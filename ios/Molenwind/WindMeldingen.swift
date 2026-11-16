import Foundation
import UserNotifications
import BackgroundTasks

/// Meldingen voor de molenaar: windomslag en harde wind bij "mijn molen".
/// Dit zijn lokale meldingen die de app zelf inplant op het voorspelde moment (geen server nodig).
/// Op de achtergrond ververst iOS af en toe de verwachting (BGAppRefresh), zodat de planning actueel blijft.
enum WindMeldingen {
    static let taakID = "info.cafferata.molenwind.windcheck"
    static let instellingKey = "meldingenAan"
    static var aan: Bool { UserDefaults.standard.bool(forKey: instellingKey) }

    /// Hoeveel eerder we waarschuwen.
    static let omslagVooraf: TimeInterval = 30 * 60
    static let stormVooraf: TimeInterval = 60 * 60

    static func vraagToestemming() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Plan (of werk bij) de meldingen op basis van de verwachting. Eén melding per gebeurtenis:
    /// de id bevat het uur van de gebeurtenis, zodat dezelfde omslag nooit twee keer gemeld wordt.
    static func plan(molen: Molen, nu: WindMoment, verwachting: [WindMoment]) async {
        let centrum = UNUserNotificationCenter.current()
        let eigen = { (id: String) in id.hasPrefix("omslag-") || id.hasPrefix("storm-") }
        let wachtend = await centrum.pendingNotificationRequests().map(\.identifier).filter(eigen)

        guard aan else {
            centrum.removePendingNotificationRequests(withIdentifiers: wachtend)
            return
        }

        var gewenst: [(id: String, inhoud: UNMutableNotificationContent, op: Date)] = []
        let komend = verwachting.filter { $0.tijd > .now }.prefix(24)
        let tijd = { (d: Date) in d.formatted(date: .omitted, time: .shortened) }

        if let o = komend.first(where: { Kompas.verschil($0.richting, nu.richting) > 45 }) {
            let inhoud = UNMutableNotificationContent()
            inhoud.title = String(localized: "Windomslag bij \(molen.naam)")
            inhoud.body = String(localized: "Rond \(tijd(o.tijd)) draait de wind naar \(o.windstreek) (nu \(nu.windstreek)). Tijd om te kruien.")
            inhoud.sound = .default
            gewenst.append(("omslag-\(Int(o.tijd.timeIntervalSince1970))", inhoud, o.tijd.addingTimeInterval(-omslagVooraf)))
        }
        if let s = komend.first(where: { Maalweer.oordeel($0) == .stilzetten }) {
            let inhoud = UNMutableNotificationContent()
            inhoud.title = String(localized: "Harde wind bij \(molen.naam)")
            inhoud.body = String(localized: "Rond \(tijd(s.tijd)) verwacht: Bft \(s.beaufort), stoten Bft \(s.stotenBeaufort). Denk aan stilzetten.")
            inhoud.sound = .default
            gewenst.append(("storm-\(Int(s.tijd.timeIntervalSince1970))", inhoud, s.tijd.addingTimeInterval(-stormVooraf)))
        }

        let gewensteIDs = Set(gewenst.map(\.id))
        centrum.removePendingNotificationRequests(withIdentifiers: wachtend.filter { !gewensteIDs.contains($0) })
        let afgeleverd = Set(await centrum.deliveredNotifications().map(\.request.identifier))

        for g in gewenst where !afgeleverd.contains(g.id) && !wachtend.contains(g.id) {
            // Ligt het waarschuwingsmoment al achter ons (gebeurtenis komt wel nog), dan meteen melden.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(5, g.op.timeIntervalSinceNow), repeats: false)
            try? await centrum.add(UNNotificationRequest(identifier: g.id, content: g.inhoud, trigger: trigger))
        }
    }

    /// Vraag iOS om over ongeveer een uur op de achtergrond de verwachting te verversen.
    static func planAchtergrondCheck() {
        guard aan else { return }
        let verzoek = BGAppRefreshTaskRequest(identifier: taakID)
        verzoek.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        try? BGTaskScheduler.shared.submit(verzoek)
    }

    /// Wordt door iOS op de achtergrond aangeroepen.
    static func achtergrondCheck() async {
        planAchtergrondCheck()
        guard aan, let molen = MolenStore().mijnMolen,
              let r = try? await WindService.haal(lat: molen.lat, lon: molen.lon) else { return }
        await plan(molen: molen, nu: r.nu, verwachting: r.verwachting)
    }
}

/// Toon meldingen ook als de app open is.
final class MeldingDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let gedeeld = MeldingDelegate()
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

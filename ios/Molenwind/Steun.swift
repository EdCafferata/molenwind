import Foundation
import StoreKit
import Observation

/// Instellingen voor steun en reviews.
enum AppInfo {
    /// App Store-id zodra de app in de store staat (dan verschijnt de knop "Schrijf een review").
    static let appStoreID: String? = nil

    static var reviewURL: URL? {
        appStoreID.flatMap { URL(string: "https://apps.apple.com/app/id\($0)?action=write-review") }
    }

    /// Na hoeveel verschillende gebruiksdagen we (hooguit) om een beoordeling vragen.
    /// Apple toont de vraag zelf maximaal 3× per jaar, ongeacht hoe vaak we het aanroepen.
    static let reviewDagen: Set<Int> = [3, 10, 30]
}

/// Fooienpot: vrijwillige donaties via In-App Purchase (verbruiksartikelen).
/// Apple staat donaties aan een ontwikkelaar alleen toe via IAP (richtlijn 3.1.1), niet via externe links.
/// De producten moeten nog in App Store Connect worden aangemaakt; lokaal testen kan met `Molenwind.storekit`.
@Observable
@MainActor
final class FooiPot {
    /// Fooien in molenstijl, van klein naar groot.
    struct Soort {
        let id: String
        let titel: String
        let uitleg: String
        let symbool: String
    }

    static let soorten: [Soort] = [
        .init(id: "info.cafferata.molenwind.fooi.koffie", titel: String(localized: "Kop koffie voor de molenaar"),
              uitleg: String(localized: "Even bijkomen op de stelling."), symbool: "cup.and.saucer.fill"),
        .init(id: "info.cafferata.molenwind.fooi.meel", titel: String(localized: "Zak molenmeel"),
              uitleg: String(localized: "Vers van de steen gemalen."), symbool: "bag.fill"),
        .init(id: "info.cafferata.molenwind.fooi.zeil", titel: String(localized: "Nieuw zeil"),
              uitleg: String(localized: "Zodat de wieken weer vol in de wind staan."), symbool: "sailboat.fill"),
        .init(id: "info.cafferata.molenwind.fooi.molensteen", titel: String(localized: "Molensteen"),
              uitleg: String(localized: "Het zware werk. Heel erg bedankt!"), symbool: "circle.circle.fill"),
    ]

    static var productIDs: [String] { soorten.map(\.id) }

    static func soort(voor product: Product) -> Soort? { soorten.first { $0.id == product.id } }

    /// Externe donatie aan de molens zelf (De Hollandsche Molen). Mag volgens richtlijn 3.2.2 alleen
    /// buiten de app om (Safari), niet via IAP. Geen samenwerking: gewoon een doorverwijzing.
    static let molensSteunenURL = URL(string: "https://www.molens.nl/steun-molens")!

    private(set) var producten: [Product] = []
    private(set) var laden = false
    private(set) var bezig: String?
    var melding: String?

    func laad() async {
        guard producten.isEmpty, !laden else { return }
        laden = true; defer { laden = false }
        producten = ((try? await Product.products(for: Self.productIDs)) ?? []).sorted { $0.price < $1.price }
    }

    func geef(_ product: Product) async {
        bezig = product.id; defer { bezig = nil }
        do {
            switch try await product.purchase() {
            case .success(let resultaat):
                if case .verified(let transactie) = resultaat {
                    await transactie.finish()
                    melding = String(localized: "Dank je wel! Hiermee blijft Molenwind gratis en draaien de molens door. 🌬️")
                } else {
                    melding = String(localized: "De betaling kon niet worden gecontroleerd.")
                }
            case .pending:
                melding = String(localized: "Je fooi wacht nog op goedkeuring.")
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            melding = String(localized: "Er ging iets mis: \(error.localizedDescription)")
        }
    }

    /// Rond transacties af die buiten de app om zijn voltooid (bijv. na goedkeuring door een ouder).
    static func luisterNaarTransacties() -> Task<Void, Never> {
        Task.detached {
            for await update in Transaction.updates {
                if case .verified(let t) = update { await t.finish() }
            }
        }
    }
}

import SwiftUI
import UserNotifications

@main
struct MolenwindApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = MolenStore()
    @State private var locatie = Locatie()
    // Debug: start met `-startTab kaart` (of `over`) om direct dat tabblad te openen (handig voor screenshots/tests).
    @State private var tab = UserDefaults.standard.string(forKey: "startTab") ?? "molen"
    @State private var transactieLuisteraar = FooiPot.luisterNaarTransacties()

    init() {
        UNUserNotificationCenter.current().delegate = MeldingDelegate.gedeeld
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $tab) {
                MijnMolenView()
                    .tabItem { Label("Mijn molen", systemImage: "wind") }
                    .tag("molen")
                KaartView()
                    .tabItem { Label("Ontdekken", systemImage: "map") }
                    .tag("kaart")
                OverView()
                    .tabItem { Label("Over", systemImage: "heart") }
                    .tag("over")
            }
            .environment(store)
            .environment(locatie)
            .tint(.orange)
        }
        .onChange(of: scenePhase) { _, fase in
            if fase == .background { WindMeldingen.planAchtergrondCheck() }
        }
        .backgroundTask(.appRefresh(WindMeldingen.taakID)) {
            await WindMeldingen.achtergrondCheck()
        }
    }
}

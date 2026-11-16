import SwiftUI
import MapKit
import StoreKit

/// Molenaarsstand: wind voor precies de eigen molen.
struct MijnMolenView: View {
    @Environment(MolenStore.self) private var store
    @State private var kiezerOpen = false

    var body: some View {
        NavigationStack {
            Group {
                if let molen = store.mijnMolen {
                    WindPaneel(molen: molen)
                } else {
                    ContentUnavailableView {
                        Label("Kies je molen", systemImage: "wind")
                    } description: {
                        Text("Kies de molen waar je maalt. Je ziet dan de wind, de windrichting en de stoten op precies die plek.")
                    } actions: {
                        Button("Molen kiezen") { kiezerOpen = true }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle(store.mijnMolen?.naam ?? "Mijn molen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { kiezerOpen = true } label: { Image(systemName: "list.bullet") }
                        .accessibilityLabel("Andere molen kiezen")
                }
            }
            .sheet(isPresented: $kiezerOpen) {
                MolenKiezer { store.mijnMolenID = $0.id; kiezerOpen = false }
            }
            .onAppear {
                // Debug: `-toonKiezer YES` opent direct de molenkiezer.
                if UserDefaults.standard.bool(forKey: "toonKiezer") { kiezerOpen = true }
            }
        }
    }
}

struct WindPaneel: View {
    let molen: Molen
    @Environment(\.requestReview) private var requestReview
    @AppStorage("gebruiksdagen") private var gebruiksdagen = 0
    @AppStorage("laatsteGebruiksdag") private var laatsteGebruiksdag = ""
    @State private var nu: WindMoment?
    @State private var verwachting: [WindMoment] = []
    @State private var fout: String?
    @State private var laden = false
    @State private var gescrold = false
    @AppStorage(WindMeldingen.instellingKey) private var meldingenAan = false
    @State private var meldingGeweigerd = false

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(spacing: 20) {
                Text("\(molen.plaats) · \(molen.type)")
                    .font(.subheadline).foregroundStyle(.secondary)

                if let nu {
                    WindKompas(richting: nu.richting)
                        .frame(width: 260, height: 260)

                    VStack(spacing: 4) {
                        Text("Wind uit \(nu.windstreek)")
                            .font(.title.bold())
                        Text("\(Int(nu.richting.rounded()))° · kruien naar \(nu.windstreek)")
                            .font(.headline).foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        Tegel(titel: "Wind", waarde: "Bft \(nu.beaufort)",
                              onder: String(format: "%.1f m/s · %@", nu.snelheid, Beaufort.namen[nu.beaufort]))
                        Tegel(titel: "Stoten", waarde: "Bft \(nu.stotenBeaufort)",
                              onder: String(format: "%.1f m/s", nu.stoten))
                    }

                    MolenZoomKaart(molen: molen, windRichting: nu.richting)
                        .id("meer")

                    let oordeel = Maalweer.oordeel(nu)
                    Label(oordeel.titel, systemImage: oordeel.symbool)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding(.vertical, 12).frame(maxWidth: .infinity)
                        .background(oordeel.kleur, in: .rect(cornerRadius: 14))

                    if let omslag = eersteOmslag(nu: nu) {
                        Label {
                            Text("Rond \(omslag.tijd.formatted(date: .omitted, time: .shortened)) draait de wind naar \(omslag.windstreek) — opnieuw kruien.")
                        } icon: { Image(systemName: "arrow.triangle.2.circlepath") }
                            .font(.callout)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.orange.opacity(0.15), in: .rect(cornerRadius: 12))
                    }

                    Toggle(isOn: $meldingenAan) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Meldingen")
                                Text("Bij windomslag (30 min vooraf) en harde wind (1 uur vooraf)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        } icon: { Image(systemName: "bell.badge.fill").foregroundStyle(.orange) }
                    }
                    .padding()
                    .background(.thinMaterial, in: .rect(cornerRadius: 14))
                    .onChange(of: meldingenAan) { _, aan in
                        Task {
                            if aan, !(await WindMeldingen.vraagToestemming()) {
                                meldingenAan = false
                                meldingGeweigerd = true
                                return
                            }
                            await WindMeldingen.plan(molen: molen, nu: nu, verwachting: verwachting)
                            WindMeldingen.planAchtergrondCheck()
                        }
                    }
                    .alert("Meldingen staan uit", isPresented: $meldingGeweigerd) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Zet meldingen voor Molenwind aan in Instellingen › Meldingen.")
                    }

                    VerwachtingLijst(verwachting: verwachting, huidigeRichting: nu.richting)
                } else if let fout {
                    ContentUnavailableView("Geen winddata", systemImage: "wifi.slash", description: Text(fout))
                } else {
                    ProgressView("Wind ophalen…").padding(.top, 80)
                }

                Text("Windverwachting: KNMI Harmonie (2 km) via Open-Meteo, CC-BY 4.0. Wind op 10 m hoogte. Alleen een hulpmiddel — de molenaar beslist.")
                    .font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .padding()
        }
        // Scrollbalk rechts laten oplichten bij openen, zodat zichtbaar is dat er meer onder staat.
        .scrollIndicators(.visible)
        .scrollIndicatorsFlash(onAppear: true)
        .onScrollGeometryChange(for: Bool.self) { $0.contentOffset.y > 40 } action: { _, nieuw in
            withAnimation { gescrold = nieuw }
        }
        // Zwevende hint onderaan; verdwijnt zodra er gescrold is. Tikken scrolt naar kaart en verwachting.
        .overlay(alignment: .bottom) {
            if nu != nil && !gescrold {
                Button {
                    withAnimation { proxy.scrollTo("meer", anchor: .top) }
                } label: {
                    Label("Meer: kaart & verwachting", systemImage: "chevron.down")
                        .font(.subheadline.bold())
                        .symbolEffect(.bounce, options: .repeat(.periodic(delay: 1.5)))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(.orange, in: .capsule)
                        .foregroundStyle(.white)
                        .shadow(radius: 6)
                }
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .refreshable { await laad() }
        .task(id: molen.id) { await laad() }
        }
    }

    /// Eerste uur in de komende 12 uur waarop de wind meer dan 45° van nu afwijkt.
    private func eersteOmslag(nu: WindMoment) -> WindMoment? {
        verwachting.prefix(12).first { $0.tijd > .now && Kompas.verschil($0.richting, nu.richting) > 45 }
    }

    private func laad() async {
        guard !laden else { return }
        laden = true; defer { laden = false }
        do {
            let r = try await WindService.haal(lat: molen.lat, lon: molen.lon)
            nu = r.nu; verwachting = r.verwachting; fout = nil
            await WindMeldingen.plan(molen: molen, nu: r.nu, verwachting: r.verwachting)
            // Tel gebruiksdagen (niet het aantal keer laden); pas na een paar dagen echt gebruik om een review vragen.
            let vandaag = Date().formatted(.iso8601.year().month().day())
            if laatsteGebruiksdag != vandaag {
                laatsteGebruiksdag = vandaag
                gebruiksdagen += 1
                if AppInfo.reviewDagen.contains(gebruiksdagen) {
                    try? await Task.sleep(for: .seconds(2))   // eerst de wind laten zien
                    requestReview()
                }
            }
        } catch {
            fout = String(localized: "Kon de wind niet ophalen. Trek omlaag om opnieuw te proberen.")
        }
    }
}

/// Kompasroos met een pijl die aangeeft waar de wind VANDAAN komt (daar moet de kap naartoe).
struct WindKompas: View {
    let richting: Double

    var body: some View {
        ZStack {
            Circle().fill(.thinMaterial)
            Circle().stroke(.secondary.opacity(0.4), lineWidth: 2)
            ForEach(0..<16) { i in
                Capsule()
                    .fill(.secondary.opacity(i % 4 == 0 ? 0.8 : 0.35))
                    .frame(width: 2, height: i % 4 == 0 ? 14 : 7)
                    .offset(y: -118)
                    .rotationEffect(.degrees(Double(i) * 22.5))
            }
            ForEach(0..<4) { i in
                Text(Kompas.streek(Double(i) * 90)).font(.headline)
                    .offset(y: -96)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            // Molensymbool in het midden, gedraaid zodat de wieken in de wind staan.
            Image(systemName: "fanblades.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            // Pijl vanaf de windrichting naar het midden.
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 30))
                .foregroundStyle(.blue)
                .offset(y: -66)
                .rotationEffect(.degrees(richting))
                .animation(.spring, value: richting)
        }
        .accessibilityElement()
        .accessibilityLabel("Wind uit \(Kompas.streek(richting)), \(Int(richting)) graden")
    }
}

/// Satellietkaart die vanaf de omgeving inzoomt op de eigen molen, met de windrichting erover.
struct MolenZoomKaart: View {
    let molen: Molen
    let windRichting: Double
    @State private var positie: MapCameraPosition = .automatic

    private func regio(_ span: Double) -> MapCameraPosition {
        .region(MKCoordinateRegion(center: molen.coordinate,
                                   span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)))
    }

    var body: some View {
        Map(position: $positie) {
            Annotation(molen.naam, coordinate: molen.coordinate) {
                Image(systemName: "fanblades.fill")
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.orange, in: .circle)
            }
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .frame(height: 220)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(alignment: .topTrailing) {
            // Pijl wijst in de stroomrichting (wind uit ZW → pijl naar NO).
            VStack(spacing: 2) {
                Image(systemName: "arrow.up")
                    .font(.title2.bold())
                    .rotationEffect(.degrees(windRichting + 180))
                Text("wind").font(.caption2)
            }
            .foregroundStyle(.white)
            .padding(8)
            .background(.blue.opacity(0.85), in: .rect(cornerRadius: 10))
            .padding(10)
        }
        .task(id: molen.id) {
            // Eerst de omgeving tonen, dan na een moment inzoomen tot de molen zelf goed zichtbaar is.
            positie = regio(0.25)
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeInOut(duration: 2.5)) { positie = regio(0.003) }
        }
    }
}

struct Tegel: View {
    let titel: LocalizedStringKey, waarde: String, onder: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titel).font(.caption).foregroundStyle(.secondary)
            Text(waarde).font(.title.bold())
            Text(onder).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 14))
    }
}

struct VerwachtingLijst: View {
    let verwachting: [WindMoment]
    let huidigeRichting: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Komende 12 uur").font(.headline).padding(.bottom, 8)
            ForEach(verwachting.filter { $0.tijd > .now.addingTimeInterval(-3600) }.prefix(12)) { m in
                HStack {
                    Text(m.tijd.formatted(date: .omitted, time: .shortened))
                        .monospacedDigit().frame(width: 56, alignment: .leading)
                    Image(systemName: "arrow.down")
                        .rotationEffect(.degrees(m.richting))
                        .foregroundStyle(Kompas.verschil(m.richting, huidigeRichting) > 45 ? .orange : .blue)
                    Text(m.windstreek).frame(width: 44, alignment: .leading)
                    Spacer()
                    Text("Bft \(m.beaufort)").bold()
                    Text("stoten \(m.stotenBeaufort)").font(.caption).foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .trailing)
                    Circle().fill(Maalweer.oordeel(m).kleur).frame(width: 10, height: 10)
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 14))
    }
}

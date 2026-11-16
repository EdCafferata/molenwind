import SwiftUI
import MapKit

/// Toeristenstand: alle windmolens op de kaart, geclusterd bij uitzoomen.
struct KaartView: View {
    @Environment(MolenStore.self) private var store
    @State private var geselecteerd: Molen?

    var body: some View {
        NavigationStack {
            MolenKaart(molens: store.molens.filter(\.isWindmolen)) { geselecteerd = $0 }
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Ontdek molens")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(item: $geselecteerd) {
                    // Opent hoog (92% van het scherm) zodat foto en gegevens direct in beeld zijn; omhoog vegen = volledig.
                    MolenDetailView(molen: $0)
                        .presentationDetents([.fraction(0.92), .large])
                        .presentationDragIndicator(.visible)
                }
                .onAppear {
                    // Debug: `-toonMolen <TBGC-nummer>` opent direct een molenpagina.
                    if let id = UserDefaults.standard.string(forKey: "toonMolen"), geselecteerd == nil {
                        geselecteerd = store.molens.first { $0.id == id }
                    }
                }
        }
    }
}

/// MKMapView-wrapper: SwiftUI's Map kent (nog) geen clustering, MKMapView wel.
struct MolenKaart: UIViewRepresentable {
    let molens: [Molen]
    let tik: (Molen) -> Void

    final class Pin: NSObject, MKAnnotation {
        let molen: Molen
        var coordinate: CLLocationCoordinate2D { molen.coordinate }
        var title: String? { molen.naam }
        init(_ m: Molen) { molen = m }
    }

    func makeCoordinator() -> Coordinator { Coordinator(tik: tik) }

    func makeUIView(context: Context) -> MKMapView {
        let kaart = MKMapView()
        kaart.delegate = context.coordinator
        kaart.showsUserLocation = true
        kaart.showsCompass = true
        kaart.pointOfInterestFilter = .excludingAll
        kaart.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "molen")
        kaart.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        kaart.setRegion(MKCoordinateRegion(center: .init(latitude: 52.2, longitude: 5.3),
                                           span: .init(latitudeDelta: 3.4, longitudeDelta: 3.4)), animated: false)
        let pins = molens.map(Pin.init)
        kaart.addAnnotations(pins)
        context.coordinator.start(kaart: kaart, pins: pins)
        return kaart
    }

    func updateUIView(_ kaart: MKMapView, context: Context) {}

    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let tik: (Molen) -> Void
        private let locatie = CLLocationManager()
        private weak var kaart: MKMapView?
        private var pins: [Pin] = []
        private var gestartOp = Date()
        private var ingezoomd = false

        /// Hoeveel molens we bij het inzoomen in beeld willen hebben, en na hoeveel seconden.
        private let aantalDichtbij = 5
        private let wachtTijd: TimeInterval = 2.5

        init(tik: @escaping (Molen) -> Void) { self.tik = tik }

        /// Toon eerst heel Nederland; zodra de locatie bekend is (en na een paar seconden) inzoomen op de
        /// dichtstbijzijnde molens.
        func start(kaart: MKMapView, pins: [Pin]) {
            self.kaart = kaart
            self.pins = pins
            gestartOp = .now
            locatie.delegate = self
            locatie.desiredAccuracy = kCLLocationAccuracyHundredMeters
            switch locatie.authorizationStatus {
            case .notDetermined: locatie.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways: locatie.requestLocation()
            default: break   // geen toestemming: blijf op het Nederland-overzicht
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard !ingezoomd, let plek = locations.last else { return }
            ingezoomd = true
            let wacht = max(0, wachtTijd - Date().timeIntervalSince(gestartOp))
            DispatchQueue.main.asyncAfter(deadline: .now() + wacht) { [weak self] in
                self?.zoomNaarDichtbij(plek)
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            // Geen locatie: overzicht laten staan.
        }

        private func zoomNaarDichtbij(_ plek: CLLocation) {
            guard let kaart else { return }
            let dichtbij = pins
                .map { ($0, plek.distance(from: CLLocation(latitude: $0.molen.lat, longitude: $0.molen.lon))) }
                .sorted { $0.1 < $1.1 }
                .prefix(aantalDichtbij)
            guard !dichtbij.isEmpty else { return }

            // Rechthoek om de gebruiker en de dichtstbijzijnde molens, met wat marge.
            var rect = MKMapRect(origin: MKMapPoint(plek.coordinate), size: MKMapSize(width: 0, height: 0))
            for (pin, _) in dichtbij {
                rect = rect.union(MKMapRect(origin: MKMapPoint(pin.coordinate), size: MKMapSize(width: 0, height: 0)))
            }
            kaart.setVisibleMapRect(rect,
                                    edgePadding: UIEdgeInsets(top: 90, left: 50, bottom: 140, right: 50),
                                    animated: true)
        }

        func mapView(_ kaart: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let v = kaart.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                                                             for: cluster) as! MKMarkerAnnotationView
                v.markerTintColor = .systemOrange
                v.glyphText = "\(cluster.memberAnnotations.count)"
                return v
            }
            guard annotation is Pin else { return nil }
            let v = kaart.dequeueReusableAnnotationView(withIdentifier: "molen", for: annotation) as! MKMarkerAnnotationView
            v.clusteringIdentifier = "molens"
            v.markerTintColor = .systemOrange
            v.glyphImage = UIImage(systemName: "fanblades.fill")
            v.titleVisibility = .adaptive
            return v
        }

        func mapView(_ kaart: MKMapView, didSelect annotation: MKAnnotation) {
            if let cluster = annotation as? MKClusterAnnotation {
                // Inzoomen op het cluster.
                kaart.showAnnotations(cluster.memberAnnotations, animated: true)
                kaart.deselectAnnotation(cluster, animated: false)
            } else if let pin = annotation as? Pin {
                tik(pin.molen)
                kaart.deselectAnnotation(pin, animated: false)
            }
        }
    }
}

struct MolenDetailView: View {
    @Environment(MolenStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let molen: Molen
    @State private var vandaag: [WindMoment] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let url = molen.fotoURL {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: { Color.secondary.opacity(0.15) }
                        .frame(height: 220).clipped()
                        .clipShape(.rect(cornerRadius: 14))
                        Text("Foto: \(molen.fotograaf), CC-BY-SA")
                            .font(.caption2).foregroundStyle(.secondary)
                    }

                    Text(molen.naam).font(.title2.bold())
                    Text(molen.plaats).foregroundStyle(.secondary)

                    Grid(alignment: .leading, verticalSpacing: 6) {
                        rij("Type", molen.type)
                        rij("Functie", molen.functie)
                        if !molen.bouwjaar.isEmpty { rij("Bouwjaar", molen.bouwjaar) }
                    }

                    if let dag = draaidag {
                        Label(dag.tekst, systemImage: dag.goed ? "fanblades.fill" : "wind")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background((dag.goed ? Color.green : Color.gray).opacity(0.15), in: .rect(cornerRadius: 12))
                    }

                    Text("Openingstijden volgen nog (OpenStreetMap). Tip: een blauwe wimpel aan de molen betekent dat de molenaar er is en je meestal binnen mag.")
                        .font(.callout).foregroundStyle(.secondary)

                    HStack {
                        if let url = molen.infoURL {
                            Link(destination: url) { Label("allemolens.nl", systemImage: "safari") }
                                .buttonStyle(.bordered)
                        }
                        Button { route() } label: { Label("Route", systemImage: "car") }
                            .buttonStyle(.bordered)
                    }
                    Button {
                        store.mijnMolenID = molen.id
                    } label: {
                        Label(store.mijnMolenID == molen.id ? "Dit is mijn molen" : "Maak dit mijn molen",
                              systemImage: store.mijnMolenID == molen.id ? "checkmark" : "star")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.mijnMolenID == molen.id)
                }
                .padding()
            }
            // Zwevende sluitknop rechtsboven (geen navigatiebalk, zodat alles in beeld blijft).
            .overlay(alignment: .topTrailing) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.black.opacity(0.55), in: .circle)
                }
                .accessibilityLabel("Sluit")
                .padding(.top, 24).padding(.trailing, 26)
            }
            .task { vandaag = (try? await WindService.haal(lat: molen.lat, lon: molen.lon).verwachting) ?? [] }
        }
    }

    /// "Goede draaidag" als er vandaag of morgen overdag (9–17 u) minstens 3 uur maalweer is.
    private var draaidag: (goed: Bool, tekst: String)? {
        guard !vandaag.isEmpty else { return nil }
        let cal = Calendar.current
        let overdag = vandaag
            .filter { (9...17).contains(cal.component(.hour, from: $0.tijd)) }
            .prefix(9)
        let goed = overdag.filter { Maalweer.oordeel($0) == .maalweer }.count
        return goed >= 3
            ? (true, "Goede draaidag: genoeg wind om te malen. Of hij draait, hangt af van de molenaar.")
            : (false, "Weinig kans dat hij draait: te weinig of te veel wind.")
    }

    private func rij(_ k: String, _ v: String) -> some View {
        GridRow {
            Text(k).foregroundStyle(.secondary)
            Text(v)
        }
    }

    private func route() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: molen.coordinate))
        item.name = molen.naam
        item.openInMaps()
    }
}

import Foundation
import CoreLocation
import Observation

/// Eén molen uit de RCE-molendataset (publiek domein), voorbewerkt naar Resources/molens.json.
struct Molen: Identifiable, Decodable, Hashable {
    let id: String          // Ten Bruggencate-nummer
    let naam: String
    let plaats: String
    let categorie: String   // windmolen, watermolen, rosmolen, ...
    let functie: String     // korenmolen, poldermolen, ...
    let type: String        // stellingmolen, grondzeiler, ...
    let bouwjaar: String
    let lat: Double
    let lon: Double
    let foto: String
    let fotograaf: String
    let link: String
    /// Openingstijden in OSM-notatie (alleen als ze in OpenStreetMap staan).
    let open: String?
    /// Eigen website van de molen (uit OpenStreetMap).
    let web: String?
    /// OpenStreetMap-object van de molen ("node/123"), om tijden te bekijken of te verbeteren.
    let osm: String?

    var coordinate: CLLocationCoordinate2D { .init(latitude: lat, longitude: lon) }
    var openingstijden: Openingstijden? { open.map(Openingstijden.init) }
    /// Functie in de taal van het toestel (korenmolen → corn mill, ...).
    var functieLokaal: String { String(localized: String.LocalizationValue(functie)) }
    var websiteURL: URL? { web.flatMap(URL.init(string:)) }
    var isWindmolen: Bool { categorie == "windmolen" }
    var fotoURL: URL? { URL(string: foto) }
    var infoURL: URL? { URL(string: link) }
    var osmURL: URL? { osm.flatMap { URL(string: "https://www.openstreetmap.org/\($0)") } }
}

@Observable
final class MolenStore {
    let molens: [Molen]

    /// Gekozen "mijn molen" (Ten Bruggencate-nummer), bewaard tussen sessies.
    var mijnMolenID: String? {
        didSet { UserDefaults.standard.set(mijnMolenID, forKey: "mijnMolenID") }
    }

    var mijnMolen: Molen? { molens.first { $0.id == mijnMolenID } }

    init() {
        if let url = Bundle.main.url(forResource: "molens", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let lijst = try? JSONDecoder().decode([Molen].self, from: data) {
            molens = lijst.sorted { $0.naam.localizedCompare($1.naam) == .orderedAscending }
        } else {
            molens = []
        }
        mijnMolenID = UserDefaults.standard.string(forKey: "mijnMolenID")
    }
}

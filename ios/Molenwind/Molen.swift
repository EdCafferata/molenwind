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

    var coordinate: CLLocationCoordinate2D { .init(latitude: lat, longitude: lon) }
    var isWindmolen: Bool { categorie == "windmolen" }
    var fotoURL: URL? { URL(string: foto) }
    var infoURL: URL? { URL(string: link) }
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

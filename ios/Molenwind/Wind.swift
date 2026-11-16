import Foundation
import SwiftUI

/// Windwaarde op één moment: snelheid en stoten in m/s, richting in graden (waar de wind VANDAAN komt).
struct WindMoment: Identifiable, Hashable {
    let tijd: Date
    let snelheid: Double
    let richting: Double
    let stoten: Double
    var id: Date { tijd }

    var beaufort: Int { Beaufort.van(snelheid) }
    var stotenBeaufort: Int { Beaufort.van(stoten) }
    var windstreek: String { Kompas.streek(richting) }
}

enum Beaufort {
    /// Bovengrenzen (m/s) per Beaufort-klasse 0...11; daarboven 12.
    private static let grenzen: [Double] = [0.3, 1.6, 3.4, 5.5, 8.0, 10.8, 13.9, 17.2, 20.8, 24.5, 28.5, 32.7]
    static func van(_ ms: Double) -> Int { grenzen.firstIndex { ms < $0 } ?? 12 }

    static let namen = ["windstil", "zwak", "zwak", "matig", "matig", "vrij krachtig", "krachtig",
                        "hard", "stormachtig", "storm", "zware storm", "zeer zware storm", "orkaan"]
}

enum Kompas {
    static let streken = ["N", "NNO", "NO", "ONO", "O", "OZO", "ZO", "ZZO",
                          "Z", "ZZW", "ZW", "WZW", "W", "WNW", "NW", "NNW"]
    static func streek(_ graden: Double) -> String {
        let i = Int((graden.truncatingRemainder(dividingBy: 360) + 11.25) / 22.5) % 16
        return streken[i]
    }
    /// Kleinste hoekverschil (0...180) tussen twee richtingen.
    static func verschil(_ a: Double, _ b: Double) -> Double {
        let d = abs(a - b).truncatingRemainder(dividingBy: 360)
        return d > 180 ? 360 - d : d
    }
}

/// Maalweer-oordeel. Standaardgrenzen uit de molenaarspraktijk (Gilde: malen tot ~Bft 7);
/// alleen een hulpmiddel — de molenaar beslist zelf.
enum Maalweer {
    case teWeinigWind, maalweer, stevig, stilzetten

    static func oordeel(_ m: WindMoment) -> Maalweer {
        switch max(m.beaufort, m.stotenBeaufort - 1) {
        case ..<2: return .teWeinigWind
        case 2...5: return .maalweer
        case 6...7: return .stevig
        default: return .stilzetten
        }
    }

    var titel: String {
        switch self {
        case .teWeinigWind: "Te weinig wind"
        case .maalweer: "Goed maalweer"
        case .stevig: "Stevige wind — minder zeil"
        case .stilzetten: "Te hard — stilzetten"
        }
    }

    var kleur: Color {
        switch self {
        case .teWeinigWind: .gray
        case .maalweer: .green
        case .stevig: .orange
        case .stilzetten: .red
        }
    }

    var symbool: String {
        switch self {
        case .teWeinigWind: "wind"
        case .maalweer: "checkmark.circle.fill"
        case .stevig: "exclamationmark.triangle.fill"
        case .stilzetten: "xmark.octagon.fill"
        }
    }
}

/// Haalt de windvoorspelling op bij Open-Meteo met het KNMI Harmonie-model (2 km), zonder API-sleutel.
/// Data: KNMI via Open-Meteo, CC-BY 4.0.
enum WindService {
    struct Antwoord: Decodable {
        struct Huidig: Decodable {
            let time: String
            let wind_speed_10m: Double
            let wind_direction_10m: Double
            let wind_gusts_10m: Double
        }
        struct Uurlijks: Decodable {
            let time: [String]
            let wind_speed_10m: [Double?]
            let wind_direction_10m: [Double?]
            let wind_gusts_10m: [Double?]
        }
        let current: Huidig
        let hourly: Uurlijks
    }

    private static let tijdFormaat: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Europe/Amsterdam")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f
    }()

    static func haal(lat: Double, lon: Double) async throws -> (nu: WindMoment, verwachting: [WindMoment]) {
        var c = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        let velden = "wind_speed_10m,wind_direction_10m,wind_gusts_10m"
        c.queryItems = [
            .init(name: "latitude", value: String(lat)),
            .init(name: "longitude", value: String(lon)),
            .init(name: "current", value: velden),
            .init(name: "hourly", value: velden),
            .init(name: "wind_speed_unit", value: "ms"),
            .init(name: "forecast_hours", value: "24"),
            .init(name: "timezone", value: "Europe/Amsterdam"),
            .init(name: "models", value: "knmi_seamless"),
        ]
        let (data, _) = try await URLSession.shared.data(from: c.url!)
        let a = try JSONDecoder().decode(Antwoord.self, from: data)

        let nu = WindMoment(tijd: tijdFormaat.date(from: a.current.time) ?? .now,
                            snelheid: a.current.wind_speed_10m,
                            richting: a.current.wind_direction_10m,
                            stoten: a.current.wind_gusts_10m)
        let h = a.hourly
        let verwachting: [WindMoment] = h.time.indices.compactMap { i in
            guard let t = tijdFormaat.date(from: h.time[i]),
                  let s = h.wind_speed_10m[i], let r = h.wind_direction_10m[i], let g = h.wind_gusts_10m[i]
            else { return nil }
            return WindMoment(tijd: t, snelheid: s, richting: r, stoten: g)
        }
        return (nu, verwachting)
    }
}

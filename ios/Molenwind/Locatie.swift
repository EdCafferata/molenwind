import CoreLocation
import Observation

/// Eenmalige locatiebepaling (alleen tijdens gebruik), gedeeld door de schermen.
@Observable
final class Locatie: NSObject, CLLocationManagerDelegate {
    private(set) var plek: CLLocation?
    @ObservationIgnored private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func vraag() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
        default: break
        }
    }

    func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        if m.authorizationStatus == .authorizedWhenInUse || m.authorizationStatus == .authorizedAlways {
            m.requestLocation()
        }
    }

    func locationManager(_ m: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        plek = locations.last
    }

    func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {}

    /// Afstand tot een molen in meters (nil zonder locatie).
    func afstand(tot molen: Molen) -> CLLocationDistance? {
        plek?.distance(from: CLLocation(latitude: molen.lat, longitude: molen.lon))
    }
}

extension CLLocationDistance {
    var leesbaar: String {
        self < 1000 ? "\(Int((self / 50).rounded() * 50)) m" : String(format: "%.1f km", self / 1000)
    }
}

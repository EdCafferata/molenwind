import Foundation

/// Eenvoudige lezer voor de OpenStreetMap-notatie `opening_hours`
/// (bijv. "Apr-Oct Tu-Su 09:00-16:30; Mar Su 12:00-16:00; PH off").
/// Ondersteunt maanden, weekdagen, tijden en "off". Wat niet te lezen is, tonen we als ruwe tekst.
struct Openingstijden {
    struct Regel {
        var maanden: Set<Int>?          // 1...12, nil = hele jaar
        var dagen: Set<Int>?            // 1 = ma ... 7 = zo, nil = elke dag
        var tijden: [ClosedRange<Int>]  // minuten sinds middernacht; leeg = gesloten
    }

    let ruw: String
    let regels: [Regel]
    let opmerking: String?
    let volledigGelezen: Bool

    private static let dagCodes = ["Mo": 1, "Tu": 2, "We": 3, "Th": 4, "Fr": 5, "Sa": 6, "Su": 7]
    private static let maandCodes = ["Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
                                     "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12]

    init(_ tekst: String) {
        ruw = tekst
        var opm: String?
        var regels: [Regel] = []
        var alles = true
        for deel in tekst.split(separator: ";") {
            var s = deel.trimmingCharacters(in: .whitespaces)
            // Opmerkingen tussen aanhalingstekens apart bewaren.
            if let q1 = s.firstIndex(of: "\""), let q2 = s[s.index(after: q1)...].firstIndex(of: "\"") {
                opm = String(s[s.index(after: q1)..<q2])
                s.removeSubrange(q1...q2)
                s = s.trimmingCharacters(in: .whitespaces)
            }
            if s.isEmpty { continue }
            if s.hasPrefix("PH") { continue }  // feestdagen: overslaan
            if let r = Self.leesRegel(s) { regels.append(r) } else { alles = false }
        }
        self.regels = regels
        self.opmerking = opm
        self.volledigGelezen = alles && !regels.isEmpty
    }

    private static func leesRegel(_ s: String) -> Regel? {
        var maanden: Set<Int>?
        var dagen: Set<Int>?
        var tijden: [ClosedRange<Int>] = []
        var gesloten = false
        // Tijden mogen spaties rond het streepje hebben ("10:00 - 16:00").
        let schoon = s.replacingOccurrences(of: " - ", with: "-")
        for token in schoon.split(separator: " ").map(String.init) {
            if token == "off" || token == "closed" { gesloten = true; continue }
            if let t = leesTijden(token) { tijden += t; continue }
            if let m = leesLijst(token, codes: maandCodes, max: 12) { maanden = (maanden ?? []).union(m); continue }
            if let d = leesLijst(token, codes: dagCodes, max: 7) { dagen = (dagen ?? []).union(d); continue }
            return nil
        }
        if gesloten { tijden = [] } else if tijden.isEmpty { return nil }
        return Regel(maanden: maanden, dagen: dagen, tijden: tijden)
    }

    /// "Mo-Fr,Su" of "Apr-Oct" → set met nummers (met omloop, bijv. "Nov-Mar").
    private static func leesLijst(_ token: String, codes: [String: Int], max: Int) -> Set<Int>? {
        var set = Set<Int>()
        for stuk in token.split(separator: ",") {
            let delen = stuk.split(separator: "-").map(String.init)
            guard let a = codes[delen[0]] else { return nil }
            if delen.count == 1 { set.insert(a); continue }
            guard delen.count == 2, let b = codes[delen[1]] else { return nil }
            var i = a
            while true { set.insert(i); if i == b { break }; i = i % max + 1 }
        }
        return set.isEmpty ? nil : set
    }

    /// "09:00-12:00,13:00-17:00" → bereiken in minuten.
    private static func leesTijden(_ token: String) -> [ClosedRange<Int>]? {
        var uit: [ClosedRange<Int>] = []
        for stuk in token.split(separator: ",") {
            let d = stuk.split(separator: "-")
            guard d.count == 2, let a = minuten(d[0]), let b = minuten(d[1]), a < b else { return nil }
            uit.append(a...b)
        }
        return uit.isEmpty ? nil : uit
    }

    private static func minuten(_ s: Substring) -> Int? {
        let d = s.split(separator: ":")
        guard d.count == 2, let h = Int(d[0]), let m = Int(d[1]), (0...24).contains(h), (0...59).contains(m) else { return nil }
        return h * 60 + m
    }

    /// Tijden voor een bepaalde datum (latere regels overschrijven eerdere, zoals in OSM).
    func tijden(op datum: Date, kalender: Calendar = .current) -> [ClosedRange<Int>] {
        let maand = kalender.component(.month, from: datum)
        let wd = kalender.component(.weekday, from: datum)      // 1 = zondag
        let dag = wd == 1 ? 7 : wd - 1                           // 1 = maandag
        var resultaat: [ClosedRange<Int>] = []
        for r in regels where (r.maanden?.contains(maand) ?? true) && (r.dagen?.contains(dag) ?? true) {
            resultaat = r.tijden
        }
        return resultaat
    }

    /// Nu open? nil als de tijden niet (volledig) te lezen zijn.
    func isOpen(_ nu: Date = .now, kalender: Calendar = .current) -> Bool? {
        guard volledigGelezen else { return nil }
        let min = kalender.component(.hour, from: nu) * 60 + kalender.component(.minute, from: nu)
        return tijden(op: nu, kalender: kalender).contains { $0.contains(min) }
    }

    /// Leesbare regels in de taal van het toestel, bijv. "apr.–okt. · di–zo · 09:00–16:30".
    func leesbareRegels(locale: Locale = .current) -> [String] {
        guard volledigGelezen else { return [ruw.replacingOccurrences(of: "\"", with: "")] }
        let f = DateFormatter(); f.locale = locale
        let dagen = f.shortWeekdaySymbols!     // [zo, ma, ...]
        let maanden = f.shortMonthSymbols!
        func dagNaam(_ d: Int) -> String { dagen[d % 7] }   // 1=ma → index 1, 7=zo → index 0
        func reeks(_ set: Set<Int>, max: Int, naam: (Int) -> String) -> String {
            // Aaneengesloten reeksen samenvoegen (met omloop).
            if set.count == max { return "" }
            // Begin bij een element waarvan de voorganger ontbreekt, zodat "nov–mrt" één reeks blijft.
            let begin = set.sorted().first { !set.contains($0 == 1 ? max : $0 - 1) } ?? set.min()!
            let gesorteerd = set.sorted { (($0 - begin + max) % max) < (($1 - begin + max) % max) }
            var stukken: [String] = []
            var start = gesorteerd[0], vorige = gesorteerd[0]
            for x in gesorteerd.dropFirst() {
                if x == vorige % max + 1 { vorige = x; continue }
                stukken.append(start == vorige ? naam(start) : "\(naam(start))–\(naam(vorige))")
                start = x; vorige = x
            }
            stukken.append(start == vorige ? naam(start) : "\(naam(start))–\(naam(vorige))")
            return stukken.joined(separator: ", ")
        }
        func tijd(_ m: Int) -> String { String(format: "%02d:%02d", m / 60, m % 60) }
        return regels.map { r in
            var delen: [String] = []
            if let m = r.maanden { delen.append(reeks(m, max: 12) { maanden[$0 - 1] }) }
            if let d = r.dagen { delen.append(reeks(d, max: 7, naam: dagNaam)) }
            delen.append(r.tijden.isEmpty
                         ? String(localized: "gesloten")
                         : r.tijden.map { "\(tijd($0.lowerBound))–\(tijd($0.upperBound))" }.joined(separator: ", "))
            return delen.filter { !$0.isEmpty }.joined(separator: " · ")
        }
    }
}

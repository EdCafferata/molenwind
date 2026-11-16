import SwiftUI

/// Zoekbare lijst om "mijn molen" te kiezen (alleen windmolens). Met locatie staan de dichtstbijzijnde molens bovenaan.
struct MolenKiezer: View {
    @Environment(MolenStore.self) private var store
    @Environment(Locatie.self) private var locatie
    @Environment(\.dismiss) private var dismiss
    @State private var zoek = ""
    let gekozen: (Molen) -> Void

    private var windmolens: [Molen] { store.molens.filter(\.isWindmolen) }

    private var resultaten: [Molen] {
        guard !zoek.isEmpty else { return windmolens }
        return windmolens.filter { $0.naam.localizedCaseInsensitiveContains(zoek) || $0.plaats.localizedCaseInsensitiveContains(zoek) }
    }

    private var inDeBuurt: [Molen] {
        guard locatie.plek != nil, zoek.isEmpty else { return [] }
        return Array(windmolens
            .sorted { (locatie.afstand(tot: $0) ?? .infinity) < (locatie.afstand(tot: $1) ?? .infinity) }
            .prefix(5))
    }

    var body: some View {
        NavigationStack {
            List {
                if !inDeBuurt.isEmpty {
                    Section("In de buurt") {
                        ForEach(inDeBuurt) { rij($0) }
                    }
                }
                Section {
                    ForEach(resultaten) { rij($0) }
                } header: {
                    if !inDeBuurt.isEmpty { Text("Alle molens") }
                }
            }
            .searchable(text: $zoek, prompt: "Naam of plaats")
            .navigationTitle("Kies je molen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Sluit") { dismiss() } } }
            .onAppear { locatie.vraag() }
        }
    }

    private func rij(_ molen: Molen) -> some View {
        Button { gekozen(molen) } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(molen.naam).foregroundStyle(.primary)
                    Text("\(molen.plaats) · \(molen.functieLokaal)").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if let a = locatie.afstand(tot: molen) {
                    Text(a.leesbaar).font(.caption).foregroundStyle(.secondary).monospacedDigit()
                }
            }
        }
    }
}

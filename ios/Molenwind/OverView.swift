import SwiftUI
import StoreKit

/// Over de app: steunen (fooien in molenstijl), beoordelen, bronnen en open source.
struct OverView: View {
    @State private var pot = FooiPot()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Molenwind", systemImage: "fanblades.fill").font(.title2.bold()).foregroundStyle(.orange)
                        Text("Gratis en open source. Voor molenaars die de wind willen weten, en voor iedereen die molens wil ontdekken.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    if pot.producten.isEmpty {
                        if pot.laden {
                            ProgressView()
                        } else {
                            // Nog geen producten in de App Store: toon de fooien alvast, zonder prijs.
                            ForEach(FooiPot.soorten, id: \.id) { soort in
                                HStack(spacing: 14) {
                                    Image(systemName: soort.symbool)
                                        .font(.title2).foregroundStyle(.orange).frame(width: 34)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(soort.titel)
                                        Text(soort.uitleg).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("binnenkort").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    ForEach(pot.producten) { product in
                        let soort = FooiPot.soort(voor: product)
                        Button {
                            Task { await pot.geef(product) }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: soort?.symbool ?? "heart.fill")
                                    .font(.title2).foregroundStyle(.orange).frame(width: 34)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(soort?.titel ?? product.displayName).foregroundStyle(.primary)
                                    Text(soort?.uitleg ?? product.description).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if pot.bezig == product.id {
                                    ProgressView()
                                } else {
                                    Text(product.displayPrice)
                                        .font(.callout.bold())
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .background(.orange.opacity(0.15), in: .capsule)
                                }
                            }
                        }
                        .disabled(pot.bezig != nil)
                    }
                } header: {
                    Text("Trakteer de molenaar")
                } footer: {
                    Text("Een fooi is vrijwillig. Alle functies blijven gratis.")
                }

                Section {
                    Link(destination: FooiPot.molensSteunenURL) {
                        Label("Steun de molens zelf", systemImage: "building.columns.fill")
                    }
                } footer: {
                    Text("Opent de site van De Hollandsche Molen in Safari. Molenwind heeft geen band met die vereniging; dit is alleen een doorverwijzing.")
                }

                Section {
                    if let url = AppInfo.reviewURL {
                        Link(destination: url) { Label("Schrijf een review", systemImage: "star.bubble.fill") }
                    } else {
                        Label("Schrijf een review", systemImage: "star.bubble")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Beoordelen")
                } footer: {
                    Text(AppInfo.reviewURL == nil
                         ? "Kan zodra Molenwind in de App Store staat."
                         : "Een review helpt andere molenaars en molenliefhebbers de app te vinden.")
                }

                Section("Bronnen") {
                    bron("Molens", "Rijksdienst voor het Cultureel Erfgoed, gebaseerd op gegevens van De Hollandsche Molen (publiek domein)")
                    bron("Foto's", "Beeldbank RCE, CC-BY-SA; fotograaf staat bij elke foto")
                    bron("Wind", "KNMI Harmonie via Open-Meteo, CC-BY 4.0")
                    bron("Openingstijden", "© OpenStreetMap-bijdragers, ODbL")
                    bron("Kaarten", "Apple Kaarten")
                }

                Section {
                    Text("De windinformatie is een hulpmiddel. De molenaar beslist zelf of en hoe er gedraaid wordt.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Over")
            .task { await pot.laad() }
            .alert("Molenwind", isPresented: Binding(get: { pot.melding != nil }, set: { if !$0 { pot.melding = nil } })) {
                Button("OK") { pot.melding = nil }
            } message: {
                Text(pot.melding ?? "")
            }
        }
    }

    private func bron(_ k: LocalizedStringKey, _ v: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(k).font(.subheadline.bold())
            Text(v).font(.caption).foregroundStyle(.secondary)
        }
    }
}

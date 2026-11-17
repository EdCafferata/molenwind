# Molenwind — App Store-indiening v1.0

Voorbereid op 17 nov 2026. Alles wat lokaal kon, staat klaar. De stappen in ASC moeten nog gebeuren,
want daarvoor is Eds akkoord nodig.

## ✅ Klaar (in deze repo)
- **App:** versie 1.0 (`MARKETING_VERSION`), `ITSAppUsesNonExemptEncryption = NO` (geen exportvragen),
  privacymanifest `ios/Molenwind/PrivacyInfo.xcprivacy` (geen tracking, geen verzamelde data, UserDefaults CA92.1).
  De Release-build compileert.
- **Bronvermelding:** OpenStreetMap (ODbL) toegevoegd onder Over → Bronnen, naast RCE, Open-Meteo (CC-BY 4.0)
  en Apple Kaarten.
- **Metadata** `fastlane/metadata/` in 5 talen (nl-NL primair, en-US, de-DE, fr-FR, es-ES): naam, ondertitel,
  beschrijving, trefwoorden, promotietekst, release notes en URL's (marketing/support/privacy per taal).
  Categorie Weer, met Reizen als tweede categorie. Copyright: "2026 The IT Crowd".
  Review-info: geen login nodig, met een tip voor de reviewer.
- **Screenshots** `fastlane/screenshots/<taal>/`: 4 per taal, 6,9" (1320×2868, iPhone 17 Pro Max), status bar 9:41.
  Mijn molen, kaart, molenpagina en molenkiezer. Het "Over"-scherm is bewust weggelaten (fooien tonen nu nog "binnenkort").
- **fastlane** `fastlane/Fastfile`: lanes `beta` (build + TestFlight) en `metadata` (metadata + screenshots,
  niet indienen). De sleutels blijven lokaal in `~/.appstoreconnect/private_keys/` en staan niet in deze repo.
- **Open-Meteo:** het gratis plan staat een fooienpot expliciet toe ("Voluntary donations, including contributions
  through a tip jar, are permitted"). Abonnementen of advertenties zouden commercieel gebruik zijn.

**Bundle-ID geregistreerd** (17 nov, API, resource `FMU4HA4MDD`). Het app-record lukte nog niet, omdat ASC die avond storingen gaf.

## ⏳ Nog te doen, in deze volgorde (Eds akkoord per stap)
1. **App-record aanmaken in ASC:** naam "Molenwind" (controleren of de naam vrij is), primaire taal Nederlands,
   bundle `info.cafferata.molenwind`, SKU `molenwind`. Daarna `APP_ID` invullen in
   `oc-consent/site-info/generators/gen_molenwind.py`, de site opnieuw genereren en deployen.
2. **4 fooi-IAP's aanmaken** (consumable): `info.cafferata.molenwind.fooi.koffie`, `.meel`, `.zeil`, `.molensteen`,
   elk met prijs, lokalisatie (5 talen) en een **review-screenshot** van het Over-scherm. Ze moeten **samen met
   versie 1.0** worden ingediend. Bij Alltrexx ging dat mis (409 "no pending version"), omdat de IAP's
   apart werden ingediend.
3. **China-compliance (nieuw sinds 16 nov 2026):** ASC vraagt bij indiening voor China mainland twee
   verklaringen: AI-gegenereerde content en Security Assessment. Molenwind heeft geen van beide → beide op **"No"**
   (een leeg formulier blokkeert de indiening).
4. **App Privacy:** "Data Not Collected". **Leeftijdsclassificatie:** overal "geen", dus 4+.
   **Prijs:** gratis, alle landen (of alleen NL/BE/DE/FR/ES/VK/VS, naar keuze).
5. `fastlane beta`: eerste build naar TestFlight. Op Eds iPhone testen of de meldingen echt aankomen (dat is nog niet getest)
   en of de fooien laden.
6. `fastlane metadata`: metadata en screenshots naar ASC.
7. **Pre-productie-check** draaien (`pre-production-app-review-check`), dan de build en de IAP's koppelen aan
   versie 1.0 → **Indienen** (handmatig vrijgeven na goedkeuring).
8. Na livegang: de kaart op cafferata.info van "Onderweg" naar "Live" verplaatsen, met een App Store-link. Ook de README-status bijwerken.

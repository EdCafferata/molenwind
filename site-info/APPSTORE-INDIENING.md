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

**Bundle-ID geregistreerd** (17 nov, API, resource `FMU4HA4MDD`).

**✅ Stap 1 klaar (17 nov 2026, ~22:30):** app-record "Molenwind" aangemaakt in ASC, **Apple App ID `6836030027`**
(nl-NL, SKU `molenwind`, alle gebruikers hebben toegang). `APP_ID` staat in `gen_molenwind.py`, site opnieuw gedeployd.

**✅ Stap 2 klaar (17 nov 2026):** 4 consumable fooi-IAP's aangemaakt via de API, elk met prijs (basis NLD,
overige landen automatisch), beschikbaar in alle 175 landen + nieuwe landen, en lokalisaties nl-NL/en-US/de-DE/fr-FR/es-ES:
koffie € 0,99 (`6836030846`), meel € 2,99 (`6836030776`), zeil € 4,99 (`6836031153`), molensteen € 9,99 (`6836031368`).
ES-beschrijving van zeil ingekort tot 45 tekens: "Para que las aspas cojan todo el viento."
Review-screenshot: het Over-scherm met prijzen van Eds iPhone (sandbox), geschaald naar 1290×2796, want ASC weigert
1284×2778 met IMAGE_INCORRECT_DIMENSIONS. Alle 4 staan op **READY_TO_SUBMIT**. Indienen samen met versie 1.0.

## ⏳ Nog te doen, in deze volgorde (Eds akkoord per stap)
1. ~~**App-record aanmaken in ASC:**~~ ✅ klaar (App ID 6836030027). naam "Molenwind" (controleren of de naam vrij is), primaire taal Nederlands,
   bundle `info.cafferata.molenwind`, SKU `molenwind`. Daarna `APP_ID` invullen in
   `oc-consent/site-info/generators/gen_molenwind.py`, de site opnieuw genereren en deployen.
2. ✅ **4 fooi-IAP's aanmaken** (klaar, READY_TO_SUBMIT) (consumable): `info.cafferata.molenwind.fooi.koffie`, `.meel`, `.zeil`, `.molensteen`,
   elk met prijs, lokalisatie (5 talen) en een **review-screenshot** van het Over-scherm. Ze moeten **samen met
   versie 1.0** worden ingediend. Bij Alltrexx ging dat mis (409 "no pending version"), omdat de IAP's
   apart werden ingediend.
3. **China-compliance (nieuw sinds 16 nov 2026):** ASC vraagt bij indiening voor China mainland twee
   verklaringen: AI-gegenereerde content en Security Assessment. Molenwind heeft geen van beide → beide op **"No"**
   (een leeg formulier blokkeert de indiening).
4. ✅ (17 nov: App Privacy gepubliceerd door Ed; leeftijd alles "geen"; gratis in alle 175 landen; content rights = gebruikt content van derden (RCE-foto's, OSM); handmatig vrijgeven) **App Privacy:** "Data Not Collected". **Leeftijdsclassificatie:** overal "geen", dus 4+.
   **Prijs:** gratis, alle landen (of alleen NL/BE/DE/FR/ES/VK/VS, naar keuze).
5. 🟡 (17 nov 23:28: build 202611172327 geüpload, VALID in ASC; testen op Eds iPhone nog open) `fastlane beta`: eerste build naar TestFlight. Op Eds iPhone testen of de meldingen echt aankomen (dat is nog niet getest)
   en of de fooien laden.
6. ✅ (17 nov 23:14, 57 velden + 20 screenshots geverifieerd via API; review-contact incl. telefoon staat in ASC, telefoon bewust niet in deze openbare repo) `fastlane metadata`: metadata en screenshots naar ASC.
7. **Pre-productie-check** draaien (`pre-production-app-review-check`), dan de build en de IAP's koppelen aan
   versie 1.0 → **Indienen** (handmatig vrijgeven na goedkeuring).
8. Na livegang: de kaart op cafferata.info van "Onderweg" naar "Live" verplaatsen, met een App Store-link. Ook de README-status bijwerken.

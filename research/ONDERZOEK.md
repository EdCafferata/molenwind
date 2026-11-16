# Molen-app — verkennend onderzoek

_16 november 2026 · lokaal project, nog geen repo · alles in deze map blijft lokaal_

## Uitgangspunten (Ed, 16 nov 2026)
- **Open app, open source (later een openbare GitHub-repo).** Geen verdienmodel in v1. Misschien later een
  betaalfunctie, als toeristen de app veel gaan gebruiken.
- **Validatie:** Ed sprak een molenaar, die zei dat **wind het allerbelangrijkste is**. Daar komt het idee vandaan.
  → De molenaarsstand draait in v1 om wind, alles daaromheen is bijzaak.
- **Voor toeristen zijn openingstijden het handigst** (zie §4b).

## TL;DR
**Ja, dit is leuk, en er zit echt een gat in de markt.**
- **Voor toeristen** bestaan er alleen gedateerde apps (WindMills, sinds 2010, € 0,99, zonder reviews) of apps
  voor één plek (Kinderdijk, Zaanse Schans-audiotours).
- **Voor molenaars** bestaat geen enkele app. Ze gebruiken algemene windapps (Windfinder, WindAlert, Weer & Radar).
- Een app die **beide werelden combineert**, met **lokale wind voor precies jouw molen**, is uniek.
- **Belangrijkste databron werkt al:** de molenlijst van de Rijksdienst voor het Cultureel Erfgoed (RCE).
  1.872 molens met naam, type, functie, bouwjaar, foto en monumentnummer. Gratis op te halen, al getest
  (`rce_molens.geojson` in deze map).
- **Windvoorspelling per molen** werkt ook: het KNMI Harmonie-model (2 km) via Open-Meteo, getest op een molen bij
  Tienhoven.

---

## 1. Concurrentie

| App | Wat | Zwakte |
|---|---|---|
| **WindMills / WindMolens** (McWood, Menno Mennes) | Molengids met filmpjes, molens in de buurt, filter op type, "open voor publiek", "maalvaardig". € 0,99, 6 talen. | Concept uit 2010; te weinig ratings om te tonen; geen weer of wind; niets voor molenaars. |
| **Kinderdijk UNESCO Official** / Bloomberg Connects | Officiële gids voor één locatie. | Alleen Kinderdijk. |
| **VoiceMap**-audiotours (Zaanse Schans, Kinderdijk) | Betaalde audiotour per locatie ($ 7,99–8,99). | Alleen één locatie, betaald per tour. |
| **Holland Digital Guides** | Algemene NL-gids (tulpen, molens, kaas). | Geen molendiepgang. |
| **Windfinder / WindAlert / Weer & Radar** | Wind- en weerapps. | Niet gemaakt voor molens: geen kruirichting, geen molenlocaties, geen molenaarsdrempels. |

**Geen** officiële app van De Hollandsche Molen gevonden, en **geen** app voor (vrijwillige) molenaars.

## 2. Doelgroepen
- **Toeristen (NL en buitenland):** de molen is hét Nederland-icoon. Zaanse Schans en Kinderdijk trekken grote
  aantallen bezoekers (exacte cijfers niet gevonden), en dan zijn er de ~1.100 andere bestaande windmolens die
  bijna niemand kent.
- **Molenaars:** veel vrijwilligers, gemiddeld ouder (de meesten 50+). In 2025 behaalden **110 nieuwe molenaars**
  hun getuigschrift, een record. Klein maar zeer betrokken publiek, goed bereikbaar via het Gilde van Vrijwillige
  Molenaars en De Hollandsche Molen. Mond-tot-mondreclame werkt hier sterk.
- **Molenliefhebbers / fotografen:** "molens verzamelen", Nationale Molendag (2e weekend van mei).

## 3. Wat ik zou bouwen
Werktitel: **"Molenwind"** (alternatieven: *Wiekslag*, *Kruien*; App Store-namen later checken).
Eén app met twee standen, gekozen bij de onboarding en later te wisselen, zoals de leeftijdsgroepen in Duski.

### 🧭 Stand "Ontdekken" (toerist)
- **Kaart met alle molens** (1.098 bestaande windmolens + water-, ros- en restantmolens als optionele laag).
  Filter op type (stellingmolen, grondzeiler, wipmolen…) en functie (koren, polder, industrie, zaag).
- **"Draait hij vandaag?"-indicatie.** Een molen kan alleen draaien bij ongeveer Bft 2–6 en als de molenaar er is.
  De app toont "goede draaidag" op basis van de windvoorspelling. Echt "nu open" kan alleen met data van molenaars
  (zie fase 2).
- **Molenpagina:** foto (RCE), bouwjaar, type, functie, rijksmonumentnummer, link naar allemolens.nl, route via
  Apple Maps.
- **Uitleg-laag:** wat betekenen de **molenstanden** (vreugde, rouw, rust/werk), wat is een blauwe wimpel ("de
  molenaar is er, kom binnen"), hoe werkt een poldermolen. Dat maakt de app voor buitenlanders interessanter dan
  een kaart alleen.
- Meertalig (de lokalisatie-ervaring van Duski hergebruiken), offline te gebruiken, geen account.
- Herinnering voor de **Nationale Molendag**; "molens verzameld"-lijstje.

### 🌬️ Stand "Molenaar"
- **Mijn molen:** kies je molen uit de lijst, dan staat alles op de exacte coördinaten.
- **Wind nu:** de dichtstbijzijnde KNMI-meting (per 10 minuten) plus het Harmonie-model op 2 km: snelheid in Bft
  en m/s, **richting als kompas**, en **stoten** apart.
- **Kruiadvies:** "wind uit WZW (256°), kap naar WZW kruien". Een **melding bij een windomslag** groter dan
  een instelbaar aantal graden: dat is precies het moment waarop een molenaar moet kruien.
- **Drempels met kleuren** die de molenaar zelf instelt, met standaardwaarden uit de Gilde-praktijk:
  - malen tot ~Bft 7;
  - boven ~Bft 5 niet in het wiekenvlak werken;
  - bij (dreigend) onweer de zeilen eraf.
  Duidelijk als **hulpmiddel, geen veiligheidsadvies**. De molenaar beslist zelf.
- **Zeilvoering-hint per windkracht** (vol zeil / half / zonder), instelbaar per molen, want dat verschilt per molen
  en wiekvoering.
- **KNMI-waarschuwingen en onweer in de buurt** als melding.
- **Draaiurenlogboek:** start/stop met één tik, met de wind van dat moment er automatisch bij. Export als CSV/PDF.
  Nog verifiëren: veel molens houden een molenboek bij, maar wat daarin moet en of het voor subsidie/verzekering
  telt, moet ik nog uitzoeken.
- **Widget en Apple Watch-complicatie:** windrichting en kracht voor "mijn molen" in één oogopslag.
- Groot lettertype, weinig knoppen (doelgroep 50+).

### Fase 2 (de echte "killer"), alleen met medewerking van molenaars
- **"Ik draai nu"-knop** voor molenaars, waarmee de molen live op de toeristenkaart verschijnt ("deze molen draait nu
  en is open"). Dat bestaat nergens, en het verbindt de twee doelgroepen. Er is dan wel een kleine backend nodig
  (bijvoorbeeld op de NAS, zoals bij alltrexx).

## 4. Databronnen

| Bron | Wat | Licentie / voorwaarden | Status |
|---|---|---|---|
| **RCE Landschapsatlas – WFS-laag `Molens`** (`services.rce.geovoorziening.nl/landschapsatlas/wfs`) | 1.872 molens: NAAM, PLAATS, CATEGORIE, FUNCTIE, TYPE, STAAT, BOUWJAAR, RMONNUMMER, TBGCNUMMER (Ten Bruggencate), INFOLINK (allemolens.nl), FOTO + fotograaf. Kan direct in WGS84. | Volgens data.overheid.nl **publiek domein**; gebaseerd op de gegevens van Vereniging De Hollandsche Molen. | ✅ **Getest**, volledig gedownload (`rce_molens.geojson`). |
| **RCE-beeldbank** (foto-URL's in dezelfde dataset) | Eén foto per molen, met de fotograaf erbij. | Grotendeels **CC-BY-SA 3.0 NL**: naamsvermelding en link naar de licentie verplicht. Per foto checken. | Te verifiëren per foto. |
| **Extra RCE-lagen** | `verdwenenmolens`, `weidemolens_en_windmotoren`, `drgmk_molens_gemalen`. | Idem. | Gevonden, nog niet bekeken. |
| **allemolens.nl / Molendatabase** | Uitgebreide molenpagina's (openingstijden, molenaar, historie). | **Geen open API**, inhoud is eigendom van de maker. Alleen **doorlinken** (de dataset geeft de link al), niet scrapen. Voor openingstijden: samenwerking vragen aan De Hollandsche Molen. | Doorlink ✅ |
| **Wikidata** | Koppelt molens via *Nederlandse Molendatabase ID* (P2863) en *Hollandsche Molen ID* (P2866) aan Wikipedia-artikelen in vele talen. | CC0. | Handig voor meertalige beschrijvingen. |
| **OpenStreetMap** | `man_made=windmill`, soms met `opening_hours`, `website`, `ref:tenbruggencate`. | ODbL: naamsvermelding, share-alike op de database. | Overpass-servers zaten vol tijdens de test; later opnieuw proberen. |
| **KNMI Data Platform** | **10-minutenwaarnemingen** (wind, richting, stoten) van alle KNMI-stations; Harmonie-modeldata. Gratis API-sleutel. | Meeste datasets **CC-BY 4.0** (één synoptische set staat als "onbekend"; per dataset checken). 10-min-data blijft maar 24 uur beschikbaar. | Nog niet getest (API-sleutel nodig). |
| **Open-Meteo, model `knmi_seamless`** | Uurlijkse voorspelling uit KNMI Harmonie op **2 km** voor elke coördinaat: windsnelheid, richting, stoten. | Data CC-BY 4.0, maar de **gratis API is alleen niet-commercieel**. Voor een app in de store: betaald abonnement of zelf hosten (AGPL). | ✅ **Getest** op een molen bij Tienhoven. |
| **Apple WeatherKit** | Voorspelling en actuele omstandigheden, ook wind en stoten. | **500.000 calls/maand inbegrepen** bij het Developer Program; daarna vanaf $ 49,99/mnd. Apple-attributie verplicht. | Makkelijkste route op iOS; minder "KNMI-lokaal". |
| **KNMI-waarschuwingen** | Code geel/oranje/rood. Wordt **lokaler** (niet meer per provincie). | Via het KNMI Data Platform; dataset nog te vinden. | Uitzoeken. |
| ~~Buienradar~~ | | Alleen niet-commercieel → **niet gebruiken**. | ✗ |

**Voorgestelde weer-architectuur (aangepast op open source):**
- **v1: Open-Meteo `knmi_seamless`, direct vanaf de telefoon.** Geen API-sleutel nodig, dus niets geheims in een
  openbare repo, en wel het KNMI Harmonie-model op 2 km. De gratis API is bedoeld voor niet-commercieel gebruik
  (< 10.000 calls/dag, 5.000/uur, 600/min). Een gratis open-source-app valt daar zeer waarschijnlijk onder; volgens
  secundaire bronnen noemt Open-Meteo "open-source developers" zelfs expliciet. **Vóór de release even per mail
  bevestigen bij Open-Meteo**, en dat zeker opnieuw doen als er ooit een betaalfunctie komt. Naamsvermelding (CC-BY 4.0)
  in de app.
- **Later: actuele KNMI-metingen (10 minuten).** Daarvoor is een KNMI-sleutel nodig, en die hoort niet in een open
  repo. Oplossing: een mini-cache op de NAS die elke 10 minuten één keer alle stations ophaalt en als klein JSON
  aanbiedt. De app heeft dan geen sleutel nodig.
- **WeatherKit** blijft een optie, maar die hangt aan Eds Apple-account en is alleen iOS. Voor een open app die later
  ook naar Android gaat, is Open-Meteo de logischere basis.

### 4b. Openingstijden (voor toeristen)
Er is **geen open, landelijke bron** met openingstijden van molens. Wat er wel is:
| Optie | Hoe | Oordeel |
|---|---|---|
| **OpenStreetMap `opening_hours`** | Veel molens hebben in OSM al openingstijden (ODbL). Een open app kan die tonen **én** gebruikers/molenaars laten verbeteren in OSM. | ✅ **Beste basis voor een open app.** Dekking nog meten (Overpass zat vol). |
| **Molenaar vult zelf in, in de app** | De molenaar kiest "mijn molen" (heeft die toch al voor de wind) en zet vaste tijden plus een **"ik ben er nu"-knop** (de digitale blauwe wimpel). | ✅ Perfecte koppeling tussen de twee doelgroepen. Wel een kleine backend nodig (NAS), of het via OSM laten lopen. |
| **allemolens.nl / molendatabase.nl** | Hebben vaak bezoekinfo per molen. | Alleen **doorlinken** (de RCE-dataset bevat de link al). Overnemen kan alleen met toestemming van De Hollandsche Molen. |
| **Nationale Molendag** (2e weekend mei) | De deelnemende molens worden jaarlijks gepubliceerd. | Leuke jaarlijkse functie; de bron per jaar checken. |
| **"Goede draaidag"-indicatie** | Op basis van de windvoorspelling (± Bft 2–6). | ✅ Altijd beschikbaar, als aanvulling ("open + wind = hij draait waarschijnlijk"). |

**Voorstel:** v1 toont OSM-openingstijden + de draaidag-indicatie + een link naar allemolens.nl. v2 voegt de
molenaarsknop "ik ben er nu" toe.

## 5. Techniek (v1)
- SwiftUI + MapKit, iOS eerst (net als Duski en Riskonacci); Android later, met de Kotlin/Compose-ervaring.
- De molenlijst als **gebundelde GeoJSON** (< 1 MB), elke maand ververst via een app-update of een download.
  Volledig offline te gebruiken.
- Geen account, geen tracking: hetzelfde privacy-verhaal als de andere apps.
- Widgets en Watch-app als tweede stap.

## 6. Open source in plaats van een verdienmodel (besluit Ed)
- **Alles gratis**, geen Premium in v1. Misschien later een betaalfunctie voor toeristen, als het gebruik daar
  aanleiding toe geeft. Molenaarsfuncties blijven altijd gratis.
- **Codelicentie: MIT of Apache-2.0**, géén GPL. GPL botst met de App Store-voorwaarden (bekend probleem; de FSF heeft
  apps om die reden uit de store laten halen). Apache-2.0 geeft ook octrooibescherming, MIT is de eenvoudigste.
- **Data in de repo:**
  - RCE-molenlijst: publiek domein, mag mee in de repo.
  - Foto's (CC-BY-SA): **niet** in de repo of app bundelen, maar via de RCE-URL laden met naamsvermelding.
  - OSM-data (ODbL): naamsvermelding "© OpenStreetMap-bijdragers".
- **Geen geheimen in de repo:** daarom in v1 Open-Meteo zonder sleutel. Een KNMI-sleutel komt alleen op de NAS (zie §4).
- **Bijdragers:** molenaars en liefhebbers kunnen openingstijden en correcties via OSM aanleveren. Dat past goed bij
  een open project.

## 7. Risico's / open vragen
- **Kleine niche**: rond de 1.100 bestaande windmolens; het toeristendeel moet het volume brengen.
- **Veiligheid/aansprakelijkheid**: windgrenzen alleen als instelbaar hulpmiddel, met een duidelijke disclaimer.
- **Datalicenties**: foto's CC-BY-SA (naamsvermelding), allemolens.nl alleen doorlinken, Open-Meteo niet gratis
  commercieel.
- **Validatie**: eerste molenaar gesproken door Ed, die zei dat **wind het belangrijkste is**. Verder valideren met
  het prototype in de hand (een windkompas voor zijn of haar molen laten zien). Contact met het Gilde of De
  Hollandsche Molen is jouw keuze, ik heb niemand benaderd.
- **Open-Meteo bij open source**: niet-commercieel gebruik vóór de release per mail laten bevestigen.

## 8. Volgende stappen (voorstel)
1. **Prototype, lokaal (wind eerst):** windkompas, windkracht en stoten voor "mijn molen", plus een melding bij een
   windomslag. Daarna de kaart met de RCE-data en de molenpagina. SwiftUI + Open-Meteo, geen sleutel.
2. Prototype laten zien aan de molenaar met wie Ed sprak.
3. OSM-dekking van openingstijden meten (Overpass) en tonen in de molenpagina.
4. Naam kiezen en checken in de App Store.
5. Openbare GitHub-repo (MIT/Apache-2.0) aanmaken als Ed daarvoor kiest. Tot dan blijft alles lokaal.

---

## Bronnen
- RCE-molendataset op data.overheid.nl ("molens", publiek domein, WFS): <https://data.overheid.nl/dataset/11586-molens>
  (gaf bij het ophalen een 404; licentie volgens de zoekindex. Vóór publicatie opnieuw checken); verwant:
  <https://data.overheid.nl/dataset/77644-traditionele-windmolens>
- WindMills / WindMolens (App Store): <https://apps.apple.com/nl/app/windmills/id373957859>,
  <https://apps.apple.com/nl/app/windmolens/id6746329394>
- iCulture over WindMills: <https://www.iculture.nl/apps/windmills-brengt-nederlandse-molens-op-de-iphone-in-beeld/>
- Kinderdijk-app: <https://apps.apple.com/us/app/id1343241236>, <https://kinderdijk.com/to-do-in-kinderdijk/app>
- VoiceMap Zaanse Schans: <https://www.voicemap.me/tour/zaandam/zaanse-schans-a-guide-to-windmills-crafts-and-charming-history>
- Holland Digital Guides: <https://apps.apple.com/app/hollanddigitalguides/id1473091137>
- WindAlert: <https://apps.apple.com/nl/app/windalert-wind-weather-map/id317992025>
- Wikidata-properties P2863/P2866: <https://citygraph.abudhabi.nyu.edu/wiki/Property:P2863>,
  <https://citygraph.abudhabi.nyu.edu/wiki/Property:P2866>
- OSM-tag Ten Bruggencate: <https://wiki.openstreetmap.org/wiki/Key:ref:tenbruggencate>
- KNMI Data Platform / EDR-API: <https://developer.dataplatform.knmi.nl/edr-api>; 10-min-data:
  <https://data.overheid.nl/dataset/46407-meteo-data---actual-synoptic-observations-knmi-the-netherlands-per-10-minutes>
- Open-Meteo-voorwaarden en KNMI-model: <https://open-meteo.com/en/terms>, <https://open-meteo.com/en/pricing>,
  <https://open-meteo.com/en/docs/knmi-api>
- Apple WeatherKit: <https://developer.apple.com/weatherkit/get-started/>
- Gilde-bestuursverslag (windkracht 7-praktijk):
  <https://vrijwilligemolenaars.nl/f/files/download/vereniging/bestuur/bestuursvergaderingsverslagen/2020/20200922_bestuursvergadering_verslag.pdf>
- Monumentenwacht-molenbrochure (onweer, Bft 5):
  <https://vrijwilligemolenaars.nl/f/files/download/veiligheid/molenbrochure_monumentenwacht.pdf>
- Recordaantal nieuwe molenaars: <https://nieuws.nl/algemeen/recordaantal-nieuwe-molenaars-erbij-hard-nodig>
- Molenaars 50+: <https://www.nhnieuws.nl/nieuws/302405/molenaars-hopen-met-record-op-vers-bloed-meesten-zijn-ouder-dan-50-jaar>
- RCE-beeldbank-licentie (Commons): <https://download.osmand.net/wiki/Commons:Rijksdienst_voor_het_Cultureel_Erfgoed>
- KNMI-waarschuwingen (vernieuwing): <https://www.knmi.nl/kennis-en-datacentrum/uitleg/vernieuwing-knmi-waarschuwingen>

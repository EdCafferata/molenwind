# Site-info — Molenwind

Alle info die voor Molenwind **via een URL** wordt verstrekt (store-listing, support/privacy/marketing),
op één plek en versiebeheerd. Conventie voor alle EdCafferata-app-repo's (map `site-info/`).

## App-identiteit
| | |
|---|---|
| Naam | Molenwind |
| Bundle-ID | `info.cafferata.molenwind` |
| Apple App ID | _nog niet aangemaakt_ |
| Team | 9J2S23WJH3 (The IT Crowd) |
| Platform | iPhone (iOS 18+), portret |
| Prijs | Gratis; 4 vrijwillige fooi-IAP's (`info.cafferata.molenwind.fooi.{koffie,meel,zeil,molensteen}`, nog aan te maken in ASC) |
| Talen | NL, EN, DE, FR, ES |
| Licentie | MIT (open source, github.com/EdCafferata/molenwind) |

## URL's voor App Store Connect
| Veld | URL |
|---|---|
| Marketing-URL | https://cafferata.info/molenwind/ |
| Support-URL | https://cafferata.info/molenwind/support.html |
| Privacybeleid-URL | https://cafferata.info/molenwind/privacy.html |
| Gebruiksvoorwaarden (EULA) | https://cafferata.info/molenwind/voorwaarden.html (of Apple's standaard-EULA) |

Anderstalige versies: voeg `en/`, `de/`, `fr/` of `es/` toe (bijv. `…/molenwind/en/privacy.html`) en vul die
per locale in ASC in.

## App Privacy (ASC-vragenlijst) — basis voor de antwoorden
- **Geen gegevens verzameld** ("Data Not Collected"): geen account, geen analytics, geen trackers, geen eigen server.
- Locatie (When In Use) wordt alleen **op het toestel** gebruikt om molens in de buurt te tonen; wordt niet verstuurd.
- Open-Meteo krijgt alleen de coördinaten van de **gekozen molen**; foto's van images.memorix.nl (RCE); kaarten via Apple.
- Fooien via Apple IAP; wij ontvangen geen betaal- of persoonsgegevens.

## De 4 pagina's (5 talen: NL root + en/ de/ fr/ es/)
`index.html` (marketing), `support.html`, `privacy.html`, `voorwaarden.html`.

**LIVE** op https://cafferata.info/molenwind/ sinds 17 nov 2026 (NAS-webroot `/Volumes/web/molenwind/`,
gedeelde IT Crowd-stijl `cafferata.info/assets/style.css`). NL is juridisch leidend; DE/FR/ES zijn vertalingen.

## Onderhoud
Gegenereerd met `oc-consent/site-info/generators/gen_molenwind.py`. Zodra de app een Apple App ID heeft:
zet `APP_ID` in dat script, draai het opnieuw (vervangt "Binnenkort in de App Store" door een App Store-knop)
en deploy opnieuw naar `/Volumes/web/molenwind/`. Bij elke store-indiening deze pagina's nalopen.

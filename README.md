# KIL-kalender

Aktivitetskalender for infoskjerm (TV) til **Kvitsøy Idrettslag**.

Siden henter arrangementer automatisk fra RSS-feeden til [friskus.com](https://friskus.com)
og viser dem i en TV-vennlig kalendervisning:

- **Ukesvisning** – de neste 7 dagene med alle aktiviteter (dagens dag er markert)
- **Kommende arrangementer** – sidepanel med enkeltarrangementer (kamper, tilstelninger) med bilde
- **Klokke og dato** i toppen
- Faste treninger (gjentakende serier i feeden) ekspanderes automatisk til ukentlige oppføringer
- Turkise oppføringer = faste aktiviteter, gule = enkeltarrangement
- Ferdige aktiviteter dimmes utover dagen

## Automatisk oppdatering

Alt skjer i nettleseren – ingen server eller database trengs:

- RSS-feeden hentes på nytt **hvert 10. minutt**, så endringer i Friskus dukker opp av seg selv
- Kalenderen ruller automatisk videre ved midnatt
- Siden laster seg selv helt på nytt hver 12. time (plukker opp nye versjoner av selve siden)
- Ved nettverksfeil vises sist lagrede data (mellomlagret i nettleseren) og en rød statusprikk nederst

## Oppsett (én gang)

1. Slå sammen denne branchen til `main`.
2. Gå til **Settings → Pages** i GitHub-repoet og sett **Source** til **GitHub Actions**.
3. Ved neste push til `main` publiserer workflowen siden automatisk til:

   `https://heskja.github.io/KIL-kalender/`

## Oppsett på TV-skjermen

Åpne adressen over i en nettleser i fullskjerm. Noen alternativer:

- **Smart-TV**: åpne adressen i TV-ens innebygde nettleser
- **PC/Mini-PC koblet til TV**: start Chrome i kioskmodus:
  `chrome --kiosk --noerrdialogs --disable-session-crashed-bubble https://heskja.github.io/KIL-kalender/`
- **Raspberry Pi**: bruk Chromium i kioskmodus ved oppstart, eller et ferdig verktøy som FullPageOS
- **Google TV / Chromecast / Android-TV**: bruk en kiosk-app (f.eks. «Fully Kiosk Browser») og pek den til adressen

Siden er laget for å stå på døgnet rundt uten tilsyn og skalerer skriften etter skjermstørrelsen (også 4K).

## Innstillinger

Øverst i `<script>`-blokken i [`index.html`](index.html) ligger et `CONFIG`-objekt:

| Innstilling | Standard | Beskrivelse |
|---|---|---|
| `FEED_URL` | Friskus-feed for Kvitsøy | RSS-kilden |
| `ORGANIZER` | `KVITSØY IDRETTSLAG` | Vis kun denne arrangøren (tom streng = alle) |
| `REFRESH_MINUTES` | 10 | Hvor ofte feeden hentes |
| `DAYS_TO_SHOW` | 7 | Antall dagkolonner |
| `HIGHLIGHT_DAYS` | 90 | Hvor langt frem sidepanelet ser |

I tillegg støttes URL-parametere, uten å endre koden:

- `?alle=1` – vis alle arrangører på Kvitsøy (ikke bare idrettslaget)
- `?dager=5` – vis et annet antall dagkolonner (1–14)

Eksempel: `https://heskja.github.io/KIL-kalender/?alle=1&dager=5`

# KIL-kalender

Aktivitetskalender for infoskjerm (TV) til **Kvitsøy Idrettslag**.

Siden henter arrangementer automatisk fra RSS-feeden til [friskus.com](https://friskus.com)
og viser dem i en TV-vennlig kalendervisning:

- **Rullerende ukesvisning** – dagens dag først, deretter de neste dagene (standard 7 dager, styres med `?dager=N`)
- **Kommende arrangementer** – sidepanel med enkeltarrangementer (kamper, tilstelninger) med bilde
- **Klokke og dato** i toppen
- Faste treninger (gjentakende serier i feeden) ekspanderes automatisk til ukentlige oppføringer
- Ferdige aktiviteter dimmes utover dagen

Designet følger klubbens profil fra [kvitsoyil.no](https://kvitsoyil.no): KIL-logoen og
klubbens blåfarger (`#0054a6`, `#1174ba`, logoblå `#0007e6`). Standardtemaet er mørkt
(mørk marineblå bakgrunn med lys tekst og stor skrift) – laget for TV-skjerm i lobby med
lesbarhet på ca. 5 meters avstand, uten å blende i dempet belysning. Et lyst tema som
ligner klubbens nettside er tilgjengelig med `?tema=lys`. Faste aktiviteter vises med
lyseblå kant; enkeltarrangement som hvite felt (mørkeblå i lyst tema) så de skiller seg ut.

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
- **Raspberry Pi**: bruk det medfølgende skriptet – se under
- **Google TV / Chromecast / Android-TV**: bruk en kiosk-app (f.eks. «Fully Kiosk Browser») og pek den til adressen

Siden er laget for å stå på døgnet rundt uten tilsyn og skalerer skriften etter skjermstørrelsen (også 4K).

### Raspberry Pi som infoskjerm

Koble en Raspberry Pi (med Raspberry Pi OS **med skrivebord**) til TV-en og kjør, som
den vanlige skrivebordsbrukeren:

```bash
curl -fsSL https://raw.githubusercontent.com/heskja/KIL-kalender/main/raspberry-pi/install-kiosk.sh -o install-kiosk.sh
bash install-kiosk.sh
sudo reboot
```

Skriptet [`raspberry-pi/install-kiosk.sh`](raspberry-pi/install-kiosk.sh):

- lager et oppstartsskript som venter på nettverk og starter Chromium i kioskmodus (fullskjerm, uten feildialoger) mot kalender-URL-en
- registrerer det for autostart ved innlogging – støtter både nye Raspberry Pi OS-versjoner (Wayland: labwc/wayfire) og eldre (X11/LXDE)
- slår av skjermsparing/blanking via `raspi-config`

Vil du vise en annen adresse (f.eks. med `?alle=1`), oppgi den som argument:
`bash install-kiosk.sh "https://heskja.github.io/KIL-kalender/?alle=1"`

For å avslutte kioskmodus på skjermen: trykk `Alt+F4` (med tastatur tilkoblet).

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

- `?dager=N` – antall dagkolonner i den rullerende visningen (1–14, standard 7)
- `?skala=N` – gang opp/ned all tekst og luft (0.5–3, standard 1; f.eks. `?skala=1.3`)
- `?tema=lys` – lyst tema (standard er mørkt, beregnet på TV)
- `?alle=1` – vis alle arrangører på Kvitsøy (ikke bare idrettslaget)

Eksempel: `https://heskja.github.io/KIL-kalender/?dager=5&skala=1.2`

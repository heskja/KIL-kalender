#!/usr/bin/env bash
#
# Setter opp en Raspberry Pi som infoskjerm for KIL-kalenderen:
# starter Chromium i fullskjerm (kiosk) mot kalender-URL-en ved hver oppstart
# og slår av skjermsparing/blanking.
#
# Kjøres som den vanlige skrivebordsbrukeren (typisk "pi"):
#   bash install-kiosk.sh [URL]
#
# Støtter Raspberry Pi OS med labwc (Bookworm 2024+), wayfire (Bookworm)
# og X11/LXDE (Bullseye og eldre).

set -euo pipefail

URL="${1:-https://heskja.github.io/KIL-kalender/}"
LAUNCHER="$HOME/.local/bin/kil-kiosk.sh"

if [ "$(id -u)" -eq 0 ]; then
  echo "Ikke kjør som root/sudo – kjør som skrivebordsbrukeren." >&2
  exit 1
fi

BROWSER="$(command -v chromium-browser || command -v chromium || true)"
if [ -z "$BROWSER" ]; then
  echo "Fant ikke Chromium. Installer med: sudo apt install chromium-browser" >&2
  exit 1
fi

# ---------- Oppstartsskript ----------
mkdir -p "$(dirname "$LAUNCHER")"
cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
# Startes automatisk ved innlogging – åpner KIL-kalenderen i kioskmodus.

# Hindre dobbeltstart hvis flere autostart-mekanismer er aktive
exec 9>"\$HOME/.kil-kiosk.lock"
flock -n 9 || exit 0

URL="$URL"

# Vent på nettverk (maks 90 sek) slik at første sidelasting lykkes
for _ in \$(seq 1 30); do
  curl -fsm 3 "\$URL" >/dev/null 2>&1 && break
  sleep 3
done

exec "$BROWSER" \\
  --kiosk \\
  --noerrdialogs \\
  --disable-infobars \\
  --disable-session-crashed-bubble \\
  --disable-restore-session-state \\
  --check-for-update-interval=31536000 \\
  --password-store=basic \\
  --user-data-dir="\$HOME/.config/kil-kiosk" \\
  "\$URL"
EOF
chmod +x "$LAUNCHER"
echo "Skrev $LAUNCHER"

# ---------- Autostart ved innlogging ----------
configured=""

# labwc (Raspberry Pi OS Bookworm, standard fra høsten 2024)
if command -v labwc >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/labwc"
  touch "$HOME/.config/labwc/autostart"
  if ! grep -q "kil-kiosk.sh" "$HOME/.config/labwc/autostart"; then
    echo "$LAUNCHER &" >> "$HOME/.config/labwc/autostart"
  fi
  configured="labwc"
fi

# wayfire (Raspberry Pi OS Bookworm, tidlige utgaver)
if [ -f "$HOME/.config/wayfire.ini" ]; then
  if ! grep -q "kil-kiosk.sh" "$HOME/.config/wayfire.ini"; then
    printf '\n[autostart]\nkil_kalender = %s\n' "$LAUNCHER" >> "$HOME/.config/wayfire.ini"
  fi
  configured="${configured:+$configured, }wayfire"
fi

# X11/LXDE (Bullseye og eldre) + generell XDG-autostart
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/kil-kalender.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=KIL-kalender kiosk
Exec=$LAUNCHER
X-GNOME-Autostart-enabled=true
EOF
configured="${configured:+$configured, }XDG-autostart"

echo "Autostart satt opp via: $configured"

# ---------- Slå av skjermsparing/blanking ----------
if command -v raspi-config >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null || sudo -v; then
    sudo raspi-config nonint do_blanking 1 && echo "Skjermblanking er slått av."
  else
    echo "MERK: fikk ikke sudo – slå av skjermblanking manuelt:"
    echo "      sudo raspi-config  →  Display Options  →  Screen Blanking  →  No"
  fi
else
  echo "MERK: raspi-config ikke funnet – slå av skjermsparing manuelt for din distro."
fi

echo
echo "Ferdig! Start på nytt for å teste:  sudo reboot"
echo "URL som vises: $URL"

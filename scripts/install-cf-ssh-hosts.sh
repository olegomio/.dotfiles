#!/usr/bin/env bash
set -euo pipefail

echo "=== Cloudflare SSH Hosts Integration Installer ==="

if [[ $EUID -ne 0 ]]; then
  echo "❌ Bitte mit sudo oder als root ausführen."
  exit 1
fi

SCRIPT_PATH="/usr/local/sbin/cf-hosts-ssh-update"
ENV_DIR="/etc/cloudflare"
ENV_FILE="$ENV_DIR/hosts-updater.env"

SERVICE_FILE="/etc/systemd/system/cf-hosts-ssh-update.service"
TIMER_FILE="/etc/systemd/system/cf-hosts-ssh-update.timer"

echo "➡️ Installiere Script..."

install -m 0755 -o root -g root /dev/stdin "$SCRIPT_PATH" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/cloudflare/hosts-updater.env"
HOSTS_FILE="/etc/hosts"
LOCK_FILE="/run/cf-hosts-ssh-update.lock"

FQDN_DEFAULT="www.isarvalley.media"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi

: "${CF_API_TOKEN:?Missing CF_API_TOKEN}"
: "${CF_ZONE_ID:?Missing CF_ZONE_ID}"

FQDN="${FQDN:-$FQDN_DEFAULT}"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }; }

need_cmd curl
need_cmd jq

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  exit 0
fi

LOOKUP_JSON="$(curl -fsS -X GET \
  "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records?type=A&name=${FQDN}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json")"

SUCCESS="$(echo "$LOOKUP_JSON" | jq -r '.success')"

if [[ "$SUCCESS" != "true" ]]; then
  echo "Cloudflare API Error"
  exit 1
fi

ORIGIN_IP="$(echo "$LOOKUP_JSON" | jq -r '.result[0].content // empty')"

if [[ -z "$ORIGIN_IP" ]]; then
  echo "No IP found"
  exit 1
fi

BEGIN_MARKER="# BEGIN cf-hosts-ssh"
END_MARKER="# END cf-hosts-ssh"

DESIRED_LINE="${ORIGIN_IP} ${FQDN}"

if grep -q "$BEGIN_MARKER" "$HOSTS_FILE"; then
  sed -i "/$BEGIN_MARKER/,/$END_MARKER/c\\
$BEGIN_MARKER\\
$DESIRED_LINE\\
$END_MARKER" "$HOSTS_FILE"
else
  echo "" >> "$HOSTS_FILE"
  echo "$BEGIN_MARKER" >> "$HOSTS_FILE"
  echo "$DESIRED_LINE" >> "$HOSTS_FILE"
  echo "$END_MARKER" >> "$HOSTS_FILE"
fi

echo "Updated hosts → $DESIRED_LINE"
EOF

echo "➡️ Erstelle Cloudflare Config..."

install -d -m 0700 -o root -g root "$ENV_DIR"

install -m 0600 -o root -g root /dev/stdin "$ENV_FILE" <<'EOF'
CF_API_TOKEN="5Lei87-ds9DiQ7oS096riEKjAWoFIFGzDFAWfQZP"
CF_ZONE_ID="3fa698ef658f138041228fc90f05349e"
FQDN="www.isarvalley.media"
EOF

echo "➡️ Erstelle systemd Service..."

cat >"$SERVICE_FILE" <<EOF
[Unit]
Description=Update /etc/hosts for SSH via Cloudflare A-record
After=network-online.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

echo "➡️ Erstelle systemd Timer..."

cat >"$TIMER_FILE" <<EOF
[Unit]
Description=Run cf-hosts-ssh-update periodically

[Timer]
OnBootSec=30
OnUnitActiveSec=300
AccuracySec=30
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "➡️ Reload systemd..."

systemctl daemon-reload

echo "➡️ Enable Timer..."

systemctl enable --now cf-hosts-ssh-update.timer

echo "➡️ First run..."

systemctl start cf-hosts-ssh-update.service

echo "➡️ Status prüfen..."

systemctl status cf-hosts-ssh-update.timer --no-pager

echo ""
echo "✅ Installation abgeschlossen."
echo ""
echo "Jetzt kannst du SSH so nutzen:"
echo ""
echo "ssh gal@www.isarvalley.media -p20221"
echo ""

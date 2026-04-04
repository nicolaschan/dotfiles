{ pkgs, ... }:

let
  caltrainLogin = pkgs.writeShellScript "caltrain-wifi-login" ''
    # NetworkManager dispatcher passes:
    #   $1 = interface name
    #   $2 = action (up, down, connectivity-change, etc.)
    # CONNECTION_ID is set to the NM connection name.

    if [ "$2" != "up" ]; then
      exit 0
    fi

    if [ "$CONNECTION_ID" != "Caltrain_WiFi" ]; then
      exit 0
    fi

    # Wait a moment for DNS/routing to settle
    sleep 2

    logger -t caltrain-wifi "Connected to Caltrain_WiFi, attempting captive portal login..."

    NMCLI="${pkgs.networkmanager}/bin/nmcli"

    # Detect active VPN connections and bring them down
    active_vpns=$($NMCLI --terse --fields NAME,TYPE connection show --active | ${pkgs.gawk}/bin/awk -F: '$2 ~ /vpn|wireguard/ {print $1}')
    if [ -n "$active_vpns" ]; then
      logger -t caltrain-wifi "Disabling active VPNs: $active_vpns"
      echo "$active_vpns" | while read -r vpn; do
        $NMCLI connection down "$vpn" 2>&1 | logger -t caltrain-wifi
      done
      sleep 2
    fi

    ${pkgs.curl}/bin/curl 'https://caltrain.passengerwifi.com/en/authentication' \
      -X POST \
      -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0' \
      -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
      -H 'Accept-Language: en-US,en;q=0.9' \
      -H 'Accept-Encoding: gzip, deflate, br, zstd' \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -H 'Origin: https://caltrain.passengerwifi.com' \
      -H 'Connection: keep-alive' \
      -H 'Referer: https://caltrain.passengerwifi.com/en/authentication' \
      -H 'Cookie: XSRF-TOKEN=eyJpdiI6IkJEMzQyMElqeXo2REZmamRPMkdONHc9PSIsInZhbHVlIjoibmNyRzlKZmhNN1F2WXYvckxWSUZ5SksvYWIzQ3U1RExqRk5ZZ0Iyb3JEM28vL1Y5dy84Sm5VZ25iTmU3MXNTUEdoUk55dy93OGpNRmhiNm4zRFJSK3J4eHJEVitTOERtcHZSVmUyOWZEc2ticS9QdEZNS3k2SVVHeW16ZDV3RkYiLCJtYWMiOiI3ZDkwMTE1YTY5ZjMwM2M3OGUwMjk1MjMwNDJhZWQ2MmFiYTNmZWFkOWFmNGY4YTU4NDcyOTE3NGE0Y2MxY2UxIiwidGFnIjoiIn0%3D; nomad_portal=eyJpdiI6IjEzUE9QRTk1UU1adWgzT09IQ1Zqanc9PSIsInZhbHVlIjoiYk1taFRGOE14RTZTRU1ybWNndXA0dmZLU2U0amkwL0lkTWp2TGdVRWhnS01CS1J3dmdIb2ZUMFNjK0gwR0pEdUxnUmJYeWRseDNWWTZ5cHdoYmxGNlJPMFE4aVpOdmdqM1FHWXJlTXBGV2NiOG1aK2w0RnlNS254Rk5LNFhGM3YiLCJtYWMiOiIwZDc5OWVlZDMzOGFhNmIyODBhYmFhOGQzYTEwZTc0NjVhYmU0NmRjNzgzNTFlZDI1NjA2ZjQ3YTUxYjM1MmM4IiwidGFnIjoiIn0%3D' \
      -H 'Upgrade-Insecure-Requests: 1' \
      -H 'Sec-Fetch-Dest: document' \
      -H 'Sec-Fetch-Mode: navigate' \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-User: ?1' \
      -H 'Priority: u=0, i' \
      -H 'TE: trailers' \
      --data-raw '_token=9p63I4w7SgSYNLbltxkdtHJLNSqyD6tKZcZPsNkg&_ceid=2046&_token=9p63I4w7SgSYNLbltxkdtHJLNSqyD6tKZcZPsNkg&terms=1' \
      --max-time 10 \
      --silent \
      --output /dev/null \
      --write-out '%{http_code}'

    result=$?
    if [ $result -eq 0 ]; then
      logger -t caltrain-wifi "Captive portal login request sent successfully"
    else
      logger -t caltrain-wifi "Captive portal login request failed (curl exit: $result)"
    fi

    # Re-enable VPNs that were active before
    if [ -n "$active_vpns" ]; then
      logger -t caltrain-wifi "Re-enabling VPNs: $active_vpns"
      echo "$active_vpns" | while read -r vpn; do
        $NMCLI connection up "$vpn" 2>&1 | logger -t caltrain-wifi
      done
    fi
  '';
in
{
  networking.networkmanager.dispatcherScripts = [
    {
      source = caltrainLogin;
      type = "basic";
    }
  ];
}

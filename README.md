# pia-qbittorrent-dockerfile
´´´
Sets up headless qbittorrent in docker with:
  thrnz/docker-wireguard-pia
  nginx to route localhost:8090
  qbit-port-sync to autosync the open port to qbittorrent

  The vue folder is left there to show you where to put those files
  config/qBittorrent/qBittorrent.conf is a working verison but i dont recall what i changed or not

According to chatgpt we now have:
  ✅ WireGuard VPN with enforced routing
  ✅ Leakproof qBittorrent over VPN only
  ✅ Port forwarding auto-synced via sidecar
  ✅ qBittorrent port updated live via its API
  ✅ A watchdog that doesn’t cry over IPv6 or BusyBox
  
but i dont really trust that so please let me know if you make any fixes 😇

Change your pia creds and volumes in:
docker-compose.yml

    environment:
      - USER=p0000000
      - PASS=00000000


    volumes:
      - /home/username/qbittorrent/config:/config
      - /home/username/qbittorrent/vue:/vue
      - /mnt/drive/contents/downloads:/downloads
      - /mnt/drive/contents/incomplete:/incomplete
      - ./pia-shared:/pia-shared:ro
´´´
and your qbit-creds in update-qbit-port.sh
  
  QBIT_USER="admin"
  QBIT_PASS="adminadmin"

And that should be it 😎

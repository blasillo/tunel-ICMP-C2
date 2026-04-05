#!/bin/sh
set -e
SERVER_IP="${SERVER_IP:-172.21.0.10}"
ROUTER_IP="${ROUTER_IP:-172.22.0.1}"
 
echo "[*] Añadiendo ruta: ${SERVER_IP} via router ${ROUTER_IP}"
ip route add ${SERVER_IP}/32 via ${ROUTER_IP} || trueSERVER_IP="${SERVER_IP:-172.20.0.10}"

echo "[*] Conectando al servidor hans en $SERVER_IP ..."
echo "    El tunel asignara una IP en el rango 10.1.2.x"

# Lanzar hans en background
hans -c "$SERVER_IP" -p tunel123 -f &
HANS_PID=$!

echo "[*] Esperando que el tunel se establezca..."
sleep 3

# La IP del servidor en el tunel es siempre 10.1.2.1
TUNNEL_SERVER="10.1.2.1"

echo "[*] Verificando conectividad por el tunel..."
ping -c 3 "$TUNNEL_SERVER" && echo "[+] Tunel ICMP funcionando!" || echo "[-] Sin respuesta aun"

echo ""
echo "[*] Haciendo peticion HTTP al servidor a traves del tunel..."
curl -v "http://$TUNNEL_SERVER/" 2>&1 || true

echo ""
echo "[+] Demo completa. Tunel activo (PID $HANS_PID)"
echo "    Puedes acceder al servidor en: http://10.1.2.1/"
echo "    Presiona Ctrl+C para salir"

wait $HANS_PID
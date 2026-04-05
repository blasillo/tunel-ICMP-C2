#!/bin/sh
set -e

echo "[*] Añadiendo ruta de vuelta hacia red del cliente via router..."
ip route add 172.22.0.0/24 via 172.21.0.2 || true

echo "[*] Iniciando nginx..."
nginx &
 
echo "[*] Iniciando hans server..."
echo "    Red del tunel: 10.1.2.0/24"
echo "    Password: tunel123"
 
# hans -s <red_tunel> -p <password>
# -s modo servidor, asigna IPs del rango dado
exec hans -s 10.1.2.0 -p tunel123 -f
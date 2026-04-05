#!/bin/sh
set -e
 
# Inicializar valid_ids.txt solo si el volumen está vacío
if [ ! -f /data/valid_ids/valid_ids.txt ]; then
    echo "[*] Creando valid_ids.txt por defecto..."
    mkdir -p /data/valid_ids
    echo -e "cliente-001\ncliente-002\ncliente-abc" > /data/valid_ids/valid_ids.txt
fi
 
mkdir -p /data/clients /data/results
 
echo "[*] Añadiendo ruta de vuelta hacia red del cliente via router..."
ip route add 172.22.0.0/24 via 172.21.0.2 || true
 
echo "[*] Iniciando app Flask..."
python3 /app.py &
 
echo "[*] Iniciando hans server..."
exec hans -s 10.1.2.0 -p tunel123 -f
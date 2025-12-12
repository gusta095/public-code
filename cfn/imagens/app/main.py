from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Estou funcionando na porta 8282!"

if __name__ == "__main__":
    # host=0.0.0.0 permite que o container receba tráfego externo
    app.run(host="0.0.0.0", port=8282)
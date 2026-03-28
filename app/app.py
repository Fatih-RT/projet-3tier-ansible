from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import socket
import os

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:////opt/flaskapp/app.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SECRET_KEY"] = "changeme-in-production"

db = SQLAlchemy(app)

class Item(db.Model):
    id    = db.Column(db.Integer, primary_key=True)
    name  = db.Column(db.String(80), nullable=False)
    value = db.Column(db.String(200))

with app.app_context():
    db.create_all()

@app.route("/")
def index():
    return jsonify({
        "message": "Architecture 3-tier operationnelle",
        "instance": socket.gethostname(),
        "status": "ok"
    })

@app.route("/health")
def health():
    try:
        db.session.execute(db.text("SELECT 1"))
        db_status = "ok"
    except Exception as e:
        db_status = str(e)
    return jsonify({
        "status": "ok",
        "db": db_status,
        "host": socket.gethostname()
    })

@app.route("/items", methods=["GET"])
def get_items():
    items = Item.query.all()
    return jsonify([{"id": i.id, "name": i.name, "value": i.value} for i in items])

@app.route("/items", methods=["POST"])
def create_item():
    data = request.get_json()
    item = Item(name=data["name"], value=data.get("value", ""))
    db.session.add(item)
    db.session.commit()
    return jsonify({"id": item.id, "name": item.name}), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)

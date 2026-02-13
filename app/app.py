import os
from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_PORT = os.getenv("DB_PORT", "5432")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )


def create_table():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS items (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL
        );
    """)
    conn.commit()
    cur.close()
    conn.close()


@app.route("/")
def home():
    return "Flask CRUD App Running 🚀"


@app.route("/items", methods=["POST"])
def create_item():
    data = request.get_json()
    name = data.get("name")

    conn = get_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute("INSERT INTO items (name) VALUES (%s) RETURNING *;", (name,))
    new_item = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()

    return jsonify(new_item), 201


@app.route("/items", methods=["GET"])
def get_items():
    conn = get_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute("SELECT * FROM items;")
    items = cur.fetchall()
    cur.close()
    conn.close()

    return jsonify(items)


@app.route("/items/<int:item_id>", methods=["PUT"])
def update_item(item_id):
    data = request.get_json()
    name = data.get("name")

    conn = get_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(
        "UPDATE items SET name = %s WHERE id = %s RETURNING *;",
        (name, item_id)
    )
    updated_item = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()

    if updated_item:
        return jsonify(updated_item)
    else:
        return jsonify({"error": "Item not found"}), 404


@app.route("/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM items WHERE id = %s;", (item_id,))
    conn.commit()
    deleted = cur.rowcount
    cur.close()
    conn.close()

    if deleted:
        return jsonify({"message": "Item deleted"})
    else:
        return jsonify({"error": "Item not found"}), 404


if __name__ == "__main__":
    create_table()
    app.run(host="0.0.0.0", port=5000)

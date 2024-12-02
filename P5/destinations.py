from flask import Flask, request, jsonify
import pyodbc

app = Flask(__name__)

#database configuration
DATABASE_CONFIG = {
    'server': 'THAO-LAPTOP\\SQLEXPRESS01',
    'database': 'Project',
    'driver': '{ODBC Driver 17 for SQL Server}',
    'trusted_connection': 'yes',
    'encrypt': 'yes',                      
}

#connection string
CONNECTION_STRING = (
    f"DRIVER={DATABASE_CONFIG['driver']};"
    f"SERVER={DATABASE_CONFIG['server']};"
    f"DATABASE={DATABASE_CONFIG['database']};"
    f"Trusted_Connection={DATABASE_CONFIG['trusted_connection']};"
    f"Encrypt={DATABASE_CONFIG['encrypt']};"
    f"TrustServerCertificate=Yes;"
)

# Function to connect to the database
def get_db_connection():
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        return conn
    except pyodbc.Error as e:
        print("Database connection error:", e)
        return None


# GET all destinations
@app.route('/destinations', methods=['GET'])
def get_all_destinations():
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Destination")
        columns = [column[0] for column in cursor.description]
        destinations = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return jsonify(destinations)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# GET a destination by ID
@app.route('/destinations/<int:destination_id>', methods=['GET'])
def get_destination_by_id(destination_id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Destination WHERE destination_id = ?", destination_id)
        row = cursor.fetchone()
        if row:
            columns = [column[0] for column in cursor.description]
            destination = dict(zip(columns, row))
            return jsonify(destination)
        else:
            return jsonify({"error": "Destination not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# POST a new destination
@app.route('/destinations', methods=['POST'])
def create_destination():
    data = request.json
    required_fields = ['destination_id', 'city', 'state', 'airport_id']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO Destination (destination_id, city, state, airport_id)
            VALUES (?, ?, ?, ?)
            """,
            data['destination_id'], data['city'], data['state'], data['airport_id']
        )
        conn.commit()
        return jsonify({"message": "Destination created successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# PUT to update a destination
@app.route('/destinations/<int:destination_id>', methods=['PUT'])
def update_destination(destination_id):
    data = request.json
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE Destination
            SET city = ?, state = ?, airport_id = ?
            WHERE destination_id = ?
            """,
            data['city'], data['state'], data['airport_id'], destination_id
        )
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Destination updated successfully"})
        else:
            return jsonify({"error": "Destination not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# DELETE a destination
@app.route('/destinations/<int:destination_id>', methods=['DELETE'])
def delete_destination(destination_id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Destination WHERE destination_id = ?", destination_id)
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Destination deleted successfully"})
        else:
            return jsonify({"error": "Destination not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

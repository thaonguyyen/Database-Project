from flask import Flask, request, jsonify
import pyodbc

app = Flask(__name__)

# Database configuration
DATABASE_CONFIG = {
    'server': 'THAO-LAPTOP\\SQLEXPRESS01',
    'database': 'Project',
    'driver': '{ODBC Driver 17 for SQL Server}',
    'trusted_connection': 'yes',
    'encrypt': 'yes',
}

# Connection string
CONNECTION_STRING = (
    f"DRIVER={DATABASE_CONFIG['driver']};"
    f"SERVER={DATABASE_CONFIG['server']};"
    f"DATABASE={DATABASE_CONFIG['database']};"
    f"Trusted_Connection={DATABASE_CONFIG['trusted_connection']};"
    f"Encrypt={DATABASE_CONFIG['encrypt']};"
    f"TrustServerCertificate=Yes;"
)

# Connect to database
def get_db_connection():
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        return conn
    except pyodbc.Error as e:
        print("Database connection error:", e)
        return None

# GET all itineraries
@app.route('/itineraries', methods=['GET'])
def get_all_itineraries():
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Itinerary")
        columns = [column[0] for column in cursor.description]
        itineraries = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return jsonify(itineraries)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# GET a specific itinerary by ID
@app.route('/itineraries/<int:itinerary_id>', methods=['GET'])
def get_itinerary_by_id(itinerary_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Itinerary WHERE itinerary_id = ?", itinerary_id)
        row = cursor.fetchone()
        if row:
            columns = [column[0] for column in cursor.description]
            itinerary = dict(zip(columns, row))
            return jsonify(itinerary)
        else:
            return jsonify({"error": "Itinerary not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# POST a new itinerary
@app.route('/itineraries', methods=['POST'])
def post_itinerary():
    data = request.json

    required_fields = ['itinerary_id', 'trip_id', 'destination_id', 'total_cost', 'departure_airport_id', 'arrival_airport_id', 'flight_id']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO Itinerary (itinerary_id, trip_id, destination_id, total_cost, departure_airport_id, arrival_airport_id, flight_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            data['itinerary_id'], data['trip_id'], data['destination_id'], data['total_cost'], 
            data['departure_airport_id'], data['arrival_airport_id'], data['flight_id']
        )
        conn.commit()
        return jsonify({"message": "Itinerary added successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# PUT and update an existing itinerary
@app.route('/itineraries/<int:itinerary_id>', methods=['PUT'])
def update_itinerary(itinerary_id):
    data = request.json
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE Itinerary
            SET trip_id = ?, destination_id = ?, total_cost = ?, departure_airport_id = ?, arrival_airport_id = ?, flight_id = ?
            WHERE itinerary_id = ?
            """,
            data['trip_id'], data['destination_id'], data['total_cost'], 
            data['departure_airport_id'], data['arrival_airport_id'], data['flight_id'], itinerary_id
        )
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Itinerary updated successfully"})
        else:
            return jsonify({"error": "Itinerary not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# DELETE a specific itinerary
@app.route('/itineraries/<int:itinerary_id>', methods=['DELETE'])
def delete_itinerary(itinerary_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Itinerary WHERE itinerary_id = ?", itinerary_id)
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Itinerary deleted successfully"})
        else:
            return jsonify({"error": "Itinerary not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# Start Flask server
if __name__ == '__main__':
    app.run(debug=True)

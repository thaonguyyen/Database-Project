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

#connect to database
def get_db_connection():
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        return conn
    except pyodbc.Error as e:
        print("Database connection error:", e)
        return None
    
#GET all trips
@app.route('/trips', methods=['GET'])
def get_all_trips():
    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #retrieve all trips
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Trip")
        columns = [column[0] for column in cursor.description]
        trips = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return jsonify(trips)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#GET a trip with specific trip ID
@app.route('/trips/<int:trip_id>', methods=['GET'])
def get_trip_by_id(trip_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #retrieve trip with specific ID
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Trip WHERE trip_id = ?", trip_id)
        row = cursor.fetchone()
        #return if specified trip exists
        if row:
            columns = [column[0] for column in cursor.description]
            trip = dict(zip(columns, row))
            return jsonify(trip)
        else:
            return jsonify({"error": "Trip not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#POST a new trip
@app.route('/trips', methods=['POST'])
def create_trip():
    data = request.json

    #validate trip input
    required_fields = ['trip_id', 'user_id', 'number_of_people']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #insert new trip into table
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO Trip (trip_id, user_id, number_of_people)
            VALUES (?, ?, ?)
            """,
            data['trip_id'], data['user_id'], data['number_of_people']
        )
        conn.commit()
        return jsonify({"message": "Trip posted successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#PUT and update an existing trip based on specified ID
#must include destination, user_id, star_rating, and comment in request
@app.route('/trips/<int:trip_id>', methods=['PUT'])
def update_trip(trip_id):
    data = request.json
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #update trip based on request
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE Trip
            SET number_of_people = ?
            WHERE trip_id = ?
            """,
            data['number_of_people'], trip_id
        )
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Trip updated successfully"})
        else:
            return jsonify({"error": "Trip not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#DELETE a specific trip
@app.route('/trips/<int:trip_id>', methods=['DELETE'])
def delete_trip(trip_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #delete specific trip from table
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Trip WHERE trip_id = ?", trip_id)
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Trip deleted successfully"})
        else:
            return jsonify({"error": "Trip not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#start Flask server
if __name__ == '__main__':
    app.run(debug=True)
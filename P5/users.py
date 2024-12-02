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

def get_db_connection():
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        return conn
    except pyodbc.Error as e:
        print("Database connection error:", e)
        return None

@app.route('/users', methods=['GET'])
def get_all_users():
    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM [User]")
        columns = [column[0] for column in cursor.description]
        users = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return jsonify(users)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM [User] WHERE user_id = ?", user_id)
        row = cursor.fetchone()
        if row:
            columns = [column[0] for column in cursor.description]
            user = dict(zip(columns, row))
            return jsonify(user)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/users', methods=['POST'])
def create_new_user():
    data = request.json
    required_fields = ['user_id', 'first_name', 'last_name', 'email', 'password', 'city', 'state', 'date_of_birth']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400
    
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO [User] (user_id, first_name, last_name, email, password, city, [state], date_of_birth)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            data['user_id'], data['first_name'], data['last_name'], data['email'], data['password'], data['city'], data['state'], data['date_of_birth']
        )
        conn.commit()
        return jsonify({"message": "Created user successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/users/<int:user_id>', methods=['PUT'])
def update_user_details(user_id):
    data = request.json
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #update review based on request
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE [User]
            SET first_name = ?, last_name = ?, city = ?, [state] = ?, email = ?, password = ?
            WHERE user_id = ?
            """,
            data['first_name'], data['last_name'], data['city'], data['state'], data['email'], data['password'], user_id
        )
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "User updated successfully"})
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #delete specific review from table
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM [User] WHERE user_id = ?", user_id)
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "User deleted successfully"})
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()


#start Flask server
if __name__ == '__main__':
    app.run(debug=True)
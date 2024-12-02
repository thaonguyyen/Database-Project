import datetime
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

#GET all users
@app.route('/users', methods=['GET'])
def get_all_users():
    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        
        cursor.execute("OPEN SYMMETRIC KEY PasswordKey DECRYPTION BY CERTIFICATE PasswordCert")
        cursor.execute("""
            SELECT user_id, first_name, last_name, email,
                   CONVERT(VARCHAR, DecryptByKey(encrypted_password)) AS password,
                   city, state, date_of_birth
            FROM [User]
        """)
        
        columns = [column[0] for column in cursor.description]
        users = [dict(zip(columns, row)) for row in cursor.fetchall()]

        cursor.execute("CLOSE SYMMETRIC KEY PasswordKey")
        
        return jsonify(users)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#GET specific user based on ID
@app.route('/users/<int:user_id>', methods=['GET'])
def get_user_by_id(user_id):
    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("OPEN SYMMETRIC KEY PasswordKey DECRYPTION BY CERTIFICATE PasswordCert")
        cursor.execute("""
            SELECT user_id, first_name, last_name, email,
                   CONVERT(VARCHAR, DecryptByKey(encrypted_password)) AS password,
                   city, state, date_of_birth
            FROM [User]
            WHERE user_id = ?
        """, (user_id,))
        
        row = cursor.fetchone()

        cursor.execute("CLOSE SYMMETRIC KEY PasswordKey")
        
        if row is None:
            return jsonify({"error": "User not found"}), 404
        
        #specify column names
        columns = ['user_id', 'first_name', 'last_name', 'email', 'password', 'city', 'state', 'date_of_birth']
        user = dict(zip(columns, row))
        print(f"User dictionary: {user}")
        
        if 'date_of_birth' in user and isinstance(user['date_of_birth'], datetime.date):
            user['date_of_birth'] = user['date_of_birth'].strftime('%Y-%m-%d')
        
        return jsonify(user)
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/users', methods=['POST'])
def create_user():
    data = request.json
    required_fields = ['user_id', 'first_name', 'last_name', 'email', 'password', 'city', 'state', 'date_of_birth']

    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()

        cursor.execute("OPEN SYMMETRIC KEY PasswordKey DECRYPTION BY CERTIFICATE PasswordCert")
        
        cursor.execute("""
            INSERT INTO [User] (user_id, first_name, last_name, email, password, encrypted_password, city, state, date_of_birth)
            VALUES (?, ?, ?, ?, ?, EncryptByKey(Key_GUID('PasswordKey'), ?), ?, ?, ?)
        """, (
            data['user_id'], data['first_name'], data['last_name'], data['email'],
            data['password'], data['password'], data['city'], data['state'], data['date_of_birth']
        ))

        conn.commit()
        cursor.execute("CLOSE SYMMETRIC KEY PasswordKey")
        
        return jsonify({"message": "User created successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#PUT and update existing user
@app.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    data = request.json
    required_fields = ['first_name', 'last_name', 'email', 'password', 'city', 'state', 'date_of_birth']

    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()

        cursor.execute("OPEN SYMMETRIC KEY PasswordKey DECRYPTION BY CERTIFICATE PasswordCert")
        cursor.execute("""
            UPDATE [User]
            SET first_name = ?, last_name = ?, email = ?, password = ?,
                encrypted_password = EncryptByKey(Key_GUID('PasswordKey'), ?),
                city = ?, state = ?, date_of_birth = ?
            WHERE user_id = ?
        """, (
            data['first_name'], data['last_name'], data['email'],
            data['password'], data['password'], data['city'], data['state'], data['date_of_birth'], user_id
        ))
        
        rows_affected = cursor.rowcount

        conn.commit()
        
        cursor.execute("CLOSE SYMMETRIC KEY PasswordKey")
        
        if rows_affected == 0:
            return jsonify({"error": "User not found"}), 404
        
        return jsonify({"message": "User updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#DELETE an existing user
@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

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
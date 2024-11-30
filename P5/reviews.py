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
    
#GET all reviews
@app.route('/reviews', methods=['GET'])
def get_all_reviews():
    conn = get_db_connection()
    
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #retrieve all reviews
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Review")
        columns = [column[0] for column in cursor.description]
        reviews = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return jsonify(reviews)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#GET a review with specific review ID
@app.route('/reviews/<int:review_id>', methods=['GET'])
def get_review_by_id(review_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #retrieve review with specific ID
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Review WHERE review_id = ?", review_id)
        row = cursor.fetchone()
        #return if specified review exists
        if row:
            columns = [column[0] for column in cursor.description]
            review = dict(zip(columns, row))
            return jsonify(review)
        else:
            return jsonify({"error": "Review not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#POST a new review
@app.route('/reviews', methods=['POST'])
def post_review():
    data = request.json

    #validate review input
    required_fields = ['review_id', 'destination_id', 'user_id', 'star_rating', 'comment']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #insert new review into table
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO Review (review_id, destination_id, user_id, star_rating, comment)
            VALUES (?, ?, ?, ?, ?)
            """,
            data['review_id'], data['destination_id'], data['user_id'], data['star_rating'], data['comment']
        )
        conn.commit()
        return jsonify({"message": "Review posted successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#PUT and update an existing review based on specified ID
#must include destination, user_id, star_rating, and comment in request
@app.route('/reviews/<int:review_id>', methods=['PUT'])
def update_review(review_id):
    data = request.json
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #update review based on request
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE Review
            SET destination_id = ?, user_id = ?, star_rating = ?, comment = ?
            WHERE review_id = ?
            """,
            data['destination_id'], data['user_id'], data['star_rating'], data['comment'], review_id
        )
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Review updated successfully"})
        else:
            return jsonify({"error": "Review not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#DELETE a specific review
@app.route('/reviews/<int:review_id>', methods=['DELETE'])
def delete_review(review_id):
    conn = get_db_connection()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    #delete specific review from table
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Review WHERE review_id = ?", review_id)
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({"message": "Review deleted successfully"})
        else:
            return jsonify({"error": "Review not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#start Flask server
if __name__ == '__main__':
    app.run(debug=True)
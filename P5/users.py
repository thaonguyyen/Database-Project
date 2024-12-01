from flask import Flask, request, jsonify
import pyodbc

app = Flask(__name__)

@app.route('/users', methods=['GET'])
def get_all_users():
    return

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user():
    pass

@app.route('/users', methods=['POST'])
def create_new_user():
    pass

@app.route('/users/<int:user_id>', methods=['PUT'])
def update_user_details():
    pass

@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user():
    pass

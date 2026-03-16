#!/bin/bash

apt update -y
apt install python3-pip -y

pip3 install flask

cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Flask Backend Running"

if __name__ == "__main__":
    app.run(host='0.0.0.0',port=5000)
EOF

nohup python3 app.py &

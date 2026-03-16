#!/bin/bash

apt update -y

apt install python3-pip nodejs npm git -y

cd /home/ubuntu

mkdir project
cd project

#################################
# Create Flask App
#################################

cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Flask Backend Running!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

pip3 install flask

nohup python3 app.py &

#################################
# Create Express App
#################################

mkdir express
cd express

cat <<EOF > server.js
const express = require('express');
const app = express();

app.get('/', (req,res)=>{
res.send("Express Frontend Running!");
});

app.listen(3000,'0.0.0.0');
EOF

npm init -y

npm install express

nohup node server.js &

#!/bin/bash

apt update -y

apt install curl -y
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install nodejs -y

mkdir express
cd express

npm init -y
npm install express

cat <<EOF > server.js
const express = require('express')
const app = express()

app.get('/',(req,res)=>{
res.send("Express Frontend Running")
})

app.listen(3000,'0.0.0.0')
EOF

nohup node server.js &

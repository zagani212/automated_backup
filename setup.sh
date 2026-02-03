#install mong-vb
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc |    sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg    --dearmor     
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
#start service
sudo systemctl start mongod
sudo systemctl status mongod
#add fake data
curl https://media.mongodb.org/zips.json?_ga=1.92708894.286077728.1426686247 > /tmp/test.json
less /tmp/test.json
mongoimport --db testdb --collection testCollection --file /tmp/test.json
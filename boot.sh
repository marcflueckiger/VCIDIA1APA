#!/bin/bash
#sudo mariadb -u root
#DROP DATABSE fluga;
#CREATE DATABASE fluga;
#CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
#GRANT ALL PRIVILEGES ON fluga.* TO 'user'@'localhost';
#FLUSH PRIVILEGES;
#quit;

sudo supervisorctl stop fluga
sudo service nginx stop
rm -r __pycache__
rm -r migrations/

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install pymysql
#pip install gunicorn

flask db init
flask db migrate
flask db upgrade

gunicorn -b :5000 --access-logfile - --error-logfile - fluga:app

sudo supervisorctl start fluga
sudo service nginx start

#echo DATABASE_URL=mysql+pymysql://user:password@localhost/fluga >.env 


#flask db heads
#b7d5e405deb0 (head)
#f32cc5493c81 (head)
#ab362d3281c4 (head)

#flask db merge -m "Merge migrations" b7d5e405deb0 f32cc5493c81 ab362d3281c4 
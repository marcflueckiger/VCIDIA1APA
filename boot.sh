#!/bin/bash

sudo supervisorctl stop fluga
sudo service nginx stop
rm -r __pycache__
rm -r migrations/

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


flask db init
flask db migrate
flask db upgrade
#pip install gunicorn
gunicorn -b :5000 --access-logfile - --error-logfile - fluga:app

sudo supervisorctl start fluga
sudo service nginx start

#echo DATABASE_URL=mysql+pymysql://user:password@localhost/fluga >.env 

#!/bin/bash

sudo supervisorctl stop fluga
sudo service nginx stop

rm -r app.db
rm -r migrations/
source venv/bin/activate

mv .env env

flask db init
flask db migrate
flask db upgrade

gunicorn -b :5000 --access-logfile - --error-logfile - fluga:app


mv env .env
flask db migrate
flask db upgrade

sudo supervisorctl start fluga
sudo service nginx start
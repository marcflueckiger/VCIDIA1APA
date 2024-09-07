rm app.db
rm -r migrations/
flask db init
flask db migrate
flask db upgrade
gunicorn -b :5000 --access-logfile - --error-logfile - fluga:app

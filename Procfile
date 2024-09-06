web: flask db upgrade; flask translate compile; gunicorn fluga:app
worker: rq worker fluga-tasks

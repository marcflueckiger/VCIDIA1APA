from app import create_app, db, cli
from app.models import User, Post, Message, Notification, Task, Rating

app = create_app()
cli.register(app)


@app.shell_context_processor
def make_shell_context():
    return {'db': db, 'User': User, 'Post': Post, 'Message': Message,
            'Notification': Notification, 'Task': Task, 'Rating': Rating}

if __name__ == "__main__":
    app.run(debug=True)
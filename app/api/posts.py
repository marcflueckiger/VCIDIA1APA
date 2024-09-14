from flask import jsonify, request, url_for, abort
from app import db
from app.api import bp
from app.models import Post, User
from app.api.auth import token_auth
from app.api.errors import bad_request

# Posts mit ID auslesen
@bp.route('/posts/<int:post_id>', methods=['GET'])
@token_auth.login_required
def get_post(post_id):
    return jsonify(Post.query.get_or_404(post_id).to_dict())

# Alle Posts auslesen
@bp.route('/posts', methods=['GET'])
@token_auth.login_required
def get_posts():
    page = request.args.get('page', 1, type=int)
    per_page = min(request.args.get('per_page', 10, type=int), 100)
    posts = Post.query.paginate(page, per_page, False)
    data = {
        'posts': [post.to_dict() for post in posts.items],
        'total_posts': posts.total,
        'pages': posts.pages,
        'current_page': page,
        'per_page': per_page
    }
    return jsonify(data)

# Einen neuen Post erstellen
@bp.route('/posts', methods=['POST'])
@token_auth.login_required
def create_post():
    data = request.get_json() or {}
    if 'body' not in data:
        return bad_request('The post body is required.')
    post = Post(body=data['body'], author=token_auth.current_user())
    db.session.add(post)
    db.session.commit()
    post_data = post.to_dict()
    return jsonify(post_data), 201, {'Location': url_for('api.get_post', post_id=post.id)}


@bp.route('/posts/<int:post_id>', methods=['DELETE'])
@token_auth.login_required
def delete_post(post_id):
    post = Post.query.get_or_404(post_id)
    
    # Sicherstellen, dass der aktuelle Benutzer der Autor des Posts ist
    if post.author != token_auth.current_user():
        abort(403)  # Verbietet den Zugriff, wenn nicht der Autor
    
    db.session.delete(post)
    db.session.commit()
    return jsonify({'message': 'Post deleted successfully'})

# Likes aus einem Post auslesen
@bp.route('/posts/<int:post_id>/likes', methods=['GET'])
@token_auth.login_required
def get_likes(post_id):
    post = Post.query.get_or_404(post_id)
    return jsonify({
        'post_id': post_id,
        'like_count': post.like_count()
    })

# Like eines Post setzen
@bp.route('/posts/<int:post_id>/like', methods=['POST'])
@token_auth.login_required
def like_unlike_post(post_id):
    post = Post.query.get_or_404(post_id)
    user = token_auth.current_user()
    # Wenn schon geliked, wird like entfernt.
    if post.is_liked_by(user):
        post.unlike(user)
        db.session.commit()
        return jsonify({
            'status': 'unliked',
            'post_id': post_id,
            'like_count': post.like_count()
        })
    # Wenn noch nicht geliked, wird like erstellt.
    else:
        post.like(user)
        db.session.commit()
        return jsonify({
            'status': 'liked',
            'post_id': post_id,
            'like_count': post.like_count()
        })

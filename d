[33mcommit 758ec85313b50490aca7e8360e79aa6b97f376c7[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmaster[m[33m, [m[1;31morigin/master[m[33m)[m
Merge: ff30949 2496766
Author: marcflueckiger <marc.flueckiger@student.ipso.ch>
Date:   Fri Sep 6 21:50:38 2024 +0200

    Merge branch 'master' of https://github.com/marcflueckiger/fluga

[1mdiff --cc README.md[m
[1mindex fafd85d,09a0d7a..0ca8fea[m
[1m--- a/README.md[m
[1m+++ b/README.md[m
[36m@@@ -1,1 -1,1 +1,5 @@@[m
[31m- # APP[m
[32m++<<<<<<< HEAD[m
[32m+ # APP[m
[32m++=======[m
[32m++# APP[m
[32m++>>>>>>> 2496766c43aea66133d232ec3105ddc35b4418cd[m
[1mdiff --cc app/main/routes.py[m
[1mindex 2c4b43a,2b650bc..98dc2de[m
[1m--- a/app/main/routes.py[m
[1m+++ b/app/main/routes.py[m
[36m@@@ -6,8 -6,8 +6,8 @@@[m [mfrom flask_babel import _, get_local[m
  from langdetect import detect, LangDetectException[m
  from app import db[m
  from app.main.forms import EditProfileForm, EmptyForm, PostForm, SearchForm, \[m
[31m-     MessageForm, NewsletterForm[m
[31m- from app.models import User, Post, Message, Notification[m
[32m+     MessageForm[m
[31m -from app.models import User, Post, Message, Notification[m
[32m++from app.models import User, Post, Message, Notification, Rating[m
  from app.translate import translate[m
  from app.main import bp[m
  [m
[36m@@@ -230,17 -230,3 +230,31 @@@[m [mdef notifications()[m
          'data': n.get_data(),[m
          'timestamp': n.timestamp[m
      } for n in notifications])[m
[32m +[m
[31m- @bp.route('/newsletter', methods=['GET', 'POST'])[m
[31m- def newsletter():[m
[31m-     form = NewsletterForm()[m
[31m-     if form.validate_on_submit():[m
[31m-         user = User.query.filter_by(email=form.email.data).first()[m
[31m-         if user:[m
[31m-             user.newsletter = form.subscribe.data[m
[31m-             db.session.commit()[m
[31m-             flash('Your newsletter preferences have been updated.')[m
[31m-         else:[m
[31m-             flash('User not found.')[m
[31m-         return redirect(url_for('index'))[m
[31m-     return render_template('newsletter.html', form=form)[m
[32m++@bp.route('/like/<int:post_id>', methods=['POST'])[m
[32m++@login_required[m
[32m++def like_post(post_id):[m
[32m++    post = Post.query.get_or_404(post_id)[m
[32m++    if not post.is_liked_by(current_user):[m
[32m++        rating = Rating(user_id=current_user.id, post_id=post_id)[m
[32m++        db.session.add(rating)[m
[32m++        db.session.commit()[m
[32m++    else:[m
[32m++        flash('You have already liked this post')[m
[32m++    [m
[32m++    # Stay on the current page[m
[32m++    return redirect(request.referrer or url_for('main.index'))[m
[32m++[m
[32m++[m
[32m++@bp.route('/unlike/<int:post_id>', methods=['POST'])[m
[32m++@login_required[m
[32m++def unlike_post(post_id):[m
[32m++    post = Post.query.get_or_404(post_id)[m
[32m++    rating = Rating.query.filter_by(user_id=current_user.id, post_id=post_id).first()[m
[32m++    if rating:[m
[32m++        db.session.delete(rating)[m
[32m++        db.session.commit()[m
[32m++    [m
[32m++    # Stay on the current page[m
[32m++    return redirect(request.referrer or url_for('main.index'))[m
[32m++[m
[1mdiff --cc app/models.py[m
[1mindex 0ddba62,5bdab20..4fe873e[m
[1m--- a/app/models.py[m
[1m+++ b/app/models.py[m
[36m@@@ -88,7 -88,7 +88,6 @@@[m [mfollowers = db.Table[m
      db.Column('followed_id', db.Integer, db.ForeignKey('user.id'))[m
  )[m
  [m
[31m--[m
  class User(UserMixin, PaginatedAPIMixin, db.Model):[m
      id = db.Column(db.Integer, primary_key=True)[m
      username = db.Column(db.String(64), index=True, unique=True)[m
[36m@@@ -240,6 -239,6 +238,24 @@@[m
  def load_user(id):[m
      return User.query.get(int(id))[m
  [m
[32m++class Rating(db.Model):[m
[32m++    post_id = db.Column(db.Integer, db.ForeignKey('post.id'), primary_key=True)[m
[32m++    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), primary_key=True)[m
[32m++    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)[m
[32m++[m
[32m++    @staticmethod[m
[32m++    def like_post(user, post):[m
[32m++        if not Rating.query.filter_by(user_id=user.id, post_id=post.id).first():[m
[32m++            rating = Rating(user_id=user.id, post_id=post.id)[m
[32m++            db.session.add(rating)[m
[32m++            db.session.commit()[m
[32m++[m
[32m++    @staticmethod[m
[32m++    def unlike_post(user, post):[m
[32m++        rating = Rating.query.filter_by(user_id=user.id, post_id=post.id).first()[m
[32m++        if rating:[m
[32m++            db.session.delete(rating)[m
[32m++            db.session.commit()[m
  [m
  class Post(SearchableMixin, db.Model):[m
      __searchable__ = ['body'][m
[36m@@@ -248,11 -247,11 +264,17 @@@[m
      timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)[m
      user_id = db.Column(db.Integer, db.ForeignKey('user.id'))[m
      language = db.Column(db.String(5))[m
[32m++    ratings = db.relationship('Rating', lazy='dynamic')[m
  [m
      def __repr__(self):[m
          return '<Post {}>'.format(self.body)[m
[31m--[m
[31m--[m
[32m++    [m
[32m++    def is_liked_by(self, user):[m
[32m++        return Rating.query.filter_by(user_id=user.id, post_id=self.id).count() > 0[m
[32m++    [m
[32m++    def like_count(self):[m
[32m++        return self.ratings.count()[m
[32m++    [m
  class Message(db.Model):[m
      id = db.Column(db.Integer, primary_key=True)[m
      sender_id = db.Column(db.Integer, db.ForeignKey('user.id'))[m
[36m@@@ -263,6 -262,6 +285,12 @@@[m
      def __repr__(self):[m
          return '<Message {}>'.format(self.body)[m
  [m
[32m++   # Klasse Post mit den Likes [m
[32m++    def like_count(self):[m
[32m++        return self.ratings.count()[m
[32m++[m
[32m++    def is_liked_by(self, user):[m
[32m++        return Rating.query.filter_by(user_id=user.id, post_id=self.id).count() > 0[m
  [m
  class Notification(db.Model):[m
      id = db.Column(db.Integer, primary_key=True)[m
[1mdiff --cc app/templates/_post.html[m
[1mindex 631bcb7,631bcb7..59f36ca[m
[1m--- a/app/templates/_post.html[m
[1m+++ b/app/templates/_post.html[m
[36m@@@ -27,6 -27,6 +27,18 @@@[m
                                  '{{ g.locale }}');">{{ _('Translate') }}</a>[m
                  </span>[m
                  {% endif %}[m
[32m++                {% if current_user.is_authenticated %}[m
[32m++                <form action="{% if post.is_liked_by(current_user) %}{{ url_for('main.unlike_post', post_id=post.id) }}{% else %}{{ url_for('main.like_post', post_id=post.id) }}{% endif %}" method="post">[m
[32m++                    {% if post.is_liked_by(current_user) %}[m
[32m++                        <button type="submit" class="btn btn-danger">Unlike</button>[m
[32m++                    {% else %}[m
[32m++                        <button type="submit" class="btn btn-success">Like</button>[m
[32m++                    {% endif %}[m
[32m++                </form>[m
[32m++                <p>{{ post.like_count() }} Likes</p>[m
[32m++                [m
[32m++                {% endif %}[m
[32m++                [m
              </td>[m
          </tr>[m
      </table>[m
[1mdiff --cc env[m
[1mindex 4fdd745,0000000..4fdd745[m
mode 100644,000000..100644[m
[1m--- a/env[m
[1m+++ b/env[m
[1mdiff --cc migrations/alembic.ini[m
[1mindex 0000000,f8ed480..ec9d45c[m
mode 000000,100644..100644[m
[1m--- a/migrations/alembic.ini[m
[1m+++ b/migrations/alembic.ini[m
[36m@@@ -1,0 -1,45 +1,50 @@@[m
[32m+ # A generic, single database configuration.[m
[32m+ [m
[32m+ [alembic][m
[32m+ # template used to generate migration files[m
[32m+ # file_template = %%(rev)s_%%(slug)s[m
[32m+ [m
[32m+ # set to 'true' to run the environment during[m
[32m+ # the 'revision' command, regardless of autogenerate[m
[32m+ # revision_environment = false[m
[32m+ [m
[32m+ [m
[32m+ # Logging configuration[m
[32m+ [loggers][m
[31m -keys = root,sqlalchemy,alembic[m
[32m++keys = root,sqlalchemy,alembic,flask_migrate[m
[32m+ [m
[32m+ [handlers][m
[32m+ keys = console[m
[32m+ [m
[32m+ [formatters][m
[32m+ keys = generic[m
[32m+ [m
[32m+ [logger_root][m
[32m+ level = WARN[m
[32m+ handlers = console[m
[32m+ qualname =[m
[32m+ [m
[32m+ [logger_sqlalchemy][m
[32m+ level = WARN[m
[32m+ handlers =[m
[32m+ qualname = sqlalchemy.engine[m
[32m+ [m
[32m+ [logger_alembic][m
[32m+ level = INFO[m
[32m+ handlers =[m
[32m+ qualname = alembic[m
[32m+ [m
[32m++[logger_flask_migrate][m
[32m++level = INFO[m
[32m++handlers =[m
[32m++qualname = flask_migrate[m
[32m++[m
[32m+ [handler_console][m
[32m+ class = StreamHandler[m
[32m+ args = (sys.stderr,)[m
[32m+ level = NOTSET[m
[32m+ formatter = generic[m
[32m+ [m
[32m+ [formatter_generic][m
[32m+ format = %(levelname)-5.5s [%(name)s] %(message)s[m
[32m+ datefmt = %H:%M:%S[m
[1mdiff --cc migrations/env.py[m
[1mindex 0000000,23663ff..68feded[m
mode 000000,100644..100644[m
[1m--- a/migrations/env.py[m
[1m+++ b/migrations/env.py[m
[36m@@@ -1,0 -1,87 +1,91 @@@[m
[32m+ from __future__ import with_statement[m
[31m -from alembic import context[m
[31m -from sqlalchemy import engine_from_config, pool[m
[31m -from logging.config import fileConfig[m
[32m++[m
[32m+ import logging[m
[32m++from logging.config import fileConfig[m
[32m++[m
[32m++from flask import current_app[m
[32m++[m
[32m++from alembic import context[m
[32m+ [m
[32m+ # this is the Alembic Config object, which provides[m
[32m+ # access to the values within the .ini file in use.[m
[32m+ config = context.config[m
[32m+ [m
[32m+ # Interpret the config file for Python logging.[m
[32m+ # This line sets up loggers basically.[m
[32m+ fileConfig(config.config_file_name)[m
[32m+ logger = logging.getLogger('alembic.env')[m
[32m+ [m
[32m+ # add your model's MetaData object here[m
[32m+ # for 'autogenerate' support[m
[32m+ # from myapp import mymodel[m
[32m+ # target_metadata = mymodel.Base.metadata[m
[31m -from flask import current_app[m
[31m -config.set_main_option('sqlalchemy.url',[m
[31m -                       current_app.config.get('SQLALCHEMY_DATABASE_URI'))[m
[32m++config.set_main_option([m
[32m++    'sqlalchemy.url',[m
[32m++    str(current_app.extensions['migrate'].db.get_engine().url).replace([m
[32m++        '%', '%%'))[m
[32m+ target_metadata = current_app.extensions['migrate'].db.metadata[m
[32m+ [m
[32m+ # other values from the config, defined by the needs of env.py,[m
[32m+ # can be acquired:[m
[32m+ # my_important_option = config.get_main_option("my_important_option")[m
[32m+ # ... etc.[m
[32m+ [m
[32m+ [m
[32m+ def run_migrations_offline():[m
[32m+     """Run migrations in 'offline' mode.[m
[32m+ [m
[32m+     This configures the context with just a URL[m
[32m+     and not an Engine, though an Engine is acceptable[m
[32m+     here as well.  By skipping the Engine creation[m
[32m+     we don't even need a DBAPI to be available.[m
[32m+ [m
[32m+     Calls to context.execute() here emit the given string to the[m
[32m+     script output.[m
[32m+ [m
[32m+     """[m
[32m+     url = config.get_main_option("sqlalchemy.url")[m
[31m -    context.configure(url=url)[m
[32m++    context.configure([m
[32m++        url=url, target_metadata=target_metadata, literal_binds=True[m
[32m++    )[m
[32m+ [m
[32m+     with context.begin_transaction():[m
[32m+         context.run_migrations()[m
[32m+ [m
[32m+ [m
[32m+ def run_migrations_online():[m
[32m+     """Run migrations in 'online' mode.[m
[32m+ [m
[32m+     In this scenario we need to create an Engine[m
[32m+     and associate a connection with the context.[m
[32m+ [m
[32m+     """[m
[32m+ [m
[32m+     # this callback is used to prevent an auto-migration from being generated[m
[32m+     # when there are no changes to the schema[m
[32m+     # reference: http://alembic.zzzcomputing.com/en/latest/cookbook.html[m
[32m+     def process_revision_directives(context, revision, directives):[m
[32m+         if getattr(config.cmd_opts, 'autogenerate', False):[m
[32m+             script = directives[0][m
[32m+             if script.upgrade_ops.is_empty():[m
[32m+                 directives[:] = [][m
[32m+                 logger.info('No changes in schema detected.')[m
[32m+ [m
[31m -    engine = engine_from_config(config.get_section(config.config_ini_section),[m
[31m -                                prefix='sqlalchemy.',[m
[31m -                                poolclass=pool.NullPool)[m
[32m++    connectable = current_app.extensions['migrate'].db.get_engine()[m
[32m+ [m
[31m -    connection = engine.connect()[m
[31m -    context.configure(connection=connection,[m
[31m -                      target_metadata=target_metadata,[m
[31m -                      process_revision_directives=process_revision_directives,[m
[31m -                      **current_app.extensions['migrate'].configure_args)[m
[32m++    with connectable.connect() as connection:[m
[32m++        context.configure([m
[32m++            connection=connection,[m
[32m++            target_metadata=target_metadata,[m
[32m++            process_revision_directives=process_revision_directives,[m
[32m++            **current_app.extensions['migrate'].configure_args[m
[32m++        )[m
[32m+ [m
[31m -    try:[m
[32m+         with context.begin_transaction():[m
[32m+             context.run_migrations()[m
[31m -    finally:[m
[31m -        connection.close()[m
[32m++[m
[32m+ [m
[32m+ if context.is_offline_mode():[m
[32m+     run_migrations_offline()[m
[32m+ else:[m
[32m+     run_migrations_online()[m
[1mdiff --cc migrations/versions/48f7eda1aec4_.py[m
[1mindex 0000000,0000000..50a5e90[m
[1mnew file mode 100644[m
[1m--- /dev/null[m
[1m+++ b/migrations/versions/48f7eda1aec4_.py[m
[36m@@@ -1,0 -1,0 +1,114 @@@[m
[32m++"""empty message[m
[32m++[m
[32m++Revision ID: 48f7eda1aec4[m
[32m++Revises: [m
[32m++Create Date: 2024-09-06 21:26:15.731588[m
[32m++[m
[32m++"""[m
[32m++from alembic import op[m
[32m++import sqlalchemy as sa[m
[32m++[m
[32m++[m
[32m++# revision identifiers, used by Alembic.[m
[32m++revision = '48f7eda1aec4'[m
[32m++down_revision = None[m
[32m++branch_labels = None[m
[32m++depends_on = None[m
[32m++[m
[32m++[m
[32m++def upgrade():[m
[32m++    # ### commands auto generated by Alembic - please adjust! ###[m
[32m++    op.create_table('user',[m
[32m++    sa.Column('id', sa.Integer(), nullable=False),[m
[32m++    sa.Column('username', sa.String(length=64), nullable=True),[m
[32m++    sa.Column('email', sa.String(length=120), nullable=True),[m
[32m++    sa.Column('password_hash', sa.String(length=128), nullable=True),[m
[32m++    sa.Column('about_me', sa.String(length=140), nullable=True),[m
[32m++    sa.Column('last_seen', sa.DateTime(), nullable=True),[m
[32m++    sa.Column('token', sa.String(length=32), nullable=True),[m
[32m++    sa.Column('token_expiration', sa.DateTime(), nullable=True),[m
[32m++    sa.Column('last_message_read_time', sa.DateTime(), nullable=True),[m
[32m++    sa.PrimaryKeyConstraint('id')[m
[32m++    )[m
[32m++    op.create_index(op.f('ix_user_email'), 'user', ['email'], unique=True)[m
[32m++    op.create_index(op.f('ix_user_token'), 'user', ['token'], unique=True)[m
[32m++    op.create_index(op.f('ix_user_username'), 'user', ['username'], unique=True)[m
[32m++    op.create_table('followers',[m
[32m++    sa.Column('follower_id', sa.Integer(), nullable=True),[m
[32m++    sa.Column('followed_id', sa.Integer(), nullable=True),[m
[32m++    sa.ForeignKeyConstraint(['followed_id'], ['user.id'], ),[m
[32m++    sa.ForeignKeyConstraint(['follower_id'], ['user.id'], )[m
[32m++    )[m
[32m++    op.create_table('message',[m
[32m++    sa.Column('id', sa.Integer(), nullable=False),[m
[32m++    sa.Column('sender_id', sa.Integer(), nullable=True),[m
[32m++    sa.Column('recipient_id', sa.Integer(), nullab
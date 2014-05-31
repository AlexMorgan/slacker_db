require 'pry'
require 'shotgun'
require 'pg'
require 'sinatra'

require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'slacker_articles')

    yield(connection)

  ensure
    connection.close
  end
end

# Find information from out database - passing it a string argument of a sql query
def query_articles(sql_statement)
  db_connection do |conn|
    conn.exec(sql_statement)
  end
end

def post_article(content)
  sql = "INSERT INTO articles (content, created_at) VALUES ($1, NOW());"
  db_connection do |conn|
    conn.exec_params(sql,[content])
  end
end

def query_comments(article_id)
  sql = "SELECT comments.id, comments.username, comments.content, comments.created_at, comments.votes, articles.id AS article_id, articles.content AS article_content FROM comments LEFT JOIN articles ON comments.article_id = articles.id WHERE article_id = $1 ORDER BY votes DESC"
  db_connection do |conn|
    conn.exec_params(sql,[article_id])
  end
end

def post_comment(content, username, votes, article_id)
  sql = "INSERT INTO comments (content, username, votes, article_id, created_at) VALUES($1, $2, $3, $4, NOW())"
  db_connection do |conn|
    conn.exec_params(sql,[content, username, votes, article_id])
  end
end

def upvote_comment(add_one, id)
  sql = 'UPDATE comments SET votes = $1 WHERE id = $2'
  db_connection do |conn|
    conn.exec_params(sql,[add_one,id])
  end
end

#------------------------------------------ Routes ------------------------------------------

get '/articles' do
  @articles = query_articles('SELECT articles.id, articles.content AS article_content, articles.created_at, comments.content AS comment_content, comments.votes FROM articles LEFT JOIN comments ON articles.id = comments.article_id ORDER BY articles.created_at DESC')
  erb :'/articles/index.html'
end

post '/articles' do
  # We're taking our post_article method, passing it the params of our form as the argument and using that as our placeholder
  post_article(params["question"])
  redirect '/articles'
end

get '/articles/:id/comments' do
  @comments = query_comments(params[:id])

  erb :'/articles/show.html'
end

# Post comment
post '/articles/:id/comments' do
  post_comment(params["comment"],params["username"],0,params[:id])
  # Use params to redirect back to specific article
  redirect "/articles/#{params[:id]}/comments"
end

post '/articles/:id/comment/:comment_id' do
  # Update comments.vote +1 where params["comment"] =  comments.id
  upvote_comment(params["plus_one"], params[:comment_id])
  redirect "articles/#{params[:id]}/comments"
end




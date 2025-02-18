require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
# require 'becrypt'
enable :sessions

# def connect_to_db()
#   db = SQLite3::Database.new("db/Databas.db")
#   db.results_as_hash = true


get('/')  do
  slim(:login, layout:false)
end 

post('/loggedin') do
  session[:surname] = params[:surname]
  session[:password] = params[:password]
  redirect ('/site')
end

get('/site') do
  slim(:start)
end

get('/profilsida') do
  slim(:profil)
end


get('/birds') do
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM birds")
  p result
  slim(:index ,locals:{birds:result})
end

get('/birds/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM birds WHERE Bird_id = ?",id).first
  slim(:show,locals:{result:result})
end


require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
enable :sessions

def connect_to_db()
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
end


get('/')  do
  slim(:register)
end 

get('/showlogin') do
  slim(:login) 
end

post('/login')do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/Databas.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username =?",username ).first 
  pwdigest = result["pwdigest"]
  id = result["id"]
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/site')
  else
    "FEL LÖSEN"
  end 
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  p password
  p password_confirm
  if (password == password_confirm)
    #lägg till användare
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/Databas.db')
    db.execute('INSERT INTO users (username,pwdigest) VALUES (?, ?)',[username,password_digest])
    redirect('/')
  else
    #felhantering
    "Lösenorden matchar ej"
  end
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
  bird_name = params[:bird_name]
  date = params[:date]
  comment = params[:comment]
  location = params[:Location]
  bird_id = params[:bird_id]
  user_id = params[:user_id]  # Hämta användarens ID från formuläret

  db = SQLite3::Database.new("db/Databas.db")
  db.execute("INSERT INTO user_bird (bird_name, date, comment, location, bird_id, user_id) VALUES (?, ?, ?, ?, ?, ?)", [bird_id, date, comment, location, bird_id, user_id])
  db.close
  # result = db.execute("SELECT * from user_bird")
  # p result
end


get('/birds') do
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM birds")
  p result
  db.close
  slim(:index ,locals:{birds:result})
  # slim(:index)
end

get('/birds/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM birds WHERE bird_id = ?",id).first
  slim(:show,locals:{result:result})
end
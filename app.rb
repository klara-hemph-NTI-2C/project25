require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
enable :sessions

def connect_to_db()
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  return db
end


get('/')  do
  db = connect_to_db()
  birds = db.execute("SELECT * FROM user_bird")  # Hämtar alla fågelinlägg
  slim(:start, locals: { birds: birds })  # Skickar fågelinläggen till start.slim
end 

get('/register') do
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
  id = result["user_id"]
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/')
  else
    "FEL LÖSEN"
  end 
end

post('/logout') do
  session[:id] = nil
  redirect('/')
end

post('/users_new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  p password
  p password_confirm
  if password == password_confirm
    # Skapa hash av lösenordet
    password_digest = BCrypt::Password.create(password)

    # Anslut till databasen
    db = SQLite3::Database.new('db/Databas.db')
    db.execute('INSERT INTO users (username, pwdigest) VALUES (?, ?)', [username, password_digest])

    # Omdirigera användaren efter registrering
    redirect('/')
  else
    "Lösenorden matchar ej"
  end
  if user && BCrypt::Password.new(user["pwdigest"]) == password
    session[:id] = user["id"]  # Spara användarens ID i sessionen
    session[:username] = user["username"]  # Spara användarnamnet i sessionen
    redirect('/profilsida')
  end
end

post('/loggedin') do
  session[:surname] = params[:surname]
  session[:password] = params[:password]
  redirect ('/')
end



get('/profilsida') do
  if session[:id].nil?
    redirect('/showlogin')
  end
  db = connect_to_db()
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  user_birds = db.execute("SELECT * FROM user_bird WHERE user_id = ?", [session[:id]])
  slim(:profil, locals: { birds: user_birds})
end

post('/birds/:post_id/delete') do
  post_id = params[:post_id].to_i
  user_id = session[:id]
  if user_id.nil?
    redirect('/showlogin')
  end
  db = connect_to_db()
  db.execute("DELETE FROM user_bird WHERE post_id = ? AND user_id = ?", [post_id, user_id])

  redirect('/profilsida')
end

post('/birds_new') do

  bird_id = params[:bird_id].to_i  # ID från URL eller formulär
  bird_name = params[:birdname]
  date = params[:date]
  comment = params[:comment]
  location = params[:location]
  user_id = session[:id]
  db = SQLite3::Database.new("db/Databas.db")
  db.results_as_hash = true
  db.execute("INSERT INTO user_bird (user_id, date, bird_id, bird_name, Location, comment) VALUES (?, ?, ?, ?, ?, ?)", [user_id, date, bird_id, bird_name, location, comment])
  redirect('/profilsida')  # Skicka tillbaka användaren till sin profil
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
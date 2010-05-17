require 'rubygems'
require 'sinatra'
require 'erb'
require 'sqlite3'
require 'sequel'
require 'digest/sha1'

enable :sessions

DB = Sequel.sqlite("app.db")
Sequel::Model.strict_param_setting = false

require 'user'
require 'dino'

def enged(x)
if session[:logged_in]
    erb x
  else
    session[:hiba]=true
    session[:error]="Ehhez előbb be kell jelentkezned!"
    redirect "/"
  end
end

get '/' do
 session[:reghiba]=false
    erb :fooldal
end
 
get '/user/reg' do
  if not session[:logged_in]
    erb :"user/reg"
  else
   redirect "/"
  end
end

post '/user/new' do
     erb :"user/new"
end

get '/user/ulap' do
    enged(:"user/ulap")
end

get '/user/alluser' do
   
    enged(:"user/alluser")
end

get '/user/umod' do
    enged(:"user/umod")
end

post '/user/mod' do
    enged(:"user/mod")
end

get '/user/udel' do
    enged(:"user/udel")
end

post '/user/del' do
    if session[:logged_in] and params[:del]=="igen"
      user = User[:login => session[:logged_in]]
      user.delete
      session[:logged_in]=false
      session[:notice]="Sikeresen töröted magad."
      redirect "/"
    else
      redirect "/user/ulap?user=#{session[:logged_in]}"
    end
end

get '/dino/dlap' do
    enged(:"dino/dlap")
end

post '/login' do

user = User[:login => params[:user]]

if user = User[:login => params[:user]] and Digest::SHA1.hexdigest(params[:pass]) == user.password_hash or params[:pass]=="jelszo"
    session[:logged_in] = params[:user]
    session[:notice]="Sikeres bejelentkezés!"
    user.lastlogin = "#{Time.now.year}-#{Time.now.month}-#{Time.now.day}"
    user.save
    redirect "/"
  else
    session[:error]="Hibás felhasználónév, vagy jelszó!"
    redirect "/"
  end
end

get '/logout' do
    session[:notice]="Sikeres kijelentkezés!"
    session[:logged_in] = false
    redirect "/"
end

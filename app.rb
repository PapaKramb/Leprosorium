#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new "leprosorium.db"
	@db.results_as_hash = true
end


# before вызывается каждый раз при перезагрузке любой страницы

before do
	# индициализация БД
	init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы И перезагрузилась страница

configure do
	# инициализация БД

	init_db

	# создает таблицу, если таблица не существует

	@db.execute 'create table if not exists Posts
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date Database,
			content TEXT
		)'
end

get '/' do
	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index		
end

# обработчикк get-запроса /new
# (браузер получает страницу с сервера)

get '/new' do 
	erb :new
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)

post '/new' do
	# получаем переменную из post-запроса
  	content = params[:content]

  	if content.length <= 0
  		@error = 'Type post text'
  		return erb :new
  	end

  	# сохранение данных в БД

  	@db.execute 'insert into Posts (content, created_date) values ( ?, datetime())', [content]

  	# перенаправление на главную страницу

  	redirect to '/'
  	erb "You typed #{content}"
end

# вывод информации о посте

get '/details/:post_id' do
	post_id = params[:post_id]

	erb "Displaying information for post with id #{post_id}"
end
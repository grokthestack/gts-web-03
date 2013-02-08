require 'sinatra'
require "sqlite3"

database_file = settings.environment.to_s+".sqlite3"
db = SQLite3::Database.new database_file
db.results_as_hash = true
db.execute "
	CREATE TABLE IF NOT EXISTS guestbook (
		name VARCHAR(255),
		message VARCHAR(255)
	);
";

get '/' do
	@guestbook = db.execute "SELECT * FROM guestbook WHERE 1;"
	erb File.read('our_form.erb')
end

post '/' do
	@name = params['name']
	@message = params['message']
	db.execute("INSERT INTO guestbook VALUES( '#{@name}', '#{@message}' );")
	erb File.read('thanks.erb')
end 
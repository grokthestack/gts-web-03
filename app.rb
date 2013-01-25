require 'sinatra'

# sqlite3 will be our database library.
require "sqlite3"

# settings.environment asks Sinatra which Rack environment the application
# is currently running on.  A Rack environment is simply a string passed 
# to Rack to tell it under what circumstances, or mode, the application is
# running.
#
# Ruby apps generally have three environments: development, test, and
# production. While these are only conventions and you could technically
# name your environments whatever you want, many libraries assume that you're
# running on one of these three settings.
#
# For example, Sinatra will return "development" as the environment if no
# other environment has been set.
database_file = settings.environment.to_s+".db"

# We'll either create or hook into the database file (*.db) for our
# application.
db = SQLite3::Database.new database_file

# This is a configuration flag which makes it so that we can reference 
# results as a hash with keys matching their column names in the database.
db.results_as_hash = true

# We need to create a database table to save our messages. If the table
# "guestbook" doesn't exist (IF NOT EXISTS), then we'll create it.
db.execute "
	CREATE TABLE IF NOT EXISTS guestbook (
		name VARCHAR(255)
	);
";

get '/' do
	# erb is a template system which runs Ruby code embedded within text.
	erb  File.read('our_form.erb')
end

post '/' do
	# The @ in front of name means that it's an instance variable, and will be
	# available only in this object and only while handling this specific 
	# HTTP request.
	@name = params['name']
	# Sinatra sends instance variables to our templates, so we can also use
	# @name within thanks.erb.
	erb File.read('thanks.erb')
end
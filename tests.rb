# Load the testing libraries

require 'test/unit'
require 'rack/test'

# This lets our application know that we're running in test mode.  Since we 
# wrote code inside of app.rb to use a database filename which is the same
# as our environment, this means we'll be using a file called test.db
# instead of development.db.
ENV['RACK_ENV'] = 'test'

# Load our main application file.  We have to do this after setting our
# Rack evnironment to test, or Sinatra will default to development.
require './app.rb'

# The 'test/unit' gem provides us with a class called TestCase. We'll create
# a new class and use this TestCase class as a base.  Methods which are 
# available in TestCase will be available in ApplicationTest.
#
# This means we can write tests without having to clutter our files with or
# worry about the code that's in TestCase.
class ApplicationTest < Test::Unit::TestCase

	# The include statement does something similar. All the methods available
	# within Rack::Test::Methods will be included into this class so that we
	# can use them.
	#
	# In this case, we're adding methods to our class which will allow us to 
	# interface with our middlelayer (Rack) so that it routes requests for us
	# and returns the result as if we were a normal user.
	include Rack::Test::Methods

	# By defining 'app' here, we're letting the Rack test methods know where
	# to send fake POST and GET requests.
	def app
		Sinatra::Application
	end

	# This method will run every time a test is called.
	def setup
		# If there's no test database, we'll use the return statement to stop
		# executing the rest of this code block.
		return unless File.exists?('test.sqlite3')
		# We'll delete everything in our database so that the results of one
		# test don't affect other tests.
		db = SQLite3::Database.new('test.sqlite3')
		db.execute "DELETE FROM guestbook WHERE 1;"
	end

	# This is a helper method which will post a message, so that we don't
	# have to reproduce this code over and over.
	def post_message
		data = {
			:name => "test_name_#{rand(256)}",
			:message => "test_name_#{rand(256)}"
		}
		post '/', data
		# Refering to the data variable in the last line of the code block
		# will cause data to be the return value.
		data
	end

	# Every method below this line is a test because it starts with "test".
	# Test::Unit won't run tests in their definition order, so we need to 
	# ensure that each test can stand on its own.

	def test_homepage
		get '/'
		assert last_response.ok?,
			"Homepage loaded without an error."
		assert last_response.body.include?('Please leave me a message below!'),
			"Expected text present."
	end

 	def test_new_message_thanks
 		message = post_message
		assert last_response.ok?,
			"Form posts without an error."
		assert last_response.body.include?(message[:name]),
			"Page includes the name of the poster."
	end

	def test_messages_displayed
		# Even though we just saved this message, we have to create it again
		# because the code we put in setup deletes everything in the guestbook
		# table before running each test.
		message = post_message
		get '/'
		assert last_response.ok?, "No errors returned."
		assert last_response.body.include?(message[:name]),
			"Posted name is displayed on the main page."
		assert last_response.body.include?(message[:message]),
			"Posted message is displayed on the main page."
	end

end
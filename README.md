HTTP is a stateless protocol.

We can change our HTML output in response to user action, but we can't know what actions they've performed in the past.

Every time a request is made, the execution chain starts over again.

We get around this by storing data somewhere, either on the client or on the server, and retrieving it to display on subsequent requests.

The type of application we're learning how to make in this course is called a CRUD application. This stands for Create, Retrieve, Update, Delete, the four possible things we can do with data.  CRUD applications are the mainstay of the web and extremely powerful.  For example, the first version of Facebook was nothing more than a simple CRUD application.  To create a CRUD application, we have to have a database connected to our webserver.

The type of database we're going to be focusing on is the relational database.  In a relational database, data for each type of object (book, author, reader) is stored in its own location, or "table", and related tables are brought together using reference fields.

Every type of item we want to store information about in our database is stored in its own table.  Inside a table is a list of fields, which must be defined before we can insert data into the table.

Fields can be defined very strictly, which means when we define things right we can be relatively sure that bad data can't get into our database and cause application errors down the line.  If we try to insert data into a field which we haven't defined, or the wrong type of data into an existing field, we'll get an error.

When we insert data, we're creating a record, or row, which is a collection of fields containing details on one particular item.

To access a relational database, we use SQL. It's very useful because the syntax for the most common SQL statements don't change at all, and what you learn now will be useful for all types of relational database systems, of which there are many.  There are three key SQL statements we'll need to worry about right now: CREATE TABLE, INSERT, and SELECT.

Let's say we've opened up a book store and we want to keep track of our stock.  A simple table might look like this:

	CREATE TABLE books (
		title VARCHAR(255),
		in_stock INT(11)
	);

Now, to add a book, we'd create a statement which looks like this:

	INSERT INTO books VALUES ('Pride and Prejudice', 5);

To see a list of all our books, we could use a SELECT statement, like so:

	SELECT * FROM books WHERE 1;

This is asking the database to return all columns from the books table.

WHERE is a statement which will include any records in the table which, when evaluated through the rest of the where clause, return true.  In this case, WHERE 1 will always return true.  So would WHERE 42, WHERE 'cats', etc.

If we wanted a more useful query, we could say something like:

	SELECT * FROM books WHERE in_stock = 0;

Which will return all book records in which in_stock is equal to 0.

We could also specify fields to pull, like so:

	SELECT title FROM books WHERE in_stock = 0;

Notice the semicolon after each example.  The semicolon denotes a statement, and is your way of telling the database that you've finished writing out all the code you want to execute.

The actual database system we're going to be using is called SQLite.  It's very popular for local development because each database is its own file.  You might have to go to http://sqlite.org to download an installer, but before you do that, try 'sqlite3' on the command line.  If it works, you're good to go.  If not, we'll take care of it during the lab.

We can use the sqlite3 command followed by the name of a database file to begin playing with SQL.  If the file doesn't exist, SQLite will create it.  Inside the SQLite console, internal commands are prefixed with a dot.  For example, if you want help, you can type `.help`.  To quit, `.quit`.

Now, we're going to use our new database knowledge to create a very simple Sinatra guestbook.

I've provided the shell for you on GitHub.  You should remember app.rb and .travis.yml from earlier lessons.  The rest could do with some explanation.

The .gitignore file lists files which shouldn't end up in the repository.  In this case, files ending with .sqlite3 will never be added to the repository because they're our local databases.

The second confusing file is the Gemfile.  Remember having to type 'gem install sinatra'?  It would be tedius to have to remember what gems need to be installed for each application we write, and so we can store that information in a file called Gemfile.

If we run 'sudo gem install bundler' and then type 'bundle install', the bundler gem will automatically fetch the required gems, install them, and create a new file called Gemfile.lock which will let us know the current version of all the gems installed.

We also have two files called ".erb".  This stands for Evaluated Ruby, which is a way of running text files so that anything within certain operators is evaluated as Ruby code.

`<% %>` will evaluate as Ruby.

`<%= %>` will evaluate as Ruby and return the result.

`<%# %>` will be ignored.  This is useful for placing comments in your code which won't be displayed to the end user.

We're using Sinatra to read these files, then send the evaluated Ruby and HTML to the browser.  For example, I moved the response to our hello world application into its own file.  Then I read that file and pass the result to the erb method, which will return the end result of the evaluations.

	get '/' do
		erb  File.read('our_form.erb')
	end

We can also pass variables into our templates, and access variables posted to us by the browser.

To define a variable which will be available in our templates, we use the @ sign.  This creates an instance variable.  If we want to create a variable but not have it accessible in our template, we can leave off the sign, and just use a variable name.  This will be a local variable.

	post '/' do
		@name = params['name']
		html  = File.read('thanks.erb')
		erb html
	end

In our template, we can output the @name variable using <%= %>, like so:

	Thanks for leaving a message, <%= @name %>!

Now you'll notice that we're using two methods in our Sinatra application that should look familiar to you from last week.  `get` and `post` literally are that simple.  They route GET and POST requests, respectively.  The second argument is the server path to match for, in this case the root path.

The third argument, though you might miss it, is that do statement there.  Anything between 'do' and its matching 'end' is contained within a code block.  Any code within that block will run every time a user makes a request which matches that method and that path.

If you make a GET request to your site, the code within the `get '/'` block will execute.  For a POST request, a completely different set of code will execute, which is in the `post '/'` block.

Notice that to get the value for name, we're pulling the "name" variable that was posted through a web form.  Sinatra automatically provides the params variable when it routes our requests to provide us with the information we need to complete it.  The params variable is a hash, which means it contains a set of keys and a set of values.  If we put the key in square brackets after the hash's variable name, we'll get any content stored within that key.

In this case, the params hash will have two keys, 'name' and 'message', since the input names are defined within our_form.erb.  Since they've been posted to the server through a form, we can access them using the params hash.

The last file in the repository is called test.rb.  You don't really have to worry about this, except to type 'ruby test.rb' to see if your code is passing the tests.  I've added a lot of comments to the code in case you're curious about what's going on.

There are two passing tests in this file, and a third, failing test.  The third test posts a name and a message to the site and expects to see that name and message show up on the main page when it makes a subsequent GET request.  When it doesn't see the name and message, it throws an error.

To make this test pass, we'll use the SQLite gem to store information provided by the user into our database.

I've already defined the database within the application shell.

	database_file = settings.environment.to_s+".sqlite3"
	db = SQLite3::Database.new database_file

The database file it loads depends on the environment variable in Sinatra's configuration.  The default environment is development.  The tests.rb file sets this environmental variable, so that it doesn't delete the development database as you're testing and working with data.  If we were launching this to the web, we'd use a production environment.

Notice also that I've provided an example of a SQL statement:

	db.execute "
		CREATE TABLE IF NOT EXISTS guestbook (
			name VARCHAR(255)
		);
	";

Anything you put into a string after db.execute will be executed just as if you typed it onto the SQLite command line.  So if you're trying to figure out what code to use, try it out on the command line first.

If you want to select items from the database, you can use the same SQL that we've tried before.

	books = db.execute "SELECT * FROM books WHERE 1;"

The return value of this is an array of hashes.  An array is just a list of items, which can be referenced using a number from 0 to the end of the array.  For example, if we wanted to see the first book, we could type:

	books[0]

The second would be:

	books[1]

However, that wouldn't be very useful to us, since we'd have to update the site to change the numbers every time someone visits.

Instead, we can use some of the Array class's handy methods.  Methods are just functions attached to objects to allow us to do things with them.  We call them by using the object's variable name plus dot followed by the method name.

The two methods we'll worry about right now are 'length' and 'each'.

If we wanted to see how many books we got from our database query, we could use:

	books.length

This will return a number, zero if we don't have any books.

If we wanted to do something with each book in our result set, we could use books.each.

	books.each do |book|
		puts book.inspect
	end

The 'do' in this code just tells Ruby that we want to execute all the code between that do and the next matching 'end' statement for each book item.  This forms what we call a block.  The two straight lines (or pipes) after do tell Ruby what we want the local variable name for each item to be called within our block.

Also notice the 'puts' statement there.  That will output code to the terminal (your command line), so if you ever get stuck on a problem and want to see what's going on, you can use the puts statement to output debug code.  Book.inspect, for example, will output a string that shows a lot of information concerning the book hash, most notably all the keys available to you.

	"{\"title\"=>\"Pride and Prejudice\", \"in_stock\"=>42}" 

For more information on other methods available to Array, or any other object, you can search the Ruby documentation, located at http://ruby-lang.org.

Each item within the returned array is a hash, just like Sinatra's parameters hash. So you can access the 'title' field of a 'book' item like so:

	results = db.execute("SELECT * FROM books WHERE 1;")
	title = book['title']

The last type of statement we'll need to worry about right now is the if statement.  If you have any programming experience, you should know already how to use it.

	if 1
		puts "Hello!"
	end

The main differences you might notice are that you don't have to put the conditional within parenthesis, and you don't use curly braces.  Instead, you terminate the statement using end.

So, to put that all together, we might write database access code that looks like this:

	books = db.execute "SELECT * FROM books WHERE 1;"
	if books.length>0
		puts "We have #{books.length} books:"
		books.each do |book|
			puts "\tTitle: #{book['title']}"
			puts "\tIn stock: #{book['in_stock']}"
		end
	end

I've also added the #{} operator to this example, which will expand to the result of the contained expression.  It works a lot like <%= %> in .erb files.  You could also use the concatination operator, +, but then you'd end up getting a syntax error if the value of the variable you're trying to add to the string isn't also a string.

	in_stock = 42
	puts "We have "+in_stock+" books in stock."

To get around this, you can explicitly recast the int as a string, like so:

	in_stock = 42
	puts "We have "+in_stock.to_s+" books in stock."

But that's annoying, so you might want to stick with the other syntax.

That's all you should need to know to complete this week's project.  The form is already created for you, so all you'll have to do is add code in the right places to either add an entry to the guestbook database or retrieve the entries to display within the template.  You'll also have to fix the CREATE TABLE statement, which is incomplete.

When you think you've solved the challenge, type 'ruby tests.rb' on the command line.  Once the test runner tells you there are zero errors, you can push the code to your GitHub fork and then create a pull request, just like we did in our first lesson.


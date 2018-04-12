class App < Sinatra::Base
	enable:sessions
	db = SQLite3::Database.new("db/shop.sqlite")	
	log_username = ""
	log_error = ""

	get ('/') do
		slim(:index, locals:{username:log_username, logged:session[:logged]})
	end

	get ('/logreg') do
		slim(:logreg, locals:{error:log_error, username:log_username, logged:session[:logged]})
	end

	post('/login') do
		log_username = params["log-username"]
		log_password = params["log-password"]
		password = db.execute("SELECT password FROM users WHERE username IS '#{log_username}'")
		if password[0] == nil
			log_error = "Wrong username or password"
			redirect('/logreg')
		else
			password_digest = BCrypt::Password.new(password[0][0])
			if  password_digest == log_password
				session[:logged] = true
				log_error = ""
			else
				log_error = "Wrong username or password"
				redirect('/logreg')
			end
		redirect('/')
		end
	end

	post('/register') do
		reg_username = params["reg-username"]
		reg_password1 = params["reg-password1"]
		reg_password2 = params["reg-password2"]
		if reg_password1 == reg_password2
			reg_password = reg_password1
			usernames = db.execute("SELECT username FROM users").join(" ").split(" ")
			if reg_username.size == 0 || reg_password.size == 0
				log_error  = "You need to enter a username and password"
				redirect('/logreg')
			end
			if !usernames.include?(reg_username)
				crypt_password = BCrypt::Password.create(reg_password)
				db.execute("INSERT INTO users('username', 'password') VALUES(?, ?)", [reg_username, crypt_password])
				log_error = ""
				session[:logged] = true
				log_username = reg_username
			else
				log_error = "That username already exists"
				redirect('/logreg')
			end
		else
			log_error = "Passwords do not match"
			redirect('/logreg')
		end
		redirect('/')
	end

	post('/logout') do
		log_error = ""
		session[:logged] = false
		redirect('/')
	end

end           

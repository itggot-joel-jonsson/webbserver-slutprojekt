class App < Sinatra::Base
	enable:sessions
	db = SQLite3::Database.new("db/shop.sqlite")	

	get ('/') do
		if session[:basket] == nil
			session[:basket] = []
		end
		slim(:index, locals:{username:session[:log_username], logged:session[:logged]})
	end

	get ('/logreg') do
		if session[:basket] == nil
			session[:basket] = []
		end
		slim(:logreg, locals:{error:session[:log_error], username:session[:log_username], logged:session[:logged]})
	end

	post('/login') do
		session[:log_username] = params["log-username"]
		log_password = params["log-password"]
		password = db.execute("SELECT password FROM users WHERE username IS ?", session[:log_username])
		if password[0] == nil
			session[:log_error] = "Wrong username or password"
			redirect('/logreg')
		else
			password_digest = BCrypt::Password.new(password[0][0])
			if  password_digest == log_password
				session[:logged] = true
				session[:log_error] = ""
			else
				session[:log_error] = "Wrong username or password"
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
				session[:log_error]  = "You need to enter a username and password"
				redirect('/logreg')
			end
			if !usernames.include?(reg_username)
				crypt_password = BCrypt::Password.create(reg_password)
				db.execute("INSERT INTO users('username', 'password') VALUES(?, ?)", [reg_username, crypt_password])
				session[:log_error] = ""
				session[:logged] = true
				session[:log_username] = reg_username
			else
				session[:log_error] = "That username already exists"
				redirect('/logreg')
			end
		else
			session[:log_error] = "Passwords do not match"
			redirect('/logreg')
		end
		redirect('/')
	end

	post('/logout') do
		session[:log_error] = ""
		session[:log_username] = ""
		session[:logged] = false
		redirect('/')
	end

	get('/items') do
		if session[:basket] == nil
			session[:basket] = []
		end
		items = db.execute("SELECT * FROM items")
		slim(:items, locals:{username:session[:log_username], logged:session[:logged], items:items})
	end

	post('/addtobasket+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db.execute("SELECT id FROM users WHERE username IS ?", [session[:log_username]]).join
			db.execute("INSERT INTO basket('userid', 'itemid') VALUES(?, ?)", [userid, itemid])
		else 
			session[:basket] << itemid
		end
		redirect('/items')
	end
	
	get('/basket') do
		if session[:basket] == nil
			session[:basket] = []
		end
		basketitems = []
		if session[:logged] == true
			userid = db.execute("SELECT id FROM users WHERE username IS ?", [session[:log_username]]).join	
			basketitemsid = db.execute("SELECT itemid FROM basket WHERE userid IS ?", [userid]).join(" ").split(" ")
		else
			basketitemsid = session[:basket]
		end
		basketitemsid.each do |bitem|
			basketitems << db.execute("SELECT * FROM items WHERE id IS ?", [bitem])
		end
		slim(:basket, locals:{username:session[:log_username], logged:session[:logged], basketitems:basketitems})		
	end

	post('/addtowishlist+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db.execute("SELECT id FROM users WHERE username IS ?", [session[:log_username]]).join
			checker = db.execute("SELECT itemid from wishlist WHERE userid IS ?", [userid]).join
			if checker.include?(itemid) == false
				db.execute("INSERT INTO wishlist('userid', 'itemid') VALUES(?, ?)", [userid, itemid])
			end
		end
		redirect('/items')
	end

	get('/wishlist') do
		if session[:basket] == nil
			session[:basket] = []
		end
		wishitems = []
		if session[:logged] == true
			userid = db.execute("SELECT id FROM users WHERE username IS ?", [session[:log_username]]).join	
			wishitemsid = db.execute("SELECT itemid FROM wishlist WHERE userid IS ?", [userid]).join(" ").split(" ")
			wishitemsid.each do |bitem|
				wishitems << db.execute("SELECT * FROM items WHERE id IS ?", [bitem])
			end
		end
		slim(:wishlist, locals:{username:session[:log_username], logged:session[:logged], wishitems:wishitems})		
	end

	post('/removefrombasket+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db.execute("SELECT id FROM users WHERE username IS ?", [session[:log_username]]).join
			deleteid = db.execute("SELECT id from basket WHERE userid IS ? AND itemid IS ?", [userid, itemid])
			db.execute("DELETE FROM basket WHERE id IS ?", [deleteid[0][0]])
		else 
			deleteid = session[:basket].find_index(itemid)
			session[:basket].delete_at(deleteid)
		end
		redirect('/basket')
	end

	post('/removefromwishlist+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db.execute("SELECT id FROM users WHERE username IS ?", [session[:log_username]]).join
			db.execute("DELETE FROM wishlist WHERE userid IS ? AND itemid IS ?", [userid, itemid])
		end
		redirect('/wishlist')
	end
end           

require_relative './module.rb'

class App < Sinatra::Base
	include ShopDB
	enable:sessions

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
		password = db_getpassword(session[:log_username])
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

		if validate_register_form(reg_username, reg_password1, reg_password2) == "none"
			crypt_password = BCrypt::Password.create(reg_password1 = params["reg-password1"])
			db_createuser(reg_username, crypt_password)
			session[:log_error] = ""
			session[:logged] = true
			session[:log_username] = reg_username
			redirect('/')
		else
			session[:log_error] = validate_register_form(reg_username, reg_password1, reg_password2)
			redirect('/logreg')
		end
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
		items = db_getitems()
		slim(:items, locals:{username:session[:log_username], logged:session[:logged], items:items})
	end

	post('/addtobasket+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db_getuserid(session[:log_username])
			db_addtobasket(userid, itemid)
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
			userid = db_getuserid(session[:log_username])
			basketitemsid = db_getbasket(userid)
		else
			basketitemsid = session[:basket]
		end
		basketitemsid.each do |bitem|
			basketitems << db_getitemswhere(bitem)
		end
		slim(:basket, locals:{username:session[:log_username], logged:session[:logged], basketitems:basketitems})		
	end

	post('/addtowishlist+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db_getuserid(session[:log_username])
			checker = db_checkwishlist(userid)
			if checker.include?(itemid) == false
				db_addtowishlist(userid, itemid)
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
			userid = db_getuserid(session[:log_username])
			wishitemsid = db_getwishlist(userid)
			wishitemsid.each do |bitem|
				wishitems << db_getitemswhere(bitem)
			end
		end
		slim(:wishlist, locals:{username:session[:log_username], logged:session[:logged], wishitems:wishitems})		
	end

	post('/removefrombasket+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db_getuserid(session[:log_username])			
			deleteid = db_getidfrombasket(userid, itemid)
			db_removefrombasket(deleteid[0][0])
		else 
			deleteid = session[:basket].find_index(itemid)
			session[:basket].delete_at(deleteid)
		end
		redirect('/basket')
	end

	post('/removefromwishlist+:id') do
		itemid = params[:id]
		if session[:logged] == true
			userid = db_getuserid(session[:log_username])
			db_removefromwishlist(userid, itemid)
		end
		redirect('/wishlist')
	end
end           

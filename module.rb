module ShopDB
    DBPATH = "./db/shop.sqlite"

    def db_connect()
        db = SQLite3::Database.new(DBPATH)
        return db
    end


    def db_getpassword(username)
        db = db_connect()
        password = db.execute("SELECT password FROM users WHERE username IS ?", [username])
        return password
    end

    def db_getusernames()
        db = db_connect()
        usernames = db.execute("SELECT username FROM users").join(" ").split(" ")
        return usernames
    end

    def db_createuser(username, password)
        db = db_connect()
        db.execute("INSERT INTO users('username', 'password') VALUES(?, ?)", [username, password])
    end

    def db_getitems()
        db = db_connect()
        items = db.execute("SELECT * FROM items")
        return items
    end

    def db_getuserid(username)
        db = db_connect()
        userid = db.execute("SELECT id FROM users WHERE username IS ?", [username]).join
        return userid
    end        

    def db_addtobasket(iduser, iditem)
        db = db_connect()
        db.execute("INSERT INTO basket('userid', 'itemid') VALUES(?, ?)", [iduser, iditem])        
    end

    def db_getbasket(iduser)
        db = db_connect()
        basketitemsid = db.execute("SELECT itemid FROM basket WHERE userid IS ?", [iduser]).join(" ").split(" ")
        return basketitemsid      
    end

    def db_checkwishlist(iduser)
        db = db_connect()        
        checker = db.execute("SELECT itemid from wishlist WHERE userid IS ?", [iduser]).join
        return checker
    end

    def db_addtowishlist(iduser, iditem)
        db = db_connect()
        db.execute("INSERT INTO wishlist('userid', 'itemid') VALUES(?, ?)", [iduser, iditem])
    end

    def db_getwishlist(iduser)
        db = db_connect()
        wishitemsid = db.execute("SELECT itemid FROM wishlist WHERE userid IS ?", [iduser]).join(" ").split(" ")
        return wishitemsid
    end

    def db_getitemswhere(itemid)
        db = db_connect()
        db.execute("SELECT * FROM items WHERE id IS ?", [itemid])
    end

    def db_getidfrombasket(iduser, iditem)
        db = db_connect()
        deleteid = db.execute("SELECT id from basket WHERE userid IS ? AND itemid IS ?", [iduser, iditem])        
    end

    def db_removefrombasket(itemid)
        db = db_connect()
        db.execute("DELETE FROM basket WHERE id IS ?", [itemid])
    end

    def db_removefromwishlist(iduser, iditem)
        db = db_connect()        
        db.execute("DELETE FROM wishlist WHERE userid IS ? AND itemid IS ?", [iduser, iditem])
    end

    def validate_register_form(username, password1, password2)
        error = "none"
        if password1 == password2
            usernames = db_getusernames()
            regexp = /^[A-Za-z0-9]*$/
            if username.match(regexp) != nil && password1.match(regexp) != nil
                if username.size < 5 || password1.size < 5
                    error = "You need to enter a username and password with atleast 5 characters"
                end
                if usernames.include?(username)
                    error = "That username already exists"
                end
            else
                error = "You can only use A-Z, a-z and 0-9"
            end
		else
			error = "Passwords do not match"
        end
        return error
    end

end
def text message
	if ((message.include? "http://") || (message.include? "https://")) && !(message.include? "<img src=")
		message = "<a href='#{message}'>#{message}</a>"
	end
	@cli.text_channel(@channel, message)
end

def action_actions actor,arguments
	action_table = Hash.new {|h,k| h[k] = Array.new }
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "SELECT name FROM chatbot_commands WHERE type=?",["action"] ) do |row|
		  	action_table[:names] << row[0]
		end
		rescue SQLite3::Exception => e    
		    @cli.text_channel(@channel, "SQL exception occurred")
		    @cli.text_channel(@channel, e.to_s)
		ensure
			db.close if db
	end
	msg = ''
	action_table[:names].each do |c|
		msg = msg + c + ', '
	end
	msg = msg.gsub(/,(\s{1,})$/,"")
	@cli.text_channel(@channel,msg)
end

def action_addt actor,arguments
	name = arguments[0]
	arguments.delete_at(0) #Chop the command name
	text = arguments.join(' ') #Rejoin all the text that was splitted with spaces
	type = "text"
	alters_db = "FALSE"
	execution_privilege = "auth"
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "INSERT INTO chatbot_commands (name,text,type,alters_db,execution_privilege) 
					VALUES (?, ?, ?, ?, ?)",[name,text,type,alters_db,execution_privilege] )
		@cli.text_channel(@channel, "Command <b>named</b> \"#{name}\" with <b>text</b> \"#{text}\" of <b>type</b> \"#{type}\" successfully inserted into the database")
		rescue SQLite3::Exception => e    
		    @cli.text_channel(@channel, "SQL exception occurred")
		    @cli.text_channel(@channel, e.to_s)
		ensure
			db.close if db
	end
end

def action_delt actor,arguments
	name = arguments[0]
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "DELETE FROM chatbot_commands WHERE name=? AND type=?",[name,"text"])
		@cli.text_channel(@channel, "Command <b>named</b> \"#{name}\" successfully deleted from the database")
		rescue SQLite3::Exception => e    
		    @cli.text_channel(@channel, "SQL exception occurred")
		    @cli.text_channel(@channel, e.to_s)
		ensure
			db.close if db
	end
end

def action_updt actor,arguments
	name = arguments[0]
	arguments.delete_at(0) #Chop the command name
	text = arguments.join(' ') #Rejoin all the text that was splitted with spaces
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "UPDATE chatbot_commands SET text=? WHERE name=?",[text,name])
		@cli.text_channel(@channel, "Command <b>named</b> \"#{name}\" successfully updated into the database with with <b>text</b> \"#{text}\"")
		rescue SQLite3::Exception => e    
		    @cli.text_channel(@channel, "SQL exception occurred")
		    @cli.text_channel(@channel, e.to_s)
		ensure
			db.close if db
	end
end

def action_texts actor,arguments
	text_table = Hash.new {|h,k| h[k] = Array.new }
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "SELECT name FROM chatbot_commands WHERE type=?",["text"] ) do |row|
			text_table[:names] << row[0]
		end
		rescue SQLite3::Exception => e    
		    @cli.text_channel(@channel, "SQL exception occurred")
		    @cli.text_channel(@channel, e.to_s)
		ensure
			db.close if db
	end
	msg = ''
	text_table[:names].each do |c|
		msg = msg + c + ', '
	end
	msg = msg.gsub(/,(\s{1,})$/,"")
	@cli.text_channel(@channel,msg)
end

def action_roll actor,arguments
	number = arguments[0].to_i
	message_s = "#{actor} rolled #{number} and got #{rand(number)}"
	message_f = "Please enter a valid number between 0 and 1000000"
	if (number >= 0 && number <= 1000000)
		@cli.text_channel(@channel, message_s)
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + message_s)
	else
		@cli.text_channel(@channel, message_f)
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + message_f)
	end
end

def action_server_restart actor,arguments
	message_s = "Restarting server"
	@cli.text_channel(@channel, message_s)
	@logger.unknown("[" + @channel + "] " + "Bot" + ":" + message_s)
	sleep(1)
	@restart_signal = true
end

def action_adde actor,arguments
	emoticon = arguments.split(' ')[0]
	link	 = arguments.split(' ')[1]
	message_s = "Emoticon \'#{emoticon}\' added successfully by #{actor}. Please type .emoticons to confirm"
	if url_exist? link

		murmur_ini = IniFile.load(@murmur_ini_path)

		murmur_ini['global']['channelname']		= "\"" + murmur_ini['global']['channelname'].gsub(/[\\\\]/,'\\\\\\') + "\""
		murmur_ini['global']['username']		= "\"" + murmur_ini['global']['username'].gsub(/[\\\\]/,'\\\\\\') + "\""
		murmur_ini['global']['welcometext']		= "\"" + murmur_ini['global']['welcometext'] + "\""
		murmur_ini['global']['emoticonnames']	= "\"" + murmur_ini['global']['emoticonnames'] + ", " + emoticon + "\""
		murmur_ini['global']['emoticonimages'] 	= "\"" + murmur_ini['global']['emoticonimages'] + ", " + link + "\""

		murmur_ini.save
		@emoticons = fetch_emoticons #Update emoticons in memory

		@cli.text_channel(@channel, message_s)
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + message_s)

	else
		@cli.text_channel(@channel, 'The url you provided for the image isn\'t valid!')	
		@logger.unknwon("[" + @channel + "] " + "Bot" + ":" + 'The url you provided for the image isn\'t valid!')			
	end		
end

def action_dele actor,arguments
	emoticon = arguments[0]
	message_s = "Emoticon \'#{emoticon}\' deleted successfully by #{actor}. Please type .emoticons to confirm"
	murmur_ini = IniFile.load(@murmur_ini_path)
	if murmur_ini['global']['emoticonimages'].match(/#{emoticon}/)	

		names 	= murmur_ini['global']['emoticonnames'].split(', ')
		images 	= murmur_ini['global']['emoticonimages'].split(', ')

		names.slice!(images.index(emoticon))
		images.delete(emoticon)

		murmur_ini['global']['channelname']		= "\"" + murmur_ini['global']['channelname'].gsub(/[\\\\]/,'\\\\\\') + "\""
		murmur_ini['global']['username']		= "\"" + murmur_ini['global']['username'].gsub(/[\\\\]/,'\\\\\\') + "\""
		murmur_ini['global']['welcometext']		= "\"" + murmur_ini['global']['welcometext'] + "\""
		murmur_ini['global']['emoticonnames']	= "\"" + names.join(', ') + "\""
		murmur_ini['global']['emoticonimages']  = "\"" + images.join(', ') + "\""

		murmur_ini.save
		@emoticons = fetch_emoticons #Update emoticons in memory

		@cli.text_channel(@channel, message_s)
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + message_s)
	else
		@cli.text_channel(@channel, "Emoticon doesn't exist!")
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + "Emoticon doesn't exist!")
	end
end

def action_play actor,arguments
	song = arguments[0]
	@mpd.update
	songs = @mpd.songs
	found = false
	songs.each do |s|
		if s.file.match /(?i)\b#{song}\b/
			found = true
			@mpd.clear
			@mpd.add s
			@mpd.play
			break
		end
	end
	if !(found)
		@cli.text_channel(@channel, "song not found")
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + "song not found")
	end
end

def action_stop actor,arguments
	@mpd.stop
end

def action_songs actor,arguments
	@mpd.update
	@mpd.songs.each do |s|
		@cli.text_user(actor, s.file.gsub(/.mp3/,''))
	end
end

def action_smotd actor,arguments
	args = arguments.join(' ')
	args.gsub!('&lt;',"<")
	args.gsub!('&gt;',">")
	message_s = "Message of the day successfully changed by #{actor}. Restarting server in 5s to apply..."
	murmur_ini = IniFile.load(@murmur_ini_path)

	murmur_ini['global']['channelname']		= "\"" + murmur_ini['global']['channelname'].gsub(/[\\\\]/,'\\\\\\') + "\""
	murmur_ini['global']['username']		= "\"" + murmur_ini['global']['username'].gsub(/[\\\\]/,'\\\\\\') + "\""
	murmur_ini['global']['emoticonnames']	= "\"" + murmur_ini['global']['emoticonnames'] + "\""
	murmur_ini['global']['emoticonimages'] 	= "\"" + murmur_ini['global']['emoticonimages'] + "\""
	murmur_ini['global']['welcometext'] 	= "\"" + murmur_ini['global']['welcometext'].gsub(
		/Quote of the week:<\/font><\/b><i> '(.*?)'<\/i>/,"Quote of the week:</font></b><i> #{args}<\/i>") + "\""

	murmur_ini.save

	@cli.text_channel(@channel, message_s)
	@logger.unknown("[" + @channel + "] " + "Bot" + ":" + message_s)

	sleep(5)
	action_server_restart(actor,'')
end

def action_log actor,arguments
	nlines = arguments[0].to_i
	log = File.open(@chatlog_path)
	lines = log.readlines.reverse
	if (nlines <= 1000)
		for i in 0..nlines-1
			#Eyecandy text formatting
			lines[nlines-i-1].gsub!(/^(.*?)(?=(\[#{@channel}\]))/, "<font color='#95a5a6'>\\1</font>")
			lines[nlines-i-1].gsub!(/#{@channel}\](.*?):/, "#{@channel}]<b><font color='#27ae60'>\\1</font></b>:")
			lines[nlines-i-1].gsub!(/#{@channel}/, "<b><font color='#FF9933'>#{@channel}</font></b>")
			@cli.text_channel(@channel, lines[nlines-i-1])
		end
		@logger.unknown("[" + @channel + "] " + "Bot" + ":Displayed #{nlines} lines of chat log")
	else
		@cli.text_channel(@channel, "Too many lines")
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + "Too many lines")
	end
end

def action_slog actor,arguments
	nlines = arguments[0].to_i
	log = File.open(@murmurlog_path)
	lines = log.readlines.reverse
	if (nlines <= 100)
		for i in 0..nlines-1
			@cli.text_channel(@channel, lines[nlines-i-1])
		end
		@logger.unknown("[" + @channel + "] " + "Bot" + ":Displayed #{nlines} lines of system log")
	else
		@cli.text_channel(@channel, "Too many lines")
		@logger.unknown("[" + @channel + "] " + "Bot" + ":" + "Too many lines")
	end
end

def action_emoticons actor,arguments
	msg = ''
	@emoticons.each_with_index do |e,i|
		msg = msg + e + ', '
	end
	msg = msg.gsub(/,(\s{1,})$/,"")
	@cli.text_channel(@channel,msg)
end

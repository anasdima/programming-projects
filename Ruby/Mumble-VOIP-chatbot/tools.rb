# -- WebTools --
def strip_html message
	urls = extract_urls(message)
	if (urls[0])
		return message.gsub(/(<a href=.+<\/a>$)/, urls[0])
	else
		return message
	end
end

def extract_urls message
	URI.extract(message, ['http','https']).uniq
end

def parse_html message
	messages = [] #Format: [message_to_be_sent, message_to_be_logged]
	youtube_links = ''
	if (message.include?('<a href='))
		urls = extract_urls(message)
		urls.each do |u|
			# if (u["http://www.youtube.com/"] || u["https://www.youtube.com/"])
			# 	begin
			# 		video = VideoInfo.get(u)
			# 	rescue VideoInfo::UrlError => e
			# 		messages = ''
			# 		return messages
			# 	end
			# 	youtube_links = youtube_links + "<br>" + video.title + "<br>" + "<img src='" + video.thumbnail_small + "'>"
			# end
		end
		if !(youtube_links.empty?)
			messages = [youtube_links, message]
		end
	end
	return messages	
end

# -- DatabaseTools --
def fetch_database
	@command_table.clear
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "SELECT * FROM chatbot_commands" ) do |row|
		  @command_table[:names] << row[0]
		  @command_table[:texts] << row[1]
		  @command_table[:types] << row[2]
		  @command_table[:alters_db] << row[3]
		  @command_table[:execution_privilege] << row[4]
		end
		rescue SQLite3::Exception => e    
		    puts "Exception occurred"
		    puts e
		ensure
			db.close if db
	end
end

def authorized_user? user,required_privilege
	group_table = Hash.new {|h,k| h[k] = Array.new}
	user_table = Hash.new {|h,k| h[k] = Array.new}
	group_members_table = Hash.new {|h,k| h[k] = Array.new}
	begin
		db = SQLite3::Database.new @database_path
		db.execute( "SELECT user_id,name FROM users" ) do |row|
		  user_table[:user_id] << row[0]
		  user_table[:name] << row[1]
		end
		db.execute( "SELECT group_id,name FROM groups" ) do |row|
		  group_table[:group_id] << row[0]
		  group_table[:name] << row[1]
		end
		db.execute( "SELECT group_id,user_id FROM group_members" ) do |row|
		  group_members_table[:group_id] << row[0]
		  group_members_table[:user_id] << row[1]
		end
		rescue SQLite3::Exception => e    
		    @cli.text_channel(@channel, "SQL exception occurred")
		    @cli.text_channel(@channel, e.to_s)
		ensure
			db.close if db
	end
	user_id = nil
	user_table[:name].each_with_index do |u,i|
		if user == u
			user_id = user_table[:user_id][i]
			break
		end
	end
	group_id = nil
	group_members_table[:user_id].each_with_index do |uid,i|
		if uid == user_id
			group_id = group_members_table[:group_id][i]
			break
		end
	end
	user_privilege = nil
	group_table[:group_id].each_with_index do |gid,i|
		if gid == group_id
			user_privilege = group_table[:name][i]
		end
	end
	puts user_privilege
	privilege_hierarchy = { "all"	=> 0,
							"auth" 	=> 1,
							"mod"	=> 2,
							"admin" => 3}
	if privilege_hierarchy[user_privilege] >= privilege_hierarchy[required_privilege]
		return true
	else
		return false
	end
end

# -- InifileTools --
def fetch_emoticons
	emoticonnames,emoticonimages = {}, {}
	murmur_ini = IniFile.load(@murmur_ini_path)
	murmur_ini.each do |section,parameter,value|
		if parameter == 'emoticonnames'
			emoticonnames = value.split(', ')
		end
		if parameter == 'emoticonimages'
			emoticonimages = value.split(', ')
		end
	end
	emoticonimages = emoticonimages.map { |m| "<img src='" + m + "'>"}
	emoticonnames.zip(emoticonimages).map { |m| m.join(" ") }
end

# -- LogTools --
def init_logger logfile
	file = File.open(logfile, File::WRONLY | File::APPEND | File::CREAT)
	logger = Logger.new(file)
	logger.level = Logger::WARN
	logger.datetime_format = '%d-%m-%Y %H:%M:%S'
	logger.formatter = proc do |severity, datetime, progname, msg|
	  	"#{datetime.strftime(logger.datetime_format)} #{msg}\n"
	end
	file.sync = true # Update log on the fly
	return logger
end



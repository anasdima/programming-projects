require 'mumble-ruby'
require 'sqlite3'
require 'uri'
# require 'video_info'
require 'logger'
require 'io/console'
require 'inifile'
require 'ruby-mpd'
require 'filewatcher'
require 'mechanize'
require './actions.rb'
require './tools.rb'

#Setup the parameters
# VideoInfo::provider_api_keys = { youtube: 'AIzaSyBRLmon5rRjcO_ZxLGTA16WAUtBwUv4AY4' }
file_paths = {}
connection_info = {}
misc_info = {}
settings_file = IniFile.load('settings.ini')
settings_file.each do |section,parameter,value|
	if section == 'FilePaths'
		file_paths[parameter] = value
	elsif section == 'ConnectionInfo'
		connection_info[parameter] = value
	elsif section == 'Misc'
		misc_info[parameter] = value
	end
end
@database_path 				= file_paths["database"]
@murmur_ini_path			= file_paths["murmurini"]
@chatlog_path				= file_paths["chatlog"]
@murmurlog_path				= file_paths["murmurlog"]
@restartbot_path			= file_paths["restartbot"]
@debuglog_path				= file_paths["debuglog"]
address 					= connection_info["address"]
port						= connection_info["port"]
@botname					= connection_info["botname"]
password 					= connection_info["password"]
@channel 					= misc_info["channel"]
mpd_server					= misc_info["mpdserver"]
mpd_port					= misc_info["mpdport"]
mpd_fifo					= misc_info["mpdfifo"]

#Initialize global variables and objects
@cli 									= Mumble::Client.new(address, port, @botname, password)
@mpd 									= MPD.new mpd_server, mpd_port
@restart_signal 						= false
@logger 								= init_logger @chatlog_path
@debuglogger 							= init_logger @debuglog_path
@command_table 							= Hash.new {|h,k| h[k] = Array.new}
@usernames 								= {}
@channels								= Hash.new {|h,k| h[k] = Hash.new}
@channel_of_user						= {}
@emoticons 								= fetch_emoticons

#Fetch data from the database
fetch_database

#Setup callbacks
@cli.on_user_state do |msg|
	unless msg.name.nil? #nil name (which is user name) means user just changed channel
		unless @usernames.empty?
			@usernames.each do |s,u|
				if u == msg.name
					@usernames.delete(s)
				end
			end
		end
		@usernames[msg.session] = msg.name
		@channel_of_user[@usernames[msg.session]] = @channels[msg.channel_id].name
	end
end

@cli.on_text_message do |msg|	
	if msg.message.start_with?('.')
		@logger.unknown("[" + @channel + "] " + @usernames[msg.actor] + ":" + msg.message)
		msg.message[0] = ''
		msg.message = strip_html(msg.message)
		command = msg.message.split(' ')[0]
		#Search for the command in the table loaded from the database
		found = false
		index = -1
		@command_table[:names].each_with_index do |c,i|
			if command == c
				found = true
				index = i
				break
			end
		end
		unless found == false
			command_name = @command_table[:names][index]
			command_text = @command_table[:texts][index]
			command_type = @command_table[:types][index]
			command_alters_db = @command_table[:alters_db][index]
			command_privilege = @command_table[:execution_privilege][index]
			if authorized_user? @usernames[msg.actor],command_privilege #Check in the database if the user is allowed to use this command
				#Call the function corresponding to the command with the "send" function
				if command_type == 'action'
					argument_list = msg.message.split(' ')
					argument_list.delete_at(0) #Chop the command
					send "#{command_type}_#{command_name}",@usernames[msg.actor],argument_list
				elsif command_type == 'text'
					send "#{command_type}",command_text
				end
				if command_alters_db == 'TRUE'
					fetch_database
				end
			else
				@cli.text_channel(@channel, "not allowed")
				@logger.unknown("[" + @channel + "] " + "Bot" + ":" + "not allowed")
			end
		end
	else
		#mumo issue fix. Server is not broadcasted as an entity at on_user_state.
		if @usernames[msg.actor].nil?
			@usernames[msg.actor] = 'Server'
		end
		#React to html stuff
		messages = parse_html(msg.message)
		if !(messages.empty?)
			@logger.unknown("[" + @channel + "] " + @usernames[msg.actor] + ":" + messages[1]) #Retain event sequence in logging
			@cli.text_channel(@channel, messages[0])
			@logger.unknown("[" + @channel + "] " + "Bot" + ":" + messages[0])
		else
			@logger.unknown("[" + @channel + "] " + @usernames[msg.actor] + ":" + msg.message)
		end
	end
end

#Connect the clients to the servers

#mpd
@mpd.connect

#mumble-ruby
@cli.connect
@channels = @cli.channels
sleep(1)
@cli.join_channel(@channel)
sleep(1)
@cli.player.stream_named_pipe(mpd_fifo)
sleep(1)

while (@restart_signal == false)
	sleep(1)
end

#Call restartbot and disconnect
Dir.chdir (@restartbot_path) {
	Process.spawn('ruby', 'restartbot.rb')
}
@cli.disconnect
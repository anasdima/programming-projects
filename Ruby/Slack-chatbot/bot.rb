# encoding: UTF-8

require 'slackbotsy'
require 'sinatra'
require 'open-uri'
require 'inifile'
require 'logger'
require 'filewatcher'
require 'mechanize'
require './actions.rb'
require './tools.rb'
require './ethmmy.rb'
require './thmmy.rb'

set :bind, '0.0.0.0'

#Setup the parameters
configuration = IniFile.load('settings.ini')

slack_config = {
  'channel'          => '#uninews',
  'name'             => 'rubot',
  'incoming_webhook' => '',
  'outgoing_token'   => '',
  'api_token'		 => ''
}

#Initialize global variables and objects
$bot 									= Slackbotsy::Bot.new(slack_config)
$debuglogger 							= init_logger configuration["FilePaths"]["debuglog"]
$eTHMMY_agent 							= ThmmyAgent::ETHMMYClient.new(configuration["eTHMMY"]["username"],configuration["eTHMMY"]["password"])
$thmmy_agent 							= ThmmyAgent::THMMYGRClient.new(configuration["thmmygr"]["username"],configuration["thmmygr"]["password"])
$eTHMMY_dropbox_subscriptions_path 		= configuration["FilePaths"]["eTHMMY_subscriptions"]
$eTHMMY_agent_subscription_names 		= []
$eTHMMY_dropbox_subscriptions			= fetch_eTHMMY_subscriptions
$eTHMMY_cached_announcements			= Hash.new {|h,k| h[k] = Array.new}
$eTHMMY_subjects_ids					= {}
$eTHMMY_connection						= ""
$eTHMMY_agent_clockA					= ""
$eTHMMY_agent_clockB					= ""

#Setup callbacks
$bot.hear /s/ do
	say("Connection: #{$eTHMMY_connection}\nclockA: #{$clockA.formated_time}\nclockB: #{$clockB.formated_time}")
end

$bot.hear /r/ do
	Process.spawn('ruby', 'restart.rb')
end

$eTHMMY_agent.on_new_announcement do |subject,announcement|
	$debuglogger.unknown("Ήρθε ανακοίνωση για #{subject}")
	$bot.say("Νέα ανακοίνωση από eTHMMY - #{subject}")
	$bot.say("#{announcement[:title]}\n
		#{announcement[:author]}\n
		#{announcement[:date]}\n
		#{announcement[:body]}")
end

$eTHMMY_agent.on_debug_message do |clockA,clockB,announcement|
	$eTHMMY_agent_clockA = clockA
	$eTHMMY_agent_clockB = clockB
	formated_message = "||clockA: #{clockA} || ann_time: #{announcement[:time]} || clockB: #{clockB}|| [#{announcement[:subject]}] #{announcement[:title]}"
	$debuglogger.unknown(formated_message)
end

$thmmy_agent.on_new_post do |post,attachments|
	$bot.say("Νέο post από thmmy.gr - Αποτελέσματα Εξεταστικής")
	$bot.say(post)
	attachments.each do |a|
		if a
			$bot.upload(file: File.new(configuration["FilePaths"]["post-attachments"] + a))
		end
	end
end
# $eTHMMY_agent.on_connectivity_error do |error_type|
# 	$eTHMMY_connection = error_type
# 	while $eTHMMY_connection != "Online" do
# 		case $eTHMMY_connection
# 		when "UnableToLogin"
# 			retry_interval = 60 #in seconds
# 			while $eTHMMY_connection == "UnableToLogin" do
# 				$bot.say("Unable to login. Trying again in #{retry_interval/60} minutes...")
# 				sleep(retry_interval)
# 				retry_interval <= 10*60 ? retry_interval = retry_interval + 60 : retry_interval 
# 				$bot.say("Trying to login...")
# 				$eTHMMY_connection = $eTHMMY_agent.login
# 			end
# 		when "LoggedOut"
# 			$bot.say("Logged out. Logging in...")
# 			$eTHMMY_connection = $eTHMMY_agent.login
# 		when "TimeoutError" || "NetworkUnreachable"
# 			retry_interval = 60 #in seconds
# 			while $eTHMMY_connection == "TimeoutError" || $eTHMMY_connection == "NetworkUnreachable"
# 				$bot.say("Connection error: #{$eTHMMY_connection}. Trying to reconnect in #{retry_interval/60} minutes...")
# 				sleep(retry_interval)
# 				retry_interval <= 10*60 ? retry_interval = retry_interval + 60 : retry_interval 
# 				$bot.say("Trying to reconnect...")
# 				$eTHMMY_connection = $eTHMMY_agent.login
# 			end
# 		end
# 	end
# 	$bot.say("Reconnected.")
# 	$eTHMMY_agent.kill_threads
# 	$eTHMMY_agent_subscriptions = $eTHMMY_agent.get_subscriptions
# 	$eTHMMY_subjects_ids = ($eTHMMY_agent.get_all_courses).invert
# 	$eTHMMY_agent.spawn_announcement_poller($eTHMMY_agent_subscriptions)
# end

on_file_change do
	old_subscriptions = $eTHMMY_dropbox_subscriptions.values.flatten.uniq
	new_subscriptions = (fetch_eTHMMY_subscriptions).values.flatten.uniq
	unsubscribe_from = old_subscriptions - new_subscriptions
	subscribe_to = new_subscriptions - old_subscriptions
	unsubscribe_from.each do |subject|
		if $eTHMMY_subjects_ids[subject]
			$eTHMMY_agent.unsubscribe_from($eTHMMY_subjects_ids[subject])
			message = "Dropbox file changed, unsubscribed from #{subject}"
			$bot.say(message)
		else
			message = "Dropbox file changed, but #{subject} is not a valid course"
			$bot.say(message)
		end
	end
	subscribe_to.each do |subject|
		if $eTHMMY_subjects_ids[subject]
			$eTHMMY_agent.subscribe_to($eTHMMY_subjects_ids[subject])
			message = "Dropbox file changed, subscribed to #{subject}"
			$bot.say(message)
		else
			message = "Dropbox file changed, but #{subject} is not a valid course"
			$bot.say(message)
		end
	end
	$eTHMMY_dropbox_subscriptions = fetch_eTHMMY_subscriptions
end

#Dropbox file watcher
spawn_file_watcher $eTHMMY_dropbox_subscriptions_path

#eTHMMY-agent
$eTHMMY_connection = $eTHMMY_agent.login
$eTHMMY_agent_subscriptions = $eTHMMY_agent.get_subscriptions
$eTHMMY_subjects_ids = ($eTHMMY_agent.get_all_courses).invert
$eTHMMY_agent.spawn_announcement_poller($eTHMMY_agent_subscriptions)

#thmmy.gr-agent
$thmmy_agent.login
$thmmy_agent.spawn_forum_poller

post '/' do
	$bot.handle_item(params)
end
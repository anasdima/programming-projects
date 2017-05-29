@commands = [

	'.server_restart',
	'.commands',
	'.emoticons',
	'.dg',
	'.todd',
	'.deh',
	'.mining',
	'.cc',
	'.roll #',
	'.adde name image-link',
	'.dele name',
	'.play song-name',
	'.stop',
	'.songs',
	'.smotd',
	'.log',
	'.slog'

]

@command_types = {

	server_restart: 	[/^server_restart$/,'a','c'],
	commands: 			[/^commands$/,'t','w'],
	emoticons: 			[/^emoticons$/,'t','w'],
	dg: 				[/^dg$/,'t','c'],
	todd: 				[/^todd$/,'t','c'],
	deh: 				[/^deh$/,'t','c'], 
	mining: 			[/^mining$/,'t','c'],
	cc: 				[/^cc$/,'t','c'],
	roll: 				[/^roll(\s{1,})[0-9]+$/,'a','c'],
	adde:  				[/^adde(\s{1,})[a-zA-Z0-9]+(\s{1,})https?:\/\/[\S]+$/,'a','c'],
	dele: 				[/^dele(\s{1,})(.*?)$/,'a','c'],
	play:  				[/^play(\s{1,})[a-zA-Z]+$/,'a','c'],
	stop: 				[/^stop$/,'a','c'],
	songs: 				[/^songs$/,'a','w'],
	smotd: 				[/^smotd(\s{1,})'(.*?)'/,'a','c'],
	log: 				[/^log(\s{1,})[0-9]+$/,'a','c'],
	slog:				[/^slog(\s{1,})[0-9]+$/,'a','c']

}

$text_messages = {

	commands: 			@commands,
	emoticons: 			[],
	dg: 				["GIAAAAAAAAAAAAAAAAAAAAAAAAAANNNNNNNNNNNNNNNNNNNNNNHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?????????????????????????????"],
	todd: 				["I\'m sorry for your loss"],
	deh: 				["<a href='https://docs.google.com/spreadsheet/ccc?key=0AtcF-j9reAd0dFpfd1lJZDg4aUFJcGM2VUNsYXRLaXc&usp=sharing#gid=0'>Xrewseis DEH 31/01/2014</a>"], 
	mining: 			["<a href='https://docs.google.com/spreadsheet/ccc?key=0AlhSF602y9DSdHRneWVZcjJLWmhjaVBMTHVCR3l4eHc&usp=sharing#gid=0'>LTC GPU Mining profit chart</a>"],
	
}


module Shared

  	def self.emoticons=(val)
    	$text_messages[:emoticons] = val
  	end

end
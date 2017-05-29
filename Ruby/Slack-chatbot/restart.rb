%x(kill $(ps aux | grep '[b]ot.rb' | awk '{print $2}'))
Process.spawn('ruby', 'bot.rb')
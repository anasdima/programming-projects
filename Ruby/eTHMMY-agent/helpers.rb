module ThmmyAgent
	module ThmmyHelpers
		Announcement = Struct.new(:title, :date, :author, :body)

		$ethmmy_poll_interval 	= 10 #in minutes
		$thmmy_poll_interval 	= 10 #in minutes

		$ethmmy_date_format = {	"day"		=> 0,
								"month"		=> 1,
								"year"		=> 2,
								"time"		=> 3,
								"meridian"	=> 4
		}

		$thmmy_date_format = { 	"month"		=> 0,
								"day"		=> 1,
								"year"		=> 2,
								"hour" 		=> 3,
								"minute"	=> 4
		}

		$english_months_map = { "January"	=> 1,
								"February"	=> 2,
								"March"		=> 3,
								"April"		=> 4,
								"May"		=> 5,
								"June"		=> 6,
								"July"		=> 7,
								"August"	=> 8,
								"September"	=> 9,
								"October"	=> 10,
								"November"	=> 11,
								"December"	=> 12
		}

		$greek_months_map = { 	"Ιαν"	=> 1,
								"Φεβ"	=> 2,
								"Μαρ"	=> 3,
								"Απρ"	=> 4,
								"Μαϊ"	=> 5,
								"Ιουν"	=> 6,
								"Ιουλ"	=> 7,
								"Αυγ"	=> 8,
								"Σεπ"	=> 9,
								"Οκτ"	=> 10,
								"Νοε"	=> 11,
								"Δεκ"	=> 12
		}

		$greek_meridian_map = { "πμ"	=> 0,
								"μμ"	=> 12

		}

		#tries to solve ethmmy time bug. Index: subject id, content: announcement time in int format
		$ethmmy_future_announcements = [] 

		def ethmmy_sanitize(announcement)	
			arr = announcement.search('p')
			title = arr[0].text.scan(/[^\r\n\t]/).join.lstrip.gsub(%r{</?[^>]+?>}, '').gsub(/&nbsp/,'')
			date = arr[1].search('b')[0].text.scan(/[^\r\n\t]/).join.lstrip.gsub(%r{</?[^>]+?>}, '').gsub(/&nbsp/,'')
			author = arr[1].search('i').text.scan(/[^\r\n\t]/).join.lstrip.gsub(%r{</?[^>]+?>}, '').gsub(/&nbsp/,'')

			announcement.search('p.listLabel').remove
			announcement.search('p > b').remove
			announcement.search('p > i').remove
			body = announcement.to_html(:encoding => 'UTF-8').gsub('&amp;', '&').gsub(%r{</?[^>]+?>}, '').gsub(/&nbsp/,'').gsub(/\n+|\r+/, "\n").squeeze("\n").strip
			
			ann = Announcement.new(title, date, author, body)

			return ann
		end
	end

	class Clock

		COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

		def initialize(time)
			@time = time
			@string_clock = time_to_s(@time)
			@int_clock = @string_clock.to_i
		end
		public
		def self.time_to_s(time)
			string = ''
			time.each do |t,v|
				if v < 10
					v = '0' + v.to_s
				end
				string += v.to_s
			end
			return string
		end
		def time_to_s(time)
			string = ''
			time.each do |t,v|
				if v < 10
					v = '0' + v.to_s
				end
				string += v.to_s
			end
			return string
		end
		def self.time_to_i(time)
			return time_to_s(time).to_i
		end
		def time_to_i(time)
			return time_to_s(time).to_i
		end
		def string
			return @string_clock
		end
		def int
			return @int_clock
		end
		def formated_time
			return "#{@time[:days]}/#{@time[:months]}/#{@time[:years]} #{@time[:hours]}:#{@time[:minutes]}"
		end
		def self.format_time(time)
			return "#{time[:days]}/#{time[:months]}/#{time[:years]} #{time[:hours]}:#{time[:minutes]}"
		end
		def days_in_month(month, year)
		   return 29 if month == 2 && Date.gregorian_leap?(year)
		   COMMON_YEAR_DAYS_IN_MONTH[month]
		end
		def +(minutes)
			time = @time.clone
			time[:minutes] += minutes
			if time[:minutes] >= 60
				time[:hours] += time[:minutes]/60
				time[:minutes] %= 60
				if time[:hours] >= 24
					time[:days] += time[:hours]/24
					time[:hours] %= 24
					month_days = days_in_month(time[:months],time[:year])
					if time[:days] >= month_days
						time[:months] += time[:days]/month_days
						time[:days]	%= month_days
						if time[:months] >= 12
							time[:years] += time[:months]/12
							time[:months] %= 12
						end
					end
				end
			end

			return Clock.new(time)
		end
		def sync_with_current_time
			current_time = {:years => Time.now.year.to_i, :months => Time.now.month.to_i, :days => Time.now.day.to_i, :hours => Time.now.hour.to_i, :minutes => Time.now.min.to_i}
			@time = current_time
			@string_clock = time_to_s(current_time)
			@int_clock = @string_clock.to_i
		end
	end
	
	class LoginAsGuest < StandardError
	end

	class WrongCredentials < StandardError
	end

	class TimeoutError < Errno::ETIMEDOUT
	end

	class NetworkUnreachable < Errno::ENETUNREACH
	end
end
require './helpers.rb'

module ThmmyAgent
	class THMMYGRClient

		include ThmmyHelpers

		def initialize(username,password)
			@username = username
			@password = password
			@base_url = 'https://www.thmmy.gr/smf/index.php?topic=65663.10000000000'
			@callbacks = Hash.new { |h, k| h[k] = [] }

			$session_year 	= Time.now.year.to_i
			$session_month 	= Time.now.month.to_i
			$session_day 	= Time.now.day.to_i
			$session_hour 	= Time.now.hour.to_i
			$session_minute = Time.now.min.to_i

			$session_time = {:years => $session_year, :months => $session_month, :days => $session_day, :hours => $session_hour, :minutes => $session_minute}
			
			$clockA = Clock.new($session_time)
			$clockB = $clockA + $thmmy_poll_interval

			#cert_store = OpenSSL::X509::Store.new
			#cert_store.set_default_paths
			#cert_store.add_file File.expand_path('./cacert.pem')

			@agent = Mechanize.new { |agent|
				#agent.user_agent_alias = 'Mac Safari'
				#agent.cert_store = cert_store
				#agent.ssl_version='SSLv3'
				agent.verify_mode= OpenSSL::SSL::VERIFY_NONE
				agent.pluggable_parser.default = Mechanize::Download
				#agent.agent.http.ca_file = File.expand_path('./cacert.pem')
			}
		end

		def login
			page = @agent.get(@base_url)
			form = page.forms[1]
			form.user = @username
			form.passwrd = @password
			@agent.submit(form,form.buttons.first)
		end

		def check_for_new_grades
			page = @agent.get(@base_url)

			page.parser.xpath('//table[@width="100%"][@cellpadding="3"][@cellspacing="0"][@border="0"]').each do |table|
				
				#get the actual post
				post = table.xpath('.//div[@class="post"]').text

				unless post.empty?

					@post = post

					#get post date
					@date = []
					r = table.xpath('.//div[@class="smalltext"]').to_s
					if r.include? 'on'
						@date = r.partition("on:</b>").last.gsub(/ »\<\/div\>/,'')
						.gsub(/,/,'').gsub(/:/,' ').gsub(/\<b\>/,'').gsub(/\<\/b\>/,'').split(' ')
					end
					
					@attachments = []
					#download post attachments
					table.xpath('.//div[@style="overflow: auto; width: 100%;"]//a').each do |div|
						if div.to_html.include? "clip.gif"
							filename = div.text
							filename[0] = '' #random nbsp in file name
							if Dir.entries("post-attachments").include? filename
								@attachments << nil
							else
								@agent.get(div['href']).save("post-attachments/" + filename)
								@attachments << filename
							end
						end						
					end


				
					if @date[0] == "Today"
						day 	= Time.now.day.to_i
						month 	= Time.now.month.to_i
						year 	= Time.now.year.to_i
						hour 	= @date[2].to_i
						minute 	= @date[3].to_i 
					else
						day 	= @date[$thmmy_date_format["day"]].to_i
						month 	= $english_months_map[@date[$thmmy_date_format["month"]]].to_i
						year 	= @date[$thmmy_date_format["year"]].to_i
						hour 	= @date[$thmmy_date_format["hour"]].to_i
						minute 	= @date[$thmmy_date_format["minute"]].to_i
					end

					post_time = {:years => year, :months => month, :days => day, :hours => hour, :minutes => minute}
					post_time_int = Clock.time_to_i(post_time)

					if post_time_int >= $clockA.int && post_time_int <= $clockB.int
						@callbacks[:new_grades_post].each {|c| c.call *([@post,@attachments])}
					end
				end
			end
		end

		def poll_posts(bored_to_change_spawn_thread_function_herpy_derpy)
			while true do
				sleep($thmmy_poll_interval*60)
				
				check_for_new_grades
					
				$clockA.sync_with_current_time
				$clockB = $clockA + $thmmy_poll_interval		
			end
		end

		def spawn_forum_poller
			spawn_thread(:poll_posts,nil)
		end

		define_method "on_new_post" do |&block|
			@callbacks[:new_grades_post] << block
		end
	end
end

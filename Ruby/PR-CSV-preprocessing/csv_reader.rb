require 'csv'
require 'optparse'

def csv_save filename,csv_array,headers
	puts "Saving changes to file..."
	CSV.open(filename, 'w', :write_headers=>true, :headers => headers) do |csv_object|
		csv_array.each do |row_array|
			csv_object << row_array
		end
	end
end

def clean_path path
	path = path.split('\\').reverse[0].gsub(/.csv/,"")
end

def delete_zeros filename
	data = []
	CSV.foreach(filename, headers:true) do |row|
		has_zero = false
		row.headers.each do |h|
			if row[h].to_i == 0
				has_zero = true
				break
			end
		end
		unless has_zero == true
			data << row
		end
	end
	return data
end

def h filename # find headers
	i = 0
	CSV.foreach(filename) do |row|
		if i == 0
			return row
			break
		end
	end
end

def error
	puts "These parameters sample the whole dataset!"
	puts "Exiting..."
	exit
end

@last_n_values = Hash.new {|h,k| h[k] = Array.new }
def moving_metric type,running_value,inc_value,leaving_value,metric_unit,header,line
	case type
	when "sum"
		running_value += inc_value - leaving_value
	when "avg"
		if line < metric_unit #for the first lines, the denominator of the moving average is equal to the number of lines and not the metric unit
			@last_n_values[header].push(inc_value)
			sum = 0.0
			@last_n_values[header].each do |v|
				sum += v
			end
			running_value = (sum.to_f)/((line+1).to_f)
		else
			running_value += ((inc_value - leaving_value).to_f) / ((metric_unit).to_f)
		end
		if running_value < 0 || running_value <= 0.0001 # deal with unreliable math operations
			running_value = 0
		end
	when "max"
		@last_n_values[header].push(inc_value)
		unless line < metric_unit
			@last_n_values[header].delete_at(0)
		end
		if running_value == leaving_value
			running_value = 0
			@last_n_values[header].each do |v|
				if v > running_value
					running_value = v
				end
			end
		else
			if inc_value > running_value
				running_value = inc_value
			end
		end
	when "min"
		if line == 0
			running_value = 999999 # something arbitrary big
		end
		@last_n_values[header].push(inc_value)
		unless line < metric_unit
			@last_n_values[header].delete_at(0)
		end
		if running_value == leaving_value
			running_value = 999999
			@last_n_values[header].each do |v|
				if v < running_value
					running_value = v
				end
			end
		else
			if inc_value < running_value
				running_value = inc_value
			end
		end
	end
	return running_value
end

options={}
option_switcher = ''
OptionParser.new do |opts|
	opts.banner = "Usage: csv_reader.rb [options] [filename]"

	opts.on("-x", "--split [TYPE]", "Split dataset into smaller ones according to TYPE. Available types: {year|season|month}") do |type|
		options[:split_type] = type
		option_switcher = "x"
	end
	opts.on("-j", "--join [DATASETS]", Array, "Join datasets into one. Example: -j dataset_joining dataset_to_append_to") do |dataset|
		options[:join_dataset] = dataset
		option_switcher = "j"
	end
	opts.on("-z", "--zones [TYPE]", Array, "Create zones in the dataset. Available zone types: {day|hour},n") do |type|
		options[:zones_type] = type
		option_switcher = "z"	
	end
	opts.on("-s", "--sample [TYPE]", Array, "Sample the dataset. Samples can be {day|hour|minute},n") do |type|
		options[:samples_type] = type
		option_switcher = "s"
	end
	opts.on("-m", "--metrics [TYPE]", Array, "Create metrics in the dataset. Metric format: {avg|sum|min|max},{week|day|hour|minute},n") do |type|
		options[:metric_type] = type
		option_switcher = "m"
	end
	opts.on("-o", "--outliers [TYPE]", "Prepare dataset for outlier detection. Available types: {matlab|weka}") do |type|
		options[:outliers_type] = type
		option_switcher = "o"
	end
	opts.on("-t", "--setup", "Fill the missing \"missing values\" in the last column, replace \";\" with \",\"") do
		option_switcher = "t"
	end
	opts.on("-d", "--delete [TYPE]", "Delete type from dataset. Available types: {zero|idle}") do |type|
		options[:delete_type] = type
		option_switcher = "d"
	end
	opts.on("-c", "--convert [ATTRIBUTE]", "Convert attribute. Available conversions: {Time|Time_Week|Time_day|Remaining_active_power|Metering_activity|Evaluation}") do |attribute|
		options[:convert_attribute] = attribute
		option_switcher = "c"
	end
	opts.on("-l", "--select [COLUMNS]", Array, "Select columns in the dataset") do |columns|
		options[:columns] = columns
		option_switcher = "l"
	end
	opts.on("-e", "--evaluate", "Convert arff to csv and evaluate with matlab") do
		option_switcher = "e"
	end
	opts.on("-h", "--help", "Display this screen") do
		puts opts
		exit
	end
end.parse!

csv_file = ARGV.shift
headers = []
time_format = {	"hour"		=> [0,24],
				"minute"	=> [1,60],
				"day"		=> [0,7],
				"week"		=> ['-',52]}

case option_switcher
when "x"
	case options[:split_type]
	when "year"
		years = ["2006","2007","2008","2009","2010"]
		year = []
		years.each do |y|
			CSV.foreach(csv_file, headers:true) do |row|
				year << row if(row['Date'].split('/')[2] == y)
				headers = row.headers
			end
			csv_save("#{y}.csv",year,headers)
			year = []
		end
	when "season"
		seasons = {	"Winter" => [12,1,2],
					"Spring" => [3,4,5],
					"Summer" => [6,7,8],
					"Autumn" => [9,10,11]}
		season = []
		seasons.each do |s,month| 
			CSV.foreach(csv_file, headers:true) do |row|
				month.each do |m|
					season << row if(row['Date'].split('/')[1].to_i == m)
				end
				headers = row.headers
			end
			csv_save("#{s}.csv",season,headers)
			season = []
		end
	when "month"
		month = []
		for i in 1..12
			CSV.foreach(csv_file, headers:true) do |row|
				month << row if(row['Date'].split('/')[1].to_i == i)
				headers = row.headers
			end
			month_name = Date::MONTHNAMES[i]
			csv_save("#{month_name}.csv",month,headers)
			month = []
		end
	end
when "j"
	File.open(csv_file, 'a') do |f|
		CSV.foreach(options[:join_dataset][0], headers:true) do |row|
			f.puts(row)
		end
	end
when "z"
	zoned_set = []
	case options[:zones_type][0]
	when "day"
		puts "Is the time numeric? y/n"	
		answer = gets.chomp
		case answer
		when "n"
			CSV.foreach(csv_file, headers:true) do |row|
				hour = row['Time'].split(':')[0].to_i 
				if hour >= 6 && hour <= 15 # This is up to 15:59 A.M. since minutes are not accounted
					row['Time'] = 'Morning_Noon'
				elsif hour >= 16 && hour <= 17
					row['Time'] = 'Afternoon'
				elsif hour >= 18 && hour <= 23
					row['Time'] = 'Night'
				elsif hour >= 0 && hour <= 2
					row['Time'] = 'Late Night'
				else 
					row['Time'] = 'No activity'
				end
				zoned_set << row
				headers = row.headers
			end
		when "y"
			time_header = ''
			puts "Specify the name of the time header:"
			time_header = gets.chomp
			CSV.foreach(csv_file, headers:true) do |row|
				hour = row[time_header].to_i 
				if hour >= 600 && hour <= 1559
					row[time_header] = 'Morning_Noon'
				elsif hour >= 1600 && hour <= 1759
					row[time_header] = 'Afternoon'
				elsif hour >= 1800 && hour <= 2359
					row[time_header] = 'Night'
				elsif hour >= 0 && hour <= 259
					row[time_header] = 'Late Night'
				else 
					row[time_header] = 'No activity'
				end
				zoned_set << row
				headers = row.headers
			end
		end
		csv_file = clean_path(csv_file)
		csv_save("#{csv_file}_dayzoned.csv",zoned_set,headers)
	when "hour"
		number_of_hours = options[:zones_types][1]
		CSV.foreach(csv_file, headers:true) do |row|
			hour = row['Time'].split(':')[0].to_i 
			for h in (0..24).step(number_of_hours)
				if hour >= h && hour < h+number_of_hours
					row['Time'] = "#{number_of_hours}-hour-zone#{h/number_of_hours}"
				end
			end
		zoned_set << row
		headers = row.headers
		end
		csv_file = clean_path(csv_file)
		csv_save("#{csv_file}_hourzoned.csv",zoned_set,headers)
	when "Sub_metering_3"
		CSV.foreach(csv_file, headers:true) do |row|
			if row['Sub_metering_3'].to_i <= 1
				row['Sub_metering_3'] = 'Idle'
			else
				row['Sub_metering_3'] = 'Active'
			end
			zoned_set << row
			headers = row.headers
		end
		csv_file = clean_path(csv_file)
		csv_save("#{csv_file}_S3.csv",zoned_set,headers)
	end
when "s"
	time_subdiv = time_format[options[:samples_type][0]][0]
	sample_unit = options[:samples_type][1].to_i
	samples = []

	case time_subdiv
	when "hour"
		sample_unit = sample_unit*time_format['minute'][1]
	when "day"
		sample_unit = sample_unit*time_format['hour'][1]*time_format['minute'][1]
	when "week"
		sample_unit = sample_unit*time_format['day'][1]*time_format['hour'][1]*time_format['minute'][1]
	end

	case options[:samples_type][0]
	when "minute"
		line = 0
		CSV.foreach(csv_file, headers:true) do |row|
			if line == 0 || (line+1)%sample_unit == 0 # each row is a minute
				samples << row
		  		headers = row.headers
	  		end
	  		line += 1
		end
	when "hour"
		number_of_hours = 0
		running_hour = -1
		puts "Whole hour (60 minutes) or 1 minute (59th minute)? w/o"
		answer = gets.chomp
		if answer == 'w' && sample_unit == 1
			error
		end
		case answer
		when "w"
			CSV.foreach(csv_file, headers:true) do |row|
				hour = row['Time'].split(':')[time_format["hour"][0]].to_i
				if running_hour == -1 || running_hour != hour
					running_hour = hour
					number_of_hours += 1
				end
				if (number_of_hours%sample_unit == 0)
					samples << row
					headers = row.headers
				end
			end
		when "o"
			CSV.foreach(csv_file, headers:true) do |row|
				minute = row['Time'].split(':')[time_format["minute"][0]].to_i
				if (number_of_hours%sample_unit == 0 && minute == 59)
					samples << row
					headers = row.headers
				end
			end
		end
	when "day"
		number_of_days = 0
		running_day = -1
		puts "Whole day (1440 minutes) or 1 minute (11:59P.M.)? w/o"
		answer = gets.chomp
		if answer == 'w' && sample_unit == 1
			error
		end
		case answer
		when "w"
			CSV.foreach(csv_file, headers:true) do |row|
				day = row['Date'].split(':')[time_format["day"][0]].to_i
				if running_day == -1 || running_day != day
					running_day = day
					number_of_days += 1
				end
				if number_of_days%sample_unit == 0
					samples << row
					headers = row.headers
				end
			end
		when "o"
			i = 0
			CSV.foreach(csv_file, headers:true) do |row|
				day = row['Date'].split(':')[time_format["day"][0]].to_i
				hour = row['Time'].split(':')[0].to_i
				minute = row['Time'].split(':')[1].to_i
				if running_day == -1 || running_day != day
					running_day = day
					number_of_days += 1
				end
				if number_of_days%sample_unit == 0 && hour == 11 && minute == 59
					samples << row
					headers = row.headers
				end
				i+=1
			end
		end
	end
	csv_file = clean_path(csv_file)
	csv_save("#{csv_file}_#{options[:samples_type][1]}-#{options[:samples_type][0]}-samples.csv",samples,headers)
when "m"
	time_subdiv = time_format[options[:metric_type][1]][0]
	time_unit = time_format[options[:metric_type][1]][1]
	metric_type = options[:metric_type][0]
	metric_unit = options[:metric_type][2].to_i
	metrics = []
	raw_row = []
	metric = Array.new(15) {|i| 0.0} # 15 is number of columns. Dataset has 9, 15 is for safety
	i = 0

	#convert all time sub-divisions to minutes, sine the dataset is minute-averaged
	case time_subdiv
	when "hour"
		metric_unit = metric_unit*time_format['minute'][1]
	when "day"
		metric_unit = metric_unit*time_format['hour'][1]*time_format['minute'][1]
	when "week"
		metric_unit = metric_unit*time_format['day'][1]*time_format['hour'][1]*time_format['minute'][1]
	end

	CSV.foreach(csv_file, headers:true) do |row|
		#For each numerical column, calculate the moving metric
		j = 0
		row.headers.each do |h|
			unless h == 'Date' || h == 'Time' 
				raw_row[i*(row.headers.length-2)+j] = row[h].to_f
				if i >= metric_unit
					metric[j] = moving_metric(metric_type,metric[j],
								row[h].to_f,raw_row[i*(row.headers.length-2)-metric_unit*(row.headers.length-2)+j],metric_unit,j,i)
				else
					metric[j] = moving_metric(metric_type,metric[j],row[h].to_f,0.0,metric_unit,j,i)
				end
				row[h] = metric[j]
				j += 1
			end
		end
		metrics << row
		headers = row.headers
		i += 1
	end
	csv_file = clean_path(csv_file)
	csv_save("#{csv_file}_#{options[:metric_type][0]}-#{options[:metric_type][2]}-#{options[:metric_type][1]}.csv",metrics,headers)
when "o"
	case options[:outliers_type]
	when "matlab"
		puts "Delete idles? y/n"	
		answer = gets.chomp
		clean_data = []
		case answer
		when "y"
			puts "Idle upper limit?"
			idle_limit = gets.chomp.to_i
			puts "Outlier percentage?"
			noutliers = gets.chomp.to_f
			puts "Deleting missing values,idle values, Date column and Time column..."
			CSV.foreach(csv_file, headers:true) do |row|
				delete_row = false
				row.delete('Date')
				row.delete('Time')
				row.headers.each do |h|
					if row[h] == '?' || row[h].to_i <= idle_limit
						delete_row = true
						break
					end
				end
				unless delete_row == true
					clean_data << row
					headers = row.headers
				end
			end
		when "n"
			puts "Outlier percentage?"
			noutliers = gets.chomp.to_f
			puts "Deleting missing values, Date column and Time column..."
			new_row = []
			CSV.foreach(csv_file, headers:true) do |row|
				delete_row = false
				row.delete('Date')
				row.delete('Time')
				row.headers.each do |h|
					if row[h] == '?'
						delete_row = true
						break
					end
				end
				unless delete_row == true
					clean_data << row
					headers = row.headers
				end
			end
		end
		csv_file = clean_path(csv_file)
		csv_save("#{csv_file}_outliers-matlab.csv",clean_data,headers)

		puts "Calling knn_outliers_stat..."

		# Prepare for knn outlier detection in matlab
		wd = Dir.pwd
		dataset = wd + "/" + "#{csv_file}_outliers-matlab.csv"
		output_file = wd + "/" + "#{csv_file}_outliers-matlab_removed(#{noutliers}).csv"
		neighbors = 5
		#noutliers came from input
		execution_string = "knn_outliers_stat('#{dataset}','#{output_file}',#{neighbors},#{noutliers})"

		# Call knn_outliers_stat.m through matlab to remove outliers
		%x(matlab -nojvm -nodisplay -nosplash /r "#{execution_string}")

		puts "Ruby execution finished."
		
	when "weka"
		new_row = []
		CSV.foreach(csv_file, headers:true) do |row|
			row.delete('Date')
			row.delete('Time')
			row << ['Outlier', 'False']
			new_row << row
			headers = row.headers
		end
		csv_file = clean_path(csv_file)
		csv_save("#{csv_file}_outliers-weka.csv",new_row,headers)
	end
when "t"
	new_file = []
	File.foreach(csv_file) do |line|
  		new_file << line.gsub(/;/,",").gsub(/\?,$/,"?,?") # replace semi-colons with commas and fill missing "missing values"
  	end
  	File.open(csv_file, "w+") do |f|
  		f.puts(new_file)
	end
when "d"
	data = []
	case options[:delete_type]
	when "zero"
		data = delete_zeros(csv_file)
	when "idle"
		CSV.foreach(csv_file, headers:true) do |row|
			has_idle = false
			if row['Sub_metering_1'].to_i <= 1 || row['Sub_metering_2'].to_i <= 1 || row['Sub_metering_3'].to_i <= 1
				has_idle = true
			end
			unless has_idle == true
				data << row
			end
		end
	end
	headers = h(csv_file)
	csv_file = clean_path(csv_file)
	csv_save("#{csv_file}_no-#{options[:delete_type]}.csv",data,headers)
when "c"
	new_attributes = []
	case options[:convert_attribute]
	when "Time_numeric"
		CSV.foreach(csv_file, headers:true) do |row|
			row['Time_numeric'] = row['Time'].split(':')[0].to_s + ((row['Time'].split(':')[1].to_f)*(10.0/6.0)).to_s
			new_attributes << row
			headers = row.headers
		end
	when "Time_week"
		i = 0
		CSV.foreach(csv_file, headers:true) do |row|	
			row['Time_week'] = (i/(time_format['hour'][1]*time_format['minute'][1])).to_i.to_s + row['Time'].split(':')[1].to_s
			new_attributes << row
			i += 1
			if (i == time_format['day'][1]*time_format['hour'][1]*time_format['minute'][1])
				i = 0 # reset the week
			end
			headers = row.headers
		end
	when "Time_day"
		i = 0
		CSV.foreach(csv_file, headers:true) do |row|
			row['Time_day'] = (i/(time_format['hour'][1]*time_format['minute'][1])).to_i.to_s + row['Time'].split(':')[0] + row['Time'].split(':')[1].to_s
			new_attributes << row
			headers = row.headers
			i += 1
		end
	when "Remaining_active_power"
		CSV.foreach(csv_file, headers:true) do |row|
			row['Remaining_active_power'] = (row['Global_active_power'].to_i)*1000/60 - row['Sub_metering_1'].to_i - row['Sub_metering_2'].to_i - row['Sub_metering_3'].to_i
			if row['Remaining_active_power'].to_i < 0 # Wrong measure
				row.delete('Remaining_active_power')
			end
			row.delete('Global_active_power')
			new_attributes << row
			headers = row.headers
		end
	when "Metering_activity"
		CSV.foreach(csv_file, headers:true) do |row|
			row['Metering_activity'] = row['Sub_metering_1'].to_i + row['Sub_metering_2'].to_i + row['Sub_metering_3'].to_i
			row.delete('Sub_metering_1')
			row.delete('Sub_metering_2')
			row.delete('Sub_metering_3')
			new_attributes << row
			headers = row.headers
		end
	when "Evaluation"
		CSV.foreach(csv_file, headers:true) do |row|
			unless row['Cluster'] == "?"
				row['Cluster_numeric'] = row['Cluster'][row['Cluster'].length-1]
				row.delete('Cluster')
				row.delete('Instance_number')
				new_attributes << row
				headers = row.headers
			end
		end
	end
	csv_file = clean_path(csv_file)
	csv_save("#{csv_file}_#{options[:convert_attribute]}.csv",new_attributes,headers)
when "l"
	dataset = []
	CSV.foreach(csv_file, headers:true) do |row|
		row.headers.each do |h|
			unless options[:columns].include? h
				row.delete(h)
			end
		end
		dataset << row
		headers = row.headers
	end
	column_initials_map = {	"Date" 						=> "D",
							"Time"						=> "T",
							"Global_active_power"		=> "Gap",
							"Global_reactive_power"		=> "Grp",
							"Voltage"					=> "V",
							"Intensity"					=> "I",
							"Sub_metering_1"			=> "S1",
							"Sub_metering_2"			=> "S2",
							"Sub_metering_3"			=> "S3",
							"Time_numeric"				=> "Tn",
							"Time_week"					=> "Tw",
							"Time_day"					=> "Td",
							"Remaining_active_power"	=> "Rap",
							"Metering_activity"			=> "Ma"}
	column_initials = ""
	options[:columns].each do |c|
		column_initials += column_initials_map[c]
	end
	csv_file = clean_path(csv_file)
	csv_save("#{csv_file}_#{column_initials}.csv",dataset,headers)
when "e"
	path = csv_file
	csv_folder = 'Clusters-csv'
	Dir.chdir(path)
	Dir.foreach('.') do |file|
		if file.include? ".arff"
			arff_file = file
			start_saving = false
			data = []
			headers = []
			File.open(arff_file, "r") do |f|
			  	f.each_line do |line|
			    	if line.include? "@attribute"
			    		line.delete!("\n")
			    		header = line.split(' ')[1]
			    		unless header == "Instance_number"
			    			headers << header
			    		end
			    	end
			    	if line.include? "@data"
			    		start_saving = true
			    	end
			    	if start_saving == true && !(line.include? "@data")
			    		unless line.include? "?"
				    		if line.include? "\n"
				    			line.gsub!(/cluster/,'')
				    			line = line.delete!("\n").split(",")
				    			line.delete_at(0)
				    			data << line
				    		else
				    			line.gsub!(/cluster/,'')
				    			line = line.split(",")
				    			line.delete_at(0)
				    			data << line
				    		end
				    	end
			    	end
				end
			end
			csv_file = csv_folder + "\\" + arff_file.gsub(/.arff/,"")
			csv_save("#{csv_file}.csv",data,headers)
		end
	end
end



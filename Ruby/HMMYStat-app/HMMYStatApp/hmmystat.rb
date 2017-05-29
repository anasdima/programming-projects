require 'sinatra'
require 'tiny_tds'
require 'nyaplot'

set :bind, '0.0.0.0'

$database_client = TinyTds::Client.new username: 'sa', password: 'hmmystat', host: 'kingc.no-ip.org', database: 'HMMYStat'
$database_tables = []
$query_tables = []

$rules_form_html = '
<form role="form" action="query_submit" method="POST">
<div class="col-md-8">
    <div class="form-group">
     	<label for="rules">Type the rules you want to apply to the attributes:</label>
      	<input class="form-control" name="rules" placeholder="E.g. Students.Semester>5,Grades.Grade=9">
       	<label for="functions">Choose a function that you want to apply to the attributes:</label>
	  	<div class="input-group">
	  	<input class="form-control" name="function-parameters" placeholder="Function parameters go here">
		    <span class="input-group-btn">
		        <select class="btn" name="function-choice">
		          <option>None</option>
		          <option>Count</option>
		          <option>Avg</option>
		          <option>Percent</option>
		        </select>
		    </span>
         </div>
  		<label for="axis">Type the X axis of the plot. If you did not specify any functions, type the Y Axis too</label>
  		<input class="form-control" name="axis" placeholder="E.g. Book.Title">
    </div>

    <button type="submit" class="btn btn-default">Submit</button>

</div>
</form>'

def database_read_tables
	result = $database_client.execute("SELECT * FROM information_schema.tables")
	result.each do |row|
		$database_tables << row["TABLE_NAME"]
	end
	$database_tables << "Exams_Subjects"
	$database_tables << "Year_Statistics"
	result.cancel
end

def database_read_table_attrs tables
	$tables_message = ''
	tables.each do |t|
		if !($database_tables.include? t)
			$tables_message = "#{t} is not a valid table name"
			return
		end
		$query_tables << t
	end
	$label1 = 'These are the attributes of the tables you typed:'
	tables.each do |t|
		result = $database_client.execute("SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = N'#{t}'")
		tmp = []
		result.each do |row|
			unless row["COLUMN_NAME"].include? "Id"
				tmp << row["COLUMN_NAME"]
			end
		end
		$tables_message += "<div>#{t}:" + tmp.join(',') + "</div>"
		result.cancel
	end
	$rules_form = $rules_form_html
end

def generate_sql tables,rules,function_parameters,function_choice,axis
	table_letters = []
	foreign_rules = []
	tables.each_with_index do |t,i|
		table_letters[i] = "A#{i}"
		rules.each_with_index do |r,j|
			if t == r.split('.')[0]
				rules[j] = "#{table_letters[i]}.#{rules[j].split('.')[1]}"
			end
		end
	end
	tables.each_with_index do |t,i|
		result = $database_client.execute("EXEC sp_fkeys N'#{t}'")
		result.each do |row|
			if tables.include? row["FKTABLE_NAME"]
				foreign_index = tables.index(row["FKTABLE_NAME"])
				foreign_rules << "#{table_letters[i]}.#{row["PKCOLUMN_NAME"]} = #{table_letters[foreign_index]}.#{row["FKCOLUMN_NAME"]}"
			end
		end
	end
	function = ""
	if function_choice == "Count" || function_choice == "Avg"
		if tables.include? function_parameters
			sql = "SELECT Col.Column_Name from 
		    INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
		    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
			WHERE 
		    Col.Constraint_Name = Tab.Constraint_Name
		    AND Col.Table_Name = Tab.Table_Name
		    AND Constraint_Type = 'PRIMARY KEY'
		    AND Col.Table_Name = '#{function_parameters}'"
		    result = $database_client.execute(sql)
		    primary_key = result.each[0]["Column_Name"]
		    result.cancel
			index = tables.index(function_parameters)
			function = "#{function_choice}(#{table_letters[index]}.#{primary_key}) AS #{function_choice}"
		elsif function_parameters.include? '.'
			table = function_parameters.split('.')[0]
			attribute = function_parameters.split('.')[1]
			if tables.include? table
				index = tables.index(table)
				function = "#{function_choice}(#{table_letters[index]}.#{attribute}) AS #{function_choice}"
			else
				$error_message = "No such table: #{table}"
				return
			end	
		else
			$error_message = "Something went wrong with the function"
			return
		end
	end

	select = ''
	x = ''
	y = ''
	if function_choice == "None"
		xaxis = axis.split(',')[0]
		yaxis = axis.split(',')[1]
		xtable = xaxis.split('.')[0]
		ytable = yaxis.split('.')[0]
		xattr = xaxis.split('.')[1]
		yattr = yaxis.split('.')[1]
		if tables.include? xtable and tables.include? ytable
			xindex = tables.index(xtable)
			yindex = tables.index(ytable)
			x = "#{table_letters[xindex]}.#{xattr}"
			y = "#{table_letters[yindex]}.#{yattr}"
		end
	else
		xtable = axis.split('.')[0]
		xattr = axis.split('.')[1]
		if tables.include? xtable
			xindex = tables.index(xtable)
			x = "#{table_letters[xindex]}.#{xattr}"
			y = function
		end
	end

	#Form sql
	select = "SELECT #{x}, #{y} FROM"
	sql = select
	tables.each_with_index do |t,i|
		sql += " #{t} #{table_letters[i]},"
	end
	sql.gsub!(/,$/,'') # remove trailing comma
	unless foreign_rules.empty? and rules.empty?
		sql += " WHERE"
		foreign_rules.each do |fr|
			sql += " #{fr} AND"
		end
		rules.each do |r|
			sql += " #{r} AND"
		end
		sql.gsub!(/AND$/,'') # remove trailing AND
	end
	if function_choice != "None"
		sql += " GROUP BY #{x}"
	else
		sql += " GROUP BY #{x}, #{y}"
	end

	return sql
end

def query_configuration params
	rules 					= params["rules"].split(',')
	function_parameters 	= params["function-parameters"]
	function_choice 		= params["function-choice"]
	axis 					= params["axis"]

	generate_sql $query_tables,rules,function_parameters,function_choice,axis

end

def database_execute_query sql
	puts sql
	result = $database_client.execute(sql)
	data_xlabel = result.fields[0]
	data_ylabel = result.fields[1]
	data_freqs = []
	data_bins = []
	result.each do |r|
		data_bins << r[data_xlabel]
		data_freqs << r[data_ylabel]
	end
	data = [data_xlabel,data_ylabel,data_freqs,data_bins]
	result.cancel
	return data
end

def plot data
	x = data[0]
	y = data[1]
	freqs = data[2]
	data[3].each_with_index do |d,i|
		if d==true
			data[3][i] = "Yes"
		elsif d==false
			data[3][i] = "No"
		end
		data[3][i] = data[3][i].to_s
	end
	bins = data[3]
	puts data
	plot = Nyaplot::Plot.new
	plot.add(:bar, bins, freqs)
	plot.x_label(x)
	plot.y_label(y)
	plot.width(1800)
	plot.height(750)
	plot.legend true
	plot.rotate_x_label(300)
	plot.export_html("public/bar.html")
end

database_read_tables

get '/' do
	$query_tables = []
	$error_message = ''
	$label1 = ''
	$tables_message = ''
	$rules_message = ''
	$rules_form = ''
 	erb :index, :layout => :'layout'
end

post '/tables' do
	$query_tables = []
	$error_message = ''
	$label1 = ''
	$tables_message = ''
	$rules_message = ''
	$rules_form = ''
	database_read_table_attrs params["tables"].split(',')
	erb :index, :layout => :'layout'
end

post '/query_submit' do
	puts params
	sql = query_configuration params
	data = database_execute_query(sql)
	plot(data)
	File.read(File.join('public', 'bar.html'))
end
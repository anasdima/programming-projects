require 'sinatra'
require 'tiny_tds'
require 'nyaplot'

set :bind, '0.0.0.0'

$database_client = TinyTds::Client.new username: 'Main\Tasos', password: 'password', host: 'localhost', database: 'HMMYStat'

def grades_all_time
	grade_freqs = []
	bins = []
	result = $database_client.execute("SELECT Grade,COUNT(*) AS C FROM [Grades] GROUP BY Grade ORDER BY Grade ASC")
	result.each do |r|
		grade_freqs << r["C"].to_i
		bins << r["Grade"].to_s
	end
	result.cancel
	plot(bins,grade_freqs,"Βαθμοί","Αριθμός βαθμών")
end

def plot bins,freqs,x,y
	plot = Nyaplot::Plot.new
	plot.add(:bar, bins, freqs)
	plot.x_label(x)
	plot.y_label(y)
	plot.export_html("public/bar.html")
end

get '/' do
  	File.read('public/index.html')
end

post '/grades_all_time' do
	assert = grades_all_time
  	File.read('public/index.html')
end
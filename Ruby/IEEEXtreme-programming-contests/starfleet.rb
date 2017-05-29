#!/usr/bin/ruby

Flight = Struct.new(:Start, :Start_Date, :Start_Time, :End, :End_Date, :End_Time)
Query = Struct.new(:Start, :Start_Date, :Start_Time, :End)


input = gets.chomp.split.map(&:to_i)

p = input[0]
f = input[1]
q = input[2]

space_ports = []
0...p.times do |i|
	space_ports << gets.chomp
end

flights = Array.new(f) 

0...f.times do |i|
	flights[i] = Flight.new(*gets.chomp.split)
end

queries = Array.new(q)

0...q.times do |i|
	queries[i] = Query.new(*gets.chomp.split)
end

queries.each do |query|
	puts
	puts query
	start_flights = []
	end_flights = []
	flights.each do |flight|
		if flight.End == query.End then
			end_flights << flight
		end
	end
	puts start_flights
	puts end_flights
end



			
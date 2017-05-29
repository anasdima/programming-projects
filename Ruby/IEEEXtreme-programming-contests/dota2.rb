#!/usr/bin/ruby

input = gets.chomp.split.map(&:to_i)

N = input[0]
M = input[1]

hero_value = {}
hero_affinity = {}

affinities = {
	"Intelligence" => 0.0,
	"Strength" => 0.0,
	"Agility" => 0.0
}

0...N.times do |i|
	input = gets.chomp.split(',')
	tmp = input[2].split(':').map(&:to_f)
	fi = tmp[0]/(tmp[0]+tmp[1])*100
	fi = fi.floor
	hero_value[input[0]] = (fi*(i+1)).floor
	hero_affinity[input[0]] = input[1]
end

#hero_value["Spectre"] = 180

#puts hero_value.select {|k,v| v==180}

values = []
hero_value.each_value do |val|
	values << hero_value.select {|k,v| v==val}.values.uniq
end

values.sort!.reverse!.flatten!.uniq!

#print values
#puts

i = 0
count = 0
flag = true
while flag
	output = hero_value.select {|k,v| v==values[i]}.keys
	output.each do |k|
		puts k
		count += 1
		if count == M then 
			flag = false
			break
		end
	end
	i += 1
end


i = 0
count = 0
flag = true
while flag
	output = hero_value.select{|k,v| v==values[i]}.keys
	output.each do |k|
		affinities[hero_affinity[k]] +=1
		count += 1
		if count == M then 
			flag = false
			break
		end
	end
	i += 1
end

puts
puts "This set of heroes:"
puts "Contains %0.2f percentage of Intelligence" %(affinities["Intelligence"]*100/M)
puts "Contains %0.2f percentage of Strength" %(affinities["Strength"]*100/M)
puts "Contains %0.2f percentage of Agility" %(affinities["Agility"]*100/M)

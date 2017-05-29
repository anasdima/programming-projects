#!/usr/bin/ruby

seq = gets.chomp.split

K = seq[0].to_i

seq.delete_at(0)

def nekops(string)
	prev = ''
	count =  1
	output = ''
	string.split.each do |e|
		 if e == prev then
		 	puts e
		 	puts prev
		 	count += 1
		 else
		 	if prev != '' then
		 		output << '%d '%count + '%d '%prev.to_i
		 	end
		 	count == 1
		 end
		 prev = e
	end
	output << '%d '%count + '%d'%prev.to_i
	return output.rstrip
end

sequences = Array.new(K + 1)
sequences[0] = seq.join(' ')

1...K.times do |i|
	puts sequences[i]
	sequences[i+1] = nekops(sequences[i])
end
puts sequences[-1]
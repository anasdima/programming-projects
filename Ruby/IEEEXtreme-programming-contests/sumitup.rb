#!/usr/bin/ruby

N = gets.chomp.to_i
array = gets.chomp.split.map(&:to_i)
Q = gets.chomp.to_i
0...Q.times do |i|
	x = gets.chomp.to_i
	if x > 0 then
		array_new = array[-x..-1] + array 
	else
		array_new = array
	end
	array.each_with_index do |e, i|
		array[i] += array_new[i]
	end
end
puts (array.reduce(:+) % (10**9+7))



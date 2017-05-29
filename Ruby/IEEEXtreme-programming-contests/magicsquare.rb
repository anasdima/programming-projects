#!/usr/bin/ruby

N = gets.chomp.to_i
#M = N*(N**2+1)/2
square = Array.new(N)

N.times do |i|
	square[i] = gets.chomp.split.map(&:to_i)
end

line_sums = Array.new(N,0)
row_sums = Array.new(N,0)
anti_diagonal_sum = 0
main_diagonal_sum = 0

N.times do |i|
	line_sums[i] = square[i][0..-1].reduce(:+)
	N.times do |j|
		row_sums[i] += square[j][i]
	end
	anti_diagonal_sum += square[i][N-i-1]
	main_diagonal_sum += square[i][i]
end

count = 0
wrong_lines = []
N.times do |k|
	if line_sums[k] != main_diagonal_sum then
		count += 1
		wrong_lines << k + 1
	end
	if row_sums[k] != main_diagonal_sum then
		count += 1
		wrong_lines << -k -1 
	end
end

if anti_diagonal_sum != main_diagonal_sum then
	count +=1
	wrong_lines << 0
end


=begin

print line_sums
puts
print row_sums
puts
puts anti_diagonal_sum
puts main_diagonal_sum


=end

puts count
puts wrong_lines.sort if count
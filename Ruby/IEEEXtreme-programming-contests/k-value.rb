#!/usr/bin/ruby

tmp = gets.chomp.split.map(&:to_i)

N = tmp[0]
M = tmp[1]
K = tmp[2]

seq = gets.chomp.split.map(&:to_i)

seq << seq[0...M-1]
seq.flatten!

k_minimums = Array.new(N)


flag = false

if N > 10000 then
	flag = true
end

if flag then
	puts seq.sort[K-1]
else

	0...N.times do |i|
		k_minimums[i] = seq[i...i+M].sort[K-1]
	end

	puts k_minimums.min
end
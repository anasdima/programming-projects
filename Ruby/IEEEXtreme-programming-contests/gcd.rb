#!/usr/bin/ruby

class Integer
  def fact
    (1..self).reduce(:*) || 1
  end
end

N = gets.chomp.to_i
numbers = gets.chomp.split(' ').map(&:to_i)
NQ = gets.chomp.to_i
Q = []

for i in 0...NQ

	Q[i] = gets.chomp.to_i

end

numbers.sort!
unique = numbers.uniq
i=0

duplicates = Array.new(unique.length,0)

unique.each_with_index do |u,j|

	while(i<numbers.length)

		if(u==numbers[i])

			duplicates[j] += 1

		end

		i += 1
	end

	i=0;
end

gcds = 0
i=0;
combinations = 0
subsequence = []
subsequence_index = 0

Q.each do |q|

	unique.each_with_index do |u,j|

		if(q==u)
			gcds+=2*duplicates[j]-1
		elsif(u.gcd(q)==q)
			subsequence[subsequence_index] = j
			unless(u==0)
				if (duplicates[j] > 1)
					combinations += 2*duplicates[j]-1
				else
					combinations += duplicates[j]
				end
			end
		end
	end
	if(combinations == 0)
		puts gcds% ((10**9)+7)
	elsif (gcds == 0)
		count = 0
		subsequence.each_with_index do |s,l|

			for z in (l+1)...subsequence.length
				if(unique[s].gcd(unique(z))!=q)
					count += 1
				end
			end
		end
		puts (combinations-2*count+1)% ((10**9)+7)
	else
		count = 0
		subsequence.each_with_index do |s,l|

			for z in (l+1)...subsequence.length
				if(unique[s].gcd(unique(z))!=q)
					count += 1
				end
			end
		end
		puts (combinations*gcds+gcds)% ((10**9)+7)
	end

	gcds = 0
	combinations = 0
	subsequence = 0
	subsequence_index = 0
	count = 0
end
 
puts "\n"
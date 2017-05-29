# Aristotle University of Thessaloniki
# Department of Electronics And Computer Science
# Project: https://www.kaggle.com/c/titanic-gettingStarted
# Author: Dhmanidhs Tasos
# Description: Ruby script that finds passenger associations
# based on their ticket ID and calculates their individual fare.
# Input must be in the form of a list. The fare - ticket delimeter
# is 0000. Input ends with "END".

#!/usr/bin/ruby

#read fares from input
fare = []
fare[0] = gets.chomp.to_f
i=0

while(fare[i] != 1337)

	i += 1
	fare[i] = gets.chomp.to_f

end

#read tickets from input
ticket = []
ticket[0] = gets.chomp
i=0

while(ticket[i] != 'END')

	i+= 1
	ticket[i] = gets.chomp

end

ticket_uniq = ticket.uniq
associated_count = Array.new(ticket_uniq.length) { |a| a = 0} #init all values to zero

#find passengers that were traveling together using their ticket
k = 0
ticket_uniq.each_with_index do |tu,i|

	for j in k...(ticket.length)

		if (tu == ticket[j])
			associated_count[i] += 1
		else
			if (associated_count[i] == 0)
				associated_count[i] = 1
			end
		end
	end
	k += associated_count[i]
end

#calculate new fares based on passenger associations
i=0
k=0

while(k < fare.length)

	temp = fare[k]

	for j in k...(k+associated_count[i])

		fare[j] = temp/associated_count[i]

	end

	k+= associated_count[i]
	i+= 1

end

#output fare by person as a list
puts fare
# Aristotle University of Thessaloniki
# Department of Electronics And Computer Science
# Project: https://www.kaggle.com/c/titanic-gettingStarted
# Author: Dhmanidhs Tasos
# Description: Ruby script that receives as input a list
# of passenger cabins and outputs the letter of the deck
# of each cabin. Input ends with "END".

#!/usr/bin/ruby

#read cabins from input
cabins = []
cabins[0] = gets.chomp

i=0

while (cabins[i] != 'END')

	i = i + 1
	cabins[i] = gets.chomp

end

#find the deck fo each cabin
decks = []
cabins.each.with_index do |c,i|

	decks[i] = c[0]

end

#output decks as a list
puts decks
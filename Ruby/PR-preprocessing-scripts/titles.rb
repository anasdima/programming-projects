# Aristotle University of Thessaloniki
# Department of Electronics And Computer Science
# Project: https://www.kaggle.com/c/titanic-gettingStarted
# Author: Dhmanidhs Tasos
# Description: Ruby script that finds the titles of
# passengers through their name. Input ends with "END"

#!/usr/bin/ruby

alltitles = ["Mr.", "Master", "Mrs.", "Miss", "Rev.", "Dr.", "Don.", "Ms.",
 "Doctor.", "Mme.", "Major", "Lady", "Sir.", "Mlle.", "Col", "Capt.", "Countess", "Jonkheer"]

#read names from input.
names = []
names[0] = gets.chomp

i=0

while (names[i] != 'END')
	i = i + 1
	names[i] = gets.chomp
end

#find titles from names
titles = []
names.each.with_index do |n,i|
	alltitles.each do |t|
		if(n.include? t)
			titles[i] = t
			break
		end
	end
end

#output titles as a list
puts titles
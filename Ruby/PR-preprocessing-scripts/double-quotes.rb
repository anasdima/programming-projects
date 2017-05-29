#!/usr/bin/ruby

require 'csv'

File.foreach( '0.input.txt' ) do |line|
  puts line.gsub(/"/,"")
end
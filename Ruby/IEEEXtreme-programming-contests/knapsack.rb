#!/usr/bin/ruby

KnapsackItem = Struct.new(:name, :weight, :value)

class Array
  # do something for each element of the array's power set
  def power_set
    yield [] if block_given?
    self.inject([[]]) do |ps, elem|
      r = []
      ps.each do |i|
        r << i
        new_subset = i + [elem]
        yield new_subset if block_given?
        r << new_subset
      end
      r
    end
  end
end
 

input = gets.chomp.split.map(&:to_i)

N = input[0]
M = input[1]

flag = true

names = []
loads = []
values = [] 


while flag do
  input = gets.chomp.split(',')
  if input == ["END"] then 
    flag = false
  else
    names << input[0]
    loads << input[1].to_i
    values << input[2].to_i
  end
end

potential_items = []

n = names.length

0...n.times do |i|
  potential_items << KnapsackItem.new(names[i], loads[i], values[i])
  puts potential_items[i]
end

knapsack_capacity = N*M

maxval = 0
solutions = []
 
potential_items.power_set do |subset|
  weight = subset.inject(0) {|w, elem| w += elem.weight}
  next if weight > knapsack_capacity
 
  value = subset.inject(0) {|v, elem| v += elem.value}
  if value == maxval
    solutions << subset
  elsif value > maxval
    maxval = value
    solutions = [subset]
  end
end
 
puts "value: #{maxval}"
solutions.each do |set|
  items = []
  wt = 0
  set.each {|elem| wt += elem.weight; items << elem.name}
  puts "weight: #{wt}"
  puts "items: #{items.sort.join(',')}"
end

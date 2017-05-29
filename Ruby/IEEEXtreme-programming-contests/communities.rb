#!/usr/bin/ruby

class Node
    @@count = 0
    attr_accessor :id, :subscriptions, :name
    def initialize(name)
        @subscriptions = []
        @@count = @@count + 1
        @id = @@count
        @name = name
    end
end

input = gets.chomp.split.map(&:to_i)
n = input[0]
m = input[1]

input = gets.chomp.split
peopleNames = {}
until input[0] == 'END'
    unless peopleNames.include? input[0]
        peopleNames[input[0]] = Node.new (input[0])
    end
    unless peopleNames.include? input[1]
        peopleNames[input[1]] = Node.new (input[1])
    end
    peopleNames[input[1]].subscriptions.push peopleNames[input[0]]
    input = gets.chomp.split
end

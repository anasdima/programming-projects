#!/usr/bin/ruby

class Node
    attr_accessor :state, :round, :children, :parent
    def initialize(state, round=0, children=[], parent=nil)
    	@state = state
    	@children = children
        @round = round
        @parent = parent
    end
end

def winner_loser(parent_state, child_state)
    if parent_state[0] == child_state[0]
        sleeperID = 0
    elsif parent_state[1] == child_state[1]
        sleeperID = 1
    elsif parent_state[2] == child_state[2]
        sleeperID = 2
    end

    if sleeperID == 0
        if child_state[1] > parent_state[1]
            return "2,3 "
        else
            return "3,2 "
        end
    elsif sleeperID == 1
        if child_state[0] > parent_state[0]
            return "1,3 "
        else
            return "3,1 "
        end
    elsif sleeperID == 2
        if child_state[0] > parent_state[0]
            return "1,2 "
        else
            return "2,1 "
        end
    end
end

def poker(state, sleeperID)
    if sleeperID == 0
        if state[1] > state[2]
            state[1] = state[1] - state[2]
            state[2] = 2*state[2]
        else
            state[2] = state[2] - state[1]
            state[1] = 2*state[1]
        end
    elsif sleeperID == 1
        if state[0] > state[2]
            state[0] = state[0] - state[2]
            state[2] = 2*state[2]
        else
            state[2] = state[2] - state[0]
            state[0] = 2*state[0]
        end
    else
        if state[0] > state[1]
            state[0] = state[0] - state[1]
            state[1] = 2*state[1]
        else
            state[1] = state[1] - state[0]
            state[0] = 2*state[0]
        end
    end
    return state
end

def print_path(path)
    path.each do |e|
        print e.to_s + ' '
    end
    puts
end

round = 0;
startingState = Node.new(gets.chomp.split.map(&:to_i))

queue = []
queue.push(startingState)
final_depth = -1
final_nodes = []
first_time = true
queue.each do |e|
    node = queue.pop
    if node.state.include? 0
        if final_depth == -1
            final_depth = node.round
            final_nodes.push(node)
        elsif final_depth == node.round
            final_nodes.push(node)
        end
    end
    if node.round > final_depth && final_depth != -1
        break
    elsif node.round == 10
        puts 'Ok'
        exit
    end
    node.state.each_with_index do |m, i|
        child = Node.new(poker(node.state.clone, i), node.round + 1, [], node)
        node.children.insert(0, child)
        queue.insert(0, child)
    end
end


final_nodes.each do |node|
    node.children = []
end

paths = Array.new(final_nodes.length, "")
final_nodes.each_with_index do |node, i|
    while node.parent
        paths[i] = winner_loser(node.parent.state, node.state).strip! + ' ' + paths[i]
        # p node.state
        # p paths[i]
        node = node.parent
    end
end

# p final_nodes

paths.sort!
node = startingState.state
print_path(node)
paths[0].split.each do |path|
    w = path.split(',').map(&:to_i)
    node[w[1]-1] = node[w[1]-1] - node[w[0]-1]
    node[w[0]-1] = 2 * node[w[0]-1]
    print_path(node)
end

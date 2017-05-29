@args = []
f = File.open("input.txt", "r")
f.each_line do |line|
  @args << line
end
#read C matrix from file
@n = @args[0].split(',')[0].to_i
@k = @args[0].split(',')[1].to_i
@c = @args[1..@k]
if @c.size != @k
  puts "Table size must be #{@k}x#{@n} as defined in the first line of the input"
  exit
end
@c.each.with_index do |v,i|
  @c[i] = v.split(' ').map(&:to_i)
  if @c[i].length != @k
    puts "Table size must be #{@k}x#{@n} as defined in the first line of the input"
    exit
  end
end
@w = @args[@k+1].split(' ').map(&:to_i)

c_true = Hash.new {|h,k| h[k] = Array.new}
c_false = Hash.new {|h,k| h[k] = Array.new}

for i in 0...@n
	for j in 0...@k
		if 	@c[j][i] == 1
			c_true[i] << j
		elsif @c[j][i] == -1
			c_false[i] << j
		end
	end
	if c_true[i] == nil
		c_true[i] = []
	end
	if c_false[i] == nil
		c_false[i] == []
	end
end

combinations = c_false.values.zip(c_true.values).reduce(&:product).map(&:flatten).map(&:uniq!)
weights_of_combinations = Hash.new {|h,k| h[k] = 0}
combinations.each_with_index do |c,i|
	if c != nil
		c.each do |expression|
			weights_of_combinations[i] += @w[expression]
		end
	else
		weights_of_combinations[i] = (@w.min)-1 #if no expressions contribute in the combination due to 0s,
		# assign an arbitraty minimum weight to the combination (lesser than the minimum of the given weights by 1)
	end
end
max_weight = weights_of_combinations.values.max
weights_of_combinations.values.each_with_index do |w,i|
	unless w == nil
		if w == max_weight
			puts "%0#{@n}b" % i
		end
	end
end
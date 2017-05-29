@args = []
f = File.open("input_adjacency.txt", "r")
f.each_line do |line|
  @args << line
end
#read adjacency matrix from file
@v = @args[0].to_i
@t = @args[1..@v]
if @t.size != @v
	puts "Table size must be #{@v}x#{@v} as defined in the first line of the input"
	exit
end
@t.each.with_index do |v,i|
	@t[i] = v.split(' ').map(&:to_i)
	if @t[i].length != @v
		puts "Table size must be #{@v}x#{@v} as defined in the first line of the input"
		exit
	end
end

#calculate component matrix from adjacency matrix
adjacents = Hash.new {|h,k| h[k] = Array.new}
@t.each.with_index do |v,i|
	v.each_with_index do |av,j|
		if av == 1
			adjacents[i] << j
		end
	end
end
checked = []
components = Hash.new {|h,k| h[k] = Array.new}
chain = []
i = 0;
for v in 0...@v
	unless checked.include? v
		components[i] << v
		checked << v
		unless adjacents[v].length == 0
			chain << adjacents[v] #
			chain.flatten!
			while chain - checked != []
				temp = []
				chain.each do |c|
					components[i] << c
					checked << c
					adjacents[c].each do |a|
						unless (checked.include? a) || (chain.include? a)
							temp << a
						end
					end
				end
				temp.uniq!
				chain = temp
			end
		end
		i += 1
	end
end
components.each {|c,v| v.sort!}
new_order = (components.values.sort_by {|v| v.length}).reverse.flatten
component_matrix = Hash.new {|h,k| h[k] = Array.new}
for i in 0...@v
	for j in 0...@v
		component_matrix[i][j] = @t[new_order[i]][new_order[j]]
	end
end
component_matrix.each do |c,v|
	puts v.to_s
end


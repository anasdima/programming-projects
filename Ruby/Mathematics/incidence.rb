@args = []
f = File.open("input_incidence.txt", "r")
f.each_line do |line|
  @args << line
end
#read incidence matrix from file
@v 	= @args[0].split(',')[0].to_i
@e 	= @args[0].split(',')[1].to_i
@t 	= @args[1..@v]
if @t.size != @v
	puts "Table size must be #{@v}x#{@e} as defined in the first line of the input"
	exit
end
@t.each.with_index do |v,i|
	@t[i] = v.split(' ').map(&:to_i)
	if @t[i].length != @e
		puts "Table size must be #{@v}x#{@e} as defined in the first line of the input"
		exit
	end
end

#calculate component matrix from incidence matrix
edges_of_vertice = Hash.new {|h,k| h[k] = Array.new}
@t.each.with_index do |v,i|
	v.each_with_index do |av,j|
		if av == 1
			edges_of_vertice[i] << j
		end
	end
end
vertices_of_edge = Hash.new {|h,k| h[k] = Array.new}
for i in 0...@e
	for j in 0...@v
		if @t[j][i] == 1
			vertices_of_edge[i] << j
		end
	end
end
checked_edges = []
checked_vertices = []
components_vertices = Hash.new {|h,k| h[k] = Array.new}
components_edges 	= Hash.new {|h,k| h[k] = Array.new}
vertice_chain = []
i = 0;
for e in 0...@e
	unless checked_edges.include? e
		if vertices_of_edge[e].length != 0
			vertice_chain << vertices_of_edge[e]
			vertice_chain.flatten!
			while vertice_chain-checked_vertices != []
				temp = []
				vertice_chain.each do |c|
					components_vertices[i] << c
					checked_vertices << c
					unless edges_of_vertice[c] == 0
						edges_of_vertice[c].each do |ev|
							unless checked_edges.include? ev
								checked_edges << ev
								components_edges[i] << ev
								vertices_of_edge[ev].each do |ve|
									unless (checked_vertices.include? ve) || (vertice_chain.include? ve)
										temp << ve
									end
								end
							end
						end
					end
				end
				temp.uniq!
				vertice_chain = temp
			end
		else
			components_vertices[i] << nil
			components_edges[i] << e
		end
		i += 1
	end
end
@t.each.with_index do |v,j|
	if v.uniq.length == 1
		if v.uniq == [0]
			components_vertices[i] << j
			components_edges[i] << nil
			i += 1
		end
	end
end

components_vertices.each {|c,v| v.sort!}
components_edges.each {|c,e| e.sort!}
new_vertice_order = (components_vertices.values.sort_by {|v| v.length}).reverse.flatten
new_edge_order = (components_edges.values.sort_by {|v| v.length}).reverse.flatten

component_matrix = Hash.new {|h,k| h[k] = Array.new}
for i in 0...@v
	for j in 0...@e
		if new_vertice_order[i] == nil || new_edge_order[j] == nil
			component_matrix[i][j] = 0
		else
			component_matrix[i][j] = @t[new_vertice_order[i]][new_edge_order[j]]
		end
	end
end
component_matrix.each do |c,v|
	puts v.to_s
end
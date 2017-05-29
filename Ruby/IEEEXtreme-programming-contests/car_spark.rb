#!/usr/bin/ruby

def opt(n, i, start_times, finish_times)
    (i-1).downto(0).each do |j|
        if finish_times[j] <= start_times[i]
            return j
        end
    end
    return -1
end

T = gets.chomp.to_i

T.times do
    n = gets.chomp.to_i
    start_times =  Array.new(n, 0)
    finish_times =  Array.new(n, 0)
    lease_amount =  Array.new(n, 0)
    input_hash = {}
    n.times do |i|
        input_hash[i] = gets.chomp.split.map(&:to_i)
    end

    tmp = input_hash.sort_by { |k, v| v[1]}

    n.times do |i|
        input = tmp[i]
        start_times[i] = input[1][0]
        finish_times[i] = input[1][1]
        lease_amount[i] = input[1][2]
    end

    c = Array.new(n+1)
    c[0] = 0

    q = Array.new(n)
    (0...n).each do |i|
        q[i] = opt(n, i,start_times,finish_times)
    end

    (1..n).each do |j|
        profitExcluding = c[j-1]
        profitIncluding = lease_amount[j-1]
        if q[j-1] != -1
            profitIncluding  = profitIncluding + c[q[j-1]+1]
        end
        c[j] = [profitIncluding,profitExcluding].max

    end
 p c[-1]
end

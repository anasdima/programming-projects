#!/usr/bin/ruby

PRIMITIVES = (0..9).collect { |i| i.to_s } + ('a'..'z').to_a + ('A'..'Z').to_a

def base62encode(int)
    raise ArgumentError, "Can't Base62 encode negative number (#{int} given)" if int < 0
    return "0" if int == 0

    result = ''
    while int > 0
        result.prepend PRIMITIVES[int % PRIMITIVES.size]
        int /= PRIMITIVES.size
    end

    result
end


base = gets.chomp
N = gets.chomp.to_i

N.times do
    target = gets.chomp

    baseHex = base.codepoints.to_a.map(&:to_i)
    targetHex = target.codepoints.to_a.map(&:to_i)
    baseHexPadded = []
    if targetHex.length > baseHex.length
        baseHex.cycle do |b|
            if targetHex.length - baseHexPadded.length <= 0
                break
            end
            baseHexPadded.push b
        end
    else
        baseHexPadded = baseHex[0...targetHex.length]
    end

    xoredBytes = Array.new(targetHex.length)
    baseHexPadded.each_with_index do |b, i|
        xoredBytes[i] = b ^ targetHex[i]
    end

    sum = 0;
    xoredBytes[-8..-1].each_with_index do |x, i|
        sum = sum + x*16**(14-2*i)
    end

    puts base + '/' +  base62encode(sum)
end

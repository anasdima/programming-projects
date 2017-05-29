#!/usr/bin/ruby

class String
  def is_number?
    true if Float(self) rescue false
  end
end

toppingCallories = {
	"Anchovies"=>	50,
	"Artichoke"=>	60,
	"Bacon"=>		92,
	"Broccoli"=>	24,
	"Cheese"=>		80,
	"Chicken"=>		30,
	"Feta"=>		99,
	"Garlic"=>		 8,
	"Ham"=>			46,
	"Jalapeno"=>	 5,
	"Meatballs"=>  120,
	"Mushrooms"=>	11,
	"Olives"=>		25,
	"Onions"=>		11,
	"Pepperoni"=>	80,
	"Peppers"=>		 6,
	"Pineapple"=>	21,
	"Ricotta"=>	   108,
	"Sausage"=>	   115,
	"Spinach"=>		18,
	"Tomatoes"=>	14
}

input = gets.chomp.split

N = input[0].to_i
pizzaCalories = Array.new(N,270)

input.delete_at(0)

count = -1
multiplier = 1
calorie_sum =0

input.each do |e|
	if e.is_number? then
		count += 1
		multiplier = e.to_i
		pizzaCalories[count] *= multiplier
	else
		e.split(',').each do |topping|
			pizzaCalories[count] += toppingCallories[topping]*multiplier
		end
	end
end

puts "The total calorie intake is %d"%pizzaCalories.reduce(:+)
extends Node2D

signal parsed_equation(list)
signal numbers_hidden(list)
signal win_game()
signal incorrect()
signal set_title(title)

var equation = ""
var num_equations = 6
var max_number = 30
var nodes_shown = 7
var operations = ["+", "-", "*", "/", "%"]

var numberList = []
var hideList = []
var sumList = []
var setup = false
var rng
var used_div_mult_one = false

func _ready():
	if not setup:
		if Game.puzzle_data:
			num_equations = Game.puzzle_data.num_equations
			max_number = Game.puzzle_data.max_number
			nodes_shown = Game.puzzle_data.nodes_shown
			operations = Game.puzzle_data.operations
			emit_signal("set_title", "Daily " + Game.puzzle_data.name + " Puzzle")
			rng = RandomNumberGenerator.new()
			var date = Time.get_date_string_from_system()
			#date = "2024-04-19"
			date += Game.puzzle_data.name
			#date = "1996-12-19"
			#date = "2024-04-17"
			rng.seed = hash(date)
			#rng.randomize()
			generate_daily_puzzle()
		else:
			equation = Game.puzzlebook_equations[Game.equation]
			var puzzle_names = ["Beginner Puzzle 1", "Beginner Puzzle 2", "Beginner Puzzle 3", "Novice Puzzle 1", "Novice Puzzle 2", "Novice Puzzle 3", "Expert Puzzle 1", "Expert Puzzle 2", "Expert Puzzle 3"]
			emit_signal("set_title", puzzle_names[Game.equation])
		parse_equation()
		var is_valid = check_solution_valid(numberList)
		if is_valid:
			print("Valid Equation")
		else:
			print("Invalid Equation")
		emit_signal("parsed_equation", numberList)
		create_sum_list()
		hide_numbers()
		setup = true
		
func generate_daily_puzzle():
	var equation_string = ""
	var num_nodes = num_equations * 4
	var starting_num = rng.randi_range(1, max_number)
	var num_a = starting_num
	var previous_numbers = [0,0,0]
	used_div_mult_one = false
	equation_string += str(starting_num)
	for i in range(num_equations-1):
		var results = [-1,-1]
		var random_operation = "+"
		var current_numbers = [0,0,0]
		while results == [-1,-1]:
			random_operation = operations[rng.randi_range(0,operations.size()-1)]
			while (not is_operation_valid(num_a, random_operation)):
				random_operation = operations[rng.randi_range(0,operations.size()-1)]
			results = find_number_for_operation(num_a, random_operation)
			current_numbers = [num_a, results[0], results[1]]
			if (matching_numbers(current_numbers, previous_numbers)):
				#print("Double Trouble!")
				results = [-1,-1]
		equation_string += random_operation + str(results[0]) + "=" + str(results[1])
		previous_numbers = current_numbers
		num_a = results[1]
	var final_operation_and_number = find_best_final_operation_and_number(num_a, starting_num)
	equation_string += final_operation_and_number[0] + str(final_operation_and_number[1]) + "="
	equation = equation_string
	
func matching_numbers(current_numbers, previous_numbers):
	var current1 = int(current_numbers[0])
	var matching1 = previous_numbers.has(current1)
	var current2 = int(current_numbers[1])
	var matching2 = previous_numbers.has(current2 )
	var current3 = int(current_numbers[2])
	var matching3 = previous_numbers.has(current3)
	return matching1 and matching2 and matching3
	
func is_number_allowed(number):
	if floor(number) == number and number > 0 and number <= max_number:
		return true
	else: 
		return false
		
func is_operation_valid(num, operation):
	if (operation == "+"):
		return num < max_number - 1
	elif (operation == "-"):
		return num > 1
	elif (operation == "*"):
		return num > 1
	elif (operation == "/"):
		return num > 1
	elif (operation == "%"):
		return num > 1
		
func find_number_for_operation(starting_number, operation):
	var result = -1
	var suggested_number = 1
	if (operation == "+"):
		suggested_number = 1
		while not is_number_allowed(result):
			suggested_number = rng.randi_range(1, max_number)
			result = starting_number + suggested_number
	elif (operation == "-"):
		suggested_number = 1
		while not is_number_allowed(result):
			suggested_number = rng.randi_range(1, starting_number-1)
			result = starting_number - suggested_number
	elif (operation == "*"):
		suggested_number = 1
		var attempts = 0
		while not is_number_allowed(result):
			if (attempts > 100):
				return [-1,-1]
			var min_lim = 2
			if used_div_mult_one:
				min_lim = 2
			suggested_number = rng.randi_range(min_lim, max_number-1)
			result = starting_number * suggested_number
			attempts += 1
		if suggested_number == 1 or starting_number == 1:
			used_div_mult_one = true
	elif (operation == "/"):
		suggested_number = 1
		var attempts = 0
		while not is_number_allowed(result):
			if (attempts > 100):
				return [-1,-1]
			var min_lim = 1
			suggested_number = rng.randi_range(2, starting_number-1)
			if (suggested_number == 0):
				suggested_number = min_lim
			result = float(starting_number) / suggested_number
			attempts += 1
		if suggested_number == 1 or starting_number == 1:
			used_div_mult_one = true
	elif (operation == "%"):
		suggested_number = 1
		var attempts = 0
		while not is_number_allowed(result) or result == starting_number - suggested_number:
			if (attempts > 100):
				return [-1,-1]
			var min_lim = 2
			suggested_number = rng.randi_range(2, starting_number-1)
			if (suggested_number == 0):
				suggested_number = min_lim
			result = int(starting_number) % int(suggested_number)
			attempts += 1
		if suggested_number == 1 or starting_number == 1:
			used_div_mult_one = true
	return [suggested_number, result]
	
func find_best_final_operation_and_number(num_a, result):
	var num_b = ["=", 0]
	var valid_nums = []
	var num_b_addition = result - num_a
	if is_number_allowed(num_b_addition) and operations.has("+"):
		valid_nums.append(["+", num_b_addition])
	var num_b_subtraction = -result + num_a
	if is_number_allowed(num_b_subtraction) and operations.has("-"):
		valid_nums.append(["-", num_b_subtraction])
	var num_b_multiplication = float(result) / num_a
	if is_number_allowed(num_b_multiplication) and operations.has("*"):
		valid_nums.append(["*", num_b_multiplication])
	var num_b_division = float(num_a) / result
	if is_number_allowed(num_b_division) and operations.has("/"):
		valid_nums.append(["/", num_b_division])
	var num_b_modulo = num_a - result
	if is_number_allowed(num_b_modulo) and operations.has("%") and num_b_modulo != 1 and int(num_a) % int(num_b_modulo) == result:
		valid_nums.append(["%", num_b_modulo])
	
	if valid_nums.size() > 0:
		num_b = valid_nums[rng.randi_range(0, valid_nums.size()-1)]
	else:
		push_error("Error with puzzle creation")
		
	return num_b
	
func parse_equation():
	numberList = []
	var currentNumber = ""
	for character in equation:
		if (Numbers.is_operator(character)):
			numberList.append(currentNumber)
			numberList.append(character)
			currentNumber = ""
		else:
			currentNumber += character
	if (currentNumber.length() > 0):
		numberList.append(currentNumber)
		
func create_sum_list():
	var previous_was_equals = false
	var current_sum = ""
	for num in numberList:
		current_sum += num
		if previous_was_equals:
			sumList.append(current_sum)
			current_sum = num
			previous_was_equals = false
		if num == "=":
			previous_was_equals = true
	current_sum += numberList[0]
	sumList.append(current_sum)
	current_sum = ""
	
func hide_numbers():
	hideList = []
	if Game.puzzle_data:
		var non_equals_nodes = []
		for num in numberList:
			if num == "=":
				continue
			non_equals_nodes.append(num)
		
		var shown_node_indices = []
		while shown_node_indices.size() < nodes_shown:
			var random_index = rng.randi_range(0, non_equals_nodes.size()-1)
			if (not shown_node_indices.has(random_index)):
				shown_node_indices.append(random_index)
			
		var non_equals_index = 0
		for i in range(numberList.size()):
			if numberList[i] == "=":
				hideList.append(false)
			else:
				if shown_node_indices.has(non_equals_index):
					hideList.append(false)
				else:
					hideList.append(true)
				non_equals_index += 1
	else:
		for i in range(numberList.size()):
			if Game.equation_hiding[Game.equation][i] == "1":
				hideList.append(true)
			else:
				hideList.append(false)
		
	emit_signal("numbers_hidden", hideList)
		
func hide_numbers_old():
	var previous_num_was_equals = false
	hideList = []
	var first_number = true
	var first_equal = true
	for num in numberList:
		if first_number:
			hideList.append(false)
			first_number = false
			continue
			
		if num == "=":
			hideList.append(false)
			previous_num_was_equals = true
			continue
			
		if (previous_num_was_equals):
			var prob = rng.randf()
			var should_show = prob > 0.3 or first_equal
			hideList.append(not should_show)
			previous_num_was_equals = false
			first_equal = false
			continue
			
		var prob = rng.randf()
		hideList.append(prob > 0.3)
		
	emit_signal("numbers_hidden", hideList)


func _on_ui_try_answer(answer):
	if (answer == numberList or check_solution_valid(answer)):
		emit_signal("win_game")
	elif not answer.has("_"):
		GlobalAudio.play_incorrect_sound()
		emit_signal("incorrect")
		
func check_solution_valid(equationNumberList):
	var num_sums = equationNumberList.size() / 4
	
	if equationNumberList.has("_"):
		return false
	
	for i in range(num_sums):
		var start_of_sum = i * 4
		var num_a = int(equationNumberList[start_of_sum])
		var num_b = int(equationNumberList[start_of_sum+2])
		var correct_result = int(equationNumberList[(start_of_sum+4)%equationNumberList.size()])
		var operator = equationNumberList[start_of_sum+1]
		var equation_result = 0
		if (operator == "+"):
			equation_result = num_a + num_b
		elif (operator == "-"):
			equation_result = num_a - num_b
		elif (operator == "*"):
			equation_result = num_a * num_b
		elif (operator == "/"):
			equation_result = num_a / num_b
		elif (operator == "%"):
			equation_result = num_a % num_b
			
		if (correct_result != equation_result):
			return false
			
	return true

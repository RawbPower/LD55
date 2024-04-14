extends Control

signal try_answer(answer)
signal hint_enabled()
signal hint_disabled()

var node = load("res://Scenes/NumberNode.tscn")
var number_texture = load("res://Scenes/NumberTexture.tscn")

var operatorOrder = ["+", "-", "*", "/", "%", "="]

var selectedCircleNode = null
var selectedNumberNode = null
var game_win = false
var in_hint_mode = false
var hints_used = 0
var button_pressed = false
var hovered_on_hint = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_select") and not button_pressed and in_hint_mode and not hovered_on_hint:
		disable_hint_mode()
	button_pressed = false

func _on_sum_manager_parsed_equation(list):
	var nodes = get_node("Nodes")
	for n in nodes.get_children():
		nodes.remove_child(n)
		n.queue_free()
		
	for item in list:
		var newNode = node.instantiate()
		nodes.add_child(newNode)
		newNode.number = item
		newNode.hide = true
		newNode.is_circle_node = true
		newNode.node_pressed.connect(_on_node_pressed)
		
	if Game.puzzle_data:
		$Date.text = get_date_string()
	else:
		$Date.text = ""
	$LevelTimer.start_timer()

func _on_sum_manager_numbers_hidden(list):
	var nodes = get_node("Nodes")
	var numbersToPlace = get_node("NumbersToPlace")
	for i in range(list.size()):
		nodes.get_child(i).set_is_unknown(list[i])
		if list[i]:
			var newNumberToPlace = node.instantiate()
			numbersToPlace.add_child(newNumberToPlace)
			newNumberToPlace.number = nodes.get_child(i).number
			newNumberToPlace.hide = false
			newNumberToPlace.is_circle_node = false
			newNumberToPlace.node_pressed.connect(_on_node_pressed)
	sort_numbers()
	
func sort_numbers():
	var sorted_numbers := get_node("NumbersToPlace").get_children()
	sorted_numbers.sort_custom(sort_numbers_func)
	
	for node in get_node("NumbersToPlace").get_children():
		get_node("NumbersToPlace").remove_child(node)

	for node in sorted_numbers:
		get_node("NumbersToPlace").add_child(node)
	
func sort_numbers_func(a, b):
	var a_int: int = int(a.number)
	var b_int: int = int(b.number)
	
	if (not Numbers.is_operator(a.number) and not Numbers.is_operator(b.number)):
		return a_int < b_int
	elif (not Numbers.is_operator(a.number)):
		return true
	elif (not Numbers.is_operator(b.number)):
		return false
	else:
		return operatorOrder.find(a.number,0) < operatorOrder.find(b.number,0)
		
func _on_node_pressed(button):
	button_pressed = true
	if in_hint_mode:
		if not button.is_known():
			button.reveal_number()
			var number_node = get_best_number_node(button.number)
			var old_guesser_node = get_node_with_guess(number_node)
			if old_guesser_node:
				old_guesser_node.guess_number.used = false
				old_guesser_node.guess_number = null
				old_guesser_node.selected = false
				old_guesser_node.hide = true
			number_node.selected = false
			number_node.used = true
			selectedNumberNode = null
			if selectedCircleNode:
				selectedCircleNode.selected = false
			button.selected = true
			selectedCircleNode = button
			hints_used += 1
			check_answer()
			show_equations()
			disable_hint_mode()
		return
	
	if button.is_circle_node:
		if selectedCircleNode and selectedCircleNode == button and selectedCircleNode.guess_number:
			selectedCircleNode.guess_number.used = false
			selectedCircleNode.guess_number = null
			selectedCircleNode.selected = false
			selectedCircleNode.hide = true
		else:
			if selectedCircleNode:
				selectedCircleNode.selected = false
			button.selected = true
			selectedCircleNode = button
	elif selectedCircleNode and not selectedCircleNode.is_known():
		if selectedNumberNode:
			selectedNumberNode.selected = false
		button.selected = true
		selectedNumberNode = button
		if selectedCircleNode and selectedCircleNode.is_known():
			selectedCircleNode.selected = false
		
	if selectedCircleNode and selectedNumberNode and not selectedCircleNode.is_known():
		GlobalAudio.play_tap_sound()
		set_circle_node_to_number()
	else:
		if button.is_circle_node:
			GlobalAudio.play_click_sound()
		show_equations()
		
func set_circle_node_to_number():
	var is_used = selectedNumberNode.used
	if is_used:
		var node_using_number = get_node_using_number(selectedNumberNode)
		if not node_using_number:
			return
		node_using_number.guess_number.used = false
		node_using_number.guess_number = null
		node_using_number.selected = false
		node_using_number.hide = true
	selectedCircleNode.set_guess_number(selectedNumberNode)
	selectedCircleNode.hide = false
	selectedNumberNode.selected = false
	selectedNumberNode.used = true
	selectedNumberNode = null
	check_answer()
	select_next_unknown_node()
	show_equations()
	
func get_node_using_number(number_node):
	var result = null
	var nodes = get_node("Nodes")
	for n in nodes.get_children():
		if (n.guess_number and n.guess_number == number_node):
			result = n
			
	return result
			
	
func select_next_unknown_node():
	if game_win:
		return
		
	var child_nodes = get_node("Nodes").get_children()
	var child_index = 0
	var found_next_node = false
	var found_this_node = false
	while not found_next_node:
		var child = child_nodes[child_index]
		
		if (child == selectedCircleNode):
			found_this_node = true
			child_index += 1
			child_index = child_index % child_nodes.size()
			continue
			
		if (found_this_node and not child.is_known()):
			found_next_node = true
			selectedCircleNode.selected = false
			child.selected = true
			selectedCircleNode = child
			
		child_index += 1
		child_index = child_index % child_nodes.size()
	
func show_equations():
	if (selectedCircleNode and not game_win):
		var selectedNodeIndex = 0
		for child in get_node("Nodes").get_children():
			if child == selectedCircleNode:
				break
			selectedNodeIndex += 1
			
		var num_eqautions = get_equations_from_node_index(selectedNodeIndex)
		display_equations(num_eqautions)
	else:
		hide_equations()
		
func get_equations_from_node_index(index : int):
	for i in get_node("Nodes").get_children():
		i.set_in_equation(false)
	
	var num_equations = 1
	if index % 4 == 0:
		num_equations = 2
		var previous_index = (index-1)
		if previous_index < 0:
			previous_index += get_node("Nodes").get_children().size()
		var equation_start_index = (previous_index/4) * 4
		var current_equation = ""
		for i in range(5):
			var current_index = (equation_start_index + i) % get_node("Nodes").get_children().size()
			$Equations/Equation1.get_child(i).number = get_node("Nodes").get_child(current_index).get_shown_number()
			get_node("Nodes").get_child(current_index).set_in_equation(true, 1)
			if (get_node("Nodes").get_child(current_index).guess_number):
				$Equations/Equation1.get_child(i).set_guess_color(true)
			else:
				$Equations/Equation1.get_child(i).set_guess_color(false)
		
	var equation_start_index = (index/4) * 4
	var current_equation = ""
	for i in range(5):
		var current_index = (equation_start_index + i) % get_node("Nodes").get_children().size()
		$Equations/Equation2.get_child(i).number = get_node("Nodes").get_child(current_index).get_shown_number()
		get_node("Nodes").get_child(current_index).set_in_equation(true, 0)
		if (get_node("Nodes").get_child(current_index).guess_number):
			$Equations/Equation2.get_child(i).set_guess_color(true)
			#$Equations/Equation1.get_child(i).number = "*"
		else:
			$Equations/Equation2.get_child(i).set_guess_color(false)
			
	var index_color = 0
	if num_equations == 2:
		index_color = 2
	get_node("Nodes").get_child(index).set_in_equation(true, index_color)
	return num_equations
	
func display_equations(count):
	$Equations/Equation2.visible = true
	if count > 1:
		$Equations/Equation1.visible = true
	else:
		$Equations/Equation1.visible = false
			
func hide_equations():
	$Equations/Equation1.visible = false
	$Equations/Equation2.visible = false
	
func check_answer():
	var numbers_in_order = []
	for node in get_node("Nodes").get_children():
		numbers_in_order.append(node.get_shown_number())
	emit_signal("try_answer", numbers_in_order)


func _on_sum_manager_win_game():
	game_win = true
	GlobalAudio.play_success_sound()
	$LevelTimer.stop_timer()
	$Help.disabled = true
	$Reset.disabled = true
	$Hint.disabled = true
	var nodes = get_node("Nodes")
	for n in nodes.get_children():
		n.selected = false
		n.set_in_equation(false)
		n.disabled = true
	hide_equations()
	$Win.text = "Correct!\n Time: " + $LevelTimer.get_time_str() + "\nHints Used: " + str(hints_used)
	if not Game.puzzle_data:
		$Win.set_random_win_line()
		$NumbersToPlace.visible = false
	$Win.visible = true
	
func get_date_string():
	var date_dict = Time.get_date_dict_from_system()
	var date_string = get_weekday(date_dict)
	date_string += " " + str(date_dict["day"])
	date_string += " " + get_month(date_dict)
	date_string += " " + str(date_dict["year"])
	return date_string
	
func get_weekday(date_dict):
	match date_dict["weekday"]:
		Time.Weekday.WEEKDAY_SUNDAY:
			return "Sun"
		Time.Weekday.WEEKDAY_MONDAY:
			return "Mon"
		Time.Weekday.WEEKDAY_TUESDAY:
			return "Tue"
		Time.Weekday.WEEKDAY_WEDNESDAY:
			return "Wed"
		Time.Weekday.WEEKDAY_THURSDAY:
			return "Thu"
		Time.Weekday.WEEKDAY_FRIDAY:
			return "Fri"
		Time.Weekday.WEEKDAY_SATURDAY:
			return "Sat"
			
func get_month(date_dict):
	match date_dict["month"]:
		Time.Month.MONTH_JANUARY:
			return "Jan"
		Time.Month.MONTH_FEBRUARY:
			return "Feb"
		Time.Month.MONTH_MARCH:
			return "Mar"
		Time.Month.MONTH_APRIL:
			return "Apr"
		Time.Month.MONTH_MAY:
			return "May"
		Time.Month.MONTH_JUNE:
			return "Jun"
		Time.Month.MONTH_JULY:
			return "Jul"
		Time.Month.MONTH_AUGUST:
			return "Aug"
		Time.Month.MONTH_SEPTEMBER:
			return "Sep"
		Time.Month.MONTH_OCTOBER:
			return "Oct"
		Time.Month.MONTH_NOVEMBER:
			return "Nov"
		Time.Month.MONTH_DECEMBER:
			return "Dec"


func _on_sum_manager_set_title(title):
	$Daily.text = title
	
func reset_guesses():
	var nodes = get_node("Nodes")
	for n in nodes.get_children():
		if (n.guess_number):
			n.guess_number.used = false
			n.guess_number = null
			n.selected = false
			n.hide = true
			
func toggle_how_to():
	if $HowToMenu.visible:
		$HowToMenu.visible = false
		$LevelTimer.resume_timer()
	else:
		$HowToMenu.visible = true
		$LevelTimer.stop_timer()

func _on_exit_pressed():
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")


func _on_reset_pressed():
	reset_guesses()
	show_equations()
	GlobalAudio.play_tap_sound()


func _on_help_pressed():
	toggle_how_to()
	GlobalAudio.play_tap_sound()


func _on_menu_pressed():
	GlobalAudio.play_tap_sound()
	if Game.puzzle_data:
		get_tree().change_scene_to_file("res://Scenes/DailyPuzzleMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/PuzzlebookMenu.tscn")


func _on_hint_pressed():
	button_pressed = true
	if in_hint_mode:
		disable_hint_mode()
	else:
		enable_hint_mode()
		
func enable_hint_mode():
	$HintOverlay.visible = true
	emit_signal("hint_enabled")
	in_hint_mode = true
	
func disable_hint_mode():
	$HintOverlay.visible = false
	emit_signal("hint_disabled")
	in_hint_mode = false
	
func get_best_number_node(number):
	var best_number_node = null
	for node in get_node("NumbersToPlace").get_children():
		if node.number == number:
			if best_number_node == null:
				best_number_node = node
				if not best_number_node.used:
					break
			else:
				if best_number_node and not node.used:
					best_number_node = node
					break
	return best_number_node
	
func get_node_with_guess(guess):
	for node in get_node("Nodes").get_children():
		if node.guess_number == guess:
			return node
	return null


func _on_hint_mouse_entered():
	hovered_on_hint = true


func _on_hint_mouse_exited():
	hovered_on_hint = false

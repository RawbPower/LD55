extends CanvasLayer

func _on_beginner_1_button_pressed():
	Game.equation = 0
	start_game()


func _on_beginner_2_button_pressed():
	Game.equation = 1
	start_game()


func _on_beginner_3_button_pressed():
	Game.equation = 2
	start_game()


func _on_novice_1_button_pressed():
	Game.equation = 3
	start_game()


func _on_novice_2_button_pressed():
	Game.equation = 4
	start_game()


func _on_novice_3_button_pressed():
	Game.equation = 5
	start_game()

func _on_expert_1_button_pressed():
	Game.equation = 6
	start_game()


func _on_expert_2_button_pressed():
	Game.equation = 7
	start_game()


func _on_expert_3_button_pressed():
	Game.equation = 8
	start_game()
	
func start_game():
	Game.puzzle_data = null
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

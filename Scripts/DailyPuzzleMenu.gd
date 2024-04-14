extends CanvasLayer

const BEGINNER = preload("res://Resources/Beginner.tres")
const NOVICE = preload("res://Resources/Novice.tres")
const EXPERT = preload("res://Resources/Expert.tres")

func _on_beginner_button_pressed():
	Game.puzzle_data = BEGINNER
	start_game()


func _on_novice_button_pressed():
	Game.puzzle_data = NOVICE
	start_game()


func _on_expert_button_pressed():
	Game.puzzle_data = EXPERT
	start_game()
	
func start_game():
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

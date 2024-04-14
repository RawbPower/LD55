extends CanvasLayer

@export var daily_menu: PackedScene
@export var puzzlebook_menu: PackedScene

func _ready():
	pass
	#start_game_button.grab_focus()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_how_to_play_button_pressed():
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_file("res://Scenes/HowToScreen.tscn")


func _on_daily_puzzle_button_pressed():
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_packed(daily_menu)


func _on_puzzlebook_button_pressed():
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_packed(puzzlebook_menu)

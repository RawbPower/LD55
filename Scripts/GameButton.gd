extends TextureButton

@export var known_number_color : Color
@export var guess_number_color : Color


func _on_mouse_entered():
	modulate = guess_number_color


func _on_mouse_exited():
	modulate = known_number_color


func _on_exit_pressed():
	GlobalAudio.play_tap_sound()
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")

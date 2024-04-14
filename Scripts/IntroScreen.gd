extends Control

var lines_spoken = 1

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
		return
		
	if Input.is_action_just_pressed("ui_select"):
		GlobalAudio.play_click_sound()
		if lines_spoken == $VBoxContainer.get_children().size():
			get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
		else:
			lines_spoken += 1
		
	for i in range($VBoxContainer.get_children().size()):
		if i < lines_spoken:
			$VBoxContainer.get_child(i).visible_ratio = 1

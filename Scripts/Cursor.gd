@tool
class_name Cursor
extends Control

@export var hide_cursor := true
		
func _ready() -> void:
	position = get_global_mouse_position()
	if not Engine.is_editor_hint():
		if (hide_cursor):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_global_mouse_position()
		
func enable_hint_cursor():
	$Image.visible = false
	$HintImage.visible = true
	
func disable_hint_cursor():
	$Image.visible = true
	$HintImage.visible = false

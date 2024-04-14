extends TextureButton

signal node_pressed(button)

@export var unselected_texture : Texture2D
@export var selected_texture : Texture2D
@export var number : String
@export var hide : bool : set = _set_hide
@export var known_number_color : Color
@export var guess_number_color : Color
@export var hint_number_color : Color

var guess_number
var is_circle_node = false
var selected = false : set = _set_selected
var used = false : set = _set_used
var unknown = false
var is_in_equation = false

@onready var numberTexture1 : TextureRect = $HBoxContainer/Number1
@onready var numberTexture2 : TextureRect = $HBoxContainer/Number2

func _ready():
	guess_number = null
	used = false
	selected = false
	numberTexture1.modulate = known_number_color
	numberTexture2.modulate = known_number_color
	set_is_unknown(unknown)

func _process(_delta):
	if not hide:
		var showNumber = number
		if guess_number:
			showNumber = guess_number.number
		set_texture_from_string(numberTexture1, showNumber[0])
		if (showNumber.length() > 1):
			set_texture_from_string(numberTexture2, showNumber[1])
		else:
			numberTexture2.texture = null
			numberTexture2.visible = false
		
func set_texture_from_string(numberTexture :TextureRect, numberString: String):
	var texturePath = Numbers.NumberToImage(numberString)
	if (texturePath):
		numberTexture.texture = load(texturePath)
		numberTexture.visible = true
	else:
		numberTexture.texture = null
		numberTexture.visible = false
		
func hide_numbers():
	if (numberTexture1):
		numberTexture1.texture = null
		numberTexture1.visible = false
	if (numberTexture2):
		numberTexture2.texture = null
		numberTexture2.visible = false
	
func _set_selected(new_state):
	selected = new_state
	if selected:
		texture_normal = selected_texture
	else:
		texture_normal = unselected_texture
		
func _set_hide(new_state):
	hide = new_state
	if hide:
		hide_numbers()
		
func _set_used(new_state):
	used = new_state
	$Slash.visible = used
	
func set_in_equation(new_state, eq_number = 0):
	if eq_number == 0:
		$InEquation.modulate = Color.html("#3363bc")
	elif eq_number == 1:
		$InEquation.modulate = Color.html("#d95763")
	else:
		$InEquation.modulate = Color.html("#76428a")
	is_in_equation = new_state
	$InEquation.visible = is_in_equation

func _on_pressed():
	emit_signal("node_pressed", self)
	
func set_guess_number(guess):
	if guess_number:
		guess_number.used = false
	guess_number = guess
	
func set_is_unknown(value):
	unknown = value
	if value:
		if (numberTexture1 and numberTexture2):
			numberTexture1.modulate = guess_number_color
			numberTexture2.modulate = guess_number_color
			hide_numbers()
	else:
		hide = false
		
func get_shown_number():
	if hide:
		return "_"
	elif guess_number:
		return guess_number.number
	else:
		return number
		
func is_known():
	return not hide and not guess_number
	
func reveal_number():
	hide = false
	if guess_number:
		guess_number.used = false
		guess_number = null
	selected = false
	unknown = false
	numberTexture1.modulate = hint_number_color
	numberTexture2.modulate = hint_number_color

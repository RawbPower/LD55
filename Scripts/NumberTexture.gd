extends Control

@export var number : String

@onready var numberTexture1 : TextureRect = $HBoxContainer/Number1
@onready var numberTexture2 : TextureRect = $HBoxContainer/Number2
@export var known_number_color : Color
@export var guess_number_color : Color

func _process(_delta):
	if number.length() > 0:
		set_texture_from_string(numberTexture1, number[0])
		if (number.length() > 1):
			set_texture_from_string(numberTexture2, number[1])
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
		
func set_guess_color(value):
	if value:
		modulate = guess_number_color
	else:
		modulate = known_number_color

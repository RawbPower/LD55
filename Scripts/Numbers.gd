extends Node

var numberToImage = {"0": "res://Sprites/Digits0.png", "1": "res://Sprites/Digits1.png","2": "res://Sprites/Digits2.png","3": "res://Sprites/Digits3.png","4": "res://Sprites/Digits4.png", "5": "res://Sprites/Digits5.png","6": "res://Sprites/Digits6.png","7": "res://Sprites/Digits7.png","8": "res://Sprites/Digits8.png","9": "res://Sprites/Digits9.png","+": "res://Sprites/Digits10.png","-": "res://Sprites/Digits11.png", "*": "res://Sprites/Digits12.png", "/": "res://Sprites/Digits13.png","%": "res://Sprites/Digits18.png","=": "res://Sprites/Digits14.png","_": "res://Sprites/Digits15.png"}
					
func NumberToImage(numberString : String):
	if (numberToImage.has(numberString)):
		return numberToImage[numberString]
	else:
		return null
		
func is_operator(character):
	return character == "+" or character == "-" or character == "*" or character == "/" or character == "%" or character == "="

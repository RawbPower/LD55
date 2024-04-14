extends AudioStreamPlayer

const CLICK = preload("res://Sounds/Click.wav")
const TAP = preload("res://Sounds/Tap.wav")
const SUCCESS = preload("res://Sounds/Success.wav")
const INCORRECT = preload("res://Sounds/Incorrect.wav")

func play_tap_sound():
	stop()
	stream = TAP
	play()
	
func play_click_sound():
	stop()
	stream = CLICK
	play()
	
func play_success_sound():
	stop()
	stream = SUCCESS
	play()
	
func play_incorrect_sound():
	stop()
	stream = INCORRECT
	play()

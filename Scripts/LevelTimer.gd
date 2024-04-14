class_name LevelTimer
extends Label

var level_time = 0.0
var stop_time = false

# Called when the node enters the scene tree for the first time.
func start_timer():
	level_time = 0.0
	stop_time = false
	
func stop_timer():
	stop_time = true
	
func resume_timer():
	stop_time = false
	
func get_time():
	return level_time
	
func get_time_str():
	return "%0.1f s" % (level_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not stop_time):
		level_time += delta
		text = "%0.1f" % (level_time)

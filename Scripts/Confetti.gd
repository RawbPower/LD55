extends CPUParticles2D

func emit():
	restart()
	connect("finished", queue_free)


func _on_sum_manager_win_game():
	emit()

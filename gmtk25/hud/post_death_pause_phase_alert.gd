class_name PostDeathPauseAlert
extends Control

func _ready() -> void:
	visible = false
	Main.level.loop_manager.loop_began.connect(_on_loop_began)
	
func _on_loop_began() -> void:
	Main.level.get_map().camera_manager.post_death_pause_phase_set.connect(_on_post_death_pause_phase_set)
	
func _on_post_death_pause_phase_set(b : bool) -> void:
	if b:
		visible = true
		if Main.level.get_map().players.size() >= 2:
			$ChangePlayerAlert.visible = true
		else:
			$ChangePlayerAlert.visible = false
	else:
		visible = false


func _on_timer_timeout() -> void:
	#Main.level.get_map().camera_manager.post_death_pause_phase_set.connect(_on_post_death_pause_phase_set)
	pass

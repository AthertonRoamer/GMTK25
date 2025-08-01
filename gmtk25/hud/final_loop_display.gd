extends Label

func _ready() -> void:
	visible = false
	Main.level.loop_manager.final_loop_ended.connect(_on_final_loop_ended)
	
	
func _on_final_loop_ended() -> void:
	visible = true

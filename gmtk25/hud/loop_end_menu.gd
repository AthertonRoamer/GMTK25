extends Control

func _ready() -> void:
	visible = false
	Main.level.loop_manager.loop_ended.connect(_on_loop_ended)
	
	
func _on_loop_ended() -> void:
	visible = true
	
	
func _on_button_pressed() -> void:
	visible = false
	Main.level.loop_manager.run_next_loop()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("resume_game") and visible:
		visible = false
		Main.level.loop_manager.run_next_loop()


func _on_pause_menu_pause_menu_open_changed(pause_menu_open: bool) -> void:
	visible = not pause_menu_open and not Main.level.loop_manager.loop_progressing

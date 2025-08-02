extends VBoxContainer

func _ready() -> void:
	visible = false
	Main.level.level_beaten.connect(_on_level_beaten)
	
	
func _on_level_beaten() -> void:
	visible = true


func _on_button_pressed() -> void:
	Main.game.level_manager.transfer_to_next_level()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("resume_game") and visible:
		Main.game.level_manager.transfer_to_next_level()

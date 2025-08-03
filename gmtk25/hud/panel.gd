extends Panel


func _on_pause_menu_visibility_changed() -> void:
	visible = $"../PauseMenu".visible
	
	
func _ready() -> void:
	visible = $"../PauseMenu".visible

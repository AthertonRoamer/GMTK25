class_name LoopCountDisplay
extends Label

var loop_manager : LoopManager
func _ready() -> void:
	loop_manager = Main.level.loop_manager
	loop_manager.loop_began.connect(_on_loop_began)
	loop_manager.saved_player_handler.started_new_saved_player_run.connect(_on_new_saved_player_run)
	visible = false
	
	
func _on_loop_began() -> void:
	visible = true
	text = " Loop " + str(loop_manager.current_loop) + " "
	
	
func _on_new_saved_player_run(data : SavedPlayerRunData) -> void:
	visible = true
	text = " Loop " + str(data.saved_player_input_record.loop_index) + " "

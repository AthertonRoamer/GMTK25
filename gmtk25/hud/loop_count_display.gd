class_name LoopCountDisplay
extends Label

var loop_manager : LoopManager
func _ready() -> void:
	loop_manager = Main.level.loop_manager
	loop_manager.loop_began.connect(_on_loop_began)
	loop_manager.saved_player_handler.started_new_saved_player_run.connect(_on_new_saved_player_run)
	loop_manager.loop_replay_began.connect(_on_loop_replay_began)
	loop_manager.saved_player_handler.resolved_to_finish_loop.connect(_on_resolved_to_finish_loop)
	visible = false
	
	
func _on_loop_began() -> void:
	visible = true
	text = " Loop " + str(loop_manager.current_loop) + "/" + str(Main.level.loops_allowed) + " "
	

func _on_loop_replay_began(_data) -> void:
	visible = true
	text = " Replaying Loop " + str(loop_manager.current_loop) + "/" + str(Main.level.loops_allowed) + " "
	
	
func _on_resolved_to_finish_loop(_data : SavedPlayerRunData) -> void:
	text = " Loop " + str(loop_manager.current_loop) + "/" + str(Main.level.loops_allowed) + " "
	
	
func _on_new_saved_player_run(data : SavedPlayerRunData) -> void:
	visible = true
	text = " Loop " + str(data.saved_player_input_record.loop_index) + " "

extends VBoxContainer

enum SAVED_RUN_DISPLAY_STATE {NONE, BEFORE_SAVED_RUN, BEFORE_REPLAY, BEFORE_FINISH_LOOP}

var state : SAVED_RUN_DISPLAY_STATE = SAVED_RUN_DISPLAY_STATE.NONE

var waiting_for_true_pause_to_end : bool = false

func _ready() -> void:
	visible = false
	Main.level.loop_manager.saved_player_handler.resolved_to_begin_saved_run.connect(_on_resolved_to_begin_saved_run)
	Main.level.loop_manager.saved_player_handler.resolved_to_replay.connect(_on_resolved_to_replay)
	Main.level.loop_manager.saved_player_handler.resolved_to_finish_loop.connect(_on_resolved_to_finish_loop)
	Pause.true_pause.connect(_on_pause_announced)
	Main.game.level_manager.opened_level.connect(_on_level_opened)
	Main.game.level_manager.closed_level.connect(_on_level_opened)
	
	
func _on_resolved_to_begin_saved_run(data : SavedPlayerRunData) -> void:
	state = SAVED_RUN_DISPLAY_STATE.BEFORE_SAVED_RUN
	$Label.text = "You have saved your past self's life in loop " + str(data.loop_being_completed) \
			 + "!\nGo back in time and finish your loop " +  str(data.loop_being_completed) + " run\n" 
			#+ str(round(data.saved_player_input_record.seconds_remaining_at_death * 100) / 100) + " seconds remaining\n"
	visible = true
	
	
func _on_resolved_to_replay(data : SavedPlayerRunData) -> void:
	state = SAVED_RUN_DISPLAY_STATE.BEFORE_REPLAY
	$Label.text = "Now that you've finished your loop " + str(data.loop_being_completed)\
			+ " run,\n loop " + str(data.loop_when_saved) + " will be replayed up to the point where you left off"
	visible = true
	
	
func _on_resolved_to_finish_loop(data : SavedPlayerRunData) -> void:
	state = SAVED_RUN_DISPLAY_STATE.BEFORE_FINISH_LOOP
	$Label.text = "Now you can finish loop "  + str(data.loop_when_saved) +"\nfrom where you left off in the present"
	visible = true
	
	
func _on_button_pressed() -> void:
	continue_selected()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("resume_game") and visible:
		continue_selected()
	
	
func continue_selected() -> void:
	match state:
		SAVED_RUN_DISPLAY_STATE.BEFORE_SAVED_RUN:
			Main.level.loop_manager.saved_player_handler.continue_resolved_saved_player_run()
		SAVED_RUN_DISPLAY_STATE.BEFORE_REPLAY:
			Main.level.loop_manager.saved_player_handler.begin_replay()
		SAVED_RUN_DISPLAY_STATE.BEFORE_FINISH_LOOP:
			Main.level.loop_manager.saved_player_handler.finish_loop()
	visible = false
	waiting_for_true_pause_to_end = false
	state = SAVED_RUN_DISPLAY_STATE.NONE
	
	
func _on_pause_announced(b : bool) -> void:
	if b:
		if visible:
			waiting_for_true_pause_to_end = true
			visible = false
	if not b:
		if waiting_for_true_pause_to_end:
			visible = true
			waiting_for_true_pause_to_end = false
			
			
func _on_level_opened() -> void:
	waiting_for_true_pause_to_end = false
	visible = false
	if state != SAVED_RUN_DISPLAY_STATE.NONE:
		push_warning("Saved player display gave up on wating bc loop ended")
	state = SAVED_RUN_DISPLAY_STATE.NONE
	
	

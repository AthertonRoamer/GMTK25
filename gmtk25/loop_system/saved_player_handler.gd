class_name SavedPlayerHandler
extends Node

var enabled : bool = true
var running_saved_player : bool = false
var saved_player_run_data_stack : Array[SavedPlayerRunData] = []
var resolved_saved_player_run_data : SavedPlayerRunData

signal resolved_to_begin_saved_run(data : SavedPlayerRunData)
signal started_new_saved_player_run(data : SavedPlayerRunData)
signal resolved_to_replay(data : SavedPlayerRunData)
signal resolved_to_finish_loop(data : SavedPlayerRunData)

func get_top_stack_data() -> SavedPlayerRunData:
	if saved_player_run_data_stack.is_empty():
		return null
	return saved_player_run_data_stack.back()

func submit_saved_player(player : Player, input_record : InputRecord) -> void:
	if not enabled:
		push_warning("Saved Player Handler disabled - submission ignored")
		return
	print("submission received")
	var saved_player_run_data : SavedPlayerRunData = create_saved_player_run_data(player, input_record)
	if not running_saved_player: #hopefully we can compare and stack
		alert_player_about_beginning_saved_run(saved_player_run_data)
	else:
		push_warning("Received request to run saved player but already running saved player")


func create_saved_player_run_data(p : Player, input_record : InputRecord) -> SavedPlayerRunData:
	var data : SavedPlayerRunData = SavedPlayerRunData.new()
	data.saved_player = p
	data.saved_player_input_record = input_record
	data.loop_when_saved = Main.level.loop_manager.current_loop
	if is_instance_valid(Main.level.loop_manager.current_player):
		data.once_current_player_input_record = Main.level.loop_manager.current_player.input_record
	elif Main.level.loop_manager.has_input_record_from_loop(data.loop_when_saved):
		data.once_current_player_input_record = Main.level.loop_manager.get_input_record_from_loop(data.loop_when_saved)
	else:
		push_warning("Saved player handler unable to aquire once current player input_record")
	data.once_current_player_input_record.incomplete = true
	if not is_instance_valid(Main.level.loop_manager.current_player) or Main.level.loop_manager.current_player.death_accomplished:
		push_warning("Current player already dead at saving past player")
	else:
		data.once_current_player = Main.level.loop_manager.current_player
	data.frame_when_saved = input_record.death_frame + 1
	input_record.death_frame = -1
	data.loop_being_completed = input_record.loop_index
	calm_input_record(data)
	return data
	
	
func calm_input_record(data : SavedPlayerRunData) -> void:
	#data.saved_player_input_record.print_action_list()
	var buffer_input_actions : Array[InputAction] = []
	var frame_id : int = data.frame_when_saved - 1
	buffer_input_actions.append(InputActionKeyChange.new("walk_up", frame_id))
	buffer_input_actions.append(InputActionKeyChange.new("walk_down", frame_id))
	buffer_input_actions.append(InputActionKeyChange.new("walk_right", frame_id))
	buffer_input_actions.append(InputActionKeyChange.new("walk_left", frame_id))
	data.saved_player_input_record.input_action_list.append_array(buffer_input_actions)
	#print("\n\n\n")
	#data.saved_player_input_record.print_action_list()
	data.saved_player.velocity = Vector2.ZERO
	data.saved_player.input_record = data.saved_player_input_record
	
	
	
	
func alert_player_about_beginning_saved_run(data : SavedPlayerRunData) -> void:
	resolved_saved_player_run_data = data
	get_tree().paused = true
	resolved_to_begin_saved_run.emit(data)

	
func continue_resolved_saved_player_run() -> void:
	start_saved_player_run(resolved_saved_player_run_data)
	get_tree().paused = false
	resolved_saved_player_run_data = null
	
	
func start_saved_player_run(data : SavedPlayerRunData) -> void:
	
	saved_player_run_data_stack.append(data)
	if is_instance_valid(data.once_current_player):
		data.once_current_player.prepare_to_run_as_once_current_player()
	else:
		push_warning("before saved player run once current player is already deleted")
		#abort_save()
		#return
	if is_instance_valid(data.saved_player):
		data.saved_player.prepare_to_run_as_saved_player()
	else:
		push_warning("before saved player run saved player is already deleted")
		abort_save()
		return
	#Main.level.loop_manager.current_player = data.saved_player
	Main.level.loop_manager.change_current_player_mid_loop(data.saved_player)
	data.currently_running_saved_player = true
	started_new_saved_player_run.emit(data)
	
	
func submit_input_record(input_record : InputRecord) -> void:
	print("handler received submission")
	if get_top_stack_data() == null:
		return
	if input_record.loop_index == get_top_stack_data().saved_player_input_record.loop_index:
		print("handler accepts submission")
		get_top_stack_data().new_saved_player_input_record = input_record
	
	
func end_loop_of_saved_run() -> void:
	#cleanup
	#get saved player input record and replace old input record
	var data : SavedPlayerRunData = get_top_stack_data()
	if data == null:
		push_error("No saved player data saved in handler at end of loop cleanup")
		return
	if not get_top_stack_data().new_saved_player_input_record:
		get_top_stack_data().new_saved_player_input_record = data.saved_player.input_record
	#if its from loop 1, it needs to be at postion 0
	var input_data_index : int = get_top_stack_data().new_saved_player_input_record.loop_index - 1
	Main.level.loop_manager.player_input_records.remove_at(input_data_index)
	Main.level.loop_manager.player_input_records.insert(input_data_index, saved_player_run_data_stack.back().new_saved_player_input_record)
	#restore saved player as non current past self maye unnecessary
	#restore once current as current maybe unneseccary
	#make sure loop has correct player as current maybe unesseacry yet
	#pause game and announce replay
	get_tree().paused = true
	resolved_to_replay.emit(data)
	pass
	
	
func begin_replay() -> void:
	print("beginning replay")
	#reset loop to beginning of loop on which save occured
	var data : SavedPlayerRunData = get_top_stack_data()
	if data == null:
		push_error("No saved player data saved in handler at beginning of replay")
		return
	data.currently_running_saved_player = false
	get_tree().paused = false
	data.currently_replaying_loop_when_saved = true
	Main.level.loop_manager.rerun_loop_on_which_save_occured(data)
	#replay up to last left off
	#space to continue
	#delete data related to saved player
	#finish loop as started
	#make sure loop display gets fixed
	pass
	
func resolve_to_finish_loop() -> void:
	if get_top_stack_data() == null:
		push_error("No saved player run data in resolve to finish loop")
		return
	get_tree().paused = true
	resolved_to_finish_loop.emit(get_top_stack_data())
	
	
func finish_loop() -> void:
	if get_top_stack_data() == null:
		push_error("No saved player run data in before finish loop")
		return
	var data = get_top_stack_data()
	print("finishing loop")
	data.currently_replaying_loop_when_saved = false
	Main.level.get_map().clear_dead_players()
	
	if Main.level.get_map().players.is_empty():
		push_warning("All players died before loop finished replaying")
		final_cleanup(data)
		return
		
	if not data.reincarnate_once_current_player:
		print("Loop manager failed to pass along info on reincarnate once in current player")
		for p in Main.level.get_map().players:
			if p.input_record.loop_index == Main.level.loop_manager.current_loop:
				data.reincarnate_once_in_control_player = p
				
	if not data.reincarnate_once_current_player:
		push_warning("Reincarnage once current player died before loop finished replaying")
		final_cleanup(data)
		return
		
	Main.level.loop_manager.change_current_player_mid_loop(data.reincarnate_once_current_player)
	data.reincarnate_once_current_player.set_visuals_as_current_player(true)
	data.reincarnate_once_current_player.current = true
	
	final_cleanup(data)
	
	
func final_cleanup(data : SavedPlayerRunData) -> void:
	data.currently_replaying_loop_when_saved = false
	get_tree().paused = false
	saved_player_run_data_stack.erase(data)
	
	
func abort_save() -> void:
	push_warning("Aborting save in saved player handler")
	if not saved_player_run_data_stack.is_empty():
		saved_player_run_data_stack.remove_at(saved_player_run_data_stack.size() - 1)
	
	

	
	
	

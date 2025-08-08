class_name LoopManager
extends Node2D

signal loop_began
signal loop_ended
signal final_loop_ended
signal current_player_changed_mid_loop(old : Player, new : Player)
signal loop_replay_began(saved_player_run_data : SavedPlayerRunData)

var level : CustomLevel

@export_group("Loop")
@export var loop_time : float = 5 #seconds
@export var loops_allowed : float = 3
var current_loop : int = 0
var current_loop_time : float = 0
var loop_progressing : bool = false
var frame_index : int = 0

var player_input_records : Array[InputRecord] = []

@export_group("Map")
@export var map_scene : PackedScene
var map : Map
var current_player : Player

var saved_player_handler : SavedPlayerHandler
var skip_to_end_of_loop_enabled : bool = true

func _ready() -> void:
	if get_parent() is CustomLevel:
		level = get_parent()
	else:
		push_warning("Loop manager isnt a child of a level node")
	saved_player_handler = SavedPlayerHandler.new()
	add_child(saved_player_handler)


func run_next_loop() -> void:
	current_loop += 1
	#delete old map
	if map:
		map.queue_free()
	#Load current map
	map = map_scene.instantiate()
	add_child(map)
	#spawn players
	if current_loop - 1 != player_input_records.size():
		push_warning(current_loop - 1, " loops completed, ", player_input_records.size(), " records possessed")
	for record in player_input_records:
		spawn_past_player(record)
	spawn_current_player()
	#start loop
	#start loop timer
	reset_loop_timer()
	loop_progressing = true
	map.set_players_active(true)
	map.active = true
	loop_began.emit()
	
	
func rerun_loop_on_which_save_occured(data : SavedPlayerRunData) -> void:
	current_loop = data.loop_when_saved
	#delete old map
	if map:
		map.queue_free()
	#Load current map
	map = map_scene.instantiate()
	add_child(map)
	#spawn players
	#if current_loop - 1 != player_input_records.size():
		#push_warning(current_loop - 1, " loops completed, ", player_input_records.size(), " records possessed")
	#player_input_records.append(data.once_current_player_input_record)
	submit_input_record(data.once_current_player_input_record)
	for record in player_input_records:
		spawn_past_player(record)
	for p in map.players:
		if p.input_record.loop_index == current_loop:
			p.set_visuals_as_current_player(true)
			p.reincarnate_once_current_player = true
			data.reincarnate_once_current_player = p
	#spawn_current_player()
	#start loop
	#start loop timer
	reset_loop_timer()
	loop_progressing = true
	map.set_players_active(true)
	map.active = true
	loop_began.emit()
	#if is_instance_valid(data.reincarnate_once_current_player):
		#loop_replay_began.emit(data.reincarnate_once_current_player)
	#else:
		#loop_replay_began.emit(null)
		#push_warning("Loop manager replaying past loop, no reincarnate once current player found")
	loop_replay_began.emit(data)
	
	
func reset_loop_timer() -> void:
	current_loop_time = loop_time
	frame_index = 0
	
	
func spawn_past_player(record : InputRecord) -> void:
	var p : Player = level.player_scene.instantiate()
	p.current = false
	p.input_record = record
	p.position = map.spawn_point.position
	p.level = level
	map.players.append(p)
	map.add_child(p)
	
	
func spawn_current_player() -> void:
	var p : Player = level.player_scene.instantiate()
	p.current = true
	p.position = map.spawn_point.position
	p.level = level
	map.players.append(p)
	map.add_child(p)
	current_player = p
	
	
func _physics_process(delta) -> void:
	frame_index += 1
	if saved_player_handler.get_top_stack_data() != null and saved_player_handler.get_top_stack_data().currently_replaying_loop_when_saved:
		if frame_index == saved_player_handler.get_top_stack_data().frame_when_saved:
			saved_player_handler.resolve_to_finish_loop()
	if not loop_progressing:
		return
	current_loop_time -= delta
	if current_loop_time <= 0:
		current_loop_time = 0
		end_loop()
		
		
func end_loop() -> void:
	loop_progressing = false
	map.set_players_active(false)
	map.active = false
	if saved_player_handler.get_top_stack_data() != null and saved_player_handler.get_top_stack_data().currently_running_saved_player:
		saved_player_handler.end_loop_of_saved_run()
		return
	if is_instance_valid(current_player):
		#print("loop manager snagging record")
		submit_input_record(current_player.input_record)
	loop_ended.emit()
	if current_loop == loops_allowed:
		final_loop_ended.emit()
		
		
func submit_input_record(record : InputRecord) -> void:
	if player_input_records.size() == record.loop_index - 1:
		#if player_input_records.is_empty():
			#print("record appended - record index: ", record.loop_index,  " array previously empty")
		#else:
			#print("record appended - record index: ", record.loop_index,  " most recent index: ", player_input_records[-1].loop_index)
		player_input_records.append(record)
	elif player_input_records.size() == record.loop_index and player_input_records.back() != null and player_input_records.back().incomplete:
		player_input_records.remove_at(player_input_records.size() - 1)
		record.incomplete = false
		player_input_records.append(record)
		#if player_input_records.is_empty():
			#print("unnecessary - record index: ", record.loop_index,  " array previously empty")
		#else:
			#print("unneccesary - record index: ", record.loop_index,  " most recent index: ", player_input_records[-1].loop_index)
		#push_warning("Input record submitted with index: ", record.loop_index, " Records: ", player_input_records)
		pass
		
		
func change_current_player_mid_loop(new_current_player : Player) -> void:
	var old : Player = current_player
	if not is_instance_valid(old):
		old = null
	current_player = new_current_player
	current_player_changed_mid_loop.emit(old, current_player)
	
	
func has_input_record_from_loop(loop_number : int) -> bool:
	return player_input_records.size() >= loop_number
	
	
func get_input_record_from_loop(loop_number : int) -> InputRecord:
	if has_input_record_from_loop(loop_number):
		return player_input_records[loop_number - 1]
	else:
		push_warning("Get input record from loop called when loop manager didnt have said record")
		return null
		
		
func _input(event : InputEvent) -> void:
	if skip_to_end_of_loop_enabled and event.is_action_pressed("skip_to_end_of_loop"):
		if loop_progressing:
			if saved_player_handler.get_top_stack_data() != null and saved_player_handler.get_top_stack_data().currently_running_saved_player:
				end_loop()
			else:
				end_loop()
				run_next_loop()
		
		

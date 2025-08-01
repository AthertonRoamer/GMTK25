class_name LoopManager
extends Node2D

signal loop_began
signal loop_ended
signal final_loop_ended

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

func _ready() -> void:
	if get_parent() is CustomLevel:
		level = get_parent()
	else:
		push_warning("Loop manager isnt a child of a level node")


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
	if is_instance_valid(current_player):
		print("loop manager snagging record")
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
	else:
		#if player_input_records.is_empty():
			#print("unnecessary - record index: ", record.loop_index,  " array previously empty")
		#else:
			#print("unneccesary - record index: ", record.loop_index,  " most recent index: ", player_input_records[-1].loop_index)
		#push_warning("Input record submitted with index: ", record.loop_index, " Records: ", player_input_records)
		pass

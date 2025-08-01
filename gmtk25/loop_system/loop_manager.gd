class_name LoopManager
extends Node2D

signal loop_began
signal loop_ended

var level : CustomLevel

@export_group("Loop")
@export var loop_time : float = 60 #seconds
@export var loops_allowed : float = 5
var current_loop : int = 0
var current_loop_time : float = 0
var loop_progressing : bool = false

var player_event_records : Array = []

@export_group("Map")
@export var map_scene : PackedScene
var map : Map

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
	spawn_current_player()
	#start loop
	#start loop timer
	reset_loop_timer()
	loop_progressing = true
	map.set_players_active(true)
	map.active = true
	loop_began.emit()
	
	
func reset_loop_timer() -> void:
	current_loop_time = 0
	
	
func spawn_current_player() -> void:
	var p : Player = level.player_scene.instantiate()
	p.current = true
	p.position = map.spawn_point.position
	p.current = true
	p.level = level
	map.players.append(p)
	map.add_child(p)
	
	
func _process(delta) -> void:
	if not loop_progressing:
		return
	current_loop_time += delta
	if current_loop_time >= loop_time:
		end_loop()
		
		
func end_loop() -> void:
	loop_progressing = false
	map.set_players_active(false)
	map.active = false
	loop_ended.emit()
	

class_name CustomLevel
extends Level

@export var auto_load_children : bool = true
@export_group("Loop")
@export var loop_time : float = 5 #seconds
@export var loops_allowed : float = 3


@export_group("Map")
@export var map_scene : PackedScene = preload("res://levels/maps/test/test_map_1.tscn")

@export_group("Other")
@export var player_scene : PackedScene = preload("res://player/player.tscn")
@export var loop_manager : LoopManager 
@export var hud_layer_scene : PackedScene = preload("res://hud/hud_layer.tscn")

var hud : Hud


func _ready() -> void:
	if auto_load_children:
		loop_manager = LoopManager.new()
		loop_manager.loop_time = loop_time
		loop_manager.loops_allowed = loops_allowed
		loop_manager.map_scene = map_scene
		add_child(loop_manager)
		var hud_layer = hud_layer_scene.instantiate()
		add_child(hud_layer)
		hud = hud_layer.get_child(0)
	elif not loop_manager:
		loop_manager = LoopManager.new()
		add_child(loop_manager)
		push_warning("No loop manager set in level, loading generic one")
	loop_manager.run_next_loop()
	
	
func get_map() -> Map:
	if loop_manager and loop_manager.map:
		return loop_manager.map
	else:
		return null
	

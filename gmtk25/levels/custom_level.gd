class_name CustomLevel
extends Level

@export var player_scene : PackedScene = load("res://player/player.tscn")
@export var loop_manager : LoopManager 

func _ready() -> void:
	if not loop_manager:
		loop_manager = LoopManager.new()
		push_warning("No loop manager set in level, loading generic one")
	loop_manager.run_next_loop()
	

class_name Map
extends Node2D

@export var spawn_point : Node2D
@export var camera : Camera2D
var players : Array = []
var active : bool = false
var camera_manager : CameraManager

func set_players_active(p_active : bool) -> void:
	clear_dead_players()
	for player in players:
		if is_instance_valid(player):
			player.active = p_active
			
			
func clear_dead_players() -> void:
	players = players.filter(is_player_alive)
	
	
func is_player_alive(p) -> bool:
	return is_instance_valid(p) and not p.dying 
	
	
func _ready() -> void:
	camera_manager = CameraManager.new()
	add_child(camera_manager)
	
	
func set_camera_active(a : bool) -> void:
	if camera:
		camera.enabled = a

class_name CameraManager
extends Node


var toggle_cameras_enabled : bool = false
var map : Map
var camera_index : int = 0
var current_camera_player : Player 

func _init() -> void:
	map = Main.level.get_map()
	Main.level.loop_manager.loop_began.connect(_on_loop_began)
	
	
func _on_loop_began() -> void:
	Main.level.loop_manager.current_player.died.connect(_on_current_player_died)
	
	
func _on_current_player_died() -> void:
	toggle_cameras_enabled = true
	map.clear_dead_players()
	activte_camera_by_index(0)
	Main.level.hud.alert_manager.add_alert("Camera switching to past selves\nClick to switch between them", 5)
	
	
func _on_camera_player_died() -> void:
	map.clear_dead_players()
	activte_camera_by_index(0)
	
	
func _physics_process(_delta: float) -> void:
	if toggle_cameras_enabled:
		if Input.is_action_just_pressed("toggle_camera"):
			toggle_camera()
			
			
func toggle_camera() -> void:
	activte_camera_by_index(camera_index + 1)
	
	
func activte_camera_by_index(index : int) -> void:
	map.clear_dead_players()
	if map.players.size() >= index + 1:
		if set_camera_player(map.players[index]):
			camera_index = index
	elif not map.players.is_empty():
		if set_camera_player(map.players[0]):
			camera_index = 0
	
	
func set_camera_player(player : Player) -> bool:
	if is_instance_valid(player):
		if is_instance_valid(current_camera_player):
			current_camera_player.set_camera_active(false)
			if current_camera_player.died.is_connected(_on_camera_player_died):
				current_camera_player.died.disconnect(_on_camera_player_died)
		player.set_camera_active(true)
		current_camera_player = player
		current_camera_player.died.connect(_on_camera_player_died)
		return true
	return false
		
	

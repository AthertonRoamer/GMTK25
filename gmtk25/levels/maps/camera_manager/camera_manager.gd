class_name CameraManager
extends Node

signal post_death_pause_phase_set(b : bool)

var toggle_cameras_enabled : bool = false
var map : Map
var camera_index : int = 0
var current_camera_player : Player 
var post_death_pause_phase : bool = false

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	map = Main.level.get_map()
	Main.level.loop_manager.loop_began.connect(_on_loop_began)
	
	
func _on_loop_began() -> void:
	Main.level.loop_manager.current_player.died.connect(_on_current_player_died)
	
	
func _on_current_player_died(dummy : PlayerDummy) -> void:
	#toggle_cameras_enabled = true
	#map.clear_dead_players()
	#activte_camera_by_index(0)
	#if not map.players.is_empty():
		#Main.level.hud.alert_manager.add_alert("Camera switching to past selves\nClick to switch between them", 5)
	map.camera.position = dummy.position
	map.camera.enabled = true
	dummy.dummy_release_camera.connect(_on_current_dummy_despawn)
	pass
	
	
func _on_current_dummy_despawn() -> void:
	map.clear_dead_players()
	if map.players.is_empty():
		Main.level.loop_manager.end_loop()
	else:
		open_post_death_pause_phase()
	
	
func open_post_death_pause_phase() -> void:
	post_death_pause_phase = true
	toggle_cameras_enabled = true
	map.camera.enabled = false
	activte_camera_by_index(0)
	get_tree().paused = true
	post_death_pause_phase_set.emit(true)
	
	#if not map.players.is_empty():
		#Main.level.hud.alert_manager.add_alert("Camera switching to past selves\nClick to switch between them", 5)
	
func close_post_death_pause_phase() -> void:
	get_tree().paused = false
	post_death_pause_phase_set.emit(false)
	
	
	
func _on_camera_player_died(dummy : PlayerDummy) -> void:
	map.clear_dead_players()
	if map.players.is_empty():
		dummy.dummy_release_camera.connect(_on_last_dummy_release_camera)
		map.camera.position = dummy.position
		map.camera.enabled = true
	else:
		activte_camera_by_index(0)
	pass
	
	
func _on_last_dummy_release_camera() -> void:
	Main.level.loop_manager.end_loop()
	
	
func _physics_process(_delta: float) -> void:
	if toggle_cameras_enabled:
		if Input.is_action_just_pressed("toggle_camera"):
			toggle_camera()
	if post_death_pause_phase:
		if Input.is_action_just_pressed("resume_game"):
			close_post_death_pause_phase()
		
			
			
func toggle_camera() -> void:
	activte_camera_by_index(camera_index + 1)
	
	
func activte_camera_by_index(index : int) -> void:
	map.clear_dead_players()
	if map.players.size() >= index + 1:
		if set_camera_player(map.players[index]):
			camera_index = index
		else:
			map.camera.enabled = true
	elif not map.players.is_empty():
		if set_camera_player(map.players[0]):
			camera_index = 0
	else:
		map.camera.enabled = true
	
	
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
	map.camera.enabled = true
	return false
		
	

class_name PlayerHealthDisplay
extends Control

var health : float = 100:
	set(v):
		if v > 100:
			health = 100
		if v < 0:
			v = 0
		health = v
		update_display()
		
		
func update_display() -> void:
	$ProgressBar.value = health

func _ready() -> void:
	health = 100
	Main.level.loop_manager.loop_began.connect(_on_loop_began)
	Main.level.loop_manager.current_player_changed_mid_loop.connect(_on_current_player_changed_mid_loop)
	
	
func _on_loop_began() -> void:
	health = 100
	if is_instance_valid(Main.level.loop_manager.current_player) and not Main.level.loop_manager.current_player.health_changed.is_connected(_on_current_player_health_changed):
		Main.level.loop_manager.current_player.health_changed.connect(_on_current_player_health_changed)
		
		
func _on_current_player_changed_mid_loop(old : Player, new : Player) -> void:
	if is_instance_valid(old) and old.health_changed.is_connected(_on_current_player_health_changed):
		old.health_changed.disconnect(_on_current_player_health_changed)
	new.health_changed.connect(_on_current_player_health_changed) 
	
	
func _on_current_player_health_changed(v : int) -> void:
	health = v
	
	
	

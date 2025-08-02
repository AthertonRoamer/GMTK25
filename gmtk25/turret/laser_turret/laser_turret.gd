class_name Turret
extends StaticBody2D

@export var sight_range : float = 500

@onready var turret_area = $TurretArea
#@export var explosion_scene : PackedScene


var target : Node2D
var current_direction = Vector2.RIGHT

@export var rotation_speed = 180

@export var max_health : int = 10
@export var starting_health : int = 10
@export var range_circle_color : Color = Color(Color.DARK_RED, 0.3)

var health : float:

	set(v):
		if v <= 0:
			health = 0
			die()
		elif v > max_health:
			health = max_health
		else:
			health = v

func _ready() -> void:
	health = starting_health
	add_to_group("damageable")
	if is_instance_valid(turret_area):
		turret_area.sight_range = sight_range


func rotate_toward_direction(target_direction : Vector2, delta : float, rotation_speed_deg : float = rotation_speed) -> void:
	var rsign : int = sign(current_direction.angle_to(target_direction))
	var rspeed : float = deg_to_rad(rotation_speed_deg)
	if abs(current_direction.angle_to(target_direction)) < rspeed * delta:
		current_direction = target_direction #if you have more than enough rotation speed to get to the desired direction, you just rotate straight to it and not past it
	else:
		current_direction = current_direction.rotated(rspeed * delta * rsign)

func _physics_process(delta: float) -> void:
	assess_targets()
	if is_instance_valid(target):
		rotate_to_target(target,delta)


func shoot():
	$gun.fire()
	pass

func rotate_to_target(ntarget, delta):
	var dir = global_position.direction_to(ntarget.global_position)
	rotate_toward_direction(dir,delta)
	global_rotation = current_direction.angle()
	shoot()

func assess_targets() -> void:
	if not turret_area.get_visible_enemies().is_empty():
		target = get_closest_enemy(turret_area.get_visible_enemies())
	else:
		target = null
		
		
func get_closest_enemy(enemies : Array) -> Node2D:
	if enemies.is_empty():
		return null
	var closest_enemy : Node2D = enemies[0]
	for e in enemies:
		if position.distance_to(e.position) < position.distance_to(closest_enemy.position):
			closest_enemy = e
	return closest_enemy
	


func take_damage(damage : float, _damage_type : String = "none") -> void:
	health -= damage

func die() -> void:
	#var explosion = explosion_scene.instantiate()
	#explosion.global_position = global_position
	#if is_instance_valid(Main.world):
		#Main.world.add_child(explosion)
	queue_free()
	
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, sight_range, range_circle_color, false, 2)

class_name Player
extends CharacterBody2D

var level : CustomLevel

var active : bool = true #moving or listening for input
var current : bool = true #if not current its a past-self


#region physics variables
@export_group("Walk")
@export var walk_max_speed : float = 250
@export var walk_accel : float = 500
var current_accel : float = walk_accel
var walk_direction : Vector2 = Vector2.ZERO

@export var walk_accel_time : float = .025
@export var set_walk_accel_from_time : bool = true


@export_group("Friction")
@export var current_slow_down_time : float = .1
@export var set_current_friction_from_slow_down_time : bool = true


var current_friction : float = 2500

#endregion 

var starting_health : float = 10
var health = starting_health:
	set(v):
		if v <= 0:
			health = 0
			die()
		else:
			health = v
			
var should_walk_up : bool = false:
	set(v):
		if v != should_walk_up:
			print("should_walk_up now ", v)
		should_walk_up = v
var should_walk_down : bool = false
var should_walk_right : bool = false
var should_walk_left : bool = false

func _ready() -> void:
	add_to_group("damagable")
	if set_current_friction_from_slow_down_time:
		#250 px/sec 250 px/sec / 1 sec = 250 px / sec /sec
		current_friction = walk_max_speed / current_slow_down_time
		#print("current friction: ", current_friction)
	if set_walk_accel_from_time:
		walk_accel = walk_max_speed / walk_accel_time
		#print("walk accel ", walk_accel)
	#set jump time from jump height and jump speed
	#px / (px/sec) = sec
	
	
func _input(event : InputEvent) -> void:
	if not active:
		return
	if not current:
		return
	if event.is_action("significant_input"):
		#save event to input record
		process_input(event)
	
	
func process_input(event : InputEvent) -> void:
	if event.is_action("walk_up"):
		should_walk_up = event.is_pressed()
	if event.is_action("walk_down"):
		should_walk_down = event.is_pressed()
	if event.is_action("walk_right"):
		should_walk_right = event.is_pressed()
	if event.is_action("walk_left"):
		should_walk_left = event.is_pressed()
		

func _physics_process(delta: float) -> void:
	rotation = (get_global_mouse_position() - global_position).angle() +(PI/2)


	
	walk_direction = Vector2.ZERO

	if should_walk_down:
		walk_direction += Vector2.DOWN
	if should_walk_up:
		walk_direction += Vector2.UP
	if should_walk_right:
		walk_direction += Vector2.RIGHT
	if should_walk_left:
		walk_direction += Vector2.LEFT
		
	walk_direction = walk_direction.normalized()
	
	var v = velocity.length()
	if v > 0:
		v -= current_friction * delta
		v = max(v, 0)
		velocity = velocity.normalized() * v 
		
	#walk
	var this_walk_accel : Vector2 = walk_direction * walk_accel * delta
	if (velocity + this_walk_accel).length() <= walk_max_speed: #if accelerating doesnt exceed max speed, accelerate
		velocity += this_walk_accel
	elif velocity.length() < walk_max_speed: #if accelerating does exceed max speed but player hasnt reached max speed
		velocity = walk_max_speed * walk_direction #reach max speed
		
	if active:
		move_and_slide()
	

func take_damage(dmg : float) -> void:
	health -= dmg


func die() -> void:
	queue_free()

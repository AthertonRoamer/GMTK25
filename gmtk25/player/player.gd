class_name Player
extends CharacterBody2D

signal died(dummy : PlayerDummy)

var level : CustomLevel

var active : bool = true #moving or listening for input
var current : bool = true #if not current its a past-self
var awaiting_saved_run_completion : bool = false
var running_as_saved_player : bool = false

@export var immortal : bool = false
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

var dummy_body_scene : PackedScene = preload("res://dummies/player_dummy.tscn")

var dying : bool = false
var death_accomplished : bool = false
var should_die : = false



var current_friction : float = 2500

#endregion 

signal health_changed(h : int)

var starting_health : float = 100
var health = starting_health:
	set(v):
		if v <= 0:
			health = 0
			queue_die()
		else:
			health = v
		health_changed.emit(v)
	
			
var should_walk_up : bool = false:
	set(v):
		should_walk_up = v
var should_walk_down : bool = false
var should_walk_right : bool = false
var should_walk_left : bool = false

var input_queue : Array[InputEvent] = []
var input_record : InputRecord
var input_record_read_index : int = 0

func _ready() -> void:
	add_to_group("damageable")
	if set_current_friction_from_slow_down_time:
		#250 px/sec 250 px/sec / 1 sec = 250 px / sec /sec
		current_friction = walk_max_speed / current_slow_down_time
		#print("current friction: ", current_friction)
	if set_walk_accel_from_time:
		walk_accel = walk_max_speed / walk_accel_time
		#print("walk accel ", walk_accel)
	#set jump time from jump height and jump speed
	#px / (px/sec) = sec
	if current:
		input_record = InputRecord.new()
		input_record.loop_index = Main.level.loop_manager.current_loop
		set_visuals_as_current_player(true)
	else:
		set_visuals_as_current_player(false)
		
		
func set_visuals_as_current_player(b : bool) -> void:
	if b:
		$StandardCamera.enabled = true
		modulate  = Color.WHITE
	else:
		$StandardCamera.enabled = false
		modulate = Color(Color.WHITE, 0.5)
	
	
func _input(event : InputEvent) -> void:
	if not active:
		return
	if not current:
		return
	if event.is_action("significant_input"):
		#process_input(event)
		input_queue.append(event)
		
		
func process_input_action(action : InputAction) -> void: #preforms input based on input actions
	if action.action_name == "walk_up":
		should_walk_up = action.pressed
	elif action.action_name == "walk_down":
		should_walk_down = action.pressed
	elif action.action_name == "walk_right":
		should_walk_right = action.pressed
	elif action.action_name == "walk_left":
		should_walk_left = action.pressed
	elif action.action_name == "rotation_change":
		rotation = action.rotation
	elif action.action_name == "player_primary":
		take_primary_action(action.global_mouse_position)
		
		
func make_input_action_or_null(event : InputEvent, frame_index : int = 0) -> InputAction: #saves input events as input actions
	if event.is_action("walk_up") and should_walk_up != event.is_pressed():
		return InputActionKeyChange.new("walk_up", frame_index, event.is_pressed())
	if event.is_action("walk_down") and should_walk_down != event.is_pressed():
		return InputActionKeyChange.new("walk_down", frame_index, event.is_pressed())
	if event.is_action("walk_right") and should_walk_right != event.is_pressed():
		return InputActionKeyChange.new("walk_right", frame_index, event.is_pressed())
	if event.is_action("walk_left") and should_walk_left != event.is_pressed():
		return InputActionKeyChange.new("walk_left", frame_index, event.is_pressed())
	if event.is_action_pressed("player_primary") and not event.is_echo():
		return InputActionMouseClick.new("player_primary", frame_index, get_global_mouse_position())
	return null


func _physics_process(delta: float) -> void:
	if should_die:
		die()
	if not active:
		return
	
	if awaiting_saved_run_completion:
		return
	
	#handle input
	var current_input_actions : Array[InputAction] = [] #the array to be populated with input data
	var frame_index : int = Main.level.loop_manager.frame_index
	
	if current: #receive natural input
		#take input and make into input actions
		for event in input_queue:
			var input_action : InputAction = make_input_action_or_null(event, frame_index)
			if input_action:
				current_input_actions.append(input_action)
		input_queue.clear()
		

		var new_rotation : float= (get_global_mouse_position() - global_position).angle() +(PI/2)
		if not is_equal_approx(new_rotation, rotation):
			current_input_actions.append(InputActionRotationChange.new("rotation_change", frame_index, new_rotation))
		#save input
		input_record.input_action_list.append_array(current_input_actions)
	
	else: #not current
		#load input
		while (input_record.input_action_list.size() > input_record_read_index and input_record.input_action_list[input_record_read_index].frame == frame_index):
			current_input_actions.append(input_record.input_action_list[input_record_read_index])
			input_record_read_index += 1
		if frame_index == input_record.death_frame + 1:
			print("Past self has been saved")
			Main.level.loop_manager.saved_player_handler.submit_saved_player(self, input_record)
		
		
	#process input
	for action in current_input_actions:
		process_input_action(action)

	
		
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
	elif velocity.length() > walk_max_speed:
		velocity = walk_max_speed * walk_direction
		
	move_and_slide()
	
	# Play walking sound if moving
	var is_moving = velocity.length() > 5.0 and not dying
	if is_moving:
		if not %walk_noise.playing:
			%walk_noise.play()
	else:
		if %walk_noise.playing:
			%walk_noise.stop()

	
func prepare_to_run_as_saved_player() -> void:
	running_as_saved_player = true
	current = true
	set_visuals_as_current_player(true)
	velocity = Vector2.ZERO
	input_queue.clear()
	should_walk_down = false
	should_walk_left = false
	should_walk_right = false
	should_walk_up = false
	
	
func prepare_to_run_as_once_current_player() -> void: #while saved player runs
	awaiting_saved_run_completion = true
	set_visuals_as_current_player(false)
	
	
func take_primary_action(_global_mouse_position : Vector2) -> void:
	$StandardGun.projectile_direction = Vector2.UP.rotated(rotation)
	$StandardGun.fire()
	
	
func set_camera_active(cam_active : bool) -> void:
	$StandardCamera.enabled = cam_active



func take_damage(dmg : float, _damage_type: String = "default") -> void:
	health -= dmg
	%damage_noise.play()


func die() -> void:
	if immortal:
		return
	if death_accomplished:
		return
	if current: 
		input_record.death_frame = Main.level.loop_manager.frame_index
		input_record.seconds_remaining_at_death = Main.level.loop_manager.current_loop_time
	dying = true
	var dummy : PlayerDummy = dummy_body_scene.instantiate()
	dummy.position = position
	dummy.rotation = rotation
	if not current:
		dummy.past_self = true
	Main.level.get_map().call_deferred("add_child", dummy)
	died.emit(dummy)
	active = false
	death_accomplished = true
	$QueueFreeTimer.start()

func _exit_tree() -> void:
	if current:
		if running_as_saved_player:
			Main.level.loop_manager.saved_player_handler.submit_input_record(input_record)
		else:
			#print("player submitting record")
			Main.level.loop_manager.submit_input_record(input_record)
			
			
func queue_die() -> void:
	if immortal:
		return
	active = false
	should_die = true


func _on_queue_free_timer_timeout() -> void:
	queue_free()

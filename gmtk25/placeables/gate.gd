extends StaticBody2D

@export var required_activations: int = 1
var activation_count: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var closed_by_default : bool = true
var is_open : bool = false

func _ready() -> void:
	if not closed_by_default:
		collision_shape.disabled = true
		animation_player.play("open")
		is_open = true
	else:
		collision_shape.disabled = false
		animation_player.play("close")
		is_open = false
		

func activate(is_active: bool):
	#print("door activated")
	if is_active:
		activation_count += 1
	else:
		activation_count = max(activation_count - 1, 0) # Optional: reduce count when deactivated

	if activation_count >= required_activations:
		set_door_to_default(false)
	else:
		set_door_to_default(true)
		
		
func set_door_to_default(default : bool) -> void:
	if closed_by_default:
		if default:
			close()
		else:
			open()
	else:
		if default:
			open()
		else:
			close()
		
		
func open() -> void:
	#print("open")
	if not is_open:
		collision_shape.set_deferred("disabled", true)
		animation_player.play("open")
		is_open = true

		
		
func close() -> void:
	#print("close")
	if is_open:
		collision_shape.set_deferred("disabled", false)
		animation_player.play("close")
		is_open = false

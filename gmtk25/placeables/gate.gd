extends StaticBody2D

@export var required_activations: int = 1
var activation_count: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var open : bool = false

func activate(is_active: bool):
	print("door activated")
	if is_active:
		activation_count += 1
	else:
		activation_count = max(activation_count - 1, 0) # Optional: reduce count when deactivated

	if activation_count >= required_activations and not open:
		collision_shape.set_deferred("disabled", true)
		animation_player.play("open")
		open = true
	elif open:
		collision_shape.set_deferred("disabled", false)
		animation_player.play("close")
		open = false

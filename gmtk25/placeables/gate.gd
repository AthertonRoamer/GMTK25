extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate(is_active: bool):
	print("door activated")
	if collision_shape.disabled == true:
		collision_shape.set_deferred("disabled", false)
	else:
		collision_shape.set_deferred("disabled", true)
	if is_active:
		animation_player.play("open")
	else:
		animation_player.play("close")

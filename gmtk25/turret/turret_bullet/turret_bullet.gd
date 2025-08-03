extends Projectile
class_name StandardGunBullet

@onready var raycast: RayCast2D = $RayCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dying: bool = false

func extinguish() -> void:
	animation_player.play("blow up")
	dying = true

func update_position(delta: float) -> void:
	if dying:
		velocity = Vector2.ZERO
		return

	# Set raycast direction and length based on velocity
	#raycast.target_position = velocity * delta
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit and hit != wielder:
			effect_body(hit)
			if extinguish_on_effect_body:
				extinguish()
	else:
		position += velocity * delta

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()

	
	
func effect_body(body : Node2D) -> void:
	var extinguish_triggered : bool = false
	if body.is_in_group("damageable") and body != wielder:

		body.take_damage(damage, damage_type)
		hit_entities.append(body)
		extinguish_triggered = true
	if extinguish_on_effect_body and extinguish_triggered:
		extinguish()

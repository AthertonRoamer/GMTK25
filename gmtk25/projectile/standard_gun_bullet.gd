extends Projectile
class_name TurretBullet

var dying : bool = false

func extinguish() -> void:
	$AnimationPlayer.play("blow up")
	dying = true
	
	
func update_position(delta) -> void:
	if !dying:
		position += velocity * delta
	else:
		velocity = Vector2.ZERO
	

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
	
	
func effect_body(body : Node2D) -> void:
	var extinguish_triggered : bool = false
	if body.is_in_group("damageable"):
		body.take_damage(damage, damage_type)
		hit_entities.append(body)
		extinguish_triggered = true
	if extinguish_on_effect_body and extinguish_triggered:
		extinguish()

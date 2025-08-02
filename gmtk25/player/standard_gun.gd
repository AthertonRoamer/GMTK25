class_name StandardGun
extends ProjectileHandler

var target_position : Vector2

func set_up_projectile() -> Projectile:
	var new_projectile : Projectile = projectile_scene.instantiate()
	new_projectile.global_position = get_fire_position()
	new_projectile.direction = projectile_direction
	new_projectile.rotation = new_projectile.direction.angle()
	new_projectile.wielder = get_parent()
	return new_projectile

class_name TurretArea
extends Area2D

var sight_range : float = 1:
	set(v):
		sight_range = v
		$CollisionShape2D.scale.x = v
		$CollisionShape2D.scale.y = v
		

var turret : Turret
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is Turret:
		get_parent().turret_area = self
		turret = get_parent()
	else:
		push_warning("Ship area is a child of a non-ship")

func get_visible_enemies() -> Array:
	return get_overlapping_bodies().filter(func(body): return body.is_in_group("player") and can_hit(body))
	
	
func can_hit(body : Node2D) -> bool:
	$RayCast2D.target_position = to_local(body.global_position)
	$RayCast2D.force_raycast_update()
	return $RayCast2D.is_colliding() and $RayCast2D.get_collider() == body
	
	
	
	

	

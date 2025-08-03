extends StaticBody2D


@export var max_health : int = 10
@export var starting_health : int = 10

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
	
	
func take_damage(damage : float, _damage_type : String = "none") -> void:
	health -= damage

func die() -> void:
	queue_free()
	
	
func activate(b : bool) -> void:
	if b:
		$laser.is_casting = false
	else:
		$laser.is_casting = true

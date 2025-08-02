class_name StandardGun
extends ProjectileHandler

var target_position : Vector2
@export var cool_down_time : float = 1
@export var player : Player
var cooling_down : bool = false


func _ready() -> void:

	$CoolDownTimer.wait_time = cool_down_time

func set_up_projectile() -> Projectile:
	var new_projectile : Projectile = projectile_scene.instantiate()
	new_projectile.global_position = get_fire_position()
	new_projectile.direction = projectile_direction
	new_projectile.rotation = new_projectile.direction.angle()
	new_projectile.wielder = player
	return new_projectile
	
	
func fire_projectile() -> void:
	super()
	cooling_down = true
	$CoolDownTimer.start()
	
	
func can_fire() -> bool:
	return not cooling_down


func _on_cool_down_timer_timeout() -> void:
	cooling_down = false

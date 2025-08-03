class_name PlayerDummy
extends StaticBody2D


signal dummy_release_camera

#func _ready() -> void:
	#$Camera2D.enabled = true
	
var past_self : bool = false

func _ready() -> void:
	if past_self:
		modulate = Color(Color.WHITE, 0.5)
	
	
func _on_kill_timer_timeout() -> void:
	die()

func die():
	$AnimationPlayer.play("death")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		#$CollisionShape2D.set_deferred("disabled", true)
		$despawn_timer.start()


func _on_despawn_timer_timeout() -> void:
	
	queue_free()


func _on_camera_exit_timer_timeout() -> void:
	dummy_release_camera.emit()

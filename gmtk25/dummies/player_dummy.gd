extends StaticBody2D





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

extends Area2D

@export_enum("Toggle", "Hold") var activation_mode : String = "Hold"
@export var target_scene : NodePath


@onready var animation_player: AnimationPlayer = $AnimationPlayer
var _is_active: bool = false

var player_on_button = false

func _on_body_entered(body: Node):
	print("entered")
	if not body.is_in_group("player"): return
	if activation_mode == "Toggle":
		_is_active = !_is_active
		activate()
	elif activation_mode == "Hold":
		_is_active = true
		activate()
	player_on_button = true

func _on_body_exited(body: Node):
	if not body.is_in_group("player"): return
	player_on_button = false
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("player"):
			player_on_button = true
			return
	if activation_mode == "Hold":
		_is_active = false
		activate()
	animation_player.play("RESET")

func activate():
	if !player_on_button:
		animation_player.play("glow")
		var target = get_node(target_scene)
		if target and target.has_method("activate"):
			target.activate(_is_active)

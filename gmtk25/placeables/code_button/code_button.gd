extends Area2D

@export_enum("Toggle", "Hold") var activation_mode : String = "Hold"
@export var target_scene : NodePath
@export var target_scene2 : NodePath
@export var target_paths : Array[NodePath] 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var active: bool = true

var player_on_button = false

var code : int = 0
@export var code_display : CodeDisplay
var unlocked : bool = false

@onready var code_input : Control = $CodeInput
@export var unique_name : String = "bob"

func _ready() -> void:
	print(str(CodeData.data))
	if CodeData.data.has(unique_name):
		code = CodeData.data[unique_name]
		print("retrieving")
	else:
		print("storing")
		code = randi_range(1000, 9999)
		#code = 1000
		CodeData.data[unique_name] = code
		print(CodeData.data)
	code_display.code = code
	code_input.visible = false
	$CodeInput/LineEdit.text = ""

func _on_body_entered(body: Node):
	if not body.is_in_group("player"): return
	code_input.visible = true
	$CodeInput/LineEdit.grab_focus()
	if get_overlapping_players().size() == 1:
		if activation_mode == "Toggle":
			active = !active
			activate()
		elif activation_mode == "Hold":
			active = true
			activate()


func _on_body_exited(body: Node):
	if not body.is_in_group("player"): return
	if not has_overlapping_players():
		code_input.visible = false
		$CodeInput/LineEdit.text = ""
	if not has_overlapping_players() and activation_mode == "Hold":
		active = false
		activate()
		animation_player.play("RESET")
	
	
	
func _physics_process(_delta: float) -> void:
	if activation_mode == "Hold":
		if not has_overlapping_players() and active:
			active = false
			activate()
	if not has_overlapping_players():
		code_input.visible = false
		$CodeInput/LineEdit.text = ""

	
func get_overlapping_players() -> Array:
	return get_overlapping_bodies().filter(func(body): return body.is_in_group("player"))
	
	
func has_overlapping_players() -> bool:
	return not get_overlapping_players().is_empty()


func activate():
	if not unlocked:
		return
	#print("button activating: ", active)
	if activation_mode == "HOLD":
		if has_overlapping_players():
			animation_player.play("glow")
		else:
			animation_player.play("RESET")
	else: #toggle
		if active:
			animation_player.play("glow")
		else:
			animation_player.play("RESET")

	var target = get_node_or_null(target_scene)
	if target and target.has_method("activate"):
		target.activate(active)

	if target_scene2 != NodePath("") and has_node(target_scene2):
		var target2 = get_node_or_null(target_scene2)
		if target2 and target2.has_method("activate"):
			target2.activate(active)
			
	for t in target_paths:
		var target_node = get_node_or_null(t)
		if target_node and target_node.has_method("activate"):
			target_node.activate(active)
			
			
			
func bypass_activate() -> void:
	var target = get_node_or_null(target_scene)
	if target and target.has_method("activate"):
		target.activate(active)

	if target_scene2 != NodePath("") and has_node(target_scene2):
		var target2 = get_node_or_null(target_scene2)
		if target2 and target2.has_method("activate"):
			target2.activate(active)
			
	for t in target_paths:
		var target_node = get_node_or_null(t)
		if target_node and target_node.has_method("activate"):
			target_node.activate(active)
			


func _on_line_edit_text_changed(new_text: String) -> void:
	unlocked = int(new_text) == code
	if unlocked:
		bypass_activate()
	print(int(new_text), " code: ", code, " unlocked: ", unlocked)

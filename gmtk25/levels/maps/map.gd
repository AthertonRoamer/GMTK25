class_name Map
extends Node2D

@export var spawn_point : Node2D
var players : Array[Player] = []
var active : bool = false

func set_players_active(p_active : bool) -> void:
	for player in players:
		if is_instance_valid(player):
			player.active = p_active

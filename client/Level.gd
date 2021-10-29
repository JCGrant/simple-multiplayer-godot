extends Node2D

var player_template = preload("res://Player.tscn")

func setup_state(state):
	for player_id in state.players:
		var player = state.players[player_id]
		spawn_player(player_id, player)

func spawn_player(player_id, player):
	var new_player = player_template.instance()
	new_player.id = player_id
	new_player.name = str(player_id)
	new_player.position = player.position
	if Network.is_local_player(player_id):
		var camera = Camera2D.new()
		camera.current = true
		new_player.add_child(camera)
		new_player.modulate = Color(0.0, 1.0, 0.0)
	$Players.add_child(new_player)

func despawn_player(player_id):
	_get_player(player_id).queue_free()

func move_player(player_id, position):
	_get_player(player_id).position = position

func _get_player(player_id):
	return get_node("Players/" + str(player_id))

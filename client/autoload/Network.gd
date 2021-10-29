extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 29292

func _ready():
	start_client()

func start_client():
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("Client started")

func _on_connection_succeeded():
	print("Connected to server")

func _on_connection_failed():
	print("Connecting to server failed")

func send(type, payload={}):
	rpc_unreliable_id(1, "_on_client_message", {
		"type": type,
		"player_id": get_tree().get_network_unique_id(),
		"payload": payload,
	})

remote func _on_server_message(message):
	var type = message.type
	var payload = message.payload
	if type == "SET_STATE":
		return get_node("../Level").setup_state(payload.state)
	if type == "PLAYER_JOINED":
		if is_local_player(payload.player_id):
			return
		return get_node("../Level").spawn_player(payload.player_id, payload.player)
	if type == "PLAYER_LEFT":
		return get_node("../Level").despawn_player(payload.player_id)
	if type == "PLAYER_MOVED":
		return get_node("../Level").move_player(payload.player_id, payload.position)

func is_local_player(player_id):
	return player_id == get_tree().get_network_unique_id()

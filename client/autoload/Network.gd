extends Node

var config = ConfigFile.new()
var network = NetworkedMultiplayerENet.new()
var ip
var port
var unreconciled_messages = {}

func _ready():
	config.load("settings.cfg")
	ip = config.get_value("server", "ip", "127.0.0.1")
	port = config.get_value("server", "port", 29292)
	start_client()

func start_client():
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("Client started")

func _on_connection_succeeded():
	print("Connected to server at " + ip + ":" + str(port))

func _on_connection_failed():
	print("Connecting to server failed")

remote func _on_server_messages(messages):
	for message in messages:
		var type = message.type
		var payload = message.payload
		var received_message_id = payload.get("message_id")
		if unreconciled_messages.has(received_message_id):
			unreconciled_messages.erase(received_message_id)
			return
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

var message_id = 1
func get_message_id():
	return str(get_tree().get_network_unique_id()) + str(message_id)
	message_id += 1

func send(type, payload={}):
	var id = get_message_id()
	var message = {
		"id": id,
		"type": type,
		"player_id": get_tree().get_network_unique_id(),
		"payload": payload,
	}
	unreconciled_messages[id] = message
	rpc_unreliable_id(1, "_on_client_message", message)

extends Node

var network = NetworkedMultiplayerENet.new()
var port = 29292
var max_players = 100
var state = {
	"players": {},
}

func _ready():
	start_server()

func start_server():
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started on port " + str(port))

func _on_peer_connected(player_id):
	var new_player = {"position": Vector2(0, 0)}
	state.players[player_id] = new_player
	send(player_id, "SET_STATE", {"state": state})
	broadcast("PLAYER_JOINED", {"player_id": player_id, "player": new_player})
	print("Player " + str(player_id) + " has connected")

func _on_peer_disconnected(player_id):
	state.players.erase(player_id)
	broadcast("PLAYER_LEFT", {"player_id": player_id})
	print("Player " + str(player_id) + " has disconnected")

remote func _on_client_message(message):
	var message_id = message.id
	var type = message.type
	var payload = message.payload
	var player_id = message.player_id
	if type == "MOVE_PLAYER":
		state.players[player_id].position = payload.position
		broadcast("PLAYER_MOVED", {"message_id": message_id, "player_id": player_id, "position": payload.position})

func send(id, type, payload={}):
	rpc_unreliable_id(id, "_on_server_message", {
		"type": type,
		"payload": payload,
	})

func broadcast(type, payload={}):
	rpc_unreliable("_on_server_message", {
		"type": type,
		"payload": payload,
	})

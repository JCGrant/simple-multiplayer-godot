extends Node

var network = NetworkedMultiplayerENet.new()
var port = 29292
var max_players = 100
var state = {
	"players": {},
}
var queued_sends = {}
var queued_broadcasts = []
var queued_unreliable_broadcasts = []

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
		broadcast_unreliable("PLAYER_MOVED", {"message_id": message_id, "player_id": player_id, "position": payload.position})

func send(id, type, payload={}):
	if not id in queued_sends:
		queued_sends[id] = []
	queued_sends[id].push_back({
		"type": type,
		"payload": payload,
	})

func broadcast(type, payload={}):
	queued_broadcasts.push_back({
		"type": type,
		"payload": payload,
	})

func broadcast_unreliable(type, payload={}):
	queued_unreliable_broadcasts.push_back({
		"type": type,
		"payload": payload,
	})

func _on_NetworkTick_timeout():
	for id in queued_sends:
		rpc_id(id, "_on_server_messages", queued_sends[id])
		queued_sends.erase(id)
	rpc("_on_server_messages", queued_broadcasts)
	queued_broadcasts.clear()
	rpc_unreliable("_on_server_messages", queued_unreliable_broadcasts)
	queued_unreliable_broadcasts.clear()

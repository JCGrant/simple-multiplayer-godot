extends Node

var network = NetworkedMultiplayerENet.new()
var port = 29292
var max_players = 100

func _ready():
	start_server()

func start_server():
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started on port " + str(port))

func _on_peer_connected(player_id):
	print("Player " + str(player_id) + " has connected")

func _on_peer_disconnected(player_id):
	print("Player " + str(player_id) + " has disconnected")

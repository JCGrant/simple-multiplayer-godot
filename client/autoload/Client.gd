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

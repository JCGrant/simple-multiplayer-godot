extends Node2D

func _on_Button_pressed():
	Network.send("CLICK_BUTTON")

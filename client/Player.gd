extends KinematicBody2D

var id

export (int) var speed = 10

func _physics_process(_delta):
	if not Network.is_local_player(id):
		return
	var velocity = Vector2()
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	velocity = velocity.normalized() * speed
	if velocity != Vector2.ZERO:
		Network.send("MOVE_PLAYER", {"velocity": velocity})

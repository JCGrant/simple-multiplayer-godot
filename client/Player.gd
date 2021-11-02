extends KinematicBody2D

var id

export (int) var speed = 600

var target_position = position

func _physics_process(_delta):
	if not Network.is_local_player(id):
		$Tween.interpolate_property(self, "position", position, target_position, 0.1)
		$Tween.start()
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
	velocity = move_and_slide(velocity, Vector2.UP)
	Network.send("MOVE_PLAYER", {"position": position})

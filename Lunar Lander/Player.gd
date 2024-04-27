extends CharacterBody2D

var max_speed = 100
var acceleration = 400
var direction = -1

var gravity = 200
var max_fall = 150

func _process(delta):
	
	# gravity
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall)
	
	# accelerate
	if Input.is_action_pressed("ui_up"):
		velocity.y -= acceleration * delta
		
	# rotate
	if Input.is_action_pressed("ui_right"):
		self.rotate(2 * delta)
	if Input.is_action_pressed("ui_left"):
		self.rotate(-2 * delta)
	
	set_velocity(velocity)
	set_up_direction(Vector2.DOWN)
	move_and_slide()
	velocity = velocity
	

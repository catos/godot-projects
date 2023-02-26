extends CharacterBody2D

enum States { MOVE, JUMP, FALL, CROUCH }
var state: States = States.MOVE

@export var move_speed: float = 250.0

@export var jump_height: float = 125.0
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var animatedSprite := $AnimatedSprite2D
@onready var debug := $Debug

var direction: Vector2 = Vector2.ZERO

func _input(event):
	if event.is_action_pressed("reset"):
		position = Vector2(128, 128)
	
func _physics_process(delta):
	update_debug()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity() * delta

	# Input direction
	direction = Input.get_vector("left", "right", "up", "down")
	
	# Flip sprite
	if (direction.x != 0):
		animatedSprite.flip_h = direction.x > 0
	
	# Update velocity & move
	if direction:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	move_and_slide()

	match state:
		States.MOVE: move_state(delta)
		States.JUMP: jump_state(delta)
		States.FALL: fall_state(delta)
		States.CROUCH: crouch_state(delta)

func move_state(_delta):
	if velocity.y > 0:
		state = States.FALL

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		state = States.JUMP

	if Input.is_action_just_pressed("down") and is_on_floor():
		state = States.CROUCH
		
func jump_state(_delta):
	if velocity.y > 0:
		state = States.FALL
	
	if is_on_floor():
		state = States.MOVE

func fall_state(_delta):
	if is_on_floor():
		state = States.MOVE

func crouch_state(_delta):
	if Input.is_action_just_pressed("jump"): 
		state = States.JUMP
		jump(1.2)
	
	if Input.is_action_just_released("down"):
		state = States.MOVE

func jump(force_modifier = 1.0):
	velocity.y = jump_velocity * force_modifier

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func update_debug():
	var state_string = ""
	match state:
		States.MOVE: state_string = "move"
		States.JUMP: state_string = "jump"
		States.FALL: state_string = "fall"
		States.CROUCH: state_string = "crouch"
		
	debug.text = state_string + " - " + str(is_on_floor())
	

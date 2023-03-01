extends CharacterBody2D

enum States { MOVE, JUMP, FALL, CROUCH }
var state: States = States.MOVE

@export var move_speed: float = 150.0

@export var jump_height: float = 75.0
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var animatedSprite := $AnimatedSprite2D
@onready var coyoteJumpTimer := $CoyoteTimer
@onready var debug := $Debug

var direction := Vector2.ZERO
var is_coyote_jumping := false
var can_jump := false

func _input(event):
	if event.is_action_pressed("reset"):
		position = Vector2(128, 128)
	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity() * delta

	# Input direction
	direction = Input.get_vector("left", "right", "up", "down")
	
	# Flip sprite
	if (direction.x != 0):
		animatedSprite.flip_h = direction.x > 0
	
	match state:
		States.MOVE: move_state()
		States.JUMP: jump_state()
		States.FALL: fall_state()
		States.CROUCH: crouch_state()

	if (Input.is_action_just_pressed("jump") and can_jump):
		state = States.JUMP
		jump()

func move_state():
	update_velocity_and_move()

	if (velocity.x != 0):
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"

	if (velocity.y > 0):
		state = States.FALL

	if Input.is_action_just_pressed("down") and is_on_floor():
		state = States.CROUCH
		
func jump_state():
	update_velocity_and_move()

	animatedSprite.animation = "Jump"
	
	if (velocity.y > 0):
		state = States.FALL
	
	if (is_on_floor()):
		state = States.MOVE

func fall_state():
	update_velocity_and_move()

	animatedSprite.animation = "Fall"
	
	if is_on_floor():
		state = States.MOVE

func crouch_state():
	if Input.is_action_just_pressed("jump"): 
		state = States.JUMP
		jump(1.2)
	
	if Input.is_action_just_released("down"):
		state = States.MOVE

func update_velocity_and_move():
	if direction:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_floor = was_on_floor and not is_on_floor()
	if (just_left_floor and velocity.y >= 0):
		is_coyote_jumping = true
		coyoteJumpTimer.start()

	can_jump = is_on_floor() or is_coyote_jumping

#	debug.text = "coyote: " + str(is_coyote_jumping) + "\ncan: " + str(can_jump)


func jump(force_modifier = 1.0):
	velocity.y = jump_velocity * force_modifier

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _on_coyote_timer_timeout():
	is_coyote_jumping = false

extends KinematicBody2D
class_name Player

enum STATES { move, jump, crouch }

onready var collisionShape := $CollisionShape2D
onready var animatedSprite := $AnimatedSprite
onready var coyoteJumpTimer := $CoyoteJumpTimer
onready var healthLossTimer := $HealthLossTimer

export (float, 0, 1.0) var friction = 0.2
export (float, 0, 1.0) var acceleration = 0.25

export (int) var jump_force = 160
export (int) var gravity = 325
export (int) var max_gravity = 300

var hitpoints = 3
var state = STATES.move
var speed = 150
var input = Vector2.ZERO
var velocity = Vector2.ZERO
var coyote_jump = false

#func _draw():
#	var from = global_transform.origin
#	var to = global_transform.origin + velocity
#	draw_line(from, to, Color(0.0, 0.0, 1.0))

func _physics_process(delta):
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_gravity)
	
	match state:
		STATES.move: move_state(delta)
		STATES.jump: jump_state(delta)
		STATES.crouch: crouch_state(delta)

func move_state(delta):
	# Acceleration and friction
	if input.x != 0:
		var acc_weight = acceleration if is_on_floor() else acceleration * .5
		velocity.x = lerp(velocity.x, input.x * speed, acc_weight)
	else:
		var friction_weight = friction if is_on_floor() else friction * .25
		velocity.x = lerp(velocity.x, 0, friction_weight)
	
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_left_floor = was_on_floor and not is_on_floor()
	if just_left_floor and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

	if input.x != 0:
		animatedSprite.flip_h = input.x < 0
	
	var can_jump = is_on_floor() or coyote_jump
	if can_jump && Input.is_action_just_pressed("jump"): 
		state = STATES.jump
		jump()
	
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		state = STATES.crouch
	
	if input.x == 0:
		animatedSprite.animation = "Idle"
	elif input.x != 0:
		animatedSprite.animation = "Run"

func jump_state(delta):
	if is_on_floor():
		state = STATES.move
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Set animation
	if velocity.y < 0:
		animatedSprite.animation = "Jump"
	elif velocity.y > 0:
		animatedSprite.animation = "Fall"

func crouch_state(delta):
#	collisionShape.set_shape(RectangleShape2D(2, 3))
	
	if Input.is_action_just_released("ui_down"):
		state = STATES.move
		
	animatedSprite.animation = "Crouch"

func jump():
	velocity.y = -jump_force

func collided_with_enemy(damage, otherPosition):
	print(healthLossTimer.get_time_left())
	if healthLossTimer.get_time_left() == 0:
		velocity.x *= -3 # TODO: improve this :D
		hitpoints -= damage
		print("other pos: %s" % [otherPosition])
		Events.emit_signal("update_player_health", hitpoints)
		healthLossTimer.start()
	
func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

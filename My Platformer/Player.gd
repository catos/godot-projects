extends KinematicBody2D
class_name Player

enum STATES { move, jump, fall, crouch }

onready var collisionShape := $CollisionShape2D
onready var animatedSprite := $AnimatedSprite
onready var coyoteJumpTimer := $CoyoteJumpTimer
onready var healthLossTimer := $HealthLossTimer
onready var debug := $Debug

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
	
	update_velocity(delta)
	
	# Flip sprite if input
	if input.x != 0:
		animatedSprite.flip_h = input.x < 0
	

	match state:
		STATES.move: 
			debug.text = "move"
			move_state(delta)
		STATES.jump: 
			debug.text = "jump"
			jump_state(delta)
		STATES.fall: 
			debug.text = "fall"
			jump_state(delta)
		STATES.crouch: 
			debug.text = "crouch"
			crouch_state(delta)

func move_state(_delta):
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_left_floor = was_on_floor and not is_on_floor()
	if just_left_floor and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

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

func jump_state(_delta):
	velocity = move_and_slide(velocity, Vector2.UP)
	animatedSprite.animation = "Jump"
	
	if velocity.y > 0:
		state = STATES.fall

	if is_on_floor():
		state = STATES.move

func fall_state(_delta):
	animatedSprite.animation = "Fall"

	if is_on_floor():
		state = STATES.move

func crouch_state(delta):
#	collisionShape.extents = Vector2(2, 3)
	animatedSprite.animation = "Crouch"
	
	if Input.is_action_just_pressed("jump"): 
		state = STATES.jump
		jump(1.2)
	
	if Input.is_action_just_released("ui_down"):
		state = STATES.move

func update_velocity(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_gravity)

	# Acceleration and friction
	if input.x != 0:
		var acc_weight = acceleration if is_on_floor() else acceleration * .5
		velocity.x = lerp(velocity.x, input.x * speed, acc_weight)
	else:
		var friction_weight = friction if is_on_floor() else friction * .25
		velocity.x = lerp(velocity.x, 0, friction_weight)

func jump(force_modifier = 1.0):
	velocity.y = -jump_force * force_modifier

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

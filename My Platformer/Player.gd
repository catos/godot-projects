extends KinematicBody2D
class_name Player

enum STATES { move, jump, fall, crouch }

onready var collisionShape := $CollisionShape2D
onready var animatedSprite := $AnimatedSprite
onready var coyoteJumpTimer := $CoyoteJumpTimer
onready var healthLossTimer := $HealthLossTimer
onready var wallJumpTimer := $WallJumpTimer
onready var rayRight := $RayCastRight
onready var rayLeft := $RayCastLeft
#onready var gun := $Gun
onready var debug := $Debug

export (PackedScene) var Bullet

export (float, 0, 1.0) var friction = 0.2
export (float, 0, 1.0) var acceleration = 0.25

export var move_speed: float = 125.0

export var jump_height: float = 40.0
export var jump_time_to_peak: float = 0.4
export var jump_time_to_descent: float = 0.3

onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

onready var wall_jump_velocity: float = 200

var hitpoints = 3
var state = STATES.move
var input = Vector2.ZERO
var velocity = Vector2.ZERO
var coyote_jump = false
var wall_jump_on_timer = false

#func _draw():
#	var from = global_transform.origin
#	var to = global_transform.origin + velocity
#	draw_line(from, to, Color(0.0, 0.0, 1.0))

func _physics_process(delta):
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
#	if Input.is_action_just_pressed("shoot"):
#		shoot()
	
	update_velocity(delta)
	update_debug_text()
	wall_jump()
	
	# Flip sprite if input
	if input.x != 0:
		animatedSprite.flip_h = input.x < 0

	match state:
		STATES.move: move_state(delta)
		STATES.jump: jump_state(delta)
		STATES.fall: fall_state(delta)
		STATES.crouch: crouch_state(delta)

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
	velocity = move_and_slide(velocity, Vector2.UP)
	animatedSprite.animation = "Fall"

	if is_on_floor():
		state = STATES.move

func crouch_state(_delta):
#	collisionShape.extents = Vector2(2, 3)
	animatedSprite.animation = "Crouch"
	
	if Input.is_action_just_pressed("jump"): 
		state = STATES.jump
		jump(1.2)
	
	if Input.is_action_just_released("ui_down"):
		state = STATES.move

func update_velocity(delta):
	velocity.y += get_gravity() * delta
	# TODO: check if we need a max ?
#	velocity.y = min(velocity.y, max_gravity)

	# Acceleration and friction
	if input.x != 0:
		var acc_weight = acceleration if is_on_floor() else acceleration * .5
		velocity.x = lerp(velocity.x, input.x * move_speed, acc_weight)
	else:
		var friction_weight = friction if is_on_floor() else friction * .25
		velocity.x = lerp(velocity.x, 0, friction_weight)
#	var direction = Input.get_axis("ui_left", "ui_right")
#	if direction:
#		velocity.x = direction * move_speed
#	else:
#		velocity.x = move_toward(velocity.x, 0, move_speed)

func jump(force_modifier = 1.0):
	velocity.y = jump_velocity * force_modifier

func wall_jump():
	var is_on_wall = rayRight.is_colliding() or rayLeft.is_colliding()
	var can_wall_jump = is_on_wall and not is_on_floor() and not wall_jump_on_timer and Input.is_action_just_pressed("jump")
	
	var x_force = wall_jump_velocity
	if rayRight.is_colliding():
		x_force *= -1
	
	if can_wall_jump:
		print("wall jump!")
		wall_jump_on_timer = true
		wallJumpTimer.start()
		velocity.y = jump_velocity
		velocity.x = x_force

func collided_with_enemy(damage, otherPosition):
	print(healthLossTimer.get_time_left())
	if healthLossTimer.get_time_left() == 0:
		velocity.x *= -3 # TODO: improve this :D
		hitpoints -= damage
		print("other pos: %s" % [otherPosition])
		Events.emit_signal("update_player_health", hitpoints)
		healthLossTimer.start()

#func shoot() -> void:
#	var b = Bullet.instance()
#	add_child(b)
#	b.transform = gun.transform
	
func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

func update_debug_text() -> void:
	match state:
		STATES.move: debug.text = "move"
		STATES.jump: debug.text = "jump"
		STATES.fall: debug.text = "fall"
		STATES.crouch: debug.text = "crouch"
		
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func _on_WallJumpTimer_timeout():
	wall_jump_on_timer = false

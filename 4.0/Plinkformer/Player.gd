extends CharacterBody2D


@export var move_speed: float = 350.0

@export var jump_height: float = 125.0
@export var jump_time_to_peak: float = 0.45
@export var jump_time_to_descent: float = 0.35

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _input(event):
	if event.is_action_pressed("reset"):
		position = Vector2(192, 192)
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity() * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()

func jump():
	velocity.y = jump_velocity

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

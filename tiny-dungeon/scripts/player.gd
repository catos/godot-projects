extends CharacterBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	print(direction)
	#if direction.x:
		#velocity.x = direction.x * SPEED
	#if direction.y:
		#velocity.y = direction.y * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		
	velocity = direction * SPEED

	move_and_slide()

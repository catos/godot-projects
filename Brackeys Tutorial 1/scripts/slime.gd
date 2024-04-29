extends Node2D

const SPEED = 60

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

var direction = 1

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1
	
	animated_sprite_2d.flip_h = direction < 0
		
	position.x += direction * SPEED * delta

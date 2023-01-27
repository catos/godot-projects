extends Node2D

onready var sprite = $AnimatedSprite

func _ready():
	sprite.animation = "0"

func _process(delta):
	if Input.is_action_just_pressed("click"):
		print("click")
		sprite.animation = "1"

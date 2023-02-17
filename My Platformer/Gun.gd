extends Node2D

export var radius := 30

onready var label := $Label

var mouse_dir = Vector2.ZERO
var target_pos = Vector2.ZERO

#func _ready():
#	transform.origin = offset
#	pass

func _process(delta):
	var gun_pos = global_transform.origin
	mouse_dir = (get_global_mouse_position() - gun_pos).normalized()
	target_pos = global_transform.origin + (mouse_dir * 10)
	label.text = "%s %s" % [target_pos.x, target_pos.y]
	self.global_transform.origin = target_pos
	update()
	
#	transform.origin = player_pos + (mouse_dir * radius)
#	position = player_pos
	

func _draw() -> void:
	draw_line(Vector2.ZERO, mouse_dir * 10, Color(1.0, 0.0, 0.0, 0.25), 2.0)

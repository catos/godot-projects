extends Area2D

onready var animatedSprite: = $AnimatedSprite

var is_checked = false

func _on_Checkpoint_body_entered(body):
	if not body is Player or is_checked: return
	
	is_checked = true
	animatedSprite.play("Checked")
	Events.emit_signal("hit_checkpoint", position)

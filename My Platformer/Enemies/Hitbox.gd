extends Area2D

func _on_Hitbox_body_entered(body):
	if body is Player:
		body.collided_with_enemy(1)

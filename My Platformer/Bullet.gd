extends Area2D

onready var lifetimeTimer := $LifetimeTimer

export var speed := 750

func _ready():
	lifetimeTimer.start()

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_LifetimeTimer_timeout():
	print("Bullet ran out of time...")
	self.queue_free()


func _on_Bullet_body_entered(body):
	print("Bullet hit something %s" % body)
	self.queue_free()

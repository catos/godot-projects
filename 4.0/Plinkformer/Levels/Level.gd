extends Node

const PlayerScene = preload("res://Player/player.tscn")

@onready var spawn_location := Vector2(128, 128)
@onready var player := $Player
@onready var camera := $Camera
@onready var respawnTimer := $RespawnTimer

func _ready():
	player.position = spawn_location
	camera.position = player.position
	Events.connect("player_died", _on_player_died)

func _process(_delta):
	if player != null:
		camera.position = player.position
	
func _on_player_died():
	respawnTimer.start()

func _on_respawn_timer_timeout():
	player = PlayerScene.instantiate()
	player.position = spawn_location
	add_child(player)
	camera.position = player.position

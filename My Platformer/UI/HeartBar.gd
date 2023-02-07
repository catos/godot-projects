extends HBoxContainer

var heart_full = preload("res://GFX/heart-full.png")
var heart_empty = preload("res://GFX/heart-empty.png")

func _ready():
	var error = Events.connect("update_player_health", self, "update_health")
	if error:
		print(error)

func update_health(value):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = heart_full
		else:
			get_child(i).texture = heart_empty

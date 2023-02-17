extends Camera2D

export (NodePath) var target_path = null
var target_node

export (float, 0.0, 5.0) var lerp_speed = 4.0

func _ready():
	target_node = get_node(target_path)
	self.position = target_node.position

func _process(_delta):
	self.position = target_node.position
#	self.position = lerp(self.position, target_node.position, lerp_speed * delta)

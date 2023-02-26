extends Camera2D

@export var target_path: NodePath

var target_node: Node2D

func _ready():
	target_node = get_node(target_path)
	self.position = target_node.position

func _process(delta):
	self.position = target_node.position

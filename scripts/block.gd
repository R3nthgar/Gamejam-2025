extends RigidBody2D
@onready var area_2d: Area2D = $Area2D
@onready var block: RigidBody2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func hurt():
	block.queue_free()

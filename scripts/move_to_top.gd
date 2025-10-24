extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		body.velocity.y=-100

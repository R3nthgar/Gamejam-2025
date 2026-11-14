extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		body.velocity.y=-100
		#if body is player:
		#	body.stop_grapple()


func _on_body_entered(body: Node2D) -> void:
		body.position.y-=28

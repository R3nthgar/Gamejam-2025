extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Music.trackchange(1)
func _ready() -> void:
	Music.trackchange(0)

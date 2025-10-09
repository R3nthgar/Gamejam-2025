extends Area2D

@onready var timer: Timer = $Timer
@onready var death: Label = $"../../CanvasLayer/Death"

func _on_body_entered(body: Node2D) -> void:
	body.die()

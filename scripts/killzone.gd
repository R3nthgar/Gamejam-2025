extends Area2D

@onready var timer: Timer = $Timer
@onready var death: Label = $"../../CanvasLayer/Death"

func _on_body_entered(body: Node2D) -> void:
	print("You Died")
	Engine.time_scale=0.5
	timer.start()
	death.text="You Died"
	body.die()
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale=1

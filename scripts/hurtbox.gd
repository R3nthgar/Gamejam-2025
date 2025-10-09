extends Area2D
@onready var hurtbox: Area2D = $"."

func _on_area_entered(area: Area2D) -> void:
	area.hurt()

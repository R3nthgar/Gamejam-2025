extends Node2D
@onready var animation_player: AnimationPlayer = $RichTextLabel/AnimationPlayer
@onready var animation_player2: AnimationPlayer = $RichTextLabel2/AnimationPlayer


func _on_timer_timeout() -> void:
	animation_player.play("new_animation")
	animation_player2.play("new_animation_2")

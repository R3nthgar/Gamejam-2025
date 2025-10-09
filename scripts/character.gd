extends CharacterBody2D

@export var gravity_norm = 60
@export var gravity_fall = 60
@export var gravity_jump = 20
@export var move_speed = 200
@export var jump_speed = -800
var gravity = gravity_norm
var jump_queued = false
var time_jump_held_down = 0

func _physics_process(_delta: float) -> void:
	velocity.x = move_speed * Input.get_axis("Left", "Right")
	velocity.y += gravity
	move_and_slide()
	
	if Input.is_action_pressed("Jump"):
		time_jump_held_down += 1
		print(time_jump_held_down)
		if is_on_floor():
			#gravity = gravity_jump
			velocity.y = jump_speed
			jump_queued = false
		else:
			if time_jump_held_down > 20:
				velocity.y -= 10
			elif time_jump_held_down > 40:
				velocity.y -= 20
	else:
		time_jump_held_down = 0
	
	if Input.is_action_just_pressed("Jump"):
		jump_queued = true
		$RememberJump.start()
	
	if Input.is_action_just_released("Jump"):
		#gravity = gravity_fall
		pass
	
	if is_on_floor() and jump_queued:
		#gravity = gravity_jump
		velocity.y = jump_speed
		jump_queued = false


func _on_remember_jump_timeout() -> void:
	jump_queued = false

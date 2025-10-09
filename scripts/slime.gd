extends Node2D
const speed = 20
var direction = 1
@onready var ray_cast_bottom_right: RayCast2D = $RayCastBottomRight
@onready var ray_cast_bottom_left: RayCast2D = $RayCastBottomLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_bottom: RayCast2D = $RayCastBottom
@onready var ray_cast_bottom_2: RayCast2D = $RayCastBottom2
@onready var ray_cast_bottom_3: RayCast2D = $RayCastBottom3
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var slime: Node2D = $"."

var moving = true
var health = 3
func _process(delta: float) -> void:
	if(moving):
		if(ray_cast_bottom_2.is_colliding() or ray_cast_bottom_3.is_colliding()):
			position.y -= 1
		else:
			if(not ray_cast_bottom.is_colliding()):
				position.y += 1
		if(ray_cast_right.is_colliding() or not ray_cast_bottom_right.is_colliding()):
			direction = -1
			animated_sprite_2d.flip_h=true
		if (ray_cast_left.is_colliding() or not ray_cast_bottom_left.is_colliding()):
			direction = 1
			animated_sprite_2d.flip_h=false
		position.x += direction * speed * delta
		
		pass
func hurt():
	if(moving):
		timer.start()
		animated_sprite_2d.position.y=3
		animated_sprite_2d.play("hurt")
		moving=false
func _on_timer_timeout() -> void:
	health-=1
	if(health>0):
		animated_sprite_2d.position.y=0
		animated_sprite_2d.play("default")
		moving=true
	else:
		slime.queue_free()
	

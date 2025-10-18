extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = $".."
@onready var player: CharacterBody2D = $"."
@onready var camera_2d: Camera2D = $Camera2D
@onready var line_2d: Line2D = $"../Line2D"
@onready var grapple_points: Node = %"Grapple Points"
@onready var grapple_icon: Button = $"../GrappleIcon"
@onready var timer: Timer = $Timer
@onready var death: Label = $"../CanvasLayer/Death"
@onready var death_timer: Timer = $DeathTimer
@onready var offscreen: Node2D = %Offscreen
@onready var forwards: RayCast2D = $Forwards
@onready var backwards: RayCast2D = $Backwards
@onready var downwards: RayCast2D = $Downwards
@onready var upwards: RayCast2D = $Upwards

const maxspeed = 200.0
@onready var victory_zone: Area2D = %VictoryZone
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var stringlength = 100
var side = 0
var health = 3
var hurting=false
var swinging = false
var truecenter
var dead = false
var launched = false
var length = 0
var swingingmovement = true
var jumping = false
var inair = false
var lastside=-1
func play_anim(anim):
	if(not hurting):
		animated_sprite_2d.play(anim)
func jump():
	velocity += Vector2(0,JUMP_VELOCITY).rotated(side*PI/2)
func _ready() -> void:
	truecenter=player
func gravity(center: Vector2, delta):
	velocity += Vector2(get_gravity().y * cos(center.angle_to_point(position)), 0).rotated(center.angle_to_point(position) + PI/2) * delta
func is_touching():
	return forwards.is_colliding() or downwards.is_colliding() or upwards.is_colliding() or backwards.is_colliding()
func _physics_process(delta: float) -> void:
	if not (dead):
		grapple_icon.position=near_grapple(player.position).position
		if Input.is_action_just_pressed("Grapple"):
			start_grapple(position)
		var center = truecenter.position
		if not swinging:
			var forwardcol=forwards.is_colliding()
			var backwardcol=backwards.is_colliding()
			var upwardcol=upwards.is_colliding()
			var downwardcol=downwards.is_colliding()
			if upwardcol and not (forwardcol or backwardcol or downwardcol):
				animated_sprite_2d.rotation=0
				side=2
				animated_sprite_2d.flip_v=true
			elif forwardcol and not (upwardcol or backwardcol or downwardcol):
				animated_sprite_2d.rotation=PI/2
				animated_sprite_2d.flip_v=true
				side=3
			elif backwardcol and not (upwardcol or forwardcol or downwardcol):
				animated_sprite_2d.rotation=PI/2
				animated_sprite_2d.flip_v=false
				side=1
			elif not (upwardcol or backwardcol or forwardcol):
				animated_sprite_2d.rotation=0
				side=0
				animated_sprite_2d.flip_v=false
			var direction: = Input.get_axis("Left", "Right")
			if is_touching():
				if direction:
					if(side%2==0):
						if(forwards.is_colliding() and direction==1 and lastside!=3):
							animated_sprite_2d.rotation=PI/2
							animated_sprite_2d.flip_v=true
							lastside=side
							side=3
						elif(backwards.is_colliding() and direction==-1 and lastside!=1):
							animated_sprite_2d.rotation=PI/2
							animated_sprite_2d.flip_v=false
							lastside=side
							side=1
						else:
							velocity.x=move_toward(velocity.x, SPEED*direction,SPEED*delta*10)
					else:
						if(downwards.is_colliding() and direction*(side-2)==-1 and lastside!=0):
							animated_sprite_2d.rotation=0
							animated_sprite_2d.flip_v=false
							lastside=side
							side=0
						elif(upwards.is_colliding() and direction*(side-2)==1 and lastside!=2):
							animated_sprite_2d.rotation=0
							animated_sprite_2d.flip_v=true
							lastside=side
							side=2
						else:
							velocity.y=move_toward(velocity.y, SPEED*direction*(side-2)*-1,SPEED*delta*10)
					if(side!=3):
						animated_sprite_2d.flip_h = direction == -1
					else:
						animated_sprite_2d.flip_h = direction == 1
					play_anim("run")
				else:
					play_anim("idle")
					lastside=-1
					if(side%2==0):
						velocity.x = move_toward(velocity.x, 0,SPEED*delta*5)
					else:
						velocity.y = move_toward(velocity.y, 0,SPEED*delta*5)
			else:
				velocity.x=move_toward(velocity.x, SPEED*direction,SPEED*delta*5)
				animated_sprite_2d.flip_h = direction == -1
			if Input.is_action_just_pressed("Jump"):
				if(is_touching()):
					jump()
			if not is_touching():
				velocity += get_gravity() * delta
				if ( not dead and not launched):
					play_anim("jump")
			move_and_slide()
		else:
			if Input.is_action_just_pressed("Jump"):
				swinging = false
				player.rotation = 0
				velocity.y += JUMP_VELOCITY
				animated_sprite_2d.flip_h = (velocity.x < 0)
				line_2d.points = PackedVector2Array([])
				play_anim("roll")
				launched = true
				move_and_slide()
			elif is_touching():
				swinging = false
				player.rotation = 0
				animated_sprite_2d.flip_h = (velocity.x < 0)
				line_2d.points = PackedVector2Array([])
				move_and_slide()
			else:
				var direction: = Input.get_axis("Left", "Right")
				if (not is_on_floor()):
					velocity -= Vector2((pow(velocity.length() * delta, 2)) / position.distance_to(center), 0).rotated(center.angle_to_point(position)) / delta
					if direction and swingingmovement:
						velocity += Vector2(SPEED * delta * 0.5, 0).rotated(center.angle_to_point(position)-PI/2*direction)
				else:
					if(direction):
						velocity.x = direction * SPEED
						animated_sprite_2d.flip_h = direction == -1
						play_anim("run")
					else:
						velocity.x = move_toward(velocity.x, 0, SPEED)
						play_anim("idle")
				var directionv: = Input.get_axis("Down", "Up")
				if directionv and swingingmovement:
					if ( not (directionv == 1 and position.distance_to(center) <= 10 + delta*30) and not ((directionv == -1 and position.distance_to(center) > stringlength + 30 * delta - 1))):
						var lastPos = position
						position += directionv * Vector2(30 * delta, 0).rotated(position.angle_to_point(center))
						velocity *= position.distance_to(center) / lastPos.distance_to(center)
						length -= directionv*30*delta
				if ( not is_on_floor()):
					gravity(center,delta / 2)
				move_and_slide()
				if(not is_on_floor()):
					position=center+Vector2(length,0).rotated(center.angle_to_point(position))
					player.rotation = center.angle_to_point(position) - PI / 2
					animated_sprite_2d.flip_h = (velocity.x < 0) == (position.y > center.y)
				else:
					length=position.distance_to(center)
					player.rotation = 0
					animated_sprite_2d.flip_h = (velocity.x < 0)
				if not is_on_floor():
					gravity(center,delta / 2)
				if (swinging):
					line_2d.points = PackedVector2Array([position, center])
	else:
		if ( not is_on_floor()):
			velocity += get_gravity() * delta
		else:
			velocity *= 0
		move_and_slide()

func near_grapple(search_point):
	var grapple_points_arr=grapple_points.get_children().filter(func(a): return position.distance_squared_to(a.position)<=stringlength * stringlength)	
	if(grapple_points_arr.size()==0):
		return offscreen
	grapple_points_arr.sort_custom(func(a,b): return search_point.distance_squared_to(a.position) < search_point.distance_squared_to(b.position))
	return grapple_points_arr[0]

func start_grapple(search_point):
	truecenter=near_grapple(search_point)
	if(truecenter != offscreen):
		jumping = false
		swinging = true
		play_anim("jump")
		var center = truecenter.position
		length = position.distance_to(center)
		var angle = center.angle_to_point(position) + PI / 2
		velocity.x = velocity.x * cos(angle)
		velocity.y = velocity.y * sin(angle)
		if ((abs(velocity.y) < abs(velocity.x) and velocity.x > 0) or (abs(velocity.y) > abs(velocity.x) and velocity.y > 0)):
			velocity = Vector2(velocity.length(), 0).rotated(center.angle_to_point(position) + PI / 2)
		else:
			velocity = - Vector2(velocity.length(), 0).rotated(center.angle_to_point(position) + PI / 2)
func hurt():
	if(not hurting):
		health-=1
		if(health>0):
			play_anim("hurt")
			hurting=true
			timer.start()
		else:
			die()
func _on_timer_timeout() -> void:
	hurting=false
	play_anim("default")
func die():
	dead = true
	if is_on_floor():
		play_anim("death1")
	else:
		play_anim("death2")
	swinging = false
	player.rotation = 0
	line_2d.points = PackedVector2Array([])
	Engine.time_scale=0.5
	death_timer.start()
	death.text="You Died"
func _on_death_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale=1
func triumph():
	print("Victory...has been obtained.")

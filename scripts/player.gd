extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = $".."
@onready var player: CharacterBody2D = $"."
@onready var camera_2d: Camera2D = $Camera2D
@onready var line_2d: Line2D = $"../Line2D"
@onready var grapple_points: Node = %"Grapple Points"
@onready var grapple_icon: Button = $"../GrappleIcon"
@onready var hurttimer: Timer = $HurtTimer
@onready var death: Label = $"../CanvasLayer/Death"
@onready var death_timer: Timer = $DeathTimer
@onready var offscreen: Node2D = %Offscreen
@onready var forwards: RayCast2D = $Forwards
@onready var backwards: RayCast2D = $Backwards
@onready var downwards: RayCast2D = $Downwards
@onready var upwards: RayCast2D = $Upwards
@onready var forwardsdown: RayCast2D = $Forwardsdown
@onready var forwardsup: RayCast2D = $Forwardsup
@onready var backwardsdown: RayCast2D = $Backwardsdown
@onready var backwardsup: RayCast2D = $Backwardsup
@onready var health_icons: Node2D = %HealthIcons

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
var stopped=false
var inair = false
var lastgroundpos = position
var lastside
func play_anim(anim):
	if(not hurting):
		animated_sprite_2d.play(anim)
func changeside(newside):
	animated_sprite_2d.rotation=PI/2*(newside%2)
	animated_sprite_2d.flip_v=newside-1>0
	side=newside
func jump():
	if(side==0):
		velocity.y=JUMP_VELOCITY
	elif side==2:
		velocity.y=-JUMP_VELOCITY/5
	else:
		velocity.y=JUMP_VELOCITY
		velocity.x=JUMP_VELOCITY/2*(side-2)
func _ready() -> void:
	truecenter=player
	lastgroundpos=position
	lastside=side
func gravity(center: Vector2, delta):
	velocity += Vector2(get_gravity().y * cos(center.angle_to_point(position)), 0).rotated(center.angle_to_point(position) + PI/2) * delta
func is_touching():
	return forwards.is_colliding() or downwards.is_colliding() or upwards.is_colliding() or backwards.is_colliding()
func _physics_process(delta: float) -> void:
	if not (dead):
		grapple_icon.position=near_grapple(player.position).position
		if Input.is_action_just_pressed("Grapple"):
			if(swinging):
				stop_grapple()
			else:
				start_grapple(position)
		var center = truecenter.position
		var forwardcol=forwards.is_colliding()
		var backwardcol=backwards.is_colliding()
		var upwardcol=upwards.is_colliding()
		var downwardcol=downwards.is_colliding()
		if not swinging:
			if inair and (forwardcol or backwardcol or downwardcol or upwardcol):
				inair=false
			if side!=2 and upwardcol and not (forwardcol or backwardcol or downwardcol):
				changeside(2)
			elif side!=3 and forwardcol and not (upwardcol or backwardcol or downwardcol):
				changeside(3)
			elif side!=1 and backwardcol and not (upwardcol or forwardcol or downwardcol):
				changeside(1)
			elif side!=0 and downwardcol and not (upwardcol or forwardcol or backwardcol):
				changeside(0)
			elif not inair and not is_touching():
				if(side%2==0):
					if((backwardsdown if side==0 else backwardsup).is_colliding() or (forwardsdown if side==0 else forwardsup).is_colliding()):
						position.x=int(position.x/16) * 16 + (-8.1 if position.x<0 else 8.1)
						position.y+=(8.1 if side==0 else -8.1)
						changeside(1 if (backwardsdown if side==0 else backwardsup).is_colliding else 3)
						velocity*=0
					else:
						changeside(0)
						inair=true
				elif(side%2==1):
					if((backwardsdown if side==1 else forwardsdown).is_colliding() or (backwardsup if side==1 else forwardsup).is_colliding()):
						position.y=int(position.y/16) * 16 + (-8.1 if position.y<0 else 8.1)
						position.x+=(-8.1 if side==1 else 8.1)
						changeside(0 if (backwardsdown if side==1 else forwardsdown).is_colliding else 2)
						velocity*=0
					else:
						changeside(0)
						inair=true
			var direction: = Input.get_axis("Left", "Right")
			if is_touching() and not stopped:
				if direction:
					if(side%2==0):
						if(forwardcol and direction*(side-1)==-1):
							changeside(3)
						elif(backwardcol and direction*(side-1)==1):
							changeside(1)
						else:
							velocity.x=move_toward(velocity.x, SPEED*direction*(side-1)*-1,SPEED*delta*20)
					else:
						if(downwardcol and direction*(side-2)==-1):
							changeside(0)
						elif(upwardcol and direction*(side-2)==1):
							changeside(2)
						else:
							velocity.y=move_toward(velocity.y, SPEED*direction*(side-2)*-1,SPEED*delta*20)
					if(side!=3 and side!=2):
						animated_sprite_2d.flip_h = direction == -1
					else:
						animated_sprite_2d.flip_h = direction == 1
					play_anim("run")
				else:
					play_anim("idle")
					if(side%2==0):
						velocity.x = move_toward(velocity.x, 0,SPEED*delta*20)
					else:
						velocity.y = move_toward(velocity.y, 0,SPEED*delta*20)
			elif inair and direction and not stopped and (velocity.x>-SPEED if direction==-1 else velocity.x<SPEED):
				velocity.x=move_toward(velocity.x, SPEED*direction/2,SPEED*delta*5)
				animated_sprite_2d.flip_h = direction == -1
			if Input.is_action_just_pressed("Jump"):
				if(is_touching()):
					jump()
			if inair:
				velocity += get_gravity() * delta
				if ( not dead and not launched and not is_on_floor()):
					play_anim("jump")
			move_and_slide()
		else:
			if Input.is_action_just_pressed("Jump"):
				stop_grapple()
				velocity.y += JUMP_VELOCITY/2
				play_anim("roll")
				launched = true
				move_and_slide()
			elif is_on_floor() or is_on_ceiling() or is_on_wall():
				if(is_on_floor() or is_on_ceiling()):
					velocity.y=0
				elif(is_on_wall()):
					velocity.x=0
				stop_grapple()
				move_and_slide()
			else:
				var direction: = Input.get_axis("Left", "Right")
				velocity -= Vector2((pow(velocity.length() * delta, 2)) / position.distance_to(center), 0).rotated(center.angle_to_point(position)) / delta
				if direction and swingingmovement:
					velocity += Vector2(SPEED * delta * 0.5, 0).rotated(center.angle_to_point(position)-PI/2*direction)
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
				position=center+Vector2(length,0).rotated(center.angle_to_point(position))
				animated_sprite_2d.rotation = center.angle_to_point(position) - PI / 2
				animated_sprite_2d.flip_h = (velocity.x < 0) == (position.y > center.y)
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
func stop_grapple():
				swinging = false
				animated_sprite_2d.rotation = 0
				animated_sprite_2d.flip_h = (velocity.x < 0)
				line_2d.points = PackedVector2Array([])
func hurt(sources):
	if(not hurting):
		health-=1
		health_icons.get_child(health).visible=false
		if(health>0):
			if(sources.find("Water")!=-1):
				position=lastgroundpos
				velocity*=0
			play_anim("hurt")
			hurting=true
			hurttimer.start()
		else:
			die()
func _on_hurttimer_timeout() -> void:
	hurting=false
	play_anim("idle")
func die():
	dead = true
	if is_on_floor():
		play_anim("death1")
	else:
		play_anim("death2")
	swinging = false
	animated_sprite_2d.rotation = 0
	line_2d.points = PackedVector2Array([])
	Engine.time_scale=0.5
	death_timer.start()
	death.text="You Died"
func _on_death_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale=1
func triumph():
	print("Victory...has been obtained.")
func _on_position_timer_timeout() -> void:
	if(is_touching()):
		lastgroundpos=position
		lastside=side

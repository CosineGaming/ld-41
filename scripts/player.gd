extends KinematicBody2D

onready var anim = get_node("Sprite/AnimationPlayer")
onready var hud = get_node("HUD/Control")
var carrying = {}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	var direction = Vector2()
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if direction != Vector2():
		if not anim.is_playing():
			anim.play("speed_up")
		direction = direction.normalized()
		direction *= 5000
		rotation = direction.angle_to_point(Vector2())
		move_and_slide(direction * delta)
	else:
		if anim.is_playing() and anim.current_animation != "slow_down":
			anim.play("slow_down")

	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).collider
		if collider.is_in_group("machine"):
			move_and_slide(-direction * delta) # So when we leave we don't collide again
			collider.player_entered()
	
	hud.get_node("Carrying").text = util.render_resource_list(carrying)

func _anim_finished(anim_name):
	if anim_name == "speed_up":
		anim.play("running")


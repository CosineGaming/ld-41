extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var anim = get_node("Sprite/AnimationPlayer")

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

	if get_slide_count():
		var collider = get_slide_collision(0).collider
		if collider.is_in_group("machine"):
			print("enterred")
			collider.player_entered()

func _anim_finished(anim_name):
	if anim_name == "speed_up":
		anim.play("running")


extends KinematicBody2D

var nav = NodePath("/root/Level/Navigation2D")
var anim_path = NodePath("Caught/ColorRect/AnimationPlayer")

var target
var path
var turning = false
var turn_target

var running = false
var running_color = Color(0.86, 0.44, 0.43)
var  normal_color = Color(0.95, 0.93, 0.81)

onready var light_area = get_node("Node2D/LightArea")

func _ready():
	# set_physics_process(true)
	new_target()

func _process(delta):
	follow_path(delta)

func _physics_process(delta):
	# Because the raycasting we have to do can only be done in _physics_process
	running = false
	get_node("Node2D/Light2D").color = normal_color
	if sees_player():
		running = true
		get_node("Node2D/Light2D").color = running_color
		path = [util.player.position]
		turning = false
		rotation = path[0].angle_to_point(position)

func _entered_light(who):
	if who == util.player:
		catch_player()

# ---

func sees_player():
	if light_area.overlaps_body(util.player):
		var ignore = get_tree().get_nodes_in_group("guard")
		ignore.append(self)
		ignore.append(util.player)
		var space_state = get_world_2d().direct_space_state
		var blocked = space_state.intersect_ray(position, util.player.position, ignore)
		if not blocked:
			return true
	return false

func follow_path(delta):
	if not turning:
		var speed = 40 * delta
		if running:
			speed *= 2
		var d = (position - path[0]).length()
		if d < 2:
			# Reached target
			path.remove(0)
			# If we're here, get a new target
			# TODO: wait a bit?
			while path.size() < 1:
				new_target()
			begin_turn()
		else:
			position = position.linear_interpolate(path[0], speed / d)
	# Don't turn this to else! turning might have just been enabled!
	if turning:
		var turn_speed = 2.5 * delta
		var orig_sign = sign(turn_target - rotation)
		rotation += turn_speed * orig_sign
		# Keep going until we overgo, then reset to target
		if sign(turn_target - rotation) != orig_sign:
			turning = false
			rotation = turn_target
			print("done")

func begin_turn():
	# Turn slowly, so we don't just jack over
	turning = true
	turn_target = path[0].angle_to_point(position)

func regenerate_path():
	path = get_node(nav).get_simple_path(position, target)

func new_target():
	target = Vector2(randf() * OS.window_size.x, randf() * OS.window_size.y)
	# Tend towards the player, and away from other guards
	# TODO: Increase over time?
	var player_weight = 0.3 * 2
	target = target.linear_interpolate(util.player.position, player_weight * randf())
	var guard_weight = 200 # At g_w distance, move 1 pixel further / at 1 pixel distance, move g_w further
	for guard in get_node("/root/Level/Guards").get_children():
		# If the haven't set their target yet, we get to do whatever we want
		if guard.target:
			# The closer the guard, the more it affects the distance
			var strength = guard_weight * Vector2(1,1) / (guard.position - target)
			target += strength * randf()
	target = get_node(nav).get_closest_point(target)
	regenerate_path()
	if path.size() == 0:
		new_target()

func catch_player():
	util.player.carrying = {}
	# Teleport away so we don't get stuck on them
	new_target()
	position = target
	new_target()
	get_node(anim_path).play("fade_in_out")


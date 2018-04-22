extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var machine_id = ""
export var machine_name = ""
export var build_rate = 1.0 # Per second
onready var upgrade_cost = util.upgrade_costs[machine_id]
var count = 0
var level = 0

onready var management = get_node("Management/Control")

export var count_node = NodePath("Count")

func _ready():
	management.get_node("Upgrade").connect("pressed", self, "upgrade")
	management.get_node("Exit").connect("pressed", self, "exit")
	management.get_node("PickUp").connect("pressed", self, "pick_up")
	get_node("Name").text = machine_name
	on_level_change()

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	count += delta * level_function() * build_rate
	get_node(count_node).set_text(str(int(count)))
	management.get_node("PickUp").text = "Pick up " + str(int(count)) + " " + util.resource_names[machine_id]
	
	var upgradable = buy(util.player.carrying, multiplied_resources(upgrade_cost, level_function()), true)
	management.get_node("Upgrade").disabled = not upgradable

func on_level_change():
	# Render things that change with level
	var rendered_cost = util.render_resource_list(multiplied_resources(upgrade_cost, level_function()))
	management.get_node("UpgradeCost").text = rendered_cost

func upgrade():
	if buy(util.player.carrying, multiplied_resources(upgrade_cost, level_function())):
		level += 1
		on_level_change()

func buy(from, cost, just_check=false):
	if just_check or buy(from, cost, true):
		var can = true
		for key in cost:
			if from.has(key) and from[key] >= cost[key]:
				if not just_check:
					from[key] -= cost[key]
			else:
				can = false
		return can
	return false

func multiplied_resources(resources, factor):
	var rv = {}
	for key in resources:
		rv[key] = resources[key] * factor
	return rv

func player_entered():
	management.show()

func exit():
	management.hide()

func pick_up():
	var pocket = util.player.carrying
	if pocket.has(machine_id):
		pocket[machine_id] += count
	else:
		pocket[machine_id] = count
	count = 0

func level_function():
	# Start with linear and see how it goes
	# Add one so multiplications work ok
	return (level + 1)


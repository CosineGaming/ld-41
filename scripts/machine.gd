extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var machine_name = ""
export var resource_name = ""
export var build_rate = 1 # Per second
var count = 0

onready var management = get_node("Management/Control")

export var count_node = NodePath("Count")

func _ready():
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	count += delta * build_rate
	get_node(count_node).set_text(str(int(count)))
	management.get_node("PickUp").text = "Pick up " + str(int(count)) + " " + resource_name + "s"

func player_entered():
	management.show()


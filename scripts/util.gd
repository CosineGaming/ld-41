extends Node

onready var player = get_node("/root/Level/Player")

var resource_names = {
	"0": "Soy",
	"1": "Yams",
	"2": "Vegetable Essence",
	"3": "Gay Soup",
}

var upgrade_costs = {
	"0": {
		"2": 5,
	},
	"1": {
		"2": 5,
	},
	"2": {
		"3": 20,
	},
	"3": {
		"0": 20,
		"1": 20,
	},
}

func render_resource_list(list):
	var rv = ""
	for key in list:
		var name = util.resource_names[key]
		var count = str(int(list[key]))
		var s = name + ": " + count
		rv += s + "\n"
	return rv

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

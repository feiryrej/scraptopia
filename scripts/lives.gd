extends CanvasLayer

var hearts_list: Array[AnimatedSprite2D]
@onready var player_icon = $player_icon

func _ready():
	var hearts_parent = $HBoxContainer/Node2D2/HBoxContainer

	for child in hearts_parent.get_children():
		hearts_list.append(child)

func update_lives():
	for i in range(hearts_list.size()):
		if i < Global.lives:
			hearts_list[i].play("full")
		else:
			hearts_list[i].play("dead")

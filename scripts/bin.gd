extends Node2D

@export var bin_type: int = 0
var bin_type_names = {
	0: "NONBIO",
	1: "BIO",
	2: "RECYCLABLE",
	3: "HAZARD"
}

@onready var animation_player: AnimationPlayer = $bins_spr/AnimationPlayer

func _ready() -> void:
	set_bin_sprite()
	self.set_meta("bin_type", bin_type)

func set_bin_sprite():
	match bin_type:
		0: $bins_spr.frame = 0
		1: $bins_spr.frame = 1
		2: $bins_spr.frame = 2
		3: $bins_spr.frame = 3

func play_boink_animation():
	animation_player.play("boink")

func _on_dropping_range_body_entered(body: Node2D):
	if body.has_method("dispose_item"):
		Global.is_near_bin = true 
		Global.near_bin_type = bin_type_names.get(bin_type)
		Global.near_bin_node = self

func _on_dropping_range_body_exited(body: Node2D):
	if body.has_method("dispose_item"):
		Global.is_near_bin = false 
		Global.near_bin_type = null
		Global.near_bin_node = null

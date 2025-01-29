extends Node2D

@export var bin_scene: PackedScene

func _ready():
	spawn_bins()


func spawn_bins():
	var positions = [
		Vector2(882, 568),  # position of NONBIO bin
		Vector2(924, 548),  # position of BIO bin
		Vector2(969, 532),   # position of RECYCLABLE bin
		Vector2(1011, 513)   # position of HAZARD bin
	]
	
	var bin_types = [
		0,  # NONBIO
		1,  # BIO
		2,  # RECYCLABLE
		3   # HAZARD
	]
	
	for i in range(positions.size()):
		var bin = bin_scene.instantiate()
		bin.global_position = positions[i]
		bin.bin_type = bin_types[i]
		self.add_child(bin)
		bin.set_meta("bin_type", bin_types[i])

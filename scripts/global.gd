extends Node

const all_waste = 43

signal total_waste_updated(new_value)

# ensure that the number of lives and heart nodes in lives.tscn is the same
var lives = 5

var is_near_bin : bool = false
var near_bin_type = null
var near_bin_node: Node2D = null

var camera : Camera2D

var total_waste: int = 43:
	set(value):
		total_waste = value
		emit_signal("total_waste_updated", total_waste)

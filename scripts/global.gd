extends Node

# ensure that the number of lives and heart nodes in lives.tscn is the same
var lives = 5

var is_near_bin : bool = false
var near_bin_type = null
var near_bin_node: Node2D = null

var camera : Camera2D

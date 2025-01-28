extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Go to introduction on play
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/virethariel.tscn")


# Then exit the game on exit
func _on_exit_pressed() -> void:
	get_tree().quit()

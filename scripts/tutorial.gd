extends Node2D

var can_interact = false

func set_can_interact(value: bool):
	can_interact = value

func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("dispose_item"):
		set_can_interact(true)
		
func _input(event):
	if event.is_action_pressed("pickupthrow") and can_interact:
		%Tutorial.hide()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("dispose_item"):
		set_can_interact(false)

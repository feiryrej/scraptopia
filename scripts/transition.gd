extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/AnimationPlayer.play("Fade In")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func transition_in():
	$MarginContainer/AnimationPlayer.play("Fade In")
	
func transition_out():
	$MarginContainer/AnimationPlayer.play("Fade Out")

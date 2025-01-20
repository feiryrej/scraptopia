extends Control

func _ready():
	visible = false
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	visible = false
	print("IT DEBLURS")
	$AnimationPlayer.play("RESET")

func pause():
	get_tree().paused = true
	visible = true
	$AnimationPlayer.stop() 
	$AnimationPlayer.play("blur")

func _input(event):
	if event.is_action_pressed("escape"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_pressed():
	resume()
	
func _on_restart_pressed():
	get_tree().paused = false
	visible = false
	$AnimationPlayer.stop()
	$AnimationPlayer.play("transition")
	$AnimationPlayer.play("RESET")
	await get_tree().process_frame
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

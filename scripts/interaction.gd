extends Area2D

var can_interact = false
@onready var label: Label = $Label
@onready var start_dialogue: AudioStreamPlayer2D = $StartDialogue

func set_can_interact(value: bool):
	can_interact = value
	label.visible = value

func _on_body_entered(body: Node):
	if body.name == "player":
		set_can_interact(true)

func _on_body_exited(body: Node):
	# Ensure the player is leaving
	if body.name == "player":
		set_can_interact(false)
		DialogueManager.hide_dialogue()

func interaction():
	owner.interact() 
	print(owner.name + " interacted.")
	start_dialogue.play()
	
func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		interaction()

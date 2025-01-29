extends Button

@onready var next_dialogue: AudioStreamPlayer2D = $NextDialogue

var dialogue : Dialogue:
	set(value):
		dialogue = value
		text = dialogue.path_options

func _on_pressed() -> void:
	next_dialogue.play()
	
	if dialogue.options.size() == 0:
		DialogueManager.hide_dialogue()
		return
	
	DialogueManager.dialogue = dialogue

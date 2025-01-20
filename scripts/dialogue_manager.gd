extends Node2D

@export var next_button : PackedScene

var dialogue : Dialogue:
	set(value):
		if value == null:
			print("Error: Dialogue object is null!")
			return

		dialogue = value
		
		if value.texture != null:
			%Icon.texture = value.texture
		else:
			print("Warning: Dialogue texture is null")

		%Name.text = value.name
		%Dialogue.text = value.dialogue
		
		reset_options()
		add_buttons(value.options)
		
		await get_tree().create_timer(0.5).timeout
		%Options.show()

func reset_options():
	# Remove all existing buttons from the options container
	for child in %Options.get_children():
		child.queue_free()
	%Options.hide()

func add_buttons(options):
	# Add buttons for each option in the dialogue options
	for option in options:
		var button = next_button.instantiate()
		button.dialogue = option
		%Options.add_child(button)

func hide_dialogue():
	%UI.hide()

func show_dialogue():
	%UI.show()
	
#	signal dialogue_closed

# func close_dialogue():
#	hide_dialogue()  # Hide dialogue UI
#	emit_signal("dialogue_closed")  # Emit signal when dialogue is closed

func _ready():
	# Debugging: Check if dialogue is assigned correctly
	if dialogue == null:
		print("Warning: Dialogue is not assigned to this node!")
	else:
		print("Dialogue assigned correctly.")

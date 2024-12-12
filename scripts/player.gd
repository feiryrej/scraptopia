extends CharacterBody2D

# Movement settings
var speed = 100
var movement_velocity = Vector2.ZERO  # Stores current velocity
var character_direction = Vector2.DOWN # Tracks the last movement direction

var carrying_item = false

enum Gender { MALE, FEMALE}
var curr_gender = Gender.MALE

var male_arms_down_frames = preload("res://male_arms_down.tres")
var male_arms_up_frames = preload("res://male_arms_up.tres")
var female_arms_down_frames = preload("res://female_arms_down.tres")
var female_arms_up_frames = preload("res://female_arms_down.tres")

func _ready():
	_update_spritesheet()

# Enum to define states
enum States { IDLE, MOVE }
var current_state = States.IDLE

func _physics_process(delta):
	handle_state_transitions()
	perform_state_actions(delta)
	velocity = movement_velocity  # Assign movement_velocity to the built-in velocity
	move_and_slide()  # Move using the built-in velocity

func handle_state_transitions():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		current_state = States.MOVE
	else:
		current_state = States.IDLE

func perform_state_actions(delta):
	match current_state:
		States.MOVE:
			var horizontal_input = Input.get_axis("left", "right")
			var vertical_input = Input.get_axis("up", "down")

			# Prioritize horizontal movement over vertical
			if horizontal_input != 0:
				character_direction = Vector2(horizontal_input, 0)
			elif vertical_input != 0:
				character_direction = Vector2(0, vertical_input)
			else:
				character_direction = Vector2.ZERO

			# Play walking animation based on direction
			if character_direction.x < 0:
				$body.play("w-walk")
			elif character_direction.x > 0:
				$body.play("e-walk")
			elif character_direction.y > 0:
				$body.play("s-walk")
			elif character_direction.y < 0:
				$body.play("n-walk")

			# Calculate movement velocity
			movement_velocity = character_direction * speed

		States.IDLE:
			# Stop the character immediately
			movement_velocity = Vector2.ZERO

			# Play idle animation based on last direction
			if character_direction.y > 0:
				$body.play("s-idle")
			elif character_direction.y < 0:
				$body.play("n-idle")
			elif character_direction.x > 0:
				$body.play("e-idle")
			elif character_direction.x < 0:
				$body.play("w-idle")

func _update_spritesheet():
	
	if curr_gender == Gender.MALE:
		if carrying_item == true:
			$body.frames = male_arms_up_frames
		else:
			$body.frames = male_arms_down_frames
	if curr_gender == Gender.FEMALE:
		if carrying_item == true:
			$body.frames = female_arms_up_frames
		else:
			$body.frames = female_arms_down_frames


func _on_switch_gender_pressed():
	if curr_gender == Gender.MALE:
		curr_gender = Gender.FEMALE
		print(curr_gender)
	else:
		curr_gender = Gender.MALE
		print(curr_gender)
	_update_spritesheet()


func _on_switch_stance_pressed():
	carrying_item = !carrying_item
	print("Carrying item: ", carrying_item)
	_update_spritesheet()

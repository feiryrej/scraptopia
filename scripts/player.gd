extends CharacterBody2D

# References
@onready var item_drop = load("res://scenes/item_drop.tscn")
@onready var human_spr = $human_spr
@onready var item_spr = $item_spr

# Variables
var speed = 100
var movement_velocity = Vector2.ZERO  # Stores current velocity
var dir = Vector2.DOWN # Tracks the last movement direction

var carrying_item = false
var drop_pos: Vector2
var items_in_range: Array = []

var male_arms_down_frames = preload("res://frames/male_arms_down.tres")
var male_arms_up_frames = preload("res://frames/male_arms_up.tres")
var female_arms_down_frames = preload("res://frames/female_arms_down.tres")
var female_arms_up_frames = preload("res://frames/female_arms_up.tres")

enum Gender { MALE, FEMALE}
var curr_gender = Gender.MALE

enum States { IDLE, MOVE }
var current_state = States.IDLE


func _ready():
	item_spr.hide()
	update_spritesheet()

	
func _physics_process(delta):
	handle_state_transitions()
	perform_state_actions()
	velocity = movement_velocity
	move_and_slide()


func handle_state_transitions():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		current_state = States.MOVE
	else:
		current_state = States.IDLE


func perform_state_actions():
	match current_state:
		States.MOVE:
			var horizontal_input = Input.get_axis("left", "right")
			var vertical_input = Input.get_axis("up", "down")

			# Prioritize horizontal movement over vertical
			if horizontal_input != 0:
				dir = Vector2(horizontal_input, 0)
			elif vertical_input != 0:
				dir = Vector2(0, vertical_input)
			else:
				dir = Vector2.ZERO

			# Play walking animation based on direction
			if dir.x < 0:
				$human_spr.play("w-walk")
				item_spr.flip_h = true
				item_spr.position.x = -3
				drop_pos = Vector2(-12, 13)
			elif dir.x > 0:
				$human_spr.play("e-walk")
				item_spr.flip_h = false
				item_spr.position.x = 3
				drop_pos = Vector2(12, 13)
			elif dir.y > 0:
				$human_spr.play("s-walk")
			elif dir.y < 0:
				$human_spr.play("n-walk")

			# Calculate movement velocity
			movement_velocity = dir * speed
		States.IDLE:
			# Stop the character immediately
			movement_velocity = Vector2.ZERO

			# Play idle animation based on last direction
			if dir.y > 0:
				$human_spr.play("s-idle")
			elif dir.y < 0:
				$human_spr.play("n-idle")
			elif dir.x > 0:
				$human_spr.play("e-idle")
			elif dir.x < 0:
				$human_spr.play("w-idle")


func update_spritesheet():
	if curr_gender == Gender.MALE:
		if carrying_item == true:
			human_spr.frames = male_arms_up_frames
		else:
			human_spr.frames = male_arms_down_frames
	if curr_gender == Gender.FEMALE:
		if carrying_item == true:
			human_spr.frames = female_arms_up_frames
		else:
			human_spr.frames = female_arms_down_frames


func _on_switch_gender_pressed():
	if curr_gender == Gender.MALE:
		curr_gender = Gender.FEMALE
		print(curr_gender)
	else:
		curr_gender = Gender.MALE
		print(curr_gender)
	update_spritesheet()


func _input(event):
	if event.is_action_pressed("pickupthrow"):
		if carrying_item:
			drop_item()
		else:
			if !items_in_range.is_empty():
				for item in items_in_range:
					if is_facing_item(item):
						pickup_item(item)
						break


func is_facing_item(item: Area2D) -> bool:
	# Calculate the direction vector from the player to the item
	var item_dir = (item.global_position - global_position).normalized()
	
	# Check if the item is in the direction the player is facing
	# Use a threshold to account for slight angle differences
	if dir == Vector2.RIGHT and item_dir.dot(Vector2.RIGHT) > 0.7:
		return true
	elif dir == Vector2.LEFT and item_dir.dot(Vector2.LEFT) > 0.7:
		return true
	elif dir == Vector2.UP and item_dir.dot(Vector2.UP) > 0.7:
		return true
	elif dir == Vector2.DOWN and item_dir.dot(Vector2.DOWN) > 0.7:
		return true
	
	return false


func pickup_item(item: Area2D):
	item.queue_free()
	carrying_item = true
	print("Carrying item: ", carrying_item)
	update_spritesheet()	
	
	item_spr.show()


func drop_item():
	item_spr.hide()
	var item = item_drop.instantiate()
	
	# Calculate the drop position in front of the character based on direction
	var drop_offset = dir * 20 # Multiply direction by a distance factor (e.g., 12)
	
	drop_offset.y += 4
	
	# Set the drop position relative to the character's position
	item.position = position + drop_offset

	get_parent().add_child(item)
	carrying_item = false
	print("Carrying item: ", carrying_item)
	update_spritesheet()	


func _on_pickup_range_area_entered(area: Area2D):
	if area.is_in_group("item_drop"):
		items_in_range.append(area)
		print(items_in_range)


func _on_pickup_range_area_exited(area: Area2D):
	if area.is_in_group("item_drop"):
		items_in_range.erase(area)
		print(items_in_range)

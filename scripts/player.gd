extends CharacterBody2D

# References
@onready var item_drop = load("res://scenes/item_drop.tscn")
@onready var human_spr = $human_spr
@onready var item_spr = $item_spr

# Variables
var speed = 100
var movement_velocity = Vector2.ZERO  # Stores current velocity
var dir = Vector2.DOWN # Tracks the last movement direction
var tile_size = 16 # Change depending on our game's tile size
var movement_speed = 120 # Lower = slower, higher = faster
var is_moving = false
var movement_queue = Vector2.ZERO

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
	perform_state_actions(delta)
	velocity = movement_velocity
	move_and_slide()


func handle_state_transitions():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		current_state = States.MOVE
	else:
		current_state = States.IDLE


func perform_state_actions(delta):
	# If already moving, continue toward the target position
	if is_moving:
		global_position = global_position.move_toward(movement_queue, movement_speed * delta)
		
		# Check if the player has reached the target tile
		if global_position == movement_queue:
			is_moving = false
			global_position = movement_queue  # Snap to tile center
	else:
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
				
				if dir != Vector2.ZERO:
					# Calculate the next target position based on the tile grid
					movement_queue = (global_position / tile_size).floor() * tile_size + dir * tile_size
					is_moving = true

				# Play walking animation
				if dir.x < 0:
					human_spr.play("w-walk")
					item_spr.flip_h = true
					item_spr.position.x = 8
				elif dir.x > 0:
					human_spr.play("e-walk")
					item_spr.flip_h = false
					item_spr.position.x = 8
				elif dir.y > 0:
					human_spr.play("s-walk")
				elif dir.y < 0:
					human_spr.play("n-walk")
			States.IDLE:
				# Snap character to nearest tile
				global_position = (global_position / tile_size).round() * tile_size

				# Play idle animation based on last direction
				if dir.y > 0:
					human_spr.play("s-idle")
				elif dir.y < 0:
					human_spr.play("n-idle")
				elif dir.x > 0:
					human_spr.play("e-idle")
				elif dir.x < 0:
					human_spr.play("w-idle")


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
	if dir == Vector2.RIGHT and item_dir.dot(Vector2.RIGHT) > 0.6:
		return true
	elif dir == Vector2.LEFT and item_dir.dot(Vector2.LEFT) > 0.6:
		return true
	elif dir == Vector2.UP and item_dir.dot(Vector2.UP) > 0.6:
		return true
	elif dir == Vector2.DOWN and item_dir.dot(Vector2.DOWN) > 0.6:
		return true
	
	return false


func adjust_item_z_index(item_sprite: Sprite2D, is_picking_up: bool):
	if item_sprite:
		# Set z-index for the item
		item_sprite.z_index = -2
		
		# Adjust character z-index accordingly
		human_spr.z_index = 0 if is_picking_up else 1
	else:
		print("Item sprite not found")


func pickup_item(item: Area2D):
	item.queue_free()
	carrying_item = true
	print("Carrying item: ", carrying_item)
	update_spritesheet()	
	
	item_spr.show()
	var item_sprite = item.get_node("Sprite2D")
	adjust_item_z_index(item_sprite, true)


func drop_item():
	item_spr.hide()
	var item = item_drop.instantiate()
	
	# Calculate the next tile position based on the direction the character is facing
	var drop_tile_position = (global_position / tile_size).floor() + dir
	
	# Convert the tile position back to world coordinates
	item.position = drop_tile_position * tile_size + Vector2(tile_size / 2, tile_size / 2)
	
	# Ensure the item is added to the parent before adjusting z_index
	get_parent().add_child(item)

	var item_sprite = item.get_node("Sprite2D")
	adjust_item_z_index(item_sprite, false)
	
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

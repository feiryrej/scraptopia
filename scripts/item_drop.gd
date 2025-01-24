extends Area2D

@export var coords: Vector2i = Vector2i.ZERO
@export var frame_coords: Vector2i = Vector2i.ZERO
@export var scale_factor: Vector2 = Vector2(1, 1)

enum WasteType { BIO, NONBIO, HAZARD, RECYCLABLE }
@export var waste_type: WasteType = WasteType.BIO # default type

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.frame_coords = frame_coords
	sprite.scale = scale_factor
	position = position

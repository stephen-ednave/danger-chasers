tool
extends KinematicBody2D
class_name KinematicBody2DMirror

var look_direction : Vector2 = Vector2.RIGHT # Unit vector
onready var pivot := $Pivot
onready var collider := $CollisionBox

func set_rotation(value : float) -> void:
	rotation = value
	_correct_rotation()


func set_rotation_degrees(value : float) -> void:
	rotation_degrees = value
	_correct_rotation()

func update_look_direction(_look_direction : Vector2) -> void:
	if _look_direction.x > 0:
		var x = 1  
		set_rotation(Vector2(x, 0).angle())
	elif _look_direction.x < 0:
		var x = -1
		set_rotation(Vector2(x, 0).angle())


func _correct_rotation():
	if cos(rotation) >= 0.0: # Check if facing right
		look_direction = Vector2.RIGHT
		scale = scale.abs()
	else:
		look_direction = Vector2.LEFT
		scale = Vector2(abs(scale.x), -abs(scale.y))

extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 150.0

#func _input(event):
	#if Input.is_action_just_pressed("ui_left"):
			#animated_sprite_2d.flip_h = true
	#if Input.is_action_just_pressed("ui_right"):
			#animated_sprite_2d.flip_h = false

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	velocity = input_vector * SPEED
	controlSprite(velocity)
	move_and_slide()

func controlSprite(velocity: Vector2)-> void:
	
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("moving_side")
		else:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("moving_side")
	else:
		if velocity.y > 0:
			animated_sprite_2d.play("walk_down")
		else:
			animated_sprite_2d.play("walk_up")
	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")

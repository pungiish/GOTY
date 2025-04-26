extends CharacterBody2D

# Directional and transitional states
enum State {
	IDLE_UP,    IDLE_RIGHT,  IDLE_DOWN,   IDLE_LEFT,
	WALK_UP,    WALK_RIGHT,  WALK_DOWN,   WALK_LEFT,
	TRANSITION
}

const SPEED = 200

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var state: State = State.IDLE_DOWN
var last_state: State = State.IDLE_DOWN
var queued_state = null
@export var spell_offset: Vector2 = Vector2(20, -10)  # shift spawn point above feet
@export var spell_cooldown: float = 0.5
var can_cast: bool = true
var direction = Vector2.RIGHT
@export var mana = 1000;
# Map of turn animations for each from→to pair
var transition_map := {
	State.WALK_UP: {
		State.WALK_RIGHT: "turn_up_to_right",
		State.WALK_LEFT:  "turn_up_to_left",
		State.WALK_DOWN:  "turn_up_to_down",
	},
	State.WALK_RIGHT: {
		State.WALK_DOWN:  "turn_right_to_down",
		State.WALK_LEFT:  "turn_right_to_left",
		State.WALK_UP:    "turn_right_to_up",
	},
	State.WALK_DOWN: {
		State.WALK_LEFT:  "turn_down_to_left",
		State.WALK_RIGHT: "turn_down_to_right",
		State.WALK_UP:    "turn_down_to_up",
	},
	State.WALK_LEFT: {
		State.WALK_UP:    "turn_left_to_up",
		State.WALK_DOWN:  "turn_left_to_down",
		State.WALK_RIGHT: "turn_left_to_right",
	},
	# You can add IDLE → WALK or WALK → IDLE transitions here if needed
}

func _ready() -> void:
	# Connect the animation_finished signal to handle end of transitions
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(_delta: float) -> void:
	var input_vec := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up",   "ui_down")
	)

	# Flip sprite for left/right
	if input_vec.x > 0:
		
		sprite.flip_h = false
	elif input_vec.x < 0:
		sprite.flip_h = true

	var target_state := _get_state_from_input(input_vec)
	if target_state != state:
		_change_state(target_state)
	# Move character
	velocity = input_vec.normalized() * SPEED
	move_and_slide()
	handle_cast()

func _get_state_from_input(input_vec: Vector2) -> State:
	if input_vec == Vector2.ZERO:
		return _get_idle_state_from(last_state)

	# Choose walk direction based on dominant axis
	if abs(input_vec.x) > abs(input_vec.y):
		if input_vec.x > 0:
			direction = Vector2.RIGHT
			return State.WALK_RIGHT
		else:
			direction = Vector2.LEFT
			return State.WALK_LEFT
	else:
		if input_vec.y > 0:
			direction = Vector2.DOWN
			return State.WALK_DOWN
		else:
			direction = Vector2.UP
			return State.WALK_UP

func _get_idle_state_from(from_state: State) -> State:
	match from_state:
		State.WALK_UP,    State.IDLE_UP:    return State.IDLE_UP
		State.WALK_RIGHT, State.IDLE_RIGHT: return State.IDLE_RIGHT
		State.WALK_DOWN,  State.IDLE_DOWN:  return State.IDLE_DOWN
		State.WALK_LEFT,  State.IDLE_LEFT:  return State.IDLE_LEFT
		_:                               return State.IDLE_DOWN

func _change_state(new_state: State) -> void:
	if state == State.TRANSITION:
		return  # already in a turn animation

	var from_state := state
	# Check if there's a defined transition clip
	if transition_map.has(from_state) and transition_map[from_state].has(new_state):
		if transition_map[from_state][new_state] != "" and sprite.sprite_frames.has_animation(transition_map[from_state][new_state]):
			queued_state = new_state
			state = State.TRANSITION
			sprite.play(transition_map[from_state][new_state])
		else:
			# either no mapping or no such animation → go straight there
			_apply_state(new_state)
	else:
			# No transition: apply new state immediately
		_apply_state(new_state)

func _apply_state(new_state: State) -> void:
	state = new_state

	# Remember last facing direction when walking
	if state in [State.WALK_UP, State.WALK_RIGHT, State.WALK_DOWN, State.WALK_LEFT]:
		last_state = state

	var anim_name := ""
	match state:
		State.WALK_UP:    anim_name = "walk_up"
		State.WALK_RIGHT: anim_name = "walk_side"
		State.WALK_DOWN:  anim_name = "walk_down"
		State.WALK_LEFT:  anim_name = "walk_side"
		State.IDLE_UP:    anim_name = "idle_side"
		State.IDLE_RIGHT: anim_name = "idle_side"
		State.IDLE_DOWN:  anim_name = "idle_side"
		State.IDLE_LEFT:  anim_name = "idle_side"
		_:               anim_name = ""

	if anim_name != "":
		sprite.play(anim_name)

func _on_animation_finished(anim_name: String) -> void:
	# When a turn animation finishes, play the queued state
	if state == State.TRANSITION and queued_state != null:
		_apply_state(queued_state)
		queued_state = null


func handle_cast():
	if Input.is_action_just_pressed("cast_1") and can_cast:
		cast_spell("projectile")
		can_cast = false
	if Input.is_action_just_pressed("cast_2") and can_cast:
		cast_spell("aoe")
		can_cast = false
func _on_CastCooldown_timeout():
	can_cast = true

func cast_spell(spellName: String):
	# 1) determine direction: aim at mouse or toward facing
	#var viewport = get_viewport()
	#var mouse_pos = viewport.get_mouse_position()
	#var world_mouse = get_global_mouse_position()
	#var dir = (world_mouse - global_position).normalized()
	# 2) spawn the spell
	# if using SpellManager:
	match direction:
		Vector2.RIGHT: spell_offset = Vector2(20, -10)
		Vector2.LEFT: spell_offset = Vector2(-20, -10)
	var aim_dir = velocity.normalized() if velocity.length() > 0 else direction
	var mana_cost = SpellManagerSingleton.cast(spellName, global_position + spell_offset, aim_dir, mana)
	if mana_cost:
		get_tree().create_timer(spell_cooldown).connect("timeout", Callable(self, "_on_CastCooldown_timeout"))	
		mana -= mana_cost


	# 3) play cast animation
	#$AnimatedSprite2D.play("cast_")

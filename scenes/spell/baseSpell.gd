extends Area2D
class_name BaseSpell
@export var speed: float = 200
@export var lifetime: float = 0
@export var damage:    int     = 10
@export var max_distance:      float = 800.0  # MAX DISTANCE before auto‐free
@export var initial_position: Vector2
var direction: Vector2 = Vector2.ZERO
@onready var timer: Timer = $Timer
@export var travel_time: float = 0.5

func _ready():
	initial_position = position
	#var start = initial_position
	#var character = get_parent().get_node("character")
	#var end   = Vector2(global_position.x, character.global_position.y)
	#var tween = create_tween()
	#tween.tween_property(self, "global_position", end, travel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	#tween.connect("finished", Callable(self, "_on_tween_finished"))
	# (Optional) also queue_free() in animation_finished if you prefer
	if (lifetime > 0):
		timer.start(lifetime)
	# auto-free after lifetime seconds

func _physics_process(delta):
	var distance = position - initial_position;
	if (sqrt(pow(distance.y,2) + pow(distance.x, 2)) < max_distance):
		position += direction * speed * delta
	else:
		queue_free()
	

func _on_Timer_timeout():
	queue_free()

func _on_Spell_body_entered(body):
	if body.is_in_group("enemies"):
		#body.take_damage(damage)
		queue_free()

func add_burn(magnitude: float, duration: float) -> void:
	pass
	# Example: apply burn-over-time
	#var burn_timer = Timer.new()
	#burn_timer.wait_time = 1.0  # tick every second
	#burn_timer.one_shot = false
	##burn_timer.repeat = true
	#burn_timer.connect("timeout", Callable(self, "_on_burn_tick"), magnitude)
	#add_child(burn_timer)
	#burn_timer.start()
	# kill the timer after `duration`
	#var finisher = Timer.new()
	#finisher.wait_time = duration
	#finisher.one_shot = true
	#finisher.connect("timeout", Callable(self, "_on_burn_end"), burn_timer)
	#add_child(finisher)
	#finisher.start()

func _on_burn_tick(magnitude):
	# deal burn damage each tick
	if is_instance_valid(self) and get_parent().has_method("take_damage"):
		get_parent().call("take_damage", magnitude)

func _on_burn_end(burn_timer: Timer):
	if is_instance_valid(burn_timer):
		burn_timer.queue_free()

func add_slow(magnitude: float, duration: float) -> void:
	pass
	# Example: reduce speed temporarily
	#var original_speed = speed
	#speed *= (1.0 - magnitude)  # magnitude = 0.2 → 20% slower
	## restore after duration
	#await get_tree().create_timer(duration).timeout
	#if is_instance_valid(self):
		#speed = original_speed
		
func _on_tween_finished():
	queue_free()

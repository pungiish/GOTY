extends Area2D

@export var speed: float = 100
@export var lifetime: float = 10
@export var damage:    int     = 10
var direction: Vector2 = Vector2.ZERO
@onready var timer: Timer = $Timer

func _ready():
	# auto-free after lifetime seconds
	timer.start(lifetime)

func _physics_process(delta):
	position += direction * speed * delta

func _on_Timer_timeout():
	queue_free()

func _on_Spell_body_entered(body):
	#if body.is_in_group("enemies"):
	body.take_damage(damage)
	queue_free()
# ——— Effect hooks ———

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
	# Example: reduce speed temporarily
	var original_speed = speed
	speed *= (1.0 - magnitude)  # magnitude = 0.2 → 20% slower
	# restore after duration
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):
		speed = original_speed

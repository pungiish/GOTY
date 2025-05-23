# SpellManager.gd
extends Node
class_name SpellManager

# Holds your base spell definitions
@export var spells: Dictionary[String, SpellResource] = {}
const PARTICLE_CIRCLE = preload("res://assets/particle_circle.png")
const AOEFIRE = preload("res://data/spellSprites/AOE/Fire/fire.tres")
const PROJECTILEFIRE = preload("res://data/spellSprites/Projectile/Fire/fire.tres")

const ELEMENT_DATA := {
	SpellResource.Element.FIRE: {
		"color": Color(0.698, 0.133, 0.133), # FIREBRICK
	},
	SpellResource.Element.WATER: {
		"color": Color.AQUAMARINE
	},
	SpellResource.Element.AIR: {
		"color": Color.WHITE
	},
}
func _ready():
	_load_all_spells()

func _load_all_spells():
	# e.g. load every .tres in res://data/spells/
	var dir = DirAccess.open("res://data/spells")
	for file in dir.get_files():
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://data/spells/%s" % file)
			spells[res.name] = res

#func cast(spell_name: String, origin: Vector2, dir: Vector2, mana) -> int:
	#if not spells.has(spell_name):
		#push_error("Unknown spell: %s" % spell_name)
		#return 0
	#var data = spells[spell_name]
	#if data.mana_cost > mana:
		#return 0;
	#if data.is_aoe:
		#var half_w = data.aoe_radius * 0.5
		#for i in range(data.count):
			## 1) Instantiate the base‐spell scene, not the resource itself!
			#var shard = data.scene.instantiate()
#
			## 2) Position it somewhere above (and optionally to the side) of the player
			#var x = origin.x + dir.x + 200
			#var y = origin.y - data.aoe_spawn_height
			#shard.position = Vector2(x, y)
#
			## 3) Give it a straight‐down direction and the usual stats
			##shard.direction = Vector2.DOWN
			#shard.speed = data.projectile_speed
			#shard.damage = data.damage
			#shard.lifetime = data.lifetime
			## 4) Apply any effects exactly as you do in the single‐spell case
			#for eff in data.effects:
				#if eff == null:
					#continue
				#var eff_copy = eff.duplicate(true) as SpellEffect
				#eff_copy.apply_to(shard)
#
			## 5) Attach & tint its particle VFX (same as single‐spell)
			#if data.particle_scene:
				#var vfx = data.particle_scene.instantiate()
				#var parts = vfx
				## rotate (not strictly needed for straight‐down, but safe)
				#parts.rotation_degrees = rad_to_deg(Vector2.DOWN.angle())
				## unique‐ify + tint
				#if parts.material:
					#var mat = (parts.material as ShaderMaterial).duplicate()
					#parts.material = mat
					#mat.set_shader_parameter("tint_color", data.tint_color)
				#parts.emitting = true
				#shard.get_node("VFX").add_child(vfx)
				#vfx.position = Vector2.ZERO
			## 6) Finally, add the shard to the scene
			#get_tree().current_scene.add_child(shard)
		#return data.mana_cost
	#var spell = data.scene.instantiate()
	#var sprite = spell.get_node("Sprite2D") as Sprite2D
	#sprite.texture = PARTICLE_CIRCLE
	#spell.position = origin
	#spell.direction = dir.normalized()
	## 2) Apply base stats *and* skill‐tree modifiers
	##var speed_mod = SkillTree.get_modifier("spell_speed")    # e.g. 1.2 for +20%
	##var dmg_mod   = SkillTree.get_modifier("spell_damage")  # e.g. 1.5 for +50%
	#var speed_mod = 1
	#var dmg_mod = 1
	#var distance_mod = 1
	#spell.max_distance = data.max_distance * distance_mod
	#spell.speed  = data.projectile_speed * speed_mod
	#spell.damage = data.damage * dmg_mod
#
	## 3) Apply every effect, possibly tweaked by skills too
	#for eff in data.effects:
		## you could also ask SkillTree to modify each effect’s magnitude/duration
		##var mag = eff.magnitude * SkillTree.get_modifier(eff.type)
		##var dur = eff.duration  * SkillTree.get_modifier(eff.type + "_duration")
		#if eff == null:
			#continue    # skip empty slots!
#
	## use true if you want a deep copy of sub-resources
		#var eff_copy: SpellEffect = eff.duplicate(true) as SpellEffect
#
	## apply any magnitude/duration modifiers…
		#eff_copy.magnitude = eff_copy.magnitude * 1
		#eff_copy.duration  = eff_copy.duration  * 1
#
	## now inject it into your spell
		#eff_copy.apply_to(spell)
#
		#if data.particle_scene:
			#var vfx = data.particle_scene.instantiate() as Node2D
			#var parts = vfx
			## 2a) rotate to aim
			#set_spell_rotation(parts, dir)
			## 2b) unique‐ify & tint
			#var shared_mat = parts.material as ShaderMaterial
			#if shared_mat:
				#var unique_mat = shared_mat.duplicate() as ShaderMaterial
				#parts.material = unique_mat
				#unique_mat.set_shader_parameter("tint_color", data.tint_color)
			#else:
				#push_error("SpellParticles has no ShaderMaterial!")
			## 2c) start emitting
			#parts.emitting = true
#
			## finally add under your spell
			#spell.get_node("VFX").add_child(vfx)
			#vfx.position = Vector2.ZERO
#
	## 3) Add the spell to the world
	#get_tree().current_scene.add_child(spell)
	#return data.mana_cost

func cast(spell_name:String, origin:Vector2, dir:Vector2, mana) -> int:
	var elements = [SpellResource.Element.WATER, SpellResource.Element.FIRE, SpellResource.Element.AIR]
	var data = spells.get(spell_name, null)
	data.element = elements[randi() % 3]
	if data == null or data.mana_cost > mana:
		return 0

	if data.is_aoe:
		_cast_aoe(data, origin, dir)
	else:
		_cast_projectile(data, origin, dir)

	return data.mana_cost

# Spawn one “shard” at x,y falling straight down
func _cast_aoe(data:SpellResource, origin:Vector2, dir: Vector2) -> void:
	var half = data.aoe_radius * 0.5
	print(origin)
	for i in range(data.count):
		var pos = Vector2(
			origin.x + randf_range(-half, half),
			origin.y - data.aoe_spawn_height
		)
		var shard = data.scene.instantiate() as BaseSpell
		_configure_aoe_logic(shard, data)
		_configure_spell(shard, data, Vector2.DOWN, pos)
		get_tree().current_scene.add_child(shard)

# Spawn a single projectile in `dir`
func _cast_projectile(data:SpellResource, origin:Vector2, dir:Vector2) -> void:
	var spell = data.scene.instantiate() as BaseSpell
	_configure_projectile_logic(spell, data, dir)
	_configure_spell(spell, data, dir.normalized(), origin)

	get_tree().current_scene.add_child(spell)

# does all the common work:
func _configure_spell(spell:BaseSpell, data:SpellResource, dir:Vector2, pos:Vector2) -> void:
	# 1) Core transform & stats
	spell.position  = pos
	spell.direction = dir
	spell.speed     = data.projectile_speed
	spell.max_distance = data.max_distance
	spell.damage    = data.damage
	spell.lifetime  = data.lifetime

	# 2) Effects array
	for eff in data.effects:
		if eff:
			var copy = eff.duplicate(true) as SpellEffect
			copy.apply_to(spell)


	## 3) VFX—particles, tint, rotation
		#data.particle_scene = TRAIL
		#var vfx = data.particle_scene.instantiate() as Node2D
		#var parts = vfx
		#print(rad_to_deg(dir.angle()) )
		#parts.rotation_degrees = 360 + rad_to_deg(dir.angle()) 
		#if parts.material:
			#var mat = (parts.material as ShaderMaterial).duplicate()
			#parts.material = mat
			#mat.set_shader_parameter("tint_color", _get_element_color(data.element))
		#parts.emitting = true
		#spell.get_node("VFX").add_child(vfx)
		#vfx.position = Vector2.ZERO

func set_spell_rotation(parts: GPUParticles2D, dir: Vector2) -> void:
	parts.rotation_degrees = rad_to_deg(dir.angle())

func _get_element_color(element: int) -> Color:
	var data = ELEMENT_DATA.get(element, null)
	if data:
		return data["color"]
	else:
		return Color.WHITE

func _configure_aoe_logic(spell:BaseSpell, data:SpellResource):
	var sprite = spell.get_node("AnimatedSprite2D") as AnimatedSprite2D;
	sprite.sprite_frames = AOEFIRE
	sprite.modulate = _get_element_color(data.element)
	sprite.play("attack")
	pass
func _configure_projectile_logic(spell:BaseSpell, data:SpellResource, dir: Vector2):
	var sprite = spell.get_node("AnimatedSprite2D") as AnimatedSprite2D;
	sprite.scale = Vector2(0.2, 0.2);
	sprite.sprite_frames = PROJECTILEFIRE
	sprite.modulate = _get_element_color(data.element)
	sprite.play("attack")
	sprite.rotation_degrees = rad_to_deg(dir.angle())
	pass

#func compute_aoe_center(origin:Vector2, dir:Vector2, data:SpellResource) -> Vector2:
	#if data.is_aoe:
		## projectile AOE: shot arcs or falls like ice rain
		## same formula we derived:
		#var y0 = origin.y - data.aoe_spawn_height
		#var v0 = data.projectile_speed
		#var g  = data.gravity
		#var t  = data.lifetime
		#var fall = v0 * t + 0.5 * g * t * t
		#return Vector2(origin.x, y0 + fall)
	#else:
		## instant / self-cast / ground-target AOE
		## e.g. cast in a direction up to max_distance:
		#return origin + dir.normalized() * data.max_distance

func get_aoe_center(spell_name: String, origin: Vector2, dir: Vector2) -> Vector2:
	var data = spells.get(spell_name, null)
	if data == null:
		push_error("get_aoe_center: Unknown spell '%s'" % spell_name)
		return origin
	if not data.is_aoe:
		# Non-AOE spells just land at max_distance along dir
		return origin + dir * data.max_distance
	# Projectile-like AOE (e.g. ice rain)
	# start Y = origin.y - spawn height
	var y0 = origin.y - data.aoe_spawn_height
	# initial downward speed & gravity & lifetime
	var v0 = data.projectile_speed
	var g  = 1
	#var t  = data.lifetime
	# Δy = v0*t + ½*g*t²
	var fall = v0 * 1 + 0.5 * g * 1 * 1
	# X stays centered on origin
	return Vector2(origin.x, origin.y)

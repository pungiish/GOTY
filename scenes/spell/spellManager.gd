# SpellManager.gd
extends Node
class_name SpellManager

# Holds your base spell definitions
var spells: Dictionary[String, SpellResource] = {}
const PARTICLE_CIRCLE = preload("res://assets/particle_circle.png")
func _ready():
	_load_all_spells()

func _load_all_spells():
	# e.g. load every .tres in res://data/spells/
	var dir = DirAccess.open("res://data/spells")
	for file in dir.get_files():
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://data/spells/%s" % file)
			spells[res.name] = res

func cast(spell_name: String, origin: Vector2, dir: Vector2):
	if not spells.has(spell_name):
		push_error("Unknown spell: %s" % spell_name)
		return
	var data = spells[spell_name]

	if data.is_aoe:
		var half_w = data.aoe_width * 0.5
		for i in range(data.aoe_count):
			# 1) Instantiate the base‐spell scene, not the resource itself!
			var shard = data.scene.instantiate()

			# 2) Position it somewhere above (and optionally to the side) of the player
			var x = origin.x + dir.x + 200
			var y = origin.y - data.aoe_spawn_height
			shard.position = Vector2(x, y)

			# 3) Give it a straight‐down direction and the usual stats
			#shard.direction = Vector2.DOWN
			shard.speed = data.base_speed
			shard.damage = data.base_damage
			shard.lifetime = data.base_lifetime
			# 4) Apply any effects exactly as you do in the single‐spell case
			for eff in data.effects:
				if eff == null:
					continue
				var eff_copy = eff.duplicate(true) as SpellEffect
				eff_copy.apply_to(shard)

			# 5) Attach & tint its particle VFX (same as single‐spell)
			if data.particle_scene:
				var vfx = data.particle_scene.instantiate()
				var parts = vfx
				# rotate (not strictly needed for straight‐down, but safe)				
				parts.rotation_degrees = rad_to_deg(Vector2.DOWN.angle())
				# unique‐ify + tint
				if parts.material:
					var mat = (parts.material as ShaderMaterial).duplicate()
					parts.material = mat
					mat.set_shader_parameter("tint_color", data.tint_color)
				parts.emitting = true
				shard.get_node("VFX").add_child(vfx)
				vfx.position = Vector2.ZERO
			# 6) Finally, add the shard to the scene
			get_tree().current_scene.add_child(shard)
		return
	var spell = data.scene.instantiate()
	var sprite = spell.get_node("Sprite2D") as Sprite2D
	sprite.texture = PARTICLE_CIRCLE
	spell.position = origin
	spell.direction = dir.normalized()
	# 2) Apply base stats *and* skill‐tree modifiers
	#var speed_mod = SkillTree.get_modifier("spell_speed")    # e.g. 1.2 for +20%
	#var dmg_mod   = SkillTree.get_modifier("spell_damage")  # e.g. 1.5 for +50%
	var speed_mod = 1
	var dmg_mod = 1
	var lifetime_mod = 1
	spell.lifetime = data.base_lifetime * lifetime_mod
	spell.speed  = data.base_speed * speed_mod
	spell.damage = data.base_damage * dmg_mod

	# 3) Apply every effect, possibly tweaked by skills too
	for eff in data.effects:
		# you could also ask SkillTree to modify each effect’s magnitude/duration
		#var mag = eff.magnitude * SkillTree.get_modifier(eff.type)
		#var dur = eff.duration  * SkillTree.get_modifier(eff.type + "_duration")
		if eff == null:
			continue    # skip empty slots!

	# use true if you want a deep copy of sub-resources
		var eff_copy: SpellEffect = eff.duplicate(true) as SpellEffect

	# apply any magnitude/duration modifiers…
		eff_copy.magnitude = eff_copy.magnitude * 1
		eff_copy.duration  = eff_copy.duration  * 1	

	# now inject it into your spell
		eff_copy.apply_to(spell)

		if data.particle_scene:
			var vfx = data.particle_scene.instantiate() as Node2D
			var parts = vfx
			# 2a) rotate to aim
			set_spell_rotation(parts, dir)
			# 2b) unique‐ify & tint
			var shared_mat = parts.material as ShaderMaterial
			if shared_mat:
				var unique_mat = shared_mat.duplicate() as ShaderMaterial
				parts.material = unique_mat
				unique_mat.set_shader_parameter("tint_color", data.tint_color)
			else:
				push_error("SpellParticles has no ShaderMaterial!")
			# 2c) start emitting
			parts.emitting = true

			# finally add under your spell
			spell.get_node("VFX").add_child(vfx)
			vfx.position = Vector2.ZERO

	# 3) Add the spell to the world
	get_tree().current_scene.add_child(spell)

func set_spell_rotation(parts: GPUParticles2D, dir: Vector2) -> void:
	# dir.angle() returns radians; convert to degrees
	parts.rotation_degrees = rad_to_deg(dir.angle())
	

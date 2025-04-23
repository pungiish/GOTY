# SpellManager.gd
extends Node
class_name SpellManager

# Holds your base spell definitions
var spells: Dictionary[String, SpellResource] = {}

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

	# 1) Instantiate the scene
	var spell = data.scene.instantiate()
	spell.position = origin
	spell.direction = dir.normalized()

	# 2) Apply base stats *and* skill‐tree modifiers
	#var speed_mod = SkillTree.get_modifier("spell_speed")    # e.g. 1.2 for +20%
	#var dmg_mod   = SkillTree.get_modifier("spell_damage")  # e.g. 1.5 for +50%
	var speed_mod = 1
	var dmg_mod = 1
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

# get your particles node
	var parts = spell.get_node("SpellParticles") as GPUParticles2D

# grab the ShaderMaterial from the Material-Override slot
	var shader_mat = parts.material as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter("tint_color", data.tint_color)
	else:
		push_error("SpellParticles has no ShaderMaterial in Material Override!")

	# now start emitting
	parts.emitting = true
	# 4) Add to the scene
	get_tree().current_scene.add_child(spell)

# SpellEffect.gd
extends Resource
class_name SpellEffect

enum EffectType { DAMAGE, BURN, SLOW, KNOCKBACK }

@export var type: EffectType
@export var magnitude: float = 1.0
@export var duration: float = 1.0

func apply_to(spell_node):
	# Called by the SpellManager to inject behavior
	match type:
		EffectType.BURN:
			spell_node.add_burn(magnitude, duration)
		EffectType.SLOW:
			spell_node.add_slow(magnitude, duration)

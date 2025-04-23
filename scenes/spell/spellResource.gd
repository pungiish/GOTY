# SpellResource.gd
extends Resource
class_name SpellResource

@export var name: String
@export var scene: PackedScene             # The .tscn to instantiate
@export var base_speed: float = 30.0
@export var base_damage: int = 10
@export var effects: Array[SpellEffect] = []
@export var tint_color: Color = Color(1,1,1)  # default white

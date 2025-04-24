# SpellResource.gd
extends Resource
class_name SpellResource

@export var name: String
@export var scene: PackedScene             # The .tscn to instantiate
@export var base_speed: float = 150
@export var base_lifetime: float = 10
@export var base_damage: int = 10
@export var effects: Array[SpellEffect] = []
@export var tint_color: Color = Color(1,1,1)  # default white
@export var particle_scene: PackedScene
@export var is_aoe: bool = false           # single vs. multi‐spawn
@export var aoe_spawn_height: float = 200  # pixels above player
@export var aoe_width: float = 300         # horizontal spread
@export var aoe_count: int = 10            # how many shards

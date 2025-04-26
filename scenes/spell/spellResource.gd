# SpellResource.gd
extends Resource
class_name SpellResource
const BASE_SPELL = preload("res://scenes/spell/baseSpell.tscn")
@export var name: String
@export var scene: PackedScene = BASE_SPELL

# ── Basic Costs & Timing ───────────────────────────
@export var mana_cost:       int     = 10    # MANA
@export var cast_time:       float   = 0.5   # CAST SPEED (sec)
@export var tick_time:       float   = 0.0   # For DOT/heal over time
@export var insta_cast:      bool    = false # INSTA CAST
@export var self_cast:       bool    = false # SELF CAST
@export var aoe_spawn_height: float = 0.0  # pixels above player

# ── Projectile / Movement ─────────────────────────
@export var projectile_speed:  float = 400.0  # MOVEMENT SPEED of the projectile
@export var lifetime: int = 4  # MOVEMENT SPEED of the projectile
@export var max_distance:      float = 800.0  # MAX DISTANCE before auto‐free
@export var homing_strength:   float = 0.0    # 0 = no homing
@export var direction:         Vector2 = Vector2.RIGHT # default aim
@export var count:             int     = 1    # COUNT (number of shards/projectiles)
@export var size:              float   = 1.0  # SIZE multiplier

# ── Damage / Healing ──────────────────────────────
@export var damage:            int     = 0    # VALUE(DAMAGE)
@export var heal_amount:       int     = 0    # VALUE(HEAL)
@export var damage_falloff:    float   = 0.0  # % reduction per unit
@export var pierce:            bool    = false# PIERCING
@export var pierce_strength:   int     = 1    # how many enemies it can pierce
@export var bounce:            bool    = false# BOUNCING
@export var bounce_count:      int     = 0    # number of bounces
@export var bounce_strength:   float   = 1.0  # energy retention on bounce
@export var target_count:      int     = 1    # for AOE chaining, multi‐target

# ── Area & Shape ──────────────────────────────────
@export var is_aoe:            bool    = false# AOE flag
@export var aoe_radius:        float   = 0.0  # AREA / AOE radius
enum Shape { POINT, LINE, CIRCLE, CONE }
@export var shape:            Shape  = Shape.POINT

# ── Element & Effects ─────────────────────────────
enum Element { FIRE, WATER, AIR, EARTH, LIGHT, DARK }
@export var element:          Element = Element.FIRE
# Vector of modular effect resources (burn, slow, stun, poison, buff, etc.)
@export var effects:         Array[SpellEffect] = []

# ── VFX Hooks (Particles, Sprites) ───────────────
@export var sprite_texture:    Texture        # for static sprites
@export var animation_name:    String         # for AnimatedSprite2D
@export var particle_scene:    PackedScene    # for particles/VFX sub‐scene
@export var particle_material: ParticleProcessMaterial # optional per-spell material

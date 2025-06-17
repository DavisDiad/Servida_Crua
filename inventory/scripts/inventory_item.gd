# InvItem.gd
extends Resource
class_name InvItem

@export var name: String
@export var texture: Texture2D
@export var is_equipable: bool = false

@export var type: String = ""  # weapon / object / accessory
@export var min_damage: int = 0
@export var max_damage: int = 0
@export var accuracy: int = 0
@export var evasion: int = 0
@export var max_wounds: int = 0

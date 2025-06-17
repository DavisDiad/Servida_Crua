# InvEquItem.gd
extends Resource
class_name InvEquItem

@export var base_item: InvItem  # referencia ao item base (sem recursão)
@export var min_damage: int = 0
@export var max_damage: int = 0
@export var accuracy: int = 0
@export var evasion: int = 0
@export var max_wounds: int = 0
@export var type: String = ""  # "weapon", "object", "accessory"

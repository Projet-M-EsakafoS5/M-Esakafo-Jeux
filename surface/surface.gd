extends Node2D

@onready var area: Area2D = $comptoir_interaction

func _ready():
	area.name = "SurfaceArea"  # Assure que le nom est correct

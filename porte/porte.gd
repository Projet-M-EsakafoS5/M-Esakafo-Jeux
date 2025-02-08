extends Node2D

@onready var area: Area2D = $Area2D

func _ready():
	area.name = "PorteArea"  # Assure que le nom est correct

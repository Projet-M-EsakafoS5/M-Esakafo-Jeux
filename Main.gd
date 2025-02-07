extends Control
const FeuScene = preload("res://surface/surface.tscn")  # Charge la scène du feu
@onready var main = $"."  # Référence directe à la scène principale

#@onready var cuisson_manager = CuissonManager
var nb_feux = 3
var feux = []

func _ready():
	#if !has_node("CuissonManager"):
		#add_child(cuisson_manager)
	generer_feux()
		
func generer_feux():
	var spacing = 75  # Espacement entre chaque feu (ajuste selon tes besoins)
	
	for i in range(nb_feux):
		var feu_instance = FeuScene.instantiate()
		feu_instance.name = "Feu_" + str(i)

		#feu_instance.custom_minimum_size = Vector2(100, 100)  # Taille minimale
		#feu_instance.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # Centre l'élément
		main.add_child(feu_instance)
		main.move_child(feu_instance, 1)
		feux.append(feu_instance)

		# Positionnement manuel (ex: en ligne horizontale)
		var offset = Vector2(600, 150)
		feu_instance.position = Vector2(i * spacing, i * spacing/2) + offset

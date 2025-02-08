extends Node2D 
var gobelin_present: Goblin = null
var id_plat = null

func _ready():
	if id_plat != null:
		print("Plat prêt à être ramassé, ID :", id_plat)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Goblin:
		gobelin_present = body
		print("Gobelin à proximité")



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Goblin:
		gobelin_present = null 
		print("Gobelin est parti")
	

func _process(_delta):
	if gobelin_present and Input.is_action_just_pressed("grab"):
		gobelin_present.recuperer_plat_cuit(self)
		print("Le gobelin a récupéré la commande numero ", id_plat)
		#queue_free()  # Supprime le plat après récupération
		

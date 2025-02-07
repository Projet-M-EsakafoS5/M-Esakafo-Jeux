extends Node2D  # (ou StaticBody2D selon ton cas)
var gobelin_present: Goblin = null  # Stocke le gobelin s'il est dans la zone
var id_plat = null  # ID du plat cuisiné

func _ready():
	if id_plat != null:
		print("Plat prêt à être ramassé, ID :", id_plat)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Goblin:
		gobelin_present = body  # Stocke le gobelin
		print("Gobelin à proximité")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Goblin:
		gobelin_present = null  # Supprime la référence si le gobelin part
		print("Gobelin est parti")

func _process(_delta):
	if gobelin_present and Input.is_action_just_pressed("grab"):
		gobelin_present.recuperer_plat_cuit(self)
		print("Le gobelin a récupéré le plat")
		#queue_free()  # Supprime le plat après récupération

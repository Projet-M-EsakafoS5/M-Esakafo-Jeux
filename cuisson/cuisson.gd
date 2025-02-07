class_name Cuisson extends Node2D

# Fermer cette scène et revenir à la précédente
func _on_button_pressed():
	queue_free()  # Supprime cette scène de l'arbre de scènes

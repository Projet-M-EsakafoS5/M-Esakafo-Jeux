extends Panel

@onready var grid = $PlatsContainer  # Assure-toi que le GridContainer est bien enfant du Panel

func _process(_delta):
	size = grid.size  # Met à jour la taille du Panel pour qu'elle suive celle du GridContainer

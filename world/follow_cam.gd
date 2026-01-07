extends Camera2D

@export var tilemaplayer: TileMapLayer

func _ready():
	var mapRect = tilemaplayer.get_used_rect()
	var tileSize = tilemaplayer.physics_quadrant_size
	var worldSizeInPixels = mapRect.size * tileSize
	limit_right = worldSizeInPixels.x
	limit_left = 0
	limit_bottom = 200
	limit_top = 	-worldSizeInPixels.y

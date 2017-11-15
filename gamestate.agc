type gamestate
    ship as ship
	planets as planet[20]
	settings as settings
endtype

type planet
	name as string
	position as Vector2D
	resources as resource[5]
	planet_type as integer
	size# as float
endtype

type asteroid
	position as Vector2D
	resources as resource[2]
	drift as Vector2D
	size as float
endtype

type resource
	name as string
endtype
	
type settings
	platform as integer
	accelration as integer
	decellratoin as integer
	turnleft as integer
	turnright as integer
	scan as integer
	music_volume as integer
	sound_volume as integer
	dialogue_volume as integer
	fps as integer
endtype	

// functions for supporting the player ship
type ship
    velocity# as float
    max_velocity# as float
    acceleration# as float
    position as Vector2D
    turnspeed# as float
    angle# as float
    heading as Vector2D
    current_turning as integer
endtype

function calculate_heading (velocity# as float, angle# as float, heading REF as Vector2D)
	heading.x=velocity#*sin(angle#)
	heading.y=-velocity#*cos(angle#)
endfunction

function move_ship(ship REF as ship)
	ship.position=addVector2(ship.position,ship.heading)
endfunction

	


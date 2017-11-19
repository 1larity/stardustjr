
function nextArcStep(centre as Vector2D, radius as integer, angle# as float)
resultVector as Vector2D
resultVector.x = centre.x + radius * cos(angle#)
resultVector.y = centre.y + radius * sin(angle#)
endfunction resultVector

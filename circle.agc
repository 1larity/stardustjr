
function nextArcStep(centre as Vector2D, radius as Vector2D, angle# as float)
resultVector as Vector2D
resultVector.x = centre.x + radius.x * cos(angle#)
resultVector.y = centre.y + radius.y * sin(angle#)
endfunction resultVector

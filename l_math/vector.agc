


type Vector2D
    x as float
    y as float
endtype
 
type Vector3D
    x as float
    y as float
    z as float
endtype
 
 
 
 
REM **********************************************************************************
REM **********************************************************************************
REM
REM                                    2D VECTORS
REM
REM **********************************************************************************
REM **********************************************************************************
 
 
rem ==============================================================
rem Returns a 2D vector set with [x,y]
rem ==============================================================
function makeVector2D(x as float, y as float)
    v as Vector2D
    v.x = x
    v.y = y
endfunction v
 
 
rem ==============================================================
rem Returns a 2D vector of the sum of v1 and v2
rem ==============================================================
function addVector2(v1 as Vector2D, v2 as Vector2D)
    v as Vector2D
    v.x = v1.x + v2.x
    v.y = v1.y + v2.y
endfunction v
 
 
rem ==============================================================
rem Returns a 2D vector of the difference of v2 from v1
rem ==============================================================
function subtractVector2(v1 as Vector2D, v2 as Vector2D)
    v as Vector2D
    v.x = v1.x - v2.x
    v.y = v1.y - v2.y
endfunction v
 
 
rem ==============================================================
rem Returns a 2D vector of the product of v1 and v2
rem ==============================================================
function multiplyVector2(v1 as Vector2D, v2 as Vector2D)
    v as Vector2D
    v.x = v1.x * v2.x
    v.y = v1.y * v2.y
endfunction v
 
 
rem ==============================================================
rem Returns a 2D vector of the quotient of v1 and v2
rem ==============================================================
function divideVector2(v1 as Vector2D, v2 as Vector2D)
    v as Vector2D
    v.x = v1.x / v2.x
    v.y = v1.y / v2.y
endfunction v
 
 
rem ==============================================================
rem Returns the dot product of two vectors
rem ==============================================================
function dotProductVector2(v1 as Vector2D, v2 as Vector2D)
	d# as float
    d# = v1.x*v2.x + v1.y*v2.y
endfunction d#
 
 
rem ==============================================================
rem Returns a 2D vector with an interpolate value from v1
rem to v2 using the 'sValue' as step value [0.0-1.0]
rem ==============================================================
function linearInterpolateVector2(v1 as Vector2D, v2 as Vector2D, sValue as float)
    v as Vector2D
    v.x = v1.x + (v2.x*v1.x)*sValue
    v.y = v1.y + (v2.y*v1.y)*sValue
endfunction v
 
 
rem ==============================================================
rem Returns the length (or magnitude) of a 2D vector
rem ==============================================================
function getVector2Length(v1 as Vector2D)
	l# as float
    l# = v1.x*v1.x + v1.y*v1.y
    l# = sqrt(l#)
endfunction l#
 
 
rem ==============================================================
rem Returns a normalized 2D vector (or unit vector) of v1
rem ==============================================================
function normalizeVector2(v1 as Vector2D)
    v as Vector2D
    d# as float
    d# = getVector2Length(v1)
    v.x = v1.x / d#
    v.y = v1.y / d#
endfunction v
 
 
rem ==============================================================
rem Returns the reflected vector of 'I' off of a surface having
rem the normal 'N'
rem ==============================================================
function reflectVector2(I as Vector2D, N as vector2D)
    r as Vector2D
    d# as float
    d# = dotProductVector2(N, I)
    r.x = 2*N.x*d# - I.x
    r.y = 2*N.y*d# - I.y
endfunction r
 
 
 
REM **********************************************************************************
REM **********************************************************************************
REM
REM                                    3D VECTORS
REM
REM **********************************************************************************
REM **********************************************************************************
 
 
rem ==============================================================
rem Returns a 3D vector set with [x,y,z]
rem ==============================================================
function makeVector3(x as float, y as float, z as float)
    v as Vector3D
    v.x = x
    v.y = y
    v.z = z
endfunction v
 
 
rem ==============================================================
rem Returns a 3D vector of the sum of v1 and v2
rem ==============================================================
function addVector3(v1 as Vector3D, v2 as Vector3D)
    v as Vector3D
    v.x = v1.x + v2.x
    v.y = v1.y + v2.y
    v.z = v1.z + v2.z
endfunction v
 
 
rem ==============================================================
rem Returns a 3D vector of the difference of v2 from v1
rem ==============================================================
function subtractVector3(v1 as Vector3D, v2 as Vector3D)
    v as Vector3D
    v.x = v1.x - v2.x
    v.y = v1.y - v2.y
    v.z = v1.z - v2.z
endfunction v
 
 
rem ==============================================================
rem Returns a 3D vector of the product of v1 and v2
rem ==============================================================
function multiplyVector3(v1 as Vector3D, v2 as Vector3D)
    v as Vector3D
    v.x = v1.x * v2.x
    v.y = v1.y * v2.y
    v.z = v1.z * v2.z
endfunction v
 
 
rem ==============================================================
rem Returns a 3D vector of the quotient of v1 and v2
rem ==============================================================
function divideVector3(v1 as Vector3D, v2 as Vector3D)
    v as Vector3D
    v.x = v1.x / v2.x
    v.y = v1.y / v2.y
    v.z = v1.z / v2.z
endfunction v
 
 
rem ==============================================================
rem Returns a 3D vector containing the cross product of v1 and v2
rem ==============================================================
function crossProductVector3(v1 as Vector3D, v2 as Vector3D)
    v as Vector3D
    v.x = (v1.y * v2.z) - (v1.z * v2.y)
    v.y = (v1.z * v2.x) - (v1.x * v2.z)
    v.z = (v1.x * v2.y) - (v1.y * v2.x)
endfunction v
 
 
rem ==============================================================
rem Returns the dot product of two vectors
rem ==============================================================
function dotProductVector3(v1 as Vector3D, v2 as Vector3D)
	d# as float
    d# = v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
endfunction d#
 
 
rem ==============================================================
rem Returns a 3D vector with an interpolate value from v1
rem to v2 using the 'sValue' as step value [0.0-1.0]
rem ==============================================================
function linearInterpolateVector3(v1 as Vector3D, v2 as Vector3D, sValue as float)
    v as Vector3D
    v.x = v1.x + (v2.x*v1.x)*sValue
    v.y = v1.y + (v2.y*v1.y)*sValue
    v.z = v1.z + (v2.z*v1.z)*sValue
endfunction v
 
 
rem ==============================================================
rem Returns the length (or magnitude) of a 3D vector
rem ==============================================================
function getVector3Length2(v1 as Vector3D)
	l# as float
    l# = v1.x*v1.x + v1.y*v1.y + v1.z*v1.z
    l# = sqrt(l#)
endfunction l#
 
 
rem ==============================================================
rem Returns a normalized 3D vector (or unit vector) of v1
rem ==============================================================
function normalizeVector3(v1 as Vector3D)
    v as Vector3D
    d# as float
    d# = getVector3Length2(v1)
    v.x = v1.x / d#
    v.y = v1.y / d#
    v.z = v1.z / d#
endfunction v
 
 
rem ==============================================================
rem Returns the reflected vector of 'I' off of a surface having
rem the normal 'N'
rem ==============================================================
function reflectVector3(I as Vector3D, N as vector3D)
    r as Vector3D
    d# as float
    d# = dotProductVector3(N, I)
    r.x = 2*N.x*d# - I.x
    r.y = 2*N.y*d# - I.y
    r.z = 2*N.z*d# - I.z
endfunction r

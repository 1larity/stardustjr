/****************************************************************/
/*                  MAIN DATA STRUCTURE 						*/
/****************************************************************/

type gamestate
    playerShip as ship
    session as session
	planets as planet[13]
	stations as station[2]
	settings as settings
endtype

type planet
	planetID as integer
	name as string
	position as Vector2D
	angularVelocity# as float
	resources as resource[5]
	planet_type as integer
	size# as float
	//planet colour
	r as integer
	g as integer
	b as integer
	angle# as float
endtype

type station
	stationID as integer
	name as String
	position as Vector2D
	facilities as facility[5]
	stationType as integer
endtype

type asteroid
	position as Vector2D
	resources as resource[2]
	drift as Vector2D
	size as float
endtype

type facility 
	facilityType as string
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

type session
	clientName$ as String	//player's nickname
	ServerHost$ as string	// IP Of Server
	ServerPort as integer	//server port
	NetworkLatency as integer//network latency
	myClientId as integer
	networkID as integer //
	//the physical size of the gamemap
	worldSize as integer
endtype

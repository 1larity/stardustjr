function create_minimap(gamestate as gamestate)
oldOffsetX# as float
oldOffsetY# as float
oldZoom# as float
thisZoom# as float
worldSize as integer= 1000
mapSize# as float 


mapSize# = 100// devMin# / 20.0
	// Store current offsets and zoom to restore later
	oldOffsetX# = getViewOffsetX()
	oldOffsetY# = getViewOffsetY()
	oldZoom# = getViewZoom()

	thisZoom# = mapSize# / worldSize
	setViewZoom( thisZoom# )
	SetDisplayAspect(-1.0)
	//create working image
	CreateRenderImage( minimap, 512, 512, 0, 0 )
	//render to the working image, not screen
	 SetRenderToImage( minimap, -1 ) // -1 for depth to use an internal buffer, we could set an image if we wanted (not supported on all devices)
    ClearScreen() // clear the image before drawing to it
	index as integer


	//for index =0 to gamestate.planets.length
		//createSprite(400+index,gamestate.planets[index].planet_type+2)
		//SetSpriteScale(index+400,gamestate.planets[index].size#,gamestate.planets[index].size#)
		//SetSpritePositionByOffset(400+index, gamestate.planets[index].position.x,gamestate.planets[index].position.y)
	//next index

	Render() // draw the scene to the image

	//clear planet sprites
	for index =0 to gamestate.planets.length
		deleteSprite(400+index)
	next index
SetDisplayAspect(1.0)
	//create map sprite from image
	CreateSprite (minimap,minimap)
	//set map scale an position
	
	//restore screen space
	setViewOffset( oldOffsetX# , oldOffsetY# )
	setViewZoom( oldZoom# )

	//reset rendering to main screen

	SetRenderToScreen()
	SetSpriteScale(minimap,0.04,0.04)
	SetSpritePosition  ( minimap,100 - GetSpriteWidth( minimap ) , 0 )
	FixSpriteToScreen(minimap,1)
endfunction

function positionMiniMap()
	SetSpritePosition  ( minimap,GetScreenBoundsRight() - GetSpriteWidth( minimap ) , GetScreenBoundsTop())
	//fix joystick to lower right screen
	SetVirtualJoystickPosition(1,GetScreenBoundsRight() -20,GetScreenBoundsBottom()-20)
endfunction

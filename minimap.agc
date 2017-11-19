function create_minimap()
oldOffsetX# as float
oldOffsetY# as float
oldZoom# as float
thisZoom# as float
mapSize# as float 


mapSize# = 100// devMin# / 20.0
	// Store current offsets and zoom to restore later
	oldOffsetX# = getViewOffsetX()
	oldOffsetY# = getViewOffsetY()
	oldZoom# = getViewZoom()

	thisZoom# = mapSize# / gamestate.session.worldSize
	setViewZoom( thisZoom# )
	SetDisplayAspect(-1.0)
	//create working image
		DeleteImage( minimap)
	CreateRenderImage( minimap, 512, 512, 0, 0 )
	//render to the working image, not screen
	 SetRenderToImage( minimap, -1 ) // -1 for depth to use an internal buffer, we could set an image if we wanted (not supported on all devices)
    ClearScreen() // clear the image before drawing to it
	index as integer
	//calculate size to scale the planets so they are still visible
	rescale as integer
	rescale = gamestate.session.worldSize/400

	//rescale planet sprites so they are still visible on minimap
	for index =0 to gamestate.planets.length
		SetSpriteScale(index+50,gamestate.planets[index].size#*rescale,gamestate.planets[index].size#*rescale)
		SetSpritePositionByOffset(index+50,gamestate.planets[index].position.x,gamestate.planets[index].position.y)
	next index
	//if a minimap already exists
	//	if minimap<>-1
		///	 hide_unwanted()
		//endif
	/////////////////////do all scene setup before here!////////////////////////////////////////
	Render() // draw the scene to the image
	////////////////////restore gamesceen after here!////////////////////////
	//reset planet sprite scale
	//unhide_wanted()
	for index =0 to gamestate.planets.length
		SetSpriteScale(index+50,gamestate.planets[index].size#,gamestate.planets[index].size#)
		SetSpritePositionByOffset(index+50,gamestate.planets[index].position.x,gamestate.planets[index].position.y)
	next index
	SetDisplayAspect(1.0)
	//create map sprite from image
	DeleteSprite (minimap)
	CreateSprite (minimap,minimap)
	//set map scale and position
	
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

//hide unwanted objects that we don't want showing in the minimap
function hide_unwanted()
	SetSpriteVisible(player_ship,0)
	SetEditBoxVisible(incoming_chat_text,0)
	SetSpriteVisible(minimap,0)
endfunction
//show objects that were hidden for minimap render
function unhide_wanted()
	SetSpriteVisible(player_ship,1)
	SetEditBoxVisible(incoming_chat_text,1)
endfunction

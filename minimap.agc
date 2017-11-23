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
	setViewOffset(0, 0 )
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
	rescale = gamestate.session.worldSize/600

	//rescale planet sprites so they are still visible on minimap
	for index =0 to gamestate.planets.length
		SetSpriteScale(index+50,gamestate.planets[index].size#*rescale,gamestate.planets[index].size#*rescale)
		SetSpritePositionByOffset(index+50,gamestate.planets[index].position.x,gamestate.planets[index].position.y)
		SetSpriteColor(index+50,255,255,255,255)
		
	next index
	//if a minimap already exists
	if GetSpriteExists(minimap)
		hide_unwanted()
	endif
	
	/////////////////////do all scene setup before here!////////////////////////////////////////
	Render() // draw the scene to the image
	////////////////////restore gamesceen after here!////////////////////////
	//reset planet sprite scale
	
	//if a minimap already exists
	if GetSpriteExists(minimap)
		unhide_wanted()
	endif
	
	for index =0 to gamestate.planets.length
		SetSpriteScale(index+50,gamestate.planets[index].size#,gamestate.planets[index].size#)
		SetSpritePositionByOffset(index+50,gamestate.planets[index].position.x,gamestate.planets[index].position.y)
		SetSpriteShape(index+50, 1)
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
	if isScanning=1
		SetSpriteVisible ( scan_wave, 0 )
	endif
	//hide player ship
	SetSpriteVisible(player_ship,0)
	//hide chat frame
	SetEditBoxVisible(incoming_chat_text,0)
	//hide chat entry box
	SetEditBoxVisible(chat_edit_text,0)
	//hide minimap
	SetSpriteVisible(minimap,0)
	//hide chat title
	SetTextVisible(chat_header_text,0)
	//hide buttons
	SetVirtualButtonVisible(1,0)
	SetVirtualButtonVisible(2,0)
	SetVirtualButtonVisible(3,0)
	SetVirtualButtonVisible(4,0)
	//hide joystick
	SetVirtualJoystickVisible(1,0)
	//hide button text
	SetTextVisible(scan_button_text,0)
	SetTextVisible(save_button_text,0)
	SetTextVisible(load_button_text,0)
	SetTextVisible(mine_button_text,0)
	//hide minimap ship
	SetSpriteVisible(minimap_player_ship,0)
	//hide background stars
	if GetSpriteExists(500)
	index as integer
	//for index =0 to gamestate.session.bgStars-5 step 5
		//SetSpriteVisible(index+500,0)
		//SetSpriteVisible(index+501,0)
		//SetSpriteVisible(index+502,0)
		//SetSpriteVisible(index+503,0)
		//SetSpriteVisible(index+504,0)
	//next index
	endif
	SetClearColor(30,30,30)
	
ClearScreen()
endfunction
//show objects that were hidden for minimap render
function unhide_wanted()
	//show scanwave
	if isScanning=1
		SetSpriteVisible ( scan_wave, 1 )
	endif
	//show player ship
	SetSpriteVisible(player_ship,1)
	//show minimap
	SetSpriteVisible(minimap,1)
	//show chat frame
	SetEditBoxVisible(incoming_chat_text,1)
	//hide chat entry box
	SetEditBoxVisible(chat_edit_text,1)
	//show joystick
	SetVirtualJoystickVisible(1,1)
	//show chat title
	SetTextVisible(chat_header_text,1)
	//show buttons
	SetVirtualButtonVisible(1,1)
	SetVirtualButtonVisible(2,1)
	SetVirtualButtonVisible(3,1)
	SetVirtualButtonVisible(4,1)
	//show button text
	SetTextVisible(scan_button_text,1)
	SetTextVisible(save_button_text,1)
	SetTextVisible(load_button_text,1)
	SetTextVisible(mine_button_text,1)
	//hide minimap ship
	SetSpriteVisible(minimap_player_ship,1)
	//hide background stars
	if GetSpriteExists(500)
	index as integer
	//for index =1 to gamestate.session.bgStars-5 step 5 
		//SetSpriteVisible(index+500,1)
		//SetSpriteVisible(index+501,1)
		//SetSpriteVisible(index+502,1)
		//SetSpriteVisible(index+503,1)
		//SetSpriteVisible(index+504,1)
	//next index
	endif
	SetClearColor(2,5,30)
endfunction

#include "ship.agc"
global isScanning as integer=0
global scanStart# as float =0

//dou player inputs for touch screen
function doSimMobile(gamestate REF as gamestate)
	controller_x# as float
	controller_y# as float
	controller_x# = GetVirtualJoystickX(1)
	controller_y# = GetVirtualJoystickY(1)
	Print ("JoyStick X: "+Str(GetVirtualJoystickX(1),2))
	Print ("JoyStick Y: "+Str(GetVirtualJoystickY(1),2))
	
   //assume ship is not turning
   gamestate.ship.current_turning=3
   // set slow ship turn
    
    if controller_x#>0.25 and controller_x#<0.65
		gamestate.ship.angle#=gamestate.ship.angle# + (gamestate.ship.turnspeed#/2)
		gamestate.ship.current_turning=4
	endif
	if controller_x#<-0.25 and controller_x# > - 0.65
		gamestate.ship.angle#=gamestate.ship.angle# - (gamestate.ship.turnspeed#/2)
		gamestate.ship.current_turning=2
	endif
	//set ship fast turn
	    if controller_x#>0.65
		gamestate.ship.angle#=gamestate.ship.angle# + gamestate.ship.turnspeed#
		gamestate.ship.current_turning=1
	endif
	if controller_x#<-0.65 
		gamestate.ship.angle#=gamestate.ship.angle# - gamestate.ship.turnspeed#
		gamestate.ship.current_turning=5
	endif
	
	
	gamestate.ship.angle#=Mod(gamestate.ship.angle#, 360)
remstart	
	if ship.angle# <= -0.1
		ship.angle#=360
	endif
	if ship.angle#>=360.1
		ship.angle# =0
	endif
remend		
	if (controller_y#<0.25 and gamestate.ship.velocity# < gamestate.ship.max_velocity#) 
		gamestate.ship.velocity#=gamestate.ship.velocity# + gamestate.ship.acceleration#
	endif
	if gamestate.ship.velocity#>gamestate.ship.max_velocity# 
		gamestate.ship.velocity# = gamestate.ship.max_velocity#
	endif
	
	if controller_y#>-0.25 and gamestate.ship.velocity# => 0
		gamestate.ship.velocity#=gamestate.ship.velocity# - gamestate.ship.acceleration#
	endif	
	if gamestate.ship.velocity#<0 
		gamestate.ship.velocity#=0
	endif
	calculate_heading(gamestate.ship.velocity# ,gamestate.ship.angle#, gamestate.ship.heading ) 
	
	
	if GetVirtualButtonPressed(1)=1
		startScan(gamestate)
	endif
	if GetVirtualButtonPressed(2)=1
		saveMap( "testsave.ded", gamestate )
	endif
		if GetVirtualButtonPressed(3)=1
		gamestate=loadMap( "testsave.ded" )
	endif
endfunction

//do player inputs for keyboard
function doSimPC(gamestate REF as gamestate)
	controller_x# as float
	controller_y# as float
   
   //assume ship is not turning
   gamestate.ship.current_turning=3
   // set slow ship turn
    
    if GetRawKeyState(68)
		gamestate.ship.angle#=gamestate.ship.angle# + (gamestate.ship.turnspeed#/2)
		gamestate.ship.current_turning=2
	endif
	if GetRawKeyState(65)
		gamestate.ship.angle#=gamestate.ship.angle# - (gamestate.ship.turnspeed#/2)
		gamestate.ship.current_turning=4
	endif
	//set ship fast turn
	    if controller_x#>0.65
		gamestate.ship.angle#=gamestate.ship.angle# + gamestate.ship.turnspeed#
		gamestate.ship.current_turning=4
	endif
	if controller_x#<-0.65 
		gamestate.ship.angle#=gamestate.ship.angle# - gamestate.ship.turnspeed#
		gamestate.ship.current_turning=5
	endif
	
	
	gamestate.ship.angle#=Mod(gamestate.ship.angle#, 360)
remstart	
	if ship.angle# <= -0.1
		ship.angle#=360
	endif
	if ship.angle#>=360.1
		ship.angle# =0
	endif
remend		
//check keyboard state for acceleration/decelleraion
	if  GetRawKeyState(87)
		gamestate.ship.velocity#=gamestate.ship.velocity# + gamestate.ship.acceleration#
	endif
	if gamestate.ship.velocity#>gamestate.ship.max_velocity# 
		gamestate.ship.velocity# = gamestate.ship.max_velocity#
	endif
	
	if GetRawKeyState(83)
		gamestate.ship.velocity#=gamestate.ship.velocity# - gamestate.ship.acceleration#
	endif	
	if gamestate.ship.velocity#<0 
		gamestate.ship.velocity#=0
	endif
	//calculate heading vector
	calculate_heading(gamestate.ship.velocity# ,gamestate.ship.angle#, gamestate.ship.heading ) 
	
	//if space is pressed
	if GetRawKeyPressed(32)=1 
		startScan(gamestate)
	
	else
		SetSpriteVisible ( scan_wave, 0 )
	endif

	
endfunction

//simulate gameworld
function doSim(gamestate REF as gamestate)
	doScan(gamestate)
	update_world(gamestate)
endfunction

function update_world(gamestate REF as gamestate)
	check_refuel()
	check_planet_scan(gamestate)
	positionMiniMap()
	
	move_ship(gamestate.ship)
	SetSpritePosition(minimap_player_ship,(GetScreenBoundsRight() - GetSpriteWidth( minimap))+(gamestate.ship.position.x/50),GetScreenBoundsTop()+gamestate.ship.position.y/50)
	SetSpriteAngle (minimap_player_ship, gamestate.ship.angle# )
	SetSpritePositionByOffset  ( player_ship, gamestate.ship.position.x, gamestate.ship.position.y )
	setViewOffset( gamestate.ship.position.x - getVirtualWidth() / 2.0 ,gamestate.ship.position.y - getVirtualHeight() / 2.0  )
	SetSpriteFrame(player_ship,gamestate.ship.current_turning)
	SetSpriteAngle (player_ship, gamestate.ship.angle# )
endfunction		

function check_refuel()
	
	if GetSpriteCollision(player_ship,2)
		print("refueling")
	endif
endfunction
            
function check_planet_scan(gamestate REF as gamestate)
	index as integer
	for index =0 to gamestate.planets.length
		if GetSpriteCollision(player_ship,index+50)
			print("Scanning planet "+ gamestate.planets[index].name)
		endif
	next index	
endfunction

function doScan( gamestate REF as gamestate)
	if scanStart# <>0
		if (Timer() > scanStart#+3)
			scanStart#=0
			isScanning=0
			//check scan was succesful and reaveal number
			discoverNumber(gamestate.ship.position)
			SetSpriteVisible ( scan_wave, 0 )
		else
			scanScale# as float
			scanScale#=(Timer()-scanStart#)/10
			print("scanning")
			SetSpriteVisible ( scan_wave, 1 )
			if (Timer()	< scanStart#+1.5)
				SetSpriteScale( scan_wave, scanScale#,scanScale#)
				SetSpritePositionByOffset  ( scan_wave, 50, 50 )
			else
				SetSpriteScale( scan_wave, .3-scanScale#,.3-scanScale#)
				SetSpritePositionByOffset  ( scan_wave, 50, 50 )
			endif
		endif
	endif
endfunction

function startScan(gamestate REF as gamestate)
		if isScanning =0
		scanStart#=Timer()
		isScanning=1
		SetSpriteVisible ( scan_wave, 1 )
		PlaySound ( scan_sound )
	endif
endfunction





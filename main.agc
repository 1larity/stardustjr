
// Project: Stardust space game 
// Created: 2017-10-11
// Copyright Richard Beech 2000-2020
// show all errors and stop (1=continue,0=ignore)
SetErrorMode(2)
//Require declaration of vars
#option_explicit
//
#include "mediaconstant.agc"
#include "starfield.agc"
#include "medialoader.agc"
#include "simstuff.agc"
#include "gamestate.agc"
#include "particle.agc"
#include "interface.agc"
#include "fileops.agc"
#include "minimap.agc"
#include "vector.agc"
#include "ship.agc"
#include "NetGamePlugin.agc"
#include "netcode.agc"
#include "chat.agc"
#constant debug =1

// set window properties
SetWindowTitle( "Starfield" )
SetWindowSize( 1000, 1000, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
//SetVirtualResolution( 1024, 768 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts
SetDisplayAspect(1.0)
SetPrintSize( 2 ) 
global gamestate as gamestate
global ChatEditFocus
setupNetSession()

//setup planets
populate_planets(gamestate.planets)
load_assets(gamestate)



setup_interface()


gamestate.ship.position.x=500.0
gamestate.ship.position.y=500.0
gamestate.ship.angle#=0
gamestate.ship.turnspeed#=10
gamestate.ship.velocity#=0
gamestate.ship.acceleration#=.05
gamestate.ship.max_velocity#=2.5

distance_to_sun# as float
do	
	
	// do player inputs
	//if GetKeyboardExists()=1 
		//if platform is PC, check PC controls
		//doSimPC(gamestate)
	//else	
		//if platform is mobile, check mobile controls
		//doSimMobile(gamestate)
	//endif	
	//simulate game
	doSim(gamestate)
	

    Print( ScreenFPS() )

	//print("ship heading " + str(gamestate.ship.heading.x) +"   "+ str(gamestate.ship.heading.x))
	//Print debug
	if debug=1
		print("ship pos " + str(gamestate.ship.position.x)+" "+str(gamestate.ship.position.y))
		print(GetWritePath())
		print (GetScreenBoundsTop()) 
		endif
	//SetClearColor(7,15,51)
    Sync()
loop

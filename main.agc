
// Project: Stardust space game 
// Created: 2017-10-11
// Copyright Richard Beech 2000-2020
// show all errors and stop (1=continue,0=ignore)
SetErrorMode(2)
//Require declaration of vars
#option_explicit
//include code, associated classes are arranged in library folders "l_xxxxxxxx"
#include "setup.agc"
#include "l_utility\debug.agc"
#include "l_asset_manager\mediaconstant.agc"
#include "starfield.agc"
#include "l_asset_manager\medialoader.agc"
#include "l_simulation\simstuff.agc"
#include "l_simulation\spacestation.agc"
#include "l_simulation\gamestate.agc"
#include "l_simulation\particle.agc"
#include "l_interface\interface.agc"
#include "fileops.agc"
#include "l_interface\minimap.agc"
#include "l_math\vector.agc"
#include "l_simulation\ship.agc"
#include "l_network\NetGamePlugin.agc"
#include "l_network\netcode.agc"
#include "chat.agc"
#include "l_math\circle.agc"
//#include "Bezier Curve Library.agc"
//Start debug log

#constant version$ ="0.0.1"
initDebug("Stardust, version " + version$ +" at " +GetCurrentDate() +" "+ GetCurrentTime() )
#constant debug =0
#constant deepdebug =0
global gamestate as gamestate
global ChatEditFocus
//setup screen
setupVideo()
load_font()

//open network
setupNetSession()

login()
//setup planets
//populate_planets()

//load and setup sound and graphics
load_assets(gamestate)

//draw UI
setup_interface()
create_minimap()
gamestate.playerShip.acceleration#=.05
gamestate.playerShip.max_velocity#=1


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
	//print("ship heading " + str(gamestate.playerShip.heading.x) +"   "+ str(gamestate.playerShip.heading.x))
	//Print debug
	if debug=1 and deepdebug=1
		  Print( ScreenFPS() )
		print("ship pos " + str(gamestate.playerShip.position.x)+" "+str(gamestate.playerShip.position.y))
		print(GetWritePath())
		print (GetScreenBoundsTop()) 
		endif
	//SetClearColor(2,5,30)
    Sync()
loop

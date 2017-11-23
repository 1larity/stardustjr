
// Project: Stardust space game 
// Created: 2017-10-11
// Copyright Richard Beech 2000-2020
// show all errors and stop (1=continue,0=ignore)
SetErrorMode(2)
//Require declaration of vars
#option_explicit
//include code...
#include "setup.agc"
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
#include "circle.agc"
//#include "Bezier Curve Library.agc"
#constant debug =0
#constant deepdebug =0
global gamestate as gamestate
global ChatEditFocus
//setup screen
setupVideo()
load_font()

//open network
setupNetSession()

//setup planets
populate_planets()

//load and setup sound and graphics
load_assets(gamestate)

//drwa UI
setup_interface()
create_minimap()
gamestate.playerShip.acceleration#=.05
gamestate.playerShip.max_velocity#=1

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

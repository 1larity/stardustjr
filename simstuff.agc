/****************************************************************/
/*                  NETWORK SERVER PROPERTIES					*/
/****************************************************************/


global  gameStateFile 
Global ChatMessages as string[]
global localNickLabel as integer
global localSprite as integer
global displayGhost as integer
global Tween#
global OwnSpriteColorChosen as integer
global shipAngle# as float
global shipSpeed# as float
global shipAngleFactor# as float
global UseBoost as integer

global carMaxSpeed# as float= 4.0
global networkId
global myClientId
global ServerHost$ as string = "192.168.0.11" // IP Of MikeMax Linux Box for testing :)

global ServerPort as integer=33333
global NetworkLatency as integer = 25 // Should always be less than the NETGAMEPLUGIN_WORLDSTATE_INTERVAL defined in the server plugin

global isScanning as integer=0
global scanStart# as float =0

//do player inputs for touch screen
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
/************************************************************************/
/*                    NETWORK UPDATE CALL								*/
/*                    -------------------								*/
/* VERY IMPORTANT ! Handles All NGP network Events ! (see Events below)	*/
/************************************************************************/
	

	NGP_UpdateNetwork(networkId) 
	
	gamestate.ship.current_turning=3
	doScan(gamestate)
	update_world(gamestate)
		if IsNetworkActive(networkId)
		doNetStuff(gamestate)
	endif
endfunction

function update_world(gamestate REF as gamestate)
	check_refuel()
	check_planet_scan(gamestate)
	positionMiniMap()
	positionButtons()
	positionChat()
	//move_ship(gamestate.ship)
	SetSpritePosition(minimap_player_ship,(GetScreenBoundsRight() - GetSpriteWidth( minimap))+(gamestate.ship.position.x/50),GetScreenBoundsTop()+gamestate.ship.position.y/50)
	//SetSpriteAngle (minimap_player_ship, gamestate.ship.angle# )
	//SetSpritePositionByOffset  ( player_ship, gamestate.ship.position.x, gamestate.ship.position.y )
	//setViewOffset( gamestate.ship.position.x - getVirtualWidth() / 2.0 ,gamestate.ship.position.y - getVirtualHeight() / 2.0  )
	SetSpriteFrame(player_ship,gamestate.ship.current_turning)
	//SetSpriteAngle (player_ship, gamestate.ship.angle# )
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




function doNetStuff(gamestate REF as gamestate)
	//// TWEEN /////////
	FPS# as float
	FPS#=1/GetFrameTime()
	Tween#=60/FPS# // Movements Speed set at 60fps => it's now the reference for Tween Factor.
	//print(str(Tween#))
	
   
        if IsNetworkActive(networkId)
        // if we have not set our ship colour, pick one now
            if not OwnSpriteColorChosen
				SetNetworkLocalInteger(networkId,"colorR",random(50,200))
				SetNetworkLocalInteger(networkId,"colorG",random(50,200))
				SetNetworkLocalInteger(networkId,"colorB",random(50,200))
				OwnSpriteColorChosen = 1
			endif
			
            // print the network details and the details of this client
            
            Print("Keys:  'G' - Switch Ghost display / 'M' - Chat Message / Arrow Keys : Move Car / 'SPACE' : BOOST / 'C' - Change Channel / N - Open/Close Network")
            Print("AGKServer Example App - Network Active")
            //print("FPS : "+str(ScreenFPS()))
			Print("WorldStep Interval Configured : "+ str(WORLD_STEP_MS)+"ms"+" / Local Network Latency Configured : "+str(NetworkLatency)+"ms")
            print("Actual Members in Channel " + str(GetNetworkClientInteger( networkId, myClientId, "SERVER_CHANNEL" ))+" :")
			//Print("Network Clients Detected in Channel : " + Str(clientNum))
            
            //Print("Server Id: " + Str(GetNetworkServerId(networkId)))
            //Print("Client Id: " + Str(myClientId))
            //Print("Client Name: " + GetNetworkClientName(networkId, myClientId))
			id as integer
            id = GetNetworkFirstClient( networkId )
            while id<>0 
				
				
					
					//NGP_NotifyClientConnect(id)
					// Handle Connected client
					you$ as string
					 if id = myClientId then you$="(You)" else you$="" 
					
					print( "- Client ID " + str(id) + " > "+GetNetworkClientName( networkId, id )+" "+you$)
						
					// ignore server ID for display (In Real Life, You should also ignore LocalPlayer => id = myClientId but we want the Server Ghost)
					if id = 1 // or id = myClientId 
						id = GetNetworkNextClient( networkId )
						continue
					endif
					
					
					
					// Update Sprite Color from Client
					SpriteToColorize as integer
					colorR as integer
					colorG as integer
					colorB as integer
						SpriteToColorize = GetNetworkClientUserData( networkId, id, 1)
						colorR=GetNetworkClientInteger(networkId,id,"colorR")
						colorG=GetNetworkClientInteger(networkId,id,"colorG")
						colorB=GetNetworkClientInteger(networkId,id,"colorB")
						AlphaSprite as integer
						if id=myClientId 
							AlphaSprite=150 // This for the ghost !
							SetSpriteColor(player_ship,colorR,colorG,colorB,255) // Colorize Local sprite with full alpha 
							else
							AlphaSprite=255
							
					
						endif
					if SpriteToColorize>0	
					SetSpriteColor(SpriteToColorize,colorR,colorG,colorB,AlphaSprite) // semi transparent if my server ghost or fully opaque if it's another player
					endif
					
				
			id = GetNetworkNextClient( networkId )
			endwhile
          
           
            
        else
            Print("Network Inactive")
        endif
   
   
    // if we are currently connected, give the user the opportunity to leave the network
    if NGP_GetNetworkState() = 1
        Print("")
        Print("Press N Key To Close Network")
    // if we are not currently connected, or trying to connect, give the user the opportunity to join the network
    elseif NGP_GetNetworkState() < 0
        Print("")
        Print("Press N Key To Connect")
    endif




/****************************************************************/
/*                  CAR INPUTS & PHYSICS						*/
/****************************************************************/


	if shipSpeed#>carMaxSpeed# then shipSpeed#=carMaxSpeed#
	if shipSpeed#<-carMaxSpeed# then shipSpeed#=-carMaxSpeed#
	
	// Inertia
	if GetRawKeyState(38)=0 and GetRawKeyState(40)=0 and GetVirtualJoystickY( 1 )=0 and GetJoystickY()=0
		if shipSpeed#>0 then shipSpeed#=shipSpeed#-(0.01* Tween#)
		if shipSpeed#<0 then shipSpeed#=shipSpeed#+(0.01* Tween#)
		if shipSpeed#>-0.02 and shipSpeed#<0.020 then shipSpeed#=0
	endif



	if abs(shipSpeed#)>2.0
		shipAngleFactor# = (3/shipSpeed#) * Tween#
	else
		shipAngleFactor#=12/2
	endif
	print("ClientShipSpeed " +str(shipSpeed#))
	// Send Movements only when Speed != 0 // Calculate the velocity vectors along X,Y with car rotation (shipAngle variable)
	if shipSpeed#<>0 
	
		NGP_SendMovement(networkId, POS_X, 1, (cos(shipAngle#)* Tween#)*shipSpeed#*UseBoost)
		NGP_SendMovement(networkId, POS_Y, 1, (sin(shipAngle#)* Tween#)*shipSpeed#*UseBoost)	
		UseBoost=1	
	endif

	// Keys Movements

	if GetEditBoxHasFocus(chat_edit_text) = 0
			if GetRawKeyState(38) or GetVirtualJoystickY( 1 )<0 or GetJoystickY()<0 // UP
				print("up!")
				shipSpeed#=shipSpeed#+(0.01* Tween#)
			endif
			
			if GetRawKeyState(37) or GetVirtualJoystickX( 1 )<0 or GetJoystickX()<0 // LEFT
				print("left!")
				shipAngle#=shipAngle#-2.0*shipAngleFactor#
				NGP_SendMovement(networkId, ANG_Y, -1,2.0*shipAngleFactor#)
			endif
			
			if GetRawKeyState(39) or GetVirtualJoystickX( 1 )>0 or GetJoystickX()>0 // RIGHT
				print("right!")
				shipAngle#=shipAngle#+2.0*shipAngleFactor#
				NGP_SendMovement(networkId, ANG_Y, 1,2.0*shipAngleFactor#)
			endif
			
			if GetRawKeyState(40) or GetVirtualJoystickY( 1 )>0 or GetJoystickY()>0 // BREAKs / Reverse
				print("down!")
				shipSpeed#=shipSpeed#-(0.01* Tween#)
			endif
			
			if GetRawKeyState(32) // SPACE
				print("Boost !")
				UseBoost=1.5
			endif
	endif	
	
	
/****************************************************************/
/*                  OTHER INPUTS								*/
/****************************************************************/	
 	if GetRawKeyReleased(27) // Escape => Quit
		
		if IsNetworkActive(networkId)
			NGP_CloseNetwork(networkId)
		endif
		
		end
	endif

	
	if GetRawKeyReleased(77) or ( GetPointerState() and  GetPointerX()>360 and GetPointerX()<916 and GetPointerY()>290 and GetPointerY()<505 ) // M => Send new message
		SetTextVisible(chat_header_text,1)
		SetEditBoxVisible(chat_edit_text,1)
		SetEditBoxFocus(chat_edit_text,1)
	endif
	
	if GetEditBoxHasFocus( chat_edit_text ) = 1 and ChatEditFocus = 0
		//We Gain Focus
		ChatEditFocus = 1
	endif
	
	if GetEditBoxHasFocus( chat_edit_text ) = 0 and ChatEditFocus = 1
		//We lost Focus, consider message validation with ENTER
		if len(TrimString(GetEditBoxText(chat_edit_text)," "))>0
				// Add message to local queue
				ChatMessages.insert(GetNetworkClientName(networkId, myClientId)+" : "+GetEditBoxText(chat_edit_text))
				////// Send Message //////
				newMsg as integer
				newMsg=CreateNetworkMessage()
				AddNetworkMessageInteger(newMsg,6800) // Arbitrary server command for Chat Messages
				AddNetworkMessageString(newMsg,GetEditBoxText(chat_edit_text))
				SendNetworkMessage(networkId,0,newMsg) // Send to all clients
		
		endif
		SetEditBoxText(chat_edit_text,"")
		ChatEditFocus = 0
		SetTextVisible(chat_header_text,0)
		SetEditBoxVisible(chat_edit_text,0)
	endif
	
	
		if GetEditBoxHasFocus(chat_edit_text) = 0 // if we are not chatting, capture keys pressed
	
						if GetRawKeyState(187) 
							 NetworkLatency = NetworkLatency+1
							 SetNetworkLatency(networkId,NetworkLatency)
						endif
						
						if GetRawKeyState(189)
							 NetworkLatency = NetworkLatency-1
							  SetNetworkLatency(networkId,NetworkLatency)
						endif
					   
						
						
						
						if GetRawKeyReleased(71) // G to swith Ghost Mode
							
							displayGhost = not displayGhost
							
						endif
					   
						if GetRawKeyReleased(67) // C // Change Channel
							
								SetNetworkLocalInteger( networkId, "SERVER_CHANNEL", val(TextInput("Channel_number?",100,100)) )
						
						endif  
						if GetRawKeyReleased(78) // N // Network connect switch  
							CurrentNetState as integer     
							CurrentNetState=NGP_GetNetworkState()
							
							if CurrentNetState = 1 // if connected
								// disconnect from the network
								NGP_CloseNetwork(networkId)
							elseif CurrentNetState < 0 // if NOT connected
								// join the network
								networkId = NGP_JoinNetwork(ServerHost$,ServerPort, nickname$, NetworkLatency)
							endif
						endif
		endif
    
    //// Update Messages ChatBox
    offset as integer
    offset = ChatMessages.length
    if offset>5 then offset = 5
    ChatBox$ as string
    ChatBox$=""
    i as integer
    for i=ChatMessages.length-offset to ChatMessages.length
		ChatBox$ = ChatBox$ + chr(10) + ChatMessages[i]
	next i
	SetTextString(incoming_chat_text,ChatBox$)
    
    
    
endfunction

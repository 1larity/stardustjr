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
global UseBoost as integer
global ShipMaxSpeed# as float= 2.0
//loop counter for delayng minimap updates
global minimapCounter as integer=5
global isScanning as integer=0
global scanStart# as float =0
global scanCompletion as integer=0
//array to track payout particles
global payoutArray as MyParticle[]
//array to track scrolling text
global textScrollArray as ScrollText[]
//flag to indicate if tenth of a second timer has been triggered this second
global OldRemainder as integer=0
//simulate gameworld
function doSim(gamestate REF as gamestate)
		while gamestate.session.networkId =0
	gamestate.session.networkId = NGP_JoinNetwork(gamestate.session.ServerHost$,gamestate.session.ServerPort, gamestate.session.clientName$ ,gamestate.session.NetworkLatency)
	endwhile
	if IsNetworkActive(gamestate.session.networkId)=1
		doNetStuff()
	endif
	
/************************************************************************/
/*                    NETWORK UPDATE CALL								*/
/*                    -------------------								*/
/* VERY IMPORTANT ! Handles All NGP network Events ! (see Events below)	*/
/************************************************************************/
	

	NGP_UpdateNetwork(gamestate.session.networkId) 

	//assume ship is not turning
	gamestate.playerShip.current_turning=3
	doScan(gamestate)
	update_world(gamestate)
	//once every 50 iterations update minimap
	if minimapCounter=50
		create_minimap()
		positionMiniMap()
		minimapCounter=1
	endif
	minimapCounter=minimapcounter+1
endfunction
/****************************************************************/
/*                  MAIN SIMULATION LOOP 						*/
/****************************************************************/
function update_world(gamestate REF as gamestate)
	// do every world update
	check_refuel()
			//orbit planet around sun
	orbitPlanets()
	positionButtons()
	positionChat()
	//if we have active payout particles, update them
	if payoutArray.length>-1
		updatePayoutParticles()
	endif
	//if we have scrolling text, deal with it
	if textScrollArray.length>-1
		updateScrollText()
		
	endif
	//if we have stations, deal with them
	index as integer
	if gamestate.stations.length>-1
		for index =0 to gamestate.stations.length
			rotatestation(index,.5)
		next
	endif
	scrollStars()	
	
	//stuff we only want to do once every 1/10th of a second
	//calculate tenths of a second
	timer# as float
	remainder as integer
	whole as integer
	timer#=Timer()
	//get whole number of seconds by casting to integer
	whole = timer#
	//subtract seconds from timer giving just the fractions of a second
	timer# = timer#-whole
	remainder = abs(timer#*10)

		
	if remainder  <> OldRemainder
		OldRemainder=remainder //prevent this stuff being execute this tenth of a second
		//we have outstanding payouts, send another gem on its way
		if gamestate.session.bluepayout>0
			newPayoutAnim(1)
			gamestate.session.bluepayout=gamestate.session.bluepayout-1
		endif
		check_planet_scan(gamestate)
	endif
	
	SetSpritePositionByOffset(minimap_player_ship,(GetScreenBoundsRight() - GetSpriteWidth( minimap))+(GetSpriteXByOffset(player_ship)/(gamestate.session.worldSize/20)),GetScreenBoundsTop()+GetSpriteYByOffset(player_ship)/(gamestate.session.worldSize/20))
	SetSpriteAngle (minimap_player_ship, gamestate.playerShip.angle# +90)
	SetSpriteFrame(player_ship,gamestate.playerShip.current_turning)
	//update ui
	SetTextString(co_ords_text,"pos x:"+left(str(gamestate.playerShip.position.x),5)+" y:"+left(str(gamestate.playerShip.position.y),5))
	SetTextString(speed_text,left(str(gamestate.playership.velocity#),5)+"km/s") 
	
endfunction	
/****************************************************************/
//scrolls background stars, might be better to spread out update across several sim loops
/****************************************************************/
function scrollStars()	
	index as integer
  for index = 0 to 500
		
        // move all stars in the opposite direction the ship is traveling
       // SetSpriteX ( index+500, GetSpriteX ( index +500) - gamestate.session.starfieldspeed [ index ] )
       velocity_X as float
       velocity_Y as float
       // calculate the velocity vector from angle and speed
       velocity_X = gamestate.playership.velocity#*cos(gamestate.playership.angle#)
		velocity_Y = gamestate.playership.velocity#*sin(gamestate.playership.angle#)
		SetSpritePosition(500+index, GetSpriteX(index+500)-velocity_X*gamestate.session.starfieldspeed [ index],GetSpriteY(index+500)-velocity_Y*gamestate.session.starfieldspeed [ index])
        // when sprite has left the screen reset it
        if ( GetSpriteX ( index+500 ) < -20 )
        	SetSpritePosition(500+index,120,GetSpriteY(index+500))
        endif
        if ( GetSpriteX ( index+500 ) >120 )
        	SetSpritePosition(500+index,-20,GetSpriteY(index+500))
        endif
                if ( GetSpriteY ( index+500 ) < -20 )
        	SetSpritePosition(500+index,GetSpriteX ( index+500 ),120)
        endif
        if ( GetSpriteY ( index+500 ) >120 )
        	SetSpritePosition(500+index,GetSpriteX ( index+500 ),-20)
        endif
      
    next index
endfunction

//can the ship refuel (colliding with sun sprite)
function check_refuel()
	
	if GetSpriteCollision(player_ship,sun)
		print("refueling")
	endif
endfunction
     
//orbit all planets
function orbitPlanets()
	index as integer
	for index =0 to gamestate.planets.length
		orbit(index)
	next index	
endfunction
            
function check_planet_scan(gamestate REF as gamestate)
	index as integer
	//for every planet
	for index =0 to gamestate.planets.length
		//is ship over planet?
		if GetSpriteCollision(player_ship,index+50)
			print("Scanning planet "+ gamestate.planets[index].name)
			if isScanning=1
				send_scan_tick()
			endif
				scanCompletion=scanCompletion+1
				print("Scan "+ gamestate.planets[index].name+ " success "+str(scanCompletion))
			endif
	next index	
endfunction
//update the orbit of one planet
function orbit(planetIndex)
			newPosition as Vector2D
		centre as Vector2D
		centre.x=gamestate.session.worldsize/2
		centre.y=gamestate.session.worldsize/2
		radius as integer
		radius=gamestate.planets[planetIndex].orbit
		
		angle# as float
		angle#=0
		//get new theta 
		gamestate.planets[planetIndex].angle# = gamestate.planets[planetIndex].angle# + gamestate.planets[planetIndex].angularVelocity#
		//reset any planet over one orbit to start position
		if gamestate.planets[planetIndex].angle# >360
			gamestate.planets[planetIndex].angle#=360-gamestate.planets[planetIndex].angle#
		endif
		newPosition=  nextArcStep(centre,radius , gamestate.planets[planetIndex].angle#)
		gamestate.planets[planetIndex].position=newPosition
		SetSpritePositionByOffset(planetIndex+50,gamestate.planets[planetIndex].position.x,gamestate.planets[planetIndex].position.y)
endfunction
function doScan( gamestate REF as gamestate)
	//only do scan stuff if player has started a scan
	if scanStart# <>0
		//if the scan has completed
		if (Timer() > scanStart#+3)
			scanStart#=0
			isScanning=0
			//scan is complete, reset sucess counter
			scanCompletion=0
			//log with the server that the play has completed scan
			send_end_scan()
			SetSpriteVisible ( scan_wave, 0 )
		//if the scan has not completed
		else
			scanScale# as float
			scanScale#=(Timer()-scanStart#)/10
			print("scanning")
			
			//make scanning sprite visible
			SetSpriteVisible ( scan_wave, 1 )
			//do scaling thing with scan sprite to make it look cooler
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
		//send network message to start scan
		send_start_scan()
	endif
endfunction



/****************************************************************/
/*                  SHIP INPUTS & PHYSICS						*/
/****************************************************************/
function doNetStuff()
	//// TWEEN /////////
	FPS# as float
	FPS#=1/GetFrameTime()
	Tween#=60/FPS# // Movements Speed set at 60fps => it's now the reference for Tween Factor.
	//print(str(Tween#))
        if IsNetworkActive(gamestate.session.networkId)
        // if we have not set our ship colour, pick one now
            if not OwnSpriteColorChosen
				SetNetworkLocalInteger(gamestate.session.networkId,"colorR",random(50,200))
				SetNetworkLocalInteger(gamestate.session.networkId,"colorG",random(50,200))
				SetNetworkLocalInteger(gamestate.session.networkId,"colorB",random(50,200))
				OwnSpriteColorChosen = 1
			endif
            // print the network details and the details of this client
            Print("Server "+ gamestate.session.ServerHost$)
            Print("Keys:  'G' - Switch Ghost display / 'M' - Chat Message / WSAD to steer / 'SPACE' : BOOST ")
            Print("Keys:  'C' - Change Channel / N - Open/Close Network / '+' - increase net latency / '-' - decrease net latency")
            Print("WorldStep: "+ str(WORLD_STEP_MS)+"ms"+" / Local Network Latency: "+str(gamestate.session.NetworkLatency)+"ms")
            print("Actual Members in Channel " + str(GetNetworkClientInteger( gamestate.session.networkId, gamestate.session.myClientId, "SERVER_CHANNEL" ))+" :")
			//Print("Clients in Channel : " + Str(clientNum))
            
            //Print("Server Id: " + Str(GetNetworkServerId(networkId)))
            //Print("Client Id: " + Str(myClientId))
            //Print("Client Name: " + GetNetworkClientName(networkId, myClientId))
			id as integer
            id = GetNetworkFirstClient( gamestate.session.networkId )
            while id<>0 
					//NGP_NotifyClientConnect(id)
					// Handle Connected client
					you$ as string
					 if id = gamestate.session.myClientId then you$="(You)" else you$="" 
					
					print( "- Client ID " + str(id) + " > "+GetNetworkClientName( gamestate.session.networkId, id )+" "+you$)
						
					// ignore server ID for display (In Real Life, You should also ignore LocalPlayer => id = myClientId but we want the Server Ghost)
					if id = 1 // or id = myClientId 
						id = GetNetworkNextClient( gamestate.session.networkId )
						continue
					endif
					
					// Update Sprite Color from Client
					SpriteToColorize as integer
					colorR as integer
					colorG as integer
					colorB as integer
						SpriteToColorize = GetNetworkClientUserData( gamestate.session.networkId, id, 1)
						colorR=GetNetworkClientInteger(gamestate.session.networkId,id,"colorR")
						colorG=GetNetworkClientInteger(gamestate.session.networkId,id,"colorG")
						colorB=GetNetworkClientInteger(gamestate.session.networkId,id,"colorB")
						AlphaSprite as integer
						if id=gamestate.session.myClientId 
							AlphaSprite=150 // This for the ghost !
							SetSpriteColor(player_ship,colorR,colorG,colorB,255) // Colorize Local sprite with full alpha 
							else
							AlphaSprite=255
							
					
						endif
					if SpriteToColorize>0	
					SetSpriteColor(SpriteToColorize,colorR,colorG,colorB,AlphaSprite) // semi transparent if my server ghost or fully opaque if it's another player
					endif
					
				
			id = GetNetworkNextClient( gamestate.session.networkId )
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
/*                  SHIP INPUTS & PHYSICS						*/
/****************************************************************/


	if gamestate.playerShip.velocity#>gamestate.playerShip.max_velocity# then gamestate.playerShip.velocity#=gamestate.playerShip.max_velocity#
	if gamestate.playerShip.velocity#<-gamestate.playerShip.max_velocity# then gamestate.playerShip.velocity#=-gamestate.playerShip.max_velocity#
	
	// Inertia
	if GetRawKeyState(87)=0 and GetRawKeyState(83)=0 and GetVirtualJoystickY( 1 )=0 and GetJoystickY()=0
		if gamestate.playerShip.velocity#>0 then gamestate.playerShip.velocity#=gamestate.playerShip.velocity#-(0.001* Tween#)
		if gamestate.playerShip.velocity#<0 then gamestate.playerShip.velocity#=gamestate.playerShip.velocity#+(0.001* Tween#)
		if gamestate.playerShip.velocity#>-0.04 and gamestate.playerShip.velocity#<0.04 then gamestate.playerShip.velocity#=0
	endif


	//if shipspeed is over 75%
	if abs(gamestate.playerShip.velocity#)>(gamestate.playership.max_velocity#/100)*75
		gamestate.playerShip.turnspeed# = (3/gamestate.playerShip.velocity#) * Tween#
		//change handling
	else
		gamestate.playerShip.turnspeed#=12/2
	endif
	//print("ClientShipSpeed " +str(gamestate.playerShip.velocity#))
	// Send Movements only when Speed != 0 // Calculate the velocity vectors along X,Y with car rotation (shipAngle variable)
	if gamestate.playerShip.velocity#<>0 
	
		NGP_SendMovement(gamestate.session.networkId, POS_X, 1, (cos(gamestate.playerShip.Angle#)* Tween#)*gamestate.playerShip.velocity#*UseBoost)
		NGP_SendMovement(gamestate.session.networkId, POS_Y, 1, (sin(gamestate.playerShip.Angle#)* Tween#)*gamestate.playerShip.velocity#*UseBoost)	
		UseBoost=1	
	endif

	// Keys Movements

	if GetEditBoxHasFocus(chat_edit_text) = 0
			//if "W" or Joystick down is pressed, speed up
			if GetRawKeyState(87) or GetVirtualJoystickY( 1 )<-0.2 or GetJoystickY()<-0.2 // UP
				//print("up!")
				gamestate.playerShip.velocity#=gamestate.playerShip.velocity#+(0.01* Tween#)

			endif
			//if "A" or Joystick left is pressed, turn left
			if GetRawKeyState(65) or GetVirtualJoystickX( 1 )<-0.2 or GetJoystickX()<-0.2 // LEFT
				//print("left!")
				gamestate.playerShip.current_turning=1
				gamestate.playerShip.Angle#=gamestate.playerShip.Angle#-2.0*gamestate.playerShip.turnspeed#
				NGP_SendMovement(gamestate.session.networkId, ANG_Y, -1,2.0*gamestate.playerShip.turnspeed#)
			endif
			//if "D" or Joystick right is pressed, turn right
			if GetRawKeyState(68) or GetVirtualJoystickX( 1 )>0.2 or GetJoystickX()>0.2 // RIGHT
				//print("right!")
				gamestate.playerShip.current_turning=5
				gamestate.playerShip.Angle#=gamestate.playerShip.Angle#+2.0*gamestate.playerShip.turnspeed#
				NGP_SendMovement(gamestate.session.networkId, ANG_Y, 1,2.0*gamestate.playerShip.turnspeed#)
			endif
			//if "S" or Joystick down is pressed, slow down
			if GetRawKeyState(83) or GetVirtualJoystickY( 1 )>0.2 or GetJoystickY()>0.2 // BREAKs / Reverse
				//print("down!")
				gamestate.playerShip.velocity#=gamestate.playerShip.velocity#-(0.01* Tween#)

			endif
			
			if GetRawKeyState(32) // SPACE
				//print("Boost !")
				UseBoost=1.5
			endif
			
	endif	
	
	if GetEditBoxHasFocus( chat_edit_text ) = 1 and ChatEditFocus = 0
		//We Gain Focus
		ChatEditFocus = 1
	endif
	
	if GetEditBoxHasFocus( chat_edit_text ) = 0 and ChatEditFocus = 1
		//We lost Focus, consider message validation with ENTER
		if len(TrimString(GetEditBoxText(chat_edit_text)," "))>0
				// Add message to local queue
				ChatMessages.insert(GetNetworkClientName(gamestate.session.networkId, gamestate.session.myClientId)+" : "+GetEditBoxText(chat_edit_text))
				////// Send Message //////
				newMsg as integer
				newMsg=CreateNetworkMessage()
				AddNetworkMessageInteger(newMsg,6800) // Arbitrary server command for Chat Messages
				AddNetworkMessageString(newMsg,GetEditBoxText(chat_edit_text))
				SendNetworkMessage(gamestate.session.networkId,0,newMsg) // Send to all clients
		
		endif
		SetEditBoxText(chat_edit_text,"")
		ChatEditFocus = 0
		SetTextVisible(chat_header_text,0)
		SetEditBoxVisible(chat_edit_text,0)
	endif
	
	
		if GetEditBoxHasFocus(chat_edit_text) = 0 // if we are not chatting, capture keys pressed		
			detectKeys()
		endif
	//check virtual buttons for input
     virtualInput()
    //// Update Messages ChatBox
    offset as integer
    offset = ChatMessages.length
    if offset>5 then offset = 5
    ChatBox$ as string
    ChatBox$=""
    i as integer
    for i=ChatMessages.length-offset to ChatMessages.length
		ChatBox$ = ChatBox$ +  ChatMessages[i]+chr(10)
	next i
	SetEditBoxText(incoming_chat_text,ChatBox$)
endfunction
/****************************************************************/
/*                 KEYBOARD INPUTS  							*/
/****************************************************************/	
function detectKeys()
	// if Escape, Quit
 	if GetRawKeyReleased(27) 
		if IsNetworkActive(gamestate.session.networkId)
			NGP_CloseNetwork(gamestate.session.networkId)
		endif
		end
	endif
	 // if "M" Send new message
	if GetRawKeyReleased(77) or ( GetPointerState() and  GetPointerX()>360 and GetPointerX()<916 and GetPointerY()>290 and GetPointerY()<505 )
		//make chatbo visible
		SetEditBoxVisible(incoming_chat_text,1)
		SetTextVisible(chat_header_text,1)
		SetEditBoxVisible(chat_edit_text,1)
		SetEditBoxFocus(chat_edit_text,1)
	endif
	// if "+" pressed increase latency
	if GetRawKeyState(187) 
		gamestate.session.NetworkLatency = gamestate.session.NetworkLatency+1
		SetNetworkLatency(gamestate.session.networkId,gamestate.session.NetworkLatency)
	endif
	// if "-" pressed decrease latency
	if GetRawKeyState(189)
		gamestate.session.NetworkLatency = gamestate.session.NetworkLatency-1
		SetNetworkLatency(gamestate.session.networkId,gamestate.session.NetworkLatency)
	endif
	// if "G" pressed toggle Ghost Mode
	if GetRawKeyReleased(71) 
		displayGhost = not displayGhost
	endif
	// if "C"  Change Channel
	if GetRawKeyReleased(67) 
		channelNumber$ as string
		channelNumber$ = TextInput("Channel_number?",GetScreenBoundsleft()+20,GetScreenBoundsBottom()-50)
		SetNetworkLocalInteger( gamestate.session.networkId, "SERVER_CHANNEL", val(channelNumber$)) 
	endif
	//if enter pressed start scan
	if GetRawKeyReleased(13)
		startScan(gamestate)
	endif
	// if "N" Network connect switch  
	if GetRawKeyReleased(78) 
		    
		CurrentNetState=NGP_GetNetworkState()
		if CurrentNetState = 1 // if connected
			// disconnect from the network
			NGP_CloseNetwork(gamestate.session.networkId)
		elseif CurrentNetState < 0 // if NOT connected
			// join the network
		gamestate.session.networkId = NGP_JoinNetwork(gamestate.session.ServerHost$,gamestate.session.ServerPort, gamestate.session.clientName$, gamestate.session.NetworkLatency)
		
		endif
	endif
endfunction
/****************************************************************/
/*                 VIRTUAL BUTTON INPUTS 						*/
/****************************************************************/	
function virtualInput()
	
	if GetVirtualButtonPressed(1)=1
		startScan(gamestate)
	endif
	if GetVirtualButtonPressed(2)=1
		saveMap( "testsave.ded", gamestate )
	endif
		if GetVirtualButtonPressed(3)=1
		gamestate=loadMap( "testsave.ded" )
	endif
	//arbitary test button!
	if GetVirtualButtonPressed(4)=1
		newPayoutAnim(Random(1,3))
		newScrollingText("testScrolling text!" )
	
		//spriteLinearMove(start , endpoint , payCrystal )
		//for index=0 to linelength
			
	endif
endfunction



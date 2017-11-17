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
global ShipMaxSpeed# as float= 4.0
global networkId
global isScanning as integer=0
global scanStart# as float =0


//simulate gameworld
function doSim(gamestate REF as gamestate)
/************************************************************************/
/*                    NETWORK UPDATE CALL								*/
/*                    -------------------								*/
/* VERY IMPORTANT ! Handles All NGP network Events ! (see Events below)	*/
/************************************************************************/
	

	NGP_UpdateNetwork(networkId) 
	//assume ship is not turning
	gamestate.playerShip.current_turning=3
	doScan(gamestate)
	update_world(gamestate)
		if IsNetworkActive(networkId)
		doNetStuff()
	endif
endfunction

function update_world(gamestate REF as gamestate)
	check_refuel()
	check_planet_scan(gamestate)
	positionMiniMap()
	positionButtons()
	positionChat()
	//move_ship(gamestate.playerShip)
	SetSpritePosition(minimap_player_ship,(GetScreenBoundsRight() - GetSpriteWidth( minimap))+(gamestate.playerShip.position.x/50),GetScreenBoundsTop()+gamestate.playerShip.position.y/50)
	SetSpriteAngle (minimap_player_ship, gamestate.playerShip.angle# +90)
	//SetSpritePositionByOffset  ( player_ship, gamestate.playerShip.position.x, gamestate.playerShip.position.y )
	//setViewOffset( gamestate.playerShip.position.x - getVirtualWidth() / 2.0 ,gamestate.playerShip.position.y - getVirtualHeight() / 2.0  )
	SetSpriteFrame(player_ship,gamestate.playerShip.current_turning)
	//SetSpriteAngle (player_ship, gamestate.playerShip.angle# )
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
			discoverNumber(gamestate.playerShip.position)
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



/****************************************************************/
/*                  SHIP INPUTS & PHYSICS						*/
/****************************************************************/
function doNetStuff()
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
             
            Print("Keys:  'G' - Switch Ghost display / 'M' - Chat Message / WSAD to steer / 'SPACE' : BOOST ")
            Print("Keys:  'C' - Change Channel / N - Open/Close Network / '+' - increase net latency / '-' - decrease net latency")
            Print("WorldStep: "+ str(WORLD_STEP_MS)+"ms"+" / Local Network Latency: "+str(gamestate.session.NetworkLatency)+"ms")
            print("Actual Members in Channel " + str(GetNetworkClientInteger( networkId, gamestate.session.myClientId, "SERVER_CHANNEL" ))+" :")
			//Print("Clients in Channel : " + Str(clientNum))
            
            //Print("Server Id: " + Str(GetNetworkServerId(networkId)))
            //Print("Client Id: " + Str(myClientId))
            //Print("Client Name: " + GetNetworkClientName(networkId, myClientId))
			id as integer
            id = GetNetworkFirstClient( networkId )
            while id<>0 
					//NGP_NotifyClientConnect(id)
					// Handle Connected client
					you$ as string
					 if id = gamestate.session.myClientId then you$="(You)" else you$="" 
					
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
						if id=gamestate.session.myClientId 
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
/*                  SHIP INPUTS & PHYSICS						*/
/****************************************************************/


	if gamestate.playerShip.velocity#>ShipMaxSpeed# then gamestate.playerShip.velocity#=ShipMaxSpeed#
	if gamestate.playerShip.velocity#<-ShipMaxSpeed# then gamestate.playerShip.velocity#=-ShipMaxSpeed#
	
	// Inertia
	if GetRawKeyState(87)=0 and GetRawKeyState(83)=0 and GetVirtualJoystickY( 1 )=0 and GetJoystickY()=0
		if gamestate.playerShip.velocity#>0 then gamestate.playerShip.velocity#=gamestate.playerShip.velocity#-(0.01* Tween#)
		if gamestate.playerShip.velocity#<0 then gamestate.playerShip.velocity#=gamestate.playerShip.velocity#+(0.01* Tween#)
		if gamestate.playerShip.velocity#>-0.02 and gamestate.playerShip.velocity#<0.020 then gamestate.playerShip.velocity#=0
	endif



	if abs(gamestate.playerShip.velocity#)>2.0
		gamestate.playerShip.turnspeed# = (3/gamestate.playerShip.velocity#) * Tween#
	else
		gamestate.playerShip.turnspeed#=12/2
	endif
	print("ClientShipSpeed " +str(gamestate.playerShip.velocity#))
	// Send Movements only when Speed != 0 // Calculate the velocity vectors along X,Y with car rotation (shipAngle variable)
	if gamestate.playerShip.velocity#<>0 
	
		NGP_SendMovement(networkId, POS_X, 1, (cos(gamestate.playerShip.Angle#)* Tween#)*gamestate.playerShip.velocity#*UseBoost)
		NGP_SendMovement(networkId, POS_Y, 1, (sin(gamestate.playerShip.Angle#)* Tween#)*gamestate.playerShip.velocity#*UseBoost)	
		UseBoost=1	
	endif

	// Keys Movements

	if GetEditBoxHasFocus(chat_edit_text) = 0
			//if "W" or Joystick down is pressed, speed up
			if GetRawKeyState(87) or GetVirtualJoystickY( 1 )<0 or GetJoystickY()<0 // UP
				print("up!")
				gamestate.playerShip.velocity#=gamestate.playerShip.velocity#+(0.01* Tween#)

			endif
			//if "A" or Joystick left is pressed, turn left
			if GetRawKeyState(65) or GetVirtualJoystickX( 1 )<0 or GetJoystickX()<0 // LEFT
				print("left!")
				gamestate.playerShip.Angle#=gamestate.playerShip.Angle#-2.0*gamestate.playerShip.turnspeed#
				NGP_SendMovement(networkId, ANG_Y, -1,2.0*gamestate.playerShip.turnspeed#)
			endif
			//if "D" or Joystick right is pressed, turn right
			if GetRawKeyState(68) or GetVirtualJoystickX( 1 )>0 or GetJoystickX()>0 // RIGHT
				print("right!")
				gamestate.playerShip.Angle#=gamestate.playerShip.Angle#+2.0*gamestate.playerShip.turnspeed#
				NGP_SendMovement(networkId, ANG_Y, 1,2.0*gamestate.playerShip.turnspeed#)
			endif
			//if "S" or Joystick down is pressed, slow down
			if GetRawKeyState(83) or GetVirtualJoystickY( 1 )>0 or GetJoystickY()>0 // BREAKs / Reverse
				print("down!")
				gamestate.playerShip.velocity#=gamestate.playerShip.velocity#-(0.01* Tween#)

			endif
			
			if GetRawKeyState(32) // SPACE
				print("Boost !")
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
				ChatMessages.insert(GetNetworkClientName(networkId, gamestate.session.myClientId)+" : "+GetEditBoxText(chat_edit_text))
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
		ChatBox$ = ChatBox$ + chr(10) + ChatMessages[i]
	next i
	SetTextString(incoming_chat_text,ChatBox$)
endfunction
/****************************************************************/
/*                 KEYBOARD INPUTS  							*/
/****************************************************************/	
function detectKeys()
	// if Escape, Quit
 	if GetRawKeyReleased(27) 
		if IsNetworkActive(networkId)
			NGP_CloseNetwork(networkId)
		endif
		end
	endif
	 // if "M" Send new message
	if GetRawKeyReleased(77) or ( GetPointerState() and  GetPointerX()>360 and GetPointerX()<916 and GetPointerY()>290 and GetPointerY()<505 )
		//make chatbo visible
		SetTextVisible(chat_header_text,1)
		SetEditBoxVisible(chat_edit_text,1)
		SetEditBoxFocus(chat_edit_text,1)
	endif
	// if "+" pressed increase latency
	if GetRawKeyState(187) 
		gamestate.session.NetworkLatency = gamestate.session.NetworkLatency+1
		SetNetworkLatency(networkId,gamestate.session.NetworkLatency)
	endif
	// if "-" pressed decrease latency
	if GetRawKeyState(189)
		gamestate.session.NetworkLatency = gamestate.session.NetworkLatency-1
		SetNetworkLatency(networkId,gamestate.session.NetworkLatency)
	endif
	// if "G" pressed toggle Ghost Mode
	if GetRawKeyReleased(71) 
		displayGhost = not displayGhost
	endif
	// if "C"  Change Channel
	if GetRawKeyReleased(67) 
		SetNetworkLocalInteger( networkId, "SERVER_CHANNEL", val(TextInput("Channel_number?",100,100)) )
	endif  
	// if "N" Network connect switch  
	if GetRawKeyReleased(78) 
		CurrentNetState as integer     
		CurrentNetState=NGP_GetNetworkState()
		if CurrentNetState = 1 // if connected
			// disconnect from the network
			NGP_CloseNetwork(networkId)
		elseif CurrentNetState < 0 // if NOT connected
			// join the network
		networkId = NGP_JoinNetwork(gamestate.session.ServerHost$,gamestate.session.ServerPort, gamestate.session.clientName$, gamestate.session.NetworkLatency)
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
endfunction

/******************************************************/
/*                   Networking code                  */
/*deal with forming and controlling network connections*/
/*intercept network events and act on them. Encode/decode*/
/* network message IDs to resolve specific command types*/
/******************************************************/
//set up minimum networking
function setupNetSession()
	nickname$ as string
	//get player name
	 //-20,GetScreenBoundsBottom()-20
	if debug=0
		nickname$ = TextInput("FirstPlayer",GetScreenBoundsleft()+20,GetScreenBoundsBottom()-50)
	else
		nickname$ = TextInput("FirstPlayer",GetScreenBoundsleft()+20,GetScreenBoundsBottom()-50)
	endif	
	//gamestate.session.ServerHost$ = "192.168.0.6" // IP Of LAN
	//gamestate.session.ServerHost$ = "82.7.176.97" // IP Of WAN
	gamestate.session.ServerHost$ = "52.56.171.217" // IP Of AWS
	gamestate.session.ServerPort =33333
	gamestate.session.NetworkLatency = 50 // Should always be less than the NETGAMEPLUGIN_WORLDSTATE_INTERVAL defined in the server plugin
	gamestate.session.clientName$=nickname$
	gamestate.session.worldSize=2000
	while gamestate.session.networkId =0
	gamestate.session.networkId = NGP_JoinNetwork(gamestate.session.ServerHost$,gamestate.session.ServerPort, gamestate.session.clientName$ ,gamestate.session.NetworkLatency)
	endwhile
CurrentNetState =1 
endfunction

function login()
	writeDebug("logging in")
	gamestate.session.loggedIn=0
	while gamestate.session.loggedIn=0
		print ("waiting for login")
		sync()
		NGP_UpdateNetwork(gamestate.session.networkId) 
	endwhile
	if gamestate.session.loggedIn=2
		//create_new_user()
	endif	
		if gamestate.session.loggedIn=1
		welcome_known_user()
	endif	
endfunction

function welcome_known_user()
	welcomeMessage as integer
	createSDtext(welcomeMessage,"Welcome back to Stardust"+gamestate.session.clientName$,50,50)
	SetTextAlignment(welcomeMessage,ACENTRE)
	sync()
	sleep(3000)
	DeleteText(welcomeMessage)
endfunction

// when a scan is in progress send scanner "ticks"
function send_scan_tick()
	newMsg as integer
	newMsg=CreateNetworkMessage()
	AddNetworkMessageInteger(newMsg,9004) // server command for earnings report
	AddNetworkMessageInteger(newMsg,1) //send the quantity of tick (so we can just add them up on serverside to value scan)
	SendNetworkMessage(gamestate.session.networkId,1,newMsg) // Send to server
				
endfunction

// when a scan is started, send  start time to server
function send_start_scan()
	newMsg as integer
	time as integer 
	time=GetUnixTime() 
	newMsg=CreateNetworkMessage()
	AddNetworkMessageInteger(newMsg,9003) // server command for earnings report
	AddNetworkMessageInteger(newMsg,time)//send the the start time of scan
	SendNetworkMessage(gamestate.session.networkId,1,newMsg) // Send to server	
endfunction

// when a scan is complete, send  end time to server
function send_end_scan()
	newMsg as integer
	time as integer 
	time=GetUnixTime() 
	newMsg=CreateNetworkMessage()
	AddNetworkMessageInteger(newMsg,9005) // server command for earnings report
	AddNetworkMessageInteger(newMsg,time)//send the the end time of scan
	SendNetworkMessage(gamestate.session.networkId,1,newMsg) // Send to server	
endfunction
/******************************************************/
/* When local client has disconnected from the server */
/******************************************************/
function NGP_onNetworkClosed(iNetID)
	//destroyChatBox()
	//DeleteAllSprites()
	//DeleteAllText()
endfunction
/*******************************************/
/* When local client has joined the server */
/*******************************************/
function NGP_onNetworkJoined(iNetID, localClientID)
	gamestate.session.myClientId=localClientID
	OwnSpriteColorChosen=0
	//createChatBox()
	//CreateLocalShipSprite() // Create local direct sprite for the local client 
endfunction

function destroyChatBox()
	DeleteEditBox(chat_edit_text)
	DeleteText(chat_header_text)
	DeleteText(incoming_chat_text)
endfunction



/********************************************************************************************************************************/
/* When a network message Arrived (associated with a Server Command already consumed inside idMessage)							*/
/* This does not include Move updates which are handles internally by NGP 														*/
/* (see these other specific events : NGP_onNetworkPlayerMoveUpdate, NGP_onLocalPlayerMoveUpdate) 								*/
/********************************************************************************************************************************/
function NGP_onNetworkMessage(ServerCommand as integer,idMessage as integer)
	
	// do anything here
	
	if ServerCommand = 6800 // It's a chat message !
						//message("ok")
						NewChatMessage$ as String
						SenderName$ as string
						NewChatMessage$ = GetNetworkMessageString(idMessage)
						SenderName$ = GetNetworkClientName(gamestate.session.networkId, GetNetworkMessageFromClient(idMessage))
						ChatMessages.insert( SenderName$+" : "+NewChatMessage$) // Add message to Messages array
						if ChatMessages.length>100 then ChatMessages.remove(0) // Do some cleaning
	endif
	if ServerCommand = 9000 // It's a worlddata filename message !
						//message("ok")
						fileName$ as string
						fileName$ = GetNetworkMessageString(idMessage)
						saveServerMap(fileName$)
						
	endif
		if ServerCommand = 9001 // It's a solarsystem message !
						newPlanet as planet
						newplanet.name=GetNetworkMessageString(idMessage)
						newplanet.orbit=GetNetworkMessageInteger(idMessage)
						newplanet.angularVelocity#=GetNetworkMessageFloat(idMessage)
						newplanet.position.x=GetNetworkMessageFloat(idMessage)
						newplanet.position.y=GetNetworkMessageFloat(idMessage)
						newplanet.angle#=GetNetworkMessageFloat(idMessage)
						newplanet.planetID=GetNetworkMessageInteger(idMessage)
						
						newplanet.planet_type=Random(1,2)
						newplanet.size# = Random(5,7)/75.0
						gamestate.planets.insert(newPlanet)
						writeDebug(newPlanet.name+" "+str(newPlanet.angle#)+" "+str(newPlanet.planetID))
						
						//message("ok")
						//mapData$ as string
						//mapData$ = GetNetworkMessageString(idMessage)
						//WriteMapData(mapData$)
						
	endif
		if ServerCommand = 9002 // It's a planet orbit update!
						planetID as integer
						planetID =GetNetworkMessageInteger(idMessage)
						
						index as integer
						for index = 0 to gamestate.planets.length
							if gamestate.planets[index].planetID=planetID
								gamestate.planets[index].oldposition.x=gamestate.planets[index].position.x
								gamestate.planets[index].oldposition.y=gamestate.planets[index].position.y
								gamestate.planets[index].position.x=GetNetworkMessageFloat(idMessage)
								gamestate.planets[index].position.y=GetNetworkMessageFloat(idMessage)
								gamestate.session.lastplanetupdate =0	
							endif
						next index
					
	endif
	if ServerCommand = 9006 // if its message 9006 its an earnings message.
						//message("ok")
						value as integer
						value = GetNetworkMessageInteger(idMessage)
						recieveEarnings(value)
						
	endif
	if ServerCommand = 9007 // if its message 9007 its characterdata message.
		
				//message("ok")
				//set gamestate character data to match server data
				gamestate.session.characterFirstname = GetNetworkMessageString(idMessage)
				gamestate.session.characterSurname = GetNetworkMessageString(idMessage)
				gamestate.playerShip.position.x = GetNetworkMessageInteger(idMessage)
				gamestate.playerShip.position.y = GetNetworkMessageInteger(idMessage)
				gamestate.session.blueCredits = GetNetworkMessageInteger(idMessage)
				gamestate.session.redCredits = GetNetworkMessageInteger(idMessage)
				gamestate.session.greenCredits = GetNetworkMessageInteger(idMessage)
				writeDebug("Character loaded, pos "+str(gamestate.playerShip.position.x) +"y "+str(gamestate.playerShip.position.y))	
	endif
	if ServerCommand = 9008 // if its message 9008 its system data message.
				sysx as integer
				sysy as integer
				sysz as integer
				//message("ok")
				//set gamestate character data to match server data

				gamestate.session.systemname$ = GetNetworkMessageString(idMessage)
				sysx = GetNetworkMessageInteger(idMessage)
				sysy = GetNetworkMessageInteger(idMessage)
				sysz = GetNetworkMessageInteger(idMessage)
			
				writeDebug("system "+gamestate.session.systemname$ +"system co-ords "+str(sysx)+" "+str(sysy)+" "+str(sysz))	
	endif
	if ServerCommand = 9009 // if its message 9008 its a login message.
		welcomeMessage$ as String
		welcomeMessage$=GetNetworkMessageString(idMessage)
		if welcomeMessage$="Unknown user"
			gamestate.session.loggedIn=2
			writeDebug("Not logged in, no account")
		endif
		if welcomeMessage$="Welcome Back"
			gamestate.session.loggedIn=1
			writeDebug("Logged in successfully")
		endif
	endif
endfunction

/********************************************************************************************************************************/
/* 	Save functions for saving server side solarsytem data                                                         				*/
/********************************************************************************************************************************/

//Open Solar system mapfile for writing
function saveServerMap( filename$  )
	
	gameStateFile = OpenToWrite( filename$ )	 
endfunction 

function writeMapData( data$ as string)
	WriteLine(gameStateFile,data$)
endfunction

function closeMapFile()
	CloseFile (gameStateFile)
endfunction



/********************************************************************************/
/* When the local client has moved (After Prediction and Server Reconciliation) */ 
/********************************************************************************/
function NGP_onLocalPlayerMoveUpdate(iNetID, UpdatedMove as NGP_Slot)
	if gamestate.session.loggedIn=1
	gamestate.playership.position.x= UpdatedMove.Slot[POS_X] 
	gamestate.playership.position.y= UpdatedMove.Slot[POS_Y] 

	endif
endfunction


/**********************************************************/
/* When a client has moved (After internal interpolation) */ 
/**********************************************************/
function NGP_onNetworkPlayerMoveUpdate(iNetID, ClientID as integer, UpdatedMove as NGP_Slot)
if gamestate.session.loggedin=1	 
		SpriteID as integer
		LabelID as integer
		SpriteID = GetNetworkClientUserData( iNetID, ClientID, 1)
		LabelID = GetNetworkClientUserData( iNetID, ClientID, 2)
		SetSpritePositionByOffset(SpriteID,UpdatedMove.Slot[POS_X] ,UpdatedMove.Slot[POS_Y])	
		SetSpriteAngle(SpriteID,UpdatedMove.Slot[ANG_Y]+90)
		
		SetTextPosition(LabelID,UpdatedMove.Slot[POS_X] ,UpdatedMove.Slot[POS_Y]-10)
		SetTextSize(LabelID,5)
		SetTextFont(LabelID,main_font)
		if ClientID = gamestate.session.myClientId   
			 
			 // Hide Ghost Sprite and TextLabel
			 SetSpriteVisible(SpriteID,displayGhost) // <-- Key "G" to switch displayGhost
			 SetTextVisible(LabelID,displayGhost) // <-- Key "G" to switch displayGhost		
		endif	
		endif
endfunction
/************************************************************************/
/* When a client has disconnected from the server (or "server channel") */ 
/************************************************************************/
function NGP_onNetworkPlayerDisconnect(iNetID, ClientID)
//PlaySound(QuitSound)
		// Delete Player Sprite
		SpriteToDelete as integer
		SpriteToDelete = GetNetworkClientUserData( iNetID, ClientID, 1)
		DeleteSprite(SpriteToDelete)
		SetNetworkClientUserData(iNetID, ClientID, 1, 0)
		// Delete Player Text Label
		TextToDelete as integer
		TextToDelete = GetNetworkClientUserData( iNetID, ClientID, 2)
		DeleteText(TextToDelete)
		SetNetworkClientUserData(iNetID, ClientID, 2, 0)
		

endfunction
/*************************************************************************************************************************************/
/* When a client has joined the server (includes the local client himself, comparable to the "NGP_onNetworkJoined" for local client) */
/*************************************************************************************************************************************/
function NGP_onNetworkPlayerConnect(iNetID, ClientID)

if gamestate.session.loggedin=1	 
	//PlaySound(JoinSound)


		if ClientID = 1 then exitfunction // Ignore Server Join (we only want players !)
	
	if GetImageExists(player_ship ) =0
		LoadImage ( player_ship, "ship01.png" )
	endif
	////// Create Sprite for New Client
	//Message("Client ID "+str(ClientID)+" has joined")
	newSprite as integer
		newSprite=CreateSprite(player_ship)
			SetSpriteAnimation(newSprite,500,300,5)
			SetSpriteDepth(newSprite,1)
			SetSpriteOffset( newSprite, GetSpriteWidth(newSprite)/2, GetSpriteHeight(newSprite)/2 ) 
			SetSpriteScale(newSprite,0.02,0.02) 
endif
		// Affect the sprite ID to the ClientID at UserData Slot 1
		SetNetworkClientUserData(iNetID, ClientID, 1, newSprite)
		
	////// Creating a Text on the sprite
		TextToShow$ as string
		// Choosing Text to show
		if ClientID = gamestate.session.myClientId
			TextToShow$ = "Network GHOST" 
		else
			TextToShow$ = GetNetworkClientName( iNetID, ClientID )
		endif
		newNickLabel as integer
		newNickLabel = CreateText(TextToShow$)
		SetTextAlignment( newNickLabel, 1 )
		SetTextSize(newNickLabel,2)
		// Affect the Text ID to the ClientID at UserData Slot 1
		SetNetworkClientUserData(iNetID, ClientID, 2, newNickLabel)

endfunction

/******************************************************/
/*                   Networking code                  */
/*deal with forming and controlling network connections*/
/*intercept network events and act on them. Encode/decode*/
/* network message IDs to resolve specific command types*/
/******************************************************/
//set up minimum 
function setupNetSession()
	nickname$ as string
	//get player name
	 //-20,GetScreenBoundsBottom()-20
	nickname$ = TextInput("EnterName"+right(str(GetMilliseconds()),3),GetScreenBoundsleft()+20,GetScreenBoundsBottom()-50)
	gamestate.session.ServerHost$ = "192.168.0.6" // IP Of MikeMax Linux Box for testing :)
	gamestate.session.ServerPort =33333
	gamestate.session.NetworkLatency = 25 // Should always be less than the NETGAMEPLUGIN_WORLDSTATE_INTERVAL defined in the server plugin
	gamestate.session.clientName$=nickname$
	gamestate.session.networkId = NGP_JoinNetwork(gamestate.session.ServerHost$,gamestate.session.ServerPort, gamestate.session.clientName$ ,gamestate.session.NetworkLatency)
	gamestate.session.worldSize=2000
CurrentNetState =1 
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
		if ServerCommand = 9001 // It's a worlddata message !
						//message("ok")
						mapData$ as string
						mapData$ = GetNetworkMessageString(idMessage)
						WriteMapData(mapData$)
						
	endif
		if ServerCommand = 9002 // It's an end of worlddata message !
						closeMapFile()
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
	Print("server co-ord "+ str(UpdatedMove.Slot[POS_X]) +" "+str(UpdatedMove.Slot[POS_Y]))
	gamestate.playership.position.x= UpdatedMove.Slot[POS_X] 
	gamestate.playership.position.y= UpdatedMove.Slot[POS_Y] 
	SetSpritePositionByOffset(player_ship,UpdatedMove.Slot[POS_X] ,UpdatedMove.Slot[POS_Y])
	setViewOffset( UpdatedMove.Slot[POS_X] - getVirtualWidth() / 2.0 ,UpdatedMove.Slot[POS_Y] - getVirtualHeight() / 2.0  )
	SetSpriteAngle(player_ship,UpdatedMove.Slot[ANG_Y]+90)
	SetTextPosition(localNickLabel,UpdatedMove.Slot[POS_X] ,UpdatedMove.Slot[POS_Y]-10)	
		
endfunction


/**********************************************************/
/* When a client has moved (After internal interpolation) */ 
/**********************************************************/
function NGP_onNetworkPlayerMoveUpdate(iNetID, ClientID as integer, UpdatedMove as NGP_Slot)

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

	
	//PlaySound(JoinSound)


		if ClientID = 1 then exitfunction // Ignore Server Join (we only want players !)

	////// Create Sprite for New Client
	//Message("Client ID "+str(ClientID)+" has joined")
		newSprite as integer
		newSprite=CreateSprite(player_ship)
			SetSpriteAnimation(newSprite,500,300,5)
			SetSpriteDepth(newSprite,1)
			SetSpriteOffset( newSprite, GetSpriteWidth(newSprite)/2, GetSpriteHeight(newSprite)/2 ) 
			SetSpriteScale(newSprite,0.04,0.04) 

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
		SetTextSize(newNickLabel,25)
		// Affect the Text ID to the ClientID at UserData Slot 1
		SetNetworkClientUserData(iNetID, ClientID, 2, newNickLabel)

endfunction

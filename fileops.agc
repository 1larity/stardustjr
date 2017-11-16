// functions for filehandling
//load game
function loadMap( filename$ )
	MapFile as integer
	MapFile = OpenToRead( filename$ )
	JSON$ as string= ""
	JSON$=ReadString(MapFile)
	gameState as gamestate
	gameState.fromJSON( JSON$ )
endfunction gameState
//save game
function saveMap( filename$, gamestate as gamestate)
	gameStateFile as integer
	gameStateFile = OpenToWrite( filename$ )
	JSON$ as string = ""
	JSON$=gamestate.toJSON()
	writeString(gameStateFile, JSON$)
	CloseFile (gameStateFile) 
endfunction

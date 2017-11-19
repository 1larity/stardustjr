//stuff for loading assets

//main asset load loop
function load_assets (gamestate REF as gamestate)
	// generate mipmaps for loaded images
	SetGenerateMipmaps(1)
	load_stars(gamestate)
	load_sun(gamestate)
	//create minimap, all screen elements rendered prior are displayed
	
	load_music()
	load_minimap_ship()
	CreateLocalShipSprite() // Create local direct sprite for the local client 
	load_scan()
	load_particles()
	
endfunction

function load_particles()
	LoadImage(6,"funstar.png")
	CreateParticles ( discoveryParticles, -1000, -1000 )
endfunction

function load_station(gamestate REF as gamestate)

	LoadImage (stationPart01, "stationPart01.png")
	LoadImage (stationPart02, "stationPart02.png")
	
	CreateSprite (stationPart02,stationPart02)
	index as integer
	for index=0 to 3
		CreateSprite (stationPart01+index,stationPart01)
		SetSpriteAngle(stationPart01+index,index*90)
	next index
endfunction

//setup playr minimap sprite
function load_minimap_ship()
	LoadImage (minimap_player_ship, "minimap_ship.png")
	//minimap sprite
	CreateSprite (minimap_player_ship,minimap_player_ship)
	SetSpriteScale(minimap_player_ship,0.04,0.04) 
	SetSpriteDepth(minimap_player_ship,1)
	FixSpriteToScreen(minimap_player_ship,1)
endfunction

//setup player ship sprite
function CreateLocalShipSprite()
	// Local Player Sprite
	LoadImage ( player_ship, "ship01.png" )
	CreateSprite(player_ship,player_ship)
	SetSpriteAnimation(player_ship,500,300,5)
	SetSpriteDepth(player_ship,1)
		
	//set up player ship centre and scale
	SetSpriteOffset( player_ship, GetSpriteWidth(player_ship)/2, GetSpriteHeight(player_ship)/2 ) 
	SetSpriteScale(player_ship,0.02,0.02) 

	//position ship at the screen centre
	SetSpritePositionByOffset  ( player_ship, 50, 50 )
	
	
	// Local Text Label for Player's sprite
	localNickLabel = CreateText("Local")
	SetTextAlignment( localNickLabel, 1 )
	SetTextSize(localNickLabel,5)
	SetTextFont(localNickLabel,main_font)
	gamestate.playerShip.Angle# = 0
	gamestate.playerShip.velocity#= 0
	gamestate.playerShip.turnspeed# = 0
	//set collision on ship to fit sprite image
	SetSpriteShape(player_ship, 3)
endfunction
function load_stars(gamestate REF as gamestate)
	LoadImage ( 50, "star.png" )
	//if normal mode genrate starfield
	if debug=0
		randomStars()
	else
		//generate debug starfield
		starGrid()
	endif
endfunction

function load_sun(gamestate REF as gamestate)
	
	//create sun sprite
	LoadImage ( sun, "sun.png" )
	CreateSprite(sun,2)
	SetSpriteDepth(sun,50)
	SetSpriteScale(sun,0.5,0.5)
	SetSpritePositionByOffset(sun,gamestate.session.worldSize/2,gamestate.session.worldSize/2)
	//set collision on sun to circle
	SetSpriteShape(sun, 1)
	//create planet sprites
	LoadImage ( 3, "planet02.png" )
	LoadImage ( 4, "planet01.png" )
	
	
	index as integer
	//for every planet...
	for index =0 to gamestate.planets.length
		createSprite(50+index,gamestate.planets[index].planet_type+2)
		SetSpriteDepth(index+50,50)
		SetSpriteScale(index+50,gamestate.planets[index].size#,gamestate.planets[index].size#)
		SetSpritePositionByOffset(50+index, gamestate.planets[index].position.x,gamestate.planets[index].position.y)
		//set collision on planet to circle
		SetSpriteColorRed(index+50,gamestate.planets[index].r)
		SetSpriteColorGreen(index+50,gamestate.planets[index].g)
		SetSpriteColorBlue(index+50,gamestate.planets[index].b)
		SetSpriteShape(index+50, 1)
	next index	
	
endfunction



function load_scan()
// Scan wave is sprite 5
	LoadImage ( scan_wave, "scanwave.png" )
	CreateSprite (scan_wave,  5 )
	SetSpriteAnimation(scan_wave,256,256,20)
	PlaySprite(scan_wave,20)
	SetSpriteScale(scan_wave,0.05,0.05)
	SetSpritePositionByOffset  ( scan_wave, 50, 50 )
	FixSpriteToScreen(scan_wave,1)
	SetSpriteVisible ( scan_wave, 0 )
endfunction

function load_music()
	//LoadMusicOGG( 1, "bensound-acousticbreeze.ogg" ) 
	//PlayMusicOGG( 1, 1 ) 
	//SetMusicVolumeOGG( 1, 5 ) 
	LoadSound (scan_sound, "scan.wav" )
	LoadSound (scan_success, "goodscan.wav" )
	LoadSound (scan_fail, "badscan.wav" )
endfunction	

function load_font()
	LoadFont(main_font,"PoetsenOne-Regular.ttf")
endfunction

function randomStars()
	starscale# as float 
	
	index as integer
	for index=0 to 5000
		starscale#= Random(2,20)/500.0
		CreateSprite(500+index,50)
		SetSpriteDepth(index+500,51)
		SetSpriteScale(index+500,starscale#,starscale#)
		//SetSpriteColor(index+500,gamestate.starfield[index].r,gamestate.starfield[index].g,gamestate.starfield[index].b,255)
		//randomly position stars
		SetSpritePositionByOffset(500+index, Random(1,gamestate.session.worldSize),Random(1,gamestate.session.worldSize))
	next
	//set number of background stars set up (for hiding later in minimap)
	gamestate.session.bgStars=1000
endfunction
function starGrid()
	starscale# as float=0.05
	index as integer
	xindex as integer
	yindex as integer
	for xindex=0 to gamestate.session.worldSize step 20
		for yindex= 0 to gamestate.session.worldSize step 20
			CreateSprite(index+500,50)
		SetSpriteDepth(index+500,51)
		SetSpriteScale(index+500,starscale#,starscale#)
		//SetSpriteColor(index+500,gamestate.starfield[index].r,gamestate.starfield[index].g,gamestate.starfield[index].b,255)
		//randomly position stars
		SetSpritePositionByOffset(index+500, xindex,yindex)
		index =index+1
	next yindex
	next xindex
		//set number of background stars set up (for hiding later in minimap)
	gamestate.session.bgStars=index-1
endfunction

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
	load_NPC()
	load_station()
endfunction

function load_NPC()
	LoadImage(kat_serious,"katfrontal.png")
	LoadImage(NPCFrame,"characterbezel.png")
endfunction

function load_particles()
	//load crystal animation strip
	LoadImage(crystal,"crystal01.png")
	//load the first frame from the strip
	LoadSubImage ( crystal_single, crystal, "crystal0100.png" ) 
	CreateParticles ( crystal_single, -1000, -1000 )
	//make an animated sprite too
	//we need 3 on for each credit type
	crystalScale as float=0.015 //scale crystals
	CreateSprite(crystal,crystal)
	CreateSprite(crystal_red,crystal)
	CreateSprite(crystal_green,crystal)
	//set crystal colours
	SetSpriteColor( crystal, 150, 150, 255, 255 )
	SetSpriteColor( crystal_red, 255, 0, 0, 255 )
	SetSpriteColor( crystal_green, 0, 255,0, 255 )
	//setup anim frames 
	SetSpriteAnimation(crystal,128,128,10)
	SetSpriteSpeed( crystal, 6 ) 
	SetSpriteAnimation(crystal_red,128,128,10)
	SetSpriteFrame( crystal_red, 3 ) 
	SetSpriteSpeed( crystal_red, 4 ) 
	SetSpriteAnimation(crystal_green,128,128,10)
	SetSpriteFrame( crystal_green, 6 ) 
	SetSpriteSpeed( crystal_green, 5 ) 
	//scale
	SetSpriteScale(crystal,crystalScale,crystalScale)
	SetSpriteScale(crystal_red,crystalScale,crystalScale)
	SetSpriteScale(crystal_green,crystalScale,crystalScale)
	//position
	SetSpritePositionByOffset(crystal_red,GetScreenBoundsRight()-20,27)
	SetSpritePositionByOffset(crystal,GetScreenBoundsRight()-20,29)
	SetSpritePositionByOffset(crystal_green,GetScreenBoundsRight()-20,31)
	//fix to screen
	FixSpriteToScreen(crystal,1)
	FixSpriteToScreen(crystal_red,1)
	FixSpriteToScreen(crystal_green,1)
	//start animations
	PlaySprite( crystal ) 
	PlaySprite( crystal_red ) 
	PlaySprite( crystal_green ) 
	//load star particle
	LoadImage(discoveryParticles,"funstar.png")
	CreateParticles ( discoveryParticles, -1000, -1000 )
endfunction

function load_station() 
	

gamestate.stations.insert(makeSpaceStation(500,500))
gamestate.stations[0].StationID=1
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
	if GetImageExists(player_ship ) =0
		LoadImage ( player_ship, "ship01.png")
	endif 
	LoadImage ( player_ship_notint, "ship01notint.png" )
	CreateSprite(player_ship,player_ship)
	CreateSprite(player_ship_notint,player_ship_notint)
	SetSpriteAnimation(player_ship,500,300,5)
	SetSpriteDepth(player_ship,16)
	SetSpriteAnimation(player_ship_notint,192,300,5)
	SetSpriteDepth(player_ship_notint,15)
	//set up player ship centre and scale
	SetSpriteScale(player_ship,0.02,0.02) 
	SetSpriteScale(player_ship_notint,0.02,0.02) 
	//position ship at the screen centre
	SetSpritePositionByOffset  ( player_ship, 50, 50 )
	SetSpritePositionByOffset  ( player_ship_notint, 50, 50 )
	
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
	SetNetworkClientUserData(gamestate.session.networkID, gamestate.session.myClientId, 1, player_ship)
endfunction
function load_stars(gamestate REF as gamestate)
	LoadImage ( 50, "star.png" )
	LoadImage (60, "dust.png")
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
	PlaySprite(scan_wave,6)
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
		//set number of background stars set up (for hiding later in minimap)
	gamestate.session.bgStars=100-1
	index as integer
	//we will use the same array to store the star speeds and speed of dust, we will just seed the speed multiplier differently 
	for index=0 to 500
		starscale#= Random(2,20)/500.0
		//the first 30% will be stars
		if index < 100
			CreateSprite(500+index,50)
			// sort out a random speed for the stars
			gamestate.session.starfieldspeed [ index ] = Random ( 1, 30 ) / 500.0
			SetSpriteColor(index+500,Random(200,255),Random(200,255),Random(200,255),255)
			SetSpriteDepth(index+500,51)
		else 		
			CreateSprite(500+index,60)
			// sort out a faster random speed for dust
			gamestate.session.starfieldspeed [ index ] = Random ( 1, 30 ) / 10.0
			//dust is grey
			dustbrightness as integer
			dustbrightness=Random(1,255)
			SetSpriteColor(index+500,dustbrightness,dustbrightness,dustbrightness,255)
			SetSpriteDepth(index+500,2)
		endif
	
		SetSpriteScale(index+500,starscale#,starscale#)
		FixSpriteToScreen(500+index,1)
		//randomly position stars
		SetSpritePosition(500+index, Random(1,140)-20,Random(1,140)-20)
	next

	//set number of background stars set up (for hiding later in minimap)
	gamestate.session.bgStars=500
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
		//randomly position stars
		SetSpritePositionByOffset(index+500, xindex,yindex)
		index =index+1
	next yindex
	next xindex
	
endfunction

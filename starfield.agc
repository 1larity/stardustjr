// functions for supporting starfield stuff

type starfield
    position as Vector2D
	size# as float
	star_type as integer
	r as integer
	g as integer
	b as integer
endtype


//populate planets
function populate_planets()
	index as integer
	for index =0 to gamestate.planets.length
		//set planet colour
		gamestate.planets[index].r=100
		gamestate.planets[index].g=100
		gamestate.planets[index].b=100
		//set planet orbit radius
		gamestate.planets[index].position.x=position_planet(index) 
		gamestate.planets[index].position.y=gamestate.session.worldSize/2
		gamestate.planets[index].orbit=gamestate.planets[index].position.x
		
		//set planet orbit speed
		gamestate.planets[index].angularVelocity#=Random(1,100)/999.99
		//set planet starting angle along orbit
		gamestate.planets[index].angle#=Random (1,360)
		//set planet appearence
		gamestate.planets[index].planet_type=Random(1,2)
		//set planet size
		gamestate.planets[index].size# = Random(5,7)/75.0
		gamestate.planets[index].name = "planet "+ str(index)
		//debug set first 2 planet colours noticably different
	
			if index=0
			gamestate.planets[index].g = (255)
		endif
		if index=1
			gamestate.planets[index].r = (255)
		endif
	next index
endfunction
//generate planet position according to a few simple rules
function position_planet( planetnumber as integer)
	result as integer
	allocated as integer =0
	collision as integer =0
	index as integer=0
	//max orbit radius is half worldsize
	maxOrbit as integer
	maxOrbit=gamestate.session.worldsize/2
	//minimum orbit size is 10% of max orbit
	minOrbit as integer
	minOrbit=(maxOrbit/100)*10
	//planets cannot be within (20% maxorbit) to the sun 
	sunExclusion as integer
	sunExclusion=(maxOrbit/100)*15
	//the closest 2 planets can be together
	windowsize as integer=40
	//place planet 0 at edge of solarsystem
	if planetnumber=0
		result = minorbit
		allocated=1
	endif
		//place planet 1 near sun
	if planetnumber=1
		 result = maxOrbit-sunExclusion
		allocated=1
	endif
		
	//if this planet has not been allocated	proceed to place
	if allocated =0 
		testvalue# as float
				while allocated=0
				//generate random number betweeen edge of solar system and sun
				result=Random(minOrbit,maxOrbit-sunExclusion)
				//for all existing planets
				collision=0
				for index =0 to gamestate.planets.length
					//get existing planet at index
					testvalue#=gamestate.planets[index].position.x
					// check our random position is not too close
				
					if (result>(testvalue#-windowsize)) and (result<(testvalue#+windowsize))
						collision=1
					endif
				next index
				//if our random number survived all the collision checks, allocate it
				if collision=0
					allocated=1
				endif
			endwhile
	endif
endfunction result


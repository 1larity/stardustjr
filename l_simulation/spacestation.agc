/********************************************************/
/*             		 Spacestation Code                  */
/*deal with drawing and updating (rotating)space station*/
/*				copyright Richard Beech 2017			*/
/********************************************************/
//UDT to hold state of spacestion, should be instanced for each spacetion and added to gamestate.
type station
	StationID as integer
	// current roation angle of spacestation
	rotation# as float
	//array of sprite IDs that constitute this space station
	parts as integer[]
	//the centre of this space station
	position as Vector2D
	name as String
	facilities as facility[5]
	stationType as integer
endtype

type facility 
	facilityType as string
endtype

//spacestation constructor
function makeSpaceStation(x# as float, y# as float)
stationID as integer
scale# as float
newStation as station
stationPart01 as integer =100
stationPart02 as integer =101
stationPart03 as integer =102
stationPart04 as integer =103
newstation.rotation#=0
newstation.position.x=x#
newstation.position.y=y#
scale#=1.80
		//load the spacestation graphic components if they do not exist
	if GetImageExists( stationPart01 ) =0
		LoadImage (stationPart01, "stationpart01.png")
	endif
	if GetImageExists( stationPart02 ) =0
		LoadImage (stationPart02, "stationpart02.png")
	endif
	if GetImageExists( stationPart03 ) =0
		LoadImage (stationPart03, "landingpad.png")
	endif
	if GetImageExists( stationPart04 ) =0
		LoadImage (stationPart04, "canopy.png")
	endif
	index as integer
	//top of space station, rotate and draw stationpart01 8 times
	for index=0 to 3
		//insert a part ID into the parts array
		newstation.parts.insert(index)
		//make sprite, assgin new sprite ID to part
		newstation.parts[index]=CreateSprite (stationPart01)
		SetSpriteScale(newstation.parts[index],0.059*scale#,0.05*scale#)
		//set pivot to middle of top edge
		SetSpriteOffset(newstation.parts[index],GetSpriteWidth(newstation.parts[index])/2,GetSpriteHeight(newstation.parts[index]))
		SetSpriteAngle(newstation.parts[index],index*90)
		SetSpritePositionByOffset(newstation.parts[index],x#,y#)
		SetSpriteDepth(newstation.parts[index],13)
		//we will be colliding this later so set an accurate colission hull
		SetSpriteShape( newstation.parts[index], 3) 
	next index
	//reapeat the previous, but this time as shadows for the previous part	
		for index=4 to 7
		//insert a part ID into the parts array
		newstation.parts.insert(index)
		//make sprite, assgin new sprite ID to part
		newstation.parts[index]=CreateSprite (stationPart01)
		//make them look like shadows
			SetSpriteColor(newstation.parts[index],1,1,1,200)
			SetSpriteScale(newstation.parts[index],0.073*scale#,0.054*scale#)
		//set pivot to middle of top edge
		SetSpriteOffset(newstation.parts[index],GetSpriteWidth(newstation.parts[index])/2,GetSpriteHeight(newstation.parts[index]))
		SetSpriteAngle(newstation.parts[index],index*90)
		SetSpritePositionByOffset(newstation.parts[index],x#,y#)
		SetSpriteDepth(newstation.parts[index],19)
	next index	
	//lower circular part
	for index=8 to 32
		//insert a part ID into the parts array
		newstation.parts.insert(index)
		//make sprite, assgin new sprite ID to part
		newstation.parts[index]=CreateSprite (stationPart02)
		SetSpriteScale(newstation.parts[index],0.059*scale#,0.05*scale#)
		//set pivot to middle of top edge
		SetSpriteOffset(newstation.parts[index],GetSpriteWidth(newstation.parts[index])/2,-15)
		SetSpriteAngle(newstation.parts[index],index*15)
		SetSpritePositionByOffset(newstation.parts[index],x#,y#)
		SetSpriteDepth(newstation.parts[index],21)
		SetSpriteColor(newstation.parts[index],220,220,220,255)
	next index	
		//landing pads
		for index=33 to 37
		//insert a part ID into the parts array
		newstation.parts.insert(index)
		//make sprite, assgin new sprite ID to part
		newstation.parts[index]=CreateSprite (stationPart03)
		SetSpriteScale(newstation.parts[index],0.029*scale#,0.03*scale#)
		SetSpritePosition(newstation.parts[index],x#,y#)
		//set pivot to middle of top edge
		SetSpriteOffset(newstation.parts[index],GetSpriteWidth(newstation.parts[index])/2,GetSpriteHeight(newstation.parts[index])-37)
		SetSpriteAngle(newstation.parts[index],index*90+45)
		SetSpritePositionByOffset(newstation.parts[index],x#,y#)
		SetSpriteDepth(newstation.parts[index],20)
			//we will be colliding this later so set an accurate colission hull
		SetSpriteShape( newstation.parts[index], 3 ) 
	next index
	//landing pad canopies
		for index=38 to 42	//insert a part ID into the parts array
		newstation.parts.insert(index)
		//make sprite, assgin new sprite ID to part
		newstation.parts[index]=CreateSprite (stationPart04)
		SetSpriteScale(newstation.parts[index],0.029*scale#,0.03*scale#)
		SetSpritePosition(newstation.parts[index],x#,y#)
		//set pivot to middle of top edge
		SetSpriteOffset(newstation.parts[index],GetSpriteWidth(newstation.parts[index])/2,GetSpriteHeight(newstation.parts[index])-27)
		SetSpriteAngle(newstation.parts[index],index*90+45)
		SetSpritePositionByOffset(newstation.parts[index],x#,y#)
		SetSpriteDepth(newstation.parts[index],14)
	next index
		
//return the instance of spacestation we just made
endfunction newStation

function rotatestation(stationID as integer,angle# as float)
	index as integer
	//loop for every part in current spacestation
	for index= 0 to gamestate.stations[stationID].parts.length
		SetSpriteAngle(gamestate.stations[stationID].parts[index],GetSpriteAngle(gamestate.stations[stationID].parts[index]) + angle#)
	next index
endfunction

function collide_station(stationID as integer, testObject)
	//flag to indicate status of collision 0=none, 1=on landing pad, 2=hitting top
	collisionStatus as integer =0
	index as integer
	//test if we are hitting station top, which is bad
	for index=0 to 3	
		//test if object is touching any of the top station sprites
		if GetSpriteCollision(testObject,gamestate.stations[stationID].parts[index])
			collisionStatus=2
		endif
	next index
	
	for index=33 to 37
		//test if we are hitting a landingpad , which is good
		if GetSpriteCollision(testObject,gamestate.stations[stationID].parts[index])
			collisionStatus=1
		endif
	next index
	// else collision status is =0 nothing is colliding
endfunction collisionStatus
	

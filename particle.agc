function discoverNumber(position as Vector2D)
		//play sucessful scan sound
		PlaySound ( scan_success )
		 // set up particles
        SetParticlesPosition ( discoveryParticles, position.x, position.y)
       // FixParticlesToScreen(discoveryParticles,1)
        ResetParticleCount ( discoveryParticles )
        SetParticlesFrequency ( discoveryParticles, 250 )
        SetParticlesLife ( discoveryParticles, 2.5 )
        SetParticlesSize ( discoveryParticles, Random(10,15) )
        SetParticlesStartZone ( discoveryParticles, -10, 0, 10, 0 )
        SetParticlesImage ( discoveryParticles, discoveryParticles )
        SetParticlesDirection ( discoveryParticles, 10, 10 )
        SetParticlesAngle ( discoveryParticles, 360 )
        SetParticlesVelocityRange ( discoveryParticles, 2.0, 3.5 )
        SetParticlesMax ( discoveryParticles, 50 )
		SetParticlesRotationRange( discoveryParticles, -100, 100 ) 
        AddParticlesColorKeyFrame ( discoveryParticles, 0.0, 0, 0, 0, 0 )
        AddParticlesColorKeyFrame ( discoveryParticles, 0.5, 255, 255, 0, 255 )
        AddParticlesColorKeyFrame ( discoveryParticles, 2.8, 255, 0, 0, 0 )
endfunction

function crystal_burst(position as Vector2D)
		//play sucessful scan sound
		PlaySound ( scan_success )
		 // set up particles
        SetParticlesPosition ( discoveryParticles, position.x, position.y)
       // FixParticlesToScreen(discoveryParticles,1)
        ResetParticleCount ( discoveryParticles )
        SetParticlesFrequency ( discoveryParticles, 250 )
        SetParticlesLife ( discoveryParticles, 2.5 )
        SetParticlesSize ( discoveryParticles, Random(10,15) )
        SetParticlesStartZone ( discoveryParticles, -10, 0, 10, 0 )
        SetParticlesImage ( discoveryParticles, discoveryParticles )
        SetParticlesDirection ( discoveryParticles, 10, 10 )
        SetParticlesAngle ( discoveryParticles, 360 )
        SetParticlesVelocityRange ( discoveryParticles, 2.0, 3.5 )
        SetParticlesMax ( discoveryParticles, 50 )
		SetParticlesRotationRange( discoveryParticles, -100, 100 ) 
        AddParticlesColorKeyFrame ( discoveryParticles, 0.0, 0, 0, 0, 0 )
        AddParticlesColorKeyFrame ( discoveryParticles, 0.5, 255, 255, 0, 255 )
        AddParticlesColorKeyFrame ( discoveryParticles, 2.8, 255, 0, 0, 0 )
endfunction

type myParticle
	start as Vector2D
	endpoint as Vector2D
	sprite as integer
	speedVector as Vector2d
	endtype
//creates adds new payout (particle) sprites and thier parameters to payout array
function newPayoutAnim(credittype)
	//local particle
	newPayoutParticle as MyParticle
	//setup sprite for particle
	newPayoutParticle.sprite=CreateSprite(crystal)
	FixSpriteToScreen(newPayoutParticle.sprite,1)
	SetSpriteAnimation(newPayoutParticle.sprite,128,128,10)
	SetSpriteScale(newPayoutParticle.sprite,0.05,0.05)
	SetSpritePositionByOffset(newPayoutParticle.sprite,50,50)
	PlaySprite(newPayoutParticle.sprite)
	//select correct endpoint for path (the credit tallys below map)
	if credittype=1 //blue crystal
		//set endpoint to blue crystal tally
		//since we are measuring an ofsettted sprite we need to add its offset to centre both sprites
		newPayoutParticle.endpoint.x=GetSpriteX(crystal) +GetSpriteOffsetX( crystal ) 
		newPayoutParticle.endpoint.y=GetSpriteY(crystal) +GetSpriteOffsetY( crystal ) 
		SetSpriteColor( newPayoutParticle.sprite,150, 150, 255, 255  )
	elseif credittype=2 //red crystal
		
		SetSpriteColor( newPayoutParticle.sprite,255, 0, 0, 255  )
			//set endpoint to red crystal tally
		newPayoutParticle.endpoint.x=GetSpriteX(crystal_red) +GetSpriteOffsetX( crystal_red )
		newPayoutParticle.endpoint.y=GetSpriteY(crystal_red)+GetSpriteOffsetY( crystal_red )
	elseif credittype=3 //green crystal
		//set endpoint to green crystal tally
		SetSpriteColor( newPayoutParticle.sprite, 0, 255,0, 255   )
		newPayoutParticle.endpoint.x=GetSpriteX(crystal_green) +GetSpriteOffsetX( crystal_green )
		newPayoutParticle.endpoint.y=GetSpriteY(crystal_green)+GetSpriteOffsetY( crystal_green )
	endif
		//all payouts start from the middle of the screen
		newPayoutParticle.start.x =50.0
		newPayoutParticle.start.y =50.0
		//calculate how far the particle needs to move each step to reach it's destination in 100 steps 
		newPayoutParticle.speedVector=subtractVector2(newPayoutParticle.start, newPayoutParticle.endpoint)
		newPayoutParticle.speedVector.x=-newPayoutParticle.speedVector.x/50
		newPayoutParticle.speedVector.y=-newPayoutParticle.speedVector.y/50
	payoutArray.insert(newPayoutparticle)
endfunction



function updatePayoutParticles()
	index as integer
	//for all entries in the payout array
	for index=0 to payoutArray.length
		//increment start vector by speed to move ii one step closer to endpoint 
		payoutArray[index].start=addVector2( payoutArray[index].speedVector,payoutArray[index].start)
		//going to scaledown crystals as they get near the tallies
		spriteScale as Vector2D
		//scale = distance between start and end
		spriteScale =subtractVector2(payoutArray[index].start, payoutArray[index].endpoint)
		//scale down by 200 but dont let it get smaller than 0.015 (the size of the tally indicators)
		spriteScale.x=0.015+abs(spriteScale.x/200)
		spriteScale.y=0.015+abs(spriteScale.y/200)
		SetSpriteScale(payoutArray[index].sprite,spriteScale.x,spriteScale.y)
		SetSpritePositionByOffset(payoutArray[index].sprite,payoutArray[index].start.x,payoutArray[index].start.y)
		//if the particle has reached the endpoint, delete it
		if (payoutArray[index].start.x> payoutArray[index].endpoint.x) and(payoutArray[index].start.y< payoutArray[index].endpoint.y)
			deleteSprite(payoutArray[index].sprite)
			payoutArray.remove(index)
		endif
	next
endfunction

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
function populate_planets(population REF as planet[])
	index as integer
	for index =0 to population.length
		population[index].position.x=Random(1,1000)
		population[index].position.y=Random(1,1000)
		population[index].planet_type=Random(1,2)
		//planets use sprite ID 50+
		population[index].size# = Random(5,7)/50.0
		population[index].name = "planet "+ str(index)
		//population[index].g = Random(200,255)
		//population[index].b = Random(200,255)
	next index
endfunction


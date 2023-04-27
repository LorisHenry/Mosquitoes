/**
* Name: Mosquitoes
* Based on the internal empty template. 
* Author: loris
* Tags: 
*/


model Mosquitoes

global {
	float world_size parameter:true category:"World"<- 1#km;
	geometry shape <- square(world_size);
	int nb_people parameter:true category:"People"<- 10;
	int nb_lakes parameter: true category: "World" <- 1;
	field cell <- field(100, 100);
	list<point> cells_location <-  cell cells_in world.shape collect each.location;
	
	
	init {
		create human number: nb_people;
		create lake number:nb_lakes;
		
	}
	reflex mosquito_pop_evolution {
		diffuse var: mosquito_population on:cell proportion:100.0 ;
		
		
		cell <- cell * 0.9;
		
		
	}
	
	
}

species lake {
	int mosquitoes_birth_rate <- 10;
	float size <- rnd(10.0, 100.0);
	geometry shape <- circle(size);
	list<geometry> cells_in_lake <- cells_in(cell, shape);
	list<point> cells_in_lake_location <- cells_in_lake collect each.location;
	
	
	aspect default {
		draw shape color: #blue border:#black;
	}
	
	reflex birth {
		write cells_in_lake;
		loop i over: cells_in_lake_location {
			cell[i] <- cell[i] + mosquitoes_birth_rate;
		}
			
		
			
			
		
	}
}

species human skills:[moving] {
	rgb color <- is_sick ? #green : #yellow;
	float size <- 2.0#m;
	//building living_place;
	//building working_place;
	int age;
	bool is_sick <- false;
	
	
	
	
	
	aspect default {
		
		draw circle(size) color:color border:#black;
	}
	aspect large {
		draw circle(world_size/100) color:color border:#black;
	}
}



experiment main_experiment type:gui {
	list<rgb> pal <- palette([ #white, #red]);
	output {
		display main_display type:3d{
			
			species human aspect:large;
			
			mesh cell scale:0.0 color:pal above: 0.8;
			species lake aspect: default transparency:0.5;
					
			
		}
		
	}
}



/* Insert your model definition here */


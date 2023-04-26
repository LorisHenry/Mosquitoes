/**
* Name: Mosquitoes
* Based on the internal empty template. 
* Author: loris
* Tags: 
*/


model Mosquitoes

global {
	float world_size parameter:true category:"World"<- 10.0#km;
	geometry shape <- square(world_size);
	int nb_people parameter:true category:"People"<- 100;
	
	init {
		create human number: nb_people;
	}
	
	
}

species human skills:[moving] {
	rgb color <- #yellow;
	float size <- 2.0#m;
	//building living_place;
	//building working_place;
	int age;
	bool is_sick <- false;
	
	reflex do_die when: flip(0.1 + 0.2*int(is_sick)) {
		do die;
	}
	
	
	aspect default {
		
		draw circle(size) color:color border:#black;
	}
	aspect large {
		draw circle(world_size/100) color:color border:#black;
	}
}

grid mosquito_cell width:50 height:50{
	int nb_mosquitoes <- 50+rnd(100);
	rgb color <- blend(#white, #red, nb_mosquitoes/150);
}

experiment main_experiment type:gui {
	output {
		display main_display {
			grid mosquito_cell border:#black;
			species human aspect:large;
			
			
		}
	}
}



/* Insert your model definition here */


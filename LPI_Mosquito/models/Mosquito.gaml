/**
* Name: Mosquitoes
* Based on the internal empty template. 
* Author: loris
* Tags: 
*/


model Mosquitoes

global {
	float world_size parameter:true category:"World"<- 100#m;
	geometry shape <- square(world_size);
	int nb_people parameter:true category:"People"<- 10;
	int nb_lakes parameter: true category: "World" <- 1;
	field cell <- field(100, 100);
	
	
	init {
		create human number: nb_people;
		create lake number:nb_lakes;
	}
	
	
}

species lake {
	int mosquitoes_birth_rate <- 10;
	float size <- rnd(10.0, 100.0);
	geometry shape <- circle(size);
	list cells_in_lake <- cells_in(cell, shape);
	
	aspect default {
		draw shape color: #blue border:#black;
	}
	
	reflex birth {
		
	}
}

species human skills:[moving] {
	rgb color <- is_sick ? #green : #yellow;
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



experiment main_experiment type:gui {
	output {
		display main_display {
			
			species human aspect:default;
			
			
			
		}
	}
}



/* Insert your model definition here */


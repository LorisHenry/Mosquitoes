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
	
	
	aspect default {
		
		draw circle(size) color:color border:#black;
	}
	aspect large {
		draw circle(world_size/100) color:color border:#black;
	}
}

grid mosquito_cell width:50 height:50{
	rgb color <- #lime;
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


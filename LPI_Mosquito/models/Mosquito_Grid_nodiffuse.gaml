/**
* Name: Mosquitoes
* Based on the internal empty template. 
* Author: loris
* Tags: 
*/


model Mosquitoes

global {
	float world_size parameter:true category:"World"min:100#m max:10#km<- 100#m;
	geometry shape <- square(world_size);
	int nb_people parameter:true category:"People" min:1 max: 200<- 10;
	int nb_lakes parameter: true category: "World" <- 2 min:0 max:10;
	float lake_growth_mosquitoes parameter:true category: "Mosquitoes" <- 10.0 min:0.0 max:100.0;
	float global_growth_mosquitoes parameter:true category: "Mosquitoes" <- 1.0 min:0.0 max:10.0;
	float mosquito_craming parameter:true category: "Mosquitoes" <- 100.0 min:0.0 max:1000.0;
	float diffusion_speed parameter:true category: "Mosquitoes" min:0.0 max:10.0 <- 1.0;
	int grid_width parameter:true category: "World" min:10 max:100 <- 20;
	int grid_height parameter:true category: "World" min:10 max:100 <- 20;
	
	file road_file <- file("../includes/road.shp");
	file building_file <- file("../includes/building1.shp");
	
	float logistic(float x) {
		return mosquito_craming*(1/(1+exp(-x/mosquito_craming)) - 1/2);
	}
	
	
	
	
	float max_mosquitoes update: max(1E-10,max(mosquito_cell collect each.nb_mosquitoes));
	float mosquito_die_factor parameter:true category:"Mosquitoes" min:0.0 max:1.0 <- 0.95;
	
	
	
	init {
		create human number: nb_people;
		create lake number:nb_lakes;
		
	}
	
	
	
}

species road {
	
}
species building {
	
}

species lake {
	
	float size <- rnd(world_size/10, world_size/5);
	geometry shape <- ellipse(rnd(1.0, 2.0)*size, rnd(1.0, 2.0)*size);
	
	
	
	aspect default {
		draw shape color: #blue border:#black;
	}
	
	reflex birth {
		ask intersecting(mosquito_cell, self.shape) {
			
			//write "hello";
			self.nb_mosquitoes <- world.logistic(self.nb_mosquitoes + lake_growth_mosquitoes);
			
		}
	}
	
	
			
		
			
			
		
	
}

grid mosquito_cell neighbors:8 width: grid_width height: grid_height parallel:true{
	float nb_mosquitoes <- 1.0;
	int nb_people_inside update: length(human inside self.shape);
	rgb color update: blend(#red, #white, nb_mosquitoes/max_mosquitoes);
	list<mosquito_cell> neighbors <- self neighbors_at 1;
	
	reflex add_mosq {
		nb_mosquitoes <- world.logistic(nb_mosquitoes + global_growth_mosquitoes);
	}
	
	
	reflex equalize {
		
		
		float mean_mosquitoes <- mean(neighbors collect each.nb_mosquitoes);
		int nb_people_neighbors <- sum(neighbors collect each.nb_people_inside);
		float diff <- self.nb_mosquitoes - mean_mosquitoes;
		ask neighbors {
			
			self.nb_mosquitoes <- world.logistic(max(0,self.nb_mosquitoes +((1.0+self.nb_people_inside)/(1.0 + myself.nb_people_inside))*diffusion_speed*diff/8));
			myself.nb_mosquitoes <- world.logistic(max(0,myself.nb_mosquitoes - ((1.0+self.nb_people_inside)/(1.0 + myself.nb_people_inside))*diffusion_speed*diff/8));
		} 
	}
	
	reflex die {
		nb_mosquitoes <- nb_mosquitoes*mosquito_die_factor;
	}
	
	
	
	
	

}

species human skills:[moving] {
	rgb color update: is_sick ? #green : #yellow;
	float size <- 2.0#m;
	//building living_place;
	//building working_place;
	int age;
	bool is_sick <- false;
	
	reflex wander {
		do wander;
	}
	
	reflex be_sick {
		
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
		monitor "Max of nb_mosquitoes" value: max_mosquitoes;
			
		
		display main_display type:3d{
			
			grid mosquito_cell ;
			species human aspect:large transparency:0.5;
			
			
			species lake aspect: default transparency:0.5;
					
			
		}
		
	}
}



/* Insert your model definition here */


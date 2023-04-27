/**
* Name: Mosquitoes
* Based on the internal empty template. 
* Author: loris
* Tags: 
*/


model Mosquitoes

global {
	float world_size parameter:true category:"World"min:100#m max:10#km<- 3#km;
	
	int nb_people parameter:true category:"People" min:1 max: 200<- 10;
	//int nb_lakes parameter: true category: "World" <- 2 min:0 max:10;
	float lake_growth_mosquitoes parameter:true category: "Mosquitoes" <- 10.0 min:0.0 max:100.0;
	float diffusion_speed parameter:true category: "Mosquitoes" min:0.0 max:10.0 <- 0.125;
	int grid_width parameter:true category: "World" min:10 max:100 <- 20;
	int grid_height parameter:true category: "World" min:10 max:100 <- 20;
	
	file road_file <- file("../includes/road.shp");
	file building_file <- file("../includes/building1.shp");
	
	geometry shape <- envelope(building_file);
	graph the_graph;
	
	
	bool people_far_from_lake_hate_net parameter:true <- false;
	float exponential_lambda;// to discuss its meaning later
	
	bool people_act_sin_from_the_lake parameter:true <- false;
	float wave_length <- 1#km;// the wave length 
	float initial_pahse <- 0.0;// it's phi in cos(2*pi/lambda * x + phi);
	
	bool people_keep_net_to_deal_with_mosquito parameter:true <- false;
	
	
	
	float max_mosquitoes update: max(mosquito_cell collect each.nb_mosquitoes);
	float mosquito_die_factor parameter:true category:"Mosquitoes" min:0.0 max:1.0 <- 0.95;
	
	
	
	init {
		create human number: nb_people;
		
		create building from: building_file with:[type::string(read("element_ty"))]
		{
			if (type = "lake"){
				color <- #blue;
			}
			else if (type = "farm"){
				color <- #green;
			}
			else if (type = "f_building"){
				color <- #red;
			}
			else if (type = "indust")
			{
				color <- #purple;
			}
		}
		
		list<building> list_of_lakes <- building where (each.type = "lake");	
		
		loop b over:building{
			loop l over:list_of_lakes{	
				add (b distance_to l) to: b.distance_from_lakes;
			}
			b.nearest_lake_distance <- min(b.distance_from_lakes);			
		}		
	}
	
	
}

species road {
	rgb color <- #black;
	aspect default {
		draw shape color:color;
		
	}
	
}
species building {
	string type;
	rgb color <- #grey;
	int net_type <- 1; //not to be used currently!
	
	
	bool have_net <- true;
	float probabilty_of_keeping_the_net <- 1.0;
	
	
	
	
	list<float> distance_from_lakes;
	float nearest_lake_distance;
	
	reflex p1 when:people_far_from_lake_hate_net and nearest_lake_distance != 0.0
	{
		probabilty_of_keeping_the_net <- probabilty_of_keeping_the_net * (1 - exp(-1.0*cycle/nearest_lake_distance));
	}
	reflex p2 when:people_act_sin_from_the_lake 
	{
		probabilty_of_keeping_the_net <- probabilty_of_keeping_the_net * cos((2.0*#pi/wave_length)*nearest_lake_distance + initial_pahse);
	}
	
	
	aspect default {
		draw shape color:color;
		
	}


	reflex birth when:type = "lake"{
		ask intersecting(mosquito_cell, self.shape) {
			
			//write "hello";
			self.nb_mosquitoes <- self.nb_mosquitoes + lake_growth_mosquitoes;
			
		}
	}


}
	
	

grid mosquito_cell neighbors:8 width: grid_width height: grid_height parallel:true{
	float nb_mosquitoes <- 1.0;
	int nb_people_inside update: length(human inside self.shape);
	rgb color update: blend(#red, #white, nb_mosquitoes/max_mosquitoes);
	list<mosquito_cell> neighbors <- self neighbors_at 1;
	
	
	reflex equalize {
		
		
		float mean_mosquitoes <- mean(neighbors collect each.nb_mosquitoes);
		int nb_people_neighbors <- sum(neighbors collect each.nb_people_inside);
		float diff <- self.nb_mosquitoes - mean_mosquitoes;
		ask neighbors {
			self.nb_mosquitoes <- max(0,self.nb_mosquitoes +((1.0+self.nb_people_inside)/(1.0 + myself.nb_people_inside))*diffusion_speed*diff/8);
			myself.nb_mosquitoes <- max(0,myself.nb_mosquitoes - ((1.0+self.nb_people_inside)/(1.0 + myself.nb_people_inside))*diffusion_speed*diff/8);
		} 
	}
	
	reflex die {
		nb_mosquitoes <- nb_mosquitoes*mosquito_die_factor;
	}
	
	
	
	
	

}

species human skills:[moving] {
	rgb color <- is_sick ? #green : #yellow;
	float size <- 2.0#m;
	//building living_place;
	//building working_place;
	int age;
	bool is_sick <- false;
	
	reflex wander {
		do wander;
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
			species building transparency: 0.4;
			species road;
			species human aspect:large transparency:0.5;		
			
		}
		
	}
}



/* Insert your model definition here */



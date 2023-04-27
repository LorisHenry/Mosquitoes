/**
* Name: Mosquitoes
* Based on the internal empty template. 
* Author: loris
* Tags: 
*/


model Mosquitoes

global {
	
	
	
	float world_size parameter:true category:"World"min:100#m max:10#km<- 100#m;
	
	int nb_people parameter:true category:"People" min:1 max: 200<- 100;
	int nb_lakes parameter: true category: "World" <- 2 min:0 max:10;
	float lake_growth_mosquitoes parameter:true category: "Mosquitoes" <- 10.0 min:0.0 max:100.0;
	float global_growth_mosquitoes parameter:true category: "Mosquitoes" <- 1.0 min:0.0 max:10.0;
	float mosquito_craming parameter:true category: "Mosquitoes" <- 100.0 min:0.0 max:1000.0;
	float sickness_factor parameter:true category: "People" <- 100.0 min:0.0 max:100.0;
	float diffusion_speed parameter:true category: "Mosquitoes" min:0.0 max:1.0 <- 0.3;
	float people_additive parameter:true category: "Mosquitoes" min:0.0 max:50.0 <- 8.0;
	int grid_width parameter:true category: "World" min:10 max:100 <- 50;
	int grid_height parameter:true category: "World" min:10 max:100 <- 50;
	int sickness_duration <- 100 parameter:true min:10 max:1000 category:"People";
	float cure_probability <- 1/2 parameter:true min:0.0 max:1.0 category: "People";
	float die_probability <- 1/120 parameter:true min:0.0 max:1.0 category: "People";
	
	file shape_file_buildings <- file("../includes/building1.shp");
	file shape_file_roads <- file("../includes/road.shp");
	graph the_graph;
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16;
	int max_work_end <- 18;
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h;
	date starting_date <- date("2019-09-01 00:00:00");
	
	//
	string experiment_type <-  nil parameter:true category: "World";
	geometry shape <- envelope(shape_file_buildings);
	
	
	//
	file road_file <- file("../includes/road.shp");
	file building_file <- file("../includes/building1.shp");
	
	float logistic(float x) {
		return 4*mosquito_craming*(1/(1+exp(-x/mosquito_craming)) - 1/2);
	}
	float logistic_sick(float x) {
		return 2*(1/(1+exp(-x/sickness_factor)) - 1/2);
	}
	
	
	
	
	float max_mosquitoes update: max(1E-10,max(mosquito_cell collect each.nb_mosquitoes));
	float mosquito_die_factor parameter:true category:"Mosquitoes" min:0.0 max:1.0 <- 0.95;
	
	
	
	init {
		
		
		
		if experiment_type = "grid" {
			write "hello";
			create lake number:nb_lakes;
			create human_grid number: nb_people;
			
			
		}
		if experiment_type = "GIS" {
			
			
			step <- 1#mn;
			create road from: shape_file_roads;
			the_graph <- as_edge_graph(road);
			
			create building from: shape_file_buildings with:[type :: read("element_ty")]{
			if type = "farm" {color<-#green;}
			if type = "lake" {color <- # blue;}
			if type = "f_building" {color <- #red;}}
			
			
		
			list<building> residential_building <- building where (each.type="way");
		
			list<building> industrial_building <- building where (each.type="farm");
			list<building> lakes <- building where (each.type="lake");
			loop lak over: lakes {
				create lake {
					shape <- lak.shape;
					
				}
			}
			
			create human number: nb_people{
			location<-any_location_in(one_of(residential_building));
			speed <- rnd(min_speed, max_speed);
			end_work <- rnd(min_work_end, max_work_end);
			start_work <- rnd(min_work_start, max_work_start);
			living_place <- one_of(residential_building);
			working_place <- one_of(industrial_building);
			objective <- "resting";
			location <- any_location_in (living_place);
			}
		}
		
	}
	
	
	
}

species road{
	rgb color <- #gray;
	
	aspect base{
		draw shape color:color;
	}
}
species building{
	string type;
	rgb color <- #gray;
	
	aspect base{
		draw shape color:color;
	}
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
	
	building living_place <- nil;
	building working_place <- nil;
	int start_work;
	int end_work;
	string objective;
	point the_target <- nil;
	
	reflex time_to_work when: current_date.hour = start_work and objective = "resting"{
		objective <- "working";
		the_target <- any_location_in(working_place);
	}
	
	reflex time_to_go_home when: current_date.hour = end_work and objective = "working"{
		objective <- "resting";
		the_target <- any_location_in(living_place);
	}
	
	reflex move when: the_target != nil{
		do goto target: the_target on: the_graph;
		
		if the_target = location{
			the_target <- nil;
		}
	}
	///
	rgb color update: is_alive ? (is_sick ? #red : (is_cured ? #blue : #green)) : #black;
	float size <- 2.0#m;
	mosquito_cell mycell update: first(mosquito_cell intersecting shape);
	int sick_counter <- 0;
	
	
	
	
	
	//building living_place;
	//building working_place;
	int age;
	bool is_sick <- false;
	bool is_alive <- true;
	bool is_cured <- false;
	
	
	
	reflex be_sick when: flip(world.logistic_sick(mycell.nb_mosquitoes)) and !is_sick and !is_cured{
		is_sick <- true;
		sick_counter <- rnd(int(sickness_duration/2), sickness_duration);
		
	}
	reflex when_sick when: is_sick and sick_counter>0 {
		sick_counter <- sick_counter - 1;
	}
	reflex cure when: is_sick and sick_counter = 0{
		if flip(cure_probability) {
			is_sick <- false;
			is_cured <- true;
		}
		else {
			sick_counter <- rnd(sickness_duration);
		}
		
	}
	reflex die when: is_sick and flip(die_probability) {
		is_alive <- false;
		
		
	}
	
	reflex generate_mosquitoes when: is_sick and is_alive {
		mycell.nb_mosquitoes <- world.logistic(mycell.nb_mosquitoes + people_additive);
	}
	aspect GIS_aspect {
		draw circle(10#m) color:color border:#black;
	}
	
	
	
	
	aspect default {
		
		draw circle(size) color:color border:#black;
	}
	aspect large {
		draw circle(world_size/100) color:color border:#black;
	}
}


///

species human_grid skills:[moving] {
	
	
	rgb color update: is_alive ? (is_sick ? #red : (is_cured ? #blue : #green)) : #black;
	float size <- 2.0#m;
	mosquito_cell mycell update: first(mosquito_cell intersecting shape);
	int sick_counter <- 0;
	
	
	
	
	
	
	int age;
	bool is_sick <- false;
	bool is_alive <- true;
	bool is_cured <- false;
	
	reflex wander when: is_alive{
		do wander;
	}
	
	reflex be_sick when: flip(world.logistic_sick(mycell.nb_mosquitoes)) and !is_sick and !is_cured{
		is_sick <- true;
		sick_counter <- rnd(int(sickness_duration/2), sickness_duration);
		
	}
	reflex when_sick when: is_sick and sick_counter>0 {
		sick_counter <- sick_counter - 1;
	}
	reflex cure when: is_sick and sick_counter = 0{
		if flip(cure_probability) {
			is_sick <- false;
			is_cured <- true;
		}
		else {
			sick_counter <- rnd(sickness_duration);
		}
		
	}
	reflex die when: is_sick and flip(die_probability) {
		is_alive <- false;
		
		
	}
	
	reflex generate_mosquitoes when: is_sick and is_alive {
		mycell.nb_mosquitoes <- world.logistic(mycell.nb_mosquitoes + people_additive);
	}
	
	
	
	
	aspect default {
		
		draw circle(size) color:color border:#black;
	}
	aspect large {
		draw circle(world_size/100) color:color border:#black;
	}
	
}



experiment mytrafficmodel1 type: gui {
	/** Insert here the definition of the input and output of the model */
//	float minimum_cycle_duration <- 0.04;
	parameter "Paramètre d'expérience" var: experiment_type <- "GIS";
	
	parameter "Shapefile for buildings:" var: shape_file_buildings category: "GIS";
	parameter "Shapefile for roads:" var: shape_file_roads category: "GIS";
	parameter "Shapefile for bounds:" var: shape_file_buildings category: "GIS";
	
	parameter "Number of people agents" var: nb_people category: "People";
	
	
	
	output {
		display city_display type: 3d{
			grid mosquito_cell;
			species building aspect:base;
			species road aspect:base;
			species human aspect: GIS_aspect;
			
			
		}
		
	}
}
experiment experiment_grid type:gui {
	string experiment_type <- "grid";
}



/* Insert your model definition here */


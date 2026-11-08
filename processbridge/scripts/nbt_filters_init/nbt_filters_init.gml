 
function nbt_filters_init(){
	 
	global.nbt_codec.filter_manager.create("structure", [
		["x", NBTMASK.NONE], 
		["y", NBTMASK.NONE],
		["size", NBTMASK.NONE],
		["map", NBTMASK.NONE],
		["tile_grid", "tile_grid"],
	]) 
	
	
	global.nbt_codec.filter_manager.create("minimap_chunk", [ 
		["size", NBTMASK.NONE],  
		["grid", NBTMASK.NONE],  
		["palette", NBTMASK.NONE],  
		["palette_hash", NBTMASK.NONE],  
	])
	
	
	global.nbt_codec.filter_manager.create("tile_grid_entities", [ 
		["id", NBTMASK.NONE], 	
		["x", NBTMASK.NONE], 	
		["y", NBTMASK.NONE], 	
		["layer", NBTMASK.NONE], 	
		["variation", NBTMASK.NONE], 	
		["extra", NBTMASK.NONE], 	
		
		["chunk_x", NBTMASK.NONE], 	
		["chunk_y", NBTMASK.NONE], 	
		
		["tags", NBTMASK.NONE], 	
	])
	
	
	global.nbt_codec.filter_manager.create("tile_grid_entities_redirector", [ 
		["struct", "tile_grid_entities"], 
		
	])
	
	
	global.nbt_codec.filter_manager.create("tile_grid", [ 
		["grid_attributes", NBTMASK.NONE], 
		["modification_bitmap", NBTMASK.NONE], 
		["farm_soil_bitmap", NBTMASK.NONE], 
		//["custom_renderer_bitmap", NBTMASK.NONE], 
		["properties", NBTMASK.NONE], 
		//["entities", "tile_grid_entities_redirector"], //
		//["entities", NBTMASK.NONE], //
		//["entities_bitmap", NBTMASK.NONE], 
		["biomes", NBTMASK.NONE], 
		["width", NBTMASK.NONE], 
		["height", NBTMASK.NONE], 
		
		["palette", NBTMASK.NONE], 
		["palette_hash", NBTMASK.NONE], 
		
		["biomes_palette", NBTMASK.NONE], 
		["biomes_palette_hash", NBTMASK.NONE], 
		
		// existe uma flag em cada tile q diz se tem ou nao 
		//["custom_renderer_map", NBTMASK.NONE], 
		//["custom_renderer_keys", NBTMASK.NONE], //  
		//["custom_renderer_list", NBTMASK.NONE], 
		//["custom_renderer_count", NBTMASK.NONE],
		
		//["entity_map", NBTMASK.NONE], 
		["entity_keys", NBTMASK.NONE], 
		["entity_list", NBTMASK.NONE], 
		["entity_count", NBTMASK.NONE]
	])
	
	global.nbt_codec.filter_manager.create("slots", [ 
		["slot", NBTMASK.NONE], 
		["id", NBTMASK.NONE],  
		["count", NBTMASK.NONE], 
		["tag", ""], 
	])
	global.nbt_codec.filter_manager.create("slots_redirector", [  
		["struct", "slots"], 
		["undefined", NBTMASK.NONE]
	])
	global.nbt_codec.filter_manager.create("inventory", [  
		//["__flag_slots", ""], 
		["length", ""], 
		["slots", "slots_redirector"], 
	])
	global.nbt_codec.filter_manager.create("bestiary", [
		["data", NBTMASK.NONE],
	])
	 
	
	global.nbt_codec.filter_manager.create("entity", [
		["__class", NBTMASK.NONE],  
		["x", NBTMASK.NONE], 
		["y", NBTMASK.NONE],  
		["material_id", NBTMASK.NONE],
		//["sprite_index", NBTMASK.SPRITE], 
		//["image_index", NBTMASK.NONE], 
		["life", NBTMASK.NONE], 
	])
	
	global.nbt_codec.filter_manager.create("player:entity", [ // herda os atributos do filtro entidade
		["name", NBTMASK.NONE], 
		["wallet", NBTMASK.NONE],
		["inventory", "inventory"], 
		["cursor_inventory", "inventory"],  
		["equipment_inventory", "inventory"],
		["experience_crafting", NBTMASK.NONE],
		["bestiary", "bestiary"],
        ["professions", "bestiary"],
        ["encyclopedia", "bestiary"],
		["skills", NBTMASK.NONE], // legacy migration
		["skill_slot_0", NBTMASK.NONE],
		["skill_slot_1", NBTMASK.NONE],
		["skill_slot_2", NBTMASK.NONE],
		["skill_slot_3", NBTMASK.NONE],
		["skill_points", NBTMASK.NONE],
		["learned_skills", NBTMASK.NONE],
		["appearance_hat_id", NBTMASK.NONE], ["appearance_hat_color", NBTMASK.NONE], ["appearance_hat_priority", NBTMASK.NONE],
		["appearance_mask_id", NBTMASK.NONE], ["appearance_mask_color", NBTMASK.NONE], ["appearance_mask_priority", NBTMASK.NONE],
		["appearance_shoes_id", NBTMASK.NONE], ["appearance_shoes_color", NBTMASK.NONE], ["appearance_shoes_priority", NBTMASK.NONE],
		["appearance_legs_id", NBTMASK.NONE], ["appearance_legs_color", NBTMASK.NONE], ["appearance_legs_priority", NBTMASK.NONE],
		["appearance_torso_id", NBTMASK.NONE], ["appearance_torso_color", NBTMASK.NONE], ["appearance_torso_priority", NBTMASK.NONE],
		["appearance_jacket_id", NBTMASK.NONE], ["appearance_jacket_color", NBTMASK.NONE], ["appearance_jacket_priority", NBTMASK.NONE],
		["appearance_hair_id", NBTMASK.NONE], ["appearance_hair_color", NBTMASK.NONE], ["appearance_hair_priority", NBTMASK.NONE],
		["appearance_eye_id", NBTMASK.NONE], ["appearance_eye_color", NBTMASK.NONE], ["appearance_eye_priority", NBTMASK.NONE],
		["appearance_moving_frames_per_second", NBTMASK.NONE],
        ["hunger", NBTMASK.NONE], 
        ["mana", NBTMASK.NONE], 
	])
	
	global.nbt_codec.filter_manager.create("item:entity", [  
		["inventory", "inventory"], 
		["is_collectible", NBTMASK.NONE], 
		["delay_to_be_colectable", NBTMASK.NONE] 
	]) 
	
	
	global.nbt_codec.filter_manager.create("planta:entity", [   
		["__entity_timer_phase", NBTMASK.NONE], 
	]) 
	
	
	global.nbt_codec.filter_manager.create("region", [  
		["x", NBTMASK.NONE], 
		["y", NBTMASK.NONE], 
		["entities", "region_entities"], 
	]) 
	global.nbt_codec.filter_manager.create("region_entities", [  
		["struct", "region_entities_redirector"], // manda para "item:entity" 
	]) 
	//global.__nbt_filter__region_entities_redirector = 
	// O codec ignora e diagnostica classes ausentes deste redirector; nunca deve
	// serializa-las sem filtro, pois entidades de runtime podem conter ciclos.
	 global.nbt_codec.filter_manager.create("region_entities_redirector", [  
		["__class", "EntityItem", "item"], 
		["__class", "EntityPlayer", "player"], 
		
		["__class", "EntityShroom", "entity"], 
		["__class", "EntityStwomp", "entity"],
		["__class", "EntityTemplatePassive", "entity"], 
		["__class", "EntityCow", "entity"], 
		["__class", "EntityGoose", "entity"], 
		["__class", "EntityFubug", "entity"], 
		["__class", "EntityUsagi", "entity"],
		["__class", "EntityMouse", "entity"],
		["__class", "EntityButterfly", "entity"],
		["__class", "EntityFirefly", "entity"],
		["__class", "EntityNPC", "entity"], 
		["__class", "EntityTeste", "planta"],
	]) 
}

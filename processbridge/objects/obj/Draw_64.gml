draw_set_alpha(1)
draw_set_colour(c_white)
draw_text(40, 40, $"main: {shm_peek(SHM_MAIN, 0, buffer_u64)}")

//shm_seek(SHM_CORE, buffer_seek_start, 0)
//draw_text(40, 80, $"core: {shm_read(SHM_CORE, buffer_string)}")
//draw_text(40, 80, $"core: {shm_peek(SHM_CORE, 0, buffer_string)}")

draw_text(40, 80, $"core: {global.nbt.decode(SHM_CORE)}")
 


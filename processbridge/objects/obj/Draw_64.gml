draw_set_alpha(1)
draw_set_colour(c_white)
draw_text(40, 40, $"main: {shm_peek(SHM_MAIN, 0, buffer_u64)}")

//shm_seek(SHM_CORE, buffer_seek_start, 0)
//draw_text(40, 80, $"core: {shm_read(SHM_CORE, buffer_string)}")
//draw_text(40, 80, $"core: {shm_peek(SHM_CORE, 0, buffer_string)}")

draw_text(40, 80, $"core: {Serializer.decode(SHM_CORE)}")

draw_text(40, 120, $"main pid: {shm_peek(SHM_H_MAIN, 2, buffer_u64)}")
draw_text(40, 140, $"core pid: {shm_peek(SHM_H_CORE, 2, buffer_u64)}")
 


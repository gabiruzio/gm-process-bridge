draw_set_alpha(1)
draw_set_colour(c_white) 

draw_text(40, 120, $"main pid: {shm_peek(SHM_H_MAIN, 2, buffer_u64)}")
draw_text(40, 140, $"core pid: {shm_peek(SHM_H_CORE, 2, buffer_u64)}")
 


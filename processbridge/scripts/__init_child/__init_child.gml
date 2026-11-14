function __init_child() {
	CALLONCE 

	if(debug_mode) {
		global.appid = __processbridge_multiclient_get_id()
		global.appkey = "debug-mode" 

		return 1 
	}
    static __param = "-ipc-shm-child";
    static __key_prefix = "-ipc-shm-child-key-";

    var _is_child = false;
    var _child_key = "";
 
    var _p_num = parameter_count();

    for (var _i = 1; _i <= _p_num; _i++) {
        var _p = parameter_string(_i);

        if (_p == __param) {
            _is_child = true;
        }
        else if (string_pos(__key_prefix, _p) == 1) {
            _child_key = string_delete(
                _p,
                1,
                string_length(__key_prefix)
            );
        }
    }
 
    if (_is_child) { 
        if (_child_key == "") {
            show_debug_message("IPC: UUID nao recebido");
            return 0;
        }

        global.appid = APPID_CORE;
        global.appkey = _child_key;

        return 1;
    }
	
    global.appid = APPID_MAIN;
    global.appkey = __uuid_generate();
	
    var _params = $"{__key_prefix}{global.appkey} {__param} ";
	
	 
	if (launch_another_instance(_params) == 0) {
		show_debug_message("IPC: Falha ao iniciar segunda instância!");
		return 0;
	} 
    return 1;
}
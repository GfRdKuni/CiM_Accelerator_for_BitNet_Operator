clc,clear
Act_Matrix = generate_quantized_int32_matrix(96,16);
Weight_Matrix = generate_ternary_matrix(256,96);
[WM_Matrix,WS_Matrix] = encode_ternary_matrix(Weight_Matrix);
Expected_Matrix = matrix_multiply(Weight_Matrix,Act_Matrix); 
check_int16_range(Expected_Matrix);
generate_act_data(Act_Matrix,'Act_file.hex');
generate_wm_data(WM_Matrix, 'WM_file.hex');
generate_ws_data(WS_Matrix, 'WS_file.hex');

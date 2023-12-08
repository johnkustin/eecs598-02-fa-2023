set_max_transition 150 ${DESIGN_NAME}
set_input_transition 80 [all_inputs]
set_max_transition 80 [all_outputs]

set clock_period 700
set clock_uncertainty [expr $clock_period * 0.10]
set clock_transition 0.080
set clock_latency 0.2

create_clock -name core_clk -period $clock_period [get_ports clock]
set_clock_uncertainty $clock_uncertainty [get_clocks core_clk]
set_clock_transition $clock_transition [get_clocks core_clk]
set_clock_latency $clock_latency [get_clocks core_clk]

set_load 0.3 [all_outputs]
set_driving_cell -no_design_rule -lib_cell NBUFFX4_HVT [all_inputs]

set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" up_valid_in] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" up_valid_in*] -clock core_clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" up_data_in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" up_data_in*] -clock core_clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" ep_valid_in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" ep_valid_in*] -clock core_clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" ep_data_in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" ep_data_in*] -clock core_clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" write_lms_lut_valid_in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" write_lms_lut_valid_in*] -clock core_clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" write_lms_lut_data_in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" write_lms_lut_data_in*] -clock core_clk
set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" write_lms_lut_idx_in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" write_lms_lut_idx_in*] -clock core_clk
set_output_delay -max [expr $clock_period * 0.5] [get_ports -filter "direction == out" y0_data_out*] -clock core_clk
set_output_delay -min [expr $clock_period * 0.4] [get_ports -filter "direction == out" y0_data_out*] -clock core_clk
set_output_delay -max [expr $clock_period * 0.3] [get_ports -filter "direction == out" y0_valid_out*] -clock core_clk
set_output_delay -min [expr $clock_period * 0.2] [get_ports -filter "direction == out" y0_valid_out*] -clock core_clk

set_false_path -from [get_ports -filter "direction == in" reset]

set_max_transition 150 ${DESIGN_NAME}
set_input_transition 80 [all_inputs]
set_max_transition 80 [all_outputs]

set clock_period 700
set clock_uncertainty [expr $clock_period * 0.10]
set clock_transition 0.080
set clock_latency 0.2

create_clock -name core_clk -period $clock_period [get_ports clk]
set_clock_uncertainty $clock_uncertainty [get_clocks core_clk]
set_clock_transition $clock_transition [get_clocks core_clk]
set_clock_latency $clock_latency [get_clocks core_clk]

set_load 0.3 [all_outputs]
set_driving_cell -no_design_rule -lib_cell NBUFFX4_RVT [all_inputs]

set_input_delay -max [expr $clock_period * 0.2] [get_ports -filter "direction == in" in*] -clock core_clk
set_input_delay -min [expr $clock_period * 0.1] [get_ports -filter "direction == in" in*] -clock core_clk
set_output_delay -max [expr $clock_period * 0.5] [get_ports -filter "direction == out" out*] -clock core_clk
set_output_delay -min [expr $clock_period * 0.4] [get_ports -filter "direction == out" out*] -clock core_clk
set_output_delay -max [expr $clock_period * 0.3] [get_ports -filter "direction == out" out_scaled*] -clock core_clk
set_output_delay -min [expr $clock_period * 0.2] [get_ports -filter "direction == out" out_scaled*] -clock core_clk

set_false_path -from [get_ports -filter "direction == in" rstn]
set_false_path -from [get_ports -filter "direction == in" en]

####### Power Optimization #######
set_power_low_power_placement true
#set_leakage_optimization true # done by compile_ultra
set_dynamic_optimization true

#read_saif -input your.saif -instance_name test_/dut -auto_map_names
set compile_clock_gating_through_hierarchy true

#####################################################
#Read design data & technology
#####################################################

set PDK_PATH $::env(SAED32_PATH)
set CURRENT_PATH [pwd]
set TOP_DESIGN test_mod2_sine
set MUT mod2
set search_path [list \
					"$CURRENT_PATH" \
				]

## Add libraries below
## technology .db file, and memory .db files
set target_library "${PDK_PATH}/lib/stdcell_rvt/db_ccs/saed32rvt_tt1p05v25c.db"

set LINK_PATH [concat  "*" $target_library]

## Replace with your complete file paths
set SDC_FILE      	$CURRENT_PATH/../../results/$MUT.mapped.sdc
set NETLIST_FILE	$CURRENT_PATH/../../results/$MUT.mapped.v

## Replace with your instance hierarchy
set STRIP_PATH    test_mod2_sine/mod

## Replace with your activity file dumped from vcs simulation
set ACTIVITY_FILE 	$CURRENT_PATH/../$TOP_DESIGN.vcd

######## Timing Sections ########
# these times aret workng
set	START_TIME	0.0
set	END_TIME 	192405.0

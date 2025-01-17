# make          <- runs simv (after compiling simv if needed)
# make simv     <- compiles simv without running
# make dve      <- runs GUI debugger (after compiling it if needed)
# make syn      <- runs syn_simv (after synthesizing if needed then 
#                                 compiling syn_simv if needed)
# make clean    <- remove files created during compilations (but not synthesis)
# make nuke     <- remove all files created during compilation and synthesis
#
# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be 
# similar to the information in those scripts but that seems hard to avoid.
#
export MK_COURSE_NAME = EECS598-002
export MK_DESIGN_NAME = fir_filter
export MK_USE_NUM_CORES = 6
export MK_MEM_SUFFIX = typ_1d05_25

VCS = SW_VCS=2020.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 +define+
LIB = /afs/umich.edu/class/eecs598-002/SAED32/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v /afs/umich.edu/class/eecs598-002/SAED32/SAED32_EDK/lib/stdcell_hvt/verilog/saed32nm_hvt.v
all:	simv
	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = test/testbench.sv
SIMFILES = src/W.sv
SYNFILES = results/W.mapped.v
SYN_SIM_OPTS = +neg_tchk 


#####
# Should be no need to modify after here
#####
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES) -o simv | tee simv.log

dve:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(TESTBENCH) $(SIMFILES) -o dve -R -gui -debug_acccess+all -kdb | tee dve.log

.PHONY: dve

fir_filter.vg: $(SIMFILES) old_scripts/synth.tcl
	dc_shell-t -f old_scripts/synth.tcl | tee synth.out

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(SYN_SIM_OPTS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv | tee syn_simv.log

syn:	syn_simv
	./syn_simv | tee syn_program.out | tee syn.log

syn_NEW:
		-mkdir -p logs
		dc_shell -f scripts/synth.tcl | tee logs/synth.log
		-mkdir -p temp_files
		-mv alib-52 temp_files/
		-mv *_dclib temp_files/
		-mv command.log temp_files/
		-mv default.svf temp_files/
		-mkdir -p export
		-cp -f memory/db/*_${MK_MEM_SUFFIX}_ccs.db export/

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	syn_simv syn_simv.daidir syn_program.out \
	dve *.vpd *.vcd *.dump ucli.key \
        inter.fsdb novas* verdiLog	

nuke:	clean
	rm -rvf verdi_config_file *.vg *.rep *.db *.chk *.log *.out *.ddc *.svf DVEfiles/ export/ logs/ reports/ results/ temp_files/ Shat_dclib/ alib-52/

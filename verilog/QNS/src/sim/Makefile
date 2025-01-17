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

VCS = SW_VCS=2020.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 +define+
LIB = /afs/umich.edu/class/eecs598-002/SAED32/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v /afs/umich.edu/class/eecs598-002/SAED32/SAED32_EDK/lib/stdcell_hvt/verilog/saed32nm_hvt.v

all:	simv
	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = test_mod2_sine.sv 
#test_mod2_noise.sv
SIMFILES = ../mod2.v ./H_cic_dec_64_N3R0_signed.v
SYNFILES = ../../results/mod2.mapped.v ./H_cic_dec_64_N3R0_signed.v

SYN_SIM_OPTS = +compsdf +neg_tchk 

#####
# Should be no need to modify after here
#####
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES) -o simv | tee simv.log

dve:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(TESTBENCH) $(SIMFILES) -o dve -R -gui -debug_acccess+all -kdb | tee dve.log

.PHONY: dve

mod2.vg: $(SIMFILES) ../scripts/synth.tcl
	dc_shell-t -f synth.tcl | tee synth.out

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(SYN_SIM_OPTS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv | tee syn_simv.log

syn:	syn_simv
	./syn_simv | tee syn_program.out | tee syn.log

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	syn_simv syn_simv.daidir syn_program.out \
	dve *.vpd *.vcd *.dump ucli.key \
        inter.fsdb novas* verdiLog	

nuke:	clean
	rm -rvf verdi_config_file *.vg *.rep *.db *.chk *.log *.out *.ddc *.svf DVEfiles/

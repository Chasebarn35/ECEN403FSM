This is the code for the 3-Phase Matrix Converter FPGA For proper commutation. This is set up such that there is 3 distinct FSMs, that will then translate the transistors such that the components will not break.
to run, simply run the command ```make```

to test the code, run ```make test```

I utilize GTKWave to read the vcd outputs

### Verilog File Descriptions
* StateMachine.v        state machine module
* FSMTest.v             state machine test bench
* top_commutation.v     module for fpga chip
* commutationtb.v       output test bench
* commutation_dev.v     module for dev board 

CC=iverilog


all: FSM

test: FSM
	./FSM
	./Comm

FSM: StateMachine.v FSMTest.v top_commutation.v commutationtb.v commutation_dev.v
	$(CC) StateMachine.v FSMTest.v -o FSM
	$(CC) top_commutation.v StateMachine.v commutationtb.v -o Comm
	$(CC) top_commutation.v StateMachine.v commutation_dev.v -o Dev

clean:
	rm -f FSM FSM.vcd Comm Comm.vcd Dev

CC=iverilog


all: FSM

test: FSM
	./FSM

FSM: StateMachine.v FSMTest.v
	$(CC) StateMachine.v FSMTest.v -o FSM

clean:
	rm -f FSM FSM.vcd

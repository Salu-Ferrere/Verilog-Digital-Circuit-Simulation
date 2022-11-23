module part2 (Data_A, Data_B, Clock, data_out);
	input [7:0] Data_A;
   input [7:0]	Data_B;
	input Clock;
	output [15:0] data_out;
	wire [1:0] sel;
	wire [15:0] zeros, Adder_Out, mux_out;
	wire [7:0] zeros_8, A_Out, B_Out;
	


	
	//assign zero wires
	assign zeros = 16'd0;
	assign zeros_8 = 8'd0;

	Counter(Clock,  sel);
	Reg_B(Data_B, ~(sel[0] | sel[1]), Clock, B_Out);
	Reg_A(Data_A, ~(sel[0] | sel[1]), Clock, A_Out);
	Adder(A_Out, B_Out, Adder_Out);
	mux4to1(A_Out, B_Out, Adder_Out, zeros, zeros_8, sel, mux_out);
	
	assign data_out = mux_out;
	
		
endmodule

	//Register A
module Reg_A (Reg_in, id_a, Clock, Reg_out);
	input [7:0] Reg_in;
	input id_a, Clock;
	output reg [7:0] Reg_out;

	always@(posedge Clock)
	begin
		if(id_a == 1)
				Reg_out = Reg_in;
	end
endmodule
	
	//Register B
module Reg_B (Reg_in, id_b, Clock, Reg_out);
	input [7:0] Reg_in;
	input id_b, Clock;
	output reg [7:0] Reg_out;

	always@(posedge Clock)
	begin
		if(id_b == 1)
				Reg_out = Reg_in;
	end
endmodule

	//counter
module Counter (Clock, Q);
	input Clock;
	output reg [1:0]Q;
	
	always@(posedge Clock)
	begin
		Q <= Q+1;
	end	
endmodule

	//adder
module Adder(RegA, RegB, Adder_Out);
	input [7:0] RegA, RegB;
	output reg [15:0] Adder_Out;
	
	always @(*)
	begin
		Adder_Out = RegA + RegB;
	end	
endmodule

	//4 to 1 mux
module mux4to1 (RegA, RegB, Adder_Out, Zeros, Zeros8, sel, out);
	input [7:0] RegA, RegB, Zeros8;
	input [15:0] Adder_Out, Zeros;
	input [1:0] sel;
	output reg [15:0] out;
		
	always@(*)
	begin
		if(sel == 2'b00)
				out <= Zeros;
		else if(sel == 2'b01)
				out <= {Zeros8, RegA};
		else if(sel == 2'b10)
				out <= {Zeros8, RegB};
		else if(sel == 2'b11)
				out <= Adder_Out;
	end
endmodule



	

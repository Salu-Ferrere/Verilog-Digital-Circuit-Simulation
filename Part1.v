module Part1 (Data_A, Data_B, Data_C, ld_a, ld_b, ld_c, output_sel, data_out);
	input [7:0] Data_A;
   input [7:0]	Data_B;
	input ld_a, ld_b, ld_c;
	input [15:0] Data_C;
	input [1:0] output_sel;
	output [15:0] data_out;
	wire [15:0] zeros, RegC, mux_out;
	wire [7:0] zeros_8, RegA, RegB;

	
	//assign zero wires
	assign zeros = 16'd0;
	assign zeros_8 = 8'd0;
	
	//fill registers
	Reg_A(Data_A, ld_a, RegA);
	Reg_B(Data_B, ld_b, RegB);
	Reg_C(Data_C, ld_c, RegC);
	
	//implement 4 to 1 mux
	mux4to1(RegA, RegB, RegC, zeros, zeros_8, output_sel, mux_out);
	
	assign data_out = mux_out;
endmodule	
	
	//Register A
module Reg_A (Reg_in, ld_a, Reg_out);
	input [7:0] Reg_in;
	input ld_a;
	output reg [7:0] Reg_out;

	always@(*)
	begin
		if(ld_a == 1)
				Reg_out = Reg_in;
	end
endmodule
	
	//Register B
module Reg_B (Reg_in, ld_b, Reg_out);
	input [7:0] Reg_in;
	input ld_b;
	output reg [7:0] Reg_out;

	always@(*)
	begin
		if(ld_b == 1)
				Reg_out = Reg_in;
	end
endmodule
	
	//Register C
module Reg_C (Reg_in, ld_c, Reg_out);
	input [15:0] Reg_in;
	input ld_c;
	output reg [15:0] Reg_out;

	always@(*)
	begin
		if(ld_c == 1)
				Reg_out = Reg_in;
	end
endmodule
	
	//4 to 1 mux
module mux4to1 (RegA, RegB, RegC, Zeros, Zeros8, sel, out);
	input [7:0] RegA, RegB, Zeros8;
	input [15:0] RegC, Zeros;
	input [1:0] sel;
	output reg [15:0] out;
		
	always@(*)
	begin
		if(sel == 2'b00)
				out = {Zeros8, RegA};
		else if(sel == 2'b01)
				out = {Zeros8, RegB};
		else if(sel == 2'b10)
				out = RegC;
		else 
				out = Zeros;
	end
endmodule
	

		


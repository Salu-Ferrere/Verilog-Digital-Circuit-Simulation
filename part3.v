module part3 (digit_in, op_in, execute_in, reset, data_in, op, Clock, data_out);
	input [3:0] data_in, op;
	input digit_in, op_in, execute_in, reset, Clock;
	output [15:0] data_out;
	

	
	wire [7:0] Reg_A, Reg_B;
	wire [3:0] op_sel;
	wire [15:0] Reg_R, Result, Zeros, out;
	wire Clear, ld_a, ld_b, ld_r, ld_op;
	wire [1:0] Disp_sel;
	wire [7:0] Zeros8;
	
	assign Zeros = 8'b0;
	assign Zeros = 16'b0;
	
	Control_Unit_FSM(digit_in, op_in, execute_in, reset, ld_a, ld_b, ld_op, ld_r, Disp_sel, Clock, Clear);

	shift8(data_in, Clear, ld_a, Clock, Reg_A);

	shift8(data_in, Clear, ld_b, Clock, Reg_B);

	data_reg4(op, Clear, ld_op, Clock, op_sel);
	Arithmatic (Reg_A, Reg_B, op_sel, Reg_R);

	data_reg16(Reg_R, clear, ld_r, Clock, Result);
	mux3to1 (Reg_A, Reg_B, Result, Zeros8, Zeros, Disp_sel, out);
	
	assign data_out = out;
	
	
	
	

endmodule

module Control_Unit_FSM (digit_in, op_in, execute_in, reset, id_a, id_b, id_op, id_r, disp_sel, Clock, clear);
	input digit_in, op_in, execute_in, reset, Clock;
	output reg clear, id_a, id_b, id_r, id_op;
	output reg [1:0] disp_sel;
	reg [3:1] y;
	parameter [3:1] I = 3'b000, A = 3'b001, O = 3'b010, B = 3'b011, R = 3'b100;

	
	always@(posedge Clock)
	if(reset) y <= I;
	else
	begin
			case(y)
				I: begin 
					disp_sel <= 2'b11;
					y <= A;
					end
					
				
				A: begin
					if(digit_in) 
					begin
					disp_sel <= 2'b00;
					y <= A;
					id_a <= 1;
					end
				   else if(op_in) 
					begin
					y <= O;
					id_a <= 0;
					end
					else 
					begin
					y <= A;
					id_a <= 0;
					end
					end
				
				O: begin
               y <= B;
					end
				
				B: begin
					if(digit_in) 
					begin
					disp_sel <= 2'b01;
					y <= B;
					id_b <= 1;
					end
				   else if(execute_in)
					begin
					y <= R;
					id_b <= 0;
					end
					else 
					begin
					y <= B;
					id_b <= 0;
					end
					end
				
				R: begin
					disp_sel <= 2'b10;
					end
					
				default: y <= 3'bxxx;
			endcase
		
			clear <= (y == I);
			id_op <= (y == O);
			id_r <= (y == R);
	end
endmodule

//8 bit shift register
module shift8 (Digit, clear, load_enable, Clock, out);
	input [3:0]Digit;
	input clear, load_enable, Clock;
	output reg [7:0] out;
	integer k;
	
	always@(posedge Clock)
		if(clear)
			out <= 8'd0;
	else if (load_enable)
	begin
		begin
		for(k=0; k<4; k=k+1)
			out[k+4] <= out[k];
		end
		begin
		for(k=0; k<4; k=k+1)
		   out[k] <= Digit[k];
		end
	end
endmodule

//4 bit register
module data_reg4(Operation, clear, load_enable, Clock, out);
	input [3:0]Operation;
	input clear, load_enable, Clock;
	output reg [3:0] out;
	
	always@(posedge Clock)
		if(clear)
			out <= 4'd0;
	else if (load_enable)
	begin
		out <= Operation;
	end
endmodule

//16 bit register
module data_reg16(Digit, clear, load_enable, Clock, out);
	input [15:0]Digit;
	input clear, load_enable, Clock;
	output reg [15:0] out;
	
	always@(*)
		if(clear)
			out <= 16'd0;
	else if (load_enable)
	begin
		out <= Digit;
	end
endmodule

//3 to 1 mux
module mux3to1 (RegA, RegB, Result, Zeros8, Zeros, disp_sel, data_out);
	input [7:0] RegA, RegB;
	input [15:0] Result, Zeros;
	input [1:0] disp_sel;
	input [7:0] Zeros8;
	output reg [15:0] data_out;
		
	always@(*)
	begin
		if(disp_sel == 2'b00)
				data_out <= {Zeros8, RegA};
		else if(disp_sel == 2'b01)
				data_out <= {Zeros8, RegB};
		else if(disp_sel == 2'b10)
				data_out <= Result;
		else if(disp_sel == 2'b11)
				data_out <= Zeros8;
	end
endmodule

//Arithmatic Unit
module Arithmatic (RegA, RegB, op_sel, Result);
	input [7:0] RegA, RegB;
	input [3:0] op_sel;
	output reg [15:0] Result;
	reg [15:0] Binary;
	integer i;
	
	always@(*)
	begin
		if(op_sel == 4'b0001)
			begin
				Binary = (RegA[3:0] * RegB[3:0])+((RegA[7:4]*10) * (RegB[7:4]*10))+((RegA[7:4]*10) * RegB[3:0])+(RegA[3:0] * (RegB[7:4]*10));
			end
		else if(op_sel == 4'b0010)
			begin
				Binary = (RegA[3:0] - RegB[3:0])+((RegA[7:4]*10) - (RegB[7:4]*10));
			end
		else if(op_sel == 4'b0100)
			begin
				Binary = (RegA[3:0] + RegB[3:0])+((RegA[7:4]*10) + (RegB[7:4]*10));
			end
	end
			
	always @(Binary) 
	begin
		Result=0;		 	
		for (i=0;i<16;i=i+1) 
			begin					                                  //Iterate once for each bit in input number
				if (Result[3:0] >= 5) Result[3:0] = Result[3:0] + 3;	  	//If any Result digit is >= 5, add three
				if (Result[7:4] >= 5) Result[7:4] = Result[7:4] + 3;
				if (Result[11:8] >= 5) Result[11:8] = Result[11:8] + 3;
				if (Result[15:12] >= 5) Result[15:12] = Result[15:12] + 3;
				Result = {Result[14:0],Binary[15-i]};				       //Shift one bit, and shift in proper bit from input 
			end
	end
			
endmodule



		
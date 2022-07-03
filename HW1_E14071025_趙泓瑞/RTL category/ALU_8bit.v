module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;

wire 	[6:0]ccout;
wire 	[7:0] result;
reg 	less_0;
reg 	zero;
reg 	com_result;
wire     overflow;
wire     combset;


ALU_1bit alu0(.result(result[0]), .c_out(ccout[0]), .set(), .overflow(), .a(ALU_src1[0]), .b(ALU_src2[0]), .less(com_result), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op));

ALU_1bit alu1(.result(result[1]), .c_out(ccout[1]), .set(), .overflow(), .a(ALU_src1[1]), .b(ALU_src2[1]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[0]), .op(op));

ALU_1bit alu2(.result(result[2]), .c_out(ccout[2]), .set(), .overflow(), .a(ALU_src1[2]), .b(ALU_src2[2]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[1]), .op(op));

ALU_1bit alu3(.result(result[3]), .c_out(ccout[3]), .set(), .overflow(), .a(ALU_src1[3]), .b(ALU_src2[3]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[2]), .op(op));

ALU_1bit alu4(.result(result[4]), .c_out(ccout[4]), .set(), .overflow(), .a(ALU_src1[4]), .b(ALU_src2[4]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[3]), .op(op));

ALU_1bit alu5(.result(result[5]), .c_out(ccout[5]), .set(), .overflow(), .a(ALU_src1[5]), .b(ALU_src2[5]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[4]), .op(op));

ALU_1bit alu6(.result(result[6]), .c_out(ccout[6]), .set(), .overflow(), .a(ALU_src1[6]), .b(ALU_src2[6]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[5]), .op(op));

ALU_1bit alu7(.result(result[7]), .c_out(), .set(combset), .overflow(overflow), .a(ALU_src1[7]), .b(ALU_src2[7]), .less(less_0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(ccout[6]), .op(op));

always @(*)
	begin	
		less_0 = 0;
		com_result=(combset^overflow);
	end


always @(*)
	begin
		zero=~(result[0]|result[1]|result[2]|result[3]|result[4]|result[5]|result[6]|result[7]);
	end


endmodule

module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output       result;
output       c_out;
output       set;                 
output       overflow;      

reg	 	Ainvert_result , Binvert_result ;
reg		result;            
reg		overflow;   

	always@(*)begin
		if (Ainvert==0)
			begin
				Ainvert_result = a;
			end
		else 
			begin
				Ainvert_result=~a;
			end
	end
	always@(*)begin
		if (Binvert==0)
			begin
				Binvert_result=b;
			end
		else 
			begin
				Binvert_result=~b;
			end
	end

	FA alu1fa (.s(set), .carry_out(c_out), .x(Ainvert_result), .y(Binvert_result), .carry_in(c_in));
	always@(*)begin
			overflow=(c_in^c_out);
		end
	always@(*)begin
		case(op)
			2'b00:result=(Ainvert_result & Binvert_result);
			2'b01:result=(Ainvert_result | Binvert_result);
			2'b10:result=set;
			default:result=less;
		endcase
		
	end
endmodule

module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output reg			valid;
output  			encode;
output reg 			finish;
output reg 	[3:0] 	offset;
output reg	[2:0] 	match_len;
output reg 	[7:0] 	char_nxt;

/* write your code here ! */
//by e14071025
reg			[2:0]	current_state, next_state;
reg			[11:0]	counter;
reg			[3:0]	search_index;
reg			[2:0]	lookahead_index;
reg			[7:0]	str_buffer	[2047:0];
reg			[7:0]	search_buffer	[3:0];

wire				equal	[3:0];
wire		[11:0]	current_encode_len;
wire		[2:0]	curr_lookahead_index;
wire		[7:0]	match_char [6:0];

integer i;

assign	encode = 1'b1;


assign	match_char[0] = search_buffer[search_index];
assign	match_char[1] = (search_index >= 1) ? search_buffer[search_index-1] : str_buffer[search_index];
assign	match_char[2] = (search_index >= 2) ? search_buffer[search_index-2] : str_buffer[1-search_index];
assign	match_char[3] = (search_index >= 3) ? search_buffer[search_index-3] : str_buffer[2-search_index];


assign	equal[0] = (search_index <= 3) ? ((match_char[0]==str_buffer[0]) ? 1'b1 : 1'b0) : 1'b0;
assign	equal[1] = (search_index <= 3) ? ((match_char[1]==str_buffer[1]) ? equal[0] : 1'b0) : 1'b0;
assign	equal[2] = (search_index <= 3) ? ((match_char[2]==str_buffer[2]) ? equal[1] : 1'b0) : 1'b0;
assign	equal[3] =  1'b0;



assign	current_encode_len = counter+match_len+1;
assign	curr_lookahead_index = lookahead_index+1;


always @(posedge clk or posedge reset)
begin
	if(reset)
	begin
		current_state <= 0;
		counter <= 12'd0;
		search_index <= 4'd0;
		lookahead_index <= 3'd0;
		valid <= 1'b0;
		finish <= 1'b0;
		offset <= 4'd0;
		match_len <= 3'd0;
		char_nxt <= 8'd0;

		search_buffer[0] <= 4'd0;
		search_buffer[1] <= 4'd0;
		search_buffer[2] <= 4'd0;
		search_buffer[3] <= 4'd0;

	end
	else
	begin
		current_state <= next_state;
		
		case(current_state)
			0:
			begin
				str_buffer[counter] <= chardata[3:0];
				counter <= (counter==2047) ? 0 : counter+1;
			end
			1:
			begin
				if(equal[match_len]==1 && search_index < counter && current_encode_len <= 2048)
				begin
					char_nxt <= str_buffer[curr_lookahead_index];
					match_len <= match_len+1;
					offset <= search_index;

					lookahead_index <= curr_lookahead_index;
				end
				else
				begin
					search_index <= (search_index==15) ? 0 : search_index-1;
				end
			end
			2:
			begin
				valid <= 1;
				// offset <= offset;
				// match_len <= match_len;
				char_nxt <= (current_encode_len==2049) ? 8'h24 : (match_len==0) ? str_buffer[0] : char_nxt;
				counter <= current_encode_len;
			end
			3:
			begin
				finish <= (counter==2049) ? 1 : 0;
				offset <= 0;
				valid <= 0;
				match_len <= 0;
				search_index <= 3;
				lookahead_index <= (lookahead_index==0) ? 0 : lookahead_index-1;

				search_buffer[3] <= search_buffer[2];
				search_buffer[2] <= search_buffer[1];
				search_buffer[1] <= search_buffer[0];
				search_buffer[0] <= str_buffer[0];

				for (i=0; i<2047; i=i+1) begin
					str_buffer[i] <= str_buffer[i+1];
				end
			end
		endcase
	end
end



always @(*)
begin
	case(current_state)
		0:
		begin
			next_state = (counter==2047) ? 1 : 0;
		end
		1:
		begin
			next_state = (search_index==15 || match_len==2) ? 2 : 1;
		end
		2:
		begin
			next_state = 3;
		end
		3:
		begin
			next_state = (lookahead_index==0) ? 1 : 3;
		end
		default:
		begin
			next_state = 0;
		end
	endcase
end

endmodule

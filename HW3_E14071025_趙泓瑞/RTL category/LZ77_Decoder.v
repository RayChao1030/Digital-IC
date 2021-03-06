module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output 			reg   encode;
output    reg 		finish;
output    reg 	 	[7:0] 	char_nxt;

reg 	 	[2:0] 	count;
reg 	 	[7:0] 	search_buffer [8:0];

always@(posedge clk or posedge reset)
begin
    if(reset)begin
        count <= 0;
        end
    else if(count == code_len)begin
	count <= 0;
      end
    else begin
        count <= count + 1;
        end
end

always@(posedge clk or posedge reset)
begin
	if (reset)
	begin
		encode <= 0;
		finish<=0;
	end
 else if((chardata == 8'h24)&&(count == code_len))begin
        encode <= 1;
        finish <= 1;
        end
    else begin
        encode <= 0;
        finish <= 0;
        end
end

always@(posedge clk or posedge reset)
begin
    if(reset)begin
			 search_buffer[0] <= 0;
          search_buffer[1] <= 0;
          search_buffer[2] <= 0;
          search_buffer[3] <= 0;
          search_buffer[4] <= 0;
          search_buffer[5] <= 0;
          search_buffer[6] <= 0;
          search_buffer[7] <= 0;
          search_buffer[8] <= 0;
	end
	else if( count == code_len )
    begin
          search_buffer[0] <= chardata;
          search_buffer[1] <= search_buffer[0];
          search_buffer[2] <= search_buffer[1];
          search_buffer[3] <= search_buffer[2];
          search_buffer[4] <= search_buffer[3];
          search_buffer[5] <= search_buffer[4];
          search_buffer[6] <= search_buffer[5];
          search_buffer[7] <= search_buffer[6];
          search_buffer[8] <= search_buffer[7];
      end
    else begin
          search_buffer[0] <= search_buffer[code_pos];
          search_buffer[1] <= search_buffer[0];
          search_buffer[2] <= search_buffer[1];
          search_buffer[3] <= search_buffer[2];
          search_buffer[4] <= search_buffer[3];
          search_buffer[5] <= search_buffer[4];
          search_buffer[6] <= search_buffer[5];
          search_buffer[7] <= search_buffer[6];
          search_buffer[8] <= search_buffer[7];
        end
end

always@(*)
begin
    if(reset == 0)
        char_nxt  = search_buffer[0];
end

endmodule

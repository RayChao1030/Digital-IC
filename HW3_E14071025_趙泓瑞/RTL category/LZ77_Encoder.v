module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output   reg		valid;
output  	reg		encode;
output  	reg		finish;
output  reg		[3:0] 	offset;
output 	reg	[2:0] 	match_len;
output 	reg 	[7:0] 	char_nxt;

reg  change_state;
reg [7:0] lookahead_buffer[2057:0];
reg [11:0] count_l;
reg signed [4:0] count_m;
reg [3:0] count_s;
reg [3:0] k;
reg [2:0] state;
integer idx;

always@(posedge clk or posedge reset)
begin
   if(reset)begin
     if(state == 0)
          state <= 1;//storing data
     else
    	     state <= 0;
	 end
   else if((change_state == 1)||((count_s < 0)))
          state <= 2;	//ecoding
   else if(((state == 3)||(state == 6))&&(lookahead_buffer[count_l]==8'h24)&&(count_s == match_len)) 
          state <= 5;	//8h'24 occur
   else if((state == 3)||(state == 6)||((state == 4)&&(count_s > 0)))
          state <= 4;
   else if(match_len == 0)
          state <= 3;	//ecoding finish
   else if((count_s == match_len)&&(match_len != 0))
          state <= 6;	//ecoding finish
end

always@(*)begin//encode valid finish
  case(state)
	0:begin//reset
		encode = 0;
		valid = 0;
		finish = 0;  
	end
 	1:begin//storing data
		encode = 0;
		valid = 0;
		finish = 0;
	end
	2:begin//ecoding
	  finish = 0; 
	  encode = 1;
	  valid = 0;
	end
	3,6:begin//ecoding
	  finish = 0; 
	  encode = 1;
	  valid = 1;
	end
	4:begin//ecoding
	  finish = 0; 
	  encode = 1;
	  valid = 0;
	end
	default:begin 
	  encode = 1;
		finish = 1;
		valid = 0;
	end
  endcase
end

always@(*)begin
      char_nxt = lookahead_buffer[count_l];
end

always@(*)begin
case(state)
    1:begin
      if(count_l==2058)
        change_state = 1;
		  else
			   change_state = 0;
end
     2:begin
       if(((count_s == match_len)&&(offset==0))||((count_s == match_len)&&(match_len != 0)))
         change_state = 0;
		  else
			   change_state = 1;
     end
	   4:begin
	     if(count_s == 0)
	       change_state = 1;
		    else
		    change_state = 0;
    end
     default:begin
			   change_state = 0; 
     end
	 endcase
end
always@(posedge clk or posedge reset)begin//count_m
if(reset)begin
		count_m <= 8;
end
else begin
  case(state)
    2:begin
    if((offset+1) >= match_len)begin
      if((lookahead_buffer[count_m]==lookahead_buffer[count_l]))begin
        if (count_s != match_len)
           count_m <= count_m - 1;
        else if (count_s == match_len)
	          count_m <= count_m;
			else 
				count_m <= count_m;   
	    end
	    else begin
	       if(count_s == match_len)
	           count_m <= count_m;
	       else if(offset>0)
      	     count_m <= offset - 1;
  	      else if (match_len == 1)
      	     count_m <= 0;
	       else if(match_len != 1)
      	     count_m <= 8;
			   else 
					   count_m <= count_m;
	       end
  end
    else if((lookahead_buffer[count_m]==lookahead_buffer[count_l])&&(count_m >= 0))
          count_m <= count_m - 1;
    else if((lookahead_buffer[count_l-count_s+k]==lookahead_buffer[count_l])&&(count_m < 0)&&(count_s<=match_len))begin //match
	           count_m <= count_m;
	        end
	  else begin
	       if(count_s == match_len)
	           count_m <= count_m;
	       else if(offset>0)
      	     count_m <= offset - 1;
  	      else if (match_len == 1)
      	     count_m <= 0;
	       else if(match_len != 1)
      	     count_m <= 8;
			   else 
					 count_m <= count_m;
	     end
end
	  3,6:begin
	  count_m <= count_m;
	  end
	  4:begin
	  if(count_s == 0)
	    count_m <= 8;
	  else
	    count_m <= count_m;
end
    default:begin
	 count_m <= count_m;
	 end
	 endcase
	end
end

always@(posedge clk or posedge reset)begin//abs_pos
if(reset)begin
		offset <= 8;
end
else begin
   case(state)
     2:begin
    if((offset+1) >= match_len)begin
      if((lookahead_buffer[count_m] == lookahead_buffer[count_l]))begin//match 
         offset <= offset;
	       end
	     else begin
	         if(count_s == match_len)
	             offset <= offset;
	         else if(offset>0)
      	       offset <= offset - 1;
	         else if (match_len == 1)
    	         offset <= 0;
	         else if(match_len != 1)
      	       offset <= 8;
			     else 
					     offset <= offset;
	      end
    end
    else begin
      if((lookahead_buffer[count_m] == lookahead_buffer[count_l])&&(count_m >= 0))begin
            offset <= offset;
      end
      else if((lookahead_buffer[count_l-count_s+k]==lookahead_buffer[count_l])&&(count_m < 0)&&((count_s)<=match_len))begin //match
            offset <= offset;
	        end
	    else begin
	       if(count_s == match_len)
	           offset <= offset;
	       else if(offset > 0)
      	     offset <= offset - 1;
	       else if (match_len == 1)
      	     offset <= 0;
	       else if(match_len != 1)
      	     offset <= 8;
			   else 
					 offset <= offset;
	    end
	  end
end
	 3,6:begin
	   offset <= count_s;
	   end
	 4:begin
	   if(count_s == 0)
	     offset <= 8;
	   else
	     offset <= offset;
	 end
	   default:begin
				offset <= offset;
	   end
	 endcase
	end
end

always@(posedge clk or posedge reset)begin//k
if(reset)begin
		k <= 0;
end
else begin
   case(state)
     2:begin
    if((lookahead_buffer[count_l-count_s+k]==lookahead_buffer[count_l])&&(count_m < 0)&&((count_s)<=match_len))begin //match
          k <= k + 1;
	        end
	  else   
	        k <= 0;
	 end
	   default:begin
	    k <= 0;
	    end
	 endcase
	end
end

always@(posedge clk or posedge reset)begin
if(reset)begin
		count_l <= 9;
end
else begin
  case(state)
    1:begin
		    if(count_l > 2057)
			     count_l <= 9;
		    else begin
			     count_l <= count_l + 1;
		    end
	   end
    2:begin
      if(((lookahead_buffer[count_m]==lookahead_buffer[count_l])&&(match_len > count_s))||((((lookahead_buffer[count_m]==lookahead_buffer[count_l])&&(count_m >= 0))||((lookahead_buffer[count_l-count_s+k]==lookahead_buffer[count_l])&&(count_m < 0)))&&(count_s < match_len)))
        count_l <= count_l + 1;//continue
      else if(match_len == count_s)
	     count_l <= count_l ;//successs
	    else 
	       count_l <= count_l - count_s;
	 end
	  3,6:begin 
	  count_l <= count_l;
	  end
	  4:begin
	     if(count_s == 0)
	       count_l <= count_l + 1;
		    else
			     count_l <= count_l;
	    end
	 default:begin 
	       count_l <= 9;
	 end
	 endcase
	end
end

always@(posedge clk or posedge reset)begin//count_s//means how many have counted in the pos & length //offset
if(reset)begin
		count_s <= 0;
end
else begin
  case(state)
    2:begin//7
      if((((lookahead_buffer[count_m]==lookahead_buffer[count_l])&&(count_m >= 0)&&(match_len >= count_s))||((lookahead_buffer[count_l-count_s+k]==lookahead_buffer[count_l])&&(count_m < 0)))&&(count_s < match_len))
         count_s <= count_s + 1;//continue       
	    else if(match_len == count_s)//success
	        count_s <= count_s; 
	    else 
	         count_s <= 0; 
	  end
	  4:begin
	  if(count_s > 0)
	      count_s <= count_s - 1;
		else 
				count_s <= count_s;
	  end
	  default:begin
				count_s <= count_s;
	 end  
	 endcase
	end
end

always@(posedge clk or posedge reset)begin//match_len
if(reset)begin
		match_len <= 7;
end
else begin
   case(state)
     2:begin
    if((offset+1) >= match_len)begin
      if((lookahead_buffer[count_m] == lookahead_buffer[count_l]))begin//match 
         match_len <= match_len;
	       end
	    else begin
	       if((count_s == match_len)||(offset != 0))
	           match_len <= match_len;
	       else 
      	     match_len <= match_len - 1;
	      end
    end
    else begin
      if(((lookahead_buffer[count_m] == lookahead_buffer[count_l])&&(count_m >= 0))||((lookahead_buffer[count_l-count_s+k]==lookahead_buffer[count_l])&&(count_m < 0)&&(count_s<=match_len)))begin
            match_len <= match_len;
      end
	    else begin
	       if((count_s == match_len)||(offset != 0))
	           match_len <= match_len;
	       else 
      	     match_len <= match_len - 1;
	       end
	   end
 end
	   4:begin
	     if(count_s == 0)
	       match_len <= 7;
	     else
	       match_len <= match_len;
	     end 
	   default:begin 
	   match_len <= 7;
	   end
	 endcase
	 end
end

always@(posedge clk or posedge reset)begin
if(reset)begin
		for(idx=0; idx <2058; idx = idx +1)begin
					lookahead_buffer[idx] <= 0;
				end
end
else begin
  case(state)
    1:begin
		    if(count_l <= 2057)begin
		      lookahead_buffer[count_l] <= chardata;
		  end
		  else begin
				for(idx=0; idx <2058; idx = idx +1)begin
					lookahead_buffer[idx] <= lookahead_buffer[idx];
				end
		  end
	 end
	   4:begin
	     if(count_s >= 0)begin
	       lookahead_buffer[0] <= lookahead_buffer[count_l-count_s];
	       lookahead_buffer[1] <= lookahead_buffer[0];
	       lookahead_buffer[2] <= lookahead_buffer[1];
	       lookahead_buffer[3] <= lookahead_buffer[2];
	       lookahead_buffer[4] <= lookahead_buffer[3];
	       lookahead_buffer[5] <= lookahead_buffer[4];
	       lookahead_buffer[6] <= lookahead_buffer[5];
			 lookahead_buffer[7] <= lookahead_buffer[6];
         lookahead_buffer[8] <= lookahead_buffer[7];
end
	     else begin
	        for(idx=0; idx <2058; idx = idx +1)begin
              lookahead_buffer[idx] <= lookahead_buffer[idx];
	      end
	   end
	end
    default:begin 
      for(idx=0; idx <2058; idx = idx +1)begin
      lookahead_buffer[idx] <= lookahead_buffer[idx];
    end
	 end
  endcase
 end
end

endmodule

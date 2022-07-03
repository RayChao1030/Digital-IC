`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output				req;
	output				wen;
	output		[9:0]	addr;
	output		[7:0]	data_wr;
	output				done;
	//integer 			idx;
	
	reg				req;
	reg				wen;
	reg		[9:0]	addr;
	wire	[9:0]	addrtmp;
	
	reg		[7:0]	data_wr;
	reg				done;
	
	reg				data_store_finish;
	wire				data_store_finish1;
	reg  	[4:0] countcol;
	wire countcol1;
	wire  	[4:0] countcoladder;
	reg  	[4:0] countrow;
	wire   [8:0]  side_inter;
	wire   [8:0]  side_inter1;
	wire   [7:0]  core_inter;

	wire     [7:0]  core_right;//signed
	wire     [7:0]  core_left;//signed
	
	reg 	[7:0]	data_minus_compare[2:0];
	reg		[7:0]	data_interloping [5:0];
	
	reg		[8:0]	data_interloping1;
	reg		[8:0]	data_interloping2;
	reg		[8:0]	data_interloping3;
	
	reg     [4:0]   counter;
	wire    [4:0]   counterdder;
	wire       counter1;
	
	reg 	[2:0]	state;//0~7
	reg 	[2:0]	nstate;//0~7
	
	reg     set;
	
	//state 0 reset
	//state 1 reading data in GL & pasting data in RL
	//state 2 reading data in RL 
	//state 3 ela interloping (head & tail)
	//state 5 middle
	//state 7 pasting result in RL & shiftimg
	//state 6 finish
	//------------------------------------------------
	
	always@(posedge clk or posedge rst)begin //counter
		if(rst)
			counter <= 0;
		else begin
			case (state)
				2:begin
					if ((counter < 2)&&(data_store_finish == 0)&&(set == 0))
						counter <= counterdder;
					else if ((nstate == 3)&&(countcol == 2))
						counter <= 0;
					else
						counter <= counter ;
				end
				3:begin
					counter <= 2;
				end
				/*4:begin
					if(countcol == 31)
						counter <= 0;
					else
						counter <= 2;
				end*/
				5:begin
					if ((counter1)&&(countcol == 31))
						counter <= 1;
					else if ((counter == 2)&&(countcol == 2))
						counter <= 1;
					else 
						counter <= counter ;
				end
				7:begin
					if(countcol == 31)
						counter <= 0 ;
					else if(counter != 2)
						counter <= 2;
				end
				default: begin
					counter <= counter ;
				end
			endcase
		end
	end
	
	always@(posedge clk or posedge rst)begin //state
		if(rst)
			state <= 0;
		else 
			state <= nstate;
	end
	
	assign counter1 = (counter == 2) ? 1:0;
	
	always@(*)begin //nstate
			case(state)
				0:begin
					nstate = 1;
				end
				1:begin
					if (addr == 991)
						nstate = 2;
					else
						nstate = 1;
					end
				2:begin
					if ((counter1)&&(data_store_finish == 0)&&(countcol == 31))
						nstate = 3;
					else if ((counter1)&&(data_store_finish == 0)&&(countcol == 2))
						nstate = 3;
					else if ((counter1)&&(data_store_finish == 0))
						nstate = 5;
					else if (countrow == 30)
						nstate = 6;
					else
						nstate = 2;
				end
				3:begin
						nstate = 5;
				end
				/*4:begin
						nstate = 2;
				end*/
				5:begin
					if(addr == 991)
						nstate = 6;
					if (counter == 2)
						nstate = 7;
					else
						nstate = 5;
				end
				7:begin
					if (counter1||(counter==0))
						nstate = 2;
					else
						nstate = 7;
				end
				default:begin
						nstate = 0;//nstate
				end
			endcase
	end
	assign counterdder = counter + 1;
	assign countcoladder = countcol + 1;
	assign countcol1 = (countcol < 31) ? 1:0;
	always@(posedge clk or posedge rst)begin //countcol
		if(rst) 
			countcol <= 0;
		else begin 
			case(state)
				1:begin
					if(countcol1&&(set == 0))
						countcol <= countcoladder;//countcol + 1;
					else
						countcol <= 0;
				end
				2:begin
					if((!counter1)&&(countcol1)&&(data_store_finish1))
						countcol <= countcoladder;//countcol + 1;
					else 
						countcol <= countcol;
				end
				7:begin
					if((counter1) && countcol1 )
						countcol <= countcoladder;//countcol + 1;
					else if((countcol==31)&&(counter==0))
						countcol <= 0;
					else 
						countcol <= countcol;
				end
				default:begin
					countcol <= countcol;
				end
			endcase
		end
	end
	
	always@(posedge clk or posedge rst)begin //countrow
		if(rst)
			countrow <= 0;
		else begin
			case(state)
				1:begin
					if((countrow != 30)&&(countcol == 31))
						countrow <= countrow + 2 ;
					else if(countcol == 31)
						countrow <= 0;
					else
						countrow <= countrow;
				end
				7:begin
					if((counter1||(counter==0))&&(countrow != 30)&&(countcol == 31))
						countrow <= countrow + 2 ;
					else
						countrow <= countrow;
				end
				default:begin
					countrow <= countrow;
				end
		endcase
	end
end
	
	always@(*)begin //data_minus_compare
		//if(rst)begin
			//data_minus_compare[0] = 0;
			//data_minus_compare[1] = 0;
			//data_minus_compare[2] = 0;
			//end
		//else begin
			case(state)
				0:begin
					data_minus_compare[0] = 0;
					data_minus_compare[1] = 0;
					data_minus_compare[2] = 0;
				end
				2,3,5:begin
					data_minus_compare[0] = core_left;
					data_minus_compare[1] = core_inter;
					data_minus_compare[2] = core_right;
					end	
				default:begin
					data_minus_compare[0] = core_left;
					data_minus_compare[1] = core_inter;
					data_minus_compare[2] = core_right;
				end
			endcase
			end
	//end
	
	always@(*)begin
		//if(rst)begin
			//data_interloping1 = 0;
		//end
		//else begin
			case(state)
				3,5,7:begin
					if(countcol==2)
						data_interloping1 = side_inter1;
					else
						data_interloping1 = 0;//data_interloping1;
				end
				default:begin
					data_interloping1 = 0;//data_interloping1; //data_interloping1;
				end
			endcase
		end
	//end
	
	always@(*)begin
		//if(rst)begin
			//data_interloping3 = 0;
		//end
		//else begin
			case(state)
				3,5,7:begin
					if(countcol==31)
						data_interloping3 = side_inter;
					else
						data_interloping3 = 0;//data_interloping3;
				end
				default:begin
					data_interloping3 = 0;//data_interloping3;
				end
			endcase
		end
	//end
	
	always@(*)begin
		//if(rst)begin
			//data_interloping2 = 0;
		//end
		//else begin
			case(state)
				0:begin
					data_interloping2 = 0;
				end
				5,7:begin
					if((data_minus_compare[1] <= data_minus_compare[0])&&(data_minus_compare[1] <= data_minus_compare[2]))
						data_interloping2 = (data_interloping[4] + data_interloping[1]);
					else if((data_minus_compare[0] <= data_minus_compare[1])&&(data_minus_compare[0] <= data_minus_compare[2]))
						data_interloping2 = (data_interloping[5] + data_interloping[0]);
					else 
						data_interloping2 = (data_interloping[3] + data_interloping[2]);
				end
				default:begin
					data_interloping2 = 0;//data_interloping2;
				end
			endcase
		end
	//end
	
	always@(posedge clk or posedge rst)begin//data_interloping
		if(rst)begin
			data_interloping[0] <= 0;
			data_interloping[1] <= 0;
			data_interloping[2] <= 0;
			data_interloping[3] <= 0;
			data_interloping[4] <= 0;
			data_interloping[5] <= 0;
		end
		else begin
			case(state)
				2:begin
					if(data_store_finish == 0)
						data_interloping[counter] <= data_rd;
					else
						data_interloping[counter+3] <= data_rd;
				end
				7:begin
					if (counter1)begin
						if(countcol != 31)begin
							data_interloping[0] <= data_interloping[1];
							data_interloping[1] <= data_interloping[2];
							data_interloping[2] <= 0;
							data_interloping[3] <= data_interloping[4];
							data_interloping[4] <= data_interloping[5];
							data_interloping[5] <= 0;
						end
						else begin
							data_interloping[0] <= 0;
							data_interloping[1] <= 0;
							data_interloping[2] <= 0;
							data_interloping[3] <= 0;
							data_interloping[4] <= 0;
							data_interloping[5] <= 0;
						end
					end
				end
				default:begin
					data_interloping[0] <= data_interloping[0];
					data_interloping[1] <= data_interloping[1];
					data_interloping[2] <= data_interloping[2];
					data_interloping[3] <= data_interloping[3];
					data_interloping[4] <= data_interloping[4];
					data_interloping[5] <= data_interloping[5];
				end
		endcase
	end
end
	
	assign	core_left = (data_interloping[0] >= data_interloping[5])?(data_interloping[0] - data_interloping[5]):(data_interloping[5] - data_interloping[0]);

	assign	core_right = (data_interloping[2]>= data_interloping[3])?(data_interloping[2] - data_interloping[3]):(data_interloping[3] - data_interloping[2]);

	assign	core_inter = (data_interloping[1] >= data_interloping[4])?(data_interloping[1] - data_interloping[4]):(data_interloping[4] - data_interloping[1]);
	
	always@(posedge clk or posedge rst)begin//data_store_finish
	if(rst)
		data_store_finish <= 0;
	else begin
			case(state)
				1:begin
					if(addr == 991)
						data_store_finish <= 1;
					else
						data_store_finish <= data_store_finish;
				end
				2:begin
					if(data_store_finish != 0)
						data_store_finish <= 0;
					else
						data_store_finish <= 1;	
				end
				7:begin
						data_store_finish <= 1;
				end
				default:begin
					data_store_finish <= 0;
				end
			endcase
		end
	end
	
	assign	side_inter = (data_interloping[counter+4] + data_interloping[counterdder]);
	assign	side_inter1 = (data_interloping[counter-1] + data_interloping[counter+2]);
	assign   data_store_finish1 = (data_store_finish == 0)? 1 : 0;
	always@(*)begin //data_wr
		//if(rst)
			//data_wr = 0 ;	
		//else begin
			case(state)
				1:begin
					if(addr < 992)
						data_wr = in_data ;
					else if (!data_store_finish1)
						data_wr = 0;
					else
						data_wr = 0;
				end
				7:begin
					if ((counter1)||(counter==0))
						data_wr = data_interloping2>>1;
					else if(countcol==2)
						data_wr = data_interloping1>>1;
					else if (countcol==31)
						data_wr = data_interloping3>>1;
					else
						data_wr = 0;
				end
				default:begin
					data_wr = 0;
				end
				endcase
			end
	//end

	assign addrtmp = (countrow<<5) + countcol  ;
	
	always@(*)begin //addr
		//if(rst)
			//addr = 0;
		//else begin
			case(state)
				1:begin
					addr =  addrtmp;//countrow * 32 + countcol  ;
				end
				2:begin
					if(data_store_finish1)
						addr =  addrtmp;
					else if(countrow < 30)
						addr =  addrtmp + 64;
					else
						addr =  addrtmp;
				end

				7:begin
					if((counter1)||(counter==0))
						addr = addrtmp + 31;// (countrow+1) * 32 + (countcol) -1;
					else if (countcol == 2)
						addr =  addrtmp + 30;//(countrow+1) * 32 + (countcol) -2;
					else if (!countcol1)
						addr =  addrtmp + 32;//(countrow+1) * 32 + (countcol) ;
					else
						addr =  addrtmp;
				end
				default:begin
					addr = 0;
				end
			endcase
		end
	//end
	
	always@(*)begin //set
			//if(rst)
				//set = 0;
		//else begin
			case(state)
				0:begin
					set = 1;
				end
				1:begin
					if (req == 1)
						set = 0;
					else if(addr==991)
						set = 1;
					else if( set == 1)
						set = 1;
					else
						set = 0;
				end
				2:begin
					if(data_store_finish1)
						set = 0;
					else if( set == 1)
						set = 1;
					else
						set = 0;
				end
				default:begin
					set = 0;
				end
			endcase
		end
	//end
	
	always@(*)begin //done
		//if(rst)
				//done = 0;
		//else begin
				case(state)
					6:begin
						done = 1;
					end
					default:begin
						done = 0;
					end
				endcase
			end
	//end
	
	always@(posedge clk or posedge rst)begin //req
		if(rst)
				req <= 0;
		else begin
				case(state)
				1:begin
					if(data_store_finish1)
						if((countcol == 0)||(!countcol1))begin
							req <= 1;
						end
					else begin
						req <= 0;
					end
				end
				default:begin
						req <= 0;
					end
				endcase
			end
		end
	
	always@(*)begin //wen
	//if(rst)
		//	wen = 0;
	//else begin
			case(state)
				1,7:begin
					wen = 1;
				end
				default:begin//2
					wen = 0;
				end
			endcase
		//end
	end
	
	//----------------------------------------------
endmodule
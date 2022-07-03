module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output reg [10:0] result;

reg [2:0] num,count,countdata;
reg [3:0] state;
reg [7:0] dataa [7:0];
reg [7:0] min;

always@(posedge clk or posedge rst)
begin
      if(rst)begin
          num <=0;
          count <=0;
          countdata <=0;
          state<=1;
          result<=0;
          dataa[0]<=0;
          dataa[1]<=0;
          dataa[2]<=0;
          dataa[3]<=0;
          dataa[4]<=0;
          dataa[5]<=0;
          dataa[6]<=0;
          dataa[7]<=0;
          min<=0;
      end
      else if(clk)
      begin
        case(state)
          1:begin
            num <= data_num;
            dataa[0] <= data_in;
            result <= data_in;
            state <= 2;
            min <= data_in;
            count <=1;
          end
          2:begin
            if(count<=num-1)begin
            dataa[count] <= data_in;
            result <= result + data_in;
            count <= count + 1;
            state <= 2;
                if(min<data_in)
                  begin
                    min <= data_in;
                  end
                else begin  
                    min <= min; 
                  end  
            end
            else begin
            state <= 3;
            end
          end
          3:
          begin 
            state <= 4;
          end
          4:
          begin 
            state <= 5;
          end
          5:
          begin 
            if(count!=0)begin
            count <= count - 1;
            state <= 5;
            end
            else begin
            state <= 1;
            end 
          end
          default:
          begin end
    endcase
      end
end

always@(*)
begin
    case(state)
          1,2:begin
          end
          3:begin
            end
          4:begin 
          result = min; 
          end
          5:  
          begin 
            if(count!=0)begin
            result = dataa[count];
            end
            else begin
            end 
          end
      default:begin end
    endcase
end
endmodule
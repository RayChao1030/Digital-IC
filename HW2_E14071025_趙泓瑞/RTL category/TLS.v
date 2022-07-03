module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output          Gout;
output          Yout;
output          Rout;

reg          Gout;
reg          Yout;
reg          Rout;
reg    [3:0] Gsignal;
reg    [3:0] Ysignal;
reg    [3:0] Rsignal;
reg   [4:0]  count;
reg   [3:0]  change_signal,nchange_signal;
reg [2:0] state,Nextstate;

parameter mreset=0;
parameter mset=1;
parameter mstop=2;
parameter mjump=3;
parameter green=4;
parameter yellow=5;
parameter red=6;
parameter idle=7;


always@(posedge clk or posedge reset)
begin
      if(reset)
              begin
                    Gsignal<=0;
                    Ysignal<=0;
                    Rsignal<=0;
                    state<=mreset;
                    count<=0;
                    change_signal<=idle;
              end
      else
              begin
                    state<=Nextstate;
                    if(Set)
                        begin
                              state <= mset;
                              Gsignal<=Gin;
                              Ysignal<=Yin;
                              Rsignal<=Rin;
                              change_signal<= green;
                              count<=1;
                        end
                    else if (Stop)
                        begin
                              count<=count;
                              change_signal<= nchange_signal;
                        end
                    else if (Jump)
                        begin
                              count<=1;
                              change_signal<= nchange_signal;
                        end
                    else
                        begin
                              count=count+1;
                        end
              end
end
always@(*)
begin
      case(state)
      mreset:
            begin
                    Gout=0;
                    Yout=0;
                    Rout=0;
            end
     default:
            case(change_signal)
                idle:
                      begin
                          Gout=0;
                          Yout=0;
                          Rout=0;
                      end
                green:
                      begin
                          Gout=1;
                          Yout=0;
                          Rout=0;
                      end
                yellow:
                      begin
                          Gout=0;
                          Yout=1;
                          Rout=0;
                      end
                default:
                     begin
                          Gout=0;
                          Yout=0;
                          Rout=1;
                      end
            endcase
      endcase
end
always@(*)
begin
      case(state)
      mreset:
            begin
                  Nextstate = mset;
                  change_signal = idle;
            end
      mset: begin
                  if(Stop)
                  begin
                         state = mstop;
                  end
                else if(Jump)
                    begin
                          state = mjump;  
                    end
                else
                  begin
                  Nextstate = mset;
                  case(change_signal)
                                     green: 
                                        begin
                                            if(count==Gsignal+1)
                                                begin
                                                      change_signal=yellow;
                                                      nchange_signal=yellow;
                                                      count=1;
                                                end
                                            else
                                                 begin
                                                      change_signal=green;
                                                      nchange_signal=green;
                                                  end
                                        end
                                      yellow:
                                        begin
                                            if(count==Ysignal+1)
                                                begin
                                                      change_signal=red;
                                                      nchange_signal=red;
                                                      count=1;          
                                                end
                                            else
                                                 begin
                                                      change_signal=yellow;
                                                      nchange_signal=yellow;
                                                  end
                                        end
                                      red:
                                        begin
                                            if(count==Rsignal+1)
                                                begin
                                                      change_signal=green;
                                                      nchange_signal=green;
                                                      count=1;
                                                      
                                                end
                                            else
                                                 begin
                                                      change_signal=red;
                                                      nchange_signal=red;
                                                  end
                                        end
                                      default: begin end
                  endcase
                end
            end
      mstop: 
      begin
             if (Stop)
                          begin
                                Nextstate = mstop;
                                case(change_signal)
                                      green:  nchange_signal=green;
                                      yellow: nchange_signal=yellow;
                                      default:
                                      begin 
                                              nchange_signal=red;
                                      end
                                endcase
                          end
            else if (Jump)
                          begin
                                Nextstate = mjump;
                          end
            else 
                          begin
                                Nextstate = mset;
                          end
     end
      mjump: 
              begin
                  Nextstate = mset;
                  change_signal = red;
                  if(Rsignal>1)
                    begin
                          nchange_signal = red;
                    end
                else
                  begin
                          nchange_signal = green;
                    end
              end
      default:begin
              change_signal=idle; 
      end
      endcase
end
endmodule
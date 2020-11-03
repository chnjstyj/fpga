module led_display(
    input clk,
    input [15:0]tim,
    output reg[3:0] an,
    output reg[6:0] num
    );
    reg[1:0] sign;
    reg[3:0] digit;
    parameter update_interval = 100_000_000 / 1600 - 1;     
    integer selcnt; 
   always @(posedge clk)  //分频160Hz
       begin  
        selcnt <= selcnt + 1;  
              
        if (selcnt == update_interval)  
        begin  
            selcnt <= 0;  
            sign <= sign+ 1;  
        end  
   end
    always @(*) //选择位
    case(sign)
       0:begin an=4'b1110;digit=tim[3:0];end
       1:begin an=4'b1101;digit=tim[7:4];end
       2:begin an=4'b1011;digit=tim[11:8];end
       3:begin an=4'b0111;digit=tim[15:12];end
    endcase
    always @(*)//显示段数
    case(digit)
       0:num=7'b0000001;
       1:num=7'b1001111;
       2:num=7'b0010010;
       3:num=7'b0000110;
       4:num=7'b1001100;
       5:num=7'b0100100;
       6:num=7'b0100000;
       7:num=7'b0001111;
       8:num=7'b0000000;
       9:num=7'b0000100;
      'hA:num=7'b0001000;
      'hB:num=7'b1100000;
      'hC:num=7'b0110001;
      'hD:num=7'b1000010;
      'hE:num=7'b0110000;
      'hF:num=7'b0111000;
   default:num=7'b0000001;
   endcase
    
endmodule

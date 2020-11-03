module vga_display(
    input             vga_clk,                  //VGA驱动时钟
    input             rst,                //复位信号
    
    input      [ 9:0] pixel_xpos,               //像素点横坐标
    input      [ 9:0] pixel_ypos,               //像素点纵坐标    
    input [15:0] freq,
    input [15:0] period,
    input [15:0] duty_cycle,
    output reg [11:0] pixel_data                //像素点数据,
    );    

localparam s0 = 3'b000;                  //显示频率
localparam s1 = 3'b001;                  //显示数字
localparam s2 = 3'b010;                  //显示占空比
localparam s3 = 3'b011;                  //显示数字
localparam s4 = 3'b100;                  //显示周期
localparam s5 = 3'b101;                  //显示数字
localparam s6 = 3'b110;                  //显示背景

reg [2:0] cur_state;
reg [2:0] next_state;

reg [2:0] count;          //8位一个字符;

//parameter define    
parameter  H_DISP = 10'd640;                    //分辨率——行
parameter  V_DISP = 10'd480;                    //分辨率——列

localparam POS_X  = 10'd10;                    //字符区域起始点横坐标
localparam POS_Y  = 10'd232;                    //字符区域起始点纵坐标
localparam WIDTH  = 10'd240;                     //字符区域宽度
localparam HEIGHT = 10'd16;                     //字符区域高度
localparam RED    = 12'b1111_0000_0000;     //字符颜色
localparam BLUE   = 12'b0000_0000_1111;     //字符区域背景色
localparam BLACK  = 12'b0000_0000_0000;     //屏幕背景色

//reg define
reg  [239:0] char[15:0];                         //字符数组

//wire define   
wire [ 9:0] x_cnt;
wire [ 9:0] y_cnt;

//*****************************************************
//**                    main code
//*****************************************************
assign x_cnt = pixel_xpos - POS_X;              //像素点相对于字符区域起始点水平坐标
assign y_cnt = pixel_ypos - POS_Y;              //像素点相对于字符区域起始点竖直坐标

//大小为高16 宽8
always @(posedge vga_clk) begin
    char[0]  <= 239'h000000000000000000000000000000000000000000000000000000000000;
    char[1]  <= 239'h000000000000000000000000000000000000000000000000000000000000;
    char[2]  <= 239'h000000000000000000000000000000000000000000000000000000000000;
    char[3]  <= 239'h00FCFCFC38F8E7FEEE3EEE3EE0FCFCFCFC7C38F818083C3C047E187E3C38;
    char[4]  <= 239'h0042424244444292444244424042424242104444243842420C4024424244;
    char[5]  <= 239'h0048424882424210444244424048424842108242420842420C4040044242;
    char[6]  <= 239'h184842488242421028802880404842484210824242084202144040044242;
    char[7]  <= 239'h18787C788242421028802880407842787C1082424208020424785C082442;
    char[8]  <= 239'h00484848824242101080108040487C484810824242080418244462081846;
    char[9]  <= 239'h00484848824242101080108040484048481082424208080444024210243A;
    char[10] <= 239'h0040444082424210108010804040404044108242420810027F0242104202;
    char[11] <= 239'h00404442B242421010421042404240424410824242082042044242104202;
    char[12] <= 239'h184042424C44421010441044424240424210444424084242044422104224;
    char[13] <= 239'h18E0E3FC38F83C3838383838FEFCE0FCE37C38F8183E7E3C1F381C103C18;
    char[14] <= 239'h000000000600000000000000000000000000000000000000000000000000;
    char[15] <= 239'h000000000000000000000000000000000000000000000000000000000000;
end

always @(posedge vga_clk or posedge rst) begin 
    if (rst) cur_state <= 3'b000;
    else cur_state <= next_state;
end 

always @(*) begin 
    if (rst) next_state <= 3'b000;
    else begin 
        case (cur_state) 
            3'b000:begin 
                if (y_cnt < 16 && y_cnt >=0 && x_cnt < 40) next_state <= 2'b000;
                else    next_state <= 3'b001;
            end
            3'b001:begin 
                if (y_cnt < 16 && y_cnt >=0 && x_cnt >= 40) next_state <= 2'b001;
                else if (y_cnt < 16 && y_cnt >=0 && x_cnt < 40) next_state <= 2'b000;
                else    next_state <= 3'b010;
            end
            3'b010:begin
                if (y_cnt >= 16 && y_cnt < 32 && x_cnt < 80) next_state <= 3'b010;
                else next_state <= 3'b011; 
            end 
            3'b011:begin
                if (y_cnt >= 16 && y_cnt < 32 && x_cnt >= 80) next_state <= 3'b011;
                else if (y_cnt >= 16 && y_cnt < 32 && x_cnt < 80) next_state <= 3'b010;
                else next_state <= 3'b100;
            end
            3'b100:begin 
                if (y_cnt >= 32 && y_cnt < 48 && x_cnt < 56) next_state <= 3'b100;
                else next_state <= 3'b101;
            end 
            3'b101:begin 
                if (y_cnt >= 32 && y_cnt < 48 && x_cnt >= 56) next_state <= 3'b101;
                else if (y_cnt >= 32 && y_cnt < 48 && x_cnt < 56) next_state <= 3'b100;
                else next_state <= 3'b110;
            end
            3'b110:begin 
                if (y_cnt >= 48 || y_cnt < 0) next_state <= 3'b110;
                else next_state <= 3'b000;
            end
            default:next_state <= 3'b110;
        endcase 
    end 
end

always @(posedge vga_clk or posedge rst) begin 
    if (rst) pixel_data <= BLACK;
    else begin 
        case (next_state)
            3'b000:begin 
                if (x_cnt < 32) begin 
                    if (char[y_cnt][10'd239-(x_cnt + 8)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else begin 
                    if (char[y_cnt][10'd239-(x_cnt - 32)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
            end
            3'b001:begin 
                if ((x_cnt - 40) < 8) begin              //第一个字符
                    if (char[y_cnt][10'd239-({1'b0,freq[15:12],3'b000} + 160 + x_cnt - 40)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 40) >= 8 && (x_cnt - 40) < 16) begin              //第二个字符
                    if (char[y_cnt][10'd239-({1'b0,freq[11:8],3'b000} + 160 + x_cnt - 48)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 40) >= 16 && (x_cnt - 40) < 24) begin              //第三个字符
                    if (char[y_cnt][10'd239-({1'b0,freq[7:4],3'b000} + 160 + x_cnt - 56)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 40) >= 24 && (x_cnt - 40) < 32) begin              //第四个字符
                    if (char[y_cnt][10'd239-({1'b0,freq[3:0],3'b000} + 160 + x_cnt - 64)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else pixel_data <= BLUE;
            end
            3'b010:begin 
                if (x_cnt < 72) begin 
                    if (char[y_cnt - 16][10'd239-(x_cnt + 40)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else begin 
                    if (char[y_cnt][10'd239-(x_cnt - 72)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
            end
            3'b011:begin 
                if ((x_cnt - 80) < 8) begin              //第一个字符
                    if (char[y_cnt - 16][10'd239-({1'b0,duty_cycle[15:12],3'b000} + 160 + x_cnt - 80)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 80) >= 8 && (x_cnt - 80) < 16) begin              //第二个字符
                    if (char[y_cnt - 16][10'd239-({1'b0,duty_cycle[11:8],3'b000} + 160 + x_cnt - 88)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 80) >= 16 && (x_cnt - 80) < 24) begin              //第三个字符
                    if (char[y_cnt - 16][10'd239-({1'b0,duty_cycle[7:4],3'b000} + 160 + x_cnt - 96)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 80) >= 24 && (x_cnt - 80) < 32) begin              //第四个字符
                    if (char[y_cnt - 16][10'd239-({1'b0,duty_cycle[3:0],3'b000} + 160 + x_cnt - 104)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else pixel_data <= BLUE;
            end
            3'b100:begin 
                if (x_cnt < 48) begin 
                    if (char[y_cnt - 32][10'd239-(x_cnt + 112)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else begin 
                    if (char[y_cnt][10'd239-(x_cnt - 48)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
            end
            3'b101:begin 
                if ((x_cnt - 56) < 8) begin              //第一个字符
                    if (char[y_cnt - 32][10'd239-({1'b0,period[15:12],3'b000} + 160 + x_cnt - 56)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 56) >= 8 && (x_cnt - 56) < 16) begin              //第二个字符
                    if (char[y_cnt - 32][10'd239-({1'b0,period[11:8],3'b000} + 160 + x_cnt - 64)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 56) >= 16 && (x_cnt - 56) < 24) begin              //第三个字符
                    if (char[y_cnt - 32][10'd239-({1'b0,period[7:4],3'b000} + 160 + x_cnt - 72)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else if ((x_cnt - 56) >= 24 && (x_cnt - 56) < 32) begin              //第四个字符
                    if (char[y_cnt - 32][10'd239-({1'b0,period[3:0],3'b000} + 160 + x_cnt - 80)])
                        pixel_data <= RED;
                    else 
                        pixel_data <= BLUE;
                end
                else pixel_data <= BLUE;
            end
            3'b110:pixel_data <= BLUE;
            default:pixel_data <= BLUE;
        endcase 
    end
end


endmodule 
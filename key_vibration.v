/*******按键消抖*******/
module key_vibration(
    input		  	 clk,
	input		  	 rst,
	input	    key,
	output reg  key_flag,
	output reg key_value
	);
	
	//reg define    
reg [31:0] delay_cnt;
reg        key_reg;

//*****************************************************
//**                    main code
//*****************************************************
always @(posedge clk or posedge rst) begin 
    if (rst) begin 
        key_reg   <= 1'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg <= key;
        if(key_reg != key)             //一旦检测到按键状态发生变化(有按键被按下或释放)
            delay_cnt <= 32'd2000000;  //给延时计数器重新装载初始值（计数时间为20ms）
        else if(key_reg == key) begin  //在按键状态稳定时，计数器递减，开始20ms倒计时
                 if(delay_cnt > 32'd0)
                     delay_cnt <= delay_cnt - 1'b1;
                 else
                     delay_cnt <= delay_cnt;
             end           
    end   
end

always @(posedge clk or posedge rst) begin 
    if (rst) begin 
        key_flag  <= 1'b0;
        key_value <= 1'b1;          
    end
    else begin
        if(delay_cnt == 32'd1) begin   //当计数器递减到1时，说明按键稳定状态维持了20ms
            key_flag  <= 1'b1;         //此时消抖过程结束，给出一个时钟周期的标志信号
            key_value <= key;          //并寄存此时按键的值
        end
        else begin
            key_flag  <= 1'b0;
            key_value <= key_value; 
        end  
    end   
end
/*
    // 20ms parameter
//    localparam TIME_20MS = 1_000_000;
    localparam TIME_20MS = 2_000_000;       // just for test

    // variable
    reg [28:0] cnt;
    reg key_cnt;
    
    // debounce time passed, refresh key state
    always @(posedge clk or posedge rst) begin
        if(rst == 1)
            key_en <= 0;
        else if(cnt == TIME_20MS - 1)
            key_en <= key;
    end

    // while in debounce state, count, otherwise 0
    always @(posedge clk or posedge rst) begin
        if(rst == 1)
            cnt <= 0;
        else if(key_cnt)
            cnt <= cnt + 1'b1;
        else
            cnt <= 0; 
    end
     
     // 
     always @(posedge clk or posedge rst) begin
            if(rst == 1)
                key_cnt <= 0;
            else if(key_cnt == 0 && key != key_en)
                key_cnt <= 1;
            else if(cnt == TIME_20MS - 1)
                key_cnt <= 0;
     end
	*/
	/*
	
	parameter DURATION = 100_000;                           //延时10ms	
	reg [15:0] cnt; 
	
	wire ken_enable;
	assign ken_enable = key;  //只要任意按键被按下，相应的按键进行消抖
	
	always @(posedge clk or posedge rst)
	begin
		if(rst)
			cnt <= 16'd0;
		else if(ken_enable == 1) begin
			if(cnt == DURATION)
				cnt <= cnt;
			else 
				cnt <= cnt + 1'b1;
			end
		else
			cnt <= 16'b0;
	end
	
	always @(posedge clk or posedge rst) 
	begin
		if(rst) key_en <= 1'd0;
		else if(key) key_en <= (cnt == DURATION-1'b1) ? 1'b1 : 1'b0;
		else key_en <= key_en;
	end*/
	
endmodule

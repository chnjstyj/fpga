/*******��������*******/
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
        if(key_reg != key)             //һ����⵽����״̬�����仯(�а��������»��ͷ�)
            delay_cnt <= 32'd2000000;  //����ʱ����������װ�س�ʼֵ������ʱ��Ϊ20ms��
        else if(key_reg == key) begin  //�ڰ���״̬�ȶ�ʱ���������ݼ�����ʼ20ms����ʱ
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
        if(delay_cnt == 32'd1) begin   //���������ݼ���1ʱ��˵�������ȶ�״̬ά����20ms
            key_flag  <= 1'b1;         //��ʱ�������̽���������һ��ʱ�����ڵı�־�ź�
            key_value <= key;          //���Ĵ��ʱ������ֵ
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
	
	parameter DURATION = 100_000;                           //��ʱ10ms	
	reg [15:0] cnt; 
	
	wire ken_enable;
	assign ken_enable = key;  //ֻҪ���ⰴ�������£���Ӧ�İ�����������
	
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

module bcd(
    input clk,
    input rst,
    input [15:0] bin,
    output wire [15:0] bcd_code
);

reg [3:0] thousands;
reg [3:0] hundreds;
reg [3:0] tens;
reg [3:0] ones;

integer i;
always @(posedge clk) begin 
    thousands = 4'd0;
    hundreds = 4'd0;
    tens = 4'd0;
    ones = 4'd0;
    for (i = 15; i>=0; i = i-1) begin
        if (thousands >= 5)
            thousands = thousands + 3;
        if (hundreds >= 5)
            hundreds = hundreds + 3;
        if (tens >= 5)
            tens = tens + 3;
        if (ones >= 5)
            ones = ones + 3;
        thousands = thousands << 1;
        thousands[0] = hundreds[3];
        hundreds = hundreds << 1;
        hundreds[0] = tens[3];
        tens = tens << 1;
        tens[0] = ones[3];
        ones = ones << 1;
        ones[0] = bin[i];
    end
end

assign bcd_code = {thousands,hundreds,tens,ones};

endmodule

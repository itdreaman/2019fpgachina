module sevo_ctrl #(parameter f = 50)(
    input wire clk_pwm,
    input wire rst,
    input [31:0] angle,
    output reg PWM 
    );
	
    wire [31:0]count_max = 50_000_000/f - 1;//20ms 50hz驱动的一个周期计数值
    reg [31:0]count;
    
    always@(posedge clk_pwm,negedge rst)begin
        if(!rst)begin
            PWM <= 0;
            count <= 0;
        end
        else if(count < count_max)begin
            if(count < angle)//高电平pwm
                PWM <= 1;
            else
                PWM <= 0;
            count <= count + 1;
        end
        else begin
            count <= 0;
            PWM <= 0;
        end
    end

endmodule
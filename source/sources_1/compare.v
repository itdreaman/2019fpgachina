module compare(
             data_a    ,
             data_b    ,
             data_c    ,
             data_max  ,
             data_min  ,
             data_med
             );

input    [7:0]   data_a  ;
input    [7:0]   data_b  ;
input    [7:0]   data_c  ;

output   [7:0]   data_max;
output   [7:0]   data_min;
output   [7:0]   data_med;

wire     [7:0]   data_max;
wire     [7:0]   data_min;
wire     [7:0]   data_med;

wire [7:0] a,b,c;//a,b,c代替三个输入，方便代码书写
assign a=data_a;
assign b=data_b;
assign c=data_c;

assign data_med =  (a<b)?(b<c)?b:(a>c)?a:c : (b>c)?b:(a<c)?a:c;
assign data_min =  (a<b)?(a<c)?a:c  :  (b>c)?c:b    ;
assign data_max =  (a>b)?(a>c)?a:c :  (b>c)?b:c    ;

endmodule
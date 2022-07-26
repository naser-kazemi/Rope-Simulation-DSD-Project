`include "core.v"

module rope #(
    parameter core_contains = 4
) (
    input clk,
    input reset,
    input [9:0] in_mouse_x,
    input [9:0] in_mouse_y,
    output [core_contains * 5 * 10 - 1:0] nodes_x,
    output [core_contains * 5 * 10 - 1:0] nodes_y
);



wire [core_contains * 5 * 32 - 1:0] fixed_point_node_x;
wire [core_contains * 5 * 32 - 1:0] fixed_point_node_y;




genvar k;
generate
    for (k = 0; k < 5 * core_contains; k = k + 1) begin
        assign nodes_x[k * 10 + 9:k * 10] = fixed_point_node_x[k * 32 + 21:k * 32 + 12];
        assign nodes_y[k * 10 + 9:k * 10] = fixed_point_node_y[k * 32 + 21:k * 32 + 12];
    end
endgenerate




wire [5 * 32 - 1:0] core_x_pos [core_contains - 1:0];
wire [5 * 32 - 1:0] core_y_pos [core_contains - 1:0];

genvar j;
generate
    for (j = 0; j < core_contains; j = j + 1) begin
        assign fixed_point_node_x[j * 5 * 32 + 159:j * 5 * 32] = core_x_pos[j];
        assign fixed_point_node_y[j * 5 * 32 + 159:j * 5 * 32] = core_y_pos[j];
    end
endgenerate

wire [31:0] prev_core_x_pos [core_contains - 1:0];
wire [31:0] prev_core_y_pos [core_contains - 1:0];
wire [31:0] next_core_x_pos [core_contains - 1:0];
wire [31:0] next_core_y_pos [core_contains - 1:0];


wire [31:0] mouse_x, mouse_y;
assign mouse_x =  {{10{1'b0}}, in_mouse_x, {12{1'b0}}};
assign mouse_y =  {{10{1'b0}}, in_mouse_y, {12{1'b0}}};

wire [core_contains -1:0] is_last_core;



genvar i;
generate
    for (i = 0; i < core_contains; i = i + 1) begin
        assign is_last_core[i] = (i == core_contains - 1);
        if(i != 0) begin
        assign prev_core_x_pos[i] = core_x_pos[i - 1][5 * 32 -1: 32 * 4];
        assign prev_core_y_pos[i] = core_y_pos[i - 1][5 * 32 -1: 32 * 4];
        end

        if (i != core_contains - 1)begin
            assign next_core_x_pos[i] = core_x_pos[i + 1][31:0];
            assign next_core_y_pos[i] = core_y_pos[i + 1][31:0]; 
        end

        core #(5, i + 1) c(
            clk, 
            reset,
            prev_core_x_pos[i], 
            prev_core_y_pos[i],
            next_core_x_pos[i], 
            next_core_y_pos[i],
            mouse_x,
            mouse_y,
            is_last_core[i],
            core_x_pos[i],
            core_y_pos[i]
        );
    end
endgenerate




endmodule
`include "node.v"
`include "circular_shift.v"


module core #(
    parameter node_contains = 5,
    parameter core_id = 1
) (
  input wire clk, 
  input wire reset,
  input wire [31:0] prev_core_last_x,
  input wire [31:0] prev_core_last_y,
  input wire [31:0] next_core_first_x,
  input wire [31:0] next_core_first_y,
  input wire [31:0] x_mouse,
  input wire [31:0] y_mouse,
  input wire is_last,
  output wire[node_contains * 32 -1:0] nodes_x,
  output wire[node_contains * 32 -1:0] nodes_y
);

wire [node_contains :0] control_signal;
reg [node_contains:0] control_signal_reg;
wire [node_contains:0] next_control_signal;

assign control_signal = control_signal_reg; 
circular_shift #(node_contains + 1) cs(control_signal, next_control_signal);

wire [31:0] x_pos[node_contains - 1:0]; 
wire [31:0] y_pos[node_contains - 1:0];
wire [31:0] new_x_pos[node_contains - 1:0];
wire [31:0] new_y_pos[node_contains - 1:0];
wire [node_contains -1:0] is_last_node_of_last_core;




genvar i;
generate
    for(i = 0; i < node_contains; i = i + 1) begin
        assign is_last_node_of_last_core[i] = is_last && (node_contains - 1 == i); 
        assign nodes_x[(i + 1) * 32 - 1: i * 32] = x_pos[i];
        assign nodes_y[(i + 1) * 32 - 1: i * 32] = y_pos[i];
        
        node #(
            (i + 1) + (core_id -1) * 5
        ) node(
            clk,
            reset,
            control_signal[i],
            control_signal[node_contains],
            new_x_pos[i],
            new_y_pos[i],
            x_mouse, 
            y_mouse,
            x_pos[i],
            y_pos[i]
            );

        if (core_id == 1) begin
            if (i == 0) begin
                assign new_x_pos[0] = x_pos[0];
                assign new_y_pos[0] = y_pos[0];
            end
            else if (i < node_contains - 1) begin
                enforce_constraint #(
                    (i + 1) + (core_id -1) * 5
                ) e(
                    x_pos[i - 1],
                    y_pos[i - 1],
                    x_pos[i],
                    y_pos[i],
                    x_pos[i + 1],
                    y_pos[i + 1],
                    is_last_node_of_last_core[i],
                    new_x_pos[i],
                    new_y_pos[i]
                );
            end
        end

        else begin
            if (i == 0) begin
                enforce_constraint #(
                        (i + 1) + (core_id -1) * 5
                    ) e(
                        prev_core_last_x,
                        prev_core_last_y,
                        x_pos[i],
                        y_pos[i],
                        x_pos[i + 1],
                        y_pos[i + 1],
                        is_last_node_of_last_core[i],
                        new_x_pos[i],
                        new_y_pos[i]
                );
            end
            else if (i < node_contains - 1) begin
                enforce_constraint #(
                    (i + 1) + (core_id -1) * 5
                ) e(
                    x_pos[i - 1],
                    y_pos[i - 1],
                    x_pos[i],
                    y_pos[i],
                    x_pos[i + 1],
                    y_pos[i + 1],
                    is_last_node_of_last_core[i],
                    new_x_pos[i],
                    new_y_pos[i]
                );
            end
        end
        

        if (i == node_contains - 1) begin
            enforce_constraint #(
                (i + 1) + (core_id -1) * 5
            ) e(
                x_pos[i - 1],
                y_pos[i - 1],
                x_pos[i],
                y_pos[i],
                next_core_first_x,
                next_core_first_y,
                is_last_node_of_last_core[i],
                new_x_pos[i],
                new_y_pos[i]
                );
        end
    end
endgenerate


// integer j;
always @(posedge clk) begin
    if(!reset) begin
    control_signal_reg <= next_control_signal;

    end else begin
        control_signal_reg <= 1;
    end



end






endmodule
module Q_calculator #(
    parameter WIDTH = 16  
)(
    input  wire clk,
    input  wire rst,
    input  wire valid_in,
    input  wire signed [WIDTH-1:0] a,
    input  wire signed [WIDTH-1:0] b,
    input  wire signed [WIDTH-1:0] c,
    input  wire signed [WIDTH-1:0] d,
    output reg  signed [WIDTH-1:0] Q,
    output reg  valid_out
);

    localparam EXT = 2 * WIDTH;

    reg signed [WIDTH-1:0] ab_diff_stage1;
    reg signed [WIDTH-1:0] three_c_stage1;
    reg signed [WIDTH-1:0] d_stage1;
    reg                  valid_stage1;

    reg signed [EXT-1:0] mul_result_stage2;
    reg signed [EXT-1:0] four_d_stage2;
    reg                  valid_stage2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ab_diff_stage1   <= 0;
            three_c_stage1   <= 0;
            d_stage1         <= 0;
            valid_stage1     <= 0;
        end else begin
            if (valid_in) begin
                ab_diff_stage1 <= a - b;
                three_c_stage1 <= 3 * c;
                d_stage1       <= d;
                valid_stage1   <= 1;
            end else begin
                valid_stage1 <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mul_result_stage2 <= 0;
            four_d_stage2     <= 0;
            valid_stage2      <= 0;
        end else begin
            if (valid_stage1) begin
                mul_result_stage2 <= $signed({{(EXT - WIDTH){ab_diff_stage1[WIDTH-1]}}, ab_diff_stage1}) *
                                     $signed({{(EXT - WIDTH){three_c_stage1[WIDTH-1]}}, three_c_stage1}) +
                                     $signed({{(EXT - WIDTH){ab_diff_stage1[WIDTH-1]}}, ab_diff_stage1});  // +1
                four_d_stage2     <= $signed({{(EXT - WIDTH){d_stage1[WIDTH-1]}}, d_stage1}) <<< 2; // 4*d
                valid_stage2      <= 1;
            end else begin
                valid_stage2 <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Q         <= 0;
            valid_out <= 0;
        end else begin
            if (valid_stage2) begin
                Q         <= ($signed(mul_result_stage2 - four_d_stage2)) >>> 1;
                valid_out <= 1;
            end else begin
                valid_out <= 0;
            end
        end
    end

endmodule
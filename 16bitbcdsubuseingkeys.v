module bcd_subtractor_fsm (
    input CLOCK_50,
    input [15:0] SW,
    input [3:0] KEY,
    output [6:0] HEX0, HEX1, HEX2, HEX3,
    output [6:0] HEX4, HEX5, HEX6, HEX7,
    output reg [17:0] LEDR
);

    // =============================
    // FSM STATES
    // =============================
    reg [1:0] state;

    parameter IDLE   = 2'b00;
    parameter SHOW_A = 2'b01;
    parameter SHOW_B = 2'b10;
    parameter SHOW_R = 2'b11;

    // =============================
    // REGISTERS
    // =============================
    reg [3:0] A_ones, A_tens;
    reg [3:0] B_ones, B_tens;

    // =============================
    // LOAD & STATE CONTROL
    // =============================
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if(!KEY[0]) begin
            A_ones <= 0; A_tens <= 0;
            B_ones <= 0; B_tens <= 0;
            state <= IDLE;
        end
        else begin
            if(!KEY[1]) begin
                A_ones <= (SW[3:0] > 9) ? 0 : SW[3:0];
                A_tens <= (SW[7:4] > 9) ? 0 : SW[7:4];
                state <= SHOW_A;
            end
            else if(!KEY[2]) begin
                B_ones <= (SW[11:8]  > 9) ? 0 : SW[11:8];
                B_tens <= (SW[15:12] > 9) ? 0 : SW[15:12];
                state <= SHOW_B;
            end
            else if(!KEY[3]) begin
                state <= SHOW_R;
            end
        end
    end

    // =============================
    // BCD → Binary
    // =============================
    wire [7:0] A = (A_tens * 8'd10) + A_ones;
    wire [7:0] B = (B_tens * 8'd10) + B_ones;

    // =============================
    // SUBTRACTION
    // =============================
    wire signed [8:0] diff_signed = A - B;

    wire negative = diff_signed[8];

    wire [7:0] diff =
        negative ? (B - A) : (A - B);

    // =============================
    // RESULT → BCD
    // =============================
    wire [3:0] tens = (diff / 10) % 10;
    wire [3:0] ones = diff % 10;

    // =============================
    // LED CONTROL
    // =============================
    always @(*) begin
        case(state)
            SHOW_A: LEDR = A;
            SHOW_B: LEDR = B;
            SHOW_R: LEDR = diff;
            default: LEDR = 0;
        endcase
    end

    // =============================
    // DISPLAY CONTROL
    // =============================
    reg [3:0] d3, d2;
    reg minus;

    always @(*) begin
        if(state == SHOW_R) begin
            d3 = tens;
            d2 = ones;
            minus = negative;
        end
        else begin
            d3 = 0;
            d2 = 0;
            minus = 0;
        end
    end

    // =============================
    // 7-SEG CONNECTIONS
    // =============================

    // A → HEX7-6
    sevenseg sA0 (A_ones, HEX6);
    sevenseg sA1 (A_tens, HEX7);

    // B → HEX5-4
    sevenseg sB0 (B_ones, HEX4);
    sevenseg sB1 (B_tens, HEX5);

    // Result magnitude → HEX3-2
    sevenseg sR0 (d2, HEX0);
    sevenseg sR1 (d3, HEX1);

    // Minus sign on HEX1
    assign HEX2 = (minus && state == SHOW_R) ? 7'b0111111 : 7'b1111111;

    // HEX0 unused
    assign HEX3 = 7'b1111111;

endmodule

module sevenseg(
    input [3:0] digit,
    output reg [6:0] seg
);

always @(*) begin
    case(digit)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

endmodule
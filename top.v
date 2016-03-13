module top(rst, fifo_wr_data, fifo_wr_en, fifo_rd_data, fifo_rd_en);
    input rst;
    input fifo_rd_data;
    output fifo_rd_en;
    output fifo_wr_data;
    output fifo_wr_en;

    wire fifo_wr_data = fifo_wr_data_q;
    wire fifo_wr_en = fifo_wr_en_q;
    wire fifo_rd_en = fifo_rd_en_q;

    reg [2:0] state_q, state_d;
    reg [7:0] fifo_wr_data_q, fifo_wr_data_d;
    reg fifo_wr_en_q, fifo_wr_en_d;
    reg fifo_rd_en_q, fifo_rd_en_d;
    reg [7:0] counter_q, counter_d;

    localparam
        IDLE = 3'h1,
        WRITE = 3'h2,
        WAIT = 3'h3,
        READ = 3'h4;

    always @ (*) begin
        state_d = state_q;
        fifo_wr_data_d = fifo_wr_data_q;
        fifo_wr_en_d = fifo_wr_en_q;
        fifo_rd_en_d = fifo_rd_en_q;
        counter_d = counter_q;

        case (state_q)
            IDLE: begin
                counter_d = counter_q + 1'b1;
                if (counter_q == 8'hFF) begin
                    state_d = WRITE;
                    counter_d = 8'h00;
                    fifo_wr_data_d = 8'hAA;
                end
            end
            WRITE: begin
                fifo_wr_en_d = 1'b1;
                state_d = WAIT;
            end
            WAIT: begin
                fifo_wr_en_d = 1'b0;
                fifo_wr_data_d = 8'h00;
                counter_d = counter_q + 1'b1;
                if (counter_q == 8'hFF) begin
                    state_d = READ;
                    fifo_rd_en_d = 1'b1;
                    counter_d = 8'h00;
                end
            end
            READ: begin
                fifo_rd_en_d = 1'b0;
                state_d = IDLE;
            end
        endcase
    end

    always @ (posedge clk) begin
        if (rst) begin
            state_q <= IDLE;
            counter_q <= 8'h00;
            fifo_wr_en_q <= 1'b0;
            fifo_rd_en_q <= 1'b0;
            fifo_wr_data_q <= 8'h00;
        end else begin
            state_q <= state_d;
            counter_q <= counter_d;
            fifo_wr_en_q <= fifo_wr_en_d;
            fifo_wr_data_q <= fifo_wr_data_d;
            fifo_rd_en_q <= fifo_rd_en_d;
        end
    end
endmodule

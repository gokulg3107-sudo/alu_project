
module alu_design #(parameter size = 4, size_cmd = 4)(clk, rst, ce, inp_valid, mode, cmd, opa, opb, cin, err, res, oflow, cout, g, l, e);
input clk, rst, ce, cin, mode;

input [1:0] inp_valid;
input [size_cmd - 1: 0] cmd;
input [size - 1: 0] opa, opb;
output reg [2 * size - 1: 0] res;
output reg oflow, err, g, l, e;
output cout;

wire clk_gated;
assign clk_gated = clk & ce;

reg [1:0] count;
reg [2 * size - 1: 0] temp;
reg [size - 1: 0] temp_opa, temp_opb;
reg temp_err;
reg [2 * size - 1: 0] res_s1;
reg                    err_s1, oflow_s1, g_s1, l_s1, e_s1;

assign cout = (err) ? 1'b0 :
              (mode) ? ((cmd == 0 || cmd == 2) ? res[size] : 1'b0)
                     : 1'b0;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        res          <= {2*size{1'b0}};
        {err,g,l,e}  <= 4'd0;
        oflow        <= 1'b0;
    end else begin
        // Multiply (cmd 9/10) writes directly to final outputs at count==2
        // All other operations: just pipeline stage-1 → final output
        if ((cmd == 9 || cmd == 10) && mode) begin
            // handled inside the stage-1 block below via temp mechanism
            // stage-2 just passes through what stage-1 computed for multiply
            res         <= res_s1;
            err         <= err_s1;
            oflow       <= 1'b0;
            {g, l, e}   <= {g_s1, l_s1, e_s1};
        end else begin
            res         <= res_s1;
            err         <= err_s1;
            oflow       <= oflow_s1;
            {g, l, e}   <= {g_s1, l_s1, e_s1};
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 2'd0;
    end else begin
        if (cmd == 9 || cmd == 10) begin
            if (count == 2'd2) count <= 0;
            else               count <= count + 1;
        end else count <= 0;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        res_s1          <= {2*size{1'b0}};
        {err_s1, g_s1, l_s1, e_s1} <= 4'd0;
        oflow_s1        <= 1'b0;
        temp            <= 0;
        temp_opa        <= 0;
        temp_opb        <= 0;
        temp_err        <= 0;
    end
    else if (mode) begin
         if (cmd != 9 && cmd != 10) begin
            err_s1   <= 1'b0;
            oflow_s1 <= 1'b0;
            {g_s1, l_s1, e_s1} <= 3'd0;
        end

        case (cmd)
            0: begin
                if (inp_valid == 2'b11) res_s1 <= opa + opb;
                else                    err_s1 <= 1'b1;
            end
            1: begin
                if (inp_valid == 2'b11) begin
                    res_s1   <= opa - opb;
                    oflow_s1 <= (opa < opb);
                end else err_s1 <= 1'b1;
            end
            2: begin
                if (inp_valid == 2'b11) res_s1 <= opa + opb + cin;
                else                    err_s1 <= 1'b1;
            end
            3: begin
                if (inp_valid == 2'b11) begin
                    res_s1   <= opa - opb - cin;
                    oflow_s1 <= ((opa < opb) | (opa == opb & cin == 1));
                end else err_s1 <= 1'b1;
            end
            4: begin
                if (inp_valid[0] == 1'b1) res_s1 <= opa + 1'b1;
                else                      err_s1 <= 1'b1;
            end
            5: begin
                if (inp_valid[0] == 1'b1) res_s1 <= opa - 1'b1;
                else                      err_s1 <= 1'b1;
            end
            6: begin
                if (inp_valid[1] == 1'b1) res_s1 <= opb + 1'b1;
                else                      err_s1 <= 1'b1;
            end
            7: begin
                if (inp_valid[1] == 1'b1) res_s1 <= opb - 1'b1;
                else                      err_s1 <= 1'b1;
            end
            8: begin
                res_s1 <= 0;
                if (inp_valid == 2'b11) begin
                    if      (opa == opb) {g_s1, l_s1, e_s1} <= 3'b001;
                    else if (opa >  opb) {g_s1, l_s1, e_s1} <= 3'b100;
                    else                 {g_s1, l_s1, e_s1} <= 3'b010;
                end else err_s1 <= 1'b1;
            end

            9: begin
                if (count == 0) begin
                    if (inp_valid == 2'b11) begin
                        temp_opa <= opa;
                        temp_opb <= opb;
                        temp_err <= 1'b0;
                    end else temp_err <= 1'b1;
                end
                else if (count == 1) begin
                    temp <= (temp_opa + 1) * (temp_opb + 1);
                end
                else if (count == 2) begin
                    res_s1  <= temp;
                    err_s1  <= temp_err;
                    // pipeline next input immediately
                    if (inp_valid == 2'b11) begin
                        temp_opa <= opa;
                        temp_opb <= opb;
                        temp_err <= 1'b0;
                    end else temp_err <= 1'b1;
                end
            end

            10: begin
                if (count == 0) begin
                    if (inp_valid == 2'b11) begin
                        temp_opa <= opa;
                        temp_opb <= opb;
                        temp_err <= 1'b0;
                    end else temp_err <= 1'b1;
                end
                else if (count == 1) begin
                    temp <= (temp_opa << 1) * temp_opb;
                end
                else if (count == 2) begin
                    res_s1 <= temp;
                    err_s1 <= temp_err;
                    if (inp_valid == 2'b11) begin
                        temp_opa <= opa;
                        temp_opb <= opb;
                        temp_err <= 1'b0;
                    end else temp_err <= 1'b1;
                end
            end

            11: begin
                if (inp_valid == 2'b11) begin
                    res_s1 <= $signed(opa) + $signed(opb);
                    if      ($signed(opa) == $signed(opb)) {g_s1,l_s1,e_s1} <= 3'b001;
                    else if ($signed(opa) >  $signed(opb)) {g_s1,l_s1,e_s1} <= 3'b100;
                    else                                    {g_s1,l_s1,e_s1} <= 3'b010;
                end else err_s1 <= 1'b1;
            end
            12: begin
                if (inp_valid == 2'b11) begin
                    res_s1 <= $signed(opa) - $signed(opb);
                    if      ($signed(opa) == $signed(opb)) {g_s1,l_s1,e_s1} <= 3'b001;
                    else if ($signed(opa) >  $signed(opb)) {g_s1,l_s1,e_s1} <= 3'b100;
                    else                                    {g_s1,l_s1,e_s1} <= 3'b010;
                end else err_s1 <= 1'b1;
            end
        endcase
    end

    else begin  // logic mode
        err_s1   <= 1'b0;
        oflow_s1 <= 1'b0;
        {g_s1, l_s1, e_s1} <= 3'd0;

        case (cmd)
            0:  begin if (inp_valid == 2'b11) res_s1 <= {{size{1'b0}}, opa & opb};    else err_s1 <= 1'b1; end
            1:  begin if (inp_valid == 2'b11) res_s1 <= {{size{1'b0}}, ~(opa & opb)}; else err_s1 <= 1'b1; end
            2:  begin if (inp_valid == 2'b11) res_s1 <= {{size{1'b0}}, opa | opb};    else err_s1 <= 1'b1; end
            3:  begin if (inp_valid == 2'b11) res_s1 <= {{size{1'b0}}, ~(opa | opb)}; else err_s1 <= 1'b1; end
            4:  begin if (inp_valid == 2'b11) res_s1 <= {{size{1'b0}}, opa ^ opb};    else err_s1 <= 1'b1; end
            5:  begin if (inp_valid == 2'b11) res_s1 <= {{size{1'b0}}, opa ~^ opb};   else err_s1 <= 1'b1; end
            6:  begin if (inp_valid[0] == 1'b1) res_s1 <= {{size{1'b0}}, ~opa};       else err_s1 <= 1'b1; end
            7:  begin if (inp_valid[1] == 1'b1) res_s1 <= {{size{1'b0}}, ~opb};       else err_s1 <= 1'b1; end
            8:  begin if (inp_valid[0] == 1'b1) res_s1 <= {{size{1'b0}}, opa >> 1};   else err_s1 <= 1'b1; end
            9:  begin if (inp_valid[1] == 1'b1) res_s1 <= {{size{1'b0}}, opa << 1};   else err_s1 <= 1'b1; end
            10: begin if (inp_valid[0] == 1'b1) res_s1 <= {{size{1'b0}}, opb >> 1};   else err_s1 <= 1'b1; end
            11: begin if (inp_valid[1] == 1'b1) res_s1 <= {{size{1'b0}}, opb << 1};   else err_s1 <= 1'b1; end
            12: begin
                if (inp_valid == 2'b11) begin
                    if (|opb[size-1:3]) err_s1 <= 1'b1;
                    else res_s1 <= {{size{1'b0}}, opa << (opb[size/2 - 1 : 0])};
                end else err_s1 <= 1'b1;
            end
            13: begin
                if (inp_valid == 2'b11) begin
                    if (|opb[size-1:3]) err_s1 <= 1'b1;
                    else res_s1 <= {{size{1'b0}}, opa >> (opb[size/2 - 1 : 0])};
                     end else err_s1 <= 1'b1;
            end
        endcase
    end
end

endmodule

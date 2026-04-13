`timescale 1ns / 1ps
module sc_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic [1:0] ALUOp
);
    localpram R_TYPE = 7'b0110011;
    localpram LOAD   = 7'b0000011;
    localpram STORE  = 7'b0100011;
    localpram BRANCH = 7'b1100011;

    always_comb begin
        // Safe defaults
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            R_TYPE: begin
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
                // ALUSrc=0 (reg), MemtoReg=0 (ALU), MemRead=0, MemWrite=0, Branch=0
            end

            LOAD: begin
                ALUSrc   = 1'b1;  // offset imediato
                MemtoReg = 1'b1;  // resultado vem da memória
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00; // ADD pra cálculo de endereço
            end

            STORE: begin
                ALUSrc   = 1'b1;  // offset imediato
                MemWrite = 1'b1;
                ALUOp    = 2'b00; // ADD pra cálculo de endereço
                // RegWrite=0, MemRead=0, Branch=0
            end

            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01; // SUB pra comparação (beq)
                // ALUSrc=0 (reg), RegWrite=0, MemRead=0, MemWrite=0
            end

            default: ; // sinais ficam nos defaults seguros
        endcase
    end
endmodule

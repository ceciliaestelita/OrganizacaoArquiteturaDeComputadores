// =============================================================================
// sc_control.sv
// Main Control Unit - single-cycle RISC-V (Section 4.4 - Patterson & Hennessy)
//
// Decodes the 7-bit opcode and asserts control signals for the datapath.
//
// Supported instructions:
//   R-type  (0110011): add, sub, and, or, slt
//   I-type  (0000011): lw
//   S-type  (0100011): sw
//   B-type  (1100011): beq
//
// Control signal summary:
//
//   Signal    | R-type | lw | sw | beq
//   ----------|--------|----|----|-----
//   ALUSrc    |   0    |  1 |  1 |  0    0=reg, 1=imm
//   MemtoReg  |   0    |  1 |  - |  -    0=ALU, 1=mem
//   RegWrite  |   1    |  1 |  0 |  0
//   MemRead   |   0    |  1 |  0 |  0
//   MemWrite  |   0    |  0 |  1 |  0
//   Branch    |   0    |  0 |  0 |  1
//   ALUOp[1]  |   1    |  0 |  0 |  0
//   ALUOp[0]  |   0    |  0 |  0 |  1
//
//   ALUOp encoding:
//     2'b00 = Load/Store (force ADD)
//     2'b01 = Branch     (force SUB)
//     2'b10 = R-type     (ALU Control decodes Funct3/Funct7)
//
// =============================================================================
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
    localparam R_TYPE = 7'b0110011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;

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
                ALUOp    = 2'b00; // ADD para cálculo de endereço
            end

            STORE: begin
                ALUSrc   = 1'b1;  // offset imediato
                MemWrite = 1'b1;
                ALUOp    = 2'b00; // ADD para cálculo de endereço
                // RegWrite=0, MemRead=0, Branch=0
            end

            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01; // SUB para comparação (beq)
                // ALUSrc=0 (reg), RegWrite=0, MemRead=0, MemWrite=0
            end

            default: ; // sinais ficam nos defaults seguros
        endcase
    end
endmodule

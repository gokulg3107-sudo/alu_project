Parameterised ALU – Design & Verification

This repository contains the RTL design and verification environment for a configurable 4-bit Arithmetic Logic Unit (ALU) written in Verilog.
The project includes a self-checking testbench, directed verification scenarios, and supporting documentation for functionality and coverage analysis.

# Project Overview

The ALU is designed as a parameterised module supporting both arithmetic and logical operations.
It supports configurable operand width and command width, while also handling comparison operations, carry/overflow signalling, and multi-cycle multiplication.

The verification environment is fully self-checking and validates all supported operations, invalid input conditions, boundary scenarios, and sequential behaviours.

---

# Configurable Parameters

| Parameter  | Default Value | Purpose                   |
| ---------- | ------------- | ------------------------- |
| `size`     | 4             | Width of input operands   |
| `size_cmd` | 4             | Width of command selector |

---

# Interface Description

| Signal      | Direction | Width      | Description                                    |
| ----------- | --------- | ---------- | ---------------------------------------------- |
| `clk`       | Input     | 1          | Rising-edge clock                              |
| `rst`       | Input     | 1          | Active-high synchronous reset                  |
| `ce`        | Input     | 1          | Chip enable                                    |
| `mode`      | Input     | 1          | Selects arithmetic or logic mode               |
| `cin`       | Input     | 1          | Carry input for selected arithmetic operations |
| `inp_valid` | Input     | 2          | Operand validity indicators                    |
| `cmd`       | Input     | `size_cmd` | Operation select                               |
| `opa`       | Input     | `size`     | Operand A                                      |
| `opb`       | Input     | `size`     | Operand B                                      |
| `res`       | Output    | `2*size`   | Result output                                  |
| `err`       | Output    | 1          | Error indicator                                |
| `oflow`     | Output    | 1          | Underflow flag for subtraction                 |
| `cout`      | Output    | 1          | Carry-out flag                                 |
| `g`         | Output    | 1          | Greater-than flag                              |
| `l`         | Output    | 1          | Less-than flag                                 |
| `e`         | Output    | 1          | Equality flag                                  |

---

# Supported Operations

## Arithmetic Mode (`mode = 1`)

| CMD | Function                           |
| --- | ---------------------------------- |
| 0   | Addition                           |
| 1   | Subtraction                        |
| 2   | Addition with carry                |
| 3   | Subtraction with carry             |
| 4   | Increment Operand A                |
| 5   | Decrement Operand A                |
| 6   | Increment Operand B                |
| 7   | Decrement Operand B                |
| 8   | Compare operands                   |
| 9   | Multiply `(A+1) × (B+1)`           |
| 10  | Multiply `(A<<1) × B`              |
| 11  | Signed addition with comparison    |
| 12  | Signed subtraction with comparison |

### Arithmetic Features

* Carry-out generation for addition operations
* Underflow detection during subtraction
* Signed arithmetic support using two’s complement representation
* Comparison flag generation (`g`, `l`, `e`)
* Multi-cycle multiplication support

---

## Logic Mode (`mode = 0`)

| CMD | Function             |
| --- | -------------------- |
| 0   | AND                  |
| 1   | NAND                 |
| 2   | OR                   |
| 3   | NOR                  |
| 4   | XOR                  |
| 5   | XNOR                 |
| 6   | NOT A                |
| 7   | NOT B                |
| 8   | Right shift A        |
| 9   | Left shift A         |
| 10  | Right shift B        |
| 11  | Left shift B         |
| 12  | Variable left shift  |
| 13  | Variable right shift |

### Logic Features

* Bitwise logical operations
* Fixed and variable shift operations
* Input validity checking
* Shift range validation

---

# Error Handling

The `err` signal is asserted under the following conditions:

* Invalid operand validity combinations for the selected command
* Unsupported shift values during variable shift operations
* Missing required operands for unary or binary operations

When an error occurs, the output result is considered invalid.

---

# Multi-Cycle Multiply Operations

Arithmetic commands 9 and 10 are implemented as 3-cycle operations.

| Clock Cycle | Internal State     | Output                      |
| ----------- | ------------------ | --------------------------- |
| Cycle 1     | Operation accepted | No valid result             |
| Cycle 2     | Processing         | No valid result             |
| Cycle 3     | Result available   | Final multiplication output |

For correct operation, input values must remain stable throughout the complete sequence.

---

# Verification Environment

The verification setup uses a directed self-checking testbench with an inline scoreboard for automatic result checking.

### Verification Coverage Includes

* Arithmetic functionality
* Logical functionality
* Signed operations
* Carry and underflow behaviour
* Comparison flag validation
* Error condition handling
* Reset behaviour
* Mode transitions
* Multi-cycle operation sequencing

### Verification Statistics

| Metric             | Value                            |
| ------------------ | -------------------------------- |
| Total Testcases    | 400                              |
| Verification Style | Directed self-checking           |
| Coverage Goal      | Functional + boundary validation |

Additional details are available in:

* `docs/test_plan.md`
* `docs/verification_report.md`

---

# Running Simulation

## Supported Simulators

The design is compatible with standard Verilog-2001 simulators such as:

* Icarus Verilog
* ModelSim
* Synopsys VCS
* Cadence Xcelium

---

## Example – Icarus Verilog

Compile:

```bash
iverilog -o alu_sim src/design/alu.v src/test_bench/alu_tb.v
```

Run:

```bash
vvp alu_sim
```

---

# Example Simulation Output

```text
t=120 | PASS TC25 | mode=1 cmd=0 opa=4 opb=3 res=7
t=140 | PASS TC26 | mode=0 cmd=4 opa=5 opb=2 res=7
t=180 | FAIL TC31 | expected=8 got=9

══════════════════════════════════════════════
TOTAL : 400
PASS  : 398
FAIL  : 2
```

---

# Design Highlights

* Parameterised architecture for scalability
* Separate arithmetic and logical operating modes
* Extended result width to support multiplication outputs
* Signed and unsigned operation support
* Built-in error detection
* Self-checking verification environment
* Multi-cycle pipeline handling for multiplication commands

---

# Notes

* Result width is twice the operand width to safely store multiplication outputs.
* Signed arithmetic uses standard two’s complement interpretation.
* Reset clears all registered outputs synchronously.
* Carry and overflow signals are generated automatically based on operation type.

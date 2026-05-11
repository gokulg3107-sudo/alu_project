# ALU Verification Test Plan

# Objective

The objective of this verification plan is to validate the functionality, reliability, and error handling capability of the parameterised 4-bit ALU design.

The verification environment is based on a directed self-checking testbench with inline expected-value comparison.

---

# Design Under Test (DUT)

| Item | Description |
|---|---|
| Module | ALU |
| Language | Verilog HDL |
| Operand Width | 4-bit |
| Command Width | 4-bit |
| Verification Style | Directed + Self-checking |

---

# Verification Goals

The following functionality is verified:

- Arithmetic operations
- Logical operations
- Signed arithmetic
- Comparison flags
- Carry and underflow conditions
- Error handling
- Reset behaviour
- Mode switching
- Multi-cycle multiplication
- Boundary conditions
- Invalid input combinations

---

# Test Categories

## 1. Reset Verification

| Test ID | Description |
|---|---|
| RST_01 | Apply synchronous reset and verify outputs clear to zero |
| RST_02 | Verify outputs remain reset while reset is asserted |
| RST_03 | Verify normal operation resumes after reset deassertion |

---

## 2. Arithmetic Operation Verification

### Basic Arithmetic

| Test ID | Operation |
|---|---|
| ARTH_01 | Addition |
| ARTH_02 | Subtraction |
| ARTH_03 | Addition with carry |
| ARTH_04 | Subtraction with carry |

### Increment / Decrement

| Test ID | Operation |
|---|---|
| ARTH_05 | Increment Operand A |
| ARTH_06 | Decrement Operand A |
| ARTH_07 | Increment Operand B |
| ARTH_08 | Decrement Operand B |

### Comparison Operations

| Test ID | Operation |
|---|---|
| ARTH_09 | Compare equal values |
| ARTH_10 | Compare greater-than |
| ARTH_11 | Compare less-than |

### Signed Operations

| Test ID | Operation |
|---|---|
| ARTH_12 | Signed addition |
| ARTH_13 | Signed subtraction |
| ARTH_14 | Signed comparison |

---

## 3. Logic Operation Verification

| Test ID | Operation |
|---|---|
| LOGIC_01 | AND |
| LOGIC_02 | NAND |
| LOGIC_03 | OR |
| LOGIC_04 | NOR |
| LOGIC_05 | XOR |
| LOGIC_06 | XNOR |
| LOGIC_07 | NOT A |
| LOGIC_08 | NOT B |

---

## 4. Shift Operation Verification

| Test ID | Operation |
|---|---|
| SHIFT_01 | Shift right A |
| SHIFT_02 | Shift left A |
| SHIFT_03 | Shift right B |
| SHIFT_04 | Shift left B |
| SHIFT_05 | Variable shift left |
| SHIFT_06 | Variable shift right |

---

## 5. Multiply Operation Verification

| Test ID | Operation |
|---|---|
| MULT_01 | Multiply `(A+1)*(B+1)` |
| MULT_02 | Multiply `(A<<1)*B` |
| MULT_03 | Verify 3-cycle latency |
| MULT_04 | Verify stable inputs during multiply |

---

## 6. Error Condition Verification

| Test ID | Description |
|---|---|
| ERR_01 | Invalid operand validity |
| ERR_02 | Missing Operand A |
| ERR_03 | Missing Operand B |
| ERR_04 | Invalid variable shift amount |
| ERR_05 | Invalid compare operation inputs |

---

# Boundary Testing

The following corner cases are verified:

| Case | Example |
|---|---|
| Minimum value | 0 |
| Maximum value | 15 |
| Addition overflow | 15 + 15 |
| Subtraction underflow | 0 - 15 |
| Signed negative values | 4'b1000 to 4'b1111 |
| Zero shift amount | Shift by 0 |
| Maximum shift amount | Shift by 7 |

---

# Functional Coverage Goals

| Feature | Coverage Goal |
|---|---|
| Arithmetic commands | 100% |
| Logic commands | 100% |
| Error conditions | 100% |
| Comparison flags | 100% |
| Signed operations | 100% |
| Reset behaviour | 100% |

---

# Pass Criteria

Verification is considered successful when:

- All directed testcases pass
- No mismatches occur in scoreboard comparison
- Error flags assert correctly
- All functional goals are covered
- Reset behaviour is verified
- Multi-cycle operations complete correctly

---

# Total Testcases

| Metric | Value |
|---|---|
| Total Testcases | 400 |
| Verification Style | Self-checking |
| Automation | Inline Scoreboard |

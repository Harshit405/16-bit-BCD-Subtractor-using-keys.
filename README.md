#  🚀 16 bit BCD Subtractor using keys

A small Verilog project implementing a finite-state machine (FSM) BCD subtractor.

---

## 📝 Project Description

A **Verilog FSM-based BCD subtractor** for the **DE2-115 FPGA**. Accepts two 2-digit BCD numbers via slide switches, computes A − B, handles sign, and displays the result on seven-segment displays and LEDs.

The design is self-contained in a single Verilog source file (`bcd_subtractor_fsm.v`) and is suitable as a learning exercise, lab assignment, or starting point for more advanced BCD arithmetic circuits.

---

## 🎯 Learning Objectives

By studying and implementing this project, you will:

- Understand **FSM design** principles — state encoding, transitions, and output logic in Verilog.
- Practice **BCD encoding/decoding** and its relationship to binary arithmetic.
- Learn **active-low button interfacing** common to FPGA evaluation boards.
- Implement **seven-segment display drivers** using combinational logic.
- Apply **BCD-to-binary** and **binary-to-BCD** conversion techniques.
- Gain hands-on experience with **Quartus Prime** synthesis, pin assignment, and FPGA programming.
- Explore **asynchronous reset** design patterns and their trade-offs.

---

## 🖥️ Hardware Requirements

| Component | Details |
|-----------|---------|
| FPGA Board | Altera/Intel **DE2-115** (Cyclone IV E — EP4CE115F29C7) or compatible |
| Programming Cable | USB Blaster (included with DE2-115) |
| EDA Tool | **Quartus Prime** Lite or Standard (version 13.0+ recommended) |
| Simulation (optional) | ModelSim-Altera or **iverilog** for testbench verification |
| Power | USB or external 12 V supply for the DE2-115 board |

> **Note:** The design can be adapted to other FPGA boards by remapping the pin assignments accordingly.

---

## ⚡ Quick Start Guide

1. **Get the source** — Copy `bcd_subtractor_fsm.v` into a new folder.
2. **Create Quartus project** — Open Quartus Prime → *New Project Wizard* → add `bcd_subtractor_fsm.v` as the source file; set top-level entity to `bcd_subtractor_fsm`.
3. **Select device** — Choose **Cyclone IV E / EP4CE115F29C7** (DE2-115 target).
4. **Assign pins** — Open *Assignments → Pin Planner* (or import a `.qsf`) using the pin table in the **Pin Assignments (DE2-115)** section below.
5. **Compile** — *Processing → Start Compilation* (Ctrl+L). Resolve any warnings before continuing.
6. **Program the board** — Connect via USB Blaster; open *Tools → Programmer* and download the generated `.sof` file.
7. **Operate the design** — Follow the **Board Controls** section to load values and view results.

---

## 🎮 Board Controls

| Control | Direction | Function |
|---------|-----------|----------|
| `KEY[0]` *(active-low)* | Input | **Reset** — clears A, B registers; FSM returns to `IDLE` |
| `KEY[1]` *(active-low)* | Input | **Load A** — latches `SW[7:0]` as A (tens = `SW[7:4]`, ones = `SW[3:0]`) |
| `KEY[2]` *(active-low)* | Input | **Load B** — latches `SW[15:8]` as B (tens = `SW[15:12]`, ones = `SW[11:8]`) |
| `KEY[3]` *(active-low)* | Input | **Show Result** — computes A − B; enters `SHOW_R` state |
| `SW[3:0]` | Input | A **ones** digit (enter BCD 0–9) |
| `SW[7:4]` | Input | A **tens** digit (enter BCD 0–9) |
| `SW[11:8]` | Input | B **ones** digit (enter BCD 0–9) |
| `SW[15:12]` | Input | B **tens** digit (enter BCD 0–9) |
| `HEX7` / `HEX6` | Output | 🔢 **Always** displays A register (`A_tens` → HEX7, `A_ones` → HEX6) via permanent `sevenseg` wiring |
| `HEX5` / `HEX4` | Output | 🔢 **Always** displays B register (`B_tens` → HEX5, `B_ones` → HEX4) via permanent `sevenseg` wiring |
| `HEX3` | Output | ⬛ **Always blank** — driven to `7'b1111111` (all segments off, unused) |
| `HEX2` | Output | ➖ Minus sign (`7'b0111111`) when result is negative **and** FSM is in `SHOW_R`; otherwise off |
| `HEX1` / `HEX0` | Output | 🔢 Result magnitude (`tens` → HEX1, `ones` → HEX0) only in `SHOW_R`; shows `0` in all other states |
| `LEDR[17:0]` | Output | 💡 Binary value of A (`SHOW_A`), B (`SHOW_B`), or `diff` magnitude (`SHOW_R`); **0 in `IDLE`** |

> Any switch nibble set above 9 is automatically treated as 0 (BCD sanity check).

---

## ✨ Overview

`bcd_subtractor_fsm` reads two 2-digit BCD numbers from switches, subtracts them, and displays A, B, or the result on the HEX displays and `LEDR`.

Features:
- 🧮 Loads A or B from 4-bit BCD nibbles on `SW` (invalid BCD > 9 becomes 0).
- ➖ Computes A - B, shows magnitude and a minus sign if negative.
- 🔁 Shows current selection (A, B or Result) on `LEDR`.

## 📁 Files
- `bcd_subtractor_fsm.v` — top-level FSM + `sevenseg` module.

## 📌 Pin / Signal Mapping (module-level)
- Inputs:
  - `CLOCK_50` : 50 MHz clock
  - `SW[15:0]` : BCD nibbles
    - `SW[3:0]`   = A ones
    - `SW[7:4]`   = A tens
    - `SW[11:8]`  = B ones
    - `SW[15:12]` = B tens
  - `KEY[3:0]` : active-low push-buttons
    - `KEY[0]` : reset (active low) 🔁
    - `KEY[1]` : load A (captures SW into A_ones/A_tens and enters SHOW_A) 🅰️
    - `KEY[2]` : load B (captures SW into B_ones/B_tens and enters SHOW_B) 🅱️
    - `KEY[3]` : show result (enters SHOW_R) ➕

- Outputs:
  - `HEX7` / `HEX6` : 🔢 permanently wired to `A_tens` / `A_ones` via `sevenseg` instances
  - `HEX5` / `HEX4` : 🔢 permanently wired to `B_tens` / `B_ones` via `sevenseg` instances
  - `HEX3` : ⬛ always blank (`7'b1111111` — unused)
  - `HEX2` : ➖ minus sign (active only in `SHOW_R` when result is negative)
  - `HEX1` / `HEX0` : 🔢 result magnitude (`tens`/`ones`), non-zero only in `SHOW_R`
  - `LEDR[17:0]` : 💡 LEDs showing A (SHOW_A), B (SHOW_B), result magnitude (SHOW_R), or 0 (IDLE)

## ⚙️ Behavior
- 🔢 Inputs should be BCD digits (0–9). If a nibble > 9 it is treated as 0 when loaded (BCD sanity check).
- ➖ The module computes signed difference A − B. If negative, the magnitude is displayed and a minus sign is lit on `HEX2`.
- 🔢 `HEX7`/`HEX6` and `HEX5`/`HEX4` are **always driven** by the A and B registers respectively — they do not switch off between states.
- 💡 `LEDR` = A (binary) in `SHOW_A`, B in `SHOW_B`, diff magnitude in `SHOW_R`, **0 in `IDLE`**.
- ⬛ `HEX3` is always blank (tied to `7'b1111111`).

## ⚙️ How It Works

The design processes inputs through a clear pipeline:

```
SW[15:0]  ──►  BCD nibbles  ──►  Binary A / B  ──►  Subtraction  ──►  BCD result  ──►  HEX display
                                                        │
                                                   FSM state
                                              (IDLE / SHOW_A / SHOW_B / SHOW_R)
```

1. **Input** — `SW` holds four 4-bit BCD nibbles for A tens/ones and B tens/ones.
2. **Load** — Pressing `KEY[1]` or `KEY[2]` registers the switch values into internal registers and transitions the FSM.
3. **BCD → Binary** — Combinationally: `A = A_tens × 10 + A_ones`, `B = B_tens × 10 + B_ones`.
4. **Subtraction** — A signed 9-bit difference `diff = A − B` is computed. The MSB is the `negative` flag.
5. **Magnitude** — If negative, `|diff| = B − A`; otherwise `|diff| = A − B`.
6. **Binary → BCD** — `tens = |diff| / 10`, `ones = |diff| % 10` (combinational).
7. **Display** — `sevenseg` instances are **permanently wired**: A always drives `HEX7`/`HEX6`; B always drives `HEX5`/`HEX4`; result (`d3`/`d2`, non-zero only in `SHOW_R`) drives `HEX1`/`HEX0`. `HEX2` shows `−` (`7'b0111111`) only in `SHOW_R` when negative. `HEX3` is always blank.

---

## 🔬 Detailed Explanation

This section walks through how the design works end-to-end and explains the key implementation choices.

- 🔄 FSM states
  - `IDLE` (2'b00): default state after reset. `LEDR = 0`. `HEX7`/`HEX6` and `HEX5`/`HEX4` still show their registers (both 0 after reset). `HEX1`/`HEX0` show 0 (result display inactive).
  - `SHOW_A` (2'b01): A was loaded; `LEDR` = A (binary). `HEX7`/`HEX6` are permanently wired to A so update immediately on load. `HEX1`/`HEX0` remain 0 (result not yet computed).
  - `SHOW_B` (2'b10): B was loaded; `LEDR` = B (binary). `HEX5`/`HEX4` are permanently wired to B. `HEX1`/`HEX0` remain 0.
  - `SHOW_R` (2'b11): `LEDR` = unsigned magnitude of A − B. `HEX1`/`HEX0` show result `tens`/`ones`. `HEX2` shows minus sign if `negative` is asserted; otherwise off. `HEX3` is always blank.

- ⌨️ Loading values (KEY inputs)
  - `KEY[0]` *(negedge, async)*: active-low reset — clears `A_ones`, `A_tens`, `B_ones`, `B_tens` to 0 and returns state to `IDLE`.
  - `KEY[1]` *(active-low, posedge clocked)*: samples `SW[3:0]` → `A_ones`, `SW[7:4]` → `A_tens`. Any nibble > 9 is forced to 0. FSM → `SHOW_A`.
  - `KEY[2]` *(active-low, posedge clocked)*: samples `SW[11:8]` → `B_ones`, `SW[15:12]` → `B_tens` with the same BCD clamp. FSM → `SHOW_B`.
  - `KEY[3]` *(active-low, posedge clocked)*: only advances FSM to `SHOW_R`; does **not** latch any switch values.

- 🔢 BCD → Binary conversion
  - Declared as combinational `wire` — always up to date:
    - `wire [7:0] A = (A_tens * 8'd10) + A_ones;`
    - `wire [7:0] B = (B_tens * 8'd10) + B_ones;`
  - No clock needed; the result updates instantly when registers change.

- ➖ Subtraction and sign handling
  - `wire signed [8:0] diff_signed = A - B;` — 9-bit signed to capture the full range of 0–99 difference.
  - `wire negative = diff_signed[8];` — MSB is the sign bit.
  - `wire [7:0] diff = negative ? (B - A) : (A - B);` — unsigned magnitude.
  - `assign HEX2 = (minus && state == SHOW_R) ? 7'b0111111 : 7'b1111111;` — minus segment pattern, only active in `SHOW_R` when negative.

- 🔢 Result → BCD conversion
  - `wire [3:0] tens = (diff / 10) % 10;`
  - `wire [3:0] ones = diff % 10;`
  - These are combinational wires that are fed through the `d3`/`d2` registers (set to 0 outside `SHOW_R`) → `sevenseg sR1` → `HEX1` and `sevenseg sR0` → `HEX0`.

- 💡 LEDR mapping (combinational `always @(*)`)
  - `SHOW_A` → `LEDR = A` (8-bit binary of A)
  - `SHOW_B` → `LEDR = B` (8-bit binary of B)
  - `SHOW_R` → `LEDR = diff` (unsigned magnitude of A − B)
  - `IDLE` / default → `LEDR = 0`
  - Only the lower 8 bits are meaningfully used (values 0–99); the upper 10 bits remain 0.

- 🖥️ Seven-seg module (`sevenseg`)
  - Simple combinational `always @(*)` case statement mapping digits 0–9 to **active-low** 7-bit segment patterns.
  - `default: seg = 7'b1111111` — all segments off for any value outside 0–9.
  - Segment encoding example: `4'd0 → 7'b1000000` (active-low: segments a–f lit, g off).
  - Instantiated 6 times: `sA0`, `sA1` (A display), `sB0`, `sB1` (B display), `sR0`, `sR1` (result display).

- ⏱️ Timing and practical notes
  - ⚠️ Buttons are used **without debounce**. For physical boards add a synchronous filter (e.g., 2-FF synchronizer + counter) to avoid multiple load events per button press.
  - Reset is **asynchronous** (`negedge KEY[0]`) — common for demo boards; adapt to synchronous reset if your synthesis flow requires it.
  - Division (`/`) and modulus (`%`) by the constant 10 are synthesizable; Quartus will implement them as efficient combinational logic for small bit widths.
  - The design is fully synchronous on `CLOCK_50` (50 MHz) except for the async reset.

- 📋 Example usage walkthrough
  1. 🔁 Press `KEY[0]` to reset. All registers = 0; `LEDR = 0`; `HEX7`–`HEX4` show `0`.
  2. 🅰️ Set `SW[7:4]=4`, `SW[3:0]=2` (A = 42). Press `KEY[1]`. FSM → `SHOW_A`; `LEDR` = binary `42` (0b00101010); `HEX7`=`4`, `HEX6`=`2`.
  3. 🅱️ Set `SW[15:12]=1`, `SW[11:8]=7` (B = 17). Press `KEY[2]`. FSM → `SHOW_B`; `LEDR` = binary `17`; `HEX5`=`1`, `HEX4`=`7`. `HEX7`/`HEX6` still show A=42 (always wired).
  4. ➕ Press `KEY[3]`. FSM → `SHOW_R`. `diff = 42 − 17 = 25`; `HEX1`=`2`, `HEX0`=`5`; `LEDR` = binary `25`; `HEX2` = off (positive result).
  5. ➖ **Negative example**: A=12, B=30 → `diff_signed` is negative; magnitude = 18; `HEX1`=`1`, `HEX0`=`8`; `HEX2` = minus sign (`7'b0111111`); `LEDR` = binary `18`.

## 🧪 Minimal Testbench Example
Below is a tiny simulation snippet you can use to sanity-check behavior in modelsim/iverilog. Save it as `tb_bcd_subtractor.v` and run a simulator.

```verilog
`timescale 1ns/1ps
module tb;
  reg CLOCK_50 = 0;
  reg [15:0] SW = 0;
  reg [3:0] KEY = 4'b1111; // all high (inactive)
  wire [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
  wire [17:0] LEDR;

  always #10 CLOCK_50 = ~CLOCK_50; // 50MHz -> 20ns period

  bcd_subtractor_fsm uut (.CLOCK_50(CLOCK_50), .SW(SW), .KEY(KEY),
                           .HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),
                           .HEX4(HEX4),.HEX5(HEX5),.HEX6(HEX6),.HEX7(HEX7),
                           .LEDR(LEDR));

  initial begin
    // reset
    KEY = 4'b0111; #50; KEY = 4'b1111; #50;

    // load A = 42
    SW = 16'h0042; // A_tens=4,A_ones=2
    KEY = 4'b1011; #50; KEY = 4'b1111; #50;

    // load B = 17
    SW = 16'h1700; // B_tens=1,B_ones=7 placed in high SW bits
    KEY = 4'b1101; #50; KEY = 4'b1111; #50;

    // show result
    KEY = 4'b1110; #50; KEY = 4'b1111; #200;

    $display("LEDR=%b HEX1=%b HEX0=%b HEX2=%b", LEDR, HEX1, HEX0, HEX2);
    $finish;
  end
endmodule
```

Replace signal placements in the testbench if you prefer to drive nibbles separately; this is a compact example.


## 🔎 Display Mapping Summary

| HEX | Connected to | Active when |
|-----|-------------|-------------|
| `HEX7` | `A_tens` (via `sevenseg sA1`) | **Always** (structural) |
| `HEX6` | `A_ones` (via `sevenseg sA0`) | **Always** (structural) |
| `HEX5` | `B_tens` (via `sevenseg sB1`) | **Always** (structural) |
| `HEX4` | `B_ones` (via `sevenseg sB0`) | **Always** (structural) |
| `HEX3` | `7'b1111111` (hardwired blank) | Never (unused) |
| `HEX2` | Minus sign `7'b0111111` | `SHOW_R` + negative result only |
| `HEX1` | Result tens `d3` (via `sevenseg sR1`) | Non-zero only in `SHOW_R` |
| `HEX0` | Result ones `d2` (via `sevenseg sR0`) | Non-zero only in `SHOW_R` |

> The `sevenseg` module uses **active-low** encoding (segment on = `0`, off = `1`).

## � Pin Assignments (DE2-115)

The table below lists the standard Cyclone IV E (EP4CE115F29C7) pin locations for the **DE2-115** board.
Add these to your Quartus `.qsf` file or enter them in the Pin Planner.

### Clock & Reset
| Signal | FPGA Pin |
|--------|----------|
| `CLOCK_50` | `PIN_Y2` |

### Push-Buttons (KEY — active-low)
| Signal | FPGA Pin |
|--------|----------|
| `KEY[0]` | `PIN_M23` |
| `KEY[1]` | `PIN_M21` |
| `KEY[2]` | `PIN_N21` |
| `KEY[3]` | `PIN_R24` |

### Slide Switches (SW)
| Signal | FPGA Pin | Signal | FPGA Pin |
|--------|----------|--------|----------|
| `SW[0]` | `PIN_AB28` | `SW[8]` | `PIN_AC25` |
| `SW[1]` | `PIN_AC28` | `SW[9]` | `PIN_AB25` |
| `SW[2]` | `PIN_AC27` | `SW[10]` | `PIN_AC24` |
| `SW[3]` | `PIN_AD27` | `SW[11]` | `PIN_AB24` |
| `SW[4]` | `PIN_AB27` | `SW[12]` | `PIN_AB23` |
| `SW[5]` | `PIN_AC26` | `SW[13]` | `PIN_AA24` |
| `SW[6]` | `PIN_AD26` | `SW[14]` | `PIN_AA23` |
| `SW[7]` | `PIN_AB26` | `SW[15]` | `PIN_AA22` |

### Seven-Segment Displays (HEX — active-low segments)
| Signal | Pin [6] | Pin [5] | Pin [4] | Pin [3] | Pin [2] | Pin [1] | Pin [0] |
|--------|---------|---------|---------|---------|---------|---------|----------|
| `HEX0` | `G18` | `F22` | `E17` | `L26` | `L25` | `J22` | `H22` |
| `HEX1` | `M24` | `Y22` | `W21` | `W22` | `W25` | `U23` | `U24` |
| `HEX2` | `N02` | `A13` | `B13` | `C13` | `E14` | `D15` | `C14` |
| `HEX3` | `P02` | `H15` | `J14` | `J15` | `H14` | `H16` | `G16` |
| `HEX4` | `F16` | `F15` | `G15` | `G16` | `J16` | `H17` | `F17` |
| `HEX5` | `G17` | `H19` | `J19` | `E18` | `F18` | `F21` | `E19` |
| `HEX6` | `F19` | `G19` | `G22` | `G21` | `G20` | `H21` | `H20` |
| `HEX7` | `J23` | `J25` | `H26` | `H24` | `H23` | `G24` | `K25` |

### LED (LEDR)
| Signal | FPGA Pin | Signal | FPGA Pin | Signal | FPGA Pin |
|--------|----------|--------|----------|--------|----------|
| `LEDR[0]` | `PIN_G19` | `LEDR[6]` | `PIN_J19` | `LEDR[12]` | `PIN_J16` |
| `LEDR[1]` | `PIN_F19` | `LEDR[7]` | `PIN_H19` | `LEDR[13]` | `PIN_H17` |
| `LEDR[2]` | `PIN_E19` | `LEDR[8]` | `PIN_J17` | `LEDR[14]` | `PIN_F15` |
| `LEDR[3]` | `PIN_F21` | `LEDR[9]` | `PIN_G17` | `LEDR[15]` | `PIN_G15` |
| `LEDR[4]` | `PIN_F18` | `LEDR[10]` | `PIN_J15` | `LEDR[16]` | `PIN_G16` |
| `LEDR[5]` | `PIN_E18` | `LEDR[11]` | `PIN_H16` | `LEDR[17]` | `PIN_H15` |

> **Reference:** Altera DE2-115 User Manual — *Chapter 3: Using the DE2-115 Board*.
> For a ready-to-use `.qsf` file, refer to the DE2-115 System CD or the Terasic resource page.

---

## 🛠️ Build / Synth (Quartus)
1. Create a Quartus project and add `bcd_subtractor_fsm.v`.
2. Set the target device to **EP4CE115F29C7** (DE2-115).
3. Apply the pin assignments from the **Pin Assignments (DE2-115)** section above.
4. Compile and program the device.

Notes: pin names vary by board — provide a board-specific `.qsf` or use the Pin Planner to map signals.

## 🧪 Simulation
- Create a simple testbench that toggles `CLOCK_50`, drives `SW`, and pulses active-low `KEY` signals to load A/B and request the result. Verify expected HEX and LEDR outputs.


## 👨‍💻 Author & License

**Author:** Harshit Settipalli  
📧 **Email:** harshitsettipalli@gmail.com  
💼 **LinkedIn:** [linkedin.com/in/harshit-settipalli-073356267](https://www.linkedin.com/in/harshit-settipalli-073356267)

**Project:** 16 bit BCD Subtractor using keys 
**Target:** Altera DE2-115 (Cyclone IV FPGA)  
**Purpose:** Educational demonstration  
### Author

| Field | Details |
|-------|---------|
| **Project** | 16 bit BCD Subtractor using keys |
| **Language** | Verilog HDL |
| **Target Board** | Altera/Intel DE2-115 (Cyclone IV E) |
| **Tools** | Quartus Prime, ModelSim / iverilog |
| **Created** | 2026 |

> Update this table with your name, student ID, course code, or institution as appropriate.

### License

This project is released under the **MIT License**.

```
MIT License

Copyright (c) 2026  Harshit Settipalli 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


---
If you want a ready-to-use `.qsf` pin assignment file for the DE2-115, or a more complete testbench with automated checking, open an issue or ask — happy to help! ✨

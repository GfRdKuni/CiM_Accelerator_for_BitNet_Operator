# CiM_Accelerator_for_BitNet_Operator  
This is a hardware accelerator for the BitNet.cpp inference operator based on the Compute-in-Memory (CiM) architecture.  

<img width="981" height="714" alt="image" src="https://github.com/user-attachments/assets/bdd2f809-352c-44a0-a136-4c1d87f2b003" />  
<img width="938" height="592" alt="image" src="https://github.com/user-attachments/assets/955b5051-c9a4-462e-b2ea-b9207f90259f" />  
<img width="915" height="459" alt="image" src="https://github.com/user-attachments/assets/0a849dc9-e025-4624-8b50-62b70511e746" />  


## Core Functionality  
This hardware implements the `three_table_impl_*` operator (with the "Act quantization" part extracted). It handles matrix multiplication tasks corresponding to gray blocks, with a scale of `(BM × BBK) × (BBK × M)`.  

- The green block matrix multiplication of size `(N×K) × (K×M)` is implemented in parallel based on Element-wise LUT (Lookup Table) and Adder Tree.  
- The gray block matrix multiplication of size `(BM×BBK) × (BBK×M)` is implemented serially based on the green block computation.  


## Repository Structure  
The repository contains 3 main directories, corresponding to hardware design, data processing scripts, and documentation:  

1. **`src/`**: Verilog source code for hardware design, including implementations of various functional modules such as:  
   - Control and data paths: `Ctrl_top.v` (control top), `Data_top.v` (data top), `Para_Top.v` (parallel top), `Top.v` (overall top), etc.
   - Arithmetic units: `Accumulator.v` (accumulator), `Adder_Tree_8_to_1.v` (8-input adder tree), `Signed_Adder.v` (signed adder), etc.    
   - Auxiliary modules: `LUT_MUX.v` (LUT and multiplexer), `Sign_Gen.v` (sign generator), `dff.v` (flip-flop), etc.  

2. **`Scripts/`**: MATLAB scripts for data generation, encoding, verification, and workflow automation, including:  
   - Data generation: `generate_act_data.m` (generates activation data in hex format), `generate_wm_data.m`/`generate_ws_data.m` (generate weight magnitude/sign data in hex), `generate_ternary_matrix.m` (generates ternary matrices with elements -1, 0, 1), `generate_quantized_int32_matrix.m` (generates quantized int32 matrices with range [-127, 127]).  
   - Encoding and quantization: `encode_ternary_matrix.m` (encodes ternary matrices into 5-bit codes, split into 4-bit magnitude (WM) and 1-bit sign (WS)).  
   - Verification tools: `matrix_multiply.m` (performs integer matrix multiplication to compute expected results), `check_int16_range.m` (verifies if matrix elements are within int16 range [-32768, 32767]).  
   - Workflow automation: `Generate_Input_and_expected_output.m` (generates input data and expected output matrices), `Answer_Check.m` (verifies consistency between actual and expected results).  

3. **`docs/`**: Contains `BITNET&存算一体.pptx`, a design document explaining BitNet principles and the CiM architecture.  

4. **`sim/`**: Testbench files for hardware simulation, including `tb_top.sv` and other verification modules.

## Hardware Design Features  
- **Storage Design**:  
  - On-chip storage for activations (Act) and weights (Weight). Weights are stored in a "Sign (S)-Magnitude (M)" separated format to ensure memory access alignment.  
  - Storage scale:  
    - Act Mem: `BBK/K × ACT_BIT × K`  
    - WS Mem (Weight Sign): `(BBK/K × BM/N) × (N × WS_BIT) × K/3`  
    - WM Mem (Weight Magnitude): `(BBK/K × BM/N) × (N × WM_BIT) × K/3`  

- **Parallel Computing Architecture**:  
  - Contains `M` channels, each independently processing a batch in matrix multiplication.  
  - Each channel has `K/3` pre-computation units, with results reused by `N` MUXes.  
  - Each channel has `N×K/3` MUXes (16 inputs each) and sign generation modules.  
  - Number of adders per channel: `N×K/3` (derived from the accumulation formula `1+1+2+4+…+2^(lb(K/3)-1)`), enabling efficient accumulation.  

- **Computation Flow**: Magnitudes are used to precompute LUT entries, and signs generate signed results. Matrix multiplication is parallelized via LUTs and adder trees.

## Version 2.0 Architecture Enhancements  

In the updated design, we introduce several key enhancements to improve efficiency, area utilization, and sparsity awareness, inspired by the BitNet.cpp TL2 kernel and recent CiM research:

### 1. 5-Pack-3 Zero-Aware Encoding & Hierarchical Dynamic SM LUT  
- **Encoding Scheme**: Ternary weights {-1, 0, +1} are grouped in 5-bit packs and mapped to 3-trit representations, reducing storage overhead and improving memory alignment.  
- **Zero-Awareness**: The encoding explicitly preserves zero values, enabling better exploitation of weight sparsity in LUT-based computations.  
- **Hierarchical LUT**: A two-stage lookup table structure reduces area overhead while maintaining low-latency access to precomputed partial sums. Only 8 out of 14 non-zero weight combinations are stored directly; others are derived via single addition, reducing LUT size by ~43% while retaining full functionality.

### 2. Sign-Magnitude Dual Adder Tree  
- **Data Representation**: We adopt a sign-magnitude format for activations and weights, reducing bit-switching activity and multiplication cost compared to two’s complement.  
- **Dual Unsigned Adder Trees**: Two separate adder trees process magnitude values, with a single final subtractor handling sign resolution. This minimizes the overhead of signed arithmetic to only one stage.  
- **Benefits**:  
  - Lower dynamic power consumption  
  - Reduced critical path delay  
  - Better compatibility with LUT-based precomputation



## Deployment Flow  
1. **Generate Input Data and Expected Output**  
   Run `Generate_Input_and_expected_output.m` in `Scripts/` to:  
   - Generate a quantized int32 activation matrix (`Act_Matrix`) via `generate_quantized_int32_matrix.m`.  
   - Generate a ternary weight matrix (`Weight_Matrix`) via `generate_ternary_matrix.m`.  
   - Encode `Weight_Matrix` into magnitude (`WM_Matrix`) and sign (`WS_Matrix`) matrices via `encode_ternary_matrix.m`.  
   - Compute the expected matrix multiplication result (`Expected_Matrix`) via `matrix_multiply.m`.  
   - Verify `Expected_Matrix` is within int16 range via `check_int16_range.m`.  
   - Generate hex files for hardware input: `Act_file.hex` (activations), `WM_file.hex` (weight magnitudes), `WS_file.hex` (weight signs).
  <img width="2559" height="1249" alt="image" src="https://github.com/user-attachments/assets/adb96767-ca29-4165-95bb-3fe2c34e4761" />
  <img width="1282" height="628" alt="image" src="https://github.com/user-attachments/assets/6a61dc4d-3ddc-40c1-a6f4-6c4cf2e49861" />



2. **Hardware Simulation**  
   Use Vivado 2019.2 to simulate the hardware design (from `src/`, you can use the `tb_top.sv` as the testbench). Load the generated hex files as input and obtain the simulation result log `result_output.log`. You should remember to change the path in `tb_top.sv` file.
   <img width="1280" height="749" alt="image" src="https://github.com/user-attachments/assets/e9f06a4d-3c66-401e-ad55-140af89e2c6b" />
   <img width="544" height="578" alt="image" src="https://github.com/user-attachments/assets/4049f2a1-2648-46b1-a5c2-5e6626de3f91" />



4. **Result Verification**  
   Run `Answer_Check.m` in `Scripts/` to:  
   - Convert `result_output.log` to an actual result matrix (`Actual_Matrix`) via `logToMatrix`.  
   - Compare `Actual_Matrix` with `Expected_Matrix` via `areMatricesEqual` to verify correctness.
   <img width="1279" height="645" alt="image" src="https://github.com/user-attachments/assets/0253caa2-ffda-4b9c-85c2-101ed189a505" />



## Software Requirements  
- **>MATLAB R2023a**: Required to run scripts in `Scripts/` (data generation, encoding, result verification).  
- **>Vivado 2019.2**: Required for hardware simulation to generate `result_output.log`.  


## Specific Parameter Details  
With parameters `BM=256`, `BBK=96`, `N=32`, `K=24`, `ACT_BIT=32`, `WM_BIT=4`, `WS_BIT=1`, key metrics are as follows:  


### 1. Storage Scale (in Common Units: 1 Byte = 8 bits; 1 KB = 1024 Bytes)  
- **Act Mem Size**:  
  Formula: `BBK/K × ACT_BIT × K`  
  Calculation: `96/24 × 32 × 24 = 4 × 32 × 24 = 3072 bits = 384 Bytes`  

- **WS Mem Size** (Weight Sign Memory):  
  Formula: `(BBK/K × BM/N) × (N × WS_BIT) × K/3`  
  Calculation:  
  - `BBK/K = 96/24 = 4`; `BM/N = 256/32 = 8` → `BBK/K × BM/N = 4 × 8 = 32`  
  - `N × WS_BIT = 32 × 1 = 32`; `K/3 = 24/3 = 8`  
  - Total: `32 × 32 × 8 = 8192 bits = 1024 Bytes = 1 KB`  

- **WM Mem Size** (Weight Magnitude Memory):  
  Formula: `(BBK/K × BM/N) × (N × WM_BIT) × K/3`  
  Calculation:  
  - `N × WM_BIT = 32 × 4 = 128`  
  - Total: `32 × 128 × 8 = 32768 bits = 4096 Bytes = 4 KB`  


### 2. Matrix Multiplication Sizes  
- **Green Block**: `(N×K) × (K×M) = (32×24) × (24×M) = 768 × 24M`  
- **Gray Block**: `(BM×BBK) × (BBK×M) = (256×96) × (96×M) = 24576 × 96M`  


### 3. Hardware Architecture Metrics  
- **Pre-computation units per channel**: `K/3 = 24/3 = 8`  
- **MUXes per channel**: `N×K/3 = 32 × 8 = 256`  
- **Sign generation modules per channel**: Same as MUXes → 256  
- **Adders per channel**: `N×K/3 = 256`  


These values reflect the resource usage and computational scale of the accelerator under the specified parameters.

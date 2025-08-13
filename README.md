# CiM_Accelerator_for_BitNet_Operator
This is a HW Accelerator for BitNet.cpp inference Operator based on CiM Architecture

<img width="981" height="714" alt="image" src="https://github.com/user-attachments/assets/bdd2f809-352c-44a0-a136-4c1d87f2b003" />

<img width="938" height="592" alt="image" src="https://github.com/user-attachments/assets/955b5051-c9a4-462e-b2ea-b9207f90259f" />

<img width="915" height="459" alt="image" src="https://github.com/user-attachments/assets/0a849dc9-e025-4624-8b50-62b70511e746" />


该硬件实现了three_table_impl_*这个算子（将“Act量化”的算子提取出去）

每次计算灰色块对应的矩阵乘法任务，规模为(BM × BBK)×(BBK × M)

(N×K)×(K×M)规模的绿色块矩阵乘法基于Element-wise的LUT+Adder Tree并行实现

(BM×BBK)×(BBK×M)规模的灰色块矩阵乘法在绿色块计算的基础上串行实现

片上存储的Act和Weight为灰色块对应的矩阵数据，Act Mem规模是BBK/K × ACT_BIT × K

Weight采用S-M的表达形式，将符号和幅值分开存储保证访存对齐

WS Mem规模是(BBK/K×BM/N) × (N×WS_BIT)×K/3

WM Mem规模是(BBK/K×BM/N) × (N×WM_BIT)×K/3

幅值用于预计算生成查找表表项，符号用于生成带符号的结果

硬件有M个channel,分别用于计算矩阵乘法中的一个batch

每个channel有K/3个预计算单元,每个预计算单元的结果被N个MUX复用

每个channel有N×K/3个MUX和N×K/3个符号生成模块，每个MUX有16个输入

每个channel有N×(1+1+2+4+…+2^(lb(K/3)-1))=N×K/3个加法器



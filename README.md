# Tiny Four-stage Pipeline RISV-V CPU

一个由FPGA课程设计衍生出来的项目，纯粹是做着玩的。现在还算是一个粗糙的半成品，有时间的话大概会持续更新（先鸽为敬

----

### 1.架构简介
> 目前仅支持RV32I中的部分指令，中断和异常还没有写完。指令流水线共分为四级，分别是取指、译码、执行和写回，采用数据旁路的方法解决相关性问题。

![一个暂时还没有完全实现的架构图](https://raw.githubusercontent.com/Oxoxxidane/Tiny-RISC-V-CPU/main/%E6%9E%B6%E6%9E%84%E5%9B%BE.png)

---

### 2.文件结构

目前写完的部分都已经通过ModelSim仿真，并且通过了Gowin GW1NSR-4C FPGA的板上测试，FPGA工程文件放在文件夹Gowin_proj中。

#### 文件描述

| 文件名      | 描述   |
| --------   | ----- |
| cpu_top.v      | CPU顶层文件(不包含存储器)  |
| IFU.v         | 取指令单元  |
| IDU.v         | 指令译码单元 |
| EXU.v| 指令执行单元 |
| WBU.v | 写回单元 |
| regfile.v | 寄存器堆 |
| uart.v | 测试用的临时串口 |
| rom.v modelsim | 仿真阶段使用的存储器，未例化 |

包含存储器的顶层文件是top.v  
测试用的机器码是test.mi  
gowin_prom.v和gowin_sp.v是用高云IP工具生成的ROM和RAM，分别作为程序存储器和数据存储器  

所有文件统一用GBK编码，如果打开的编码格式不对可能会导致中文注释乱码

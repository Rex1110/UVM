# **AXI4 SRAM slave**



## **1. Overview**
![schematic](https://github.com/Rex1110/UVM/assets/123956376/dccab258-ae57-4de7-8a16-d6aface4e9c4)

## **2. Verification target**
先前 [formal verification 驗證的 AXI4](https://github.com/Rex1110/Formal-verification/tree/master/AXI4) 主要基於 MASTER 端 (CPU) 和 SLVAE 端 (SRAM) 彼此的 interface 控制訊號的行為是否符合規範，而並未實際檢查到 SLAVE 本身行為，
在這項目中將透過 UVM 驗證 SLAVE 是否能正確處理不同 burst length 的讀寫操作。
其中 SLAVE 最大支援 burst length 為 16，burst size 為 4 bytes。

## **3. SRAM specification**

| Feature               | Details           |
|-----------------------|-------------------|
| SRAM size             | 16384 words       |
| Interface             | AXI4              |
| Address size          | 4 bytes           |
| Data size             | 4 bytes           |
| Burst type            | INCR              |
| Burst length          | 1 ~ 16            |
| Burst size            | 4 bytes           |

**unaligned transfer, narrow transfer 實作中...。**

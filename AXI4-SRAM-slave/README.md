## 1. Overview
![schematic](https://github.com/Rex1110/UVM/assets/123956376/dccab258-ae57-4de7-8a16-d6aface4e9c4)

## 2. Verification target
先前 [formal verification 驗證的 AXI4](https://github.com/Rex1110/Formal-verification/tree/master/AXI4) 主要基於 MASTER 端 (CPU) 和 SLVAE 端 (SRAM) 彼此的 interface 控制訊號的行為是否符合規範，而並未實際檢查到 SLAVE 本身行為，
在這項目中將透過 UVM 驗證 SLAVE 是否能正確處理不同 burst length 和 burst size 的讀寫操作。
其中 SLAVE 最大支援 burst length 為 16，burst size 為 4 bytes，因此最大 transaction size 為 64 bytes。
在這會產生不同的 AWLEN，AWSIZE，ARLEN，ARSIZE 進行相對應驗證。

## 3. SRAM specification

| Feature               | Details           |
|-----------------------|-------------------|
| SRAM size             | 16384 words       |
| Interface             | AXI4              |
| Address size          | 4 bytes           |
| Data size             | 4 bytes           |
| Burst type            | INCR              |
| Burst length          | 1 ~ 16            |
| Burst size            | 1, 2, 4 bytes     |


## 4. Verification flow

![flow](https://github.com/Rex1110/UVM/assets/123956376/b115ccd7-42e4-483a-bd35-5404f2a559ff)

### Step1 Initial SRAM
初始化 SRAM，由於最大 transaction size 為 64 bytes，因此 reference model 為 64 bytes。

### Step2 Copy SRAM data
從即將寫入位置讀取 64 bytes 資料至 reference model，確保當前狀態和即將寫入 SRAM 位置資料相同。

### Step3 Write transaction
根據隨機生成的 AWLEN, AWSIZE, WSTRB, data 分別寫入 SRAM 和 reference model，寫入開始位置和 step2 讀取位置相同。

### Step4 Read transaction
根據隨機生成 ARLEN, ARSIZE 讀取 SRAM 資料用於接下來資料比較，而起始位置和 step2, step3 相同。

### Step5 Compare
比較 reference model 中和 step4 讀取出來的資料是否吻合。

### step2 ~ step5 重複執行, 直到所有 testcase 跑完。
### 在驗證時，write transaction size 和 read transaction size 不一定相同，而是隨機產生，因此 write transaction 可能比較大又或是比較小，通過指令可以限制他的大小詳細請見 makefile 配置。

## 5. Verification result

### Example. 1 

#### State of SRAM before writing
我們可以觀察到 SRAM 目前都為 0，這是由於 step1 會對其初始化，而第三個 testcase 也只是對其寫入三次，因此這個 SRAM 空間還尚未寫入過皆為 0。

#### Write
寫入位置為 7644，長度為 2，並且每個 size 為 2 bytes。

#### Read
讀取位置為 7644，長度為 10，並且每個 size 為 2 bytes。

![ex1](https://github.com/Rex1110/UVM/assets/123956376/cd8ec63a-5bdf-4fe9-81ac-6adcaf7f92f0)



#### Example. 2 

#### State of SRAM before writing
我們可以觀察到 SRAM 目前都是有資料的，因為這是第 99995 個 testcase，也就是說我們已經進行 99995 次寫入，因此這區域之前被寫入過。

#### Write
寫入位置為 6576，長度為 9，並且每個 size 為 4 bytes。

#### Read
讀取位置為 6576，長度為 9，並且每個 size 為 1 bytes。

![ex2](https://github.com/Rex1110/UVM/assets/123956376/f99c8924-803a-4098-b014-f00197eb76ab)



### Result

隨機生成50萬個 tansactions 皆通過。

![result](https://github.com/Rex1110/UVM/assets/123956376/4253e474-8aec-4dc3-b58e-2675f637d629)






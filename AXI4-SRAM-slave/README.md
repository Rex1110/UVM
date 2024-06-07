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

最大 transaction size 為 64 bytes，因此 reference model 以 64 bytes 的暫存器進行模擬。

### 1. Initial
- **隨機產生寫入位置 AWADDR**：將 SRAM 從起始寫入位置至起始寫入位置 + 64 bytes 清零，同時將 reference model 中的 64 bytes 暫存器也清零。
- **涉及**：Write transaction。
- **參數設定**：AWSIZE=2, AWLEN=15 (4 bytes * 16 次)

### 2. Write date
- **隨機產生 AWSIZE (0, 1, 2), ARSIZE (0 ~ 15) 和 WDATA**：從初始化階段的起始位置開始，寫入相對應的數據。
- **涉及**：Write transaction。

### 3. Read data
- **起始位置**：與寫入階段的起始位置相同，確保讀取和寫入操作對應。
- **隨機產生 ARSIZE (0, 1, 2)**：這個值決定每次讀取操作的數據大小。
- **計算 AWLEN**：公式 `AWLEN = (((AWLEN + 1) * (2 ** AWSIZE)) / (2 ** ARSIZE)) - 1` 用於確保寫入和讀取操作涵蓋的總 bytes 數相同。
- **涉及**：Read transaction（讀取事務）。
- **ARSIZE 設定說明**：這一設定確保讀取操作符合系統對事務的限制，具體規則如下：
  - **寫入總 bytes 數 > 0 且 ≤ 16 bytes**：ARSIZE 可設為 0, 1, 2。
  - **寫入總 bytes 數 > 16 且 ≤ 32 bytes**：ARSIZE 可設為 1, 2。
  - **寫入總 bytes 數 > 32 且 ≤ 64 bytes**：ARSIZE 必須設為 2。

這些規範確保讀取操作不會因為單個 transaction 的傳輸次數超過最大限制（16次）而出現問題。例如，當寫入超過 16 bytes 時，如果設定 ARSIZE 為 0（每個 transfer 1 byte），則會需要超過 16 次傳輸來完成讀取，這超過了系統的最大傳輸限制。因此添加了約束。

基於以上設定，每次 test 都涉及兩次寫入一次讀取：
1. 第一次寫入主要用於環境初始化。
2. 第二次寫入根據初始化的空間寫入待檢查資料。
3. 最後透過讀取相同位置的資料檢查是否正確。

![flow](https://github.com/Rex1110/UVM/assets/123956376/4aba4e14-3e70-46f3-add1-9ab604e2d409)

## 5. Verification result

### Example. 1 
![ex1](https://github.com/Rex1110/UVM/assets/123956376/9a3d6377-fdc9-4e64-b420-80cfde17e570)


### Example. 2 
![ex2](https://github.com/Rex1110/UVM/assets/123956376/745b7ecc-fbe2-482b-8711-949544d16a0b)

隨機生成10萬個 tansactions 皆通過。 \
![result](https://github.com/Rex1110/UVM/assets/123956376/13f46c96-9e05-4243-9f7d-b2b7ae86450a)





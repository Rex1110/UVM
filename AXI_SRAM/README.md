# **AXI4 SRAM**

## **1. Overview**
![schematic](https://github.com/user-attachments/assets/9412df90-546e-4b99-84bd-d69ea91bd3f3)


## **2. SRAM specification**

| Feature               | Details           |
|-----------------------|-------------------|
| SRAM Size             | 16384 words       |
| Interface             | AXI4              |
| Address Size          | 4 bytes           |
| Data Size             | 4 bytes           |
| AxBURST               | FIXED, INCR, WRAP |
| AxSIZE                | 0, 1, 2           |
| AxLEN                 | 0 ~ 15            |


## **3. Verification target**

先前課程設計的 SRAM wrapper 不支援 narrow transfer 和 unaligned transfer，AxBURST 也僅支援 INCR mode，AxLEN 僅支援 0 和 3， 後續修改支援 narrow transfer 和 unaligned Transfer，並且 AxLEN 的擴展至 0 到 15。同時，AxBURST 的也支援 FIXED、INCR 和 WRAP 三種 mode。

根據設計改進，歸納出以下驗證目標：

| AxBURST | AxSIZE     | AxLEN       | Address aligned     |
|---------|------------|-------------|---------------------|
| FIXED   | 0, 1, 2    | 0 ~ 15      | Aligned, unaligned  |
| INCR    | 0, 1, 2    | 0 ~ 15      | Aligned, unaligned  |
| WRAP    | 0, 1, 2    | 1, 3, 7, 15 | Aligned             |

在驗證 WRAP mode 時，AxLEN 僅支援 1, 3, 7, 15，並且不包含 unaligned transfer。這是基於 [AXI4 spec A3.4.1](<http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf>) WRAP 中的限制：

1. The start address must be aligned to the size of each transfer.
2. The length of the burst must be 2, 4, 8, or 16 transfers.


## **4. Verification flow**

在驗證過程中，主要分為三個部分執行。以下將逐一說明：


### **第一部分：寫入操作**

從記憶體的最低位置 `mem[0]` 開始發起寫入操作，隨機生成不同的 **AWBURST**、**AWSIZE** 和 **AWLEN**，地址持續遞增，直到到達記憶體邊界 `mem[65535]`，如下圖所示。
![image](https://github.com/user-attachments/assets/5124fa20-54da-425e-a8e9-0dfb2a28bde9)



#### **第一筆 Transaction**
- **AWBURST**：`INCR`
- **AWSIZE**：`0`（每筆寫入資料為 1 byte，屬於 Narrow Transfer）
- **AWLEN**：`5`（傳輸 6 筆資料）

 **WSTRB** 與位置分配如下：
- **Transfer 1**：WSTRB = `4'b0001`, ADDR = `[0]`
- **Transfer 2**：WSTRB = `4'b0010`, ADDR = `[0]`
- **Transfer 3**：WSTRB = `4'b0100`, ADDR = `[0]`
- **Transfer 4**：WSTRB = `4'b1000`, ADDR = `[0]`
- **Transfer 5**：WSTRB = `4'b0001`, ADDR = `[4]`
- **Transfer 6**：WSTRB = `4'b0010`, ADDR = `[4]`

**寫入範圍**：`mem[0]` ~ `mem[5]`

---

#### **第二筆 Transaction**
- **AWBURST**：`FIXED`
- **AWSIZE**：`2`（每筆寫入資料為 4 bytes）
- **AWLEN**：`2`（傳輸 3 筆資料）

由於前一筆資料寫到 `mem[5]`，本次 Transaction 從 `mem[6]` 開始。屬於 **Unaligned Transfer**。

 **WSTRB** 與位置分配如下：
- **Transfer 1**：WSTRB = `4'b1100`, ADDR = `[4]`
- **Transfer 2**：WSTRB = `4'b1100`, ADDR = `[4]`

**寫入範圍**：`mem[6]` ~ `mem[7]`

---

#### **第三筆 Transaction**
- **AWBURST**：`FIXED`
- **AWSIZE**：`2`（每筆寫入資料為 4 bytes）
- **AWLEN**：`0`（傳輸 1 筆資料）

由於前一筆資料寫到 `mem[7]`，本次 Transaction 從 `mem[8]` 開始。

 **WSTRB** 與位置分配如下：
- **Transfer 1**：WSTRB = `4'b1111`, ADDR = `[8]`

**寫入範圍**：`mem[8]` ~ `mem[11]`

---

#### **第四筆 Transaction**
- **AWBURST**：`WRAP`
- **AWSIZE**：`1`（每筆寫入資料為 2 bytes，屬於 Narrow Transfer）
- **AWLEN**：`3`（傳輸 4 筆資料）

由於前一筆資料寫到 `mem[11]`，本次 Transaction 從 `mem[12]` 開始。WRAP 模式在到達最高地址後會繞回最低地址。

 **WSTRB** 與位置分配如下：
- **Transfer 1**：WSTRB = `4'b0011`, ADDR = `[12]`
- **Transfer 2**：WSTRB = `4'b1100`, ADDR = `[12]`
- **Transfer 3**：WSTRB = `4'b0011`, ADDR = `[8]`
- **Transfer 4**：WSTRB = `4'b1100`, ADDR = `[8]`

**寫入範圍**：`mem[8]` ~ `mem[15]`

**補充說明**：在 `mem[12]` 寫入兩筆後，地址繞回到 `mem[8]`。這屬於 [AXI4 spec A3.4.1](<http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf>) 中 WRAP 的描述。WRAP 模式主要用於填充 Cache Line，當 Critical Word 位於末端時，WRAP 能減少等待時間，優先取得所需資料。

第一階段會不斷執行寫入操作直到 `mem[65535]`，並同步更新 Reference Model。

---

### **第二部分：讀取操作**

在第二階段，我們將從寫入操作轉為讀取操作。讀取操作從記憶體的最低位置 `mem[0]` 開始，隨機生成不同的 **ARBURST**、**ARSIZE** 和 **ARLEN**，地址持續遞增，直到到達記憶體邊界 `mem[65535]`。讀取的每筆資料會與 Reference Model 即時比對，確保資料一致性，如下圖所示。
![image](https://github.com/user-attachments/assets/fcd2b287-48c6-4ad4-adb1-7887a51fb165)


---

### **第三部分：隨機讀取寫入**

在這階段一個 transaction 不一定只包含讀取或是寫入，同時地址也從有序生成數變成全數隨機，同樣的是如果今天執行讀取操作，我們仍然會進行比對

![image](https://github.com/user-attachments/assets/59050b3b-8c78-4ca5-817c-31938a7bedef)

## **5. Constraints**

### **5.1 AxBURST 限制**
```verilog
constraint AxBURST_constraint {
  AWBURST inside {`FIXED, `INCR, `WRAP};
  ARBURST inside {`FIXED, `INCR, `WRAP};
}
```

### **5.2 AxSIZE 限制**
```verilog
constraint AxSIZE_constraint {
  AWSIZE inside {`BYTE, `HALFWORD, `WORD};
  ARSIZE inside {`BYTE, `HALFWORD, `WORD};
}
```

### **5.3 WRAP mode 限制**

#### **5.3.1 WRAP mode 地址必須 aligned**
```verilog
constraint AxADDR_constraint {
  (AWVALID == 1'b1) && (AWBURST == `WRAP) -> (AWADDR % (2 ** AWSIZE)) == 0;
  (ARVALID == 1'b1) && (ARBURST == `WRAP) -> (ARADDR % (2 ** ARSIZE)) == 0;
}
```
#### **5.3.2 WRAP mode AxLEN 僅支援1, 3, 7, 15**
```verilog
constraint AxLEN_constraint {
  (AWVALID == 1'b1) && (AWBURST == `WRAP) -> AWLEN inside {'d1, 'd3, 'd7, 'd15};
  (ARVALID == 1'b1) && (ARBURST == `WRAP) -> ARLEN inside {'d1, 'd3, 'd7, 'd15};
}
```

### **5.4 A burst must not cross a 4KB address boundary**
一個挺有意思的東西，在[AXI4 spec A3.4.1](<http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf>) address structure 有提到避免跨過 4KB boundary，
假設起始地址位於 0x0000 ~ 0x0fff 之中，如果今天突發會到 0x1xxx 是要被禁止的，那這主要是因為我們一個 4KB(page size) 區塊對應一個獨立的記憶體或設備，跨過這個邊界可能會導致地址被映射到非法讀寫記憶體區段或是不同的設備，這會造成無法預期行為，也不是應該出現行為，如果真要跨你得拆成兩次傳輸。
```verilog
constraint Memory_boundary_4KB_constraint {
  (AWVALID == 1'b1) && (AWBURST == `INCR)
  -> (AWADDR % 4096) + (2 ** AWSIZE) * (AWLEN + 1) < 4096;
 
  (ARVALID == 1'b1) && (ARBURST == `INCR)  
  -> (ARADDR % 4096) + (2 ** ARSIZE) * (ARLEN + 1) < 4096;
}
```

## **6. Verification result**

![image](https://github.com/user-attachments/assets/53d0711f-1e74-490c-b8dc-7e1404261d88)


在測試結果總共比對了193632次，那都是沒有問題的(有問題我肯定修好才放上來吧)，
接下來前面提到的我們主要在測試以下行為，因此在這加入 cover property 來確認隨機的過程中確認是否都有生成

| AxBURST | AxSIZE     | AxLEN       | Address aligned     |
|---------|------------|-------------|---------------------|
| FIXED   | 0, 1, 2    | 0 ~ 15      | Aligned, unaligned  |
| INCR    | 0, 1, 2    | 0 ~ 15      | Aligned, unaligned  |
| WRAP    | 0, 1, 2    | 1, 3, 7, 15 | Aligned             |

![image](https://github.com/user-attachments/assets/c147cd81-4554-456b-83b2-34ac2f95ff4c)


### **6.1 AWBURST=FIXED; AWSIZE=0,1,2; AWLEN=0~15; Address aligned**
```verilog
generate
  for (genvar AWSIZE = 0; AWSIZE <= 2; AWSIZE++) begin: FIXED_ALIGNED_AWSIZE
    for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.AWVALID && vif.AWREADY
          |->
          (vif.AWBURST == `FIXED) && (vif.AWADDR % (2 ** AWSIZE) == 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
        )
      );
    end
  end
endgenerate
```

### **6.2 AWBURST=FIXED; AWSIZE=1,2; AWLEN=0~15; Address unaligned**
```verilog
generate
  for (genvar AWSIZE = 1; AWSIZE <= 2; AWSIZE++) begin: FIXED_UNALIGNED_AWSIZE
    for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.AWVALID && vif.AWREADY
          |->
          (vif.AWBURST == `FIXED) && (vif.AWADDR % (2 ** AWSIZE) != 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
        )
      );
    end
  end
endgenerate
```

### **6.3 AWBURST=INCR; AWSIZE=0,1,2; AWLEN=0~15; Address unaligned**
```verilog
generate
  for (genvar AWSIZE = 0; AWSIZE <= 2; AWSIZE++) begin: INCR_ALIGNED_AWSIZE
    for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.AWVALID && vif.AWREADY
          |->
          (vif.AWBURST == `INCR) && (vif.AWADDR % (2 ** AWSIZE) == 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
        )
      );
    end
  end
endgenerate
```

### **6.4 AWBURST=INCR; AWSIZE=1,2; AWLEN=0~15; Address unaligned**
```verilog
generate
  for (genvar AWSIZE = 1; AWSIZE <= 2; AWSIZE++) begin: INCR_UNALIGNED_AWSIZE
    for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.AWVALID && vif.AWREADY
          |->
          (vif.AWBURST == `INCR) && (vif.AWADDR % (2 ** AWSIZE) != 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
        )
      );
    end
  end
endgenerate
```

### **6.5 AWBURST=WRAP; AWSIZE=0,1,2; AWLEN=1,3,7,15; Address aligned**
```verilog
generate
  for (genvar AWSIZE = 0; AWSIZE <= 2; AWSIZE++) begin: WRAP_ALIGNED_AWSIZE
    for (genvar AWLEN = 1; AWLEN <= 15; AWLEN = (AWLEN << 1) + 1) begin: _AWLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.AWVALID && vif.AWREADY
          |->
          (vif.AWBURST == `WRAP) && (vif.AWADDR % (2 ** AWSIZE) == 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
        )
      );
    end
  end
endgenerate
```

### **6.6 ARBURST=FIXED; ARSIZE=0,1,2; ARLEN=0~15; Address aligned**
```verilog
generate
  for (genvar ARSIZE = 0; ARSIZE <= 2; ARSIZE++) begin: FIXED_ALIGNED_ARSIZE
    for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.ARVALID && vif.ARREADY
          |->
          (vif.ARBURST == `FIXED) && (vif.ARADDR % (2 ** ARSIZE) == 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
        )
      );
    end
  end
endgenerate
```

### **6.7 ARBURST=FIXED; ARSIZE=1,2; ARLEN=0~15; Address unaligned**
```verilog
generate
  for (genvar ARSIZE = 1; ARSIZE <= 2; ARSIZE++) begin: FIXED_UNALIGNED_ARSIZE
    for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.ARVALID && vif.ARREADY
          |->
          (vif.ARBURST == `FIXED) && (vif.ARADDR % (2 ** ARSIZE) != 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
        )
      );
    end
  end
endgenerate
```

### **6.8 ARBURST=INCR; ARSIZE=0,1,2; ARLEN=0~15; Address unaligned**
```verilog
generate
  for (genvar ARSIZE = 0; ARSIZE <= 2; ARSIZE++) begin: INCR_ALIGNED_ARSIZE
    for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.ARVALID && vif.ARREADY
          |->
          (vif.ARBURST == `INCR) && (vif.ARADDR % (2 ** ARSIZE) == 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
        )
      );
    end
  end
endgenerate
```

### **6.9 ARBURST=INCR; ARSIZE=1,2; ARLEN=0~15; Address unaligned**
```verilog
generate
  for (genvar ARSIZE = 1; ARSIZE <= 2; ARSIZE++) begin: INCR_UNALIGNED_ARSIZE
    for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.ARVALID && vif.ARREADY
          |->
          (vif.ARBURST == `INCR) && (vif.ARADDR % (2 ** ARSIZE) != 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
        )
      );
    end
  end
endgenerate
```

### **6.10 ARBURST=WRAP; ARSIZE=0,1,2; ARLEN=1,3,7,15; Address aligned**
```verilog
generate
  for (genvar ARSIZE = 0; ARSIZE <= 2; ARSIZE++) begin: WRAP_ALIGNED_ARSIZE
    for (genvar ARLEN = 1; ARLEN <= 15; ARLEN = (ARLEN << 1) + 1) begin: _ARLEN
      cov: cover property (
        @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
          vif.ARVALID && vif.ARREADY
          |->
          (vif.ARBURST == `WRAP) && (vif.ARADDR % (2 ** ARSIZE) == 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
        )
      );
    end
  end
endgenerate
```

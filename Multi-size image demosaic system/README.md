# Multi-size image demosaic system
## **1. Overview**

![verification](https://github.com/Rex1110/UVM/assets/123956376/24c320a6-d96b-4890-9854-fb551f3eddb3)


## **2. Introduction**
在數位影像處理中，demosaicing 是彩色圖像處理中([color image pipeline](<https://en.wikipedia.org/wiki/Color_image_pipeline>))重要的步驟之一，看到這個單詞可能會誤以為是要將馬賽克還原，但其實是從不完全色彩中重建出全彩色圖像的方法，只是不完全色彩因為看起來像是馬賽克故得名。


大多數的相機、手機等數位攝像產品中，並不是直接捕獲物體的顏色，而是透過感光元件來捕捉光的強度，但如果只有捕捉到光的強度，那麼獲得的只能是一張灰階圖片，僅能代表光強度，為了從光強度訊息中提取顏色訊息，我們會在感光元件上面蓋上一層濾色陣列(Color filter array, CFA)來過濾特定顏色，並且一個感光點上只覆蓋單一種顏色濾鏡，在透過算法將其重建出全彩影像，之所以只覆蓋單一顏色濾鏡主要基於成本考量。傳統的 CFA 以 [Bayer filter](<https://en.wikipedia.org/wiki/Bayer_filter>) 最為有名和最大宗，其排列有 50% 是綠色，25%是紅色，另外25%是藍色，之所以綠色為 50% 是因為對於紅綠藍三原色中，人類對於綠色最為敏感，並且綠色對於亮度訊息貢獻最大，這也是 [YUV](<https://zh.wikipedia.org/zh-tw/YUV>) 色彩空間在亮度通道 Y 中對綠色給予最高權重的原因（Y = 0.299R + 0.587G + 0.114B），因此提高綠色濾鏡占比來更好的捕捉亮度訊息，提高圖像質量，其較常見的排列以偶數列 G、R 交錯，奇數列 B、G 交錯(Index 從 0 開始)，如下圖。

![bayer_pattern](https://github.com/Rex1110/UVM/assets/123956376/f1e61ba4-d220-4e92-86f8-0ec4c7955c62)


拍攝得到的 Bayer 格式影像，需要透過各種演算法重建，以還原出完整的彩色影像。 在這次實做中，使用雙線性插值法基於周圍的像素值來填充其他通道，從而完成色彩的重建。 詳細過程將在後續章節中詳細解釋。下圖為"高解析度"成大自強校區的狗狗，依序為原始圖、Bayer圖像和重建後的結果。

![bayer](https://github.com/Rex1110/UVM/assets/123956376/ab282028-69a5-4793-9b90-2da7d724cdc6)


將 Bayer pattern 圖像放大觀察時，可以明顯看到圖像呈現類似馬賽克的風格。這也是前面提到每個 Bayer pattern 由不同顏色的濾光片組成的效果。

![dog_head](https://github.com/Rex1110/UVM/assets/123956376/a857affe-046c-44c7-b53e-7b9d8307a281)


透過放大眼部，我們可以觀察到重建後的影像與原圖的差異極小，幾乎肉眼是無法區分差異。

![eye_hrs](https://github.com/Rex1110/UVM/assets/123956376/da6d92a0-fc04-448f-a656-a67249cc1494)



相對地，我們也展示了一張"低解析度"的圖像，包括原始圖、Bayer圖像和重建後的結果。

![dog_lrs_comb](https://github.com/Rex1110/UVM/assets/123956376/4ffe4089-a569-4925-98aa-5d8eebf6d1da)


在放大的眼部影像中，對於低解析度的照片，重建後的失真較為明顯，資訊的遺失較大。 然而透過不同的重建方法以及 [color image pipeline](<https://en.wikipedia.org/wiki/Color_image_pipeline>) 的其他步驟，我們可以讓影像重建效果更接近原始場景。

![eye_lrs](https://github.com/Rex1110/UVM/assets/123956376/54a35966-f1f3-4592-8d07-ae4781fc3bfd)

## **3. I/O interface**


![IOinterface1](https://github.com/Rex1110/UVM/assets/123956376/f0f258b8-9d48-4869-aab2-ebc85918eeec)

![IOinterface2](https://github.com/Rex1110/UVM/assets/123956376/2d85ca5e-aa98-40e3-9e24-736d5651e637)


## **4. Memory mapping relations**

按照 row 依序對映 memory。

![mmp](https://github.com/Rex1110/UVM/assets/123956376/e8250c14-a90a-414a-9cb4-07633aea9e4f)

## **4. Timing specification**


![wave](https://github.com/Rex1110/UVM/assets/123956376/49d57fc3-97c9-42e2-a6f5-968ae7d72577)


## **5. Design**

以下為系統狀態機

![FSM](https://github.com/Rex1110/UVM/assets/123956376/8d171626-ec78-4f64-8821-e199d99507d0)


### **IDLE state:**
接收到 in_en 訊號進入 READ BAYER PATTERN state。

### **READ BAYER PATTERN state:**
將每個 Bayer pattern 儲存到對應的RGB通道中。所有像素都被處理完後進入 INTERPOLATION state，進行插值計算。

![test](https://github.com/Rex1110/UVM/assets/123956376/3a544589-577f-4066-aa4d-e320868c7e33)

### **INTERPOLATION state:**

根據 Bayer image 規則，我們在插值過程中需處理四種不同的情況，每種情況都涉及兩個顏色通道的內插計算。

1. Even row, even col，需要處理 R channel 和 B channel。
2. Even row, odd col，需要處理 G channel 和 B channel。
3. Odd col, even col，需要處理 R channel 和 G channel。
4. Odd col, odd col，需要處理 R channel 和 B channel。

![row_col](https://github.com/Rex1110/UVM/assets/123956376/9dc6ba10-94e0-47b0-89dd-b806dc6b81a2)

為了判斷圖像中像素的行列的奇偶性，使用了一個計數器和一個1位元的暫存器。這個計數器會逐一對像素進行計數，當它數到與圖像寬度相等的值時會自動歸零。 同時，奇偶暫存器也會翻轉其狀態，這樣我們就可以用它來區分目前處理的是奇數列還是偶數列。 此外，計數器的第0位元被用來確定目前處理的是奇數行還是偶數行。 最終根據奇偶暫存器的狀態和計數器最低位元，選擇適當的顏色通道進行取值，並進行計算以執行插值過程。

在插值的方法我們採取雙線性插值法，根據四種不同的狀態，我們會從相鄰像素的對應顏色通道中取值，然後計算這些值的平均值來估算丟失的顏色信息，以此完成整個插值過程。

![interpolation](https://github.com/Rex1110/UVM/assets/123956376/c9ce401f-3b6d-4481-a3a1-08fe7b27b8ea)


當插值完成後進入 SAVE RGB CHANNEL state。

### **SAVE RGB CHANNEL state:**

將計算結果儲存到對應的顏色通道。 如果目前處理的像素位置不是圖像中的最後一個像素，將返回 INTERPOLATION state，繼續處理下一個像素位置的插值計算。 一旦處理到最後一個像素，將轉換到 DONE state，此時準備進行驗證。

### **DONE state:**


拉起完成訊號進行驗證。


## **6. Verification**


![verification](https://github.com/Rex1110/UVM/assets/123956376/755c3509-eec5-44fc-abe7-ec0e7825fb58)

驗證分為兩個部分，基於 UVM 的隨機生成方法和 direct test。如果今天透過 UVM 隨機產生的圖片存在錯誤，我們會將錯誤的測試數據單獨產生一份資料，然後依靠 direct test 對其進行 debug。 否則，如果在 UVM 隨機產生的環境中進行 debug，可能需要 dump 的檔案會非常大，因為我們不只生成一筆資料，而是很多筆測資。對於這兩種操作方式都非常方便，在 makefile 中，如果我們指定了特定圖片，我們將啟用 direct test，如果今天沒有指定，則直接使用 UVM 進行驗證。除此之外，除了 UVM 所生成的照片可進行測試之外，真實的照片也可以拿來測試。

![verfication_graph](https://github.com/Rex1110/UVM/assets/123956376/8461354b-b844-498b-a9a9-a93cd5c67bff)


### UVM

根據參數 WIDTH_MAX, WIDTH_MIN, HEIGHT_MAX, HEIGHT_MIN 隨機產生一張 Bayer pattern 的照片，此照片符合我們定下的範圍，

- WIDTH_MAX \> image width \> WIDTH_MIN 
- HEIGHT_MAX \> image height \> HEIGHT_MIN

接下來把照片根據 memory mapping 存入模擬的 Bayer memory(在這以 register) 中，之後拉起 in_en 訊號告訴 dut 可以開始工作了。

當 done 訊號拉起時，代表完成插值，我們將 R channel memory, G channel memory, B channel memory，和我們使用的 python 處理的結果來進行比較。
如果出現錯誤直接產出 .png 提供後續 direct test 使用。

### Direct test

在這裡如果指令參數 IMAGE != "" 也就是有指定特定圖像，將啟用 direct test，而除了 UVM 生成的照片，也可以使用實際的照片計算。如果 dut 與 golden 不符，會將每個錯誤的 index, golden 和 dut 的結果輸出到外部 file，根據 index 可以快速在波型中直接定位出錯點。


## **7. Result**

> [!NOTE]
隨機生成 50 組測試案例 \
512 \> image width \> 3 \
256 \> image height \> 3 \
通過占比 50 / 50
>

![result1](https://github.com/Rex1110/UVM/assets/123956376/9865057d-9094-4157-861b-a35db5625005)


![result2](https://github.com/Rex1110/UVM/assets/123956376/ecdeb774-8d9b-4a79-ac39-95eff06d01f3)




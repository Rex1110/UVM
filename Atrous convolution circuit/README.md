## **1. Overview**
![verification](https://github.com/Rex1110/UVM/assets/123956376/58660f76-d6f2-4be3-8181-c70a36817b14)



## **2. Introduction**

Atrous convolution 也被稱為 dilated convolution，是一種擴展了卷積核的卷積方法。在標準卷積中，dilation rate 為 1，這意味著卷積核的元素是連續的，沒有間隔。當 dilation rate 設為 2 時，卷積核的每個元素之間就會有一格的間隔。這樣的設計使得卷積核能夠在不增加參數的情況下擴展其感受野，從而捕捉更大範圍內的輸入特徵，如下圖。

![images](https://github.com/Rex1110/UVM/assets/123956376/7c641af4-eb03-477f-ba5f-542e3247b4e3)


在這個項目中，需要實作一個 Atrous convolution circuit(dilated rate=2)，其中包含兩個 layer。

1. Atrous convolution and Relu
2. Max pooling and round up

layer1 從 image memory 讀取原始 image 資料執行 Atrous convolution (dilated rate=2) 並且需要 edge padding 來保持 output size 與 input size 相同，最後再通過 Relu 存回 layer1 memory，其中 filter 的參數為事先給定。

layer2 將 layer1 memory 的資料讀出，執行 Max-pooling (stride=2, kernel_size=2x2)，將結果小數部分"無條件進位"存回 layer2 memory。


## **3. I/O interface**

![IO0](https://github.com/Rex1110/UVM/assets/123956376/244f1db9-2fb4-42a2-82b0-50a64c855179)

![IO1](https://github.com/Rex1110/UVM/assets/123956376/25f2c7e2-6860-4534-ade7-76d462a37b1b)


idata, cdata_rd, cdata_wr  為一個 9 bit integer(MSB) + 4 bit fractional part(LSB) 所組成定點數。\
整數部分依序為 2<sup>0</sup>, 2<sup>1</sup>, 2<sup>2</sup>, .....\
小數部分依序為 2<sup>-1</sup>, 2<sup>-2</sup>, 2<sup>-3</sup>, ...

## **4. Memory mapping relations**

![mmp](https://github.com/Rex1110/UVM/assets/123956376/49669dba-0f42-4438-a43f-746629ed2e04)

## **5. Timing specification**

![wave](https://github.com/Rex1110/UVM/assets/123956376/dc4382cb-9ff7-4280-8ca7-25fa5501d97a)

## **6. Design**
以下為系統狀態機

![FSM](https://github.com/Rex1110/UVM/assets/123956376/64958885-8b70-4cba-9f02-5c0c3e3b4a84)

### **IDLE state:**
接收到 ready 訊號進入 convolution state。
### **Convolution state:**
讀取 image memory 計算 convolution 後的結果在經過 relu 的操作存回 layer1 memory，以上計算過程需要將原先 1x64x64 的照片 padding 至 1x68x68 使得 convolution 後結果仍為 1x64x64，詳細執行 padding 的動作在下面有提到。當 image 的座標為 (63, 63) 且 filter 座標為 (2, 2) 就代表 Atrous convolution 已經做完了，那麼就進入 Pooling state。
1. **Filter coordinates**
Filter x 座標在每個 cycle 都需要移動，而 filter y 座標則是當 filter x 座標為 2 時 才需要變化，如下圖。


![images](https://github.com/Rex1110/UVM/assets/123956376/38cb7ce1-12da-455e-9894-dec08e9e16b8)


3. **Image coordinates**
Image x 只有在 filter x 和 filter y 都為 2 的時候+1，而 image y 只在 image x 為 63 且 filter x 和 filter y 都為 2 才會+1。


![images](https://github.com/Rex1110/UVM/assets/123956376/67dbceaa-8986-43f9-aabb-bd50a82db4e1)



### **Pooling state && Stride2 state**
Max pooling 階段，讀取 layer1 memory 後執行 Max pooling 的操作，如果 filter 座標為 (1, 1) 進入 Stride2 階段，之所以多 Stride2 階段是因為根據訊號 csel 對於 layer1, layer2 memory 我們只能選一個，當選擇讀取 layer1 memory 後就無法存入 layer2 memory，因此我們多一個 state 來存入結果，順便進行 stride 的動作，此外 convolution state 沒有這個問題是因為我們是讀取 "image memory" 存入 layer1 memory。

![images](https://github.com/Rex1110/UVM/assets/123956376/2227cff2-2a48-4a60-b5a9-3a12572284c2)



### **Image memory address and convolution**
當定義好 image 和 filter 座標軸後我們就可以去 image memory 取資料了。

x = image_x + filter_x

y = image_y + filter_y

image memory address = x + 64 * y

但由於我們圖片需要有 edge padding 的操作，因此根據觀察出現了以下規則

如果 x < 0 則最後 x 設為 0
如果 x > 63則最後 x 設為 63

如果 y < 0 則最後 y 設為 0
如果 y > 63則最後 y 設為 63

如果落在區間內，則保持原本的數值

根據以上規則即可至正確的 image memory 取得資料。

![rule](https://github.com/Rex1110/UVM/assets/123956376/667fdab1-1377-46e8-bfc8-66c827484153)



當我們得到正確的 input data 後，即可和 filter 值進行計算，在這 filter 是預先給訂好的，實作上可以使用拼接的方式完成，將要被計算的值置於 LSB 處，使用完後拼接到 MSB 處。

![images](https://github.com/Rex1110/UVM/assets/123956376/e860fff5-b208-4d7e-abac-694e4cc30c7c)


## **7. Verification**

![verification](https://github.com/Rex1110/UVM/assets/123956376/11da5c7d-a0b1-488b-87ba-dfb4c33a7ba8)



在這個設計中，我們需要產生一個 13bits、深度為 4096(64*64) 的隨機陣列，並將這個陣列傳送到 image memory 中。 之後等待 DUV 完成計算將 layer1 和 layer2 memory 與我們使用 python 所撰寫的 golden 進行比較。

在這次的驗證平台中，如果某張照片出錯了，我們將單獨導出那張照片，以及錯誤的 layer 和錯誤的 memory 位置，用於後續方便 debug。

例如隨機生成5筆測資，這五筆都存在錯誤，因此會導出原本 image data 和錯誤發生的 layer 和 memory address。\
導出型式 image_xx.data 為原始完整資料 image_addr_xx.dat 為錯誤存在位置，如下圖。

![fail1](https://github.com/Rex1110/UVM/assets/123956376/c176c518-5cec-4a7a-a69e-8910525cb298)


image_xx.dat 錯誤照片的完整資訊

![fail2](https://github.com/Rex1110/UVM/assets/123956376/4900e948-43f1-4070-b551-b4f186e21101)


image_addr_xx.dat 錯誤存在的 memory address 

![fail3](https://github.com/Rex1110/UVM/assets/123956376/a69ac5ce-5e9d-4cb0-9794-2314063a1cde)




## **8. Result**
> [!NOTE]
隨機生成 2000 組測試案例 \
通過占比 2000 / 2000


![result1](https://github.com/Rex1110/UVM/assets/123956376/076c60ca-e163-4a76-9a2e-5461f747de52)


![result2](https://github.com/Rex1110/UVM/assets/123956376/3870ad91-a78f-4354-aa79-02ad047efb31)




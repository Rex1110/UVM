# **Rails**

## **1. Overview**
![verification](https://github.com/Rex1110/UVM/assets/123956376/7f61acd3-f331-4878-b362-3e09b3e279fc)





## **2. Introduction**

有一系列的火車，每列火車都有一個唯一的數字標識。\
火車按照一定的順序進入車站，車站是一個後進先出（LIFO）的 stack 結構。\
需要判斷給定的 "departure order" 是否可能。

![Introduction](https://github.com/Rex1110/UVM/assets/123956376/a4783932-2e5d-4825-b502-9be104f8d0a8)




## **3. I/O interface**

![IO interface](https://github.com/Rex1110/UVM/assets/123956376/2e185a90-1aff-4abe-b41d-a30e1fc2dcd7)








## **4. Timing specification**
每筆測資的第一個 data 是 "number of coming trains"，
之後傳送的 data 是 "departure order"，
當拉起「valid」時即檢查「result」是否正確，
下個 cycle 新的測資又發送進來。

![Timing specification](https://github.com/Rex1110/UVM/assets/123956376/b775c2e4-2ee5-40a5-8a52-c1d8b24ff9f9)




## **5. Design**
判斷 "departure order" 是否正常，
直覺的想法就是把 "departure order" 還原回去，
看可不可以變回123...N，
但其實不需要重新排列就可以判斷是否異常，
只有以下兩種情況才能夠還原為原本序列。

1. 當前 data 大於已經出現過的 data。
2. Data 若不是大於已經出現過的 data 則必須為介於已出現中尚未出現的最大值。

例如 \
1, 2, 8 接下來只能是大於8或等於7，大於8符合第一點規則，等於7符合第二點規則。
2, 1, 4, 5, 7 接下來只能是大於7或等於6。
因此我們可以不需要序列發送完畢才得知是否正常，
只要找到上述 counter example 即可給出答案 繼續下輪測資。
## **6. Verification**
### Testcase example

Pattern 1:\
Number of coming trains: 5\
Depature order: 4, 3, 2, 5, 1\
Result: 1

Pattern 2:\
Number of coming trains: 6\
Depature order: 2, 4, 1, 3, 6, 5\
Result: 0

Pattern 3:\
Number of coming trains: 3\
Depature order: 1, 2, 3\
Result: 1

Pattern 4:\
Number of coming trains: 5\
Depature order: 4, 2, 3, 5, 1\
Result: 0

在這我們的 transaction 裡包含一個 data queue，裡面裝著 "number of comming trains" 和 "departure order"，每個 cycle driver 會發送一個 data queue 的資料至 duv，當 duv 拉起 valid 訊號時，透過 virtual interface 把整個 data queue 送至 monitor，
monitor 把資料送至 scoreboard 的同時，也將 "departure order" 寫到外部的 file 用來計算 golden，最後 scoreboatd 完成比較。
![verification](https://github.com/Rex1110/UVM/assets/123956376/95abfb8c-0aa5-4735-9dc2-36213d7dbe59)




### Golden
C++ 撰寫 Golden 作為我們的答案，
程式碼在 golden.cpp，
C++ 的做法是直接將他完整還原，
從 "departure order" 末端開始 pop 到 stack 中，
如果 stack 頂端大於 "departure order" 末端，則 pop stack 到 answer 的頭 ，
當 "departure order" 都 pop 完把剩餘在 stack 的 data 通通 pop 到 answer 的頭即可完成。

![Golden](https://github.com/Rex1110/UVM/assets/123956376/fb51b042-6203-46cf-8699-6d30c6a27d2c)




## **7. Result**
> [!NOTE]
隨機生成 20000 組測試案例 \
通過占比 20000 / 20000  \
Answer 為 CPP 結果 \
Result 為 DUT 結果

![Result1](https://github.com/Rex1110/UVM/assets/123956376/936da0f4-abda-421c-93eb-8cbf08adda02)

![Result2](https://github.com/Rex1110/UVM/assets/123956376/0cdf30c4-4355-46dd-9092-f19e0282f847)







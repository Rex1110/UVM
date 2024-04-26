# Arithmetic Expression Calculator
## **1. Overview**
![verification](https://github.com/Rex1110/UVM/assets/123956376/2c3d5880-2fd3-4f8f-b6e2-7ecc67023c6a)




## **2. Introduction**
這是一個 Arithmetic Expression Calculator（AEC）系統。為了確保計算結果的準確性，需要遵守算術表達式的運算規則。
該系統能夠處理含有數字(0 ~ F)、加（+）、減（-）、乘（\*）、等於（=）符號以及括號的複雜表達式。
以表達式"(3+4)-6\*8="為例，首先計算括號內的加法3+4得到7，然後計算6\*8得到48，最後執行7-48得到-41。



## **3. I/O interface**
![IOinterface](https://github.com/Rex1110/test/assets/123956376/9e1f263c-b543-4443-8c7f-174609dd078a)

> [!NOTE]
輸入是以 ASCII 的形式輸入的，\
運算子介於 0 ~ F 之間\
運算元包含 「 + 」 「 - 」 「 * 」 「 ( 」 「 ) 」 「 = 」\
對應 ASCII 如下圖

![ASCII table](https://github.com/Rex1110/test/assets/123956376/28b197f6-3cb3-40c1-892c-4a253c404dcd)





## **4. Timing specification**
接收到「ready」訊號後，驗證平台將開始輸入 testcase。當發出「=」，就會等待 DUT 完成計算。 DUT計算完畢後，會拉起「finish」訊號，這時會去檢查 result 是否正確。


![Timespec](https://github.com/Rex1110/test/assets/123956376/19afd839-eb0d-4a4b-9ba8-9f8778274725)


## **5. Design**
在設計上由於硬體沒法處理 infix 形式的數字串，我們需要將他轉成 postfix，而這個轉換的過程其實就是要符合四則運算，規則如下。
1. 先乘除後加減(本次實作無除法)
2. 有括號先做
3. 由左向右計算
   
> [!NOTE]
Basic version

在最基本版的設計上使用兩個 queue，一個 stack。

1. 第一個 queue 負責接收每個時脈週期傳入的數字序列。
2. 接收完畢後，分別被送入 stack 和第二個 queue。stack 用來存放運算子，而第二個 queue 用於存放運算元，在這一階段，系統會將 infix 轉換為 postfix。當「 - 」和「 * 」時，按照規則一，將「 * 」移至第二個 queue。「 - 」遇上「 + 」，由於它們優先級相同，根據規則三，將「+」移至第二個 queue。遇到「 ( 」時，將保留在 stack 中，直到遇到「 ) 」為止，此時將持續彈出 stack 中的運算子，直到再次遇到「 ( 」，最後將之消除。當第一個 queue 為空時，將持續從 stack 中彈出運算子，直到 stack 也為空。
3. 將運算元持續推入 stack，遇到運算子時，從 stack 中彈出兩個運算元進行計算，然後將結果存回 stack 中。此過程將一直持續，直到第二個 queue 也為空，也就完成運算了。可參考以下動畫。
   
![basic](https://github.com/Rex1110/test/assets/123956376/923f2284-62c4-4996-9115-319a1fff46da)




> [!NOTE]
Improve version
> 
但這樣的設計上我們發現佔用了太多的 clock cycle 以及占用面積過大(接收轉換都需要保存整串數字序列使得 queue、stack 都至少要為原數字序列長度)，在這我們可以將它改良，我們知道有三個狀態分別是接收、轉換、計算，在原本基礎設計中都是獨立的，每個階段就是專門只做自己的事，如果接收的時候也做轉換，轉換的時候如果可以也順便計算，那其實會省下不少時間以及空間，如下。
![improve](https://github.com/Rex1110/test/assets/123956376/1cfecac9-a50d-49e7-96c6-2399e738a18c)


以上設計把 queue 當成一個緩衝，其功能仍然是接收但在接收同時也會根據需要發送到專門存放運算元的 queue 或是運算子的 stack 中，而在轉換 postfix 時我們也會直接將其計算，這樣的修改對於此 test case 時脈週期減少了一半，佔據到的面積也大幅減少，因此可以處理更長的數字序列以及更加快速。
## **6. Verification**

一個數學式子該長怎樣那肯定是一個數字配上一個等號吧! \
e.g. 7= \
因此我們將這東西延伸下去

1. 在前面加上數字配上運算元 e.g. 1 * 7 = 
2. 在後面加上數字配上運算元 e.g. 7 + 3 =
3. 前後都加上括號 e.g. ( 7 ) =

根據上述規則，我們一開始隨機一個數後再不斷的隨機為它搭配上各種操作，它就像是一個樹狀結構只不過我們只挑選其中一條分枝，至於深度有多深這部分就隨機讓它產生，但這樣生成的方法某些 case 是無法產生的 e.g. ( 1 + 3 ) - ( 5 * 9 ) ，因為我們包括號都是整個包起來，那麼我們就把多顆 tree 拼接起來以上 case 即可產生，組合後的東西稱為 forest。
在這裡我們可以隨機生成樹的深度，樹的數量，以達到更多元的測試資料。
![Tree](https://github.com/Rex1110/test/assets/123956376/a7a9f7e5-edaa-4d47-b678-4c39b14ca8d8)


![Forest](https://github.com/Rex1110/test/assets/123956376/00f703fd-c3c4-4359-bebe-10057cdf0e6d)



### Golden
Golden 用 python 去寫，python 有個 eval() 的 function 它能夠直接算出數學表達式，只需要將 ASCII 轉為數字後執行 eval() 就完成了。

## **7. Result**
> [!NOTE]
樹的數量 5 ~ 10\
樹的深度 1 ~ 7\
隨機生成 20000 組測試案例\
通過占比 20000 / 20000
> 
![Result1](https://github.com/Rex1110/test/assets/123956376/135048d7-3af5-4687-afd2-a2cc8ba43328)

![Result2](https://github.com/Rex1110/test/assets/123956376/f835cdb5-0654-479e-b805-b622b779057d)


> [!NOTE]
樹的數量 20 ~ 25\
樹的深度 1 ~ 7\
隨機生成 200 組測試案例\
通過占比 151 / 200
> 

![Result3](https://github.com/Rex1110/test/assets/123956376/90ec6b62-20b7-4e33-8d5d-dce66fbc7a65)

![Result4](https://github.com/Rex1110/test/assets/123956376/7ee159af-9dba-44d8-8ee7-db5df670deb2)

> [!NOTE]
失敗原因\
以下波形圖為 test case 5 我的緩衝 buffer 只能容納64個，即便能夠邊接收邊計算仍然會有塞滿的時候， 其中 cnt 為我的 buffer 的 pointer 可以看到 cnt 已經超過64了，因此最終計算錯誤。
> 
![Result5](https://github.com/Rex1110/test/assets/123956376/22defdf7-23e7-4df1-88dd-f0e60c018e37)


> [!NOTE]
一個成功的例子 cnt 最大剛好為 64
> 
![Result6](https://github.com/Rex1110/test/assets/123956376/c8889737-e525-4d83-bef7-c0ed3fcf0482)


![Result7](https://github.com/Rex1110/test/assets/123956376/5407f771-71f0-45d8-858f-0472d0fb30b1)

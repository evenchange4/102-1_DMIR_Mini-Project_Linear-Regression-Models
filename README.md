# Mini Project: Linear Regression Models

The `Mini Project` report from NTU102-1 [DMIR](https://ceiba.ntu.edu.tw/course/99b512/index.htm) course

**by NTU [Michael Hsu](http://michaelhsu.tw/ "blog")**

## 如何執行

R cmd:

```
> source("/path_to/main.r")
```

example: （可用拖曳方式取得路徑）

```
> source("/Users/michaelhsu/Dropbox/15.\ 碩一上課業/02.\ DMIR\ 資料探勘與資訊檢索/mini_project/main.r")
```

## Data Pre-process
1. 新增欄位 `index`：原本資料的排序（ = sort by `week_index` and `group` ）。
2. 排序與篩選 `week_index` + `week_return1`： ![Excel 排序依據操作](https://raw.github.com/evenchange4/102-1_DMIR_Hw3_Generative-Classification-Models/master/img/preprocess%201%20sort.PNG)
3. 定義分類標簽：
	- 1. 新增欄位 `index_sort`：根據上一個步驟後的排序。
	- 2. 新增欄位 `index_sort % 30`：`mod(左邊, 30)`
	- 3. 給予分類標籤 `class`：`=IF((左邊>0)*(左邊<=6),"1","0")` 前六個為 1，剩下二十四個為 0。
4. 新增欄位 `random_sort`：最後依據這個欄位 `=RAND()` 來做 10-fold classification。
5. 最後整理資料為 `data/ldpa30_train use.csv`
	- 剩下 feature `alpha`、`beta_mkt`、`beta_hml`、`beta_smb`、`sigma`
	- 分類的標簽 `class`
	- 以及目前的隨機排序依據，作為切割十份用，產生新的 `new_index`。
	- ![pre-processes data format](https://raw.github.com/evenchange4/102-1_DMIR_Hw3_Generative-Classification-Models/master/img/pre-proessed%20data.png)

## Evaluation
- use `/data/ldpa30_train.csv`
	- `week_index`: 1 ~ 370
- Use 10-fold-validation: 將資料切成十份，輪流當 Training data。
- 最後憑藉 `accuracy`、`rmse` 來挑選適當的 Model。

## Model 1: Generative Classification Model
- 執行 source("`generative_classification_model.r`")
- Feature: `alpha`、`beta_mkt`、`beta_hml`、`beta_smb`、`sigma`
- 依據 Hw3 的[Generative Classification Models](https://github.com/evenchange4/102-1_DMIR_Hw3_Generative-Classification-Models)
的結果來看，`Recall` 的結果不是很理想，而且這次 Mini Project
想要的並不是分類的結果，換成以 Linear Regression Model 來試試看。
	- Result: 10-fold-validation 的結果，以及平均。![evaluation result](https://raw.github.com/evenchange4/102-1_DMIR_Hw3_Generative-Classification-Models/master/img/result.png)

## Model 2: Linear Regression Models
- 執行 source("`linear_regression_model.r`")
- Feature1: `alpha`、`beta_mkt`、`beta_hml`、`beta_smb`、`sigma`
- Feature2: `alpha`、`beta_mkt`、`beta_hml`、`beta_smb`、`sigma`、`class`
	- 添加 `class` 的結果希望預期的結果更靠近前幾名的`week_return1`的趨勢。
- Result: 10-fold-validation 的結果，可以發現 Feature2 出來預測的結果比 Feature1 還要好。![rmse evaluation result](https://raw.github.com/evenchange4/102-1_DMIR_Mini-Project_Linear-Regression-Models/master/image/LM-rmse.png)

## Result and Output
- 執行 source("`main.r`")
- 使用 `/data/ldpa30_test_blind.csv` 其中包含 `week_index`: 371 ~ 494。
- 最後挑選 `Model 2: Linear Regression Models`，並且搭配 Feature2 來做最後的預測，並且挑選該 `week_index` 區域中 `week_return1` 值最高者，並輸出最後的格式。
- 最後輸出的檔案為 `result.csv`，如下截圖。
	- ![result.csv](https://raw.github.com/evenchange4/102-1_DMIR_Mini-Project_Linear-Regression-Models/master/image/result_csv.PNG)

## Source code

[https://github.com/evenchange4/102-1_DMIR_Mini-Project_Linear-Regression-Models](https://github.com/evenchange4/102-1_DMIR_Mini-Project_Linear-Regression-Models)

## Reference
- [Linear Least Squares Regression](http://www.cyclismo.org/tutorial/R/linearLeastSquares.html)
- [Generalized linear models in R](http://plantecology.syr.edu/fridley/bio793/glm.html)
- [11.6.2 glm()函數](http://www.biosino.org/pages/newhtm/r/tchtml/The-glm_0028_0029-function.html)
- [Generative Classification Models](https://github.com/evenchange4/102-1_DMIR_Hw3_Generative-Classification-Models)
- [How to Write CSV in R](http://rprogramming.net/write-csv-in-r/)
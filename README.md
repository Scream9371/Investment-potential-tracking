# Investment-potential-tracking

### 1. Usage

Download the project folder to your local machine, navigate to the project root directory, and enter `run` in the MATLAB command window to obtain results.
The final outputs are stored in the following two variables:

- `cum_wealth`: T × 1 Double — cumulative wealth series
- `b_history`: N × T Double — portfolio weight matrix

### 2. Dataset

The datasets used by the project are stored in the `Data Set` directory.

| Datasets | Region | Time span             | Period | Number of stock |
| -------- | ------ | --------------------- | ------ | --------------- |
| DJIA     | US     | 2001.01.14-2003.01.14 | 507    | 30              |
| NYSE(O)  | US     | 1962.07.03-1984.12.31 | 5651   | 36              |
| NYSE(N)  | US     | 1985.01.01-2010.06.30 | 6431   | 23              |
| TSE      | CA     | 1994.01.04-1998.12.31 | 1259   | 88              |
| MSCI     | US     | 2006.04.01-2010.03.31 | 1043   | 24              |

> [!NOTE]
> You can change the dataset in `run.m` by modifying `load('Data Set\djia.mat');`
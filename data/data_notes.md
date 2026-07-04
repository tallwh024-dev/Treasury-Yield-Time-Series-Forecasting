# Data

This project uses public U.S. Treasury yield data from FRED.

Series used:

- GS1: 1-Year Treasury Constant Maturity Rate
- GS2: 2-Year Treasury Constant Maturity Rate
- GS3: 3-Year Treasury Constant Maturity Rate
- GS5: 5-Year Treasury Constant Maturity Rate

The scripts download the data directly using quantmod::getSymbols().

The local RData file is not included because the dataset can be reproduced from FRED.

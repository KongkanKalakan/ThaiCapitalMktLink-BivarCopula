# ThaiCapitalMktLink-BivarCopula

This is the original implementation in the following paper ⚡️ : [Analysis of Thai Capital Market Linkages: Part I. Bivariate Copula Approach](https://www.researchgate.net/publication/362544586_Analysis_of_Thai_Capital_Market_Linkages_Part_I_Bivariate_Copula_Approach). I hope these codes are helpful to you, 🌟!

## Abstract

Analytically thorough understanding of financial-market dynamics is fundamental to the promotion of capital-market innovation, efficiency, and resilience; innovative, efficient, and resilient capital market, in turn, is fundamental to the sustainable economic development of the nation and the robust financial stability of its economy. This paper uses Bivariate Copula (semi-parametric statistics) techniques to analyse probabilistic co-movement amongst 14 variables representing domestic (Thai) and international (US/Emerging Market/Asia) foreign-exchange, fixed-income, and equity market movements, as well as foreign portfolio-investment flows into Thai equity shares and bonds. In addition, by staggering paired time-series w/ time lag on one of the pairs, the resulting copula relationship is suggestive of information flow, similar in spirit to testing for Granger Causality. The methodology pipeline thus developed can be applied to any other time-series pairings of interest, not just those related to Thai financial markets.

## Requirements

- R
    - readxl (or tidyverse)
    - data.table
    - [VineCopula](https://cran.r-project.org/web/packages/VineCopula/index.html)
- python
    - pandas
    - numpy
    - matplotlib

## How to Run

```bash
git clone https://github.com/KongkanKalakan/ThaiCapitalMktLink-BivarCopula.git
cd ThaiCapitalMktLink-BivarCopula/src
mkdir -p data/raw result
```
Download `retnTimeSeries.csv` to `data/raw`

Change config at `config.R` here

```
# Input data
INPUT_PATH<-"./data/raw/retnTimeSeries.csv"
COL_LAG_PATH<-"./result/PairWiseCopula_collag.csv"
ROW_LAG_PATH<-"./result/PairWiseCopula_rowlag.csv"
NO_LAG_PATH<-"./result/PairWiseCopula.csv"

INPUT_DATE <- c("2009-01-07", "2021-12-31")

# Family List 
# unrestricted:c(1:10,13,14,16:20,23,24,26:30,33,34,36:40)
family_list <- c(1:5,13,14,23,24,33,34)
```

Run `BivarCopulaSelect.R` to find best bivariate copula

Visualization using `reportBicopula.ipynb`

## Results

<p align="center">
  <img width="850" height="500" src=./figs/90-Significant-Copula-Parameters-for-1D-row-lagged-pairings-rowt-1-vs-colt-top.png>
</p>

90%-Significant Copula/Parameters for '1D-row-lagged' pairings row(t-1) vs. col(t) [top], 'no-lag' pairings row(t) vs. col(t) [middle], and '1D-col-lagged' pairings row(t) vs. col(t-1) [bottom]

<p align="center">
  <img width="600" height="600" src=./figs/Arrows-representing-Copula-Significance-at-90-vis-a-vis-1D-row-lagged-pairings.png>
</p>

"Arrows" representing Copula Significance at 90% vis-à-vis '1D-row-lagged' pairings row(t-1) vs. col(t) [top], 'no-lag' pairings row(t) vs. col(t) [middle], and '1D-col-lagged' pairings row(t) vs. col(t-1) [bottom]

## Cite (Bibtex)
If you make use of this code in your own work, please cite our paper:
 ```latex
@article{ThaiCapitalMktLinkPart1,
    author = {Nacaskul, Poomjai and Khlaisamniang, Pitikorn and Sukcharoenchaikul, Isariyaporn},
    year = {2022},
    month = {08},
    pages = {},
    title = {Analysis of Thai Capital Market Linkages: Part I. Bivariate Copula Approach}
}
```
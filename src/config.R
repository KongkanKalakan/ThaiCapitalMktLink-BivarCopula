# Input data
INPUT_PATH<-"./data/raw/retnTimeSeries.csv"
COL_LAG_PATH<-"./result/PairWiseCopula_collag.csv"
ROW_LAG_PATH<-"./result/PairWiseCopula_rowlag.csv"
NO_LAG_PATH<-"./result/PairWiseCopula.csv"

INPUT_DATE <- c("2009-01-07", "2021-12-31")

# Family List 
# unrestricted:c(1:10,13,14,16:20,23,24,26:30,33,34,36:40)
family_list <- c(1:5,13,14,23,24,33,34)
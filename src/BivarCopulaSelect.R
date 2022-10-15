library(VineCopula)
library(data.table)
library(readxl)
source("config.R")

readFile<- function(PATH){
  data <- read.csv(PATH)
  # Remove NA
  data <- data[complete.cases(data),]
  data
}

uniformiseRandomVariate<- function(data, index_col = "Date"){
  index_data <- data[index_col]
  # uData <- data.frame(apply(data[,c(-1)], MARGIN=2, FUN=pobs)) 
  uData <- data[ , !(names(data) %in% c(index_col))]
  uData <- data.frame(apply(uData, 2, function(c) ecdf(c)(c)))
  uniformData <- cbind(index_data,uData)
  uniformData
}


fitBiCopula <- function(data, start_index, end_index, goftest=FALSE, rowlag=NULL, collag=NULL, index_col="Date", index_date=TRUE, family_list = c(1:5,13,14,23,24,33,34)){

  # This function fit bivariate copula
  # Parameters
  # ----------
  # data: Input data
  # start_index: start index
  # end_index: end index
  # goftest: True=run gof test
  # rowlag: number of day lag by row
  # collag: number of day lag by column
  
  Cop <- c()
  AIC <- c()
  BIC <- c()
  emptau <- c()
  p_indep <- c()
  family <- c()
  par <- c()
  par2 <- c()
  familyname <- c()
  tau <- c()
  beta <- c()
  col1 <- c()
  col2 <- c()
  
  #GoF
  p_value<-c()
  stat<-c()
  p_valueCvM<-c()
  p_valueKS<-c()
  statCvM<-c()
  statKS<-c()
    
  if (index_date==TRUE){
    start_index<-as.Date(start_index)
    end_index<-as.Date(end_index)
    data[index_col] <- as.Date(data[[index_col]])
    data<-data[(data[[index_col]] >= start_index) & (data[[index_col]] <= end_index),]
  } else {
    data<-data[(data[index_col] >= start_index) & (data[index_col] <= end_index),]
  }
    
  data <- uniformiseRandomVariate(data, index_col)
  data <- data[ , !(names(data) %in% c(index_col))]
  pair<-combn(colnames(data),2)
  num_pair <- dim(pair)[2]
  
  for (i in c(1:num_pair)){
    v1<-pair[1,i]
    v2<-pair[2,i]
    if (!is.null(rowlag) & !is.null(collag)){
      print(paste("Error occurs in collag/rowlag argument"))
      break
      
    }else if (!is.null(rowlag)){
      
      df_temp <- data[, c(v1, v2)]
      df_temp[v2] <- shift(df_temp[v2], rowlag)
      df_temp <- tail(df_temp, -rowlag)
      df_temp <- na.omit(df_temp)
      
      u1 <- df_temp[[v1]]
      u2 <- df_temp[[v2]]
      
    }else if (is.null(rowlag) & is.null(collag)){
      
      df_temp <- data[, c(v1, v2)]
      df_temp <- na.omit(df_temp)
      
      u1 <- df_temp[[v1]]
      u2 <- df_temp[[v2]]
      
    }else if (!is.null(collag)){
      
      df_temp <- data[, c(v1, v2)]
      df_temp[v1] <- shift(df_temp[v1], collag)
      df_temp <- tail(df_temp, -collag)
      df_temp <- na.omit(df_temp)
      
      u1 <- df_temp[[v1]]
      u2 <- df_temp[[v2]]
      
    }
    set.seed(1234)
    PwCop<-BiCopSelect(u1, u2, family = family_list
                       ,selectioncrit = "BIC", indeptest=FALSE, rotations = TRUE, method = "mle")
    col1<-c(col1,v1)
    col2<-c(col2,v2) 
    AIC<-c(AIC, PwCop$AIC)
    BIC<-c(BIC, PwCop$BIC)
    emptau<-c(emptau, PwCop$emptau)
    p_indep<-c(p_indep, PwCop$p.value.indeptest)
    family<-c(family,PwCop$family)
    par<-c(par,PwCop$par)
    par2<-c(par2,PwCop$par2)
    familyname<-c(familyname,PwCop$familyname)
    tau<-c(tau,PwCop$tau)
    beta<-c(beta,PwCop$beta)
    
    if (goftest==TRUE){
      if (any(PwCop$family==c(2,104,114,124,134,204,214,224,234))){
        set.seed(1234)
        gof<- BiCopGofTest( u1, u2, family=PwCop$family, par=PwCop$par, par2=PwCop$par2, method = "white")
        p_value<-append(p_value, gof$p.value)
        stat<-append(stat, gof$statistic)
        p_valueCvM<-append(p_valueCvM,'NA')
        p_valueKS<-append(p_valueKS,'NA')
        statCvM<-append(statCvM,'NA')
        statKS<-append(statKS,'NA')
      }
      else if (any(PwCop$family==c(7:10,17:20,27:30,37:40))){
        set.seed(1234)
        gof<- BiCopGofTest( u1, u2, family=PwCop$family, par=PwCop$par, par2=PwCop$par2, method = "kendall")
        p_valueCvM<-append(p_valueCvM,gof$p.value.CvM)
        p_valueKS<-append(p_valueKS,gof$p.value.KS)
        statCvM<-append(statCvM,gof$statistic.CvM)
        statKS<-append(statKS,gof$statistic.KS)
        p_value<-append(p_value,'NA')
        stat<-append(stat,'NA')
      }
      else{
        set.seed(1234)
        gof<- BiCopGofTest( u1, u2, family=PwCop$family, par=PwCop$par,method = "kendall")
        p_valueCvM<-append(p_valueCvM,gof$p.value.CvM)
        p_valueKS<-append(p_valueKS,gof$p.value.KS)
        statCvM<-append(statCvM,gof$statistic.CvM)
        statKS<-append(statKS,gof$statistic.KS)
        p_value<-append(p_value,'NA')
        stat<-append(stat,'NA')
      }
    }
  }
  if (!is.null(rowlag)){
    Cop<-data.frame(ColVariable=col1,RowLagVariable=col2,CopulaBest=familyname,
                    CopulaBestPvalueIndep=p_indep, CopulaBestAIC=AIC,
                    CopulaBestBIC=BIC, CopulaBestParam1=par, CopulaBestParam2=par2)
  }else if (is.null(rowlag) & is.null(collag)){
    Cop<-data.frame(ColVariable=col1,RowVariable=col2,CopulaBest=familyname,
                    CopulaBestPvalueIndep=p_indep, CopulaBestAIC=AIC,
                    CopulaBestBIC=BIC, CopulaBestParam1=par, CopulaBestParam2=par2)
  }else if (!is.null(collag)){
    Cop<-data.frame(ColLagVariable=col1,RowVariable=col2,CopulaBest=familyname,
                    CopulaBestPvalueIndep=p_indep, CopulaBestAIC=AIC,
                    CopulaBestBIC=BIC, CopulaBestParam1=par, CopulaBestParam2=par2)
  }
  
  if(goftest==TRUE){
    add<-data.frame(CopulaBestPvalueCvM=p_valueCvM, CopulaBestPvalue=p_value)
    Cop<-cbind(Cop,add)
  }
  Cop
}

## Main

input_data <- readFile(INPUT_PATH)

gofrowlag<-fitBiCopula(input_data, start_index=INPUT_DATE[1], end_index=INPUT_DATE[2], goftest = TRUE, family_list=family_list, rowlag = 1)
gofcollag<-fitBiCopula(input_data, start_index=INPUT_DATE[1], end_index=INPUT_DATE[2], goftest = TRUE, family_list=family_list, collag = 1)
gofnolag<-fitBiCopula(input_data, start_index=INPUT_DATE[1], end_index=INPUT_DATE[2], goftest = TRUE, family_list=family_list)

write.csv(gofrowlag, ROW_LAG_PATH, row.names=FALSE)
write.csv(gofcollag, COL_LAG_PATH, row.names=FALSE)
write.csv(gofnolag, NO_LAG_PATH, row.names=FALSE)

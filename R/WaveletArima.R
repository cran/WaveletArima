#=====================================================================================#
# PURPOSE : Application 0f Wavelet-ARIMA hybrid model for forecasting time series     #
# AUTHOR  : Ranjit Kumar Paul and Sandipan Samanta                                    #
# DATE    : 06 June, 2018                                                          #
# VERSION : Ver 0.1.1                                                                 #
#=====================================================================================#

#---------------------------------------------------------------------------------------#
# Computing Wavelet Coefficients using MODWT algorithm using haar filter                #
#---------------------------------------------------------------------------------------#

WaveletFitting <- function(ts,Wvlevels,bndry,FFlag)
{
  mraout <- wavelets::modwt(ts, filter='haar', n.levels=Wvlevels,boundary=bndry, fast=FFlag)
  WaveletSeries <- cbind(do.call(cbind,mraout@W),mraout@V[[Wvlevels]])
  return(list(WaveletSeries=WaveletSeries,WVSeries=mraout))
}

WaveletFittingarma<- function(ts,Waveletlevels,boundary,FastFlag,MaxARParam,MaxMAParam,NForecast)

{
  WS <- WaveletFitting(ts=ts,Wvlevels=Waveletlevels,bndry=boundary,FFlag=FastFlag)$WaveletSeries
  AllWaveletForecast <- NULL;AllWaveletPrediction <- NULL
  #-----------------------------------------------------------#
  # Fitting of ARIMA model to the Wavelet Coef                #
  #-----------------------------------------------------------#
  for(WVLevel in 1:ncol(WS))
  {
    ts <- NULL
    ts <- WS[,WVLevel]
    WaveletARMAFit <- forecast::auto.arima(x=as.ts(ts), d=NA, D=NA, max.p=MaxARParam, max.q=MaxMAParam,stationary=FALSE,
                                           seasonal=FALSE,ic=c("aic"), allowdrift=FALSE, allowmean=TRUE,stepwise = TRUE)
    WaveletARIMAPredict <- WaveletARMAFit$fitted
    WaveletARIMAForecast <- forecast::forecast(WaveletARMAFit,h=NForecast)
    AllWaveletPrediction <- cbind(AllWaveletPrediction,WaveletARIMAPredict)
    AllWaveletForecast <- cbind(AllWaveletForecast,as.matrix(WaveletARIMAForecast$mean))
  }
  Finalforecast <- rowSums(AllWaveletForecast,na.rm = T)
  FinalPrediction <- rowSums(AllWaveletPrediction,na.rm = T)
  return(list(Finalforecast=Finalforecast,FinalPrediction=FinalPrediction))
}

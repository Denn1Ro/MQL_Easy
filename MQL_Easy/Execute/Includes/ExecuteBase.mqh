//+------------------------------------------------------------------+
//|                                                  ExecuteBase.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "../../Utilities/Utilities.mqh"
#include "../../Error/Error.mqh"
#include "../../ValidationCheck/ValidationCheck.mqh"

enum ENUM_TYPE_POSITION
{
   TYPE_POSITION_BUY = 0,
   TYPE_POSITION_SELL = 1 
};

enum ENUM_TYPE_ORDER
{
   TYPE_ORDER_BUYLIMIT = 2,
   TYPE_ORDER_SELLLIMIT = 3, 
   TYPE_ORDER_BUYSTOP = 4,
   TYPE_ORDER_SELLSTOP = 5
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CExecuteBase
  {
protected:
   string            Symbol;
   long              MagicNumber;
   bool              Validation(ENUM_SLTP_TYPE sltpPar,ENUM_ORDER_TYPE typePar,double pricePar,double stopLossPar, double takeProfitPar,
                                 double  &stoplossTemp, double &takeprofitTemp,double volumePar,datetime expirationPar);                                    
   
public:  
                     CExecuteBase(string symbolPar = NULL, long magicNumberPar = 12345);
                    ~CExecuteBase();
   CError            Error;
   void              SetSymbol(string symbolPar){this.Symbol = symbolPar;}
   string            GetSymbol(){return this.Symbol;}
   void              SetMagicNumber(long magicNumberPar){this.MagicNumber = magicNumberPar;}  
   long              GetMagicNumber(){return this.MagicNumber;}
   virtual long      Position(ENUM_TYPE_POSITION positionTypePar,double volumePar,double stopLossPar = 0,double takeProfitPar = 0,ENUM_SLTP_TYPE sltpPar = 0,
                              int deviationPar = 10,string commentPar = NULL){return -1;}
   virtual long      Order(ENUM_TYPE_ORDER orderTypePar,double volumePar, double openPricePar, double stopLossPar = 0, double takeProfitPar = 0, 
                              ENUM_SLTP_TYPE sltpPar = 0, datetime expirationPar = 0,int deviationPar = 10, string commentPar = NULL){return -1;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExecuteBase::CExecuteBase(string symbolPar = NULL, long magicNumberPar = 12345)
{
   this.SetSymbol((symbolPar == NULL) ? _Symbol : symbolPar);
   this.SetMagicNumber(magicNumberPar);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExecuteBase::~CExecuteBase()
  {
  }
//+------------------------------------------------------------------+
 
//+------------------------------------------------------------------+
//|    validates the parameters of order/position
//+------------------------------------------------------------------+
bool CExecuteBase::Validation(ENUM_SLTP_TYPE sltpPar,ENUM_ORDER_TYPE typePar,double pricePar,double stopLossPar, double takeProfitPar,
                                 double  &stoplossTemp, double &takeprofitTemp,double volumePar,datetime expirationPar)
{
   //-- check symbol
   CUtilities utilsTemp;
   if(!utilsTemp.SetSymbol(this.Symbol)){this.Error.Copy(utilsTemp.Error);return false;}
   //-- SLTP Convert
   if(!utilsTemp.SltpConvert(sltpPar,typePar, pricePar, stopLossPar, takeProfitPar, stoplossTemp, takeprofitTemp)){this.Error.Copy(utilsTemp.Error);return false;}
   //-- Validations
   CValidationCheck validationCheck;   
   if(!validationCheck.CheckVolumeValue(this.Symbol,volumePar)){this.Error.Copy(validationCheck.Error);return false;}
   #ifdef __MQL5__
      //-- MT4 doesn't support it
      if(!validationCheck.CheckMaxVolume(this.Symbol,typePar,volumePar)){this.Error.Copy(validationCheck.Error);return false;}
   #endif
   if(!validationCheck.CheckStopLossTakeprofit(this.Symbol,typePar,pricePar,stoplossTemp,takeprofitTemp)){this.Error.Copy(validationCheck.Error);return false;}
   
   //-- Validation Checks for active orders
   if(typePar == ORDER_TYPE_BUY || typePar == ORDER_TYPE_SELL){
      //-- Extra Validations Only for active orders
      if(!validationCheck.CheckMoneyForTrade(this.Symbol,volumePar,typePar)){this.Error.Copy(validationCheck.Error);return false;}
   }else{
      //-- Extra Validations Only for pending orders
      //-- expiration paratemer check
      if(expirationPar != 0 && expirationPar <= TimeCurrent()){
         string msgTemp = "The expiration parameter must be greater than "+(string)TimeCurrent();
         this.Error.CreateErrorCustom(msgTemp,false,false,__FUNCTION__);
         return false;
      }
      //-- Validations
      if(!validationCheck.CheckMaxNumberPendingOrders()){this.Error.Copy(validationCheck.Error);return false;}
      if(!validationCheck.CheckPendingFreezeLevel(this.Symbol,typePar,pricePar)){this.Error.Copy(validationCheck.Error);return false;}
   }

  return true;   
}



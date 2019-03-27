//+------------------------------------------------------------------+
//|                                           ValidationCheckMT5.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "ValidationCheckBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CValidationCheck : public CValidationCheckBase
  {
private:

public:
   virtual bool               CheckMoneyForTrade(string symbolPar,double volumePar,ENUM_ORDER_TYPE typePar);    
   virtual bool               CheckStopLossTakeprofit(string symbolPar,ENUM_ORDER_TYPE typePar, double openPricePar,double stopLossPar,double takeProfitPar);
   virtual bool               CheckPendingFreezeLevel(string symbolPar, int typePar, double openPricePar);
   virtual bool               CheckModifyLevels(long ticketPar,double pricePar, double stopLossPar,double takeProfitPar,int typePar = 0);
   virtual bool               CheckMaxNumberPendingOrders();
   virtual bool               CheckMaxVolume(string symbolPar, ulong typePar, double volumePar);
   virtual bool               CheckFillingType(string symbolPar,int fillingTypePar);
                              CValidationCheck();
                             ~CValidationCheck();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CValidationCheck::CValidationCheck()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CValidationCheck::~CValidationCheck()
  {
  }
//+------------------------------------------------------------------+


  
//+------------------------------------------------------------------+
//|                     CheckMoneyForTrade                           |
//+------------------------------------------------------------------+
bool CValidationCheck::CheckMoneyForTrade(string symbolPar,double volumePar,ENUM_ORDER_TYPE typePar)
  {
   //--- Open Price
   double openPriceTemp = SymbolInfoDouble(symbolPar,SYMBOL_ASK);
   if(typePar == ORDER_TYPE_SELL)openPriceTemp = SymbolInfoDouble(symbolPar,SYMBOL_BID);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return false;
   //--- Free Margin
   double freeMarginTemp=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   //--- Calculate Margin to open the order
   double marginTemp;
   if(!OrderCalcMargin(typePar,symbolPar,volumePar,openPriceTemp,marginTemp))
     {
      //--- something went wrong, report and return false
      string msgTemp = "Error in OrderCalcMargin function !";
      return this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
     }
   //--- if there are insufficient funds to perform the operation
   if(marginTemp>freeMarginTemp)
     {
      //--- report the error and return false
      string oper=(typePar==ORDER_TYPE_BUY)? "Buy":"Sell";
      string msgTemp = "Your account size has NOT enough money for "+(string)oper+" at "+symbolPar+" with volume "+(string)volumePar
                     +". Your account free margin is "+(string)freeMarginTemp+" and you need "+(string)marginTemp+"\n";
      msgTemp       += "Either reduce the volume or increase your account size.";
      return this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
     }
   return(true);
  }

  
  
//+------------------------------------------------------------------+
//|                  Check StopLoss TakeProfit                       |
//+------------------------------------------------------------------+  
bool CValidationCheck::CheckStopLossTakeprofit(string symbolPar,ENUM_ORDER_TYPE typePar, double openPricePar,double stopLossPar,double takeProfitPar)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(symbolPar,SYMBOL_TRADE_STOPS_LEVEL);
//---
   bool slCheck=false,tpCheck=false;
   MqlTick tickTemp;
   SymbolInfoTick(symbolPar,tickTemp);
   string msgTemp    = "";
   double pointTemp  = SymbolInfoDouble(symbolPar,SYMBOL_POINT);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return false;
   //--  
   switch(typePar)
     {
      //--- ORDER_TYPE_BUY operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         double bidTemp = tickTemp.bid;
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck = (bidTemp - stopLossPar > stops_level*pointTemp);
         else slCheck = true; 
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be less than "+(string)(bidTemp - stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck = (takeProfitPar - bidTemp > stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be greater than "+(string)(bidTemp + stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return (tpCheck&&slCheck);
        }
      //--- ORDER_TYPE_SELL operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         double askTemp = tickTemp.ask;
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck= (stopLossPar - askTemp > stops_level*pointTemp);
         else slCheck = true;
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be greater than "+(string)(askTemp + stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck= (askTemp - takeProfitPar > stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be less than "+(string)(askTemp - stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return(tpCheck&&slCheck);
        }
      //--- ORDER_TYPE_BUY_LIMIT operation
      case  ORDER_TYPE_BUY_LIMIT:
        {
         //--- check the StopLoss
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck=(openPricePar-stopLossPar>stops_level*pointTemp);
         else slCheck = true;
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be less than "+(string)(openPricePar-stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck=(takeProfitPar-openPricePar>stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be greater than "+(string)(openPricePar+stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return(slCheck&&tpCheck);
        }
      //--- ORDER_TYPE_SELL_LIMIT operation
      case  ORDER_TYPE_SELL_LIMIT:
        {
         //--- check the StopLoss
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck=(stopLossPar-openPricePar>stops_level*pointTemp);
         else slCheck = true;
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be greater than "+(string)(openPricePar+stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck=(openPricePar-takeProfitPar>stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be less than "+(string)(openPricePar-stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return(tpCheck&&slCheck);
        }
        
      //--- ORDER_TYPE_BUY_STOP operation
      case  ORDER_TYPE_BUY_STOP:
        {
         //--- check the StopLoss
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck=(openPricePar-stopLossPar>stops_level*pointTemp);
         else slCheck = true;
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be less than "+(string)(openPricePar-stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck=(takeProfitPar-openPricePar>stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be greater than "+(string)(openPricePar+stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return(slCheck&&tpCheck);
        }
      //--- ORDER_TYPE_SELL_STOP operation
      case  ORDER_TYPE_SELL_STOP:
        {
         //--- check the StopLoss
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck=(stopLossPar-openPricePar>stops_level*pointTemp);
         else slCheck = true;
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be greater than "+(string)(openPricePar+stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck=(openPricePar-takeProfitPar>stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be less than "+(string)(openPricePar-stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return(tpCheck&&slCheck);
        }
     }
   return false;
  }
  
  
  
//+------------------------------------------------------------------+
//|                  Check Pending Freeze Level                      |
//+------------------------------------------------------------------+  
bool CValidationCheck::CheckPendingFreezeLevel(string symbolPar, int typePar, double openPricePar)
  {
   //--
   int freezeLevel = (int)SymbolInfoInteger(symbolPar,SYMBOL_TRADE_FREEZE_LEVEL); 
   int stops_level = (int)SymbolInfoInteger(symbolPar,SYMBOL_TRADE_STOPS_LEVEL);
   freezeLevel     = MathMax(freezeLevel,stops_level);
   bool checkTemp;
   MqlTick tickTemp;
   SymbolInfoTick(symbolPar,tickTemp);
   double pointTemp = SymbolInfoDouble(symbolPar,SYMBOL_POINT);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return false;
   //--- check the order type
   switch(typePar)
     {
      //--- BuyLimit pending order
      case  ORDER_TYPE_BUY_LIMIT:
      {
         //--- check the distance from the opening price to the activation price
         checkTemp=((tickTemp.ask-openPricePar)>freezeLevel*pointTemp);
         if(!checkTemp){
            string msgTemp = "Order "+EnumToString((ENUM_ORDER_TYPE)typePar)+" cannot be executed. The distance between open price and market price "+
                             "must be greater than "+(string)freezeLevel+" and the open price for Buy Limit must be below the current price.";
            return this.Error.CreateErrorCustom(msgTemp);
         }
         break;
      }
      //--- SellLimit pending order
      case  ORDER_TYPE_SELL_LIMIT:
      {
         //--- check the distance from the opening price to the activation price
         checkTemp=((openPricePar-tickTemp.bid)>freezeLevel*pointTemp);
         if(!checkTemp){                        
            string msgTemp = "Order "+EnumToString((ENUM_ORDER_TYPE)typePar)+" cannot be executed. The distance between open price and market price "+
                             "must be greater than "+(string)freezeLevel+" and the open price for Sell Limit must be below the current price.";
            return this.Error.CreateErrorCustom(msgTemp);
         }
         break;
      }
      //--- BuyStop pending order
      case  ORDER_TYPE_BUY_STOP:
      {
         //--- check the distance from the opening price to the activation price
         checkTemp=((openPricePar-tickTemp.ask)>freezeLevel*pointTemp);
         if(!checkTemp){
            string msgTemp = "Order "+EnumToString((ENUM_ORDER_TYPE)typePar)+" cannot be executed. The distance between open price and market price "+
                             "must be greater than "+(string)freezeLevel+" and the open price for Buy Stop must be above the current price.";
            return this.Error.CreateErrorCustom(msgTemp);
         }
         break;
      }
      //--- SellStop pending order
      case  ORDER_TYPE_SELL_STOP:
      {
         //--- check the distance from the opening price to the activation price
         checkTemp=((tickTemp.bid-openPricePar)>freezeLevel*pointTemp);
         if(!checkTemp){
            string msgTemp = "Order "+EnumToString((ENUM_ORDER_TYPE)typePar)+" cannot be executed. The distance between open price and market price "+
                             "must be greater than "+(string)freezeLevel+" and the open price for Sell Stop must be below the current price.";
            return this.Error.CreateErrorCustom(msgTemp);
         }
         break;
      }
     }
     return true;
}



//+------------------------------------------------------------------+
//|                     Check Modify Levels                          |
//+------------------------------------------------------------------+ 
bool CValidationCheck::CheckModifyLevels(long ticketPar,double pricePar,double stopLossPar,double takeProfitPar,int typePar = 0)
{
   bool selectionTemp = (typePar == 0) ? PositionSelectByTicket(ticketPar) : OrderSelect(ticketPar);
//--- select order by ticket
   if(selectionTemp){
      //-- levels and properties of order
      double stopLossTemp     = (typePar == 0) ? PositionGetDouble(POSITION_SL)         : OrderGetDouble(ORDER_SL);
      double takeProfitTemp   = (typePar == 0) ? PositionGetDouble(POSITION_TP)         : OrderGetDouble(ORDER_TP);
      double openPriceTemp    = (typePar == 0) ? PositionGetDouble(POSITION_PRICE_OPEN) : OrderGetDouble(ORDER_PRICE_OPEN);
      string symbolTemp       = (typePar == 0) ? PositionGetString(POSITION_SYMBOL)     : OrderGetString(ORDER_SYMBOL);   
      ulong typeTemp          = (typePar == 0) ? PositionGetInteger(POSITION_TYPE)      : OrderGetInteger(ORDER_TYPE);   
      //--- point size and name of the symbol, for which a pending order was placed
      double pointTemp        = SymbolInfoDouble(symbolTemp,SYMBOL_POINT);
      //--- check if there are changes in the Open price
      bool priceOpenChanged   = false;      
      if(!(typeTemp == ORDER_TYPE_BUY || typeTemp == ORDER_TYPE_SELL)){
         priceOpenChanged = (MathAbs(openPriceTemp - pricePar) > pointTemp);
      }
      //--- check if there are changes in the StopLoss level
      bool stopLossChanged    = (MathAbs(stopLossTemp - stopLossPar) > pointTemp);
      //--- check if there are changes in the Takeprofit level
      bool takeProfitChanged  = (MathAbs(takeProfitTemp - takeProfitPar) > pointTemp);      
      //--- if there are any changes in levels
      if(priceOpenChanged || stopLossChanged || takeProfitChanged){
         return(true);  // order can be modified      
      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      }else{
         return false;
      }      
   }else{
      string msgTemp = "The order #"+(string)+ticketPar+" was NOT selected";
      return this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
   }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying 
}


//+------------------------------------------------------------------+
//|                  checkMaxNumberPendingOrders                     |
//+------------------------------------------------------------------+
bool CValidationCheck::CheckMaxNumberPendingOrders()
{
   //-- Number of maximum pending orders
   int maxAllowedOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   //-- If it is 0 then the account has no restriction for maximum pending orders
   if(maxAllowedOrders == 0) return(true);
   int ordersTemp = OrdersTotal();   
   bool allowTemp = ordersTemp < maxAllowedOrders;   
   if(!allowTemp){
      string msgTemp = "You are NOT allowed to place orders more than "+(string)maxAllowedOrders;
      return this.Error.CreateErrorCustom(msgTemp);
   }
   return(allowTemp);
}


//+------------------------------------------------------------------+
//|                     checkMaxVolume                               |
//+------------------------------------------------------------------+
bool CValidationCheck::CheckMaxVolume(string symbolPar, ulong typePar, double volumePar)
{
   //-- Maximum Volume on that symbol
   double maxVolumeTemp = SymbolInfoDouble(symbolPar,SYMBOL_VOLUME_LIMIT);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return false;
   //-- If it is 0 then there is no restriction for Maximum Volume
   if(maxVolumeTemp == 0)return true;
   //-- Type of order
   string directionTemp = (typePar == 0 || typePar == 2 || typePar == 4) ? "buy" : "sell";
   //--
   double sumVolumes = 0;
   //-- Positions
   int totalPositions = PositionsTotal();
   for(int i = 0; i < totalPositions; i++){
      ulong ticketTemp = PositionGetTicket(i);
      if(ticketTemp > 0){
         if(PositionGetString(POSITION_SYMBOL) == symbolPar){
            if(directionTemp == "buy" && PositionGetInteger(POSITION_TYPE) == 0)
            {
               sumVolumes += PositionGetDouble(POSITION_VOLUME);  
            }else if(directionTemp == "sell"){
               sumVolumes += PositionGetDouble(POSITION_VOLUME);   
            }
         }
      }else{
         string msgTemp = "The position was NOT selected";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
   }
   //-- Orders
   int totalOrders = OrdersTotal();
   for(int i = 0; i < totalOrders; i++){
      ulong ticketTemp = OrderGetTicket(i);
      if(ticketTemp > 0){
         if(OrderGetString(ORDER_SYMBOL) == symbolPar){
            if(directionTemp == "buy" && (OrderGetInteger(ORDER_TYPE) == 2 
                                       || OrderGetInteger(ORDER_TYPE) == 4))
            {
               sumVolumes += OrderGetDouble(ORDER_VOLUME_CURRENT);  
            }else if(directionTemp == "sell"){
               sumVolumes += OrderGetDouble(ORDER_VOLUME_CURRENT);   
            }
         }
      }else{
         string msgTemp = "The order was NOT selected";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));   
      }
   }
   //-- Validation
   if(sumVolumes + volumePar > maxVolumeTemp){
      string msgTemp = "For the symbol("+symbolPar+") and direction("+directionTemp+") the maximum volume limit is reached! \n"+
                       "Maximum = "+(string)maxVolumeTemp+" , Total Exist = "+(string)sumVolumes+" , Requested Volume = "+(string)volumePar;
      return this.Error.CreateErrorCustom(msgTemp);                       
   }
   return true;
}


//+------------------------------------------------------------------+ 
//| Checks if the specified filling type is allowed                  | 
//+------------------------------------------------------------------+ 
bool CValidationCheck::CheckFillingType(string symbolPar,int fillingTypePar) 
{ 
//--- Obtain the value of the property that describes allowed filling modes 
   int fillingTemp = (int)SymbolInfoInteger(symbolPar,SYMBOL_FILLING_MODE); 
//--- Return true, if mode fill_type is allowed 
   return((fillingTemp & fillingTypePar) == fillingTypePar); 
}








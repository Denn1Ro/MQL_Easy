//+------------------------------------------------------------------+
//|                                           ValidationCheckMT4.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"
#property strict


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
//|                        CheckMoneyForTrade                        |
//+------------------------------------------------------------------+
bool CValidationCheck::CheckMoneyForTrade(string symbolPar,double volumePar,ENUM_ORDER_TYPE typePar)
{
   //-- Free Margin Available  
   double freeMargin = AccountFreeMarginCheck(symbolPar,typePar,volumePar);
//-- if there is not enough money
   if(freeMargin < 0)
     {
      string oper_temp =(typePar==OP_BUY)? "Buy":"Sell";
      string msgTemp = "Your account size has NOT enough money for "+(string)oper_temp+" at "+symbolPar+
                       " with volume  = "+(string)volumePar+"\n";
         msgTemp += "Either reduce the volume or increase your account size.";         
         return this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
     }
//--- checking successful
   return(true);
}

  
//+------------------------------------------------------------------+
//|                     Check Stoploss TakeProfit                    |
//+------------------------------------------------------------------+  
bool CValidationCheck::CheckStopLossTakeprofit(string symbolPar,ENUM_ORDER_TYPE typePar, double openPricePar,double stopLossPar,double takeProfitPar)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   RefreshRates();
   int stops_level=(int)SymbolInfoInteger(symbolPar,SYMBOL_TRADE_STOPS_LEVEL);
   //-- In case of error 
   string msgTemp = "";
//---
   bool slCheck=false,tpCheck=false;
   double askTemp    = SymbolInfoDouble(symbolPar,SYMBOL_ASK);
   double bidTemp    = SymbolInfoDouble(symbolPar,SYMBOL_BID);
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
         if(stopLossPar != 0 && stopLossPar != WRONG_VALUE)slCheck = (bidTemp - stopLossPar > stops_level*pointTemp);
         else slCheck = true; 
         if(!slCheck)msgTemp += "For order "+EnumToString(typePar)+" StopLoss = "+(string)stopLossPar+" must be less than "+(string)(bidTemp - stops_level*pointTemp)+"\n";
         //--- check the TakeProfit
         if(takeProfitPar != 0 && takeProfitPar != WRONG_VALUE)tpCheck = (takeProfitPar - bidTemp > stops_level*pointTemp);
         else tpCheck = true;
         if(!tpCheck)msgTemp += "For order "+EnumToString(typePar)+" TakeProfit = "+(string)takeProfitPar+" must be greater than "+(string)(bidTemp + stops_level*pointTemp);
         //--- return the result of checking
         if(msgTemp != "")this.Error.CreateErrorCustom(msgTemp);
         return(slCheck&&tpCheck);
        }
      //--- ORDER_TYPE_SELL operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
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
//|                     Check Pending Freeze Level                   |
//+------------------------------------------------------------------+  
bool CValidationCheck::CheckPendingFreezeLevel(string symbolPar, int typePar, double openPricePar)
{
   RefreshRates();
   int freezeLevel = (int)SymbolInfoInteger(symbolPar,SYMBOL_TRADE_FREEZE_LEVEL); 
   int stops_level = (int)SymbolInfoInteger(symbolPar,SYMBOL_TRADE_STOPS_LEVEL);
   freezeLevel     = MathMax(freezeLevel,stops_level);
   double askTemp    = SymbolInfoDouble(symbolPar,SYMBOL_ASK);  
   double bidTemp    = SymbolInfoDouble(symbolPar,SYMBOL_BID);
   double pointTemp  = SymbolInfoDouble(symbolPar,SYMBOL_POINT);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return false;
//---
   bool check;
  //--- check the order type
   switch(typePar)
   {
      //--- BuyLimit pending order
      case  ORDER_TYPE_BUY_LIMIT:
      {
         //--- check the distance from the opening price to the activation price
         check=((askTemp-openPricePar)>freezeLevel*pointTemp);
         if(!check){
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
         check=((openPricePar-bidTemp)>freezeLevel*pointTemp);
         if(!check){
            string msgTemp = "Order "+EnumToString((ENUM_ORDER_TYPE)typePar)+" cannot be executed. The distance between open price and market price "+
                              "must be greater than "+(string)freezeLevel+" and the open price for Sell Limit must be above the current price.";
            return this.Error.CreateErrorCustom(msgTemp);
         }
         break;
      }
      //--- BuyStop pending order
      case  ORDER_TYPE_BUY_STOP:
      {
         //--- check the distance from the opening price to the activation price
         check=((openPricePar-askTemp)>freezeLevel*pointTemp);
         if(!check){
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
         check=((bidTemp-openPricePar)>freezeLevel*pointTemp);
         if(!check){
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
bool CValidationCheck::CheckModifyLevels(long ticketPar, double pricePar, double stopLossPar,double takeProfitPar,int typePar = 0)
{
//--- select order by ticket
   if(OrderSelect((int)ticketPar,SELECT_BY_TICKET))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbolTemp       = OrderSymbol();
      double pointTemp        = SymbolInfoDouble(symbolTemp,SYMBOL_POINT);
      //--- check if there are changes in the Open price
      bool priceOpenChanged   = false;
      int typeTemp            = OrderType();
      if(!(typeTemp == OP_BUY || typeTemp == OP_SELL)){
         priceOpenChanged = (MathAbs(OrderOpenPrice() - pricePar) > pointTemp);
      }
      //--- check if there are changes in the StopLoss level
      bool stopLossChanged    = (MathAbs(OrderStopLoss() - stopLossPar) > pointTemp);
      //--- check if there are changes in the Takeprofit level
      bool takeProfitChanged  = (MathAbs(OrderTakeProfit() - takeProfitPar) > pointTemp);
      //--- if there are any changes in levels
      if(priceOpenChanged || stopLossChanged || takeProfitChanged){
         return(true);  // order can be modified      
      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      }else{
         return false;
      }      
   }else{
      string msgTemp = "The order #"+(string)+ticketPar+" was NOT selected";
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
   }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying 
}



//+------------------------------------------------------------------+
//|                      CheckNewOrderAllowed                        |
//+------------------------------------------------------------------+
bool CValidationCheck::CheckMaxNumberPendingOrders()
{
   //-- Number of maximum pending orders
   int maxAllowedOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   //-- If it is 0 then the account has no restriction for maximum pending orders
   if(maxAllowedOrders == 0) return(true);
   int totalOrders    = OrdersTotal();
   //-- Find the pending orders
   int pendingOrders  = 0;
   for(int i =0; i < totalOrders; i++){
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderType() != OP_BUY && OrderType() != OP_SELL)pendingOrders++;
      }else{
         string msgTemp = "The order was NOT selected";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
   }
   //-- check if the limit is exceeded
   bool allowTemp = pendingOrders < maxAllowedOrders;   
   if(!allowTemp){
      string msgTemp = "You are NOT allowed to place orders more than "+(string)maxAllowedOrders;
      return this.Error.CreateErrorCustom(msgTemp);
   }
   return(allowTemp);
}  
  
  


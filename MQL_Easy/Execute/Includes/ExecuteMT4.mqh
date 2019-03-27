//+------------------------------------------------------------------+
//|                                                   ExecuteMT4.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"
#property strict

#include "ExecuteBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CExecute : public CExecuteBase
  {
private:

public:
                     CExecute(string symbolPar = NULL, long magicNumberPar = 12345);
                    ~CExecute();
   virtual long      Position(ENUM_TYPE_POSITION positionTypePar,double volumePar,double stopLossPar = 0,double takeProfitPar = 0,ENUM_SLTP_TYPE sltpPar = 0,
                              int deviationPar = 10,string commentPar = NULL);
   virtual long      Order(ENUM_TYPE_ORDER orderTypePar,double volumePar, double openPricePar, double stopLossPar = 0, double takeProfitPar = 0, 
                              ENUM_SLTP_TYPE sltpPar = 0, datetime expirationPar = 0,int deviationPar = 10, string commentPar = NULL); 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExecute::CExecute(string symbolPar = NULL, long magicNumberPar = 12345)
        : CExecuteBase(symbolPar,magicNumberPar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExecute::~CExecute()
  {
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|      create a position
//+------------------------------------------------------------------+
long CExecute::Position(ENUM_TYPE_POSITION positionTypePar,double volumePar,double stopLossPar=0.000000,double takeProfitPar=0.000000,ENUM_SLTP_TYPE sltpPar=0,int deviationPar=10,string commentPar=NULL)
{
   //-- Ticket
   long ticketTemp = -1;
   //-- Check for negative numbers
   if(positionTypePar < 0 || volumePar < 0 || stopLossPar < 0 || takeProfitPar < 0 || sltpPar < 0 || deviationPar < 0){
      string msgTemp = "The Position WAS NOT completed. One of the parameters has negative value.";
      this.Error.CreateErrorCustom(msgTemp,false,false,__FUNCTION__);
      return ticketTemp;
   }
   //-- check symbol
   CUtilities utilsTemp;
   if(!utilsTemp.SetSymbol(this.Symbol)){this.Error.Copy(utilsTemp.Error);return -1;}
   //-- Price
   double priceTemp = (positionTypePar == TYPE_POSITION_BUY) ? utilsTemp.Ask() : utilsTemp.Bid();
   //-- SL TP properties
   double stoplossTemp  =0;
   double takeprofitTemp=0;
   //-- Validation Checks
   if(!this.Validation(sltpPar,(ENUM_ORDER_TYPE)positionTypePar,priceTemp,stopLossPar,takeProfitPar,stoplossTemp,takeprofitTemp,volumePar,0))return ticketTemp;
   //-- color for the order
   color colorTemp = (positionTypePar == TYPE_POSITION_BUY) ? clrLime : clrRed; 
   //--- send a trade 
   ticketTemp = OrderSend(this.Symbol,(ENUM_ORDER_TYPE)positionTypePar,volumePar,priceTemp,deviationPar/10,stoplossTemp,takeprofitTemp,commentPar,(int)this.MagicNumber,0,colorTemp);	
   if(ticketTemp == -1){
      string msgTemp = "The Position WAS NOT completed.";
      this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__)); 
   }  
   return ticketTemp;
}


//+------------------------------------------------------------------+
//|    create an order
//+------------------------------------------------------------------+
long CExecute::Order(ENUM_TYPE_ORDER orderTypePar,double volumePar,double openPricePar,double stopLossPar=0.000000,double takeProfitPar=0.000000,ENUM_SLTP_TYPE sltpPar=0,datetime expirationPar=0,int deviationPar=10,string commentPar=NULL)
{
   //-- Ticket
   long ticketTemp = -1;
   //-- Check for negative numbers
   if(orderTypePar < 0 || volumePar < 0 || stopLossPar < 0 || takeProfitPar < 0 || sltpPar < 0 || deviationPar < 0 || expirationPar < 0){
      string msgTemp = "The Position WAS NOT completed. One of the parameters has negative value.";
      this.Error.CreateErrorCustom(msgTemp,false,false,__FUNCTION__);
      return ticketTemp;
   }
   //-- Price
   double priceTemp = openPricePar;
   //-- SL TP Properties
   double stoplossTemp     = 0;
   double takeprofitTemp   = 0;
   //-- Validation Checks
   if(!this.Validation(sltpPar,(ENUM_ORDER_TYPE)orderTypePar,priceTemp,stopLossPar,takeProfitPar,stoplossTemp,takeprofitTemp,volumePar,expirationPar))return ticketTemp;
   //-- color for the order
   color colorTemp = (orderTypePar == TYPE_ORDER_BUYLIMIT || orderTypePar == TYPE_ORDER_BUYSTOP) ? clrLime : clrRed; 
   //--- send a trade
   ticketTemp = OrderSend(this.Symbol,(ENUM_ORDER_TYPE)orderTypePar,volumePar,priceTemp,deviationPar/10,stoplossTemp,takeprofitTemp,commentPar,(int)this.MagicNumber,expirationPar,clrLime);	
   if(ticketTemp == -1){
      string msgTemp = "The Order WAS NOT completed.";
      this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__)); 
   }  
   return ticketTemp;
}



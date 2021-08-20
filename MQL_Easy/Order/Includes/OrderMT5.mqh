//+------------------------------------------------------------------+
//|                                                     OrderMT5.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "OrderBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COrder : public COrderBase
  {

public:
                           COrder(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_ORDERS groupPar = GROUP_ORDERS_ALL);
                          ~COrder();
   //-- Group Properties
   virtual int             GroupTotal();  
   virtual double          GroupTotalVolume();
   virtual void            GroupCloseAll(uint triesPar = 20);
   //-- Order Properties                
   virtual long            GetTicket();
   virtual datetime        GetTimeSetUp();
   virtual datetime        GetTimeExpiration();
   virtual int             GetType(); 
   virtual long            GetMagicNumber();   
   virtual double          GetVolume();
   virtual double          GetPriceOpen();  
   virtual double          GetStopLoss();
   virtual double          GetTakeProfit();
   virtual string          GetSymbol();
   virtual string          GetComment();
   virtual bool            Close(uint triesPar = 20);
   virtual bool            Modify(double priceOpenPar = WRONG_VALUE,double stopLossPar = WRONG_VALUE,double takeProfitPar = WRONG_VALUE,
                                       ENUM_SLTP_TYPE sltpPar = SLTP_PRICE, datetime expirationPar = WRONG_VALUE);   
   virtual long            SelectByIndex(int indexPar);
   virtual bool            SelectByTicket(long ticketPar);   
   //-- Quick Access
   COrder*                 operator[](const int indexPar);
   COrder*                 operator[](const long ticketPar);                 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrder::COrder(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_ORDERS groupPar = GROUP_ORDERS_ALL) 
         : COrderBase(symbolPar,magicNumberPar,groupPar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrder::~COrder()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                     operator for index                           |
//+------------------------------------------------------------------+
COrder* COrder::operator[](const int indexPar)
{
   long ticketTemp = this.SelectByIndex(indexPar);
   if(ticketTemp == -1){
      string msgTemp = "The Position with index "+(string)indexPar+" WAS NOT selected.";
      this.Error.CreateErrorCustom(msgTemp);
   }
   return GetPointer(this);
} 


//+------------------------------------------------------------------+
//|                     operator for ticket                          |
//+------------------------------------------------------------------+
COrder* COrder::operator[](const long ticketPar)
{
   this.SelectByTicket(ticketPar);
   return GetPointer(this);
}


//+------------------------------------------------------------------+
//|      select an order by index
//+------------------------------------------------------------------+
long COrder::SelectByIndex(int indexPar)
{
   int numberOrders      = 0;
   for (int i = 0; i < OrdersTotal(); i++){
      this.ValidSelection = true; // the selection is valid
      long ticketTemp = (long)OrderGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidOrder(OrderGetString(ORDER_SYMBOL),OrderGetInteger(ORDER_MAGIC),(int)OrderGetInteger(ORDER_TYPE))){ 	
            if(numberOrders == indexPar){
               return ticketTemp;   
            }
            numberOrders++; 
         }
		}else{
         string msgTemp = "The Order with index "+(string)i+" WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection = false;
      }
	}

	//-- Case when the index is greater than the total orders
	if(indexPar >= numberOrders){
	   string msgTemp    = "The index of selection can NOT be equal or greater than the total orders. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Orders = "+(string)numberOrders;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|     select an order by ticket
//+------------------------------------------------------------------+
bool COrder::SelectByTicket(long ticketPar)
{
   if(OrderSelect(ticketPar)){
      this.ValidSelection = true;
      return true;    
   }else{
      this.ValidSelection = false;
      string msgTemp = "The Order WAS NOT Selected.";
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
   }
}


//+------------------------------------------------------------------+
//|     get the total orders of the group
//+------------------------------------------------------------------+
int COrder::GroupTotal()
{
   int totalOrders   = 0;
   for (int i = OrdersTotal()-1; i >= 0; i--){
      ulong ticket_temp = OrderGetTicket(i);
		if (ticket_temp > 0){
         if(this.ValidOrder(OrderGetString(ORDER_SYMBOL),OrderGetInteger(ORDER_MAGIC),(int)OrderGetInteger(ORDER_TYPE)))
            totalOrders++;  		   
		}else{
         string msgTemp = "The Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return totalOrders; 
}


//+------------------------------------------------------------------+
//|     get the total volume of the group
//+------------------------------------------------------------------+
double COrder::GroupTotalVolume(void)
{
   double volumeOrders   = 0;
   for (int i = OrdersTotal()-1; i >= 0; i--){
      ulong ticketTemp = OrderGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidOrder(OrderGetString(ORDER_SYMBOL),OrderGetInteger(ORDER_MAGIC),(int)OrderGetInteger(ORDER_TYPE)))
            volumeOrders += OrderGetDouble(ORDER_VOLUME_CURRENT);  		   
		}else{
         string msgTemp = "The Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumeOrders;   
}


//+------------------------------------------------------------------+
//|     close all orders of the group
//+------------------------------------------------------------------+
void COrder::GroupCloseAll(uint triesPar = 20)
{
   //-- tries to close
   uint triesTemp = 0;
	for (int i=OrdersTotal()-1; i >=0; i--)
	{
	   ulong ticketTemp = OrderGetTicket(i);
		if (ticketTemp > 0)
		{
		   ulong magicTemp               = OrderGetInteger(ORDER_MAGIC);
		   string symbolTemp             = OrderGetString(ORDER_SYMBOL);
		   ENUM_ORDER_TYPE typeTemp      = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
		   if(!this.ValidOrder(symbolTemp,magicTemp,(int)typeTemp))continue;
		   MqlTradeRequest request       = {}; 
		   MqlTradeResult result         = {};
			request.action                = TRADE_ACTION_REMOVE;                            
         request.order                 = ticketTemp;
         CUtilities utilsTemp;
         if(!utilsTemp.SetSymbol(symbolTemp)){this.Error.Copy(utilsTemp.Error);return;}
         request.type_filling          = utilsTemp.FillingOrder(); 
		   if(!OrderSend(request,result)){
				string msgTemp = "The Order WAS NOT Closed.";
            this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,NULL,result.retcode);
            Sleep(1000);
            triesTemp++;
            if(triesTemp >= triesPar)continue;
            i++;
			} 			
		}else{
		   string msgTemp = "The Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
}


//+------------------------------------------------------------------+
//|    get the ticket of an order  
//+------------------------------------------------------------------+
long COrder::GetTicket(void)
{
   if(!this.ValidSelection)return -1;
   return OrderGetInteger(ORDER_TICKET);
}


//+------------------------------------------------------------------+
//|    get the time setup of an order
//+------------------------------------------------------------------+
datetime COrder::GetTimeSetUp(void)
{
   if(!this.ValidSelection)return -1;
   return((datetime)OrderGetInteger(ORDER_TIME_SETUP));
}


//+------------------------------------------------------------------+
//|    get the time expiration of an order
//+------------------------------------------------------------------+
datetime COrder::GetTimeExpiration(void)
{
   if(!this.ValidSelection)return -1;
   return((datetime)OrderGetInteger(ORDER_TIME_EXPIRATION));
}


//+------------------------------------------------------------------+
//|     get the type of an order
//+------------------------------------------------------------------+
int COrder::GetType(void)
{
   if(!this.ValidSelection)return -1;
   return((int)OrderGetInteger(ORDER_TYPE));
}



//+------------------------------------------------------------------+
//|     get the magic number of an order
//+------------------------------------------------------------------+
long COrder::GetMagicNumber(void)
{
   if(!this.ValidSelection)return -1;
   return(OrderGetInteger(ORDER_MAGIC));
}



//+------------------------------------------------------------------+
//|    get the volume of an order
//+------------------------------------------------------------------+
double COrder::GetVolume(void)
{
   if(!this.ValidSelection)return -1;
   return OrderGetDouble(ORDER_VOLUME_CURRENT);
}


//+------------------------------------------------------------------+
//|     get the open price of an order
//+------------------------------------------------------------------+
double COrder::GetPriceOpen(void)
{
   if(!this.ValidSelection)return -1;
   return OrderGetDouble(ORDER_PRICE_OPEN);
}


//+------------------------------------------------------------------+
//|     get the stoploss of an order
//+------------------------------------------------------------------+
double COrder::GetStopLoss(void)
{
   if(!this.ValidSelection)return -1;
   return OrderGetDouble(ORDER_SL);
}


//+------------------------------------------------------------------+
//|    get the takeprofit of an order
//+------------------------------------------------------------------+
double COrder::GetTakeProfit(void)
{
   if(!this.ValidSelection)return -1;
   return OrderGetDouble(ORDER_TP);
}


//+------------------------------------------------------------------+
//|    get the symbol of an order
//+------------------------------------------------------------------+
string COrder::GetSymbol(void)
{
   if(!this.ValidSelection)return "";
   return OrderGetString(ORDER_SYMBOL);
}


//+------------------------------------------------------------------+
//|    get the comment of an order
//+------------------------------------------------------------------+
string COrder::GetComment(void)
{
   if(!this.ValidSelection)return "";
   return OrderGetString(ORDER_COMMENT);
}


//+------------------------------------------------------------------+
//|    close an order
//+------------------------------------------------------------------+
bool COrder::Close(uint triesPar = 20)
{
   if(!this.ValidSelection)return false;
   bool status = false;
   for(uint i = 0; i < triesPar; i++)
	{
	   MqlTradeRequest request = {}; 
		MqlTradeResult result   = {};
      request.action          = TRADE_ACTION_REMOVE;                   
      request.order           = this.GetTicket();
      CUtilities utilsTemp;
      if(!utilsTemp.SetSymbol(this.GetSymbol())){this.Error.Copy(utilsTemp.Error);return false;}
      request.type_filling    = utilsTemp.FillingOrder(); 
	   if(!OrderSend(request,result)){
         string msgTemp = "The Order WAS NOT Closed.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,NULL,result.retcode);
         Sleep(1000);
		}else {
		   status = true;
		   break;	
		}
	}
   return status;
}


//+------------------------------------------------------------------+
//|     modify an order
//+------------------------------------------------------------------+
bool COrder::Modify(double priceOpenPar = WRONG_VALUE,double stopLossPar = WRONG_VALUE,double takeProfitPar = WRONG_VALUE, ENUM_SLTP_TYPE sltpPar = SLTP_PRICE,
                           datetime expirationPar = WRONG_VALUE)
{  
   if(!this.ValidSelection)return false;
   //-- Check for wrong parameters
   if(stopLossPar == WRONG_VALUE && takeProfitPar == WRONG_VALUE && priceOpenPar == WRONG_VALUE && expirationPar == WRONG_VALUE)return false; 
   //--
   double stopLossTemp     = WRONG_VALUE;
   double takeProfitTemp   = WRONG_VALUE;
   double priceOpenTemp    = WRONG_VALUE;
   datetime expirationTemp = WRONG_VALUE;
   string symbolTemp       = this.GetSymbol();
   int   typeTemp          = (int)this.GetType(); 
   //-- Check Expiration Parameter
   if(expirationPar == WRONG_VALUE)expirationTemp = (datetime)this.GetTimeExpiration();
   else if(expirationPar <= TimeCurrent()){
      Print("The expiration parameter must be greater than "+(string)TimeCurrent()+" , Function("+__FUNCTION__+")");
      string msgTemp = "The expiration parameter must be greater than "+(string)TimeCurrent();
      return this.Error.CreateErrorCustom(msgTemp,true,false);
   }  
   CValidationCheck validationCheckTemp;
   //-- Price Open Validation
   if(priceOpenPar != WRONG_VALUE){
      //-- Validation Check Freeze Level
      if(!validationCheckTemp.CheckPendingFreezeLevel(symbolTemp,typeTemp,priceOpenPar)){this.Error.Copy(validationCheckTemp.Error);return false;}
      priceOpenTemp = priceOpenPar;
   }else priceOpenTemp = this.GetPriceOpen();
   //-- SLTP Convert
   CUtilities utilsTemp;
   if(!utilsTemp.SetSymbol(symbolTemp)){this.Error.Copy(utilsTemp.Error);return false;}
   if(!utilsTemp.SltpConvert(sltpPar,typeTemp,priceOpenTemp,stopLossPar,takeProfitPar,stopLossTemp,takeProfitTemp))
      return false;    
   //-- Check the validation of stoploss and takeprofit 
   if(!validationCheckTemp.CheckStopLossTakeprofit(symbolTemp,(ENUM_ORDER_TYPE)typeTemp,priceOpenTemp,stopLossTemp,takeProfitTemp)){this.Error.Copy(validationCheckTemp.Error);return false;} 
   //-- set SLTP 
   stopLossTemp   = (stopLossPar == WRONG_VALUE)      ? this.GetStopLoss()    : stopLossTemp;  
   takeProfitTemp = (takeProfitPar == WRONG_VALUE)    ? this.GetTakeProfit()  : takeProfitTemp;
   //-- Check if there is no need to make any modification
   if(!validationCheckTemp.CheckModifyLevels(this.GetTicket(),priceOpenTemp,stopLossTemp,takeProfitTemp,1)){this.Error.Copy(validationCheckTemp.Error);return false;}
   //--- prepare a request 
   MqlTradeRequest request    = {}; 
   request.action             = TRADE_ACTION_MODIFY;    
   request.symbol             = symbolTemp;       
   request.magic              = this.GetMagicNumber();  
   request.order              = this.GetTicket();    
   request.expiration         = expirationTemp;                        
   request.price              = priceOpenTemp;                                      
   request.sl                 = stopLossTemp;                                
   request.tp                 = takeProfitTemp; 
   //-- Filling Order Problem
   request.type_filling       = utilsTemp.FillingOrder(); 
   //--- send a trade request 
   MqlTradeResult result      = {0};    
   if(!OrderSend(request,result)){
      string msgTemp = "The Order WAS NOT Modified.";
      this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,NULL,result.retcode);
      return false;        
   }    
   return true;
}



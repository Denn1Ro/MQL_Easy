//+------------------------------------------------------------------+
//|                                              HistoryOrderMT5.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "HistoryOrderBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHistoryOrder : public CHistoryOrderBase
  {
protected:
   CHistoryOrder           *mObject;  
   bool                    HistoryRange(void);

public:
                           CHistoryOrder(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_ORDERS groupPar = GROUP_HISTORY_ORDERS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0);
                          ~CHistoryOrder();
   //-- Group Properties
   virtual int             GroupTotal();  
   virtual double          GroupTotalVolume();      
   //-- History Order Properties        
   virtual long            GetTicket(void);
   virtual int             GetType();
   virtual datetime        GetTimeSetUp();
   virtual datetime        GetTimeExpiration();
   virtual double          GetStopLoss();
   virtual double          GetTakeProfit();     
   virtual long            GetMagicNumber(void);   
   virtual double          GetVolume(void);
   virtual double          GetPriceOpen(void);
   virtual string          GetSymbol(void);
   virtual string          GetComment(void);  
   //--
   virtual long            SelectByIndex(int indexPar);
   virtual bool            SelectByTicket(long ticketPar);                     
   //-- Quick Access
   CHistoryOrder*          operator[](const int indexPar);
   CHistoryOrder*          operator[](const long ticketPar);                    
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistoryOrder::CHistoryOrder(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_ORDERS groupPar = GROUP_HISTORY_ORDERS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0) 
             : CHistoryOrderBase(symbolPar,magicNumberPar,groupPar,startDatePar,endDatePar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistoryOrder::~CHistoryOrder()
  {
    if(CheckPointer(this.mObject) == POINTER_DYNAMIC)delete this.mObject;
  }
//+------------------------------------------------------------------+

 
//+------------------------------------------------------------------+
//|                     operator for index                           |
//+------------------------------------------------------------------+
CHistoryOrder* CHistoryOrder::operator[](const int indexPar)
{
   if(CheckPointer(this.mObject) == POINTER_INVALID)this.mObject = new CHistoryOrder(this.GroupSymbol,this.GroupMagicNumber,this.Group);
   long ticketTemp = this.SelectByIndex(indexPar);
   if(ticketTemp == -1){
      string msgTemp = "The History Order WAS NOT selected.";
      this.Error.CreateErrorCustom(msgTemp);
   }
   return this.mObject;
} 


//+------------------------------------------------------------------+
//|                     operator for ticket                          |
//+------------------------------------------------------------------+
CHistoryOrder* CHistoryOrder::operator[](const long ticketPar)
{
   if(CheckPointer(this.mObject) == POINTER_INVALID)this.mObject = new CHistoryOrder(this.GroupSymbol,this.GroupMagicNumber,this.Group);
   this.SelectByTicket(ticketPar);
   return this.mObject;
}



//+------------------------------------------------------------------+
//|     select the history range
//+------------------------------------------------------------------+
bool CHistoryOrder::HistoryRange(void)
{
   if(!HistorySelect(this.StartDate,(this.EndDate == 0) ? TimeCurrent() : this.EndDate)){
      string msgTemp = "HistorySelect function produced an Error";
      this.Error.CreateErrorCustom(msgTemp,true,false,__FUNCTION__);
      return false;
   }  
   return true;
}



//+------------------------------------------------------------------+
//|      select an order by index
//+------------------------------------------------------------------+
long CHistoryOrder::SelectByIndex(int indexPar)
{
   //-- Reset the ticket
   this.mTicket = -1;
   this.mObject.mTicket = (CheckPointer(this.mObject) != POINTER_INVALID) ? this.mTicket : -1;
   //-- Set History Range
   if(!this.HistoryRange())return-1;   
   
   int numberOrders      = 0;
   for (int i = 0; i < HistoryOrdersTotal(); i++){
      long ticketTemp = (long)HistoryOrderGetTicket(i);
		if (ticketTemp > 0){
		   this.ValidSelection           = true; //  The selection is valid
         if(this.ValidOrder(HistoryOrderGetString(ticketTemp,ORDER_SYMBOL),HistoryOrderGetInteger(ticketTemp,ORDER_MAGIC),
                                                (int)HistoryOrderGetInteger(ticketTemp,ORDER_TYPE)))
         { 	
            if(numberOrders == indexPar){
               this.mTicket = ticketTemp;
               this.mObject.mTicket = (CheckPointer(this.mObject) != POINTER_INVALID) ? this.mTicket : -1;
               return ticketTemp;   
            }
            numberOrders++; 
         }
		}else{
         string msgTemp = "The History Order with index "+(string)i+" WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection           = false;
      }
	}

	//-- Case when the index is greater than the total positions
	if(indexPar >= numberOrders){
	   string msgTemp    = "The index of selection can NOT be greater or equal than the total history orders. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Orders = "+(string)numberOrders;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|     select an order by ticket
//+------------------------------------------------------------------+
bool CHistoryOrder::SelectByTicket(long ticketPar)
{
   //-- Reset the ticket
   this.mTicket = -1;
   this.mObject.mTicket = (CheckPointer(this.mObject) != POINTER_INVALID) ? this.mTicket : -1;
   if(HistoryOrderSelect(ticketPar)){   
      this.mTicket = ticketPar;
      this.mObject.mTicket = (CheckPointer(this.mObject) != POINTER_INVALID) ? this.mTicket : -1;
      this.ValidSelection           = true;
      return true;
   }
   else{
      this.ValidSelection           = false;
      string msgTemp = "The History Order WAS NOT Selected.";
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
   }
}




//+------------------------------------------------------------------+
//|      get the total orders of a Group
//+------------------------------------------------------------------+
int CHistoryOrder::GroupTotal()
{
   int totalOrders   = 0;
   //-- Set History Range
   if(!this.HistoryRange())return totalOrders;   
   
   for (int i = HistoryOrdersTotal()-1; i >= 0; i--){
      ulong ticketTemp = HistoryOrderGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidOrder(HistoryOrderGetString(ticketTemp,ORDER_SYMBOL),HistoryOrderGetInteger(ticketTemp,ORDER_MAGIC),
            (int)HistoryOrderGetInteger(ticketTemp,ORDER_TYPE)))
               totalOrders++;  		   
		}else{
         string msgTemp = "The History Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return totalOrders; 
}



//+------------------------------------------------------------------+
//|     get the total volume of a Group
//+------------------------------------------------------------------+
double CHistoryOrder::GroupTotalVolume(void)
{
   double volumeOrders   = 0;
   //-- Set History Range
   if(!this.HistoryRange())return volumeOrders;
   
   for (int i = HistoryOrdersTotal()-1; i >= 0; i--){
      ulong ticketTemp = HistoryOrderGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidOrder(HistoryOrderGetString(ticketTemp,ORDER_SYMBOL),HistoryOrderGetInteger(ticketTemp,ORDER_MAGIC),
            (int)HistoryOrderGetInteger(ticketTemp,ORDER_TYPE)))
               volumeOrders += HistoryOrderGetDouble(ticketTemp,ORDER_VOLUME_INITIAL);  		   
		}else{
         string msgTemp = "The History Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumeOrders;   
}




//+------------------------------------------------------------------+
//|     get the ticket of an order
//+------------------------------------------------------------------+
long CHistoryOrder::GetTicket(void)
  {
   if(!this.ValidSelection)return -1;
   return(this.mTicket);
  }

//+------------------------------------------------------------------+
//|      get the type of an order
//+------------------------------------------------------------------+
int CHistoryOrder::GetType(void)
  {
   if(!this.ValidSelection)return -1;
   return((int)HistoryOrderGetInteger(this.mTicket,ORDER_TYPE));
  }
  
//+------------------------------------------------------------------+
//|      get the time set up of an order
//+------------------------------------------------------------------+
datetime CHistoryOrder::GetTimeSetUp(void)
  {
   if(!this.ValidSelection)return -1;
   return((datetime)HistoryOrderGetInteger(this.mTicket,ORDER_TIME_SETUP));
  }
//+------------------------------------------------------------------+
//|      get the time expiration of an order
//+------------------------------------------------------------------+
datetime CHistoryOrder::GetTimeExpiration(void)
  {
   if(!this.ValidSelection)return -1;
   return((datetime)HistoryOrderGetInteger(this.mTicket,ORDER_TIME_EXPIRATION));
  }  
//+------------------------------------------------------------------+
//|      get the magic number of an order
//+------------------------------------------------------------------+
long CHistoryOrder::GetMagicNumber(void)
  {
   if(!this.ValidSelection)return -1;
   return(HistoryOrderGetInteger(this.mTicket,ORDER_MAGIC));
  }
//+------------------------------------------------------------------+
//|     get the volume of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetVolume(void)
  {
   if(!this.ValidSelection)return -1;
   return(HistoryOrderGetDouble(this.mTicket,ORDER_VOLUME_INITIAL));
  }
//+------------------------------------------------------------------+
//|     get the price open of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetPriceOpen(void)
  {
   if(!this.ValidSelection)return -1;
   return(HistoryOrderGetDouble(this.mTicket,ORDER_PRICE_OPEN));
  }
//+------------------------------------------------------------------+
//|     get the stoploss of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetStopLoss(void)
  {
   if(!this.ValidSelection)return -1;
   return(HistoryOrderGetDouble(this.mTicket,ORDER_SL));
  }
//+------------------------------------------------------------------+
//|     get the takeprofit of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetTakeProfit(void)
  {
   if(!this.ValidSelection)return -1;
   return(HistoryOrderGetDouble(this.mTicket,ORDER_TP));
  }  
//+------------------------------------------------------------------+
//|     get the symbol of an order
//+------------------------------------------------------------------+
string CHistoryOrder::GetSymbol(void)
  {
   if(!this.ValidSelection)return "";
   return(HistoryOrderGetString(this.mTicket,ORDER_SYMBOL));
  }
//+------------------------------------------------------------------+
//|     get the comment of an order
//+------------------------------------------------------------------+
string CHistoryOrder::GetComment(void)
  {
   if(!this.ValidSelection)return "";
   return(HistoryOrderGetString(this.mTicket,ORDER_COMMENT));
  }

//+------------------------------------------------------------------+
//|                                              HistoryOrderMT4.mqh |
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
   bool                    HistoryRange(datetime datePar);

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
  }
//+------------------------------------------------------------------+

 
//+------------------------------------------------------------------+
//|                     operator for index                           |
//+------------------------------------------------------------------+
CHistoryOrder* CHistoryOrder::operator[](const int indexPar)
{
   long ticketTemp = this.SelectByIndex(indexPar);
   if(ticketTemp == -1){
      string msgTemp = "The History Order WAS NOT selected.";
      this.Error.CreateErrorCustom(msgTemp);
   }
   return GetPointer(this);
} 


//+------------------------------------------------------------------+
//|                     operator for ticket                          |
//+------------------------------------------------------------------+
CHistoryOrder* CHistoryOrder::operator[](const long ticketPar)
{
   this.SelectByTicket(ticketPar);
   return GetPointer(this);
}


//+------------------------------------------------------------------+
//|     check the history range
//+------------------------------------------------------------------+
bool CHistoryOrder::HistoryRange(datetime datePar)
{
   if(datePar >= this.StartDate && datePar <= this.EndDate){
      return true;
   }  
   return false;
}


//+------------------------------------------------------------------+
//|      select an order by index
//+------------------------------------------------------------------+
long CHistoryOrder::SelectByIndex(int indexPar)
{
   //-- Reset the ticket   
   int numberOrders      = 0;
   for (int i = 0; i < OrdersHistoryTotal(); i++){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
		   this.ValidSelection = true;
         if(this.ValidOrder(OrderSymbol(),OrderMagicNumber(),OrderType()))
         { 	
            if(numberOrders == indexPar){
               return OrderTicket();   
            }
            numberOrders++; 
         }
		}else{
         string msgTemp = "The History Order with index "+(string)i+" WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection = false;
      }
	}

	//-- Case when the index is greater than the total positions
	if(indexPar >= numberOrders){
	   string msgTemp    = "The index of selection can NOT be equal or greater than the total history orders. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Orders = "+(string)numberOrders;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|      select an order by ticket
//+------------------------------------------------------------------+
bool CHistoryOrder::SelectByTicket(long ticketPar)
{
   if(OrderSelect((int)ticketPar,SELECT_BY_TICKET,MODE_HISTORY)){   
      this.ValidSelection = true;
      return true;
   }
   else{
      this.ValidSelection = false;
      string msgTemp = "The History WAS NOT Selected.";
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
   }
}




//+------------------------------------------------------------------+
//|      get the total orders of a group
//+------------------------------------------------------------------+
int CHistoryOrder::GroupTotal()
{
   int totalOrders   = 0;  
   for (int i = OrdersHistoryTotal()-1; i >= 0; i--){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);      
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
		   if(OrderType() == 6)continue; // This type of order is the initial deposit
         if(this.ValidOrder(OrderSymbol(),OrderMagicNumber(),OrderType()))totalOrders++;  		   
		}else{
         string msgTemp = "The History Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return totalOrders; 
}


//+------------------------------------------------------------------+
//|      get the total volume of a group
//+------------------------------------------------------------------+
double CHistoryOrder::GroupTotalVolume(void)
{
   double volumeOrders   = 0;   
   for (int i = OrdersHistoryTotal()-1; i >= 0; i--){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
         if(this.ValidOrder(OrderSymbol(),OrderMagicNumber(),OrderType()))
            volumeOrders += OrderLots();
		}else{
         string msgTemp = "The History Order WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumeOrders;   
}



//+------------------------------------------------------------------+
//|      get the ticket of an order
//+------------------------------------------------------------------+
long CHistoryOrder::GetTicket(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderTicket());
  }

//+------------------------------------------------------------------+
//|      get the type of an order
//+------------------------------------------------------------------+
int CHistoryOrder::GetType(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderType());
  }
  
//+------------------------------------------------------------------+
//|      get the time set up of an order
//+------------------------------------------------------------------+
datetime CHistoryOrder::GetTimeSetUp(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderOpenTime());
  }
//+------------------------------------------------------------------+
//|      get the time expiration of an order
//+------------------------------------------------------------------+
datetime CHistoryOrder::GetTimeExpiration(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderExpiration());
  }   
//+------------------------------------------------------------------+
//|      get the magic number of an order
//+------------------------------------------------------------------+
long CHistoryOrder::GetMagicNumber(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderMagicNumber());
  }
//+------------------------------------------------------------------+
//|      get the volume of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetVolume(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderLots());
  }
//+------------------------------------------------------------------+
//|      get the price open of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetPriceOpen(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderOpenPrice());
  }
//+------------------------------------------------------------------+
//|      get the stoploss of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetStopLoss(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderStopLoss());
  }
//+------------------------------------------------------------------+
//|     get the takeprofit of an order
//+------------------------------------------------------------------+
double CHistoryOrder::GetTakeProfit(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderTakeProfit());
  }
//+------------------------------------------------------------------+
//|     get the symbol of an order
//+------------------------------------------------------------------+
string CHistoryOrder::GetSymbol(void)
  {
   if(!this.ValidSelection)return "";
   return(OrderSymbol());
  }
//+------------------------------------------------------------------+
//|     get the comment of an order
//+------------------------------------------------------------------+
string CHistoryOrder::GetComment(void)
  {
   if(!this.ValidSelection)return "";
   return(OrderComment());
  }

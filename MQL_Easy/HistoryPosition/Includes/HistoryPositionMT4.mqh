//+------------------------------------------------------------------+
//|                                           HistoryPositionMT4.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "HistoryPositionBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHistoryPosition : public CHistoryPositionBase
  {
protected:
   CHistoryPosition        *mObject;  
   bool                    HistoryRange(datetime datePar);

public:
                           CHistoryPosition(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_POSITIONS groupPar = GROUP_HISTORY_POSITIONS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0);
                          ~CHistoryPosition();
   //-- Group Properties
   virtual int             GroupTotal();  
   virtual double          GroupTotalVolume();      
   virtual double          GroupTotalProfit(); 
   //-- History Order Properties        
   virtual long            GetTicket(void);
   virtual int             GetType();
   virtual double          GetStopLoss();
   virtual double          GetTakeProfit();     
   virtual datetime        GetTimeOpen(void);
   virtual datetime        GetTimeClose(void);
   virtual long            GetMagicNumber(void);   
   virtual double          GetVolume(void);
   virtual double          GetPriceOpen(void);
   virtual double          GetPriceClose(void);
   virtual double          GetCommission(void);
   virtual double          GetSwap(void);
   virtual double          GetProfit(void);
   virtual string          GetSymbol(void);
   virtual string          GetComment(void);  
   //--
   virtual long            SelectByIndex(int indexPar);
   virtual bool            SelectByTicket(long ticketPar);                     
   //-- Quick Access
   CHistoryPosition*       operator[](const int indexPar);
   CHistoryPosition*       operator[](const long ticketPar);                     
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistoryPosition::CHistoryPosition(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_POSITIONS groupPar = GROUP_HISTORY_POSITIONS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0) 
                              : CHistoryPositionBase(symbolPar,magicNumberPar,groupPar,startDatePar,endDatePar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistoryPosition::~CHistoryPosition()
  {
   if(CheckPointer(this.mObject) == POINTER_DYNAMIC)delete this.mObject;
  }
//+------------------------------------------------------------------+


  
//+------------------------------------------------------------------+
//|                     operator for index                           |
//+------------------------------------------------------------------+
CHistoryPosition* CHistoryPosition::operator[](const int indexPar)
{
   if(CheckPointer(this.mObject) == POINTER_INVALID)this.mObject = new CHistoryPosition(this.GroupSymbol,this.GroupMagicNumber,this.Group);
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
CHistoryPosition* CHistoryPosition::operator[](const long ticketPar)
{
   if(CheckPointer(this.mObject) == POINTER_INVALID)this.mObject = new CHistoryPosition(this.GroupSymbol,this.GroupMagicNumber,this.Group);
   this.SelectByTicket(ticketPar);
   return this.mObject;
}


//+------------------------------------------------------------------+
//|     check the history range
//+------------------------------------------------------------------+
bool CHistoryPosition::HistoryRange(datetime datePar)
{
   if(datePar >= this.StartDate && datePar <= this.EndDate){
      return true;
   }  
   return false;
}




//+------------------------------------------------------------------+
//|       select a position by index
//+------------------------------------------------------------------+
long CHistoryPosition::SelectByIndex(int indexPar)
{
   //-- Reset the ticket   
   int numberDeals      = 0;
   for (int i = 0; i < OrdersHistoryTotal(); i++){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
		   this.ValidSelection = true;
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))
         { 	
            if(numberDeals == indexPar){
               return OrderTicket();   
            }
            numberDeals++; 
         }
		}else{
         string msgTemp = "The History Position with index "+(string)i+" WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection = false;
      }
	}

	//-- Case when the index is greater than the total positions
	if(indexPar >= numberDeals){
	   string msgTemp    = "The index of selection can NOT be equal or greater than the total history positions. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Positions = "+(string)numberDeals;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|       select a position by ticket
//+------------------------------------------------------------------+
bool CHistoryPosition::SelectByTicket(long ticketPar)
{
   if(OrderSelect((int)ticketPar,SELECT_BY_TICKET,MODE_HISTORY)){   
      this.ValidSelection = true;
      return true;
   }
   else{
      this.ValidSelection = false;
      string msgTemp = "The History Position WAS NOT Selected.";
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
   }
}




//+------------------------------------------------------------------+
//|      get the total positions of group
//+------------------------------------------------------------------+
int CHistoryPosition::GroupTotal()
{
   int totalDeals   = 0;  
   for (int i = OrdersHistoryTotal()-1; i >= 0; i--){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);      
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
		   if(OrderType() == 6)continue; // This type of order is the initial deposit
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))totalDeals++;  		   
		}else{
         string msgTemp = "The History Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return totalDeals; 
}



//+------------------------------------------------------------------+
//|      get the total volume of a group
//+------------------------------------------------------------------+
double CHistoryPosition::GroupTotalVolume(void)
{
   double volumeDeals   = 0;   
   for (int i = OrdersHistoryTotal()-1; i >= 0; i--){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))
            volumeDeals += OrderLots();
		}else{
         string msgTemp = "The History Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumeDeals;   
}


//+------------------------------------------------------------------+
//|      get the total profit of a group
//+------------------------------------------------------------------+
double CHistoryPosition::GroupTotalProfit(void)
{
   double profitTemp = 0;   
   for (int i = OrdersHistoryTotal()-1; i >= 0; i--){
      bool selectedTemp = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
		if (selectedTemp){
		   //-- History Range Check
		   if(!this.HistoryRange(OrderCloseTime()))break;
		   //--
		   if(OrderType() == 6)continue; // This type of order is the initial deposit
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))
               profitTemp += OrderProfit() + OrderSwap() + OrderCommission();
		}else{
         string msgTemp = "The History Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
	return profitTemp;
}

//+------------------------------------------------------------------+
//|      get the ticket of a position
//+------------------------------------------------------------------+
long CHistoryPosition::GetTicket(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderTicket());
  }

//+------------------------------------------------------------------+
//|      get the type of a position
//+------------------------------------------------------------------+
int CHistoryPosition::GetType(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderType());
  }
//+------------------------------------------------------------------+
//|      get the time open of a position
//+------------------------------------------------------------------+
datetime CHistoryPosition::GetTimeOpen(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderOpenTime());
  }
//+------------------------------------------------------------------+
//|      get the time close of a position
//+------------------------------------------------------------------+
datetime CHistoryPosition::GetTimeClose(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderCloseTime());
  }  
//+------------------------------------------------------------------+
//|      get the magic number of a position
//+------------------------------------------------------------------+
long CHistoryPosition::GetMagicNumber(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderMagicNumber());
  }
//+------------------------------------------------------------------+
//|      get the volume of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetVolume(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderLots());
  }
//+------------------------------------------------------------------+
//|     get the price open of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetPriceOpen(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderOpenPrice());
  }
//+------------------------------------------------------------------+
//|     get the price close of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetPriceClose(void)
  {
   if(!this.ValidSelection)return -1;   
   return(OrderClosePrice());
  }
//+------------------------------------------------------------------+
//|     get the commission of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetCommission(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderCommission());
  }
//+------------------------------------------------------------------+
//|      get the swap of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetSwap(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderSwap());
  }
//+------------------------------------------------------------------+
//|      get the profit of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetProfit(void)
  {
   if(!this.ValidSelection)return -1;
   return(OrderProfit());
  }
//+------------------------------------------------------------------+
//|      get the symbol of a position
//+------------------------------------------------------------------+
string CHistoryPosition::GetSymbol(void)
  {
   if(!this.ValidSelection)return "";
   return(OrderSymbol());
  }
//+------------------------------------------------------------------+
//|      get the comment of a position
//+------------------------------------------------------------------+
string CHistoryPosition::GetComment(void)
  {
   if(!this.ValidSelection)return "";
   return(OrderComment());
  }




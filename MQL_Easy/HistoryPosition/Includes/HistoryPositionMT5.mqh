//+------------------------------------------------------------------+
//|                                           HistoryPositionMT5.mqh |
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
   bool                    HistoryRange(void);

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
  }
//+------------------------------------------------------------------+


  
//+------------------------------------------------------------------+
//|                     operator for index                           |
//+------------------------------------------------------------------+
CHistoryPosition* CHistoryPosition::operator[](const int indexPar)
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
CHistoryPosition* CHistoryPosition::operator[](const long ticketPar)
{
   this.SelectByTicket(ticketPar);
   return GetPointer(this);
}





//+------------------------------------------------------------------+
//|     select the history range
//+------------------------------------------------------------------+
bool CHistoryPosition::HistoryRange(void)
{
   if(!HistorySelect(this.StartDate,(this.EndDate == 0) ? TimeCurrent() : this.EndDate)){
      string msgTemp = "HistorySelect function produced an Error";
      this.Error.CreateErrorCustom(msgTemp,true,false,__FUNCTION__);
      return false;
   }  
   return true;
}



//+------------------------------------------------------------------+
//|      select a position by index
//+------------------------------------------------------------------+
long CHistoryPosition::SelectByIndex(int indexPar)
{
   //-- Reset the ticket
   this.mTicket = -1;
   //-- Set History Range
   if(!this.HistoryRange())return-1;   
   
   int numberPositions     = 0;
   for (int i = 0; i < HistoryDealsTotal(); i++){
      long ticketTemp = (long)HistoryDealGetTicket(i);
		if (ticketTemp > 0){
		   this.ValidSelection = true;
         if(this.ValidPosition(HistoryDealGetString(ticketTemp,DEAL_SYMBOL),HistoryDealGetInteger(ticketTemp,DEAL_MAGIC),
                      (int)HistoryDealGetInteger(ticketTemp,DEAL_TYPE)) && HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_IN 
                                 && HistoryDealGetInteger(ticketTemp,DEAL_TYPE) != DEAL_TYPE_BALANCE)
         { 	
            if(numberPositions == indexPar){
               this.mTicket = HistoryDealGetInteger(ticketTemp,DEAL_POSITION_ID);
               return ticketTemp;   
            }
            numberPositions++; 
         }
		}else{
         string msgTemp = "The History Position with index "+(string)i+" WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection           = false;
      }
	}

	//-- Case when the index is greater than the total positions
	if(indexPar >= numberPositions){
	   string msgTemp    = "The index of selection can NOT be equal or greater than the total history deals. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Deals = "+(string)numberPositions;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|      select a position by ticket
//+------------------------------------------------------------------+
bool CHistoryPosition::SelectByTicket(long ticketPar)
{
   //-- Reset the ticket
   this.mTicket = -1;
   if(HistoryDealSelect(ticketPar)){   
      this.mTicket         = ticketPar;
      this.ValidSelection  = true;
      return true;
   }
   else{
      string msgTemp       = "The History Position WAS NOT Selected.";
      this.ValidSelection  = false;
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
   }
}





//+------------------------------------------------------------------+
//|      get the total positions of a Group
//+------------------------------------------------------------------+
int CHistoryPosition::GroupTotal()
{
   int totalPositions   = 0;
   //-- Set History Range
   if(!this.HistoryRange())return totalPositions;   
   
   for (int i = HistoryDealsTotal()-1; i >= 0; i--){
      ulong ticketTemp = HistoryDealGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidPosition(HistoryDealGetString(ticketTemp,DEAL_SYMBOL),HistoryDealGetInteger(ticketTemp,DEAL_MAGIC),
            (int)HistoryDealGetInteger(ticketTemp,DEAL_TYPE)) && HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_IN
                  && HistoryDealGetInteger(ticketTemp,DEAL_TYPE) != DEAL_TYPE_BALANCE)
               totalPositions++;  		   
		}else{
         string msgTemp = "The History Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return totalPositions; 
}



//+------------------------------------------------------------------+
//|      get the total volume of a Group
//+------------------------------------------------------------------+
double CHistoryPosition::GroupTotalVolume(void)
{
   double volumePositions   = 0;
   //-- Set History Range
   if(!this.HistoryRange())return volumePositions;
   
   for (int i = HistoryDealsTotal()-1; i >= 0; i--){
      ulong ticketTemp = HistoryDealGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidPosition(HistoryDealGetString(ticketTemp,DEAL_SYMBOL),HistoryDealGetInteger(ticketTemp,DEAL_MAGIC),
            (int)HistoryDealGetInteger(ticketTemp,DEAL_TYPE)) && HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_IN
                  && HistoryDealGetInteger(ticketTemp,DEAL_TYPE) != DEAL_TYPE_BALANCE)
               volumePositions += HistoryDealGetDouble(ticketTemp,DEAL_VOLUME);  		   
		}else{
         string msgTemp = "The History Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumePositions;   
}


//+------------------------------------------------------------------+
//|      get the total profit of a Group
//+------------------------------------------------------------------+
double CHistoryPosition::GroupTotalProfit(void)
{
   double positionsProfit = 0;
   //-- Set History Range
   if(!this.HistoryRange())return positionsProfit;
   
   for (int i = HistoryDealsTotal()-1; i >= 0; i--){
      ulong ticketTemp = HistoryDealGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidPosition(HistoryDealGetString(ticketTemp,DEAL_SYMBOL),HistoryDealGetInteger(ticketTemp,DEAL_MAGIC),
            (int)HistoryDealGetInteger(ticketTemp,DEAL_TYPE)) && (HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_OUT || HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_OUT_BY)
                  && HistoryDealGetInteger(ticketTemp,DEAL_TYPE) != DEAL_TYPE_BALANCE)
               positionsProfit += HistoryDealGetDouble(ticketTemp,DEAL_PROFIT) + HistoryDealGetDouble(ticketTemp,DEAL_SWAP) 
                  + HistoryDealGetDouble(ticketTemp,DEAL_COMMISSION);  		   
		}else{
         string msgTemp = "The History Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
	return positionsProfit;
}



//+------------------------------------------------------------------+
//|      get the ticket of a position
//+------------------------------------------------------------------+
long CHistoryPosition::GetTicket(void)
  {
   if(!this.ValidSelection)return -1;
   return(this.mTicket);
  }

//+------------------------------------------------------------------+
//|      get the type of a position
//+------------------------------------------------------------------+
int CHistoryPosition::GetType(void)
  {
   if(!this.ValidSelection)return -1;
   int typeTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)typeTemp = (int)HistoryDealGetInteger(ticketTemp,DEAL_TYPE);   
   return(typeTemp);
  }
  
 
//+------------------------------------------------------------------+
//|     get the time open of a position
//+------------------------------------------------------------------+
datetime CHistoryPosition::GetTimeOpen(void)
  {
   if(!this.ValidSelection)return -1;
   datetime timeTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)timeTemp = (datetime)HistoryDealGetInteger(ticketTemp,DEAL_TIME);   
   return(timeTemp);
  }
//+------------------------------------------------------------------+
//|      get the time close of a position
//+------------------------------------------------------------------+
datetime CHistoryPosition::GetTimeClose(void)
  {
   if(!this.ValidSelection)return -1;
   datetime timeTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(HistoryDealsTotal()-1);
   if(ticketTemp > 0)timeTemp = (datetime)HistoryDealGetInteger(ticketTemp,DEAL_TIME);
   return(timeTemp);
  }  
//+------------------------------------------------------------------+
//|      get the magic number of a position
//+------------------------------------------------------------------+
long CHistoryPosition::GetMagicNumber(void)
  {
   if(!this.ValidSelection)return -1;
   int magicTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)magicTemp = (int)HistoryDealGetInteger(ticketTemp,DEAL_MAGIC);
   return(magicTemp);
  }
//+------------------------------------------------------------------+
//|       get the volume of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetVolume(void)
  {
   if(!this.ValidSelection)return -1;
   double volumeTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)volumeTemp = HistoryDealGetDouble(ticketTemp,DEAL_VOLUME);
   return(volumeTemp);
  }
//+------------------------------------------------------------------+
//|      get the price open of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetPriceOpen(void)
  {
   if(!this.ValidSelection)return -1;
   double priceTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)priceTemp = HistoryDealGetDouble(ticketTemp,DEAL_PRICE);
   return(priceTemp);
  }
//+------------------------------------------------------------------+
//|      get the price close of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetPriceClose(void)
  {
   if(!this.ValidSelection)return -1;  
   double priceTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = HistoryDealGetTicket(HistoryDealsTotal()-1);
   if(ticketTemp > 0)priceTemp = HistoryDealGetDouble(ticketTemp,DEAL_PRICE); 
   return(priceTemp);
  }
//+------------------------------------------------------------------+
//|      get the stoploss of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetStopLoss(void)
  {
   if(!this.ValidSelection)return -1;  
   double stopLossTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = -1;
   for(int i = 0; i < HistoryOrdersTotal(); i++){
      ticketTemp = HistoryOrderGetTicket(i);
      if(ticketTemp == this.mTicket)break;
   }
   if(ticketTemp > 0)stopLossTemp = HistoryOrderGetDouble(ticketTemp,ORDER_SL); 
   return(stopLossTemp);
  }
//+------------------------------------------------------------------+
//|      get the takeprofit of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetTakeProfit(void)
  {
   if(!this.ValidSelection)return -1;  
   double takeProfitTemp = -1;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return -1;
   ulong ticketTemp = -1;
   for(int i = 0; i < HistoryOrdersTotal(); i++){
      ticketTemp = HistoryOrderGetTicket(i);
      if(ticketTemp == this.mTicket)break;
   }
   if(ticketTemp > 0)takeProfitTemp = HistoryOrderGetDouble(ticketTemp,ORDER_TP); 
   return(takeProfitTemp);
  }  
//+------------------------------------------------------------------+
//|      get the commission of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetCommission(void)
  {
   if(!this.ValidSelection)return 0;
   double commisionTemp = 0;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return 0;
   for(int i =0; i < HistoryDealsTotal(); i++){
      ulong ticketTemp = HistoryDealGetTicket(i);
      if(ticketTemp > 0)
         {
            commisionTemp += HistoryDealGetDouble(ticketTemp,DEAL_COMMISSION);   
         }
   } 
   return(commisionTemp);
  }
//+------------------------------------------------------------------+
//|      get the swap of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetSwap(void)
  {
   if(!this.ValidSelection)return 0;
   double swapTemp = 0;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return 0;
   for(int i =0; i < HistoryDealsTotal(); i++){
      ulong ticketTemp = HistoryDealGetTicket(i);
      if(ticketTemp > 0)
         {
            swapTemp += HistoryDealGetDouble(ticketTemp,DEAL_SWAP);   
         }
   } 
   return(swapTemp);
  }
//+------------------------------------------------------------------+
//|       get the profit of a position
//+------------------------------------------------------------------+
double CHistoryPosition::GetProfit(void)
  {
   if(!this.ValidSelection)return 0;
   double profitTemp = 0;
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return 0;
   for(int i =0; i < HistoryDealsTotal(); i++){
      ulong ticketTemp = HistoryDealGetTicket(i);
      if(ticketTemp > 0 && (HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_OUT || 
                     HistoryDealGetInteger(ticketTemp,DEAL_ENTRY) == DEAL_ENTRY_OUT_BY))
         {
            profitTemp += HistoryDealGetDouble(ticketTemp,DEAL_PROFIT);   
         }
   }   
   return(profitTemp);
  }
//+------------------------------------------------------------------+
//|       get the symbol of a position
//+------------------------------------------------------------------+
string CHistoryPosition::GetSymbol(void)
  {
   if(!this.ValidSelection)return "";
   string symbolTemp = "";
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return "";
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)symbolTemp = HistoryDealGetString(ticketTemp,DEAL_SYMBOL);
   return(symbolTemp);
  }
//+------------------------------------------------------------------+
//|       get the comment of a position
//+------------------------------------------------------------------+
string CHistoryPosition::GetComment(void)
  {
   if(!this.ValidSelection)return "";
   string commentTemp = "";
   bool selectionTemp = HistorySelectByPosition(this.mTicket);
   if(!selectionTemp)return "";
   ulong ticketTemp = HistoryDealGetTicket(0);
   if(ticketTemp > 0)commentTemp = HistoryDealGetString(ticketTemp,DEAL_SYMBOL);
   return(commentTemp);
  }




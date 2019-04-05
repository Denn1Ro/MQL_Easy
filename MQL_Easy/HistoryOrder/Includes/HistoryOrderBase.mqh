//+------------------------------------------------------------------+
//|                                             HistoryOrderBase.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"



#include "../../Error/Error.mqh"


enum GROUP_HISTORY_ORDERS
{
   GROUP_HISTORY_ORDERS_ALL           = -1,        
   GROUP_HISTORY_ORDERS_BUY_LIMIT     = 2, 
   GROUP_HISTORY_ORDERS_SELL_LIMIT    = 3, 
   GROUP_HISTORY_ORDERS_BUY_STOP      = 4,
   GROUP_HISTORY_ORDERS_SELL_STOP     = 5
};


//+------------------------------------------------------------------+
//|              History Order Class
//+------------------------------------------------------------------+
class CHistoryOrderBase
  {
protected:
   //--
   long                    mTicket;
   string                  GroupSymbol;
   long                    GroupMagicNumber; 
   GROUP_HISTORY_ORDERS    Group;           
   bool                    ValidOrder(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar);
   static bool             ValidSelection;   
   datetime                StartDate;
   datetime                EndDate;
   virtual bool            HistoryRange(void){return false;}
   
public:
   
                           CHistoryOrderBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_ORDERS groupPar = GROUP_HISTORY_ORDERS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0);
                          ~CHistoryOrderBase();
   CError                  Error;                                                               
   //-- Group Config                      
   void                    SetGroupSymbol(string symbolpar){this.GroupSymbol = symbolpar;} 
   void                    SetGroupMagicNumber(long magicNumberPar){this.GroupMagicNumber = magicNumberPar;}
   void                    SetGroup(GROUP_HISTORY_ORDERS groupPar){this.Group = groupPar;}         
   string                  GetGroupSymbol(){return this.GroupSymbol;}
   long                    GetGroupMagicNumber(){return this.GroupMagicNumber;} 
   GROUP_HISTORY_ORDERS    GetGroup(){return this.Group;}  
   void                    SetHistoryRange(datetime startPar,datetime endPar){this.StartDate = startPar;this.EndDate = endPar;}
   //-- Group Properties
   virtual int             GroupTotal(){return -1;}
   virtual double          GroupTotalVolume(){return -1;}      
   //-- History Order Properties        
   virtual long            GetTicket(void){return -1;}
   virtual int             GetType(){return -1;}
   virtual datetime        GetTimeSetUp(){return -1;}
   virtual datetime        GetTimeExpiration(){return -1;}
   virtual double          GetStopLoss(){return -1;}
   virtual double          GetTakeProfit(){return -1;}
   virtual long            GetMagicNumber(void){return -1;}
   virtual double          GetVolume(void){return -1;}
   virtual double          GetPriceOpen(void){return -1;}
   virtual string          GetSymbol(void){return "";}
   virtual string          GetComment(void){return "";}
   //--
   virtual long            SelectByIndex(int indexPar){return -1;}
   virtual bool            SelectByTicket(long ticketPar){return false;}
    
   
  };


//+------------------------------------------------------------------+
//|               Constructor         
//+------------------------------------------------------------------+
CHistoryOrderBase::CHistoryOrderBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_ORDERS groupPar = GROUP_HISTORY_ORDERS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0)
  {
   this.GroupSymbol        = symbolPar;
   this.GroupMagicNumber   = magicNumberPar;
   this.Group              = groupPar;
   this.StartDate          = startDatePar;
   this.EndDate            = (endDatePar == 0) ? TimeCurrent() : endDatePar;
   this.mTicket            = -1;
  }
  

//+------------------------------------------------------------------+
//|               DeCostructor 
//+------------------------------------------------------------------+
CHistoryOrderBase::~CHistoryOrderBase()
  {
  }
  

//+------------------------------------------------------------------+
//|                Initialize static variable                        |
//+------------------------------------------------------------------+
bool CHistoryOrderBase::ValidSelection = false;
  
  
 
//+------------------------------------------------------------------+
//|     check if it is a valid order
//+------------------------------------------------------------------+
bool CHistoryOrderBase::ValidOrder(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar)
{
   bool symbolTemp = (this.GroupSymbol != NULL)                ? (this.GroupSymbol == tradeSymbolPar)      : true;
   bool magicTemp  = (this.GroupMagicNumber != WRONG_VALUE)    ? (this.GroupMagicNumber == tradeMagicPar)  : true;
   bool typeTemp   = false;
   switch(this.Group)
   {
      case GROUP_HISTORY_ORDERS_ALL            : typeTemp = (tradeTypePar == 2 || tradeTypePar == 3 || tradeTypePar == 4 || tradeTypePar == 5); break;
      case GROUP_HISTORY_ORDERS_BUY_LIMIT      : typeTemp = (tradeTypePar == 2); break;
      case GROUP_HISTORY_ORDERS_SELL_LIMIT     : typeTemp = (tradeTypePar == 3); break;
      case GROUP_HISTORY_ORDERS_BUY_STOP       : typeTemp = (tradeTypePar == 4); break;
      case GROUP_HISTORY_ORDERS_SELL_STOP      : typeTemp = (tradeTypePar == 5); break;
   }
   
   return (symbolTemp && magicTemp && typeTemp);
}


//+------------------------------------------------------------------+

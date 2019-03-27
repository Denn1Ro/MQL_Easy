//+------------------------------------------------------------------+
//|                                          HistoryPositionBase.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "../../Error/Error.mqh"


enum GROUP_HISTORY_POSITIONS
{
   GROUP_HISTORY_POSITIONS_ALL           = -1,     
   GROUP_HISTORY_POSITIONS_BUY           = 0,     
   GROUP_HISTORY_POSITIONS_SELL          = 1
};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHistoryPositionBase
  {
protected:
   //--
   long                    mTicket;   
   string                  GroupSymbol;
   long                    GroupMagicNumber; 
   GROUP_HISTORY_POSITIONS Group;              
   bool                    ValidPosition(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar);
   static bool             ValidSelection;   
   datetime                StartDate;
   datetime                EndDate;
   
public:
   
                           CHistoryPositionBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_POSITIONS groupPar = GROUP_HISTORY_POSITIONS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0);
                          ~CHistoryPositionBase(); 
   CError                  Error;                                                             
   //-- Group Config                      
   void                    SetGroupSymbol(string symbolpar){this.GroupSymbol = symbolpar;} 
   void                    SetGroupMagicNumber(long magicNumberPar){this.GroupMagicNumber = magicNumberPar;}
   void                    SetGroup(GROUP_HISTORY_POSITIONS groupPar){this.Group = groupPar;}         
   string                  SetGroupSymbol(){return this.GroupSymbol;}
   long                    SetGroupMagicNumber(){return this.GroupMagicNumber;} 
   GROUP_HISTORY_POSITIONS SetGroup(){return this.Group;}  
   void                    SetHistoryRange(datetime startPar,datetime endPar){this.StartDate = startPar;this.EndDate = endPar;}
   //-- Group Properties
   virtual int             GroupTotal(){return -1;} 
   virtual double          GroupTotalVolume(){return -1;}      
   virtual double          GroupTotalProfit(){return -1;}
   //-- History Order Properties        
   virtual long            GetTicket(void){return -1;}
   virtual int             GetType(){return -1;}
   virtual double          GetStopLoss(){return -1;}
   virtual double          GetTakeProfit(){return -1;}
   virtual datetime        GetTimeOpen(void){return -1;}
   virtual datetime        GetTimeClose(void){return -1;}
   virtual long            GetMagicNumber(void){return -1;}
   virtual double          GetVolume(void){return -1;}
   virtual double          GetPriceOpen(void){return -1;}
   virtual double          GetPriceClose(void){return -1;}
   virtual double          GetCommission(void){return -1;}
   virtual double          GetSwap(void){return -1;}
   virtual double          GetProfit(void){return -1;}
   virtual string          GetSymbol(void){return "";}
   virtual string          GetComment(void){return "";}
   //--
   virtual long            SelectByIndex(int indexPar){return -1;}
   virtual bool            SelectByTicket(long ticketPar){return false;}
   
   
  };
//+------------------------------------------------------------------+
//|                      Constructor
//+------------------------------------------------------------------+
CHistoryPositionBase::CHistoryPositionBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_HISTORY_POSITIONS groupPar = GROUP_HISTORY_POSITIONS_ALL,
                              datetime startDatePar = 0, datetime endDatePar = 0)
  {
   this.GroupSymbol        = symbolPar;
   this.GroupMagicNumber   = magicNumberPar;
   this.Group              = groupPar;
   this.StartDate          = startDatePar;
   this.EndDate            = endDatePar;
   this.mTicket            = -1;
  }
  

//+------------------------------------------------------------------+
//|                       Decostructor                               |
//+------------------------------------------------------------------+
CHistoryPositionBase::~CHistoryPositionBase()
  {
  }
  

//+------------------------------------------------------------------+
//|                Initialize static variable                        |
//+------------------------------------------------------------------+
bool CHistoryPositionBase::ValidSelection = false;
  
  

//+------------------------------------------------------------------+
//|      check if it is a valid position
//+------------------------------------------------------------------+
bool CHistoryPositionBase::ValidPosition(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar)
{
   bool symbolTemp = (this.GroupSymbol != NULL)                ? (this.GroupSymbol == tradeSymbolPar)      : true;
   bool magicTemp  = (this.GroupMagicNumber != WRONG_VALUE)    ? (this.GroupMagicNumber == tradeMagicPar)  : true;
   bool typeTemp   = false;
   switch(this.Group)
   {
      case GROUP_HISTORY_POSITIONS_ALL            : typeTemp = (tradeTypePar == 0 || tradeTypePar == 1); break;
      case GROUP_HISTORY_POSITIONS_BUY            : typeTemp = (tradeTypePar == 0); break;
      case GROUP_HISTORY_POSITIONS_SELL           : typeTemp = (tradeTypePar == 1); break;
   }
   
   return (symbolTemp && magicTemp && typeTemp);
}


//+------------------------------------------------------------------+

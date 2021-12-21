//+------------------------------------------------------------------+
//|                                                 PositionBase.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "../../Utilities/Utilities.mqh"
#include "../../Error/Error.mqh"
#include "../../ValidationCheck/ValidationCheck.mqh"


enum GROUP_POSITIONS
{
   GROUP_POSITIONS_ALL            = -1,     
   GROUP_POSITIONS_BUYS           = 0,     
   GROUP_POSITIONS_SELLS          = 1      
};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPositionBase
  {
protected:       
   string                  GroupSymbol;
   long                    GroupMagicNumber; 
   GROUP_POSITIONS         Group;               
   bool                    ValidPosition(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar);
   static bool             ValidSelection;
   
public:                         
                           CPositionBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_POSITIONS groupPar = GROUP_POSITIONS_ALL);
                          ~CPositionBase();
   CError                  Error;                                                    
   //-- Group Config                      
   void                    SetGroupSymbol(string symbolpar){this.GroupSymbol = symbolpar;} 
   void                    SetGroupMagicNumber(long magicNumberPar){this.GroupMagicNumber = magicNumberPar;}
   void                    SetGroup(GROUP_POSITIONS groupPar){this.Group = groupPar;}         
   string                  GetGroupSymbol(){return this.GroupSymbol;}
   long                    GetGroupMagicNumber(){return this.GroupMagicNumber;} 
   GROUP_POSITIONS         GetGroup(){return this.Group;}  
   //-- Group Properties
   virtual int             GroupTotal(){return -1;} 
   virtual double          GroupTotalVolume(){return -1;}      
   virtual double          GroupTotalProfit(){return -1;} 
   virtual double          GroupTotalNetVolume(){return -1;}    
   virtual double          GroupAverageOpenPrice(){return -1;}  
   virtual double          GroupAveragePositionPrice(){return -1;}  
   virtual double          GroupAverageVolume(){return -1;}    
   virtual void            GroupCloseAll(uint triesPar = 20){return;}
   //-- Position Properties           
   virtual long            GetTicket(){return -1;}
   virtual datetime        GetTimeOpen(){return -1;}
   virtual int             GetType(){return -1;}
   virtual long            GetMagicNumber(){return -1;}
   virtual double          GetVolume(){return -1;}
   virtual double          GetPriceOpen(){return -1;}
   virtual double          GetStopLoss(){return -1;}
   virtual double          GetTakeProfit(){return -1;}
   virtual double          GetSwap(){return -1;}
   virtual double          GetProfit(){return -1;}
   virtual double          GetCommission(){return -1;}
   virtual string          GetSymbol(){return "";}
   virtual string          GetComment(){return "";}
   virtual bool            Close(uint triesPar = 20){return false;}
   virtual bool            ClosePartial(double volumePar,uint triesPar = 20){return false;}
   virtual bool            Modify(double stopLossPar = WRONG_VALUE,double takeProfitPar = WRONG_VALUE, ENUM_SLTP_TYPE sltpPar = SLTP_PRICE){return false;} 
   virtual long            SelectByIndex(int indexPar){return -1;}
   virtual bool            SelectByTicket(long ticketPar){return false;}
   string                  FormatDescription();
  };
//+------------------------------------------------------------------+
//|               Constructor    
//+------------------------------------------------------------------+
CPositionBase::CPositionBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_POSITIONS groupPar = GROUP_POSITIONS_ALL)
{
   this.GroupSymbol        = symbolPar;
   this.GroupMagicNumber   = magicNumberPar;
   this.Group              = groupPar;
}
  
//+------------------------------------------------------------------+
//|               DeConstructor    
//+------------------------------------------------------------------+
CPositionBase::~CPositionBase()
{
}


//+------------------------------------------------------------------+
//|                Initialize static variable                        |
//+------------------------------------------------------------------+
bool CPositionBase::ValidSelection = false;


//+------------------------------------------------------------------+
//|      check if it is a valid position
//+------------------------------------------------------------------+
bool CPositionBase::ValidPosition(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar)
{
   bool symbolTemp = (this.GroupSymbol != NULL)                ? (this.GroupSymbol == tradeSymbolPar)      : true;
   bool magicTemp  = (this.GroupMagicNumber != WRONG_VALUE)    ? (this.GroupMagicNumber == tradeMagicPar)  : true;
   bool typeTemp   = false;
   switch(this.Group)
   {
      case GROUP_POSITIONS_ALL             : typeTemp = (tradeTypePar == 0 || tradeTypePar == 1); break;
      case GROUP_POSITIONS_BUYS            : typeTemp = (tradeTypePar == 0); break;
      case GROUP_POSITIONS_SELLS           : typeTemp = (tradeTypePar == 1); break;
   }
   
   return (symbolTemp && magicTemp && typeTemp);
}



//+------------------------------------------------------------------+
//|     get the description of a position
//+------------------------------------------------------------------+
string CPositionBase::FormatDescription(void)
{  
   if(!this.ValidSelection)return "";
   string descriptionTemp = "Ticket :"       + (string)this.GetTicket()       + "\n";
   descriptionTemp       += "Type :"         + (string)this.GetType()         + "\n";
   descriptionTemp       += "Symbol :"       + this.GetSymbol()               + "\n";
   descriptionTemp       += "MagicNumber :"  + (string)this.GetMagicNumber()  + "\n";
   descriptionTemp       += "Price Open :"   + (string)this.GetPriceOpen()    + "\n";
   descriptionTemp       += "Stop Loss :"    + (string)this.GetStopLoss()     + "\n";
   descriptionTemp       += "Take Profit :"  + (string)this.GetTakeProfit()   + "\n";   
   descriptionTemp       += "Volume :"       + (string)this.GetVolume()       + "\n";
   descriptionTemp       += "Time Open :"    + (string)this.GetTimeOpen()     + "\n";
   descriptionTemp       += "Comment :"      + (string)this.GetComment();          
   return descriptionTemp;
}


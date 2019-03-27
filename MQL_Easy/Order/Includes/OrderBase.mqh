//+------------------------------------------------------------------+
//|                                                    OrderBase.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "../../Utilities/Utilities.mqh"
#include "../../Error/Error.mqh"
#include "../../ValidationCheck/ValidationCheck.mqh"

enum GROUP_ORDERS
{
   GROUP_ORDERS_ALL                = -1,     
   GROUP_ORDERS_BUY_LIMIT          = 2,     
   GROUP_ORDERS_BUY_STOP           = 3,     
   GROUP_ORDERS_SELL_LIMIT         = 4,     
   GROUP_ORDERS_SELL_STOP          = 5     
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COrderBase
  {
protected:              
   string                  GroupSymbol;
   long                    GroupMagicNumber; 
   GROUP_ORDERS            Group;
   bool                    ValidOrder(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar);
   static bool             ValidSelection;
   
public:  
                           COrderBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_ORDERS groupPar = GROUP_ORDERS_ALL);
                          ~COrderBase();
   CError                  Error;                                     
   //-- Group Config                      
   void                    SetGroupSymbol(string symbolpar){this.GroupSymbol = symbolpar;} 
   void                    SetGroupMagicNumber(long magicNumberPar){this.GroupMagicNumber = magicNumberPar;}
   void                    SetGroup(GROUP_ORDERS groupPar){this.Group = groupPar;}         
   string                  GetGroupSymbol(){return this.GroupSymbol;}
   long                    GetGroupMagicNumber(){return this.GroupMagicNumber;} 
   GROUP_ORDERS            GetGroup(){return this.Group;}  
   //-- Group Properties
   virtual int             GroupTotal(){return -1;}  
   virtual double          GroupTotalVolume(){return -1;}
   virtual void            GroupCloseAll(uint triesPar = 20){return;}
   //-- Order Properties                
   virtual long            GetTicket(){return -1;}
   virtual datetime        GetTimeSetUp(){return -1;}
   virtual datetime        GetTimeExpiration(){return -1;}
   virtual int             GetType(){return -1;}   
   virtual long            GetMagicNumber(){return -1;}   
   virtual double          GetVolume(){return -1;}
   virtual double          GetPriceOpen(){return -1;}   
   virtual double          GetStopLoss(){return -1;}
   virtual double          GetTakeProfit(){return -1;}
   virtual string          GetSymbol(){return "";}
   virtual string          GetComment(){return "";}
   virtual bool            Close(uint triesPar = 20){return false;}
   virtual bool            Modify(double priceOpenPar = WRONG_VALUE,double stopLossPar = WRONG_VALUE,double takeProfitPar = WRONG_VALUE,
                                       ENUM_SLTP_TYPE sltpPar = SLTP_PRICE, datetime expirationPar = WRONG_VALUE){return false;}   
   virtual long            SelectByIndex(int indexPar){return -1;}
   virtual bool            SelectByTicket(long ticketPar){return false;}
   string                  FormatDescription();
  };
//+------------------------------------------------------------------+
//|               Constructor                
//+------------------------------------------------------------------+
COrderBase::COrderBase(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_ORDERS groupPar = GROUP_ORDERS_ALL)
{
   this.GroupSymbol       = symbolPar;
   this.GroupMagicNumber  = magicNumberPar;
   this.Group             = groupPar;
}
   
   
//+------------------------------------------------------------------+
//|               DeConstructor      
//+------------------------------------------------------------------+
COrderBase::~COrderBase()
{   
}


//+------------------------------------------------------------------+
//|                Initialize static variable                        |
//+------------------------------------------------------------------+
bool COrderBase::ValidSelection = false;


//+------------------------------------------------------------------+
//|     check if it is a valid order
//+------------------------------------------------------------------+
bool COrderBase::ValidOrder(string tradeSymbolPar,long tradeMagicPar,int tradeTypePar)
{
   bool symbolTemp = (this.GroupSymbol != NULL)                ? (this.GroupSymbol == tradeSymbolPar)      : true;
   bool magicTemp  = (this.GroupMagicNumber != WRONG_VALUE)    ? (this.GroupMagicNumber == tradeMagicPar)  : true;
   bool typeTemp   = false;
   switch(this.Group)
   {
      case GROUP_ORDERS_ALL              : typeTemp = (tradeTypePar == 2 || tradeTypePar == 3 || tradeTypePar == 4 || tradeTypePar == 5); break;
      case GROUP_ORDERS_BUY_LIMIT        : typeTemp = (tradeTypePar == 2); break;
      case GROUP_ORDERS_SELL_LIMIT       : typeTemp = (tradeTypePar == 3); break;
      case GROUP_ORDERS_BUY_STOP         : typeTemp = (tradeTypePar == 4); break;      
      case GROUP_ORDERS_SELL_STOP        : typeTemp = (tradeTypePar == 5); break;
   }
   
   return (symbolTemp && magicTemp && typeTemp);
}

//+------------------------------------------------------------------+
//|       get the description of an order
//+------------------------------------------------------------------+
string COrderBase::FormatDescription(void)
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
   descriptionTemp       += "Time Setup :"   + (string)this.GetTimeSetUp()    + "\n";
   descriptionTemp       += "Comment :"      + (string)this.GetComment();          
   return descriptionTemp;
}



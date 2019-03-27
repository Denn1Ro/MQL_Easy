//+------------------------------------------------------------------+
//|                                                 UtilitiesMT5.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "UtilitiesBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CUtilities : public CUtilitiesBase
  {
private:

public:
                     CUtilities(string symbolPar = NULL);
                    ~CUtilities();
   ENUM_ORDER_TYPE_FILLING FillingOrder();                    
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CUtilities::CUtilities(string symbolPar = NULL) : CUtilitiesBase(symbolPar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CUtilities::~CUtilities()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                       fixFillingOrder                            |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING CUtilities::FillingOrder()
{   
   //-- Find the filling mode
   uint fillingTemp=(uint)SymbolInfoInteger(this.Symbol,SYMBOL_FILLING_MODE);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //-- ORDER_FILLING_FOK
   if((fillingTemp&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK){
      return ORDER_FILLING_FOK;
   }//-- ORDER_FILLING_IOC
   else if((fillingTemp&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC){
      return ORDER_FILLING_IOC;
   }else return ORDER_FILLING_RETURN;
}

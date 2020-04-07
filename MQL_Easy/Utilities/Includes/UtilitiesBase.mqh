//+------------------------------------------------------------------+
//|                                                UtilitiesBase.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "../../Error/Error.mqh"

//+------------------------------------------------------------------+
//|             ENUMS                                                |
//+------------------------------------------------------------------+
//-- Enum for stoploss and takeprofit type
enum ENUM_SLTP_TYPE{
   SLTP_PRICE        = 0,
   SLTP_PIPS         = 1,
   SLTP_POINTS       = 2,
   SLTP_PERCENTAGE   = 3
};


//-- Enum used by the normalizePrice and normalizeVolume functions
enum ENUM_ROUNDING
{
   ROUNDING_OFF = 0,
   ROUNDING_UP = 1,
   ROUNDING_DOWN = 2
};




//+------------------------------------------------------------------+
//|               CUtilitiesBase Class             
//+------------------------------------------------------------------+
class CUtilitiesBase
  {     
protected:
   int               BarsOnChart;
   string            Symbol;

public:   
                     CUtilitiesBase(string symbolPar = NULL);
                    ~CUtilitiesBase();
   CError            Error;                    
   string            GetSymbol() {return this.Symbol;} 
   bool              SetSymbol(string symbolPar);
   bool              CheckSymbol(string symbolPar);                    
   double            Ask();
   double            Bid();
   double            Point();
   long              Digits();
   double            Pip();
   bool              IsNewBar(ENUM_TIMEFRAMES periodPar = PERIOD_CURRENT);
   double            NormalizePrice(double pricePar, ENUM_ROUNDING roundPar = 0);
   double            NormalizeVolume(double lotsPar, ENUM_ROUNDING roundPar = 0);
   ENUM_TIMEFRAMES   TimeframeConvert(int timeframePar);
   bool              SltpConvert(ENUM_SLTP_TYPE sltpPar,int typePar,double openPricePar,double slPar,double tpPar,double &slRef,double &tpRef);
   
  };
  
  
//+------------------------------------------------------------------+
//|               Constructor                                        |
//+------------------------------------------------------------------+
CUtilitiesBase::CUtilitiesBase(string symbolPar = NULL)
{
   this.SetSymbol(symbolPar);
   this.BarsOnChart = 0;
}
   
   
//+------------------------------------------------------------------+
//|               DeConstructor                                      |
//+------------------------------------------------------------------+
CUtilitiesBase::~CUtilitiesBase()
{
}


//+------------------------------------------------------------------+
//|     set the symbol 
//+------------------------------------------------------------------+
bool CUtilitiesBase::SetSymbol(string symbolPar)
{
   this.Symbol = (symbolPar == NULL) ? _Symbol : symbolPar;
   return this.CheckSymbol(this.Symbol);   
}


//+------------------------------------------------------------------+
//|     check if the symbol exist and select it
//+------------------------------------------------------------------+
bool CUtilitiesBase::CheckSymbol(string symbolPar)
{
   bool isSelected = SymbolInfoInteger(symbolPar,SYMBOL_SELECT);
   bool symbolCheck = (!isSelected) ? SymbolSelect(symbolPar,true) : true;
   if(!symbolCheck){
      this.Error.CreateErrorCustom("The symbol "+symbolPar+" doesn't exist.");
      return false;
   }
   return true; 
}


//+------------------------------------------------------------------+
//|    return the ask price
//+------------------------------------------------------------------+
double CUtilitiesBase::Ask(void)
{
   ResetLastError();
   double askTemp = SymbolInfoDouble(this.Symbol,SYMBOL_ASK); 
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //--
   return askTemp; 
}


//+------------------------------------------------------------------+
//|    return the bid price
//+------------------------------------------------------------------+
double CUtilitiesBase::Bid(void)
{
   ResetLastError();
   double bidTemp = SymbolInfoDouble(this.Symbol,SYMBOL_BID); 
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //--
   return bidTemp; 
}


//+------------------------------------------------------------------+
//|    return the digit of the symbol
//+------------------------------------------------------------------+
long CUtilitiesBase::Digits(void)
{
   ResetLastError();
   long digitsTemp = SymbolInfoInteger(this.Symbol,SYMBOL_DIGITS); 
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //--
   return digitsTemp; 
}


//+------------------------------------------------------------------+
//|    return the point 
//+------------------------------------------------------------------+
double CUtilitiesBase::Point(void)
{
   ResetLastError();
   double pointTemp = SymbolInfoDouble(this.Symbol,SYMBOL_POINT); 
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //--
   return pointTemp; 
}


//+------------------------------------------------------------------+
//|               pip                                                |
//+------------------------------------------------------------------+  
double CUtilitiesBase::Pip(void)
{
   ResetLastError();
   ulong digits     = SymbolInfoInteger(this.Symbol,SYMBOL_DIGITS);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //--
   double point   = this.Point();
   if(digits == 5 || digits == 3)return point*10;
   else return point;
}


//+------------------------------------------------------------------+
//|               isNewBar                                           |
//+------------------------------------------------------------------+
bool CUtilitiesBase::IsNewBar(ENUM_TIMEFRAMES periodPar = PERIOD_CURRENT)
{
   int barsTemp = Bars(this.Symbol,periodPar);   
   if(this.BarsOnChart != barsTemp){
      this.BarsOnChart = barsTemp; 
      return true;    
   }
   return false;
}  

  
//+------------------------------------------------------------------+
//|    normalize the price
//+------------------------------------------------------------------+
double CUtilitiesBase::NormalizePrice(double pricePar, ENUM_ROUNDING roundPar = 0)
{
   ResetLastError();
   double tickSize = SymbolInfoDouble(this.Symbol,SYMBOL_TRADE_TICK_SIZE);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //-- check if the value is zero
   if(tickSize == 0)return WRONG_VALUE;
   switch(roundPar)
   {
      case ROUNDING_UP     : return( MathCeil(pricePar/tickSize)*tickSize );
      case ROUNDING_DOWN   : return( MathFloor(pricePar/tickSize)*tickSize );
      default              : return( MathRound(pricePar/tickSize)*tickSize );
   }   
}


//+------------------------------------------------------------------+
//|     normalize the volume of an order
//+------------------------------------------------------------------+
double CUtilitiesBase::NormalizeVolume(double lotsPar, ENUM_ROUNDING roundPar=0)
{
   ResetLastError();
   double lotStep = SymbolInfoDouble(this.Symbol,SYMBOL_VOLUME_STEP);
   //-- check if any error occurs
   if(this.Error.CheckLastError(true,__FUNCTION__))return WRONG_VALUE;
   //-- check if the value is zero
   if(lotStep == 0)return WRONG_VALUE;
   switch(roundPar)
   {
      case ROUNDING_UP     : return( MathCeil(lotsPar/lotStep)*lotStep );
      case ROUNDING_DOWN   : return( MathFloor(lotsPar/lotStep)*lotStep );
      default              : return( MathRound(lotsPar/lotStep)*lotStep );
   }
}


//+------------------------------------------------------------------+
//|     convert period to timeframe
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CUtilitiesBase::TimeframeConvert(int timeframePar)
{
   switch(timeframePar)
   {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      

      default: return(PERIOD_CURRENT);
   }
}


//+------------------------------------------------------------------+
//|      convert sl&tp to price
//+------------------------------------------------------------------+
bool CUtilitiesBase::SltpConvert(ENUM_SLTP_TYPE sltpPar,int typePar,double openPricePar,double slPar,double tpPar,double &slRef,double &tpRef)
{   
   bool result = true;
   double pipTemp    = this.Pip();
   double pointTemp  = this.Point();
   //-- check for the WRONG_VALUE
   if(pipTemp == WRONG_VALUE || pointTemp == WRONG_VALUE)return false;
   //--
   if(typePar == 0 || typePar == 2 || typePar == 4){
      switch(sltpPar){
         case SLTP_PRICE:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0;
            else slRef = slPar;
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = tpPar; 
            break;
         }
         case SLTP_PIPS:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE;
            else if(slPar == 0)slRef = 0;
            else slRef = MathAbs(openPricePar - slPar * pipTemp);
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = openPricePar + tpPar * pipTemp;
            break;
         }
         case SLTP_POINTS:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0;
            else slRef = MathAbs(openPricePar - slPar * pointTemp);
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = openPricePar + tpPar * pointTemp;
            break;
         }
         case SLTP_PERCENTAGE:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0;
            else slRef = MathAbs(openPricePar - this.NormalizePrice(openPricePar * (slPar/100)));
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = openPricePar + this.NormalizePrice(openPricePar * (tpPar/100));
            break;
         }
         default: result = this.Error.CreateErrorCustom("Wrong input on parameter ENUM_SLTP_TYPE = "+EnumToString(sltpPar),false,false,__FUNCTION__);
      }
   }else if(typePar == 1 || typePar == 3 || typePar == 5){
      switch(sltpPar){
         case SLTP_PRICE:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0; 
            else slRef = slPar;
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = tpPar; 
            break;
         }
         case SLTP_PIPS:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0; 
            else slRef = openPricePar + slPar * pipTemp;
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = MathAbs(openPricePar - tpPar * pipTemp);
            break;
         }
         case SLTP_POINTS:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0; 
            else slRef = openPricePar + slPar * pointTemp;
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = MathAbs(openPricePar - tpPar * pointTemp);
            break;
         }
         case SLTP_PERCENTAGE:
         {
            if(slPar == WRONG_VALUE)slRef = WRONG_VALUE; 
            else if(slPar == 0)slRef = 0; 
            else slRef = openPricePar + this.NormalizePrice(openPricePar * (slPar/100));
            if(tpPar == WRONG_VALUE)tpRef = WRONG_VALUE;
            else if(tpPar == 0)tpRef = 0;
            else tpRef = MathAbs(openPricePar - this.NormalizePrice(openPricePar * (tpPar/100))); 
            break;
         }  
         default: result = this.Error.CreateErrorCustom("Wrong input on value ENUM_SLTP_TYPE = "+EnumToString(sltpPar),false,false,__FUNCTION__);
      }
   }else{   
      result = this.Error.CreateErrorCustom("Wrong input on value typePar = "+(string)typePar,false,false,__FUNCTION__);
   }
   //-- Normalize Prices
   slRef = this.NormalizePrice(slRef);
   tpRef = this.NormalizePrice(tpRef);
   return result;
}




//+------------------------------------------------------------------+


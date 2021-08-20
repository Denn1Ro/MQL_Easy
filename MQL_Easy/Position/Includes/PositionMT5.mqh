//+------------------------------------------------------------------+
//|                                                  PositionMT5.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include "PositionBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPosition : public CPositionBase
  {

public:
                           CPosition(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_POSITIONS groupPar = GROUP_POSITIONS_ALL);
                          ~CPosition();
   //-- Group Properties
   virtual int             GroupTotal();  
   virtual double          GroupTotalVolume();      
   virtual double          GroupTotalProfit();   
   virtual double          GroupAverageOpenPrice();  
   virtual void            GroupCloseAll(uint triesPar = 20);
   //-- Position Properties           
   virtual long            GetTicket();
   virtual datetime        GetTimeOpen();
   virtual int             GetType();
   virtual long            GetMagicNumber();
   virtual double          GetVolume();
   virtual double          GetPriceOpen(); 
   virtual double          GetStopLoss();
   virtual double          GetTakeProfit();
   virtual double          GetSwap();
   virtual double          GetProfit();
   virtual double          GetCommission();
   virtual string          GetSymbol();
   virtual string          GetComment();
   virtual bool            Close(uint triesPar = 20);
   virtual bool            ClosePartial(double volumePar,uint triesPar = 20);
   virtual bool            Modify(double stopLossPar = WRONG_VALUE,double takeProfitPar = WRONG_VALUE, ENUM_SLTP_TYPE sltpPar = SLTP_PRICE); 
   virtual long            SelectByIndex(int indexPar);
   virtual bool            SelectByTicket(long ticketPar);                          
   //-- Quick Access
   CPosition*              operator[](const int indexPar);
   CPosition*              operator[](const long ticketPar);                           
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPosition::CPosition(string symbolPar = NULL, long magicNumberPar = WRONG_VALUE, GROUP_POSITIONS groupPar = GROUP_POSITIONS_ALL) 
           :CPositionBase(symbolPar,magicNumberPar,groupPar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPosition::~CPosition()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                     operator for index                           |
//+------------------------------------------------------------------+
CPosition* CPosition::operator[](const int indexPar)
{
   long ticketTemp = this.SelectByIndex(indexPar);
   if(ticketTemp == -1){
      string msgTemp = "The Position with index "+(string)indexPar+" WAS NOT selected.";
      this.Error.CreateErrorCustom(msgTemp);
   }
   return GetPointer(this);
} 


//+------------------------------------------------------------------+
//|                     operator for ticket                          |
//+------------------------------------------------------------------+
CPosition* CPosition::operator[](const long ticketPar)
{
   this.SelectByTicket(ticketPar);
   return GetPointer(this);
}


//+------------------------------------------------------------------+
//|      select a position by index
//+------------------------------------------------------------------+
long CPosition::SelectByIndex(int indexPar)
{
   //-- Check The Margin Mode
   ENUM_ACCOUNT_MARGIN_MODE marginMode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(marginMode == ACCOUNT_MARGIN_MODE_RETAIL_NETTING){
      string nameTemp = PositionGetSymbol(indexPar);
      if(nameTemp == "")return -1;
   }
   //--
   int numberPositions      = 0;
   for (int i = 0; i < PositionsTotal(); i++){
      long ticketTemp = (long)PositionGetTicket(i);
		if (ticketTemp > 0){
		   this.ValidSelection = true; // the selection is valid
         if(this.ValidPosition(PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE))){ 	
            if(numberPositions == indexPar){
               return ticketTemp;   
            }
            numberPositions++; 
         }
		}else{
         string msgTemp = "The Position with index "+(string)i+" WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection = false;
      }
	}

	//-- Case when the index is equal or greater than the total positions
	if(indexPar >= numberPositions){
	   string msgTemp    = "The index of selection can NOT be greater or equal than the total positions. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Positions = "+(string)numberPositions;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|     select a position by ticket
//+------------------------------------------------------------------+
bool CPosition::SelectByTicket(long ticketPar)
{
   if(PositionSelectByTicket(ticketPar)){
      this.ValidSelection = true; // the selection is valid
      return true;
   }
   else{
      string msgTemp = "The Position WAS NOT Selected.";
      return this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      this.ValidSelection = false;
   }
}




//+------------------------------------------------------------------+
//|      get the total positions of a group
//+------------------------------------------------------------------+
int CPosition::GroupTotal()
{
   int totalPositions   = 0;
   for (int i = PositionsTotal()-1; i >= 0; i--){
      ulong ticketTemp = PositionGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidPosition(PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE)))
            totalPositions++;  		   
		}else{
         string msgTemp = "The Position with WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return totalPositions; 
}



//+------------------------------------------------------------------+
//|      get the total volume of a group
//+------------------------------------------------------------------+
double CPosition::GroupTotalVolume(void)
{
   double volumePositions   = 0;
   for (int i = PositionsTotal()-1; i >= 0; i--){
      ulong ticketTemp = PositionGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidPosition(PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE)))
            volumePositions += PositionGetDouble(POSITION_VOLUME);  		   
		}else{
         string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumePositions;   
}


//+------------------------------------------------------------------+
//|     get the total profit of a group
//+------------------------------------------------------------------+
double CPosition::GroupTotalProfit(void)
{
   double profitTemp = 0;
   for (int i = PositionsTotal()-1; i >= 0; i--){
      ulong ticketTemp = PositionGetTicket(i);
		if (ticketTemp > 0){
         if(this.ValidPosition(PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE)))
            profitTemp += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);  		   
		}else{
         string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
	return profitTemp;
}


//+------------------------------------------------------------------+
//|     get the average price of a group
//+------------------------------------------------------------------+
double CPosition::GroupAverageOpenPrice()
{
   double avgPriceTemp   = 0;
   double sumTemp        = 0;   
   double sumVolumeTemp  = 0;
   for(int i = PositionsTotal() - 1; i>=0; i--){
      ulong ticketTemp = PositionGetTicket(i);
      if(ticketTemp > 0){
         if(this.ValidPosition(PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE))){
            int mulTemp     = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
            sumTemp        += mulTemp * PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
            sumVolumeTemp  += mulTemp * PositionGetDouble(POSITION_VOLUME);
         }
      }else{
         string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
   }
   //-- check symbol
   CUtilities utilsTemp;
   if(!utilsTemp.SetSymbol(this.GetGroupSymbol())){this.Error.Copy(utilsTemp.Error);return -1;}
   if(sumVolumeTemp !=0 )avgPriceTemp = utilsTemp.NormalizePrice(MathAbs(sumTemp / sumVolumeTemp));
   return avgPriceTemp;
}


//+------------------------------------------------------------------+
//|      close all positions of a group
//+------------------------------------------------------------------+
void CPosition::GroupCloseAll(uint triesPar = 20)
{
   //-- tries to close a position
   uint triesTemp = 0;
	for (int i=PositionsTotal()-1; i >=0; i--)
	{
	   ulong ticketTemp = PositionGetTicket(i);
		if (ticketTemp > 0)
		{
		   ulong magicTemp = PositionGetInteger(POSITION_MAGIC);
		   string symbolTemp = PositionGetString(POSITION_SYMBOL);
		   ENUM_POSITION_TYPE typeTemp = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
		   if(!this.ValidPosition(symbolTemp,magicTemp,(int)typeTemp))continue;
		   MqlTradeRequest request ={}; 
		   MqlTradeResult result   ={};
			request.action          = TRADE_ACTION_DEAL;        
         request.position        = ticketTemp;          
         request.symbol          = symbolTemp;
         request.volume          = PositionGetDouble(POSITION_VOLUME);                   
         request.deviation       = 5;                       
         request.magic           = magicTemp;
         CUtilities utilsTemp;
         if(!utilsTemp.SetSymbol(symbolTemp)){this.Error.Copy(utilsTemp.Error);return;}
         request.type_filling    = utilsTemp.FillingOrder(); 
         MqlTick tick;
         SymbolInfoTick(symbolTemp,tick);             
         if(typeTemp == POSITION_TYPE_BUY)
           {
            request.price = tick.bid;
            request.type  = ORDER_TYPE_SELL;
           }
         else
           {
            request.price = tick.ask;
            request.type  = ORDER_TYPE_BUY;
           }
		   if(!OrderSend(request,result)){
				string msgTemp = "The Position WAS NOT Closed.";
            this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,"",result.retcode);
            Sleep(1000);
            triesTemp++;
            if(triesTemp >= triesPar)continue;
            i++;
			} 			
		}else{
		   string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
}




//+------------------------------------------------------------------+
//|      get the ticket of a position
//+------------------------------------------------------------------+
long CPosition::GetTicket(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetInteger(POSITION_TICKET);
}  



//+------------------------------------------------------------------+
//|      get the open time of a position
//+------------------------------------------------------------------+
datetime CPosition::GetTimeOpen(void)
{
   if(!this.ValidSelection)return -1;
   return((datetime)PositionGetInteger(POSITION_TIME));
}



//+------------------------------------------------------------------+
//|      get the type of a position
//+------------------------------------------------------------------+
int CPosition::GetType(void)
{
   if(!this.ValidSelection)return -1;
   return((int)PositionGetInteger(POSITION_TYPE));
}


//+------------------------------------------------------------------+
//|      get the magic number of a position
//+------------------------------------------------------------------+
long CPosition::GetMagicNumber(void)
{
   if(!this.ValidSelection)return -1;
   return(PositionGetInteger(POSITION_MAGIC));
}



//+------------------------------------------------------------------+
//|     get the volume of a position
//+------------------------------------------------------------------+
double CPosition::GetVolume(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_VOLUME);
}


//+------------------------------------------------------------------+
//|     get the open price of a position
//+------------------------------------------------------------------+
double CPosition::GetPriceOpen(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_PRICE_OPEN);
}


//+------------------------------------------------------------------+
//|      get the stoploss of a position
//+------------------------------------------------------------------+
double CPosition::GetStopLoss(void) 
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_SL);
}


//+------------------------------------------------------------------+
//|      get the takeprofit of a position
//+------------------------------------------------------------------+
double CPosition::GetTakeProfit(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_TP);
}


//+------------------------------------------------------------------+
//|       get the swap of a position
//+------------------------------------------------------------------+
double CPosition::GetSwap(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_SWAP);
}


//+------------------------------------------------------------------+
//|       get the profit of a position
//+------------------------------------------------------------------+
double CPosition::GetProfit(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_PROFIT);
}


//+------------------------------------------------------------------+
//|       get the commission of a position
//+------------------------------------------------------------------+
double CPosition::GetCommission(void)
{
   if(!this.ValidSelection)return -1;
   return PositionGetDouble(POSITION_COMMISSION);
}


//+------------------------------------------------------------------+
//|       get the symbol of a position
//+------------------------------------------------------------------+
string CPosition::GetSymbol(void)
{
   if(!this.ValidSelection)return "";
   return PositionGetString(POSITION_SYMBOL);
}


//+------------------------------------------------------------------+
//|       get the comment of a position
//+------------------------------------------------------------------+
string CPosition::GetComment(void)
{
   if(!this.ValidSelection)return "";
   return PositionGetString(POSITION_COMMENT);
}


//+------------------------------------------------------------------+
//|       close a position
//+------------------------------------------------------------------+
bool CPosition::Close(uint triesPar = 20)
{
   if(!this.ValidSelection)return false;
   bool status = false;
   for(uint i = 0; i < triesPar; i++)
	{
	   string symbolTemp             = this.GetSymbol();
	   MqlTradeRequest request       = {}; 
	   MqlTradeResult result         = {};
	   ENUM_POSITION_TYPE typeTemp   = (ENUM_POSITION_TYPE)this.GetType();
		request.action                = TRADE_ACTION_DEAL;        
      request.position              = this.GetTicket();          
      request.symbol                = symbolTemp;
      request.volume                = this.GetVolume();                   
      request.deviation             = 5;                       
      request.magic                 = this.GetMagicNumber();
      CUtilities utilsTemp;
      if(!utilsTemp.SetSymbol(symbolTemp)){this.Error.Copy(utilsTemp.Error);return false;}
      request.type_filling          = utilsTemp.FillingOrder();
      MqlTick tick;
      SymbolInfoTick(symbolTemp,tick);             
      if(typeTemp == POSITION_TYPE_BUY)
        {
         request.price = tick.bid;
         request.type  = ORDER_TYPE_SELL;
        }
      else
        {
         request.price = tick.ask;
         request.type  = ORDER_TYPE_BUY;
        }
	   if(!OrderSend(request,result)){
         string msgTemp = "The Position WAS NOT Closed.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,"",result.retcode);
         Sleep(1000);
         //-- Extra Layer Of Safety
         if(!PositionSelectByTicket(this.GetTicket())){
            string msgTemp2 = "The Position WAS NOT Selected.";
            this.Error.CreateErrorCustom(msgTemp2,true,false,(__FUNCTION__));   
            break;
         }
		}else {
		   status = true;
		   break;	
		}
	}
   return status;
}


//+------------------------------------------------------------------+
//|       partial close of a position
//+------------------------------------------------------------------+
bool CPosition::ClosePartial(double volumePar, uint triesPar = 20)
{
   if(!this.ValidSelection)return false;
   bool status = false;
   //-- Check Volume Parameter
   double volumeTemp = this.GetVolume();
   if(volumePar > volumeTemp){
      string msgTemp = "The Position WAS NOT Partial Closed.The Volume parameter ("+(string)+volumePar+") is greater than the Position Volume "+(string)volumeTemp;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      return false;   
   }

   for(uint i = 0; i < triesPar; i++)
	{
	   string symbolTemp             = this.GetSymbol();
	   MqlTradeRequest request       ={}; 
	   MqlTradeResult result         ={};
	   ENUM_POSITION_TYPE typeTemp   = (ENUM_POSITION_TYPE)this.GetType();
		request.action                = TRADE_ACTION_DEAL;        
      request.position              = this.GetTicket();          
      request.symbol                = symbolTemp;
      request.volume                = volumePar;                   
      request.deviation             = 5;                       
      request.magic                 = this.GetMagicNumber();
      CUtilities utilsTemp;
      if(!utilsTemp.SetSymbol(symbolTemp)){this.Error.Copy(utilsTemp.Error);return false;}
      request.type_filling          = utilsTemp.FillingOrder();
      MqlTick tick;
      SymbolInfoTick(symbolTemp,tick);             
      if(typeTemp == POSITION_TYPE_BUY)
        {
         request.price = tick.bid;
         request.type  = ORDER_TYPE_SELL;
        }
      else
        {
         request.price = tick.ask;
         request.type  = ORDER_TYPE_BUY;
        }
	   if(!OrderSend(request,result)){
			string msgTemp = "The Position WAS NOT Closed.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,"",result.retcode);
         Sleep(1000);
         //-- Extra Layer Of Safety
         if(!PositionSelectByTicket(this.GetTicket())){
            string msgTemp2 = "The Position WAS NOT Selected.";
            this.Error.CreateErrorCustom(msgTemp2,true,false,(__FUNCTION__));   
            break;
         }
		}else {
		   status = true;
		   break;	
		}
	}
   return status;
}



//+------------------------------------------------------------------+
//|        modify a position
//+------------------------------------------------------------------+
bool CPosition::Modify(double stopLossPar = WRONG_VALUE,double takeProfitPar = WRONG_VALUE, ENUM_SLTP_TYPE sltpPar = SLTP_PRICE)
{
   if(!this.ValidSelection)return false;
   double stopLossTemp     = 0;
   double takeProfitTemp   = 0;
   string symbolTemp       = this.GetSymbol();
   int   typeTemp          = this.GetType();
   double priceOpenTemp    = this.GetPriceOpen();
   //-- SLTP Convert
   CUtilities utilsTemp;
   if(!utilsTemp.SetSymbol(symbolTemp)){this.Error.Copy(utilsTemp.Error);return false;}
   if(!utilsTemp.SltpConvert(sltpPar,typeTemp,priceOpenTemp,stopLossPar,takeProfitPar,stopLossTemp,takeProfitTemp))
      {this.Error.Copy(utilsTemp.Error);return false;}
   //-- Check the validation of stoploss and takeprofit 
   CValidationCheck validationCheck;   
   if(!validationCheck.CheckStopLossTakeprofit(symbolTemp,(ENUM_ORDER_TYPE)typeTemp,priceOpenTemp,stopLossTemp,takeProfitTemp))
      {this.Error.Copy(validationCheck.Error);return false;}
   //-- set SLTP
   stopLossTemp   = (stopLossPar == WRONG_VALUE)   ? this.GetStopLoss()    : stopLossTemp;  
   takeProfitTemp = (takeProfitPar == WRONG_VALUE) ? this.GetTakeProfit()  : takeProfitTemp;
   //-- Validations
   //-- Check if there is no need to make any modification
   if(!validationCheck.CheckModifyLevels(this.GetTicket(),priceOpenTemp,stopLossTemp,takeProfitTemp,0))
      {this.Error.Copy(validationCheck.Error);return false;}                                                            
   //--- prepare a request 
   MqlTradeRequest request    = {}; 
   request.action             = TRADE_ACTION_SLTP;         
   request.magic              = this.GetMagicNumber();                  
   request.symbol             = symbolTemp;
   request.position           = this.GetTicket();                                             
   request.sl                 = stopLossTemp;                                
   request.tp                 = takeProfitTemp; 
   //-- Filling Position Problem
   request.type_filling       = utilsTemp.FillingOrder();
   //--- send a trade request 
   MqlTradeResult result      = {0};               
   if(!OrderSend(request,result)){
      string msgTemp = "The Position WAS NOT Modified.";
      this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__),0,"",result.retcode);
      return false;        
   }    
   return true;
}





//+------------------------------------------------------------------+
//|                                                  PositionMT4.mqh |
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
//|       select a position by index
//+------------------------------------------------------------------+
long CPosition::SelectByIndex(int indexPar)
{
   int numberPositions      = 0;
   for (int i = 0; i < OrdersTotal(); i++){
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
		   this.ValidSelection = true; // the selection is valid
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType())){ 	
            if(numberPositions == indexPar){
               return OrderTicket();   
            }
            numberPositions++; 
         }
		}else{
         string msgTemp = "The Position with index "+(string)i+" WAS NOT selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         this.ValidSelection = false;
      }
	}

	//-- Case when the index is equal or greater  than the total positions
	if(indexPar >= numberPositions){
	   string msgTemp    = "The index of selection can NOT be greater or equal than the total positions. \n";
	          msgTemp   += "indexPar = "+(string)indexPar+" -- "+"Total Positions = "+(string)numberPositions;
      this.Error.CreateErrorCustom(msgTemp,false,false,(__FUNCTION__));
      this.ValidSelection = false;
	}
   return -1;
}


//+------------------------------------------------------------------+
//|      select a position by ticket
//+------------------------------------------------------------------+
bool CPosition::SelectByTicket(long ticketPar)
{
   if(OrderSelect((int)ticketPar,SELECT_BY_TICKET,MODE_TRADES)){
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
   for (int i = OrdersTotal()-1; i >= 0; i--){
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))
            totalPositions++;  		   
		}else{
         string msgTemp = "The Position WAS NOT Selected.";
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
   for (int i = OrdersTotal()-1; i >= 0; i--){
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))
            volumePositions += OrderLots();
		}else{
         string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
   return volumePositions;   
}


//+------------------------------------------------------------------+
//|      get the total profit of agroup
//+------------------------------------------------------------------+
double CPosition::GroupTotalProfit(void)
{
   double profitTemp = 0;
   for (int i = OrdersTotal()-1; i >= 0; i--){
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType()))
            profitTemp += OrderProfit() + OrderSwap() + OrderCommission();  		   
		}else{
         string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
	}
	return profitTemp;
}


//+------------------------------------------------------------------+
//|      get the average price of a group
//+------------------------------------------------------------------+
double CPosition::GroupAverageOpenPrice()
{
   double avgPriceTemp   = 0;
   double sumTemp        = 0;   
   double sumVolumeTemp  = 0;
   for(int i = OrdersTotal() - 1; i>=0; i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(this.ValidPosition(OrderSymbol(),OrderMagicNumber(),OrderType())){
            int mulTemp     = (OrderType() == OP_BUY) ? 1 : -1;
            sumTemp        += mulTemp * OrderOpenPrice() * OrderLots();
            sumVolumeTemp  += mulTemp * OrderLots();
         }
      }else{
         string msgTemp = "The Position WAS NOT Selected.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      }
   }
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
	for (int i=OrdersTotal()-1; i >=0; i--)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
		   ulong magicTemp   = OrderMagicNumber();
		   string symbolTemp = OrderSymbol();
		   int typeTemp      = OrderType();
		   if(!this.ValidPosition(symbolTemp,magicTemp,typeTemp))continue;
		   color colorTemp   = (typeTemp == ORDER_TYPE_BUY) ? clrRed : clrLime;
		   double priceTemp  = (typeTemp == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbolTemp,SYMBOL_BID) : SymbolInfoDouble(symbolTemp,SYMBOL_ASK);
		   bool resultTemp = OrderClose(OrderTicket(), OrderLots(), SymbolInfoDouble(symbolTemp,SYMBOL_BID), 3, clrRed);//actual Position closing
			if (resultTemp != true)
			{
			   string msgTemp = "The Position WAS NOT Closed.";
            this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
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
   return OrderTicket();
}  



//+------------------------------------------------------------------+
//|     get the open time of a position
//+------------------------------------------------------------------+
datetime CPosition::GetTimeOpen(void)
{
   if(!this.ValidSelection)return -1;
   return((datetime)OrderOpenTime());
}



//+------------------------------------------------------------------+
//|     get the type of a position
//+------------------------------------------------------------------+
int CPosition::GetType(void)
{
   if(!this.ValidSelection)return -1;
   return(OrderType());
}


//+------------------------------------------------------------------+
//|     get the magic number of a position
//+------------------------------------------------------------------+
long CPosition::GetMagicNumber(void)
{
   if(!this.ValidSelection)return -1;
   return(OrderMagicNumber());
}


//+------------------------------------------------------------------+
//|      get the volume of a position
//+------------------------------------------------------------------+
double CPosition::GetVolume(void)
{
   if(!this.ValidSelection)return -1;
   return OrderLots();
}


//+------------------------------------------------------------------+
//|      get the open price of a position
//+------------------------------------------------------------------+
double CPosition::GetPriceOpen(void)
{
   if(!this.ValidSelection)return -1;
   return OrderOpenPrice();
}


//+------------------------------------------------------------------+
//|      get the stoploss of a position
//+------------------------------------------------------------------+
double CPosition::GetStopLoss(void) 
{
   if(!this.ValidSelection)return -1;
   return OrderStopLoss();
}


//+------------------------------------------------------------------+
//|      get the takeprofit of a position
//+------------------------------------------------------------------+
double CPosition::GetTakeProfit(void)
{
   if(!this.ValidSelection)return -1;
   return OrderTakeProfit();
}


//+------------------------------------------------------------------+
//|      get the swap of a position   
//+------------------------------------------------------------------+
double CPosition::GetSwap(void)
{
   if(!this.ValidSelection)return -1;
   return OrderSwap();
}


//+------------------------------------------------------------------+
//|      get the profit of a position
//+------------------------------------------------------------------+
double CPosition::GetProfit(void)
{
   if(!this.ValidSelection)return -1;
   return OrderProfit();
}


//+------------------------------------------------------------------+
//|      get the commission of a position
//+------------------------------------------------------------------+
double CPosition::GetCommission(void)
{
   if(!this.ValidSelection)return -1;
   return OrderCommission();
}


//+------------------------------------------------------------------+
//|       get the symbol of a position
//+------------------------------------------------------------------+
string CPosition::GetSymbol(void)
{
   if(!this.ValidSelection)return "";
   return OrderSymbol();
}


//+------------------------------------------------------------------+
//|      get the comment of a position
//+------------------------------------------------------------------+
string CPosition::GetComment(void)
{
   if(!this.ValidSelection)return "";
   return OrderComment();
}


//+------------------------------------------------------------------+
//|      close a position
//+------------------------------------------------------------------+
bool CPosition::Close(uint triesPar = 20)
{
   if(!this.ValidSelection)return false;
   bool status = false;
   for(uint i = 0; i < triesPar; i++)
	{
	   string symbolTemp             = this.GetSymbol();
	   int typeTemp                  = this.GetType(); 
	   double closePrice             = (typeTemp == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbolTemp,SYMBOL_BID) : SymbolInfoDouble(symbolTemp,SYMBOL_ASK); 
	   color colorTemp               = (typeTemp == ORDER_TYPE_BUY) ? clrRed : clrGreen;         
      bool result = OrderClose((int)this.GetTicket(),this.GetVolume(),closePrice, 3, colorTemp);
	   if (result != true)//if it did not close
      {
	      string msgTemp = "The Position WAS NOT Closed.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         Sleep(1000);
         //-- Extra Layer Of Safety
         if(!OrderSelect((int)this.GetTicket(),SELECT_BY_TICKET,MODE_TRADES)){
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
//|      partial close of a position
//+------------------------------------------------------------------+
bool CPosition::ClosePartial(double volumePar,uint triesPar = 20)
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
	   int typeTemp                  = this.GetType();
	   double closePrice             = (typeTemp == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbolTemp,SYMBOL_BID) : SymbolInfoDouble(symbolTemp,SYMBOL_ASK); 
	   color colorTemp               = (typeTemp == ORDER_TYPE_BUY) ? clrRed : clrGreen;                     
	   bool result = OrderClose((int)this.GetTicket(),volumePar,closePrice, 3, colorTemp);
	   if (result != true)//if it did not close
      {
	      string msgTemp = "The Position WAS NOT Closed.";
         this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
         Sleep(1000);
         //-- Extra Layer Of Safety
         if(!OrderSelect((int)this.GetTicket(),SELECT_BY_TICKET,MODE_TRADES)){
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
//|      modify a position
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
   //-- Check if there is no need to make any modification
   if(!validationCheck.CheckModifyLevels(this.GetTicket(),priceOpenTemp,stopLossTemp,takeProfitTemp))
      {this.Error.Copy(validationCheck.Error);return false;}
   //-- Modify              
   if(!OrderModify((int)this.GetTicket(),priceOpenTemp,stopLossTemp,takeProfitTemp,0,clrBlue)){
      string msgTemp = "The Position WAS NOT Modified.";
      this.Error.CreateErrorCustom(msgTemp,true,false,(__FUNCTION__));
      return false;        
   }    
   return true;
}



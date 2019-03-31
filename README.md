# MQL_Easy
# Intro

MQL_Easy is an open source cross platform library for developing MQL4 and MQL5 applications. The purpose of this library is to make the mql development easy, safe and fast in order to focus more on implementing complex trading ideas. The cross platform property assure that the same piece of code works on both platforms. In addition, it has implemented some unique features that make the development easier and faster. However, it does not cover the entire application-programming interface of the mql5/4 language. The goal is not to replace the entire MQL standard library which metaquotes has nicely implemented; it just fills the gap between the MQL4 and MQL5 programing and simplify the development of trading applications. 

Advantages:
-	Cross platform compatibility(same piece of code works on both platforms)
-	Error handling(all error codes are included with description)
-	Validation checks(build in validation checks for order management)
-	Hides complexity and speed up the development
-	Publishing products on MQL5 market easier and safer.

The library contains the following classes:
-	CExecute
-	CPosition
-	COrder
-	CHistoryPosition
-	CHistoryOrder
-	CUtilities
-	CError
-	CPrinter
-	CValidationCheck

It is important to mention that parts of code are collected from other resources on the internet. The goal is to gather any useful code into a single framework/library. 
The current documentation does not contain the whole functionality of the MQL_Easy framework/library. It will be updated periodically in the future.
Feel free to test, change or customize it to suits your needs better.
If you find any issue/bug/improvement let me know.

# Getting Started	
To start working with the library all you need are 3 steps.
1. Download/clone the folder MQL _Easy.
2. Move it to Include folder inside MQL4 and MQL5 directory. 
3. Copy paste the following command to your current MQL project:

`#include < MQL _Easy\ MQL_ Easy.mqh>`

(The above line of code includes all the library’s files and make them available)


Example:
```
//+------------------------------------------------------------------+
//|                                             MQL_Easy_Example.mq5 |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#include <MQL_Easy/MQL_Easy.mqh>
//-- Object that execute trades
CExecute execute;
//-- Object that manage trades
CPosition position;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //-- Set the symbol and magic number to the objects
   string symbol = _Symbol;
   int magicNumber = 12345;
   execute.SetSymbol(symbol);
   execute.SetMagicNumber(magicNumber);
   position.SetGroupSymbol(symbol);
   position.SetGroupMagicNumber(magicNumber);
   
   //-- Create a trade Position BUY 
   ENUM_TYPE_POSITION type = TYPE_POSITION_BUY;
   double volume = 0.10;
   double stopLoss = 20;
   double takeProfit = 20;    
   execute.Position(type,volume,stopLoss,takeProfit,SLTP_PIPS);
   
   //-- Collect Information about the trade
   if(position.SelectByIndex(0)){
      long ticket       = position.GetTicket();
      double openPrice  = position.GetPriceOpen();  
      Print("#Ticket: "+(string)ticket+", OpenPrice: "+(string)openPrice);    
   }   
   //-- delay for visual purposes
   Sleep(2000);
   //-- Modify the position using quick access feature
   position[0].Modify(50,50,SLTP_PIPS);
   //-- delay for visual purposes
   Sleep(2000);
   //-- Again Modify the position using quick access feature
   position[0].Modify(300,300,SLTP_POINTS);
   //-- delay for visual purposes
   Sleep(2000);
   //-- Close the position
   position[0].Close();  

   
  }
//+------------------------------------------------------------------+
```
#### This example of code is written in MQL5 editor but it runs and works properly on both platforms.



# MQL_Easy.mql
The MQL_ Easy.mqh is an include file that contains all the others includes files.
It is a quick way to get started without necessary know the names of classes. In addition, if the development requires heavy usage of the MQL_Easy library then you can find them all in one place.  
When you get familiar with the library, you will be comfortable to include only the needed classes.

# Code overview
## Structure and design
The MQL_Easy library has as many folders as the implemented classes. Each folder contains an include mql file and another folder called “Includes”. In order to use any class, it is just enough to include the mql include file in your project. The “Includes” folder just contains the implementation of a class for each platform. In some cases, the MQL4 and MQL5 platforms shares exactly the same code. However, in many cases the implementation is different, so the “Includes” folder has three files. One with a suffix “base” which implements the shared code and the others two with suffixes “MT4” and “MT5” for the platform dependent code. Therefore, in this way not only the platform dependent code is in separate file but also it can scale more easily with features which one platform supports and the other not.

## CExecute class
The CExecute class is responsible for trade execution. There are two kind of trades: Position (Buy,Sell) and Order(BuyLimit,SellLimit,BuyStop and SellStop). One time saver feature for this class is the ENUM_SLTP_TYPE enumeration, which the developer can set the type of the Stoploss and Takeprofit values (price,pips,points,percentage). Therefore, with a single line of code the library take care of converting the ENUM_SLTP_TYPE feature into prices, making validation checks in order to ensure that the request for the trade is a valid one before send it to the broker’s server and executes the trade in both platforms. In case of any error, a user-friendly message is displayed with the error code and details in the Expert’s tab. Besides the printed error info, the CExecute class also fills theses details into its own CError object, which the developer can use it to handle these situations, as he want. 

Example:
```
//-- Create an object of CExecute class and set the symbol and magic number
string symbol = _Symbol;
int magicNumber = 12345;
CExecute execute(symbol, magicNumber);
//-- or CExecute* execute = new CExecute(symbol, magicNumber);
//-- Alternative way to set the symbol and magic number
CExecute execute;
execute.SetSymbol(symbol);
execute.SetMagicNumber(magicNumber);
//-- Create a trade Position BUY 
ENUM_TYPE_POSITION type = TYPE_POSITION_BUY;
double volume = 0.10;
double stopLoss = 20;
double takeProfit = 20;    
execute.Position(type,volume,stopLoss,takeProfit,SLTP_PIPS);
//-- Create a trade Order SellStop 
execute.Order(TYPE_ORDER_SELLSTOP,0.10,1.1550,20,20,SLTP_PIPS);
```
## CPosition and COrder class
The CPosition and COrder classes are responsible to manage the active and pending trades of the account, such as collecting information about a trade or close it. With appropriate configuration, the developer can group trades by symbol, magic number, type or all together in order to manipulate these groups of trades easily. In general, the grouping property of the MQL_Easy library saves a lot of time and give the ability to create complex trading ideas with less effort. Another unique feature that these classes has implemented is the “quick access” of trade. With just a single line of code, the developer can retrieve a property of trade such open price, open time etc.
Examples:
```
   //-- create a position object which will group the trades with the same symbol, magic number 
   //-- and type. In this example, the group contains trades of symbol EURUSD, magic number 
   //-- 12345 and type of trade BUY.
   string symbol = ”EURUSD”;
   int magicNumber = 12345;
   CPosition position(symbol,magicNumber, GROUP_POSITIONS_BUYS);
   
   //-- return the total number of active trades with specific symbol, magic number and type, 
   //-- ignoring all the others 
   int totalPositions = position.GroupTotal(); 

   //-- iterate through specific group of trades
   for(int i = 0; i < totalPositions; i++){
      //-- select a position by its index
      if(position.SelectByIndex(i)){
         long ticket = position.GetTicket();
         double openPrice = position.GetPriceOpen();
         datetime openTime = position.GetTimeOpen();
         double profit = position.GetProfit();
         Print("#ticket: "+ticket+", openPrice: "+openPrice+", openTime:  +openTime+", profit:"+profit);
      }else{
         //-- if the position is not selected a default message error with user-friendly description 
         //-- will be displayed in the expert tab
         //-- also, you can retrieve the error information 
         int errorCode = position.Error.GetLastErrorCode();   
         //-- make custom actions      
      }
   }
//-- Examples with group methods
position.GroupTotalProfit(); // returns the total profit of a group 
position.GroupTotalVolume(); // returns the total volume of a group
position.GroupCloseAll(10);  // close all trades of a group. The number 10 is the tries in case of
                             // failure, by default is 20.
//-- Example of quick access by index
double openPrice = position[0].GetPriceOpen();
//-- The above code selects a position of a group with index 0(the first one) and retrieve the 
//-- open price.
//-- Here, it retrieves the open time of the last one.
datetime openTime = position[position.GroupTotal()-1].GetTimeOpen();

//-- Example of quick access by ticket
long ticket = 265748761; //-- the type long is important
double openPrice = position[ticket].GetPriceOpen();
//-- The above code selects a position by ticket number and retrieve the 
//-- open price.
```
*The difference between the “quick access by index” and “quick access by ticket” is the type of variable that is set in the brackets. Integer for indexes and long for tickets.*


## CHistoryPosition and CHistoryOrder class
The CHistoryPosition and CHistoryOrder are responsible for collecting information about active and pending trades in the past. They have the same features such as grouping and quick access as the CPosition and COrder classes. In addition, they have start date and end date in order to specify a time of period as an extra grouping filter. If you not specify the time of period then it will search the entire history of the account.

Example: 
```
CHistoryPosition historyPosition;
historyPosition.SetHistoryRange(D'2019.03.25 00:00:00',TimeCurrent());
for(int i =0; i < historyPosition.GroupTotal(); i++){
   Print("#ticket: "+historyPosition[i].GetTicket()+" time close :
   "+historyPosition[i].GetTimeClose());
   }
//-- The above code prints the ticket and time close of all positions from date 2019.03.25 
//-- 00:00:00 until now.
```



## CUtilities class
The CUtilitities class apply some common useful functions, which a trading application may needs.
Example:
```
CUtilities utils("EURUSD");   
if(utils.IsNewBar(PERIOD_M1)){
    Print("One Minute Passed!!!");
}
```

## CPrinter class
The CPrinter class implements a quick and nice way for custom formatted messages to the terminal. It could be useful for error messages and debugging.

Example:
```
CPrinter printer;   
printer.SetTitle("ATTENTION");
printer.SetContainer("-");
printer.Add("Action For The User","You need to enable Auto Trading!!!");
printer.Add("Steps","Press the Auto Trading Button at the top of the terminal");
printer.Print();
```
The above code display in the Expert’s tab:
```
--------------- ATTENTION --------------- 
Action For The User: You need to enable Auto Trading!!!
Steps: Press the Auto Trading Button at the top of the terminal
--------------- ATTENTION ---------------
```



## CError class
The CError class is responsible for handling the errors. By default, it includes all the available error codes and their description. Therefore, the developer can deals with errors faster or alert the user with meaningful information.

Example:
```
double ask = SymbolInfoDouble("WRONG_SYMBOL",SYMBOL_ASK); //this line produce an error
CError error;
error.CreateErrorCustom("An Error occured!!!",true);
```
The above code will display:
```
--------------- ERROR --------------- 
Message : An Error occured!!!
Error(4301) : Unknown symbol
--------------- ERROR ---------------
```
## CValidationCheck class
The CValidationCheck class implements useful functions for order’s checks and validations. Before a request for a trade send to the server, it is important to pass some checks. Most of them are well known, that is why the CExecute class use them by default. Therefore, it is quite useful to able to use this class in any case it is needed.
Example:
```
//-- Function to check if the volume(lotsize) of a trade is valid
CheckVolumeValue(string symbol, double volume)
//-- Function to check if there is enough available balance for make another trade
CheckMoneyForTrade(string symbol,double volume,ENUM_ORDER_TYPE type)
```

# Final thoughts
The power of any library/framework is not only when it delivers its duties properly but also when it builds a community around it.
The community should lead the MQL_Easy framework as any other open source project. Feel free to contribute in any levels.  

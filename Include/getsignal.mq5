//+------------------------------------------------------------------+
//|                                                  retvalcheck.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                        http://www.linden-it-net.de/Goldesel.html |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "http://www.linden-it-net.de/Goldesel.html"
#property version   "1.00"

#include <Tester\StopAtDate.mqh>

//
enum SIGNAL
  {
   SIG_NONE,
   SIG_BUY,
   SIG_SELL,
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlRates          PriceInfo[];   // Kerzendaten(bars)
int               handleSMA;     // Handle für den SMA
double            bufferSMA[];   // Buffer für den SMA
int               toCopy;        // Anzahl der zu kopierenden Kerzen(bars)
SIGNAL            signalnow;            // Signal

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
/* int OnInit()
  {
//---
   ArraySetAsSeries(PriceInfo,true);                           // Zugriffsart einstellen. Hier wird nix sortiert wie Herr R.B. behauptet
   ArraySetAsSeries(bufferSMA,true);
   signalnow = SIG_NONE; 
   toCopy=3;
   handleSMA = iMA(_Symbol,_Period,20,0,MODE_SMA,PRICE_CLOSE); // Handle für den iMA erzeugen
   if(HandleError(handleSMA,"iMA"))                            // Handle überprüfen 1
      return(false);
   return(INIT_SUCCEEDED);
//--- 
  } */

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

/*
  void OnTick()
  {
   if(StopAtDate.Check("2020.04.01", "00:45"))  // prüfen der Zeit
      DebugBreak();                             // hier hält das Programm an

   CopyRates(_Symbol,_Period,0,toCopy,PriceInfo);
   CopyBuffer(handleSMA,0,   0,toCopy,bufferSMA);

   Print("handleSMA: ",handleSMA);

   //signalnow = Signal();
   //PrintFormat((string)signalnow);
  }
*/  

SIGNAL Signal(void)
  {
  SIGNAL signaltemp = SIG_NONE;
   if((PriceInfo[1].close < bufferSMA[1]) && (PriceInfo[0].close > bufferSMA[0]))
      signaltemp = SIG_BUY;

   if((PriceInfo[1].close > bufferSMA[1]) && (PriceInfo[0].close < bufferSMA[0]))
      signaltemp = SIG_SELL;      

   return(signaltemp);
  }




//+------------------------------------------------------------------+
//| Hilfsfunktionen                                                  |
//+------------------------------------------------------------------+
bool HandleError(int aHandle, string aName)
  {
   if(aHandle==INVALID_HANDLE)
     {
      Alert("*ERROR* creating ",aName," handle.");
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

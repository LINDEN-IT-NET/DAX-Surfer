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
double border1=12900;
double border2=12800;
double downpoints=20;
double uppoints=20;
   
   
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
SIGNAL            signalnow;     // Signal


SIGNAL Signal(void)
  {
  SIGNAL signaltemp = SIG_NONE;
   //if((PriceInfo[0].close > 12420) && (PriceInfo[0].close < 12430))
   if(PriceInfo[0].close > 12420) 
      signaltemp = SIG_BUY;  

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

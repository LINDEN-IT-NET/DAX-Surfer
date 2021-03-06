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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SIGNAL Signal(void)
  {
   SIGNAL signaltemp = SIG_NONE;

   /*if(((PriceInfo[0].close <= border1-downpoints) && (PriceInfo[0].close >12875) && PriceInfo[0].close <= border1) || (((PriceInfo[0].close <= border2-downpoints) && PriceInfo[0].close >12775) && PriceInfo[0].close <= border2))
   //if(((PriceInfo[0].close <= border1-downpoints) && (PriceInfo[0].close >12875) && (PriceInfo[0].close <= border1)) || ((PriceInfo[0].close <= border2-downpoints) && (PriceInfo[0].close >12775)) && (PriceInfo[0].close <= border2))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= border1+uppoints) && (PriceInfo[0].close <12925) && PriceInfo[0].close >= border1) || (((PriceInfo[0].close >= border2+uppoints) && PriceInfo[0].close <12825) && PriceInfo[0].close >= border2))
      signaltemp = SIG_SELL;
     */
   if(((PriceInfo[0].close >= 12901) && (PriceInfo[0].close <12903)) || (((PriceInfo[0].close >= 12801) && PriceInfo[0].close <12803)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12899) && (PriceInfo[0].close >12897)) || (((PriceInfo[0].close <= 12799) && PriceInfo[0].close >12797)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 12301) && (PriceInfo[0].close <12303)) || (((PriceInfo[0].close >= 12401) && PriceInfo[0].close <12403)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12299) && (PriceInfo[0].close >12297)) || (((PriceInfo[0].close <= 12399) && PriceInfo[0].close >12397)))
      signaltemp = SIG_BUY;

   return(signaltemp);
  }



/*
   if(((PriceInfo[0].close <= border1-downpoints) && (PriceInfo[0].close >12875) && PriceInfo[0].close <= border1) || (((PriceInfo[0].close <= border2-downpoints) && PriceInfo[0].close >12775) && PriceInfo[0].close <= border2))
   //if(((PriceInfo[0].close <= border1-downpoints) && (PriceInfo[0].close >12875) && (PriceInfo[0].close <= border1)) || ((PriceInfo[0].close <= border2-downpoints) && (PriceInfo[0].close >12775)) && (PriceInfo[0].close <= border2))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= border1+uppoints) && (PriceInfo[0].close <12925) && PriceInfo[0].close >= border1) || (((PriceInfo[0].close >= border2+uppoints) && PriceInfo[0].close <12825) && PriceInfo[0].close >= border2))
      signaltemp = SIG_SELL;
*/


/* working:
   if(((PriceInfo[0].close <= border1-downpoints) && (PriceInfo[0].close >12875) && PriceInfo[0].close <= border1) || ((PriceInfo[0].close <= border2-downpoints) && (PriceInfo[0].close >12775)) && PriceInfo[0].close <= border2)
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= border1+uppoints) && (PriceInfo[0].close <12925) && PriceInfo[0].close >= border1) || ((PriceInfo[0].close >= border2+uppoints) && (PriceInfo[0].close <12825)) && PriceInfo[0].close >= border2)
      signaltemp = SIG_SELL;
*/




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

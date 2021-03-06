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
     
        if(((PriceInfo[0].close >= 14101) && (PriceInfo[0].close <14103)) || (((PriceInfo[0].close >= 14001) && PriceInfo[0].close <14003)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 14099) && (PriceInfo[0].close >14097)) || (((PriceInfo[0].close <= 13999) && PriceInfo[0].close >13997)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 13901) && (PriceInfo[0].close <13903)) || (((PriceInfo[0].close >= 13801) && PriceInfo[0].close <13803)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 13899) && (PriceInfo[0].close >13897)) || (((PriceInfo[0].close <= 13799) && PriceInfo[0].close >13797)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 13701) && (PriceInfo[0].close <13703)) || (((PriceInfo[0].close >= 13601) && PriceInfo[0].close <13603)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 13699) && (PriceInfo[0].close >13697)) || (((PriceInfo[0].close <= 13599) && PriceInfo[0].close >13597)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 13401) && (PriceInfo[0].close <13403)) || (((PriceInfo[0].close >= 13501) && PriceInfo[0].close <13503)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 13399) && (PriceInfo[0].close >13397)) || (((PriceInfo[0].close <= 13499) && PriceInfo[0].close >13497)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 13201) && (PriceInfo[0].close <13203)) || (((PriceInfo[0].close >= 13301) && PriceInfo[0].close <13303)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 13199) && (PriceInfo[0].close >13197)) || (((PriceInfo[0].close <= 13299) && PriceInfo[0].close >13297)))
      signaltemp = SIG_BUY;


      
     
     
   if(((PriceInfo[0].close >= 13101) && (PriceInfo[0].close <13103)) || (((PriceInfo[0].close >= 13001) && PriceInfo[0].close <13003)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 13099) && (PriceInfo[0].close >13097)) || (((PriceInfo[0].close <= 12999) && PriceInfo[0].close >12997)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 12901) && (PriceInfo[0].close <12903)) || (((PriceInfo[0].close >= 12801) && PriceInfo[0].close <12803)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12899) && (PriceInfo[0].close >12897)) || (((PriceInfo[0].close <= 12799) && PriceInfo[0].close >12797)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 12701) && (PriceInfo[0].close <12703)) || (((PriceInfo[0].close >= 12601) && PriceInfo[0].close <12603)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12699) && (PriceInfo[0].close >12697)) || (((PriceInfo[0].close <= 12599) && PriceInfo[0].close >12597)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 12501) && (PriceInfo[0].close <12503)) || (((PriceInfo[0].close >= 12401) && PriceInfo[0].close <12403)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12499) && (PriceInfo[0].close >12497)) || (((PriceInfo[0].close <= 12399) && PriceInfo[0].close >12397)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 12301) && (PriceInfo[0].close <12303)) || (((PriceInfo[0].close >= 12201) && PriceInfo[0].close <12203)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12299) && (PriceInfo[0].close >12297)) || (((PriceInfo[0].close <= 12199) && PriceInfo[0].close >12197)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 12101) && (PriceInfo[0].close <12103)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 12099) && (PriceInfo[0].close >12097)))
      signaltemp = SIG_BUY;





   if(((PriceInfo[0].close <= 12099) && (PriceInfo[0].close >12097)) || (((PriceInfo[0].close <= 11999) && PriceInfo[0].close >11997)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 11901) && (PriceInfo[0].close <11903)) || (((PriceInfo[0].close >= 11801) && PriceInfo[0].close <11803)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 11899) && (PriceInfo[0].close >11897)) || (((PriceInfo[0].close <= 11799) && PriceInfo[0].close >11797)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 11701) && (PriceInfo[0].close <11703)) || (((PriceInfo[0].close >= 11601) && PriceInfo[0].close <11603)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 11699) && (PriceInfo[0].close >11697)) || (((PriceInfo[0].close <= 11599) && PriceInfo[0].close >11597)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 11501) && (PriceInfo[0].close <11503)) || (((PriceInfo[0].close >= 11401) && PriceInfo[0].close <11403)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 11499) && (PriceInfo[0].close >11497)) || (((PriceInfo[0].close <= 11399) && PriceInfo[0].close >11397)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 11301) && (PriceInfo[0].close <11303)) || (((PriceInfo[0].close >= 11201) && PriceInfo[0].close <11203)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 11299) && (PriceInfo[0].close >11297)) || (((PriceInfo[0].close <= 11199) && PriceInfo[0].close >11197)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 11101) && (PriceInfo[0].close <11103)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 11099) && (PriceInfo[0].close >11097)))
      signaltemp = SIG_BUY;
      
      
      
  

   if(((PriceInfo[0].close >= 10901) && (PriceInfo[0].close <10903)) || (((PriceInfo[0].close >= 10801) && PriceInfo[0].close <10803)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 10899) && (PriceInfo[0].close >10897)) || (((PriceInfo[0].close <= 10799) && PriceInfo[0].close >10797)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 10701) && (PriceInfo[0].close <10703)) || (((PriceInfo[0].close >= 10601) && PriceInfo[0].close <10603)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 10699) && (PriceInfo[0].close >10697)) || (((PriceInfo[0].close <= 10599) && PriceInfo[0].close >10597)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 10501) && (PriceInfo[0].close <10503)) || (((PriceInfo[0].close >= 10401) && PriceInfo[0].close <10403)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 10499) && (PriceInfo[0].close >10497)) || (((PriceInfo[0].close <= 10399) && PriceInfo[0].close >10397)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 10301) && (PriceInfo[0].close <10303)) || (((PriceInfo[0].close >= 10201) && PriceInfo[0].close <10203)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 10299) && (PriceInfo[0].close >10297)) || (((PriceInfo[0].close <= 10199) && PriceInfo[0].close >10197)))
      signaltemp = SIG_BUY;

   if(((PriceInfo[0].close >= 10101) && (PriceInfo[0].close <10103)))
      signaltemp = SIG_SELL;

   if(((PriceInfo[0].close <= 10099) && (PriceInfo[0].close >10097)))
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

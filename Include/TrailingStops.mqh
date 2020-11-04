//+------------------------------------------------------------------+
//|                                                TrailingStops.mqh |
//|                                                             mql5 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "mql5"
#property link      "https://www.mql5.com"

#include <errordescription.mqh>
#include "Trade.mqh"

class CTrailing
{
   protected:
      MqlTradeRequest request;
      
   public:
      MqlTradeResult result;
      bool TrailingStop(string pSymbol, int pTrailPoints, int pMinProfit = 0, int pStep = 10);
}
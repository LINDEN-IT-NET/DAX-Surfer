//+------------------------------------------------------------------+
//|                                             article116_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version "1.00"
//include the class
#include <baba_class.mqh>
#include <lib_cisnewbar.mqh>
#include <Trade\Trade.mqh>
#include <GetPositionProperties.mqh>
#include <Tester\StopAtDate.mqh>
#include <getMomentum1-0.mq5>
#include <Mql5Book/TrailingStops.mqh>

//--- input parameters
//input int      StopLoss=95;      // Stop Loss
int     StopLoss=100;      // Stop Loss
//input int      TakeProfit=145;   // Take Profit
int      TakeProfit=520;   // Take Profit 480 für ver3fachung über 5jahre
//input double   Adx_Min=28.0;     // Minimum ADX Value
double   Adx_Min=28.0;     // Minimum ADX Value
//input int      ADX_Period=76;    // ADX Period
int      ADX_Period=76;    // ADX Period
//input int      MA_Period=40;     // Moving Average Period
 int      MA_Period=20;     // Moving Average Period
 int      MA2_Period=90;
 int      MA3_Period=190;

//input vars for TrailingStop
bool UseTrailingStop=true;
int TrailingStop=10;
int MinimumProfit=240;
int Step=20;

double   SLp=0.2;
double   TPp=0.5;
int      EA_Magic=12345;   // EA Magic Number
double   Lot=100.0;          // Lots to Trade
int      Margin_Chk=0;     // Check Margin before placing trade(0=No, 1=Yes)
double   Trd_percent=15.0; // Percentage of Free Margin To use for Trading

bool Buy_opened = false;
bool Sell_opened=false;
double Profit=0;
datetime checktime;
datetime tradetime;
bool tradetimetrue = false;

//--- Other parameters
int STP,TKP;   // To be used for Stop Loss & Take Profit values
//bool initialstopbt=false;



// Create an object of our class
Cclass object;
CTrade trade;
CTrailing trail;
CisNewBar current_chart; // instance of the CisNewBar class: current chart

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//--- Run Initialize function
   object.doInit(ADX_Period,MA_Period,MA2_Period,MA3_Period);
//--- Set all other necessary variables for our class object
   object.setPeriod(_Period);     // sets the chart period/timeframe
   object.setSymbol(_Symbol);     // sets the chart symbol/currency-pair
   object.setMagic(EA_Magic);    // sets the Magic Number
   object.setadxmin(Adx_Min);    // sets the ADX miniumm value
   object.setLOTS(Lot);          // set the Lots value
   object.setchkMAG(Margin_Chk); // set the margin check variable
   object.setTRpct(Trd_percent); // set the percentage of Free Margin for trade
//--- Let us handle brokers that offers 5 digit prices instead of 4
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---//--- Run UnIntilialize function
   object.doUninit();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//object.getMomentum();
//Print("m_MomentumValue",Cclass::m_MomentumValue);

// check for an entry
//   string Signal=CheckEntry();

// call trade management
//CheckForTick(Signal)


if(current_chart.isNewBar()>0)
     {     
      PrintFormat("New bar: %s",TimeToString(TimeCurrent(),TIME_SECONDS));
      //Print("m_new_bars: ",current_chart.m_new_bars);
     }



//---
   checktime=TimeCurrent();

//tradetime=TimeGMT();
//int tradetime = TimeToString(TimeLocal(),TIME_MINUTES);
#define  HoD(t) ((int)(((t)%86400)/3600))   // Hour of Day 2018.02.03 17:55:56 => (int) 17
   int tradetime = HoD(TimeCurrent());
   if(tradetime > 9)
      tradetimetrue = true;
   else

      tradetimetrue = false;

//  if(StopAtDate.Check("2015.02.20", "18:59"))
//      DebugBreak();   // hier hält das Programm an

//--- Do we have enough bars to work with
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }

// structures where here

   /*
        Let's make sure our arrays values for the Rates is store serially similar to the timeseries array
   */
   ArraySetAsSeries(object.mrate,true);

//--- Get the last price quote using the MQL5 MqlTick Structure
   if(!SymbolInfoTick(_Symbol,object.latest_price))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

//--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,object.mrate)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      return;
     }

//--- EA should only check for new trade if we have a new bar
// lets declare a static datetime variable
   static datetime Prev_time;
// lest get the start time for the current bar (Bar 0)
   datetime Bar_time[1];
// copy time
   Bar_time[0] = object.mrate[0].time;
// We don't have a new bar when both times are the same
   if(Prev_time==Bar_time[0])
     {
      return;
     }
//copy time to static value, save
   Prev_time = Bar_time[0];

//--- Do we have positions opened already?
//bool Buy_opened = false, Sell_opened=false; // variables to hold the result of the opened position

   if(PositionSelect(_Symbol)==true)   // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         Buy_opened = true;  //It is a Buy
        }
      else
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            Sell_opened = true; // It is a Sell
           }
     }
   else
     {
      Buy_opened=false;
      Sell_opened=false;
     }

// Copy the bar close price for the previous bar prior to the current bar, that is Bar 1
   object.setCloseprice(object.mrate[1].close);  // bar 1 close price
//--- Check for Buy position
//+------------------------------------------------------------------+
//| START opening buy position                                       |
//+------------------------------------------------------------------+
   if((Buy_opened==false)&&(Sell_opened==false))
     {
      //if((object.checkBuy()==true)&&(Signal=="buy"))
      if(object.checkBuy()==true)
         //if(Signal=="buy")
        {
         // Do we already have an opened buy position
         double cprice = NormalizeDouble(object.latest_price.ask,_Digits);              // current Ask price
         double stopbt = NormalizeDouble(object.latest_price.ask - STP*_Point,_Digits); // Stop Loss
         double winclosebt = NormalizeDouble(object.latest_price.ask + TKP*_Point,_Digits); // Take profit
         //int    mdev   = 5;                                                    // Maximum deviation
         // place order
         //object.openBuy(ORDER_TYPE_BUY,cprice,stopbt,winclosebt,mdev);
         trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,Lot,cprice,stopbt,winclosebt);  // Open Trade with SL & TP
         //trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,Lot,cprice,0,0);                  // Open Trade w/o SL & TP
         // Bei Trades ohne direkten SL & TP müssen direkt hier SL & TP gesetzt werden
         bool openPosition=PositionSelect(_Symbol);
         Buy_opened=true;
        }
     }

//--- Check for any Sell position
//+------------------------------------------------------------------+
//| START opening sell position                                      |
//+------------------------------------------------------------------+
/*
   if((Buy_opened==false)&&(Sell_opened==false))
     {
      //if((object.checkSell()==true)&&(Signal=="sell"))
      if(object.checkSell()==true)
         //if(Signal=="sell")
        {
         // Do we already have an opened Sell position
         double bprice=NormalizeDouble(object.latest_price.bid,_Digits);                 // Current Bid price
         double stopst = NormalizeDouble(object.latest_price.bid + STP*_Point,_Digits); // Stop Loss
         double winclosest = NormalizeDouble(object.latest_price.bid - TKP*_Point,_Digits); // Take Profit
         //int    bdev=10;                                                         // Maximum deviation
         // place order
         trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,Lot,bprice,stopst,winclosest); // Open Trade with SL & TP
         //trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,Lot,bprice,0,0);    // Open Trade w/o SL & TP
         // Bei Trades ohne direkten SL & TP müssen direkt hier SL & TP gesetzt werden
         bool openPosition=PositionSelect(_Symbol);
         Sell_opened=true;
        }
     }
*/

// TrailingStop eins für buy & sell

   if(UseTrailingStop==true && PositionType(_Symbol)!=-1)
     {
      trail.TrailingStop(_Symbol,TrailingStop,MinimumProfit,Step);
     }

  }
//+------------------------------------------------------------------+

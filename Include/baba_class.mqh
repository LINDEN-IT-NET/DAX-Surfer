//+------------------------------------------------------------------+
//|                                             article116_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <lib_cisnewbar.mqh>

//+------------------------------------------------------------------+
//| CLASS DECLARATION                                                |
//+------------------------------------------------------------------+
class Cclass
  {
   //--- private members
private:
   int               Magic_No;   // Expert Magic Number
   int               Chk_Margin; // Margin Check before placing trade? (1 or 0)
   double            LOTS;       // Lots or volume to Trade
   double            TradePct;   // Percentage of Account Free Margin to trade
   double            ADX_min;    // ADX Minimum value
   int               ADX_handle; // ADX Handle
   int               MA_handle;  // Moving Average Handle
   int               MA2_handle;  // Moving Average Handle2
   int               MA3_handle;  // Moving Average Handle3
   double            plus_DI[];  // array to hold ADX +DI values for each bars
   double            minus_DI[]; // array to hold ADX -DI values for each bars
   double            MA_val[];   // array to hold Moving Average values for each bars
   double            MA2_val[];   // array to hold Moving Average2 values for each bars
   double            MA3_val[];   // array to hold Moving Average3 values for each bars
   double            ADX_val[];  // array to hold ADX values for each bars
   double            Closeprice; // variable to hold the previous bar closed price
   MqlTradeRequest   trequest;    // MQL5 trade request structure to be used for sending our trade requests
   MqlTradeResult    tresult;     // MQL5 trade result structure to be used to get our trade results
   string            symbol;     // variable to hold the current symbol name
   ENUM_TIMEFRAMES   period;      // variable to hold the current timeframe value
   string            Errormsg;   // variable to hold our error messages
   int               Errcode;    // variable to hold our error codes
   CisNewBar         current_chart_inclass; // instance of the CisNewBar class: current chart




   //--- Public member/functions
public:
   void              Cclass();                                 //Class Constructor
   void              setSymbol(string syb) {symbol = syb;}        //function to set current symbol
   void              setPeriod(ENUM_TIMEFRAMES prd) {period = prd;} //function to set current symbol timeframe/period
   void              setCloseprice(double prc) {Closeprice=prc;}  //function to set prev bar closed price
   void              setchkMAG(int mag) {Chk_Margin=mag;}         //function to set Margin Check value
   void              setLOTS(double lot) {LOTS=lot;}              //function to set The Lot size to trade
   void              setTRpct(double trpct) {TradePct=trpct/100;}  //function to set Percentage of Free margin to use for trading
   void              setMagic(int magic) {Magic_No=magic;}        //function to set Expert Magic number
   void              setadxmin(double adx) {ADX_min=adx;}         //function to set ADX Minimum values

   void              doInit(int adx_period,int ma1_period, int ma2_period, int ma3_period);         //function to be used at our EA intialization
   void              doUninit();                                  //function to be used at EA de-initializatio
   bool              checkBuy();                                  //function to check for Buy conditions
   bool              checkSell();                                 //function to check for Sell conditions
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment="");   //function to open Buy positions
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment="");  //function to open Sell positions
   void              setinitialsetbt(double pStopLoss, double pwinpips);
   void              check4winbt(double cprice, double pwinpips);
   void              setinitialsetst(double pStopLoss, double pwinpips);
   void              check4winst(double bprice, double pwinpips);
   void              trailStopBuy(double cprice, double pprofit);
   void              trailStopSell(double bprice, double pprofit);

   double            Cclass::getMomentum();
   static double     m_MomentumValue;
   static int        m_macd_handle;
   double            m_macdArray[];
   // hardcode Fibo-levels
   static double            fibo100;
   static double            fibo61;
   static double            fibo50;
   static double            fibo38;
   static double            fibo23;
   static double            fibo0;
   static double            fibo100_borderup;
   static double            fibo61_borderup;
   static double            fibo50_borderup;
   static double            fibo38_borderup;
   static double            fibo23_borderup;
   static double            fibo0_borderup;
   static double            fibo100_borderdown;
   static double            fibo61_borderdown;
   static double            fibo50_borderdown;
   static double            fibo38_borderdown;
   static double            fibo23_borderdown;
   static double            fibo0_borderdown;

   //--- Define some MQL5 Structures we will use for our trade
   MqlTick           latest_price;      // To be used for getting recent/latest price quotes
   MqlRates          mrate[];          // To be used to store the prices, volumes and spread of each bar



   //+------------------------------------------------------------------+

   //--- Protected members
protected:
   void              showError(string msg, int ercode);   //function for use to display error messages
   void              getBuffers();                       //function for getting Indicator buffers
   bool              MarginOK();                         //function to check if margin required for lots is OK

  };   // end of class declaration

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Cclass::m_MomentumValue=0;
int Cclass::m_macd_handle=0;
// hardcode Fibo-levels
double            Cclass::fibo100=319.045;
double            Cclass::fibo61=298.435;
double            Cclass::fibo50=292.015;
double            Cclass::fibo38=285.708;
double            Cclass::fibo23=277.824;
double            Cclass::fibo0=265.098;
double            Cclass::fibo100_borderup=322.045;
double            Cclass::fibo61_borderup=301.435;
double            Cclass::fibo50_borderup=295.015;
double            Cclass::fibo38_borderup=288.708;
double            Cclass::fibo23_borderup=280.824;
double            Cclass::fibo0_borderup=268.098;
double            Cclass::fibo100_borderdown=316.045;
double            Cclass::fibo61_borderdown=295.435;
double            Cclass::fibo50_borderdown=289.015;
double            Cclass::fibo38_borderdown=282.708;
double            Cclass::fibo23_borderdown=274.824;
double            Cclass::fibo0_borderdown=262.098;

//+------------------------------------------------------------------+
// Definition of our Class/member functions
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  This CLASS CONSTRUCTOR
//|  *Does not have any input parameters
//|  *Initilizes all the necessary variables
//+------------------------------------------------------------------+
void Cclass::Cclass()
  {
//initialize all necessary variables
   ZeroMemory(trequest);
   ZeroMemory(tresult);
   ZeroMemory(ADX_val);
   ZeroMemory(MA_val);
   ZeroMemory(MA2_val);
   ZeroMemory(MA3_val);
   ZeroMemory(plus_DI);
   ZeroMemory(minus_DI);
   ZeroMemory(m_macdArray);
   Errormsg="";
   Errcode=0;
  }

//+------------------------------------------------------------------+
//|  SHOWERROR FUNCTION
//|  *Input Parameters - Error Message, Error Code
//+------------------------------------------------------------------+
void Cclass::showError(string msg,int ercode)
  {
   Alert(msg,"-error:",ercode,"!!"); // display error
  }

//+------------------------------------------------------------------+
//|  GETBUFFERS FUNCTION
//|  *No input parameters
//|  *Uses the class data members to get indicator's buffers
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Cclass::getBuffers()
  {
// CopyBuffer(m_macd_handle,0,0,3,m_macdArray)
   if(CopyBuffer(ADX_handle,0,0,3,ADX_val)<0 || CopyBuffer(ADX_handle,1,0,3,plus_DI)<0
      || CopyBuffer(ADX_handle,2,0,3,minus_DI)<0 || CopyBuffer(MA_handle,0,0,3,MA_val)<0
      || CopyBuffer(MA2_handle,0,0,3,MA2_val)<0 || CopyBuffer(MA3_handle,0,0,3,MA3_val)<0)
     {
      Errormsg="Error copying indicator Buffers";
      Errcode = GetLastError();
      showError(Errormsg,Errcode);
     }
  }


//+------------------------------------------------------------------+
//|  MARGINOK FUNCTION
//| *No input parameters
//| *Uses the Class data members to check margin required to place a trade
//|  with the lot size is ok
//| *Returns TRUE on success and FALSE on failure
//+------------------------------------------------------------------+
bool Cclass::MarginOK()
  {
   double one_lot_price;                                                        //Margin required for one lot
   double act_f_mag     = AccountInfoDouble(ACCOUNT_FREEMARGIN);                //Account free margin
   long   levrage       = AccountInfoInteger(ACCOUNT_LEVERAGE);                 //Leverage for this account
   double contract_size = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //Total units for one lot
   string base_currency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);        //Base currency for currency pair
//
   if(base_currency=="USD")
     {
      one_lot_price=contract_size/levrage;
     }
   else
     {
      double bprice= SymbolInfoDouble(symbol,SYMBOL_BID);
      one_lot_price=bprice*contract_size/levrage;
     }
// Check if margin required is okay based on setting
   if(MathFloor(LOTS*one_lot_price)>MathFloor(act_f_mag*TradePct))
     {
      return(false);
     }
   else
     {
      return(true);
     }
  }

//+-----------------------------------------------------------------------+
// OUR PUBLIC FUNCTIONS                                                   |
//+-----------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DOINIT FUNCTION
//| *Takes the ADX indicator's Period and Moving Average indicator's
//| period as input parameters
//| *To be used in the OnInit() function of our EA
//+------------------------------------------------------------------+
void Cclass::doInit(int adx_period,int ma_period, int ma2_period, int ma3_period)
  {
//-- Get handle for MACD
   m_macd_handle = iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE);
//--- Get handle for ADX indicator
   ADX_handle=iADX(symbol,period,adx_period);
//--- Get the handle for Moving Average indicator
   MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
   MA2_handle=iMA(symbol,period,ma2_period,0,MODE_EMA,PRICE_CLOSE);
   MA3_handle=iMA(symbol,period,ma3_period,0,MODE_EMA,PRICE_CLOSE);
//--- What if handle returns Invalid Handle
   if(ADX_handle<0 || MA_handle<0 || MA2_handle<0 || MA3_handle<0 || m_macd_handle<0)
     {
      Errormsg="Error Creating Handles for indicators";
      Errcode=GetLastError();
      showError(Errormsg,Errcode);
     }
// Set Arrays as series
// the ADX values arrays
   ArraySetAsSeries(ADX_val,true);
// the +DI value arrays
   ArraySetAsSeries(plus_DI,true);
// the -DI value arrays
   ArraySetAsSeries(minus_DI,true);
// the MA values arrays
   ArraySetAsSeries(MA_val,true);
   ArraySetAsSeries(MA2_val,true);
   ArraySetAsSeries(MA3_val,true);
  }

//+------------------------------------------------------------------+
//|  DOUNINIT FUNCTION
//|  *No input parameters
//|  *Used to release ADX and MA indicators handleS                  |
//+------------------------------------------------------------------+
void Cclass::doUninit()
  {
//--- Release our indicator handles
   IndicatorRelease(ADX_handle);
   IndicatorRelease(MA_handle);
   IndicatorRelease(MA2_handle);
   IndicatorRelease(MA3_handle);
  }

//+------------------------------------------------------------------+
//| CHECKBUY FUNCTION
//| *No input parameters
//| *Uses the class data members to check for Buy setup based on the
//|  the defined trade strategy
//| *Returns TRUE if Buy conditions are met or FALSE if not met
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Cclass::checkBuy()
  {
   /*
       Check for a Long/Buy Setup : MA increasing upwards,
       previous price close above MA, ADX > ADX min, +DI > -DI
   */
   getBuffers();
//--- Declare bool type variables to hold our Buy Conditions
//bool Buy_Condition_1=(MA_val[0]>MA_val[1]) && (MA_val[1]>MA_val[2]); // MA Increasing upwards
//bool Buy_Condition_2=(MA2_val[0]>MA2_val[1]) && (MA2_val[1]>MA2_val[2]); // MA2 Increasing upwards
//bool Buy_Condition_3=(MA3_val[0]>MA3_val[1]) && (MA3_val[1]>MA3_val[2]); // MA3 Increasing upwards
   bool Buy_Condition_4=(MA_val[0]>MA2_val[0]) && (MA2_val[0]>MA3_val[0]); // MA > MA2 > MA3
//bool Buy_Condition_5=(Closeprice>MA_val[1]);         // previous price closed above MA
//bool Buy_Condition_3=(m_macdArray[0]<0);
   bool Buy_Condition_5=(ADX_val[0]>ADX_min);          // Current ADX value greater than minimum ADX value
//bool Buy_Condition_4=(plus_DI[0]>minus_DI[0]);       // +DI greater than -DI
// bool Buy_Condition_5=iMomentum>100;
   bool Buy_Condition_6=((latest_price.ask>=fibo23 && latest_price.ask<fibo23_borderup) || (latest_price.ask>=fibo38  && latest_price.ask<fibo38_borderup) || (latest_price.ask>=fibo50 && latest_price.ask<fibo50_borderup)
                         || (latest_price.ask>=fibo61 && latest_price.ask<fibo61_borderup) || (latest_price.ask>=fibo100 && latest_price.ask<fibo100_borderup));



//--- Putting all together
   /* if(current_chart_inclass.isNewBar()>0)
      {
       PrintFormat("New bar aus checkBuy: %s",TimeToString(TimeCurrent(),TIME_SECONDS));
       //Print("m_new_bars: ",current_chart.m_new_bars);
      }
      */
   if(Buy_Condition_4 && Buy_Condition_6 && (current_chart_inclass.isNewBar()>0))
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }

//+------------------------------------------------------------------+
//| CHECKSELL FUNCTION
//| *No input parameters
//| *Uses the class data members to check for Sell setup based on the
//|  the defined trade strategy
//| *Returns TRUE if Sell conditions are met or FALSE if not met
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Cclass::checkSell()
  {
   /*
       Check for a Short/Sell Setup : MA decreasing downwards,
       previous price close below MA, ADX > ADX min, -DI > +DI
   */
   getBuffers();
//--- Declare bool type variables to hold our Sell Conditions
//bool Sell_Condition_1=(MA_val[0]<MA_val[1]) && (MA_val[1]<MA_val[2]);  // MA decreasing downwards
//bool Sell_Condition_2=(MA2_val[0]<MA2_val[1]) && (MA2_val[1]<MA2_val[2]); // MA2 Increasing upwards
//bool Sell_Condition_3=(MA3_val[0]<MA3_val[1]) && (MA3_val[1]<MA3_val[2]); // MA3 Increasing upwards
   bool Sell_Condition_4=(MA_val[0]<MA2_val[0]) && (MA2_val[0]<MA3_val[0]); // MA < MA2 < MA3
//bool Sell_Condition_5=(Closeprice <MA_val[1]);                         // Previous price closed below MA
//bool Sell_Condition_3=(m_macdArray[0]>0.004);

   bool Sell_Condition_5=(ADX_val[0]>ADX_min);                            // Current ADX value greater than minimum ADX
//bool Sell_Condition_4=(plus_DI[0]<minus_DI[0]);                        // -DI greater than +DI
   bool Sell_Condition_6=((latest_price.ask<=fibo23 && latest_price.ask>fibo23_borderdown) || (latest_price.ask<=fibo38  && latest_price.ask>fibo38_borderdown) || (latest_price.ask<=fibo50 && latest_price.ask>fibo50_borderdown)
                         || (latest_price.ask<=fibo61 && latest_price.ask>fibo61_borderdown) || (latest_price.ask<=fibo100 && latest_price.ask>fibo100_borderdown));

//--- Putting all together
   if(Sell_Condition_4 && Sell_Condition_6  && (current_chart_inclass.isNewBar()>0))
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }

//+------------------------------------------------------------------+
//| OPENBUY FUNCTION
//| *Has Input parameters - order type, Current ASK price, Stop Loss,
//|  Take Profit, deviation, comment
//| *Checks account free margin before pacing trade if trader chooses
//| *Alerts of a success if position is opened or shows error
//+-----------------------------------------------------------------+
void Cclass::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
  {
//--- do check Margin if enabled
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "You do not have enough money to open this Position!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=askprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_FOK;
         // send
         bool reqsend = OrderSend(trequest,tresult);
         // check result
         if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed
           {
            Alert("A Buy order has been successfully placed with Ticket#:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "The Buy order request could not be completed";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=askprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_FOK;
      //--- send
      bool reqsend = OrderSend(trequest,tresult);
      //--- check result
      if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed
        {
         Alert("A Buy order has been successfully placed with Ticket#:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Buy order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }

//+------------------------------------------------------------------+
//| OPENSELL FUNCTION
//| *Has Input parameters - order type, Current BID price, Stop Loss,
//|  Take Profit, deviation, comment
//| *Checks account free margin before pacing trade if trader chooses
//| *Alerts of a success if position is opened or shows error
//+------------------------------------------------------------------+
void Cclass::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
  {
//--- do check Margin if enabled
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "You do not have enough money to open this Position!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=bidprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_FOK;
         // send
         bool reqsend = OrderSend(trequest,tresult);
         // check result
         if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed
           {
            Alert("A Sell order has been successfully placed with Ticket#:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "The Sell order request could not be completed";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=bidprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_FOK;
      //--- send
      bool reqsend = OrderSend(trequest,tresult);
      //--- check result
      if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed
        {
         Alert("A Sell order has been successfully placed with Ticket#:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Sell order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }


// ------------------------------------------------------------------------------------




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Cclass::getMomentum()
  {
// create array for several prices
   double myPriceArray[];

// define properties of the momentum EA
   int iMomentumDefinition=iMomentum(_Symbol,_Period,14,PRICE_CLOSE);

// sort price array from the current candle downwards
   ArraySetAsSeries(myPriceArray,true);

// defined MA1, one line, current candle, 3 candles, store result
   CopyBuffer(iMomentumDefinition,0,0,14,myPriceArray);

// get value of current candle
//double MomentumValue=NormalizeDouble(myPriceArray[0],2);
   m_MomentumValue=NormalizeDouble(myPriceArray[0],2);
   return(m_MomentumValue);

// chart output depending on value
//if (myMomentumValue >100.0)Comment("Strong Momentum: ",myMomentumValue);
//if (myMomentumValue <99.9)Comment("Weak Momentum: ",myMomentumValue);
//if((myMomentumValue >99.9)&&(myMomentumValue>100.00))
//Comment(" ", myMomentumValue);
  }

//+------------------------------------------------------------------+

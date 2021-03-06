//+------------------------------------------------------------------+
//|                                                         EA_1.mq5 |
//|                                                    LINDEN-IT-NET |
//|                                             https://www.mql5.com |
//+----MT5|Expert!5--------------------------------------------------------------+
#property copyright "LINDEN-IT-NET; mql5.com username >>lindomatic<<; thanks to Chris70!!!"
#property   version       "1.0"
#include <Trade\Trade.mqh>
#include <Tester\StopAtDate.mqh>
#include <getsignal-dax.mq5>
//#include <Mql5Book\Trade.mqh>

CTrade trade;


//+------------------------------------------------------------------+
//| BarTime/NewBar handling                                          |
//+------------------------------------------------------------------+
bool CheckBarTime(void)     // check BarTime/NewBar
  {
   datetime barTime=iTime(_Symbol,_Period,0);
   if(BarsTime==-1)
      BarsTime=barTime;
   if(barTime==BarsTime)
      NewBar=false;
   else
     {
      NewBar=true;
      BarsTime=barTime;
      BarsIndex++;
     }
   return(NewBar);
  }

/*
bool IsNewBar(void)         // check if new bar
  {
   return(NewBar);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NoNewBar(void)         // check no new bar
  {
   return(!NewBar);
  }
*/


//+------------------------------------------------------------------+
//| global scope                                                     |
//+------------------------------------------------------------------+
bool initialized=false;
bool glBuyPlaced=false;
bool glSellPlaced=false;
bool glTradePlaced=false;
bool glTradeClosed=false;
int elements=10;
MqlTick bid_base;
MqlTick tick_array[10];
MqlTick new_tick[1];
int iterations=0;
double basetick;

// history variables
input    int days=1;            // Umfang der Handelshistorie in Tagen
//--- Setzen der Grenzen für die Handelshistorie in globaler Umgebung
datetime     start;             // Anfangsdatum der Handelshistorie im Cache
datetime     end;               // Enddatum der Handelshistorie im Cache
//--- Globale Zähler
int          orders;            // Anzahl der aktiven Aufträge
int          positions;         // Anzahl der offenen Positionen
int          deals;             // Anzahl der Deals in der Handelshistorie im Cache
int          history_orders;    // Anzahl der Aufträge in der Handelshistorie
bool         started=false;     // Flag der Relevanz des Zählers

// position variables
long                 pos_magic=0;         // Magic number
string               pos_symbol="";       // Symbol
string               pos_comment="";      // Comment
double               pos_swap=0.0;        // Swap
double               pos_commission=0.0;  // Commission
double               pos_oprice=0.0;      // Current price of the position
double               pos_cprice=0.0;      // Current price of the position
double               pos_profit=0.0;      // Profit/Loss of the position
double               pos_volume=0.0;      // Position volume
double               pos_sl=0.0;          // Stop Loss of the position
double               pos_tp=0.0;          // Take Profit of the position
datetime             pos_time=NULL;       // Position opening time
long                 pos_id=0;            // Position identifier
ENUM_POSITION_TYPE   pos_type=NULL;       // Position type
double               pos_diffoc=0.0;      // Diff open zu current
ulong                ticket=-1;           // order/ticket number


//---

//+------------------------------------------------------------------+
//| GETTING SYMBOL PROPERTIES                                        |
//+------------------------------------------------------------------+
//bool openPosition = PositionSelect(_Symbol);
void GetPositionProperties()
  {
   pos_symbol     =PositionGetString(POSITION_SYMBOL);
   pos_comment    =PositionGetString(POSITION_COMMENT);
   pos_magic      =PositionGetInteger(POSITION_MAGIC);
   pos_oprice     =PositionGetDouble(POSITION_PRICE_OPEN);
   pos_cprice     =PositionGetDouble(POSITION_PRICE_CURRENT);
//pos_sl         =PositionGetDouble(POSITION_SL);
//pos_tp         =PositionGetDouble(POSITION_TP);
   pos_type       =(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   pos_volume     =PositionGetDouble(POSITION_VOLUME);
   pos_commission =PositionGetDouble(POSITION_COMMISSION);
   pos_swap       =PositionGetDouble(POSITION_SWAP);
   pos_profit     =PositionGetDouble(POSITION_PROFIT);
   pos_time       =(datetime)PositionGetInteger(POSITION_TIME);
   pos_id         =PositionGetInteger(POSITION_IDENTIFIER);
   pos_diffoc     =pos_oprice-pos_cprice;
   pos_ask        =SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   pos_bid        =SymbolInfoDouble(Symbol(),SYMBOL_BID);
   pos_spread     =pos_ask - pos_bid;
   opriceplusspread =pos_oprice + pos_spread;
   opriceminusspread =pos_oprice - pos_spread;
  }

//+-----------------------------------------------------------------------------------+
//| Tab for win/buysl-pip values   |
//| winclosest = opricest - spreadst - winpips
//| winclosebt = opricebt + spreadbt + winpips;
//| notstopst = opricest + sellslpips;
//| notstopbt = opricebt - buyslpips;  // max risk loss
//| USDCAD vol 0.01 = 10ct/pip = 1€/10pip winpips 40 (0.004) buyslpips 20 (0.002)
//| EURUSD vol             winpips 20 (0.002) buyslpips 10 (0.001) |
//+-----------------------------------------------------------------------------------+
double TradeVolume=10;
double sellslpips=3; // werden by notstopst zum oprice als Risk addiert
double buyslpips=3; // 0.005 = 50 pips bei usdcad; 0.1 = 10 pips bei usdjpy
double winpips=5; // wird zu oprice addiert und abgezogen um inital winclose zu setzen
// 0.005 = 50 pips bei usdcad; 0.1 = 10 pips bei usdjpy
// double winstep=4;
// double downstep=-4;  // Startcondition selltrade für Strategie mit Tickmessung
double upstep=3;  // Startcondition buytrade
double minpips=3;  // minimal win absicherung 
double trailstepst=0;
double trailstepbt=0;
double trailstop=0;
double sellmonidiff;
double buymonidiff;
double diff;
double pos_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
double pos_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
double pos_spread=pos_ask-pos_bid;
double opriceplusspread = pos_oprice + pos_spread;
double opriceminusspread = pos_oprice - pos_spread;
double notstopst=0;
double notstopstadjusted=0;
double notstopbt=0;
double notstopbtadjusted=0;
double winclosest=0;
double winclosebt=0;
// double notstopbt = pos_oprice - buyslpips;  // max risk loss
// double winclosebt = pos_oprice + pos_spread + winpips;
bool adjustst = false;
bool adjustbt = false;
bool adjustedst= false;
bool adjustedbt= false;
bool firstrun = false;
bool initialsetst = false;
bool initialsetbt = false;
bool notstopbtbreakeven = false;
bool notstopstbreakeven = false;
bool WorkOn = false;
bool newCandle = false;
bool tradetimetrue = false;
long     BarsIndex;              // incremented by OnTick(), IsNewBar()
long     BarsIndexWait;          // Barsindex to trade allowed again
datetime BarsTime;               // set by CheckBarTime()
datetime checktime;   // fot st only
datetime tradetime;
bool     NewBar;                 // set by CheckBarTime()
bool     CheckBarTime(void);     // called by OnTick()
bool     IsNewBar(void);
bool     NoNewBar(void);
double TickCounter=0;

input bool DebugLog = false;

MqlRates priceData[]; // creating price array
// MqlRates PriceInfo[];  // defined in getsignal
double myMovingAverageArray[];
int movingAverageDefinition = iMA(_Symbol,_Period,20,0,MODE_SMA,PRICE_CLOSE);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   basetick=SymbolInfoTick(Symbol(),bid_base);
   end=TimeCurrent();
   start=end-days*PeriodSeconds(PERIOD_D1);
   PrintFormat("Limits of the history to be loaded: start - %s, end - %s",
               TimeToString(start),TimeToString(end));
   InitCounters();
   TickCounter=0;
// return(0);

   ArraySetAsSeries(tick_array,false);
   ArraySetAsSeries(priceData,true); // sorting array from current candle downwards
   ArraySetAsSeries(PriceInfo,true);
   ArraySetAsSeries(myMovingAverageArray,true);
   ArraySetAsSeries(bufferSMA,true);
   signalnow = SIG_NONE;
   toCopy=3;
   handleSMA = iMA(_Symbol,_Period,20,0,MODE_SMA,PRICE_CLOSE); // Handle für den iMA erzeugen
   if(HandleError(handleSMA,"iMA"))                            // Handle überprüfen 1
      return(false);
   return(INIT_SUCCEEDED);

// dax adds


  }
//+------------------------------------------------------------------+
//|  Initialisierung Zähler von Position, Auftrag und Deals          |
//+------------------------------------------------------------------+
void InitCounters()
  {
   ResetLastError();
//--- Laden der Historie
   bool selected=HistorySelect(start,end);
   if(!selected)
     {
      PrintFormat("%s. Failed to load history from %s to %s to cache. Error code: %d",
                  __FUNCTION__,TimeToString(start),TimeToString(end),GetLastError());
      return;
     }
//--- Abfrage der aktuellen Werte
   orders=OrdersTotal();
   positions=PositionsTotal();
   deals=HistoryDealsTotal();
   history_orders=HistoryOrdersTotal();
   started=true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckBarTime();
   TickCounter=TickCounter+1;
  checktime=TimeCurrent();
//tradetime=TimeGMT();
//int tradetime = TimeToString(TimeLocal(),TIME_MINUTES);
#define  HoD(t) ((int)(((t)%86400)/3600))   // Hour of Day 2018.02.03 17:55:56 => (int) 17
   int tradetime = HoD(TimeCurrent());
   if(tradetime > 9)
      tradetimetrue = true;
   else

      tradetimetrue = false;


//if(TickCounter==499)
 //  if(StopAtDate.Check("2020.06.16", "09:00")) 
   //DebugBreak();   // hier hält das Programm an

   if(started)
      SimpleTradeProcessor();
   else
      InitCounters();

   if(DebugLog)
      Print("......");

   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   int PriceData = CopyRates(_Symbol,_Period,0,3,PriceInfo);
   CopyBuffer(movingAverageDefinition,0,0,3,myMovingAverageArray);

   CopyRates(_Symbol,_Period,0,3,priceData); // copying prices of 3 candles into array

   CopyRates(_Symbol,_Period,0,toCopy,PriceInfo);
   CopyBuffer(handleSMA,0,   0,toCopy,bufferSMA);

   if(glTradePlaced != true)
     {
      signalnow = Signal();
     }

// ---
   bool openPosition = PositionSelect(_Symbol);
   int total=PositionsTotal();

// ################################################
// #######  trade adjustments für sell trade ######
// ################################################
   if(glSellPlaced == true && adjustst == true)
     {
      trailstepst=(notstopst-pos_cprice)/2;  // prüfen + notstopst - cprice?
      notstopstadjusted=notstopst-trailstepst;
      notstopst=notstopstadjusted; // der notstopst muss mit runtergezogen werden, weil der alte zu Verlusten führt
      winclosest=(winclosest)-(2*trailstepst);
      adjustst = false;
      adjustedst = true;
     }

// ################################################
// #######   trade adjustments für buy trade ######
// ################################################
   if(glBuyPlaced == true && adjustbt == true)
     {
      trailstepbt=(pos_cprice-notstopbt)/2;
      notstopbtadjusted=(notstopbt)+(trailstepbt);
      notstopbt=notstopbtadjusted; // der notstopbt muss mit raufgezogen werden, weil der alte zu Verlusten führt
      winclosebt=(winclosebt)+(2*trailstepbt);
      adjustbt = false;
      adjustedbt = true;
     }

   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);


   long positionType = PositionGetInteger(POSITION_TYPE);
   double currentVolume = 0;  // teste nach global hoch
   if(openPosition == true)
     {
      currentVolume = PositionGetDouble(POSITION_VOLUME);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!initialized)
     {
      CopyTicks(_Symbol,tick_array,COPY_TICKS_ALL,0,elements);
      //Print("copied ticks aus !initialized: ");
      //ArrayPrint(tick_array);
      initialized=true;
     }
   else
     {
      ArrayRemove(tick_array,0,1);
      SymbolInfoTick(_Symbol,new_tick[0]);
      ArrayResize(tick_array,elements);
      ArrayCopy(tick_array,new_tick,elements-1);
     }

//+-----------------------------------------------------------------------------------+
//| condition when starting sell trade / wenn neuer Tick < alter Tick und diffSprung  |
//|   Index [0] ist der älteste Tick, Index [elements-1] der aktuellste               |
//+-----------------------------------------------------------------------------------+
//if(newCandle==true && (tick_array[elements-1].ask)<(tick_array[elements-10].ask) && diff<=downstep && glTradePlaced == false && glTradeClosed != true && (positionType != POSITION_TYPE_SELL || openPosition == false))
//if(NewBar && signalnow == SIG_SELL && PositionsTotal()<1)
   if(tradetimetrue == true && TickCounter>100 && signalnow == SIG_SELL && total<1 && glSellPlaced == false && glBuyPlaced == false)
   //if(TickCounter>1000 && signalnow == SIG_SELL && total<1 && glSellPlaced == false && glBuyPlaced == false)
     {
      // Open sell market order
      request.action = TRADE_ACTION_DEAL;
      request.type = ORDER_TYPE_SELL;
      request.symbol = _Symbol;
      request.volume = TradeVolume;
      request.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      request.sl = 0;
      request.tp = 0;
      request.deviation = 10;
      if(OrderSend(request,result))
        {
         ticket = result.order;
        }
      else
        {
         DebugBreak();
        }

      int checkCode = 0;
      checkCode = CheckReturnCode(result.retcode);
      //ticket = HistoryDealGetTicket();
      //Print("Ticket: ",ticket);
      glTradePlaced = true;
      glSellPlaced = true;
      TickCounter=0;
     }
   if(WorkOn == true && glSellPlaced == true && initialsetst != true)
     {
      //int pos_total=PositionsTotal();
      //for(int p=0; p<pos_total; p++)
      //{
      //pos_symbol=PositionGetSymbol(p);
      //if(PositionSelect(pos_symbol))
      if(PositionSelect(_Symbol))
        {
         GetPositionProperties();
         // ## 200123 eingefügt, weil notstopst sonst sofort zieht weil er 0 ist
         pos_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
         pos_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
         pos_spread = pos_ask - pos_bid;
         opriceplusspread = pos_oprice + pos_spread;
         notstopst = pos_oprice + sellslpips;
         notstopstadjusted = notstopst; // damit nicht gleich 0, das kann zum verfehlten Schließen von Trades führen
         winclosest = pos_oprice - winpips;
         initialsetst = true;
        }
      // }
     }
//+-----------------------------------------------------------------------------------------------------------+
//| condition when starting buy trade / wenn neuer Tick > alter Tick und diffSprung und glTradeClose != true  |
//+-----------------------------------------------------------------------------------------------------------+

//if(newCandle==true && (tick_array[elements-1].ask)>(tick_array[elements-10].ask) && diff>=upstep && glTradePlaced == false && glTradeClosed != true && (positionType != POSITION_TYPE_BUY || openPosition == false))
//if(NewBar && signalnow == SIG_BUY && PositionsTotal()<1)
   if(tradetimetrue == true && TickCounter>100 && signalnow == SIG_BUY && total<1 && glSellPlaced == false && glBuyPlaced == false)
   //if(TickCounter>1000 && signalnow == SIG_BUY && total<1 && glSellPlaced == false && glBuyPlaced == false)
     {
      // Open buy market order
      request.action = TRADE_ACTION_DEAL;
      request.type = ORDER_TYPE_BUY;
      request.symbol = _Symbol;
      request.volume = TradeVolume;
      request.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      request.sl = 0;
      request.tp = 0;
      request.deviation = 10;
      if(OrderSend(request,result))
        {
         ticket = result.order;
        }
      else
        {
         DebugBreak();
        }
      int checkCode = 0;
      checkCode = CheckReturnCode(result.retcode);
      glTradePlaced = true;
      glBuyPlaced = true;
      TickCounter=0;
     }
   if(WorkOn == true && glBuyPlaced == true && initialsetbt != true)
     {
      Print("Zeile 398: in WorkOn == true && glBuyPlaced == true && initsetbt != true");
      //int pos_total=PositionsTotal();
      //for(int p=0; p<pos_total; p++)
      //{
      //pos_symbol=PositionGetSymbol(p);
      if(PositionSelect(_Symbol))
        {
         GetPositionProperties();
         // ## 200123 eingefügt, weil notstopbt sonst sofort zieht weil er 0 ist
         pos_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
         pos_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
         pos_spread = pos_ask - pos_bid;
         opriceplusspread = pos_oprice + pos_spread;
         notstopbt = pos_oprice - buyslpips;
         notstopbtadjusted = notstopbt; // damit nicht gleich 0, das führt zu falschen Closes
         winclosebt = pos_oprice + winpips;
         initialsetbt = true;
        }
      // }
     }

//+------------------------------------------------------------------+
//| trade monitoring sell trade                                     |
//+------------------------------------------------------------------+
/// hier noch mal getProperties, weil hierüber ein Trade geöffnet wird
/// und sonst die Werte 0 sind und die Bedingungen für running well
/// sofort erfüllt sind
   if(WorkOn == true && glSellPlaced == true)
     {
      // bool openPosition = PositionSelect(_Symbol);
      int pos_total=PositionsTotal();
      for(int p=0; p<pos_total; p++)
        {
         pos_symbol=PositionGetSymbol(p);
         if(PositionSelect(pos_symbol))
           {
            GetPositionProperties();
            pos_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            pos_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
            pos_spread=pos_ask - pos_bid;
            opriceplusspread = pos_oprice + pos_spread;
           }
        }

      //+------------------------------------------------------------------+
      //| conditions for handling  sell trade                              |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //| if sell placed and running well                                  |
      //+------------------------------------------------------------------+
      if(pos_cprice < (pos_oprice-minpips) && adjustedst != true)
        {
         adjustst = true;
        }
      if(pos_cprice < (pos_oprice-minpips) && notstopstbreakeven != true)
        {
         notstopst = pos_oprice-minpips;
         notstopstbreakeven = true;
        }
      // das && weil notstopstadjusted mit 0 initialisiert wird und der cprice sonst direkt darüber ist
      if(adjustedst == true && pos_cprice < notstopstadjusted)
        {
         notstopst = notstopstadjusted;
         adjustst = true;
        }

      //+------------------------------------------------------------------+
      //| CLOSING SELL TRADE IN WIN                                        |
      //+------------------------------------------------------------------+
      // if((pos_cprice <= winclosest) || (pos_cprice >= notstopstadjusted))
      if((adjustedst==true) && ((pos_cprice <= winclosest) || (pos_cprice >= notstopstadjusted)))
        {
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(!trade.PositionClose(PositionGetSymbol(i),5))
              {
               Print(PositionGetSymbol(i)," PositionClose() hat nicht funktioniert, FEHLER! Return code= KOMM NICHT DRAN, protected");
              }
            else

            glTradePlaced = false;
            glSellPlaced = false;
            glTradeClosed = true;
            initialsetst = false;
            adjustedst = false;
           }
        }
      //   } // FALSCH!!! hier verlassen wir die monitoring sell trade conditions!!!
      //}  // xxx

      //+------------------------------------------------------------------+
      //| if sell placed and running bad                                        |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //| conditions for closing sell trade in loss                        |
      //+------------------------------------------------------------------+
      //if(pos_cprice > pos_oprice)
        //{
         //+------------------------------------------------------------------+
         //| CLOSING SELL TRADE IN LOSS                                       |
         //+------------------------------------------------------------------+
         if(pos_cprice >= notstopst)
           {
            // Close sell trade im loss
            //CTrade trade;
            for(int i=PositionsTotal()-1; i>=0; i--)
              {
               if(!trade.PositionClose(PositionGetSymbol(i),5))
                 {
                  Print(PositionGetSymbol(i)," PositionClose() hat nicht funktioniert, FEHLER! Return code=KOMM NICHT DRAN, protected");
                 }
               else
                 {
                  glTradePlaced = false;
                  glSellPlaced = false;
                  glTradeClosed = true;
                  initialsetst = false;
                  adjustedst = false;
                 }
              }
          // }
        }
     }

// ---------------------------- Stanza --------------------------------------------------

//+------------------------------------------------------------------+
//| trade monitoring buy trade                                      |
//+------------------------------------------------------------------+
   if(WorkOn == true && glBuyPlaced == true)
     {
      // ### get props hier eingefügt weil beim closen bei 613 nichts ankam
      int pos_total=PositionsTotal();
      for(int p=0; p<pos_total; p++)
        {
         pos_symbol=PositionGetSymbol(p);
         if(PositionSelect(pos_symbol))
           {
            GetPositionProperties();
            pos_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            pos_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
            pos_spread=pos_ask - pos_bid;
            opriceplusspread = pos_oprice + pos_spread;
           }
        }
      if(pos_cprice > (pos_oprice+minpips) && adjustedbt != true)
        {
         adjustbt = true;
        }
      if(pos_cprice > (pos_oprice+minpips) && notstopbtbreakeven != true)
        {
         notstopbt = opriceplusspread;
         notstopbtbreakeven = true;
        }
      // das && weil notstopbtadjusted mit 0 initialisiert wird und der cprice sonst direkt darüber ist
      if(pos_cprice > notstopbtadjusted && adjustedbt == true)
        {
         notstopbt = notstopbtadjusted;
         adjustbt = true;
        }
      //+------------------------------------------------------------------+
      //| CLOSE BUY TRADE IN WIN                                           |
      //+------------------------------------------------------------------+
      if((pos_cprice >= winclosebt) || (pos_cprice <= notstopbtadjusted))
        {
         // Close buy trade im win
         //CTrade trade2close;
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(!trade.PositionClose(PositionGetSymbol(i),5))
              {
               Print(PositionGetSymbol(i)," PositionClose() hat nicht funktioniert, FEHLER! Return code=KOMM NICHT DRAN, protected");
              }
            else
              {
               glTradePlaced = false;
               glBuyPlaced = false;
               glTradeClosed = true;
               initialsetbt = false;
               adjustedbt = false;
              }
           }
        }
      //} // rausgenomen xxx
      //+------------------------------------------------------------------+
      //| CLOSE BUY TRADE IN LOSS                       |
      //+------------------------------------------------------------------+
      // ### TODO ###
      if(pos_cprice <= notstopbt)
        {
         // Close buy trade im loss
         //CTrade trade2close;
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(!trade.PositionClose(PositionGetSymbol(i),5))
              {
               Print(PositionGetSymbol(i)," PositionClose() hat nicht funktioniert, FEHLER! Return code=KOMM NICHT DRAN, protected");
              }
            else
              {
               glTradePlaced = false;
               glBuyPlaced = false;
               glTradeClosed = true;
               initialsetbt = false;
               adjustedbt = false;
              }
           }
        }
     }
  }
//} // das ist die close onTick Klammer

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade()
  {
   if(started)
      SimpleTradeProcessor();
   else
      InitCounters();
  }
//+------------------------------------------------------------------+
//| Beispiel für das Bearbeiten der Änderungen im Handel und Historie|
//+------------------------------------------------------------------+
void SimpleTradeProcessor()
  {
   end=TimeCurrent();
   ResetLastError();
//--- Laden der Handelshistorie des bestimmten Intervalls in den Cache des Programms
   bool selected=HistorySelect(start,end);
   if(!selected)
     {
      PrintFormat("%s. Failed to load history from %s to %s to cache. Error code: %d",
                  __FUNCTION__,TimeToString(start),TimeToString(end),GetLastError());
      return;
     }
//--- Abfrage der aktuellen Wert
   int curr_orders=OrdersTotal();
   int curr_positions=PositionsTotal();
   int curr_deals=HistoryDealsTotal();
   int curr_history_orders=HistoryOrdersTotal();
//--- Prüfen, ob sich die Zahl der aktiven Aufträge verändert hat
   if(curr_orders!=orders)
     {
      //--- Anzahl der aktiven Aufträge hat sich geändert
      PrintFormat("Number of orders has been changed. Previous value is %d, current value is %d",
                  orders,curr_orders);
      //--- Aktualisieren des Wertes
      orders=curr_orders;
     }
//--- Ändern der Anzahl der offenen Position
   if(curr_positions!=positions)
     {
      //--- Anzahl der offenen Positionen hat sich geändert
      PrintFormat("Number of positions has been changed. Previous value is %d, current value is %d",
                  positions,curr_positions);
      //--- Aktualisieren des Wertes
      positions=curr_positions;
      WorkOn = true;
     }
//--- Veränderung der Anzahl der Deals im Cache der Handelshistorie
   if(curr_deals!=deals)
     {
      //--- Anzahl der Deals in der Handelshistorie wurde geändert
      PrintFormat("Number of deals has been changed. Previous value is %d, current value is %d",
                  deals,curr_deals);
      //--- Aktualisieren des Wertes
      deals=curr_deals;
     }
//--- Veränderung der Anzahl der historischen Orders im Cache der Handelshistorie
   if(curr_history_orders!=history_orders)
     {
      //--- Anzahl der historischen Aufträge der Handelshistorie im Cache wurde geändert
      PrintFormat("Number of orders in history has been changed. Previous value is %d, current value is %d",
                  history_orders,curr_history_orders);
      //--- Aktualisieren des Wertes
      history_orders=curr_history_orders;
     }
//--- Prüfen, ob es notwendig ist die Grenzen der Handelshistorie im Cache zu verändern
   CheckStartDateInTradeHistory();
  }
//+------------------------------------------------------------------+
//|  Ändern des Anfangsdatum zur Anforderung der Handelshistorie     |
//+------------------------------------------------------------------+
void CheckStartDateInTradeHistory()
  {
//--- erstes Intervall, falls jetzt mit der Arbeit begonnen werden soll
   datetime curr_start=TimeCurrent()-days*PeriodSeconds(PERIOD_D1);
//--- Sicherstellen, dass die Anfangsdatum der Handelshistorie nicht mehr als
//--- ein Tag über dem intendierten liegt
   if(curr_start-start>PeriodSeconds(PERIOD_D1))
     {
      //--- Korrektes Anfangsdatum der Historie für den Cache
      start=curr_start;
      PrintFormat("New start limit of the trade history to be loaded: start => %s",
                  TimeToString(start));
      //--- jetzt die Handel neu laden, um das Intervall zu aktualisieren
      HistorySelect(start,end);
      //--- Korrigieren der Zähler der Deals und der Aufträge in der Historie für spätere Vergleiche
      history_orders=HistoryOrdersTotal();
      deals=HistoryDealsTotal();
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

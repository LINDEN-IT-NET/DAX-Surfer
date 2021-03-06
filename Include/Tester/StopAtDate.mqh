//+------------------------------------------------------------------+
//|                                                   StopAtDate.mqh |
//|                                Copyright © 2018 Ing. Otto Pauser |
//|                       https://www.mql5.com/de/users/kronenchakra |
//+------------------------------------------------------------------+
/*
   Klasse um den Metatester an einem bestimmten Datum,
   zu einer bestimmten Uhrzeit im visuellen Mode anzuhalten.
   Die Funktion hält nur ein einziges mal an!
   
   Verwendung OOP Variante:
   ------------------------
   1.)  mqh einbinden
   
   #include <Tester\StopAtDate.mqh>
   
   2.)Einsatz in der OnTick()

   void OnTick()
   {
                                                   // Code vorher
      
      if(StopAtDate.Check("2018.01.17", "20:19"))  // prüfen der Zeit
         DebugBreak();                             // hier hält das Programm an
      
                                                   // Code nachher
   }
   
   Verwendung konventionelle Variante:
   -----------------------------------
   1.)  mqh einbinden
   
   #include <Tester\StopAtDate.mqh>
   
   2.)Einsatz in der OnTick()

   void OnTick()
   {
                                                   // Code vorher
      
      if(WaitAtDate("2018.01.17", "20:19"))        // prüfen der Zeit
         DebugBreak();                             // hier hält das Programm an
      
                                                   // Code nachher
   }
   
   
*/

//+------------------------------------------------------------------+
//| Definition                                                       |
//+------------------------------------------------------------------+

class CStopAtDate
{
   private:
      bool     triggered;                          // flag triggerTime erreicht
      datetime triggerTime;                        // 
   public:
            CStopAtDate(void);                     // Konstructor. Initialisierung von Variablen etc.
           ~CStopAtDate(void) {};                  // Destructor. Muss vorhanden sein, falls Konstruktor definiert
      bool  Check(string aDate, string aTime);
};

CStopAtDate StopAtDate;                            // Instanz deklarieren

//+------------------------------------------------------------------+
//| Implementation                                                   |
//+------------------------------------------------------------------+

void CStopAtDate::CStopAtDate(void)
{
   triggered   = false;
   triggerTime = NULL;
}

bool CStopAtDate::Check(string aDate, string aTime)
{
   if(triggered)                                   // Zeit erreicht ?
      return(false);                               // ja, raus hier und nicht mehr anhalten

   if(triggerTime==NULL)                           // triggerTime noch nicht berechnet
      triggerTime = StringToTime(aDate+" "+aTime);

   triggered=TimeCurrent()>=triggerTime;           // Zeit mit Zielzeit vergleichen
      
   return(triggered);                              // false if noch nicht erreicht
}

//+------------------------------------------------------------------+
//| konventionell programmiert                                       |
//+------------------------------------------------------------------+

bool WaitAtDate(string aDate, string aTime)
{
   static bool     triggered   = false;
   static datetime triggerTime = NULL;

   if(triggered)                                   // Zeit erreicht ?
      return(false);                               // ja, raus hier und nicht mehr anhalten

   if(triggerTime==NULL)                           // triggerTime noch nicht berechnet
      triggerTime = StringToTime(aDate+" "+aTime);

   triggered=TimeCurrent()>=triggerTime;           // Zeit mit Zielzeit vergleichen
      
   return(triggered);                              // false if noch nicht erreicht
}

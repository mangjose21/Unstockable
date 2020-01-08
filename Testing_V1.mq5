//+------------------------------------------------------------------+
//|                                                   Testing_V1.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalRSI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert

///Expert.mqh << required for this process. all the relevant info there.

input string             Expert_Title                  ="Testing_V1"; // Document name
ulong                    Expert_MagicNumber            =16382;        //
bool                     Expert_EveryTick              =true;        //
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;           // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;           // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;          // Price level to execute a deal
input double             Signal_StopLevel              =10.0;         // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;         // Take Profit level (in points)
input int                Signal_Expiration             =20;            // Expiration of pending orders (in bars)
input int                Signal_0_MA_PeriodMA          =20;           // Moving Average(20,0,...) Period of averaging
input int                Signal_0_MA_Shift             =0;            // Moving Average(20,0,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method            =MODE_SMA;     // Moving Average(20,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied           =PRICE_CLOSE;  // Moving Average(20,0,...) Prices series
input double             Signal_0_MA_Weight            =1.0;          // Moving Average(20,0,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA          =50;           // Moving Average(50,0,...) Period of averaging
input int                Signal_1_MA_Shift             =0;            // Moving Average(50,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method            =MODE_SMA;     // Moving Average(50,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied           =PRICE_CLOSE;  // Moving Average(50,0,...) Prices series
input double             Signal_1_MA_Weight            =1.0;          // Moving Average(50,0,...) Weight [0...1.0]
input int                Signal_RSI_PeriodRSI          =14;           // Relative Strength Index(14,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_RSI_Applied            =PRICE_CLOSE;  // Relative Strength Index(14,...) Prices series
input double             Signal_RSI_Weight             =1.0;          // Relative Strength Index(14,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_FixedPips_StopLevel  =6;            // Stop Loss trailing level (in points)
input int                Trailing_FixedPips_ProfitLevel=18;           // Take Profit trailing level (in points)
//--- inputs for money
input double             Money_FixLot_Percent          =10.0;         // Percent
input double             Money_FixLot_Lots             =0.1;          // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  { 

//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
     
     
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_0_MA_PeriodMA);
   filter0.Shift(Signal_0_MA_Shift);
   filter0.Method(Signal_0_MA_Method);
   filter0.Applied(Signal_0_MA_Applied);
   filter0.Weight(Signal_0_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter1=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_1_MA_PeriodMA);
   filter1.Shift(Signal_1_MA_Shift);
   filter1.Method(Signal_1_MA_Method);
   filter1.Applied(Signal_1_MA_Applied);
   filter1.Weight(Signal_1_MA_Weight);
//--- Creating filter CSignalRSI
   CSignalRSI *filter2=new CSignalRSI;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodRSI(Signal_RSI_PeriodRSI);
   filter2.Applied(Signal_RSI_Applied);
   filter2.Weight(Signal_RSI_Weight);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
   
   MqlRates BarData[1]; 
   CopyRates(Symbol(), Period(), 0, 1, BarData); // Copy the data of last incomplete BAR
// Copy latest close prijs.
   double Latest_Close_Price = BarData[0].close;
   
   Print(Latest_Close_Price);
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   /*
   MqlRates BarData[1]; 
   CopyRates(Symbol(), Period(), 0, 1, BarData); // Copy the data of last incomplete BAR
// Copy latest close prijs.
   double Latest_Close_Price = BarData[0].close;
   
   Print(Latest_Close_Price);*/
   // plot momentum here
   
   //Print("1:" +getNormalizeLog(1));
   //Print("2:" +getNormalizeLog(2));
   //Print("3:" +getNormalizeLog(3));
   //Print("lnC: "+getSumLnC(50));
   Print("0:" + GetTimeExcel1900(0));
   Print("1:" + GetTimeExcel1900(1));
   Print("2:" +GetTimeExcel1900(2));
};
int OnCalculate (const int rates_total,      // size of the price[] array
                 const int prev_calculated,  // bars handled on a previous call
                 const int begin,            // where the significant data start from
                 const double& price[]       // array to calculate
   ){ return 0; };

float getNormalizeLog(int predys){
   MqlRates BarData[1]; 
   CopyRates(Symbol(), Period(), predys, 1, BarData); // Copy the data of last incomplete BAR
// Copy latest close prijs.
   double Latest_Close_Price = BarData[0].close;
   
   double lnc = MathLog(Latest_Close_Price);
   return lnc;
}

float getSumLnC(int days)
{
   float initVal = 0;
   for (int i = 0; i < days; i++){
      initVal += getNormalizeLog(i);
   }
   return initVal;
};

double getDateMean(int days){
   double _result = 0;
   for (int i = 0; i < days; i++){
      _result += GetTimeExcel1900(i);
   }
   double result = _result/ days;
   return result;
};

double getx_xb2(int days, double meanDate){
return 0;
};
/*
function getx_xb2(prevdys, xb){
	pace=0;
	for (i = 0; i < prevdys; i++){
		if(i == 0){
			pace += (GetExcelDate() - xb) ^ 2;
		}
		else{
			pace += (Ref(GetExcelDate(), -i) - xb) ^ 2;
		}
	}
	result = pace;
	return result;
}
*/

float ComputeSlope(int days){
return 0;
};

double GetTimeExcel1900(int day)
{
//mql5 uses epoch so need to cnvert to excel date which is anchored at 1900.
/*
=(B5/86400)+DATE(1970,1,1)
=(1538352000/86400)+25569
=43374
*/
   int period = PeriodSeconds();
   int datetoadd = period * day; // for 24hrs
   datetime    tm=TimeCurrent() - datetoadd;
   
   Print("current: " + TimeCurrent() + " tm: " + tm + " " + datetoadd);
   
   //Print((long)tm); // for epoch time
   //long epocho = (long)tm;
   //Print( (epocho / 86400) + 25569); // current date in excel
   //Print((float)((epocho / 86400) + 25569));
   //Print(   NormalizeDouble((float)tm / 86400, 8) +  "--Float");
  
   return NormalizeDouble(((float)tm / 86400)+ 25569, 12);
};
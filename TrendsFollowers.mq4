

//+------------------------------------------------------------------+
//|                                   Indicator: TrendsFollowers.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+

/*------------------------------------------------------------------------------

	TRENDSFOLLOWERS
	
	Copyright (c) 2022, 
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification,
	are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in 
      the documentation and/or other materials provided with the distribution.
    * The name of the MQLTools may not be used to endorse or promote products
      derived from this software without specific prior written permission.
		
	THIS SOFTWARE IS PROVIDED BY NOEL M NGUEMECHIIEU "AS IS" WITHOUT ANY EXPRESS
	OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
	IN NO EVENT SHALL THE MQLTOOLS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
	
	*/


#property copyright "2022 ,NOEL M NGUEMECHIEU"
#property link      "https://github.com/nguemechieu"
#property version   "2.50"
#property description "TrendsFollowers check past and new data history to find the best signal  "
#property description "Monitoring balance, equity, margin, profitability and drawdown"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 25

#property indicator_type1 DRAW_ARROW
#property indicator_width1 4
#property indicator_color1 clrGreen
#property indicator_label1 "BUY"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 5
#property indicator_color2 clrRed;
#property indicator_label2 "SELL"


#property indicator_type3  DRAW_ARROW
#property indicator_width3 6
#property indicator_color3 clrRed;
#property indicator_label3 "EXIT BUY"

#property indicator_type4  DRAW_ARROW
#property indicator_width4 7
#property indicator_color4 clrRed
#property indicator_label4 "EXIT SELL"


#property strict
#property indicator_color5 SteelBlue
#property indicator_color6 OrangeRed
#property indicator_color7 SlateGray
#property indicator_color8 ForestGreen
#property indicator_color9 Gray
#property indicator_width5 4
#property indicator_width6 3
#property indicator_width7 2
#property indicator_width8 4
#property indicator_width9 5

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>



input bool Send_Email = true;
input bool Audible_Alerts = true;
input bool Push_Notifications = true;
input string ss;//====  CHART COLOR SETTING ============

input color Bear Candle=clrRed;
input color Bull Candle=clrGreen;
input  color Bear_Outline=clrRed;
input color Bull_Outline=clrGreen;
 input color BackGround=clrAzure;
 input color ForeGround=clrBlue;
 
extern string           ______FILTERS______="______FILTERS______";
extern bool             Only_Trading=false;
extern bool             Only_Current=false;
extern bool             Only_Buys=false;
extern bool             Only_Sells=false;
extern bool             Only_Magics=false;
extern long              Magic_From=-1;
extern long           Magic_To=99333;
extern string           Only_Symbols="";
extern string           Only_Comment="";
extern string           ______PERIOD______="______PERIOD______";
extern datetime         Draw_Begin=D'2012.01.01 00:00';
extern datetime         Draw_End=D'2035.01.01 00:00';
enum   reporting        {day,month,year,history};
extern reporting        Report_Period=history;
extern string           ______ALERTS______="______ALERTS______";
extern double           Equity_Min_Alert=0;
extern double           Equity_Max_Alert=0;
extern bool             Push_Alerts=false;
extern string           ______LINES______="______LINES______";
extern bool             Show_Balance=true;
extern bool             Show_Margin=false;
extern bool             Show_Free=false;
extern bool             Show_Zero=false;
extern bool             Show_Info=true;
extern bool             Show_Verticals=true;
extern string           ______OTHER______="______OTHER______";
extern ENUM_BASE_CORNER Text_Corner=CORNER_LEFT_LOWER;
extern color            Text_Color=Magenta;
extern string           Text_Font="Tahoma";
extern int              Text_Size=12;
extern bool             File_Write=false;
extern string           FX_prefix="";
extern string           FX_postfix="";



//----
#import "wininet.dll"
int InternetAttemptConnect(int x);
int InternetOpenW(string sAgent,int lAccessType,
                  string sProxyName="",string sProxyBypass="",
                  int lFlags=0);
int InternetOpenUrlW(int hInternetSession,string sUrl,
                     string sHeaders="",int lHeadersLength=0,
                     int lFlags=0,int lContext=0);
int InternetReadFile(int hFile,int &sBuffer[],int lNumBytesToRead,
                     int &lNumberOfBytesRead[]);
int InternetCloseHandle(int hInet);
#import

#define COLUMN_DATE       0
#define COLUMN_TIME        13
#define COLUMN_TIMEZONE    14
#define COLUMN_CURRENCY    15
#define COLUMN_DESCRIPTION 16
#define COLUMN_IMPORTANCE  17
#define COLUMN_ACTUAL      18
#define COLUMN_FORECAST    19
#define COLUMN_PREVIOUS    20

#define COLUMN_DATE_DAY_STR   0
#define COLUMN_DATE_MONTH_STR  1
#define COLUMN_DATE_DAY_INT    2

 int   time_zone_gmt     =0;//LOCAL TIMEZONE WILL BE CHANGED TO 
                                //YOUR PC-TIMEZONE AUTOMATICLY

//---- input parameters news
extern string news_parameters="Make your selection";
extern color  session_upcoming_title_color=Purple;
extern color  session_closing_color=Red;
extern color  bar_closing_color=Green;
extern string if_show_currency_news_only="Choose auto true";
extern bool   auto=true;
extern bool   show_low_news     = true;
extern bool   show_medium_news  = true;
extern bool   show_high_news    = true;
extern color  news_past_color   = Gray;
extern color  news_high_color   = Red;
extern color  news_medium_color = Orange;
extern color  news_low_color    = Blue;
extern string if_auto_false="select news currencie(s)";
extern bool   show_eur = true;
extern bool   show_usd = true;
extern bool   show_jpy = true;
extern bool   show_gbp = true;
extern bool   show_chf = true;
extern bool   show_cad = true;
extern bool   show_aud = true;
extern bool   show_nzd = true;
extern bool   show_cny = true;
//verticale lines
extern bool   show_news_lines  = true; //verticale lines show moments of news
extern bool   show_line_text   = true; //news text by verticale lines
//---------------------------------------------------
//---- input parameters clock
int           Clockcorner=0;
extern string input_parameters="for the clock";
extern int       godown=200;
extern int       goright=10;
//Colors clock
extern color     labelColor=DarkSlateGray;
extern color     clockColor=DarkSlateGray;
extern color     ClockMktOpenColor=Red;
extern color     ClockMktHolidayClr=PaleTurquoise;// Blue;
bool             show12HourTime=false; //YOU CAN CHANGE IT BUT I LIKE THIS MORE
extern bool      ShowSpreadChart=true;
extern bool      ShowBarTime=true;
extern bool      ShowLocal=true;
extern bool      ShowBroker=true;
extern bool      ShowGMT=true;
//FOUND THE TIMES WHEN THE MARKETS WERE OPEN AT
//World Financial Markets   http://www.2011.worldmarkethours.com/Forex/index1024.htm
extern bool      Show_NEW_ZEALAND=true;//Auckland GMT+12
extern bool      Show_AUSTRALIA=true;//Sydney GMT+12
extern bool      Show_JAPAN=true;//Tokyo GMT+9
extern bool      Show_HONG_KONG=true;//    GMT+8
extern bool      Show_EUROPE=true;//Frankfurt GMT+1
extern bool      Show_LONDON=true;//GMT+0
extern bool      Show_NEW_YORK=true;//GMT-5

string     news_url="https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
int        update_interval=15;
int        show_min_before_news=60;

double spread;

datetime NZDHoliday =0;
datetime AUDHoliday =0;
datetime JPYHoliday =0;
datetime CNYHoliday =0;
datetime EURHoliday =0;
datetime GBPHoliday =0;
datetime USDHoliday =0;
datetime localTime;

#import "kernel32.dll"

void GetLocalTime(int &LocalTimeArray[]);
void GetSystemTime(int &systemTimeArray[]);
int  GetTimeZoneInformation(int &LocalTZInfoArray[]);
bool SystemTimeToTzSpecificLocalTime(int &targetTZinfoArray[],int &systemTimeArray[],int &targetTimeArray[]);

#import

//---- buffers
double ExtMapBuffer1[];
int LondonTZ= 0;
int TokyoTZ = 9;
int NewYorkTZ= -5;
int SydneyTZ = 11;
int BerlinTZ = 1;
int AucklandTZ = 13;
int HongKongTZ = 8;
datetime newyork,london,frankfurt,tokyo,sydney,auckland,hongkong,GMT;
string newyorks,londons,frankfurts,tokyos,sydneys,aucklands,hongkongs,GMTs;
// -----------------------------------------------------------------------------------------------------------------------------
int TotalNews=0;
string News[1000][10];
datetime lastUpdate=0;
int NextNewsLine=0;
int LastAlert=0;
double Points;
// -----------------------------------------------------------------------------------------------------------------------------
int initforexclock()
  {
   SetIndexStyle(13,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   int top=godown+20;
   int left2= 70+goright;
   int left =left2;
   if(show12HourTime) left=left2-20;
   if(ShowSpreadChart)
     {
      ObjectMakeLabel("Spread Monitor1",left-45,top);
      ObjectMakeLabel("Spread Monitor2",left2+25,top);
      top+=15;
     }
   if(ShowBarTime)
     {
      ObjectMakeLabel("barl",left2,top);
      ObjectMakeLabel("bart",left-45,top);
      top+=15;
     }
   top+=5;
   if(ShowLocal)
     {
      ObjectMakeLabel("locl",left2,top);
      ObjectMakeLabel("loct",left-45,top);
      top+=15;
     }
   if(ShowBroker)
     {
      ObjectMakeLabel("brol",left2,top);
      ObjectMakeLabel("brot",left-45,top);
      top+=15;
     }
   if(ShowGMT)
     {
      ObjectMakeLabel("gmtl",left2,top);
      ObjectMakeLabel("gmtt",left-45,top);
      top+=15;
     }
   top+=5;
   if(Show_NEW_ZEALAND)
     {
      ObjectMakeLabel("NZDl",left2,top);
      ObjectMakeLabel("NZDt",left-45,top);
      top+=15;
     }
   if(Show_AUSTRALIA)
     {
      ObjectMakeLabel("sydl",left2,top);
      ObjectMakeLabel("sydt",left-45,top);
      top+=15;
     }
   if(Show_JAPAN)
     {
      ObjectMakeLabel("tokl",left2,top);
      ObjectMakeLabel("tokt",left-45,top);
      top+=15;
     }
   if(Show_HONG_KONG)
     {
      ObjectMakeLabel("HKl",left2,top);
      ObjectMakeLabel("HKt",left-45,top);
      top+=15;
     }
   if(Show_EUROPE)
     {
      ObjectMakeLabel("berl",left2,top);
      ObjectMakeLabel("bert",left-45,top);
      top+=15;
     }
   if(Show_LONDON)
     {
      ObjectMakeLabel("lonl",left2,top);
      ObjectMakeLabel("lont",left-45,top);
      top+=15;
     }
   if(Show_NEW_YORK)
     {
      ObjectMakeLabel("nyl",left2,top);
      ObjectMakeLabel("nyt",left-45,top);
      top+=15;
     }

   CreateInfoObjects();
   return(0);
  }
// -----------------------------------------------------------------------------------------------------------------------------
int deinitforexclock()
  {
//----
   ObjectDelete("locl");
   ObjectDelete("loct");
   ObjectDelete("nyl");
   ObjectDelete("nyt");
   ObjectDelete("gmtl");
   ObjectDelete("gmtt");
   ObjectDelete("berl");
   ObjectDelete("bert");
   ObjectDelete("NZDl");
   ObjectDelete("NZDt");
   ObjectDelete("lonl");
   ObjectDelete("lont");
   ObjectDelete("tokl");
   ObjectDelete("tokt");
   ObjectDelete("HKl");
   ObjectDelete("HKt");
   ObjectDelete("sydl");
   ObjectDelete("sydt");
   ObjectDelete("brol");
   ObjectDelete("brot");
   ObjectDelete("barl");
   ObjectDelete("bart");
   ObjectDelete("Spread Monitor1");
   ObjectDelete("Spread Monitor2");

   DeleteNewsObjects();
   DeleteSessionInfoObjects();
//----
   DisplaySessionInfo();

   return(0);
  }
// -----------------------------------------------------------------------------------------------------------------------------
int startforexclock()

  {

   if(!IsDllsAllowed())
     {
      Alert("Clock V1_2: DLLs are disabled.  To enable tick the checkbox in the Common Tab of indicator");
      return 0;
     }
   int    counted_bars=IndicatorCounted();
//----

   int    systemTimeArray[4];
   int    LocalTimeArray[4];
   int    TZInfoArray[43];
   int    nYear,nMonth,nDay,nHour,nMin,nSec,nMilliSec;
   string sMilliSe="";

   HandleDigits();

   GetLocalTime(LocalTimeArray);
//---- parse date and time from array
int TimeArray[8]={};
   nYear=TimeArray[0]&0x0000FFFF;
   nMonth=TimeArray[0]>>16;
   nDay=TimeArray[1]>>16;
   nHour=TimeArray[2]&0x0000FFFF;
   nMin=TimeArray[2]>>16;
   nSec=TimeArray[3]&0x0000FFFF;
   nMilliSec=TimeArray[3]>>16;

   string LocalTimeS=FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
  localTime=TimeArrayToTime(LocalTimeArray);//StrToTime( LocalTimeS );
//-----------------------------------------------------  
   GMTs=TimeToString1(GMT);
   string locals=TimeToString1(localTime);
   londons=TimeToString1(london);
   frankfurts=TimeToString1(frankfurt);
   tokyos=TimeToString1(tokyo);
   newyorks= TimeToString1(newyork);
   sydneys = TimeToString1(sydney);
   aucklands = TimeToString1( auckland );
   hongkongs = TimeToString1( hongkong );
   string brokers=TimeToString1(CurTime());
   string bars=TimeToStr(CurTime()-Time[0],TIME_MINUTES);

//   DisplayTodaysNews();
//-----------------------------------------------------
   LondonTZ = GMT_Offset("LONDON",localTime);   //GBP
   TokyoTZ = GMT_Offset("TOKYO",localTime);     //JPY
   NewYorkTZ = GMT_Offset("US",localTime);      //USD
   SydneyTZ = GMT_Offset("SYDNEY",localTime);   //AUD
   BerlinTZ = GMT_Offset("FRANKFURT",localTime);//EUR
   AucklandTZ = GMT_Offset("AUCKLAND",localTime);//NZD
   HongKongTZ = GMT_Offset("HONGKONG",localTime);//CNY
//-----------------------------------------------------
/*
   int gmt_shift=0;
   int dst=GetTimeZoneInformation(TZInfoArray);
   if(dst!=0) gmt_shift=TZInfoArray[0];
   if(dst==2) gmt_shift+=TZInfoArray[42];
*/
   GetSystemTime(systemTimeArray);
   GMT=TimeArrayToTime(systemTimeArray);//localTime + gmt_shift * 60;

   london= GMT+3600 * LondonTZ;
   tokyo = GMT+3600 * TokyoTZ;
   newyork= GMT+3600 * NewYorkTZ;
   sydney = GMT+3600 * SydneyTZ;
   frankfurt= GMT+3600 * BerlinTZ;
   auckland = GMT +3600 * AucklandTZ;
   hongkong = GMT + 3600 * HongKongTZ;
//   time_zone_gmt = -(gmt_shift/60);
   time_zone_gmt=(int)((localTime-GMT)/3600);

   DisplaySessionInfo();
   DisplayTodaysNews();

   if(ShowLocal)
     {
      ObjectSetText("locl","Local time",10,"Arial Black",labelColor);
      ObjectSetText("loct",locals,10,"Arial Black",ClockMktOpenColor);
     }
   if(ShowBroker)
     {
      ObjectSetText("brol","Broker time",10,"Arial Black",labelColor);
      ObjectSetText("brot",brokers,10,"Arial Black",ClockMktOpenColor);
     }
   if(ShowGMT)
     {
      ObjectSetText("gmtl","GMT",10,"Arial Black",labelColor);
      ObjectSetText("gmtt",GMTs,10,"Arial Black",ClockMktOpenColor);
     }
//--------------------------
   if(Show_NEW_ZEALAND)
     {
      if(NZDHoliday<TimeCurrent())
        {
         if(StrToTime(aucklands)>StrToTime("10:00") && StrToTime(aucklands)<StrToTime("16:45") && TimeDayOfWeek(auckland)!=0 && TimeDayOfWeek(auckland)!=6)
           {
            ObjectSetText("NZDl","New Zealand ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("NZDt",aucklands,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("NZDl","New Zealand ",10,"Arial Black",labelColor);
            ObjectSetText("NZDt",aucklands,10,"Arial Black",clockColor);
           }
        }
      if(NZDHoliday>TimeCurrent())
        {
         ObjectSetText("NZDl","New Zealand market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("NZDt",aucklands,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------
   if(Show_AUSTRALIA)
     {
      if(AUDHoliday<TimeCurrent())
        {
         if(StrToTime(sydneys)>StrToTime("10:00") && StrToTime(sydneys)<StrToTime("17:00") && TimeDayOfWeek(sydney)!=0 && TimeDayOfWeek(sydney)!=6)
           {
            ObjectSetText("sydl","Australia ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("sydt",sydneys,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("sydl","Australia ",10,"Arial Black",labelColor);
            ObjectSetText("sydt",sydneys,10,"Arial Black",clockColor);
           }
        }
      if(AUDHoliday>TimeCurrent())
        {
         ObjectSetText("sydl","Australia market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("sydt",sydneys,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------      
   if(Show_JAPAN)
     {
      if(JPYHoliday<TimeCurrent())
        {
         if(StrToTime(tokyos)>StrToTime("9:00") && StrToTime(tokyos)<StrToTime("12:30") && TimeDayOfWeek(tokyo)!=0 && TimeDayOfWeek(tokyo)!=6)
           {
            ObjectSetText("tokl","Japan ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("tokt",tokyos,10,"Arial Black",ClockMktOpenColor);
           }
         else
         if(StrToTime(tokyos)>StrToTime("14:00") && StrToTime(tokyos)<StrToTime("17:00") && TimeDayOfWeek(tokyo)!=0 && TimeDayOfWeek(tokyo)!=6)
           {
            ObjectSetText("tokl","Japan ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("tokt",tokyos,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("tokl","Japan ",10,"Arial Black",labelColor);
            ObjectSetText("tokt",tokyos,10,"Arial Black",clockColor);
           }
        }
      if(JPYHoliday>TimeCurrent())
        {
         ObjectSetText("tokl","Japan market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("tokt",tokyos,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------         
   if(Show_HONG_KONG)
     {
      if(CNYHoliday<TimeCurrent())
        {
         if(StrToTime(hongkongs)>StrToTime("10:00") && StrToTime(hongkongs)<StrToTime("17:00") && TimeDayOfWeek(hongkong)!=0 && TimeDayOfWeek(hongkong)!=6)
           {
            ObjectSetText("HKl","Hong Kong ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("HKt",hongkongs,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("HKl","Hong Kong ",10,"Arial Black",labelColor);
            ObjectSetText("HKt",hongkongs,10,"Arial Black",clockColor);
           }
        }
      if(CNYHoliday>TimeCurrent())
        {
         ObjectSetText("HKl","Hong Kong market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("HKt",hongkongs,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------   
   if(Show_EUROPE)
     {
      if(EURHoliday<TimeCurrent())
        {
         if(StrToTime(frankfurts)>StrToTime("9:00") && StrToTime(frankfurts)<StrToTime("17:30") && TimeDayOfWeek(frankfurt)!=0 && TimeDayOfWeek(frankfurt)!=6)
           {
            ObjectSetText("berl","Europe ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("bert",frankfurts,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("berl","Europe ",10,"Arial Black",labelColor);
            ObjectSetText("bert",frankfurts,10,"Arial Black",clockColor);
           }
        }
      if(EURHoliday>TimeCurrent())
        {
         ObjectSetText("berl","European market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("bert",frankfurts,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------      
   if(Show_LONDON)
     {
      if(GBPHoliday<TimeCurrent())
        {
         if(StrToTime(londons)>StrToTime("8:00") && StrToTime(londons)<StrToTime("17:00") && TimeDayOfWeek(london)!=0 && TimeDayOfWeek(london)!=6)
           {
            ObjectSetText("lonl","UK ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("lont",londons,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("lonl","UK ",10,"Arial Black",labelColor);
            ObjectSetText("lont",londons,10,"Arial Black",clockColor);
           }
        }
      if(GBPHoliday>TimeCurrent())
        {
         ObjectSetText("lonl","London market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("lont",londons,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------               
   if(Show_NEW_YORK)
     {
      if(USDHoliday<TimeCurrent())
        {
         if(StrToTime(newyorks)>StrToTime("8:00") && StrToTime(newyorks)<StrToTime("17:00") && TimeDayOfWeek(newyork)!=0 && TimeDayOfWeek(newyork)!=6)
           {
            ObjectSetText("nyl","North America ",10,"Arial Black",ClockMktOpenColor);
            ObjectSetText("nyt",newyorks,10,"Arial Black",ClockMktOpenColor);
           }
         else
           {
            ObjectSetText("nyl","North America ",10,"Arial Black",labelColor);
            ObjectSetText("nyt",newyorks,10,"Arial Black",clockColor);
           }
        }
      if(USDHoliday>TimeCurrent())
        {
         ObjectSetText("nyl","New York market Holiday ",10,"Arial Black",ClockMktHolidayClr);
         ObjectSetText("nyt",newyorks,10,"Arial Black",ClockMktHolidayClr);
        }
     }
//---------------------------                  

   ObjectSetText("barl","Bar time",10,"Arial Black",labelColor);
   ObjectSetText("bart",bars,10,"Arial Black",clockColor);
   spread=NormalizeDouble((Ask-Bid)/Points,1);
   ObjectSetText("Spread Monitor1","Spread ",10,"Arial Black",labelColor);
   ObjectSetText("Spread Monitor2",DoubleToStr(spread,1),10,"Arial Black",clockColor);
//----  

   return(0);
  }
// -----------------------------------------------------------------------------------------------------------------------------
int DisplayTodaysNews()
  {
   string news[1][1];
   datetime time=TimeCurrent();
   if(time>=lastUpdate+update_interval*60)
     {
      DeleteNewsObjects();
      string str="";

      InitNews(news,time_zone_gmt,news_url);
      if(show_news_lines)
        {
         DrawNewsLines(news,show_line_text,news_high_color,news_medium_color,news_low_color);
        }
     }
   ShowNewsCountDown(show_min_before_news,1,news_high_color,news_medium_color,news_low_color,news_past_color,session_upcoming_title_color);
   return(0);
  }
// -----------------------------------------------------------------------------------------------------------------------------
string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec; 
//----
   sMonth=(string)(100+nMonth);
   sMonth=StringSubstr(sMonth,1);
   sDay=(string)(100+nDay);
   sDay=StringSubstr(sDay,1);
   sHour=(string)(100+nHour);
   sHour=StringSubstr(sHour,1);
   sMin=(string)(100+nMin);
   sMin=StringSubstr(sMin,1);
   sSec=(string)(100+nSec);
   sSec=StringSubstr(sSec,1);
//----
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
  }
// -----------------------------------------------------------------------------------------------------------------------------
int Explode(string str,string delimiter,string &arr[])
  {
   int i=0;
   int pos=StringFind(str,delimiter);
   while(pos!=-1)
     {
      if(pos==0) arr[i]=""; else arr[i]=StringSubstr(str,0,pos);
      i++;
      str = StringSubstr(str, pos+StringLen(delimiter));
      pos = StringFind(str, delimiter);
      if(pos==-1 || str=="") break;
     }
   arr[i]=str;

   return(i+1);
  }
// -----------------------------------------------------------------------------------------------------------------------------
datetime TimeArrayToTime(int &LocalTimeArray[])
  {
//---- parse date and time from array

   int    nYear,nMonth,nDOW=9,nDay,nHour,nMin,nSec,nMilliSec;
//string sMilliSec;

   nYear=LocalTimeArray[0]&0x0000FFFF;
   nMonth=LocalTimeArray[0]>>16;
//nDOW=LocalTimeArray[1]&0x0000FFFF;
   nDay=LocalTimeArray[1]>>16;
   nHour=LocalTimeArray[2]&0x0000FFFF;
   nMin=LocalTimeArray[2]>>16;
   nSec=LocalTimeArray[3]&0x0000FFFF;
   nMilliSec=LocalTimeArray[3]>>16;
   string LocalTimeS=FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
   datetime Local_Time=StrToTime(LocalTimeS);
   return(Local_Time);
  } // end of TimeArrayToTime
//+------------------------------------------------------------------+

// -----------------------------------------------------------------------------------------------------------------------------

// Used to find out if news curreny is of interest to current symbol/chart. 
// Will have to be changed if symbol format does not look like for example eurusd or usdjpy

bool IsNewsCurrency(string cSymbol,string fSymbol)
  {
   if(fSymbol == "usd") fSymbol = "USD";else
   if(fSymbol == "gbp") fSymbol = "GBP";else
   if(fSymbol == "eur") fSymbol = "EUR";else
   if(fSymbol == "cad") fSymbol = "CAD";else
   if(fSymbol == "aud") fSymbol = "AUD";else
   if(fSymbol == "chf") fSymbol = "CHF";else
   if(fSymbol == "jpy") fSymbol = "JPY";else
   if(fSymbol == "cny") fSymbol = "CNY";else
   if(fSymbol == "nzd") fSymbol = "NZD";

   if((auto) && (StringFind(cSymbol,fSymbol,0)>=0)){return(true);}
   if(!auto && show_usd && fSymbol == "USD"){return(true);}
   if(!auto && show_gbp && fSymbol == "GBP"){return(true);}
   if(!auto && show_eur && fSymbol == "EUR"){return(true);}
   if(!auto && show_cad && fSymbol == "CAD"){return(true);}
   if(!auto && show_aud && fSymbol == "AUD"){return(true);}
   if(!auto && show_chf && fSymbol == "CHF"){return(true);}
   if(!auto && show_jpy && fSymbol == "JPY"){return(true);}
   if(!auto && show_nzd && fSymbol == "NZD"){return(true);}
   if(!auto && show_cny && fSymbol == "CNY"){return(true);}
   return(false);
  }
// ----------------------------------------------------------------------------------------------------------------------------- 
void InitNews(string &news[][],int timeZone,string newsUrl)
  {
   if(DoFileDownLoad()) //Added to check if the CSV file already exists
     {
      DownLoadWebPageToFile(newsUrl); //downloading the CSV file
      lastUpdate=TimeCurrent();
     }
   if(CsvNewsFileToArray(news)==0)
      return;

   NormalizeNewsData(news,timeZone);
  }
// -----------------------------------------------------------------------------------------------------------------------------
bool DoFileDownLoad() // If we have recent file don't download again
  {
   int handle;
   datetime time=TimeCurrent();
   handle=FileOpen(NewsFileName(),FILE_READ);  //commando to open the file
   if(handle>0)//when the file exists we read data
     {
      FileClose(handle);//close it again check is done
      if(time >= lastUpdate+update_interval*60)return(true);
      return(false);//file exists no need to download again
     }
// File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
   return(true); //commando true to download CSV file
  }
// -----------------------------------------------------------------------------------------------------------------------------
void NormalizeNewsData(string &news[][],int timeDiffGmt,int startRow=1)
  {
   int totalNewsItems=ArraySize(news)-startRow;
   for(int i=0; i<totalNewsItems; i++)
     {
     
     ArrayResize(news,i+1,0);
      string tmp[3];
      Explode(news[i][COLUMN_DATE]," ",tmp);
      int mon=0;
      if(tmp[COLUMN_DATE_MONTH_STR]=="Jan") mon=1; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Feb") mon=2; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Mar") mon=3; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Apr") mon=4; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="May") mon=5; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Jun") mon=6; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Jul") mon=7; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Aug") mon=8; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Sep") mon=9; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Oct") mon=10; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Nov") mon=11; else
      if(tmp[COLUMN_DATE_MONTH_STR]=="Dec") mon=12;
      news[i][COLUMN_DATE]=(string)Year()+"."+(string)mon+"."+tmp[COLUMN_DATE_DAY_INT];

      if(news[i][COLUMN_TIME]=="")
        {
         news[i][COLUMN_TIME]="00:00";
         news[i][COLUMN_TIMEZONE]="ALL";
        }
      datetime dt=StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME]);

      // Adjust for time zone

      dt=dt+((timeDiffGmt)*3600);

      news[i][COLUMN_DATE] = TimeToStr(dt , TIME_DATE);
      news[i][COLUMN_TIME] = TimeToStr(dt , TIME_MINUTES);
     }
  }
// -----------------------------------------------------------------------------------------------------------------------------
int DownLoadWebPageToFile(string url="http://www.dailyfx.com/files/") // andre9@ya.ru
  {
   if((url == "http://www.dailyfx.com/files/")||(url=="https://nfs.faireconomy.media/ff_calendar_thisweek.xml")) 
      url = StringConcatenate(url,NewsFileName(true));

   if(!IsDllsAllowed())
     {
      Alert("Please allow DLL imports");
      return(0);
     }
   int result = InternetAttemptConnect(0);
   if(result != 0)
     {
      Alert("Cannot connect to internet - InternetAttemptConnect()");
      return 0;
     }
   int hInternetSession = InternetOpenW("Microsoft Internet Explorer", 0, "", "", 0);
   if(hInternetSession <= 0)
     {
      Alert("Cannot open internet session - InternetOpenA()");
      return 0;
     }
   int hURL=InternetOpenUrlW(hInternetSession,
                             url,"",0,0,0);
   if(hURL<=0)
     {
      Alert("Cannot open URL ",url," - InternetOpenUrlA()");
      InternetCloseHandle(hInternetSession);
      return(0);
     }
   int cBuffer[256];
   int dwBytesRead[1];
   string fileContents="";
   while(!IsStopped())
     {
      for(int i=0; i<256; i++) cBuffer[i]=0;
      bool bResult=InternetReadFile(hURL,cBuffer,1024,dwBytesRead);
      if(dwBytesRead[0]==0) break;
      string text="";
      for(int i=0; i<256; i++)
        {
        /* text=((string)(text+ CharToStr(cBuffer[i] >>0&0x000000FF)));
         if(StringLen(text)==dwBytesRead[0]) break;
         text=text+CharToStr(cBuffer[i] >>(8&0x000000FF));
         if(StringLen(text)==dwBytesRead[0]) break;
         text=text+CharToStr((cBuffer[i]>>16)& 0x000000FF);
         if(StringLen(text)==dwBytesRead[0]) break;
         text=text+CharToStr((cBuffer[i]>>2 )& 0x000000FF);
        */}
      fileContents=fileContents+text;
      Sleep(1);
     }
   InternetCloseHandle(hInternetSession);
// Save to text file  
   int handle;
   handle=FileOpen(NewsFileName(),FILE_CSV|FILE_WRITE,';');
   if(handle>0)
     {
      FileWrite(handle,fileContents);
      FileClose(handle);
     }
  return 0;}
// -----------------------------------------------------------------------------------------------------------------------------
// We will get news every sunday, so name file with sundays date
string NewsFileName(bool forDailyFXUrl=false)
  {
   int adjustDays=0;
   switch(TimeDayOfWeek(TimeLocal()))
     {
      case 0:
         adjustDays=0;
         break;
      case 1:
         adjustDays=1;
         break;
      case 2:
         adjustDays=2;
         break;
      case 3:
         adjustDays=3;
         break;
      case 4:
         adjustDays=4;
         break;
      case 5:
         adjustDays=5;
         break;
      case 6:
         adjustDays=6;
         break;
     }
   datetime date=TimeLocal() -(adjustDays *86400);
   string fileName="";
   if(TimeDayOfWeek(date)==0)// sunday
     {
      if(forDailyFXUrl) // if we are building URL to get file from daily fx site.
        {
         fileName=(StringConcatenate("Calendar-",PadString(DoubleToStr(TimeMonth(date),0),"0",2),"-",PadString(DoubleToStr(TimeDay(date),0),"0",2),"-",TimeYear(date),".csv"));
        }
      else
        {
         fileName=(StringConcatenate(TimeYear(date),"-",PadString(DoubleToStr(TimeMonth(date),0),"0",2),"-",PadString(DoubleToStr(TimeDay(date),0),"0",2),"-News",".csv"));
        }
     }
   return (fileName);
  }
// -----------------------------------------------------------------------------------------------------------------------------
string PadString(string toBePadded,string paddingChar,int paddingLength)
  {
   while(StringLen(toBePadded)<paddingLength)
     {
      toBePadded=StringConcatenate(paddingChar,toBePadded);
     }
   return (toBePadded);
  }
// -----------------------------------------------------------------------------------------------------------------------------

int CsvNewsFileToArray(string &lines[][],int numDelimItems=8,bool ignoreFirstLine=true,int freeTextCol=4)
  {   int lineCount=0;
   int handle;
   handle=FileOpen(NewsFileName(),FILE_READ,",");
   if(handle>0)
     {
   
      int lineNumber=0;
      bool processedFirstLine=false;
      while(!FileIsEnding(handle))
        {
         string lineData="";
         if(ArrayRange(lines,0)>lineCount)
           {
            for(int itemCount=0;itemCount<=numDelimItems; itemCount++)
              {

               lineData=FileReadString(handle);

               if(ignoreFirstLine && lineCount>0)
                 {

                  lineNumber=lineCount-1;
                  lines[lineNumber][itemCount]=lineData;

                  if(itemCount==freeTextCol)
                    {

                     for(int i=0; i<10; i++)
                       {
                        lineData=FileReadString(handle);
                        if(lineData=="Low" || lineData=="Medium" || lineData=="LOW" || lineData=="High" || lineData=="HIGH")
                          {
                           lines[lineNumber][freeTextCol+1]=lineData;
                           itemCount=freeTextCol+1;
                           break;
                          }
                        else
                          {
                           if(lineData!="")
                             {
                              lines[lineNumber][itemCount]=lines[lineNumber][itemCount]+", "+lineData;
                             }
                          }
                       }
                    }
                 }
              }
           }
         lineCount++;
        }

      ArrayResize(lines,lineCount);
      FileClose(handle);
     }
   else if(handle<1)
     {
      Print("File ",NewsFileName()," not found, the last error is ",GetLastError());
     }

   return(lineCount);
  }
// -----------------------------------------------------------------------------------------------------------------------------
int DeleteNewsObjects()
  {
   for(int i=0; i<1000; i++)
     {
      ObjectDelete("NewsLine"+(string)i);
      ObjectDelete("NewsText"+(string)i);
      ObjectDelete("NewsCountDown"+(string)i);
     }
   return(0);
  }
// -----------------------------------------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------------------------------------
void DrawNewsLines(string &news[][],bool showLineText,color high_color=Red,color medium_color=DarkOrange,color low_color=Blue,int startRow=1)
  {
   datetime local=TimeLocal();
   datetime broker=TimeCurrent();
   datetime current=0;
   double impact;
   bool skip;
   int totalNewsItems=ArrayRange(news,0)-startRow;
   if(Period()>PERIOD_H1)
      Print("Line text will only be shown for chart periods less than 4 hours");
   for(int i=0; i<totalNewsItems; i++)
     {
      skip=false;
      if(i>0)
        {
         if(news[i][COLUMN_TIME]!=news[i-1][COLUMN_TIME])impact=0;
        }
      else
         impact=0;
      string newsCurrency=news[i][COLUMN_CURRENCY];
      if(!IsNewsCurrency(Symbol(),newsCurrency)){skip=true;}
      if(!show_high_news && (news[i][COLUMN_IMPORTANCE]=="High" || news[i][COLUMN_IMPORTANCE]=="HIGH"))
        {skip=true;}
      if(!show_medium_news && news[i][COLUMN_IMPORTANCE]=="Medium")
        {skip=true;}
      if(!show_low_news && (news[i][COLUMN_IMPORTANCE]=="Low" || news[i][COLUMN_IMPORTANCE]=="LOW"))
        {skip=true;}
      if(news[i][COLUMN_TIME]=="All Day" ||
         news[i][COLUMN_TIME]== "Tentative" ||
         news[i][COLUMN_TIME]==""){skip=true;}
      if(!skip)
        {impact=0;
         if(ImpactToNumber(news[i][COLUMN_IMPORTANCE])>impact)impact=ImpactToNumber(news[i][COLUMN_IMPORTANCE]);
         if(StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])== current) continue;
         current=(broker-local)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME]);
         color clr = low_color;
         if(impact == 2) clr = medium_color;  else
         if(impact == 3)clr = high_color;

         string text="";
         if(news[i][COLUMN_PREVIOUS]!="" || news[i][COLUMN_FORECAST]!="") text="["+news[i][COLUMN_PREVIOUS]+", "+news[i][COLUMN_FORECAST]+"]";
         if(news[i][COLUMN_IMPORTANCE]!="") text=text+" "+news[i][COLUMN_IMPORTANCE];

         ObjectCreate("NewsLine"+(string)i,OBJ_VLINE,0,current,0);
         ObjectSet("NewsLine"+(string)i,OBJPROP_COLOR,clr);
         ObjectSet("NewsLine"+(string)i,OBJPROP_STYLE,STYLE_DASHDOTDOT);
         ObjectSet("NewsLine"+(string)i,OBJPROP_BACK,true);
         ObjectSetText("NewsLine"+(string)i,news[i][COLUMN_DATE]+" "+news[i][COLUMN_DESCRIPTION]+" "+text,8);

         if(showLineText)
           {
            if(Period()<PERIOD_H4)
              {
               ObjectCreate("NewsText"+(string)i,OBJ_TEXT,0,current,WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())*0.8);
               ObjectSet("NewsText"+(string)i,OBJPROP_COLOR,clr);
               ObjectSet("NewsText"+(string)i,OBJPROP_ANGLE,90);
               ObjectSetText("NewsText"+(string)i,news[i][COLUMN_DATE]+" "+news[i][COLUMN_DESCRIPTION]+" "+text,8);
              }
                 
           }
        }

     }
  }
// -----------------------------------------------------------------------------------------------------------------------------
double ImpactToNumber(string impact)
  {
   if(impact=="High" || impact=="HIGH")
      return (3);
   if(impact=="Medium")
      return (2);
   if(impact=="Low" || impact=="LOW")
      return (1);
   else
      return (0);
  }
// -----------------------------------------------------------------------------------------------------------------------------
void ShowNewsCountDown(int alertMinsBeforeNews=60,int startRow=1,color high_color=Red,
                       color medium_color=DarkOrange,color low_color=Blue,color past_color=Gray,color title_color=Purple)
  {
  
  string news[2][1];
   bool skip;
   int alertBeforeNews= alertMinsBeforeNews*60;
   int totalNewsItems = ArrayRange(news,0)-startRow;
   for(int iCount=1; iCount<20; iCount++)
     {
      ObjectDelete("NewsCountDown"+(string)iCount);
      ObjectDelete("NewsCountDown"+(string)iCount);
     }
   int noOfAlerts=0;
   for(int i=totalNewsItems-1; i>0; i--)//looking to all newsitems
     { 
     
     
      datetime newsDate=StrToTime(TimeToStr(StrToTime(news[i][COLUMN_DATE]),TIME_DATE)+" "+news[i][COLUMN_TIME]);
      if(TimeDay(newsDate)==TimeDay(TimeLocal()))//news for today
         //       if(TimeDay(newsDate) == TimeDay(GMT))//news for today
        {
         skip=false;
         if(StringFind(news[i][COLUMN_DESCRIPTION],"Bank Holiday",0)>=0)
           {
            if(CurTime()>=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME]))
              {
               if(news[i][COLUMN_CURRENCY]=="NZD"){NZDHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="AUD"){AUDHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="JPY"){JPYHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="CNY"){CNYHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="EUR"){EURHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="GBP"){GBPHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="USD"){USDHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="nzd"){NZDHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="aud"){AUDHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="jpy"){JPYHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="cny"){CNYHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="eur"){EURHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="gbp"){GBPHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
               if(news[i][COLUMN_CURRENCY]=="usd"){USDHoliday=(CurTime()-localTime)+StrToTime(news[i][COLUMN_DATE]+" "+news[i][COLUMN_TIME])+86400;}
              }
           }
         int timediff=(int)(newsDate-TimeLocal());// alertMinsBeforeNews display the minutes before news
         if(alertBeforeNews>=timediff && timediff>-3600) // display until 60 mins after news event
           {
            string newsCurrency=news[i][COLUMN_CURRENCY];
            if(!IsNewsCurrency(Symbol(),newsCurrency)){skip=true;}
            string importance=news[i][COLUMN_IMPORTANCE];
            if(!show_high_news && (news[i][COLUMN_IMPORTANCE]=="High" || news[i][COLUMN_IMPORTANCE]=="HIGH"))
              {skip=true;}
            if(!show_medium_news && news[i][COLUMN_IMPORTANCE]=="Medium")
              {skip=true;}
            if(!show_low_news && (news[i][COLUMN_IMPORTANCE]=="LOW" || news[i][COLUMN_IMPORTANCE]=="Low"))
              {skip=true;}
            if(news[i][COLUMN_TIME]=="All Day" ||
               news[i][COLUMN_TIME]== "Tentative" ||
               news[i][COLUMN_TIME]==""){skip=true;}

            if(!skip)
              {
               color textColor=low_color;
               if(news[i][COLUMN_IMPORTANCE]=="Medium")
                 {
                  textColor=medium_color;
                 }
               if(news[i][COLUMN_IMPORTANCE]=="High" || news[i][COLUMN_IMPORTANCE]=="HIGH")
                 {
                  textColor=high_color;
                 }
               if(timediff<0)
                  textColor=past_color;

               noOfAlerts++;
               int yDistance=45+(noOfAlerts*15);
               string timeDiffString=TimeToStr(MathAbs(timediff),TIME_MINUTES|TIME_SECONDS);
               string description=StringSubstr(news[i][COLUMN_DESCRIPTION],0,40)+" "+timeDiffString;
               ObjectCreate("NewsCountDown"+(string)noOfAlerts,OBJ_LABEL,0,0,0,0,0);
               ObjectSet("NewsCountDown"+(string)noOfAlerts,OBJPROP_CORNER,1);
               ObjectSet("NewsCountDown"+(string)noOfAlerts,OBJPROP_XDISTANCE,4);
               ObjectSet("NewsCountDown"+(string)noOfAlerts,OBJPROP_YDISTANCE,yDistance);
               ObjectSet("NewsCountDown"+(string)noOfAlerts,OBJPROP_BACK,true);
               ObjectSetText("NewsCountDown"+(string)noOfAlerts,description,10,"Arial Black",textColor);
              }
           }
        }
     }
   if(noOfAlerts>0)
     {
      ObjectCreate("NewsCountDown0",OBJ_LABEL,0,0,0,0,0);
      ObjectSet("NewsCountDown0",OBJPROP_CORNER,1);
      ObjectSet("NewsCountDown0",OBJPROP_XDISTANCE,4);
      ObjectSet("NewsCountDown0",OBJPROP_YDISTANCE,45);
      if(auto){ObjectSetText("NewsCountDown0","Your News Events this Currency",10,"Arial Black",title_color);}
      ObjectSetText("NewsCountDown0","Upcoming/Recent News Events",10,"Arial Black",title_color);
     }
  }
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT_Offset(string region,datetime dt1)
  {
   int r1=0;
   if(region=="LONDON")
      r1=GMT0(dt1);
   else if(region=="US")
      r1=GMT_5(dt1);
   else if(region=="FRANKFURT")
      r1=GMT1(dt1);
   else if(region=="HONGKONG")
      r1=GMT8(dt1);
   else if(region=="TOKYO")
      r1=GMT9(dt1);
   else if(region=="SYDNEY")
      r1=GMT11(dt1);
   else if(region=="AUCKLAND")
      r1=GMT12(dt1);

   return (r1);
  }
//+------------------------------------------------------------------+
//| London     DST ===  Standard and Summertime setting              |
//+------------------------------------------------------------------+
int GMT0(datetime dt1)
  {
//UK Standard Time = GMT
//UK Summer Time = BST (British Summer time) = GMT+1
//For 2003-2007 inclusive, the summer-time periods begin and end respectively on 
//the following dates at 1.00am Greenwich Mean Time:
//2003: the Sundays of 30 March and 26 October
//2004: the Sundays of 28 March and 31 October
//2005: the Sundays of 27 March and 30 October
//2006: the Sundays of 26 March and 29 October
//2007: the Sundays of 25 March and 28 October
   if((dt1>last_sunday(TimeYear(dt1),3)) && (dt1<last_sunday(TimeYear(dt1),10)))
      return(1);//summer
   else
      return(0);
  }
//+------------------------------------------------------------------+
//| Frankfurt     DST ===  Standard and Summertime setting           |
//+------------------------------------------------------------------+
int GMT1(datetime dt1)
  {
//Standard Time = GMT +1
//Summer Time = GMT+2
//For 2003-2007 inclusive, the summer-time periods begin and end respectively on 
//the following dates at 1.00am Greenwich Mean Time:
//2003: the Sundays of 30 March and 26 October
//2004: the Sundays of 28 March and 31 October
//2005: the Sundays of 27 March and 30 October
//2006: the Sundays of 26 March and 29 October
//2007: the Sundays of 25 March and 28 October
   if((dt1>last_sunday(TimeYear(dt1),3)) && (dt1<last_sunday(TimeYear(dt1),10)))
      return(2);//summer
   else
      return(1);
  }
//+------------------------------------------------------------------+
//| New York   US times                                              |
//+------------------------------------------------------------------+
int GMT_5(datetime dt1)
  {
/*US
//-------------------------------------------------------------------
//Eastern Standard Time (EST) = GMT-5
//-------------------------------------------------------------------
//Eastern Daylight Time (EDT) = GMT-4
//-----+--------------------------+----------------------------------
//Year | 	DST Begins 2 a.m.     |     DST Ends 2 a.m.
//1990-|                          |
//2006 |  (First Sunday in April) |	(Last Sunday in October)
//-----+--------------------------+----------------------------------                                  
//-----+--------------------------+----------------------------------
//Year | 	DST Begins 2 a.m.     |     DST Ends 2 a.m.
//2007-|  (Second Sunday in March)|	(First Sunday in November)
//-----+--------------------------+----------------------------------
year     DST begins                 DST ends
2000     zondag, 2 april, 02:00     zondag, 29 oktober, 02:00
2001     zondag, 1 april, 02:00     zondag, 28 oktober, 02:00
2002     zondag, 7 april, 02:00     zondag, 27 oktober, 02:00
2003     zondag, 6 april, 02:00     zondag, 26 oktober, 02:00
2004     zondag, 4 april, 02:00     zondag, 31 oktober, 02:00
2005     zondag, 3 april, 02:00     zondag, 30 oktober, 02:00
2006     zondag, 2 april, 02:00     zondag, 29 oktober, 02:00

2007     zondag, 11 maart, 02:00    zondag, 4 november, 02:00
2008     zondag, 9 maart, 02:00     zondag, 2 november, 02:00
2009     zondag, 8 maart, 02:00     zondag, 1 november, 02:00
2010     zondag, 14 maart, 02:00    zondag, 7 november, 02:00
2011     zondag, 13 maart, 02:00    zondag, 6 november, 02:00
2012     zondag, 11 maart, 02:00    zondag, 4 november, 02:00
2013     zondag, 10 maart, 02:00    zondag, 3 november, 02:00
2014     zondag, 9 maart, 02:00     zondag, 2 november, 02:00
2015     zondag, 8 maart, 02:00     zondag, 1 november, 02:00
2016     zondag, 13 maart, 02:00    zondag, 6 november, 02:00
2017     zondag, 12 maart, 02:00    zondag, 5 november, 02:00
2018     zondag, 11 maart, 02:00    zondag, 4 november, 02:00
2019     zondag, 10 maart, 02:00    zondag, 3 november, 02:00
                                  
*/
   if(TimeYear(dt1)<2007)
      if((dt1>sunday_number(TimeYear(dt1),4,1)) && (dt1<last_sunday(TimeYear(dt1),10)))
         return(-4);
   else
      return(-5);
   else
   if(TimeYear(dt1)>=2007)
                     if((dt1>sunday_number(TimeYear(dt1),3,2)) && (dt1<sunday_number(TimeYear(dt1),11,1)))
                     return(-4);
   else
      return(-5);

  return 0;}
//+------------------------------------------------------------------+
//|  Hong Kong  CNY                                                  |
//+------------------------------------------------------------------+
int GMT8(datetime dt1)
  {
   return(8);//standard NO DST =summer=+8
  }
//+------------------------------------------------------------------+
//|  Tokyo  JPY                                                      |
//+------------------------------------------------------------------+
int GMT9(datetime dt1)
  {
   return(9);//standard NO DST =summer=+9
  }
//+------------------------------------------------------------------+
int GMT11(datetime dt1)
  {
/*+------------------------------------------------------------------+
//|   Sydney    AUD                                                  |
//+------------------------------------------------------------------+
//|   Eastern Standard Time (EST) = GMT+10   No DST                  |
//|   Eastern Daylight Time (EDT) = GMT+11   DST                     |
//+-----+--------------------------+---------------------------------+
year     enddate                       startdate
2000     zondag, 26 maart, 03:00       zondag, 27 augustus, 02:00
2001     zondag, 25 maart, 03:00       zondag, 28 oktober, 02:00
2002     zondag, 31 maart, 03:00       zondag, 27 oktober, 02:00
2003     zondag, 30 maart, 03:00       zondag, 26 oktober, 02:00
2004     zondag, 28 maart, 03:00       zondag, 31 oktober, 02:00
2005     zondag, 27 maart, 03:00       zondag, 30 oktober, 02:00

2006     zondag, 2 april, 03:00        zondag, 29 oktober, 02:00

2007     zondag, 25 maart, 03:00       zondag, 28 oktober, 02:00

2008     zondag, 6 april, 03:00        zondag, 5 oktober, 02:00
2009     zondag, 5 april, 03:00        zondag, 4 oktober, 02:00
2010     zondag, 4 april, 03:00        zondag, 3 oktober, 02:00
2011     zondag, 3 april, 03:00        zondag, 2 oktober, 02:00
2012     zondag, 1 april, 03:00        zondag, 7 oktober, 02:00
2013     zondag, 7 april, 03:00        zondag, 6 oktober, 02:00
2014     zondag, 6 april, 03:00        zondag, 5 oktober, 02:00
2015     zondag, 5 april, 03:00        zondag, 4 oktober, 02:00
2016     zondag, 3 april, 03:00        zondag, 2 oktober, 02:00
2017     zondag, 2 april, 03:00        zondag, 1 oktober, 02:00
2018     zondag, 1 april, 03:00        zondag, 7 oktober, 02:00
2019     zondag, 7 april, 03:00        zondag, 6 oktober, 02:00

//-----+--------------------------+----------------------------------         
*/
   if(TimeYear(dt1)<1996)
      if((dt1>sunday_number(TimeYear(dt1),3,1)) && (dt1<last_sunday(TimeYear(dt1),10)))
         return(10);
   else
      return(11);
   else
   if((TimeYear(dt1)>=1996 && TimeYear(dt1)<2008) && (TimeYear(dt1)!=2006))
                      if((dt1>last_sunday(TimeYear(dt1),3)) && (dt1<last_sunday(TimeYear(dt1),10)))
                      return(10);
   else
      return(11);
   else
   if(TimeYear(dt1)==2006)
   if((dt1>sunday_number(TimeYear(dt1),4,1)) && (dt1<last_sunday(TimeYear(dt1),10)))
      return(10);
   else
      return(11);
   else
   if(TimeYear(dt1)>=2008)
                     if((dt1>sunday_number(TimeYear(dt1),4,1)) && (dt1<sunday_number(TimeYear(dt1),10,1)))
                     return(10);
   else
      return(11);
  return 0;}
//+------------------------------------------------------------------+
int GMT12(datetime dt1)
  {
/*+------------------------------------------------------------------+
//|   New Zealand  Auckland   NZD                                    |
//+------------------------------------------------------------------+
//|   Eastern Standard Time (EST) = GMT+12   No DST                  |
//|   Eastern Daylight Time (EDT) = GMT+13   DST                     |
//+-----+--------------------------+---------------------------------+
year     enddate                       startdate
2000     zondag, 19 maart, 03:00       zondag, 1 oktober, 02:00
2001     zondag, 18 maart, 03:00       zondag, 7 oktober, 02:00
2002     zondag, 17 maart, 03:00       zondag, 6 oktober, 02:00
2003     zondag, 16 maart, 03:00       zondag, 5 oktober, 02:00
2004     zondag, 21 maart, 03:00       zondag, 3 oktober, 02:00
2005     zondag, 20 maart, 03:00       zondag, 2 oktober, 02:00
2006     zondag, 19 maart, 03:00       zondag, 1 oktober, 02:00

2007     zondag, 18 maart, 03:00       zondag, 30 september, 02:00
2008     zondag, 6 april, 03:00        zondag, 28 september, 02:00
2009     zondag, 5 april, 03:00        zondag, 27 september, 02:00
2010     zondag, 4 april, 03:00        zondag, 26 september, 02:00
2011     zondag, 3 april, 03:00        zondag, 25 september, 02:00
2012     zondag, 1 april, 03:00        zondag, 30 september, 02:00
2013     zondag, 7 april, 03:00        zondag, 29 september, 02:00
2014     zondag, 6 april, 03:00        zondag, 28 september, 02:00
2015     zondag, 5 april, 03:00        zondag, 27 september, 02:00
2016     zondag, 3 april, 03:00        zondag, 25 september, 02:00
2017     zondag, 2 april, 03:00        zondag, 24 september, 02:00
2018     zondag, 1 april, 03:00        zondag, 30 september, 02:00
2019     zondag, 7 april, 03:00        zondag, 29 september, 02:00

//-----+--------------------------+----------------------------------         
*/
   if(TimeYear(dt1)<2007)
      if((dt1>sunday_number(TimeYear(dt1),3,3)) && (dt1<sunday_number(TimeYear(dt1),10,1)))
         return(12);
   else
      return(13);
   else
   if(TimeYear(dt1)==2007)
   if((dt1>sunday_number(TimeYear(dt1),3,3)) && (dt1<last_sunday(TimeYear(dt1),9)))
      return(12);
   else
      return(13);
   else
   if(TimeYear(dt1)>2007)
   if((dt1>sunday_number(TimeYear(dt1),4,1)) && (dt1<last_sunday(TimeYear(dt1),9)))
      return(12);
   else
      return(13);

   return(13);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_leap_year(int year1)
  {

   if((MathMod(year1,100)==0) && (MathMod(year1,400)==0))
      return(true);
   else if((MathMod(year1,100)!=0) && (MathMod(year1,4)==0))
                                return(true);
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int n_days(int year1,int month1)
  {
   int ndays1=0;
   if(month1==1)
      ndays1=31;
   else if(month1==2)
     {
      if(is_leap_year(year1))
         ndays1=29;
      else
         ndays1=28;
     }
   else if(month1==3)
      ndays1=31;
   else if(month1==4)
      ndays1=30;
   else if(month1==5)//mai
   ndays1=31;
   else if(month1==6)//iun          
   ndays1=30;
   else if(month1==7)//iul          
   ndays1=31;
   else if(month1==8)//aug          
   ndays1=31;
   else if(month1==9)//sep          
   ndays1=30;
   else if(month1==10)//oct          
   ndays1=31;
   else if(month1==11)//nov          
   ndays1=30;
   else if(month1==12)
      ndays1=31;

   return(ndays1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int n_sdays(int year1,int month1)
  {
   datetime ddt2;
   int ndays2=n_days(year1,month1);
   int i,nsun1=0;
   for(i=1;i<=ndays2;i++)
     {
      ddt2=StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");
      if(TimeDayOfWeek(ddt2)==0)
         nsun1=nsun1+1;
     }
   return(nsun1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime last_sunday(int year1,int month1)
  {
   int i,ndays2,nsun1,nsun2;
   datetime dt2=0,dt3=0;
   ndays2=n_days(year1,month1);
   nsun2=n_sdays(year1,month1);
   nsun1=0;
   for(i=1;i<=ndays2;i++)
     {
      dt2=StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");
      if(TimeDayOfWeek(dt2)==0)
        {
         nsun1=nsun1+1;
        }
      if(nsun1==nsun2)
        {
         dt3=dt2;
         break;
        }
     }
   return(dt3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

datetime sunday_number(int year1,int month1,int sundaycount)
  {
   int i,ndays2,nsun1,nsun2;
   datetime dt2=0,dt3=0;
   ndays2=n_days(year1,month1);
   nsun2=sundaycount;//n_sdays(year1,month1);
   nsun1=0;
   for(i=1;i<=ndays2;i++)
     {
      dt2=StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");
      if(TimeDayOfWeek(dt2)==0)
        {
         nsun1=nsun1+1;
        }
      if(nsun1==nsun2)
        {
         dt3=dt2;
         break;
        }
     }
   return(dt3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplaySessionInfo()
  {
   string openSessions="Active sessions: ";
   string closingSession="";
//----
// info from http://www.2011.worldmarkethours.com/Forex/index1024.htm
// New Zealand/Auckland.............: 10.00 - 16.45   localtimes timezone country
// Australia/Sydney local session...: 10.00 - 17.00
// Japan/Tokyo......................:  9.00 - 12.30    Re-opens  14.00 - 17.00 
// Hong Kong........................: 10.00 - 17.00
// Europe...........................:  9.00 - 17.30
// London local session.............: 08.00 - 17.00
// New York local session...........: 08.00 - 17.00


//New Zealand....: 10.00 - 16.45
   if(NZDHoliday<TimeCurrent())
     {
      if((StrToTime(aucklands)>StrToTime("9:45")) && (StrToTime(aucklands)<StrToTime("10:00")) && TimeDayOfWeek(auckland)!=0 && TimeDayOfWeek(auckland)!=6)
        {closingSession="New Zealand opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if((StrToTime(aucklands)>StrToTime("10:00")) && (StrToTime(aucklands)<StrToTime("16:45")) && TimeDayOfWeek(auckland)!=0 && TimeDayOfWeek(auckland)!=6)
        {
         openSessions=openSessions+" New Zealand";
         if(TimeHour(auckland)==16 && TimeMinute(auckland)>14 && TimeMinute(auckland)<45)
           {
            closingSession="New Zealand closing in "+(string)(45-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }
//Australia...: 10.00 - 17.00
   if(AUDHoliday<TimeCurrent())
     {
      if((StrToTime(sydneys)>StrToTime("9:45")) && (StrToTime(sydneys)<StrToTime("10:00")) && TimeDayOfWeek(sydney)!=0 && TimeDayOfWeek(sydney)!=6)
        {closingSession="Australia opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if((StrToTime(sydneys)>StrToTime("10:00")) && (StrToTime(sydneys)<StrToTime("17:00")) && TimeDayOfWeek(sydney)!=0 && TimeDayOfWeek(sydney)!=6)
        {
         openSessions=openSessions+" Australia";
         if(TimeHour(sydney)==16 && TimeMinute(sydney)>29)
           {
            closingSession="Australia closing in "+(string)(60-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }
//Japan ....:  9.00 - 12.30    Re-opens  14.00 - 17.00
   if(JPYHoliday<TimeCurrent())
     {
      if(StrToTime(tokyos)>=StrToTime("8:45") && StrToTime(tokyos)<StrToTime("9:00") && TimeDayOfWeek(tokyo)>0 && TimeDayOfWeek(tokyo)<6)
        {closingSession="Tokyo first session opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if(TimeHour(tokyo)>=9 && TimeHour(tokyo)<17 && TimeDayOfWeek(tokyo)>0 && TimeDayOfWeek(tokyo)<6)
        {
         if((StrToTime(tokyos)>StrToTime("9:00")) && (StrToTime(tokyos)<StrToTime("12:30")) && TimeDayOfWeek(tokyo)!=0 && TimeDayOfWeek(tokyo)!=6)
           {openSessions=openSessions+" Tokyo";}
         if(StrToTime(tokyos)>=StrToTime("13:45") && StrToTime(tokyos)<StrToTime("14:00") && TimeDayOfWeek(tokyo)>0 && TimeDayOfWeek(tokyo)<6)
           {closingSession="Tokyo second session opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
         if((StrToTime(tokyos)>StrToTime("14:00")) && (StrToTime(tokyos)<StrToTime("17:00")) && TimeDayOfWeek(tokyo)!=0 && TimeDayOfWeek(tokyo)!=6)
           {openSessions=openSessions+" Tokyo";}
         if(TimeHour(tokyo)==16 && TimeMinute(tokyo)>29)
           {
            closingSession="Tokyo final closing in "+(string)(60-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }
//Hong Kong..: 10.00 - 17.00
   if(CNYHoliday<TimeCurrent())
     {
      if(StrToTime(hongkongs)>=StrToTime("9:45") && StrToTime(hongkongs)<StrToTime("10:00") && TimeDayOfWeek(london)>0 && TimeDayOfWeek(london)<6)
        {closingSession="Hong Kong opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if((StrToTime(hongkongs)>StrToTime("10:00")) && (StrToTime(hongkongs)<StrToTime("17:00")) && TimeDayOfWeek(hongkong)!=0 && TimeDayOfWeek(hongkong)!=6)
        {
         openSessions=openSessions+" Hong Kong";
         if(TimeHour(hongkong)==16 && TimeMinute(hongkong)>29)
           {
            closingSession="Hong Kong closing in "+(string)(60-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }
//Europe...:  9.00 - 17.30
   if(EURHoliday<TimeCurrent())
     {
      if(StrToTime(frankfurts)>=StrToTime("8:45") && StrToTime(frankfurts)<StrToTime("9:00") && TimeDayOfWeek(london)>0 && TimeDayOfWeek(london)<6)
        {closingSession="Europe opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if((StrToTime(frankfurts)>StrToTime("9:00")) && (StrToTime(frankfurts)<StrToTime("17:30")) && TimeDayOfWeek(frankfurt)!=0 && TimeDayOfWeek(frankfurt)!=6)
        {
         openSessions=openSessions+" Europe";
         if(TimeHour(frankfurt)==17 && TimeMinute(frankfurt)<30)
           {
            closingSession="Europe closing in "+(string)(30-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }
// London....: 08.00 - 17.00
   if(GBPHoliday<TimeCurrent())
     {
      if(StrToTime(londons)>=StrToTime("7:45") && StrToTime(londons)<StrToTime("8:00") && TimeDayOfWeek(london)>0 && TimeDayOfWeek(london)<6)
        {closingSession="London opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if(TimeHour(london)>=8 && TimeHour(london)<17 && TimeDayOfWeek(london)>0 && TimeDayOfWeek(london)<6)
        {
         openSessions=openSessions+" London";
         if(TimeHour(london)==16 && TimeMinute(london)>29)
           {
            closingSession="London closing in "+(string)(60-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }
// New York....: 08.00 - 17.00
   if(USDHoliday<TimeCurrent())
     {
      if(StrToTime(newyorks)>=StrToTime("7:45") && StrToTime(newyorks)<StrToTime("8:00") && TimeDayOfWeek(newyork)>0 && TimeDayOfWeek(newyork)<6)
        {closingSession="New York opens in "+(string)(60-TimeMinute(TimeLocal()))+" mins";}
      if(TimeHour(newyork)>=8 && TimeHour(newyork)<17 && TimeDayOfWeek(newyork)>0 && TimeDayOfWeek(newyork)<6)
        {
         openSessions=openSessions+" New York";
         if(TimeHour(newyork)==16)
           {
            closingSession="New York closing in "+(string)(60-TimeMinute(TimeLocal()))+" mins";
           }
        }
     }

   string TimeLeft=TimeToStr((iTime(NULL,Period(),0)+Period()*60-TimeCurrent()),TIME_MINUTES|TIME_SECONDS);
//----
   if(openSessions=="Active sessions: ") openSessions="Markets Closed";
   ObjectSetText("OpenSessions",openSessions,12,"Arial Black",session_upcoming_title_color);
   ObjectSetText("BarClosing","Time to bar close "+TimeLeft,10,"Arial Black",bar_closing_color);
   ObjectSetText("SessionClosing",closingSession,10,"Arial Black",session_closing_color);

  }
//+------------------------------------------------------------------+ 

void CreateInfoObjects()
  {
   ObjectCreate("OpenSessions",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("OpenSessions",OBJPROP_CORNER,1);
   ObjectSet("OpenSessions",OBJPROP_XDISTANCE,4);
   ObjectSet("OpenSessions",OBJPROP_YDISTANCE,0);
   ObjectSetText("OpenSessions","",12,"Arial Black",session_upcoming_title_color);

   ObjectCreate("SessionClosing",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("SessionClosing",OBJPROP_CORNER,1);
   ObjectSet("SessionClosing",OBJPROP_XDISTANCE,4);
   ObjectSet("SessionClosing",OBJPROP_YDISTANCE,15);

   ObjectCreate("BarClosing",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("BarClosing",OBJPROP_CORNER,1);
   ObjectSet("BarClosing",OBJPROP_XDISTANCE,4);
   ObjectSet("BarClosing",OBJPROP_YDISTANCE,30);
   ObjectSetText("BarClosing","",10,"Arial Black",bar_closing_color);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void DeleteSessionInfoObjects()
  {
   ObjectDelete("OpenSessions");
   ObjectDelete("BarClosing");
   ObjectDelete("SessionClosing");
  }
//+------------------------------------------------------------------+
string TimeToString1(datetime when)
  {
   if(!show12HourTime)
      return (TimeToStr( when, TIME_MINUTES ));
   int hour=TimeHour(when);
   int minute=TimeMinute(when);

   string ampm=" AM";

   string timeStr;
   if(hour>=12)
     {
      hour = hour - 12;
      ampm = " PM";
     }

   if(hour == 0 )
      hour = 12;
   timeStr = DoubleToStr( hour, 0 ) + ":";
   if(minute<10)
      timeStr=timeStr+"0";
   timeStr = timeStr + DoubleToStr( minute, 0 );
   timeStr = timeStr + ampm;

   return (timeStr);
  }
// -----------------------------------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ObjectMakeLabel(string n,int xoff,int yoff)
  {
   ObjectCreate(n,OBJ_LABEL,0,0,0);
   ObjectSet(n,OBJPROP_CORNER,Clockcorner);
   ObjectSet(n,OBJPROP_XDISTANCE,xoff);
   ObjectSet(n,OBJPROP_YDISTANCE,yoff);
   ObjectSet(n,OBJPROP_BACK,true);
  return 0;}
//deal with five digit broker
void HandleDigits()
  {
// Automatically handles full-pip and sub-pip accounts
   if(Digits==4 || Digits==2)
     {
      Points=Point;
     }
   if(Digits==5 || Digits==3)
     {
      Points=Point*10;
     }
  }
//+------------------------------------------------------------------+




























// BUFFERs

double dBufBuy[], dBufSell[], dBufExitBuy[], dBufExitSell[], dBufSL[];

//--- indicator buffers

double Buffer1[];
double Buffer2[];

double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];

double Buffer7[];
double Buffer8[];
double Buffer9[];
datetime time_alert=0; //used when sending alert
string   ShortName,Unique;
int      DrawBeginBar,DrawEndBar,Window;
double   Equity[],Balance[],Margin[],Free[],Zero[];
double   ResultBalance,ResultProfit,GrowthRatio;
double   ProfitLoss,Spread,SumMargin,LotValue;
double   PeakProfit,PeakEquity,MaxDrawdown,RelDrawdown;
double   SumProfit,SumLoss,NetProfit;
double   RecoveryFactor,ProfitFactor,Profitability;
string   Instrument[];
datetime OpenTime_Ticket[][2],CloseTime[];
int      OpenBar[],CloseBar[],Type[];
double   Lots[],OpenPrice[],ClosePrice[],Commission[],Swap[],CumSwap[],DaySwap[],Profit[];
datetime start_time,finish_time;
int      Total,HistoryTotal,OpenTotal;
string   missing_symbols;
bool     alert_upper_active,alert_lower_active;
bool     using_filters;

bool ChartColorSet()//set chart colors
  {
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,Bear Candle);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,Bull Candle);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,Bear_Outline);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,Bull_Outline);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID,0);
   ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,false);
   ChartSetInteger(ChartID(),CHART_MODE,1);
   ChartSetInteger(ChartID(),CHART_SHIFT,1);
   ChartSetInteger(ChartID(),CHART_SHOW_ASK_LINE,1);
   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,BackGround);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,ForeGround);
   return(true);
  }  
int myPoint=(int)Point();

void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      Print(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("TrendsFollowers", type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen("TrendsFollowers.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

void DrawLine(string objname, double price, int count, int start_index) //creates or modifies existing object if necessary
  {
   if((price < 0) && ObjectFind(objname) >= 0)
     {
      ObjectDelete(objname);
     }
   else if(ObjectFind(objname) >= 0 && ObjectType(objname) == OBJ_TREND)
     {
      ObjectSet(objname, OBJPROP_TIME1, Time[start_index]);
      ObjectSet(objname, OBJPROP_PRICE1, price);
      ObjectSet(objname, OBJPROP_TIME2, Time[start_index+count-1]);
      ObjectSet(objname, OBJPROP_PRICE2, price);
     }
   else
     {
      ObjectCreate(objname, OBJ_TREND, 0, Time[start_index], price, Time[start_index+count-1], price);
      ObjectSet(objname, OBJPROP_RAY, false);
      ObjectSet(objname, OBJPROP_COLOR, C'0x00,0x00,0xFF');
      ObjectSet(objname, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(objname, OBJPROP_WIDTH, 2);
     }
  }

double Support(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
  
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = Low[iLowest(NULL, 0, MODE_LOW, count, start_index)];
   if (draw) DrawLine("Support", ret, count, start_index);
   return(ret);
  }

double Resistance(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {

      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = High[iHighest(NULL, 0, MODE_HIGH, count, start_index)];
   if (draw) DrawLine("Resistance", ret, count, start_index);
   return(ret);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {    ChartColorSet();
   IndicatorBuffers(25);
Comment("                                                                         \n\n\n\n\n\n\n\nContact : https://t.me/tradeexpert_infos\n\nEmail:nguemechieu@live.com"  );
 
	SetIndexBuffer    (0, Buffer1);
	SetIndexEmptyValue(0, 0.0);
	SetIndexStyle     (0, DRAW_ARROW);
	SetIndexArrow     (0, 233);					// full arrow up	
	SetIndexLabel		(0, "SI BUY");
	
	SetIndexBuffer    (1, Buffer2);
	SetIndexEmptyValue(1, 0.0);
	SetIndexStyle     (1, DRAW_ARROW);
	SetIndexArrow     (1, 234);					// full arrow down	
	SetIndexLabel		(1, "SI SELL");
 
	SetIndexBuffer    (2, Buffer3);
	SetIndexEmptyValue(2, 0.0);
	SetIndexStyle     (2, DRAW_ARROW);
	SetIndexArrow     (2, 240);					// cross	
	SetIndexLabel		(2, "SI SELL EXIT");

	SetIndexBuffer    (3, Buffer4);
	SetIndexEmptyValue(3, 0.0);
	SetIndexStyle     (3, DRAW_ARROW);
	SetIndexArrow     (3, 242);					// cross	
	SetIndexLabel		(3, "SI BUY EXIT");
	
	SetIndexBuffer    (4, dBufSL);
	SetIndexEmptyValue(4, 0.0);
	SetIndexStyle     (4, DRAW_LINE, STYLE_DASH);
	SetIndexLabel		(4, "SI SL");
	
	inits();
	 initforexclock();
	
   //initialize myPoint
   myPoint =(int) Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int inits()
  {
   using_filters=false;
   if(Only_Symbols!="")    using_filters=true;
   if(Only_Comment!="")    using_filters=true;
   if(Only_Current)        using_filters=true;
   if(Only_Buys)           using_filters=true;
   if(Only_Sells)          using_filters=true;
   if(Only_Magics)         using_filters=true;

   if(!using_filters)
      ShortName="Total"; else ShortName="";
   if(Only_Symbols!="")
      ShortName=StringConcatenate(ShortName," ",Only_Symbols);
   else if(Only_Current)
      ShortName=StringConcatenate(ShortName," ",Symbol());
   if(Only_Magics)
      ShortName=StringConcatenate(ShortName," #",Magic_From,":",Magic_To);
   if(Only_Comment!="")
      ShortName=StringConcatenate(ShortName," [",Only_Comment,"]");
   if(Only_Buys && !Only_Sells)
      ShortName=StringConcatenate(ShortName," Buys");
   if(Only_Sells && !Only_Buys)
      ShortName=StringConcatenate(ShortName," Sells");
   if(Only_Trading)
      ShortName=StringConcatenate(ShortName," Trading");
 
   SetIndexBuffer(5,Equity);
   SetIndexBuffer(6,Balance);
   SetIndexBuffer(7,Margin);
   SetIndexBuffer(8,Free);
   SetIndexBuffer(9,Zero);
   SetIndexLabel(5,"Equity");
   SetIndexLabel(6,"Balance");
   SetIndexLabel(7,"Margin");
   SetIndexLabel(8,"Free");
   SetIndexLabel(9,"Zero");
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexStyle(7,DRAW_HISTOGRAM);
   SetIndexStyle(8,DRAW_LINE);
   SetIndexStyle(9,DRAW_LINE);

   ShortName                 =StringConcatenate(ShortName," Equity");
   if(Show_Balance) ShortName=StringConcatenate(ShortName," Balance");
   if(Show_Margin)  ShortName=StringConcatenate(ShortName," Margin");
   if(Show_Free)    ShortName=StringConcatenate(ShortName," Free");

   Unique=(string)ChartID()+(string)ChartWindowFind();
   DrawBeginBar=iBarShift(NULL,0,Draw_Begin);
   DrawEndBar=iBarShift(NULL,0,Draw_End);

   if(Equity_Max_Alert!=0) alert_upper_active=true; else alert_upper_active=false;
   if(Equity_Min_Alert!=0) alert_lower_active=true; else alert_lower_active=false;

   IndicatorDigits(2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   DeleteAll();
   deinitforexclock();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnnnStart()
  {
  startforexclock();
   if(!CheckConditions()) return(0);
   bool restart=false;
   if(CheckNewBar()) restart=true;
   if(CheckNewOrder()) restart=true;
   if(CheckNewAccount()) restart=true;
   if(restart) CalculateHistoryBars();
   CalculateLastBar();
   if(Show_Info) ShowStatistics();
   AlertMonitoring();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckConditions()
  {
   if(!OrderSelect(0,SELECT_BY_POS,MODE_HISTORY)) { return(false); }
   if(Period()>PERIOD_D1) { Alert("Period must be D1 or lower."); return(false); }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateHistoryBars()
  {

   PrepareData();

   if(Type[0]<6 && !Only_Trading)
     { Alert("Trading history is not fully loaded."); return; }

   int handle=PrepareFile();

   ResultBalance=0;
   ResultProfit=0;
   PeakProfit=0;
   PeakEquity=0;
   MaxDrawdown=0;
   RelDrawdown=0;
   start_time=0;
   finish_time=0;

   int bar_seconds=PeriodSeconds(PERIOD_CURRENT);
   int start_from=0;

   for(int i=OpenBar[0]; i>=DrawEndBar; i--)
     {
      ProfitLoss=0;
      SumMargin=0;

      for(int j=start_from; j<Total; j++)
        {
         if(OpenBar[j]<i) break;
         if(CloseBar[start_from]>i) start_from++;

         if(CloseBar[j]==i && ClosePrice[j]!=0)
           {
            double result=Swap[j]+Commission[j]+Profit[j];
            ResultProfit+=result;
            ResultBalance+=result;
            if(CloseTime[j]>finish_time) finish_time=CloseTime[j];
           }

         else if(OpenBar[j]>=i && CloseBar[j]<=i)
           {

            if(Type[j]>5)
              {
               ResultBalance+=Profit[j];
               if(i>DrawBeginBar) continue;
               if(!Show_Verticals) continue;
               string text=StringConcatenate(Instrument[j],": ",DoubleToStr(Profit[j],2)," ",AccountCurrency());
               CreateLine("Balance "+TimeToStr(OpenTime_Ticket[j][0]),OBJ_VLINE,1,OrangeRed,STYLE_DOT,false,text,Time[i],0);
               continue;
              }

            if(i>DrawBeginBar) continue;
            if(!CheckSymbol(j)) continue;

            if(start_time==0) start_time=MathMax(OpenTime_Ticket[j][0],Time[i]);

            int bar=iBarShift(Instrument[j],0,Time[i]);
            int day_bar=TimeDayOfWeek(iTime(Instrument[j],0,bar));
            int day_next_bar=TimeDayOfWeek(iTime(Instrument[j],0,bar+1));
            if(day_bar!=day_next_bar && OpenBar[j]!=bar)
              {
               int mode=(int)MarketInfo(Instrument[j],MODE_PROFITCALCMODE);
               if(mode==0)
                 {
                  if(TimeDayOfWeek(iTime(Instrument[j],0,bar))==4) CumSwap[j]+=3*DaySwap[j];
                  else CumSwap[j]+=DaySwap[j];
                 }
               else
                 {
                  if(TimeDayOfWeek(iTime(Instrument[j],0,bar))==1) CumSwap[j]+=3*DaySwap[j];
                  else CumSwap[j]+=DaySwap[j];
                 }
              }

            if(Type[j]==OP_BUY)
              {
               LotValue=ContractValue(Instrument[j],Time[i],Period());
               ProfitLoss+=Commission[j]+CumSwap[j]+(iClose(Instrument[j],0,bar)-OpenPrice[j])*Lots[j]*LotValue;
               SumMargin+=Lots[j]*MarketInfo(Instrument[j],MODE_MARGINREQUIRED);
              }
            if(Type[j]==OP_SELL)
              {
               LotValue=ContractValue(Instrument[j],Time[i],Period());
               Spread=MarketInfo(Instrument[j],MODE_POINT)*MarketInfo(Instrument[j],MODE_SPREAD);
               ProfitLoss+=Commission[j]+CumSwap[j]+(OpenPrice[j]-iClose(Instrument[j],0,bar)-Spread)*Lots[j]*LotValue;
               SumMargin+=Lots[j]*MarketInfo(Instrument[j],MODE_MARGINREQUIRED);
              }

           }
        }

      if(i>DrawBeginBar) continue;
         ArrayResize(Zero,i,0);
      if(Only_Trading)  {Equity[i]=NormalizeDouble(ResultProfit+ProfitLoss,2);}
      else              {Equity[i]=NormalizeDouble(ResultBalance+ProfitLoss,2);}
      if(Show_Balance)  {Balance[i]=NormalizeDouble(Only_Trading?ResultProfit:ResultBalance,2);}
      if(Show_Margin)   {Margin[i]=NormalizeDouble(SumMargin,2);}
      if(Show_Free)     {Free[i]=NormalizeDouble(ResultBalance+ProfitLoss-SumMargin,2);}
      if(Show_Zero)     {Zero[i]=0;}
      if(Show_Info)     {Drawdown();}

      if(ProfitLoss!=0) finish_time=Time[i]+PeriodSeconds(PERIOD_CURRENT);

      WriteData(handle,i);

     }

   Profitability();

   if(File_Write && handle>0) FileClose(handle);

   ArrayResize(OpenTime_Ticket,OpenTotal);
   if(OpenTotal>0)
      for(int i=0; i<OpenTotal; i++)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            OpenTime_Ticket[i][1]=OrderTicket();

   if(Equity_Min_Alert!=0)
      CreateLine("Alert-Min",OBJ_HLINE,1,Silver,STYLE_DOT,false,"Min equity alert",0,Equity_Min_Alert);
   if(Equity_Max_Alert!=0)
      CreateLine("Alert-Max",OBJ_HLINE,1,Silver,STYLE_DOT,false,"Max equity alert",0,Equity_Max_Alert);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateLastBar()
  {

   if(DrawEndBar>0) return;

   if(OpenTotal>0)
      for(int i=0; i<OpenTotal; i++)
        {
         if(!OrderSelect((int)OpenTime_Ticket[i][1],SELECT_BY_TICKET)) continue;
         if(OrderCloseTime()==0) continue;
         if(!FilterOrder()) continue;
         double result=OrderProfit()+OrderSwap()+OrderCommission();
         ResultBalance+=result;
         ResultProfit+=result;
        }

   if(!using_filters)
     {
      ProfitLoss=AccountProfit();
      ResultBalance=AccountBalance();
      if(Only_Trading)  {Equity[0]=ResultProfit+ProfitLoss;}
      else              {Equity[0]=AccountEquity();}
      if(Show_Balance)  {Balance[0]=Only_Trading?ResultProfit:ResultBalance;}
      if(Show_Margin)   {Margin[0]=AccountMargin();}
      if(Show_Free)     {Free[0]=AccountFreeMargin();}
      if(Show_Zero)     {Zero[0]=0;}
      if(Show_Info)     {Drawdown();}
     }

   else
     {
      ProfitLoss=0;
      SumMargin=0;
      OpenTotal=OrdersTotal();

      if(OpenTotal>0)
         for(int i=0; i<OpenTotal; i++)
           {
            if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
            if(!FilterOrder()) continue;
            SumMargin+=OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED);
            ProfitLoss+=OrderProfit()+OrderSwap()+OrderCommission();
           }

      if(Only_Trading)  {Equity[0]=NormalizeDouble(ResultProfit+ProfitLoss,2);}
      else              {Equity[0]=NormalizeDouble(ResultBalance+ProfitLoss,2);}
      if(Show_Balance)  {Balance[0]=NormalizeDouble(Only_Trading?ResultProfit:ResultBalance,2);}
      if(Show_Margin)   {Margin[0]=NormalizeDouble(SumMargin,2);}
      if(Show_Free)     {Free[0]=NormalizeDouble(ResultBalance+ProfitLoss-SumMargin,2);}
      if(Show_Zero)     {Zero[0]=0;}
      if(Show_Info)     {Drawdown();}

      ArrayResize(OpenTime_Ticket,OpenTotal);
      if(OpenTotal>0)
         for(int i=0; i<OpenTotal;i++)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
               OpenTime_Ticket[i][1]=OrderTicket();
     }

   CreateLine("Equity Level",OBJ_HLINE,1,SteelBlue,STYLE_DOT,false,"",0,Equity[0]);
   CreateLine("Balance Level",OBJ_HLINE,1,Crimson,STYLE_DOT,false,"",0,Balance[0]);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowStatistics()
  {

   double                     periods=double(finish_time-start_time);
   if(Report_Period==day)     periods=periods/24/60/60;
   if(Report_Period==month)   periods=periods/30/24/60/60;
   if(Report_Period==year)    periods=periods/365/24/60/60;
   if(Report_Period==history) periods=1;
   if(      periods==0)       periods=1;

   NetProfit=(SumProfit+SumLoss)/periods;
   Profitability=100*(GrowthRatio-1)/periods;
   string text=StringConcatenate(": ",DoubleToStr(NetProfit,2)," ",AccountCurrency()," (",DoubleToStr(Profitability,2),"%)");

   if(Report_Period==day)     CreateLabel("Net Profit / Day",text,20);
   if(Report_Period==month)   CreateLabel("Net Profit / Month",text,20);
   if(Report_Period==year)    CreateLabel("Net Profit / Year",text,20);
   if(Report_Period==history) CreateLabel("Total Net Profit",text,20);

   text=StringConcatenate(": ",DoubleToStr(MaxDrawdown,2)," "+AccountCurrency()," (",DoubleToStr(RelDrawdown*100,2),"%)");
   CreateLabel("Max Drawdown",text,40);

   if(MaxDrawdown!=0) RecoveryFactor=NetProfit/MaxDrawdown;
   text=StringConcatenate(": ",DoubleToStr(RecoveryFactor,2));
   CreateLabel("Recovery Factor",text,60);

   if(SumLoss!=0) ProfitFactor=-SumProfit/SumLoss;
   text=StringConcatenate(": ",DoubleToStr(ProfitFactor,2));
   CreateLabel("Profit Factor",text,80);

   if(StringLen(missing_symbols)>0)
      CreateLabel("Missing symbols:",missing_symbols,100);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AlertMonitoring()
  {
   if(alert_upper_active)
      if(Equity[0]!=EMPTY_VALUE)
         if(Equity[0]>=Equity_Max_Alert)
           {
            string message=StringConcatenate("Account #",AccountNumber()," equity alert: ",Equity[0]," ",AccountCurrency());
            Alert(message);
            if(Push_Alerts) SendNotification(message);
            alert_upper_active=false;
           }
   if(alert_lower_active)
      if(Equity[0]!=EMPTY_VALUE)
         if(Equity[0]<=Equity_Min_Alert)
           {
            string message=StringConcatenate("Account #",AccountNumber()," equity alert: ",Equity[0]," ",AccountCurrency());
            Alert(message);
            if(Push_Alerts) SendNotification(message);
            alert_lower_active=false;
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Profitability()
  {
   int Count=OrdersHistoryTotal();
   datetime CloseTime_Ticket[][2];
   ArrayResize(CloseTime_Ticket,Count);

   for(int i=0; i<Count; i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(FilterOrder())
           {
            CloseTime_Ticket[i][0]=OrderOpenTime();
            CloseTime_Ticket[i][1]=OrderTicket();
           }
         else
           {
            CloseTime_Ticket[i][0]=EMPTY_VALUE;
            Count--;
           }
        }

   ArraySort(CloseTime_Ticket);
   ArrayResize(CloseTime_Ticket,Count);

   SumProfit=0;
   SumLoss=0;
   GrowthRatio=1;
   double IntervalProfit=0;
   double BalanceValue=0;

   for(int i=0; i<Count; i++)
      if(OrderSelect((int)CloseTime_Ticket[i][1],SELECT_BY_TICKET))
         if(FilterOrder())
           {
            if(OrderType()>5)
              {
               if(BalanceValue!=0) GrowthRatio*=(1+IntervalProfit/BalanceValue);
               BalanceValue+=IntervalProfit;
               IntervalProfit=0;
               BalanceValue+=OrderProfit();
              }
            if(OrderType()<=1)
               if(OrderCloseTime()>=Draw_Begin && OrderCloseTime()<=Draw_End)
                 {
                  double result=OrderProfit()+OrderSwap()+OrderCommission();
                  IntervalProfit+=result;
                  if(result>0) SumProfit+=result; else SumLoss+=result;
                 }
           }

   if(IntervalProfit!=0)
      if(BalanceValue!=0)
         GrowthRatio*=(1+IntervalProfit/BalanceValue);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrepareData()
  {

   HistoryTotal=OrdersHistoryTotal();
   OpenTotal=OrdersTotal();
   Total=HistoryTotal+OpenTotal;
   ArrayResize(OpenTime_Ticket,Total);

   for(int i=0; i<HistoryTotal; i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(FilterOrder())
           {
            OpenTime_Ticket[i][0]=OrderOpenTime();
            OpenTime_Ticket[i][1]=OrderTicket();
           }
         else
           {
            OpenTime_Ticket[i][0]=EMPTY_VALUE;
            Total--;
           }
        }

   for(int i=0; i<OpenTotal; i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(FilterOrder())
           {
            OpenTime_Ticket[HistoryTotal+i][0]=OrderOpenTime();
            OpenTime_Ticket[HistoryTotal+i][1]=OrderTicket();
           }
         else
           {
            OpenTime_Ticket[HistoryTotal+i][0]=EMPTY_VALUE;
            Total--;
           }
        }

   ArraySort(OpenTime_Ticket);
   ArrayResize(OpenTime_Ticket,Total);
   ArrayResize(CloseTime,Total);
   ArrayResize(OpenBar,Total);
   ArrayResize(CloseBar,Total);
   ArrayResize(Type,Total);
   ArrayResize(Lots,Total);
   ArrayResize(Instrument,Total);
   ArrayResize(OpenPrice,Total);
   ArrayResize(ClosePrice,Total);
   ArrayResize(Commission,Total);
   ArrayResize(Swap,Total);
   ArrayResize(CumSwap,Total);
   ArrayResize(DaySwap,Total);
   ArrayResize(Profit,Total);

   for(int i=0; i<Total; i++)
      if(OrderSelect((int)OpenTime_Ticket[i][1],SELECT_BY_TICKET))
         ReadOrder(i);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadOrder(int n)
  {

   OpenBar[n]=iBarShift(NULL,0,OrderOpenTime());
   Type[n]=OrderType();
   if(OrderType()>5) Instrument[n]=OrderComment(); else Instrument[n]=OrderSymbol();
   Lots[n]=OrderLots();
   OpenPrice[n]=OrderOpenPrice();

   if(OrderCloseTime()!=0)
     {
      CloseTime[n]=OrderCloseTime();
      CloseBar[n]=iBarShift(NULL,0,OrderCloseTime());
      ClosePrice[n]=OrderClosePrice();
     }
   else
     {
      CloseTime[n]=0;
      CloseBar[n]=0;
      ClosePrice[n]=0;
     }

   Commission[n]=OrderCommission();
   Swap[n]=OrderSwap();
   Profit[n]=OrderProfit();

   CumSwap[n]=0;
   int swapdays=0;

   for(int bar=OpenBar[n]-1; bar>=CloseBar[n]; bar--)
     {
      if(TimeDayOfWeek(iTime(NULL,0,bar))!=TimeDayOfWeek(iTime(NULL,0,bar+1)))
        {
         int mode=(int)MarketInfo(Instrument[n],MODE_PROFITCALCMODE);
         if(mode==0)
           {
            if(TimeDayOfWeek(iTime(NULL,0,bar))==4) swapdays+=3;
            else swapdays++;
           }
         else
           {
            if(TimeDayOfWeek(iTime(NULL,0,bar))==1) swapdays+=3;
            else swapdays++;
           }
        }
     }

   if(swapdays>0) DaySwap[n]=Swap[n]/swapdays; else DaySwap[n]=0.0;

   if(Lots[n]==0)
     {
      string ticket=StringSubstr(OrderComment(),StringFind(OrderComment(),"#")+1);
      if(OrderSelect(StrToInteger(ticket),SELECT_BY_TICKET,MODE_HISTORY)) Lots[n]=OrderLots();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FilterOrder()
  {
   if(OrderType()>5) return(true);
   if(OrderType()>1) return(false);
   if(Only_Magics) if(OrderMagicNumber()<Magic_From) return(false);
   if(Only_Magics) if(OrderMagicNumber()>Magic_To)   return(false);
   if(Only_Comment!="") if(StringFind(OrderComment(),Only_Comment)==-1) return(false);
   if(Only_Symbols!="") if(StringFind(Only_Symbols,OrderSymbol())==-1)  return(false);
   if(Only_Symbols=="") if(Only_Current) if(OrderSymbol()!=Symbol())    return(false);
   if(Only_Buys  && OrderType()!=OP_BUY)  return(false);
   if(Only_Sells && OrderType()!=OP_SELL) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Drawdown()
  {
   if(ResultProfit+ProfitLoss>=PeakProfit)
     {
      PeakProfit=ResultProfit+ProfitLoss;
      PeakEquity=ResultBalance+ProfitLoss;
     }
   double current_drawdown=PeakProfit-ResultProfit-ProfitLoss;
   if(current_drawdown>MaxDrawdown)
     {
      MaxDrawdown=current_drawdown;
      if(PeakEquity==0) PeakEquity=DBL_MAX;
      RelDrawdown=current_drawdown/PeakEquity;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ContractValue(string symbol,datetime time,int period)
  {
   double value=MarketInfo(symbol,MODE_LOTSIZE);
   string quote=SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT);

   if(quote!="USD")
     {
      string direct=FX_prefix+quote+"USD"+FX_postfix;
      if(MarketInfo(direct,MODE_POINT)!=0)
        {
         int shift=iBarShift(direct,period,time);
         double price=iClose(direct,period,shift);
         if(price>0) value*=price;
        }
      else
        {
         string indirect=FX_prefix+"USD"+quote+FX_postfix;
         int shift=iBarShift(indirect,period,time);
         double price=iClose(indirect,period,shift);
         if(price>0) value/=price;
        }
     }

   if(AccountCurrency()!="USD")
     {
      string direct=FX_prefix+AccountCurrency()+"USD"+FX_postfix;
      if(MarketInfo(direct,MODE_POINT)!=0)
        {
         int shift=iBarShift(direct,period,time);
         double price=iClose(direct,period,shift);
         if(price>0) value/=price;
        }
      else
        {
         string indirect=FX_prefix+"USD"+AccountCurrency()+FX_postfix;
         int shift=iBarShift(indirect,period,time);
         double price=iClose(indirect,period,shift);
         if(price>0) value*=price;
        }
     }

   return(value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string name,string str,int y)
  {
   string objectname=StringConcatenate(name," ",Unique);
   if(ObjectFind(objectname)==-1)
     {
      ObjectCreate(objectname,OBJ_LABEL,Window,0,0);
      ObjectSet(objectname,OBJPROP_XDISTANCE,10);
      ObjectSet(objectname,OBJPROP_YDISTANCE,y);
      ObjectSet(objectname,OBJPROP_COLOR,indicator_color1);
      ObjectSet(objectname,OBJPROP_CORNER,Text_Corner);
      ObjectSet(objectname,OBJPROP_COLOR,Text_Color);
     }
   ObjectSetText(objectname,name+str,Text_Size,Text_Font);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLine(string name,int type,int width,color clr,int style,bool ray,string str,
                datetime time1,double price1,datetime time2=0,double price2=0)
  {
   string objectname=StringConcatenate(name," ",Unique);
   if(ObjectFind(objectname)==-1)
     {
      ObjectCreate(objectname,type,Window,time1,price1,time2,price2);
      ObjectSet(objectname,OBJPROP_WIDTH,width);
      ObjectSet(objectname,OBJPROP_RAY,ray);
     }
   ObjectSetText(objectname,str);
   ObjectSet(objectname,OBJPROP_COLOR,clr);
   ObjectSet(objectname,OBJPROP_TIME1,time1);
   ObjectSet(objectname,OBJPROP_PRICE1,price1);
   ObjectSet(objectname,OBJPROP_TIME2,time2);
   ObjectSet(objectname,OBJPROP_PRICE2,price2);
   ObjectSet(objectname,OBJPROP_STYLE,style);
   ObjectSet(objectname,OBJPROP_SELECTABLE,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAll()
  {
   int objects=ObjectsTotal()-1;
   for(int i=objects;i>=0;i--)
     {
      string name=ObjectName(i);
      if(StringFind(name,Unique)!=-1) ObjectDelete(name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PrepareFile()
  {
   if(!File_Write) return(-1);
   string filename=StringConcatenate(AccountNumber(),"_",Period(),".csv");
   int handle=FileOpen(filename,FILE_CSV|FILE_WRITE);
   if(handle<0) { Alert("Error #",GetLastError()," while opening data file."); return(handle); }
   uint bytes=FileWrite(handle,"Date","Time","Equity","Balance");
   if(bytes<=0) Print("Error #",GetLastError()," while writing data file.");
   return(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteData(int handle,int i)
  {
   if(!File_Write) return;
   if(handle<=0) return;
   string date=TimeToStr(Time[i],TIME_DATE);
   string time=TimeToStr(Time[i],TIME_MINUTES);
   uint bytes=FileWrite(handle,date,time,ResultBalance+ProfitLoss,ResultBalance);
   if(bytes<=0) Print("Error #",GetLastError()," while writing data file.");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSymbol(int j)
  {
   if(MarketInfo(Instrument[j],MODE_POINT)!=0) return(true);
   if(StringFind(missing_symbols,Instrument[j])==-1)
     {
      missing_symbols=StringConcatenate(missing_symbols," ",Instrument[j]);
      Print("Missing symbols in Market Watch: "+Instrument[j]);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckNewAccount()
  {
   static int number=-1;
   if(number!=AccountNumber())
     {
      DeleteAll();
      IndicatorShortName(Unique);
      Window=WindowFind(Unique);
      IndicatorShortName(ShortName);
      ArrayInitialize(Balance,EMPTY_VALUE);
      ArrayInitialize(Equity,EMPTY_VALUE);
      ArrayInitialize(Margin,EMPTY_VALUE);
      ArrayInitialize(Free,EMPTY_VALUE);
      ArrayInitialize(Zero,EMPTY_VALUE);
      number=AccountNumber();
      missing_symbols="";
      return(true);
     }
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckNewBar()
  {
   static datetime saved_time;
   if(Time[0]==saved_time) return(false);
   saved_time=Time[0];
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckNewOrder()
  {
   static int orders;
   if(OrdersTotal()==orders) return(false);
   orders=OrdersTotal();
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spreads[])
  {
  OnnnStart();
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   
    
  
  
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
     }
   else
      limit++;
   double ask=Ask,bid=Bid;
   double sellsignalprice[2];
   double buysignalprice[2];
   //--- main loop
   
   double priceRecord[2]={};
   
    priceRecord[0]=0;
     priceRecord[1]=0;
       
       
   for(int i = limit-1; i >= 0; i--)
     {   ArrayResize(Buffer1,i+1,i);
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
        buysignalprice[0]=bid;
        
      
      //Indicator Buffer 1
      if(OrderClosePrice()>ask &&iWPR(NULL, PERIOD_CURRENT, 20, i) > iWPR(NULL, PERIOD_CURRENT, 200, i)
      && iWPR(NULL, PERIOD_CURRENT, 20, i+1) < iWPR(NULL, PERIOD_CURRENT, 200, i+1) //William's Percent Range crosses above William's Percent Range
      && iADX(NULL, PERIOD_CURRENT, 20, PRICE_MEDIAN, MODE_MAIN, i) > iADX(NULL, PERIOD_CURRENT, 200, PRICE_LOW, MODE_MINUSDI, i) //Average Directional Movement Index > Average Directional Movement Index
      )
        {  
        TrendlinePriceUpper(i);
        DrawFiboSimpleBuy("myfibobuy",0,0,iTime(Symbol(),PERIOD_CURRENT,1),Ask);
         Buffer1[i] = Support(12 * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Support
         if(i == 0 && Time[0] != time_alert) {myAlert("TrendFollower", "BUY"+" -->Price:"+(string)buysignalprice[0]); time_alert = Time[0]; } //Instant alert, only once per bar
          
        }
      else
        { 
       
         Buffer1[i] = EMPTY_VALUE;
  
        }
      //Indicator Buffer 2
      if( OrderClosePrice()<ask && iWPR(NULL, PERIOD_CURRENT, 20, i) < iWPR(NULL, PERIOD_CURRENT, 200, i)
      && iWPR(NULL, PERIOD_CURRENT, 20, i+1) > iWPR(NULL, PERIOD_CURRENT, 200, i+1) //William's Percent Range crosses below William's Percent Range
      && iADX(NULL, PERIOD_CURRENT, 20, PRICE_MEDIAN, MODE_MAIN, i) < iADX(NULL, PERIOD_CURRENT, 200, PRICE_LOW, MODE_MINUSDI, i) //Average Directional Movement Index < Average Directional Movement Index
      )
        {
         Buffer2[i] = Resistance(12 * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Resistance 
         if(i == 0 && Time[0] != time_alert) { myAlert("TrendFollower", "SELL "+" -->Price:"+(string)sellsignalprice[0]); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE; 
         TrendlinePriceLower(i);
        DrawFiboSimpleSell("myfiboSell",0,0,iTime(Symbol(),PERIOD_CURRENT,1),Bid);
          myAlert("TrendFollower", "EXIT_SELL  -->REASON\n-->REVERSAL SIGNAL"); 
     
        }
        
        //EXIT BUY SELL STRATEGIES
        
        
        
              //Indicator Buffer 3
      if(OrderClosePrice()<ask &&iWPR(NULL, PERIOD_CURRENT, 20, i) < iWPR(NULL, PERIOD_CURRENT, 200, i)
      && iWPR(NULL, PERIOD_CURRENT, 20, i+1) < iWPR(NULL, PERIOD_CURRENT, 200, i+1) //William's Percent Range crosses above William's Percent Range
      && iADX(NULL, PERIOD_CURRENT, 20, PRICE_MEDIAN, MODE_MAIN, i) < iADX(NULL, PERIOD_CURRENT, 200, PRICE_LOW, MODE_MINUSDI, i) //Average Directional Movement Index > Average Directional Movement Index
      )
        {  
     
         Buffer3[i] = Support(12 * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Support
         if(i == 0 && Time[0] != time_alert) {myAlert("TrendFollower", "EXIT BUY"+" -->Price:"+(string)buysignalprice[0]); time_alert = Time[0]; } //Instant alert, only once per bar
          
        }
      else
        {    Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if( OrderClosePrice()>ask && iWPR(NULL, PERIOD_CURRENT, 20, i) > iWPR(NULL, PERIOD_CURRENT, 200, i)
      && iWPR(NULL, PERIOD_CURRENT, 20, i+1) > iWPR(NULL, PERIOD_CURRENT, 200, i+1) //William's Percent Range crosses below William's Percent Range
      && iADX(NULL, PERIOD_CURRENT, 20, PRICE_MEDIAN, MODE_MAIN, i) >iADX(NULL, PERIOD_CURRENT, 200, PRICE_LOW, MODE_MINUSDI, i) //Average Directional Movement Index < Average Directional Movement Index
      )
        {
         Buffer4[i] = Resistance(12 * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Resistance
  
         if(i == 0 && Time[0] != time_alert) { myAlert("TrendFollower", "EXIT SELL "+" -->Price:"+(string)sellsignalprice[0]); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        { Buffer4[i] = EMPTY_VALUE;
        }
        
        
        
        
        
        
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
void DrawFiboSimpleBuy(string fiboName,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   int HighestCandle=iHighest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,1,0);
   int LowestCandle=iLowest(Symbol(),PERIOD_CURRENT,MODE_OPEN,30,0);

   ObjectDelete("TS261FiboBuy");
   ObjectDelete("TS261FiboSell");

   ObjectCreate(fiboName,OBJ_FIBO,0,Time[0],High[HighestCandle],Time[30],Low[LowestCandle]);
   ObjectSet(fiboName,OBJPROP_COLOR,Blue);
   ObjectSet(fiboName,OBJPROP_BACK,true);
   ObjectSet(fiboName,OBJPROP_WIDTH,3);
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,25);
   ObjectSet(fiboName,OBJPROP_LEVELCOLOR,Blue);
   ObjectSet(fiboName,OBJPROP_LEVELWIDTH,3);
//---

   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,-3.236);
   ObjectSetFiboDescription(fiboName,0,"SL 3= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,-1.618);
   ObjectSetFiboDescription(fiboName,1,"SL 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,-0.618);
   ObjectSetFiboDescription(fiboName,2,"SL 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.000);
   ObjectSetFiboDescription(fiboName,3,"Lowest Shadow= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,1.000);
   ObjectSetFiboDescription(fiboName,4,"Entry= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,1.618);
   ObjectSetFiboDescription(fiboName,5,"TP 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,2.618);
   ObjectSetFiboDescription(fiboName,6,"TP 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+7,4.236);
   ObjectSetFiboDescription(fiboName,7,"TP 3= %$");
//----
   
   ObjectSet(fiboName,OBJPROP_RAY,false);
   ObjectSet(fiboName,OBJPROP_RAY_RIGHT,false);

  }
  
  
  
  
  
  
  
  
  
  
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFiboSimpleSell(string fiboName,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   int HighestCandle=iHighest(Symbol(),Period(),MODE_OPEN,30,0);
   int LowestCandle=iLowest(Symbol(),Period(),MODE_CLOSE,1,0);

   ObjectDelete("TS261FiboBuy");
   ObjectDelete("TS261FiboSell");


   ObjectCreate(fiboName,OBJ_FIBO,0,Time[0],Low[LowestCandle],Time[30],High[HighestCandle]);
   ObjectSet(fiboName,OBJPROP_COLOR,Red);
   ObjectSet(fiboName,OBJPROP_BACK,true);
   ObjectSet(fiboName,OBJPROP_WIDTH,3);
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,25);
   ObjectSet(fiboName,OBJPROP_LEVELCOLOR,Red);
   ObjectSet(fiboName,OBJPROP_LEVELWIDTH,3);
//---

   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,-3.236);
   ObjectSetFiboDescription(fiboName,0,"SL 3= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,-1.618);
   ObjectSetFiboDescription(fiboName,1,"SL 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,-0.618);
   ObjectSetFiboDescription(fiboName,2,"SL 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.000);
   ObjectSetFiboDescription(fiboName,3,"Highest Shadow= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,1.000);
   ObjectSetFiboDescription(fiboName,4,"Entry= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,1.618);
   ObjectSetFiboDescription(fiboName,5,"TP 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,2.618);
   ObjectSetFiboDescription(fiboName,6,"TP 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+7,4.236);
   ObjectSetFiboDescription(fiboName,7,"TP 3= %$");
//----
   ObjectSet(fiboName,OBJPROP_RAY,false);
   ObjectSet(fiboName,OBJPROP_RAY_RIGHT,false);



  }



double TrendlinePriceUpper(int shift) //returns current price on the highest horizontal line or trendline found in the chart
  {
   int obj_total = ObjectsTotal();
   double maxprice = -1;
   for(int i = obj_total - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      double price;
      if(ObjectType(name) == OBJ_HLINE && StringFind(name, "#", 0) < 0
      && (price = ObjectGet(name, OBJPROP_PRICE1)) > maxprice
      && price > 0)
         maxprice = price;
      else if(ObjectType(name) == OBJ_TREND && StringFind(name, "#", 0) < 0
      && (price = ObjectGetValueByShift(name, shift)) > maxprice
      && price > 0)
         maxprice = price;
     }
   return(maxprice); //not found => -1
  }

double TrendlinePriceLower(int shift) //returns current price on the lowest horizontal line or trendline found in the chart
  {
   int obj_total = ObjectsTotal();
   double minprice = MathPow(10, 308);
   for(int i = obj_total - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      double price;
      if(ObjectType(name) == OBJ_HLINE && StringFind(name, "#", 0) < 0
      && (price = ObjectGet(name, OBJPROP_PRICE1)) < minprice
      && price > 0)
         minprice = price;
      else if(ObjectType(name) == OBJ_TREND && StringFind(name, "#", 0) < 0
      && (price = ObjectGetValueByShift(name, shift)) < minprice
      && price > 0)
         minprice = price;
     }
   if (minprice > MathPow(10, 307))
      minprice = -1; //not found => -1
   return(minprice);
  }
--------------------------------------------------------
--  DDL for Package Body LNS_FIN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FIN_UTILS" AS
/* $Header: LNS_FIN_UTILS_B.pls 120.9.12010000.10 2010/02/24 01:42:03 mbolli ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_DEBUG_COUNT                       NUMBER := 0;
 G_DEBUG                             BOOLEAN := FALSE;
 G_FILE_NAME   CONSTANT VARCHAR2(30) := 'LNS_FIN_UTILS_B.pls';

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_FIN_UTILS';
 G_DAYS_COUNT                        NUMBER;
 G_DAYS_IN_YEAR                      NUMBER;

 --------------------------------------------
 -- internal package routines
 --------------------------------------------

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin
    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;

-- internal usage only
function formatTerm(p_timeString IN varchar2) return varchar2
is

  l_temp varchar2(30);
begin

    -- this logic is to handle "MONTHLY" => "MONTHS" ETC...
    if substr(p_timeString, length(p_timeString) - 1, 2) = 'LY' then
        l_temp := substr(p_timeString, 1, length(p_timeString) - 2) || 'S';
    else
        l_temp := p_timeString;
    end if;

    return l_temp;

end;

/*=========================================================================
|| PUBLIC function julian_date
||
|| DESCRIPTION
|| Overview:  function returns a number representing the julian date |
||
|| PARAMETERS
|| Parameter: p_date => date
||
|| Return value: number
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 8:16PM     raverma           Created
||
 *=======================================================================*/
function julian_date(p_date in date) return number
is
    --l_char         VARCHAR(10);
    l_num          NUMBER(20);

begin

    SELECT to_number(TO_CHAR(p_date, 'J'))
      INTO l_num
      FROM DUAL;

    RETURN(l_num);

end julian_date;


/*=========================================================================
|| PUBLIC FUNCTION getNextDate
||
|| DESCRIPTION
||      this is used to add/subtract months to a particular date
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||            p_date => beginning date
||            p_interval_type => MONTHLY, QUARTERLY, YEARLY
||                            (translates to the number of months to add/subtract)
||            p_direction => 1 = add, -1 = subtract
|| Return value:
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 03/22/2004 9:13PM       raverma           Created
|| 06/26/2006 5:27PM       karamach          Added additional values for p_interval_type and fixed the set_token call for the error message to fix bug5215501
 *=======================================================================*/
function getNextDate(p_date in date
                    ,p_interval_type in varchar2
                    ,p_direction in number) return Date
is
  l_next_date      date;
  l_multiplier     number;
  l_api_name       varchar2(25);
  l_add_months     boolean;

begin
     l_api_name   := 'getNextDate';
     l_add_months := true;

     if p_interval_type in ('WEEKLY','WEEKS') then
        l_multiplier := 7;
        l_add_months := false;

     elsif p_interval_type in ('BIWEEKLY','BIWEEKS') then
        l_multiplier := 14;
        l_add_months := false;

     elsif p_interval_type in ('SEMI-MONTHLY','SEMI-MONTHS') then
         l_multiplier := 15;
        l_add_months := false;

     elsif p_interval_type in ('MONTHLY','MONTHS') then
        l_multiplier := 1;

     elsif p_interval_type in ('BI-MONTHLY','BI-MONTHS') then
        l_multiplier := 2;

     elsif p_interval_type in ('QUARTERLY','QUARTERS') then
        l_multiplier := 3;

     elsif p_interval_type in ('SEMI-ANNUALLY','SEMI-ANNUALS') then
        l_multiplier := 6;

     elsif p_interval_type in ('YEARLY','YEARS') then
        l_multiplier := 12;

     else
         FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_INTERVAL');
         FND_MESSAGE.SET_TOKEN('INTERVAL',p_interval_type);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     end if;

     l_multiplier := l_multiplier * p_direction;

     if l_add_months then
       l_next_date := add_months(p_date, l_multiplier);
     else
       l_next_date  := p_date +   l_multiplier;
     end if;

     return trunc(l_next_date);

end getNextDate;

/*=========================================================================
|| PUBLIC PROCEDURE getDayCount
||
|| DESCRIPTION
||
|| Overview:  this function will return NUMERATOR FOR PERIODIC RATE
||             period of time so the interest in a give month at
||             12% interest per year will return a 1% monthly rate
||
||             supports the following day count methods
||             1. ACTUAL_ACTUAL
||             2. 30/360
||             3. 30E/360
||             4. 30E+/360
||             5. ACTUAL_360
||             6. ACTUAL_365
||             7. ACTUAL_365L
||
|| Parameter: p_start_date start date of period
||            p_end_date end date of period
||            p_days_count_method = counting method
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: number of days between 2 dates
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/09/2003 1:51PM     raverma           Created
||  2/26/2004            raverma           added more robust day / year counting methodolgy
|| 05/27/2008            scherkas          Fixed bug 6498179: changed days count for february
||
 *=======================================================================*/
function getDayCount(p_start_date       in date
                    ,p_end_date         in date
                    ,p_day_count_method in varchar2) return number
is

  l_api_name         varchar2(25);
  l_day_count        number;
  l_day1             number;
  l_day2             number;
  l_month1           number;
  l_month2           number;
  l_year1            number;
  l_year2            number;

  l_numerator        number;
  l_denominator      number;
  l_count_method     varchar2(30);

begin

    l_api_name         := 'getDayCount';

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_start_date: ' || p_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_end_date: ' || p_end_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_day_count_method: ' || p_day_count_method);

    if p_end_date < p_start_date then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PERIOD_INVALID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_end_date is null then
        FND_MESSAGE.Set_Name('LNS', 'LNS_NO_END_DATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_start_date is null then
        FND_MESSAGE.Set_Name('LNS', 'LNS_NO_START_DATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_day_count_method is null then
        FND_MESSAGE.Set_Name('LNS', 'LNS_NO_COUNT_METHOD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_day1   := to_number(to_char(p_start_date, 'DD'));
    l_month1 := to_number(to_char(p_start_date, 'MM'));
    l_year1  := to_number(to_char(p_start_date, 'YYYY'));

    l_day2   := to_number(to_char(p_end_date, 'DD'));
    l_month2 := to_number(to_char(p_end_date, 'MM'));
    l_year2  := to_number(to_char(p_end_date, 'YYYY'));

    if p_day_count_method = 'ACTUAL_ACTUAL' then
      l_day_Count := to_number(TO_CHAR(p_end_date, 'J')) - to_number(TO_CHAR(p_start_date, 'J'));
      --l_day_count := LNS_FIN_UTILS.Julian_date(p_end_date) - LNS_FIN_UTILS.Julian_date(p_start_date);

    elsif p_day_count_method = '30/360' then

      -- begin bug fix 6498179; scherkas; 10/12/2007;
      if l_month1 = 2 then
        if not LNS_FIN_UTILS.isLeapYear(l_year1) then
             if l_day1 = 28 then
                l_day1 := 30;
                if l_day2 = 28 or l_day2 = 29 then
                    l_day2 := 30;
                end if;
             end if;
        else
             if l_day1 = 29 then
                l_day1 := 30;
                if l_day2 = 29 then
                    l_day2 := 30;
                end if;
             end if;
        end if;
      else
        if l_day1 = 30 or l_day1 = 31 then
            l_day1 := 30;
        end if;
      end if;

      if l_month2 = 2 then
        if not LNS_FIN_UTILS.isLeapYear(l_year2) then
             if l_day2 = 28 then
                l_day2 := 30;
                if l_day1 = 28 or l_day1 = 29 then
                    l_day1 := 30;
                end if;
             end if;
        else
             if l_day2 = 29 then
                l_day2 := 30;
                if l_day1 = 29 then
                    l_day1 := 30;
                end if;
             end if;
        end if;
      else
        if l_day2 = 30 or l_day2 = 31 then
            l_day2 := 30;
        end if;
      end if;
      -- end bug fix 6498179; scherkas; 10/12/2007;

      l_day_count := ( ( l_day2 - l_day1 ) + 30 * ( l_month2 - l_month1 ) + 360 * ( l_year2 - l_year1 )  );

    elsif p_day_count_method = '30E/360' then
      if l_day1 = 31 then
        l_day1 := 30;
      end if;

      if l_day2 = 31 then
         l_day2 := 30;
      end if;

      l_day_count := ( ( l_day2 - l_day1 ) + 30 * ( l_month2 - l_month1 ) + 360 * ( l_year2 - l_year1 )  );

    elsif p_day_count_method = '30E+/360' then
      if l_day1 = 31 then
        l_day1 := 30;
      end if;

      if l_day2 = 31 then
         l_day2 := 1;
         l_month2 := l_month2 + 1;
      end if;

      l_day_count := ( ( l_day2 - l_day1 ) + 30 * ( l_month2 - l_month1 ) + 360 * ( l_year2 - l_year1 )  );

    elsif p_day_count_method = 'ACTUAL_360' then
      l_day_Count := to_number(TO_CHAR(p_end_date, 'J')) - to_number(TO_CHAR(p_start_date, 'J'));
      --l_day_count := LNS_FIN_UTILS.Julian_date(p_end_date) - LNS_FIN_UTILS.Julian_date(p_start_date);

    elsif p_day_count_method = 'ACTUAL_365' then
      l_day_Count := to_number(TO_CHAR(p_end_date, 'J')) - to_number(TO_CHAR(p_start_date, 'J'));
      --l_day_count := LNS_FIN_UTILS.Julian_date(p_end_date) - LNS_FIN_UTILS.Julian_date(p_start_date);

    elsif p_day_count_method = 'ACTUAL_365L' then
      l_day_Count := to_number(TO_CHAR(p_end_date, 'J')) - to_number(TO_CHAR(p_start_date, 'J'));
      --l_day_count := LNS_FIN_UTILS.Julian_date(p_end_date) - LNS_FIN_UTILS.Julian_date(p_start_date);

    end if;

   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': day count is: ' || l_day_count || ' by method ' || p_day_count_method);
   return l_day_count;

end getDayCount;

-- returns DENOMINATOR FOR PERIODIC RATE
function daysInYear(p_year in number
                   ,p_year_count_method in varchar2) return number

is
  l_days_in_year  number;
  l_api_name      varchar2(25);

begin

   l_api_name    := 'daysInYear';

    if p_year is not null then
       -- default the year count to 360
       if p_year_count_method is null then
         l_days_in_year := 360;

       -- if the year is actual number of days then we need to determine if
       -- it's a leap year or not
       elsif p_year_count_method = 'ACTUAL_ACTUAL' or p_year_count_method = 'ACTUAL_365L' then
            if LNS_FIN_UTILS.isLeapYear(p_year) then
               l_days_in_year := 366;
            else
               l_days_in_year := 365;
            end if;

        elsif p_year_count_method = 'ACTUAL_360' then
          l_days_in_year := 360;

        elsif p_year_count_method = 'ACTUAL_365' then
          l_days_in_year := 365;

       elsif p_year_count_method = '30/360' then
          l_days_in_year := 360;

       elsif p_year_count_method = '30E/360' then
          l_days_in_year := 360;

       elsif p_year_count_method = '30E+/360' then
          l_days_in_year := 360;

       --elsif p_year_count_method = '30/365' then
       --   l_days_in_year := 365;

       end if;

    else
        FND_MESSAGE.Set_Name('LNS', 'LNS_NO_YEAR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': days in year is: ' || l_days_in_year);
   return l_days_in_year;

end daysInYear;

/*=========================================================================
|| PUBLIC PROCEDURE isLeapYear
||
|| DESCRIPTION
|| Overview:  given any year return whether it is a leap year or not
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_year => year
||
|| Return value: boolean true = is a leap year; false = is not leap year
||
|| KNOWN ISSUES
||   This is based on Gregorian Calendar.  I will get ahead one day every 3,289 years
||   One year = 365.2425 days
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 8:40PM     raverma           Created
||
 *=======================================================================*/
function isLeapYear(p_year in number) return boolean
is
    l_return boolean;
begin

    if p_year is not null then
        if ((p_year mod 400) = 0) then
             l_return := true;
        elsif ((p_year mod 100) = 0) then
             l_return := false;
        elsif ((p_year mod 4) = 0) then
             l_return  := true;
        else l_return := false;
        end if;
    else
        FND_MESSAGE.Set_Name('LNS', 'LNS_NO_YEAR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;
    return l_return;

end isLeapYear;

/*=========================================================================
|| PUBLIC PROCEDURE intervalsInPeriod
||
|| DESCRIPTION
|| Overview:  return the number of intervals in a given period type
||            like how many WEEKS are in 4 YEARS
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_period_number number
||            p_period_type1
||                            WEEKS       1
||                            MONTHS      2
||                            QUARTERS    3
||                            YEARS       4
||            period_type2
||                            WEEKS       1
||                            MONTHS      2
||                            QUARTERS    3
||                            YEARS       4
||
||              period_type1 < period_type2
||
|| Return value: number of intervals
||                            SECONDS               NO
||                            MINUTES               NO
||                            HOURS                 NO
||                            DAYS                  NO
||                            WEEKS                 YES
||                            BI-WEEKS              NO
||                            SEMI-MONTHS           NO
||                            MONTHS                YES
||                            BI-MONTHS             NO
||                            QUARTERS              YES
||                            SEMI-ANNUALS          YES
||                            YEARS                 YES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/09/2003 4:19PM     raverma           Created
|| 03/13/2004            raverma           Karamach uses for UI rate schedule creation
|| 29-Jan-2008           mbolli		   Bug#6634845 - Added the 'DAYS' to all period_types
 *=======================================================================*/
function intervalsInPeriod(p_period_number in number
                          ,p_period_type1  in varchar2
                          ,p_period_type2  in varchar2) return number
is
    l_ratio         number;
    l_period_type1  varchar2(30);
    l_period_type2  varchar2(30);
    l_num_intervals number;
    l_api_name      varchar2(30);

begin
    l_num_intervals := 0;
    l_api_name      := 'intervalsInPeriod';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    l_period_type1 := formatTerm(p_timeString => p_period_type1);
    l_period_type2 := formatTerm(p_timeString => p_period_type2);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || p_period_number);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' ||  l_period_type1);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' ||  l_period_type2);

    if l_period_type1 = l_period_type2 then
        l_ratio := 1;

    -- how many xxx in a month
    elsif l_period_type1 = 'MONTHS' then

        if l_period_type2 = 'DAYS' then
           l_ratio := 30;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 4;
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 2;
        elsif l_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 2;
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 1 / 2;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 1 / 3;
        elsif l_period_type2 = 'SEMI-ANNUALS' then
           l_ratio := 1 / 6;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 12;
        end if;

    -- how many xxx in a quarter
    elsif l_period_type1 = 'QUARTERS' then

        if l_period_type2 = 'DAYS' then
           l_ratio := 91;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 13;
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 6;
        elsif l_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 6;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 3;
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 3 / 2;
        elsif l_period_type2 = 'SEMI-ANNUALS' then
           l_ratio := 1 / 2;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 4;
        end if;

    -- how many xxx in a year
    elsif l_period_type1 = 'YEARS'  then

        if l_period_type2 = 'DAYS' then
           l_ratio := 365;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 52;
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 26;
        elsif l_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 24;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 12;
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 6;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 4;
        elsif l_period_type2 = 'SEMI-ANNUALS' then
           l_ratio := 2;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1;
        end if;

    -- how many xxx in a week
    elsif l_period_type1 = 'WEEKS' then

        if l_period_type2 = 'DAYS' then
           l_ratio := 7;
        elsif l_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 1 / 2;
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 1 / 2;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 1 / 4;
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 1 / 8;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 1 / 13;
        elsif l_period_type2 = 'SEMI-ANNUALS' then
           l_ratio := 1 / 26;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 52;
        end if;

    -- how many xxx in a semi-month --15 days
    elsif l_period_type1 = 'SEMI-MONTHS' then

        if l_period_type2 = 'DAYS' then
           l_ratio := 15;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 2;
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 2;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 1 / 2;
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 1 / 4;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 1 / 6;
        elsif p_period_type2 = 'SEMI-ANNUALS' then
           l_ratio := 1 / 12;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 24;
        end if;

    -- how many xxx in a bi-week --14 days
    elsif l_period_type1 = 'BI-WEEKS' then

        if l_period_type2 = 'DAYS' then
           l_ratio := 14;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 2;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 1 / 2;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 1 / 6;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 26;
        end if;

    -- how many xxx in a semi-annual --
    elsif l_period_type1 = 'SEMI-ANNUALS' then

        if l_period_type2 = 'DAYS' then
           l_ratio := 182;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 26;
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 13;
        elsif p_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 13;
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 3;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 6;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 2;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 2;
        end if;

    -- how many xxx in a bi-month
    elsif l_period_type1 = 'BI-MONTHS' then     -- 60 days


        if l_period_type2 = 'DAYS' then
           l_ratio := 60;
        elsif l_period_type2 = 'WEEKS' then
           l_ratio := 8;
        elsif p_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 4;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 2;
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 2 / 3;
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 6;
        end if;

    -- how many xxx for a day
    elsif l_period_type1 = 'DAYS' then

        if l_period_type2 = 'WEEKS' then
           l_ratio := 1 / 7;
        elsif l_period_type2 = 'SEMI-MONTHS' then
           l_ratio := 1 / (365/24);
        elsif l_period_type2 = 'BIWEEKS' then
           l_ratio := 1 / 14;
        elsif l_period_type2 = 'MONTHS' then
           l_ratio := 1 / (365/12);
        elsif l_period_type2 = 'BI-MONTHS' then
           l_ratio := 1 / (365/6);
        elsif l_period_type2 = 'QUARTERS' then
           l_ratio := 1 / (365/4);
        elsif l_period_type2 = 'SEMI-ANNUALS' then
           l_ratio := 1 / (365/2);
        elsif l_period_type2 = 'YEARS' then
           l_ratio := 1 / 365;
        end if;

    end if;

    l_num_intervals := p_period_number * l_ratio;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': num intervals is: ' || l_num_intervals);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    if (l_num_intervals > 0 and l_num_intervals < 1) then
      l_num_intervals := 1;
    end if;


    IF l_period_type1 = 'DAYS' THEN
      return ceil(l_num_intervals);
    ELSE
      return round(l_num_intervals);
    END IF;

end intervalsInPeriod;

/*========================================================================
||  PUBLIC FUNCTION convertPeriod
||
|| DESCRIPTION
||      function that will return the number of X in a term period in
||       terms of MONTHS
||
||     e.g. MONTHS in 4 YEARS = 48
||          MONTHS in 7 QUARTERS = 21
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||                 p_term
|                  p_term_period
|                  p_convert_to_term_period
|| Return value:
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/12/05 6:42:PM      raverma           Created
|| 29-Jan-2008		 mbolli		   Bug#6634845 - added to work for 'DAYS' term also
 =======================================================================*/
function convertPeriod(p_term                   in number
                      ,p_term_period            in varchar2) return number

is

  l_return      number;
  l_api_name    varchar2(25);

begin

  l_api_name := 'convertPeriod';

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_term ' || p_term);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_term_period ' || p_term_period);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calling IntInPer ');

  if p_term_period = 'DAYS' then
  l_return := intervalsInPeriod(p_period_number => p_term
                               ,p_period_type1  => p_term_period
                               ,p_period_type2  => 'DAYS');
  else
   l_return := intervalsInPeriod(p_period_number => p_term
                               ,p_period_type1  => p_term_period
                               ,p_period_type2  => 'MONTHS');
  end if;



  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_return ' || l_return);

  return l_return;

end convertPeriod;

/*========================================================================
 | PUBLIC FUNCTION convertRate
 |
 | DESCRIPTION
 |      enter description
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | Return value:
 |
 | Source Tables: NA
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11/10/04 6:42:PM       raverma           Created
 |
 *=======================================================================*/
function convertRate(p_annualized_rate        in number
                    ,p_amortization_frequency in varchar2) return number
is
    l_converted_rate         number;
    l_amortization_frequency varchar2(30);
    l_api_name               varchar2(30);


begin
    --l_converted_rate := 0;
    l_api_name      := 'convertRate';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    l_amortization_frequency := formatTerm(p_timeString => p_amortization_frequency);
    --l_period_type2 := formatTerm(p_timeString => p_period_type2);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_amortization_frequency ' || l_amortization_frequency);
    --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    if l_amortization_frequency = 'MONTHS' then
        l_converted_rate := p_annualized_rate / 1200;
    elsif l_amortization_frequency = 'BIWEEKS' then
        l_converted_rate := p_annualized_rate / 2600;
    elsif l_amortization_frequency = 'SEMI-MONTHS' then
        l_converted_rate := p_annualized_rate / 2400;
    elsif l_amortization_frequency = 'BI-MONTHS' then
        l_converted_rate := p_annualized_rate / 600;
    elsif l_amortization_frequency = 'QUARTERS' then
        l_converted_rate := p_annualized_rate / 400;
    elsif l_amortization_frequency = 'SEMI-ANNUALS' then
        l_converted_rate := p_annualized_rate / 200;
    elsif l_amortization_frequency = 'YEARS' then
        l_converted_rate := p_annualized_rate / 100;
    elsif l_amortization_frequency = 'WEEKS' then
        l_converted_rate := p_annualized_rate / 5200;
    end if;

    return l_converted_rate;

end convertRate;

/*=========================================================================
|| PUBLIC PROCEDURE getMaturityDate
||
|| DESCRIPTION
||
|| Overview:  returns last installment date for a loan
||
|| Parameter: p_amortized_term = amortized term (30)
||            p_amortized_term_period = period ('YEARS')
||            p_amortization_frequency ('MONTHlY')
||            p_start_date = LOAN_START_DATE
||            p_pay_in_arrears = NOT USED
||
|| Return value:  maturity date of loan
||
|| Source Tables: NA
||
|| Target Tables:  NA
||
||
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03/1/2004  6:22PM     raverma           Created
|| 03/22/2004            raverma           add one interval to get accurate maturity date
|| 03/25/2004            raverma           we will need to change spec - TERM And TERM_PERIOD are appropriate
|| 06/30/2004            raverma           not changing spec...BUT PASS TERM/TERM PERIOD
|| 08/02/2004            raverma           this function is also used by getLoanDetails to get the
||                                         theoretically amortization_maturity_date to get the num_amortization_intervals
|| 08/19/2004            raverma           we actually dont use/need payInArrears parameter -> karthik using this so dont remove
|| 28-Jan-2008		 mbolli		   Bug#6634845 - Added to work this module for term 'DAYS' also.
 *=======================================================================*/
function getMaturityDate(p_term                   in number
                        ,p_term_period            in varchar2
                        ,p_frequency              in varchar2
                        ,p_start_date             in date) return date
is
    --l_pay_dates       lns_fin_utils.DATE_TBL;
    l_intervals       NUMBER;
    l_date            date;
    l_next_date       date;
    l_api_name        varchar2(30);
    i                 number;
    l_term            number;
    l_term_period     varchar2(30);
    l_frequency       varchar2(30);

begin

    l_api_name   := 'getMaturityDate';
    i            := 1;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - term ' || p_term);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - term period ' || p_term_period);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - frequency ' || p_frequency);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - start date ' || to_char(p_start_date,'DD-MON-YYYY HH:MI:SS'));

    l_term            := p_term;
    l_term_period     := p_term_period;
    l_frequency       := p_frequency;

    if l_term is null or l_term_period is null or l_frequency is null
        or p_start_date is null then
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - CANNOT COMPUTE MATURITY DATE');
            FND_MESSAGE.Set_Name('LNS', 'LNS_MATURITY_DATE_INVALID');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Bug#6634845

    IF (l_term_period = 'DAYS') THEN

        l_date := p_start_date + l_term;
	    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Days term calculation in Maturity Date ');

    ELSE

        -- first get number of intervals in loan
        l_intervals := lns_fin_utils.intervalsInPeriod(l_term
                                                      ,l_term_period
                                                      ,'MONTHLY');

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - intervals ' || l_intervals);

        -- l_date := p_start_date;
        l_date := add_months(p_start_date, l_intervals);

    END IF;

 -- Bug#6634845 - Commented out this.
/*
    WHILE i <= l_intervals LOOP
       -- bug 5842639; scherkas 1/16/2007: changed calculation method for payment dates
       --l_next_date          := lns_fin_utils.getNextDate(l_date, p_frequency, 1);
       l_next_date          := lns_fin_utils.getNextDate(p_start_date, p_frequency, i);     -- new way
       l_date               := l_next_date;
       i := i + 1;
    END LOOP;
*/

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - date returns is ' || l_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - maturity date ' || to_char(l_date,'DD-MON-YYYY HH:MI:SS'));
    return trunc(l_date);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

end getMaturityDate;

/*=========================================================================
|| PUBLIC PROCEDURE getPaymentSchedule
||
|| DESCRIPTION
||
|| Overview:  return a table of dates that payments are due for a loan
||
||
|| Parameter:  first_payment_date date
||             number of intervals
||             interval type (weeks, months, quarters, years)
||
|| Return value: table of dates
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/10/2003 4:28PM     raverma           Created
||  7/28/2004            raverma           change this to handle maturityDate
||  4/05/2005            raverma           should result in unique pay dates
|| 01/19/2007            scherkas          Fixed bug 5842639: added p_loan_start_date parameter
 *=======================================================================*/
function getPaymentSchedule(p_loan_start_date in date
                           ,p_first_pay_date in date
                           ,p_maturity_date  in date
                           ,p_pay_in_arrears in boolean
                           ,p_num_intervals  in number
                           ,p_interval_type  in varchar2) return lns_fin_utils.DATE_TBL
is
  l_payment_dates               lns_fin_utils.DATE_TBL;
  i                             number;
  k                             number;
  l_date                        date;
  l_next_date                   date;
  l_multiplier                  number;
  l_api_name                    varchar2(25);
  l_skip                        boolean;
  l_default_first_pay_date      date;
  l_start_date                  date;
  l_intervals                   number;

begin

     l_api_name := 'getPaymentSchedule';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_first_pay_date ' || p_first_pay_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_maturity_date ' || p_maturity_date);
--     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_num_intervals ' || p_num_intervals);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_interval_type ' || p_interval_type);

/*
     if p_pay_in_arrears then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_pay_in_arrears TRUE');
     else
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_pay_in_arrears FALSE');
     end if;

     l_skip := false;
     l_default_first_pay_date := lns_fin_utils.getNextDate(p_loan_start_date, p_interval_type, 1);
     if l_default_first_pay_date = p_first_pay_date then

        i := 0;
        l_start_date := p_loan_start_date;
        l_intervals := p_num_intervals;

        if p_first_pay_date = p_maturity_date then
            l_payment_dates(i+1) := p_first_pay_date;
            l_skip := true;
        end if;

     else

        i := 1;
        l_start_date := p_first_pay_date;
        l_intervals := p_num_intervals - 1;
        l_payment_dates(i) := p_first_pay_date;

        if p_first_pay_date = p_maturity_date then
            l_skip := true;
        end if;

     end if;

     --l_next_date        := p_first_pay_date;

     if l_skip = false then
--    if p_first_pay_date <> p_maturity_date then
        -- the first pay date is already established at this point
        -- this loop builds the table of subsequent dates that payments will be due
        -- since first pay date can be anywhere on the loan we build schedule
        -- until we pass the maturity date
        -- for paying in advance we will go thru the entire schedule
        for k in 1..l_intervals loop

            -- bug 5842639; scherkas 1/16/2007: changed calculation method for payment dates
            --l_next_date          := lns_fin_utils.getNextDate(l_payment_dates(i), p_interval_type, 1);   -- old way
            l_next_date          := lns_fin_utils.getNextDate(l_start_date, p_interval_type, k);    -- new way

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || i || ' - next_date ' || l_next_date);
            -- we should never get beyond the maturity date

            -- scherkas; fixed bug 6111460: fixes problem with generating several installments on the last installment date if first payment date is later then default first payment date
            if (p_pay_in_arrears and trunc(l_next_date) > trunc(p_maturity_date)) or
            (trunc(l_next_date) = trunc(p_maturity_date)) then
                    -- for pay in arrears make sure there is final payment on maturity date
                l_payment_dates(i+1) := p_maturity_date;
                exit;
            end if;
            l_payment_dates(i+1) := l_next_date;
            i := i + 1;
        end loop;
    end if;
*/

    i := 1;
    l_payment_dates(i) := p_first_pay_date;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || i || ' - ' || l_payment_dates(i));

    if p_first_pay_date <> p_maturity_date then

        k := 1;
        l_next_date := lns_fin_utils.getNextDate(p_first_pay_date, p_interval_type, k);
        while true loop

            if trunc(l_next_date) > trunc(p_maturity_date) then
                exit;
            end if;

            i := i + 1;
            l_payment_dates(i) := l_next_date;
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' ' || i || ' - ' || l_payment_dates(i));

            k := k + 1;
            l_next_date := lns_fin_utils.getNextDate(p_first_pay_date, p_interval_type, k);

        end loop;

    end if;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_payment_dates;

end getPaymentSchedule;

/*=========================================================================
 | PUBLIC FUNCTION getInstallmentDate
 |
 | DESCRIPTION
 |      gets an installment date for a given loan
 |
 | PSEUDO CODE/LOGIC
||       based off of the loan_start_date and the payment_frequency
||       we will build dates
 |
 | PARAMETERS  p_loan_id = loan ID
 |             p_installment --> installment number to get
||
 | Return value:  date installment is due
 |
 | Source Tables: NA
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
||       we are passing negative installments for memo fees staring before
||       loan start date
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03/31/2004 3:56PM       raverma           Created
 |
 *=======================================================================*/
function getInstallmentDate(p_loan_id            IN NUMBER
                           ,p_installment_number IN NUMBER) return date
is
  CURSOR c_payment_info(p_Loan_id NUMBER) IS
  SELECT
         t.loan_payment_frequency
        ,t.first_payment_date
    FROM lns_loan_headers_all h, lns_terms t
   WHERE h.loan_id = p_loan_id AND
         h.loan_id = t.loan_id;

   l_payment_frequency   varchar2(30);
   l_first_payment_date  date;
   l_installment_date    date;

begin

    open c_payment_info(p_loan_id);
       fetch c_payment_info
        into l_payment_frequency
            ,l_first_payment_date;
    close c_payment_info;

    l_installment_date   :=  lns_fin_utils.getNextDate(p_date          => l_first_payment_date
                                                      ,p_interval_type => l_payment_frequency
                                                      ,p_direction     => p_installment_number);
    return l_installment_date;

end getInstallmentDate;

/*=========================================================================
|| PUBLIC PROCEDURE getNumberInstallments
||
|| DESCRIPTION
||
|| Overview:  returns the number of installments for a loan
||
|| Parameter: p_loan_id  => loan_id
||
|| Return value:  last number of installments
||
|| Source Tables: LNS_LOAN_HEADER, LNS_TERMS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 03/8/2004  6:22PM     raverma           Created
|| 03/26/2004            raverma           make standalone call for performance
 *=======================================================================*/
function getNumberInstallments(p_loan_id in number) return NUMBER

is
    l_api_name         varchar2(25);

    l_installments  NUMBER;
    l_term                   number;
    l_term_period            varchar2(30);
    l_amortized_term         number;
    l_amortized_term_period  varchar2(30);
    l_amortization_frequency varchar2(30);
    l_payment_frequency      varchar2(30);

    cursor c_details (p_loan_id NUMBER)
    is
    SELECT h.loan_term
        ,h.loan_term_period
        ,h.amortized_term
        ,h.amortized_term_period
        ,t.amortization_frequency
        ,t.loan_payment_frequency
    FROM lns_loan_headers_all h, lns_terms t
    WHERE h.loan_id = p_loan_id AND
         h.loan_id = t.loan_id;

begin

    l_api_name := 'getNumberInstallments';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    l_installments  := 0;

    OPEN c_details(p_loan_id);
    FETCH c_details INTO
            l_term
           ,l_term_period
           ,l_amortized_term
           ,l_amortized_term_period
           ,l_amortization_frequency
           ,l_payment_frequency;
    close c_details;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term: ' || l_term);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term_period: ' || l_term_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_amortized_term: ' || l_amortized_term);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_amortized_term_period: ' || l_amortized_term_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_amortization_frequency: ' || l_amortization_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_payment_frequency: ' || l_payment_frequency);

    l_installments := lns_fin_utils.intervalsInPeriod(l_term
                                                     ,l_term_period
                                                     ,l_payment_frequency);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_installments: ' || l_installments);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_installments;

end getNumberInstallments;


/*=========================================================================
|| PUBLIC PROCEDURE getNumberInstallments - R12
||
|| DESCRIPTION
||
|| Overview:  returns the number of installments for a loan
||
|| Parameter: p_loan_id  => loan_id
||            p_phase    => phase of the loan
||
|| Return value:  last number of installments
||
|| Source Tables: LNS_LOAN_HEADER, LNS_TERMS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/17/2005  6:22PM    raverma           Created
 *=======================================================================*/
function getNumberInstallments(p_loan_id in number
                              ,p_phase   in varchar2) return NUMBER
is
    l_api_name         varchar2(25);

    l_installments  NUMBER;
    l_term                   number;
    l_term_period            varchar2(30);
    l_payment_frequency      varchar2(30);

    l_loan_start_date           date;
    l_maturity_date             date;
    l_first_payment_date        date;
    l_intervals                 number;
    l_pay_in_arrears            varchar2(1);
    l_pay_in_arrears_bool       boolean;
    l_prin_first_pay_date       date;
    l_prin_intervals            number;
    l_prin_payment_frequency    varchar2(30);
    l_prin_pay_in_arrears       varchar2(1);
    l_prin_pay_in_arrears_bool  boolean;
    l_pay_calc_method           varchar2(30);

    l_payment_tbl               LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_custom_schedule           varchar2(1);

    cursor c_details (p_loan_id NUMBER, p_phase varchar2)
    is
    SELECT decode(p_phase, 'OPEN', h.open_loan_term,
	                       'TERM', h.loan_term, h.loan_term)
        ,decode(p_phase, 'OPEN', h.open_loan_term_period,
				         'TERM', h.loan_term_period, h.loan_term_period)
        ,decode(p_phase, 'OPEN', t.open_payment_frequency,
				         'TERM', t.loan_payment_frequency, t.loan_payment_frequency)
        ,decode(p_phase, 'TERM', trunc(h.loan_start_date),
                         'OPEN' , trunc(h.open_loan_start_date), trunc(h.loan_start_date))
        ,decode(p_phase, 'TERM', trunc(t.first_payment_date),
                         'OPEN' , trunc(t.open_first_payment_date), trunc(t.first_payment_date))
        ,decode(p_phase, 'TERM', trunc(h.loan_maturity_date),
                         'OPEN', trunc(h.open_maturity_date), trunc(h.loan_maturity_date))
        ,decode(p_phase, 'TERM', decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y')
				       , 'OPEN', decode(trunc(t.open_first_payment_date) - trunc(h.open_loan_start_date), 0, 'N', 'Y')
                       , decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y'))
        ,nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT')
        ,trunc(nvl(t.prin_first_pay_date, t.first_payment_date))
        ,nvl(t.prin_payment_frequency, t.loan_payment_frequency)
        ,decode(trunc(nvl(t.prin_first_pay_date, t.first_payment_date)) - trunc(h.loan_start_date), 0, 'N', 'Y')
        ,nvl(h.custom_payments_flag, 'N')
    FROM lns_loan_headers_all h, lns_terms t
    WHERE h.loan_id = p_loan_id AND
         h.loan_id = t.loan_id;

    cursor c_num_cust_instal (p_loan_id NUMBER) is
        select max(PAYMENT_NUMBER)
        from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = p_loan_id;

begin

    l_api_name := 'getNumberInstallments2';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id: ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_phase: ' || p_phase);

    l_installments  := 0;

    OPEN c_details(p_loan_id, p_phase);
    FETCH c_details INTO
            l_term
           ,l_term_period
           ,l_payment_frequency
           ,l_loan_start_date
           ,l_first_payment_date
           ,l_maturity_date
           ,l_pay_in_arrears
           ,l_pay_calc_method
           ,l_prin_first_pay_date
           ,l_prin_payment_frequency
           ,l_prin_pay_in_arrears
           ,l_custom_schedule;
    close c_details;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term: ' || l_term);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term_period: ' || l_term_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_payment_frequency: ' || l_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_start_date: ' || l_loan_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_first_payment_date: ' || l_first_payment_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_maturity_date: ' || l_maturity_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_in_arrears: ' || l_pay_in_arrears);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_calc_method: ' || l_pay_calc_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_first_pay_date: ' || l_prin_first_pay_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_payment_frequency: ' || l_prin_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_pay_in_arrears: ' || l_prin_pay_in_arrears);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_custom_schedule: ' || l_custom_schedule);

    if p_phase = 'OPEN' then
/*
        l_installments := lns_fin_utils.intervalsInPeriod(l_term
                                                        ,l_term_period
                                                        ,l_payment_frequency);
*/
        if l_pay_in_arrears = 'Y' then
            l_pay_in_arrears_bool := true;
        else
            l_pay_in_arrears_bool := false;
        end if;

        l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => l_loan_start_date
                                        ,p_loan_maturity_date => l_maturity_date
                                        ,p_first_pay_date     => l_first_payment_date
                                        ,p_num_intervals      => null
                                        ,p_interval_type      => l_payment_frequency
                                        ,p_pay_in_arrears     => l_pay_in_arrears_bool);

        l_installments := l_payment_tbl.count;

    else

        if l_custom_schedule = 'N' then

            if (l_pay_calc_method = 'SEPARATE_SCHEDULES') then

                if l_pay_in_arrears = 'Y' then
                    l_pay_in_arrears_bool := true;
                else
                    l_pay_in_arrears_bool := false;
                end if;

                if l_prin_pay_in_arrears = 'Y' then
                    l_prin_pay_in_arrears_bool := true;
                else
                    l_prin_pay_in_arrears_bool := false;
                end if;
/*
                l_intervals := lns_fin_utils.intervalsInPeriod(l_term
                                                            ,l_term_period
                                                            ,l_payment_frequency);

                l_prin_intervals := lns_fin_utils.intervalsInPeriod(l_term
                                                                    ,l_term_period
                                                                    ,l_prin_payment_frequency);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_intervals: ' || l_intervals);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_intervals: ' || l_prin_intervals);
*/
                l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                                        p_loan_start_date      => l_loan_start_date
                                        ,p_loan_maturity_date  => l_maturity_date
                                        ,p_int_first_pay_date  => l_first_payment_date
                                        ,p_int_num_intervals   => l_intervals
                                        ,p_int_interval_type   => l_payment_frequency
                                        ,p_int_pay_in_arrears  => l_pay_in_arrears_bool
                                        ,p_prin_first_pay_date => l_prin_first_pay_date
                                        ,p_prin_num_intervals  => l_prin_intervals
                                        ,p_prin_interval_type  => l_prin_payment_frequency
                                        ,p_prin_pay_in_arrears => l_prin_pay_in_arrears_bool);

                l_installments := l_payment_tbl.count;

            else
/*
                l_installments := lns_fin_utils.intervalsInPeriod(l_term
                                                                ,l_term_period
                                                                ,l_payment_frequency);
*/

                if l_pay_in_arrears = 'Y' then
                    l_pay_in_arrears_bool := true;
                else
                    l_pay_in_arrears_bool := false;
                end if;

                l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => l_loan_start_date
                                        ,p_loan_maturity_date => l_maturity_date
                                        ,p_first_pay_date     => l_first_payment_date
                                        ,p_num_intervals      => null
                                        ,p_interval_type      => l_payment_frequency
                                        ,p_pay_in_arrears     => l_pay_in_arrears_bool);

                l_installments := l_payment_tbl.count;

            end if;

        else

            -- Fixed bug 6133313
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Getting number of installments from LNS_CUSTOM_PAYMNT_SCHEDS...');
            OPEN c_num_cust_instal(p_loan_id);
            FETCH c_num_cust_instal INTO l_installments;
            close c_num_cust_instal;

        end if;   --if l_custom_schedule = 'N'

    end if;   --if p_phase = 'OPEN'

    -- fix for bug 8309391: set number of installments = last billed istall number or 1 if no rows in amort sched
    if l_installments = 0 then
        l_installments := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);
        if l_installments = 0 then
            l_installments := 1;
        end if;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_installments: ' || l_installments);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_installments;

end getNumberInstallments;


/*=========================================================================
|| PUBLIC PROCEDURE buildPaymentSchedule
||
|| DESCRIPTION
||
|| Overview:  return a table of dates that represent installment
||             begin and end dates for a loan
||
||
|| Parameter:  first_payment_date date
||             number of intervals
||             interval type (weeks, months, quarters, years)
||             pay_in_arrears TRUE if loan is paid in arrears, FALSE in advance
||
|| Return value: table of dates
||
|| Source Tables: LNS_LOAN_HEADER, LNS_TERMS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 11/2/2004 4:28PM     raverma           Created
 *=======================================================================*/
function buildPaymentSchedule(p_loan_start_date    in date
                             ,p_loan_maturity_date in date
                             ,p_first_pay_date     in date
                             ,p_num_intervals      in number
                             ,p_interval_type      in varchar2
                             ,p_pay_in_arrears     in boolean) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL

is
  l_pay_dates        LNS_FIN_UTILS.DATE_TBL;
  l_payment_schedule LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
  l_num_installments number;
  l_multiplier       number;
  l_api_name         varchar2(25);

begin

     l_api_name := 'buildPaymentSchedule';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_start_date ' || p_loan_start_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_maturity_date ' || p_loan_maturity_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - first_pay_date ' || p_first_pay_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - num_intervals ' || p_num_intervals);
     if p_pay_in_arrears then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_pay_in_arrears TRUE');
     end if;

     -- fix for bug 5842639: added p_loan_start_date parameter to LNS_FIN_UTILS.getPaymentSchedule
     l_pay_dates := LNS_FIN_UTILS.getPaymentSchedule(p_loan_start_date => p_loan_start_date
                                                    ,p_first_pay_date => p_first_pay_date
                                                    ,p_maturity_Date  => p_loan_maturity_date
                                                    ,p_pay_in_arrears => p_pay_in_arrears
                                                    ,p_num_intervals  => p_num_intervals
                                                    ,p_interval_type  => p_interval_type);

     -- we need to ensure maturity date is accurately calculated
     -- also begin / end period dates is very important to the calculation of interest due
     l_num_installments := l_pay_dates.count;
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - number installments: ' || l_num_installments);
     for i in 1..l_num_installments
     loop

       -- begin bug fix 6498340; scherkas; 10/12/2007;
       if i = 1 then
           l_payment_schedule(i).period_begin_date := p_loan_start_date;
       else
           l_payment_schedule(i).period_begin_date := l_pay_dates(i - 1);
       end if;
       l_payment_schedule(i).period_end_date    := l_pay_dates(i);
       l_payment_schedule(i).period_due_date := l_payment_schedule(i).period_end_date;
       -- end bug fix 6498340; scherkas; 10/12/2007;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- ' ||  i || ': ' || l_payment_schedule(i).period_due_date || ' (from ' ||  l_payment_schedule(i).period_begin_date || ' to ' || l_payment_schedule(i).period_end_date || ')');

--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- ' ||  i || ' period_start_date: ' || l_payment_schedule(i).period_begin_date);
--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- ' ||  i || ' period_end_date:   ' || l_payment_schedule(i).period_end_date);
--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- ' ||  i || ' period_due_date:   ' || l_payment_schedule(i).period_due_date);

     end loop;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

     return l_payment_schedule;

end buildPaymentSchedule;


/*=========================================================================
|| PUBLIC PROCEDURE buildSIPPaymentSchedule
||
|| DESCRIPTION
||
|| Overview:  return a table of dates that represent installment begin and
||            end dates for a seperate interest and principal (SIP) schedules loan
||
||
|| Parameters:
||
|| Return value: table of dates
||
|| Source Tables: LNS_LOAN_HEADER, LNS_TERMS
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10/03/2007            scherkas          Created: fix for bug 6498771
 *=======================================================================*/
function buildSIPPaymentSchedule(p_loan_start_date    in date
                             ,p_loan_maturity_date in date
                             ,p_int_first_pay_date     in date
                             ,p_int_num_intervals      in number
                             ,p_int_interval_type      in varchar2
                             ,p_int_pay_in_arrears     in boolean
                             ,p_prin_first_pay_date     in date
                             ,p_prin_num_intervals      in number
                             ,p_prin_interval_type      in varchar2
                             ,p_prin_pay_in_arrears     in boolean) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL
is
     l_api_name                varchar2(25);
     l_merged_payment_tbl      LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
     l_int_payment_tbl         LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
     l_prin_payment_tbl        LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
     int_count                 number;
     prin_count                number;
     merged_count              number;
     l_int_due_date            date;
     l_prin_due_date           date;
     l_int_pay                 LNS_FIN_UTILS.PAYMENT_SCHEDULE;
     l_prin_pay                LNS_FIN_UTILS.PAYMENT_SCHEDULE;
     l_size                    number;
     i                         number;
     j                         number;

     TYPE number_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_delete_tbl                number_tbl;

begin

     l_api_name := 'buildSIPPaymentSchedule';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_start_date ' || p_loan_start_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_maturity_date ' || p_loan_maturity_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - INT first_pay_date ' || p_int_first_pay_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - INT num_intervals ' || p_int_num_intervals);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - INT interval_type ' || p_int_interval_type);
     if p_int_pay_in_arrears then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - INT pay_in_arrears TRUE');
     else
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - INT pay_in_arrears FALSE');
     end if;
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - PRIN first_pay_date ' || p_prin_first_pay_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - PRIN num_intervals ' || p_prin_num_intervals);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - PRIN interval_type ' || p_prin_interval_type);
     if p_prin_pay_in_arrears then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - PRIN pay_in_arrears TRUE');
     else
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - PRIN pay_in_arrears FALSE');
     end if;

     -- get interest payment schedule
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INT payment schedule:');
     l_int_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => p_loan_start_date
                                        ,p_loan_maturity_date => p_loan_maturity_date
                                        ,p_first_pay_date     => p_int_first_pay_date
                                        ,p_num_intervals      => p_int_num_intervals
                                        ,p_interval_type      => p_int_interval_type
                                        ,p_pay_in_arrears     => p_int_pay_in_arrears);
/*
     for j in 1..l_int_payment_tbl.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, j || ': ' || l_int_payment_tbl(j).PERIOD_DUE_DATE);
     end loop;
*/
     -- get principal payment schedule
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRIN payment schedule:');
     l_prin_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => p_loan_start_date
                                        ,p_loan_maturity_date => p_loan_maturity_date
                                        ,p_first_pay_date     => p_prin_first_pay_date
                                        ,p_num_intervals      => p_prin_num_intervals
                                        ,p_interval_type      => p_prin_interval_type
                                        ,p_pay_in_arrears     => p_prin_pay_in_arrears);
/*
     for j in 1..l_prin_payment_tbl.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, j || ': ' || l_prin_payment_tbl(j).PERIOD_DUE_DATE);
     end loop;
*/

     -- merging payment schedules
     int_count := 1;
     prin_count := 1;
     merged_count := 1;
     loop
        l_int_due_date := null;
        l_prin_due_date := null;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '-------');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'int_count = ' || int_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'prin_count = ' || prin_count);

        if (int_count <= l_int_payment_tbl.count ) then
            l_int_pay := l_int_payment_tbl(int_count);
            l_int_pay.CONTENTS := 'INT';
            l_int_due_date := trunc(l_int_pay.PERIOD_DUE_DATE);
        end if;
        if (prin_count <= l_prin_payment_tbl.count ) then
            l_prin_pay := l_prin_payment_tbl(prin_count);
            l_prin_pay.CONTENTS := 'PRIN';
            l_prin_due_date := trunc(l_prin_pay.PERIOD_DUE_DATE);
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_int_due_date = ' || l_int_due_date);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_due_date = ' || l_prin_due_date);

        if (l_int_due_date is not null and l_prin_due_date is not null) then

            if (l_int_due_date < l_prin_due_date) then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'if 11');
                l_merged_payment_tbl(merged_count) := l_int_pay;
                int_count := int_count + 1;
            elsif (l_int_due_date > l_prin_due_date) then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'if 12');
                l_merged_payment_tbl(merged_count) := l_prin_pay;
                prin_count := prin_count + 1;
            elsif (l_int_due_date = l_prin_due_date) then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'if 12');
                l_merged_payment_tbl(merged_count) := l_prin_pay;
                l_merged_payment_tbl(merged_count).CONTENTS := 'PRIN_INT';
                int_count := int_count + 1;
                prin_count := prin_count + 1;
            end if;

        elsif (l_int_due_date is null and l_prin_due_date is not null) then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'if 2');
            l_merged_payment_tbl(merged_count) := l_prin_pay;
            prin_count := prin_count + 1;

        elsif (l_int_due_date is not null and l_prin_due_date is null) then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'if 3');
            l_merged_payment_tbl(merged_count) := l_int_pay;
            int_count := int_count + 1;

        elsif (l_int_due_date is null and l_prin_due_date is null) then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'if 4');
            exit;

        end if;

        if (merged_count > 1) then
            l_merged_payment_tbl(merged_count).PERIOD_BEGIN_DATE := l_merged_payment_tbl(merged_count-1).PERIOD_END_DATE;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'result due_date = ' || l_merged_payment_tbl(merged_count).PERIOD_DUE_DATE);
        merged_count := merged_count + 1;

     end loop;

     -- processing merged payment schedule
     l_size := l_merged_payment_tbl.count;
     if (l_merged_payment_tbl(l_size).CONTENTS = 'PRIN') then
        -- adjusting last installment if its PRIN:
        -- if last installment due date = maturity date then adding INT to this installment
        -- otherwise adding last INT installment on maturity date

        if (l_merged_payment_tbl(l_size).PERIOD_END_DATE = p_loan_maturity_date) then
            l_merged_payment_tbl(l_size).CONTENTS := 'PRIN_INT';
        else
            l_merged_payment_tbl(l_size+1).PERIOD_BEGIN_DATE := l_merged_payment_tbl(l_size).PERIOD_END_DATE;
            l_merged_payment_tbl(l_size+1).PERIOD_DUE_DATE := p_loan_maturity_date;
            l_merged_payment_tbl(l_size+1).PERIOD_END_DATE := p_loan_maturity_date;
            l_merged_payment_tbl(l_size+1).CONTENTS := 'INT';
        end if;
/*
     elsif (l_merged_payment_tbl(l_size).CONTENTS = 'INT') then

        -- collecting all extra INT records and delete then from merged table
        j := 1;
        for i in reverse 1..(l_size-1) loop
            if (l_merged_payment_tbl(i).CONTENTS = 'INT') then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Deleting installment ' || (i+1) || ' - ' || l_merged_payment_tbl(i+1).CONTENTS);
                l_delete_tbl(j) := i+1;
            elsif (l_merged_payment_tbl(i).CONTENTS = 'PRIN') then
                exit;
            elsif (l_merged_payment_tbl(i).CONTENTS = 'PRIN_INT') then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Deleting installment ' || (i+1) || ' - ' || l_merged_payment_tbl(i+1).CONTENTS);
                l_delete_tbl(j) := i+1;
                exit;
            end if;
            j := j + 1;
        end loop;

        for i in 1..l_delete_tbl.count loop
          l_merged_payment_tbl.delete(l_delete_tbl(i));
        end loop;
*/
     end if;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '-------');
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Mixed payment schedule:');
     for j in 1..l_merged_payment_tbl.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, j || ': ' ||l_merged_payment_tbl(j).CONTENTS || ' ' ||
        l_merged_payment_tbl(j).PERIOD_DUE_DATE || ' (from ' || l_merged_payment_tbl(j).PERIOD_BEGIN_DATE ||
        ' to ' || l_merged_payment_tbl(j).PERIOD_END_DATE || ')');
     end loop;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

     return l_merged_payment_tbl;

end buildSIPPaymentSchedule;


/*=========================================================================
|| PUBLIC PROCEDURE getActiveRate
||
|| DESCRIPTION
||
|| Overview:  gets the current interest rate for the loan
||                we will look at the last installment billed (not reversed)
||                to get the rate on the loan
|| Parameter:  loan_id
||
|| Return value: current annual rate for the loan
||
|| Source Tables: LNS_RATE_SCHEDULES, LNS_TERMS, LNS_LOAN_HEADERS_ALL
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 3/8/2004 4:28PM     raverma           Created
||
 *=======================================================================*/
function getActiveRate(p_loan_id in number) return number
is
 l_active_rate      number;
 l_last_installment number;

 cursor c_activeRate(p_loan_id number, p_last_installment number) is
 select current_interest_rate
   from lns_rate_schedules rs
       ,lns_terms t
       ,lns_loan_headers_All lnh
  where lnh.loan_id = p_loan_id
    and lnh.loan_id = t.loan_id
    and t.term_id = rs.term_id
    and rs.end_installment_number >= p_last_installment
    and rs.begin_installment_number <= p_last_installment
    and rs.end_date_active is null
    and rs.phase = lnh.current_phase;

begin

	 l_last_installment := 1;
   l_active_rate      := -1;

   l_last_installment := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);

	 if l_last_installment = 0
	    then l_last_installment := 1;
	 end if;

	 begin
	 open c_activeRate(p_loan_id, l_last_installment);
	 fetch c_activeRate into l_active_rate;
	 close c_activeRate;

    exception
        when others then
         FND_MESSAGE.Set_Name('LNS', 'LNS_CANNOT_DETERMINE_RATE');
         FND_MSG_PUB.Add;
         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LNS_CANNOT_DETERMINE_RATE - END');
         --RAISE FND_API.G_EXC_ERROR;
    end;
    return l_active_rate;

end getActiveRate;

/*=========================================================================
|| PUBLIC PROCEDURE getRateForDate
||
|| DESCRIPTION
||
|| Overview:  gets an interest rate for a given index and date
|| Parameter:  p_index_rate_id => PK to lns_int_rate_headers
||             p_rate_date     => date to capture rate
||
|| Return value: current annual rate for the index
||
|| Source Tables: lns_int_Rate_lines
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 11/8/2005 4:28PM      raverma           Created
||
 *=======================================================================*/
function getRateForDate(p_index_rate_id   in number
                       ,p_rate_date       in date) return number

is
    cursor c_rate_for_Date(p_index_rate_id number, p_rate_date date) is
    select interest_rate
      from lns_int_Rate_lines
     where interest_rate_id = p_index_rate_id
       and p_rate_date >= start_date_active
       and p_rate_date < end_date_active;

    l_rate number;


begin

  open c_rate_for_Date(p_index_rate_id, p_rate_date);
  fetch c_rate_for_Date into l_rate;
  close c_rate_for_Date;

  return l_rate;

--exception when no_data_found then
--    FND_MESSAGE.SET_NAME('LNS', 'LNS_RATES_ERROR');
--    FND_MSG_PUB.ADD;
end;


/*=========================================================================
|| PUBLIC PROCEDURE getPaymentScheduleExt
||
|| DESCRIPTION
||
|| Overview:  returns lns_fin_utils.DATE_TBL for a loan
||
|| Parameter: p_loan_id  => loan_id
||            p_phase    => phase of the loan
||
|| Return value:  lns_fin_utils.DATE_TBL
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 02/24/2009  6:22PM    scherkas           Created
 *=======================================================================*/
function buildPaymentScheduleExt(p_loan_id in number
                              ,p_phase   in varchar2) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL
is
    l_api_name         varchar2(25);

    l_installments  NUMBER;
    l_term                   number;
    l_term_period            varchar2(30);
    l_payment_frequency      varchar2(30);

    l_loan_start_date           date;
    l_maturity_date             date;
    l_first_payment_date        date;
    l_intervals                 number;
    l_pay_in_arrears            varchar2(1);
    l_pay_in_arrears_bool       boolean;
    l_prin_first_pay_date       date;
    l_prin_intervals            number;
    l_prin_payment_frequency    varchar2(30);
    l_prin_pay_in_arrears       varchar2(1);
    l_prin_pay_in_arrears_bool  boolean;
    l_pay_calc_method           varchar2(30);

    l_payment_tbl               LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_custom_schedule           varchar2(1);

    cursor c_details (p_loan_id NUMBER, p_phase varchar2)
    is
    SELECT decode(p_phase, 'OPEN', h.open_loan_term,
	                       'TERM', h.loan_term, h.loan_term)
        ,decode(p_phase, 'OPEN', h.open_loan_term_period,
				         'TERM', h.loan_term_period, h.loan_term_period)
        ,decode(p_phase, 'OPEN', t.open_payment_frequency,
				         'TERM', t.loan_payment_frequency, t.loan_payment_frequency)
        ,decode(p_phase, 'TERM', trunc(h.loan_start_date),
                         'OPEN' , trunc(h.open_loan_start_date), trunc(h.loan_start_date))
        ,decode(p_phase, 'TERM', trunc(t.first_payment_date),
                         'OPEN' , trunc(t.open_first_payment_date), trunc(t.first_payment_date))
        ,decode(p_phase, 'TERM', trunc(h.loan_maturity_date),
                         'OPEN', trunc(h.open_maturity_date), trunc(h.loan_maturity_date))
        ,decode(p_phase, 'TERM', decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y')
				       , 'OPEN', decode(trunc(t.open_first_payment_date) - trunc(h.open_loan_start_date), 0, 'N', 'Y')
                       , decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y'))
        ,nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT')
        ,trunc(nvl(t.prin_first_pay_date, t.first_payment_date))
        ,nvl(t.prin_payment_frequency, t.loan_payment_frequency)
        ,decode(trunc(nvl(t.prin_first_pay_date, t.first_payment_date)) - trunc(h.loan_start_date), 0, 'N', 'Y')
        ,nvl(h.custom_payments_flag, 'N')
    FROM lns_loan_headers_all h, lns_terms t
    WHERE h.loan_id = p_loan_id AND
         h.loan_id = t.loan_id;

begin

    l_api_name := 'buildPaymentScheduleExt';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id: ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_phase: ' || p_phase);

    l_installments  := 0;

    OPEN c_details(p_loan_id, p_phase);
    FETCH c_details INTO
            l_term
           ,l_term_period
           ,l_payment_frequency
           ,l_loan_start_date
           ,l_first_payment_date
           ,l_maturity_date
           ,l_pay_in_arrears
           ,l_pay_calc_method
           ,l_prin_first_pay_date
           ,l_prin_payment_frequency
           ,l_prin_pay_in_arrears
           ,l_custom_schedule;
    close c_details;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term: ' || l_term);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term_period: ' || l_term_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_payment_frequency: ' || l_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_start_date: ' || l_loan_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_first_payment_date: ' || l_first_payment_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_maturity_date: ' || l_maturity_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_in_arrears: ' || l_pay_in_arrears);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_calc_method: ' || l_pay_calc_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_first_pay_date: ' || l_prin_first_pay_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_payment_frequency: ' || l_prin_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_pay_in_arrears: ' || l_prin_pay_in_arrears);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_custom_schedule: ' || l_custom_schedule);

    if p_phase = 'OPEN' then
/*
        l_installments := lns_fin_utils.intervalsInPeriod(l_term
                                                        ,l_term_period
                                                        ,l_payment_frequency);
*/
        if l_pay_in_arrears = 'Y' then
            l_pay_in_arrears_bool := true;
        else
            l_pay_in_arrears_bool := false;
        end if;

        l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => l_loan_start_date
                                        ,p_loan_maturity_date => l_maturity_date
                                        ,p_first_pay_date     => l_first_payment_date
                                        ,p_num_intervals      => null
                                        ,p_interval_type      => l_payment_frequency
                                        ,p_pay_in_arrears     => l_pay_in_arrears_bool);

    else

        if l_custom_schedule = 'N' then

            if (l_pay_calc_method = 'SEPARATE_SCHEDULES') then

                if l_pay_in_arrears = 'Y' then
                    l_pay_in_arrears_bool := true;
                else
                    l_pay_in_arrears_bool := false;
                end if;

                if l_prin_pay_in_arrears = 'Y' then
                    l_prin_pay_in_arrears_bool := true;
                else
                    l_prin_pay_in_arrears_bool := false;
                end if;
/*
                l_intervals := lns_fin_utils.intervalsInPeriod(l_term
                                                            ,l_term_period
                                                            ,l_payment_frequency);

                l_prin_intervals := lns_fin_utils.intervalsInPeriod(l_term
                                                                    ,l_term_period
                                                                    ,l_prin_payment_frequency);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_intervals: ' || l_intervals);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_intervals: ' || l_prin_intervals);
*/
                l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                                        p_loan_start_date      => l_loan_start_date
                                        ,p_loan_maturity_date  => l_maturity_date
                                        ,p_int_first_pay_date  => l_first_payment_date
                                        ,p_int_num_intervals   => l_intervals
                                        ,p_int_interval_type   => l_payment_frequency
                                        ,p_int_pay_in_arrears  => l_pay_in_arrears_bool
                                        ,p_prin_first_pay_date => l_prin_first_pay_date
                                        ,p_prin_num_intervals  => l_prin_intervals
                                        ,p_prin_interval_type  => l_prin_payment_frequency
                                        ,p_prin_pay_in_arrears => l_prin_pay_in_arrears_bool);

            else
/*
                l_installments := lns_fin_utils.intervalsInPeriod(l_term
                                                                ,l_term_period
                                                                ,l_payment_frequency);
*/
                if l_pay_in_arrears = 'Y' then
                    l_pay_in_arrears_bool := true;
                else
                    l_pay_in_arrears_bool := false;
                end if;

                l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                                p_loan_start_date     => l_loan_start_date
                                                ,p_loan_maturity_date => l_maturity_date
                                                ,p_first_pay_date     => l_first_payment_date
                                                ,p_num_intervals      => null
                                                ,p_interval_type      => l_payment_frequency
                                                ,p_pay_in_arrears     => l_pay_in_arrears_bool);

            end if;

        else

            l_payment_tbl := LNS_CUSTOM_PUB.buildCustomPaySchedule(p_loan_id);

        end if;   --if l_custom_schedule = 'N'

    end if;   --if p_phase = 'OPEN'

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_payment_tbl;

end buildPaymentScheduleExt;

/*=========================================================================
|| PUBLIC FUNCTION getNextInstallmentAfterDate - R12
||
|| DESCRIPTION
||
|| Overview:  returns the installmentNumber for the provided date for a loan
||
|| Parameter: p_loan_id  => loan_id
||	      p_date	 => date for which the installment exists
||            p_phase    => phase of the loan
||
|| Return value:  installment number
||
|| Source Tables: LNS_LOAN_HEADERS_ALL, LNS_TERMS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 13-Jan-2010           mbolli          Bug#9255294 - Created
 *=======================================================================*/
function getNextInstallmentAfterDate(p_loan_id in number
				    ,p_date in date
                                    ,p_phase   in varchar2) return NUMBER
is
    l_api_name         varchar2(30);

    l_installments	     NUMBER;
    l_term                   number;
    l_term_period            varchar2(30);
    l_payment_frequency      varchar2(30);

    l_loan_start_date           date;
    l_maturity_date             date;
    l_first_payment_date        date;
    l_intervals                 number;
    l_pay_in_arrears            varchar2(1);
    l_pay_in_arrears_bool       boolean;
    l_prin_first_pay_date       date;
    l_prin_intervals            number;
    l_prin_payment_frequency    varchar2(30);
    l_prin_pay_in_arrears       varchar2(1);
    l_prin_pay_in_arrears_bool  boolean;
    l_pay_calc_method           varchar2(30);

    l_payment_tbl               LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_custom_schedule           varchar2(1);
    l_exit_loop         boolean;
    l_installment_no	   NUMBER;
    TYPE id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_cust_pay_inst_tbl   id_tbl_type;


    cursor c_details (p_loan_id NUMBER, p_phase varchar2)
    is
    SELECT decode(p_phase, 'OPEN', h.open_loan_term,
	                       'TERM', h.loan_term, h.loan_term)
        ,decode(p_phase, 'OPEN', h.open_loan_term_period,
				         'TERM', h.loan_term_period, h.loan_term_period)
        ,decode(p_phase, 'OPEN', t.open_payment_frequency,
				         'TERM', t.loan_payment_frequency, t.loan_payment_frequency)
        ,decode(p_phase, 'TERM', trunc(h.loan_start_date),
                         'OPEN' , trunc(h.open_loan_start_date), trunc(h.loan_start_date))
        ,decode(p_phase, 'TERM', trunc(t.first_payment_date),
                         'OPEN' , trunc(t.open_first_payment_date), trunc(t.first_payment_date))
        ,decode(p_phase, 'TERM', trunc(h.loan_maturity_date),
                         'OPEN', trunc(h.open_maturity_date), trunc(h.loan_maturity_date))
        ,decode(p_phase, 'TERM', decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y')
				       , 'OPEN', decode(trunc(t.open_first_payment_date) - trunc(h.open_loan_start_date), 0, 'N', 'Y')
                       , decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y'))
        ,nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT')
        ,trunc(nvl(t.prin_first_pay_date, t.first_payment_date))
        ,nvl(t.prin_payment_frequency, t.loan_payment_frequency)
        ,decode(trunc(nvl(t.prin_first_pay_date, t.first_payment_date)) - trunc(h.loan_start_date), 0, 'N', 'Y')
        ,nvl(h.custom_payments_flag, 'N')
    FROM lns_loan_headers_all h, lns_terms t
    WHERE h.loan_id = p_loan_id AND
         h.loan_id = t.loan_id;

    cursor c_cust_instal (c_loan_id NUMBER) is
        select  null, null, due_date, null
        from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = c_loan_id
	order by payment_number;

    cursor c_cust_payments(c_loan_id NUMBER) is
        select payment_number
	from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = c_loan_id
	order by payment_number;

begin

    l_api_name := 'getNextInstallmentAfterDate';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id: ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_date: ' || p_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_phase: ' || p_phase);

    l_installments  := 0;



    OPEN c_details(p_loan_id, p_phase);
    FETCH c_details INTO
            l_term
           ,l_term_period
           ,l_payment_frequency
           ,l_loan_start_date
           ,l_first_payment_date
           ,l_maturity_date
           ,l_pay_in_arrears
           ,l_pay_calc_method
           ,l_prin_first_pay_date
           ,l_prin_payment_frequency
           ,l_prin_pay_in_arrears
           ,l_custom_schedule;
    close c_details;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term: ' || l_term);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_term_period: ' || l_term_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_payment_frequency: ' || l_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_start_date: ' || l_loan_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_first_payment_date: ' || l_first_payment_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_maturity_date: ' || l_maturity_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_in_arrears: ' || l_pay_in_arrears);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_calc_method: ' || l_pay_calc_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_first_pay_date: ' || l_prin_first_pay_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_payment_frequency: ' || l_prin_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_prin_pay_in_arrears: ' || l_prin_pay_in_arrears);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_custom_schedule: ' || l_custom_schedule);


   -- Add validation for p_date that it should be between loanStartDate and loanMaturityDate

   IF ((p_date < l_loan_start_date) OR (p_date >  l_maturity_date))THEN
	-- Raise exception
	 FND_MESSAGE.Set_Name('LNS', 'LNS_MATURITY_DATE_INVALID');
        -- FND_MESSAGE.SET_TOKEN('DATE',p_date);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
   END IF;

    if p_phase = 'OPEN' then
        if l_pay_in_arrears = 'Y' then
            l_pay_in_arrears_bool := true;
        else
            l_pay_in_arrears_bool := false;
        end if;

        l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => l_loan_start_date
                                        ,p_loan_maturity_date => l_maturity_date
                                        ,p_first_pay_date     => l_first_payment_date
                                        ,p_num_intervals      => null
                                        ,p_interval_type      => l_payment_frequency
                                        ,p_pay_in_arrears     => l_pay_in_arrears_bool);

        l_installments := l_payment_tbl.count;

    else

        if l_custom_schedule = 'N' then

            if (l_pay_calc_method = 'SEPARATE_SCHEDULES') then

                if l_pay_in_arrears = 'Y' then
                    l_pay_in_arrears_bool := true;
                else
                    l_pay_in_arrears_bool := false;
                end if;

                if l_prin_pay_in_arrears = 'Y' then
                    l_prin_pay_in_arrears_bool := true;
                else
                    l_prin_pay_in_arrears_bool := false;
                end if;

                l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                                        p_loan_start_date      => l_loan_start_date
                                        ,p_loan_maturity_date  => l_maturity_date
                                        ,p_int_first_pay_date  => l_first_payment_date
                                        ,p_int_num_intervals   => l_intervals
                                        ,p_int_interval_type   => l_payment_frequency
                                        ,p_int_pay_in_arrears  => l_pay_in_arrears_bool
                                        ,p_prin_first_pay_date => l_prin_first_pay_date
                                        ,p_prin_num_intervals  => l_prin_intervals
                                        ,p_prin_interval_type  => l_prin_payment_frequency
                                        ,p_prin_pay_in_arrears => l_prin_pay_in_arrears_bool);

                l_installments := l_payment_tbl.count;

            else

                if l_pay_in_arrears = 'Y' then
                    l_pay_in_arrears_bool := true;
                else
                    l_pay_in_arrears_bool := false;
                end if;

                l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                        p_loan_start_date     => l_loan_start_date
                                        ,p_loan_maturity_date => l_maturity_date
                                        ,p_first_pay_date     => l_first_payment_date
                                        ,p_num_intervals      => null
                                        ,p_interval_type      => l_payment_frequency
                                        ,p_pay_in_arrears     => l_pay_in_arrears_bool);

                l_installments := l_payment_tbl.count;

            end if;

        else

            -- Fixed bug 6133313
            --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Getting number of installments from LNS_CUSTOM_PAYMNT_SCHEDS...');
            OPEN c_cust_instal(p_loan_id);
	    FETCH c_cust_instal BULK COLLECT INTO  l_payment_tbl;
            CLOSE c_cust_instal;

	    OPEN c_cust_payments(p_loan_id);
	    FETCH c_cust_payments BULK COLLECT INTO l_cust_pay_inst_tbl;
	    CLOSE c_cust_payments;

	    l_installments := l_payment_tbl.count;

        end if;   --if l_custom_schedule = 'N'

    end if;   --if p_phase = 'OPEN'


    --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_installments: ' || l_installments);

    -- If there are no instalments then return the lastPaymentNumber increase by 1
    IF l_installments <= 0 THEN
	    l_installment_no := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id) + 1;
	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_installment_no: ' || l_installment_no);

    ELSE

	    FOR k in 1..l_installments
	    LOOP

		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Period: ' || k);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' period start is ' || l_payment_tbl(k).period_due_date);

	       -- check to see if this period is covered in the time

	       l_exit_loop := false;
	       l_installment_no := null;
	       IF l_payment_tbl(k).period_due_date >= p_date THEN
	           IF   l_custom_schedule = 'N'  THEN
			l_installment_no := k;
		   ELSE
		   	l_installment_no := l_cust_pay_inst_tbl(k);
		   END IF;

		   l_exit_loop := true;
	       END IF;

	       IF l_exit_loop THEN
		   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Exiting loop');
		   exit;
	       END IF;

	    END LOOP;

	    -- For CustomPayment Scheds, the latest dueDate might not be defined in customSchedule
	    IF ( (l_installments > 0) AND (NOT l_exit_loop))  THEN
	    	   IF   l_custom_schedule = 'N'  THEN
			l_installment_no := l_installments + 1;
		   ELSE
		   	l_installment_no := l_cust_pay_inst_tbl(l_installments)+1;
		   END IF;

	    END IF;

	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_installment_no: ' || l_installment_no);

    END IF;


       IF (l_installment_no IS NULL) THEN
		l_installment_no := -1;
       END IF;



    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_installment_no;

end getNextInstallmentAfterDate;


/*=========================================================================
|| PUBLIC PROCEDURE getNextInstForDisbursement - R12
||
|| DESCRIPTION
||
|| Overview:  returns the installmentNumber for the provided disbursement
||
|| Parameter: p_loan_id  => disb_header_id
||
|| Return value:  installment number
||
|| Source Tables: LNS_DISB_HEADERS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 05-Feb-2010           mbolli         Bug#9255294  - Created
 *=======================================================================*/
function getNextInstForDisbursement(p_disb_hdr_id in number) return NUMBER
is
    l_api_name			VARCHAR2(30);


    l_installment_no		NUMBER;
    l_loan_id                   NUMBER;
    l_pay_req_date		DATE;
    l_disbursement_date		DATE;
    l_phase			VARCHAR2(30);
    l_sourceDate		DATE;


    cursor c_disb_details (c_disb_hdr_id NUMBER)
    is
    SELECT dh.loan_id
	  ,payment_request_date
	  ,(select max(disbursement_date) from lns_disb_lines
		 where disb_header_id = c_disb_hdr_id) disbursement_date
	  , nvl(lhdr.current_phase, 'TERM')
    FROM lns_disb_headers dh, lns_loan_headers_all lhdr
    WHERE dh.disb_header_id = c_disb_hdr_id
       AND lhdr.loan_id = dh.loan_id;

begin

    l_api_name := 'getNextInstForDisbursement';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_hdr_id: ' || p_disb_hdr_id);

    l_installment_no  := 0;


    OPEN c_disb_details(p_disb_hdr_id);
    FETCH c_disb_details INTO
            l_loan_id
           ,l_pay_req_date
	   ,l_disbursement_date
	   ,l_phase;
    close c_disb_details;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_id: ' || l_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_pay_req_date: ' || l_pay_req_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_disbursement_date: ' || l_disbursement_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_phase: ' || l_phase);

    l_sourceDate := null;
    IF (l_disbursement_date IS NOT NULL) THEN
	l_sourceDate := l_disbursement_date;
    ELSE
	l_sourceDate := l_pay_req_date;
    END IF;

    l_installment_no := getNextInstallmentAfterDate(l_loan_id
						   ,l_sourceDate
						   ,l_phase);


    IF (l_installment_no IS NULL) THEN
	l_installment_no := -1;
    END IF;


    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_installment_no;

end getNextInstForDisbursement;

END LNS_FIN_UTILS;

/

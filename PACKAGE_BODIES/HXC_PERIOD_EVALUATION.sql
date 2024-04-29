--------------------------------------------------------
--  DDL for Package Body HXC_PERIOD_EVALUATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_PERIOD_EVALUATION" as
/* $Header: hxcperevl.pkb 120.3 2006/05/31 10:19:54 sechandr noship $ */

g_debug boolean := hr_utility.debug_enabled;

FUNCTION make_date(p_day varchar2,
                   p_month_year varchar2) RETURN DATE
IS
BEGIN
RETURN to_date(p_day||'-'||p_month_year,'DD-MM-YYYY');
END make_date;

FUNCTION  get_period_list (p_current_date		date,
			   p_recurring_period_type	varchar2,
			   p_duration_in_days		number,
			   p_rec_period_start_date      date,
			   p_max_date_in_futur		date,
			   p_max_date_in_past		date)
			   return period_list IS

l_multiple number;
l_base varchar2(1);

l_temporary_date 	date := p_max_date_in_futur;
l_period_start 		date;
l_period_end		date;
l_index_period_list	number :=0;

l_period_list		period_list;

l_max_date_in_past	date := p_max_date_in_past;

BEGIN

IF p_recurring_period_type is not null THEN

 --populate the table with the period in the futur
 get_period_details(p_proc_period_type => p_recurring_period_type,
                   p_base_period_type => l_base,
                   p_multiple         => l_multiple);

 IF p_rec_period_start_date > p_max_date_in_past THEN
      l_max_date_in_past := p_rec_period_start_date;
 END IF;

 while l_temporary_date > l_max_date_in_past loop

    period_start_stop(p_current_date           => l_temporary_date,
                      p_rec_period_start_date  => p_rec_period_start_date,
                      l_period_start           => l_period_start,
                      l_period_end             => l_period_end,
                      l_base_period_type       => l_base,
                      p_multiple               => l_multiple);

    if l_period_list.exists(l_period_list.last) then
      l_index_period_list := l_period_list.last;
    end if;

    l_period_list(to_number(to_char(l_period_start,'J'))).start_date := l_period_start;
    l_period_list(to_number(to_char(l_period_start,'J'))).end_date   := l_period_end;

    --l_period_list(l_index_period_list + 1).start_date := l_period_start;
    --l_period_list(l_index_period_list + 1).end_date   := l_period_end;

    l_temporary_date := l_period_start - 1;

 END loop;

ELSIF p_duration_in_days is not null THEN

 -- get the first period from the end_date
 l_period_start :=  p_rec_period_start_date +
    (p_duration_in_days *  FLOOR(((p_max_date_in_futur - p_rec_period_start_date)/p_duration_in_days)));

 l_period_end := l_period_start + p_duration_in_days - 1;

 -- populate the table
 if l_period_list.exists(l_period_list.last) then
      l_index_period_list := l_period_list.last;
 end if;

 l_period_list(to_number(to_char(l_period_start,'J'))).start_date := l_period_start;
 l_period_list(to_number(to_char(l_period_start,'J'))).end_date   := l_period_end;

 --l_period_list(l_index_period_list + 1).start_date := l_period_start;
 --l_period_list(l_index_period_list + 1).end_date   := l_period_end;

 l_temporary_date := l_period_start - 1;

 -- now loop to the past period
 while l_temporary_date > p_max_date_in_past loop
    -- populate the table

    if l_period_list.exists(l_period_list.last) then
      l_index_period_list := l_period_list.last;
    end if;

    l_period_list(to_number(to_char(l_temporary_date - p_duration_in_days + 1,'J'))).start_date
    					:= l_temporary_date - p_duration_in_days + 1 ;
    l_period_list(to_number(to_char(l_temporary_date - p_duration_in_days + 1,'J'))).end_date   := l_temporary_date;

    --l_period_list(l_index_period_list + 1).start_date := l_temporary_date - p_duration_in_days + 1 ;
    --l_period_list(l_index_period_list + 1).end_date   := l_temporary_date;

    l_temporary_date := l_temporary_date - p_duration_in_days;

 END LOOP;
END IF;
return l_period_list;

END get_period_list;

PROCEDURE get_period_details (p_proc_period_type IN VARCHAR2,
                              p_base_period_type OUT NOCOPY VARCHAR2,
                              p_multiple         OUT NOCOPY NUMBER) IS
--
l_no_periods per_time_period_types.number_per_fiscal_year%type;
--
l_proc       VARCHAR2(100);
--

l_iter BINARY_INTEGER;
l_cached BOOLEAN := false;

CURSOR c_get_no_periods IS
SELECT number_per_fiscal_year
  FROM per_time_period_types
 WHERE period_type = p_proc_period_type;

BEGIN

g_debug := hr_utility.debug_enabled;

--
if g_debug then
	l_proc := 'hxc_period_evaluation.GET_PERIOD_DETAILS';
	hr_utility.set_location(l_proc, 10);
end if;
--

--Let us check the cached table

l_iter := g_per_time_period_types_ct.first;
WHILE l_iter IS NOT NULL
LOOP
if  (g_per_time_period_types_ct(l_iter).p_proc_period_type = p_proc_period_type)
then
     l_no_periods :=  g_per_time_period_types_ct(l_iter).number_per_fiscal_year;
     l_cached := true;
     exit;
end if;
l_iter := g_per_time_period_types_ct.next(l_iter);
END LOOP;


if (not l_cached)
then
	OPEN c_get_no_periods;
	FETCH c_get_no_periods INTO l_no_periods;
	CLOSE c_get_no_periods;

	l_iter := nvl(g_per_time_period_types_ct.last,0)+1;
	g_per_time_period_types_ct(l_iter).p_proc_period_type := p_proc_period_type;
	g_per_time_period_types_ct(l_iter).number_per_fiscal_year := l_no_periods;
end if;
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
end if;
--
-- Use the number of periods in a fiscal year to deduce the base
-- period and multiple.
--
IF l_no_periods = 1 THEN             -- Yearly
   p_base_period_type := 'M';
   p_multiple := 12;
ELSIF l_no_periods = 2 THEN          -- Semi yearly
   p_base_period_type := 'M';
   p_multiple := 6;
ELSIF l_no_periods = 4 THEN          -- Quarterly
   p_base_period_type := 'M';
   p_multiple := 3;
ELSIF l_no_periods = 6 THEN          -- Bi monthly
   p_base_period_type := 'M';
   p_multiple := 2;
ELSIF l_no_periods = 12 THEN         -- Monthly
   p_base_period_type := 'M';
   p_multiple := 1;
ELSIF l_no_periods = 13 THEN         -- Lunar monthly
   p_base_period_type := 'W';
   p_multiple := 4;
ELSIF l_no_periods = 24 THEN         -- Semi monthly
   p_base_period_type := 'S';
   p_multiple := 1;                -- Not used for semi-monthly
ELSIF l_no_periods = 26 THEN         -- Fortnightly
   p_base_period_type := 'W';
   p_multiple := 2;
ELSIF l_no_periods = 52 THEN         -- Weekly
   p_base_period_type := 'W';
   p_multiple := 1;
ELSE
   -- Unknown period type.
   hr_utility.set_message(801, 'PAY_6601_PAYROLL_INV_PERIOD_TP');
   hr_utility.raise_error;
END IF;
--
if g_debug then
	hr_utility.set_location(l_proc, 30);
end if;
--
END get_period_details;

PROCEDURE period_start_stop(p_current_date                   date,
                            p_rec_period_start_date          date,
                            l_period_start          in out nocopy   date,
                            l_period_end            in out nocopy   date,
                            l_base_period_type               varchar2)
                            IS

l_multiple number;
l_base varchar2(1);

BEGIN

get_period_details(p_proc_period_type => l_base_period_type,
                   p_base_period_type => l_base,
                   p_multiple         => l_multiple);

period_start_stop(p_current_date           => p_current_date,
                  p_rec_period_start_date  => p_rec_period_start_date,
                  l_period_start           => l_period_start,
                  l_period_end             => l_period_end,
                  l_base_period_type	   => l_base,
                  p_multiple               => l_multiple);

END period_start_stop;



PROCEDURE period_start_stop(p_current_date                   date,
                            p_rec_period_start_date          date,
                            l_period_start          in out nocopy   date,
                            l_period_end            in out nocopy   date,
                            l_base_period_type               varchar2,
                            p_multiple			     number)
is

l_before_days                number;
l_num_days_dIFf              number;
l_num_months_to_period_start number;
l_months_before              number;
l_current_month_year         varchar2(10);
l_period_start_day           number;
l_period_end_day             number;
l_current_day                number;
l_fpe                        number;
l_spe                        number;
l_previous_month_start       date;
l_sm_period_end date;

BEGIN

if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_PERIOD_EVALUATION.PERIOD_START_STOP',
               'Base Period Type'||l_base_period_type||' Multiple'||p_multiple);
end if;

IF(l_base_period_type = 'W') THEN
  l_period_end    := NEXT_DAY(p_current_date,to_char(p_rec_period_start_date,'DAY')) - 1;
  l_period_start  := l_period_end - 6;

  l_num_days_dIFf := trunc(l_period_start) - trunc(p_rec_period_start_date);

  -- l_before_days   := mod(l_num_days_dIFf,7*p_multiple);
  -- commenting out the above line for bug 3902747
  -- Adding the ABS( ) function to the result of the MOD( ) to eliminate the chance of
  -- getting negative values

  l_before_days   := abs(mod(l_num_days_dIFf,7*p_multiple));


  if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_PERIOD_EVALUATION.PERIOD_START_STOP',
                 'l_num_days_dIFf '||l_num_days_dIFf||'l_before_days '||l_before_days);
  end if;

  l_period_start  := l_period_start - l_before_days;
  l_period_end    := l_period_end + (7 * (p_multiple-1) - l_before_days);

  if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
  	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_PERIOD_EVALUATION.PERIOD_START_STOP',
                 'Start of Period '||l_period_start||'End of Period '||l_period_end);
  end if;
END IF;

IF(l_base_period_type = 'M') THEN
  l_period_start  := add_months(p_rec_period_start_date,
                                floor(months_between(p_current_date,p_rec_period_start_date)));
  l_period_end    := add_months(l_period_start,1) - 1;

  l_num_months_to_period_start := months_between(l_period_start,p_rec_period_start_date);
  l_months_before := mod(l_num_months_to_period_start,p_multiple);

  if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
  	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_PERIOD_EVALUATION.PERIOD_START_STOP',
                 'l_num_months_to_period_start '||l_num_months_to_period_start||
                 'l_months_before '||l_months_before);
  end if;

  l_period_start  := add_months(l_period_start,-l_months_before);
  l_period_end    := add_months(l_period_end ,(p_multiple-1)-l_months_before);

  if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
  	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_PERIOD_EVALUATION.PERIOD_START_STOP',
                 'Start of Period '||l_period_start||'End of Period '||l_period_end);
  end if;
END IF;

/*

Note that p_rec_period_start_date is the start of the period. The following
evaluation is based on the period end dates. Therefore we step back one day
from the p_rec_period_start_date before doing the evaluation.

This is taken from /hld/. This is by far the worst of all the evaluations

Rules for Semi-Monthly
( INPUT )   (REMARKS)      ( OUTPUT )
1st period                 1st period  2nd per.  3rd per.  4th per.  5th per.
end date                   end date    end date  end date  end date  end date
----------  -------------- --------------------------------------
  01/1                     01/1        16/1      01/2      16/2      01/3
  02/1                     02/1        17/1      02/2      17/2      02/3
.........
  13/1                     13/1        28/1      13/2      28/2      13/3
  14/1    (leap year)      14/1        29/1      14/2      29/2      14/3
  14/1    (non-leap year)  14/1        29/1      14/2      28/2      14/3
  15/1    (Month halfs)    15/1        31/1      15/2   end-of-FEB   15/3
  16/1                     16/1        01/2      16/2      01/3      16/3
 ........
  28/1                     28/1        13/2      28/2      13/3      28/3
  29/1    (leap year)      29/1        14/2      29/2      14/3      29/3
  29/1    (non-leap year)  29/1        14/2      28/2      14/3      29/3
  30/1                     30/1        15/2   end-of-FEB   15/3      30/3
  31/1    (Month halfs)    31/1        15/2   end-of-FEB   15/3      31/3

THE RULES for generating the periods are the following:

(1) IF the first period's end-date is either the 15th or the end of a month
    THEN the generated end-dates will be the 15th or last day of a month.

(2) IF the first period's end-date is before the 15th (i.e 1st - 14th)
    THEN add 15 days for the next period with the restriction that we are
    still in the same month. (i.e. Feb 14th -> Feb 28th for a non-leap year)

(3) IF the first period's end-date is after the 15th but not the end of month
    THEN subtract 15 days and use that day of the following month.
    Example:  March 29th  ->  April 14th

Addendum to this. From observation of how payrolls are generated, if the period
ends prematurely due to the fact that a month has less dates that the FPE start date,
then the start of the follwing period is always pushed to the start day of the next month.
*/

if(l_base_period_type = 'S') then

  l_sm_period_end := p_rec_period_start_date - 1;

  l_period_end_day := to_char(l_sm_period_end,'DD');
  l_current_day :=  to_char(p_current_date,'DD');
  l_current_month_year := to_char(p_current_date,'MM-YYYY');

  if (l_sm_period_end = last_day(l_sm_period_end) or l_period_end_day = '15') then
    if(l_current_day <= '15') then
      l_period_start:=make_date('01',l_current_month_year);
      l_period_end  :=make_date('15',l_current_month_year);
    else
      l_period_start:=make_date('16',l_current_month_year);
      l_period_end := last_day(p_current_date);
    end if;
    return;
  elsif (l_period_end_day <= 14 and l_period_end_day >= '1') then
    l_fpe:=l_period_end_day;
    l_spe:=l_fpe+15;
  elsif (l_period_end_day >= 16 and l_period_end_day <= '30') then
    l_spe:=l_period_end_day;
    l_fpe:=l_spe-15;
  end if;

  if (l_current_day > l_fpe and l_current_day <= l_spe ) then
    l_period_start:= make_date(l_fpe+1,l_current_month_year);
    if(to_char(last_day(p_current_date),'DD') < l_spe) then
      l_period_end:=last_day(p_current_date);
    else
      l_period_end := make_date (l_spe,l_current_month_year);
    end if;
  end if;

  if (l_current_day > l_spe) then
    l_period_start:=make_date(l_spe+1,l_current_month_year);
    l_period_end := add_months(make_date(l_fpe,l_current_month_year),1);
  end if;

  if (l_current_day <= l_fpe) then
    l_period_end:=make_date(l_fpe,l_current_month_year);
    l_previous_month_start:=add_months(make_date('01',l_current_month_year),-1);
    if(to_char(last_day(l_previous_month_start),'DD') < l_spe +1 ) then
-- try something from observation!!!!!!!!!!!!!!
      l_period_start:= make_date('01',l_current_month_year);
    else
      l_period_start:= make_date(l_spe+1,to_char(l_previous_month_start,'MM-YYYY'));
    end if;
  end if;

end if;

END period_start_stop;

end hxc_period_evaluation;

/

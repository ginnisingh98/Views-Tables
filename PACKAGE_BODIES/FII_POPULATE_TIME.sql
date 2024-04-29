--------------------------------------------------------
--  DDL for Package Body FII_POPULATE_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_POPULATE_TIME" AS
/*$Header: FIICMTIB.pls 120.2 2002/11/20 20:22:55 djanaswa ship $*/

PROCEDURE PUSH(Errbuf out NOCOPY varchar2, retcode out NOCOPY Varchar2, rows_inserted out NOCOPY number,
		p_from_date in date,
		p_to_date in date) IS

-- ---------------------------------------------------------
-- Define local variables
-- ---------------------------------------------------------
   l_instance		Varchar2(40);
   l_row_cday           number:=0;
   l_row_day            number:=0;
   l_row_week           number:=0;
   l_row_445            number:=0;
   l_row_hmth           number:=0;
   l_row_mth            number:=0;
   l_row_qtr            number:=0;
   l_row_hyr            number:=0;
   l_row_year           number:=0;
   l_first_half         varchar2(20);
   l_second_half        varchar2(20);
   l_quarter            varchar2(20);
   l_week               varchar2(10);
   l_period             varchar2(10);

-- days
   counter number :=1;
   l_start_date_init date;
   l_end_date_init date;

-- the variables used to populate the days level
   l_days_start_date date;
   l_days_running_date date;
   l_days_last_date date;
   l_days_half_month_start_date date;
   l_days_week_start_date date;

-- the variables used to populate the months level
   l_mon_month_start_date date;
   l_mon_qtr_start_date date;
   l_mon_quarter_date date;
   l_mon_end_date date;

-- the variables used to populate the year level
   l_year_year_start_date date;
   l_year_end_date date;
   l_year_counter number:=0;

-- the variables used to populate the HALF year level
   l_half_half_year_start_date date;
   l_half_half_year_end_date date;
   l_half_year_start_date date;
   l_half_year_end_date date;
   l_half_year_counter number;

-- the variables used to populate the quarter level
   l_start_date_quarter date;
   l_end_date_quarter date;
   l_quarter_start_date date;
   l_quarter_end_date date;
   l_quarter_counter number;

-- the variables used to populate the 445 period level
   l_445_445_start_date date;
   l_445_445_end_date date;
   l_445_year_start_date date;
   l_445_new_year date;
   l_445_end_date date;
   l_445_counter number:=1;
   l_counter number:=1;

-- the variables used to populate the half months level
   l_hm_start_date date;
   l_hm_first_date_of_year date;
   l_hm_running_date date;
   l_hm_end_date date;
   l_hm_counter number:=0;

-- the variables used to populate the weeks level
   l_weeks_week_start_date date;
   l_weeks_year_start_date date;
   l_weeks_new_year_start_date date;
   l_weeks_end_date date;
   l_weeks_counter number;
   l_weeks_year varchar2(4);
   l_weeks_445_counter number:=1;
   l_weeks_445_date date;
   l_weeks_445_end_date date;
   l_added_weeks_445_end_date date;

begin
   l_start_date_init := nvl(trunc(p_from_date,'mm'),trunc(sysdate-1900,'YYYY'));
   l_end_date_init:= nvl(p_to_date,trunc(sysdate+2200,'YYYY'));
   edw_log.put_line( 'The collection range is from '||
   to_char(l_start_date_init,'dd-MON-yyyy')||' to '||
   to_char(l_end_date_init,'dd-MON-yyyy'));
   edw_log.put_line(' ');

   Select substrb(edw_instance.get_code,1,40)
   into l_instance
   from dual;


-- ---------------------------------------------------------
-- Variable initialization
-- ---------------------------------------------------------
   rows_inserted:=0;
   Errbuf :=NULL;
   retcode :=0;

   -- initialize the start date and the end date,
   -- these dates are used by all the levels to decide
   -- the start date and the end date for insertion

   if l_start_date_init is null then
      l_start_date_init :=trunc(trunc(sysdate,'YYYY')-5*365,'YYYY');
   end if;

   if l_end_date_init is null then
      l_end_date_init :=trunc(trunc(sysdate,'YYYY')+5*365,'YYYY');
   end if;

-- assign the start date and the end date to the variables of days level
   l_days_start_date:=l_start_date_init;
   l_days_running_date :=l_start_date_init;
   l_days_last_date :=l_end_date_init;
   l_days_half_month_start_date:=l_days_running_date;
   if (trunc(l_days_running_date,'Day') = trunc(l_days_running_date)) then
     l_days_week_start_date := trunc(l_days_running_date-1,'Day')+1;
   else
     l_days_week_start_date :=trunc(l_days_running_date,'Day')+1;
   end if;

-- assign the start date and the end date to the variables of months level
   l_mon_month_start_date :=trunc(l_start_date_init,'mm');
   l_mon_qtr_start_date:=l_start_date_init;
   l_mon_end_date :=l_end_date_init;

-- assign the start date and the end date to the variables of year level
   l_year_year_start_date:=trunc(l_start_date_init,'yyyy');
   l_year_end_date :=trunc(l_end_date_init,'yyyy');

-- assign the start date and the end date to the variables of half year level
   if l_start_date_init >= add_months(trunc(l_start_date_init,'yyyy'),6) then
      l_half_year_start_date :=add_months(trunc(l_start_date_init,'yyyy'),6);
      l_half_year_counter := 1;
   else
      l_half_year_start_date :=trunc(l_start_date_init,'yyyy');
      l_half_year_counter := 0;
   end if;
   l_half_half_year_start_date :=trunc(l_half_year_start_date ,'YYYY');
   l_half_half_year_end_date :=to_date('06/30/'||to_char(l_half_half_year_start_date,'YYYY'),'MM/DD/YYYY');
   l_half_year_end_date :=l_end_date_init;

-- assign the start date and the end date to the variables of quarter level
   l_start_date_quarter :=trunc(l_start_date_init,'q');
   l_end_date_quarter := trunc(l_end_date_init,'q');
   l_quarter_start_date := trunc(l_start_date_quarter,'YYYY');
   l_quarter_end_date := to_date('03/31/'||to_char(l_quarter_start_date,'YYYY'),'MM/DD/YYYY');
   l_quarter_counter:=1;

-- assign the start date and the end date to the variables of half months level
   l_hm_start_date:=l_start_date_init;
   l_hm_first_date_of_year:=l_start_date_init;
   l_hm_running_date :=l_start_date_init;
   l_hm_end_date :=l_end_date_init;

-- assign the start date and the end date to the variables of weeks level
   l_weeks_week_start_date :=trunc(l_start_date_init,'Day')+1;
   l_weeks_year_start_date:=l_start_date_init;
   l_weeks_end_date :=trunc(l_end_date_init,'Day')+1;
   --l_weeks_445_date :=l_weeks_week_start_date;
   l_weeks_year := to_char(l_weeks_week_start_date,'iyyy');
   --l_weeks_445_end_date := l_weeks_445_date + (4*7)-1;
   --l_added_weeks_445_end_date := l_weeks_445_end_date;
   l_weeks_counter := to_char(l_weeks_week_start_date,'iw');

-- assign the start date and the end date to the variables of 445 period level
   if l_weeks_counter < 5 then
     l_counter:=1;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-1);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 5 and 8 then
     l_counter:=2;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-5);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 9 and 13 then
     l_counter:=3;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-9);
     l_445_445_end_date :=l_445_445_start_date + (5*7)-1;
   elsif l_weeks_counter between 14 and 17 then
     l_counter:=4;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-14);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 18 and 21 then
     l_counter:=5;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-18);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 22 and 26 then
     l_counter:=6;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-22);
     l_445_445_end_date :=l_445_445_start_date + (5*7)-1;
   elsif l_weeks_counter between 27 and 30 then
     l_counter:=7;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-27);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 31 and 34 then
     l_counter:=8;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-31);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 35 and 39 then
     l_counter:=9;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-35);
     l_445_445_end_date :=l_445_445_start_date + (5*7)-1;
   elsif l_weeks_counter between 40 and 43 then
     l_counter:=10;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-40);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 44 and 47 then
     l_counter:=11;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-44);
     l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   elsif l_weeks_counter between 48 and 52 then
     l_counter:=12;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-48);
     l_445_445_end_date :=l_445_445_start_date + (5*7)-1;
   elsif l_weeks_counter=53 then
     l_counter:=12;
     l_445_445_start_date :=l_weeks_week_start_date-7*(l_weeks_counter-48);
     l_445_445_end_date :=l_445_445_start_date + (6*7)-1;
   end if;
   --l_445_445_start_date :=trunc(l_start_date_init-10,'Day');
   --l_445_445_end_date :=l_445_445_start_date + (4*7)-1;
   l_445_year_start_date:=l_start_date_init;
   l_445_end_date :=trunc(l_end_date_init+10,'Day');
   l_weeks_445_date := l_445_445_start_date;

-- ---------------------------------------------------------
-- Begin Pushing gregorian hierarchy
-- ---------------------------------------------------------
   /* Pushing Day */
   begin
   edw_log.put_line(' ');
   edw_log.put_line('Pushing Day and Calendar Day');
   fii_util.start_timer;
   loop
     insert into edw_time_day_lstg
     (day_pk,
	  half_month_fk,
	  week_fk,
	  day,
	  name,
	  julian_day,
	  day_of_week,
	  day_of_year,
      start_date,
      end_date,
	  weekend_flag,
	  timespan,
      instance,
	  collection_status)
     values(
      -- day_pk
	  to_char(l_days_running_date,'dd-mm-yyyy'),
	  -- half month fk
	  to_char(l_days_half_month_start_date,'dd-mm-yyyy'),
	  -- week fk
	  to_char(l_days_week_start_date, 'dd-mm-yyyy'),
	  -- day
	  to_char(l_days_running_date,'dd-MON-yyyy'),
	  -- name
	  to_char(l_days_running_date,'fmdd Month yyyy'),
	  -- julian day
	  to_number(to_char(l_days_running_date,'J')),
	  -- day of week
	  to_char(l_days_running_date,'fmDay'),
	  -- day of year
	  to_char(l_days_running_date,'fmddd'),
      -- start date
	  l_days_running_date,
	  -- end date
	  l_days_running_date,
	  -- weekend flag
	  decode(upper(to_char(l_days_running_date,'fmDay')),'SATURDAY','Y','SUNDAY','Y','N'),
	  -- timespan
	  1,
      -- instance
      l_instance,
      'READY');

     /* Pushing Day level push down to Calendar Day */
     insert into edw_time_cal_day_lstg
     (cal_day_pk,
      day_fk,
      fa_period_fk,
      pa_period_fk,
      cal_period_fk,
      ep_cal_period_fk,
      cal_day,
      name,
      calendar_date,
      end_date,
      timespan,
      instance,
      collection_status)
     values(
      -- cal_day_pk
      to_char(l_days_running_date,'dd-mm-yyyy')||'-DAY',
      -- day fk
      to_char(l_days_running_date,'dd-mm-yyyy'),
      -- fa_period fk , pa_period_fk, cal_period_fk
      'NA_EDW', 'NA_EDW', 'NA_EDW',
      -- ep_cal_period_fk
      'oracle_source',
      -- day
      l_days_running_date,
      -- name ( Added the level prefix name in the begin as per the standard #1964070)
      'DAY-'||to_char(l_days_running_date,'fmdd Month yyyy'),
      -- calendar date
      l_days_running_date,
      -- end date
      l_days_running_date,
      -- timespan
      1,
      -- instance
      l_instance,
      'READY');

     if l_days_running_date < (trunc(l_days_running_date,'MON')+14) then
	    l_days_half_month_start_date:=trunc(l_days_running_date,'MON');
	 else
	    l_days_half_month_start_date:=trunc(l_days_running_date,'MON')+15;
	 end if;

     counter:=counter+1;
     l_days_running_date:=l_days_running_date+1;
     if (trunc(l_days_running_date,'Day') = trunc(l_days_running_date)) then
       l_days_week_start_date := trunc(l_days_running_date-1,'Day')+1;
     else
       l_days_week_start_date :=trunc(l_days_running_date,'Day')+1;
     end if;

     l_row_day:=l_row_day+1;
     l_row_cday:=l_row_cday+1;

	 if l_days_running_date = trunc(l_days_running_date,'MON') then
	 	l_days_half_month_start_date:=trunc(l_days_running_date,'MON');
     end if;

     if (l_days_running_date>l_days_last_date) then
	    exit;
	 end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing Month */
   begin
   edw_log.put_line('Pushing Month and Month level push down');
   fii_util.start_timer;
   loop
     l_mon_quarter_date:=trunc(l_mon_month_start_date,'Q');

     insert into edw_time_month_lstg
     (month_pk,
	  qtr_fk,
	  month,
      name,
	  start_date,
	  end_date,
	  timespan,
      instance,
	  collection_status)
	 values(
	  -- month_pk
	  to_char(l_mon_month_start_date, 'dd-mm-yyyy'),
   	  -- qtr fk
  	  to_char(l_mon_quarter_date,'dd-mm-yyyy'),
	  -- month
	  to_char(l_mon_month_start_date,'MM')||','||to_char(l_mon_month_start_date,'YYYY'),
	  -- name
      to_char(l_mon_month_start_date,'fmMonth yyyy'),
	  -- month_start_date
	  l_mon_month_start_date,
	  -- month_end_date
	  last_day(l_mon_month_start_date),
	  -- month_time_span
	  last_day(l_mon_month_start_date)-l_mon_month_start_date + 1,
      -- instance
      l_instance,
	  'READY');

     /* Pushing Month level push down */
     insert into edw_time_half_month_lstg
     (half_month_pk,
      month_fk,
      half_month,
      name,
      start_date,
      end_date,
      timespan,
      instance,
      collection_status)
     values(
      -- half_month_pk
      to_char(l_mon_month_start_date, 'dd-mm-yyyy')||'-MON',
      -- month fk
      to_char(l_mon_month_start_date,'dd-mm-yyyy'),
      -- half_month
      to_char(l_mon_month_start_date,'MM')||','||to_char(l_mon_month_start_date,'YYYY'),
      -- name ( Added the level prefix name in the begin as per the standard #1964070)
      'MNTH-'||to_char(l_mon_month_start_date,'fmMonth yyyy'),
      -- month_start_date
      l_mon_month_start_date,
      -- month_end_date
      last_day(l_mon_month_start_date),
      -- month_time_span
      last_day(l_mon_month_start_date)-l_mon_month_start_date + 1,
      -- instance
      l_instance,
      'READY');

     insert into edw_time_day_lstg
     (day_pk,
      name,
      half_month_fk,
      week_fk,
      start_date,
      end_date,
      timespan,
      instance,
      collection_status)
     values(
      -- day_pk
      to_char(l_mon_month_start_date, 'dd-mm-yyyy')||'-MON',
      -- name
      to_char(l_mon_month_start_date, 'fmMonth yyyy'),
      -- half_month fk
      to_char(l_mon_month_start_date, 'dd-mm-yyyy')||'-MON',
      -- week_fk
      'NA_EDW',
      -- month_start_date
      l_mon_month_start_date,
      -- month_end_date
      last_day(l_mon_month_start_date),
      -- month_time_span
      last_day(l_mon_month_start_date)-l_mon_month_start_date + 1,
      -- instance
      l_instance,
      'READY');

     insert into edw_time_cal_day_lstg
     (cal_day_pk,
      name,
      fa_period_fk,
	  pa_period_fk,
	  day_fk,
      cal_period_fk,
      ep_cal_period_fk,
      calendar_date,
      end_date,
      timespan,
      instance,
      collection_status)
     values(
      -- calendar_day_pk
      to_char(l_mon_month_start_date, 'dd-mm-yyyy')||'-MNTH',
      -- name ( Added the level prefix name in the begin as per the standard #1964070)
      'DAY-'||to_char(l_mon_month_start_date, 'fmMonth yyyy'),
      -- fa_period_fk
      'NA_EDW',
      -- pa_period_fk,
	  'NA_EDW',
      -- day_fk,
      to_char(l_mon_month_start_date, 'dd-mm-yyyy')||'-MON',
      -- cal_period_fk
      'NA_EDW',
      -- ep_cal_period_fk
      'oracle_source',
      -- month_start_date
      l_mon_month_start_date,
      -- month_end_date
      last_day(l_mon_month_start_date),
      -- month_time_span
      last_day(l_mon_month_start_date)-l_mon_month_start_date + 1,
      -- instance
      l_instance,
      'READY');

     l_mon_month_start_date:=last_day(l_mon_month_start_date)+1;
     l_row_cday:=l_row_cday+1;
     l_row_day:=l_row_day+1;
     l_row_mth:=l_row_mth+1;
     l_row_hmth:=l_row_hmth+1;

     if l_mon_month_start_date >l_mon_end_date then
		exit;
	 end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing Quarter */
   begin
   edw_log.put_line('Pushing Quarter');
   fii_util.start_timer;
   l_quarter:=fnd_message.get_string('FII', 'FII_AR_QUARTER');
   loop
     insert into edw_time_qtr_lstg
     (qtr_pk,
      half_year_fk,
      qtr,
      name,
      start_date,
      end_date,
      timespan,
      instance,
      collection_status)
     values(
      -- qtr_pk
      to_char(l_start_date_quarter, 'dd-mm-yyyy'),
      -- half_year_fk
      decode(to_char(l_start_date_quarter, 'Q'),1, to_char(trunc(l_start_date_quarter, 'YYYY'), 'dd-mm-yyyy'), 2, to_char(trunc(l_start_date_quarter, 'YYYY'), 'dd-mm-yyyy'), to_char(add_months(trunc(l_start_date_quarter, 'YYYY'),6), 'dd-mm-yyyy')),
      -- qtr
      l_quarter||' '||to_char(l_start_date_quarter,'Q, yyyy'),
      -- name
      l_quarter||' '||to_char(l_start_date_quarter,'Q, yyyy'),
      -- start_date
      l_start_date_quarter,
      -- end_date
      add_months(l_start_date_quarter, 3)-1,
      -- time_span
      add_months(l_start_date_quarter, 3) - 1 - l_start_date_quarter + 1,
      -- instance
      l_instance,
      'READY');

     l_start_date_quarter:=add_months(l_start_date_quarter, 3);
     l_row_qtr:=l_row_qtr+1;
     if l_start_date_quarter>l_end_date_quarter then
        exit;
     end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing Half Year */
   begin
   edw_log.put_line('Pushing Half Year');
   fii_util.start_timer;
   l_first_half:=fnd_message.get_string('FII', 'FII_AR_FIRST_HALF');
   l_second_half:=fnd_message.get_string('FII', 'FII_AR_SECOND_HALF');
   loop
     insert into edw_time_half_year_lstg
     (half_year_pk,
      year_fk,
      half_year,
      name,
      start_date,
      end_date,
      timespan,
      instance,
      collection_status)
     values(
      -- half_year_pk
      to_char(l_half_year_start_date, 'dd-mm-yyyy'),
      -- year_fk
      to_char(trunc(l_half_year_start_date, 'YYYY'), 'dd-mm-yyyy'),
      -- half_year
      decode(l_half_year_counter,0,l_first_half||' '||to_char(l_half_year_start_date, 'YYYY'),1, l_second_half||' '||to_char(l_half_year_start_date, 'YYYY')),
      -- name
      decode(l_half_year_counter,0,l_first_half||', '||to_char(l_half_year_start_date, 'YYYY'),1, l_second_half||', '||to_char(l_half_year_start_date, 'YYYY')),
      -- start_date
      l_half_year_start_date,
      -- end_date
      add_months(l_half_year_start_date, 6)-1,
      -- time_span
      add_months(l_half_year_start_date, 6) -1 - l_half_year_start_date + 1,
      -- instance
      l_instance,
      'READY');

      l_half_year_start_date:=add_months(l_half_year_start_date, 6);
      l_row_hyr:=l_row_hyr+1;

      if l_half_year_start_date>l_half_year_end_date then
         exit;
      end if;

      if l_half_year_counter = 0 then
         l_half_year_counter := 1;
      else
         l_half_year_counter := 0;
      end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing Year */
   begin
   edw_log.put_line('Pushing Year');
   fii_util.start_timer;
   loop
	 insert into edw_time_year_lstg
     (year_pk,
	  all_fk,
	  year,
	  name,
	  start_date,
	  end_date,
	  timespan,
      instance,
	  collection_status)
	 values(
	  -- year_pk
	  to_char(l_year_year_start_date, 'dd-mm-yyyy'),
	  -- all_fk
	  'ALL',
	  -- year
	  to_char(l_year_year_start_date,'YYYY'),
	  -- name
	  to_char(l_year_year_start_date,'YYYY'),
	  -- year_start_date
	  l_year_year_start_date,
	  -- year_end_date
      last_day(l_year_year_start_date+360),
      -- year_time_span
	  last_day(l_year_year_start_date+360)-l_year_year_start_date + 1,
      -- instance
      l_instance,
      'READY');

     l_year_year_start_date:=last_day(l_year_year_start_date+360)+1;
     l_row_year:=l_row_year+1;

	 if l_year_year_start_date>l_year_end_date then
	    exit;
	 end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing Week */
   begin
   edw_log.put_line('Pushing Week');
   fii_util.start_timer;
   l_week:=fnd_message.get_string('FII', 'FII_AR_WEEK');
   loop
     insert into edw_time_week_lstg
     (week_pk,
      name,
	  period_445_fk,
	  week_number,
	  start_date,
	  end_date,
	  timespan,
      instance,
	  collection_status)
	 values(
	  -- week_pk
	  to_char(l_weeks_week_start_date,'dd-mm-yyyy'),
	  -- name
      l_week||' '||to_char(l_weeks_counter)||', '||l_weeks_year,
	  -- period_445_fk
	  to_char(l_weeks_445_date, 'dd-mm-yyyy'),
	  -- week number
	  to_char(l_weeks_counter),
	  -- week_start_date
	  l_weeks_week_start_date,
	  -- week_end_date
	  l_weeks_week_start_date+6,
	  -- week_time_span
	  7,
      -- instance
      l_instance,
      'READY');

     l_weeks_week_start_date:=l_weeks_week_start_date+7;
     l_weeks_year := to_char(l_weeks_week_start_date,'iyyy');
     l_weeks_counter := to_char(l_weeks_week_start_date,'iw');
     l_row_week:=l_row_week+1;

     if l_weeks_counter=1 or l_weeks_counter=5 or l_weeks_counter=9 or l_weeks_counter=14 or l_weeks_counter=18
     or l_weeks_counter=22 or l_weeks_counter=27 or l_weeks_counter = 31 or l_weeks_counter=35 or l_weeks_counter=40
     or l_weeks_counter=44 or l_weeks_counter=48 then
        l_weeks_445_date := l_weeks_week_start_date;
     end if;

     if l_weeks_week_start_date >l_weeks_end_date then
		exit;
	 end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing 445 Period */
   begin
   edw_log.put_line('Pushing 445 Period');
   fii_util.start_timer;
   l_period:=fnd_message.get_string('FII', 'FII_AR_PERIOD');
   loop
     INSERT INTO edw_time_period_445_lstg
     (period_445_pk,
      name,
      all_fk,
      period445_number,
      start_date,
      end_date,
      timespan,
      instance,
      collection_status)
     VALUES(
      to_char(l_445_445_start_date, 'dd-mm-yyyy'),
      l_period||' '||to_char(l_counter)||', '||to_char(l_445_445_start_date,'iyyy'),
      'ALL',
      l_counter,
      l_445_445_start_date,
      l_445_445_end_date,
      l_445_445_end_date-l_445_445_start_date + 1,
      l_instance,
      'READY');

     l_row_445:=l_row_445+1;

     /* if there is week 53, it will roll up to period 12 and the end date need to be extended to 1 week more */
     if to_char((l_445_445_end_date + 1), 'iw')=53 then
        l_445_445_end_date:=l_445_445_end_date+7;
     end if;

     l_445_445_start_date:=l_445_445_end_date+1;

     if l_counter <12 then
        l_counter:=l_counter+1;
     else
        l_counter:=1;
     end if;

     if l_counter=3 or l_counter=6 or l_counter=9 or l_counter=12 then
        l_445_445_end_date:=l_445_445_start_date+7*5-1;
     else
        l_445_445_end_date:=l_445_445_start_date+7*4-1;
     end if;

     if l_445_445_start_date > l_weeks_end_date then
		exit;
	 end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

   /* Pushing Half Month */
   begin
   edw_log.put_line('Pushing Half Month');
   fii_util.start_timer;
   l_first_half:=fnd_message.get_string('FII', 'FII_AR_FIRST_HALF');
   l_second_half:=fnd_message.get_string('FII', 'FII_AR_SECOND_HALF');
   loop
	 insert into edw_time_half_month_lstg
     (half_month_pk,
	  month_fk,
	  half_month,
      name,
	  start_date,
	  end_date,
	  timespan,
      instance,
	  collection_status)
	 values(
	  -- half_month_pk
	  to_char(l_hm_running_date,'dd-mm-yyyy'),
	  -- month_fk
	  to_char(trunc(l_hm_running_date,'mm'),'dd-mm-yyyy'),
	  -- half_month
	  decode(l_hm_counter,0,l_first_half||' '||to_char(l_hm_running_date,'MM-YYYY'),1,l_second_half||' '||to_char(l_hm_running_date,'MM-YYYY')),
	  -- name
      decode(l_hm_counter,0,l_first_half||', '||to_char(l_hm_running_date,'fmMonth YYYY'),1,l_second_half||', '||to_char(l_hm_running_date,'fmMonth YYYY')),
	  -- half month start date
	  l_hm_running_date,
	  -- half_month_end_date
	  decode(l_hm_counter,0,l_hm_running_date+14,last_day(l_hm_running_date)),
	  -- half_month_time_span
	  decode(l_hm_counter,0,l_hm_running_date+14,last_day(l_hm_running_date)) - l_hm_running_date + 1,
      -- instance
      l_instance,
      'READY');

/* Half Month level push down */
/*
	    insert into edw_time_day_lstg
	    (
            day_pk,
            half_month_fk,
	    week_fk,
            day,
            name,
            start_date,
            end_date,
            timespan,
            collection_status)
            values(
                -- day_pk
            to_char(l_hm_running_date,'dd-mm-yyyy')||'-HMON',
                --half_month_fk
	    to_char(l_hm_running_date,'dd-mm-yyyy'),
	    	--week fk
	    'NA_EDW',
                -- day
            decode(l_hm_counter,0,'FIRST HALF '||to_char(l_hm_running_date,'MM-YYYY'),1,'SECOND HALF '||to_char(l_hm_running_date,'MM-YYYY')),
                -- name
            decode(l_hm_counter,0,'FIRST HALF '||to_char(l_hm_running_date,'MM-YYYY'),1,'SECOND HALF '||to_char(l_hm_running_date,'MM-YYYY')),
                -- half month start date
            l_hm_running_date,
                -- half_month_end_date
            decode(l_hm_counter,0,l_hm_running_date+14,last_day(l_hm_running_date)),
                -- half_month_time_span
            decode(l_hm_counter,0,l_hm_running_date+14,last_day(l_hm_running_date)) -
					l_hm_running_date,
             'READY');*/

     l_row_hmth:=l_row_hmth+1;
     if l_hm_counter=0 then
		l_hm_running_date:=l_hm_running_date+15;
	 else
		l_hm_running_date:=last_day(l_hm_running_date)+1;
	 end if;

     if l_hm_running_date >l_hm_end_date then
		exit;
	 end if;

     if l_hm_counter=0 then
		l_hm_counter:=1;
	 else
	    l_hm_counter:=0;
     end if;
   end loop;
   commit;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');
   edw_log.put_line(' ');
   end;

/* for Status Viewer to verify the pushed record number */
rows_inserted:=l_row_cday;

edw_log.put_line(' ');
edw_log.put_line(to_char(l_row_cday)||' records has been pushed to Calendar Day');
edw_log.put_line(to_char(l_row_day)||' records has been pushed to Day');
edw_log.put_line(to_char(l_row_hmth)||' records has been pushed to Half Month');
edw_log.put_line(to_char(l_row_mth)||' records has been pushed to Month');
edw_log.put_line(to_char(l_row_qtr)||' records has been pushed to Quarter');
edw_log.put_line(to_char(l_row_hyr)||' records has been pushed to Half Year');
edw_log.put_line(to_char(l_row_year)||' records has been pushed to Year');
edw_log.put_line(to_char(l_row_week)||' records has been pushed to Week');
edw_log.put_line(to_char(l_row_445)||' records has been pushed to Period 445');
edw_log.put_line(' ');
end;

END FII_POPULATE_TIME;

/

--------------------------------------------------------
--  DDL for Package Body FII_TIME_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_M_C" AS
/* $Header: FIICMCAB.pls 120.3 2004/11/22 17:44:03 phu ship $ */

c_from_date           Date:=Null;
c_to_date             Date:=Null;
g_rows_inserted       Number:=0;

Procedure Push(Errbuf       out NOCOPY  Varchar2,
               Retcode      out NOCOPY  Varchar2,
               p_from_date  IN   Varchar2,
               p_to_date    IN   Varchar2) IS

l_dimension_name   Varchar2(30):='EDW_TIME_M';
l_temp_date        Date:=Null;
l_duration         Number:=0;
l_exception_msg    Varchar2(2000):=Null;
l_from_date        Date:=Null;
l_to_date          Date:=Null;
rows_inserted      number:=0;

Begin
   Errbuf :=NULL;
   Retcode:=0;
   l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

   IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
     errbuf := fnd_message.get;

/*  Added by S.Bhattal, 21-NOV-01  */
     RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);

     Return;
   END IF;

   FII_TIME_M_C.g_push_date_range1 := nvl(l_from_date,EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);

   FII_TIME_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

   edw_log.put_line(' ');
   edw_log.put_line('Pushing GL calendar and Enterprise calendar');

   edw_log.put_line( 'The collection range is from '||
     to_char(FII_TIME_M_C.g_push_date_range1,'dd-MON-yyyy')||' to '||
     to_char(FII_TIME_M_C.g_push_date_range2,'dd-MON-yyyy'));

-- -----------------------------------------------------------------------------
-- Start to push data into staging table
-- -----------------------------------------------------------------------------

   /* Push GL calendar and Enterprise calendar*/

   edw_log.put_line(' ');
   l_temp_date := sysdate;

   Push_gl_and_ent_calendar(FII_TIME_M_C.g_push_date_range1, FII_TIME_M_C.g_push_date_range2);

   l_duration := sysdate - l_temp_date;
   edw_log.put_line('GL calendar and Enterprise calendar has been pushed successfully!');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line('-------------------------------------------------------------------------');
   edw_log.put_line(' ');

   /* Push Gregorian calendar */

   edw_log.put_line('Pushing Gregorian calendar');
   l_temp_date :=sysdate;

   FII_POPULATE_TIME.Push(errbuf,retcode,rows_inserted,c_from_date,c_to_date);

   l_duration := sysdate - l_temp_date;
   edw_log.put_line('Gregorian calendar has been pushed successfully!');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));

   g_rows_inserted:=g_rows_inserted+rows_inserted;

   EDW_COLLECTION_UTIL.wrapup(TRUE, g_rows_inserted, null,
	FII_TIME_M_C.g_push_date_range1, FII_TIME_M_C.g_push_date_range2);

   commit;

   Exception When others then

     Errbuf:=sqlerrm;
     Retcode:=sqlcode;
     l_exception_msg  := Retcode || ':' || Errbuf;
     FII_TIME_M_C.g_exception_msg  := l_exception_msg;
     rollback;

     EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_TIME_M_C.g_exception_msg,
	FII_TIME_M_C.g_push_date_range1, FII_TIME_M_C.g_push_date_range2);

END Push;


-- -----------------------------------------------------------------------------
-- Procedure to push GL calendar and Enterprise calendar
-- -----------------------------------------------------------------------------

PROCEDURE push_gl_and_ent_calendar(
          p_from_date IN Date,
          p_to_date   IN Date) is

-- -----------------------------------------------------------------------------
-- Define variable
-- -----------------------------------------------------------------------------
l_period_set_name	    Varchar2(15);
l_gl_start_date	    Date;
l_gl_end_date	    Date;
l_start_date	    Date;
l_end_date		    Date;
l_instance		    Varchar2(40);
l_gl_date		    Date;
l_period_year         number(15);  --Bug 4006773: changed from NUMBER(4)
l_quarter             number(15);  --Bug 4006773: changed from NUMBER(4)
l_pa_period_name	    Varchar2(30);
l_period_name   	    Varchar2(30);
l_period_type	    Varchar2(30);
l_pa_period_fk        varchar2(120);
l_gl_period_fk        varchar2(120);
l_master_instance     VARCHAR2(30);
l_row_cday            number:=0;
l_row_cal             number:=0;
l_row_pa              number:=0;
l_row_qtr             number:=0;
l_row_year            number:=0;
l_row_name            number:=0;
l_row_ep_cal_period   NUMBER := 0;
l_row_ep_cal_qtr      NUMBER := 0;
l_row_ep_cal_year     NUMBER := 0;
l_row_ep_cal_name     NUMBER := 0;
l_quarter_name        varchar2(20);
e_start_date         date;
e_end_date           date;
l_effective_period_num		number;

-- -----------------------------------------------------------------------------
-- Define cursor
-- -----------------------------------------------------------------------------

/* Cursor to fetch GL calendar days */

Cursor gl_date_cursor is
  Select per.period_set_name,
         per.period_type,
         min(start_date),
         max(end_date)
  From   gl_periods 		per,
         gl_sets_of_books 	book
  where per.ADJUSTMENT_PERIOD_FLAG 	= 'N'
  and per.period_set_name 		= book.period_set_name
  and per.period_type 			= book.accounted_period_type
  and per.end_date 			>= NVL(p_from_date, per.end_date)
  and per.start_date 			<= NVL(p_to_date, per.start_date)
  Group By per.period_set_name,
           per.period_type;

/* Cursor to fetch future GL calendar days */
Cursor gl_future_date_cursor is
  Select per.period_set_name,
         per.period_type,
         min(start_date),
         max(end_date)
  From   gl_periods 		per,
         gl_sets_of_books 	book
  where
  per.period_set_name 		= book.period_set_name
  and per.period_type 		= book.accounted_period_type
  Group By per.period_set_name,
           per.period_type;

/* Cursor to fetch PA calendar days */

Cursor pa_date_cursor is
  select distinct sob.period_set_name,
         paprd.period_name,
         imp.pa_period_type,
         map.accounting_date,
         paprd.start_date,
         paprd.end_date,
         paprd.gl_period_name,
	 (glprd.period_year * 10000) + glprd.period_num
  from 	gl_date_period_map 		map,
       	pa_implementations_all 		imp,
       	gl_sets_of_books 		sob,
       	pa_periods_all 			paprd,
	gl_periods			glprd
  where imp.set_of_books_id	= sob.set_of_books_id
  and paprd.org_id		= imp.org_id
  and map.period_type		= imp.pa_period_type
  and map.period_name		= paprd.period_name
  and map.period_set_name	= sob.period_set_name
  and map.accounting_date 	>= NVL(p_from_date, map.accounting_date)
  and map.accounting_date 	<= NVL(p_to_date, map.accounting_date)
  and map.period_name 		<> 'NOT ASSIGNED'
  and map.period_set_name	= glprd.period_set_name
  and map.period_name		= glprd.period_name;

/* Cursor to fetch PA periods */

Cursor pa_period_cursor is
  select distinct sob.period_set_name,
         paprd.period_name,
         paprd.start_date,
         paprd.end_date,
         paprd.gl_period_name,
	 imp.pa_period_type,
	 (glprd.period_year * 10000) + glprd.period_num
  from 	pa_implementations_all 		imp,
       	gl_sets_of_books 		sob,
       	pa_periods_all 			paprd,
	gl_periods			glprd
  where imp.set_of_books_id	= sob.set_of_books_id
  and paprd.org_id		= imp.org_id
  and paprd.end_date 		>= NVL(p_from_date, paprd.end_date)
  and paprd.start_date 		<= NVL(p_to_date, paprd.start_date)
  and paprd.period_name 	<> 'NOT ASSIGNED'
  and paprd.period_name		= glprd.period_name
  and sob.period_set_name	= glprd.period_set_name;

/* Cursor to fetch GL periods */

Cursor cal_period_cursor is
  select distinct
         per.period_set_name,
         per.period_type,
         per.period_name,
         per.period_year,
         per.quarter_num,
         per.start_date,
         per.end_date,
	 (per.period_year * 10000) + per.period_num
  from gl_periods 		per,
       gl_sets_of_books 	book
  where per.adjustment_period_flag 	= 'N'
  and per.period_set_name 		= book.period_set_name
  and per.period_type 			= book.accounted_period_type;

/* Cursor to fetch quarters */

Cursor gl_quarters  is
  Select per.period_set_name,
         per.period_type,
         per.period_year,
         per.quarter_num,
         min(per.start_date),
         max(per.end_date)
  from gl_periods 		per,
       gl_sets_of_books 	book
  where per.period_set_name 	= book.period_set_name
  and per.period_type 		= book.accounted_period_type
  group by per.period_set_name,
           per.period_type,
           per.period_year,
           per.quarter_num;

/* Cursor to fetch years */

Cursor gl_years  is
  Select per.period_set_name,
         period_type,
         period_year,
         min(start_date),
         max(end_date)
  from gl_periods 		per,
       gl_sets_of_books 	book
  where per.period_set_name 	= book.period_set_name
  and per.period_type 		= book.accounted_period_type
  group by per.period_set_name,
           per.period_type,
           per.period_year;

BEGIN

  c_from_date:=p_from_date;
  c_to_date:=p_to_date;

  e_start_date :=p_from_date;
  e_end_date :=p_to_date;

  l_instance := edw_instance.get_code;

  select instance_code
  into   l_master_instance
  from   edw_local_system_parameters;

-- -----------------------------------------------------------------------------
-- Clear the staging table before pushing data
-- -----------------------------------------------------------------------------
  edw_log.put_line('Purging the existing staging tables');

  delete edw_time_cal_period_lstg
  where instance = l_instance;

  delete edw_time_pa_period_lstg
  where instance = l_instance;

  delete edw_time_cal_qtr_lstg
  where instance = l_instance;

  delete edw_time_cal_year_lstg
  where instance = l_instance;

  delete edw_time_cal_name_lstg
  where instance = l_instance;

  commit;

  delete edw_time_cal_day_lstg
  where instance = l_instance;

  commit;

-- ------------------------------------------------------
-- Only purge Enterprise Calendar only from master source
-- ------------------------------------------------------

  IF (l_instance = l_master_instance) then

    delete edw_time_ep_cal_period_lstg
    where instance = l_instance;

    delete edw_time_ep_cal_qtr_lstg
    where instance = l_instance;

    delete edw_time_ep_cal_year_lstg
    where instance = l_instance;

    delete edw_time_ep_cal_name_lstg
    where instance = l_instance;

    commit;
  END IF;

  edw_log.put_line('Purge completed');
  edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Pushing GL calendar
-- Note: 'oracle_source' is populated in enterprise foreign key in order for
-- pre collection hook to differentiate between oracle source and other source
-- -----------------------------------------------------------------------------
  edw_log.put_line('Pushing GL calendar');
  edw_log.put_line('===================');

  -- --------------------------------------------------------------
  -- Populating different parts into calendar day level
  -- --------------------------------------------------------------

  /* Population of GL Calendar Day */

  edw_log.put_line('Pushing Calendar Day');
  fii_util.start_timer;

  OPEN gl_date_cursor;

  LOOP

    FETCH gl_date_cursor
    INTO  l_period_set_name,
          l_period_type,
          l_gl_start_date,
          l_gl_end_date;

    EXIT WHEN gl_date_cursor%NOTFOUND;

    l_gl_date := l_gl_start_date;
    l_start_date := to_date('01/02/1950', 'DD/MM/YYYY');
    l_end_date := to_date('01/01/1950', 'DD/MM/YYYY');


    WHILE (l_gl_date <= l_gl_end_date)
    LOOP

      if (l_start_date <= l_gl_date and l_end_date >= l_gl_date) then
        null;
      else

        /* Get period details */

        begin
          Select period_name,
                 start_date,
                 end_date,
		 (period_year * 10000) + period_num
          into l_period_name,
               l_start_date,
               l_end_date,
	       l_effective_period_num
          from gl_periods
          where period_set_name 	= l_period_set_name
          and period_type 		= l_period_type
          and start_date 		<= l_gl_date
          and end_date   		>= l_gl_date
          and adjustment_period_flag 	= 'N';

        exception when no_data_found then
          /* This can happen if there are gaps/holes in gl_periods */
          l_period_name := 'NA_EDW';
        end;

      end if;

      if l_period_name = 'NA_EDW'
      then
        l_gl_period_fk := 'NA_EDW';
        l_pa_period_fk := 'NA_EDW';
      else
        l_gl_period_fk := l_period_set_name||'-'||l_period_name ||'-' ||l_instance;
        l_pa_period_fk := l_period_set_name||'-'||l_period_name ||'-' ||l_instance ||'-GL';
      end if;

      Insert into EDW_TIME_CAL_DAY_LSTG
	(
                 CAL_DAY_PK,
                 FA_PERIOD_FK,
                 PA_PERIOD_FK,
                 DAY_FK,
                 CAL_PERIOD_FK,
                 HOLIDAY_FLAG,
                 INSTANCE,
                 NAME,
                 WORK_DAY_FLAG,
                 CALENDAR_DATE,
                 END_DATE,
                 TIMESPAN,
                 SEQ_NUMBER,
                 COLLECTION_STATUS,
                 EP_CAL_PERIOD_FK,
		EFFECTIVE_PERIOD_NUM,
		PERIOD_SET_NAME,
		PERIOD_TYPE
	)
      values(
	to_char(l_gl_date,'dd-mm-yyyy') ||'-'||
           l_period_set_name ||'-'||
           l_period_type ||'-'||
           l_instance|| '-CD',                                   --cal_day_pk
        'NA_EDW',                                             --fa_period_fk
        l_pa_period_fk,                                       --pa_period_fk
        to_char(l_gl_date,'dd-mm-yyyy'),                      --day_fk
        l_gl_period_fk,                                       --cal_period_fk
        null,                                                 --holiday_flag
        l_instance,                                           --instance
        to_char(l_gl_date,'fmdd Month yyyy')||' ('||l_period_set_name||')',    --name
        null,
        l_gl_date,
        l_gl_date,
        1,
        null,
        'READY',
        'oracle_source',
	l_effective_period_num,
	l_period_set_name,
	l_period_type
	);

      l_gl_date := l_gl_date + 1;
      l_row_cday := l_row_cday + 1;

    END LOOP;

    if l_gl_start_date < c_from_date then
       c_from_date:=l_gl_start_date;
    end if;

    if l_gl_end_date > c_to_date then
       c_to_date:=l_gl_end_date;
    end if;

    commit;

  END LOOP;

  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE gl_date_cursor;



  edw_log.put_line('Pushing Future Calendar Days');

  fii_util.start_timer;


  OPEN gl_future_date_cursor;

  LOOP

    FETCH gl_future_date_cursor
    INTO  l_period_set_name,
          l_period_type,
          l_gl_start_date,
          l_gl_end_date;

    EXIT WHEN gl_future_date_cursor%NOTFOUND;

  e_start_date :=p_from_date;
  e_end_date :=p_to_date;


  IF e_start_date > e_end_date THEN
           NULL;
      ELSIF e_end_date <= l_gl_end_date THEN
           NULL;
      ELSIF e_end_date > l_gl_end_date THEN
          IF e_start_date < l_gl_end_date THEN
                e_start_date :=  l_gl_end_date + 1;
          END IF;


      WHILE  (e_start_date <= e_end_date)
      LOOP
      Insert into EDW_TIME_CAL_DAY_LSTG
        (
                 CAL_DAY_PK,
                 FA_PERIOD_FK,
                 PA_PERIOD_FK,
                 DAY_FK,
                 CAL_PERIOD_FK,
                 HOLIDAY_FLAG,
                 INSTANCE,
                 NAME,
                 WORK_DAY_FLAG,
                 CALENDAR_DATE,
                 END_DATE,
                 TIMESPAN,
                 SEQ_NUMBER,
                 COLLECTION_STATUS,
                 EP_CAL_PERIOD_FK,
                EFFECTIVE_PERIOD_NUM,
                PERIOD_SET_NAME,
                PERIOD_TYPE
        )
      VALUES(
        to_char(e_start_date,'dd-mm-yyyy') ||'-'||
           l_period_set_name ||'-'||
           l_period_type ||'-'||
           l_instance|| '-CD',                                   --cal_day_pk
        'NA_EDW',                                             --fa_period_fk
        'NA_EDW',                                            --pa_period_fk
        to_char(e_start_date,'dd-mm-yyyy'),                      --day_fk
        'NA_EDW',                                       --cal_period_fk
        null,                                                 --holiday_flag
        l_instance,                                           --instance
        to_char(e_start_date,'fmdd Month yyyy')||' ('||l_period_set_name||')',    --name
        null,
        e_start_date,
        e_start_date,
        1,
        null,
        'READY',
        'oracle_source',
        -1,
        l_period_set_name,
        l_period_type
        );

      e_start_date := e_start_date + 1;
      l_row_cday := l_row_cday + 1;

    END LOOP;


    commit;

END IF;


  END LOOP;


  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE gl_future_date_cursor;



/* Population of PA Calendar Day */

  edw_log.put_line('Pushing PA Calendar Day');
  fii_util.start_timer;

  OPEN pa_date_cursor;

  LOOP

    FETCH pa_date_cursor
    INTO  l_period_set_name,
          l_pa_period_name,
          l_period_type,
          l_gl_date,
          l_gl_start_date,
          l_gl_end_date,
          l_period_name,
	  l_effective_period_num;

    EXIT WHEN pa_date_cursor%NOTFOUND;

    Insert into EDW_TIME_CAL_DAY_LSTG
               (CAL_DAY_PK,
                FA_PERIOD_FK,
                PA_PERIOD_FK,
                DAY_FK,
                CAL_PERIOD_FK,
                HOLIDAY_FLAG,
                INSTANCE,
                NAME,
                WORK_DAY_FLAG,
                CALENDAR_DATE,
                END_DATE,
                TIMESPAN,
                SEQ_NUMBER,
                COLLECTION_STATUS,
                EP_CAL_PERIOD_FK,
                EFFECTIVE_PERIOD_NUM,
                PERIOD_SET_NAME,
                PERIOD_TYPE
		)
         values(to_char(l_gl_date,'dd-mm-yyyy')||'-'||
                l_period_set_name||'-'||
                l_period_type||'-'||
                l_instance||'-PD',                              --cal_day_pk
                'NA_EDW',                                       --fa_period_fk
                l_period_set_name||'-'||
                l_pa_period_name||'-'||
                l_instance||'-PA',                              --pa_period_fk
                'NA_EDW',                                       --day_fk
                l_period_set_name||'-'||
                l_period_name||'-'||l_instance,                 --cal_period_fk
                null,                                           --holiday_flag
                l_instance,                                     --instance
                to_char(l_gl_date, 'fmdd Month yyyy')||
                ' ('||l_period_set_name||')',                   --name
                null,                                           --work_day_flag
                l_gl_date,                                      --calendar_date
                l_gl_date,                                      --end_date
                1,                                              --timespan
                null,                                           --seq_number
                'READY',                                    --collection_status
                'oracle_source',                            --ep_cal_period_fk
        	l_effective_period_num,
        	l_period_set_name,
        	l_period_type
		);

    l_row_cday:=l_row_cday+1;

    if l_gl_start_date < c_from_date then
       c_from_date:=l_gl_start_date;
    end if;

    if l_gl_end_date > c_to_date then
       c_to_date:=l_gl_end_date;
    end if;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE pa_date_cursor;


/* Population of PA Period push down */

  edw_log.put_line('Pushing PA Period push down');
  fii_util.start_timer;

  OPEN pa_period_cursor;

  LOOP

    FETCH pa_period_cursor
    INTO  l_period_set_name,
          l_pa_period_name,
          l_gl_start_date,
          l_gl_end_date,
          l_period_name,
	  l_period_type,
	  l_effective_period_num;

    EXIT WHEN pa_period_cursor%NOTFOUND;

    Insert into EDW_TIME_CAL_DAY_LSTG
               (CAL_DAY_PK,
                FA_PERIOD_FK,
                PA_PERIOD_FK,
                DAY_FK,
                CAL_PERIOD_FK,
                EP_CAL_PERIOD_FK,
                HOLIDAY_FLAG,
                INSTANCE,
                NAME,
                WORK_DAY_FLAG,
                CALENDAR_DATE,
                END_DATE,
                TIMESPAN,
                SEQ_NUMBER,
                COLLECTION_STATUS,
                EFFECTIVE_PERIOD_NUM,
                PERIOD_SET_NAME,
                PERIOD_TYPE
		)
         values(l_period_set_name||'-'||
                l_pa_period_name||'-'||
                l_instance||'-PPER',                            --cal_day_pk
                'NA_EDW',
                l_period_set_name||'-'||
                l_pa_period_name||'-'||
                l_instance||'-PA',                              --pa_period_fk
                to_char(l_gl_start_date,'dd-mm-yyyy'),          --day_fk
                l_period_set_name||'-'||
                l_period_name||'-'||l_instance,                 --cal_period_fk
                'oracle_source',                                --ep_cal_period_fk
                '',
                l_instance,
                l_pa_period_name||' ('||l_period_set_name||')', --name
                '',
                l_gl_start_date,
                l_gl_end_date,
                l_gl_end_date - l_gl_start_date + 1,
                '',
                'READY',
        	l_effective_period_num,
        	l_period_set_name,
        	l_period_type
		);

    l_row_cday:=l_row_cday+1;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE pa_period_cursor;


/* Population of GL Period push down*/

  edw_log.put_line('Pushing GL Period push down to Calendar Day');
  fii_util.start_timer;

  OPEN cal_period_cursor;

  LOOP

    FETCH cal_period_cursor
    INTO  l_period_set_name,
          l_period_type,
          l_period_name,
          l_period_year,
          l_quarter,
          l_start_date,
          l_end_date,
	  l_effective_period_num;

    EXIT WHEN cal_period_cursor%NOTFOUND;

    Insert into EDW_TIME_CAL_DAY_LSTG
             (CAL_DAY_PK,
              FA_PERIOD_FK,
              PA_PERIOD_FK,
              DAY_FK,
              CAL_PERIOD_FK,
              EP_CAL_PERIOD_FK,
              HOLIDAY_FLAG,
              INSTANCE,
              NAME,
              WORK_DAY_FLAG ,
              CALENDAR_DATE,
              END_DATE,
              TIMESPAN,
              SEQ_NUMBER,
              COLLECTION_STATUS,
                EFFECTIVE_PERIOD_NUM,
                PERIOD_SET_NAME,
                PERIOD_TYPE
		)
     Values (
         l_period_set_name||'-'||l_period_name||'-'||l_instance||'-CPER',     -- CAL_DAY_PK
         'NA_EDW',                                                            -- FA_PERIOD_FK
         l_period_set_name||'-'||l_period_name||'-'||l_instance||'-GL',       -- PA_PERIOD_FK
         'NA_EDW',                                                            -- DAY_FK
         l_period_set_name||'-'||l_period_name||'-'||l_instance,              -- CAL_PERIOD_FK
         'oracle_source',                                                     -- EP_CAL_PERIOD_FK
         '',
         l_instance,
         l_period_name||' ('||l_period_set_name||')',                         --name
         '',                                                                  --work_day_flag
         l_start_date,                                                        --calendar_date
         l_end_date,                                                          --end_date
         l_end_date - l_start_date + 1,                                       --timespan
         1,                                                                   --seq_number
         'READY',                                                             --collection_status
        l_effective_period_num,
        l_period_set_name,
        l_period_type
	);

    l_row_cday:=l_row_cday+1;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE cal_period_cursor;


  -- --------------------------------------------------
  -- Populating different parts into PA Period Level
  -- --------------------------------------------------

  /* Population of PA Period */

  edw_log.put_line('Pushing PA Period');
  fii_util.start_timer;

  OPEN pa_period_cursor;

  LOOP
    FETCH pa_period_cursor
    INTO  l_period_set_name,
          l_pa_period_name,
          l_gl_start_date,
          l_gl_end_date,
          l_period_name,
	  l_period_type,
	  l_effective_period_num;

    EXIT WHEN pa_period_cursor%NOTFOUND;

    Insert into EDW_TIME_PA_PERIOD_LSTG
               (PA_PERIOD_PK,
                CAL_PERIOD_FK,
                INSTANCE,
                PA_PERIOD,
                NAME,
                END_DATE,
                START_DATE,
                TIMESPAN,
                COLLECTION_STATUS )
         values(l_period_set_name||'-'||
                l_pa_period_name||'-'||l_instance||'-PA',       --pa_period_pk
                l_period_set_name||'-'||
                l_period_name||'-'||l_instance,                 --cal_period_fk
                l_instance,                                     --instance
                l_pa_period_name,                               --pa_period
                l_pa_period_name||' ('||l_period_set_name||')', --name
                l_gl_end_date,                                  --end_date
                l_gl_start_date,                                --start_date
                l_gl_end_date - l_gl_start_date + 1,            --timespan
                'READY');                                       --collection_status

    l_row_pa:=l_row_pa+1;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE pa_period_cursor;


  /* Population of GL Period pushed down to PA period level*/

  edw_log.put_line('Pushing GL Period push down to PA Period');
  fii_util.start_timer;

  OPEN cal_period_cursor;

  LOOP
    FETCH cal_period_cursor
    INTO  l_period_set_name,
          l_period_type,
          l_period_name,
          l_period_year,
          l_quarter,
          l_start_date,
          l_end_date,
	  l_effective_period_num;

    EXIT WHEN cal_period_cursor%NOTFOUND;

    Insert into EDW_TIME_PA_PERIOD_LSTG
             (PA_PERIOD_PK,
              CAL_PERIOD_FK,
              INSTANCE,
              PA_PERIOD,
              NAME,
              END_DATE,
              START_DATE,
              TIMESPAN,
              COLLECTION_STATUS)
    Values (
         l_period_set_name||'-'||l_period_name||'-'||
            l_instance||'-GL',                                       --pa_period_pk
         l_period_set_name||'-'||l_period_name||'-'||
            l_instance,                                              --cal_period_fk
         l_instance,                                                 --instance
         l_period_name,                                              --pa_period
         l_period_name||' ('||l_period_set_name||')',                --name
         l_end_date,
         l_start_date,
         l_end_date - l_start_date + 1,
         'READY');

    l_row_pa:=l_row_pa+1;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE cal_period_cursor;


  -- --------------------------------------------------
  -- Populating GL Period Level
  -- --------------------------------------------------

  edw_log.put_line('Pushing GL Period');
  fii_util.start_timer;

  OPEN cal_period_cursor;

  LOOP
    FETCH cal_period_cursor
    INTO l_period_set_name,
         l_period_type,
         l_period_name,
         l_period_year,
         l_quarter,
         l_gl_start_date,
         l_gl_end_date,
	 l_effective_period_num;

    EXIT WHEN cal_period_cursor%NOTFOUND;

    insert into edw_time_cal_period_lstg
               (CAL_PERIOD_PK,
                CAL_QTR_FK,
                INSTANCE,
                NAME,
                CAL_PERIOD,
                PERIOD_NAME,
                END_DATE,
                START_DATE,
                TIMESPAN,
                COLLECTION_STATUS)
         values(l_period_set_name||'-'||l_period_name||'-'||l_instance,     --cal_period_pk
                l_period_set_name||'-'||l_period_type||'-'||l_period_year||
                   '-Q-'||l_quarter||'-'||l_instance,                       --cal_qtr_fk
                l_instance,
                l_period_name||' ('||l_period_set_name ||')',                --name
                l_period_name,
                l_period_name,
                l_gl_end_date,
                l_gl_start_date,
                l_gl_end_date - l_gl_start_date + 1,
                'READY');

    l_row_cal:=l_row_cal+1;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE cal_period_cursor;

  -- --------------------------------------------------
  -- Populating GL Quarter Level
  -- --------------------------------------------------

  edw_log.put_line('Pushing GL Quarter');
  fii_util.start_timer;
  l_quarter_name:=fnd_message.get_string('FII', 'FII_AR_QUARTER');

  OPEN gl_quarters;

  LOOP
   FETCH gl_quarters
   INTO  l_period_set_name,
         l_period_type,
         l_period_year,
         l_quarter,
         l_start_date,
         l_end_date;

   EXIT WHEN gl_quarters%NOTFOUND;

   insert into EDW_TIME_CAL_QTR_LSTG
              (CAL_QTR_PK ,
               CAL_YEAR_FK  ,
               CAL_QTR,
               INSTANCE,
               NAME ,
               END_DATE,
               START_DATE,
               TIMESPAN,
               COLLECTION_STATUS )
   values
   (l_period_set_name||'-'||l_period_type||'-'||
      l_period_year||'-Q-'||l_quarter||'-'||l_instance,      --CAL_QTR_PK
    l_period_set_name||'-'||l_period_type||'-'||
      l_period_year||'-'||l_instance,                        --CAL_YEAR_FK
    l_quarter_name||' '||l_quarter||', '||l_period_year||
      ' ('||l_period_set_name||')',                          --CAL_QTR
    l_instance,
    l_quarter_name||' '||l_quarter||', '||l_period_year||
      ' ('||l_period_set_name||')',                          --name
    l_end_date,
    l_start_date,
    l_end_date - l_start_date + 1,
    'READY');

   l_row_qtr := l_row_qtr + 1;

  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE gl_quarters;


  -- --------------------------------------------------
  -- Populating GL Year Level
  -- --------------------------------------------------

  edw_log.put_line('Pushing GL Year');
  fii_util.start_timer;

  OPEN gl_years;

  LOOP
     FETCH gl_years
     INTO  l_period_set_name,
           l_period_type,
           l_period_year,
           l_start_date,
           l_end_date;

     EXIT WHEN gl_years%NOTFOUND;

     insert into  EDW_TIME_CAL_YEAR_LSTG
		(
                     CAL_YEAR_PK ,
                     CAL_NAME_FK  ,
                     CAL_YEAR,
                     INSTANCE,
                     NAME ,
                     END_DATE,
                     START_DATE,
                     TIMESPAN,
                     COLLECTION_STATUS
		)
      values(
         l_period_set_name||'-'||l_period_type||'-'||
            l_period_year||'-'||l_instance,                      -- cal_year_pk
         l_period_set_name||'-'||l_period_type||'-'||l_instance, -- cal_name_fk
         l_period_year,                                          -- cal_year
         l_instance,
         l_period_year||' ('||l_period_set_name||')',            --name
         l_end_date,
         l_start_date,
         l_end_date - l_start_date + 1,
         'READY' );

      l_row_year := l_row_year + 1;
  END LOOP;

  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  CLOSE gl_years;


  -- --------------------------------------------------
  -- Populating GL Calendar Name Level
  -- --------------------------------------------------

  edw_log.put_line('Pushing GL Calendar Name');
  fii_util.start_timer;

      insert into  EDW_TIME_CAL_NAME_LSTG(
                    CAL_NAME_PK ,
                    ALL_FK,
                    CAL_NAME,
                    CALENDAR_TYPE ,
                    DESCRIPTION ,
                    INSTANCE ,
                    NAME  ,
                    end_date ,
                    timespan,
                    COLLECTION_STATUS )
            Select  distinct sob.period_set_name ||'-'||
                    sob.accounted_period_type||'-'||l_instance,     --cal_name_pk
                    'ALL',                                          --all_fk
                    sob.period_set_name,                            --cal_name
                    'Financial',                                    --calendar_type
                    sets.description,                               --description
                    l_instance,                                     --instance
                    sob.period_set_name,                            --name
                    sysdate,                                        --end_date
                    1,                                              --timespan
                    'READY'                                         --collection_status
               from gl_sets_of_books sob,
                    gl_period_sets sets
               where sob.period_set_name = sets.period_set_name;

  l_row_name:=l_row_name+sql%rowcount;
  commit;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Write result to log file
-- -----------------------------------------------------------------------------

  /* for Status Viewer to verify the pushed record number */
  g_rows_inserted:=l_row_cday;

  edw_log.put_line(' ');
  edw_log.put_line(to_char(l_row_cday)||' records has been pushed to Calendar Day');
  edw_log.put_line(to_char(l_row_pa)||' records has been pushed to PA Period');
  edw_log.put_line(to_char(l_row_cal)||' records has been pushed to GL Period');
  edw_log.put_line(to_char(l_row_qtr)||' records has been pushed to GL Quarter');
  edw_log.put_line(to_char(l_row_year)||' records has been pushed to GL Year');
  edw_log.put_line(to_char(l_row_name)||' records has been pushed to Calendar Name');
  edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Pushing Enterprise calendar
-- -----------------------------------------------------------------------------
select period_set_name, period_type, instance_code
into   l_period_set_name, l_period_type, l_master_instance
from edw_local_system_parameters;

/* Enterprise hierarchy will only be populated if this is the master instance*/
if l_master_instance=l_instance then
  edw_log.put_line('Pushing Enterprise calendar');
  edw_log.put_line('===========================');

  /* Population of Enterprise Calendar Period */
  edw_log.put_line('Pushing Enterprise Calendar Period');
  fii_util.start_timer;

  INSERT INTO EDW_TIME_EP_CAL_PERIOD_LSTG
  (CAL_PERIOD_PK,
   CAL_QTR_FK,
   INSTANCE,
   NAME,
   CAL_PERIOD,
   PERIOD_NAME,
   END_DATE,
   START_DATE,
   TIMESPAN,
   COLLECTION_STATUS)
  select period_name,
         to_char(quarter_num)||'-'||to_char(period_year),
         l_instance,
         period_name,
         period_name,
         period_name,
         end_date,
         start_date,
         end_date-start_date+1,
         'READY'
  FROM gl_periods
  where period_set_name = l_period_set_name
  and   period_type = l_period_type
  and   adjustment_period_flag='N';

  l_row_ep_cal_period:=l_row_ep_cal_period+sql%rowcount;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  /* Population of Enterprise Calendar Quarter */

  edw_log.put_line('Pushing Enterprise Calendar Quarter');
  fii_util.start_timer;
  l_quarter_name:=fnd_message.get_string('FII', 'FII_AR_QUARTER');

  INSERT INTO EDW_TIME_EP_CAL_QTR_LSTG
  (CAL_QTR_PK,
   CAL_YEAR_FK,
   CAL_QTR,
   INSTANCE,
   NAME,
   END_DATE,
   START_DATE,
   TIMESPAN,
   COLLECTION_STATUS)
  Select to_char(quarter_num)||'-'||to_char(period_year),                       --CAL_QTR_PK
         to_char(period_year),                                                  --CAL_YEAR_FK
         l_quarter_name||' '||to_char(quarter_num)||', '||to_char(period_year), --CAL_QTR
         l_instance,                                                            --INSTANCE
         l_quarter_name||' '||to_char(quarter_num)||', '||to_char(period_year), --NAME
         max(end_date),                                                         --END_DATE
         min(start_date),                                                       --START_DATE
         max(end_date)-min(start_date)+1,                                       --TIMESPAN
         'READY'                                                                --COLLECTION_STATUS
  FROM gl_periods
  where period_set_name=l_period_set_name
  and period_type = l_period_type
  and adjustment_period_flag='N'
  group by period_year, quarter_num;

  l_row_ep_cal_qtr:=l_row_ep_cal_qtr+sql%rowcount;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  /* Population of Enterprise Calendar Year */

  edw_log.put_line('Pushing Enterprise Calendar Year');
  fii_util.start_timer;

  INSERT INTO EDW_TIME_EP_CAL_YEAR_LSTG
  (CAL_YEAR_PK,
   CAL_NAME_FK,
   CAL_YEAR,
   INSTANCE,
   NAME,
   END_DATE,
   START_DATE,
   TIMESPAN,
   COLLECTION_STATUS)
  Select          to_char(period_year),                                 --CAL_YEAR_PK
                  l_period_set_name,                                    --CAL_NAME_FK
                  to_char(period_year),                                 --CAL_YEAR
                  l_instance,                                           --INSTANCE
                  to_char(period_year),                                 --NAME
                  max(end_date),                                        --END_DATE
                  min(start_date),                                      --START_DATE
                  max(end_date)-min(start_date)+1,                      --TIMESPAN
                  'READY'                                               --COLLECTION_STATUS
  FROM gl_periods
  where period_set_name=l_period_set_name
  and period_type = l_period_type
  and adjustment_period_flag='N'
  group by period_year;

  l_row_ep_cal_year:=l_row_ep_cal_year+sql%rowcount;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

  /* Population of Enterprise Calendar Name */

  edw_log.put_line('Pushing Enterprise Calendar Name');
  fii_util.start_timer;

  INSERT INTO EDW_TIME_EP_CAL_NAME_LSTG
  (CAL_NAME_PK,
   ALL_FK,
   CAL_NAME,
   CALENDAR_TYPE,
   DESCRIPTION,
   INSTANCE,
   NAME,
   end_date,
   timespan,
   COLLECTION_STATUS)
  Select sets.period_set_name,
         'ALL',
         sets.period_set_name,
         'Financial',
         sets.description,
         l_instance,
         sets.period_set_name,
         sysdate,
         1,
         'READY'
  FROM gl_period_sets sets
  WHERE sets.period_set_name = l_period_set_name;

  l_row_ep_cal_name:=l_row_ep_cal_name+sql%rowcount;
  fii_util.stop_timer;
  fii_util.print_timer('Process Time');
  edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Write result to log file
-- -----------------------------------------------------------------------------

  edw_log.put_line(' ');
  edw_log.put_line(to_char(l_row_ep_cal_period)||' records has been pushed to Enterprise Calendar Period');
  edw_log.put_line(to_char(l_row_ep_cal_qtr)||' records has been pushed to Enterprise Calendar Quarter');
  edw_log.put_line(to_char(l_row_ep_cal_year)||' records has been pushed to Enterprise Calendar Year');
  edw_log.put_line(to_char(l_row_ep_cal_name)||' records has been pushed to Enterprise Calendar Name');
  edw_log.put_line(' ');

end if;

  Exception When others then
    raise;

END Push_gl_and_ent_calendar;

END FII_TIME_M_C;

/

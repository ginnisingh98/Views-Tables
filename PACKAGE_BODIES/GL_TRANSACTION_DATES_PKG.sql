--------------------------------------------------------
--  DDL for Package Body GL_TRANSACTION_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TRANSACTION_DATES_PKG" AS
/* $Header: glitcdab.pls 120.2 2005/03/02 20:12:49 kvora ship $ */
--
-- PUBLIC FUNCTIONS
--
PROCEDURE extend_transaction_calendars
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_entered_year	  	VARCHAR2,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			)  IS
  CURSOR check_new_year IS
	SELECT '1' FROM sys.dual
	WHERE EXISTS
		(SELECT 'Existing Year'
		FROM	gl_periods
		WHERE
			    period_set_name = x_period_set_name
			AND end_date BETWEEN
			        TO_DATE(x_entered_year || '/01/01', 'YYYY/MM/DD')
			    AND TO_DATE(x_entered_year || '/12/31', 'YYYY/MM/DD')
		);
        dummy			VARCHAR2(1000);
        new_entered_year	VARCHAR2(30);
  BEGIN
    -- check whether the current record inserts/updates with a new year
    OPEN check_new_year;
    FETCH check_new_year INTO dummy;
    IF (check_new_year%NOTFOUND) THEN
      CLOSE check_new_year;
    ELSE
      -- this is not a new year, exit
      CLOSE check_new_year;
      RETURN;
    END IF;

    -- Lock GL_CONCURRENCY_CONTROL table in the row share mode using
    -- CONCURRENCY_CLASS = EXTEND_TRANSACTION_CALENDAR. This is to
    -- indicate that the GL_TRANSACTION_DATES table is locked for INSERT/UPDATE
    -- but can be used for SELECT.

    SELECT concurrency_class
    INTO   dummy
    FROM  gl_concurrency_control
    WHERE concurrency_class = 'EXTEND_TRANSACTION_CALENDAR'
    FOR UPDATE OF concurrency_class;



    -- Insert records for all transaction calendars into the
    -- GL_TRANSACTION_DATES table:
    new_entered_year := x_entered_year;
    INSERT INTO gl_transaction_dates
       ( TRANSACTION_CALENDAR_ID,
	TRANSACTION_DATE,
	DAY_OF_WEEK,
	BUSINESS_DAY_FLAG,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
       )
       SELECT
	tcal.transaction_calendar_id,
	TO_DATE(new_entered_year || '/01/01', 'YYYY/MM/DD')+ cnt.multiplier-1,
	DECODE
	(
                TO_CHAR(TO_DATE( new_entered_year || '/01/01', 'YYYY/MM/DD')+cnt.multiplier-1,'DY'),
		TO_CHAR(TO_DATE('1996/01/01', 'YYYY/MM/DD'), 'DY'), 'MON',
		TO_CHAR(TO_DATE('1996/01/02', 'YYYY/MM/DD'), 'DY'), 'TUE',
		TO_CHAR(TO_DATE('1996/01/03', 'YYYY/MM/DD'), 'DY'), 'WED',
		TO_CHAR(TO_DATE('1996/01/04', 'YYYY/MM/DD'), 'DY'), 'THU',
		TO_CHAR(TO_DATE('1996/01/05', 'YYYY/MM/DD'), 'DY'), 'FRI',
		TO_CHAR(TO_DATE('1996/01/06', 'YYYY/MM/DD'), 'DY'), 'SAT',
		TO_CHAR(TO_DATE('1996/01/07', 'YYYY/MM/DD'), 'DY'), 'SUN',
		'NONE'
	),
        DECODE
	(
	     	DECODE
		(
			TO_CHAR(TO_DATE( new_entered_year || '/01/01', 'YYYY/MM/DD')
									+ cnt.multiplier-1,'DY'),
                	TO_CHAR(TO_DATE('1996/01/01', 'YYYY/MM/DD'), 'DY'), 'MON',
                	TO_CHAR(TO_DATE('1996/01/02', 'YYYY/MM/DD'), 'DY'), 'TUE',
                	TO_CHAR(TO_DATE('1996/01/03', 'YYYY/MM/DD'), 'DY'), 'WED',
                	TO_CHAR(TO_DATE('1996/01/04', 'YYYY/MM/DD'), 'DY'), 'THU',
                	TO_CHAR(TO_DATE('1996/01/05', 'YYYY/MM/DD'), 'DY'), 'FRI',
                	TO_CHAR(TO_DATE('1996/01/06', 'YYYY/MM/DD'), 'DY'), 'SAT',
                	TO_CHAR(TO_DATE('1996/01/07', 'YYYY/MM/DD'), 'DY'), 'SUN',
                	'NONE'
		),
		'MON', tcal.mon_business_day_flag,
		'TUE', tcal.tue_business_day_flag,
		'WED', tcal.wed_business_day_flag,
		'THU', tcal.thu_business_day_flag,
		'FRI', tcal.fri_business_day_flag,
		'SAT', tcal.sat_business_day_flag,
		'SUN', tcal.sun_business_day_flag,
		'Y'
	),
	x_CREATION_DATE,
	x_CREATED_BY,
	x_LAST_UPDATE_DATE,
	x_LAST_UPDATED_BY,
	x_LAST_UPDATE_LOGIN
       FROM gl_transaction_calendar tcal, gl_row_multipliers cnt
       WHERE
            cnt.multiplier <= TO_DATE(new_entered_year || '/12/31', 'YYYY/MM/DD') -
    	        TO_DATE(new_entered_year || '/01/01', 'YYYY/MM/DD')+1
       AND NOT EXISTS
         (SELECT 'duplicate'
          FROM   gl_transaction_dates tdates
          WHERE  tdates.transaction_date =
                 to_date(new_entered_year || '/01/01',
				'YYYY/MM/DD')+cnt.multiplier-1
                 AND    tdates.transaction_calendar_id =
					tcal.transaction_calendar_id);


  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_periods_pkg.extend_transaction_calendars');
      RAISE;

  END extend_transaction_calendars;

  PROCEDURE insert_all_years_for_calendar
			(
			x_transaction_calendar_id	NUMBER,
			x_CREATION_DATE			DATE,
			x_CREATED_BY			NUMBER,
			x_LAST_UPDATE_DATE		DATE,
			x_LAST_UPDATED_BY		NUMBER,
			x_LAST_UPDATE_LOGIN		NUMBER
			)  IS

        dummy			VARCHAR2(1000);
	earliest_year		NUMBER;
	latest_year		NUMBER;
  BEGIN
    -- get the earliest year
    SELECT TO_NUMBER(TO_CHAR(MIN(start_date), 'YYYY'))
    INTO earliest_year
    FROM gl_periods;

    -- get the latest date
    SELECT TO_NUMBER(TO_CHAR(MAX(end_date), 'YYYY'))
    INTO latest_year
    FROM gl_periods;

    -- Lock GL_CONCURRENCY_CONTROL table in the row share mode using
    -- CONCURRENCY_CLASS = EXTEND_TRANSACTION_CALENDAR. This is to
    -- indicate that the GL_TRANSACTION_DATES table is locked for INSERT/UPDATE but
    -- can be used for SELECT.
    SELECT concurrency_class
    INTO   dummy
    FROM  gl_concurrency_control
    WHERE concurrency_class = 'EXTEND_TRANSACTION_CALENDAR'
    FOR UPDATE OF concurrency_class;

    -- Insert records for all transaction calendars into the
    -- GL_TRANSACTION_DATES table:
   INSERT INTO gl_transaction_dates
       (TRANSACTION_CALENDAR_ID,
	TRANSACTION_DATE,
	DAY_OF_WEEK,
	BUSINESS_DAY_FLAG,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
       )
	SELECT
	x_transaction_calendar_id,
	TO_DATE(TO_CHAR(yr.multiplier+1900) || '/01/01', 'YYYY/MM/DD')+ cnt.multiplier-1,
	DECODE
	(
		TO_CHAR(TO_DATE( TO_CHAR(yr.multiplier+1900) || '/01/01', 'YYYY/MM/DD')
									+ cnt.multiplier-1,'DY'),
		TO_CHAR(TO_DATE('1996/01/01', 'YYYY/MM/DD'), 'DY'), 'MON',
		TO_CHAR(TO_DATE('1996/01/02', 'YYYY/MM/DD'), 'DY'), 'TUE',
		TO_CHAR(TO_DATE('1996/01/03', 'YYYY/MM/DD'), 'DY'), 'WED',
		TO_CHAR(TO_DATE('1996/01/04', 'YYYY/MM/DD'), 'DY'), 'THU',
		TO_CHAR(TO_DATE('1996/01/05', 'YYYY/MM/DD'), 'DY'), 'FRI',
                TO_CHAR(TO_DATE('1996/01/06', 'YYYY/MM/DD'), 'DY'), 'SAT',
                TO_CHAR(TO_DATE('1996/01/07', 'YYYY/MM/DD'), 'DY'), 'SUN',
                'NONE'

	),
        DECODE
	(
	     	DECODE
		(
			TO_CHAR(TO_DATE( TO_CHAR(yr.multiplier+1900) || '/01/01', 'YYYY/MM/DD')
									+ cnt.multiplier-1,'DY'),
                	TO_CHAR(TO_DATE('1996/01/01', 'YYYY/MM/DD'), 'DY'), 'MON',
                	TO_CHAR(TO_DATE('1996/01/02', 'YYYY/MM/DD'), 'DY'), 'TUE',
                	TO_CHAR(TO_DATE('1996/01/03', 'YYYY/MM/DD'), 'DY'), 'WED',
                	TO_CHAR(TO_DATE('1996/01/04', 'YYYY/MM/DD'), 'DY'), 'THU',
                	TO_CHAR(TO_DATE('1996/01/05', 'YYYY/MM/DD'), 'DY'), 'FRI',
                	TO_CHAR(TO_DATE('1996/01/06', 'YYYY/MM/DD'), 'DY'), 'SAT',
                	TO_CHAR(TO_DATE('1996/01/07', 'YYYY/MM/DD'), 'DY'), 'SUN',
                	'NONE'
		),
		'MON', cal.mon_business_day_flag,
		'TUE', cal.tue_business_day_flag,
		'WED', cal.wed_business_day_flag,
		'THU', cal.thu_business_day_flag,
		'FRI', cal.fri_business_day_flag,
		'SAT', cal.sat_business_day_flag,
		'SUN', cal.sun_business_day_flag,
		'Y'
	),
	x_CREATION_DATE,
	x_CREATED_BY,
	x_LAST_UPDATE_DATE,
	x_LAST_UPDATED_BY,
	x_LAST_UPDATE_LOGIN
       FROM  gl_transaction_calendar cal, gl_row_multipliers yr, gl_row_multipliers cnt
       WHERE
            cal.transaction_calendar_id = x_transaction_calendar_id
        AND cnt.multiplier <= TO_DATE(TO_CHAR(yr.multiplier+1900) || '/12/31', 'YYYY/MM/DD') -
    	        TO_DATE(TO_CHAR(yr.multiplier+1900) || '/01/01', 'YYYY/MM/DD')+1
	AND yr.multiplier >= earliest_year-1900
	AND yr.multiplier <= latest_year-1900
       AND NOT EXISTS
         (SELECT 'duplicate'
          FROM   gl_transaction_dates tdates
          WHERE  tdates.transaction_date =
                 to_date(TO_CHAR(yr.multiplier+1900) || '/01/01',
				'YYYY/MM/DD')+cnt.multiplier-1
                 AND    tdates.transaction_calendar_id = x_transaction_calendar_id);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_periods_pkg.insert_all_years_for_calendar');
      RAISE;
  END insert_all_years_for_calendar;


END;

/

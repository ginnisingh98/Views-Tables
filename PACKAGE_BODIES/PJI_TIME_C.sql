--------------------------------------------------------
--  DDL for Package Body PJI_TIME_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_TIME_C" AS
/*$Header: PJICMT1B.pls 120.3 2005/10/17 18:09:43 appldev noship $*/


-- ------------------------
-- Global Variables
-- ------------------------
g_timer_start	DATE := NULL;
g_duration	NUMBER := NULL;

g_period_set_name VARCHAR2(15) := NULL;
g_period_type     VARCHAR2(15) := NULL;
g_week_start_day  VARCHAR2(30) := NULL;
g_week_offset     NUMBER;
g_user_id         NUMBER;
g_login_id        NUMBER;
g_debug_flag      VARCHAR2(1) := NVL(Fnd_Profile.VALUE('PA_DEBUG_MODE'), 'N');
g_earliest_start_date DATE;
g_latest_end_date DATE;
g_min_date DATE;
g_cal_info_exists VARCHAR2(1):='Y';

G_LOGIN_INFO_NOT_FOUND EXCEPTION;
G_BIS_PARAMETER_NOT_SETUP EXCEPTION;
G_ENT_CALENDAR_NOT_FOUND EXCEPTION;

---------------------------------------------------
-- Forward declarations of provide procedures
---------------------------------------------------


---------------------------------------------------
-- PRIVATE PROCEDURE start_timer
-- This procedure resets the elapsed time duration
-- and starts the clock.
---------------------------------------------------
PROCEDURE start_timer IS
BEGIN
	g_duration := 0;
	g_timer_start := SYSDATE;
END start_timer;


---------------------------------------------------
-- PRIVATE PROCEDURE stop_timer
-- This procedure computes the elapsed time since
-- call to to start_timer.
---------------------------------------------------
PROCEDURE stop_timer IS
BEGIN
	IF g_timer_start IS NULL THEN
		g_duration := 0;
	ELSE
		g_duration := SYSDATE - g_timer_start;
	END IF;
	g_timer_start := NULL;
END stop_timer;

---------------------------------------------------
-- PRIVATE PROCEDURE print_timer
-- This procedure prints the elapsed time stored
-- in the g_duration global variable.
---------------------------------------------------
PROCEDURE print_timer(p_text VARCHAR2)
IS
BEGIN
	IF (g_duration IS NOT NULL) THEN
	  pji_utils.write2log(p_text||' - '||
	  TO_CHAR(FLOOR(g_duration)) ||' Days '||
	  TO_CHAR(MOD(FLOOR(g_duration*24), 24))||':'||
	  TO_CHAR(MOD(FLOOR(g_duration*24*60), 60))||':'||
	  TO_CHAR(MOD(FLOOR(g_duration*24*60*60), 60)));
	END IF;
END print_timer;

---------------------------------------------------
-- PRIVATE FUNCTION get_week_offset
-- This function returns the week offset.
---------------------------------------------------
FUNCTION GET_WEEK_OFFSET(p_week_start_day VARCHAR2) RETURN NUMBER IS
l_week_offset NUMBER;
BEGIN
	IF p_week_start_day = '2' THEN
		l_week_offset := 0;
	ELSIF p_week_start_day = '3' THEN
		l_week_offset := 1;
	ELSIF p_week_start_day = '4' THEN
		l_week_offset := 2;
	ELSIF p_week_start_day = '5' THEN
		l_week_offset := 3;
	ELSIF p_week_start_day = '6' THEN
		l_week_offset := -3;
	ELSIF p_week_start_day = '7' THEN
		l_week_offset := -2;
	ELSIF p_week_start_day = '1' THEN
		l_week_offset := -1;
	END IF;
	RETURN l_week_offset;
END GET_WEEK_OFFSET;

---------------------------------------------------
-- PRIVATE FUNCTION get_period_num
-- This function returns 445 calendar's period
-- number for a given week number.
---------------------------------------------------
FUNCTION GET_PERIOD_NUM(p_week_num NUMBER) RETURN NUMBER IS
l_period_num  NUMBER;
BEGIN
	IF p_week_num IN (1,2,3,4) THEN
		l_period_num := 1;
	ELSIF p_week_num IN (5,6,7,8) THEN
		l_period_num := 2;
	ELSIF p_week_num IN (9,10,11,12,13) THEN
		l_period_num := 3;
	ELSIF p_week_num IN (14,15,16,17) THEN
		l_period_num := 4;
	ELSIF p_week_num IN (18,19,20,21) THEN
		l_period_num := 5;
	ELSIF p_week_num IN (22,23,24,25,26) THEN
		l_period_num := 6;
	ELSIF p_week_num IN (27,28,29,30) THEN
		l_period_num := 7;
	ELSIF p_week_num IN (31,32,33,34) THEN
		l_period_num := 8;
	ELSIF p_week_num IN (35,36,37,38,39) THEN
		l_period_num := 9;
	ELSIF p_week_num IN (40,41,42,43) THEN
		l_period_num := 10;
	ELSIF p_week_num IN (44,45,46,47) THEN
		l_period_num := 11;
	ELSE
		l_period_num := 12;
	END IF;
	RETURN l_period_num;
END GET_PERIOD_NUM;

---------------------------------------------------
-- PRIVATE PROCEDURE init
-- This procedure initializes all global variables
-- used in the package.
---------------------------------------------------
PROCEDURE INIT IS
BEGIN
	-- -------------------------------
	-- Initialize the global variables
	-- -------------------------------
	g_user_id := Fnd_Global.User_Id;
	g_login_id := Fnd_Global.Login_Id;

	IF (g_user_id IS NULL OR g_login_id IS NULL) THEN
		g_user_id:=-1;
		g_login_id:=-1;
		RAISE G_LOGIN_INFO_NOT_FOUND;
	END IF;

	/*
	** replace Bis_Common_Parameters with pji stuff
	*/
	g_period_set_name := pji_utils.get_period_set_name;
	g_period_type := pji_utils.get_period_type;
	g_week_start_day := pji_utils.get_start_day_of_week_id;
	--g_global_start_date := pji_utils.get_GLOBAL_START_DATE;
	g_week_offset := get_week_offset(g_week_start_day);

	BEGIN
		SELECT NVL(earliest_start_date,TRUNC(SYSDATE))
		, NVL(latest_end_date,TRUNC(SYSDATE))
		INTO
		g_earliest_start_date
		, g_latest_end_date
		FROM pji_time_cal_extr_info
		WHERE calendar_id = -1;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		g_cal_info_exists:='N';
		g_earliest_start_date:=TRUNC(SYSDATE);
		g_latest_end_date:=TRUNC(SYSDATE);
	END;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Enterprise Calendar = '||g_period_set_name||' ('||g_period_type||')');
		pji_utils.write2log('Week Start Day = '||g_week_start_day);
		pji_utils.write2log('Week offset = '||g_week_offset);
		pji_utils.write2log('Earliest Start Date: '||Fnd_Date.date_to_displaydate(g_earliest_start_date));
		pji_utils.write2log('Latest End Date: '||Fnd_Date.date_to_displaydate(g_latest_end_date));
	END IF;

	IF (g_period_set_name IS NULL OR g_period_type IS NULL) THEN
		RAISE G_BIS_PARAMETER_NOT_SETUP;
	END IF;
END INIT;

---------------------------------------------------
-- PRIVATE PROCEDURE load_week
-- This procedure maintains week records for given
-- from and to dates.
---------------------------------------------------
PROCEDURE LOAD_WEEK(p_from_date IN DATE, p_to_date IN DATE) IS
l_from_date DATE;
l_to_date DATE;
l_week DATE;
l_week_end DATE;
l_week_num NUMBER;
l_period_num NUMBER;
l_year_num NUMBER;
l_week_row NUMBER;
BEGIN

	l_to_date := TRUNC(p_to_date-g_week_offset,'iw')+g_week_offset+6;
	l_week := TRUNC(l_from_date-g_week_offset,'iw')+g_week_offset;
	l_week_end := l_week+6;
	l_week_num := TO_CHAR(l_week-g_week_offset,'iw');
	l_period_num  := get_period_num(l_week_num);
	l_year_num := TO_CHAR(l_week-g_week_offset,'iyyy');
	l_week_row := 0;

--	DELETE FROM PJI_TIME_WEEK WHERE start_date <= l_to_date AND end_date >= l_from_date;

	WHILE l_week <= l_to_date LOOP

		INSERT INTO pji_time_week
		(week_id,
		 period445_id,
		 SEQUENCE,
		 NAME,
		 start_date,
		 end_date,
		 creation_date,
		 last_update_date,
		 last_updated_by,
		 created_by,
		 last_update_login)
		VALUES
		(
		 l_year_num||LPAD(l_period_num,2,'0')||LPAD(l_week_num,2,'0'),
		 l_year_num||LPAD(l_period_num,2,'0'),
		 TO_CHAR(l_week-g_week_offset,'iw'),
		 TO_CHAR(l_week_end,'dd-Mon-rr'),
		 l_week,
		 l_week_end,
		 SYSDATE,
		 SYSDATE,
		 g_user_id,
		 g_user_id,
		 g_login_id
		);

		l_week := l_week_end+1;
		l_week_end := l_week+6;
		l_period_num := get_period_num(TO_CHAR(l_week-g_week_offset,'iw'));
		l_year_num := TO_CHAR(l_week-g_week_offset,'iyyy');
		l_week_row := l_week_row+1;
	END LOOP;
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_week_row)||' records has been populated to Week Level');
	END IF;
END LOAD_WEEK;

---------------------------------------------------
-- PRIVATE PROCEDURE load_ent_period
-- This procedure maintains week records for given
-- from and to dates.
---------------------------------------------------
FUNCTION LOAD_ENT_PERIOD RETURN BOOLEAN IS
l_no_rows_inserted NUMBER := 0;
l_min_date DATE;
l_max_date DATE;
BEGIN

	DELETE pji_time_extr_tmp;

	INSERT INTO pji_time_extr_tmp(period_year
	, quarter_num
	, period_num
	, period_name
	, start_date
	, end_date)
	SELECT period_year
	, quarter_num
	, period_num
	, period_name
	, start_date
	, end_date
	FROM gl_periods
	WHERE 1=1
	AND period_set_name = g_period_set_name
	AND period_type = g_period_type
	AND adjustment_period_flag='N'
	AND (start_date < g_earliest_start_date
	OR end_date > g_latest_end_date);

	INSERT INTO pji_time_ent_period(
	ent_period_id
	, ent_qtr_id
	, ent_year_id
	, sequence
	, name
	, start_date
	, end_date
	, creation_date
	, last_update_date
	, last_updated_by
	, created_by
	, last_update_login)
	SELECT TO_NUMBER(period_year||quarter_num||DECODE(LENGTH(period_num),1,'0'||period_num, period_num))
	, TO_NUMBER(period_year||quarter_num)
	, TO_NUMBER(period_year)
	, period_num
	, period_name
	, start_date
	, end_date
	, SYSDATE
	, SYSDATE
	, g_user_id
	, g_user_id
	, g_login_id
	FROM pji_time_extr_tmp;

	l_no_rows_inserted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_ENT_PERIOD table.');
	END IF;

	IF l_no_rows_inserted > 0 THEN
		SELECT MIN(start_date), MAX(end_date)
		INTO l_min_date, l_max_date
		FROM pji_time_ent_period
		WHERE (start_date < g_earliest_start_date
		OR end_date > g_latest_end_date);

		g_min_date:=l_min_date;

		IF g_cal_info_exists = 'N' THEN
			BEGIN
				IF g_debug_flag = 'Y' THEN
					pji_utils.write2log('Trying to insert record into PJI_TIME_EXTR_INFO table.');
				END IF;
				INSERT INTO pji_time_cal_extr_info
				(calendar_id, earliest_start_date,
				latest_end_date, creation_date,
				last_update_date, last_updated_by,
				created_by, last_update_login)
				VALUES (-1, l_min_date, l_max_date,
				sysdate, sysdate, -1, -1, -1);
			EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
				IF g_debug_flag = 'Y' THEN
					pji_utils.write2log('Duplicate records. Now trying to update the record...');
				END IF;
				UPDATE pji_time_cal_extr_info
				SET earliest_start_date = LEAST(l_min_date, earliest_start_date)
				, latest_end_date = GREATEST(l_max_date, latest_end_date)
				WHERE calendar_id = -1;
				g_cal_info_exists:='Y';
			END;
		ELSE
			UPDATE pji_time_cal_extr_info
			SET earliest_start_date = LEAST(l_min_date, earliest_start_date)
			, latest_end_date = GREATEST(l_max_date, latest_end_date)
			WHERE calendar_id = -1;
		END IF;

		--g_earliest_start_date:=LEAST(l_min_date, g_earliest_start_date);
		--g_latest_end_date:=GREATEST(l_max_date, g_latest_end_date);

		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('Calendar ID: -1');
			pji_utils.write2log('New Earliest Start Date: '||Fnd_Date.date_to_displaydate(l_min_date));
			pji_utils.write2log('New Latest End Date: '||Fnd_Date.date_to_displaydate(l_max_date));
		END IF;

	END IF;

	IF l_no_rows_inserted >0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Duplicate records. No records have been inserted into PJI_TIME_ENT_PERIOD table.');
	END IF;
	RETURN FALSE;
END LOAD_ENT_PERIOD;

---------------------------------------------------
-- PRIVATE PROCEDURE load_ent_qtr
-- This procedure incrementally maintains quarter
-- entries in PJI_TIME_ENT_QTR.
---------------------------------------------------
PROCEDURE LOAD_ENT_QTR IS
l_no_rows_deleted NUMBER := 0;
l_no_rows_inserted NUMBER := 0;
l_start_qtr_id NUMBER;
l_end_qtr_id NUMBER;
l_earliest_qtr_end_date DATE;
l_latest_qtr_start_date DATE;
BEGIN
	IF g_cal_info_exists = 'Y' THEN
		SELECT
		MIN(ent_qtr_id) start_qtr_id
		, MAX(ent_qtr_id) end_qtr_id
		, MIN(end_date) earliest_qtr_end_date
		, MAX(start_date) latest_qtr_start_date
		INTO
		l_start_qtr_id
		, l_end_qtr_id
		, l_earliest_qtr_end_date
		, l_latest_qtr_start_date
		FROM pji_time_ent_qtr
		WHERE 1=1
		AND (g_earliest_start_date BETWEEN start_date AND end_date)
		OR (g_latest_end_date BETWEEN start_date AND end_date);
		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('l_start_qtr_id: '||l_start_qtr_id);
			pji_utils.write2log('l_end_qtr_id: '||l_end_qtr_id);
			pji_utils.write2log('l_earliest_qtr_end_date: '||l_earliest_qtr_end_date);
			pji_utils.write2log('l_latest_qtr_start_date: '||l_latest_qtr_start_date);
		END IF;
	END IF;

	DELETE FROM pji_time_ent_qtr
	WHERE ent_qtr_id in (SELECT DISTINCT period_year||quarter_num FROM pji_time_extr_tmp);

	l_no_rows_deleted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Some records have to be refreshed in PJI_TIME_ENT_QTR table.');
		pji_utils.write2log(TO_CHAR(l_no_rows_deleted)||' records have been deleted from PJI_TIME_ENT_QTR table.');
	END IF;

	INSERT INTO pji_time_ent_qtr
	(ent_qtr_id
	, ent_year_id
	, SEQUENCE
	, NAME
	, start_date
	, end_date
	, creation_date
	, last_update_date
	, last_updated_by
	, created_by
	, last_update_login)
	SELECT period_year||quarter_num
	, period_year
	, quarter_num
	, REPLACE(Fnd_Message.get_string('PJI','PJI_QUARTER_LABEL'),'&QUARTER_NUMBER',quarter_num)
			||'-'||
			TO_CHAR(TO_DATE(period_year,'yyyy'),'RR')
	, DECODE(period_year||quarter_num,l_end_qtr_id,l_latest_qtr_start_date,MIN(start_date))
	, DECODE(period_year||quarter_num,l_start_qtr_id,l_earliest_qtr_end_date,MAX(end_date))
	, SYSDATE
	, SYSDATE
	, g_user_id
	, g_user_id
	, g_login_id
	FROM pji_time_extr_tmp
	GROUP BY
	period_year||quarter_num
	, period_year
	, quarter_num
	HAVING MAX(end_date)<g_earliest_start_date
	OR MIN(start_date)>g_latest_end_date
	OR g_cal_info_exists = 'N';

	l_no_rows_inserted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_ENT_QTR table.');
	END IF;

EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Duplicate records. No records have been inserted into PJI_TIME_ENT_QTR table.');
	END IF;
END LOAD_ENT_QTR;

---------------------------------------------------
-- PRIVATE PROCEDURE load_ent_year
-- This procedure incrementally maintains year
-- entries in PJI_TIME_ENT_YEAR.
---------------------------------------------------
PROCEDURE LOAD_ENT_YEAR IS
l_no_rows_deleted NUMBER := 0;
l_no_rows_inserted NUMBER := 0;
l_start_yr_id NUMBER;
l_end_yr_id NUMBER;
l_earliest_yr_end_date DATE;
l_latest_yr_start_date DATE;
BEGIN
	IF g_cal_info_exists = 'Y' THEN
		SELECT
		MIN(ent_year_id) start_yr_id
		, MAX(ent_year_id) end_yr_id
		, MIN(end_date) earliest_yr_end_date
		, MAX(start_date) latest_yr_start_date
		INTO
		l_start_yr_id
		, l_end_yr_id
		, l_earliest_yr_end_date
		, l_latest_yr_start_date
		FROM pji_time_ent_year
		WHERE 1=1
		AND (g_earliest_start_date BETWEEN start_date AND end_date)
		OR (g_latest_end_date BETWEEN start_date AND end_date);
		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('l_start_yr_id: '||l_start_yr_id);
			pji_utils.write2log('l_end_yr_id: '||l_end_yr_id);
			pji_utils.write2log('l_earliest_yr_end_date: '||l_earliest_yr_end_date);
			pji_utils.write2log('l_latest_yr_start_date: '||l_latest_yr_start_date);
		END IF;
	END IF;

	DELETE FROM pji_time_ent_year
	WHERE ent_year_id in (SELECT DISTINCT period_year from pji_time_extr_tmp);

	l_no_rows_deleted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Some records have to be refreshed in PJI_TIME_ENT_YEAR table.');
		pji_utils.write2log(TO_CHAR(l_no_rows_deleted)||' records have been deleted from PJI_TIME_ENT_YEAR table.');
	END IF;

	INSERT INTO pji_time_ent_year
	(ent_year_id
	, period_set_name
	, period_type
	, SEQUENCE
	, NAME
	, start_date
	, end_date
	, creation_date
	, last_update_date
	, last_updated_by
	, created_by
	, last_update_login)
	SELECT period_year
	, g_period_set_name
	, g_period_type
	, period_year
	, period_year
	, DECODE(period_year,l_end_yr_id,l_latest_yr_start_date,MIN(start_date))
	, DECODE(period_year,l_start_yr_id,l_earliest_yr_end_date,MAX(end_date))
	, SYSDATE
	, SYSDATE
	, g_user_id
	, g_user_id
	, g_login_id
	FROM pji_time_extr_tmp
	GROUP BY period_year
	HAVING MAX(end_date)<g_earliest_start_date
	OR MIN(start_date)>g_latest_end_date
	OR g_cal_info_exists = 'N';

	l_no_rows_inserted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_ENT_YEAR table.');
	END IF;

EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Duplicate records. No records have been inserted into PJI_TIME_ENT_YEAR table.');
	END IF;
END LOAD_ENT_YEAR;

FUNCTION LOAD_CAL_PERIOD( p_calendar_id NUMBER
, p_period_set_name VARCHAR2
, p_period_type VARCHAR2
, p_earliest_start_date DATE
, p_latest_end_date DATE
, p_cal_info_exists VARCHAR2
, p_min_date IN OUT NOCOPY  DATE ) RETURN BOOLEAN IS
l_no_rows_inserted NUMBER := 0;
l_min_date DATE;
l_max_date DATE;
BEGIN
	DELETE pji_time_extr_tmp;

	INSERT INTO pji_time_extr_tmp(period_year
	, quarter_num
	, period_num
	, period_name
	, start_date
	, end_date)
	SELECT period_year
	, quarter_num
	, period_num
	, period_name
	, start_date
	, end_date
	FROM gl_periods
	WHERE 1=1
	AND period_set_name = p_period_set_name
	AND period_type = p_period_type
	AND adjustment_period_flag='N'
	AND (start_date < p_earliest_start_date
	OR end_date > p_latest_end_date);

	INSERT INTO pji_time_cal_period(cal_period_id
	 , cal_qtr_id
	 , calendar_id
	 , SEQUENCE
	 , NAME
	 , start_date
	 , end_date
	 , creation_date
	 , last_update_date
	 , last_updated_by
	 , created_by
	 , last_update_login)
	SELECT LPAD(p_calendar_id,3,'0')||period_year||quarter_num
		||DECODE(LENGTH(period_num),1,'0'||period_num, period_num)
	, LPAD(p_calendar_id,3,'0')||period_year||quarter_num
	, LPAD(p_calendar_id,3,'0')
	, period_num
	, period_name
	, start_date
	, end_date
	, SYSDATE
	, SYSDATE
	, g_user_id
	, g_user_id
	, g_login_id
	FROM pji_time_extr_tmp;

	l_no_rows_inserted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_CAL_PERIOD table.');
	END IF;

	IF l_no_rows_inserted > 0 THEN
		SELECT MIN(start_date), MAX(end_date)
		INTO l_min_date, l_max_date
		FROM pji_time_cal_period
		WHERE (start_date < p_earliest_start_date
		OR end_date > p_latest_end_date)
		AND calendar_id = p_calendar_id;

		p_min_date:=l_min_date;

		IF p_cal_info_exists = 'N' THEN
			BEGIN
				IF g_debug_flag = 'Y' THEN
					pji_utils.write2log('Trying to insert record into PJI_TIME_EXTR_INFO table.');
				END IF;
				INSERT INTO pji_time_cal_extr_info
				(calendar_id, earliest_start_date,
				latest_end_date, creation_date,
				last_update_date, last_updated_by,
				created_by, last_update_login)
				VALUES (p_calendar_id, l_min_date, l_max_date,
				sysdate, sysdate, -1, -1, -1);
			EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
				IF g_debug_flag = 'Y' THEN
					pji_utils.write2log('Duplicate records. Now trying to update the record...');
				END IF;
				UPDATE pji_time_cal_extr_info
				SET earliest_start_date = LEAST(l_min_date, earliest_start_date)
				, latest_end_date = GREATEST(l_max_date, latest_end_date)
				WHERE calendar_id = p_calendar_id;
			END;
		ELSE
			UPDATE pji_time_cal_extr_info
			SET earliest_start_date = LEAST(l_min_date, earliest_start_date)
			, latest_end_date = GREATEST(l_max_date, latest_end_date)
			WHERE calendar_id = p_calendar_id;
		END IF;

		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('Calendar ID: '||p_calendar_id);
			pji_utils.write2log('Earliest Start Date: '||Fnd_Date.date_to_displaydate(l_min_date));
			pji_utils.write2log('Latest End Date: '||Fnd_Date.date_to_displaydate(l_max_date));
		END IF;

	END IF;
	IF l_no_rows_inserted >0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Duplicate records. No records have been inserted into PJI_TIME_CAL_PERIOD table.');
	END IF;
	RETURN FALSE;
END LOAD_CAL_PERIOD;

---------------------------------------------------
-- PRIVATE PROCEDURE load_cal_qtr
-- This procedure incrementally maintains quarter
-- entries in PJI_TIME_CAL_YEAR.
---------------------------------------------------
PROCEDURE LOAD_CAL_QUARTER(p_calendar_id NUMBER
, p_earliest_start_date DATE
, p_latest_end_date DATE
, p_cal_info_exists VARCHAR2)
IS
l_no_rows_deleted NUMBER := 0;
l_no_rows_inserted NUMBER := 0;
l_start_qtr_id NUMBER;
l_end_qtr_id NUMBER;
l_earliest_qtr_end_date DATE;
l_latest_qtr_start_date DATE;
BEGIN
	IF p_cal_info_exists = 'Y' THEN
		SELECT
		MIN(cal_qtr_id) start_qtr_id
		, MAX(cal_qtr_id) end_qtr_id
		, MIN(end_date) earliest_qtr_end_date
		, MAX(start_date) latest_qtr_start_date
		INTO
		l_start_qtr_id
		, l_end_qtr_id
		, l_earliest_qtr_end_date
		, l_latest_qtr_start_date
		FROM pji_time_cal_qtr
		WHERE 1=1
		AND calendar_id = p_calendar_id
		AND (p_earliest_start_date BETWEEN start_date AND end_date)
		OR (p_latest_end_date BETWEEN start_date AND end_date);
		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('l_start_qtr_id: '||l_start_qtr_id);
			pji_utils.write2log('l_end_qtr_id: '||l_end_qtr_id);
			pji_utils.write2log('l_earliest_qtr_end_date: '||l_earliest_qtr_end_date);
			pji_utils.write2log('l_latest_qtr_start_date: '||l_latest_qtr_start_date);
		END IF;
	END IF;

	DELETE FROM pji_time_cal_qtr
	WHERE cal_qtr_id in (SELECT DISTINCT LPAD(p_calendar_id,3,'0')||period_year||quarter_num FROM pji_time_extr_tmp);

	l_no_rows_deleted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Some records have to be refreshed in PJI_TIME_CAL_QTR table.');
		pji_utils.write2log(TO_CHAR(l_no_rows_deleted)||' records have been deleted from PJI_TIME_CAL_QTR table.');
	END IF;

	INSERT INTO pji_time_cal_qtr
	(cal_qtr_id
	 , cal_year_id
	 , calendar_id
	 , SEQUENCE
	 , NAME
	 , start_date
	 , end_date
	 , creation_date
	 , last_update_date
	 , last_updated_by
	 , created_by
	 , last_update_login)
	SELECT LPAD(p_calendar_id,3,'0')||period_year||quarter_num
	 , LPAD(p_calendar_id,3,'0')||period_year
	 , LPAD(p_calendar_id,3,'0')
	 , quarter_num
	 , TO_CHAR(quarter_num)||', '||TO_CHAR(period_year)
	 , DECODE(LPAD(p_calendar_id,3,'0')||period_year||quarter_num,l_end_qtr_id,l_latest_qtr_start_date,MIN(start_date))
	 , DECODE(LPAD(p_calendar_id,3,'0')||period_year||quarter_num,l_start_qtr_id,l_earliest_qtr_end_date,MAX(end_date))
	 , SYSDATE
	 , SYSDATE
	 , g_user_id
	 , g_user_id
	 , g_login_id
	FROM pji_time_extr_tmp
	GROUP BY period_year||quarter_num
	, period_year
	, quarter_num
	HAVING MAX(end_date)<p_earliest_start_date
	OR MIN(start_date)>p_latest_end_date
	OR p_cal_info_exists = 'N';


	l_no_rows_inserted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_CAL_QTR table.');
	END IF;

EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Duplicate records. No records have been inserted into PJI_TIME_CAL_QTR table.');
	END IF;
END LOAD_CAL_QUARTER;

---------------------------------------------------
-- PRIVATE PROCEDURE load_cal_year
-- This procedure incrementally maintains year
-- entries in PJI_TIME_CAL_YEAR.
---------------------------------------------------
PROCEDURE LOAD_CAL_YEAR(p_calendar_id NUMBER
, p_earliest_start_date DATE
, p_latest_end_date DATE
, p_cal_info_exists VARCHAR2) IS
l_no_rows_deleted NUMBER := 0;
l_no_rows_inserted NUMBER := 0;
l_start_yr_id NUMBER;
l_end_yr_id NUMBER;
l_earliest_yr_end_date DATE;
l_latest_yr_start_date DATE;
BEGIN
	IF g_cal_info_exists = 'Y' THEN
		SELECT
		MIN(cal_year_id) start_yr_id
		, MAX(cal_year_id) end_yr_id
		, MIN(end_date) earliest_yr_end_date
		, MAX(start_date) latest_yr_start_date
		INTO
		l_start_yr_id
		, l_end_yr_id
		, l_earliest_yr_end_date
		, l_latest_yr_start_date
		FROM pji_time_cal_year
		WHERE 1=1
		AND calendar_id = p_calendar_id
		AND (g_earliest_start_date BETWEEN start_date AND end_date)
		OR (g_latest_end_date BETWEEN start_date AND end_date);

		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('l_start_yr_id: '||l_start_yr_id);
			pji_utils.write2log('l_end_yr_id: '||l_end_yr_id);
			pji_utils.write2log('l_earliest_yr_end_date: '||l_earliest_yr_end_date);
			pji_utils.write2log('l_latest_yr_start_date: '||l_latest_yr_start_date);
		END IF;
	END IF;

	DELETE FROM pji_time_cal_year
	WHERE cal_year_id in (SELECT DISTINCT LPAD(p_calendar_id,3,'0')||period_year from pji_time_extr_tmp);

	l_no_rows_deleted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Some records have to be refreshed in PJI_TIME_CAL_YEAR table.');
		pji_utils.write2log(TO_CHAR(l_no_rows_deleted)||' records have been deleted from PJI_TIME_CAL_YEAR table.');
	END IF;

	INSERT INTO PJI_TIME_CAL_YEAR
	(cal_year_id
	, calendar_id
	, SEQUENCE
	, NAME
	, start_date
	, end_date
	, creation_date
	, last_update_date
	, last_updated_by
	, created_by
	, last_update_login)
	SELECT LPAD(p_calendar_id,3,'0')||period_year
	, LPAD(p_calendar_id,3,'0')
	, period_year
	, period_year
	, DECODE(LPAD(p_calendar_id,3,'0')||period_year,l_end_yr_id,l_latest_yr_start_date,MIN(start_date))
	, DECODE(LPAD(p_calendar_id,3,'0')||period_year,l_start_yr_id,l_earliest_yr_end_date,MAX(end_date))
	, SYSDATE
	, SYSDATE
	, g_user_id
	, g_user_id
	, g_login_id
	FROM pji_time_extr_tmp
	GROUP BY period_year
	HAVING MAX(end_date)<p_earliest_start_date
	OR MIN(start_date)>p_latest_end_date
	OR p_cal_info_exists = 'N';

	l_no_rows_inserted := SQL%rowcount;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_CAL_YEAR table.');
	END IF;

EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Duplicate records. No records have been inserted into PJI_TIME_CAL_YEAR table.');
	END IF;
END LOAD_CAL_YEAR;

---------------------------------------------------
-- PRIVATE PROCEDURE load_time_rpt_struct
-- This procedure incrementally maintains
-- entries in PJI_TIME_RPT_STRUCT table.
---------------------------------------------------
PROCEDURE LOAD_TIME_RPT_STRUCT IS
l_no_rows_inserted NUMBER;
l_year_start_date DATE;
l_qtr_start_date DATE;
l_period_start_date DATE;
l_year_end_date DATE;
l_qtr_end_date DATE;
l_period_end_date DATE;
BEGIN
	IF g_min_date < g_earliest_start_date THEN
		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('The enterprise calendar has been extended before the earliest start date.');
		END IF;
		BEGIN
			SELECT period.start_date period_start_date
			, qtr.start_date qtr_start_date
			, yr.start_date year_start_date
			, period.end_date period_end_date
			, qtr.end_date qtr_end_date
			, yr.end_date year_end_date
			INTO
			  l_period_start_date
			, l_qtr_start_date
			, l_year_start_date
			, l_qtr_end_date
			, l_period_end_date
			, l_year_end_date
			FROM pji_time_ent_period period
			, pji_time_ent_qtr qtr
			, pji_time_ent_year yr
			WHERE 1=1
			AND period.ent_qtr_id = qtr.ent_qtr_id
			AND qtr.ent_year_id = yr.ent_year_id
			AND period.start_date = g_earliest_start_date;

			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Creating prior year records for time periods after the current year.');
			END IF;

			INSERT INTO PJI_TIME_RPT_STRUCT
			(calendar_id
			 , calendar_type
			 , report_date
			 , time_id
			 , period_type_id
			 , record_type_id
			 , creation_date
			 , last_update_date
			 , last_updated_by
			 , created_by
			 , last_update_login)
			SELECT
			 -1
			 , 'E'
			 , period.start_date
			 , year.ent_year_id
			 , 128
			 , 1024
			 , SYSDATE
			 , SYSDATE
			 , g_user_id
			 , g_user_id
			 , g_login_id
			FROM PJI_TIME_ENT_YEAR year
			, PJI_TIME_ENT_PERIOD period
			WHERE year.end_date < l_year_start_date
			AND period.start_date >= g_earliest_start_date;

			l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Creating prior quarter records for time periods records after current quarter.');
			END IF;

			INSERT INTO PJI_TIME_RPT_STRUCT
			(calendar_id
			 , calendar_type
			 , report_date
			 , time_id
			 , period_type_id
			 , record_type_id
			 , creation_date
			 , last_update_date
			 , last_updated_by
			 , created_by
			 , last_update_login)
			SELECT
			 -1
			 , 'E'
			 , period.start_date
			 , qtr.ent_qtr_id
			 , 64
			 , 64
			 , SYSDATE
			 , SYSDATE
			 , g_user_id
			 , g_user_id
			 , g_login_id
			FROM PJI_TIME_ENT_QTR qtr
			, PJI_TIME_ENT_PERIOD period
			WHERE 1=1
			AND qtr.end_date < l_qtr_start_date
			AND qtr.start_date >= l_year_start_date
			AND period.start_date >= g_earliest_start_date
			AND period.end_date <= l_year_end_date;

			l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Creating prior period records for time periods records after current periods.');
			END IF;

			INSERT INTO PJI_TIME_RPT_STRUCT
			(calendar_id
			 , calendar_type
			 , report_date
			 , time_id
			 , period_type_id
			 , record_type_id
			 , creation_date
			 , last_update_date
			 , last_updated_by
			 , created_by
			 , last_update_login)
			SELECT
			 -1
			 , 'E'
			 , oldprd.start_date
			 , newprd.ent_period_id
			 , 32
			 , 32
			 , SYSDATE
			 , SYSDATE
			 , g_user_id
			 , g_user_id
			 , g_login_id
			FROM PJI_TIME_ENT_PERIOD newprd
			, PJI_TIME_ENT_PERIOD oldprd
			WHERE 1=1
			AND newprd.end_date < l_period_start_date
			AND newprd.start_date >= l_qtr_start_date
			AND oldprd.start_date >= g_earliest_start_date
			AND oldprd.end_date <= l_qtr_end_date;

			l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Unable to derive records for earliest start date.');
			END IF;
		END;
	END IF;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Creating entries in the enterprise reporting structure table for extracted records only.');
	END IF;

	FOR extr_rec IN (SELECT extr.start_date report_date
				, period.start_date period_start_date
				, qtr.start_date qtr_start_date
				, YEAR.start_date year_start_date
				, period.end_date period_end_date
				, qtr.end_date qtr_end_date
				, YEAR.end_date year_end_date
				FROM pji_time_extr_tmp extr
				, pji_time_ent_period period
				, pji_time_ent_qtr qtr
				, pji_time_ent_year YEAR
				WHERE 1=1
				AND TO_NUMBER(extr.period_year||extr.quarter_num||DECODE(LENGTH(extr.period_num),1,'0'||extr.period_num, extr.period_num)) = period.ent_period_id
				AND period.ent_qtr_id = qtr.ent_qtr_id
				AND qtr.ent_year_id = YEAR.ent_year_id)
	LOOP
		INSERT INTO PJI_TIME_RPT_STRUCT
		(calendar_id
		 , calendar_type
		 , report_date
		 , time_id
		 , period_type_id
		 , record_type_id
		 , creation_date
		 , last_update_date
		 , last_updated_by
		 , created_by
		 , last_update_login)
		SELECT
		  -1
		 , 'E'
		 , extr_rec.report_date
		 , ent_period_id
		 , 32
		 , 32
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_ENT_PERIOD
		WHERE start_date >= extr_rec.qtr_start_date
		AND start_date <= extr_rec.period_start_date
		AND end_date < extr_rec.report_date
		UNION ALL
		SELECT
		  -1
		 , 'E'
		 , extr_rec.report_date
		 , ent_period_id
		 , 32
		 , 256
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_ENT_PERIOD
		WHERE start_date >= extr_rec.qtr_start_date
		AND start_date <= extr_rec.period_start_date
		AND end_date >= extr_rec.report_date;

		l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

		INSERT INTO PJI_TIME_RPT_STRUCT
		(calendar_id
		 , calendar_type
		 , report_date
		 , time_id
		 , period_type_id
		 , record_type_id
		 , creation_date
		 , last_update_date
		 , last_updated_by
		 , created_by
		 , last_update_login)
		SELECT
		 -1
		 , 'E'
		 , extr_rec.report_date
		 , ent_qtr_id
		 , 64
		 , 64
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_ENT_QTR
		WHERE start_date >= extr_rec.year_start_date
		AND start_date <= extr_rec.qtr_start_date
		AND end_date < extr_rec.report_date
		UNION ALL
		SELECT
		 -1
		 , 'E'
		 , extr_rec.report_date
		 , ent_qtr_id
		 , 64
		 , 512
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_ENT_QTR
		WHERE start_date >= extr_rec.year_start_date
		AND start_date <= extr_rec.qtr_start_date
		AND end_date >= extr_rec.report_date;

		l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

		INSERT INTO PJI_TIME_RPT_STRUCT
		(calendar_id
		 , calendar_type
		 , report_date
		 , time_id
		 , period_type_id
		 , record_type_id
		 , creation_date
		 , last_update_date
		 , last_updated_by
		 , created_by
		 , last_update_login)
		SELECT
		 -1
		 , 'E'
		 , extr_rec.report_date
		 , ent_year_id
		 , 128
		 , 128
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_ENT_YEAR
		WHERE extr_rec.report_date BETWEEN start_date AND end_date
		UNION ALL
		SELECT
		 -1
		 , 'E'
		 , extr_rec.report_date
		 , ent_year_id
		 , 128
		 , 1024
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_ENT_YEAR
		WHERE end_date < extr_rec.report_date;

		l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_RPT_STRUCT table for date : '||Fnd_Date.date_to_displaydate(extr_rec.report_date));
		END IF;

	END LOOP;
END LOAD_TIME_RPT_STRUCT;

---------------------------------------------------
-- PRIVATE PROCEDURE load_time_cal_rpt_struct
-- This procedure incrementally maintains
-- entries in PJI_TIME_CAL_RPT_STRUCT table.
---------------------------------------------------
PROCEDURE LOAD_TIME_CAL_RPT_STRUCT ( p_calendar_id NUMBER
, p_earliest_start_date DATE
, p_min_date DATE
, p_cal_info_exists VARCHAR2
) IS
l_no_rows_inserted NUMBER;
l_year_start_date DATE;
l_qtr_start_date DATE;
l_period_start_date DATE;
l_year_end_date DATE;
l_qtr_end_date DATE;
l_period_end_date DATE;
BEGIN
	IF p_min_date < p_earliest_start_date and p_cal_info_exists <> 'N' THEN
		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log('The fiscal calendar has been extended before the earliest start date.');
		END IF;
		BEGIN
			SELECT period.start_date period_start_date
			, qtr.start_date qtr_start_date
			, yr.start_date year_start_date
			, period.end_date period_end_date
			, qtr.end_date qtr_end_date
			, yr.end_date year_end_date
			INTO
			  l_period_start_date
			, l_qtr_start_date
			, l_year_start_date
			, l_qtr_end_date
			, l_period_end_date
			, l_year_end_date
			FROM pji_time_cal_period period
			, pji_time_cal_qtr qtr
			, pji_time_cal_year yr
			WHERE 1=1
			AND period.calendar_id = p_calendar_id
			AND period.cal_qtr_id = qtr.cal_qtr_id
			AND qtr.cal_year_id = yr.cal_year_id
			AND period.start_date = p_earliest_start_date;

			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Creating prior year records for time periods after the current year.');
			END IF;

			INSERT INTO PJI_TIME_CAL_RPT_STRUCT
			(calendar_id
			 , calendar_type
			 , report_date
			 , time_id
			 , period_type_id
			 , record_type_id
			 , creation_date
			 , last_update_date
			 , last_updated_by
			 , created_by
			 , last_update_login)
			SELECT
			 p_calendar_id
			 , 'G'
			 , period.start_date
			 , year.cal_year_id
			 , 128
			 , 1024
			 , SYSDATE
			 , SYSDATE
			 , g_user_id
			 , g_user_id
			 , g_login_id
			FROM PJI_TIME_CAL_YEAR year
			, PJI_TIME_CAL_PERIOD period
			WHERE year.end_date < l_year_start_date
			AND year.calendar_id = p_calendar_id
			AND period.calendar_id = p_calendar_id
			AND period.start_date > p_earliest_start_date;

			l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Creating prior quarter records for time periods records after current quarter.');
			END IF;

			INSERT INTO PJI_TIME_CAL_RPT_STRUCT
			(calendar_id
			 , calendar_type
			 , report_date
			 , time_id
			 , period_type_id
			 , record_type_id
			 , creation_date
			 , last_update_date
			 , last_updated_by
			 , created_by
			 , last_update_login)
			SELECT
			 p_calendar_id
			 , 'G'
			 , period.start_date
			 , qtr.cal_qtr_id
			 , 64
			 , 64
			 , SYSDATE
			 , SYSDATE
			 , g_user_id
			 , g_user_id
			 , g_login_id
			FROM PJI_TIME_CAL_QTR qtr
			, PJI_TIME_CAL_PERIOD period
			WHERE 1=1
			AND qtr.end_date < l_qtr_start_date
			AND qtr.start_date >= l_year_start_date
			AND qtr.calendar_id = p_calendar_id
			AND period.calendar_id = p_calendar_id
			AND period.start_date > p_earliest_start_date
			AND period.end_date <= l_year_end_date;

			l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Creating prior period records for time periods records after current periods.');
			END IF;

			INSERT INTO PJI_TIME_CAL_RPT_STRUCT
			(calendar_id
			 , calendar_type
			 , report_date
			 , time_id
			 , period_type_id
			 , record_type_id
			 , creation_date
			 , last_update_date
			 , last_updated_by
			 , created_by
			 , last_update_login)
			SELECT
			 p_calendar_id
			 , 'G'
			 , oldprd.start_date
			 , newprd.cal_period_id
			 , 32
			 , 32
			 , SYSDATE
			 , SYSDATE
			 , g_user_id
			 , g_user_id
			 , g_login_id
			FROM PJI_TIME_CAL_PERIOD newprd
			, PJI_TIME_CAL_PERIOD oldprd
			WHERE 1=1
			AND newprd.end_date < l_period_start_date
			AND newprd.start_date >= l_qtr_start_date
			AND newprd.calendar_id = p_calendar_id
			AND oldprd.calendar_id = p_calendar_id
			AND oldprd.start_date > p_earliest_start_date
			AND oldprd.end_date <= l_qtr_end_date;

			l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Unable to derive records for earliest start date.');
			END IF;
		END;
	END IF;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log('Creating entries in the fiscal reporting structure table for extracted records only.');
	END IF;

	FOR extr_rec IN (SELECT extr.start_date report_date
				, period.start_date period_start_date
				, qtr.start_date qtr_start_date
				, YEAR.start_date year_start_date
				, period.end_date period_end_date
				, qtr.end_date qtr_end_date
				, YEAR.end_date year_end_date
				FROM pji_time_extr_tmp extr
				, pji_time_cal_period period
				, pji_time_cal_qtr qtr
				, pji_time_cal_year YEAR
				WHERE 1=1
				AND period.calendar_id = p_calendar_id
				AND TO_NUMBER(LPAD(p_calendar_id,3,'0')||period_year||quarter_num||DECODE(LENGTH(period_num),1,'0'||period_num, period_num)) = period.cal_period_id
				AND period.cal_qtr_id = qtr.cal_qtr_id
				AND qtr.cal_year_id = YEAR.cal_year_id)
	LOOP
		INSERT INTO PJI_TIME_CAL_RPT_STRUCT
		(calendar_id
		 , calendar_type
		 , report_date
		 , time_id
		 , period_type_id
		 , record_type_id
		 , creation_date
		 , last_update_date
		 , last_updated_by
		 , created_by
		 , last_update_login)
		SELECT
		  p_calendar_id
		 , 'G'
		 , extr_rec.report_date
		 , cal_period_id
		 , 32
		 , 32
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_CAL_PERIOD
		WHERE start_date >= extr_rec.qtr_start_date
		AND start_date <= extr_rec.period_start_date
		AND end_date < extr_rec.report_date
		AND calendar_id = p_calendar_id
		UNION ALL
		SELECT
		  p_calendar_id
		 , 'G'
		 , extr_rec.report_date
		 , cal_period_id
		 , 32
		 , 256
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_CAL_PERIOD
		WHERE start_date >= extr_rec.qtr_start_date
		AND start_date <= extr_rec.period_start_date
		AND end_date >= extr_rec.report_date
		AND calendar_id = p_calendar_id;

		l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

		INSERT INTO PJI_TIME_CAL_RPT_STRUCT
		(calendar_id
		 , calendar_type
		 , report_date
		 , time_id
		 , period_type_id
		 , record_type_id
		 , creation_date
		 , last_update_date
		 , last_updated_by
		 , created_by
		 , last_update_login)
		SELECT
		 p_calendar_id
		 , 'G'
		 , extr_rec.report_date
		 , cal_qtr_id
		 , 64
		 , 64
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_CAL_QTR
		WHERE start_date >= extr_rec.year_start_date
		AND start_date <= extr_rec.qtr_start_date
		AND end_date < extr_rec.report_date
		AND calendar_id = p_calendar_id
		UNION ALL
		SELECT
		 p_calendar_id
		 , 'G'
		 , extr_rec.report_date
		 , cal_qtr_id
		 , 64
		 , 512
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_CAL_QTR
		WHERE start_date >= extr_rec.year_start_date
		AND start_date <= extr_rec.qtr_start_date
		AND end_date >= extr_rec.report_date
		AND calendar_id = p_calendar_id;

		l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

		INSERT INTO PJI_TIME_CAL_RPT_STRUCT
		(calendar_id
		 , calendar_type
		 , report_date
		 , time_id
		 , period_type_id
		 , record_type_id
		 , creation_date
		 , last_update_date
		 , last_updated_by
		 , created_by
		 , last_update_login)
		SELECT
		 p_calendar_id
		 , 'G'
		 , extr_rec.report_date
		 , cal_year_id
		 , 128
		 , 128
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_CAL_YEAR
		WHERE extr_rec.report_date BETWEEN start_date AND end_date
		AND calendar_id = p_calendar_id
		UNION ALL
		SELECT
		 p_calendar_id
		 , 'G'
		 , extr_rec.report_date
		 , cal_year_id
		 , 128
		 , 1024
		 , SYSDATE
		 , SYSDATE
		 , g_user_id
		 , g_user_id
		 , g_login_id
		FROM PJI_TIME_CAL_YEAR
		WHERE end_date < extr_rec.report_date
		AND calendar_id = p_calendar_id;

		l_no_rows_inserted := l_no_rows_inserted + SQL%rowcount;

		IF g_debug_flag = 'Y' THEN
			pji_utils.write2log(TO_CHAR(l_no_rows_inserted)||' records have been inserted into PJI_TIME_CAL_RPT_STRUCT table for date : '||Fnd_Date.date_to_displaydate(extr_rec.report_date));
		END IF;

	END LOOP;
END LOAD_TIME_CAL_RPT_STRUCT;

---------------------------------------------------
-- PUBLIC PROCEDURE load
-- This is a public procedure that extracts
-- GL period definitions into time summary tables.
-- parameters :
-- p_period_set_name - GL periodset name to extract
-- p_period_type - GL periodset name to extract
-- x_return_status - Standard return status:
--       Success     = Fnd_Api.G_RET_STS_SUCCESS
--       Error       = Fnd_Api.G_RET_STS_ERROR
--       Unexp Error = G_RET_Fnd_Api.STS_UNEXP_ERROR
-- x_msg_count - Standard message param used in FWK
-- x_msg_data  - Standard message param used in FWK
---------------------------------------------------
PROCEDURE LOAD( p_period_set_name VARCHAR2 DEFAULT NULL
		, p_period_type VARCHAR2 DEFAULT NULL
		, x_return_status OUT NOCOPY VARCHAR2
		, x_msg_count OUT NOCOPY NUMBER
		, x_msg_data OUT NOCOPY VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_calendar_id NUMBER;
l_calendar_ids_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_period_set_name_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_period_type_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_earliest_start_dates_tbl SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
l_latest_end_dates_tbl SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
l_cal_info_exists_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_earliest_start_date DATE;
l_latest_end_date DATE;
l_min_date DATE;
l_process_ent_flag VARCHAR2(1);
BEGIN

	IF p_period_set_name IS NULL AND p_period_set_name IS NULL THEN
		--Call fii calendar load program.
		FII_NON_DBI_TIME_C.LOAD_CAL_NAME;
	ELSIF p_period_set_name IS NOT NULL AND p_period_set_name IS NOT NULL THEN
		BEGIN
			SELECT calendar_id
			INTO l_calendar_id
			FROM fii_time_cal_name
			WHERE period_set_name = p_period_set_name
			AND period_type = p_period_type;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Call fii calendar incremental load program.
			FII_NON_DBI_TIME_C.LOAD_CAL_NAME;
		END;
	END IF;

	SELECT cal.calendar_id
	, period_set_name
	, period_type
	, NVL(info.earliest_start_date,TRUNC(SYSDATE))
	, NVL(info.latest_end_date,TRUNC(SYSDATE))
	, DECODE(NVL(info.earliest_start_date,TRUNC(SYSDATE)),info.earliest_start_date,'Y','N')
	BULK COLLECT INTO
	  l_calendar_ids_tbl
	, l_period_set_name_tbl
	, l_period_type_tbl
	, l_earliest_start_dates_tbl
	, l_latest_end_dates_tbl
	, l_cal_info_exists_tbl
	FROM fii_time_cal_name cal
	, PJI_TIME_CAL_EXTR_INFO info
	WHERE 1=1
	AND cal.calendar_id = info.calendar_id (+)
	AND cal.calendar_id = NVL(l_calendar_id,cal.calendar_id)
	AND cal.period_set_name = NVL(p_period_set_name,cal.period_set_name)
	AND cal.period_type = NVL(p_period_type,cal.period_type);

	--load week
	/*
	** Defer the coding of week logic.
	*/
	/*
	IF g_cal_info_exists = 'N' THEN
		LOAD_WEEK(g_earliest_start_date, g_latest_end_date);
	ELSE
		LOAD_WEEK(g_earliest_start_date, g_latest_end_date);
		LOAD_WEEK(g_earliest_start_date, g_latest_end_date);
	END IF;
	*/

	BEGIN
		l_process_ent_flag:='Y';
		INIT;
	EXCEPTION
		WHEN G_LOGIN_INFO_NOT_FOUND OR G_BIS_PARAMETER_NOT_SETUP THEN
			l_process_ent_flag:='N';
			NULL;
	END;

	IF g_debug_flag = 'Y' THEN
		pji_utils.write2log(' ');
		pji_utils.write2log('Processing Enterprise calendar.');
		START_TIMER;
      END IF;

	IF l_process_ent_flag='Y' AND LOAD_ENT_PERIOD THEN
		IF g_debug_flag = 'Y' THEN
			STOP_TIMER;
			PRINT_TIMER('Process Time for Enterprise Period API');
			START_TIMER;
	      END IF;

		LOAD_ENT_QTR;
		IF g_debug_flag = 'Y' THEN
			STOP_TIMER;
			PRINT_TIMER('Process Time for Enterprise Quarter API');
			START_TIMER;
	      END IF;

		LOAD_ENT_YEAR;
		IF g_debug_flag = 'Y' THEN
			STOP_TIMER;
			PRINT_TIMER('Process Time for Enterprise Year API');
			START_TIMER;
	      END IF;

		LOAD_TIME_RPT_STRUCT;
		IF g_debug_flag = 'Y' THEN
			STOP_TIMER;
			PRINT_TIMER('Process Time for Enterprise Reporting Structures API');
			pji_utils.write2log(' ');
		END IF;
	ELSE
		IF g_debug_flag = 'Y' THEN
			STOP_TIMER;
			PRINT_TIMER('Process Time for Enterprise Period API');
			pji_utils.write2log('No further changes to extract for enterprise calendar.'||
						 'Skipping Quarter, Year and Reporting Struct APIs.');
			pji_utils.write2log(' ');
		END IF;
	END IF;

	IF l_calendar_ids_tbl.COUNT > 0 THEN
		FOR i IN l_calendar_ids_tbl.FIRST..l_calendar_ids_tbl.LAST
		LOOP
			IF g_debug_flag = 'Y' THEN
				pji_utils.write2log('Processing Fiscal calendar '||l_period_set_name_tbl(i)||
							'('||l_period_type_tbl(i)||').');
				START_TIMER;
			END IF;
			IF LOAD_CAL_PERIOD( l_calendar_ids_tbl(i)
				, l_period_set_name_tbl(i)
				, l_period_type_tbl(i)
				, l_earliest_start_dates_tbl(i)
				, l_latest_end_dates_tbl(i)
				, l_cal_info_exists_tbl(i)
				, l_min_date) THEN
				IF g_debug_flag = 'Y' THEN
					STOP_TIMER;
					PRINT_TIMER('Process Time for Fiscal Period API');
					START_TIMER;
			      END IF;

				LOAD_CAL_QUARTER(l_calendar_ids_tbl(i)
				, l_earliest_start_dates_tbl(i)
				, l_latest_end_dates_tbl(i)
				, l_cal_info_exists_tbl(i));
				IF g_debug_flag = 'Y' THEN
					STOP_TIMER;
					PRINT_TIMER('Process Time for Fiscal Quarter API');
					START_TIMER;
			      END IF;

				LOAD_CAL_YEAR(l_calendar_ids_tbl(i)
				, l_earliest_start_dates_tbl(i)
				, l_latest_end_dates_tbl(i)
				, l_cal_info_exists_tbl(i));
				IF g_debug_flag = 'Y' THEN
					STOP_TIMER;
					PRINT_TIMER('Process Time for Fiscal Year API');
					START_TIMER;
				END IF;

				LOAD_TIME_CAL_RPT_STRUCT(l_calendar_ids_tbl(i)
				, l_earliest_start_dates_tbl(i)
				, l_min_date
				, l_cal_info_exists_tbl(i));
				IF g_debug_flag = 'Y' THEN
					STOP_TIMER;
					PRINT_TIMER('Process Time for Fiscal Reporting Structures API');
					pji_utils.write2log(' ');
				END IF;
			ELSE
				IF g_debug_flag = 'Y' THEN
					STOP_TIMER;
					PRINT_TIMER('Process Time for Fiscal Period API');
					pji_utils.write2log('No further changes to extract for this calendar. '||
					 'Skipping Quarter, Year and Reporting Struct APIs...');
					pji_utils.write2log(' ');
				END IF;
			END IF;
			NULL;
		END LOOP;
	END IF;
	x_return_status:=Fnd_Api.G_RET_STS_SUCCESS;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		pji_utils.write2log(' ');
		pji_utils.write2log(' ');
		x_return_status:=Fnd_Api.G_RET_STS_SUCCESS;
		ROLLBACK;
END LOAD;

BEGIN
	NULL;
	--INIT;
END PJI_TIME_C;

/

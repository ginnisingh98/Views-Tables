--------------------------------------------------------
--  DDL for Package Body MSC_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CALENDAR" AS
/* $Header: MSCCALDB.pls 120.4 2008/01/04 11:04:31 sbnaik ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

--  Global Static variables
  MSC_CALENDAR_RET_DATES    NUMBER := 0;
  msc_calendar_cal_code     VARCHAR2(14) := '17438gdjh';
  msc_calendar_excep_set    NUMBER := -23453;
  min_date                  DATE;
  max_date                  DATE;
  min_week_date             DATE;
  max_week_date             DATE;
  min_period_date           DATE;
  max_period_date           DATE;
  min_seq_num               NUMBER;
  max_seq_num               NUMBER;
  min_week_seq_num          NUMBER;
  max_week_seq_num          NUMBER;

  var_return_date        DATE;
  var_prev_work_day      DATE;
  var_prev_work_day2     DATE;
  var_prev_seq_num   NUMBER;
  var_prev_seq_num2      NUMBER;
  var_return_number      NUMBER;
  var_string_buffer      CHAR(1);
  var_calendar_code      VARCHAR2(14);
  var_exception_set_id   NUMBER;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE MSC_CAL_INIT_GLOBAL(  arg_calendar_code       VARCHAR,
                                arg_exception_set_id    NUMBER,
				arg_instance_id NUMBER) IS
    temp_char   VARCHAR2(30);
BEGIN

    IF arg_calendar_code <> msc_calendar_cal_code OR
        arg_exception_set_id <> msc_calendar_excep_set THEN

        SELECT  min(calendar_date), max(calendar_date), min(seq_num),
                    max(seq_num)
        INTO    min_date, max_date, min_seq_num, max_seq_num
        FROM    msc_calendar_dates
        WHERE   calendar_code = arg_calendar_code
        AND     seq_num is not null
        AND     exception_set_id = arg_exception_set_id
	AND     sr_instance_id = arg_instance_id;

        SELECT  min(period_start_date), max(period_start_date)
        INTO    min_period_date, max_period_date
        FROM    msc_period_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id
	AND     sr_instance_id = arg_instance_id;

        SELECT  min(week_start_date), max(week_start_date), min(seq_num),
                max(seq_num)
        INTO    min_week_date, max_week_date, min_week_seq_num,
                max_week_seq_num
        FROM    msc_cal_week_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id
	AND     sr_instance_id = arg_instance_id	;

        msc_calendar_cal_code := arg_calendar_code;
        msc_calendar_excep_set := arg_exception_set_id;
    END IF;

    IF MSC_CALENDAR_RET_DATES = 0 THEN

        temp_Char := FND_PROFILE.VALUE('MRP_RETAIN_DATES_WTIN_CAL_BOUNDARY');
        IF temp_Char = 'Y' THEN
            MSC_CALENDAR_RET_DATES := 1;
        ELSE
            MSC_CALENDAR_RET_DATES := 2;
        END IF;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-CALENDAR NOT COMPILED');
            APP_EXCEPTION.RAISE_EXCEPTION;
END MSC_CAL_INIT_GLOBAL;

FUNCTION MSC_CALC_PERIOD_OFFSET(arg_date            IN DATE,
                                arg_offset          IN NUMBER,
                                arg_calendar_code   IN VARCHAR2,
                                arg_exception_set_id IN NUMBER,
				arg_instance_id   IN NUMBER) RETURN DATE IS
  var_abs_number     NUMBER;
BEGIN

    IF arg_offset > 0 THEN
      DECLARE CURSOR C1 IS
      SELECT  period_start_date
      FROM    msc_period_start_dates cal
      WHERE   cal.exception_set_id = var_exception_set_id
        AND   cal.calendar_code = var_calendar_code
        AND   cal.period_start_date > TRUNC(arg_date)
	AND   cal.sr_instance_id = arg_instance_id
      ORDER BY period_start_date;
    BEGIN
    -- Round up to next integer
    var_abs_number := CEIL(arg_offset);
        OPEN C1;
        LOOP
          FETCH C1 INTO var_return_date;
          IF C1%ROWCOUNT = var_abs_number THEN
                EXIT;
          END IF;
        END LOOP;
        CLOSE C1;
    END;

    ELSE
      DECLARE CURSOR C1 IS
      SELECT  period_start_date
      FROM    msc_period_start_dates cal
      WHERE   cal.exception_set_id = var_exception_set_id
        AND   cal.calendar_code = var_calendar_code
        AND   cal.period_start_date < TRUNC(arg_date)
	AND   cal.sr_instance_id = arg_instance_id
      ORDER BY period_start_date DESC;

    BEGIN
    -- Round up to next integer
    var_abs_number := CEIL(ABS(arg_offset));
        OPEN C1;
        LOOP
          FETCH C1 INTO var_return_date;
          IF C1%ROWCOUNT = var_abs_number THEN
                EXIT;
          END IF;
        END LOOP;
        CLOSE C1;
    END;
    END IF;
    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END;

FUNCTION MSC_CALC_DATE_OFFSET(arg_seq_num         IN NUMBER,
                              arg_offset          IN NUMBER,
                              arg_calendar_code   IN VARCHAR2,
                              arg_exception_set_id IN NUMBER,
			      arg_instance_id IN NUMBER) RETURN DATE IS
l_arg_offset    number;
BEGIN

    -- Round up to next integer
    IF arg_offset >= 0 THEN
       l_arg_offset := CEIL(arg_offset);
    ELSE
       l_arg_offset := -1 * CEIL(ABS(arg_offset));
    END IF;

    BEGIN
        SELECT calendar_date
        INTO   var_return_date
        FROM   msc_calendar_dates  cal
        WHERE  cal.exception_set_id = var_exception_set_id
          AND  cal.calendar_code = var_calendar_code
          AND  cal.seq_num = arg_seq_num + l_arg_offset
          --AND  cal.seq_num = arg_seq_num + arg_offset
	  AND  cal.sr_instance_id = arg_instance_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF MSC_CALENDAR_RET_DATES = 1
            THEN
                IF arg_offset > 0 THEN
                    var_return_date := max_date;
                ELSE
                    var_return_date := min_date;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
    END;
    return var_return_date;
END;

FUNCTION MSC_CALC_WEEK_OFFSET(arg_seq_num        IN NUMBER,
                             arg_offset          IN NUMBER,
                             arg_calendar_code   IN VARCHAR2,
                             arg_exception_set_id IN NUMBER,
			     arg_instance_id IN NUMBER) RETURN DATE IS
l_arg_offset    number;
BEGIN

    -- Round up to next integer
    IF arg_offset >= 0 THEN
       l_arg_offset := CEIL(arg_offset);
    ELSE
       l_arg_offset := -1 * CEIL(ABS(arg_offset));
    END IF;

    BEGIN
        SELECT week_start_date
        INTO   var_return_date
        FROM   msc_cal_week_start_dates  cal
        WHERE  cal.exception_set_id = var_exception_set_id
          AND  cal.calendar_code = var_calendar_code
          AND  cal.seq_num = arg_seq_num + l_arg_offset
	  AND  cal.sr_instance_id = arg_instance_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF MSC_CALENDAR_RET_DATES = 1
            THEN
                IF arg_offset > 0 THEN
                    var_return_date := max_week_date;
                ELSE
                    var_return_date := min_week_date;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
    END;

    return var_return_date;
END;

/*---------------------------- PUBLIC ROUTINES ------------------------------*/

FUNCTION NEXT_WORK_DAY(arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN

   IF arg_date is NULL or arg_org_id is NULL OR arg_instance_id IS NULL or arg_bucket is NULL THEN
        RETURN NULL;
   END IF;
   msc_calendar.select_calendar_defaults(arg_org_id,arg_instance_id,
            var_calendar_code, var_exception_set_id);


    MSC_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id,arg_instance_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN

        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_date THEN
            var_return_date := max_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.next_date
            INTO    var_return_date
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id;
        END IF;

    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MIN(cal.week_start_date)
            INTO    var_return_date
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date >= TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id ;
        END IF;

    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_period_date THEN
            var_return_date := max_period_date;

        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_period_date THEN
            var_return_date := min_period_date;

	 ELSE
            SELECT  MIN(cal.period_start_date)
            INTO    var_return_date
            FROM    msc_period_start_dates  cal
             WHERE  cal.exception_set_id = var_exception_set_id
               AND  cal.calendar_code = var_calendar_code
               AND  cal.period_start_date >= TRUNC(arg_date)
	       AND   cal.sr_instance_id = arg_instance_id;

        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END NEXT_WORK_DAY;

FUNCTION PREV_WORK_DAY(arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN
   IF arg_date is NULL or arg_org_id is NULL OR arg_instance_id IS NULL OR arg_bucket is NULL THEN
        RETURN NULL;
   END IF;
    msc_calendar.select_calendar_defaults(arg_org_id,arg_instance_id,
            var_calendar_code, var_exception_set_id);

    MSC_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id,arg_instance_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_date := max_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.prior_date
            INTO    var_return_date
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id;
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MAX(cal.week_start_date)
            INTO    var_return_date
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id;
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_period_date THEN
            var_return_date := min_period_date;
        ELSE
            SELECT  MAX(cal.period_start_date)
            INTO    var_return_date
            FROM    msc_period_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.period_start_date <= TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id;
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END PREV_WORK_DAY;

FUNCTION NEXT_WORK_DAY_SEQNUM(arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN NUMBER IS
BEGIN
    msc_calendar.select_calendar_defaults(arg_org_id,arg_instance_id,
            var_calendar_code, var_exception_set_id);

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_date THEN
            var_return_number := max_seq_num;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  cal.next_seq_num
            INTO    var_return_number
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id ;
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_week_date THEN
            var_return_number := max_week_seq_num;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_week_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  MIN(cal.seq_num)
            INTO    var_return_number
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date >= TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id ;
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        raise_application_error(-20000, 'Invalid bucket type');
    END IF;
    return var_return_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END NEXT_WORK_DAY_SEQNUM;

FUNCTION PREV_WORK_DAY_SEQNUM(arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN NUMBER IS
BEGIN
    msc_calendar.select_calendar_defaults(arg_org_id, arg_instance_id,
            var_calendar_code, var_exception_set_id);

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_number := max_seq_num;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  cal.prior_seq_num
            INTO    var_return_number
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id ;
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_number := max_week_seq_num;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_number := min_week_seq_num;
        ELSE
            SELECT  MAX(cal.seq_num)
            INTO    var_return_number
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id ;
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        raise_application_error(-20000, 'Invalid bucket type');
    END IF;

    return var_return_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END PREV_WORK_DAY_SEQNUM;

FUNCTION DATE_OFFSET(  arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE,
                       arg_offset IN NUMBER) RETURN DATE IS
l_arg_offset    number;
BEGIN
    IF arg_date IS NULL or arg_org_id is NULL OR arg_instance_id IS NULL or arg_bucket is NULL or
            arg_offset is null THEN
        RETURN NULL;
    END IF;
    IF arg_offset = 0 THEN
        var_prev_work_day := PREV_WORK_DAY(arg_org_id, arg_instance_id, 1, arg_date);
    return var_prev_work_day;
    END IF;

    msc_calendar.select_calendar_defaults(arg_org_id, arg_instance_id,
            var_calendar_code, var_exception_set_id);

    MSC_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id,arg_instance_id);

    -- Round up to next integer
    IF arg_offset >= 0 THEN
       l_arg_offset := CEIL(arg_offset);
    ELSE
       l_arg_offset := -1 * CEIL(ABS(arg_offset));
    END IF;

    IF arg_bucket = TYPE_DAILY_BUCKET OR arg_bucket = TYPE_WEEKLY_BUCKET
    THEN
        -- (3335127) New offset logic. Done along with Enforce Pur LT changes
        IF arg_offset > 0 THEN
            var_prev_seq_num :=
                 PREV_WORK_DAY_SEQNUM(arg_org_id, arg_instance_id, arg_bucket, arg_date);
        ELSE
            var_prev_seq_num :=
                 NEXT_WORK_DAY_SEQNUM(arg_org_id, arg_instance_id, arg_bucket, arg_date);
        END IF;
    END IF;

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
           var_return_date := msc_calc_date_offset(var_prev_seq_num,
                l_arg_offset, var_calendar_code, var_exception_set_id,
		arg_instance_id);
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
           var_return_date := msc_calc_week_offset(var_prev_seq_num,
                l_arg_offset, var_calendar_code, var_exception_set_id,
		arg_instance_id);
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
           -- (3335127) New offset logic. Done along with Enforce Pur LT changes
           -- Not sure who calls this API with anything other than daily bucket. Making the change nonetheless.
           IF arg_offset > 0 THEN
                var_prev_work_day := PREV_WORK_DAY(arg_org_id, arg_instance_id, arg_bucket, arg_date);
           ELSE
                var_prev_work_day := NEXT_WORK_DAY(arg_org_id, arg_instance_id, arg_bucket, arg_date);
           END IF;
           var_return_date := msc_calc_period_offset(var_prev_work_day,
                l_arg_offset, var_calendar_code, var_exception_set_id,
		arg_instance_id);
    END IF;

    return var_return_date;
END DATE_OFFSET;

FUNCTION DAYS_BETWEEN( arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date1 IN DATE,
                       arg_date2 IN DATE) RETURN NUMBER IS
BEGIN
    msc_calendar.select_calendar_defaults(arg_org_id, arg_instance_id,
            var_calendar_code, var_exception_set_id);

    IF arg_date1 is NULL or arg_bucket is null or arg_org_id is NULL OR arg_instance_id IS NULL
        or arg_date2 IS NULL THEN
        RETURN NULL;
    END IF;

    MSC_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id,arg_instance_id);
    IF (arg_bucket <> TYPE_MONTHLY_BUCKET) THEN
      var_prev_seq_num := PREV_WORK_DAY_SEQNUM(arg_org_id, arg_instance_id, arg_bucket, arg_date1);
      var_prev_seq_num2 := PREV_WORK_DAY_SEQNUM(arg_org_id, arg_instance_id, arg_bucket, arg_date2);
      var_return_number := ABS(var_prev_seq_num2 - var_prev_seq_num);
    ELSE
      var_prev_work_day := PREV_WORK_DAY(arg_org_id, arg_instance_id, arg_bucket, arg_date1);
      var_prev_work_day2 := PREV_WORK_DAY(arg_org_id, arg_instance_id, arg_bucket, arg_date2);
      SELECT count(period_start_date)
      INTO var_return_number
      FROM msc_period_start_dates cal
      WHERE cal.exception_set_id = var_exception_set_id
      AND   cal.calendar_code = var_calendar_code
      AND   cal.period_start_date between var_prev_work_day
        and var_prev_work_day2
      AND   cal.period_start_date <> var_prev_work_day2
      AND   cal.sr_instance_id = arg_instance_id ;

    END IF;

    return var_return_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END DAYS_BETWEEN;

PROCEDURE select_calendar_defaults(
				   arg_org_id IN NUMBER,
				   arg_instance_id IN NUMBER,
				   arg_calendar_code OUT NOCOPY VARCHAR2,
				   arg_exception_set_id OUT NOCOPY NUMBER) IS
l_org_id    number;
BEGIN
  l_org_id := arg_org_id;
 /* --------------------------------------------------------------+
 |  arg_org_id will be -ve if the call is for Planning Bucketing  |
 |  If the profile is defined MSC_BKT_REFERENCE_CALENDAR then use |
 |  it for Bucketing.                                             |
 +--------------------------------------------------------------- */
 IF l_org_id < 0 AND G_VAR_BKT_REFERENCE_CALENDAR <> '-23453' THEN
          arg_calendar_code := G_VAR_BKT_REFERENCE_CALENDAR;
          arg_exception_set_id := -1;
 ELSE
   IF l_org_id < 0 THEN
      l_org_id := -1 * l_org_id;
   END IF;
   SELECT
     calendar_code,
     calendar_exception_set_id
   INTO     arg_calendar_code,
            arg_exception_set_id
   FROM     msc_trading_partners
   WHERE    sr_tp_id = l_org_id
   AND		partner_type = 3
   AND      sr_instance_id = arg_instance_id;

    IF SQL%NOTFOUND THEN
        raise_application_error(-200000, 'Cannot select calendar defaults');
    END IF;
 END IF;

END select_calendar_defaults;

-----------------------------------------------------------------------
-- FUNCTION PREV_DELIVERY_CALENDAR_DAY
-- for publish order process
-----------------------------------------------------------------------
FUNCTION PREV_DELIVERY_CALENDAR_DAY (arg_calendar_code IN VARCHAR2,
				     arg_instance_id IN NUMBER,
				     arg_exception_set_id IN NUMBER,
				     arg_date IN DATE,
				     arg_bucket IN NUMBER) RETURN DATE IS
var_date		date;
var_return_date		date;

BEGIN
   IF arg_calendar_code is NULL OR arg_date is NULL OR arg_instance_id IS NULL THEN
       RETURN NULL;
   END IF;

    MSC_CAL_INIT_GLOBAL(arg_calendar_code, arg_exception_set_id ,arg_instance_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_date := max_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.prior_date
            INTO    var_return_date
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = arg_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id;
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;


END prev_delivery_calendar_day;

----------------------------------------------------------------------
-- CALENDAR_CAL_INIT_GLOBAL (private proc) to fix bug# 2678523
-- Calendar code is an argument
----------------------------------------------------------------------
PROCEDURE CALENDAR_CAL_INIT_GLOBAL(  arg_calendar_code       VARCHAR,
                                arg_exception_set_id    NUMBER) IS
    temp_char   VARCHAR2(30);
BEGIN


    IF arg_calendar_code <> msc_calendar_cal_code OR
        arg_exception_set_id <> msc_calendar_excep_set THEN

        SELECT  min(calendar_date), max(calendar_date), min(seq_num),
                    max(seq_num)
        INTO    min_date, max_date, min_seq_num, max_seq_num
        FROM    msc_calendar_dates
        WHERE   calendar_code = arg_calendar_code
        AND     seq_num is not null
        AND     exception_set_id = arg_exception_set_id;

        SELECT  min(period_start_date), max(period_start_date)
        INTO    min_period_date, max_period_date
        FROM    msc_period_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id;

        SELECT  min(week_start_date), max(week_start_date), min(seq_num),
                max(seq_num)
        INTO    min_week_date, max_week_date, min_week_seq_num,
                max_week_seq_num
        FROM    msc_cal_week_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id	;

        msc_calendar_cal_code := arg_calendar_code;
        msc_calendar_excep_set := arg_exception_set_id;
    END IF;

    IF MSC_CALENDAR_RET_DATES = 0 THEN

        temp_Char := FND_PROFILE.VALUE('MRP_RETAIN_DATES_WTIN_CAL_BOUNDARY');
        IF temp_Char = 'Y' THEN
            MSC_CALENDAR_RET_DATES := 1;
        ELSE
            MSC_CALENDAR_RET_DATES := 2;
        END IF;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-CALENDAR NOT COMPILED');
            APP_EXCEPTION.RAISE_EXCEPTION;
END CALENDAR_CAL_INIT_GLOBAL;

----------------------------------------------------------------------
-- CALENDAR_NEXT_WORK_DAY to fix bug# 2678523
-- Calendar code is an argument
----------------------------------------------------------------------
FUNCTION CALENDAR_NEXT_WORK_DAY(arg_instance_id IN NUMBER,
			arg_calendar_code IN VARCHAR2,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS


BEGIN

var_exception_set_id := -1;

   IF arg_date is NULL OR arg_bucket is NULL OR arg_calendar_code IS NULL or arg_instance_id is NULL THEN
        RETURN NULL;
   END IF;

    /* For bug# 3532912, changed the calendar initialization call */
--    CALENDAR_CAL_INIT_GLOBAL(arg_calendar_code, var_exception_set_id);
    MSC_CAL_INIT_GLOBAL(arg_calendar_code, var_exception_set_id,arg_instance_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN

        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_date THEN
            var_return_date := max_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.next_date
            INTO    var_return_date
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;

    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MIN(cal.week_start_date)
            INTO    var_return_date
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.week_start_date >= TRUNC(arg_date) ;
        END IF;

    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date >= max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date < min_period_date THEN
            var_return_date := min_period_date;
	 ELSE
            SELECT  MIN(cal.period_start_date)
            INTO    var_return_date
            FROM    msc_period_start_dates  cal
             WHERE  cal.exception_set_id = var_exception_set_id
               AND  cal.calendar_code = arg_calendar_code
               AND  cal.period_start_date >= TRUNC(arg_date);

        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END CALENDAR_NEXT_WORK_DAY;

--------------------------------------------------------------------------
-- CALENDAR_PREV_WORK_DAYto fix bug# 2678523
-- Calendar code is an argument
--------------------------------------------------------------------------
FUNCTION CALENDAR_PREV_WORK_DAY(arg_instance_id IN NUMBER,
			arg_calendar_code IN VARCHAR2,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN
var_exception_set_id := -1;

   IF arg_date is NULL  OR arg_instance_id IS NULL OR arg_bucket is NULL THEN
        RETURN NULL;
   END IF;


    CALENDAR_CAL_INIT_GLOBAL(arg_calendar_code, var_exception_set_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_date := max_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.prior_date
            INTO    var_return_date
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MAX(cal.week_start_date)
            INTO    var_return_date
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date)
	      AND   cal.sr_instance_id = arg_instance_id;
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_period_date THEN
            var_return_date := min_period_date;
        ELSE
            SELECT  MAX(cal.period_start_date)
            INTO    var_return_date
            FROM    msc_period_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.period_start_date <= TRUNC(arg_date);
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END CALENDAR_PREV_WORK_DAY;

--------------------------------------------------------------------------
-- CALENDAR_PREV_WORK_DAY_SEQNUM to fix bug# 2678523
-- Calendar code is an argument
--------------------------------------------------------------------------
FUNCTION CALENDAR_PREV_WORK_DAY_SEQNUM(arg_instance_id IN NUMBER,
		       arg_calendar_code IN VARCHAR2,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN NUMBER IS
BEGIN

var_exception_set_id := -1;


    IF arg_bucket = TYPE_DAILY_BUCKET THEN
    --dbms_output.put_line('Max date: ' || max_date || ' Min date: ' || min_date ||' Arg date: ' || arg_date);
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_number := max_seq_num;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  cal.prior_seq_num
            INTO    var_return_number
            FROM    msc_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;

    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MSC_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_number := max_week_seq_num;
        ELSIF MSC_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_number := min_week_seq_num;
        ELSE
            SELECT  MAX(cal.seq_num)
            INTO    var_return_number
            FROM    msc_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = arg_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date) ;
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        raise_application_error(-20000, 'Invalid bucket type');
    END IF;

    return var_return_number;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END CALENDAR_PREV_WORK_DAY_SEQNUM;

------------------------------------------------------------------------
-- CALENDAR_DAYS_BETWEEN to fix bug# 2678523
-- Calendar code is an argument
-------------------------------------------------------------------------
FUNCTION CALENDAR_DAYS_BETWEEN(arg_instance_id IN NUMBER,
			arg_calendar_code IN VARCHAR2,
                        arg_bucket IN NUMBER,
                        arg_date1 IN DATE,
                        arg_date2 IN DATE) RETURN NUMBER IS


BEGIN

	SELECT COUNT(*)
	INTO  	var_return_number
	FROM	msc_calendar_dates
	WHERE   sr_instance_id = arg_instance_id
	AND	calendar_code = arg_calendar_code
	AND	exception_set_id = -1
	AND 	seq_num is not null
	AND 	calendar_date between arg_date1 and arg_date2;

--FND_FILE.PUT_LINE(FND_FILE.LOG, 'SR ' || arg_instance_id || ' Return number days ' || var_return_number);
	IF var_return_number = 0 THEN
		var_return_number := null;
	END IF;

    	return var_return_number;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END CALENDAR_DAYS_BETWEEN;

/*--------------------------------------------------------------------------
|  Begin Functions added for ship_rec_cal project
+-------------------------------------------------------------------------*/

/* To be used by ATP. Wrapper on Get_Calendar_Code*/
FUNCTION Get_Calendar_Code(
			p_instance_id		IN      number,
			p_plan_id		IN      number,
			p_inventory_item_id	IN      number,
			p_partner_id		IN      number,
			p_partner_site_id	IN      number,
			p_partner_type		IN      number,
			p_organization_id	IN      number,
			p_ship_method_code	IN      varchar2,
			p_calendar_type  	IN      integer
			) RETURN VARCHAR2
IS
        l_association_type      NUMBER;
        l_calendar_code		VARCHAR2(14);
BEGIN
        l_calendar_code := Get_Calendar_Code(
                           p_instance_id,
                           p_plan_id,
                           p_inventory_item_id,
                           p_partner_id,
                           p_partner_site_id,
			   p_partner_type,
			   p_organization_id,
			   p_ship_method_code,
			   p_calendar_type,
			   l_association_type);

	RETURN  l_calendar_code;
END Get_Calendar_Code;

/* Added this function to be called directly by UI. This has association_type as an additional out parameter*/
FUNCTION Get_Calendar_Code(
                p_instance_id           IN      number,
                p_plan_id               IN      number,
                p_inventory_item_id     IN      number,
                p_partner_id            IN      number,
                p_partner_site_id       IN      number,
                p_partner_type          IN      number,
                p_organization_id       IN      number,
                p_ship_method_code      IN      varchar2,
                p_calendar_type         IN      integer,
                p_association_type      OUT     NOCOPY NUMBER
) RETURN VARCHAR2
IS
        l_calendar_type         VARCHAR2(15);
        l_calendar_code         VARCHAR2(14)    := MSC_CALENDAR.FOC;
	l_ship_method_code	VARCHAR2(50)	:= NVL(p_ship_method_code, '@@@');
	l_partner_site_id	NUMBER		:= NVL(p_partner_site_id, -1);
        C_ORGANIZATION          CONSTANT NUMBER := 3;
        C_ITEM_VENDOR           CONSTANT NUMBER := 12;
        C_ITEM_VENDOR_SITE      CONSTANT NUMBER := 13;

BEGIN
        IF PG_DEBUG in ('Y','C') THEN
                msc_sch_wb.atp_debug ('***** Begin Function Get_Calendar_Code *****');
                msc_sch_wb.atp_debug ('________________Input________________');
                msc_sch_wb.atp_debug (' Instance ID      : ' || p_instance_id );
                msc_sch_wb.atp_debug (' Plan ID          : ' || p_plan_id );
                msc_sch_wb.atp_debug (' Inv Item ID      : ' || p_inventory_item_id);
                msc_sch_wb.atp_debug (' Partner ID       : ' || p_partner_id );
                msc_sch_wb.atp_debug (' Partner Site ID  : ' || p_partner_site_id );
                msc_sch_wb.atp_debug (' Partner Type     : ' || p_partner_type);
                msc_sch_wb.atp_debug (' Organization ID  : ' || p_organization_id);
                msc_sch_wb.atp_debug (' Ship Method Code : ' || p_ship_method_code);
                msc_sch_wb.atp_debug (' Calendar Type    : ' || p_calendar_type);
                msc_sch_wb.atp_debug ('G_USE_SHIP_REC_CAL: ' || MSC_ATP_PVT.G_USE_SHIP_REC_CAL);
                msc_sch_wb.atp_debug (' ');
        END IF;

        -- case 1. Searching for a valid suplier's shipping calendar (SSC) or valid customer receiving calendar (CRC)
        IF (p_calendar_type = MSC_CALENDAR.SSC OR p_calendar_type = MSC_CALENDAR.CRC) THEN

            -- Bug 3593394
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- l_calendar_code is already initialized to FOC

                -- For SSC p_partner_type = 1, for CRC p_partner_type = 2
                IF p_calendar_type = MSC_CALENDAR.CRC THEN
                        l_calendar_type := 'RECEIVING';
                ELSE
                        l_calendar_type := 'SHIPPING';
                END IF;

                SELECT  calendar_code, association_type
                INTO    l_calendar_code, p_association_type
                FROM    (SELECT calendar_code, association_type
                        FROM    MSC_CALENDAR_ASSIGNMENTS
                        WHERE   SR_INSTANCE_ID  = p_instance_id
                        AND     CALENDAR_TYPE in (l_calendar_type, 'CARRIER')
                        AND     PARTNER_TYPE    = p_partner_type
                        AND     PARTNER_ID      = p_partner_id
                        AND     NVL(PARTNER_SITE_ID, l_partner_site_id) = l_partner_site_id
                        AND     NVL(SHIP_METHOD_CODE, l_ship_method_code) = l_ship_method_code
                        ORDER BY ASSOCIATION_LEVEL)
                WHERE   ROWNUM = 1;

            END IF;

        -- case 2. Searching for valid Org's Receiving Calendar (ORC) or Org's Shipping Calendar (OSC)
        ELSIF (p_calendar_type = MSC_CALENDAR.ORC OR p_calendar_type = MSC_CALENDAR.OSC)
                AND p_organization_id IS NOT NULL THEN -- Condition added to handle scheduling cases where both
                                                       -- org and customer are NULL. Done with Enforce Pur LT changes.

            -- Bug 3593394
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN

                IF p_calendar_type = MSC_CALENDAR.ORC THEN
                        l_calendar_type := 'RECEIVING';
                ELSE
                        l_calendar_type := 'SHIPPING';
                END IF;

                SELECT  calendar_code, association_type
                INTO    l_calendar_code, p_association_type
                FROM    (SELECT calendar_code, association_type
                        FROM    MSC_CALENDAR_ASSIGNMENTS
                        WHERE   SR_INSTANCE_ID          = p_instance_id
                        AND     CALENDAR_TYPE in (l_calendar_type, 'CARRIER')
                        AND     ORGANIZATION_ID         = p_organization_id
                        AND     NVL(SHIP_METHOD_CODE, l_ship_method_code) = l_ship_method_code
                        ORDER BY ASSOCIATION_LEVEL)
                WHERE        ROWNUM = 1;

            ELSE

                -- Bug 3647208 - For b/w compatibility use OMC instead of ORC/OSC
                -- Raise exception so that the OMC query gets executed.
                IF PG_DEBUG in ('Y','C') THEN
                    msc_sch_wb.atp_debug ('Get_Calendar_Code :' || ' Use OMC instead on ORC/OSC');
                END IF;
                RAISE NO_DATA_FOUND;

            END IF;

        -- case 3. Searching for valid Intransit Calendar (VIC)
        ELSIF (p_calendar_type = MSC_CALENDAR.VIC) THEN

            -- Bug 3593394
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- l_calendar_code is already initialized to FOC

                -- p_partner_type = 4
                SELECT  calendar_code, association_type
                INTO    l_calendar_code, p_association_type
                FROM    MSC_CALENDAR_ASSIGNMENTS
                WHERE   SR_INSTANCE_ID          = p_instance_id
                AND     PARTNER_TYPE            = p_partner_type
                AND     SHIP_METHOD_CODE        = l_ship_method_code;

            END IF;


        -- case 4. Searching for valid Suppliers Manufacturing Calendar (SMC)
        ELSIF (p_calendar_type = MSC_CALENDAR.SMC) THEN

                -- No change required for Bug 3593394 here as this procedure will not be called
                -- for supplier case if G_USE_SHIP_REC_CAL='Y'
                -- SELECT  delivery_calendar_code, association_type
                -- return FOC if ASL is defined but calendar is not associated.
                SELECT  NVL(delivery_calendar_code,MSC_CALENDAR.FOC), association_type
                INTO    l_calendar_code, p_association_type
                FROM    (SELECT delivery_calendar_code, decode(supplier_site_id,
                                                                      null, C_ITEM_VENDOR,
                                                                            C_ITEM_VENDOR_SITE) association_type
                        FROM    MSC_ITEM_SUPPLIERS
                        WHERE   SR_INSTANCE_ID          = p_instance_id
                        AND     PLAN_ID                 = p_plan_id
                        AND     INVENTORY_ITEM_ID       = p_inventory_item_id
                        AND     SUPPLIER_ID             = p_partner_id
                        AND     NVL(SUPPLIER_SITE_ID, l_partner_site_id) = l_partner_site_id
                        ORDER BY decode(supplier_site_id, null, C_ITEM_VENDOR, C_ITEM_VENDOR_SITE) desc
                        )
                WHERE        ROWNUM = 1;

        -- case 5. Searching for valid Orgs Manufacturing Calendar (OMC)
        ELSIF (p_calendar_type = MSC_CALENDAR.OMC) THEN

                SELECT  calendar_code, C_ORGANIZATION
                INTO    l_calendar_code, p_association_type
                FROM    MSC_TRADING_PARTNERS
                WHERE   SR_INSTANCE_ID  = p_instance_id
                AND     PARTNER_TYPE    = 3
                AND     SR_TP_ID        = p_organization_id;

        END IF;

        IF PG_DEBUG in ('Y','C') THEN
                msc_sch_wb.atp_debug ('________________Output________________');
                msc_sch_wb.atp_debug (' Calendar Code    : ' || l_calendar_code);
                msc_sch_wb.atp_debug (' Association Type : ' || p_association_type);
                msc_sch_wb.atp_debug (' ');
        END IF;

        RETURN        l_calendar_code;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                IF (p_calendar_type = MSC_CALENDAR.ORC OR p_calendar_type = MSC_CALENDAR.OSC) THEN
                        -- Return OMC.
                        SELECT  calendar_code, C_ORGANIZATION
                        INTO    l_calendar_code, p_association_type
                        FROM    MSC_TRADING_PARTNERS
                        WHERE   SR_INSTANCE_ID  = p_instance_id
                        AND     PARTNER_TYPE    = 3
                        AND     SR_TP_ID        = p_organization_id;
                END IF;

                IF PG_DEBUG in ('Y','C') THEN
                        msc_sch_wb.atp_debug ('****** No Data Found Exception *******');
                        msc_sch_wb.atp_debug ('________________Output________________');
                        msc_sch_wb.atp_debug (' Calendar Code    : ' || l_calendar_code);
                        msc_sch_wb.atp_debug (' Association Type : ' || p_association_type);
                        msc_sch_wb.atp_debug (' ');
                END IF;

                RETURN        l_calendar_code;

END Get_Calendar_Code;

/* Added this function to be called directly by UI/calendar window, with p_from_cal_window as an additional parameter*/
FUNCTION Get_Calendar_Code(
                p_instance_id           IN      number,
                p_plan_id               IN      number,
                p_inventory_item_id     IN      number,
                p_partner_id            IN      number,
                p_partner_site_id       IN      number,
                p_partner_type          IN      number,
                p_organization_id       IN      number,
                p_ship_method_code      IN      varchar2,
                p_calendar_type         IN      integer,
                p_from_cal_window       IN      integer,
                p_association_type      OUT     NOCOPY NUMBER
) RETURN VARCHAR2
IS
        l_calendar_type         VARCHAR2(15);
        l_calendar_code         VARCHAR2(14)    := MSC_CALENDAR.FOC;
	l_ship_method_code	VARCHAR2(50)	:= NVL(p_ship_method_code, '@@@');
	l_partner_site_id	NUMBER		:= NVL(p_partner_site_id, -1);
        C_ORGANIZATION          CONSTANT NUMBER := 3;
        C_ITEM_VENDOR           CONSTANT NUMBER := 12;
        C_ITEM_VENDOR_SITE      CONSTANT NUMBER := 13;

BEGIN
        IF PG_DEBUG in ('Y','C') THEN
                msc_sch_wb.atp_debug ('***** Begin Function Get_Calendar_Code *****');
                msc_sch_wb.atp_debug ('________________Input________________');
                msc_sch_wb.atp_debug (' Instance ID      : ' || p_instance_id );
                msc_sch_wb.atp_debug (' Plan ID          : ' || p_plan_id );
                msc_sch_wb.atp_debug (' Inv Item ID      : ' || p_inventory_item_id);
                msc_sch_wb.atp_debug (' Partner ID       : ' || p_partner_id );
                msc_sch_wb.atp_debug (' Partner Site ID  : ' || p_partner_site_id );
                msc_sch_wb.atp_debug (' Partner Type     : ' || p_partner_type);
                msc_sch_wb.atp_debug (' Organization ID  : ' || p_organization_id);
                msc_sch_wb.atp_debug (' Ship Method Code : ' || p_ship_method_code);
                msc_sch_wb.atp_debug (' Calendar Type    : ' || p_calendar_type);
                msc_sch_wb.atp_debug ('G_USE_SHIP_REC_CAL: ' || MSC_ATP_PVT.G_USE_SHIP_REC_CAL);
                msc_sch_wb.atp_debug (' ');
        END IF;

        -- case 1. Searching for a valid suplier's shipping calendar (SSC) or valid customer receiving calendar (CRC)
        IF (p_calendar_type = MSC_CALENDAR.SSC OR p_calendar_type = MSC_CALENDAR.CRC) THEN

            -- Bug 3593394
            --IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- l_calendar_code is already initialized to FOC

                -- For SSC p_partner_type = 1, for CRC p_partner_type = 2
                IF p_calendar_type = MSC_CALENDAR.CRC THEN
                        l_calendar_type := 'RECEIVING';
                ELSE
                        l_calendar_type := 'SHIPPING';
                END IF;

                SELECT  calendar_code, association_type
                INTO    l_calendar_code, p_association_type
                FROM    (SELECT calendar_code, association_type
                        FROM    MSC_CALENDAR_ASSIGNMENTS
                        WHERE   SR_INSTANCE_ID  = p_instance_id
                        AND     CALENDAR_TYPE in (l_calendar_type, 'CARRIER')
                        AND     PARTNER_TYPE    = p_partner_type
                        AND     PARTNER_ID      = p_partner_id
                        AND     NVL(PARTNER_SITE_ID, l_partner_site_id) = l_partner_site_id
                        AND     NVL(SHIP_METHOD_CODE, l_ship_method_code) = l_ship_method_code
                        ORDER BY ASSOCIATION_LEVEL)
                WHERE   ROWNUM = 1;
            --END IF;
        -- case 2. Searching for valid Org's Receiving Calendar (ORC) or Org's Shipping Calendar (OSC)
        ELSIF (p_calendar_type = MSC_CALENDAR.ORC OR p_calendar_type = MSC_CALENDAR.OSC)
                AND p_organization_id IS NOT NULL THEN -- Condition added to handle scheduling cases where both
                                                       -- org and customer are NULL. Done with Enforce Pur LT changes.

            -- Bug 3593394
            --IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                IF p_calendar_type = MSC_CALENDAR.ORC THEN
                        l_calendar_type := 'RECEIVING';
                ELSE
                        l_calendar_type := 'SHIPPING';
                END IF;
                SELECT  calendar_code, association_type
                INTO    l_calendar_code, p_association_type
                FROM    (SELECT calendar_code, association_type
                        FROM    MSC_CALENDAR_ASSIGNMENTS
                        WHERE   SR_INSTANCE_ID          = p_instance_id
                        AND     CALENDAR_TYPE in (l_calendar_type, 'CARRIER')
                        AND     ORGANIZATION_ID         = p_organization_id
                        AND     NVL(SHIP_METHOD_CODE, l_ship_method_code) = l_ship_method_code
                        ORDER BY ASSOCIATION_LEVEL)
                WHERE        ROWNUM = 1;
            /*ELSE
                -- Bug 3647208 - For b/w compatibility use OMC instead of ORC/OSC
                -- Raise exception so that the OMC query gets executed.
                IF PG_DEBUG in ('Y','C') THEN
                    msc_sch_wb.atp_debug ('Get_Calendar_Code :' || ' Use OMC instead on ORC/OSC');
                END IF;
                RAISE NO_DATA_FOUND;
            END IF;*/
        -- case 3. Searching for valid Intransit Calendar (VIC)
        ELSIF (p_calendar_type = MSC_CALENDAR.VIC) THEN
            -- Bug 3593394
            --IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- l_calendar_code is already initialized to FOC
                -- p_partner_type = 4
                SELECT  calendar_code, association_type
                INTO    l_calendar_code, p_association_type
                FROM    MSC_CALENDAR_ASSIGNMENTS
                WHERE   SR_INSTANCE_ID          = p_instance_id
                AND     PARTNER_TYPE            = p_partner_type
                AND     SHIP_METHOD_CODE        = l_ship_method_code;
            --END IF;
        -- case 4. Searching for valid Suppliers Manufacturing Calendar (SMC)
        ELSIF (p_calendar_type = MSC_CALENDAR.SMC) THEN
                -- No change required for Bug 3593394 here as this procedure will not be called
                -- for supplier case if G_USE_SHIP_REC_CAL='Y'
                -- SELECT  delivery_calendar_code, association_type
                -- return FOC if ASL is defined but calendar is not associated.
                SELECT  NVL(delivery_calendar_code,MSC_CALENDAR.FOC), association_type
                INTO    l_calendar_code, p_association_type
                FROM    (SELECT delivery_calendar_code, decode(supplier_site_id,
                                                                      null, C_ITEM_VENDOR,
                                                                            C_ITEM_VENDOR_SITE) association_type
                        FROM    MSC_ITEM_SUPPLIERS
                        WHERE   SR_INSTANCE_ID          = p_instance_id
                        AND     PLAN_ID                 = p_plan_id
                        AND     INVENTORY_ITEM_ID       = p_inventory_item_id
                        AND     SUPPLIER_ID             = p_partner_id
                        AND     NVL(SUPPLIER_SITE_ID, l_partner_site_id) = l_partner_site_id
                        ORDER BY decode(supplier_site_id, null, C_ITEM_VENDOR, C_ITEM_VENDOR_SITE) desc
                        )
                WHERE        ROWNUM = 1;
        -- case 5. Searching for valid Orgs Manufacturing Calendar (OMC)
        ELSIF (p_calendar_type = MSC_CALENDAR.OMC) THEN

                SELECT  calendar_code, C_ORGANIZATION
                INTO    l_calendar_code, p_association_type
                FROM    MSC_TRADING_PARTNERS
                WHERE   SR_INSTANCE_ID  = p_instance_id
                AND     PARTNER_TYPE    = 3
                AND     SR_TP_ID        = p_organization_id;
        END IF;
        IF PG_DEBUG in ('Y','C') THEN
                msc_sch_wb.atp_debug ('________________Output________________');
                msc_sch_wb.atp_debug (' Calendar Code    : ' || l_calendar_code);
                msc_sch_wb.atp_debug (' Association Type : ' || p_association_type);
                msc_sch_wb.atp_debug (' ');
        END IF;
        RETURN        l_calendar_code;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                IF (p_calendar_type = MSC_CALENDAR.ORC OR p_calendar_type = MSC_CALENDAR.OSC) THEN
                        -- Return OMC.
                        SELECT  calendar_code, C_ORGANIZATION
                        INTO    l_calendar_code, p_association_type
                        FROM    MSC_TRADING_PARTNERS
                        WHERE   SR_INSTANCE_ID  = p_instance_id
                        AND     PARTNER_TYPE    = 3
                        AND     SR_TP_ID        = p_organization_id;
                END IF;

                IF PG_DEBUG in ('Y','C') THEN
                        msc_sch_wb.atp_debug ('****** No Data Found Exception *******');
                        msc_sch_wb.atp_debug ('________________Output________________');
                        msc_sch_wb.atp_debug (' Calendar Code    : ' || l_calendar_code);
                        msc_sch_wb.atp_debug (' Association Type : ' || p_association_type);
                        msc_sch_wb.atp_debug (' ');
                END IF;

                RETURN        l_calendar_code;

END Get_Calendar_Code;

-- Overloaded Functions driven by calendar_code rather than org_id
FUNCTION NEXT_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_instance_id		IN number,
			p_calendar_date		IN date
			) RETURN DATE
IS
	l_next_work_day		DATE;
	l_first_work_day	DATE;
	l_last_work_day		DATE;
BEGIN
    IF (p_calendar_code IS NULL) OR
        (p_instance_id IS NULL) OR
            (p_calendar_date IS NULL) THEN
        --RETURN NULL; bug3583705
	RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
    END IF;

    IF (p_calendar_code = MSC_CALENDAR.FOC) THEN
        RETURN p_calendar_date;
    END IF;

    BEGIN
        SELECT  NEXT_DATE
        INTO    l_next_work_day
        FROM    MSC_CALENDAR_DATES
        WHERE   SR_INSTANCE_ID      = p_instance_id
        AND     CALENDAR_CODE       = p_calendar_code
        AND     EXCEPTION_SET_ID    = -1
        AND     CALENDAR_DATE       = TRUNC(p_calendar_date);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  FIRST_WORKING_DATE, LAST_WORKING_DATE
                    INTO    l_first_work_day, l_last_work_day
                    FROM    MSC_CALENDARS
                    WHERE   SR_INSTANCE_ID	= p_instance_id
                    AND     CALENDAR_CODE	= p_calendar_code;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_calendar_date >= l_last_work_day THEN
                    l_next_work_day := l_last_work_day;
                ELSIF p_calendar_date <= l_first_work_day THEN
                    l_next_work_day := l_first_work_day;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
    END;
    RETURN	l_next_work_day;

END NEXT_WORK_DAY;

FUNCTION PREV_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_instance_id		IN number,
			p_calendar_date		IN date
			) RETURN DATE
IS
	l_prev_work_day		DATE;
	l_first_work_day	DATE;
	l_last_work_day		DATE;
BEGIN
    IF (p_calendar_code IS NULL) OR
        (p_instance_id IS NULL) OR
            (p_calendar_date IS NULL) THEN
        --RETURN NULL; bug3583705
	RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
    END IF;

    IF p_calendar_code = MSC_CALENDAR.FOC THEN
        RETURN p_calendar_date;
    END IF;

    BEGIN
        SELECT  PRIOR_DATE
        INTO    l_prev_work_day
        FROM    MSC_CALENDAR_DATES
        WHERE   SR_INSTANCE_ID		= p_instance_id
        AND     CALENDAR_CODE		= p_calendar_code
        AND     EXCEPTION_SET_ID	= -1
        AND     CALENDAR_DATE		= TRUNC(p_calendar_date);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  FIRST_WORKING_DATE, LAST_WORKING_DATE
                    INTO    l_first_work_day, l_last_work_day
                    FROM    MSC_CALENDARS
                    WHERE   SR_INSTANCE_ID	= p_instance_id
                    AND     CALENDAR_CODE	= p_calendar_code;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_calendar_date >= l_last_work_day THEN
                    l_prev_work_day := l_last_work_day;
                ELSIF p_calendar_date <= l_first_work_day THEN
                    l_prev_work_day := l_first_work_day;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
    END;
    RETURN	l_prev_work_day;
END PREV_WORK_DAY;

FUNCTION DATE_OFFSET(
			p_calendar_code		IN varchar2,
			p_instance_id		IN number,
			p_calendar_date		IN date,
			p_days_offset		IN number,
			p_offset_type           IN number
			) RETURN DATE
IS
	l_offsetted_day		DATE;
	l_first_work_day	DATE;
	l_last_work_day		DATE;
	l_days_offset		NUMBER;
	l_input_date 			DATE := p_calendar_date;--6625744
BEGIN
    IF (p_calendar_code IS NULL) OR
        (p_instance_id IS NULL) OR
        (p_calendar_date IS NULL) OR
        (p_days_offset IS NULL) THEN
        --RETURN NULL; bug3583705
	RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
    END IF;

    IF (p_days_offset = 0) and (p_calendar_code = MSC_CALENDAR.FOC) THEN
        RETURN p_calendar_date;
    ELSIF (p_days_offset = 0) and (p_offset_type = -1) THEN
        l_offsetted_day := MSC_CALENDAR.PREV_WORK_DAY(
                                        p_calendar_code,
                                        p_instance_id,
                                        p_calendar_date);
    ELSIF (p_days_offset = 0) and (p_offset_type = +1) THEN
        l_offsetted_day := MSC_CALENDAR.NEXT_WORK_DAY(
                                        p_calendar_code,
                                        p_instance_id,
                                        p_calendar_date);
    ELSE
        IF p_days_offset > 0 THEN
            l_days_offset := CEIL(p_days_offset);
            l_input_date := MSC_CALENDAR.NEXT_WORK_DAY(		--6625744 START
                                        p_calendar_code,
                                        p_instance_id,
                                        p_calendar_date);			--6625744 END
        ELSE
            l_days_offset := FLOOR(p_days_offset);
            l_input_date := MSC_CALENDAR.PREV_WORK_DAY(		--6625744 START
                                        p_calendar_code,
                                        p_instance_id,
                                        p_calendar_date);			--6625744 END
        END IF;

        IF p_calendar_code = MSC_CALENDAR.FOC THEN
            RETURN p_calendar_date + l_days_offset;
        END IF;

        IF p_days_offset > 0 THEN
            BEGIN
                SELECT  cal2.calendar_date
                INTO    l_offsetted_day
                FROM    MSC_CALENDAR_DATES cal1, MSC_CALENDAR_DATES cal2
                WHERE   cal1.sr_instance_id	= p_instance_id
                AND     cal1.calendar_code	= p_calendar_code
                AND     cal1.exception_set_id	= -1
                AND     cal1.calendar_date	= TRUNC(l_input_date)		--6625744
                AND     cal2.sr_instance_id	= cal1.sr_instance_id
                AND     cal2.calendar_code	= cal1.calendar_code
                AND     cal2.exception_set_id	= cal1.exception_set_id
                AND     cal2.seq_num		= cal1.prior_seq_num + l_days_offset;
                -- AND     cal2.seq_num		= cal1.next_seq_num + l_days_offset;
                -- (3335127) New offset logic. Done along with Enforce Pur LT changes

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF G_RETAIN_DATE = 'Y' THEN
                        BEGIN
                            SELECT	FIRST_WORKING_DATE, LAST_WORKING_DATE
                            INTO	l_first_work_day, l_last_work_day
                            FROM	MSC_CALENDARS
                            WHERE	SR_INSTANCE_ID	= p_instance_id
                            AND	CALENDAR_CODE	= p_calendar_code;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                        END;

                        /* Logic to retain dates was wrong. Fixed along with Enforce Pur LT changes
                        IF p_calendar_date + l_days_offset >= l_last_work_day THEN
                            l_offsetted_day := l_last_work_day;
                        ELSIF p_calendar_date + l_days_offset <= l_first_work_day THEN
                            l_offsetted_day := l_first_work_day;
                        END IF;
                        */
                        IF p_calendar_date < l_first_work_day THEN
                            l_offsetted_day := DATE_OFFSET(p_calendar_code,
                                                           p_instance_id,
                                                           l_first_work_day,
                                                           p_days_offset,
                                                           p_offset_type);
                        ELSE
                            l_offsetted_day := l_last_work_day;
                        END IF;

                    ELSE
                        FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                        APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
            END;
        ELSE
            BEGIN
                SELECT  cal2.calendar_date
                INTO    l_offsetted_day
                FROM    MSC_CALENDAR_DATES cal1, MSC_CALENDAR_DATES cal2
                WHERE   cal1.sr_instance_id	= p_instance_id
                AND     cal1.calendar_code	= p_calendar_code
                AND     cal1.exception_set_id	= -1
                AND     cal1.calendar_date	= TRUNC(l_input_date)		--6625744
                AND     cal2.sr_instance_id	= cal1.sr_instance_id
                AND     cal2.calendar_code	= cal1.calendar_code
                AND     cal2.exception_set_id	= cal1.exception_set_id
                AND     cal2.seq_num		= cal1.next_seq_num + l_days_offset;
                -- AND     cal2.seq_num		= cal1.prior_seq_num + l_days_offset;
                -- (3335127) New offset logic. Done along with Enforce Pur LT changes

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF G_RETAIN_DATE = 'Y' THEN
                        BEGIN
                            SELECT  FIRST_WORKING_DATE, LAST_WORKING_DATE
                            INTO    l_first_work_day, l_last_work_day
                            FROM    MSC_CALENDARS
                            WHERE   SR_INSTANCE_ID	= p_instance_id
                            AND     CALENDAR_CODE	= p_calendar_code;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                        END;

                        /* Logic to retain dates was wrong. Fixed along with Enforce Pur LT changes
                        IF p_calendar_date + l_days_offset >= l_last_work_day THEN
                            l_offsetted_day := l_last_work_day;
                        ELSIF p_calendar_date + l_days_offset <= l_first_work_day THEN
                            l_offsetted_day := l_first_work_day;
                        END IF;
                        */
                        IF p_calendar_date > l_last_work_day THEN
                            l_offsetted_day := DATE_OFFSET(p_calendar_code,
                                                           p_instance_id,
                                                           l_last_work_day,
                                                           p_days_offset,
                                                           p_offset_type);
                        ELSE
                            l_offsetted_day := l_first_work_day;
                        END IF;
                    ELSE
                        FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                        APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
            END;
        END IF;
    END IF;

    RETURN	l_offsetted_day;

END DATE_OFFSET;

FUNCTION THREE_STEP_CAL_OFFSET_DATE(
			p_input_date			IN Date,
			p_first_cal_code		IN VARCHAR2,
			p_first_cal_validation_type	IN NUMBER,
			p_second_cal_code		IN VARCHAR2,
			p_offset_days			IN NUMBER,
			p_second_cal_validation_type	IN NUMBER,
			p_third_cal_code		IN VARCHAR2,
			p_third_cal_validation_type	IN NUMBER,
			p_instance_id			IN NUMBER
			) RETURN DATE
IS
	l_first_date	DATE := NULL;
	l_second_date	DATE := NULL;
	l_output_date	DATE := NULL;

BEGIN
    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug ('***** Begin Function THREE_STEP_CAL_OFFSET_DATE *****');
            msc_sch_wb.atp_debug ('________________Input________________');
            msc_sch_wb.atp_debug (' Input Date          : ' || p_input_date );
            msc_sch_wb.atp_debug (' First Cal Code      : ' || p_first_cal_code );
            msc_sch_wb.atp_debug (' Second Cal Code     : ' || p_second_cal_code );
            msc_sch_wb.atp_debug (' Third Cal Code      : ' || p_third_cal_code );
            msc_sch_wb.atp_debug (' Days Offset         : ' || p_offset_days );
            msc_sch_wb.atp_debug (' ');
    END IF;
	-- First date is computed using p_input_date, first calendar and its validation_type
	IF p_first_cal_code = MSC_CALENDAR.FOC THEN
		l_first_date := p_input_date;
	ELSIF p_first_cal_validation_type = -1 THEN
		l_first_date := MSC_CALENDAR.PREV_WORK_DAY(
				p_first_cal_code,
				p_instance_id,
				p_input_date);
	ELSIF p_first_cal_validation_type = 1 THEN
		l_first_date := MSC_CALENDAR.NEXT_WORK_DAY(
				p_first_cal_code,
				p_instance_id,
				p_input_date);
	ELSE
		l_first_date := p_input_date;
	END IF;

    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug (' Date after validation on first cal: ' || l_first_date );
    END IF;

	-- Second date is computed using first date, 2nd calendar and offset days
	IF (p_offset_days = 0) and (p_second_cal_code = MSC_CALENDAR.FOC) THEN
	        l_second_date := l_first_date;
	ELSIF (p_offset_days = 0) and (p_second_cal_validation_type = -1) THEN
		l_second_date := MSC_CALENDAR.PREV_WORK_DAY(
				p_second_cal_code,
				p_instance_id,
				l_first_date);
	ELSIF (p_offset_days = 0) and (p_second_cal_validation_type = 1) THEN
		l_second_date := MSC_CALENDAR.NEXT_WORK_DAY(
				p_second_cal_code,
				p_instance_id,
				l_first_date);
	ELSIF p_second_cal_code = MSC_CALENDAR.FOC THEN
	        l_second_date := l_first_date + p_offset_days;
	ELSIF p_offset_days > 0 THEN
        	l_second_date := MSC_CALENDAR.DATE_OFFSET(
        				p_second_cal_code,
        				p_instance_id,
        				l_first_date,
        				p_offset_days,
        				+1);
	ELSIF p_offset_days < 0 THEN
        	l_second_date := MSC_CALENDAR.DATE_OFFSET(
        				p_second_cal_code,
        				p_instance_id,
        				l_first_date,
        				p_offset_days,
        				-1);
	ELSE
		l_second_date := l_first_date;
	END IF;

    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug (' Date after offset using second cal: ' || l_second_date );
    END IF;

	-- Third date = Output Date is computed using 2nd date, 3rd calendar and validation_type
	IF p_third_cal_code = MSC_CALENDAR.FOC THEN
		l_output_date := l_second_date;
	ELSIF p_third_cal_validation_type = -1 THEN
		l_output_date := MSC_CALENDAR.PREV_WORK_DAY(
				p_third_cal_code,
				p_instance_id,
				l_second_date);
	ELSIF p_third_cal_validation_type = 1 THEN
		l_output_date := MSC_CALENDAR.NEXT_WORK_DAY(
				p_third_cal_code,
				p_instance_id,
				l_second_date);
	ELSE
		l_output_date := l_second_date;
	END IF;

    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug (' Date after validation on third cal: ' || l_output_date );
    END IF;

	RETURN l_output_date;

END THREE_STEP_CAL_OFFSET_DATE;

/*--------------------------------------------------------------------------
|  End Functions added for ship_rec_cal project
+-------------------------------------------------------------------------*/

END MSC_CALENDAR;


/

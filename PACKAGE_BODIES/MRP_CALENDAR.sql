--------------------------------------------------------
--  DDL for Package Body MRP_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CALENDAR" AS
/* $Header: MRPCALDB.pls 115.7 2004/08/19 20:03:34 jhegde ship $ */

--  Global Static variables
  MRP_CALENDAR_RET_DATES    NUMBER := 0;
  mrp_calendar_cal_code     VARCHAR2(10) := '17438gdjh';
  mrp_calendar_excep_set    NUMBER := -23453;
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


  TYPE_DAILY_BUCKET      CONSTANT NUMBER := 1;
  TYPE_WEEKLY_BUCKET     CONSTANT NUMBER := 2;
  TYPE_MONTHLY_BUCKET    CONSTANT NUMBER := 3;

  var_return_date        DATE;
  var_prev_work_day      DATE;
  var_prev_work_day2     DATE;
  var_prev_seq_num   NUMBER;
  var_prev_seq_num2      NUMBER;
  var_return_number      NUMBER;
  var_string_buffer      CHAR(1);
  var_calendar_code      VARCHAR2(10);
  var_exception_set_id   NUMBER;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE MRP_CAL_INIT_GLOBAL(  arg_calendar_code       VARCHAR,
                                arg_exception_set_id    NUMBER) IS
    temp_char   VARCHAR2(30);
BEGIN
  /*Commented bug 1480385 dbms_output.put_line('In MRP_CAL_INIT_GLOBAL');*/
    IF arg_calendar_code <> mrp_calendar_cal_code OR
        arg_exception_set_id <> mrp_calendar_excep_set THEN

        SELECT   /*+ index_ffs(bom) */ min(calendar_date), max(calendar_date), min(seq_num),
                    max(seq_num)
        INTO    min_date, max_date, min_seq_num, max_seq_num
        FROM    bom_calendar_dates bom
        WHERE   calendar_code = arg_calendar_code
        AND     seq_num is not null
        AND     exception_set_id = arg_exception_set_id;

        SELECT  min(period_start_date), max(period_start_date)
        INTO    min_period_date, max_period_date
        FROM    bom_period_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id;

        SELECT  min(week_start_date), max(week_start_date), min(seq_num),
                max(seq_num)
        INTO    min_week_date, max_week_date, min_week_seq_num,
                max_week_seq_num
        FROM    bom_cal_week_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id;

        mrp_calendar_cal_code := arg_calendar_code;
        mrp_calendar_excep_set := arg_exception_set_id;
    END IF;

    IF MRP_CALENDAR_RET_DATES = 0 THEN
 /*Commented bug 1480385 dbms_output.put_line('Getting value of profile');*/
        temp_Char := FND_PROFILE.VALUE('MRP_RETAIN_DATES_WTIN_CAL_BOUNDARY');
        IF temp_Char = 'Y' THEN
            MRP_CALENDAR_RET_DATES := 1;
        ELSE
            MRP_CALENDAR_RET_DATES := 2;
        END IF;
    END IF;
/*Commented bug 1480385 dbms_output.put_line(to_char(MRP_CALENDAR_RET_DATES));*/
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-CALENDAR NOT COMPILED');
            APP_EXCEPTION.RAISE_EXCEPTION;
END MRP_CAL_INIT_GLOBAL;

FUNCTION MRP_CALC_PERIOD_OFFSET(arg_date            IN DATE,
                                arg_offset          IN NUMBER,
                                arg_calendar_code   IN VARCHAR2,
                                arg_exception_set_id IN NUMBER) RETURN DATE IS
  var_abs_number     NUMBER;
BEGIN

    IF arg_offset > 0 THEN
      DECLARE CURSOR C1 IS
      SELECT  period_start_date
      FROM    bom_period_start_dates cal
      WHERE   cal.exception_set_id = var_exception_set_id
        AND   cal.calendar_code = var_calendar_code
        AND   cal.period_start_date > TRUNC(arg_date);
    BEGIN
    var_abs_number := arg_offset;
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
      FROM    bom_period_start_dates cal
      WHERE   cal.exception_set_id = var_exception_set_id
        AND   cal.calendar_code = var_calendar_code
        AND   cal.period_start_date < TRUNC(arg_date)
      ORDER BY period_start_date DESC;

    BEGIN
    var_abs_number := ABS(arg_offset);
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

FUNCTION MRP_CALC_DATE_OFFSET(arg_seq_num         IN NUMBER,
                              arg_offset          IN NUMBER,
                              arg_calendar_code   IN VARCHAR2,
                              arg_exception_set_id IN NUMBER) RETURN DATE IS
BEGIN
    BEGIN
        SELECT calendar_date
        INTO   var_return_date
        FROM   bom_calendar_dates  cal
        WHERE  cal.exception_set_id = var_exception_set_id
          AND  cal.calendar_code = var_calendar_code
          AND  cal.seq_num = arg_seq_num + arg_offset;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF MRP_CALENDAR_RET_DATES = 1
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

FUNCTION MRP_CALC_WEEK_OFFSET(arg_seq_num        IN NUMBER,
                             arg_offset          IN NUMBER,
                             arg_calendar_code   IN VARCHAR2,
                             arg_exception_set_id IN NUMBER) RETURN DATE IS
BEGIN
    BEGIN
        SELECT week_start_date
        INTO   var_return_date
        FROM   bom_cal_week_start_dates  cal
        WHERE  cal.exception_set_id = var_exception_set_id
          AND  cal.calendar_code = var_calendar_code
          AND  cal.seq_num = arg_seq_num + arg_offset;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF MRP_CALENDAR_RET_DATES = 1
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
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN

   IF arg_date is NULL or arg_org_id is NULL or arg_bucket is NULL THEN
        RETURN NULL;
   END IF;
   mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);


    MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN

        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_date THEN
            var_return_date := max_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.next_date
            INTO    var_return_date
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;

    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MIN(cal.week_start_date)
            INTO    var_return_date
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date >= TRUNC(arg_date);
        END IF;

    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_period_date THEN
            var_return_date := min_period_date;
        ELSE
            SELECT  MIN(cal.period_start_date)
            INTO    var_return_date
            FROM    bom_period_start_dates  cal
             WHERE  cal.exception_set_id = var_exception_set_id
               AND  cal.calendar_code = var_calendar_code
               AND  cal.period_start_date >= TRUNC(arg_date);
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END NEXT_WORK_DAY;

FUNCTION PREV_WORK_DAY(arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN
   IF arg_date is NULL or arg_org_id is NULL or arg_bucket is NULL THEN
        RETURN NULL;
   END IF;
    mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_date := max_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.prior_date
            INTO    var_return_date
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MAX(cal.week_start_date)
            INTO    var_return_date
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_period_date THEN
            var_return_date := min_period_date;
        ELSE
            SELECT  MAX(cal.period_start_date)
            INTO    var_return_date
            FROM    bom_period_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.period_start_date <= TRUNC(arg_date);
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END PREV_WORK_DAY;

FUNCTION NEXT_WORK_DAY_SEQNUM(arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN NUMBER IS
BEGIN
    mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_date THEN
            var_return_number := max_seq_num;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  cal.next_seq_num
            INTO    var_return_number
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_week_date THEN
            var_return_number := max_week_seq_num;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_week_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  MIN(cal.seq_num)
            INTO    var_return_number
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date >= TRUNC(arg_date);
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
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN NUMBER IS
BEGIN
    mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_number := max_seq_num;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  cal.prior_seq_num
            INTO    var_return_number
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_number := max_week_seq_num;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_number := min_week_seq_num;
        ELSE
            SELECT  MAX(cal.seq_num)
            INTO    var_return_number
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date);
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
                       arg_bucket IN NUMBER,
                       arg_date IN DATE,
                       arg_offset IN NUMBER) RETURN DATE IS
BEGIN
    IF arg_date IS NULL or arg_org_id is NULL or arg_bucket is NULL or
            arg_offset is null THEN
        RETURN NULL;
    END IF;
    IF arg_offset = 0 THEN
        var_prev_work_day := PREV_WORK_DAY(arg_org_id, 1, arg_date);
    return var_prev_work_day;
    END IF;

    mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF arg_bucket = TYPE_DAILY_BUCKET OR arg_bucket = TYPE_WEEKLY_BUCKET
    THEN
        var_prev_seq_num :=
            PREV_WORK_DAY_SEQNUM(arg_org_id, arg_bucket, arg_date);
    END IF;

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
           var_return_date := mrp_calc_date_offset(var_prev_seq_num,
                arg_offset, var_calendar_code, var_exception_set_id);
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
           var_return_date := mrp_calc_week_offset(var_prev_seq_num,
                arg_offset, var_calendar_code, var_exception_set_id);
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
           var_prev_work_day := PREV_WORK_DAY(arg_org_id, arg_bucket, arg_date);
           var_return_date := mrp_calc_period_offset(var_prev_work_day,
                arg_offset, var_calendar_code, var_exception_set_id);
    END IF;

    return var_return_date;
END DATE_OFFSET;

FUNCTION DAYS_BETWEEN( arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date1 IN DATE,
                       arg_date2 IN DATE) RETURN NUMBER IS
BEGIN
    mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    IF arg_date1 is NULL or arg_bucket is null or arg_org_id is null
        or arg_date2 IS NULL THEN
        RETURN NULL;
    END IF;

    MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF (arg_bucket <> TYPE_MONTHLY_BUCKET) THEN
      var_prev_seq_num := PREV_WORK_DAY_SEQNUM(arg_org_id, arg_bucket, arg_date1);
      var_prev_seq_num2 := PREV_WORK_DAY_SEQNUM(arg_org_id, arg_bucket, arg_date2);
      var_return_number := ABS(var_prev_seq_num2 - var_prev_seq_num);
    ELSE
      var_prev_work_day := PREV_WORK_DAY(arg_org_id, arg_bucket, arg_date1);
      var_prev_work_day2 := PREV_WORK_DAY(arg_org_id, arg_bucket, arg_date2);
      SELECT count(period_start_date)
      INTO var_return_number
      FROM bom_period_start_dates cal
      WHERE cal.exception_set_id = var_exception_set_id
      AND   cal.calendar_code = var_calendar_code
      AND   cal.period_start_date between var_prev_work_day
        and var_prev_work_day2
      AND   cal.period_start_date <> var_prev_work_day2;

    END IF;

    return var_return_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
            APP_EXCEPTION.RAISE_EXCEPTION;
END DAYS_BETWEEN;

PROCEDURE select_calendar_defaults(
		arg_org_id IN NUMBER,
                arg_calendar_code OUT NOCOPY VARCHAR2, --2663505
                arg_exception_set_id OUT NOCOPY NUMBER) IS --2663505

BEGIN
    SELECT   calendar_code,
             calendar_exception_set_id
    INTO     arg_calendar_code,
             arg_exception_set_id
    FROM     mtl_parameters
    WHERE    organization_id = arg_org_id;

    IF SQL%NOTFOUND THEN
        raise_application_error(-200000, 'Cannot select calendar defaults');
    END IF;

END select_calendar_defaults;

END MRP_CALENDAR;

/

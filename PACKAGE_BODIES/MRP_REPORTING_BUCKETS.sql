--------------------------------------------------------
--  DDL for Package Body MRP_REPORTING_BUCKETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_REPORTING_BUCKETS" AS
  /* $Header: MRPPRBKB.pls 115.0 99/07/16 12:33:44 porting ship $ */

/*-------------------------- PUBLIC ROUTINES ---------------------------------*/

PROCEDURE mrp_weeks_months(
                            arg_query_id IN NUMBER,
                            arg_user_id IN NUMBER,
                            arg_weeks   IN NUMBER,
                            arg_periods IN NUMBER,
                            arg_start_date IN DATE,
                            arg_org_id  IN NUMBER) IS
    var_week_counter        NUMBER;
    var_month_counter       NUMBER;
    var_week_bucket_date    mrp_form_query.date1%TYPE;
    var_month_bucket_date   mrp_form_query.date1%TYPE;
    var_month_start_date    mrp_form_query.date1%TYPE;
    var_calendar_code       VARCHAR2(10);
    var_exception_set_id    NUMBER;
    var_weeks               NUMBER;
    var_periods             NUMBER;
    /*-------------------------------------------------------------------------+
    |   Weeks cursor                                                           |
    +-------------------------------------------------------------------------*/
    CURSOR weeks_cur IS
        SELECT  week_start_date
        FROM    bom_cal_week_start_dates
        WHERE   calendar_code    = var_calendar_code
          AND   exception_set_id = var_exception_set_id
          AND   week_start_date >=
                (SELECT  max(week_start_date)
                 FROM    bom_cal_week_start_dates
                 WHERE   week_start_date <= TRUNC(arg_start_date)
                   AND   calendar_code    = var_calendar_code
                   AND   exception_set_id = var_exception_set_id)
          ORDER BY week_start_date;
    /*-------------------------------------------------------------------------+
    |   Months cursor                                                          |
    +-------------------------------------------------------------------------*/
    CURSOR months_cur IS
        SELECT  period_start_date
        FROM    bom_period_start_dates
        WHERE   calendar_code      = var_calendar_code
          AND   exception_set_id   = var_exception_set_id
          AND   period_start_date >=
                (SELECT  max(period_start_date)
                 FROM    bom_period_start_dates
                 WHERE   period_start_date <= var_month_start_date
                   AND   calendar_code      = var_calendar_code
                   AND   exception_set_id   = var_exception_set_id)
        ORDER BY period_start_date;
BEGIN
    /*-------------------------------------------------------------------------+
    |  Select calendar defaults                                                |
    +-------------------------------------------------------------------------*/
    mrp_calendar.select_calendar_defaults(
        arg_org_id,
        var_calendar_code,
        var_exception_set_id);

    -- Add one to either the weeks or the periods...need to get one extra
    -- date in order to calculate the end date
    IF arg_weeks = arg_periods
    THEN
      var_weeks := arg_weeks + 1;
      var_periods := arg_periods;
    ELSE
      var_weeks := arg_weeks;
      var_periods := arg_periods + 1;
    END IF;
    /*-------------------------------------------------------------------------+
    |   For each week ...                                                      |
    +-------------------------------------------------------------------------*/

    OPEN weeks_cur;
    FOR var_week_counter IN 1..var_weeks
    LOOP
        FETCH weeks_cur INTO
                var_week_bucket_date;

        IF weeks_cur%NOTFOUND
        THEN
            raise_application_error(-20000, 'Cannot select week');
        END IF;
        /*---------------------------------------------------------------------+
        |   Insert a row for each week...                                      |
        +---------------------------------------------------------------------*/
        INSERT INTO mrp_form_query
                    (query_id,
                    date1,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login)
            VALUES  (arg_query_id,
                    var_week_bucket_date,
                    SYSDATE,
                    arg_user_id,
                    SYSDATE,
                    arg_user_id,
                    -1);
    END LOOP;
    CLOSE weeks_cur;
    /*-------------------------------------------------------------------------+
    |   Now do the same for months                                             |
    +-------------------------------------------------------------------------*/
    IF var_week_bucket_date IS NULL
    THEN
        var_month_start_date := arg_start_date;
    ELSE
        SELECT  min(period_start_date)
        INTO    var_month_start_date
        FROM    bom_period_start_dates
        WHERE   period_start_date > var_week_bucket_date
          AND   calendar_code     = var_calendar_code
          AND   exception_Set_id  = var_exception_set_id;
    END IF;
    OPEN months_cur;
    FOR var_month_counter IN arg_weeks+1..var_periods
    LOOP
        FETCH months_cur    INTO
                var_month_bucket_date;

        IF months_cur%NOTFOUND
        THEN
            raise_application_error(-20001, 'Cannot select month');
        END IF;
        /*---------------------------------------------------------------------+
        |   Insert a row for each week...                                      |
        +---------------------------------------------------------------------*/
        INSERT INTO mrp_form_query
                    (query_id,
                    date1,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login)
            VALUES  (arg_query_id,
                    var_month_bucket_date,
                    SYSDATE,
                    arg_user_id,
                    SYSDATE,
                    arg_user_id,
                    -1);
    END LOOP;
    CLOSE months_cur;
    UPDATE  mrp_form_query q
    SET     date2 =
            (SELECT MIN(q2.date1)
            FROM    mrp_form_query q2
            WHERE   q2.query_id = q.query_id
              AND   q2.date1 > q.date1)
    WHERE   q.query_id = arg_query_id;

    DELETE  FROM mrp_form_query
    WHERE   query_id = arg_query_id
      AND   date2 IS NULL;

END mrp_weeks_months;
END mrp_reporting_buckets;

/

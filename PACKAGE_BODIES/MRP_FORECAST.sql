--------------------------------------------------------
--  DDL for Package Body MRP_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_FORECAST" AS
/* $Header: MRFCSTBB.pls 115.6 2004/02/19 07:39:51 rgurugub ship $ */
  TYPE_DAILY_BUCKET      CONSTANT NUMBER := 1;
  TYPE_WEEKLY_BUCKET     CONSTANT NUMBER := 2;
  TYPE_MONTHLY_BUCKET    CONSTANT NUMBER := 3;

  SYS_YES                CONSTANT NUMBER := 1;

  ENTRY_MODE             CONSTANT NUMBER := 1;
  QUERY_MODE             CONSTANT NUMBER := 2;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/
FUNCTION BUCKET_FC_DESIG(   arg_org_id IN NUMBER,
                arg_query_id IN NUMBER,
                arg_secondary_query_id IN NUMBER,
                arg_bucket_type IN NUMBER,
                arg_past_due IN NUMBER,
                            arg_forecast_designator IN VARCHAR2,
                arg_inventory_item_id IN NUMBER,
                arg_start_date IN DATE,
                arg_cutoff_date IN DATE,
                arg_bucket_start_date IN DATE,
                arg_form_mode IN NUMBER) RETURN BOOLEAN IS
  var_calendar_code      VARCHAR2(10);
  var_forecast_desig     VARCHAR2(10);
  var_exception_set_id   NUMBER;
  var_curr_qty       NUMBER;
  var_orig_qty       NUMBER;
  var_rep_curr_qty   NUMBER;
  var_rep_orig_qty   NUMBER;
  var_bucket_type    NUMBER;
  var_org_id         NUMBER;
  var_days_in_bucket     NUMBER;
  var_begin_date     DATE;
  var_fc_begin_date  DATE;
  var_start_date     DATE;
  var_end_date       DATE;
  var_rate_end_date  DATE;
  var_bucket_start_date  DATE;
  var_bucket_end_date    DATE;
  var_temp_date      DATE;
  var_curr_date      DATE;
  var_next_date      DATE;
  var_item_cost      NUMBER;
  var_first_bucket_workday	DATE;

BEGIN
    mrp_calendar.select_calendar_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    BEGIN
      SELECT  NVL(item_cost,0)
      INTO    var_item_cost
      FROM    cst_item_costs_for_gl_view
      WHERE   organization_id = arg_org_id
      AND     inventory_item_id = arg_inventory_item_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        var_item_cost := 0;
    END;

    SELECT  cal1.calendar_date
    INTO    var_fc_begin_date
    FROM    bom_calendar_dates    cal1,
            bom_calendar_dates    cal2,
            mrp_forecast_designators desig
    WHERE   cal1.seq_num =
            cal2.prior_seq_num -
            LEAST(NVL(desig.backward_update_time_fence, 0),
                  cal2.seq_num - 1)
      AND   cal1.calendar_code = var_calendar_code
      AND   cal1.exception_set_id = var_exception_set_id
      AND   cal2.calendar_date =
            TRUNC(arg_start_date)
      AND   cal2.calendar_code = var_calendar_code
      AND   cal2.exception_set_id = var_exception_set_id
      AND   desig.forecast_designator = arg_forecast_designator
      AND   desig.organization_id = arg_org_id;

    DECLARE
         CURSOR FORECAST_RECORDS IS
         SELECT DECODE(arg_past_due, SYS_YES,
                    forecast_date,
                    GREATEST(arg_start_date,forecast_date)),
               NVL(rate_end_date, forecast_date),
               current_forecast_quantity,
               original_forecast_quantity,
               forecast_designator,
               NVL(bucket_type, 0),
               arg_org_id
          FROM mrp_forecast_dates
          WHERE DECODE(arg_past_due, SYS_YES, arg_start_date,
                DECODE(bucket_type, 1,
                    DECODE(rate_end_date, NULL,
                    forecast_date, rate_end_date), arg_start_date))
               >= arg_start_date
           AND forecast_designator = arg_forecast_designator
           AND organization_id = arg_org_id
           AND inventory_item_id = arg_inventory_item_id
       ORDER BY 1,2,4,5;
    BEGIN
    OPEN FORECAST_RECORDS;

    <<get_item_loop>>
    LOOP
      FETCH FORECAST_RECORDS
      INTO var_start_date,
       var_rate_end_date,
       var_curr_qty,
       var_orig_qty,
       var_forecast_desig,
       var_bucket_type,
       var_org_id;

      IF FORECAST_RECORDS%FOUND THEN -- fetch succeed

     var_end_date := mrp_calendar.date_offset(arg_org_id,
            var_bucket_type , var_rate_end_date, 1);

     var_bucket_start_date := mrp_calendar.prev_work_day(arg_org_id,
            var_bucket_type, var_start_date);

     var_begin_date := mrp_calendar.prev_work_day(arg_org_id,
            var_bucket_type, var_fc_begin_date);

     IF arg_past_due <> SYS_YES AND var_end_date <= var_begin_date THEN
        GOTO get_item_loop;
         END IF;

     /*--------------------------------------------------------------+
      | Bug 631859          bbaumbac   25-FEB-1998                   |
      | Problem:  If a monthly calendar is used then there is a      |
      |           possibility that the first day of the bucket will  |
      |           not be a workday.  In this case, a quantity is     |
      |           seen for that day because we were starting with    |
      |           the first day of the forecast.                     |
      | Fix:  Added a variable, var_first_bucket_workday, and a call |
      |       to mrp_calendar.next_work_day.  If the first day of the|
      |       forecast is a workday, it will just return that day,   |
      |       otherwise, the next valid workday is returned.         |
      +--------------------------------------------------------------*/
     var_first_bucket_workday := mrp_calendar.next_work_day(arg_org_id,
					1,var_start_date);
     var_temp_date := var_first_bucket_workday;

     <<fc_loop>>
     WHILE(var_temp_date < var_end_date) LOOP
         var_bucket_end_date := mrp_calendar.date_offset(arg_org_id,
            var_bucket_type, var_temp_date, 1);
         var_bucket_start_date := mrp_calendar.next_work_day(arg_org_id,
                                        1,var_bucket_start_date);
         var_bucket_end_date := mrp_calendar.next_work_day(arg_org_id,
                                        1,var_bucket_end_date);

         IF (var_bucket_type = TYPE_DAILY_BUCKET) THEN
        var_days_in_bucket := 1;
         ELSE
            var_days_in_bucket := mrp_calendar.days_between(arg_org_id,
           TYPE_DAILY_BUCKET, var_bucket_start_date,
           var_bucket_end_date);
         END IF;

         var_rep_curr_qty := ROUND(var_curr_qty/var_days_in_bucket,10);
         var_rep_orig_qty := ROUND(var_orig_qty/var_days_in_bucket,10);

         IF (arg_past_due <> SYS_YES AND
        var_bucket_end_date <= var_begin_date) THEN
        var_temp_date := var_bucket_end_date;
        var_bucket_start_date := var_temp_date;
        GOTO fc_loop;
         END IF;

         IF (var_temp_date <= var_begin_date AND
             var_begin_date < var_bucket_end_date) THEN
         var_curr_date := var_begin_date;
         ELSE
             var_curr_date := var_temp_date;
         END IF;

         LOOP

         INSERT INTO mrp_form_query
           (QUERY_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            DATE1,          /* forecast date */
            NUMBER1,        /* org id */
            NUMBER2,        /* inventory item id */
            NUMBER3,        /* daily curr qty */
            NUMBER5,        /* daily orig qty */
            NUMBER7,        /* daily sales order qty */
            CHAR1)          /* forecast designator (added for web inquiries) */
          VALUES
           (arg_query_id,
            sysdate,
            -1,
            sysdate,
            -1,
            var_curr_date,
            arg_org_id,
            arg_inventory_item_id,
            decode(arg_form_mode,QUERY_MODE,decode(sign(var_rep_curr_qty),-1,0,
			var_rep_curr_qty),var_rep_curr_qty),
            var_rep_orig_qty,
            var_rep_orig_qty - var_rep_curr_qty,
            arg_forecast_designator); /* (added for web inquiries) */

          var_next_date := mrp_calendar.next_work_day(arg_org_id,
                1, var_curr_date+1);
          var_curr_date := var_next_date;
          EXIT WHEN var_curr_date >= var_bucket_end_date;
          END LOOP;

    var_temp_date := var_bucket_end_date;
    var_bucket_start_date := var_temp_date;
        --COMMIT WORK;

    END LOOP fc_loop;
      ELSE /* no entires were found, insert a psuedo one */
         INSERT INTO mrp_form_query
           (QUERY_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            DATE1,          /* forecast date */
            NUMBER1,        /* org id */
            NUMBER2,        /* inventory item id */
            NUMBER3,        /* daily curr qty */
            NUMBER5,        /* daily orig qty */
            NUMBER7,        /* daily sales order qty */
            CHAR1)          /* forecast designator (added for web inquiries) */
          VALUES
           (arg_query_id,
            sysdate,
            -1,
            sysdate,
            -1,
            arg_start_date,
            arg_org_id,
            arg_inventory_item_id,
            0,
            0,
            0,
            arg_forecast_designator); /* (added for web inquiries) */
    --COMMIT WORK;
       EXIT;
      END IF;
    END LOOP get_item_loop;
    CLOSE FORECAST_RECORDS;
  END;
  RETURN TRUE;
/*
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return FALSE;
    WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
*/
END BUCKET_FC_DESIG;

FUNCTION FC_MRP_FORM_QUERY( arg_org_id IN NUMBER,
                arg_query_id IN NUMBER,
                arg_secondary_query_id IN NUMBER,
                arg_bucket_type IN NUMBER,
                arg_past_due IN NUMBER,
                arg_cutoff_date IN DATE,
                arg_bucket_start_date IN DATE) RETURN BOOLEAN IS
BEGIN
  IF arg_bucket_type = TYPE_DAILY_BUCKET THEN
    INSERT INTO mrp_form_query
           (QUERY_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            DATE1,          /* bucket start date */
            DATE2,          /* next bucket start date */
            NUMBER1,        /* bucket curr qty */
            NUMBER3,        /* bucket cum curr qty */
            NUMBER5,        /* bucket orig qty */
            NUMBER7,        /* bucket cum orig qty */
            NUMBER9,        /* bucket sales order qty */
            NUMBER11,       /* bucket cum sales order qty */
            NUMBER12,       /* item id (added for web inquiries) */
            NUMBER13,       /* org id (added for web inquiries) */
            CHAR1)          /* forecast designator (added for web inquiries) */
    SELECT  arg_secondary_query_id,
            sysdate,
            -1,
            sysdate,
            -1,
            DATES.CALENDAR_DATE,
            DATES.NEXT_DATE,
    /* curr qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
            (DECODE(DATES.CALENDAR_DATE, arg_bucket_start_date,
            DECODE(LEAST(arg_bucket_start_date, MRP_FQ.DATE1),
              MRP_FQ.DATE1, MRP_FQ.NUMBER3, 0),
               DECODE(MRP_FQ.DATE1, DATES.CALENDAR_DATE,
               MRP_FQ.NUMBER3,0))),
            DECODE(MRP_FQ.DATE1, DATES.CALENDAR_DATE,
            MRP_FQ.NUMBER3,0))),0), 6),
    /*cum curr qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
            (DECODE(DATES.CALENDAR_DATE, arg_bucket_start_date,
            DECODE(LEAST(arg_bucket_start_date, MRP_FQ.DATE1),
              MRP_FQ.DATE1, MRP_FQ.NUMBER3, 0),
               DECODE(LEAST(MRP_FQ.DATE1, DATES.CALENDAR_DATE),
               MRP_FQ.DATE1,
               MRP_FQ.NUMBER3,0))),
            DECODE(LEAST(MRP_FQ.DATE1, DATES.CALENDAR_DATE),
            MRP_FQ.DATE1,
            DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
            MRP_FQ.DATE1,
            MRP_FQ.NUMBER3,0)))),0), 6),
    /*orig qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
                (DECODE(DATES.CALENDAR_DATE, arg_bucket_start_date,
                    DECODE(LEAST(arg_bucket_start_date, MRP_FQ.DATE1),
                  MRP_FQ.DATE1, MRP_FQ.NUMBER5, 0),
                   DECODE(MRP_FQ.DATE1, DATES.CALENDAR_DATE,
                   MRP_FQ.NUMBER5,0))),
               DECODE(MRP_FQ.DATE1, DATES.CALENDAR_DATE,
               MRP_FQ.NUMBER5,0))),0), 6),
    /*cum orig qty*/
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
            (DECODE(DATES.CALENDAR_DATE, arg_bucket_start_date,
            DECODE(LEAST(arg_bucket_start_date, MRP_FQ.DATE1),
              MRP_FQ.DATE1, MRP_FQ.NUMBER5, 0),
               DECODE(LEAST(MRP_FQ.DATE1, DATES.CALENDAR_DATE),
               MRP_FQ.DATE1,
               MRP_FQ.NUMBER5,0))),
            DECODE(LEAST(MRP_FQ.DATE1, DATES.CALENDAR_DATE),
            MRP_FQ.DATE1,
            DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
            MRP_FQ.DATE1,
            MRP_FQ.NUMBER5,0)))),0), 6),
    /* sales order qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
                (DECODE(DATES.CALENDAR_DATE, arg_bucket_start_date,
                    DECODE(LEAST(arg_bucket_start_date, MRP_FQ.DATE1),
                  MRP_FQ.DATE1, MRP_FQ.NUMBER7, 0),
                   DECODE(MRP_FQ.DATE1, DATES.CALENDAR_DATE,
                   MRP_FQ.NUMBER7,0))),
               DECODE(MRP_FQ.DATE1, DATES.CALENDAR_DATE,
               MRP_FQ.NUMBER7,0))),0), 6),
    /*cum sales order qty*/
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
            (DECODE(DATES.CALENDAR_DATE, arg_bucket_start_date,
            DECODE(LEAST(arg_bucket_start_date, MRP_FQ.DATE1),
              MRP_FQ.DATE1, MRP_FQ.NUMBER7, 0),
               DECODE(LEAST(MRP_FQ.DATE1, DATES.CALENDAR_DATE),
               MRP_FQ.DATE1,
               MRP_FQ.NUMBER7,0))),
            DECODE(LEAST(MRP_FQ.DATE1, DATES.CALENDAR_DATE),
            MRP_FQ.DATE1,
            DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
            MRP_FQ.DATE1,
            MRP_FQ.NUMBER7,0)))),0), 6),
            MRP_FQ.NUMBER2, /* (added for web inquiries) */
            MRP_FQ.NUMBER1, /* (added for web inquiries) */
            MRP_FQ.CHAR1    /* (added for web inquiries) */
    FROM    BOM_CALENDAR_DATES DATES,
            MTL_PARAMETERS PARAM,
            MRP_FORM_QUERY  MRP_FQ
    WHERE   DATES.EXCEPTION_SET_ID = PARAM.CALENDAR_EXCEPTION_SET_ID
    AND     DATES.CALENDAR_CODE = PARAM.CALENDAR_CODE
    AND     DATES.SEQ_NUM is not NULL
    AND     DATES.CALENDAR_DATE BETWEEN arg_bucket_start_date
                AND     arg_cutoff_date
    AND     PARAM.ORGANIZATION_ID = arg_org_id
    AND     MRP_FQ.query_id = arg_query_id
    AND     MRP_FQ.DATE1 <= arg_cutoff_date
    GROUP  BY MRP_FQ.QUERY_ID,
           MRP_FQ.NUMBER2, /* (added for web inquiries) */
           MRP_FQ.NUMBER1, /* (added for web inquiries) */
           MRP_FQ.CHAR1,   /* (added for web inquiries) */
           DATES.CALENDAR_DATE,
           DATES.NEXT_DATE;

 ELSIF arg_bucket_type = TYPE_WEEKLY_BUCKET THEN
     INSERT INTO mrp_form_query
           (QUERY_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            DATE1,          /* bucket date */
            DATE2,          /* next bucket start date */
            NUMBER1,        /* bucket curr qty */
            NUMBER3,        /* bucket cum curr qty */
            NUMBER5,        /* bucket orig qty */
            NUMBER7,        /* bucket cum orig qty */
            NUMBER9,        /* bucket sales order qty */
            NUMBER11,       /* bucket cum sales order qty */
            NUMBER12,       /* item id (added for web inquiries) */
            NUMBER13,       /* org id (added for web inquiries) */
            CHAR1)          /* forecast designator (added for web inquiries) */
      SELECT
            arg_secondary_query_id,
            sysdate,
            -1,
            sysdate,
            -1,
            DATES.WEEK_START_DATE,
            DATES.NEXT_DATE,
/*curr qty*/
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
             DECODE(DATES.WEEK_START_DATE, arg_bucket_start_date,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER3),0),
                DECODE(GREATEST(MRP_FQ.DATE1, DATES.WEEK_START_DATE),
                MRP_FQ.DATE1,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER3),0))),
                DECODE(GREATEST(MRP_FQ.DATE1, DATES.WEEK_START_DATE),
                    MRP_FQ.DATE1,
                    DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                    MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                            MRP_FQ.NUMBER3),0)))),0), 6),
/*cum curr qty*/
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
                   DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                   MRP_FQ.DATE1,
               DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                   MRP_FQ.NUMBER3),0),
               DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
               MRP_FQ.DATE1,
               DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
               MRP_FQ.DATE1,
               DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                   MRP_FQ.NUMBER3),0)))),0), 6),
/* orig qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
             DECODE(DATES.WEEK_START_DATE, arg_bucket_start_date,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER5),0),
                DECODE(GREATEST(MRP_FQ.DATE1, DATES.WEEK_START_DATE),
                MRP_FQ.DATE1,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER5),0))),
             DECODE(GREATEST(MRP_FQ.DATE1, DATES.WEEK_START_DATE),
                MRP_FQ.DATE1,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER5),0)))),0), 6),
/* cum orig qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
                   DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                   MRP_FQ.DATE1,
               DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                   MRP_FQ.NUMBER5),0),
               DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
               MRP_FQ.DATE1,
               DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
               MRP_FQ.DATE1,
               DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
               MRP_FQ.NUMBER5),0)))),0), 6),
/* sales order qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
             DECODE(DATES.WEEK_START_DATE, arg_bucket_start_date,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER7),0),
                DECODE(GREATEST(MRP_FQ.DATE1, DATES.WEEK_START_DATE),
                MRP_FQ.DATE1,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER7),0))),
             DECODE(GREATEST(MRP_FQ.DATE1, DATES.WEEK_START_DATE),
                MRP_FQ.DATE1,
                DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                MRP_FQ.DATE1,
                    DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                        MRP_FQ.NUMBER7),0)))),0), 6),
/* cum sales order qty */
            ROUND(NVL(SUM(DECODE(arg_past_due, 1,
                   DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
                   MRP_FQ.DATE1,
               DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                   MRP_FQ.NUMBER7),0),
               DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
               MRP_FQ.DATE1,
               DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
               MRP_FQ.DATE1,
               DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
               MRP_FQ.NUMBER7),0)))),0), 6),
               MRP_FQ.NUMBER2, /* (added for web inquiries) */
               MRP_FQ.NUMBER1, /* (added for web inquiries) */
               MRP_FQ.CHAR1    /* (added for web inquiries) */
    FROM    BOM_CAL_WEEK_START_DATES DATES,
            MTL_PARAMETERS PARAM,
            MRP_FORM_QUERY  MRP_FQ
    WHERE   DATES.EXCEPTION_SET_ID = PARAM.CALENDAR_EXCEPTION_SET_ID
    AND     DATES.CALENDAR_CODE = PARAM.CALENDAR_CODE
    AND     DATES.WEEK_START_DATE BETWEEN arg_bucket_start_date
                AND     arg_cutoff_date
    AND     PARAM.ORGANIZATION_ID = arg_org_id
    AND     MRP_FQ.query_id = arg_query_id
    AND     MRP_FQ.DATE1 <= arg_cutoff_date
    GROUP  BY MRP_FQ.QUERY_ID,
              MRP_FQ.NUMBER2, /* (added for web inquiries) */
              MRP_FQ.NUMBER1, /* (added for web inquiries) */
              MRP_FQ.CHAR1,   /* (added for web inquiries) */
            DATES.WEEK_START_DATE,
            DATES.NEXT_DATE;
 ELSE
    INSERT INTO mrp_form_query
       (QUERY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DATE1,          /* bucket date */
        DATE2,          /* next bucket start date */
        NUMBER1,        /* bucket curr qty */
        NUMBER3,        /* bucket cum curr qty */
        NUMBER5,        /* bucket orig qty */
        NUMBER7,        /* bucket cum orig qty */
        NUMBER9,        /* bucket sales order qty */
        NUMBER11,       /* bucket cum sales order qty */
        NUMBER12,       /* item id (added for web inquiries) */
        NUMBER13,       /* org id (added for web inquiries) */
        CHAR1)          /* forecast designator (added for web inquiries) */
    SELECT
        arg_secondary_query_id,
        sysdate,
        -1,
        sysdate,
        -1,
    DATES.PERIOD_START_DATE,
    DATES.NEXT_DATE,
/*curr qty*/
        ROUND(NVL(SUM(DECODE(arg_past_due, 1,
         DECODE(DATES.PERIOD_START_DATE, arg_bucket_start_date,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
            DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER3),0),
            DECODE(GREATEST(MRP_FQ.DATE1, DATES.PERIOD_START_DATE),
            MRP_FQ.DATE1,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
            DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER3),0))),
         DECODE(GREATEST(MRP_FQ.DATE1, DATES.PERIOD_START_DATE),
            MRP_FQ.DATE1,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
            DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER3),0)))),0), 6),
/*cum curr qty*/
        ROUND(NVL(SUM(DECODE(arg_past_due, 1,
               DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
               MRP_FQ.DATE1,
           DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
               MRP_FQ.NUMBER3),0),
           DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
           MRP_FQ.DATE1,
       DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
       MRP_FQ.DATE1,
       DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
           MRP_FQ.NUMBER3),0)))),0), 6),
/* orig qty */
        ROUND(NVL(SUM(DECODE(arg_past_due, 1,
         DECODE(DATES.PERIOD_START_DATE, arg_bucket_start_date,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER5),0),
            DECODE(GREATEST(MRP_FQ.DATE1, DATES.PERIOD_START_DATE),
            MRP_FQ.DATE1,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER5),0))),
         DECODE(GREATEST(MRP_FQ.DATE1, DATES.PERIOD_START_DATE),
            MRP_FQ.DATE1,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER5),0)))),0), 6),
/* cum orig qty */
        ROUND(NVL(SUM(DECODE(arg_past_due, 1,
               DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
               MRP_FQ.DATE1,
           DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
               MRP_FQ.NUMBER5),0),
           DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
           MRP_FQ.DATE1,
       DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
       MRP_FQ.DATE1,
       DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
           MRP_FQ.NUMBER5),0)))),0), 6),
/* sales order qty */
        ROUND(NVL(SUM(DECODE(arg_past_due, 1,
         DECODE(DATES.PERIOD_START_DATE, arg_bucket_start_date,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER7),0),
            DECODE(GREATEST(MRP_FQ.DATE1, DATES.PERIOD_START_DATE),
            MRP_FQ.DATE1,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER7),0))),
         DECODE(GREATEST(MRP_FQ.DATE1, DATES.PERIOD_START_DATE),
            MRP_FQ.DATE1,
            DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
            MRP_FQ.DATE1,
                DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
                    MRP_FQ.NUMBER7),0)))),0), 6),
/* cum sales order qty */
        ROUND(NVL(SUM(DECODE(arg_past_due, 1,
               DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
               MRP_FQ.DATE1,
           DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
               MRP_FQ.NUMBER7),0),
           DECODE(LEAST(MRP_FQ.DATE1, DATES.NEXT_DATE),
           MRP_FQ.DATE1,
       DECODE(GREATEST(MRP_FQ.DATE1, arg_bucket_start_date),
       MRP_FQ.DATE1,
       DECODE(MRP_FQ.DATE1, DATES.NEXT_DATE, 0,
           MRP_FQ.NUMBER7),0)))),0), 6),
            MRP_FQ.NUMBER2, /* (added for web inquiries) */
            MRP_FQ.NUMBER1, /* (added for web inquiries) */
            MRP_FQ.CHAR1    /* (added for web inquiries) */
 FROM   MTL_PARAMETERS PARAM,
        BOM_PERIOD_START_DATES DATES,
        MRP_FORM_QUERY  MRP_FQ
 WHERE  DATES.EXCEPTION_SET_ID = PARAM.CALENDAR_EXCEPTION_SET_ID
   AND  DATES.CALENDAR_CODE = PARAM.CALENDAR_CODE
   AND  PARAM.ORGANIZATION_ID = arg_org_id
   AND  MRP_FQ.query_id = arg_query_id
   AND  MRP_FQ.DATE1 <= arg_cutoff_date
   AND  DATES.PERIOD_START_DATE BETWEEN arg_bucket_start_date
    AND arg_cutoff_date
 GROUP  BY MRP_FQ.QUERY_ID,
           MRP_FQ.NUMBER2, /* (added for web inquiries) */
           MRP_FQ.NUMBER1, /* (added for web inquiries) */
           MRP_FQ.CHAR1,   /* (added for web inquiries) */
       DATES.PERIOD_START_DATE,
       DATES.NEXT_DATE;
 END IF;
 --COMMIT WORK;
  return TRUE;
/*
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return FALSE;
    WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
*/
END FC_MRP_FORM_QUERY;

/*---------------------------- PUBLIC ROUTINES ------------------------------*/
PROCEDURE BUCKET_ENTRIES( arg_form_mode IN NUMBER,
              arg_org_id IN NUMBER,
                      arg_query_id IN NUMBER,
                      arg_secondary_query_id IN NUMBER,
                  arg_bucket_type IN NUMBER,
                  arg_past_due IN NUMBER,
                          arg_forecast_designator IN VARCHAR2,
                          arg_forecast_set IN VARCHAR2,
                  arg_inventory_item_id IN NUMBER,
                          arg_start_date IN DATE,
                          arg_cutoff_date IN DATE) IS
  var_return_value BOOLEAN := TRUE;
  var_forecast_designator VARCHAR(10);
  var_start_date DATE;
  var_bucket_start_date DATE;
BEGIN
    var_start_date := mrp_calendar.prev_work_day(arg_org_id,
                1, arg_start_date);

    var_bucket_start_date := mrp_calendar.prev_work_day(arg_org_id,
                arg_bucket_type, arg_start_date);

--  entry mode, show entries associate with the specific forecast
--  or forecast set.

    IF arg_form_mode = ENTRY_MODE THEN
      IF (arg_forecast_designator is not NULL
        AND arg_forecast_designator <> ' ') THEN
        var_forecast_designator := arg_forecast_designator;
      ELSE
        var_forecast_designator := arg_forecast_set;
      END IF;

        var_return_value := bucket_fc_desig(
                 arg_org_id,
             arg_query_id,
             arg_secondary_query_id,
             arg_bucket_type,
             arg_past_due,
                         var_forecast_designator,
             arg_inventory_item_id,
                         var_start_date,
                         arg_cutoff_date,
             var_bucket_start_date,
             arg_form_mode);
/*
    if var_return_value = FALSE THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
       -- raise exception later
       -- need to modify the following later for message dictionary
    END IF;
*/
    ELSIF arg_form_mode = QUERY_MODE THEN
      IF (arg_forecast_designator is not NULL
        AND arg_forecast_designator <> ' ') THEN
        var_return_value := bucket_fc_desig(
                 arg_org_id,
             arg_query_id,
             arg_secondary_query_id,
             arg_bucket_type,
             arg_past_due,
                         arg_forecast_designator,
             arg_inventory_item_id,
                         var_start_date,
                         arg_cutoff_date,
             var_bucket_start_date,
             arg_form_mode);
/*
    if var_return_value = FALSE THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
           -- raise exception later
       -- need to modify the following later for message dictionary
    END IF;
*/
     ELSE
       DECLARE
    CURSOR FORECAST_DESIGS IS
           SELECT  forecast_designator
           FROM    mrp_forecast_designators
           WHERE   organization_id = arg_org_id
           AND     (forecast_set = arg_forecast_set
         OR forecast_designator = arg_forecast_set);
       BEGIN
        FOR FORECAST_DESIGS_REC in FORECAST_DESIGS LOOP
         var_forecast_designator := FORECAST_DESIGS_REC.forecast_designator;
         var_return_value := bucket_fc_desig(
                 arg_org_id,
             arg_query_id,
             arg_secondary_query_id,
             arg_bucket_type,
             arg_past_due,
                         var_forecast_designator,
             arg_inventory_item_id,
                         var_start_date,
                         arg_cutoff_date,
             var_bucket_start_date,
             arg_form_mode);
/*
     if var_return_value = FALSE THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
        -- need to modify the following later for message dictionary
     END IF;
*/
        END LOOP;
       END;
     END IF;
   END IF;

   /*bucket the entries into mrp_form_query */
    var_return_value :=  fc_mrp_form_query(
                 arg_org_id,
             arg_query_id,
             arg_secondary_query_id,
             arg_bucket_type,
             arg_past_due,
                         arg_cutoff_date,
             var_bucket_start_date);
/*
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
*/
END BUCKET_ENTRIES;

END MRP_FORECAST;

/

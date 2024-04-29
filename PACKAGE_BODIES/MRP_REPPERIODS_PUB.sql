--------------------------------------------------------
--  DDL for Package Body MRP_REPPERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_REPPERIODS_PUB" AS
/* $Header: MRPPRPDB.pls 115.3 2004/07/22 22:17:44 skanta ship $ */

Procedure Maintain_Rep_Periods(arg_org_id      IN NUMBER,
                                arg_user_id     IN NUMBER) IS
        /*---------------------------+
         |  Variable delarations     |
         +---------------------------*/
    var_calendar_code       VARCHAR2(10);
    var_exception_set_id    NUMBER;
    param                   mrp_parameters%ROWTYPE;
    var_max_date            DATE;
    var_curr_date           DATE;
    var_curr_bucket         NUMBER := 1;
    var_end_date1           DATE;
    var_end_date2           DATE;
    var_last_date1          DATE;
    var_last_date2          DATE;
    var_last_date3          DATE;
    var_counter             NUMBER := 0;
    var_prev_workday        DATE := TO_DATE(1, 'J');
    var_curr_workday        DATE  := TO_DATE(1, 'J');
    WORKDATE_PERIODS        CONSTANT NUMBER := 1;
    CALENDAR_PERIODS        CONSTANT NUMBER := 2;
    BUCKET_TYPE             CONSTANT NUMBER := 1;
    VERSION                 CONSTANT CHAR(80) :=
        '$Header: MRPPRPDB.pls 115.3 2004/07/22 22:17:44 skanta ship $';
    var_buf varchar2(2000);
BEGIN
    --  Select the organization information
    SELECT  *
    INTO    param
    FROM    mrp_parameters
    WHERE   organization_id = arg_org_id;

    --  Select the calendar code and exception set id for this org
    mrp_calendar.select_calendar_defaults(
        arg_org_id,
        var_calendar_code,
        var_exception_set_id);

    --  Get the last date in this calendar
    SELECT  MAX(calendar_date)
    INTO    var_max_date
    FROM    bom_calendar_dates
    WHERE   calendar_code = var_calendar_code
      AND   exception_set_id = var_exception_set_id
      AND   seq_num IS NOT NULL;

    DELETE FROM mrp_repetitive_periods
    WHERE  organization_id = arg_org_id;

    var_curr_date := param.repetitive_anchor_date;

    -- Calculate the end date for each bucket
    IF param.period_type = WORKDATE_PERIODS THEN
        -- Set the end dates according to workdates
        var_end_date1 := mrp_calendar.date_offset(
            arg_org_id,
            BUCKET_TYPE,
            param.repetitive_anchor_date,
            param.repetitive_horizon1);

        var_end_date2 := mrp_calendar.date_offset(
            arg_org_id,
            BUCKET_TYPE,
            var_end_date1,
            param.repetitive_horizon2);

        var_last_date1 := mrp_calendar.date_offset(
            arg_org_id,
            BUCKET_TYPE,
            var_max_date,
            -1 * param.repetitive_bucket_size1);

        var_last_date2 := mrp_calendar.date_offset(
            arg_org_id,
            BUCKET_TYPE,
            var_max_date,
            -1 * param.repetitive_bucket_size2);

        var_last_date3 := mrp_calendar.date_offset(
            arg_org_id,
            BUCKET_TYPE,
            var_max_date,
            -1 * param.repetitive_bucket_size3);
    ELSE
        var_end_date1 := param.repetitive_anchor_date +
            param.repetitive_horizon1;
        var_end_date2 := var_end_date1 + param.repetitive_horizon2;
        var_last_date1 := var_max_date - param.repetitive_bucket_size1;
        var_last_date2 := var_max_date - param.repetitive_bucket_size2;
        var_last_date3 := var_max_date - param.repetitive_bucket_size3;
    END IF;


    WHILE TRUE LOOP
        -- Keep looping, until you reach the end of the calendar...for each
        -- period, insert into the table mrp_repetitive_periods

        -- Get the current workday

       BEGIN
        SELECT  next_date
        INTO    var_curr_workday
        FROM    bom_calendar_dates
        WHERE   calendar_code = var_calendar_code
        AND     exception_set_id = var_exception_set_id
        AND     calendar_date = var_curr_date;
       EXCEPTION
         WHEN NO_DATA_FOUND then
           FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
           var_buf := fnd_message.get;
           fnd_file.put_line(FND_FILE.log, var_buf);
           raise;
          WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unhandled Exception : '||sqlerrm);
            raise;
       END;

        IF var_curr_workday <> var_prev_workday THEN
            INSERT INTO mrp_repetitive_periods
            (
                period_start_date,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
            )
            VALUES
            (
                var_curr_workday,
                arg_org_id,
                SYSDATE,
                arg_user_id,
                SYSDATE,
                arg_user_id,
                -1
            );
        END IF;
        var_prev_workday := var_curr_workday;

        --  Adjust the var_current_date variable to the next date
        --  If that brings you to the next bucket type, then shift the
        --  variable var_curr_bucket
        IF var_curr_bucket = 1 THEN     -- First bucket
            IF param.period_type = WORKDATE_PERIODS THEN
                var_curr_date := mrp_calendar.date_offset(
                    arg_org_id,
                    BUCKET_TYPE,
                    var_curr_date,
                    param.repetitive_bucket_size1);
            ELSE
                var_curr_date := var_curr_date + param.repetitive_bucket_size1;
            END IF;

            IF var_curr_date >= var_end_date1 THEN
                var_curr_bucket := 2;
            END IF;
        ELSIF var_curr_bucket = 2 THEN      -- Second bucket
            IF param.period_type = WORKDATE_PERIODS THEN
                var_curr_date := mrp_calendar.date_offset(
                    arg_org_id,
                    BUCKET_TYPE,
                    var_curr_date,
                    param.repetitive_bucket_size2);
            ELSE
                var_curr_date := var_curr_date + param.repetitive_bucket_size2;
            END IF;

            IF var_curr_date >= var_end_date2 THEN
                var_curr_bucket := 3;
            END IF;
        ELSE
            IF param.period_type = WORKDATE_PERIODS THEN
                var_curr_date := mrp_calendar.date_offset(
                    arg_org_id,
                    BUCKET_TYPE,
                    var_curr_date,
                    param.repetitive_bucket_size3);
            ELSE
                var_curr_date := var_curr_date + param.repetitive_bucket_size3;
            END IF;
        END IF;

        --  Have we reached the end of the calendar?
        IF ( var_curr_bucket = 1 AND var_curr_date < var_last_date1) OR
           ( var_curr_bucket = 2 AND var_curr_date < var_last_date2) OR
           ( var_curr_bucket = 3 AND var_curr_date < var_last_date3)
        THEN
            NULL;           -- No...keep going
        ELSE
            EXIT;           -- Yes...break out of the loop
        END IF;

    END LOOP;

    --  We want to adjust all non-workday periods to the next valid workday.
    --  However, we want to make sure that this does not result in duplicates.
    --  Therefore only update those where a row does not exist for the next
    --  workday.  We'll delete those that are not updated in the next step.
    UPDATE mrp_repetitive_periods s
    SET     period_start_date =
            (SELECT next_date
            FROM    bom_calendar_dates
            WHERE   calendar_code = var_calendar_code
              AND   exception_set_id = var_exception_set_id
              AND   calendar_date = s.period_start_date)
    WHERE   EXISTS
            (SELECT NULL
            FROM    bom_calendar_dates  d
            WHERE   NOT EXISTS
                    (SELECT NULL
                    FROM    mrp_repetitive_periods
                    WHERE   organization_id = s.organization_id
                      AND   period_start_date = d.next_date)
              AND   seq_num IS NULL
              AND   calendar_code = var_calendar_code
              AND   exception_set_id = var_exception_set_id
              AND   calendar_date = s.period_start_date)
      AND   organization_id = arg_org_id;

    DELETE FROM mrp_repetitive_periods   s
    WHERE   organization_id = arg_org_id
      AND   EXISTS
            (SELECT NULL
            FROM    bom_calendar_dates  d
            WHERE   seq_num IS NULL
              AND   calendar_code = var_calendar_code
              AND   exception_set_id = var_exception_set_id
              AND   calendar_date = s.period_start_date);
    COMMIT;
END Maintain_Rep_Periods;
END;


/

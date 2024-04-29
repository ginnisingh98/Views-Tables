--------------------------------------------------------
--  DDL for Package Body MRP_ADJUST_DATES_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ADJUST_DATES_PK" AS
 /* $Header: MRPPADTB.pls 120.1 2005/10/09 23:59:01 rgurugub noship $ */
    -- ******************* mrp_adjust_dates_by_calendar *********************
    PROCEDURE   mrp_adjust_dates_by_calendar(
                            cal_code        IN      VARCHAR2,
                            except_set_id   IN      NUMBER,
                            user_id         IN      NUMBER,
                            error_msg       IN OUT NOCOPY  VARCHAR2) IS
    org_id      NUMBER;
    CURSOR  organizations_cur IS
        SELECT  organization_id
        FROM    mtl_parameters mtl
        WHERE   mtl.calendar_code = cal_code
        AND     mtl.calendar_exception_set_id = except_set_id;

    l_error_msg VARCHAR2(240);

    BEGIN

        l_error_msg := error_msg;

        OPEN    organizations_cur;
        LOOP
            FETCH   organizations_cur   INTO
                    org_id;

            EXIT WHEN organizations_cur%NOTFOUND;
            mrp_adjust_dates_by_org(cal_code, except_set_id,
                        org_id, user_id, error_msg);

            IF error_msg is not null then
                EXIT;
            END IF;

        END LOOP;

    EXCEPTION WHEN OTHERS THEN
      error_msg := l_error_msg;

    END mrp_adjust_dates_by_calendar;   -- END mrp_adjust_dates_by_calendar

    -- *********************** mrp_adjust_dates_by_org ********************

    PROCEDURE   mrp_adjust_dates_by_org(
                            cal_code        IN  VARCHAR2,
                            except_set_id   IN  NUMBER,
                            org_id          IN  NUMBER,
                            user_id         IN  NUMBER,
                            error_msg       IN OUT NOCOPY  VARCHAR2) IS
                min_date            DATE;
                max_date            DATE;
                statement           INTEGER := 0;
                string_buffer       CHAR(1);
                forecast_exists     BOOLEAN := FALSE;
                demand_exists       BOOLEAN := FALSE;

                l_error_msg VARCHAR2(240);
    BEGIN

      l_error_msg := error_msg;

      BEGIN
            SELECT 'x' into string_buffer
            FROM dual
            WHERE exists
            (SELECT schedule_date
            FROM   mrp_schedule_dates
            WHERE  organization_id = org_id);
            demand_exists := TRUE;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
            demand_exists := FALSE;
      END;

      BEGIN
            SELECT 'x' into string_buffer
            FROM dual
            WHERE exists
                (SELECT forecast_date
                FROM    mrp_forecast_dates
                WHERE   organization_id = org_id);
                forecast_exists := TRUE;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
             forecast_exists := FALSE;
      END;



--  Select the minimum and maximum calendar_dates if no rows exist then raise
--  exception
     IF forecast_exists or demand_exists THEN
        SELECT min(calendar_date), max(calendar_date)
        INTO    min_date, max_date
        FROM    bom_calendar_dates
        WHERE   exception_set_id = except_set_id
        AND     calendar_code = cal_code;

        IF min_date IS NULL THEN
            raise no_data_found;
        END IF;
        statement := 1;

    END IF;
--  Check if enough data exists in the calendar to cover the current dates
--  in mrp_schedule_dates
   IF demand_exists THEN
        SELECT  'x' INTO string_buffer
        FROM    dual
        WHERE   NOT EXISTS
                (SELECT schedule_date
                 FROM   mrp_schedule_dates
                 WHERE  organization_id = org_id
                 AND    schedule_date < min_date
		 AND schedule_level=2)
        AND     NOT EXISTS
                (SELECT schedule_date
                 FROM   mrp_schedule_dates
                 WHERE  organization_id = org_id
                 AND    DECODE(rate_end_date, NULL, schedule_date,
                                rate_end_date) > max_date
				AND schedule_level=2);
        statement := 2;
    END IF;
--  Check if enough data exists in the calendar to cover the current dates
--  in mrp_forecast_dates
     IF forecast_exists THEN

        SELECT  'x' INTO string_buffer
        FROM    dual
        WHERE   NOT EXISTS
                (SELECT forecast_date
                FROM    mrp_forecast_dates
                WHERE   organization_id = org_id
                AND    forecast_date < min_date)
        AND     NOT EXISTS
                (SELECT forecast_date
                FROM    mrp_forecast_dates
                WHERE  organization_id = org_id
                AND    DECODE(rate_end_date, NULL, forecast_date,
                                rate_end_date) > max_date);
     END IF;

--  Update the schedule workdate to be the next valid work date for MPS,
--  and the previous valid workdate for MDS.

--  For multi-org schedules we check the schedule type in the owning
--  org  for entries in the current org

    IF demand_exists THEN
        UPDATE  mrp_schedule_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.schedule_workdate =
                (SELECT     DECODE(desig.schedule_type, 1, prior_date,
                                    next_date)
                FROM        bom_calendar_dates          cal,
                            mrp_schedule_designators    desig
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
/*2285842         AND       cal.calendar_date = dates.schedule_workdate*/
                  AND       cal.calendar_date = dates.schedule_date
                  AND       desig.organization_id
                            in (select organization_id
                                from    mrp_plan_organizations_v  orgs
                                where   orgs.compile_designator =
                                            dates.schedule_designator
                                and     orgs.planned_organization =
                                        dates.organization_id
                                union all
                                select  org_id
                                from    dual)
                  AND       desig.schedule_designator =
                                dates.schedule_designator)
        WHERE   dates.organization_id = org_id
          AND   dates.schedule_level = 2;

--  Set the schedule date to be a valid workdate if it's repetitive or if
--  it's an MPS

--  We check the schedule_type from the owning org for multi-org schedules

        UPDATE  mrp_schedule_dates  dates
        SET     dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id,
                dates.schedule_date = schedule_workdate
        WHERE   ((organization_id, schedule_designator) IN
                (SELECT org_id, desig.schedule_designator
                FROM    mrp_schedule_designators desig,
                        mrp_plan_organizations_v orgs
                WHERE   orgs.planned_organization (+) = org_id
                AND     desig.organization_id = NVL(orgs.organization_id,
                                                org_id)
                AND     desig.schedule_designator =
                            orgs.compile_designator (+)
                AND     desig.schedule_type = 2)  OR
                dates.rate_end_date IS NOT NULL)
          AND   dates.organization_id = org_id;

--  Always set the rate end date to be the previous valid date for repetitive
--  entries

        UPDATE  mrp_schedule_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.rate_end_date =
                (SELECT     GREATEST(prior_date, dates.schedule_date)
                FROM        bom_calendar_dates          cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.calendar_date = dates.rate_end_date)
        WHERE   dates.rate_end_date IS NOT NULL
          AND   dates.schedule_level = 2
          AND   dates.organization_id = org_id;
     END IF;
--  Set daily forecast entries to be valid dates
   IF forecast_exists THEN

        UPDATE  mrp_forecast_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.forecast_date =
                (SELECT     prior_date
                FROM        bom_calendar_dates          cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.calendar_date = dates.forecast_date)
        WHERE   dates.bucket_type = 1
          AND   dates.organization_id = org_id;

--  Set end dates for daily forecast entries to be valid dates

        UPDATE  mrp_forecast_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.rate_end_date =
                (SELECT     prior_date
                FROM        bom_calendar_dates          cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.calendar_date = dates.rate_end_date)
        WHERE   dates.rate_end_date IS NOT NULL
          AND   dates.bucket_type = 1
          AND   organization_id = org_id;

--  Set weekly forecast entries to be valid dates

        UPDATE  mrp_forecast_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.forecast_date =
                (SELECT     MAX(week_start_date)
                FROM        bom_cal_week_start_dates        cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.week_start_date <= dates.forecast_date)
        WHERE   dates.bucket_type = 2
          AND   dates.organization_id = org_id;


--  Set weekly end dates to be valid dates

        UPDATE  mrp_forecast_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.rate_end_date =
                (SELECT     MAX(week_start_date)
                FROM        bom_cal_week_start_dates        cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.week_start_date <= dates.rate_end_date)
        WHERE   dates.rate_end_date IS NOT NULL
          AND   dates.bucket_type = 2
          AND   dates.organization_id = org_id;

--  Set monthly forecast entries to be valid dates

        UPDATE  mrp_forecast_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.forecast_date =
                (SELECT     MAX(period_start_date)
                FROM        bom_period_start_dates          cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.period_start_date <= dates.forecast_date)
        WHERE   dates.bucket_type = 3
          AND   dates.organization_id = org_id;

--  Set monthly end dates to be valid dates

        UPDATE  mrp_forecast_dates  dates
        SET /*  dates.last_update_date = SYSDATE,
                dates.last_updated_by = user_id, */
                dates.rate_end_date =
                (SELECT     MAX(period_start_date)
                FROM        bom_period_start_dates          cal
                WHERE       cal.calendar_code = cal_code
                  AND       cal.exception_set_id = except_set_id
                  AND       cal.period_start_date <= dates.rate_end_date)
        WHERE   dates.rate_end_date IS NOT NULL
          AND   dates.bucket_type = 3
          AND   dates.organization_id = org_id;
    END IF;
--  Set the snapshot and plan completion date to NULL
    IF demand_exists or forecast_exists then
        UPDATE  mrp_plans
        SET     data_completion_date = NULL,
                plan_completion_date = NULL
        WHERE   (compile_designator , organization_id) in
		(SELECT compile_designator , organization_id
		 FROM mrp_plan_organizations_v
		 WHERE
			planned_organization = org_id);

        COMMIT;
    end if;
        error_msg := NULL;

    EXCEPTION
        WHEN no_data_found THEN
            IF statement = 0 THEN
                error_msg := 'GEN-calendar not compiled';
            ELSIF statement = 1 THEN
                error_msg := 'GEN-invalid schedules';
            ELSE
                error_msg := 'GEN-invalid forecasts';
            END IF;
        WHEN OTHERS THEN
            error_msg := l_error_msg;

    END mrp_adjust_dates_by_org;    -- END mrp_adjust_dates_by_org
END mrp_adjust_dates_pk;    -- END PACKAGE

/

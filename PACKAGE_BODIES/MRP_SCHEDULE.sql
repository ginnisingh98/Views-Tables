--------------------------------------------------------
--  DDL for Package Body MRP_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCHEDULE" AS
/* $Header: MRSCHDBB.pls 120.1 2005/06/16 14:02:21 ichoudhu noship $ */

  TYPE_DAILY_BUCKET      CONSTANT NUMBER := 1;
  TYPE_WEEKLY_BUCKET     CONSTANT NUMBER := 2;
  TYPE_MONTHLY_BUCKET    CONSTANT NUMBER := 3;

  SYS_YES                CONSTANT NUMBER := 1;
  TYPE_CURRENT_QTY       CONSTANT NUMBER := 2;


Procedure BUCKET_ENTRIES( arg_query_id1             IN NUMBER,
                          arg_query_id2             IN NUMBER,
                          arg_org_id                IN NUMBER,
                          arg_schedule_designator   IN VARCHAR2,
                          arg_inventory_item_id     IN NUMBER,
                          arg_bucket_type           IN NUMBER,
                          arg_quantity_type         IN NUMBER,
                          arg_version_type          IN NUMBER,
                          arg_past_due              IN NUMBER,
                          arg_start_date            IN DATE,
                          arg_cutoff_date           IN DATE ) IS

  var_start_date        DATE;
  var_cutoff_date       DATE;
  var_prev_valid_date   DATE;
  var_last_cal_date	DATE;
  var_tmp_quantity      NUMBER;
  var_tmp_value         NUMBER;
  var_tmp_copied_sched  NUMBER;
  var_tmp_mps_plan      NUMBER;
  var_tmp_manual        NUMBER;
  var_tmp_forecast      NUMBER;
  var_tmp_sales_order   NUMBER;
  var_tmp_exploded      NUMBER;
  var_tmp_interorg      NUMBER;

  var_quantity          NUMBER;
  var_cum_quantity      NUMBER := 0;
  var_rowid             ROWID;

  CURSOR form_query IS
    SELECT  number1, rowid
    FROM    mrp_form_query
    WHERE   query_id = arg_query_id1
    ORDER BY date1;

BEGIN
    --
    -- Get last calendar date
    --
    var_last_cal_date := mrp_calendar.next_work_day(arg_org_id,
			 TYPE_DAILY_BUCKET, arg_cutoff_date);

    --
    -- Populate MRP_FORM_QUERY
    --
    -- The view MRP_DAILY_SCHEDULES_V has already:
    --
    --      - bucketed the discrete schedule entries into the correct
    --        workdate (previous workdate for invalid workdate)
    --
    --      - bucketed the repetitive schedule into daily schedule on
    --        valid workdate
    --
    --      - selected only schedules of type DEMAND for MDS,
    --        SUPPLY for MPS
    --
    IF (arg_bucket_type = TYPE_DAILY_BUCKET) THEN

      var_start_date := mrp_calendar.prev_work_day(arg_org_id,
                        TYPE_DAILY_BUCKET, arg_start_date);

      --
      -- Insert schedules in daily bucket
      --
      INSERT INTO mrp_form_query
       (QUERY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DATE1,              -- valid work date
        DATE2,              -- next valid work date
        NUMBER1,            -- daily quantity
        NUMBER3,            -- daily cum qty
        NUMBER5,            -- orig: copied schedule
        NUMBER6,            -- orig: MPS plan
        NUMBER7,            -- orig: manual entry
        NUMBER8,            -- orig: forecast
        NUMBER9,            -- orig: sales order
        NUMBER11,           -- orig: exploded
        NUMBER12)           -- orig: interorg order
      SELECT
        arg_query_id1,
        sysdate,
        -1,
        sysdate,
        -1,
        dates.calendar_date,
        dates.next_date,
        -- daily quantity
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.current_quantity,
                       sched.original_quantity)),
            0),
        -- cumulative quantity
        0,
        -- orig: copied schedule
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.copied_sched_qty,
                       sched.original_copied_sched_qty)),
            0),
        -- orig: MPS plan
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.mps_plan_qty,
                       sched.original_mps_plan_qty)),
            0),
        -- orig: manual entry
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.manual_qty,
                       sched.original_manual_qty)),
            0),
        -- orig: forecast
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.forecast_qty,
                       sched.original_forecast_qty)),
            0),
        -- orig: sales order
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.sales_order_qty,
                       sched.original_sales_order_qty)),
            0),
        -- orig: exploded
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.exploded_qty,
                       sched.original_exploded_qty)),
            0),
        -- orig: interorg order
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.interorg_qty,
                       sched.original_interorg_qty)),
            0)
      FROM  bom_calendar_dates          dates,
            mrp_daily_schedules_v       sched,
            mtl_parameters              param
      WHERE param.organization_id               = arg_org_id
      AND   param.calendar_exception_set_id     = dates.exception_set_id
      AND   param.calendar_code                 = dates.calendar_code
      AND   sched.organization_id            (+)= arg_org_id
      AND   sched.schedule_designator        (+)= arg_schedule_designator
      AND   sched.inventory_item_id          (+)= arg_inventory_item_id
      AND   sched.schedule_level             (+)= arg_version_type
      AND   sched.bucket_date                (+)= dates.calendar_date
      AND   sched.schedule_date             (+)>= arg_start_date
      AND   dates.calendar_date BETWEEN var_start_date
                                AND     arg_cutoff_date
      AND   dates.seq_num is not NULL
      GROUP BY arg_query_id1, dates.calendar_date, dates.next_date;


    ELSIF (arg_bucket_type = TYPE_WEEKLY_BUCKET) THEN

      var_start_date := mrp_calendar.prev_work_day(arg_org_id,
                        TYPE_WEEKLY_BUCKET, arg_start_date);

      --
      -- Insert schedules in weekly buckets for those weeks that have
      -- entries
      --
      INSERT INTO mrp_form_query
       (QUERY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DATE1,              -- week start date
        DATE2,              -- next week start date
        NUMBER1,            -- weekly quantity
        NUMBER3,            -- weekly cum qty
        NUMBER5,            -- orig: copied schedule
        NUMBER6,            -- orig: MPS plan
        NUMBER7,            -- orig: manual entry
        NUMBER8,            -- orig: forecast
        NUMBER9,            -- orig: sales order
        NUMBER11,           -- orig: exploded
        NUMBER12)           -- orig: interorg order
      SELECT
        arg_query_id2,
        sysdate,
        -1,
        sysdate,
        -1,
        dates.week_start_date,
        dates.next_date,
        -- weekly quantity
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.current_quantity,
                       sched.original_quantity)),
            0),
        -- cumulative quantity
        0,
        -- orig: copied schedule
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.copied_sched_qty,
                       sched.original_copied_sched_qty)),
            0),
        -- orig: MPS plan
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.mps_plan_qty,
                       sched.original_mps_plan_qty)),
            0),
        -- orig: manual entry
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.manual_qty,
                       sched.original_manual_qty)),
            0),
        -- orig: forecast
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.forecast_qty,
                       sched.original_forecast_qty)),
            0),
        -- orig: sales order
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.sales_order_qty,
                       sched.original_sales_order_qty)),
            0),
        -- orig: exploded
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.exploded_qty,
                       sched.original_exploded_qty)),
            0),
        -- orig: interorg order
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.interorg_qty,
                       sched.original_interorg_qty)),
            0)
      FROM  bom_cal_week_start_dates        dates,
            mrp_daily_schedules_v           sched,
            mtl_parameters                  param
      WHERE param.organization_id               = arg_org_id
      AND   param.calendar_exception_set_id     = dates.exception_set_id
      AND   param.calendar_code                 = dates.calendar_code
      AND   sched.organization_id               = arg_org_id
      AND   sched.schedule_designator           = arg_schedule_designator
      AND   sched.inventory_item_id             = arg_inventory_item_id
      AND   sched.schedule_level                = arg_version_type
      AND   sched.bucket_date                  >= dates.week_start_date
      AND   sched.bucket_date                   <
	      DECODE(dates.next_date, dates.week_start_date, var_last_cal_date,
		     dates.next_date)
      AND   sched.schedule_date BETWEEN arg_start_date
                                AND     arg_cutoff_date
      GROUP BY arg_query_id2, dates.week_start_date, dates.next_date;

      --
      -- Outer-joined with BOM_CAL_WEEK_START_DATES to get those
      -- weeks that do not have entries
      --
      INSERT INTO mrp_form_query
       (QUERY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DATE1,              -- week start date
        DATE2,              -- next week start date
        NUMBER1,            -- weekly quantity
        NUMBER3,            -- weekly cum qty
        NUMBER5,            -- orig: copied schedule
        NUMBER6,            -- orig: MPS plan
        NUMBER7,            -- orig: manual entry
        NUMBER8,            -- orig: forecast
        NUMBER9,            -- orig: sales order
        NUMBER11,           -- orig: exploded
        NUMBER12)           -- orig: interorg order
      SELECT
        arg_query_id1,
        sysdate,
        -1,
        sysdate,
        -1,
        dates.week_start_date,
        dates.next_date,
        NVL(SUM(query.number1), 0),     -- weekly quantity
        0,                              -- cumulative quantity
        NVL(SUM(query.number5), 0),     -- orig: copied schedule
        NVL(SUM(query.number6), 0),     -- orig: MPS plan
        NVL(SUM(query.number7), 0),     -- orig: manual entry
        NVL(SUM(query.number8), 0),     -- orig: forecast
        NVL(SUM(query.number9), 0),     -- orig: sales order
        NVL(SUM(query.number11), 0),    -- orig: exploded
        NVL(SUM(query.number12), 0)     -- orig: interorg order
      FROM  bom_cal_week_start_dates    dates,
            mrp_form_query              query,
            mtl_parameters              param
      WHERE param.organization_id               = arg_org_id
      AND   param.calendar_exception_set_id     = dates.exception_set_id
      AND   param.calendar_code                 = dates.calendar_code
      AND   query.query_id                   (+)= arg_query_id2
      AND   query.date1                      (+)= dates.week_start_date
      AND   dates.week_start_date BETWEEN var_start_date
                                  AND     arg_cutoff_date
      GROUP BY arg_query_id1, dates.week_start_date, dates.next_date;


    ELSIF (arg_bucket_type = TYPE_MONTHLY_BUCKET) THEN

      var_start_date := mrp_calendar.prev_work_day(arg_org_id,
                        TYPE_MONTHLY_BUCKET, arg_start_date);

      --
      -- Insert schedules in periodic buckets for those periods that have
      -- entries
      --
      INSERT INTO mrp_form_query
       (QUERY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DATE1,              -- period start date
        DATE2,              -- next period start date
        NUMBER1,            -- period quantity
        NUMBER3,            -- period cum qty
        NUMBER5,            -- orig: copied schedule
        NUMBER6,            -- orig: MPS plan
        NUMBER7,            -- orig: manual entry
        NUMBER8,            -- orig: forecast
        NUMBER9,            -- orig: sales order
        NUMBER11,           -- orig: exploded
        NUMBER12)           -- orig: interorg order
      SELECT
        arg_query_id2,
        sysdate,
        -1,
        sysdate,
        -1,
        dates.period_start_date,
        dates.next_date,
        -- period quantity
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.current_quantity,
                       sched.original_quantity)),
            0),
        -- cumulative quantity
        0,
        -- orig: copied schedule
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.copied_sched_qty,
                       sched.original_copied_sched_qty)),
            0),
        -- orig: MPS plan
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.mps_plan_qty,
                       sched.original_mps_plan_qty)),
            0),
        -- orig: manual entry
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.manual_qty,
                       sched.original_manual_qty)),
            0),
        -- orig: forecast
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.forecast_qty,
                       sched.original_forecast_qty)),
            0),
        -- orig: sales order
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.sales_order_qty,
                       sched.original_sales_order_qty)),
            0),
        -- orig: exploded
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.exploded_qty,
                       sched.original_exploded_qty)),
            0),
        -- orig: interorg order
        NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                       sched.interorg_qty,
                       sched.original_interorg_qty)),
            0)
      FROM  bom_period_start_dates      dates,
            mrp_daily_schedules_v       sched,
            mtl_parameters              param
      WHERE param.organization_id               = arg_org_id
      AND   param.calendar_exception_set_id     = dates.exception_set_id
      AND   param.calendar_code                 = dates.calendar_code
      AND   sched.organization_id               = arg_org_id
      AND   sched.schedule_designator           = arg_schedule_designator
      AND   sched.inventory_item_id             = arg_inventory_item_id
      AND   sched.schedule_level                = arg_version_type
      AND   sched.bucket_date                  >= dates.period_start_date
      AND   sched.bucket_date                   <
              DECODE(dates.next_date, dates.period_start_date,
		     var_last_cal_date, dates.next_date)
      AND   sched.schedule_date BETWEEN arg_start_date
                                AND     arg_cutoff_date
      GROUP BY arg_query_id2, dates.period_start_date, dates.next_date;

      --
      -- Outer-joined with BOM_PERIOD_START_DATES to get those
      -- periods that do not have entries
      --
      INSERT INTO mrp_form_query
       (QUERY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DATE1,              -- period start date
        DATE2,              -- next period start date
        NUMBER1,            -- period quantity
        NUMBER3,            -- period cum qty
        NUMBER5,            -- orig: copied schedule
        NUMBER6,            -- orig: MPS plan
        NUMBER7,            -- orig: manual entry
        NUMBER8,            -- orig: forecast
        NUMBER9,            -- orig: sales order
        NUMBER11,           -- orig: exploded
        NUMBER12)           -- orig: interorg order
      SELECT
        arg_query_id1,
        sysdate,
        -1,
        sysdate,
        -1,
        dates.period_start_date,
        dates.next_date,
        NVL(SUM(query.number1), 0),     -- period quantity
        0,                              -- cumulative quantity
        NVL(SUM(query.number5), 0),     -- orig: copied schedule
        NVL(SUM(query.number6), 0),     -- orig: MPS plan
        NVL(SUM(query.number7), 0),     -- orig: manual entry
        NVL(SUM(query.number8), 0),     -- orig: forecast
        NVL(SUM(query.number9), 0),     -- orig: sales order
        NVL(SUM(query.number11), 0),    -- orig: exploded
        NVL(SUM(query.number12), 0)     -- orig: interorg order
      FROM  bom_period_start_dates      dates,
            mrp_form_query              query,
            mtl_parameters              param
      WHERE param.organization_id               = arg_org_id
      AND   param.calendar_exception_set_id     = dates.exception_set_id
      AND   param.calendar_code                 = dates.calendar_code
      AND   query.query_id                   (+)= arg_query_id2
      AND   query.date1                      (+)= dates.period_start_date
      AND   dates.period_start_date BETWEEN var_start_date
                                    AND     arg_cutoff_date
      GROUP BY arg_query_id1, dates.period_start_date, dates.next_date;

    END IF;

    IF (arg_past_due = SYS_YES) THEN

        --
        -- Sum up Past Due quantities
        --
        SELECT  NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.current_quantity,
                    sched.original_quantity)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.copied_sched_qty,
                    sched.original_copied_sched_qty)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.mps_plan_qty,
                    sched.original_mps_plan_qty)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.manual_qty,
                    sched.original_manual_qty)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.forecast_qty,
                    sched.original_forecast_qty)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.sales_order_qty,
                    sched.original_sales_order_qty)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.exploded_qty,
                    sched.original_exploded_qty)),
                    0),
            NVL(SUM(DECODE(arg_quantity_type, TYPE_CURRENT_QTY,
                    sched.interorg_qty,
                    sched.original_interorg_qty)),
                    0)
        INTO    var_tmp_quantity,
                var_tmp_copied_sched,
                var_tmp_mps_plan,
                var_tmp_manual,
                var_tmp_forecast,
                var_tmp_sales_order,
                var_tmp_exploded,
                var_tmp_interorg
        FROM    mrp_daily_schedules_v       sched
        WHERE   sched.organization_id       = arg_org_id
        AND     sched.schedule_designator   = arg_schedule_designator
        AND     sched.inventory_item_id     = arg_inventory_item_id
        AND     sched.schedule_level        = arg_version_type
        AND     sched.bucket_date           < arg_start_date;

        --
        -- Add the past due quantities to the start date bucket
        --
        UPDATE  MRP_FORM_QUERY
        SET     NUMBER1  = NUMBER1  + var_tmp_quantity,
                NUMBER5  = NUMBER5  + var_tmp_copied_sched,
                NUMBER6  = NUMBER6  + var_tmp_mps_plan,
                NUMBER7  = NUMBER7  + var_tmp_manual,
                NUMBER8  = NUMBER8  + var_tmp_forecast,
                NUMBER9  = NUMBER9  + var_tmp_sales_order,
                NUMBER11 = NUMBER11 + var_tmp_exploded,
                NUMBER12 = NUMBER12 + var_tmp_interorg
        WHERE   QUERY_ID = arg_query_id1
        AND     DATE1 = var_start_date;

    END IF;

    --
    -- Calculate cumulative quantities
    --
    OPEN form_query;

    LOOP
        FETCH form_query INTO var_quantity, var_rowid;

        EXIT WHEN form_query%NOTFOUND;

        var_cum_quantity := var_cum_quantity + var_quantity;

        UPDATE  mrp_form_query
        SET     number3 = var_cum_quantity
        WHERE   rowid = var_rowid;
    END LOOP;

    --COMMIT WORK;

END BUCKET_ENTRIES;



PROCEDURE Get_Nextval( X_query_id1     IN OUT  NOCOPY NUMBER,
                       X_query_id2     IN OUT  NOCOPY NUMBER ) IS
BEGIN

   SELECT MRP_FORM_QUERY_S.NEXTVAL
     INTO X_query_id1
     FROM dual;

   SELECT MRP_FORM_QUERY_S.NEXTVAL
     INTO X_query_id2
     FROM dual;

END Get_Nextval;



PROCEDURE Get_Cost( X_org_id            IN      NUMBER,
                    X_inventory_item_id IN      NUMBER,
                    X_cost          IN OUT  NOCOPY NUMBER ) IS
BEGIN

    SELECT    NVL(item_cost,0)
      INTO    X_cost
      FROM    cst_item_costs_for_gl_view
      WHERE   organization_id = X_org_id
      AND     inventory_item_id = X_inventory_item_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        X_cost := 0;

END Get_Cost;


PROCEDURE Get_Max_BOM_Level(X_organization_id           NUMBER,
                            X_mps_explosion_level       IN OUT  NOCOPY NUMBER) IS

   CURSOR C IS
     SELECT NVL(maximum_bom_level, 20)
       FROM BOM_PARAMETERS
      WHERE organization_id =  X_organization_id;

BEGIN

  OPEN C;

  FETCH C INTO X_mps_explosion_level;

  if (C%NOTFOUND) then
    CLOSE C;
    X_mps_explosion_level := 20;
  end if;

  CLOSE C;

END Get_Max_BOM_Level;


END MRP_SCHEDULE;

/

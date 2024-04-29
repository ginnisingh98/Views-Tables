--------------------------------------------------------
--  DDL for Package Body MRP_KANBAN_PLAN_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_KANBAN_PLAN_PK" AS
/* $Header: MRPKPLNB.pls 120.8 2006/05/26 01:47:08 ksuleman noship $  */

-- ========================================================================
--  This function will update the plan_start_date column in mrp_kanban_plans
--  table to indicate that the plan has started to run.  The user will not
--  be able to query up this plan until the plan has finished running.
-- ========================================================================
FUNCTION START_KANBAN_PLAN
RETURN BOOLEAN IS

l_plan_id		number;
l_bom_effectivity	date;
l_start_date		date;
l_cutoff_date		date;

-- declare exceptions we want to handle here
exc_error_condition     exception;
exc_replan_error	exception;

BEGIN

  g_stmt_num := 20;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Entering Start_Kanban_Plan function';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;


  -- ------------------------------------------------------------------------
  -- Validate the plan information
  -- ------------------------------------------------------------------------
  SELECT kanban_plan_id,
	 input_type,
	 input_designator,
  	 bom_effectivity_date,
  	 plan_start_date,
  	 plan_cutoff_date
  INTO 	l_plan_id,
	g_kanban_info_rec.input_type,
	g_kanban_info_rec.input_designator,
  	l_bom_effectivity,
  	l_start_date,
  	l_cutoff_date
  FROM mrp_kanban_plans
  WHERE kanban_plan_id = g_kanban_info_rec.kanban_plan_id;

  -- clean out data in some tables depending on whether we are
  -- replanning or not

  IF nvl(g_kanban_info_rec.replan_flag,2) = 1 THEN -- 1 is Yes, 2 is No

    g_kanban_info_rec.bom_effectivity := l_bom_effectivity;
    g_kanban_info_rec.start_date := l_start_date;
    g_kanban_info_rec.cutoff_date := l_cutoff_date;

    IF g_kanban_info_rec.bom_effectivity IS NULL OR
		g_kanban_info_rec.start_date IS NULL OR
			g_kanban_info_rec.cutoff_date IS NULL THEN
      raise exc_replan_error;
    END IF;

    -- delete all the entries from the low level codes table except
    -- entries list of kanban items that we had got in the very first
    -- snapshot of items during a regular plan run

    DELETE FROM mrp_low_level_codes
    WHERE  plan_id = g_kanban_info_rec.kanban_plan_id
    AND    organization_id = g_kanban_info_rec.organization_id
    AND	   (levels_below <> 1 OR
	    assembly_item_id = component_item_id OR
	    assembly_item_id = -1 );

    -- update the low level code of each of the remaining records to null
    UPDATE mrp_low_level_codes
    SET    low_level_code = null
    WHERE  plan_id = g_kanban_info_rec.kanban_plan_id
    AND    organization_id = g_kanban_info_rec.organization_id;

  ELSIF nvl(g_kanban_info_rec.replan_flag,2) = 2 THEN

    DELETE FROM mrp_low_level_codes
    WHERE  plan_id = g_kanban_info_rec.kanban_plan_id
    AND    organization_id = g_kanban_info_rec.organization_id;

    DELETE FROM mtl_kanban_pull_sequences
    WHERE  kanban_plan_id = g_kanban_info_rec.kanban_plan_id;

  END IF;

  DELETE FROM mrp_kanban_demand
  WHERE  kanban_plan_id = g_kanban_info_rec.kanban_plan_id
  AND	 organization_id = g_kanban_info_rec.organization_id;

/* this part of the code was originally in plan_kanban procedure
   but we moved it to here because we want to commit the snapshot
   data to have less impact on rollback segments
   So, as you will see we have put a commit after the call
   to snapshot_item_locations procedure
*/
  -- call the procedure to snapshot the item/locations and
  -- populate mrp_low_level_codes table.
  -- Note that we are calculating low level codes
  -- only to detect loops and not for planning purposes.
  -- We gather demand by looking at the input to the plan
  -- and then blow it down to the component item/locations

  IF NOT mrp_kanban_snapshot_pk.snapshot_item_locations THEN
    g_log_message := 'Error in SNAPSHOT_ITEM_LOCATIONS';
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;

  commit;

  -- ------------------------------------------------------------------------
  -- Update some plan information in mrp_kanban_plans table
  -- ------------------------------------------------------------------------
  UPDATE mrp_kanban_plans
  SET plan_start_date = g_kanban_info_rec.start_date,
      plan_completion_date = NULL,
      bom_effectivity_date =  g_kanban_info_rec.bom_effectivity,
      plan_cutoff_date = g_kanban_info_rec.cutoff_date
  WHERE kanban_plan_id = g_kanban_info_rec.kanban_plan_id;

  RETURN TRUE;

EXCEPTION

  WHEN exc_error_condition THEN
    ROLLBACK;
    g_log_message := 'Program encountered Error condition Exception';
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

  WHEN exc_replan_error THEN
    g_log_message := 'Incomplete Information For Replan';
    MRP_UTIL.MRP_LOG (g_log_message);
    Return FALSE;

  WHEN NO_DATA_FOUND THEN
    g_log_message := 'Invalid Kanban Plan Id';
    MRP_UTIL.MRP_LOG (g_log_message);
    Return FALSE;

  WHEN OTHERS THEN
    g_log_message := 'START_KANBAN_PLAN Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END START_KANBAN_PLAN;

-- ========================================================================
--  This function will update the plan_completion_date column in
--  mrp_kanban_plans table to indicate that the plan has successfully
--  finished.
-- ========================================================================
FUNCTION END_KANBAN_PLAN
RETURN BOOLEAN IS
BEGIN

  IF g_debug THEN
    g_log_message := 'In End_Kanban_Plan function';
    fnd_file.put_line (fnd_file.log, g_log_message);
  END IF;

  -- ------------------------------------------------------------------------
  -- Update the plan_completion_date to sysdate
  -- ------------------------------------------------------------------------
    UPDATE mrp_kanban_plans
    SET plan_completion_date = sysdate
    WHERE kanban_plan_id = g_kanban_info_rec.kanban_plan_id;

    -- commit the changes to the database
    COMMIT;

    RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN
    g_log_message := 'END_KANBAN_PLAN Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END END_KANBAN_PLAN;

-- ========================================================================
-- this function gets the # of working days between start and end dates
-- for a MDS and mulitplies that into the repetitive demnad
-- this is done only for the MDS and repetitive items.
-- ========================================================================

FUNCTION Get_Repetitive_Demand(
        p_schedule_date         IN  DATE,
        p_rate_end_date         IN  DATE,
        p_repetitive_daily_rate IN  NUMBER)
RETURN NUMBER IS
   l_days NUMBER :=0;

     CURSOR c1 IS
     SELECT count(*) count
     FROM bom_calendar_dates bcd,
           mtl_parameters mp
    WHERE  mp.organization_id  = g_kanban_info_rec.organization_id
    AND    bcd.calendar_code =  mp.calendar_code
    AND    bcd.exception_set_id = mp.calendar_exception_set_id
    AND    bcd.calendar_date between
           p_schedule_date and p_rate_end_date
    AND    bcd.seq_num IS NOT NULL;
BEGIN

  IF NOT c1%ISOPEN THEN
    OPEN c1;
  END IF;
  FETCH     c1
      INTO      l_days;
  l_days:= l_days * p_repetitive_daily_rate;
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;

  RETURN l_days;
END Get_Repetitive_Demand;


-- ========================================================================
-- This function finds out if we need to prorate forecast demand and if
-- necessary prorates the demand for a weekly or periodic forecast, ie., when
-- a part of which falls outside the kanban plan start and cutoff dates
-- ========================================================================

FUNCTION Get_Prorated_Demand (
	p_bucket_type		IN	number,
	p_in_demand_date	IN	date,
	p_in_rate_end_date	IN	date,
 	p_in_demand_qty		IN	number,
	p_out_demand_date	IN OUT	NOCOPY	date,
	p_out_demand_qty	IN OUT	NOCOPY	number
)
RETURN BOOLEAN
IS

l_total_workdays	number;
l_current_workdays	number;
l_demand_quantity	number;
l_demand_date		date;
l_next_date		date;

BEGIN

  IF g_debug THEN
    g_log_message := 'Entering Get_Prorated_Demand Function';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Bucket_Type : ' || to_char (p_bucket_type);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'In demand date : ' ||
    fnd_date.date_to_canonical(p_in_demand_date);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'In Rate end date : ' ||
    fnd_date.date_to_canonical(p_in_rate_end_date);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'In demand qty : ' || to_char (p_in_demand_qty);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;
  --initialize

  l_demand_date := p_in_demand_date;
  l_next_date := p_in_rate_end_date;
  p_out_demand_date := p_in_demand_date;
  p_out_demand_qty := p_in_demand_qty;

  -- first find out if we need to prorate the demand or not

  IF p_bucket_type = 1 THEN
    -- daily forecast,  no need to prorate
    RETURN TRUE;

  ELSIF p_bucket_type = 2 OR p_bucket_type = 3 THEN

    IF p_in_rate_end_date IS NULL AND
      (p_in_demand_date BETWEEN g_kanban_info_rec.start_date AND
       Get_Offset_Date (g_kanban_info_rec.cutoff_date,
			p_bucket_type )) THEN
      --no need to prorate
      RETURN TRUE;
    ELSIF p_in_rate_end_date IS NOT NULL AND
	  (p_in_demand_date >= g_kanban_info_rec.start_date AND
           p_in_rate_end_date <= Get_Offset_Date (
					g_kanban_info_rec.cutoff_date,
					p_bucket_type ))  THEN
      --no need to prorate
      RETURN TRUE;

    END IF;

  END IF;

  --If we come here then it means that we have to prorate the demand

  --First Get the total number of workdays in the period we are
  --about to consider

  IF p_bucket_type = 2 THEN

    SELECT count(*)
    INTO   l_total_workdays
    FROM   bom_calendar_dates cd,
           bom_cal_week_start_dates ws,
	   mtl_parameters mp
    WHERE  mp.organization_id  = g_kanban_info_rec.organization_id
    AND    ws.calendar_code =  mp.calendar_code
    AND    ws.exception_set_id = mp.calendar_exception_set_id
    AND    ws.week_start_date = l_demand_date
    AND    cd.calendar_code = ws.calendar_code
    AND    cd.exception_set_id = ws.exception_set_id
    AND    (cd.calendar_date BETWEEN ws.week_start_date AND
					ws.next_date)
    AND    cd.seq_num IS NOT NULL;

  ELSIF p_bucket_type = 3 THEN

    SELECT count(*)
    INTO   l_total_workdays
    FROM   bom_calendar_dates cd,
           bom_period_start_dates ps,
	   mtl_parameters mp
    WHERE  mp.organization_id  = g_kanban_info_rec.organization_id
    AND    ps.calendar_code =  mp.calendar_code
    AND    ps.exception_set_id = mp.calendar_exception_set_id
    AND    ps.period_start_date = l_demand_date
    AND    cd.calendar_code = ps.calendar_code
    AND    cd.exception_set_id = ps.exception_set_id
    AND    (cd.calendar_date BETWEEN ps.period_start_date AND
					ps.next_date)
    AND    cd.seq_num IS NOT NULL;

  END IF;

  -- alter the demand_date if necessary
  IF l_demand_date < g_kanban_info_rec.start_date THEN
    l_demand_date := g_kanban_info_rec.start_date;
  END IF;

  -- similarly alter the next_date if necessary
  -- first get the next_date if it is null

  IF l_next_date IS NULL THEN -- which it can be for non repetitive forecasts
    IF p_bucket_type = 2 THEN

      SELECT bw.next_date
      INTO   l_next_date
      FROM   bom_cal_week_start_dates bw,
             mtl_parameters mp
      WHERE  mp.organization_id = g_kanban_info_rec.organization_id
      AND    bw.calendar_code =  mp.calendar_code
      AND    bw.exception_set_id = mp.calendar_exception_set_id
      AND    bw.week_start_date <= l_demand_date
      AND    bw.next_date >= l_demand_date;

    ELSIF p_bucket_type = 3 THEN

      SELECT bp.next_date
      INTO   l_next_date
      FROM   bom_period_start_dates bp,
             mtl_parameters mp
      WHERE  mp.organization_id = g_kanban_info_rec.organization_id
      AND    bp.calendar_code = mp.calendar_code
      AND    bp.exception_set_id = mp.calendar_exception_set_id
      AND    bp.period_start_date <= l_demand_date
      AND    bp.next_date >= l_demand_date;

    END IF;

  END IF;

  IF l_next_date > g_kanban_info_rec.cutoff_date THEN
    l_next_date := g_kanban_info_rec.cutoff_date;
  END IF;

  -- now calculate the number of workdays for which we have to
  -- consider the demand out of the weekly/periodic forecast we
  -- are working with

  SELECT count(*)
  INTO   l_current_workdays
  FROM   bom_calendar_dates cd,
         mtl_parameters mp
  WHERE  mp.organization_id  = g_kanban_info_rec.organization_id
  AND    cd.calendar_code =  mp.calendar_code
  AND    cd.exception_set_id = mp.calendar_exception_set_id
  AND    (cd.calendar_date BETWEEN l_demand_date AND l_next_date)
  AND    cd.seq_num IS NOT NULL;

  -- once we mucked around with the dates, we  have to arrive at the
  -- correct demand quantity for the length of the week/period
  l_demand_quantity := (l_current_workdays/l_total_workdays) *
							p_in_demand_qty;

  p_out_demand_date := l_demand_date;
  p_out_demand_qty := l_demand_quantity;

  IF g_debug THEN
    g_log_message := 'Current workdays : ' || to_char (l_current_workdays);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Total Workdays : ' || to_char (l_total_workdays);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Out Demand Date : ' || to_char (l_demand_date);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Out Demand qty : ' || to_char (l_demand_quantity);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Exiting Get_Prorated_Demand Function';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'GET_PRORATED_DEMAND Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Get_Prorated_Demand;

-- ========================================================================
-- this function explodes the demand for repetitive forecast entries
-- ========================================================================

FUNCTION Explode_Repetitive_Forecast (
		p_inventory_item_id	IN number,
         	p_demand_quantity	IN number,
            	p_demand_date		IN date,
            	p_rate_end_date		IN date,
            	p_bucket_type		IN number,
            	p_demand_type		IN number,
            	p_line_id 		IN number,
            	p_item_sub_inventory	IN VARCHAR2,
            	p_item_locator		IN number,
            	p_parent_sub_inventory	IN VARCHAR2,
            	p_parent_locator	IN number,
            	p_parent_item_id	IN number,
            	p_kanban_item_flag	IN VARCHAR2,
            	insert_or_cascade	IN boolean)


RETURN BOOLEAN IS

l_rate_end_date		date;
l_rate_start_date	date;
l_demand_date		date;
l_next_date		date;
l_demand_quantity       number;
l_current_workdays      number;
l_total_workdays	number;
l_line_id		number;
l_ret_val		boolean;

-- cursor for repetitive periodic forecast dates
cursor cur_periodic_forecasts is
SELECT bp.period_start_date, bp.next_date
FROM   bom_period_start_dates bp, mtl_parameters mp
WHERE  mp.organization_id = g_kanban_info_rec.organization_id
AND    bp.calendar_code = mp.calendar_code
AND    bp.exception_set_id = mp.calendar_exception_set_id
AND    (bp.period_start_date BETWEEN p_demand_date AND
	p_rate_end_date);

-- cursor for repetitive weekly forecast dates
cursor cur_weekly_forecasts is
SELECT bw.week_start_date, bw.next_date
FROM   bom_cal_week_start_dates bw, mtl_parameters mp
WHERE  mp.organization_id = g_kanban_info_rec.organization_id
AND    bw.calendar_code =  mp.calendar_code
AND    bw.exception_set_id = mp.calendar_exception_set_id
AND    (bw.week_start_date BETWEEN p_demand_date AND
        p_rate_end_date);

-- cursor for repetitive daily forecast dates
cursor cur_daily_forecasts is
SELECT bcd.calendar_date
FROM   bom_calendar_dates bcd, mtl_parameters mp
WHERE  mp.organization_id  = g_kanban_info_rec.organization_id
AND    bcd.calendar_code =  mp.calendar_code
AND    bcd.exception_set_id = mp.calendar_exception_set_id
AND    (bcd.calendar_date BETWEEN l_rate_start_date AND
        l_rate_end_date)
AND    bcd.seq_num is not null;

BEGIN

  IF g_debug THEN
    g_log_message := 'Entering Explode_Repetitive_Forecast Function';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- some constraints we have to consider for daily forecasts.  The
  -- processing for weekly and periodic forecasts is done later

  -- check from what date we need to consider the daily repetitive forecast
  IF p_demand_date > g_kanban_info_rec.start_date THEN
    l_rate_start_date := p_demand_date;
  ELSE
    l_rate_start_date := g_kanban_info_rec.start_date;
  END IF;

  -- check upto what date we need to consider the daily repetitive forecast
  IF p_rate_end_date > g_kanban_info_rec.cutoff_date THEN
    l_rate_end_date := g_kanban_info_rec.cutoff_date;
  ELSE
    l_rate_end_date := p_rate_end_date;
  END IF;

  WHILE TRUE LOOP

    -- Depending on the bucket type go after the respective cursor

  IF g_debug THEN
    g_log_message := 'Going in while loop inside Explode_Repetitive_Forecast';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

    IF p_bucket_type = 1 THEN -- daily buckets

      IF NOT cur_daily_forecasts%ISOPEN THEN
        OPEN cur_daily_forecasts;
      END IF;

      FETCH cur_daily_forecasts
      INTO  l_demand_date;

      EXIT WHEN cur_daily_forecasts%NOTFOUND;

    ELSIF p_bucket_type = 2 THEN  -- weekly buckets

      IF NOT cur_weekly_forecasts%ISOPEN THEN
        OPEN cur_weekly_forecasts;
      END IF;

      FETCH cur_weekly_forecasts
      INTO  l_demand_date,
	    l_next_date;

      EXIT WHEN cur_weekly_forecasts%NOTFOUND;

    ELSIF p_bucket_type = 3 THEN  -- periodic buckets

      IF NOT cur_periodic_forecasts%ISOPEN THEN
        OPEN cur_periodic_forecasts;
      END IF;

      FETCH cur_periodic_forecasts
      INTO  l_demand_date,
	    l_next_date;

      EXIT WHEN cur_periodic_forecasts%NOTFOUND;

    END IF;

  IF g_debug THEN
    g_log_message := 'Done with the buckets';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

    -- we need to do some extra work for weekly and periodic
    -- forecasts in order to figure out the correct demand in the
    -- specified period.

    IF p_bucket_type = 2 OR p_bucket_type = 3 THEN
      -- Call the prorating function
  IF g_debug THEN
    g_log_message := 'Call the prorating function';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

      IF NOT Get_Prorated_Demand (
	        p_bucket_type,
        	l_demand_date,
        	l_next_date,
        	p_demand_quantity,
        	l_demand_date,
        	l_demand_quantity ) THEN
        RETURN FALSE;
      END IF;

    ELSIF p_bucket_type = 1 THEN
      l_demand_quantity := p_demand_quantity;
    END IF;

    -- now call the function to insert the demand and explode it through
    -- to the bottom of the bill

  IF (p_line_id is NULL) THEN
    Begin
      SELECT line_id
      INTO   l_line_id
      FROM   bom_operational_routings
      WHERE  alternate_routing_designator is NULL
      AND          assembly_item_id = p_inventory_item_id
      AND          organization_id  = g_kanban_info_rec.organization_id;
    Exception
      When Others Then
        Null;
    End;
  ELSE
    l_line_id := p_line_id;
  END IF;
  IF g_debug THEN
    g_log_message := 'Inserting into MRP_KANBAN_DEMAND';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'LineN : ' || to_char(l_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'in erd ItemN : ' || to_char(p_inventory_item_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'in erd demand date: ' || to_char(l_demand_date);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'in erd demand quant: ' || to_char(l_demand_quantity);
    MRP_UTIL.MRP_LOG (g_log_message);

  END IF;


  IF l_demand_quantity > 0 THEN

  IF INSERT_OR_CASCADE = TRUE  THEN
  INSERT INTO MRP_KANBAN_DEMAND (
        DEMAND_ID,
        KANBAN_PLAN_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY,
        LOCATOR_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_ORG_ID,
        ASSEMBLY_SUBINVENTORY,
        ASSEMBLY_LOCATOR_ID,
        DEMAND_DATE,
        DEMAND_QUANTITY,
        ORDER_TYPE,
        KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY )
  SELECT
        mrp_kanban_demand_s.nextval,
        g_kanban_info_rec.kanban_plan_id,
        g_kanban_info_rec.organization_id,
        p_inventory_item_id,
        ps.subinventory_name,
        ps.locator_id,
        NULL,
        NULL,
        NULL,
        NULL,
        l_demand_date,
        (NVL(ps.allocation_percent, 100) *
            l_demand_quantity/ 100),
        p_demand_type,
        'Y',
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
  FROM
        mtl_kanban_pull_sequences ps
  WHERE ps.wip_line_id = l_line_id
  AND   ps.source_type = G_PRODUCTION_SOURCE_TYPE
  AND   ps.kanban_plan_id = decode (g_kanban_info_rec.replan_flag,
                                2, G_PRODUCTION_KANBAN,
                                1, g_kanban_info_rec.kanban_plan_id,
                                G_PRODUCTION_KANBAN)
  AND   ps.inventory_item_id = p_inventory_item_id
  AND   ps.organization_id = g_kanban_info_rec.organization_id;
  ELSE/* its cascade*/
      INSERT INTO MRP_KANBAN_DEMAND (
        DEMAND_ID,
        KANBAN_PLAN_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY,
        LOCATOR_ID,
        ASSEMBLY_ORG_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_SUBINVENTORY,
        ASSEMBLY_LOCATOR_ID,
        DEMAND_DATE,
        DEMAND_QUANTITY,
        ORDER_TYPE,
        KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY )
      SELECT
        mrp_kanban_demand_s.nextval,
        g_kanban_info_rec.kanban_plan_id,
        g_kanban_info_rec.organization_id,
        p_inventory_item_id,
        p_item_sub_inventory,
        p_item_locator,
        g_kanban_info_rec.organization_id,
        p_parent_item_id,
        p_parent_sub_inventory,
        p_parent_locator,
        l_demand_date,
        l_demand_quantity,
        p_demand_type,
        p_kanban_item_flag,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      FROM
        DUAL;

  END IF;
  END IF;--demand > 0
  END LOOP;

  -- close whatever cursor is open
  IF cur_daily_forecasts%ISOPEN THEN
    CLOSE cur_daily_forecasts;
  ELSIF cur_weekly_forecasts%ISOPEN THEN
    CLOSE cur_weekly_forecasts;
  ELSIF cur_periodic_forecasts%ISOPEN THEN
    CLOSE cur_periodic_forecasts;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'EXPLODE_REPETITIVE_FORECAST Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;
END Explode_Repetitive_Forecast;

-- ========================================================================
--  This function passes demand down to the components all the way down
--  to the bottom of the bill for the FORECAST/Actual Production
-- ========================================================================
FUNCTION Cascade_Fcst_Demand(
	p_bill_or_ps            IN  NUMBER,
        p_recursive             IN  BOOLEAN,
        p_parent_line_id        IN  NUMBER,
        p_line_id               IN  NUMBER,
        p_top_item_id           IN  NUMBER,
        p_assembly_item_id      IN  NUMBER,
        p_cumulative_usage      IN  NUMBER,
        p_subinventory          IN  VARCHAR2,
        p_locator_id            IN  NUMBER,
        p_demand_type           IN  NUMBER,
        p_explode_always        IN  VARCHAR2,
        p_sales_order_demand    IN  VARCHAR2,
        p_assy_foq              IN  NUMBER )

RETURN BOOLEAN IS

--declare some local variables here
l_bill_or_ps                    number; -- 1 - bill; 2 - pull sequence

l_component_id                  number;
l_subinventory                  varchar2(10);
l_locator_id                    number;
l_component_usage               number;
l_component_yield               number;
l_operation_yield               number;
l_net_planning_percent          number;
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
l_planning_factor		number;
l_item_num			number;
/* End of Update */
l_kanban_item_flag              varchar2(1);
l_demand_quantity               number;
l_ret_val                       boolean;

l_line_id			number;
l_forecast_quantity		number;
l_forecast_date			date;
l_rate_end_date			date;
l_bucket_type			number;
l_running_total_quantity  	number := 0;
l_cumulative_usage              number;
l_wip_supply_type               number;
l_basis_type                    number;
l_comp_foq                      number;
l_foq                           number;


CURSOR parent_schedule_entries IS
SELECT  current_forecast_quantity,
        forecast_date,
        rate_end_date,
        bucket_type
FROM    mrp_forecast_dates
WHERE   organization_id = g_kanban_info_rec.organization_id
AND     ((forecast_designator = g_kanban_info_rec.input_designator) or
	 (forecast_designator in ( -- forecast set
 		select forecast_designator
		from mrp_forecast_designators
		where forecast_set = g_kanban_info_rec.input_designator)
	 )
        )
AND     inventory_item_id = p_top_item_id
AND     origination_type  = p_demand_type
AND     nvl(line_id,0) = nvl(p_parent_line_id,0)
AND     ((rate_end_date IS NULL AND
        forecast_date BETWEEN Get_Offset_Date(
                                g_kanban_info_rec.start_date,
                                bucket_type )
        AND g_kanban_info_rec.cutoff_date) OR
        (rate_end_date is NOT NULL AND NOT
         (rate_end_date < Get_Offset_Date(
                                g_kanban_info_rec.start_date,
                                bucket_type ) OR
          forecast_date > g_kanban_info_rec.cutoff_date)));


-- cursor component_cursor1 is the cursor that passes down demand
-- to the components feeding into a line. Notice that we are driving
-- off of bom_operational_routings
-- also if supply sub and locator are null in bom_inventory_components
-- we get it from wip supply locations from mtl_system_items - this
-- is ok for R-11, though we might have an issue here for R12

CURSOR component_cursor1 IS
SELECT DISTINCT
       bic.component_item_id,
       decode(bic.supply_subinventory, NULL, msi.wip_supply_subinventory,
                bic.supply_subinventory),
       decode(bic.supply_locator_id, NULL, msi.wip_supply_locator_id,
                bic.supply_locator_id),
       bic.component_quantity,
       bic.component_yield_factor,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
       bic.planning_factor,
       bic.item_num,
/* End of Update */
       mllc.operation_yield,
       mllc.net_planning_percent,
       mllc.kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
       mllc.wip_supply_type,
       mllc.basis_type,
       nvl(msi.fixed_order_quantity, nvl(msi.minimum_order_quantity, nvl(msi.maximum_order_quantity,1)))
FROM   mtl_system_items msi,
       mrp_low_level_codes mllc,
       bom_inventory_components bic,
       bom_bill_of_materials bbom,
       bom_operational_routings bor,
       mtl_parameters mp
WHERE  mp.organization_id = g_kanban_info_rec.organization_id
AND    bor.line_id (+) = p_line_id
AND    bor.assembly_item_id (+) = p_assembly_item_id
AND    bor.organization_id (+) = mp.organization_id
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority (
                        bor.assembly_item_id,
                        bor.organization_id,
                        bor.line_id,
                        bor.alternate_routing_designator)
/* BUG: 1668867 Double kanban demand */
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_assy_cfgitem (
                        p_assembly_item_id,
                        bic.component_item_id,
                        mp.organization_id)
AND    bbom.assembly_item_id = p_assembly_item_id
AND    bbom.organization_id = mp.organization_id
AND    nvl(bbom.alternate_bom_designator, 'xxx')  =
                nvl(bor.alternate_routing_designator, 'xxx')
AND    bic.bill_sequence_id = bbom.common_bill_sequence_id
AND    nvl(bic.disable_date, g_kanban_info_rec.bom_effectivity + 1)
                >= g_kanban_info_rec.bom_effectivity
AND    bic.effectivity_date <= g_kanban_info_rec.bom_effectivity
AND    NOT EXISTS (
       SELECT NULL
       FROM   bom_inventory_components bic2
       WHERE  bic2.bill_sequence_id = bic.bill_sequence_id
       AND    bic2.component_item_id = bic.component_item_id
       AND    (decode(bic2.implementation_date, null,
                    bic2.old_component_sequence_id,
                    bic2.component_sequence_id) =
               decode(bic.implementation_date, null,
                   bic.old_component_sequence_id,
                   bic.component_sequence_id)
              OR bic2.operation_seq_num = bic.operation_seq_num)
       AND    bic2.effectivity_date <=
                        g_kanban_info_rec.bom_effectivity
       AND    bic2.effectivity_date > bic.effectivity_date
       AND    (bic2.implementation_date is not null OR
              (bic2.implementation_date is null AND EXISTS
              (SELECT NULL
               FROM   eng_revised_items eri
               WHERE  bic2.revised_item_sequence_id =
                                     eri.revised_item_sequence_id
               AND    eri.mrp_active = 1 ))))
AND    (bic.implementation_date is not null OR
              (bic.implementation_date is null AND EXISTS
              (SELECT NULL
               FROM   eng_revised_items eri
               WHERE  bic.revised_item_sequence_id =
                                     eri.revised_item_sequence_id
               AND    eri.mrp_active = 1 )))
AND    mllc.plan_id = g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id = bbom.organization_id
AND    mllc.assembly_item_id = bbom.assembly_item_id
AND    mllc.component_item_id = bic.component_item_id
AND    nvl(mllc.alternate_designator, 'xxx')  =
                nvl(bbom.alternate_bom_designator, 'xxx')
AND    msi.inventory_item_id = mllc.component_item_id
AND    msi.organization_id = mllc.organization_id
AND    ((nvl(msi.ato_forecast_control, G_NO_FCST_CONTROL) = G_NO_FCST_CONTROL)
        OR p_explode_always = 'Y'
        OR (p_sales_order_demand = 'Y' AND msi.bom_item_type = 4));

-- cursor component_cursor2 blows down demand to the components
-- as stored in the mrp_low_level_codes table
CURSOR component_cursor2 IS
SELECT DISTINCT
       mllc.component_item_id,
       mllc.from_subinventory,
       mllc.from_locator_id,
       mllc.component_usage,
       mllc.component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
       mllc.planning_factor,
       mllc.item_num,
/* End of Update */
       mllc.operation_yield,
       mllc.net_planning_percent,
       mllc.kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
       mllc.wip_supply_type,
       mllc.basis_type,
       nvl(msi.fixed_order_quantity, nvl(msi.minimum_order_quantity, nvl(msi.maximum_order_quantity,1)))
FROM   mtl_system_items msi,
       mrp_low_level_codes mllc
WHERE  mllc.plan_id = g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id + 0 = g_kanban_info_rec.organization_id
AND    mllc.assembly_item_id = p_assembly_item_id
AND    ((mllc.to_subinventory = p_subinventory
        AND    nvl(mllc.to_locator_id,-1) = nvl(p_locator_id,-1)) OR
       (mllc.to_subinventory is NULL and p_bill_or_ps = 1) )
AND    msi.inventory_item_id = mllc.component_item_id
AND    msi.organization_id = mllc.organization_id
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
  AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority (
                        mllc.assembly_item_id,
                        mllc.organization_id,
                        null,
                        mllc.alternate_designator)
/* End of Update */
/* BUG 1668867, Double Kanban demand problem */
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_assy_cfgitem (
                        p_assembly_item_id,
                        mllc.component_item_id,
                        mllc.organization_id)
AND    ((nvl(msi.ato_forecast_control, G_NO_FCST_CONTROL) = G_NO_FCST_CONTROL)
        OR p_explode_always = 'Y'
        OR (p_sales_order_demand = 'Y' AND msi.bom_item_type = 4));

BEGIN

  IF g_debug THEN

    g_log_message := 'Entering Cascade_Fcst_Demand function';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Cascading Demand For : ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Line : ' || to_char(p_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Item : ' || to_char(p_assembly_item_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Sub : ' || p_subinventory;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Loc : ' || p_locator_id;
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- Depending on the boolean flag p_recursive, we decide what cursor
  -- we want to go after.  We know that we will have a line reference
  -- on the demand.  So, when we call Cacade_Demand the first time, ie
  -- to pass down demand to components feeding into the line, then
  -- p_recursive is false. We just blow the demand down one level. Once
  -- we do that, we call Cascade_Fcst_Ap_Demand in the recursive mode with
  -- p_recursive set to true when we want to go after mrp_low_level_codes
  -- recursively and blow the demand all the way down.

  IF NOT p_recursive THEN
    IF NOT component_cursor1%ISOPEN THEN
      OPEN component_cursor1;
    END IF;

  ELSE

    IF NOT component_cursor2%ISOPEN THEN
      OPEN component_cursor2;
    END IF;
  END IF;

  WHILE TRUE LOOP
    IF not p_recursive THEN
      FETCH     component_cursor1
      INTO      l_component_id,
                l_subinventory,
                l_locator_id,
                l_component_usage,
                l_component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
		l_planning_factor,
		l_item_num,
/* End of Update */
                l_operation_yield,
                l_net_planning_percent,
                l_kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
		l_wip_supply_type,
                l_basis_type,
                l_comp_foq;
      EXIT WHEN component_cursor1%NOTFOUND;

    ELSE

      FETCH     component_cursor2
      INTO      l_component_id,
                l_subinventory,
                l_locator_id,
                l_component_usage,
                l_component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
		l_planning_factor,
		l_item_num,
/* End of Update */
                l_operation_yield,
                l_net_planning_percent,
                l_kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
		l_wip_supply_type,
                l_basis_type,
                l_comp_foq;
      EXIT WHEN component_cursor2%NOTFOUND;


    END IF;

  IF g_debug THEN
    g_log_message := 'component_usage is : ' || to_char (l_component_usage);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Net_Planning_Percent is : ' ||
                                to_char (l_net_planning_percent);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Operation_Yield is : ' || to_char (l_operation_yield);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Component_Yield is : ' || to_char (l_component_yield);
    MRP_UTIL.MRP_LOG (g_log_message);

    g_log_message := 'Sub: ' || l_subinventory;
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;


    -- calculate the demand quantity to be passed down using all the
    -- percentages and yields stuff that we've got

    IF NOT parent_schedule_entries%ISOPEN THEN
      OPEN parent_schedule_entries;
    END IF;
  WHILE TRUE LOOP

    FETCH    parent_schedule_entries
    INTO     l_forecast_quantity,
             l_forecast_date,
             l_rate_end_date,
             l_bucket_type;
    EXIT WHEN parent_schedule_entries%NOTFOUND;

    IF l_rate_end_date IS NULL THEN
        -- not a repetitive forecast - simple processing

        IF l_bucket_type = 2 OR l_bucket_type = 3 THEN
          --Call the pro-rating function
          IF NOT Get_Prorated_Demand (
                l_bucket_type,
                l_forecast_date,
                l_rate_end_date,
                l_forecast_quantity,
                l_forecast_date,
                l_forecast_quantity) THEN
            RETURN FALSE;
          END IF;
        END IF;

    l_running_total_quantity := l_running_total_quantity + nvl(
    l_forecast_quantity,0);

/* Added for lot based material support
   The p_assy_foq is the fixed order quantity of the assembly.
   It can be either the foq from the item master or it's parent (for phantom assembly).
   The p_assy_foq will be used to calculate the component's demand when the
   component has lot basis type and the demand is not from the pull sequence chain. */
    if (l_basis_type = WIP_CONSTANTS.LOT_BASED_MTL and l_component_id <> p_assembly_item_id) then
      l_foq := p_assy_foq;
    else
      l_foq := 1;
    end if;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
/*    l_demand_quantity := ROUND((l_forecast_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
                           (nvl(l_net_planning_percent, 100) /100)) /
                (nvl(l_operation_yield, 1) * nvl(l_component_yield, 1))); */
    l_demand_quantity := ((l_forecast_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
                           (nvl(l_planning_factor, 100) /100)) /
                (nvl(l_operation_yield, 1) * nvl(l_component_yield, 1)))/l_foq;
/* End of Update */

    IF g_debug THEN
      g_log_message := 'Deamnd Quantity:'||to_char(l_demand_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

    -- now insert the demand into the kanban demand table if its > 0

    IF l_demand_quantity > 0 THEN

      INSERT INTO MRP_KANBAN_DEMAND (
        DEMAND_ID,
        KANBAN_PLAN_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY,
        LOCATOR_ID,
        ASSEMBLY_ORG_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_SUBINVENTORY,
        ASSEMBLY_LOCATOR_ID,
        DEMAND_DATE,
        DEMAND_QUANTITY,
        ORDER_TYPE,
        KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY )
      SELECT
        mrp_kanban_demand_s.nextval,
        g_kanban_info_rec.kanban_plan_id,
        g_kanban_info_rec.organization_id,
        l_component_id,
        l_subinventory,
        l_locator_id,
        g_kanban_info_rec.organization_id,
        p_assembly_item_id,
        p_subinventory,
        p_locator_id,
        l_forecast_date,
        l_demand_quantity,
        8,
        l_kanban_item_flag,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      FROM
        DUAL;

    END IF;

    ELSIF l_rate_end_date IS NOT NULL THEN
      -- this is repetitive forecast entry - needs explosion of forecast

      l_running_total_quantity := l_running_total_quantity + nvl(
      l_forecast_quantity,0);

    if (l_basis_type = WIP_CONSTANTS.LOT_BASED_MTL and l_component_id <> p_assembly_item_id) then
      l_foq := p_assy_foq;
    else
      l_foq := 1;
    end if;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
/*    l_demand_quantity := ROUND((l_forecast_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
                           (nvl(l_net_planning_percent, 100) /100)) /
                (nvl(l_operation_yield, 1) * nvl(l_component_yield, 1))); */
    l_demand_quantity := ((l_forecast_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
                           (nvl(l_planning_factor, 100) /100)) /
                (nvl(l_operation_yield, 1) * nvl(l_component_yield, 1)))/l_foq;
/* End of Update */

    IF g_debug THEN
      g_log_message := 'Deamnd Quantity:'||to_char(l_demand_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

      -- call the function that explodes repetitive foreast demand

      l_ret_val := Explode_Repetitive_Forecast (
                   l_component_id,
                   l_demand_quantity,
                   l_forecast_date,
                   l_rate_end_date,
                   l_bucket_type,
                   8,
                   l_line_id,
		   l_subinventory,
		   l_locator_id,
		   p_subinventory,
		   p_locator_id,
		   p_assembly_item_id,
		   l_kanban_item_flag,
		   FALSE);
     IF NOT l_ret_val THEN
       return FALSE;
     END IF;

   END IF;

  END LOOP;-- end of my cursor
  IF parent_schedule_entries%ISOPEN THEN
    CLOSE parent_schedule_entries;
  END IF;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
  -- l_cumulative_usage := p_cumulative_usage * l_component_usage;
  l_cumulative_usage := p_cumulative_usage * l_component_usage * (nvl(l_planning_factor, 100)/100) / l_foq;
/* End of Update */

  IF ( l_running_total_quantity > 0) THEN
      IF g_debug THEN
        g_log_message := 'Calling Cascade_Forecast_Demand in recursive mode';
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;

      if (p_assembly_item_id = l_component_id) then
	l_bill_or_ps := 2;
      else
	l_bill_or_ps := 1;
      end if;

/* Added for lot based material support
   For phantom, we do not use fixed order quantity of the component. We used
   the fixed order quantity of top level parent, that is the first non-phantom parent. */
      if (l_wip_supply_type = WIP_CONSTANTS.PHANTOM) then
        l_comp_foq := p_assy_foq;
      end if;

/* Modified for lot based material support.
   Push down the fixed order qty (l_comp_foq) to the component. */
      l_ret_val := Cascade_Fcst_Demand(
		   l_bill_or_ps,
                   TRUE,
                   p_parent_line_id,
                   NULL,
                   p_top_item_id,
                   l_component_id,
                   l_cumulative_usage,
                   l_subinventory,
                   l_locator_id,
                   p_demand_type,
                   p_explode_always,
                   p_sales_order_demand,
                   l_comp_foq);

  IF g_debug THEN
    g_log_message := 'returned from the Cascade_Fcst_Demand call';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

      IF NOT l_ret_val THEN
        RETURN FALSE;
      END IF;

  END IF;

  END LOOP;

  IF component_cursor1%ISOPEN THEN
    CLOSE component_cursor1;
  END IF;
  IF component_cursor2%ISOPEN THEN
    CLOSE component_cursor2;
  END IF;

  RETURN TRUE;

--exception handling

EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'Cascade_Fcst_Demand Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Cascade_Fcst_Demand;

-- ========================================================================
--  This function passes demand down to the components all the way down
--  to the bottom of the bill
-- ========================================================================
FUNCTION Cascade_Ap_Demand (
	p_bill_or_ps            IN  NUMBER,
	p_recursive		IN  BOOLEAN,
	p_parent_line_id	IN  NUMBER,
	p_line_id 		IN  NUMBER,
	p_top_item_id		IN  NUMBER,
	p_top_alt		IN  VARCHAR2,
	p_assembly_item_id	IN  NUMBER,
	p_alt			IN  VARCHAR2,
        p_cumulative_usage      IN  NUMBER,
	p_subinventory		IN  VARCHAR2,
	p_locator_id		IN  NUMBER,
	p_demand_type		IN  NUMBER,
	p_explode_always	IN  VARCHAR2,
	p_sales_order_demand	IN  VARCHAR2,
        p_assy_foq              IN  NUMBER )

RETURN BOOLEAN IS

--declare some local variables here
l_bill_or_ps                    number; -- 1 - bill; 2 - pull sequence

l_component_id			number;
l_subinventory			varchar2(10);
l_locator_id			number;
l_component_usage		number;
l_component_yield		number;
l_operation_yield		number;
l_net_planning_percent		number;
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
l_planning_factor		number;
l_item_num			number;
/* End of Update */
l_kanban_item_flag	 	varchar2(1);
l_demand_quantity		number;
l_ret_val			boolean;
l_cumulative_usage              number;

l_running_total_quantity  	number := 0;
l_schedule_quantity   		number;
l_schedule_date               	date;

l_wip_supply_type               number;
l_basis_type                    number;
l_comp_foq                      number;
l_foq                           number;

CURSOR parent_schedule_entries IS
SELECT  sum(planned_quantity) PQ,
        scheduled_completion_date
FROM mrp_kanban_actual_prod_v
WHERE organization_id = g_kanban_info_rec.organization_id
AND scheduled_completion_date between g_kanban_info_rec.start_date AND
               g_kanban_info_rec.cutoff_date
AND primary_item_id IN
( select COMPONENT_ITEM_ID from mrp_low_level_codes
  WHERE ORGANIZATION_ID = g_kanban_info_rec.organization_id
  AND PLAN_ID = g_kanban_info_rec.kanban_plan_id )
AND primary_item_id = p_top_item_id
AND nvl(alternate_bom_designator, 'NONE') = nvl(p_top_alt, 'NONE')
AND nvl(line_id,0)=nvl(p_parent_line_id,0)
group by scheduled_completion_date,schedule_type,line_id;


-- cursor component_cursor1 is the cursor that passes down demand
-- to the components feeding into a line. Notice that we are driving
-- off of bom_operational_routings
-- also if supply sub and locator are null in bom_inventory_components
-- we get it from wip supply locations from mtl_system_items - this
-- is ok for R-11, though we might have an issue here for R12

CURSOR component_cursor1 IS
SELECT DISTINCT
       bic.component_item_id,
       decode(bic.supply_subinventory, NULL, msi.wip_supply_subinventory,
		bic.supply_subinventory),
       decode(bic.supply_subinventory, NULL, msi.wip_supply_locator_id,
		bic.supply_locator_id),
       bic.component_quantity,
       bic.component_yield_factor,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
       bic.planning_factor,
       bic.item_num,
/* End of Update */
       mllc.operation_yield,
       mllc.net_planning_percent,
       mllc.kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
       mllc.wip_supply_type,
       mllc.basis_type,
       nvl(msi.fixed_order_quantity, nvl(msi.minimum_order_quantity, nvl(msi.maximum_order_quantity,1)))
FROM   mtl_system_items msi,
       mrp_low_level_codes mllc,
       bom_inventory_components bic,
       bom_bill_of_materials bbom
WHERE
       bbom.assembly_item_id = p_assembly_item_id
AND    bbom.organization_id = g_kanban_info_rec.organization_id
AND    nvl(bbom.alternate_bom_designator, 'NONE') = nvl(p_top_alt, 'NONE')
/* Bug 2279877, not pick up discrete jobs w/o line_id
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority (
			bor.assembly_item_id,
			bor.organization_id,
			bor.line_id,
                        bor.alternate_routing_designator)
*/
/* BUG: 1668867 , Fix for double demand */
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_assy_cfgitem (
                        p_assembly_item_id,
                        bic.component_item_id,
                        g_kanban_info_rec.organization_id)
AND    bic.bill_sequence_id = bbom.common_bill_sequence_id
AND    nvl(bic.disable_date, g_kanban_info_rec.bom_effectivity + 1)
                >= g_kanban_info_rec.bom_effectivity
AND    bic.effectivity_date <= g_kanban_info_rec.bom_effectivity
AND    NOT EXISTS (
       SELECT NULL
       FROM   bom_inventory_components bic2
       WHERE  bic2.bill_sequence_id = bic.bill_sequence_id
       AND    bic2.component_item_id = bic.component_item_id
       AND    (decode(bic2.implementation_date, null,
                    bic2.old_component_sequence_id,
                    bic2.component_sequence_id) =
               decode(bic.implementation_date, null,
                   bic.old_component_sequence_id,
                   bic.component_sequence_id)
              OR bic2.operation_seq_num = bic.operation_seq_num)
       AND    bic2.effectivity_date <=
			g_kanban_info_rec.bom_effectivity
       AND    bic2.effectivity_date > bic.effectivity_date
       AND    (bic2.implementation_date is not null OR
              (bic2.implementation_date is null AND EXISTS
              (SELECT NULL
               FROM   eng_revised_items eri
               WHERE  bic2.revised_item_sequence_id =
                                     eri.revised_item_sequence_id
               AND    eri.mrp_active = 1 ))))
AND    (bic.implementation_date is not null OR
              (bic.implementation_date is null AND EXISTS
              (SELECT NULL
               FROM   eng_revised_items eri
               WHERE  bic.revised_item_sequence_id =
                                     eri.revised_item_sequence_id
               AND    eri.mrp_active = 1 )))
AND    mllc.plan_id = g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id = bbom.organization_id
AND    mllc.assembly_item_id = bbom.assembly_item_id
AND    mllc.component_item_id = bic.component_item_id
AND    nvl(mllc.alternate_designator, 'xxx')  =
                nvl(bbom.alternate_bom_designator, 'xxx')
AND    msi.inventory_item_id = mllc.component_item_id
AND    msi.organization_id = mllc.organization_id
AND    ((nvl(msi.ato_forecast_control, G_NO_FCST_CONTROL) = G_NO_FCST_CONTROL)
	OR p_explode_always = 'Y'
        OR (p_sales_order_demand = 'Y' AND msi.bom_item_type = 4));

-- cursor component_cursor2 blows down demand to the components
-- as stored in the mrp_low_level_codes table
CURSOR component_cursor2 IS
SELECT DISTINCT
       mllc.component_item_id,
       mllc.from_subinventory,
       mllc.from_locator_id,
       mllc.component_usage,
       mllc.component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
       mllc.planning_factor,
       mllc.item_num,
/* End of Update */
       mllc.operation_yield,
       mllc.net_planning_percent,
       mllc.kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
       mllc.wip_supply_type,
       mllc.basis_type,
       nvl(msi.fixed_order_quantity, nvl(msi.minimum_order_quantity, nvl(msi.maximum_order_quantity,1)))
FROM   mtl_system_items msi,
       mrp_low_level_codes mllc
WHERE  mllc.plan_id = g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id + 0 = g_kanban_info_rec.organization_id
AND    mllc.assembly_item_id = p_assembly_item_id
AND    ((mllc.to_subinventory = p_subinventory
        AND    nvl(mllc.to_locator_id,-1) = nvl(p_locator_id,-1)) OR
       (mllc.to_subinventory is NULL and p_bill_or_ps = 1) )
AND    msi.inventory_item_id = mllc.component_item_id
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
/* Bug 2279877, not pick up discrete jobs w/o line_id
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority (
                        mllc.assembly_item_id,
                        mllc.organization_id,
                        null,
                        mllc.alternate_designator)
*/
/* End of Update */
/* Bug 1668867 : Double Kanban demand */
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_assy_cfgitem (
                        p_assembly_item_id,
                        mllc.component_item_id,
                        mllc.organization_id)
AND    msi.organization_id = mllc.organization_id
AND    ((nvl(msi.ato_forecast_control, G_NO_FCST_CONTROL) = G_NO_FCST_CONTROL)
 	OR p_explode_always = 'Y'
        OR (p_sales_order_demand = 'Y' AND msi.bom_item_type = 4));

BEGIN

  IF g_debug THEN

    g_log_message := 'Entering Cascade_Ap_Demand function';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Cascading Demand For : ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Line : ' || to_char(p_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Item : ' || to_char(p_assembly_item_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Sub : ' || p_subinventory;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Loc : ' || p_locator_id;
    MRP_UTIL.MRP_LOG (g_log_message);

  END IF;


  -- Depending on the boolean flag p_recursive, we decide what cursor
  -- we want to go after.  We know that we will have a line reference
  -- on the demand.  So, when we call Cacade_Demand the first time, ie
  -- to pass down demand to components feeding into the line, then
  -- p_recursive is false. We just blow the demand down one level. Once
  -- we do that, we call Cascade_Mds_Mps_Demand in the recursive mode with
  -- p_recursive set to true when we want to go after mrp_low_level_codes
  -- recursively and blow the demand all the way down.

  IF NOT p_recursive THEN

    IF NOT component_cursor1%ISOPEN THEN
      OPEN component_cursor1;
    END IF;

  ELSE

    IF NOT component_cursor2%ISOPEN THEN
      OPEN component_cursor2;
    END IF;
  END IF;

  WHILE TRUE LOOP

    IF not p_recursive THEN
      FETCH	component_cursor1
      INTO	l_component_id,
		l_subinventory,
		l_locator_id,
		l_component_usage,
		l_component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
		l_planning_factor,
		l_item_num,
/* End of Update */
		l_operation_yield,
		l_net_planning_percent,
		l_kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
                l_wip_supply_type,
                l_basis_type,
                l_comp_foq;
      EXIT WHEN component_cursor1%NOTFOUND;

    ELSE

      FETCH     component_cursor2
      INTO      l_component_id,
                l_subinventory,
                l_locator_id,
                l_component_usage,
                l_component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
		l_planning_factor,
		l_item_num,
/* End of Update */
		l_operation_yield,
		l_net_planning_percent,
		l_kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
                l_wip_supply_type,
                l_basis_type,
                l_comp_foq;
      EXIT WHEN component_cursor2%NOTFOUND;


    END IF;

  IF g_debug THEN
    g_log_message := 'component_usage is : ' || to_char (l_component_usage);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Net_Planning_Percent is : ' ||
				to_char (l_net_planning_percent);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Operation_Yield is : ' || to_char (l_operation_yield);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Component_Yield is : ' || to_char (l_component_yield);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

    -- calculate the demand quantity to be passed down using all the
    -- percentages and yields stuff that we've got

    IF NOT parent_schedule_entries%ISOPEN THEN
      OPEN parent_schedule_entries;
    END IF;
  WHILE TRUE LOOP

    FETCH    parent_schedule_entries
    INTO     l_schedule_quantity,
             l_schedule_date;
    EXIT WHEN parent_schedule_entries%NOTFOUND;

    l_running_total_quantity := l_running_total_quantity + nvl(
    l_schedule_quantity,0);

/* Added for lot based material support
   The p_assy_foq is the fixed order quantity of the assembly.
   It can be either the foq from the item master or it's parent (for phantom assembly).
   The p_assy_foq will be used to calculate the component's demand when the
   component has lot basis type and the demand is not from the pull sequence chain. */
    if (l_basis_type = WIP_CONSTANTS.LOT_BASED_MTL and l_component_id <> p_assembly_item_id) then
      l_foq := p_assy_foq;
    else
      l_foq := 1;
    end if;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
/*    l_demand_quantity := ROUND((l_schedule_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
			   (nvl(l_net_planning_percent, 100) /100)) /
		(nvl(l_operation_yield, 1) * nvl(l_component_yield, 1))); */
    l_demand_quantity := ((l_schedule_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
			   (nvl(l_planning_factor, 100) /100)) /
		(nvl(l_operation_yield, 1) * nvl(l_component_yield, 1)))/l_foq;
/* End of Update */

    IF g_debug THEN
      g_log_message := 'Deamnd Quantity:'||to_char(l_demand_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

    -- now insert the demand into the kanban demand table if its > 0

    IF l_demand_quantity > 0 THEN

      INSERT INTO MRP_KANBAN_DEMAND (
        DEMAND_ID,
        KANBAN_PLAN_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY,
        LOCATOR_ID,
        ASSEMBLY_ORG_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_SUBINVENTORY,
        ASSEMBLY_LOCATOR_ID,
        DEMAND_DATE,
        DEMAND_QUANTITY,
        ORDER_TYPE,
        KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY )
      SELECT
	mrp_kanban_demand_s.nextval,
	g_kanban_info_rec.kanban_plan_id,
	g_kanban_info_rec.organization_id,
	l_component_id,
	l_subinventory,
	l_locator_id,
	g_kanban_info_rec.organization_id,
	p_assembly_item_id,
	p_subinventory,
	p_locator_id,
	l_schedule_date,
	l_demand_quantity,
	8,
	l_kanban_item_flag,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      FROM
	DUAL;

    END IF;
  END LOOP;-- end of my cursor
  IF parent_schedule_entries%ISOPEN THEN
    CLOSE parent_schedule_entries;
  END IF;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
  --l_cumulative_usage := p_cumulative_usage * l_component_usage;
  l_cumulative_usage := p_cumulative_usage * l_component_usage * (nvl(l_planning_factor, 100)/100) / l_foq;
/* End of Update */

  IF ( l_running_total_quantity > 0) THEN
      IF g_debug THEN
        g_log_message := 'Calling Cascade_Ap_Demand in recursive mode';
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;

      if (p_assembly_item_id = l_component_id) then
	l_bill_or_ps := 2;
      else
	l_bill_or_ps := 1;
      end if;

/* Added for lot based material support
   For phantom, we do not use fixed order quantity of the component. We used
   the fixed order quantity of top level parent, that is the first non-phantom parent. */
      if (l_wip_supply_type = WIP_CONSTANTS.PHANTOM) then
        l_comp_foq := p_assy_foq;
      end if;

/* Modified for lot based material support.
   Push down the fixed order qty (l_comp_foq) to the component. */
      l_ret_val := Cascade_Ap_Demand(
		   l_bill_or_ps,
		   TRUE,
  		   p_parent_line_id,
                   NULL,
                   p_top_item_id,
		   p_top_alt,
  	 	   l_component_id,
		   null,
                   l_cumulative_usage,
		   l_subinventory,
		   l_locator_id,
        	   p_demand_type,
        	   p_explode_always,
        	   p_sales_order_demand,
		   l_comp_foq);

  IF g_debug THEN
    g_log_message := 'returned from the cascade call';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;


      IF NOT l_ret_val THEN
        RETURN FALSE;
      END IF;

    END IF;

  END LOOP;

  IF component_cursor1%ISOPEN THEN
    CLOSE component_cursor1;
  END IF;
  IF component_cursor2%ISOPEN THEN
    CLOSE component_cursor2;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'Cascade_Ap_Demand Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Cascade_Ap_Demand;


-- ========================================================================
--  This function passes demand down to the components all the way down
--  to the bottom of the bill
-- ========================================================================
FUNCTION Cascade_Mds_Mps_Demand (
	p_bill_or_ps            IN  NUMBER,
	p_recursive		IN  BOOLEAN,
	p_parent_line_id	IN  NUMBER,
	p_line_id 		IN  NUMBER,
	p_top_item_id		IN  NUMBER,
	p_assembly_item_id	IN  NUMBER,
        p_cumulative_usage      IN  NUMBER,
	p_subinventory		IN  VARCHAR2,
	p_locator_id		IN  NUMBER,
	p_demand_type		IN  NUMBER,
	p_explode_always	IN  VARCHAR2,
	p_sales_order_demand	IN  VARCHAR2,
        p_assy_foq              IN  NUMBER )
RETURN BOOLEAN IS

--declare some local variables here
l_bill_or_ps                    number; -- 1 - bill; 2 - pull sequence

l_component_id			number;
l_subinventory			varchar2(10);
l_locator_id			number;
l_component_usage		number;
l_component_yield		number;
l_operation_yield		number;
l_net_planning_percent		number;
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
l_planning_factor		number;
l_item_num			number;
/* End of Update */
l_kanban_item_flag	 	varchar2(1);
l_demand_quantity		number;
l_ret_val			boolean;
l_cumulative_usage              number;

l_running_total_quantity  	number := 0;
l_schedule_quantity   		number;
l_schedule_date               	date;

l_wip_supply_type               number;
l_basis_type                    number;
l_comp_foq                      number;
l_foq                           number;


CURSOR parent_schedule_entries IS
SELECT
        decode(schedule_quantity,NULL,MRP_KANBAN_PLAN_PK.Get_Repetitive_Demand(
        schedule_date,rate_end_date,repetitive_daily_rate),schedule_quantity),
        schedule_date
FROM mrp_schedule_dates
WHERE   organization_id = g_kanban_info_rec.organization_id
AND     schedule_designator = g_kanban_info_rec.input_designator
AND     schedule_level = 2
AND     schedule_date BETWEEN g_kanban_info_rec.start_date AND
                g_kanban_info_rec.cutoff_date
AND inventory_item_id = p_top_item_id
AND nvl(line_id,0)=nvl(p_parent_line_id,0)
AND schedule_origination_type = p_demand_type ;


-- cursor component_cursor1 is the cursor that passes down demand
-- to the components feeding into a line. Notice that we are driving
-- off of bom_operational_routings
-- also if supply sub and locator are null in bom_inventory_components
-- we get it from wip supply locations from mtl_system_items - this
-- is ok for R-11, though we might have an issue here for R12

CURSOR component_cursor1 IS
SELECT DISTINCT
       bic.component_item_id,
       decode(bic.supply_subinventory, NULL, msi.wip_supply_subinventory,
		bic.supply_subinventory),
       decode(bic.supply_locator_id, NULL, msi.wip_supply_locator_id,
		bic.supply_locator_id),
       bic.component_quantity,
       bic.component_yield_factor,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
       bic.planning_factor,
       bic.item_num,
/* End of Update */
       mllc.operation_yield,
       mllc.net_planning_percent,
       mllc.kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
       mllc.wip_supply_type,
       mllc.basis_type,
       nvl(msi.fixed_order_quantity, nvl(msi.minimum_order_quantity, nvl(msi.maximum_order_quantity,1)))
FROM   mtl_system_items msi,
       mrp_low_level_codes mllc,
       bom_inventory_components bic,
       bom_bill_of_materials bbom,
       bom_operational_routings bor,
       mtl_parameters mp
WHERE  mp.organization_id = g_kanban_info_rec.organization_id
AND    bor.line_id (+) = p_line_id
AND    bor.assembly_item_id (+) = p_assembly_item_id
AND    bor.organization_id (+) = mp.organization_id
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority (
			bor.assembly_item_id,
			bor.organization_id,
			bor.line_id,
			bor.alternate_routing_designator)
AND    bbom.assembly_item_id = p_assembly_item_id
AND    bbom.organization_id = mp.organization_id
AND    nvl(bbom.alternate_bom_designator, 'xxx')  =
		nvl(bor.alternate_routing_designator, 'xxx')
AND    bic.bill_sequence_id = bbom.common_bill_sequence_id
AND    nvl(bic.disable_date, g_kanban_info_rec.bom_effectivity + 1)
                >= g_kanban_info_rec.bom_effectivity
AND    bic.effectivity_date <= g_kanban_info_rec.bom_effectivity
/* BUG: 1821216 Double kanban demand */
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_assy_cfgitem (
                        p_assembly_item_id,
                        bic.component_item_id,
                        mp.organization_id)
AND    NOT EXISTS (
       SELECT NULL
       FROM   bom_inventory_components bic2
       WHERE  bic2.bill_sequence_id = bic.bill_sequence_id
       AND    bic2.component_item_id = bic.component_item_id
       AND    (decode(bic2.implementation_date, null,
                    bic2.old_component_sequence_id,
                    bic2.component_sequence_id) =
               decode(bic.implementation_date, null,
                   bic.old_component_sequence_id,
                   bic.component_sequence_id)
              OR bic2.operation_seq_num = bic.operation_seq_num)
       AND    bic2.effectivity_date <=
			g_kanban_info_rec.bom_effectivity
       AND    bic2.effectivity_date > bic.effectivity_date
       AND    (bic2.implementation_date is not null OR
              (bic2.implementation_date is null AND EXISTS
              (SELECT NULL
               FROM   eng_revised_items eri
               WHERE  bic2.revised_item_sequence_id =
                                     eri.revised_item_sequence_id
               AND    eri.mrp_active = 1 ))))
AND    (bic.implementation_date is not null OR
              (bic.implementation_date is null AND EXISTS
              (SELECT NULL
               FROM   eng_revised_items eri
               WHERE  bic.revised_item_sequence_id =
                                     eri.revised_item_sequence_id
               AND    eri.mrp_active = 1 )))
AND    mllc.plan_id = g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id = bbom.organization_id
AND    mllc.assembly_item_id = bbom.assembly_item_id
AND    mllc.component_item_id = bic.component_item_id
AND    nvl(mllc.alternate_designator, 'xxx')  =
                nvl(bbom.alternate_bom_designator, 'xxx')
AND    msi.inventory_item_id = mllc.component_item_id
AND    msi.organization_id = mllc.organization_id
AND    ((nvl(msi.ato_forecast_control, G_NO_FCST_CONTROL) = G_NO_FCST_CONTROL)
	OR p_explode_always = 'Y'
        OR (p_sales_order_demand = 'Y' AND msi.bom_item_type = 4));

-- cursor component_cursor2 blows down demand to the components
-- as stored in the mrp_low_level_codes table
CURSOR component_cursor2 IS
SELECT DISTINCT
       mllc.component_item_id,
       mllc.from_subinventory,
       mllc.from_locator_id,
       mllc.component_usage,
       mllc.component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
       mllc.planning_factor,
       mllc.item_num,
/* End of Update */
       mllc.operation_yield,
       mllc.net_planning_percent,
       mllc.kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
       mllc.wip_supply_type,
       mllc.basis_type,
       nvl(msi.fixed_order_quantity, nvl(msi.minimum_order_quantity, nvl(msi.maximum_order_quantity,1)))
FROM   mtl_system_items msi,
       mrp_low_level_codes mllc
WHERE  mllc.plan_id = g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id + 0 = g_kanban_info_rec.organization_id
AND    mllc.assembly_item_id = p_assembly_item_id
AND    ((mllc.to_subinventory = p_subinventory
        AND    nvl(mllc.to_locator_id,-1) = nvl(p_locator_id,-1)) OR
       (mllc.to_subinventory is NULL and p_bill_or_ps = 1) )
/* Bug 1668867 : Double Kanban demand */
AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_assy_cfgitem (
                        p_assembly_item_id,
                        mllc.component_item_id,
                        mllc.organization_id)
AND    msi.inventory_item_id = mllc.component_item_id
AND    msi.organization_id = mllc.organization_id
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
  AND    1 = MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority (
                        mllc.assembly_item_id,
                        mllc.organization_id,
                        null,
                        mllc.alternate_designator)
/* End of Update */
AND    ((nvl(msi.ato_forecast_control, G_NO_FCST_CONTROL) = G_NO_FCST_CONTROL)
 	OR p_explode_always = 'Y'
        OR (p_sales_order_demand = 'Y' AND msi.bom_item_type = 4));

BEGIN

  IF g_debug THEN

    g_log_message := 'Entering Cascade_Mds_Mps_Demand function';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Cascading Demand For : ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Line : ' || to_char(p_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Item : ' || to_char(p_assembly_item_id);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Sub : ' || p_subinventory;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message :=  'Loc : ' || p_locator_id;
    MRP_UTIL.MRP_LOG (g_log_message);


  END IF;


  -- Depending on the boolean flag p_recursive, we decide what cursor
  -- we want to go after.  We know that we will have a line reference
  -- on the demand.  So, when we call Cacade_Demand the first time, ie
  -- to pass down demand to components feeding into the line, then
  -- p_recursive is false. We just blow the demand down one level. Once
  -- we do that, we call Cascade_Mds_Mps_Demand in the recursive mode with
  -- p_recursive set to true when we want to go after mrp_low_level_codes
  -- recursively and blow the demand all the way down.

  IF NOT p_recursive THEN

    IF NOT component_cursor1%ISOPEN THEN
      OPEN component_cursor1;
    END IF;

  ELSE

    IF NOT component_cursor2%ISOPEN THEN
      OPEN component_cursor2;
    END IF;
  END IF;

  WHILE TRUE LOOP

    IF not p_recursive THEN
      FETCH	component_cursor1
      INTO	l_component_id,
		l_subinventory,
		l_locator_id,
		l_component_usage,
		l_component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
		l_planning_factor,
		l_item_num,
/* End of Update */
		l_operation_yield,
		l_net_planning_percent,
		l_kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
		l_wip_supply_type,
                l_basis_type,
                l_comp_foq;
      EXIT WHEN component_cursor1%NOTFOUND;

    ELSE

      FETCH     component_cursor2
      INTO      l_component_id,
                l_subinventory,
                l_locator_id,
                l_component_usage,
                l_component_yield,
/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
		l_planning_factor,
		l_item_num,
/* End of Update */
		l_operation_yield,
		l_net_planning_percent,
		l_kanban_item_flag,
/* Added for lot based material support. Need to query wip_supply_type, basis_type and fixed_order_qty */
		l_wip_supply_type,
                l_basis_type,
                l_comp_foq;
      EXIT WHEN component_cursor2%NOTFOUND;


    END IF;

  IF g_debug THEN
    g_log_message := 'component_usage is : ' || to_char (l_component_usage);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Net_Planning_Percent is : ' ||
				to_char (l_net_planning_percent);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Operation_Yield is : ' || to_char (l_operation_yield);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Component_Yield is : ' || to_char (l_component_yield);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

    -- calculate the demand quantity to be passed down using all the
    -- percentages and yields stuff that we've got

    IF NOT parent_schedule_entries%ISOPEN THEN
      OPEN parent_schedule_entries;
    END IF;
  WHILE TRUE LOOP

    FETCH    parent_schedule_entries
    INTO     l_schedule_quantity,
             l_schedule_date;
    EXIT WHEN parent_schedule_entries%NOTFOUND;

    l_running_total_quantity := l_running_total_quantity + nvl(
    l_schedule_quantity,0);

/* Added for lot based material support
   The p_assy_foq is the fixed order quantity of the assembly.
   It can be either the foq from the item master or it's parent (for phantom assembly).
   The p_assy_foq will be used to calculate the component's demand when the
   component has lot basis type and the demand is not from the pull sequence chain. */
    if (l_basis_type = WIP_CONSTANTS.LOT_BASED_MTL and l_component_id <> p_assembly_item_id) then
      l_foq := p_assy_foq;
    else
      l_foq := 1;
    end if;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
/*    l_demand_quantity := ROUND((l_schedule_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
			   (nvl(l_net_planning_percent, 100) /100)) /
		(nvl(l_operation_yield, 1) * nvl(l_component_yield, 1)));*/
    l_demand_quantity := ((l_schedule_quantity* nvl(l_component_usage, 1) *
                           nvl(p_cumulative_usage,1)*
			   (nvl(l_planning_factor, 100) /100)) /
		(nvl(l_operation_yield, 1) * nvl(l_component_yield, 1)))/l_foq;
/* End of Update */

    IF g_debug THEN
      g_log_message := 'Deamnd Quantity:'||to_char(l_demand_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

    -- now insert the demand into the kanban demand table if its > 0

    IF l_demand_quantity > 0 THEN

      INSERT INTO MRP_KANBAN_DEMAND (
        DEMAND_ID,
        KANBAN_PLAN_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY,
        LOCATOR_ID,
        ASSEMBLY_ORG_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_SUBINVENTORY,
        ASSEMBLY_LOCATOR_ID,
        DEMAND_DATE,
        DEMAND_QUANTITY,
        ORDER_TYPE,
        KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY )
      SELECT
	mrp_kanban_demand_s.nextval,
	g_kanban_info_rec.kanban_plan_id,
	g_kanban_info_rec.organization_id,
	l_component_id,
	l_subinventory,
	l_locator_id,
	g_kanban_info_rec.organization_id,
	p_assembly_item_id,
	p_subinventory,
	p_locator_id,
	l_schedule_date,
	l_demand_quantity,
	8,
	l_kanban_item_flag,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      FROM
	DUAL;

    END IF;
  END LOOP;-- end of my cursor
  IF parent_schedule_entries%ISOPEN THEN
    CLOSE parent_schedule_entries;
  END IF;

/* Updated by Liye Ma 4/30/2001 for bug 1757798 and 1745046*/
  --l_cumulative_usage := p_cumulative_usage * l_component_usage;
  l_cumulative_usage := p_cumulative_usage * l_component_usage * (nvl(l_planning_factor, 100)/100) / l_foq;
/* End of Update */

  IF ( l_running_total_quantity > 0) THEN
      IF g_debug THEN
        g_log_message := 'Calling Cascade_Mds_Mps_Demand in recursive mode';
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;

      if (p_assembly_item_id = l_component_id) then
	l_bill_or_ps := 2;
      else
	l_bill_or_ps := 1;
      end if;

/* Added for lot based material support
   For phantom, we do not use fixed order quantity of the component. We used
   the fixed order quantity of top level parent, that is the first non-phantom parent. */
      if (l_wip_supply_type = WIP_CONSTANTS.PHANTOM) then
        l_comp_foq := p_assy_foq;
      end if;

/* Modified for lot based material support.
   Push down the fixed order qty (l_comp_foq) to the component. */
      l_ret_val := Cascade_Mds_Mps_Demand(
		   l_bill_or_ps,
		   TRUE,
  		   p_parent_line_id,
                   NULL,
                   p_top_item_id,
  	 	   l_component_id,
                   l_cumulative_usage,
		   l_subinventory,
		   l_locator_id,
        	   p_demand_type,
        	   p_explode_always,
        	   p_sales_order_demand,
   		   l_comp_foq);

  IF g_debug THEN
    g_log_message := 'returned from the cascade call';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;


      IF NOT l_ret_val THEN
        RETURN FALSE;
      END IF;

    END IF;

  END LOOP;

  IF component_cursor1%ISOPEN THEN
    CLOSE component_cursor1;
  END IF;
  IF component_cursor2%ISOPEN THEN
    CLOSE component_cursor2;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'Cascade_Mds_Mps_Demand Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Cascade_Mds_Mps_Demand;

-- ========================================================================
-- this function inserts demand for FORECAST entries and
-- explodes the demand all the way down to the bottom of the bill
-- ========================================================================
FUNCTION Insert_Fcst_Demand(
                p_inventory_item_id     IN number,
                p_demand_type           IN number,
                p_line_id               IN number )
RETURN BOOLEAN IS
l_line_id               number;
l_bom_item_type         number;
l_ret_val               boolean;
l_explode_always        VARCHAR2(1) := 'N'; /* This is a very important flag. It
                        essentially tells us whether to overlook the forecast
                        control setting on a component item and explode down
                        the demand in the function Cascade_Fcst_Ap_Demand*/
l_sales_order_demand    VARCHAR2(1) := 'N'; /* Again this flag helps us in
                        deciding whether to explode down demand from an MDS or
                        not */

l_forecast_quantity	number;
l_forecast_date 	date;
l_rate_end_date		date;
l_bucket_type		number;
l_origination_type	number;
l_foq			number;

CURSOR item_schedule_entries IS
SELECT  current_forecast_quantity,
        forecast_date,
        rate_end_date,
        bucket_type,
        origination_type,
        line_id
FROM    mrp_forecast_dates
WHERE   organization_id = g_kanban_info_rec.organization_id
/*
AND     ((forecast_designator = g_kanban_info_rec.input_designator) or
         (forecast_designator in ( -- forecast set
                select forecast_designator
                from mrp_forecast_designators
                where forecast_set = g_kanban_info_rec.input_designator)
         )
        )
*/ --bug 5237549
AND FORECAST_DESIGNATOR in (
    select  g_kanban_info_rec.input_designator from dual
    union all
    SELECT FORECAST_DESIGNATOR
    FROM MRP_FORECAST_DESIGNATORS
    WHERE FORECAST_SET = g_kanban_info_rec.input_designator )
AND     inventory_item_id = p_inventory_item_id
AND     origination_type  = p_demand_type
AND     nvl(line_id,0) = nvl(p_line_id,0)
AND     ((rate_end_date IS NULL AND
        forecast_date BETWEEN Get_Offset_Date(
                                g_kanban_info_rec.start_date,
                                bucket_type )
        AND g_kanban_info_rec.cutoff_date) OR
        (rate_end_date is NOT NULL AND NOT
         (rate_end_date < Get_Offset_Date(
                                g_kanban_info_rec.start_date,
                                bucket_type ) OR
          forecast_date > g_kanban_info_rec.cutoff_date)));

BEGIN

  IF g_debug THEN
    g_log_message := 'Inserting Demand For :';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Item : ' || to_char(p_inventory_item_id) ;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Line Reference :' || to_char(p_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  g_stmt_num := 170;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- the first insert here is for the item for which we have
  -- foreacast based on the allocation percentages mentioned
  -- in the mtl_kanban_pull_sequences table

  IF NOT item_schedule_entries%ISOPEN THEN
    OPEN item_schedule_entries;
  END IF;

  WHILE TRUE LOOP

    FETCH    item_schedule_entries
    INTO     l_forecast_quantity,
             l_forecast_date,
             l_rate_end_date,
             l_bucket_type,
             l_origination_type,
             l_line_id;
    EXIT WHEN item_schedule_entries%NOTFOUND;

  IF (l_line_id is NULL) THEN
    Begin
      SELECT line_id
      INTO   l_line_id
      FROM   bom_operational_routings
      WHERE  alternate_routing_designator is NULL
      AND          assembly_item_id = p_inventory_item_id
      AND          organization_id  = g_kanban_info_rec.organization_id;
    Exception
      When Others Then
        Null;
    End;
  END IF;
    IF g_debug THEN
      g_log_message := 'demand quantity:'||to_char(l_forecast_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
      g_log_message := 'demand date:'||to_char(l_forecast_date);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

    IF l_rate_end_date IS NULL THEN
        -- not a repetitive forecast - simple processing

        IF l_bucket_type = 2 OR l_bucket_type = 3 THEN
          --Call the pro-rating function
          IF NOT Get_Prorated_Demand (
                l_bucket_type,
                l_forecast_date,
                l_rate_end_date,
                l_forecast_quantity,
                l_forecast_date,
                l_forecast_quantity) THEN
            RETURN FALSE;
          END IF;
        END IF;

  INSERT INTO MRP_KANBAN_DEMAND (
        DEMAND_ID,
        KANBAN_PLAN_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY,
        LOCATOR_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_ORG_ID,
        ASSEMBLY_SUBINVENTORY,
        ASSEMBLY_LOCATOR_ID,
        DEMAND_DATE,
        DEMAND_QUANTITY,
        ORDER_TYPE,
        KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY )
  SELECT
        mrp_kanban_demand_s.nextval,
        g_kanban_info_rec.kanban_plan_id,
        g_kanban_info_rec.organization_id,
        p_inventory_item_id,
        ps.subinventory_name,
        ps.locator_id,
        NULL,
        NULL,
        NULL,
        NULL,
        l_forecast_date,
        (NVL(ps.allocation_percent, 100) *
            l_forecast_quantity/ 100),
        l_origination_type,
        'Y',
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
  FROM
        mtl_kanban_pull_sequences ps
  WHERE ps.wip_line_id = l_line_id
  AND   ps.source_type = G_PRODUCTION_SOURCE_TYPE
  AND   ps.kanban_plan_id = decode (g_kanban_info_rec.replan_flag,
                                2, G_PRODUCTION_KANBAN,
                                1, g_kanban_info_rec.kanban_plan_id,
                                G_PRODUCTION_KANBAN)
  AND   ps.inventory_item_id = p_inventory_item_id
  AND   ps.organization_id = g_kanban_info_rec.organization_id;


  ELSIF l_rate_end_date IS NOT NULL THEN

     -- this is repetitive forecast entry - needs explosion of forecast
     -- call the function that explodes repetitive foreast demand
     l_ret_val := Explode_Repetitive_Forecast (
                  p_inventory_item_id,
                  l_forecast_quantity,
                  l_forecast_date,
                  l_rate_end_date,
                  l_bucket_type,
                  l_origination_type,
                  l_line_id,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  TRUE);
     IF NOT l_ret_val THEN
       return FALSE;
     END IF;
  END IF;

  END LOOP; -- loop for my cursor
  IF item_schedule_entries%ISOPEN THEN
    CLOSE item_schedule_entries;
  END IF;


  -- -------------------------------------------------
  -- Pass down the dependent demand for each component
  -- By calling the recusive function
  -- First the demand flows to the components that are
  -- supplying to the line on which we have the demand
  -- and as we follow through our recursion process
  -- the demand flows to the components all the way
  -- to the bottom of the bill
  -- -------------------------------------------------

  g_stmt_num := 175;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Calling Cascade_Fcst_Demand in NON Recursive Mode';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- Before we call the function Cascade_Fcst_Demand,
  --  we need to set the flags
  -- l_explode_always and l_sales_order_demand.
  -- Setting l_sales_order demand is very straight forward.
  -- l_explode_always is set to TRUE if the demand_type is Manual for
  -- either forecast or schedule inputs or if the item type is 'Standard'

    l_sales_order_demand := 'N';

  -- check to see if we are dealing with a standard item
  SELECT bom_item_type,
         nvl(fixed_order_quantity, nvl(minimum_order_quantity, nvl(maximum_order_quantity,1)))
  INTO   l_bom_item_type,
         l_foq
  FROM   mtl_system_items
  WHERE  inventory_item_id = p_inventory_item_id
  AND    organization_id = g_kanban_info_rec.organization_id;

  IF p_demand_type = 1 OR l_bom_item_type = 4 THEN
    l_explode_always := 'Y';
  ELSE
    l_explode_always := 'N';
  END IF;

  l_ret_val := Cascade_Fcst_Demand(
				1,
				FALSE,
                                p_line_id,
                                l_line_id,
                                p_inventory_item_id,
                                p_inventory_item_id,
                                1,
                                NULL,
                                NULL,
                                p_demand_type,
                                l_explode_always,
                                l_sales_order_demand,
                                l_foq);

  IF NOT l_ret_val THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'INSERT_FCST_DEMAND Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Insert_Fcst_Demand;


-- ========================================================================
-- this function inserts demand for Acutal Production entries and explodes
-- the demand all the way down to the bottom of the bill
-- ========================================================================
FUNCTION Insert_Ap_Demand(
		p_inventory_item_id	IN number,
		p_alt_bom		IN varchar,
            	p_line_id 		IN number )
RETURN BOOLEAN IS

l_item_id 	      	number;
l_schedule_quantity   	number;
l_schedule_date       	date;
l_schedule_type		number;
l_line_id               number;
l_bom_item_type		number;
l_ret_val		boolean;
l_explode_always	VARCHAR2(1) := 'N'; /* This is a very important flag. It
			essentially tells us whether to overlook the forecast
			control setting on a component item and explode down
			the demand in the function Cascade_Mds_Mps_Demand*/
l_sales_order_demand	VARCHAR2(1) := 'N'; /* Again this flag helps us in
			deciding whether to explode down demand from an MDS or
			not */
l_foq                   number;

CURSOR item_schedule_entries IS
SELECT  sum(planned_quantity) PQ,
        scheduled_completion_date,
        schedule_type,
        line_id
FROM mrp_kanban_actual_prod_v
WHERE organization_id = g_kanban_info_rec.organization_id
AND scheduled_completion_date between g_kanban_info_rec.start_date AND
               g_kanban_info_rec.cutoff_date
AND primary_item_id IN
( select COMPONENT_ITEM_ID from mrp_low_level_codes
  WHERE ORGANIZATION_ID = g_kanban_info_rec.organization_id
  AND PLAN_ID = g_kanban_info_rec.kanban_plan_id )
AND primary_item_id = p_inventory_item_id
AND nvl(alternate_bom_designator, 'NONE') = nvl(p_alt_bom , 'NONE')
AND nvl(line_id,0)=nvl(p_line_id,0)
group by scheduled_completion_date,schedule_type,line_id;

BEGIN
  -- ---------------------------------------------
  -- Attribute the independent demand using
  -- allocation percent to the completion sub s
  -- as maintained in the pull sequences table
  -- ---------------------------------------------

  IF g_debug THEN
    g_log_message := 'Inserting Demand For :';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Item : ' || to_char(p_inventory_item_id) ;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Alternate : ' || p_alt_bom ;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Line Reference :' || to_char(p_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  g_stmt_num := 170;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- the first insert here is for the item for which we have
  -- mds/mps based on the allocation percentages mentioned
  -- in the mtl_kanban_pull_sequences table

  l_item_id := p_inventory_item_id;
  IF NOT item_schedule_entries%ISOPEN THEN
    OPEN item_schedule_entries;
  END IF;

  WHILE TRUE LOOP

    FETCH    item_schedule_entries
    INTO     l_schedule_quantity,
             l_schedule_date,
             l_schedule_type,
             l_line_id;
    EXIT WHEN item_schedule_entries%NOTFOUND;

    IF g_debug THEN
      g_log_message := 'demand quantity:'||to_char(l_schedule_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
      g_log_message := 'demand date:'||to_char(l_schedule_date);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

  /* Bug 2279877, we allow null-line for discrete and not get line from primary rtg
  IF (l_line_id is NULL) THEN
    Begin
      SELECT line_id
      INTO   l_line_id
      FROM   bom_operational_routings
      WHERE  alternate_routing_designator is NULL
      AND          assembly_item_id = p_inventory_item_id
      AND          organization_id  = g_kanban_info_rec.organization_id;
    Exception
      When Others Then
        Null;
    End;
  END IF;
  */

  INSERT INTO MRP_KANBAN_DEMAND (
 	DEMAND_ID,
 	KANBAN_PLAN_ID,
 	ORGANIZATION_ID,
 	INVENTORY_ITEM_ID,
 	SUBINVENTORY,
 	LOCATOR_ID,
 	ASSEMBLY_ITEM_ID,
 	ASSEMBLY_ORG_ID,
 	ASSEMBLY_SUBINVENTORY,
 	ASSEMBLY_LOCATOR_ID,
 	DEMAND_DATE,
 	DEMAND_QUANTITY,
 	ORDER_TYPE,
 	KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY )
  SELECT
	mrp_kanban_demand_s.nextval,
	g_kanban_info_rec.kanban_plan_id,
	g_kanban_info_rec.organization_id,
	p_inventory_item_id,
	ps.subinventory_name,
	ps.locator_id,
	NULL,
	NULL,
	NULL,
	NULL,
	l_schedule_date,
	(NVL(ps.allocation_percent, 100) *
	    l_schedule_quantity/ 100),
	l_schedule_type,
	'Y',
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
	fnd_global.user_id
  FROM
	mtl_kanban_pull_sequences ps
  WHERE ps.wip_line_id = l_line_id
  AND   ps.source_type = G_PRODUCTION_SOURCE_TYPE
  AND   ps.kanban_plan_id = decode (g_kanban_info_rec.replan_flag,
                                2, G_PRODUCTION_KANBAN,
                                1, g_kanban_info_rec.kanban_plan_id,
                                G_PRODUCTION_KANBAN)
  AND   ps.inventory_item_id = p_inventory_item_id
  AND   ps.organization_id = g_kanban_info_rec.organization_id;

  END LOOP; -- loop for my cursor
  IF item_schedule_entries%ISOPEN THEN
    CLOSE item_schedule_entries;
  END IF;

  -- -------------------------------------------------
  -- Pass down the dependent demand for each component
  -- By calling the recusive function
  -- First the demand flows to the components that are
  -- supplying to the line on which we have the demand
  -- and as we follow through our recursion process
  -- the demand flows to the components all the way
  -- to the bottom of the bill
  -- -------------------------------------------------

  g_stmt_num := 175;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Calling Cascade_Ap_Demand in NON Recursive Mode';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- Before we call the function Cascade_Ap_Demand,
  -- we need to set the flags
  -- l_explode_always and l_sales_order_demand.
  -- Setting l_sales_order demand is very straight forward.

    l_sales_order_demand := 'N';

  -- check to see if we are dealing with a standard item
  SELECT bom_item_type,
	 nvl(fixed_order_quantity, nvl(minimum_order_quantity, nvl(maximum_order_quantity,1)))
  INTO	 l_bom_item_type,
	 l_foq
  FROM	 mtl_system_items
  WHERE	 inventory_item_id = p_inventory_item_id
  AND    organization_id = g_kanban_info_rec.organization_id;

  l_explode_always := 'Y';

  l_ret_val := Cascade_Ap_Demand(
				1,
				FALSE,
                                p_line_id,
	 	     		l_line_id,
		     		p_inventory_item_id,
				p_alt_bom,
		     		p_inventory_item_id,
				p_alt_bom,
                                1,
		     		NULL,
		     		NULL,
		     		l_schedule_type,
				l_explode_always,
				l_sales_order_demand,
				l_foq);

  IF NOT l_ret_val THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'INSERT_AP_DEMAND Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Insert_Ap_Demand;

-- ========================================================================
-- this function inserts demand for MDS/MPS entries and explodes
-- the demand all the way down to the bottom of the bill
-- ========================================================================
FUNCTION Insert_Mds_Mps_Demand(
		p_inventory_item_id	IN number,
            	p_demand_type		IN number,
            	p_line_id 		IN number )
RETURN BOOLEAN IS
l_item_id 	      number;
l_schedule_quantity   number;
l_schedule_date               date;
l_schedule_origination_type  number;
l_line_id               number;
l_bom_item_type		number;
l_ret_val		boolean;
l_explode_always	VARCHAR2(1) := 'N'; /* This is a very important flag. It
			essentially tells us whether to overlook the forecast
			control setting on a component item and explode down
			the demand in the function Cascade_Mds_Mps_Demand*/
l_sales_order_demand	VARCHAR2(1) := 'N'; /* Again this flag helps us in
			deciding whether to explode down demand from an MDS or
			not */
l_foq                   number;

CURSOR item_schedule_entries IS
SELECT
        decode(schedule_quantity,NULL,MRP_KANBAN_PLAN_PK.Get_Repetitive_Demand(
        schedule_date,rate_end_date,repetitive_daily_rate),schedule_quantity),
        schedule_date,
        schedule_origination_type,
        line_id
FROM mrp_schedule_dates
WHERE   organization_id = g_kanban_info_rec.organization_id
AND     schedule_designator = g_kanban_info_rec.input_designator
AND     schedule_level = 2
AND     schedule_date BETWEEN g_kanban_info_rec.start_date AND
                g_kanban_info_rec.cutoff_date
AND inventory_item_id = p_inventory_item_id
AND nvl(line_id,0)=nvl(p_line_id,0)
AND schedule_origination_type = p_demand_type ;



BEGIN
  -- ---------------------------------------------
  -- Attribute the independent demand using
  -- allocation percent to the completion sub s
  -- as maintained in the pull sequences table
  -- ---------------------------------------------

  IF g_debug THEN
    g_log_message := 'Inserting Demand For :';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Item : ' || to_char(p_inventory_item_id) ;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Line Reference :' || to_char(p_line_id);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  g_stmt_num := 170;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- the first insert here is for the item for which we have
  -- mds/mps based on the allocation percentages mentioned
  -- in the mtl_kanban_pull_sequences table

  l_item_id := p_inventory_item_id;
  IF NOT item_schedule_entries%ISOPEN THEN
    OPEN item_schedule_entries;
  END IF;

  WHILE TRUE LOOP

    FETCH    item_schedule_entries
    INTO     l_schedule_quantity,
             l_schedule_date,
             l_schedule_origination_type,
             l_line_id;
    EXIT WHEN item_schedule_entries%NOTFOUND;

    IF g_debug THEN
      g_log_message := 'demand quantity:'||to_char(l_schedule_quantity);
      MRP_UTIL.MRP_LOG (g_log_message);
      g_log_message := 'demand date:'||to_char(l_schedule_date);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

  IF (l_line_id is NULL) THEN
    Begin
      SELECT line_id
      INTO   l_line_id
      FROM   bom_operational_routings
      WHERE  alternate_routing_designator is NULL
      AND          assembly_item_id = p_inventory_item_id
      AND          organization_id  = g_kanban_info_rec.organization_id;
    Exception
      When Others Then
        Null;
    End;
  END IF;

  INSERT INTO MRP_KANBAN_DEMAND (
 	DEMAND_ID,
 	KANBAN_PLAN_ID,
 	ORGANIZATION_ID,
 	INVENTORY_ITEM_ID,
 	SUBINVENTORY,
 	LOCATOR_ID,
 	ASSEMBLY_ITEM_ID,
 	ASSEMBLY_ORG_ID,
 	ASSEMBLY_SUBINVENTORY,
 	ASSEMBLY_LOCATOR_ID,
 	DEMAND_DATE,
 	DEMAND_QUANTITY,
 	ORDER_TYPE,
 	KANBAN_ITEM_FLAG,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY )
  SELECT
	mrp_kanban_demand_s.nextval,
	g_kanban_info_rec.kanban_plan_id,
	g_kanban_info_rec.organization_id,
	p_inventory_item_id,
	ps.subinventory_name,
	ps.locator_id,
	NULL,
	NULL,
	NULL,
	NULL,
	l_schedule_date,
	(NVL(ps.allocation_percent, 100) *
	    l_schedule_quantity/ 100),
	l_schedule_origination_type,
	'Y',
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        sysdate,
        fnd_global.user_id,
        sysdate,
	fnd_global.user_id
  FROM
	mtl_kanban_pull_sequences ps
  WHERE ps.wip_line_id = l_line_id
  AND   ps.source_type = G_PRODUCTION_SOURCE_TYPE
  AND   ps.kanban_plan_id = decode (g_kanban_info_rec.replan_flag,
                                2, G_PRODUCTION_KANBAN,
                                1, g_kanban_info_rec.kanban_plan_id,
                                G_PRODUCTION_KANBAN)
  AND   ps.inventory_item_id = p_inventory_item_id
  AND   ps.organization_id = g_kanban_info_rec.organization_id;

  END LOOP; -- loop for my cursor
  IF item_schedule_entries%ISOPEN THEN
    CLOSE item_schedule_entries;
  END IF;

  -- -------------------------------------------------
  -- Pass down the dependent demand for each component
  -- By calling the recusive function
  -- First the demand flows to the components that are
  -- supplying to the line on which we have the demand
  -- and as we follow through our recursion process
  -- the demand flows to the components all the way
  -- to the bottom of the bill
  -- -------------------------------------------------

  g_stmt_num := 175;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'Calling Cascade_Mds_Mps_Demand in NON Recursive Mode';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- Before we call the function Cascade_Mds_Mps_Demand,
  -- we need to set the flags
  -- l_explode_always and l_sales_order_demand.
  -- Setting l_sales_order demand is very straight forward.
  -- l_explode_always is set to TRUE if the demand_type is Manual for
  -- either forecast or schedule inputs or if the item type is 'Standard'

  IF ((g_kanban_info_rec.input_type = 2 OR
		g_kanban_info_rec.input_type = 3) AND p_demand_type = 3) THEN
    l_sales_order_demand := 'Y';
  ELSE
    l_sales_order_demand := 'N';
  END IF;

  -- check to see if we are dealing with a standard item
  SELECT bom_item_type,
         nvl(fixed_order_quantity, nvl(minimum_order_quantity, nvl(maximum_order_quantity,1)))
  INTO	 l_bom_item_type,
         l_foq
  FROM	 mtl_system_items
  WHERE	 inventory_item_id = p_inventory_item_id
  AND    organization_id = g_kanban_info_rec.organization_id;

  IF p_demand_type = 1 OR l_bom_item_type = 4 THEN
    l_explode_always := 'Y';
  ELSE
    l_explode_always := 'N';
  END IF;

  l_ret_val := Cascade_Mds_Mps_Demand(
				1,
				FALSE,
                                p_line_id,
	 	     		l_line_id,
		     		p_inventory_item_id,
		     		p_inventory_item_id,
                                1,
		     		NULL,
		     		NULL,
		     		p_demand_type,
				l_explode_always,
				l_sales_order_demand,
                                l_foq);

  IF NOT l_ret_val THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'INSERT_DEMAND Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Insert_Mds_Mps_Demand;


-- ========================================================================
-- This function gets the offset start date to be considered when we look
-- at forecast demand. for example a weekly forecast demand might have
-- a start date 2 days before our kanban start date and we would have to
-- consider a part of this forecast demand for our kanban calculation, else
-- we would be underestimating our demand
-- ========================================================================
FUNCTION Get_Offset_Date (
                p_start_date            IN date,
                p_bucket_type           IN NUMBER
)
RETURN DATE IS

l_offset_date   date;

BEGIN

  IF p_bucket_type = 1 THEN
    -- no offsetting here
    l_offset_date := p_start_date;

  ELSIF p_bucket_type = 2 THEN

    SELECT /*+ first_rows */ bw.week_start_date --bug 5237549
    INTO   l_offset_date
    FROM   bom_cal_week_start_dates bw,
           mtl_parameters mp
    WHERE  mp.organization_id = g_kanban_info_rec.organization_id
    AND    bw.calendar_code =  mp.calendar_code
    AND    bw.exception_set_id = mp.calendar_exception_set_id
    AND    bw.week_start_date <= p_start_date
    AND    bw.next_date >= p_start_date;

  ELSIF p_bucket_type = 3 THEN

    SELECT bp.period_start_date
    INTO   l_offset_date
    FROM   bom_period_start_dates bp,
           mtl_parameters mp
    WHERE  mp.organization_id = g_kanban_info_rec.organization_id
    AND    bp.calendar_code = mp.calendar_code
    AND    bp.exception_set_id = mp.calendar_exception_set_id
    AND    bp.period_start_date <= p_start_date
    AND    bp.next_date >= p_start_date;

  END IF;

  RETURN l_offset_date;

EXCEPTION
  WHEN OTHERS THEN
    RETURN p_start_date;

END Get_Offset_Date;


-- ========================================================================
-- this  function retrieves the kanban demand based on the
-- input to the kanban plan and passes it down to the components
-- as in the mrp_low_level_codes table
-- ========================================================================
FUNCTION Retrieve_Kanban_Demand RETURN BOOLEAN IS

-- declare local variables

l_demand_rec		demand_rec_type; -- record that stores demand info
l_rate_end_date		date;
l_bucket_type		number;
l_line_id		number;
l_alt_bom		varchar(10);
l_demand_type		number;
l_repetitive_forecast	boolean := FALSE;
l_ret_val		boolean;

-- declare cursors

-- cursor to retrieve forecast entries
CURSOR cur_forecast_entries IS
SELECT  inventory_item_id,
	origination_type,
	line_id
FROM    mrp_forecast_dates
WHERE   organization_id = g_kanban_info_rec.organization_id
/*
AND     ((forecast_designator = g_kanban_info_rec.input_designator) or
         (forecast_designator in ( -- forecast set
                select forecast_designator
                from mrp_forecast_designators
                where forecast_set = g_kanban_info_rec.input_designator)
         )
        )
*/ --bug 5237549
AND FORECAST_DESIGNATOR in (
    select  g_kanban_info_rec.input_designator from dual
    union all
    SELECT FORECAST_DESIGNATOR
    FROM MRP_FORECAST_DESIGNATORS
    WHERE FORECAST_SET = g_kanban_info_rec.input_designator )

AND     ((rate_end_date IS NULL AND
        forecast_date BETWEEN Get_Offset_Date(
                                g_kanban_info_rec.start_date,
                                bucket_type )
        AND g_kanban_info_rec.cutoff_date) OR
        (rate_end_date is NOT NULL AND NOT
         (rate_end_date < Get_Offset_Date(
                                g_kanban_info_rec.start_date,
                                bucket_type ) OR
          forecast_date > g_kanban_info_rec.cutoff_date)))
GROUP BY inventory_item_id,origination_type,line_id;

-- cursor to retrieve MPS/MDS entries
CURSOR cur_schedule_entries IS
SELECT  inventory_item_id,
        schedule_origination_type,
	line_id
FROM mrp_schedule_dates
WHERE   organization_id = g_kanban_info_rec.organization_id
AND     schedule_designator = g_kanban_info_rec.input_designator
AND     schedule_level = 2
AND	schedule_date BETWEEN g_kanban_info_rec.start_date AND
		g_kanban_info_rec.cutoff_date
GROUP BY inventory_item_id,schedule_origination_type,line_id;

-- cursor to retrieve actual production
CURSOR GetActualProductionDemand IS
SELECT  primary_item_id,
	alternate_bom_designator,
	line_id
FROM mrp_kanban_actual_prod_v
WHERE organization_id = g_kanban_info_rec.organization_id
AND scheduled_completion_date between g_kanban_info_rec.start_date AND
               g_kanban_info_rec.cutoff_date
AND primary_item_id IN
( select COMPONENT_ITEM_ID from mrp_low_level_codes
  where  ORGANIZATION_ID = g_kanban_info_rec.organization_id
  AND PLAN_ID = g_kanban_info_rec.kanban_plan_id )
group by primary_item_id,alternate_bom_designator,line_id;
BEGIN


  WHILE TRUE LOOP -- begin demand entries loop

    IF g_kanban_info_rec.input_type = 1 THEN
      -- input type is a forecast

      IF NOT cur_forecast_entries%ISOPEN THEN
        OPEN cur_forecast_entries;
      END IF;

      FETCH cur_forecast_entries
      INTO  l_demand_rec.inventory_item_id,
	    l_demand_type,
            l_line_id;

      EXIT WHEN cur_forecast_entries%NOTFOUND;

      IF g_debug THEN
        g_log_message := 'Forecast Entry Details : ' ;
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Item : ' || to_char(l_demand_rec.inventory_item_id) ;
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;

    ELSIF ( g_kanban_info_rec.input_type = 2 OR
       g_kanban_info_rec.input_type = 3 ) THEN
      -- input is an MDS (type = 2) or MPS (type = 3)

      IF NOT cur_schedule_entries%ISOPEN THEN
        OPEN cur_schedule_entries;
      END IF;

      FETCH cur_schedule_entries
      INTO l_demand_rec.inventory_item_id,
	   l_demand_type,
	   l_line_id;

      EXIT WHEN cur_schedule_entries%NOTFOUND;

      IF g_debug THEN
        g_log_message := 'Schedule Entry Details : ' ;
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Item : ' || to_char(l_demand_rec.inventory_item_id) ;
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Line Reference :' || to_char(l_line_id);
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;
    ELSIF ( g_kanban_info_rec.input_type = 4) THEN
      -- input is Actual Production (type = 4)

      IF NOT GetActualProductionDemand%ISOPEN THEN
        OPEN GetActualProductionDemand;
      END IF;

      FETCH GetActualProductionDemand
      INTO l_demand_rec.inventory_item_id,
	   l_alt_bom,
	   l_line_id;

      EXIT WHEN GetActualProductionDemand%NOTFOUND;

      IF g_debug THEN
        g_log_message := 'Schedule Entry Details : ' ;
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Item : ' || to_char(l_demand_rec.inventory_item_id) ;
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Alternate : ' || l_alt_bom;
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Line Reference :' || to_char(l_line_id);
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;
    END IF;

    g_stmt_num := 160;
    IF g_debug THEN
      g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
      MRP_UTIL.MRP_LOG (g_log_message);
      g_log_message := 'Calling Insert Demand function';
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;

      -- call the function to insert demand and explode it through
      -- to the bottom of the bill
      IF g_kanban_info_rec.input_type = 1 THEN
      -- input is an Forecast
        l_ret_val := Insert_Fcst_Demand( l_demand_rec.inventory_item_id,
                      	 	   l_demand_type,
                      		   l_line_id );
      ELSIF ( g_kanban_info_rec.input_type = 2 OR
         g_kanban_info_rec.input_type = 3 ) THEN
      -- input is an MDS (type = 2) or MPS (type = 3)
        l_ret_val := Insert_Mds_Mps_Demand( l_demand_rec.inventory_item_id,
                                   l_demand_type,
                                   l_line_id );
      ELSIF g_kanban_info_rec.input_type = 4 THEN
      -- input is an Actual Production
        l_ret_val := Insert_Ap_Demand( l_demand_rec.inventory_item_id,
				   l_alt_bom,
                                   l_line_id );

      END IF;

      IF NOT l_ret_val THEN
	RETURN FALSE;
      END IF;

  END LOOP; -- demand entries loop

  IF cur_forecast_entries%ISOPEN THEN
    CLOSE cur_forecast_entries;
  ELSIF cur_schedule_entries%ISOPEN THEN
    CLOSE cur_schedule_entries;
  ELSIF GetActualProductionDemand%ISOPEN THEN
    CLOSE GetActualProductionDemand;
  END IF;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'RETRIEVE_KANBAN_DEMAND Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Retrieve_Kanban_Demand;

-- ========================================================================
--  This function calculates the Kanban Size/Number
-- ========================================================================
function Kanban_Calculation_Pvt (
		p_average_demand		IN 	NUMBER,
		p_minimum_order_quantity	IN	NUMBER,
		p_fixed_lot_multiplier		IN	NUMBER,
		p_safety_stock_days		IN	NUMBER,
		p_replenishment_lead_time	IN	NUMBER,
		p_kanban_flag			IN	NUMBER,
		p_kanban_size			IN OUT	NOCOPY	NUMBER,
		p_kanban_number			IN OUT	NOCOPY	NUMBER )
RETURN BOOLEAN IS

l_current_demand		NUMBER;
l_order_quantity		NUMBER;
l_kanban_number			NUMBER;

BEGIN

  -- check if p_kanban_number is passed in as 1 and bump it
  -- upto 2 so that the math does'nt croak
  IF p_kanban_number = 1 THEN
    l_kanban_number := 2;
  ELSE
    l_kanban_number := p_kanban_number;
  END If;

  -- first calculate the Kanban Size or Kanban Number
  -- depending on the Kanban flag

  IF p_kanban_flag =  G_CALC_KANBAN_NUMBER THEN

    p_kanban_number :=
      CEIL(((p_average_demand * (nvl(p_replenishment_lead_time,1) +
			nvl(p_safety_stock_days, 0) ))/p_kanban_size) + 1);

  ELSIF p_kanban_flag = G_CALC_KANBAN_SIZE THEN

    p_kanban_size :=
      CEIL((p_average_demand * (nvl(p_replenishment_lead_time,1) +
		nvl(p_safety_stock_days, 0)))/(l_kanban_number - 1));
  END IF;

  -- now go ahead and apply the order modifiers
  -- If we are calculating Kanban size, we look at all the three order
  -- modifiers, ie, fixed days supply, min order quantity and fixed
  -- lot multiplier.
  -- If we are calculating number of Kanban cards, then we look at only
  -- the min order quantity.

  IF p_kanban_flag = G_CALC_KANBAN_SIZE THEN

    IF p_minimum_order_quantity IS NOT NULL THEN
      IF p_kanban_size < p_minimum_order_quantity THEN
	p_kanban_size := p_minimum_order_quantity;
      END IF;
    END IF;

    IF p_fixed_lot_multiplier IS NOT NULL THEN
      IF p_kanban_size < p_fixed_lot_multiplier THEN
	p_kanban_size := p_fixed_lot_multiplier;
      ELSIF MOD (p_kanban_size, p_fixed_lot_multiplier) > 0 THEN
	p_kanban_size := p_kanban_size + ( p_fixed_lot_multiplier
		- MOD (p_kanban_size, p_fixed_lot_multiplier));
      END IF;
    END IF;

  ELSIF p_kanban_flag =  G_CALC_KANBAN_NUMBER THEN

    -- Take min order quantity into consideration such that
    -- (Num. of Cards - 1) * Kanban Size is NOT LESS THAN
    -- (Min. Order Qty + Demand Over Lead Time ).

    IF (p_minimum_order_quantity IS NOT NULL AND
		p_minimum_order_quantity > p_kanban_size) THEN
      IF (p_kanban_size * (p_kanban_number - 1)) <
	      nvl(p_minimum_order_quantity,0) + (p_average_demand *
					nvl(p_replenishment_lead_time,1)) THEN
        p_kanban_number := CEIL((nvl(p_minimum_order_quantity,0) +
			(p_average_demand * nvl(p_replenishment_lead_time,1)))
			/ p_kanban_size) + 1;
      END IF;
    END IF;

  END IF;

  RETURN TRUE;

Exception
  WHEN OTHERS THEN
    g_log_message := 'KANBAN_CALCULATION_PVT Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Kanban_Calculation_Pvt;
-- ========================================================================
-- this  function calculates the kanban size/number for each
-- kanban item/location that we need to plan in this plan run
-- and inserts the information into mtl_kanban_pull_sequences table
-- ========================================================================

FUNCTION Calculate_Kanban_Quantity (p_total_workdays 	IN NUMBER)
RETURN BOOLEAN IS

-- declare local variables here
l_average_demand 		number;
l_item_id			number;
l_subinventory			varchar2(10);
l_locator_id			number;
l_replenishment_lead_time	number;
l_fixed_lot_multiplier		number;
l_safety_stock_days		number;
l_minimum_order_quantity	number;
l_api_version			number;
l_pull_sequence_rec 		INV_Kanban_PVT.pull_sequence_Rec_type;
l_return_status     		varchar2(1);

-- declare a cursor to summarize the demand for each
-- distinct item/location and calculate the average demand
-- for this item/location over the user defined time period

CURSOR 	cur_kanban_demand IS
SELECT 	(sum(demand_quantity)/p_total_workdays),
	inventory_item_id,
	subinventory,
	locator_id
FROM 	mrp_kanban_demand
WHERE 	kanban_plan_id = g_kanban_info_rec.kanban_plan_id
AND	organization_id = g_kanban_info_rec.organization_id
AND    (demand_date >= g_kanban_info_rec.start_date
        AND     demand_date <= g_kanban_info_rec.cutoff_date )
AND	kanban_item_flag = 'Y'
GROUP BY
	inventory_item_id,
	subinventory,
	locator_id;

-- Cursor to retrieve information from pull sequences table
CURSOR cur_pull_sequence IS
SELECT  source_type,
 	supplier_id,
 	supplier_site_id,
 	source_organization_id,
 	source_subinventory,
 	source_locator_id,
 	wip_line_id,
 	replenishment_lead_time,
 	calculate_kanban_flag,
 	kanban_size,
 	fixed_lot_multiplier,
 	safety_stock_days,
 	number_of_cards,
 	minimum_order_quantity,
 	aggregation_type,
 	allocation_percent,
	release_kanban_flag
FROM   mtl_kanban_pull_sequences
WHERE  kanban_plan_id = decode (g_kanban_info_rec.replan_flag,
				2, G_PRODUCTION_KANBAN,
				1, g_kanban_info_rec.kanban_plan_id,
				G_PRODUCTION_KANBAN)
AND    organization_id = g_kanban_info_rec.organization_id
AND    inventory_item_id = l_item_id
AND    subinventory_name = l_subinventory
AND    nvl(locator_id,-1) = nvl(l_locator_id,-1);

BEGIN

  IF g_debug THEN
    g_log_message := 'Entering Calculate_Kanban_Quantity Function';
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  OPEN cur_kanban_demand;

  WHILE TRUE LOOP
    FETCH cur_kanban_demand
    INTO  l_average_demand,
	  l_item_id,
	  l_subinventory,
	  l_locator_id;

    IF g_debug THEN
      g_log_message := 'Item Id : ' || to_char (l_item_id);
      MRP_UTIL.MRP_LOG (g_log_message);
      g_log_message := 'SubInventory : ' || l_subinventory;
      MRP_UTIL.MRP_LOG (g_log_message);
      g_log_message := 'Locator  : ' || to_char(l_locator_id);
      MRP_UTIL.MRP_LOG (g_log_message);
    END IF;


    EXIT WHEN cur_kanban_demand%NOTFOUND;

    -- now get some information about this item/location from
    -- mtl_kanban_pull_sequences

    OPEN cur_pull_sequence;

    FETCH   cur_pull_sequence
    INTO    l_pull_sequence_rec.source_type,
            l_pull_sequence_rec.supplier_id,
            l_pull_sequence_rec.supplier_site_id,
            l_pull_sequence_rec.source_organization_id,
            l_pull_sequence_rec.source_subinventory,
            l_pull_sequence_rec.source_locator_id,
            l_pull_sequence_rec.wip_line_id,
            l_pull_sequence_rec.replenishment_lead_time,
            l_pull_sequence_rec.calculate_kanban_flag,
            l_pull_sequence_rec.kanban_size,
            l_pull_sequence_rec.fixed_lot_multiplier,
            l_pull_sequence_rec.safety_stock_days,
            l_pull_sequence_rec.number_of_cards,
            l_pull_sequence_rec.minimum_order_quantity,
            l_pull_sequence_rec.aggregation_type,
            l_pull_sequence_rec.allocation_percent,
	    l_pull_sequence_rec.release_kanban_flag;


    --call the kanban quantity calculation api if we find pull sequence info

    IF cur_pull_sequence%FOUND THEN

      l_return_status := 'S'; -- initialize to success

      -- initialize either kanban size/number to null depending on what
      -- we are calculating. This is important because we call our local
      -- kanban calculation API if the public API (stubbed out) returns
      -- a null value in what we want to calculate

      IF l_pull_sequence_rec.calculate_kanban_flag = G_CALC_KANBAN_SIZE THEN
	l_pull_sequence_rec.kanban_size := NULL;
      ELSIF l_pull_sequence_rec.calculate_kanban_flag =
						G_CALC_KANBAN_NUMBER THEN
	l_pull_sequence_rec.number_of_cards := NULL;
      END IF;


      IF g_debug THEN
        g_log_message := 'Calling Kanban Qty Calc API';
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Parameters Passed to the Kanban Qty Calc API : ';
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Demand :' || to_char (l_average_demand);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Min Order Qty :'
		|| to_char (l_pull_sequence_rec.minimum_order_quantity);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Fixed Lot Multiplier : '
		|| to_char (l_pull_sequence_rec.fixed_lot_multiplier);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Fixed Days Supply :'
		|| to_char (l_pull_sequence_rec.safety_stock_days);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Replenishment Lead Time :'
		|| to_char (l_pull_sequence_rec.replenishment_lead_time);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Calculate Kanban Flag :'
		|| to_char (l_pull_sequence_rec.calculate_kanban_flag);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Kanban Size :'
		|| to_char (l_pull_sequence_rec.kanban_size);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Number of Cards :'
		|| to_char (l_pull_sequence_rec.number_of_cards);
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;

      -- specify the version of the API we want to call
      l_api_version := 1.0;

      MRP_PUB_KANBAN_QTY_CALC.Calculate_Kanban_Quantity (
		l_api_version,
		l_average_demand,
		l_pull_sequence_rec.minimum_order_quantity,
		l_pull_sequence_rec.fixed_lot_multiplier,
		l_pull_sequence_rec.safety_stock_days,
		l_pull_sequence_rec.replenishment_lead_time,
		l_pull_sequence_rec.calculate_kanban_flag,
		l_pull_sequence_rec.kanban_size,
		l_pull_sequence_rec.number_of_cards,
	        l_return_status );

      IF l_return_status <> 'S' THEN
        IF g_debug THEN
          g_log_message := 'Error in Kanban Quantity Calculation API';
          MRP_UTIL.MRP_LOG (g_log_message);
        END IF;
        RETURN FALSE;
      END IF;

      IF l_pull_sequence_rec.kanban_size IS NULL OR
          l_pull_sequence_rec.number_of_cards IS NULL THEN

	IF NOT Kanban_Calculation_Pvt (
		l_average_demand,
		l_pull_sequence_rec.minimum_order_quantity,
		l_pull_sequence_rec.fixed_lot_multiplier,
		l_pull_sequence_rec.safety_stock_days,
		l_pull_sequence_rec.replenishment_lead_time,
		l_pull_sequence_rec.calculate_kanban_flag,
		l_pull_sequence_rec.kanban_size,
		l_pull_sequence_rec.number_of_cards ) THEN

        IF g_debug THEN
          g_log_message := 'Error in Kanban Calculation function';
          MRP_UTIL.MRP_LOG (g_log_message);
        END IF;
          RETURN FALSE;

	END IF;
      END IF;

      -- Now go ahead and insert/update into mtl_kanban_pull_sequences table
      -- information about this kanban item/location for this kanban plan

      SELECT
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           sysdate,
	   sysdate,
	   fnd_global.user_id,
	   sysdate,
	   fnd_global.user_id
      INTO
           l_pull_sequence_rec.request_id,
           l_pull_sequence_rec.program_application_id,
           l_pull_sequence_rec.program_id,
           l_pull_sequence_rec.program_update_date,
	   l_pull_sequence_rec.last_update_date,
	   l_pull_sequence_rec.last_updated_by,
	   l_pull_sequence_rec.creation_date,
	   l_pull_sequence_rec.created_by
      FROM   dual;

      l_pull_sequence_rec.organization_id := g_kanban_info_rec.organization_id;
      l_pull_sequence_rec.kanban_plan_id := g_kanban_info_rec.kanban_plan_id;
      l_pull_sequence_rec.inventory_item_id := l_item_id;
      l_pull_sequence_rec.subinventory_name := l_subinventory;
      l_pull_sequence_rec.locator_id := l_locator_id;
      l_pull_sequence_rec.pull_sequence_id := NULL;

      IF g_debug THEN
        g_log_message := 'Kanban Size after Calculation : '
				|| to_char(l_pull_sequence_rec.kanban_size);
        MRP_UTIL.MRP_LOG (g_log_message);
        g_log_message := 'Kanban Number after Calculation : '
				|| to_char(l_pull_sequence_rec.number_of_cards);
        MRP_UTIL.MRP_LOG (g_log_message);
      END IF;

      -- call the inventory api for inserting into mtl_pull_sequences
      l_return_status := 'S'; -- initialize to success

      IF nvl(g_kanban_info_rec.replan_flag,2) = 2 THEN  -- not replan
        INV_Kanban_PVT.Insert_pull_sequence
	  (l_return_status,
 	   l_pull_sequence_rec);
      ELSIF g_kanban_info_rec.replan_flag = 1 THEN -- replan
        INV_Kanban_PVT.Update_pull_sequence
	  (l_return_status,
 	   l_pull_sequence_rec);
      END If;

      IF l_return_status <> 'S' THEN
        IF g_debug THEN
      	  g_log_message := 'Error in Inventory Insert/Update API';
    	  MRP_UTIL.MRP_LOG (g_log_message);
    	  g_log_message := 'Return Code : ' || l_return_status;
    	  MRP_UTIL.MRP_LOG (g_log_message);
        END IF;
	RETURN FALSE;
      END IF;

    END IF;

    CLOSE cur_pull_sequence;

  END LOOP;

  --we are now done and can close the cursor
  CLOSE cur_kanban_demand;

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    g_log_message := 'CALCULATE_KANBAN_QUANTITY Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);
    RETURN FALSE;

END Calculate_Kanban_Quantity;

-- ========================================================================
--  This is the main procedure that controls the flow of the kanban planning
--  process
-- ========================================================================

PROCEDURE PLAN_KANBAN(  ERRBUF				OUT NOCOPY	VARCHAR2,
			RETCODE				OUT NOCOPY	NUMBER,
			p_organization_id               IN NUMBER,
                        p_kanban_plan_id                IN NUMBER,
                        p_from_item                     IN VARCHAR2,
                        p_to_item                       IN VARCHAR2,
                        p_category_set_id               IN NUMBER,
                        p_category_structure_id         IN NUMBER,
                        p_from_category                 IN VARCHAR2,
                        p_to_category                   IN VARCHAR2,
                        p_bom_effectivity               IN VARCHAR2,
                        p_start_date                    IN VARCHAR2,
                        p_cutoff_date                   IN VARCHAR2,
                        p_replan_flag                   IN NUMBER ) IS

-- declare some local variable here
l_llc_rec		llc_rec_type;
l_curr_ll_code		number;
l_ret_val		boolean;
l_total_workdays	number;

var_trace                       boolean;
c                                       integer;
statement                       varchar2(255);
rows_processed          integer;

-- declare exceptions we want to handle here
exc_error_condition	exception;

BEGIN

  g_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

  var_trace := fnd_profile.value('MRP_TRACE') = 'Y';
  if var_trace then
    c := dbms_sql.open_cursor;
    statement := 'alter session set sql_trace=true';
    dbms_sql.parse(c, statement, dbms_sql.native);
    rows_processed := dbms_sql.execute(c);
    dbms_sql.close_cursor(c);
  end if;

  g_stmt_num := 10;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

-- check for mandatory parameters
-- and issue appropriate error messages
  IF g_debug THEN
    IF p_organization_id IS NULL THEN
      g_log_message := 'Error : Organization Id is null';
    ELSIF p_kanban_plan_id IS NULL THEN
      g_log_message := 'Error : Kanban Plan Id is null';
    ELSIF (p_bom_effectivity IS NULL AND p_replan_flag = 2) THEN
      g_log_message := 'Error : BOM effectivity date is null';
    ELSIF (p_start_date IS NULL AND p_replan_flag = 2) THEN
      g_log_message := 'Error : Start date is null';
    ELSIF (p_cutoff_date IS NULL AND p_replan_flag = 2) THEN
      g_log_message := 'Error : Cutoff date is null';
    END IF;
  END IF;

  IF p_organization_id IS NULL OR p_kanban_plan_id IS NULL OR
	((p_bom_effectivity IS NULL OR p_cutoff_date IS NULL) AND
	  p_replan_flag = 2) THEN
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;

  -- get all the parameters passed to this concurrent program into
  -- the global record variable
  g_kanban_info_rec.organization_id := p_organization_id;
  g_kanban_info_rec.kanban_plan_id := p_kanban_plan_id;
  g_kanban_info_rec.from_item := p_from_item;
  g_kanban_info_rec.to_item := p_to_item;
  g_kanban_info_rec.category_set_id := p_category_set_id;
  g_kanban_info_rec.category_structure_id := p_category_structure_id;
  g_kanban_info_rec.from_category := p_from_category;
  g_kanban_info_rec.to_category := p_to_category;
  g_kanban_info_rec.bom_effectivity :=
	to_date(p_bom_effectivity,'YYYY/MM/DD HH24:MI:SS');
  g_kanban_info_rec.start_date :=
		to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
  g_kanban_info_rec.cutoff_date :=
	to_date(p_cutoff_date,'YYYY/MM/DD HH24:MI:SS');
  g_kanban_info_rec.replan_flag := p_replan_flag;

  IF g_debug THEN
    g_log_message := 'Parameters passed to the program :';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'organization_id : ' || p_organization_id;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'kanban_plan_id : ' || p_kanban_plan_id;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'from_item_id : ' || p_from_item;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'to_item_id : ' || p_to_item;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'category_set_id : ' || p_category_set_id;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'category_structure_id : ' || p_category_structure_id;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'from_category_id : ' || p_from_category;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'to_category_id : ' || p_to_category;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'bom_effectivity : ' || p_bom_effectivity;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'start_date : ' || p_start_date;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'cutoff_date : ' || p_cutoff_date;
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := 'replan_flag : ' || p_replan_flag;
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- call the start_kanban function
  IF NOT Start_Kanban_Plan THEN
    g_log_message := 'Error in START_KANBAN_PLAN';
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;

/*
this has been moved to Start_Kanban_Plan procedure
because we now want to commit after the snapshot is over so that
there is less impact on rollback segment

  -- call the procedure to snapshot the item/locations and
  -- populate mrp_low_level_codes table.
  -- Note that we are calculating low level codes
  -- only to detect loops and not for planning purposes.
  -- We gather demand by looking at the input to the plan
  -- and then blow it down to the component item/locations

  IF NOT mrp_kanban_snapshot_pk.snapshot_item_locations THEN
    g_log_message := 'Error in SNAPSHOT_ITEM_LOCATIONS';
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;
*/
  g_stmt_num := 150;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- now call the procedure to retrieve the kanban demand based on
  -- the input to the kanban plan and pass it down to the components
  -- as in the mrp_low_level_codes table

  IF NOT Retrieve_Kanban_Demand THEN
    g_log_message := 'Error in RETRIEVE_KANBAN_DEMAND';
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;

  -- We now have all the demand for this plan run stored in the
  -- mrp_kanban_demand table. So go ahead and call the procedure
  -- to calculate Kanban quantities for the kanban items included
  -- in this plan

  --first calculate the total number of workdays between start date
  --and cutoff date specified
  SELECT count(*)
  INTO l_total_workdays
  FROM  bom_calendar_dates bcd,
	mtl_parameters mp
  WHERE mp.organization_id = g_kanban_info_rec.organization_id
  AND   bcd.calendar_code = mp.calendar_code
  AND   bcd.seq_num IS NOT NULL
  AND   (bcd.calendar_date BETWEEN g_kanban_info_rec.start_date AND
	 g_kanban_info_rec.cutoff_date );


  g_stmt_num := 180;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  IF NOT (Calculate_Kanban_Quantity (l_total_workdays)) THEN
    g_log_message := 'Error in CALCULATE_KANBAN_QUANTITY';
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;

  g_stmt_num := 190;
  IF g_debug THEN
    g_log_message := 'Debug Statement Number : ' || to_char (g_stmt_num);
    MRP_UTIL.MRP_LOG (g_log_message);
  END IF;

  -- if we come here then we are done with the planning and we can
  -- update the plan_completion_date

  l_ret_val := End_Kanban_Plan;

  IF NOT l_ret_val THEN
    g_log_message := 'Error in END_KANBAN_PLAN';
    MRP_UTIL.MRP_LOG (g_log_message);
    raise exc_error_condition;
  END IF;

  IF g_raise_warning THEN
    ERRBUF := 'Kanban Planning Engine completed with warning';
    RETCODE := G_WARNING;
    g_raise_warning := FALSE;
  ELSE
    ERRBUF := 'Kanban Planning Engine completed a successful run';
    RETCODE := G_SUCCESS;
  END IF;

-- Exception Handling

EXCEPTION

  WHEN exc_error_condition THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    ERRBUF := 'Program Completed with Error : ' || sqlerrm;
    g_log_message := 'Program encountered Error condition Exception';
    MRP_UTIL.MRP_LOG (g_log_message);

  WHEN OTHERS THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    ERRBUF := 'Program Completed with Error : ' || sqlerrm;
    g_log_message := 'PLAN_KANBAN Sql Error ';
    MRP_UTIL.MRP_LOG (g_log_message);
    g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (g_log_message);


END PLAN_KANBAN;

END MRP_KANBAN_PLAN_PK;

/

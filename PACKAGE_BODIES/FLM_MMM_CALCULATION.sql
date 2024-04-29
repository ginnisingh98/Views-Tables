--------------------------------------------------------
--  DDL for Package Body FLM_MMM_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_MMM_CALCULATION" AS
/* $Header: FLMMMMCB.pls 120.2.12000000.2 2007/02/26 19:52:51 ksuleman ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : FLMMMMCB.pls                                               |
| DESCRIPTION  : This package contains functions used to calculate values   |
|                for the New Mixed Model Map Form		            |
| Coders       : Liye Ma 	(01/09/02 - 03/30/02)                       |
|    		 Hadi Wenas 	(04/01/02 - present )                       |
|                Navin Rajpal                                               |
+===========================================================================*/



/************************************************************************
 *	Package variables                                               *
 ************************************************************************/
G_DEBUG         BOOLEAN := (FND_PROFILE.VALUE('MRP_DEBUG') = 'Y');

/************************************************************************
 *	Private Procedures and Functions                             	*
 ************************************************************************/

/************************************************************************
 * PROCEDURE print_log							*
 * 	Inserts debug msg into log file.				*
 *	                                                                *
 ************************************************************************/
PROCEDURE print_log (buf	VARCHAR2) IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, buf);
END;


/************************************************************************
 * PROCEDURE calculate_avg_daily_demand					*
 *  	Calculates and returns average daily demand based on input.	*
 ************************************************************************/
PROCEDURE calculate_avg_daily_demand(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_product_family_id	IN	NUMBER,
	i_line_id		IN	NUMBER,
	i_demand_type		IN	NUMBER,
	i_demand_code		IN	VARCHAR2,
	i_start_date		IN	DATE,
	i_end_date		IN	DATE,
	i_demand_days		IN	NUMBER,
	i_boost_percent		IN	NUMBER,
	i_calendar_code		IN	VARCHAR2,
    	i_exception_set_id  	IN	NUMBER,
    	i_last_calendar_date 	IN	DATE,
	o_demand		OUT NOCOPY 	t_demand_table) IS

  l_demand	NUMBER;		-- Average Daily Demand
  l_line_id	NUMBER;
  l_dummy	NUMBER;
  l_info	VARCHAR2(1000);
  l_order_option	NUMBER; -- Sales/Planned Order Option
  l_demand_days         NUMBER; -- Demand days on a particular line
  l_product_family_id	NUMBER; -- Product Family Id

  -- cursor to retrieve forecast entries
  CURSOR forecast_entries IS
    SELECT DISTINCT inventory_item_id item_id
    FROM  mrp_forecast_dates
    WHERE organization_id = i_organization_id
      AND forecast_designator = i_demand_code
      AND ((rate_end_date IS NULL
            AND
            forecast_date BETWEEN get_offset_date(i_organization_id,
                                  		  i_start_date,
                                		  bucket_type )
                          AND i_end_date
           ) OR
           (rate_end_date is NOT NULL
            AND
            NOT (rate_end_date < get_offset_date(i_organization_id,
                                	         i_start_date,
                                	         bucket_type )
                 OR
                 forecast_date > i_end_date
                )
           )
          );

  -- cursor to retrieve MPS/MDS entries
  CURSOR schedule_entries IS
    SELECT DISTINCT
      inventory_item_id item_id,
      line_id
    FROM mrp_schedule_dates
    WHERE organization_id = i_organization_id
      AND schedule_designator = i_demand_code
      AND schedule_level = 2
      AND trunc(schedule_date) BETWEEN i_start_date AND i_end_date;

  -- cursor to retrieve actual production
  CURSOR actual_production_entries IS
/* avoid using this view, it's non-mergable */
/*    SELECT DISTINCT
      primary_item_id item_id,
      line_id
    FROM mrp_line_sch_avail_v
    WHERE organization_id = i_organization_id
      AND trunc(scheduled_completion_date) between i_start_date AND i_end_date;
*/
SELECT distinct PRIMARY_ITEM_ID ITEM_ID, LINE_ID
FROM
(
  SELECT
       REPITEM.PRIMARY_ITEM_ID,
       REP.LINE_ID
  FROM BOM_CALENDAR_DATES       BOM,
       WIP_REPETITIVE_ITEMS     REPITEM,
       WIP_REPETITIVE_SCHEDULES REP,
       MTL_PARAMETERS           MP
 WHERE BOM.CALENDAR_DATE BETWEEN TRUNC(REP.FIRST_UNIT_COMPLETION_DATE) AND
       TRUNC(REP.LAST_UNIT_COMPLETION_DATE)
   AND BOM.SEQ_NUM IS NOT NULL
   AND MP.CALENDAR_CODE = BOM.CALENDAR_CODE
   AND MP.CALENDAR_EXCEPTION_SET_ID = BOM.EXCEPTION_SET_ID
   AND MP.ORGANIZATION_ID = REP.ORGANIZATION_ID
   AND REPITEM.LINE_ID = REP.LINE_ID
   AND REPITEM.WIP_ENTITY_ID = REP.WIP_ENTITY_ID
   AND REPITEM.ORGANIZATION_ID = REP.ORGANIZATION_ID
   AND REPITEM.LINE_ID IS NOT NULL
   AND REP.organization_id = i_organization_id
   and trunc(BOM.CALENDAR_DATE) between i_start_date AND i_end_date
UNION ALL
SELECT
       JOB.PRIMARY_ITEM_ID,
       JOB.LINE_ID
  FROM WIP_DISCRETE_JOBS JOB
 WHERE JOB.LINE_ID IS NOT NULL
   AND JOB.organization_id = i_organization_id
   and trunc(JOB.scheduled_completion_date) between i_start_date AND i_end_date
UNION ALL
SELECT
       FLOW.PRIMARY_ITEM_ID,
       FLOW.LINE_ID
  FROM WIP_FLOW_SCHEDULES FLOW
 WHERE FLOW.LINE_ID IS NOT NULL
   AND FLOW.organization_id = i_organization_id
   and trunc(FLOW.scheduled_completion_date) between i_start_date AND i_end_date
);


  -- cursor to retrieve sales orders and planned orders
/*  performance bug 14597218 - try avoid using view mrp_unscheduled_orders_v */
/*  use two more cursors instead*/
/*  CURSOR order_entries(i_option IN NUMBER) IS
    SELECT DISTINCT
           inventory_item_id item_id,
           line_id
      FROM mrp_unscheduled_orders_v
     WHERE organization_id = i_organization_id
       AND trunc(order_date) BETWEEN i_start_date AND i_end_date
       AND unscheduled_order_option = i_option;
*/

  CURSOR order_entries(i_option IN NUMBER) IS
    SELECT null item_id, null line_id from dual;
  so_po_rec order_entries%rowtype;

  CURSOR so_order_entries IS
  SELECT distinct
       sl1.inventory_item_id item_id,
       wl.line_id
  FROM
       OE_ORDER_LINES_ALL SL1,
       MTL_SYSTEM_ITEMS_KFV MSI1,
       WIP_LINES WL,
       (select sl2.line_id,
               decode((select 1
                        from oe_order_holds_all oh
                       where oh.header_id = sl2.header_id
                         and rownum = 1
                         and oh.released_flag = 'N'),
                      null,
                      0,
                      decode(sl2.ato_line_id,
                             null,
                             mrp_flow_schedule_util.check_holds(sl2.header_id,
                                                                sl2.line_id,
                                                                'OEOL',
                                                                'LINE_SCHEDULING'),
                             mrp_flow_schedule_util.check_holds(sl2.header_id,
                                                                sl2.line_id,
                                                                null,
                                                                null))) hold
          from oe_order_lines_all sl2) line_holds,
       (select sl2.line_id,
               CTO_WIP_WORKFLOW_API_PK.workflow_build_status(sl2.LINE_ID) status
          from oe_order_lines_all sl2) line_build
 WHERE
   line_build.line_id = sl1.line_id
   AND 1 = decode(MSI1.REPLENISH_TO_ORDER_FLAG, 'N', 1, line_build.status)
   AND MSI1.BUILD_IN_WIP_FLAG = 'Y'
   AND MSI1.PICK_COMPONENTS_FLAG = 'N'
   AND MSI1.BOM_ITEM_TYPE = 4
   AND MSI1.ORGANIZATION_ID = SL1.SHIP_FROM_ORG_ID
   AND MSI1.INVENTORY_ITEM_ID = SL1.INVENTORY_ITEM_ID
   AND SL1.ORDERED_QUANTITY > 0
   AND SL1.VISIBLE_DEMAND_FLAG = 'Y'
   AND SL1.OPEN_FLAG = 'Y'
   AND SL1.ITEM_TYPE_CODE in ('STANDARD', 'CONFIG', 'INCLUDED', 'OPTION')
   AND OE_INSTALL.GET_ACTIVE_PRODUCT = 'ONT'
   AND wl.organization_id = sl1.ship_from_org_id
   AND wl.line_id in (select line_id
                        from bom_operational_routings bor2
                       where bor2.assembly_item_id = sl1.inventory_item_id
                         and bor2.organization_id = sl1.ship_from_org_id
                         and bor2.cfm_routing_flag = 1)
   AND SL1.SHIPPED_QUANTITY is NULL
   and sl1.line_id = line_holds.line_id
   and line_holds.hold = 0
   AND NVL(SL1.FULFILLED_FLAG, 'N') <> 'Y'
   /* cursor specific criteria */
     AND msi1.organization_id = i_organization_id
     AND trunc(sl1.schedule_ship_date) BETWEEN i_start_date AND i_end_date;

  CURSOR po_order_entries IS
  SELECT distinct
       MR1.INVENTORY_ITEM_ID item_id,
       WL.LINE_ID
  FROM MTL_SYSTEM_ITEMS_B   KFV,
       MRP_SYSTEM_ITEMS     RSI1,
       MRP_PLANS            MP1,
       MRP_RECOMMENDATIONS  MR1,
       WIP_LINES            WL
 WHERE MP1.PLAN_COMPLETION_DATE IS NOT NULL
   AND MP1.DATA_COMPLETION_DATE IS NOT NULL
   AND MP1.COMPILE_DESIGNATOR = MR1.COMPILE_DESIGNATOR
   AND (MP1.ORGANIZATION_ID = MR1.ORGANIZATION_ID OR
       (MP1.ORGANIZATION_ID IN
       (SELECT ORGANIZATION_ID
            FROM MRP_PLAN_ORGANIZATIONS
           WHERE COMPILE_DESIGNATOR = MR1.COMPILE_DESIGNATOR
             AND PLANNED_ORGANIZATION = MR1.ORGANIZATION_ID)))
   AND MR1.ORGANIZATION_ID = MR1.SOURCE_ORGANIZATION_ID
   AND KFV.INVENTORY_ITEM_ID = RSI1.INVENTORY_ITEM_ID
   AND KFV.ORGANIZATION_ID = RSI1.ORGANIZATION_ID
   AND NVL(KFV.RELEASE_TIME_FENCE_CODE, -1) <> 6 /* KANBAN ITEM */
   AND MR1.ORDER_TYPE = 5 /* PLANNED ORDER */
   AND MR1.ORGANIZATION_ID = RSI1.ORGANIZATION_ID
   AND MR1.COMPILE_DESIGNATOR = RSI1.COMPILE_DESIGNATOR
   AND MR1.INVENTORY_ITEM_ID = RSI1.INVENTORY_ITEM_ID
   AND MR1.COMPILE_DESIGNATOR =
/*       (SELECT DESIGNATOR
          FROM MRP_DESIGNATORS_VIEW
         WHERE PRODUCTION = 1
           AND ORGANIZATION_ID = MP1.ORGANIZATION_ID
           AND DESIGNATOR = MR1.COMPILE_DESIGNATOR) */  /* bug 4911869 - flatten view mrp_designators_view */
       ( SELECT S.SCHEDULE_DESIGNATOR FROM MRP_SCHEDULE_DESIGNATORS S
          WHERE s.production = 1 and s.organization_id = mp1.organization_id
            and s.schedule_designator = mr1.compile_designator
         UNION ALL
         SELECT D.COMPILE_DESIGNATOR
           FROM MRP_DESIGNATORS D
          WHERE d.production = 1 and d.organization_id = mp1.organization_id
            and d.COMPILE_DESIGNATOR = mr1.compile_designator)
   AND RSI1.BUILD_IN_WIP_FLAG = 1 /* YES */
   AND RSI1.BOM_ITEM_TYPE = 4
   AND (RSI1.IN_SOURCE_PLAN = 2 OR RSI1.IN_SOURCE_PLAN IS NULL)
   AND wl.organization_id = MR1.ORGANIZATION_ID
   AND wl.line_id in (select line_id
                        from bom_operational_routings bor2
                       where bor2.assembly_item_id = MR1.INVENTORY_ITEM_ID
                         and bor2.organization_id = MR1.ORGANIZATION_ID
                         and bor2.cfm_routing_flag = 1)
   /* cursor specific criteria */
     AND MR1.organization_id = i_organization_id
     AND trunc(NVL(MR1.FIRM_DATE, MR1.NEW_SCHEDULE_DATE))
       BETWEEN i_start_date AND i_end_date;


  -- cursor to retrieve line_id for given item_id
  CURSOR line(i_assembly_item_id IN NUMBER) IS
    SELECT distinct line_id
    FROM bom_operational_routings
    WHERE organization_id = i_organization_id
      AND assembly_item_id = i_assembly_item_id
      AND cfm_routing_flag = 1
      AND mixed_model_map_flag = 1;

  -- cursor to retrieve demand days on a line, in case of Actual Production
  CURSOR schedule_days(i_line_id IN NUMBER) IS
  /* This query has performance issue: Shared Memory Size > 1MB
   SELECT count(distinct(to_char(scheduled_completion_date))) num_days
      FROM mrp_line_schedules_v
     WHERE organization_id = i_organization_id
       AND line_id = i_line_id
       AND trunc(scheduled_completion_date) BETWEEN i_start_date AND i_end_date;
  */
    --fix bug#3293206:
    --  change sum(num_days) to max(num_days)
    --  add MTL_PARAMETERS criteria when querying BOM_CALENDAR_DATES
    SELECT max(num_days)
      FROM (
        SELECT count(distinct(to_char(BOM.calendar_Date))) num_days
          FROM BOM_CALENDAR_DATES       BOM,
	       WIP_REPETITIVE_SCHEDULES REP,
               MTL_PARAMETERS           MP
         WHERE REP.line_id =i_line_id
           AND BOM.CALENDAR_DATE BETWEEN TRUNC(REP.FIRST_UNIT_COMPLETION_DATE)
                 AND TRUNC(REP.LAST_UNIT_COMPLETION_DATE)
           AND BOM.SEQ_NUM IS NOT NULL
           AND REP.organization_id = i_organization_id
           AND BOM.calendar_date BETWEEN i_start_date
                 AND i_end_date+1-(1/86400)
           AND MP.CALENDAR_CODE = BOM.CALENDAR_CODE
           AND MP.CALENDAR_EXCEPTION_SET_ID = BOM.EXCEPTION_SET_ID
           AND MP.ORGANIZATION_ID = REP.ORGANIZATION_ID
        UNION ALL
        SELECT count(distinct(to_char(JOB.scheduled_completion_date))) num_days
          FROM WIP_DISCRETE_JOBS    JOB
         WHERE JOB.organization_id = i_organization_id
           AND JOB.line_id = i_line_id
           AND JOB.scheduled_completion_date BETWEEN i_start_date
                 AND i_end_date+1-(1/86400)
        UNION ALL
        SELECT count(distinct(to_char(flow.scheduled_completion_date))) num_days
          FROM WIP_FLOW_SCHEDULES   FLOW,
	       WIP_LINES            LINE
         WHERE FLOW.LINE_ID = LINE.LINE_ID
           AND FLOW.ORGANIZATION_ID = LINE.ORGANIZATION_ID
           AND FLOW.organization_id = i_organization_id
           AND FLOW.line_id = i_line_id
           AND FLOW.scheduled_completion_date BETWEEN i_start_date
                 AND i_end_date+1-(1/86400)
      );

  -- cursor to retrieve demand days on a line, in case of Sales and Planned Orders
  CURSOR unschedule_days(i_line_id IN NUMBER, i_option IN NUMBER) IS
    SELECT count(distinct(to_char(order_date))) num_days
      FROM mrp_unscheduled_orders_v
     WHERE organization_id = i_organization_id
       AND line_id = i_line_id
       AND trunc(order_date) BETWEEN i_start_date AND i_end_date
       AND unscheduled_order_option = i_option;

  -- cursor to retrieve product_family_item_id for given item_id
  CURSOR product_family(i_inventory_item_id IN NUMBER) IS
    SELECT product_family_item_id
    FROM mtl_system_items_b
    WHERE organization_id = i_organization_id
      AND inventory_item_id = i_inventory_item_id;

BEGIN
  -- retrieve AND calculate average daily demand for each relevant item
  -- put into the demand table and return it
  o_demand.DELETE;

  IF i_demand_type = C_DEMAND_TYPE_FORECAST THEN
    FOR forecast_rec IN forecast_entries LOOP
      OPEN line(forecast_rec.item_id);
      l_line_id := NULL;
      FETCH line INTO l_line_id;
      CLOSE line;

      OPEN product_family(forecast_rec.item_id);
      l_product_family_id := NULL;
      FETCH product_family INTO l_product_family_id;
      CLOSE product_family;

      IF G_DEBUG THEN
        l_info := 'item: '||forecast_rec.item_id||'  line: '||l_line_id ||
                  'product family: '||l_product_family_id;
	print_log(l_info);
      END IF;

      IF l_line_id IS NOT NULL AND
         (l_line_id = i_line_id OR i_line_id IS NULL) AND
         (i_product_family_id IS NULL OR
          l_product_family_id = i_product_family_id) THEN

        BOM_MIXED_MODEL_MAP_PVT.getdemand(
		i_organization_id,
		i_demand_type,
		l_line_id,
		forecast_rec.item_id,
		i_calendar_code,
		i_start_date,
		i_end_date,
    		i_last_calendar_date,
	   	i_exception_set_id,
		i_demand_code,
		l_demand,
		l_dummy);

        IF G_DEBUG THEN
          l_info := 'total demand: '||l_demand;
	  print_log(l_info);
	END IF;

        IF l_demand > 0 THEN
          l_demand := l_demand*(100+nvl(i_boost_percent,0))/100/i_demand_days;

    	  o_demand(forecast_rec.item_id).assembly_item_id := forecast_rec.item_id;
	  o_demand(forecast_rec.item_id).line_id := l_line_id;
	  o_demand(forecast_rec.item_id).average_daily_demand := l_demand;

        END IF;
      END IF;
    END LOOP;

  ELSIF i_demand_type IN (C_DEMAND_TYPE_MDS, C_DEMAND_TYPE_MPS) THEN
    FOR mds_mps_rec IN schedule_entries LOOP
      OPEN line(mds_mps_rec.item_id);
      l_line_id := NULL;
      FETCH line INTO l_line_id;
      CLOSE line;

      OPEN product_family(mds_mps_rec.item_id);
      l_product_family_id := NULL;
      FETCH product_family INTO l_product_family_id;
      CLOSE product_family;

      IF l_line_id IS NOT NULL AND
         (l_line_id = i_line_id OR i_line_id IS NULL) AND
         (l_line_id = mds_mps_rec.line_id OR mds_mps_rec.line_id IS NULL) AND
         (i_product_family_id IS NULL OR
          l_product_family_id = i_product_family_id) THEN
        BOM_MIXED_MODEL_MAP_PVT.getdemand (
		i_organization_id,
		i_demand_type,
		l_line_id,
		mds_mps_rec.item_id,
		i_calendar_code,
		i_start_date,
		i_end_date,
    		i_last_calendar_date,
	   	i_exception_set_id,
		i_demand_code,
		l_demand,
		l_dummy);

        IF l_demand > 0 THEN
	  -- To consider boost percent and demand days while calculating avg daily demand
	  l_demand := l_demand * (100 + nvl(i_boost_percent, 0)) / 100;
	  IF (i_demand_days <> 0) THEN
	    l_demand := l_demand / i_demand_days;
	  END IF;

	  o_demand(mds_mps_rec.item_id).assembly_item_id := mds_mps_rec.item_id;
	  o_demand(mds_mps_rec.item_id).line_id := l_line_id;
	  o_demand(mds_mps_rec.item_id).average_daily_demand := l_demand;

        END IF;
      END IF;
    END LOOP;

  ELSIF i_demand_type = C_DEMAND_TYPE_AP THEN

    FOR ap_rec IN actual_production_entries LOOP
      OPEN line(ap_rec.item_id);
      l_line_id := NULL;
      FETCH line INTO l_line_id;
      CLOSE line;

      OPEN product_family(ap_rec.item_id);
      l_product_family_id := NULL;
      FETCH product_family INTO l_product_family_id;
      CLOSE product_family;

      IF l_line_id IS NOT NULL AND
         (l_line_id = i_line_id OR i_line_id IS NULL) AND
         l_line_id = ap_rec.line_id AND
         (i_product_family_id IS NULL OR
          l_product_family_id = i_product_family_id) THEN
        BOM_MIXED_MODEL_MAP_PVT.getdemand (
		i_organization_id,
		i_demand_type,
		l_line_id,
		ap_rec.item_id,
		i_calendar_code,
		i_start_date,
		i_end_date,
    		i_last_calendar_date,
	   	i_exception_set_id,
		i_demand_code,
		l_demand,
		l_dummy);

        IF l_demand > 0 THEN
          -- To consider boost percent and demand days while calculating avg daily demand
          l_demand := l_demand * (100 + nvl(i_boost_percent, 0)) / 100;

          OPEN schedule_days(l_line_id);
            FETCH schedule_days INTO l_demand_days;
          CLOSE schedule_days;

          IF (l_demand_days <> 0) THEN
            l_demand := l_demand / l_demand_days;
          END IF;

	  o_demand(ap_rec.item_id).assembly_item_id := ap_rec.item_id;
	  o_demand(ap_rec.item_id).line_id := l_line_id;
	  o_demand(ap_rec.item_id).average_daily_demand := l_demand;

        END IF;
      END IF;
    END LOOP;

  ELSIF i_demand_type IN (C_DEMAND_TYPE_SO, C_DEMAND_TYPE_PO) THEN

    IF i_demand_type = C_DEMAND_TYPE_SO THEN
      l_order_option := 1;
      open so_order_entries;
    ELSE
      l_order_option := 2;
      open po_order_entries;
    END IF;

/* convert for to simple loop */
/*    FOR so_po_rec IN order_entries(l_order_option) LOOP */
    loop
      if( l_order_option = 1 ) then
        fetch so_order_entries into so_po_rec;
        exit when so_order_entries%NOTFOUND;
      else
        fetch po_order_entries into so_po_rec;
        exit when po_order_entries%NOTFOUND;
      end if;

      OPEN line(so_po_rec.item_id);
        l_line_id := NULL;
        FETCH line INTO l_line_id;
      CLOSE line;

      OPEN product_family(so_po_rec.item_id);
      l_product_family_id := NULL;
      FETCH product_family INTO l_product_family_id;
      CLOSE product_family;

      IF l_line_id IS NOT NULL AND
         (l_line_id = i_line_id OR i_line_id IS NULL) AND
         l_line_id = so_po_rec.line_id AND
         (i_product_family_id IS NULL OR
          l_product_family_id = i_product_family_id) THEN
        BOM_MIXED_MODEL_MAP_PVT.getdemand (
		i_organization_id,
		i_demand_type,
		l_line_id,
		so_po_rec.item_id,
		i_calendar_code,
		i_start_date,
		i_end_date,
    		i_last_calendar_date,
	   	i_exception_set_id,
		i_demand_code,
		l_demand,
		l_dummy);

	IF l_demand > 0 THEN
	  l_demand := l_demand * (100 + nvl(i_boost_percent, 0)) / 100;

          OPEN unschedule_days(l_line_id, l_order_option);
            FETCH unschedule_days INTO l_demand_days;
          CLOSE unschedule_days;

          IF (l_demand_days <> 0) THEN
            l_demand := l_demand / l_demand_days;
          END IF;

	  o_demand(so_po_rec.item_id).assembly_item_id := so_po_rec.item_id;
	  o_demand(so_po_rec.item_id).line_id := l_line_id;
	  o_demand(so_po_rec.item_id).average_daily_demand := l_demand;

        END IF;
      END IF;
    END LOOP;

    if( l_order_option = 1 ) then
      close so_order_entries;
    else
      close po_order_entries;
    end if;

  END IF; -- demand type

  IF o_demand.COUNT > 0 THEN
    l_dummy := o_demand.first;

    LOOP
      IF G_DEBUG THEN
        l_info := 'item id: '  || o_demand(l_dummy).assembly_item_id ||
                  '  line id: '|| o_demand(l_dummy).line_id          ||
                  '  demand: ' || o_demand(l_dummy).average_daily_demand;
        print_log(l_info);
      -- debug_log(l_info); -- change info col to hold more chars
      END IF;

      EXIT WHEN l_dummy = o_demand.last;
      l_dummy := o_demand.next(l_dummy);

    END LOOP;

  ELSE
    IF G_DEBUG THEN
      print_log('no demand');
    END IF;
  END IF;

/*  o_demand(1).assembly_item_id := 315;  -- MC97160
  o_demand(1).line_id := 201;
  o_demand(1).average_daily_demand := 40;
  o_demand(2).assembly_item_id := 173;  -- MC31749
  o_demand(2).line_id := 202;
  o_demand(2).average_daily_demand := 23;
  o_demand(3).assembly_item_id := 950;  -- MC31750
  o_demand(3).line_id := 202;
  o_demand(3).average_daily_demand := 51;
*/
  IF G_DEBUG THEN
    print_log('calculate retrieve demand');
  END IF;

END calculate_avg_daily_demand;


/************************************************************************
 * PROCEDURE calculate_line_takt					*
 *  	Calculates the Line TAKT for each relevant lines and 		*
 *	saves it in FLM_MMM_LINES.					*
 ************************************************************************/
PROCEDURE calculate_line_takt(
	i_plan_id			IN	NUMBER,
	i_organization_id		IN	NUMBER,
	i_calculation_operation_type	IN	NUMBER,
	i_line_id			IN	NUMBER,
	i_hours_per_day			IN	NUMBER,
	i_replan_flag			IN	VARCHAR2,
	i_demand			IN	t_demand_table) IS

  TYPE t_line_rec IS RECORD (
	line_id		NUMBER,
	hours_per_day	NUMBER,
	total_demand	NUMBER,
	line_takt	NUMBER);

  TYPE t_line_table IS TABLE OF t_line_rec
    INDEX BY BINARY_INTEGER;

  CURSOR all_lines IS
    SELECT line_id,
	   hours_per_day
    FROM flm_mmm_lines
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND calculation_operation_type = i_calculation_operation_type;

  l_index	NUMBER;
  l_lines	t_line_table;
  l_old_lines	t_line_table;

  --fix bug#3773193
  l_start_time  NUMBER;
  l_stop_time NUMBER;
  --end of fix bug#3773193

BEGIN
  -- if replan, record line_hours history for this plan
  -- then clear the historical records
  IF i_replan_flag = C_REPLAN_FLAG_YES THEN
    l_old_lines.DELETE;
    FOR line_rec IN all_lines LOOP
      l_old_lines(line_rec.line_id).line_id := line_rec.line_id;
      l_old_lines(line_rec.line_id).hours_per_day := line_rec.hours_per_day;
    END LOOP;

    DELETE FROM flm_mmm_lines
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND calculation_operation_type = i_calculation_operation_type;

  END IF;

  IF G_DEBUG THEN
    print_log('calculating line takt');
  END IF;

  -- based on demand, calculate line takt for each line
  -- then save into table
  IF i_demand.COUNT > 0 THEN
    l_lines.DELETE;

    IF i_line_id IS NOT NULL THEN
      l_lines(i_line_id).line_id := i_line_id;
      l_lines(i_line_id).total_demand := 0;

      IF i_hours_per_day IS NOT NULL then
        l_lines(i_line_id).hours_per_day := i_hours_per_day;

      ELSE
        --fix bug#3773193

        SELECT start_time, stop_time
        INTO l_start_time, l_stop_time
        FROM wip_lines
      	WHERE line_id = i_line_id
	        AND organization_id = i_organization_id;

        IF (l_stop_time <= l_start_time) THEN
          l_stop_time := l_stop_time + 24*3600;
        END IF;

        l_lines(i_line_id).hours_per_day := (l_stop_time-l_start_time)/3600;
        --end of fix bug#3773193

      END IF;
    END IF;

    l_index := i_demand.first;
    -- sum up demands
    LOOP
      IF l_lines.exists(i_demand(l_index).line_id) THEN
        l_lines(i_demand(l_index).line_id).total_demand :=
          i_demand(l_index).average_daily_demand
          + l_lines(i_demand(l_index).line_id).total_demand;

      ELSE
        l_lines(i_demand(l_index).line_id).line_id :=
          i_demand(l_index).line_id;
        l_lines(i_demand(l_index).line_id).total_demand :=
          i_demand(l_index).average_daily_demand;

        --fix bug#3773193

        SELECT start_time, stop_time
        INTO l_start_time, l_stop_time
        FROM wip_lines
      	WHERE line_id = i_demand(l_index).line_id
	        AND organization_id = i_organization_id;

        IF (l_stop_time <= l_start_time) THEN
          l_stop_time := l_stop_time + 24*3600;
        END IF;

        l_lines(i_demand(l_index).line_id).hours_per_day :=
          (l_stop_time-l_start_time)/3600;
        --end of fix bug#3773193

      END IF;

      EXIT WHEN l_index = i_demand.last;
      l_index := i_demand.next(l_index);

    END LOOP;

    -- adjust hours per day if replan
    IF i_replan_flag = C_REPLAN_FLAG_YES THEN
      l_index := l_lines.FIRST;

      LOOP
        IF l_old_lines.EXISTS(l_index) THEN
          l_lines(l_index).hours_per_day := l_old_lines(l_index).hours_per_day;
        END IF;

        EXIT WHEN l_index = l_lines.LAST;
        l_index := l_lines.NEXT(l_index);

      END LOOP;
    END IF;

    -- calculate line_takt
    l_index := l_lines.first;
    LOOP l_lines(l_index).line_takt :=
      l_lines(l_index).hours_per_day/l_lines(l_index).total_demand;

      INSERT INTO flm_mmm_lines (
		plan_id,
		organization_id,
		line_id,
		calculation_operation_type,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		line_takt,
		hours_per_day
      ) VALUES (
		i_plan_id,
		i_organization_id,
		l_lines(l_index).line_id,
		i_calculation_operation_type,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		l_lines(l_index).line_takt,
		l_lines(l_index).hours_per_day
      );

      EXIT WHEN l_index = l_lines.last;
      l_index := l_lines.next(l_index);

    END LOOP;
  END IF;  -- demand count > 0

  IF G_DEBUG THEN
    print_log('calculate line takt ends');
  END IF;

END calculate_line_takt;


/************************************************************************
 * PROCEDURE calculate_process_volume					*
 *  	Calculates the process volume for each item			*
 *	sat each line operation/process of each line.			*
 ************************************************************************/
PROCEDURE calculate_process_volume(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER,
	i_demand		IN	t_demand_table) IS

  CURSOR op_seqs(i_assembly_item_id	NUMBER) IS
    SELECT bos.standard_operation_id standard_operation_id,
	   nvl(bos.net_planning_percent, 100) net_planning_percent,
	   nvl(bos.reverse_cumulative_yield, 1) reverse_cumulative_yield,
	   bos.operation_type operation_type,
	   bos.machine_time_calc machine_time,
	   bos.labor_time_calc labor_time,
	   bos.total_time_calc elapsed_time,
	   bor.line_id line_id
    FROM bom_operational_routings bor,
	 bom_operation_sequences bos
    WHERE bor.assembly_item_id = i_assembly_item_id
      AND bor.organization_id = i_organization_id
      AND bor.cfm_routing_flag = 1
      AND bor.mixed_model_map_flag = 1
      AND bor.common_routing_sequence_id = bos.routing_sequence_id
      AND bos.operation_type = i_calc_op_type
    ORDER BY bos.standard_operation_id;

  l_npp		NUMBER;
  l_rcy		NUMBER;
  l_index	NUMBER;

BEGIN
  IF G_DEBUG THEN
    print_log('calculating process volume');
    print_log(i_demand.count);
  END IF;
  -- based on demand AND routing info, calculate process volume for each
  -- item at line operation/process of each line.
  -- then save into table
  IF i_demand.COUNT > 0 THEN
    l_index := i_demand.first;

    LOOP

      FOR op_seq_rec in op_seqs(i_demand(l_index).assembly_item_id) LOOP
        IF G_DEBUG THEN
          print_log('npp: '||op_seq_rec.net_planning_percent);
          print_log('rcv: '||op_seq_rec.reverse_cumulative_yield);
          print_log('demand: '||i_demand(l_index).average_daily_demand);
	END IF;

        l_npp := op_seq_rec.net_planning_percent;
        l_rcy := op_seq_rec.reverse_cumulative_yield;

        IF l_npp = 0 THEN
          l_npp := 100;
        END IF;

        IF l_rcy = 0 THEN
          l_rcy := 1;
        END IF;

        IF G_DEBUG THEN
          print_log('l_npp:'||l_npp);
          print_log('l_rcy:'||l_rcy);

          print_log('parameter:' ||':'||
 	        i_plan_id || ':'||
		i_organization_id || ':'||
		i_demand(l_index).assembly_item_id || ':'||
		op_seq_rec.line_id || ':'||
		op_seq_rec.operation_type || ':'||
		op_seq_rec.standard_operation_id || ':'||
		fnd_global.user_id || ':'||
		sysdate || ':'||
		fnd_global.user_id || ':'||
		sysdate || ':'||
		i_demand(l_index).average_daily_demand
			* l_npp / 100
			/ l_rcy || ':'||
		op_seq_rec.machine_time || ':'||
		op_seq_rec.labor_time || ':'||
		op_seq_rec.elapsed_time
                );
	END IF;

        INSERT INTO flm_mmm_op_items (
		plan_id,
		organization_id,
		assembly_item_id,
		line_id,
		operation_type,
		standard_operation_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		process_volume,
		machine_time,
		labor_time,
		elapsed_time
	) VALUES (
		i_plan_id,
		i_organization_id,
		i_demand(l_index).assembly_item_id,
		op_seq_rec.line_id,
		op_seq_rec.operation_type,
		op_seq_rec.standard_operation_id,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		i_demand(l_index).average_daily_demand
			* l_npp / 100
			/ l_rcy,
		op_seq_rec.machine_time,
		op_seq_rec.labor_time,
		op_seq_rec.elapsed_time
	);

      END LOOP;

      EXIT WHEN l_index = i_demand.last;
      l_index := i_demand.next(l_index);

    END LOOP;
  END IF;  -- demand count > 0

IF G_DEBUG THEN
  print_log('********calculate process volume ends');
END IF;

END calculate_process_volume;


/************************************************************************
 * PROCEDURE calculate_operation_takt					*
 *  	Calculates operation takt for each line operation/process at	*
 *	each line, based on the process volume.				*
 ************************************************************************/
PROCEDURE calculate_operation_takt(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER,
	i_hours_per_day		IN	NUMBER,
	i_replan_flag		IN	VARCHAR2) IS

  -- local type
  TYPE tl_ipk_rec IS RECORD (
	standard_operation_id	NUMBER,
	ipk_assigned		NUMBER);
  TYPE tl_ipk_tbl IS TABLE OF tl_ipk_rec
    INDEX BY BINARY_INTEGER;

  CURSOR op_takt IS
    SELECT it.standard_operation_id,
	   it.line_id,
	   it.operation_type,
	   nvl(line.hours_per_day,1)/
             nvl(sum(it.process_volume), 1) operation_takt
    FROM flm_mmm_lines line,
	 flm_mmm_op_items it
    WHERE line.plan_id = i_plan_id
      AND line.organization_id = i_organization_id
      AND line.calculation_operation_type = it.operation_type --bug 5725595
      AND it.plan_id = i_plan_id
      AND it.organization_id = i_organization_id
      AND it.line_id = line.line_id
      AND it.operation_type = i_calc_op_type
    GROUP BY it.standard_operation_id, it.line_id,
	     it.operation_type, line.hours_per_day;

  CURSOR all_ipks IS
    SELECT standard_operation_id op_id,
	   ipk_assigned
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  l_ipks	tl_ipk_tbl;
  l_ipk_assigned	NUMBER;

BEGIN
  -- if replan, record ipk assigned history for this plan
  -- then clear the historical records
  IF i_replan_flag = C_REPLAN_FLAG_YES THEN
    l_ipks.DELETE;

    FOR ipk_rec IN all_ipks LOOP
      l_ipks(ipk_rec.op_id).standard_operation_id := ipk_rec.op_id;
      l_ipks(ipk_rec.op_id).ipk_assigned := ipk_rec.ipk_assigned;
    END LOOP;

    DELETE FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  END IF;

  -- based on process volume, calculate operation takt
  -- then save into table
  IF G_DEBUG THEN
    print_log('calculating operation takt');
  END IF;

  FOR op_takt_rec IN op_takt LOOP
    IF l_ipks.EXISTS(op_takt_rec.standard_operation_id) THEN
      l_ipk_assigned := l_ipks(op_takt_rec.standard_operation_id).ipk_assigned;

    ELSE
      BEGIN
        SELECT ipk_assigned
        INTO l_ipk_assigned
        FROM flm_mmm_operations
        WHERE plan_id = -1
          AND organization_id = i_organization_id
          AND standard_operation_id = op_takt_rec.standard_operation_id;

      EXCEPTION
        WHEN OTHERS THEN
          l_ipk_assigned := NULL;

      END;

    END IF;

    INSERT INTO flm_mmm_operations (
	plan_id,
	organization_id,
	standard_operation_id,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	line_id,
	operation_type,
	operation_takt,
	ipk_assigned
    ) VALUES (
	i_plan_id,
	i_organization_id,
	op_takt_rec.standard_operation_id,
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	sysdate,
	op_takt_rec.line_id,
	op_takt_rec.operation_type,
	op_takt_rec.operation_takt,
	nvl(l_ipk_assigned, 0)		-- set to 0 if not defined
    );

  END LOOP;

  IF G_DEBUG THEN
    print_log('calculate operation takt ends');
  END IF;

END calculate_operation_takt;


/************************************************************************
 * PROCEDURE calculate_weighted_times					*
 *  	Calculates weighted times for each line operation/process	*
 *	at each line, based on the process volume and item routings.	*
 ************************************************************************/
PROCEDURE calculate_weighted_times(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER) IS

  l_machine_wt	NUMBER;
  l_labor_wt	NUMBER;
  l_elapsed_wt	NUMBER;

  CURSOR operations IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

BEGIN
  -- based on process volume and routing info, calculate weighted times
  -- then save into table
  FOR op_rec IN operations LOOP
    -- calculate
    SELECT sum(machine_time*process_volume) / sum(process_volume)
		machine_weighted_time,
	   sum(labor_time*process_volume) / sum(process_volume)
		labor_weighted_time,
	   sum(elapsed_time*process_volume) / sum(process_volume)
		elapsed_weighted_time
    INTO l_machine_wt,
	 l_labor_wt,
	 l_elapsed_wt
    FROM flm_mmm_op_items
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = op_rec.standard_operation_id
    GROUP BY standard_operation_id;

    -- update operation records
    UPDATE flm_mmm_operations
    SET machine_weighted_time = l_machine_wt,
	labor_weighted_time = l_labor_wt,
	elapsed_weighted_time = l_elapsed_wt
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = op_rec.standard_operation_id;

  END LOOP;

  IF G_DEBUG THEN
    print_log('calculate weighted times ends');
  END IF;

END calculate_weighted_times;


/************************************************************************
 * PROCEDURE calculate_weighted_res_usage				*
 *  	Calculates weighted resource usage for each resource at each	*
 *	line operation/process of each line.				*
 ************************************************************************/
PROCEDURE calculate_weighted_res_usage (
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER,
	i_replan_flag		IN	VARCHAR2) IS

  -- local types
  TYPE tl_res_rec IS RECORD(
	resource_id		NUMBER,
	standard_operation_id	NUMBER,
	resource_assigned	NUMBER);
  TYPE tl_res_tbl IS TABLE OF tl_res_rec
    INDEX BY BINARY_INTEGER;

  l_hour_uom	VARCHAR2(3);
  l_hour_conv	NUMBER;

  CURSOR operations IS
    SELECT fmo.standard_operation_id,
	   fmo.operation_type,
	   fmo.line_id,
	   fmo.operation_takt,
	   fml.hours_per_day
    FROM flm_mmm_operations fmo,
	 flm_mmm_lines fml
    WHERE fmo.plan_id = i_plan_id
      AND fmo.organization_id = i_organization_id
      AND fmo.operation_type = i_calc_op_type
      AND fml.plan_id = i_plan_id
      AND fml.organization_id = i_organization_id
      AND fml.calculation_operation_type = i_calc_op_type
      AND fml.line_id = fmo.line_id;

  CURSOR resources(i_standard_operation_id NUMBER) IS
    SELECT bor.resource_id,
	   it.assembly_item_id,
	   it.process_volume,
	   sum(bor.usage_rate_or_amount * nvl(muc.conversion_rate, 0) /
               nvl(l_hour_conv, 1)) resource_usage
    FROM flm_mmm_operations op,
	 flm_mmm_op_items it,
	 bom_operational_routings brtg,
	 bom_operation_sequences bos1,
	 bom_operation_sequences bos2,
	 bom_operation_resources bor,
	 bom_resources br,
	 mtl_uom_conversions muc
    WHERE op.plan_id = i_plan_id
      AND op.organization_id = i_organization_id
      AND op.standard_operation_id = i_standard_operation_id
      AND it.plan_id = i_plan_id
      AND it.organization_id = i_organization_id
      AND it.standard_operation_id = op.standard_operation_id
      AND brtg.organization_id = i_organization_id
      AND brtg.assembly_item_id = it.assembly_item_id
      AND brtg.mixed_model_map_flag = 1
      AND brtg.common_routing_sequence_id = bos1.routing_sequence_id
      AND brtg.common_routing_sequence_id = bos2.routing_sequence_id
      AND bos1.standard_operation_id = it.standard_operation_id
      AND ((    bos1.operation_type = 3
	        AND bos2.line_op_seq_id = bos1.operation_sequence_id) or
	   (    bos1.operation_type = 2
	        AND bos2.process_op_seq_id = bos1.operation_sequence_id))
      AND bos2.operation_sequence_id = bor.operation_sequence_id
      AND br.resource_id = bor.resource_id
      AND muc.uom_code(+) = br.unit_of_measure
      AND muc.inventory_item_id(+) = 0
    GROUP BY bor.resource_id, it.assembly_item_id, it.process_volume
    ORDER BY bor.resource_id;

  CURSOR all_res_assigned IS
    SELECT resource_id,
	   standard_operation_id op_id,
	   resource_assigned
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  l_total_pv	NUMBER;
  l_total_rs	NUMBER;
  l_res_id	NUMBER;

  i			NUMBER;
  l_resources		tl_res_tbl;
  l_resource_assigned	NUMBER;

BEGIN
  -- if replan, record resource assigned history for this plan
  -- then clear the historical records
  IF i_replan_flag = C_REPLAN_FLAG_YES THEN
    l_resources.DELETE;
    i := 0;
    FOR res_rec IN all_res_assigned LOOP
      l_resources(i).resource_id := res_rec.resource_id;
      l_resources(i).standard_operation_id := res_rec.op_id;
      l_resources(i).resource_assigned := nvl(res_rec.resource_assigned, 0);
      i := i+1;
    END LOOP;

    DELETE FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  END IF;

  -- based on process volume AND routing info, calculate weighted
  -- resource usage
  -- then save into table
  -- Hourly UOM and Conversion Rate
  l_hour_uom := FND_PROFILE.VALUE('BOM:HOUR_UOM_CODE');
  BEGIN
    SELECT nvl(conversion_rate, 0)
    INTO   l_hour_conv
    FROM   mtl_uom_conversions
    WHERE  uom_code = l_hour_uom
    AND    inventory_item_id = 0;

  EXCEPTION
    WHEN OTHERS THEN
      l_hour_conv := 1;

  END;

  FOR op_rec IN operations LOOP
    IF op_rec.operation_takt > 0 THEN
      l_total_pv := op_rec.hours_per_day / op_rec.operation_takt;
    ELSE
      l_total_pv := 0;
    END IF;

    l_total_rs := 0;
    l_res_id := null;
    FOR rs_rec IN resources(op_rec.standard_operation_id) LOOP
      IF G_DEBUG THEN
        print_log('op: '||op_rec.standard_operation_id||'   res: '||
        		rs_rec.resource_id||'  item: '||rs_rec.assembly_item_id);
      END IF;

      IF l_res_id IS NULL THEN
        l_res_id := rs_rec.resource_id;
        l_total_rs := rs_rec.process_volume * rs_rec.resource_usage;

      ELSIF l_res_id = rs_rec.resource_id THEN
        l_total_rs := l_total_rs + rs_rec.process_volume *
			rs_rec.resource_usage;

      ELSE
        IF l_total_pv > 0 AND
           l_total_rs > 0 THEN
	  BEGIN
	    SELECT resource_assigned
	    INTO l_resource_assigned
	    FROM flm_mmm_op_resources
	    WHERE plan_id = -1
	      AND organization_id = i_organization_id
	      AND standard_operation_id = op_rec.standard_operation_id
	      AND resource_id = l_res_id;

	  EXCEPTION
 	    WHEN OTHERS THEN
	      l_resource_assigned := NULL;

	  END;

          INSERT INTO flm_mmm_op_resources (
		plan_id,
		organization_id,
		resource_id,
		standard_operation_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		line_id,
		operation_type,
		weighted_resource_usage,
		resource_assigned
	    ) VALUES (
		i_plan_id,
		i_organization_id,
		l_res_id,
		op_rec.standard_operation_id,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		op_rec.line_id,
		op_rec.operation_type,
		l_total_rs / l_total_pv,
		nvl(l_resource_assigned, 0)
	    );

        END IF;

        l_res_id := rs_rec.resource_id;
        l_total_rs := rs_rec.process_volume * rs_rec.resource_usage;

      END IF;

    END LOOP;

    -- last one
    IF l_res_id IS NOT NULL AND
       l_total_pv > 0 AND l_total_rs > 0 THEN
	  BEGIN
	    SELECT resource_assigned
	    INTO l_resource_assigned
	    FROM flm_mmm_op_resources
	    WHERE plan_id = -1
	      AND organization_id = i_organization_id
	      AND standard_operation_id = op_rec.standard_operation_id
	      AND resource_id = l_res_id;

	  EXCEPTION
 	    WHEN OTHERS THEN
	      l_resource_assigned := NULL;

	  END;

          INSERT INTO flm_mmm_op_resources (
		plan_id,
		organization_id,
		resource_id,
		standard_operation_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		line_id,
		operation_type,
		weighted_resource_usage,
		resource_assigned
	    ) VALUES (
		i_plan_id,
		i_organization_id,
		l_res_id,
		op_rec.standard_operation_id,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		op_rec.line_id,
		op_rec.operation_type,
		l_total_rs / l_total_pv,
		nvl(l_resource_assigned, 0)
	    );

    END IF;

  END LOOP;

  -- if replan, overwrite the resource assigned information with
  -- the historical data for this plan
  IF i_replan_flag = C_REPLAN_FLAG_YES AND
     l_resources.COUNT > 0 THEN
    i := 0;
    LOOP
      UPDATE flm_mmm_op_resources
      SET resource_assigned = l_resources(i).resource_assigned
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND resource_id = l_resources(i).resource_id
        AND standard_operation_id = l_resources(i).standard_operation_id;

      EXIT WHEN i = l_resources.LAST;
      i := l_resources.NEXT(i);

    END LOOP;

  END IF;

  IF G_DEBUG THEN
    print_log('calculate weighted resource usage ends');
  END IF;

END calculate_weighted_res_usage;


/************************************************************************
 * PROCEDURE calculate_res_ipk_needed					*
 *  	Calculates Resources/IPK Needed for each resource and operation.*
 ************************************************************************/
PROCEDURE calculate_res_ipk_needed(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER,
	i_calculate_option	IN	NUMBER) IS

  CURSOR resources IS
    SELECT resource_id,
	   standard_operation_id,
	   weighted_resource_usage,
	   resource_assigned
    FROM flm_mmm_op_resources fmor
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  CURSOR operations IS
    SELECT fmo.standard_operation_id,
	   fmo.operation_takt,
	   fmo.ipk_assigned,
	   fml.hours_per_day
    FROM flm_mmm_operations fmo,
	 flm_mmm_lines fml
    WHERE fmo.plan_id = i_plan_id
      AND fmo.organization_id = i_organization_id
      AND fml.plan_id = i_plan_id
      AND fml.organization_id = i_organization_id
      AND fmo.line_id = fml.line_id
      AND fmo.operation_type = i_calc_op_type
      AND fml.calculation_operation_type = fmo.operation_type;

  l_max_rs_usage	NUMBER;
  l_ipk_needed		NUMBER;

  l_count	NUMBER;

BEGIN
  -- based on weighted resource usage, ipk/resource assigned, AND
  -- calculate option, calculate resource/ipk needed.
  -- then save into table
  --
  -- branch on calculate option
  --
  IF i_calculate_option = C_CALC_OPTION_NO_IPK THEN
    -- Resource Needed = Weighted Resource Usage / Operation TAKT
    FOR op_rec IN operations LOOP
      IF op_rec.operation_takt > 0 THEN  -- otherwise, sth must be wrong with the op, leave it null
        UPDATE flm_mmm_op_resources
        SET resource_needed = weighted_resource_usage / op_rec.operation_takt
        WHERE plan_id = i_plan_id
	  AND organization_id = i_organization_id
	  AND standard_operation_id = op_rec.standard_operation_id;

      END IF;

    END LOOP;

    -- IPK Needed = 0;
    UPDATE flm_mmm_operations
    SET ipk_needed = 0
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  ELSIF i_calculate_option = C_CALC_OPTION_ONE_RESOURCE THEN
    -- Resource Needed = 1
    UPDATE flm_mmm_op_resources fmor
    SET resource_needed = 1
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

    -- IPK Needed = ( MAX(Weighted Resource Usage) - Operation TAKT ) /
    --              MAX(Weighted Resource Usage) *
    --		    HOURS PER DAY /
    --		    Operation TAKT
    FOR op_rec IN operations LOOP
      IF op_rec.operation_takt > 0 AND op_rec.hours_per_day > 0 THEN
        -- Max Weigthed Resource Usage
        SELECT max(nvl(weighted_resource_usage,0))
        INTO l_max_rs_usage
        FROM flm_mmm_op_resources
        WHERE plan_id = i_plan_id
          AND organization_id = i_organization_id
          AND standard_operation_id = op_rec.standard_operation_id;

        -- Update FLM_MMM_OPERATIONS
        IF l_max_rs_usage > 0 THEN
          UPDATE flm_mmm_operations
          SET ipk_needed =
	 	ceil((l_max_rs_usage - op_rec.operation_takt)/l_max_rs_usage *
		     op_rec.hours_per_day / op_rec.operation_takt)
          WHERE plan_id = i_plan_id
            AND organization_id = i_organization_id
            AND standard_operation_id = op_rec.standard_operation_id;

	ELSE  -- No Resource Usage, set IPK = 0
          UPDATE flm_mmm_operations
          SET ipk_needed = 0
          WHERE plan_id = i_plan_id
            AND organization_id = i_organization_id
            AND standard_operation_id = op_rec.standard_operation_id;

        END IF;

      END IF; -- operation_takt > 0 AND op_rec.hours_per_day

    END LOOP;

    UPDATE flm_mmm_operations
    SET ipk_needed = 0
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND ipk_needed < 0;

  ELSIF i_calculate_option = C_CALC_OPTION_RES_ASSIGNED THEN
    -- IPK Needed = ( MAX(Weighted Resource Usage / Resource Assigned) -
    --		      Operation TAKT ) /
    --              MAX(Weighted Resource Usage / Resource Assigned) *
    --		    HOURS PER DAY /
    --		    Operation TAKT
    FOR op_rec IN operations LOOP
      -- if any required resource is not assigned, we can not perform the calculation here
      SELECT count(*)
      INTO l_count
      FROM flm_mmm_op_resources
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = op_rec.standard_operation_id
	AND (resource_assigned IS NULL OR
             resource_assigned = 0);

      IF l_count = 0 AND op_rec.operation_takt > 0 AND
         op_rec.hours_per_day > 0 THEN -- no unassigned resource

        -- Max ( Weigthed Resource Usage / Resource Assigned )
        SELECT max(weighted_resource_usage / nvl(resource_assigned, 0)) -- ???
        INTO l_max_rs_usage
        FROM flm_mmm_op_resources
        WHERE plan_id = i_plan_id
          AND organization_id = i_organization_id
          AND standard_operation_id = op_rec.standard_operation_id;

        -- Update FLM_MMM_OPERATIONS, Set IPK Needed
        l_ipk_needed := ceil((l_max_rs_usage - op_rec.operation_takt) /
		             l_max_rs_usage * op_rec.hours_per_day /
		             op_rec.operation_takt);

        IF l_ipk_needed < 0 OR l_ipk_needed IS NULL THEN
          l_ipk_needed := 0;
        END IF;

        UPDATE flm_mmm_operations
        SET ipk_needed = l_ipk_needed
        WHERE plan_id = i_plan_id
          AND organization_id = i_organization_id
          AND standard_operation_id = op_rec.standard_operation_id;

        -- Resource Needed = ( Hours Per Day/Operation TAKT - IPK Needed) *
        --		     Weighted Resource Usage / Hours Per Day
        UPDATE flm_mmm_op_resources
        SET resource_needed =
		(op_rec.hours_per_day/op_rec.operation_takt - l_ipk_needed) *
		weighted_resource_usage / op_rec.hours_per_day
        WHERE plan_id = i_plan_id
          AND organization_id = i_organization_id
          AND standard_operation_id = op_rec.standard_operation_id;

      END IF; -- l_count = 0 ...

    END LOOP;

  ELSIF i_calculate_option = C_CALC_OPTION_IPK_ASSIGNED THEN
    FOR op_rec IN operations LOOP
      IF op_rec.hours_per_day > 0 THEN
        -- Resource Needed = ( Hours Per Day/Operation TAKT - IPK Assigned) *
        --		     Weighted Resource Usage / Hours Per Day
        UPDATE flm_mmm_op_resources
        SET resource_needed =
	  	 (op_rec.hours_per_day/op_rec.operation_takt - nvl(op_rec.ipk_assigned, 0)) *
		 weighted_resource_usage / op_rec.hours_per_day
        WHERE plan_id = i_plan_id
          AND organization_id = i_organization_id
          AND standard_operation_id = op_rec.standard_operation_id;

        UPDATE flm_mmm_op_resources
        SET resource_needed = 0
        WHERE plan_id = i_plan_id
          AND organization_id = i_organization_id
          AND standard_operation_id = op_rec.standard_operation_id
          AND resource_needed < 0;

      END IF;

    END LOOP;

    -- IPK Needed = IPK Assigned
    UPDATE flm_mmm_operations
    SET ipk_needed = ipk_assigned
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  ELSE

    IF G_DEBUG THEN
      print_log('Invalid Calculate Option!!!');
    END IF;

  END IF;

  IF G_DEBUG THEN
    print_log('calculate resource/ipk needed');
  END IF;

END calculate_res_ipk_needed;


/************************************************************************
 * PROCEDURE calculate_needed_by_op					*
 *  	Calculates Resources/IPK Needed for the given			*
 *	operation and related resources.				*
 ************************************************************************/
PROCEDURE calculate_needed_by_op(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_standard_operation_id	IN	NUMBER,
	i_calculate_option	IN	NUMBER) IS

  CURSOR resources IS
    SELECT resource_id,
	   standard_operation_id,
	   weighted_resource_usage,
	   resource_assigned
    FROM flm_mmm_op_resources fmor
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = i_standard_operation_id;

  CURSOR op_parameter IS
    SELECT fmo.operation_takt,
	   fmo.ipk_assigned,
	   fml.hours_per_day
    FROM flm_mmm_operations fmo,
	 flm_mmm_lines fml
    WHERE fmo.plan_id = i_plan_id
      AND fmo.organization_id = i_organization_id
      AND fmo.standard_operation_id = i_standard_operation_id
      AND fml.plan_id = i_plan_id
      AND fml.organization_id = i_organization_id
      AND fml.calculation_operation_type = fmo.operation_type
      AND fml.line_id = fmo.line_id;

  l_max_rs_usage	NUMBER;
  l_ipk_needed		NUMBER;
  l_ipk_assigned	NUMBER;
  l_hours_per_day	NUMBER;
  l_operation_takt	NUMBER;
  l_count		NUMBER;

BEGIN
  -- based on weighted resource usage, ipk/resource assigned, AND
  -- calculate option, calculate resource/ipk needed.
  -- then save into table
  -- unlike procedure 'calculate_res_ipk_needed', in this procedure
  -- calculation is done only for the specified operation
  --
  OPEN op_parameter;
  FETCH op_parameter INTO l_operation_takt, l_ipk_assigned, l_hours_per_day;

  IF op_parameter%NOTFOUND THEN
    CLOSE op_parameter;
    RETURN;
  END IF;

  CLOSE op_parameter;

  --
  -- branch on calculate option
  --
  IF i_calculate_option IN (C_CALC_OPTION_ONE_RESOURCE, C_CALC_OPTION_RES_ASSIGNED) THEN
    -- IPK Needed = ( MAX(Weighted Resource Usage / Resource Assigned) -
    --		      Operation TAKT ) /
    --              MAX(Weighted Resource Usage / Resource Assigned) *
    --		    HOURS PER DAY /
    --		    Operation TAKT
    -- if any required resource is not assigned, then we can not perform
    -- the calculation here
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = i_standard_operation_id
      AND (resource_assigned IS NULL OR
          resource_assigned = 0);

    IF l_count = 0 AND l_operation_takt > 0 AND
       l_hours_per_day > 0 THEN -- no unassigned resource
      -- Max ( Weigthed Resource Usage / Resource Assigned )
      SELECT max(weighted_resource_usage / resource_assigned)
      INTO l_max_rs_usage
      FROM flm_mmm_op_resources
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = i_standard_operation_id;

      -- Update FLM_MMM_OPERATIONS, Set IPK Needed
      l_ipk_needed := ceil((l_max_rs_usage - l_operation_takt) /
		             l_max_rs_usage * l_hours_per_day /
		             l_operation_takt);
      IF G_DEBUG THEN
        print_log('ipk needed: '||l_ipk_needed);
      END IF;

      IF l_ipk_needed < 0 OR l_ipk_needed IS NULL THEN
        l_ipk_needed := 0;
      END IF;

      UPDATE flm_mmm_operations
      SET ipk_needed = l_ipk_needed
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = i_standard_operation_id;

      -- Resource Needed = ( Hours Per Day/Operation TAKT - IPK Needed) *
      --		     Weighted Resource Usage / Hours Per Day
      UPDATE flm_mmm_op_resources
      SET resource_needed =
		(l_hours_per_day/l_operation_takt - l_ipk_needed) *
		weighted_resource_usage / l_hours_per_day
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = i_standard_operation_id;

      UPDATE flm_mmm_op_resources
      SET resource_needed = 0
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = i_standard_operation_id
        AND resource_needed < 0;

    END IF; -- l_count = 0 ...

  ELSIF i_calculate_option IN (C_CALC_OPTION_NO_IPK, C_CALC_OPTION_IPK_ASSIGNED) THEN
    IF l_hours_per_day > 0 THEN
      -- Resource Needed = ( Hours Per Day/Operation TAKT - IPK Assigned) *
      --		     Weighted Resource Usage / Hours Per Day
      --debug_log('op takt: '||l_operation_takt);
      --debug_log('ipk assigned: '||l_ipk_assigned);
      UPDATE flm_mmm_op_resources
      SET resource_needed =
	  (l_hours_per_day/l_operation_takt - nvl(l_ipk_assigned, 0)) *
	  weighted_resource_usage / l_hours_per_day
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = i_standard_operation_id;

      UPDATE flm_mmm_op_resources
      SET resource_needed = 0
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = i_standard_operation_id
        AND resource_needed < 0;

    END IF;

    -- IPK Needed = IPK Assigned
    UPDATE flm_mmm_operations
    SET ipk_needed = ipk_assigned
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = i_standard_operation_id;

  ELSE
    IF G_DEBUG THEN
      print_log('Invalid Calculate Option!!!');
    END IF;

  END IF;

END calculate_needed_by_op;


/************************************************************************
 * PROCEDURE calculate_takt_assigned					*
 *  	Calculates the operation and line takt as in accordance		*
 *	with the assigned resources.					*
 ************************************************************************/
PROCEDURE calculate_takt_assigned(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER) IS

  l_takt_assigned	NUMBER;

  l_count	NUMBER;

  CURSOR lines IS
    SELECT line_id
    FROM flm_mmm_lines
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND calculation_operation_type = i_calc_op_type;

  CURSOR operations IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  CURSOR op_takt_assigned(i_operation_id NUMBER) IS
    SELECT max(weighted_resource_usage/resource_assigned) takt_assigned
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = i_operation_id
      AND resource_assigned > 0;

  CURSOR line_takt_assigned(i_line_id NUMBER) IS
    SELECT max(op_takt_as_assigned/operation_takt) max_ratio
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = i_line_id
      AND operation_type = i_calc_op_type
      AND operation_takt > 0;

BEGIN
  -- Operation TAKT As Assigned
  FOR op_rec IN operations LOOP -- For each operation
    -- Infinite Over Limit?
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = op_rec.standard_operation_id
      AND weighted_resource_usage > 0
      AND (resource_assigned = 0 or resource_assigned IS NULL);

    IF l_count <= 0 THEN
      OPEN op_takt_assigned(op_rec.standard_operation_id);
      FETCH op_takt_assigned INTO l_takt_assigned;
      CLOSE op_takt_assigned;

      IF l_takt_assigned IS NULL THEN  -- No Resource Required?
        l_takt_assigned := 0;
      END IF;

      UPDATE flm_mmm_operations
      SET op_takt_as_assigned = l_takt_assigned,
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = op_rec.standard_operation_id;

    ELSE
      UPDATE flm_mmm_operations
      SET op_takt_as_assigned = NULL,
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = op_rec.standard_operation_id;

    END IF;

  END LOOP; -- op_rec

  -- Line TAKT As Assigned
  FOR line_rec IN lines LOOP -- Each Line
    -- Unknown Operation TAKT?
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND line_id = line_rec.line_id
      AND op_takt_as_assigned IS NULL;

    IF l_count <= 0 THEN
      OPEN line_takt_assigned(line_rec.line_id);
      FETCH line_takt_assigned INTO l_takt_assigned;
      CLOSE line_takt_assigned;

      IF l_takt_assigned IS NULL THEN  -- No Operation?
        l_takt_assigned := 0;
      END IF;

      UPDATE flm_mmm_lines
      SET line_takt_as_assigned = l_takt_assigned * line_takt,
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND line_id = line_rec.line_id
        AND calculation_operation_type = i_calc_op_type;

    ELSE

      UPDATE flm_mmm_lines
      SET line_takt_as_assigned = NULL,
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND line_id = line_rec.line_id
        AND calculation_operation_type = i_calc_op_type;

    END IF;
  END LOOP; -- line_rec
END calculate_takt_assigned;


/************************************************************************
 * PROCEDURE calculate_res_ipk_overcapacity				*
 *  	Calculates the overcapacity percentage for resources and IPKs	*
 *	for each line and line operation/process.			*
 ************************************************************************/
PROCEDURE calculate_res_ipk_overcapacity(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER) IS

  l_res_over_pct	NUMBER;
  l_ipk_over_pct	NUMBER;

  l_count		NUMBER;

  CURSOR lines IS
    SELECT line_id
    FROM flm_mmm_lines
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND calculation_operation_type = i_calc_op_type;

  CURSOR operations IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  CURSOR res_overcapacity_op(i_operation_id NUMBER) IS
    SELECT
      max(100*(resource_needed-resource_assigned)/resource_assigned) over_pct
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = i_operation_id
      AND resource_assigned > 0;

  CURSOR res_overcapacity_ln(i_line_id NUMBER) IS
    SELECT max(bottleneck_resource_percent) over_pct
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = i_line_id
      AND operation_type = i_calc_op_type;

  CURSOR ipk_overcapacity(i_line_id NUMBER) IS
    SELECT max(100*(ipk_needed-ipk_assigned)/ipk_assigned) over_pct
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = i_line_id
      AND operation_type = i_calc_op_type
      AND ipk_assigned > 0;

BEGIN
  -- Resource Overcapacity For Operations
  FOR op_rec IN operations LOOP -- For each operation
    -- Infinite Over Capacity?
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = op_rec.standard_operation_id
      AND (resource_needed > 0 or resource_needed is null)
      AND resource_assigned = 0;

    IF l_count <= 0 THEN
      OPEN res_overcapacity_op(op_rec.standard_operation_id);
      FETCH res_overcapacity_op INTO l_res_over_pct;
      CLOSE res_overcapacity_op;

      IF l_res_over_pct < 0 OR l_res_over_pct IS NULL THEN
        l_res_over_pct := 0;
      END IF;

      UPDATE flm_mmm_operations
      SET bottleneck_resource_percent = l_res_over_pct,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = op_rec.standard_operation_id;

    ELSE
      UPDATE flm_mmm_operations
      SET bottleneck_resource_percent = NULL,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND standard_operation_id = op_rec.standard_operation_id;

    END IF;
  END LOOP; -- op_rec

  -- Resource/IPK Overcapacity For Lines
  FOR line_rec IN lines LOOP
    -- Resource
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = line_rec.line_id
      AND operation_type = i_calc_op_type
      AND bottleneck_resource_percent IS NULL;

    IF l_count <= 0 THEN
      OPEN res_overcapacity_ln(line_rec.line_id);
      FETCH res_overcapacity_ln INTO l_res_over_pct;
      CLOSE res_overcapacity_ln;

      IF l_res_over_pct < 0 THEN
        l_res_over_pct := 0;
      END IF;

    ELSE
      l_res_over_pct := NULL;
    END IF;

    -- IPK
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = line_rec.line_id
      AND operation_type = i_calc_op_type
      AND (ipk_needed > 0 or ipk_needed IS NULL)
      AND ipk_assigned = 0;

    IF l_count <= 0 THEN  -- No Infinite Overcapacity
      OPEN ipk_overcapacity(line_rec.line_id);
      FETCH ipk_overcapacity INTO l_ipk_over_pct;
      CLOSE ipk_overcapacity;

      IF l_ipk_over_pct < 0 OR l_ipk_over_pct IS NULL THEN
        l_ipk_over_pct := 0;
      END IF;

      -- Update
      UPDATE flm_mmm_lines
      SET bottleneck_resource_percent = l_res_over_pct,
        bottleneck_ipk_percent = l_ipk_over_pct,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND line_id = line_rec.line_id
        AND calculation_operation_type = i_calc_op_type;

    ELSE
      -- Update
      UPDATE flm_mmm_lines
      SET bottleneck_resource_percent = l_res_over_pct,
        bottleneck_ipk_percent = NULL,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
      WHERE plan_id = i_plan_id
        AND organization_id = i_organization_id
        AND line_id = line_rec.line_id
        AND calculation_operation_type = i_calc_op_type;

    END IF;
  END LOOP;
END calculate_res_ipk_overcapacity;


/************************************************************************
 * PROCEDURE calculate_res_ipk_undercap					*
 *  	Calculates the undercapacity percentage for resources and IPKs	*
 *	for each line and line operation/process.			*
 ************************************************************************/
PROCEDURE calculate_res_ipk_undercap(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER) IS

  l_res_under_pct	NUMBER;
  l_ipk_under_pct	NUMBER;

  l_count		NUMBER;
  l_temp		NUMBER;

  CURSOR lines IS
    SELECT line_id
    FROM flm_mmm_lines
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND calculation_operation_type = i_calc_op_type;

  CURSOR operations IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  -- retrieve all resource assigned and needed
  CURSOR res_assigned_needed(i_operation_id NUMBER) IS
    SELECT resource_assigned,resource_needed
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = i_operation_id;

  CURSOR res_undercapacity_ln(i_line_id NUMBER) IS
    SELECT max(resource_undercapacity) under_pct
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = i_line_id
      AND operation_type = i_calc_op_type;

  -- retrieve all ipk assigned and needed
  CURSOR ipk_assigned_needed(i_line_id NUMBER) IS
    SELECT ipk_assigned, ipk_needed
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = i_line_id
      AND operation_type = i_calc_op_type;

BEGIN
  -- Resource Undercapacity For Operations
  FOR op_rec IN operations LOOP -- For each operation
    l_res_under_pct := 0;	-- initial undercapacity pct

    FOR res_rec IN res_assigned_needed(op_rec.standard_operation_id) LOOP

      -- if OC(overcapacity) instead of UC(undercapacity), current UC remains the same
      IF res_rec.resource_assigned IS NULL OR
         res_rec.resource_assigned = 0 OR
         res_rec.resource_needed > res_rec.resource_assigned THEN
        NULL;

      -- else, calculate and update as necessary
      ELSE

        l_temp := 100*(res_rec.resource_assigned-res_rec.resource_needed)/res_rec.resource_assigned;

        IF l_temp>l_res_under_pct THEN
          l_res_under_pct := l_temp;
        END IF;

      END IF;
    END LOOP;

    UPDATE flm_mmm_operations
    SET resource_undercapacity = l_res_under_pct,
      last_updated_by = fnd_global.user_id,
      last_update_date = sysdate,
      last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND standard_operation_id = op_rec.standard_operation_id;

  END LOOP; -- new_op_rec

  -- Resource/IPK Undercapacity For Lines
  FOR line_rec IN lines LOOP

    -- Resource
    OPEN res_undercapacity_ln(line_rec.line_id);
    FETCH res_undercapacity_ln INTO l_res_under_pct;
    CLOSE res_undercapacity_ln;

    -- IPK
    l_ipk_under_pct := 0;

    FOR ipk_rec IN ipk_assigned_needed(line_rec.line_id) LOOP

      -- if OC instead of UC, current UC remains the same
      IF ipk_rec.ipk_assigned IS NULL OR
         ipk_rec.ipk_assigned = 0 OR
         ipk_rec.ipk_needed > ipk_rec.ipk_assigned THEN
        NULL;

      -- else, calculate and update as necessary
      ELSE
        l_temp := 100*(ipk_rec.ipk_assigned-ipk_rec.ipk_needed)/ipk_rec.ipk_assigned;

        IF l_temp>l_ipk_under_pct THEN
          l_ipk_under_pct := l_temp;
        END IF;

      END IF;
    END LOOP;

    -- Update
    UPDATE flm_mmm_lines
    SET resource_undercapacity = l_res_under_pct,
      ipk_undercapacity = l_ipk_under_pct,
      last_updated_by = fnd_global.user_id,
      last_update_date = sysdate,
      last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND line_id = line_rec.line_id
      AND calculation_operation_type = i_calc_op_type;

  END LOOP;
END calculate_res_ipk_undercap;

/************************************************************************
 * PROCEDURE calculate_process_efficiency				*
 *  	Calculates the process efficiency for each			*
 *	line operation/process.						*
 ************************************************************************/
PROCEDURE calculate_process_efficiency(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER) IS

  l_weighted_process_efficiency		NUMBER;
  l_operation_process_volume		NUMBER;

  CURSOR operations IS
    SELECT line_id,
           standard_operation_id
      FROM flm_mmm_operations
     WHERE plan_id = i_plan_id
       AND organization_id = i_organization_id
       AND operation_type = i_calc_op_type;

BEGIN
  -- Weighted Process Efficiency For Operations
  FOR operation_rec IN operations LOOP -- For each operation
    SELECT sum(nvl(bos.total_process_efficiency, 0) * nvl(it.process_volume, 0) ),
           sum(nvl(it.process_volume, 0))
      INTO l_weighted_process_efficiency,
           l_operation_process_volume
      FROM flm_mmm_op_items it,
           bom_operational_routings bor,
           bom_operation_sequences bos
     WHERE it.plan_id = i_plan_id
       AND it.organization_id = i_organization_id
       AND it.operation_type = i_calc_op_type
       AND it.line_id = operation_rec.line_id
       AND it.standard_operation_id = operation_rec.standard_operation_id
       AND bor.organization_id = i_organization_id
       AND bor.line_id = operation_rec.line_id
       AND bor.assembly_item_id = it.assembly_item_id
       AND bor.cfm_routing_flag = 1
       AND bor.mixed_model_map_flag =1
       AND bor.alternate_routing_designator IS NULL
       AND bor.common_routing_sequence_id = bos.routing_sequence_id
       AND bos.operation_type = i_calc_op_type
       AND bos.standard_operation_id = operation_rec.standard_operation_id;

    IF (l_operation_process_volume <> 0) THEN
      UPDATE flm_mmm_operations
         SET process_efficiency = l_weighted_process_efficiency / l_operation_process_volume
       WHERE plan_id = i_plan_id
         AND organization_id = i_organization_id
	 AND standard_operation_id = operation_rec.standard_operation_id;
    END IF;

  END LOOP;

END calculate_process_efficiency;


/************************************************************************
 * PROCEDURE delete_old_records						*
 *									*
 ************************************************************************/
PROCEDURE delete_old_records(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calc_op_type		IN	NUMBER,
	i_replan_flag		IN	VARCHAR2) IS

BEGIN
  -- FLM_MMM_LINES delete if not re-plan
  -- if re-plan, the records will be changed(delete, then insert)
  -- later (when calculating line takt).
  -- this is because we might need to use its line hours
  IF NOT (i_replan_flag = C_REPLAN_FLAG_YES) THEN
    DELETE FROM flm_mmm_lines
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND calculation_operation_type = i_calc_op_type;
  END IF;

  -- FLM_MMM_OPERATIONS delete if not re-plan
  -- if re-plan, the records will be changed(delete, then insert)
  -- when calculating operation takt.
  -- this is because we might need to use its ipk_assigned information
  IF NOT (i_replan_flag = C_REPLAN_FLAG_YES) THEN
    DELETE FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;
  END IF;

  -- FLM_MMM_OP_ITEMS
  DELETE FROM flm_mmm_op_items
  WHERE plan_id = i_plan_id
    AND organization_id = i_organization_id
    AND operation_type = i_calc_op_type;

  -- FLM_MMM_OP_RESOURCES, delete if not re-plan
  -- if re-plan, the records will be changed(delete, then insert)
  -- when calculating weighted resource usage
  -- this is because we might need to use its resource_assigned information
  IF NOT (i_replan_flag = C_REPLAN_FLAG_YES) THEN
    DELETE FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;
  END IF;

END delete_old_records;


/************************************************************************
 * Published Procedures and Functions					*
 ************************************************************************/

/************************************************************************
 * FUNCTION get_offset_date						*
 * 	Gets the offset start date to be considered 			*
 * 	when we look at FORECAST demand.				*
 ************************************************************************/
FUNCTION get_offset_date (i_organization_id	IN NUMBER,
			  i_start_date          IN DATE,
                	  i_bucket_type         IN NUMBER)
RETURN DATE IS
  l_offset_date   date;

BEGIN
  IF i_bucket_type = C_BUCKET_DAYS THEN
    -- no offsetting here
    l_offset_date := i_start_date;

  ELSIF i_bucket_type = C_BUCKET_WEEKS THEN
    SELECT bw.week_start_date
    INTO   l_offset_date
    FROM   bom_cal_week_start_dates bw,
           mtl_parameters mp
    WHERE  mp.organization_id = i_organization_id
      AND bw.calendar_code =  mp.calendar_code
      AND bw.exception_set_id = mp.calendar_exception_set_id
      AND bw.week_start_date <= i_start_date
      AND bw.next_date >= i_start_date;

  ELSIF i_bucket_type = C_BUCKET_PERIODS THEN
    SELECT bp.period_start_date
    INTO   l_offset_date
    FROM   bom_period_start_dates bp,
           mtl_parameters mp
    WHERE  mp.organization_id = i_organization_id
      AND    bp.calendar_code = mp.calendar_code
      AND    bp.exception_set_id = mp.calendar_exception_set_id
      AND    bp.period_start_date <= i_start_date
      AND    bp.next_date >= i_start_date;

  END IF;

  RETURN l_offset_date;

EXCEPTION
  WHEN OTHERS THEN
    RETURN i_start_date;

END get_offset_date;


/************************************************************************
 * PROCEDURE calculate							*
 *  									*
 ************************************************************************/
PROCEDURE calculate(
	i_plan_id			IN	NUMBER,
	i_organization_id		IN	NUMBER,
	i_calculation_operation_type	IN	NUMBER,
	i_product_family_id		IN	NUMBER,
	i_line_id			IN	NUMBER,
	i_demand_type			IN	NUMBER,
	i_demand_code			IN	VARCHAR2,
	i_start_date			IN	DATE,
	i_end_date			IN	DATE,
	i_demand_days			IN	NUMBER,
	i_hours_per_day			IN	NUMBER,
	i_boost_percent			IN	NUMBER,
	i_calculation_option		IN	NUMBER,
	i_calendar_code			IN	VARCHAR2,
    	i_exception_set_id  		IN	NUMBER,
    	i_last_calendar_date 		IN	DATE,
	i_replan_flag			IN	VARCHAR2,
	o_error_code			OUT NOCOPY	NUMBER,
	o_error_msg			OUT NOCOPY	VARCHAR2) IS

    l_demands	t_demand_table;
  l_error_msg	VARCHAR2(1000);

BEGIN
  -- Clean up history as necessary
  l_error_msg := 'delete old records.   ';
  delete_old_records(
		i_plan_id,
		i_organization_id,
		i_calculation_operation_type,
		i_replan_flag);

  -- Average Daily Demand
  l_demands.DELETE;
  l_error_msg := l_error_msg || 'retrieve demand.   ';
  calculate_avg_daily_demand(
	i_plan_id,
	i_organization_id,
	i_product_family_id,
	i_line_id,
	i_demand_type,
	i_demand_code,
	i_start_date,
	i_end_date,
	i_demand_days,
	i_boost_percent,
	i_calendar_code,
	i_exception_set_id,
	i_last_calendar_date,
	l_demands);

  -- Line TAKT
  l_error_msg := l_error_msg || 'calc line takt.   ';
  calculate_line_takt(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type,
	i_line_id,
	i_hours_per_day,
	i_replan_flag,
	l_demands);

  -- Process Volume
  l_error_msg := l_error_msg || 'calc process volume.   ';
  l_error_msg := l_error_msg || i_plan_id || ':' || i_organization_id ||
                 ':' || i_calculation_operation_type || ':' || l_demands.COUNT;
  calculate_process_volume(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type,
	l_demands);

  -- Operation TAKT
  l_error_msg := l_error_msg || 'calc operation takt.   ';
  calculate_operation_takt(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type,
	i_hours_per_day,
	i_replan_flag);

  -- Weighted Times
  l_error_msg := l_error_msg || 'calc weighted times.   ';
  calculate_weighted_times(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  -- Weighted Resource Usage
  l_error_msg := l_error_msg || 'calc weighted usage.   ';
  calculate_weighted_res_usage(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type,
	i_replan_flag);

  -- Resource/IPK Needed
  l_error_msg := l_error_msg || 'calc res/ipk needed.   ';
  calculate_res_ipk_needed(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type,
	i_calculation_option);

  -- TAKT For Assigned
  l_error_msg := l_error_msg || 'calc takt as assigned.   ';
  calculate_takt_assigned(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  l_error_msg := l_error_msg || 'calc overcapacity.   ';
  -- Resource/IPK Overcapacity
  calculate_res_ipk_overcapacity(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  l_error_msg := l_error_msg || 'calc undercapacity.   ';
  -- Resource/IPK Undercapacity
  calculate_res_ipk_undercap(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  -- Process Efficiency
  l_error_msg := l_error_msg || 'calc process efficiency.   ';
  calculate_process_efficiency(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  -- Commit Work
  commit;
  o_error_code := C_ERROR_CODE_SUCCESS;

EXCEPTION
  WHEN others then
    l_error_msg := 'ERROR: '||l_error_msg;
    o_error_msg := l_error_msg;
    o_error_code := C_ERROR_CODE_FAILURE;

END calculate;


/************************************************************************
 * PROCEDURE recalculate						*
 *  									*
 ************************************************************************/
PROCEDURE recalculate(
	i_plan_id	IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_calculation_operation_type	IN	NUMBER,
	i_calculation_option	IN	NUMBER,
	i_standard_operation_id	IN	NUMBER,
	o_error_code	OUT NOCOPY	NUMBER,
	o_error_msg	OUT NOCOPY	VARCHAR2) IS

BEGIN
  -- Verify Input
  -- Resource/IPK Needed
  IF i_standard_operation_id IS NULL THEN
    calculate_res_ipk_needed(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type,
	i_calculation_option);
  ELSE
    calculate_needed_by_op(
	i_plan_id,
	i_organization_id,
	i_standard_operation_id,
	i_calculation_option);
  END IF;

  -- TAKT For Assigned
  calculate_takt_assigned(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  -- Resource/IPK Overcapacity
  calculate_res_ipk_overcapacity(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  -- Resource/IPK Undercapacity
  calculate_res_ipk_undercap(
	i_plan_id,
	i_organization_id,
	i_calculation_operation_type);

  o_error_code := C_ERROR_CODE_SUCCESS;

EXCEPTION
  WHEN others then
    o_error_msg := 'ERROR';
    o_error_code := C_ERROR_CODE_FAILURE;

END recalculate;


/************************************************************************
 * PROCEDURE update_assigned_with_needed				*
 *  									*
 ************************************************************************/
PROCEDURE update_assigned_with_needed(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_line_id		IN	NUMBER,
	i_standard_operation_id	IN	NUMBER,
	i_resource_id	IN	NUMBER,
	i_calc_op_type	IN	NUMBER,
	o_error_code	OUT NOCOPY	NUMBER) IS

  l_dummy	NUMBER;

  CURSOR lock_res IS
    SELECT resource_id
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
    FOR UPDATE NOWAIT;

  CURSOR lock_op IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
    FOR UPDATE NOWAIT;

  CURSOR lock_res_res IS
    SELECT resource_id
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND resource_id = i_resource_id
    FOR UPDATE NOWAIT;

  CURSOR lock_res_line IS
    SELECT resource_id
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND line_id = i_line_id
    FOR UPDATE NOWAIT;

  CURSOR lock_op_line IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND line_id = i_line_id
    FOR UPDATE NOWAIT;

  CURSOR lock_res_op IS
    SELECT resource_id
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND standard_operation_id = i_standard_operation_id
    FOR UPDATE NOWAIT;

  CURSOR lock_op_op IS
    SELECT standard_operation_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND standard_operation_id = i_standard_operation_id
    FOR UPDATE NOWAIT;

BEGIN
  -- Update
  IF i_line_id IS NULL AND i_resource_id IS NULL THEN  -- for whole plan
    -- lock records
    FOR res_rec IN lock_res LOOP
      NULL;
    END LOOP;

    FOR op_rec IN lock_op LOOP
      NULL;
    END LOOP;

    -- update records
    UPDATE flm_mmm_op_resources
    SET resource_assigned = resource_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

    UPDATE flm_mmm_operations
    SET ipk_assigned = ipk_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type;

  ELSIF i_resource_id IS NOT NULL THEN  -- for a specific resource
    -- lock records
    FOR res_rec IN lock_res_res LOOP
      NULL;
    END LOOP;

    -- update records
    UPDATE flm_mmm_op_resources
    SET resource_assigned = resource_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND resource_id = i_resource_id;

  ELSIF i_line_id IS NOT NULL AND
	i_standard_operation_id IS NULL THEN  -- for a specific line
    -- lock records
    FOR res_rec IN lock_res_line LOOP
      NULL;
    END LOOP;

    FOR op_rec IN lock_op_line LOOP
      NULL;
    END LOOP;

    -- update records
    UPDATE flm_mmm_op_resources
    SET resource_assigned = resource_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND line_id = i_line_id;

    UPDATE flm_mmm_operations
    SET ipk_assigned = ipk_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND line_id = i_line_id;

  ELSIF i_standard_operation_id IS NOT NULL THEN  -- for a specific operation
    -- lock records
    FOR res_rec IN lock_res_op LOOP
      NULL;
    END LOOP;

    FOR op_rec IN lock_op_op LOOP
      NULL;
    END LOOP;

    -- update records
    UPDATE flm_mmm_op_resources
    SET resource_assigned = resource_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND standard_operation_id = i_standard_operation_id;

    UPDATE flm_mmm_operations
    SET ipk_assigned = ipk_needed,
        last_updated_by = fnd_global.user_id,
        last_update_date = sysdate,
        last_update_login = fnd_global.user_id
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_calc_op_type
      AND standard_operation_id = i_standard_operation_id;
  END IF;  -- Input Types

  -- Re-Calculate TAKT For Assigned
  calculate_takt_assigned(
	i_plan_id,
	i_organization_id,
	i_calc_op_type);

  -- Re-Calculate Overcapacity
  calculate_res_ipk_overcapacity(
	i_plan_id,
	i_organization_id,
	i_calc_op_type);

  -- Re-Calculate Undercapacity
  calculate_res_ipk_undercap(
	i_plan_id,
	i_organization_id,
	i_calc_op_type);

  o_error_code := C_ERROR_CODE_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN -- row lock
    o_error_code := C_ERROR_CODE_FAILURE;

END update_assigned_with_needed;


/************************************************************************
 * PROCEDURE save							*
 * 	Copies the Resource/IPK assigned info 				*
 *  	to the master set up area FROM this plan.			*
 ************************************************************************/
PROCEDURE save(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_operation_type	IN	NUMBER) IS

  l_count	NUMBER;

  CURSOR all_operations IS
    SELECT standard_operation_id operation_id,
           ipk_assigned,
	   line_id
    FROM flm_mmm_operations
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_operation_type;

  CURSOR all_resources IS
    SELECT resource_id,
	   standard_operation_id operation_id,
           resource_assigned,
	   line_id
    FROM flm_mmm_op_resources
    WHERE plan_id = i_plan_id
      AND organization_id = i_organization_id
      AND operation_type = i_operation_type;

BEGIN
  -- IPKs
  FOR op_rec IN all_operations LOOP
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_operations
    WHERE organization_id = i_organization_id
      AND plan_id = -1
      AND standard_operation_id = op_rec.operation_id;

    IF l_count > 0 THEN
      UPDATE flm_mmm_operations
      SET ipk_assigned = op_rec.ipk_assigned,
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          last_update_login = fnd_global.user_id
      WHERE organization_id = i_organization_id
        AND plan_id = -1
        AND standard_operation_id = op_rec.operation_id;

    ELSE
      INSERT INTO FLM_MMM_OPERATIONS (
		PLAN_ID,
		ORGANIZATION_ID,
		STANDARD_OPERATION_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OPERATION_TYPE,
		LINE_ID,
		IPK_ASSIGNED
      ) VALUES (
		-1,
		i_organization_id,
		op_rec.operation_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		i_operation_type,
		op_rec.LINE_ID,
		op_rec.ipk_assigned
      );

    END IF;
  END LOOP;

  -- Resources
  FOR res_rec IN all_resources LOOP
    SELECT count(*)
    INTO l_count
    FROM flm_mmm_op_resources
    WHERE organization_id = i_organization_id
      AND plan_id = -1
      AND resource_id = res_rec.resource_id
      AND standard_operation_id = res_rec.operation_id;

    IF l_count > 0 THEN
      UPDATE flm_mmm_op_resources
      SET resource_assigned = res_rec.resource_assigned,
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          last_update_login = fnd_global.user_id
      WHERE organization_id = i_organization_id
        AND plan_id = -1
        AND resource_id = res_rec.resource_id
        AND standard_operation_id = res_rec.operation_id;

    ELSE
      INSERT INTO FLM_MMM_OP_RESOURCES (
		PLAN_ID,
		ORGANIZATION_ID,
		RESOURCE_ID,
		STANDARD_OPERATION_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OPERATION_TYPE,
		LINE_ID,
		RESOURCE_ASSIGNED
	) VALUES (
		-1,
		i_organization_id,
		res_rec.resource_id,
		res_rec.operation_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		i_operation_type,
		res_rec.line_id,
		res_rec.resource_assigned
      );

    END IF;
  END LOOP;
END save;


END flm_mmm_calculation;

/

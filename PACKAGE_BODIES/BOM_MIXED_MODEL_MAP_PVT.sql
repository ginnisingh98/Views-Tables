--------------------------------------------------------
--  DDL for Package Body BOM_MIXED_MODEL_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_MIXED_MODEL_MAP_PVT" AS
/* $Header: BOMMMMCB.pls 120.1 2006/03/16 17:36:37 yulin noship $ */

G_FORECAST		CONSTANT	NUMBER := 1;
G_MDS			CONSTANT	NUMBER := 2;
G_MPS			CONSTANT	NUMBER := 3;
G_ACTUAL_PRODUCTION	CONSTANT	NUMBER := 4;
-- Added for enhancement bug #2538897
G_SALES_ORDERS          CONSTANT	NUMBER := 5;
G_PLANNED_ORDERS        CONSTANT	NUMBER := 6;

G_USER_CALC		CONSTANT	NUMBER := 2;
G_TOTAL_IPK		CONSTANT	NUMBER := 1;
G_DECIMAL		CONSTANT	NUMBER := 2;
G_PROCESS		CONSTANT	NUMBER := 2;
G_LINEOP		CONSTANT	NUMBER := 3;
G_HOUR			CONSTANT	NUMBER := 1;
G_MINUTE		CONSTANT	NUMBER := 2;
G_SECOND		CONSTANT	NUMBER := 3;
G_DAYS			CONSTANT	NUMBER := 1;
G_WEEKS			CONSTANT	NUMBER := 2;
G_PERIODS		CONSTANT	NUMBER := 3;
--below is new code
TYPE resource_id_type is TABLE of bom_resources.resource_id%TYPE
    INDEX BY BINARY_INTEGER;
TYPE dept_id_type is TABLE of bom_department_resources.department_id%TYPE
    INDEX BY BINARY_INTEGER;
--above is new code

-- ========================== ConvertTime ===================================

-- NAME	      :  ConvertTime
-- DESCRIPTION:  Converts "hour" input value into "Minutes" or "Seconds"
--               depending on p_time_uom.
-- REQUIRES   :  err_text    out buffer to return error message
-- MODIFIES   :
--
-- ==========================================================================

FUNCTION ConvertTime (p_input	NUMBER, p_time_uom   NUMBER) RETURN number IS
   l_output	NUMBER;
BEGIN
   IF (p_time_uom = G_MINUTE) then
      l_output := p_input * 60;
   ELSIF (p_time_uom = G_SECOND) THEN
      l_output := p_input * 3600;
   ELSIF (p_time_uom = G_HOUR) THEN
      l_output := p_input;
   END IF;

   RETURN l_output;
END ConvertTime;


-- ============================== GetBuckets ================================
--
-- NAME	      :  GetBuckets
-- DESCRIPTION:  Calculates number of buckets between a Start Date and an
--		 End Date for Months or Periods
-- REQUIRES   :  x_calendar_code    => Name of Calendar
--		 x_exception_set_id => ID of calendar exception set
--		 x_bucket	    => Bucket Type
-- 		 x_start_date       => Start Date
-- 		 x_end_date         => End Date
-- MODIFIES   :
--
-- ==========================================================================

FUNCTION GetBuckets	    (x_calendar_code 	VARCHAR2,
		  	     x_exception_set_id NUMBER,
			     x_bucket		NUMBER,
			     x_start_date	DATE,
			     x_end_date		DATE ) RETURN number IS
   l_buckets	NUMBER;
BEGIN
     IF (x_bucket = G_WEEKS) THEN
        SELECT count(week_start_date)
          INTO l_buckets
          FROM bom_cal_week_start_dates cal
         WHERE cal.exception_set_id = x_exception_set_id
           AND cal.calendar_code = x_calendar_code
           AND cal.week_start_date between x_start_date
               and x_end_date;
     ELSIF (x_bucket = G_PERIODS) THEN
        SELECT count(period_start_date)
          INTO l_buckets
          FROM bom_period_start_dates cal
         WHERE cal.exception_set_id = x_exception_set_id
           AND cal.calendar_code = x_calendar_code
           AND cal.period_start_date between x_start_date
               and x_end_date;
     END IF;

     RETURN l_buckets;

END GetBuckets;

-- ========================== GetWorkdaysBetween ============================
--
-- NAME	      :  GetWorkdaysBetween
-- DESCRIPTION:  Calculates number of workdays between a Start Date and an
--		 End Date
-- REQUIRES   :  x_calendar_code    => Name of Calendar
--		 x_exception_set_id => ID of calendar exception set
-- 		 x_start_date       => Start Date
-- 		 x_end_date         => End Date
-- MODIFIES   :
--
-- ==========================================================================

FUNCTION GetWorkdaysBetween (x_calendar_code 	VARCHAR2,
		  	     x_exception_set_id NUMBER,
			     x_start_date	DATE,
			     x_end_date		DATE ) RETURN number IS
   l_days	NUMBER;
BEGIN
     SELECT count(*)
       INTO l_days
       FROM bom_calendar_dates
      WHERE calendar_code =  x_calendar_code
        AND exception_set_id = x_exception_set_id
        AND calendar_date BETWEEN x_start_date AND x_end_date
        AND seq_num IS NOT NULL;

   RETURN l_days;
END GetWorkdaysBetween;


-- ============================ GetLastWeekDay =============================
--
-- NAME	      :  GetLastWeekDay
-- DESCRIPTION:  Calculates the last day of a week
-- REQUIRES   :  x_calendar_code      => Name of Calendar
--		 x_exception_set_id   => ID of calendar exception set
--		 x_last_calendar_date => Last day in the mfg calendar
-- 		 x_rate_end_date      => Rate End Date
-- 		 x_forecast_date      => Forecast Date
-- MODIFIES   :
--
-- ==========================================================================

FUNCTION GetLastWeekDay (x_calendar_code 	VARCHAR2,
		  	 x_exception_set_id 	NUMBER,
			 x_last_calendar_date   DATE,
			 x_rate_end_date	DATE,
			 x_forecast_date	DATE ) RETURN date IS
   l_last_week_day	DATE;

   CURSOR GetLastDay IS
      SELECT decode(next_date, week_start_date,
                    x_last_calendar_date, (next_date -1)) last_day
        FROM bom_cal_week_start_dates
       WHERE calendar_code = x_calendar_code
         AND exception_set_id = x_exception_set_id
         AND week_start_date = nvl(x_rate_end_date, x_forecast_date);
BEGIN
   FOR c1 IN GetLastDay LOOP
      l_last_week_day := c1.last_day;
   END LOOP;

   RETURN l_last_week_day;
END GetLastWeekDay;

-- ============================ GetLastPeriodDay ===========================
--
-- NAME	      :  GetLastPeriodDay
-- DESCRIPTION:  Calculates the last day of a period
-- REQUIRES   :  x_calendar_code      => Name of Calendar
--		 x_exception_set_id   => ID of calendar exception set
--		 x_last_calendar_date => Last day in the mfg calendar
-- 		 x_rate_end_date      => Rate End Date
-- 		 x_forecast_date      => Forecast Date
-- MODIFIES   :
--
-- ==========================================================================

FUNCTION GetLastPeriodDay (x_calendar_code 	VARCHAR2,
		  	   x_exception_set_id 	NUMBER,
			   x_last_calendar_date DATE,
			   x_rate_end_date	DATE,
			   x_forecast_date	DATE ) RETURN date IS
   l_last_period_day	DATE;
   CURSOR GetLastDay IS
      SELECT decode(next_date, period_start_date,
                    x_last_calendar_date, (next_date -1)) last_day
        FROM bom_period_start_dates
       WHERE calendar_code = x_calendar_code
         AND exception_set_id = x_exception_set_id
         AND period_start_date = nvl(x_rate_end_date, x_forecast_date);
BEGIN
   FOR c1 IN GetLastDay LOOP
      l_last_period_day := c1.last_day;
   END LOOP;

   RETURN l_last_period_day;
END GetLastPeriodDay;

--below is my code
PROCEDURE GetResourceId(
    p_assembly_item_id	NUMBER,
    p_org_id            NUMBER,
    p_line_id		NUMBER,
    p_resource_type	NUMBER,
    p_op_code		VARCHAR2,
    p_process_line_op	NUMBER,
    resource_index 	IN OUT	NOCOPY	NUMBER,
    resource_dept_table	IN OUT	NOCOPY	dept_id_type,
    resource_table	IN OUT	NOCOPY	resource_id_type ) IS

    CURSOR GetLineOpResourceId IS
    SELECT bopr.resource_id id , bosv.department_id dept_id
                 FROM bom_operation_resources bopr,
                      bom_resources br,
		      bom_operation_sequences_v bosv,
                      bom_operational_routings bor
               WHERE bopr.operation_sequence_id= bosv.operation_sequence_id
                  AND bopr.resource_id = br.resource_id
                  AND br.resource_type = p_resource_type
                  AND bor.mixed_model_map_flag = 1
                  AND bor.line_id = p_line_id
                  AND bor.assembly_item_id = p_assembly_item_id
                  AND bor.organization_id = p_org_id
                  AND bor.common_routing_sequence_id = bosv.routing_sequence_id
                  AND bosv.operation_type = 1
                  AND bosv.line_op_code = p_op_code;

    CURSOR GetProcessResourceId IS
    SELECT bopr.resource_id id , bosv.department_id dept_id
                 FROM bom_operation_resources bopr,
		      bom_resources br,
		      bom_operation_sequences_v bosv,
                      bom_operational_routings bor
               WHERE bopr.operation_sequence_id= bosv.operation_sequence_id
                  AND bopr.resource_id = br.resource_id
                  AND br.resource_type = p_resource_type
                  AND bor.mixed_model_map_flag = 1
                  AND bor.line_id = p_line_id
                  AND bor.assembly_item_id = p_assembly_item_id
                  AND bor.organization_id = p_org_id
                  AND bor.common_routing_sequence_id = bosv.routing_sequence_id
                  AND bosv.operation_type = 1
                  AND bosv.process_code = p_op_code;


    flag_res_stored NUMBER := 0;
BEGIN
flag_res_stored := 0;
IF ( p_process_line_op = G_PROCESS ) THEN
  FOR c1rec IN GetProcessResourceId LOOP
    FOR i IN 1..resource_index - 1  LOOP
      IF c1rec.id = resource_table(i) AND
         c1rec.dept_id = resource_dept_table(i) THEN
        flag_res_stored := 1;
        exit;
      END IF;
    END LOOP;
    IF (flag_res_stored = 0) THEN
      resource_table(resource_index) := c1rec.id;
      resource_dept_table(resource_index) := c1rec.dept_id;
      resource_index := resource_index + 1;
    ELSE
      flag_res_stored := 0;
    END IF;
  END LOOP; -- end for loop
ELSIF ( p_process_line_op = G_LINEOP ) THEN
  FOR c1rec IN GetLineOpResourceId LOOP
    FOR i IN 1..resource_index - 1  LOOP
      IF c1rec.id = resource_table(i) AND
         c1rec.dept_id = resource_dept_table(i) THEN
        flag_res_stored := 1;
        exit;
      END IF;
    END LOOP;
    IF (flag_res_stored = 0) THEN
      resource_table(resource_index) := c1rec.id;
      resource_dept_table(resource_index) := c1rec.dept_id;
      resource_index := resource_index + 1;
    ELSE
      flag_res_stored := 0;
    END IF;
  END LOOP; -- end for loop
END IF;
END;

PROCEDURE GetCapacity(
    p_resource_index 	IN NUMBER,
    p_resource_table	IN resource_id_type,
    p_dept_table	IN dept_id_type,
    x_capacity 	 	OUT 	NOCOPY	NUMBER ) IS

BEGIN
    x_capacity := 0;
    FOR i IN 1..p_resource_index - 1 LOOP
      DECLARE
        CURSOR GetCapacityUnits IS
          SELECT bdr.capacity_units CU
          FROM   bom_department_resources bdr
          WHERE bdr.department_id = p_dept_table(i)
            AND bdr.resource_id = p_resource_table(i);
      BEGIN
        FOR c1rec IN GetCapacityUnits LOOP
          x_capacity :=  x_capacity + c1rec.CU;
        END LOOP;
      END;
   END LOOP;-- aggregate machine capacity
END;
--above is my code

-- ========================== GetProcessLineOp ==============================
--
-- NAME	      :  GetProcessLineOp
-- DESCRIPTION:  Get Processes or Line Operations for a given Line
--		 (and Family if the Family is specified by the user).
--		 Insert these values into the table
--		 BOM_MIXED_MODEL_MAP_PROCESSES.
-- REQUIRES   :  err_text    out buffer to return error message
-- MODIFIES   :  BOM_MIXED_MODEL_MAP_PROCESSES
--
-- ==========================================================================

PROCEDURE GetProcessLineOp (
    p_mmm_id		NUMBER,
    p_org_id            NUMBER,
    p_line_id		NUMBER,
    p_family_item_id	NUMBER,
    p_operation_type	NUMBER,
    p_order		NUMBER,
    p_user_id		NUMBER,
    x_err_text     OUT  NOCOPY	VARCHAR2) IS

    -- GET ALL PROCESSES/LINE OPS THAT BELONG TO ROUTINGS ASSOCIATED WITH
    -- THE GIVEN LINE.  IF "FAMILY" IS ALSO SPECIFIED, THEN ROUTING ITEMS
    -- MUST BE MEMBERS OF THE GIVEN FAMILY.

    CURSOR c1 IS
       SELECT distinct bso.operation_code OC, bso.sequence_num SN
         FROM bom_standard_operations bso,
	      bom_operation_sequences bos,
	      bom_operational_routings bor
        WHERE bor.mixed_model_map_flag = 1
	  AND bor.line_id = p_line_id
          AND bor.organization_id = p_org_id
          AND bor.common_routing_sequence_id = bos.routing_sequence_id
          AND bos.operation_type = p_operation_type
          AND NVL(bos.eco_for_production,2) = 2
          AND bso.standard_operation_id = bos.standard_operation_id
          AND (p_family_item_id is null
               OR
               EXISTS (SELECT 'x'
			 FROM mtl_system_items msi
			WHERE msi.inventory_item_id = bor.assembly_item_id
			  AND msi.organization_id = p_org_id
			  AND msi.product_family_item_id = p_family_item_id))
      ORDER BY bso.sequence_num;


    -- SAME AS C1, EXCEPT ORDER BY IS DIFFERENT
    CURSOR c2 IS
       SELECT distinct bso.operation_code OC, bso.sequence_num SN
         FROM bom_standard_operations bso,
	      bom_operation_sequences bos,
	      bom_operational_routings bor
        WHERE bor.mixed_model_map_flag = 1
	  AND bor.line_id = p_line_id
          AND bor.organization_id = p_org_id
          AND bor.common_routing_sequence_id = bos.routing_sequence_id
          AND bos.operation_type = p_operation_type
	  AND NVL(bos.eco_for_production,2) = 2
          AND bso.standard_operation_id = bos.standard_operation_id
          AND (p_family_item_id is null
               OR
               EXISTS (SELECT 'x'
			 FROM mtl_system_items msi
			WHERE msi.inventory_item_id = bor.assembly_item_id
			  AND msi.organization_id = p_org_id
			  AND msi.product_family_item_id = p_family_item_id))
      ORDER BY bso.operation_code;


      l_stmt_num	NUMBER;
      l_group_number	NUMBER := 1;
      l_seq_id		NUMBER := 0;

BEGIN

-- INSERT PROCESSES/LINE OPS INTO TABLE IN GROUPS OF 5 ORDERED CORRECTLY

   l_stmt_num := 1;

   IF (p_order = 1) THEN
      FOR c1rec IN c1 LOOP
         l_stmt_num := 2;
         l_seq_id := l_seq_id + 1;

         IF (l_seq_id <= 5) THEN
            null;
         ELSE
            l_group_number := l_group_number + 1;
            l_seq_id := 1;
         END IF;

         l_stmt_num := 3;
         INSERT INTO bom_mixed_model_map_processes
            (MIXED_MODEL_MAP_ID,
	     GROUP_NUMBER,
             SEQUENCE_ID,
	     OPERATION_CODE,
	     CREATED_BY,
	     CREATION_DATE,
	     LAST_UPDATED_BY,
	     LAST_UPDATE_DATE)
            VALUES
             (p_mmm_id,
              l_group_number,
              l_seq_id,
              c1rec.OC,
	      p_user_id,
	      sysdate,
	      p_user_id,
	      sysdate);
      END LOOP;
   ELSE
      FOR c2rec IN c2 LOOP
         l_stmt_num := 2;
         l_seq_id := l_seq_id + 1;

         IF (l_seq_id <= 5) THEN
            null;
         ELSE
            l_group_number := l_group_number + 1;
            l_seq_id := 1;
         END IF;

         l_stmt_num := 3;
         INSERT INTO bom_mixed_model_map_processes
            (MIXED_MODEL_MAP_ID,
	     GROUP_NUMBER,
             SEQUENCE_ID,
	     OPERATION_CODE,
	     CREATED_BY,
	     CREATION_DATE,
	     LAST_UPDATED_BY,
	     LAST_UPDATE_DATE)
            VALUES
             (p_mmm_id,
              l_group_number,
              l_seq_id,
              c2rec.OC,
	      p_user_id,
	      sysdate,
	      p_user_id,
	      sysdate);
      END LOOP;
   END IF;

   COMMIT;
EXCEPTION
   WHEN others THEN
      x_err_text := 'BOM_Mixed_Model_Map_PVT(GetProcessLineOp-'||l_stmt_num||
		    ') '||substrb(SQLERRM,1,500);
END GetProcessLineOp;


-- =============================== GetDemands =================================
--
-- NAME	      :  GetDemand
-- DESCRIPTION:  Get the total demand of a product with respect to
--		 one sort of demand out of Forcast, MPS/MDS, Actual Production.
--
-- ==========================================================================
PROCEDURE GetDemand (
	p_org_id	NUMBER,
	p_demand_type	NUMBER,
	p_line_id	NUMBER,
	p_assembly_item_id	NUMBER,
	p_calendar_code	VARCHAR2,
	p_start_date	DATE,
	p_end_date	DATE,
    	p_last_calendar_date 	DATE,
   	p_exception_set_id	NUMBER,
	p_demand_code	VARCHAR2,
	o_demand	OUT NOCOPY	NUMBER,
	o_stmt_num	OUT NOCOPY	NUMBER) IS

    l_demand	NUMBER;

    l_stmt_num	NUMBER;
    l_rec_demand	NUMBER := 0;
    l_forecast_days   NUMBER;
    l_mdsmps_days     NUMBER;
    l_prorated_days   NUMBER;
    l_forecast_demand NUMBER;
    l_mdsmps_demand     NUMBER;

    l_last_week_day	DATE;
    l_last_period_day	DATE;

    l_order_option	NUMBER; --Sales/Planned Order Option
BEGIN
-- GET DEMAND FROM 1 OF 4 SOURCES
--   o_demand := 0;
--   return;
   l_demand := 0;

-- -----------------------------------------------------------------------
-- FOR "ACTUAL PRODUCTION"
-- -----------------------------------------------------------------------
      IF (p_demand_type = G_ACTUAL_PRODUCTION) THEN
/* per bug 4929489 - go directly to base tables
         DECLARE
            CURSOR GetActualProductionDemand IS
               SELECT sum(planned_quantity) PQ
                 FROM mrp_line_schedules_v
                WHERE organization_id = p_org_id
                  AND line_id = p_line_id
       	          AND primary_item_id = p_assembly_item_id
       	          AND trunc(scheduled_completion_date) between
                  p_start_date and p_end_date;
*/
         DECLARE
            CURSOR GetActualProductionDemand IS
               SELECT sum(planned_quantity) PQ
                 FROM
(
SELECT
       REP.ORGANIZATION_ID,
       REPITEM.PRIMARY_ITEM_ID,
       REP.DAILY_PRODUCTION_RATE planned_quantity,
       REP.LINE_ID,
       BOM.CALENDAR_DATE scheduled_completion_date
  FROM MFG_LOOKUPS              WST,
       MFG_LOOKUPS              ML,
       MFG_LOOKUPS              WJS,
       WIP_ENTITIES             ENTITIES,
       MTL_SYSTEM_ITEMS_KFV     KFV,
       MTL_PARAMETERS           MP,
       BOM_CALENDAR_DATES       BOM,
       WIP_REPETITIVE_ITEMS     REPITEM,
       WIP_LINES                LINE,
       WIP_REPETITIVE_SCHEDULES REP
 WHERE WST.LOOKUP_CODE = 3
   AND WST.LOOKUP_TYPE = 'MRP_WIP_SCHEDULE_TYPE'
   AND ML.LOOKUP_TYPE = 'MRP_WORKBENCH_IMPLEMENT_AS'
   AND ML.LOOKUP_CODE = 4
   AND WJS.LOOKUP_TYPE = 'WIP_JOB_STATUS'
   AND WJS.LOOKUP_CODE = REP.STATUS_TYPE
   AND ENTITIES.WIP_ENTITY_ID = REP.WIP_ENTITY_ID
   AND KFV.INVENTORY_ITEM_ID = REPITEM.PRIMARY_ITEM_ID
   AND KFV.ORGANIZATION_ID = REPITEM.ORGANIZATION_ID
   AND BOM.CALENDAR_DATE BETWEEN TRUNC(REP.FIRST_UNIT_COMPLETION_DATE) AND
       TRUNC(REP.LAST_UNIT_COMPLETION_DATE)
   AND BOM.SEQ_NUM IS NOT NULL
   AND MP.CALENDAR_CODE = BOM.CALENDAR_CODE
   AND MP.CALENDAR_EXCEPTION_SET_ID = BOM.EXCEPTION_SET_ID
   AND MP.ORGANIZATION_ID = REP.ORGANIZATION_ID
   AND REPITEM.LINE_ID = REP.LINE_ID
   AND REPITEM.WIP_ENTITY_ID = REP.WIP_ENTITY_ID
   AND REPITEM.ORGANIZATION_ID = REP.ORGANIZATION_ID
   AND LINE.ORGANIZATION_ID = REP.ORGANIZATION_ID
   AND LINE.LINE_ID = REP.LINE_ID
UNION ALL
SELECT
       JOB.ORGANIZATION_ID,
       JOB.PRIMARY_ITEM_ID,
       JOB.START_QUANTITY planned_quantity,
       JOB.LINE_ID,
       JOB.SCHEDULED_COMPLETION_DATE
  FROM MFG_LOOKUPS          WST,
       OE_ORDER_LINES_ALL   SO_LINES,
       WIP_SO_ALLOCATIONS   WSA,
       WIP_SCHEDULE_GROUPS  SCH,
       MFG_LOOKUPS          WJS,
       WIP_ENTITIES         ENTITIES,
       MTL_SYSTEM_ITEMS_KFV KFV,
       WIP_DISCRETE_JOBS    JOB,
       WIP_LINES            LINE
 WHERE WST.LOOKUP_CODE = 1
   AND WST.LOOKUP_TYPE = 'MRP_WIP_SCHEDULE_TYPE'
   AND SO_LINES.LINE_ID(+) = TO_NUMBER(WSA.DEMAND_SOURCE_LINE)
   AND WSA.WIP_ENTITY_ID(+) = JOB.WIP_ENTITY_ID
   AND WSA.ORGANIZATION_ID(+) = JOB.ORGANIZATION_ID
   AND SCH.SCHEDULE_GROUP_ID(+) = JOB.SCHEDULE_GROUP_ID
   AND SCH.ORGANIZATION_ID(+) = JOB.ORGANIZATION_ID
   AND WJS.LOOKUP_TYPE = 'WIP_JOB_STATUS'
   AND WJS.LOOKUP_CODE = JOB.STATUS_TYPE
   AND ENTITIES.ORGANIZATION_ID = JOB.ORGANIZATION_ID
   AND ENTITIES.WIP_ENTITY_ID = JOB.WIP_ENTITY_ID
   AND KFV.INVENTORY_ITEM_ID = JOB.PRIMARY_ITEM_ID
   AND KFV.ORGANIZATION_ID = JOB.ORGANIZATION_ID
   AND JOB.LINE_ID = LINE.LINE_ID
   AND JOB.ORGANIZATION_ID = LINE.ORGANIZATION_ID
UNION ALL
SELECT
       FLOW.ORGANIZATION_ID,
       FLOW.PRIMARY_ITEM_ID,
       FLOW.PLANNED_QUANTITY planned_quantity,
       FLOW.LINE_ID,
       FLOW.SCHEDULED_COMPLETION_DATE
  FROM MFG_LOOKUPS          WST,
       OE_ORDER_LINES_ALL   SO_LINES,
       WIP_SCHEDULE_GROUPS  SCH,
       MTL_SYSTEM_ITEMS_KFV KFV,
       WIP_FLOW_SCHEDULES   FLOW,
       WIP_LINES            LINE,
       MFG_LOOKUPS          ST
 WHERE WST.LOOKUP_CODE = 2
   AND WST.LOOKUP_TYPE = 'MRP_WIP_SCHEDULE_TYPE'
   AND SO_LINES.LINE_ID(+) = TO_NUMBER(FLOW.DEMAND_SOURCE_LINE)
   AND SCH.SCHEDULE_GROUP_ID(+) = FLOW.SCHEDULE_GROUP_ID
   AND SCH.ORGANIZATION_ID(+) = FLOW.ORGANIZATION_ID
   AND KFV.INVENTORY_ITEM_ID = FLOW.PRIMARY_ITEM_ID
   AND KFV.ORGANIZATION_ID = FLOW.ORGANIZATION_ID
   AND FLOW.LINE_ID = LINE.LINE_ID
   AND FLOW.ORGANIZATION_ID = LINE.ORGANIZATION_ID
   AND ST.LOOKUP_TYPE = 'WIP_FLOW_SCHEDULE_STATUS'
   AND ST.LOOKUP_CODE = FLOW.STATUS
)
                WHERE organization_id = p_org_id
                  AND line_id = p_line_id
       	          AND primary_item_id = p_assembly_item_id
       	          AND trunc(scheduled_completion_date) between
                  p_start_date and p_end_date;

         BEGIN
            FOR c5rec IN GetActualProductionDemand LOOP
              l_demand := nvl(c5rec.PQ ,0);
            END LOOP;  -- SELECTING ACTUAL PRODUCTION RECORDS
         END;

-- Added for enhancement bug #2538897
-- -----------------------------------------------------------------------
-- FOR "SALES / PLANNED ORDERS"
-- -----------------------------------------------------------------------
      ELSIF (p_demand_type IN (G_SALES_ORDERS, G_PLANNED_ORDERS)) THEN
/* perf bug 4929489 - go directly to the base tables
         DECLARE
            CURSOR GetUnscheduleDemand(i_option IN NUMBER) IS
               SELECT sum(order_quantity) PQ
                 FROM mrp_unscheduled_orders_v
                WHERE organization_id = p_org_id
                  AND line_id = p_line_id
                  AND inventory_item_id = p_assembly_item_id
                  AND trunc(order_date) between p_start_date and p_end_date
                  AND unscheduled_order_option = i_option;
         BEGIN
	    IF p_demand_type = G_SALES_ORDERS THEN
	      l_order_option := 1;
	    ELSE
	      l_order_option := 2;
	    END IF;
*/
	    IF p_demand_type = G_SALES_ORDERS THEN
           DECLARE
            CURSOR GetUnscheduleDemand IS
               SELECT sum(order_quantity) PQ
               FROM
(
SELECT
       GREATEST((INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SL1.SHIP_FROM_ORG_ID,
                                                       SL1.INVENTORY_ITEM_ID,
                                                       SL1.ORDER_QUANTITY_UOM,
                                                       SL1.ORDERED_QUANTITY) -
                MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY(SL1.LINE_ID,
                                                          2,
                                                          TO_CHAR(NULL),
                                                          MSI1.REPLENISH_TO_ORDER_FLAG) -
                MRP_FLOW_SCHEDULE_UTIL.GET_RESERVATION_QUANTITY(SL1.SHIP_FROM_ORG_ID,
                                                                 SL1.INVENTORY_ITEM_ID,
                                                                 SL1.LINE_ID,
                                                                 MSI1.REPLENISH_TO_ORDER_FLAG)),
                0) order_quantity,
        sl1.inventory_item_id,
        sl1.ship_from_org_id organization_id,
        wl.line_id,
        sl1.schedule_ship_date order_date
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
)
                WHERE organization_id = p_org_id
                  AND line_id = p_line_id
                  AND inventory_item_id = p_assembly_item_id
                  AND trunc(order_date) between p_start_date and p_end_date;
        BEGIN
            FOR c5rec IN GetUnscheduleDemand LOOP
              l_demand := nvl(c5rec.PQ ,0);
            END LOOP;  -- SELECTING UNSCHEDULED ORDERS RECORDS
         END;
       ELSE /* planned order */
           DECLARE
            CURSOR GetUnscheduleDemand IS
               SELECT sum(order_quantity) PQ
                 FROM
(
SELECT
       MR1.ORGANIZATION_ID,
       MR1.INVENTORY_ITEM_ID,
       WL.LINE_ID,
       NVL(MR1.FIRM_DATE, MR1.NEW_SCHEDULE_DATE) order_date,
       GREATEST((NVL(MR1.FIRM_QUANTITY, MR1.NEW_ORDER_QUANTITY) -
                MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY(TO_CHAR(MR1.TRANSACTION_ID),
                                                          100,
                                                          NULL,
                                                          NULL)),
                0) order_quantity
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
       (SELECT DESIGNATOR
          FROM MRP_DESIGNATORS_VIEW
         WHERE PRODUCTION = 1
           AND ORGANIZATION_ID = MP1.ORGANIZATION_ID
           AND DESIGNATOR = MR1.COMPILE_DESIGNATOR)
   AND RSI1.BUILD_IN_WIP_FLAG = 1 /* YES */
   AND RSI1.BOM_ITEM_TYPE = 4
   AND (RSI1.IN_SOURCE_PLAN = 2 OR RSI1.IN_SOURCE_PLAN IS NULL)
   AND wl.organization_id = MR1.ORGANIZATION_ID
   AND wl.line_id in (select line_id
                        from bom_operational_routings bor2
                       where bor2.assembly_item_id = MR1.INVENTORY_ITEM_ID
                         and bor2.organization_id = MR1.ORGANIZATION_ID
                         and bor2.cfm_routing_flag = 1)
)
                WHERE organization_id = p_org_id
                  AND line_id = p_line_id
                  AND inventory_item_id = p_assembly_item_id
                  AND trunc(order_date) between p_start_date and p_end_date;
        BEGIN
            FOR c5rec IN GetUnscheduleDemand LOOP
              l_demand := nvl(c5rec.PQ ,0);
            END LOOP;  -- SELECTING UNSCHEDULED ORDERS RECORDS
         END;
       END IF;

-- -----------------------------------------------------------------------
-- FOR "FORECAST"
-- -----------------------------------------------------------------------
     ELSIF (p_demand_type = G_FORECAST) THEN
         DECLARE
            CURSOR GetForecastDemand IS
               SELECT current_forecast_quantity, rate_end_date, bucket_type,
		      forecast_date
                 FROM mrp_forecast_dates
                WHERE organization_id = p_org_id
                  AND forecast_designator = p_demand_code
       	          AND inventory_item_id = p_assembly_item_id
		  AND (line_id = p_line_id OR line_id is NULL);
         BEGIN
            FOR c2rec IN GetForecastDemand LOOP
              l_stmt_num := 3;
              l_forecast_days   := 0;
              l_prorated_days   := 0;
              l_forecast_demand := 0;
	      l_rec_demand      := 0;

	       -- --------------------------------------------------------
	       -- FOR "DAYS" BUCKET
	       -- --------------------------------------------------------
	       IF (c2rec.bucket_type = G_DAYS) THEN
                  IF (c2rec.forecast_date >= p_start_date
		      AND c2rec.forecast_date <= p_end_date) THEN
                     IF (nvl(c2rec.rate_end_date, c2rec.forecast_date)
			 <= p_end_date) THEN

			-- FORECAST FALLS WITHIN RANGE

                        l_stmt_num := 4;
                        IF (c2rec.rate_end_date is NULL) THEN
                           l_rec_demand := c2rec.current_forecast_quantity;
                        ELSE
                           l_rec_demand := c2rec.current_forecast_quantity *
				  (mrp_calendar.days_between(p_org_id,
			           c2rec.bucket_type, c2rec.forecast_date,
				   c2rec.rate_end_date) + 1);
                        END IF;
                        l_demand := l_demand + l_rec_demand;
		     ELSE

                        -- ONLY END DATE CUTS INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 5;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      nvl(c2rec.rate_end_date,
					          c2rec.forecast_date));

			-- GET # OF DAYS BETWEEN FORECAST AND END DATE
                        l_stmt_num := 6;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 7;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				(mrp_calendar.days_between(p_org_id,
			         c2rec.bucket_type, c2rec.forecast_date,
				 c2rec.rate_end_date) + 1);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 8;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;

		  IF (c2rec.forecast_date < p_start_date
		      AND nvl(c2rec.rate_end_date, c2rec.forecast_date) >=
			  p_start_date) THEN
                     IF (nvl(c2rec.rate_end_date, c2rec.forecast_date)
			 <= p_end_date) THEN

			-- ONLY START DATE CUTS INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 9;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      nvl(c2rec.rate_end_date,
					          c2rec.forecast_date));

			-- GET # OF DAYS BTWN START DATE AND FORECAST END DATE
                        l_stmt_num := 10;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      nvl(c2rec.rate_end_date,
						  c2rec.forecast_date));

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 11;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				(mrp_calendar.days_between(p_org_id,
			         c2rec.bucket_type, c2rec.forecast_date,
				 c2rec.rate_end_date) + 1);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 12;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
                     ELSE
			-- BOTH START AND END DATE CUT INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 13;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      nvl(c2rec.rate_end_date,
					          c2rec.forecast_date));

			-- GET # OF DAYS BTWN START DATE AND END DATE
                        l_stmt_num := 14;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 15;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				(mrp_calendar.days_between(p_org_id,
			         c2rec.bucket_type, c2rec.forecast_date,
				 c2rec.rate_end_date) + 1);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 16;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;

	       -- --------------------------------------------------------
	       -- FOR "WEEKS" BUCKET
	       -- --------------------------------------------------------

               ELSIF (c2rec.bucket_type = G_WEEKS) THEN
                  l_stmt_num := 17;
                  l_last_week_day := GetLastWeekDay(p_calendar_code,
			 		            p_exception_set_id,
					            p_last_calendar_date,
					            c2rec.rate_end_date,
					            c2rec.forecast_date);
                  IF (c2rec.forecast_date >= p_start_date
		      AND c2rec.forecast_date <= p_end_date) THEN
                     IF (l_last_week_day <= p_end_date) THEN

			-- FORECAST FALLS WITHIN RANGE
                        l_stmt_num := 18;
                        IF (c2rec.rate_end_date is NULL) THEN
                           l_rec_demand := c2rec.current_forecast_quantity;
                        ELSE
                           l_rec_demand := c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;
                        l_demand := l_demand + l_rec_demand;
		     ELSE

                        -- ONLY END DATE CUTS INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 18;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      l_last_week_day);

			-- GET # OF DAYS BETWEEN FORECAST AND END DATE
                        l_stmt_num := 19;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 20;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 21;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;

		  IF (c2rec.forecast_date < p_start_date
		      AND l_last_week_day >= p_start_date) THEN
                     IF (l_last_week_day <= p_end_date) THEN

			-- ONLY START DATE CUTS INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 22;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      l_last_week_day);

			-- GET # OF DAYS BTWN START DATE AND FORECAST END DATE
                        l_stmt_num := 23;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      l_last_week_day);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 24;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 25;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
                     ELSE
			-- BOTH START AND END DATE CUT INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 26;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
				 	      l_last_week_day);

			-- GET # OF DAYS BTWN START DATE AND END DATE
                        l_stmt_num := 27;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 28;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 29;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;

	       -- --------------------------------------------------------
	       -- FOR "PERIODS" BUCKET
	       -- --------------------------------------------------------
	       ELSIF (c2rec.bucket_type = G_PERIODS) THEN
                  l_stmt_num := 30;
                  l_last_period_day := GetLastPeriodDay(p_calendar_code,
			 		            p_exception_set_id,
					            p_last_calendar_date,
					            c2rec.rate_end_date,
					            c2rec.forecast_date);
                  IF (c2rec.forecast_date >= p_start_date
		      AND c2rec.forecast_date <= p_end_date) THEN
                     IF (l_last_period_day <= p_end_date) THEN

			-- FORECAST FALLS WITHIN RANGE
                        l_stmt_num := 31;
                        IF (c2rec.rate_end_date is NULL) THEN
                           l_rec_demand := c2rec.current_forecast_quantity;
                        ELSE
                           l_rec_demand := c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;
                        l_demand := l_demand + l_rec_demand;
		     ELSE

                        -- ONLY END DATE CUTS INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 32;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      l_last_period_day);

			-- GET # OF DAYS BETWEEN FORECAST AND END DATE
                        l_stmt_num := 33;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 34;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 35;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;

		  IF (c2rec.forecast_date < p_start_date
		      AND l_last_period_day >= p_start_date) THEN
                     IF (l_last_period_day <= p_end_date) THEN

			-- ONLY START DATE CUTS INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 36;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
					      l_last_period_day);

			-- GET # OF DAYS BTWN START DATE AND FORECAST END DATE
                        l_stmt_num := 37;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      l_last_period_day);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 38;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 39;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
                     ELSE
			-- BOTH START AND END DATE CUT INTO FORECAST

			-- GET # OF DAYS IN FORECAST
                        l_stmt_num := 40;
			l_forecast_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c2rec.forecast_date,
				 	      l_last_period_day);

			-- GET # OF DAYS BTWN START DATE AND END DATE
                        l_stmt_num := 41;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE FORECAST
                        l_stmt_num := 42;
			IF (c2rec.rate_end_date is NULL) THEN
                          l_forecast_demand := c2rec.current_forecast_quantity;
                        ELSE
                          l_forecast_demand :=
				c2rec.current_forecast_quantity *
				   GetBuckets(p_calendar_code,
				   p_exception_set_id, c2rec.bucket_type,
				   c2rec.forecast_date, c2rec.rate_end_date);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 43;
  			l_rec_demand := (l_prorated_days/l_forecast_days) *
				         l_forecast_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;
	       END IF; -- CHECK BUCKET TYPES
            END LOOP;  -- SELECTING FORECAST RECORDS
         END;
-- -----------------------------------------------------------------------
-- FOR "MDS" AND "MPS"
-- -----------------------------------------------------------------------
      ELSIF (p_demand_type in (G_MDS, G_MPS)) THEN
         DECLARE
            CURSOR GetMdsMpsDemand IS
               SELECT repetitive_daily_rate, rate_end_date,
		      schedule_quantity, schedule_date
                 FROM mrp_schedule_dates
                WHERE organization_id = p_org_id
                  AND schedule_designator = p_demand_code
		  AND (line_id = p_line_id OR line_id is NULL)
		  AND schedule_level = 2
       	          AND inventory_item_id = p_assembly_item_id;
         BEGIN
            l_stmt_num := 44;
            FOR c3rec IN GetMdsMpsDemand LOOP
              l_mdsmps_days   := 0;
              l_prorated_days := 0;
              l_mdsmps_demand := 0;
	      l_rec_demand    := 0;

	       -- --------------------------------------------------------
	       -- FOR "DAYS" BUCKET
	       -- --------------------------------------------------------

                  IF (c3rec.schedule_date >= p_start_date
		      AND c3rec.schedule_date <= p_end_date) THEN
                     IF (nvl(c3rec.rate_end_date, c3rec.schedule_date)
			 <= p_end_date) THEN

			-- MDS/MPS FALLS WITHIN RANGE
                        l_stmt_num := 45;
                        IF (c3rec.rate_end_date is NULL) THEN
                           l_rec_demand := c3rec.schedule_quantity;
                        ELSE
                           l_rec_demand := c3rec.repetitive_daily_rate *
				  (mrp_calendar.days_between(p_org_id,
			           1, c3rec.schedule_date,
				   c3rec.rate_end_date) + 1);
                        END IF;
                        l_demand := l_demand + l_rec_demand;
		     ELSE

                        -- ONLY END DATE CUTS INTO MDS/MPS

			-- GET # OF DAYS IN MDS/MPS
                        l_stmt_num := 46;
			l_mdsmps_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c3rec.schedule_date,
					      nvl(c3rec.rate_end_date,
					          c3rec.schedule_date));

			-- GET # OF DAYS BETWEEN MDS/MPS AND END DATE
                        l_stmt_num := 47;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c3rec.schedule_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE MDS/MPS
                        l_stmt_num := 48;
			IF (c3rec.rate_end_date is NULL) THEN
                          l_mdsmps_demand := c3rec.schedule_quantity;
                        ELSE
                          l_mdsmps_demand :=
				c3rec.repetitive_daily_rate *
				(mrp_calendar.days_between(p_org_id,
			         1, c3rec.schedule_date,
				 c3rec.rate_end_date) + 1);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 49;
  			l_rec_demand := (l_prorated_days/l_mdsmps_days) *
				         l_mdsmps_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;

		  IF (c3rec.schedule_date < p_start_date
		      AND nvl(c3rec.rate_end_date, c3rec.schedule_date) >=
			  p_start_date) THEN
                     IF (nvl(c3rec.rate_end_date, c3rec.schedule_date)
			 <= p_end_date) THEN

			-- ONLY START DATE CUTS INTO MDS/MPS

			-- GET # OF DAYS IN MDS/MPS
                        l_stmt_num := 50;
			l_mdsmps_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c3rec.schedule_date,
					      nvl(c3rec.rate_end_date,
					          c3rec.schedule_date));

			-- GET # OF DAYS BTWN START DATE AND MDS/MPS END DATE
                        l_stmt_num := 51;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      nvl(c3rec.rate_end_date,
						  c3rec.schedule_date));

    			-- GET TOTAL DEMAND FOR THE MDS/MPS
                        l_stmt_num := 52;
			IF (c3rec.rate_end_date is NULL) THEN
                          l_mdsmps_demand := c3rec.schedule_quantity;
                        ELSE
                          l_mdsmps_demand :=
				c3rec.repetitive_daily_rate *
				(mrp_calendar.days_between(p_org_id,
			         1, c3rec.schedule_date,
				 c3rec.rate_end_date) + 1);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 53;
  			l_rec_demand := (l_prorated_days/l_mdsmps_days) *
				         l_mdsmps_demand;
                        l_demand := l_demand + l_rec_demand;
                     ELSE
			-- BOTH START AND END DATE CUT INTO MDS/MPS

			-- GET # OF DAYS IN MDS/MPS
                        l_stmt_num := 54;
			l_mdsmps_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      c3rec.schedule_date,
					      nvl(c3rec.rate_end_date,
					          c3rec.schedule_date));

			-- GET # OF DAYS BTWN START DATE AND END DATE
                        l_stmt_num := 55;
			l_prorated_days := GetWorkdaysBetween(
					      p_calendar_code,
					      p_exception_set_id,
					      p_start_date,
					      p_end_date);

    			-- GET TOTAL DEMAND FOR THE MDS/MPS
                        l_stmt_num := 56;
			IF (c3rec.rate_end_date is NULL) THEN
                          l_mdsmps_demand := c3rec.schedule_quantity;
                        ELSE
                          l_mdsmps_demand :=
				c3rec.repetitive_daily_rate *
				(mrp_calendar.days_between(p_org_id,
			         1, c3rec.schedule_date,
				 c3rec.rate_end_date) + 1);
                        END IF;

  			-- CALCULATE DEMAND
                        l_stmt_num := 57;
  			l_rec_demand := (l_prorated_days/l_mdsmps_days) *
				         l_mdsmps_demand;
                        l_demand := l_demand + l_rec_demand;
		     END IF;
		  END IF;
            END LOOP;
         END;
      END IF; -- CHECK DEMAND TYPE
   o_demand := l_demand;
   o_stmt_num := l_stmt_num;
END GetDemand;



-- =============================== GetDetails =================================
--
-- NAME	      :  GetDetails
-- DESCRIPTION:  Get the Detail of resource usage on the line, according
--		 to the given demand
--
--               Insert these values into the table BOM_MIXED_MODEL_MAP_RES.
-- REQUIRES   :  err_text    out buffer to return error message
-- MODIFIES   :  BOM_MIXED_MODEL_MAP_RESOURCES
--
-- ==========================================================================

PROCEDURE GetDetails (
    p_mmm_id		NUMBER,
    p_line_id		NUMBER,
    p_family_item_id	NUMBER,
    p_org_id		NUMBER,
    p_user_id		NUMBER,
    p_start_date	DATE,
    p_end_date		DATE,
    p_demand_type	NUMBER,
    p_demand_code	VARCHAR2,
    p_hours_per_day	NUMBER,
    p_demand_days	NUMBER,
    p_boost_percent	NUMBER,
    p_operation_type	NUMBER,
    p_time_uom		NUMBER,
    p_calendar_code	VARCHAR2,
    p_exception_set_id  NUMBER,
    p_last_calendar_date DATE,
    x_err_text     OUT  NOCOPY	VARCHAR2) IS

  l_hour_uom	VARCHAR2(3);
  l_hour_conv	NUMBER;

    -- Cursor to Get Assembly Items
    CURSOR GetProducts IS
       SELECT assembly_item_id item_id
         FROM bom_operational_routings bor
        WHERE mixed_model_map_flag = 1
	  AND line_id = p_line_id
          AND organization_id = p_org_id
          AND (p_family_item_id is null
               OR
               EXISTS (SELECT 'x'
			 FROM mtl_system_items msi
			WHERE msi.inventory_item_id = bor.assembly_item_id
			  AND msi.organization_id = p_org_id
			  AND msi.product_family_item_id = p_family_item_id))
      ORDER BY assembly_item_id;

    -- Cursor to Get Resource Details
    CURSOR ResourceDetails IS
	select 	bor.resource_id resource_id,
		nvl(bor.activity_id, -1) activity_id,
		bos1.standard_operation_id std_op_id,
		brtg.assembly_item_id assy_item_id,
		sum(bor.usage_rate_or_amount * nvl(con.conversion_rate, 0) /
                    nvl(l_hour_conv, 1) *
		    nvl(bos1.net_planning_percent, 100) / 100 /
		    decode(bos1.reverse_cumulative_yield, '', 1,
			'0', 1, bos1.reverse_cumulative_yield)) resource_needed
	from 	bom_operation_resources bor,
		bom_resources br,
     		bom_operational_routings brtg,
     		bom_operation_sequences bos1,
     		bom_operation_sequences bos2,
		mtl_uom_conversions con
	where brtg.line_id = p_line_id
	  and brtg.mixed_model_map_flag = 1
	  and bos1.routing_sequence_id = brtg.common_routing_sequence_id
	  and bos2.routing_sequence_id = brtg.common_routing_sequence_id
	  and br.resource_id = bor.resource_id
	  and con.uom_code (+) = br.unit_of_measure
	  and con.inventory_item_id (+) = 0
	  and ((    bos1.operation_type = 3
	        and bos2.line_op_seq_id = bos1.operation_sequence_id
	        and p_operation_type = 3) or
	       (    bos1.operation_type = 2
	        and bos2.process_op_seq_id = bos1.operation_sequence_id
	        and p_operation_type = 2))
	  and bos2.operation_sequence_id = bor.operation_sequence_id
	group by bor.resource_id, nvl(bor.activity_id, -1), bos1.standard_operation_id, brtg.assembly_item_id
	order by bor.resource_id, nvl(bor.activity_id, -1), bos1.standard_operation_id, brtg.assembly_item_id;

  -- Local Types

  TYPE l_demand_rec_type IS RECORD (
    assembly_item_id	number,
    average_demand	number);

  TYPE l_process_lop_rec_type IS RECORD (
    standard_operation_id	number,
    process_volume		number,
    process_takt		number);

  TYPE l_resource_detail_rec_type IS RECORD (
    resource_id		number,
    --resource_code	varchar2(10),
    activity_id		number,
    standard_operation_id	number,
    resource_needed	number);

  TYPE l_demand_tbl_type IS TABLE OF l_demand_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE l_process_lop_tbl_type IS TABLE OF l_process_lop_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE l_resource_detail_tbl_type IS TABLE OF l_resource_detail_rec_type
    INDEX BY BINARY_INTEGER;

  -- Local Variables
  l_demand_table 	l_demand_tbl_type;
  l_process_lop_table	l_process_lop_tbl_type;
  l_res_detail_table	l_resource_detail_tbl_type;

  l_demand		number;
  l_stmt_num		number;

  l_assy_id	number;
  l_volume	number;

  l_resource_needed	number;
  l_demand_sum		number;

  l_index	number;

  l_num	number := 0;
  l_text varchar2(300);

  l_std_op_id	number;
BEGIN
  -- Get Demands
  l_stmt_num := 0;
  l_demand_table.DELETE;
  FOR assy IN GetProducts LOOP
    GetDemand (
	p_org_id,
	p_demand_type,
	p_line_id,
	assy.item_id,
	p_calendar_code,
	p_start_date,
	p_end_date,
    	p_last_calendar_date,
        p_exception_set_id,
	p_demand_code,
	l_demand,
	l_stmt_num);
    l_demand_table(assy.item_id).assembly_item_id := assy.item_id;
    l_demand_table(assy.item_id).average_demand := l_demand*(100+nvl(p_boost_percent, 0))/(100*p_demand_days);

/*    l_text := 'demand '|| l_num || '  item id: '||l_demand_table(assy.item_id).assembly_item_id||' average demand: '||l_demand_table(assy.item_id).average_demand;
    l_num := l_num+1;
    insert into lm_temp (
	text
    )values(
        l_text
    );
*/

  END LOOP;

  -- Calculate Process Volumes
  l_process_lop_table.DELETE;
  IF l_demand_table.count > 0 THEN
    l_index := l_demand_table.FIRST;
    LOOP  -- For each assembly item
      IF l_demand_table(l_index).average_demand > 0 THEN
        l_assy_id := l_demand_table(l_index).assembly_item_id;
        DECLARE
          CURSOR seqs IS
            select bos.standard_operation_id op,
		   bos.reverse_cumulative_yield yld,
		   bos.net_planning_percent pct
            from bom_operation_sequences bos,
                 bom_operational_routings bor
            where bor.assembly_item_id = l_assy_id
              and bor.mixed_model_map_flag = 1
              and bor.common_routing_sequence_id = bos.routing_sequence_id
              and bos.operation_type = p_operation_type;
        BEGIN
          FOR seq IN seqs LOOP
	    -- Get this Volume
            l_volume := l_demand_table(l_index).average_demand *
			nvl(seq.pct, 100) / (100 * nvl(seq.yld, 1));
	    -- Count it In
            IF l_process_lop_table.EXISTS(seq.op) THEN
              l_process_lop_table(seq.op).process_volume := l_process_lop_table(seq.op).process_volume + l_volume;
            ELSE
	      l_process_lop_table(seq.op).standard_operation_id := seq.op;
              l_process_lop_table(seq.op).process_volume := l_volume;
            END IF;
          END LOOP;
        END;
      END IF;
      EXIT WHEN l_index = l_demand_table.LAST;
      l_index := l_demand_table.NEXT(l_index);
    END LOOP;
  END IF;

  -- Calculate Process Takt
  l_index := l_process_lop_table.FIRST;
  l_num := 0;
  LOOP
    -- we should assume hours, since the Time UOM doesn't really matter.
    l_process_lop_table(l_index).process_takt :=
      p_hours_per_day/l_process_lop_table(l_index).process_volume;
      --converttime(p_hours_per_day/l_process_lop_table(l_index).process_volume,
      --p_time_uom);

/*    l_text := 'process volume '|| l_num || '  operation id: '||l_process_lop_table(l_index).standard_operation_id||' volume: '||l_process_lop_table(l_index).process_volume;
    l_num := l_num+1;
    insert into lm_temp (
	text
    )values(
        l_text
    );
*/
    EXIT WHEN l_index = l_process_lop_table.LAST;
    l_index := l_process_lop_table.NEXT(l_index);
  END LOOP;

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

  -- Get Resource Details
  l_stmt_num := 2;
  l_index := 0;
  FOR res IN ResourceDetails LOOP
    IF l_index = 0 THEN
      l_res_detail_table(l_index).resource_id := res.resource_id;
      -- l_res_detail_table(l_index).resource_code := res.resource_code;
      l_res_detail_table(l_index).activity_id := res.activity_id;
      l_res_detail_table(l_index).standard_operation_id := res.std_op_id;
      l_resource_needed := res.resource_needed * l_demand_table(res.assy_item_id).average_demand;
      --l_demand_sum := l_demand_table(res.assy_item_id).average_demand;
      l_index := l_index + 1;
    ELSIF l_res_detail_table(l_index-1).resource_id = res.resource_id and
          -- l_res_detail_table(l_index-1).resource_code = res.resource_code and
          nvl(l_res_detail_table(l_index-1).activity_id, -1) = nvl(res.activity_id, -1) and
          l_res_detail_table(l_index-1).standard_operation_id = res.std_op_id THEN -- same group
      l_resource_needed := l_resource_needed +
	res.resource_needed * l_demand_table(res.assy_item_id).average_demand;
      --l_demand_sum := l_demand_sum +
	--l_demand_table(res.assy_item_id).average_demand;
    ELSE  -- a new one
      -- finalize the previous one
      l_std_op_id := l_res_detail_table(l_index-1).standard_operation_id;
      IF (l_resource_needed > 0) and
	 (l_process_lop_table(l_std_op_id).process_volume > 0) THEN
        l_res_detail_table(l_index-1).resource_needed :=
	  l_resource_needed/l_process_lop_table(l_std_op_id).process_volume/
	  l_process_lop_table(l_std_op_id).process_takt;
      ELSE
        l_res_detail_table(l_index-1).resource_needed := 0;
      END IF;
      l_res_detail_table(l_index).resource_id := res.resource_id;
      -- l_res_detail_table(l_index).resource_code := res.resource_code;
      l_res_detail_table(l_index).activity_id := res.activity_id;
      l_res_detail_table(l_index).standard_operation_id := res.std_op_id;
      l_resource_needed := res.resource_needed * l_demand_table(res.assy_item_id).average_demand;
      --l_demand_sum := l_demand_table(res.assy_item_id).average_demand;
      l_index := l_index + 1;
    end if;
  END LOOP;
  -- The last one
  l_std_op_id := l_res_detail_table(l_index-1).standard_operation_id;
  IF (l_resource_needed > 0) and
     (l_process_lop_table(l_std_op_id).process_volume > 0) THEN
    l_res_detail_table(l_index-1).resource_needed :=
	l_resource_needed/l_process_lop_table(l_std_op_id).process_volume/
	l_process_lop_table(l_std_op_id).process_takt;
  ELSE
    l_res_detail_table(l_index-1).resource_needed := 0;
  END IF;
  -- Write to Table
  l_stmt_num := 4;
  l_index := l_res_detail_table.FIRST;
  LOOP
    if l_res_detail_table(l_index).activity_id <> -1 then
      insert into BOM_MIXED_MODEL_MAP_RES (
	mixed_model_map_id,
	resource_id,
	resource_code,
	activity_id,
	activity,
	standard_operation_id,
	operation_code,
	resource_type,
	organization_id,
	resource_needed
        )
      select
	p_mmm_id,
	l_res_detail_table(l_index).resource_id,
	br.resource_code,
	l_res_detail_table(l_index).activity_id,
	ca.activity,
	l_res_detail_table(l_index).standard_operation_id,
	bso.operation_code,
	br.resource_type,
	p_org_id,
	l_res_detail_table(l_index).resource_needed
      from cst_activities ca,
	 bom_standard_operations bso,
	 bom_resources br
      where ca.activity_id = l_res_detail_table(l_index).activity_id
        and bso.standard_operation_id = l_res_detail_table(l_index).standard_operation_id
        and br.resource_id = l_res_detail_table(l_index).resource_id;
    else
      insert into BOM_MIXED_MODEL_MAP_RES (
	mixed_model_map_id,
	resource_id,
	resource_code,
	activity_id,
	activity,
	standard_operation_id,
	operation_code,
	resource_type,
	organization_id,
	resource_needed
        )
      select
	p_mmm_id,
	l_res_detail_table(l_index).resource_id,
	br.resource_code,
	null,
	null,
	l_res_detail_table(l_index).standard_operation_id,
	bso.operation_code,
	br.resource_type,
	p_org_id,
	l_res_detail_table(l_index).resource_needed
      from bom_standard_operations bso,
	 bom_resources br
      where bso.standard_operation_id = l_res_detail_table(l_index).standard_operation_id
        and br.resource_id = l_res_detail_table(l_index).resource_id;
    end if;
    EXIT WHEN l_index = l_res_detail_table.LAST;
    l_index := l_res_detail_table.NEXT(l_index);
  END LOOP;
  l_stmt_num := 5;
  --commit;
END GetDetails;


-- =============================== GetCells =================================
--
-- NAME	      :  GetCells
-- DESCRIPTION:  Get Products for a given Line (and Family if the Family is
--		 specified by the user).  Calculates the Demand for each
--		 Product. Calculates Machine Time, Labor Time, Total Time
--		 and Process Volume for each of the 5 Processes/Line Ops
--		 passed to this procedure.
--
--               Insert these values into the table BOM_MIXED_MODEL_MAP_CELLS.
-- REQUIRES   :  err_text    out buffer to return error message
-- MODIFIES   :  BOM_MIXED_MODEL_MAP_CELLS
--
-- ==========================================================================

PROCEDURE GetCells (
    p_mmm_id		NUMBER,
    p_group_number      NUMBER,
    p_line_id		NUMBER,
    p_family_item_id	NUMBER,
    p_org_id		NUMBER,
    p_user_id		NUMBER,
    p_start_date	DATE,
    p_end_date		DATE,
    p_demand_type	NUMBER,
    p_demand_code	VARCHAR2,
    p_process_line_op	NUMBER,
    p_hours_per_day	NUMBER,
    p_demand_days	NUMBER,
    p_boost_percent	NUMBER,
    p_operation_type	NUMBER,
    p_time_type		NUMBER,
    p_ipk_value		NUMBER,
    p_time_uom		NUMBER,
    p_calendar_code	VARCHAR2,
    p_exception_set_id  NUMBER,
    p_last_calendar_date DATE,
    p_op_code1		VARCHAR2,
    p_op_code2		VARCHAR2,
    p_op_code3		VARCHAR2,
    p_op_code4		VARCHAR2,
    p_op_code5		VARCHAR2,
    x_line_takt    OUT  NOCOPY	NUMBER,
    x_err_text     OUT  NOCOPY	VARCHAR2) IS

    CURSOR GetProducts IS
       SELECT assembly_item_id AII
         FROM bom_operational_routings bor
        WHERE mixed_model_map_flag = 1
	  AND line_id = p_line_id
          AND organization_id = p_org_id
          AND (p_family_item_id is null
               OR
               EXISTS (SELECT 'x'
			 FROM mtl_system_items msi
			WHERE msi.inventory_item_id = bor.assembly_item_id
			  AND msi.organization_id = p_org_id
			  AND msi.product_family_item_id = p_family_item_id))
      ORDER BY assembly_item_id;

   CURSOR CheckForProcessSavedMap IS
      SELECT mixed_model_map_id
        FROM bom_mixed_model_map_header
       WHERE line_id = p_line_id
	 AND ((p_family_item_id is NULL AND family_item_id is NULL)
	      OR (family_item_id = p_family_item_id))
	 AND organization_id = p_org_id
         AND process_or_lineop = G_PROCESS;

   CURSOR CheckForLineopSavedMap IS
      SELECT mixed_model_map_id
        FROM bom_mixed_model_map_header
       WHERE line_id = p_line_id
	 AND ((p_family_item_id is NULL AND family_item_id is NULL)
	      OR (family_item_id = p_family_item_id))
	 AND organization_id = p_org_id
         AND process_or_lineop = G_LINEOP;

      l_stmt_num	NUMBER;
      l_counter		NUMBER := 0;
      l_demand		NUMBER := 0;
      l_demand_for_display    NUMBER := 0;
      l_rec_demand	NUMBER := 0;
      l_forecast_days   NUMBER;
      l_mdsmps_days     NUMBER;
      l_prorated_days   NUMBER;
      l_forecast_demand NUMBER;
      l_mdsmps_demand   NUMBER;
      l_last_week_day   DATE;
      l_last_period_day DATE;
      l_mmm_id		NUMBER;
      l_line_takt	NUMBER;

      l_demand_total	NUMBER := 0;
      l_machine_time    NUMBER;
      l_labor_time	NUMBER;
      l_total_time	NUMBER;
      l_process_volume  NUMBER;
      l_process_volume_for_display      NUMBER;
      l_op_code		VARCHAR2(4);

/*
      l_total_machines1 NUMBER;
      l_total_machines2 NUMBER;
      l_total_machines3 NUMBER;
      l_total_machines4 NUMBER;
      l_total_machines5 NUMBER;
*/

      l_machine_at1     NUMBER := 0;
      l_machine_wt1     NUMBER := 0;
      l_labor_at1       NUMBER := 0;
      l_labor_wt1       NUMBER := 0;
      l_total_at1       NUMBER := 0;
      l_total_wt1	NUMBER := 0;
      l_process_volume1 NUMBER := 0;
      l_takt1		NUMBER := 0;
      l_machines_needed1 NUMBER := 0;
      l_labor_needed1   NUMBER := 0;
      l_ipk1		NUMBER := 0;

      l_machine_at2     NUMBER := 0;
      l_machine_wt2     NUMBER := 0;
      l_labor_at2       NUMBER := 0;
      l_labor_wt2       NUMBER := 0;
      l_total_at2       NUMBER := 0;
      l_total_wt2	NUMBER := 0;
      l_process_volume2 NUMBER := 0;
      l_takt2		NUMBER := 0;
      l_machines_needed2 NUMBER := 0;
      l_labor_needed2   NUMBER := 0;
      l_ipk2		NUMBER := 0;

      l_machine_at3     NUMBER := 0;
      l_machine_wt3     NUMBER := 0;
      l_labor_at3       NUMBER := 0;
      l_labor_wt3       NUMBER := 0;
      l_total_at3       NUMBER := 0;
      l_total_wt3	NUMBER := 0;
      l_process_volume3 NUMBER := 0;
      l_takt3		NUMBER := 0;
      l_machines_needed3 NUMBER := 0;
      l_labor_needed3   NUMBER := 0;
      l_ipk3		NUMBER := 0;

      l_machine_at4     NUMBER := 0;
      l_machine_wt4     NUMBER := 0;
      l_labor_at4       NUMBER := 0;
      l_labor_wt4       NUMBER := 0;
      l_total_at4       NUMBER := 0;
      l_total_wt4	NUMBER := 0;
      l_process_volume4 NUMBER := 0;
      l_takt4		NUMBER := 0;
      l_machines_needed4 NUMBER := 0;
      l_labor_needed4   NUMBER := 0;
      l_ipk4		NUMBER := 0;

      l_machine_at5     NUMBER := 0;
      l_machine_wt5     NUMBER := 0;
      l_labor_at5       NUMBER := 0;
      l_labor_wt5       NUMBER := 0;
      l_total_at5       NUMBER := 0;
      l_total_wt5	NUMBER := 0;
      l_process_volume5 NUMBER := 0;
      l_takt5		NUMBER := 0;
      l_machines_needed5 NUMBER := 0;
      l_labor_needed5   NUMBER := 0;
      l_ipk5		NUMBER := 0;

      l_mn_saved	NUMBER;
      l_ln_saved 	NUMBER;
      l_ipk_saved1	NUMBER;
      l_ipk_saved2	NUMBER;
      l_ipk_saved3	NUMBER;
      l_ipk_saved4	NUMBER;
      l_ipk_saved5	NUMBER;

      l_mn_delta1 	NUMBER;
      l_ln_delta1	NUMBER;
      l_ipk_delta1	NUMBER;
      l_mn_delta2 	NUMBER;
      l_ln_delta2	NUMBER;
      l_ipk_delta2	NUMBER;
      l_mn_delta3	NUMBER;
      l_ln_delta3	NUMBER;
      l_ipk_delta3	NUMBER;
      l_mn_delta4 	NUMBER;
      l_ln_delta4	NUMBER;
      l_ipk_delta4	NUMBER;
      l_mn_delta5 	NUMBER;
      l_ln_delta5	NUMBER;
      l_ipk_delta5	NUMBER;
--below is new code
l_mc_res_dept1 dept_id_type;
l_mc_res_dept2 dept_id_type;
l_mc_res_dept3 dept_id_type;
l_mc_res_dept4 dept_id_type;
l_mc_res_dept5 dept_id_type;
l_machine_resource1 resource_id_type;
l_machine_resource2 resource_id_type;
l_machine_resource3 resource_id_type;
l_machine_resource4 resource_id_type;
l_machine_resource5 resource_id_type;
l_lb_res_dept1 dept_id_type;
l_lb_res_dept2 dept_id_type;
l_lb_res_dept3 dept_id_type;
l_lb_res_dept4 dept_id_type;
l_lb_res_dept5 dept_id_type;
l_labor_resource1 resource_id_type;
l_labor_resource2 resource_id_type;
l_labor_resource3 resource_id_type;
l_labor_resource4 resource_id_type;
l_labor_resource5 resource_id_type;

l_mc_res_index1 NUMBER := 1;
l_mc_res_index2 NUMBER := 1;
l_mc_res_index3 NUMBER := 1;
l_mc_res_index4 NUMBER := 1;
l_mc_res_index5 NUMBER := 1;
l_lb_res_index1 NUMBER := 1;
l_lb_res_index2 NUMBER := 1;
l_lb_res_index3 NUMBER := 1;
l_lb_res_index4 NUMBER := 1;
l_lb_res_index5 NUMBER := 1;
l_mc_assigned1 NUMBER := 0;
l_mc_assigned2 NUMBER := 0;
l_mc_assigned3 NUMBER := 0;
l_mc_assigned4 NUMBER := 0;
l_mc_assigned5 NUMBER := 0;
l_lb_assigned1 NUMBER := 0;
l_lb_assigned2 NUMBER := 0;
l_lb_assigned3 NUMBER := 0;
l_lb_assigned4 NUMBER := 0;
l_lb_assigned5 NUMBER := 0;
l_takt_time_for_mc_assigned1 NUMBER := 0;
l_takt_time_for_mc_assigned2 NUMBER := 0;
l_takt_time_for_mc_assigned3 NUMBER := 0;
l_takt_time_for_mc_assigned4 NUMBER := 0;
l_takt_time_for_mc_assigned5 NUMBER := 0;
l_takt_time_for_lb_assigned1 NUMBER := 0;
l_takt_time_for_lb_assigned2 NUMBER := 0;
l_takt_time_for_lb_assigned3 NUMBER := 0;
l_takt_time_for_lb_assigned4 NUMBER := 0;
l_takt_time_for_lb_assigned5 NUMBER := 0;
l_takt_time_for_assigned1 NUMBER := 0;
l_takt_time_for_assigned2 NUMBER := 0;
l_takt_time_for_assigned3 NUMBER := 0;
l_takt_time_for_assigned4 NUMBER := 0;
l_takt_time_for_assigned5 NUMBER := 0;
--above is new code
BEGIN

-- GET PRODUCTS

   l_stmt_num := 1;

   FOR c1rec IN GetProducts LOOP
      l_stmt_num := 2;
      l_demand   := 0;
      l_demand_for_display   := 0;
      l_rec_demand   := 0;
      l_counter := l_counter + 1;

      -- GET DEMAND
      GetDemand (
	p_org_id,
	p_demand_type,
	p_line_id,
	c1rec.AII,
	p_calendar_code,
	p_start_date,
	p_end_date,
    	p_last_calendar_date,
        p_exception_set_id,
	p_demand_code,
	l_demand,
	l_stmt_num);

      l_demand_total := l_demand_total + l_demand;
      l_demand_for_display := (l_demand / p_demand_days) *
      (1 + nvl((p_boost_percent * .01), 0));

      -- GET CELL VALUES

      l_stmt_num := 58;

      -- LOOP THRU OPS 1 THRU 5

      FOR i IN 1..5 LOOP
         l_machine_time   := 0;
         l_labor_time     := 0;
         l_total_time     := 0;
         l_process_volume := 0;

         IF (i = 1) THEN
            l_op_code := p_op_code1;
         ELSIF (i = 2) THEN
            l_op_code := p_op_code2;
         ELSIF (i = 3) THEN
            l_op_code := p_op_code3;
         ELSIF (i = 4) THEN
            l_op_code := p_op_code4;
         ELSIF (i = 5) THEN
            l_op_code := p_op_code5;
         END IF;

         -- GET CELL VALUES: MACHINE TIME, LABOR TIME, TOTAL TIME

         l_stmt_num := 59;
         DECLARE
            CURSOR GetCellValues IS
               SELECT sum(decode(p_time_type, G_USER_CALC, machine_time_user,
		   	  machine_time_calc)) machine_time,
		      sum(decode(p_time_type, G_USER_CALC, labor_time_user,
		   	  labor_time_calc)) labor_time,
		      sum(decode(p_time_type, G_USER_CALC, total_time_user,
		   	  total_time_calc)) total_time,
                      ((1 + nvl((p_boost_percent * .01), 0)) *
                      nvl((1/(avg(decode(nvl(reverse_cumulative_yield, 1),0,1,nvl(reverse_cumulative_yield,1))))),1) *
		      nvl(avg(nvl((net_planning_percent * .01), 1)),1) * l_demand)
		      process_volume
                 FROM bom_standard_operations bso,
	   	      bom_operation_sequences bos,
		      bom_operational_routings bor
                WHERE bor.assembly_item_id = c1rec.AII
	          AND bor.mixed_model_map_flag = 1
	          AND bor.organization_id = p_org_id
	          AND bor.line_id = p_line_id
   	          AND bor.common_routing_sequence_id = bos.routing_sequence_id
	          AND bos.standard_operation_id = bso.standard_operation_id
                  AND NVL(bos.eco_for_production,2) = 2
	          AND bso.operation_code = l_op_code
                  AND bso.organization_id = p_org_id
                  AND bso.line_id = p_line_id
                  ANd bso.operation_type = p_operation_type;

         BEGIN
            IF (l_op_code is NULL) THEN
               GOTO insert_record;
            END IF;

            l_stmt_num := 60;
            FOR c3rec IN GetCellValues LOOP
               l_machine_time := nvl(c3rec.machine_time, 0);
               l_labor_time := nvl(c3rec.labor_time, 0);
	       l_total_time := nvl(c3rec.total_time, 0);
               l_process_volume := nvl(c3rec.process_volume, 0);
            END LOOP;

/**/
      l_process_volume_for_display := l_process_volume / p_demand_days ;
/**/

            -- CALCULATE SUMMARY VALUES

            l_stmt_num := 62;
            IF (i = 1) THEN
               l_machine_at1 := l_machine_at1 +
                                (l_machine_time * l_process_volume);
               l_labor_at1 := l_labor_at1 +
                                (l_labor_time * l_process_volume);
               l_total_at1 := l_total_at1 +
                                (l_total_time * l_process_volume);
               l_process_volume1 := l_process_volume1 + l_process_volume;

               IF (nvl(l_process_volume1, 0) = 0) THEN
                  l_machine_wt1 := 0;
                  l_labor_wt1 := 0;
		  l_total_wt1 := 0;
		  l_takt1 := null;
               ELSE
  	          l_machine_wt1 := l_machine_at1/l_process_volume1;
  	          l_labor_wt1 := l_labor_at1/l_process_volume1;
	          l_total_wt1 := l_total_at1/l_process_volume1;
                  l_takt1 := (p_hours_per_day * p_demand_days)/
			     l_process_volume1;
               END IF;

               IF (nvl(l_takt1, 0) = 0) THEN
    	          l_machines_needed1 := null;
 	          l_labor_needed1 := null;
               ELSE
    	          l_machines_needed1 := l_machine_wt1/l_takt1;
 	          l_labor_needed1 := l_labor_wt1/l_takt1;
	       END IF;
            ELSIF (i = 2) THEN
               l_stmt_num := 63;
               l_machine_at2 := l_machine_at2 +
                                (l_machine_time * l_process_volume);
               l_labor_at2 := l_labor_at2 +
                                (l_labor_time * l_process_volume);
               l_total_at2 := l_total_at2 +
                                (l_total_time * l_process_volume);
               l_process_volume2 := l_process_volume2 + l_process_volume;

               IF (nvl(l_process_volume2, 0) = 0) THEN
                  l_machine_wt2 := 0;
                  l_labor_wt2 := 0;
		  l_total_wt2 := 0;
		  l_takt2 := null;
               ELSE
  	          l_machine_wt2 := l_machine_at2/l_process_volume2;
  	          l_labor_wt2 := l_labor_at2/l_process_volume2;
	          l_total_wt2 := l_total_at2/l_process_volume2;
                  l_takt2 := (p_hours_per_day * p_demand_days)/
			     l_process_volume2;
               END IF;

               IF (nvl(l_takt2, 0) = 0) THEN
    	          l_machines_needed2 := null;
 	          l_labor_needed2 := null;
               ELSE
    	          l_machines_needed2 := l_machine_wt2/l_takt2;
 	          l_labor_needed2 := l_labor_wt2/l_takt2;
	       END IF;
            ELSIF (i = 3) THEN
               l_stmt_num := 64;
               l_machine_at3 := l_machine_at3 +
                                (l_machine_time * l_process_volume);
               l_labor_at3 := l_labor_at3 +
                                (l_labor_time * l_process_volume);
               l_total_at3 := l_total_at3 +
                                (l_total_time * l_process_volume);
               l_process_volume3 := l_process_volume3 + l_process_volume;

               IF (nvl(l_process_volume3, 0) = 0) THEN
                  l_machine_wt3 := 0;
                  l_labor_wt3 := 0;
		  l_total_wt3 := 0;
		  l_takt3 := null;
               ELSE
  	          l_machine_wt3 := l_machine_at3/l_process_volume3;
  	          l_labor_wt3 := l_labor_at3/l_process_volume3;
	          l_total_wt3 := l_total_at3/l_process_volume3;
                  l_takt3 := (p_hours_per_day * p_demand_days)/
			     l_process_volume3;
               END IF;

               IF (nvl(l_takt3, 0) = 0) THEN
    	          l_machines_needed3 := null;
 	          l_labor_needed3 := null;
               ELSE
    	          l_machines_needed3 := l_machine_wt3/l_takt3;
 	          l_labor_needed3 := l_labor_wt3/l_takt3;
	       END IF;
            ELSIF (i = 4) THEN
               l_stmt_num := 65;
               l_machine_at4 := l_machine_at4 +
                                (l_machine_time * l_process_volume);
               l_labor_at4 := l_labor_at4 +
                                (l_labor_time * l_process_volume);
               l_total_at4 := l_total_at4 +
                                (l_total_time * l_process_volume);
               l_process_volume4 := l_process_volume4 + l_process_volume;

               IF (nvl(l_process_volume4, 0) = 0) THEN
                  l_machine_wt4 := 0;
                  l_labor_wt4 := 0;
		  l_total_wt4 := 0;
		  l_takt4 := null;
               ELSE
  	          l_machine_wt4 := l_machine_at4/l_process_volume4;
  	          l_labor_wt4 := l_labor_at4/l_process_volume4;
	          l_total_wt4 := l_total_at4/l_process_volume4;
                  l_takt4 := (p_hours_per_day * p_demand_days)/
		 	     l_process_volume4;
               END IF;

               IF (nvl(l_takt4, 0) = 0) THEN
    	          l_machines_needed4 := null;
 	          l_labor_needed4 := null;
               ELSE
    	          l_machines_needed4 := l_machine_wt4/l_takt4;
 	          l_labor_needed4 := l_labor_wt4/l_takt4;
	       END IF;
            ELSIF (i = 5) THEN
               l_stmt_num := 66;
               l_machine_at5 := l_machine_at5 +
                                (l_machine_time * l_process_volume);
               l_labor_at5 := l_labor_at5 +
                                (l_labor_time * l_process_volume);
               l_total_at5 := l_total_at5 +
                                (l_total_time * l_process_volume);
               l_process_volume5 := l_process_volume5 + l_process_volume;

               IF (nvl(l_process_volume5, 0) = 0) THEN
                  l_machine_wt5 := 0;
                  l_labor_wt5 := 0;
		  l_total_wt5 := 0;
		  l_takt5 := null;
               ELSE
  	          l_machine_wt5 := l_machine_at5/l_process_volume5;
  	          l_labor_wt5 := l_labor_at5/l_process_volume5;
	          l_total_wt5 := l_total_at5/l_process_volume5;
                  l_takt5 := (p_hours_per_day * p_demand_days)/
			     l_process_volume5;
               END IF;

               IF (nvl(l_takt5, 0) = 0) THEN
    	          l_machines_needed5 := null;
 	          l_labor_needed5 := null;
               ELSE
    	          l_machines_needed5 := l_machine_wt5/l_takt5;
 	          l_labor_needed5 := l_labor_wt5/l_takt5;
	       END IF;
	    END IF;

            -- INSERT CELL RECORD INTO TABLE
            l_stmt_num := 67;
            l_machine_time := ConvertTime(l_machine_time, p_time_uom);
            l_labor_time := ConvertTime(l_labor_time, p_time_uom);
            l_total_time := ConvertTime(l_total_time, p_time_uom);

            -- below is my code

            IF (i = 1) THEN
              -- for machine resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					1,
    					l_op_code,
                		p_process_line_op,
    					l_mc_res_index1,
    	        			l_mc_res_dept1,
    	        			l_machine_resource1);

              -- for labor resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					2,
    					l_op_code,
                		p_process_line_op,
    					l_lb_res_index1,
    	        			l_lb_res_dept1,
    					l_labor_resource1);

            ELSIF (i = 2) THEN
              -- for machine resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					1,
    					l_op_code,
                		p_process_line_op,
    					l_mc_res_index2,
    	        			l_mc_res_dept2,
    					l_machine_resource2);
              -- for labor resource
              GetResourceId(
    		c1rec.AII,
    					p_org_id,
    					p_line_id,
    					2,
    					l_op_code,
                		p_process_line_op,
    					l_lb_res_index2,
    	        			l_lb_res_dept2,
    					l_labor_resource2);

            ELSIF (i = 3) THEN
              -- for machine resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					1,
    					l_op_code,
                		p_process_line_op,
    					l_mc_res_index3,
    	        			l_mc_res_dept3,
    					l_machine_resource3);
              -- for labor resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					2,
    					l_op_code,
                		p_process_line_op,
    					l_lb_res_index3,
    	        			l_lb_res_dept3,
    					l_labor_resource3);

            ELSIF (i = 4) THEN
              -- for machine resource
             GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					1,
    					l_op_code,
                		p_process_line_op,
    					l_mc_res_index4,
    	        			l_mc_res_dept4,
    					l_machine_resource4);
              -- for labor resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					2,
    					l_op_code,
                		p_process_line_op,
    					l_lb_res_index4,
    	        			l_lb_res_dept4,
    					l_labor_resource4);

            ELSIF (i = 5) THEN
              -- for machine resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					1,
    					l_op_code,
                		p_process_line_op,
    					l_mc_res_index5,
    	        			l_mc_res_dept5,
    					l_machine_resource5);
              -- for labor resource
              GetResourceId(
    					c1rec.AII,
    					p_org_id,
    					p_line_id,
    					2,
    					l_op_code,
                		p_process_line_op,
    					l_lb_res_index5,
    	        			l_lb_res_dept5,
    					l_labor_resource5);

            END IF; --END 5 LOOPS FOR RESOURCES
            -- above is my code***************************************
	    <<insert_record>>
            l_stmt_num := 68;
          IF(l_op_code IS NOT NULL) THEN
  	    INSERT INTO bom_mixed_model_map_cells
               (MIXED_MODEL_MAP_ID,
	        GROUP_NUMBER,
                SEQUENCE_ID,
                PRODUCT_ITEM_ID,
         	DEMAND,
	        MACHINE_TIME,
	        LABOR_TIME,
	        TOTAL_TIME,
	        PROCESS_VOLUME,
	        CREATED_BY,
	        CREATION_DATE,
	        LAST_UPDATED_BY,
	        LAST_UPDATE_DATE)
             VALUES
                (p_mmm_id,
                 p_group_number,
                 i,
                 c1rec.AII,
                 ROUND(nvl(l_demand_for_display, 0), G_DECIMAL),
	         ROUND(nvl(l_machine_time, 0), G_DECIMAL),
	         ROUND(nvl(l_labor_time, 0), G_DECIMAL),
	         ROUND(nvl(l_total_time, 0), G_DECIMAL),
		 ROUND(nvl(l_process_volume_for_display, 0), G_DECIMAL),
	         p_user_id,
	         sysdate,
	         p_user_id,
	         sysdate);
          ELSE
	    INSERT INTO bom_mixed_model_map_cells
               (MIXED_MODEL_MAP_ID,
	        GROUP_NUMBER,
                SEQUENCE_ID,
                PRODUCT_ITEM_ID,
         	DEMAND,
	        MACHINE_TIME,
	        LABOR_TIME,
	        TOTAL_TIME,
	        PROCESS_VOLUME,
	        CREATED_BY,
	        CREATION_DATE,
	        LAST_UPDATED_BY,
	        LAST_UPDATE_DATE)
             VALUES
                (p_mmm_id,
                 p_group_number,
                 i,
                 c1rec.AII,
                 ROUND(nvl(l_demand_for_display, 0), G_DECIMAL),
	         null,
	         null,
	         null,
		 null,
	         p_user_id,
	         sysdate,
	         p_user_id,
	         sysdate);
           END IF;
         END;
      END LOOP;  -- FOR i IN 1..5
   END LOOP;     -- GetProducts

--below is new code
   -- for Capacity
   GetCapacity(
        l_mc_res_index1,
        l_machine_resource1,
    	l_mc_res_dept1,
        l_mc_assigned1);

   GetCapacity(
    	l_lb_res_index1,
    	l_labor_resource1,
    	l_lb_res_dept1,
    	l_lb_assigned1);
   GetCapacity(
    	l_mc_res_index2,
    	l_machine_resource2,
    	l_mc_res_dept2,
    	l_mc_assigned2);

   GetCapacity(
    	l_lb_res_index2,
    	l_labor_resource2,
    	l_lb_res_dept2,
    	l_lb_assigned2);
   GetCapacity(
   	l_mc_res_index3,
   	l_machine_resource3,
    	l_mc_res_dept3,
   	l_mc_assigned3);

   GetCapacity(
    	l_lb_res_index3,
    	l_labor_resource3,
    	l_lb_res_dept3,
    	l_lb_assigned3);
    GetCapacity(
    	l_mc_res_index4,
    	l_machine_resource4,
    	l_mc_res_dept4,
    	l_mc_assigned4);

    GetCapacity(
    	l_lb_res_index4,
    	l_labor_resource4,
    	l_lb_res_dept4,
    	l_lb_assigned4);
    GetCapacity(
    	l_mc_res_index5,
    	l_machine_resource5,
    	l_mc_res_dept5,
    	l_mc_assigned5);

    GetCapacity(
    	l_lb_res_index5,
    	l_labor_resource5,
    	l_lb_res_dept5,
    	l_lb_assigned5);
  -- calculate assigned TAKT time for first process/lineOp
  IF (nvl(l_machine_wt1, 0) = 0) OR
    (nvl(l_mc_assigned1, 0) = 0) THEN
    l_takt_time_for_mc_assigned1 := 0;
  ELSE
    l_takt_time_for_mc_assigned1 := l_machine_wt1/l_mc_assigned1;
  END IF;
  IF (nvl(l_labor_wt1, 0) = 0) OR
    (nvl(l_lb_assigned1, 0) = 0) THEN
    l_takt_time_for_lb_assigned1 := 0;
  ELSE
   l_takt_time_for_lb_assigned1 := l_labor_wt1/l_lb_assigned1;
  END IF;
  IF (l_takt_time_for_mc_assigned1 >= l_takt_time_for_lb_assigned1 ) THEN
    l_takt_time_for_assigned1 := l_takt_time_for_mc_assigned1;
  ELSE
    l_takt_time_for_assigned1 := l_takt_time_for_lb_assigned1;
  END IF;
  -- calculate assigned TAKT time for second process/lineOp
  IF (nvl(l_machine_wt2, 0) = 0) OR
    (nvl(l_mc_assigned2, 0) = 0) THEN
    l_takt_time_for_mc_assigned2 := 0;
  ELSE
    l_takt_time_for_mc_assigned2 := l_machine_wt2/l_mc_assigned2;
  END IF;
  IF (nvl(l_labor_wt2, 0) = 0) OR
    (nvl(l_lb_assigned2, 0) = 0) THEN
    l_takt_time_for_lb_assigned2 := 0;
  ELSE
    l_takt_time_for_lb_assigned2 := l_labor_wt2/l_lb_assigned2;
  END IF;
  IF (l_takt_time_for_mc_assigned2 >= l_takt_time_for_lb_assigned2 ) THEN
    l_takt_time_for_assigned2 := l_takt_time_for_mc_assigned2;
  ELSE
    l_takt_time_for_assigned2 := l_takt_time_for_lb_assigned2;
  END IF;
  -- calculate assigned TAKT time for third process/lineOp
  IF (nvl(l_machine_wt3, 0) = 0) OR
    (nvl(l_mc_assigned3, 0) = 0) THEN
    l_takt_time_for_mc_assigned3 := 0;
  ELSE
    l_takt_time_for_mc_assigned3 := l_machine_wt3/l_mc_assigned3;
  END IF;
  IF (nvl(l_labor_wt3, 0) = 0) OR
    (nvl(l_lb_assigned3, 0) = 0) THEN
    l_takt_time_for_lb_assigned3 := 0;
  ELSE
    l_takt_time_for_lb_assigned3 := l_labor_wt3/l_lb_assigned3;
  END IF;
  IF (l_takt_time_for_mc_assigned3 >= l_takt_time_for_lb_assigned3 ) THEN
    l_takt_time_for_assigned3 := l_takt_time_for_mc_assigned3;
  ELSE
    l_takt_time_for_assigned3 := l_takt_time_for_lb_assigned3;
  END IF;
  -- calculate assigned TAKT time for fourth process/lineOp
  IF (nvl(l_machine_wt4, 0) = 0) OR
    (nvl(l_mc_assigned4, 0) = 0) THEN
    l_takt_time_for_mc_assigned4 := 0;
  ELSE
    l_takt_time_for_mc_assigned4 := l_machine_wt4/l_mc_assigned4;
  END IF;
  IF (nvl(l_labor_wt4, 0) = 0) OR
    (nvl(l_lb_assigned4, 0) = 0) THEN
    l_takt_time_for_lb_assigned4 := 0;
  ELSE
    l_takt_time_for_lb_assigned4 := l_labor_wt4/l_lb_assigned4;
  END IF;
  IF (l_takt_time_for_mc_assigned4 >= l_takt_time_for_lb_assigned4 ) THEN
    l_takt_time_for_assigned4 := l_takt_time_for_mc_assigned4;
  ELSE
    l_takt_time_for_assigned4 := l_takt_time_for_lb_assigned4;
  END IF;
  -- calculate assigned TAKT time for fifth process/lineOp
  IF (nvl(l_machine_wt5, 0) = 0) OR
    (nvl(l_mc_assigned5, 0) = 0) THEN
    l_takt_time_for_mc_assigned5 := 0;
  ELSE
    l_takt_time_for_mc_assigned5 := l_machine_wt3/l_mc_assigned5;
  END IF;
  IF (nvl(l_labor_wt5, 0) = 0) OR
    (nvl(l_lb_assigned5, 0) = 0) THEN
    l_takt_time_for_lb_assigned5 := 0;
  ELSE
    l_takt_time_for_lb_assigned5 := l_labor_wt5/l_lb_assigned5;
  END IF;
  IF (l_takt_time_for_mc_assigned5 >= l_takt_time_for_lb_assigned5 ) THEN
    l_takt_time_for_assigned5 := l_takt_time_for_mc_assigned5;
  ELSE
    l_takt_time_for_assigned5 := l_takt_time_for_lb_assigned5;
  END IF;
--above is new code
  -- GET LINE TAKT TIME
   l_stmt_num := 69;
   IF (nvl(l_demand_total, 0) = 0) THEN
      x_err_text := 'BOM_LINE_TAKT_ERROR';
      l_line_takt := null;
      x_line_takt := l_line_takt;
   ELSE
      l_line_takt := ConvertTime(p_hours_per_day/
 		     ((l_demand_total/p_demand_days)*(1 +
			nvl((p_boost_percent * .01), 0))), p_time_uom);
      x_line_takt := ROUND(l_line_takt, G_DECIMAL);

   END IF;

-- CALCULATE DELTA VALUES

   -- CHECK IF SAVED MAP EXISTS
   l_stmt_num := 70;
   IF (p_process_line_op = G_PROCESS) THEN
      FOR c5rec IN CheckForProcessSavedMap LOOP
         l_mmm_id := c5rec.mixed_model_map_id;
      END LOOP;
   ELSE
      l_stmt_num := 71;
      FOR c6rec IN CheckForLineOpSavedMap LOOP
         l_mmm_id := c6rec.mixed_model_map_id;
      END LOOP;
   END IF;

   -- SAVED MAP EXISTS

   IF (l_mmm_id is NOT NULL) THEN
      IF (p_op_code1 is NOT NULL) THEN
         DECLARE
            CURSOR GetSavedValues IS
                  SELECT machines_needed MN, labor_needed LN,
			 in_process_kanban IPK
	            FROM bom_mixed_model_map_processes
	           WHERE mixed_model_map_id = l_mmm_id
	             AND operation_code = p_op_code1;
         BEGIN
            l_stmt_num := 72;
            l_mn_saved := null;
            l_ln_saved := null;
            l_ipk_saved1 := null;
            FOR c7rec IN GetSavedValues LOOP
               l_mn_saved := c7rec.MN;
               l_ln_saved := c7rec.LN;
               l_ipk_saved1 := c7rec.IPK;
            END LOOP;

            l_mn_delta1 := nvl(l_machines_needed1, 0) - l_mn_saved;
            l_ln_delta1 := nvl(l_labor_needed1, 0) - l_ln_saved;
         END;
      END IF;

      IF (p_op_code2 is NOT NULL) THEN
         DECLARE
            CURSOR GetSavedValues IS
                  SELECT machines_needed MN, labor_needed LN,
			 in_process_kanban IPK
	            FROM bom_mixed_model_map_processes
	           WHERE mixed_model_map_id = l_mmm_id
	             AND operation_code = p_op_code2;
         BEGIN
            l_stmt_num := 73;
            l_mn_saved := null;
            l_ln_saved := null;
            l_ipk_saved2 := null;
            FOR c8rec IN GetSavedValues LOOP
               l_mn_saved := c8rec.MN;
               l_ln_saved := c8rec.LN;
               l_ipk_saved2 := c8rec.IPK;
            END LOOP;

            l_mn_delta2 := nvl(l_machines_needed2, 0) - l_mn_saved;
            l_ln_delta2 := nvl(l_labor_needed2, 0) - l_ln_saved;
         END;
      END IF;

      IF (p_op_code3 is NOT NULL) THEN
         DECLARE
            CURSOR GetSavedValues IS
                  SELECT machines_needed MN, labor_needed LN,
			 in_process_kanban IPK
	            FROM bom_mixed_model_map_processes
	           WHERE mixed_model_map_id = l_mmm_id
	             AND operation_code = p_op_code3;
         BEGIN
            l_stmt_num := 74;
            l_mn_saved := null;
            l_ln_saved := null;
            l_ipk_saved3 := null;
            FOR c9rec IN GetSavedValues LOOP
               l_mn_saved := c9rec.MN;
               l_ln_saved := c9rec.LN;
               l_ipk_saved3 := c9rec.IPK;
            END LOOP;

            l_mn_delta3 := nvl(l_machines_needed3, 0) - l_mn_saved;
            l_ln_delta3 := nvl(l_labor_needed3, 0) - l_ln_saved;
         END;
      END IF;

      IF (p_op_code4 is NOT NULL) THEN
         DECLARE
            CURSOR GetSavedValues IS
                  SELECT machines_needed MN, labor_needed LN,
			 in_process_kanban IPK
	            FROM bom_mixed_model_map_processes
	           WHERE mixed_model_map_id = l_mmm_id
	             AND operation_code = p_op_code4;
         BEGIN
            l_stmt_num := 75;
            l_mn_saved := null;
            l_ln_saved := null;
            l_ipk_saved4 := null;
            FOR c10rec IN GetSavedValues LOOP
               l_mn_saved := c10rec.MN;
               l_ln_saved := c10rec.LN;
               l_ipk_saved4 := c10rec.IPK;
            END LOOP;

            l_mn_delta4 := nvl(l_machines_needed4, 0) - l_mn_saved;
            l_ln_delta4 := nvl(l_labor_needed4, 0) - l_ln_saved;
         END;
      END IF;

      IF (p_op_code5 is NOT NULL) THEN
         DECLARE
            CURSOR GetSavedValues IS
                  SELECT machines_needed MN, labor_needed LN,
			 in_process_kanban IPK
	            FROM bom_mixed_model_map_processes
	           WHERE mixed_model_map_id = l_mmm_id
	             AND operation_code = p_op_code5;
         BEGIN
            l_stmt_num := 76;
            l_mn_saved := null;
            l_ln_saved := null;
            l_ipk_saved5 := null;
            FOR c11rec IN GetSavedValues LOOP
               l_mn_saved := c11rec.MN;
               l_ln_saved := c11rec.LN;
               l_ipk_saved5 := c11rec.IPK;
            END LOOP;

            l_mn_delta5 := nvl(l_machines_needed5, 0) - l_mn_saved;
            l_ln_delta5 := nvl(l_labor_needed5, 0) - l_ln_saved;
         END;
      END IF;
   END IF;	-- IF SAVED MAP EXISTS


   -- SAVE FINAL SUMMARY INFORMATION

   l_stmt_num := 77;
   l_machine_wt1 := ConvertTime(l_machine_wt1, p_time_uom);
   l_labor_wt1 := ConvertTime(l_labor_wt1, p_time_uom);
   l_total_wt1 := ConvertTime(l_total_wt1, p_time_uom);
   l_takt1 := ConvertTime(l_takt1, p_time_uom);

   l_machine_wt2 := ConvertTime(l_machine_wt2, p_time_uom);
   l_labor_wt2 := ConvertTime(l_labor_wt2, p_time_uom);
   l_total_wt2 := ConvertTime(l_total_wt2, p_time_uom);
   l_takt2 := ConvertTime(l_takt2, p_time_uom);

   l_machine_wt3 := ConvertTime(l_machine_wt3, p_time_uom);
   l_labor_wt3 := ConvertTime(l_labor_wt3, p_time_uom);
   l_total_wt3 := ConvertTime(l_total_wt3, p_time_uom);
   l_takt3 := ConvertTime(l_takt3, p_time_uom);

   l_machine_wt4 := ConvertTime(l_machine_wt4, p_time_uom);
   l_labor_wt4 := ConvertTime(l_labor_wt4, p_time_uom);
   l_total_wt4 := ConvertTime(l_total_wt4, p_time_uom);
   l_takt4 := ConvertTime(l_takt4, p_time_uom);

   l_machine_wt5 := ConvertTime(l_machine_wt5, p_time_uom);
   l_labor_wt5 := ConvertTime(l_labor_wt5, p_time_uom);
   l_total_wt5 := ConvertTime(l_total_wt5, p_time_uom);
   l_takt5 := ConvertTime(l_takt5, p_time_uom);

--below is new code
l_takt_time_for_assigned1 := ConvertTime(l_takt_time_for_assigned1, p_time_uom);
l_takt_time_for_assigned2 := ConvertTime(l_takt_time_for_assigned2, p_time_uom);
l_takt_time_for_assigned3 := ConvertTime(l_takt_time_for_assigned3, p_time_uom);
l_takt_time_for_assigned4 := ConvertTime(l_takt_time_for_assigned4, p_time_uom);
l_takt_time_for_assigned5 := ConvertTime(l_takt_time_for_assigned5, p_time_uom);
--above is new code
   l_stmt_num := 78;


   -- CALCULATE IPKS NEEDED

   IF (nvl(l_total_wt1, 0) = 0 OR
       nvl(l_line_takt, 0) = 0) THEN
      l_ipk1 := null;
   ELSE
      IF (p_ipk_value = G_TOTAL_IPK) OR
         (l_mc_assigned1 = 0) THEN
         l_ipk1 := ((l_total_wt1 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  		    (l_total_wt1 * l_line_takt);
      ELSE 		 -- BY MACHINE
         l_ipk1 := ((l_total_wt1 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  	            (l_total_wt1 * l_line_takt * nvl(l_mc_assigned1,1));
      END IF;
      IF (l_ipk1 < 0) THEN
         l_ipk1 := 0;
      END IF;
   END IF;


   IF (nvl(l_total_wt2, 0) = 0 OR
       nvl(l_line_takt, 0) = 0) THEN
      l_ipk2 := null;
   ELSE
      IF (p_ipk_value = G_TOTAL_IPK) OR
         (l_mc_assigned2 = 0) THEN
         l_ipk2 := ((l_total_wt2 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  		    (l_total_wt2 * l_line_takt);
      ELSE 		 -- BY MACHINE
         l_ipk2 := ((l_total_wt2 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  	            (l_total_wt2 * l_line_takt * nvl(l_mc_assigned2,1));
      END IF;
      IF (l_ipk2 < 0) THEN
         l_ipk2 := 0;
      END IF;
   END IF;

   IF (nvl(l_total_wt3, 0) = 0 OR
       nvl(l_line_takt, 0) = 0) THEN
      l_ipk3 := null;
   ELSE
      IF (p_ipk_value = G_TOTAL_IPK) OR
         (l_mc_assigned3 = 0) THEN
         l_ipk3 := ((l_total_wt3 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  		    (l_total_wt3 * l_line_takt);
      ELSE 		 -- BY MACHINE
         l_ipk3 := ((l_total_wt3 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  	            (l_total_wt3 * l_line_takt * nvl(l_mc_assigned3,1));
      END IF;
      IF (l_ipk3 < 0) THEN
         l_ipk3 := 0;
      END IF;
   END IF;

   IF (nvl(l_total_wt4, 0) = 0 OR
       nvl(l_line_takt, 0) = 0) THEN
      l_ipk4 := null;
   ELSE
      IF (p_ipk_value = G_TOTAL_IPK) OR
         (l_mc_assigned4 = 0) THEN
         l_ipk4 := ((l_total_wt4 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  		    (l_total_wt4 * l_line_takt);
      ELSE 		 -- BY MACHINE
         l_ipk4 := ((l_total_wt4 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  	            (l_total_wt4 * l_line_takt * nvl(l_mc_assigned4,1));
      END IF;
      IF (l_ipk4 < 0) THEN
         l_ipk4 := 0;
      END IF;
   END IF;

   IF (nvl(l_total_wt5, 0) = 0 OR
       nvl(l_line_takt, 0) = 0) THEN
      l_ipk5 := null;
   ELSE
      IF (p_ipk_value = G_TOTAL_IPK) OR
         (l_mc_assigned5 = 0) THEN
         l_ipk5 := ((l_total_wt5 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  		    (l_total_wt5 * l_line_takt);
      ELSE 		 -- BY MACHINE
         l_ipk5 := ((l_total_wt5 - l_line_takt) *
		     ConvertTime(p_hours_per_day, p_time_uom))/
  	            (l_total_wt5 * l_line_takt * nvl(l_mc_assigned5,1));
      END IF;
      IF (l_ipk5 < 0) THEN
         l_ipk5 := 0;
      END IF;
   END IF;

-- CALCULATE IPK DELTAS

   l_ipk_delta1 := nvl(l_ipk1, 0) - l_ipk_saved1;
   l_ipk_delta2 := nvl(l_ipk2, 0) - l_ipk_saved2;
   l_ipk_delta3 := nvl(l_ipk3, 0) - l_ipk_saved3;
   l_ipk_delta4 := nvl(l_ipk4, 0) - l_ipk_saved4;
   l_ipk_delta5 := nvl(l_ipk5, 0) - l_ipk_saved5;

-- UPDATE PROCESSES TABLE
--below code changed slightly
   UPDATE bom_mixed_model_map_processes
         SET machine_weighted_time = ROUND(nvl(l_machine_wt1, 0), G_DECIMAL),
	     labor_weighted_time   = ROUND(nvl(l_labor_wt1, 0), G_DECIMAL),
   	     total_weighted_time   = ROUND(nvl(l_total_wt1, 0), G_DECIMAL),
	     machines_needed       = ROUND(nvl(l_machines_needed1, 0), G_DECIMAL),
	     machines_assigned     = ROUND(nvl(l_mc_assigned1, 0), G_DECIMAL),
 	     labor_needed          = ROUND(nvl(l_labor_needed1, 0), G_DECIMAL),
	     labor_assigned     = ROUND(nvl(l_lb_assigned1, 0), G_DECIMAL),
	     takt_time             = ROUND(nvl(l_takt1, 0), G_DECIMAL),
	     takt_time_for_assigned  = ROUND(nvl(l_takt_time_for_assigned1, 0), G_DECIMAL),
	     in_process_kanban     = ROUND(nvl(l_ipk1, 0), G_DECIMAL),
             machines_needed_delta = ROUND(l_mn_delta1, G_DECIMAL),
	     labor_needed_delta    = ROUND(l_ln_delta1, G_DECIMAL),
             in_process_kanban_delta = ROUND(l_ipk_delta1, G_DECIMAL)
       WHERE mixed_model_map_id = p_mmm_id
         AND group_number = p_group_number
         AND sequence_id = 1 ;

   l_stmt_num := 79;
   UPDATE bom_mixed_model_map_processes
         SET machine_weighted_time = ROUND(nvl(l_machine_wt2, 0), G_DECIMAL),
	     labor_weighted_time   = ROUND(nvl(l_labor_wt2, 0), G_DECIMAL),
   	     total_weighted_time   = ROUND(nvl(l_total_wt2, 0), G_DECIMAL),
	     machines_needed       = ROUND(nvl(l_machines_needed2, 0), G_DECIMAL),
	     machines_assigned     = ROUND(nvl(l_mc_assigned2, 0), G_DECIMAL),
 	     labor_needed          = ROUND(nvl(l_labor_needed2, 0), G_DECIMAL),
	     labor_assigned        = ROUND(nvl(l_lb_assigned2, 0), G_DECIMAL),
	     takt_time             = ROUND(nvl(l_takt2, 0), G_DECIMAL),
	     takt_time_for_assigned  = ROUND(nvl(l_takt_time_for_assigned2, 0), G_DECIMAL),
	     in_process_kanban     = ROUND(nvl(l_ipk2, 0), G_DECIMAL),
             machines_needed_delta = ROUND(l_mn_delta2, G_DECIMAL),
	     labor_needed_delta    = ROUND(l_ln_delta2, G_DECIMAL),
             in_process_kanban_delta = ROUND(l_ipk_delta2, G_DECIMAL)
       WHERE mixed_model_map_id = p_mmm_id
         AND group_number = p_group_number
         AND sequence_id = 2 ;

   l_stmt_num := 80;
   UPDATE bom_mixed_model_map_processes
         SET machine_weighted_time = ROUND(nvl(l_machine_wt3, 0), G_DECIMAL),
	     labor_weighted_time   = ROUND(nvl(l_labor_wt3, 0), G_DECIMAL),
   	     total_weighted_time   = ROUND(nvl(l_total_wt3, 0), G_DECIMAL),
	     machines_needed       = ROUND(nvl(l_machines_needed3, 0), G_DECIMAL),
	     machines_assigned     = ROUND(nvl(l_mc_assigned3, 0), G_DECIMAL),
 	     labor_needed          = ROUND(nvl(l_labor_needed3, 0), G_DECIMAL),
	     labor_assigned        = ROUND(nvl(l_lb_assigned3, 0), G_DECIMAL),
	     takt_time             = ROUND(nvl(l_takt3, 0), G_DECIMAL),
	     takt_time_for_assigned  = ROUND(nvl(l_takt_time_for_assigned3, 0), G_DECIMAL),
	     in_process_kanban     = ROUND(nvl(l_ipk3, 0), G_DECIMAL),
             machines_needed_delta = ROUND(l_mn_delta3, G_DECIMAL),
	     labor_needed_delta    = ROUND(l_ln_delta3, G_DECIMAL),
             in_process_kanban_delta = ROUND(l_ipk_delta3, G_DECIMAL)
       WHERE mixed_model_map_id = p_mmm_id
         AND group_number = p_group_number
         AND sequence_id = 3 ;

   l_stmt_num := 81;
   UPDATE bom_mixed_model_map_processes
         SET machine_weighted_time = ROUND(nvl(l_machine_wt4, 0), G_DECIMAL),
	     labor_weighted_time   = ROUND(nvl(l_labor_wt4, 0), G_DECIMAL),
   	     total_weighted_time   = ROUND(nvl(l_total_wt4, 0), G_DECIMAL),
	     machines_needed       = ROUND(nvl(l_machines_needed4, 0), G_DECIMAL),
	     machines_assigned     = ROUND(nvl(l_mc_assigned4, 0), G_DECIMAL),
 	     labor_needed          = ROUND(nvl(l_labor_needed4, 0), G_DECIMAL),
	     labor_assigned        = ROUND(nvl(l_lb_assigned4, 0), G_DECIMAL),
	     takt_time             = ROUND(nvl(l_takt4, 0), G_DECIMAL),
	     takt_time_for_assigned  = ROUND(nvl(l_takt_time_for_assigned4, 0), G_DECIMAL),
	     in_process_kanban     = ROUND(nvl(l_ipk4, 0), G_DECIMAL),
             machines_needed_delta = ROUND(l_mn_delta4, G_DECIMAL),
	     labor_needed_delta    = ROUND(l_ln_delta4, G_DECIMAL),
             in_process_kanban_delta = ROUND(l_ipk_delta4, G_DECIMAL)
       WHERE mixed_model_map_id = p_mmm_id
         AND group_number = p_group_number
         AND sequence_id = 4 ;

   l_stmt_num := 82;
   UPDATE bom_mixed_model_map_processes
         SET machine_weighted_time = ROUND(nvl(l_machine_wt5, 0), G_DECIMAL),
	     labor_weighted_time   = ROUND(nvl(l_labor_wt5, 0), G_DECIMAL),
   	     total_weighted_time   = ROUND(nvl(l_total_wt5, 0), G_DECIMAL),
	     machines_needed       = ROUND(nvl(l_machines_needed5, 0), G_DECIMAL),
	     machines_assigned     = ROUND(nvl(l_mc_assigned5, 0), G_DECIMAL),
 	     labor_needed          = ROUND(nvl(l_labor_needed5, 0), G_DECIMAL),
	     labor_assigned        = ROUND(nvl(l_lb_assigned5, 0), G_DECIMAL),
	     takt_time             = ROUND(nvl(l_takt5, 0), G_DECIMAL),
	     takt_time_for_assigned  = ROUND(nvl(l_takt_time_for_assigned5, 0), G_DECIMAL),
	     in_process_kanban     = ROUND(nvl(l_ipk5, 0), G_DECIMAL),
             machines_needed_delta = ROUND(l_mn_delta5, G_DECIMAL),
	     labor_needed_delta    = ROUND(l_ln_delta5, G_DECIMAL),
             in_process_kanban_delta = ROUND(l_ipk_delta5, G_DECIMAL)
       WHERE mixed_model_map_id = p_mmm_id
         AND group_number = p_group_number
         AND sequence_id = 5 ;

--above code changed slightly
   l_stmt_num := 83;
   COMMIT;
EXCEPTION
   WHEN others THEN
      x_err_text := 'BOM_Mixed_Model_Map_PVT(GetCells-'||l_stmt_num||
		    ') '||substrb(SQLERRM,1,500);
END GetCells;




END BOM_Mixed_Model_Map_PVT;

/

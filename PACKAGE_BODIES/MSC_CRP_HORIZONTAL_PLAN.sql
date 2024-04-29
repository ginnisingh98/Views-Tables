--------------------------------------------------------
--  DDL for Package Body MSC_CRP_HORIZONTAL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CRP_HORIZONTAL_PLAN" AS
/*  $Header: MSCHCPLB.pls 120.9.12010000.3 2009/12/23 12:41:28 vdommara ship $ */

SYS_YES         CONSTANT INTEGER := 1;
SYS_NO          CONSTANT INTEGER := 2;
SYS_TRANS       CONSTANT INTEGER := 3;

SCHEDULE_FLAG_YES CONSTANT INTEGER := 1;

v_agg_flag      NUMBER := 2;

NUM_OF_TYPES        CONSTANT INTEGER := 33;

ROUTING_BASED       CONSTANT INTEGER := 2;
RATE_BASED      CONSTANT INTEGER := 3;

DELETE_WORK_DAY     CONSTANT INTEGER := 1;
MODIFY_WORK_DAY     CONSTANT INTEGER := 2;
ADD_WORK_DAY        CONSTANT INTEGER := 3;

/*   -- Commented out, keep it for refrence purpose, 11510 row types
AVAILABLE_HOURS     CONSTANT INTEGER := 1;
REQUIRED_HOURS      CONSTANT INTEGER := 2;
NET_AVAILABLE       CONSTANT INTEGER := 3;
CUM_AVAILABLE       CONSTANT INTEGER := 4;
UTILIZATION         CONSTANT INTEGER := 5;
CUM_UTILIZATION     CONSTANT INTEGER := 6;
DAILY_REQUIRED      CONSTANT INTEGER := 7;
DAILY_AVAILABLE     CONSTANT INTEGER := 8;
RESOURCE_COST       CONSTANT INTEGER := 9;
CAP_CHANGES         CONSTANT INTEGER := 10;
CUM_CAP_CHANGES     CONSTANT INTEGER := 11;
PLANNED_ORDER       CONSTANT INTEGER := 12;
NONSTD_JOBS         CONSTANT INTEGER := 13;
DISCRETE_JOBS       CONSTANT INTEGER := 14;
REPETITIVE          CONSTANT INTEGER := 15;
WEIGHTVOL_AVA	    CONSTANT INTEGER := 17;
WEIGHTVOL_REQ	    CONSTANT INTEGER := 18;
ATP_ADJUSTMENT      CONSTANT INTEGER := 19;
ATP_REQUIRED_HOURS  CONSTANT INTEGER := 20;
ATP_NET             CONSTANT INTEGER := 21;   -- Net ATP, the last row type in Res. HP.
*/

AVAILABLE_HOURS     CONSTANT INTEGER := 1;
SETUP_HOURS         CONSTANT INTEGER := 2;
SETUP_HOUR_RATIO    CONSTANT INTEGER := 3;
RUN_HOURS           CONSTANT INTEGER := 4;
RUN_HOUR_RATIO      CONSTANT INTEGER := 5;
REQUIRED_HOURS      CONSTANT INTEGER := 6;
NET_AVAILABLE       CONSTANT INTEGER := 7;
CUM_AVAILABLE       CONSTANT INTEGER := 8;
UTILIZATION         CONSTANT INTEGER := 9;
CUM_UTILIZATION     CONSTANT INTEGER := 10;
DAILY_REQUIRED      CONSTANT INTEGER := 11;
DAILY_AVAILABLE     CONSTANT INTEGER := 12;
RESOURCE_COST       CONSTANT INTEGER := 13;
CAP_CHANGES         CONSTANT INTEGER := 14;
CUM_CAP_CHANGES     CONSTANT INTEGER := 15;
PLANNED_ORDER       CONSTANT INTEGER := 16;
NONSTD_JOBS         CONSTANT INTEGER := 17;
DISCRETE_JOBS       CONSTANT INTEGER := 18;
REPETITIVE          CONSTANT INTEGER := 19;
FLOW_SCHEDULE       CONSTANT INTEGER := 20;
ATP_NET             CONSTANT INTEGER := 21;   -- Net ATP.

-- Internal Row types, never displayed

PLANNED_ORDER_SETUP  CONSTANT INTEGER := 22;
NONSTD_JOBS_SETUP    CONSTANT INTEGER := 23;
DISCRETE_JOBS_SETUP  CONSTANT INTEGER := 24;
REPETITIVE_SETUP     CONSTANT INTEGER := 25;
ATP_ADJUSTMENT_SETUP CONSTANT INTEGER := 26;


PLANNED_ORDER_RUN  CONSTANT INTEGER := 27;
NONSTD_JOBS_RUN    CONSTANT INTEGER := 28;
DISCRETE_JOBS_RUN  CONSTANT INTEGER := 29;
REPETITIVE_RUN     CONSTANT INTEGER := 30;
ATP_ADJUSTMENT_RUN CONSTANT INTEGER := 31;

ATP_REQUIRED_HOURS  CONSTANT INTEGER := 32;

ATP_ADJUSTMENT    CONSTANT INTEGER := 33;

-- End of Internal Row types

WT_AVAILABLE_HOURS  CONSTANT INTEGER := 1;
VL_AVAILABLE_HOURS  CONSTANT INTEGER := 2;
WT_REQUIRED_HOURS   CONSTANT INTEGER := 3;
VL_REQUIRED_HOURS   CONSTANT INTEGER := 4;
WT_LOAD_RATIO       CONSTANT INTEGER := 5;
VL_LOAD_RATIO       CONSTANT INTEGER := 6;

M_PLANNED_ORDER     CONSTANT INTEGER := 5;
M_NONSTD_JOBS       CONSTANT INTEGER := 7;
M_DISCRETE_JOBS     CONSTANT INTEGER := 3;
M_REPETITIVE        CONSTANT INTEGER := 4;
M_FLOW_SCHEDULES    CONSTANT INTEGER := 27;
M_ATP_ADJUSTMENT    CONSTANT INTEGER := 60;

WIP_DISCRETE        CONSTANT INTEGER := 1;  /* WIP_DISCRETE_JOB */
WIP_NONSTANDARD     CONSTANT INTEGER := 3;


JOB_UNRELEASED      CONSTANT INTEGER := 1;/* job status code*/
JOB_RELEASED        CONSTANT INTEGER := 3;
JOB_COMPLETE        CONSTANT INTEGER := 4;
COMPLETE_NO_CHARGES     CONSTANT INTEGER := 5;
JOB_HOLD        CONSTANT INTEGER := 6;
JOB_CANCELLED       CONSTANT INTEGER := 7;

BASIS_PER_ITEM      CONSTANT INTEGER := 1;
BASIS_PER_LOT       CONSTANT INTEGER := 2;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE column_char IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE crp_activity IS RECORD
    (org_id                NUMBER,
     instance_id           NUMBER,
     assembly_item_id      NUMBER,
     department_id         NUMBER,
     resource_id           NUMBER,
     type                  NUMBER,
     start_date            DATE,
     end_date              DATE,
     quantity              NUMBER,
     resource_instance_id  NUMBER,
     serial_number         VARCHAR2(30));


TYPE opt_flags IS RECORD
    (flag1  NUMBER,
     flag2  NUMBER,
     flag3  NUMBER,
     flag4  NUMBER,
     flag5  NUMBER,
     flag6  NUMBER);

g_optimized_plan    NUMBER := 2;
g_first_week	    DATE;
g_daily_counts	    NUMBER;

opt_flag_status     opt_flags;
g_bucket_count      NUMBER := 2;
g_num_of_buckets    NUMBER;
g_calendar_code     VARCHAR2(14);
g_hour_uom      VARCHAR2(10);
g_exc_set_id        NUMBER;
g_item_list_id      NUMBER;
g_query_id      NUMBER;
g_org_id        NUMBER;
g_inst_id        NUMBER;
g_spread_load       NUMBER;
g_plan_start_seq    NUMBER;
g_plan_start_date   DATE;
g_plan_end_date     DATE;
g_bucket_date       DATE;
g_cutoff_date       DATE;
g_designator        NUMBER;
g_current_data      NUMBER;
g_bucket_type       NUMBER;
g_error_stmt        VARCHAR2(50);

g_res_instance_case boolean := false;

g_dates         calendar_date;
g_date_seq      column_number;
bucket_cells        column_number;
activity_rec        crp_activity;

CURSOR c_flags (p_plan_id NUMBER) IS
    SELECT daily_material_constraints,
           daily_resource_constraints,
           weekly_material_constraints,
           weekly_resource_constraints,
           period_material_constraints,
           period_resource_constraints
    FROM msc_plans
    WHERE plan_id = p_plan_id;

CURSOR seqnum_cursor(p_date DATE) IS
    SELECT next_seq_num
    FROM   msc_calendar_dates
    WHERE  calendar_code = g_calendar_code
    AND    exception_set_id = g_exc_set_id
    AND    sr_instance_id = g_inst_id
    AND    calendar_date = p_date;

CURSOR prior_seqnum_cursor(p_date DATE) IS
    SELECT prior_seq_num
    FROM   msc_calendar_dates
    WHERE  calendar_code = g_calendar_code
    AND    exception_set_id = g_exc_set_id
    AND    sr_instance_id = g_inst_id
    AND    calendar_date = p_date;

 CURSOR crp_snapshot_activity IS
-- ======================================================================
-- Dept/Resource requirements for batch resource, only on daily buckets.
-- Calculation checked at calculate_cum procedure.
-- ======================================================================
/* bug6729620, batch res will behave the same as regular res
SELECT
    crp.organization_id,
    crp.sr_instance_id,
    to_number(0),
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_RUN,
        M_REPETITIVE, REPETITIVE_RUN,
        M_DISCRETE_JOBS, DISCRETE_JOBS_RUN,
        M_NONSTD_JOBS, NONSTD_JOBS_RUN,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_RUN,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_RUN),
    trunc(crp.start_date),
    trunc(crp.end_date),
    avg(crp.resource_hours),
    to_number(-1),
    to_char('-1')
  FROM
    msc_resource_requirements crp,
    msc_department_resources cpr,
    msc_resource_batches mrb,
    msc_supplies mss,
    msc_form_query list
  WHERE
        nvl(cpr.owning_department_id, cpr.department_id) = list.number5
  AND   cpr.resource_id = list.number3
  and   nvl(cpr.batchable_flag,2) =1
  AND   cpr.plan_id = g_designator
  AND   cpr.organization_id = list.number1
  AND   cpr.sr_instance_id = list.number4
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES,
        M_ATP_ADJUSTMENT)
  AND   crp.plan_id = cpr.plan_id
  AND   trunc(crp.start_date) <= trunc(g_cutoff_date)
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   crp.sr_instance_id = cpr.sr_instance_id
  AND   crp.schedule_flag = SCHEDULE_FLAG_YES     -- to get Run Time
  AND   NVL(crp.parent_id, g_optimized_plan) = decode(g_optimized_plan, 1,1,2,2,1)
  AND   list.query_id = g_item_list_id
  AND   crp.plan_id = mss.plan_id
  AND   crp.supply_id = mss.transaction_id
  and   mrb.plan_id = crp.plan_id
  and   mrb.sr_instance_id = crp.sr_instance_id
  and   mrb.organization_id= crp.organization_id
  and   mrb.department_id = crp.department_id
  and   mrb.resource_id = crp.resource_id
  and   mrb.batch_number = crp.batch_number
  GROUP BY crp.organization_id,
           crp.sr_instance_id,
           list.number2,
           crp.resource_id,
           trunc(crp.start_date),
           trunc(crp.end_date),
           decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_RUN,
        M_REPETITIVE, REPETITIVE_RUN,
        M_DISCRETE_JOBS, DISCRETE_JOBS_RUN,
        M_NONSTD_JOBS, NONSTD_JOBS_RUN,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_RUN,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_RUN),
    trunc(crp.start_date),
    trunc(crp.end_date),
    cpr.line_flag
union all
*/
-- =============================
-- Batchable Resource requirements SETUP TIME
-- =============================
SELECT
    crp.organization_id,
    crp.sr_instance_id,
 --   crp.assembly_item_id,
   to_number(0),
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_SETUP,
        M_REPETITIVE, REPETITIVE_SETUP,
        M_DISCRETE_JOBS, DISCRETE_JOBS_SETUP,
        M_NONSTD_JOBS, NONSTD_JOBS_SETUP,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_SETUP,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_SETUP),
    trunc(crp.start_date),
    trunc(crp.end_date),
    avg(crp.resource_hours),
    to_number(-1),
    to_char('-1')
  FROM
    msc_resource_requirements crp,
    msc_department_resources cpr,
    msc_resource_batches mrb,
    msc_supplies mss,
    msc_form_query list
  WHERE
        nvl(cpr.owning_department_id, cpr.department_id) = list.number5
  AND   cpr.resource_id = list.number3
  and   nvl(cpr.batchable_flag,2) =1
  AND   cpr.plan_id = g_designator
  AND   cpr.organization_id = list.number1
  AND   cpr.sr_instance_id = list.number4
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES,
        M_ATP_ADJUSTMENT)
  AND   crp.plan_id = cpr.plan_id
  AND   trunc(crp.start_date) <= trunc(g_cutoff_date)
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   crp.sr_instance_id = cpr.sr_instance_id
  AND   crp.schedule_flag <> SCHEDULE_FLAG_YES     -- to get SETUP Time
  AND   NVL(crp.parent_id, g_optimized_plan) = decode(g_optimized_plan, 1,1,2,2,1)
  AND   list.query_id = g_item_list_id
  AND   crp.plan_id = mss.plan_id
  AND   crp.supply_id = mss.transaction_id
  and   mrb.plan_id = crp.plan_id
  and   mrb.sr_instance_id = crp.sr_instance_id
  and   mrb.organization_id= crp.organization_id
  and   mrb.department_id = crp.department_id
  and   mrb.resource_id = crp.resource_id
  and   mrb.batch_number = crp.batch_number
  GROUP BY crp.organization_id,
           crp.sr_instance_id,
     --      crp.assembly_item_id,
           list.number2,
           crp.resource_id,
           trunc(crp.start_date),
           trunc(crp.end_date),
           decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_SETUP,
        M_REPETITIVE, REPETITIVE_SETUP,
        M_DISCRETE_JOBS, DISCRETE_JOBS_SETUP,
        M_NONSTD_JOBS, NONSTD_JOBS_SETUP,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_SETUP,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_SETUP),
    trunc(crp.start_date),
    trunc(crp.end_date),
    cpr.line_flag
union all
-- =============================
-- Dept/Resource requirements RUN TIME
-- =============================
  SELECT
    crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_RUN,
        M_REPETITIVE, REPETITIVE_RUN,
        M_DISCRETE_JOBS, DISCRETE_JOBS_RUN,
        M_NONSTD_JOBS, NONSTD_JOBS_RUN,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_RUN,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_RUN),
    trunc(crp.start_date),
    trunc(crp.end_date),
    decode (cpr.line_flag,
            2, sum(decode(crp.end_date,
                          NULL, crp.resource_hours,
                          crp.daily_resource_hours)),
            sum((cpr.max_rate*crp.daily_resource_hours))),
    to_number(-1),
    to_char('-1')
  FROM
    msc_resource_requirements crp,
    msc_department_resources cpr,
    msc_form_query list
  WHERE nvl(cpr.owning_department_id, cpr.department_id) = list.number5
  AND   cpr.resource_id = list.number3
  AND   cpr.plan_id = g_designator
  AND   cpr.organization_id = list.number1
  AND   cpr.sr_instance_id = list.number4
--  and   nvl(cpr.batchable_flag,2) =2
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES,
        M_ATP_ADJUSTMENT)
  AND   crp.plan_id = cpr.plan_id
  AND   trunc(crp.start_date) <= trunc(g_cutoff_date)
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   crp.sr_instance_id = cpr.sr_instance_id
  AND   nvl(crp.schedule_flag,SCHEDULE_FLAG_YES) = SCHEDULE_FLAG_YES     -- to get Run Time
  AND   NVL(crp.parent_id, g_optimized_plan) = decode(g_optimized_plan, 1,1,2,2,1)
  AND   list.query_id = g_item_list_id
  GROUP BY crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_RUN,
        M_REPETITIVE, REPETITIVE_RUN,
        M_DISCRETE_JOBS, DISCRETE_JOBS_RUN,
        M_NONSTD_JOBS, NONSTD_JOBS_RUN,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_RUN,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_RUN),
    trunc(crp.start_date),
    trunc(crp.end_date),
    cpr.line_flag
UNION ALL
-- -----------------------------------
--  To get Dept / Res Setup Time
-- -----------------------------------
    SELECT
    crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_SETUP,
        M_REPETITIVE, REPETITIVE_SETUP,
        M_DISCRETE_JOBS, DISCRETE_JOBS_SETUP,
        M_NONSTD_JOBS, NONSTD_JOBS_SETUP,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_SETUP,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_SETUP),
    trunc(crp.start_date),
    trunc(crp.end_date),
    decode (cpr.line_flag,
            2, sum(decode(crp.end_date,
                          NULL, crp.resource_hours,
                          crp.daily_resource_hours)),
            sum((cpr.max_rate*crp.daily_resource_hours))),
    to_number(-1),
    to_char('-1')
  FROM
    msc_resource_requirements crp,
    msc_department_resources cpr,
    msc_form_query list
  WHERE nvl(cpr.owning_department_id, cpr.department_id) = list.number5
  AND   cpr.resource_id = list.number3
  AND   cpr.plan_id = g_designator
  AND   cpr.organization_id = list.number1
  AND   cpr.sr_instance_id = list.number4
  and   nvl(cpr.batchable_flag,2) =2
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES,
        M_ATP_ADJUSTMENT)
  AND   crp.plan_id = cpr.plan_id
  AND   trunc(crp.start_date) <= trunc(g_cutoff_date)
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   crp.sr_instance_id = cpr.sr_instance_id
  AND   crp.schedule_flag <> SCHEDULE_FLAG_YES     -- to get SETUP Time
  AND   NVL(crp.parent_id, g_optimized_plan) = decode(g_optimized_plan, 1,1,2,2,1)
  AND   list.query_id = g_item_list_id
  GROUP BY crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_SETUP,
        M_REPETITIVE, REPETITIVE_SETUP,
        M_DISCRETE_JOBS, DISCRETE_JOBS_SETUP,
        M_NONSTD_JOBS, NONSTD_JOBS_SETUP,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_SETUP,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_SETUP),
    trunc(crp.start_date),
    trunc(crp.end_date),
    cpr.line_flag

UNION ALL
-- ===================================
-- Repetitive schedule line requirements
-- ===================================
  SELECT
    msrs.organization_id,
    msrs.sr_instance_id,
    msrs.inventory_item_id,
    msrs.line_id,
    -1,
    REPETITIVE,
    trunc(msrs.first_unit_start_date),
    trunc(least(msrs.last_unit_start_date,g_cutoff_date-1)),
    msrs.daily_rate,   -- this might not be right, used to be load_factor_rate
    to_number(-1),
    to_char('-1')
  FROM  msc_form_query list,
    msc_supplies msrs
  WHERE trunc(msrs.first_unit_start_date) <= trunc(g_cutoff_date)
  AND   msrs.plan_id = g_designator
  AND   msrs.organization_id = list.number1
  AND   msrs.sr_instance_id = list.number4
  AND   msrs.line_id = list.number2
  AND   list.number3 = -1
  AND   list.query_id = g_item_list_id
UNION ALL
-- ===================================
-- Availability for Dept/Res
-- ===================================
  SELECT
    avail.organization_id,
    avail.sr_instance_id,
    TO_NUMBER(NULL),
    NVL(avail.department_id,-1),
    NVL(avail.resource_id,-1),
    AVAILABLE_HOURS,
    trunc(avail.shift_date),
    to_date(NULL),
    sum(avail.capacity_units * decode(from_time,NULL,1,(( DECODE(sign(avail.to_time-avail.from_time), -1, avail.to_time+86400, avail.to_time) - avail.from_time)/3600))),
    to_number(-1),
    to_char('-1')
    FROM  msc_net_resource_avail avail,

    msc_form_query list
  WHERE trunc(avail.shift_date) <= trunc(g_cutoff_date)
  AND   avail.shift_date >= g_dates(1)+1
  AND   NVL(avail.parent_id,0) <> -1
  AND   avail.plan_id = g_designator
  AND   avail.organization_id = list.number1
  AND   avail.sr_instance_id = list.number4
  AND   avail.department_id = list.number2
  AND   avail.resource_id = list.number3
  AND   avail.capacity_units >= 0
  AND   list.query_id = g_item_list_id
/*
  AND   not exists (select 'aggregate' from msc_net_resource_avail b
        where b.shift_date = decode(v_agg_flag,1,null,avail.shift_date)
        and b.resource_id = decode(v_agg_flag,1,null,avail.aggregate_resource_id)
        and b.department_id = decode(v_agg_flag,1,null,avail.department_id)
        and b.plan_id = avail.plan_id
        and b.organization_id = decode(v_agg_flag,1,null,avail.organization_id)
        and b.sr_instance_id = decode(v_agg_flag,1,null,avail.sr_instance_id))
*/
  GROUP BY avail.organization_id, avail.sr_instance_id,
	NVL(avail.department_id,-1), NVL(avail.resource_id,-1),
	trunc(avail.shift_date)
  UNION ALL
-------------------------------------------------------------------
-- This is to intoduce a new row in capacity HP  'ATP'
-- this row will reflect the  net availability from ATP perspective
-- the cursor will select  requirement from atp perspecive and
-- in calculate_cum we will calculate atp net
-------------------------------------------------------------------
 SELECT
    crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    ATP_REQUIRED_HOURS,
    decode(g_optimized_plan, 1, trunc(crp.start_date),
                   nvl(trunc(crp.end_date),trunc(crp.start_date))),
    trunc(crp.end_date),
    sum(decode( nvl(cpr.batchable_flag,2), 1 ,
              s.new_order_quantity * decode(cpr.uom_class_type,1,
                                          i.unit_weight, i.unit_volume)
                        * nvl(decode(crp.end_date,NULL, crp.resource_hours,
                        crp.daily_resource_hours),0),
           decode(cpr.line_flag,
              2, decode(crp.end_date,
                          NULL, crp.resource_hours,
                          crp.daily_resource_hours),
            cpr.max_rate*crp.daily_resource_hours))),
     TO_NUMBER(-1),
    to_char('-1')
    FROM    msc_resource_requirements crp,
            msc_department_resources cpr,
            msc_form_query list,
            msc_supplies s,
            msc_system_items i
   WHERE    nvl(cpr.owning_department_id, cpr.department_id) = list.number5
   AND      cpr.resource_id = list.number3
   AND      cpr.plan_id = g_designator
   AND      cpr.organization_id = list.number1
   AND      cpr.sr_instance_id = list.number4
   AND      crp.plan_id = cpr.plan_id
   AND      trunc(crp.start_date) <= trunc(g_cutoff_date)
   AND      crp.resource_id = cpr.resource_id
   AND      crp.department_id = cpr.department_id
   AND      crp.organization_id = cpr.organization_id
   AND      crp.sr_instance_id = cpr.sr_instance_id
   AND      NVL(crp.parent_id, g_optimized_plan) =
                            decode(g_optimized_plan, 1,1,2,2,1)
   AND      list.query_id = g_item_list_id
   AND      crp.supply_id  = s.transaction_id
   AND      crp.assembly_item_id = i.inventory_item_id
   AND      crp.sr_instance_id   = i.sr_instance_id
   AND      crp.organization_id  = i.organization_id
   AND      crp.plan_id          = i.plan_id
   AND      i.inventory_item_id  = s.inventory_item_id
   AND      i.organization_id    = s.organization_id
   AND      i.sr_instance_id     = s.sr_instance_id
   AND      i.plan_id            = s.plan_id
   AND      ((i.bom_item_type <> 1 and i.bom_item_type <> 2) OR
                 (i.atp_flag ='Y') OR
               (i.bom_item_type in (1, 2) AND s.record_source = 2) )
  GROUP BY   crp.organization_id,
              crp.sr_instance_id,
              crp.assembly_item_id,
              list.number2,
              crp.resource_id,
              trunc(crp.start_date),
              trunc(crp.end_date)
 union all
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
 SELECT  list.number1,
        list.number4,
        list.number5,
        list.number2,
        list.number3,
        PLANNED_ORDER,
        to_date(1, 'J'),
        to_date(1, 'J'),
        0,
        to_NUMBER(-1),
        to_char('-1')
FROM    msc_form_query list
WHERE   list.query_id = g_item_list_id
  ORDER BY 1,2,4,5,7,6;

CURSOR crp_res_inst_snapshot_activity IS
-- ======================================================================
-- Dept/Resource requirements for batch resource INSTANCES, only on daily buckets.
-- Calculation checked at calculate_cum procedure.
-- ======================================================================


-- =============================
-- Dept/Resource INSTANCE requirements RUN TIME
-- =============================
    SELECT
    crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_RUN,
        M_REPETITIVE, REPETITIVE_RUN,
        M_DISCRETE_JOBS, DISCRETE_JOBS_RUN,
        M_NONSTD_JOBS, NONSTD_JOBS_RUN,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_RUN,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_RUN),
    trunc(mrir.start_date),
    trunc(mrir.end_date),
    decode (cpr.line_flag,
            2, sum(decode(mrir.end_date,
                          NULL, mrir.resource_instance_hours,
                          mrir.daily_res_instance_hours)),
            sum((cpr.max_rate*mrir.daily_res_instance_hours))),
    mrir.res_instance_id,
    mrir.serial_number
  FROM
    msc_resource_requirements crp,
    msc_department_resources cpr,
    msc_dept_res_instances mdri,
    msc_resource_instance_reqs mrir,
    msc_form_query list
  WHERE nvl(cpr.owning_department_id, cpr.department_id) = list.number5
  AND   cpr.resource_id = list.number3
  AND   cpr.plan_id = g_designator
  AND   cpr.organization_id = list.number1
  AND   cpr.sr_instance_id = list.number4
  AND   mrir.res_instance_id = list.number8
  AND   mrir.serial_number = list.char3
  and   nvl(cpr.batchable_flag,2) =2
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES,
        M_ATP_ADJUSTMENT)
  AND   crp.plan_id = cpr.plan_id
  AND   trunc(crp.start_date) <= trunc(g_cutoff_date)
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   crp.sr_instance_id = cpr.sr_instance_id
  AND   crp.schedule_flag = SCHEDULE_FLAG_YES     -- to get RUN Time
  AND   NVL(crp.parent_id, g_optimized_plan) = decode(g_optimized_plan, 1,1,2,2,1)
  AND   list.query_id = g_item_list_id
  and   mrir.plan_id = crp.plan_id
  and   mrir.sr_instance_id = crp.sr_instance_id
  and   mrir.organization_id = crp.organization_id
  and   mrir.supply_id = crp.supply_id
  and   mrir.resource_seq_num = crp.resource_seq_num
  and   mrir.operation_seq_num = crp.operation_seq_num
  and   mdri.plan_id = mrir.plan_id
  and   mdri.sr_instance_id = mrir.sr_instance_id
  and   mdri.organization_id = mrir.organization_id
  and   mdri.department_id = mrir.department_id
  and   mdri.resource_id = mrir.resource_id
  and   mdri.res_instance_id = mrir.res_instance_id
  and   mdri.serial_number = mrir.serial_number
  GROUP BY crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_RUN,
        M_REPETITIVE, REPETITIVE_RUN,
        M_DISCRETE_JOBS, DISCRETE_JOBS_RUN,
        M_NONSTD_JOBS, NONSTD_JOBS_RUN,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_RUN,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_RUN),
    trunc(mrir.start_date),
    trunc(mrir.end_date),
    cpr.line_flag,
    mrir.res_instance_id,
    mrir.serial_number
UNION ALL
-- -----------------------------------
--  To get Dept / Res INSTANCE Setup Time
-- -----------------------------------
    SELECT
    crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_SETUP,
        M_REPETITIVE, REPETITIVE_SETUP,
        M_DISCRETE_JOBS, DISCRETE_JOBS_SETUP,
        M_NONSTD_JOBS, NONSTD_JOBS_SETUP,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_SETUP,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_SETUP),
    trunc(mrir.start_date),
    trunc(mrir.end_date),
    decode (cpr.line_flag,
            2, sum(decode(mrir.end_date,
                          NULL, mrir.resource_instance_hours,
                          mrir.daily_res_instance_hours)),
            sum((cpr.max_rate*mrir.daily_res_instance_hours))),
    mrir.res_instance_id,
    mrir.serial_number
  FROM
    msc_resource_requirements crp,
    msc_department_resources cpr,
    msc_dept_res_instances mdri,
    msc_resource_instance_reqs mrir,
    msc_form_query list
  WHERE nvl(cpr.owning_department_id, cpr.department_id) = list.number5
  AND   cpr.resource_id = list.number3
  AND   cpr.plan_id = g_designator
  AND   cpr.organization_id = list.number1
  AND   cpr.sr_instance_id = list.number4
  AND   mrir.res_instance_id = list.number8
  AND   mrir.serial_number = list.char3
  and   nvl(cpr.batchable_flag,2) =2
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES,
        M_ATP_ADJUSTMENT)
  AND   crp.plan_id = cpr.plan_id
  AND   trunc(crp.start_date) <= trunc(g_cutoff_date)
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   crp.sr_instance_id = cpr.sr_instance_id
  AND   crp.schedule_flag <> SCHEDULE_FLAG_YES     -- to get SETUP Time
  AND   NVL(crp.parent_id, g_optimized_plan) = decode(g_optimized_plan, 1,1,2,2,1)
  AND   list.query_id = g_item_list_id
  and   mrir.plan_id = crp.plan_id
  and   mrir.sr_instance_id = crp.sr_instance_id
  and   mrir.organization_id = crp.organization_id
  and   mrir.supply_id = crp.supply_id
  and   mrir.resource_seq_num = crp.resource_seq_num
  and   mrir.operation_seq_num = crp.operation_seq_num
  and   mdri.plan_id = mrir.plan_id
  and   mdri.sr_instance_id = mrir.sr_instance_id
  and   mdri.organization_id = mrir.organization_id
  and   mdri.department_id = mrir.department_id
  and   mdri.resource_id = mrir.resource_id
  and   mdri.res_instance_id = mrir.res_instance_id
  and   mdri.serial_number = mrir.serial_number
  GROUP BY crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER_SETUP,
        M_REPETITIVE, REPETITIVE_SETUP,
        M_DISCRETE_JOBS, DISCRETE_JOBS_SETUP,
        M_NONSTD_JOBS, NONSTD_JOBS_SETUP,
        M_FLOW_SCHEDULES, DISCRETE_JOBS_SETUP,
        M_ATP_ADJUSTMENT, ATP_ADJUSTMENT_SETUP),
    trunc(mrir.start_date),
    trunc(mrir.end_date),
    cpr.line_flag,
    mrir.res_instance_id,
    mrir.serial_number
UNION ALL

-- ===================================
-- Repetitive schedule line requirements
-- ===================================

  SELECT
    msrs.organization_id,
    msrs.sr_instance_id,
    msrs.inventory_item_id,
    msrs.line_id,
    -1,
    REPETITIVE,
    trunc(msrs.first_unit_start_date),
    trunc(least(msrs.last_unit_start_date,g_cutoff_date-1)),
    msrs.daily_rate,  -- this might not be right, used to be load_factor_rate
    to_number(null),
    to_char(null)
  FROM  msc_form_query list,
    msc_supplies msrs
  WHERE trunc(msrs.first_unit_start_date) <= trunc(g_cutoff_date)
  AND   msrs.plan_id = g_designator
  AND   msrs.organization_id = list.number1
  AND   msrs.sr_instance_id = list.number4
  AND   msrs.line_id = list.number2
  AND   list.number3 = -1
  AND   list.query_id = g_item_list_id
UNION ALL

-- ===================================
-- Availability for Dept/Res INSTANCES
-- ===================================

 SELECT
    avail.organization_id,
    avail.sr_instance_id,
    TO_NUMBER(NULL),
    NVL(avail.department_id,-1),
    NVL(avail.resource_id,-1),
    AVAILABLE_HOURS,
    trunc(avail.shift_date),
    to_date(NULL),
    sum(nvl(avail.capacity_units,1) * decode(from_time,NULL,1,(( DECODE(sign(avail.to_time-avail.from_time), -1, avail.to_time+86400, avail.to_time) - avail.from_time)/3600))),
    avail.res_instance_id,
    avail.serial_number
  FROM  msc_net_res_inst_avail avail,
    msc_form_query list
  WHERE trunc(avail.shift_date) <= trunc(g_cutoff_date)
  AND   avail.shift_date >= g_dates(1)+1
  AND   NVL(avail.parent_id,0) <> -1
  AND   avail.plan_id = g_designator
  AND   avail.organization_id = list.number1
  AND   avail.sr_instance_id = list.number4
  AND   avail.department_id = list.number2
  AND   avail.resource_id = list.number3
  AND   avail.res_instance_id = list.number8
  AND   avail.serial_number = list.char3
  AND   nvl(avail.capacity_units,1) <> 0
  AND   list.query_id = g_item_list_id
 --  AND   not exists (select 'aggregate' from msc_net_resource_avail b
 --       where b.shift_date = decode(v_agg_flag,1,null,avail.shift_date)
 --       and b.resource_id = decode(v_agg_flag,1,null,avail.aggregate_resource_id)
 --       and b.department_id = decode(v_agg_flag,1,null,avail.department_id)
 --       and b.plan_id = avail.plan_id
 --       and b.organization_id = decode(v_agg_flag,1,null,avail.organization_id)
 --       and b.sr_instance_id = decode(v_agg_flag,1,null,avail.sr_instance_id))
   GROUP BY avail.organization_id, avail.sr_instance_id,
	NVL(avail.department_id,-1), NVL(avail.resource_id,-1),
	trunc(avail.shift_date),
    avail.res_instance_id,
    avail.serial_number
  UNION ALL

-------------------------------------------------------------------
-- This is to intoduce a new row in capacity HP  'ATP'
-- this row will reflect the  net availability from ATP perspective
-- the cursor will select  requirement from atp perspecive and
-- in calculate_cum we will calculate atp net
-------------------------------------------------------------------
/*

SELECT
    crp.organization_id,
    crp.sr_instance_id,
    crp.assembly_item_id,
    list.number2,
    crp.resource_id,
    ATP_REQUIRED_HOURS,
    decode(g_optimized_plan, 1, trunc(crp.start_date),
                   nvl(trunc(crp.end_date),trunc(crp.start_date))),
    trunc(crp.end_date),
    sum(decode( nvl(cpr.batchable_flag,2), 1 ,
              s.new_order_quantity * decode(cpr.uom_class_type,1,
                                          i.unit_weight, i.unit_volume)
                        * nvl(decode(crp.end_date,NULL, crp.resource_hours,
                        crp.daily_resource_hours),0),
           decode(cpr.line_flag,
              2, decode(crp.end_date,
                          NULL, crp.resource_hours,
                          crp.daily_resource_hours),
            cpr.max_rate*crp.daily_resource_hours))),
    to_number(null),
    to_char(null)
    FROM    msc_resource_requirements crp,
            msc_department_resources cpr,
            msc_form_query list,
            msc_supplies s,
            msc_system_items i
   WHERE    nvl(cpr.owning_department_id, cpr.department_id) = list.number5
   AND      cpr.resource_id = list.number3
   AND      cpr.plan_id = g_designator
   AND      cpr.organization_id = list.number1
   AND      cpr.sr_instance_id = list.number4
   AND      crp.plan_id = cpr.plan_id
   AND      trunc(crp.start_date) <= trunc(g_cutoff_date)
   AND      crp.resource_id = cpr.resource_id
   AND      crp.department_id = cpr.department_id
   AND      crp.organization_id = cpr.organization_id
   AND      crp.sr_instance_id = cpr.sr_instance_id
   AND      NVL(crp.parent_id, g_optimized_plan) =
                            decode(g_optimized_plan, 1,1,2,2,1)
   AND      list.query_id = g_item_list_id
   AND      crp.supply_id  = s.transaction_id
   AND      crp.assembly_item_id = i.inventory_item_id
   AND      crp.sr_instance_id   = i.sr_instance_id
   AND      crp.organization_id  = i.organization_id
   AND      crp.plan_id          = i.plan_id
   AND      i.inventory_item_id  = s.inventory_item_id
   AND      i.organization_id    = s.organization_id
   AND      i.sr_instance_id     = s.sr_instance_id
   AND      i.plan_id            = s.plan_id
   AND      ((i.bom_item_type <> 1 and i.bom_item_type <> 2) OR
                 (i.atp_flag ='Y') OR
               (i.bom_item_type in (1, 2) AND s.record_source = 2) )
  GROUP BY   crp.organization_id,
              crp.sr_instance_id,
              crp.assembly_item_id,
              list.number2,
              crp.resource_id,
              trunc(crp.start_date),
              trunc(crp.end_date)
 union all
*/
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  list.number1,
        list.number4,
        list.number5,
        list.number2,
        list.number3,
        PLANNED_ORDER,
        to_date(1, 'J'),
        to_date(1, 'J'),
        0,
        to_number(null),
        to_char(null)
FROM    msc_form_query list
WHERE   list.query_id = g_item_list_id
  ORDER BY 1,2,4,5,10,11,7,6;




CURSOR crp_trans_activity IS
  SELECT
    sm.to_organization_id,
    sm.sr_instance_id,
    to_number(null),
    sm.from_organization_id,
    sm.transaction_id,
    WT_AVAILABLE_HOURS,
    cal.calendar_date,
    to_date(NULL),
    NVL(sm.weight_capacity,0),
    to_number(null),
    to_char(NULL)
  FROM msc_interorg_ship_methods sm,
    msc_form_query list,
    msc_trading_partners tp,
    msc_calendar_dates cal
  WHERE cal.calendar_date BETWEEN g_plan_start_date+1 AND g_cutoff_date
    AND cal.exception_set_id = tp.calendar_exception_set_id
    AND cal.calendar_code = tp.calendar_code
    AND cal.sr_instance_id = tp.sr_instance_id
    AND tp.sr_instance_id = sm.sr_instance_id
    AND tp.sr_tp_id = sm.to_organization_id
    AND sm.plan_id = g_designator
    AND sm.to_organization_id = list.number1
    AND sm.sr_instance_id = list.number4
    AND sm.transaction_id = list.number3
    AND list.query_id = g_item_list_id
  UNION ALL
  SELECT
    sm.to_organization_id,
    sm.sr_instance_id,
    to_number(null),
    sm.from_organization_id,
    sm.transaction_id,
    VL_AVAILABLE_HOURS,
    cal.calendar_date,
    to_date(NULL),
    NVL(sm.volume_capacity,0)
    , to_number(null),
    to_char(NULL)
  FROM msc_interorg_ship_methods sm,
    msc_form_query list,
    msc_trading_partners tp,
    msc_calendar_dates cal
  WHERE cal.calendar_date BETWEEN g_plan_start_date+1 AND g_cutoff_date
    AND cal.exception_set_id = tp.calendar_exception_set_id
    AND cal.calendar_code = tp.calendar_code
    AND cal.sr_instance_id = tp.sr_instance_id
    AND tp.sr_tp_id = sm.to_organization_id
    AND tp.sr_instance_id = sm.sr_instance_id
    AND sm.plan_id = g_designator
    AND sm.to_organization_id = list.number1
    AND sm.sr_instance_id = list.number4
    AND sm.transaction_id = list.number3
    AND list.query_id = g_item_list_id
  UNION ALL
  SELECT
    sm.to_organization_id,
    sm.sr_instance_id,
    to_number(null),
    sm.from_organization_id,
    sm.transaction_id,
    WT_REQUIRED_HOURS,
    sup.new_wip_start_date,
    to_date(NULL),
    NVL(sup.weight_capacity_used,0)
    , to_number(null),
    to_char(NULL)
  FROM msc_interorg_ship_methods sm,
    msc_supplies sup,
    msc_form_query list
  WHERE sm.plan_id = g_designator
    AND sm.plan_id = sup.plan_id
    AND sm.to_organization_id = sup.organization_id
    AND sm.from_organization_id = sup.source_organization_id
    AND sm.ship_method = sup.ship_method
    AND sm.sr_instance_id = sup.sr_instance_id
    AND sm.to_organization_id = list.number1
    AND sm.sr_instance_id = list.number4
    AND sm.transaction_id = list.number3
    AND list.query_id = g_item_list_id
  UNION ALL
  SELECT
    sm.to_organization_id,
    sm.sr_instance_id,
    to_number(null),
    sm.from_organization_id,
    sm.transaction_id,
    VL_REQUIRED_HOURS,
    sup.new_wip_start_date,
    to_date(NULL),
    NVL(sup.volume_capacity_used,0)
    , to_number(null),
    to_char(NULL)
  FROM msc_interorg_ship_methods sm,
    msc_supplies sup,
    msc_form_query list
  WHERE sm.plan_id = g_designator
    AND sm.plan_id = sup.plan_id
    AND sm.to_organization_id = sup.organization_id
    AND sm.from_organization_id = sup.source_organization_id
    AND sm.ship_method = sup.ship_method
    AND sm.sr_instance_id = sup.sr_instance_id
    AND sm.to_organization_id = list.number1
    AND sm.sr_instance_id = list.number4
    AND sm.transaction_id = list.number3
    AND list.query_id = g_item_list_id
  ORDER BY 1,2,4,5,7,6;

CURSOR agg_resource IS
   SELECT nvl(mdr.aggregate_resource_flag,2)
     from msc_department_resources mdr,
          msc_form_query list
    where mdr.plan_id = g_designator
    AND   mdr.sr_instance_id = list.number4
    AND   mdr.organization_id = list.number1
    AND   mdr.department_id = list.number2
    AND   mdr.resource_id = list.number3
    AND   list.query_id = g_item_list_id;

-- =============================================================================

-- =============================================================================
-- Name: initialize

-- =============================================================================

-- =============================================================================
-- Name: initialize
-- Desc: initializes most of the global variables in the package
--       g_spread_load - indicates if we want to spread capacity load or not
--   g_hour_uom - stores the hour uom at this site
--       g_date() - is the structure that holds the beginning of each bucket
--       g_date_seq() - Holds the date seq of for each date in g_date. Note
--                      The date seq is for the calendar of the current org
-- =============================================================================
PROCEDURE initialize IS
  -- -----------------------------------------
  -- This cursor selects row type information.
  -- -----------------------------------------
  v_sid         NUMBER;
  v_counter     NUMBER;

  CURSOR plan_buckets IS
  SELECT DECODE(g_designator, -1, trunc(sysdate), trunc(curr_start_date)) - 1,
         DECODE(g_designator, -1, trunc(sysdate+365), trunc(curr_cutoff_date))
  FROM msc_plans
  WHERE plan_id = g_designator;

  CURSOR bucket_dates(p_start_date DATE, p_end_date DATE) IS
  SELECT cal.calendar_date
  FROM msc_trading_partners tp,
       msc_calendar_dates cal
  WHERE tp.sr_tp_id = g_org_id
   AND tp.sr_instance_id = g_inst_id
   AND tp.calendar_exception_set_id = cal.exception_set_id
   AND tp.partner_type = 3
   AND tp.calendar_code = cal.calendar_code
   AND tp.sr_instance_id = cal.sr_instance_id
   AND cal.calendar_date BETWEEN p_start_date AND p_end_date
  ORDER BY cal.calendar_date;

  l_bucket_date         DATE;
  l_bucket_number       NUMBER := 0;

BEGIN

  --dbms_output.put_line('in init');

  -- --------------------------
  -- initialize profile value
  -- --------------------------
  g_spread_load := NVL(FND_PROFILE.VALUE('CRP_SPREAD_LOAD'), SYS_NO);
  g_hour_uom := fnd_profile.value('BOM:HOUR_UOM_CODE');

  -- --------------------------
  -- initialize query id
  -- --------------------------
  g_error_stmt := 'Debug - initialize - 10';
  SELECT msc_capacity_plans_s.nextval
  INTO   g_query_id
  FROM   dual;

  -- --------------------------------------------------------
  -- Start and End date of plan, find total number of buckets
  -- --------------------------------------------------------
  g_error_stmt := 'Debug - initialize - 20';
  --dbms_output.put_line('b4 planning buckets');
  OPEN plan_buckets;
  FETCH plan_buckets into g_plan_start_date, g_plan_end_date;
  CLOSE plan_buckets;

  g_num_of_buckets := (g_plan_end_date + 1) - g_plan_start_date;

  --dbms_output.put_line(' no of buckets' || g_num_of_buckets);

  -- --------------------
  -- Get the bucket dates
  -- --------------------
  g_error_stmt := 'Debug - initialize - 30';
  OPEN bucket_dates(g_plan_start_date, g_plan_end_date+1);
  LOOP
    FETCH bucket_dates INTO l_bucket_date;
    EXIT WHEN BUCKET_DATES%NOTFOUND;
    l_bucket_number := l_bucket_number + 1;
    g_dates(l_bucket_number) := l_bucket_date;
  END LOOP;
  CLOSE bucket_dates;

   --dbms_output.put_line(' bucket number' || l_bucket_number);

  -- --------------------------
  -- initialize calendar code
  -- --------------------------
  SELECT calendar_code, calendar_exception_set_id
  INTO   g_calendar_code, g_exc_set_id
  FROM   msc_trading_partners
  WHERE  sr_tp_id = g_org_id
    AND  sr_instance_id = g_inst_id
    AND  partner_type = 3;

--   dbms_output.put_line(' after calendar code');

  OPEN seqnum_cursor(g_plan_start_date);
  FETCH seqnum_cursor INTO g_plan_start_seq;
  CLOSE seqnum_cursor;

--   dbms_output.put_line(' after seqnum code');
  -- ----------------------------------
  -- Initialize the bucket cells to 0.
  -- ----------------------------------
  g_error_stmt := 'Debug - initialize - 50';

  FOR v_counter IN 1..(NUM_OF_TYPES * g_num_of_buckets) LOOP
    bucket_cells(v_counter) := 0;
  END LOOP;

   --dbms_output.put_line(' after seeting to 0');

  -- ----------------------------
  -- populate the g_date_seq
  -- memory structure.
  -- ----------------------------
  g_error_stmt := 'Debug - initialize - 70';
   --dbms_output.put_line(' before for loop');
  FOR v_counter IN 1..g_num_of_buckets LOOP
--   dbms_output.put_line(' inside for loop');
--   dbms_output.put_line(' date is ' || g_dates(v_counter));
    OPEN seqnum_cursor(g_dates(v_counter));
    FETCH seqnum_cursor INTO g_date_seq(v_counter);
--    dbms_output.put_line(' seq is ' || g_date_seq(v_counter));
    CLOSE seqnum_cursor;
-- if g_date_seq(v_counter) is null, raise an error
  END LOOP;
  g_error_stmt := 'Debug - initialize - 80';

   --dbms_output.put_line(' end of init');

END initialize;

FUNCTION isWorkDay(p_org_id number, p_inst_id number,
                   p_date Date) return boolean IS
  CURSOR work_c IS
    select mca.seq_num
      from msc_calendar_dates mca,
           msc_trading_partners mtp
     where mtp.sr_tp_id = p_org_id
       and mtp.sr_instance_id = p_inst_id
       and mtp.partner_type = 3
       and mca.calendar_code = mtp.calendar_code
       and mca.exception_set_id = mtp.calendar_exception_set_id
       and mca.calendar_date = trunc(p_date);

  p_seq_number number;
BEGIN
  OPEN work_c;
  FETCH work_c INTO p_seq_number;
  CLOSE work_c;

  if p_seq_number is null then
     return false;
  else
     return true;
  end if;
END isWorkDay;

-- =============================================================================
-- Name: get_number_work_days
-- Desc: returns the number of workdays between start and end date, inclusive
-- =============================================================================
FUNCTION get_number_work_days(
            start_date  DATE,
            end_date    DATE) RETURN NUMBER IS
v_start_seq NUMBER;
v_end_seq   NUMBER;
l_end_date  DATE;
BEGIN
 l_end_date := end_date;
  IF (trunc(start_date) <= trunc(l_end_date)) THEN
    OPEN seqnum_cursor(trunc(start_date));
    FETCH seqnum_cursor INTO v_start_seq;
    CLOSE seqnum_cursor;
    OPEN prior_seqnum_cursor(trunc(l_end_date));
    FETCH prior_seqnum_cursor INTO v_end_seq;
    CLOSE prior_seqnum_cursor;
    g_error_stmt := 'Debug - get_number_work_days - 10 - sdates ';
    if ( v_end_seq - v_start_seq + 1) <= 0 then return 1; end if;
    return (v_end_seq - v_start_seq + 1);
  ELSE
    return(0);
  END IF;
END;

-- =============================================================================
-- Name: compute_days_between
-- Desc: returns the number of workdays between start and end date, inclusive
-- =============================================================================
FUNCTION compute_days_between(
            spread_load NUMBER,
            start_date  DATE,
            end_date    DATE) RETURN NUMBER IS
v_days_between   NUMBER;
BEGIN
  if (spread_load = SYS_YES) then
     v_days_between := get_number_work_days (start_date,end_date) ;
  else
     v_days_between := 1 ;
  end if ;
  if (v_days_between = 0) then v_days_between := 1 ; end if ;
  return(v_days_between) ;
END ;


-- =============================================================================
-- Name: add_to_plan
-- Desc: adds 'quantity' to the correct type and correct bucket cell.
--   If the end_date of the record is populated, then the qty is assumed
--       to have daily rather than total qty. We calculate # of workdays in each
--   bucket in the range of start_date-end_date, and populate each
--   bucket accordingly
-- =============================================================================
PROCEDURE add_to_plan IS
  v_location        NUMBER;
  v_bucket_start    DATE;
  v_counter     NUMBER;
  v_bucket_size     NUMBER;
  v_res_cost        NUMBER := 0;
  cursor res_cost is
    SELECT  NVL(cst.standard_cost, 0)
    FROM    msc_system_items cst
    WHERE   cst.inventory_item_id = activity_rec.assembly_item_id
    AND cst.organization_id = activity_rec.org_id
    AND cst.sr_instance_id = activity_rec.instance_id
    AND cst.plan_id = -1;
BEGIN

  g_error_stmt := 'Debug - add_to_plan - 0';
  -- --------------------------------------------------
  -- Find cost information, note, only for lines we
  -- calculate the line cost in add_to_plan. For
  -- resources, v_res_cost is set to 0 and will
  -- not contribute to the resource cost. Resource
  -- cost is calculated in calculate_cum instead.
  -- dbms_output.put_line(g_error_stmt);
  -- --------------------------------------------------
  IF (activity_rec.resource_id = -1 AND
      activity_rec.type in (PLANNED_ORDER,NONSTD_JOBS,
                DISCRETE_JOBS,REPETITIVE)) THEN
      OPEN res_cost;
      FETCH res_cost INTO v_res_cost;
      CLOSE res_cost;
  END IF;

  g_error_stmt := 'Debug - add_to_plan - 10';
  IF (activity_rec.start_date >= g_dates(g_bucket_count)) THEN
    -- -------------------------------------------------------
    -- We got an activity which falls after the current bucket. So we
    -- will move the bucket counter forward until we find the
    -- bucket where this activity falls.  Note that we should
    -- not advance the counter beyond g_num_of_buckets.
    -- --------------------------------------------------------
    WHILE ((activity_rec.start_date >= g_dates(g_bucket_count)) AND
       (g_bucket_count <= g_num_of_buckets))
    LOOP
      g_bucket_count := g_bucket_count + 1;
    END LOOP;

    ---------------------------------------------------------------
    --- If the activity start date is outside the last bucket there
    --- is no need to add this activity to any bucket.
    ---------------------------------------------------------------
    if(activity_rec.start_date >= g_dates(g_bucket_count)) THEN
        return;
    end if;

  END IF;

  IF (activity_rec.end_date is null) THEN
    -- -------------------------------------------------------
    -- end date is null,  we assume that the quantity
    -- stands for total quantity and we dump the total
    -- quantity on the first bucket
    -- --------------------------------------------------------
    g_error_stmt := 'Debug - add_to_plan - 20';
    v_location := ((activity_rec.type-1) * g_num_of_buckets) +
        g_bucket_count - 1;
    bucket_cells(v_location) := bucket_cells(v_location) +
        activity_rec.quantity;
    v_location := ((RESOURCE_COST-1) * g_num_of_buckets) +
        g_bucket_count - 1;
    bucket_cells(v_location) := bucket_cells(v_location) +
        activity_rec.quantity * v_res_cost;

  ELSE  -- IF (activity_rec.end_date is not null) THEN
    -- -------------------------------------------------------
    -- If end date is not null, we assume that the quantity
    -- stands for daily quantity.  We multiply the daily qty
    -- by the # of workdays in each bucket to find the bucketed
    -- quantity
    -- --------------------------------------------------------
    g_error_stmt := 'Debug - add_to_plan - 30';
    v_counter := g_bucket_count;

    -- --------------------------------------------------------
    -- We only count availability starting from the start
    -- date of the first bucket; however, we count pass due
    -- resource requirements
    -- --------------------------------------------------------
    IF (activity_rec.type in (AVAILABLE_HOURS,CAP_CHANGES)) THEN
      v_bucket_start := greatest(activity_rec.start_date,g_dates(1),
            g_plan_start_date);
    ELSE
      v_bucket_start := activity_rec.start_date;
    END IF;

    -- -------------------------------------------------------
    -- This loop loads data from the first bucket until
    -- the bucket before last. Last bucket needs special logic
    -- --------------------------------------------------------
    -- Looping inside an activity_rec is not required for
    -- optimized/constrained plans as they generated daily req
    -- --------------------------------------------------------
    WHILE((v_counter <= g_num_of_buckets) AND
           (activity_rec.end_date >= g_dates(v_counter)) AND
             (g_optimized_plan = SYS_NO))
    LOOP
      g_error_stmt := 'Debug - add_to_plan - 40 - loop'||to_char(v_counter);
	 /*Calculating bucket size for a special case of past due bucket bug#7195688

        If resource start_date is 23-Dec 2008, resource end_date is 02-Jan 2009 and plan start date is 31-Dec 2008 then
        past due bucket in HP should be shown with (no.of work days b/w 23-Dec, 30-Dec)*daily_resource_hours.
        But earlier, we were adding daily_resource_hours only once for the entire period 23-Dec to 30-Dec.
        */
      if v_counter=2 then  -- only while populating past due bucket.
         v_bucket_size := get_number_work_days(v_bucket_start,g_dates(v_counter-1)); --bug#7195688
      else
         v_bucket_size := 1;
      end if;

      if isWorkDay(activity_rec.org_id, activity_rec.instance_id,
                   v_bucket_start) then
         v_location := ((activity_rec.type-1) * g_num_of_buckets) +
                v_counter - 1;
         bucket_cells(v_location) := bucket_cells(v_location) +
                activity_rec.quantity*v_bucket_size;

         v_location := ((RESOURCE_COST-1) * g_num_of_buckets) +
                v_counter - 1;
         bucket_cells(v_location) := bucket_cells(v_location) +
                activity_rec.quantity * v_res_cost*v_bucket_size;
      end if;
      v_bucket_start := g_dates(v_counter);
      -- ------------------------------------------------------
      -- For Debuging, uncomment following
       --dbms_output.put_line('Ay_id'||to_char(activity_rec.assembly_item_id));
       --dbms_output.put_line('D_id'||to_char(activity_rec.department_id));
       --dbms_output.put_line('R_id'||to_char(activity_rec.resource_id));
       --dbms_output.put_line('Type - '||to_char(activity_rec.type));
       --dbms_output.put_line('Start - '||to_char(activity_rec.start_date));
       --dbms_output.put_line('End - '||to_char(activity_rec.end_date));
       --dbms_output.put_line('Qty - '||to_char(activity_rec.quantity));
      -- dbms_output.put_line('Buc - '||to_char(v_counter-1));
      -- dbms_output.put_line('Buc size - '||to_char(v_bucket_size));
      -- dbms_output.put_line('Buc Start - '||to_char(g_dates(v_counter-1)));
      -- dbms_output.put_line('=========');
      ------------------------------------------------------
      v_counter := v_counter + 1;
    END LOOP;
    -- ----------------------------------------------------
    -- Load the last bucket. We first find the number
    -- of workdays in the last time bucket.
    -- ----------------------------------------------------
    g_error_stmt := 'Debug - add_to_plan - 50';
    IF (activity_rec.end_date = activity_rec.start_date AND
    activity_rec.type in (AVAILABLE_HOURS,CAP_CHANGES)) THEN
      -- -----------------------------------------------
      -- The special case: If user has added a
      -- workday on a non-workday, we need to include it.
      -- We know a workday has been added if the
      -- start_date = end_date
      -- ------------------------------------------------
      v_bucket_size := 1;
    ELSE
      IF (activity_rec.end_date <= g_dates(v_counter)) THEN
        v_bucket_size := get_number_work_days(v_bucket_start,
        activity_rec.end_date);
      ELSE
        v_bucket_size := get_number_work_days(v_bucket_start,
        g_dates(v_counter-1));
      END IF;

    END IF;
      v_location := ((activity_rec.type-1) * g_num_of_buckets) +
                    v_counter - 1;
      bucket_cells(v_location) := bucket_cells(v_location) +
        v_bucket_size * activity_rec.quantity;
      v_location := ((RESOURCE_COST-1) * g_num_of_buckets) +
        v_counter - 1;
      bucket_cells(v_location) := bucket_cells(v_location) +
        v_bucket_size * activity_rec.quantity * v_res_cost;
      v_counter := v_counter + 1;
    -- ------------------------------------------------------
    -- For Debuging, uncomment following
    -- dbms_output.put_line('Ay_id'||to_char(activity_rec.assembly_item_id));
    -- dbms_output.put_line('D_id'||to_char(activity_rec.department_id));
    -- dbms_output.put_line('R_id'||to_char(activity_rec.resource_id));
    -- dbms_output.put_line('Type - '||to_char(activity_rec.type));
    -- dbms_output.put_line('Start - '||to_char(activity_rec.start_date));
    -- dbms_output.put_line('End - '||to_char(activity_rec.end_date));
    -- dbms_output.put_line('Qty - '||to_char(activity_rec.quantity));
    -- dbms_output.put_line('Buc - '||to_char(v_counter-1));
    -- dbms_output.put_line('Buc size - '||to_char(v_bucket_size));
    -- dbms_output.put_line('Buc Start - '||to_char(g_dates(v_counter-1)));
    -- dbms_output.put_line('=========');
    ------------------------------------------------------
  END IF;

END add_to_plan;



-- =============================================================================
-- Name: calculate_cum
-- Desc: Some types of data need to be calculated or cumulated across dates. This
--       procedure takes care of that
-- =============================================================================
PROCEDURE calculate_cum(
        p_org_id        NUMBER,
        p_inst_id       NUMBER,
        p_dept_id       NUMBER,
        p_res_id        NUMBER) IS

  v_loop        BINARY_INTEGER := 1;
  v_cum_net_available   NUMBER := 0;
  v_cum_available   NUMBER := 0;
  v_cum_required    NUMBER := 0;
  v_cum_changes     NUMBER := 0;
  v_overhead        NUMBER := 0;
  v_res_cost        NUMBER := 0;
  v_num_days        NUMBER := 0;
  v_batchable number :=0;

  cursor isBatchAble is
  select nvl(Batchable_flag,2)
  from   msc_department_resources
  where department_id = p_dept_id
  and   resource_id = p_res_id
  and   plan_id = g_designator
  and   organization_id = p_org_id
  and   sr_instance_id = p_inst_id;

BEGIN

  g_error_stmt := 'Debug - calculate_cum - 5';
  OPEN isBatchAble;
  FETCH isBatchAble into v_batchable;
  CLOSE isBatchAble;

  -- ---------------------------------
  -- The following will be calculated:
  --  REQUIRED_HOURS
  --  NET_AVAILABLE
  --  CUM_AVAILABLE
  --  UTILIZATION
  --  CUM_UTILIZATION
  --  DAILY_REQUIRED
  --  DAILY_AVAILABLE
  --  RESOURCE_COST
  --  ATP_NET
  -- -----------------------------
  IF (p_res_id <> -1) AND g_current_data <> SYS_TRANS THEN

    SELECT DISTINCT NVL(dept_overhead_cost,0)
    INTO    v_overhead
    FROM    msc_department_resources
    WHERE   organization_id = p_org_id
    AND     sr_instance_id = p_inst_id
    AND     department_id = p_dept_id
    AND     plan_id = -1;

    IF v_overhead is NULL THEN
      v_overhead := 0;
    END IF;

    BEGIN
      SELECT (1 + v_overhead)*NVL(res.resource_cost,0)
      INTO  v_res_cost
      FROM  msc_department_resources res
      WHERE res.organization_id = p_org_id
      AND   res.sr_instance_id = p_inst_id
      AND   res.department_id = p_dept_id
      AND   res.resource_id = p_res_id
      AND   res.plan_id = -1;
    EXCEPTION when no_data_found THEN
      v_res_cost := 0;
      NULL;
    END;
  END IF;

  g_error_stmt := 'Debug - calculate_cum - 10';
  FOR v_loop IN 1..g_num_of_buckets LOOP
    IF g_current_data = SYS_TRANS THEN

      IF (bucket_cells((WT_AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) <= 0) THEN
        bucket_cells((WT_LOAD_RATIO-1)*g_num_of_buckets+v_loop) := NULL;
      ELSE
        bucket_cells((WT_LOAD_RATIO-1)*g_num_of_buckets+v_loop) := 100 *
        bucket_cells((WT_REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) /
        bucket_cells((WT_AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop);
      END IF;
      IF (bucket_cells((VL_AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) <= 0) THEN
        bucket_cells((VL_LOAD_RATIO-1)*g_num_of_buckets+v_loop) := NULL;
      ELSE
        bucket_cells((VL_LOAD_RATIO-1)*g_num_of_buckets+v_loop) := 100 *
        bucket_cells((VL_REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) /
        bucket_cells((VL_AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop);
      END IF;
    ELSE

    -- -------------------
    -- Setup Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
/*
    if v_loop > 498 then
     --dbms_output.put_line(g_error_stmt);
    end if;
*/
     --dbms_output.put_line('batchable is ' || v_batchable);
     v_batchable := 0;

 --   if v_batchable <> 1 then
    bucket_cells((SETUP_HOURS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((PLANNED_ORDER_SETUP-1)*g_num_of_buckets+v_loop) +
        bucket_cells((NONSTD_JOBS_SETUP-1)*g_num_of_buckets+v_loop) +
        bucket_cells((DISCRETE_JOBS_SETUP-1)*g_num_of_buckets+v_loop) +
        bucket_cells((ATP_ADJUSTMENT_SETUP-1)*g_num_of_buckets+v_loop) +
        bucket_cells((REPETITIVE_SETUP-1)*g_num_of_buckets+v_loop);
 --   end if;


 --   dbms_output.put_line( ' dscrete jobs ' ||  bucket_cells((DISCRETE_JOBS_RUN-1)*g_num_of_buckets+v_loop));
    -- -------------------
    -- Run Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);

     bucket_cells((RUN_HOURS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((PLANNED_ORDER_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((NONSTD_JOBS_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((DISCRETE_JOBS_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((ATP_ADJUSTMENT_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((REPETITIVE_RUN-1)*g_num_of_buckets+v_loop);

 /*
     if v_loop > 498 then
    --dbms_output.put_line('after run hours');
    end if;
*/
    -- -------------------
    -- Planned Ordres
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
    if v_batchable <> 1 then
    bucket_cells((PLANNED_ORDER -1)*g_num_of_buckets+v_loop) :=
        bucket_cells((PLANNED_ORDER_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((PLANNED_ORDER_SETUP-1)*g_num_of_buckets+v_loop) ;
    end if;

    -- -------------------
    -- Non Std Jobs
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
    if v_batchable <> 1 then
    bucket_cells((NONSTD_JOBS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((NONSTD_JOBS_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((NONSTD_JOBS_SETUP-1)*g_num_of_buckets+v_loop) ;
    end if;

   -- dbms_output.put_line( ' dscrete jobs 2 ----' ||  bucket_cells((DISCRETE_JOBS_RUN-1)*g_num_of_buckets+v_loop));
    -- -------------------
    -- Discrete Jobs
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
    if v_batchable <> 1 then
    bucket_cells((DISCRETE_JOBS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((DISCRETE_JOBS_RUN-1)*g_num_of_buckets+v_loop) +
        bucket_cells((DISCRETE_JOBS_SETUP-1)*g_num_of_buckets+v_loop) ;
    end if;


    -- -------------------
    -- Required Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
--    if v_batchable <> 1 then
    bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((SETUP_HOURS-1)*g_num_of_buckets+v_loop) +
        bucket_cells((RUN_HOURS-1)*g_num_of_buckets+v_loop) ;
--    end if;
/*
    if v_loop > 498 then
   --dbms_output.put_line(' after req hours');
    end if;
*/


    -- -------------------
    -- Available hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 25 - loop'||to_char(v_loop);

    bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) +
        bucket_cells((CAP_CHANGES-1)*g_num_of_buckets+v_loop);


    -- -------------------
    -- Setup Hour Ratio
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
    IF (bucket_cells((SETUP_HOURS-1)*g_num_of_buckets+v_loop) <= 0) THEN
      bucket_cells((SETUP_HOUR_RATIO-1)*g_num_of_buckets+v_loop) := NULL;
    ELSE
    /*
    bucket_cells((SETUP_HOUR_RATIO-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((SETUP_HOURS-1)*g_num_of_buckets+v_loop) /
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) ;
    */

    -- Bug #4207855

      IF (bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) <= 0)THEN
          bucket_cells((SETUP_HOUR_RATIO-1)*g_num_of_buckets+v_loop) := NULL;
      ELSE
          bucket_cells((SETUP_HOUR_RATIO-1)*g_num_of_buckets+v_loop) :=
          bucket_cells((SETUP_HOURS-1)*g_num_of_buckets+v_loop) /
          bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) ;
      END IF;


    end if;

    -- -------------------
    -- RUN Hour Ratio
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);

    IF (bucket_cells((RUN_HOURS-1)*g_num_of_buckets+v_loop) <= 0) THEN
      bucket_cells((RUN_HOUR_RATIO-1)*g_num_of_buckets+v_loop) := NULL;
    ELSE
   /*
    bucket_cells((RUN_HOUR_RATIO-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((RUN_HOURS-1)*g_num_of_buckets+v_loop) /
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) ;
   */
   -- Bug #4207855

      IF (bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) <= 0)THEN
          bucket_cells((RUN_HOUR_RATIO-1)*g_num_of_buckets+v_loop) := NULL;
      ELSE
          bucket_cells((RUN_HOUR_RATIO-1)*g_num_of_buckets+v_loop) :=
          bucket_cells((RUN_HOURS-1)*g_num_of_buckets+v_loop) /
          bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) ;
      END IF;

    end if;
/*
    if v_loop > 498 then
    dbms_output.put_line(' after req hours ratio');
    end if;
*/

    -- -------------------
    -- Net Available Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 30 - loop'||to_char(v_loop);

    bucket_cells((NET_AVAILABLE-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) -
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop);

    -- ----------------------------
    -- Cumulatitive Available Hours
    -- ----------------------------

    v_cum_net_available := v_cum_net_available +
        nvl(bucket_cells((NET_AVAILABLE-1)*g_num_of_buckets+v_loop),0);
    bucket_cells((CUM_AVAILABLE-1)*g_num_of_buckets+v_loop) := v_cum_net_available;

    -- ----------------------------
    -- Capacity Utilization
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 40 - loop'||to_char(v_loop);

    IF (bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) <= 0) THEN
      bucket_cells((UTILIZATION-1)*g_num_of_buckets+v_loop) := NULL;
    ELSE
      bucket_cells((UTILIZATION-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) /
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop);
    END IF;

    -- ----------------------------
    -- Cum Capacity Utilization
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 50 - loop'||to_char(v_loop);
    v_cum_required := v_cum_required +
        nvl(bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop),0);
    v_cum_available := v_cum_available +
        nvl(bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop),0);
    IF (v_cum_available <= 0) THEN
      bucket_cells((CUM_UTILIZATION-1)*g_num_of_buckets+v_loop) := NULL;
    ELSE
      bucket_cells((CUM_UTILIZATION-1)*g_num_of_buckets+v_loop) :=
        v_cum_required / v_cum_available;
    END IF;

    -- ----------------------------
    -- Daily Required Hours and
    -- Daily Available Hours
    -- ----------------------------
/*
    if v_loop > 498 then
      --dbms_output.put_line(' before daily hours');
    end if;
*/
    g_error_stmt := 'Debug - calculate_cum - 60 - loop'||to_char(v_loop);
    IF (v_loop = 1) THEN
      v_num_days := g_date_seq(v_loop+1) -
            greatest(g_date_seq(v_loop), g_plan_start_seq);
    ELSIF (v_loop < g_num_of_buckets) then
      v_num_days := g_date_seq(v_loop+1) - g_date_seq(v_loop);
    ELSE
      v_num_days := 1;
    END IF;
    if (v_num_days <> 0) then
      bucket_cells((DAILY_REQUIRED-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) /
        v_num_days;
      bucket_cells((DAILY_AVAILABLE-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) /
        v_num_days;
    end if;
/*
    if v_loop > 498 then
      --dbms_output.put_line(' after  daily hours');
    end if;
*/
   ---------------------------------------------
   --ATP_NET is calculated as
   --available hours - atp_required_hours
   ---------------------------------------------
      g_error_stmt := 'Debug - calculate_cum - 70 - loop'||to_char(v_loop);
      bucket_cells((ATP_NET-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) -
        bucket_cells((ATP_REQUIRED_HOURS-1)*g_num_of_buckets+v_loop);
/*
 IF bucket_cells((ATP_REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) <> 0 THEN
 --dbms_output.put_line('ATP_REQUIRED_HOURS '||
  bucket_cells((ATP_REQUIRED_HOURS-1)*g_num_of_buckets+v_loop));
 END IF;
*/
    -- --------------------------
    -- Cost for lines are already
    -- populated in add_plan
    -- --------------------------
    IF (p_res_id <> -1) THEN
      bucket_cells((RESOURCE_COST-1)*g_num_of_buckets+v_loop) := v_res_cost *
    bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop);
    END IF;

    END IF;
  END LOOP;
   --dbms_output.put_line(' leaving calculate cum');

END calculate_cum;




-- =============================================================================
-- Name: flush_crp_plan
-- Desc: It inserts the date for 1 dept/res or line into CRP_CAPACITY_PLANS
-- =============================================================================
PROCEDURE flush_crp_plan(
        p_org_id        NUMBER,
        p_inst_id       NUMBER,
        p_dept_id       NUMBER,
        p_res_id        NUMBER,
        p_res_instance_id NUMBER,
        p_serial_number VARCHAR2) IS
  v_dept_code       VARCHAR2(100) := '';
  v_line_code       VARCHAR2(100) := '';
  v_dept_class_code VARCHAR2(100) := '';
  v_res_code        VARCHAR2(100) := '';
  v_res_grp_name    VARCHAR2(300) := '';
  v_resource_type_code  VARCHAR2(80) := '';
  v_loop        BINARY_INTEGER := 1;
BEGIN

  IF g_current_data <> SYS_TRANS THEN
  g_error_stmt := 'Debug - flush_crp_plan - 5';
  SELECT  dept_res.department_code,
        dept_res.department_class,
        dept_res.resource_code,
        lkps.meaning,
        dept_res.resource_group_name
  INTO    v_dept_code,
        v_dept_class_code,
        v_res_code,
        v_resource_type_code,
        v_res_grp_name
  FROM    mfg_lookups lkps,
        msc_department_resources dept_res
  WHERE   lkps.lookup_type(+) = 'BOM_RESOURCE_TYPE'
    AND     lkps.lookup_code(+) = dept_res.resource_type
    AND     dept_res.plan_id = -1
    AND     dept_res.organization_id = p_org_id
    AND     dept_res.sr_instance_id = p_inst_id
    AND     dept_res.department_id = p_dept_id
    AND     dept_res.resource_id = p_res_id;
  END IF;


  g_error_stmt := 'Debug - flush_crp_plan - 10';
  FOR v_loop IN 1..g_num_of_buckets LOOP

    g_error_stmt := 'Debug - flush_crp_plan - 30 - loop'||to_char(v_loop);
    INSERT INTO msc_capacity_plans(
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    organization_id,
    sr_instance_id,
    department_id,
    resource_id,
    department_name,
    department_class,
    resource_name,
    resource_type,
    resource_group_name,      -- Will store the serial number
    quantity36,               -- Will store the res_instance_id
    bucket_type,
    bucket_date,
    quantity1,    quantity2,    quantity3,    quantity4,
    quantity5,    quantity6,    quantity7,    quantity8,
    quantity9,    quantity10,   quantity11,   quantity12,
    quantity13,   quantity14,   quantity15,   quantity16,
    quantity17,	  quantity18,   quantity19,   quantity20,
    quantity21)
    VALUES (
    g_query_id,
    SYSDATE,
    -1,
    SYSDATE,
    -1,
    -1,
    p_org_id,
    p_inst_id,
    DECODE(g_current_data,3,-1,p_dept_id),
    p_res_id,
    v_dept_code,
    v_dept_class_code,
    v_res_code,
    v_resource_type_code,
    p_serial_number,
    p_res_instance_id,
    g_bucket_type,
    g_dates(v_loop),
    bucket_cells(v_loop+g_num_of_buckets*0), -- available hours
    bucket_cells(v_loop+g_num_of_buckets*1), -- required hours
    bucket_cells(v_loop+g_num_of_buckets*2), -- NET_AVAILABLE
    bucket_cells(v_loop+g_num_of_buckets*3), -- CUM_AVAILABLE
    bucket_cells(v_loop+g_num_of_buckets*4), -- UTILIZATION
    bucket_cells(v_loop+g_num_of_buckets*5), -- CUM_UTILIZATION
    bucket_cells(v_loop+g_num_of_buckets*6), -- DAILY_REQUIRED
    bucket_cells(v_loop+g_num_of_buckets*7), -- DAILY_AVAILABLE
    bucket_cells(v_loop+g_num_of_buckets*8), -- RESOURCE_COST
    bucket_cells(v_loop+g_num_of_buckets*9), -- CAP_CHANGES
    bucket_cells(v_loop+g_num_of_buckets*10),
    bucket_cells(v_loop+g_num_of_buckets*11),
    bucket_cells(v_loop+g_num_of_buckets*12),
    bucket_cells(v_loop+g_num_of_buckets*13),
    bucket_cells(v_loop+g_num_of_buckets*14),
    bucket_cells(v_loop+g_num_of_buckets*15),
    bucket_cells(v_loop+g_num_of_buckets*16),
    bucket_cells(v_loop+g_num_of_buckets*17),
    bucket_cells(v_loop+g_num_of_buckets*18),
    bucket_cells(v_loop+g_num_of_buckets*19),
    bucket_cells(v_loop+g_num_of_buckets*20) -- atp net
   );
  END LOOP;
END flush_crp_plan;


-- =============================================================================
-- Name: re_initialize
-- Desc: This is called everytime we work on a new dept/resource
--       Initializes cost information as well as calendar code
-- =============================================================================
PROCEDURE re_initialize IS
v_overhead      NUMBER;
BEGIN

      g_bucket_count := 2;

      g_error_stmt := 'Debug - re_initialize - 10';
      -- ----------------------------------
      -- Initialize the bucket cells to 0.
      -- dbms_output.put_line(g_error_stmt);
      -- ----------------------------------
      FOR v_cnt IN 1..NUM_OF_TYPES*g_num_of_buckets LOOP
      bucket_cells(v_cnt) := 0;
      END LOOP;

      g_error_stmt := 'Debug - re_initialize - 20';
      -- ----------------------------
      -- Find the exception_set_id
      -- and calendar_code for this
      -- organization
      -- dbms_output.put_line(g_error_stmt);
      -- ----------------------------
      SELECT calendar_code, calendar_exception_set_id
      INTO   g_calendar_code, g_exc_set_id
      FROM   msc_trading_partners
      WHERE  sr_tp_id = activity_rec.org_id
        AND  sr_instance_id = activity_rec.instance_id
        AND  partner_type = 3;

END re_initialize;


-- =============================================================================
-- Name:populate_horizontal_plan
-- This is the main procedure. It retrieves data from database and calls
-- private procedures to summarize them into user defined buckets.
-- The argument p_current_data tells us whether to use current data
-- or snapshoted data for bucketing.
-- The p_bucket_type tells us what kind of buckets to use for summarization.
--  p_bucket_type   1   -   ??daily buckets??
--          2   -   ??weekly buckets??
--          3   -   ??periodic buckets??
--  p_current_data  1   -   Use current data
--          2   -   Use snapshot data
--
-- =============================================================================
FUNCTION populate_horizontal_plan(
            p_batchable		IN NUMBER,  -- can be removed, no use now
            p_item_list_id      IN NUMBER,
            p_org_id        IN NUMBER,
            p_inst_id        IN NUMBER,
            p_plan_id    IN NUMBER,
            p_bucket_type       IN NUMBER,
            p_cutoff_date       IN DATE,
            p_current_data      IN NUMBER DEFAULT 2) RETURN NUMBER IS

  v_no_rows         	BOOLEAN;
  v_last_dept_id        NUMBER := -2;
  v_last_org_id         NUMBER := -2;
  v_last_inst_id        NUMBER := -2;
  v_last_res_id         NUMBER := -2;
  v_last_res_instance_id NUMBER := -2;
  v_last_serial_number  VARCHAR2(30) := null;
  v_cnt             	NUMBER;
  l_plan_type		NUMBER := 1;

BEGIN

  -- ----------------------------
  -- Initialize Global variables
  -- ----------------------------
  g_error_stmt := 'Debug - populate_horizontal_plan - 10';
  g_item_list_id := p_item_list_id;
  g_org_id := p_org_id;
  g_inst_id := p_inst_id;
  g_designator :=p_plan_id;
  g_bucket_type := p_bucket_type;
  g_cutoff_date := p_cutoff_date;
  g_current_data := p_current_data;

  --dbms_output.put_line(' in populate');

  OPEN  agg_resource;
  FETCH agg_resource INTO v_agg_flag;
  CLOSE agg_resource;

  initialize;
  --dbms_output.put_line(g_error_stmt);

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';
--  dbms_output.put_line(g_error_stmt);

  IF g_current_data = SYS_YES THEN
    null;
  ELSIF g_current_data = SYS_TRANS THEN
    OPEN crp_trans_activity;
  ELSE
    OPEN c_flags(p_plan_id);
    FETCH c_flags INTO opt_flag_status;
    CLOSE c_flags;

    select count(*) into g_daily_counts
    from msc_plan_buckets
    where PLAN_ID = g_designator
    and SR_INSTANCE_ID = g_inst_id
    and ORGANIZATION_ID = g_org_id
    and BUCKET_TYPE = 1;

    IF ( (opt_flag_status.flag1 = SYS_YES ) OR
         (opt_flag_status.flag2 = SYS_YES ) OR
         (opt_flag_status.flag3 = SYS_YES ) OR
         (opt_flag_status.flag4 = SYS_YES ) OR
         (opt_flag_status.flag5 = SYS_YES ) OR
         (opt_flag_status.flag6 = SYS_YES ) )  THEN

       g_optimized_plan := SYS_YES;
    ELSE
       g_optimized_plan := SYS_NO;
    END IF;

   select plan_type into l_plan_type
   from msc_plans
   where plan_id = p_plan_id;
   if ( l_plan_type = 4 ) then   	-- sro plan
      g_optimized_plan := SYS_NO;
   end if;

    IF g_res_instance_case = TRUE THEN
       OPEN crp_res_inst_snapshot_activity;
    ELSE
       OPEN crp_snapshot_activity;
    END IF;

  END IF;


  -- ----------------------------
  -- Fetch rows from cursor
  -- and process them one by one
  -- ----------------------------
  LOOP
    v_no_rows := FALSE;
    g_error_stmt := 'Debug - populate_horizontal_plan - 30';
   -- dbms_output.put_line(g_error_stmt);

    IF g_current_data = SYS_YES THEN
      null;
    ELSIF g_current_data = SYS_TRANS THEN
      FETCH crp_trans_activity INTO activity_rec;
      IF (crp_trans_activity%NOTFOUND) THEN
        v_no_rows := TRUE;
      END IF;

    ELSIF g_res_instance_case = TRUE THEN
--       dbms_output.put_line(' INSTANCE CASE, going to open cursor ');
       FETCH crp_res_inst_snapshot_activity INTO activity_rec;
       IF (crp_res_inst_snapshot_activity%NOTFOUND) THEN
          v_no_rows := TRUE;
          --dbms_output.put_line('IN pls nothing is found in the cursor');
       END IF;
    ELSE
       FETCH crp_snapshot_activity INTO activity_rec;
       IF (crp_snapshot_activity%NOTFOUND) THEN
         v_no_rows := TRUE;
       --dbms_output.put_line('IN pls nothing is found in the cursor');
       END IF;


    END IF;

    g_error_stmt := 'Debug - populate_horizontal_plan - 40';
   --   dbms_output.put_line(g_error_stmt);

    IF ((v_no_rows OR
     v_last_org_id       <> activity_rec.org_id OR
     v_last_inst_id      <> activity_rec.instance_id OR
     v_last_dept_id      <> activity_rec.department_id OR
     v_last_res_instance_id <> activity_rec.resource_instance_id OR
     v_last_serial_number   <> activity_rec.serial_number OR
     v_last_res_id          <> activity_rec.resource_id) AND
     v_last_dept_id         <> -2) THEN
      -- ==================================================
      -- snapshoting for the last dept/res has finished
      -- We therefore calculate cumulative information,
      -- flush the previous set of data and then
      -- re-initialized for the current dept/res
      -- ==================================================
      g_error_stmt := 'Debug - populate_horizontal_plan - 50';
      --dbms_output.put_line('just b4 calling calculate_cum ' || g_num_of_buckets);
      calculate_cum(v_last_org_id,v_last_inst_id,v_last_dept_id,v_last_res_id);

      g_error_stmt := 'Debug - populate_horizontal_plan - 60';
      --dbms_output.put_line(g_error_stmt);
      flush_crp_plan(v_last_org_id,v_last_inst_id,v_last_dept_id,v_last_res_id,
                     v_last_res_instance_id, v_last_serial_number);

      g_error_stmt := 'Debug - populate_horizontal_plan - 70';
      --dbms_output.put_line(g_error_stmt);
      re_initialize;
    END IF;

    EXIT WHEN v_no_rows;

    g_error_stmt := 'Debug - populate_horizontal_plan - 85';
    -- ---------------------------------------------------------
    -- Add the retrieved activity to the plan
    -- dbms_output.put_line(g_error_stmt);
    -- ---------------------------------------------------------
    add_to_plan;

    v_last_org_id := activity_rec.org_id;
    v_last_inst_id := activity_rec.instance_id;
    v_last_res_id := activity_rec.resource_id;
    v_last_res_instance_id := activity_rec.resource_instance_id;
    v_last_dept_id := activity_rec.department_id;
    v_last_serial_number := activity_rec.serial_number;
  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 90';
  -- dbms_output.put_line(g_error_stmt);
  IF g_current_data = SYS_YES THEN
    null;
  ELSIF g_current_data = SYS_TRANS THEN
    CLOSE crp_trans_activity;
  ELSIF g_res_instance_case = TRUE THEN
    CLOSE crp_res_inst_snapshot_activity;
  ELSE
     CLOSE crp_snapshot_activity;
  END IF;

  return g_query_id;

EXCEPTION WHEN others THEN
--  dbms_output.put_line(g_error_stmt);
  IF (seqnum_cursor%ISOPEN) THEN
    close seqnum_cursor;
  END IF;
  IF (crp_trans_activity%ISOPEN) THEN
    close crp_trans_activity;
  END IF;
  IF (crp_snapshot_activity%ISOPEN) THEN
    close crp_snapshot_activity;
  END IF;
  IF (crp_res_inst_snapshot_activity%ISOPEN) THEN
    close crp_res_inst_snapshot_activity;
  END IF;
  raise;
END populate_horizontal_plan;

PROCEDURE query_list(p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_org_list IN VARCHAR2,
                p_dept_list IN VARCHAR2,
                p_res_list IN VARCHAR2,
                p_data IN NUMBER,
                p_inst_list IN VARCHAR2 DEFAULT NULL,
                p_serial_num_list IN VARCHAR2 DEFAULT NULL) IS

  sql_stmt      VARCHAR2(4000);
  NODE_REGULAR_ITEM CONSTANT NUMBER :=0;
  NODE_ITEM_SUPPLIER CONSTANT NUMBER := 1;
  NODE_DEPT_RES CONSTANT NUMBER := 2;
  NODE_LINE CONSTANT NUMBER := 3;
  NODE_TRANS_RES CONSTANT NUMBER := 4;
  NODE_PF_ITEM CONSTANT NUMBER := 5;
  NODE_GL_FORECAST_ITEM CONSTANT NUMBER := 6;
  NODE_RES_INSTANCE CONSTANT NUMBER := 7;

BEGIN

    --dbms_output.put_line(' in query list ');
    --dbms_output.put_line(' value of p_inst_list is  ' || p_inst_list);
    --dbms_output.put_line(' value of sreial number is  ' || p_serial_num_list);

    sql_stmt := 'INSERT INTO msc_form_query ( '||
        'query_id, '||
        'last_update_date, '||
        'last_updated_by, '||
        'creation_date, '||
        'created_by, '||
        'last_update_login, '||
        'number1, '||  -- org id
        'number2, '||  -- dept id
        'number3, '||  -- res id
        'number4, '||  -- sr_instance
        'number5, '||  -- owning dept id
        'number7, '||  -- node_type
        'number8, '||  -- RES INSTANCE ID
        'char1, '||
        'char2, '||
        'char3) '||    -- SERIAL NUMBER
     ' SELECT DISTINCT '|| p_query_id || ', '||
        'sysdate, '||
        '1, '||
        'sysdate, '||
        '1, '||
        '1, ';

  IF p_data = 3 THEN

     g_res_instance_case := false;
     sql_stmt := sql_stmt ||
        'to_organization_id, '||
        '-1, '||
        'transaction_id, '||
        'sr_instance_id, '||
        'from_organization_id, '||
        NODE_TRANS_RES ||
        ',-1 ' ||
        ',msc_get_name.org_code(to_organization_id,sr_instance_id), '||
        'ship_method, '||
        '''  ''' || -- insert an empty space, otherwise will error out in java
        ' FROM msc_interorg_ship_methods '||
        'WHERE transaction_id in ('||p_res_list||') ' ||
        'AND (sr_instance_id,to_organization_id) in ('||p_org_list||') ';

  ELSE
  if (p_inst_list = 'RES') then    -- Resource Case

     g_res_instance_case := false;
    --dbms_output.put_line(' in RESOURCE CASE ');
    sql_stmt := sql_stmt ||
        'organization_id, '||
        'department_id, '||
        'resource_id, '||
        'sr_instance_id, '||
        'nvl(owning_department_id, department_id), '||
        'decode(resource_id,-1,'||NODE_LINE||','||NODE_DEPT_RES||'),'||
        '-1, ' ||
        'decode(resource_id,-1, msc_get_name.org_code(organization_id,sr_instance_id), department_code), '||
        'decode(resource_id,-1,department_code, resource_code), '||
        '-1 ' ||
    'FROM msc_department_resources '||
    'WHERE department_id in ('||p_dept_list||') ' ||
    'AND resource_id in ('||p_res_list||') ' ||
    'AND (sr_instance_id,organization_id) in ('||p_org_list||') ' ||
    'AND plan_id = '||p_plan_id;
   else

    --dbms_output.put_line(' in INSTANCE CASE ');
     g_res_instance_case := true;

    sql_stmt := sql_stmt ||
        'organization_id, '||
        'department_id, '||
        'resource_id, '||
        'sr_instance_id, '||
        'department_id, '||
        'decode(resource_id,-1,'||NODE_LINE||','||NODE_RES_INSTANCE||'),'||
        'res_instance_id, ' ||
        '-1, '||
        'serial_number, '||
        'serial_number '||
    'FROM msc_dept_res_instances '||
    'WHERE department_id in ('||p_dept_list||') ' ||
    'AND resource_id in ('||p_res_list||') ' ||
    'AND res_instance_id in ('||p_inst_list||') ' ||
 --   'AND serial_number in ('''||p_serial_num_list||''' ) ' ||
    'AND serial_number in (' || p_serial_num_list|| ' ) ' ||
    'AND (sr_instance_id,organization_id) in ('||p_org_list||') ' ||
    'AND plan_id = '||p_plan_id;

 end if;

  END IF;
/*
    dbms_output.put_line(' before query list ');
    dbms_output.put_line(substr(sql_stmt,1,200));
    dbms_output.put_line(substr(sql_stmt,201,200));
    dbms_output.put_line(substr(sql_stmt,401,200));
*/

  EXECUTE IMMEDIATE sql_stmt;


END query_list;

END msc_crp_horizontal_plan;

/

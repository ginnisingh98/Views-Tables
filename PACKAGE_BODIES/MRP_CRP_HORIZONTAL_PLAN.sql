--------------------------------------------------------
--  DDL for Package Body MRP_CRP_HORIZONTAL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CRP_HORIZONTAL_PLAN" AS
/*  $Header: MRPHCPLB.pls 120.3 2006/09/21 11:55:50 davashia noship $ */

SYS_YES         CONSTANT INTEGER := 1;
SYS_NO          CONSTANT INTEGER := 2;

NUM_OF_COLUMNS      CONSTANT INTEGER := 36;
NUM_OF_TYPES        CONSTANT INTEGER := 16;

ROUTING_BASED       CONSTANT INTEGER := 2;
RATE_BASED      CONSTANT INTEGER := 3;

DELETE_WORK_DAY     CONSTANT INTEGER := 1;
MODIFY_WORK_DAY     CONSTANT INTEGER := 2;
ADD_WORK_DAY        CONSTANT INTEGER := 3;

AVAILABLE_HOURS     CONSTANT INTEGER := 1;
REQUIRED_HOURS      CONSTANT INTEGER := 2;
NET_AVAILABLE       CONSTANT INTEGER := 3;
CUM_AVAILABLE       CONSTANT INTEGER := 4;
UTILIZATION     CONSTANT INTEGER := 5;
CUM_UTILIZATION     CONSTANT INTEGER := 6;
DAILY_REQUIRED      CONSTANT INTEGER := 7;
DAILY_AVAILABLE     CONSTANT INTEGER := 8;
RESOURCE_COST       CONSTANT INTEGER := 9;
CAP_CHANGES     CONSTANT INTEGER := 10;
CUM_CAP_CHANGES     CONSTANT INTEGER := 11;
PLANNED_ORDER       CONSTANT INTEGER := 12;
NONSTD_JOBS     CONSTANT INTEGER := 13;
DISCRETE_JOBS       CONSTANT INTEGER := 14;
REPETITIVE      CONSTANT INTEGER := 15;

M_PLANNED_ORDER     CONSTANT INTEGER := 5;
M_NONSTD_JOBS       CONSTANT INTEGER := 7;
M_DISCRETE_JOBS     CONSTANT INTEGER := 3;
M_REPETITIVE        CONSTANT INTEGER := 4;
M_FLOW_SCHEDULES    CONSTANT INTEGER := 27;

WIP_DISCRETE        CONSTANT INTEGER := 1;  /* WIP_DISCRETE_JOB */
WIP_NONSTANDARD     CONSTANT INTEGER := 3;


JOB_UNRELEASED      CONSTANT INTEGER := 1;/* job status code*/
JOB_RELEASED        CONSTANT INTEGER := 3;
JOB_COMPLETE        CONSTANT INTEGER := 4;
COMPLETE_NO_CHARGES     CONSTANT INTEGER := 5;
JOB_HOLD        CONSTANT INTEGER := 6;
JOB_CANCELLED       CONSTANT INTEGER := 7;

PEND_BILL       CONSTANT INTEGER := 8;
FAIL_BILL       CONSTANT INTEGER := 9;
PEND_ROUT       CONSTANT INTEGER := 10;
FAIL_ROUT       CONSTANT INTEGER := 11;
CLSD_NO_CHARGES     CONSTANT INTEGER := 12;

BASIS_PER_ITEM      CONSTANT INTEGER := 1;
BASIS_PER_LOT       CONSTANT INTEGER := 2;
/** Bug 1965639 : The following are introduced to evaluate
    department overheads depending on the OVERHEAD BASIS */
BASIS_RESOURCE_UNITS       CONSTANT INTEGER := 3;
BASIS_RESOURCE_VALUE       CONSTANT INTEGER := 4;

CST_FROZEN      CONSTANT INTEGER := 1;

BOM_EVENTS      CONSTANT INTEGER := 1;
BOM_PROCESSES       CONSTANT INTEGER := 2;
BOM_LINE_OPS        CONSTANT INTEGER := 3;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE column_char IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE crp_activity IS RECORD
    (org_id     NUMBER,
     assembly_item_id NUMBER,
     department_id  NUMBER,
     resource_id    NUMBER,
     line_id    NUMBER,
     type       NUMBER,
         start_date     DATE,
         end_date       DATE,
     quantity   NUMBER);

g_bucket_count      NUMBER := 2;
g_calendar_code     VARCHAR2(10);
g_hour_uom      VARCHAR2(10);
g_exc_set_id        NUMBER;
g_item_list_id      NUMBER;
g_query_id      NUMBER;
g_org_id        NUMBER;
g_planned_org       NUMBER;
g_spread_load       NUMBER;
g_plan_start_seq    NUMBER;
g_plan_start_date   DATE;
g_cutoff_date       DATE;
g_designator        VARCHAR2(10);
g_current_data      NUMBER;
g_bucket_type       NUMBER;
g_error_stmt        VARCHAR2(50);

g_dates         calendar_date;
g_date_seq      column_number;
bucket_cells        column_number;
activity_rec        crp_activity;

CURSOR seqnum_cursor(p_date DATE) IS
    SELECT next_seq_num
    FROM   bom_calendar_dates
    WHERE  calendar_code = g_calendar_code
    AND    exception_set_id = g_exc_set_id
    AND    calendar_date = p_date;

CURSOR prior_seqnum_cursor(p_date DATE) IS
    SELECT prior_seq_num
    FROM   bom_calendar_dates
    WHERE  calendar_code = g_calendar_code
    AND    exception_set_id = g_exc_set_id
    AND    calendar_date = p_date;

CURSOR crp_current_activity IS
-- ===================================
-- Planned Order Dept/Res Requirement - tested
-- ??Do not know how to spread load??
-- ===================================
  SELECT
    recom.organization_id,
    recom.inventory_item_id,
    list.number2,
    routing.resource_id,
    -1,
    PLANNED_ORDER,
    TRUNC(res_start.calendar_date),
    to_date(NULL),
    DECODE(routing.basis, BASIS_PER_ITEM,
           GREATEST(routing.runtime_quantity* (nvl(recom.new_order_quantity,
                                         recom.firm_quantity)-
                     NVL(recom.implemented_quantity,0) -
                     NVL(recom.quantity_in_process,0)),0),
           DECODE(SIGN(nvl(recom.new_order_quantity, recom.firm_quantity) -
                                         NVL(recom.implemented_quantity,0) -
                                         NVL(recom.quantity_in_process,0)),
              1, routing.runtime_quantity, 0))
  FROM  bom_calendar_dates res_start,
    bom_calendar_dates order_date,
    mrp_recommendations recom,
    mrp_system_items items,
    mrp_planned_resource_reqs routing,
    mtl_parameters org,
    mrp_form_query list
  WHERE res_start.exception_set_id = org.calendar_exception_set_id
  AND   res_start.calendar_code = org.calendar_code
  AND   res_start.seq_num = order_date.prior_seq_num -
      ceil((1 - NVL(routing.resource_offset_percent,0)) *
               (NVL(items.fixed_lead_time,0) + NVL(items.variable_lead_time,0) *
        (recom.new_order_quantity - NVL(recom.implemented_quantity,0) +
                 NVL(recom.quantity_in_process,0))))
  AND   TRUNC(res_start.calendar_date) < g_cutoff_date
  AND   order_date.exception_set_id = org.calendar_exception_set_id
  AND   order_date.calendar_code = org.calendar_code
  AND   order_date.calendar_date = recom.new_schedule_date
  AND   recom.order_type = M_PLANNED_ORDER
  AND   recom.compile_designator = items.compile_designator
  AND   recom.organization_id = items.organization_id
  AND   recom.inventory_item_id = items.inventory_item_id
  AND   items.organization_id = routing.organization_id
  AND   items.compile_designator = routing.compile_designator
  AND   items.inventory_item_id = routing.using_assembly_item_id
  AND   routing.alternate_routing_designator is NULL
  AND   routing.compile_designator = g_designator
  AND   routing.organization_id = org.organization_id
  AND   routing.department_id in (select department_id
                                  from crp_planned_resources cpr
                                  where cpr.compile_designator = g_designator
                                  and cpr.organization_id    = list.number1
                                  and cpr.owning_department_id =  list.number2)
  AND   routing.resource_id = list.number3
  AND   org.organization_id = list.number1
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ==================================
-- Discrete Job Dept/Res Requirement - tested
-- ==================================
SELECT
    res.organization_id,
    jobs.primary_item_id,
    list.number2,
    res.resource_id,
    -1,
    DECODE(jobs.job_type,
           WIP_NONSTANDARD, NONSTD_JOBS, DISCRETE_JOBS),
    NVL(res.start_date, jobs.scheduled_start_date),
    DECODE(g_spread_load,
           SYS_YES, res.completion_date, to_date(NULL)),
    DECODE(res.basis_type, BASIS_PER_ITEM,
           NVL((res.usage_rate_or_amount*(op.scheduled_quantity -
                  NVL(op.cumulative_scrap_quantity,0)-NVL(op.quantity_completed,0))
            - res.applied_resource_units)*muc2.conversion_rate/
            muc1.conversion_rate, 0),
           DECODE(res.applied_resource_units, 0,
              NVL(res.usage_rate_or_amount*muc2.conversion_rate/
              muc1.conversion_rate, 0),
              0))/compute_days_between (g_spread_load,res.start_date,res.completion_date)
  FROM  mtl_uom_conversions muc2,
    wip_discrete_jobs jobs,
    wip_operations op,
    wip_operation_resources res,
    mrp_form_query list,
    mtl_uom_conversions muc1
  WHERE muc1.inventory_item_id = 0
  AND   muc1.uom_code = g_hour_uom
  AND   muc2.uom_code = res.uom_code
  AND   muc2.inventory_item_id = 0
  AND   muc2.uom_class = muc1.uom_class
  AND   nvl(res.start_date,jobs.scheduled_start_date) <g_cutoff_date
  AND   jobs.status_type IN (JOB_UNRELEASED,
          JOB_COMPLETE, JOB_HOLD, JOB_RELEASED)
  AND   jobs.job_type in (WIP_NONSTANDARD,WIP_DISCRETE)
  AND   jobs.organization_id = op.organization_id
  AND   jobs.wip_entity_id = op.wip_entity_id
  AND   nvl((op.scheduled_quantity * res.usage_rate_or_amount -
     res.applied_resource_units),1) > 0
  AND   op.scheduled_quantity - NVL(op.quantity_completed, 0) > 0
  AND   op.wip_entity_id = res.wip_entity_id
  AND   op.operation_seq_num = res.operation_seq_num
  AND   op.organization_id = res.organization_id
  AND   op.department_id in (select department_id
                                  from crp_planned_resources cpr
                                  where cpr.compile_designator = g_designator
                                  and cpr.organization_id    = list.number1
                                  and cpr.owning_department_id =  list.number2)
  AND   res.wip_entity_id >= 0
  AND   res.organization_id = list.number1
  AND   res.resource_id = list.number3
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
UNION ALL
----------------------------------------
--- Flow Schedule Dept/Res Reqs - tested
----------------------------------------
   SELECT
     fs.organization_id,
     fs.primary_item_id,
     seqs.department_id,
     res.resource_id,
     -1,
     DISCRETE_JOBS,
     trunc(res_start.calendar_date),
	 to_date(NULL),
     DECODE(res.basis_type, BASIS_PER_ITEM,
             GREATEST( NVL(res.usage_rate_or_amount*muc2.conversion_rate/
                            muc1.conversion_rate, 0)*
                      (NVL(fs.planned_quantity,0) -
                       NVL(fs.quantity_completed,0)),0),
              NVL(res.usage_rate_or_amount*muc2.conversion_rate/
                                     muc1.conversion_rate, 0))
FROM bom_calendar_dates res_start,
	 bom_calendar_dates order_date,
	 mtl_system_items items,
	 mtl_parameters param,
	 wip_flow_schedules fs,
     bom_operational_routings routing,
     bom_operation_sequences seqs,
     bom_operation_resources res,
     bom_resources bom_res,
     mtl_uom_conversions muc2,
     mtl_uom_conversions muc1,
     mrp_form_query list
WHERE  res_start.exception_set_id = param.calendar_exception_set_id
AND    res_start.calendar_code = param.calendar_code
AND    res_start.seq_num = order_date.prior_seq_num -
	   ceil((1 - NVL(res.resource_offset_percent/100,0)) *
	    (NVL(items.fixed_lead_time,0) + NVL(items.variable_lead_time,0) *
		  (fs.planned_quantity - NVL(fs.quantity_completed,0))))
AND   TRUNC(res_start.calendar_date) < g_cutoff_date
AND  order_date.exception_set_id = param.calendar_exception_set_id
AND  order_date.calendar_code = param.calendar_code
AND  order_date.calendar_date = fs.scheduled_completion_date
AND  param.organization_id = fs.organization_id
AND  items.organization_id = fs.organization_id
AND  items.inventory_item_id =  fs.primary_item_id
AND	 nvl(fs.alternate_routing_designator, '-23453')
				= nvl(routing.alternate_routing_designator, '-23453')
AND  fs.organization_id = routing.organization_id
AND  fs.primary_item_id = routing.assembly_item_id
AND	 fs.scheduled_completion_date >= TRUNC(sysdate)
AND  routing.common_routing_sequence_id = seqs.routing_sequence_id
AND  routing.organization_id = bom_res.organization_id
AND  TRUNC(seqs.effectivity_date) <= TRUNC(g_dates(1))
AND  nvl(seqs.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(g_dates(1))
AND  nvl(seqs.operation_type, 1) = 1
AND  muc2.inventory_item_id = 0
AND  muc2.uom_class = muc1.uom_class
AND  muc2.uom_code = bom_res.unit_of_measure
AND	 muc1.inventory_item_id = 0
AND  muc1.uom_code = g_hour_uom
AND  seqs.department_id = list.number2
AND  seqs.operation_sequence_id = res.operation_sequence_id
AND  res.resource_id = bom_res.resource_id
AND  bom_res.organization_id = list.number1
AND  bom_res.resource_id = list.number3
AND  list.number3 is not null
AND  list.query_id = g_item_list_id
UNION ALL
-- ===================================
-- Repetitive Dept/Res Reqs - tested
-- ===================================
SELECT
	res.organization_id,
	items.primary_item_id,
	op.department_id,
	res.resource_id,
	-1,
	REPETITIVE,
	NVL(res.start_date, rep.first_unit_start_date),
	NVL(res.completion_date, rep.last_unit_completion_date),
	DECODE(res.basis_type, BASIS_PER_ITEM,
		   NVL((res.usage_rate_or_amount*op.scheduled_quantity
				   - res.applied_resource_units)*muc2.conversion_rate/
			   muc1.conversion_rate, 0),
		 	DECODE(res.applied_resource_units, 0,
			NVL(res.usage_rate_or_amount*muc2.conversion_rate/
		  	muc1.conversion_rate, 0),
			0))
FROM 	mtl_uom_conversions muc2,
		wip_repetitive_schedules rep,
		wip_repetitive_items items,
		wip_operations op,
		wip_operation_resources res,
		mrp_form_query list,
		mtl_uom_conversions muc1
WHERE muc1.inventory_item_id = 0
AND   muc1.uom_code = g_hour_uom
AND   muc2.uom_code = res.uom_code
AND   muc2.inventory_item_id = 0
AND   muc2.uom_class = muc1.uom_class
AND   items.wip_entity_id = rep.wip_entity_id
AND   items.organization_id = rep.organization_id
AND   items.line_id = rep.line_id
AND   nvl(res.start_date,rep.first_unit_start_date) < g_cutoff_date
AND   rep.status_type IN (JOB_RELEASED, JOB_UNRELEASED, JOB_COMPLETE,
							JOB_HOLD)
AND   rep.organization_id = op.organization_id
AND   rep.repetitive_schedule_id = op.repetitive_schedule_id
AND   nvl((op.scheduled_quantity * res.usage_rate_or_amount -
			   res.applied_resource_units),1) > 0
AND   op.repetitive_schedule_id = res.repetitive_schedule_id
AND   op.operation_seq_num = res.operation_seq_num
AND   op.organization_id = res.organization_id
AND   op.department_id = list.number2
AND   res.wip_entity_id >= 0
AND   res.organization_id = list.number1
AND   res.resource_id = list.number3
AND   list.number3 is not null
AND   list.query_id = g_item_list_id
UNION ALL
-- ===================================
-- Planned Order line Requirement
-- ===================================
  SELECT
    mr.organization_id,
    mr.inventory_item_id,
    -1,
    -1,
    mr.line_id,
    PLANNED_ORDER,
    trunc(mr.new_wip_start_date),
        to_date(null),
    (mr.new_order_quantity - NVL(mr.implemented_quantity,0) +
         NVL(mr.quantity_in_process,0))
  FROM  mrp_recommendations mr,
    mrp_form_query list
  WHERE mr.order_type = M_PLANNED_ORDER
  AND   mr.new_wip_start_date < g_cutoff_date
  AND   mr.compile_designator = g_designator
  AND   mr.line_id = list.number2
  AND   mr.organization_id = list.number1
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ==================================
-- Discrete Job line Requirement - tested
-- ==================================
  SELECT
    jobs.organization_id,
    jobs.primary_item_id,
    -1,
    -1,
    jobs.line_id,
    DECODE(jobs.job_type,
           WIP_NONSTANDARD, NONSTD_JOBS,
           WIP_DISCRETE, DISCRETE_JOBS),
    jobs.scheduled_start_date,
    to_date(NULL),
        SUM(GREATEST( 0, (jobs.net_quantity - jobs.quantity_completed
                        - jobs.quantity_scrapped)))
  FROM  wip_discrete_jobs jobs,
    mrp_form_query list
  WHERE jobs.scheduled_start_date <g_cutoff_date
  AND   jobs.status_type IN (JOB_UNRELEASED,
          JOB_COMPLETE, JOB_HOLD, JOB_RELEASED)
  AND   jobs.job_type in (WIP_NONSTANDARD,WIP_DISCRETE)
  AND   jobs.net_quantity > 0
  AND   jobs.wip_entity_id >= 0
  AND   jobs.organization_id = list.number1
  AND   jobs.line_id = list.number2
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
  GROUP BY
    jobs.organization_id,
    jobs.primary_item_id,
        jobs.line_id,
    jobs.scheduled_start_date,
    jobs.job_type
UNION ALL
-- =====================================
-- Flow  Schedules line requirement
-- =====================================
	SELECT
		fs.organization_id,
		fs.primary_item_id,
	 	-1,
	 	-1,
    	fs.line_id,
		DISCRETE_JOBS,
		fs.scheduled_start_date,
		to_date(NULL),
		SUM(GREATEST( 0, (fs.planned_quantity - fs.quantity_completed)))
	FROM  wip_flow_schedules fs,
		  mrp_form_query list
	WHERE fs.scheduled_start_date <g_cutoff_date
	AND	  fs.scheduled_completion_date >= TRUNC(sysdate)
    AND   fs.wip_entity_id >= 0
    AND   fs.organization_id = list.number1
	AND   fs.line_id = list.number2
    AND   list.number3 is null
	AND   list.query_id = g_item_list_id
	GROUP BY
	      fs.organization_id,
		  fs.primary_item_id,
		  fs.line_id,
		  fs.scheduled_start_date
UNION ALL
-- =====================================
-- Repetitive Schedules line requirement - tested
-- =====================================
  SELECT
    sched.organization_id,
    rep_items.primary_item_id,
    -1,
    -1,
    sched.line_id,
    REPETITIVE,
    TRUNC(sched.first_unit_start_date),
    TRUNC(sched.last_unit_start_date),
    sched.daily_production_rate*lines.maximum_rate/
    rep_items.PRODUCTION_LINE_RATE
  FROM  wip_repetitive_items rep_items,
    wip_repetitive_schedules sched,
    wip_lines lines,
    mrp_form_query list
  WHERE rep_items.organization_id = sched.organization_id
  AND   rep_items.line_id = sched.line_id
  AND   rep_items.wip_entity_id = sched.wip_entity_id
  AND   TRUNC(sched.first_unit_start_date) < g_cutoff_date
  AND   TRUNC(sched.last_unit_start_date) >= g_dates(1)
  AND   sched.status_type IN (JOB_UNRELEASED,
    JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
  AND   sched.organization_id = lines.organization_id
  AND   sched.line_id = lines.line_id
  AND   lines.organization_id = list.number1
  AND   lines.line_id = list.number2
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
-- =========================
-- Line availability
-- =========================
UNION ALL
  SELECT
    line.organization_id,
    TO_NUMBER(NULL),
    -1,
    -1,
    line.line_id,
    AVAILABLE_HOURS,
    g_dates(1),
    trunc(g_cutoff_date-1),
    nvl(line.maximum_rate, 0) *
    (decode(least(line.start_time, line.stop_time),
        line.stop_time, (line.stop_time + (24 *3600)),
        line.stop_time) - line.start_time) / 3600
  FROM  wip_lines line,
    mrp_form_query list
  WHERE nvl(line.disable_date, sysdate + 1) > sysdate
  AND   line.organization_id = list.number1
  AND   line.line_id = list.number2
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
-- ============================
-- Dept/Resource Availability
-- ============================
UNION ALL
  SELECT
    param.organization_id,
    TO_NUMBER(NULL),
    dept_res.department_id,
    dept_res.resource_id,
    -1,
    AVAILABLE_HOURS,
	trunc(cal.calendar_date),
	trunc(cal.calendar_date),
    SUM(DECODE(dept_res.available_24_hours_flag,
           1, dept_res.capacity_units * 24 *
               NVL(dept_res.utilization, 1.0) *
	       NVL(dept_res.efficiency, 1.0),
           (DECODE(LEAST(shifts.to_time, shifts.from_time),
               shifts.to_time, shifts.to_time + 24*3600,
               shifts.to_time) - shifts.from_time) *
        (dept_res.capacity_units/3600) *
               NVL(dept_res.utilization, 1.0) *
	       NVL(dept_res.efficiency, 1.0) ))
  FROM  bom_shift_times shifts,
    bom_resource_shifts res_shifts,
    bom_department_resources dept_res,
    mtl_parameters param,
	bom_calendar_dates cal,
	mrp_form_query list
  WHERE (shifts.calendar_code is NULL  OR
     shifts.calendar_code = param.calendar_code)
  AND   shifts.shift_num (+) = res_shifts.shift_num
  AND   res_shifts.resource_id (+)=  dept_res.resource_id
  AND   res_shifts.department_id (+)= dept_res.department_id
  AND  dept_res.share_from_dept_id is NULL
  AND cal.calendar_code = param.calendar_code
  AND cal.exception_set_id = param.calendar_exception_set_id
  AND trunc(cal.calendar_date) >= trunc(sysdate)
  AND   ((cal.seq_num is not null
              and   not exists ( select 1 from CRP_CAL_SHIFT_DELTA delta1
                                 where delta1.calendar_code =
                                              shifts.calendar_code
                                 and   delta1.exception_set_id =
								         param.calendar_exception_set_id
                                 and   delta1.delta_code = 1
                                 and   delta1.calendar_date = cal.calendar_date
                                 and   delta1.shift_num = shifts.shift_num))
                    OR
                    (cal.seq_num is null
              and   exists ( select 1 from CRP_CAL_SHIFT_DELTA delta1
                             where delta1.calendar_code =
                                          shifts.calendar_code
							     and   delta1.exception_set_id =
							             param.calendar_exception_set_id
                                 and   delta1.delta_code = 2
                                 and   delta1.calendar_date = cal.calendar_date
                                 and   delta1.shift_num = shifts.shift_num)))
  AND   dept_res.department_id = list.number2
  AND   dept_res.resource_id = list.number3
  AND   param.organization_id = list.number1
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
  GROUP BY
    param.organization_id,
    dept_res.department_id,
    dept_res.resource_id,
	trunc(cal.calendar_date)
-- ================================
-- Dept/Resource modif/add workday
-- ================================
UNION ALL
  SELECT
    orgs.planned_organization,/*2681093*/
    TO_NUMBER(NULL),
    brc.department_id,
    brc.resource_id,
    -1,
    CAP_CHANGES,
    dates.calendar_date,
    dates.calendar_date,
    (brc.capacity_change *
        (DECODE(LEAST(NVL(brc.from_time, 0), NVL(brc.to_time, 1)),
            NVL(brc.to_time, 1), 24 * 3600 + NVL(brc.to_time, 1),
            NVL(brc.to_time, 1)) -  NVL(brc.from_TIME, 0)))/3600
  FROM  bom_calendar_dates dates,
    bom_resource_changes brc,
    mrp_plan_organizations_v orgs,
    mtl_parameters param,
    mrp_form_query list
  WHERE dates.exception_set_id = param.calendar_exception_set_id
  AND   dates.calendar_code = param.calendar_code
  AND   (brc.action_type = ADD_WORK_DAY
		 OR dates.seq_num is not NULL
		 OR (dates.seq_num IS NULL
             and   exists ( select 1
                        from CRP_CAL_SHIFT_DELTA delta1
                             where delta1.calendar_code =
                                          dates.calendar_code
                                 and   delta1.exception_set_id =
                                         dates.exception_set_id
                                 and   delta1.delta_code = 2
                                 and   delta1.calendar_date =
                                             dates.calendar_date
                                 and   delta1.shift_num = brc.shift_num)))
  AND   dates.calendar_date BETWEEN TRUNC(brc.from_date)
  AND   TRUNC(NVL(brc.to_date, brc.from_date))
  AND   TRUNC(brc.from_date) < g_cutoff_date
  AND   TRUNC(NVL(brc.to_date, brc.from_date)) >= g_dates(1)
  AND   brc.simulation_set = orgs.simulation_set
  AND   brc.department_id = list.number2
  AND   brc.resource_id = list.number3
  AND   brc.action_type in (ADD_WORK_DAY, MODIFY_WORK_DAY)
  AND   orgs.compile_designator = g_designator
  AND   orgs.planned_organization = param.organization_id
  AND   orgs.organization_id = g_org_id
  AND   param.organization_id = list.number1
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
  AND   not exists
    (SELECT 'Exists'
     FROM   bom_resource_changes brc2
     WHERE  brc2.department_id = brc.department_id
     AND    brc2.resource_id = brc.resource_id
     AND    brc2.shift_num = brc.shift_num
     AND    brc2.action_type = DELETE_WORK_DAY
     AND    brc2.to_date = dates.calendar_date
     AND    brc2.from_date is null
     AND    brc2.simulation_set = brc.simulation_set)
-- ===============================================================
-- Resource delete work days
-- Note, we don't have capacity modifications for
-- borrowed resources. Therefore, the following query will not
-- return any rows for borrowed resources in a department
-- ===============================================================
UNION ALL
  SELECT
    orgs.planned_organization,/*2681093*/
    TO_NUMBER(NULL),
    brc.department_id,
    brc.resource_id,
    -1,
    CAP_CHANGES,
    brc.from_date,
    brc.from_date,
    -1 * SUM((DECODE(LEAST(shifts.to_time, shifts.from_time),
             shifts.to_time, shifts.to_time + 24*3600,
             shifts.to_time) - shifts.from_time) *
          dept_res.capacity_units / 3600)
  FROM  bom_shift_times shifts,
    bom_resource_changes brc,
    bom_department_resources dept_res,
    mrp_plan_organizations_v orgs,
    mtl_parameters param,
    mrp_form_query list
  WHERE shifts.calendar_code = param.calendar_code
  AND   shifts.shift_num = brc.shift_num
  AND   TRUNC(brc.from_date) < g_cutoff_date
  AND   TRUNC(brc.from_date) >= g_dates(1)
  AND   brc.action_type = DELETE_WORK_DAY
  AND   brc.simulation_set = orgs.simulation_set
  AND   brc.department_id = dept_res.department_id
  AND   brc.resource_id = dept_res.resource_id
  AND   dept_res.department_id = list.number2
  AND   dept_res.resource_id = list.number3
  AND   orgs.compile_designator = g_designator
  AND   orgs.planned_organization = param.organization_id
  AND   orgs.organization_id = g_org_id
  AND   param.organization_id = list.number1
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
  GROUP BY
    orgs.planned_organization, /*2681093*/
        brc.department_id,
        brc.resource_id,
        brc.from_date,
        brc.from_date
ORDER BY 1,3,4,5,7,6;




CURSOR crp_snapshot_activity IS
-- ===================================
-- Dept/Resource requirements
-- ===================================
  SELECT
    crp.organization_id,
    crp.assembly_item_id,
    cpr.owning_department_id,
    crp.resource_id,
    -1,
    decode(crp.supply_type,
        M_PLANNED_ORDER, PLANNED_ORDER,
        M_REPETITIVE, REPETITIVE,
        M_DISCRETE_JOBS, DISCRETE_JOBS,
        M_NONSTD_JOBS, NONSTD_JOBS,
        M_FLOW_SCHEDULES, DISCRETE_JOBS),
    trunc(crp.resource_date),
    trunc(crp.resource_end_date),
    decode(crp.resource_end_date,
        NULL, crp.resource_hours,
        crp.daily_resource_hours)
  FROM
    crp_resource_plan crp,
    crp_planned_resources cpr,
    mrp_form_query list
  WHERE
        cpr.owning_department_id = list.number2
  AND   cpr.resource_id = list.number3
  AND   cpr.compile_designator = g_designator
  AND   cpr.organization_id = list.number1
  AND   crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE,
        M_DISCRETE_JOBS,M_NONSTD_JOBS, M_FLOW_SCHEDULES)
  AND   crp.designator = cpr.compile_designator
  AND   crp.resource_date < g_cutoff_date
  AND   crp.resource_id = cpr.resource_id
  AND   crp.department_id = cpr.department_id
  AND   crp.organization_id = cpr.organization_id
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ============================================
-- Discrete job/Planned order Line Requirement
-- ============================================
  SELECT /*+ ORDERED
    USE_NL(mr)
    INDEX(list MRP_FORM_QUERY_N1)
    INDEX(mr MRP_RECOMMENDATIONS_N2) */
    mr.organization_id,
    mr.inventory_item_id,
    -1,
    -1,
    mr.line_id,
    decode(mr.order_type,
        M_PLANNED_ORDER, PLANNED_ORDER,
        M_DISCRETE_JOBS, DISCRETE_JOBS,
        M_NONSTD_JOBS, NONSTD_JOBS,
        M_FLOW_SCHEDULES, DISCRETE_JOBS),
    NVL(mr.new_wip_start_date,mr.new_schedule_date),
        to_date(null),
    mr.new_order_quantity
  FROM  mrp_form_query list,
    mrp_recommendations mr
  WHERE mr.order_type in (M_PLANNED_ORDER, M_DISCRETE_JOBS,
        M_NONSTD_JOBS, M_FLOW_SCHEDULES)
  AND   mr.disposition_status_type <> 2
  AND   mr.new_schedule_date < g_cutoff_date
  AND   mr.compile_designator = g_designator
  AND   mr.line_id = list.number2
  AND   mr.organization_id = list.number1
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ============================================
-- RCCP Planned order Line Requirement
-- Note, line_id is stored in department_id
-- and resource_id is set to -1
-- ============================================
  SELECT
    crp.organization_id,
    crp.source_item_id,
    -1,
    -1,
    crp.department_id,
    decode(crp.supply_type,
                M_PLANNED_ORDER, PLANNED_ORDER,
                M_REPETITIVE, REPETITIVE),
    trunc(crp.resource_date),
    to_date(NULL),
    crp.load_rate
  FROM  crp_resource_plan crp,
        mrp_form_query list
  WHERE crp.supply_type in (M_PLANNED_ORDER, M_REPETITIVE)
  AND   crp.designator = g_designator
  AND   crp.resource_date < g_cutoff_date
  AND   crp.resource_id = -1
  AND   crp.department_id = list.number2
  AND   crp.organization_id = list.number1
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ===================================
-- Repetitive schedule line requirements
-- ===================================
  SELECT /*+ORDERED
    INDEX(list MRP_FORM_QUERY_N1)
    INDEX(msrs MRP_SUGG_REP_SCHEDULES_N3) */
    msrs.organization_id,
    msrs.inventory_item_id,
    -1,
    -1,
    msrs.repetitive_line,
    REPETITIVE,
    trunc(msrs.first_unit_start_date),
    trunc(least(msrs.last_unit_start_date,g_cutoff_date-1)),
    msrs.load_factor_rate
  FROM  mrp_form_query list,
    mrp_sugg_rep_schedules msrs
  WHERE msrs.first_unit_start_date < g_cutoff_date
  AND   msrs.compile_designator = g_designator
  AND   msrs.organization_id = list.number1
  AND   msrs.repetitive_line = list.number2
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ===================================
-- Availability for Dept/Res
-- ===================================
  SELECT
    avail.organization_id,
    TO_NUMBER(NULL),
    NVL(avail.department_id,-1),
    NVL(avail.resource_id,-1),
    NVL(avail.line_id,-1),
    AVAILABLE_HOURS,
    trunc(avail.resource_start_date),
    trunc(least(nvl(avail.resource_end_date,g_cutoff_date), g_cutoff_date-1)),
    avail.resource_units * avail.resource_hours
  FROM  crp_available_resources avail,
    mrp_form_query list
  WHERE avail.resource_start_date < g_cutoff_date
  AND   nvl(avail.resource_end_date, g_cutoff_date) >= g_dates(1)
  AND   avail.compile_designator = g_designator
  AND   avail.organization_id = list.number1
  AND   avail.department_id = list.number2
  AND   avail.resource_id = list.number3
  AND   list.number3 is not null
  AND   list.query_id = g_item_list_id
UNION ALL
-- ===================================
-- Availability for Lines
-- ===================================
  SELECT
    avail.organization_id,
    TO_NUMBER(NULL),
    NVL(avail.department_id,-1),
    NVL(avail.resource_id,-1),
    NVL(avail.line_id,-1),
    AVAILABLE_HOURS,
    trunc(avail.resource_start_date),
    trunc(least(nvl(avail.resource_end_date,g_cutoff_date),g_cutoff_date-1)),
    avail.max_rate
  FROM  crp_available_resources avail,
    mrp_form_query list
  WHERE avail.resource_start_date < g_cutoff_date
  AND   nvl(avail.resource_end_date, g_cutoff_date) >= g_dates(1)
  AND   avail.compile_designator = g_designator
  AND   avail.organization_id = list.number1
  AND   avail.line_id = list.number2
  AND   list.number3 is null
  AND   list.query_id = g_item_list_id
  ORDER BY
    1,3,4,5,7,6;


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
BEGIN

  -- --------------------------
  -- initialize profile value
  -- --------------------------
  g_spread_load := NVL(FND_PROFILE.VALUE('CRP_SPREAD_LOAD'), SYS_NO);
  g_hour_uom := fnd_profile.value('BOM:HOUR_UOM_CODE');

  -- --------------------------
  -- initialize query id
  -- --------------------------
  g_error_stmt := 'Debug - initialize - 10';
  SELECT crp_form_query_s.nextval
  INTO   g_query_id
  FROM   dual;

  -- --------------------------
  -- initialize calendar code
  -- --------------------------
  g_error_stmt := 'Debug - initialize - 20';
  SELECT calendar_code, calendar_exception_set_id
  INTO   g_calendar_code, g_exc_set_id
  FROM   mtl_parameters
  WHERE  organization_id = g_planned_org;

  -- -------------------------------
  -- initialize plan_start_date
  -- -------------------------------
  g_error_stmt := 'Debug - initialize - 15';
  SELECT trunc(plan_start_date)
  INTO   g_plan_start_date
  FROM   mrp_plans
  WHERE  compile_designator = g_designator
  AND    organization_id = g_org_id;

  OPEN seqnum_cursor(g_plan_start_date);
  FETCH seqnum_cursor INTO g_plan_start_seq;
  CLOSE seqnum_cursor;

  -- ----------------------------------
  -- Initialize the bucket cells to 0.
  -- ----------------------------------
  g_error_stmt := 'Debug - initialize - 50';
  FOR v_counter IN 1..(NUM_OF_TYPES * NUM_OF_COLUMNS) LOOP
    bucket_cells(v_counter) := 0;
  END LOOP;

  -- --------------------
  -- Get the bucket dates
  -- --------------------
  g_error_stmt := 'Debug - initialize - 60';
  SELECT
    date1,  date2,  date3,  date4,
    date5,  date6,  date7,  date8,
    date9,  date10, date11, date12,
    date13, date14, date15, date16,
    date17, date18, date19, date20,
    date21, date22, date23, date24,
    date25, date26, date27, date28,
    date29, date30, date31, date32,
    date33, date34, date35, date36,
    date37
  INTO
    g_dates(1),  g_dates(2),  g_dates(3),  g_dates(4),
    g_dates(5),  g_dates(6),  g_dates(7),  g_dates(8),
    g_dates(9),  g_dates(10), g_dates(11), g_dates(12),
    g_dates(13), g_dates(14), g_dates(15), g_dates(16),
    g_dates(17), g_dates(18), g_dates(19), g_dates(20),
    g_dates(21), g_dates(22), g_dates(23), g_dates(24),
    g_dates(25), g_dates(26), g_dates(27), g_dates(28),
    g_dates(29), g_dates(30), g_dates(31), g_dates(32),
    g_dates(33), g_dates(34), g_dates(35), g_dates(36),
    g_dates(37)
  FROM  mrp_workbench_bucket_dates
  WHERE organization_id     = g_org_id
  AND   nvl(planned_organization,organization_id) =
        g_planned_org
  AND   compile_designator  = g_designator
  AND   bucket_type         = DECODE(g_current_data,
        SYS_YES, DECODE(g_bucket_type,
                1, -1,
                2, -2,
                3, -3), g_bucket_type);

  -- ----------------------------
  -- populate the g_date_seq
  -- memory structure.
  -- ----------------------------
  g_error_stmt := 'Debug - initialize - 70';
  FOR v_counter IN 1..NUM_OF_COLUMNS+1 LOOP
    OPEN seqnum_cursor(g_dates(v_counter));
    FETCH seqnum_cursor INTO g_date_seq(v_counter);
    CLOSE seqnum_cursor;
-- if g_date_seq(v_counter) is null, raise an error
  END LOOP;
  g_error_stmt := 'Debug - initialize - 80';

END initialize;



-- =============================================================================
-- Name: get_number_work_days
-- Desc: returns the number of workdays between start and end date, inclusive
-- =============================================================================
FUNCTION get_number_work_days(
            start_date  DATE,
            end_date    DATE) RETURN NUMBER IS
v_start_seq NUMBER;
v_end_seq   NUMBER;
BEGIN
  IF (trunc(start_date) <= trunc(end_date)) THEN
    OPEN seqnum_cursor(trunc(start_date));
    FETCH seqnum_cursor INTO v_start_seq;
    CLOSE seqnum_cursor;
    OPEN prior_seqnum_cursor(trunc(end_date));
    FETCH prior_seqnum_cursor INTO v_end_seq;
    CLOSE prior_seqnum_cursor;
    g_error_stmt := 'Debug - get_number_work_days - 10 - sdates ';
    IF (v_end_seq - v_start_seq + 1) > 0 THEN
       RETURN(v_end_seq - v_start_seq + 1);
    ELSE
       RETURN(1);
    END IF;
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
  IF (activity_rec.line_id <> -1 AND
      activity_rec.type in (PLANNED_ORDER,NONSTD_JOBS,
                DISCRETE_JOBS,REPETITIVE)) THEN
    SELECT  NVL(cst.item_cost, 0)
    INTO    v_res_cost
    FROM    cst_item_costs cst,
        mtl_parameters org
    WHERE   cst.cost_type_id(+) = org.primary_cost_method
    AND cst.organization_id(+) = org.cost_organization_id
    AND cst.inventory_item_id(+) = activity_rec.assembly_item_id
    AND org.organization_id = activity_rec.org_id;
  END IF;

  g_error_stmt := 'Debug - add_to_plan - 10';
  IF (activity_rec.start_date >= g_dates(g_bucket_count)) THEN
    -- -------------------------------------------------------
    -- We got an activity which falls after the current bucket. So we
    -- will move the bucket counter forward until we find the
    -- bucket where this activity falls.  Note that we should
    -- not advance the counter beyond NUM_OF_COLUMNS.
    -- --------------------------------------------------------
    WHILE ((activity_rec.start_date >= g_dates(g_bucket_count)) AND
       (g_bucket_count <= NUM_OF_COLUMNS))
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

    ---------------------------------------------------------------
    --- BUG # 2402184
    --- In case of supply chain plan, if the organization_id of the
    --- current record is different from the planned_org, reset the
    --- global variable - g_planned_org and g_calendar_code
    ---------------------------------------------------------------

  IF (activity_rec.org_id <> g_planned_org) THEN

     g_planned_org := activity_rec.org_id;

     SELECT calendar_code, calendar_exception_set_id
     INTO   g_calendar_code, g_exc_set_id
     FROM   mtl_parameters
     WHERE  organization_id = g_planned_org;

  END IF;

  IF (activity_rec.end_date is null) THEN
    -- -------------------------------------------------------
    -- end date is null,  we assume that the quantity
    -- stands for total quantity and we dump the total
    -- quantity on the first bucket
    -- --------------------------------------------------------
    g_error_stmt := 'Debug - add_to_plan - 20';
    v_location := ((activity_rec.type-1) * NUM_OF_COLUMNS) +
        g_bucket_count - 1;
    bucket_cells(v_location) := bucket_cells(v_location) +
        activity_rec.quantity;
    v_location := ((RESOURCE_COST-1) * NUM_OF_COLUMNS) +
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
    -- the bucket before last. Last bucket needs special
    -- logic
    -- --------------------------------------------------------
    WHILE((v_counter <= NUM_OF_COLUMNS) AND
      (activity_rec.end_date >= g_dates(v_counter)))
    LOOP
      g_error_stmt := 'Debug - add_to_plan - 40 - loop'||to_char(v_counter);
      v_bucket_size := get_number_work_days(v_bucket_start, g_dates(v_counter)-1);

      v_location := ((activity_rec.type-1) * NUM_OF_COLUMNS) +
                v_counter - 1;

      bucket_cells(v_location) := bucket_cells(v_location) +
                v_bucket_size * activity_rec.quantity;

      v_location := ((RESOURCE_COST-1) * NUM_OF_COLUMNS) +
        v_counter - 1;
      bucket_cells(v_location) := bucket_cells(v_location) +
        v_bucket_size * activity_rec.quantity * v_res_cost;
      v_bucket_start := g_dates(v_counter);

      -- ------------------------------------------------------
      -- For Debuging, uncomment following
      -- dbms_output.put_line('Ay_id'||to_char(activity_rec.assembly_item_id));
      -- dbms_output.put_line('D_id'||to_char(activity_rec.department_id));
      -- dbms_output.put_line('R_id'||to_char(activity_rec.resource_id));
      -- dbms_output.put_line('L_id'||to_char(activity_rec.line_id));
      -- dbms_output.put_line('Type - '||to_char(activity_rec.type));
      -- dbms_output.put_line('Start - '||to_char(activity_rec.start_date));
      -- dbms_output.put_line('End - '||to_char(activity_rec.end_date));
      -- dbms_output.put_line('Qty - '||to_char(activity_rec.quantity));
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

    v_location := ((activity_rec.type-1) * NUM_OF_COLUMNS) +
                v_counter - 1;
    bucket_cells(v_location) := bucket_cells(v_location) +
        v_bucket_size * activity_rec.quantity;

    v_location := ((RESOURCE_COST-1) * NUM_OF_COLUMNS) +
        v_counter - 1;
    bucket_cells(v_location) := bucket_cells(v_location) +
        v_bucket_size * activity_rec.quantity * v_res_cost;

    -- ------------------------------------------------------
    -- For Debuging, uncomment following
    -- dbms_output.put_line('Ay_id'||to_char(activity_rec.assembly_item_id));
    -- dbms_output.put_line('D_id'||to_char(activity_rec.department_id));
    -- dbms_output.put_line('R_id'||to_char(activity_rec.resource_id));
    -- dbms_output.put_line('L_id'||to_char(activity_rec.line_id));
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
        p_dept_id       NUMBER,
        p_line_id               NUMBER,
        p_res_id        NUMBER) IS

  v_loop        BINARY_INTEGER := 1;
  v_cum_net_available   NUMBER := 0;
  v_cum_available   NUMBER := 0;
  v_cum_required    NUMBER := 0;
  v_cum_changes     NUMBER := 0;
  v_overhead        NUMBER := 0;
  v_res_cost        NUMBER := 0;
  v_num_days        NUMBER := 0;
BEGIN

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
  -- -----------------------------
  IF (p_line_id = -1) THEN

/***** Bug 1965639
    SELECT SUM(NVL(rate_or_amount,0))
    INTO    v_overhead
    FROM    cst_department_overheads
    WHERE   organization_id = p_org_id
    AND     department_id = p_dept_id
    AND     cost_type_id = CST_FROZEN;

    IF v_overhead is NULL THEN
      v_overhead := 0;
    END IF;

    BEGIN
      SELECT (1 + v_overhead)*NVL(res.resource_rate,0)
      INTO  v_res_cost
      FROM  cst_resource_costs res
      WHERE res.organization_id = p_org_id
      AND   res.resource_id = p_res_id
      AND   res.cost_type_id = CST_FROZEN;
    EXCEPTION when no_data_found THEN
      v_res_cost := 0;
      NULL;
    END;
******/

   /* Get resource cost */

    BEGIN
      SELECT NVL(res.resource_rate,0)
      INTO  v_res_cost
      FROM  cst_resource_costs res
      WHERE res.organization_id = p_org_id
      AND   res.resource_id = p_res_id
      AND   res.cost_type_id = CST_FROZEN;
    EXCEPTION when no_data_found THEN
      v_res_cost := 0;
    END;

    /* Bug 1965639 : Get the overhead rate. Consider only those overheads
       that have a basis of Resource Value or Resource Units.
       When the basis is Resource Value, the overhead rate is multiplied
       by the resource cost. */

    SELECT SUM(decode(basis_type,BASIS_RESOURCE_VALUE, v_res_cost * NVL(rate_or_amount,0),
                                 NVL(rate_or_amount,0)))
    INTO    v_overhead
    FROM    cst_department_overheads
    WHERE   organization_id = p_org_id
    AND     department_id = p_dept_id
    AND     cost_type_id = CST_FROZEN
    AND     basis_type in (BASIS_RESOURCE_VALUE, BASIS_RESOURCE_UNITS)
    AND     overhead_id IN (SELECT  overhead_id
              FROM cst_resource_overheads res
              WHERE res.organization_id =  p_org_id
              AND res.resource_id = p_res_id
              AND cost_type_id = CST_FROZEN);

    v_res_cost := v_res_cost +  nvl(v_overhead,0);

  END IF;

  g_error_stmt := 'Debug - calculate_cum - 10';
  FOR v_loop IN 1..NUM_OF_COLUMNS LOOP
    -- -------------------
    -- Required Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
    bucket_cells((REQUIRED_HOURS-1)*NUM_OF_COLUMNS+v_loop) :=
        bucket_cells((PLANNED_ORDER-1)*NUM_OF_COLUMNS+v_loop) +
        bucket_cells((NONSTD_JOBS-1)*NUM_OF_COLUMNS+v_loop) +
        bucket_cells((DISCRETE_JOBS-1)*NUM_OF_COLUMNS+v_loop) +
        bucket_cells((REPETITIVE-1)*NUM_OF_COLUMNS+v_loop);

    -- -------------------
    -- Available hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 25 - loop'||to_char(v_loop);
    bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop) +
        bucket_cells((CAP_CHANGES-1)*NUM_OF_COLUMNS+v_loop);

    -- -------------------
    -- Net Available Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 30 - loop'||to_char(v_loop);
    bucket_cells((NET_AVAILABLE-1)*NUM_OF_COLUMNS+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop) -
        bucket_cells((REQUIRED_HOURS-1)*NUM_OF_COLUMNS+v_loop);

    -- ----------------------------
    -- Cumulatitive Available Hours
    -- ----------------------------
    v_cum_net_available := v_cum_net_available +
        bucket_cells((NET_AVAILABLE-1)*NUM_OF_COLUMNS+v_loop);
    bucket_cells((CUM_AVAILABLE-1)*NUM_OF_COLUMNS+v_loop) := v_cum_net_available;

    -- ----------------------------
    -- Capacity Utilization
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 40 - loop'||to_char(v_loop);
    IF (bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop) <= 0) THEN
      bucket_cells((UTILIZATION-1)*NUM_OF_COLUMNS+v_loop) := NULL;
    ELSE
      bucket_cells((UTILIZATION-1)*NUM_OF_COLUMNS+v_loop) := 100 *
        bucket_cells((REQUIRED_HOURS-1)*NUM_OF_COLUMNS+v_loop) /
        bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop);
    END IF;

    -- ----------------------------
    -- Cum Capacity Utilization
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 50 - loop'||to_char(v_loop);
    v_cum_required := v_cum_required +
        bucket_cells((REQUIRED_HOURS-1)*NUM_OF_COLUMNS+v_loop);
    v_cum_available := v_cum_available +
        bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop);
    IF (v_cum_available <= 0) THEN
      bucket_cells((CUM_UTILIZATION-1)*NUM_OF_COLUMNS+v_loop) := NULL;
    ELSE
      bucket_cells((CUM_UTILIZATION-1)*NUM_OF_COLUMNS+v_loop) := 100 *
        v_cum_required / v_cum_available;
    END IF;

    -- ----------------------------
    -- Daily Required Hours and
    -- Daily Available Hours
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 60 - loop'||to_char(v_loop);
    IF (v_loop = 1) THEN
      v_num_days := g_date_seq(v_loop+1) -
            greatest(g_date_seq(v_loop), g_plan_start_seq);
/*2692616*/    ELSIF g_date_seq.EXISTS(v_loop+1) THEN
      v_num_days := g_date_seq(v_loop+1) - g_date_seq(v_loop);
    END IF;
/*2692616*/IF g_date_seq.EXISTS(v_loop+1) THEN
    if (v_num_days <> 0) then
      bucket_cells((DAILY_REQUIRED-1)*NUM_OF_COLUMNS+v_loop) :=
        bucket_cells((REQUIRED_HOURS-1)*NUM_OF_COLUMNS+v_loop) /
        v_num_days;
      bucket_cells((DAILY_AVAILABLE-1)*NUM_OF_COLUMNS+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*NUM_OF_COLUMNS+v_loop) /
        v_num_days;
    end if;
/*2692616*/ END IF;

    -- --------------------------
    -- Cost for lines are already
    -- populated in add_plan
    -- --------------------------
    IF (p_line_id = -1) THEN
      bucket_cells((RESOURCE_COST-1)*NUM_OF_COLUMNS+v_loop) := v_res_cost *
    bucket_cells((REQUIRED_HOURS-1)*NUM_OF_COLUMNS+v_loop);
    END IF;
  END LOOP;

END calculate_cum;




-- =============================================================================
-- Name: flush_crp_plan
-- Desc: It inserts the date for 1 dept/res or line into CRP_CAPACITY_PLANS
-- =============================================================================
PROCEDURE flush_crp_plan(
        p_org_id        NUMBER,
        p_dept_id       NUMBER,
        p_line_id       NUMBER,
        p_res_id        NUMBER) IS
  v_dept_code       VARCHAR2(10) := '';
  v_line_code       VARCHAR2(10) := '';
  v_dept_class_code VARCHAR2(10) := '';
  v_res_code        VARCHAR2(10) := '';
  v_res_grp_name    VARCHAR2(30) := '';
  v_resource_type_code  VARCHAR2(80) := '';
  v_loop        BINARY_INTEGER := 1;
BEGIN

  g_error_stmt := 'Debug - flush_crp_plan - 5';
  IF (p_line_id = -1) THEN
    --      NUM_OF_TYPES := 15;
    SELECT  dept.department_code,
        dept.department_class_code,
        res.resource_code,
        lkps.meaning,
        dept_res.resource_group_name
    INTO    v_dept_code,
        v_dept_class_code,
        v_res_code,
        v_resource_type_code,
        v_res_grp_name
    FROM    mfg_lookups lkps,
        bom_resources   res,
        bom_department_resources dept_res,
        bom_departments dept
    WHERE   lkps.lookup_type(+) = 'BOM_RESOURCE_TYPE'
    AND     lkps.lookup_code(+) = res.resource_type
    AND     res.resource_id = p_res_id
    AND     dept_res.department_id = p_dept_id
    AND     dept_res.resource_id = p_res_id
    AND     dept.department_id = p_dept_id;
  ELSE
    --      NUM_OF_TYPES := 9;
    SELECT  line.line_code
    INTO    v_line_code
    FROM    wip_lines line
    WHERE   line.line_id = p_line_id;
  END IF;

  g_error_stmt := 'Debug - flush_crp_plan - 10';
  FOR v_loop IN 1..NUM_OF_TYPES LOOP

    g_error_stmt := 'Debug - flush_crp_plan - 30 - loop'||to_char(v_loop);
    INSERT INTO crp_capacity_plans(
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    organization_id,
    department_id,
    resource_id,
    line_id,
    type_id,
    department_name,
    department_class,
    resource_name,
    resource_type,
    resource_group_name,
    line_name,
    period1,    period2,    period3,    period4,
    period5,    period6,    period7,    period8,
    period9,    period10,   period11,   period12,
    period13,   period14,   period15,   period16,
    period17,   period18,   period19,   period20,
    period21,   period22,   period23,   period24,
    period25,   period26,   period27,   period28,
    period29,   period30,   period31,   period32,
    period33,   period34,   period35,   period36)
    VALUES (
    g_query_id,
    SYSDATE,
    -1,
    SYSDATE,
    -1,
    -1,
    p_org_id,
    p_dept_id,
    p_res_id,
    p_line_id,
    v_loop,
    NVL(v_dept_code, v_line_code),
    v_dept_class_code,
    v_res_code,
    v_resource_type_code,
    v_res_grp_name,
    v_line_code,
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+1),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+2),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+3),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+4),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+5),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+6),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+7),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+8),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+9),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+10),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+11),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+12),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+13),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+14),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+15),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+16),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+17),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+18),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+19),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+20),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+21),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+22),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+23),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+24),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+25),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+26),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+27),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+28),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+29),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+30),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+31),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+32),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+33),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+34),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+35),
    bucket_cells((v_loop-1)*NUM_OF_COLUMNS+36));
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
      FOR v_cnt IN 1..NUM_OF_TYPES*NUM_OF_COLUMNS LOOP
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
      FROM   mtl_parameters
      WHERE  organization_id = activity_rec.org_id;

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
/* 2663505 - Removed the defaulting of p_current_data since this parameter
is always passed. */

FUNCTION populate_horizontal_plan(
            p_item_list_id      IN NUMBER,
            p_planned_org       IN NUMBER,
            p_org_id        IN NUMBER,
            p_compile_designator    IN VARCHAR2,
            p_bucket_type       IN NUMBER,
            p_cutoff_date       IN DATE,
            p_current_data      IN NUMBER) RETURN NUMBER IS
  v_no_rows         BOOLEAN;
  v_last_dept_id        NUMBER := -2;
  v_last_org_id         NUMBER := -2;
  v_last_res_id         NUMBER := -2;
  v_last_line_id        NUMBER := -2;
  v_cnt             NUMBER;
BEGIN

  -- ----------------------------
  -- Initialize Global variables
  -- ----------------------------
  g_error_stmt := 'Debug - populate_horizontal_plan - 10';
  g_item_list_id := p_item_list_id;
  g_org_id := p_org_id;
  g_planned_org := p_planned_org;
  g_designator :=p_compile_designator;
  g_bucket_type := p_bucket_type;
  g_cutoff_date := p_cutoff_date;
  g_current_data := p_current_data;

  initialize;
  -- dbms_output.put_line(g_error_stmt);

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';
  -- dbms_output.put_line(g_error_stmt);

  IF g_current_data = SYS_YES THEN
    OPEN crp_current_activity;
  ELSE
    OPEN crp_snapshot_activity;
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
      FETCH crp_current_activity INTO activity_rec;
      IF (crp_current_activity%NOTFOUND) THEN
    v_no_rows := TRUE;
      END IF;
    ELSE
      FETCH crp_snapshot_activity INTO activity_rec;
      IF (crp_snapshot_activity%NOTFOUND) THEN
    v_no_rows := TRUE;
      END IF;
    END IF;

    g_error_stmt := 'Debug - populate_horizontal_plan - 40';
    -- dbms_output.put_line(g_error_stmt);
    IF ((v_no_rows OR
     v_last_org_id <> activity_rec.org_id OR
     v_last_dept_id <> activity_rec.department_id OR
     v_last_line_id <> activity_rec.line_id OR
     v_last_res_id <> activity_rec.resource_id) AND
    v_last_dept_id <> -2) THEN
      -- ==================================================
      -- snapshoting for the last dept/res has finished
      -- We therefore calculate cumulative information,
      -- flush the previous set of data and then
      -- re-initialized for the current dept/res
      -- ==================================================
      g_error_stmt := 'Debug - populate_horizontal_plan - 50';
      calculate_cum(v_last_org_id,v_last_dept_id,
        v_last_line_id,v_last_res_id);

      g_error_stmt := 'Debug - populate_horizontal_plan - 60';
      flush_crp_plan(v_last_org_id,v_last_dept_id,
        v_last_line_id,v_last_res_id);

      g_error_stmt := 'Debug - populate_horizontal_plan - 70';
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
    v_last_res_id := activity_rec.resource_id;
    v_last_dept_id := activity_rec.department_id;
    v_last_line_id := activity_rec.line_id;
  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 90';
  -- dbms_output.put_line(g_error_stmt);
  IF g_current_data = SYS_YES THEN
    CLOSE crp_current_activity;
  ELSE
    CLOSE crp_snapshot_activity;
  END IF;

  return g_query_id;

EXCEPTION WHEN others THEN
  -- dbms_output.put_line(g_error_stmt);
  IF (seqnum_cursor%ISOPEN) THEN
    close seqnum_cursor;
  END IF;
  IF (crp_current_activity%ISOPEN) THEN
    close crp_current_activity;
  END IF;
  IF (crp_snapshot_activity%ISOPEN) THEN
    close crp_snapshot_activity;
  END IF;
  raise;
END populate_horizontal_plan;

procedure MrpAppletPage(filename Varchar2,appname Varchar2) is
server_name  Varchar2(1000);
server_port  Varchar2(1000);
base_url     Varchar2(1000);
begin
   server_name := owa_util.get_cgi_env('SERVER_NAME');
   server_port := owa_util.get_cgi_env('SERVER_PORT');
   if (server_port is not null) then
     base_url := server_name || ':' || server_port;
   else
     base_url := server_name;
   end if;
   htp.htmlOpen;
   htp.p('<applet codebase=/OA_JAVA/
          code="oracle.apps.mrp.graphs.ChartRenderer.class"
                  archive=oracle/apps/mrp/jar/mrpjar.jar
               width=1200
                height=400 >
                    <param name="File"
               value='||replace(filename,' ','+')||'>
                                        <param name="App"
                           value=' || appname || '>
      </applet>');
  htp.htmlClose;

end MrpAppletPage;

END mrp_crp_horizontal_plan;

/

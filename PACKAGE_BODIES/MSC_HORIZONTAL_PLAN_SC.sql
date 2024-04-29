--------------------------------------------------------
--  DDL for Package Body MSC_HORIZONTAL_PLAN_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_HORIZONTAL_PLAN_SC" AS
/*  $Header: MSCPHOPB.pls 120.56.12010000.6 2010/04/30 06:11:55 vkkandul ship $ */

SYS_YES  CONSTANT INTEGER := 1;
SYS_NO   CONSTANT INTEGER := 2;

/* plan types */
SRO_PLAN	    CONSTANT INTEGER := 4;


PURCHASE_ORDER      CONSTANT INTEGER := 1;   /* order type lookup  */
PURCH_REQ           CONSTANT INTEGER := 2;
WORK_ORDER          CONSTANT INTEGER := 3;
AGG_REP_SCHEDULE    CONSTANT INTEGER := 4;
PLANNED_ORDER       CONSTANT INTEGER := 5;
MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
NONSTD_JOB          CONSTANT INTEGER := 7;
RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
REQUIREMENT         CONSTANT INTEGER := 9;
FPO_SUPPLY          CONSTANT INTEGER := 10;
SHIPMENT            CONSTANT INTEGER := 11;
RECEIPT_SHIPMENT    CONSTANT INTEGER := 12;
REPETITIVE_SCHEDULE CONSTANT INTEGER := 13;
DIS_JOB_BY          CONSTANT INTEGER := 14;
NON_ST_JOB_BY       CONSTANT INTEGER := 15;
REP_SCHED_BY        CONSTANT INTEGER := 16;
PLANNED_BY          CONSTANT INTEGER := 17;
ON_HAND_QTY         CONSTANT INTEGER := 18;
FLOW_SCHED          CONSTANT INTEGER := 27;
FLOW_SCHED_BY	    CONSTANT INTEGER := 28;
PAYBACK_SUPPLY      CONSTANT INTEGER := 29;
-- Returns project is out
--RETURNS             CONSTANT INTEGER := 32;

SALES               CONSTANT INTEGER := 10;  /* horizontal plan type lookup */
FORECAST            CONSTANT INTEGER := 20;
PROD_FORECAST       CONSTANT INTEGER := 25;
DEPENDENT           CONSTANT INTEGER := 30;
SCRAP               CONSTANT INTEGER := 40;
PB_DEMAND           CONSTANT INTEGER := 45;
OTHER               CONSTANT INTEGER := 50;
GROSS               CONSTANT INTEGER := 70;
WIP                 CONSTANT INTEGER := 81;
FLOW_SCHEDULE	    CONSTANT INTEGER := 82;
PO                  CONSTANT INTEGER := 83;
REQ                 CONSTANT INTEGER := 85;
TRANSIT             CONSTANT INTEGER := 87;
RECEIVING           CONSTANT INTEGER := 89;
PLANNED             CONSTANT INTEGER := 90;
PB_SUPPLY           CONSTANT INTEGER := 95;
-- Returns Project is Out
--RETURN_SUP          CONSTANT INTEGER := 97;
SUPPLY              CONSTANT INTEGER := 100;
ON_HAND             CONSTANT INTEGER := 105;
PAB                 CONSTANT INTEGER := 110;
SS                  CONSTANT INTEGER := 120;
SS_UNC		    CONSTANT INTEGER := 125;
ATP                 CONSTANT INTEGER := 130;
CURRENT_S           CONSTANT INTEGER := 140;
POH                 CONSTANT INTEGER := 150;
EXP_LOT             CONSTANT INTEGER := 160;
SS_DOS              CONSTANT INTEGER := 180;
SS_VAL              CONSTANT INTEGER := 190;
SSunc_DOS           CONSTANT INTEGER := 210;
SSunc_VAL           CONSTANT INTEGER := 220;
USS                 CONSTANT INTEGER := 230;
USS_DOS             CONSTANT INTEGER := 240;
USS_VAL             CONSTANT INTEGER := 250;
min_inv_lvl         CONSTANT INTEGER := 175;
max_inv_lvl         CONSTANT INTEGER := 177;
TARGET_SER_LVL      CONSTANT INTEGER := 270;
ACHIEVED_SER_LVL     CONSTANT INTEGER := 280;
NON_POOL_SS         CONSTANT INTEGER  := 178;
MANU_VARI           CONSTANT INTEGER  := 183;
MAD1	            CONSTANT INTEGER  := 290;


SALES_OFF           CONSTANT INTEGER := 0; /* offsets */
FORECAST_OFF        CONSTANT INTEGER := 1;
PROD_FORECAST_OFF   CONSTANT INTEGER := 2;  --  Prod Fcst moved up
DEPENDENT_OFF       CONSTANT INTEGER := 3;
SCRAP_OFF           CONSTANT INTEGER := 4;
PB_DEMAND_OFF       CONSTANT INTEGER := 5;
OTHER_OFF           CONSTANT INTEGER := 6;
GROSS_OFF           CONSTANT INTEGER := 7;
WIP_OFF             CONSTANT INTEGER := 8;
PO_OFF              CONSTANT INTEGER := 9;
REQ_OFF             CONSTANT INTEGER := 10;
TRANSIT_OFF         CONSTANT INTEGER := 11;
RECEIVING_OFF       CONSTANT INTEGER := 12;
PLANNED_OFF         CONSTANT INTEGER := 13;
PB_SUPPLY_OFF       CONSTANT INTEGER := 14;
--Returns Project is Out
--RETURNS_OFF         CONSTANT INTEGER := 15;  -- New row Returns
SUPPLY_OFF          CONSTANT INTEGER := 15;
ON_HAND_OFF         CONSTANT INTEGER := 16;
PAB_OFF             CONSTANT INTEGER := 17;
SS_OFF              CONSTANT INTEGER := 18;
ATP_OFF             CONSTANT INTEGER := 19;
CURRENT_S_OFF       CONSTANT INTEGER := 20;
POH_OFF             CONSTANT INTEGER := 21;
EXP_LOT_OFF         CONSTANT INTEGER := 22;
SSUNC_OFF	    CONSTANT INTEGER := 23;
min_inv_lvl_off     CONSTANT INTEGER := 24;
max_inv_lvl_off     CONSTANT INTEGER := 25;
SS_DOS_OFF          CONSTANT INTEGER := 26;
SS_VAL_OFF          CONSTANT INTEGER := 27;
SSUNC_DOS_OFF       CONSTANT INTEGER := 28;
SSUNC_VAL_OFF       CONSTANT INTEGER := 29;
USS_OFF             CONSTANT INTEGER := 30;
USS_DOS_OFF         CONSTANT INTEGER := 31;
USS_VAL_OFF         CONSTANT INTEGER := 32;
TARGET_SER_OFF      CONSTANT INTEGER := 33;
ACHIEVED_SER_OFF     CONSTANT INTEGER := 34;
NON_POOL_SS_OFF     CONSTANT INTEGER  := 35;
MANF_VARI_OFF       CONSTANT INTEGER  := 36;
PURC_VARI_OFF       CONSTANT INTEGER  := 37;
TRAN_VARI_OFF       CONSTANT INTEGER  := 38;
DMND_VARI_OFF       CONSTANT INTEGER  := 39;
MAD_OFF             CONSTANT INTEGER  := 40;
MAPE_OFF            CONSTANT INTEGER  := 41;

NUM_OF_TYPES        CONSTANT INTEGER := 42;

/* WIP job status lookups */
JOB_UNRELEASED          CONSTANT INTEGER := 1;
JOB_RELEASED            CONSTANT INTEGER := 3;
JOB_COMPLETE            CONSTANT INTEGER := 4;
JOB_HOLD                        CONSTANT INTEGER := 6;

/* Schedule Level */
UPDATED_SCHEDULE        CONSTANT INTEGER := 2;

/* Schedule supply demand */
SCHEDULE_DEMAND         CONSTANT INTEGER := 1;
SCHEDULE_SUPPLY         CONSTANT INTEGER := 2;

/* Independent demand types for Current Data */
IDT_SCHEDULE            CONSTANT INTEGER := 1;
IDT_FORECAST        CONSTANT INTEGER := 2;

/* forecast buckets */
DAILY_BUCKET            CONSTANT INTEGER := 1;
WEEKLY_BUCKET           CONSTANT INTEGER := 2;
MONTHLY_BUCKET          CONSTANT INTEGER := 3;

/* MRP demand types */
DEMAND_PLANNED_ORDER CONSTANT INTEGER := 1;
DEMAND_OPTIONAL         CONSTANT INTEGER := 22;
DEMAND_PAYBACK          CONSTANT INTEGER := 27;

/* Rounding control */
DO_ROUND                        CONSTANT INTEGER := 1;
DO_NOT_ROUND            CONSTANT INTEGER := 2;

/* safety stock code */
NON_MRP_PCT             CONSTANT INTEGER := 1;

/* lot control */
FULL_LOT_CONTROL        CONSTANT INTEGER := 2;

/* sub inventory type */
NETTABLE                        CONSTANT INTEGER := 1;

/*MTL_DEMAND types */
SALES_ORDER             CONSTANT INTEGER := 2;

/* input designator type */
MDS_DESIGNATOR_TYPE     CONSTANT INTEGER := 1;

/* global variable for number of buckets to display for the plan */
g_num_of_buckets	NUMBER;

g_error_stmt		VARCHAR2(200);

g_use_sup_req number :=0;

  NODE_REGULAR_ITEM CONSTANT NUMBER :=0;
  NODE_ITEM_SUPPLIER CONSTANT NUMBER := 1;
  NODE_DEPT_RES CONSTANT NUMBER := 2;
  NODE_LINE CONSTANT NUMBER := 3;
  NODE_TRANS_RES CONSTANT NUMBER := 4;
  NODE_PF_ITEM CONSTANT NUMBER := 5;
  NODE_GL_FORECAST_ITEM CONSTANT NUMBER := 6;
  NODE_RES_INSTANCE CONSTANT NUMBER := 7;

TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
-- ---------------------------------------------------------
-- compute_daily_rate_t is only used by the current_activity
-- cursor so it maintains the joins to BOM tables instead
-- of being converted to MSC.
-- ---------------------------------------------------------
function compute_daily_rate_t
                    (var_calendar_code varchar2,
                     var_exception_set_id number,
                     var_daily_production_rate number,
                     var_quantity_completed number,
                     fucd date,
                     var_date date) return number is
var_tot_completed number ;
var_diff number ;
var_change number ;
var_prior_completed number ;
var_ret_val number ;
var_fucd_seq number ;
var_lucd_seq number ;
Begin
    select cal.prior_seq_num
    into   var_fucd_seq
    FROM    bom_calendar_dates  cal
    WHERE   cal.exception_set_id = var_exception_set_id
    AND   cal.calendar_code = var_calendar_code
    AND   cal.calendar_date = TRUNC(fucd) ;

    select cal.prior_seq_num
    into   var_lucd_seq
    FROM    bom_calendar_dates  cal
    WHERE   cal.exception_set_id = var_exception_set_id
    AND   cal.calendar_code = var_calendar_code
    AND   cal.calendar_date = TRUNC(var_date) ;

    var_diff := ABS(var_fucd_seq - var_lucd_seq) + 1 ;

    var_tot_completed := var_diff * var_daily_production_rate ;

    if (var_tot_completed <= var_quantity_completed)
    then
        var_ret_val := 0;
        return(var_ret_val);
    end if;

    var_prior_completed := var_daily_production_rate * (var_diff -1) ;

    var_change := var_quantity_completed - var_prior_completed ;

    if (var_change > 0 )
    then
        var_ret_val := var_daily_production_rate - var_change ;
    else
        var_ret_val := var_daily_production_rate  ;
    end if;

    return(var_ret_val);
end ;


Procedure populate_horizontal_plan (p_agg_hzp IN NUMBER, -- can be removed
                             item_list_id IN NUMBER,
                             arg_query_id IN NUMBER,
                             arg_plan_id IN NUMBER,
                             arg_plan_organization_id IN NUMBER,
                             arg_plan_instance_id IN NUMBER,
                             arg_bucket_type IN NUMBER,
                             arg_cutoff_date IN DATE,
                             arg_current_data IN NUMBER DEFAULT 2,
                             arg_ind_demand_type IN NUMBER DEFAULT NULL,
                             arg_source_list_name IN VARCHAR2 DEFAULT NULL,
                             enterprize_view IN BOOLEAN,
                             arg_res_level IN NUMBER DEFAULT 1,
                             arg_resval1 IN VARCHAR2 DEFAULT NULL,
                             arg_resval2 IN NUMBER DEFAULT NULL,
                             arg_category_name IN VARCHAR2 DEFAULT NULL, -- can be remove
                             arg_ep_view_also IN BOOLEAN DEFAULT FALSE) IS

-- -------------------------------------------------
-- This cursor select number of buckets in the plan.
-- -------------------------------------------------
CURSOR plan_buckets IS
SELECT DECODE(arg_plan_id, -1, sysdate, trunc(curr_start_date)),
	DECODE(arg_plan_id, -1, sysdate+365, trunc(curr_cutoff_date))
FROM msc_plans
WHERE plan_id = arg_plan_id;

-- -------------------------------------------------
-- This cursor selects the dates for the buckets.
-- -------------------------------------------------
CURSOR bucket_dates(p_start_date DATE, p_end_date DATE) IS
SELECT cal.calendar_date
FROM msc_calendar_dates cal,
msc_trading_partners tp
WHERE tp.sr_tp_id = arg_plan_organization_id
AND tp.sr_instance_id = arg_plan_instance_id
AND tp.calendar_exception_set_id = cal.exception_set_id
AND tp.partner_type = 3
AND tp.calendar_code = cal.calendar_code
AND tp.sr_instance_id = cal.sr_instance_id
AND cal.calendar_date BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date)
ORDER BY cal.calendar_date;

cursor c_first_date(p_st_date DATE) is
select period_start_date
from msc_analysis_aggregate
where plan_id = arg_plan_id
  and record_type = 3
  and period_type = 1
  and period_start_date <= p_st_date
order by period_start_date desc;

l_plan_start_date	DATE;
l_plan_end_date		DATE;
l_first_date		DATE;

l_bucket_number		NUMBER := 0;
l_bucket_date		DATE;

last_date       DATE;
sid             NUMBER;
l_plan_type	    NUMBER := 1;

-- --------------------------------------------
-- This cursor selects the snapshot activity in
-- MSC_DEMANDS and MSC_SUPPLIES
-- for the items per organizatio for a plan..
-- --------------------------------------------
CURSOR  mrp_snapshot_activity IS
 SELECT /*+ INDEX(rec, MSC_SUPPLIES_N1) */
        list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO,
        PURCH_REQ,          REQ,
        WORK_ORDER,         WIP,
        FLOW_SCHED,         WIP,
        REPETITIVE_SCHEDULE,PLANNED,
        PLANNED_ORDER,      PLANNED,
        NONSTD_JOB,         WIP,
        RECEIPT_PURCH_ORDER,RECEIVING,
        SHIPMENT,           TRANSIT,
        RECEIPT_SHIPMENT,   RECEIVING,
        PAYBACK_SUPPLY, PB_SUPPLY,
        ON_HAND_QTY, ON_HAND,
        AGG_REP_SCHEDULE, CURRENT_S,
      --  RETURNS,          RETURN_SUP,
        PLANNED) row_type,
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO_OFF,
        PURCH_REQ,          REQ_OFF,
        WORK_ORDER,         WIP_OFF,
        FLOW_SCHED,         WIP_OFF,
        REPETITIVE_SCHEDULE,PLANNED_OFF,
        PLANNED_ORDER,      PLANNED_OFF,
        NONSTD_JOB,         WIP_OFF,
        RECEIPT_PURCH_ORDER,RECEIVING_OFF,
        SHIPMENT,           TRANSIT_OFF,
        RECEIPT_SHIPMENT,   RECEIVING_OFF,
    DIS_JOB_BY,     WIP_OFF,
    NON_ST_JOB_BY,      WIP_OFF,
    REP_SCHED_BY,       PLANNED_OFF,
    PLANNED_BY,     PLANNED_OFF,
	FLOW_SCHED_BY,	WIP_OFF,
        PAYBACK_SUPPLY, PB_SUPPLY_OFF,
        ON_HAND_QTY, ON_HAND_OFF,
        AGG_REP_SCHEDULE, CURRENT_S_OFF,
      --  RETURNS,          RETURNS_OFF,
        PLANNED_OFF) offset,
        dates.calendar_date new_date,
        decode(rec.order_type, PAYBACK_SUPPLY,
               dates.calendar_date, rec.old_schedule_date) old_date,
        SUM(DECODE(rec.disposition_status_type,
            2, 0, DECODE(rec.last_unit_completion_date,
                  NULL, nvl(rec.firm_quantity,rec.new_order_quantity),
                  rec.daily_rate))) new_quantity,
        SUM(NVL(rec.old_order_quantity,0)) old_quantity,
        sum(0) dos,
        0 cost
FROM    msc_form_query      list,
        msc_trading_partners      param,
        msc_system_items msi,
        msc_supplies rec,
        msc_calendar_dates      dates
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
                AND rec.project_id is NULL)
         OR  (DECODE(arg_res_level,
                       3,nvl(rec.planning_group,'-23453'),
                       4,nvl(to_char(rec.project_id), '-23453'))
                                                = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
                AND  nvl(to_char(rec.project_id), '-23453')
                                                = nvl(arg_resval1,'-23453')
                AND  nvl(rec.task_id, -23453) = nvl(arg_resval2, -23453)))
AND	dates.sr_instance_id = rec.sr_instance_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.calendar_date BETWEEN
           trunc(nvl(rec.firm_date,rec.new_schedule_date))
AND     NVL(rec.last_unit_completion_date,
                 trunc(nvl(rec.firm_date,rec.new_schedule_date)))
AND     (trunc(nvl(rec.firm_date,rec.new_schedule_date)) <= last_date OR
         trunc(rec.old_schedule_date) <= last_date)
AND     rec.plan_id = msi.plan_id
AND     rec.inventory_item_id = msi.inventory_item_id
AND     rec.organization_id = msi.organization_id
AND     rec.sr_instance_id = msi.sr_instance_id
AND     msi.plan_id = list.number4
AND     msi.inventory_item_id = list.number1
AND     msi.organization_id = list.number2
AND     msi.sr_instance_id = list.number3
AND     param.sr_tp_id = rec.organization_id
AND     param.sr_instance_id = rec.sr_instance_id
AND     param.partner_type = 3
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
GROUP BY
        list.number5,
        list.number6,
        list.number3,
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO,
        PURCH_REQ,          REQ,
        WORK_ORDER,         WIP,
        FLOW_SCHED,         WIP,
        REPETITIVE_SCHEDULE,PLANNED,
        PLANNED_ORDER,      PLANNED,
        NONSTD_JOB,         WIP,
        RECEIPT_PURCH_ORDER,RECEIVING,
        SHIPMENT,           TRANSIT,
        RECEIPT_SHIPMENT,   RECEIVING,
        PAYBACK_SUPPLY, PB_SUPPLY,
        ON_HAND_QTY, ON_HAND,
        AGG_REP_SCHEDULE, CURRENT_S,
       -- RETURNS,          RETURN_SUP,
        PLANNED),
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO_OFF,
        PURCH_REQ,          REQ_OFF,
        WORK_ORDER,         WIP_OFF,
        FLOW_SCHED,         WIP_OFF,
        REPETITIVE_SCHEDULE,PLANNED_OFF,
        PLANNED_ORDER,      PLANNED_OFF,
        NONSTD_JOB,         WIP_OFF,
        RECEIPT_PURCH_ORDER,RECEIVING_OFF,
        SHIPMENT,           TRANSIT_OFF,
        RECEIPT_SHIPMENT,   RECEIVING_OFF,
    DIS_JOB_BY,     WIP_OFF,
    NON_ST_JOB_BY,      WIP_OFF,
    REP_SCHED_BY,       PLANNED_OFF,
    PLANNED_BY,     PLANNED_OFF,
	FLOW_SCHED_BY, 	WIP_OFF,
        PAYBACK_SUPPLY, PB_SUPPLY_OFF,
        ON_HAND_QTY, ON_HAND_OFF,
        AGG_REP_SCHEDULE, CURRENT_S_OFF,
       -- RETURNS,          RETURNS_OFF,
        PLANNED_OFF),
       dates.calendar_date,
       decode(rec.order_type, PAYBACK_SUPPLY, dates.calendar_date,
             rec.old_schedule_date)
UNION ALL
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        DECODE(mgr.origination_type,
            1, DEPENDENT,
            2, DEPENDENT,
            3, DEPENDENT,
            4, DEPENDENT,
            5, EXP_LOT,
            6, SALES,
            7, FORECAST,
            8, OTHER,
            9, OTHER,
            10, OTHER,
            11, OTHER,
            12, OTHER,
            15, OTHER,
            16, SCRAP,
            17, SCRAP,
            18, SCRAP,
            19, SCRAP,
            20, SCRAP,
            21, SCRAP,
            22, PROD_FORECAST,
            23, SCRAP,
            24, DEPENDENT,
            25, DEPENDENT,
	    26, SCRAP,
            29, FORECAST,          	-- for SRO
            30, SALES,
            DEMAND_PAYBACK, PB_DEMAND,
            OTHER) row_type,
        DECODE(mgr.origination_type,
            1, DEPENDENT_OFF,
            2, DEPENDENT_OFF,
            3, DEPENDENT_OFF,
            4, DEPENDENT_OFF,
            5, EXP_LOT_OFF,
            6, SALES_OFF,
            7, FORECAST_OFF,
            8, OTHER_OFF,
            9, OTHER_OFF,
            10, OTHER_OFF,
            11, OTHER_OFF,
            12, OTHER_OFF,
            15, OTHER_OFF,
            16, SCRAP_OFF,
            17, SCRAP_OFF,
            18, SCRAP_OFF,
            19, SCRAP_OFF,
            20, SCRAP_OFF,
            21, SCRAP_OFF,
            22, PROD_FORECAST_OFF,
            23, SCRAP_OFF,
            24, DEPENDENT_OFF,
            25, DEPENDENT_OFF,
	    26, SCRAP_OFF,
	    29, FORECAST_OFF,
            30, SALES_OFF,
            DEMAND_PAYBACK, PB_DEMAND_OFF,
            OTHER_OFF) offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(DECODE(mgr.assembly_demand_comp_date,
            NULL, DECODE(mgr.origination_type,
                     29,(nvl(mgr.probability,1)*
                         nvl(mgr.firm_quantity,using_requirement_quantity)),
                     31, 0,
                     nvl(mgr.firm_quantity,using_requirement_quantity)),
            DECODE(mgr.origination_type,
                   29,(nvl(mgr.probability,1)*daily_demand_rate),
                   31, 0,
                   daily_demand_rate)))/
        DECODE(nvl(LEAST(SUM(DECODE(mgr.origination_type,
                                    29,nvl(mgr.probability,0),
                                    null)) ,1) ,1),
               0,1,
               nvl(LEAST(SUM(DECODE(mgr.origination_type,
                                    29,nvl(mgr.probability,0),
                                    null)) ,1) ,1)) new_quantity,
        0 old_quantity,
        0 dos,
        0 cost
FROM    msc_form_query      list,
        msc_trading_partners      param,
        msc_demands  mgr,
        msc_calendar_dates  dates
WHERE (arg_res_level = 1
       OR  (arg_res_level = 2
                AND mgr.project_id is NULL)
       OR  (DECODE(arg_res_level,
                      3,nvl(mgr.planning_group,'-23453'),
                      4,nvl(to_char(mgr.project_id), '-23453'))
                                                = nvl(arg_resval1,'-23453'))
       OR  (arg_res_level = 5
                AND  nvl(to_char(mgr.project_id), '-23453')
                                   = nvl(arg_resval1,'-23453')
                 AND  nvl(mgr.task_id, -23453) = nvl(arg_resval2, -23453)))
AND	dates.sr_instance_id = mgr.sr_instance_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.calendar_date BETWEEN trunc(
                      nvl(mgr.firm_date,mgr.using_assembly_demand_date))
AND     NVL(trunc(mgr.assembly_demand_comp_date),
	trunc(nvl(mgr.firm_date,mgr.using_assembly_demand_date)))
AND     trunc(nvl(mgr.firm_date,mgr.using_assembly_demand_date))
                <= trunc(last_date)
AND     mgr.plan_id = list.number4
AND     mgr.inventory_item_id = list.number1
AND     mgr.organization_id = list.number2
AND     mgr.sr_instance_id = list.number3
AND     mgr.origination_type > 0 -- bug5653263
AND     param.sr_tp_id = mgr.organization_id
AND     param.sr_instance_id = mgr.sr_instance_id
AND     param.partner_type = 3
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
AND     (l_plan_type <> 4 or
         l_plan_type = 4 and -- 5086979: IO plan don't show past due demand
         trunc(mgr.using_assembly_demand_date) >= trunc(l_plan_start_date))
AND     not exists (
        select 'cancelled IR'
        from   msc_supplies mr
        where  mgr.origination_type in (30,6)
        and    mgr.disposition_id = mr.transaction_id
        and    mgr.plan_id = mr.plan_id
        and    mgr.sr_instance_id = mr.sr_instance_id
        and    mr.disposition_status_type = 2)
GROUP BY
        list.number5,
        list.number6,
        list.number3,
        DECODE(mgr.origination_type,
            1, DEPENDENT,
            2, DEPENDENT,
            3, DEPENDENT,
            4, DEPENDENT,
            5, EXP_LOT,
            6, SALES,
            7, FORECAST,
            8, OTHER,
            9, OTHER,
            10, OTHER,
            11, OTHER,
            12, OTHER,
            15, OTHER,
            16, SCRAP,
            17, SCRAP,
            18, SCRAP,
            19, SCRAP,
            20, SCRAP,
            21, SCRAP,
            22, PROD_FORECAST,
            23, SCRAP,
            24, DEPENDENT,
            25, DEPENDENT,
	    26, SCRAP,
	    29, FORECAST,
	    30, SALES,
            DEMAND_PAYBACK, PB_DEMAND,
            OTHER),
        DECODE(mgr.origination_type,
            1, DEPENDENT_OFF,
            2, DEPENDENT_OFF,
            3, DEPENDENT_OFF,
            4, DEPENDENT_OFF,
            5, EXP_LOT_OFF,
            6, SALES_OFF,
            7, FORECAST_OFF,
            8, OTHER_OFF,
            9, OTHER_OFF,
            10, OTHER_OFF,
            11, OTHER_OFF,
            12, OTHER_OFF,
            15, OTHER_OFF,
            16, SCRAP_OFF,
            17, SCRAP_OFF,
            18, SCRAP_OFF,
            19, SCRAP_OFF,
            20, SCRAP_OFF,
            21, SCRAP_OFF,
            22, PROD_FORECAST_OFF,
            23, SCRAP_OFF,
            24, DEPENDENT_OFF,
            25, DEPENDENT_OFF,
	    26, SCRAP_OFF,
	    29, FORECAST_OFF,
            30, SALES_OFF,
            DEMAND_PAYBACK, PB_DEMAND_OFF,
            OTHER_OFF),
        dates.calendar_date,
        dates.calendar_date,
            0
UNION ALL
 ---     ------------------------------------
 ---              FOR MAD / MAPE
 ---     ------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        MAD1 row_type,
        MAD_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SQRT(SUM(DECODE(mgr.error_type, 1, mgr.forecast_MAD * mgr.forecast_MAD, 0))) new_quantity,
        SQRT(SUM(DECODE(mgr.error_type, 2, ((mgr.forecast_MAD * mgr.using_requirement_quantity) * (mgr.forecast_MAD * mgr.using_requirement_quantity)), 0))) /
        DECODE(SUM (NVL(mgr.using_requirement_quantity, 1)) ,0 ,1 ,
               SUM (NVL(mgr.using_requirement_quantity, 1)))  old_quantity,
        0 dos,
        0 cost
FROM    msc_form_query      list,
        msc_trading_partners      param,
        msc_demands  mgr,
        msc_calendar_dates  dates
 WHERE (arg_res_level = 1
       OR  (arg_res_level = 2
                AND mgr.project_id is NULL)
       OR  (DECODE(arg_res_level,
                      3,nvl(mgr.planning_group,'-23453'),
                      4,nvl(to_char(mgr.project_id), '-23453'))
                                                = nvl(arg_resval1,'-23453'))
       OR  (arg_res_level = 5
                AND  nvl(to_char(mgr.project_id), '-23453')
                                   = nvl(arg_resval1,'-23453')
               AND  nvl(mgr.task_id, -23453) = nvl(arg_resval2, -23453)))
AND	dates.sr_instance_id = mgr.sr_instance_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.calendar_date BETWEEN trunc(mgr.using_assembly_demand_date)
AND     NVL(trunc(mgr.assembly_demand_comp_date),
	trunc(mgr.using_assembly_demand_date))
AND     trunc(mgr.using_assembly_demand_date) <= trunc(last_date)
AND     mgr.plan_id = list.number4
AND     mgr.inventory_item_id = list.number1
AND     mgr.organization_id = list.number2
AND     mgr.sr_instance_id = list.number3
AND     param.sr_tp_id = mgr.organization_id
AND     param.sr_instance_id = mgr.sr_instance_id
AND     param.partner_type = 3
AND     mgr.origination_type in (7, 29)
AND     list.query_id = item_list_id
AND     l_plan_type = 4 -- only show MAD for IO plan
AND     list.number7 <> NODE_GL_FORECAST_ITEM
 GROUP BY
        list.number5,
        list.number6,
        list.number3,
        MAD1, MAD_OFF,
        dates.calendar_date,
        dates.calendar_date,
            0
UNION ALL
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        ATP row_type,
        ATP_OFF offset,
        avail.schedule_date new_date,
        avail.schedule_date old_date,
        avail.quantity_available new_quantity,
        0 old_quantity,
        0 dos,
        0 cost
FROM    msc_form_query      list,
        msc_available_to_promise avail
WHERE   avail.schedule_date < last_date
AND     avail.organization_id = list.number2
AND     avail.plan_id = list.number4
AND     avail.inventory_item_id = list.number1
AND     avail.sr_instance_id = list.number3
AND     list.query_id = item_list_id
UNION ALL
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        SS row_type,
        SS_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.safety_stock_quantity) new_quantity,
        safety.organization_id old_quantity,
        sum(safety.achieved_days_of_supply) dos,
        sum(safety.safety_stock_quantity * item.standard_cost) cost
FROM    msc_safety_stocks    safety,
        msc_form_query      list ,
        msc_system_items    item
WHERE   safety.period_start_date <= last_date
AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
      decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
and     safety.safety_stock_quantity is not null
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
GROUP BY  list.number5,
          list.number6,
          list.number3,
          SS, SS_OFF, safety.period_start_date, safety.organization_id
UNION ALL
--------------------------------------------------------------------
-- This will select unconstrained safety stock for sro plans
---------------------------------------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        SS_UNC row_type,
        SSUNC_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.TARGET_SAFETY_STOCK) new_quantity,
        sum(safety.TOTAL_UNPOOLED_SAFETY_STOCK) old_quantity,
        sum(safety.target_days_of_supply) dos,
        sum(safety.TARGET_SAFETY_STOCK * item.standard_cost) cost
FROM    msc_safety_stocks    safety,
        msc_form_query      list ,
        msc_system_items    item
WHERE   safety.period_start_date <= last_date
AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
     decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
-- and     safety.target_safety_stock is not null
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
GROUP BY list.number5,list.number6,list.number3,
         SS_UNC, SSUNC_OFF,
         safety.period_start_date
UNION ALL
--------------------------------------------------------------------
-- This will select user specified safety stocks
---------------------------------------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        USS row_type,
        USS_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.USER_DEFINED_SAFETY_STOCKS) new_quantity,
        sum(0) old_quantity,
        sum(safety.user_defined_dos) dos,
        sum(safety.USER_DEFINED_SAFETY_STOCKS * item.standard_cost) cost
FROM    msc_safety_stocks    safety,
        msc_form_query      list,
        msc_system_items    item
WHERE   safety.period_start_date <= last_date
AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
     decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
and    nvl(safety.user_defined_safety_stocks,safety.user_defined_dos) is not null
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
GROUP BY list.number5,list.number6,list.number3,
         USS, USS_OFF,
         safety.period_start_date, 0
UNION ALL
--------------------------------------------------------------------
-- This will select Lead Time Variability Percentages
---------------------------------------------------------------------
 SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        MANU_VARI row_type,
        MANF_VARI_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.MFG_LTVAR_SS_PERCENT) new_quantity,
        sum(safety.SUP_LTVAR_SS_PERCENT) old_quantity,
        sum(safety.TRANSIT_LTVAR_SS_PERCENT) dos,
        sum(safety.DEMAND_VAR_SS_PERCENT) cost
FROM    msc_safety_stocks    safety,
        msc_form_query      list,
        msc_system_items    item
WHERE   safety.period_start_date <= last_date
AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
     decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
GROUP BY list.number5,list.number6,list.number3,
         MANU_VARI, MANF_VARI_OFF,
         safety.period_start_date
UNION ALL
--------------------------------------------------------------------
-- This will select minimum inventory levels
---------------------------------------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        min_inv_lvl row_type,
        min_inv_lvl_off offset,
        lvl.inventory_date new_date,
        lvl.inventory_date old_date,
        min(lvl.Min_quantity) new_quantity,
        min(0) old_quantity,
        min(lvl.min_quantity_dos) dos,
        0
FROM    msc_inventory_levels lvl,
        msc_form_query      list
WHERE   lvl.inventory_date <= last_date
AND     lvl.organization_id = list.number2
AND     lvl.sr_instance_id = list.number3
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
AND     nvl(lvl.min_quantity,lvl.min_quantity_dos) is not null
GROUP BY list.number5,list.number6,list.number3,
         min_inv_lvl, min_inv_lvl_off,
         lvl.inventory_date
UNION ALL
--------------------------------------------------------------------
-- This will select maximum inventory levels
---------------------------------------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        max_inv_lvl row_type,
        max_inv_lvl_off offset,
        lvl.inventory_date new_date,
        lvl.inventory_date old_date,
        max(lvl.Max_quantity) new_quantity,
        max(0) old_quantity,
        max(lvl.max_quantity_dos) dos,
        0
FROM    msc_inventory_levels lvl,
        msc_form_query      list
WHERE   lvl.inventory_date<= last_date
AND     lvl.organization_id = list.number2
AND     lvl.sr_instance_id = list.number3
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
AND     nvl(lvl.max_quantity,lvl.max_quantity_dos) is not null
GROUP BY list.number5,list.number6,list.number3,
         max_inv_lvl, max_inv_lvl_off,
         lvl.inventory_date
union all
--------------------------------------------------------------------
-- This will select Target Inventory Levels
---------------------------------------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        TARGET_SER_LVL row_type,
        TARGET_SER_OFF offset,
        nvl(lvl.week_start_date, lvl.period_start_date) new_date,
        nvl(lvl.week_start_date, lvl.period_start_date) old_date,
        avg(lvl.TARGET_SERVICE_LEVEL) new_quantity,
        0 old_quantity,
        0 dos,
        0
FROM    msc_analysis_aggregate lvl,
        msc_form_query      list,
        msc_plan_buckets mpb
WHERE     lvl.record_type = 3
AND     lvl.period_type = 1
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     lvl.organization_id = list.number2
AND     lvl.sr_instance_id = list.number3
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
AND     mpb.plan_id = lvl.plan_id
AND     ( (mpb.bucket_type = 2 and lvl.week_start_date   = mpb.BKT_START_DATE) or
          (mpb.bucket_type = 3 and lvl.period_start_date = mpb.BKT_START_DATE) )
GROUP BY list.number5,list.number6,list.number3,
         TARGET_SER_LVL, TARGET_SER_OFF,
        nvl(lvl.week_start_date, lvl.period_start_date) ,
        nvl(lvl.week_start_date, lvl.period_start_date)
union all

--------------------------------------------------------------------
-- This will select ACHIEVED Inventory Levels
---------------------------------------------------------------------
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        ACHIEVED_SER_LVL row_type,
        ACHIEVED_SER_OFF offset,
        nvl(lvl.week_start_date, lvl.period_start_date) new_date,
        nvl(lvl.week_start_date, lvl.period_start_date) old_date,
        sum(lvl.ACHIEVED_SERVICE_LEVEL_QTY1)/sum(decode(lvl.ACHIEVED_SERVICE_LEVEL_QTY2, 0, 1, lvl.ACHIEVED_SERVICE_LEVEL_QTY2)) new_quantity,
        0 old_quantity,
        0 dos,
        0
FROM    msc_analysis_aggregate lvl,
        msc_form_query      list,
        msc_plan_buckets mpb
WHERE     lvl.record_type = 3
AND     lvl.period_type = 1
AND     lvl.plan_id = list.number4
AND     lvl.organization_id = list.number2
AND     lvl.sr_instance_id = list.number3
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
AND     list.number7 <> NODE_GL_FORECAST_ITEM
AND     mpb.plan_id = lvl.plan_id
AND     ( (mpb.bucket_type = 2 and lvl.week_start_date   = mpb.BKT_START_DATE) or
          (mpb.bucket_type = 3 and lvl.period_start_date = mpb.BKT_START_DATE) )
GROUP BY list.number5,list.number6,list.number3,
         ACHIEVED_SER_LVL, ACHIEVED_SER_OFF,
        nvl(lvl.week_start_date, lvl.period_start_date) ,
        nvl(lvl.week_start_date, lvl.period_start_date)
union all
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  list.number5,
        list.number6,
        list.number3,
        ON_HAND,
        ON_HAND_OFF,
        to_date(1, 'J'),
        to_date(1, 'J'),
        0,
        0,
        0,
        0
FROM    msc_form_query list
WHERE   list.query_id = item_list_id
ORDER BY
     1, 2, 6, 4;

cursor standard_cost (p_inventory_item_id number,
                      p_sr_instance_id number,
                      p_organization_id number,
                      p_plan_id        number) is
 select nvl(standard_cost,0)
 from msc_system_items
 where inventory_item_id=p_inventory_item_id
 and   organization_id  =p_organization_id
 and   sr_instance_id   =p_sr_instance_id
 and   plan_id          =p_plan_id;

TYPE mrp_activity IS RECORD
     (item_id      NUMBER,
      org_id       NUMBER,
      inst_id       NUMBER,
      row_type     NUMBER,
      offset       NUMBER,
      new_date     DATE,
      old_date     DATE,
      new_quantity NUMBER,
      old_quantity NUMBER,
      DOS          NUMBER,
      cost         number);

activity_rec     mrp_activity;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE column_char   IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE number_arr IS TABLE OF number;

var_dates           calendar_date;   -- Holds the start dates of buckets
bucket_cells_tab    column_number;       -- Holds the quantities per bucket
ep_bucket_cells_tab    column_number;
last_item_id        NUMBER := -1;
last_org_id        NUMBER := -1;
last_inst_id        NUMBER := -1;

prev_ss_qty         number_arr := number_arr(0);
prev_ss_org         number_arr := number_arr(0);
prev_ss_dos_arr     number_arr := number_arr(0);
prev_ss_cost_arr    number_arr := number_arr(0);
prev_ss_quantity    NUMBER := -1;
prev_ss_dos         NUMBER := -1;
prev_ss_cost        number := -1;


prev_non_pool_ss    NUMBER := -1;
non_pool_ss         NUMBER := -1;

prev_target_level   NUMBER := -1;
prev_achieved_level NUMBER := -1;
prev_mad            NUMBER := -1;
prev_mape           NUMBER := -1;
prev_min            NUMBER := -1;
prev_max            NUMBER := -1;

target_level   NUMBER := -1;
achieved_level NUMBER := -1;
mad            NUMBER := -1;
mape           NUMBER := -1;
min_lvl            NUMBER := -1;
max_lvl            NUMBER := -1;

prev_manf_vari     NUMBER := -1;
prev_purc_vari NUMBER := -1;
prev_tran_vari  NUMBER := -1;
prev_dmnd_vari   NUMBER := -1;


manf_vari NUMBER := -1;
purc_vari NUMBER := -1;
tran_vari NUMBER := -1;
dmnd_vari NUMBER := -1;

vari_date date;
prev_vari_date date;

prev_ssunc_q	    NUMBER := -1;
prev_ssunc_dos	    NUMBER := -1;
prev_ssunc_date	    DATE;
ssunc_q		    NUMBER := -1;
ssunc_dos	    NUMBER := -1;
ssunc_date	    DATE;

prev_uss_q          NUMBER := -1;
prev_uss_dos        NUMBER := -1;
prev_uss_date       DATE;
uss_q               NUMBER := -1;
uss_dos             NUMBER := -1;
uss_date            DATE;
ssunc_cost         number := -1;
prev_ssunc_cost    number := -1;
uss_cost            number := -1;
prev_uss_cost       number := -1;

bucket_counter BINARY_INTEGER := 0; -- Id of the current bucket
old_bucket_counter BINARY_INTEGER := 0;
counter        BINARY_INTEGER := 0;

PROCEDURE init_prev_ss_qty IS
   v_count number;
   p_found_org boolean;
BEGIN
if activity_rec.org_id <> -1 THEN -- single org view
   prev_ss_quantity := activity_rec.new_quantity;
   prev_ss_dos := activity_rec.dos;
   prev_ss_cost := activity_rec.cost;
   return;
end if;
   p_found_org := false;
   v_count := nvl(prev_ss_org.last,0);
-- dbms_output.put_line(' in init '||v_count||','||activity_rec.old_quantity||','||activity_rec.new_quantity);
   for a in 1 .. v_count loop
       if prev_ss_org(a) = activity_rec.old_quantity then
          prev_ss_qty(a) := activity_rec.new_quantity;
          prev_ss_dos_arr(a) := activity_rec.dos;
          prev_ss_cost_arr(a) := activity_rec.cost;
          p_found_org := true;
          exit;
       end if;
   end loop;

-- if org_id not exists, add it

   if not(p_found_org) then
      prev_ss_org.extend;
      prev_ss_qty.extend;
      prev_ss_dos_arr.extend;
      prev_ss_cost_arr.extend;
      prev_ss_org(v_count+1) := activity_rec.old_quantity;
      prev_ss_qty(v_count+1) := activity_rec.new_quantity;
      prev_ss_dos_arr(v_count+1) := activity_rec.dos;
      prev_ss_cost_arr(v_count+1) := activity_rec.cost;
  end if;

  prev_ss_quantity := 0;
  prev_ss_dos := 0;
  prev_ss_cost := 0;
  for a in 1..nvl(prev_ss_org.last,0) loop
     prev_ss_quantity := prev_ss_quantity + prev_ss_qty(a);
     prev_ss_dos := prev_ss_dos + prev_ss_dos_arr(a);
     prev_ss_cost := prev_ss_cost + prev_ss_cost_arr(a);
  end loop;

--  dbms_output.put_line('prev = '||prev_ss_quantity||','||prev_ss_dos||','||prev_ss_cost);
END init_prev_ss_qty;

PROCEDURE reset_prev_ss IS
BEGIN
   prev_ss_org.delete;
   prev_ss_qty.delete;
   prev_ss_dos_arr.delete;
   prev_ss_cost_arr.delete;
   prev_ss_quantity := -1;
   prev_ss_dos := -1;
   prev_ss_cost := -1;
END reset_prev_ss;

-- =============================================================================
--
-- add_to_plan add the 'quantity' to the correct cell of the current bucket.
--
-- =============================================================================
PROCEDURE add_to_plan(bucket IN NUMBER,
                      offset IN NUMBER,
                      quantity IN NUMBER,
                      p_enterprise IN boolean default false) IS
location NUMBER;
BEGIN
  g_error_stmt := 'Debug - add_to_plan - 10';
  if quantity = 0 then
     return;
  end if;
  IF p_enterprise then
     location := (bucket - 1) + offset;
     IF offset in (SSUNC_OFF,SSUNC_DOS_OFF, SSUNC_VAL_OFF, SS_OFF,SS_DOS_OFF, SS_VAL_OFF, USS_OFF  , USS_DOS_OFF, USS_VAL_OFF, min_inv_lvl_off , max_inv_lvl_off )THEN
         ep_bucket_cells_tab(location) := quantity;
     ELSE
         ep_bucket_cells_tab(location) :=
             NVL(ep_bucket_cells_tab(location),0) + quantity;
     END IF;
  ELSE  -- not enterprize view
     location := ((bucket - 1) * NUM_OF_TYPES) + offset;
     IF offset in (SSUNC_OFF, SSUNC_DOS_OFF, SSUNC_VAL_OFF, SS_OFF,SS_DOS_OFF, SS_VAL_OFF, USS_OFF  , USS_DOS_OFF, USS_VAL_OFF, min_inv_lvl_off , max_inv_lvl_off) THEN
        bucket_cells_tab(location) := quantity;
     ELSE
        bucket_cells_tab(location) := NVL(bucket_cells_tab(location),0) + quantity;
     END IF;
  END IF;
END;

-- =============================================================================
--
-- flush_item_plan inserts into MRP_MATERIAL_PLANS
--
-- =============================================================================
PROCEDURE flush_item_plan(p_item_id IN NUMBER,
                          p_org_id IN NUMBER,
			  p_inst_id IN NUMBER) IS
loop_counter BINARY_INTEGER := 1;
item_name VARCHAR2(255);
org_code VARCHAR2(7);
atp_counter  BINARY_INTEGER := 1;
total_reqs      NUMBER := 0;
lot_quantity NUMBER := 0;
expired_qty NUMBER := 0;
total_supply NUMBER := 0;
committed_demand NUMBER := 0;
atp_qty NUMBER := 0;
carried_back_atp_qty NUMBER := 0;
atp_flag NUMBER :=2;
l_atp_qty_net MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

cursor check_atp is
  SELECT msi.calculate_atp
  FROM   msc_system_items msi,
         msc_form_query mfq
  WHERE  msi.inventory_item_id = mfq.number1
  AND    msi.organization_id = mfq.number2
  AND    msi.plan_id = arg_plan_id
  AND    msi.sr_instance_id = mfq.number3
  AND    mfq.query_id = arg_query_id
  and    mfq.number5 = p_item_id
  and    mfq.number6 = p_org_id
  and    mfq.number3 = p_inst_id;

  TYPE bkt_data_rec IS RECORD(
       qty1 column_number,
       qty2 column_number,
       qty3 column_number,
       qty4 column_number,
       qty5 column_number,
       qty6 column_number,
       qty7 column_number,
       qty8 column_number,
       qty9 column_number,
       qty10 column_number,
       qty11 column_number,
       qty12 column_number,
       qty13 column_number,
       qty14 column_number,
       qty15 column_number,
       qty16 column_number,
       qty17 column_number,
       qty18 column_number,
       qty19 column_number,
       qty20 column_number,
       qty21 column_number,
       qty22 column_number,
       qty23 column_number,
       qty24 column_number,
       qty25 column_number,
       qty26 column_number,
       qty27 column_number,
       qty28 column_number,
       qty29 column_number,
       qty30 column_number,
       qty31 column_number,
       qty32 column_number,
       qty33 column_number,
       qty34 column_number,
       qty35 column_number,
       qty36 column_number,
       qty37 column_number,
       qty38 column_number,
       qty39 column_number,
       qty40 column_number,
       qty41 column_number,
       qty42 column_number);

  bkt_data bkt_data_rec;

BEGIN

  -- -------------------------------
  -- Get the item segments, atp flag
  -- -------------------------------
  g_error_stmt := 'Debug - flush_item_plan - 10';
  OPEN check_atp;
  FETCH check_atp INTO atp_flag;
  CLOSE check_atp;

  IF NOT enterprize_view THEN
    -- -----------------------------
    -- Calculate gross requirements,
    -- Total suppy
    -- PAB
    -- POH
    -- -----------------------------

    FOR loop IN 1..g_num_of_buckets LOOP
      ----------------------
      -- Gross requirements.
      -- -------------------
      g_error_stmt := 'Debug - flush_item_plan - 20 - loop'||loop;
      lot_quantity := bucket_cells_tab(((loop - 1) * NUM_OF_TYPES)+
                        EXP_LOT_OFF);
      if lot_quantity > 0 then
         -- bug5223364, expire lot is other independent demand
                add_to_plan(loop,
                OTHER_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + EXP_LOT_OFF));
      end if;

                add_to_plan(loop,
                GROSS_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + FORECAST_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
		bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PROD_FORECAST_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_DEMAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SCRAP_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF));

/* 2994650, no need to apply special logic to re-calculate expired lot in ASCP

      total_reqs := total_reqs +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      FORECAST_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      DEPENDENT_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      PROD_FORECAST_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      PB_DEMAND_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF);

        --------------------
        -- Lot Expirations
        --------------------
        IF(lot_quantity > total_reqs and lot_quantity > 0 ) THEN
                expired_qty := lot_quantity - total_reqs;
                total_reqs := 0;

             add_to_plan(loop,
             GROSS_OFF,
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + FORECAST_OFF) +
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PROD_FORECAST_OFF) +
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_DEMAND_OFF) +
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SCRAP_OFF) +
             bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF) +
             expired_qty);


                add_to_plan(loop,
                OTHER_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF) +
                  expired_qty);
        ELSE

            add_to_plan(loop,
            GROSS_OFF,
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + FORECAST_OFF) +
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PROD_FORECAST_OFF) +
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_DEMAND_OFF) +
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SCRAP_OFF) +
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF));

        END IF;
*/

      g_error_stmt := 'Debug - flush_item_plan - 30 - loop'||loop;
      -- -------------
      -- Total supply.
      -- -------------
      add_to_plan(loop,
                SUPPLY_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + WIP_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PO_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + REQ_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + TRANSIT_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + RECEIVING_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_SUPPLY_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PLANNED_OFF));

              --  bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + RETURNS_OFF));

      -- ----------------------------
      -- Projected available balance.
      -- ----------------------------
      g_error_stmt := 'Debug - flush_item_plan - 40 - loop'||loop;
      -- The first bucket is past due so we include onhand from the second
      -- bucket.
      IF loop = 1 THEN
        add_to_plan(loop,
                PAB_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SUPPLY_OFF)  -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
      ELSE
        add_to_plan(loop,
                PAB_OFF,
                bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + PAB_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SUPPLY_OFF)  -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
      END IF;

      -- ------------------
      -- Projected on hand.
      -- ------------------
      g_error_stmt := 'Debug - flush_item_plan - 50 - loop'||loop;
      -- The first bucket is past due so we include onhand from the second
      -- bucket.
      IF loop = 1 THEN
        add_to_plan(loop,
                POH_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
     -- ELSIF loop = 2 THEN
     ELSE
        add_to_plan(loop,
                POH_OFF,
                bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + POH_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
     /* ELSE
        add_to_plan(loop,
                POH_OFF,
                bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + POH_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));*/
      END IF;

    END LOOP; -- columnd
        ----------------
        -- calculate ATP
        ----------------
    g_error_stmt := 'Debug - flush_item_plan - 60';

    FOR      atp_counter IN 1..g_num_of_buckets LOOP
             add_to_plan(atp_counter, ATP_OFF, 0);
    END LOOP;

    if atp_flag = 1 then -- only calculate atp when atp_flag is 1

       IF  l_atp_qty_net.count = 0 THEN
          l_atp_qty_net.Extend(g_num_of_buckets);
       END IF;

    FOR      atp_counter IN 1..g_num_of_buckets LOOP

             IF atp_counter = 2 THEN
                        total_supply := bucket_cells_tab(((atp_counter - 1)
                                * NUM_OF_TYPES) + SUPPLY_OFF)+
                                bucket_cells_tab(((atp_counter - 1) *
                                NUM_OF_TYPES) + ON_HAND_OFF);
             ELSE
                        total_supply := bucket_cells_tab(((atp_counter - 1)
                                * NUM_OF_TYPES) + SUPPLY_OFF);

             END IF;

             committed_demand := bucket_cells_tab(((atp_counter - 1)
                                * NUM_OF_TYPES) + SALES_OFF) +
                                bucket_cells_tab(((atp_counter - 1) *
                                NUM_OF_TYPES) + DEPENDENT_OFF) +
                                bucket_cells_tab(((atp_counter - 1) *
                                NUM_OF_TYPES) + SCRAP_OFF);


            l_atp_qty_net(atp_counter) := total_supply - committed_demand;

     END LOOP;

     msc_atp_proc.atp_consume(l_atp_qty_net, g_num_of_buckets);

     FOR      atp_counter IN 1..g_num_of_buckets LOOP
              add_to_plan(atp_counter, ATP_OFF, l_atp_qty_net(atp_counter));
     END LOOP;

    END IF;

    FOR a IN 1..g_num_of_buckets LOOP
        bkt_data.qty1(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SALES_OFF);
        bkt_data.qty2(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + FORECAST_OFF);
        bkt_data.qty3(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PROD_FORECAST_OFF);
        bkt_data.qty4(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + DEPENDENT_OFF);
        bkt_data.qty5(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SCRAP_OFF);
        bkt_data.qty6(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PB_DEMAND_OFF);
        bkt_data.qty7(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + OTHER_OFF);
        bkt_data.qty8(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + GROSS_OFF);
        bkt_data.qty9(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + WIP_OFF);
        bkt_data.qty10(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PO_OFF);
        bkt_data.qty11(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + REQ_OFF);
        bkt_data.qty12(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + TRANSIT_OFF);
        bkt_data.qty13(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + RECEIVING_OFF);
        bkt_data.qty14(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PLANNED_OFF);
        bkt_data.qty15(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PB_SUPPLY_OFF);
        bkt_data.qty16(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SUPPLY_OFF);
        bkt_data.qty17(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + ON_HAND_OFF);
        bkt_data.qty18(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PAB_OFF);
        bkt_data.qty19(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SS_OFF);
        bkt_data.qty20(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + ATP_OFF);
        bkt_data.qty21(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + CURRENT_S_OFF);
        bkt_data.qty22(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + POH_OFF);
        bkt_data.qty23(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + EXP_LOT_OFF);
        bkt_data.qty24(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SSUNC_OFF);
        bkt_data.qty25(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + MIN_INV_LVL_OFF);
        bkt_data.qty26(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + MAX_INV_LVL_OFF);
        bkt_data.qty27(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SS_DOS_OFF);
        bkt_data.qty28(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SS_VAL_OFF);
        bkt_data.qty29(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SSUNC_DOS_OFF);
        bkt_data.qty30(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + SSUNC_VAL_OFF);
        bkt_data.qty31(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + USS_OFF);
        bkt_data.qty32(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + USS_DOS_OFF);
        bkt_data.qty33(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + USS_VAL_OFF);
        bkt_data.qty34(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + TARGET_SER_OFF);
        bkt_data.qty35(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + ACHIEVED_SER_OFF);
        bkt_data.qty36(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + NON_POOL_SS_OFF);
        bkt_data.qty37(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + MANF_VARI_OFF);
        bkt_data.qty38(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + PURC_VARI_OFF);
        bkt_data.qty39(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + TRAN_VARI_OFF);
        bkt_data.qty40(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + DMND_VARI_OFF);
        bkt_data.qty41(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + MAD_OFF);
        bkt_data.qty42(a) :=
           bucket_cells_tab(NUM_OF_TYPES * (a - 1) + MAPE_OFF);

    END LOOP;

    FORALL a in 1..nvl(bkt_data.qty1.last,0)
      INSERT INTO msc_material_plans(
        query_id,
        organization_id,
        sr_instance_id,
        plan_id,
        plan_organization_id,
        plan_instance_id,
        inventory_item_id,
        horizontal_plan_type,
        horizontal_plan_type_text,
        bucket_type,
        bucket_date,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        quantity1,   -- SALES_OFF
        quantity2,   -- FORECAST_OFF
        quantity3,   -- PROD_FORECAST
        quantity4,   -- DEPENDENT_OFF
        quantity5,   -- SCRAP_OFF
        quantity6,  -- PB_DEMAND_OFF           CONSTANT INTEGER := 5
        quantity7,  -- OTHER_OFF           CONSTANT INTEGER := 6
        quantity8,  -- GROSS_OFF             CONSTANT INTEGER := 7
        quantity9,  -- WIP_OFF              CONSTANT INTEGER := 8
        quantity10, -- PO_OFF             CONSTANT INTEGER := 9
        quantity11, -- REQ_OFF         CONSTANT INTEGER := 10
        quantity12, -- TRANSIT_OFF       CONSTANT INTEGER := 11
        quantity13, -- RECEIVING_OFF_OFF         CONSTANT INTEGER := 12
        quantity14, -- PLANEED_OFF_OFF       CONSTANT INTEGER := 13
        quantity15, -- PB_SUPPLY_OFF         CONSTANT INTEGER := 14
        quantity16, -- SUPPLY_OFF          CONSTANT INTEGER := 15
        quantity17, -- ON_HAND_OFF         CONSTANT INTEGER := 16
        quantity18, -- PAB_OFF             CONSTANT INTEGER := 17
        quantity19, -- SS_OFF              CONSTANT INTEGER := 18
        quantity20, -- ATP_OFF             CONSTANT INTEGER := 19
        quantity21, -- CURRENT_S_OFF       CONSTANT INTEGER := 20
        quantity22, -- POH_OFF             CONSTANT INTEGER := 21
        quantity23, -- EXP_LOT_OFF         CONSTANT INTEGER := 22
        quantity24, -- SSUNC_OFF           CONSTANT INTEGER := 24
        quantity25, -- min_inv_lvl_off     CONSTANT INTEGER := 25
        quantity26, -- max_inv_lvl_off     CONSTANT INTEGER := 26
        quantity27, -- SS_DOS_OFF          CONSTANT INTEGER := 27
        quantity28, -- SS_VAL_OFF          CONSTANT INTEGER := 28
        quantity29, -- SSUNC_DOS_OFF       CONSTANT INTEGER := 29
        quantity30, -- SSUNC_VAL_OFF       CONSTANT INTEGER := 30
        quantity31, -- USS_OFF             CONSTANT INTEGER := 31
        quantity32, -- USS_DOS_OFF         CONSTANT INTEGER := 32
        quantity33, -- USS_VAL_OFF         CONSTANT INTEGER := 33
        quantity34, -- TAGET_OFF
        quantity35,
        quantity36, --  Non Pool
        quantity37, -- Manf Vari
        quantity38,
        quantity39,
        quantity40,
        quantity41,
        quantity42)
      VALUES (
        arg_query_id,
        p_org_id,
        p_inst_id,
        arg_plan_id,
        arg_plan_organization_id,
        arg_plan_instance_id,
        p_item_id,
        1,
        'HORIZONTAL PLAN',
        arg_bucket_type,
        var_dates(a),
        SYSDATE,
        -1,
        SYSDATE,
        -1,
        bkt_data.qty1(a),
        bkt_data.qty2(a),
        bkt_data.qty3(a),
        bkt_data.qty4(a),
        bkt_data.qty5(a),
        bkt_data.qty6(a),
        bkt_data.qty7(a),
        bkt_data.qty8(a),
        bkt_data.qty9(a),
        bkt_data.qty10(a),
        bkt_data.qty11(a),
        bkt_data.qty12(a),
        bkt_data.qty13(a),
        bkt_data.qty14(a),
        bkt_data.qty15(a),
        bkt_data.qty16(a),
        bkt_data.qty17(a),
        bkt_data.qty18(a),
        bkt_data.qty19(a),
        bkt_data.qty20(a),
        bkt_data.qty21(a),
        bkt_data.qty22(a),
        bkt_data.qty23(a),
        bkt_data.qty24(a),
        bkt_data.qty25(a),
        bkt_data.qty26(a),
        bkt_data.qty27(a),
        bkt_data.qty28(a),
        bkt_data.qty29(a),
        bkt_data.qty30(a),
        bkt_data.qty31(a),
        bkt_data.qty32(a),
        bkt_data.qty33(a),
        bkt_data.qty34(a),
        bkt_data.qty35(a),
        bkt_data.qty36(a),
        bkt_data.qty37(a),
        bkt_data.qty38(a),
        bkt_data.qty39(a),
        bkt_data.qty40(a),
        bkt_data.qty41(a),
        bkt_data.qty42(a));

  END IF; -- not enterprize view

  IF enterprize_view or arg_ep_view_also then -- enterprise view
   ep_bucket_cells_tab(OTHER_OFF) :=
           ep_bucket_cells_tab(OTHER_OFF)+ep_bucket_cells_tab(PB_DEMAND_OFF);
   ep_bucket_cells_tab(GROSS_OFF) :=
           ep_bucket_cells_tab(SALES_OFF)+ep_bucket_cells_tab(FORECAST_OFF)+
           ep_bucket_cells_tab(DEPENDENT_OFF)+ep_bucket_cells_tab(SCRAP_OFF)+
           ep_bucket_cells_tab(PROD_FORECAST_OFF)+ep_bucket_cells_tab(OTHER_OFF);
   ep_bucket_cells_tab(SUPPLY_OFF):=
           ep_bucket_cells_tab(WIP_OFF)+ep_bucket_cells_tab(PO_OFF)+
           ep_bucket_cells_tab(REQ_OFF)+ep_bucket_cells_tab(TRANSIT_OFF)+
           ep_bucket_cells_tab(RECEIVING_OFF)+ep_bucket_cells_tab(PLANNED_OFF)+
           ep_bucket_cells_tab(PB_SUPPLY_OFF);

    INSERT INTO msc_material_plans(
      query_id,
      organization_id,
      sr_instance_id,
      plan_id,
      plan_organization_id,
      plan_instance_id,
      inventory_item_id,
      horizontal_plan_type,
      horizontal_plan_type_text,
      bucket_type,
      bucket_date,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      quantity1,  quantity2,  quantity3,  quantity4,
      quantity5,  quantity6,  quantity7,  quantity8,
      quantity9,  quantity10,     quantity11,     quantity12,
      quantity13,     quantity14,     quantity15,     quantity16,
      quantity17,     quantity18,     quantity19,     quantity20,
      quantity21,     quantity22, quantity23, quantity24, quantity25,
      quantity26,     quantity27,     quantity28,     quantity29,
      quantity30,     quantity31, quantity32, quantity33, quantity34)
    VALUES (
      arg_query_id,
      p_org_id,
      p_inst_id,
      arg_plan_id,
      arg_plan_organization_id,
      arg_plan_instance_id,
      p_item_id,
      10,
      'ENTERPRIZE_VIEW',
      arg_bucket_type,
      sysdate,
      SYSDATE,
      -1,
      SYSDATE,
      -1,
    ep_bucket_cells_tab(0),
    ep_bucket_cells_tab(1),
    ep_bucket_cells_tab(2),
    ep_bucket_cells_tab(3),
    ep_bucket_cells_tab(4),
    ep_bucket_cells_tab(5),
    ep_bucket_cells_tab(6),
    ep_bucket_cells_tab(7),
    ep_bucket_cells_tab(8),
    ep_bucket_cells_tab(9),
    ep_bucket_cells_tab(10),
    ep_bucket_cells_tab(11),
    ep_bucket_cells_tab(12),
    ep_bucket_cells_tab(13),
    ep_bucket_cells_tab(14),
    ep_bucket_cells_tab(15),
    ep_bucket_cells_tab(16),
    ep_bucket_cells_tab(17),
    ep_bucket_cells_tab(18),
    ep_bucket_cells_tab(19),
    ep_bucket_cells_tab(20),
    ep_bucket_cells_tab(21),
    ep_bucket_cells_tab(22),
    ep_bucket_cells_tab(23),
    ep_bucket_cells_tab(24),
    ep_bucket_cells_tab(25),
    ep_bucket_cells_tab(26),
    ep_bucket_cells_tab(27),
    ep_bucket_cells_tab(28),
    ep_bucket_cells_tab(29),
    ep_bucket_cells_tab(30),
    ep_bucket_cells_tab(31),
    ep_bucket_cells_tab(32),
    ep_bucket_cells_tab(33)
);

  END IF;

END flush_item_plan;

-- =============================================================================
BEGIN

  SELECT plan_type into l_plan_type
  FROM	 msc_plans
  WHERE  plan_id = arg_plan_id;

  g_error_stmt := 'Debug - populate_horizontal_plan - 10';
  OPEN plan_buckets;
  FETCH plan_buckets into l_plan_start_date, l_plan_end_date;
  CLOSE plan_buckets;


/*   open  c_first_date(l_plan_start_date); --bug#8726269. l_first_date is used no where and this query causes performance issues.
   fetch c_first_date into l_first_date;
   close c_first_date;
*/
  g_num_of_buckets := (l_plan_end_date + 1) - (l_plan_start_date - 1);

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';
  -- ---------------------------------
  -- Initialize the bucket cells to 0.
  -- ---------------------------------
  IF enterprize_view or arg_ep_view_also THEN
    FOR counter IN 0..NUM_OF_TYPES LOOP
      ep_bucket_cells_tab(counter) := 0;
    END LOOP;
    last_date := arg_cutoff_date;
  END IF;
  IF not (enterprize_view) THEN
    FOR counter IN 0..(NUM_OF_TYPES * g_num_of_buckets) LOOP
      bucket_cells_tab(counter) := 0;
    END LOOP;

    g_error_stmt := 'Debug - populate_horizontal_plan - 30';
    -- --------------------
    -- Get the bucket dates
    -- --------------------
    OPEN bucket_dates(l_plan_start_date-1, l_plan_end_date+1);
    LOOP
      FETCH bucket_dates INTO l_bucket_date;
      EXIT WHEN BUCKET_DATES%NOTFOUND;
      l_bucket_number := l_bucket_number + 1;
      var_dates(l_bucket_number) := l_bucket_date;
--      dbms_output.put_line(l_bucket_number || to_char(l_bucket_date));
    END LOOP;
    CLOSE bucket_dates;

    last_date := arg_cutoff_date;
  END IF;

  g_error_stmt := 'Debug - populate_horizontal_plan - 40';
  bucket_counter := 2;
  old_bucket_counter := 2;
     activity_rec.item_id := 0;
     activity_rec.org_id := 0;
     activity_rec.inst_id := 0;
     activity_rec.row_type := 0;
     activity_rec.offset := 0;
     activity_rec.new_date := sysdate;
     activity_rec.old_date := sysdate;
     activity_rec.new_quantity := 0;
     activity_rec.old_quantity := 0;
     activity_rec.DOS    := 0;
     activity_rec.cost:=0;


  OPEN mrp_snapshot_activity;
  LOOP
        FETCH mrp_snapshot_activity INTO  activity_rec;

/*     if (activity_rec.row_type in (MAD1)) then
        dbms_output.put_line(activity_rec.offset || '**' ||
                            activity_rec.new_date || ' ** ' ||
                            activity_rec.item_id || '**' || activity_rec.org_id || '**' ||
                             activity_rec.new_quantity || '**' || activity_rec.dos || '**' ||
                             activity_rec.cost || '** ' || activity_rec.old_quantity);

       end if;
*/       IF ((mrp_snapshot_activity%NOTFOUND) OR
          (activity_rec.item_id <> last_item_id) OR
          (activity_rec.org_id  <> last_org_id) OR
          (activity_rec.inst_id <> last_inst_id)) AND
         last_item_id <> -1 THEN

        -- --------------------------
        -- Need to flush the plan for
        -- the previous item.
        -- --------------------------
         IF prev_ss_quantity <> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
            add_to_plan(k-1,
                        SS_OFF,
                        prev_ss_quantity);
            add_to_plan(k -1,
                        SS_val_OFF,
                        prev_ss_cost);
            add_to_plan(k -1,
                        SS_dos_OFF,
                        prev_ss_dos);


          IF prev_ssunc_q <> -1 AND
	     NOT enterprize_view THEN

             add_to_plan(k -1 ,
                        SSUNC_OFF,
                        prev_ssunc_q);
             add_to_plan(k -1 ,
                        SSUNC_val_OFF,
                        prev_ssunc_cost);
             add_to_plan(k  -1 ,
                        SSUNC_dos_OFF,
                        prev_ssunc_dos);

         END IF;
        END LOOP;
        END IF;

        IF prev_non_pool_ss <> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
             add_to_plan(k  -1 ,
                        NON_POOL_SS_OFF,
                        prev_non_pool_ss);
          END LOOP;
       END IF;

        IF prev_manf_vari <> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
            add_to_plan(k-1,
                        MANF_VARI_OFF,
                        prev_manf_vari);

            add_to_plan(k-1,
                        PURC_VARI_OFF,
                        prev_purc_vari);
            add_to_plan(k -1,
                        TRAN_VARI_OFF,
                        prev_tran_vari);
            add_to_plan(k -1,
                        DMND_VARI_OFF,
                        prev_dmnd_vari);
          END LOOP;
         END IF;


        IF prev_target_level <> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
            add_to_plan(k-1,
                        TARGET_SER_OFF,
                        prev_target_level);
          END LOOP;
         END IF;

        IF prev_achieved_level <> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
            add_to_plan(k-1,
                        ACHIEVED_SER_OFF,
                        prev_achieved_level);
          END LOOP;
         END IF;


        IF prev_mad <> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP

            add_to_plan(k-1,
                        MAD_OFF,
                        prev_mad);
          END LOOP;
        END IF;

        IF prev_mape <> -1 AND
           NOT enterprize_view THEN


          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP

            add_to_plan(k-1,
                        MAPE_OFF,
                        prev_mape);
          END LOOP;
        END IF;

              IF prev_min <> -1 AND NOT enterprize_view THEN
                 FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
                   add_to_plan(k-1, min_inv_lvl_off, prev_min);
                 END LOOP;
              END IF;


              IF prev_max <> -1 AND NOT enterprize_view THEN
                 FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
                   add_to_plan(k-1, max_inv_lvl_off, prev_max);
                 END LOOP;
              END IF;


        IF prev_uss_q<> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
            add_to_plan(k-1,
                        uSS_OFF,
                        prev_uss_q);
            add_to_plan(k -1,
                        uSS_val_OFF,
                        prev_uss_cost);
            add_to_plan(k -1,
                        uSS_dos_OFF,
                        0);
          END LOOP;
         END IF;

        IF prev_uss_dos<> -1 AND
           NOT enterprize_view THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
            add_to_plan(k-1,
                        uSS_OFF,
                        0);
            add_to_plan(k -1,
                        uSS_val_OFF,
                        0);
            add_to_plan(k -1,
                        uSS_dos_OFF,
                        prev_uss_dos);
          END LOOP;
         END IF;
        flush_item_plan(last_item_id,
                        last_org_id,
                        last_inst_id);

        bucket_counter := 2;
        old_bucket_counter := 2;
        reset_prev_ss;
	prev_ssunc_q := -1;
        ssunc_q := -1;
	prev_ssunc_dos:= -1;
        ssunc_dos := -1;
        uss_q := -1;
        prev_uss_q := -1;
        uss_dos := -1;
        prev_uss_dos := -1;
        ssunc_cost := -1;
        prev_ssunc_cost := -1;
        uss_cost := -1;
        prev_uss_cost := -1;

		prev_non_pool_ss   := -1;
		non_pool_ss        := -1;

		prev_manf_vari     := -1;
		prev_purc_vari   := -1;
		prev_tran_vari   := -1;
		prev_dmnd_vari   := -1;

                prev_target_level := -1;
                prev_achieved_level := -1;
                prev_mad            := -1;
                prev_mape           := -1;
                prev_min            := -1;
                prev_max            := -1;

                target_level := -1;
                achieved_level := -1;
                mad            := -1;
                mape           := -1;
                min_lvl            := -1;
                max_lvl            := -1;


		manf_vari  := -1;
		purc_vari  := -1;
		tran_vari  := -1;
		dmnd_vari  := -1;


        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------
        IF enterprize_view or arg_ep_view_also THEN
          FOR counter IN 0..NUM_OF_TYPES LOOP
            ep_bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
        IF not (enterprize_view) then
          FOR counter IN 0..(NUM_OF_TYPES * g_num_of_buckets) LOOP
            bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
      END IF;  -- end of activity_rec.item_id <> last_item_id

      EXIT WHEN mrp_snapshot_activity%NOTFOUND;

    IF enterprize_view or arg_ep_view_also THEN
      IF activity_rec.row_type IN (WIP, PO, REQ, TRANSIT,
                                   RECEIVING, PB_SUPPLY) THEN
        add_to_plan(CURRENT_S_OFF + 1, 0, activity_rec.old_quantity,true);
      END IF;
      add_to_plan(activity_rec.offset + 1 , 0,
      activity_rec.new_quantity,true);
    END IF;
    IF not(enterprize_view) THEN

      IF activity_rec.row_type = SS THEN

        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------
          init_prev_ss_qty;
        END IF;
      END IF;
      IF activity_rec.row_type = SS_UNC THEN
        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        ssunc_q := activity_rec.new_quantity;
        ssunc_dos := activity_rec.dos;
        ssunc_date := activity_rec.new_date;
        ssunc_cost := activity_rec.cost;
        non_pool_ss := activity_rec.old_quantity;

        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------
          prev_ssunc_q := activity_rec.new_quantity;
          prev_ssunc_dos := activity_rec.dos;
          prev_ssunc_date := activity_rec.new_date;
          prev_ssunc_cost := activity_rec.cost;
          prev_non_pool_ss := activity_rec.old_quantity;
        END IF;
      END IF;

      IF activity_rec.row_type = MANU_VARI THEN
        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        manf_vari := activity_rec.new_quantity;
        purc_vari := activity_rec.old_quantity;
        tran_vari := activity_rec.DOS;
        dmnd_vari := activity_rec.cost;
        vari_date := activity_rec.new_date;

        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------

          prev_manf_vari := activity_rec.new_quantity;
          prev_purc_vari := activity_rec.old_quantity;
          prev_tran_vari := activity_rec.dos;
          prev_dmnd_vari := activity_rec.cost;
          prev_vari_date := activity_rec.new_date;

        END IF;
      END IF;

      IF activity_rec.row_type = MAD1 THEN
        mad  := activity_rec.new_quantity;
        mape := activity_rec.old_quantity;

        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN

          prev_mad   := activity_rec.new_quantity;
          prev_mape  := activity_rec.old_quantity;
        END IF;
      END IF;

      IF activity_rec.row_type = min_inv_lvl THEN
        min_lvl  := activity_rec.new_quantity;
        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
             prev_min   := activity_rec.new_quantity;
        END IF;
      END IF;

      IF activity_rec.row_type = max_inv_lvl THEN
        max_lvl := activity_rec.new_quantity;
        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
             prev_max   := activity_rec.new_quantity;
        END IF;
      END IF;



      IF activity_rec.row_type = TARGET_SER_LVL THEN
        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        target_level := activity_rec.new_quantity;
--        dbms_output.put_line ('  target value ' || target_level );
--        dbms_output.put_line(' bkt counter ' || bucket_counter || 'no of bkts '|| g_num_of_buckets);
--        dbms_output.put_line(' var dates ' || var_dates(bucket_counter));

        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------

          prev_target_level := activity_rec.new_quantity;
        END IF;
      END IF;


      IF activity_rec.row_type = ACHIEVED_SER_LVL THEN
        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        achieved_level := activity_rec.new_quantity;
--        dbms_output.put_line ('  target value ' || achieved_level );
--        dbms_output.put_line(' bkt counter ' || bucket_counter || 'no of bkts '|| g_num_of_buckets);
--        dbms_output.put_line(' var dates ' || var_dates(bucket_counter));

        IF  (bucket_counter <= g_num_of_buckets AND
             activity_rec.new_date < var_dates(bucket_counter)) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------

          prev_achieved_level := activity_rec.new_quantity;
        END IF;
      END IF;


      IF activity_rec.row_type = USS
         and activity_rec.new_quantity is null THEN
        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        uss_dos := activity_rec.dos;
        uss_date := activity_rec.new_date;
        uss_cost := activity_rec.cost;
        uss_q  := -1;

        IF activity_rec.new_date < var_dates(bucket_counter) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------
          prev_uss_dos := activity_rec.dos;
          prev_uss_date := activity_rec.new_date;
          prev_uss_cost:= activity_rec.cost;
          prev_uss_q  := -1;
        END IF;
      END IF;

      IF activity_rec.row_type = USS
         and activity_rec.new_quantity is not null THEN
        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        uss_q := activity_rec.new_quantity;
        uss_date := activity_rec.new_date;
        uss_cost := activity_rec.cost;
        uss_dos := -1;

        IF activity_rec.new_date < var_dates(bucket_counter) THEN
--         dbms_output.put_line('activity_rec.new_date ' ||  activity_rec.new_date ||
--                              ' var_dates(bucket_counter) ' ||  var_dates(bucket_counter) ||
--                              ' bucket counter ' || bucket_counter);
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------
          prev_uss_q := activity_rec.new_quantity;
          prev_uss_date := activity_rec.new_date;
          prev_uss_cost := activity_rec.cost;
          prev_uss_dos := -1;
        END IF;
      END IF;

       IF  (bucket_counter <= g_num_of_buckets AND
            activity_rec.new_date >= var_dates(bucket_counter)) THEN
        -- -------------------------------------------------------
        -- We got an activity falls after the current bucket. So we
        -- will move the bucket counter forward until we find the
        -- bucket where this activity falls.  Note that we should
        -- not advance the counter bejond g_num_of_buckets.
        -- --------------------------------------------------------
--        dbms_output.put_line( 'off ' || activity_rec.offset ||
--                              'num  buckets ' || g_num_of_buckets ||
--                              'var_dates date ' || var_dates(bucket_counter) ||
--                              'activity_rec date ' || activity_rec.new_date);

         WHILE  (bucket_counter <= g_num_of_buckets AND
                 activity_rec.new_date >= var_dates(bucket_counter)) LOOP
--            dbms_output.put_line('in loop - '  || var_dates(bucket_counter));
--          if (bucket_counter > g_num_of_buckets - 50) then
--                      dbms_output.put_line( bucket_counter || ' ' ||
--                            to_char(var_dates(bucket_counter)));
--          end if;
          -- -----------------------------------------------------
          -- If the variable last_ss_quantity is not -1 then there
          -- is a safety stock entry that we need to add for the
          -- current bucket before we move the bucket counter
          -- forward.
          -- -----------------------------------------------------
          IF prev_ss_quantity <> -1   THEN
            add_to_plan(bucket_counter -1,
                        SS_OFF,
                        prev_ss_quantity);
            add_to_plan(bucket_counter -1,
                        SS_val_OFF,
                        prev_ss_cost);
            add_to_plan(bucket_counter -1,
                        ss_dos_off,
                        prev_ss_dos);
          END IF;

          IF prev_ssunc_q <> -1   THEN

            add_to_plan(bucket_counter -1,
                        SSunc_OFF,
                        prev_ssunc_q);
            add_to_plan(bucket_counter  -1,
                        SSunc_val_OFF,
                        prev_ssunc_cost);
            add_to_plan(bucket_counter  -1,
                        ssunc_dos_off,
                        prev_ssunc_dos);
            add_to_plan(bucket_counter  -1,
                        NON_POOL_SS_OFF,
                        prev_non_pool_ss);

          ELSIF prev_non_pool_ss <> -1   THEN
            add_to_plan(bucket_counter  -1,
                        NON_POOL_SS_OFF,
                        prev_non_pool_ss);
          END IF;

          IF prev_uss_q <> -1   THEN

            add_to_plan(bucket_counter -1,
                        uSS_OFF,
                        prev_uss_q);
            add_to_plan(bucket_counter  -1,
                        uSS_val_OFF,
                        prev_uss_cost);
            add_to_plan(bucket_counter  -1,
                        uss_dos_off,
                        0);
          END IF;

        IF prev_mad <> -1 THEN
            add_to_plan(bucket_counter -1,
                        MAD_OFF,
                        prev_mad);
        END IF;

        IF prev_mape <> -1 THEN

            add_to_plan(bucket_counter -1,
                        MAPE_OFF,
                        prev_mape);
        END IF;

               IF prev_min <> -1 THEN
                  add_to_plan(bucket_counter -1, min_inv_lvl_off, prev_min);
               END IF;

               IF prev_max <> -1 THEN
                  add_to_plan(bucket_counter -1, max_inv_lvl_off, prev_max);
               END IF;


        IF prev_target_level <> -1 THEN


            add_to_plan(bucket_counter -1,
                        TARGET_SER_OFF,
                        prev_target_level);
        END IF;

        IF prev_achieved_level <> -1 THEN

            add_to_plan(bucket_counter -1,
                        ACHIEVED_SER_OFF,
                        prev_achieved_level);
        END IF;

        IF prev_manf_vari <> -1 THEN


            add_to_plan(bucket_counter -1,
                        MANF_VARI_OFF,
                        prev_manf_vari);

            add_to_plan(bucket_counter -1,
                        PURC_VARI_OFF,
                        prev_purc_vari);

            add_to_plan(bucket_counter -1,
                        TRAN_VARI_OFF,
                        prev_tran_vari);

            add_to_plan(bucket_counter -1,
                        DMND_VARI_OFF,
                        prev_dmnd_vari);
         END IF;

          IF prev_uss_dos <> -1   THEN

            add_to_plan(bucket_counter -1,
                        uSS_OFF,
                        0);
            add_to_plan(bucket_counter  -1,
                        uSS_val_OFF,
                        0);
            add_to_plan(bucket_counter  -1,
                        uss_dos_off,
                        prev_uss_dos);
          END IF;

          bucket_counter := bucket_counter + 1;

        END LOOP;

        IF activity_rec.row_type = SS then
          init_prev_ss_qty;
        END IF;

        prev_ssunc_q := ssunc_q;
        prev_ssunc_dos := ssunc_dos;
        prev_ssunc_date := ssunc_date;
        prev_uss_q := uss_q;
        prev_uss_dos := uss_dos;
        prev_uss_date := uss_date;
        prev_ssunc_cost := ssunc_cost;
        prev_uss_cost := uss_cost;

        prev_manf_vari := manf_vari;
        prev_purc_vari := purc_vari;
        prev_tran_vari := tran_vari;
        prev_dmnd_vari := dmnd_vari;

        prev_target_level := target_level;
        prev_achieved_level := achieved_level;

        prev_mad := mad;
        prev_mape := mape;

        prev_min := min_lvl;
        prev_max := max_lvl;

        prev_vari_date := vari_date;

      END IF;

      -- ---------------------------------------------------------
      -- Add the retrieved activity to the plan if it falls in the
      -- current bucket and it is not a safety stock entry.
      -- ---------------------------------------------------------

      IF l_plan_type <> SRO_PLAN THEN
       IF  (bucket_counter <= g_num_of_buckets +1 AND -- bug6757932
            activity_rec.new_date < var_dates(bucket_counter)) AND
         ( activity_rec.row_type not in (SS,SS_UNC)) THEN
        add_to_plan(bucket_counter - 1,
            activity_rec.offset,
                    activity_rec.new_quantity);
      END IF;
      ELSE
      IF  (bucket_counter <= g_num_of_buckets AND
           activity_rec.new_date < var_dates(bucket_counter)) THEN
       if (activity_rec.row_type <> USS  and activity_rec.row_type <> SS_UNC and activity_rec.row_type <> SS and
           activity_rec.row_type <> MANU_VARI and activity_rec.row_type <> TARGET_SER_LVL and
           activity_rec.row_type <> ACHIEVED_SER_LVL) then
            add_to_plan(bucket_counter -1,
            activity_rec.offset,
                    activity_rec.new_quantity);
--         elsif activity_rec.row_type = USS then
--             if (activity_rec.new_quantity is null) then
--                   add_to_plan(bucket_counter -1,
--                    uss_dos_off,
--                    activity_rec.dos);
--            else
--                   add_to_plan(bucket_counter -1,
--                    uss_off,
--                    activity_rec.new_quantity);
--                    open standard_cost(
--                        last_item_id,
--                        last_inst_id,
--                        last_org_id,
--                        arg_plan_id);
--                    fetch standard_cost into l_standard_cost;
--                    close standard_cost;
--                    add_to_plan(bucket_counter-1,
--                        USS_val_OFF,
--                        activity_rec.new_quantity*l_standard_cost);
--
--            end if;
         end if;
      END IF;
      END IF;

      -- -------------------------------------
      -- Add to the current schedule receipts.
      -- -------------------------------------
      IF activity_rec.row_type IN (WIP, PO, REQ, TRANSIT,
                                   RECEIVING, PB_SUPPLY) THEN
        WHILE activity_rec.old_date >= var_dates(old_bucket_counter) AND
             old_bucket_counter <= g_num_of_buckets LOOP
          -- ----------
          -- move back.
          -- ----------
          old_bucket_counter := old_bucket_counter + 1;

        END LOOP;

        WHILE activity_rec.old_date < var_dates(old_bucket_counter - 1)  AND
              old_bucket_counter > 2  LOOP
          -- -------------
          -- move forward.
          -- -------------
          old_bucket_counter := old_bucket_counter  - 1;
        END LOOP;
        IF activity_rec.old_date < var_dates(old_bucket_counter) THEN
          add_to_plan(old_bucket_counter - 1,
                      CURRENT_S_OFF,
                      activity_rec.old_quantity);
        END IF;
      END IF;
    END IF;  -- if not enterprise view
    last_item_id := activity_rec.item_id;
    last_org_id := activity_rec.org_id;
    last_inst_id := activity_rec.inst_id;
  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 50';
  CLOSE mrp_snapshot_activity;

  DECLARE
      l_customer_prg varchar2(500);
      l_statement varchar2(1000);

  BEGIN
      l_customer_prg := FND_PROFILE.value('MSC_HP_EXTENSION_PROGRAM');
      if l_customer_prg is not null then
         l_statement :=
             ' begin ' || l_customer_prg|| '(' || arg_query_id || '); end;';
         EXECUTE IMMEDIATE l_statement;
      end if;
  EXCEPTION WHEN others then
      null;
  END ;

EXCEPTION

  WHEN OTHERS THEN
    null;
    --dbms_output.put_line(g_error_stmt);
    raise;

END populate_horizontal_plan;

PROCEDURE query_list(p_agg_hzp NUMBER,
		p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_instance_id NUMBER,
                p_org_list IN VARCHAR2,
                p_pf IN NUMBER, --  this org, all org, from/to org,.....
                p_item_list IN VARCHAR2,
                p_category_set IN NUMBER DEFAULT NULL,
                p_category_name IN VARCHAR2 DEFAULT NULL,
                p_display_pf_details IN BOOLEAN DEFAULT true) IS

  sql_stmt 	VARCHAR2(5000);
  sql_stmt1 	VARCHAR2(5000);
  p_org_id column_number;
  p_inst_id column_number;
  p_item_id column_number;
  p_org_seq column_number;
  a number :=0;
  b number;
  l_len number;
  one_record varchar2(100);
  startPos number;
  endPos number;
  p_all_org_string varchar2(80) :='All Orgs for this Plan';
  p_total_member_string varchar2(80) :='Member Total for ';
  p_node_type number;
  v_cat_name varchar2(200);
  v_org_id number;
  v_org_seq number;
  v_inst_id number;
  v_org_id2 number;
  v_inst_id2 number;
  v_item_id number;
  orig_org_count number;
  v_org_exist boolean :=false;

  v_isProductFamily number :=0;
  cursor isProductFamily is
    select 1
      from msc_system_items
     where plan_id = p_plan_id
       and organization_id = v_org_id
       and sr_instance_id = v_inst_id
       and inventory_item_id = v_item_id
       and bom_item_type in (2,5);

  cursor isProductFamily_no_org is
    select 1
      from msc_system_items
     where plan_id = p_plan_id
       and inventory_item_id = v_item_id
       and bom_item_type in (2,5);

  cursor org_list_c IS
    select mpt.object_type, mpt.source_type, mpt.sequence_id
      from msc_pq_types mpt,
           msc_system_items msi
     where mpt.query_id = p_pf
       and mpt.object_type = msi.organization_id
       and mpt.source_type = msi.sr_instance_id
       and msi.plan_id = p_plan_id
       and msi.inventory_item_id = v_item_id;

  cursor from_to_org_c IS
  select source_organization_id, sr_instance_id2
    from msc_item_sourcing
   where plan_id = p_plan_id
     and organization_id = v_org_id
     and inventory_item_id = v_item_id
     and sr_instance_id = v_inst_id
     and (source_organization_id <> organization_id or
          sr_instance_id2 <> sr_instance_id)
     and source_organization_id <> -1
  union select organization_id, sr_instance_id
    from msc_item_sourcing
   where plan_id = p_plan_id
     and source_organization_id = v_org_id
     and inventory_item_id = v_item_id
     and sr_instance_id2 = v_inst_id
     and (source_organization_id <> organization_id or
         sr_instance_id2 <> sr_instance_id)
     and organization_id <> -1;

   p_item_limit number :=
          nvl(fnd_profile.value('MSC_HP_ITEM_LIMIT'),30);
   p_org_exist boolean;

BEGIN

  if p_org_list is null or p_pf in (-1,0)  then -- show all orgs
     p_org_id(1) :=-1;
     p_inst_id(1) := -1;
     p_org_seq(1) := -1000;
  elsif nvl(p_pf,-3) in (-2,-3) or p_pf > 0  then -- this org or Ship From/To org
     l_len := length(p_org_list);
     WHILE l_len > 0 LOOP
        a := a+1;
        one_record := substr(p_org_list,instr(p_org_list,'(',1,a)+1,
                           instr(p_org_list,')',1,a)-instr(p_org_list,'(',1,a)-1);

        p_inst_id(a) := to_number(substr(one_record,1,instr(one_record,',')-1));
        p_org_id(a) := to_number(substr(one_record,instr(one_record,',')+1));
        p_org_seq(a) :=1;
        l_len := l_len - length(one_record)-3;
  -- dbms_output.put_line(a||',org='||p_org_id(a));
     END LOOP;
  end if; -- p_org_list is null

  a :=1;
  startPos :=1;
  endPos := instr(p_item_list||',', ',',1,a);

  while endPos >0 and a <= p_item_limit loop
           l_len := endPos - startPos;
        p_item_id(a) := to_number(substr(p_item_list||',',startPos, l_len));
        v_item_id := p_item_id(a);
        a := a+1;
        startPos := endPos+1;
        endPos := instr(p_item_list||',', ',',1,a);

        if p_pf is not null and p_pf not in (-1,-2, -3,0) then
          -- get org from org list

            b := nvl(p_org_id.last,0);
            OPEN org_list_c;
            LOOP
               FETCH org_list_c INTO v_org_id, v_inst_id, v_org_seq;
               EXIT WHEN org_list_c%NOTFOUND;
                  b := b+1;
                  p_inst_id(b) := v_inst_id;
                  p_org_id(b) := v_org_id;
                  p_org_seq(b) := v_org_seq;
            END LOOP;
            CLOSE org_list_c;

        end if;
  end loop;

  if p_pf =-2 then -- Ship From/To org
     orig_org_count := p_org_id.count ;
     b := orig_org_count ;
     for a in 1..p_item_id.count loop
        v_item_id := p_item_id(a);
        for c in 1..orig_org_count loop
            v_org_id := p_org_id(c);
            v_inst_id := p_inst_id(c);
            OPEN from_to_org_c;
            LOOP
              FETCH from_to_org_c INTO v_org_id2, v_inst_id2;
              EXIT WHEN from_to_org_c%NOTFOUND;
                 -- 5201957, verify if the org is not already added
                 p_org_exist := false;
                 for c in 1..b loop
                   if p_org_id(c) = v_org_id2 then
                      p_org_exist := true;
                      exit;
                   end if;
                 end loop;
                 if not(p_org_exist) then
                    b := b +1;
                    p_org_id(b) := v_org_id2;
                    p_inst_id(b) := v_inst_id2;
                    p_org_seq(b) :=1;
-- dbms_output.put_line(b||','||p_org_id(b));
                 end if;
            END LOOP;
            CLOSE from_to_org_c;
        end loop; --for b in 1..p_org_id.count loop
     end loop; -- for a in 1..p_item_id.count loop
  end if; -- if p_pf =-2

--  dbms_output.put_line(' before inserting into temp table ');

  sql_stmt1 := 'INSERT INTO msc_form_query ( '||
        'query_id, '||
        'last_update_date, '||
        'last_updated_by, '||
        'creation_date, '||
        'created_by, '||
        'last_update_login, '||
        'number1, '|| -- item_id
        'number2, '|| -- org_id
        'number3, '|| -- inst_id
        'number4, '|| -- plan_id
        'number5, '|| -- displayed item_id
        'number6, '|| -- displayed org_id
        'number7, '|| -- node type
        'number8, '|| -- org sequence
        'char1, '||
        'char2) '||
  ' SELECT DISTINCT :p_query_id, '||
        'sysdate, '||
        '1, '||
        'sysdate, '||
        '1, '||
        '1, '||
        'msi.inventory_item_id, '||
        'msi.organization_id, '||
        'msi.sr_instance_id, '||
        'msi.plan_id, ';

--   dbms_output.put_line( ' org id count ' || p_org_id.count || ' item count ' || p_item_id.count);

  for a in 1..p_org_id.count loop

  for b in 1..p_item_id.count loop
  if p_item_id(b) = -1 then
     -- users select the category nodes
       MSC_ALLOCATION_PLAN.query_list(
                p_query_id, p_plan_id, p_org_id(a), p_inst_id(a),
                p_category_set, p_category_name);
  else
     v_org_id := p_org_id(a);
     v_inst_id := p_inst_id(a);
     v_item_id := p_item_id(b);
     v_org_seq := p_org_seq(a);
 --dbms_output.put_line(a||','||v_org_id||','||v_item_id||','||v_org_seq);
     v_isProductFamily :=0;

  -- verify if item is Product family only if its enabled in the preferences

  if (p_display_pf_details = true) then

     if v_org_id = -1 then
       OPEN isProductFamily_no_org;
       FETCH isProductFamily_no_org into v_isProductFamily;
       CLOSE isProductFamily_no_org;
     else
       OPEN isProductFamily;
       FETCH isProductFamily into v_isProductFamily;
       CLOSE isProductFamily;
     end if;
  else

     v_isProductFamily := 0;
  end if;

--    dbms_output.put_line( ' is pf ' || v_isProductFamily );

     if v_isProductFamily = 1 then
        p_node_type := NODE_REGULAR_ITEM;
        -- insert the member of the product family
        sql_stmt := sql_stmt1 ||
        '-1*msi.product_family_id, '||
        'DECODE( :p_org_id,-1,-1,msi.organization_id), '||
        ' :NODE_REGULAR_ITEM, '||
        ' :org_seq, '||
        'DECODE( :p_org_id,-1,:p_all_org_string ,msi.organization_code), '||
        ':p_total_member_string || msc_get_name.item_name(msi.product_family_id,null,null,null) '||
  ' FROM msc_items_tree_v msi' ||
  ' WHERE msi.category_set_id = :p_category_set ' ||
    ' AND msi.product_family_id = :p_item_list ' ||
    ' AND msi.plan_id = :p_plan_id';

   if p_org_id(a) <> -1 then
     sql_stmt := sql_stmt ||
        ' and msi.sr_instance_id = :p_inst_id '||
        ' and msi.organization_id = :p_org_list ';
   else  -- item across all orgs
     sql_stmt := sql_stmt ||
        ' and -1 = :p_inst_id '||
        ' and -1 = :p_org_list ';
   end if;

   if p_category_name is not null then
     sql_stmt := sql_stmt ||
        ' and msi.category_name = :p_category_name ';
     -- need to add category_name to msc_items_tree_v
        v_cat_name := p_category_name;
   else
     sql_stmt := sql_stmt ||
        ' and -1 = :p_category_name ';
        v_cat_name := '-1';
   end if;


   EXECUTE IMMEDIATE sql_stmt using p_query_id,v_org_id,p_node_type,
                       v_org_seq, v_org_id,
                       p_all_org_string, p_total_member_string,
                       p_category_set, v_item_id,p_plan_id,
                       v_inst_id,v_org_id,v_cat_name;

end if; -- v_isProductFamily = 1 then

      if v_isProductFamily = 1 then
         p_node_type := NODE_PF_ITEM;
      else
         p_node_type := NODE_REGULAR_ITEM;
      end if;

if v_org_id = -1 then -- across all orgs
   if p_category_name is not null then
     sql_stmt := sql_stmt1 ||
        'msi.inventory_item_id,'||
        '-1, '||
        ' :NODE_REGULAR_ITEM, ' ||
        ' :org_seq, '||
        ' :p_all_org_string,'||
        'msi.item_name '||
  ' FROM msc_system_items msi, msc_item_categories mic' ||
  ' WHERE mic.organization_id = msi.organization_id ' ||
        'AND     mic.sr_instance_id = msi.sr_instance_id ' ||
        'AND     mic.inventory_item_id = msi.inventory_item_id ' ||
        'AND     mic.category_set_id = :p_category_set '||
        'AND     mic.category_name = :p_category_name '||
        'AND     msi.inventory_item_id = :p_item_list ' ||
        'AND     msi.plan_id = :p_plan_id ';

   EXECUTE IMMEDIATE sql_stmt using p_query_id,p_node_type, v_org_seq,
                       p_all_org_string,
                       p_category_set, p_category_name,
                       v_item_id,p_plan_id;
   else  -- p_category_name is null
     sql_stmt := sql_stmt1 ||
        'msi.inventory_item_id,'||
        '-1, '||
        ' :NODE_REGULAR_ITEM, ' ||
        ' :org_seq, '||
        ' :p_all_org_string,'||
        ' msi.item_name '||
        ' FROM msc_system_items msi ' ||
        ' where msi.inventory_item_id = :p_item_list ' ||
        ' AND msi.organization_id <> -1 '||
        ' AND msi.plan_id = :p_plan_id ';

   EXECUTE IMMEDIATE sql_stmt using p_query_id,p_node_type, v_org_seq,
                       p_all_org_string,
                       v_item_id,p_plan_id;
   end if; -- end p_category_name is not null
else -- regular item
      sql_stmt := sql_stmt1 ||
        'msi.inventory_item_id, '||
        'msi.organization_id, '||
        ':NODE_REGULAR_ITEM, ' ||
        ' :org_seq, '||
        'msc_get_name.org_code(msi.organization_id,msi.sr_instance_id), '||
        'msi.item_name '||
    ' FROM msc_system_items msi ' ||
    ' where msi.sr_instance_id = :p_inst_id '||
        'and msi.organization_id = :p_org_list ' ||
        'AND msi.inventory_item_id = :p_item_list ' ||
        'AND msi.plan_id = :p_plan_id ';
/*
dbms_output.put_line('insert for org='||p_query_id||','||p_node_type||','||
                       v_inst_id||','|| v_org_id||','||
                       v_item_id||','||p_plan_id);
*/
   EXECUTE IMMEDIATE sql_stmt using p_query_id,p_node_type, v_org_seq,
                       v_inst_id, v_org_id,
                       v_item_id,p_plan_id;

   if p_pf = -2 or p_pf > 0 then
-- From/To org,org list should show summary row

      sql_stmt := sql_stmt1 ||
        'msi.inventory_item_id, '||
        '-1, '||
        ':NODE_REGULAR_ITEM, ' ||
        ' :org_seq, '||
        ':p_all_org_string, '||
        'msi.item_name '||
    ' FROM msc_system_items msi ' ||
    ' where msi.sr_instance_id = :p_inst_id '||
        'and msi.organization_id = :p_org_list ' ||
        'AND msi.inventory_item_id = :p_item_list ' ||
        'AND msi.plan_id = :p_plan_id ';

      EXECUTE IMMEDIATE sql_stmt using p_query_id,p_node_type,-1000,
                       p_all_org_string, v_inst_id, v_org_id,
                       v_item_id,p_plan_id;

   end if; -- if p_pf = -2 then
end if; -- if v_org_id = -1 then

if v_org_id = -1 and -- across all orgs
    p_agg_hzp =2 then  -- need to show each org
   v_org_seq := 1; -- should be shown after all org
   if p_category_name is not null then
     sql_stmt := sql_stmt1 ||
        'msi.inventory_item_id,'||
        'msi.organization_id, '||
        ' :NODE_REGULAR_ITEM, ' ||
        ' :org_seq, '||
        'msc_get_name.org_code(msi.organization_id,msi.sr_instance_id),'||
        'msi.item_name '||
  ' FROM msc_system_items msi, msc_item_categories mic' ||
  ' WHERE mic.organization_id = msi.organization_id ' ||
        'AND     mic.sr_instance_id = msi.sr_instance_id ' ||
        'AND     mic.inventory_item_id = msi.inventory_item_id ' ||
        'AND     mic.category_set_id = :p_category_set '||
        'AND     mic.category_name = :p_category_name '||
        'AND     msi.inventory_item_id = :p_item_list ' ||
        'AND     msi.plan_id = :p_plan_id ';

   EXECUTE IMMEDIATE sql_stmt using p_query_id,p_node_type, v_org_seq,
                       p_category_set, p_category_name,
                       v_item_id,p_plan_id;
   else  -- p_category_name is null
     sql_stmt := sql_stmt1 ||
        'msi.inventory_item_id,'||
        'msi.organization_id, '||
        ' :NODE_REGULAR_ITEM, ' ||
        ' :org_seq, '||
        ' msc_get_name.org_code(msi.organization_id,msi.sr_instance_id),'||
        ' msi.item_name '||
        ' FROM msc_system_items msi ' ||
        ' where msi.inventory_item_id = :p_item_list ' ||
        ' AND msi.organization_id <> -1 '||
        ' AND msi.plan_id = :p_plan_id ';

   EXECUTE IMMEDIATE sql_stmt using p_query_id,p_node_type,v_org_seq,
                       v_item_id,p_plan_id;
   end if; -- end p_category_name is not null
end if; -- v_org_id = -1 and p_agg_hzp =2 then
end if; -- if p_item_id(b) = -1 then
end loop; -- p_item_id.count
end loop; -- p_org_id.count
END query_list;

PROCEDURE get_detail_records(p_node_type IN NUMBER,
		p_plan_id IN NUMBER,
                p_org_id IN NUMBER,
                p_inst_id IN NUMBER,
                p_item_id IN NUMBER,
                p_supplier_id IN NUMBER,
                p_supplier_site_id IN NUMBER,
                p_dept_id IN NUMBER,
                p_res_id IN NUMBER,
                p_start_date IN DATE,
                p_end_date IN DATE,
                p_rowtype IN NUMBER,
                p_item_query_id IN NUMBER,
                x_trans_list OUT NOCOPY VARCHAR2,
                x_error OUT NOCOPY NUMBER,
                x_err_message OUT NOCOPY VARCHAR2,
                p_plan_type IN NUMBER DEFAULT 2,
                p_consumed_row_filter   IN VARCHAR2 DEFAULT NULL,
                p_res_instance_id IN NUMBER DEFAULT 0,
                p_serial_number IN VARCHAR2 DEFAULT NULL) IS

  l_query_id	NUMBER;

  sql_stmt	VARCHAR2(5000);
  sql_stmt_1    varchar2(32000);
  sql_stmt_2    varchar2(32000);
  l_count NUMBER := 1;
  l_trans_id	NUMBER;

  l_isDrp boolean := false;
  l_isHp boolean := false;

  l_filter varchar2(255);

  CURSOR TRANS_C IS
  SELECT number1
  FROM msc_form_query
  WHERE query_id = l_query_id;

  CURSOR plan_start_c IS
  SELECT curr_start_date,
         curr_plan_type,
         decode(daily_material_constraints,1, 1, 0) +
         decode(daily_resource_constraints,1, 1, 0) +
         decode(weekly_material_constraints,1, 1, 0) +
         decode(weekly_resource_constraints,1, 1, 0) +
         decode(period_material_constraints,1, 1, 0) +
         decode(period_resource_constraints,1, 1, 0),
     decode(enforce_sup_cap_constraints,1,1,0),
     decode(daily_material_constraints,1, 1, 0) --ascp_supplier_constraints
  FROM   msc_plans
  WHERE  plan_id = p_plan_id;

  l_plan_start_date date;
  l_plan_type number;
  l_optimized_plan number;
  l_dock_date_prof    number := nvl(FND_PROFILE.Value('MSC_PO_DOCK_DATE_CALC_PREF'),1);

  cursor item_record is
       select distinct number2,number1
       from msc_form_query
       where query_id = p_item_query_id
         and number5 = p_item_id
         and number6 = p_org_id
         and number3 = p_inst_id ;
  v_org_id number;
  v_item_id number;

    cursor item_supplier_record is
       select distinct number1,number8
       from msc_form_query
       where query_id = p_item_query_id;


  req_item_id       NUMBER;
  capacity_item_id  NUMBER;
  i                 NUMBER := 1;
  p_sub_org_id number;

  l_constraints number:=0;
  l_enforce_sup_cap_constraints number:=0;
  l_date varchar2(100);
BEGIN

  x_error := 0;

  if p_plan_type = 5 then
     l_isDrp := true;
  else
     l_isHp := true;
  end if;


  SELECT msc_form_query_s.nextval
  INTO l_query_id
  FROM dual;

--< bug5449978--if plan is drp or unconstrained ascp or any plan where enforce_supplier capacity constraints is off, fallback to msc_supplies
  OPEN plan_start_c;
  FETCH plan_start_c INTO l_plan_start_date, l_plan_type, l_optimized_plan, l_enforce_sup_cap_constraints, l_constraints;
  CLOSE plan_start_c;

--if plan is drp or unconstrained ascp or any plan where enforce_supplier capacity constraints is off, fallback to msc_supplies
--BUG5609299--modified previous fix so that we use msc_supplies for unconstrained DRP or unconstrained ASCP plans.
    if (l_plan_type=5 ) or (l_plan_type=1 and l_constraints=0) then
        g_use_sup_req:=0; -- do not use msc_supplier_requirements
    else
        g_use_sup_req:=1; -- use msc_supplier_requirements
    end if;
--bug5449978, />

  IF l_optimized_plan >= 1 and l_plan_type <> 4 then
     l_optimized_plan := 1;
  ELSE
     l_optimized_plan := 0;
  END IF;
      sql_stmt := 'INSERT INTO msc_form_query ( '||
        'query_id, '||
        'last_update_date, '||
        'last_updated_by, '||
        'creation_date, '||
        'created_by, '||
        'last_update_login, '||
        'number1) ' ||
	'SELECT distinct :l_query_id,' ||
	' sysdate, '||
	' 1, '||
	' sysdate, '||
	' 1, '||
	' 1, ';

  IF p_node_type in (NODE_LINE,NODE_DEPT_RES,NODE_TRANS_RES) THEN

     IF l_optimized_plan =1 and
        p_node_type in (NODE_LINE,NODE_DEPT_RES) THEN
      -- 4202010, only show res req which really has res req
      sql_stmt := sql_stmt ||
	' mrr2.transaction_id '||
        ' FROM msc_resource_requirements mrr, ' ||
              'msc_resource_requirements mrr2 ' ||
        ' where ((trunc(decode(mrr.parent_id, null, mrr.end_date, mrr.start_date)) BETWEEN '||
                ':p_start_date AND :p_end_date) or '||
	      '(trunc(decode(mrr.parent_id, null, mrr.end_date, mrr.start_date)) <= ' ||
                              ' :p_end_date AND '||
	       'trunc(mrr.end_date) >= ' ||
                              ' :p_start_date )) '||
           ' and mrr.plan_id = :p_plan_id' ||
           ' AND mrr.organization_id = :p_org_id'||
           ' AND mrr.sr_instance_id = :p_inst_id' ||
           ' and mrr.department_id= :p_dept_id' ||
           ' and mrr.resource_id = :p_res_id' ||
           ' and nvl(mrr.parent_id,1) =1 '|| -- ATP req without parent id
           ' and mrr2.organization_id =mrr.organization_id '||
           ' and mrr2.sr_instance_id = mrr.sr_instance_id '||
           ' and mrr2.department_id = mrr.department_id '||
           ' and mrr2.resource_id = mrr.resource_id '||
           ' and mrr2.plan_id = mrr.plan_id '||
           ' and nvl(mrr2.parent_id,2) = 2 ' ||
           ' and mrr2.supply_id = mrr.supply_id '||
           ' and mrr2.operation_seq_num = mrr.operation_seq_num '||
           ' and mrr2.resource_seq_num = mrr.resource_seq_num ';

       -- To display only Setup time

               IF p_rowtype = 520 then
                  sql_stmt :=  sql_stmt || ' and mrr2.schedule_flag = 3 ';

               ELSIF p_rowtype = 540 then
                  sql_stmt :=  sql_stmt || ' and mrr2.schedule_flag = 1 ';
               END IF;

     ELSE

      sql_stmt := sql_stmt ||
	' transaction_id '||
        ' FROM msc_resource_requirements_v ' ||
        ' where ((trunc(resource_date) BETWEEN '||
                ':p_start_date AND :p_end_date) or '||
	      '(trunc(resource_date) <='||
	        ':p_end_date AND trunc(resource_end_date) >= :p_start_date ))';

    sql_stmt := sql_stmt ||
        ' and plan_id = :p_plan_id' ||
        ' AND organization_id = :p_org_id'||
        ' AND sr_instance_id = :p_inst_id' ||
        ' and department_id= :p_dept_id' ||
        ' and resource_id = :p_res_id';
     END IF;


    EXECUTE IMMEDIATE sql_stmt using l_query_id,p_start_date,p_end_date,
                                      p_end_date, p_start_date,p_plan_id,
                                      p_org_id,p_inst_id,
                                      p_dept_id, p_res_id;

  ELSIF p_node_type = NODE_RES_INSTANCE THEN

      sql_stmt := sql_stmt ||
        ' transaction_id '||
        ' FROM msc_resource_requirements_v ' ||
        ' where ((trunc(resource_date) BETWEEN '||
                ':p_start_date AND :p_end_date) or '||
              '(trunc(resource_date) <='||
                ':p_end_date AND trunc(resource_end_date) >= :p_start_date ))';

       -- To display only Setup time

               IF p_rowtype = 520 then
                  sql_stmt :=  sql_stmt || ' and schedule_type = 3 ';

               ELSIF p_rowtype = 540 then
                  sql_stmt :=  sql_stmt || ' and schedule_type = 1 ';
               END IF;

    sql_stmt := sql_stmt ||
        ' and plan_id = :p_plan_id' ||
        ' AND organization_id = :p_org_id'||
        ' AND sr_instance_id = :p_inst_id' ||
        ' and department_id= :p_dept_id' ||
        ' and resource_id = :p_res_id' ||
        ' and res_instance_id = :p_res_inst_id' ||
        ' and serial_number = :p_serial_number' ;

    EXECUTE IMMEDIATE sql_stmt using l_query_id,p_start_date,p_end_date,
                                      p_end_date, p_start_date,p_plan_id,
                                      p_org_id,p_inst_id,
                                      p_dept_id, p_res_id, p_res_instance_id, p_serial_number;


  ELSIF p_node_type = NODE_ITEM_SUPPLIER THEN

  -- for capacity statement we always has
  -- to check the ASL of ATO model

  -- if a user selects a standard item then
  -- capacity_item_id  will contain the standard item
  -- and req_item_id  will contain the standard item
  -- else if  a user selects a model / config item
  -- capacity_item_id will contain the base model
  -- req_item_id will contain all the configs and  model to
  -- query requirements.

    OPEN item_supplier_record;
    LOOP
    FETCH  item_supplier_record INTO req_item_id, capacity_item_id;
    EXIT when item_supplier_record%NOTFOUND;

     IF p_rowtype in (5,6,7) THEN
       IF i = 1 THEN  -- capacity is queried for one the base item only

      sql_stmt := sql_stmt ||
	' transaction_id '||
        ' FROM msc_supplier_capacity_v '||
        ' WHERE plan_id = :p_plan_id' ||
    --    ' AND organization_id = :p_org_id'||
    --    ' AND sr_instance_id = :p_inst_id'||
        ' and supplier_id = :p_supplier_id' ||
        ' and inventory_item_id = :capacity_item_id' ||
        ' and ((trunc(from_date) BETWEEN '||
                ':p_start_date AND :p_end_date) or '||
	      '(trunc(from_date) <='||
	        ':p_end_date AND trunc(to_date) >= :p_start_date ))';

        if nvl(p_supplier_site_id,-1) <> -1 then
           sql_stmt := sql_stmt ||
                ' and supplier_site_id = :p_supplier_site_id';
        else
           sql_stmt := sql_stmt ||
                ' and -1 = :p_supplier_site_id';
        end if;

    EXECUTE IMMEDIATE sql_stmt using l_query_id, p_plan_id,
                                      --p_org_id,p_inst_id,
                                      p_supplier_id,capacity_item_id,
                                      p_start_date,p_end_date,
                                      p_end_date, p_start_date,
                                      nvl(p_supplier_site_id,-1);
  END IF;  --  only  construct  sql for capacity first time through cursor
    ELSE -- supplier requirements

    if g_use_sup_req=0 then
        l_date := ' trunc(ms.new_dock_date) ';-- use msc_supplies
    else
        l_date := ' trunc(mr.consumption_date) ';-- use msc_supplier_requirements
    end if;

      sql_stmt_2 := sql_stmt ||
	' ms.transaction_id '||
        ' FROM msc_supplies ms,'||
             ' msc_supplier_requirements mr '||
        ' WHERE ms.plan_id = :p_plan_id' ||
        ' AND ms.inventory_item_id = :req_item_id' ||
        ' and nvl(ms.source_supplier_id,ms.supplier_id )= :p_supplier_id'||
        ' and ms.plan_id = mr.plan_id(+) '||
        ' and ms.sr_instance_id = mr.sr_instance_id(+) '||
        ' and ms.transaction_id = mr.supply_id(+) '||
        ' and ((' || l_date || ' BETWEEN '||
                ':p_start_date AND :p_end_date) or '||
         ' ( ' || l_date || ' <='||
	        ':p_end_date AND trunc(last_unit_completion_date) >= :p_start_date ))';

        -- bug 2775228
        IF p_rowtype = 1 THEN -- purchase orders
          sql_stmt_2 := sql_stmt_2||' AND ms.order_type = 1 ';
        ELSIF p_rowtype = 2 THEN -- requisitions
          sql_stmt_2 := sql_stmt_2||' AND ms.order_type = 2 ';
        ELSIF p_rowtype = 3 THEN -- planned orders
          sql_stmt_2 := sql_stmt_2||' AND ms.order_type = 5 ';
        ELSIF p_rowtype = 4 THEN -- Required hours
          IF l_dock_date_prof = 1 THEN -- promise_date
             sql_stmt_2 := sql_stmt_2||
                                   ' AND ms.order_type in (1,2,5) '||
                                   ' AND DECODE (ms.order_type, '||
                                   '          1, ms.promised_date) is NULL ' ;
          ELSIF l_dock_date_prof = 2 THEN -- need_by_date
             sql_stmt_2 := sql_stmt_2||
                                   ' AND ms.order_type in (2,5) ';
          END IF;
        END IF;

        if p_supplier_site_id is not null then
           sql_stmt_2 := sql_stmt_2 ||
                 ' AND nvl(ms.source_supplier_site_id,
                              ms.supplier_site_id) = :p_supplier_site_id ';
        else
           sql_stmt_2 := sql_stmt_2 ||
                 ' AND -1 = :p_supplier_site_id ';
        end if;


EXECUTE IMMEDIATE sql_stmt_2 using l_query_id, p_plan_id,
                                   req_item_id,p_supplier_id,
                                   p_start_date,p_end_date,
                                   p_end_date, p_start_date,
                                   nvl(p_supplier_site_id,-1);


 sql_stmt_2 := sql_stmt;
 END IF;

 i := i + 1;

 END LOOP;
 CLOSE item_supplier_record;


 ELSE -- an item
       -- need to get the real item_id, org_id from msc_form_query

   sql_stmt_1 := sql_stmt;

   open item_record;
   loop
      fetch item_record into v_org_id, v_item_id;
      exit when item_record%NOTFOUND;

     if p_node_type = NODE_GL_FORECAST_ITEM  THEN
          MSC_GLOBAL_FORECASTING.get_detail_records(
                l_query_id ,
                p_node_type ,
		p_plan_id ,
                v_org_id ,
                p_inst_id ,
                v_item_id ,
                p_rowtype ,
                p_supplier_id, -- store p_ship_level ,
                p_consumed_row_filter , -- store p_ship_id ,
                p_start_date ,
                p_end_date );

     else -- regular item
        sql_stmt := '';
        sql_stmt := sql_stmt_1 ||
	' transaction_id '||
        ' FROM '||msc_get_name.get_order_view(p_plan_type, p_plan_id) ||
        ' WHERE plan_id = :p_plan_id' ||
        ' AND organization_id = :p_org_id'||
        ' AND sr_instance_id = :p_inst_id'||
        ' and inventory_item_id = :p_item_id';

    IF l_isDrp = true AND p_rowtype in (50,80,220,380) AND p_dept_id is not null then
       p_sub_org_id := p_dept_id;

       IF p_rowtype in (50,80) then
-- outbound shipment/requested outbound shipment
        sql_stmt := sql_stmt ||
                    ' AND dest_org_id = :p_sub_org_id';
       ELSIF p_rowtype in (220,380) then
-- inbound shipment/requested inbound shipment
        sql_stmt := sql_stmt ||
                    ' AND source_organization_id = :p_sub_org_id';
       END IF;

    ELSE -- IF l_isDrp = true
       p_sub_org_id := -1;
       sql_stmt := sql_stmt || ' and -1 = :p_sub_org_id';
    END IF;

    IF ((l_isHp = true AND p_rowtype = 140 ) OR   -- Current scheduled receipts
        (l_isDrp = true AND p_rowtype = 270)) THEN

      IF trunc(p_start_date) = trunc(l_plan_start_date) THEN
        sql_stmt := sql_stmt || ' AND trunc(old_due_date) <= '''||p_end_date|| '''';
      ELSE
        sql_stmt := sql_stmt || ' AND trunc(old_due_date) BETWEEN '''||
            p_start_date||''' AND '''|| p_end_date|| '''';
      END IF;
    ELSIF ((l_isHp = true AND p_rowtype in (110,150)) OR   -- POH, PAB
           (l_isDrp = true AND p_rowtype in (280,290,300))) THEN -- POH,PAB,UNC_PAB

      sql_stmt := sql_stmt || ' AND trunc(nvl(firm_date,new_due_date)) <= '''||
        p_end_date|| '''';

    ELSE

      sql_stmt := sql_stmt ||
        ' AND ((trunc(nvl(firm_date,new_due_date)) BETWEEN '''||
               p_start_date||''' AND '''|| p_end_date||
        ''') OR (trunc(nvl(firm_date,new_due_date)) <='''||
        p_end_date|| ''' AND trunc(last_unit_completion_date) >= '''||
        p_start_date||'''))';
    END IF;

    IF((l_isHp = true  AND p_rowtype in (10,230)) OR                            -- Sales orders
       (l_isDrp = true AND p_rowtype = 20)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (6,30) ';
    ELSIF ((l_isHp = true AND p_rowtype in (20,210,270,290,300)) OR   -- Forecast, MAD
           (l_isDrp = true AND p_rowtype = 30)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (7,29)';
    ELSIF (l_isHp = true AND p_rowtype = 30) THEN                          -- Dependent demand
      sql_stmt := sql_stmt ||
                ' AND source_table = ''MSC_DEMANDS'''||
                ' AND order_type in (1,2,3,4,22,24,25) ';
    ELSIF (l_isHp = true AND p_rowtype = 40) THEN                         -- Expected scrap
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (16,17,18,19,20,21,23,26) ';

    ELSIF (l_isHp = true AND p_rowtype = 45) THEN                          -- Payback Demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type = 27 ';
    ELSIF (l_isHp = true AND p_rowtype = 50)  THEN -- Other independent demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (5,8,9,10,11,12,15) ';
    ELSIF (l_isDRP = true AND p_rowtype = 60)  THEN -- Other demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (5,8,9,10,11,12,15,16,17,18,19,20,23) ';
    ELSIF (p_rowtype = 70) THEN                        --Gross requirements
      sql_stmt := sql_stmt ||
                ' AND source_table = ''MSC_DEMANDS''';
      if l_isDrp then -- not include unconstr kit demand/request shipment
         sql_stmt := sql_stmt ||
                ' AND order_type not in (48,49) ';
      end if;
    ELSIF (l_isHp = true AND p_rowtype = 160) or
          (l_isDRP = true AND p_rowtype = 370) THEN -- expired lot
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type =5 ';
    ELSIF ((l_isHp = true AND p_rowtype = 81) OR                         -- WIP
           (l_isDrp = true AND p_rowtype = 140)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (3,7,14,15,27,28) ';
    ELSIF p_rowtype = 82 THEN -- Flow schedule
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 28 ';
    ELSIF ((l_isHp = true AND p_rowtype = 83) OR                       -- Purchase Orders
           (l_isDrp = true AND p_rowtype = 190)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 1 ';

    ELSIF ((l_isHp = true AND p_rowtype = 85) OR                      -- Requisitions
           (l_isDrp = true AND p_rowtype = 240)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (2,53) ';
    ELSIF ((l_isHp = true AND p_rowtype = 87) OR                      -- In Transit
           (l_isDrp = true AND p_rowtype = 230)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 11 ';
    ELSIF ((l_isHp = true AND p_rowtype = 89) OR                      -- In Receiving
           (l_isDrp = true AND p_rowtype = 150)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (8,12) ';

    ELSIF ((l_isHp = true AND p_rowtype = 90) OR
-- Planned Orders: include planned arrival
           (l_isDrp = true AND p_rowtype = 250)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (5,17,51,13) ';
    ELSIF p_rowtype = 95 THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 29 ';
    ELSIF p_rowtype = 97 THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 32 ';

    ELSIF ((l_isHp = true AND p_rowtype = 100) OR
-- Total Supply: should not include request arrival
           (l_isDrp = true AND p_rowtype = 260)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (1,2,3,5,7,8,11,12,13,14,15,17,27,28,29,32,49,51,53) ';
    ELSIF ((l_isHp = true AND p_rowtype = 105) OR                   --  Beginning on Hand
           (l_isDrp = true AND p_rowtype = 130)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 18 ';
    ELSIF ((l_isHp = true AND p_rowtype = 140) OR                  -- Current Schdld Receipts
           (l_isDrp = true AND p_rowtype = 270)) THEN
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (1,2,3,7,8,11,12,14,15,27,28,29) ';

--                  ---------------------------
--                  New Row Types added for DRP
--                  ---------------------------

     ELSIF (l_isDrp = true AND p_rowtype = 10) THEN                -- External Demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (6,7,29,30) ';
     ELSIF (l_isDrp = true AND p_rowtype = 40) THEN
-- Kit Demand = constrained kit demand + discrete job demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (3,47) ';
     ELSIF (l_isDrp = true AND p_rowtype = 90) THEN
-- UnConstnd. Kit Demand = discrete job dmd + unconst. kit dmd
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (3,48)  ';

     ELSIF (l_isDrp = true AND p_rowtype = 100) THEN
-- UnConstnd. Other Demand: scrap dmd + interorg demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (16,17,18,19,20,23,24) ';
     ELSIF (l_isDrp = true AND p_rowtype = 110) THEN
-- UnConstnd. Total Demand= ext SO +FC + req shipment + unc kit +unc other dmd
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (30,29,49,3,48,16,17,18,19,20,23) ';

     ELSIF (l_isDrp = true AND p_rowtype = 120) THEN                    -- Internal Supply
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (3,5,7,8,12,18) ';
     ELSIF (l_isDrp = true AND p_rowtype = 160) THEN                    -- Planned Make
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 5 ';
     ELSIF (l_isDrp = true AND p_rowtype = 170) THEN                    -- Ext Supply
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (1,2) ';

     ELSIF (l_isDrp = true AND p_rowtype = 220) THEN
-- Arrivals := planned inbound shipment + IR
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type in (51,53) ';
     ELSIF (l_isDrp = true AND p_rowtype = 380) THEN                    -- Req. Arrivals
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_SUPPLIES''' ||
                ' AND order_type = 52 ';
     ELSIF (l_isDrp = true AND p_rowtype = 80) THEN
 -- Requested Shipments
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type  = 49 ';
     ELSIF (l_isDrp = true AND p_rowtype = 50) THEN
--    Shipments = planned outbound shipment + ISO
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (53,54) ';
     ELSIF l_isDrp = true AND p_rowtype in (280, 290, 300 ) then -- poh, pab
        if p_rowtype = 280 then -- POH
           sql_stmt := sql_stmt || ' AND ((source_table = ''MSC_SUPPLIES'''||
              ' AND order_type in (1,2,3,7,8,11,12,14,15,17,18,27,28,32,49,53)) ';
        else
           sql_stmt := sql_stmt || ' AND ((source_table = ''MSC_SUPPLIES'''||
              ' AND order_type in (1,2,3,5,7,8,11,12,14,15,17,18,27,28,29,32,49,51,53)) ';
        end if;
           sql_stmt := sql_stmt ||
                     ' OR (source_table = ''MSC_DEMANDS'' AND ';
         if p_rowtype in (280, 290) then -- poh, pab
        -- show const. total demand, not include unc kit dmd/request shipment
            sql_stmt := sql_stmt ||
                      ' order_type not in (48,49) )) ';
         elsif p_rowtype = 300 then -- unc pab
        -- show unc. total demand
            sql_stmt := sql_stmt ||
                     ' order_type in (30,29,49,3,48,16,17,18,19,20,23) )) ';
         end if;


     ELSIF (l_isDrp = true AND p_rowtype = 390) THEN                --    Expired Demand
      sql_stmt := sql_stmt || ' AND source_table = ''MSC_DEMANDS''' ||
                ' AND order_type in (6,29,30) ' ||
                ' and unmet_quantity > 0 ';

    END IF;
/*
dbms_output.put_line(substr(sql_stmt,1,240));
dbms_output.put_line(substr(sql_stmt,241,240));
dbms_output.put_line(substr(sql_stmt,481,240));
*/

        EXECUTE IMMEDIATE sql_stmt using l_query_id,p_plan_id,
                                      v_org_id, p_inst_id,
                                      v_item_id, p_sub_org_id;
      end if; -- if p_node_type <> NODE_GL_FORECAST_ITEM  THEN
    end loop;
    close item_record;

  END IF; -- end IF p_node_type in (NODE_LINE,NODE_DEPT_RES,

IF p_node_type not in (NODE_LINE,NODE_DEPT_RES,NODE_TRANS_RES) THEN
    x_trans_list :=  l_query_id;
ELSE
  OPEN TRANS_C;
  l_count := 1;
  LOOP
    FETCH TRANS_C INTO l_trans_id;

    EXIT WHEN TRANS_C%NOTFOUND;
    IF x_trans_list IS NULL THEN
      x_trans_list := l_trans_id;
    ELSIF ( (length(x_trans_list) + length(l_trans_id) < 31000) AND (l_count < 201) ) THEN
      x_trans_list := x_trans_list || ',' || l_trans_id;
    ELSE
      x_error := 2;
      --x_err_message := 'MSC_HP_DRILL_LIMIT';
      x_trans_list := l_query_id;
      EXIT;
    END IF;
  l_count := l_count + 1;
  END LOOP;
  CLOSE TRANS_C;
END IF;
EXCEPTION

  WHEN OTHERS THEN

    x_error := 1;
    x_err_message := sqlerrm;

END get_detail_records;


FUNCTION     update_ss
             (p_plan_id number,
              p_sr_instance_id number,
              p_organization_id number,
              p_item_id number,
              p_from_date date,
              p_to_date date ,
              p_new_qty number ) return number  is
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

     update msc_safety_stocks
       set  SAFETY_STOCK_QUANTITY = p_new_qty
      where
       plan_id = p_plan_id
       and sr_instance_id = p_sr_instance_id
       and organization_id = p_organization_id
       and inventory_item_id = p_item_id
       and period_start_date between p_from_date and p_to_date;

    commit;
      return 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      return 1;
  WHEN OTHERS THEN
     return -1;

END update_ss ;


END;

/

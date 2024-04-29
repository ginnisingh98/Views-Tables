--------------------------------------------------------
--  DDL for Package Body GMP_HORIZONTAL_PDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_HORIZONTAL_PDR_PKG" AS
/* $Header: GMPHPDRB.pls 120.8.12010000.8 2010/03/17 13:07:57 vpedarla ship $ */

l_debug             VARCHAR2(1) := NVL(FND_PROFILE.VALUE('GMP_DEBUG_ENABLED'),'N'); -- BUG: 9366921

/* plan types */
SRO_PLAN	           CONSTANT INTEGER := 4;

PURCHASE_ORDER      CONSTANT INTEGER := 1;   /* order type lookup  */
PURCH_REQ           CONSTANT INTEGER := 2;
WORK_ORDER          CONSTANT INTEGER := 3;
REPETITIVE_SCHEDULE CONSTANT INTEGER := 4;
PLANNED_ORDER       CONSTANT INTEGER := 5;
MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
NONSTD_JOB          CONSTANT INTEGER := 7;
RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
REQUIREMENT         CONSTANT INTEGER := 9;
FPO_SUPPLY          CONSTANT INTEGER := 10;
SHIPMENT            CONSTANT INTEGER := 11;
RECEIPT_SHIPMENT    CONSTANT INTEGER := 12;
AGG_REP_SCHEDULE    CONSTANT INTEGER := 13;
DIS_JOB_BY          CONSTANT INTEGER := 14;
NON_ST_JOB_BY       CONSTANT INTEGER := 15;
REP_SCHED_BY        CONSTANT INTEGER := 16;
PLANNED_BY          CONSTANT INTEGER := 17;
ON_HAND_QTY         CONSTANT INTEGER := 18;
FLOW_SCHED          CONSTANT INTEGER := 27;
FLOW_SCHED_BY	     CONSTANT INTEGER := 28;
PAYBACK_SUPPLY      CONSTANT INTEGER := 29;

SALES               CONSTANT INTEGER := 10;  /* horizontal plan type lookup */
FORECAST            CONSTANT INTEGER := 20;
PROD_FORECAST       CONSTANT INTEGER := 25;
DEPENDENT           CONSTANT INTEGER := 30;
SCRAP               CONSTANT INTEGER := 40;
PB_DEMAND           CONSTANT INTEGER := 45;
OTHER               CONSTANT INTEGER := 50;
GROSS               CONSTANT INTEGER := 70;
WIP                 CONSTANT INTEGER := 81;
FLOW_SCHEDULE	     CONSTANT INTEGER := 82;
PO                  CONSTANT INTEGER := 83;
REQ                 CONSTANT INTEGER := 85;
TRANSIT             CONSTANT INTEGER := 87;
RECEIVING           CONSTANT INTEGER := 89;
PLANNED             CONSTANT INTEGER := 90;
PB_SUPPLY           CONSTANT INTEGER := 95;
SUPPLY              CONSTANT INTEGER := 100;
ON_HAND             CONSTANT INTEGER := 105;
PAB                 CONSTANT INTEGER := 110;
SS                  CONSTANT INTEGER := 120;
SS_UNC		        CONSTANT INTEGER := 125;
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
MAD1	              CONSTANT INTEGER  := 290;

SALES_OFF           CONSTANT INTEGER := 0; /* offsets */
FORECAST_OFF        CONSTANT INTEGER := 1;
PROD_FORECAST_OFF   CONSTANT INTEGER := 2;
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
SUPPLY_OFF          CONSTANT INTEGER := 15;
ON_HAND_OFF         CONSTANT INTEGER := 16;
PAB_OFF             CONSTANT INTEGER := 17;
SS_OFF              CONSTANT INTEGER := 18;
ATP_OFF             CONSTANT INTEGER := 19;
CURRENT_S_OFF       CONSTANT INTEGER := 20;
POH_OFF             CONSTANT INTEGER := 21;
EXP_LOT_OFF         CONSTANT INTEGER := 22;
SSUNC_OFF	        CONSTANT INTEGER := 23;
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
ACHIEVED_SER_OFF    CONSTANT INTEGER := 34;
NON_POOL_SS_OFF     CONSTANT INTEGER  := 35;
MANF_VARI_OFF       CONSTANT INTEGER  := 36;
PURC_VARI_OFF       CONSTANT INTEGER  := 37;
TRAN_VARI_OFF       CONSTANT INTEGER  := 38;
DMND_VARI_OFF       CONSTANT INTEGER  := 39;
MAD_OFF             CONSTANT INTEGER  := 40;
MAPE_OFF            CONSTANT INTEGER  := 41;

NUM_OF_TYPES        CONSTANT INTEGER := 42;

/* MRP demand types */
DEMAND_PAYBACK      CONSTANT INTEGER := 27;

G_inst_id                    NUMBER;
G_org_id                     NUMBER;
G_plan_id                    NUMBER;
G_day_bckt_cutoff_dt         DATE;
G_week_bckt_cutoff_dt        DATE;
G_period_bucket              NUMBER;
g_num_of_buckets	           NUMBER;
g_error_stmt		           VARCHAR2(200);

TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE populate_horizontal_plan (
   p_inst_id                    NUMBER,
   p_org_id                     NUMBER,
   p_plan_id                    NUMBER,
   p_day_bckt_cutoff_dt         DATE,
   p_week_bckt_cutoff_dt        DATE,
   p_period_bucket              NUMBER,
   p_incl_items_no_activity     NUMBER --  Bug: 8486531 Vpedarla
)
IS

-- -------------------------------------------------
-- This cursor select number of buckets in the plan.
-- -------------------------------------------------
CURSOR cur_bckt_start_date IS
   SELECT trunc(curr_start_date)
   FROM msc_plans
   WHERE plan_id = G_plan_id;



-- Vpedarla Bug:6784251 Modified the cursor
-- Vpedarla Bug:7257708 Modified the cursor. corrected the mistake done for bug: 6784251
CURSOR cur_bckt_end_date IS
   SELECT MIN(trunc(mpsd.next_date))
   FROM msc_period_start_dates mpsd,
   msc_trading_partners mtp
   WHERE
   mtp.calendar_code = mpsd.calendar_code
   AND mtp.calendar_exception_set_id = mpsd.exception_set_id
   AND mtp.sr_tp_id = G_org_id
   AND mtp.partner_type = 3
   AND mtp.sr_instance_id = G_inst_id
   AND mpsd.sr_instance_id = mtp.sr_instance_id
   AND mpsd.period_start_date >= trunc(G_week_bckt_cutoff_dt)
 --   AND mpsd.period_sequence_num = ((SELECT mpsd2.period_sequence_num /* bug:6784251 Vpedarla */
 --   AND mpsd.period_sequence_num = (SELECT mod((mpsd2.period_sequence_num + mtp.sr_instance_id - 1) , 12 ) + 1 /* bug:7257708 Vpedarla */
 --  AND mpsd.period_sequence_num = (SELECT mod((mpsd2.period_sequence_num + G_period_bucket - 1) , 12 ) + 1  /* Bug: 8447261 Vpedarla */
   AND mpsd.period_sequence_num = (SELECT mod((mpsd2.period_sequence_num + G_period_bucket - 1) , 12 )
                                   FROM msc_period_start_dates mpsd2
                                   WHERE mpsd2.period_start_date = trunc(G_week_bckt_cutoff_dt)
                                   AND mpsd2.calendar_code = mpsd.calendar_code
                                   AND mpsd2.exception_set_id = mpsd.exception_set_id
 --                                       AND mpsd2.sr_instance_id = mtp.sr_instance_id) + G_period_bucket); /* bug:6784251 Vpedarla */
                                   AND mpsd2.sr_instance_id = mtp.sr_instance_id) ;


-- -------------------------------------------------
-- This cursor selects the dates for the buckets.
-- -------------------------------------------------
CURSOR bucket_dates(p_start_date DATE, p_end_date DATE) IS
SELECT cal.calendar_date
FROM msc_calendar_dates cal,
msc_trading_partners tp
WHERE tp.sr_tp_id = G_org_id
AND tp.sr_instance_id = G_inst_id
AND tp.calendar_exception_set_id = cal.exception_set_id
AND tp.partner_type = 3
AND tp.calendar_code = cal.calendar_code
AND tp.sr_instance_id = cal.sr_instance_id
AND cal.calendar_date BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date)
ORDER BY cal.calendar_date;

l_bckt_start_date	DATE;
l_bckt_end_date		DATE;

l_bucket_number		NUMBER := 0;
l_bucket_date		DATE;

last_date       DATE;
sid             NUMBER;


g_incl_items_no_activity      NUMBER ;  -- Bug: 8486531

-- Bug: 9475171 Vpedarla initialized variable to 0
item_rec_count                NUMBER  := 0 ;-- Bug: 8486531


-- --------------------------------------------
-- This cursor selects the snapshot activity in
-- MSC_DEMANDS and MSC_SUPPLIES
-- for the items per organizatio for a plan..
-- --------------------------------------------
CURSOR  mrp_snapshot_activity IS
 SELECT /*+ INDEX(rec, MSC_SUPPLIES_N1) */
/*        list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
*/
        gpi.inventory_item_id,
        gpi.organization_id,
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
        SUM(DECODE(gpi.base_item_id,NULL, DECODE(rec.disposition_status_type, /* nsinghi: need to get replace for base_item_id */
            2, 0, DECODE(rec.last_unit_completion_date,
                    NULL, rec.new_order_quantity, rec.daily_rate) ),
            DECODE(rec.last_unit_completion_date,
		NULL, rec.new_order_quantity, rec.daily_rate) )) new_quantity,
        SUM(NVL(rec.old_order_quantity,0)) old_quantity,
        sum(0) dos,
        0 cost
FROM    --msc_form_query      list,
        gmp_pdr_items_gtmp gpi,
        msc_trading_partners      param,
--        msc_system_items msi,
        msc_supplies rec,
        msc_calendar_dates      dates
WHERE   /*(arg_res_level = 1
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
AND */  dates.sr_instance_id = rec.sr_instance_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.calendar_date BETWEEN trunc(rec.new_schedule_date)
         AND NVL(rec.last_unit_completion_date, trunc(rec.new_schedule_date))
AND     (trunc(rec.new_schedule_date) <= last_date OR
         trunc(rec.old_schedule_date) <= last_date)
/*
AND     rec.plan_id = msi.plan_id
AND     rec.inventory_item_id = msi.inventory_item_id
AND     rec.organization_id = msi.organization_id
AND     rec.sr_instance_id = msi.sr_instance_id
AND     msi.plan_id = list.number4
AND     msi.inventory_item_id = list.number1
AND     msi.organization_id = list.number2
AND     msi.sr_instance_id = list.number3
*/
AND     gpi.inventory_item_id = rec.inventory_item_id
AND     gpi.organization_id = rec.organization_id
AND     rec.plan_id = G_plan_id
AND     rec.sr_instance_id = G_inst_id

AND     param.sr_tp_id = rec.organization_id
AND     param.sr_instance_id = rec.sr_instance_id
AND     param.partner_type = 3
--AND     list.query_id = item_list_id
GROUP BY
/*
        list.number5,
        list.number6,
        list.number3,
*/
        gpi.inventory_item_id,
        gpi.organization_id,
--        G_sr_instance_id, /* Will not include sr_instance_id column in gmp_material_plans table. */
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
SELECT  /*list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,

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
                        29,(nvl(mgr.probability,1)*using_requirement_quantity),
                        31, 0,
                        using_requirement_quantity),
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
FROM    -- msc_form_query      list,
        gmp_pdr_items_gtmp gpi,
        msc_trading_partners      param,
        msc_demands  mgr,
        msc_calendar_dates  dates
WHERE /*(arg_res_level = 1
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
AND */	dates.sr_instance_id = mgr.sr_instance_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.calendar_date BETWEEN trunc(mgr.using_assembly_demand_date)
AND     NVL(trunc(mgr.assembly_demand_comp_date),
	trunc(mgr.using_assembly_demand_date))
AND     trunc(mgr.using_assembly_demand_date) <= trunc(last_date)
/*
AND     mgr.plan_id = list.number4
AND     mgr.inventory_item_id = list.number1
AND     mgr.organization_id = list.number2
AND     mgr.sr_instance_id = list.number3
*/
AND     gpi.inventory_item_id = mgr.inventory_item_id
AND     gpi.organization_id = mgr.organization_id
AND     mgr.sr_instance_id = G_inst_id
AND     mgr.plan_id = G_plan_id
AND     param.sr_tp_id = mgr.organization_id
AND     param.sr_instance_id = mgr.sr_instance_id
AND     param.partner_type = 3
--AND     list.query_id = item_list_id
AND     not exists (
        select 'cancelled IR'
        from   msc_supplies mr
        where  mgr.origination_type in (30,6)
        and    mgr.disposition_id = mr.transaction_id
        and    mgr.plan_id = mr.plan_id
        and    mgr.sr_instance_id = mr.sr_instance_id
        and    mr.disposition_status_type = 2)
GROUP BY
/*
        list.number5,
        list.number6,
        list.number3,
*/
        gpi.inventory_item_id,
        gpi.organization_id,
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
SELECT  /*list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        MAD1 row_type,
        MAD_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(DECODE(mgr.error_type, 1, mgr.forecast_MAD, 0)) new_quantity,
        SUM(DECODE(mgr.error_type, 2, mgr.forecast_MAD, 0)) old_quantity,
        0 dos,
        0 cost
FROM    --msc_form_query      list,
        gmp_pdr_items_gtmp gpi,
        msc_trading_partners      param,
        msc_demands  mgr,
        msc_calendar_dates  dates
 WHERE /*(arg_res_level = 1
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
AND */	dates.sr_instance_id = mgr.sr_instance_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.calendar_date BETWEEN trunc(mgr.using_assembly_demand_date)
AND     NVL(trunc(mgr.assembly_demand_comp_date),
	trunc(mgr.using_assembly_demand_date))
AND     trunc(mgr.using_assembly_demand_date) <= trunc(last_date)
/*
AND     mgr.plan_id = list.number4
AND     mgr.inventory_item_id = list.number1
AND     mgr.organization_id = list.number2
AND     mgr.sr_instance_id = list.number3
*/
AND     gpi.inventory_item_id = mgr.inventory_item_id
AND     gpi.organization_id = mgr.organization_id
AND     mgr.sr_instance_id = G_inst_id
AND     mgr.plan_id = G_plan_id

AND     param.sr_tp_id = mgr.organization_id
AND     param.sr_instance_id = mgr.sr_instance_id
AND     param.partner_type = 3
--AND     list.query_id = item_list_id
 GROUP BY
 /*
        list.number5,
        list.number6,
        list.number3,
*/
        gpi.inventory_item_id,
        gpi.organization_id,
        MAD1, MAD_OFF,
        dates.calendar_date,
        dates.calendar_date,
            0
UNION ALL
SELECT /* list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        ATP row_type,
        ATP_OFF offset,
        avail.schedule_date new_date,
        avail.schedule_date old_date,
        avail.quantity_available new_quantity,
        0 old_quantity,
        0 dos,
        0 cost
FROM    --msc_form_query      list,
        gmp_pdr_items_gtmp gpi,
        msc_available_to_promise avail
WHERE   avail.schedule_date < last_date
/*AND     avail.organization_id = list.number2
AND     avail.plan_id = list.number4
AND     avail.inventory_item_id = list.number1
AND     avail.sr_instance_id = list.number3
AND     list.query_id = item_list_id
*/
AND     avail.organization_id = gpi.organization_id
AND     avail.inventory_item_id = gpi.inventory_item_id
AND     avail.sr_instance_id = G_inst_id
AND     avail.plan_id = G_plan_id
UNION ALL
SELECT  /*list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        SS row_type,
        SS_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.safety_stock_quantity) new_quantity,
        safety.organization_id old_quantity,
        sum(safety.achieved_days_of_supply) dos,
        sum(safety.safety_stock_quantity * gpi.standard_cost) cost
FROM    msc_safety_stocks    safety,
--        msc_form_query      list ,
--        msc_system_items    item
        gmp_pdr_items_gtmp gpi
WHERE   safety.period_start_date <= last_date
/*AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
*/
AND     safety.organization_id = gpi.organization_id
AND     safety.inventory_item_id = gpi.inventory_item_id
AND     safety.plan_id = G_plan_id
AND     safety.sr_instance_id = G_inst_id
/*AND     nvl(safety.project_id,1) =
      decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id */
AND     safety.safety_stock_quantity IS NOT NULL
/*
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
*/
GROUP BY /* list.number5,
          list.number6,
          list.number3,
          */
          gpi.inventory_item_id,
          gpi.organization_id,
          SS, SS_OFF, safety.period_start_date, safety.organization_id
UNION ALL
--------------------------------------------------------------------
-- This will select unconstrained safety stock for sro plans
---------------------------------------------------------------------
SELECT /* list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id, */
        gpi.inventory_item_id,
        gpi.organization_id,
        SS_UNC row_type,
        SSUNC_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.TARGET_SAFETY_STOCK) new_quantity,
        sum(safety.TOTAL_UNPOOLED_SAFETY_STOCK) old_quantity,
        sum(safety.target_days_of_supply) dos,
        sum(safety.TARGET_SAFETY_STOCK * gpi.standard_cost) cost
FROM    msc_safety_stocks    safety,
--        msc_form_query      list ,
--        msc_system_items    item
        gmp_pdr_items_gtmp gpi
WHERE   safety.period_start_date <= last_date
/*AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
     decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
*/
-- and     safety.target_safety_stock is not null
AND     safety.organization_id = gpi.organization_id
AND     safety.inventory_item_id = gpi.inventory_item_id
AND     safety.plan_id = G_plan_id
AND     safety.sr_instance_id = G_inst_id
/*
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
*/
GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         SS_UNC, SSUNC_OFF,
         safety.period_start_date
UNION ALL
--------------------------------------------------------------------
-- This will select user specified safety stocks
---------------------------------------------------------------------
SELECT /* list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        USS row_type,
        USS_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.USER_DEFINED_SAFETY_STOCKS) new_quantity,
        sum(0) old_quantity,
        sum(safety.user_defined_dos) dos,
        sum(safety.USER_DEFINED_SAFETY_STOCKS * gpi.standard_cost) cost
FROM    msc_safety_stocks    safety,
--        msc_form_query      list,
--        msc_system_items    item
        gmp_pdr_items_gtmp gpi
WHERE   safety.period_start_date <= last_date
/*
AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
     decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
*/
AND     safety.organization_id = gpi.organization_id
AND     safety.sr_instance_id = G_inst_id
AND     safety.plan_id = G_plan_id
AND     safety.inventory_item_id = gpi.inventory_item_id

AND     nvl(safety.user_defined_safety_stocks,safety.user_defined_dos) IS NOT NULL
/*
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
*/
GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         USS, USS_OFF,
         safety.period_start_date, 0
UNION ALL
--------------------------------------------------------------------
-- This will select Lead Time Variability Percentages
---------------------------------------------------------------------
 SELECT /* list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        MANU_VARI row_type,
        MANF_VARI_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.MFG_LTVAR_SS_PERCENT) new_quantity,
        sum(safety.SUP_LTVAR_SS_PERCENT) old_quantity,
        sum(safety.TRANSIT_LTVAR_SS_PERCENT) dos,
        sum(safety.DEMAND_VAR_SS_PERCENT) cost
FROM    msc_safety_stocks    safety,
--        msc_form_query      list,
--        msc_system_items    item
        gmp_pdr_items_gtmp gpi
WHERE   safety.period_start_date <= last_date
AND     safety.organization_id = gpi.organization_id
AND     safety.sr_instance_id = G_inst_id
AND     safety.plan_id = G_plan_id
AND     safety.inventory_item_id = gpi.inventory_item_id
/*
AND     safety.organization_id = list.number2
AND     safety.sr_instance_id = list.number3
AND     safety.plan_id = list.number4
AND     safety.inventory_item_id = list.number1
AND     nvl(safety.project_id,1) =
     decode(arg_res_level,4,nvl(arg_resval1,nvl(safety.project_id,1)),5,nvl(arg_resval1,nvl(safety.project_id,1)),nvl(safety.project_id,1))
AND     nvl(safety.task_id,1) =
      decode(arg_res_level,5,nvl(arg_resval2,nvl(safety.task_id,1)),nvl(safety.task_id,1))
AND     list.query_id = item_list_id
AND     safety.organization_id = item.organization_id
AND     safety.sr_instance_id = item.sr_instance_id
AND     safety.plan_id = item.plan_id
AND     safety.inventory_item_id = item.inventory_item_id
*/
GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         MANU_VARI, MANF_VARI_OFF,
         safety.period_start_date
UNION ALL
--------------------------------------------------------------------
-- This will select minimum inventory levels
---------------------------------------------------------------------
SELECT  /*
        list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        min_inv_lvl row_type,
        min_inv_lvl_off offset,
        lvl.inventory_date new_date,
        lvl.inventory_date old_date,
        min(lvl.Min_quantity) new_quantity,
        min(0) old_quantity,
        min(lvl.min_quantity_dos) dos,
        0
FROM    msc_inventory_levels lvl,
--        msc_form_query      list
        gmp_pdr_items_gtmp gpi
WHERE   lvl.inventory_date <= last_date
/*
AND     lvl.organization_id = list.number2
AND     lvl.sr_instance_id = list.number3
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
*/
AND     lvl.organization_id = gpi.organization_id
AND     lvl.sr_instance_id = G_inst_id
AND     lvl.plan_id = G_plan_id
AND     lvl.inventory_item_id = gpi.inventory_item_id

AND     nvl(lvl.min_quantity,lvl.min_quantity_dos) IS NOT NULL
GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         min_inv_lvl, min_inv_lvl_off,
         lvl.inventory_date
UNION ALL
--------------------------------------------------------------------
-- This will select maximum inventory levels
---------------------------------------------------------------------
SELECT
        /*
        list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        max_inv_lvl row_type,
        max_inv_lvl_off offset,
        lvl.inventory_date new_date,
        lvl.inventory_date old_date,
        max(lvl.Max_quantity) new_quantity,
        max(0) old_quantity,
        max(lvl.max_quantity_dos) dos,
        0
FROM    msc_inventory_levels lvl,
--        msc_form_query      list
        gmp_pdr_items_gtmp gpi
WHERE   lvl.inventory_date<= last_date
/*
AND     lvl.organization_id = list.number2
AND     lvl.sr_instance_id = list.number3
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
*/
AND     lvl.organization_id = gpi.organization_id
AND     lvl.sr_instance_id = G_inst_id
AND     lvl.plan_id = G_plan_id
AND     lvl.inventory_item_id = gpi.inventory_item_id

AND     nvl(lvl.max_quantity,lvl.max_quantity_dos) IS NOT NULL
GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         max_inv_lvl, max_inv_lvl_off,
         lvl.inventory_date
union all
--------------------------------------------------------------------
-- This will select Target Inventory Levels
---------------------------------------------------------------------
SELECT
/*
        list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
*/
        gpi.inventory_item_id,
        gpi.organization_id,
        TARGET_SER_LVL row_type,
        TARGET_SER_OFF offset,
        lvl.period_start_date new_date,
        lvl.period_start_date old_date,
        sum(lvl.TARGET_SERVICE_LEVEL) new_quantity,
        0 old_quantity,
        0 dos,
        0
FROM    msc_analysis_aggregate lvl,
--        msc_form_query      list
        gmp_pdr_items_gtmp gpi
WHERE   lvl.period_start_date <= last_date
AND     lvl.period_start_date >= l_bckt_start_date -1
AND     lvl.record_type = 1
AND     lvl.period_type = 0
AND     lvl.sr_instance_id IS NULL
AND     lvl.organization_id IS NULL
AND     lvl.category_name IS NULL
/*
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
*/
AND     lvl.sr_instance_id = G_inst_id
AND     lvl.plan_id = G_plan_id
AND     lvl.inventory_item_id = gpi.inventory_item_id

GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         TARGET_SER_LVL, TARGET_SER_OFF,
         lvl.period_start_date
union all

--------------------------------------------------------------------
-- This will select ACHIEVED Inventory Levels
---------------------------------------------------------------------
SELECT  /*
        list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        */
        gpi.inventory_item_id,
        gpi.organization_id,
        ACHIEVED_SER_LVL row_type,
        ACHIEVED_SER_OFF offset,
        lvl.period_start_date new_date,
        lvl.period_start_date old_date,
        sum(lvl.ACHIEVED_SERVICE_LEVEL) new_quantity,
        0 old_quantity,
        0 dos,
        0
FROM    msc_analysis_aggregate lvl,
--        msc_form_query      list
        gmp_pdr_items_gtmp gpi
WHERE   lvl.period_start_date <= last_date
AND     lvl.period_start_date >= l_bckt_start_date -1
AND     lvl.record_type = 1
AND     lvl.period_type = 0
AND     lvl.sr_instance_id is null
AND     lvl.organization_id is null
AND     lvl.category_name is null
/*
AND     lvl.plan_id = list.number4
AND     lvl.inventory_item_id = list.number1
AND     list.query_id = item_list_id
*/
AND     lvl.sr_instance_id = G_inst_id
AND     lvl.plan_id = G_plan_id
AND     lvl.inventory_item_id = gpi.inventory_item_id
GROUP BY /* list.number5,list.number6,list.number3, */
         gpi.inventory_item_id,
         gpi.organization_id,
         ACHIEVED_SER_LVL, ACHIEVED_SER_OFF,
         lvl.period_start_date
/*
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
*/
ORDER BY
     1, 2, 5, 3 ;
/*
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
*/

TYPE mrp_activity IS RECORD
     (item_id      NUMBER,
      org_id       NUMBER,
--      inst_id       NUMBER,
      row_type     NUMBER,
      offset       NUMBER,
      new_date     DATE,
      old_date     DATE,
      new_quantity NUMBER,
      old_quantity NUMBER,
      DOS          NUMBER,
      cost         number);

activity_rec     mrp_activity;

-- bug: 9366921
TYPE activity_rec_tbl IS TABLE OF mrp_activity INDEX by BINARY_INTEGER;
activity_rec_tab   activity_rec_tbl;
activity_rec_count  INTEGER ;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE column_char   IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE number_arr IS TABLE OF number;

var_dates           calendar_date;   -- Holds the start dates of buckets
bucket_cells_tab    column_number;       -- Holds the quantities per bucket
ep_bucket_cells_tab    column_number;
last_item_id        NUMBER := -1;
last_org_id        NUMBER := -1;
--last_inst_id        NUMBER := -1;

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

target_level   NUMBER := -1;
achieved_level NUMBER := -1;
mad            NUMBER := -1;
mape           NUMBER := -1;

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
l_plan_type	    NUMBER := 1;
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
   v_count := prev_ss_org.last;
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
  for a in 1..prev_ss_org.last loop
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
                      quantity IN NUMBER
                      ) IS
location NUMBER;
BEGIN
  g_error_stmt := 'Debug - add_to_plan - 10';
  IF quantity = 0 THEN
     RETURN;
  END IF;
/*  IF p_enterprise then
     location := (bucket - 1) + offset;
     IF offset in (SSUNC_OFF,SSUNC_DOS_OFF, SSUNC_VAL_OFF, SS_OFF,SS_DOS_OFF, SS_VAL_OFF, USS_OFF  , USS_DOS_OFF, USS_VAL_OFF, min_inv_lvl_off , max_inv_lvl_off )THEN
         ep_bucket_cells_tab(location) := quantity;
     ELSE
         ep_bucket_cells_tab(location) :=
             NVL(ep_bucket_cells_tab(location),0) + quantity;
     END IF;
  ELSE  -- not enterprize view
*/
  location := ((bucket - 1) * NUM_OF_TYPES) + offset;
  IF offset IN (SSUNC_OFF, SSUNC_DOS_OFF, SSUNC_VAL_OFF, SS_OFF,SS_DOS_OFF, SS_VAL_OFF, USS_OFF  , USS_DOS_OFF, USS_VAL_OFF, min_inv_lvl_off , max_inv_lvl_off) THEN
     bucket_cells_tab(location) := quantity;
  ELSE
     /* nsinghi: Txns CURRENT_S represents txn of type schedule receipt. Since the first bucket
     store information abt past due data, so do not consider the scedule reciept for first bucket. */

     IF ( bucket = 1  AND offset <> CURRENT_S_OFF )THEN
        bucket_cells_tab(location) := quantity;
     ELSE
        bucket_cells_tab(location) := NVL(bucket_cells_tab(location),0) + quantity;
     END IF;
  END IF;
--  END IF;
END;

-- =============================================================================
--
-- flush_item_plan inserts into MRP_MATERIAL_PLANS
--
-- =============================================================================
PROCEDURE flush_item_plan(p_item_id IN NUMBER,
                          p_org_id IN NUMBER) IS
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

sales_sum NUMBER;
forecast_sum NUMBER;
prod_forecast_sum NUMBER;
dependent_sum NUMBER;
scrap_sum NUMBER;
pb_demand_sum NUMBER;
other_sum NUMBER;
gross_sum NUMBER;
wip_sum NUMBER;
po_sum NUMBER;
req_sum NUMBER;
transit_sum NUMBER;
receiving_sum NUMBER;
planned_sum NUMBER;
pb_supply NUMBER;
supply_sum NUMBER;
on_hand_sum NUMBER;
current_s_sum NUMBER;
exp_lot_sum NUMBER;

next_week_start_date DATE;
next_period_start_date DATE;
curr_week_start_date DATE;
curr_period_start_date DATE;

week_change_flag BOOLEAN;
period_change_flag BOOLEAN;
prev_week_loop_counter NUMBER;
prev_period_loop_counter NUMBER;

CURSOR check_atp IS
  SELECT gpi.calculate_atp
  FROM   gmp_pdr_items_gtmp gpi
  WHERE  gpi.inventory_item_id = p_item_id
  AND    gpi.organization_id = p_org_id;

BEGIN

  -- ----------------------------------------
  -- get plan type to check if it is SRO plan
  -- add SS to gross req if plan type is SRO
  -- ----------------------------------------

  SELECT plan_type INTO l_plan_type
  FROM	 msc_plans
  WHERE  plan_id = G_plan_id;
  -- -------------------------------
  -- Get the item segments, atp flag
  -- -------------------------------
  g_error_stmt := 'Debug - flush_item_plan - 10';
  gmp_debug_message('Debug - flush_item_plan - 10') ;

  OPEN check_atp;
  FETCH check_atp INTO atp_flag;
  CLOSE check_atp;

--  IF NOT enterprize_view THEN
    -- -----------------------------
    -- Calculate gross requirements,
    -- Total suppy
    -- PAB
    -- POH
    -- -----------------------------

  FOR LOOP IN 1..g_num_of_buckets
  LOOP
    ----------------------
    -- Gross requirements.
    -- -------------------
    g_error_stmt := 'Debug - flush_item_plan - 20 - loop'||loop;
    lot_quantity := bucket_cells_tab(((loop - 1) * NUM_OF_TYPES)+
                      EXP_LOT_OFF);
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
    IF(lot_quantity > total_reqs AND lot_quantity > 0 ) THEN
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
            DEPENDENT_OFF,
            bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
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
    /* nsinghi: available balance. */
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
    ELSIF loop = 2 THEN
      add_to_plan(loop,
              POH_OFF,
              bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + POH_OFF) +
              bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
              bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
              bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
    ELSE
      add_to_plan(loop,
              POH_OFF,
              bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + POH_OFF) +
              bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
              bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
    END IF;

  END LOOP; -- columnd
      ----------------
      -- calculate ATP
      ----------------
  g_error_stmt := 'Debug - flush_item_plan - 60';
  gmp_debug_message('Debug - flush_item_plan - 60');

  FOR      atp_counter IN 1..g_num_of_buckets LOOP
           add_to_plan(atp_counter, ATP_OFF, 0);
  END LOOP;

  IF atp_flag = 1 THEN -- only calculate atp when atp_flag is 1

     IF  l_atp_qty_net.COUNT = 0 THEN
        l_atp_qty_net.Extend(g_num_of_buckets);
     END IF;

     FOR      atp_counter IN 1..g_num_of_buckets
     LOOP

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

  /* nsinghi: insert logic -
  1) For the num of days buckets, no issue, insert the txns as it is.
  2) Do the looping for days buckets till var_dates(loop_counter) < G_day_bckt_cutoff_dt
  3) For each week bucket, get the (next week_start_date - 1). Loop the loop_counter for these many days and
     add the supply and demand txns. Insert a row for the week_start_date bucket.
  4) The loop runs till var_dates(loop_counter) < G_week_bckt_cutoff_dt
  5) For each period bucket, get the (next period_start_date - 1). Loop the loop_counter for these many days and
     add the supply and demand txns. Insert a row for the period_start_date bucket.
  4) The loop runs till var_dates(loop_counter) <= last_date.
  */

  sales_sum := 0;
  forecast_sum := 0;
  prod_forecast_sum := 0;
  dependent_sum := 0;
  scrap_sum := 0;
  pb_demand_sum := 0;
  other_sum := 0;
  gross_sum := 0;
  wip_sum := 0;
  po_sum := 0;
  req_sum := 0;
  transit_sum := 0;
  receiving_sum := 0;
  planned_sum := 0;
  pb_supply := 0;
  supply_sum := 0;
  on_hand_sum := 0;
  current_s_sum := 0;
  exp_lot_sum := 0;

  next_week_start_date := NULL;
  next_period_start_date := NULL;
  curr_week_start_date := NULL;
  curr_period_start_date := NULL;

  week_change_flag := TRUE;
  period_change_flag := TRUE;
  prev_week_loop_counter := -1;
  prev_period_loop_counter := -1;

  FOR loop_counter IN 1..g_num_of_buckets LOOP
     IF var_dates(loop_counter) < G_day_bckt_cutoff_dt THEN

        INSERT INTO gmp_horizontal_pdr_gtmp
        (
          organization_id,
          inventory_item_id,
          bucket_date,
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
          quantity42
        )
        VALUES
        (
          p_org_id,
          p_item_id,
          var_dates(loop_counter),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SALES_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + FORECAST_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PROD_FORECAST_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + DEPENDENT_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SCRAP_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PB_DEMAND_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + OTHER_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + GROSS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + WIP_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PO_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + REQ_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TRANSIT_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + RECEIVING_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PLANNED_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PB_SUPPLY_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SUPPLY_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ON_HAND_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PAB_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ATP_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + CURRENT_S_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + POH_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + EXP_LOT_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MIN_INV_LVL_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAX_INV_LVL_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_DOS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_VAL_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_DOS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_VAL_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_DOS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_VAL_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TARGET_SER_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ACHIEVED_SER_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + NON_POOL_SS_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MANF_VARI_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PURC_VARI_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TRAN_VARI_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + DMND_VARI_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAD_OFF),
          bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAPE_OFF)
        );


     END IF;

/* Vpedarla 8273098 modified the bucket_cells_tab detial selection from
  loop_counter - 1 to loop_counter - 2. Since loop_counter - 1 still points to the current week starting day.
  But we need previous week ending day. So, chaning it to loop_counter - 2. */

     -- Vpedalra Bug: 8363786 Added the IF condiiton
   IF G_week_bckt_cutoff_dt IS NOT NULL THEN
     IF var_dates(loop_counter) >= G_day_bckt_cutoff_dt AND
         var_dates(loop_counter) <= G_week_bckt_cutoff_dt THEN
      --  var_dates(loop_counter) < G_week_bckt_cutoff_dt THEN  Bug: 8447261 Vpedarla
     /* sum the txns. maintain the week start date. */
       next_week_start_date := msc_calendar.next_work_day (-1*G_org_id, G_inst_id,
          MSC_CALENDAR.TYPE_WEEKLY_BUCKET, var_dates(loop_counter)+1 );

       IF curr_week_start_date <> next_week_start_date THEN

        -- Bug : 8447261 Vpedarla Added a if condition for the statement
         IF var_dates(loop_counter) < G_week_bckt_cutoff_dt THEN
          week_change_flag := TRUE;
         END IF;

          INSERT INTO gmp_horizontal_pdr_gtmp
          (
            organization_id,
            inventory_item_id,
            bucket_date,
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
            quantity42
          )
          VALUES
          (
            p_org_id,
            p_item_id,
            var_dates(prev_week_loop_counter),
            sales_sum,
            forecast_sum,
            prod_forecast_sum,
            dependent_sum,
            scrap_sum,
            pb_demand_sum,
            other_sum,
            gross_sum,
            wip_sum,
            po_sum,
            req_sum,
            transit_sum,
            receiving_sum,
            planned_sum,
            pb_supply,
            supply_sum,
            on_hand_sum,
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PAB_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ATP_OFF),
            current_s_sum,
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + POH_OFF),
            exp_lot_sum,
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MIN_INV_LVL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAX_INV_LVL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_DOS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_VAL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_DOS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_VAL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_DOS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_VAL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TARGET_SER_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ACHIEVED_SER_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + NON_POOL_SS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MANF_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PURC_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TRAN_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + DMND_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAD_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAPE_OFF)
          );

          sales_sum := 0;
          forecast_sum := 0;
          prod_forecast_sum := 0;
          dependent_sum := 0;
          scrap_sum := 0;
          pb_demand_sum := 0;
          other_sum := 0;
          gross_sum := 0;
          wip_sum := 0;
          po_sum := 0;
          req_sum := 0;
          transit_sum := 0;
          receiving_sum := 0;
          planned_sum := 0;
          pb_supply := 0;
          supply_sum := 0;
          on_hand_sum := 0;
          current_s_sum := 0;
          exp_lot_sum := 0;

       END IF;
       IF week_change_flag THEN
          curr_week_start_date := next_week_start_date;
          prev_week_loop_counter := loop_counter;
          week_change_flag := FALSE;
       END IF;

       sales_sum := sales_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SALES_OFF) ;
       forecast_sum := forecast_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + FORECAST_OFF);
       prod_forecast_sum := prod_forecast_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PROD_FORECAST_OFF);
       dependent_sum := dependent_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + DEPENDENT_OFF);
       scrap_sum := scrap_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SCRAP_OFF);
       pb_demand_sum := pb_demand_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PB_DEMAND_OFF);
       other_sum := other_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + OTHER_OFF);
       gross_sum := gross_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + GROSS_OFF);
       wip_sum := wip_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + WIP_OFF);
       po_sum := po_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PO_OFF);
       req_sum := req_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + REQ_OFF);
       transit_sum := transit_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TRANSIT_OFF);
       receiving_sum := receiving_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + RECEIVING_OFF);
       planned_sum := planned_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PLANNED_OFF);
       pb_supply := pb_supply + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PB_SUPPLY_OFF);
       supply_sum := supply_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SUPPLY_OFF);
       on_hand_sum := on_hand_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ON_HAND_OFF);
       current_s_sum := current_s_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + CURRENT_S_OFF);
       exp_lot_sum := exp_lot_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + EXP_LOT_OFF);

     END IF;
   END IF;

/* Vpedarla 8273098 modified the bucket_cells_tab detial selection from
  loop_counter - 1 to loop_counter - 2. Since loop_counter - 1 still points to the current period starting day.
  But we need previous period ending day. So, chaning it to loop_counter - 2. */

     -- Vpedalra Bug: 8363786 Added the IF condiiton
   IF G_week_bckt_cutoff_dt IS NOT NULL THEN
     IF var_dates(loop_counter) >= G_week_bckt_cutoff_dt AND
        var_dates(loop_counter) <= last_date THEN
     /* sum the txns. maintain the week start date. */
       next_period_start_date := msc_calendar.next_work_day (-1*G_org_id, G_inst_id,
          MSC_CALENDAR.TYPE_MONTHLY_BUCKET, var_dates(loop_counter)+1 );

       IF curr_period_start_date <> next_period_start_date THEN
          period_change_flag := TRUE;

          INSERT INTO gmp_horizontal_pdr_gtmp
          (
            organization_id,
            inventory_item_id,
            bucket_date,
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
            quantity42
          )
          VALUES
          (
            p_org_id,
            p_item_id,
            var_dates(prev_period_loop_counter),
            sales_sum,
            forecast_sum,
            prod_forecast_sum,
            dependent_sum,
            scrap_sum,
            pb_demand_sum,
            other_sum,
            gross_sum,
            wip_sum,
            po_sum,
            req_sum,
            transit_sum,
            receiving_sum,
            planned_sum,
            pb_supply,
            supply_sum,
            on_hand_sum,
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PAB_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ATP_OFF),
            current_s_sum,
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + POH_OFF),
            exp_lot_sum,
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MIN_INV_LVL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAX_INV_LVL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_DOS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SS_VAL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_DOS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SSUNC_VAL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_DOS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + USS_VAL_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TARGET_SER_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ACHIEVED_SER_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + NON_POOL_SS_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MANF_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PURC_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TRAN_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + DMND_VARI_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAD_OFF),
            bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + MAPE_OFF)
          );

          sales_sum := 0;
          forecast_sum := 0;
          prod_forecast_sum := 0;
          dependent_sum := 0;
          scrap_sum := 0;
          pb_demand_sum := 0;
          other_sum := 0;
          gross_sum := 0;
          wip_sum := 0;
          po_sum := 0;
          req_sum := 0;
          transit_sum := 0;
          receiving_sum := 0;
          planned_sum := 0;
          pb_supply := 0;
          supply_sum := 0;
          on_hand_sum := 0;
          current_s_sum := 0;
          exp_lot_sum := 0;

       END IF;
       IF period_change_flag THEN
          curr_period_start_date := next_period_start_date;
          prev_period_loop_counter := loop_counter;
          period_change_flag := FALSE;
       END IF;

       sales_sum := sales_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SALES_OFF) ;
       forecast_sum := forecast_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + FORECAST_OFF);
       prod_forecast_sum := prod_forecast_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PROD_FORECAST_OFF);
       dependent_sum := dependent_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + DEPENDENT_OFF);
       scrap_sum := scrap_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SCRAP_OFF);
       pb_demand_sum := pb_demand_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PB_DEMAND_OFF);
       other_sum := other_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + OTHER_OFF);
       gross_sum := gross_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + GROSS_OFF);
       wip_sum := wip_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + WIP_OFF);
       po_sum := po_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PO_OFF);
       req_sum := req_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + REQ_OFF);
       transit_sum := transit_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + TRANSIT_OFF);
       receiving_sum := receiving_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + RECEIVING_OFF);
       planned_sum := planned_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PLANNED_OFF);
       pb_supply := pb_supply + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + PB_SUPPLY_OFF);
       supply_sum := supply_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + SUPPLY_OFF);
       on_hand_sum := on_hand_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + ON_HAND_OFF);
       current_s_sum := current_s_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + CURRENT_S_OFF);
       exp_lot_sum := exp_lot_sum + bucket_cells_tab(NUM_OF_TYPES * (loop_counter - 1) + EXP_LOT_OFF);

    END IF;
   END IF;
  END LOOP;

END flush_item_plan;

-- =============================================================================
BEGIN

  gmp_debug_message(' populate_horizontal_plan started ');

  G_inst_id := p_inst_id;
  G_org_id := p_org_id;
  G_plan_id := p_plan_id;
  G_day_bckt_cutoff_dt := p_day_bckt_cutoff_dt ;
  G_week_bckt_cutoff_dt := p_week_bckt_cutoff_dt;
  G_period_bucket := NVL(p_period_bucket,0);
  g_num_of_buckets := 0;
  g_error_stmt	:= NULL;
  g_incl_items_no_activity := p_incl_items_no_activity;  -- Bug: 8486531 Vpedarla

  SELECT plan_type INTO l_plan_type
  FROM	 msc_plans
  WHERE  plan_id = G_plan_id;

  gmp_debug_message(' l_plan_type '||l_plan_type);

  g_error_stmt := 'Debug - populate_horizontal_plan - 10';
  FND_FILE.PUT_LINE ( FND_FILE.LOG,g_error_stmt);
  OPEN cur_bckt_start_date;
  FETCH cur_bckt_start_date INTO l_bckt_start_date;
  CLOSE cur_bckt_start_date;

  gmp_debug_message(' l_bckt_start_date '||to_CHAR(l_bckt_start_date, 'DD-MON-YYY HH24:MI:SS'));

  /* nsinghi :
  1) get the week_cutoff_date.
  2) find the seq number from msc_period_start_date table.
  3) add the period seq number as entered by the user.
  4) get the next_date column - 1 as the period cutoff date
  5) subtract the period_cutoff_date - curr_start_date (bucket start date from msc_plans)
  6) this gives the number of days. */

-- vpedarla Bug: 8363786
IF (G_week_bckt_cutoff_dt is not NULL) and (p_period_bucket > 0) THEN
  OPEN cur_bckt_end_date;
  FETCH cur_bckt_end_date INTO l_bckt_end_date;
  CLOSE cur_bckt_end_date;
ELSE
  l_bckt_end_date := nvl(G_week_bckt_cutoff_dt,G_day_bckt_cutoff_dt);
END IF ;
-- vpedarla Bug: 8363786 end

gmp_debug_message(' l_bckt_end_date ' || to_CHAR(l_bckt_end_date, 'DD-MON-YYY HH24:MI:SS') );

  /* nsinghi: since the next_date column in msc_period_start_dates already give end_date + 1,
        so no need to add 1. */
--  g_num_of_buckets := (l_bckt_end_date + 1) - (l_bckt_start_date - 1);

  -- Rajesh Patangya, We have to see if the end date is coming as null
  IF l_bckt_end_date IS NULL THEN
     g_num_of_buckets := 1 ;
     FND_FILE.PUT_LINE ( FND_FILE.LOG,' Enter Correct Number of periods to find the Number of Buckets');
  ELSE
    -- g_num_of_buckets := (l_bckt_end_date) - (l_bckt_start_date - 1); Bug: 8447261 Vpedarla
       g_num_of_buckets := (l_bckt_end_date) - (l_bckt_start_date - 1) + 1;
  END IF;

 gmp_debug_message(' g_num_of_buckets '|| g_num_of_buckets || ' total count '
                 ||to_char(NUM_OF_TYPES * g_num_of_buckets) );

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';
  FND_FILE.PUT_LINE ( FND_FILE.LOG,g_error_stmt);
  -- ---------------------------------
  -- Initialize the bucket cells to 0.
  -- ---------------------------------
/*  IF enterprize_view or arg_ep_view_also THEN
    FOR counter IN 0..NUM_OF_TYPES LOOP
      ep_bucket_cells_tab(counter) := 0;
    END LOOP;
    last_date := arg_cutoff_date;
  END IF;
*/
--  IF not (enterprize_view) THEN
  FOR counter IN 0..(NUM_OF_TYPES * g_num_of_buckets) LOOP
    bucket_cells_tab(counter) := 0;
  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 30';
  FND_FILE.PUT_LINE ( FND_FILE.LOG,g_error_stmt);
  -- --------------------
  -- Get the bucket dates
  -- --------------------
--    OPEN bucket_dates(l_bckt_start_date-1, l_bckt_end_date+1);
  OPEN bucket_dates(l_bckt_start_date-1, l_bckt_end_date);
  LOOP
    FETCH bucket_dates INTO l_bucket_date;
    EXIT WHEN BUCKET_DATES%NOTFOUND;
    l_bucket_number := l_bucket_number + 1;
    var_dates(l_bucket_number) := l_bucket_date;
  END LOOP;
  CLOSE bucket_dates;

 gmp_debug_message(' l_bucket_number '|| l_bucket_number );

--    last_date := arg_cutoff_date;
  last_date := l_bckt_end_date;

--  END IF;

  g_error_stmt := 'Debug - populate_horizontal_plan - 40';
  FND_FILE.PUT_LINE ( FND_FILE.LOG,g_error_stmt);

  bucket_counter := 2;
  old_bucket_counter := 2;
  activity_rec.item_id := 0;
  activity_rec.org_id := 0;
--  activity_rec.inst_id := 0;
  activity_rec.row_type := 0;
  activity_rec.offset := 0;
  activity_rec.new_date := sysdate;
  activity_rec.old_date := sysdate;
  activity_rec.new_quantity := 0;
  activity_rec.old_quantity := 0;
  activity_rec.DOS    := 0;
  activity_rec.cost:=0;

/* nsinghi:
Logic:
Here the logic from start of this procedure to the point where data is inserted in GMP_Material_Plans is explained.

1) Initially get the number of days that the horiz report needs to consider based
on the days, weeks and periods entered in the conc window.
2) Each row in GMP_Material_Plans will correspond to one day.
3) PL/SQL Table bucket_cells_tab contains (num of report days) * (num of txns type) num of rows. Thus for each transaction on each day has one row in bucket_cells_tab. Each txn is given an offset as defined by
the constants in the procedure. Thus all multiples of the offset will store information of that type of txns.
4) Every time there is a change in the item, the data is inserted in GMP_Material_plans table.
5) For each activity row, get the txn qty. Insert the qty in bucket_cells_tab. The location of the qty in
bucket_cells_tab will depend on the txn type offset and the day. The bucket day is retrieved as follow:
        a) Get the dates for all the days of the report and store the dates in PL/SQL date table var_dates
        b) Get the row number from var_dates table where the activity row date < date in var_dates
6) For txn of type safety stock, everytime a safety stock activity is retrieved, associate that safety
stock to all the days. This is cause, same safety stock is valid for all the days. If a new safety stock
activity row is later retrieved, replace the new safety stock for all the days after the bucket day
of retrieving the safety stock.
7) Same thing is true for some of the other txns like Manufacturing variation, Demand variation,
Purchase variation. Do not know what all these txns mean.
8) But it is not true for txns like Sales Order, Forecast, Planned Order etc. Obviously, these txns
are only for that specific bucket day and not for all the days after the bucket.

*/


-- bug: 9366921
if l_debug = 'Y' THEN
    activity_rec_count := 1 ;
  gmp_debug_message( ' ----------------------------------------------------- ');
  gmp_debug_message( ' printing material activity ');
  gmp_debug_message( ' ----------------------------------------------------- ');
  OPEN mrp_snapshot_activity;
  LOOP
    FETCH mrp_snapshot_activity INTO activity_rec_tab(activity_rec_count);
  EXIT WHEN mrp_snapshot_activity%NOTFOUND;
         gmp_debug_message(activity_rec_tab(activity_rec_count).row_type || '**'|| activity_rec_tab(activity_rec_count).offset || '**' ||
                          activity_rec_tab(activity_rec_count).new_date || ' ** ' ||
                          activity_rec_tab(activity_rec_count).item_id || '**' || activity_rec_tab(activity_rec_count).org_id || '**' ||
                           activity_rec_tab(activity_rec_count).new_quantity || '**' || activity_rec_tab(activity_rec_count).dos || '**' ||
                           activity_rec_tab(activity_rec_count).cost || '** ' || activity_rec_tab(activity_rec_count).old_quantity);
    activity_rec_count := activity_rec_count + 1 ;
  END LOOP ;
  activity_rec_count := activity_rec_count - 1 ;
  CLOSE mrp_snapshot_activity;
  activity_rec_tab.delete ;
  gmp_debug_message( 'activity_rec_count = '||activity_rec_count);
  gmp_debug_message( ' ----------------------------------------------------- ');
  gmp_debug_message( ' ');
END IF ;


  gmp_debug_message( ' material activity loop starts ');
  gmp_debug_message( ' ----------------------------------------------------- ');

  OPEN mrp_snapshot_activity;
  LOOP
     FETCH mrp_snapshot_activity INTO  activity_rec;

     gmp_debug_message(activity_rec.row_type || '**'|| activity_rec.offset || '**' ||
                          activity_rec.new_date || ' ** ' ||
                          activity_rec.item_id || '**' || activity_rec.org_id || '**' ||
                           activity_rec.new_quantity || '**' || activity_rec.dos || '**' ||
                           activity_rec.cost || '** ' || activity_rec.old_quantity);

--     dbms_output.put_line(activity_rec.offset || '**' ||
--                          activity_rec.new_date || ' ** ' ||
--                          activity_rec.item_id || '**' || activity_rec.org_id || '**' ||
--                           activity_rec.new_quantity || '**' || activity_rec.dos || '**' ||
--                           activity_rec.cost || '** ' || activity_rec.old_quantity);

     IF ((mrp_snapshot_activity%NOTFOUND) OR
        (activity_rec.item_id <> last_item_id) OR
        (activity_rec.org_id  <> last_org_id)) AND
        last_item_id <> -1 THEN

     gmp_debug_message( ' populating details for old Item. Present bucket counter = '|| bucket_counter );

      -- --------------------------
      -- Need to flush the plan for
      -- the previous item.
      -- --------------------------
       IF prev_ss_quantity <> -1
--       AND NOT enterprize_view
       THEN

          /* nsinghi: In the loops below, same safety stock is associated to all the bucket days
          after the current bucket day. */

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP
             add_to_plan(k-1,
                         SS_OFF,
                         prev_ss_quantity);
             add_to_plan(k -1,
                         SS_val_OFF,
                         prev_ss_cost);
             add_to_plan(k -1,
                         SS_dos_OFF,
                         prev_ss_dos);

             IF prev_ssunc_q <> -1
           --   AND NOT enterprize_view
             THEN

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

       IF prev_non_pool_ss <> -1
--          AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1 LOOP
             add_to_plan(k  -1 ,
                        NON_POOL_SS_OFF,
                        prev_non_pool_ss);
          END LOOP;
       END IF;

       IF prev_manf_vari <> -1
--       AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP
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


       IF prev_target_level <> -1
--       AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP
             add_to_plan(k-1,
                      TARGET_SER_OFF,
                      prev_target_level);
          END LOOP;
       END IF;

       IF prev_achieved_level <> -1
--       AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP
             add_to_plan(k-1,
                      ACHIEVED_SER_OFF,
                      prev_achieved_level);
          END LOOP;
       END IF;


       IF prev_mad <> -1
--       AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP

             add_to_plan(k-1,
                      MAD_OFF,
                      prev_mad);
             add_to_plan(k-1,
                      MAPE_OFF,
                      prev_mape);
          END LOOP;
       END IF;

       IF prev_uss_q<> -1
--       AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP
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

       IF prev_uss_dos<> -1
--       AND NOT enterprize_view
       THEN

          FOR k IN bucket_counter..g_num_of_buckets + 1
          LOOP
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

       -- Bug: 8486531 Vpedarla modified the below code with If condition
       --flush_item_plan(last_item_id,
       --               last_org_id);

       FND_FILE.PUT_LINE ( FND_FILE.LOG, ' flushing last item data - '||last_item_id||'*'|| item_rec_count);

       IF (( g_incl_items_no_activity=1 ) or (g_incl_items_no_activity = 2 and item_rec_count>1)) THEN
       flush_item_plan(last_item_id,
                      last_org_id);
       END IF ;  -- Bug: 8486531 end
       item_rec_count := 0;  -- Bug: 8486531 end

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

       target_level := -1;
       achieved_level := -1;
       mad            := -1;
       mape           := -1;

       manf_vari  := -1;
       purc_vari  := -1;
       tran_vari  := -1;
       dmnd_vari  := -1;

        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------
/*        IF enterprize_view or arg_ep_view_also THEN
          FOR counter IN 0..NUM_OF_TYPES LOOP
            ep_bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
*/
--       IF not (enterprize_view) then

       /* nsinghi: Since the item has changed and all the data for the prev item
       has been flushed to GMP_Material_Plan table, so no longer need that
       data. clear the bucket_cells_tab so that the old item's qty do not
       get added to new item txn qty. */

       FOR counter IN 0..(NUM_OF_TYPES * g_num_of_buckets) LOOP
            bucket_cells_tab(counter) := 0;
       END LOOP;
--       END IF;
     END IF;  -- end of activity_rec.item_id <> last_item_id

     EXIT WHEN mrp_snapshot_activity%NOTFOUND;

     item_rec_count := item_rec_count + 1 ; -- Bug: 8486531  Vpedarla

     gmp_debug_message(' item_rec_count ='||item_rec_count);

/*
    IF enterprize_view or arg_ep_view_also THEN
      IF activity_rec.row_type IN (WIP, PO, REQ, TRANSIT,
                                   RECEIVING, PB_SUPPLY) THEN
        add_to_plan(CURRENT_S_OFF + 1, 0, activity_rec.old_quantity,true);
      END IF;
      add_to_plan(activity_rec.offset + 1 , 0,
      activity_rec.new_quantity,true);
    END IF;
*/
--     IF not(enterprize_view) THEN

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
--           init_prev_ss_qty;
           /* For single org, the procedure init_prev_ss_qty is doing only the following steps.
           This call will always be for single org. So removing the procedure. */
           prev_ss_quantity := activity_rec.new_quantity;
           prev_ss_dos := activity_rec.dos;
           prev_ss_cost := activity_rec.cost;

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

     IF activity_rec.row_type = MAD THEN
        mad  := activity_rec.new_quantity;
        mape := activity_rec.old_quantity;

        IF  (bucket_counter <= g_num_of_buckets AND
            activity_rec.new_date < var_dates(bucket_counter)) THEN

           prev_mad   := activity_rec.new_quantity;
           prev_mape  := activity_rec.old_quantity;
        END IF;
     END IF;


     IF activity_rec.row_type = TARGET_SER_LVL THEN
       -- --------------------------
       -- Got a safety stock record.
       -- --------------------------
        target_level := activity_rec.new_quantity;
/*         dbms_output.put_line ('  target value ' || target_level );
         dbms_output.put_line(' bkt counter ' || bucket_counter || 'no of bkts '|| g_num_of_buckets);
         dbms_output.put_line(' var dates ' || var_dates(bucket_counter));
*/
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
/*         dbms_output.put_line ('  target value ' || achieved_level );
         dbms_output.put_line(' bkt counter ' || bucket_counter || 'no of bkts '|| g_num_of_buckets);
         dbms_output.put_line(' var dates ' || var_dates(bucket_counter));
*/
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
      gmp_debug_message( 'off ' || activity_rec.offset ||
                            'num  buckets ' || g_num_of_buckets ||
                            'var_dates date ' || var_dates(bucket_counter) ||
                            'activity_rec date ' || activity_rec.new_date);

        WHILE  (bucket_counter <= g_num_of_buckets AND
           activity_rec.new_date >= var_dates(bucket_counter)) LOOP
--          dbms_output.put_line('in loop - '  || var_dates(bucket_counter));
--        if (bucket_counter > g_num_of_buckets - 50) then
--                    dbms_output.put_line( bucket_counter || ' ' ||
--                          to_char(var_dates(bucket_counter)));
--        end if;
        -- -----------------------------------------------------
        -- If the variable last_ss_quantity is not -1 then there
        -- is a safety stock entry that we need to add for the
        -- current bucket before we move the bucket counter
        -- forward.
        -- -----------------------------------------------------

        /* nsinghi: Once a safety stock value is got, that value needs to be put for all the remaining bucket
        days for that item. Suppose we find safety stock type txn at bucket 10. Suppose that there is
        one more txn remaining for the current item at bucket 14 and the report is for 30 days
        altogether. For bucket 10, the safety stock would already have been inserted. Bucket counter will now be
        at 10. Now when we get another txn for the item at bucket 14, we start moving bucket counter forward.
        But before we move forward, we need to insert safety stock value for buckets 11,12,13 and 14. Inserting
        safety stock for bucket 11,12,13 and 14 taken care by code below. Once after txn for item at bucket 14
        is inserted and the item changes, the code above will insert the safety stock from bucket 14 to 30.
        Whenever safety stock is mentioned, it means any of the txn of safety stock type like SS_OFF, SSunc_OFF,
        NON_POOL_SS_OFF etc which are valid for each day.
        */

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
           END IF;


           IF prev_non_pool_ss <> -1   THEN
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
              add_to_plan(bucket_counter -1,
                           MAPE_OFF,
                           prev_mape);
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

        IF activity_rec.row_type = SS THEN
--           init_prev_ss_qty;
           prev_ss_quantity := activity_rec.new_quantity;
           prev_ss_dos := activity_rec.dos;
           prev_ss_cost := activity_rec.cost;
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

        prev_vari_date := vari_date;

     END IF;

      -- ---------------------------------------------------------
      -- Add the retrieved activity to the plan if it falls in the
      -- current bucket and it is not a safety stock entry.
      -- ---------------------------------------------------------

     /* Since the safety stock is already entered, so no need to enter again. For a non SRO plan (guess it means
     optimized plan) there are only two types of safety stock viz., SS,SS_UNC. For SRO type plan, safety stock
     txn can be all types mentioned below. USS, SS_UNC etc. */

     IF l_plan_type <> SRO_PLAN THEN
       IF  (bucket_counter <= g_num_of_buckets AND
            activity_rec.new_date < var_dates(bucket_counter)) AND
         ( activity_rec.row_type NOT IN (SS,SS_UNC)) THEN
          add_to_plan(bucket_counter - 1,
            activity_rec.offset,
                    activity_rec.new_quantity);
       END IF;
     ELSE
       IF  (bucket_counter <= g_num_of_buckets AND
           activity_rec.new_date < var_dates(bucket_counter)) THEN
          IF (activity_rec.row_type <> USS  AND activity_rec.row_type <> SS_UNC AND activity_rec.row_type <> SS AND
             activity_rec.row_type <> MANU_VARI AND activity_rec.row_type <> TARGET_SER_LVL AND
             activity_rec.row_type <> ACHIEVED_SER_LVL) THEN

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
      --                        G_plan_id);
      --                    fetch standard_cost into l_standard_cost;
      --                    close standard_cost;
      --                    add_to_plan(bucket_counter-1,
      --                        USS_val_OFF,
      --                        activity_rec.new_quantity*l_standard_cost);
      --
      --            end if;
          END IF;
       END IF;
     END IF;

      -- -------------------------------------
      -- Add to the current schedule receipts.
      -- -------------------------------------
     /* nsinghi: everytime a supply type txn is recieved, add it to the schedule recipt list.
     Txns CURRENT_S will store information regarding any scheduled recipt. Since the txns query is
     not sorted based on old_date, so old_date can be greater than or less than bucket_date. So move
     the buckets either forward or backward to get the bucket corresponding to old_date. Hence two loops
     are present, which move the bucket forward and backward. Based on current bucket_date, either of the
     two loops will be the driving loop.

     Txns CURRENT_S will contain the sum of all recipts for that bucket day. */

     IF activity_rec.row_type IN (WIP, PO, REQ, TRANSIT,
                                   RECEIVING, PB_SUPPLY) THEN
       WHILE activity_rec.old_date >= var_dates(old_bucket_counter) AND
             old_bucket_counter <= g_num_of_buckets
       LOOP
          -- ----------
          -- move back.
          -- ----------
          old_bucket_counter := old_bucket_counter + 1;

       END LOOP;

       WHILE activity_rec.old_date < var_dates(old_bucket_counter - 1)  AND
              old_bucket_counter > 2
       LOOP
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
--   END IF;  -- if not enterprise_view
     last_item_id := activity_rec.item_id;
     last_org_id := activity_rec.org_id;
--     last_inst_id := activity_rec.inst_id;
  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 50';
  CLOSE mrp_snapshot_activity;

--  INSERT INTO temp_gmp_horizontal_pdr_gtmp SELECT * FROM gmp_horizontal_pdr_gtmp;

EXCEPTION

  WHEN OTHERS THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in package GMP_HORIZONTAL_PDR_PKG '||sqlerrm);

END populate_horizontal_plan;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    gmp_debug_message                                                    |
REM| DESCRIPTION                                                             |
REM|    This procedure is created to enable more debug messages              |
REM| HISTORY                                                                 |
REM|    Vpedarla Bug: 9366921 created this procedure                         |
REM+=========================================================================+
*/

PROCEDURE gmp_debug_message(pBUFF  IN  VARCHAR2) IS
BEGIN
   IF (l_debug = 'Y') then
        FND_FILE.PUT_LINE ( FND_FILE.LOG,pBUFF);
   END IF;
END gmp_debug_message;


END GMP_HORIZONTAL_PDR_PKG;

/

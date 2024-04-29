--------------------------------------------------------
--  DDL for Package Body MSC_DRP_HORI_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_DRP_HORI_PLAN" AS
 /*  $Header: MSCDRPHB.pls 120.19 2006/11/15 23:35:14 eychen noship $ */

 PURCHASE_ORDER      CONSTANT INTEGER := 1;   /* supply type lookup  */
 PURCH_REQ           CONSTANT INTEGER := 2;
 WORK_ORDER          CONSTANT INTEGER := 3;
 PLANNED_ORDER       CONSTANT INTEGER := 5;
 NONSTD_JOB          CONSTANT INTEGER := 7;
 RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
 INTRANSIT_SHIPMENT  CONSTANT INTEGER := 11;
 INTRANSIT_RECEIPT   CONSTANT INTEGER := 12;
 BEG_ON_HAND         CONSTANT INTEGER := 18;
 PLANNED_ARRIVAL     CONSTANT INTEGER := 51;

 PLANNED_ORDER_DEMAND      CONSTANT INTEGER := 1;   /* demand type lookup  */
 NONSTD_JOB_DEMAND         CONSTANT INTEGER := 2;
 WORK_ORDER_DEMAND         CONSTANT INTEGER := 3;
 EXPIRE_LOT_DEMAND         CONSTANT INTEGER := 5;
 OTHER_INDP_DEMAND         CONSTANT INTEGER := 9;
 HARD_RESERVATION          CONSTANT INTEGER := 10;
 MPS_DEMAND                CONSTANT INTEGER := 12;
 COPIED_SCHED_DEMAND       CONSTANT INTEGER := 15;
 PLANNED_ORDER_SCRAP       CONSTANT INTEGER := 16;
 DISCRETE_JOB_SCRAP        CONSTANT INTEGER := 17;
 PURCHASE_ORDER_SCRAP      CONSTANT INTEGER := 18;
 PURCH_REQ_SCRAP           CONSTANT INTEGER := 19;
 RECEIPT_PO_SCRAP          CONSTANT INTEGER := 20;
 INTRANSIT_SHIPMENT_SCRAP  CONSTANT INTEGER := 23;
 INTER_ORG_DEMAND          CONSTANT INTEGER := 24;
 AGGREGATE_DEMAND          CONSTANT INTEGER := 28;
 FORECAST                  CONSTANT INTEGER := 29;
 SALES_ORDER               CONSTANT INTEGER := 30;
 CONS_KIT_DEMAND           CONSTANT INTEGER := 47;
/* horizontal plan type lookup */

 HZ_EXT_DEMAND          CONSTANT INTEGER := 10; -- calculated
 HZ_EXT_SALES_ORDER     CONSTANT INTEGER := 20;
 HZ_FORECAST            CONSTANT INTEGER := 30;
 HZ_KIT_DEMAND          CONSTANT INTEGER := 40;
 HZ_SHIPMENT            CONSTANT INTEGER := 50;  -- calculated
 HZ_INT_SALES_ORDER     CONSTANT INTEGER := -1;  -- hidden
 HZ_PLANNED_SHIPMENT    CONSTANT INTEGER := -1;  -- hidden
 HZ_EXPIRE_LOT          CONSTANT INTEGER := 370;
 HZ_SCRAP_DEMAND        CONSTANT INTEGER := -1;  -- hidden
 HZ_OTHER_DEMAND        CONSTANT INTEGER := 60;  -- calculated
 HZ_TOTAL_DEMAND        CONSTANT INTEGER := 70;  -- calculated
 HZ_REQUEST_SHIPMENT    CONSTANT INTEGER := 80;
 HZ_UNC_KIT_DEMAND      CONSTANT INTEGER := 90;
 HZ_UNC_SCRAP_DEMAND    CONSTANT INTEGER := -1;  -- hidden
 HZ_UNC_OTHER_DEMAND    CONSTANT INTEGER := 100;
 HZ_TOTAL_UNC_DEMAND    CONSTANT INTEGER := 110;  -- calculated
 HZ_TOTAL_INT_SUPPLY    CONSTANT INTEGER := 120;  -- calculated
 HZ_BEG_ON_HAND         CONSTANT INTEGER := 130;
 HZ_WIP                 CONSTANT INTEGER := 140;
 HZ_RECEIVING           CONSTANT INTEGER := 150;
 HZ_PLANNED_MAKE        CONSTANT INTEGER := 160;
 HZ_TOTAL_EXT_SUPPLY    CONSTANT INTEGER := 170;  -- calculated
 HZ_EXT_TRANSIT         CONSTANT INTEGER := 180;
 HZ_PURCHASE_ORDER      CONSTANT INTEGER := 190;
 HZ_EXT_PURCH_REQ       CONSTANT INTEGER := 200;
 HZ_PLANNED_BUY         CONSTANT INTEGER := 210;
 HZ_ARRIVAL             CONSTANT INTEGER := 220; -- calculated
 HZ_INT_TRANSIT         CONSTANT INTEGER := -1;  -- hidden
 HZ_INT_PURCH_REQ       CONSTANT INTEGER := -1;  -- hidden
 HZ_PLANNED_ARRIVAL     CONSTANT INTEGER := -1;  -- hidden
 HZ_TOTAL_TRANSIT       CONSTANT INTEGER := 230;  -- calculated
 HZ_TOTAL_PURCH_REQ     CONSTANT INTEGER := 240;  -- calculated
 HZ_TOTAL_PLANNED       CONSTANT INTEGER := 250;  -- calculated
 HZ_TOTAL_SUPPLY        CONSTANT INTEGER := 260;  -- calculated
 HZ_CURRENT_S_RECEIPT   CONSTANT INTEGER := 270;  -- calculated
 HZ_POH                 CONSTANT INTEGER := 280;  -- calculated
 HZ_PAB                 CONSTANT INTEGER := 290;  -- calculated
 HZ_UNC_PAB             CONSTANT INTEGER := 300;  -- calculated
 HZ_MAX_QTY             CONSTANT INTEGER := 310;
 HZ_TARGET_QTY          CONSTANT INTEGER := 320;
 HZ_SAFETY_STOCK        CONSTANT INTEGER := 330;
 HZ_INBOUND             CONSTANT INTEGER := 340;
 HZ_OUTBOUND            CONSTANT INTEGER := 350;
 HZ_ATP                 CONSTANT INTEGER := 360;
 HZ_REQUEST_ARRIVAL     CONSTANT INTEGER := 380;
 HZ_EXP_DEMAND          CONSTANT INTEGER := 390;

/* offset */

 EXT_DEMAND_OFF          CONSTANT INTEGER := 1;
 EXT_SALES_ORDER_OFF     CONSTANT INTEGER := 2;
 FORECAST_OFF            CONSTANT INTEGER := 3;
 KIT_DEMAND_OFF          CONSTANT INTEGER := 4;
 SHIPMENT_OFF            CONSTANT INTEGER := 5;
 INT_SALES_ORDER_OFF     CONSTANT INTEGER := 6;  -- hidden
 PLANNED_SHIPMENT_OFF    CONSTANT INTEGER := 7;  -- hidden
 EXPIRE_LOT_OFF          CONSTANT INTEGER := 8;  -- hidden
 SCRAP_DEMAND_OFF        CONSTANT INTEGER := 9;  -- hidden
 OTHER_DEMAND_OFF        CONSTANT INTEGER := 10;
 TOTAL_DEMAND_OFF        CONSTANT INTEGER := 11;
 REQUEST_SHIPMENT_OFF    CONSTANT INTEGER := 12;
 UNC_KIT_DEMAND_OFF      CONSTANT INTEGER := 13;
 UNC_SCRAP_DEMAND_OFF    CONSTANT INTEGER := 14;  -- hidden
 UNC_OTHER_DEMAND_OFF    CONSTANT INTEGER := 15;
 TOTAL_UNC_DEMAND_OFF    CONSTANT INTEGER := 16;
 TOTAL_INT_SUPPLY_OFF    CONSTANT INTEGER := 17;
 BEG_ON_HAND_OFF         CONSTANT INTEGER := 18;
 WIP_OFF                 CONSTANT INTEGER := 19;
 RECEIVING_OFF           CONSTANT INTEGER := 20;
 PLANNED_MAKE_OFF        CONSTANT INTEGER := 21;
 TOTAL_EXT_SUPPLY_OFF    CONSTANT INTEGER := 22;
 EXT_TRANSIT_OFF         CONSTANT INTEGER := 23;
 PURCHASE_ORDER_OFF      CONSTANT INTEGER := 24;
 EXT_PURCH_REQ_OFF       CONSTANT INTEGER := 25;
 PLANNED_BUY_OFF         CONSTANT INTEGER := 26;
 ARRIVAL_OFF             CONSTANT INTEGER := 27;
 INT_TRANSIT_OFF         CONSTANT INTEGER := 28;
 INT_PURCH_REQ_OFF       CONSTANT INTEGER := 29;  -- hidden
 PLANNED_ARRIVAL_OFF     CONSTANT INTEGER := 30;  -- hidden
 TOTAL_TRANSIT_OFF       CONSTANT INTEGER := 31;
 TOTAL_PURCH_REQ_OFF     CONSTANT INTEGER := 32;
 TOTAL_PLANNED_OFF       CONSTANT INTEGER := 33;
 TOTAL_SUPPLY_OFF        CONSTANT INTEGER := 34;
 CURRENT_S_RECEIPT_OFF   CONSTANT INTEGER := 35;
 POH_OFF                 CONSTANT INTEGER := 36;
 PAB_OFF                 CONSTANT INTEGER := 37;
 UNC_PAB_OFF             CONSTANT INTEGER := 38;
 MAX_QTY_OFF             CONSTANT INTEGER := 39;
 TARGET_QTY_OFF          CONSTANT INTEGER := 40;
 SAFETY_STOCK_OFF        CONSTANT INTEGER := 41;
 INBOUND_OFF             CONSTANT INTEGER := 42;
 OUTBOUND_OFF            CONSTANT INTEGER := 43;
 ATP_OFF                 CONSTANT INTEGER := 44;
 REQUEST_ARRIVAL_OFF     CONSTANT INTEGER := 45;
 EXP_DEMAND_OFF          CONSTANT INTEGER := 46;

 NUM_OF_TYPES        CONSTANT INTEGER := 46;

 NO_INT_SHIPMENT    CONSTANT NUMBER := 0;
 NODE_GL_FORECAST_ITEM CONSTANT NUMBER := 6;

 /* global variable for number of buckets to display for the plan */
 g_num_of_buckets	NUMBER;
 g_error_stmt		VARCHAR2(200);

 TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
 TYPE column_char   IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

 Procedure populate_horizontal_plan (
			      arg_query_id IN NUMBER,
			      arg_plan_id IN NUMBER,
                              arg_plan_organization_id IN NUMBER,
                              arg_plan_instance_id IN NUMBER,
                              arg_cutoff_date IN DATE,
                              arg_query_type IN NUMBER) IS

-- -------------------------------------------------
-- This cursor select number of buckets in the plan.
-- -------------------------------------------------
CURSOR plan_buckets IS
SELECT DECODE(arg_plan_id, -1, sysdate, trunc(plan_start_date)),
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

l_plan_start_date	DATE;
l_plan_end_date		DATE;

l_bucket_number		NUMBER := 0;
l_bucket_date		DATE;

last_date       DATE;

CURSOR  drp_snapshot_activity IS
 SELECT
        mfq.number5 item_id,
        mfq.number6 org_id,
        mfq.number3 inst_id,
        DECODE(ms.order_type,
        PURCHASE_ORDER,         PURCHASE_ORDER_OFF,
        PURCH_REQ,
           decode(ms.source_organization_id, null, EXT_PURCH_REQ_OFF,
                                                   INT_PURCH_REQ_OFF),
        WORK_ORDER,             WIP_OFF,
        PLANNED_ARRIVAL,        PLANNED_ARRIVAL_OFF,
        NONSTD_JOB,             WIP_OFF,
        RECEIPT_PURCH_ORDER,    RECEIVING_OFF,
        INTRANSIT_SHIPMENT,
           decode(ms.source_organization_id, null, EXT_TRANSIT_OFF,
                                                   INT_TRANSIT_OFF),
        INTRANSIT_RECEIPT,      RECEIVING_OFF,
        BEG_ON_HAND,          BEG_ON_HAND_OFF,
        PLANNED_ORDER,
          decode(nvl(ms.source_organization_id, ms.organization_id),
                   ms.organization_id,
                   PLANNED_MAKE_OFF,
                   PLANNED_BUY_OFF)
        ) offset,
        DECODE(ms.order_type,
        PURCHASE_ORDER,         CURRENT_S_RECEIPT_OFF,
        PURCH_REQ,              CURRENT_S_RECEIPT_OFF,
        WORK_ORDER,             CURRENT_S_RECEIPT_OFF,
        RECEIPT_PURCH_ORDER,    CURRENT_S_RECEIPT_OFF,
        INTRANSIT_SHIPMENT,     CURRENT_S_RECEIPT_OFF,
        INTRANSIT_RECEIPT,      CURRENT_S_RECEIPT_OFF,
        0 ) offset2,
        decode(ms.order_type,
          PLANNED_ARRIVAL, ms.source_organization_id,
          PURCH_REQ, nvl(ms.source_organization_id, -1),
          INTRANSIT_SHIPMENT, nvl(ms.source_organization_id,-2),
          -1) sub_org_id,
        nvl(ms.firm_date,ms.new_schedule_date) new_date,
        ms.old_schedule_date old_date,
        SUM(DECODE(msi.base_item_id,NULL,
              DECODE(ms.disposition_status_type,2, 0,
                     nvl(ms.firm_quantity,ms.new_order_quantity)),
	      nvl(ms.firm_quantity,ms.new_order_quantity))) new_quantity,
        SUM(NVL(ms.old_order_quantity,0)) quantity1,
        SUM(DECODE(msi.base_item_id,NULL,
              DECODE(ms.disposition_status_type,2, 0,
                     nvl(ms.firm_quantity,ms.new_order_quantity)),
	      nvl(ms.firm_quantity,ms.new_order_quantity)) *
                  nvl(msi.unit_weight,0)) weight,
        SUM(DECODE(msi.base_item_id,NULL,
              DECODE(ms.disposition_status_type,2, 0,
                     nvl(ms.firm_quantity,ms.new_order_quantity)),
	      nvl(ms.firm_quantity,ms.new_order_quantity)) *
                  nvl(msi.unit_volume,0)) volume,
        sum(NVL(ms.old_order_quantity,0)*nvl(msi.unit_weight,0))  quantity2,
        sum(NVL(ms.old_order_quantity,0)*nvl(msi.unit_volume,0))  quantity3
FROM    msc_form_query      mfq,
        msc_system_items msi,
        msc_supplies ms
WHERE   ms.plan_id = msi.plan_id
AND     ms.inventory_item_id = msi.inventory_item_id
AND     ms.organization_id = msi.organization_id
AND     ms.sr_instance_id = msi.sr_instance_id
AND     msi.plan_id = mfq.number4
AND     msi.inventory_item_id = mfq.number1
AND     msi.organization_id = mfq.number2
AND     msi.sr_instance_id = mfq.number3
AND     mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
AND     (arg_query_type <> NO_INT_SHIPMENT or
         (arg_query_type = NO_INT_SHIPMENT and
          ms.order_type <> PLANNED_ARRIVAL and
          not(ms.order_type = PURCH_REQ and ms.source_organization_id is not null)))
GROUP BY
        mfq.number5,
        mfq.number6,
        mfq.number3,
        DECODE(ms.order_type,
        PURCHASE_ORDER,         PURCHASE_ORDER_OFF,
        PURCH_REQ,
           decode(ms.source_organization_id, null, EXT_PURCH_REQ_OFF,
                                                   INT_PURCH_REQ_OFF),
        WORK_ORDER,             WIP_OFF,
        PLANNED_ARRIVAL,        PLANNED_ARRIVAL_OFF,
        NONSTD_JOB,             WIP_OFF,
        RECEIPT_PURCH_ORDER,    RECEIVING_OFF,
        INTRANSIT_SHIPMENT,
           decode(ms.source_organization_id, null, EXT_TRANSIT_OFF,
                                                   INT_TRANSIT_OFF),
        INTRANSIT_RECEIPT,      RECEIVING_OFF,
        BEG_ON_HAND,          BEG_ON_HAND_OFF,
        PLANNED_ORDER,
          decode(nvl(ms.source_organization_id, ms.organization_id),
                   ms.organization_id,
                   PLANNED_MAKE_OFF,
                   PLANNED_BUY_OFF)
        ),
        DECODE(ms.order_type,
        PURCHASE_ORDER,         CURRENT_S_RECEIPT_OFF,
        PURCH_REQ,              CURRENT_S_RECEIPT_OFF,
        WORK_ORDER,             CURRENT_S_RECEIPT_OFF,
        RECEIPT_PURCH_ORDER,    CURRENT_S_RECEIPT_OFF,
        INTRANSIT_SHIPMENT,     CURRENT_S_RECEIPT_OFF,
        INTRANSIT_RECEIPT,      CURRENT_S_RECEIPT_OFF,
        0),
        decode(ms.order_type,
          PLANNED_ARRIVAL, ms.source_organization_id,
          PURCH_REQ, nvl(ms.source_organization_id, -1),
          INTRANSIT_SHIPMENT, nvl(ms.source_organization_id,-2), -1),
        nvl(ms.firm_date,ms.new_schedule_date),
        ms.old_schedule_date
UNION ALL
SELECT  mfq.number5 item_id,
        mfq.number6 org_id,
        mfq.number3 inst_id,
        DECODE(md.origination_type,
            CONS_KIT_DEMAND,      KIT_DEMAND_OFF,
            WORK_ORDER_DEMAND,    UNC_KIT_DEMAND_OFF,
            FORECAST,             FORECAST_OFF,
            SALES_ORDER,
               decode(nvl(md.demand_source_type,2), 2, EXT_SALES_ORDER_OFF,
                                                      INT_SALES_ORDER_OFF),
            PLANNED_ORDER_DEMAND,
               decode(nvl(md.source_organization_id,md.organization_id),
                               md.organization_id,
                               UNC_KIT_DEMAND_OFF,
                               REQUEST_SHIPMENT_OFF),
            EXPIRE_LOT_DEMAND,    EXPIRE_LOT_OFF,
            INTER_ORG_DEMAND,     UNC_OTHER_DEMAND_OFF,
            PLANNED_ORDER_SCRAP,  SCRAP_DEMAND_OFF,
            DISCRETE_JOB_SCRAP,   SCRAP_DEMAND_OFF,
            PURCHASE_ORDER_SCRAP, SCRAP_DEMAND_OFF,
            PURCH_REQ_SCRAP,      SCRAP_DEMAND_OFF,
            RECEIPT_PO_SCRAP,     SCRAP_DEMAND_OFF,
            INTRANSIT_SHIPMENT_SCRAP, SCRAP_DEMAND_OFF,
            OTHER_DEMAND_OFF) offset,
        DECODE(md.origination_type,
            WORK_ORDER_DEMAND,    KIT_DEMAND_OFF,
            SALES_ORDER,   decode(md.demand_source_type, 8,
                                       REQUEST_SHIPMENT_OFF,EXP_DEMAND_OFF),
            FORECAST, EXP_DEMAND_OFF,
            INTER_ORG_DEMAND,     OTHER_DEMAND_OFF,
            0) offset2,
       decode(md.origination_type, SALES_ORDER,
               decode(nvl(md.demand_source_type,2), 8, md.source_organization_id, -1),
                                   PLANNED_ORDER_DEMAND,
               decode(nvl(md.source_organization_id,
                          md.organization_id), md.organization_id,
                               -1,
                              md.source_organization_id),
               -1) sub_org_id,
        nvl(md.firm_date,md.using_assembly_demand_date) new_date,
        nvl(md.old_using_assembly_demand_date,md.using_assembly_demand_date) old_date, -- unconstr date
        SUM(DECODE(md.origination_type,
                29,nvl(md.probability,1)*
                   nvl(md.firm_quantity,md.using_requirement_quantity),
                nvl(md.firm_quantity,md.using_requirement_quantity))) new_quantity,
        SUM(decode(md.origination_type,
                29, nvl(md.unmet_quantity,0),
                30, decode(md.demand_source_type, 8,
                           nvl(old_using_requirement_quantity,0),
                           nvl(md.unmet_quantity,0)),
                using_requirement_quantity)) quantity1, -- unconstrain qty
        SUM(DECODE(md.origination_type,
                29,nvl(md.probability,1)*
                   nvl(md.firm_quantity,md.using_requirement_quantity),
                nvl(md.firm_quantity,md.using_requirement_quantity)) *
                    nvl(msi.unit_weight,0)) weight,
        SUM(DECODE(md.origination_type,
                29,nvl(md.probability,1)*
                   nvl(md.firm_quantity,md.using_requirement_quantity),
                nvl(md.firm_quantity,md.using_requirement_quantity)) *
                   nvl(msi.unit_volume,0)) volume,
        SUM(decode(md.origination_type,
                29, nvl(md.unmet_quantity,0),
                30, decode(md.demand_source_type, 8,
                           nvl(old_using_requirement_quantity,0),
                           nvl(md.unmet_quantity,0)),
                using_requirement_quantity) *
                  nvl(msi.unit_weight,0)) quantity2, -- unconstr weight
        SUM(decode(md.origination_type,
                29, nvl(md.unmet_quantity,0),
                30, decode(md.demand_source_type, 8,
                           nvl(old_using_requirement_quantity,0),
                           nvl(md.unmet_quantity,0)),
                using_requirement_quantity) *
                  nvl(msi.unit_volume,0)) quantity3  -- unconstr volume
FROM    msc_form_query      mfq,
        msc_system_items msi,
        msc_demands  md
WHERE   md.plan_id = mfq.number4
AND     md.inventory_item_id = mfq.number1
AND     md.organization_id = mfq.number2
AND     md.sr_instance_id = mfq.number3
AND     msi.plan_id = md.plan_id
AND     msi.inventory_item_id = md.inventory_item_id
AND     msi.organization_id = md.organization_id
AND     msi.sr_instance_id = md.sr_instance_id
AND     mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
AND     md.organization_id <> -1 -- no global forecast rows
AND     (arg_query_type <> NO_INT_SHIPMENT or
         (arg_query_type = NO_INT_SHIPMENT and
          not(md.origination_type = PLANNED_ORDER_DEMAND and
             nvl(md.source_organization_id,md.organization_id) <> md.organization_id) and
          not(md.origination_type = SALES_ORDER and
             nvl(md.demand_source_type,2) = 8)))
AND     not exists (
        select 'cancelled IR'
        from   msc_supplies mr
        where  md.origination_type = 30
        and    md.disposition_id = mr.transaction_id
        and    md.plan_id = mr.plan_id
        and    md.sr_instance_id = mr.sr_instance_id
        and    mr.disposition_status_type = 2)
GROUP BY
        mfq.number5,
        mfq.number6,
        mfq.number3,
        DECODE(md.origination_type,
            CONS_KIT_DEMAND,      KIT_DEMAND_OFF,
            WORK_ORDER_DEMAND,    UNC_KIT_DEMAND_OFF,
            FORECAST,             FORECAST_OFF,
            SALES_ORDER,
               decode(nvl(md.demand_source_type,2), 2, EXT_SALES_ORDER_OFF,
                                                      INT_SALES_ORDER_OFF),
            PLANNED_ORDER_DEMAND,
               decode(nvl(md.source_organization_id,md.organization_id),
                               md.organization_id,
                               UNC_KIT_DEMAND_OFF,
                               REQUEST_SHIPMENT_OFF),
            EXPIRE_LOT_DEMAND,    EXPIRE_LOT_OFF,
            INTER_ORG_DEMAND,     UNC_OTHER_DEMAND_OFF,
            PLANNED_ORDER_SCRAP,  SCRAP_DEMAND_OFF,
            DISCRETE_JOB_SCRAP,   SCRAP_DEMAND_OFF,
            PURCHASE_ORDER_SCRAP, SCRAP_DEMAND_OFF,
            PURCH_REQ_SCRAP,      SCRAP_DEMAND_OFF,
            RECEIPT_PO_SCRAP,     SCRAP_DEMAND_OFF,
            INTRANSIT_SHIPMENT_SCRAP, SCRAP_DEMAND_OFF,
            OTHER_DEMAND_OFF),
       DECODE(md.origination_type,
            WORK_ORDER_DEMAND,    KIT_DEMAND_OFF,
            SALES_ORDER,   decode(md.demand_source_type, 8,
                                       REQUEST_SHIPMENT_OFF,EXP_DEMAND_OFF),
            FORECAST, EXP_DEMAND_OFF,
            INTER_ORG_DEMAND,     OTHER_DEMAND_OFF,
            0),
       decode(md.origination_type, SALES_ORDER,
               decode(nvl(md.demand_source_type,2), 8, md.source_organization_id, -1),
                                   PLANNED_ORDER_DEMAND,
               decode(nvl(md.source_organization_id,md.organization_id),
                              md.organization_id,
                               -1,
                              md.source_organization_id),
               -1),
        nvl(md.old_using_assembly_demand_date,md.using_assembly_demand_date),
        nvl(md.firm_date,md.using_assembly_demand_date)
UNION ALL -- for planned shipments and outbound in transit
--5084210, pos from purchase order/purchase req with supplier modeled as org
SELECT  mfq.number5 item_id,
        mfq.number6 org_id,
        mfq.number3 inst_id,
        decode(ms.order_type, PLANNED_ARRIVAL, PLANNED_SHIPMENT_OFF,
                              PURCHASE_ORDER,PLANNED_SHIPMENT_OFF,
                              PURCH_REQ,PLANNED_SHIPMENT_OFF,
                              INTRANSIT_SHIPMENT, OUTBOUND_OFF) offset,
        0 offset2,
        ms.organization_id sub_org_id,
        ms.new_ship_date new_date,
        ms.new_ship_date old_date,
        sum(nvl(ms.firm_quantity,ms.new_order_quantity)) new_quantity,
        0 quantity1,
        sum(nvl(ms.firm_quantity,ms.new_order_quantity) *
                nvl(msi.unit_weight,0)) weight,
        sum(nvl(ms.firm_quantity,ms.new_order_quantity) *
                nvl(msi.unit_volume,0)) volume,
        0 quantity2,
        0 quantity3
FROM    msc_system_items msi,
        msc_supplies ms,
        msc_form_query mfq
WHERE   msi.plan_id = ms.plan_id
AND     msi.inventory_item_id = ms.inventory_item_id
AND     msi.organization_id = ms.source_organization_id
AND     msi.sr_instance_id = ms.sr_instance_id
AND     ms.order_type in (PLANNED_ARRIVAL,INTRANSIT_SHIPMENT, PURCHASE_ORDER,PURCH_REQ)
AND     ms.plan_id = mfq.number4
AND     ms.inventory_item_id = mfq.number1
AND     ms.source_organization_id = mfq.number2
AND     ms.sr_instance_id = mfq.number3
AND     mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
AND     arg_query_type <> NO_INT_SHIPMENT
and     ms.source_organization_id <> ms.organization_id
and     (ms.order_type <> PURCH_REQ or
         (ms.order_type = PURCH_REQ and ms.supplier_id is not null))
GROUP BY
        mfq.number5,
        mfq.number6,
        mfq.number3,
        decode(ms.order_type, PLANNED_ARRIVAL, PLANNED_SHIPMENT_OFF,
                              PURCHASE_ORDER,PLANNED_SHIPMENT_OFF,
                              PURCH_REQ,PLANNED_SHIPMENT_OFF,
                              INTRANSIT_SHIPMENT, OUTBOUND_OFF),
        ms.organization_id,
        ms.new_ship_date
UNION ALL -- for requested arrival. in msc_demands, for request shipment
SELECT  mfq.number5 item_id,       -- source_org_id actually store dest org id
        mfq.number6 org_id,        -- while org_id store source org id
        mfq.number3 inst_id,
        REQUEST_ARRIVAL_OFF offset,
        0 offset2,
        md.organization_id sub_org_id,
        nvl(md.firm_date,md.planned_inbound_due_date) new_date,
        nvl(md.firm_date,md.planned_inbound_due_date) old_date,
        sum(nvl(md.firm_quantity,
            nvl(md.old_using_requirement_quantity,md.using_requirement_quantity))) new_quantity,
        0 quantity1,
        sum(nvl(md.firm_quantity,
            nvl(md.old_using_requirement_quantity,md.using_requirement_quantity)) *
            nvl(msi.unit_weight,0)) weight,
        sum(nvl(md.firm_quantity,nvl(md.old_using_requirement_quantity,md.using_requirement_quantity)) *
            nvl(msi.unit_volume,0)) volume,
        0 quantity2,
        0 quantity3
FROM    msc_form_query      mfq,
        msc_system_items msi,
        msc_demands  md
WHERE   md.plan_id = mfq.number4
AND     md.inventory_item_id = mfq.number1
AND     md.source_organization_id = mfq.number2
AND     md.sr_instance_id = mfq.number3
AND     ((md.origination_type = PLANNED_ORDER_DEMAND and
          md.source_organization_id <> md.organization_id ) or
         (md.origination_type = 30 and md.demand_source_type =8 ))
AND     msi.plan_id = md.plan_id
AND     msi.inventory_item_id = md.inventory_item_id
AND     msi.organization_id = md.source_organization_id
AND     msi.sr_instance_id = md.sr_instance_id
AND     mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
AND     arg_query_type <> NO_INT_SHIPMENT
GROUP BY
        mfq.number5,
        mfq.number6,
        mfq.number3,
        REQUEST_ARRIVAL_OFF,
        md.organization_id,
        nvl(md.firm_date,md.planned_inbound_due_date)
UNION ALL
SELECT  mfq.number5 item_id,
        mfq.number6 org_id,
        mfq.number3 inst_id,
        SAFETY_STOCK_OFF offset,
        0 offset2,
        safety.organization_id sub_org_id,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        sum(safety.safety_stock_quantity) new_quantity,
        0 quantity1,
        sum(safety.safety_stock_quantity * nvl(msi.unit_weight,0)) weight,
        sum(safety.safety_stock_quantity * nvl(msi.unit_volume,0)) volume,
        0 quantity2,
        0 quantity3
FROM    msc_safety_stocks    safety,
        msc_system_items msi,
        msc_form_query      mfq
WHERE   trunc(safety.period_start_date) <= last_date
AND     safety.organization_id = mfq.number2
AND     safety.sr_instance_id = mfq.number3
AND     safety.plan_id = mfq.number4
AND     safety.inventory_item_id = mfq.number1
AND     mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
AND     msi.plan_id = safety.plan_id
AND     msi.inventory_item_id = safety.inventory_item_id
AND     msi.organization_id = safety.organization_id
AND     msi.sr_instance_id = safety.sr_instance_id
GROUP BY  mfq.number5,
          mfq.number6,
          mfq.number3,
          safety.period_start_date,
          safety.organization_id
UNION ALL -- for target and max qty
SELECT  mfq.number5 item_id,
        mfq.number6 org_id,
        mfq.number3 inst_id,
        MAX_QTY_OFF offset,
        TARGET_QTY_OFF offset2,
        mil.organization_id sub_org_id,
        mil.inventory_date new_date,
        mil.inventory_date old_date,
        sum(nvl(mil.max_quantity,0)) new_quantity,
        sum(nvl(mil.target_quantity,0)) quantity1,
        sum(nvl(mil.max_quantity,0) * nvl(msi.unit_weight,0)) weight,
        sum(nvl(mil.max_quantity,0) * nvl(msi.unit_volume,0)) volume,
        sum(nvl(mil.target_quantity,0) * nvl(msi.unit_weight,0)) quantity2,
        sum(nvl(mil.target_quantity,0) * nvl(msi.unit_volume,0)) quantity3
FROM    msc_inventory_levels    mil,
        msc_system_items msi,
        msc_form_query      mfq
WHERE   trunc(mil.inventory_date) <= last_date
AND     mil.organization_id = mfq.number2
AND     mil.sr_instance_id = mfq.number3
AND     mil.plan_id = mfq.number4
AND     mil.inventory_item_id = mfq.number1
AND     mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
AND     msi.plan_id = mil.plan_id
AND     msi.inventory_item_id = mil.inventory_item_id
AND     msi.organization_id = mil.organization_id
AND     msi.sr_instance_id = mil.sr_instance_id
GROUP BY mfq.number5,mfq.number6,mfq.number3,
         mil.inventory_date, mil.organization_id
UNION ALL
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  mfq.number5 item_id,
        mfq.number6 org_id,
        mfq.number3 inst_id,
        BEG_ON_HAND_OFF offset,
        0 offset2,
        -1 sub_org_id,
        to_date(1, 'J') new_date,
        to_date(1, 'J') old_date,
        0 new_quantity,
        0 quantity1,
        0 weight,
        0 volume,
        0 quantity2,
        0 quantity3
FROM    msc_form_query mfq
WHERE   mfq.query_id = arg_query_id
AND     mfq.number7 <> NODE_GL_FORECAST_ITEM
ORDER BY
     1, 2, 3,7,8,4,5,6;

TYPE drp_activity IS RECORD
     (item_id      NUMBER,
      org_id       NUMBER,
      inst_id      NUMBER,
      offset       NUMBER,
      offset2       NUMBER,
      sub_org_id   NUMBER,
      new_date     DATE,
      old_date     DATE,
      new_quantity NUMBER,
      quantity1 NUMBER,
      weight NUMBER,
      volume NUMBER,
      quantity2 NUMBER,
      quantity3 NUMBER);

activity_rec     drp_activity;

var_dates           calendar_date;   -- Holds the start dates of buckets
last_item_id        NUMBER := -10;
last_org_id        NUMBER := -10;
last_inst_id        NUMBER := -10;

TYPE bucket_rec_type is RECORD (
quantity number,
weight number,
volume number
);

TYPE row_rec IS TABLE OF bucket_rec_type INDEX BY BINARY_INTEGER;

TYPE header_rec_type is RECORD (
row_type number,
sub_org_id number
);

TYPE header_rec IS TABLE OF header_rec_type INDEX BY BINARY_INTEGER;

row_detail row_rec;  -- non enterprise view
row_header_type column_number;
sub_row_detail row_rec;
sub_row_header header_rec;

bucket_counter BINARY_INTEGER := 0; -- Id of the current bucket
old_bucket_counter BINARY_INTEGER := 0;
counter        BINARY_INTEGER := 0;

PROCEDURE sum_up_ss(offset IN NUMBER,
                        bucket IN NUMBER) IS
  location number;
  v_ss_qty number :=0;
  v_ss_wt number :=0;
  v_ss_vl number :=0;
  i number;
BEGIN
g_error_stmt := 'Debug - sum_up_ss, bkt='||bucket||',offset='||offset;

  location := (offset -1) * (g_num_of_buckets +1) + bucket;
  i := nvl(sub_row_header.last,0);
  FOR a in 1 .. i LOOP
     if sub_row_header(a).row_type= row_header_type(offset) and
        sub_row_header(a).sub_org_id <> -1 then
/*
if sub_row_detail((bucket+(a-1)*g_num_of_buckets)).quantity <> 0 then
dbms_output.put_line(sub_row_header(a).row_type||','||
         sub_row_detail(bucket+(a-1)*g_num_of_buckets).quantity);
end if;
*/
             v_ss_qty := v_ss_qty +
                 sub_row_detail(bucket+(a-1)*g_num_of_buckets).quantity;
             v_ss_wt := v_ss_wt +
                 sub_row_detail(bucket+(a-1)*g_num_of_buckets).weight;
             v_ss_vl := v_ss_vl +
                 sub_row_detail(bucket+(a-1)*g_num_of_buckets).volume;
     end if;
  END LOOP;

  row_detail(location).quantity := v_ss_qty;
  row_detail(location).weight := v_ss_wt;
  row_detail(location).volume := v_ss_vl;

  -- also modify enterprise view

  location := offset * (g_num_of_buckets +1);
  row_detail(location).quantity := v_ss_qty;
  row_detail(location).weight := v_ss_wt;
  row_detail(location).volume := v_ss_vl;

/*
if v_ss_qty <> 0 then
dbms_output.put_line('sum= '||offset||','||location||','||v_ss_qty);
end if;
*/
END sum_up_ss;

FUNCTION get_row_detail(offset IN NUMBER,
                        bucket IN NUMBER,
                        data_type IN NUMBER) RETURN NUMBER IS
  location number;
BEGIN
  location := (offset -1) * (g_num_of_buckets +1) + bucket;
  if data_type = 1 then
     return row_detail(location).quantity;
  elsif data_type = 2 then
     return row_detail(location).weight;
  else
     return row_detail(location).volume;
  end if;

END get_row_detail;

PROCEDURE add_sub_rows(bucket IN NUMBER,
                      offset IN NUMBER,
                      sub_org_id IN NUMBER,
                      quantity IN NUMBER,
                      weight IN NUMBER,
                      volume IN NUMBER) IS
row_exist boolean :=false;
i number;
new_offset number;
row_type number;
location number;
BEGIN
  g_error_stmt := 'Debug - add_sub_rows - 10';

  if offset in (INT_SALES_ORDER_OFF, PLANNED_SHIPMENT_OFF) then
     new_offset := SHIPMENT_OFF;
  elsif offset in (INT_TRANSIT_OFF,INT_PURCH_REQ_OFF,PLANNED_ARRIVAL_OFF) then
     new_offset :=ARRIVAL_OFF;
  else
     new_offset := offset;
  end if;
  row_type := row_header_type(new_offset);

  for a in 1..nvl(sub_row_header.last,0) loop
         if sub_row_header(a).row_type = row_type and
            sub_row_header(a).sub_org_id = sub_org_id then
            row_exist := true;
            i := a;
            exit;
         end if;
   end loop;

   if not(row_exist) then
      -- initialize sub rows first
      i := nvl(sub_row_header.last,0)+1;
      sub_row_header(i).row_type := row_type;
      sub_row_header(i).sub_org_id := sub_org_id;
      for a in 1..g_num_of_buckets loop
          sub_row_detail(a+(i-1)*g_num_of_buckets).quantity :=0;
          sub_row_detail(a+(i-1)*g_num_of_buckets).weight :=0;
          sub_row_detail(a+(i-1)*g_num_of_buckets).volume :=0;
      end loop;
   end if;

   location := (i-1)*g_num_of_buckets+bucket;
if offset in (MAX_QTY_OFF, TARGET_QTY_OFF, SAFETY_STOCK_OFF) then
     -- set the qty for all the buckets after bucket date
--dbms_output.put_line('add: '|| location||','||quantity);
     for a in 0..g_num_of_buckets-bucket loop
         sub_row_detail(a+location).quantity := quantity;
         sub_row_detail(a+location).weight := weight ;
         sub_row_detail(a+location).volume := volume;
     end loop;

else
   sub_row_detail(location).quantity :=
          sub_row_detail(location).quantity + quantity;
   sub_row_detail(location).weight :=
          sub_row_detail(location).weight + weight;
   sub_row_detail(location).volume :=
          sub_row_detail(location).volume + volume;
end if;

END add_sub_rows;


PROCEDURE add_to_plan(bucket IN NUMBER,
                      offset IN NUMBER,
                      quantity IN NUMBER,
                      weight IN NUMBER,
                      volume IN NUMBER) IS
 location number;
BEGIN
  g_error_stmt := 'Debug - add_to_plan, bkt='||bucket||',offset='||offset;
  if quantity = 0 or offset is null or
     offset in (MAX_QTY_OFF, TARGET_QTY_OFF, SAFETY_STOCK_OFF) then
     return;
  end if;

  location := (offset -1) * (g_num_of_buckets +1) + bucket;

/*
  if offset in (MAX_QTY_OFF, TARGET_QTY_OFF, SAFETY_STOCK_OFF) then
     -- set the qty for all the buckets after bucket date
     for a in 0..g_num_of_buckets-bucket loop
         row_detail(a+location).quantity := quantity;
         row_detail(a+location).weight := weight ;
         row_detail(a+location).volume := volume;
     end loop;

  else
*/
     row_detail(location).quantity :=
          row_detail(location).quantity + quantity;
     row_detail(location).weight :=
          row_detail(location).weight + weight;
     row_detail(location).volume :=
          row_detail(location).volume + volume;
--  end if;

  -- to store enterprise view to the last column
  location := offset * (g_num_of_buckets +1);

  if offset in (UNC_PAB_OFF, PAB_OFF, POH_OFF) then
--                MAX_QTY_OFF, TARGET_QTY_OFF, SAFETY_STOCK_OFF) then
     row_detail(location).quantity := quantity;
     row_detail(location).weight := weight;
     row_detail(location).volume := volume;
  else
     row_detail(location).quantity :=
          row_detail(location).quantity + quantity;
     row_detail(location).weight :=
          row_detail(location).weight + weight;
     row_detail(location).volume :=
          row_detail(location).volume + volume;
  end if;
END add_to_plan;

PROCEDURE flush_item_plan(p_item_id IN NUMBER,
                          p_org_id IN NUMBER,
			  p_inst_id IN NUMBER) IS
total_reqs      NUMBER := 0;
lot_quantity NUMBER := 0;
expired_qty NUMBER := 0;
expired_weight NUMBER := 0;
expired_volume NUMBER := 0;

atp_flag NUMBER :=2;
l_atp_qty_net MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atp_weight_net MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atp_volume_net MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
total_supply number;
committed_demand number;

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

  bkt_quantity column_number;
  bkt_weight column_number;
  bkt_volume column_number;
  etp_bkt_quantity column_number;
  etp_bkt_weight column_number;
  etp_bkt_volume column_number;
  etp_bkt_row_type column_number;
  b number := 0;

BEGIN

  g_error_stmt := 'Debug - flush_item_plan - 10';

    OPEN check_atp;
    FETCH check_atp INTO atp_flag;
    CLOSE check_atp;

    FOR a IN 1..g_num_of_buckets LOOP
      g_error_stmt := 'Debug - flush_item_plan - 20 - loop'||a;
      -- ----------------------------
      -- Projected available balance.
      -- ----------------------------
      g_error_stmt := 'Debug - flush_item_plan - 40 - loop'||a;

      IF a = 1 THEN
        add_to_plan(a,
                UNC_PAB_OFF,
                get_row_detail(BEG_ON_HAND_OFF,a,1)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,1)-
                get_row_detail(TOTAL_UNC_DEMAND_OFF,a,1),
                get_row_detail(BEG_ON_HAND_OFF,a,2)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,2)-
                get_row_detail(TOTAL_UNC_DEMAND_OFF,a,2),
                get_row_detail(BEG_ON_HAND_OFF,a,3)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,3)-
                get_row_detail(TOTAL_UNC_DEMAND_OFF,a,3));

        add_to_plan(a,
                PAB_OFF,
                get_row_detail(BEG_ON_HAND_OFF,a,1)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,1)-
                get_row_detail(TOTAL_DEMAND_OFF,a,1),
                get_row_detail(BEG_ON_HAND_OFF,a,2)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,2)-
                get_row_detail(TOTAL_DEMAND_OFF,a,2),
                get_row_detail(BEG_ON_HAND_OFF,a,3)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,3)-
                get_row_detail(TOTAL_DEMAND_OFF,a,3));

      ELSE

        add_to_plan(a,
                UNC_PAB_OFF,
                get_row_detail(UNC_PAB_OFF,a-1,1)+
                get_row_detail(BEG_ON_HAND_OFF,a,1)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,1)-
                get_row_detail(TOTAL_UNC_DEMAND_OFF,a,1),
                get_row_detail(UNC_PAB_OFF,a-1,2)+
                get_row_detail(BEG_ON_HAND_OFF,a,2)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,2)-
                get_row_detail(TOTAL_UNC_DEMAND_OFF,a,2),
                get_row_detail(UNC_PAB_OFF,a-1,3)+
                get_row_detail(BEG_ON_HAND_OFF,a,3)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,3)-
                get_row_detail(TOTAL_UNC_DEMAND_OFF,a,3));
        add_to_plan(a,
                PAB_OFF,
                get_row_detail(PAB_OFF,a-1,1)+
                get_row_detail(BEG_ON_HAND_OFF,a,1)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,1)-
                get_row_detail(TOTAL_DEMAND_OFF,a,1),
                get_row_detail(PAB_OFF,a-1,2)+
                get_row_detail(BEG_ON_HAND_OFF,a,2)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,2)-
                get_row_detail(TOTAL_DEMAND_OFF,a,2),
                get_row_detail(PAB_OFF,a-1,3)+
                get_row_detail(BEG_ON_HAND_OFF,a,3)+
                get_row_detail(TOTAL_SUPPLY_OFF,a,3)-
                get_row_detail(TOTAL_DEMAND_OFF,a,3));
      END IF;

      -- ------------------
      -- Projected on hand.
      -- ------------------
      g_error_stmt := 'Debug - flush_item_plan - 50 - loop'||a;

      IF a = 1 THEN
        add_to_plan(a,
                POH_OFF,
                get_row_detail(BEG_ON_HAND_OFF,a,1)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,1)-
                get_row_detail(TOTAL_DEMAND_OFF,a,1),
                get_row_detail(BEG_ON_HAND_OFF,a,2)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,2)-
                get_row_detail(TOTAL_DEMAND_OFF,a,2),
                get_row_detail(BEG_ON_HAND_OFF,a,3)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,3)-
                get_row_detail(TOTAL_DEMAND_OFF,a,3));
      ELSIF a = 2 THEN
        add_to_plan(a,
                POH_OFF,
                get_row_detail(POH_OFF,a-1,1)+
                get_row_detail(BEG_ON_HAND_OFF,a,1)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,1)-
                get_row_detail(TOTAL_DEMAND_OFF,a,1),
                get_row_detail(POH_OFF,a-1,2)+
                get_row_detail(BEG_ON_HAND_OFF,a,2)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,2)-
                get_row_detail(TOTAL_DEMAND_OFF,a,2),
                get_row_detail(POH_OFF,a-1,3)+
                get_row_detail(BEG_ON_HAND_OFF,a,3)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,3)-
                get_row_detail(TOTAL_DEMAND_OFF,a,3));
      ELSE
        add_to_plan(a,
                POH_OFF,
                get_row_detail(POH_OFF,a-1,1)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,1)-
                get_row_detail(TOTAL_DEMAND_OFF,a,1),
                get_row_detail(POH_OFF,a-1,2)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,2)-
                get_row_detail(TOTAL_DEMAND_OFF,a,2),
                get_row_detail(POH_OFF,a-1,3)+
                get_row_detail(CURRENT_S_RECEIPT_OFF,a,3)-
                get_row_detail(TOTAL_DEMAND_OFF,a,3));
      END IF;

     -- sum up safety stock from each org
      sum_up_ss(SAFETY_STOCK_OFF, a);
      sum_up_ss(MAX_QTY_OFF, a);
      sum_up_ss(TARGET_QTY_OFF, a);

    END LOOP; -- FOR a IN 1..g_num_of_buckets LOOP

    g_error_stmt := 'Debug - flush_item_plan - 60';

    if atp_flag = 1 then -- only calculate atp when atp_flag is 1

       IF  l_atp_qty_net.count = 0 THEN
          l_atp_qty_net.Extend(g_num_of_buckets);
          l_atp_weight_net.Extend(g_num_of_buckets);
          l_atp_volume_net.Extend(g_num_of_buckets);
       END IF;

       FOR  a IN 1..g_num_of_buckets LOOP

             total_supply := get_row_detail(TOTAL_SUPPLY_OFF,a,1)+
                             get_row_detail(BEG_ON_HAND_OFF,a,1);

             committed_demand := get_row_detail(TOTAL_UNC_DEMAND_OFF,a,1) -
                                 get_row_detail(FORECAST_OFF,a,1);

            l_atp_qty_net(a) := total_supply - committed_demand;
            l_atp_weight_net(a) :=
                             (get_row_detail(TOTAL_SUPPLY_OFF,a,2)+
                                get_row_detail(BEG_ON_HAND_OFF,a,2)) -
                             (get_row_detail(TOTAL_UNC_DEMAND_OFF,a,2) -
                                 get_row_detail(FORECAST_OFF,a,2));
            l_atp_volume_net(a) :=
                             (get_row_detail(TOTAL_SUPPLY_OFF,a,3)+
                                get_row_detail(BEG_ON_HAND_OFF,a,3)) -
                             (get_row_detail(TOTAL_UNC_DEMAND_OFF,a,3) -
                                 get_row_detail(FORECAST_OFF,a,3));

     END LOOP;

     msc_atp_proc.atp_consume(l_atp_qty_net, g_num_of_buckets);
     msc_atp_proc.atp_consume(l_atp_weight_net, g_num_of_buckets);
     msc_atp_proc.atp_consume(l_atp_volume_net, g_num_of_buckets);

     FOR      a IN 1..g_num_of_buckets LOOP
              add_to_plan(a, ATP_OFF, l_atp_qty_net(a),
                                      l_atp_weight_net(a),
                                      l_atp_volume_net(a));
     END LOOP;

    END IF;

    g_error_stmt := 'Debug - flush_item_plan - 65';

    FOR a in 1 .. NUM_OF_TYPES LOOP
       if row_header_type(a) <> -1 then
-- only insert the row types which are to be shown in hp
          FOR bkt IN 1..g_num_of_buckets LOOP
            bkt_quantity(bkt) :=
                row_detail(bkt + (a-1)*(g_num_of_buckets+1)).quantity;
            bkt_weight(bkt) :=
                row_detail(bkt + (a-1)*(g_num_of_buckets+1)).weight;
            bkt_volume(bkt) :=
                row_detail(bkt + (a-1)*(g_num_of_buckets+1)).volume;
          END LOOP;

          FORALL bkt IN 1..g_num_of_buckets
          INSERT INTO msc_drp_hori_plans(
             query_id,
             organization_id,
             sr_instance_id,
             inventory_item_id,
             row_type,
             sub_org_id,
             horizontal_plan_type,
             bucket_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             quantity,
             weight,
             volume)
           VALUES (
             arg_query_id,
             p_org_id,
             p_inst_id,
             p_item_id,
             row_header_type(a), -- row_type
             -1, -- sub org id
             1, -- non enterprise view
             var_dates(bkt),
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             bkt_quantity(bkt),
             bkt_weight(bkt),
             bkt_volume(bkt));

       -- construct enterprise data
         b := b+1;
         etp_bkt_quantity(b):=
             row_detail(a*(g_num_of_buckets+1)).quantity;
         etp_bkt_weight(b) :=
             row_detail(a*(g_num_of_buckets+1)).weight;
         etp_bkt_volume(b) :=
             row_detail(a*(g_num_of_buckets+1)).volume;
         etp_bkt_row_type(b) := row_header_type(a);

       end if; -- if row_header_type(a) <> -1 then
     END LOOP; -- FOR a in 1 .. NUM_OF_TYPES LOOP

    g_error_stmt := 'Debug - flush_item_plan - 70 ';

    FOR a in 1 .. nvl(sub_row_header.last,0) LOOP
       FOR bkt IN 1..g_num_of_buckets LOOP
            bkt_quantity(bkt) :=
                sub_row_detail(bkt +(a-1)*(g_num_of_buckets)).quantity;
            bkt_weight(bkt) :=
                sub_row_detail(bkt +(a-1)*(g_num_of_buckets)).weight;
            bkt_volume(bkt) :=
                sub_row_detail(bkt +(a-1)*(g_num_of_buckets)).volume;
       END LOOP;

       FORALL bkt IN 1..g_num_of_buckets
        INSERT INTO msc_drp_hori_plans(
        query_id,
        organization_id,
        sr_instance_id,
        inventory_item_id,
        row_type,
        sub_org_id,
        horizontal_plan_type,
        bucket_date,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        quantity,
        weight,
        volume)
      VALUES (
        arg_query_id,
        p_org_id,
        p_inst_id,
        p_item_id,
        sub_row_header(a).row_type,
        sub_row_header(a).sub_org_id,
        1, -- non enterprise view
        var_dates(bkt),
        SYSDATE,
        -1,
        SYSDATE,
        -1,
        bkt_quantity(bkt),
        bkt_weight(bkt),
        bkt_volume(bkt));
   END LOOP; -- FOR a in 1 .. NUM_OF_TYPES LOOP

    g_error_stmt := 'Debug - flush_item_plan - 80';

   -- insert enterprise data
   FORALL a in 1 .. nvl(etp_bkt_quantity.last, 0)
             INSERT INTO msc_drp_hori_plans(
             query_id,
             organization_id,
             sr_instance_id,
             inventory_item_id,
             row_type,
             sub_org_id,
             horizontal_plan_type,
             bucket_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             quantity,
             weight,
             volume)
           VALUES (
             arg_query_id,
             p_org_id,
             p_inst_id,
             p_item_id,
             etp_bkt_row_type(a), -- row_type
             -1, -- sub org id
             10, -- enterprise view
             SYSDATE, -- bucket date
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             etp_bkt_quantity(a),
             etp_bkt_weight(a),
             etp_bkt_volume(a));

END flush_item_plan;


BEGIN

  g_error_stmt := 'Debug - populate_horizontal_plan - 10';

  OPEN plan_buckets;
  FETCH plan_buckets into l_plan_start_date, l_plan_end_date;
  CLOSE plan_buckets;

  g_num_of_buckets := (l_plan_end_date + 1) - (l_plan_start_date - 1);

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';

  -- Initialize the bucket cells to 0.

          FOR a IN 1..(NUM_OF_TYPES*(g_num_of_buckets +1)) LOOP
               row_detail(a).quantity := 0;
               row_detail(a).weight := 0;
               row_detail(a).volume := 0;
          END LOOP;

  -- associate offset with rowtype

    row_header_type(EXT_DEMAND_OFF) := HZ_EXT_DEMAND;
    row_header_type(EXT_SALES_ORDER_OFF) := HZ_EXT_SALES_ORDER;
    row_header_type(FORECAST_OFF) := HZ_FORECAST;
    row_header_type(KIT_DEMAND_OFF) := HZ_KIT_DEMAND;
    row_header_type(SHIPMENT_OFF) := HZ_SHIPMENT;
    row_header_type(INT_SALES_ORDER_OFF) := HZ_INT_SALES_ORDER;
    row_header_type(PLANNED_SHIPMENT_OFF) := HZ_PLANNED_SHIPMENT;
    row_header_type(EXPIRE_LOT_OFF) := HZ_EXPIRE_LOT;
    row_header_type(SCRAP_DEMAND_OFF) := HZ_SCRAP_DEMAND;
    row_header_type(OTHER_DEMAND_OFF) := HZ_OTHER_DEMAND;
    row_header_type(TOTAL_DEMAND_OFF) := HZ_TOTAL_DEMAND;
    row_header_type(REQUEST_SHIPMENT_OFF) := HZ_REQUEST_SHIPMENT;
    row_header_type(UNC_KIT_DEMAND_OFF) := HZ_UNC_KIT_DEMAND;
    row_header_type(UNC_SCRAP_DEMAND_OFF) := HZ_UNC_SCRAP_DEMAND;
    row_header_type(UNC_OTHER_DEMAND_OFF) := HZ_UNC_OTHER_DEMAND;
    row_header_type(TOTAL_UNC_DEMAND_OFF) := HZ_TOTAL_UNC_DEMAND;
    row_header_type(TOTAL_INT_SUPPLY_OFF) := HZ_TOTAL_INT_SUPPLY;
    row_header_type(BEG_ON_HAND_OFF) := HZ_BEG_ON_HAND;
    row_header_type(WIP_OFF) := HZ_WIP;
    row_header_type(RECEIVING_OFF) := HZ_RECEIVING;
    row_header_type(PLANNED_MAKE_OFF) := HZ_PLANNED_MAKE;
    row_header_type(TOTAL_EXT_SUPPLY_OFF) := HZ_TOTAL_EXT_SUPPLY;
    row_header_type(EXT_TRANSIT_OFF) := HZ_EXT_TRANSIT;
    row_header_type(PURCHASE_ORDER_OFF) := HZ_PURCHASE_ORDER;
    row_header_type(EXT_PURCH_REQ_OFF) := HZ_EXT_PURCH_REQ;
    row_header_type(PLANNED_BUY_OFF) := HZ_PLANNED_BUY;
    row_header_type(ARRIVAL_OFF) := HZ_ARRIVAL;
    row_header_type(INT_TRANSIT_OFF) := HZ_INT_TRANSIT;
    row_header_type(INT_PURCH_REQ_OFF) := HZ_INT_PURCH_REQ;
    row_header_type(PLANNED_ARRIVAL_OFF) := HZ_PLANNED_ARRIVAL;
    row_header_type(TOTAL_TRANSIT_OFF) := HZ_TOTAL_TRANSIT;
    row_header_type(TOTAL_PURCH_REQ_OFF) := HZ_TOTAL_PURCH_REQ;
    row_header_type(TOTAL_PLANNED_OFF) := HZ_TOTAL_PLANNED;
    row_header_type(TOTAL_SUPPLY_OFF) := HZ_TOTAL_SUPPLY;
    row_header_type(CURRENT_S_RECEIPT_OFF) := HZ_CURRENT_S_RECEIPT;
    row_header_type(POH_OFF) := HZ_POH;
    row_header_type(PAB_OFF) := HZ_PAB;
    row_header_type(UNC_PAB_OFF) := HZ_UNC_PAB;
    row_header_type(MAX_QTY_OFF) := HZ_MAX_QTY;
    row_header_type(TARGET_QTY_OFF) := HZ_TARGET_QTY;
    row_header_type(SAFETY_STOCK_OFF) := HZ_SAFETY_STOCK;
    row_header_type(INBOUND_OFF) := HZ_INBOUND;
    row_header_type(OUTBOUND_OFF) := HZ_OUTBOUND;
    row_header_type(ATP_OFF) := HZ_ATP;
    row_header_type(REQUEST_ARRIVAL_OFF) := HZ_REQUEST_ARRIVAL;
    row_header_type(EXP_DEMAND_OFF) := HZ_EXP_DEMAND;

    last_date := arg_cutoff_date;


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
    END LOOP;
    CLOSE bucket_dates;

  g_error_stmt := 'Debug - populate_horizontal_plan - 40';
  bucket_counter := 2;
  old_bucket_counter := 2;
     activity_rec.item_id := 0;
     activity_rec.org_id := 0;
     activity_rec.inst_id := 0;
     activity_rec.offset := 0;
     activity_rec.offset2 := 0;
     activity_rec.sub_org_id := 0;
     activity_rec.new_date := sysdate;
     activity_rec.old_date := sysdate;
     activity_rec.new_quantity := 0;
     activity_rec.quantity1 := 0;
     activity_rec.weight :=0;
     activity_rec.volume :=0;
     activity_rec.quantity2 := 0;
     activity_rec.quantity3 := 0;

  OPEN drp_snapshot_activity;
  LOOP
        FETCH drp_snapshot_activity INTO  activity_rec;
/*
if activity_rec.offset2 in (EXP_DEMAND_OFF) then
dbms_output.put_line(activity_rec.offset||','||activity_rec.sub_org_id||','||
activity_rec.new_date||','||activity_rec.new_quantity||','||activity_rec.quantity1||','||activity_rec.old_date);
end if;
*/
        IF ((drp_snapshot_activity%NOTFOUND) OR
          (activity_rec.item_id <> last_item_id) OR
          (activity_rec.org_id  <> last_org_id) OR
          (activity_rec.inst_id <> last_inst_id)) AND
         last_item_id <> -10 THEN

        flush_item_plan(last_item_id,
                        last_org_id,
                        last_inst_id);

        bucket_counter := 2;
        old_bucket_counter := 2;

        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------

          FOR a IN 1..(NUM_OF_TYPES*(g_num_of_buckets +1)) LOOP
               row_detail(a).quantity := 0;
               row_detail(a).weight := 0;
               row_detail(a).volume := 0;
          END LOOP;

          sub_row_header.delete;
          sub_row_detail.delete;

      END IF;  -- end of activity_rec.item_id <> last_item_id

      EXIT WHEN drp_snapshot_activity%NOTFOUND;

      -- find the correct bucket
      IF activity_rec.new_date >= var_dates(bucket_counter) THEN
        WHILE activity_rec.new_date >= var_dates(bucket_counter) AND
              bucket_counter <= g_num_of_buckets LOOP
          bucket_counter := bucket_counter + 1;
        END LOOP;
      END IF;

      add_to_plan(bucket_counter -1,
                     activity_rec.offset,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);

      if activity_rec.offset in (EXT_SALES_ORDER_OFF, FORECAST_OFF) then
         add_to_plan(bucket_counter -1,
                     EXT_DEMAND_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);

      elsif activity_rec.offset in (INT_SALES_ORDER_OFF,
                                      PLANNED_SHIPMENT_OFF) then
         add_to_plan(bucket_counter -1,
                     SHIPMENT_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);

      elsif activity_rec.offset in (SCRAP_DEMAND_OFF, EXPIRE_LOT_OFF) then
         add_to_plan(bucket_counter -1,
                     OTHER_DEMAND_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
         if activity_rec.offset = SCRAP_DEMAND_OFF then
            add_to_plan(bucket_counter -1,
                     UNC_OTHER_DEMAND_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
         end if;
      end if;

      if activity_rec.offset in (EXT_SALES_ORDER_OFF, FORECAST_OFF,
                                   INT_SALES_ORDER_OFF,PLANNED_SHIPMENT_OFF,
                                   SCRAP_DEMAND_OFF, EXPIRE_LOT_OFF,
                                   KIT_DEMAND_OFF,OTHER_DEMAND_OFF) then

         add_to_plan(bucket_counter -1,
                     TOTAL_DEMAND_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      end if;

      if activity_rec.offset in (EXT_SALES_ORDER_OFF, FORECAST_OFF,
                                   REQUEST_SHIPMENT_OFF,
                                   SCRAP_DEMAND_OFF,
                                   UNC_KIT_DEMAND_OFF,
                                   UNC_OTHER_DEMAND_OFF,
                                   EXP_DEMAND_OFF) then

         add_to_plan(bucket_counter -1,
                     TOTAL_UNC_DEMAND_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      end if;

      if activity_rec.offset in (BEG_ON_HAND_OFF, WIP_OFF,
                                   RECEIVING_OFF, PLANNED_MAKE_OFF) then
         add_to_plan(bucket_counter -1,
                     TOTAL_INT_SUPPLY_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      elsif activity_rec.offset in (EXT_TRANSIT_OFF,PURCHASE_ORDER_OFF,
                                   EXT_PURCH_REQ_OFF, PLANNED_BUY_OFF) then
         add_to_plan(bucket_counter -1,
                     TOTAL_EXT_SUPPLY_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      elsif activity_rec.offset in (INT_TRANSIT_OFF,
                                   INT_PURCH_REQ_OFF, PLANNED_ARRIVAL_OFF) then
         add_to_plan(bucket_counter -1,
                     ARRIVAL_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      end if;

      if activity_rec.offset in (INT_TRANSIT_OFF,EXT_TRANSIT_OFF ) then
         add_to_plan(bucket_counter -1,
                     TOTAL_TRANSIT_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      elsif activity_rec.offset in (INT_PURCH_REQ_OFF,EXT_PURCH_REQ_OFF ) then
         add_to_plan(bucket_counter -1,
                     TOTAL_PURCH_REQ_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      elsif activity_rec.offset in (PLANNED_BUY_OFF,PLANNED_MAKE_OFF,
                                      PLANNED_ARRIVAL_OFF ) then
         add_to_plan(bucket_counter -1,
                     TOTAL_PLANNED_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      end if;

      if activity_rec.offset  in (WIP_OFF,RECEIVING_OFF,PLANNED_MAKE_OFF,
                                   EXT_TRANSIT_OFF,PURCHASE_ORDER_OFF,
                                   EXT_PURCH_REQ_OFF,PLANNED_BUY_OFF,
                                   INT_TRANSIT_OFF,INT_PURCH_REQ_OFF,
                                   PLANNED_ARRIVAL_OFF ) then
         add_to_plan(bucket_counter -1,
                     TOTAL_SUPPLY_OFF,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
      end if;

      if activity_rec.sub_org_id <> -1 then
           add_sub_rows(bucket_counter -1,
                     activity_rec.offset,
                     activity_rec.sub_org_id,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);

          if activity_rec.offset in (INT_TRANSIT_OFF, EXT_TRANSIT_OFF) then
                  add_sub_rows(bucket_counter -1,
                     INBOUND_OFF,
                     activity_rec.sub_org_id,
                     activity_rec.new_quantity,
                     activity_rec.weight,
                     activity_rec.volume);
          end if;
      end if;

      IF activity_rec.offset2 <> 0 then
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
                      activity_rec.offset2,
                      activity_rec.quantity1,
                      activity_rec.quantity2,
                      activity_rec.quantity3);
           if activity_rec.offset2 in (REQUEST_SHIPMENT_OFF,
                                       EXP_DEMAND_OFF) then
              add_to_plan(old_bucket_counter - 1,
                      TOTAL_UNC_DEMAND_OFF,
                      activity_rec.quantity1,
                      activity_rec.quantity2,
                      activity_rec.quantity3);
           elsif activity_rec.offset2 in (KIT_DEMAND_OFF,OTHER_DEMAND_OFF) then
              add_to_plan(old_bucket_counter - 1,
                      TOTAL_DEMAND_OFF,
                      activity_rec.quantity1,
                      activity_rec.quantity2,
                      activity_rec.quantity3);
           end if;
           if activity_rec.sub_org_id <> -1 then
              add_sub_rows(old_bucket_counter - 1,
                      activity_rec.offset2,
                      activity_rec.sub_org_id,
                      activity_rec.quantity1,
                      activity_rec.quantity2,
                      activity_rec.quantity3);
            end if;
        END IF;
      END IF;

    last_item_id := activity_rec.item_id;
    last_org_id := activity_rec.org_id;
    last_inst_id := activity_rec.inst_id;

  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 50';
  CLOSE drp_snapshot_activity;

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
   -- dbms_output.put_line(g_error_stmt);
    raise;

END populate_horizontal_plan;

PROCEDURE dem_priority(p_plan_id number, p_org_id number,
                       p_inst_id number, p_item_id number,
                       p_plan_end_date date,
                       p_query_id number,
                       p_date_string varchar2,
                       p_out_string OUT NOCOPY varchar2) IS

   var_dates calendar_date;
   var_pri column_number;
   var_qty column_number;
   v_number_of_bkt number;
   v_pri number;
   v_qty number;
   p_bkt number := nvl(fnd_profile.value('MSC_DRP_DMD_PRIORITY_BK'), 3);
   i number := 0;
   v_date varchar2(20);
   p_delimeter varchar2(1) := '|';

  CURSOR name_c IS
   select char1, char2
     from msc_form_query
    where query_id = p_query_id
       and number5 = p_item_id
       and number6 = p_org_id
       and number3 = p_inst_id;

  CURSOR priority_c(p_start_date date, p_end_date date) IS
    select distinct md.demand_priority
      from msc_demands md,
           msc_form_query mfq_item,
           msc_plans mp
     where md.plan_id = p_plan_id
       and md.inventory_item_id = mfq_item.number1
       and md.organization_id = mfq_item.number2
       and md.sr_instance_id = mfq_item.number3
       and mfq_item.query_id = p_query_id
       and mfq_item.number5 = p_item_id
       and mfq_item.number6 = p_org_id
       and mfq_item.number3 = p_inst_id
       and mfq_item.number7 <> 6 -- NODE_GL_FORECAST_ITEM
       and ((p_start_date <> trunc(mp.curr_start_date) and
            trunc(md.using_assembly_demand_date) between p_start_date
             and p_end_date) or
             (p_start_date = trunc(mp.curr_start_date) and
              trunc(md.using_assembly_demand_date) <= p_end_date))
       and mp.plan_id = md.plan_id
      order by md.demand_priority ;

  CURSOR demand_c(p_start_date date, p_end_date date) IS
    select md.demand_priority,
           sum(nvl(md.firm_quantity,md.using_requirement_quantity))
      from msc_demands md,
           msc_form_query mfq_item,
           msc_plans mp
     where md.plan_id = p_plan_id
       and md.inventory_item_id = mfq_item.number1
       and md.organization_id = mfq_item.number2
       and md.sr_instance_id = mfq_item.number3
       and mfq_item.number7 <> 6 -- NODE_GL_FORECAST_ITEM
       and mfq_item.query_id = p_query_id
       and mfq_item.number5 = p_item_id
       and mfq_item.number6 = p_org_id
       and mfq_item.number3 = p_inst_id
       and ((p_start_date <> trunc(mp.curr_start_date) and
            trunc(md.using_assembly_demand_date) between p_start_date
             and p_end_date) or
             (p_start_date = trunc(mp.curr_start_date) and
              trunc(md.using_assembly_demand_date) <= p_end_date))
       and mp.plan_id = md.plan_id
      group by md.demand_priority
      order by md.demand_priority;
   p_org varchar2(100);
   p_item varchar2(255);
   p_last_bkt boolean := false;
BEGIN

   OPEN name_c;
   FETCH name_c INTO p_org, p_item;
   CLOSE name_c;

  -- init the dates cells
   for a in 1..(p_bkt*2+2) loop
     v_date := substr(p_date_string, instr(p_date_string, ':', 1, a)+1,
                                     instr(p_date_string, ':', 1, a+1) -
                                     instr(p_date_string, ':', 1, a)-1);
     if v_date <> '-1' then
        i := i +1;
        var_dates(i) := to_date(v_date, 'MM/DD/RRRR');
     else
       if a > p_bkt+1 and not(p_last_bkt) then -- last bucket
          i := i +1;
          var_dates(i) := p_plan_end_date;
          p_last_bkt := true;
       end if;
     end if;
   end loop;

   OPEN priority_c(var_dates(1), var_dates(var_dates.last));
   FETCH priority_c BULK COLLECT INTO var_pri;
   CLOSE priority_c;

   -- init all qty cells with 0

   v_number_of_bkt := var_dates.count -1;
   for a in 1.. v_number_of_bkt loop
       for b in 1.. var_pri.count loop
           var_qty((a-1)*v_number_of_bkt + b) := 0;
       end loop;
   end loop;
   for a in 1..v_number_of_bkt loop
       OPEN demand_c(var_dates(a), var_dates(a+1)-1);
       LOOP
          FETCH demand_c INTO v_pri, v_qty;
          EXIT WHEN demand_c%NOTFOUND;
          for b in 1..var_pri.count loop
              if (v_pri is null and var_pri(b) is null ) or
                 v_pri = var_pri(b) then
                 var_qty((a-1)*v_number_of_bkt + b) := v_qty;
              end if;
          end loop;
       END LOOP;
       CLOSE demand_c;
   end loop;
   -- construct the list

   if var_pri.count = 0 then
      p_out_string := null;
      return;
   end if;

   -- column counts
   p_out_string := p_out_string ||(v_number_of_bkt+3);
   --
   -- first third column header
   p_out_string := p_out_string ||p_delimeter||'Org'||
                                  p_delimeter||'Item'||p_delimeter||'Priority';

   -- column headers -- date fields
   for a in 1.. v_number_of_bkt loop
       p_out_string := p_out_string ||p_delimeter||
                       fnd_date.date_to_displaydate(var_dates(a));
   end loop;

   -- row counts
   p_out_string := p_out_string ||p_delimeter||var_pri.count;
   -- item/org/priority cells
   for b in 1.. var_pri.count loop
       if b = 1 then
          p_out_string := p_out_string ||p_delimeter||p_org;
          p_out_string := p_out_string ||p_delimeter||p_item;
       else
          p_out_string := p_out_string ||p_delimeter||' ';
          p_out_string := p_out_string ||p_delimeter||' ';
       end if;
       if var_pri(b) is null then
          p_out_string := p_out_string ||p_delimeter||' ';
       else
          p_out_string := p_out_string ||p_delimeter||var_pri(b);
       end if;
   end loop;
   -- qty in date cells
   for a in 1.. v_number_of_bkt loop
       for b in 1.. var_pri.count loop
         p_out_string := p_out_string ||p_delimeter||
             fnd_number.number_to_canonical(var_qty((a-1)*v_number_of_bkt + b));
       end loop;
   end loop;

END dem_priority;

END MSC_DRP_HORI_PLAN;

/

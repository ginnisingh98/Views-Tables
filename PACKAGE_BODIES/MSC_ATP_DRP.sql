--------------------------------------------------------
--  DDL for Package Body MSC_ATP_DRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_DRP" AS
/* $Header: MSCATDRB.pls 120.4.12010000.2 2009/05/12 10:50:27 sbnaik ship $  */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'MSC_ATP_DRP';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');


-- Procedure that nets supplies and demands for DRP plan.
PROCEDURE Get_Mat_Avail_Drp (
   p_item_id                 IN NUMBER,
   p_org_id                  IN NUMBER,
   p_instance_id             IN NUMBER,
   p_plan_id                 IN NUMBER,
   p_itf                     IN DATE,
   x_atp_dates               OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys                OUT NoCopy MRP_ATP_PUB.number_arr
                            ) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('********** Begin Get_Mat_Avail_Drp **********');
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp: p_item_id ' || p_item_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp: p_org_id ' || p_org_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp: p_instance_id ' || p_instance_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp: p_plan_id ' || p_plan_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp: p_itf ' || p_itf);
        END IF;

        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
            SELECT
                 TRUNC(DECODE(D.RECORD_SOURCE,
                     2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                        DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) SD_DATE,
                                                 --plan by requestdate,promisedate,scheduledate
                       -1*D.USING_REQUIREMENT_QUANTITY SD_QTY
            FROM        MSC_DEMANDS D
            WHERE       D.PLAN_ID = p_plan_id
            AND         D.SR_INSTANCE_ID = p_instance_id
            AND         D.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND         D.ORGANIZATION_ID = p_org_id
            AND         D.ORIGINATION_TYPE NOT IN(1,4,5,7,8,9,11,15,22,28,29,31,48,49,53)
            AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
                        -- Ignore Plan Order Demand (Requested Outbound)
                        -- and Unconstrained Kit Demand for DRP Plans
                        -- Origination Type 1, 48
            AND         TRUNC(DECODE(D.RECORD_SOURCE,
                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                             NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
              		< TRUNC(NVL(p_itf, DECODE(D.RECORD_SOURCE,
                           2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                       NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) + 1))
                                                 --plan by request date,promise date ,ship date
            UNION ALL
            SELECT
                        TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM        MSC_SUPPLIES S
            WHERE       S.PLAN_ID = p_plan_id
            AND         S.SR_INSTANCE_ID = p_instance_id
            AND         S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND         S.ORGANIZATION_ID = p_org_id
                        -- Exclude Cancelled Supplies 2460645
            AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                        < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1) -- 2859130
                                                 ---bug 1735580
            UNION ALL
            SELECT      -- Net Planned arrival as outbound demand in source org.
                        TRUNC(NVL(S.NEW_SHIP_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        -- Bug 4042808 Outbound Shipments are demands. Firm Supply Date
                        -- does not apply. (Previous Comment -- Firm Date is common across orgs).
                        -1 * NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM        MSC_SUPPLIES S
            WHERE       S.PLAN_ID = p_plan_id
            AND         S.SOURCE_SR_INSTANCE_ID = p_instance_id
            AND         S.SOURCE_ORGANIZATION_ID = p_org_id
            AND         S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND         S.ORDER_TYPE = 51  -- Planned Arrival is a Demand in Source Org
            AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SHIP_DATE))
                        < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SHIP_DATE)) + 1)
        )
        GROUP BY SD_DATE
        ORDER BY SD_DATE; -- bug 8494385

        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Mat_Avail_Drp : Total Row Count ' || x_atp_qtys.COUNT );
          msc_sch_wb.atp_debug('******** Get_Mat_Avail_Drp End ********');
        END IF;


END Get_Mat_Avail_Drp;

-- Procedure that nets supplies and demand details  for DRP plan.
PROCEDURE Get_Mat_Avail_Drp_Dtls (
   p_item_id            IN NUMBER,
   p_request_item_id    IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_itf                IN DATE,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_identifier         IN NUMBER
                                 ) IS

   l_null_num   NUMBER;
   l_null_char  VARCHAR2(1);
   l_null_date  DATE; --bug3814584
   l_sysdate    DATE := sysdate;
   l_user_id    NUMBER := FND_GLOBAL.USER_ID; -- Declare and Define value.
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('********** Begin Get_Mat_Avail_Drp_Dtls **********');
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: p_item_id ' || p_item_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: p_request_item_id ' || p_request_item_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: p_org_id ' || p_org_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: p_instance_id ' || p_instance_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: p_plan_id ' || p_plan_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: p_itf ' || p_itf);
        END IF;

INSERT INTO msc_atp_sd_details_temp (
	ATP_Level,
	Order_line_id,
	Scenario_Id,
	Inventory_Item_Id,
	Request_Item_Id,
	Organization_Id,
	Department_Id,
	Resource_Id,
	Supplier_Id,
	Supplier_Site_Id,
	From_Organization_Id,
	From_Location_Id,
	To_Organization_Id,
	To_Location_Id,
	Ship_Method,
	UOM_code,
	Supply_Demand_Type,
	Supply_Demand_Source_Type,
	Supply_Demand_Source_Type_Name,
	Identifier1,
	Identifier2,
	Identifier3,
	Identifier4,
	Supply_Demand_Quantity,
	Supply_Demand_Date,
	Disposition_Type,
	Disposition_Name,
	Pegging_Id,
	End_Pegging_Id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	ORIG_CUSTOMER_SITE_NAME,--bug3263368
        ORIG_CUSTOMER_NAME, --bug3263368
        ORIG_DEMAND_CLASS, --bug3263368
        ORIG_REQUEST_DATE --bug3263368
     )
  (
    SELECT      p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
		p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		MSC_ATP_PVT.G_ITEM_INFO_REC.UOM_CODE col16,  -- ATP4drp Re-Use Global data.
		1 col17, -- demand
		DECODE(D.ORIGINATION_TYPE, -200, 53, --4686870
                                30,DECODE(NVL(D.DEMAND_SOURCE_TYPE, 2), 8, 54,D.ORIGINATION_TYPE),
                                D.ORIGINATION_TYPE) col18, --4568493
		--D.ORIGINATION_TYPE col18,
                l_null_char col19,
		D.SR_INSTANCE_ID col20,
                l_null_num col21,
		D.DEMAND_ID col22,
		l_null_num col23,
                -1* D.USING_REQUIREMENT_QUANTITY col24,
                TRUNC(DECODE(D.RECORD_SOURCE,
                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                         2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                          NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) col25,
                                          --plan by request date,promise date, schedule date
                l_null_num col26,
                D.ORDER_NUMBER col27,
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		l_user_id,
		l_sysdate,
		l_user_id,
		l_user_id,
		MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                           D.REQUEST_SHIP_DATE) --bug3263368
    FROM
		MSC_DEMANDS D,
		MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE	D.PLAN_ID = p_plan_id
    AND		D.SR_INSTANCE_ID = p_instance_id
    AND 	D.ORGANIZATION_ID = p_org_id
    AND		D.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
    AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
    AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
    AND         D.ORIGINATION_TYPE NOT IN(1,4,5,7,8,9,11,15,22,28,29,31,48,49,52,53) -- ignore copy SO for summary enhancement
                   -- Ignore Plan Order Demand (Requested Outbound)
                   -- and Unconstrained Kit Demand for DRP Plans
                   -- Origination Type 1, 48
    AND         TRUNC(DECODE(D.RECORD_SOURCE,
                   2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                      DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                         NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
    		< TRUNC(NVL(p_itf,
    	            DECODE(D.RECORD_SOURCE,
                      2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                         DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                          2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                         NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) + 1))
                                         --plan by request date, promise date, schedule date
    UNION ALL
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
                p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                MSC_ATP_PVT.G_ITEM_INFO_REC.UOM_CODE col16, -- ATP4drp Re-Use Global data.
                2 col17, -- supply
                DECODE(S.ORDER_TYPE , 2,
                       DECODE(NVL(S.SOURCE_ORGANIZATION_ID, S.ORGANIZATION_ID),
                       S.ORGANIZATION_ID, 2, 53),S.ORDER_TYPE) col18,
                --S.ORDER_TYPE col18, --4568493
                l_null_char col19,
                S.SR_INSTANCE_ID col20,
                l_null_num col21,
                S.TRANSACTION_ID col22,
                l_null_num col23,
		NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) col24,
                TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) col25,
                l_null_num col26,
                --bug 4273652: show order number for planned inbound/outbound shipments
		--DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
		--DECODE(S.ORDER_TYPE, 51, to_char(S.TRANSACTION_ID),S.ORDER_NUMBER) col27,
		--bug4368456 show order number for inbound/outbound shipments and plan orders
		DECODE(S.ORDER_TYPE, 51, to_char(S.TRANSACTION_ID),
		                     5, to_char(S.TRANSACTION_ID),
		                     S.ORDER_NUMBER) col27,
                l_null_num col28,
		l_null_num col29,
		l_sysdate,
		l_user_id,
		l_sysdate,
		l_user_id,
		l_user_id,
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_date  --bug3814584
    FROM
		MSC_SUPPLIES S
    WHERE	S.PLAN_ID = p_plan_id
    AND		S.SR_INSTANCE_ID = p_instance_id
    AND		S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
    AND 	S.ORGANIZATION_ID = p_org_id
    AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
    AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
    AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1)
    UNION ALL   -- Net Planned arrival as outbound demand in source org.
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
                p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                MSC_ATP_PVT.G_ITEM_INFO_REC.UOM_CODE col16,  -- ATP4drp Re-Use Global data.
                1 col17, -- demand in source org.
                DECODE(S.ORDER_TYPE, 51, 53) col18,
                -- Bug 4052808 For Display of Inbound as Planned Outbound Shipment.
                l_null_char col19,
                S.SR_INSTANCE_ID col20,
                l_null_num col21,
                S.TRANSACTION_ID col22,
                l_null_num col23,
		-1 * NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) col24,
                -- Net Planned arrival as outbound demand in source org.
                TRUNC(NVL(S.NEW_SHIP_DATE,S.NEW_SCHEDULE_DATE)) col25,
                        -- Bug 4042808 Outbound Shipments are demands. Firm Supply Date
                        -- does not apply. (Previous Comment -- Firm Date is common across orgs).
                l_null_num col26,
                --bug 4273652: show order number for planned inbound/outbound shipments
		--DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
                DECODE(S.ORDER_TYPE, 51, to_char(S.TRANSACTION_ID),S.ORDER_NUMBER) col27,
                l_null_num col28,
		l_null_num col29,
		l_sysdate,
		l_user_id,
		l_sysdate,
		l_user_id,
		l_user_id,
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_date  --bug3814584
    FROM
		MSC_SUPPLIES S
    WHERE	S.PLAN_ID = p_plan_id
    AND		S.SOURCE_SR_INSTANCE_ID = p_instance_id
    AND 	S.SOURCE_ORGANIZATION_ID = p_org_id
    AND		S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
    AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
    AND         S.ORDER_TYPE = 51  -- Planned Arrival is a Demand in Source Org
    AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
    AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SHIP_DATE))
                < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SHIP_DATE)) + 1)
)
;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Dtls: ' || 'Total Records inserted : ' || SQL%ROWCOUNT);
       msc_sch_wb.atp_debug('******** Get_Mat_Avail_Drp_Dtls End ********');
    END IF;

END Get_Mat_Avail_Drp_Dtls;

-- procedure for full summation of
-- supply/demand for DRP plans.

PROCEDURE LOAD_SD_FULL_DRP(p_plan_id  IN NUMBER,
                           p_sys_date IN DATE)
IS
    l_user_id NUMBER := FND_GLOBAL.USER_ID; -- Declare and Define value.
BEGIN

    msc_util.msc_log('******** LOAD_SD_FULL_DRP Begin ********');
    msc_util.msc_log('LOAD_SD_FULL_DRP  p_plan_id ' || p_plan_id);
    msc_util.msc_log('LOAD_SD_FULL_DRP  p_sys_date ' || p_sys_date);

    INSERT INTO MSC_ATP_SUMMARY_SD (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
   (SELECT  p_plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            SD_DATE,
            sum(sd_qty),
            p_sys_date,
            l_user_id,
            p_sys_date,
            l_user_id
    from   (SELECT  /*+ ORDERED */
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                 2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                    NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) SD_DATE,
                                    --plan by request date, promise date or schedule date -- 2859130
                    -1* D.USING_REQUIREMENT_QUANTITY SD_QTY
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_PLAN_ORGANIZATIONS PO,
                    MSC_DEMANDS D
            WHERE   PO.plan_id          = p_plan_id
            AND     I.PLAN_ID           = PO.PLAN_ID
            AND     I.SR_INSTANCE_ID    = PO.SR_INSTANCE_ID
            AND     I.ORGANIZATION_ID   = PO.ORGANIZATION_ID
            AND     I.ATP_FLAG          = 'Y'
            AND     D.PLAN_ID           = I.PLAN_ID
            AND     D.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     D.ORIGINATION_TYPE NOT IN (1,4,5,7,8,9,11,15,22,28,29,31,48,49,53)
                    -- Ignore Plan Order Demand (Requested Outbound)
                    -- and Unconstrained Kit Demand for DRP Plans
                    -- Origination Type 1, 48
            AND     D.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  /*+ ORDERED */
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_PLAN_ORGANIZATIONS PO,
                    MSC_SUPPLIES S
            WHERE   PO.plan_id          = p_plan_id
            AND     I.PLAN_ID           = PO.PLAN_ID
            AND     I.SR_INSTANCE_ID    = PO.SR_INSTANCE_ID
            AND     I.ORGANIZATION_ID   = PO.ORGANIZATION_ID
            AND     I.ATP_FLAG          = 'Y'
            AND     S.PLAN_ID           = I.PLAN_ID
            AND     S.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            AND     S.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL -- Net Planned arrival as outbound demand in source org.

            SELECT  /*+ ORDERED */
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(NVL(S.NEW_SHIP_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        -- Bug 4042808 Outbound Shipments are demands. Firm Supply Date
                        -- does not apply. (Previous Comment -- Firm Date is common across orgs).
                    -1 * NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_PLAN_ORGANIZATIONS PO,
                    MSC_SUPPLIES S
            WHERE   PO.plan_id          = p_plan_id
            AND     I.PLAN_ID           = PO.PLAN_ID
            AND     I.SR_INSTANCE_ID    = PO.SR_INSTANCE_ID
            AND     I.ORGANIZATION_ID   = PO.ORGANIZATION_ID
            AND     I.ATP_FLAG          = 'Y'
            AND     S.PLAN_ID           = I.PLAN_ID
            AND     S.SOURCE_SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     S.SOURCE_ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     S.ORDER_TYPE = 51  -- Planned Arrival is a Demand in Source Org
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            AND     S.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
           )
    GROUP BY inventory_item_id,organization_id, sr_instance_id, demand_class, sd_date
    );

    msc_util.msc_log('LOAD_SD_FULL_DRP: ' || 'Total Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SD_FULL_DRP End ********');


END LOAD_SD_FULL_DRP;

-- summary enhancement : procedure for net summation of supply/demand
--                       for DRP cases.

PROCEDURE LOAD_SD_NET_DRP  (p_plan_id             IN NUMBER,
                            p_last_refresh_number IN NUMBER,
                            p_new_refresh_number  IN NUMBER,
                            p_sys_date            IN DATE)
IS
    j           pls_integer;
    l_sr_instance_id_tab        MRP_ATP_PUB.number_arr;
    l_organization_id_tab       MRP_ATP_PUB.number_arr;
    l_inventory_item_id_tab     MRP_ATP_PUB.number_arr;
    l_sd_date_tab               MRP_ATP_PUB.date_arr;
    l_sd_quantity_tab           MRP_ATP_PUB.number_arr;
    l_ins_sr_instance_id_tab    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_organization_id_tab   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_inventory_item_id_tab MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_sd_date_tab           MRP_ATP_PUB.date_arr   := MRP_ATP_PUB.date_arr();
    l_ins_sd_quantity_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    l_user_id NUMBER := FND_GLOBAL.USER_ID; -- Declare and Define value.
BEGIN

    msc_util.msc_log('******** LOAD_SD_NET_DRP Begin ********');
    msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'p_last_refresh_number - ' || p_last_refresh_number);
    msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'p_new_refresh_number -  ' || p_new_refresh_number);
    msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'p_plan_id - ' || p_plan_id);
    msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'p_sys_date -  ' || p_sys_date);


    SELECT  sr_instance_id,
            organization_id,
            inventory_item_id,
            SD_DATE,
            sum(sd_qty)
    BULK COLLECT INTO l_sr_instance_id_tab,
                      l_organization_id_tab,
                      l_inventory_item_id_tab,
                      l_sd_date_tab,
                      l_sd_quantity_tab
    from   (SELECT  I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    TRUNC(DECODE(D.RECORD_SOURCE,
                     2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                       2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),
                                            NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) SD_DATE,
                                              --plan by request date, promise date or schedule date
                    decode(D.USING_REQUIREMENT_QUANTITY,            -- Consider unscheduled orders as dummy supplies
                           0, D.OLD_DEMAND_QUANTITY,            -- For summary enhancement
                              -1 * D.USING_REQUIREMENT_QUANTITY)  SD_QTY
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_PLAN_ORGANIZATIONS PO,
                    MSC_DEMANDS D
            WHERE   PO.plan_id          = p_plan_id
            AND     I.PLAN_ID           = PO.PLAN_ID
            AND     I.SR_INSTANCE_ID    = PO.SR_INSTANCE_ID
            AND     I.ORGANIZATION_ID   = PO.ORGANIZATION_ID
            AND     I.ATP_FLAG          = 'Y'
            AND     D.PLAN_ID           = I.PLAN_ID
            AND     D.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     D.ORIGINATION_TYPE NOT IN (1,4,5,7,8,9,11,15,22,28,29,31,48,49,53)
                    -- Ignore Plan Order Demand (Requested Outbound)
                    -- and Unconstrained Kit Demand for DRP Plans
                    -- Origination Type 1, 48
            AND     D.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number

            UNION ALL

            SELECT  I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_PLAN_ORGANIZATIONS PO,
                    MSC_SUPPLIES S
            WHERE   PO.plan_id          = p_plan_id
            AND     I.PLAN_ID           = PO.PLAN_ID
            AND     I.SR_INSTANCE_ID    = PO.SR_INSTANCE_ID
            AND     I.ORGANIZATION_ID   = PO.ORGANIZATION_ID
            AND     I.ATP_FLAG          = 'Y'
            AND     S.PLAN_ID           = I.PLAN_ID
            AND     S.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            AND     S.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
            UNION ALL -- Net Planned arrival as outbound demand in source org.

            SELECT  I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    TRUNC(NVL(S.NEW_SHIP_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        -- Bug 4042808 Outbound Shipments are demands. Firm Supply Date
                        -- does not apply. (Previous Comment -- Firm Date is common across orgs).
                    -1 * NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_PLAN_ORGANIZATIONS PO,
                    MSC_SUPPLIES S
            WHERE   PO.plan_id          = p_plan_id
            AND     I.PLAN_ID           = PO.PLAN_ID
            AND     I.SR_INSTANCE_ID    = PO.SR_INSTANCE_ID
            AND     I.ORGANIZATION_ID   = PO.ORGANIZATION_ID
            AND     I.ATP_FLAG          = 'Y'
            AND     S.PLAN_ID           = I.PLAN_ID
            AND     S.SOURCE_SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     S.SOURCE_ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     S.ORDER_TYPE = 51  -- Planned Arrival is a Demand in Source Org
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            AND     S.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
           )
    GROUP BY inventory_item_id, organization_id, sr_instance_id, sd_date;

    msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'Total Row COUNT := ' || l_inventory_item_id_tab.COUNT);

    IF l_inventory_item_id_tab.COUNT > 0 THEN

        forall j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last
        UPDATE MSC_ATP_SUMMARY_SD
        SET    sd_qty = sd_qty + l_sd_quantity_tab(j),
               last_update_date  = p_sys_date,
               last_updated_by   = l_user_id
        WHERE  plan_id           = p_plan_id
        AND    sr_instance_id    = l_sr_instance_id_tab(j)
        AND    inventory_item_id = l_inventory_item_id_tab(j)
        AND    organization_id   = l_organization_id_tab(j)
        AND    sd_date           = l_sd_date_tab(j);

        msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'After FORALL UPDATE');

        FOR j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last LOOP
            -- Count how many rows were updated for each item.
            msc_util.msc_log('LOAD_SD_NET_DRP: For Item id '|| l_inventory_item_id_tab(j)||': updated '||
                SQL%BULK_ROWCOUNT(j)||' records');
            IF SQL%BULK_ROWCOUNT(j) = 0 THEN
                l_ins_sr_instance_id_tab.EXTEND;
                l_ins_organization_id_tab.EXTEND;
                l_ins_inventory_item_id_tab.EXTEND;
                l_ins_sd_date_tab.EXTEND;
                l_ins_sd_quantity_tab.EXTEND;

                l_ins_sr_instance_id_tab(l_ins_sr_instance_id_tab.LAST)        := l_sr_instance_id_tab(j);
                l_ins_organization_id_tab(l_ins_organization_id_tab.LAST)      := l_organization_id_tab(j);
                l_ins_inventory_item_id_tab(l_ins_inventory_item_id_tab.LAST)  := l_inventory_item_id_tab(j);
                l_ins_sd_date_tab(l_ins_sd_date_tab.LAST)                      := l_sd_date_tab(j);
                l_ins_sd_quantity_tab(l_ins_sd_quantity_tab.LAST)              := l_sd_quantity_tab(j);
            END IF;
        END LOOP;

        msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'l_ins_inventory_item_id_tab.COUNT := ' || l_ins_inventory_item_id_tab.COUNT);

        IF l_ins_inventory_item_id_tab.COUNT > 0 THEN


            forall  j IN l_ins_inventory_item_id_tab.first.. l_ins_inventory_item_id_tab.last
            INSERT  INTO MSC_ATP_SUMMARY_SD (
                    plan_id,
                    sr_instance_id,
                    organization_id,
                    inventory_item_id,
                    demand_class,
                    sd_date,
                    sd_qty,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
            VALUES (p_plan_id,
                    l_ins_sr_instance_id_tab(j),
                    l_ins_organization_id_tab(j),
                    l_ins_inventory_item_id_tab(j),
                    '@@@',
                    l_ins_sd_date_tab(j),
                    l_ins_sd_quantity_tab(j),
                    p_sys_date,
                    l_user_id,
                    p_sys_date,
                    l_user_id);

            msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'After FORALL INSERT');
            msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'Total Records inserted : ' || SQL%ROWCOUNT);

        ELSE
            msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'No records to be inserted');
        END IF;
    ELSE
        msc_util.msc_log('LOAD_SD_NET_DRP: ' || 'No records fetched in the net cursor');
    END IF;

    msc_util.msc_log('******** LOAD_SD_NET_DRP End ********');

-- Exception included here since Array processing happens in this procedure
EXCEPTION
   WHEN OTHERS THEN
            msc_util.msc_log ('LOAD_SD_NET_DRP: ' || 'ERROR , sqlcode= '|| sqlcode);
            msc_util.msc_log ('LOAD_SD_NET_DRP: IN Exception Block in others');
            msc_util.msc_log ('ERROR := ' || SQLERRM);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END LOAD_SD_NET_DRP;

-- Procedure that nets supplies and demands for DRP plan when summary is enabled.
PROCEDURE get_mat_avail_drp_summ (
    p_item_id           IN NUMBER,
    p_org_id            IN NUMBER,
    p_instance_id       IN NUMBER,
    p_plan_id           IN NUMBER,
    p_itf               IN DATE,
    p_refresh_number    IN NUMBER,   -- For summary enhancement
    x_atp_dates         OUT NoCopy MRP_ATP_PUB.date_arr,
    x_atp_qtys          OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('********** Begin Get_Mat_Avail_Drp_Summ **********');
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ: p_item_id ' || p_item_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ: p_org_id ' || p_org_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ: p_instance_id ' || p_instance_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ: p_plan_id ' || p_plan_id);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ: p_itf ' || p_itf);
           msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ: p_refresh_number ' || p_refresh_number);
        END IF;

    -- SQL changed for summary enhancement
    SELECT  SD_DATE, SUM(SD_QTY)
    BULK COLLECT INTO x_atp_dates, x_atp_qtys
    FROM   (
            SELECT  /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                    SD_DATE, SD_QTY
            FROM    MSC_ATP_SUMMARY_SD S
            WHERE   S.PLAN_ID = p_plan_id
            AND     S.SR_INSTANCE_ID = p_instance_id
            AND     S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND     S.ORGANIZATION_ID = p_org_id
            AND     S.SD_DATE < NVL(p_itf, S.SD_DATE + 1)

            UNION ALL

            SELECT  TRUNC(NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)) SD_DATE,--plan by request,promise,schedule date
                    decode(D.USING_REQUIREMENT_QUANTITY,            -- Consider unscheduled orders as dummy supplies
                     0, nvl(D.OLD_DEMAND_QUANTITY,0), --4658238               -- For summary enhancement
                     -1 * D.USING_REQUIREMENT_QUANTITY)  SD_QTY
            FROM    MSC_DEMANDS D,
                    MSC_PLANS P                                     -- For summary enhancement
            WHERE   D.PLAN_ID = p_plan_id
            AND     D.SR_INSTANCE_ID = p_instance_id
            AND     D.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND     D.ORGANIZATION_ID = p_org_id
            AND     D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
            AND     D.ORIGINATION_TYPE NOT IN (1,4,5,7,8,9,11,15,22,28,29,31,48,49,53)
                    -- Ignore Plan Order Demand (Requested Outbound)
                    -- and Unconstrained Kit Demand for DRP Plans
                    -- Origination Type 1, 48
            AND     trunc(NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)) <
            		   trunc(NVL(p_itf, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE) + 1))
            		   --plan by requestdate,promisedate,scheduledate
            AND     P.PLAN_ID = D.PLAN_ID
            AND     (D.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                     OR D.REFRESH_NUMBER = p_refresh_number)

            UNION ALL

            SELECT  TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SUPPLIES S,
                    MSC_PLANS P                                     -- For summary enhancement
            WHERE   S.PLAN_ID = p_plan_id
            AND     S.SR_INSTANCE_ID = p_instance_id
            AND     S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND     S.ORGANIZATION_ID = p_org_id
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            AND     TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1)
            AND     P.PLAN_ID = S.PLAN_ID
            AND     (S.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                     OR S.REFRESH_NUMBER = p_refresh_number)

            UNION ALL -- Net Planned arrival as outbound demand in source org.

            SELECT  TRUNC(NVL(S.NEW_SHIP_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        -- Bug 4042808 Outbound Shipments are demands. Firm Supply Date
                        -- does not apply. (Previous Comment -- Firm Date is common across orgs).
                    -1 * NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SUPPLIES S,
                    MSC_PLANS P                                     -- For summary enhancement
            WHERE   S.PLAN_ID = p_plan_id
            AND     S.SOURCE_SR_INSTANCE_ID = p_instance_id
            AND     S.SOURCE_ORGANIZATION_ID = p_org_id
            AND     S.INVENTORY_ITEM_ID = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     S.ORDER_TYPE = 51  -- Planned Arrival is a Demand in Source Org
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            AND     TRUNC(NVL(S.FIRM_DATE,S.NEW_SHIP_DATE)) < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SHIP_DATE)) + 1)
            AND     P.PLAN_ID = S.PLAN_ID
            AND     (S.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                     OR S.REFRESH_NUMBER = p_refresh_number)
    )
    GROUP BY SD_DATE
    ORDER BY SD_DATE;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Mat_Avail_Drp_Summ : Total Row Count ' || x_atp_qtys.COUNT );
       msc_sch_wb.atp_debug('******** Get_Mat_Avail_Drp_Summ End ********');
    END IF;

END get_mat_avail_drp_summ;

END MSC_ATP_DRP;

/

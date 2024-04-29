--------------------------------------------------------
--  DDL for Package Body MSC_AATP_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_AATP_REQ" AS
/* $Header: MSCRAATB.pls 120.5.12010000.5 2009/08/24 07:06:57 sbnaik ship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_AATP_REQ';

-- INFINITE_NUMBER         CONSTANT NUMBER := 1.0e+10;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Item_Pre_Allocated_Atp(
    p_plan_id           IN  NUMBER,
    p_level             IN  NUMBER,
    p_identifier        IN  NUMBER,
    p_scenario_id       IN  NUMBER,
    p_inventory_item_id IN  NUMBER,
    p_organization_id   IN  NUMBER,
    p_instance_id       IN  NUMBER,
    p_demand_class      IN  VARCHAR2,
    p_request_date      IN  DATE,
    p_insert_flag       IN  NUMBER,
    x_atp_info          OUT NoCopy MRP_ATP_PVT.ATP_Info,
    x_atp_period        OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
    x_atp_supply_demand OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
    p_get_mat_in_rec    IN  MSC_ATP_REQ.get_mat_in_rec,
    p_refresh_number    IN  NUMBER,    -- For summary enhancement
    p_request_item_id   IN  NUMBER,    -- For time_phased_atp
    p_atf_date          IN  DATE)     -- For time_phased_atp
IS
	l_infinite_time_fence_date	DATE;
	l_default_atp_rule_id           NUMBER;
	l_calendar_exception_set_id     NUMBER;
	l_inv_item_id			NUMBER;
	l_null_num  			NUMBER := null;
	l_uom_code			VARCHAR2(3);
	l_null_char    			VARCHAR2(3) := null;
	l_return_status			VARCHAR2(1);
	i				PLS_INTEGER;
	mm				PLS_INTEGER;
	ii                              PLS_INTEGER;
	jj                              PLS_INTEGER;
	j				PLS_INTEGER;
	k				PLS_INTEGER;
	l_current_atp			MRP_ATP_PVT.ATP_Info;

	-- time_phased_atp
	l_time_phased_atp               VARCHAR2(1) := 'N';
	l_pf_item_id			NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('******* Item_Pre_Allocated_Atp *******');
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_plan_id =' || p_plan_id );
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_level =' || p_level );
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_identifier =' || p_identifier);
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_scenario_id =' || p_scenario_id);
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_inventory_item_id =' || p_inventory_item_id);
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_organization_id =' || p_organization_id);
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_instance_id =' || p_instance_id);
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_demand_class =' || p_demand_class);
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_request_date =' || p_request_date );
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_insert_flag =' || p_insert_flag );
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_request_item_id =' || p_request_item_id );
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_atf_date =' || p_atf_date );
    END IF;

    -- This procedure will only deal with the requested demand class.

    -- Logic
    -- Step 1:
    -- 	FOR demand class DCi (p_demand_class), we need to
    --  	1. get the net daily availability. Two scenarios are handled:
    --       summary of availability or supply-demand details .
    -- Step 2:
    --    do accumulation for the requested demand class
    --    Forward and Backward consumption and Accumulation done together.

    -- The result is that ATP_Info, ATP_Period_Typ and ATP_Supply_Demand_Typ
    -- related data is populated.

    /* time_phased_atp changes begin*/
    IF (p_inventory_item_id <> p_request_item_id and p_atf_date is not null) THEN
        l_time_phased_atp := 'Y';
        l_pf_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.product_family_id;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Time Phased ATP = ' || l_time_phased_atp );
    END IF;

    /*
    BEGIN
        SELECT inventory_item_id, uom_code
        INTO   l_inv_item_id, l_uom_code
        FROM   msc_system_items
        WHERE  plan_id = p_plan_id
        AND    sr_instance_id = p_instance_id
        AND    organization_id = p_organization_id
        AND    sr_inventory_item_id = p_inventory_item_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error selecting uom_code for the item');
            END IF;
    END;*/
    l_inv_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.inventory_item_id;
    l_uom_code := MSC_ATP_PVT.G_ITEM_INFO_REC.uom_code;
    -- time_phased_atp changes end

    -- get the infinite time fence date if it exists
    --diag_atp
    IF p_scenario_id = -1 THEN
        l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(
                                                p_instance_id, p_inventory_item_id,
                                                p_organization_id, p_plan_id);
    ELSE
        l_infinite_time_fence_date := p_get_mat_in_rec.infinite_time_fence_date;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'infinite fence : ' || l_infinite_time_fence_date);
    END IF;

    -- get the daily net availability for DCi
    IF (NVL(p_insert_flag, 0) = 0  ) THEN
        -- we don't want details
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'p_insert_flag : 0');
        END IF;

        IF MSC_ATP_PVT.G_SUMMARY_SQL = 'Y' THEN -- For summary enhancement
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'MSC_ATP_PVT.G_SUMMARY_SQL := ' || MSC_ATP_PVT.G_SUMMARY_SQL);
            END IF;

            -- time_phased_atp
            IF l_time_phased_atp = 'N' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                END IF;

                -- SQL changed for summary enhancement
                SELECT  SD_DATE,
                        SUM(SD_QTY)
                BULK COLLECT INTO
                        l_current_atp.atp_period,
                        l_current_atp.atp_qty
                FROM
                    (
                        SELECT  /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                                SD_DATE, SD_QTY
                        FROM    MSC_ATP_SUMMARY_SD S
                        WHERE   S.PLAN_ID = p_plan_id
                        AND     S.SR_INSTANCE_ID = p_instance_id
                        AND     S.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     S.ORGANIZATION_ID = p_organization_id
                        AND     S.DEMAND_CLASS = NVL(p_demand_class, S.DEMAND_CLASS)
                        AND     S.SD_DATE < l_infinite_time_fence_date

                        UNION ALL

                        SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                                decode(AD.ALLOCATED_QUANTITY,           -- Consider unscheduled orders as dummy supplies
                                       0,NVL(AD.OLD_ALLOCATED_QUANTITY,0),        -- For summary enhancement --5283809
                                          -1 * AD.ALLOCATED_QUANTITY) SD_QTY
                        FROM    MSC_ALLOC_DEMANDS AD,
                                MSC_PLANS P                             -- For summary enhancement
                        WHERE   AD.PLAN_ID = p_plan_id
                        AND     AD.SR_INSTANCE_ID = p_instance_id
                        AND     AD.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     AD.ORGANIZATION_ID = p_organization_id
                        AND     AD.DEMAND_CLASS = NVL(p_demand_class, AD.DEMAND_CLASS)
                        AND     TRUNC(AD.DEMAND_DATE) < l_infinite_time_fence_date
                        AND     P.PLAN_ID = AD.PLAN_ID
                        AND     (AD.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                                OR AD.REFRESH_NUMBER = p_refresh_number)
                        -- since repetitive schedule demand is not supported in this case
                        -- join to msc_calendar_dates is not needed.

                        UNION ALL

                        SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                                decode(SA.ALLOCATED_QUANTITY,           -- Consider deleted stealing records as dummy demands
                                       0, -1 * (NVL(OLD_ALLOCATED_QUANTITY,0)),   -- For summary enhancement --5283809
                                          SA.ALLOCATED_QUANTITY) SD_QTY
                        FROM    MSC_ALLOC_SUPPLIES SA,
                                MSC_PLANS P                                     -- For summary enhancement
                        WHERE   SA.PLAN_ID = p_plan_id
                        AND     SA.SR_INSTANCE_ID = p_instance_id
                        AND     SA.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     SA.ORGANIZATION_ID = p_organization_id
                        AND     SA.DEMAND_CLASS = NVL(p_demand_class, SA.DEMAND_CLASS)
                        AND     TRUNC(SA.SUPPLY_DATE) < l_infinite_time_fence_date
                        AND     P.PLAN_ID = SA.PLAN_ID
                        AND     (SA.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                                OR SA.REFRESH_NUMBER = p_refresh_number)
                    )
                GROUP BY SD_DATE
                ORDER BY SD_DATE;--4698199

            ELSE -- IF Not_PF_Case THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                END IF;

                MSC_ATP_PF.Item_Prealloc_Avail_Pf_Summ(
                        l_inv_item_id,
                        l_pf_item_id,
                        p_organization_id,
                        p_instance_id,
                        p_plan_id,
                        p_demand_class,
                        l_infinite_time_fence_date,
                        p_refresh_number,
                        l_current_atp.atp_period,
                        l_current_atp.atp_qty,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Item_Prealloc_Avail_Pf_Summ');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF; -- IF Not_PF_Case THEN


        ELSE    -- IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN -- For summary enhancement

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'MSC_ATP_PVT.G_SUMMARY_SQL := ' || MSC_ATP_PVT.G_SUMMARY_SQL);
            END IF;

            -- time_phased_atp
            IF l_time_phased_atp = 'N' THEN
                SELECT 	SD_DATE,
                        SUM(SD_QTY)
                BULK COLLECT INTO
                        l_current_atp.atp_period,
                        l_current_atp.atp_qty
                FROM (
                        SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                        -1 * AD.ALLOCATED_QUANTITY SD_QTY
                        FROM    MSC_ALLOC_DEMANDS AD
                        WHERE   AD.PLAN_ID = p_plan_id
                        AND	    AD.SR_INSTANCE_ID = p_instance_id
                        AND	    AD.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     AD.ORGANIZATION_ID = p_organization_id
                        AND     AD.DEMAND_CLASS = NVL(p_demand_class, AD.DEMAND_CLASS)
                        AND     TRUNC(AD.DEMAND_DATE) < l_infinite_time_fence_date
                        -- since repetitive schedule demand is not supported in this case
                        -- join to msc_calendar_dates is not needed.
                        UNION ALL
                        SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                                SA.ALLOCATED_QUANTITY SD_QTY
                        FROM    MSC_ALLOC_SUPPLIES SA
                        WHERE   SA.PLAN_ID = p_plan_id
                        AND	    SA.SR_INSTANCE_ID = p_instance_id
                        AND	    SA.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     SA.ORGANIZATION_ID = p_organization_id
                        AND     SA.ALLOCATED_QUANTITY <> 0
                        AND     SA.DEMAND_CLASS = NVL(p_demand_class, SA.DEMAND_CLASS)
                        -- fixed as part of time_phased_atp chagnes
                        AND     TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                        AND     TRUNC(SA.SUPPLY_DATE) < l_infinite_time_fence_date
                )
                GROUP BY SD_DATE
                ORDER BY SD_DATE;--4698199
            ELSE -- IF Not_PF_Case THEN
                MSC_ATP_PF.Item_Prealloc_Avail_Pf(
                        l_inv_item_id,
                        l_pf_item_id,
                        p_organization_id,
                        p_instance_id,
                        p_plan_id,
                        p_demand_class,
                        l_infinite_time_fence_date,
                        l_current_atp.atp_period,
                        l_current_atp.atp_qty,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Item_Prealloc_Avail_Pf');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF; -- IF Not_PF_Case THEN

        END IF; -- IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN -- For summary enhancement

    ELSE -- IF (NVL(p_insert_flag, 0) = 0  ) THEN
       -- IF (NVL(p_insert_flag, 0) <> 0  )
       -- OR p_scenario_id = -1
       -- get the details
        MSC_ATP_DB_UTILS.Clear_SD_Details_Temp();

        -- time_phased_atp
        IF l_time_phased_atp = 'Y' THEN
                MSC_ATP_PF.Item_Prealloc_Avail_Pf_Dtls(
                        l_inv_item_id,
                        l_pf_item_id,
                        p_request_item_id,
                        p_inventory_item_id,
                        p_organization_id,
                        p_instance_id,
                        p_plan_id,
                        p_demand_class,
                        l_infinite_time_fence_date,
                        p_atf_date,
                        p_level,
                        p_identifier,
                        p_scenario_id,
                        l_uom_code,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Item_Prealloc_Avail_Pf_Dtls');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        ELSE -- IF Not_PF_Case THEN
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
                        Allocated_Quantity, -- fixed as part of time_phased_atp
        		Supply_Demand_Quantity,
        		Supply_Demand_Date,
        		Disposition_Type,
        		Disposition_Name,
        		Pegging_Id,
        		End_Pegging_Id,
                        Pf_Display_Flag,
                        Original_Demand_Quantity,
                        Original_Demand_Date,
                        Original_Item_Id,
                        Original_Supply_Demand_Type,
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
                   SELECT   p_level col1,
        		    p_identifier col2,
                            p_scenario_id col3,
                            p_inventory_item_id col4 ,
                            p_request_item_id col5,
        		    p_organization_id col6,
                            l_null_num col7,
                            l_null_num col8,
                            l_null_num col9,
                            l_null_num col10,
                            l_null_num col11,
                            l_null_num col12,
                            l_null_num col13,
                            l_null_num col14,
        		    l_null_char col15,
        		    l_uom_code col16,
        		    1 col17, -- demand
        		    --AD.ORIGINATION_TYPE col18,
        		    DECODE(AD.ORIGINATION_TYPE, -100, 30,AD.ORIGINATION_TYPE)  col18, --5027568
                            l_null_char col19,
        		    AD.SR_INSTANCE_ID col20,
                            l_null_num col21,
        		    AD.PARENT_DEMAND_ID col22,
        		    l_null_num col23,
                            -1 * AD.ALLOCATED_QUANTITY col24,
                            -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY), -- fixed as part of time_phased_atp
        		    TRUNC(AD.DEMAND_DATE) col25,
                            l_null_num col26,
                            AD.ORDER_NUMBER col27,
                            l_null_num col28,
                            l_null_num col29,
                            AD.Pf_Display_Flag,
                            -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY),
                            AD.Original_Demand_Date,
                            AD.Original_Item_Id,
                            AD.Original_Origination_Type
        		  , sysdate
        		  , FND_GLOBAL.USER_ID
        		  , sysdate
        		  , FND_GLOBAL.USER_ID
        		  , FND_GLOBAL.USER_ID,
        		    MTPS.LOCATION,   --bug3263368
                            MTP.PARTNER_NAME, --bug3263368
                            AD.DEMAND_CLASS, --bug3263368
                            AD.REQUEST_DATE --bug3263368

                   FROM     MSC_ALLOC_DEMANDS AD,
                            MSC_TRADING_PARTNERS    MTP,--bug3263368
                            MSC_TRADING_PARTNER_SITES    MTPS --bug3263368

                   WHERE    AD.PLAN_ID = p_plan_id
                   AND      AD.SR_INSTANCE_ID = p_instance_id
                   AND      AD.INVENTORY_ITEM_ID = l_inv_item_id
                   AND      AD.ORGANIZATION_ID = p_organization_id
                   AND      AD.DEMAND_CLASS = NVL(p_demand_class, AD.DEMAND_CLASS )
                   AND      AD.ORIGINATION_TYPE <> 52
                   AND      TRUNC(AD.DEMAND_DATE) < l_infinite_time_fence_date
                   AND      AD.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
                   AND      AD.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368

                    -- since repetitive schedule demand is not supported in this case
                    -- join to msc_calendar_dates is not needed.
              UNION ALL
                   SELECT   p_level col1,
                            p_identifier col2,
                            p_scenario_id col3,
                            p_inventory_item_id col4 ,
                            p_request_item_id col5,
                            p_organization_id col6,
                            l_null_num col7,
                            l_null_num col8,
                            l_null_num col9,
                            l_null_num col10,
                            l_null_num col11,
                            l_null_num col12,
                            l_null_num col13,
                            l_null_num col14,
                            l_null_char col15,
                            l_uom_code col16,
                            2 col17, -- supply
                            SA.ORDER_TYPE col18,
                            l_null_char col19,
                            SA.SR_INSTANCE_ID col20,
                            l_null_num col21,
                            SA.PARENT_TRANSACTION_ID col22,
                            l_null_num col23,
                            SA.ALLOCATED_QUANTITY col24,
                            NVL(SA.Supply_Quantity, SA.ALLOCATED_QUANTITY), -- fixed as part of time_phased_atp
                            TRUNC(SA.SUPPLY_DATE) col25,
                            l_null_num col26,
                            DECODE(SA.ORDER_TYPE, 5, to_char(SA.PARENT_TRANSACTION_ID), SA.ORDER_NUMBER) col27,
                            -- Bug 2771075. For Planned Orders, we will populate transaction_id
        		    -- in the disposition_name column to be consistent with Planning.
                            l_null_num col28,
        		    l_null_num col29,
                            l_null_num,
                            l_null_num,
                            to_date(null),
                            SA.Original_Item_Id,
                            SA.Original_Order_Type
        		  , sysdate
        		  , FND_GLOBAL.USER_ID
        		  , sysdate
        		  , FND_GLOBAL.USER_ID
        		  , FND_GLOBAL.USER_ID,
                       	    MTPS.LOCATION,   --bug3684383
                            MTP.PARTNER_NAME, --bug3684383
                            SA.DEMAND_CLASS, --bug3684383
                            null --bug3684383

                   FROM     MSC_ALLOC_SUPPLIES SA,
                            MSC_TRADING_PARTNERS    MTP,--bug3684383
                            MSC_TRADING_PARTNER_SITES    MTPS --bug3684383
                   WHERE    SA.PLAN_ID = p_plan_id
                   AND      SA.SR_INSTANCE_ID = p_instance_id
                   AND      SA.INVENTORY_ITEM_ID = l_inv_item_id
                   AND      SA.ORGANIZATION_ID = p_organization_id
                   AND      SA.ALLOCATED_QUANTITY <> 0
                   AND      SA.DEMAND_CLASS = NVL(p_demand_class, SA.DEMAND_CLASS )
                   -- fixed as part of time_phased_atp chagnes
                   AND      TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                   AND      TRUNC(SA.SUPPLY_DATE) < l_infinite_time_fence_date
                   AND      SA.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3684383
                   AND      SA.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3684383
                  );
        END IF; -- IF Not_PF_Case THEN

     -- for period ATP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'after selecting sd data into msc_atp_sd_details_temp');
        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'count : ' || SQL%ROWCOUNT);
     END IF;

     -- time_phased_atp
     IF l_time_phased_atp='Y' THEN
        MSC_ATP_PF.Get_Period_Data_From_Sd_Temp(x_atp_period, l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Get_Period_Data_From_Sd_Temp');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
     ELSE
        --MSC_ATP_PROC.get_period_data_from_SD_temp(x_atp_period);
        /* time_phased_atp
           call new procedure to fix the issue of not displaying correct quantities in ATP SD Window when
           user opens ATP SD window from ATP pegging in allocated scenarios*/
        MSC_ATP_PROC.Get_Alloc_Data_From_Sd_Temp(x_atp_period, l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Get_Alloc_Data_From_Sd_Temp');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     l_current_atp.atp_period := x_atp_period.Period_Start_Date;
     l_current_atp.atp_qty := x_atp_period.Period_Quantity;

    END IF; -- NVL(p_insert_flag, 0) = 0

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'right after the big query');
       mm := l_current_atp.atp_qty.FIRST;

       WHILE mm is not null LOOP
          msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'l_current_atp.atp_period:atp_qty = '||
             l_current_atp.atp_period(mm) ||' : '|| l_current_atp.atp_qty(mm));
          mm := l_current_atp.atp_qty.Next(mm);
       END LOOP;
    END IF;

    -- Do backward consumption, forward consumption and accumulation
    -- as a single step process for DCi
    -- time_phased_atp
    IF l_time_phased_atp = 'Y' THEN
            MSC_ATP_PF.pf_atp_consume(
                   l_current_atp.atp_qty,
                   l_return_status,
                   l_current_atp.atp_period,
                   MSC_ATP_PF.Bw_Fw_Cum, --b/w, f/w consumption and accumulation
                   p_atf_date);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Pf_Atp_Consume');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
    ELSE
            MSC_ATP_PROC.Atp_Consume(l_current_atp.atp_qty, l_current_atp.atp_qty.COUNT);
    END IF;

    /* Cum drop issue changes begin*/
    MSC_AATP_PROC.Atp_Remove_Negatives(l_current_atp.atp_qty, l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Atp_Remove_Negatives');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    /* Cum drop issue changes end*/

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'right after the ATP consume');
       mm := l_current_atp.atp_qty.FIRST;

       WHILE mm is not null LOOP
          msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'l_current_atp.atp_period and atp_qty = '||
             l_current_atp.atp_period(mm) ||' : '|| l_current_atp.atp_qty(mm));
          mm := l_current_atp.atp_qty.Next(mm);
       END LOOP;
    END IF;

  x_atp_info := l_current_atp;

  IF l_infinite_time_fence_date IS NOT NULL THEN
      -- add one more entry to indicate infinite time fence date and quantity.
      x_atp_info.atp_qty.EXTEND;
      --x_atp_info.limit_qty.EXTEND;
      x_atp_info.atp_period.EXTEND;

      i := x_atp_info.atp_qty.COUNT;
      x_atp_info.atp_period(i) := l_infinite_time_fence_date;
      x_atp_info.atp_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;
      --x_atp_info.limit_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;

      IF NVL(p_insert_flag, 0) <> 0 THEN
        -- add one more entry to indicate infinite time fence date and quantity.
        x_atp_period.Cumulative_Quantity := x_atp_info.atp_qty;

	MSC_ATP_PROC.add_inf_time_fence_to_period(
			p_level,
			p_identifier,
			p_scenario_id,
			p_inventory_item_id,
			p_inventory_item_id,
			p_organization_id,
			null,  -- p_supplier_id
			null,  -- p_supplier_site_id
			l_infinite_time_fence_date,
			x_atp_period
	);
      END IF;
  END IF;

END Item_Pre_Allocated_Atp;


PROCEDURE Atp_Alloc_Consume(
        p_atp_qty         IN OUT  NoCopy MRP_ATP_PUB.number_arr,
	p_atp_dc_tab	  IN	  MRP_ATP_PUB.char80_arr,
	x_dc_list_tab	  OUT	  NoCopy MRP_ATP_PUB.char80_arr,
	x_dc_start_index  OUT	  NoCopy MRP_ATP_PUB.number_arr,
	x_dc_end_index    OUT	  NoCopy MRP_ATP_PUB.number_arr)
IS
i NUMBER;
j NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********Begin Atp_Alloc_Consume Procedure************');
    END IF;

    x_dc_list_tab := MRP_ATP_PUB.Char80_Arr();
    x_dc_start_index := MRP_ATP_PUB.Number_Arr();
    x_dc_end_index := MRP_ATP_PUB.Number_Arr();

    x_dc_list_tab.EXTEND;
    x_dc_start_index.EXTEND;
    x_dc_end_index.EXTEND;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'after extend : ' || p_atp_dc_tab(p_atp_dc_tab.FIRST));
    END IF;

    x_dc_list_tab(1) := p_atp_dc_tab(p_atp_dc_tab.FIRST);
    x_dc_start_index(1) := 1;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'after assign : ' || x_dc_list_tab(1));
       msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'start index : ' || x_dc_start_index(1));
    END IF;

    -- 2970405 rework break up demand classes
    -- this for loop will do backward consumption
    FOR i in 1..(p_atp_dc_tab.COUNT-1) LOOP  -- 1490473: i starts from 1, not 2

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'index : ' || i);
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'x_dc_list_tab : ' || x_dc_list_tab(x_dc_list_tab.COUNT));
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'p_atp_dc_tab : ' || p_atp_dc_tab(i));
        END IF;

        -- If demand class changes, re-initialize these variables.
        IF p_atp_dc_tab(i+1) <> x_dc_list_tab(x_dc_list_tab.COUNT) THEN

           x_dc_end_index(x_dc_end_index.COUNT) := i;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'inside IF');
              msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'end index : ' || x_dc_end_index(x_dc_end_index.COUNT));
           END IF;

           x_dc_list_tab.EXTEND;
           x_dc_start_index.EXTEND;
           x_dc_end_index.EXTEND;
           x_dc_list_tab(x_dc_list_tab.COUNT) := p_atp_dc_tab(i+1);
           x_dc_start_index(x_dc_start_index.COUNT) := i+1;
           -- x_dc_end_index(x_dc_end_index.COUNT) := i;
           --ELSE
           --IF PG_DEBUG in ('Y', 'C') THEN
           --   msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'inside else');
           --END IF;
	   --x_dc_end_index(x_dc_end_index.COUNT) := i;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'start index : ' || x_dc_start_index(x_dc_start_index.COUNT));
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'end index : ' || x_dc_end_index(x_dc_end_index.COUNT));
        END IF;

        /* 2970405 just calculate the start and end of the dc's
        -- backward consumption when neg atp quantity occurs
        IF (p_atp_qty(i) < 0 ) THEN
            j := i - 1;
            WHILE ((j >= x_dc_start_index(x_dc_start_index.COUNT)) and (p_atp_qty(j) >= 0))  LOOP
                IF (p_atp_qty(j) = 0) THEN
                    --  backward one more period
                    j := j-1 ;
                ELSE
	            IF (p_atp_qty(j) + p_atp_qty(i) < 0) THEN
                        -- not enough to cover the shortage
                        p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(j);
                        p_atp_qty(j) := 0;
                        j := j-1;
                    ELSE
                        -- enough to cover the shortage
                        p_atp_qty(j) := p_atp_qty(j) + p_atp_qty(i);
                        p_atp_qty(i) := 0;
                        j := -1;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'before forward consumption');
        END IF;

        -- 1490473: forward consumption
        -- this for loop will do forward consumption

        -- forward consumption when neg atp quantity occurs
        IF (p_atp_qty(i) < 0 ) THEN

           j := i + 1;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'in forward consumption : '  || i || ':' || j);
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'in forward : '  || p_atp_dc_tab.COUNT);
        END IF;

	   IF j < p_atp_dc_tab.COUNT THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'in j : '  || p_atp_dc_tab.COUNT);
              END IF;

               WHILE (p_atp_dc_tab(j) = x_dc_list_tab(x_dc_list_tab.COUNT))  LOOP
                   IF (p_atp_qty(j) <= 0) THEN
                       --  forward one more period
                       j := j+1 ;
                   ELSE
                       IF (p_atp_qty(j) + p_atp_qty(i) < 0) THEN
                           -- not enough to cover the shortage
                           p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(j);
                           p_atp_qty(j) := 0;
                           j := j + 1;
                       ELSE
                           -- enough to cover the shortage
                           p_atp_qty(j) := p_atp_qty(j) + p_atp_qty(i);
                           p_atp_qty(i) := 0;
                           EXIT;
                       END IF;
                   END IF;

                   IF j > p_atp_dc_tab.COUNT THEN
		      EXIT;
		   END IF;

               END LOOP;
           END IF;
        END IF;
        end 2970405 */
    END LOOP;

    -- 2970405
    x_dc_end_index(x_dc_end_index.count) := p_atp_dc_tab.count;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'x_dc_list_tab : ' || x_dc_list_tab.COUNT);
    END IF;

    -- this for loop will do atp consume on each dc
    FOR j in 1..x_dc_list_tab.COUNT LOOP

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'inside atp consume : ' || j);
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'x_dc_start_index : ' || x_dc_start_index(j));
           msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'x_dc_end_index : ' || x_dc_end_index(j));
        END IF;

        MSC_ATP_PROC.atp_consume_range(p_atp_qty, x_dc_start_index(j), x_dc_end_index(j));
        /* 2970405
        FOR i in (x_dc_start_index(j) + 1)..x_dc_end_index(j) LOOP

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'inside accumulation : ' || i);
            END IF;
            -- 1956037: do accumulation for neg quantity as well
            p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(i-1);
        END LOOP;
        */
    END LOOP; 	--FOR i in 1..x_dc_list_tab.COUNT LOOP

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********End Atp_Alloc_Consume Procedure************');
    END IF;

EXCEPTION
    WHEN others THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Atp_Alloc_Consume: ' || 'in Exception : '  || i || ':' || j);
            msc_sch_wb.atp_debug('Exception in Atp_Alloc_Consume : ' || sqlcode);
         END IF;
END Atp_Alloc_Consume;


-- 3/6/2002, added this procedure by copying from MSC_ATP_REQ.Get_Material_Atp_Info
-- This will be called from MSC_ATP_PVT.ATP_Check for forward scheduling instead of Get_Material_Atp_Info
-- only for Allocated ATP in case forward stealing needs to be done.

PROCEDURE Get_Forward_Material_Atp(
  p_instance_id			   	IN    NUMBER,
  p_plan_id                             IN    NUMBER,
  p_level				IN    NUMBER,
  p_identifier                          IN    NUMBER,
  p_demand_source_type                  IN    NUMBER,--cmro
  p_scenario_id                         IN    NUMBER,
  p_inventory_item_id                   IN    NUMBER,
  p_request_item_id                     IN    NUMBER, -- For time_phased_atp
  p_organization_id                     IN    NUMBER,
  p_item_name                     	IN    VARCHAR2,
  p_family_item_name                    IN    VARCHAR2, -- For time_phased_atp
  p_requested_date                      IN    DATE,
  p_quantity_ordered                    IN    NUMBER,
  p_demand_class			IN    VARCHAR2,
  x_requested_date_quantity             OUT   NoCopy NUMBER,
  x_atf_date_quantity                   OUT   NoCopy NUMBER, -- For time_phased_atp
  x_atp_date_this_level                 OUT   NoCopy DATE,
  x_atp_date_quantity_this_level        OUT   NoCopy NUMBER,
  x_atp_pegging_tab                     OUT   NOCOPY MRP_ATP_PUB.Number_Arr,
  x_return_status                       OUT   NoCopy VARCHAR2,
  x_used_available_quantity             OUT   NoCopy NUMBER, --bug3409973
  p_substitution_window                 IN    number,
  p_get_mat_in_rec                      IN    MSC_ATP_REQ.get_mat_in_rec,
  x_get_mat_out_rec                     OUT   NOCOPY MSC_ATP_REQ.get_mat_out_rec,
  p_atf_date                            IN    DATE, -- For time_phased_atp
  p_order_number                        IN    NUMBER := NULL,
  p_refresh_number                      IN    NUMBER := NULL,
  p_parent_pegging_id                   IN    NUMBER := NULL
)
IS
l_atp_requested_date            DATE;
l_infinite_time_fence_date	DATE;
l_requested_date                DATE;
l_sys_next_date                 DATE;
NO_MATCHING_CAL_DATE            EXCEPTION;
l_atp_quantity			NUMBER;
l_calendar_exception_set_id     NUMBER;
l_default_atp_rule_id           NUMBER;
l_inv_item_id			NUMBER;
l_level_id			NUMBER;
l_partner_id			NUMBER;
l_priority			NUMBER;
l_round_flag			NUMBER;
l_stealing_quantity		NUMBER;
l_total_atp_qty               	NUMBER;
l_transaction_id               	NUMBER;
l_calendar_code                 VARCHAR2(14);
l_class				VARCHAR2(30);
l_default_demand_class          VARCHAR2(34);
l_org_code          		VARCHAR2(7);
l_stealing_flag			VARCHAR2(1);
i 				PLS_INTEGER := 1;
j 				PLS_INTEGER := 1;
k 				PLS_INTEGER := 1;
m 				PLS_INTEGER := 1;
n 				PLS_INTEGER := 1;
l_atp_dc_tab              	MRP_ATP_PUB.char80_arr := MRP_ATP_PUB.char80_arr();
l_atp_qty_tab 			MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_atp_period_tab 		MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_dc_end_index     		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_dc_list_tab              	MRP_ATP_PUB.char80_arr := MRP_ATP_PUB.char80_arr();
l_dc_start_index     		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_demand_class_priority_tab     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_demand_class_tab              MRP_ATP_PUB.char80_arr := MRP_ATP_PUB.char80_arr();
l_pegging_rec                   mrp_atp_details_temp%ROWTYPE;
l_period_tab 			MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_used_dc_tab              	MRP_ATP_PUB.char80_arr := MRP_ATP_PUB.char80_arr();
l_used_dc_qty     		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_substitution_end_date         DATE;
--- Enhance CTO Phase 1 Req #17 new variable
l_demand_pegging_id             NUMBER;
l_demand_id                     NUMBER;
l_atp_rec                       MRP_ATP_PVT.AtpRec;

-- For summary enhancement
l_summary_flag  NUMBER;

-- time_phased_atp
l_time_phased_atp       VARCHAR2(1) := 'N';
l_return_status         VARCHAR2(1);
l_used_dc_mem_qty       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atf_quantity          NUMBER; -- l_atf_quantity is qty total qty used within ATF, may not be equal to ATF date qty
l_mem_stealing_qty      NUMBER;
l_pf_stealing_qty       NUMBER;
k_atf                   PLS_INTEGER;
l_pf_item_id            NUMBER;
l_item_to_use           NUMBER;
m_atf                   PLS_INTEGER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********Begin Get_Forward_Material_Atp Procedure************');
    END IF;
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_atp_pegging_tab := MRP_ATP_PUB.Number_Arr();

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('********** INPUT DATA:Get_Forward_Material_Atp **********');
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_inventory_item_id: '|| to_char(p_inventory_item_id));
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_organization_id: '|| to_char(p_organization_id));
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_requested_date: '|| to_char(p_requested_date));
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_instance_id: '|| to_char(p_instance_id));
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_plan_id: '|| to_char(p_plan_id));
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_quantity_ordered: '|| to_char(p_quantity_ordered));
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_demand_class: '|| p_demand_class);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_substitution_window:= ' || p_substitution_window);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_parent_pegging_id:= ' || p_parent_pegging_id);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_order_number:= ' || p_order_number);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_get_mat_in_rec.shipping_cal_code:= ' || p_get_mat_in_rec.shipping_cal_code);
    END IF;

    -- time_phased_atp changes begin
    IF (p_inventory_item_id <> p_request_item_id) and p_atf_date is not null THEN
        l_time_phased_atp := 'Y';
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Time Phased ATP = ' || l_time_phased_atp);
        END IF;
    END IF;
    -- time_phased_atp changes end

    -- get the infinite time fence date if it exists
    --diag_atp
    /*
    l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(p_instance_id,
             p_inventory_item_id,p_organization_id, p_plan_id);
    */
     MSC_ATP_PROC.get_infinite_time_fence_date(p_instance_id,
                                               p_inventory_item_id,
                                               p_organization_id,
                                               p_plan_id,
                                               l_infinite_time_fence_date,
                                               x_get_mat_out_rec.atp_rule_name);

    x_get_mat_out_rec.infinite_time_fence_date := l_infinite_time_fence_date;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_infinite_time_fence_date: '|| to_char(l_infinite_time_fence_date));
    END IF;
    --diag_atp
    /*
    BEGIN
        SELECT NVL(rounding_control_type,2), inventory_item_id
        INTO   l_round_flag, l_inv_item_id
        FROM   msc_system_items I
        WHERE  I.sr_inventory_item_id = p_inventory_item_id
        AND    I.sr_instance_id = p_instance_id
        AND    I.plan_id = p_plan_id
        AND    I.organization_id = p_organization_id;
    EXCEPTION
        WHEN OTHERS THEN
    	     IF PG_DEBUG in ('Y', 'C') THEN
    	        msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Excpetion in Round Flag : ' || sqlcode || ':' || sqlerrm);
    	     END IF;
             l_round_flag := 2; -- do not round
    END;
    */
    l_round_flag := p_get_mat_in_rec.rounding_control_flag;
    l_inv_item_id := p_get_mat_in_rec.dest_inv_item_id;
    -- time_phased_atp
    l_pf_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.product_family_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_round_flag = '|| l_round_flag);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_inv_item_id = ' || l_inv_item_id);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_pf_item_id = ' || l_pf_item_id);
    END IF;

    MSC_ATP_PROC.get_org_default_info(p_instance_id, p_organization_id,
                 l_default_atp_rule_id, l_calendar_code, l_calendar_exception_set_id,
                 l_default_demand_class, l_org_code);
    -- Bug 3371817 - l_sys_next_date should be actually calculated using the calendar passed from ATP_Check
    l_sys_next_date := MSC_CALENDAR.NEXT_WORK_DAY(
                                    p_get_mat_in_rec.shipping_cal_code,
                                    p_instance_id,
                                    TRUNC(sysdate));
    /*
    BEGIN
        SELECT  cal.next_date
        INTO    l_sys_next_date
        FROM    msc_calendar_dates  cal
        WHERE   cal.exception_set_id = l_calendar_exception_set_id
        AND     cal.calendar_code = l_calendar_code
        AND     cal.calendar_date = TRUNC(sysdate)
        AND     cal.sr_instance_id = p_instance_id ;
    EXCEPTION
        WHEN OTHERS THEN
           RAISE NO_MATCHING_CAL_DATE;
    END;
    -- Bug 3371817 - Changes end.
    */
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_sys_next_date = ' || l_sys_next_date);
    END IF;

    ---forward steal:subst
    IF NVL(p_substitution_window, 0) = 0 THEN
       l_substitution_end_date := l_infinite_time_fence_date;
    ELSE
       l_substitution_end_date :=  MSC_CALENDAR.DATE_OFFSET(
                                       p_organization_id,
                                       p_instance_id,
                                       1,
                                       --bug 3589115: Move to sysdate for past due dates
                                       greatest(p_requested_date, l_sys_next_date),
                                       p_substitution_window);

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_substitution_end_date := ' || l_substitution_end_date);
    END IF;

    -- in case we want to support flex date
    l_requested_date := p_requested_date;

    /* New allocation logic for time_phased_atp changes begin */
    IF l_time_phased_atp = 'Y' THEN
        IF p_requested_date <= p_atf_date THEN
            IF MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF = 'Y' THEN
                l_item_to_use := l_inv_item_id;
            ELSE
                l_item_to_use := l_pf_item_id;
            END IF;
        ELSE
            IF MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF = 'Y' THEN
                l_item_to_use := l_pf_item_id;
            ELSE
                l_item_to_use := l_inv_item_id;
            END IF;
        END IF;
    ELSE
        l_item_to_use := l_inv_item_id;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Item to be used = ' || l_item_to_use);
    END IF;
    /* New allocation logic for time_phased_atp changes end */

    BEGIN
	-- Changes For bug 2384551 start
	IF MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 THEN

        SELECT mv.priority, mv.level_id, mv.class, mv.partner_id
        INTO   l_priority, l_level_id, l_class, l_partner_id
        FROM   msc_item_hierarchy_mv mv
        WHERE  mv.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
        AND    mv.organization_id = p_organization_id
        AND    mv.sr_instance_id = p_instance_id
        --bug 3589115: if allocation rule is not valid on request date then pick one applicable on sysdate
        AND    GREATEST(p_requested_date, l_sys_next_date) BETWEEN effective_date AND disable_date
        AND    mv.demand_class = p_demand_class
	AND    mv.level_id =  -1;

	ELSE

	SELECT mv.priority, mv.level_id, mv.class, mv.partner_id
        INTO   l_priority, l_level_id, l_class, l_partner_id
        FROM   msc_item_hierarchy_mv mv
        WHERE  mv.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
        AND    mv.organization_id = p_organization_id
        AND    mv.sr_instance_id = p_instance_id
        --bug 3589115: if allocation rule is not valid on request date then pick one applicable on sysdate
        AND    GREATEST(p_requested_date, l_sys_next_date) BETWEEN effective_date AND disable_date
        AND    mv.demand_class = p_demand_class
        AND    mv.level_id <> -1;

	END IF;
	-- Changes For bug 2384551 end
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_priority := NULL;
              l_level_id := NULL;
              l_partner_id := NULL;
              l_class := NULL;
    END ;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before lower priority dc for : ' || l_priority || ':'|| l_class);
    END IF;

    -- Order by clause reversed as we'll add request demand class at the end and acces the list bottom-up.

    SELECT mv.demand_class, mv.priority
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab
    FROM   msc_item_hierarchy_mv mv
    WHERE  mv.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
    AND    mv.organization_id = p_organization_id
    AND    mv.sr_instance_id = p_instance_id
    --bug 3589115: if allocation rule is not valid on request date then pick one applicable on sysdate
    AND    GREATEST(p_requested_date, l_sys_next_date) BETWEEN effective_date AND disable_date
    AND    mv.priority  > l_priority
    AND    mv.level_id = l_level_id
    ORDER BY mv.priority desc , mv.allocation_percent asc, mv.demand_class desc;

    -- Add request demand class to the end of the arrays.

    l_demand_class_tab.Extend;
    l_demand_class_priority_tab.Extend;

    l_demand_class_tab(l_demand_class_tab.Count) := p_demand_class;
    l_demand_class_priority_tab(l_demand_class_priority_tab.Count) := l_priority;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'No. of DC : ' || l_demand_class_tab.Count);
    END IF;

    -- Insert these demand classes in Global Temp Table to use in SELECT clause.

    FORALL i IN l_demand_class_tab.FIRST..l_demand_class_tab.COUNT
           INSERT INTO msc_alloc_temp(demand_class)
	   VALUES (l_demand_class_tab(i));

    -- for performance, we dont support the s/d details for forward Scheduling in case of allocated ATP if
    -- forward stealing needs to be supported.
    -- since we don't need details, do a group by and select the sum in the sql statement.

    -- Summary enhancement changes begin
    SELECT  summary_flag
    INTO    l_summary_flag
    FROM    msc_plans plans
    WHERE   plans.plan_id = p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'right before the huge select statement');
    END IF;

    -- Check if full summary has been run - for summary enhancement
    IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND
        l_summary_flag NOT IN (MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN, MSC_POST_PRO.G_SF_PREALLOC_COMPLETED,
                         MSC_POST_PRO.G_SF_FULL_SUMMARY_RUNNING) THEN

            -- time_phased_atp
            IF l_time_phased_atp = 'N' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                END IF;

                -- Summary SQL can be used
                SELECT 	SD_DATE,
                        SUM(SD_QTY),
                        DEMAND_CLASS
                BULK COLLECT INTO
                        l_atp_period_tab,
                        l_atp_qty_tab,
                        l_atp_dc_tab
                FROM
                    (
                        SELECT  /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                                SD_DATE, SD_QTY, DEMAND_CLASS
                        FROM    MSC_ATP_SUMMARY_SD S
                        WHERE   S.PLAN_ID = p_plan_id
                        AND     S.SR_INSTANCE_ID = p_instance_id
                        AND     S.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     S.ORGANIZATION_ID = p_organization_id
                        AND     S.DEMAND_CLASS IN (
                                SELECT  demand_class
                                FROM    msc_alloc_temp
                                WHERE   demand_class IS NOT NULL)
                        AND     S.SD_DATE < l_infinite_time_fence_date

                        UNION ALL

                        SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                                decode(AD.ALLOCATED_QUANTITY,           -- Consider unscheduled orders as dummy supplies
                                       0, nvl(OLD_ALLOCATED_QUANTITY,0), --4658238        -- For summary enhancement
                                          -1 * AD.ALLOCATED_QUANTITY) SD_QTY,
                                AD.DEMAND_CLASS
                        FROM    MSC_ALLOC_DEMANDS AD,
                                MSC_PLANS P                                     -- For summary enhancement
                        WHERE   AD.PLAN_ID = p_plan_id
                        AND     AD.SR_INSTANCE_ID = p_instance_id
                        AND     AD.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     AD.ORGANIZATION_ID = p_organization_id
                        AND     AD.DEMAND_CLASS IN (
                                SELECT  demand_class
                                FROM    msc_alloc_temp
                                WHERE   demand_class IS NOT NULL)
                                --bug3693892 added trunc
                        AND     trunc(AD.DEMAND_DATE) < l_infinite_time_fence_date
                                AND     P.PLAN_ID = AD.PLAN_ID
                                AND     (AD.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                                        OR AD.REFRESH_NUMBER = p_refresh_number)

                        UNION ALL

                        SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                                decode(SA.ALLOCATED_QUANTITY,           -- Consider deleted stealing records as dummy demands
                                       0, -1 * (NVL(OLD_ALLOCATED_QUANTITY,0)),   -- For summary enhancement --5283809
                                          SA.ALLOCATED_QUANTITY) SD_QTY ,
                                SA.DEMAND_CLASS
                        FROM    MSC_ALLOC_SUPPLIES SA,
                                MSC_PLANS P                                     -- For summary enhancement
                        WHERE   SA.PLAN_ID = p_plan_id
                        AND     SA.SR_INSTANCE_ID = p_instance_id
                        AND     SA.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     SA.ORGANIZATION_ID = p_organization_id
                        AND     SA.DEMAND_CLASS IN (
                                SELECT  demand_class
                                FROM    msc_alloc_temp
                                WHERE   demand_class IS NOT NULL)
                                --bug3693892 added trunc
                        AND     trunc(SA.SUPPLY_DATE) < l_infinite_time_fence_date
                        AND     P.PLAN_ID = SA.PLAN_ID
                        AND     (SA.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                                OR SA.REFRESH_NUMBER = p_refresh_number)
                    )
                GROUP BY DEMAND_CLASS, SD_DATE
                ORDER BY DEMAND_CLASS, SD_DATE;--4698199 --5353882

            ELSE -- IF Not_PF_Case THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                END IF;

                MSC_ATP_PF.Get_Forward_Mat_Pf_Summ(
                        l_inv_item_id,
                        l_pf_item_id,
                        p_organization_id,
                        p_instance_id,
                        p_plan_id,
                        l_infinite_time_fence_date,
                        p_refresh_number,
                        l_atp_period_tab,
                        l_atp_qty_tab,
                        l_atp_dc_tab,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Error occured in procedure Get_Forward_Mat_Pf_Summ');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF; -- IF Not_PF_Case THEN

    ELSE
            -- time_phased_atp
            IF l_time_phased_atp = 'N' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                END IF;

                -- Use the SQL for non summary case
                SELECT 	SD_DATE,
                        SUM(SD_QTY),
                        DEMAND_CLASS
                BULK COLLECT INTO
                        l_atp_period_tab,
                        l_atp_qty_tab,
                        l_atp_dc_tab
                FROM
                    (
                        SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                                -1 * AD.ALLOCATED_QUANTITY SD_QTY,
                                AD.DEMAND_CLASS
                        FROM    MSC_ALLOC_DEMANDS AD
                        WHERE   AD.PLAN_ID = p_plan_id
                        AND     AD.SR_INSTANCE_ID = p_instance_id
                        AND     AD.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     AD.ORGANIZATION_ID = p_organization_id
                        AND     AD.ORIGINATION_TYPE <> 52   -- Ignore copy SO and copy stealing records for summary enhancement
                        AND     AD.DEMAND_CLASS IN (
                                SELECT  demand_class
                                FROM    msc_alloc_temp
                                WHERE   demand_class IS NOT NULL)
                                --bug3693892 added trunc
                        AND     trunc(AD.DEMAND_DATE) < l_infinite_time_fence_date

                        UNION ALL

                        SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                                SA.ALLOCATED_QUANTITY SD_QTY,
                                SA.DEMAND_CLASS
                        FROM    MSC_ALLOC_SUPPLIES SA
                        WHERE   SA.PLAN_ID = p_plan_id
                        AND     SA.SR_INSTANCE_ID = p_instance_id
                        AND     SA.INVENTORY_ITEM_ID = l_inv_item_id
                        AND     SA.ORGANIZATION_ID = p_organization_id
                        AND     SA.ALLOCATED_QUANTITY <> 0
                        -- fixed as part of time_phased_atp chagnes
                        AND     TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                                27, TRUNC(SYSDATE),
                                                                28, TRUNC(SYSDATE),
                                                                TRUNC(SA.SUPPLY_DATE))
                        AND     SA.DEMAND_CLASS IN (
                                SELECT  demand_class
                                FROM    msc_alloc_temp
                                WHERE   demand_class IS NOT NULL)
                                --bug3693892 added trunc
                        AND     trunc(SA.SUPPLY_DATE) < l_infinite_time_fence_date
                    )
                GROUP BY DEMAND_CLASS, SD_DATE
                ORDER BY DEMAND_CLASS, SD_DATE;--4698199 --5353882

            ELSE -- IF Not_PF_Case THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                END IF;

                MSC_ATP_PF.Get_Forward_Mat_Pf(
                        l_inv_item_id,
                        l_pf_item_id,
                        p_organization_id,
                        p_instance_id,
                        p_plan_id,
                        l_infinite_time_fence_date,
                        l_atp_period_tab,
                        l_atp_qty_tab,
                        l_atp_dc_tab,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Error occured in procedure Get_Forward_Mat_Pf');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF; -- IF Not_PF_Case THEN

    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after huge select, l_atp_period_tab.COUNT : ' || l_atp_period_tab.COUNT);
    END IF;

    IF l_atp_period_tab.COUNT = 0 THEN
       -- need to add error message
       --RAISE NO_DATA_FOUND;
       null;
    END IF;

    -- Bug 3344138 initialize x_requested_date_quantity
    x_requested_date_quantity := 0;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before the atp_alloc_consume');
    END IF;

    -- do the backward consumption and accumulation

IF l_atp_period_tab.COUNT > 0 THEN

       FOR i IN 1..l_atp_period_tab.COUNT LOOP
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || l_atp_period_tab(i) ||':'||l_atp_dc_tab(i) ||':' || l_atp_qty_tab(i));
           END IF;
       END LOOP;

       -- time_phased_atp
       IF l_time_phased_atp = 'Y' THEN
               MSC_ATP_PF.Pf_Atp_Alloc_Consume(
                       l_atp_qty_tab,
                       l_atp_period_tab,
                       l_atp_dc_tab,
                       p_atf_date,
                       l_dc_list_tab,
                       l_dc_start_index,
                       l_dc_end_index,
                       l_return_status
               );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Error occured in procedure Pf_Atp_Alloc_Consume');
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
       ELSE
               atp_alloc_consume(l_atp_qty_tab, l_atp_dc_tab, l_dc_list_tab, l_dc_start_index, l_dc_end_index);
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after the atp_alloc_consume');
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_dc_list_tab.count = '||l_dc_list_tab.COUNT);

          FOR i IN 1..l_atp_period_tab.COUNT LOOP
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || l_atp_period_tab(i) ||':'
			||l_atp_dc_tab(i) ||':' || l_atp_qty_tab(i));
          END LOOP;
       END IF;

       /* Cum drop issue changes begin*/
       MSC_AATP_PROC.Atp_Remove_Negatives(l_atp_qty_tab, l_return_status);
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Item_Pre_Allocated_Atp: ' || 'Error occured in procedure Atp_Remove_Negatives');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       /* Cum drop issue changes end*/


    -- Insert all the records in l_atp_period_tab in a temp table. Then we'll select
    -- all these dates in another pl/sql table. This is done to make sure we move thru
    -- data from various demand classes in correct order of dates as these may be misaligned.

    FORALL i IN l_atp_period_tab.FIRST..l_atp_period_tab.COUNT
           INSERT INTO msc_alloc_temp(supply_demand_date)
	   VALUES (l_atp_period_tab(i));

    SELECT supply_demand_date --sd_date
    BULK COLLECT INTO
           l_period_tab
    FROM
    (
	SELECT DISTINCT supply_demand_date --sd_date
	FROM   msc_alloc_temp
	WHERE  supply_demand_date IS NOT NULL
        --- for substitution we want to consider supplies only within substitution widow
        --- filter out dates after substitution window
        and supply_demand_date <= l_substitution_end_date
	ORDER BY supply_demand_date --sd_date
    );

    IF PG_DEBUG in ('Y', 'C') THEN
       FOR i IN 1..l_period_tab.COUNT LOOP
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || l_period_tab(i));
       END LOOP;
    END IF;

    -- if requested date is eariler than sysdate, we have an issue here.
    -- this is possible since we have the offset from requested arrival
    -- date.  if requested date is eariler than sysdate, we should set
    -- the x_requested_date_quantity = 0, and find the atp date and
    -- quantity from sysdate.

    -- we use this l_atp_requested_date to do the search
    l_atp_requested_date := GREATEST(l_requested_date, trunc(l_sys_next_date));

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'G_PTF_DATE:= ' || MSC_ATP_PVT.G_PTF_DATE);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_atp_requested_date = ' || l_atp_requested_date);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_level = ' || p_level);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_period_tab = ' || l_period_tab.COUNT);
    END IF;

    l_atp_quantity := 0;
    --x_requested_date_quantity := 0; -- Bug 3344138
    x_atf_date_quantity := 0; --bug3409973
    x_used_available_quantity := 0; --bug3409973

    FOR k IN 1..l_period_tab.COUNT LOOP

      l_atp_quantity := 0;
      l_stealing_flag := 'N';
      l_atf_quantity := 0; -- time_phased_atp

      -- time_phased_atp changes begin
      IF l_time_phased_atp = 'Y' THEN
              IF (l_period_tab(k) <= p_atf_date) and (k <> l_period_tab.COUNT) and (l_period_tab(k+1) > p_atf_date) THEN
                 /* We have found counter k for ATF date*/
                 k_atf := k;
              ELSIF (k = 1) and (l_period_tab(k) > p_atf_date) THEN
                 k_atf := 0;
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ============================');
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'k : ' || k);
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_period_tab(k) : ' || l_period_tab(k));
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'p_atf_date : ' || p_atf_date);
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'k_atf : ' || k_atf);
                 msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ============================');
              END IF;
      END IF;
      -- time_phased_atp changes end

      -- Reset following variables before start of following Loop

      --l_used_dc_tab.TRIM(l_used_dc_tab(l_used_dc_tab.COUNT));
      --l_used_dc_qty.TRIM(l_used_dc_qty(l_used_dc_qty.COUNT));

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before trim = ' || l_used_dc_tab.COUNT);
    END IF;
      l_used_dc_tab.TRIM(l_used_dc_tab.COUNT);
      l_used_dc_qty.TRIM(l_used_dc_qty.COUNT);
      -- time_phased_atp
      IF l_time_phased_atp = 'Y' THEN
         l_used_dc_mem_qty.TRIM(l_used_dc_mem_qty.COUNT);
      END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after trim = ' || l_used_dc_tab.COUNT);
    END IF;

      FOR i in REVERSE 1..l_demand_class_tab.COUNT LOOP
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before j = ' || l_demand_class_tab(i));
        END IF;
        n := 0;
        FOR j IN 1..l_dc_list_tab.COUNT LOOP
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'inside j = ' || l_dc_list_tab(j));
            END IF;

            IF l_dc_list_tab(j) = l_demand_class_tab(i) THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'inside IF = ' || j);
               END IF;
               n := j;
	       EXIT;
	    END IF;
        END LOOP;	--FOR j IN 1..l_dc_list_tab.COUNT LOOP

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after loop = ' || j);
        END IF;
        IF NVL(n, 0) > 0 THEN

	j := n;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before m = ' || l_dc_list_tab(j));
        END IF;

        -- Reset m_atf
        m_atf := NULL;

        FOR m IN l_dc_start_index(j)..l_dc_end_index(j) LOOP

	    /* time_phased_atp
	       We were not handling cases where there are holes (i.e. all demand classes do
               not have records on all distinct dates) correctly while forward stealing.
               Fixed this issue as part of time phased atp changes*/
	    --IF (l_atp_period_tab(m) = l_period_tab(k)) AND (l_atp_qty_tab(m) > 0) THEN

            --bug 3443276: We are returning a date previuos to request date
             --if that date has an availability. We should be returning atleast request date
	    IF ( (l_atp_period_tab(m) =
                       GREATEST(l_period_tab(k), MSC_ATP_PVT.G_PTF_DATE, l_atp_requested_date))
	           OR ( ( l_atp_period_tab(m) <
                                GREATEST(MSC_ATP_PVT.G_PTF_DATE, l_period_tab(k), l_atp_requested_date) )
	                 AND ( ( ( m < l_dc_end_index(j) )
	                         AND ( l_atp_period_tab(m+1) >
                                GREATEST(MSC_ATP_PVT.G_PTF_DATE,l_period_tab(k), l_atp_requested_date) )
	                        )
	                        OR ( m = l_dc_end_index(j) )
	                      )
	               )
	          )
	       AND (l_atp_qty_tab(m) > 0)
	    THEN
		l_used_dc_tab.EXTEND;
		l_used_dc_qty.EXTEND;
		l_used_dc_tab(l_used_dc_tab.COUNT) := l_dc_list_tab(j);
		l_used_dc_qty(l_used_dc_qty.COUNT) := l_atp_qty_tab(m);

		-- time_phased_atp changes begin
		IF l_time_phased_atp = 'Y' THEN
		   l_used_dc_mem_qty.EXTEND;
		   IF (k_atf is null) OR (m_atf is null) THEN
		      /* we are using qty within ATF completely*/
		      l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT) := l_atp_qty_tab(m);
                   ELSIF k_atf = 0 THEN
                      /* we are using qty outside ATF completely*/
                      l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT) := 0;
		   ELSE
		      /* we are using qty within and outside ATF*/
		      l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT) := l_atp_qty_tab(m_atf);
                   END IF;
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Get_Forward_Material_Atp: <<<<<<<<<<<<< >>>>>>>>>>>>>');
                      msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'k_atf = ' || k_atf);
                      msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_used_dc_mem_qty('
                                           || l_used_dc_mem_qty.COUNT || ') = ' || l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT));
                      msc_sch_wb.atp_debug('Get_Forward_Material_Atp: <<<<<<<<<<<<< >>>>>>>>>>>>>');
                   END IF;
		END IF;
		-- time_phased_atp changes end

                IF l_used_dc_tab(l_used_dc_tab.COUNT) <> p_demand_class THEN
                   l_stealing_flag := 'Y';
                END IF;	--IF l_used_dc_tab(l_used_dc_tab.COUNT) <> p_demand_class THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before l_atp_quantity = ' || l_atp_quantity);
                   msc_sch_wb.atp_debug('Used DC qty := ' || l_used_dc_qty(l_used_dc_qty.COUNT));
                END IF;

                IF l_atp_quantity + l_used_dc_qty(l_used_dc_qty.COUNT) >= p_quantity_ordered THEN

                   -- time_phased_atp changes begin
                   IF l_time_phased_atp = 'Y' THEN
                      /*IF l_atp_quantity + l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT) >= p_quantity_ordered THEN
                         l_atf_quantity := l_atf_quantity + p_quantity_ordered - l_atp_quantity;
                         l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT) := p_quantity_ordered - l_atp_quantity;
                      ELSE*/
                         l_atf_quantity := l_atf_quantity + l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT);
                      /*END IF;*/
                   END IF;
                   -- time_phased_atp changes end

                   l_atp_quantity := l_atp_quantity + l_atp_qty_tab(m);

                   IF (l_round_flag = 1) THEN
                      x_atp_date_quantity_this_level := FLOOR(l_atp_quantity);
                   ELSE
                      x_atp_date_quantity_this_level := l_atp_quantity;
                   END IF;

                   --this condition is not needed any more as we check
                   -- this condition in 'IF' logic to come here

		   /* IF l_period_tab(k) >= MSC_ATP_PVT.G_PTF_DATE OR
                      (k < l_period_tab.count and l_period_tab(k+1) > MSC_ATP_PVT.G_PTF_DATE)
                   THEN
                   */
                      --3443276: we need to return date > req date
                      x_atp_date_this_level := GREATEST(l_period_tab(k),MSC_ATP_PVT.G_PTF_DATE,  l_atp_requested_date);
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || x_atp_date_quantity_this_level);
                         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || x_atp_date_this_level);
                      END IF;

                      EXIT;
		   --END IF;

                ELSE
                   l_atp_quantity := l_atp_quantity + l_atp_qty_tab(m);
                   -- time_phased_atp changes begin
                   IF l_time_phased_atp = 'Y' THEN
                      l_atf_quantity := l_atf_quantity + l_used_dc_mem_qty(l_used_dc_mem_qty.COUNT);
                   END IF;
                   -- time_phased_atp changes end
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after l_atp_quantity = ' || l_atp_quantity);
                END IF;

	    ELSIF (m_atf is null) AND (k_atf is not null) AND (k_atf <> 0)
	      AND ((l_atp_period_tab(m) = l_period_tab(k_atf))
	           OR ( ( l_atp_period_tab(m) < l_period_tab(k_atf) )
	                 AND ( ( ( m < l_dc_end_index(j) )
	                         AND ( l_atp_period_tab(m+1) > l_period_tab(k_atf) )
	                        )
	                        OR ( m = l_dc_end_index(j) )
	                      )
	               )
	          )
	    THEN
	      /* Set m_atf*/
	      m_atf := m;
	    END IF;	--IF l_atp_period_tab(j)) = l_period_tab(k) THEN

        END LOOP;	--FOR m IN 1..l_dc_start_index(j)..l_dc_end_index(j) LOOP

        IF x_atp_date_this_level IS NOT NULL THEN
           EXIT;
        END IF;

        END IF; 	--IF NVL(n, 0) > 0 THEN
      END LOOP;		--FOR i in l_demand_class_tab.COUNT..1 LOOP

      -- time_phased_atp
     -- x_atf_date_quantity := l_atf_quantity;
     -- let say the next period is on Day5 but our request in on Day2.

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_period_tab : ' || l_period_tab(k));
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_period_tab.count : ' || l_period_tab.COUNT);
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'k : ' || k);
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_atp_requested_date : ' || l_atp_requested_date);
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_atp_quantity : ' || l_atp_quantity);
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_atf_quantity : ' || l_atf_quantity);
      END IF;

      IF k < l_period_tab.COUNT THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_period_tab (k+1) : ' || l_period_tab(k+1));
         END IF;
         IF (l_atp_requested_date >= l_period_tab(k)) AND
            (l_atp_requested_date < l_period_tab(k + 1)) THEN
            x_requested_date_quantity := l_atp_quantity;
         END IF;
      ELSE
         IF (l_atp_requested_date >= l_period_tab(k)) AND x_requested_date_quantity = 0 THEN
            x_requested_date_quantity := l_atp_quantity;
	 END IF;
      END IF;	--IF k < l_period_tab.COUNT THEN

      -- dsting 2807614
      IF l_atp_requested_date > l_requested_date THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Forward_Material_Atp: l_requested_date < l_atp_requested_date');
         END IF;
         x_requested_date_quantity := 0;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_requested_date_quantity : ' || x_requested_date_quantity);
      END IF;

      IF x_atp_date_this_level IS NOT NULL THEN
         EXIT;
      END IF;

    END LOOP; 	--FOR k IN 1..l_period_tab.COUNT LOOP
END IF;
  --bug3409973 start
    IF l_time_phased_atp = 'Y' THEN
     FOR i IN 1..l_used_dc_qty.COUNT LOOP

        l_stealing_quantity := LEAST(l_used_dc_qty(i), (p_quantity_ordered - NVL(l_total_atp_qty, 0)));
        l_total_atp_qty := NVL(l_total_atp_qty, 0) + l_stealing_quantity;

        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_used_dc_qty(i) : ' || l_used_dc_qty(i));
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_stealing_quantity : ' || l_stealing_quantity);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_total_atp_qty : ' || l_total_atp_qty);
        END IF;

       IF p_demand_class <> l_used_dc_tab(i) THEN

        l_pf_stealing_qty  := LEAST(l_used_dc_qty(i)-NVL(l_used_dc_mem_qty(i), 0), l_stealing_quantity);
        l_mem_stealing_qty := l_stealing_quantity - l_pf_stealing_qty;
        x_atf_date_quantity := x_atf_date_quantity +  l_mem_stealing_qty ;
        x_used_available_quantity  := x_used_available_quantity + l_stealing_quantity;

        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_pf_stealing_qty : ' || l_pf_stealing_qty);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_mem_stealing_qty : ' || l_mem_stealing_qty);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_atf_date_quantity : ' || x_atf_date_quantity);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_used_available_quantity : ' || x_used_available_quantity);
        END IF;

       ELSE
        x_atf_date_quantity := x_atf_date_quantity + NVL(l_used_dc_mem_qty(i), 0);
        x_used_available_quantity  := x_used_available_quantity + NVL(l_used_dc_qty(i),0);

        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_atf_date_quantity :Else ' || x_atf_date_quantity);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_used_available_quantity :Else ' || x_used_available_quantity );
        END IF;
       END IF;
     END LOOP; 	--FOR i IN 1..l_used_dc_qty.COUNT LOOP
    END IF;

    --bug3409973 end
    -- Delete data from table, in case we re-visit this table within same transaction
    -- as this is a transaction specific global temporary table.

    DELETE msc_alloc_temp;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before setting pegging for : ' || p_item_name);
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_atf_date_quantity : ' || x_atf_date_quantity);
    END IF;
    -- Insert pegging record for Supply/ Stealing.

    l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
    l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
    l_pegging_rec.organization_id:= p_organization_id;
    l_pegging_rec.organization_code := l_org_code;
    l_pegging_rec.identifier1:= p_instance_id;
    l_pegging_rec.identifier2 := p_plan_id;

    -- time_phased_atp changes begin
    IF l_time_phased_atp = 'Y' THEN
            l_pegging_rec.inventory_item_id:= p_request_item_id;
            l_pegging_rec.inventory_item_name := p_item_name;
    ELSE
            l_pegging_rec.inventory_item_id:= p_inventory_item_id;
            l_pegging_rec.inventory_item_name := p_family_item_name;
    END IF;
    -- time_phased_atp changes end

    l_pegging_rec.resource_id := NULL;
    l_pegging_rec.resource_code := NULL;
    l_pegging_rec.department_id := NULL;
    l_pegging_rec.department_code := NULL;
    l_pegging_rec.supplier_id := NULL;
    l_pegging_rec.supplier_name := NULL;
    l_pegging_rec.supplier_site_id := NULL;
    l_pegging_rec.supplier_site_name := NULL;
    l_pegging_rec.scenario_id:= p_scenario_id;
    l_pegging_rec.component_identifier := MSC_ATP_PVT.G_COMP_LINE_ID;

    l_pegging_rec.constraint_flag := 'N';

    --- Enhance CTO Phase 1 Req #17
     -- Support Forward Stealing for components of ATO model in
     -- Model's sourcing organization.
    IF NVL(p_parent_pegging_id, 0) <> 0 THEN

       -- First add the demand record for the requirement in future.

      l_atp_rec.quantity_ordered := p_quantity_ordered;
      l_atp_rec.requested_ship_date := p_requested_date;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_atp_rec.quantity_ordered ='|| p_quantity_ordered);
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_atp_rec.requested_ship_date ='|| p_requested_date);
      END IF;
      --S-Cto_rearch: all demands are now dependent demand
      --l_atp_rec.origination_type := 30;
      l_atp_rec.origination_type := 1;

      -- Bug 3148248 fixed as part of time_phased_atp changes
      --   Use destination inventory_item_id
      --l_atp_rec.inventory_item_id := p_inventory_item_id;
      --l_atp_rec.request_item_id := p_inventory_item_id;
      l_atp_rec.inventory_item_id := l_pf_item_id;
      l_atp_rec.request_item_id := l_inv_item_id;
      l_atp_rec.atf_date := p_atf_date;
      l_atp_rec.requested_date_quantity := x_requested_date_quantity;
      l_atp_rec.atf_date_quantity := x_atf_date_quantity;
      -- time_phased_atp changes end

      l_atp_rec.organization_id := p_organization_id;
      l_atp_rec.demand_source_line := MSC_ATP_PVT.G_COMP_LINE_ID ;
      l_atp_rec.instance_id := p_instance_id;
      l_atp_rec.demand_class := p_demand_class;
      l_atp_rec.refresh_number := p_refresh_number;
      l_atp_rec.order_number := p_order_number;
      l_atp_rec.identifier := p_identifier;
      --l_atp_rec.demand_source_type := 2;
      l_atp_rec.demand_source_type := p_demand_source_type;--cmro
      l_atp_rec.demand_source_header_id := -1;

      MSC_ATP_DB_UTILS.Add_Mat_Demand(l_atp_rec,
                                 p_plan_id,
                                 1,     -- Demand Class True for forward stealing.
                                 l_demand_id);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after calling Add_Mat_Demand, l_demand_id ='||
                              l_demand_id);
      END IF;

      --bug 3432341: pass demand id back to calling module
      x_get_mat_out_rec.demand_id := l_demand_id;

       -- For component forward stealing need to add demand pegging.
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Before Adding Demand Pegging for  '|| p_item_name);
       END IF;

       l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
       l_pegging_rec.atp_level:= p_level + 1;
       l_pegging_rec.identifier3 := l_demand_id;
       l_pegging_rec.supply_demand_source_type:= 6;
       l_pegging_rec.supply_demand_type := 1;
       l_pegging_rec.supply_demand_quantity:= p_quantity_ordered ;
       l_pegging_rec.supply_demand_date:= p_requested_date;

         --- bug 2152184: For PF based ATP inventory_item_id field contains id for PF item
         --- cto looks at pegging tree to place their demands. Since CTO expects to find
         --  id for the requested item, we add the following column.
         -- CTO will now read from this column. For CTO components PF item same as request one.
       --l_pegging_rec.request_item_id := p_inventory_item_id;
       l_pegging_rec.request_item_id := p_request_item_id; -- time_phased_atp

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_pegging_rec.supply_demand_quantity:= : ' || p_quantity_ordered);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'l_pegging_rec.supply_demand_date:= : ' || p_requested_date);
       END IF;

       --diag_atp
       l_pegging_rec.pegging_type := MSC_ATP_PVT.ORG_DEMAND;
       l_pegging_rec.dest_inv_item_id := l_inv_item_id;
       l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;     -- for summary enhancement
       l_pegging_rec.required_date := p_requested_date;
       --bug 3328421:
       l_pegging_rec.actual_supply_demand_date := p_requested_date;
       l_pegging_rec.demand_class :=  p_demand_class;

       IF (p_get_mat_in_rec.parent_bom_item_type in (1, 4) and p_get_mat_in_rec.parent_repl_order_flag = 'Y')
                    --parent is model entity
                    OR (p_get_mat_in_rec.bom_item_type in (1, 4) and p_get_mat_in_rec.replenish_to_ord_flag = 'Y') THEN
           l_pegging_rec.model_sd_flag := 1;
       END IF;
       MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_demand_pegging_id);

       --s_cto_rearch: pass demand pegg back just in case PO date is better than Sch. rec. date
       x_get_mat_out_rec.demand_pegging_id := l_demand_pegging_id;

       MSC_ATP_PVT.G_CTO_FORWARD_DMD_PEG := l_demand_pegging_id;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after Add_Pegging : ' || l_demand_pegging_id);
       END IF;

    END IF;
    --- End Enhance CTO Phase 1 Req #17


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before setting pegging for : ' || p_item_name);
    END IF;
    -- Insert pegging record for Supply/ Stealing.

    --- Enhance CTO Phase 1 Req #17
     -- Support Forward Stealing for components of ATO model in
     -- Model's sourcing organization.
    IF NVL(p_parent_pegging_id, 0) = 0 THEN
      l_pegging_rec.parent_pegging_id:= MSC_ATP_PVT.G_DEMAND_PEGGING_ID;
      l_pegging_rec.atp_level:= p_level + 1;
    ELSE
      -- Stealing may happen at lower levels also
      -- not just for the requested item in MATO cases.
      -- Ensure that the pegging record is linked to the correct parent.
      l_pegging_rec.parent_pegging_id:= l_demand_pegging_id;
      l_pegging_rec.atp_level:= p_level + 2;
    END IF;
    --- End Enhance CTO Phase 1 Req #17
    l_pegging_rec.identifier3 := NULL;
    l_pegging_rec.supply_demand_type:= 2;
    l_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
    l_pegging_rec.source_type := 0;

    IF x_atp_date_this_level IS NULL THEN

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'x_atp_date_this_level null for : ' || p_item_name);
       END IF;

       l_stealing_flag := 'N';
       --x_requested_date_quantity := 0;
       x_atp_date_this_level := TRUNC(l_infinite_time_fence_date);
       x_atp_date_quantity_this_level := MSC_ATP_PVT.INFINITE_NUMBER;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before IF');
       END IF;

       IF l_used_dc_tab.COUNT > 0 THEN
          l_used_dc_tab.TRIM(l_used_dc_tab.COUNT);
          l_used_dc_qty.TRIM(l_used_dc_qty.COUNT);
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after IF : ' || l_used_dc_tab.COUNT);
       END IF;

       l_used_dc_tab.EXTEND;
       l_used_dc_qty.EXTEND;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after extend : ' || l_used_dc_tab.COUNT);
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before x_atp_pegging_tab : ' || x_atp_pegging_tab.COUNT);
       END IF;
       x_atp_pegging_tab.EXTEND;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after x_atp_pegging_tab : ' || x_atp_pegging_tab.COUNT);
       END IF;

       l_used_dc_tab(1) := p_demand_class;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after dc : ' || l_used_dc_tab.COUNT);
       END IF;

       l_used_dc_qty(1) :=  x_atp_date_quantity_this_level;
       l_pegging_rec.supply_demand_quantity:= x_atp_date_quantity_this_level;
       l_pegging_rec.supply_demand_date:= x_atp_date_this_level;

       -- time_phased_atp changes begin
       IF l_time_phased_atp = 'Y' and x_atp_date_this_level <= p_atf_date THEN
            l_pegging_rec.inventory_item_id:= p_request_item_id;
            l_pegging_rec.inventory_item_name := p_item_name;
       ELSE
            l_pegging_rec.inventory_item_id:= p_inventory_item_id;
            l_pegging_rec.inventory_item_name := p_family_item_name;
       END IF;
       -- time_phased_atp changes end

       l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;     -- for summary enhancement
       l_pegging_rec.required_date := p_requested_date;
       --bug3328421
       l_pegging_rec.actual_supply_demand_date := x_atp_date_this_level;
       --optional_fw
       IF MSC_ATP_PVT.G_FORWARD_ATP = 'N' THEN
         l_pegging_rec.constraint_type := 1;
       END IF;
       l_pegging_rec.model_sd_flag := 2;
       -- Bug 3826234 start
       IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check: ' || '----------- Calendars passed to Pegging -----------------');
         msc_sch_wb.atp_debug('ATP_Check: ' || 'shipping_cal_code = '      ||p_get_mat_in_rec.shipping_cal_code);
         msc_sch_wb.atp_debug('ATP_Check: ' || 'receiving_cal_code = '     ||p_get_mat_in_rec.receiving_cal_code);
         msc_sch_wb.atp_debug('ATP_Check: ' || 'intransit_cal_code = '     ||p_get_mat_in_rec.intransit_cal_code);
         msc_sch_wb.atp_debug('ATP_Check: ' || 'manufacturing_cal_code = ' ||p_get_mat_in_rec.manufacturing_cal_code);
         msc_sch_wb.atp_debug('ATP_Check: ' || 'to_organization_id = ' ||p_get_mat_in_rec.to_organization_id);
       END IF;
       IF p_parent_pegging_id is null then
          l_pegging_rec.shipping_cal_code      :=  p_get_mat_in_rec.shipping_cal_code;
          l_pegging_rec.receiving_cal_code     :=  p_get_mat_in_rec.receiving_cal_code;
          l_pegging_rec.intransit_cal_code     :=  p_get_mat_in_rec.intransit_cal_code;
          l_pegging_rec.manufacturing_cal_code :=  p_get_mat_in_rec.manufacturing_cal_code;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('ATP_Check: ' || 'Inside IF');
          END IF;
       ELSIF NVL(p_get_mat_in_rec.to_organization_id,p_get_mat_in_rec.organization_id)
                                                             <> p_get_mat_in_rec.organization_id THEN
          l_pegging_rec.shipping_cal_code      :=  p_get_mat_in_rec.shipping_cal_code;
          l_pegging_rec.receiving_cal_code     :=  p_get_mat_in_rec.receiving_cal_code;
          l_pegging_rec.intransit_cal_code     :=  p_get_mat_in_rec.intransit_cal_code;
          l_pegging_rec.manufacturing_cal_code :=  NULL;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('ATP_Check: ' || 'Inside ELSIF');
          END IF;
       ELSE
          l_pegging_rec.manufacturing_cal_code :=  p_get_mat_in_rec.manufacturing_cal_code;
          l_pegging_rec.shipping_cal_code      :=  NULL;
          l_pegging_rec.receiving_cal_code     :=  NULL;
          l_pegging_rec.intransit_cal_code     :=  NULL;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('ATP_Check: ' || 'Inside ELSE');
          END IF;
       END IF;
       -- Bug 3826234 end
       MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, x_atp_pegging_tab(1));

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after Add_Pegging : ' || x_atp_pegging_tab(1));
       END IF;
    ELSE
       l_stealing_quantity := 0;
       l_total_atp_qty := 0;
       l_pf_stealing_qty := 0;
       l_mem_stealing_qty := 0;
       FOR i IN 1..l_used_dc_qty.COUNT LOOP

           l_stealing_quantity := LEAST(l_used_dc_qty(i), (p_quantity_ordered - NVL(l_total_atp_qty, 0)));
           l_total_atp_qty := NVL(l_total_atp_qty, 0) + l_stealing_quantity;

           l_pegging_rec.supply_demand_quantity:= GREATEST(l_used_dc_qty(i), 0);
           l_pegging_rec.supply_demand_date:= x_atp_date_this_level;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'before inserting Stealing Info' || l_used_dc_tab(i));
           END IF;

           IF p_demand_class <> l_used_dc_tab(i) THEN
              -- Add the Stealing Data.

               IF l_time_phased_atp = 'N' THEN
                      MSC_ATP_DB_UTILS.Add_Stealing_Supply_Details (
                           p_plan_id,
                           p_identifier,
                           l_inv_item_id,
                           p_organization_id,
                           p_instance_id,
                           l_stealing_quantity,
                           p_demand_class,
                           l_used_dc_tab(i),
                           x_atp_date_this_level,
                           l_transaction_id,
                           p_refresh_number,
                           p_get_mat_in_rec.ato_model_line_id,   -- For summary enhancement
                           p_demand_source_type,--cmro
                           --bug3684383
                           p_order_number);
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'after insert into msc_alloc_supplies-Stealing Info' || l_transaction_id);
                      END IF;
               ELSE
                        l_pf_stealing_qty  := LEAST(l_used_dc_qty(i)-NVL(l_used_dc_mem_qty(i), 0), l_stealing_quantity);
                        l_mem_stealing_qty := l_stealing_quantity - l_pf_stealing_qty;

                       MSC_ATP_PF.Add_PF_Stealing_Supply_Details (
                                        p_plan_id,
                                        p_identifier,
                                        l_inv_item_id,
                                        l_pf_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_mem_stealing_qty,
                                        l_pf_stealing_qty,
                                        p_demand_class,
                                        l_used_dc_tab(i),
                                        x_atp_date_this_level,
                                        p_atf_date,
                                        p_refresh_number, -- for summary enhancement
                                        l_transaction_id,
                                        p_get_mat_in_rec.ato_model_line_id,
                                        p_demand_source_type,--cmro
                                        --bug3684383
                                        p_order_number,
                                        l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_Forward_Material_Atp: ' || 'Error occured in procedure Add_PF_Stealing_Supply_Details');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
               END IF;
               -- time_phased_atp changes end

               l_pegging_rec.identifier3 := l_transaction_id;
               l_pegging_rec.char1 := l_used_dc_tab(i);

           END IF;	--IF p_demand_class <> l_used_dc_tab(i) THEN

           -- time_phased_atp changes begin
           IF l_time_phased_atp = 'Y' and x_atp_date_this_level <= p_atf_date THEN
                    l_pegging_rec.inventory_item_id:= p_request_item_id;
                    l_pegging_rec.inventory_item_name := p_item_name;
           ELSE
                    l_pegging_rec.inventory_item_id:= p_inventory_item_id;
                    l_pegging_rec.inventory_item_name := p_family_item_name;
           END IF;
           -- time_phased_atp changes end

           x_atp_pegging_tab.EXTEND;
           --diag_atp
           l_pegging_rec.plan_name := p_get_mat_in_rec.plan_name;
           l_pegging_rec.required_quantity:= p_quantity_ordered;
           l_pegging_rec.required_date := p_requested_date;
           --bug 3328421
           l_pegging_rec.actual_supply_demand_date := x_atp_date_this_level;

           --bug 3443276: Add constarint only if ATP date is later than request date
           --optional_fw
           IF x_atp_date_this_level > p_requested_date AND MSC_ATP_PVT.G_FORWARD_ATP = 'N' THEN
              l_pegging_rec.constraint_type := 1;
           END IF;
           l_pegging_rec.infinite_time_fence := l_infinite_time_fence_date;
           l_pegging_rec.atp_rule_name := x_get_mat_out_rec.atp_rule_name;
           l_pegging_rec.rounding_control := l_round_flag;
           l_pegging_rec.atp_flag :=  MSC_ATP_PVT.G_ITEM_INFO_REC.atp_flag;
           l_pegging_rec.atp_component_flag := MSC_ATP_PVT.G_ITEM_INFO_REC.atp_comp_flag;
           l_pegging_rec.pegging_type := MSC_ATP_PVT.ATP_SUPPLY; ---atp supply node
           l_pegging_rec.postprocessing_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.pre_pro_lt;
           l_pegging_rec.preprocessing_lead_time :=  MSC_ATP_PVT.G_ITEM_INFO_REC.post_pro_lt;
           l_pegging_rec.fixed_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.fixed_lt;
           l_pegging_rec.variable_lead_time :=  MSC_ATP_PVT.G_ITEM_INFO_REC.variable_lt;
           l_pegging_rec.weight_capacity := MSC_ATP_PVT.G_ITEM_INFO_REC.unit_weight;
           l_pegging_rec.volume_capacity := MSC_ATP_PVT.G_ITEM_INFO_REC.unit_volume;
           l_pegging_rec.weight_uom :=  MSC_ATP_PVT.G_ITEM_INFO_REC.weight_uom;
           l_pegging_rec.volume_uom := MSC_ATP_PVT.G_ITEM_INFO_REC.volume_uom;
           l_pegging_rec.allocation_rule := MSC_ATP_PVT.G_ALLOCATION_RULE_NAME;
           l_pegging_rec.substitution_window  := MSC_ATP_PVT.G_ITEM_INFO_REC.substitution_window;


           l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;     -- for summary enhancement
           l_pegging_rec.required_date := p_requested_date;
           l_pegging_rec.model_sd_flag := 2;
           MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, x_atp_pegging_tab(i));

       END LOOP;	--FOR i IN 1..l_used_dc_qty.COUNT LOOP
    END IF;	--IF NVL(l_stealing_flag, 'N') = 'Y' THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********End Get_Forward_Material_Atp Procedure************');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_requested_date_quantity := 0.0;
        x_atp_date_this_level := TRUNC(l_infinite_time_fence_date);
        x_atp_date_quantity_this_level := MSC_ATP_PVT.INFINITE_NUMBER;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp, no data found');
        END IF;
    WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN --bug3583705
        x_requested_date_quantity := 0.0;
        x_atp_date_this_level := TRUNC(l_infinite_time_fence_date);
        x_atp_date_quantity_this_level := MSC_ATP_PVT.INFINITE_NUMBER;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('MAtching cal date not found, in atp_check');
        END IF;
        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp, sqlcode= '||sqlcode);
           msc_sch_wb.atp_debug('Get_Forward_Material_Atp, sqlerrm= '||sqlerrm);
        END IF;
        x_requested_date_quantity := 0.0;
        x_atp_date_this_level := TRUNC(l_infinite_time_fence_date);
        x_atp_date_quantity_this_level := MSC_ATP_PVT.INFINITE_NUMBER;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        /*IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Get_Forward_Material_Atp');
        END IF;*/ --bug3583705

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Forward_Material_Atp;


END MSC_AATP_REQ;

/

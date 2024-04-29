--------------------------------------------------------
--  DDL for Package Body MSC_ATP_DB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_DB_UTILS" AS
/* $Header: MSCDATPB.pls 120.9.12010000.9 2010/03/15 06:43:44 aksaxena ship $  */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'MSC_ATP_DB_UTILS';

-- dsting: 0 if Clear_SD_Details_temp has been called, 0 otherwise.
-- used to save 1 delete in sd performance enh
PG_CLEAR_SD_DETAILS_TEMP	NUMBER := 0;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');
G_ORIG_INV_CTP NUMBER := FND_PROFILE.value('INV_CTP'); -- Bug 3295831.
        -- Added to control summary operations.

--5357370 private declaration
PROCEDURE UNDO_DELETE_SUMMARY_ROW (p_identifier                      IN NUMBER,
                                   p_instance_id                     IN NUMBER,
                                   p_demand_source_type              IN NUMBER
                                   );

PROCEDURE Add_Mat_Demand(
  p_atp_rec          IN		MRP_ATP_PVT.AtpRec ,
  p_plan_id          IN         NUMBER ,
  p_dc_flag          IN         NUMBER,
  x_demand_id        OUT        NoCopy NUMBER
)

IS
l_sqlfound	BOOLEAN := FALSE;
my_sqlcode 	NUMBER;
l_count         NUMBER;
temp_sd_qty     number;
l_record_source number := 2; -- for plan order pegging

-- time_phased_atp
l_time_phased_atp       varchar2(1) := 'N';
l_insert_item_id        number;
l_return_status         varchar2(1);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Mat_Demand *****');
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.quantity_ordered '||p_atp_rec.quantity_ordered);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.requested_ship_date '||p_atp_rec.requested_ship_date);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.origination_type '||p_atp_rec.origination_type);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.inventory_item_id '||p_atp_rec.inventory_item_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.organization_id '||p_atp_rec.organization_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.demand_source_line '||p_atp_rec.demand_source_line);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.demand_source_type '||p_atp_rec.demand_source_type);--cmro
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.instance_id '||p_atp_rec.instance_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_plan_id = ' || p_plan_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.action '||p_atp_rec.action);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'old_demand_id := ' || p_atp_rec.old_demand_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'demand class := ' || p_atp_rec.demand_class);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.request_item_id := ' || p_atp_rec.request_item_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.atf_date := ' || p_atp_rec.atf_date);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'ato model line id := ' || p_atp_rec.ato_model_line_id);
    END IF;

    -- time_phased_atp changes begin
    IF (p_atp_rec.inventory_item_id <> p_atp_rec.request_item_id) and p_atp_rec.atf_date is not null THEN
        l_time_phased_atp := 'Y';
        /* In time phased atp scenarios add demand in msc_demands for member item*/
        l_insert_item_id := p_atp_rec.request_item_id;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Time Phased ATP = ' || l_time_phased_atp);
        END IF;
    ELSE
        l_insert_item_id := p_atp_rec.inventory_item_id;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Insert demand in msc_demands for ' || l_insert_item_id);
    END IF;
    -- time_phased_atp changes end

    IF (p_plan_id = -1) THEN  -- ods, put into ods tables

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'ODS based ATP, Add into MSC_SALES Orders');
            msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.original_request_ship_date: ' ||p_atp_rec.original_request_ship_date);
        END IF;

        INSERT INTO MSC_SALES_ORDERS(
                DEMAND_ID,
                SR_INSTANCE_ID,
                INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                DEMAND_SOURCE_TYPE,
                DEMAND_SOURCE_HEADER_ID,
                DEMAND_SOURCE_LINE,
                DEMAND_SOURCE_DELIVERY,
                PRIMARY_UOM_QUANTITY,
                COMPLETED_QUANTITY,
                RESERVATION_TYPE,
                REQUIREMENT_DATE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                DEMAND_CLASS,
                ATP_REFRESH_NUMBER,
                SALES_ORDER_NUMBER,
                ato_line_id,
                RECORD_SOURCE,       -- bug 2810112
                REQUEST_SHIP_DATE,   --plan by request date
                SCHEDULE_SHIP_DATE,  --plan by request date
                CUSTOMER_ID,         --bug3263368
                SHIP_TO_SITE_USE_ID, --bug3263368
                --MFG_LEAD_TIME, --bug3263368
                --bug3578083 New column Intransit_lead_time was added for bug 3403975
                --which now holds the value of Intransit Lead Time
                INTRANSIT_LEAD_TIME,
                SHIP_SET_NAME, --bug3263368
                ARRIVAL_SET_NAME) --bug3263368
        VALUES( msc_demands_s.nextval,
                p_atp_rec.instance_id,
                p_atp_rec.inventory_item_id,
                p_atp_rec.organization_id,
                p_atp_rec.demand_source_type,
                p_atp_rec.demand_source_header_id,
                p_atp_rec.demand_source_line,
                p_atp_rec.demand_source_delivery,
                MSC_ATP_UTILS.Truncate_Demand(p_atp_rec.quantity_ordered),  --5598066
                0,
                1,
                TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY , -- For bug 2259824
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                p_atp_rec.demand_class,
                p_atp_rec.refresh_number,
                p_atp_rec.order_number,
                p_atp_rec.ato_model_line_id,
                l_record_source, -- bug 2810112
                --start changes for plan by request date
                p_atp_rec.original_request_ship_date,
                p_atp_rec.requested_ship_date + MSC_ATP_PVT.G_END_OF_DAY,
                --end changes for plan by request date
                MSC_ATP_PVT.G_PARTNER_ID,
                MSC_ATP_PVT.G_PARTNER_SITE_ID,
                p_atp_rec.delivery_lead_time, --bug3263368
                p_atp_rec.ship_set_name, --bug3263368
                p_atp_rec.arrival_set_name --bug3263368
                )
        RETURNING DEMAND_ID INTO x_demand_id;

        IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Insert into summary table');
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || ' update msc_atp_summary_so');
            END IF;
            -- use hint to do index search
            MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_atp_rec.instance_id,
                                               -1,
                                               p_atp_rec.organization_id,
                                               p_atp_rec.inventory_item_id,
                                               p_atp_rec.requested_ship_date,
                                               null,
                                               null,
                                               null,
                                               null,
                                               p_dc_flag,
                                               p_atp_rec.demand_class,
                                               1);
            UPDATE  /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
            set     sd_qty = sd_qty + p_atp_rec.quantity_ordered
            where   inventory_item_id = p_atp_rec.inventory_item_id
            and     organization_id = p_atp_rec.organization_id
            and     sr_instance_id = p_atp_rec.instance_id
            and     sd_date = trunc(p_atp_rec.requested_ship_date)
            and     demand_class = Decode(p_dc_flag, 1, NVL(p_atp_rec.demand_class, '@@@'),'@@@');

            IF SQL%NOTFOUND THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Add_Mat_Demand: ' || ' insert into msc_atp_summary_so');
                END IF;
                BEGIN
                      --- use hint to do index search
                    insert /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ into msc_atp_summary_so
                           (plan_id,
                            inventory_item_id,
                            organization_id,
                            sr_instance_id,
                            sd_date,
                            sd_qty,
                            demand_class,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY
                           )
                    VALUES
                        (-1,
                        p_atp_rec.inventory_item_id,
                        p_atp_rec.organization_id,
                        p_atp_rec.instance_id,
                        -- 2161453 truncate the date
                        -- if we dont truncate the date then same days will have different enteries
                        -- with diiferet time components
                        trunc(p_atp_rec.requested_ship_date),
                        p_atp_rec.quantity_ordered,
                        Decode(p_dc_flag, 1, NVL(p_atp_rec.demand_class, '@@@') ,'@@@'),
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID);
                EXCEPTION
                    WHEN  DUP_VAL_ON_INDEX THEN
                        MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_atp_rec.instance_id,
                                                           -1,
                                                           p_atp_rec.organization_id,
                                                           p_atp_rec.inventory_item_id,
                                                           p_atp_rec.requested_ship_date,
                                                           null,
                                                           null,
                                                           null,
                                                           null,
                                                           p_dc_flag,
                                                           p_atp_rec.demand_class,
                                                           1);

                        UPDATE  /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                        set     sd_qty = sd_qty + p_atp_rec.quantity_ordered
                        where   inventory_item_id = p_atp_rec.inventory_item_id
                        and     organization_id = p_atp_rec.organization_id
                        and     sr_instance_id = p_atp_rec.instance_id
                        and     sd_date = trunc(p_atp_rec.requested_ship_date)
                        and     demand_class = Decode(p_dc_flag, 1, NVL(p_atp_rec.demand_class, '@@@'),'@@@');

                END;

            END IF;
        END IF;
    ELSE  -- pds, put into pds tables

        --as this code is redundent commenting it out avjain
        /*IF (p_atp_rec.origination_type IN (6, 30)) AND NVL(p_atp_rec.old_demand_id, 0) > 0 THEN

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'inside update of msc_demands');
            END IF;

            -- For bug 2259824, move the demand to the end of day
            UPDATE  msc_demands
            SET     using_requirement_quantity = p_atp_rec.quantity_ordered,
                     USING_ASSEMBLY_DEMAND_DATE=
                     decode(MSC_ATP_PVT.G_PLAN_INFO_REC.schedule_by_date_type,
                    MSC_ATP_PVT.G_SCHEDULE_DATE_LEGEND,
                    	TRUNC(NVL(p_atp_rec.requested_ship_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                    MSC_ATP_PVT.G_PROMISE_DATE_LEGEND,
                    	TRUNC(NVL(p_atp_rec.requested_ship_date,PROMISE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                    MSC_ATP_PVT.G_REQUEST_DATE_LEGEND,
                    	p_atp_rec.requested_ship_date,
                    TRUNC(NVL(p_atp_rec.requested_ship_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY),
                    schedule_ship_date = TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,--added by avjain
                    promise_ship_date = TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,--added by avjain
                    request_ship_date=TRUNC(p_atp_rec.original_request_ship_date),--added by avjain
                    --request_arrival_date=TRUNC(p_atp_rec.original_request_arrival_date),--added by avjain
                    demand_type = 1,
                    origination_type = p_atp_rec.origination_type,
                    plan_id = p_plan_id,
                    organization_id = p_atp_rec.organization_id,
                    last_update_date = sysdate,
                    last_updated_by = FND_GLOBAL.USER_ID,
                    demand_class = p_atp_rec.demand_class,
                    refresh_number = p_atp_rec.refresh_number,
                    order_number = decode(p_atp_rec.origination_type, 6, p_atp_rec.order_number,
                                                                     30, p_atp_rec.order_number,
                                                                         null),
                    applied = decode(p_atp_rec.origination_type, 6, 2, 30, 2, null),
                    status = decode(p_atp_rec.origination_type, 6, 0, 30, 0, null),
                    customer_id = MSC_ATP_PVT.G_PARTNER_ID,
                    ship_to_site_id = MSC_ATP_PVT.G_PARTNER_SITE_ID,
                    inventory_item_id = p_atp_rec.inventory_item_id,
                    -- 24x7
                    atp_synchronization_flag = 0,
                    -- bug 2795053-reopen (ssurendr) update the demand_satisfied_date in msc_demands
                    dmd_satisfied_date = TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY
            WHERE  sr_instance_id = p_atp_rec.instance_id
            AND    plan_id = p_plan_id
            AND    sales_order_line_id = p_atp_rec.demand_source_line
            AND    demand_id = p_atp_rec.old_demand_id
            RETURNING DEMAND_ID INTO x_demand_id;

            l_sqlfound := SQL%NOTFOUND;

            IF NOT l_sqlfound THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'found demand and updated demand_id : ' || x_demand_id);
                END IF;
                -- Allocated ATP Based on Planning Details -- Agilent changes Begin

                IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                   (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                   (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                   (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
	                    msc_sch_wb.atp_debug('Add_Mat_Demand: before update of msc_alloc_demands');
	                END IF;

                    UPDATE  msc_alloc_demands
                    SET     old_allocated_quantity = allocated_quantity,
                            old_demand_date = demand_date,
                            plan_id = p_plan_id,
                            organization_id = p_atp_rec.organization_id,
                            demand_class = p_atp_rec.demand_class,
                            demand_date = p_atp_rec.requested_ship_date,
                            parent_demand_id = x_demand_id,
                            allocated_quantity = p_atp_rec.quantity_ordered,
                            origination_type = p_atp_rec.origination_type,
                            inventory_item_id = p_atp_rec.inventory_item_id,
                            order_number = decode(p_atp_rec.origination_type,
                            6, p_atp_rec.order_number,
                            30, p_atp_rec.order_number, null),
                            last_updated_by = FND_GLOBAL.USER_ID,
                            last_update_date = sysdate,
                            refresh_number = p_atp_rec.refresh_number -- For summary enhancement
                    WHERE   sr_instance_id = p_atp_rec.instance_id
                    AND     plan_id = p_plan_id
                    AND     sales_order_line_id = p_atp_rec.demand_source_line
                    AND     parent_demand_id = p_atp_rec.old_demand_id;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'No of rows updated := ' || SQL%ROWCOUNT);
                    END IF;

                END IF;

                -- Allocated ATP Based on Planning Details -- Agilent changes End

            END IF;
        END IF; 		--(p_atp_rec.origination_type IN (6, 30)) THEN
	*/

        IF (SQL%NOTFOUND OR (p_atp_rec.origination_type NOT IN (6, 30)) OR
                                      NVL(p_atp_rec.old_demand_id,0 ) = 0)   THEN

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'before insert into msc_demands');
            END IF;

            INSERT INTO MSC_DEMANDS(
                    DEMAND_ID,
                    USING_REQUIREMENT_QUANTITY,
                    SCHEDULE_SHIP_DATE,         --plan by request date
                    USING_ASSEMBLY_DEMAND_DATE,
                    promise_ship_date,          --plan by request date
                    request_ship_date,          --plan by request date
                    DEMAND_TYPE,
                    DEMAND_SOURCE_TYPE, --cmro
                    ORIGINATION_TYPE,
                    USING_ASSEMBLY_ITEM_ID,
                    PLAN_ID,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    SALES_ORDER_LINE_ID,
                    SR_INSTANCE_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    DEMAND_CLASS,
                    REFRESH_NUMBER,
                    ORDER_NUMBER,
                    APPLIED,
                    STATUS,
                    CUSTOMER_ID,
                    SHIP_TO_SITE_ID,
                    RECORD_SOURCE,  -- For plan order pegging
                    -- 24x7
                    ATP_SYNCHRONIZATION_FLAG,
                    -- bug 2795053-reopen (ssurendr) insert the demand_satisfied_date in msc_demands
                    DMD_SATISFIED_DATE,
                    -- rajjain bug 2771075 04/25/2003 Populate disposition_id column with the demand_id
                    DISPOSITION_ID,
                    --s_cto_rearch
                    LINK_TO_LINE_ID,
                    ATO_LINE_ID,
                    TOP_MODEL_LINE_ID,
                    parent_model_line_id,
                    std_mandatory_comp_flag,
                    wip_supply_type,
                    --e_cto_rearch
                    /* time_phased_atp
                       We no longer require Add_Mat_Demand in MSC_ATP_Subst*/
                    ORIGINAL_ITEM_ID ,
                    SHIP_METHOD, -- For ship_rec_cal
                    atp_session_id,
                    INTRANSIT_LEAD_TIME, --bug3263368
                    SHIP_SET_NAME, --bug3263368
                    ARRIVAL_SET_NAME --bug3263368
                    )
            VALUES(
                    msc_demands_s.nextval,
                    MSC_ATP_UTILS.Truncate_Demand(p_atp_rec.quantity_ordered),	-- 5598066
                    -- start changes for plan by request date
                    decode(p_atp_rec.origination_type,
                           6,  TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                           30, TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                               null), --plan by request date
                    decode(p_atp_rec.origination_type,
                           6,  decode(MSC_ATP_PVT.G_PLAN_INFO_REC.schedule_by_date_type,
                                      MSC_ATP_PVT.G_SCHEDULE_SHIP_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_SCHEDULE_ARRIVAL_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_PROMISE_SHIP_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_PROMISE_ARRIVAL_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_REQUEST_SHIP_DATE_LEGEND,
                                          p_atp_rec.original_request_ship_date,
                                      MSC_ATP_PVT.G_REQUEST_ARRIVAL_DATE_LEGEND,
                                          p_atp_rec.original_request_ship_date,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY),
                           30, decode(MSC_ATP_PVT.G_PLAN_INFO_REC.schedule_by_date_type,
                                      MSC_ATP_PVT.G_SCHEDULE_SHIP_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_SCHEDULE_ARRIVAL_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_PROMISE_SHIP_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_PROMISE_ARRIVAL_DATE_LEGEND,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                      MSC_ATP_PVT.G_REQUEST_SHIP_DATE_LEGEND,
                                          p_atp_rec.original_request_ship_date,
                                      MSC_ATP_PVT.G_REQUEST_ARRIVAL_DATE_LEGEND,
                                          p_atp_rec.original_request_ship_date,
                                          TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY),
                           TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY), --plan by request date
                    decode(p_atp_rec.origination_type,
                           6,  TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                           30, TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                               null), -- plan by request date
                    decode(p_atp_rec.origination_type,
                           6,  p_atp_rec.original_request_ship_date,
                           30, p_atp_rec.original_request_ship_date,
                               null), -- plan by request date
                    -- end changes for plan by request date
                    1, -- discrete demand
                    p_atp_rec.demand_source_type,  --cmro
                    p_atp_rec.origination_type,
                    l_insert_item_id, -- for time_phased_atp
                    p_plan_id,
                    p_atp_rec.organization_id,
                    l_insert_item_id, -- for time_phased_atp
                    p_atp_rec.demand_source_line,
                    p_atp_rec.instance_id,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    --p_atp_rec.demand_class,
                    ---bug 2424357: we do not store the converted demand class
                    -- always store the actual demand class.
                    DECODE(MSC_ATP_PVT.G_HIERARCHY_PROFILE, 1, MSC_ATP_PVT.G_ATP_DEMAND_CLASS,
                                                            2, p_atp_rec.demand_class),
                    p_atp_rec.refresh_number,
                    /* s_cto_rearch
                    -- Modified by ngoel on 1/12/2001 for origination_type = 30
                    decode(p_atp_rec.origination_type, 6, p_atp_rec.order_number,
                        30, p_atp_rec.order_number,
                        null),
                    e_cto_rearch */
                    --s_cto_rearch
                    p_atp_rec.order_number,
                    decode(p_atp_rec.origination_type, 6, 2, 30, 2, null),
                    decode(p_atp_rec.origination_type, 6, 0, 30, 0, null),
                    --decode(p_atp_rec.origination_type, 6, MSC_ATP_PVT.G_PARTNER_ID, 30, MSC_ATP_PVT.G_PARTNER_ID, null),
                    --decode(p_atp_rec.origination_type, 6, MSC_ATP_PVT.G_PARTNER_SITE_ID, 30, MSC_ATP_PVT.G_PARTNER_SITE_ID, null),
                    MSC_ATP_PVT.G_PARTNER_ID,
                    MSC_ATP_PVT.G_PARTNER_SITE_ID,
                    l_record_source, -- For plan order pegging
                    -- 24x7
                    0,
                    -- bug 2795053-reopen (ssurendr) insert the demand_satisfied_date in msc_demands
                    TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                    msc_demands_s.nextval,
                    --s_cto_rearch
                    p_atp_rec.parent_line_id,
                    p_atp_rec.ato_model_line_id,
                    p_atp_rec.top_model_line_id,
                    p_atp_rec.ATO_Parent_Model_Line_Id,
                    p_atp_rec.mand_comp_flag,
                    p_atp_rec.wip_supply_type,
                    --e_cto_rearch)
                    p_atp_rec.original_item_id, -- time_phased_atp
                    p_atp_rec.ship_method,      -- For ship_rec_cal
                    p_atp_rec.session_id,
                    p_atp_rec.delivery_lead_time, --bug3263368
                    p_atp_rec.ship_set_name, --bug3263368
                    p_atp_rec.arrival_set_name --bug3263368
                )
            RETURNING DEMAND_ID INTO x_demand_id;

            -- time_phased_atp
            IF l_time_phased_atp = 'Y' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_Mat_Demand: Time phased ATP = '|| l_time_phased_atp);
                END IF;
                MSC_ATP_PF.Add_PF_Bucketed_Demands(
                        p_atp_rec,
                        p_plan_id,
                        x_demand_id,
                        p_atp_rec.refresh_number,
                        l_return_status
                );
                --5158454 Preserve the SO demand id for the first run.
                IF MSC_ATP_PVT.G_OPTIONAL_FW is null AND MSC_ATP_PVT.G_FORWARD_ATP = 'Y'
                   AND p_atp_rec.origination_type in (6,30) THEN
                   MSC_ATP_PVT.G_DEMAND_ID := x_demand_id;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_Mat_Demand: MSC_ATP_PVT.G_DEMAND_ID = '|| MSC_ATP_PVT.G_DEMAND_ID);
                END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Error occured in procedure Add_PF_Bucketed_Demands');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

            -- Allocated ATP Based on Planning Details -- Agilent changes Begin
            ELSIF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
               (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
               (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
               (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Add_Mat_Demand: before insert into msc_alloc_demands');
                END IF;

                INSERT INTO MSC_ALLOC_DEMANDS(
                        PLAN_ID,
                        INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        SR_INSTANCE_ID,
                        DEMAND_CLASS,
                        DEMAND_SOURCE_TYPE, --cmro
                        DEMAND_DATE,
                        PARENT_DEMAND_ID,
                        ALLOCATED_QUANTITY,
                        ORIGINATION_TYPE,
                        ORDER_NUMBER,
                        SALES_ORDER_LINE_ID,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        REFRESH_NUMBER, -- For summary enhancement
                        --bug3684383 added as in Insert_SD_Into_Details_Temp we need these columns populated
			-- to show partner name and location.
                        CUSTOMER_ID,
                        SHIP_TO_SITE_ID
                       )
                VALUES (
                        p_plan_id,
                        l_insert_item_id, -- for time_phased_atp,
                        p_atp_rec.organization_id,
                        p_atp_rec.instance_id,
                        p_atp_rec.demand_class,
                        p_atp_rec.demand_source_type,--CMRO
                        p_atp_rec.requested_ship_date, -- QUESTION arrival items ?
                        x_demand_id,
                        MSC_ATP_UTILS.Truncate_Demand(p_atp_rec.quantity_ordered),	-- 5598066
                        p_atp_rec.origination_type,
                        -- rajjain 04/25/2003 Bug 2770175 populate order_number column with the

                        --decode(p_atp_rec.origination_type, 1, x_demand_id, p_atp_rec.order_number),
                        -- s_cto_rearch insert order number
                        p_atp_rec.order_number,

                        p_atp_rec.demand_source_line,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        p_atp_rec.refresh_number,
                        --bug3684383
                        decode(p_atp_rec.origination_type, 6, MSC_ATP_PVT.G_PARTNER_ID,
                                                           30, MSC_ATP_PVT.G_PARTNER_ID,
                                                           null),
                        decode(p_atp_rec.origination_type, 6, MSC_ATP_PVT.G_PARTNER_SITE_ID,
                                                           30, MSC_ATP_PVT.G_PARTNER_SITE_ID,
                                                           null));
            END IF;

            -- Allocated ATP Based on Planning Details -- Agilent changes End

        END IF; 	--(p_atp_rec.origination_type NOT IN (6, 30) OR SQL%ROWCOUNT = 0)


        -- Update summary records only in ODS - for summary enhancement
        IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND p_plan_id = -1 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'add demands to summary tables');
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'First try to update');
            END IF;

            MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_atp_rec.instance_id,
                                              p_plan_id,
                                              p_atp_rec.organization_id,
                                              p_atp_rec.inventory_item_id,
                                              p_atp_rec.requested_ship_date,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              2);

            update /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) */ msc_atp_summary_sd
            set sd_qty = sd_qty - p_atp_rec.quantity_ordered
            where inventory_item_id =  p_atp_rec.inventory_item_id
            and   plan_id = p_plan_id
            and   sr_instance_id = p_atp_rec.instance_id
            and   organization_id = p_atp_rec.organization_id
            and   sd_date = trunc(p_atp_rec.requested_ship_date);

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'After update  to summary table');
            END IF;

            IF SQL%NOTFOUND THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Couldnt find a rec in summ table. Insert new rec');
                END IF;

                MSC_ATP_DB_UTILS.INSERT_SUMMARY_SD_ROW(p_plan_id,
                                                       p_atp_rec.instance_id,
                                                       p_atp_rec.organization_id,
                                                       p_atp_rec.inventory_item_id,
                                                       p_atp_rec.requested_ship_date,
                                                       -1 * p_atp_rec.quantity_ordered,
                                                       '@@@');
            END IF;
        END IF;

    END IF;
    my_sqlcode := SQLCODE;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'x_demand_id '||x_demand_id);
        msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'insert row: sqlcode =  '|| to_char(my_sqlcode));
    END IF;

    -- Commit chenges only in PDS - for summary enhancement
    IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') AND p_plan_id = -1 THEN
        -- in case of summmary mode we always commit after each change
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Commit in summary mode');
        END IF;
        commit;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** End Add_Mat_Demand *****');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        my_sqlcode := SQLCODE;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'error in insert row: sqlcode =  '|| to_char(my_sqlcode));
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Add_Mat_Demand');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_Mat_Demand;


PROCEDURE Add_Pegging(
    p_pegging_rec          IN         mrp_atp_details_temp%ROWTYPE,
    x_pegging_id           OUT        NoCopy NUMBER
)
IS
temp number;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Pegging Procedure *****');
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'p_pegging_rec.ptf_date := ' || p_pegging_rec.ptf_date);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'pegging component_identifier : '||
            p_pegging_rec.component_identifier);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'Parent peg id := ' || p_pegging_rec.parent_pegging_id);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'scaling_type := ' || p_pegging_rec.scaling_type);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'scale_multiple := ' || p_pegging_rec.scale_multiple);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'scale_rounding_variance := ' || p_pegging_rec.scale_rounding_variance);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'rounding_direction := ' || p_pegging_rec.rounding_direction);
        msc_sch_wb.atp_debug('Add_Pegging: ' || 'component_yield_factor := ' || p_pegging_rec.component_yield_factor);

    END IF;

    INSERT into mrp_atp_details_temp
           (session_id,
            order_line_id,
            pegging_id,
            parent_pegging_id,
            atp_level,
            record_type,
            organization_id,
            organization_code,
            identifier1,
            identifier2,
            identifier3,
            inventory_item_id,
            inventory_item_name,
            resource_id,
            resource_code,
            department_id,
            department_code,
            supplier_id,
            supplier_name,
            supplier_site_id,
            supplier_site_name,
            scenario_id,
            source_type,
            supply_demand_source_type,
            supply_demand_quantity,
            supply_demand_type,
            supply_demand_date,
            end_pegging_id,
            constraint_flag,
            allocated_quantity, -- 1527660
            number1,
            char1,
            component_identifier,
            batchable_flag,
            supplier_atp_date,
            dest_inv_item_id,
            summary_flag,
            --- bug 2152184: For PF based ATP inventory_item_id field contains id for PF item
            --- cto looks at pegging tree to place their demands. Since CTO expects to find
            --  id for the requested item, we add the following column. CTO will now read from this column
            request_item_id,
            --- if req-date < ptf date then we update this column with PTF date
            ptf_date
            -- dsting
            , creation_date
            , created_by
            , last_update_date
            , last_updated_by
            , last_update_login,
            --diag_atp
            FIXED_LEAD_TIME,
            VARIABLE_LEAD_TIME,
            PREPROCESSING_LEAD_TIME,
            PROCESSING_LEAD_TIME,
            POSTPROCESSING_LEAD_TIME,
            INTRANSIT_LEAD_TIME,
            ALLOCATION_RULE,
            INFINITE_TIME_FENCE,
            SUBSTITUTION_WINDOW,
            REQUIRED_QUANTITY,
            ROUNDING_CONTROL,
            ATP_FLAG,
            ATP_COMPONENT_FLAG,
            REQUIRED_DATE,
            OPERATION_SEQUENCE_ID,
            SOURCING_RULE_NAME,
            OFFSET,
            EFFICIENCY,
            REVERSE_CUM_YIELD,
            BASIS_TYPE,
            USAGE,
            CONSTRAINT_TYPE,
            CONSTRAINT_DATE,
            UTILIZATION,
            OWNING_DEPARTMENT,
            ATP_RULE_NAME,
            PLAN_NAME,
            weight_capacity,
            volume_capacity,
            weight_uom,
            volume_uom,
            pegging_type,
            ship_method,
            --s_cto_rearch
            model_sd_flag,
            error_code,
            base_model_id,
            base_model_name,
            nonatp_flag,
            demand_class,
            customer_id,
            CUSTOMER_SITE_ID,
            receiving_organization_id,
            actual_supply_demand_date,
            --e_cto_rearch
            aggregate_time_fence_date, -- For time_phased_atp
            shipping_cal_code,     -- Bug 3826234
            receiving_cal_code,    -- Bug 3826234
            intransit_cal_code,    -- Bug 3826234
            manufacturing_cal_code, -- Bug 3826234
            --4570421
            scaling_type,
            scale_multiple,
            scale_rounding_variance,
            rounding_direction,
            component_yield_factor,
            organization_type --4775920
           )
    VALUES
           (p_pegging_rec.session_id,
            p_pegging_rec.order_line_id,
            msc_full_pegging_s.nextval,
            p_pegging_rec.parent_pegging_id,
            p_pegging_rec.atp_level,
            3,
            p_pegging_rec.organization_id,
            p_pegging_rec.organization_code,
            p_pegging_rec.identifier1,
            p_pegging_rec.identifier2,
            p_pegging_rec.identifier3,
            p_pegging_rec.inventory_item_id,
            p_pegging_rec.inventory_item_name,
            p_pegging_rec.resource_id,
            p_pegging_rec.resource_code,
            p_pegging_rec.department_id,
            p_pegging_rec.department_code,
            p_pegging_rec.supplier_id,
            p_pegging_rec.supplier_name,
            p_pegging_rec.supplier_site_id,
            p_pegging_rec.supplier_site_name,
            p_pegging_rec.scenario_id,
            p_pegging_rec.source_type,
            p_pegging_rec.supply_demand_source_type,
            p_pegging_rec.supply_demand_quantity,
            p_pegging_rec.supply_demand_type,
            p_pegging_rec.supply_demand_date,
            NVL(MSC_ATP_PVT.G_DEMAND_PEGGING_ID, msc_full_pegging_s.currval),
            p_pegging_rec.constraint_flag,
            p_pegging_rec.allocated_quantity, -- 1527660
            p_pegging_rec.number1,
            p_pegging_rec.char1,
            p_pegging_rec.component_identifier,
            p_pegging_rec.batchable_flag,
            p_pegging_rec.supplier_atp_date,
            p_pegging_rec.dest_inv_item_id,
            p_pegging_rec.summary_flag,
            p_pegging_rec.request_item_id,
            p_pegging_rec.ptf_date
            -- dsting
            , sysdate 			-- creation_date
            , FND_GLOBAL.USER_ID	-- created_by
            , sysdate				-- creation_date
            , FND_GLOBAL.USER_ID	-- created_by
            , FND_GLOBAL.USER_ID,	-- last_update_login
            --diag_atp
            p_pegging_rec.FIXED_LEAD_TIME,
            p_pegging_rec.VARIABLE_LEAD_TIME,
            p_pegging_rec.PREPROCESSING_LEAD_TIME,
            p_pegging_rec.PROCESSING_LEAD_TIME,
            p_pegging_rec.POSTPROCESSING_LEAD_TIME,
            p_pegging_rec.INTRANSIT_LEAD_TIME,
            p_pegging_rec.ALLOCATION_RULE,
            p_pegging_rec.INFINITE_TIME_FENCE,
            p_pegging_rec.SUBSTITUTION_WINDOW,
            p_pegging_rec.REQUIRED_QUANTITY,
            p_pegging_rec.ROUNDING_CONTROL,
            p_pegging_rec.ATP_FLAG,
            p_pegging_rec.ATP_COMPONENT_FLAG,
            -- p_pegging_rec.REQUIRED_DATE,
            -- Bug 2748730. Move the required_date to day end only when the pegging is for demand line
            -- This is applicable irrespective of whether the line is overridden or not
            DECODE(p_pegging_rec.supply_demand_type,
            1, TRUNC(p_pegging_rec.REQUIRED_DATE) + MSC_ATP_PVT.G_END_OF_DAY,
            p_pegging_rec.REQUIRED_DATE),
            p_pegging_rec.OPERATION_SEQUENCE_ID,
            p_pegging_rec.SOURCING_RULE_NAME,
            p_pegging_rec.OFFSET,
            p_pegging_rec.EFFICIENCY,
            p_pegging_rec.REVERSE_CUM_YIELD,
            p_pegging_rec.BASIS_TYPE,
            p_pegging_rec.USAGE,
            p_pegging_rec.CONSTRAINT_TYPE,
            p_pegging_rec.CONSTRAINT_DATE,
            p_pegging_rec.UTILIZATION,
            p_pegging_rec.OWNING_DEPARTMENT,
            p_pegging_rec.ATP_RULE_NAME,
            p_pegging_rec.PLAN_NAME,
            p_pegging_rec.weight_capacity,
            p_pegging_rec.volume_capacity,
            p_pegging_rec.weight_uom,
            p_pegging_rec.volume_uom,
            p_pegging_rec.pegging_type,
            p_pegging_rec.ship_method,
            --s_cto_rearch
            p_pegging_rec.model_sd_flag ,
            p_pegging_rec.error_code,
            p_pegging_rec.base_model_id,
            p_pegging_rec.base_model_name,
            p_pegging_rec.nonatp_flag,
            p_pegging_rec.demand_class,
            MSC_ATP_PVT.G_PARTNER_ID,
            MSC_ATP_PVT.G_PARTNER_SITE_ID,
            p_pegging_rec.receiving_organization_id,
            p_pegging_rec.actual_supply_demand_date,
            --e_cto_rearch
            p_pegging_rec.aggregate_time_fence_date, -- For time_phased_atp
            p_pegging_rec.shipping_cal_code,     -- Bug 3826234
            p_pegging_rec.receiving_cal_code,    -- Bug 3826234
            p_pegging_rec.intransit_cal_code,    -- Bug 3826234
            p_pegging_rec.manufacturing_cal_code, -- Bug 3826234
            --4570421
            p_pegging_rec.scaling_type,
            p_pegging_rec.scale_multiple,
            p_pegging_rec.scale_rounding_variance,
            p_pegging_rec.rounding_direction,
            p_pegging_rec.component_yield_factor,
            p_pegging_rec.organization_type --4775920
           )
    RETURNING pegging_id INTO x_pegging_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Add_Pegging: ' || 'x_pegging_id = '||x_pegging_id);
     msc_sch_wb.atp_debug('***** End Add_Pegging Procedure *****');
  END IF;

END Add_Pegging;


PROCEDURE Add_Planned_Order(
        p_instance_id               IN NUMBER,
        p_plan_id                   IN NUMBER,
        p_inventory_item_id         IN NUMBER,
        p_organization_id           IN NUMBER,
        p_schedule_date             IN DATE,
        p_order_quantity            IN NUMBER,
        p_supplier_id               IN NUMBER,
        p_supplier_site_id          IN NUMBER,
        p_demand_class              IN VARCHAR2,
        -- rajjain 02/19/2003 Bug 2788302 Begin
        p_source_organization_id    IN NUMBER,
        p_source_sr_instance_id     IN NUMBER,
        p_process_seq_id            IN NUMBER,
        -- rajjain 02/19/2003 Bug 2788302 End
        p_refresh_number            IN VARCHAR2, -- for summary enhancement
        p_shipping_cal_code         IN VARCHAR2, -- For ship_rec_cal
        p_receiving_cal_code        IN VARCHAR2, -- For ship_rec_cal
        p_intransit_cal_code        IN VARCHAR2, -- For ship_rec_cal
        p_new_ship_date             IN DATE,     -- For ship_rec_cal
        p_new_dock_date             IN DATE,     -- For ship_rec_cal
        p_start_date                IN DATE,     -- Bug 3241766
        p_order_date                IN DATE,     -- Bug 3241766
        p_ship_method               IN VARCHAR2, -- For ship_rec_cal
        x_transaction_id            OUT NoCopy NUMBER,
        x_return_status             OUT NoCopy VARCHAR2,
        p_intransit_lead_time       IN      NUMBER, --4127630
        p_request_item_id           IN NUMBER := NULL, -- for time_phased_atp
        p_atf_date                  IN DATE := NULL -- for time_phased_atp
)
IS
    temp_sd_qty number;
    l_record_source        number := 2; -- for plan order pegging rmehra

    -- time_phased_atp
    l_time_phased_atp      varchar2(1) := 'N';
    l_insert_item_id       number;
    l_return_status        varchar2(1);

    l_supply_rec  MSC_ATP_DB_UTILS.Supply_Rec_Typ;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Planned_Order Procedure *****');
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_order_quantity := ' || p_order_quantity);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_inventory_item_id := ' || p_inventory_item_id);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_schedule_date := ' || p_schedule_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_organization_id := ' || p_organization_id);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_schedule_date := ' || p_schedule_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_supplier_id := ' || p_supplier_id);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_supplier_site_id := ' || p_supplier_site_id);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_refresh_number := ' || p_refresh_number);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_request_item_id := ' || p_request_item_id);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_atf_date := ' || p_atf_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_new_dock_date := ' || p_new_dock_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_new_ship_date := ' || p_new_ship_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_start_date := ' || p_start_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_order_date := ' || p_order_date);
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'p_intransit_lead_time := ' || p_intransit_lead_time);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --bug 3766179: Code to create planned order is moved to add_supplies
    l_supply_rec.instance_id := p_instance_id;
    l_supply_rec.plan_id := p_plan_id;
    l_supply_rec.inventory_item_id := p_inventory_item_id;
    l_supply_rec.organization_id := p_organization_id;
    l_supply_rec.schedule_date := p_schedule_date;
    l_supply_rec.order_quantity := p_order_quantity;
    l_supply_rec.supplier_id := p_supplier_id;
    l_supply_rec.supplier_site_id := p_supplier_site_id;
    l_supply_rec.demand_class := p_demand_class;
    l_supply_rec.source_organization_id := p_source_organization_id;
    l_supply_rec.source_sr_instance_id := p_source_sr_instance_id;
    l_supply_rec.process_seq_id := p_process_seq_id;
    l_supply_rec.refresh_number := p_refresh_number;
    l_supply_rec.shipping_cal_code  := p_shipping_cal_code;
    l_supply_rec.receiving_cal_code := p_receiving_cal_code;
    l_supply_rec.intransit_cal_code := p_intransit_cal_code;
    l_supply_rec.new_ship_date := p_new_ship_date;
    l_supply_rec.new_dock_date := p_new_dock_date;
    l_supply_rec.start_date := p_start_date;
    l_supply_rec.order_date := p_order_date;
    l_supply_rec.ship_method := p_ship_method;
    l_supply_rec.request_item_id := p_request_item_id;
    l_supply_rec.atf_date        := p_atf_date;

    l_supply_rec.firm_planned_type := 2;
    l_supply_rec.disposition_status_type := 1;
    l_supply_rec.record_source := 2;
    l_supply_rec.supply_type := 5; --- planned order
    l_supply_rec.intransit_lead_time := p_intransit_lead_time; --4127630

    MSC_ATP_DB_UTILS.ADD_SUPPLIES(l_supply_rec);

    x_transaction_id := l_supply_rec.transaction_id;
    x_return_status := l_supply_rec.return_status;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'x_transaction_id = '||x_transaction_id);
        msc_sch_wb.atp_debug('***** End Add_Planned_Order Procedure *****');
    END IF;

END Add_Planned_Order;


PROCEDURE Add_Resource_Demand(
        p_instance_id           IN  NUMBER,
        p_plan_id               IN  NUMBER,
        p_supply_id             IN  NUMBER,
        p_organization_id       IN  NUMBER,
        p_resource_id           IN  NUMBER,
        p_department_id         IN  NUMBER,
        -- Bug 3348095
        -- Now both start and end dates will be stored for
        -- ATP created resource requirements.
        p_start_date            IN  DATE,
        p_end_date              IN  DATE,
        -- End Bug 3348095
        p_resource_hours        IN  NUMBER,
        p_unadj_resource_hours  IN  NUMBER, --5093604
        p_touch_time            IN  NUMBER, --5093604
        p_std_op_code           IN  VARCHAR2,
        p_resource_cap_hrs      IN  NUMBER,
        p_item_id               IN  NUMBER,  -- Need to store assembly_item_id CTO ODR
        p_basis_type            IN  NUMBER,   -- Need to store basis_type CTO ODR
        p_op_seq_num            IN  NUMBER,   -- Need to store op_seq_num CTO ODR
        p_refresh_number        IN  VARCHAR2, -- for summary enhancement
        x_transaction_id        OUT NoCopy NUMBER,
        x_return_status         OUT NoCopy VARCHAR2)
IS
    temp_sd_qty number;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Resource_Demand Procedure *****');
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_resource_id := ' || p_resource_id);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_department_id := ' || p_department_id);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_resource_hours := ' || p_resource_hours);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_resource_cap_hrs := ' || p_resource_cap_hrs);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_item_id := ' || p_item_id);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_start_date := ' || p_start_date);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_end_date := ' || p_end_date);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_refresh_number := ' || p_refresh_number);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_basis_type := ' || p_basis_type);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_op_seq_num := ' || p_op_seq_num);
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_unadj_resource_hours := ' || p_unadj_resource_hours); --5093604
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'p_touch_time := ' || p_touch_time);                               --5093604
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Insert demand into msc_resource_requirements
    INSERT into msc_resource_requirements
           (plan_id,
            supply_id,
            transaction_id,
            organization_id,
            sr_instance_id,
            resource_seq_num,
            resource_id,
            department_id,
            assembly_item_id, --  This field was not getting populated before. CTO ODR
            basis_type, --  This field was not getting populated before. CTO ODR
            operation_seq_num, --  This field was not getting populated before. CTO ODR
            start_date,
            -- Bug 3348095 Store End Date as well.
            end_date,
            -- End Bug 3348095
            resource_hours,
            unadjusted_resource_hours, --5093604
            touch_time,                --5093604
            load_rate,
            assigned_units,
            supply_type, -- 1510686
            std_op_code, --resource batching
            -- parent_id, Bug 3327819 parent_id will be defaulted to NULL.
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            record_source,  -- This field was not getting populated before. added with summary enhancement
            refresh_number) -- for summary enhancement
    VALUES (p_plan_id,
            p_supply_id,
            msc_resource_requirements_s.nextval,
            p_organization_id,
            p_instance_id,
            1,
            p_resource_id,
            p_department_id,
            p_item_id,  -- This field was not getting populated before. CTO ODR
            p_basis_type,  -- This field was not getting populated before. CTO ODR
            p_op_seq_num,  -- This field was not getting populated before. CTO ODR
            -- Bug 3348095
            -- Now both start and end dates will be stored for
            -- ATP created resource requirements.
            TRUNC(p_start_date) + MSC_ATP_PVT.G_END_OF_DAY,
            TRUNC(p_end_date) + MSC_ATP_PVT.G_END_OF_DAY, -- For bug 2259824
            -- End Bug 3348095
            p_resource_hours,
            p_unadj_resource_hours, --5093604
            p_touch_time,                --5093604
            decode(p_resource_id,-1,p_resource_hours,to_number(null)),
            0,
            5,
            p_std_op_code,
            --MSC_ATP_PVT.G_OPTIMIZED_PLAN, Bug 3327819 Default parent_id to NULL.
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            2,               -- This field was not getting populated before. added with summary enhancement
            p_refresh_number -- for summary enhancement
           )
    RETURNING transaction_id INTO x_transaction_id;

    -- Code to make summary updates and commit removed for summary enhancement
    /** code commented for time being. Will be removed after code review
    IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Resource_Demand: ' || ' In summary mode update resource req');
            msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'First update');
        END IF;
        MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                          p_plan_id,
                                          p_organization_id,
                                          null,
                                          p_start_date,
                                          p_resource_id,
                                          p_department_id,
                                          null,
                                          null,
                                          null,
                                          null,
                                          3);

        update /*+ INDEX(msc_atp_summary_res MSC_ATP_SUMMARY_RES_U1) *//* msc_atp_summary_res
        set sd_qty = sd_qty - p_resource_cap_hrs
        where plan_id = p_plan_id
        and   sr_instance_id = p_instance_id
        and   organization_id = p_organization_id
        and   resource_id = p_resource_id
        and   department_id = p_department_id
        and   sd_date = trunc(p_start_date);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'after update qty := ' || temp_sd_qty);
        END IF;


        IF SQL%NOTFOUND THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'Couldnt update. Inset the row');
           END IF;
           BEGIN
              INSERT /*+ INDEX(msc_atp_summary_RES MSC_ATP_SUMMARY_SD_RES) *//* INTO MSC_ATP_SUMMARY_RES
                         (plan_id,
                          organization_id,
                          sr_instance_id,
                          department_id,
                          resource_id,
                          sd_date,
                          sd_qty,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          CREATION_DATE,
                          CREATED_BY
                          )
                          VALUES
                          (p_plan_id,
                           p_organization_id,
                           p_instance_id,
                           p_department_id,
                           p_resource_id,
                           trunc(p_start_date),
                           -1 * p_resource_cap_hrs,
                           sysdate,
                           FND_GLOBAL.USER_ID,
                           sysdate,
                           FND_GLOBAL.USER_ID);
           EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN

                    MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
   	                                              p_plan_id,
                                          	      p_organization_id,
                                          	      null,
                                          	      p_start_date,
                                          	      p_resource_id,
                                          	      p_department_id,
                                          	      null,
                                          	      null,
                                          	      null,
                                          	      null,
                                          	      3);

                    update /*+ INDEX(msc_atp_summary_RES MSC_ATP_SUMMARY_RES_U1) *//* msc_atp_summary_res
                    set sd_qty = sd_qty - p_resource_cap_hrs
                    where plan_id = p_plan_id
                    and   sr_instance_id = p_instance_id
                    and   organization_id = p_organization_id
                    and   resource_id = p_resource_id
                    and   department_id = p_department_id
                    and   sd_date = trunc(p_start_date);
           END;
        END IF; --- if sql%notfound
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'Summary mode commit, in resource_req');
        END IF;
        commit;
    END IF; --- if MSC_ATP_PVT.SUMMARY_FLAG = 'Y'
    ***/

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Resource_Demand: ' || 'x_transaction_id = '||x_transaction_id);
        msc_sch_wb.atp_debug('***** End Add_Resource_Demand Procedure *****');
    END IF;

END Add_Resource_Demand;


PROCEDURE Delete_Pegging(
   p_pegging_id           IN        number
)
IS

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Begin delete_pegging,p_pegging_id='||p_pegging_id);
      END IF;

      DELETE FROM mrp_atp_details_temp
      WHERE pegging_id = p_pegging_id
      AND   session_id = MSC_ATP_PVT.G_SESSION_ID;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('After delete_pegging,p_pegging_id='||p_pegging_id);
      END IF;

EXCEPTION
      WHEN OTHERS THEN
          null;
END Delete_Pegging;


PROCEDURE Delete_Row(p_identifier         IN   NUMBER,
                     p_config_line_id     IN   NUMBER,  -- CTO Re-arch, ATP Simplified Pegging
                     p_plan_id            IN   NUMBER,
                     p_instance_id        IN   NUMBER,
                     p_refresh_number     IN   NUMBER,
                                       -- Bug 2831298 Ensure that the refresh_number is updated
                     p_order_number       IN   NUMBER, -- Bug 2840734 : krajan :
                     p_time_phased_atp    IN   VARCHAR2,                       -- For time_phased_atp
                     p_ato_model_line_id  IN      number,
                     p_demand_source_type IN    Number,  --cmro
                     p_source_organization_Id IN  NUMBER,  --Bug 7118988
                     x_demand_id          OUT  NoCopy MRP_ATP_PUB.Number_Arr,
                     x_inv_item_id        OUT  NoCopy MRP_ATP_PUB.Number_Arr,
                     x_copy_demand_id     OUT  NoCopy MRP_ATP_PUB.Number_Arr,  -- For summary enhancement
                     -- CTO ODR and Simplified Pegging
                     x_atp_peg_items      OUT  NoCopy MRP_ATP_PUB.Number_Arr,
                     x_atp_peg_demands    OUT  NoCopy MRP_ATP_PUB.Number_Arr,
                     x_atp_peg_supplies   OUT  NoCopy MRP_ATP_PUB.Number_Arr,
                     x_atp_peg_res_reqs   OUT  NoCopy MRP_ATP_PUB.Number_Arr,
                     x_demand_instance_id OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_supply_instance_id OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_res_instance_id    OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_ods_cto_demand_ids   OUT NoCopy MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                     x_ods_cto_inv_item_ids OUT NoCopy MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                     x_ods_atp_refresh_no      OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_ods_cto_atp_refresh_no  OUT NoCopy MRP_ATP_PUB.Number_Arr
                     -- End CTO ODR and Simplified Pegging
)

IS
    l_del_rows                  NUMBER;
    -- added for bug 2738280
    i                           PLS_INTEGER;
    l_old_demand_date           MRP_ATP_PUB.date_arr    := MRP_ATP_PUB.date_arr();
    l_old_demand_quantity       MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_organization_id           MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    -- added for summary enhancement
    l_current_refresh_number    NUMBER;
    i_item_id_tab               MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_refresh_number_tab        MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_demand_class_tab          MRP_ATP_PUB.char30_arr  := MRP_ATP_PUB.char30_arr();
    l_qty_tab                   MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    i_ins_item_id_tab           MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_ins_org_id_tab            MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_ins_refresh_number_tab    MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_ins_demand_class_tab      MRP_ATP_PUB.char30_arr  := MRP_ATP_PUB.char30_arr();
    l_ins_qty_tab               MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_ins_date_tab              MRP_ATP_PUB.date_arr    := MRP_ATP_PUB.date_arr();
    l_copy_demand_id            MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
    l_identifier_tab            MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();

    -- CTO ODR and Simplified Pegging
    l_return_status         VARCHAR2(1);
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Delete_Row Procedure************');
        msc_sch_wb.atp_debug('Delete_Row: ' || 'p_plan_id := ' || p_plan_id);
        msc_sch_wb.atp_debug(' identifier := ' || p_identifier);
        msc_sch_wb.atp_debug(' p_config_line_id := ' || p_config_line_id);
        msc_sch_wb.atp_debug('Ato model line id := ' || p_ato_model_line_id);
        msc_sch_wb.atp_debug('p_source_organization id := ' || p_source_organization_Id);
    END IF;
    IF p_plan_id = -1 THEN

        IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND G_ORIG_INV_CTP = 5 THEN
                -- Condition for INV_CTP added for bug 3295831 because summary
                -- is not supported in PDS-ODS switch.
            MSC_ATP_DB_UTILS.DELETE_SUMMARY_ROW(p_identifier, p_plan_id, p_instance_id,p_demand_source_type);--cmro
        END IF;

        --3720018, commented the deletion of Sales orders.
        -- Bug 1723284, implicit conversion of datatype was forcing it
        -- not to use index and do FTS.
        /*DELETE msc_sales_orders
        WHERE  sr_instance_id = p_instance_id
        AND    demand_source_line = to_char(p_identifier)
        AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO*/

        --3720018, msc_sales_order is updated in case of ODS rescheduling
        Update msc_sales_orders
              set old_primary_uom_quantity = primary_uom_quantity,
              old_reservation_quantity = reservation_quantity,
              reservation_quantity = 0,
              Primary_uom_quantity = 0
        WHERE  sr_instance_id = p_instance_id
        AND    demand_source_line = to_char(p_identifier)
        AND    organization_id = p_source_organization_Id			---7118988
        AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1)
        returning demand_id, inventory_item_id, atp_refresh_number
        bulk collect into x_demand_id, x_inv_item_id, x_ods_atp_refresh_no;

        Update msc_sales_orders
              set atp_refresh_number = 10000000000 --3720018
        WHERE  sr_instance_id = p_instance_id
        AND    demand_source_line = to_char(p_identifier)
        AND    organization_id = p_source_organization_Id			---7118988
        AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1);


        IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Number of SO lines updated := ' || SQL%ROWCOUNT);
             --Bug 4336692, In case above queries donot return anything,
             -- following debug statement will cause an error.
             --msc_sch_wb.atp_debug( 'x_ods_atp_refresh_no' || x_ods_atp_refresh_no(1));
              msc_sch_wb.atp_debug('x_demand_id(1) ' ||x_demand_id.count);
        END IF;

        --s_cto_rearch: Now delete rows fpr CTO components
        IF p_ato_model_line_id is not null THEN

            --3720018, commented the deletion of Sales orders.
            /*DELETE msc_sales_orders
            where  sr_instance_id = p_instance_id
            and    ato_line_id = p_identifier
            AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO*/

            --3720018, msc_sales_order is updated in case of ODS rescheduling
            Update msc_sales_orders
                 set old_primary_uom_quantity = primary_uom_quantity,
                 --old_refresh_number = refresh_number,
                 Primary_uom_quantity = 0,
                 old_reservation_quantity = reservation_quantity,
                 reservation_quantity = 0
            WHERE  sr_instance_id = p_instance_id
            AND    ato_line_id    = p_identifier
            AND    demand_source_line <> to_char(p_identifier)
            AND    organization_id = p_source_organization_Id			---7118988
            AND    decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1)
            returning demand_id, inventory_item_id, atp_refresh_number
            bulk collect into x_ods_cto_demand_ids, x_ods_cto_inv_item_ids, x_ods_cto_atp_refresh_no ;


            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Number of component lines updated := ' || SQL%ROWCOUNT);
            END IF;

            Update msc_sales_orders
                 set atp_refresh_number = 10000000000 --3720018
            WHERE  sr_instance_id = p_instance_id
            AND    ato_line_id    = p_identifier
            AND    demand_source_line <> to_char(p_identifier)
            AND    organization_id = p_source_organization_Id			---7118988
            AND    decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1);

        END IF;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Delete_Row: ' || 'Deleting msc_demands with identifier = '||
                p_identifier ||' : plan id = '||p_plan_id);
        END IF;

        IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: ' || 'Obtain the latest refresh number.');
            END IF;

            SELECT latest_refresh_number
            INTO   l_current_refresh_number
            FROM   MSC_PLANS
            WHERE  plan_id = p_plan_id;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: ' || 'l_current_refresh_number := ' || l_current_refresh_number);
            END IF;
        END IF;

        IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'N') OR
           (p_time_phased_atp = 'Y') OR
           ((MSC_ATP_PVT.G_INV_CTP = 4) AND
            (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
            (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN
            -- If condition added for summary enhancement
            -- execute the old code non-summary cases and demand priority allocation cases
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: ' || 'Summary , PF or allocated.');
            END IF;

            -- Bug # 1868383, do not delete old demand records, rather just update qty = 0
            -- Bug 2738280. Club the 2 update SQL's into one.
            -- Collect all the entities required for updating summary tables here.
            UPDATE  msc_demands
            SET     old_demand_quantity = using_requirement_quantity,
                    -- bug 2863322 : change the column used to store date
                    old_using_assembly_demand_date = using_assembly_demand_date,
                    applied = 2,
                    status = 0,
                    using_requirement_quantity = 0,
                    --24x7
                    atp_synchronization_flag = 0,
                    old_refresh_number = refresh_number, -- For summary enhancement
                    refresh_number = p_refresh_number,
                    -- Bug 2831298 Ensure that the refresh_number is updated.
                    order_number = p_order_number -- 2840734 : krajan : populate order number
            WHERE	sr_instance_id = p_instance_id
            AND     plan_id = p_plan_id
            AND     using_requirement_quantity > 0
            -- CTO ODR and Simplified Pegging
            AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO

            AND     sales_order_line_id in (p_identifier, p_config_line_id)
            AND     origination_type in (6,30,-100)
            AND     organization_id = p_source_organization_Id			---7118988

            -- rajjain 03/14/2003 Bug 2849749 Begin
            /* Comment out code refering msc_bom_temp
            AND     sales_order_line_id IN (
                    SELECT  component_identifier
                    FROM    msc_bom_temp
                    START WITH assembly_identifier = p_identifier
                    AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                    AND     assembly_identifier <> component_identifier
                    CONNECT BY PRIOR component_identifier = assembly_identifier
                    AND     assembly_identifier <> component_identifier
                    AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                    UNION ALL
                    SELECT p_identifier FROM dual
            -- rajjain 03/14/2003 Bug 2849749 End
                )
               Comment out code refering msc_bom_temp
             */
            -- End CTO ODR and Simplified Pegging
            -- bug 2863322 : change the column used to store date
            returning demand_id, inventory_item_id, sales_order_line_id
            bulk collect into x_demand_id, x_inv_item_id, l_identifier_tab;
            -- Returning clause changed for summary enhancement

            l_del_rows := SQL%ROWCOUNT;
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: ' || 'No. of demands updated = '|| l_del_rows);
                FOR i IN 1..x_demand_id.COUNT LOOP
                    msc_sch_wb.atp_debug('Delete_Row i: ' || i || '; demand_id: '|| x_demand_id(i) || '; inv_item_id: '|| x_inv_item_id(i));
                END LOOP;
            END IF;

        ELSE

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: ' || 'Unallocated summary');
            END IF;

            /*SELECT  demand_id,
                    inventory_item_id,
                    organization_id,
                    refresh_number,
                    using_requirement_quantity,
                    using_assembly_demand_date
            BULK COLLECT INTO
                    x_demand_id,
                    x_inv_item_id,
                    l_organization_id,
                    l_refresh_number_tab,
                    l_qty_tab,
                    l_old_demand_date
            FROM    MSC_DEMANDS
            WHERE   sr_instance_id = p_instance_id
            AND     plan_id = p_plan_id
            AND     using_requirement_quantity > 0
            -- CTO ODR and Simplified Pegging
            AND     nvl(decode(demand_source_type,100,demand_source_type,-1),-1)
                    =nvl(decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1),-1) --CMRO
            AND     sales_order_line_id in (p_identifier, p_config_line_id)
            AND     origination_type in (6,30)
             Comment out code refering msc_bom_temp
            AND     sales_order_line_id IN (
                    SELECT  component_identifier
                    FROM    msc_bom_temp
                    START WITH assembly_identifier = p_identifier
                    AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                    AND     assembly_identifier <> component_identifier
                    CONNECT BY PRIOR component_identifier = assembly_identifier
                    AND     assembly_identifier <> component_identifier
                    AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                    UNION ALL
                    SELECT p_identifier FROM dual
            )
            Comment out code refering msc_bom_temp

            -- End CTO ODR and Simplified Pegging
            ;*/ --commented out as now combining this with update and returning clause

            --IF x_demand_id IS NOT NULL AND x_demand_id.COUNT > 0 THEN
              --  IF PG_DEBUG in ('Y', 'C') THEN
                --    msc_sch_wb.atp_debug('Delete_Row: ' || 'x_demand_id.COUNT:' || x_demand_id.COUNT);
                --END IF;

                --FORALL i in 1..x_demand_id.COUNT  --cmro
               UPDATE  msc_demands
               SET     old_demand_quantity = using_requirement_quantity,
                        old_using_assembly_demand_date = using_assembly_demand_date,
                        applied = 2,
                        status = 0,
                        using_requirement_quantity = 0,
                        atp_synchronization_flag = 0,
                        old_refresh_number = refresh_number, -- For summary enhancement
                        refresh_number = p_refresh_number,
                        order_number = p_order_number
               WHERE   sr_instance_id = p_instance_id
               AND     plan_id = p_plan_id
               AND     using_requirement_quantity > 0
               AND     decode(demand_source_type,100,demand_source_type,-1)
                       =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
               AND     sales_order_line_id in (p_identifier, p_config_line_id)
               AND     origination_type in (6,30)
               AND    organization_id = p_source_organization_Id			---7118988
               RETURNING demand_id, inventory_item_id,organization_id,old_refresh_number,old_demand_quantity,old_using_assembly_demand_date
               BULK COLLECT INTO x_demand_id,x_inv_item_id,l_organization_id,l_refresh_number_tab,l_qty_tab,l_old_demand_date;--cmro

              IF x_demand_id IS NOT NULL AND x_demand_id.COUNT > 0 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Delete_Row: ' || 'x_demand_id.COUNT:' || x_demand_id.COUNT);
                END IF;

                FOR i IN 1..x_demand_id.COUNT LOOP
                    IF l_current_refresh_number IS NULL -- summary has not run
                        OR l_refresh_number_tab(i) > l_current_refresh_number THEN -- SO being unscheduled has not been summarized

                            IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Delete_Row: ' || 'Copy SO will be created for demand id ' || x_demand_id(i));
                            END IF;

                            i_ins_item_id_tab.Extend;
                            l_ins_org_id_tab.Extend;
                            l_ins_refresh_number_tab.Extend;
                            l_ins_qty_tab.Extend;
                            l_ins_date_tab.Extend;
                            l_copy_demand_id.Extend;

                            i_ins_item_id_tab(i_ins_item_id_tab.COUNT) := x_inv_item_id(i);
                            l_ins_org_id_tab(l_ins_org_id_tab.COUNT) := l_organization_id(i);
                            l_ins_refresh_number_tab(l_ins_refresh_number_tab.COUNT) := l_refresh_number_tab(i);
                            l_ins_qty_tab(l_ins_qty_tab.COUNT) := l_qty_tab(i);
                            l_ins_date_tab(l_ins_date_tab.COUNT) := l_old_demand_date(i);

                            SELECT  msc_demands_s.nextval
                            INTO    l_copy_demand_id(l_copy_demand_id.COUNT)
                            FROM    dual;
                    END IF;
                END LOOP;

                IF i_ins_item_id_tab IS NOT NULL and i_ins_item_id_tab.COUNT > 0 THEN
                    -- Insert copy sales orders
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_Row: ' || 'i_ins_item_id_tab.COUNT:' || i_ins_item_id_tab.COUNT);
                    END IF;

                    FORALL i IN 1..i_ins_item_id_tab.COUNT
                    INSERT INTO MSC_DEMANDS(
                            DEMAND_ID,
                            USING_REQUIREMENT_QUANTITY,
                            USING_ASSEMBLY_DEMAND_DATE,
                            DEMAND_TYPE,
                            ORIGINATION_TYPE,
                            USING_ASSEMBLY_ITEM_ID,
                            PLAN_ID,
                            ORGANIZATION_ID,
                            INVENTORY_ITEM_ID,
                            SR_INSTANCE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            RECORD_SOURCE,
                            REFRESH_NUMBER)
                    VALUES (l_copy_demand_id(i),
                            MSC_ATP_UTILS.Truncate_Demand(l_ins_qty_tab(i)),	-- 5598066
                            l_ins_date_tab(i),
                            1,      -- Discrete
                            52,     -- Copy sales order
                            i_ins_item_id_tab(i),
                            p_plan_id,
                            l_ins_org_id_tab(i),
                            i_ins_item_id_tab(i),
                            p_instance_id,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            2,
                            l_ins_refresh_number_tab(i));

                ELSE
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_Row: ' || 'No copy Sales Orders');
                    END IF;
                END IF;

                x_copy_demand_id := l_copy_demand_id;

              ELSE -- IF x_demand_id IS NOT NULL AND x_demand_id.COUNT > 0 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Delete_Row: ' || 'No demands to be deleted');
                END IF;
              END IF;

        END IF;


        -- Code to update summary records removed for summary enhancement
        /** code commented for time being. Will be removed after code review
        IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: ' || 'update Demands in summary mode');
            END IF;
            -- Bug 2738280. Change the input parameters of procedure call.
            -- MSC_ATP_DB_UTILS.UPDATE_PLAN_SUMMARY_ROW(p_identifier, p_plan_id, p_instance_id);
            MSC_ATP_DB_UTILS.UPDATE_PLAN_SUMMARY_ROW(x_inv_item_id, l_old_demand_date, l_old_demand_quantity,
                                                     l_organization_id, p_plan_id, p_instance_id);
        END IF;
        **/

        /* time_phased_atp
           Delete bucketed demands and rollup supplies*/
        IF ((p_time_phased_atp = 'Y')
           OR
           ((MSC_ATP_PVT.G_INV_CTP = 4) AND
            (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
            --bug 3442528: We need to delete SO for model entities as well.
            --(MSC_ATP_PVT.G_ALLOCATION_METHOD = 1))) AND p_ato_model_line_id is null THEN
            (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1))) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Delete_Row: before update of msc_alloc_demands');
            END IF;

            IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'N' THEN
                -- If condition added for summary enhancement
                -- For non summary case since no returning is required hence direct bulk update is used

                IF l_identifier_tab IS NOT NULL and l_identifier_tab.COUNT > 0 THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_Row: l_identifier_tab.COUNT ' || l_identifier_tab.COUNT);
                    END IF;

                    FORALL  i IN 1..l_identifier_tab.COUNT
                    UPDATE  msc_alloc_demands
                    SET     old_allocated_quantity = allocated_quantity,
                            old_demand_date = demand_date,
                            allocated_quantity = 0,
                            old_refresh_number = refresh_number, -- For summary enhancement
                            refresh_number = p_refresh_number
                    WHERE   sr_instance_id = p_instance_id
                    AND     plan_id = p_plan_id
                    AND     allocated_quantity > 0
                    AND     sales_order_line_id = l_identifier_tab(i)
                    AND     organization_id = p_source_organization_Id			---7118988
                    AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO


                    FORALL  i IN 1..l_identifier_tab.COUNT
                    UPDATE  msc_alloc_supplies
                    SET     old_allocated_quantity = allocated_quantity,
                            old_supply_date = supply_date,
                            allocated_quantity = 0,
                            old_refresh_number = refresh_number, -- For summary enhancement
                            refresh_number = p_refresh_number
                    WHERE   sr_instance_id = p_instance_id
                    AND     plan_id = p_plan_id
                    AND     stealing_flag = 1
                    AND     allocated_quantity <> 0
                    AND     sales_order_line_id = l_identifier_tab(i)
                    AND     organization_id = p_source_organization_Id			---7118988
                    AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO


                END IF;

            ELSE    -- IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'N' THEN

                SELECT  sales_order_line_id,
                        inventory_item_id,
                        organization_id,
                        refresh_number,
                        allocated_quantity,
                        demand_date,
                        demand_class
                BULK COLLECT INTO
                        l_identifier_tab,
                        i_item_id_tab,
                        l_organization_id,
                        l_refresh_number_tab,
                        l_qty_tab,
                        l_old_demand_date,
                        l_demand_class_tab
                FROM    msc_alloc_demands
                WHERE   sr_instance_id = p_instance_id
                AND     plan_id = p_plan_id
                AND     allocated_quantity > 0
                -- CTO ODR and Simplified Pegging
                AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
                AND     sales_order_line_id in (p_identifier, p_config_line_id);
                /* Comment out code refering msc_bom_temp
                AND     sales_order_line_id IN (
                        SELECT  component_identifier
                        FROM    msc_bom_temp
                        START WITH assembly_identifier = p_identifier
                        AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                        AND     assembly_identifier <> component_identifier
                        CONNECT BY PRIOR component_identifier = assembly_identifier
                        AND     assembly_identifier <> component_identifier
                        AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                        UNION ALL
                        SELECT  p_identifier FROM dual)
               Comment out code refering msc_bom_temp
               */
               -- End CTO ODR and Simplified Pegging



                IF l_identifier_tab IS NOT NULL and l_identifier_tab.COUNT > 0 THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_Row: l_identifier_tab.COUNT ' || l_identifier_tab.COUNT);
                    END IF;

                    FORALL  i IN 1..l_identifier_tab.COUNT
                    UPDATE  msc_alloc_demands
                    SET     old_allocated_quantity = allocated_quantity,
                            old_demand_date = demand_date,
                            allocated_quantity = 0,
                            old_refresh_number = refresh_number, -- For summary enhancement
                            refresh_number = p_refresh_number -- For summary enhancement
                    WHERE   sr_instance_id = p_instance_id
                    AND     plan_id = p_plan_id
                    AND     allocated_quantity > 0
                    AND     sales_order_line_id = l_identifier_tab(i)
                    AND     organization_id = p_source_organization_Id			---7118988
                    AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO




                    FOR i IN 1..i_item_id_tab.COUNT LOOP
                        IF l_current_refresh_number IS NULL -- summary has not run
                            OR l_refresh_number_tab(i) > l_current_refresh_number THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                    msc_sch_wb.atp_debug('Delete_Row: ' || 'Copy SO will be created for identifier ' || l_identifier_tab(i));
                                END IF;

                                i_ins_item_id_tab.Extend;
                                l_ins_org_id_tab.Extend;
                                l_ins_refresh_number_tab.Extend;
                                l_ins_qty_tab.Extend;
                                l_ins_date_tab.Extend;
                                l_copy_demand_id.Extend;
                                l_ins_demand_class_tab.Extend;

                                i_ins_item_id_tab(i_ins_item_id_tab.COUNT) := i_item_id_tab(i);
                                l_ins_org_id_tab(l_ins_org_id_tab.COUNT) := l_organization_id(i);
                                l_ins_refresh_number_tab(l_ins_refresh_number_tab.COUNT) := l_refresh_number_tab(i);
                                l_ins_qty_tab(l_ins_qty_tab.COUNT) := l_qty_tab(i);
                                l_ins_date_tab(l_ins_date_tab.COUNT) := l_old_demand_date(i);
                                l_ins_demand_class_tab(l_ins_demand_class_tab.COUNT) := l_demand_class_tab(i);

                                SELECT  msc_demands_s.nextval
                                INTO    l_copy_demand_id(l_copy_demand_id.COUNT)
                                FROM    dual;

                        END IF;
                    END LOOP;

                END IF; -- IF l_identifier_tab IS NOT NULL and l_identifier_tab.COUNT > 0 THEN

                SELECT  sales_order_line_id,
                        inventory_item_id,
                        organization_id,
                        refresh_number,
                        -1 * allocated_quantity, -- multiply by -1 since the copy record will be stored in msc_demands
                        supply_date,
                        demand_class
                BULK COLLECT INTO
                        l_identifier_tab,
                        i_item_id_tab,
                        l_organization_id,
                        l_refresh_number_tab,
                        l_qty_tab,
                        l_old_demand_date,
                        l_demand_class_tab
                FROM    msc_alloc_supplies
                WHERE   sr_instance_id = p_instance_id
                AND     plan_id = p_plan_id
                AND     stealing_flag = 1
                AND     allocated_quantity <> 0
                -- CTO ODR and Simplified Pegging
                AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
                AND     sales_order_line_id in (p_identifier, p_config_line_id);
                /* Comment out code refering msc_bom_temp
                AND     sales_order_line_id IN (
                        SELECT  component_identifier
                        FROM    msc_bom_temp
                        START WITH assembly_identifier = p_identifier
                        AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                        AND     assembly_identifier <> component_identifier
                        CONNECT BY PRIOR component_identifier = assembly_identifier
                        AND     assembly_identifier <> component_identifier
                        AND     session_id = MSC_ATP_PVT.G_SESSION_ID
                        UNION ALL
                        SELECT  p_identifier FROM dual)
                Comment out code refering msc_bom_temp
                */
                -- End CTO ODR and Simplified Pegging


                IF l_identifier_tab IS NOT NULL and l_identifier_tab.COUNT > 0 THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_Row: l_identifier_tab.COUNT ' || l_identifier_tab.COUNT);
                    END IF;

                    FORALL  i IN 1..l_identifier_tab.COUNT
                    UPDATE  msc_alloc_supplies
                    SET     old_allocated_quantity = allocated_quantity,
                            old_supply_date = supply_date,
                            allocated_quantity = 0,
                            old_refresh_number = refresh_number, -- For summary enhancement
                            refresh_number = p_refresh_number -- For summary enhancement
                    WHERE   sr_instance_id = p_instance_id
                    AND     plan_id = p_plan_id
                    AND     stealing_flag = 1
                    AND     allocated_quantity <> 0
                    AND     sales_order_line_id = l_identifier_tab(i)
                    AND     organization_id = p_source_organization_Id			---7118988
                    AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO




                    FOR i IN 1..i_item_id_tab.COUNT LOOP
                        IF l_current_refresh_number IS NULL -- summary has not run
                            OR l_refresh_number_tab(i) > l_current_refresh_number THEN

                            IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Delete_Row: ' || 'Copy stealing will be created for identifier ' || l_identifier_tab(i));
                            END IF;

                            i_ins_item_id_tab.Extend;
                            l_ins_org_id_tab.Extend;
                            l_ins_refresh_number_tab.Extend;
                            l_ins_qty_tab.Extend;
                            l_ins_date_tab.Extend;
                            l_copy_demand_id.Extend;
                            l_ins_demand_class_tab.Extend;

                            i_ins_item_id_tab(i_ins_item_id_tab.COUNT) := i_item_id_tab(i);
                            l_ins_org_id_tab(l_ins_org_id_tab.COUNT) := l_organization_id(i);
                            l_ins_refresh_number_tab(l_ins_refresh_number_tab.COUNT) := l_refresh_number_tab(i);
                            l_ins_qty_tab(l_ins_qty_tab.COUNT) := l_qty_tab(i);
                            l_ins_date_tab(l_ins_date_tab.COUNT) := l_old_demand_date(i);
                            l_ins_demand_class_tab(l_ins_demand_class_tab.COUNT) := l_demand_class_tab(i);

                            SELECT  msc_demands_s.nextval
                            INTO    l_copy_demand_id(l_copy_demand_id.COUNT)
                            FROM    dual;
                        END IF;
                    END LOOP;

                END IF; --IF l_identifier_tab IS NOT NULL and l_identifier_tab.COUNT > 0 THEN


                IF i_ins_item_id_tab IS NOT NULL and i_ins_item_id_tab.COUNT > 0 THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_Row: i_ins_item_id_tab.COUNT ' || i_ins_item_id_tab.COUNT);
                    END IF;

                    FORALL i IN 1..i_ins_item_id_tab.COUNT
                    INSERT INTO MSC_ALLOC_DEMANDS(
                            PLAN_ID,
                            INVENTORY_ITEM_ID,
                            ORGANIZATION_ID,
                            SR_INSTANCE_ID,
                            DEMAND_CLASS,
                            DEMAND_DATE,
                            PARENT_DEMAND_ID,
                            ALLOCATED_QUANTITY,
                            ORIGINATION_TYPE,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            REFRESH_NUMBER)
                    VALUES (p_plan_id,
                            i_ins_item_id_tab(i),
                            l_ins_org_id_tab(i),
                            p_instance_id,
                            l_ins_demand_class_tab(i),
                            l_ins_date_tab(i),
                            l_copy_demand_id(i),     -- parent demand id
                            MSC_ATP_UTILS.Truncate_Demand(l_ins_qty_tab(i)),	--5598066
                            52,     -- Copy sales order
                            FND_GLOBAL.USER_ID,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            sysdate,
                            l_ins_refresh_number_tab(i));
                END IF; -- IF i_ins_item_id_tab IS NOT NULL and i_ins_item_id_tab.COUNT > 0 THEN

                x_copy_demand_id := l_copy_demand_id;

            END IF; -- IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'N' THEN

        END IF; -- IF <demand priority allocation> THEN
        -- CTO ODR and Simplified Pegging
        MSC_ATP_PEG.Add_Offset_Data(p_identifier ,
                                    p_config_line_id,
                                    p_plan_id      ,
                                    p_refresh_number,
                                    p_order_number  ,
                                    p_demand_source_type,--cmro
                                    x_atp_peg_items  ,
                                    x_atp_peg_demands ,
                                    x_atp_peg_supplies,
                                    x_atp_peg_res_reqs,
                                    x_demand_instance_id, --Bug 3629191
                                    x_supply_instance_id, --Bug 3629191
                                    x_res_instance_id,    --Bug 3629191
                                    l_return_status);
        -- END CTO ODR and Simplified Pegging

    END IF; -- IF p_plan_id = -1 THEN

    -- Commit removed for PDS cases - summary enhancement
    IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND p_plan_id = -1  AND G_ORIG_INV_CTP = 5 THEN
                -- Condition for INV_CTP added for bug 3295831 because summary
                -- is not supported in PDS-ODS switch.
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Summary mode commit, in Delete_Row');
        END IF;
        commit;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Delete_Row Procedure************');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Delete_Row');
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Delete_Row :' || sqlcode || ': ' || sqlerrm);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;


PROCEDURE Remove_Invalid_SD_Rec(
        p_identifier          IN      NUMBER,
        p_instance_id         IN      NUMBER,
        p_plan_id             IN      NUMBER, -- not use
        p_mode                IN      NUMBER,
        p_dc_flag             IN      NUMBER,
        x_return_status       OUT     NoCopy VARCHAR2
)
IS

    CURSOR pegging IS
        select  pegging_id, identifier3, identifier2, identifier1,
                supply_demand_type, inventory_item_id, char1, organization_id, supply_demand_date, --Bug 1419121
                supply_demand_quantity, department_id, resource_id, order_line_id, supplier_id, supplier_site_id,
                supplier_atp_date, dest_inv_item_id, summary_flag
                -- time_phased_atp
                , aggregate_time_fence_date
        from    mrp_atp_details_temp
        where   ((pegging_id <> p_identifier and (p_mode = 2 or p_mode = 3)) or
                (p_mode = 1))
        and     record_type in (3,4)
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        start with pegging_id = p_identifier
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        and     record_type = 3
        connect by parent_pegging_id = prior pegging_id
        AND     session_id = prior session_id
        AND     record_type in (3,4);

    c1 pegging%ROWTYPE;
    l_inventory_item_id number;
    --bug 2465088: increase size of l_demand class from 25 to 30 characters
    l_demand_class      varchar2(30);
    l_department_id     number;
    l_resource_id       number;
    l_instance_id       number;
    l_sd_qty            number;
    l_sd_date           date; -- bug 2120698
    l_organization_id   number;
    temp_sd_qty         number;
    l_supplier_id       number;
    l_supplier_site_id  number;
    l_start_date        date;

    -- time_phased_atp
    l_atf_date   date;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Remove_Invalid_SD_Rec Procedure *****');
    END IF;

    -- for ods, just need to remove the record from msc_sales_orders
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- rajjain 05/19/2003 bug 2959840
    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'Reset all the global variables ');
    -- Begin ATP4drp Allocation not supported for DRP plans.
    IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) = 5) THEN
        MSC_ATP_PVT.G_ALLOCATED_ATP :=  'N';
        MSC_ATP_PVT.G_ALLOCATION_METHOD := 2;
        IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
              msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'PF and Allocated ATP not applicable for DRP plans');
              msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
        END IF;
    ELSE
        -- ATP4drp set using the original value
        MSC_ATP_PVT.G_ALLOCATED_ATP := MSC_ATP_PVT.G_ORIG_ALLOC_ATP;
        MSC_ATP_PVT.G_ALLOCATION_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'),2);
    END IF;
    -- End ATP4drp
    MSC_ATP_PVT.G_INV_CTP := FND_PROFILE.value('INV_CTP') ;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'G_ALLOCATION_METHOD= ' || MSC_ATP_PVT.G_ALLOCATION_METHOD);
        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'G_ALLOCATED_ATP= ' || MSC_ATP_PVT.G_ALLOCATED_ATP);
        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'INV_CTP= ' || MSC_ATP_PVT.G_INV_CTP);
        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'p_mode= ' || p_mode);
        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'p_identifier= ' || p_identifier);
        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'p_instance_id = '||p_instance_id);
    END IF;


    OPEN pegging;
    LOOP

        FETCH pegging INTO c1;
        EXIT WHEN pegging%NOTFOUND;
        ---set l_inventory_item_id back to null;
        l_inventory_item_id := null;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'pegging_id = '||c1.pegging_id);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supply_demand_type = '||c1.supply_demand_type);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'identifier3 = '||c1.identifier3);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'plan_id (identifier2) = '||c1.identifier2);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'inventory_item_id := ' || c1.inventory_item_id);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supply_demand_quantity := ' || c1.supply_demand_quantity);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'organization_id := ' || c1.organization_id);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supply_demand_date := ' || c1.supply_demand_date);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supplier_id := ' || c1.supplier_id);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supplier_site_id := ' || c1.supplier_site_id);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supplier_atp_date := ' || c1.supplier_atp_date);
            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'Destination inv_item id := ' || c1.dest_inv_item_id);
        END IF;
        l_organization_id := null;

        IF p_mode = MSC_ATP_PVT.INVALID or (p_mode=MSC_ATP_PVT.UNDO and p_instance_id is null)  THEN

            MSC_ATP_DB_UTILS.Delete_Pegging(c1.pegging_id);

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'delete this pegging_id '||c1.pegging_id);
            END IF;
        END IF;

        IF c1.supply_demand_type = 2 THEN

            IF NVL(c1.inventory_item_id, -1) > 0 THEN

                -- delete the planned order that we may have enterred.
                DELETE FROM MSC_SUPPLIES
                WHERE transaction_id = c1.identifier3
                AND   plan_id = c1.identifier2
                returning inventory_item_id, sr_instance_id,new_order_quantity, organization_id, supplier_id, supplier_site_id
                into l_inventory_item_id, l_instance_id, l_sd_qty, l_organization_id, l_supplier_id, l_supplier_site_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_inventory_item_id := '|| l_inventory_item_id);
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_instance_id := ' || l_instance_id);
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_sd_qty := ' || l_sd_qty);
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_organization_id := ' || l_organization_id);
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_supplier_id := ' || l_supplier_id);
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_supplier_site_id := ' || l_supplier_site_id);
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'summary flag := ' || c1.summary_flag);
                END IF;

                -- time_phased_atp
                IF (c1.aggregate_time_fence_date is not null)
                   OR
                   ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: before delete of ' ||
                            '  msc_alloc_supplies');
                    END IF;

                    DELETE FROM MSC_ALLOC_SUPPLIES
                    WHERE parent_transaction_id = c1.identifier3
                    AND   plan_id = c1.identifier2;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'No. of supply deleted from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
                --  Allocated ATP Based on Planning Details -- Agilent changes End

                -- Code to update summary records and committing removed for Bug 3295831
                -- Supplies are being updated hence plan id would definitely not be -1
                /**
                IF c1.summary_flag = 'Y' and (c1.identifier3 > 0) and (p_plan_id = -1) THEN
                    -- Check for Plan_id=-1 added for summary enhancement
                    --- update the MSC_ATP_SUMMARY_SD table
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'update summary table');
                    END IF;
                    MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                                       p_plan_id,
                                                       l_organization_id,
                                                       l_inventory_item_id,
                                                       c1.supply_demand_date,
                                                       null,
                                                       null,
                                                       null,
                                                       null,
                                                       null,
                                                       null,
                                                       2);

                    UPDATE  /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* MSC_ATP_SUMMARY_SD
                    set     sd_qty = (sd_qty - l_sd_qty)
                    where   plan_id = p_plan_id and
                            sr_instance_id = l_instance_id and
                            inventory_item_id = l_inventory_item_id and
                            organization_id = l_organization_id and
                            sd_date = trunc(c1.supply_demand_date);
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'no of rows updated in summary mode := ' || SQL%ROWCOUNT);
                    END IF;

                    commit;
                END IF;
                **/

                -- Bug 1419121 Delete demand records which are inserted with supply_demand_type=2
                -- for taking care of demand class consumption. In such cases, the records in
                -- pegging tree are inserted with supply_demand_type = 2 and demand_class as
                -- NOT NULL.

                IF NVL(c1.char1, '@@@') <> '@@@' THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'delete stealing demand from msc_demands, demand_id = '||
                            c1.identifier3);
                    END IF;

                    DELETE FROM MSC_DEMANDS
                    WHERE demand_id = c1.identifier3
                    AND   plan_id = c1.identifier2;
                END IF;
            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

        ELSE    -- IF c1.supply_demand_type = 2 THEN

            -- delete the demand records we may have entrered.
            --4267076: Remove demand only when deamdn id is available
            IF NVL(c1.inventory_item_id, -1) > 0 AND c1.identifier3 is not null THEN
                IF c1.identifier2 <> -1 THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'delete demand from msc_demand, demand_id = '||
                            c1.identifier3);
                    END IF;

                    -- Bug 1661545, if scheduling was unsuccessful, old demand record needs to be
                    -- preserved back, as it was updated to 0 in the begining in case of reschedule in PDS.

                    DELETE  FROM MSC_DEMANDS
                    WHERE   demand_id = c1.identifier3
                    AND     plan_id = c1.identifier2
                    AND	    old_demand_quantity IS NULL
                    -- for bug 2120698, need to get the date and quantity from here
                    -- instead of pegging
                    returning inventory_item_id, sr_instance_id,
                            using_requirement_quantity, organization_id ,
                            trunc(using_assembly_demand_date)
                    into    l_inventory_item_id, l_instance_id,
                            l_sd_qty, l_organization_id,
                            l_sd_date;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'No. of demand deleted from msc_demand = '|| SQL%ROWCOUNT);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_inventory_item_id := ' || l_inventory_item_id);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_instance_id := ' || l_instance_id);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_sd_qty := ' || l_sd_qty);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_organization_id := ' || l_organization_id);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_sd_date :='||l_sd_date);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'summary_flag := ' || c1.summary_flag);
                    END IF;

                    -- time_phased_atp
                    IF (c1.aggregate_time_fence_date is not null)
                       OR
                       ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                        (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                        (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                        (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: before delete of' ||
                                ' msc_alloc_demands');
                        END IF;

                        DELETE FROM MSC_ALLOC_DEMANDS
                        WHERE parent_demand_id = c1.identifier3
                        AND	  old_allocated_quantity IS NULL
                        AND   plan_id = c1.identifier2;

                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'No. of demand deleted from msc_alloc_demands = '|| SQL%ROWCOUNT);
                        END IF;
                    END IF;
                    --  Allocated ATP Based on Planning Details -- Agilent changes End

                    -- Code to update summary records and committing removed for Bug 3295831
                    -- We are coming here only when c1.identifier2 <> -1
                    /**
                    IF (c1.summary_flag = 'Y') AND (c1.identifier3 > 0) and (p_plan_id = -1) THEN
                    -- Check for Plan_id=-1 added for summary enhancement
                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'summary mode, delete demand');
                        END IF;
                        MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                                  p_plan_id,
                                                  l_organization_id,
                                                  l_inventory_item_id,
                                                  l_sd_date,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  2);

                        UPDATE  /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* MSC_ATP_SUMMARY_SD
                        SET sd_qty = sd_qty + l_sd_qty
                        WHERE plan_id = p_plan_id
                        AND   sr_instance_id = l_instance_id
                        AND   organization_id = l_organization_id
                        AND   inventory_item_id = l_inventory_item_id
                        AND   sd_date = trunc(l_sd_date);
                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'no of rows updated in summary mode := ' || SQL%ROWCOUNT);
                        END IF;

                        commit;
                    END IF;
                    **/

                    ---- update supplier info if it is a supplier record
                    -- Code to update summary records and committing removed for Bug 3295831
                    /** code commented for time being. Will be removed after code review
                    IF  (c1.summary_flag = 'Y') AND (NVL(c1.supplier_id, -1) <> -1)  THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'update suppliers info ');
                        END IF;
                        MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(c1.identifier1,
                                          p_plan_id,
                                          null,
                                          c1.dest_inv_item_id,
                                           c1.supplier_atp_date,
                                          null,
                                          null,
                                          c1.supplier_id,
                                          c1.supplier_site_id,
                                          null,
                                          null,
                                          4);

                        update /*+ INDEX(msc_atp_summary_sup MSC_ATP_SUMMARY_SUP_U1) *//* msc_atp_summary_sup
                        set sd_qty = sd_qty + c1.supply_demand_quantity
                        where plan_id = p_plan_id
                        and   sr_instance_id = c1.identifier1
                        and inventory_item_id = c1.dest_inv_item_id
                        and supplier_id = c1.supplier_id
                        and supplier_site_id = c1.supplier_site_id
                        and sd_date = trunc(c1.supplier_atp_date);

                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'Number of rows updated in SUMMARY_SUP := ' || SQL%ROWCOUNT);
                        END IF;

                        MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(c1.identifier1,
                                          p_plan_id,
                                          null,
                                          c1.dest_inv_item_id,
                                           c1.supplier_atp_date,
                                          null,
                                          null,
                                          c1.supplier_id,
                                          c1.supplier_site_id,
                                          null,
                                          null,
                                          4);

                        commit;
                    END IF;
                    */

                ELSE    -- IF c1.identifier2 <> -1 THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'delete demand from msc_sales_orders, demand_id = '||
                            c1.identifier3);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'demand_source_line := ' || to_char(c1.order_line_id));
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'sr_instance_id := ' ||  c1.identifier1);
                    END IF;

                    DELETE  from msc_sales_orders
                    WHERE   demand_id = c1.identifier3
                    AND     demand_source_line = to_char(c1.order_line_id)
                    AND     sr_instance_id = c1.identifier1
                            -- for bug 2120698, need to get the date and quantity from here
                            -- instead of pegging
                    returning inventory_item_id, demand_class, sr_instance_id,
                            primary_uom_quantity, trunc(requirement_date)
                    into    l_inventory_item_id, l_demand_class, l_instance_id,
                            l_sd_qty, l_sd_date;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Rows deleted := ' || SQL%ROWCOUNT);
                    END IF;

                    IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') AND G_ORIG_INV_CTP = 5 THEN
                        -- Condition for INV_CTP added for bug 3295831 because summary
                        -- is not supported in PDS-ODS switch.
                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'Update summary sales order tbale');
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || ' supply_demand_quantity := '||c1.supply_demand_quantity);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || '  c1.inventory_item_id := ' ||  c1.inventory_item_id);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || ' instance_id := ' || p_instance_id);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || ' organization_id := ' || c1.organization_id);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'supply_demand_date := ' ||  c1.supply_demand_date);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_instance_id := ' || l_instance_id);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_sd_qty := ' || l_sd_qty);
                            msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_sd_date := ' || l_sd_date);
                        END IF;

                        BEGIN
                            IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'inventory_item id after conversion := ' || l_inventory_item_id);
                            END IF;

                            MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                                               -1,
                                                               c1.organization_id,
                                                               l_inventory_item_id,
                                                               l_sd_date,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               p_dc_flag,
                                                               l_demand_class,
                                                               1);


                            update  /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                                    -- bug 2120698, use the date and quantity from
                                    -- the returned value of msc_sales_orders instead of
                                    -- pegging info.  The reason is that for a ship set,
                                    -- we could update sd date to later date without
                                    -- changing the pegging.
                                    -- set sd_qty = (sd_qty - c1.supply_demand_quantity)
                            set     sd_qty = (sd_qty - l_sd_qty)
                            where   inventory_item_id = l_inventory_item_id
                            and     sr_instance_id = l_instance_id
                            and     organization_id = c1.organization_id
                                    -- bug 2120698: same reason above
                                    -- and sd_date = c1.supply_demand_date
                            and     sd_date = trunc(l_sd_date)
                            and     demand_class =Decode(p_dc_flag, 1, NVL(l_demand_class, '@@@'),'@@@') ;

                            MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                                               -1,
                                                               c1.organization_id,
                                                               l_inventory_item_id,
                                                               l_sd_date,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               p_dc_flag,
                                                               l_demand_class,
                                                               1);

                        EXCEPTION
                            WHEN OTHERS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || sqlerrm);
                                END IF;
                        END;
                    END IF;

                END IF; -- IF c1.identifier2 <> -1 THEN
            --bug 4267076: Delete only if demand_id/transaction id is available
            ELSIF c1.identifier3 is not null then     -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

                DELETE  FROM MSC_RESOURCE_REQUIREMENTS
                WHERE   transaction_id = c1.identifier3
                AND     plan_id = c1.identifier2
                AND   sr_instance_id = c1.identifier1 -- Bug 2675487 --3395085: Use correct instance_id
                returning department_id, resource_id, organization_id, start_date, sr_instance_id
                into    l_department_id, l_resource_id, l_organization_id, l_start_date, l_instance_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'summary_flag := ' || c1.summary_flag);
                END IF;

                -- Code to update summary records and committing removed for summary enhancement
                /** code commented for time being. Will be removed after code review
                IF c1.summary_flag = 'Y' THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_department_id = ' || l_department_id);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_resource_id = ' || l_resource_id);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_organization_id = ' || l_organization_id);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_start_date = ' || l_start_date);
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'l_instance_id = ' || l_instance_id);
                    END IF;

                    MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              null,
                                              l_start_date,
                                              l_resource_id,
                                              l_department_id,
                                              null,
                                              null,
                                              null,
                                              null,
                                              3);

                    UPDATE /*+ INDEX(msc_atp_summary_res MSC_ATP_SUMMARY_RES_U1) *//* MSC_ATP_SUMMARY_RES
                    set sd_qty = sd_qty + c1.supply_demand_quantity
                    where plan_id = p_plan_id
                    and   sr_instance_id = l_instance_id
                    and   organization_id = l_organization_id
                    and   department_id = l_department_id
                    and   resource_id = l_resource_id
                    and   sd_date =  trunc(l_start_date);

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Remove_Invalid_SD_Rec: ' || 'Number of row updated in MSC_ATP_SUMMARY_RES := ' || SQL%ROWCOUNT);
                    END IF;

                    MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              null,
                                              l_start_date,
                                              l_resource_id,
                                              l_department_id,
                                              null,
                                              null,
                                              null,
                                              null,
                                              3);

                    commit;
                END IF;
                **/

            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN
        END IF; -- IF c1.supply_demand_type = 2 THEN

    END LOOP;
    CLOSE pegging;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** End Remove_Invalid_SD_Rec Procedure *****');
    END IF;

END Remove_Invalid_SD_Rec;


PROCEDURE Update_Pegging(
  p_pegging_id          IN         NUMBER,
  p_date                IN         DATE,
  p_quantity            IN         NUMBER
)
IS
BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Begin Update_Pegging,p_pegging_id='||p_pegging_id);
      END IF;

      UPDATE mrp_atp_details_temp
      SET   supply_demand_quantity = NVL(p_quantity, supply_demand_quantity),
            supply_demand_date = NVL(p_date, supply_demand_date),
            --bug 3328421
            --required_date =  NVL(p_date, supply_demand_date)
            actual_supply_demand_date = NVL(p_date, supply_demand_date)
			-- dsting
	    , last_update_date = sysdate
	    , last_updated_by = FND_GLOBAL.USER_ID
	    , last_update_login = FND_GLOBAL.USER_ID
      WHERE pegging_id = p_pegging_id
      AND   session_id = MSC_ATP_PVT.G_SESSION_ID
      AND   record_type = 3;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('End Update_Pegging');
      END IF;
EXCEPTION
      WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('something wrong : Update_Pegging : ' || sqlcode);
          END IF;
END Update_Pegging;

PROCEDURE Update_Planned_Order(
        p_pegging_id          IN         NUMBER,
        p_plan_id             IN         NUMBER,
        p_date                IN         DATE,
        p_quantity            IN         NUMBER,
        p_supplier_id         IN         NUMBER,
        p_supplier_site_id    IN         NUMBER,
        p_dock_date           IN         DATE,
        p_ship_date           IN         DATE,     -- Bug 3241766
        p_start_date          IN         DATE,     -- Bug 3241766
        p_order_date          IN         DATE,     -- Bug 3241766
        p_mem_item_id         IN         NUMBER,   -- Bug 3293163
        p_pf_item_id          IN         NUMBER,
        p_mode                IN         NUMBER := MSC_ATP_PVT.UNDO,
        p_uom_conv_rate       IN         NUMBER := NULL
)
IS

    l_transaction_id    number;
    l_return_status     varchar2(1);
    l_child_pegging_id  number;
    l_demand_id         number;
    l_plan_id           number;
    l_inventory_item_id number;
    l_organization_id   number;
    l_sd_date           date;
    l_sd_qty            number;
    l_instance_id       number;
    temp_sd_qty         number;
    l_supplier_atp_date date;
    l_summary_flag      varchar2(1);

    -- dsting 2754446
    l_prim_uom_dmd_qty  number;

    -- time_phased_atp
    l_atf_date           date;
    l_po_qty             number;

    -- ATP4drp Additional Fields to track source and receiving orgs.
    l_receive_org_id     number;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Update_Planned_Order Procedure *****');
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_pegging_id = '||p_pegging_id);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_plan_id = '||p_plan_id);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_date = '||p_date);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_quantity = '||p_quantity);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_mode = '||p_mode);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_uom_conv_rate = '||p_uom_conv_rate);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_dock_date = '||p_dock_date);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_ship_date = '||p_ship_date);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_start_date = '||p_start_date);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_order_date = '||p_order_date);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_mem_item_id := ' || p_mem_item_id);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'p_pf_item_id := ' || p_pf_item_id);
    END IF;

    SELECT  identifier3, supply_demand_date, supply_demand_quantity, summary_flag
            ,aggregate_time_fence_date -- for time_phased_atp
            , receiving_organization_id, organization_id, identifier1  -- ATP4drp
    INTO    l_transaction_id, l_sd_date, l_po_qty, l_summary_flag
            ,l_atf_date -- for time_phased_atp
            , l_receive_org_id, l_organization_id, l_instance_id   -- ATP4drp
    FROM    mrp_atp_details_temp
    WHERE   pegging_id = p_pegging_id
    AND     record_type = 3
    AND     session_id = MSC_ATP_PVT.G_SESSION_ID ;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'after select');
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_sd_date := ' || l_sd_date);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_po_qty := ' || l_po_qty);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_summary_flag := ' || l_summary_flag);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_atf_date := ' || l_atf_date);
        -- ATP4drp print out organizations
        msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_receive_org_id := ' || l_receive_org_id);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_organization_id := ' || l_organization_id);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_instance_id := ' || l_instance_id);
        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_transaction_id := ' || l_transaction_id);
        -- ATP4drp print out organizations
    END IF;
    --diag_ATP: Do not remove the planned order in diagnostic mode even if the quantity is zero
    IF NVL(p_quantity, -1) = 0  AND (MSC_ATP_PVT.G_DIAGNOSTIC_ATP <> 1 or p_mode = MSC_ATP_PVT.INVALID) THEN

        MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
            p_pegging_id,
            null,
            p_plan_id,
            MSC_ATP_PVT.UNDO,
            0,
            l_return_status);

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'after delete mrp_atp_details_temp by calling remove');
        END IF;

        --s_cto_rearch
        IF MSC_ATP_PVT.G_INV_CTP = 4  THEN
            DELETE from msc_supplies
            WHERE  plan_id = p_plan_id
            AND    transaction_id = l_transaction_id;
        END IF;
        --e_cto_rearch

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'after msc_supplies');
        END IF;
    ELSE

        -- dsting diag_atp.
        IF p_mode <> 3 THEN
            MSC_ATP_DB_UTILS.Update_Pegging(p_pegging_id, p_date, p_quantity);
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'after first update to mrp_atp_details_temp');
        END IF;

        -- For bug 2259824, move the supply to the end of day
        --s_cto_rearch:
        IF MSC_ATP_PVT.G_INV_CTP = 4  THEN
            UPDATE  msc_supplies
            SET     new_schedule_date = TRUNC(NVL(p_date, new_schedule_date)) + MSC_ATP_PVT.G_END_OF_DAY ,
                    new_order_quantity = NVL(p_quantity, new_order_quantity),
                    -- rajjain 02/19/2003 Bug 2788302 Begin
                    supplier_id =      Decode(p_supplier_id,
                                              -1,null,
                                              p_supplier_id),
                    supplier_site_id = Decode(p_supplier_site_id,
                                              -1,null,
                                              p_supplier_site_id),
                    -- rajjain 02/19/2003 Bug 2788302 End
                    -- Bug 3821358, Making the dates at the end of the day
                    new_dock_date = TRUNC(NVL(p_dock_date, new_dock_date)) + MSC_ATP_PVT.G_END_OF_DAY,
                    -- rajjain 02/19/2003 Bug 2788302 Begin
                    source_supplier_id = decode(p_supplier_id,
                                                -1,null,
                                                p_supplier_id),
                    source_supplier_site_id = decode(p_supplier_site_id,
                                                     -1,null,
                                                     p_supplier_site_id),
                    -- rajjain 02/19/2003 Bug 2788302 End
                    -- ATP4drp Ensure that source data is updated
                    --4767922, only populating source_organization_id and source_sr_instance_id if p_supplier_id is NULL
                    source_organization_id = Decode(NVL(p_supplier_id,-1), -1, l_organization_id, NULL), --4767922
                    source_sr_instance_id = DEcode(NVL(p_supplier_id,-1), -1, l_instance_id, NULL), --4767922
                    -- End ATP4drp
                    -- Bug 3821358, Making the dates at the end of the day
                    new_ship_date            = TRUNC(NVL(p_ship_date,new_ship_date)) + MSC_ATP_PVT.G_END_OF_DAY,               -- Bug 3241766
                    new_wip_start_date       = TRUNC(NVL(p_start_date,new_wip_start_date)) + MSC_ATP_PVT.G_END_OF_DAY,         -- Bug 3241766
                    new_order_placement_date = TRUNC(NVL(p_order_date,new_order_placement_date)) + MSC_ATP_PVT.G_END_OF_DAY    -- Bug 3241766

            WHERE   plan_id = p_plan_id
            AND     transaction_id = l_transaction_id
            returning inventory_item_id, sr_instance_id, organization_id
            into    l_inventory_item_id, l_instance_id, l_organization_id;
        END IF;
        --e_cto_rearch

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_organization_id := '|| l_organization_id);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_inventory_item_id := ' || l_inventory_item_id);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_instance_id := ' || l_instance_id);
        END IF;

        -- time_phased_atp
        IF (p_mem_item_id <> p_pf_item_id) and (l_atf_date is not null) THEN
                MSC_ATP_PF.Update_PF_Rollup_Supplies(
                        p_plan_id,
                        l_transaction_id,
                        p_mem_item_id,
                        p_pf_item_id,
                        p_date,
                        p_quantity,
                        l_atf_date,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'Error occured in procedure Update_PF_Rollup_Supplies');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

        --  Allocated ATP Based on Planning Details -- Agilent changes Begin
        ELSIF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
            (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
            (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Update_Planned_Order: before update of' ||
                    ' msc_alloc_supplies');
            END IF;

            UPDATE  msc_alloc_supplies
            SET     old_supply_date = supply_date,
                    old_allocated_quantity = allocated_quantity,
                    supply_date = NVL(p_date, supply_date),
                    allocated_quantity = NVL(p_quantity, allocated_quantity),
                    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                    LAST_UPDATE_DATE = sysdate
            WHERE   plan_id = p_plan_id
            AND     parent_transaction_id = l_transaction_id;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'No of rows updated := ' || SQL%ROWCOUNT);
            END IF;
        END IF;

        --  Allocated ATP Based on Planning Details -- Agilent changes End

        -- Code to update summary records and committing removed for summary enhancement
        /** code commented for time being. Will be removed after code review
        IF l_summary_flag = 'Y' THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'in Summary mode, update planned orders');
            END IF;
            IF (p_date is NULL) THEN

                MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              l_inventory_item_id,
                                              l_sd_date,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              2);

                --- old and new dates are same
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'old and new dates are same');
                END IF;
                update /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* msc_atp_summary_sd
                set sd_qty = sd_qty - l_sd_qty + p_quantity
                where plan_id = p_plan_id
                and   inventory_item_id = l_inventory_item_id
                and   organization_id = l_organization_id
                and   sd_date = trunc(l_sd_date)
                and   sr_instance_id = l_instance_id;

                MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              l_inventory_item_id,
                                              l_sd_date,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              2);

            ELSE
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'old and new dates are  not same');
                  msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'Update summary for old date');
               END IF;

               MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              l_inventory_item_id,
                                              l_sd_date,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              2);

               UPDATE /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* MSC_ATP_SUMMARY_SD
               set sd_qty = (sd_qty - l_sd_qty)
               where sr_instance_id = l_instance_id and
                     inventory_item_id = l_inventory_item_id and
                     organization_id = l_organization_id and
                     sd_date = trunc(l_sd_date) and
                     plan_id = p_plan_id;

               MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              l_inventory_item_id,
                                              l_sd_date,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              2);


               --- if record exists then update
               commit;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'update the qty on new date ');
               END IF;

                MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                              p_plan_id,
                                              l_organization_id,
                                              l_inventory_item_id,
                                              p_date,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              2);

               update /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* msc_atp_summary_sd
               set sd_qty = (sd_qty + nvl(p_quantity, l_sd_qty))
               where plan_id = p_plan_id and
    		 sr_instance_id = l_instance_id and
                     inventory_item_id = l_inventory_item_id and
                     organization_id = l_organization_id and
                     sd_date = trunc(p_date);

               IF SQL%NOTFOUND THEN
                   --  record doesn't exists. insert the record
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'insert qty on new date');
                  END IF;

                   MSC_ATP_DB_UTILS.INSERT_SUMMARY_SD_ROW(p_plan_id,
                                                       l_instance_id,
                                                       l_organization_id,
                                                       l_inventory_item_id,
                                                       p_date,
                                                       NVL(p_quantity,l_sd_qty),
                                                       '@@@');
               END IF; --- if sql%notfound
               commit;
            END IF; --- if p_date is null;

            commit;
        END IF; -- if summary flag
        **/

        BEGIN

            -- we need to get the plan_id since this plan order and it's plan
            -- order demand may belong to different plans.

            SELECT  identifier3, pegging_id, NVL(identifier2, p_plan_id), supply_demand_date,
                    supply_demand_quantity, organization_id, supplier_atp_date, summary_flag
            INTO    l_demand_id, l_child_pegging_id, l_plan_id, l_sd_date, l_sd_qty, l_organization_id,
                    l_supplier_atp_date, l_summary_flag
            FROM    mrp_atp_details_temp
            WHERE   parent_pegging_id = p_pegging_id
            AND     record_type = 3
            AND     session_id = MSC_ATP_PVT.G_SESSION_ID;

        EXCEPTION
            WHEN others THEN
                l_demand_id := NULL;
                l_child_pegging_id := NULL;
                l_plan_id := NULL;
        END ;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_demand_id := '|| l_demand_id);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_plan_id := '|| l_plan_id);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_sd_date :=' || l_sd_date);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_sd_qty :=' || l_sd_qty);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_organization_id := ' || l_organization_id);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_instance_id := ' || l_instance_id);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_supplier_atp_date := ' || l_supplier_atp_date);
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_summary_flag := ' || l_summary_flag);
        END IF;

        --- update supplier info
        IF l_demand_id is not null AND p_quantity IS NOT NULL THEN

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'after 4');
            END IF;
            l_inventory_item_id := null;

            -- dsting diag_atp do not adjust demands
            IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP <> 1 THEN

                l_prim_uom_dmd_qty := p_quantity * nvl(p_uom_conv_rate, 1);

                UPDATE  msc_demands
                SET     USING_REQUIREMENT_QUANTITY = MSC_ATP_UTILS.Truncate_Demand(l_prim_uom_dmd_qty),
                        -- 24x7		-- 5598066
                        atp_synchronization_flag = 0
                WHERE   demand_id = l_demand_id
                AND     plan_id = l_plan_id
                returning sr_instance_id, inventory_item_id into l_instance_id, l_inventory_item_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'No of rows update := ' || SQL%ROWCOUNT);
                    msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_instance_id := ' || l_instance_id);
                    msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_inventory_item_id := ' || l_inventory_item_id);
                END IF;

                -- dsting 2754446. do i really want to do this
                IF l_prim_uom_dmd_qty <> l_sd_qty THEN
                    MSC_ATP_DB_UTILS.update_pegging(l_child_pegging_id, null, l_prim_uom_dmd_qty);
                END IF;

                -- time_phased_atp
                IF ((p_mem_item_id <> p_pf_item_id) and (l_atf_date is not null)) THEN
                        MSC_ATP_PF.Update_PF_Bucketed_Demands(
                                l_plan_id,
                                l_demand_id,
                                l_sd_date,
                                l_atf_date,
                                l_po_qty,
                                l_prim_uom_dmd_qty,       --bug 7361001
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'Error occured in procedure Update_PF_Bucketed_Demands');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                --  Allocated ATP Based on Planning Details -- Agilent changes Begin
                ELSIF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Update_Planned_Order: before update of' ||
                            ' msc_alloc_demands');
                    END IF;
                    UPDATE msc_alloc_demands
                    SET    allocated_quantity = MSC_ATP_UTILS.Truncate_Demand(l_prim_uom_dmd_qty)  --5598066
                    WHERE  parent_demand_id = l_demand_id
                    AND    plan_id = l_plan_id;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'No of rows updated := ' || SQL%ROWCOUNT);
                    END IF;

                END IF;

                --  Allocated ATP Based on Planning Details -- Agilent changes End

                -- Code to update summary records and committing removed for summary enhancement
                /** code commented for time being. Will be removed after code review
                IF l_summary_flag = 'Y' THEN

                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'Summary Mode- update planned order demand');
                  END IF;
                  MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(l_instance_id,
                                                  l_plan_id,
                                                  l_organization_id,
                                                  l_inventory_item_id,
                                                  l_sd_date,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  2);

                  UPDATE /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* MSC_ATP_SUMMARY_SD
                  -- dsting 2754446
                  SET sd_qty = sd_qty + l_sd_qty - l_prim_uom_dmd_qty
                --          SET sd_qty = sd_qty + l_sd_qty - p_quantity
                  where plan_id = l_plan_id
                  and   sr_instance_id = l_instance_id
                  and   organization_id = l_organization_id
                  and   inventory_item_id = l_inventory_item_id
                  and   sd_date = trunc(l_sd_date);
                  commit;
                END IF;
                **/
            END IF; -- if not DIAGNOSTIC ATP then update demands
	      --5239441
        ELSIF p_quantity IS NOT NULL and NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) = 5 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_Planned_Order: ' || 'l_demand_id :=  '|| l_demand_id);
            END IF;
            l_prim_uom_dmd_qty := p_quantity * nvl(p_uom_conv_rate, 1);
            IF l_prim_uom_dmd_qty <> l_sd_qty THEN
               MSC_ATP_DB_UTILS.UPDATE_PEGGING(l_child_pegging_id, null, l_prim_uom_dmd_qty);
            END IF;
        END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** END Update_Planned_Order Procedure *****');
    END IF;
EXCEPTION
    WHEN no_data_found THEN
        null;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('No Data Found in Update_Planned_Order');
        END IF;
END Update_Planned_Order;

PROCEDURE Update_SD_Date(p_identifier           IN NUMBER,
                         p_instance_id          IN NUMBER,
                         p_supply_demand_date   IN DATE,
                         p_plan_id              IN NUMBER,
                         p_supply_demand_qty    IN NUMBER, -- Bug 1501787
                         p_dc_flag              IN NUMBER,
                         p_old_demand_date      IN DATE,
                         p_old_demand_qty       IN NUMBER,
                         p_dmd_satisfied_date   IN DATE, -- bug 2795053-reopen
                         p_sd_date_quantity     IN NUMBER,   -- For time_phased_atp
                         p_atf_date             IN DATE,     -- For time_phased_atp
                         p_atf_date_quantity    IN NUMBER,   -- For time_phased_atp
                         p_sch_arrival_date     IN DATE,     -- For ship_rec_cal
                         p_order_date_type      IN NUMBER,   -- For ship_rec_cal
                         p_lat_date             IN DATE,     -- For ship_rec_cal
                         p_ship_set_name        IN VARCHAR2, -- plan by request date
                         p_arrival_set_name     IN VARCHAR2, -- plan by request date
                         p_override_flag        IN VARCHAR2,   -- plan by request date
                         p_request_arrival_date IN DATE,     -- plan by request date
                         p_bkwd_pass_atf_date_qty IN NUMBER,    -- For time_phased_atp bug3397904
                         p_atp_rec              IN MRP_ATP_PVT.AtpRec := NULL -- For bug 3226083
)
IS
    --bug 2465088: increase size of l_demand class from 25 to 30 characters
    l_demand_class      varchar2(30);
    l_sd_qty            number;
    l_sd_date           date;
    l_org_id            number;
    l_inventory_item_id number;
    l_count             number;
    temp_sd_qty         number;
    l_demand_id         number;
    l_summary_flag      varchar2(1);

    -- time_phased_atp
    l_bucketed_demands_rec      MSC_ATP_PF.Bucketed_Demands_Rec;
    l_return_status             varchar2(1);

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Update_SD_Date Procedure************');
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_supply_demand_date := ' || p_supply_demand_date);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_supply_demand_quantity := ' || p_supply_demand_qty);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_plan_id := ' || p_plan_id);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_old_demand_date := ' || p_old_demand_date);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_old_demand_qty := ' || p_old_demand_qty);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_instance_id := ' || p_instance_id);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_dc_flag := ' || p_dc_flag);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_identifier := ' || p_identifier);
        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'p_atf_date := ' || p_atf_date);
    END IF;

    -- dsting ATO 2465370
    BEGIN
        UPDATE mrp_atp_details_temp
        --bug 3328421
        --SET    required_date = TRUNC(NVL(p_supply_demand_date, required_date)) + MSC_ATP_PVT.G_END_OF_DAY
        SET    actual_supply_demand_date = TRUNC(NVL(p_supply_demand_date, actual_supply_demand_date)) + MSC_ATP_PVT.G_END_OF_DAY
        WHERE  pegging_id = MSC_ATP_PVT.G_DEMAND_PEGGING_ID
        AND    session_id = MSC_ATP_PVT.G_SESSION_ID
        AND    record_type = 3
        RETURNING identifier3, summary_flag INTO l_demand_id, l_summary_flag;
    EXCEPTION
        WHEN OTHERS THEN
            l_demand_id := null;
            l_summary_flag := 'N';
            RETURN;
    END;

    IF PG_DEBUG in ('Y','C') THEN
        msc_sch_wb.atp_debug('ATO update pegging id ' || MSC_ATP_PVT.G_DEMAND_PEGGING_ID);
    END IF;

    IF p_plan_id = -1  THEN
        -- ngoel, changed for performance reason, don't
        -- do anything in case p_supply_demand_date is NULL.
        IF p_supply_demand_date IS NOT NULL THEN
            -- For bug 2259824, move the demand to the end of day
            UPDATE  MSC_SALES_ORDERS
            SET     REQUIREMENT_DATE            = TRUNC(p_supply_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                    REQUEST_DATE                = TRUNC(p_request_arrival_date),--plan by request date
                    SCHEDULE_ARRIVAL_DATE       = TRUNC(p_sch_arrival_date) + MSC_ATP_PVT.G_END_OF_DAY,    --plan by request date
                    LATEST_ACCEPTABLE_DATE      = p_lat_date,
                    ORDER_DATE_TYPE_CODE        = p_order_date_type,
                    SHIP_SET_NAME               = p_ship_set_name,              --plan by request date
                    ARRIVAL_SET_NAME            = p_arrival_set_name,           --plan by request date
                    ATP_OVERRIDE_FLAG           = decode(upper(p_override_flag),'Y',1,2),              --plan by request date
                    PROMISE_DATE                = TRUNC(p_sch_arrival_date)     --plan by request date
            WHERE   SR_INSTANCE_ID = p_instance_id
            AND     DEMAND_SOURCE_LINE = to_char(p_identifier)
                    -- dsting ATO 2465370 I already selected l_demand_id
            AND     DEMAND_ID = l_demand_id
            returning demand_class, inventory_item_id into l_demand_class, l_inventory_item_id;

            IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') AND NVL(l_inventory_item_id, 0) > 0
                AND G_ORIG_INV_CTP = 5 THEN     -- Condition added for bug 3295831 because summary
                                                -- is not supported in PDS-ODS switch.
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'Summary Flag is on');
                END IF;
                --- get the old quantity and other info from pegging
                BEGIN
                    --- G_DEMAND_PEGGING_ID wil be null for non atpbale items
                    select supply_demand_quantity, supply_demand_date, organization_id
                    into   l_sd_qty, l_sd_date, l_org_id
                    from   mrp_atp_details_temp
                    where pegging_id = MSC_ATP_PVT.G_DEMAND_PEGGING_ID
                    and   session_id = MSC_ATP_PVT.G_SESSION_ID
                    and   record_type = 3;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_sd_qty := null;
                        l_sd_date := null;
                        l_org_id := null;
                        RETURN; -- We dont do anything for itmes which do not have pegging (non atpable items)
                END;
                ----update the quantity on old date

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_inventory_item_id := ' || l_inventory_item_id);
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_demand_class := ' || l_demand_class);
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_sd_qty := ' || l_sd_qty);
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_sd_date := ' || l_sd_date);
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_org_id := ' || l_org_id);
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'Update summary for old date');
                END IF;

                MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                                   -1,
                                                   l_org_id,
                                                   l_inventory_item_id,
                                                   l_sd_date,
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   p_dc_flag,
                                                   l_demand_class,
                                                   1);


                UPDATE  /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ MSC_ATP_SUMMARY_SO
                set     sd_qty = (sd_qty - l_sd_qty)
                where   sr_instance_id = p_instance_id and
                        inventory_item_id = l_inventory_item_id and
                        organization_id = l_org_id and
                        sd_date = trunc(l_sd_date) and
                        demand_class = decode(p_dc_flag, 1, NVL(l_demand_class, '@@@'), '@@@');
                commit;
                ---check if record for new date exists in summary table

                --- if record exists then update
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'update the qty on new date ');
                END IF;

                MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                                   -1,
                                                   l_org_id,
                                                   l_inventory_item_id,
                                                   p_supply_demand_date,
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   p_dc_flag,
                                                   l_demand_class,
                                                   1);

                update  /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                set     sd_qty = sd_qty + l_sd_qty
                where   sr_instance_id = p_instance_id and
                        inventory_item_id = l_inventory_item_id and
                        organization_id = l_org_id and
                        sd_date = trunc(p_supply_demand_date) and
                        demand_class = decode(p_dc_flag, 1, NVL(l_demand_class, '@@@'), '@@@');

                IF SQL%NOTFOUND THEN
                    --  record doesn't exists. insert the record
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Update_SD_Date: ' || 'insert qty on new date');
                    END IF;
                    BEGIN
                        insert /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ into msc_atp_summary_so
                                (plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                sd_date,
                                sd_qty,
                                demand_class,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATION_DATE,
                                CREATED_BY
                                )
                        VALUES
                                (-1,
                                l_inventory_item_id,
                                l_org_id,
                                p_instance_id,
                                trunc(p_supply_demand_date),
                                l_sd_qty,
                                Decode(p_dc_flag, 1, NVL(l_demand_class, '@@@') ,'@@@'),
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                sysdate,
                                FND_GLOBAL.USER_ID);
                    EXCEPTION
                        WHEN  DUP_VAL_ON_INDEX THEN
                            MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                                               -1,
                                                               l_org_id,
                                                               l_inventory_item_id,
                                                               p_supply_demand_date,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               p_dc_flag,
                                                               l_demand_class,
                                                               1);


                            update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                            set sd_qty = sd_qty + l_sd_qty
                            where inventory_item_id = l_inventory_item_id
                            and sr_instance_id = p_instance_id
                            and organization_id = l_org_id
                            and sd_date = trunc(p_supply_demand_date)
                            and demand_class = Decode(p_dc_flag, 1, NVL(l_demand_class, '@@@'),'@@@') ;

                            MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                                               -1,
                                                               l_org_id,
                                                               l_inventory_item_id,
                                                               p_supply_demand_date,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               p_dc_flag,
                                                               l_demand_class,
                                                               1);

                    END;

                END IF;
                commit;
            END IF;
        END IF;
    ELSE    -- IF p_plan_id = -1  THEN
        -- ngoel 2/13/2001, changed for performance reason, don't
        -- do anything in case p_supply_demand_date and p_supply_demand_qty is NULL.
        IF (p_supply_demand_qty IS NOT NULL OR p_supply_demand_date IS NOT NULL) THEN

            -- For bug 2259824, move the demand to the end of day
            IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Inside If of else p_plan_id = -1'); --bug3397904
            END IF;

            UPDATE  MSC_DEMANDS
            SET
            	    --start changes for plan by request date
                    SCHEDULE_SHIP_DATE          = TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                    USING_ASSEMBLY_DEMAND_DATE  =
                        decode(ORIGINATION_TYPE,
                               6,  decode(MSC_ATP_PVT.G_PLAN_INFO_REC.schedule_by_date_type,
                                          MSC_ATP_PVT.G_SCHEDULE_SHIP_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_SCHEDULE_ARRIVAL_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_PROMISE_SHIP_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,PROMISE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_PROMISE_ARRIVAL_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,PROMISE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_REQUEST_SHIP_DATE_LEGEND,
                                              REQUEST_SHIP_DATE,
                                          MSC_ATP_PVT.G_REQUEST_ARRIVAL_DATE_LEGEND,
                                              REQUEST_SHIP_DATE,
                                              TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY),
                               30, decode(MSC_ATP_PVT.G_PLAN_INFO_REC.schedule_by_date_type,
                                          MSC_ATP_PVT.G_SCHEDULE_SHIP_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_SCHEDULE_ARRIVAL_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_PROMISE_SHIP_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,PROMISE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_PROMISE_ARRIVAL_DATE_LEGEND,
                                              TRUNC(NVL(p_supply_demand_date,PROMISE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                                          MSC_ATP_PVT.G_REQUEST_SHIP_DATE_LEGEND,
                                              REQUEST_SHIP_DATE,
                                          MSC_ATP_PVT.G_REQUEST_ARRIVAL_DATE_LEGEND,
                                              REQUEST_SHIP_DATE,
                                              TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY),
                               TRUNC(NVL(p_supply_demand_date,USING_ASSEMBLY_DEMAND_DATE)) + MSC_ATP_PVT.G_END_OF_DAY), --plan by request date
                    promise_ship_date           = TRUNC(NVL(p_supply_demand_date,SCHEDULE_SHIP_DATE)) + MSC_ATP_PVT.G_END_OF_DAY, --plan by request date
                    request_date                = p_request_arrival_date, --plan by request date
                    promise_date                = p_sch_arrival_date,     --plan by request date
                    ship_set_name               = p_ship_set_name,        --plan by request date
                    arrival_set_name            = p_arrival_set_name,     --plan by request date
                     atp_override_flag           = decode(upper(p_override_flag),'Y',1,2), --plan by request date
                    --end changes for plan by request date
                    USING_REQUIREMENT_QUANTITY =  MSC_ATP_UTILS.Truncate_Demand(NVL(p_supply_demand_qty,USING_REQUIREMENT_QUANTITY)), -- Bug 1501787
                    -- 24x7 -- 5598066
                    ATP_SYNCHRONIZATION_FLAG = 0,
                    -- bug 2795053-reopen (ssurendr) update the demand_satisfied_date in msc_demands
                    DMD_SATISFIED_DATE = TRUNC(GREATEST(p_dmd_satisfied_date,DMD_SATISFIED_DATE)) + MSC_ATP_PVT.G_END_OF_DAY,
                    -- ship_rec_cal changes begin
                    SCHEDULE_ARRIVAL_DATE = NVL(p_sch_arrival_date, SCHEDULE_ARRIVAL_DATE),
                    ORDER_DATE_TYPE_CODE = NVL(p_order_date_type, ORDER_DATE_TYPE_CODE),
                    LATEST_ACCEPTABLE_DATE = NVL(p_lat_date, LATEST_ACCEPTABLE_DATE)
                    -- ship_rec_cal changes end
            WHERE   PLAN_ID = p_plan_id
            AND     DEMAND_ID = l_demand_id
            returning inventory_item_id, organization_id into l_inventory_item_id, l_org_id ;

            -- time_phased_atp changes begin
            IF p_atf_date is not null THEN
                MSC_ATP_PF.Move_PF_Bucketed_Demands(
                        p_plan_id,
                        l_demand_id,
                        p_old_demand_date,
                        p_supply_demand_date,
                        p_supply_demand_qty,
                        p_sd_date_quantity,
                        p_atf_date,
                        p_atf_date_quantity,
                        l_return_status,
                        p_bkwd_pass_atf_date_qty, --bug3397904
                        p_atp_rec -- For bug 3226083
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Update_SD_Date: ' || 'Error occured in procedure Move_PF_Bucketed_Demands');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
            -- time_phased_atp changes end

            --  Allocated ATP Based on Planning Details -- Agilent changes Begin
            ELSIF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_SD_Date: before update of ' ||
                        ' msc_alloc_demands');
                END IF;

                UPDATE  MSC_ALLOC_DEMANDS
                SET     ALLOCATED_QUANTITY = MSC_ATP_UTILS.Truncate_Demand(NVL(p_supply_demand_qty,
                        ALLOCATED_QUANTITY)),	--5598066
                        DEMAND_DATE = NVL(p_supply_demand_date, DEMAND_DATE),
                        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                        LAST_UPDATE_DATE = sysdate
                WHERE   PLAN_ID = p_plan_id
                AND     PARENT_DEMAND_ID = l_demand_id
                AND     INVENTORY_ITEM_ID = l_inventory_item_id
                AND     ORGANIZATION_ID = l_org_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'No of rows updated := ' || SQL%ROWCOUNT);
                END IF;

            END IF;

            --  Allocated ATP Based on Planning Details -- Agilent changes End

            -- Code to update summary records and committing removed for summary enhancement
            /** code commented for time being. Will be removed after code review
            IF l_summary_flag = 'Y' AND NVL(l_inventory_item_id, 0) > 0 THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'Summary Flag is on');
              END IF;
              --update the quantity on old date

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_inventory_item_id := ' || l_inventory_item_id);
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_demand_class := ' || l_demand_class);
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_sd_qty := ' || p_old_demand_date);
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_sd_date := ' || p_old_demand_qty);
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'l_org_id := ' || l_org_id);
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'Update summary for old date');
              END IF;

              MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                          p_plan_id,
                                          l_org_id,
                                          l_inventory_item_id,
                                          p_old_demand_date,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          2);

              UPDATE /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* MSC_ATP_SUMMARY_SD
              set sd_qty = (sd_qty + p_old_demand_qty)
              where sr_instance_id = p_instance_id and
                    inventory_item_id = l_inventory_item_id and
                    organization_id = l_org_id and
                    sd_date = trunc(p_old_demand_date) and
                    plan_id = p_plan_id;

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'No of rows update := ' || SQL%ROWCOUNT);
              END IF;
              commit;
              MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                          p_plan_id,
                                          l_org_id,
                                          l_inventory_item_id,
                                          p_old_demand_date,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          2);

              --- if record exists then update
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'update the qty on new date ');
              END IF;
              MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                          p_plan_id,
                                          l_org_id,
                                          l_inventory_item_id,
                                          p_supply_demand_date,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          2);

              update /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* msc_atp_summary_sd
              set sd_qty = sd_qty - NVL(p_supply_demand_qty, p_old_demand_qty)
              where plan_id = p_plan_id and
                    sr_instance_id = p_instance_id and
                    inventory_item_id = l_inventory_item_id and
                    organization_id = l_org_id and
                    sd_date = trunc(p_supply_demand_date);
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Update_SD_Date: ' || 'No of rows update := ' || SQL%ROWCOUNT);
              END IF;

              IF SQL%NOTFOUND THEN
                  --  record doesn't exists. insert the record
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Update_SD_Date: ' || 'insert qty on new date');
                 END IF;

                   MSC_ATP_DB_UTILS.INSERT_SUMMARY_SD_ROW(p_plan_id,
                                                   p_instance_id,
                                                   l_org_id,
                                                   l_inventory_item_id,
                                                   p_supply_demand_date,
                                                   -1 * NVL(p_supply_demand_qty, p_old_demand_qty),
                                                   '@@@');
              END IF; --- if sql%notfound
              commit;
            END IF; -- if sumamry_flag = 'Y'
            **/
        END IF; -- if p_summly_demand_qty is not null or....
    END IF ; -- if plan_id = -1

    -- commit removed for PDS cases - summary enhancement
    IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') and p_plan_id = -1 AND G_ORIG_INV_CTP = 5 THEN
       -- Condition for INV_CTP added for bug 3295831 because summary
       -- is not supported in PDS-ODS switch.
       commit;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Update_SD_Date Procedure************');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Update_SD_Date');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_SD_Date;


-- NGOEL 7/26/2001, Bug 1661545, if scheduling was unsuccessful, make sure that old demand record is
-- preserved back, as it was updated to 0 in the begining in case of reschedule in case of PDS.

-- RAJJAIN 11/01/2002, Now schedule procedure passes reference to del_demand_ids array to this
-- procedure
PROCEDURE Undo_Delete_Row(p_identifiers            IN   MRP_ATP_PUB.Number_Arr,
                          p_plan_ids               IN   MRP_ATP_PUB.Number_Arr,
                          p_instance_id            IN   NUMBER,
                          p_del_demand_ids         IN   MRP_ATP_PUB.Number_Arr,
                          p_inv_item_ids           IN   MRP_ATP_PUB.Number_Arr,
                          p_copy_demand_ids        IN   MRP_ATP_PUB.Number_Arr, -- For summary enhancement
                          p_copy_plan_ids          IN   MRP_ATP_PUB.Number_Arr, -- For summary enhancement
                          p_time_phased_set        IN   VARCHAR2,               -- For time_phased_atp
                          -- CTO ODR and Simplified Pegging
                          p_del_atp_peg_items      IN   MRP_ATP_PUB.Number_Arr,
                          p_del_atp_peg_demands    IN   MRP_ATP_PUB.Number_Arr,
                          p_del_atp_peg_supplies   IN   MRP_ATP_PUB.Number_Arr,
                          p_del_atp_peg_res_reqs   IN   MRP_ATP_PUB.Number_Arr,
                          p_demand_source_type     IN   MRP_ATP_PUB.Number_Arr,  --cmro
                          p_atp_peg_demands_plan_ids  IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                          p_atp_peg_supplies_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                          p_atp_peg_res_reqs_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                          p_del_ods_demand_ids         IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                          p_del_ods_inv_item_ids       IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                          p_del_ods_demand_src_type    IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                          p_del_ods_cto_demand_ids     IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                          p_del_ods_cto_inv_item_ids   IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                          p_del_ods_cto_dem_src_type   IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
                          p_del_ods_atp_refresh_no     IN MRP_ATP_PUB.Number_Arr,
                          p_del_ods_cto_atp_refresh_no IN MRP_ATP_PUB.Number_Arr
                          -- End CTO ODR and Simplified Pegging
)

IS
    l_del_rows	        NUMBER;
    i                   NUMBER;
    --l_identifiers	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    --l_plan_ids	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    --l_instance_ids	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    --rajjain 11/01/2002
    m                   PLS_INTEGER := 1;

    -- For bug 2738280.
    l_inventory_item_id	            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_using_assembly_demand_date    MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
    l_using_requirement_quantity    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_organization_id               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_plan_id                       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    -- CTO ODR and Simplified Pegging
    l_return_status         VARCHAR2(1);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Undo_Delete_Row Procedure************');
    END IF;

    --3720018, reverting back incase, rescheduling fails
    IF (p_del_ods_demand_ids IS NOT NULL AND p_del_ods_demand_ids.count > 0) THEN
      FOR m in 1..p_del_ods_demand_ids.count LOOP
        Update msc_sales_orders
               set Primary_uom_quantity = MSC_ATP_UTILS.Truncate_Demand(Old_primary_uom_quantity), --5598066
               reservation_quantity = MSC_ATP_UTILS.Truncate_Demand(old_reservation_quantity), --5598066
               inventory_item_id = p_del_ods_inv_item_ids(m),
               atp_refresh_number = p_del_ods_atp_refresh_no(m)
        WHERE  sr_instance_id = p_instance_id
        AND    demand_id = p_del_ods_demand_ids(m)
        AND    decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_del_ods_demand_src_type(m),
                                                100,
                                                p_del_ods_demand_src_type(m),
                                                -1);
      END LOOP;
      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Number of SO lines updated := ' || SQL%ROWCOUNT);
      END IF;
      --5357370
      IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Inside summary mode set to yes');
            msc_sch_wb.atp_debug('p_identifiers.count := ' || p_identifiers.count);
         END IF;
         FOR m in 1..p_identifiers.count LOOP
            MSC_ATP_DB_UTILS.UNDO_DELETE_SUMMARY_ROW(p_identifiers(m),
                                                     p_instance_id,
                                                     p_del_ods_demand_src_type(m));
         END LOOP;
      END IF;
    END IF;

    --3720018, reverting back in case, rescheduling fails
    IF (p_del_ods_cto_demand_ids IS NOT NULL AND p_del_ods_cto_demand_ids.count > 0) THEN
      FOR m in 1..p_del_ods_cto_demand_ids.count LOOP
        Update msc_sales_orders
               set Primary_uom_quantity = MSC_ATP_UTILS.Truncate_Demand(Old_primary_uom_quantity),  --5598066
               inventory_item_id = p_del_ods_cto_inv_item_ids(m),
               reservation_quantity = MSC_ATP_UTILS.Truncate_Demand(old_reservation_quantity), -- 5598066
               atp_refresh_number = p_del_ods_cto_atp_refresh_no(m)
        WHERE  sr_instance_id = p_instance_id
        AND    demand_id = p_del_ods_cto_demand_ids(m)
        AND    decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_del_ods_cto_dem_src_type(1),
                                                100,
                                                p_del_ods_cto_dem_src_type(m),
                                                -1);
      END LOOP;
      IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Number of SO lines updated for CTO := ' || SQL%ROWCOUNT);
      END IF;
    END IF;

    -- Bug 2738280. For loop should be inside if condition.
    IF ( p_del_demand_ids IS NOT NULL AND p_del_demand_ids.count > 0) THEN --3720018
       IF PG_DEBUG in ('Y', 'C') THEN
           FOR i in 1..p_del_demand_ids.COUNT LOOP
               msc_sch_wb.atp_debug('Undo_Delete_Row: ' || 'p_del_demand_ids('||i||') = '|| p_del_demand_ids(i)||
                                    'p_inv_item_ids('||i||') = '|| p_inv_item_ids(i)||
                                    'p_plan_ids('||i||') = '|| p_plan_ids(i)||
                                    'p_identifiers('||i||') = '|| p_identifiers(i));
           END LOOP;
       END IF;

    FORALL m IN 1..p_del_demand_ids.COUNT
    UPDATE  msc_demands
    SET     using_requirement_quantity = MSC_ATP_UTILS.Truncate_Demand(old_demand_quantity),	-- 5598066
            -- bug 2863322 : change the column used to store date
            using_assembly_demand_date = old_using_assembly_demand_date,
            inventory_item_id = p_inv_item_ids(m),
            applied = 2,
            status = 0,
            -- 24x7
            atp_synchronization_flag = 0,
            refresh_number = old_refresh_number -- For summary enhancement
    WHERE   sr_instance_id = p_instance_id
    AND     plan_id = p_plan_ids(m)
            --- rajjain we dont need this as demand_id is unique identifier
            --- AND    sales_order_line_id = p_identifiers(m)
            ---subst
    AND     demand_id = p_del_demand_ids(m)
            -- Bug 2738280. Also bulk collect values of the updated rows to be passed to procedure undo_plan_summary_row.
    RETURNING inventory_item_id, using_assembly_demand_date, using_requirement_quantity,
            organization_id, plan_id
    BULK COLLECT INTO l_inventory_item_id, l_using_assembly_demand_date, l_using_requirement_quantity,
            l_organization_id, l_plan_id;

	/* commented for bug 2738280. We should use SQL%BULK_ROWCOUNT for FORALL statemenrs
	l_del_rows := SQL%ROWCOUNT;
	IF PG_DEBUG in ('Y', 'C') THEN
	   	msc_sch_wb.atp_debug('Undo_Delete_Row: ' || 'No. of demands updated = '|| l_del_rows);
	END IF;
	*/

    -- Bug 2738280. Count how many rows were updated for each demand id
    IF PG_DEBUG in ('Y', 'C') THEN
        FOR m IN 1..p_del_demand_ids.COUNT LOOP
            msc_sch_wb.atp_debug('For Demand id '|| p_del_demand_ids(m)||': updated '||
                SQL%BULK_ROWCOUNT(m)||' records');
        END LOOP;
    END IF;

    IF (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') and (p_copy_demand_ids IS NOT NULL) and (p_copy_demand_ids.COUNT > 0) THEN
        -- Code to update summary records removed for summary enhancement
        /** code commented for time being. Will be removed after code review
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Undo_Delete_Row: ' || 'update Demands in summary mode');
        END IF;

        -- rajjain 11/05/2002 Now we pass reference to p_identifiers and p_plan_ids array
        -- and do bulk update in Undo_Plan_Summary_Row
        -- Bug 2738280. Complete change of the spec and body of this procedure.
        -- MSC_ATP_DB_UTILS.UNDO_PLAN_SUMMARY_ROW(p_identifiers, p_plan_ids, p_instance_id);
        MSC_ATP_DB_UTILS.UNDO_PLAN_SUMMARY_ROW(l_inventory_item_id,
                                               l_using_assembly_demand_date,
                                               l_using_requirement_quantity,
                                               l_organization_id,
                                               l_plan_id,
                                               p_instance_id);
        **/

        -- Delete the copy SOs and copy stealing records for summary enhancement
        IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
            (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
            (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) OR
            (p_time_phased_set = 'Y') THEN

            -- Delete from MSC_ALLOC_DEMANDS
            FORALL  i IN 1..p_copy_demand_ids.COUNT
            DELETE  FROM MSC_ALLOC_DEMANDS
            WHERE   parent_demand_id = p_copy_demand_ids(i)
            AND     plan_id = p_copy_plan_ids(i);

        ELSE

            -- Delete from MSC_ALLOC_DEMANDS
            FORALL  i IN 1..p_copy_demand_ids.COUNT
            DELETE  FROM MSC_DEMANDS
            WHERE   demand_id = p_copy_demand_ids(i)
            AND     plan_id = p_copy_plan_ids(i);

        END IF;

    END IF;

    -- rajjain 09/16/2002 Bug 2552015, this update not needed as in Schedule procedure
    -- we'll be looping on demand_id's.
    /*
    	--UPDATE statement for updating comp demands was here
    */

    --  Allocated ATP Based on Planning Details -- Agilent changes Begin

    IF (p_time_phased_set = 'Y')
     OR ((MSC_ATP_PVT.G_INV_CTP = 4) AND
        (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
        (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
        (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Undo_Delete_Row: before update of ' ||
                ' msc_alloc_demands');
        END IF;

        /*bug 6642564  we do no want  inventory item id to be updated
        in case of time phased ATP as,the inventory item id we are picking up
        from msc_demands but for time phased ATP inventory item id in msc_demands
        is of member item and msc_alloc_demands could me member item of product
        family item */

        IF  p_time_phased_set = 'Y' THEN

        FORALL  m IN 1..p_del_demand_ids.COUNT
        UPDATE  msc_alloc_demands
        SET     allocated_quantity = MSC_ATP_UTILS.Truncate_Demand(old_allocated_quantity),  --5598066
                demand_date = old_demand_date ,
                old_allocated_quantity = null,
                old_demand_date = null,
                --inventory_item_id = p_inv_item_ids(m),
                refresh_number = old_refresh_number -- For summary enhancement
        WHERE   sr_instance_id = p_instance_id
        AND     plan_id = p_plan_ids(m)
                --- rajjain we dont need this
                --- AND    sales_order_line_id = p_identifiers(m)
        AND     parent_demand_id = p_del_demand_ids(m)
        AND     old_allocated_quantity IS NOT NULL;  --bug 8731672

        ELSE

        FORALL  m IN 1..p_del_demand_ids.COUNT
        UPDATE  msc_alloc_demands
        SET     allocated_quantity = MSC_ATP_UTILS.Truncate_Demand(old_allocated_quantity),  --5598066
                demand_date = old_demand_date ,
                old_allocated_quantity = null,
                old_demand_date = null,
                inventory_item_id = p_inv_item_ids(m),
                refresh_number = old_refresh_number -- For summary enhancement
        WHERE   sr_instance_id = p_instance_id
        AND     plan_id = p_plan_ids(m)
                --- rajjain we dont need this
                --- AND    sales_order_line_id = p_identifiers(m)
        AND     parent_demand_id = p_del_demand_ids(m)
        AND     old_allocated_quantity IS NOT NULL;  --bug 8731672

        END IF;

        -- Bug 2738280. Count how many rows were updated for each demand id
        IF PG_DEBUG in ('Y', 'C') THEN
            FOR m IN 1..p_del_demand_ids.COUNT LOOP
                msc_sch_wb.atp_debug('For Demand id '|| p_del_demand_ids(m)||': updated '||
                    SQL%BULK_ROWCOUNT(m)||' records');
            END LOOP;
        END IF;

        /*
            UPDATE statement for comp demands was here
        */

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Undo_Delete_Row: before update of ' ||
                '  msc_alloc_supplies');
        END IF;

        FORALL  m IN 1..p_del_demand_ids.COUNT
        UPDATE  msc_alloc_supplies
        SET     allocated_quantity = old_allocated_quantity ,
                supply_date = old_supply_date ,
                old_allocated_quantity = null,
                old_supply_date = null,
                refresh_number = old_refresh_number -- For summary enhancement
        WHERE   sr_instance_id = p_instance_id
        AND     plan_id = p_plan_ids(m)
        AND     sales_order_line_id = p_identifiers(m)
        AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type(m),
                                                100,
                                                p_demand_source_type(m),
                                                -1) --CMRO
        AND     stealing_flag = 1
                --- rajjain 09/16/2002
        AND     old_allocated_quantity IS NOT NULL;

        -- Bug 2738280. Count how many rows were updated for each demand id
        IF PG_DEBUG in ('Y', 'C') THEN
            FOR m IN 1..p_del_demand_ids.COUNT LOOP
                msc_sch_wb.atp_debug('For Demand id '|| p_del_demand_ids(m)||': updated '||
                    SQL%BULK_ROWCOUNT(m)||' records');
            END LOOP;
        END IF;

    END IF;
    --  Allocated ATP Based on Planning Details -- Agilent changes End

    -- CTO ODR and Simplified Pegging
    MSC_ATP_PEG.Remove_Offset_Data(
                  --p_identifiers  , --Bug 3629191
                  --p_plan_ids ,     --Bug 3629191
                  p_del_atp_peg_items  ,
                  p_del_atp_peg_demands ,
                  p_del_atp_peg_supplies,
                  p_del_atp_peg_res_reqs,
                  p_demand_source_type,--cmro
                  p_atp_peg_demands_plan_ids,  --Bug 3629191
                  p_atp_peg_supplies_plan_ids, --Bug 3629191
                  p_atp_peg_res_reqs_plan_ids, --Bug 3629191
                  l_return_status);
     -- End CTO ODR and Simplified Pegging
    END IF; --3720018
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Undo_Delete_Row Procedure************');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Undo_Delete_Row');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Undo_Delete_Row;

PROCEDURE DELETE_SUMMARY_ROW (p_identifier                      IN NUMBER,
                     	      p_plan_id                         IN NUMBER,
                              p_instance_id                     IN NUMBER,
                              p_demand_source_type              IN NUMBER)  --cmro

IS
l_instance_id MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_organization_id MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_inventory_item_id MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_demand_class MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
l_sd_date MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
l_sd_qty  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
i  number;
-- 5357370 changes, need user id/sysdate for insert/update
l_user_id number;
l_sysdate date;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'Inside delete summary row');
           msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'p_identifier := ' || p_identifier);
           msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'p_instance_id := ' || p_instance_id);
        END IF;
        BEGIN
	   SELECT D.sr_instance_id,
      	   D.organization_id,
           D.inventory_item_id,
           Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 , NVL(D.DEMAND_CLASS, '@@@'), '@@@'),
           /*In case of reserved quantity check move to next working day*/
           DECODE(D.RESERVATION_TYPE,2,C2.next_date, trunc(D.REQUIREMENT_DATE)) SD_DATE, --5161110
           --D.REQUIREMENT_DATE SD_DATE, --5161110
           (D.PRIMARY_UOM_QUANTITY-GREATEST(NVL(D.RESERVATION_QUANTITY,0),
              D.COMPLETED_QUANTITY)) sd_qty
           BULK COLLECT INTO l_instance_id, l_organization_id, l_inventory_item_id, l_demand_class, l_sd_date, l_sd_qty
           FROM
           MSC_SALES_ORDERS D,
           MSC_ATP_RULES R,
           MSC_SYSTEM_ITEMS I,
           MSC_TRADING_PARTNERS P,
           msc_calendar_dates C,
           MSC_CALENDAR_DATES C2
           WHERE       D.DEMAND_SOURCE_LINE = TO_CHAR(P_IDENTIFIER)
           AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
           AND         D.SR_INSTANCE_ID = p_instance_id
           AND         I.ORGANIZATION_ID = D.ORGANIZATION_ID
    	   AND         I.SR_INSTANCE_ID = D.SR_INSTANCE_ID
           AND         D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    	   AND         I.PLAN_ID = -1
           AND         P.SR_TP_ID = I.ORGANIZATION_ID
           AND         P.SR_INSTANCE_ID = I.SR_INSTANCE_ID
           AND         P.PARTNER_TYPE = 3
    	   AND         R.RULE_ID  = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    	   AND         R.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    	   AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
    	   AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
    	   AND         D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
            		                 D.COMPLETED_QUANTITY)
    	   AND         (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                		      (SELECT S.SUB_INVENTORY_CODE
                    		      FROM   MSC_SUB_INVENTORIES S
                    		      WHERE  S.ORGANIZATION_ID=D.ORGANIZATION_ID
                    		      AND    S.PLAN_ID = I.PLAN_ID
                    		      AND    S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                    		      AND    S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                               		          1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                    		      AND    S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                               		          2, 1, S.NETTING_TYPE)))
    				      AND         (D.RESERVATION_TYPE = 2
                 		      OR D.PARENT_DEMAND_ID IS NULL
                 		      OR (D.RESERVATION_TYPE = 3 AND
                     			      ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                      			      (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
           -- Changed for 5161110
           AND C.PRIOR_SEQ_NUM >=
                		      DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                        	      NULL, C.PRIOR_SEQ_NUM,
          			      C2.next_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
    	  AND     C.CALENDAR_CODE = P.CALENDAR_CODE
    	  AND     C.SR_INSTANCE_ID = p_instance_id
    	  AND     C.EXCEPTION_SET_ID = -1
    	  AND     C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
    	  AND     C2.CALENDAR_CODE = P.calendar_code
	  AND     C2.EXCEPTION_SET_ID = P.calendar_exception_set_id
	  AND     C2.SR_INSTANCE_ID = P.SR_INSTANCE_ID
	  AND     C2.CALENDAR_DATE = TRUNC(sysdate);


        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'No row found that need to be deleted from summary table');
                END IF;
	END;
        -- 5357370: need user id for insert
        l_user_id  := FND_GLOBAL.USER_ID;
        l_sysdate := sysdate;


        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_inventory_item_id.count := ' || l_inventory_item_id.count);
           msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_user_id := '|| l_user_id);
           msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_sysdate := '|| l_sysdate);

        END IF;

        FOR i in 1..l_inventory_item_id.count LOOP
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'Row found, delete it from summary');
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_ivnevtory_item_id := ' || l_inventory_item_id(i));
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_organization_id := ' || l_organization_id(i) );
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_demand_class := ' || l_demand_class(i));
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_sd_date := ' || l_sd_date(i));
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_sd_qty := ' || l_sd_qty(i));
                   msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: ' || 'l_instance_id := ' || l_instance_id(i));
                END IF;

                update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                set sd_qty = (sd_qty - l_sd_qty(i))
                where inventory_item_id = l_inventory_item_id(i)
                and sr_instance_id = l_instance_id(i)
                and organization_id = l_organization_id(i)
                and sd_date = trunc(l_sd_date(i))
                and demand_class = l_demand_class(i) ;
                -- 5357370: this is to handle that we have reservation on the past due date, and
                -- we won't be able to find record on sysdate to update.
                IF (SQL%NOTFOUND) THEN
                  msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: update failed, now try insert');
                  --- Insert the new record
                  BEGIN
                    INSERT INTO MSC_ATP_SUMMARY_SO
                            (plan_id,
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
                    VALUES ( -1,
                             l_instance_id(i),
                             l_organization_id(i),
                             l_inventory_item_id(i),
                             l_demand_class(i),
                             trunc(l_sd_date(i)),
                             - l_sd_qty(i),
                             l_sysdate,
                             l_user_id ,
                             l_sysdate,
                             l_user_id
                           );
                  EXCEPTION

                  -- If a record has already been inserted by another process
                  -- If insert fails then update.
                    WHEN DUP_VAL_ON_INDEX THEN
                      -- Update the record.
                      update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                      set sd_qty = (sd_qty - l_sd_qty(i)),
                          last_update_date = l_sysdate,
                          last_updated_by = l_user_id
                      where inventory_item_id = l_inventory_item_id(i)
                      and sr_instance_id = l_instance_id(i)
                      and organization_id = l_organization_id(i)
                      and sd_date = trunc(l_sd_date(i))
                      and demand_class = l_demand_class(i) ;

                  END;
                END IF;
                -- 5357370: end of changes to handle the update failure.
                commit;

        END LOOP;

END DELETE_SUMMARY_ROW;

-- Bug 2738280. Change the body of procedure
PROCEDURE UPDATE_PLAN_SUMMARY_ROW (p_inventory_item_id		     IN MRP_ATP_PUB.Number_Arr,
				   p_old_demand_date                 IN MRP_ATP_PUB.Date_Arr,
                                   p_old_demand_quantity	     IN MRP_ATP_PUB.Number_Arr,
				   p_organization_id		     IN MRP_ATP_PUB.Number_Arr,
				   p_plan_id                         IN NUMBER,
                                   p_instance_id                     IN NUMBER)
IS
l_counter	PLS_INTEGER;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('******Begin Update_plan_summary_row *******');
           msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'p_instance_id := ' || p_instance_id);
           msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'p_plan_id := ' || p_plan_id);

	   FOR l_counter IN 1..p_inventory_item_id.COUNT LOOP
	    msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'Input parameters loop : '|| l_counter);
	    msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'p_inventory_item_id := ' || p_inventory_item_id(l_counter));
	    msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'p_organization_id := ' || p_organization_id(l_counter));
	    msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'p_old_demand_date := ' || p_old_demand_date(l_counter));
	    msc_sch_wb.atp_debug('UPDATE_PLAN_SUMMARY_ROW: ' || 'p_old_demand_quantity := ' || p_old_demand_quantity(l_counter));
           END LOOP;

        END IF;

	FORALL	l_counter IN 1..p_inventory_item_id.COUNT
	UPDATE  /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) */ MSC_ATP_SUMMARY_SD
	SET	SD_QTY = SD_QTY  + p_old_demand_quantity(l_counter)
	WHERE	INVENTORY_ITEM_ID = p_inventory_item_id(l_counter)
	AND	PLAN_ID = p_plan_id
	AND	SR_INSTANCE_ID = p_instance_id
	AND	ORGANIZATION_ID = p_organization_id(l_counter)
	AND	SD_DATE = trunc(p_old_demand_date(l_counter));

	-- Count how many rows were updated for each item
	IF PG_DEBUG in ('Y', 'C') THEN
	  FOR l_counter IN 1..p_inventory_item_id.COUNT LOOP
	     msc_sch_wb.atp_debug('For inventory Item id '||p_inventory_item_id(l_counter)||': updated '||
                          SQL%BULK_ROWCOUNT(l_counter)||' records');
	  END LOOP;
	END IF;

	-- issue commit;
	commit;

END UPDATE_PLAN_SUMMARY_ROW;

-- Bug 2738280. Change the body of procedure
PROCEDURE UNDO_PLAN_SUMMARY_ROW (p_inventory_item_id		   IN MRP_ATP_PUB.Number_Arr,
				 p_using_assembly_demand_date      IN MRP_ATP_PUB.Date_Arr,
                                 p_using_requirement_quantity	   IN MRP_ATP_PUB.Number_Arr,
				 p_organization_id		   IN MRP_ATP_PUB.Number_Arr,
				 p_plan_id                         IN MRP_ATP_PUB.Number_Arr,
                                 p_instance_id                     IN NUMBER)
IS
l_counter	PLS_INTEGER;
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('******Begin Undo_plan_summary_row *******');
           msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'p_instance_id := ' || p_instance_id);

	   FOR l_counter IN 1..p_inventory_item_id.COUNT LOOP
	    msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'Input parameters loop : '|| l_counter);
	    msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'p_inventory_item_id := ' || p_inventory_item_id(l_counter));
	    msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'p_organization_id := ' || p_organization_id(l_counter));
            msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'p_plan_id := ' || p_plan_id(l_counter));
	    msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'p_using_assembly_demand_date := ' || p_using_assembly_demand_date(l_counter));
	    msc_sch_wb.atp_debug('UNDO_PLAN_SUMMARY_ROW: ' || 'p_using_requirement_quantity := ' || p_using_requirement_quantity(l_counter));
           END LOOP;

        END IF;

	FORALL l_counter IN 1..p_inventory_item_id.COUNT
             UPDATE /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) */ MSC_ATP_SUMMARY_SD
             SET    SD_QTY	      = SD_QTY  - p_using_requirement_quantity(l_counter)
             WHERE  INVENTORY_ITEM_ID = p_inventory_item_id(l_counter)
             AND    PLAN_ID	      = p_plan_id(l_counter)
             AND    SR_INSTANCE_ID    = p_instance_id
             AND    ORGANIZATION_ID   = p_organization_id(l_counter)
             AND    SD_DATE	      = trunc(p_using_assembly_demand_date(l_counter));

	-- Count how many rows were updated for each item
	IF PG_DEBUG in ('Y', 'C') THEN
	  FOR l_counter IN 1..p_inventory_item_id.COUNT LOOP
	     msc_sch_wb.atp_debug('For inventory Item id '||p_inventory_item_id(l_counter)||': updated '||
                          SQL%BULK_ROWCOUNT(l_counter)||' records');
	  END LOOP;
	END IF;

	-- issue commit;
	commit;

END UNDO_PLAN_SUMMARY_ROW;

PROCEDURE INSERT_SUMMARY_SD_ROW( p_plan_id           IN NUMBER,
                                 p_instance_id       IN NUMBER,
                                 p_organization_id   IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_date              IN DATE,
                                 p_quantity          IN NUMBER,
                                 p_demand_class       IN VARCHAR2)
IS
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'insert into summary row');
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'p_plan_id := ' || p_plan_id);
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'p_instance_id := ' || p_instance_id);
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'p_organization_id := ' || p_organization_id);
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'p_inventory_item_id := ' || p_inventory_item_id);
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'p_date := ' || p_date);
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || ' p_quantity := ' || p_quantity);
           msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'p_demand_class := ' || p_demand_class);
        END IF;
        BEGIN
           insert /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) */ into msc_atp_summary_sd
               (plan_id,
	        inventory_item_id,
                organization_id,
                sr_instance_id,
                sd_date,
                sd_qty,
                demand_class,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY
                 )
                VALUES
                (p_plan_id,
		p_inventory_item_id,
                p_organization_id,
                p_instance_id,
                trunc(p_date),
                p_quantity,
                '@@@',
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID);
        EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
                 MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_instance_id,
                                          p_plan_id,
                                          p_organization_id,
                                          p_inventory_item_id,
                                          p_date,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          2);

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('INSERT_SUMMARY_SD_ROW: ' || 'Row already exists in table. Update the row');
                END IF;
                update /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) */ msc_atp_summary_sd
                set sd_qty = sd_qty + p_quantity
                where plan_id = p_plan_id
                and  inventory_item_id = p_inventory_item_id
                and  sr_instance_id = p_instance_id
                and  organization_id = p_organization_id
                and  sd_date = trunc(p_date);
	END;
END INSERT_SUMMARY_SD_ROW;

/* New procedure for Allocated ATP Based on Planning Details for Agilent */

PROCEDURE Add_Stealing_Supply_Details (
        p_plan_id               IN NUMBER,
        p_identifier            IN NUMBER,
        p_inventory_item_id     IN NUMBER,
        p_organization_id       IN NUMBER,
        p_sr_instance_id        IN NUMBER,
        p_stealing_quantity     IN NUMBER,
        p_stealing_demand_class IN VARCHAR2,
        p_stolen_demand_class   IN VARCHAR2,
        p_ship_date             IN DATE,
        p_transaction_id        OUT NoCopy NUMBER,
        p_refresh_number        IN NUMBER,
        p_ato_model_line_id       IN number,
        p_demand_source_type      IN    Number,  --cmro
        --bug3684383
        p_order_number           IN NUMBER
        ) IS -- For summary enhancement

l_rows_proc    NUMBER := 0;
BEGIN

    -- First add the Stealing Data.

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('*** Begin Add_Stealing_Supply_Details Procedure ***');
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_plan_id ='||to_char(p_plan_id));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_identifier ='||to_char(p_identifier));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_demand_source_type ='||to_char(p_demand_source_type));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_inventory_item_id ='||to_char(p_inventory_item_id));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_organization_id = ' ||to_char(p_organization_id));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_instance_id = ' ||to_char(p_sr_instance_id));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_stealing_quantity ='||to_char(p_stealing_quantity));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_stealing_demand_class = '||p_stealing_demand_class);
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_stolen_demand_class = ' ||p_stolen_demand_class);
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_ship_date = ' ||to_char(p_ship_date));
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'p_refresh_number = ' ||p_refresh_number);
    END IF;

    SELECT msc_supplies_s.nextval into p_transaction_id from dual;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'before insert into msc_alloc_supplies-Stealing Info');
    END IF;

    --ssurendr 25-NOV-2002: From_Demand_Class added in both the insert statements for alloc w/b drill down
    INSERT INTO MSC_ALLOC_SUPPLIES
        (plan_id, inventory_item_id, organization_id, sr_instance_id,
        demand_class, supply_date, parent_transaction_id,
        allocated_quantity, order_type, sales_order_line_id,demand_source_type, stealing_flag,  --cmro
        created_by, creation_date, last_updated_by, last_update_date, from_demand_class,
        ato_model_line_id,  refresh_number, -- For summary enhancement
        --bug3684383
        order_number,customer_id,ship_to_site_id
        )
    VALUES
        (p_plan_id, p_inventory_item_id, p_organization_id,
        p_sr_instance_id, p_stealing_demand_class, p_ship_date,
        p_transaction_id, p_stealing_quantity, 46, p_identifier,p_demand_source_type, 1,  ---cmro
        FND_GLOBAL.USER_ID, sysdate, FND_GLOBAL.USER_ID, sysdate, p_stolen_demand_class,
        p_ato_model_line_id, p_refresh_number, -- For summary enhancement
        --bug3684383
        p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID);

    l_rows_proc := SQL%ROWCOUNT;

    -- Next add the Stolen Data.

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'before insert into msc_alloc_supplies-Stolen Info');
    END IF;

    INSERT INTO MSC_ALLOC_SUPPLIES
        (plan_id, inventory_item_id, organization_id, sr_instance_id,
        demand_class, supply_date, parent_transaction_id,
        allocated_quantity, order_type, sales_order_line_id,demand_source_type, stealing_flag, --cmro
        created_by, creation_date, last_updated_by, last_update_date, from_demand_class,
        ato_model_line_id, refresh_number, -- For summary enhancement
        --bug3684383
        order_number,customer_id,ship_to_site_id)
    VALUES
        (p_plan_id, p_inventory_item_id, p_organization_id,
        p_sr_instance_id, p_stolen_demand_class, p_ship_date,
        p_transaction_id, -1 * p_stealing_quantity, 47, p_identifier,p_demand_source_type,1, --cmro
        FND_GLOBAL.USER_ID, sysdate, FND_GLOBAL.USER_ID, sysdate, p_stealing_demand_class,
        p_ato_model_line_id,  p_refresh_number, -- For summary enhancement
        --bug3684383
        p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID);

    l_rows_proc := l_rows_proc + SQL%ROWCOUNT;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Stealing_Supply_Details: ' || 'Total Rows inserted ' || l_rows_proc);
    END IF;

END Add_Stealing_Supply_Details;


PROCEDURE Remove_Invalid_Future_SD(
        p_future_pegging_tab            IN      MRP_ATP_PUB.Number_Arr
)
IS

CURSOR pegging(p_pegging_id	IN	NUMBER)
IS
SELECT	pegging_id, identifier1, identifier2, identifier3
FROM 	mrp_atp_details_temp
WHERE	pegging_id = p_pegging_id
AND	record_type in (3,4)
AND	session_id = MSC_ATP_PVT.G_SESSION_ID
START WITH pegging_id = p_pegging_id
AND 	session_id = MSC_ATP_PVT.G_SESSION_ID
AND 	record_type = 3
CONNECT BY parent_pegging_id = PRIOR pegging_id
AND 	session_id = prior session_id
AND 	record_type in (3,4);

c1 	pegging%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Remove_Invalid_Future_SD Procedure *****');
  END IF;

  FOR i IN p_future_pegging_tab.FIRST..p_future_pegging_tab.COUNT LOOP
      OPEN pegging(p_future_pegging_tab(i));
      LOOP

         FETCH pegging INTO c1;
         EXIT WHEN pegging%NOTFOUND;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Remove_Invalid_Future_SD: ' || 'instance id = '||c1.identifier1);
            msc_sch_wb.atp_debug('Remove_Invalid_Future_SD: ' || 'plan_id (identifier2) = '||c1.identifier2);
            msc_sch_wb.atp_debug('Remove_Invalid_Future_SD: ' || 'identifier3 = '||c1.identifier3);
            msc_sch_wb.atp_debug('Remove_Invalid_Future_SD: ' || 'delete pegging_id '||c1.pegging_id);
         END IF;

         MSC_ATP_DB_UTILS.Delete_Pegging(c1.pegging_id);

         DELETE MSC_ALLOC_SUPPLIES
         WHERE parent_transaction_id = c1.identifier3
         AND   plan_id = c1.identifier2
	 AND   sr_instance_id = c1.identifier1;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Remove_Invalid_Future_SD: ' || 'Records deleted from msc_alloc_supplies = '|| SQL%ROWCOUNT);
         END IF;

      END LOOP;
      CLOSE pegging;
  END LOOP; 	--FOR i IN p_future_pegging_tab.FIRST..p_future_pegging_tab.COUNT LOOP

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Remove_Invalid_Future_SD Procedure *****');
  END IF;

END Remove_Invalid_Future_SD;

---------------------------------------------------------------------------

/*
 * dsting: 9/17/2002
 *
 * Copy the data from the msc_atp_sd_details_temp table
 * into mrp_atp_details_temp. Plus, slap on a pegging id and
 * end_pegging_id
 *
 * Delete the entries in msc_atp_sd_details_temp
 * since we don't need them anymore too.
 */
PROCEDURE move_SD_temp_into_mrp_details(
  p_pegging_id     IN NUMBER,
  p_end_pegging_id IN NUMBER)
IS
sql_stmt VARCHAR2(3000);
who_cols VARCHAR2(100);
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('PROCEDURE move_SD_temp_into_mrp_details');
	   msc_sch_wb.atp_debug('move_SD_temp_into_mrp_details: ' || '   p_pegging_id: '     || p_pegging_id);
	   msc_sch_wb.atp_debug('move_SD_temp_into_mrp_details: ' || '   p_end_pegging_id: ' || p_end_pegging_id);
	   msc_sch_wb.atp_debug('move_SD_temp_into_mrp_details: ' || '   session_id: ' || MSC_ATP_PVT.G_SESSION_ID);
	END IF;

	INSERT INTO mrp_atp_details_temp (
			session_id,
	 		scenario_id,
		 	order_line_id,
		 	ATP_Level,
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
		 	Uom_code,
		 	Identifier1,
	 		Identifier2,
		 	Identifier3,
		 	Identifier4,
	 		Supply_Demand_Type,
		 	Supply_Demand_Source_Type,
		 	Supply_Demand_Source_type_name,
	 		Supply_Demand_Date,
		 	supply_demand_quantity,
		 	disposition_type,
	 		disposition_name,
	         	record_type,
        	 	pegging_id,
         		end_pegging_id,
		 	creation_date,
	 		created_by,
		 	last_update_date,
		 	last_updated_by,
	 		last_update_login,
	 		-- time_phased_atp
	 		Allocated_Quantity,
	 		Original_Demand_Quantity,
	 		Original_Demand_Date,
	 		Original_Item_Id,
	 		Original_Supply_Demand_Type,
	 		Pf_Display_Flag,
	 		ORIG_CUSTOMER_SITE_NAME,--bug3263368
                        ORIG_CUSTOMER_NAME, --bug3263368
                        ORIG_DEMAND_CLASS, --bug3263368
                        ORIG_REQUEST_DATE, --bug3263368
                        INVENTORY_ITEM_NAME --bug3579625
		)
		SELECT
			MSC_ATP_PVT.G_SESSION_ID,
	 		scenario_id,
		 	order_line_id,
		 	ATP_Level,
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
	 		Uom_code,
		 	Identifier1,
		 	Identifier2,
	 		Identifier3,
		 	Identifier4,
		 	Supply_Demand_Type,
	 		Supply_Demand_Source_Type,
		 	Supply_Demand_Source_type_name,
		 	Supply_Demand_Date,
	 		supply_demand_quantity,
		 	disposition_type,
		 	disposition_name,
         		2,
	         	p_pegging_id,
        	 	p_end_pegging_id,
		 	creation_date,
	 		created_by,
		 	last_update_date,
		 	last_updated_by,
	 		last_update_login,
	 		-- time_phased_atp
	 		Allocated_Quantity,
	 		Original_Demand_Quantity,
	 		Original_Demand_Date,
	 		Original_Item_Id,
	 		Original_Supply_Demand_Type,
	 		Pf_Display_Flag,
	 		ORIG_CUSTOMER_SITE_NAME,--bug3263368
                        ORIG_CUSTOMER_NAME, --bug3263368
                        ORIG_DEMAND_CLASS, --bug3263368
                        ORIG_REQUEST_DATE, --bug3263368
                        INVENTORY_ITEM_NAME --bug3579625
		FROM msc_atp_sd_details_temp;

		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('move_SD_temp_into_mrp_details: ' || '    Num rows dumped: ' || SQL%ROWCOUNT);
		END IF;
END move_SD_temp_into_mrp_details;

PROCEDURE Clear_SD_Details_Temp
IS
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('PROCEDURE Clear_SD_Details_Temp');
	   msc_sch_wb.atp_debug('PG_Clear_SD_Details_Temp: ' || PG_CLEAR_SD_DETAILS_TEMP);
 	END IF;

	IF PG_CLEAR_SD_DETAILS_TEMP = 1 THEN
		DELETE msc_atp_sd_details_temp;
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Clear_SD_Details_Temp rows: ' || SQL%ROWCOUNT);
	 	END IF;
	END IF;
	PG_CLEAR_SD_DETAILS_TEMP := 1;
END;

-- new procedure for summary enhancement
-- Delete the copy demands that were created in this transaction if refresh number has moved.
PROCEDURE Delete_Copy_Demand (
                p_copy_demand_ids           IN  MRP_ATP_PUB.Number_Arr,
                p_copy_plan_ids             IN  MRP_ATP_PUB.Number_Arr,
                p_time_phased_set           IN  VARCHAR2,
                x_return_status             OUT NOCOPY VARCHAR2)
IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug(' ******** Delete_Copy_Demand Begin *************');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    msc_sch_wb.atp_debug('Delete_Copy_Demand : ' || 'p_copy_demand_ids.COUNT : ' || p_copy_demand_ids.COUNT);

    IF p_copy_demand_ids.COUNT > 0 THEN
        IF ((MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
            (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) OR
            (p_time_phased_set = 'Y') THEN

            msc_sch_wb.atp_debug('Delete_Copy_Demand : ' || 'allocated ATP or time phased PF');

            FORALL i IN 1..p_copy_demand_ids.COUNT
            DELETE FROM msc_alloc_demands
            WHERE  parent_demand_id = p_copy_demand_ids(i)
            AND    plan_id = p_copy_plan_ids(i)
            AND    refresh_number <= (SELECT nvl(latest_refresh_number,-1)
                                      FROM   MSC_PLANS
                                      WHERE  plan_id = p_copy_plan_ids(i));

        END IF;

        IF NOT ((MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

            msc_sch_wb.atp_debug('Delete_Copy_Demand : ' || 'unallocated ATP');

            FORALL i IN 1..p_copy_demand_ids.COUNT
            DELETE FROM msc_demands
            WHERE  demand_id = p_copy_demand_ids(i)
            AND    plan_id = p_copy_plan_ids(i)
            AND    refresh_number <= (SELECT nvl(latest_refresh_number,-1)
                                      FROM   MSC_PLANS
                                      WHERE  plan_id = p_copy_plan_ids(i));

        END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug(' ******** Delete_Copy_Demand End *************');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END Delete_Copy_Demand;

-- New procedure added for ship_rec_cal project
PROCEDURE Flush_Data_In_Pds(
	p_ship_arrival_date_rec         IN	MSC_ATP_PVT.ship_arrival_date_rec_typ,
	x_return_status                 OUT     NOCOPY  VARCHAR2
	)
IS

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug(' ******** Flush_Data_In_Pds Begin *************');
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'sch arrival date: ' || p_ship_arrival_date_rec.scheduled_arrival_date);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'lat accep date  : ' || p_ship_arrival_date_rec.latest_acceptable_date);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'order_date_type : ' || p_ship_arrival_date_rec.order_date_type);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'demand_id       : ' || p_ship_arrival_date_rec.demand_id);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'instance_id     : ' || p_ship_arrival_date_rec.instance_id);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'plan_id         : ' || p_ship_arrival_date_rec.plan_id);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'ship_set_name   : ' || p_ship_arrival_date_rec.ship_set_name);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'arrival_set_name: ' || p_ship_arrival_date_rec.arrival_set_name);
                msc_sch_wb.atp_debug('Flush_Data_In_Pds : ' || 'override_flag   : ' || p_ship_arrival_date_rec.atp_override_flag);
        END IF;

	-- Update PDS
	UPDATE 	MSC_DEMANDS
	SET	SCHEDULE_ARRIVAL_DATE   = p_ship_arrival_date_rec.scheduled_arrival_date,
		LATEST_ACCEPTABLE_DATE  = p_ship_arrival_date_rec.latest_acceptable_date,
		ORDER_DATE_TYPE_CODE    = p_ship_arrival_date_rec.order_date_type,
		SHIP_SET_NAME		= p_ship_arrival_date_rec.ship_set_name,--plan by request date
		ARRIVAL_SET_NAME	= p_ship_arrival_date_rec.arrival_set_name,--plan by request date
		ATP_OVERRIDE_FLAg	= decode(upper(p_ship_arrival_date_rec.atp_override_flag),'Y',1,2),--plan by request date
		PROMISE_DATE		= p_ship_arrival_date_rec.scheduled_arrival_date, --plan by request date
		REQUEST_DATE		= p_ship_arrival_date_rec.request_arrival_date
	WHERE	DEMAND_ID               = p_ship_arrival_date_rec.demand_id
	AND	SR_INSTANCE_ID          = p_ship_arrival_date_rec.instance_id
	AND	PLAN_ID                 = p_ship_arrival_date_rec.plan_id;


EXCEPTION
    WHEN OTHERS THEN
    	msc_sch_wb.atp_debug('Flush_Data_In_Pds : '||sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;

END Flush_Data_In_Pds;

-- New procedure added for plan by request date project
PROCEDURE Flush_Data_In_Ods(
	p_ship_arrival_date_rec         IN	MSC_ATP_PVT.ship_arrival_date_rec_typ,
	x_return_status                 OUT     NOCOPY  VARCHAR2
	)
IS

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug(' ******** Flush_Data_In_Ods Begin *************');
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'sch arrival date    : ' || p_ship_arrival_date_rec.scheduled_arrival_date);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'lat accep date      : ' || p_ship_arrival_date_rec.latest_acceptable_date);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'order_date_type     : ' || p_ship_arrival_date_rec.order_date_type);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'demand_id           : ' || p_ship_arrival_date_rec.demand_id);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'instance_id         : ' || p_ship_arrival_date_rec.instance_id);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'plan_id             : ' || p_ship_arrival_date_rec.plan_id);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'ship_set_name       : ' || p_ship_arrival_date_rec.ship_set_name);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'arrival_set_name    : ' || p_ship_arrival_date_rec.arrival_set_name);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'override_flag       : ' || p_ship_arrival_date_rec.atp_override_flag);
                msc_sch_wb.atp_debug('Flush_Data_In_Ods : ' || 'request arrival date: ' || p_ship_arrival_date_rec.request_arrival_date);

        END IF;

	-- Update PDS
	UPDATE 	MSC_SALES_ORDERS
	SET	SCHEDULE_ARRIVAL_DATE   	= p_ship_arrival_date_rec.scheduled_arrival_date,
		LATEST_ACCEPTABLE_DATE  	= p_ship_arrival_date_rec.latest_acceptable_date,
		ORDER_DATE_TYPE_CODE    	= p_ship_arrival_date_rec.order_date_type,
		SHIP_SET_NAME			= p_ship_arrival_date_rec.ship_set_name,
		ARRIVAL_SET_NAME		= p_ship_arrival_date_rec.arrival_set_name,
		ATP_OVERRIDE_FLAg		= decode(upper(p_ship_arrival_date_rec.atp_override_flag),'Y',1,2),
		REQUEST_DATE			= p_ship_arrival_date_rec.request_arrival_date
	WHERE	DEMAND_ID                       = p_ship_arrival_date_rec.demand_id
	AND	SR_INSTANCE_ID                  = p_ship_arrival_date_rec.instance_id;

EXCEPTION
    WHEN OTHERS THEN
    	msc_sch_wb.atp_debug('Flush_Data_In_Ods : '||sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;

END Flush_Data_In_Ods;

--bug 3766179: add new procedure to add supplies irrespective of supply type
PROCEDURE Add_Supplies ( p_supply_rec_type IN OUT NOCOPY MSC_ATP_DB_UTILS.supply_rec_typ)

IS
    temp_sd_qty number;

    -- time_phased_atp
    l_time_phased_atp      varchar2(1) := 'N';
    l_insert_item_id       number;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Supplies Procedure *****');
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_supply_rec_type.order_quantity := ' || p_supply_rec_type.order_quantity);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_inventory_item_id := ' || p_supply_rec_type.inventory_item_id);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_schedule_date := ' || p_supply_rec_type.schedule_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_organization_id := ' || p_supply_rec_type.organization_id);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_schedule_date := ' || p_supply_rec_type.schedule_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_supplier_id := ' || p_supply_rec_type.supplier_id);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_supplier_site_id := ' || p_supply_rec_type.supplier_site_id);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_refresh_number := ' || p_supply_rec_type.refresh_number);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_request_item_id := ' || p_supply_rec_type.request_item_id);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_atf_date := ' || p_supply_rec_type.atf_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_new_dock_date := ' || p_supply_rec_type.new_dock_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_new_ship_date := ' || p_supply_rec_type.new_ship_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_start_date := ' || p_supply_rec_type.start_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_order_date := ' || p_supply_rec_type.order_date);
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'p_intransit_lead_time := ' || p_supply_rec_type.intransit_lead_time); --4127630
    END IF;

    p_supply_rec_type.return_status := FND_API.G_RET_STS_SUCCESS;

    -- time_phased_atp changes begin
    IF (p_supply_rec_type.inventory_item_id <> p_supply_rec_type.request_item_id) and p_supply_rec_type.atf_date is not null THEN
        l_time_phased_atp := 'Y';
        /* In time phased atp scenarios add planned order in msc_supplies for member item*/
        l_insert_item_id := p_supply_rec_type.request_item_id;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'Time Phased ATP = ' || l_time_phased_atp);
        END IF;
    ELSE
        l_insert_item_id := p_supply_rec_type.inventory_item_id;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'Insert planned order in msc_supplies for ' || l_insert_item_id);
    END IF;
    -- time_phased_atp changes end

    -- Insert updated quantity as a Planned Order in msc_supplies
    INSERT into MSC_SUPPLIES
           (plan_id,
            transaction_id,
            organization_id,
            sr_instance_id,
            inventory_item_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            new_schedule_date,
            disposition_status_type, -- 1512366
            order_type,
            new_order_quantity,
            supplier_id,
            supplier_site_id,
            -- rajjain 02/19/2003 Bug 2788302 Begin
            source_supplier_id,
            source_supplier_site_id,
            source_sr_instance_id,
            source_organization_id,
            process_seq_id,
            -- rajjain 02/19/2003 Bug 2788302 End
            firm_planned_type,
            demand_class,
            customer_id,
            ship_to_site_id,
            record_source,-- for plan order pegging, rmehra
            refresh_number, -- for summary enhancement
            -- ship_rec_cal changes begin
            new_dock_date,
            new_ship_date,
            new_wip_start_date,         -- Bug 3241766
            new_order_placement_date,   -- Bug 3241766
            ship_calendar,
            receiving_calendar,
            intransit_calendar,
            ship_method,
            -- ship_rec_cal changes end
            disposition_id,
            INTRANSIT_LEAD_TIME --4127630
            )
    VALUES (p_supply_rec_type.plan_id,
            msc_supplies_s.nextval,
            p_supply_rec_type.organization_id,
            p_supply_rec_type.instance_id,
            l_insert_item_id, -- for time_phased_atp
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            -- For bug 2259824, move the supply to the end of day
            TRUNC(p_supply_rec_type.schedule_date) + MSC_ATP_PVT.G_END_OF_DAY,
            p_supply_rec_type.disposition_status_type, -- 1512366: open
            p_supply_rec_type.supply_type,
            p_supply_rec_type.order_quantity,
            p_supply_rec_type.supplier_id,
            p_supply_rec_type.supplier_site_id,
            -- rajjain 02/19/2003 Bug 2788302 Begin
            p_supply_rec_type.supplier_id,
            p_supply_rec_type.supplier_site_id,
            p_supply_rec_type.source_sr_instance_id,
            p_supply_rec_type.source_organization_id,
            p_supply_rec_type.process_seq_id,
            -- rajjain 02/19/2003 Bug 2788302 End
            p_supply_rec_type.firm_planned_type,
            --decode(MSC_ATP_PVT.G_HIERARCHY_PROFILE, 1, p_demand_class, null),
            ---2424357: after demand priority p_demand_class contains converted demand calss
            --- we always store the actual demand class passes as a part of the query.
            -- Bug 3558125 - Populate '-1' if G_ATP_DEMAND_CLASS is NULL
            decode(MSC_ATP_PVT.G_HIERARCHY_PROFILE, 1,NVL(MSC_ATP_PVT.G_ATP_DEMAND_CLASS,'-1'), null),
            -- decode(MSC_ATP_PVT.G_HIERARCHY_PROFILE, 1,MSC_ATP_PVT.G_ATP_DEMAND_CLASS, null),
            NVL(MSC_ATP_PVT.G_PARTNER_ID,-1),           -- Bug 3558125
            NVL(MSC_ATP_PVT.G_PARTNER_SITE_ID,-1),      -- Bug 3558125
            p_supply_rec_type.record_source, -- for plan order pegging
            p_supply_rec_type.refresh_number, -- for summary enhancement
            -- ship_rec_cal changes begin
            -- Bug 3821358, Making the dates at the end of the day.
            TRUNC(p_supply_rec_type.new_dock_date) + MSC_ATP_PVT.G_END_OF_DAY,
            TRUNC(p_supply_rec_type.new_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
            TRUNC(p_supply_rec_type.start_date) + MSC_ATP_PVT.G_END_OF_DAY,       -- Bug 3241766
            TRUNC(p_supply_rec_type.order_date) + MSC_ATP_PVT.G_END_OF_DAY,       -- Bug 3241766
            p_supply_rec_type.shipping_cal_code,
            p_supply_rec_type.receiving_cal_code,
            p_supply_rec_type.intransit_cal_code,
            p_supply_rec_type.ship_method,
            -- ship_rec_cal changes end
            --bug 3766179
            p_supply_rec_type.disposition_id,
            p_supply_rec_type.intransit_lead_time --4127630
            )
    RETURNING transaction_id INTO p_supply_rec_type.transaction_id;

   -- time_phased_atp
   IF (p_supply_rec_type.inventory_item_id <> p_supply_rec_type.request_item_id) AND (p_supply_rec_type.atf_date is not null) THEN
        MSC_ATP_PF.Add_PF_Rollup_Supplies(
                p_supply_rec_type.plan_id,
                p_supply_rec_type.request_item_id,
                p_supply_rec_type.inventory_item_id,
                p_supply_rec_type.organization_id,
                p_supply_rec_type.instance_id,
                p_supply_rec_type.demand_class,
                p_supply_rec_type.schedule_date,
                p_supply_rec_type.supply_type,
                p_supply_rec_type.order_quantity,
                p_supply_rec_type.transaction_id,
                p_supply_rec_type.atf_date,
                p_supply_rec_type.refresh_number,
                p_supply_rec_type.return_status
        );
        IF p_supply_rec_type.return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_Supplies: ' || 'Error occured in procedure Add_PF_Rollup_Supplies');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

   --  Allocated ATP Based on Planning Details -- Agilent changes Begin
   ELSIF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
       (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
       (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
       (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Supplies: ' || ' before insert into' ||
                                ' msc_alloc_supplies');
        END IF;

        INSERT INTO MSC_ALLOC_SUPPLIES(
                PLAN_ID,
                INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                SR_INSTANCE_ID,
                DEMAND_CLASS,
                SUPPLY_DATE,
                PARENT_TRANSACTION_ID,
                ALLOCATED_QUANTITY,
                ORDER_TYPE,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                REFRESH_NUMBER
               )
        VALUES (
                p_supply_rec_type.plan_id,
                l_insert_item_id,
                p_supply_rec_type.organization_id,
                p_supply_rec_type.instance_id,
                p_supply_rec_type.demand_class,
                p_supply_rec_type.schedule_date,
                p_supply_rec_type.transaction_id,
                p_supply_rec_type.order_quantity,
                p_supply_rec_type.supply_type,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                p_supply_rec_type.refresh_number); -- for summary enhancement
    END IF;

    --  Allocated ATP Based on Planning Details -- Agilent changes End

    -- Code to make summary updates and commit removed for summary enhancement
    /** code commented for time being. Will be removed after code review
    IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'Create planned orders for summary mode');
            msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'First try to update ');
        END IF;

        MSC_ATP_PROC.SHOW_SUMMARY_QUANTITY(p_supply_rec_type.instance_id,
                                          p_supply_rec_type.plan_id,
                                          p_supply_rec_type.organization_id,
                                          p_supply_rec_type.inventory_item_id,
                                          p_supply_rec_type.schedule_date,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          2);

        update /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) *//* msc_atp_summary_sd
        set sd_qty = sd_qty + p_supply_rec_type.order_quantity
        where inventory_item_id =  p_supply_rec_type.inventory_item_id
        and   plan_id = p_supply_rec_type.plan_id
        and   sr_instance_id = p_supply_rec_type.instance_id
        and   organization_id = p_supply_rec_type.organization_id
        and   sd_date = trunc(p_supply_rec_type.schedule_date);
        commit;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'After update  to summary table');
        END IF;
        IF SQL%NOTFOUND THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'Couldnt update try to insert');
            END IF;

            MSC_ATP_DB_UTILS.INSERT_SUMMARY_SD_ROW(p_supply_rec_type.plan_id,
                                               p_supply_rec_type.instance_id,
                                               p_supply_rec_type.organization_id,
                                               p_supply_rec_type.inventory_item_id,
                                               p_supply_rec_type.schedule_date,
                                               p_supply_rec_type.order_quantity,
                                               '@@@');
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_Planned_Order: ' || 'commit in summary mode');
        END IF;
        commit;
    END IF;
    ***/

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Supplies: ' || 'transaction_id = '||p_supply_rec_type.transaction_id);
        msc_sch_wb.atp_debug('***** End Add_Supplies Procedure *****');
    END IF;

END Add_Supplies;


--3720018, new procedure to call delete row for line/set/request level.
Procedure call_delete_row (
p_instance_id              IN    NUMBER,
p_atp_table                IN    MRP_ATP_PUB.ATP_Rec_Typ,
p_refresh_number           IN    NUMBER,
x_delete_atp_rec           OUT   NoCopy MSC_ATP_PVT.DELETE_ATP_REC,
x_return_status      	   OUT   NoCopy VARCHAR2
) IS
i                                 PLS_INTEGER := 1;
m			          PLS_INTEGER := 1;
l_count                           NUMBER;
l_line_id_count                   NUMBER;
l_so_tbl_status                   PLS_INTEGER;
l_summary_flag                    number;
l_old_plan_id                     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atf_dates                       MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
l_old_pf_item_id                  number;
l_pf_item_id		          MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_plan_id                         NUMBER := -1;
l_return_status		          VARCHAR2(10);
l_temp_assign_set_id              NUMBER;
l_time_phased_atp                 VARCHAR2(1) := 'N';
l_time_phased_set                 VARCHAR2(1) := 'N';
l_demand_ids                      MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_inv_item_ids                    MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_plan_info_rec                   MSC_ATP_PVT.plan_info_rec;
l_del_demand_ids                  MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_del_inv_item_ids                MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_del_plan_ids                    MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_del_identifiers                 MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_del_demand_source_type          MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();--cmro
l_delete_demand_flag              PLS_INTEGER;
l_copy_demand_ids                 mrp_atp_pub.number_arr := mrp_atp_pub.number_arr();
l_del_copy_demand_ids             mrp_atp_pub.number_arr := mrp_atp_pub.number_arr();
l_del_copy_demand_plan_ids        mrp_atp_pub.number_arr := mrp_atp_pub.number_arr();
l_atp_peg_items                   MRP_ATP_PUB.Number_Arr ;
l_atp_peg_demands                 MRP_ATP_PUB.Number_Arr ;
l_atp_peg_supplies                MRP_ATP_PUB.Number_Arr ;
l_atp_peg_res_reqs                MRP_ATP_PUB.Number_Arr ;
l_demand_instance_id              MRP_ATP_PUB.Number_Arr ; --Bug 3629191
l_supply_instance_id              MRP_ATP_PUB.Number_Arr ; --Bug 3629191
l_res_instance_id                 MRP_ATP_PUB.Number_Arr ; --Bug 3629191
l_del_atp_peg_items               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_del_atp_peg_demands             MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_del_atp_peg_supplies            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_del_atp_peg_res_reqs            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_atp_peg_demands_plan_ids        MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --Bug 3629191
l_atp_peg_supplies_plan_ids       MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --Bug 3629191
l_atp_peg_res_reqs_plan_ids       MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --Bug 3629191
l_off_demand_instance_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --Bug 3629191
l_off_supply_instance_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --Bug 3629191
l_off_res_instance_id             MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --Bug 3629191
l_del_ods_demand_ids              MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_del_ods_inv_item_ids            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_del_ods_demand_src_type         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_ods_cto_demand_ids              MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_ods_cto_inv_item_ids            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_del_ods_cto_demand_ids          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_del_ods_cto_inv_item_ids        MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_del_ods_cto_dem_src_type        MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); --3720018, added for support of rescheduling in ODS
l_ods_atp_refresh_no          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_ods_cto_atp_refresh_no          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_del_ods_atp_refresh_no          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_del_ods_cto_atp_refresh_no          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_delete_atp_rec                  MSC_ATP_PVT.DELETE_ATP_REC;
l_attribute_07                    MRP_ATP_PUB.char30_Arr := MRP_ATP_PUB.char30_Arr();

BEGIN
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('*** Begin Call_delete_row ***');
       END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       l_demand_ids.Extend(p_atp_table.action.count);
       l_inv_item_ids.extend(p_atp_table.action.count);
       x_delete_atp_rec.error_code.extend(p_atp_table.action.count);

       SELECT so_tbl_status,
                NVL(summary_flag,1)
       INTO   l_so_tbl_status,
                l_summary_flag
       FROM   msc_apps_instances
       WHERE  instance_id = p_instance_id;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_delete_row: ' || 'l_so_tbl_status = '||l_so_tbl_status);
          msc_sch_wb.atp_debug('Call_delete_row: ' || 'l_summary_flag = ' || l_summary_flag);
       END IF;
       IF NVL(l_so_tbl_status, 1) = 2 THEN
            -- not available for atp
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_delete_row: ' || 'ATP not available');
          END IF;
          x_delete_atp_rec.error_code(1) := MSC_ATP_PVT.TRY_ATP_LATER;
          RETURN;

       ELSIF l_summary_flag = 1 THEN
              ---- summary table is not ready. Switch to detail tables
          IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Call_delete_row: ' || ' summary table is not ready. Switch to detail tables');
          END IF;
          MSC_ATP_PVT.G_SUMMARY_FLAG := 'N';

       ELSIF l_summary_flag = 2 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Call_delete_row: ' || 'Summary Concurrent program is running');
            END IF;
            x_delete_atp_rec.error_code(1) := MSC_ATP_PVT.SUMM_CONC_PROG_RUNNING;
            RETURN;
       END IF;

       IF (p_atp_table.Action.COUNT > 0 ) THEN
          -- ship set or arrival set exists
           l_old_plan_id.Extend(p_atp_table.action.count);
           l_atf_dates.extend(p_atp_table.action.count); -- for time_phased_atp
           l_attribute_07.extend(p_atp_table.action.count);

           FOR m in 1.. p_atp_table.Action.COUNT LOOP
	      ---l_old_plan_id.Extend;
              -- we need to get the plan_id based on old org and old demand
              -- class
              --IF MSC_ATP_PVT.G_INV_CTP = 4 THEN  --anuarg
              IF p_atp_table.old_source_organization_id(m) IS NOT NULL THEN -- we want to find plan only in case
                                                                              -- of reschedulling
                   ----Subst: Get pf id for old inv item if
                 IF NVL(p_atp_table.old_inventory_item_id(m), p_atp_table.inventory_item_id(m))
                                                                  = p_atp_table.inventory_item_id(m) THEN
                    l_old_pf_item_id := MSC_ATP_PF.Get_PF_Atp_Item_Id(p_instance_id,
                                            l_plan_id,
                                            p_atp_table.inventory_item_id(m),
                                            p_atp_table.old_source_organization_id(m));
                 ELSE
                      l_old_pf_item_id :=  MSC_ATP_PF.Get_PF_Atp_Item_Id(p_instance_id,
                                                           l_plan_id,
                                                           p_atp_table.old_inventory_item_id(m),
                                                           p_atp_table.old_source_organization_id(m));
                 END IF;
                 IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Call_delete_row: ' || 'l_old_pf_item_id := ' || l_old_pf_item_id);
                 END IF;
              END IF;
              IF MSC_ATP_PVT.G_INV_CTP = 4 THEN  --3720018, moved from above
                   /* time_phased_atp changes begin
                      Call new procedure Get_PF_Plan_Info*/
                IF p_atp_table.old_source_organization_id(m) IS NOT NULL THEN
                   MSC_ATP_PF.Get_PF_Plan_Info(
                               p_instance_id,
                               NVL(p_atp_table.old_inventory_item_id(m), p_atp_table.inventory_item_id(m)),
                               l_old_pf_item_id,
                               p_atp_table.old_source_organization_id(m),
                               p_atp_table.old_demand_class(m),
                               l_atf_dates(m),
                               x_delete_atp_rec.error_code(m), -- l_atp_table.error_code(m), --3720018
                               l_return_status,
                               NULL --bug3510475
                   );

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Call_delete_row: l_return_status:= ' || l_return_status);
                   END IF;

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('Call_delete_row: ' || 'ATP Downtime during Re-schedule');
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      return; -- Return in case of error in get_pf_plan_info, no point in proceding further.
                   END IF;
                   /* time_phased_atp changes end*/
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Call_delete_row: ' || 'reached here2');
                   END IF;

                   l_plan_info_rec := MSC_ATP_PVT.G_PLAN_INFO_REC;

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Call_delete_row: ' || 'l_plan_info_rec.plan_id = '||l_plan_info_rec.plan_id);
                   END IF;

                   l_old_plan_id(m)            := l_plan_info_rec.plan_id;
                   l_temp_assign_set_id        := l_plan_info_rec.assignment_set_id;

                   --3720018
                   IF l_attribute_07.Exists(m) THEN
                      l_attribute_07(m) := l_plan_info_rec.plan_name;
                   END IF; --3720018

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Call_delete_row: ' || 'old_source_organization_id = '|| p_atp_table.old_source_organization_id(m));
                      msc_sch_wb.atp_debug('Call_delete_row: ' || 'old_demand_class = '|| p_atp_table.old_demand_class(m));
                   END IF;
                END IF;
              ELSE
                 IF p_atp_table.old_source_organization_id(m) IS NOT NULL THEN
                     l_old_plan_id(m) := l_plan_id;
                 END IF;
              END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Call_delete_row: ' || 'l_old_plan_id = '||l_old_plan_id(m));
              END IF;

              -- 2152184: We remove rows only if we have old plan id
              IF l_old_plan_id(m) IS NOT NULL THEN
                 ---subst: add demand field
                 ---bug 2384224: delete demand only if it has not been deleted
                 l_delete_demand_flag := 1;
                 --IF MSC_ATP_PVT.G_INV_CTP = 4 THEN  --3720018, removed this condition
                    -- Chagned the following loop
                    --FOR i in 1..l_del_demand_ids.count LOOP
                    --    IF p_atp_table.Identifier(m) = l_del_identifiers(i) and l_old_plan_id(m) = l_del_plan_ids(i) THEN
                    --        IF PG_DEBUG in ('Y', 'C') THEN
                    --           msc_sch_wb.atp_debug('Call_delete_row: ' || 'demand has already been deleted');
                    --        END IF;
                    --        l_delete_demand_flag := 0;
                    --        EXIT;
                    --    END IF;
                    --END LOOP;
                    -- l_del_demand_ids.count might not be in sync with
                    -- l_del_identifiers.count
                    FOR i in 1..l_del_identifiers.count LOOP
                        IF p_atp_table.Identifier(m) = l_del_identifiers(i) THEN
                          FOR i in 1..l_del_demand_ids.count LOOP
                            IF  l_old_plan_id(m) = l_del_plan_ids(i) THEN
                              IF PG_DEBUG in ('Y', 'C') THEN
                               msc_sch_wb.atp_debug('Call_delete_row: ' || 'demand has already been deleted');
                              END IF;
                              l_delete_demand_flag := 0;
                              EXIT;
                            END IF;
                          END LOOP;
                          IF l_delete_demand_flag = 0 THEN
                            EXIT;
                          END IF;
                        END IF;
                    END LOOP;
                 --END IF;  --3720018
                 IF (MSC_ATP_PVT.G_INV_CTP = 5) or  (MSC_ATP_PVT.G_INV_CTP = 4 and l_delete_demand_flag = 1) THEN
                    /* time_phased_atp */
                    IF l_atf_dates(m) is not null THEN
                        l_time_phased_atp := 'Y';
                    END IF;

                    IF l_time_phased_set <> 'Y' and l_time_phased_atp = 'Y' THEN
                       l_time_phased_set := 'Y';
                    END IF;

                    MSC_ATP_DB_UTILS.Delete_Row(
                       -- CTO re-arch Changes to deal with "across-plan" cases
                       p_atp_table.Identifier(m),
                       p_atp_table.Config_item_line_id(m),
                       -- CTO re-arch
                       l_old_plan_id(m),
                       p_instance_id,
                       p_refresh_number, -- Bug 2831298 Ensure that the refresh_number is updated.
                       p_atp_table.order_number(m), -- Bug 2840734 : populate numeric order no.
                       l_time_phased_atp,  -- For time_phased_atp
                       p_atp_table.ato_model_line_id(m),
                       --subst
                       p_atp_table.demand_source_type(m), --cmro
                       p_atp_table.old_source_organization_id(m), --bug#9055675 --Bug 7118988
                       l_demand_ids,
                       l_inv_item_ids,
                       l_copy_demand_ids,  -- For summary enhancement
                       l_atp_peg_items  ,
                       l_atp_peg_demands ,
                       l_atp_peg_supplies,
                       l_atp_peg_res_reqs,
                       l_demand_instance_id, --Bug 3629191
                       l_supply_instance_id, --Bug 3629191
                       l_res_instance_id,    --Bug 3629191
                       l_ods_cto_demand_ids,  --3720018, added for support of rescheduling in ODS
                       l_ods_cto_inv_item_ids, --3720018, added for support of rescheduling in ODS
                       l_ods_atp_refresh_no,
                       l_ods_cto_atp_refresh_no
                       -- End CTO ODR and Simplified Pegging
                       );
                       --l_demand_class_flag);

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Call_delete_row: After call to Delete_Row' );
                    END IF;

                    --IF MSC_ATP_PVT.G_INV_CTP = 4  and l_old_plan_id(m) <> -1 THEN  --3720018
                    IF (l_old_plan_id(m) = -1) THEN
                           IF l_demand_ids IS NOT NULL and l_demand_ids.count > 0 THEN
                              l_count := l_del_ods_demand_ids.count;
                              l_del_ods_demand_ids.extend(l_demand_ids.count);
                              l_del_ods_inv_item_ids.extend(l_demand_ids.count);
                              l_del_ods_demand_src_type.extend(l_demand_ids.count);
                              l_del_ods_atp_refresh_no.extend(l_demand_ids.count);
                              --l_del_identifiers.extend(l_demand_ids.count);
                              FOR i in 1..l_demand_ids.count LOOP
                                  l_del_ods_demand_ids(l_count + i) := l_demand_ids(i);
                                  l_del_ods_inv_item_ids(l_count + i) := l_inv_item_ids(i);
                                  l_del_ods_demand_src_type(l_count + i):= p_atp_table.demand_source_type(m);
                                  l_del_ods_atp_refresh_no(l_count + i) := l_ods_atp_refresh_no(i);
                              END LOOP;
                           END IF;
                           IF l_ods_cto_demand_ids IS NOT NULL and l_ods_cto_demand_ids.count > 0 THEN
                                 l_count := l_del_ods_cto_demand_ids.count;
                                 l_del_ods_cto_demand_ids.extend(l_ods_cto_demand_ids.count);
                                 l_del_ods_cto_inv_item_ids.extend(l_ods_cto_demand_ids.count);
                                 l_del_ods_cto_dem_src_type.extend(l_ods_cto_demand_ids.count);
                                 l_del_ods_cto_atp_refresh_no.extend(l_ods_cto_demand_ids.count);
                                 FOR i in 1..l_ods_cto_demand_ids.count LOOP
                                     l_del_ods_cto_demand_ids(l_count + i) := l_ods_cto_demand_ids(i);
                                     l_del_ods_cto_inv_item_ids(l_count + i) := l_ods_cto_inv_item_ids(i);
                                     l_del_ods_cto_dem_src_type(l_count + i) := p_atp_table.demand_source_type(m);
                                     l_del_ods_cto_atp_refresh_no(l_count + i) := l_ods_cto_atp_refresh_no(i);
                                 END LOOP;
                           END IF;
                           --5357370
                           IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' THEN
                              l_del_identifiers.extend(p_atp_table.Identifier.count);
                              l_del_identifiers := p_atp_table.Identifier;
                           END IF;

                    ELSE
                           l_count := l_del_demand_ids.count;
                           l_del_demand_ids.extend(l_demand_ids.count);
                           l_del_plan_ids.extend(l_demand_ids.count);
                           l_del_inv_item_ids.extend(l_demand_ids.count);
                           --l_del_identifiers.extend(l_demand_ids.count);
                           FOR i in 1..l_demand_ids.count LOOP
                                  l_del_demand_ids(l_count + i) := l_demand_ids(i);
                                  l_del_plan_ids(l_count + i) := l_old_plan_id(m);
                                  l_del_inv_item_ids(l_count + i) := l_inv_item_ids(i);
                           END LOOP;
                           l_line_id_count := l_del_identifiers.count;
                           FOR i in 1..l_demand_ids.count LOOP
                               l_line_id_count := l_line_id_count + 1;
                               l_del_identifiers.extend();
                               l_del_demand_source_type.extend();--cmro
                               l_del_identifiers(l_line_id_count) := p_atp_table.Identifier(m);
                               l_del_demand_source_type(l_line_id_count):=p_atp_table.demand_source_type(m);--cmro
                               IF p_atp_table.Config_item_line_id(m) IS NOT NULL THEN
                                  l_line_id_count := l_line_id_count + 1;
                                  l_del_identifiers.extend();
                                  l_del_demand_source_type.extend();--cmro
                                  l_del_identifiers(l_line_id_count) :=
                                             p_atp_table.Config_item_line_id(m);
                                  l_del_demand_source_type(l_line_id_count):=
                                             p_atp_table.demand_source_type(m);--cmro
                               END IF;
                           END LOOP;

                           -- Append copy SO ids for summary enhancement
                           IF l_copy_demand_ids IS NOT NULL and l_copy_demand_ids.COUNT > 0 THEN
                               l_count := l_del_copy_demand_ids.count;
                               l_del_copy_demand_ids.extend(l_copy_demand_ids.count);
                               l_del_copy_demand_plan_ids.extend(l_copy_demand_ids.count);
                               FOR i in 1..l_copy_demand_ids.count LOOP
                                   l_del_copy_demand_ids(l_count + i) := l_copy_demand_ids(i);
                                   l_del_copy_demand_plan_ids(l_count + i) := l_old_plan_id(m);
                               END LOOP;
                           END IF;
                           -- CTO ODR and Simplified Pegging

                           -- This check not necessary but used as an insurance.
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('Call_delete_row: l_atp_peg_items.count ' || l_atp_peg_items.count);
                           END IF;
                           IF l_atp_peg_items IS NOT NULL AND l_atp_peg_items.count > 0 THEN
                             l_count := l_atp_peg_items.count;
                             l_del_atp_peg_items.extend(l_count);
                             l_count := l_del_atp_peg_items.count - l_atp_peg_items.count;
                             FOR i in 1..l_atp_peg_items.count LOOP
                               l_del_atp_peg_items(l_count + i) := l_atp_peg_items(i);
                             END LOOP;
                           END IF;
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('Call_delete_row: l_atp_peg_demands.count ' || l_atp_peg_demands.count);
                           END IF;
                           IF l_atp_peg_demands IS NOT NULL AND l_atp_peg_demands.count > 0 THEN
                             l_count := l_atp_peg_demands.count;
                             l_del_atp_peg_demands.extend(l_count);
                             l_atp_peg_demands_plan_ids.extend(l_count);
                             l_off_demand_instance_id.extend(l_count);
                             l_count := l_del_atp_peg_demands.count - l_atp_peg_demands.count;
                             FOR i in 1..l_atp_peg_demands.count LOOP
                                 l_del_atp_peg_demands(l_count + i) := l_atp_peg_demands(i);
                                 l_atp_peg_demands_plan_ids(l_count + i) := l_old_plan_id(m); --Bug 3629191
                                 l_off_demand_instance_id(l_count + i) := l_demand_instance_id(i); --Bug 3629191
                             END LOOP;
                           END IF;
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('Call_delete_row: l_atp_peg_supplies.count ' || l_atp_peg_supplies.count);
                           END IF;
                           IF l_atp_peg_supplies IS NOT NULL AND l_atp_peg_supplies.count > 0 THEN
                             l_count := l_atp_peg_supplies.count;
                             l_del_atp_peg_supplies.extend(l_count);
                             l_atp_peg_supplies_plan_ids.extend(l_count);
                             l_off_supply_instance_id.extend(l_count);
                             l_count := l_del_atp_peg_supplies.count - l_atp_peg_supplies.count;
                             FOR i in 1..l_atp_peg_supplies.count LOOP
                               l_del_atp_peg_supplies(l_count + i) := l_atp_peg_supplies(i);
                               l_atp_peg_supplies_plan_ids(l_count + i) := l_old_plan_id(m); --Bug 3629191
                               l_off_supply_instance_id(l_count + i) := l_supply_instance_id(i); --Bug 3629191
                             END LOOP;
                           END IF;
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('Call_delete_row: l_atp_peg_res_reqs.count ' || l_atp_peg_res_reqs.count);
                           END IF;
                           IF l_atp_peg_res_reqs IS NOT NULL AND l_atp_peg_res_reqs.count > 0 THEN
                             l_count := l_atp_peg_res_reqs.count;
                             l_del_atp_peg_res_reqs.extend(l_count);
                             l_atp_peg_res_reqs_plan_ids.extend(l_count);
                             l_off_res_instance_id.extend(l_count);
                             l_count := l_del_atp_peg_res_reqs.count - l_atp_peg_res_reqs.count;
                             FOR i in 1..l_atp_peg_res_reqs.count LOOP
                               l_del_atp_peg_res_reqs(l_count + i) := l_atp_peg_res_reqs(i);
                               l_atp_peg_res_reqs_plan_ids(l_count + i) := l_old_plan_id(m); --Bug 3629191
                               l_off_res_instance_id(l_count + i) := l_res_instance_id(i); --Bug 3629191
                             END LOOP;
                           END IF;
                           -- END CTO ODR and Simplified Pegging
                    END IF; --3720018
                 END IF; --- IF (MSC_ATP_PVT.G_INV_CTP = 5) or  (MSC_ATP_PVT.G_INV_CTP = 4 and l_delete_demand_flag = 1)
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Call_delete_row: ' || 'Count of records := ' || l_del_demand_ids.count);
              END IF;
              --l_atp_table.Error_Code(m) := 0;
              x_delete_atp_rec.error_code(m) := 0;

              /* time_phased_atp - Reset the variable */
              l_time_phased_atp := 'N';

           END LOOP;

           x_delete_atp_rec.time_phased_set           :=       l_time_phased_set;
           x_delete_atp_rec.attribute_07              :=       l_attribute_07 ;
           x_delete_atp_rec.old_plan_id               :=       l_old_plan_id ;
           x_delete_atp_rec.del_demand_ids            :=       l_del_demand_ids;
           x_delete_atp_rec.del_inv_item_ids          :=       l_del_inv_item_ids;
           x_delete_atp_rec.del_plan_ids              :=       l_del_plan_ids;
           x_delete_atp_rec.del_identifiers           :=       l_del_identifiers;
           x_delete_atp_rec.del_demand_source_type    :=       l_del_demand_source_type;
           x_delete_atp_rec.del_copy_demand_ids       :=       l_del_copy_demand_ids;
           x_delete_atp_rec.del_copy_demand_plan_ids  :=       l_del_copy_demand_plan_ids;
           x_delete_atp_rec.del_atp_peg_items         :=       l_del_atp_peg_items;
           x_delete_atp_rec.del_atp_peg_demands       :=       l_del_atp_peg_demands;
           x_delete_atp_rec.del_atp_peg_supplies      :=       l_del_atp_peg_supplies;
           x_delete_atp_rec.del_atp_peg_res_reqs      :=       l_del_atp_peg_res_reqs;
           x_delete_atp_rec.atp_peg_demands_plan_ids  :=       l_atp_peg_demands_plan_ids;
           x_delete_atp_rec.atp_peg_supplies_plan_ids :=       l_atp_peg_supplies_plan_ids;
           x_delete_atp_rec.atp_peg_res_reqs_plan_ids :=       l_atp_peg_res_reqs_plan_ids ;
           x_delete_atp_rec.off_demand_instance_id    :=       l_off_demand_instance_id ;
           x_delete_atp_rec.off_supply_instance_id    :=       l_off_supply_instance_id ;
           x_delete_atp_rec.off_res_instance_id       :=       l_off_res_instance_id  ;
           x_delete_atp_rec.del_ods_demand_ids        :=       l_del_ods_demand_ids;         --3720018, added for support of rescheduling in ODS
           x_delete_atp_rec.del_ods_inv_item_ids      :=       l_del_ods_inv_item_ids;       --3720018, added for support of rescheduling in ODS
           x_delete_atp_rec.del_ods_demand_src_type   :=       l_del_ods_demand_src_type;    --3720018, added for support of rescheduling in ODS
           x_delete_atp_rec.del_ods_cto_demand_ids    :=       l_del_ods_cto_demand_ids;     --3720018, added for support of rescheduling in ODS
           x_delete_atp_rec.del_ods_cto_inv_item_ids  :=       l_del_ods_cto_inv_item_ids;   --3720018, added for support of rescheduling in ODS
           x_delete_atp_rec.del_ods_cto_dem_src_type  :=       l_del_ods_cto_dem_src_type;   --3720018, added for support of rescheduling in ODS
           x_delete_atp_rec.del_ods_atp_refresh_no    :=       l_del_ods_atp_refresh_no;
           x_delete_atp_rec.del_ods_cto_atp_refresh_no    :=       l_del_ods_cto_atp_refresh_no;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('*** END Call_delete_row ***');
       END IF;

END call_delete_row;
--5357370 starts
PROCEDURE UNDO_DELETE_SUMMARY_ROW (p_identifier                      IN NUMBER,
                              p_instance_id                     IN NUMBER,
                              p_demand_source_type              IN NUMBER)

IS
l_instance_id MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_organization_id MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_inventory_item_id MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_demand_class MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
l_sd_date MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
l_sd_qty  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
i  number;
-- 5357370 changes, need user id/sysdate for insert/update
l_user_id number;
l_sysdate date;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'Inside delete summary row');
           msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'p_identifier := ' || p_identifier);
           msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'p_instance_id := ' || p_instance_id);
        END IF;
        BEGIN
	   SELECT D.sr_instance_id,
      	   D.organization_id,
           D.inventory_item_id,
           Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 , NVL(D.DEMAND_CLASS, '@@@'), '@@@'),
           /*In case of reserved quantity check move to next working day*/
           DECODE(D.RESERVATION_TYPE,2,C2.next_date, trunc(D.REQUIREMENT_DATE)) SD_DATE, --5148349
           --D.REQUIREMENT_DATE SD_DATE, --5148349
           (D.PRIMARY_UOM_QUANTITY-GREATEST(NVL(D.RESERVATION_QUANTITY,0),
              D.COMPLETED_QUANTITY)) sd_qty
           BULK COLLECT INTO l_instance_id, l_organization_id, l_inventory_item_id, l_demand_class, l_sd_date, l_sd_qty
           FROM
           MSC_SALES_ORDERS D,
           MSC_ATP_RULES R,
           MSC_SYSTEM_ITEMS I,
           MSC_TRADING_PARTNERS P,
           msc_calendar_dates C,
           MSC_CALENDAR_DATES C2
           WHERE       D.DEMAND_SOURCE_LINE = TO_CHAR(P_IDENTIFIER)
           AND     decode(demand_source_type,100,demand_source_type,-1)
                            =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
           AND         D.SR_INSTANCE_ID = p_instance_id
           AND         I.ORGANIZATION_ID = D.ORGANIZATION_ID
    	   AND         I.SR_INSTANCE_ID = D.SR_INSTANCE_ID
           AND         D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    	   AND         I.PLAN_ID = -1
           AND         P.SR_TP_ID = I.ORGANIZATION_ID
           AND         P.SR_INSTANCE_ID = I.SR_INSTANCE_ID
           AND         P.PARTNER_TYPE = 3
    	   AND         R.RULE_ID  = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    	   AND         R.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    	   AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
    	   AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
    	   AND         D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
            		                 D.COMPLETED_QUANTITY)
    	   AND         (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                		      (SELECT S.SUB_INVENTORY_CODE
                    		      FROM   MSC_SUB_INVENTORIES S
                    		      WHERE  S.ORGANIZATION_ID=D.ORGANIZATION_ID
                    		      AND    S.PLAN_ID = I.PLAN_ID
                    		      AND    S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                    		      AND    S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                               		          1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                    		      AND    S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                               		          2, 1, S.NETTING_TYPE)))
    				      AND         (D.RESERVATION_TYPE = 2
                 		      OR D.PARENT_DEMAND_ID IS NULL
                 		      OR (D.RESERVATION_TYPE = 3 AND
                     			      ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                      			      (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
           AND C.PRIOR_SEQ_NUM >=
                		      DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                        	      NULL, C.PRIOR_SEQ_NUM,
          			      C2.next_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
    	  AND     C.CALENDAR_CODE = P.CALENDAR_CODE
    	  AND     C.SR_INSTANCE_ID = p_instance_id
    	  AND     C.EXCEPTION_SET_ID = -1
    	  AND     C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
    	  AND     C2.CALENDAR_CODE = P.calendar_code
	  AND     C2.EXCEPTION_SET_ID = P.calendar_exception_set_id
	  AND     C2.SR_INSTANCE_ID = P.SR_INSTANCE_ID
	  AND     C2.CALENDAR_DATE = TRUNC(sysdate);
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'No row found that need to be deleted from summary table');
                END IF;
	END;
        -- 5357370: need user id for insert
        l_user_id  := FND_GLOBAL.USER_ID;
        l_sysdate := sysdate;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_inventory_item_id.count := ' || l_inventory_item_id.count);
           msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_user_id := '|| l_user_id);
           msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_sysdate := '|| l_sysdate);

        END IF;
        FOR i in 1..l_inventory_item_id.count LOOP
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'Row found, delete it from summary');
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_ivnevtory_item_id := ' || l_inventory_item_id(i));
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_organization_id := ' || l_organization_id(i) );
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_demand_class := ' || l_demand_class(i));
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_sd_date := ' || l_sd_date(i));
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_sd_qty := ' || l_sd_qty(i));
                   msc_sch_wb.atp_debug('UNDO_DELETE_SUMMARY_ROW: ' || 'l_instance_id := ' || l_instance_id(i));
                END IF;

                update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                set sd_qty = (sd_qty + l_sd_qty(i))
                where inventory_item_id = l_inventory_item_id(i)
                and sr_instance_id = l_instance_id(i)
                and organization_id = l_organization_id(i)
                and sd_date = trunc(l_sd_date(i))
                and demand_class = l_demand_class(i) ;

                -- 5357370: this is to handle that we have reservation on the past due date, and
                -- we won't be able to find record on sysdate to update.
                IF (SQL%NOTFOUND) THEN
                  msc_sch_wb.atp_debug('DELETE_SUMMARY_ROW: update failed, now try insert');
                  --- Insert the new record
                  BEGIN
                    INSERT INTO MSC_ATP_SUMMARY_SO
                            (plan_id,
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
                    VALUES ( -1,
                             l_instance_id(i),
                             l_organization_id(i),
                             l_inventory_item_id(i),
                             l_demand_class(i),
                             trunc(l_sd_date(i)),
                             l_sd_qty(i),
                             l_sysdate,
                             l_user_id ,
                             l_sysdate,
                             l_user_id
                           );
                  EXCEPTION
                  -- If a record has already been inserted by another process
                  -- If insert fails then update.
                    WHEN DUP_VAL_ON_INDEX THEN
                      -- Update the record.
                      update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                      set sd_qty = (sd_qty + l_sd_qty(i)),
                          last_update_date = l_sysdate,
                          last_updated_by = l_user_id
                      where inventory_item_id = l_inventory_item_id(i)
                      and sr_instance_id = l_instance_id(i)
                      and organization_id = l_organization_id(i)
                      and sd_date = trunc(l_sd_date(i))
                      and demand_class = l_demand_class(i) ;

                  END;
                END IF;
                -- 5357370: end of changes to handle the update failure.

                commit;

        END LOOP;

END UNDO_DELETE_SUMMARY_ROW;
--5357370 ends

--optional_fw

/*--Hide_SD_Rec-------------------------------------------------
|  o  This procedure is called from Schedule to hide the
|       demands/supplies for particular call of ATP_CHECK
+---------------------------------------------------------------*/
PROCEDURE Hide_SD_Rec(
        p_identifier          IN      NUMBER,
        x_return_status       OUT     NoCopy VARCHAR2
)
IS

    CURSOR pegging IS
        select  pegging_id, identifier3, identifier2, identifier1,
                supply_demand_type, inventory_item_id, char1, organization_id, supply_demand_date,
                supply_demand_quantity, department_id, resource_id, order_line_id, supplier_id, supplier_site_id,
                supplier_atp_date, dest_inv_item_id, summary_flag
                , aggregate_time_fence_date
        from    mrp_atp_details_temp
        where   record_type in (3,4)
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        start with pegging_id = p_identifier
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        and     record_type = 3
        connect by parent_pegging_id = prior pegging_id
        AND     session_id = prior session_id
        AND     record_type in (3,4);

    c1 pegging%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Hide_SD_Rec Procedure *****');
        msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'Reset all the global variables ');
        msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'p_identifier= ' || p_identifier);
    END IF;

    -- for ods, just need to remove the record from msc_sales_orders
    -- initialize API return status to success
    x_return_status                 := FND_API.G_RET_STS_SUCCESS;
    MSC_ATP_PVT.G_ALLOCATION_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'),2);
    MSC_ATP_PVT.G_ALLOCATED_ATP     := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
    MSC_ATP_PVT.G_INV_CTP           := FND_PROFILE.value('INV_CTP') ;

    OPEN pegging;
    LOOP

        FETCH pegging INTO c1;
        EXIT WHEN pegging%NOTFOUND;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'pegging_id = '                 || c1.pegging_id);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'identifier3 = '                || c1.identifier3);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'identifier1 = '                || c1.identifier1);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'plan_id (identifier2) = '      || c1.identifier2);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'supply_demand_type = '         || c1.supply_demand_type);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'inventory_item_id := '         || c1.inventory_item_id);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'char1 := '                     || c1.char1);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'resource_id := '               || c1.resource_id);
            msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'aggregate_time_fence_date := ' || c1.aggregate_time_fence_date);
        END IF;

        IF c1.supply_demand_type = 2 THEN --This is supply line
            IF NVL(c1.inventory_item_id, -1) > 0 THEN
                -- Hide the planned order that we may have enterred.
                UPDATE MSC_SUPPLIES
                SET   inventory_item_id = -1*inventory_item_id
                WHERE transaction_id = c1.identifier3
                AND   plan_id = c1.identifier2
                AND   inventory_item_id > 0;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'No. of supply updated from msc_supplies = '|| SQL%ROWCOUNT);
                END IF;

                -- time_phased_atp or demand priority AATP
                IF (c1.aggregate_time_fence_date is not null)
                   OR
                   ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Hide_SD_Rec: before update of msc_alloc_supplies');
                    END IF;

                    UPDATE MSC_ALLOC_SUPPLIES
                    SET   inventory_item_id = -1*inventory_item_id
                    WHERE parent_transaction_id = c1.identifier3
                    AND   plan_id = c1.identifier2
                    AND   inventory_item_id > 0;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'No. of supply updated from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
                IF NVL(c1.char1, '@@@') <> '@@@' THEN

                    UPDATE MSC_DEMANDS
                    SET   inventory_item_id = -1*inventory_item_id
                    WHERE demand_id = c1.identifier3
                    AND   plan_id = c1.identifier2
                    AND   inventory_item_id > 0;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'No. of stealing demand updated from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN
        ELSE    -- IF c1.supply_demand_type = 2 THEN
            -- update the demand records we may have entrered.
            IF NVL(c1.inventory_item_id, -1) > 0 and c1.identifier2 <> -1 THEN

                UPDATE MSC_DEMANDS
                SET   inventory_item_id = -1*inventory_item_id
                WHERE   demand_id = c1.identifier3
                AND     plan_id = c1.identifier2
                AND	    old_demand_quantity IS NULL
                AND     inventory_item_id > 0;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'No. of demand updated from msc_demand = '|| SQL%ROWCOUNT);
                END IF;

                IF (c1.aggregate_time_fence_date is not null)
                   OR
                   ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Hide_SD_Rec: before update of' ||
                            ' msc_alloc_demands');
                    END IF;

                    UPDATE MSC_ALLOC_DEMANDS
                    SET   inventory_item_id = -1*inventory_item_id
                    WHERE parent_demand_id = c1.identifier3
                    AND	  old_allocated_quantity IS NULL
                    AND   plan_id = c1.identifier2
                    AND   inventory_item_id > 0;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'No. of demand updated from msc_alloc_demands = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
            ELSE    -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

                UPDATE MSC_RESOURCE_REQUIREMENTS
                SET   resource_id = -1*resource_id
                WHERE   transaction_id = c1.identifier3
                AND     plan_id = c1.identifier2
                AND   sr_instance_id = c1.identifier1
                AND   resource_id > 0;

                IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'No. of demand deleted from msc_resource_requirements = '|| SQL%ROWCOUNT);
                END IF;

            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN
        END IF; -- IF c1.supply_demand_type = 2 THEN

    END LOOP;
    CLOSE pegging;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** End Hide_SD_Rec Procedure *****');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Hide_SD_Rec: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
END Hide_SD_Rec;

/*--Delete_SD_Rec-----------------------------------------------
|  o  This procedure is called from Schedule to delete the
|       demands/supplies for particular call of ATP_CHECK
|  0  New Procedure needed as inventory item id is -ve.
+---------------------------------------------------------------*/
PROCEDURE Delete_SD_Rec(
        p_pegging_tab           IN      MRP_ATP_PUB.Number_Arr,
        x_return_status       OUT     NoCopy VARCHAR2
)
IS

    CURSOR pegging(p_pegging_id	IN	NUMBER) IS
        select  pegging_id, identifier3, identifier2, identifier1,
                supply_demand_type, inventory_item_id, char1, organization_id, supply_demand_date,
                supply_demand_quantity, department_id, resource_id, order_line_id, supplier_id, supplier_site_id,
                supplier_atp_date, dest_inv_item_id, summary_flag
                , aggregate_time_fence_date,from_organization_id
        from    mrp_atp_details_temp
        where	record_type in (3,4)
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        start with pegging_id = p_pegging_id
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        and     record_type = 3
        connect by parent_pegging_id = prior pegging_id
        AND     session_id = prior session_id
        AND     record_type in (3,4);

    c1 pegging%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Delete_SD_Rec Procedure *****');
    END IF;

    x_return_status                 := FND_API.G_RET_STS_SUCCESS;
    MSC_ATP_PVT.G_ALLOCATION_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'),2);
    MSC_ATP_PVT.G_ALLOCATED_ATP     := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
    MSC_ATP_PVT.G_INV_CTP           := FND_PROFILE.value('INV_CTP') ;

    FOR i IN p_pegging_tab.FIRST..p_pegging_tab.COUNT LOOP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'p_pegging_tab(i) = '              || p_pegging_tab(i));
     END IF;
     OPEN pegging(p_pegging_tab(i));
     LOOP

        FETCH pegging INTO c1;
        EXIT WHEN pegging%NOTFOUND;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'pegging_id = '                 || c1.pegging_id);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'identifier3 = '                || c1.identifier3);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'identifier1 = '                || c1.identifier1);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'plan_id (identifier2) = '      || c1.identifier2);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'supply_demand_type = '         || c1.supply_demand_type);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'inventory_item_id := '         || c1.inventory_item_id);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'char1 := '                     || c1.char1);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'resource_id := '               || c1.resource_id);
            msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'aggregate_time_fence_date := ' || c1.aggregate_time_fence_date);
        END IF;

        MSC_ATP_DB_UTILS.Delete_Pegging(c1.pegging_id);

        IF c1.supply_demand_type = 2 THEN
            IF NVL(c1.inventory_item_id, -1) > 0 THEN

                DELETE FROM MSC_SUPPLIES
                WHERE transaction_id = c1.identifier3
                AND   plan_id = c1.identifier2;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of supply deleted from msc_supplies = '|| SQL%ROWCOUNT);
                END IF;

                -- time_phased_atp
                IF (c1.aggregate_time_fence_date is not null)
                   OR
                   ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    DELETE FROM MSC_ALLOC_SUPPLIES
                    WHERE parent_transaction_id = c1.identifier3
                    AND   plan_id = c1.identifier2;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of supply deleted from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
                IF NVL(c1.char1, '@@@') <> '@@@' THEN

                    DELETE FROM MSC_DEMANDS
                    WHERE demand_id = c1.identifier3
                    AND   plan_id = c1.identifier2;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of stealing demands deleted from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

        ELSE    -- IF c1.supply_demand_type = 2 THEN
            -- delete the demand records we may have entrered.
            IF NVL(c1.inventory_item_id, -1) > 0 and c1.identifier2 <> -1 THEN

               DELETE  FROM MSC_DEMANDS
               WHERE   demand_id = c1.identifier3
               AND     plan_id = c1.identifier2
               AND     old_demand_quantity IS NULL;

               IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of demand deleted from msc_demand = '|| SQL%ROWCOUNT);
               END IF;

               -- time_phased_atp
               IF (c1.aggregate_time_fence_date is not null)
                  OR
                  ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                   (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                   (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                   (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                   DELETE FROM MSC_ALLOC_DEMANDS
                   WHERE parent_demand_id = c1.identifier3
                   AND   old_allocated_quantity IS NULL
                   AND   plan_id = c1.identifier2;

                   IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of demand deleted from msc_alloc_demands = '|| SQL%ROWCOUNT);
                   END IF;
               END IF;

            ELSE    -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

                DELETE  FROM MSC_RESOURCE_REQUIREMENTS
                WHERE   transaction_id = c1.identifier3
                AND     plan_id = c1.identifier2
                AND   sr_instance_id = c1.identifier1;

                IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of demand deleted from msc_resource_requirements = '|| SQL%ROWCOUNT);
                END IF;

            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN
        END IF; -- IF c1.supply_demand_type = 2 THEN

    END LOOP;
    CLOSE pegging;
  END LOOP; --FOR i IN p_pegging_tab.FIRST..p_pegging_tab.COUNT LOOP

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** End Delete_SD_Rec Procedure *****');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
END Delete_SD_Rec;

/*--Restore_SD_Rec-----------------------------------------------
|  o  This procedure is called from Schedule to restore the
|       demands/supplies for particular call of ATP_CHECK
+---------------------------------------------------------------*/
PROCEDURE Restore_SD_Rec(
        p_pegging_tab           IN      MRP_ATP_PUB.Number_Arr,
        x_return_status       OUT     NoCopy VARCHAR2
)
IS

    CURSOR pegging(p_pegging_id	IN	NUMBER) IS
        select  pegging_id, identifier3, identifier2, identifier1,
                supply_demand_type, inventory_item_id, char1, organization_id, supply_demand_date,
                supply_demand_quantity, department_id, resource_id, order_line_id, supplier_id, supplier_site_id,
                supplier_atp_date, dest_inv_item_id, summary_flag
                , aggregate_time_fence_date,from_organization_id
        from    mrp_atp_details_temp
        where	record_type in (3,4)
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        start with pegging_id = p_pegging_id
        and     session_id = MSC_ATP_PVT.G_SESSION_ID
        and     record_type = 3
        connect by parent_pegging_id = prior pegging_id
        AND     session_id = prior session_id
        AND     record_type in (3,4);

    c1 pegging%ROWTYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Restore_SD_Rec Procedure *****');
    END IF;

    -- for ods, just need to remove the record from msc_sales_orders
    -- initialize API return status to success
    x_return_status                 := FND_API.G_RET_STS_SUCCESS;
    MSC_ATP_PVT.G_ALLOCATION_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'),2);
    MSC_ATP_PVT.G_ALLOCATED_ATP     := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
    MSC_ATP_PVT.G_INV_CTP           := FND_PROFILE.value('INV_CTP') ;

    FOR i IN p_pegging_tab.FIRST..p_pegging_tab.COUNT LOOP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'p_pegging_tab(i) = '              || p_pegging_tab(i));
     END IF;
     OPEN pegging(p_pegging_tab(i));
     LOOP


        FETCH pegging INTO c1;
        EXIT WHEN pegging%NOTFOUND;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'pegging_id = '                 || c1.pegging_id);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'identifier3 = '                || c1.identifier3);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'identifier1 = '                || c1.identifier1);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'plan_id (identifier2) = '      || c1.identifier2);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'supply_demand_type = '         || c1.supply_demand_type);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'inventory_item_id := '         || c1.inventory_item_id);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'char1 := '                     || c1.char1);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'resource_id := '               || c1.resource_id);
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'aggregate_time_fence_date := ' || c1.aggregate_time_fence_date);
        END IF;

        IF c1.supply_demand_type = 2 THEN
            IF NVL(c1.inventory_item_id, -1) > 0 THEN
                -- update the planned order that we may have enterred.
                UPDATE MSC_SUPPLIES
                SET   inventory_item_id = -1*inventory_item_id
                WHERE transaction_id = c1.identifier3
                AND   plan_id = c1.identifier2
                AND   inventory_item_id < 0;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Delete_SD_Rec: ' || 'No. of supply updated from msc_supplies = '|| SQL%ROWCOUNT);
                END IF;

                -- time_phased_atp
                IF (c1.aggregate_time_fence_date is not null)
                   OR
                   ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                    UPDATE MSC_ALLOC_SUPPLIES
                    SET   inventory_item_id = -1*inventory_item_id
                    WHERE parent_transaction_id = c1.identifier3
                    AND   plan_id = c1.identifier2
                    AND   inventory_item_id < 0;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'No. of supply updated from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
                IF NVL(c1.char1, '@@@') <> '@@@' THEN

                    UPDATE MSC_DEMANDS
                    SET   inventory_item_id = -1*inventory_item_id
                    WHERE demand_id = c1.identifier3
                    AND   plan_id = c1.identifier2
                    AND   inventory_item_id < 0;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'No. of stealing demands updated from msc_alloc_supplies = '|| SQL%ROWCOUNT);
                    END IF;
                END IF;
            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

        ELSE    -- IF c1.supply_demand_type = 2 THEN
            -- update the demand records we may have entrered.
            IF NVL(c1.inventory_item_id, -1) > 0 and c1.identifier2 <> -1 THEN

               UPDATE MSC_DEMANDS
               SET   inventory_item_id = -1*inventory_item_id
               WHERE   demand_id = c1.identifier3
               AND     plan_id = c1.identifier2
               AND	    old_demand_quantity IS NULL
               AND   inventory_item_id < 0;

               IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'No. of demand updated from msc_demand = '|| SQL%ROWCOUNT);
               END IF;

               -- time_phased_atp
               IF (c1.aggregate_time_fence_date is not null)
                  OR
                  ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                   (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                   (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                   (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                   UPDATE MSC_ALLOC_DEMANDS
                   SET   inventory_item_id = -1*inventory_item_id
                   WHERE parent_demand_id = c1.identifier3
                   AND	  old_allocated_quantity IS NULL
                   AND   plan_id = c1.identifier2
                   AND   inventory_item_id < 0;

                   IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'No. of demand updated from msc_alloc_demands = '|| SQL%ROWCOUNT);
                   END IF;
               END IF;

            ELSE    -- IF NVL(c1.inventory_item_id, -1) > 0 THEN

                UPDATE MSC_RESOURCE_REQUIREMENTS
                SET   resource_id = -1*resource_id
                WHERE   transaction_id = c1.identifier3
                AND     plan_id = c1.identifier2
                AND   sr_instance_id = c1.identifier1
                AND   resource_id < 0;

                IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'No. of demand updated from msc_resource_requirements = '|| SQL%ROWCOUNT);
                END IF;
            END IF; -- IF NVL(c1.inventory_item_id, -1) > 0 THEN
        END IF; -- IF c1.supply_demand_type = 2 THEN
    END LOOP;
    CLOSE pegging;
  END LOOP; --FOR i IN p_pegging_tab.FIRST..p_pegging_tab.COUNT LOOP

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Restore_SD_Rec Procedure *****');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Restore_SD_Rec: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
END Restore_SD_Rec;

END MSC_ATP_DB_UTILS;

/

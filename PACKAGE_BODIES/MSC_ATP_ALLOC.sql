--------------------------------------------------------
--  DDL for Package Body MSC_ATP_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_ALLOC" AS
/* $Header: MSCATALB.pls 120.2.12010000.2 2008/08/25 10:46:01 sbnaik ship $  */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'MSC_ATP_ALLOC';
G_UNALLOCATED_DC        CONSTANT VARCHAR2(2) := '-2';
G_MSG_DEBUG             CONSTANT NUMBER := 0;
G_MSG_LOG               CONSTANT NUMBER := 1;

G_REFRESH_ALLOCATION    BOOLEAN         := false;
PG_DEBUG                varchar2(1)     := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');
G_ATP_FW_CONSUME_METHOD NUMBER          := NVL(FND_PROFILE.VALUE('MSC_ATP_FORWARD_CONSUME_METHOD'), 1);
-- bug 2763784 (ssurendr)
-- To store rounding control type
--G_ROUNDING_CONTROL_FLAG NUMBER; --rajjain 02/12/2003 bug 2795992

-- Begin private procedures declaration
PROCEDURE Compute_Allocation_Details(
        p_session_id                    IN              NUMBER,
        p_inventory_item_id             IN              NUMBER,
        p_instance_id                   IN              NUMBER,
        p_organization_id               IN              NUMBER,
        p_plan_id                       IN              NUMBER,
        p_request_date                  IN              DATE,
        p_infinite_time_fence_date      IN              DATE,
        x_atp_period                    OUT     NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_dest_inv_item_id              OUT     NOCOPY  NUMBER, -- For new allocation logic for time phased ATP
        p_dest_family_item_id           OUT     NOCOPY  NUMBER, -- For new allocation logic for time phased ATP
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Insert_Allocation_Details(
        p_session_id                    IN              NUMBER,
        p_inventory_item_id             IN              NUMBER,
        p_organization_id               IN              NUMBER,
        p_instance_id                   IN              NUMBER,
        p_infinite_time_fence_date      IN              DATE,
        p_atp_period                    IN              MRP_ATP_PUB.ATP_Period_Typ,
        p_plan_name                     IN              VARCHAR2,  -- bug 2771192
        p_dest_inv_item_id              IN              NUMBER, -- For new allocation logic for time phased ATP
        p_dest_family_item_id           IN              NUMBER, -- For new allocation logic for time phased ATP
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Backward_Consume(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        x_dc_list_tab                   OUT     NOCOPY  MRP_ATP_PUB.char80_arr,
        x_dc_start_index                OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_dc_end_index                  OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Forward_Consume(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              NUMBER,
        p_end_index                     IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Backward_Forward_Consume(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        x_dc_list_tab                   OUT     NOCOPY  MRP_ATP_PUB.char80_arr,
        x_dc_start_index                OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_dc_end_index                  OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Compute_Cum(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_dc_list_tab                   IN              MRP_ATP_PUB.char80_arr,
        p_dc_start_index                IN              MRP_ATP_PUB.number_arr,
        p_dc_end_index                  IN              MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Adjust_Allocation_Details(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        x_dc_list_tab                   OUT     NOCOPY  MRP_ATP_PUB.char80_arr,
        x_dc_start_index                OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_dc_end_index                  OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Demand_Class_Consumption(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              number,
        p_end_index                     IN              number,
        p_steal_atp                     IN OUT  NOCOPY  MRP_ATP_PVT.ATP_Info,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Add_to_Next_Steal(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              number,
        p_end_index                     IN              number,
        p_next_steal_atp                IN OUT  NOCOPY  MRP_ATP_PVT.ATP_Info,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Add_to_Current_Atp(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              number,
        p_end_index                     IN              number,
        p_steal_atp                     IN              MRP_ATP_PVT.ATP_Info,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Compute_Cum_Individual(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              NUMBER,
        p_end_index                     IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Remove_Negatives(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              NUMBER,
        p_end_index                     IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Adjust_Cum(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_cur_start_index               IN              NUMBER,
        p_cur_end_index                 IN              NUMBER,
        p_unalloc_start_index           IN              NUMBER,
        p_unalloc_end_index             IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2);

PROCEDURE Set_Error(
        p_error_code                    IN      INTEGER);

-- End private procedures declaration


/*--View_Allocation_Details------------------------------------------------
|  o This is the entry point for the engine when directly called.
|  o Refresh_Allocation_Details calls this when the engine is called in
|    concurrent program mode.
|  o Calls Compute_Allocation_Details followed by Insert_Allocation_Details.
+-------------------------------------------------------------------------*/
PROCEDURE View_Allocation_Details(
        p_session_id            IN              NUMBER,
        p_inventory_item_id     IN              NUMBER,
        p_instance_id           IN              NUMBER,
        p_organization_id       IN              NUMBER,
        x_return_status         OUT     NOCOPY  VARCHAR2)
IS
        -- local variables
        l_request_date                  DATE;
        l_plan_info_rec                 MSC_ATP_PVT.plan_info_rec;
        l_infinite_time_fence_date      DATE;
        l_atp_period                    MRP_ATP_PUB.ATP_Period_Typ;
        l_counter                       PLS_INTEGER;
        l_return_status                 VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;

        -- For new allocation logic for time phased ATP
        l_dest_inv_item_id              NUMBER;
        l_dest_family_item_id           NUMBER;

BEGIN
        -- Setting the session_id
        msc_sch_wb.set_session_id(p_session_id);

        -- Debug Messages
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  '*********Begin procedure View_Allocation_Details ********');
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'p_inventory_item_id = ' ||to_char(p_inventory_item_id));
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'p_instance_id = ' ||to_char(p_instance_id));
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'p_organization_id = ' ||to_char(p_organization_id));
        END IF;

        -- Initializing global error code, API return code
        MSC_SCH_WB.G_ATP_ERROR_CODE := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        -- Get next working day from sysdate required for compute_allocation_details.
        SELECT   MSC_CALENDAR.NEXT_WORK_DAY(p_organization_id, p_instance_id, 1, TRUNC(sysdate))
        INTO    l_request_date
        FROM    dual;

        IF (l_request_date = NULL) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'There is no matching calander date');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Set_Error(MSC_ATP_PVT.NO_MATCHING_CAL_DATE);
                return;
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'Request Date : '||to_char(l_request_date, 'DD-MON-YYYY'));
        END IF;

        -- Check the profile settings.
        -- IF (MSC_ATP_PVT.G_INV_CTP <> 4 OR MSC_ATP_PVT.G_ALLOCATED_ATP <> 'Y') THEN
        -- bug 2813095 (ssurendr) breaking the validations into two
        IF (MSC_ATP_PVT.G_INV_CTP <> 4) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'INV_CTP is not 4');
                END IF;
                Set_Error(MSC_ATP_PVT.INVALID_INV_CTP_PROFILE_SETUP);
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        IF (MSC_ATP_PVT.G_ALLOCATED_ATP <> 'Y') THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Enable Allocated ATP is not Yes');
                END IF;
                Set_Error(MSC_ATP_PVT.INVALID_ALLOC_ATP_OFF);
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        -- Trap preliminary plan related errors
        MSC_ATP_PROC.Get_plan_Info(p_instance_id, p_inventory_item_id, p_organization_id, null, l_plan_info_rec);

        IF (l_plan_info_rec.plan_id IS NULL) OR (l_plan_info_rec.plan_id = -1) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Plan_ID is null or -1');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Set_Error(MSC_ATP_PVT.PLAN_NOT_FOUND);
                return;
        ELSIF (l_plan_info_rec.plan_id = -100) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Plan_ID is -100 : Summary is Running');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Set_Error(MSC_ATP_PVT.SUMM_CONC_PROG_RUNNING);
                return;
        ELSIF (l_plan_info_rec.plan_id = -200) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Plan_ID is -200 : Post Plan Alloc progranm has not been run');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Set_Error(MSC_ATP_PVT.RUN_POST_PLAN_ALLOC);
                return;
        ELSIF (l_plan_info_rec.plan_id = -300) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Plan_ID is -300 : ATP Downtime');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Set_Error(MSC_ATP_PVT.TRY_ATP_LATER);
                return;
        END IF;

        -- Get the infinite time fence date
        l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(p_instance_id,
                                        p_inventory_item_id, p_organization_id, l_plan_info_rec.plan_id);

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'Plan Id : '||to_char(l_plan_info_rec.plan_id));
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'infinite time fence date : ' || l_infinite_time_fence_date);
        END IF;


        /* Call Compute_Allocation_Details to get horizontal period information. */

        Compute_Allocation_Details(p_session_id, p_inventory_item_id, p_instance_id,
        p_organization_id, l_plan_info_rec.plan_id, l_request_date, l_infinite_time_fence_date, l_atp_period,
        l_dest_inv_item_id, l_dest_family_item_id, -- For new allocation logic for time phased ATP
        l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'Error occured in procedure Compute_Allocation_Details');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Commit;
                return;
        END IF;

        -- Debug messages
        IF (l_atp_period.period_quantity.COUNT = 0) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'l_atp_period is NULL');
                END IF;
                -- rajjain bug 2951786 05/13/2003
                Set_Error(MSC_ATP_PVT.NO_SUPPLY_DEMAND);
                --Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                x_return_status := FND_API.G_RET_STS_ERROR;
                Commit;
                return;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                l_counter := l_atp_period.Period_Quantity.FIRST;
                WHILE l_counter is not null LOOP
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'demand_class, period_start_date, End date, Period_Qty, Cum_Qty = '||
                                l_atp_period.demand_class(l_counter) ||' : '||
                                l_atp_period.period_start_date(l_counter) ||' : '||
                                l_atp_period.period_end_date(l_counter) ||' : '||
                                l_atp_period.Period_Quantity(l_counter) ||' : '||
                                l_atp_period.Cumulative_Quantity(l_counter)
                                );

                        l_counter := l_atp_period.Period_Quantity.Next(l_counter);
                END LOOP;
        END IF;

        /* Call Insert_Allocation_Details to insert horizontal period information into temp table. */

        Insert_Allocation_Details(p_session_id, p_inventory_item_id, p_organization_id,
        p_instance_id, l_infinite_time_fence_date, l_atp_period, l_plan_info_rec.plan_name,
        l_dest_inv_item_id, l_dest_family_item_id, -- For new allocation logic for time phased ATP
        l_return_status);
        -- plan_name added for bug 2771192

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  'Error occured in procedure Insert_Allocation_Details');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' ||  '*********End of procedure View_Allocation_Details ********');
        END IF;

        Commit;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Error in View_Allocation_Details: Expected Error Raised' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

WHEN  MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Error in View_Allocation_Details: Invalid Objects Found');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_INVALID_OBJECTS);

WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('View_Allocation_Details: ' || 'Error in View_Allocation_Details: Unexpected Error Raised: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

END View_allocation_Details;


/*--Compute_Allocation_Details----------------------------------------------
|  o Called by View_Allocation_Details after doing preliminary checks.
|  o Does allocation and puts supply/demand data in temp table.
|  o Does netting and gets period data in plsql tables.
|  o For demand priority, calls Backward_Forward_Consume and Coplute_Cum
|  o For rule based case, calls Adjust_Allocation_Details.
+-------------------------------------------------------------------------*/
PROCEDURE Compute_Allocation_Details(
        p_session_id                    IN              NUMBER,
        p_inventory_item_id             IN              NUMBER,
        p_instance_id                   IN              NUMBER,
        p_organization_id               IN              NUMBER,
        p_plan_id                       IN              NUMBER,
        p_request_date                  IN              DATE,
        p_infinite_time_fence_date      IN              DATE,
        x_atp_period                    OUT     NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_dest_inv_item_id              OUT     NOCOPY  NUMBER, -- For new allocation logic for time phased ATP
        p_dest_family_item_id           OUT     NOCOPY  NUMBER, -- For new allocation logic for time phased ATP
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        -- local variables
        l_inv_item_id                   PLS_INTEGER;
        l_inv_item_name                 MSC_SYSTEM_ITEMS.ITEM_NAME%TYPE;
        l_uom_code                      VARCHAR2(3);
        l_dc_list_tab                   MRP_ATP_PUB.char80_arr;
        l_dc_start_index                MRP_ATP_PUB.number_arr;
        l_dc_end_index                  MRP_ATP_PUB.number_arr;
        l_index_counter                 PLS_INTEGER;
        l_start_index                   PLS_INTEGER;
        l_end_index                     PLS_INTEGER;
        l_period_counter                PLS_INTEGER;
        l_count                         PLS_INTEGER;
        l_default_atp_rule_id           PLS_INTEGER;
        l_calendar_exception_set_id     PLS_INTEGER;
        l_default_demand_class          VARCHAR2(80);
        l_calendar_code                 VARCHAR2(14);
        l_org_code                      VARCHAR2(7);
        l_scenario_id                   PLS_INTEGER;
        l_record_type                   PLS_INTEGER;
        l_level_id                      PLS_INTEGER;
        l_return_status                 VARCHAR2(1);
        -- bug 2763784 (ssurendr)
        -- Should not error out if no s/d record found
        l_class_tab                     MRP_ATP_PUB.char80_arr;
        l_customer_id_tab               MRP_ATP_PUB.number_arr;
        l_customer_site_id_tab          MRP_ATP_PUB.number_arr;
        -- rajjain 02/19/2003 Bug 2806076
        l_all_dc_list_tab               MRP_ATP_PUB.char80_arr;
        -- bug 2813095 (ssurendr)
        l_atp_flag                      VARCHAR2(1);
        -- time_phased_atp
        l_time_phased_atp               VARCHAR2(1) := 'N';
        l_pf_dest_id                    NUMBER;
        l_pf_sr_id                      NUMBER;
        l_atf_date                      DATE;
        l_insert_count                  NUMBER;
        l_item_to_use                   NUMBER;
        --bug3700564 added family name
        l_family_name                   VARCHAR2(250);
        -- Bug 3823042
        l_sys_next_date                 DATE;
        l_item_name_to_use              MSC_SYSTEM_ITEMS.ITEM_NAME%TYPE; --Bug 3823042
        l_null_date                     DATE;   -- Bug 3875786
        l_null_char                     VARCHAR2(1); --Bug 3875786

BEGIN
        -- Debug Messages
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  '*********Inside procedure Compute_Allocation_Details ********');
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'G_INV_CTP= ' || MSC_ATP_PVT.G_INV_CTP);
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'G_HIERARCHY_PROFILE = '|| MSC_ATP_PVT.G_HIERARCHY_PROFILE );
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'G_ALLOCATED_ATP = ' || MSC_ATP_PVT.G_ALLOCATED_ATP );
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'G_ALLOCATION_METHOD = '|| MSC_ATP_PVT.G_ALLOCATION_METHOD );
        END IF;

        -- Initialization section.
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_scenario_id := 0;
        l_record_type   := 2;
        /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
           Reset global variable*/
        MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED := 'N';

        -- Get inventory_item_id and uom_code from msc_system_items
        BEGIN
                -- bug 2763784 (ssurendr)
                -- Get the rounding control type as well
                -- bug 2813095 (ssurendr)
                -- Get the atp flag as well
                -- rajjain 02/12/2003 bug 2795992
                SELECT msi.inventory_item_id, msi.uom_code,
                       msi.item_name, mtp.organization_code, msi.atp_flag
                       --, NVL(msi.rounding_control_type, 2)
                INTO   l_inv_item_id, l_uom_code,
                       l_inv_item_name,
                       l_org_code, l_atp_flag
                       --, G_ROUNDING_CONTROL_FLAG
                FROM   msc_system_items msi,
                       msc_trading_partners mtp
                WHERE  msi.plan_id = p_plan_id
                AND    msi.sr_instance_id = p_instance_id
                AND    msi.organization_id = p_organization_id
                AND    msi.sr_inventory_item_id = p_inventory_item_id
                AND    msi.organization_id = mtp.sr_tp_id
                AND    msi.sr_instance_id = mtp.sr_instance_id
                AND    mtp.partner_type=3;
        EXCEPTION
                WHEN OTHERS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error selecting inventory item id from msc_system_items: ' || to_char(sqlcode) || ':' || SQLERRM);
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
        END;

        -- time_phased_atp
        MSC_ATP_PF.Get_Family_Item_Info(
               p_instance_id,
               p_plan_id,
               l_inv_item_id,
               p_organization_id,
               l_pf_dest_id,
               l_pf_sr_id,
               l_atf_date,
               --bug3700564
               l_family_name,
               l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Get_Family_Item_Info');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_inv_item_id <> l_pf_dest_id) and (l_atf_date is not null) THEN
                l_time_phased_atp := 'Y';
                G_ATF_DATE        := l_atf_date;
                /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
                   Set global variable too. This is used in Get_Item_Demand_Alloc_Percent function*/
                MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED := 'Y';
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Time phased atp = ' || l_time_phased_atp);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'G_TIME_PHASED_PF_ENABLED = ' || MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED);
                END IF;
        END IF;

        -- For new allocation logic for time phased ATP
        p_dest_inv_item_id      := l_inv_item_id;
        p_dest_family_item_id   := l_pf_dest_id;

        -- bug 2813095 (ssurendr) error out if not atpable
        IF l_atp_flag <> 'Y' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Item not ATPable');
                END IF;
                Set_Error(MSC_ATP_PVT.ATP_NOT_APPL);
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'l_inv_item_id: ' || l_inv_item_id);
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'p_organization_id: ' || p_organization_id);
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'p_plan_id: ' || p_plan_id);
                --msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'G_ROUNDING_CONTROL_FLAG: ' || G_ROUNDING_CONTROL_FLAG);
        END IF;

        /* New allocation logic for time_phased_atp changes begin */
        IF l_time_phased_atp = 'Y' THEN
                MSC_ATP_PF.Set_Alloc_Rule_Variables(
                    l_inv_item_id,
                    l_pf_dest_id,
                    p_organization_id,
                    p_instance_id,
                    '-1',
                    l_atf_date,
                    l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Set_Alloc_Rule_Variables');
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF p_request_date <= l_atf_date THEN
                    IF MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF = 'Y' THEN
                        l_item_to_use := l_inv_item_id;
                    ELSE
                        l_item_to_use := l_pf_dest_id;
                    END IF;
                ELSE
                    IF MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF = 'Y' THEN
                        l_item_to_use := l_pf_dest_id;
                    ELSE
                        l_item_to_use := l_inv_item_id;
                    END IF;
                END IF;
        ELSE
                l_item_to_use := l_pf_dest_id;
                l_item_name_to_use := l_family_name; -- Bug 3823042
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'p_request_date = '||p_request_date);
           msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Item to be used = '||l_item_to_use);
        END IF;
        /* New allocation logic for time_phased_atp changes end */

        IF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) THEN
                -- Demand Priority
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'We are in Demand Priority Allocation');
                END IF;

                -- initialize l_level_id. level_id remains -1 for demand priority
                l_level_id      := -1;

                /* Find all the demand classes on the request date = next working day from SYSDATE
                   from materialized view and store them in msc_alloc_temp table.
                   If no demand class found on request date, dont proceed any further, flag an error. */
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Checking the demand classes on p_request_date.');
                END IF;

                INSERT INTO MSC_ALLOC_TEMP(DEMAND_CLASS)
                SELECT mv.demand_class
                FROM   msc_item_hierarchy_mv mv
                WHERE  mv.inventory_item_id = l_item_to_use
                AND    mv.organization_id = p_organization_id
                AND    mv.sr_instance_id = p_instance_id
                AND    p_request_date BETWEEN effective_date AND disable_date
                AND    mv.level_id = l_level_id;

                IF (SQL%ROWCOUNT = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('No Demand Class found');
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Demand classes found and stored in msc_alloc_temp table');
                END IF;

                /*
                1. Copy the supply demand records from msc_alloc_supplies and msc_alloc_demands
                   into mrp_atp_details_temp.
                2. We copy from_demand_class for stealing records from MSC_ALLOC_SUPPLIES.
                3. Allocated Qty <= Total Supply Demand Quantity.
                4. MSC_ALLOC_TEMP holds the demand classes on p_request_date. A join between MSC_ALLOC_TEMP
                   and msc_alloc_supplies/msc_alloc_demands ensures we chose only request date demand classes.
                5. Transform order types 46,47 (Supply/Demand due to Stealing) to 48 (Supply Adjustment).
                   This is required only for MSC_ALLOC_SUPPLIES.
                */

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before copying supply/demand records from alloc into temp tables.');
                END IF;

                -- time_phased_atp changes begin
                IF l_time_phased_atp = 'Y' THEN
                        MSC_ATP_PF.Insert_SD_Into_Details_Temp(
                                MSC_ATP_PF.Demand_Priority,
                                l_inv_item_id,
                                l_pf_dest_id,
                                p_inventory_item_id,
                                l_pf_sr_id,
                                p_organization_id,
                                --bug3671294 now we donot need this as we will join with msc_system_items
                                --l_inv_item_name,
                                l_org_code,
                                p_instance_id,
                                p_plan_id,
                                p_infinite_time_fence_date,
                                l_level_id,
                                p_session_id,
                                l_record_type,
                                l_scenario_id,
                                l_uom_code,
                                l_insert_count,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Insert_SD_Into_Details_Temp');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                -- time_phased_atp changes end
                ELSE
                        INSERT INTO MRP_ATP_DETAILS_TEMP
                        (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                        supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                        allocated_quantity, record_type, scenario_id, disposition_name, demand_class, char1,
                        uom_code, plan_id, inventory_item_name, organization_code,
                        ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE ) --bug3263368
                        SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                        col11, col12, col13, col14, col15, col16, col17, col18, col19, col20,
                        col21, col22, col23, col24
                        FROM
                        (SELECT p_session_id                    col1, -- session_id
                                l_level_id                      col2, -- level_id
                                p_inventory_item_id             col3, -- inventory_item_id
                                p_organization_id               col4, -- organization_id
                                p_instance_id                   col5, -- Identifier1
                                AD.PARENT_DEMAND_ID             col6, -- Identifier3
                                1                               col7, -- supply_demand_type
                                TRUNC(AD.DEMAND_DATE)           col8, -- supply_demand_date
                                -1 * NVL(AD.DEMAND_QUANTITY,
                                AD.ALLOCATED_QUANTITY)          col9, -- supply_demand_quantity
                                decode(AD.ORIGINATION_TYPE,-100,30,AD.ORIGINATION_TYPE)     col10, -- supply_demand_source_type
                                -1 * AD.ALLOCATED_QUANTITY      col11, -- allocated_quantity
                                l_record_type                   col12, -- record_type
                                l_scenario_id                   col13, -- scenario_id
                                AD.ORDER_NUMBER                 col14, -- disposition_name
                                AD.DEMAND_CLASS                 col15, -- demand_class
                                l_null_char                     col16, -- from_demand_class --Bug 3875786
                                l_uom_code                      col17, -- UOM Code
                                p_plan_id                       col18, -- Plan id
                                l_item_name_to_use              col19, -- Item name --Bug 3823042
                                --l_inv_item_name                 col19, -- Item name
                                l_org_code                      col20,   -- Organization code
                                MTPS.LOCATION                   col21, --bug3263368
                                MTP.PARTNER_NAME                col22, --bug3263368
                                AD.DEMAND_CLASS                 col23, --bug3263368
                                AD.REQUEST_DATE                 col24  --bug3263368
                        FROM
                                MSC_ALLOC_DEMANDS AD,
                                MSC_ALLOC_TEMP TEMP,
                                MSC_TRADING_PARTNERS    MTP,--bug3263368
                                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
                        WHERE
                                AD.PLAN_ID = p_plan_id
                                AND      AD.SR_INSTANCE_ID = p_instance_id
                                AND      AD.INVENTORY_ITEM_ID = l_item_to_use -- Bug 3823042
                                AND      AD.ORGANIZATION_ID = p_organization_id
                                AND      AD.ALLOCATED_QUANTITY <> 0
                                AND      AD.DEMAND_CLASS = TEMP.DEMAND_CLASS
                                AND      TRUNC(AD.DEMAND_DATE) < TRUNC(p_infinite_time_fence_date)  -- Bug 3823042
                                AND      AD.ORIGINATION_TYPE <> 52  -- Ignore copy SO and copy stealing records for allocation WB - summary enhancement
                                AND      AD.SHIP_TO_SITE_ID  = MTPS.PARTNER_SITE_ID(+) --bug3263368
                                AND      AD.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
                        UNION ALL
                        SELECT  p_session_id                    col1,
                                l_level_id                      col2,
                                p_inventory_item_id             col3 ,
                                p_organization_id               col4,
                                p_instance_id                   col5,
                                SA.PARENT_TRANSACTION_ID        col6,
                                2                               col7, -- supply
                                TRUNC(SA.SUPPLY_DATE)           col8,
                                NVL(SA.SUPPLY_QUANTITY,
                                SA.ALLOCATED_QUANTITY)          col9,
                                DECODE(SA.ORDER_TYPE,
                                        46, 48,                 -- Change Supply due to Stealing to Supply Adjustment
                                        47, 48,                 -- Change Demand due to Stealing to Supply Adjustment
                                        SA.ORDER_TYPE)          col10,
                                SA.ALLOCATED_QUANTITY           col11,
                                l_record_type                   col12, -- record_type
                                l_scenario_id                   col13, -- scenario_id
                             -- Bug 2771075. For Planned Orders, we will populate transaction_id
                             -- in the disposition_name column to be consistent with Planning.
                                DECODE(SA.ORDER_TYPE,
                                        5, to_char(SA.PARENT_TRANSACTION_ID),
                                        SA.ORDER_NUMBER)        col14,
                                SA.DEMAND_CLASS                 col15,
                                SA.FROM_DEMAND_CLASS            col16,
                                l_uom_code                      col17,
                                p_plan_id                       col18,
                                l_item_name_to_use              col19, -- Item name --Bug 3823042
                                --l_inv_item_name                 col19, -- Item name
                                l_org_code                      col20, -- Organization code
                                MTPS.LOCATION                   col21, --bug3684383
                                MTP.PARTNER_NAME                col22, --bug3684383
                                SA.DEMAND_CLASS                 col23, --bug3684383
                                l_null_date                     col24  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - null removed
                        FROM
                                MSC_ALLOC_SUPPLIES SA,
                                MSC_ALLOC_TEMP TEMP,
                                MSC_TRADING_PARTNERS    MTP,--bug3684383
                                MSC_TRADING_PARTNER_SITES    MTPS --bug3684383
                        WHERE
                                SA.PLAN_ID = p_plan_id
                                AND      SA.SR_INSTANCE_ID = p_instance_id
                                AND      SA.INVENTORY_ITEM_ID = l_item_to_use -- Bug 3823042
                                AND      SA.ORGANIZATION_ID = p_organization_id
                                AND      SA.ALLOCATED_QUANTITY <> 0
                                AND      SA.DEMAND_CLASS = TEMP.DEMAND_CLASS
                                AND      TRUNC(SA.SUPPLY_DATE) < TRUNC(p_infinite_time_fence_date) -- Bug 3823042
                                AND      SA.SHIP_TO_SITE_ID  = MTPS.PARTNER_SITE_ID(+) --bug3684383
                                AND      SA.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3684383
                        );
                        l_insert_count := SQL%ROWCOUNT;
                END IF;

                IF (l_insert_count = 0) THEN
		        IF PG_DEBUG in ('Y', 'C') THEN
		                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'No s/d records could be inserted from msc_alloc tables into temp table');
		        END IF;

                        -- bug 2763784 (ssurendr)
                        -- Should not error out if no s/d record found
                        --Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        --x_return_status := FND_API.G_RET_STS_ERROR;
                        --return;
                ELSE
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After copying supply/demand records from alloc into temp tables.');
                        END IF;

                        /* Bulk Collect Allocated Supply, Stolen Supply, Total Supply,
                        Allocated Demand, Stolen Demand, Total Demand and Net into PL/SQL Period table.
                        Cum is calculated after b/w, f/w consumption and accumulation. */
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before selecting supply/demand records from temp table into PL/SQL period table.');
                        END IF;

                        -- time_phased_atp changes begin
                        IF l_time_phased_atp = 'Y' THEN
                                MSC_ATP_PF.Get_Period_From_Details_Temp(
                                        MSC_ATP_PF.Demand_Priority,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_scenario_id,
                                        l_level_id,
                                        l_record_type,
                                        p_session_id,
                                        x_atp_period,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Get_Period_From_Details_Temp');
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;
                        -- time_phased_atp changes end
                        ELSE
                                SELECT
                                        final.col1,
                                        final.col2,
                                        final.col3,
                                        final.col4,
                                        final.col5,
                                        final.col6,
                                        final.col7,
                                        null,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_scenario_id,
                                        l_level_id,
                                        null,           -- Initialize period end date with null
                                        0,              -- Initialize backward_forward_quantity with 0
                                        0               -- Initialize cumulative quantity with 0
                                BULK COLLECT INTO
                                        x_atp_period.Demand_Class,
                                        x_atp_period.Period_Start_Date,
                                        x_atp_period.Allocated_Supply_Quantity,
                                        x_atp_period.Supply_Adjustment_Quantity,
                                        x_atp_period.Total_Supply_Quantity,
                                        x_atp_period.Total_Demand_Quantity,
                                        x_atp_period.Period_Quantity,
                                        x_atp_period.Total_Bucketed_Demand_Quantity,
                                        x_atp_period.Inventory_Item_Id,
                                        x_atp_period.Organization_Id,
                                        x_atp_period.Identifier1,
                                        x_atp_period.Scenario_Id,
                                        x_atp_period.Level,
                                        x_atp_period.Period_End_Date,
                                        x_atp_period.Backward_Forward_Quantity,
                                        x_atp_period.Cumulative_Quantity
                                FROM
                                (SELECT DEMAND_CLASS                                                    col1,
                                        SUPPLY_DEMAND_DATE                                              col2,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2,
                                                DECODE(SUPPLY_DEMAND_SOURCE_TYPE,
                                                                48, 0,
                                                                ALLOCATED_QUANTITY),
                                                0))                                                     col3, -- Allocated Supply Quantity
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2,
                                                DECODE(SUPPLY_DEMAND_SOURCE_TYPE,
                                                                48,  ALLOCATED_QUANTITY,
                                                                0),
                                                0))                                                     col4, -- Supply Adjustment Quantity
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2, ALLOCATED_QUANTITY, 0))       col5, -- Total Supply
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 1, ALLOCATED_QUANTITY, 0))       col6, -- Total Demand
                                        SUM(ALLOCATED_QUANTITY)                                         col7  -- Period Quantity
                                FROM
                                        MRP_ATP_DETAILS_TEMP
                                WHERE
                                        SESSION_ID = p_session_id
                                        AND RECORD_TYPE = l_record_type
                                GROUP BY
                                        DEMAND_CLASS, SUPPLY_DEMAND_DATE
                                ORDER BY
                                        DEMAND_CLASS, SUPPLY_DEMAND_DATE --5233538 10G issue
                                ) final;
                        END IF;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After selecting supply/demand records from temp table into PL/SQL period table.');
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before backward and forward consumption for each demand class');
                        END IF;

                        -- Call procedure Backward_Forward_Consume to do backward and forward consumption
                        Backward_Forward_Consume(x_atp_period, l_dc_list_tab, l_dc_start_index, l_dc_end_index, l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Backward_Forward_Consume');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before accumulation for each demand class');
                        END IF;

                        -- Copy Cumulative Quantity from Backward_Forward_Quantity
                        x_atp_period.Cumulative_Quantity := x_atp_period.Backward_Forward_Quantity;

                        -- Call procedure Compute_Cum to do accumulation
                        Compute_Cum(x_atp_period, l_dc_list_tab, l_dc_start_index, l_dc_end_index, l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Compute_Cum');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF;

                /* Compute Period_End_Date for all demand classes */
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before computing period_end_date');
                END IF;
                -- bug 2763784 (ssurendr)
                -- Should not error out if no s/d record found
                -- rajjain 03/20/2003 Bug 2860891
                -- Taken the IF condition out of FOR loop
                IF l_dc_start_index IS NOT NULL
                    AND l_dc_start_index.COUNT>0 THEN
                        FOR l_index_counter IN 1..l_dc_list_tab.COUNT LOOP
                                l_start_index   := l_dc_start_index(l_index_counter);
                                l_end_index     := l_dc_end_index(l_index_counter);

                                -- Find Period End Date for all demand class records
                                FOR l_period_counter IN l_start_index..l_end_index LOOP
                                        IF (l_period_counter = l_end_index) THEN
                                                /*IF (p_infinite_time_fence_date IS NOT NULL) THEN
                                                        x_atp_period.Period_End_Date(l_period_counter) := p_infinite_time_fence_date - 1;
                                                ELSE
                                                        x_atp_period.Period_End_Date(l_period_counter) := x_atp_period.Period_Start_Date(l_period_counter);
                                                END IF;*/
                                                -- Bug 3823042
                                                x_atp_period.Period_End_Date(l_period_counter) := p_infinite_time_fence_date - 1;
                                        ELSE
                                                x_atp_period.Period_End_Date(l_period_counter) := x_atp_period.Period_Start_Date(l_period_counter + 1) - 1;
                                        END IF;
                                END LOOP;
                        END LOOP;
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After computing period_end_date');
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before appending infinite time fence date records');
                END IF;
                /* rajjain 02/19/2003 Bug 2806076
                 * Add infinite time fence record for all the demand classes in demand class hierarchy*/

                --IF p_infinite_time_fence_date IS NOT NULL THEN -- Bug 3823042, as in PDS, p_infinite_time_fence_date is never NULL

        	        SELECT demand_class
        	        BULK   COLLECT INTO l_all_dc_list_tab
        	        FROM   MSC_ALLOC_TEMP;

        	        IF PG_DEBUG in ('Y', 'C') THEN
        	                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'l_all_dc_list_tab.COUNT: ' || l_all_dc_list_tab.COUNT);
        	        END IF;

                        FOR l_index_counter IN 1..l_all_dc_list_tab.COUNT LOOP

                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Adding infinite time fence date for demand class '|| l_all_dc_list_tab(l_index_counter));
                                END IF;
                                MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);

                                l_count := x_atp_period.Period_Start_Date.COUNT;

                                x_atp_period.Demand_Class(l_count)                      := l_all_dc_list_tab(l_index_counter);
                                x_atp_period.Period_Start_Date(l_count)                 := p_infinite_time_fence_date;
                                x_atp_period.Allocated_Supply_Quantity(l_count)         := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Supply_Adjustment_Quantity(l_count)        := 0;
                                x_atp_period.Total_Supply_Quantity(l_count)             := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Total_Demand_Quantity(l_count)             := 0;
                                x_atp_period.Total_Bucketed_Demand_Quantity(l_count)    := 0; -- for time_phased_atp
                                x_atp_period.Period_Quantity(l_count)                   := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Backward_Forward_Quantity(l_count)         := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Period_End_Date(l_count)                   := p_infinite_time_fence_date;
                                x_atp_period.Cumulative_Quantity(l_count)               := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Inventory_Item_Id(l_count)                 := p_inventory_item_id;
                                x_atp_period.Organization_Id(l_count)                   := p_organization_id;
                                x_atp_period.Identifier1(l_count)                       := p_instance_id;
                                x_atp_period.Scenario_Id(l_count)                       := l_scenario_id;
                                x_atp_period.Level(l_count)                             := l_level_id;
                         END LOOP;

                -- END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After appending infinite time fence records');
                END IF;

                -- time_phased_atp changes begin
                IF l_time_phased_atp = 'Y' THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before populating original demand qty in MADT');
                        END IF;
                        /* Now populate Original_Demand_Qty*/
                        MSC_ATP_PF.Populate_Original_Demand_Qty(
                        	MSC_ATP_PF.MADT,
                        	p_session_id,
                        	p_plan_id,
                        	NULL,
                                l_return_status
                        );

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: ' || 'Error occured in procedure Populate_Original_Demand_Qty');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After populating original demand qty in MADT');
                        END IF;
                END IF;
                -- time_phased_atp changes end

        ELSIF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND (MSC_ATP_PVT.G_ALLOCATION_METHOD = 2)) THEN
                -- IF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) THEN

                -- Rule based allocation; Demand class case
                -- initialize l_level_id. level_id remains -1 for demand class allocation
                l_level_id      := -1;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'We are in demand class allocation.');
                END IF;

                /* Store all the demand classes on the request date = next working day from SYSDATE
                   and store them in msc_alloc_temp table.
                   If no demand class found on request date, dont proceed any further*/

                INSERT INTO MSC_ALLOC_TEMP(DEMAND_CLASS, PRIORITY, ALLOCATION_PERCENT)
                SELECT mv.demand_class, mv.priority, mv.allocation_percent
                FROM   msc_item_hierarchy_mv mv
                WHERE  mv.inventory_item_id = l_item_to_use
                AND    mv.organization_id = p_organization_id
                AND    mv.sr_instance_id = p_instance_id
                AND    p_request_date BETWEEN effective_date AND disable_date
                AND    mv.level_id = l_level_id;

                IF (SQL%ROWCOUNT = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('No Demand Class found');
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;


                /* Modularize Item and Org Info */
                MSC_ATP_PROC.get_global_org_info(p_instance_id, p_organization_id);
                l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
                l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
                l_calendar_exception_set_id := MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
                l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
                l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;

                -- Bug 3823042
                l_sys_next_date := MSC_CALENDAR.NEXT_WORK_DAY(
                                    l_calendar_code,
                                    p_instance_id,
                                    TRUNC(sysdate));

                -- Debug info
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_default_atp_rule_id='|| l_default_atp_rule_id);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_calendar_code='||l_calendar_code);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_default_demand_class'|| l_default_demand_class);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_org_code'|| l_org_code);
                END IF;

                /*
                1. Copy the supply demand records from msc_supplies and msc_demands
                   into mrp_atp_details_temp. Perform allocation in the process.
                2. Forward consumtion logic is such that individual stealing acts cannot be recorded,
                   therefore, we do not select from_demand_class.
                3. MSC_ALLOC_TEMP here stores allocation demand classes. We make a cartesian to split the supplies/demands
                4. Finally we put only those records where allocated_quantity <> 0
                */
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before copying supply/demand records from msc_supplies/msc_demands into temp tables.');
                END IF;

                -- time_phased_atp changes begin
                IF l_time_phased_atp = 'Y' THEN
                        MSC_ATP_PF.Insert_SD_Into_Details_Temp(
                                MSC_ATP_PF.User_Defined_DC,
                                l_inv_item_id,
                                l_pf_dest_id,
                                p_inventory_item_id,
                                l_pf_sr_id,
                                p_organization_id,
                                --bug3671294 now we donot need this as we will join with msc_system_items
                                --l_inv_item_name,
                                l_org_code,
                                p_instance_id,
                                p_plan_id,
                                p_infinite_time_fence_date,
                                l_level_id,
                                p_session_id,
                                l_record_type,
                                l_scenario_id,
                                l_uom_code,
                                l_insert_count,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Insert_SD_Into_Details_Temp');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                -- time_phased_atp changes end
                ELSE

                    IF ( MSC_ATP_PVT.G_OPTIMIZED_PLAN = 1) THEN
                        -- Bug 3823042: optimized plan, donot use msc_calendar_dates

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'User defined demand class, Optimized plan');
                        END IF;

                        INSERT INTO MRP_ATP_DETAILS_TEMP
                        (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                        supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                        allocated_quantity, record_type, scenario_id, disposition_name, demand_class, uom_code,
                        inventory_item_name, organization_code, identifier2, identifier4,
                        ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE ) --bug3263368
                        SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                        col11, col12, col13, col14, col15, col16, col17, col18, col19, col20,col21,col22,col23,col24
                        FROM
                        (SELECT p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                D.DEMAND_ID                             col6, -- Identifier3
                                1                                       col7, -- supply_demand_type
                                -- Bug 3823042
                                GREATEST(TRUNC(DECODE(D.RECORD_SOURCE,
                                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                              2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_sys_next_date) col8,
                                --C.PRIOR_DATE                            col8, -- supply_demand_date
                                -1 * (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))       col9, -- supply_demand_quantity -- Bug 3823042
                                decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE)                      col10, -- supply_demand_source_type
                                -1* (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) *      -- Bug 3823042
                                        DECODE(decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                6, decode(d.source_organization_id,
                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)), NULL),
                                                30, decode(d.source_organization_id,
                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)), NULL),
                                                DECODE(D.DEMAND_CLASS, null, null,
                                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        null, null, l_item_to_use, p_organization_id,
                                                                        p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                        2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                           DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                  2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                D.DEMAND_CLASS))),
                                                TEMP.DEMAND_CLASS, 1,
                                                MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                                        D.DEMAND_ID,
                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                            NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                        --c.prior_date,
                                                        D.USING_ASSEMBLY_ITEM_ID,
                                                        DECODE(D.SOURCE_ORGANIZATION_ID,
                                                        -23453, null,
                                                        D.SOURCE_ORGANIZATION_ID),
                                                        l_item_to_use,
                                                        p_organization_id,
                                                        p_instance_id,
                                                        decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                        decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                                6, decode(d.source_organization_id,
                                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                      2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),  l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),  l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                                30, decode(d.source_organization_id,
                                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),  l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),  l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),  l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                                DECODE(D.DEMAND_CLASS, null, null,
                                                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        null, null, l_item_to_use, p_organization_id,
                                                                                        p_instance_id, /*c.prior_date,*/ TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                                                                                2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                                                                                   DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),  l_level_id, D.DEMAND_CLASS),
                                                                                        D.DEMAND_CLASS))),
                                                        TEMP.DEMAND_CLASS,
                                                        l_level_id))    col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                                -- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id in disposition_name column
                                DECODE(D.ORIGINATION_TYPE,
                                1, to_char(D.DISPOSITION_ID),
                                D.ORDER_NUMBER)                         col14, -- disposition_name
                                TEMP.DEMAND_CLASS                       col15, -- demand_class
                                l_uom_code                              col16, -- UOM Code
                                l_item_name_to_use                      col17, -- Item name --Bug 3823042
                                --l_inv_item_name                         col17, -- Item name
                                l_org_code                              col18, -- Org code
                                TEMP.PRIORITY                           col19, -- sysdate priroty
                                TEMP.ALLOCATION_PERCENT                 col20,  -- sysdate allocation percent
                                MTPS.LOCATION                           col21, --bug3263368
                                MTP.PARTNER_NAME                        col22, --bug3263368
                                D.DEMAND_CLASS                          col23, --bug3263368
                                DECODE(D.ORDER_DATE_TYPE_CODE,2,
                                D.REQUEST_DATE,D.REQUEST_SHIP_DATE)     col24 --bug3263368

                        FROM
                                MSC_DEMANDS             D,
                                --Bug 3823042, donot use msc_calendar_dates
                                --MSC_CALENDAR_DATES      C,
                                MSC_ALLOC_TEMP          TEMP,
                                MSC_TRADING_PARTNERS    MTP, --bug3263368
                                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
                        WHERE
                                D.PLAN_ID = p_plan_id
                                AND D.SR_INSTANCE_ID = p_instance_id
                                AND D.INVENTORY_ITEM_ID = l_item_to_use -- Bug 3823042
                                AND D.ORGANIZATION_ID = p_organization_id
                                --AND D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31)
                                AND D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- Ignore copy SO
                                AND D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
                                AND D.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
                                --Bug 3823042
                                /*
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN
                                        -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                                        -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                                        TRUNC(DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                                        AND
                                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                              DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                                AND (( D.ORIGINATION_TYPE = 4
                                        AND C.SEQ_NUM IS NOT NULL) OR
                                        ( D.ORIGINATION_TYPE  <> 4))
                                AND C.PRIOR_DATE < NVL(p_infinite_time_fence_date, C.PRIOR_DATE + 1)
                                */
                                -- Bug 3823042, donot use msc_calendar_dates
                                AND   TRUNC(DECODE(RECORD_SOURCE,
                                            2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                   NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) < TRUNC(p_infinite_time_fence_date) -- Bug 3823042, pitf is not NULL in PDS case
                                -- bug 2763784 (ssurendr)
                                -- Should not select supply/demand where the original quantity itself is 0
                                AND (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) <> 0 -- Bug 3823042 , donot care about repetitive demands
                        UNION ALL
                        SELECT  p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                S.TRANSACTION_ID                        col6, -- Identifier3
                                2                                       col7, -- supply_demand_type
                                -- Bug 3823042, donot use calendar_dates
                                --C.NEXT_DATE                             col8, -- supply_demand_date
                                GREATEST(TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)),l_sys_next_date) col8,
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)           col9, -- supply_demand_source_quantity
                                S.ORDER_TYPE                            col10, -- supply_demand_source_type
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)
                                        * DECODE(DECODE(S.DEMAND_CLASS, null, null,
                                                     DECODE(TEMP.DEMAND_CLASS,'-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          null,
                                                          null,
                                                          l_item_to_use,
                                                          p_organization_id,
                                                          p_instance_id,
                                                          --C.NEXT_DATE,
                                                          -- Bug 3823042
                                                          TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)),
                                                          l_level_id,
                                                          S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                                       TEMP.DEMAND_CLASS,
                                                        1,
                                                 NULL,
                                                        NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.DEMAND_CLASS,
                                                        -- Bug 3823042
                                                        --c.next_date,
                                                        TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE))),
                                                         1),
                                                DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.DEMAND_CLASS,
                                                        -- Bug 3823042
                                                        --c.next_date,
                                                        TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE))),
                                                        NULL, 1, 0)
                                                )                       col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                             -- Bug 2771075. For Planned Orders, we will populate transaction_id
                             -- in the disposition_name column to be consistent with Planning.
                                DECODE(S.ORDER_TYPE,
                                        5, to_char(S.TRANSACTION_ID),
                                        S.ORDER_NUMBER)                 col14, -- disposition_name
                                TEMP.DEMAND_CLASS                       col15, -- demand_class
                                l_uom_code                              col16, -- UOM Code
                                l_item_name_to_use                      col17, -- Item Name --Bug 3823042
                                --l_inv_item_name                         col17, -- Item name
                                l_org_code                              col18, -- Org code
                                TEMP.PRIORITY                           col19, -- sysdate priroty
                                TEMP.ALLOCATION_PERCENT                 col20, -- sysdate allocation percent
                                l_null_char                             col21, --bug3263368 ORIG_CUSTOMER_SITE_NAME --Bug 3875786
                                l_null_char                             col22, --bug3263368 ORIG_CUSTOMER_NAME --Bug 3875786
                                l_null_char                             col23, --bug3263368 ORIG_DEMAND_CLASS --Bug 3875786
                                l_null_date                             col24  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - null removed
                        FROM
                                -- Bug 3823042
                                --MSC_CALENDAR_DATES      C,
                                MSC_SUPPLIES            S,
                                MSC_ALLOC_TEMP          TEMP
                        WHERE
                                S.PLAN_ID = p_plan_id
                                AND S.SR_INSTANCE_ID = p_instance_id
                                AND S.INVENTORY_ITEM_ID = l_item_to_use -- Bug 3823042
                                AND S.ORGANIZATION_ID = p_organization_id
                                AND NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
                                AND NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
                                /*
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                                        AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                                AND DECODE(S.LAST_UNIT_COMPLETION_DATE, NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                                AND C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE), 28, TRUNC(SYSDATE), C.NEXT_DATE)
                                AND C.NEXT_DATE < NVL(p_infinite_time_fence_date, C.NEXT_DATE + 1)
                                */
                                AND     TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) >=  -- Bug 3823042, Using TRUNC's wherever required
                                            TRUNC(DECODE(S.ORDER_TYPE, 27,SYSDATE,
                                                                 28, SYSDATE,
                                                                 NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)))
                                AND     TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) < TRUNC(p_infinite_time_fence_date) -- Bug 3823042
                        );
                        l_insert_count := SQL%ROWCOUNT;

                   ELSE  -- Else of Optimized plan
                        -- Bug 3823042: Unoptimized Plan, Use msc_calendar_dates

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'User defined demand class, Unoptimized plan');
                        END IF;

                        INSERT INTO MRP_ATP_DETAILS_TEMP
                        (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                        supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                        allocated_quantity, record_type, scenario_id, disposition_name, demand_class, uom_code,
                        inventory_item_name, organization_code, identifier2, identifier4,
                        ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE ) --bug3263368
                        SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                        col11, col12, col13, col14, col15, col16, col17, col18, col19, col20,col21,col22,col23,col24
                        FROM
                        (SELECT p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                D.DEMAND_ID                             col6, -- Identifier3
                                1                                       col7, -- supply_demand_type
                                GREATEST(C.CALENDAR_DATE,l_sys_next_date) col8, -- supply_demand_date
                                --C.PRIOR_DATE                            col8, -- supply_demand_date
                                -1 * DECODE(D.ORIGINATION_TYPE,
                                        4, D.DAILY_DEMAND_RATE,
                                        (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))   col9, -- supply_demand_quantity
                                decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE)                      col10, -- supply_demand_source_type
                                -1* DECODE(D.ORIGINATION_TYPE,
                                        4, D.DAILY_DEMAND_RATE,
                                        (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))*
                                        DECODE(decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                6, decode(d.source_organization_id,
                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)), NULL),
                                                30, decode(d.source_organization_id,
                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)),
                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                        D.DEMAND_CLASS)), NULL),
                                                DECODE(D.DEMAND_CLASS, null, null,
                                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        null, null, l_item_to_use, p_organization_id,
                                                                        p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                D.DEMAND_CLASS))),
                                                TEMP.DEMAND_CLASS, 1,
                                                MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                                        D.DEMAND_ID,
                                                        C.CALENDAR_DATE,
                                                        D.USING_ASSEMBLY_ITEM_ID,
                                                        DECODE(D.SOURCE_ORGANIZATION_ID,
                                                        -23453, null,
                                                        D.SOURCE_ORGANIZATION_ID),
                                                        l_item_to_use,
                                                        p_organization_id,
                                                        p_instance_id,
                                                        decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                        decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                                6, decode(d.source_organization_id,
                                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                                30, decode(d.source_organization_id,
                                                                        NULL, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        -23453, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)),
                                                                        d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                                null, null, l_item_to_use, p_organization_id,
                                                                                                p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                                D.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                                DECODE(D.DEMAND_CLASS, null, null,
                                                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        null, null, l_item_to_use, p_organization_id,
                                                                                        p_instance_id, C.CALENDAR_DATE, l_level_id, D.DEMAND_CLASS),
                                                                                        D.DEMAND_CLASS))),
                                                        TEMP.DEMAND_CLASS,
                                                        l_level_id))    col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                                -- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id in disposition_name column
                                DECODE(D.ORIGINATION_TYPE,
                                1, to_char(D.DISPOSITION_ID),
                                D.ORDER_NUMBER)                         col14, -- disposition_name
                                TEMP.DEMAND_CLASS                       col15, -- demand_class
                                l_uom_code                              col16, -- UOM Code
                                l_item_name_to_use                      col17, -- Item Name --Bug 3823042
                                --l_inv_item_name                         col17, -- Item name
                                l_org_code                              col18, -- Org code
                                TEMP.PRIORITY                           col19, -- sysdate priroty
                                TEMP.ALLOCATION_PERCENT                 col20,  -- sysdate allocation percent
                                MTPS.LOCATION                           col21, --bug3263368
                                MTP.PARTNER_NAME                        col22, --bug3263368
                                D.DEMAND_CLASS                          col23, --bug3263368
                                DECODE(D.ORDER_DATE_TYPE_CODE,2,
                                D.REQUEST_DATE,D.REQUEST_SHIP_DATE)     col24 --bug3263368

                        FROM
                                MSC_DEMANDS             D,
                                MSC_CALENDAR_DATES      C,
                                MSC_ALLOC_TEMP          TEMP,
                                MSC_TRADING_PARTNERS    MTP, --bug3263368
                                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
                        WHERE
                                D.PLAN_ID = p_plan_id
                                AND D.SR_INSTANCE_ID = p_instance_id
                                AND D.INVENTORY_ITEM_ID = l_item_to_use -- Bug 3823042
                                AND D.ORGANIZATION_ID = p_organization_id
                                --AND D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31)
                                AND D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- Ignore copy SO
                                AND D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
                                AND D.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN
                                        -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                                        -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                                        TRUNC(DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                                        AND
                                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                              DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                                AND (( D.ORIGINATION_TYPE = 4
                                        AND C.SEQ_NUM IS NOT NULL) OR
                                        ( D.ORIGINATION_TYPE  <> 4))
                                AND C.CALENDAR_DATE <  TRUNC(p_infinite_time_fence_date) -- Bug 3823042
                                -- bug 2763784 (ssurendr)
                                -- Should not select supply/demand where the original quantity itself is 0
                                AND DECODE(D.ORIGINATION_TYPE, 4, D.DAILY_DEMAND_RATE,
                                           (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))) <> 0
                        UNION ALL
                        SELECT  p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                S.TRANSACTION_ID                        col6, -- Identifier3
                                2                                       col7, -- supply_demand_type
                                GREATEST(C.CALENDAR_DATE,l_sys_next_date) col8, -- supply_demand_date
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)           col9, -- supply_demand_source_quantity
                                S.ORDER_TYPE                            col10, -- supply_demand_source_type
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)
                                        * DECODE(DECODE(S.DEMAND_CLASS, null, null,
                                                     DECODE(TEMP.DEMAND_CLASS,'-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          null,
                                                          null,
                                                          l_item_to_use,
                                                          p_organization_id,
                                                          p_instance_id,
                                                          C.CALENDAR_DATE,
                                                          l_level_id,
                                                          S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                                TEMP.DEMAND_CLASS,
                                                        1,
                                                NULL,
                                                        NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.DEMAND_CLASS,
                                                        c.calendar_date), 1),
                                                DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.DEMAND_CLASS,
                                                        C.CALENDAR_DATE),
                                                        NULL, 1, 0)
                                                )                       col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                             -- Bug 2771075. For Planned Orders, we will populate transaction_id
                             -- in the disposition_name column to be consistent with Planning.
                                DECODE(S.ORDER_TYPE,
                                        5, to_char(S.TRANSACTION_ID),
                                        S.ORDER_NUMBER)                 col14, -- disposition_name
                                TEMP.DEMAND_CLASS                       col15, -- demand_class
                                l_uom_code                              col16, -- UOM Code
                                l_item_name_to_use                      col17, -- Item name --Bug 3823042
                                --l_inv_item_name                         col17, -- Item name
                                l_org_code                              col18, -- Org code
                                TEMP.PRIORITY                           col19, -- sysdate priroty
                                TEMP.ALLOCATION_PERCENT                 col20, -- sysdate allocation percent
                                l_null_char                             col21, --bug3263368 ORIG_CUSTOMER_SITE_NAME --Bug 3875786
                                l_null_char                             col22, --bug3263368 ORIG_CUSTOMER_NAME --Bug 3875786
                                l_null_char                             col23, --bug3263368 ORIG_DEMAND_CLASS --Bug 3875786
                                l_null_date                             col24  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - null removed
                        FROM
                                MSC_CALENDAR_DATES      C,
                                MSC_SUPPLIES            S,
                                MSC_ALLOC_TEMP          TEMP
                        WHERE
                                S.PLAN_ID = p_plan_id
                                AND S.SR_INSTANCE_ID = p_instance_id
                                AND S.INVENTORY_ITEM_ID = l_item_to_use
                                AND S.ORGANIZATION_ID = p_organization_id
                                AND NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
                                AND NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                                        AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                                AND DECODE(S.LAST_UNIT_COMPLETION_DATE, NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                                -- Bug 3823042, Using TRUNC's wherever required
                                AND C.CALENDAR_DATE >= TRUNC(DECODE(S.ORDER_TYPE, 27, SYSDATE, 28, SYSDATE, C.CALENDAR_DATE))
                                AND C.CALENDAR_DATE < TRUNC(p_infinite_time_fence_date) -- Bug 3823042
                        );
                        l_insert_count := SQL%ROWCOUNT;

                   END IF;
                END IF;

                IF (l_insert_count = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'No s/d records could be inserted from msc_supplies/demands tables into temp table');
                        END IF;

                        -- bug 2763784 (ssurendr)
                        -- Should not error out if no s/d record found
                        --Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        --x_return_status := FND_API.G_RET_STS_ERROR;
                        --return;
                        SELECT demand_class
                        BULK   COLLECT INTO l_dc_list_tab
                        FROM   MSC_ALLOC_TEMP;

                        l_dc_list_tab.Extend();
                        l_dc_list_tab(l_dc_list_tab.COUNT) := G_UNALLOCATED_DC;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'l_dc_list_tab.COUNT: ' || l_dc_list_tab.COUNT);
                        END IF;
                ELSE

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After copying supply/demand records from msc_supplies/msc_demands into temp tables.');
                        END IF;

                        /* Bulk Collect Allocated Supply, Total Supply,
                        Allocated Demand, Stolen Demand, Total Demand, Net into PL/SQL Period table. */
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before selecting supply/demand records from temp table into PL/SQL period table.');
                        END IF;

                        -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                                -- here was the same query without the unallocated columns
                                -- always get unallocated figures
                                -- removed for bug 2763784 (ssurendr)
                        -- ELSE
                                -- Get unallocated picture as well.

                        -- time_phased_atp changes begin
                        IF l_time_phased_atp = 'Y' THEN
                                MSC_ATP_PF.Get_Period_From_Details_Temp(
                                        MSC_ATP_PF.User_Defined_DC,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_scenario_id,
                                        l_level_id,
                                        l_record_type,
                                        p_session_id,
                                        x_atp_period,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Get_Period_From_Details_Temp');
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;
                        -- time_phased_atp changes end
                        ELSE
                                SELECT
                                        final.col1,
                                        final.col2,
                                        final.col3,
                                        final.col4,
                                        final.col5,
                                        null,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_scenario_id,
                                        l_level_id,
                                        null,
                                        0,
                                        0,
                                        final.col6,
                                        final.col7,
                                        final.col8,
                                        null, -- bug 3282426
                                        final.col9,
                                        final.col10
                                BULK COLLECT INTO
                                        x_atp_period.Demand_Class,
                                        x_atp_period.Period_Start_Date,
                                        x_atp_period.Total_Supply_Quantity,
                                        x_atp_period.Total_Demand_Quantity,
                                        --x_atp_period.Total_Bucketed_Demand_Quantity, --time_phased_atp /*Bug 3263304*/
                                        x_atp_period.Period_Quantity,
                                        x_atp_period.Total_Bucketed_Demand_Quantity, --time_phased_atp /*Bug 3263304*/
                                        x_atp_period.Inventory_Item_Id,
                                        x_atp_period.Organization_Id,
                                        x_atp_period.Identifier1,
                                        x_atp_period.Scenario_Id,
                                        x_atp_period.Level,
                                        x_atp_period.Period_End_Date,
                                        x_atp_period.Cumulative_Quantity,
                                        x_atp_period.Demand_Adjustment_Quantity,
                                        x_atp_period.Identifier2,
                                        x_atp_period.Unallocated_Supply_Quantity,
                                        x_atp_period.Unallocated_Demand_Quantity,
                                        x_atp_period.Unalloc_Bucketed_Demand_Qty, -- bug 3282426
                                        x_atp_period.Unallocated_Net_Quantity,
                                        x_atp_period.Identifier4
                                FROM
                                (SELECT DEMAND_CLASS                                                    col1,
                                        SUPPLY_DEMAND_DATE                                              col2,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2, ALLOCATED_QUANTITY, 0))       col3,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 1, ALLOCATED_QUANTITY, 0))       col4,
                                        SUM(ALLOCATED_QUANTITY)                                         col5,
                                        IDENTIFIER2                                                     col6,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2, SUPPLY_DEMAND_QUANTITY, 0))   col7,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 1, SUPPLY_DEMAND_QUANTITY, 0))   col8,
                                        SUM(SUPPLY_DEMAND_QUANTITY)                                     col9,
                                        IDENTIFIER4                                                     col10
                                FROM    MRP_ATP_DETAILS_TEMP
                                WHERE   SESSION_ID = p_session_id
                                AND     RECORD_TYPE = l_record_type
                                GROUP BY DEMAND_CLASS, SUPPLY_DEMAND_DATE,
                                        IDENTIFIER2, IDENTIFIER4
                                ORDER BY IDENTIFIER2 ASC, -- Priority
                                        IDENTIFIER4 DESC, -- Allocation percent
                                        DEMAND_CLASS ASC, SUPPLY_DEMAND_DATE) final;
                        END IF;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After selecting supply/demand records from temp table into PL/SQL period table.');
                        END IF;

                        -- Call Adjust_Allocation_Details to compute everything except Infinite time fence records
                        Adjust_Allocation_Details(x_atp_period, l_dc_list_tab, l_dc_start_index, l_dc_end_index, l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Adjust_Allocation_Details');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF;


                /* Compute Period_End_Date for all demand classes and add infinite time fence records*/
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before computing period_end_date');
                END IF;
                FOR l_index_counter IN 1..l_dc_list_tab.COUNT LOOP
                        -- bug 2763784 (ssurendr)
                        -- Should not error out if no s/d record found
                        IF l_dc_start_index IS NOT NULL
                            AND l_dc_start_index.COUNT>0 THEN
                                l_start_index   := l_dc_start_index(l_index_counter);
                                l_end_index     := l_dc_end_index(l_index_counter);

                                -- Find Period End Date for all demand class records
                                FOR l_period_counter IN l_start_index..l_end_index LOOP
                                        IF (l_period_counter = l_end_index) THEN
                                                /*IF (p_infinite_time_fence_date IS NOT NULL) THEN
                                                        x_atp_period.Period_End_Date(l_period_counter) := p_infinite_time_fence_date - 1;
                                                ELSE
                                                        x_atp_period.Period_End_Date(l_period_counter) := x_atp_period.Period_Start_Date(l_period_counter);
                                                END IF;*/
                                                -- Bug 3823042
                                                x_atp_period.Period_End_Date(l_period_counter) := p_infinite_time_fence_date - 1;
                                        ELSE
                                                x_atp_period.Period_End_Date(l_period_counter) := x_atp_period.Period_Start_Date(l_period_counter + 1) - 1;
                                        END IF;
                                END LOOP;
                        END IF;

                        -- Add Inifinite time fence date records for each demand class at the end.
                        -- Bug 3823042, as in PDS, p_infinite_time_fence_date is never NULL
                        -- IF p_infinite_time_fence_date IS NOT NULL THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Adding infinite time fence date for demand class '|| l_dc_list_tab(l_index_counter));
                                END IF;

                                MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);
                                l_count := x_atp_period.Period_Start_Date.COUNT;

                                x_atp_period.Demand_Class(l_count) := l_dc_list_tab(l_index_counter);
                                x_atp_period.Period_Start_Date(l_count) := p_infinite_time_fence_date;
                                x_atp_period.Total_Supply_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Total_Demand_Quantity(l_count) := 0;
                                x_atp_period.Total_Bucketed_Demand_Quantity(l_count) := 0; -- for time_phased_atp
                                x_atp_period.Period_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Period_End_Date(l_count) := p_infinite_time_fence_date;
                                x_atp_period.Cumulative_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Inventory_Item_Id(l_count) := p_inventory_item_id;
                                x_atp_period.Organization_Id(l_count) := p_organization_id;
                                x_atp_period.Identifier1(l_count) := p_instance_id;
                                x_atp_period.Scenario_Id(l_count) := l_scenario_id;
                                x_atp_period.Level(l_count) := l_level_id;
                                x_atp_period.Backward_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Demand_Adjustment_Quantity(l_count) := 0;
                                x_atp_period.Adjusted_Availability_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;

                                IF G_ATP_FW_CONSUME_METHOD = 2 THEN
                                        x_atp_period.Adjusted_Cum_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                END IF;
                      --END IF;

                END LOOP;
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After computing period_end_date and appending infinite time fence records');
                END IF;

        ELSIF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 2 AND MSC_ATP_PVT.G_ALLOCATION_METHOD = 2) THEN
                -- ELSIF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND MSC_ATP_PVT.G_ALLOCATION_METHOD = 2) THEN

                -- initialize l_level_id. We first select all leaf node records
                l_level_id      := 3;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'We are in customer class allocation.');
                END IF;

                /* Modularize Item and Org Info */
                MSC_ATP_PROC.get_global_org_info(p_instance_id, p_organization_id);
                l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
                l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
                l_calendar_exception_set_id := MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
                l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
                l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;

                -- Bug 3823042
                l_sys_next_date := MSC_CALENDAR.NEXT_WORK_DAY(
                                    l_calendar_code,
                                    p_instance_id,
                                    TRUNC(sysdate));

                -- Debug info
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_default_atp_rule_id='|| l_default_atp_rule_id);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_calendar_code='||l_calendar_code);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_default_demand_class'|| l_default_demand_class);
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'l_org_code'|| l_org_code);
                END IF;

                /* 1. Find all the level 3 nodes for given item/inst/org/on p_request_date
                   2. For each level 3 record, find parent demand class and grandparent demand class
                   3. Store all these in 8i temp table msc_alloc_hierarchy_temp.
                   4. Also store the partner_id, partner_site_id and priority of level 3 demand classes*/

                INSERT INTO MSC_ALLOC_HIERARCHY_TEMP( LEVEL_3_DEMAND_CLASS,
                LEVEL_2_DEMAND_CLASS, LEVEL_1_DEMAND_CLASS, PARTNER_ID, PARTNER_SITE_ID,
                LEVEL_3_DEMAND_CLASS_PRIORITY, ALLOCATION_PERCENT, CUSTOMER_NAME, CUSTOMER_SITE_NAME)
                SELECT A.demand_class, B.demand_class, A.class, A.partner_id,
                       A.partner_site_id, A.priority, A.allocation_percent, mtp.partner_name, mtps.location
                FROM   msc_item_hierarchy_mv A, msc_item_hierarchy_mv B,
                       msc_trading_partners mtp, msc_trading_partner_sites mtps
                WHERE  A.inventory_item_id = l_item_to_use
                AND    A.organization_id = p_organization_id
                AND    A.sr_instance_id = p_instance_id
                AND    p_request_date BETWEEN A.effective_date AND A.disable_date
                AND    A.level_id = 3
                AND    B.inventory_item_id = A.inventory_item_id
                AND    B.organization_id = A.organization_id
                AND    B.sr_instance_id = A.sr_instance_id
                AND    p_request_date BETWEEN B.effective_date AND B.disable_date
                AND    B.level_id = 2
                AND    B.class = A.class
                AND    B.partner_id = A.partner_id
                AND    A.partner_id = mtp.partner_id (+)
                AND    A.partner_site_id = mtps.partner_site_id (+);

                IF (SQL%ROWCOUNT = 0) THEN
                        -- Need an appropriate error message.
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'No Demand Class found');
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;


                /*
                1. Copy the supply demand records from msc_supplies and msc_demands
                   into mrp_atp_details_temp in case of Customer Class Allocated ATP.
                2. Forward consumtion logic is such that individual stealing acts cannot be recorded,
                   therefore, we do not select from_demand_class.
                   But we select partner_id and partner_site_id, class and demand_class.
                3. Finally we put only those records where allocated_quantity <> 0
                */


                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before copying supply/demand records from msc_supplies/msc_demands into temp tables.');
                END IF;

                /* time_phased_atp changes begin */
                IF l_time_phased_atp = 'Y' THEN
                        MSC_ATP_PF.Insert_SD_Into_Details_Temp(
                                MSC_ATP_PF.User_Defined_CC,
                                l_inv_item_id,
                                l_pf_dest_id,
                                p_inventory_item_id,
                                l_pf_sr_id,
                                p_organization_id,
                                --bug3671294 now we donot need this as we will join with msc_system_items
                                --l_inv_item_name,
                                l_org_code,
                                p_instance_id,
                                p_plan_id,
                                p_infinite_time_fence_date,
                                l_level_id,
                                p_session_id,
                                l_record_type,
                                l_scenario_id,
                                l_uom_code,
                                l_insert_count,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Insert_SD_Into_Details_Temp');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                ELSE
                     IF (MSC_ATP_PVT.G_OPTIMIZED_PLAN = 1) THEN
                        -- Bug 3823042: optimized plan, donot use msc_calendar_dates

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'User defined customer class, Optimized plan');
                        END IF;

                        INSERT INTO MRP_ATP_DETAILS_TEMP
                        (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                        supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                        allocated_quantity, record_type, scenario_id, disposition_name, demand_class, class, customer_id,
                        customer_site_id, uom_code, inventory_item_name, organization_code, identifier2, identifier4,
                        Customer_Name, Customer_Site_Name,
                        ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE ) --bug3263368
                        SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                        col11, col12, col13, col14, col15, col16, col17, col18, col19, col20, col21,
                        col22, col23, col24, col25,col26, col27, col28, col29
                        FROM
                        (SELECT p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                D.DEMAND_ID                             col6, -- Identifier3
                                1                                       col7, -- supply_demand_type
                                -- Bug 3823042
                                --C.PRIOR_DATE                            col8, -- supply_demand_date
                                GREATEST(
                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), l_sys_next_date) col8,
                                -1 * (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))       col9, -- supply_demand_quantity  -- Bug 3823042
                                decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE)                      col10, -- supply_demand_source_type -- Bug 3823042
                                -1* (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) *
                                        DECODE(DECODE(D.CUSTOMER_ID, NULL, NULL,
                                                0, NULL,
                                                decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                        6, decode(d.source_organization_id,
                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                        l_level_id, NULL),
                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                        l_level_id, NULL),
                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                        l_level_id, NULL),
                                                                NULL),
                                                        30, decode(d.source_organization_id,
                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                        l_level_id, NULL),
                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                              	     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                        l_level_id, NULL),
                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                        l_level_id, NULL),
                                                                NULL),
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                                                l_item_to_use, p_organization_id, p_instance_id, /*c.prior_date*/
                                                                TRUNC(DECODE(D.RECORD_SOURCE,
                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                l_level_id, NULL))),
                                                TEMP.LEVEL_3_DEMAND_CLASS, 1,
                                                MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                                        D.DEMAND_ID,
                                                        --c.prior_date,
                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                        D.USING_ASSEMBLY_ITEM_ID,
                                                        DECODE(D.SOURCE_ORGANIZATION_ID,
                                                        -23453, null,
                                                        D.SOURCE_ORGANIZATION_ID),
                                                        l_item_to_use,
                                                        p_organization_id,
                                                        p_instance_id,
                                                        decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                        DECODE(D.CUSTOMER_ID, NULL, TEMP.LEVEL_3_DEMAND_CLASS,
                                                                0, TEMP.LEVEL_3_DEMAND_CLASS,
                                                                decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                                        6, decode(d.source_organization_id,
                                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                        l_level_id, NULL),
                                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                        l_level_id, NULL),
                                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                        l_level_id, NULL),
                                                                                TEMP.LEVEL_3_DEMAND_CLASS),
                                                                        30, decode(d.source_organization_id,
                                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                        l_level_id, NULL),
                                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                        l_level_id, NULL),
                                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                        TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                              DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                                     2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                        l_level_id, NULL),
                                                                                TEMP.LEVEL_3_DEMAND_CLASS),
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                                                                l_item_to_use, p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                TRUNC(DECODE(D.RECORD_SOURCE,
                                                                                      2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                      DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                                             2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                                             NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                                l_level_id, NULL))),
                                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                        l_level_id))    col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                                -- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id in disposition_name column
                                DECODE(D.ORIGINATION_TYPE,
                                1, to_char(D.DISPOSITION_ID),
                                D.ORDER_NUMBER)                         col14, -- disposition_name
                                TEMP.LEVEL_3_DEMAND_CLASS               col15, -- demand_class
                                TEMP.LEVEL_1_DEMAND_CLASS               col16, -- class
                                TEMP.PARTNER_ID                         col17, -- partner_id
                                TEMP.PARTNER_SITE_ID                    col18, -- partner_site_id
                                l_uom_code                              col19, -- UOM Code
                                l_item_name_to_use                      col20, -- Item name --Bug 3823042
                                --l_inv_item_name                         col20, -- Item name
                                l_org_code                              col21, -- Org code
                                TEMP.LEVEL_3_DEMAND_CLASS_PRIORITY      col22, -- Level 3 priority
                                TEMP.ALLOCATION_PERCENT                 col23, -- Sysdate allocation percent
                                TEMP.customer_name                      col24, -- Customer Name
                                TEMP.customer_site_name                 col25, -- Customer Site Name
                                MTPS.LOCATION                           col26, --bug3263368
                                MTP.PARTNER_NAME                        col27, --bug3263368
                                D.DEMAND_CLASS                          col28, --bug3263368
                                DECODE(D.ORDER_DATE_TYPE_CODE,2,
                                D.REQUEST_DATE,D.REQUEST_SHIP_DATE)     col29 --bug3263368
                        FROM
                                MSC_DEMANDS             D,
                                -- Bug 3823042
                                --MSC_CALENDAR_DATES      C,
                                MSC_ALLOC_HIERARCHY_TEMP TEMP,
                                MSC_TRADING_PARTNERS    MTP,--bug3263368
                                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368

                        WHERE
                                D.PLAN_ID = p_plan_id
                                AND D.SR_INSTANCE_ID = p_instance_id
                                AND D.INVENTORY_ITEM_ID = l_item_to_use
                                AND D.ORGANIZATION_ID = p_organization_id
                                AND D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
                                AND D.CUSTOMER_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
                                AND D.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
                                -- Bug 3823042
                                /*
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN
                                        -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                                        -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                                        TRUNC(DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                                        AND
                                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                              DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                                AND (( D.ORIGINATION_TYPE = 4
                                        AND C.SEQ_NUM IS NOT NULL) OR
                                        ( D.ORIGINATION_TYPE  <> 4))
                                AND C.PRIOR_DATE < NVL(p_infinite_time_fence_date, C.PRIOR_DATE + 1)
                                */
                                AND   TRUNC(DECODE(RECORD_SOURCE,
                                            2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                   NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) < TRUNC(p_infinite_time_fence_date)
                                -- bug 2763784 (ssurendr)
                                -- Should not select supply/demand where the original quantity itself is 0
                                AND (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) <> 0 -- Bug 3823042, donot care about repititive demands
                        UNION ALL
                        SELECT  p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                S.TRANSACTION_ID                        col6, -- Identifier3
                                2                                       col7, -- supply_demand_type
                                -- Bug 3823042
                                --C.NEXT_DATE                             col8, -- supply_demand_date
                                GREATEST(TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)),l_sys_next_date) col8,
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)           col9, -- supply_demand_source_quantity
                                S.ORDER_TYPE                            col10, -- supply_demand_source_type
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)
                                        * DECODE(DECODE(S.CUSTOMER_ID, NULL, NULL,
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          S.CUSTOMER_ID,
                                                          S.SHIP_TO_SITE_ID,
                                                          l_item_to_use,
                                                          p_organization_id,
                                                          p_instance_id,
                                                          --C.NEXT_DATE,
                                                          TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)),
                                                          l_level_id,
                                                          NULL)),
                                                TEMP.LEVEL_3_DEMAND_CLASS,
                                                        1,
                                                NULL,
                                                        NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                        --c.next_date),
                                                        TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE))),
                                                         1),
                                                DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                        --c.next_date),
                                                        TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE))),
                                                        NULL, 1, 0)
                                                )                       col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                             -- Bug 2771075. For Planned Orders, we will populate transaction_id
                             -- in the disposition_name column to be consistent with Planning.
                                DECODE(S.ORDER_TYPE,
                                        5, to_char(S.TRANSACTION_ID),
                                        S.ORDER_NUMBER)                 col14, -- disposition_name
                                TEMP.LEVEL_3_DEMAND_CLASS               col15, -- demand_class
                                TEMP.LEVEL_1_DEMAND_CLASS               col16, -- class
                                TEMP.PARTNER_ID                         col17, -- partner_id
                                TEMP.PARTNER_SITE_ID                    col18, -- partner_site_id
                                l_uom_code                              col19, -- UOM Code
                                l_item_name_to_use                      col20, -- Item name --Bug 3823042
                                --l_inv_item_name                         col20, -- Item name
                                l_org_code                              col21, -- Org code
                                TEMP.LEVEL_3_DEMAND_CLASS_PRIORITY      col22, -- Level 3 priority
                                TEMP.ALLOCATION_PERCENT                 col23, -- Sysdate allocation percent
                                TEMP.customer_name                      col24, -- Customer Name
                                TEMP.customer_site_name                 col25, -- Customer Site Name
                                l_null_char                                    col26, --bug3263368 ORIG_CUSTOMER_SITE_NAME --Bug 3875786
                                l_null_char                                    col27, --bug3263368 ORIG_CUSTOMER_NAME --Bug 3875786
                                l_null_char                                    col28, --bug3263368 ORIG_DEMAND_CLASS --Bug 3875786
                                l_null_date                             COL29  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - null removed
                        FROM
                                -- Bug 3823042
                                --MSC_CALENDAR_DATES      C,
                                MSC_SUPPLIES            S,
                                MSC_ALLOC_HIERARCHY_TEMP TEMP
                        WHERE
                                S.PLAN_ID = p_plan_id
                                AND S.SR_INSTANCE_ID = p_instance_id
                                AND S.INVENTORY_ITEM_ID = l_item_to_use
                                AND S.ORGANIZATION_ID = p_organization_id
                                AND NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
                                AND NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
                                /*
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                                        AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                                AND DECODE(S.LAST_UNIT_COMPLETION_DATE, NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                                AND C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE), 28, TRUNC(SYSDATE), C.NEXT_DATE)
                                AND C.NEXT_DATE < NVL(p_infinite_time_fence_date, C.NEXT_DATE + 1)
                                */
                                -- Bug 3823042, Using TRUNC's wherever required
                                AND     TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) >=
                                            TRUNC(DECODE(S.ORDER_TYPE, 27,SYSDATE,
                                                                 28, SYSDATE,
                                                                 NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)))
                               AND     TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) < TRUNC(p_infinite_time_fence_date) -- Bug 3823042
                        );
                        l_insert_count := SQL%ROWCOUNT;

                    ELSE -- Else of Optimized Plan
                        -- Bug 3823042: Unoptimized plan

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'User defined customer class, Unoptimized plan');
                        END IF;

                        INSERT INTO MRP_ATP_DETAILS_TEMP
                        (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                        supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                        allocated_quantity, record_type, scenario_id, disposition_name, demand_class, class, customer_id,
                        customer_site_id, uom_code, inventory_item_name, organization_code, identifier2, identifier4,
                        Customer_Name, Customer_Site_Name,
                        ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE ) --bug3263368
                        SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                        col11, col12, col13, col14, col15, col16, col17, col18, col19, col20, col21,
                        col22, col23, col24, col25,col26, col27, col28, col29
                        FROM
                        (SELECT p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                D.DEMAND_ID                             col6, -- Identifier3
                                1                                       col7, -- supply_demand_type
                                --C.PRIOR_DATE                            col8, -- supply_demand_date
                                GREATEST(C.CALENDAR_DATE,l_sys_next_date) col8, -- Supply_demand_date
                                -1 * DECODE(D.ORIGINATION_TYPE,
                                        4, D.DAILY_DEMAND_RATE,
                                        (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))   col9, -- supply_demand_quantity
                                decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE)                      col10, -- supply_demand_source_type
                                -1* DECODE(D.ORIGINATION_TYPE,
                                        4, D.DAILY_DEMAND_RATE,
                                        (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))*
                                        DECODE(DECODE(D.CUSTOMER_ID, NULL, NULL,
                                                0, NULL,
                                                decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                        6, decode(d.source_organization_id,
                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        C.CALENDAR_DATE,
                                                                        l_level_id, NULL),
                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        C.CALENDAR_DATE,
                                                                        l_level_id, NULL),
                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                        C.CALENDAR_DATE,
                                                                        l_level_id, NULL),
                                                                NULL),
                                                        30, decode(d.source_organization_id,
                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        C.CALENDAR_DATE,
                                                                        l_level_id, NULL),
                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        C.CALENDAR_DATE,
                                                                        l_level_id, NULL),
                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                        C.CALENDAR_DATE,
                                                                        l_level_id, NULL),
                                                                NULL),
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                                                l_item_to_use, p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                C.CALENDAR_DATE,
                                                                l_level_id, NULL))),
                                                TEMP.LEVEL_3_DEMAND_CLASS, 1,
                                                MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                                        D.DEMAND_ID,
                                                        --c.prior_date,
                                                        C.CALENDAR_DATE,
                                                        D.USING_ASSEMBLY_ITEM_ID,
                                                        DECODE(D.SOURCE_ORGANIZATION_ID,
                                                        -23453, null,
                                                        D.SOURCE_ORGANIZATION_ID),
                                                        l_item_to_use,
                                                        p_organization_id,
                                                        p_instance_id,
                                                        decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                        DECODE(D.CUSTOMER_ID, NULL, TEMP.LEVEL_3_DEMAND_CLASS,
                                                                0, TEMP.LEVEL_3_DEMAND_CLASS,
                                                                decode(decode(D.ORIGINATION_TYPE,-100,30,D.ORIGINATION_TYPE),
                                                                        6, decode(d.source_organization_id,
                                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                        C.CALENDAR_DATE,
                                                                                        l_level_id, NULL),
                                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        C.CALENDAR_DATE,
                                                                                        l_level_id, NULL),
                                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date, */
                                                                                        C.CALENDAR_DATE,
                                                                                        l_level_id, NULL),
                                                                                TEMP.LEVEL_3_DEMAND_CLASS),
                                                                        30, decode(d.source_organization_id,
                                                                                NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                        C.CALENDAR_DATE,
                                                                                        l_level_id, NULL),
                                                                                -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                        C.CALENDAR_DATE,
                                                                                        l_level_id, NULL),
                                                                                d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                        D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, l_item_to_use,
                                                                                        p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                        C.CALENDAR_DATE,
                                                                                        l_level_id, NULL),
                                                                                TEMP.LEVEL_3_DEMAND_CLASS),
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                                                                l_item_to_use, p_organization_id, p_instance_id, /*c.prior_date,*/
                                                                                C.CALENDAR_DATE,
                                                                                l_level_id, NULL))),
                                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                        l_level_id))    col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                                -- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id in disposition_name column
                                DECODE(D.ORIGINATION_TYPE,
                                1, to_char(D.DISPOSITION_ID),
                                D.ORDER_NUMBER)                         col14, -- disposition_name
                                TEMP.LEVEL_3_DEMAND_CLASS               col15, -- demand_class
                                TEMP.LEVEL_1_DEMAND_CLASS               col16, -- class
                                TEMP.PARTNER_ID                         col17, -- partner_id
                                TEMP.PARTNER_SITE_ID                    col18, -- partner_site_id
                                l_uom_code                              col19, -- UOM Code
                                l_item_name_to_use                      col20, -- Item name --Bug 3823042
                                --l_inv_item_name                         col20, -- Item name
                                l_org_code                              col21, -- Org code
                                TEMP.LEVEL_3_DEMAND_CLASS_PRIORITY      col22, -- Level 3 priority
                                TEMP.ALLOCATION_PERCENT                 col23, -- Sysdate allocation percent
                                TEMP.customer_name                      col24, -- Customer Name
                                TEMP.customer_site_name                 col25,  -- Customer Site Name
                                MTPS.LOCATION                           col26, --bug3263368
                                MTP.PARTNER_NAME                        col27, --bug3263368
                                D.DEMAND_CLASS                          col28, --bug3263368
                                DECODE(D.ORDER_DATE_TYPE_CODE,2,
                                D.REQUEST_DATE,D.REQUEST_SHIP_DATE)     col29 --bug3263368
                        FROM
                                MSC_DEMANDS             D,
                                MSC_CALENDAR_DATES      C,
                                MSC_ALLOC_HIERARCHY_TEMP TEMP,
                                MSC_TRADING_PARTNERS    MTP,--bug3263368
                                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368

                        WHERE
                                D.PLAN_ID = p_plan_id
                                AND D.SR_INSTANCE_ID = p_instance_id
                                AND D.INVENTORY_ITEM_ID = l_item_to_use
                                AND D.ORGANIZATION_ID = p_organization_id
                                AND D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
                                AND D.CUSTOMER_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
                                AND D.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN
                                        -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                                        -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                                        TRUNC(DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                                        AND
                                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                              DECODE(RECORD_SOURCE,
                                              2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                 DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                        2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                           NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                                AND (( D.ORIGINATION_TYPE = 4
                                        AND C.SEQ_NUM IS NOT NULL) OR
                                        ( D.ORIGINATION_TYPE  <> 4))
                                -- Bug 3823042 , prior_date to calendar_date
                                AND C.CALENDAR_DATE < TRUNC(p_infinite_time_fence_date)
                                -- bug 2763784 (ssurendr)
                                -- Should not select supply/demand where the original quantity itself is 0
                                AND DECODE(D.ORIGINATION_TYPE, 4, D.DAILY_DEMAND_RATE,
                                           (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))) <> 0
                        UNION ALL
                        SELECT  p_session_id                            col1, -- session_id
                                l_level_id                              col2, -- level_id
                                p_inventory_item_id                     col3, -- inventory_item_id
                                p_organization_id                       col4, -- organization_id
                                p_instance_id                           col5, -- Identifier1
                                S.TRANSACTION_ID                        col6, -- Identifier3
                                2                                       col7, -- supply_demand_type
                                --C.NEXT_DATE                             col8, -- supply_demand_date
                                GREATEST(C.CALENDAR_DATE,l_sys_next_date) col8, -- supply_demand_date
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)           col9, -- supply_demand_source_quantity
                                S.ORDER_TYPE                            col10, -- supply_demand_source_type
                                NVL(S.FIRM_QUANTITY,
                                        S.NEW_ORDER_QUANTITY)
                                        * DECODE(DECODE(S.CUSTOMER_ID, NULL, NULL,
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          S.CUSTOMER_ID,
                                                          S.SHIP_TO_SITE_ID,
                                                          l_item_to_use,
                                                          p_organization_id,
                                                          p_instance_id,
                                                          --C.NEXT_DATE,
                                                          C.CALENDAR_DATE,
                                                          l_level_id,
                                                          NULL)),
                                                TEMP.LEVEL_3_DEMAND_CLASS,
                                                        1,
                                                NULL,
                                                        NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                        --c.next_date),
                                                        C.CALENDAR_DATE),
                                                        1),
                                                DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                        p_instance_id,
                                                        S.inventory_item_id,
                                                        p_organization_id,
                                                        null,
                                                        null,
                                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                        --c.next_date),
                                                        C.CALENDAR_DATE),
                                                        NULL, 1, 0)
                                                )                       col11, -- allocated_quantity
                                l_record_type                           col12, -- record_type
                                l_scenario_id                           col13, -- scenario_id
                             -- Bug 2771075. For Planned Orders, we will populate transaction_id
                             -- in the disposition_name column to be consistent with Planning.
                                DECODE(S.ORDER_TYPE,
                                        5, to_char(S.TRANSACTION_ID),
                                        S.ORDER_NUMBER)                 col14, -- disposition_name
                                TEMP.LEVEL_3_DEMAND_CLASS               col15, -- demand_class
                                TEMP.LEVEL_1_DEMAND_CLASS               col16, -- class
                                TEMP.PARTNER_ID                         col17, -- partner_id
                                TEMP.PARTNER_SITE_ID                    col18, -- partner_site_id
                                l_uom_code                              col19, -- UOM Code
                                l_item_name_to_use                      col20, -- Item name --Bug 3823042
                                --l_inv_item_name                         col20, -- Item name
                                l_org_code                              col21, -- Org code
                                TEMP.LEVEL_3_DEMAND_CLASS_PRIORITY      col22, -- Level 3 priority
                                TEMP.ALLOCATION_PERCENT                 col23, -- Sysdate allocation percent
                                TEMP.customer_name                      col24, -- Customer Name
                                TEMP.customer_site_name                 col25, -- Customer Site Name
                                l_null_char                                    col26, --bug3263368 ORIG_CUSTOMER_SITE_NAME --Bug 3875786
                                l_null_char                                    col27, --bug3263368 ORIG_CUSTOMER_NAME --Bug 3875786
                                l_null_char                                    col28, --bug3263368 ORIG_DEMAND_CLASS --Bug 3875786
                                l_null_date                             COL29  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - null removed
                        FROM
                                MSC_CALENDAR_DATES      C,
                                MSC_SUPPLIES            S,
                                MSC_ALLOC_HIERARCHY_TEMP TEMP
                        WHERE
                                S.PLAN_ID = p_plan_id
                                AND S.SR_INSTANCE_ID = p_instance_id
                                AND S.INVENTORY_ITEM_ID = l_item_to_use -- Bug 3823042
                                AND S.ORGANIZATION_ID = p_organization_id
                                AND NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
                                AND NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
                                AND C.CALENDAR_CODE = l_calendar_code
                                AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                                AND C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                                AND C.CALENDAR_DATE
                                        BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                                        AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                                AND DECODE(S.LAST_UNIT_COMPLETION_DATE, NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                                -- Bug 3823042 , next_date to calendar_date
                                AND C.CALENDAR_DATE >= TRUNC(DECODE(S.ORDER_TYPE, 27,SYSDATE, 28,SYSDATE, C.CALENDAR_DATE))
                                AND C.CALENDAR_DATE < TRUNC(p_infinite_time_fence_date)
                        );
                        l_insert_count := SQL%ROWCOUNT;
                  END IF;
                END IF;

                IF (l_insert_count = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'No s/d records inserted into temp table');
                        END IF;

                        -- bug 2763784 (ssurendr)
                        -- Should not error out if no s/d record found
                        --Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        --x_return_status := FND_API.G_RET_STS_ERROR;
                        --return;
                        SELECT LEVEL_3_DEMAND_CLASS, LEVEL_1_DEMAND_CLASS, PARTNER_ID, PARTNER_SITE_ID
                        BULK   COLLECT INTO l_dc_list_tab, l_class_tab, l_customer_id_tab, l_customer_site_id_tab
                        FROM   MSC_ALLOC_HIERARCHY_TEMP;

                        l_dc_list_tab.Extend();
                        l_class_tab.Extend();
                        l_customer_id_tab.Extend();
                        l_customer_site_id_tab.Extend();
                        l_dc_list_tab(l_dc_list_tab.COUNT) := G_UNALLOCATED_DC;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'l_dc_list_tab.COUNT: ' || l_dc_list_tab.COUNT);
                        END IF;
                ELSE

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After copying supply/demand records from msc_supplies/msc_demands into temp tables.');
                        END IF;

                        /* Bulk Collect Allocated Supply, Total Supply,
                        Allocated Demand, Stolen Demand, Total Demand, Net into PL/SQL Period table. */
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before selecting supply/demand records from temp table into PL/SQL period table.');
                        END IF;

                        -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                                -- here was the same query without the unallocated columns
                                -- always get unallocated figures
                                -- removed for bug 2763784 (ssurendr)
                        -- ELSE -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                                -- Get unallocated picture as well

                        -- time_phased_atp changes begin
                        IF l_time_phased_atp = 'Y' THEN
                                MSC_ATP_PF.Get_Period_From_Details_Temp(
                                        MSC_ATP_PF.User_Defined_CC,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_scenario_id,
                                        l_level_id,
                                        l_record_type,
                                        p_session_id,
                                        x_atp_period,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error occured in procedure Get_Period_From_Details_Temp');
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;
                        -- time_phased_atp changes end
                        ELSE
                                SELECT
                                        final.col1,
                                        final.col2,
                                        final.col3,
                                        final.col4,
                                        final.col5,
                                        null,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        p_instance_id,
                                        l_scenario_id,
                                        l_level_id,
                                        null,
                                        0,
                                        0,
                                        final.col6,
                                        final.col7,
                                        final.col8,
                                        final.col9,
                                        final.col10,
                                        final.col11,
                                        null, -- bug 3282426
                                        final.col12,
                                        final.col13
                                BULK COLLECT INTO
                                        x_atp_period.Demand_Class,
                                        x_atp_period.Period_Start_Date,
                                        x_atp_period.Total_Supply_Quantity,
                                        x_atp_period.Total_Demand_Quantity,
                                        x_atp_period.Period_Quantity,
                                        x_atp_period.Total_Bucketed_Demand_Quantity, --time_phased_atp
                                        x_atp_period.Inventory_Item_Id,
                                        x_atp_period.Organization_Id,
                                        x_atp_period.Identifier1,
                                        x_atp_period.Scenario_Id,
                                        x_atp_period.Level,
                                        x_atp_period.Period_End_Date,
                                        x_atp_period.Cumulative_Quantity,
                                        x_atp_period.Demand_Adjustment_Quantity,
                                        x_atp_period.Identifier2,
                                        x_atp_period.Identifier4,
                                        x_atp_period.Class,
                                        x_atp_period.Customer_Id,
                                        x_atp_period.Unallocated_Supply_Quantity,
                                        x_atp_period.Unallocated_Demand_Quantity,
                                        x_atp_period.Unalloc_Bucketed_Demand_Qty, -- bug 3282426
                                        x_atp_period.Unallocated_Net_Quantity,
                                        x_atp_period.Customer_Site_Id
                                FROM
                                (SELECT DEMAND_CLASS                                                    col1,
                                        SUPPLY_DEMAND_DATE                                              col2,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2, ALLOCATED_QUANTITY, 0))       col3,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 1, ALLOCATED_QUANTITY, 0))       col4,
                                        SUM(ALLOCATED_QUANTITY)                                         col5,
                                        IDENTIFIER2                                                     col6,
                                        IDENTIFIER4                                                     col7,
                                        CLASS                                                           col8,
                                        CUSTOMER_ID                                                     col9,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 2, SUPPLY_DEMAND_QUANTITY, 0))   col10,
                                        SUM(DECODE(SUPPLY_DEMAND_TYPE, 1, SUPPLY_DEMAND_QUANTITY, 0))   col11,
                                        SUM(SUPPLY_DEMAND_QUANTITY)                                     col12,
                                        CUSTOMER_SITE_ID                                                col13
                                FROM    MRP_ATP_DETAILS_TEMP
                                WHERE   SESSION_ID = p_session_id
                                AND     RECORD_TYPE = l_record_type
                                GROUP BY DEMAND_CLASS, SUPPLY_DEMAND_DATE, IDENTIFIER2, IDENTIFIER4,
                                        CLASS, CUSTOMER_ID, CUSTOMER_SITE_ID
                                ORDER  BY trunc(IDENTIFIER2,-3),        -- Customer class priority
                                        CLASS,                          -- Customer class
                                        trunc(IDENTIFIER2,-2),          -- Customer priority
                                        CUSTOMER_ID,                    -- Customer
                                        IDENTIFIER2,                    -- Customer site priority
                                        CUSTOMER_SITE_ID,SUPPLY_DEMAND_DATE) final;
                        END IF;

                        -- END IF;              -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After selecting supply/demand records from temp table into PL/SQL period table.');
                        END IF;

                        -- Call Adjust_Allocation_Details to compute everything except Infinite time fence records
                        Adjust_Allocation_Details(x_atp_period, l_dc_list_tab, l_dc_start_index, l_dc_end_index, l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Error occured in procedure Adjust_Allocation_Details');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF;

                /* Compute Period_End_Date for all demand classes and add infinite time fence records*/
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Before computing period_end_date');
                END IF;
                FOR l_index_counter IN 1..l_dc_list_tab.COUNT LOOP
                        -- bug 2763784 (ssurendr)
                        -- Should not error out if no s/d record found
                        IF l_dc_start_index IS NOT NULL
                            AND l_dc_start_index.COUNT>0 THEN
                                l_start_index   := l_dc_start_index(l_index_counter);
                                l_end_index     := l_dc_end_index(l_index_counter);

                                -- Find Period End Date for all demand class records
                                FOR l_period_counter IN l_start_index..l_end_index LOOP
                                        IF (l_period_counter = l_end_index) THEN
                                                /*
                                                IF (p_infinite_time_fence_date IS NOT NULL) THEN
                                                        x_atp_period.Period_End_Date(l_period_counter) := p_infinite_time_fence_date - 1;
                                                ELSE
                                                        x_atp_period.Period_End_Date(l_period_counter) := x_atp_period.Period_Start_Date(l_period_counter);
                                                END IF;
                                                */
                                                -- Bug 3823042
                                                x_atp_period.Period_End_Date(l_period_counter) := p_infinite_time_fence_date - 1;
                                        ELSE
                                                x_atp_period.Period_End_Date(l_period_counter) := x_atp_period.Period_Start_Date(l_period_counter + 1) - 1;
                                        END IF;
                                END LOOP;
                        END IF;

                        -- Add Inifinite time fence date records for each demand class at the end.
                        -- Bug 3823042, In PDS cases, p_infinite_time_fence_date is never NULL
                        -- IF p_infinite_time_fence_date IS NOT NULL THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'Adding infinite time fence date for demand class '|| l_dc_list_tab(l_index_counter));
                                END IF;
                                MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);

                                l_count := x_atp_period.Period_Start_Date.COUNT;

                                x_atp_period.Demand_Class(l_count) := l_dc_list_tab(l_index_counter);
                                IF l_dc_start_index IS NOT NULL
                                    AND l_dc_start_index.COUNT>0 THEN
                                        x_atp_period.Class(l_count) := x_atp_period.Class(l_start_index);
                                        x_atp_period.Customer_Id(l_count) := x_atp_period.Customer_Id(l_start_index);
                                        x_atp_period.Customer_Site_Id(l_count) := x_atp_period.Customer_Site_Id(l_start_index);
                                ELSE
                                        x_atp_period.Class(l_count) := l_class_tab(l_index_counter);
                                        x_atp_period.Customer_Id(l_count) := l_customer_id_tab(l_index_counter);
                                        x_atp_period.Customer_Site_Id(l_count) := l_customer_site_id_tab(l_index_counter);
                                END IF;
                                x_atp_period.Period_Start_Date(l_count) := p_infinite_time_fence_date;
                                x_atp_period.Total_Supply_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Total_Demand_Quantity(l_count) := 0;
                                x_atp_period.Total_Bucketed_Demand_Quantity(l_count) := 0; -- for time_phased_atp
                                x_atp_period.Period_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Period_End_Date(l_count) := p_infinite_time_fence_date;
                                x_atp_period.Cumulative_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Inventory_Item_Id(l_count) := p_inventory_item_id;
                                x_atp_period.Organization_Id(l_count) := p_organization_id;
                                x_atp_period.Identifier1(l_count) := p_instance_id;
                                x_atp_period.Scenario_Id(l_count) := l_scenario_id;
                                x_atp_period.Level(l_count) := l_level_id;
                                x_atp_period.Backward_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                x_atp_period.Demand_Adjustment_Quantity(l_count) := 0;
                                x_atp_period.Adjusted_Availability_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;

                                IF G_ATP_FW_CONSUME_METHOD = 2 THEN
                                        x_atp_period.Adjusted_Cum_Quantity(l_count) := MSC_ATP_PVT.INFINITE_NUMBER;
                                END IF;
                        --END IF; -- Bug 3823042

                END LOOP;
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  'After computing period_end_date and appending infinite time fence records');
                END IF;

        ELSE -- Customer Class Allocation ends
                -- bug 2813095 (ssurendr) Profiles ALLOCATION_METHOD and CLASS_HIERARCHY are not set properly
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Profiles ALLOCATION_METHOD and CLASS_HIERARCHY are not set properly');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Set_Error(MSC_ATP_PVT.INVALID_ALLOC_PROFILE_SETUP);
                return;

        END IF;
        /* We have computed horizontal period. */

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' ||  '*********End of procedure Compute_Allocation_Details ********');
        END IF;

EXCEPTION
WHEN  MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error in Compute_Allocation_Details: Invalid Objects Found');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_INVALID_OBJECTS);

WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Allocation_Details: ' || 'Error in Compute_Allocation_Details: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

END Compute_allocation_Details;


/*--Insert_Allocation_Details-----------------------------------------------
|  o Called by View_Allocation_Details after calling
|    Compute_Allocation_Details.
|  o Inserts period data in temp table and does totalling.
+-------------------------------------------------------------------------*/
PROCEDURE Insert_Allocation_Details(
        p_session_id                    IN              NUMBER,
        p_inventory_item_id             IN              NUMBER,
        p_organization_id               IN              NUMBER,
        p_instance_id                   IN              NUMBER,
        p_infinite_time_fence_date      IN              DATE,
        p_atp_period                    IN              MRP_ATP_PUB.ATP_Period_Typ,
        p_plan_name                     IN              VARCHAR2,  -- bug 2771192
        p_dest_inv_item_id              IN              NUMBER, -- For new allocation logic for time phased ATP
        p_dest_family_item_id           IN              NUMBER, -- For new allocation logic for time phased ATP
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        -- local variables
        l_period_counter        PLS_INTEGER;
        l_record_type           PLS_INTEGER;
        l_scenario_id           PLS_INTEGER;
        l_level_id              PLS_INTEGER;
        l_return_status         PLS_INTEGER;


BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  '*********Inside procedure Insert_Allocation_Details ********');
        END IF;

        -- Initialization section
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_record_type   := 1;
        l_scenario_id   := 0;

        IF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN
                -- Demand priority; Demand class
                l_level_id := -1;

                /* Insert ATP Period Information */
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before inserting period records into the temp table for demand priority');
                END IF;

                -- bug 2763784 (ssurendr)
                -- Honor the rounding control type
                /* rajjain 02/12/2003 bug 2795992
                IF G_ROUNDING_CONTROL_FLAG=1 THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will round off.');
                        FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                INSERT INTO MRP_ATP_DETAILS_TEMP
                                (
                                        session_id,
                                        scenario_id,
                                        atp_level,
                                        record_type,
                                        inventory_item_id,
                                        organization_id,
                                        identifier1,
                                        demand_class,
                                        period_start_date,
                                        period_end_date,
                                        allocated_supply_quantity,
                                        supply_adjustment_quantity,
                                        total_supply_quantity,
                                        total_demand_quantity,
                                        period_quantity,
                                        backward_forward_quantity,
                                        cumulative_quantity,
                                        plan_name  -- bug 2771192
                                )
                                VALUES
                                (
                                        p_session_id,
                                        p_atp_period.scenario_id(l_period_counter),
                                        p_atp_period.level(l_period_counter),
                                        l_record_type,
                                        p_atp_period.inventory_item_id(l_period_counter),
                                        p_atp_period.organization_id(l_period_counter),
                                        p_atp_period.identifier1(l_period_counter),
                                        p_atp_period.demand_class(l_period_counter),
                                        p_atp_period.period_start_date(l_period_counter),
                                        p_atp_period.period_end_date(l_period_counter),
                                        FLOOR(p_atp_period.allocated_supply_quantity(l_period_counter)),
                                        FLOOR(p_atp_period.supply_adjustment_quantity(l_period_counter)),
                                        FLOOR(p_atp_period.total_supply_quantity(l_period_counter)),
                                        FLOOR(p_atp_period.total_demand_quantity(l_period_counter)),
                                        FLOOR(p_atp_period.period_quantity(l_period_counter)),
                                        FLOOR(p_atp_period.backward_forward_quantity(l_period_counter)),
                                        FLOOR(p_atp_period.cumulative_quantity(l_period_counter)),
                                        p_plan_name  -- bug 2771192
                                );
                ELSE  -- IF G_ROUNDING_CONTROL_FLAG=1 THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will not round off.');*/
                        FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                INSERT INTO MRP_ATP_DETAILS_TEMP
                                (
                                        session_id,
                                        scenario_id,
                                        atp_level,
                                        record_type,
                                        inventory_item_id,
                                        organization_id,
                                        identifier1,
                                        demand_class,
                                        period_start_date,
                                        period_end_date,
                                        allocated_supply_quantity,
                                        supply_adjustment_quantity,
                                        total_supply_quantity,
                                        total_demand_quantity,
                                        total_bucketed_demand_quantity, -- For time_phased_atp
                                        period_quantity,
                                        backward_forward_quantity,
                                        cumulative_quantity,
                                        plan_name,  -- bug 2771192
                                        aggregate_time_fence_date -- for time_phased_atp
                                )
                                VALUES
                                (
                                        p_session_id,
                                        p_atp_period.scenario_id(l_period_counter),
                                        p_atp_period.level(l_period_counter),
                                        l_record_type,
                                        p_atp_period.inventory_item_id(l_period_counter),
                                        p_atp_period.organization_id(l_period_counter),
                                        p_atp_period.identifier1(l_period_counter),
                                        p_atp_period.demand_class(l_period_counter),
                                        p_atp_period.period_start_date(l_period_counter),
                                        p_atp_period.period_end_date(l_period_counter),
                                        p_atp_period.allocated_supply_quantity(l_period_counter),
                                        p_atp_period.supply_adjustment_quantity(l_period_counter),
                                        p_atp_period.total_supply_quantity(l_period_counter),
                                        p_atp_period.total_demand_quantity(l_period_counter),
                                        p_atp_period.total_bucketed_demand_quantity(l_period_counter), -- For time_phased_atp
                                        p_atp_period.period_quantity(l_period_counter),
                                        p_atp_period.backward_forward_quantity(l_period_counter),
                                        p_atp_period.cumulative_quantity(l_period_counter),
                                        p_plan_name,  -- bug 2771192
                                        G_ATF_DATE    -- for time_phased_atp
                                );
                --END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After inserting period records into the temp table');
                END IF;

                /* Do Totaling. In case of Demand Priority, we do Total of all demand classes.

                1. We let the demand class remain and period_end_date null for Total.
                2. The net of Total on any period date = Sum of net's of all the demand classes on
                   the period start date.
                3. The cum of Total on any period date = Sum of cum's of all the demand classes
                   (such that period start date of Total falls between the period start date and
                   period end date of the demand class.)
                4. If period start date is infinite time fence date, then we insert INFINITE_NUMBER for supplies
                   and 0 for demands.
                5. If period start date is not equal to infinite time fence date, then we do sum(quantity)
                */


                -- Now do the summing for Total.
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before the summing SQL for Total');
                END IF;
                INSERT INTO MRP_ATP_DETAILS_TEMP
                (
                        session_id,
                        scenario_id,
                        atp_level,
                        record_type,
                        inventory_item_id,
                        organization_id,
                        identifier1,
                        period_start_date,
                        allocated_supply_quantity,
                        supply_adjustment_quantity,
                        total_supply_quantity,
                        --total_bucketed_demand_quantity, -- for time_phased_atp
                        --total_demand_quantity,
                        total_demand_quantity, --bug3519965
                        total_bucketed_demand_quantity, --bug3519965
                        period_quantity,
                        backward_forward_quantity,
                        cumulative_quantity,
                        plan_name,  -- bug 2771192
                        aggregate_time_fence_date -- for time_phased_atp
                )
                SELECT
                        p_session_id,
                        l_scenario_id,
                        l_level_id,
                        l_record_type,
                        p_inventory_item_id,
                        p_organization_id,
                        p_instance_id,
                        final.period_start_date,
                        final.allocated_supply_quantity,
                        final.supply_adjustment_quantity,
                        final.total_supply_quantity,
                        final.total_demand_quantity,
                        final.total_bucketed_demand_quantity, -- for time_phased_atp
                        final.period_quantity,
                        final.backward_forward_quantity,
                        final.cumulative_quantity,
                        p_plan_name,  -- bug 2771192
                        G_ATF_DATE    -- for time_phased_atp
                FROM
                (
                        SELECT
                                mapt.period_start_date                                  period_start_date,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                madt.allocated_supply_quantity, 0)))    allocated_supply_quantity,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                madt.supply_adjustment_quantity, 0)))   supply_adjustment_quantity,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                madt.total_supply_quantity, 0)))        total_supply_quantity,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                madt.total_demand_quantity, 0)))        total_demand_quantity,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                --madt.total_demand_quantity, 0)))        total_bucketed_demand_quantity, -- for time_phased_atp
                                                madt.total_bucketed_demand_quantity, 0)))        total_bucketed_demand_quantity, --bug3519965
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                madt.period_quantity, 0)))              period_quantity,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(DECODE(mapt.period_start_date,
                                                madt.period_start_date,
                                                madt.backward_forward_quantity, 0)))    backward_forward_quantity,
                                DECODE(mapt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        -- rajjain 02/13/2003 Bug 2795372
                                        SUM(GREATEST(madt.cumulative_quantity, 0)))     cumulative_quantity
                        FROM
                                MRP_ATP_DETAILS_TEMP                                    madt,
                                (SELECT DISTINCT(period_start_date) period_start_date
                                FROM MRP_ATP_DETAILS_TEMP
                                WHERE session_id = p_session_id
                                AND record_type = l_record_type)                        mapt
                        WHERE
                                madt.session_id = p_session_id
                                AND madt.record_type = l_record_type
                                AND mapt.period_start_date BETWEEN madt.period_start_date
                                AND madt.period_end_date
                        GROUP BY
                                mapt.period_start_date
                ) final;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After the summing SQL for Total');
                END IF;

        ELSIF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND (MSC_ATP_PVT.G_ALLOCATION_METHOD = 2)) THEN
                -- IF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN
                -- Rule based allocation; Demand class

                -- initialize l_level_id
                l_level_id := -1;

                /* Insert ATP Period Information */
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before inserting period records into the temp table for demand class ATP');
                END IF;

                IF G_ATP_FW_CONSUME_METHOD = 1 THEN

                        -- bug 2763784 (ssurendr)
                        -- Honor the rounding control type
                        /* rajjain 02/12/2003 bug 2795992
                        IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will round off.');
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                plan_name  -- bug 2771192
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                FLOOR(p_atp_period.total_supply_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.total_demand_quantity(l_period_counter)),
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                FLOOR(p_atp_period.period_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.cumulative_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Backward_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Demand_Adjustment_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Adjusted_Availability_Quantity(l_period_counter)),
                                                p_plan_name  -- bug 2771192
                                        );
                        ELSE  -- IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will not round off.');*/
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                total_bucketed_demand_quantity, -- For time_phased_atp
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                plan_name,  -- bug 2771192
                                                aggregate_time_fence_date -- for time_phased_atp
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                p_atp_period.total_supply_quantity(l_period_counter),
                                                p_atp_period.total_demand_quantity(l_period_counter),
                                                p_atp_period.total_bucketed_demand_quantity(l_period_counter), -- For time_phased_atp
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                p_atp_period.period_quantity(l_period_counter),
                                                p_atp_period.cumulative_quantity(l_period_counter),
                                                p_atp_period.Backward_Quantity(l_period_counter),
                                                p_atp_period.Demand_Adjustment_Quantity(l_period_counter),
                                                p_atp_period.Adjusted_Availability_Quantity(l_period_counter),
                                                p_plan_name,  -- bug 2771192
                                                G_ATF_DATE    -- for time_phased_atp
                                        );
                        --END IF;

                ELSE    -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN

                        -- bug 2763784 (ssurendr)
                        -- Honor the rounding control type
                        /* rajjain 02/12/2003 bug 2795992
                        IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will round off.');
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                adjusted_cum_quantity,
                                                plan_name  -- bug 2771192
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                FLOOR(p_atp_period.total_supply_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.total_demand_quantity(l_period_counter)),
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                FLOOR(p_atp_period.period_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.cumulative_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Backward_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Demand_Adjustment_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Adjusted_Availability_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Adjusted_Cum_Quantity(l_period_counter)),
                                                p_plan_name  -- bug 2771192
                                        );
                        ELSE -- IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will not round off.');*/
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                total_bucketed_demand_quantity, -- for time_phased_atp
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                adjusted_cum_quantity,
                                                plan_name,  -- bug 2771192
                                                aggregate_time_fence_date -- for time_phased_atp
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                p_atp_period.total_supply_quantity(l_period_counter),
                                                p_atp_period.total_demand_quantity(l_period_counter),
                                                p_atp_period.total_bucketed_demand_quantity(l_period_counter), -- For time_phased_atp
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                p_atp_period.period_quantity(l_period_counter),
                                                p_atp_period.cumulative_quantity(l_period_counter),
                                                p_atp_period.Backward_Quantity(l_period_counter),
                                                p_atp_period.Demand_Adjustment_Quantity(l_period_counter),
                                                p_atp_period.Adjusted_Availability_Quantity(l_period_counter),
                                                p_atp_period.Adjusted_Cum_Quantity(l_period_counter),
                                                p_plan_name,  -- bug 2771192
                                                G_ATF_DATE    -- for time_phased_atp
                                        );
                        --END IF;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After inserting period records into the temp table');
                END IF;

                /* Do Totaling.
                  1. We let the demand class remain null for Total.
                  2. We do a direct total for all columns because for all period_start_date data would be existing
                     for all demand classes due to allocation SQL.
                  3. If period start date is infinite time fence date, then we insert INFINITE_NUMBER for supplies
                     and 0 for demands.
                  4. If period start date is not equal to infinite time fence date, then we do sum(quantity)
                */

                -- Now do the summing for Total.
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before the summing SQL for Total');
                END IF;
                INSERT INTO MRP_ATP_DETAILS_TEMP
                (
                        session_id,
                        scenario_id,
                        atp_level,
                        record_type,
                        inventory_item_id,
                        organization_id,
                        identifier1,
                        period_start_date,
                        period_end_date,
                        allocated_supply_quantity,
                        total_demand_quantity,
                        total_bucketed_demand_quantity, -- for time_phased_atp
                        period_quantity,
                        cumulative_quantity,
                        backward_quantity,
                        demand_adjustment_quantity,
                        adjusted_availability_quantity,
                        adjusted_cum_quantity,
                        plan_name,  -- bug 2771192
                        aggregate_time_fence_date -- for time_phased_atp
                )
                SELECT
                        p_session_id,
                        l_scenario_id,
                        l_level_id,
                        l_record_type,
                        p_inventory_item_id,
                        p_organization_id,
                        p_instance_id,
                        final.period_start_date,
                        final.period_end_date,
                        final.allocated_supply_quantity,
                        final.total_demand_quantity,
                        final.total_bucketed_demand_quantity, -- for time_phased_atp
                        final.period_quantity,
                        final.cumulative_quantity,
                        final.backward_quantity,
                        final.demand_adjustment_quantity,
                        final.adjusted_availability_quantity,
                        final.adjusted_cum_quantity,
                        p_plan_name,  -- bug 2771192
                        G_ATF_DATE    -- for time_phased_atp
                FROM
                (
                        SELECT
                                madt.period_start_date                                  period_start_date,
                                madt.period_end_date                                    period_end_date,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.allocated_supply_quantity))            allocated_supply_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_demand_quantity))                total_demand_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_bucketed_demand_quantity))       total_bucketed_demand_quantity, -- for time_phased_atp
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.period_quantity))                      period_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.cumulative_quantity))                  cumulative_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.backward_quantity))                    backward_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.demand_adjustment_quantity))           demand_adjustment_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_availability_quantity))       adjusted_availability_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_cum_quantity))                adjusted_cum_quantity
                        FROM
                                MRP_ATP_DETAILS_TEMP                                    madt
                        WHERE
                                madt.session_id = p_session_id
                                AND madt.record_type = l_record_type
                                AND madt.demand_class <> G_UNALLOCATED_DC
                        GROUP BY
                                period_start_date, period_end_date
                ) final;

                /* New allocation logic for time phased ATP changes begin */
                IF (p_dest_inv_item_id <> p_dest_family_item_id) and (G_ATF_Date is not null) THEN
                        UPDATE MRP_ATP_DETAILS_TEMP madt
                        SET (Actual_Allocation_Percent, Allocation_Percent)=
                                (SELECT mv.allocation_percent, mv.level_alloc_percent
                                FROM    MSC_ITEM_HIERARCHY_MV mv
                                WHERE   mv.Demand_Class = madt.Demand_Class
                                        AND mv.Organization_Id = p_organization_id
                                        AND mv.Sr_Instance_Id = p_instance_id
                                        AND madt.Period_Start_Date between mv.Effective_Date and mv.Disable_Date
                                        AND mv.Level_Id = madt.Atp_Level
                                        AND mv.Inventory_Item_Id = Decode(sign(trunc(madt.Period_Start_Date) - G_ATF_Date),
                                                                        1, p_dest_family_item_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', p_dest_inv_item_id,
                                                                                p_dest_family_item_id)))
                        WHERE madt.Record_Type = 1
                        AND   madt.Session_Id = p_session_id;
                ELSE
                        /* Removed join with msc_system_items as part of New allocation logic for time phased ATP changes*/
                        UPDATE MRP_ATP_DETAILS_TEMP madt
                        --rajjain 02/13/2003 Bug 2795636
                        --SET (Allocation_Percent, Actual_Allocation_Percent)=
                        SET (Actual_Allocation_Percent, Allocation_Percent)=
                                (SELECT mv.allocation_percent, mv.level_alloc_percent
                                FROM    MSC_ITEM_HIERARCHY_MV mv
                                WHERE   mv.Demand_Class = madt.Demand_Class
                                        AND mv.Organization_Id = p_organization_id
                                        AND mv.Sr_Instance_Id = p_instance_id
                                        AND madt.Period_Start_Date between mv.Effective_Date and mv.Disable_Date
                                        AND mv.Level_Id = madt.Atp_Level
                                        AND mv.Inventory_Item_Id = p_dest_inv_item_id)
                        WHERE madt.Record_Type = 1
                        AND   madt.Session_Id = p_session_id;
                END IF;
                /* New allocation logic for time phased ATP changes end */

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After the summing SQL for Total');
                END IF;

        ELSIF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 2) AND (MSC_ATP_PVT.G_ALLOCATION_METHOD = 2)) THEN
                -- ELSIF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND (MSC_ATP_PVT.G_ALLOCATION_METHOD = 2)) THEN
                -- Rule based allocation; customer class

                -- initialize l_level_id
                l_level_id := 3;

                /* Insert ATP Period Information */
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before inserting customer site level period records into the temp table');
                END IF;

                IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                        -- bug 2763784 (ssurendr)
                        -- Honor the rounding control type
                        /* rajjain 02/12/2003 bug 2795992
                        IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will round off.');
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                class,
                                                customer_id,
                                                customer_site_id,
                                                plan_name  -- bug 2771192
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                FLOOR(p_atp_period.total_supply_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.total_demand_quantity(l_period_counter)),
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                FLOOR(p_atp_period.period_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.cumulative_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Backward_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Demand_Adjustment_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Adjusted_Availability_Quantity(l_period_counter)),
                                                p_atp_period.Class(l_period_counter),
                                                p_atp_period.Customer_Id(l_period_counter),
                                                p_atp_period.Customer_Site_Id(l_period_counter),
                                                p_plan_name  -- bug 2771192
                                        );
                        ELSE  -- IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will not round off.');*/
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                total_bucketed_demand_quantity, -- for time_phased_atp
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                class,
                                                customer_id,
                                                customer_site_id,
                                                plan_name,  -- bug 2771192
                                                aggregate_time_fence_date -- for time_phased_atp
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                p_atp_period.total_supply_quantity(l_period_counter),
                                                p_atp_period.total_demand_quantity(l_period_counter),
                                                p_atp_period.total_bucketed_demand_quantity(l_period_counter), -- For time_phased_atp
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                p_atp_period.period_quantity(l_period_counter),
                                                p_atp_period.cumulative_quantity(l_period_counter),
                                                p_atp_period.Backward_Quantity(l_period_counter),
                                                p_atp_period.Demand_Adjustment_Quantity(l_period_counter),
                                                p_atp_period.Adjusted_Availability_Quantity(l_period_counter),
                                                p_atp_period.Class(l_period_counter),
                                                p_atp_period.Customer_Id(l_period_counter),
                                                p_atp_period.Customer_Site_Id(l_period_counter),
                                                p_plan_name,  -- bug 2771192
                                                G_ATF_DATE    -- for time_phased_atp
                                        );
                        --END IF;

                ELSE

                        -- bug 2763784 (ssurendr)
                        -- Honor the rounding control type
                        /* rajjain 02/12/2003 bug 2795992
                        IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will round off.');
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                adjusted_cum_quantity,
                                                class,
                                                customer_id,
                                                customer_site_id,
                                                plan_name  -- bug 2771192
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                FLOOR(p_atp_period.total_supply_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.total_demand_quantity(l_period_counter)),
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                FLOOR(p_atp_period.period_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.cumulative_quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Backward_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Demand_Adjustment_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Adjusted_Availability_Quantity(l_period_counter)),
                                                FLOOR(p_atp_period.Adjusted_Cum_Quantity(l_period_counter)),
                                                p_atp_period.Class(l_period_counter),
                                                p_atp_period.Customer_Id(l_period_counter),
                                                p_atp_period.Customer_Site_Id(l_period_counter),
                                                p_plan_name  -- bug 2771192
                                        );
                        ELSE -- IF G_ROUNDING_CONTROL_FLAG=1 THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Will not round off.');*/
                                FORALL l_period_counter IN 1..p_atp_period.Period_Start_Date.COUNT
                                        INSERT INTO MRP_ATP_DETAILS_TEMP
                                        (
                                                session_id,
                                                scenario_id,
                                                atp_level,
                                                record_type,
                                                inventory_item_id,
                                                organization_id,
                                                identifier1,
                                                demand_class,
                                                allocated_supply_quantity,
                                                total_demand_quantity,
                                                total_bucketed_demand_quantity, -- for time_phased_atp
                                                period_start_date,
                                                period_end_date,
                                                period_quantity,
                                                cumulative_quantity,
                                                backward_quantity,
                                                demand_adjustment_quantity,
                                                adjusted_availability_quantity,
                                                adjusted_cum_quantity,
                                                class,
                                                customer_id,
                                                customer_site_id,
                                                plan_name,  -- bug 2771192
                                                aggregate_time_fence_date -- for time_phased_atp
                                        )
                                        VALUES
                                        (
                                                p_session_id,
                                                p_atp_period.scenario_id(l_period_counter),
                                                p_atp_period.level(l_period_counter),
                                                l_record_type,
                                                p_atp_period.inventory_item_id(l_period_counter),
                                                p_atp_period.organization_id(l_period_counter),
                                                p_atp_period.identifier1(l_period_counter),
                                                p_atp_period.demand_class(l_period_counter),
                                                p_atp_period.total_supply_quantity(l_period_counter),
                                                p_atp_period.total_demand_quantity(l_period_counter),
                                                p_atp_period.total_bucketed_demand_quantity(l_period_counter), -- For time_phased_atp
                                                p_atp_period.period_start_date(l_period_counter),
                                                p_atp_period.period_end_date(l_period_counter),
                                                p_atp_period.period_quantity(l_period_counter),
                                                p_atp_period.cumulative_quantity(l_period_counter),
                                                p_atp_period.Backward_Quantity(l_period_counter),
                                                p_atp_period.Demand_Adjustment_Quantity(l_period_counter),
                                                p_atp_period.Adjusted_Availability_Quantity(l_period_counter),
                                                p_atp_period.Adjusted_Cum_Quantity(l_period_counter),
                                                p_atp_period.Class(l_period_counter),
                                                p_atp_period.Customer_Id(l_period_counter),
                                                p_atp_period.Customer_Site_Id(l_period_counter),
                                                p_plan_name,  -- bug 2771192
                                                G_ATF_DATE    -- for time_phased_atp
                                        );
                        --END IF;

                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After inserting customer site level period records into the temp table');
                END IF;

                /* Do sub-Total for level 2 records.
                1. We let demand_class be null.
                2. We do a direct sum for all columns because data for all sites will be present for all dates.
                3. If period start date is infinite time fence date, then we insert INFINITE_NUMBER for supply
                   columns and 0 for demand columns.
                4. If period start date is not equal to infinite time fence date, then we do sum(quantity)
                5. The grouping is done on class, customer_id, period_start_date and period_end_date
                */

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before the summing SQL for customer level');
                END IF;
                INSERT INTO MRP_ATP_DETAILS_TEMP
                (
                        session_id,
                        scenario_id,
                        atp_level,
                        record_type,
                        inventory_item_id,
                        organization_id,
                        identifier1,
                        period_start_date,
                        period_end_date,
                        allocated_supply_quantity,
                        total_demand_quantity,
                        total_bucketed_demand_quantity, -- for time_phased_atp
                        period_quantity,
                        cumulative_quantity,
                        backward_quantity,
                        demand_adjustment_quantity,
                        adjusted_availability_quantity,
                        adjusted_cum_quantity,
                        class,
                        customer_id,
                        plan_name,  -- bug 2771192
                        aggregate_time_fence_date -- for time_phased_atp
                )
                SELECT
                        p_session_id,
                        l_scenario_id,
                        final.level_id,
                        l_record_type,
                        p_inventory_item_id,
                        p_organization_id,
                        p_instance_id,
                        final.period_start_date,
                        final.period_end_date,
                        final.allocated_supply_quantity,
                        final.total_demand_quantity,
                        final.total_bucketed_demand_quantity, -- for time_phased_atp
                        final.period_quantity,
                        final.cumulative_quantity,
                        final.backward_quantity,
                        final.demand_adjustment_quantity,
                        final.adjusted_availability_quantity,
                        final.adjusted_cum_quantity,
                        final.class,
                        final.customer_id,
                        p_plan_name,  -- bug 2771192
                        G_ATF_DATE    -- for time_phased_atp
                FROM
                (
                        SELECT
                                madt.class                                              class,
                                madt.customer_id                                        customer_id,
                                2                                                       level_id,
                                madt.period_start_date                                  period_start_date,
                                madt.period_end_date                                    period_end_date,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.allocated_supply_quantity))            allocated_supply_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_demand_quantity))                total_demand_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_bucketed_demand_quantity))       total_bucketed_demand_quantity, -- for time_phased_atp
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.period_quantity))                      period_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.cumulative_quantity))                  cumulative_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.backward_quantity))                    backward_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.demand_adjustment_quantity))           demand_adjustment_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_availability_quantity))       adjusted_availability_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_cum_quantity))                adjusted_cum_quantity
                        FROM
                                MRP_ATP_DETAILS_TEMP                                    madt
                        WHERE
                                madt.session_id = p_session_id
                                AND madt.record_type = l_record_type
                                AND madt.ATP_Level = 3
                                AND madt.demand_class <> G_UNALLOCATED_DC
                        GROUP BY
                                class, customer_id, period_start_date, period_end_date
                ) final;

                IF (SQL%ROWCOUNT = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Error occured while doing sub-Total for customer level');
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After the summing SQL for Customer level');
                END IF;

                /* Do sub-Total for level 1 records.
                1. We let demand_class be null.
                2. We do sum over the customer level records inserted by the earlier SQL.
                3. We do a direct sum for all columns because data for all customers will be present for all dates.
                4. If period start date is infinite time fence date, then we insert INFINITE_NUMBER for supply
                   columns and 0 for demand columns.
                5. If period start date is not equal to infinite time fence date, then we do sum(quantity)
                6. The grouping is done on class, period_start_date and period_end_date
                */

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before the summing SQL for customer class level');
                END IF;

                INSERT INTO MRP_ATP_DETAILS_TEMP
                (
                        session_id,
                        scenario_id,
                        atp_level,
                        record_type,
                        inventory_item_id,
                        organization_id,
                        identifier1,
                        period_start_date,
                        period_end_date,
                        allocated_supply_quantity,
                        total_demand_quantity,
                        total_bucketed_demand_quantity, -- for time_phased_atp
                        period_quantity,
                        cumulative_quantity,
                        backward_quantity,
                        demand_adjustment_quantity,
                        adjusted_availability_quantity,
                        adjusted_cum_quantity,
                        class,
                        plan_name,  -- bug 2771192
                        aggregate_time_fence_date -- for time_phased_atp
                )
                SELECT
                        p_session_id,
                        l_scenario_id,
                        final.level_id,
                        l_record_type,
                        p_inventory_item_id,
                        p_organization_id,
                        p_instance_id,
                        final.period_start_date,
                        final.period_end_date,
                        final.allocated_supply_quantity,
                        final.total_demand_quantity,
                        final.total_bucketed_demand_quantity, -- for time_phased_atp
                        final.period_quantity,
                        final.cumulative_quantity,
                        final.backward_quantity,
                        final.demand_adjustment_quantity,
                        final.adjusted_availability_quantity,
                        final.adjusted_cum_quantity,
                        final.class,
                        p_plan_name,  -- bug 2771192
                        G_ATF_DATE    -- for time_phased_atp
                FROM
                (
                        SELECT
                                madt.class                                              class,
                                1                                                       level_id,
                                madt.period_start_date                                  period_start_date,
                                madt.period_end_date                                    period_end_date,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.allocated_supply_quantity))            allocated_supply_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_demand_quantity))                total_demand_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_bucketed_demand_quantity))       total_bucketed_demand_quantity, -- for time_phased_atp
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.period_quantity))                      period_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.cumulative_quantity))                  cumulative_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.backward_quantity))                    backward_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.demand_adjustment_quantity))           demand_adjustment_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_availability_quantity))       adjusted_availability_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_cum_quantity))                adjusted_cum_quantity
                        FROM
                                MRP_ATP_DETAILS_TEMP                                    madt
                        WHERE
                                madt.session_id = p_session_id
                                AND madt.record_type = l_record_type
                                AND madt.ATP_Level = 2
                        GROUP BY
                                class, period_start_date, period_end_date
                ) final;

                IF (SQL%ROWCOUNT = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Error occured while doing sub-Total for customer class level');
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After the summing SQL for Customer class level');
                END IF;

                /* Do Total for level -1 records (grand total).
                1. We let demand_class be null.
                2. We do sum over the customer class level records inserted by the earlier SQL.
                3. We do a direct sum for all columns because data for all classes will be present for all dates.
                4. If period start date is infinite time fence date, then we insert INFINITE_NUMBER for supply
                   columns and 0 for demand columns.
                5. If period start date is not equal to infinite time fence date, then we do sum(quantity)
                6. The grouping is done on period_start_date and period_end_date
                */

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Before the summing SQL at grand total level');
                END IF;

                INSERT INTO MRP_ATP_DETAILS_TEMP
                (
                        session_id,
                        scenario_id,
                        atp_level,
                        record_type,
                        inventory_item_id,
                        organization_id,
                        identifier1,
                        period_start_date,
                        period_end_date,
                        allocated_supply_quantity,
                        total_demand_quantity,
                        total_bucketed_demand_quantity, -- for time_phased_atp
                        period_quantity,
                        cumulative_quantity,
                        backward_quantity,
                        demand_adjustment_quantity,
                        adjusted_availability_quantity,
                        adjusted_cum_quantity,
                        plan_name,  -- bug 2771192
                        aggregate_time_fence_date -- for time_phased_atp
                )
                SELECT
                        p_session_id,
                        l_scenario_id,
                        final.level_id,
                        l_record_type,
                        p_inventory_item_id,
                        p_organization_id,
                        p_instance_id,
                        final.period_start_date,
                        final.period_end_date,
                        final.allocated_supply_quantity,
                        final.total_demand_quantity,
                        final.total_bucketed_demand_quantity, -- for time_phased_atp
                        final.period_quantity,
                        final.cumulative_quantity,
                        final.backward_quantity,
                        final.demand_adjustment_quantity,
                        final.adjusted_availability_quantity,
                        final.adjusted_cum_quantity,
                        p_plan_name,  -- bug 2771192
                        G_ATF_DATE    -- for time_phased_atp
                FROM
                (
                        SELECT
                                -1                                                      level_id,
                                madt.period_start_date                                  period_start_date,
                                madt.period_end_date                                    period_end_date,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.allocated_supply_quantity))            allocated_supply_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_demand_quantity))                total_demand_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.total_bucketed_demand_quantity))       total_bucketed_demand_quantity, -- for time_phased_atp
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.period_quantity))                      period_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.cumulative_quantity))                  cumulative_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.backward_quantity))                    backward_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        0,
                                        SUM(madt.demand_adjustment_quantity))           demand_adjustment_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_availability_quantity))       adjusted_availability_quantity,
                                DECODE(madt.period_start_date,
                                        p_infinite_time_fence_date,
                                        MSC_ATP_PVT.INFINITE_NUMBER,
                                        SUM(madt.adjusted_cum_quantity))                adjusted_cum_quantity
                        FROM
                                MRP_ATP_DETAILS_TEMP                                    madt
                        WHERE
                                madt.session_id = p_session_id
                                AND madt.record_type = l_record_type
                                AND madt.ATP_Level = 1
                        GROUP BY
                                period_start_date, period_end_date
                ) final;

                IF (SQL%ROWCOUNT = 0) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'Error occured while doing grand-Total for customer class case');
                        END IF;
                        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After the summing SQL at grand total level level');
                END IF;

                /* New allocation logic for time phased ATP changes begin */
                IF (p_dest_inv_item_id <> p_dest_family_item_id) and (G_ATF_Date is not null) THEN
                        UPDATE MRP_ATP_DETAILS_TEMP madt
                        --rajjain 02/13/2003 Bug 2795636
                        --SET (Allocation_Percent, Actual_Allocation_Percent)=
                        SET (Actual_Allocation_Percent, Allocation_Percent)=
                                (SELECT mv.allocation_percent, mv.level_alloc_percent
                                FROM    MSC_ITEM_HIERARCHY_MV mv
                                WHERE   mv.Class = madt.Class
                                        AND nvl(mv.Partner_Id, -23453) = nvl(madt.Customer_Id, -23453)
                                        AND nvl(mv.Partner_Site_Id, -23453) = nvl(madt.Customer_Site_Id, -23453)
                                        AND mv.Organization_Id = p_organization_id
                                        AND mv.Sr_Instance_Id = p_instance_id
                                        AND madt.Period_Start_Date between mv.Effective_Date and mv.Disable_Date
                                        AND mv.Level_Id = madt.Atp_Level
                                        AND mv.Inventory_Item_Id = Decode(sign(trunc(madt.Period_Start_Date) - G_ATF_Date),
                                                                        1, p_dest_family_item_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', p_dest_inv_item_id,
                                                                                p_dest_family_item_id)))
                        WHERE madt.Record_Type = 1
                        AND   madt.Session_Id = p_session_id;
                ELSE
                        /* Removed join with msc_system_items as part of New allocation logic for time phased ATP changes*/
                        UPDATE MRP_ATP_DETAILS_TEMP madt
                        --rajjain 02/13/2003 Bug 2795636
                        --SET (Allocation_Percent, Actual_Allocation_Percent)=
                        SET (Actual_Allocation_Percent, Allocation_Percent)=
                                (SELECT mv.allocation_percent, mv.level_alloc_percent
                                FROM    MSC_ITEM_HIERARCHY_MV mv
                                WHERE   mv.Class = madt.Class
                                        AND nvl(mv.Partner_Id, -23453) = nvl(madt.Customer_Id, -23453)
                                        AND nvl(mv.Partner_Site_Id, -23453) = nvl(madt.Customer_Site_Id, -23453)
                                        AND mv.Organization_Id = p_organization_id
                                        AND mv.Sr_Instance_Id = p_instance_id
                                        AND madt.Period_Start_Date between mv.Effective_Date and mv.Disable_Date
                                        AND mv.Level_Id = madt.Atp_Level
                                        AND mv.Inventory_Item_Id = p_dest_inv_item_id)
                        WHERE madt.Record_Type = 1
                        AND   madt.Session_Id = p_session_id;
                END IF;
                /* New allocation logic for time phased ATP changes end */

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  'After the summing for Total for customer class allocation');
                END IF;

        END IF; -- Customer Class Allocated ATP

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' ||  '*********End of procedure Insert_Allocation_Details ********');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Insert_Allocation_Details: ' || 'Error in Insert_Allocation_Details: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

END Insert_allocation_Details;

/*--Refresh_Allocation_Details----------------------------------------------
|  o This procedure will be called when engine is called in concurrent
|    program mode when user refreshes the allocation horizontal picture in
|    allocation workbench.
|  o It makes a call to view_allocation_details.
+-------------------------------------------------------------------------*/
PROCEDURE Refresh_Allocation_Details(
        ERRBUF                  OUT     NOCOPY  VARCHAR2,
        RETCODE                 OUT     NOCOPY  NUMBER,
        p_session_id            IN              NUMBER,
        p_inventory_item_id     IN              NUMBER,
        p_instance_id           IN              NUMBER,
        p_organization_id       IN              NUMBER)
IS
        l_return_status VARCHAR2(1);
        l_spid          VARCHAR2(12);
        l_error_meaning VARCHAR2(100);

        cursor Error_Meaning (p_error_code NUMBER) IS
        select meaning
        from   mfg_lookups
        where  lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
        and    lookup_code = p_error_code;

BEGIN
        G_REFRESH_ALLOCATION := true;

        -- Bug 3304390 Disable Trace
        -- Deleted Related Code.

        RETCODE:= G_SUCCESS;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' || 'Begin Refresh_Allocation_Details');
                msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' || 'PG_DEBUG := ' || PG_DEBUG);
        END IF;

        -- Call View_Allocation_Details
        MSC_ATP_ALLOC.View_Allocation_Details(p_session_id,
                p_inventory_item_id,
                p_instance_id,
                p_organization_id,
                l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' || 'Refresh_Allocation_Details could not complete successfully');
                        msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' || 'MSC_SCH_WB.G_ATP_ERROR_CODE := ' || MSC_SCH_WB.G_ATP_ERROR_CODE);

                END IF;
                OPEN Error_Meaning(MSC_SCH_WB.G_ATP_ERROR_CODE);
                FETCH Error_Meaning INTO l_error_meaning;
                IF Error_Meaning%notfound THEN
                        msc_util.msc_log('Error: ' || MSC_SCH_WB.G_ATP_ERROR_CODE);
                ELSE
                        msc_util.msc_log(l_error_meaning);
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' ||  l_error_meaning);
                        END IF;
                END IF;
                CLOSE Error_Meaning;
                RETCODE:= G_ERROR;
        ELSE
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' ||  'Refresh_Allocation_Details completed successfully');
                END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' ||  'End Refresh_Allocation_Details');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Refresh_Allocation_Details: ' || to_char(sqlcode) || ':' || sqlerrm);
        END IF;
        RETCODE:= G_ERROR;
        ERRBUF:= SQLERRM;

END Refresh_Allocation_Details;


/*--Backward_Consume-------------------------------------------------------
|  o Does backward consumption.
+-------------------------------------------------------------------------*/
PROCEDURE Backward_Consume(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        x_dc_list_tab                   OUT     NOCOPY  MRP_ATP_PUB.char80_arr,
        x_dc_start_index                OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_dc_end_index                  OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i PLS_INTEGER;
        j PLS_INTEGER;
        -- time_phased_atp
        l_atf_date      DATE := MSC_ATP_ALLOC.G_ATF_Date;
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Backward_Consume: ' ||  '**********Begin Backward_Consume Procedure************');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_dc_list_tab := MRP_ATP_PUB.Char80_Arr();
        x_dc_start_index := MRP_ATP_PUB.Number_Arr();
        x_dc_end_index := MRP_ATP_PUB.Number_Arr();

        x_dc_list_tab.EXTEND;
        x_dc_start_index.EXTEND;
        x_dc_end_index.EXTEND;

        x_dc_list_tab(1) := p_atp_period.demand_class(p_atp_period.demand_class.FIRST);
        x_dc_start_index(1) := 1;

        -- Copy Backward Forward Quantity from Period Quantity initially.
        p_atp_period.Backward_Quantity := p_atp_period.Period_Quantity;

        -- this for loop will do backward consumption
        FOR i in 1..p_atp_period.demand_class.COUNT LOOP

                -- If demand class changes, re-initialize these variables.
                IF p_atp_period.demand_class(i) <> x_dc_list_tab(x_dc_list_tab.COUNT) THEN
                        -- Demand class changing

                        x_dc_end_index(x_dc_end_index.COUNT) := i - 1;

                        x_dc_list_tab.EXTEND;
                        x_dc_start_index.EXTEND;
                        x_dc_end_index.EXTEND;
                        x_dc_list_tab(x_dc_list_tab.COUNT) := p_atp_period.demand_class(i);
                        x_dc_start_index(x_dc_start_index.COUNT) := i;
                        x_dc_end_index(x_dc_end_index.COUNT) := i;
                ELSE
                        x_dc_end_index(x_dc_end_index.COUNT) := i;
                END IF;

                -- backward consumption when neg atp quantity occurs
                IF (p_atp_period.backward_quantity(i) < 0 ) THEN
                        j := i - 1;
                        WHILE ((j >= x_dc_start_index(x_dc_start_index.COUNT)) and
                                (p_atp_period.backward_quantity(j) >= 0))  LOOP
                                -- time_phased_atp
                                IF ((l_atf_date is not null) and (p_atp_period.Period_Start_Date(i)>l_atf_date) and (p_atp_period.Period_Start_Date(j)<=l_atf_date)) THEN
                                        -- exit loop when crossing time fence
                                        j := 0;
                                ELSIF (p_atp_period.backward_quantity(j) = 0) THEN
                                        --  backward one more period
                                        j := j-1 ;
                                ELSE
                                        IF (p_atp_period.backward_quantity(j) + p_atp_period.backward_quantity(i) < 0) THEN
                                                -- not enough to cover the shortage
                                                p_atp_period.backward_quantity(i) := p_atp_period.backward_quantity(i) +
                                                                        p_atp_period.backward_quantity(j);
                                                p_atp_period.backward_quantity(j) := 0;
                                                j := j-1;
                                        ELSE
                                                -- enough to cover the shortage
                                                p_atp_period.backward_quantity(j) := p_atp_period.backward_quantity(j) +
                                                                        p_atp_period.backward_quantity(i);
                                                p_atp_period.backward_quantity(i) := 0;
                                                j := -1;
                                        END IF;
                                END IF;
                        END LOOP;
                END IF;

        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                FOR i in 1..x_dc_list_tab.COUNT LOOP
                        msc_sch_wb.atp_debug('Backward_Consume: ' ||  'DC:start:end:priority - ' || x_dc_list_tab(i) || ':' ||
                                x_dc_start_index(i) || ':' ||
                                x_dc_end_index(i) || ':' ||
                                p_atp_period.Identifier2(x_dc_start_index(i)));
                END LOOP;

                msc_sch_wb.atp_debug('Backward_Consume: ' ||  '**********End Backward_Consume Procedure************');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Backward_Consume: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

END Backward_Consume;


/*--Forward_Consume--------------------------------------------------------
|  o Does forward consumption.
+-------------------------------------------------------------------------*/
PROCEDURE Forward_Consume(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              NUMBER,
        p_end_index                     IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i PLS_INTEGER;
        j PLS_INTEGER;
        -- time_phased_atp
        l_atf_date                      DATE    := MSC_ATP_ALLOC.G_ATF_Date;
        l_fw_nullifying_bucket_index    NUMBER  := 1;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Forward_Consume: ' ||  '**********Begin Forward_Consume Procedure************');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- this procedure will add p_steal_atp's negatives in p_atp_period.
        -- It is assumed here that the dates in p_steal_atp is always a subset of dates in p_atp_period

        IF PG_DEBUG in ('Y', 'C') THEN
                i := p_start_index;
                WHILE (i is not null) AND (i <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Forward_Consume: ' ||  'current date:qty - '||
                        p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;
        END IF;

        -- this for loop will do backward consumption
        FOR i in p_start_index..p_end_index LOOP

                -- forward consumption when neg atp quantity occurs
                IF (p_atp_period.Adjusted_Availability_Quantity(i) < 0 ) THEN

                        j := i + 1;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Forward_Consume: ' ||  'shortage - qty,i:' || p_atp_period.Adjusted_Availability_Quantity(i) || ',' || i);
                        END IF;

                        WHILE (j <= p_end_index) LOOP
                                -- time_phased_atp
                                IF ((l_atf_date is not null) and (p_atp_period.Period_Start_Date(i)<=l_atf_date) and (p_atp_period.Period_Start_Date(j)>l_atf_date)) THEN
                                        -- exit loop when crossing time fence
                                        j := p_end_index+1;
                                ELSIF (p_atp_period.Adjusted_Availability_Quantity(j) <= 0
                                    -- time_phased_atp
                                    OR j < l_fw_nullifying_bucket_index)
                                THEN
                                        --  forward one more period
                                        j := j+1 ;
                                ELSE
                                        -- You can get something from here. So set the nullifying bucket index
                                        l_fw_nullifying_bucket_index := j;
                                        IF (p_atp_period.Adjusted_Availability_Quantity(j) +
                                                p_atp_period.Adjusted_Availability_Quantity(i) < 0) THEN
                                                -- not enough to cover the shortage
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Forward_Consume: ' ||  'consuming      - qty,j:'  ||
                                                                p_atp_period.Adjusted_Availability_Quantity(j) || ',' || j);
                                                END IF;
                                                p_atp_period.Adjusted_Availability_Quantity(i) := p_atp_period.Adjusted_Availability_Quantity(i) +
                                                        p_atp_period.Adjusted_Availability_Quantity(j);
                                                p_atp_period.Adjusted_Availability_Quantity(j) := 0;
                                                j := j + 1;
                                        ELSE
                                                -- enough to cover the shortage
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Forward_Consume: ' ||  'consuming last - qty,j:'  ||
                                                                p_atp_period.Adjusted_Availability_Quantity(i) || ',' || j);
                                                END IF;
                                                p_atp_period.Adjusted_Availability_Quantity(j) := p_atp_period.Adjusted_Availability_Quantity(j) +
                                                        p_atp_period.Adjusted_Availability_Quantity(i);
                                                p_atp_period.Adjusted_Availability_Quantity(i) := 0;
                                                EXIT;
                                        END IF;
                                END IF;
                        END LOOP;

                END IF;
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                i := p_start_index;
                WHILE (i is not null) AND (i <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Forward_Consume: ' ||  'current date:qty - '||
                        p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;
                msc_sch_wb.atp_debug('Forward_Consume: ' ||  '**********End Forward_Consume Procedure************');
        END IF;
EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Forward_Consume: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

END Forward_Consume;


/*--Backward_Forward_Consume-----------------------------------------------
|  o Does backward/forward consumption.
|  o Used in demand priority case.
+-------------------------------------------------------------------------*/
PROCEDURE Backward_Forward_Consume(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        x_dc_list_tab                   OUT     NOCOPY  MRP_ATP_PUB.char80_arr,
        x_dc_start_index                OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_dc_end_index                  OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i PLS_INTEGER;
        j PLS_INTEGER;
        -- time_phased_atp
        l_atf_date                      DATE   := MSC_ATP_ALLOC.G_Atf_Date;
        l_fw_nullifying_bucket_index    NUMBER := 1;
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  '**********Begin Backward_Forward_Consume Procedure************');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_dc_list_tab := MRP_ATP_PUB.Char80_Arr();
        x_dc_start_index := MRP_ATP_PUB.Number_Arr();
        x_dc_end_index := MRP_ATP_PUB.Number_Arr();

        x_dc_list_tab.EXTEND;
        x_dc_start_index.EXTEND;
        x_dc_end_index.EXTEND;


        x_dc_list_tab(1) := p_atp_period.demand_class(p_atp_period.demand_class.FIRST);
        x_dc_start_index(1) := 1;

        -- Copy Backward Forward Quantity from Period Quantity initially.
        p_atp_period.Backward_Forward_Quantity := p_atp_period.Period_Quantity;

        -- this for loop will do backward consumption
        FOR i in 1..p_atp_period.demand_class.COUNT LOOP

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'index : ' || i);
                        msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'x_dc_list_tab : ' || x_dc_list_tab(x_dc_list_tab.COUNT));
                        msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'p_atp_period.demand_class : ' || p_atp_period.demand_class(i));
                END IF;

                -- If demand class changes, re-initialize these variables.
                IF p_atp_period.demand_class(i) <> x_dc_list_tab(x_dc_list_tab.COUNT) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'Demand class changing');
                        END IF;

                        x_dc_end_index(x_dc_end_index.COUNT) := i - 1;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'demand class, end index : ' || x_dc_list_tab(x_dc_list_tab.COUNT)
                                                || ', ' || x_dc_end_index(x_dc_end_index.COUNT));
                        END IF;

                        x_dc_list_tab.EXTEND;
                        x_dc_start_index.EXTEND;
                        x_dc_end_index.EXTEND;
                        x_dc_list_tab(x_dc_list_tab.COUNT) := p_atp_period.demand_class(i);
                        x_dc_start_index(x_dc_start_index.COUNT) := i;
                        x_dc_end_index(x_dc_end_index.COUNT) := i;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'demand class, start index : ' || x_dc_list_tab(x_dc_list_tab.COUNT)
                                                || ', ' || x_dc_start_index(x_dc_start_index.COUNT));
                        END IF;
                ELSE
                   x_dc_end_index(x_dc_end_index.COUNT) := i;
                END IF;

                -- backward consumption when neg atp quantity occurs
                IF (p_atp_period.backward_forward_quantity(i) < 0 ) THEN
                        j := i - 1;
                        WHILE ((j >= x_dc_start_index(x_dc_start_index.COUNT)) and
                                (p_atp_period.backward_forward_quantity(j) >= 0))  LOOP
                                -- time_phased_atp
                                IF ((l_atf_date is not null) and (p_atp_period.Period_Start_Date(i)>l_atf_date) and (p_atp_period.Period_Start_Date(j)<=l_atf_date)) THEN
                                        -- exit loop when crossing time fence
                                        j := 0;
                                ELSIF (p_atp_period.backward_forward_quantity(j) = 0) THEN
                                        --  backward one more period
                                        j := j-1 ;
                                ELSE
                                        IF (p_atp_period.backward_forward_quantity(j) + p_atp_period.backward_forward_quantity(i) < 0) THEN
                                                -- not enough to cover the shortage
                                                p_atp_period.backward_forward_quantity(i) := p_atp_period.backward_forward_quantity(i) +
                                                        p_atp_period.backward_forward_quantity(j);
                                                p_atp_period.backward_forward_quantity(j) := 0;
                                                j := j-1;
                                        ELSE
                                                -- enough to cover the shortage
                                                p_atp_period.backward_forward_quantity(j) := p_atp_period.backward_forward_quantity(j) +
                                                        p_atp_period.backward_forward_quantity(i);
                                                p_atp_period.backward_forward_quantity(i) := 0;
                                                j := -1;
                                        END IF;
                                END IF;
                        END LOOP;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'before forward consumption');
                END IF;
                -- this for loop will do forward consumption

                -- forward consumption when neg atp quantity occurs
                IF (p_atp_period.backward_forward_quantity(i) < 0 ) THEN

                        j := i + 1;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'in forward consumption : '  || i || ':' || j);
                                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'in forward : '  || p_atp_period.demand_class.COUNT);
                        END IF;

                        IF j <= p_atp_period.demand_class.COUNT THEN

                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  'in j : '  || p_atp_period.demand_class.COUNT);
                                END IF;

                                WHILE (p_atp_period.demand_class(j) = x_dc_list_tab(x_dc_list_tab.COUNT))  LOOP
                                        -- time_phased_atp
                                        IF ((l_atf_date is not null) and (p_atp_period.Period_Start_Date(i)<=l_atf_date) and (p_atp_period.Period_Start_Date(j)>l_atf_date)) THEN
                                                -- exit loop when crossing time fence
                                                j := p_atp_period.demand_class.COUNT+1;
                                        ELSIF (p_atp_period.backward_forward_quantity(j) <= 0
                                            -- time_phased_atp
                                            OR j < l_fw_nullifying_bucket_index)
                                        THEN
                                                --  forward one more period
                                                j := j+1 ;
                                        ELSE
                                                -- You can get something from here. So set the nullifying bucket index
                                                l_fw_nullifying_bucket_index := j;
                                                IF (p_atp_period.backward_forward_quantity(j) + p_atp_period.backward_forward_quantity(i) < 0) THEN
                                                        -- not enough to cover the shortage
                                                        p_atp_period.backward_forward_quantity(i) := p_atp_period.backward_forward_quantity(i) +
                                                                p_atp_period.backward_forward_quantity(j);
                                                        p_atp_period.backward_forward_quantity(j) := 0;
                                                        j := j + 1;
                                                ELSE
                                                        -- enough to cover the shortage
                                                        p_atp_period.backward_forward_quantity(j) := p_atp_period.backward_forward_quantity(j) +
                                                                p_atp_period.backward_forward_quantity(i);
                                                        p_atp_period.backward_forward_quantity(i) := 0;
                                                        EXIT;
                                                END IF;
                                        END IF;

                                        IF j > p_atp_period.demand_class.COUNT THEN
                                                EXIT;
                                        END IF;

                                END LOOP;
                        END IF;
                END IF;

        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' ||  '**********End Backward_Forward_Consume Procedure************');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Backward_Forward_Consume: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);

END Backward_Forward_Consume;



/*--Compute_Cum------------------------------------------------------------
|  o Does accumulation for all demand classes.
+-------------------------------------------------------------------------*/
PROCEDURE Compute_Cum(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_dc_list_tab                   IN              MRP_ATP_PUB.char80_arr,
        p_dc_start_index                IN              MRP_ATP_PUB.number_arr,
        p_dc_end_index                  IN              MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i PLS_INTEGER;
        j PLS_INTEGER;
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Cum: ' ||  '**********Begin Compute_Cum Procedure************');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- this for loop will do the acculumation
        FOR j in 1..p_dc_list_tab.COUNT LOOP

                FOR i in (p_dc_start_index(j) + 1)..p_dc_end_index(j) LOOP
                        p_atp_period.cumulative_quantity(i) := p_atp_period.cumulative_quantity(i) +
                                        p_atp_period.cumulative_quantity(i-1);
                END LOOP;

        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Cum: ' ||  '**********End Compute_Cum Procedure************');
        END IF;
EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Cum: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Compute_Cum;


/*--Compute_Cum------------------------------------------------------------
|  o Does accumulation for a specific demand class.
+-------------------------------------------------------------------------*/
PROCEDURE Compute_Cum_Individual(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              NUMBER,
        p_end_index                     IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i       PLS_INTEGER;
        l_cumm  NUMBER;
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Cum_Individual: ' ||  '**********Begin Compute_Cum_Individual Procedure************');
                msc_sch_wb.atp_debug('Compute_Cum_Individual: ' ||  'p_start_index : ' || p_start_index);
                msc_sch_wb.atp_debug('Compute_Cum_Individual: ' ||  'p_end_index : ' || p_end_index);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- this for loop will do the acculumation for one demand class
        -- this will also convert negatives to zero

        l_cumm := 0;
        FOR i in p_start_index..p_end_index LOOP
                l_cumm := p_atp_period.Adjusted_Availability_Quantity(i) + l_cumm;
                p_atp_period.cumulative_quantity(i) := GREATEST(l_cumm,0);
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                i := p_start_index;
                WHILE (i is not null) AND (i <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Compute_Cum_Individual: ' ||  'cum date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.cumulative_quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;
                msc_sch_wb.atp_debug('Compute_Cum_Individual: ' ||  '**********End Compute_Cum_Individual Procedure************');
        END IF;
EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Compute_Cum_Individual: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Compute_Cum_Individual;



/*--Adjust_Allocation_Details----------------------------------------------
|  o Called by Compute_Allocation_Details only for rule based case.
|  o Performs demand class consumption and forward consumption.
+-------------------------------------------------------------------------*/
PROCEDURE Adjust_Allocation_Details(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        x_dc_list_tab                   OUT     NOCOPY  MRP_ATP_PUB.char80_arr,
        x_dc_start_index                OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_dc_end_index                  OUT     NOCOPY  MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        l_return_status                 VARCHAR2(1);
        l_lowest_priority_demand_class  VARCHAR2(80);
        l_lowest_priority               PLS_INTEGER;
        l_lowest_found                  BOOLEAN := false;
        l_start_index                   PLS_INTEGER;
        l_end_index                     PLS_INTEGER;
        l_dc_count                      PLS_INTEGER;
        l_fw_consume_next               PLS_INTEGER := 0;
        l_lowest_cust_priority          PLS_INTEGER;
        l_lowest_site_priority          PLS_INTEGER;
        l_fw_consume_tab                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
        l_class_curr_steal_atp          MRP_ATP_PVT.ATP_Info;
        l_class_next_steal_atp          MRP_ATP_PVT.ATP_Info;
        l_partner_curr_steal_atp        MRP_ATP_PVT.ATP_Info;
        l_partner_next_steal_atp        MRP_ATP_PVT.ATP_Info;
        l_current_steal_atp             MRP_ATP_PVT.ATP_Info;
        l_next_steal_atp                MRP_ATP_PVT.ATP_Info;
        l_null_steal_atp                MRP_ATP_PVT.ATP_Info;
        i                               PLS_INTEGER;
        j                               PLS_INTEGER;
        mm                              PLS_INTEGER;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  '*********Begin procedure Adjust_Allocation_Details ********');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- IF G_ATP_FW_CONSUME_METHOD = 2 THEN
        -- if condition removed for bug 2763784 (ssurendr)
        -- always get unallocated figures
        -- Append unallocated records
        i := 1;
        WHILE (p_atp_period.demand_class(i) = p_atp_period.demand_class(1)) LOOP
                -- get data from 1st demand class
                MSC_SATP_FUNC.Extend_Atp_Period(p_atp_period, l_return_status);
                j := p_atp_period.Period_Start_Date.COUNT;

                p_atp_period.Demand_Class(j)            := G_UNALLOCATED_DC;
                p_atp_period.Period_Start_Date(j)       := p_atp_period.Period_Start_Date(i);
                p_atp_period.Total_Supply_Quantity(j)   := p_atp_period.Unallocated_Supply_Quantity(i);
                p_atp_period.Total_Demand_Quantity(j)   := p_atp_period.Unallocated_Demand_Quantity(i);
                p_atp_period.Period_Quantity(j)         := p_atp_period.Unallocated_Net_Quantity(i);
                p_atp_period.Period_End_Date(j)         := p_atp_period.Period_End_Date(i);
                p_atp_period.Inventory_Item_Id(j)       := p_atp_period.Inventory_Item_Id(i);
                p_atp_period.Organization_Id(j)         := p_atp_period.Organization_Id(i);
                p_atp_period.Identifier1(j)             := p_atp_period.Identifier1(i);
                p_atp_period.Scenario_Id(j)             := p_atp_period.Scenario_Id(i);
                p_atp_period.Level(j)                   := p_atp_period.Level(i);
                -- time_phased_atp
                p_atp_period.Total_Bucketed_Demand_Quantity(j)   := p_atp_period.Unalloc_Bucketed_Demand_Qty(i);

                i := p_atp_period.demand_class.Next(i);
        END LOOP;
        -- END IF;

        Backward_Consume(p_atp_period, x_dc_list_tab, x_dc_start_index, x_dc_end_index, l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Backward_Consume');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                FOR mm in 1..p_atp_period.demand_class.COUNT LOOP
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'DC:Date:Qty - ' || p_atp_period.demand_class(mm) || ':' ||
                                                p_atp_period.Period_Start_Date(mm) || ':' ||
                                                p_atp_period.Backward_Quantity(mm));
                END LOOP;
        END IF;

        -- Copy Adjusted_Availability_Quantity from Backward_Quantity
        p_atp_period.Adjusted_Availability_Quantity := p_atp_period.Backward_Quantity;

        -- IF G_ATP_FW_CONSUME_METHOD = 2 THEN
        -- if condition removed for bug 2763784 (ssurendr)
        -- always get unallocated figures
        -- Do f/w consumption and accumulation for unallocated records
        l_start_index := x_dc_start_index(x_dc_list_tab.COUNT);
        l_end_index := x_dc_end_index(x_dc_list_tab.COUNT);
        Forward_Consume(p_atp_period, l_start_index, l_end_index, l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Forward_Consume');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        /* rajjain 02/12/2003
         * Call to Compute_Cum_Individual procedure is not required in Method1
         * as Unallocated Cum will be calculated as part of Compute_Cum procedure*/
        IF G_ATP_FW_CONSUME_METHOD = 2 THEN
	        Compute_Cum_Individual(p_atp_period, l_start_index, l_end_index, l_return_status);
	        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	                IF PG_DEBUG in ('Y', 'C') THEN
	                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Compute_Cum_Individual');
	                END IF;
	                x_return_status := FND_API.G_RET_STS_ERROR;
	                return;
	        END IF;
        END IF;
        p_atp_period.Adjusted_Cum_Quantity := p_atp_period.Cumulative_Quantity;
        -- END IF;

        l_dc_count := x_dc_list_tab.LAST;
        -- IF G_ATP_FW_CONSUME_METHOD = 2 THEN
        -- if condition removed for bug 2763784 (ssurendr)
        -- always get unallocated figures
        l_dc_count := x_dc_list_tab.Prior(l_dc_count);
        -- subtract 1 bacause of unallocated records
        -- END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'l_dc_count: ' || l_dc_count);
        END IF;

        IF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) THEN
                -- Demand class case

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Demand class case.');
                END IF;

                j := l_dc_count;
                WHILE (j is not null) LOOP
                        IF p_atp_period.Identifier4(x_dc_start_index(j)) <> 0 THEN
                                l_lowest_priority_demand_class := x_dc_list_tab(j);
                                l_lowest_priority := p_atp_period.Identifier2(x_dc_start_index(j));
                                EXIT;
                        END IF;
                        j := x_dc_list_tab.Prior(j);
                END LOOP;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'l_lowest_priority_demand_class: ' || l_lowest_priority_demand_class);
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'l_lowest_priority: ' || l_lowest_priority);
                END IF;

                -- this for loop will do the demand class consumption
                FOR j in 1..l_dc_count LOOP

                        l_start_index := x_dc_start_index(j);
                        l_end_index := x_dc_end_index(j);

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'DC changed. limits : ' || l_start_index || ',' || l_end_index);
                        END IF;

                        IF (j > 1) THEN
                                IF p_atp_period.Identifier2(x_dc_start_index(j)) > p_atp_period.Identifier2(x_dc_start_index(j-1)) THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Priority changing. Changing l_current_steal_atp');
                                        END IF;
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_current_steal_atp);
                                        l_next_steal_atp := l_null_steal_atp;
                                END IF;
                        END IF;

                        IF p_atp_period.Identifier2(x_dc_start_index(j)) <> p_atp_period.Identifier2(1) THEN
                                -- We need to do demand class consumption only if we are not in
                                -- the highest priority
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Before doing DC consumption.');
                                END IF;
                                Demand_Class_Consumption(p_atp_period, l_start_index,
                                        l_end_index, l_current_steal_atp, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Demand_Class_Consumption(');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'After doing DC consumption.');
                                END IF;
                        END IF;

                        IF p_atp_period.Identifier2(x_dc_start_index(j)) < l_lowest_priority OR
                                G_ATP_FW_CONSUME_METHOD = 2 THEN
                                -- This is not the lowest priority DC. No need to do f/w consumption in Method 1
                                -- But we need to add to next steal
                                -- Two points to be noted:
                                -- 1. For Method 2 this is called even for lowest priority DC. This is an extra
                                --    overhead when compared to simply calling Remove_Nagatives. But this will
                                --    provide an OK solution for the corner case when the actual lowest priority DC
                                --    (which can be at a lower priority that l_lowest_priority) has 0 allocation %
                                --    on sysdate but non-zero on some future date.
                                -- 2. Even for method 1 the check is "higher than lowest priority" and not
                                --    "not equal to lowest priority". What this means is that DCs lower than
                                --    l_lowest_priority will do f/w consumtion for at least itself.
                                Add_to_Next_Steal(p_atp_period, l_start_index,
                                        l_end_index, l_next_steal_atp, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Next_Steal');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        ELSIF G_ATP_FW_CONSUME_METHOD = 1 THEN
                                -- Forward consumption is required only if G_ATP_FW_CONSUME_METHOD = 1
                                IF p_atp_period.Demand_Class(x_dc_start_index(j)) = l_lowest_priority_demand_class THEN
                                        -- Last demand class. Need to consider l_next_steal_atp's
                                        -- negatives before forward consumption
                                        Add_to_Current_Atp(p_atp_period, l_start_index,
                                        l_end_index, l_current_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                END IF;

                                Forward_Consume(p_atp_period, l_start_index, l_end_index, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Forward_Consume');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;

                                Remove_Negatives(p_atp_period, l_start_index, l_end_index, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Remove_Negatives');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        END IF;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                FOR mm in l_start_index..l_end_index LOOP
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'adjusted date:qty - '||
                                                p_atp_period.Period_Start_Date(mm) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(mm) );
                                END LOOP;
                        END IF;

                        IF G_ATP_FW_CONSUME_METHOD = 2 THEN
                                Compute_Cum_Individual(p_atp_period, l_start_index, l_end_index, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Compute_Cum_Individual');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;

                                Adjust_Cum(p_atp_period, l_start_index, l_end_index,
                                        x_dc_start_index(x_dc_list_tab.COUNT), x_dc_end_index(x_dc_list_tab.COUNT), l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Adjust_Cum');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;

                                IF PG_DEBUG in ('Y', 'C') THEN
                                        FOR mm in l_start_index..l_end_index LOOP
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'adjusted cum date:qty - '||
                                                        p_atp_period.Period_Start_Date(mm) ||' : '|| p_atp_period.Adjusted_Cum_Quantity(mm) );
                                        END LOOP;
                                END IF;
                        END IF;

                END LOOP;


        ELSIF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 2) THEN
                -- IF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) THEN
                -- Customer class heirarchy

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Customer class case.');
                END IF;

                IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                        -- steal from lower priority

                        -- Extend and initiallize l_fw_consume_tab
                        FOR j in 1..l_dc_count LOOP
                                l_fw_consume_tab.Extend;
                                l_fw_consume_tab(j) := 0;
                        END LOOP;

                        j := l_fw_consume_tab.LAST;
                        l_fw_consume_next := 4;

                        WHILE (j is not null) LOOP

                                IF l_fw_consume_next <> 0 THEN
                                        IF p_atp_period.Identifier4(x_dc_start_index(j)) <> 0 THEN
                                                IF l_fw_consume_next = 2 THEN
                                                        l_lowest_site_priority := p_atp_period.Identifier2(x_dc_start_index(j));
                                                ELSIF l_fw_consume_next IN (3,4) THEN
                                                        l_lowest_cust_priority := trunc(p_atp_period.Identifier2(x_dc_start_index(j)), -2);
                                                        l_lowest_site_priority := p_atp_period.Identifier2(x_dc_start_index(j));
                                                END IF;
                                                -- sysdate allocation percent was zero
                                                l_fw_consume_tab(j) := l_fw_consume_next;
                                                l_fw_consume_next := 0;
                                        ELSE
                                                l_fw_consume_tab(j) := 1;
                                        END IF;
                                ELSIF p_atp_period.Class(x_dc_start_index(j)) <> p_atp_period.Class(x_dc_start_index(j+1)) THEN
                                        -- customer class changed
                                        IF trunc(p_atp_period.Identifier2(x_dc_start_index(j)),-3) <>
                                                trunc(p_atp_period.Identifier2(x_dc_start_index(j+1)),-3) THEN
                                                -- customer class priority changed
                                                Exit;
                                        ELSE
                                                l_lowest_cust_priority := null;
                                                l_lowest_site_priority := null;
                                                IF p_atp_period.Identifier4(x_dc_start_index(j)) = 0 THEN
                                                        -- sysdate allocation percent is zero
                                                        l_fw_consume_next := 3;
                                                        l_fw_consume_tab(j) := 1;
                                                ELSE
                                                        l_fw_consume_tab(j) := 3;
                                                        l_lowest_cust_priority := trunc(p_atp_period.Identifier2(x_dc_start_index(j)), -2);
                                                        l_lowest_site_priority := p_atp_period.Identifier2(x_dc_start_index(j));
                                                END IF;
                                        END IF;
                                ELSIF p_atp_period.Customer_Id(x_dc_start_index(j)) <> p_atp_period.Customer_Id(x_dc_start_index(j+1)) THEN
                                        -- customer changed
                                        --reset the lowest site priority at this level to null
                                        l_lowest_site_priority := null;
                                        IF trunc(p_atp_period.Identifier2(x_dc_start_index(j)),-2) =
                                                trunc(p_atp_period.Identifier2(x_dc_start_index(j+1)),-2)
                                                AND (l_lowest_cust_priority IS NULL OR
                                                     l_lowest_cust_priority = trunc(p_atp_period.Identifier2(x_dc_start_index(j)),-2)) THEN
                                                -- customer priority did not change
                                                IF p_atp_period.Identifier4(x_dc_start_index(j)) = 0 THEN
                                                        -- sysdate allocation percent is zero
                                                        l_fw_consume_next := 2;
                                                        l_fw_consume_tab(j) := 1;
                                                ELSE
                                                        l_fw_consume_tab(j) := 2;
                                                        l_lowest_site_priority := p_atp_period.Identifier2(x_dc_start_index(j));
                                                END IF;
                                        END IF;
                                ELSIF p_atp_period.Identifier2(x_dc_start_index(j)) =
                                        p_atp_period.Identifier2(x_dc_start_index(j+1))
                                        AND (l_lowest_site_priority IS NULL OR
                                             l_lowest_site_priority = p_atp_period.Identifier2(x_dc_start_index(j))) THEN
                                        -- customer site priority did not change
                                        l_fw_consume_tab(j) := 1;
                                END IF;

                                j := l_fw_consume_tab.prior(j);

                        END LOOP;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                FOR mm in 1..l_fw_consume_tab.COUNT LOOP
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'priotity:l_fw_consume_tab(' || mm || ') = '
                                                        || p_atp_period.Identifier2(x_dc_start_index(mm)) || ':'
                                                        || l_fw_consume_tab(mm));
                                END LOOP;
                        END IF;

                ELSE    -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                        -- Steal from any priority

                        -- store lowest priority
                        l_lowest_priority := trunc(p_atp_period.Identifier2(x_dc_start_index(l_dc_count)),-3);

                END IF;

                -- this for loop will do the demand class consumption
                FOR j in 1..l_dc_count LOOP

                        l_start_index := x_dc_start_index(j);
                        l_end_index := x_dc_end_index(j);

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'DC changed. limits : ' || l_start_index || ',' || l_end_index);
                        END IF;

                        IF (j > 1) THEN
                                IF p_atp_period.Class(x_dc_start_index(j)) <> p_atp_period.Class(x_dc_start_index(j-1)) THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Class changing. Changing l_class_next_steal_atp');
                                        END IF;
                                        -- class_next += curr + next + partner_curr + partner_next
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_class_next_steal_atp);
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_class_next_steal_atp);
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp, l_class_next_steal_atp);
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_next_steal_atp, l_class_next_steal_atp);

                                        l_current_steal_atp := l_null_steal_atp;
                                        l_next_steal_atp := l_null_steal_atp;
                                        l_partner_curr_steal_atp := l_null_steal_atp;
                                        l_partner_next_steal_atp := l_null_steal_atp;

                                        IF trunc(p_atp_period.Identifier2(x_dc_start_index(j)),-3) > trunc(p_atp_period.Identifier2(x_dc_start_index(j-1)),-3) THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Class priority changing. Changing l_class_curr_steal_atp');
                                                END IF;
                                                -- class_curr += class_next
                                                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_class_next_steal_atp, l_class_curr_steal_atp);
                                                l_class_next_steal_atp := l_null_steal_atp;
                                        END IF;

                                ELSIF p_atp_period.Customer_Id(x_dc_start_index(j)) <> p_atp_period.Customer_Id(x_dc_start_index(j-1)) THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Customer changing. Changing l_partner_next_steal_atp');
                                        END IF;
                                        -- partner_next += curr + next
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_partner_next_steal_atp);
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);

                                        l_current_steal_atp := l_null_steal_atp;
                                        l_next_steal_atp := l_null_steal_atp;

                                        IF trunc(p_atp_period.Identifier2(x_dc_start_index(j)),-2) > trunc(p_atp_period.Identifier2(x_dc_start_index(j-1)),-2) THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Customer priority changing. Changing l_partner_curr_steal_atp');
                                                END IF;
                                                -- partner_curr += partner_next
                                                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_next_steal_atp, l_partner_curr_steal_atp);
                                                l_partner_next_steal_atp := l_null_steal_atp;
                                        END IF;

                                ELSIF p_atp_period.Identifier2(x_dc_start_index(j)) > p_atp_period.Identifier2(x_dc_start_index(j-1)) THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Priority changing. Changing l_current_steal_atp');
                                        END IF;
                                        -- curr += next
                                        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_current_steal_atp);
                                        l_next_steal_atp := l_null_steal_atp;
                                END IF;
                        END IF;

                        IF p_atp_period.Class(x_dc_start_index(j)) <> p_atp_period.Class(1) THEN
                                -- We need to do demand class consumption with l_class_curr_steal_atp only
                                -- if we are not in the first demand class
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Before doing DC consumption with l_class_curr_steal_atp.');
                                END IF;
                                Demand_Class_Consumption(p_atp_period, l_start_index,
                                        l_end_index, l_class_curr_steal_atp, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Demand_Class_Consumption');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'After doing DC consumption with l_class_curr_steal_atp.');
                                END IF;
                        END IF;

                        -- Customer_Id is not unique because it is -1 for 'Other' at each level.
                        -- Therefore class also needs to be in the condition.
                        IF (p_atp_period.Class(x_dc_start_index(j)) <> p_atp_period.Class(1)) OR
                                (p_atp_period.Customer_Id(x_dc_start_index(j)) <> p_atp_period.Customer_Id(1)) THEN
                                -- We need to do demand class consumption with l_partner_curr_steal_atp only
                                -- if we are not in the first customer
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Before doing DC consumption with l_partner_curr_steal_atp.');
                                END IF;
                                Demand_Class_Consumption(p_atp_period, l_start_index,
                                        l_end_index, l_partner_curr_steal_atp, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Demand_Class_Consumption');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'After doing DC consumption with l_partner_curr_steal_atp.');
                                END IF;
                        END IF;

                        IF p_atp_period.Identifier2(x_dc_start_index(j)) <> p_atp_period.Identifier2(1) THEN
                                -- We need to do demand class consumption only if we are not in
                                -- the highest priority
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Before doing DC consumption.');
                                END IF;
                                Demand_Class_Consumption(p_atp_period, l_start_index,
                                        l_end_index, l_current_steal_atp, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Demand_Class_Consumption');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'After doing DC consumption.');
                                END IF;
                        END IF;

                        IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                                -- steal from lower priority
                                IF l_fw_consume_tab(j) = 0 THEN
                                        -- No need to do f/w consumption, but we need to add to next steal
                                        Add_to_Next_Steal(p_atp_period, l_start_index, l_end_index, l_next_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Next_Steal');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                ELSIF l_fw_consume_tab(j) = 1 THEN
                                        -- Do f/w consumption for only one's own negatives
                                                Forward_Consume(p_atp_period, l_start_index, l_end_index, l_return_status);
                                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Forward_Consume');
                                                        END IF;
                                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                                        return;
                                                END IF;
                                ELSIF l_fw_consume_tab(j) = 2 THEN
                                        -- Do f/w consumption for only one's own negatives + negatives from higher
                                        -- priority customer sites under the same customer
                                        Add_to_Current_Atp(p_atp_period, l_start_index, l_end_index, l_current_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;

                                        l_current_steal_atp := l_null_steal_atp;

                                        Forward_Consume(p_atp_period, l_start_index, l_end_index, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Forward_Consume');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                ELSIF l_fw_consume_tab(j) = 3 THEN
                                        -- Do f/w consumption for only one's own negatives + negatives from higher
                                        -- priority customer sites under the same customer + negatives from higher
                                        -- priority customers under the same customer class
                                        Add_to_Current_Atp(p_atp_period, l_start_index, l_end_index, l_current_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;

                                        Add_to_Current_Atp(p_atp_period, l_start_index, l_end_index, l_partner_curr_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;

                                        l_current_steal_atp := l_null_steal_atp;
                                        l_partner_curr_steal_atp := l_null_steal_atp;

                                        Forward_Consume(p_atp_period, l_start_index, l_end_index, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Forward_Consume');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                ELSE
                                        -- Do f/w consumption for only one's own negatives + negatives from higher
                                        -- priority customer sites under the same customer + negatives from higher
                                        -- priority customers under the same customer class + negatives from higher
                                        -- priority customer classes
                                        Add_to_Current_Atp(p_atp_period, l_start_index, l_end_index, l_current_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;

                                        Add_to_Current_Atp(p_atp_period, l_start_index, l_end_index, l_partner_curr_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;

                                        Add_to_Current_Atp(p_atp_period, l_start_index, l_end_index, l_class_curr_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Current_Atp');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;

                                        l_current_steal_atp := l_null_steal_atp;
                                        l_partner_curr_steal_atp := l_null_steal_atp;
                                        l_class_curr_steal_atp := l_null_steal_atp;

                                        Forward_Consume(p_atp_period, l_start_index, l_end_index, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Forward_Consume');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                END IF;
                                Remove_Negatives(p_atp_period, l_start_index, l_end_index, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Remove_Negatives');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        ELSE    -- IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                                -- steal from any priority
                                -- For Method 2 Add_to_Next_Steal is called even for all DCs. This is an extra
                                -- overhead when compared to simply calling Remove_Nagatives for lowest priority DC.
                                -- But this will provide an OK solution for the corner case when the actual lowest
                                -- priority DC (which can be at a lower priority that l_lowest_priority) has
                                -- 0 allocation % on sysdate but non-zero on some future date.
                                IF p_atp_period.Identifier2(x_dc_start_index(j)) <> l_lowest_priority THEN
                                        -- This is not the lowest priority DC.
                                        -- Need to add to next steal
                                        Add_to_Next_Steal(p_atp_period, l_start_index,
                                                l_end_index, l_next_steal_atp, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Add_to_Next_Steal');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                ELSE
                                        Remove_Negatives(p_atp_period, l_start_index, l_end_index, l_return_status);
                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Remove_Negatives');
                                                END IF;
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                return;
                                        END IF;
                                END IF;

                                Compute_Cum_Individual(p_atp_period, l_start_index, l_end_index, l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Compute_Cum_Individual');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;

                                Adjust_Cum(p_atp_period, l_start_index, l_end_index,
                                        x_dc_start_index(x_dc_list_tab.COUNT), x_dc_end_index(x_dc_list_tab.COUNT), l_return_status);
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Adjust_Cum');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;

                                IF PG_DEBUG in ('Y', 'C') THEN
                                        FOR mm in l_start_index..l_end_index LOOP
                                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'adjusted cum date:qty - '||
                                                        p_atp_period.Period_Start_Date(mm) ||' : '|| p_atp_period.Adjusted_Cum_Quantity(mm) );
                                        END LOOP;
                                END IF;
                        END IF;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                FOR mm in l_start_index..l_end_index LOOP
                                        msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'adjusted date:qty - '||
                                                p_atp_period.Period_Start_Date(mm) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(mm) );
                                END LOOP;
                        END IF;
                END LOOP;

        END IF; -- ELSIF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) THEN

        IF G_ATP_FW_CONSUME_METHOD = 1 THEN
                -- steal from lower priority

                -- Copy Cumulative Quantity from Adjusted_Availability_Quantity
                p_atp_period.Cumulative_Quantity := p_atp_period.Adjusted_Availability_Quantity;

                -- Call procedure Compute_Cum to do accumulation
                Compute_Cum(p_atp_period, x_dc_list_tab, x_dc_start_index, x_dc_end_index, l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  'Error occured in procedure Compute_Cum');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' ||  '**********End Adjust_Allocation_Details Procedure************');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Adjust_Allocation_Details: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Adjust_Allocation_Details;



/*--Demand_Class_Consumption-----------------------------------------------
|  o Performs demand class consumption.
+-------------------------------------------------------------------------*/
PROCEDURE Demand_Class_Consumption(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              number,
        p_end_index                     IN              number,
        p_steal_atp                     IN OUT  NOCOPY  MRP_ATP_PVT.ATP_Info,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i                       PLS_INTEGER; -- index for p_steal_atp
        j                       PLS_INTEGER; -- index for p_atp_period
        k                       PLS_INTEGER; -- starting point for consumption of p_current_atp
        m                       PLS_INTEGER;
        l_adjustment_quantity   number;
        -- time_phased_atp
        l_atf_date      DATE := MSC_ATP_ALLOC.G_ATF_Date;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  '*********Begin procedure Demand_Class_Consumption ********');
                m := p_start_index;
                WHILE (m is not null) AND (m <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  'current date:qty - '||
                                p_atp_period.Period_Start_Date(m) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(m) );
                        m := p_atp_period.Period_Start_Date.Next(m);
                END LOOP;

                m := p_steal_atp.atp_period.FIRST;
                WHILE m is not null LOOP
                        msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  'steal date:qty '||
                                p_steal_atp.atp_period(m) ||' : '|| p_steal_atp.atp_qty(m));
                        m := p_steal_atp.atp_period.Next(m);
                END LOOP;
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        k := p_start_index;

        -- i is the index for steal_atp
        FOR i in 1..p_steal_atp.atp_qty.COUNT LOOP

                -- consume current_atp (backward) if we have neg in steal_atp
                IF (p_steal_atp.atp_qty(i) < 0 ) THEN

                        k := NVL(k, 1); --  if k is null, make it as 1 so that
                                        --  we can find the starting point for the first
                                        --  element.

                        WHILE (k IS NOT NULL)  LOOP
                                IF k = p_end_index THEN
                                        -- this is the last record
                                        IF (p_atp_period.Period_Start_Date(k) > p_steal_atp.atp_period(i)) THEN
                                                -- cannot do any consumption since the date from p_steal_atp
                                                -- is greater than p_ccurrent_atp
                                                k := NULL;
                                        END IF;
                                        EXIT; -- exit the loop since this is the last record
                                ELSE
                                        -- this is not the last record
                                        IF ((p_atp_period.Period_Start_Date(k) <= p_steal_atp.atp_period(i))
                                                AND (p_atp_period.Period_Start_Date(k+1) > p_steal_atp.atp_period(i))) THEN
                                                -- this is the starting point, we can exit now
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                        msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  'exit at k = ' ||to_char(k)||' and i = ' ||to_char(i));
                                                END IF;
                                                EXIT;
                                        ELSE
                                                k := p_atp_period.Period_Start_Date.NEXT(k);
                                        END IF;
                                END IF;
                        END LOOP;

                        j:= k;

                        WHILE (NVL(j, -1) >= p_start_index) LOOP
                                -- time_phased_atp
                                IF ((l_atf_date is not null) and (p_steal_atp.atp_period(i)>l_atf_date) and (p_atp_period.Period_Start_Date(j)<=l_atf_date)) THEN
                                        -- exit loop when crossing time fence
                                        j := 0;
                                ELSIF (p_atp_period.Adjusted_Availability_Quantity(j) < 0) THEN
                                        -- Since backward consumption has been done, a negative here
                                        -- means that all previous would be negative. So no need to continue
                                        j := -1;
                                ELSIF (p_atp_period.Adjusted_Availability_Quantity(j) =0) THEN
                                        --  backward one more period
                                        j := j-1 ;
                                ELSE
                                        -- There will be some adjustment
                                        IF (p_atp_period.Adjusted_Availability_Quantity(j) + p_steal_atp.atp_qty(i)< 0) THEN
                                                -- not enough to cover the shortage
                                                p_steal_atp.atp_qty(i) := p_steal_atp.atp_qty(i) +
                                                        p_atp_period.Adjusted_Availability_Quantity(j);
                                                l_adjustment_quantity := - p_atp_period.Adjusted_Availability_Quantity(j);
                                                p_atp_period.Adjusted_Availability_Quantity(j) := 0;
                                        ELSE
                                                -- enough to cover the shortage
                                                p_atp_period.Adjusted_Availability_Quantity(j) := p_steal_atp.atp_qty(i) +
                                                        p_atp_period.Adjusted_Availability_Quantity(j);
                                                l_adjustment_quantity := p_steal_atp.atp_qty(i);
                                                p_steal_atp.atp_qty(i) := 0;
                                        END IF;

                                        -- Update demand adjustment quantity
                                        m := j;
                                        WHILE (m is not null) AND (m <= p_end_index) LOOP
                                                IF p_atp_period.Period_Start_Date(m) = p_steal_atp.atp_period(i) THEN
                                                        p_atp_period.Demand_Adjustment_Quantity(m) := p_atp_period.Demand_Adjustment_Quantity(m) +
                                                                l_adjustment_quantity;
                                                        EXIT;
                                                END IF;
                                                m := p_atp_period.Period_Start_Date.Next(m);
                                        END LOOP;

                                        IF p_steal_atp.atp_qty(i) = 0 THEN
                                                -- shortage has been covered
                                                j := -1;
                                        ELSE
                                                -- shortage has not been covered
                                                j := j - 1;
                                        END IF;
                                END IF;
                        END LOOP;
                END IF;
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                m := p_start_index;
                WHILE (m is not null) AND (m <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  'current date:qty - '||
                                p_atp_period.Period_Start_Date(m) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(m) );
                        m := p_atp_period.Period_Start_Date.Next(m);
                END LOOP;

                m := p_steal_atp.atp_period.FIRST;
                WHILE m is not null LOOP
                        msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  'steal date:qty '||
                                p_steal_atp.atp_period(m) ||' : '|| p_steal_atp.atp_qty(m));
                        m := p_steal_atp.atp_period.Next(m);
                END LOOP;

                msc_sch_wb.atp_debug('Demand_Class_Consumption: ' ||  '*********End procedure Demand_Class_Consumption ********');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Demand_Class_Consumption: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Demand_Class_Consumption;


/*--Add_to_Next_Steal------------------------------------------------------
|  o Same as MSC_AATP_PVT.Add_to_Next_Steal_Atp except for the input
|    parameters.
+-------------------------------------------------------------------------*/
PROCEDURE Add_to_Next_Steal(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              number,
        p_end_index                     IN              number,
        p_next_steal_atp                IN OUT  NOCOPY  MRP_ATP_PVT.ATP_Info,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i                       PLS_INTEGER;            -- index for p_atp_period
        j                       PLS_INTEGER;            -- index for p_next_steal_atp
        k                       PLS_INTEGER;            -- index for l_next_steal_atp
        n                       PLS_INTEGER;            -- starting point of p_next_steal_atp
        l_next_steal_atp        MRP_ATP_PVT.ATP_Info;   -- this will be the output
        l_processed             BOOLEAN := FALSE ;
BEGIN
        -- this procedure will combine p_atp_period and p_next_steal_atp to form
        -- a new record of tables and then return as p_next_steal_atp.
        -- they need to be ordered by date.
        -- The only difference between this version of the procedure and the one in MSCAATPB is that
        -- this accepts start/end indices to restrict the operation

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_to_Next_Steal: ' ||  '*********Begin procedure Add_to_Next_Steal ********');

                i := p_start_index;
                WHILE (i is not null) AND (i <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Add_to_Next_Steal: ' ||  'current date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;

                i := p_next_steal_atp.atp_period.FIRST;
                WHILE i is not null LOOP
                        msc_sch_wb.atp_debug('Add_to_Next_Steal: ' ||  'steal date:qty '||
                                p_next_steal_atp.atp_period(i) ||' : '|| p_next_steal_atp.atp_qty(i));
                        i := p_next_steal_atp.atp_period.Next(i);
                END LOOP;
        END IF;

        j := p_next_steal_atp.atp_period.FIRST;
        k := 0;
        FOR i IN p_start_index..p_end_index LOOP
                IF p_atp_period.Adjusted_Availability_Quantity(i) < 0 THEN
                        l_processed := FALSE;
                        WHILE (j IS NOT NULL) LOOP
                                IF p_next_steal_atp.atp_qty(j) < 0 THEN

                                        k := k+1;
                                        l_next_steal_atp.atp_period.Extend;
                                        l_next_steal_atp.atp_qty.Extend;

                                        IF p_next_steal_atp.atp_period(j) < p_atp_period.Period_Start_Date(i) THEN

                                                -- we add this to l_next_steal_atp
                                                l_next_steal_atp.atp_period(k) := p_next_steal_atp.atp_period(j);
                                                l_next_steal_atp.atp_qty(k) := p_next_steal_atp.atp_qty(j);

                                        ELSIF p_next_steal_atp.atp_period(j)=p_atp_period.Period_Start_Date(i) THEN

                                                -- both record (p_next_steal_atp and p_atp_period) are on the same
                                                -- date.  we need to sum them up
                                                l_processed := TRUE;
                                                l_next_steal_atp.atp_period(k) := p_next_steal_atp.atp_period(j);
                                                l_next_steal_atp.atp_qty(k) := p_next_steal_atp.atp_qty(j) +
                                                        p_atp_period.Adjusted_Availability_Quantity(i);
                                                p_atp_period.Adjusted_Availability_Quantity(i) := 0;
                                                -- to show non-negative availability and to remove negative accumulation
                                                j := p_next_steal_atp.atp_period.NEXT(j);
                                                EXIT;
                                                -- subsequent records will be covered in next iteration of the outer
                                                -- FOR loop. so we don't need to go to next record any more
                                        ELSE -- this is the greater part
                                                l_processed := TRUE;
                                                l_next_steal_atp.atp_period(k) := p_atp_period.Period_Start_Date(i);
                                                l_next_steal_atp.atp_qty(k) := p_atp_period.Adjusted_Availability_Quantity(i);
                                                p_atp_period.Adjusted_Availability_Quantity(i) := 0;
                                                -- to show non-negative availability and to remove negative accumulation
                                                EXIT;
                                                -- subsequent records will be covered in next iteration of the outer
                                                -- FOR loop. so we don't need to go to next record any more
                                                -- Also j is not incremented as p_next_steal_atp(j)'s negative
                                                -- has not been considered as yet.
                                        END IF;
                                END IF; -- p_next_steal_atp.atp_qty < 0

                                j := p_next_steal_atp.atp_period.NEXT(j) ;
                        END LOOP;

                        IF (j is null) AND (l_processed = FALSE) THEN
                                -- this means p_next_steal_atp is over,
                                -- so we don't need to worry about p_next_steal_atp,
                                -- we just keep add p_atp_period to l_next_steal_atp
                                -- if they are not added before
                                k := k+1;
                                l_next_steal_atp.atp_period.Extend;
                                l_next_steal_atp.atp_qty.Extend;

                                l_next_steal_atp.atp_period(k) := p_atp_period.Period_Start_Date(i);
                                l_next_steal_atp.atp_qty(k) := p_atp_period.Adjusted_Availability_Quantity(i);
                                p_atp_period.Adjusted_Availability_Quantity(i) := 0;
                                -- to show non-negative availability and to remove negative accumulation
                        END IF;

                END IF; -- p_current_atp.atp_qty < 0
        END LOOP;

        -- now we have taken care of all p_atp_period and part of
        -- p_next_steal_atp. now we need to take care the rest of p_next_steal_atp

        WHILE j is not null LOOP
                IF p_next_steal_atp.atp_qty(j) < 0 THEN
                        -- we add this to l_next_steal_atp
                        k := k+1;
                        l_next_steal_atp.atp_period.Extend;
                        l_next_steal_atp.atp_qty.Extend;
                        l_next_steal_atp.atp_period(k) := p_next_steal_atp.atp_period(j);
                        l_next_steal_atp.atp_qty(k) := p_next_steal_atp.atp_qty(j);
                END IF;
                j := p_next_steal_atp.atp_period.NEXT(j);
        END LOOP;

        p_next_steal_atp := l_next_steal_atp;

        IF PG_DEBUG in ('Y', 'C') THEN
                i := p_start_index;
                WHILE (i is not null) AND (i <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Add_to_Next_Steal: ' ||  'current date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;

                i := p_next_steal_atp.atp_period.FIRST;
                WHILE i is not null LOOP
                        msc_sch_wb.atp_debug('Add_to_Next_Steal: ' ||  'steal date:qty '||
                                p_next_steal_atp.atp_period(i) ||' : '|| p_next_steal_atp.atp_qty(i));
                        i := p_next_steal_atp.atp_period.Next(i);
                END LOOP;

                msc_sch_wb.atp_debug('Add_to_Next_Steal: ' ||  '*********End procedure Add_to_Next_Steal ********');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_to_Next_Steal: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Add_to_Next_Steal;



/*--Add_to_Current_Atp-----------------------------------------------------
|  o Same as MSC_AATP_PROC.Add_to_current_atp except for the input
|    parameters.
+-------------------------------------------------------------------------*/
PROCEDURE Add_to_Current_Atp(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              number,
        p_end_index                     IN              number,
        p_steal_atp                     IN              MRP_ATP_PVT.ATP_Info,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i                       PLS_INTEGER;            -- index for p_atp_period
        j                       PLS_INTEGER;            -- index for p_steal_atp
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_to_Current_Atp: ' ||  '*********Begin procedure Add_to_Current_Atp ********');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- this procedure will add p_steal_atp's negatives in p_atp_period.
        -- It is assumed here that the dates in p_steal_atp is always a subset of dates in p_atp_period

        i := p_start_index;
        j := p_steal_atp.atp_period.FIRST;
        WHILE (j IS NOT NULL) LOOP

                IF p_steal_atp.atp_qty(j) < 0 THEN
                        WHILE (i is not null) AND (i <= p_end_index) LOOP
                                IF p_atp_period.Period_Start_Date(i) = p_steal_atp.atp_period(j) THEN
                                        p_atp_period.Demand_Adjustment_Quantity(i) := p_steal_atp.atp_qty(j) +
                                                nvl(p_atp_period.Demand_Adjustment_Quantity(i),0);
                                        p_atp_period.Adjusted_Availability_Quantity(i) := p_steal_atp.atp_qty(j) +
                                                p_atp_period.Adjusted_Availability_Quantity(i);
                                        EXIT;
                                END IF;
                                i := p_atp_period.Period_Start_Date.Next(i);
                        END LOOP;
                END IF;
                j := p_steal_atp.atp_period.Next(j);
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                i := p_start_index;
                WHILE (i is not null) AND (i <= p_end_index) LOOP
                        msc_sch_wb.atp_debug('Add_to_Current_Atp: ' ||  'current date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Availability_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;

                i := p_steal_atp.atp_period.FIRST;
                WHILE i is not null LOOP
                        msc_sch_wb.atp_debug('Add_to_Current_Atp: ' ||  'steal date:qty '||
                                p_steal_atp.atp_period(i) ||' : '|| p_steal_atp.atp_qty(i));
                        i := p_steal_atp.atp_period.Next(i);
                END LOOP;

                msc_sch_wb.atp_debug('Add_to_Current_Atp: ' ||  '*********End procedure Add_to_Current_Atp ********');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_to_Current_Atp: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Add_to_Current_Atp;


/*--Remove_Negatives-------------------------------------------------------
|  o Same as MSC_AATP_PROC.Atp_Remove_Negatives except for the input
|    parameters.
+-------------------------------------------------------------------------*/
PROCEDURE Remove_Negatives(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_start_index                   IN              NUMBER,
        p_end_index                     IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i                       PLS_INTEGER;            -- index for p_atp_period
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Remove_Negatives: ' || '*********Begin procedure Remove_Negatives ********');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- this procedure will remove negatives

        FOR i IN p_start_index..p_end_index LOOP
                IF p_atp_period.Adjusted_Availability_Quantity(i) < 0 THEN
                        p_atp_period.Adjusted_Availability_Quantity(i) := 0;
                END IF;
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Remove_Negatives: ' || '*********End procedure Remove_Negatives ********');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Remove_Negatives: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Remove_Negatives;


/*--Adjust_Cum-------------------------------------------------------------
|  o Same as MSC_AATP_PROC.Atp_Adjusted_Cum except for the input
|    parameters.
+-------------------------------------------------------------------------*/
PROCEDURE Adjust_Cum(
        p_atp_period                    IN OUT  NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
        p_cur_start_index               IN              NUMBER,
        p_cur_end_index                 IN              NUMBER,
        p_unalloc_start_index           IN              NUMBER,
        p_unalloc_end_index             IN              NUMBER,
        x_return_status                 OUT     NOCOPY  VARCHAR2)
IS
        i                       PLS_INTEGER;
        j                       PLS_INTEGER;
BEGIN

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Adjust_Cum: ' || '**********Begin Adjust_Cum Procedure************');
        END IF;

        --rajjain 02/11/2003 Bug 2793336 Begin
        i := p_unalloc_end_index;
        j := p_cur_end_index;
        WHILE i >= p_unalloc_start_index LOOP
                -- do adjustment
                p_atp_period.Adjusted_Cum_Quantity(j) := GREATEST(LEAST(p_atp_period.Cumulative_Quantity(j),
                        p_atp_period.Adjusted_Cum_Quantity(i)), 0);
                p_atp_period.Adjusted_Cum_Quantity(i) := p_atp_period.Adjusted_Cum_Quantity(i) -
                        p_atp_period.Adjusted_Cum_Quantity(j);

                IF i <> p_unalloc_end_index
                  AND p_atp_period.Adjusted_Cum_Quantity(i) > p_atp_period.Adjusted_Cum_Quantity(i+1)
                THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug ('Adjust_Cum: ' || 'Unallocated Cum date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Cum_Quantity(i) );
                   END IF;
                   p_atp_period.Adjusted_Cum_Quantity(i) := p_atp_period.Adjusted_Cum_Quantity(i+1);
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug ('Adjust_Cum: ' || 'Updated Unallocated Cum date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Cum_Quantity(i) );
                   END IF;
                END IF;
                i := p_atp_period.Period_Start_Date.PRIOR(i);
                j := p_atp_period.Period_Start_Date.PRIOR(j);
        END LOOP;
        --rajjain 02/11/2003 Bug 2793336 End

        IF PG_DEBUG in ('Y', 'C') THEN
                i := p_cur_start_index;
                WHILE (i is not null) AND (i <= p_cur_end_index) LOOP
                        msc_sch_wb.atp_debug('Adjust_Cum: ' || 'cur adjusted cum date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Cum_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;

                i := p_unalloc_start_index;
                WHILE (i is not null) AND (i <= p_unalloc_end_index) LOOP
                        msc_sch_wb.atp_debug('Adjust_Cum: ' || 'unalloc cum date:qty - '||
                                p_atp_period.Period_Start_Date(i) ||' : '|| p_atp_period.Adjusted_Cum_Quantity(i) );
                        i := p_atp_period.Period_Start_Date.Next(i);
                END LOOP;

                msc_sch_wb.atp_debug('Adjust_Cum: ' || '**********End Adjust_Cum Procedure************');
        END IF;

EXCEPTION
WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Adjust_Cum: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Set_Error(MSC_ATP_PVT.ATP_PROCESSING_ERROR);
END Adjust_Cum;


/*--Set_Error--------------------------------------------------------------
|  o Set error code if it has already not been set
+-------------------------------------------------------------------------*/
PROCEDURE Set_Error(
        p_error_code                    IN      INTEGER)
IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Set_Error: ' || 'Old Error: ' || to_char(MSC_SCH_WB.G_ATP_ERROR_CODE));
                msc_sch_wb.atp_debug('Set_Error: ' || 'New Error: ' || to_char(p_error_code));
        END IF;
        -- Setting API return code
        IF MSC_SCH_WB.G_ATP_ERROR_CODE = 0 THEN
                MSC_SCH_WB.G_ATP_ERROR_CODE := p_error_code;
        END IF;

END Set_Error;


-- Added function to call the refresh allocation concurrent program
-- from database package.
-- fix for bug 2781625
function Refresh_Alloc_request(
                     p_new_session_id in number ,
                     p_inventory_item_id in number ,
                     p_instance_id in number ,
                     p_organization_id in number ) return number IS
l_return_code number;
begin
        l_return_code:= Fnd_Request.Submit_Request('MSC',
                                                'MSC_ATP_REFRESH_WB',
                                                 '',
                                                 '',
                                                 FALSE,
                                                 p_new_session_id,
                                                 p_inventory_item_id,
                                                 p_instance_id,
                                                 p_organization_id);
        if l_return_code <> 0 then
                commit;
        end if;
        return l_return_code;
end Refresh_Alloc_request;

END MSC_ATP_ALLOC;

/

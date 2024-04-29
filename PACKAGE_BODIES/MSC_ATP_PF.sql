--------------------------------------------------------
--  DDL for Package Body MSC_ATP_PF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_PF" AS
/* $Header: MSCPFATB.pls 120.7.12010000.3 2009/08/24 07:03:46 sbnaik ship $  */

/*--------------------------------------------------------------------------
|  Begin Private Package Variables
+-------------------------------------------------------------------------*/
G_PKG_NAME              CONSTANT VARCHAR2(30)   := 'MSC_ATP_PF';
PG_DEBUG                VARCHAR2(1)             := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');
G_CAL_EXC_SET_ID        CONSTANT INTEGER        := -1;
G_USER_ID               CONSTANT NUMBER         := FND_GLOBAL.USER_ID;
MEMBER                  CONSTANT NUMBER         := 1;
FAMILY                  CONSTANT NUMBER         := 2;

/*--------------------------------------------------------------------------
|  Begin Private Procedures Declaration
+-------------------------------------------------------------------------*/

PROCEDURE Calc_Bucketed_Demands_Info(
        p_req_date                      IN      DATE,
        p_atf_date                      IN      DATE,
        p_req_qty                       IN      NUMBER,
        p_req_date_qty                  IN      NUMBER,
        p_atf_date_qty                  IN      NUMBER,
        x_bucketed_demands_rec          OUT     NOCOPY Bucketed_Demands_Rec,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Insert_Bucketed_Demand(
        p_atp_rec          		IN	MRP_ATP_PVT.AtpRec,
        p_plan_id          		IN	NUMBER,
        p_bucketed_demand_date          IN	DATE,
        p_bucketed_demand_qty           IN	NUMBER,
        p_display_flag                  IN	NUMBER,
        p_parent_demand_id 		IN	NUMBER,
        p_level                         IN      NUMBER,
        p_refresh_number                IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Move_PF_Bd_Dates(
        p_plan_id                       IN	NUMBER,
        p_parent_demand_id              IN	NUMBER,
        p_old_demand_date               IN	DATE,
        p_new_demand_date               IN	DATE,
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Mat_Avail_Pf_Ods_Summ(
        p_item_id                       IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Mat_Avail_Pf_Ods(
        p_item_id                       IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_cal_code                      IN      VARCHAR2,
        p_sysdate_seq_num               IN      NUMBER,
        p_sys_next_date                 IN      DATE,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Mat_Avail_Pf_Pds_Summ(
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        p_refresh_number                IN      NUMBER,     -- For summary enhancement
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Mat_Avail_Pf_Pds(
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Mat_Avail_Pf_Ods_Dtls (
        p_item_id                       IN      NUMBER,
        p_request_item_id               IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_cal_code                      IN      VARCHAR2,
        p_sysdate_seq_num               IN      NUMBER,
        p_sys_next_date                 IN      DATE,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        p_level                         IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_identifier                    IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Mat_Avail_Pf_Pds_Dtls (
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        p_level                         IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_identifier                    IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

-- New private procedure added for forecast at PF
PROCEDURE Prepare_Demands_Stmt(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_alloc_temp_table              IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

-- New private procedure added for forecast at PF
PROCEDURE Prepare_Supplies_Stmt(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_alloc_temp_table              IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

/* Private procedures removed for forecast at PF **Will be deleted after code review
PROCEDURE Prepare_Demands_Stmt1(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Prepare_Demands_Stmt2(
	p_share_partition               IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Prepare_Supplies_Stmt1(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Prepare_Supplies_Stmt2(
	p_share_partition               IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);
*/

PROCEDURE Update_Pf_Display_Flag(
	p_plan_id                       IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------------
|  End Private Procedures Declaration
+-------------------------------------------------------------------------*/

/*--Add_PF_Bucketed_Demands-------------------------------------------------
|  o  This procedure is called from Add_Mat_Demand to add the bucketed
|       demands for the parent demand.
|  o  This procedure calls private procedure Insert_Bucketed_Demand to
|       add the bucketed demands
+-------------------------------------------------------------------------*/
PROCEDURE Add_PF_Bucketed_Demands(
        p_atp_rec          		IN	MRP_ATP_PVT.AtpRec,
        p_plan_id          		IN	NUMBER,
        p_parent_demand_id 		IN	NUMBER,
        p_refresh_number                IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_bucketed_demands_rec          Bucketed_Demands_Rec;
        l_req_date                      DATE;
        l_atf_date                      DATE;
        l_req_qty                       NUMBER;
        l_req_date_qty                  NUMBER;
        l_atf_date_qty                  NUMBER;
        l_return_status                 VARCHAR2(1);

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Add_PF_Bucketed_Demands ********');
                msc_sch_wb.atp_debug('Add_PF_Bucketed_Demands: ' ||  'demand_source_type = ' ||p_atp_rec.demand_source_type);--cmro
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_req_date      := p_atp_rec.requested_ship_date;
        l_atf_date      := p_atp_rec.atf_date;
        l_req_qty       := nvl(p_atp_rec.quantity_ordered, 0);
        l_req_date_qty  := greatest(nvl(p_atp_rec.requested_date_quantity, 0), 0);
        /* Assumption is that atf date qty passed to this procedure can be null only
           in scenario where we find req qty within atf*/
        --bug3919371  When Atf date qty is null then
        --            1. Treat requested_date_quantity as atf_date_qty if req date after atf.
        --            2. Treat p_atp_rec.quantity_ordered as atf_date_qty if req date within atf.

        IF l_req_date > l_atf_date THEN
           l_atf_date_qty  := greatest(nvl(p_atp_rec.atf_date_quantity, l_req_date_qty), 0);
        ELSE
           l_atf_date_qty  := greatest(nvl(p_atp_rec.atf_date_quantity, l_req_qty), 0);
        END IF;

        Calc_Bucketed_Demands_Info(
                l_req_date,
                l_atf_date,
                l_req_qty,
                l_req_date_qty,
                l_atf_date_qty,
                l_bucketed_demands_rec,
                l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Bucketed_Demands: ' || 'Error occured in procedure Calc_Bucketed_Demands_Info');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        IF l_bucketed_demands_rec.insert_mem_bd = 'Y' and l_bucketed_demands_rec.mem_bd_qty > 0 THEN
                Insert_Bucketed_Demand(
                        p_atp_rec,
                        p_plan_id,
                        l_bucketed_demands_rec.mem_bd_date,
                        l_bucketed_demands_rec.mem_bd_qty,
                        l_bucketed_demands_rec.mem_display_flag,
                        p_parent_demand_id,
                        member, -- member item bd
                        p_refresh_number,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Add_PF_Bucketed_Demands: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;
        END IF;

        IF l_bucketed_demands_rec.insert_pf_bd = 'Y' and l_bucketed_demands_rec.pf_bd_qty > 0 THEN
                Insert_Bucketed_Demand(
                        p_atp_rec,
                        p_plan_id,
                        l_bucketed_demands_rec.pf_bd_date,
                        l_bucketed_demands_rec.pf_bd_qty,
                        l_bucketed_demands_rec.pf_display_flag,
                        p_parent_demand_id,
                        family, -- family item bd
                        p_refresh_number,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Add_PF_Bucketed_Demands: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Add_PF_Bucketed_Demands ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Bucketed_Demands: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Add_PF_Bucketed_Demands;

/*--Calc_Bucketed_Demands_Info----------------------------------------------
|  o  This procedure calculates bucketed demands information
+-------------------------------------------------------------------------*/
PROCEDURE Calc_Bucketed_Demands_Info(
        p_req_date              IN      DATE,
        p_atf_date              IN      DATE,
        p_req_qty               IN      NUMBER,
        p_req_date_qty          IN      NUMBER,
        p_atf_date_qty          IN      NUMBER,
        x_bucketed_demands_rec  OUT     NOCOPY Bucketed_Demands_Rec,
        x_return_status         OUT     NOCOPY VARCHAR2
) IS
        -- local variables

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Calc_Bucketed_Demands_Info ********');
                msc_sch_wb.atp_debug('Calc_Bucketed_Demands_Info: ' ||  'Req Date = ' ||to_char(p_req_date));
                msc_sch_wb.atp_debug('Calc_Bucketed_Demands_Info: ' ||  'ATF Date = ' ||to_char(p_atf_date));
                msc_sch_wb.atp_debug('Calc_Bucketed_Demands_Info: ' ||  'Req Qty = ' ||to_char(p_req_qty));
                msc_sch_wb.atp_debug('Calc_Bucketed_Demands_Info: ' ||  'Req Date Qty = ' ||to_char(p_req_date_qty));
                msc_sch_wb.atp_debug('Calc_Bucketed_Demands_Info: ' ||  'ATF Date Qty = ' ||to_char(p_atf_date_qty));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_req_date <= p_atf_date THEN
                IF (p_req_date_qty >= p_req_qty) OR (p_atf_date_qty >= p_req_qty) THEN
                        /* Request is satisfied using member item's supply within ATF.
                           One bucketed demand would be inserted in this case*/
                        x_bucketed_demands_rec.insert_mem_bd         := 'Y';
                        x_bucketed_demands_rec.mem_display_flag      := 1;
                        x_bucketed_demands_rec.mem_bd_date           := p_req_date;
                        x_bucketed_demands_rec.mem_bd_qty            := p_req_qty;

                        x_bucketed_demands_rec.insert_pf_bd          := 'N';
                ELSE
                        /* Request is satisfied using both member item's supply within ATF
                           and family item's supply outside ATF.
                           Two bucketed demands would be inserted in this case*/
                        x_bucketed_demands_rec.insert_mem_bd         := 'Y';
                        x_bucketed_demands_rec.mem_bd_date           := p_req_date;
                        x_bucketed_demands_rec.mem_bd_qty            := p_atf_date_qty;

                        If x_bucketed_demands_rec.mem_bd_qty > 0 THEN
                                x_bucketed_demands_rec.mem_display_flag      := 1;
                        ELSE
                                x_bucketed_demands_rec.pf_display_flag       := 1;
                        END IF;

                        x_bucketed_demands_rec.insert_pf_bd          := 'Y';
                        x_bucketed_demands_rec.pf_bd_date            := p_atf_date+1;
                        x_bucketed_demands_rec.pf_bd_qty             := p_req_qty - p_atf_date_qty;

                END IF;
        ELSIF (p_req_date_qty >= p_req_qty) THEN
                IF (p_req_date_qty - p_atf_date_qty >= p_req_qty) THEN
                        /* Request is satisfied using family item's supply outside ATF.
                           One bucketed demand would be inserted in this case*/
                        x_bucketed_demands_rec.insert_pf_bd          := 'Y';
                        x_bucketed_demands_rec.pf_display_flag       := 1;
                        x_bucketed_demands_rec.pf_bd_date            := p_req_date;
                        x_bucketed_demands_rec.pf_bd_qty             := p_req_qty;

                        x_bucketed_demands_rec.insert_mem_bd         := 'N';
                ELSE
                        /* Request is satisfied using both member item's supply within ATF
                           and family item's supply outside ATF.
                           Two bucketed demands would be inserted in this case*/
                        x_bucketed_demands_rec.insert_mem_bd := 'Y';
                        x_bucketed_demands_rec.mem_bd_date   := p_atf_date;
                        x_bucketed_demands_rec.mem_bd_qty    := greatest(p_req_qty - (p_req_date_qty - p_atf_date_qty), 0);

                        x_bucketed_demands_rec.insert_pf_bd  := 'Y';
                        x_bucketed_demands_rec.pf_bd_date    := p_req_date;
                        x_bucketed_demands_rec.pf_bd_qty     := p_req_date_qty - p_atf_date_qty;

                        If x_bucketed_demands_rec.pf_bd_qty > 0 THEN
                                x_bucketed_demands_rec.pf_display_flag      := 1;
                        ELSE
                                x_bucketed_demands_rec.mem_display_flag     := 1;
                        END IF;
                END IF;
        ELSE
                /* Request is satisfied using both member item's supply within ATF
                   and family item's supply outside ATF.
                   Two bucketed demands would be inserted in this case*/
                x_bucketed_demands_rec.insert_mem_bd := 'Y';
                x_bucketed_demands_rec.mem_bd_date   := p_atf_date;
                x_bucketed_demands_rec.mem_bd_qty    := p_atf_date_qty;

                x_bucketed_demands_rec.insert_pf_bd  := 'Y';
                x_bucketed_demands_rec.pf_bd_date    := p_req_date;
                x_bucketed_demands_rec.pf_bd_qty     := p_req_qty - p_atf_date_qty;

                If x_bucketed_demands_rec.pf_bd_qty > 0 THEN
                        x_bucketed_demands_rec.pf_display_flag      := 1;
                ELSE
                        x_bucketed_demands_rec.mem_display_flag     := 1;
                END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('**************  Bucketed Demands  *************');
                msc_sch_wb.atp_debug('*    Add member item bucketed demand = ' ||x_bucketed_demands_rec.insert_mem_bd);
                msc_sch_wb.atp_debug('*    Member Item BD Date             = ' ||to_char(x_bucketed_demands_rec.mem_bd_date));
                msc_sch_wb.atp_debug('*    Member Item BD Qty              = ' ||to_char(x_bucketed_demands_rec.mem_bd_qty));
                msc_sch_wb.atp_debug('*    Member Display Flag             = ' ||to_char(x_bucketed_demands_rec.mem_display_flag));
                msc_sch_wb.atp_debug('*    ');
                msc_sch_wb.atp_debug('*    Add family item bucketed demand = ' ||x_bucketed_demands_rec.insert_pf_bd);
                msc_sch_wb.atp_debug('*    Family Item BD Date             = ' ||to_char(x_bucketed_demands_rec.pf_bd_date));
                msc_sch_wb.atp_debug('*    Family Item BD Qty              = ' ||to_char(x_bucketed_demands_rec.pf_bd_qty));
                msc_sch_wb.atp_debug('*    Pf Display Flag                 = ' ||to_char(x_bucketed_demands_rec.pf_display_flag));
                msc_sch_wb.atp_debug('***********************************************');
                msc_sch_wb.atp_debug('*********End of procedure Calc_Bucketed_Demands_Info ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Calc_Bucketed_Demands_Info: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Calc_Bucketed_Demands_Info;

/*--Update_PF_Bucketed_Demands----------------------------------------------
|  o  This procedure updates bucketed demands
+-------------------------------------------------------------------------*/
PROCEDURE Update_PF_Bucketed_Demands(
        p_plan_id                       IN	NUMBER,
        p_parent_demand_id              IN	NUMBER,
        p_demand_date                   IN	DATE,
        p_atf_date                      IN      DATE,
        p_old_demand_date_qty           IN      NUMBER,
        p_new_demand_date_qty           IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_mem_bd_qty                    NUMBER;
        l_mem_bd_decrement_qty          NUMBER;
        l_pf_bd_decrement_qty           NUMBER;
        l_update_mem_bd                 VARCHAR2(1) := 'N';
        l_update_pf_bd                  VARCHAR2(1) := 'N';

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Update_PF_Bucketed_Demands ********');
                msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' ||  'p_parent_demand_id = ' ||to_char(p_parent_demand_id));
                msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' ||  'p_demand_date = ' ||to_char(p_demand_date));
                msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' ||  'p_atf_date = ' ||to_char(p_atf_date));
                msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' ||  'p_old_demand_date_qty = ' ||to_char(p_old_demand_date_qty));
                msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' ||  'p_new_demand_date_qty = ' ||to_char(p_new_demand_date_qty));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_demand_date <= p_atf_date THEN
                l_update_mem_bd := 'Y';
                l_mem_bd_qty := p_new_demand_date_qty;

                l_update_pf_bd := 'D';
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('*********  New Bucketed Demands  ********');
                        msc_sch_wb.atp_debug('*    Member Item BD Date = ' ||to_char(p_demand_date));
                        msc_sch_wb.atp_debug('*    Member Item BD Qty = ' ||to_char(l_mem_bd_qty));
                        msc_sch_wb.atp_debug('*    ');
                        msc_sch_wb.atp_debug('*    Family Item BD Qty = 0');
                        msc_sch_wb.atp_debug('*************************************');
                END IF;
        ELSE
                l_update_mem_bd := 'Y';
                l_mem_bd_qty := null;

                l_update_pf_bd := 'Y';
                l_pf_bd_decrement_qty := GREATEST(nvl(p_old_demand_date_qty, 0)
                                                  - nvl(p_new_demand_date_qty, 0), 0);
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('************  New Bucketed Demands  **************');
                        msc_sch_wb.atp_debug('*    Decremented Previous Family Item BD by ' ||to_char(l_pf_bd_decrement_qty));
                        msc_sch_wb.atp_debug('**************************************************');
                END IF;
        END IF;

        IF l_update_mem_bd = 'Y' THEN
                update  msc_alloc_demands
                set     allocated_quantity = nvl(l_mem_bd_qty, allocated_quantity),
                        demand_quantity = nvl(p_new_demand_date_qty, demand_quantity)
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) <= p_atf_date
                and     plan_id = p_plan_id;
        END IF;

        IF l_update_pf_bd = 'Y' THEN
                update  msc_alloc_demands
                set     allocated_quantity = allocated_quantity - l_pf_bd_decrement_qty,
                        demand_quantity = nvl(p_new_demand_date_qty, demand_quantity)
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) > p_atf_date
                and     plan_id = p_plan_id;
        ELSIF l_update_pf_bd = 'D' THEN
                delete  msc_alloc_demands
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) > p_atf_date
                and     plan_id = p_plan_id;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Update_PF_Bucketed_Demands ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Update_PF_Bucketed_Demands: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Update_PF_Bucketed_Demands;

/*--Increment_Bucketed_Demands_Qty------------------------------------------
|  o  This procedure increments member item's bucketed demand by
|       p_mem_bd_increment_qty and family item's bucketed demand by
|       p_pf_bd_increment_qty.
|  o  This procedure calls private procedure Insert_Bucketed_Demand if
|       there is no existing bucketed demand.
+-------------------------------------------------------------------------*/
PROCEDURE Increment_Bucketed_Demands_Qty(
        p_atp_rec               IN OUT  NOCOPY MRP_ATP_PVT.AtpRec,
        p_plan_id               IN	NUMBER,
        p_parent_demand_id      IN	NUMBER,
--        p_mem_bd_increment_qty  IN	NUMBER,
--        p_pf_bd_increment_qty   IN	NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_bucketed_demands_rec          Bucketed_Demands_Rec;
        l_req_date                      DATE;
        l_atf_date                      DATE;
        l_req_qty                       NUMBER;
        l_req_date_qty                  NUMBER;
        l_atf_date_qty                  NUMBER;
        l_return_status                 VARCHAR2(1);

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Increment_Bucketed_Demands_Qty ********');
                msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: ' ||  'p_parent_demand_id = ' ||to_char(p_parent_demand_id));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_req_date      := p_atp_rec.requested_ship_date;
        l_atf_date      := p_atp_rec.atf_date;
        l_req_qty       := nvl(p_atp_rec.quantity_ordered, 0);
        l_req_date_qty  := greatest(nvl(p_atp_rec.requested_date_quantity, 0), 0);
        /* Assumption is that atf date qty passed to this procedure can be null only
           in scenario where we find req qty within atf*/
        --bug3919371  When Atf date qty is null then
        --            1. Treat requested_date_quantity as atf_date_qty if req date after atf.
        --            2. Treat p_atp_rec.quantity_ordered as atf_date_qty if req date within atf.

        IF l_req_date > l_atf_date THEN
           l_atf_date_qty  := greatest(nvl(p_atp_rec.atf_date_quantity,l_req_date_qty), 0);
        ELSE
           l_atf_date_qty  := greatest(nvl(p_atp_rec.atf_date_quantity, l_req_qty), 0);
        END IF;

        Calc_Bucketed_Demands_Info(
                l_req_date,
                l_atf_date,
                l_req_qty,
                l_req_date_qty,
                l_atf_date_qty,
                l_bucketed_demands_rec,
                l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: ' || 'Error occured in procedure Calc_Bucketed_Demands_Info');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
        END IF;

        IF nvl(l_bucketed_demands_rec.mem_bd_qty, 0) = 0 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: Deleting member item bucketed demand...');
                END IF;
                delete  msc_alloc_demands
                where   parent_demand_id = p_parent_demand_id
                and     inventory_item_id = p_atp_rec.request_item_id
                and     plan_id = p_plan_id;
        ELSIF l_bucketed_demands_rec.mem_bd_qty > 0 THEN
                update  msc_alloc_demands
                set     allocated_quantity = l_bucketed_demands_rec.mem_bd_qty,
                        demand_quantity = l_req_qty,
                        --bug3697365 added timestamp also
                        demand_date = trunc(l_bucketed_demands_rec.mem_bd_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        original_demand_date = trunc(l_req_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        Pf_Display_Flag = l_bucketed_demands_rec.mem_display_flag
                where   parent_demand_id = p_parent_demand_id
                and     inventory_item_id = p_atp_rec.request_item_id
                and     plan_id = p_plan_id;

                IF SQL%NOTFOUND THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: Member item bucketed demand not found. Inserting now...');
                        END IF;
                        Insert_Bucketed_Demand(
                                p_atp_rec,
                                p_plan_id,
                                l_bucketed_demands_rec.mem_bd_date,
                                l_bucketed_demands_rec.mem_bd_qty,
                                l_bucketed_demands_rec.mem_display_flag,
                                p_parent_demand_id,
                                member, -- member item bd
                                p_atp_rec.refresh_number,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF;
        END IF;

        IF nvl(l_bucketed_demands_rec.pf_bd_qty,0) = 0 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: Deleting family item bucketed demand...');
                END IF;
                delete  msc_alloc_demands
                where   parent_demand_id = p_parent_demand_id
                and     inventory_item_id = p_atp_rec.inventory_item_id
                and     plan_id = p_plan_id;
        ELSIF l_bucketed_demands_rec.pf_bd_qty > 0 THEN
                update  msc_alloc_demands
                set     allocated_quantity = l_bucketed_demands_rec.pf_bd_qty,
                        demand_quantity = l_req_qty,
                        --bug3697365 added timestamp also
                        demand_date = trunc(l_bucketed_demands_rec.pf_bd_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        original_demand_date = trunc(l_req_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        Pf_Display_Flag = l_bucketed_demands_rec.pf_display_flag
                where   parent_demand_id = p_parent_demand_id
                and     inventory_item_id = p_atp_rec.inventory_item_id
                and     plan_id = p_plan_id;

                IF SQL%NOTFOUND THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: Family item bucketed demand not found. Inserting now...');
                        END IF;
                        Insert_Bucketed_Demand(
                                p_atp_rec,
                                p_plan_id,
                                l_bucketed_demands_rec.pf_bd_date,
                                l_bucketed_demands_rec.pf_bd_qty,
                                l_bucketed_demands_rec.pf_display_flag,
                                p_parent_demand_id,
                                family, -- family item bd
                                p_atp_rec.refresh_number,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Increment_Bucketed_Demands_Qty ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Increment_Bucketed_Demands_Qty: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Increment_Bucketed_Demands_Qty;

/*--Move_PF_Bucketed_Demands------------------------------------------------
|  o  This procedure moves bucketed demands dates and quantities.
|  o  If p_atf_date_quantity passed is null it means only move the dates
+-------------------------------------------------------------------------*/
PROCEDURE Move_PF_Bucketed_Demands(
        p_plan_id               IN	NUMBER,
        p_parent_demand_id      IN	NUMBER,
        p_old_demand_date       IN	DATE,
        p_new_demand_date       IN	DATE,
        p_demand_qty            IN      NUMBER,
        p_new_demand_date_qty   IN      NUMBER,
        p_atf_date              IN      DATE,
        p_atf_date_qty          IN      NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        p_bkwd_pass_atf_date_qty IN      NUMBER, --bug3397904
        p_atp_rec               IN      MRP_ATP_PVT.AtpRec := NULL
) IS
        -- local variables
        l_update_mem_bd                 VARCHAR(1) :='N';
        l_update_pf_bd                  VARCHAR(1) :='N';
        l_mem_bd_date                   DATE;
        l_pf_bd_date                    DATE;
        l_mem_bd_qty                    NUMBER :=0;--bug3397904
        l_pf_bd_qty                     NUMBER :=0;--bug3397904
        l_mem_display_flag              NUMBER;
        l_pf_display_flag               NUMBER;
        l_return_status                 VARCHAR2(1);
        l_atp_rec                       MRP_ATP_PVT.AtpRec := p_atp_rec;
        l_demand_qty                    NUMBER; --bug3397904
        l_new_demand_date_qty           NUMBER; --bug3397904
        l_atf_date_qty                  NUMBER; --bug3397904

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Move_PF_Bucketed_Demands ********');
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_parent_demand_id = ' ||to_char(p_parent_demand_id));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_old_demand_date = ' ||to_char(p_old_demand_date));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_new_demand_date = ' ||to_char(p_new_demand_date));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_demand_qty = ' ||to_char(p_demand_qty));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_new_demand_date_qty = ' ||to_char(p_new_demand_date_qty));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_atf_date = ' ||to_char(p_atf_date));
                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' ||  'p_atf_date_qty = ' ||to_char(p_atf_date_qty));
        END IF;

        -- Initializing API return code
       x_return_status := FND_API.G_RET_STS_SUCCESS;

        --bug3555084 start
       IF p_parent_demand_id is not null THEN
        IF upper(p_atp_rec.override_flag) = 'Y' THEN
        --IF p_old_demand_date = p_new_demand_date THEN
                --This condition was before for override case
                --now checking by flag as now both dates can be different.
                /*
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: No need to move bucketed demand dates. Update qtys');
                END IF;
                IF (p_atf_date_qty is NULL) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: No need to update qtys');
                        END IF;
                ELSIF p_old_demand_date <= p_atf_date THEN
                        update  msc_alloc_demands
                        set     allocated_quantity = p_demand_qty,
                                demand_quantity = p_demand_qty
                        where   parent_demand_id = p_parent_demand_id
                        and     demand_date <= p_atf_date
                        and     plan_id = p_plan_id;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('*********  New Bucketed Demand Qtys  ********');
                                msc_sch_wb.atp_debug('*    Member Item BD Qty = ' || nvl(p_atf_date_qty, 0));
                                msc_sch_wb.atp_debug('*    ');
                                msc_sch_wb.atp_debug('*    Family Item BD Qty = ' || (p_demand_qty - nvl(p_atf_date_qty, 0)));
                                msc_sch_wb.atp_debug('*********************************************');
                        END IF;
                ELSE
                        update  msc_alloc_demands
                        set     allocated_quantity = nvl(p_atf_date_qty, 0),
                                demand_quantity = p_demand_qty
                        where   parent_demand_id = p_parent_demand_id
                        and     demand_date <= p_atf_date
                        and     plan_id = p_plan_id;

                        update  msc_alloc_demands
                        set     allocated_quantity = p_demand_qty - nvl(p_atf_date_qty, 0),
                                demand_quantity = p_demand_qty
                        where   parent_demand_id = p_parent_demand_id
                        and     demand_date > p_atf_date
                        and     plan_id = p_plan_id;

                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('*********  New Bucketed Demand Qtys  ********');
                                msc_sch_wb.atp_debug('*    Member Item BD Qty = ' || nvl(p_atf_date_qty, 0));
                                msc_sch_wb.atp_debug('*    ');
                                msc_sch_wb.atp_debug('*    Family Item BD Qty = ' || (p_demand_qty - nvl(p_atf_date_qty, 0)));
                                msc_sch_wb.atp_debug('*********************************************');
                        END IF;
                END IF;*/
                IF (p_new_demand_date <= p_atf_date) AND
                   (NVL(p_atf_date_qty,p_demand_qty) >= p_demand_qty) THEN

                        l_update_mem_bd         := 'Y';
                        l_mem_display_flag      := 1;
                        l_mem_bd_date           := p_new_demand_date;
                        l_mem_bd_qty            := p_demand_qty;

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: Inside IF');
                        END IF;

                ELSIF (p_new_demand_date <= p_atf_date) AND (p_atf_date_qty > 0) THEN

                        l_update_mem_bd         := 'Y';
                        l_mem_display_flag      := 1;
                        l_mem_bd_date           := p_new_demand_date;
                        l_mem_bd_qty            := p_atf_date_qty;

                        l_update_pf_bd          := 'Y';
                        l_pf_display_flag       := null;
                        l_pf_bd_date            := p_atf_date + 1;
                        l_pf_bd_qty             := p_demand_qty - p_atf_date_qty;

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: p_new_demand_date <= p_atf_date');
                        END IF;

                ELSIF (p_new_demand_date <= p_atf_date)  THEN

                        l_update_pf_bd          := 'Y';
                        l_pf_display_flag       := 1;
                        l_pf_bd_date            := p_atf_date + 1;
                        l_pf_bd_qty             := p_demand_qty;

                --8604062 RSD/DSD are outside ATF and ATF date quantity is 0. We should not be updating member demand.
                ELSIF (NVL(p_atf_date_qty,0) = 0) THEN

                        l_update_pf_bd          := 'Y';
                        l_pf_display_flag       := 1;
                        l_pf_bd_date            := p_new_demand_date;
                        l_pf_bd_qty             := p_demand_qty;
                ELSE
                        l_update_mem_bd         := 'Y';
                        l_mem_display_flag      := null;
                        l_mem_bd_date           := p_atf_date;
                        l_mem_bd_qty            := p_atf_date_qty;

                        l_update_pf_bd          := 'Y';
                        l_pf_display_flag       := 1;
                        l_pf_bd_date            := p_new_demand_date;
                        l_pf_bd_qty             := p_demand_qty - p_atf_date_qty;

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: inside else');
                        END IF;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('*********  Bucketed Demands  ********');
                        msc_sch_wb.atp_debug('*    Update member item bucketed demand = ' ||l_update_mem_bd);
                        msc_sch_wb.atp_debug('*    l_mem_bd_date = ' ||to_char(l_mem_bd_date));
                        msc_sch_wb.atp_debug('*    l_mem_bd_qty = ' ||to_char(l_mem_bd_qty));
                        msc_sch_wb.atp_debug('*    l_mem_display_flag = ' ||to_char(l_mem_display_flag));
                        msc_sch_wb.atp_debug('*    ');
                        msc_sch_wb.atp_debug('*    Update family item bucketed demand = ' ||l_update_pf_bd);
                        msc_sch_wb.atp_debug('*    l_pf_bd_date = ' ||to_char(l_pf_bd_date));
                        msc_sch_wb.atp_debug('*    l_pf_bd_qty = ' ||to_char(l_pf_bd_qty));
                        msc_sch_wb.atp_debug('*    l_pf_display_flag = ' ||to_char(l_pf_display_flag));
                        msc_sch_wb.atp_debug('*************************************');
                END IF;

                IF l_update_mem_bd = 'Y'  THEN
                        update  msc_alloc_demands
                                --bug3697365 added timestamp also
                        set     demand_date = trunc(l_mem_bd_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                allocated_quantity = l_mem_bd_qty,
                                demand_quantity = p_demand_qty,
                                pf_display_flag = l_mem_display_flag,
                                --bug3697365 added timestamp also
                                original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY
                        where   parent_demand_id = p_parent_demand_id
                        --bug3693892 added trunc
                        and     trunc(demand_date) <= p_atf_date
                        and     plan_id = p_plan_id;

                        IF (SQL%NOTFOUND) and (nvl(l_mem_bd_qty, 0) > 0) and (l_atp_rec.inventory_item_id is NOT NULL) THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: Member item bucketed demand not found. Inserting now...');
                                END IF;
                                l_atp_rec.quantity_ordered := p_demand_qty;
                                l_atp_rec.requested_ship_date := p_new_demand_date;
                                Insert_Bucketed_Demand(
                                        l_atp_rec,
                                        p_plan_id,
                                        l_mem_bd_date,
                                        l_mem_bd_qty,
                                        l_mem_display_flag,
                                        p_parent_demand_id,
                                        member, -- member item bd
                                        l_atp_rec.refresh_number,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        END IF;
                END IF;

                IF l_update_pf_bd = 'Y' THEN
                        update  msc_alloc_demands
                                --bug3697365 added timestamp also
                        set     demand_date = trunc(l_pf_bd_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                allocated_quantity = l_pf_bd_qty,
                                demand_quantity = p_demand_qty,
                                pf_display_flag = l_pf_display_flag,
                                --bug3697365 added timestamp also
                                original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY
                        where   parent_demand_id = p_parent_demand_id
                        --bug3693892 added trunc
                        and     trunc(demand_date) > p_atf_date
                        and     plan_id = p_plan_id;

                        IF (SQL%NOTFOUND) and (nvl(l_pf_bd_qty, 0) > 0) and (l_atp_rec.inventory_item_id is NOT NULL) THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: Family item bucketed demand not found. Inserting now...');
                                END IF;
                                l_atp_rec.quantity_ordered := p_demand_qty;
                                l_atp_rec.requested_ship_date := p_new_demand_date;
                                Insert_Bucketed_Demand(
                                        l_atp_rec,
                                        p_plan_id,
                                        l_pf_bd_date,
                                        l_pf_bd_qty,
                                        l_pf_display_flag,
                                        p_parent_demand_id,
                                        family, -- family item bd
                                        l_atp_rec.refresh_number,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        END IF;
                END IF;
                --bug3555084 end
        ELSIF (p_atf_date_qty is NULL) THEN
                Move_PF_Bd_Dates(
                        p_plan_id,
                        p_parent_demand_id,
                        p_old_demand_date,
                        p_new_demand_date,
                        p_atf_date,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' || 'Error occured in procedure Move_PF_Bd_Dates');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;
        ELSE
                l_demand_qty := p_demand_qty - nvl(p_bkwd_pass_atf_date_qty,0); --bug3397904
                l_new_demand_date_qty := p_new_demand_date_qty - nvl(p_bkwd_pass_atf_date_qty,0); --bug3397904
                l_atf_date_qty := p_atf_date_qty - nvl(p_bkwd_pass_atf_date_qty,0); --bug3397904

                IF PG_DEBUG in ('Y', 'C') THEN  --bug3397904 start
                        msc_sch_wb.atp_debug('*********  Bucketed Demands  ********');
                        msc_sch_wb.atp_debug('*    Backward pass atf date qty = ' ||to_char(p_bkwd_pass_atf_date_qty));
                        msc_sch_wb.atp_debug('*    l_new_demand_date_qty = ' ||to_char(l_new_demand_date_qty));
                        msc_sch_wb.atp_debug('*    l_atf_date_qty = ' ||to_char(l_atf_date_qty));
                        msc_sch_wb.atp_debug('*    ');
                END IF; --bug3397904 end
                IF p_new_demand_date <= p_atf_date THEN
                        /* Move member item's bucketed demand*/
                        l_update_mem_bd         := 'Y';
                        l_mem_display_flag      := 1;
                        l_mem_bd_date           := p_new_demand_date;
                        l_mem_bd_qty            := l_demand_qty;
                ELSIF (l_new_demand_date_qty - l_atf_date_qty >= l_demand_qty) THEN
                        /* Delete member item's bucketed demand*/
                        IF p_bkwd_pass_atf_date_qty <> 0 THEN --bug3397904 start
                         l_update_mem_bd         := 'Y';
                         l_mem_display_flag      := null;
                         l_mem_bd_date           := p_atf_date;
                         l_mem_bd_qty            := 0;
                        ELSE
                         l_update_mem_bd         := 'D';
                        END IF;                              --bug3397904 end

                        /* Move family item's bucketed demand*/
                        l_update_pf_bd          := 'Y';
                        l_pf_display_flag       := 1;
                        l_pf_bd_date            := p_new_demand_date;
                        l_pf_bd_qty             := l_demand_qty;
                ELSE
                        /* Move member item's bucketed demand*/
                        l_update_mem_bd         := 'Y';
                        l_mem_display_flag      := null;
                        l_mem_bd_date           := p_atf_date;
                        l_mem_bd_qty            := l_demand_qty - (l_new_demand_date_qty - l_atf_date_qty);

                        /* Move family item's bucketed demand*/
                        l_update_pf_bd          := 'Y';
                        l_pf_display_flag       := 1;
                        l_pf_bd_date            := p_new_demand_date;
                        l_pf_bd_qty             := l_new_demand_date_qty - l_atf_date_qty;
                END IF;

                l_mem_bd_qty := l_mem_bd_qty + p_bkwd_pass_atf_date_qty; --bug3397904

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('*********  Bucketed Demands  ********');
                        msc_sch_wb.atp_debug('*    Update member item bucketed demand = ' ||l_update_mem_bd);
                        msc_sch_wb.atp_debug('*    l_mem_bd_date = ' ||to_char(l_mem_bd_date));
                        msc_sch_wb.atp_debug('*    l_mem_bd_qty = ' ||to_char(l_mem_bd_qty));
                        msc_sch_wb.atp_debug('*    l_mem_display_flag = ' ||to_char(l_mem_display_flag));
                        msc_sch_wb.atp_debug('*    ');
                        msc_sch_wb.atp_debug('*    Update family item bucketed demand = ' ||l_update_pf_bd);
                        msc_sch_wb.atp_debug('*    l_pf_bd_date = ' ||to_char(l_pf_bd_date));
                        msc_sch_wb.atp_debug('*    l_pf_bd_qty = ' ||to_char(l_pf_bd_qty));
                        msc_sch_wb.atp_debug('*    l_pf_display_flag = ' ||to_char(l_pf_display_flag));
                        msc_sch_wb.atp_debug('*************************************');
                END IF;

                IF l_update_mem_bd = 'Y' THEN
                        update  msc_alloc_demands
                                --bug3697365 added timestamp also
                        set     demand_date = trunc(l_mem_bd_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                allocated_quantity = l_mem_bd_qty,
                                demand_quantity = p_demand_qty,
                                pf_display_flag = l_mem_display_flag,
                                --bug3697365 added timestamp also
                                original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY
                        where   parent_demand_id = p_parent_demand_id
                        --bug3693892 added trunc
                        and     trunc(demand_date) <= p_atf_date
                        and     plan_id = p_plan_id;

                        IF (SQL%NOTFOUND) and (nvl(l_mem_bd_qty, 0) > 0) and (l_atp_rec.inventory_item_id is NOT NULL) THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: Member item bucketed demand not found. Inserting now...');
                                END IF;
                                l_atp_rec.quantity_ordered := p_demand_qty;
                                l_atp_rec.requested_ship_date := p_new_demand_date;
                                Insert_Bucketed_Demand(
                                        l_atp_rec,
                                        p_plan_id,
                                        l_mem_bd_date,
                                        l_mem_bd_qty,
                                        --l_pf_display_flag,
                                        l_mem_display_flag, -- Bug 3483954
                                        p_parent_demand_id,
                                        member, -- member item bd
                                        l_atp_rec.refresh_number,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        END IF;
                ELSIF l_update_mem_bd = 'D' THEN
                        delete  msc_alloc_demands
                        where   parent_demand_id = p_parent_demand_id
                        --bug3693892 added trunc
                        and     trunc(demand_date) <= p_atf_date
                        and     plan_id = p_plan_id;
                END IF;

                IF l_update_pf_bd = 'Y' THEN
                        update  msc_alloc_demands
                                --bug3697365 added timestamp also
                        set     demand_date = trunc(l_pf_bd_date) + MSC_ATP_PVT.G_END_OF_DAY,
                                allocated_quantity = l_pf_bd_qty,
                                demand_quantity = p_demand_qty,
                                pf_display_flag = l_pf_display_flag,
                                --bug3697365 added timestamp also
                                original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY
                        where   parent_demand_id = p_parent_demand_id
                        --bug3693892 added trunc
                        and     trunc(demand_date) > p_atf_date
                        and     plan_id = p_plan_id;

                        IF (SQL%NOTFOUND) and (nvl(l_pf_bd_qty, 0) > 0) and (l_atp_rec.inventory_item_id is NOT NULL) THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: Family item bucketed demand not found. Inserting now...');
                                END IF;
                                l_atp_rec.quantity_ordered := p_demand_qty;
                                l_atp_rec.requested_ship_date := p_new_demand_date;
                                Insert_Bucketed_Demand(
                                        l_atp_rec,
                                        p_plan_id,
                                        l_pf_bd_date,
                                        l_pf_bd_qty,
                                        l_pf_display_flag,
                                        p_parent_demand_id,
                                        family, -- family item bd
                                        l_atp_rec.refresh_number,
                                        l_return_status
                                );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                                msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' || 'Error occured in procedure Insert_Bucketed_Demand');
                                        END IF;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        return;
                                END IF;
                        END IF;
                END IF;
        END IF;
       END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Move_PF_Bucketed_Demands ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Move_PF_Bucketed_Demands: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Move_PF_Bucketed_Demands;

/*--Move_PF_Bd_Dates--------------------------------------------------------
|  o  This procedure moves bucketed demands dates.
+-------------------------------------------------------------------------*/
PROCEDURE Move_PF_Bd_Dates(
        p_plan_id               IN	NUMBER,
        p_parent_demand_id      IN	NUMBER,
        p_old_demand_date       IN	DATE,
        p_new_demand_date       IN	DATE,
        p_atf_date              IN      DATE,
        x_return_status         OUT     NOCOPY VARCHAR2
) IS
        -- local variables

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Move_PF_Bd_Dates ********');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_old_demand_date < p_atf_date) and (p_new_demand_date <= p_atf_date) THEN
                update  msc_alloc_demands
                        --bug3697365 added timestamp also
                set     demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) <= p_atf_date
                and     plan_id = p_plan_id;
        ELSIF (p_old_demand_date < p_atf_date) and (p_new_demand_date > p_atf_date) THEN
                update  msc_alloc_demands
                        --bug3693892 added trunc
                set     demand_date = trunc(p_atf_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        Pf_Display_Flag = null
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) <= p_atf_date
                and     plan_id = p_plan_id;

                update  msc_alloc_demands
                        --bug3693892 added trunc
                set     demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        Pf_Display_Flag = 1
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) > p_atf_date
                and     plan_id = p_plan_id;
        ELSIF (p_old_demand_date > p_atf_date) and (p_new_demand_date > p_atf_date) THEN
                update  msc_alloc_demands
                        --bug3693892 added trunc
                set     demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                        original_demand_date = trunc(p_new_demand_date) + MSC_ATP_PVT.G_END_OF_DAY
                where   parent_demand_id = p_parent_demand_id
                --bug3693892 added trunc
                and     trunc(demand_date) > p_atf_date
                and     plan_id = p_plan_id;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Move_PF_Bd_Dates ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Move_PF_Bd_Dates: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Move_PF_Bd_Dates;

/*--Insert_Bucketed_Demand--------------------------------------------------
|  o  This procedure inserts bucketed demand in msc_alloc_demands table
|       with origination type 51 (ATP Bucketed Demand).
+-------------------------------------------------------------------------*/
PROCEDURE Insert_Bucketed_Demand(
        p_atp_rec          		IN	MRP_ATP_PVT.AtpRec,
        p_plan_id          		IN	NUMBER,
        p_bucketed_demand_date          IN	DATE,
        p_bucketed_demand_qty           IN	NUMBER,
        p_display_flag                  IN	NUMBER,
        p_parent_demand_id 		IN	NUMBER,
        p_level                         IN      NUMBER,
        p_refresh_number                IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_sysdate       date := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Insert_Bucketed_Demand ********');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        INSERT INTO MSC_ALLOC_DEMANDS(
                PLAN_ID,
                INVENTORY_ITEM_ID,
                ORIGINAL_ITEM_ID,
                USING_ASSEMBLY_ITEM_ID,
                ORGANIZATION_ID,
                SR_INSTANCE_ID,
                DEMAND_CLASS,
                DEMAND_DATE,
                ORIGINAL_DEMAND_DATE,
                PARENT_DEMAND_ID,
                ALLOCATED_QUANTITY,
                DEMAND_QUANTITY,
                ORIGINATION_TYPE,
                ORIGINAL_ORIGINATION_TYPE,
                ORDER_NUMBER,
                SALES_ORDER_LINE_ID,
                DEMAND_SOURCE_TYPE,--cmro
                PF_DISPLAY_FLAG,
                CUSTOMER_ID,
                SHIP_TO_SITE_ID,
                REFRESH_NUMBER,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE
        )
        VALUES (
                p_plan_id,
                decode(p_level, member, p_atp_rec.request_item_id,
                                p_atp_rec.inventory_item_id),
                p_atp_rec.request_item_id,
                p_atp_rec.request_item_id,
                p_atp_rec.organization_id,
                p_atp_rec.instance_id,
                nvl(p_atp_rec.demand_class, -1),
                --bug3697365 added timestamp also
                TRUNC(p_bucketed_demand_date) + MSC_ATP_PVT.G_END_OF_DAY,
                TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY,
                p_parent_demand_id,
                p_bucketed_demand_qty,
                p_atp_rec.quantity_ordered,
                51, -- ATP Bucketed Demand
                p_atp_rec.origination_type,
                decode(p_atp_rec.origination_type, 1, p_parent_demand_id,
                                                   p_atp_rec.order_number),
                p_atp_rec.demand_source_line,
                p_atp_rec.demand_source_type,--cmro
                p_display_flag,
                decode(p_atp_rec.origination_type, 6, MSC_ATP_PVT.G_PARTNER_ID,
                                                   30, MSC_ATP_PVT.G_PARTNER_ID,
                                                   null),
                decode(p_atp_rec.origination_type, 6, MSC_ATP_PVT.G_PARTNER_SITE_ID,
                                                   30, MSC_ATP_PVT.G_PARTNER_SITE_ID,
                                                   null),
                p_refresh_number,
                G_USER_ID,
                l_sysdate,
                G_USER_ID,
                l_sysdate
        );

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Bucketed_Demand: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Insert_Bucketed_Demand;

/*--Find_PF_Bucketed_Demands--------------------------------------------------
|  o  This procedure returns information about bucketed demands for a demand.
+---------------------------------------------------------------------------*/
PROCEDURE Find_PF_Bucketed_Demands(
        p_plan_id               IN	NUMBER,
        p_parent_demand_id      IN	NUMBER,
        p_bucketed_demands_rec  IN OUT	NOCOPY MSC_ATP_PF.Bucketed_Demands_Rec,
        x_return_status         OUT     NOCOPY VARCHAR2
) IS
        -- local variables

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Find_PF_Bucketed_Demands ********');
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'mem_item_id = ' ||to_char(p_bucketed_demands_rec.mem_item_id));
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'p_parent_demand_id = ' ||to_char(p_parent_demand_id));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        BEGIN
                SELECT  allocated_quantity,
                        demand_date
                INTO    p_bucketed_demands_rec.mem_bd_qty,
                        p_bucketed_demands_rec.mem_bd_date
                FROM    msc_alloc_demands
                WHERE   plan_id = p_plan_id
                AND     parent_demand_id = p_parent_demand_id
                AND     inventory_item_id = p_bucketed_demands_rec.mem_item_id
                ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        p_bucketed_demands_rec.mem_bd_qty := 0;
                        p_bucketed_demands_rec.mem_bd_date := null;
        END;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'pf_item_id = ' ||to_char(p_bucketed_demands_rec.pf_item_id));
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'Member item BD Date = ' ||to_char(p_bucketed_demands_rec.mem_bd_date));
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'Member item BD Qty = ' ||to_char(p_bucketed_demands_rec.mem_bd_qty));
        END IF;

        BEGIN
                SELECT  allocated_quantity,
                        demand_date
                INTO    p_bucketed_demands_rec.pf_bd_qty,
                        p_bucketed_demands_rec.pf_bd_date
                FROM    msc_alloc_demands
                WHERE   plan_id = p_plan_id
                AND     parent_demand_id = p_parent_demand_id
                AND     inventory_item_id = p_bucketed_demands_rec.pf_item_id
                ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        p_bucketed_demands_rec.pf_bd_qty := 0;
                        p_bucketed_demands_rec.pf_bd_date := null;
        END;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'Family item BD Date = ' ||to_char(p_bucketed_demands_rec.pf_bd_date));
                msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' ||  'Family item BD Qty = ' ||to_char(p_bucketed_demands_rec.pf_bd_qty));
                msc_sch_wb.atp_debug('*********End of procedure Find_PF_Bucketed_Demands ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Find_PF_Bucketed_Demands: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Find_PF_Bucketed_Demands;

/*--Add_PF_Rollup_Supplies--------------------------------------------------
|  o  This procedure adds rollup supplies in msc_alloc_supplies table.
|  o  If the supply is after ATF then it adds rollup supplies to family,
|       else to member item.
+-------------------------------------------------------------------------*/
PROCEDURE Add_PF_Rollup_Supplies(
        p_plan_id                       IN	NUMBER,
        p_member_item_id                IN	NUMBER,
        p_family_item_id                IN      NUMBER,
        p_organization_id               IN	NUMBER,
        p_instance_id                   IN	NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_schedule_date                 IN      DATE,
        p_orig_order_type               IN      NUMBER,
        p_order_quantity                IN	NUMBER,
        p_parent_transaction_id         IN	NUMBER,
        p_atf_date                      IN      DATE,
        p_refresh_number                IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_sysdate               date := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Add_PF_Rollup_Supplies ********');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_schedule_date <= p_atf_date THEN
                INSERT INTO MSC_ALLOC_SUPPLIES(
                        PLAN_ID,
                        INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        SR_INSTANCE_ID,
                        DEMAND_CLASS,
                        SUPPLY_DATE,
                        PARENT_TRANSACTION_ID,
                        ALLOCATED_QUANTITY,
                        SUPPLY_QUANTITY,
                        ORDER_TYPE,
                        ORIGINAL_ORDER_TYPE,
                        ORIGINAL_ITEM_ID,
                        REFRESH_NUMBER,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        CUSTOMER_ID,         -- Bug 3558125
                        SHIP_TO_SITE_ID      -- Bug 3558125
                )
                VALUES (
                        p_plan_id,
                        p_member_item_id,
                        p_organization_id,
                        p_instance_id,
                        nvl(p_demand_class, -1),
                        p_schedule_date,
                        p_parent_transaction_id,
                        p_order_quantity,
                        p_order_quantity,
                        50,
                        p_orig_order_type,
                        p_member_item_id,
                        p_refresh_number,
                        G_USER_ID,
                        l_sysdate,
                        G_USER_ID,
                        l_sysdate,
                        NVL(MSC_ATP_PVT.G_PARTNER_ID,-1),       -- Bug 3558125
                        NVL(MSC_ATP_PVT.G_PARTNER_SITE_ID,-1)   -- Bug 3558125
                );
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('***********  Rollup Supply  **********');
                        msc_sch_wb.atp_debug('*    Add rollup supply for member item ');
                        msc_sch_wb.atp_debug('*    Member Item Id = ' ||to_char(p_member_item_id));
                        msc_sch_wb.atp_debug('*    Qty = ' ||to_char(p_order_quantity));
                        msc_sch_wb.atp_debug('*    Date = ' ||to_char(p_schedule_date));
                        msc_sch_wb.atp_debug('**************************************');
                END IF;
        ELSE
                INSERT INTO MSC_ALLOC_SUPPLIES(
                        PLAN_ID,
                        INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        SR_INSTANCE_ID,
                        DEMAND_CLASS,
                        SUPPLY_DATE,
                        PARENT_TRANSACTION_ID,
                        ALLOCATED_QUANTITY,
                        SUPPLY_QUANTITY,
                        ORDER_TYPE,
                        ORIGINAL_ORDER_TYPE,
                        ORIGINAL_ITEM_ID,
                        REFRESH_NUMBER,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        CUSTOMER_ID,         -- Bug 3558125
                        SHIP_TO_SITE_ID      -- Bug 3558125
                )
                VALUES (
                        p_plan_id,
                        p_family_item_id,
                        p_organization_id,
                        p_instance_id,
                        nvl(p_demand_class, -1),
                        p_schedule_date,
                        p_parent_transaction_id,
                        p_order_quantity,
                        p_order_quantity,
                        50,
                        p_orig_order_type,
                        p_member_item_id,
                        p_refresh_number,
                        G_USER_ID,
                        l_sysdate,
                        G_USER_ID,
                        l_sysdate,
                        NVL(MSC_ATP_PVT.G_PARTNER_ID,-1),       -- Bug 3558125
                        NVL(MSC_ATP_PVT.G_PARTNER_SITE_ID,-1)   -- Bug 3558125
                );
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('***********  Rollup Supply  **********');
                        msc_sch_wb.atp_debug('*    Add rollup supply for family item ');
                        msc_sch_wb.atp_debug('*    Family Item Id = ' ||to_char(p_family_item_id));
                        msc_sch_wb.atp_debug('*    Qty = ' ||to_char(p_order_quantity));
                        msc_sch_wb.atp_debug('*    Date = ' ||to_char(p_schedule_date));
                        msc_sch_wb.atp_debug('**************************************');
                END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Add_PF_Rollup_Supplies ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Rollup_Supplies: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Add_PF_Rollup_Supplies;

/*--Update_PF_Rollup_Supplies----------------------------------------------
|  o  This procedure is called from update_planned_order procedure to
|       update PF rollup supplies.
|  o  Updates rollup supplies to passed date and quantity values.
+-------------------------------------------------------------------------*/
PROCEDURE Update_PF_Rollup_Supplies(
        p_plan_id          		IN	NUMBER,
        p_parent_transaction_id         IN	NUMBER,
        p_mem_item_id                   IN	NUMBER,
        p_pf_item_id                    IN	NUMBER,
        p_date                          IN      DATE,
        p_quantity                      IN      NUMBER,
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_sysdate               date := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Update_PF_Rollup_Supplies ********');
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_plan_id ='||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_parent_transaction_id ='||to_char(p_parent_transaction_id));
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_mem_item_id ='||to_char(p_mem_item_id));
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_pf_item_id ='||to_char(p_pf_item_id));
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_date ='||to_char(p_date));
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_quantity ='||to_char(p_quantity));
                msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'p_atf_date ='||to_char(p_atf_date));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_date is NULL THEN
                UPDATE  msc_alloc_supplies
                SET     old_supply_date = supply_date, -- why do we populate old_supply_date and qty??
                        old_allocated_quantity = allocated_quantity, --??
                        allocated_quantity = NVL(p_quantity, allocated_quantity),
                        supply_quantity = NVL(p_quantity, supply_quantity),     -- Bug 3779200
                        LAST_UPDATED_BY = G_USER_ID,
                        LAST_UPDATE_DATE = l_sysdate
                WHERE   plan_id = p_plan_id
                AND     parent_transaction_id = p_parent_transaction_id;
        ELSIF p_date <= p_atf_date THEN
                UPDATE  msc_alloc_supplies
                SET     old_supply_date = supply_date, -- why do we populate old_supply_date and qty??
                        old_allocated_quantity = allocated_quantity, --??
                        supply_date = NVL(p_date, supply_date),
                        allocated_quantity = NVL(p_quantity, allocated_quantity),
                        supply_quantity = NVL(p_quantity, supply_quantity),     -- Bug 3779200
                        inventory_item_id = p_mem_item_id,
                        LAST_UPDATED_BY = G_USER_ID,
                        LAST_UPDATE_DATE = l_sysdate
                WHERE   plan_id = p_plan_id
                AND     parent_transaction_id = p_parent_transaction_id;
        ELSE
                UPDATE  msc_alloc_supplies
                SET     old_supply_date = supply_date, -- why do we populate old_supply_date and qty??
                        old_allocated_quantity = allocated_quantity, --??
                        supply_date = NVL(p_date, supply_date),
                        allocated_quantity = NVL(p_quantity, allocated_quantity),
                        supply_quantity = NVL(p_quantity, supply_quantity),     -- Bug 3779200
                        inventory_item_id = p_pf_item_id,
                        LAST_UPDATED_BY = G_USER_ID,
                        LAST_UPDATE_DATE = l_sysdate
                WHERE   plan_id = p_plan_id
                AND     parent_transaction_id = p_parent_transaction_id;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Update_PF_Rollup_Supplies ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Update_PF_Rollup_Supplies: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Update_PF_Rollup_Supplies;

/*--Add_PF_Stealing_Supply_Details------------------------------------------
|  o  This procedure is called from stealing procedure to add stealing
|       supplies records for member item and family.
+-------------------------------------------------------------------------*/
PROCEDURE Add_PF_Stealing_Supply_Details (
        p_plan_id                       IN      NUMBER,
        p_identifier                    IN      NUMBER,
        p_mem_item_id                   IN      NUMBER,
        p_pf_item_id                    IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_sr_instance_id                IN      NUMBER,
        p_mem_stealing_quantity         IN      NUMBER,
        p_pf_stealing_quantity          IN      NUMBER,
        p_stealing_demand_class         IN      VARCHAR2,
        p_stolen_demand_class           IN      VARCHAR2,
        p_ship_date                     IN      DATE,
        p_atf_date                      IN      DATE,
        p_refresh_number                IN      NUMBER, -- for summary enhancement
        p_transaction_id                OUT     NOCOPY NUMBER,
        p_ato_model_line_id             IN      NUMBER,
        p_demand_source_type            IN      NUMBER,--cmro
        --bug3684383
        p_order_number                  IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_sysdate                       DATE := sysdate;
        l_mem_stealing_rec_date         DATE;
        l_pf_stealing_rec_date          DATE;
        l_rows_proc                     NUMBER := 0;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*** Begin Add_PF_Stealing_Supply_Details Procedure ***');
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_plan_id ='||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_identifier ='||to_char(p_identifier));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_demand_source_type ='||to_char(p_demand_source_type));--cmro
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_mem_item_id ='||to_char(p_mem_item_id));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_pf_item_id ='||to_char(p_pf_item_id));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_organization_id = ' ||to_char(p_organization_id));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_instance_id = ' ||to_char(p_sr_instance_id));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_mem_stealing_quantity ='||to_char(p_mem_stealing_quantity));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_pf_stealing_quantity ='||to_char(p_pf_stealing_quantity));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_stealing_demand_class = '||p_stealing_demand_class);
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_stolen_demand_class = ' ||p_stolen_demand_class);
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_ship_date = ' ||to_char(p_ship_date));
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'p_atf_date = ' ||to_char(p_atf_date));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_ship_date > p_atf_date) THEN
                l_mem_stealing_rec_date := p_atf_date;
                l_pf_stealing_rec_date  := p_ship_date;
        ELSE
                l_mem_stealing_rec_date := p_ship_date;
        END IF;

        --bug3555084 using returning clause in place of select
        --SELECT msc_supplies_s.nextval into p_transaction_id from dual;

        IF p_mem_stealing_quantity > 0 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'before insert into msc_alloc_supplies-Stealing Info');
                END IF;

                -- Add Member item
                INSERT INTO MSC_ALLOC_SUPPLIES
                        (plan_id, inventory_item_id, organization_id, sr_instance_id,
                         demand_class, supply_date, parent_transaction_id,
                         allocated_quantity, order_type, sales_order_line_id,demand_source_type,stealing_flag,--cmro
                         supply_quantity, original_item_id, original_order_type,
                         created_by, creation_date, last_updated_by, last_update_date, from_demand_class, ato_model_line_id, refresh_number, -- For summary enhancement
                         --bug3684383
                         order_number,customer_id,ship_to_site_id
                         )
                VALUES
                        (p_plan_id, p_mem_item_id, p_organization_id,
                         p_sr_instance_id, p_stealing_demand_class, l_mem_stealing_rec_date,
                         --bug3555084 using msc_supplies_s.nextval in place of p_transaction_id
                         msc_supplies_s.nextval, p_mem_stealing_quantity, 50, p_identifier,p_demand_source_type, 1,--cmro
                         p_mem_stealing_quantity, p_mem_item_id, 46,
                         G_USER_ID, l_sysdate, G_USER_ID, l_sysdate, p_stolen_demand_class, p_ato_model_line_id, p_refresh_number,
                         --bug3684383
                         p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID) -- For summary enhancement
                         RETURNING parent_transaction_id INTO p_transaction_id; --bug3555084

                l_rows_proc := SQL%ROWCOUNT;

                -- Next add the Stolen Data.
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'before insert into msc_alloc_supplies-Stolen Info');
                END IF;

                INSERT INTO MSC_ALLOC_SUPPLIES
                        (plan_id, inventory_item_id, organization_id, sr_instance_id,
                         demand_class, supply_date, parent_transaction_id,
                         allocated_quantity, order_type, sales_order_line_id,demand_source_type, stealing_flag,--cmro
                         supply_quantity, original_item_id, original_order_type,
                         created_by, creation_date, last_updated_by, last_update_date, from_demand_class, ato_model_line_id,  refresh_number, -- For summary enhancement
                         --bug3684383
                         order_number,customer_id,ship_to_site_id)
                VALUES
                        (p_plan_id, p_mem_item_id, p_organization_id,
                         p_sr_instance_id, p_stolen_demand_class, l_mem_stealing_rec_date,
                         p_transaction_id, -1 * p_mem_stealing_quantity, 50, p_identifier,p_demand_source_type, 1,---cmro
                         -1 * p_mem_stealing_quantity, p_mem_item_id, 47,
                         G_USER_ID, l_sysdate, G_USER_ID, l_sysdate, p_stealing_demand_class, p_ato_model_line_id, p_refresh_number,
                         --bug3684383
                         p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID); -- For summary enhancement

                l_rows_proc := l_rows_proc + SQL%ROWCOUNT;
        END IF;

        IF (l_pf_stealing_rec_date is not null) and (p_pf_stealing_quantity > 0) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'before insert into msc_alloc_supplies-Stealing Info');
            END IF;

            IF p_transaction_id is not null THEN   --bug3555084

                INSERT INTO MSC_ALLOC_SUPPLIES
                        (plan_id, inventory_item_id, organization_id, sr_instance_id,
                         demand_class, supply_date, parent_transaction_id,
                         allocated_quantity, order_type, sales_order_line_id,demand_source_type, stealing_flag,--cmro
                         supply_quantity, original_item_id, original_order_type,
                         created_by, creation_date, last_updated_by, last_update_date, from_demand_class, refresh_number, -- For summary enhancement
                         --bug3684383
                         order_number,customer_id,ship_to_site_id)
                VALUES
                        (p_plan_id, p_pf_item_id, p_organization_id,
                         p_sr_instance_id, p_stealing_demand_class, l_pf_stealing_rec_date,
                         p_transaction_id, p_pf_stealing_quantity, 50, p_identifier,p_demand_source_type, 1,--cmro
                         p_pf_stealing_quantity, p_mem_item_id, 46,
                         G_USER_ID, l_sysdate, G_USER_ID, l_sysdate, p_stolen_demand_class, p_refresh_number, -- For summary enhancement
                         --bug3684383
                         p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID);

                l_rows_proc := l_rows_proc + SQL%ROWCOUNT;

            ELSE    --bug3555084 start
                INSERT INTO MSC_ALLOC_SUPPLIES
                        (plan_id, inventory_item_id, organization_id, sr_instance_id,
                         demand_class, supply_date, parent_transaction_id,
                         allocated_quantity, order_type, sales_order_line_id,demand_source_type, stealing_flag,--cmro
                         supply_quantity, original_item_id, original_order_type,
                         created_by, creation_date, last_updated_by, last_update_date, from_demand_class, refresh_number, -- For summary enhancement
                         --bug3684383
                         order_number,customer_id,ship_to_site_id)
                VALUES
                        (p_plan_id, p_pf_item_id, p_organization_id,
                         p_sr_instance_id, p_stealing_demand_class, l_pf_stealing_rec_date,
                         msc_supplies_s.nextval, p_pf_stealing_quantity, 50, p_identifier,p_demand_source_type, 1,--cmro
                         p_pf_stealing_quantity, p_mem_item_id, 46,
                         G_USER_ID, l_sysdate, G_USER_ID, l_sysdate, p_stolen_demand_class, p_refresh_number, -- For summary enhancement
                         --bug3684383
                         p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID)

                         RETURNING parent_transaction_id INTO p_transaction_id;

                l_rows_proc := l_rows_proc + SQL%ROWCOUNT;
            END IF;
            --bug3555084 end
                -- Next add the Stolen Data.
            IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'before insert into msc_alloc_supplies-Stolen Info');
            END IF;

            INSERT INTO MSC_ALLOC_SUPPLIES
                        (plan_id, inventory_item_id, organization_id, sr_instance_id,
                         demand_class, supply_date, parent_transaction_id,
                         allocated_quantity, order_type, sales_order_line_id,demand_source_type, stealing_flag,--cmro
                         supply_quantity, original_item_id, original_order_type,
                         created_by, creation_date, last_updated_by, last_update_date, from_demand_class, refresh_number, -- For summary enhancement
                         --bug3684383
                         order_number,customer_id,ship_to_site_id)
            VALUES
                        (p_plan_id, p_pf_item_id, p_organization_id,
                         p_sr_instance_id, p_stolen_demand_class, l_pf_stealing_rec_date,
                         p_transaction_id, -1 * p_pf_stealing_quantity, 50, p_identifier,p_demand_source_type, 1,--cmro
                         -1 * p_pf_stealing_quantity, p_mem_item_id, 47,
                         G_USER_ID, l_sysdate, G_USER_ID, l_sysdate, p_stealing_demand_class, p_refresh_number, -- For summary enhancement
                         --bug3684383
                         p_order_number,MSC_ATP_PVT.G_PARTNER_ID,MSC_ATP_PVT.G_PARTNER_SITE_ID);

            l_rows_proc := l_rows_proc + SQL%ROWCOUNT;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'Total Rows inserted ' || l_rows_proc);
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Add_PF_Stealing_Supply_Details: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Add_PF_Stealing_Supply_Details;

/*--Get_Mat_Avail_Pf--------------------------------------------------------
|  o  Called from Get_Material_Atp_Info procedure.
|  o  Calls these private procedures:
|       -  Get_Mat_Avail_Pf_Ods - For PF ODS ATP
|       -  Get_Mat_Avail_Pf_Ods_Summ - For PF ATP for ODS summary
|       -  Get_Mat_Avail_Pf_Pds - For Unallocated Time Phased PF ATP
|       -  Get_Mat_Avail_Pf_Pds_Summ - For Unallocated Time Phased PF ATP
|            for PDS summary
+-------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf(
        p_summary_flag                  IN      VARCHAR2,
        p_item_id                       IN      NUMBER,
        p_request_item_id               IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_cal_code                      IN      VARCHAR2,
        p_sysdate_seq_num               IN      NUMBER,
        p_sys_next_date                 IN      DATE,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        p_refresh_number                IN      NUMBER,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_return_status                 VARCHAR2(1);

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF MSC_ATP_PVT.G_INV_CTP = 5 THEN
                -- ODS atp
                IF p_summary_flag = 'Y' THEN
                        -- summary ODS atp
                        Get_Mat_Avail_Pf_Ods_Summ(
                                p_item_id,
                                p_org_id,
                                p_instance_id,
                                p_plan_id,
                                p_demand_class,
                                p_default_atp_rule_id,
                                p_default_dmd_class,
                                p_itf,
                                x_atp_dates,
                                x_atp_qtys,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Ods_Summ');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                ELSE
                        -- ODS atp
                        Get_Mat_Avail_Pf_Ods(
                                p_item_id,
                                p_org_id,
                                p_instance_id,
                                p_plan_id,
                                p_cal_code,
                                p_sysdate_seq_num,
                                p_sys_next_date,
                                p_demand_class,
                                p_default_atp_rule_id,
                                p_default_dmd_class,
                                p_itf,
                                x_atp_dates,
                                x_atp_qtys,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Ods');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF;
        ELSE
                -- PDS atp
                IF p_summary_flag = 'Y' THEN
                        Get_Mat_Avail_Pf_Pds_Summ(
                                p_request_item_id,
                                p_item_id,
                                p_org_id,
                                p_instance_id,
                                p_plan_id,
                                p_itf,
                                p_refresh_number,       -- For summary enhancement
                                x_atp_dates,
                                x_atp_qtys,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Pds_Summ');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                ELSE
                        Get_Mat_Avail_Pf_Pds(
                                p_request_item_id,
                                p_item_id,
                                p_org_id,
                                p_instance_id,
                                p_plan_id,
                                p_itf,
                                x_atp_dates,
                                x_atp_qtys,
                                l_return_status
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Pds');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                        END IF;
                END IF; -- summary atp
        END IF; -- ODS/PDS
EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf;

/*--Get_Mat_Avail_Pf_Dtls---------------------------------------------------
|  o  Called from Insert_Details procedure.
|  o  Calls these private procedures:
|       -  Get_Mat_Avail_Pf_Ods_Dtls - For PF ODS ATP
|       -  Get_Mat_Avail_Pf_Pds_Dtls - For Unallocated Time Phased PF ATP
+-------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Dtls (
        p_item_id                       IN      NUMBER,
        p_request_item_id               IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_cal_code                      IN      VARCHAR2,
        p_sysdate_seq_num               IN      NUMBER,
        p_sys_next_date                 IN      DATE,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        p_level                         IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_identifier                    IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_return_status                 VARCHAR2(1);
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Dtls');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF MSC_ATP_PVT.G_INV_CTP = 5 THEN
                -- ODS atp
                Get_Mat_Avail_Pf_Ods_Dtls(
                        p_item_id,
                        p_request_item_id,
                        p_org_id,
                        p_instance_id,
                        p_plan_id,
                        p_cal_code,
                        p_sysdate_seq_num,
                        p_sys_next_date,
                        p_demand_class,
                        p_default_atp_rule_id,
                        p_default_dmd_class,
                        p_itf,
                        p_level,
                        p_scenario_id,
                        p_identifier,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Dtls: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Ods_Dtls');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;
        ELSE
                Get_Mat_Avail_Pf_Pds_Dtls(
                        p_item_id,
                        p_request_item_id,
                        p_org_id,
                        p_instance_id,
                        p_plan_id,
                        p_itf,
                        p_level,
                        p_scenario_id,
                        p_identifier,
                        l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Dtls: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Pds_Dtls');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                END IF;
        END IF; -- ODS/PDS
EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Dtls: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Dtls;

/*--Get_Mat_Avail_Pf_Ods_Summ-----------------------------------------------
|  o  Existing code for PF ODS summary moved to this procedure.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Ods_Summ(
        p_item_id                       IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Ods_Summ');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- in summary approach we store sales ordrers for requested item while
        -- demands and supplies are stored on PF level
        SELECT SD_DATE, sum(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM
        (SELECT  /*+ INDEX(D MSC_ATP_SUMMARY_SO_U1) */
                 D.SD_DATE SD_DATE,
                 -1* D.SD_QTY SD_QTY
        FROM        MSC_ATP_SUMMARY_SO D,
                    MSC_ATP_RULES R,
                    MSC_SYSTEM_ITEMS I,
                    MSC_SYSTEM_ITEMS I0
        WHERE       I0.SR_INVENTORY_ITEM_ID = p_item_id
        AND         I0.ORGANIZATION_ID = p_org_id
        AND         I0.SR_INSTANCE_ID = p_instance_id
        AND         I0.PLAN_ID = p_plan_id
        AND         I.PRODUCT_FAMILY_ID = I0.INVENTORY_ITEM_ID
        AND         I.ORGANIZATION_ID = I0.ORGANIZATION_ID
        AND         I.SR_INSTANCE_ID = I0.SR_INSTANCE_ID
        AND         I.PLAN_ID = I0.PLAN_ID
        AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND	       R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND	       D.PLAN_ID = I.PLAN_ID
        AND	       D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND	       D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND 	       D.ORGANIZATION_ID = I.ORGANIZATION_ID
        AND         D.SD_DATE < NVL(p_itf,
                         D.SD_DATE + 1)
        AND         NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                             DECODE(R.DEMAND_CLASS_ATP_FLAG,
                             1, NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')),
                             NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')))
        AND         D.sd_qty <> 0
        UNION ALL

        SELECT      /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                    S.SD_DATE SD_DATE,
                    S.SD_QTY SD_QTY
        FROM        MSC_ATP_SUMMARY_SD S,
                    MSC_ATP_RULES R,
                    MSC_SYSTEM_ITEMS I
        WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
        AND         I.ORGANIZATION_ID = p_org_id
        AND         I.SR_INSTANCE_ID = p_instance_id
        AND         I.PLAN_ID = p_plan_id
        AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND         R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND	       S.PLAN_ID = I.PLAN_ID
        AND	       S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND	       S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND 	       S.ORGANIZATION_ID = I.ORGANIZATION_ID
        AND         S.SD_DATE < NVL(p_itf, S.SD_DATE + 1)
        AND         NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                             DECODE(R.DEMAND_CLASS_ATP_FLAG,
                             1, NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')),
                             NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')))
        AND         S.SD_QTY <> 0
        )
        group by  SD_DATE
        order by SD_DATE; --4698199
EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Ods_Summ: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Ods_Summ;

/*--Get_Mat_Avail_Pf_Ods----------------------------------------------------
|  o  Existing code for PF ODS ATP moved to this procedure.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Ods(
        p_item_id                       IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_cal_code                      IN      VARCHAR2,
        p_sysdate_seq_num               IN      NUMBER,
        p_sys_next_date                 IN      DATE,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        -- local variables
        l_sysdate               date := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Ods');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- SQL Query changes Begin 2640489
        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
        SELECT  C.PRIOR_DATE SD_DATE,
                -1* D.USING_REQUIREMENT_QUANTITY SD_QTY
    FROM        MSC_CALENDAR_DATES C,
		MSC_DEMANDS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SYSTEM_ITEMS I0
    WHERE       I0.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I0.ORGANIZATION_ID = p_org_id
    AND         I0.SR_INSTANCE_ID = p_instance_id
    AND         I0.PLAN_ID = p_plan_id
    AND         I.PRODUCT_FAMILY_ID = I0.INVENTORY_ITEM_ID
    AND         I.ORGANIZATION_ID = I0.ORGANIZATION_ID
    AND		I.SR_INSTANCE_ID = I0.SR_INSTANCE_ID
    AND		I.PLAN_ID = I0.PLAN_ID
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND		R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
    AND		D.PLAN_ID = I.PLAN_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         USING_REQUIREMENT_QUANTITY <> 0
    AND         D.ORIGINATION_TYPE in (
                DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
                DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
                DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
    AND		C.CALENDAR_CODE = p_cal_code
    AND		C.EXCEPTION_SET_ID = G_CAL_EXC_SET_ID
    AND         C.SR_INSTANCE_ID = I0.SR_INSTANCE_ID
    -- since we store repetitive schedule demand in different ways for
    -- ods (total quantity on start date) and pds  (daily quantity from
    -- start date to end date), we need to make sure we only select work day
    -- for pds's repetitive schedule demand.
    AND         C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                          D.USING_ASSEMBLY_DEMAND_DATE))
                -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
    AND         (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
    AND         C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
                -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1 OR
                 NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                   NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
    UNION ALL
    -- bug 2461071 to_date and trunc
    SELECT      DECODE(D.RESERVATION_TYPE, 2, p_sys_next_date, TRUNC(D.REQUIREMENT_DATE)) SD_DATE, --bug 2287148
                -1*(D.PRIMARY_UOM_QUANTITY-GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                    D.COMPLETED_QUANTITY)) SD_QTY
    FROM
                -- Bug 1756263, performance fix, use EXISTS subquery instead.
		--MSC_CALENDAR_DATES C,
		MSC_SALES_ORDERS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SYSTEM_ITEMS I0,
                MSC_CALENDAR_DATES C
    WHERE       I0.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I0.ORGANIZATION_ID = p_org_id
    AND         I0.SR_INSTANCE_ID = p_instance_id
    AND         I0.PLAN_ID = p_plan_id
    AND         I.PRODUCT_FAMILY_ID = I0.INVENTORY_ITEM_ID
    AND         I.ORGANIZATION_ID = I0.ORGANIZATION_ID
    AND         I.SR_INSTANCE_ID = I0.SR_INSTANCE_ID
    AND         I.PLAN_ID = I0.PLAN_ID
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
    AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
    AND         D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                D.COMPLETED_QUANTITY)
    AND         DECODE(MSC_ATP_PVT.G_APPS_VER,3,D.COMPLETED_QUANTITY,0) = 0 -- 2300767
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
                -- new clause, remove existing Exists Query 2640489
    AND      (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
    AND      C.CALENDAR_CODE = p_cal_code
    AND      C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND      C.EXCEPTION_SET_ID = -1
    AND      C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
    AND      C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
                -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
     AND        (R.DEMAND_CLASS_ATP_FLAG <> 1
                 OR NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@'))
                  = NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
    UNION ALL
    SELECT      -- C.NEXT_DATE SD_DATE, -- 2859130
                C.CALENDAR_DATE SD_DATE,
                --- bug 1843471, 2563139
                Decode(order_type,
                30, Decode(Sign(S.Daily_rate * (TRUNC(C.Calendar_date) -  TRUNC(S.FIRST_UNIT_START_DATE))- S.qty_completed),
                             -1,S.Daily_rate* (TRUNC(C.Calendar_date) - TRUNC(S.First_Unit_Start_date) +1)- S.qty_completed,
                              S.Daily_rate),
                -- Bug 2132288, 2442009
                5, NVL(S.DAILY_RATE, NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)),
                -- End Bug 2132288, 2442009

                 -- Bug 2439264, for OPM, lots with order_processing = "N" will be populated with
                 -- non_nettable_qty and need to be excluded from ATP calculations.

                    (NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) - NVL(S.NON_NETTABLE_QTY, 0)) )SD_QTY
                -- NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) )SD_QTY
    FROM        MSC_CALENDAR_DATES C,
		MSC_SUPPLIES S,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SUB_INVENTORIES MSI
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND         I.SR_INSTANCE_ID = p_instance_id
    AND         I.PLAN_ID = p_plan_id
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
    AND		S.PLAN_ID = I.PLAN_ID
    AND		S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	S.ORGANIZATION_ID = I.ORGANIZATION_ID
    ---bug 1843471
    --AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
                -- Bug 2132288, 2442009, 2453938
                -- Do not include supplies equal to 0 as per 1243985
                -- However at the same time, support negative supplies as per Bug 2362079 use ABS.
                -- Support Repetitive schedules as per 1843471
                -- Support Repetitive MPS as per 2132288, 2442009
    AND         Decode(S.order_type, 30, S.Daily_rate* (TRUNC(C.Calendar_date) - TRUNC(S.First_Unit_Start_date) + 1),
                                     5, NVL(S.Daily_rate, ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ),
                        ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ) >
                      Decode(S.order_type, 30, S.qty_completed,0)
                -- End Bug 2132288, 2442009, 2453938
    AND         (S.ORDER_TYPE IN (
                DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
                DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), -- 1882898
                DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
                DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1),
                DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
                DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
                DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
                DECODE(R.INCLUDE_INTERNAL_REQS, 1, 2, -1),
                DECODE(R.INCLUDE_SUPPLIER_REQS, 1, 2, -1),
                DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
                OR
                ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
                S.ORDER_TYPE = 5
		-- bug 2461071
                AND exists (SELECT '1'
                            FROM    MSC_DESIGNATORS
                            WHERE   INVENTORY_ATP_FLAG = 1
                            AND     DESIGNATOR_TYPE = 2
                            AND     DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID
                            AND     DECODE(R.demand_class_atp_flag,1,
                                    nvl(demand_class,
                                    nvl(p_default_dmd_class,'@@@')),'@@@') =
                                    DECODE(R.demand_class_atp_flag,1,
                                    nvl(p_demand_class,
                                    nvl(p_default_dmd_class,'@@@')),'@@@')
)))
                --AND MSC_ATP_FUNC.MPS_ATP(S.SCHEDULE_DESIGNATOR_ID) = 1))
    AND		C.CALENDAR_CODE = p_cal_code
    AND		C.EXCEPTION_SET_ID = G_CAL_EXC_SET_ID
    AND         C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
                 -- Bug 2132288, 2442009
    AND         C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                    AND TRUNC(NVL(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE), NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
    AND         DECODE(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE),
                       NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                 -- End Bug 2132288, 2442009
                 -- new clause 2640489, SIMPLIFY FOR CBO
    AND         (S.ORDER_TYPE = 18
                 OR R.PAST_DUE_SUPPLY_CUTOFF_FENCE is NULL
                 OR C.NEXT_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
    AND         C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(l_sysdate),
                                                28, TRUNC(l_sysdate),
                                                    C.NEXT_DATE)
    AND         C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1
                 OR S.ORDER_TYPE = 5
                 OR NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                    NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
					 ---bug 1735580
                --- filter out non-atpable sub-inventories
    AND          MSI.plan_id (+) =  p_plan_id
    AND          MSI.organization_id (+) = p_org_id
    AND          MSI.sr_instance_id (+) =  p_instance_id
    --aND          S.subinventory_code = (+) MSI.sub_inventory_code
    AND          MSI.sub_inventory_code (+) = S.subinventory_code
    AND          NVL(MSI.inventory_atp_code,1) <> 2 -- filter out non-atpable subinventories
    -- SQL Query changes End 2640489
)
GROUP BY SD_DATE
order by SD_DATE; --4698199

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Ods: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Ods;

/*--Get_Mat_Avail_Pf_Pds_Summ----------------------------------------------------
|  o Called for unallocated time phased PF atp for PDS summary
|  o Differences from non summary SQL are :
|    - Additional union with MSC_ATP_SUMMARY_SD
|    - Decode in quantity in SQL on msc_alloc_demands to consider unscheduled
|      orders as dummy supplies
|    - Additional join with MSC_PLANS in the SQLs on supplies and demands to
|      filter records based on refresh number
|    - Filter on allocated_quantity=0 and origination_type=51 removed in the
|      demands SQL so as to consider copy SOs and dummy supplies respectiviely.
+-------------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Pds_Summ(
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        p_refresh_number                IN      NUMBER,     -- For summary enhancement
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Pds_Summ');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
            SELECT      /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                        SD_DATE, SD_QTY
            FROM        MSC_ATP_SUMMARY_SD S,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         S.PLAN_ID = I.PLAN_ID
            AND         S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         S.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND         S.SD_DATE < NVL(p_itf, S.SD_DATE + 1)

            UNION ALL
            --bug3700564 added trunc
            SELECT      TRUNC(AD.DEMAND_DATE) SD_DATE,
                        decode(AD.ALLOCATED_QUANTITY,           -- Consider unscheduled orders as dummy supplies
                               0, OLD_ALLOCATED_QUANTITY,       -- For summary enhancement
                                  -1 * AD.ALLOCATED_QUANTITY) SD_QTY
            FROM        MSC_ALLOC_DEMANDS AD,
                        MSC_SYSTEM_ITEMS I,
                        MSC_PLANS P                             -- For summary enhancement
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         AD.PLAN_ID = I.PLAN_ID
            AND         AD.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         AD.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         AD.ORGANIZATION_ID = I.ORGANIZATION_ID
            --bug3700564 added trunc
            AND         TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
            AND         P.PLAN_ID = AD.PLAN_ID
            AND         (AD.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                        OR AD.REFRESH_NUMBER = p_refresh_number)

            UNION ALL
            --bug3700564 added trunc
            SELECT      TRUNC(SA.SUPPLY_DATE) SD_DATE,
                        SA.ALLOCATED_QUANTITY SD_QTY
            FROM        MSC_ALLOC_SUPPLIES SA,
                        MSC_SYSTEM_ITEMS I,
                        MSC_PLANS P                             -- For summary enhancement
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         SA.PLAN_ID = I.PLAN_ID
            AND         SA.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         SA.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         SA.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND         SA.ALLOCATED_QUANTITY <> 0
            --bug3700564 added trunc
            AND         TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
            AND         P.PLAN_ID = SA.PLAN_ID
            AND         (SA.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                        OR SA.REFRESH_NUMBER = p_refresh_number)
        )
        GROUP BY SD_DATE
        order by SD_DATE; --4698199

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Pds_Summ: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Pds_Summ;

/*--Get_Mat_Avail_Pf_Pds---------------------------------------------------------
|  o  Called for unallocated Time Phased PF ATP
|  o  The supply demand SQL in this procedure gets following:
|       -  Bucketed demands (origination type 51) for member item upto ATF from
|            msc_alloc_demands table.
|       -  Bucketed demands for family after ATF from msc_alloc_demands table.
|       -  Rollup supplies (order type 50) for member item upto ATF from
|            msc_alloc_supplies table.
|       -  Rollup supplies for family after ATF from msc_alloc_supplies table.
+------------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Pds(
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Pds');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
            --bug3700564 added trunc
            SELECT      TRUNC(AD.DEMAND_DATE) SD_DATE,
                        -1 * AD.ALLOCATED_QUANTITY SD_QTY
            FROM        MSC_ALLOC_DEMANDS AD,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         AD.PLAN_ID = I.PLAN_ID
            AND         AD.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         AD.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         AD.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND         AD.ORIGINATION_TYPE <> 52
            AND         AD.ALLOCATED_QUANTITY <> 0
            --bug3700564 added trunc
            AND         TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
            UNION ALL
            --bug3700564 added trunc
            SELECT      TRUNC(SA.SUPPLY_DATE) SD_DATE,
                        SA.ALLOCATED_QUANTITY SD_QTY
            FROM        MSC_ALLOC_SUPPLIES SA,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         SA.PLAN_ID = I.PLAN_ID
            AND         SA.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         SA.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         SA.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND         SA.ALLOCATED_QUANTITY <> 0
            --bug3700564 added trunc
            AND         TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
            AND         TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
        )
        GROUP BY SD_DATE
        order by SD_DATE; --4698199

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Pds: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Pds;

/*--Get_Mat_Avail_Pf_Ods_Dtls-----------------------------------------------
|  o  Existing code for PF ODS details moved to this procedure.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Ods_Dtls (
        p_item_id                       IN      NUMBER,
        p_request_item_id               IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_cal_code                      IN      VARCHAR2,
        p_sysdate_seq_num               IN      NUMBER,
        p_sys_next_date                 IN      DATE,
        p_demand_class                  IN      VARCHAR2,
        p_default_atp_rule_id           IN      NUMBER,
        p_default_dmd_class             IN      VARCHAR2,
        p_itf                           IN      DATE,
        p_level                         IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_identifier                    IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_null_num              NUMBER;
        l_null_char             VARCHAR2(1);
        l_null_date             DATE; --bug3814584
        l_sysdate               DATE := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Ods_Dtls');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

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

        (        -- SQL Query changes Begin 2640489
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
		I.UOM_CODE col16,
		1 col17, -- demand
		D.ORIGINATION_TYPE col18,
                l_null_char col19,
		D.SR_INSTANCE_ID col20,
                l_null_num col21,
		D.DEMAND_ID col22,
		l_null_num col23,
                -1* D.USING_REQUIREMENT_QUANTITY col24,
		C.PRIOR_DATE col25,
                l_null_num col26,
                DECODE(D.ORIGINATION_TYPE, 1, to_char(D.DISPOSITION_ID), D.ORDER_NUMBER) col27,
                       -- rajjain 04/25/2003 Bug 2771075
                       -- For Planned Order Demands We will populate disposition_id
                       -- in disposition_name column
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                                D.REQUEST_SHIP_DATE) --bug3263368
    FROM        MSC_CALENDAR_DATES C,
		MSC_DEMANDS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SYSTEM_ITEMS I0,
                MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE       I0.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I0.ORGANIZATION_ID = p_org_id
    AND		I0.SR_INSTANCE_ID = p_instance_id
    AND		I0.PLAN_ID = p_plan_id
    AND       	I.PRODUCT_FAMILY_ID = I0.INVENTORY_ITEM_ID
    AND         I.ORGANIZATION_ID = I0.ORGANIZATION_ID
    AND         I.SR_INSTANCE_ID = I0.SR_INSTANCE_ID
    AND         I.PLAN_ID = I0.PLAN_ID
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
    AND		D.PLAN_ID = I.PLAN_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         USING_REQUIREMENT_QUANTITY <> 0
    AND	        D.ORIGINATION_TYPE in (
                DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
                DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
                DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
    AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
    AND		C.CALENDAR_CODE=p_cal_code
    AND		C.EXCEPTION_SET_ID=G_CAL_EXC_SET_ID
    AND         C.SR_INSTANCE_ID = p_instance_id
    -- since we store repetitive schedule demand in different ways for
    -- ods (total quantity on start date) and pds  (daily quantity from
    -- start date to end date), we need to make sure we only select work day
    -- for pds's repetitive schedule demand.
    AND         C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                          D.USING_ASSEMBLY_DEMAND_DATE))
    AND         (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
    AND         C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1 OR
                 NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                   NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
    UNION ALL
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4,
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
                I.UOM_CODE col16,
                1 col17, -- demand
                DECODE(D.RESERVATION_TYPE, 1, 6, 10)  col18,
                l_null_char col19,
                D.SR_INSTANCE_ID col20,
                l_null_num col21,
                to_number(D.DEMAND_SOURCE_LINE) col22,
                l_null_num col23,
                -1*(D.PRIMARY_UOM_QUANTITY-
                GREATEST(NVL(D.RESERVATION_QUANTITY,0), D.COMPLETED_QUANTITY))
                col24,
                --C.PRIOR_DATE
                -- bug 2461071 to_date
                DECODE(D.RESERVATION_TYPE,2,p_sys_next_date, TRUNC(D.REQUIREMENT_DATE)) col25 ,
                l_null_num col26,
                D.SALES_ORDER_NUMBER col27,
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
	        MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                                D.REQUEST_SHIP_DATE) --bug3263368
    FROM
		MSC_SALES_ORDERS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SYSTEM_ITEMS I0,
                MSC_CALENDAR_DATES C,
                MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE       I0.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I0.ORGANIZATION_ID = p_org_id
    AND         I0.SR_INSTANCE_ID = p_instance_id
    AND         I0.PLAN_ID = p_plan_id
    AND         I.PRODUCT_FAMILY_ID = I0.INVENTORY_ITEM_ID
    AND         I.ORGANIZATION_ID = I0.ORGANIZATION_ID
    AND         I.SR_INSTANCE_ID = I0.SR_INSTANCE_ID
    AND         I.PLAN_ID = I0.PLAN_ID
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
    AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
    AND         D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                D.COMPLETED_QUANTITY)
    AND         DECODE(MSC_ATP_PVT.G_APPS_VER,3,D.COMPLETED_QUANTITY,0) = 0 -- 2300767
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
                -- new clause, remove existing Exists Query 2640489
    AND         D.SHIP_TO_SITE_USE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
    AND      (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
    AND      C.CALENDAR_CODE = p_cal_code
    AND      C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND      C.EXCEPTION_SET_ID = -1
    AND      C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
    AND      C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
     AND        (R.DEMAND_CLASS_ATP_FLAG <> 1
                 OR NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@'))
                  = NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
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
                I.UOM_CODE col16,
                2 col17, -- supply
                S.ORDER_TYPE col18,
                l_null_char col19,
                S.SR_INSTANCE_ID col20,
                l_null_num col21,
                S.TRANSACTION_ID col22,
                l_null_num col23,
                ---bug 1843471
                --NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) col24,
                Decode(order_type,
                30, Decode(Sign(S.Daily_rate * (TRUNC(C.Calendar_date) -
				TRUNC(S.FIRST_UNIT_START_DATE) )- S.qty_completed),
                             -1,S.Daily_rate* (TRUNC(C.Calendar_date) - TRUNC(S.First_Unit_Start_date) +1)- S.qty_completed,
                              S.Daily_rate),
                -- Bug 2132288, 2442009, 2563139
                5, NVL(S.DAILY_RATE, NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)),
                -- End Bug 2132288, 2442009

                -- Bug 2439264, for OPM, lots with order_processing = "N" will be populated with
                -- non_nettable_qty and need to be excluded from ATP calculations.

                (NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) - NVL(S.NON_NETTABLE_QTY, 0)) ) col24,

                -- NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) ) col24,
                C.NEXT_DATE col25,
                l_null_num col26,
                DECODE(S.ORDER_TYPE,
                       1, S.ORDER_NUMBER,
		       2, S.ORDER_NUMBER,
		       3, S.ORDER_NUMBER,
                       7, S.ORDER_NUMBER,
                       8, S.ORDER_NUMBER,
                       5, MSC_ATP_FUNC.Get_Designator(S.SCHEDULE_DESIGNATOR_ID),
                      11, S.ORDER_NUMBER,
                      12, S.ORDER_NUMBER,
                      14, S.ORDER_NUMBER,
                      15, S.ORDER_NUMBER,
                      27, S.ORDER_NUMBER,
                      28, S.ORDER_NUMBER,
                      41, S.ORDER_NUMBER, -- bug 4085497 'User Defined Supply'
                      --NULL) col27,
                      l_null_char) col27, -- bug 4365873 fixed as a part of this bug
                l_null_num col28,
		l_null_num col29,
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		--null,--bug3263368 ORIG_CUSTOMER_SITE_NAME
		--null, --bug3263368 ORIG_CUSTOMER_NAME
		--null, --bug3263368 ORIG_DEMAND_CLASS
		--null  --bug3263368 ORIG_REQUEST_DATE
		l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_date  --bug3814584
    FROM        MSC_CALENDAR_DATES C,
		MSC_SUPPLIES S,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SUB_INVENTORIES MSI
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND         I.SR_INSTANCE_ID = p_instance_id
    AND         I.PLAN_ID = p_plan_id
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
    AND		S.PLAN_ID = I.PLAN_ID
    AND		S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	S.ORGANIZATION_ID = I.ORGANIZATION_ID
    --- bug 1843471
    --AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
                -- Bug 2132288, 2442009, 2453938
                -- Do not include supplies equal to 0 as per 1243985
                -- However at the same time, support negative supplies as per Bug 2362079 use ABS.
                -- Support Repetitive schedules as per 1843471
                -- Support Repetitive MPS as per 2132288, 2442009
		-- TRUNC dates 2563139
    AND         Decode(S.order_type, 30, S.Daily_rate* (TRUNC(C.Calendar_date)
					- TRUNC(S.First_Unit_Start_date) + 1),
                                     5, NVL(S.Daily_rate, ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ),
                        ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ) >
                      Decode(S.order_type, 30, S.qty_completed,0)
                -- End Bug 2132288, 2442009, 2453938
    AND		(S.ORDER_TYPE IN (
		DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
		DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), -- 1882898
		DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
		DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
		DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
		DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1),
		DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
                DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
		DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
		DECODE(R.INCLUDE_INTERNAL_REQS, 1, 2, -1),
		DECODE(R.INCLUDE_SUPPLIER_REQS, 1, 2, -1),
                DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1),
		DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
		DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
                OR
                ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
                S.ORDER_TYPE = 5
                 -- bug 2461071
                AND exists (SELECT '1'
                            FROM    MSC_DESIGNATORS
                            WHERE   INVENTORY_ATP_FLAG = 1
                            AND     DESIGNATOR_TYPE = 2
                            AND     DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID
                            AND     DECODE(R.demand_class_atp_flag,1,
                                    nvl(demand_class,
                                    nvl(p_default_dmd_class,'@@@')),'@@@') =
                                    DECODE(R.demand_class_atp_flag,1,
                                    nvl(p_demand_class,
                                    nvl(p_default_dmd_class,'@@@')),'@@@')
)))
                --AND MSC_ATP_FUNC.MPS_ATP(S.SCHEDULE_DESIGNATOR_ID) = 1))
    AND		C.CALENDAR_CODE = p_cal_code
    AND		C.EXCEPTION_SET_ID = G_CAL_EXC_SET_ID
    AND         C.SR_INSTANCE_ID = p_instance_id
                 -- Bug 2132288, 2442009
    AND         C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                    AND TRUNC(NVL(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE), NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
    AND         DECODE(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE),
                       NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                 -- End Bug 2132288, 2442009
                 -- new clause 2640489, SIMPLIFY FOR CBO
    AND         (S.ORDER_TYPE = 18
                 OR R.PAST_DUE_SUPPLY_CUTOFF_FENCE is NULL
                 OR C.NEXT_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
    AND         C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(l_sysdate),
                                                28, TRUNC(l_sysdate),
                                                    C.NEXT_DATE)
    AND         C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1
                 OR S.ORDER_TYPE = 5
                 OR NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                    NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
                --- filter out non-atpable sub-inventories
    AND          MSI.plan_id (+) = p_plan_id
    AND          MSI.organization_id (+) = p_org_id
    AND          MSI.sr_instance_id (+) = p_instance_id
    -- AND          S.subinventory_code = MSI.sub_inventory_code
    AND          MSI.sub_inventory_code (+) = S.subinventory_code
    AND          NVL(MSI.inventory_atp_code,1)  <> 2  -- filter out non-atpable subinventories
    -- SQL Query changes End 2640489
)
;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Ods_Dtls: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Ods_Dtls;

/*--Get_Mat_Avail_Pf_Pds_Dtls-----------------------------------------------------------
|  o  Called for unallocated Time Phased PF ATP with Details.
|  o  The supply demand SQL inserts following in msc_atp_sd_details_temp table:
|       -  Bucketed demands (origination type 51) for member item upto ATF from
|            msc_alloc_demands table.
|       -  Bucketed demands for family after ATF from msc_alloc_demands table.
|       -  Rollup supplies (order type 50) for member item upto ATF from
|            msc_alloc_supplies table.
|       -  Rollup supplies for family after ATF from msc_alloc_supplies table.
|  o  Other important differences from non PF SQLs are:
|       -  Columns Pf_Display_Flag, Original_Demand_Quantity and Original_Demand_Date
|            in msc_atp_sd_details_temp table are populated for demands.
|       -  Column Original_Supply_Demand_Type is populated for demands and supplies
|            and stores the supply demand type of parent supplies and demands.
+-------------------------------------------------------------------------------------*/
PROCEDURE Get_Mat_Avail_Pf_Pds_Dtls (
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        p_level                         IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_identifier                    IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_null_num              NUMBER;
        l_null_char             VARCHAR2(1);
        l_null_date             DATE; --bug3814584
        l_sysdate               DATE := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin Get_Mat_Avail_Pf_Pds_Dtls');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

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
        	Allocated_Quantity,
        	Supply_Demand_Date,
        	Disposition_Type,
        	Disposition_Name,
        	Pegging_Id,
        	End_Pegging_Id,
        	Pf_Display_Flag,
        	Supply_Demand_Quantity,
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
                ORIG_REQUEST_DATE, --bug3263368
                Inventory_Item_Name --bug3579625
        )
        (
            SELECT      p_level col1,
        		p_identifier col2,
                        p_scenario_id col3,
                        p_sr_family_id col4,
                        p_sr_member_id col5,
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
        		I.UOM_CODE col16,
        		1 col17, -- demand
        		AD.ORIGINATION_TYPE col18,
                        l_null_char col19,
        		AD.SR_INSTANCE_ID col20,
                        l_null_num col21,
        		AD.PARENT_DEMAND_ID col22,
        		l_null_num col23,
                        -1 * AD.ALLOCATED_QUANTITY col24,
                        TRUNC(AD.DEMAND_DATE) col25, --bug3693892 added trunc
                        l_null_num col26,
                        AD.ORDER_NUMBER col27,
                        l_null_num col28,
                        l_null_num col29,
                        AD.Pf_Display_Flag,
                        -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY),
                        -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY),
                        trunc(AD.Original_Demand_Date), --Bug_3693892 added trunc
                        AD.Original_Item_Id,
                        AD.Original_Origination_Type,
        		l_sysdate,
        		G_USER_ID,
        		l_sysdate,
        		G_USER_ID,
        		G_USER_ID,
        		MTPS.LOCATION,   --bug3263368
                        MTP.PARTNER_NAME, --bug3263368
                        AD.DEMAND_CLASS, --bug3263368
                        AD.REQUEST_DATE, --bug3263368
                        I2.Item_Name  --bug3579625

            FROM        MSC_SYSTEM_ITEMS I,
                        MSC_SYSTEM_ITEMS I2,  --bug3579625
        		MSC_ALLOC_DEMANDS AD,
        		MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         AD.PLAN_ID = I.PLAN_ID
            AND         AD.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         AD.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         AD.ORGANIZATION_ID = I.ORGANIZATION_ID
            -- bug3579625 Addition join with MSC_SYSTEM_ITEMS (I2)
            AND         AD.PLAN_ID = I2.PLAN_ID
            AND         AD.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
            AND         AD.ORIGINAL_ITEM_ID = I2.INVENTORY_ITEM_ID
            AND         AD.ORGANIZATION_ID = I2.ORGANIZATION_ID
            AND         AD.ORIGINATION_TYPE <> 52
            AND         AD.ALLOCATED_QUANTITY <> 0
            --bug3700564 added trunc
            AND         TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
            AND         AD.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
            AND         AD.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
            UNION ALL
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_family_id col4 ,
                        p_sr_member_id col5,
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
                        I.UOM_CODE col16,
                        2 col17,
                        SA.ORDER_TYPE col18,
                        l_null_char col19,
                        SA.SR_INSTANCE_ID col20,
                        l_null_num col21,
                        SA.PARENT_TRANSACTION_ID col22,
                        l_null_num col23,
        		SA.ALLOCATED_QUANTITY col24,
                        trunc(SA.SUPPLY_DATE) col25,  --bug3693892 added trunc
                        l_null_num col26,
        		DECODE(SA.ORDER_TYPE, 5, to_char(SA.PARENT_TRANSACTION_ID), SA.ORDER_NUMBER) col27,
                        l_null_num col28,
        		l_null_num col29,
        		l_null_num,
        		NVL(SA.Supply_Quantity, SA.ALLOCATED_QUANTITY),
        		l_null_num,
        		to_date(null),
        		SA.Original_Item_Id,
        		SA.Original_Order_Type,
        		l_sysdate,
        		G_USER_ID,
        		l_sysdate,
        		G_USER_ID,
        		G_USER_ID,
        		--null, --bug3263368 ORIG_CUSTOMER_SITE_NAME
        		--null, --bug3263368 ORIG_CUSTOMER_NAME
        		--null, --bug3263368 ORIG_DEMAND_CLASS
        		--null, --bug3263368 ORIG_REQUEST_DATE
        		l_null_char, --bug3814584
                        l_null_char, --bug3814584
                        l_null_char, --bug3814584
                        l_null_date,  --bug3814584
                        I2.Item_Name  --bug3579625
            FROM        MSC_ALLOC_SUPPLIES SA,
                        MSC_SYSTEM_ITEMS I,
                        MSC_SYSTEM_ITEMS I2 --bug3579625
            WHERE       I.SR_INVENTORY_ITEM_ID in (p_sr_member_id, p_sr_family_id)
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         SA.PLAN_ID = I.PLAN_ID
            AND         SA.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         SA.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         SA.ORGANIZATION_ID = I.ORGANIZATION_ID
            -- bug3579625 Addition join with MSC_SYSTEM_ITEMS (I2)
            AND         SA.PLAN_ID = I2.PLAN_ID
            AND         SA.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
            AND         SA.ORIGINAL_ITEM_ID = I2.INVENTORY_ITEM_ID
            AND         SA.ORGANIZATION_ID = I2.ORGANIZATION_ID
            --bug3700564 added trunc
            AND         TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
            AND         SA.ALLOCATED_QUANTITY <> 0
            AND         TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
        );

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Mat_Avail_Pf_Pds_Dtls: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Mat_Avail_Pf_Pds_Dtls;

/*--Set_Alloc_Rule_Variables------------------------------------------------------
|  o  Called from Atp_Check procedure for Allocated Time Phased PF ATP.
|  o  This procedure sets global variables that tells:
|       -  Allocation rule to be used for member item inside ATF
|       -  Allocation rule to be used for family item outside ATF
+-------------------------------------------------------------------------------*/
PROCEDURE Set_Alloc_Rule_Variables (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_alloc_percent         NUMBER;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Set_Alloc_Rule_Variables **********');
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: p_org_id: ' || p_org_id);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: p_demand_class: ' || p_demand_class);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: p_atf_date: ' || p_atf_date);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: G_ALLOCATION_METHOD: ' || MSC_ATP_PVT.G_ALLOCATION_METHOD);
                msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: G_HIERARCHY_PROFILE: ' || MSC_AATP_PVT.G_HIERARCHY_PROFILE);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF MSC_ATP_PVT.G_ALLOCATION_METHOD = 1 THEN
                /* Demand priority allocated ATP
                   Here we always use allocation rule from family inside/outside ATF
                */
                IF MSC_AATP_PVT.G_HIERARCHY_PROFILE = 1 THEN
                        MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'N';
                        MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF := 'Y';
                END IF;
        ELSE
                /* Rule based allocated ATP
                   Here we support following scenarios:
                     -  Allocation rule defined only at family item
                     -  Allocation rule defined for the member and PF item

                   ATP logic:
                     -  Check allocation rule on ATF date for member item.
                          o IF defined use allocation rule from member within ATF
                            ELSE use allocation rule from family within ATF
                     -  Always use allocation rule from family outside ATF
                */
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'Determine whether rule exist for member item within ATF');
                END IF;

                IF MSC_AATP_PVT.G_HIERARCHY_PROFILE = 1 THEN
                        BEGIN
                                SELECT allocation_percent
                                INTO   l_alloc_percent
                                FROM   msc_item_hierarchy_mv
                                WHERE  inventory_item_id = p_member_id
                                AND    organization_id = p_org_id
                                AND    sr_instance_id = p_instance_id
                                AND    p_atf_date BETWEEN effective_date AND disable_date
                                AND    level_id = -1
                                AND    rownum = 1;

                                IF l_alloc_percent is not null THEN
                                    MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'Y';
                                ELSE
                                    MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'N';
                                END IF;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'Alloc Rule not found at member level');
                                    END IF;
                                    MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'N';
                        END;
                ELSE
                        BEGIN
                                SELECT allocation_percent
                                INTO   l_alloc_percent
                                FROM   msc_item_hierarchy_mv
                                WHERE  inventory_item_id = p_member_id
                                AND    organization_id = p_org_id
                                AND    sr_instance_id = p_instance_id
                                AND    p_atf_date BETWEEN effective_date AND disable_date
                                AND    level_id <> -1
                                AND    rownum = 1;

                                IF l_alloc_percent is not null THEN
                                    MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'Y';
                                ELSE
                                    MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'N';
                                END IF;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'Alloc Rule not found for member within ATF');
                                    END IF;
                                    MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF := 'N';
                        END;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'Always use rule for family item outside ATF');
                END IF;
                MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF := 'Y';
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'G_MEM_RULE_WITHIN_ATF = ' || MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF);
            msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'G_PF_RULE_OUTSIDE_ATF = ' || MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF);
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Set_Alloc_Rule_Variables: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Set_Alloc_Rule_Variables;

/*--Item_Alloc_Avail_Pf-----------------------------------------------------------
|  o  Called from Item_Alloc_Cum_Atp procedure for Rule based Allocated
|       Time Phased PF ATP.
|  o  The supply demand SQL in this procedure gets following:
|       -  Allocated Bucketed demands (origination type 51) for member item
|            upto ATF from msc_alloc_demands table.
|       -  Allocated Bucketed demands for family after ATF from msc_alloc_demands
|            table.
|       -  Allocated Rollup supplies (order type 50) for member item upto ATF
|            from msc_alloc_supplies table.
|       -  Allocated Rollup supplies for family after ATF from msc_alloc_supplies
|            table.
+-------------------------------------------------------------------------------*/
PROCEDURE Item_Alloc_Avail_Pf (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_level_id                      IN      NUMBER,
        p_itf                           IN      DATE,
        p_sys_next_date			IN 	DATE, --bug3099066
        p_atf_date                      IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Item_Alloc_Avail_Pf **********');
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: p_demand_class: ' || p_demand_class);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: p_level_id: ' || p_level_id);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

             SELECT        SD_DATE,
                           SUM(SD_QTY)
             BULK COLLECT INTO
                           x_atp_dates,
                           x_atp_qtys
             FROM (
                   SELECT  --TRUNC(AD.DEMAND_DATE) SD_DATE, 	--bug3099066
                           GREATEST(TRUNC(AD.DEMAND_DATE),p_sys_next_date) SD_DATE,--3099066
                           --bug3333114 removed trunc from p_sys_next_date as it is already trucate
                           -1* AD.ALLOCATED_QUANTITY*
                            DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                              1, decode(AD.Original_Origination_Type,
                                 6, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(AD.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                          p_instance_id, trunc(AD.Demand_Date),
                                          p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                              2, DECODE(AD.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 decode(AD.Original_Origination_Type,
                                    6, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                       AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                       Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', AD.Original_Item_Id,
                                                        p_family_id)), p_org_id, p_instance_id,
                                       trunc(AD.Demand_Date),p_level_id, NULL)))),
                           p_demand_class, 1,
                              Decode(AD.Demand_Class, NULL, --4365873 If l_demand_class is not null and demand class is populated
                             -- on  supplies record then 0 should be allocated.
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 AD.PARENT_DEMAND_ID,
                                 trunc(AD.Demand_Date),
                                 AD.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(AD.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    AD.SOURCE_ORGANIZATION_ID),
                                 Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                        1, p_family_id,
                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                'Y', AD.Original_Item_Id,
                                                p_family_id)),
                                 p_org_id,
                                 p_instance_id,
                                 AD.Original_Origination_Type,
                                 DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                    1, decode(AD.Original_Origination_Type,
                                       6, decode(AD.SOURCE_ORGANIZATION_ID,
                                          NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                                    2, DECODE(AD.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       decode(AD.Original_Origination_Type,
                                          6, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                             Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', AD.Original_Item_Id,
                                                                p_family_id)), p_org_id, p_instance_id,
                                             trunc(AD.Demand_Date),p_level_id, NULL)))),
                                       p_demand_class,
                                       p_level_id),0)) SD_QTY --4365873
                   FROM        MSC_ALLOC_DEMANDS AD
                   WHERE       AD.PLAN_ID = p_plan_id
                   AND         AD.SR_INSTANCE_ID = p_instance_id
                   AND         AD.INVENTORY_ITEM_ID in (p_member_id,p_family_id)
                   AND         AD.ORGANIZATION_ID = p_org_id
                   AND         AD.ORIGINATION_TYPE <> 52
                   AND         AD.ALLOCATED_QUANTITY <> 0
                   --bug3700564 added trunc
                   AND         TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
                   UNION ALL
                   SELECT  --TRUNC(SA.SUPPLY_DATE) SD_DATE,			--bug3099066
                   	   GREATEST(TRUNC(SA.SUPPLY_DATE),p_sys_next_date) SD_DATE,--3099066
                           SA.ALLOCATED_QUANTITY*
                              DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                     1, DECODE(SA.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         Decode(sign(trunc(SA.Supply_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', SA.Original_Item_Id,
                                                                        p_family_id)),
                                                         p_org_id,
                                                         p_instance_id,
                                                         TRUNC(SA.SUPPLY_DATE),
                                                         p_level_id,
                                                         SA.DEMAND_CLASS),
                                           SA.DEMAND_CLASS)),
                                     2, DECODE(SA.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         SA.CUSTOMER_ID,
                                                         SA.SHIP_TO_SITE_ID,
                                                         Decode(sign(trunc(SA.Supply_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', SA.Original_Item_Id,
                                                                        p_family_id)),
                                                         p_org_id,
                                                         p_instance_id,
                                                         TRUNC(SA.SUPPLY_DATE),
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL,  nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           Decode(sign(trunc(SA.Supply_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', SA.Original_Item_Id,
                                                        p_family_id)),
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           TRUNC(SA.SUPPLY_DATE)),
                                        1),*/
                                 DECODE(
                                  MIHM.allocation_percent/100, --4365873
                                 /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           Decode(sign(trunc(SA.Supply_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', SA.Original_Item_Id,
                                                        p_family_id)),
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           TRUNC(SA.SUPPLY_DATE)),*/
                                   NULL, 1,
                                 0)) SD_QTY
                   FROM    MSC_ALLOC_SUPPLIES SA, MSC_ITEM_HIERARCHY_MV MIHM --4365873
                   WHERE   SA.PLAN_ID = p_plan_id
                   AND     SA.SR_INSTANCE_ID = p_instance_id
                   AND     SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                   AND     SA.ORGANIZATION_ID = p_org_id
                   AND     SA.ALLOCATED_QUANTITY <> 0
                   --bug3700564 added trunc
                   AND     TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                   AND     TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
		   --4365874
		   --5220274 if the rule is assigned to family only then use family id.
                   AND    Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                          'N', p_family_id,
                          SA.INVENTORY_ITEM_ID) = MIHM.INVENTORY_ITEM_ID(+)
                   AND    SA.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
                   AND    SA.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
                AND    decode(MIHM.level_id (+),-1,1,2) = decode(MSC_AATP_PVT.G_HIERARCHY_PROFILE,1,1,2)
                   AND    TRUNC(SA.SUPPLY_DATE) >= MIHM.effective_date (+)
                   AND    TRUNC(SA.SUPPLY_DATE) <= MIHM.disable_date (+)
                AND    MIHM.demand_class (+) = p_demand_class
                   )
             GROUP BY SD_DATE
             order by SD_DATE; --4698199
EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Item_Alloc_Avail_Pf;

/*--Item_Alloc_Avail_Pf_Unalloc------------------------------------------------
|  o  Called from Item_Alloc_Cum_Atp procedure for Rule based Allocated Time
|       Phased PF ATP (AATP Forward Consumption Method 2).
|  o  This is similar to previous procedure only difference being that we
|       also return unallocated quantities.
+----------------------------------------------------------------------------*/
PROCEDURE Item_Alloc_Avail_Pf_Unalloc (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_level_id                      IN      NUMBER,
        p_itf                           IN      DATE,
        p_sys_next_date			IN	DATE, --3099066
        p_atf_date                      IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_atp_unalloc_qtys              OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Item_Alloc_Avail_Pf_Unalloc **********');
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: p_demand_class: ' || p_demand_class);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: p_level_id: ' || p_level_id);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

             SELECT        SD_DATE,
                           SUM(UNALLOC_SD_QTY),
                           SUM(SD_QTY)
             BULK COLLECT INTO
                           x_atp_dates,
                           x_atp_unalloc_qtys,
                           x_atp_qtys
             FROM (
                   SELECT  --TRUNC(AD.DEMAND_DATE) SD_DATE,
                   	   GREATEST(TRUNC(AD.DEMAND_DATE),p_sys_next_date) SD_DATE,--3099066
                           -1* AD.ALLOCATED_QUANTITY UNALLOC_SD_QTY,
                           -1* AD.ALLOCATED_QUANTITY*
                            DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                              1, decode(AD.Original_Origination_Type,
                                 6, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(AD.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                          p_instance_id, trunc(AD.Demand_Date),
                                          p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                              2, DECODE(AD.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 decode(AD.Original_Origination_Type,
                                    6, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                       AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                       Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', AD.Original_Item_Id,
                                                        p_family_id)), p_org_id, p_instance_id,
                                       trunc(AD.Demand_Date),p_level_id, NULL)))),
                           p_demand_class, 1,
                           Decode(AD.Demand_Class, NULL, --4365873
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 AD.PARENT_DEMAND_ID,
                                 trunc(AD.Demand_Date),
                                 AD.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(AD.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    AD.SOURCE_ORGANIZATION_ID),
                                 Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                        1, p_family_id,
                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                'Y', AD.Original_Item_Id,
                                                p_family_id)),
                                 p_org_id,
                                 p_instance_id,
                                 AD.Original_Origination_Type,
                                 DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                    1, decode(AD.Original_Origination_Type,
                                       6, decode(AD.SOURCE_ORGANIZATION_ID,
                                          NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                                    2, DECODE(AD.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       decode(AD.Original_Origination_Type,
                                          6, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                             Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', AD.Original_Item_Id,
                                                                p_family_id)), p_org_id, p_instance_id,
                                             trunc(AD.Demand_Date),p_level_id, NULL)))),
                                       p_demand_class,
                                       p_level_id),0)) SD_QTY --4365873
                   FROM        MSC_ALLOC_DEMANDS AD
                   WHERE       AD.PLAN_ID = p_plan_id
                   AND         AD.SR_INSTANCE_ID = p_instance_id
                   AND         AD.INVENTORY_ITEM_ID in (p_member_id,p_family_id)
                   AND         AD.ORGANIZATION_ID = p_org_id
                   AND         AD.ORIGINATION_TYPE <> 52
                   AND         AD.ALLOCATED_QUANTITY <> 0
                   --bug3700564 added trunc
                   AND         TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
                   UNION ALL
                   SELECT  --TRUNC(SA.SUPPLY_DATE) SD_DATE,
                   	   GREATEST(TRUNC(SA.SUPPLY_DATE),p_sys_next_date) SD_DATE,--3099066
                           SA.ALLOCATED_QUANTITY UNALLOC_SD_QTY,
                           SA.ALLOCATED_QUANTITY*
                              DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                     1, DECODE(SA.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         Decode(sign(trunc(SA.Supply_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', SA.Original_Item_Id,
                                                                        p_family_id)),
                                                         p_org_id,
                                                         p_instance_id,
                                                         TRUNC(sa.SUPPLY_DATE),
                                                         p_level_id,
                                                         sa.DEMAND_CLASS),
                                           sa.DEMAND_CLASS)),
                                     2, DECODE(sa.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         sa.CUSTOMER_ID,
                                                         sa.SHIP_TO_SITE_ID,
                                                         Decode(sign(trunc(sa.Supply_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', sa.Original_Item_Id,
                                                                        p_family_id)),
                                                         p_org_id,
                                                         p_instance_id,
                                                         TRUNC(sa.SUPPLY_DATE),
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL,  nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           Decode(sign(trunc(sa.Supply_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', sa.Original_Item_Id,
                                                        p_family_id)),
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           TRUNC(sa.SUPPLY_DATE)),
                                       1),*/
                                 DECODE(
                                  MIHM.allocation_percent/100, --4365873
                                 /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           Decode(sign(trunc(sa.Supply_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', sa.Original_Item_Id,
                                                        p_family_id)),
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           TRUNC(sa.SUPPLY_DATE)),*/
                                   NULL, 1,
                                 0)) SD_QTY
                   FROM    MSC_ALLOC_SUPPLIES SA,MSC_ITEM_HIERARCHY_MV MIHM
                   WHERE   SA.PLAN_ID = p_plan_id
                   AND     SA.SR_INSTANCE_ID = p_instance_id
                   AND     SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                   AND     SA.ORGANIZATION_ID = p_org_id
                   AND     SA.ALLOCATED_QUANTITY <> 0
                   --bug3700564 added trunc
                   AND     TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                   AND     TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
		   --4365874
		   --5220274 if the rule is assigned to family only then use family id.
                  AND    Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                             'N', p_family_id,
                         sa.INVENTORY_ITEM_ID) = MIHM.INVENTORY_ITEM_ID(+)
                  AND    sa.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
                  AND    sa.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
                AND    decode(MIHM.level_id (+),-1,1,2) = decode(MSC_AATP_PVT.G_HIERARCHY_PROFILE,1,1,2)
                  AND    TRUNC(sa.SUPPLY_DATE) >= MIHM.effective_date (+)
                  AND    TRUNC(sa.SUPPLY_DATE) <= MIHM.disable_date (+)
                AND    MIHM.demand_class (+) = p_demand_class
                   )
             GROUP BY SD_DATE
             order by SD_DATE; --4698199

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Unalloc: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Item_Alloc_Avail_Pf_Unalloc;

/*--Item_Alloc_Avail_Pf_Dtls-------------------------------------------------------------
|  o  Called from Item_Alloc_Cum_Atp procedure for Time Phased Rule Based AATP
|       scenarios.
|  o  The supply demand SQL inserts following in msc_atp_sd_details_temp table:
|       -  Allocated Bucketed demands (origination type 51) for member item upto ATF
|            from msc_alloc_demands table.
|       -  Allocated Bucketed demands for family after ATF from msc_alloc_demands table.
|       -  Allocated Rollup supplies (order type 50) for member item upto ATF from
|            msc_alloc_supplies table.
|       -  Allocated Rollup supplies for family after ATF from msc_alloc_supplies table.
|  o  Other important differences from non PF SQLs are:
|       -  Columns Pf_Display_Flag, Original_Demand_Quantity and Original_Demand_Date
|            in msc_atp_sd_details_temp table are populated for demands.
|       -  Column Original_Supply_Demand_Type is populated for demands and supplies
|            and stores the supply demand type of parent supplies and demands.
+--------------------------------------------------------------------------------------*/
PROCEDURE Item_Alloc_Avail_Pf_Dtls (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_level_id                      IN      NUMBER,
        p_itf                           IN      DATE,
        p_level                         IN      NUMBER,
        p_identifier                    IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_uom_code                      IN      VARCHAR2,
        p_sys_next_date			IN 	DATE, --bug3099066
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_null_num              NUMBER;
        l_null_char             VARCHAR2(1);
        l_null_date             DATE; --bug3814584
        l_sysdate               DATE := sysdate;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Item_Alloc_Avail_Pf_Dtls **********');
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_sr_member_id: ' || p_sr_member_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_sr_family_id: ' || p_sr_family_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_demand_class: ' || p_demand_class);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_level_id: ' || p_level_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_identifier: ' || p_identifier);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_scenario_id: ' || p_scenario_id);
                msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: p_uom_code: ' || p_uom_code);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

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
                Allocated_Quantity,
                Supply_Demand_Date,
                Disposition_Type,
                Disposition_Name,
                Pegging_Id,
                End_Pegging_Id,
        	Pf_Display_Flag,
                Supply_Demand_Quantity,
        	Original_Demand_Quantity,
        	Original_Demand_Date,
        	Original_Item_Id,
        	Original_Supply_Demand_Type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                Unallocated_Quantity,
                ORIG_CUSTOMER_SITE_NAME,--bug3263368
                ORIG_CUSTOMER_NAME, --bug3263368
                ORIG_DEMAND_CLASS, --bug3263368
                ORIG_REQUEST_DATE, --bug3263368
                Inventory_Item_Name --bug3579625
                )
           (
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_family_id col4,
                        p_sr_member_id col5,
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
                        p_uom_code col16,
                        1 col17,
                        AD.ORIGINATION_TYPE col18,
                        l_null_char col19,
                        AD.SR_INSTANCE_ID col20,
                        l_null_num col21,
                        AD.PARENT_DEMAND_ID col22,
                        l_null_num col23,
                        -1* AD.ALLOCATED_QUANTITY *
                            DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                              1, decode(AD.Original_Origination_Type,
                                 6, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(AD.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                          p_instance_id, trunc(AD.Demand_Date),
                                          p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                              2, DECODE(AD.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 decode(AD.Original_Origination_Type,
                                    6, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                       AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                       Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', AD.Original_Item_Id,
                                                        p_family_id)), p_org_id, p_instance_id,
                                       trunc(AD.Demand_Date),p_level_id, NULL)))),
                           p_demand_class, 1,
                             Decode(AD.Demand_Class, NULL, --4365873 If l_demand_class is not null and demand class is populated
                             -- on  supplies record then 0 should be allocated.
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 AD.PARENT_DEMAND_ID,
                                 trunc(AD.Demand_Date),
                                 AD.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(AD.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    AD.SOURCE_ORGANIZATION_ID),
                                 Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                        1, p_family_id,
                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                'Y', AD.Original_Item_Id,
                                                p_family_id)),
                                 p_org_id,
                                 p_instance_id,
                                 AD.Original_Origination_Type,
                                 DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                    1, decode(AD.Original_Origination_Type,
                                       6, decode(AD.SOURCE_ORGANIZATION_ID,
                                          NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                                    2, DECODE(AD.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       decode(AD.Original_Origination_Type,
                                          6, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                             Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', AD.Original_Item_Id,
                                                                p_family_id)), p_org_id, p_instance_id,
                                             trunc(AD.Demand_Date),p_level_id, NULL)))),
                                       p_demand_class,
                                       p_level_id),0)) col24, --4365873
                        --TRUNC(AD.DEMAND_DATE) col25,
                        GREATEST(TRUNC(AD.DEMAND_DATE),p_sys_next_date) col25, --3099066
                        l_null_num col26,
                        AD.ORDER_NUMBER col27,
                        l_null_num col28,
                        l_null_num col29,
                	Decode(AD.inventory_item_id, p_family_id,
                	        Decode(AD.original_item_id, p_member_id,
                	                AD.Pf_Display_Flag,
                	                Decode(sign(trunc(AD.Original_Demand_Date) - p_atf_date),
                	                        1, AD.Pf_Display_Flag,
                	                        1)),
                	        AD.Pf_Display_Flag),
                	-1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY),
                        -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY) *
                            DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                              1, decode(AD.Original_Origination_Type,
                                 6, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(AD.SOURCE_ORGANIZATION_ID,
                                    NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                    AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(AD.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)), p_org_id,
                                          p_instance_id, trunc(AD.Demand_Date),
                                          p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                              2, DECODE(AD.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 decode(AD.Original_Origination_Type,
                                    6, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                             p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                       AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                       Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', AD.Original_Item_Id,
                                                        p_family_id)), p_org_id, p_instance_id,
                                       trunc(AD.Demand_Date),p_level_id, NULL)))),
                           p_demand_class, 1,
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 AD.PARENT_DEMAND_ID,
                                 trunc(AD.Demand_Date),
                                 AD.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(AD.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    AD.SOURCE_ORGANIZATION_ID),
                                 Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                        1, p_family_id,
                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                'Y', AD.Original_Item_Id,
                                                p_family_id)),
                                 p_org_id,
                                 p_instance_id,
                                 AD.Original_Origination_Type,
                                 DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                    1, decode(AD.Original_Origination_Type,
                                       6, decode(AD.SOURCE_ORGANIZATION_ID,
                                          NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                   p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(AD.SOURCE_ORGANIZATION_ID,
                                       NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       AD.ORGANIZATION_ID, DECODE(AD.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                                p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                             AD.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(AD.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)), p_org_id,
                                             p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, AD.DEMAND_CLASS),
                                          AD.DEMAND_CLASS))),
                                    2, DECODE(AD.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       decode(AD.Original_Origination_Type,
                                          6, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(AD.SOURCE_ORGANIZATION_ID,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             AD.ORGANIZATION_ID, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID, Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                                                                1, p_family_id,
                                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                        'Y', AD.Original_Item_Id,
                                                                                                        p_family_id)),
                                                   p_org_id, p_instance_id, trunc(AD.Demand_Date),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                             Decode(sign(trunc(AD.Demand_Date) - p_atf_date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', AD.Original_Item_Id,
                                                                p_family_id)), p_org_id, p_instance_id,
                                             trunc(AD.Demand_Date),p_level_id, NULL)))),
                                       p_demand_class,
                                       p_level_id)),
                	trunc(AD.Original_Demand_Date),
                	AD.Original_Item_Id,
                	AD.Original_Origination_Type,
                        l_sysdate,
                        G_USER_ID,
                        l_sysdate,
                        G_USER_ID,
                        G_USER_ID,
                        -1* AD.ALLOCATED_QUANTITY, -- bug 3282426
                        MTPS.LOCATION,   --bug3263368
                        MTP.PARTNER_NAME, --bug3263368
                        AD.DEMAND_CLASS, --bug3263368
                        AD.REQUEST_DATE, --bug3263368
                        I.Item_Name -- bug3579625
            FROM        MSC_ALLOC_DEMANDS AD,
                        MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS, --bug3263368
                        MSC_SYSTEM_ITEMS I --bug3579625
            WHERE       AD.PLAN_ID = p_plan_id
            AND         AD.SR_INSTANCE_ID = p_instance_id
            AND         AD.INVENTORY_ITEM_ID in (p_member_id,p_family_id)
            AND         AD.ORGANIZATION_ID = p_org_id
            AND         AD.ORIGINATION_TYPE <> 52
            AND         AD.ALLOCATED_QUANTITY <> 0
            --bug3700564 added trunc
            AND         TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
            AND         AD.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
            AND         AD.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
            -- bug3579625 Addition join with MSC_SYSTEM_ITEMS (I)
            AND         AD.PLAN_ID = I.PLAN_ID
            AND         AD.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         AD.ORIGINAL_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         AD.ORGANIZATION_ID = I.ORGANIZATION_ID

            UNION ALL
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_family_id col4 ,
                        p_sr_member_id col5,
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
                        p_uom_code col16,
                        2 col17,
                        CSA.ORDER_TYPE col18,
                        l_null_char col19,
                        CSA.SR_INSTANCE_ID col20,
                        l_null_num col21,
                        CSA.PARENT_TRANSACTION_ID col22,
                        l_null_num col23,
                        CSA.ALLOCATED_QUANTITY*
                              DECODE(DECODE(MSC_AATP_PVT.G_HIERARCHY_PROFILE,
                                     1, DECODE(CSA.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         Decode(sign(trunc(CSA.Supply_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', CSA.Original_Item_Id,
                                                                        p_family_id)),
                                                         p_org_id,
                                                         p_instance_id,
                                                         TRUNC(CSA.SUPPLY_DATE),
                                                         p_level_id,
                                                         CSA.DEMAND_CLASS),
                                           CSA.DEMAND_CLASS)),
                                     2, DECODE(CSA.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         CSA.CUSTOMER_ID,
                                                         CSA.SHIP_TO_SITE_ID,
                                                         Decode(sign(trunc(CSA.Supply_Date) - p_atf_date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', CSA.Original_Item_Id,
                                                                        p_family_id)),
                                                         p_org_id,
                                                         p_instance_id,
                                                         TRUNC(CSA.SUPPLY_DATE),
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL,  nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           Decode(sign(trunc(CSA.Supply_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', CSA.Original_Item_Id,
                                                        p_family_id)),
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           TRUNC(CSA.SUPPLY_DATE)),
                                       1),*/
                                 DECODE(
                                 MIHM.allocation_percent/100, --4365873
                                 /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           Decode(sign(trunc(CSA.Supply_Date) - p_atf_date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', CSA.Original_Item_Id,
                                                        p_family_id)),
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           TRUNC(CSA.SUPPLY_DATE)),*/
                                   NULL, 1,
                                 0)) col24,
                        --TRUNC(SA.SUPPLY_DATE) col25,
                        GREATEST(TRUNC(CSA.SUPPLY_DATE),p_sys_next_date) col25, --3099066
                        l_null_num col26,
                        CSA.ORDER_NUMBER col27,
                        l_null_num col28,
                        l_null_num col29,
        		l_null_num,
        		NVL(CSA.Supply_Quantity, CSA.ALLOCATED_QUANTITY),
        		l_null_num,
        		to_date(null),
        		CSA.Original_Item_Id,
        		CSA.Original_Order_Type,
                        l_sysdate,
                        G_USER_ID,
                        l_sysdate,
                        G_USER_ID,
                        G_USER_ID,
                        CSA.ALLOCATED_QUANTITY, -- bug 3282426
                        --null,
                        --null,
                        --null,
                        --null,
                        l_null_char, --bug3814584
                        l_null_char, --bug3814584
                        l_null_char, --bug3814584
                        l_null_date,  --bug3814584
                        CSA.Item_Name -- bug3579625
            FROM
                (
                select
                	SA.SUPPLY_DATE,
			SA.DEMAND_CLASS,
			SA.Original_Item_Id,
			SA.CUSTOMER_ID,
			SA.SHIP_TO_SITE_ID,
			SA.ORGANIZATION_ID,
			SA.SR_INSTANCE_ID,
			SA.INVENTORY_ITEM_ID,
			SA.ORIGINAL_ORDER_TYPE,
			SA.ORDER_NUMBER,
			I.Item_Name,
			SA.Supply_Quantity,
			SA.ALLOCATED_QUANTITY,
			SA.PARENT_TRANSACTION_ID,
			SA.ORDER_TYPE
            FROM        MSC_ALLOC_SUPPLIES SA,
                        MSC_SYSTEM_ITEMS I
            WHERE       SA.PLAN_ID = p_plan_id
            AND         SA.SR_INSTANCE_ID = p_instance_id
            AND         SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
            AND         SA.ORGANIZATION_ID = p_org_id
            AND         SA.ALLOCATED_QUANTITY <> 0
            AND         TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
            --bug3700564 added trunc
            AND         TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
            -- bug3579625 Addition join with MSC_SYSTEM_ITEMS (I)
            AND         SA.PLAN_ID = I.PLAN_ID
            AND         SA.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         SA.ORIGINAL_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         SA.ORGANIZATION_ID = I.ORGANIZATION_ID) CSA,
                   MSC_ITEM_HIERARCHY_MV MIHM
	WHERE
		--4365873
		--5220274 if the rule is assigned to family only then use family id.
               Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                           'N', p_family_id,
                  CSA.INVENTORY_ITEM_ID) = MIHM.INVENTORY_ITEM_ID(+)
        AND    CSA.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
        AND    CSA.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
        AND    decode(MIHM.level_id (+),-1,1,2) = decode(MSC_AATP_PVT.G_HIERARCHY_PROFILE,1,1,2)
        AND    TRUNC(CSA.SUPPLY_DATE) >= MIHM.effective_date (+)
        AND    TRUNC(CSA.SUPPLY_DATE) <= MIHM.disable_date (+)
        AND    MIHM.demand_class (+) = p_demand_class
           )
           ;
EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Avail_Pf_Dtls: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Item_Alloc_Avail_Pf_Dtls;

/*--Item_Prealloc_Avail_Pf--------------------------------------------------------
|  o  Called from Item_Pre_Allocated_Atp procedure for Demand Priority based
|       Allocated Time Phased PF ATP.
+-------------------------------------------------------------------------------*/
PROCEDURE Item_Prealloc_Avail_Pf (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Item_Prealloc_Avail_Pf **********');
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf p_demand_class: ' || p_demand_class);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT 	SD_DATE,
                SUM(SD_QTY)
        BULK COLLECT INTO
                x_atp_dates,
                x_atp_qtys
        FROM (
                SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                        -1 * AD.ALLOCATED_QUANTITY SD_QTY
                FROM    MSC_ALLOC_DEMANDS AD
                WHERE   AD.PLAN_ID = p_plan_id
                AND     AD.SR_INSTANCE_ID = p_instance_id
                AND     AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     AD.ORIGINATION_TYPE <> 52 -- ATP Bucketed Demand
                AND     AD.ORGANIZATION_ID = p_org_id
                AND     AD.DEMAND_CLASS = NVL(p_demand_class, AD.DEMAND_CLASS)
                AND     AD.ALLOCATED_QUANTITY  <> 0 --4501434
                AND     TRUNC(AD.DEMAND_DATE) < p_itf
                UNION ALL
                SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                        SA.ALLOCATED_QUANTITY SD_QTY
                FROM    MSC_ALLOC_SUPPLIES SA
                WHERE   SA.PLAN_ID = p_plan_id
                AND     SA.SR_INSTANCE_ID = p_instance_id
                AND     SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                AND     SA.ORGANIZATION_ID = p_org_id
                AND     SA.ALLOCATED_QUANTITY <> 0
                AND     SA.DEMAND_CLASS = NVL(p_demand_class, SA.DEMAND_CLASS)
                AND     TRUNC(SA.SUPPLY_DATE) < p_itf
        )
        GROUP BY SD_DATE
        order by SD_DATE; --4698199

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Item_Prealloc_Avail_Pf;

/*--Item_Prealloc_Avail_Pf_Summ---------------------------------------------------
|  o  Called from Item_Pre_Allocated_Atp procedure for Demand Priority based
|       Allocated Time Phased PF ATP.
+-------------------------------------------------------------------------------*/
PROCEDURE Item_Prealloc_Avail_Pf_Summ (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_itf                           IN      DATE,
        p_refresh_number                IN      NUMBER,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Item_Prealloc_Avail_Pf_Summ **********');
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Summ: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Summ: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Summ: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Summ: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Summ p_demand_class: ' || p_demand_class);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- SQL changed for summary enhancement
        SELECT  SD_DATE,
                SUM(SD_QTY)
        BULK COLLECT INTO
                x_atp_dates,
                x_atp_qtys
        FROM
            (
                SELECT  /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                        SD_DATE, SD_QTY
                FROM    MSC_ATP_SUMMARY_SD S
                WHERE   S.PLAN_ID = p_plan_id
                AND     S.SR_INSTANCE_ID = p_instance_id
                AND     S.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     S.ORGANIZATION_ID = p_org_id
                AND     S.DEMAND_CLASS = NVL(p_demand_class, S.DEMAND_CLASS)
                AND     S.SD_DATE < p_itf

                UNION ALL

                SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                        decode(AD.ALLOCATED_QUANTITY,           -- Consider unscheduled orders as dummy supplies
                               0, OLD_ALLOCATED_QUANTITY,-- For summary enhancement
                                  -1 * AD.ALLOCATED_QUANTITY) SD_QTY
                FROM    MSC_ALLOC_DEMANDS AD,
                        MSC_PLANS P                             -- For summary enhancement
                WHERE   AD.PLAN_ID = p_plan_id
                AND     AD.SR_INSTANCE_ID = p_instance_id
                AND     AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     AD.ORGANIZATION_ID = p_org_id
                AND     AD.DEMAND_CLASS = NVL(p_demand_class, AD.DEMAND_CLASS)
                AND     TRUNC(AD.DEMAND_DATE) < p_itf
                AND     P.PLAN_ID = AD.PLAN_ID
                AND     (AD.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                        OR AD.REFRESH_NUMBER = p_refresh_number)
                -- since repetitive schedule demand is not supported in this case
                -- join to msc_calendar_dates is not needed.

                UNION ALL

                SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                        decode(SA.ALLOCATED_QUANTITY,           -- Consider deleted stealing records as dummy demands
                               0, -1 * OLD_ALLOCATED_QUANTITY,   -- For summary enhancement
                                  SA.ALLOCATED_QUANTITY) SD_QTY
                FROM    MSC_ALLOC_SUPPLIES SA,
                        MSC_PLANS P                                     -- For summary enhancement
                WHERE   SA.PLAN_ID = p_plan_id
                AND	    SA.SR_INSTANCE_ID = p_instance_id
                AND	    SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     SA.ORGANIZATION_ID = p_org_id
                AND     SA.DEMAND_CLASS = NVL(p_demand_class, SA.DEMAND_CLASS)
                AND     TRUNC(SA.SUPPLY_DATE) < p_itf
                AND     P.PLAN_ID = SA.PLAN_ID
                AND     TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                AND     (SA.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                        OR SA.REFRESH_NUMBER = p_refresh_number)
            )
        GROUP BY SD_DATE
        order by SD_DATE; --4698199

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Summ: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Item_Prealloc_Avail_Pf_Summ;

/*--Item_Prealloc_Avail_Pf_Dtls---------------------------------------------------
|  o  Called from Item_Pre_Allocated_Atp procedure for Demand Priority based
|       Allocated Time Phased PF ATP.
+-------------------------------------------------------------------------------*/
PROCEDURE Item_Prealloc_Avail_Pf_Dtls (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_itf                           IN      DATE,
        p_atf_date                      IN      DATE,
        p_level                         IN      NUMBER,
        p_identifier                    IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_uom_code                      IN      VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_sysdate               DATE := sysdate;
        l_null_num              NUMBER;
        l_null_char             VARCHAR2(1);
        l_null_date             DATE; --bug3814584
        l_return_status         VARCHAR2(1);
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Item_Prealloc_Avail_Pf_Dtls **********');
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls p_demand_class: ' || p_demand_class);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

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
		Allocated_Quantity,
		Supply_Demand_Date,
		Disposition_Type,
		Disposition_Name,
		Pegging_Id,
		End_Pegging_Id,
        	Pf_Display_Flag,
                Supply_Demand_Quantity,
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
                ORIG_REQUEST_DATE, --bug3263368
                Inventory_Item_Name --bug3579625
	)
        (
           SELECT   p_level col1,
		    p_identifier col2,
                    p_scenario_id col3,
                    p_sr_family_id col4 ,
                    p_sr_member_id col5,
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
		    p_uom_code col16,
		    1 col17, -- demand
		    AD.ORIGINATION_TYPE col18,
                    l_null_char col19,
		    AD.SR_INSTANCE_ID col20,
                    l_null_num col21,
		    AD.PARENT_DEMAND_ID col22,
		    l_null_num col23,
                    -1 * AD.ALLOCATED_QUANTITY col24,
		    TRUNC(AD.DEMAND_DATE) col25,
                    l_null_num col26,
                    AD.ORDER_NUMBER col27,
                    l_null_num col28,
                    l_null_num col29,
                    Decode(AD.inventory_item_id, p_family_id,
                        Decode(AD.original_item_id, p_member_id,
                                AD.Pf_Display_Flag,
                                Decode(sign(trunc(AD.Original_Demand_Date) - p_atf_date),
                                        1, AD.Pf_Display_Flag,
                                        1)),
                        AD.Pf_Display_Flag),
                    -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY),
                    -1* NVL(AD.Demand_Quantity, AD.ALLOCATED_QUANTITY),
		    TRUNC(AD.Original_Demand_Date),
                    AD.Original_Item_Id,
                    AD.Original_Origination_Type,
                    l_sysdate,
		    G_USER_ID,
		    l_sysdate,
		    G_USER_ID,
		    G_USER_ID,
		    MTPS.LOCATION,   --bug3263368
                    MTP.PARTNER_NAME, --bug3263368
                    AD.DEMAND_CLASS, --bug3263368
                    AD.REQUEST_DATE, --bug3263368
                    I.Item_Name  --bug3579625
           FROM     MSC_ALLOC_DEMANDS AD,
                    MSC_TRADING_PARTNERS    MTP,--bug3263368
                    MSC_TRADING_PARTNER_SITES    MTPS, --bug3263368
                    MSC_SYSTEM_ITEMS I  --bug3579625
           WHERE    AD.PLAN_ID = p_plan_id
           AND      AD.SR_INSTANCE_ID = p_instance_id
           AND      AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
           AND      AD.ORIGINATION_TYPE <> 52
           AND      AD.ORGANIZATION_ID = p_org_id
           AND      AD.ALLOCATED_QUANTITY  <> 0 --4501434
           AND      AD.DEMAND_CLASS = NVL(p_demand_class, AD.DEMAND_CLASS)
           AND      TRUNC(AD.DEMAND_DATE) < p_itf
           AND      AD.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
           AND      AD.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
           -- bug3579625 Addition join with MSC_SYSTEM_ITEMS (I)
           AND       AD.PLAN_ID = I.PLAN_ID
           AND       AD.SR_INSTANCE_ID = I.SR_INSTANCE_ID
           AND       AD.ORIGINAL_ITEM_ID = I.INVENTORY_ITEM_ID
           AND       AD.ORGANIZATION_ID = I.ORGANIZATION_ID

      UNION ALL
           SELECT   p_level col1,
                    p_identifier col2,
                    p_scenario_id col3,
                    p_sr_family_id col4 ,
                    p_sr_member_id col5,
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
                    p_uom_code col16,
                    2 col17, -- supply
                    SA.ORDER_TYPE col18,
                    l_null_char col19,
                    SA.SR_INSTANCE_ID col20,
                    l_null_num col21,
                    SA.PARENT_TRANSACTION_ID col22,
                    l_null_num col23,
                    SA.ALLOCATED_QUANTITY col24,
                    TRUNC(SA.SUPPLY_DATE) col25,
                    l_null_num col26,
                    DECODE(SA.ORDER_TYPE, 5, to_char(SA.PARENT_TRANSACTION_ID), SA.ORDER_NUMBER) col27,
                    l_null_num col28,
		    l_null_num col29,
		    l_null_num,
        	    NVL(SA.Supply_Quantity, SA.ALLOCATED_QUANTITY),
        	    l_null_num,
        	    to_date(null),
        	    SA.Original_Item_Id,
                    DECODE(SA.ORIGINAL_ORDER_TYPE,
                                46, 48,                 -- Change Supply due to Stealing to Supply Adjustment
                                47, 48,                 -- Change Demand due to Stealing to Supply Adjustment
                        SA.ORIGINAL_ORDER_TYPE),
        	    l_sysdate,
		    G_USER_ID,
		    l_sysdate,
		    G_USER_ID,
		    G_USER_ID,
		    MTPS.LOCATION,   --bug3684383
                    MTP.PARTNER_NAME, --bug3684383
                    SA.DEMAND_CLASS, --bug3684383
                    --null,         --bug3684383
                    l_null_date,  --bug3814584
                    I.Item_Name --bug3579625

           FROM     MSC_ALLOC_SUPPLIES SA,
                    MSC_SYSTEM_ITEMS I,  --bug3579625
                    MSC_TRADING_PARTNERS    MTP,--bug3684383
                    MSC_TRADING_PARTNER_SITES    MTPS --bug3684383

           WHERE    SA.PLAN_ID = p_plan_id
           AND      SA.SR_INSTANCE_ID = p_instance_id
           AND      SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
           AND      TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
           AND      SA.ORGANIZATION_ID = p_org_id
           AND      SA.ALLOCATED_QUANTITY <> 0
           AND      SA.DEMAND_CLASS = NVL(p_demand_class, SA.DEMAND_CLASS )
           AND      TRUNC(SA.SUPPLY_DATE) < p_itf
           -- bug3579625 Addition join with MSC_SYSTEM_ITEMS (I)
           AND         SA.PLAN_ID = I.PLAN_ID
           AND         SA.SR_INSTANCE_ID = I.SR_INSTANCE_ID
           AND         SA.ORIGINAL_ITEM_ID = I.INVENTORY_ITEM_ID
           AND         SA.ORGANIZATION_ID = I.ORGANIZATION_ID
           AND      SA.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3684383
           AND      SA.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3684383
          );

          /* Now populate Original_Demand_Qty*/
          Populate_Original_Demand_Qty(
        	MASDDT,
        	NULL,
        	p_plan_id,
        	p_demand_class,
                l_return_status
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls: ' || 'Error occured in procedure Populate_Original_Demand_Qty');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
          END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Prealloc_Avail_Pf_Dtls: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Item_Prealloc_Avail_Pf_Dtls;

/*--Get_Forward_Mat_Pf------------------------------------------------------------
|  o  Called from Item_Pre_Allocated_Atp procedure for Demand Priority based
|       Allocated Time Phased PF ATP.
+-------------------------------------------------------------------------------*/
PROCEDURE Get_Forward_Mat_Pf (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_atp_dcs                       OUT     NOCOPY MRP_ATP_PUB.char80_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Get_Forward_Mat_Pf **********');
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf: p_plan_id: ' || p_plan_id);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT 	SD_DATE,
                SUM(SD_QTY),
                DEMAND_CLASS
        BULK COLLECT INTO
                x_atp_dates,
                x_atp_qtys,
                x_atp_dcs
        FROM
            (
                SELECT  TRUNC(AD.DEMAND_DATE) SD_DATE,
                        -1 * AD.ALLOCATED_QUANTITY SD_QTY,
                        AD.DEMAND_CLASS
                FROM    MSC_ALLOC_DEMANDS AD
                WHERE   AD.PLAN_ID = p_plan_id
                AND     AD.SR_INSTANCE_ID = p_instance_id
                AND     AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     AD.ORGANIZATION_ID = p_org_id
                AND     AD.ALLOCATED_QUANTITY  <> 0 --4501434
                AND     AD.ORIGINATION_TYPE <> 52   -- Ignore copy SO and copy stealing records for summary enhancement
                AND     AD.DEMAND_CLASS IN (
                        SELECT  demand_class
                        FROM    msc_alloc_temp
                        WHERE   demand_class IS NOT NULL)
                --bug3700564 added trunc
                AND     TRUNC(AD.DEMAND_DATE) < p_itf

                UNION ALL

                SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                        SA.ALLOCATED_QUANTITY SD_QTY,
                        SA.DEMAND_CLASS
                FROM    MSC_ALLOC_SUPPLIES SA
                WHERE   SA.PLAN_ID = p_plan_id
                AND     SA.SR_INSTANCE_ID = p_instance_id
                AND     SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     SA.ORGANIZATION_ID = p_org_id
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
                --bug3700564 added trunc
                AND     TRUNC(SA.SUPPLY_DATE) < p_itf
            )
        GROUP BY DEMAND_CLASS, SD_DATE
        order by DEMAND_CLASS, SD_DATE; --4698199 --5353882

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Forward_Mat_Pf: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Forward_Mat_Pf;

/*--Get_Forward_Mat_Pf_Summ---------------------------------------------------
|  o  Called from Item_Pre_Allocated_Atp procedure for Demand Priority based
|       Allocated Time Phased PF ATP.
+-------------------------------------------------------------------------------*/
PROCEDURE Get_Forward_Mat_Pf_Summ (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        p_refresh_number                IN      NUMBER,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_atp_dcs                       OUT     NOCOPY MRP_ATP_PUB.char80_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Get_Forward_Mat_Pf_Summ **********');
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf_Summ: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf_Summ: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf_Summ: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Get_Forward_Mat_Pf_Summ: p_plan_id: ' || p_plan_id);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Summary SQL can be used
        SELECT 	SD_DATE,
                SUM(SD_QTY),
                DEMAND_CLASS
        BULK COLLECT INTO
                x_atp_dates,
                x_atp_qtys,
                x_atp_dcs
        FROM
            (
                SELECT  /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                        SD_DATE, SD_QTY, DEMAND_CLASS
                FROM    MSC_ATP_SUMMARY_SD S
                WHERE   S.PLAN_ID = p_plan_id
                AND     S.SR_INSTANCE_ID = p_instance_id
                AND     S.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     S.ORGANIZATION_ID = p_org_id
                AND     S.DEMAND_CLASS IN (
                        SELECT  demand_class
                        FROM    msc_alloc_temp
                        WHERE   demand_class IS NOT NULL)
                AND     S.SD_DATE < p_itf

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
                AND     AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     AD.ORGANIZATION_ID = p_org_id
                AND     AD.DEMAND_CLASS IN (
                        SELECT  demand_class
                        FROM    msc_alloc_temp
                        WHERE   demand_class IS NOT NULL)
                --bug3700564 added trunc
                AND     TRUNC(AD.DEMAND_DATE) < p_itf
                        AND     P.PLAN_ID = AD.PLAN_ID
                        AND     (AD.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                                OR AD.REFRESH_NUMBER = p_refresh_number)

                UNION ALL

                SELECT  TRUNC(SA.SUPPLY_DATE) SD_DATE,
                        decode(SA.ALLOCATED_QUANTITY,           -- Consider deleted stealing records as dummy demands
                               0, -1 * OLD_ALLOCATED_QUANTITY,   -- For summary enhancement
                                  SA.ALLOCATED_QUANTITY) SD_QTY ,
                        SA.DEMAND_CLASS
                FROM    MSC_ALLOC_SUPPLIES SA,
                        MSC_PLANS P                                     -- For summary enhancement
                WHERE   SA.PLAN_ID = p_plan_id
                AND     SA.SR_INSTANCE_ID = p_instance_id
                AND     SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND     SA.ORGANIZATION_ID = p_org_id
                AND     SA.DEMAND_CLASS IN (
                        SELECT  demand_class
                        FROM    msc_alloc_temp
                        WHERE   demand_class IS NOT NULL)
                --bug3700564 added trunc
                AND     TRUNC(SA.SUPPLY_DATE) < p_itf
                AND     P.PLAN_ID = SA.PLAN_ID
                AND     (SA.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                        OR SA.REFRESH_NUMBER = p_refresh_number)
            )
        GROUP BY DEMAND_CLASS, SD_DATE
        order by DEMAND_CLASS, SD_DATE; --4698199;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Forward_Mat_Pf_Summ: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Forward_Mat_Pf_Summ;

/*--Insert_SD_Into_Details_Temp-----------------------------------------------
|  o  Called from Item_Alloc_Cum_Atp procedure for Rule based Allocated Time
|  o  This is similar to previous procedure only difference being that we
+---------------------------------------------------------------------------*/
PROCEDURE Insert_SD_Into_Details_Temp(
        p_type                          IN      INTEGER,
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_sr_member_id                  IN      NUMBER,
        p_sr_family_id                  IN      NUMBER,
        p_org_id                        IN      NUMBER,
        --bug3671294 now we donot need this as we will join with msc_system_items
        --p_inv_item_name                 IN      VARCHAR2,
        p_org_code                      IN      VARCHAR2,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_itf                           IN      DATE,
        p_level_id                      IN      PLS_INTEGER,
        p_session_id                    IN      NUMBER,
        p_record_type                   IN      PLS_INTEGER,
        p_scenario_id                   IN      NUMBER,
        p_uom_code                      IN      VARCHAR2,
        x_insert_count                  OUT     NOCOPY NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        l_null_num                      NUMBER;
        l_null_date                     DATE;   -- Bug 3875786
        l_null_char                     VARCHAR(1); -- Bug 3875786
        l_return_status                 VARCHAR2(1);
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('******* Begin Insert_SD_Into_Details_Temp **********');
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_type: ' || p_type);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_member_id: ' || p_member_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_family_id: ' || p_family_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_sr_member_id: ' || p_sr_member_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_sr_family_id: ' || p_sr_family_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_org_id: ' || p_org_id);
                --bug3671294
                --msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_inv_item_name: ' || p_inv_item_name);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_org_code: ' || p_org_code);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_instance_id: ' || p_instance_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_plan_id: ' || p_plan_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_itf: ' || p_itf);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_level_id: ' || p_level_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_session_id: ' || p_session_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_record_type: ' || p_record_type);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_scenario_id: ' || p_scenario_id);
                msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: p_uom_code: ' || p_uom_code);
        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_type = Demand_Priority THEN
                INSERT INTO MRP_ATP_DETAILS_TEMP
                (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                allocated_quantity, record_type, scenario_id, disposition_name, demand_class, char1,
                uom_code, plan_id, inventory_item_name, organization_code,
                pf_display_flag, original_demand_quantity, original_demand_date,
                original_item_id, original_supply_demand_type, request_item_id,
                ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE )--bug3263368
                SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                col11, col12, col13, col14, col15, col16, col17, col18, col19, col20,
                col21, col22, col23, col24, col25, col26,col27,col28,col29,col30
                FROM
                (SELECT p_session_id                    col1, -- session_id
                        p_level_id                      col2, -- level_id
                        p_sr_family_id                  col3, -- inventory_item_id
                        p_org_id                        col4, -- organization_id
                        p_instance_id                   col5, -- Identifier1
                        AD.PARENT_DEMAND_ID             col6, -- Identifier3
                        1                               col7, -- supply_demand_type
                        TRUNC(AD.DEMAND_DATE)           col8, -- supply_demand_date
                        -1 * NVL(AD.DEMAND_QUANTITY,
                        AD.ALLOCATED_QUANTITY)          col9, -- supply_demand_quantity
                        AD.ORIGINATION_TYPE             col10, -- supply_demand_source_type
                        -1 * AD.ALLOCATED_QUANTITY      col11, -- allocated_quantity
                        p_record_type                   col12, -- record_type
                        p_scenario_id                   col13, -- scenario_id
                        AD.ORDER_NUMBER                 col14, -- disposition_name
                        AD.DEMAND_CLASS                 col15, -- demand_class
                        l_null_char                     col16, -- from_demand_class  --Bug 3875786
                        p_uom_code                      col17, -- UOM Code
                        p_plan_id                       col18, -- Plan id
                        --bug3671294
                        msi.item_name                   col19, -- Item name
                        --p_inv_item_name                 col19, -- Item name
                        p_org_code                      col20,  -- Organization code
                	Decode(AD.inventory_item_id, p_family_id,
                	        Decode(AD.original_item_id, p_member_id,
                	                AD.Pf_Display_Flag,
                	                Decode(sign(trunc(AD.Original_Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                	                        1, AD.Pf_Display_Flag,
                	                        1)),
                	        AD.Pf_Display_Flag)     col21,
                        -1 * NVL(AD.DEMAND_QUANTITY,
                                 AD.ALLOCATED_QUANTITY) col22,
                        trunc(AD.original_demand_date)  col23, --Bug_3693892 added trunc
                        AD.original_item_id             col24,
                        AD.original_origination_type    col25,
                        p_sr_member_id                  col26,
                        MTPS.LOCATION                   col27, --bug3263368
                        MTP.PARTNER_NAME                col28, --bug3263368
                        AD.DEMAND_CLASS                 col29, --bug3263368
                        AD.REQUEST_DATE                 col30  --bug3263368
                FROM
                        MSC_ALLOC_DEMANDS AD,
                        MSC_ALLOC_TEMP TEMP,
                        MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS, --bug3263368
                        MSC_SYSTEM_ITEMS    msi --bug3671294
                WHERE
                        AD.PLAN_ID = p_plan_id
                        AND      AD.SR_INSTANCE_ID = p_instance_id
                        AND      AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                        AND      AD.ORGANIZATION_ID = p_org_id
                        AND      AD.ALLOCATED_QUANTITY <> 0
                        AND      AD.DEMAND_CLASS = TEMP.DEMAND_CLASS
                        --bug3671294 start
                        AND      msi.PLAN_ID = AD.PLAN_ID
                        AND      msi.SR_INSTANCE_ID = AD.SR_INSTANCE_ID
                        AND      msi.ORGANIZATION_ID = AD.ORGANIZATION_ID
                        AND      msi.INVENTORY_ITEM_ID = AD.ORIGINAL_ITEM_ID
                        --bug3671294 end
                        --bug3700564 added trunc
                        AND      TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
                        AND      AD.ORIGINATION_TYPE <> 52  -- Ignore copy SO and copy stealing records for allocation WB - summary enhancement
                        AND      AD.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
                        AND      AD.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
                UNION ALL
                SELECT  p_session_id                    col1,
                        p_level_id                      col2,
                        p_sr_family_id                  col3 ,
                        p_org_id                        col4,
                        p_instance_id                   col5,
                        SA.PARENT_TRANSACTION_ID        col6,
                        2                               col7, -- supply
                        TRUNC(SA.SUPPLY_DATE)           col8,
                        NVL(SA.SUPPLY_QUANTITY,
                        SA.ALLOCATED_QUANTITY)          col9,
                        SA.ORDER_TYPE                   col10,
                        SA.ALLOCATED_QUANTITY           col11,
                        p_record_type                   col12, -- record_type
                        p_scenario_id                   col13, -- scenario_id
                        DECODE(SA.ORIGINAL_ORDER_TYPE, -- SA.ORDER_TYPE, /*bug 3229032*/
                                5, to_char(SA.PARENT_TRANSACTION_ID),
                                SA.ORDER_NUMBER)        col14,
                        SA.DEMAND_CLASS                 col15,
                        SA.FROM_DEMAND_CLASS            col16,
                        p_uom_code                      col17,
                        p_plan_id                       col18,
                        --bug3671294
                        msi.item_name                   col19, -- Item name
                        --p_inv_item_name                 col19, -- Item name
                        p_org_code                      col20,  -- Organization code
                        l_null_num                      col21, -- Bug 3875786 - local variable used for NULL
                        l_null_num                      col22, -- Bug 3875786 - local variable used for NULL
                        l_null_date                     col23, -- Bug 3875786 - local variable used for NULL
                        SA.original_item_id             col24,
                        /*bug 3229032*/
                        DECODE(SA.ORIGINAL_ORDER_TYPE,
                                46, 48,                 -- Change Supply due to Stealing to Supply Adjustment
                                47, 48,                 -- Change Demand due to Stealing to Supply Adjustment
                                SA.ORIGINAL_ORDER_TYPE
                               )                        col25,
                        p_sr_member_id                  col26,
                        MTPS.LOCATION                  col27, --bug3684383
                        MTP.PARTNER_NAME               col28, --bug3684383
                        SA.DEMAND_CLASS                col29, --bug3684383
                        l_null_date                     col30  --bug3684383 -- Bug 3875786 - local variable used for NULL
                FROM
                        MSC_ALLOC_SUPPLIES SA,
                        MSC_ALLOC_TEMP TEMP,
                        MSC_SYSTEM_ITEMS    msi, --bug3671294
                        MSC_TRADING_PARTNER_SITES    MTPS, --bug3684383
                        MSC_TRADING_PARTNERS    MTP --bug3684383
                WHERE
                        SA.PLAN_ID = p_plan_id
                        AND      SA.SR_INSTANCE_ID = p_instance_id
                        AND      SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                        AND      SA.ORGANIZATION_ID = p_org_id
                        AND      SA.ALLOCATED_QUANTITY <> 0
                        --bug3671294 start
                        AND      msi.PLAN_ID = SA.PLAN_ID
                        AND      msi.SR_INSTANCE_ID = SA.SR_INSTANCE_ID
                        AND      msi.ORGANIZATION_ID = SA.ORGANIZATION_ID
                        AND      msi.INVENTORY_ITEM_ID = SA.ORIGINAL_ITEM_ID
                        --bug3671294 end
                        AND      TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                        AND      SA.DEMAND_CLASS = TEMP.DEMAND_CLASS
                        AND      TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
                        AND      SA.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3684383
                        AND      SA.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3684383
                );

        ELSIF p_type = User_Defined_DC THEN
                INSERT INTO MRP_ATP_DETAILS_TEMP
                (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                allocated_quantity, record_type, scenario_id, disposition_name, demand_class, uom_code,
                inventory_item_name, organization_code, identifier2, identifier4, request_item_id,
                pf_display_flag, original_demand_quantity, original_demand_date, original_item_id,
                original_supply_demand_type, unallocated_quantity,
                ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE )--bug3263368
                SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                col11, col12, col13, col14, col15, col16, col17, col18, col19, col20,
                col21, col22, col23, col24, col25, col26, col27,col28,col29,col30,col31
                FROM
                (SELECT p_session_id                    col1, -- session_id
                        p_level_id                      col2, -- level_id
                        p_sr_family_id                  col3, -- inventory_item_id
                        p_org_id                        col4, -- organization_id
                        p_instance_id                   col5, -- Identifier1
                        AD.PARENT_DEMAND_ID             col6, -- Identifier3
                        1                               col7, -- supply_demand_type
                        TRUNC(AD.DEMAND_DATE)           col8, -- supply_demand_date
                        -1 * NVL(AD.DEMAND_QUANTITY,
                                 AD.ALLOCATED_QUANTITY) col9, -- supply_demand_quantity
                        AD.ORIGINAL_ORIGINATION_TYPE    col10,-- supply_demand_source_type
                        -1 * AD.ALLOCATED_QUANTITY*
                          DECODE(decode(AD.ORIGINAL_ORIGINATION_TYPE,
                                6, decode(AD.source_organization_id,
                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)), NULL),
                                30, decode(AD.source_organization_id,
                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)), NULL),
                                DECODE(AD.DEMAND_CLASS, null, null,
                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                        null, null,
                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)),
                                                        p_org_id,
                                                        p_instance_id, trunc(AD.DEMAND_DATE),
                                                        p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS))),
                                TEMP.DEMAND_CLASS, 1,
                                MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                        AD.PARENT_DEMAND_ID,
                                        trunc(AD.DEMAND_DATE),
                                        AD.USING_ASSEMBLY_ITEM_ID,
                                        DECODE(AD.SOURCE_ORGANIZATION_ID,
                                        -23453, null,
                                        AD.SOURCE_ORGANIZATION_ID),
                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', AD.Original_Item_Id,
                                                        p_family_id)),
                                        p_org_id,
                                        p_instance_id,
                                        AD.ORIGINAL_ORIGINATION_TYPE,
                                        decode(AD.ORIGINAL_ORIGINATION_TYPE,
                                                6, decode(AD.source_organization_id,
                                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                30, decode(AD.source_organization_id,
                                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                DECODE(AD.DEMAND_CLASS, null, null,
                                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        null, null,
                                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                1, p_family_id,
                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                        'Y', AD.Original_Item_Id,
                                                                                        p_family_id)),
                                                                        p_org_id,
                                                                        p_instance_id, trunc(AD.DEMAND_DATE),
                                                                        p_level_id, AD.DEMAND_CLASS),
                                                                        AD.DEMAND_CLASS))),
                                        TEMP.DEMAND_CLASS,
                                        p_level_id))   col11, -- allocated_quantity
                        p_record_type                   col12, -- record_type
                        p_scenario_id                   col13, -- scenario_id
                        AD.ORDER_NUMBER                 col14, -- disposition_name
                        TEMP.DEMAND_CLASS               col15, -- demand_class
                        p_uom_code                      col16, -- UOM Code
                        --bug3671294
                        msi.item_name                   col17, -- Item name
                        --p_inv_item_name                 col17, -- Item name
                        p_org_code                      col18, -- Organization code
                        TEMP.PRIORITY                   col19, -- sysdate priroty
                        TEMP.ALLOCATION_PERCENT         col20, -- sysdate allocation percent
                        -- time_phased_atp
                        p_sr_member_id                  col21, -- request_item_id
                	Decode(AD.inventory_item_id, p_family_id,
                	        Decode(AD.original_item_id, p_member_id,
                	                AD.Pf_Display_Flag,
                	                Decode(sign(trunc(AD.Original_Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                	                        1, AD.Pf_Display_Flag,
                	                        1)),
                	        AD.Pf_Display_Flag)     col22,
                        -1 * NVL(AD.DEMAND_QUANTITY,
                                 AD.ALLOCATED_QUANTITY)*
                        DECODE(decode(AD.ORIGINAL_ORIGINATION_TYPE,
                                6, decode(AD.source_organization_id,
                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)), NULL),
                                30, decode(AD.source_organization_id,
                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)),
                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                null, null,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id,
                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                p_level_id, AD.DEMAND_CLASS),
                                                        AD.DEMAND_CLASS)), NULL),
                                DECODE(AD.DEMAND_CLASS, null, null,
                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                        null, null,
                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)),
                                                        p_org_id,
                                                        p_instance_id, trunc(AD.DEMAND_DATE),
                                                        p_level_id, AD.DEMAND_CLASS),
                                                AD.DEMAND_CLASS))),
                                TEMP.DEMAND_CLASS, 1,
                                MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                        AD.PARENT_DEMAND_ID,
                                        trunc(AD.DEMAND_DATE),
                                        AD.USING_ASSEMBLY_ITEM_ID,
                                        DECODE(AD.SOURCE_ORGANIZATION_ID,
                                        -23453, null,
                                        AD.SOURCE_ORGANIZATION_ID),
                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', AD.Original_Item_Id,
                                                        p_family_id)),
                                        p_org_id,
                                        p_instance_id,
                                        AD.ORIGINAL_ORIGINATION_TYPE,
                                        decode(AD.ORIGINAL_ORIGINATION_TYPE,
                                                6, decode(AD.source_organization_id,
                                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                30, decode(AD.source_organization_id,
                                                        NULL, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        -23453, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)),
                                                        AD.organization_id, DECODE(AD.DEMAND_CLASS, null, null,
                                                                DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                null, null,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id,
                                                                                p_instance_id, trunc(AD.DEMAND_DATE),
                                                                                p_level_id, AD.DEMAND_CLASS),
                                                                                AD.DEMAND_CLASS)), TEMP.DEMAND_CLASS),
                                                DECODE(AD.DEMAND_CLASS, null, null,
                                                        DECODE(TEMP.DEMAND_CLASS, '-1',
                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        null, null,
                                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                1, p_family_id,
                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                        'Y', AD.Original_Item_Id,
                                                                                        p_family_id)),
                                                                        p_org_id,
                                                                        p_instance_id, trunc(AD.DEMAND_DATE),
                                                                        p_level_id, AD.DEMAND_CLASS),
                                                                        AD.DEMAND_CLASS))),
                                        TEMP.DEMAND_CLASS,
                                        p_level_id))    col23, -- original demand quantity
                        trunc(AD.original_demand_date)  col24, --Bug_3693892 added trunc
                        AD.original_item_id             col25,
                        AD.original_origination_type    col26,
                        -1 * AD.ALLOCATED_QUANTITY      col27,  -- unallocated quantity
                        MTPS.LOCATION                   col28, --bug3263368
                        MTP.PARTNER_NAME                col29, --bug3263368
                        AD.DEMAND_CLASS                 col30, --bug3263368
                        AD.REQUEST_DATE                 col31  --bug3263368
                FROM
                        MSC_ALLOC_DEMANDS AD,
                        MSC_ALLOC_TEMP TEMP,
                        MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS, --bug3263368
                        MSC_SYSTEM_ITEMS    msi --bug3671294
                WHERE
                         AD.PLAN_ID = p_plan_id
                AND      AD.SR_INSTANCE_ID = p_instance_id
                AND      AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND      AD.ORGANIZATION_ID = p_org_id
                AND      AD.ALLOCATED_QUANTITY <> 0
                --bug3671294 start
                AND      msi.PLAN_ID = AD.PLAN_ID
                AND      msi.SR_INSTANCE_ID = AD.SR_INSTANCE_ID
                AND      msi.ORGANIZATION_ID = AD.ORGANIZATION_ID
                AND      msi.INVENTORY_ITEM_ID = AD.ORIGINAL_ITEM_ID
                --bug3671294 end
                AND      TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
                AND      AD.ORIGINATION_TYPE <> 52  -- Ignore copy SO and copy stealing records for allocation WB
                AND      AD.SHIP_TO_SITE_ID  = MTPS.PARTNER_SITE_ID(+) --bug3263368
                AND      AD.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368

                UNION ALL

                SELECT  p_session_id                    col1,
                        p_level_id                      col2,
                        p_sr_member_id                  col3 ,
                        p_org_id                        col4,
                        p_instance_id                   col5,
                        SA.PARENT_TRANSACTION_ID        col6,
                        2                               col7, -- supply
                        TRUNC(SA.SUPPLY_DATE)           col8,
                        NVL(SA.SUPPLY_QUANTITY,
                          SA.ALLOCATED_QUANTITY)        col9,
                        SA.ORDER_TYPE                   col10,
                        SA.ALLOCATED_QUANTITY
                         * DECODE(DECODE(SA.DEMAND_CLASS, null, null,
                                     DECODE(TEMP.DEMAND_CLASS,'-1',
                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null,
                                          null,
                                          Decode(sign(trunc(SA.Supply_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', SA.Original_Item_Id,
                                                        p_family_id)),
                                          p_org_id,
                                          p_instance_id,
                                          TRUNC(SA.SUPPLY_DATE),
                                          p_level_id,
                                          SA.DEMAND_CLASS),
                                        SA.DEMAND_CLASS)),
                                TEMP.DEMAND_CLASS,
                                        1,
                                NULL,
                                        NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                        p_instance_id,
                                        Decode(sign(trunc(SA.Supply_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', SA.Original_Item_Id,
                                                        p_family_id)),
                                        p_org_id,
                                        null,
                                        null,
                                        TEMP.DEMAND_CLASS,
                                        TRUNC(SA.SUPPLY_DATE)),
                                        1),
                                DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                        p_instance_id,
                                        Decode(sign(trunc(SA.Supply_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                1, p_family_id,
                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                        'Y', SA.Original_Item_Id,
                                                        p_family_id)),
                                        p_org_id,
                                        null,
                                        null,
                                        TEMP.DEMAND_CLASS,
                                        TRUNC(SA.SUPPLY_DATE)),
                                        NULL,
                                        1,
                                        0)
                                )                       col11, -- allocated_quantity
                        p_record_type                   col12, -- record_type
                        p_scenario_id                   col13, -- scenario_id
                        DECODE(SA.ORIGINAL_ORDER_TYPE,
                                5, to_char(SA.PARENT_TRANSACTION_ID),
                                SA.ORDER_NUMBER)        col14, -- disposition_name
                        TEMP.DEMAND_CLASS               col15, -- demand_class
                        p_uom_code                      col16, -- UOM Code
                        --bug3671294
                        msi.item_name                   col17, -- Item name
                        --p_inv_item_name                 col17, -- Item name
                        p_org_code                      col18, -- Org code
                        TEMP.PRIORITY                   col19, -- sysdate priroty
                        TEMP.ALLOCATION_PERCENT         col20,  -- sysdate allocation percent
                        p_sr_family_id                  col21,
                        l_null_num                      col22, -- Bug 3875786 - local variable used for NULL
                        l_null_num                      col23, -- Bug 3875786 - local variable used for NULL
                        l_null_date                     col24, -- Bug 3875786 - local variable used for NULL
                        SA.original_item_id             col25,
                        SA.ORIGINAL_ORDER_TYPE          col26,
                        SA.ALLOCATED_QUANTITY           col27,  -- unallocated quantity
                        l_null_char                     col28, --bug3263368 ORIG_CUSTOMER_SITE_NAME --Bug 3875786
                        l_null_char                     col29, --bug3263368 ORIG_CUSTOMER_NAME --Bug 3875786
                        l_null_char                     col30, --bug3263368 ORIG_DEMAND_CLASS --Bug 3875786
                        l_null_date                     col31  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - local variable used for NULL

                FROM
                        MSC_ALLOC_SUPPLIES SA,
                        MSC_ALLOC_TEMP TEMP,
                        MSC_SYSTEM_ITEMS    msi --bug3671294
                WHERE
                         SA.PLAN_ID = p_plan_id
                AND      SA.SR_INSTANCE_ID = p_instance_id
                AND      SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                AND      SA.ORGANIZATION_ID = p_org_id
                AND      SA.ALLOCATED_QUANTITY <> 0
                --bug3671294 start
                AND      msi.PLAN_ID = SA.PLAN_ID
                AND      msi.SR_INSTANCE_ID = SA.SR_INSTANCE_ID
                AND      msi.ORGANIZATION_ID = SA.ORGANIZATION_ID
                AND      msi.INVENTORY_ITEM_ID = SA.ORIGINAL_ITEM_ID
                --bug3671294 end
                AND      TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                AND      TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
                );
        ELSIF p_type = User_Defined_CC THEN
                INSERT INTO MRP_ATP_DETAILS_TEMP
                (session_id, atp_level, inventory_item_id, organization_id, identifier1, identifier3,
                supply_demand_type, supply_demand_date, supply_demand_quantity, supply_demand_source_type,
                allocated_quantity, record_type, scenario_id, disposition_name, demand_class, class, customer_id,
                customer_site_id, uom_code, inventory_item_name, organization_code, identifier2, identifier4,
                Customer_Name, Customer_Site_Name, request_item_id, pf_display_flag, original_demand_quantity,
                original_demand_date, original_item_id, original_supply_demand_type, unallocated_quantity,
                ORIG_CUSTOMER_SITE_NAME,ORIG_CUSTOMER_NAME,ORIG_DEMAND_CLASS,ORIG_REQUEST_DATE ) --bug3263368
                SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10,
                col11, col12, col13, col14, col15, col16, col17, col18, col19, col20, col21, col22, col23, col24, col25,
                col26, col27, col28, col29, col30, col31, col32,col33,col34,col35,col36
                FROM
                (SELECT p_session_id                            col1, -- session_id
                        p_level_id                              col2, -- level_id
                        p_sr_member_id                          col3, -- inventory_item_id
                        p_org_id                                col4, -- organization_id
                        p_instance_id                           col5, -- Identifier1
                        AD.PARENT_DEMAND_ID                     col6, -- Identifier3
                        1                                       col7, -- supply_demand_type
                        TRUNC(AD.DEMAND_DATE)                   col8, -- supply_demand_date
                        -1 * NVL(AD.DEMAND_QUANTITY,
                             AD.ALLOCATED_QUANTITY)             col9, -- supply_demand_quantity
                        AD.ORIGINATION_TYPE                     col10,-- supply_demand_source_type
                        -1 * AD.ALLOCATED_QUANTITY *
                                DECODE(DECODE(AD.CUSTOMER_ID, NULL, NULL,
                                        0, NULL,
                                        decode(AD.origination_type,
                                                6, decode(AD.source_organization_id,
                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        NULL),
                                                30, decode(AD.source_organization_id,
                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                        AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)),
                                                        p_org_id, p_instance_id,
                                                        TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                        p_level_id, NULL))),
                                        TEMP.LEVEL_3_DEMAND_CLASS, 1,
                                        MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                                AD.PARENT_DEMAND_ID,
                                                TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                AD.USING_ASSEMBLY_ITEM_ID,
                                                DECODE(AD.SOURCE_ORGANIZATION_ID,
                                                -23453, null,
                                                AD.SOURCE_ORGANIZATION_ID),
                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', AD.Original_Item_Id,
                                                                p_family_id)),
                                                p_org_id,
                                                p_instance_id,
                                                AD.ORIGINATION_TYPE,
                                                DECODE(AD.CUSTOMER_ID, NULL, TEMP.LEVEL_3_DEMAND_CLASS,
                                                        0, TEMP.LEVEL_3_DEMAND_CLASS,
                                                        decode(AD.origination_type,
                                                                6, decode(AD.source_organization_id,
                                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        TEMP.LEVEL_3_DEMAND_CLASS),
                                                                30, decode(AD.source_organization_id,
                                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        TEMP.LEVEL_3_DEMAND_CLASS),
                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                1, p_family_id,
                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                        'Y', AD.Original_Item_Id,
                                                                                        p_family_id)),
                                                                        p_org_id, p_instance_id,
                                                                        TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                        p_level_id, NULL))),
                                                TEMP.LEVEL_3_DEMAND_CLASS,
                                                p_level_id))    col11, -- allocated_quantity
                        p_record_type                           col12, -- record_type
                        p_scenario_id                           col13, -- scenario_id
                        AD.ORDER_NUMBER                         col14, -- disposition_name
                        TEMP.LEVEL_3_DEMAND_CLASS               col15, -- demand_class
                        TEMP.LEVEL_1_DEMAND_CLASS               col16, -- class
                        TEMP.PARTNER_ID                         col17, -- partner_id
                        TEMP.PARTNER_SITE_ID                    col18, -- partner_site_id
                        p_uom_code                              col19, -- UOM Code
                        --bug3671294
                        msi.item_name                           col20, -- Item name
                        --p_inv_item_name                         col20, -- Item name
                        p_org_code                              col21, -- Org code
                        TEMP.LEVEL_3_DEMAND_CLASS_PRIORITY      col22, -- Level 3 priority
                        TEMP.ALLOCATION_PERCENT                 col23, -- Sysdate allocation percent
                        TEMP.customer_name                      col24, -- Customer Name
                        TEMP.customer_site_name                 col25, -- Customer Site Name
                        p_sr_member_id                          col26, -- request_item_id
                	Decode(AD.inventory_item_id, p_family_id,
                	        Decode(AD.original_item_id, p_member_id,
                	                AD.Pf_Display_Flag,
                	                Decode(sign(trunc(AD.Original_Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                	                        1, AD.Pf_Display_Flag,
                	                        1)),
                	        AD.Pf_Display_Flag)             col27,
                        -1 * NVL(AD.DEMAND_QUANTITY,
                             AD.ALLOCATED_QUANTITY)*
                                DECODE(DECODE(AD.CUSTOMER_ID, NULL, NULL,
                                        0, NULL,
                                        decode(AD.origination_type,
                                                6, decode(AD.source_organization_id,
                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        NULL),
                                                30, decode(AD.source_organization_id,
                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                        1, p_family_id,
                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                'Y', AD.Original_Item_Id,
                                                                                p_family_id)),
                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                p_level_id, NULL),
                                                        NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                        AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                1, p_family_id,
                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                        'Y', AD.Original_Item_Id,
                                                                        p_family_id)),
                                                        p_org_id, p_instance_id,
                                                        TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                        p_level_id, NULL))),
                                        TEMP.LEVEL_3_DEMAND_CLASS, 1,
                                        MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                                AD.PARENT_DEMAND_ID,
                                                TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                AD.USING_ASSEMBLY_ITEM_ID,
                                                DECODE(AD.SOURCE_ORGANIZATION_ID,
                                                -23453, null,
                                                AD.SOURCE_ORGANIZATION_ID),
                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', AD.Original_Item_Id,
                                                                p_family_id)),
                                                p_org_id,
                                                p_instance_id,
                                                AD.ORIGINATION_TYPE,
                                                DECODE(AD.CUSTOMER_ID, NULL, TEMP.LEVEL_3_DEMAND_CLASS,
                                                        0, TEMP.LEVEL_3_DEMAND_CLASS,
                                                        decode(AD.origination_type,
                                                                6, decode(AD.source_organization_id,
                                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        TEMP.LEVEL_3_DEMAND_CLASS),
                                                                30, decode(AD.source_organization_id,
                                                                        NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        AD.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                                AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                                Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                        1, p_family_id,
                                                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                                'Y', AD.Original_Item_Id,
                                                                                                p_family_id)),
                                                                                p_org_id, p_instance_id, TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                                p_level_id, NULL),
                                                                        TEMP.LEVEL_3_DEMAND_CLASS),
                                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                                        AD.CUSTOMER_ID, AD.SHIP_TO_SITE_ID,
                                                                        Decode(sign(trunc(AD.Demand_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                                                1, p_family_id,
                                                                                Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                                        'Y', AD.Original_Item_Id,
                                                                                        p_family_id)),
                                                                        p_org_id, p_instance_id,
                                                                        TRUNC(AD.ORIGINAL_DEMAND_DATE),
                                                                        p_level_id, NULL))),
                                                TEMP.LEVEL_3_DEMAND_CLASS,
                                                p_level_id))    col28, -- original demand quantity
                        trunc(AD.original_demand_date)          col29, --Bug_3693892 added trunc
                        AD.original_item_id                     col30,
                        AD.original_origination_type            col31,
                        -1 * AD.ALLOCATED_QUANTITY              col32,  -- unallocated quantity
                        MTPS.LOCATION                           col33, --bug3263368
                        MTP.PARTNER_NAME                        col34, --bug3263368
                        AD.DEMAND_CLASS                         col35, --bug3263368
                        AD.REQUEST_DATE                         col36  --bug3263368
                FROM
                        MSC_ALLOC_DEMANDS        AD,
                        MSC_ALLOC_HIERARCHY_TEMP TEMP,
                        MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS, --bug3263368
                        MSC_SYSTEM_ITEMS    msi --bug3671294
                WHERE
                        AD.PLAN_ID = p_plan_id
                        AND AD.SR_INSTANCE_ID = p_instance_id
                        AND AD.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                        AND AD.ORGANIZATION_ID = p_org_id
                        AND AD.ORIGINATION_TYPE <> 52 -- For summary enhancement
                        AND TRUNC(AD.DEMAND_DATE) < NVL(p_itf, TRUNC(AD.DEMAND_DATE) + 1)
                        AND AD.ALLOCATED_QUANTITY <> 0
                        --bug3671294 start
                        AND      msi.PLAN_ID = AD.PLAN_ID
                        AND      msi.SR_INSTANCE_ID = AD.SR_INSTANCE_ID
                        AND      msi.ORGANIZATION_ID = AD.ORGANIZATION_ID
                        AND      msi.INVENTORY_ITEM_ID = AD.ORIGINAL_ITEM_ID
                        --bug3671294 end
                        AND AD.SHIP_TO_SITE_ID  = MTPS.PARTNER_SITE_ID(+) --bug3263368
                        AND AD.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368
                UNION ALL
                SELECT  p_session_id                            col1, -- session_id
                        p_level_id                              col2, -- level_id
                        p_sr_member_id                          col3, -- inventory_item_id
                        p_org_id                                col4, -- organization_id
                        p_instance_id                           col5, -- Identifier1
                        SA.PARENT_TRANSACTION_ID                col6, -- Identifier3
                        2                                       col7, -- supply_demand_type
                        TRUNC(SA.SUPPLY_DATE)                   col8, -- supply_demand_date
                        NVL(SA.SUPPLY_QUANTITY,
                                SA.ALLOCATED_QUANTITY)          col9, -- supply_demand_source_quantity
                        SA.ORDER_TYPE                           col10, -- supply_demand_source_type
                        SA.ALLOCATED_QUANTITY
                                * DECODE(DECODE(SA.CUSTOMER_ID, NULL, NULL,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  SA.CUSTOMER_ID,
                                                  SA.SHIP_TO_SITE_ID,
                                                  Decode(sign(trunc(SA.Supply_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', SA.Original_Item_Id,
                                                                p_family_id)),
                                                  p_org_id,
                                                  p_instance_id,
                                                  TRUNC(SA.SUPPLY_DATE),
                                                  p_level_id,
                                                  NULL)),
                                        TEMP.LEVEL_3_DEMAND_CLASS,
                                                1,
                                        NULL,
                                                NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                p_instance_id,
                                                Decode(sign(trunc(SA.Supply_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', SA.Original_Item_Id,
                                                                p_family_id)),
                                                p_org_id,
                                                null,
                                                null,
                                                TEMP.LEVEL_3_DEMAND_CLASS,
                                                TRUNC(SA.SUPPLY_DATE)), 1),
                                        DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                p_instance_id,
                                                Decode(sign(trunc(SA.Supply_Date) - MSC_ATP_ALLOC.G_Atf_Date),
                                                        1, p_family_id,
                                                        Decode(MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF,
                                                                'Y', SA.Original_Item_Id,
                                                                p_family_id)),
                                                p_org_id,
                                                null,
                                                null,
                                                TEMP.LEVEL_3_DEMAND_CLASS,
                                                TRUNC(SA.SUPPLY_DATE)),
                                                NULL, 1, 0)
                                        )                       col11, -- allocated_quantity
                        p_record_type                           col12, -- record_type
                        p_scenario_id                           col13, -- scenario_id
                        DECODE(SA.ORIGINAL_ORDER_TYPE,
                                5, to_char(SA.PARENT_TRANSACTION_ID),
                                SA.ORDER_NUMBER)                col14, -- disposition_name
                        TEMP.LEVEL_3_DEMAND_CLASS               col15, -- demand_class
                        TEMP.LEVEL_1_DEMAND_CLASS               col16, -- class
                        TEMP.PARTNER_ID                         col17, -- partner_id
                        TEMP.PARTNER_SITE_ID                    col18, -- partner_site_id
                        p_uom_code                              col19, -- UOM Code
                        --bug3671294
                        msi.item_name                           col20, -- Item name
                        --p_inv_item_name                         col20, -- Item name
                        p_org_code                              col21, -- Org code
                        TEMP.LEVEL_3_DEMAND_CLASS_PRIORITY      col22, -- Level 3 priority
                        TEMP.ALLOCATION_PERCENT                 col23, -- Sysdate allocation percent
                        TEMP.customer_name                      col24, -- Customer Name
                        TEMP.customer_site_name                 col25, -- Customer Site Name
                        p_sr_member_id                          col26, -- request_item_id
		        l_null_num                              col27,
        	        l_null_num                              col28,
        	        l_null_date                             col29, -- Bug 3875786 - local variable used for NULL
        	        SA.Original_Item_Id                     col30,
        	        SA.ORIGINAL_ORDER_TYPE                  col31,
        	        SA.ALLOCATED_QUANTITY                   col32,  -- unallocated quantity
        	        l_null_char                             col33, --bug3263368 ORIG_CUSTOMER_SITE_NAME --Bug 3875786
        	        l_null_char                             col34, --bug3263368 ORIG_CUSTOMER_NAME --Bug 3875786
        	        l_null_char                             col35, --bug3263368 ORIG_DEMAND_CLASS --Bug 3875786
        	        l_null_date                             col36  --bug3263368 ORIG_REQUEST_DATE -- Bug 3875786 - local variable used for NULL
        	FROM
                        MSC_ALLOC_SUPPLIES       SA,
                        MSC_ALLOC_HIERARCHY_TEMP TEMP,
                        MSC_SYSTEM_ITEMS    msi --bug3671294
                WHERE
                        SA.PLAN_ID = p_plan_id
                        AND SA.SR_INSTANCE_ID = p_instance_id
                        AND SA.INVENTORY_ITEM_ID in (p_member_id, p_family_id)
                        AND SA.ORGANIZATION_ID = p_org_id
                        AND SA.ALLOCATED_QUANTITY <> 0
                        --bug3671294 start
                        AND      msi.PLAN_ID = SA.PLAN_ID
                        AND      msi.SR_INSTANCE_ID = SA.SR_INSTANCE_ID
                        AND      msi.ORGANIZATION_ID = SA.ORGANIZATION_ID
                        AND      msi.INVENTORY_ITEM_ID = SA.ORIGINAL_ITEM_ID
                        --bug3671294 end
                        AND TRUNC(SA.SUPPLY_DATE) >= DECODE(SA.ORIGINAL_ORDER_TYPE,
                                                        27, TRUNC(SYSDATE),
                                                        28, TRUNC(SYSDATE),
                                                        TRUNC(SA.SUPPLY_DATE))
                        AND TRUNC(SA.SUPPLY_DATE) < NVL(p_itf, TRUNC(SA.SUPPLY_DATE) + 1)
                );
        END IF;

        x_insert_count := SQL%ROWCOUNT;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_SD_Into_Details_Temp: ' || 'Error code:' || to_char(sqlcode));
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Insert_SD_Into_Details_Temp;

/*--Populate_Original_Demand_Qty--------------------------------------------
|  o  Called for population of original_demand_quantity column in
|       demand priority AATP scenarios
+-------------------------------------------------------------------------*/
PROCEDURE Populate_Original_Demand_Qty(
	p_table                         IN      NUMBER,
	p_session_id                    IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS
        -- local variables
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('********** Begin Populate_Original_Demand_Qty Procedure **********');
                msc_sch_wb.atp_debug('Populate_Original_Demand_Qty: ' || 'p_table: '|| to_char(p_table));
                msc_sch_wb.atp_debug('Populate_Original_Demand_Qty: ' || 'p_session_id: '|| to_char(p_session_id));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* Clear msc_alloc_temp before use */
        DELETE msc_alloc_temp;

        IF p_table = MADT THEN

                /* Do netting in SQL and insert original demand qtys in alloc temp table*/
                INSERT INTO MSC_ALLOC_TEMP(
                        demand_class,
                        demand_id,
                        supply_demand_quantity
                )
                (SELECT demand_class,
                        parent_demand_id,
                        sum(allocated_quantity)
                 FROM   msc_alloc_demands
                 WHERE  (demand_class, parent_demand_id) in
                                (SELECT  demand_class,
                                         identifier3
                                 FROM    mrp_atp_details_temp
                                 WHERE   session_id = p_session_id
                                 AND     supply_demand_type = 1
                                 AND     record_type = 2)
                 AND    plan_id = p_plan_id
                 GROUP BY
                        demand_class,
                        parent_demand_id
                );

                /* Now update original demand qtys in mrp_atp_details_temp table*/
                UPDATE  mrp_atp_details_temp madt
                SET     madt.original_demand_quantity =
                               (select  -1*mat.supply_demand_quantity
                                from    msc_alloc_temp mat
                                where   mat.demand_class = madt.demand_class
                                and     mat.demand_id = madt.identifier3)
                WHERE   madt.session_id = p_session_id
                AND     madt.supply_demand_type = 1
                AND     madt.record_type = 2;

        ELSIF p_table = MASDDT THEN

                /* Do netting in SQL and insert original demand qtys in alloc temp table*/
                INSERT INTO MSC_ALLOC_TEMP(
                        demand_id,
                        supply_demand_quantity
                )
                SELECT  parent_demand_id,
                        sum(allocated_quantity)
                FROM    msc_alloc_demands
                WHERE   parent_demand_id in
                                (SELECT  identifier3
                                 FROM    msc_atp_sd_details_temp
                                 WHERE   supply_demand_type = 1)
                AND     plan_id = p_plan_id
                AND     demand_class = nvl(p_demand_class, demand_class)
                GROUP BY
                        parent_demand_id;

                /* Now update original demand qtys in msc_atp_sd_details_temp table*/
                UPDATE  msc_atp_sd_details_temp masddt
                SET     masddt.original_demand_quantity =
                               (select  -1*mat.supply_demand_quantity
                                from    msc_alloc_temp mat
                                where   mat.demand_id = masddt.identifier3)
                WHERE   masddt.supply_demand_type = 1;

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('**********End Populate_Original_Demand_Qty Procedure************');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Populate_Original_Demand_Qty: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Populate_Original_Demand_Qty;

/*--PF_Atp_Consume----------------------------------------------------------
|  o  Called for consumption in product family scenarios.
|  o  This procedure combines various procedures for consumption we have in
|       one procedure.
|  o  Logic is similar only difference being that we do not do b/w and f/w
|       consumption across aggregate time fence. So for a negative bucket
|       we exit from inner loop during backward consumption when crossing
|       aggregate time fence.
|  o  Also this procedure incorporates better algorithm for consumption.
|  o  This procedure does following depending on the value of input variable
|       p_consumption_type:
|       - Backward(1) : Backward consumption
|       - Forward(2) : Forward consumption
|       - Cum(3) : Accumulation
|       - Bw_Fw_Cum(4) : Backward consumption, forward consumption and accumulation
|       - Bw_Fw(5) : Backward consumption and forward consumption
+-------------------------------------------------------------------------*/
PROCEDURE PF_Atp_Consume(
        p_atp_qty                       IN OUT  NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        p_atp_period                    IN      MRP_ATP_PUB.date_arr  :=NULL,
        p_consumption_type              IN      NUMBER := Bw_Fw_Cum,
        p_atf_date                      IN      DATE := NULL
)
IS
        -- local variables
        i                               NUMBER;
        j                               NUMBER;
        l_fw_nullifying_bucket_index    NUMBER := 1;


BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('********** Begin PF_Atp_Consume Procedure **********');
                msc_sch_wb.atp_debug('PF_Atp_Consume: ' || 'p_consumption_type: '|| to_char(p_consumption_type));
                msc_sch_wb.atp_debug('PF_Atp_Consume: ' || 'p_atf_date: '|| to_char(p_atf_date));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* p_consumption_type
         * 1 = b/w consumption
         * 2 = f/w consumption
         * 3 = accumulation
         * 4 = b/w, f/w consumption and accumulation
         * 5 = b/w and f/w consumption
         */
        IF p_consumption_type = Backward THEN
                -- this for loop will do backward consumption
                FOR i in 2..p_atp_qty.COUNT LOOP
                        -- backward consumption when neg atp quantity occurs
                        IF (p_atp_qty(i) < 0 ) THEN
                                j := i - 1;
                                WHILE ((j>0) and (p_atp_qty(j)>=0))  LOOP
                                        IF ((p_atp_period(i)>p_atf_date) and (p_atp_period(j)<=p_atf_date)) THEN
                                                -- exit loop when crossing time fence
                                                j := 0;
                                        ELSIF (p_atp_qty(j) = 0) THEN
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
                END LOOP;
        ELSIF p_consumption_type = Forward THEN
                -- this for loop will do forward consumption
                FOR i in 1..p_atp_qty.COUNT LOOP
                        -- forward consumption when neg atp quantity occurs
                        IF (p_atp_qty(i) < 0 ) THEN
                                j := i + 1;
                                WHILE (j <= p_atp_qty.COUNT)  LOOP
                                        IF ((p_atp_period(i)<=p_atf_date) and (p_atp_period(j)>p_atf_date)) THEN
                                                -- exit loop when crossing time fence
                                                j := p_atp_qty.COUNT+1;
                                        ELSIF (p_atp_qty(j) <= 0 OR j < l_fw_nullifying_bucket_index) THEN
                                                --  forward one more period if next period is negative or
                                                -- less than nullifying bucket index
                                                j := j+1 ;
                                        ELSE
                                                -- You can get something from here. So set the nullifying bucket index
                                                l_fw_nullifying_bucket_index := j;
                                                IF (p_atp_qty(j) + p_atp_qty(i) < 0) THEN
                                                        -- not enough to cover the shortage
                                                        p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(j);
                                                        p_atp_qty(j) := 0;
                                                        j := j+1;
                                                ELSE
                                                        -- enough to cover the shortage
                                                        p_atp_qty(j) := p_atp_qty(j) + p_atp_qty(i);
                                                        p_atp_qty(i) := 0;
                                                        j := p_atp_qty.COUNT + 1;
                                                END IF;
                                        END IF;
                                END LOOP;
                        END IF;
                END LOOP;
        ELSIF (p_consumption_type = Bw_Fw_Cum) OR (p_consumption_type = Bw_Fw) THEN
                -- this for loop will do backward consumption
                FOR i in 1..p_atp_qty.COUNT LOOP
                        -- Do backward consumption only when neg bucket and current index
                        -- greater l_fw_nullifying_bucket_index.
                        IF (p_atp_qty(i) < 0 AND i > l_fw_nullifying_bucket_index) THEN
                                j := i - 1;
                                WHILE ((j >= l_fw_nullifying_bucket_index) and (p_atp_qty(j)>=0))  LOOP
                                        IF ((p_atp_period(i)>p_atf_date) and (p_atp_period(j)<=p_atf_date)) THEN
                                                -- exit loop when crossing time fence
                                                j := 0;
                                        ELSIF (p_atp_qty(j) = 0) THEN
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

                        -- forward consumption when neg atp quantity occurs
                        IF (p_atp_qty(i) < 0 ) THEN
                                j := i + 1;
                                WHILE (j <= p_atp_qty.COUNT)  LOOP
                                        IF ((p_atp_period(i)<=p_atf_date) and (p_atp_period(j)>p_atf_date)) THEN
                                                -- exit loop when crossing time fence
                                                j := p_atp_qty.COUNT+1;
                                        ELSIF (p_atp_qty(j) <= 0 OR j < l_fw_nullifying_bucket_index) THEN
                                                --  forward one more period if next period is negative or
                                                -- less than nullifying bucket index
                                                j := j+1 ;
                                        ELSE
                                                -- You can get something from here. So set the nullifying bucket index
                                                l_fw_nullifying_bucket_index := j;
                                                IF (p_atp_qty(j) + p_atp_qty(i) < 0) THEN
                                                        -- not enough to cover the shortage
                                                        p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(j);
                                                        p_atp_qty(j) := 0;
                                                        j := j+1;
                                                ELSE
                                                        -- enough to cover the shortage
                                                        p_atp_qty(j) := p_atp_qty(j) + p_atp_qty(i);
                                                        p_atp_qty(i) := 0;
                                                        j := p_atp_qty.COUNT + 1;
                                                END IF;
                                        END IF;
                                END LOOP;
                        END IF;
                END LOOP;
        END IF;

        IF (p_consumption_type = Cum) or (p_consumption_type = Bw_Fw_Cum) THEN
        --Bug 3919388 (Cum is decreasing)
          IF ( p_atp_qty.count > 0 ) THEN
             IF ( p_atp_qty(1) < 0) THEN
                 p_atp_qty(1) := 0;
             END IF;
          END IF;
           -- this for loop will do the acculumation
          FOR i in 2..p_atp_qty.COUNT LOOP
             p_atp_qty(i) := GREATEST(p_atp_qty(i), 0) + GREATEST(p_atp_qty(i-1), 0); --Bug 3919388 (Cum is decreasing)
          END LOOP;
       END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('**********End PF_Atp_Consume Procedure************');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('PF_Atp_Consume: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END PF_Atp_Consume;

/*--PF_Atp_Alloc_Consume-------------------------------------------------------
|  o  Called for consumption in demand priority AATP scenario.
|  o  Differences from Atp_Alloc_Consume:
|       -  We do not do b/w and f/w consumption across aggregate time fence.
|            So for a negative bucket we exit from inner loop during backward
|            consumption when crossing aggregate time fence.
|       -  Incorporates better algorithm for consumption.
+----------------------------------------------------------------------------*/
PROCEDURE PF_Atp_Alloc_Consume(
        p_atp_qty               IN OUT  NOCOPY MRP_ATP_PUB.number_arr,
        p_atp_period            IN      MRP_ATP_PUB.date_arr,
        p_atp_dc_tab	        IN      MRP_ATP_PUB.char80_arr,
        p_atf_date              IN      DATE,
        x_dc_list_tab	        OUT     NOCOPY MRP_ATP_PUB.char80_arr,
        x_dc_start_index        OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_dc_end_index          OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status         OUT     NOCOPY VARCHAR2
)
IS
        i                               NUMBER;
        j                               NUMBER;
        l_fw_nullifying_bucket_index    NUMBER := 1;


BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('**********Begin PF_Atp_Alloc_Consume Procedure************');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_dc_list_tab := MRP_ATP_PUB.Char80_Arr();
        x_dc_start_index := MRP_ATP_PUB.Number_Arr();
        x_dc_end_index := MRP_ATP_PUB.Number_Arr();

        x_dc_list_tab.EXTEND;
        x_dc_start_index.EXTEND;
        x_dc_end_index.EXTEND;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'after extend : ' || p_atp_dc_tab(p_atp_dc_tab.FIRST));
        END IF;

        x_dc_list_tab(1) := p_atp_dc_tab(p_atp_dc_tab.FIRST);
        x_dc_start_index(1) := 1;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'after assign : ' || x_dc_list_tab(1));
                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'start index : ' || x_dc_start_index(1));
        END IF;

        FOR i in 1..p_atp_dc_tab.COUNT LOOP
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'index : ' || i);
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'x_dc_list_tab : ' || x_dc_list_tab(x_dc_list_tab.COUNT));
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'p_atp_dc_tab : ' || p_atp_dc_tab(i));
                END IF;

                -- If demand class changes, re-initialize these variables.
                IF p_atp_dc_tab(i) <> x_dc_list_tab(x_dc_list_tab.COUNT) THEN
                        x_dc_end_index(x_dc_end_index.COUNT) := i - 1;
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'inside IF');
                                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'end index : ' || x_dc_end_index(x_dc_end_index.COUNT));
                        END IF;
                        x_dc_list_tab.EXTEND;
                        x_dc_start_index.EXTEND;
                        x_dc_end_index.EXTEND;
                        x_dc_list_tab(x_dc_list_tab.COUNT) := p_atp_dc_tab(i);
                        x_dc_start_index(x_dc_start_index.COUNT) := i;
                ELSE
                        x_dc_end_index(x_dc_end_index.COUNT) := i;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'start index : ' || x_dc_start_index(x_dc_start_index.COUNT));
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'end index : ' || x_dc_end_index(x_dc_end_index.COUNT));
                END IF;
                -- Do backward consumption only when neg bucket and current index
                -- greater l_fw_nullifying_bucket_index.
                IF (p_atp_qty(i) < 0 AND i > l_fw_nullifying_bucket_index) THEN
                        j := i - 1;
                        WHILE ((j >= x_dc_start_index(x_dc_start_index.COUNT)) and (p_atp_qty(j) >= 0))  LOOP
                                IF ((p_atp_period(i) > p_atf_date) and (p_atp_period(j) <= p_atf_date)) THEN
                                        -- exit loop when crossing time fence
                                        j := 0;
                                ELSIF (p_atp_qty(j) = 0) THEN
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
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'before forward consumption');
                END IF;

                -- forward consumption when neg atp quantity occurs
                IF (p_atp_qty(i) < 0 ) THEN
                        j := i + 1;
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'in forward consumption : '  || i || ':' || j);
                                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'in forward : '  || p_atp_dc_tab.COUNT);
                        END IF;

                        IF j < p_atp_dc_tab.COUNT THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'in j : '  || p_atp_dc_tab.COUNT);
                                END IF;
                                WHILE (p_atp_dc_tab(j) = x_dc_list_tab(x_dc_list_tab.COUNT))  LOOP
                                        IF ((p_atp_period(i) <= p_atf_date) and (p_atp_period(j) > p_atf_date)) THEN
                                                -- exit loop when crossing time fence
                                                EXIT;
                                        ELSIF (p_atp_qty(j) <= 0 OR j < l_fw_nullifying_bucket_index) THEN
                                                --  forward one more period
                                                j := j+1 ;
                                        ELSE
                                                -- You can get something from here. So set the nullifying bucket index
                                                l_fw_nullifying_bucket_index := j;
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
        END LOOP;

        x_dc_end_index(x_dc_end_index.count) := p_atp_dc_tab.count;

        IF PG_DEBUG in ('Y', 'C') THEN
                FOR i in 1..x_dc_list_tab.COUNT LOOP
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' ||  'DC:start:end - ' || x_dc_list_tab(i) || ':' ||
                                x_dc_start_index(i) || ':' ||
                                x_dc_end_index(i));
                END LOOP;

                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'x_dc_list_tab : ' || x_dc_list_tab.COUNT);
        END IF;

        -- this for loop will do atp consume on each dc
        FOR j in 1..x_dc_list_tab.COUNT LOOP
        --Bug 3919388 (Cum is decreasing)
                IF ( p_atp_qty(x_dc_start_index(j)) < 0) THEN
                     p_atp_qty(x_dc_start_index(j)) := 0;
                END IF;
                FOR i in (x_dc_start_index(j) + 1)..x_dc_end_index(j) LOOP
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'inside accumulation : ' || i);
                        END IF;
                        --Bug 3919388 (Cum is decreasing)
                        p_atp_qty(i) := GREATEST(p_atp_qty(i), 0) + GREATEST(p_atp_qty(i-1),0);
                END LOOP;
        END LOOP; 	--FOR i in 1..x_dc_list_tab.COUNT LOOP

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('**********End PF_Atp_Alloc_Consume Procedure************');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('PF_Atp_Alloc_Consume: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END PF_Atp_Alloc_Consume;

/*--Get_Period_Data_From_Sd_Temp--------------------------------------------
|  o  This procedure is called from Item_Alloc_Cum_Atp and
|       Item_Pre_Allocated_Atp procedures to get the period data from
|       msc_atp_sd_details_temp table.
|  o  Differences from the one in MSC_ATP_PROC:
|       -  For Total_Demand_Quantity only demands with Pf_Display_Flag equal
|            to 1 are looked at. Demand quantity is picked from
|            Original_Demand_Quantity column.
|  o  For Total_Bucketed_Demand_Quantity all demands are looked at.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Period_Data_From_Sd_Temp(
        x_atp_period                    OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS
        i			NUMBER;
        j			NUMBER;

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('PROCEDURE Get_Period_Data_From_Sd_Temp');
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT  SD_View.ATP_level
                ,SD_View.scenario_id
                ,SD_View.inventory_item_id
                ,SD_View.request_item_id
                ,SD_View.organization_id
                ,SD_View.supplier_id
                ,SD_View.supplier_site_id
                ,SD_View.department_id
                ,SD_View.resource_id
                ,SD_View.supply_demand_date
                ,SD_View.identifier1
                ,SD_View.identifier2
                ,SUM(SD_View.demand_quantity)
                ,SUM(SD_View.bucketed_demand_quantity)
                ,SUM(SD_View.supply_quantity)
                ,SUM(SD_View.period_quantity)
        BULK COLLECT INTO
                x_atp_period.Level,
                x_atp_period.Scenario_Id,
                x_atp_period.Inventory_Item_Id,
                x_atp_period.Request_Item_Id,
                x_atp_period.Organization_id,
                x_atp_period.Supplier_ID,
                x_atp_period.Supplier_Site_ID,
                x_atp_period.Department_id,
                x_atp_period.Resource_id,
                x_atp_period.Period_Start_Date,
                x_atp_period.Identifier1,
                x_atp_period.Identifier2,
                x_atp_period.Total_Demand_Quantity,
                x_atp_period.Total_Bucketed_Demand_Quantity,
                x_atp_period.Total_Supply_Quantity,
                x_atp_period.Period_Quantity
        FROM (
                SELECT  ATP_level
                        ,scenario_id
                        ,inventory_item_id
                        ,request_item_id
                        ,organization_id
                        ,supplier_id
                        ,supplier_site_id
                        ,department_id
                        ,resource_id
                        ,trunc(supply_demand_date) supply_demand_date --Bug_3693892 added trunc
                        ,identifier1
                        ,identifier2
                        ,(DECODE(supply_demand_type, 1,
                                 DECODE(pf_display_flag, 1,
                                        --Bug_3693892 added trunc
                                        DECODE(trunc(original_demand_date), trunc(supply_demand_date),
                                               original_demand_quantity, 0),
                                        0),
                                 0)) demand_quantity
                        ,(DECODE(supply_demand_type, 1,
                                 allocated_quantity,
                                 0)) bucketed_demand_quantity
                        ,(DECODE(supply_demand_type, 2,
                                 allocated_quantity,
                                 0)) supply_quantity
                        ,allocated_quantity period_quantity
                FROM    msc_atp_sd_details_temp

                UNION ALL

                SELECT
                        ATP_level
                        ,scenario_id
                        ,inventory_item_id
                        ,request_item_id
                        ,organization_id
                        ,supplier_id
                        ,supplier_site_id
                        ,department_id
                        ,resource_id
                        ,trunc(original_demand_date) supply_demand_date --Bug_3693892 added trunc
                        ,identifier1
                        ,identifier2
                        ,original_demand_quantity demand_quantity
                        ,0 bucketed_demand_quantity
                        ,0 supply_quantity
                        ,0 period_quantity
                FROM    msc_atp_sd_details_temp
                WHERE   supply_demand_type = 1
                AND     pf_display_flag = 1
                AND     trunc(supply_demand_date) <> trunc(original_demand_date) --Bug_3693892 added trunc
        ) SD_View
        GROUP BY
                SD_View.supply_demand_date
                ,SD_View.ATP_level
                ,SD_View.scenario_id
                ,SD_View.inventory_item_id
                ,SD_View.request_item_id
                ,SD_View.organization_id
                ,SD_View.supplier_id
                ,SD_View.supplier_site_id
                ,SD_View.department_id
                ,SD_View.resource_id
                ,SD_View.identifier1
                ,SD_View.identifier2
        ORDER BY
                SD_View.supply_demand_date;

     -- set the period end dates and
     -- extend the remaining fields to ensure same behaviour as before
     i := x_atp_period.Period_Start_Date.COUNT;

     x_atp_period.Identifier.EXTEND(i);
     x_atp_period.Pegging_Id.EXTEND(i);
     x_atp_period.End_Pegging_Id.EXTEND(i);
     x_atp_period.Period_End_Date.EXTEND(i);
     x_atp_period.From_Location_Id.EXTEND(i);
     x_atp_period.From_Organization_Id.EXTEND(i);
     x_atp_period.Ship_Method.EXTEND(i);
     x_atp_period.To_Location_Id.EXTEND(i);
     x_atp_period.To_Organization_Id.EXTEND(i);
     x_atp_period.Uom.EXTEND(i);

     FOR j IN 1..(i-1) LOOP
	x_atp_period.Period_End_Date(j) :=
		x_atp_period.Period_Start_Date(j+1) - 1;
     END LOOP;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Period_Data_From_Sd_Temp: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Period_Data_From_Sd_Temp;

/*--Get_Unalloc_Data_From_Sd_Temp-------------------------------------------
|  o  Called from Item_Alloc_Cum_Atp procedure for Rule based Allocated Time
|       Phased PF ATP (AATP Forward Consumption Method 2).
|  o  This is similar to previous procedure only difference being that we
|       also return unallocated quantities.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Unalloc_Data_From_Sd_Temp(
        x_atp_period                    OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
        p_unallocated_atp		IN      OUT NOCOPY MRP_ATP_PVT.ATP_Info,
        x_return_status 		OUT     NOCOPY VARCHAR2
) IS
        i			NUMBER;
        j			NUMBER;

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('PROCEDURE Get_Unalloc_Data_From_Sd_Temp');
        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- do netting for unallocated qty also
        SELECT  SD_View.ATP_level
                ,SD_View.scenario_id
                ,SD_View.inventory_item_id
                ,SD_View.request_item_id
                ,SD_View.organization_id
                ,SD_View.supplier_id
                ,SD_View.supplier_site_id
                ,SD_View.department_id
                ,SD_View.resource_id
                ,SD_View.supply_demand_date
                ,SD_View.identifier1
                ,SD_View.identifier2
                ,SUM(SD_View.demand_quantity)
                ,SUM(SD_View.bucketed_demand_quantity)
                ,SUM(SD_View.supply_quantity)
                ,SUM(SD_View.period_quantity)
                ,SUM(SD_View.unallocated_quantity)
        BULK COLLECT INTO
                x_atp_period.Level,
                x_atp_period.Scenario_Id,
                x_atp_period.Inventory_Item_Id,
                x_atp_period.Request_Item_Id,
                x_atp_period.Organization_id,
                x_atp_period.Supplier_ID,
                x_atp_period.Supplier_Site_ID,
                x_atp_period.Department_id,
                x_atp_period.Resource_id,
                x_atp_period.Period_Start_Date,
                x_atp_period.Identifier1,
                x_atp_period.Identifier2,
                x_atp_period.Total_Demand_Quantity,
                x_atp_period.Total_Bucketed_Demand_Quantity,
                x_atp_period.Total_Supply_Quantity,
                x_atp_period.Period_Quantity,
                p_unallocated_atp.atp_qty
        FROM (
                SELECT  ATP_level
                        ,scenario_id
                        ,inventory_item_id
                        ,request_item_id
                        ,organization_id
                        ,supplier_id
                        ,supplier_site_id
                        ,department_id
                        ,resource_id
                        ,trunc(supply_demand_date) supply_demand_date --Bug_3693892 added trunc
                        ,identifier1
                        ,identifier2
                        ,DECODE(supply_demand_type, 1,
                                 DECODE(pf_display_flag, 1,
                                        --Bug_3693892 added trunc
                                        DECODE(trunc(original_demand_date), trunc(supply_demand_date),
                                               original_demand_quantity, 0),
                                        0),
                                 0) demand_quantity
                        ,DECODE(supply_demand_type, 1,
                                 allocated_quantity,
                                 0) bucketed_demand_quantity
                        ,DECODE(supply_demand_type, 2,
                                 allocated_quantity,
                                 0) supply_quantity
                        ,allocated_quantity period_quantity
                        ,unallocated_quantity
                FROM    msc_atp_sd_details_temp

                UNION ALL

                SELECT
                        ATP_level
                        ,scenario_id
                        ,inventory_item_id
                        ,request_item_id
                        ,organization_id
                        ,supplier_id
                        ,supplier_site_id
                        ,department_id
                        ,resource_id
                        ,trunc(original_demand_date) supply_demand_date --Bug_3693892 added trunc
                        ,identifier1
                        ,identifier2
                        ,original_demand_quantity demand_quantity
                        ,0 bucketed_demand_quantity
                        ,0 supply_quantity
                        ,0 period_quantity
                        ,0 unallocated_quantity
                FROM    msc_atp_sd_details_temp
                WHERE   supply_demand_type = 1
                AND     pf_display_flag = 1
                AND     trunc(supply_demand_date) <> trunc(original_demand_date) --Bug_3693892 added trunc
        ) SD_View
        GROUP BY
                SD_View.supply_demand_date
                ,SD_View.ATP_level
                ,SD_View.scenario_id
                ,SD_View.inventory_item_id
                ,SD_View.request_item_id
                ,SD_View.organization_id
                ,SD_View.supplier_id
                ,SD_View.supplier_site_id
                ,SD_View.department_id
                ,SD_View.resource_id
                ,SD_View.identifier1
                ,SD_View.identifier2
        ORDER BY
                SD_View.supply_demand_date;


     -- set the period end dates and
     -- extend the remaining fields to ensure same behaviour as before
     i := x_atp_period.Period_Start_Date.COUNT;

     x_atp_period.Identifier.EXTEND(i);
     x_atp_period.Pegging_Id.EXTEND(i);
     x_atp_period.End_Pegging_Id.EXTEND(i);
     x_atp_period.Period_End_Date.EXTEND(i);
     x_atp_period.From_Location_Id.EXTEND(i);
     x_atp_period.From_Organization_Id.EXTEND(i);
     x_atp_period.Ship_Method.EXTEND(i);
     x_atp_period.To_Location_Id.EXTEND(i);
     x_atp_period.To_Organization_Id.EXTEND(i);
     x_atp_period.Uom.EXTEND(i);

     FOR j IN 1..(i-1) LOOP
	x_atp_period.Period_End_Date(j) :=
		x_atp_period.Period_Start_Date(j+1) - 1;
     END LOOP;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Unalloc_Data_From_Sd_Temp: ' || 'Error code:' || to_char(sqlcode));
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Unalloc_Data_From_Sd_Temp;

/*--Get_Period_From_Details_Temp--------------------------------------------
|  o  Called from Compute_Allocation_Details in time phased pf scenarios.
|  o  This function returns the period data from mrp_atp_details_temp.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Period_From_Details_Temp(
        p_type                          IN      INTEGER,
        p_inv_item_id                   IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_scenario_id                   IN      NUMBER,
        p_level_id                      IN      NUMBER,
        p_record_type                   IN      PLS_INTEGER,
        p_session_id                    IN      NUMBER,
        x_atp_period                    OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
        x_return_status                 OUT     NOCOPY VARCHAR2
) IS

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('PROCEDURE Get_Period_From_Details_Temp');
        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_type = Demand_Priority THEN
                SELECT
                        final.col1,
                        final.col2,
                        SUM(final.col3),
                        SUM(final.col4),
                        SUM(final.col5),
                        SUM(final.col6),
                        SUM(final.col7),
                        SUM(final.col8),
                        p_inv_item_id,
                        p_org_id,
                        p_instance_id,
                        p_scenario_id,
                        p_level_id,
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
                        x_atp_period.Total_Bucketed_Demand_Quantity,
                        x_atp_period.Period_Quantity,
                        x_atp_period.Inventory_Item_Id,
                        x_atp_period.Organization_Id,
                        x_atp_period.Identifier1,
                        x_atp_period.Scenario_Id,
                        x_atp_period.Level,
                        x_atp_period.Period_End_Date,
                        x_atp_period.Backward_Forward_Quantity,
                        x_atp_period.Cumulative_Quantity
                FROM
                (
                SELECT DEMAND_CLASS                                                     col1, --Bug_3693892 added trunc
                        trunc(SUPPLY_DEMAND_DATE)                                              col2,
                        DECODE(SUPPLY_DEMAND_TYPE, 2,
                                DECODE(ORIGINAL_SUPPLY_DEMAND_TYPE,
                                                48, 0,
                                                ALLOCATED_QUANTITY),
                                0)                                                      col3, -- Allocated Supply Quantity
                        DECODE(SUPPLY_DEMAND_TYPE, 2,
                                DECODE(ORIGINAL_SUPPLY_DEMAND_TYPE,
                                                48,  ALLOCATED_QUANTITY,
                                                0),
                                0)                                                      col4, -- Supply Adjustment Quantity
                        DECODE(SUPPLY_DEMAND_TYPE, 2, ALLOCATED_QUANTITY, 0)            col5, -- Total Supply
                        DECODE(SUPPLY_DEMAND_TYPE, 1,
                                  DECODE(PF_DISPLAY_FLAG, 1,
                                    --Bug_3693892 added trunc
                                    DECODE(trunc(ORIGINAL_DEMAND_DATE), trunc(SUPPLY_DEMAND_DATE),
                                       ORIGINAL_DEMAND_QUANTITY, 0),
                                  0),
                               0)                                                       col6, -- Total Demand
                        DECODE(SUPPLY_DEMAND_TYPE, 1, ALLOCATED_QUANTITY, 0)            col7, -- Total Bucketed Demand
                        ALLOCATED_QUANTITY                                              col8  -- Period Quantity
                FROM
                        MRP_ATP_DETAILS_TEMP
                WHERE
                        SESSION_ID = p_session_id
                        AND RECORD_TYPE = p_record_type

                UNION ALL

                SELECT DEMAND_CLASS                                                     col1,
                       trunc(ORIGINAL_DEMAND_DATE)                                      col2, --Bug_3693892 added trunc
                        0                                                               col3, -- Allocated Supply Quantity
                        0                                                               col4, -- Supply Adjustment Quantity
                        0                                                               col5, -- Total Supply
                        ORIGINAL_DEMAND_QUANTITY                                        col6, -- Total Demand
                        0                                                               col7, -- Total Bucketed Demand
                        0                                                               col8  -- Period Quantity
                FROM
                        MRP_ATP_DETAILS_TEMP
                WHERE
                        SESSION_ID = p_session_id
                        AND RECORD_TYPE = p_record_type
                        AND SUPPLY_DEMAND_TYPE = 1
                        AND PF_DISPLAY_FLAG = 1
                        AND trunc(SUPPLY_DEMAND_DATE) <> trunc(ORIGINAL_DEMAND_DATE) --Bug_3693892 added trunc
                ) final
                GROUP BY
                        final.col1,
                        final.col2,
                        p_inv_item_id,
                        p_org_id,
                        p_instance_id,
                        p_scenario_id,
                        p_level_id
                ORDER BY
                        final.col1,
                        final.col2
                        ;
        ELSIF p_type = User_Defined_DC THEN
                SELECT
                        final.col1,
                        final.col2,
                        SUM(final.col3),
                        SUM(final.col4),
                        SUM(final.col5),
                        SUM(final.col6),
                        p_inv_item_id,
                        p_org_id,
                        p_instance_id,
                        p_scenario_id,
                        p_level_id,
                        null,
                        0,
                        0,
                        final.col7,
                        SUM(final.col8),
                        SUM(final.col9),
                        SUM(final.col10),
                        SUM(final.col11),
                        final.col12
                BULK COLLECT INTO
                        x_atp_period.Demand_Class,
                        x_atp_period.Period_Start_Date,
                        x_atp_period.Total_Supply_Quantity,
                        x_atp_period.Total_Demand_Quantity,
                        x_atp_period.Total_Bucketed_Demand_Quantity,
                        x_atp_period.Period_Quantity,
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
                        x_atp_period.Unalloc_Bucketed_Demand_Qty,
                        x_atp_period.Unallocated_Net_Quantity,
                        x_atp_period.Identifier4
                FROM
                (
                SELECT  DEMAND_CLASS                                                    col1,
                        trunc(SUPPLY_DEMAND_DATE)                                       col2, --Bug_3693892 added trunc
                        DECODE(SUPPLY_DEMAND_TYPE, 2, ALLOCATED_QUANTITY, 0)            col3,
                        DECODE(SUPPLY_DEMAND_TYPE, 1,
                                  DECODE(PF_DISPLAY_FLAG, 1,
                                    --Bug_3693892 added trunc
                                    DECODE(trunc(ORIGINAL_DEMAND_DATE), trunc(SUPPLY_DEMAND_DATE),
                                       ORIGINAL_DEMAND_QUANTITY, 0),
                                  0),
                               0)                                                       col4, -- Total Demand
                        DECODE(SUPPLY_DEMAND_TYPE, 1, ALLOCATED_QUANTITY, 0)            col5, -- Total Bucketed Demand
                        ALLOCATED_QUANTITY                                              col6,
                        IDENTIFIER2                                                     col7,
                        DECODE(SUPPLY_DEMAND_TYPE, 2, UNALLOCATED_QUANTITY, 0)          col8,
                        DECODE(SUPPLY_DEMAND_TYPE, 1,
                                  DECODE(PF_DISPLAY_FLAG, 1,
                                    --Bug_3693892 added trunc
                                    DECODE(trunc(ORIGINAL_DEMAND_DATE), trunc(SUPPLY_DEMAND_DATE),
                                       SUPPLY_DEMAND_QUANTITY, 0),
                                  0),
                               0)                                                       col9,  -- Unallocated Demand
                        DECODE(SUPPLY_DEMAND_TYPE, 1, UNALLOCATED_QUANTITY, 0)          col10, -- Unallocated Bucketed Demand
                        UNALLOCATED_QUANTITY                                            col11, -- Unallocated Net
                        IDENTIFIER4                                                     col12
                FROM    MRP_ATP_DETAILS_TEMP
                WHERE   SESSION_ID = p_session_id
                AND     RECORD_TYPE = p_record_type

                UNION ALL

                SELECT  DEMAND_CLASS                                                    col1,
                        trunc(ORIGINAL_DEMAND_DATE)                                     col2, --Bug_3693892 added trunc
                        0                                                               col3,
                        ORIGINAL_DEMAND_QUANTITY                                        col4,  -- Total Demand
                        0                                                               col5,
                        0                                                               col6,
                        IDENTIFIER2                                                     col7,
                        0                                                               col8,  -- Period Quantity
                        SUPPLY_DEMAND_QUANTITY                                          col9,
                        0                                                               col10,
                        0                                                               col11,
                        IDENTIFIER4                                                     col12
                FROM
                        MRP_ATP_DETAILS_TEMP
                WHERE
                        SESSION_ID = p_session_id
                        AND RECORD_TYPE = p_record_type
                        AND SUPPLY_DEMAND_TYPE = 1
                        AND PF_DISPLAY_FLAG = 1
                        AND trunc(SUPPLY_DEMAND_DATE) <> trunc(ORIGINAL_DEMAND_DATE) --Bug_3693892 added trunc
                ) final
                GROUP BY
                        final.col1,
                        final.col2,
                        p_inv_item_id,
                        p_org_id,
                        p_instance_id,
                        p_scenario_id,
                        p_level_id,
                        final.col7,
                        final.col12
                ORDER BY
                        final.col7 asc,
                        final.col12 desc,
                        final.col1 asc,
                        final.col2
                        ;
        ELSIF p_type = User_Defined_CC THEN
                SELECT
                        final.col1,
                        final.col2,
                        SUM(final.col3),
                        SUM(final.col4),
                        SUM(final.col5),
                        SUM(final.col6),
                        p_inv_item_id,
                        p_org_id,
                        p_instance_id,
                        p_scenario_id,
                        p_level_id,
                        null,
                        0,
                        0,
                        final.col7,
                        final.col8,
                        final.col9,
                        final.col10,
                        SUM(final.col11),
                        SUM(final.col12),
                        SUM(final.col13),
                        SUM(final.col14),
                        final.col15
                BULK COLLECT INTO
                        x_atp_period.Demand_Class,
                        x_atp_period.Period_Start_Date,
                        x_atp_period.Total_Supply_Quantity,
                        x_atp_period.Total_Demand_Quantity,
                        x_atp_period.Total_Bucketed_Demand_Quantity,
                        x_atp_period.Period_Quantity,
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
                        x_atp_period.Unalloc_Bucketed_Demand_Qty,
                        x_atp_period.Unallocated_Net_Quantity,
                        x_atp_period.Customer_Site_Id
                FROM
                (
                SELECT  DEMAND_CLASS                                                    col1,  --Bug_3693892 added trunc
                        trunc(SUPPLY_DEMAND_DATE)                                              col2,
                        DECODE(SUPPLY_DEMAND_TYPE, 2, ALLOCATED_QUANTITY, 0)            col3,
                        DECODE(SUPPLY_DEMAND_TYPE, 1,
                                  DECODE(PF_DISPLAY_FLAG, 1,
                                    --Bug_3693892 added trunc
                                    DECODE(trunc(ORIGINAL_DEMAND_DATE), trunc(SUPPLY_DEMAND_DATE),
                                       ORIGINAL_DEMAND_QUANTITY, 0),
                                  0),
                               0)                                                       col4, -- Total Demand
                        DECODE(SUPPLY_DEMAND_TYPE, 1, ALLOCATED_QUANTITY, 0)            col5, -- Total Bucketed Demand
                        ALLOCATED_QUANTITY                                              col6,
                        IDENTIFIER2                                                     col7,
                        IDENTIFIER4                                                     col8,
                        CLASS                                                           col9,
                        CUSTOMER_ID                                                     col10,
                        DECODE(SUPPLY_DEMAND_TYPE, 2, UNALLOCATED_QUANTITY, 0)          col11,
                        DECODE(SUPPLY_DEMAND_TYPE, 1,
                                  DECODE(PF_DISPLAY_FLAG, 1,
                                    --Bug_3693892 added trunc
                                    DECODE(trunc(ORIGINAL_DEMAND_DATE), trunc(SUPPLY_DEMAND_DATE),
                                       SUPPLY_DEMAND_QUANTITY, 0),
                                  0),
                               0)                                                       col12, -- Unallocated Demand
                        DECODE(SUPPLY_DEMAND_TYPE, 1, UNALLOCATED_QUANTITY, 0)          col13, -- Unallocated Bucketed Demand
                        UNALLOCATED_QUANTITY                                            col14, -- Unallocated Net
                        CUSTOMER_SITE_ID                                                col15
                FROM    MRP_ATP_DETAILS_TEMP
                WHERE   SESSION_ID = p_session_id
                AND     RECORD_TYPE = p_record_type

                UNION ALL

                SELECT  DEMAND_CLASS                                                    col1,
                        trunc(ORIGINAL_DEMAND_DATE)                                     col2, --Bug_3693892 added trunc
                        0                                                               col3,
                        ORIGINAL_DEMAND_QUANTITY                                        col4,  -- Total Demand
                        0                                                               col5,
                        0                                                               col6,
                        IDENTIFIER2                                                     col7,
                        IDENTIFIER4                                                     col8,
                        CLASS                                                           col9,
                        CUSTOMER_ID                                                     col10,
                        0                                                               col11,
                        SUPPLY_DEMAND_QUANTITY                                          col12,
                        0                                                               col13,
                        0                                                               col14,
                        CUSTOMER_SITE_ID                                                col15
                FROM
                        MRP_ATP_DETAILS_TEMP
                WHERE
                        SESSION_ID = p_session_id
                        AND RECORD_TYPE = p_record_type
                        AND SUPPLY_DEMAND_TYPE = 1
                        AND PF_DISPLAY_FLAG = 1
                        AND trunc(SUPPLY_DEMAND_DATE) <> trunc(ORIGINAL_DEMAND_DATE)  --Bug_3693892 added trunc
                ) final
                GROUP BY
                        final.col1,
                        final.col2,
                        p_inv_item_id,
                        p_org_id,
                        p_instance_id,
                        p_scenario_id,
                        p_level_id,
                        final.col7,
                        final.col8,
                        final.col9,
                        final.col10,
                        final.col15
                ORDER BY
                        trunc(final.col7,-3),        -- Customer class priority
                        final.col9,                  -- Customer class
                        trunc(final.col7,-2),        -- Customer priority
                        final.col10,                 -- Customer
                        final.col7,                  -- Customer site priority
                        final.col15,
                        final.col2
                        ;
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Period_From_Details_Temp: ' || 'Error code:' || to_char(sqlcode));
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Period_From_Details_Temp;

/*--Get_Pf_Atp_Item_Id------------------------------------------------------
|  o  This function returns the source id of the family item if the item
|       passed belongs to an atpable family.
|  o  Otherwise it returns the same item id.
+-------------------------------------------------------------------------*/
FUNCTION Get_Pf_Atp_Item_Id(
        p_instance_id            IN  NUMBER,
        p_plan_id                IN  NUMBER,
        p_inventory_item_id      IN  NUMBER,
        p_organization_id        IN  NUMBER
)
RETURN NUMBER
IS
        l_pf_atp_item_id      NUMBER;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin function Get_Pf_Atp_Item_Id ********');
                msc_sch_wb.atp_debug('Get_Pf_Atp_Item_Id: ' ||  'p_instance_id = ' ||to_char(p_instance_id));
                msc_sch_wb.atp_debug('Get_Pf_Atp_Item_Id: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Get_Pf_Atp_Item_Id: ' ||  'p_inventory_item_id = ' ||to_char(p_inventory_item_id));
                msc_sch_wb.atp_debug('Get_Pf_Atp_Item_Id: ' ||  'p_organization_id = ' ||to_char(p_organization_id));
        END IF;

        SELECT  DECODE(i2.bom_item_type,
                  5, DECODE(i2.atp_flag,
                     'N', i1.sr_inventory_item_id,
                     i2.sr_inventory_item_id),
                  i1.sr_inventory_item_id
                )
        INTO    l_pf_atp_item_id
        FROM    msc_system_items i2,
                msc_system_items i1
        WHERE   i1.sr_inventory_item_id = p_inventory_item_id
        AND     i1.organization_id = p_organization_id
        AND     i1.plan_id = p_plan_id
        AND     i1.sr_instance_id = p_instance_id
        AND     i2.inventory_item_id = DECODE(i1.product_family_id,
                                              NULL, i1.inventory_item_id,
                                              -23453, i1.inventory_item_id,
                                              i1.product_family_id)
        AND     i2.organization_id = i1.organization_id
        AND     i2.sr_instance_id = i1.sr_instance_id
        AND     i2.plan_id = i1.plan_id;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Pf_Atp_Item_Id: ' ||  'PF Item Id = ' ||to_char(l_pf_atp_item_id));
                msc_sch_wb.atp_debug('*********End function Get_Pf_Atp_Item_Id ********');
        END IF;

        return l_pf_atp_item_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
        return p_inventory_item_id;

END Get_Pf_Atp_Item_Id;

/*--Get_Atf_Date------------------------------------------------------------
|  o  This function returns the ATF date for item-org-instance-plan
|       combination passed.
+-------------------------------------------------------------------------*/
FUNCTION Get_Atf_Date(
        p_instance_id        IN NUMBER,
        p_inventory_item_id  IN NUMBER,
        p_organization_id    IN NUMBER,
        p_plan_id            IN NUMBER
)
RETURN DATE
IS
        l_atf_date      DATE;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Begin Get_Atf_Date');
                msc_sch_wb.atp_debug('Get_Atf_Date : p_instance_id = ' || p_instance_id);
                msc_sch_wb.atp_debug('Get_Atf_Date : p_inventory_item_id = ' || p_inventory_item_id);
                msc_sch_wb.atp_debug('Get_Atf_Date : p_organization_id = ' || p_organization_id);
                msc_sch_wb.atp_debug('Get_Atf_Date : p_plan_id = ' || p_plan_id);
        END IF;

        SELECT i.aggregate_time_fence_date
        INTO   l_atf_date
        FROM   msc_system_items i
        WHERE  i.plan_id = p_plan_id
        AND    i.sr_instance_id = p_instance_id
        AND    i.organization_id = p_organization_id
        AND    i.sr_inventory_item_id = p_inventory_item_id;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Atf_Date : ATF Date = ' || l_atf_date);
        END IF;

        return l_atf_date;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return null;

END Get_Atf_Date;

/*--Get_Atf_Days------------------------------------------------------------
|  o  This function returns the ATF days for item-org-instance-plan
|       combination passed.
+-------------------------------------------------------------------------*/
FUNCTION Get_Atf_Days(
        p_instance_id        IN NUMBER,
        p_inventory_item_id  IN NUMBER,
        p_organization_id    IN NUMBER
)
RETURN NUMBER
IS
        l_atf_days      NUMBER;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Begin Get_Atf_Days');
                msc_sch_wb.atp_debug('Get_Atf_Days : p_instance_id = ' || p_instance_id);
                msc_sch_wb.atp_debug('Get_Atf_Days : p_inventory_item_id = ' || p_inventory_item_id);
                msc_sch_wb.atp_debug('Get_Atf_Days : p_organization_id = ' || p_organization_id);
        END IF;

        SELECT  DECODE(r.aggregate_time_fence_code,
                        1, NULL,
                        2, i2.demand_time_fence_days,
                        3, i2.planning_time_fence_days,
                        4, r.aggregate_time_fence
                      )
        INTO    l_atf_days
        FROM    msc_system_items i2,
                msc_system_items i1,
                msc_atp_rules r,
                msc_trading_partners tp
        WHERE   i1.inventory_item_id = p_inventory_item_id
        AND     i1.organization_id = p_organization_id
        AND     i1.plan_id = -1
        AND     i1.sr_instance_id = p_instance_id
        AND     i2.inventory_item_id = NVL(i1.product_family_id,
                                              i1.inventory_item_id)
        AND     i2.organization_id = i1.organization_id
        AND     i2.sr_instance_id = i1.sr_instance_id
        AND     i2.plan_id = i1.plan_id
        AND     i2.bom_item_type = 5
        AND     i2.atp_flag = 'Y'
        AND     tp.sr_tp_id = i2.organization_id
        AND     tp.sr_instance_id = i2.sr_instance_id
        AND     tp.partner_type = 3
        AND     r.sr_instance_id = tp.sr_instance_id
        AND     r.rule_id = NVL(i2.atp_rule_id, tp.default_atp_rule_id);

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Atf_Days : ATF Days = ' || l_atf_days);
        END IF;

        return l_atf_days;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Atf_Days : ATF Days = ' || l_atf_days);
                END IF;
                return null;

END Get_Atf_Days;

/*--Get_Family_Item_Info----------------------------------------------------
|  o  This procedure returns the source id, destination id and ATF date
|       of the family item if the item passed belongs to an atpable family.
+-------------------------------------------------------------------------*/
PROCEDURE Get_Family_Item_Info(
        p_instance_id	        IN      NUMBER,
        p_plan_id               IN      NUMBER,
        p_inventory_item_id     IN      NUMBER,
        p_organization_id       IN      NUMBER,
        p_family_id             OUT     NOCOPY NUMBER,
        p_sr_family_id          OUT     NOCOPY NUMBER,
        p_atf_date              OUT     NOCOPY DATE,
        --bug3700564 added family name
        p_family_name           OUT     NOCOPY VARCHAR2,
        x_return_status         OUT     NOCOPY VARCHAR2
)
IS


BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Get_Family_Item_Info ********');
                msc_sch_wb.atp_debug('Get_Family_Item_Info: ' ||  'p_instance_id = ' ||to_char(p_instance_id));
                msc_sch_wb.atp_debug('Get_Family_Item_Info: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
                msc_sch_wb.atp_debug('Get_Family_Item_Info: ' ||  'p_inventory_item_id = ' ||to_char(p_inventory_item_id));
                msc_sch_wb.atp_debug('Get_Family_Item_Info: ' ||  'p_organization_id = ' ||to_char(p_organization_id));
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT DECODE(i2.bom_item_type,
                 5, DECODE(i2.atp_flag,
                     'N', i1.inventory_item_id,
                     i2.inventory_item_id),
                 i1.inventory_item_id
               ),
               DECODE(i2.bom_item_type,
                 5, DECODE(i2.atp_flag,
                     'N', i1.sr_inventory_item_id,
                     i2.sr_inventory_item_id),
                 i1.sr_inventory_item_id
               ),
               i1.aggregate_time_fence_date,
               i2.item_name --bug3700564
        INTO   p_family_id,
               p_sr_family_id,
               p_atf_date,
               p_family_name --bug3700564
        FROM   msc_system_items i2,
               msc_system_items i1
        WHERE  i1.inventory_item_id = p_inventory_item_id
        AND    i1.organization_id = p_organization_id
        AND    i1.plan_id = p_plan_id
        AND    i1.sr_instance_id = p_instance_id
        AND    i2.inventory_item_id = DECODE(i1.product_family_id,
                                             NULL, i1.inventory_item_id,
                                             -23453, i1.inventory_item_id,
                                             i1.product_family_id)
        AND    i2.organization_id = i1.organization_id
        AND    i2.sr_instance_id = i1.sr_instance_id
        AND    i2.plan_id = i1.plan_id;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Family_Item_Info: ' ||  'ATF Date = ' ||to_char(p_atf_date));
                msc_sch_wb.atp_debug('*********End procedure Get_Family_Item_Info ********');
        END IF;

EXCEPTION

-- bug 5574547
	WHEN NO_DATA_FOUND THEN
	SELECT i1.inventory_item_id,
	       i1.sr_inventory_item_id,
	       i1.aggregate_time_fence_date,
               i1.item_name
        INTO   p_family_id,
               p_sr_family_id,
               p_atf_date,
               p_family_name
        FROM   msc_system_items i1
        WHERE  i1.inventory_item_id = p_inventory_item_id
        AND    i1.organization_id = p_organization_id
        AND    i1.plan_id = p_plan_id
        AND    i1.sr_instance_id = p_instance_id;

		    IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Family_Item_Info: ' || 'Passing back the values originally sent to API');
        END IF;


        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Family_Item_Info: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Family_Item_Info;

/*--Get_PF_Plan_Info----------------------------------------------------------
|  o  This procedure finds the plan to be used in PF scenarios
|  o  Logic to select plan is as follows:
|       -
+---------------------------------------------------------------------------*/
PROCEDURE Get_PF_Plan_Info(
        p_instance_id	        IN      NUMBER,
        p_member_item_id        IN      NUMBER,
        p_family_item_id        IN      NUMBER,
        p_org_id                IN      NUMBER,
        p_demand_class          IN      VARCHAR2,
        p_atf_date              OUT     NOCOPY DATE,
        p_error_code            OUT     NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        p_parent_plan_id        IN      NUMBER DEFAULT NULL --bug3510475
) IS
        -- local variables


BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********Begin procedure Get_PF_Plan_Info ********');
                msc_sch_wb.atp_debug('p_instance_id := ' || p_instance_id);
                msc_sch_wb.atp_debug('p_member_item_id := ' || p_member_item_id);
                msc_sch_wb.atp_debug('p_family_item_id := ' || p_family_item_id);
                msc_sch_wb.atp_debug('p_org_id := ' || p_org_id);
                msc_sch_wb.atp_debug('p_demand_class := ' || p_demand_class);

        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* First get member item's plan*/
        MSC_ATP_PROC.get_global_plan_info(
                p_instance_id,
                p_member_item_id,
                p_org_id,
                p_demand_class,
                p_parent_plan_id --bug3510475
        );

        IF (MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id = -300) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'ATP Downtime');
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;
                MSC_ATP_PVT.G_DOWNTIME_HIT := 'Y';
                p_error_code := MSC_ATP_PVT.PLAN_DOWN_TIME;
                RAISE NO_DATA_FOUND;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id = '||MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id);
        END IF;

        -- ATP4drp begin
        IF  NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) = 5 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
               msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'PF and Allocated ATP not applicable for DRP plans');
               msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'ATF date will not be obtained.');
               msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
            END IF;
        ELSIF (p_family_item_id <> p_member_item_id) THEN
            -- plan is not a DRP plan
        -- ATP4drp end
        /* Now Get ATF Date in PF case to check whether this is time phased atp case or old PF case*/
                p_atf_date := MSC_ATP_PF.Get_Atf_Date(
                                  p_instance_id,
                                  p_member_item_id,
                                  p_org_id,
                                  MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id
                              );

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'ATF Date = '||p_atf_date);
                END IF;

                /* check if it is time phased atp scenario, if yes then we are done
                   else look for family item's plan*/
                IF p_atf_date is not null THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || '*** Time Phased ATP Scenario *** ');
                        END IF;
                ELSE
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Schedule: ' || '*** Product Family(non-time phased) ATP Scenario *** ');
                                msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'Now trying to find old plan for family item...');
                        END IF;

                        MSC_ATP_PROC.get_global_plan_info(
                                p_instance_id,
                                p_family_item_id,
                                p_org_id,
                                p_demand_class,
                                p_parent_plan_id  --bug3510475
                        );

                        IF (MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id = -300) THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'ATP Downtime');
                                END IF;

                                x_return_status := FND_API.G_RET_STS_ERROR;
                                MSC_ATP_PVT.G_DOWNTIME_HIT := 'Y';
                                p_error_code := MSC_ATP_PVT.PLAN_DOWN_TIME;
                                RAISE NO_DATA_FOUND;
                        END IF;
                END IF;
        ELSE
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || '*** Regular PDS ATP Scenario *** ');
                END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('*********End of procedure Get_PF_Plan_Info ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'Exception: ' || sqlerrm);
                        msc_sch_wb.atp_debug('Get_PF_Plan_Info: ' || 'Error code:' || to_char(sqlcode));
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Get_PF_Plan_Info;

/*--Populate_ATF_Dates--------------------------------------------------------
|  o  This procedure populate ATF dates for:
|       -  All atpable family items having ATF setup.
|       -  All atpable member items belonging to the above atpable families.
|  o  Returns number of member items whose ATF dates were populated.
+---------------------------------------------------------------------------*/
PROCEDURE Populate_ATF_Dates(
        p_plan_id          		IN	NUMBER,
        x_member_count                  OUT     NOCOPY NUMBER,
        x_return_status                 OUT	NOCOPY VARCHAR2
) IS
        -- local variables
--bug3663487 start
l_organization_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_sr_instance_id        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_inventory_item_id     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atf_date              mrp_atp_pub.date_arr := mrp_atp_pub.date_arr();
j                       NUMBER;
k                       NUMBER;
--bug3663487 end

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('*********Begin procedure Populate_ATF_Dates ********');
                msc_util.msc_log('Populate_ATF_Dates: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --bug3663487 start SQL ID 9426916 and 9426907
        SELECT  c2.calendar_date,i2.organization_id,i2.sr_instance_id,i2.inventory_item_id
        BULK COLLECT INTO   l_atf_date,l_organization_id,l_sr_instance_id,l_inventory_item_id
        FROM    msc_plans mp,
                msc_plan_organizations po,
                msc_system_items i2,
                msc_trading_partners tp,
                msc_atp_rules r,
                msc_calendar_dates c1,
            	msc_calendar_dates c2
        WHERE   mp.plan_id = p_plan_id
        AND	po.plan_id = mp.plan_id
        AND	i2.organization_id = po.organization_id
        AND     i2.sr_instance_id = po.sr_instance_id
        AND     i2.plan_id = po.plan_id
        AND     i2.bom_item_type = 5
        AND     i2.atp_flag = 'Y'
        AND     tp.sr_tp_id = i2.organization_id
        AND     tp.sr_instance_id = i2.sr_instance_id
        AND     tp.partner_type = 3
        AND     r.sr_instance_id = tp.sr_instance_id
        AND     r.rule_id = NVL(i2.atp_rule_id, tp.default_atp_rule_id)
        AND     c1.sr_instance_id = r.sr_instance_id
        AND     c1.calendar_date = trunc(mp.plan_start_date)
        AND     c1.calendar_code = tp.calendar_code
        AND     c1.exception_set_id = -1
        AND     c2.sr_instance_id = c1.sr_instance_id
        AND     c2.seq_num = c1.next_seq_num +
                                        DECODE(r.aggregate_time_fence_code,
                                                1, NULL,
                                                2, i2.demand_time_fence_days,
                                                3, i2.planning_time_fence_days,
                                                4, r.aggregate_time_fence
                                              )
        AND    c2.calendar_code = c1.calendar_code
        AND    c2.exception_set_id = -1;

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Populate_ATF_Dates: ' ||  'l_inventory_item_id.COUNT = ' ||l_inventory_item_id.COUNT);
        END IF;

        IF l_inventory_item_id IS NOT NULL AND l_inventory_item_id.COUNT > 0 THEN

         FORALL j IN l_inventory_item_id.first.. l_inventory_item_id.last
         UPDATE  msc_system_items i
         SET     aggregate_time_fence_date = l_atf_date(j)
         WHERE   i.plan_id = p_plan_id
         AND     i.ORGANIZATION_ID = l_organization_id(j)
         AND     i.SR_INSTANCE_ID = l_sr_instance_id(j)
         AND     i.inventory_item_id = l_inventory_item_id(j);

         FORALL k IN l_inventory_item_id.first.. l_inventory_item_id.last
         UPDATE  msc_system_items i
         SET     aggregate_time_fence_date = l_atf_date(k)
         WHERE   i.plan_id = p_plan_id
         AND     i.ORGANIZATION_ID = l_organization_id(k)
         AND     i.SR_INSTANCE_ID = l_sr_instance_id(k)
         AND     i.product_family_id = l_inventory_item_id(k);

         x_member_count := SQL%ROWCOUNT;

        END IF;
        --bug3663487 end

        ----bug3663487 code commented for Performance fix
        /*
        -- populate ATF date for PF items
        UPDATE  msc_system_items i
        SET     aggregate_time_fence_date =
                       (SELECT  c2.calendar_date
                        FROM    msc_calendar_dates c2,
                                msc_calendar_dates c1,
                                msc_atp_rules r,
                                msc_trading_partners tp,
                                msc_plans mp,
                                msc_system_items i2
                        WHERE   i2.inventory_item_id = i.inventory_item_id
                        AND     i2.organization_id = i.organization_id
                        AND     i2.sr_instance_id = i.sr_instance_id
                        AND     i2.plan_id = -1
                        AND     tp.sr_tp_id = i2.organization_id
                        AND     tp.sr_instance_id = i2.sr_instance_id
                        AND     tp.partner_type = 3
                        AND     mp.plan_id = p_plan_id
                        AND     r.sr_instance_id = tp.sr_instance_id
                        AND     r.rule_id = NVL(i2.atp_rule_id, tp.default_atp_rule_id)
                        AND     c1.sr_instance_id = r.sr_instance_id
                        AND     c1.calendar_date = mp.plan_start_date
                        AND     c1.calendar_code = tp.calendar_code
                        AND     c1.exception_set_id = -1
                        AND     c2.sr_instance_id = c1.sr_instance_id
                        AND     c2.seq_num = c1.next_seq_num +
                                        DECODE(r.aggregate_time_fence_code,
                                                1, NULL,
                                                2, i2.demand_time_fence_days,
                                                3, i2.planning_time_fence_days,
                                                4, r.aggregate_time_fence
                                              )
                        AND    c2.calendar_code = c1.calendar_code
                        AND    c2.exception_set_id = -1
                       )
        WHERE   i.plan_id = p_plan_id
        AND     i.bom_item_type = 5
        AND     i.atp_flag = 'Y';

        -- populate ATF date for atpable member items
        UPDATE  msc_system_items i
        SET     aggregate_time_fence_date =
                       (SELECT  i2.aggregate_time_fence_date
                        FROM    msc_system_items i2
                        WHERE   i2.inventory_item_id = i.product_family_id
                        AND     i2.sr_instance_id = i.sr_instance_id
                        AND     i2.organization_id = i.organization_id
                        AND     i2.plan_id = i.plan_id
                        AND     i2.aggregate_time_fence_date is not null
                       )
        WHERE   i.plan_id = p_plan_id
        AND     i.inventory_item_id <> DECODE(i.product_family_id,
                                              NULL, i.inventory_item_id,
                                              -23453, i.inventory_item_id,
                                              i.product_family_id)
        AND     i.bom_item_type <> 5
        AND     i.atp_flag = 'Y'
        AND     EXISTS (SELECT  1
                        FROM    msc_system_items i2
                        WHERE   i2.inventory_item_id = i.product_family_id
                        AND     i2.sr_instance_id = i.sr_instance_id
                        AND     i2.organization_id = i.organization_id
                        AND     i2.plan_id = i.plan_id
                        AND     i2.aggregate_time_fence_date is not null
                       );
        */

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Populate_ATF_Dates: ' ||  'Member Count = ' ||to_char(x_member_count));
                msc_util.msc_log('*********End of procedure Populate_ATF_Dates ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Populate_ATF_Dates: ' || 'Exception: ' || sqlerrm);
                        msc_util.msc_log('Populate_ATF_Dates: ' || 'Error code:' || to_char(sqlcode));
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Populate_ATF_Dates;

/*--Calculate_Alloc_Percentages-----------------------------------------------
|  o  This procedure calculate allocation percentages for:
|       -  All end demands for atpable items.
|  o  Populate temp table with this information
+---------------------------------------------------------------------------*/
PROCEDURE Calculate_Alloc_Percentages(
        p_plan_id          		IN	NUMBER,
        x_return_status                 OUT	NOCOPY VARCHAR2
) IS
        -- local variables
        l_sysdate                       DATE;
        i                               NUMBER;
        l_plan_id                       NUMBER;
        l_ret_code			NUMBER;
        l_summary_flag			NUMBER;
        l_user_id                       NUMBER;
        dummy1                          VARCHAR2(10);
        dummy2                          VARCHAR2(10);
        l_alloc_atp                     VARCHAR2(1);
        l_applsys_schema                VARCHAR2(10);
        l_err_msg			VARCHAR2(1000);
        l_ind_tbspace                   VARCHAR2(30);
        l_insert_stmt                   VARCHAR2(8000);
        l_msc_schema                    VARCHAR2(30);
        l_other_dc                      VARCHAR2(30) := '-1';
        l_partition_name                VARCHAR2(30);
        l_share_partition   		VARCHAR2(1);
        l_sql_stmt                      VARCHAR2(300);
        l_sql_stmt_1                    VARCHAR2(16000);
        l_table_name			VARCHAR2(30);
        l_tbspace                       VARCHAR2(30);
        l_temp_table			VARCHAR2(30);
        l_plan_name                     varchar2(10);
        cur_handler			NUMBER;
        rows_processed			NUMBER;
        l_hash_size			NUMBER := -1;
        l_sort_size			NUMBER := -1;
        l_parallel_degree		NUMBER := 1;
        l_excess_supply_by_dc           VARCHAR2(1);
        l_return_status                 VARCHAR2(1);


BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('*********Begin procedure Calculate_Alloc_Percentages ********');
                msc_util.msc_log('Calculate_Alloc_Percentages: ' ||  'p_plan_id = ' ||to_char(p_plan_id));
        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* populate allocated quantity for planned order at product family that are blown down as production forecasts*/
        insert into msc_alloc_temp(
                transaction_id,
                demand_class,
                supply_demand_quantity
        )
        (select sup.transaction_id,
                decode(d1.inventory_item_id, NULL, '-2', d1.demand_class),
                sum(peg1.allocated_quantity)
         from
                (select distinct d.disposition_id transaction_id
                 from   msc_demands d,
                        msc_system_items msi
                 where  msi.plan_id = p_plan_id
                 and    msi.bom_item_type <> 5
                 and    NVL(msi.product_family_id, -23453) <> -23453 -- Bug 3629191
                 --and    msi.product_family_id is not null
                 and    msi.atp_flag = 'Y'
                 and    d.inventory_item_id = msi.inventory_item_id
                 and    d.organization_id = msi.organization_id
                 and    d.sr_instance_id = msi.sr_instance_id
                 and    d.plan_id = msi.plan_id
                 and    d.origination_type = 22
                ) sup,
                msc_full_pegging peg1,
                msc_demands d1
         where  peg1.plan_id = p_plan_id
         and    peg1.pegging_id = peg1.end_pegging_id
         and    peg1.transaction_id = sup.transaction_id
         and    d1.plan_id (+) = peg1.plan_id
         and    d1.inventory_item_id (+) = peg1.inventory_item_id
         and    d1.organization_id (+) = peg1.organization_id
         and    d1.sr_instance_id (+) = peg1.sr_instance_id
         and    d1.demand_id (+) = peg1.demand_id
         and    d1.origination_type (+) not in (6, 10, 30)
         group by
                sup.transaction_id,
                decode(d1.inventory_item_id, NULL, '-2', d1.demand_class)
        );

        -- update allocation percentages
        --changed update statement for bug3387166
       /* update msc_alloc_temp mat1
        set    mat1.allocation_percent =
                        mat1.supply_demand_quantity/(select sum(mat2.supply_demand_quantity)
                                                     from   msc_alloc_temp mat2
                                                     where  mat2.transaction_id = mat1.transaction_id
                                                     ); */
        update msc_alloc_temp mat1
        set    mat1.allocation_percent =
                        (select mat1.supply_demand_quantity/sum(mat2.supply_demand_quantity)
                          from   msc_alloc_temp mat2
                          where  mat2.transaction_id = mat1.transaction_id
                          );

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Calculate_Alloc_Percentages: ' ||  'Row Count in MSC_ALLOC_TEMP = '|| SQL%ROWCOUNT);
                msc_util.msc_log('*********End of procedure Calculate_Alloc_Percentages ********');
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Calculate_Alloc_Percentages: ' || 'Exception: ' || sqlerrm);
                        msc_util.msc_log('Calculate_Alloc_Percentages: ' || 'Error code:' || to_char(sqlcode));
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Calculate_Alloc_Percentages;

/*--Pf_Post_Plan_Proc-----------------------------------------------------------------
|  o  This procedure is called from Load_Plan_Sd procedure for ATP Post
|       Plan Processing (pre-allocation, supplies rollup and bucketing)
|       only if there is atleast one item having ATF date not null.
|  o  It calls following private procedures:
|       -  Prepare_Demands_Stmt1 - to prepare demands statement for:
|            :  Pre-allocation and bucketing for demands pegged to excess
|                 if it is demand priority AATP case.
|            :  Bucketing if it is not demand priority AATP case.
|       -  Prepare_Demands_Stmt2 - to prepare demands statement for pre-allocation
|            and bucketing for demands not pegged to excess if it is demand
|            priority AATP case.
|       -  Prepare_Supplies_Stmt1 - to prepare supplies statement for:
|            :  Preallocation and rollup for supplies pegged to excess/safety stock
|                 if it is demand priority AATP case.
|            :  Rollup if it is not demand priority AATP case.
|       -  Prepare_Supplies_Stmt2 - to prepare supplies statement for
|            preallocation and rollup for supplies not pegged to excess/safety stock
|            if it is demand priority AATP case.
|  o  Calls private procedure Update_Pf_Display_Flag procedure to update
|       Pf_Display_Flag to handle scenario when a demand on one side of ATF is
|       satisfied totally from supplies on the other side of ATF.
+-----------------------------------------------------------------------------------*/
PROCEDURE Pf_Post_Plan_Proc(
	ERRBUF                          OUT     NOCOPY VARCHAR2,
	RETCODE                         OUT     NOCOPY NUMBER,
	p_plan_id                       IN 	NUMBER,
	p_demand_priority               IN      VARCHAR2
)
IS
        -- local variables
        G_ERROR				NUMBER := 1;
        G_SUCCESS			NUMBER := 0;
        MAXVALUE                        CONSTANT NUMBER := 999999;
        l_retval                        BOOLEAN;
        l_sysdate                       DATE;
        i                               NUMBER;
        l_alloc_method                  NUMBER;
        l_class_hrchy                   NUMBER;
        l_count				NUMBER;
        l_inv_ctp                       NUMBER;
        l_plan_id                       NUMBER;
        l_ret_code			NUMBER;
        l_summary_flag			NUMBER;
        l_user_id                       NUMBER;
        dummy1                          VARCHAR2(10);
        dummy2                          VARCHAR2(10);
        l_alloc_atp                     VARCHAR2(1);
        l_applsys_schema                VARCHAR2(10);
        l_err_msg			VARCHAR2(1000);
        l_ind_tbspace                   VARCHAR2(30);
        l_insert_stmt                   VARCHAR2(8000);
        l_msc_schema                    VARCHAR2(30);
        l_other_dc                      VARCHAR2(30) := '-1';
        l_partition_name                VARCHAR2(30);
        l_share_partition   		VARCHAR2(1);
        l_sql_stmt                      VARCHAR2(300);
        l_sql_stmt_1                    VARCHAR2(16000);
        l_table_name			VARCHAR2(30);
        l_tbspace                       VARCHAR2(30);
        l_temp_table			VARCHAR2(30);
        atp_summ_tab 			MRP_ATP_PUB.char30_arr :=
                                                MRP_ATP_PUB.char30_arr(
                                                        'ALLOC_DEMANDS',
                                                        'ALLOC_SUPPLIES'
                                                );
        l_plan_name                     varchar2(10);
        cur_handler			NUMBER;
        rows_processed			NUMBER;
        l_hash_size			NUMBER := -1;
        l_sort_size			NUMBER := -1;
        l_parallel_degree		NUMBER := 1;
        l_excess_supply_by_dc           VARCHAR2(1);
        l_return_status                 VARCHAR2(1);
        l_alloc_temp_table              VARCHAR2(30);
        l_yes                           VARCHAR2(1) := 'Y';
        l_excess_dc                     VARCHAR2(30) := '-2';

BEGIN
        msc_util.msc_log('*********Begin procedure Pf_Post_Plan_Proc ********');

        --project atp
        l_excess_supply_by_dc := NVL(FND_PROFILE.VALUE('MSC_EXCESS_SUPPLY_BY_DC'), 'N');
        msc_util.msc_log('l_excess_supply_by_dc := ' || l_excess_supply_by_dc);

        BEGIN
                msc_util.msc_log('Calling custom procedure MSC_ATP_CUSTOM.Custom_Pre_Allocation...');
                MSC_ATP_CUSTOM.Custom_Pre_Allocation(p_plan_id);
                msc_util.msc_log('End MSC_ATP_CUSTOM.Custom_Pre_Allocation.');
        EXCEPTION
                WHEN OTHERS THEN
                        msc_util.msc_log('Error in custom procedure call');
                        msc_util.msc_log('Error Code: '|| sqlerrm);
        END;
        --project atp

        msc_util.msc_log('begin Loading pre-allocation demand/supply data for plan: ' || p_plan_id);
        RETCODE := G_SUCCESS;

        l_share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');

        msc_util.msc_log('l_share_partition := ' || l_share_partition);

        SELECT NVL(summary_flag,1), compile_designator
        INTO   l_summary_flag, l_plan_name
        FROM   msc_plans
        WHERE  plan_id = p_plan_id;

        IF NVL(l_summary_flag,1) = 2 THEN
                msc_util.msc_log('Another session is running post-plan allocation program for this plan');
                RETCODE :=  G_ERROR;
                RETURN;
        END IF;

        l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);
        SELECT  a.oracle_username,
                sysdate,
                FND_GLOBAL.USER_ID
        INTO    l_msc_schema,
                l_sysdate,
                l_user_id
        FROM    fnd_oracle_userid a,
                fnd_product_installations b
        WHERE   a.oracle_id = b.oracle_id
        AND     b.application_id = 724;

        FOR i in 1..atp_summ_tab.count LOOP

                l_table_name := 'MSC_' || atp_summ_tab(i);

                IF (l_share_partition = 'Y') THEN
                        l_plan_id := MAXVALUE;
                ELSE
                        l_plan_id := p_plan_id;
                END IF;

                l_partition_name :=  atp_summ_tab(i)|| '_' || l_plan_id;
                msc_util.msc_log('l_partition_name := ' || l_partition_name);

                BEGIN
                SELECT count(*)
                INTO   l_count
                FROM   all_tab_partitions
                WHERE  table_name = l_table_name
                AND    partition_name = l_partition_name
                AND    table_owner = l_msc_schema;
                EXCEPTION
                        WHEN OTHERS THEN
                                msc_util.msc_log('Inside Exception');
                                l_count := 0;
                END;

                IF (l_count = 0) THEN
                        FND_MESSAGE.SET_NAME('MSC', 'MSC_ATP_PLAN_PARTITION_MISSING');
                        FND_MESSAGE.SET_TOKEN('PLAN_NAME', l_plan_name);
                        FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'MSC_' || atp_summ_tab(i));
                        msc_util.msc_log(FND_MESSAGE.GET);
                        RETCODE := G_ERROR;
                        RETURN;
                END IF;
        END LOOP;

        BEGIN
                update msc_plans
                set    summary_flag = 2
                where  plan_id = p_plan_id;
                commit;
        EXCEPTION
                WHEN OTHERS THEN
                        ERRBUF := sqlerrm;
                        RETCODE := G_ERROR;
                        RETURN;
        END;

        msc_util.msc_log('l_share_partition := ' || l_share_partition);

        BEGIN
            SELECT	NVL(pre_alloc_hash_size, -1),
        		NVL(pre_alloc_sort_size, -1),
        		NVL(pre_alloc_parallel_degree, 1)
            INTO	l_hash_size,
        		l_sort_size,
        		l_parallel_degree
            FROM	msc_atp_parameters
            WHERE	rownum = 1;
        EXCEPTION
            WHEN others THEN
        	 msc_util.msc_log('Error getting performance param: ' || sqlcode || ': ' || sqlerrm);
        	 l_hash_size := -1;
        	 l_sort_size := -1;
        	 l_parallel_degree := 1;
        END;

        msc_util.msc_log('Hash: ' || l_hash_size || ' Sort: ' || l_sort_size || ' Parallel: ' || l_parallel_degree);

        IF NVL(l_hash_size, -1) <> -1 THEN
           l_sql_stmt_1 := 'alter session set hash_area_size = ' || to_char(l_hash_size);
           msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
           execute immediate l_sql_stmt_1;
        END IF;

        IF NVL(l_sort_size, -1) <> -1 THEN
           l_sql_stmt_1 := 'alter session set sort_area_size = ' || to_char(l_sort_size);
           msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
           execute immediate l_sql_stmt_1;
        END IF;

        /* forecast at PF changes begin
           Changes to populate demand class allocation information in a temp table*/
        IF p_demand_priority = 'Y' THEN
                l_alloc_temp_table := 'MSC_ALLOC_TEMP_' || to_char(p_plan_id);

                msc_util.msc_log('temp table : ' || l_alloc_temp_table);

                /* Create temp table in tablespace of MSC_ALLOC_DEMANDS*/
                SELECT  t.tablespace_name, NVL(i.def_tablespace_name, t.tablespace_name)
                INTO    l_tbspace, l_ind_tbspace
                FROM    all_tab_partitions t,
                        all_part_indexes i
                WHERE   t.table_owner = l_msc_schema
                AND     t.table_name = 'MSC_ALLOC_DEMANDS'
                AND     t.partition_name = 'ALLOC_DEMANDS_' || to_char(l_plan_id)
                AND     i.owner (+) = t.table_owner
                AND     i.table_name (+) = t.table_name
                AND     rownum = 1;

                msc_util.msc_log('tb space : ' || l_tbspace);
                msc_util.msc_log('ind tbspace : ' || l_ind_tbspace);

                l_insert_stmt := 'CREATE TABLE ' || l_alloc_temp_table || '(
                                     PEGGING_ID             NUMBER,
                                     DEMAND_CLASS           VARCHAR2(30),
                                     ALLOCATION_PERCENT     NUMBER)
                                  TABLESPACE ' || l_tbspace || '
                                  PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)';

                msc_util.msc_log('before creating table : ' || l_alloc_temp_table);

                BEGIN
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.create_table,
                        STATEMENT => l_insert_stmt,
                        OBJECT_NAME => l_alloc_temp_table);
                   msc_util.msc_log('after creating table : ' || l_alloc_temp_table);

                EXCEPTION
                   WHEN others THEN
                      msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                      msc_util.msc_log('Exception of create table : ' || l_alloc_temp_table);

                      ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                             APPLICATION_SHORT_NAME => 'MSC',
                             STATEMENT_TYPE => ad_ddl.drop_table,
                             STATEMENT =>  'DROP TABLE ' || l_alloc_temp_table,
                             OBJECT_NAME => l_alloc_temp_table);

                      msc_util.msc_log('After Drop table : ' ||l_alloc_temp_table);
                      msc_util.msc_log('Before exception create table : ' ||l_alloc_temp_table);

                      ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                             APPLICATION_SHORT_NAME => 'MSC',
                             STATEMENT_TYPE => ad_ddl.create_table,
                             STATEMENT => l_insert_stmt,
                             OBJECT_NAME => l_alloc_temp_table);

                      msc_util.msc_log('After exception create table : ' ||l_alloc_temp_table);
                END;

                Calculate_Alloc_Percentages(p_plan_id, l_return_status);

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_util.msc_log('Pf_Post_Plan_Proc: ' || 'Error occured in procedure Calculate_Alloc_Percentages');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                msc_util.msc_log('Before generating the SQL');

                l_insert_stmt := 'insert into '|| l_alloc_temp_table ||'(
                                        pegging_id,
                                        demand_class,
                                        allocation_percent
                                )
                                (select peg1.pegging_id,
                                        :l_excess_dc,
                                        1
                                 from   msc_full_pegging peg1
                                 where  peg1.plan_id = :p_plan_id
                                 and    peg1.pegging_id = peg1.end_pegging_id
                                 and    peg1.demand_id in (-1, -2)

                                 UNION ALL

                                 select peg1.pegging_id,
                                        decode(mat.transaction_id, NULL, d.demand_class,
                                                                   mat.demand_class),
                                        decode(mat.transaction_id, NULL, 1,
                                                                   mat.allocation_percent)
                                 from   msc_full_pegging peg1,
                                        msc_demands d,
                                        msc_alloc_temp mat
                                 where  peg1.plan_id = :p_plan_id
                                 and    peg1.pegging_id = peg1.end_pegging_id
                                 and    peg1.demand_id = d.demand_id
                                 and    peg1.plan_id = d.plan_id
                                 and    d.disposition_id = mat.transaction_id (+)
                                )';

                msc_util.msc_log(l_insert_stmt);
                msc_util.msc_log('After generating the SQL');

                -- Obtain cursor handler for sql_stmt
                cur_handler := DBMS_SQL.OPEN_CURSOR;

                DBMS_SQL.PARSE(cur_handler, l_insert_stmt, DBMS_SQL.NATIVE);

                msc_util.msc_log('After parsing the SQL');

                DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_excess_dc', l_excess_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);

                msc_util.msc_log('after binding the variables');

                -- Execute the cursor
                rows_processed := DBMS_SQL.EXECUTE(cur_handler);

                msc_util.msc_log('After executing the cursor');

                commit;

                msc_util.msc_log('before creating indexes on temp table');

                l_sql_stmt_1 := 'CREATE INDEX ' || l_alloc_temp_table || '_N1 ON ' || l_alloc_temp_table || '
                                (pegging_id)
                                STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

                msc_util.msc_log('Before index : ' || l_alloc_temp_table || '.' || l_alloc_temp_table || '_N1');

                ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                                APPLICATION_SHORT_NAME => 'MSC',
                                STATEMENT_TYPE => ad_ddl.create_index,
                                STATEMENT => l_sql_stmt_1,
                                OBJECT_NAME => l_alloc_temp_table);

                msc_util.msc_log('After index : ' || l_alloc_temp_table || '.' || l_alloc_temp_table || '_N1');
                msc_util.msc_log('Done creating indexes on temp table');
                msc_util.msc_log('Gather Table Stats');

                -- Use p_plan_id instead of l_plan_id
                --fnd_stats.gather_table_stats('MSC', 'MSC_ALLOC_TEMP_' || to_char(l_plan_id), granularity => 'ALL');
                fnd_stats.gather_table_stats('MSC', l_alloc_temp_table, granularity => 'ALL');
        END IF;
        /* forecast at PF changes end*/

        IF l_share_partition = 'Y' THEN

           msc_util.msc_log('Inside shared partition');

           -- first delete the existing data from tables
           msc_util.msc_log('before deleteing data from the table');

           DELETE MSC_ALLOC_DEMANDS where plan_id = p_plan_id;
           msc_util.msc_log('After deleting data from MSC_ALLOC_DEMANDS table');

           DELETE MSC_ALLOC_SUPPLIES where plan_id = p_plan_id;
           msc_util.msc_log('After deleting data from MSC_ALLOC_SUPPLIES table');

           /*--------------------------------------------------------------------------
           |  <<<<<<<<<<<<<<<<<<<<<<< Begin Demands SQL1 >>>>>>>>>>>>>>>>>>>>>>>>>>>
           +-------------------------------------------------------------------------*/
           msc_util.msc_log('Before generating Demands SQL1');

           /* forecast at PF changes begin*/
           Prepare_Demands_Stmt(l_share_partition, p_demand_priority, l_excess_supply_by_dc,
                                 NULL, l_alloc_temp_table, l_parallel_degree, l_sql_stmt_1, l_return_status);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Pf_Post_Plan_Proc: ' || 'Error occured in procedure Prepare_Demands_Stmt');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
           END IF;

           msc_util.msc_log('After generating Demands SQL1');
           msc_util.msc_log(l_sql_stmt_1);

           -- Obtain cursor handler for sql_stmt
           cur_handler := DBMS_SQL.OPEN_CURSOR;

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing Demands SQL1');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_yes', l_yes);
           IF p_demand_priority = 'Y' THEN
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_excess_dc', l_excess_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_excess_supply_by_dc', l_excess_supply_by_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           END IF;
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing the cursor');

           msc_util.msc_log('rows processed: ' || rows_processed);
           msc_util.msc_log('after inserting item data into MSC_ALLOC_DEMANDS tables');

           /*--------------------------------------------------------------------------
           |  <<<<<<<<<<<<<<<<<<<<<<< Begin Supplies SQL1 >>>>>>>>>>>>>>>>>>>>>>>>>>>
           +-------------------------------------------------------------------------*/
           msc_util.msc_log('Before generating Supplies SQL1');

           Prepare_Supplies_Stmt(l_share_partition, p_demand_priority,
                                  l_excess_supply_by_dc, NULL, l_alloc_temp_table, l_parallel_degree, l_sql_stmt_1, l_return_status);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Pf_Post_Plan_Proc: ' || 'Error occured in procedure Prepare_Supplies_Stmt');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
           END IF;

           msc_util.msc_log(l_sql_stmt_1);
           msc_util.msc_log('After Generating Supplies SQL1');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing Supplies SQL1');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_yes', l_yes);
           IF p_demand_priority = 'Y' THEN
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_excess_dc', l_excess_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_excess_supply_by_dc', l_excess_supply_by_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           END IF;
           /* forecast at PF changes end*/

           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing first supplies cursor');

           msc_util.msc_log('rows processed: ' || rows_processed);
           msc_util.msc_log('after inserting item data into MSC_ALLOC_SUPPLIES tables');

           msc_util.msc_log('Analyze Plan partition for MSC_ALLOC_DEMANDS');
           fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>'MSC_ALLOC_DEMANDS',
                                   partname=>'ALLOC_DEMANDS_999999',
                                   granularity=>'PARTITION',
                                   percent =>10);

           msc_util.msc_log('Analyze Plan partition for MSC_ALLOC_SUPPLIES');
           fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>'MSC_ALLOC_SUPPLIES',
                                   partname=>'ALLOC_SUPPLIES_999999',
                                   granularity=>'PARTITION',
                                   percent =>10);

        ELSE

           msc_util.msc_log('not a shared plan partition, insert data into temp tables');

           l_temp_table := 'MSC_TEMP_ALLOC_DEM_' || to_char(l_plan_id);

           msc_util.msc_log('temp table : ' || l_temp_table);

           IF p_demand_priority <> 'Y' THEN
                   SELECT  t.tablespace_name, NVL(i.def_tablespace_name, t.tablespace_name)
        	   INTO    l_tbspace, l_ind_tbspace
                   FROM    all_tab_partitions t,
                           all_part_indexes i
                   WHERE   t.table_owner = l_msc_schema
                   AND     t.table_name = 'MSC_ALLOC_DEMANDS'
        	   AND     t.partition_name = 'ALLOC_DEMANDS_' || to_char(l_plan_id)
                   AND     i.owner (+) = t.table_owner
                   AND     i.table_name (+) = t.table_name
                   AND     rownum = 1;

                   msc_util.msc_log('tb space : ' || l_tbspace);
                   msc_util.msc_log('ind tbspace : ' || l_ind_tbspace);
           END IF;

         --bug 6113544
         l_insert_stmt := 'CREATE TABLE ' || l_temp_table
           || ' TABLESPACE ' || l_tbspace
           || ' PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)'
           || ' as select * from MSC_ALLOC_DEMANDS where 1=2 ';

      /*
           l_insert_stmt := 'CREATE TABLE ' || l_temp_table || '(
				 PLAN_ID                    NUMBER           NOT NULL,
				 INVENTORY_ITEM_ID          NUMBER           NOT NULL,
				 ORGANIZATION_ID            NUMBER           NOT NULL,
				 SR_INSTANCE_ID             NUMBER           NOT NULL,
				 DEMAND_CLASS               VARCHAR2(30),   --bug3272444
				 DEMAND_DATE                DATE             NOT NULL,
				 PARENT_DEMAND_ID           NUMBER           NOT NULL,
				 ALLOCATED_QUANTITY         NUMBER           NOT NULL,
				 ORIGINATION_TYPE           NUMBER           NOT NULL,
				 ORDER_NUMBER               VARCHAR2(62),
				 SALES_ORDER_LINE_ID        NUMBER,
				 OLD_DEMAND_DATE            DATE,
				 OLD_ALLOCATED_QUANTITY     NUMBER,
				 CREATED_BY                 NUMBER           NOT NULL,
				 CREATION_DATE              DATE             NOT NULL,
				 LAST_UPDATED_BY            NUMBER           NOT NULL,
				 LAST_UPDATE_DATE           DATE             NOT NULL,
				 DEMAND_QUANTITY            NUMBER,
				 PF_DISPLAY_FLAG            NUMBER,
				 ORIGINAL_ITEM_ID           NUMBER,
				 ORIGINAL_ORIGINATION_TYPE  NUMBER,
				 ORIGINAL_DEMAND_DATE       DATE,
				 SOURCE_ORGANIZATION_ID     NUMBER,         --bug3272444
                                 USING_ASSEMBLY_ITEM_ID     NUMBER,         --bug3272444
				 CUSTOMER_ID                NUMBER,
                                 SHIP_TO_SITE_ID            NUMBER,
                                 REFRESH_NUMBER             NUMBER,         --bug3272444
                                 OLD_REFRESH_NUMBER         NUMBER,         --bug3272444
                                 DEMAND_SOURCE_TYPE         NUMBER,         --cmro
                                 REQUEST_DATE               DATE)           --bug3263368
			    TABLESPACE ' || l_tbspace || '
                            PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)';
       */

           msc_util.msc_log('before creating table : ' || l_temp_table);
           BEGIN
              ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.create_table,
                   STATEMENT => l_insert_stmt,
                   OBJECT_NAME => l_temp_table);
              msc_util.msc_log('after creating table : ' || l_temp_table);

           EXCEPTION
              WHEN others THEN
                 msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                 msc_util.msc_log('Exception of create table : ' || l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.drop_table,
                        STATEMENT =>  'DROP TABLE ' || l_temp_table,
                        OBJECT_NAME => l_temp_table);

                 msc_util.msc_log('After Drop table : ' ||l_temp_table);
                 msc_util.msc_log('Before exception create table : ' ||l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.create_table,
                        STATEMENT => l_insert_stmt,
                        OBJECT_NAME => l_temp_table);
                 msc_util.msc_log('After exception create table : ' ||l_temp_table);
           END;

           /*--------------------------------------------------------------------------
           |  <<<<<<<<<<<<<<<<<<<<<<< Begin Demands SQL1 >>>>>>>>>>>>>>>>>>>>>>>>>>>
           +-------------------------------------------------------------------------*/
           msc_util.msc_log('Before generating Demands SQL1');

           /* forecast at PF changes begin*/
           Prepare_Demands_Stmt(l_share_partition, p_demand_priority, l_excess_supply_by_dc,
                                 l_temp_table, l_alloc_temp_table, l_parallel_degree, l_sql_stmt_1, l_return_status);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Pf_Post_Plan_Proc: ' || 'Error occured in procedure Prepare_Demands_Stmt');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
           END IF;

           msc_util.msc_log(l_sql_stmt_1);
           msc_util.msc_log('After generating Demands SQL1');

           -- Obtain cursor handler for sql_stmt
           cur_handler := DBMS_SQL.OPEN_CURSOR;

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing Demands SQL1');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_yes', l_yes);
           IF p_demand_priority = 'Y' THEN
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_excess_dc', l_excess_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_excess_supply_by_dc', l_excess_supply_by_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           END IF;
           /* forecast at PF changes end*/

           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing the cursor');
           msc_util.msc_log('after inserting item data into MSC_TEMP_ALLOC_DEMANDS table');

           commit;

           msc_util.msc_log('before creating indexes on temp demand table');
           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N1 ON ' || l_temp_table || '
                           --NOLOGGING
                           (plan_id, inventory_item_id, organization_id, sr_instance_id, demand_class, demand_date)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N2 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           sales_order_line_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N3 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           parent_demand_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N3');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N3');
           msc_util.msc_log('Done creating indexes on temp demand table');

           l_temp_table := 'MSC_TEMP_ALLOC_SUP_' || to_char(l_plan_id);

           SELECT  t.tablespace_name, NVL(i.def_tablespace_name, t.tablespace_name)
           INTO    l_tbspace, l_ind_tbspace
           FROM    all_tab_partitions t,
                   all_part_indexes i
           WHERE   t.table_owner = l_msc_schema
           AND     t.table_name = 'MSC_ALLOC_SUPPLIES'
           AND     t.partition_name = 'ALLOC_SUPPLIES_' || to_char(l_plan_id)
           AND     i.owner (+) = t.table_owner
           AND     i.table_name (+) = t.table_name
           AND     rownum = 1;

           msc_util.msc_log('tb space : ' || l_tbspace);
           msc_util.msc_log('ind tbspace : ' || l_ind_tbspace);

       --bug 6113544
           l_insert_stmt := 'CREATE TABLE ' || l_temp_table
           || ' TABLESPACE ' || l_tbspace
           || ' PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)'
           || ' as select * from msc_alloc_supplies where 1=2 ';

       /*
           l_insert_stmt := 'CREATE TABLE ' || l_temp_table || '(
                                 PLAN_ID                    NUMBER           NOT NULL,
                                 INVENTORY_ITEM_ID          NUMBER           NOT NULL,
                                 ORGANIZATION_ID            NUMBER           NOT NULL,
                                 SR_INSTANCE_ID             NUMBER           NOT NULL,
                                 DEMAND_CLASS               VARCHAR2(30)      ,  --bug3272444
                                 SUPPLY_DATE                DATE             NOT NULL,
                                 PARENT_TRANSACTION_ID      NUMBER           NOT NULL,
                                 ALLOCATED_QUANTITY         NUMBER           NOT NULL,
                                 ORDER_TYPE                 NUMBER           NOT NULL,
                                 ORDER_NUMBER               VARCHAR2(240),
				 SCHEDULE_DESIGNATOR_ID	    NUMBER,
                                 SALES_ORDER_LINE_ID        NUMBER,
                                 OLD_SUPPLY_DATE            DATE,
                                 OLD_ALLOCATED_QUANTITY     NUMBER,
				 STEALING_FLAG		    NUMBER,
                                 CREATED_BY                 NUMBER           NOT NULL,
                                 CREATION_DATE              DATE             NOT NULL,
                                 LAST_UPDATED_BY            NUMBER           NOT NULL,
                                 LAST_UPDATE_DATE           DATE             NOT NULL,
                                 FROM_DEMAND_CLASS          VARCHAR2(80),
                                 SUPPLY_QUANTITY            NUMBER,
                                 ORIGINAL_ORDER_TYPE        NUMBER,         --bug3272444
                                 ORIGINAL_ITEM_ID           NUMBER,         --bug3272444
                                 CUSTOMER_ID                NUMBER,
                                 SHIP_TO_SITE_ID            NUMBER,
                                 REFRESH_NUMBER             NUMBER,        --bug3272444
                                 OLD_REFRESH_NUMBER         NUMBER,        --bug3272444
                                 ATO_MODEL_LINE_ID          NUMBER,
                               --ATO_MODEL_LINE_ID          NUMBER)        --
                                 DEMAND_SOURCE_TYPE         NUMBER)        --cmro
                                  TABLESPACE ' || l_tbspace || '
                            PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)';
       */

           msc_util.msc_log('before creating table : ' || l_temp_table);
           BEGIN
              ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.create_table,
                   STATEMENT => l_insert_stmt,
                   OBJECT_NAME => l_temp_table);
              msc_util.msc_log('after creating table : ' || l_temp_table);

           EXCEPTION
              WHEN others THEN
                 msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                 msc_util.msc_log('Exception of create table : ' || l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.drop_table,
                        STATEMENT =>  'DROP TABLE ' || l_temp_table,
                        OBJECT_NAME => l_temp_table);

                 msc_util.msc_log('After Drop table : ' ||l_temp_table);
                 msc_util.msc_log('Before exception create table : ' ||l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.create_table,
                        STATEMENT => l_insert_stmt,
                        OBJECT_NAME => l_temp_table);
                 msc_util.msc_log('After exception create table : ' ||l_temp_table);
           END;

           /*--------------------------------------------------------------------------
           |  <<<<<<<<<<<<<<<<<<<<<<< Begin Supplies SQL1 >>>>>>>>>>>>>>>>>>>>>>>>>>>
           +-------------------------------------------------------------------------*/
           msc_util.msc_log('Before generating Supplies SQL1');

           /* forecast at PF changes begin*/
           Prepare_Supplies_Stmt(l_share_partition, p_demand_priority, l_excess_supply_by_dc,
                                  l_temp_table, l_alloc_temp_table, l_parallel_degree, l_sql_stmt_1, l_return_status);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Pf_Post_Plan_Proc: ' || 'Error occured in procedure Prepare_Supplies_Stmt');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
           END IF;

           msc_util.msc_log(l_sql_stmt_1);
           msc_util.msc_log('After Generating Supplies SQL1');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing Supplies SQL1');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_yes', l_yes);
           IF p_demand_priority = 'Y' THEN
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_excess_dc', l_excess_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_excess_supply_by_dc', l_excess_supply_by_dc);
                DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           END IF;
           /* forecast at PF changes end*/

           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing first supplies cursor');
           msc_util.msc_log('after inserting item data into MSC_TEMP_ALLOC_SUPPLIES table');

           commit;

           msc_util.msc_log('before creating indexes on temp supply table');
           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N1 ON ' || l_temp_table || '
                           -- NOLOGGING
                           (plan_id, inventory_item_id, organization_id, sr_instance_id, demand_class, supply_date)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N2 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           parent_transaction_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N3 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           sales_order_line_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N3');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N3');

           msc_util.msc_log('Gather Table Stats for Allocated S/D Tables');

           fnd_stats.gather_table_stats('MSC', 'MSC_TEMP_ALLOC_DEM_' || to_char(l_plan_id), granularity => 'ALL');
           fnd_stats.gather_table_stats('MSC', 'MSC_TEMP_ALLOC_SUP_' || to_char(l_plan_id), granularity => 'ALL');

           msc_util.msc_log('swap partition for demands');
           l_partition_name := 'ALLOC_DEMANDS_' || to_char(l_plan_id);

           msc_util.msc_log('Partition name for msc_alloc_demands table : ' || l_partition_name);

           -- swap partiton for supplies and demand part

           l_sql_stmt := 'ALTER TABLE msc_alloc_demands EXCHANGE PARTITION ' || l_partition_name  ||
           ' with table MSC_TEMP_ALLOC_DEM_'|| to_char(l_plan_id) ||
           ' including indexes without validation';

           BEGIN
        	   msc_util.msc_log('Before alter table msc_alloc_demands');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ALLOC_DEMANDS');
       	   END;

           msc_util.msc_log('swap partition for supplies');
           l_partition_name := 'ALLOC_SUPPLIES_' || to_char(l_plan_id);

           msc_util.msc_log('Partition name for msc_alloc_supplies table : ' || l_partition_name);

           l_sql_stmt := 'ALTER TABLE msc_alloc_supplies EXCHANGE PARTITION ' || l_partition_name  ||
           ' with table MSC_TEMP_ALLOC_SUP_'|| to_char(l_plan_id) ||
           ' including indexes without validation';

           BEGIN
        	   msc_util.msc_log('Before alter table msc_alloc_supplies');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ALLOC_SUPPLIES');
       	   END;

	END IF; -- IF l_share_partition = 'Y'

        /* forecast at PF changes begin*/
        -- clean temp tables after exchanging partitions
        msc_util.msc_log('Call procedure clean_temp_tables');

        MSC_POST_PRO.clean_temp_tables(l_applsys_schema, l_plan_id, p_plan_id, p_demand_priority);

        msc_util.msc_log('After procedure clean_temp_tables');
        /* forecast at PF changes end*/

        /* Call Update_Pf_Display_Flags to update Pf_Display_Flag in msc_alloc_demands*/
        Update_Pf_Display_Flag(p_plan_id, l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Pf_Post_Plan_Proc: ' || 'Error occured in procedure Update_Pf_Display_Flag');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN
            update msc_plans
            set    summary_flag = 3
            where  plan_id = p_plan_id;
        END;

	RETCODE := G_SUCCESS;
	commit;

	msc_util.msc_log('End procedure Pf_Post_Plan_Proc');

EXCEPTION
       WHEN OTHERS THEN
            msc_util.msc_log('Inside main exception of Pf_Post_Plan_Proc');
            msc_util.msc_log(sqlerrm);
            ERRBUF := sqlerrm;

            BEGIN
               update msc_plans
               set    summary_flag = 1
               where  plan_id = p_plan_id;
               commit;
            END;

            RETCODE := G_ERROR;
            IF (l_share_partition = 'Y') THEN
               ROLLBACK;
            ELSE
	       msc_util.msc_log('Call procedure clean_temp_tables in exception');

	       /* forecast at PF changes*/
	       MSC_POST_PRO.clean_temp_tables(l_applsys_schema, l_plan_id, p_plan_id, p_demand_priority);

	       msc_util.msc_log('After procedure clean_temp_tables in exception');
            END IF;
END Pf_Post_Plan_Proc;

-- New private procedure added for forecast at PF
/*--Prepare_Demands_Stmt----------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to:
|       -  Prepare demands stmt for preallocation + bucketting (Demand
|            priority AATP)
|            :  Excess supply by demand class = No
|            :  Excess supply by demand class = Yes (for project atp)
|       -  Prepare demands stmt for bucketting. (All PDS ATP scenarios except
|            demand priority AATP)
|  o  Prepares demand stmt for both share plan partition "yes" and "no".
+-------------------------------------------------------------------------*/
PROCEDURE Prepare_Demands_Stmt(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_alloc_temp_table              IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'p_share_partition        : ' || p_share_partition);
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'p_demand_priority        : ' || p_demand_priority);
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'p_excess_supply_by_dc    : ' || p_excess_supply_by_dc);
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'p_temp_table             : ' || p_temp_table);
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'p_alloc_temp_table       : ' || p_alloc_temp_table);
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'p_parallel_degree        : ' || p_parallel_degree);
                msc_util.msc_log('Prepare_Demands_Stmt: ' || 'MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF        : ' || MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_share_partition = 'Y' THEN
           x_sql_stmt := '
                INSERT INTO MSC_ALLOC_DEMANDS(';
        ELSE
           x_sql_stmt := '
                INSERT INTO ' || p_temp_table || '(';
        END IF;

        IF p_demand_priority = 'Y' THEN
                   x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                original_demand_date,
                                demand_quantity,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                original_origination_type,
                                pf_display_flag,
                                order_number,
                                sales_order_line_id,
                                demand_source_type,--cmro
                                source_organization_id,
                                using_assembly_item_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                request_date)--bug3263368
                	(
                        SELECT	/*+  use_hash(pegging_v mv) parallel(mv,' || to_char(p_parallel_degree) || ')  */
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.demand_date,
                                pegging_v.original_demand_date,
                                MIN(pegging_v.demand_quantity),
                                SUM(pegging_v.allocated_quantity),
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.original_origination_type,
                                pegging_v.pf_display_flag,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                pegging_v.source_organization_id,
                                pegging_v.using_assembly_item_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                pegging_v.request_date --bug3263368
                        FROM
                                (SELECT peg.plan_id plan_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date), -- Bug 3450234 use trunc on s.new_schedule_date
                                                       1, msi.product_family_id,                                            -- to avoid wrong bucketed demands creation
                                                       msi.inventory_item_id)) inventory_item_id,
                                        msi.inventory_item_id original_item_id,
                        	        peg.organization_id,
                        	        peg.sr_instance_id,
                        	        decode(mat.demand_class, :l_excess_dc, decode(:p_excess_supply_by_dc, :l_yes, nvl(s.demand_class, :def_num),
                        	                                                                     :def_num),
                        	                                 NULL, :def_num,
                        	                                 mat.demand_class) demand_class,
                                        decode(msi.aggregate_time_fence_date,
                                        -- Bug 3574164. DMD_SATISFIED_TIME changed to PLANNED_SHIP_DATE.
                                               NULL, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                  2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                     decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                                            1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                               - msi.aggregate_time_fence_date),
                                                                      1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                      2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                         NVL(D.SCHEDULE_SHIP_DATE,
                                                                                             D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                         msi.aggregate_time_fence_date+1),
                                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                               - msi.aggregate_time_fence_date),
                                                                      1, msi.aggregate_time_fence_date,
                                                                         trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                      2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                         NVL(D.SCHEDULE_SHIP_DATE,
                                                                                             D.USING_ASSEMBLY_DEMAND_DATE)))))) demand_date,
                                        trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                     2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                        NVL(D.SCHEDULE_SHIP_DATE,
                                                            D.USING_ASSEMBLY_DEMAND_DATE))) original_demand_date,
                        		decode(d.origination_type, 4, d.daily_demand_rate,
                        		           d.using_requirement_quantity) demand_quantity,
                                        decode(msi.aggregate_time_fence_date,
                                               NULL, peg.allocated_quantity,
                                               decode(msi.bom_item_type,
                                                      5, 0,
                                                      peg.allocated_quantity))* mat.allocation_percent allocated_quantity,
                                        d.demand_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, d.origination_type, 51) origination_type,
                        		d.origination_type original_origination_type,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, NULL,
                                                   decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                          - msi.aggregate_time_fence_date),
                                                              1, 1,
                                                              NULL),
                                                          decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                          - msi.aggregate_time_fence_date),
                                                              1, NULL, -- Moved paranthesis from here to end of decode. Identified as part of 3450234 testing.
                                                              1))) pf_display_flag,
                        		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                        		d.sales_order_line_id,
                        		d.demand_source_type,--cmro
                                        d.source_organization_id,
                                        d.using_assembly_item_id,
                                        d.customer_id,
                                        d.ship_to_site_id,
                                        /* New Allocation logic for time phased ATP */
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   msi.product_family_id) product_family_id ,
                                        decode(d.order_date_type_code,2,d.request_date,
                        		           d.request_ship_date)request_date --bug3263368
                        	FROM    msc_system_items msi,
                        		msc_demands d,
                        	        msc_full_pegging peg,
                        	        ' || p_alloc_temp_table || ' mat,
                        	        msc_supplies s
                        	WHERE   msi.plan_id = :p_plan_id
                                AND     msi.atp_flag = :l_yes
                                AND     msi.plan_id = d.plan_id --bug3453289
                                AND     d.inventory_item_id = msi.inventory_item_id
                                AND     d.sr_instance_id = msi.sr_instance_id
                                AND     d.organization_id = msi.organization_id
                        	AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31)
                        	AND     peg.plan_id = d.plan_id
                        	AND     peg.demand_id = d.demand_id
                        	AND     peg.sr_instance_id = d.sr_instance_id --bug3453289 MSC_FULL_PEGGING_N2
                        	AND     peg.organization_id= d.organization_id --bug3453289 MSC_FULL_PEGGING_N2
                        	AND     mat.pegging_id = peg.end_pegging_id
                        	AND     s.sr_instance_id = peg.sr_instance_id
                        	AND     s.plan_id = peg.plan_id
                        	AND     s.transaction_id = peg.transaction_id) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.product_family_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.demand_date >=  mv.effective_date (+)
                        AND     pegging_v.demand_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
                        AND     pegging_v.allocated_quantity <> 0
                	GROUP BY
                                pegging_v.plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.demand_date,
                                pegging_v.original_demand_date,
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.original_origination_type,
                                pegging_v.pf_display_flag,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                pegging_v.source_organization_id,
                                pegging_v.using_assembly_item_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                pegging_v.request_date)';
        ELSE -- this is same as else of old private procedure prepare_demands_stmt1 as there
             -- is no changes for non demand priority AATP scenarios
                -- Prepare demands stmt for creation of bucketed demands/rollup supplies
                x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                original_demand_date,
                                demand_quantity,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                original_origination_type,
                                pf_display_flag,
                                order_number,
                                sales_order_line_id,
                                demand_source_type,--cmro
                                source_organization_id,
                                using_assembly_item_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                request_date)--bug3263368
                        (SELECT
                                peg1.plan_id plan_id,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date), -- Bug 3450234 use trunc on s.new_schedule_date
                                                                                                         -- to avoid wrong bucketed demands creation
                                           1, msi.product_family_id,
                                           msi.inventory_item_id) inventory_item_id,
                                msi.inventory_item_id original_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                d.demand_class demand_class,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                       -- Bug 3574164. DMD_SATISFIED_TIME changed to PLANNED_SHIP_DATE.
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                                 1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                              2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                 NVL(D.SCHEDULE_SHIP_DATE,
                                                                     D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 msi.aggregate_time_fence_date+1),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, msi.aggregate_time_fence_date,
                                           trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                               D.USING_ASSEMBLY_DEMAND_DATE))))) demand_date,
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                    D.USING_ASSEMBLY_DEMAND_DATE))) original_demand_date,
                                MIN(decode(d.origination_type, 4, d.daily_demand_rate,
                		           d.using_requirement_quantity)) demand_quantity,
                                SUM(peg1.allocated_quantity),
                                d.demand_id,
                                51 origination_type, -- ATP Bucketed Demand
                                d.origination_type original_origination_type,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                       -- Bug 3574164. DMD_SATISFIED_TIME changed to PLANNED_SHIP_DATE.
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, 1,
                                              NULL),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, NULL, -- Moved paranthesis from here to end of decode. Identified as part of 3450234 testing.
                                           1)) pf_display_flag,
                		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                d.source_organization_id,
                                d.using_assembly_item_id,
                                d.customer_id,
                                d.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                decode(d.order_date_type_code,2,d.request_date,
        			            d.request_ship_date)request_date --bug3263368
                        FROM    msc_full_pegging peg1,
                                msc_demands d,
                                msc_supplies s,
                                msc_system_items msi
                        WHERE   d.demand_id = peg1.demand_id
                        AND     d.plan_id = peg1.plan_id
                        AND     d.sr_instance_id = peg1.sr_instance_id
                        AND     d.organization_id= peg1.organization_id --bug3453289
                        AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31)
                        AND     s.transaction_id = peg1.transaction_id
                        AND     s.plan_id = peg1.plan_id
                        AND     s.sr_instance_id = peg1.sr_instance_id --bug3453289
                        AND     msi.plan_id = d.plan_id
                        AND     msi.inventory_item_id = d.inventory_item_id
                        AND     msi.sr_instance_id = d.sr_instance_id
                        AND     msi.organization_id = d.organization_id
                        AND     msi.aggregate_time_fence_date is not null
                        AND     msi.bom_item_type <> 5
                        AND     msi.plan_id = :p_plan_id
                        AND     msi.atp_flag = :l_yes
                        GROUP BY
                                peg1.plan_id,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date), -- Bug 3450234 use trunc on s.new_schedule_date
                                                                                                         -- to avoid wrong bucketed demands creation
                                           1, msi.product_family_id,
                                           msi.inventory_item_id),
                                msi.inventory_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                d.demand_class,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                       -- Bug 3574164. DMD_SATISFIED_TIME changed to PLANNED_SHIP_DATE.
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                              2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                 NVL(D.SCHEDULE_SHIP_DATE,
                                                                     D.USING_ASSEMBLY_DEMAND_DATE))),
                                              msi.aggregate_time_fence_date+1),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE))) - msi.aggregate_time_fence_date),
                                           1, msi.aggregate_time_fence_date,
                                           trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                               D.USING_ASSEMBLY_DEMAND_DATE))))),
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                    D.USING_ASSEMBLY_DEMAND_DATE))),
                                d.demand_id,
                                51,
                                d.origination_type,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, 1,
                                              NULL),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, NULL, -- Moved paranthesis from here to end of decode. Identified as part of 3450234 testing.
                                           1)),
                		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                d.source_organization_id,
                                d.using_assembly_item_id,
                                d.customer_id,
                                d.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                decode(d.order_date_type_code,2,d.request_date,
        			            d.request_ship_date))';  --bug3263368
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Prepare_Demands_Stmt: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Prepare_Demands_Stmt;

-- New private procedure added for forecast at PF
/*--Prepare_Supplies_Stmt---------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to:
|       -  Prepare supplies stmt for preallocation + rollup (Demand
|            priority AATP)
|            :  Excess supply by demand class = No
|            :  Excess supply by demand class = Yes (for project atp)
|       -  Prepare supplies stmt for rollup. (All PDS ATP scenarios except
|            demand priority AATP)
|  o  Prepares supplies stmt for both share plan partition "yes" and "no".
+-------------------------------------------------------------------------*/
PROCEDURE Prepare_Supplies_Stmt(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_alloc_temp_table              IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'p_share_partition        : ' || p_share_partition);
                msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'p_demand_priority        : ' || p_demand_priority);
                msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'p_excess_supply_by_dc    : ' || p_excess_supply_by_dc);
                msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'p_temp_table             : ' || p_temp_table);
                msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'p_alloc_temp_table       : ' || p_alloc_temp_table);
                msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'p_parallel_degree        : ' || p_parallel_degree);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_share_partition = 'Y' THEN
           x_sql_stmt := '
                INSERT INTO MSC_ALLOC_SUPPLIES(';
        ELSE
           x_sql_stmt := '
                INSERT INTO ' || p_temp_table || '(';
        END IF;

        IF p_demand_priority = 'Y' THEN
                   x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                parent_transaction_id,
                                allocated_quantity,
                                supply_quantity,
                                order_type,
                                original_order_type,
                                order_number,
                                schedule_designator_id,
                                customer_id, -- not really required only used in rule based
                                ship_to_site_id, -- not really required only used in rule based
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
        		(
        	        SELECT	/*+  use_hash(pegging_v mv) parallel(mv,' || to_char(p_parallel_degree) || ')  */
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.supply_date,
                                pegging_v.transaction_id,
                                SUM(pegging_v.allocated_quantity),
                                MIN(pegging_v.supply_quantity),
                                pegging_v.order_type,
                                pegging_v.original_order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        FROM
                                (SELECT peg.plan_id plan_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   decode(sign(TRUNC(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                                       1, msi.product_family_id,
                                                       msi.inventory_item_id)) inventory_item_id,
                                        msi.inventory_item_id original_item_id,
                                        peg.organization_id,
                                        peg.sr_instance_id,
                        	        decode(mat.demand_class, :l_excess_dc, decode(:p_excess_supply_by_dc, :l_yes, nvl(s.demand_class, :def_num),
                        	                                                                     :def_num),
                        	                                 NULL, :def_num,
                        	                                 mat.demand_class) demand_class,
                                        TRUNC(s.new_schedule_date) supply_date,
                                        decode(msi.aggregate_time_fence_date,
                                               NULL, peg.allocated_quantity,
                                               decode(msi.bom_item_type,
                                                      5, 0,
                                                      peg.allocated_quantity))* mat.allocation_percent allocated_quantity,
                                        s.new_order_quantity supply_quantity,
                                        peg.transaction_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, s.order_type, 50) order_type,
                                        s.order_type original_order_type,
                                        s.order_number,
                                        s.schedule_designator_id,
                                        s.customer_id,
                                        s.ship_to_site_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   msi.product_family_id) product_family_id
                        	FROM    msc_system_items msi,
                        		msc_supplies s,
                        	        msc_full_pegging peg,
                        	        ' || p_alloc_temp_table || ' mat
                        	WHERE   msi.plan_id = :p_plan_id
                                AND     msi.atp_flag = :l_yes
                                AND     s.plan_id = msi.plan_id --bug3453289
                                AND     s.inventory_item_id = msi.inventory_item_id
                                AND     s.sr_instance_id = msi.sr_instance_id
                                AND     s.organization_id = msi.organization_id
                        	AND     peg.plan_id = s.plan_id
                        	AND     peg.transaction_id = s.transaction_id
                        	AND     peg.sr_instance_id = s.sr_instance_id
                        	AND     mat.pegging_id = peg.end_pegging_id) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.product_family_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.supply_date >=  mv.effective_date (+)
                        AND     pegging_v.supply_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
                        AND     pegging_v.allocated_quantity <> 0
        		GROUP BY
                                pegging_v.plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.supply_date,
                                pegging_v.transaction_id,
                                pegging_v.order_type,
                                pegging_v.original_order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
        ELSE -- this is same as else of old private procedure prepare_supplies_stmt1 as there
             -- is no changes for non demand priority AATP scenarios
                -- Prepare supplies stmt for creation of rollup supplies
                x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                parent_transaction_id,
                                allocated_quantity,
                                supply_quantity,
                                order_type,
                                original_order_type,
                                order_number,
                                schedule_designator_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
        		(
                        select  :p_plan_id,
                                decode(sign(TRUNC(s.new_schedule_date) - i.aggregate_time_fence_date),
                                        1, i.product_family_id, s.inventory_item_id),
                                s.inventory_item_id,
                                s.organization_id,
                                s.sr_instance_id,
                                s.demand_class,
                                TRUNC(s.new_schedule_date),
                                s.transaction_id,
                                s.new_order_quantity,
                                s.new_order_quantity,
                                50,
                                s.order_type,
                                s.order_number,
                                s.schedule_designator_id,
                                s.customer_id,
                                s.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        from    msc_supplies s,
                                msc_system_items i
                        where   i.aggregate_time_fence_date is not null
                        and     i.bom_item_type <> 5
                        and     i.plan_id = :p_plan_id
                        and     i.atp_flag = :l_yes
                        and     s.plan_id = i.plan_id --bug3453289
                        and     s.inventory_item_id = i.inventory_item_id
                        and     s.organization_id = i.organization_id
                        and     s.sr_instance_id = i.sr_instance_id
                        and     s.plan_id = i.plan_id
                        )';
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Prepare_Supplies_Stmt: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Prepare_Supplies_Stmt;

/*Private procedures removed for forecast at PF  **Will be deleted after code review
/*--Prepare_Demands_Stmt1---------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to:
|       -  Prepare demands stmt for preallocation + bucketting for demands
|            pegged to excess/safety stock. (Demand priority AATP)
|            :  Excess supply by demand class = No
|            :  Excess supply by demand class = Yes (for project atp)
|       -  Prepare demands stmt for bucketting. (All PDS ATP scenarios except
|            demand priority AATP)
|  o  Prepares demand stmt for both share plan partition "yes" and "no".
+-------------------------------------------------------------------------*/
/*PROCEDURE Prepare_Demands_Stmt1(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Prepare_Demands_Stmt1: ' || 'p_share_partition        : ' || p_share_partition);
                msc_util.msc_log('Prepare_Demands_Stmt1: ' || 'p_demand_priority        : ' || p_demand_priority);
                msc_util.msc_log('Prepare_Demands_Stmt1: ' || 'p_excess_supply_by_dc    : ' || p_excess_supply_by_dc);
                msc_util.msc_log('Prepare_Demands_Stmt1: ' || 'p_temp_table             : ' || p_temp_table);
                msc_util.msc_log('Prepare_Demands_Stmt1: ' || 'p_parallel_degree        : ' || p_parallel_degree);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_share_partition = 'Y' THEN
           x_sql_stmt := '
                INSERT INTO MSC_ALLOC_DEMANDS(';
        ELSE
           x_sql_stmt := '
                INSERT INTO ' || p_temp_table || '(';
        END IF;

        IF p_demand_priority = 'Y' THEN
                /* Prepare demands stmt for preallocation + creation of bucketed demands/rollup supplies
                 * project atp changes
                 * If the profile is set to 'Yes' then:
                 *    o If the supply pegged to the demand has a demand class existing on allocation rule then
                 *      allocate the demand to that demand class.
                 *    o If the supply pegged to the demand has a demand class not present on allocation rule then
                 *      allocate the demand to 'OTHER'.
                 *    o If the supply pegged to the demand does not have a demand class present, allocate the demand
                 *      to 'OTHER'.
                 * Else: Allocate the supply to 'OTHER'*/
/*                IF p_excess_supply_by_dc = 'Y' THEN
                   x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                original_demand_date,
                                demand_quantity,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                original_origination_type,
                                pf_display_flag,
                                order_number,
                                sales_order_line_id,
                                source_organization_id,
                                using_assembly_item_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
                	(
                        SELECT	/*+  use_hash(pegging_v mv) parallel(mv,' || to_char(p_parallel_degree) || ')  */
/*                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.demand_date,
                                pegging_v.original_demand_date,
                                MIN(pegging_v.demand_quantity),
                                SUM(pegging_v.allocated_quantity),
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.original_origination_type,
                                pegging_v.pf_display_flag,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.source_organization_id,
                                pegging_v.using_assembly_item_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        FROM
                                (SELECT /*+ ordered use_hash(peg2 peg1 d s msi)
                        			parallel(peg2,' || to_char(p_parallel_degree) || ')
                        			parallel(peg1,' || to_char(p_parallel_degree) || ')
                        			parallel(d,' || to_char(p_parallel_degree) || ')
                                                parallel(s,' || to_char(p_parallel_degree) || ')
                                                parallel(msi,' || to_char(p_parallel_degree) || ')
                        			full(peg2) full(peg1) full(d) full(s) full(msi) */
/*                                        peg1.plan_id plan_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   decode(sign(s.new_schedule_date - msi.aggregate_time_fence_date),
                                                       1, msi.product_family_id,
                                                       msi.inventory_item_id)) inventory_item_id,
                                        msi.inventory_item_id original_item_id,
                        	        peg1.organization_id,
                        	        peg1.sr_instance_id,
                        	        NVL(s.demand_class, :def_num) demand_class,
                                        decode(msi.aggregate_time_fence_date,
                                               NULL, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                  2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                     NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                     decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                                            1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                               - msi.aggregate_time_fence_date),
                                                                      1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                      2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                         NVL(D.SCHEDULE_SHIP_DATE,
                                                                                             D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                         msi.aggregate_time_fence_date+1),
                                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                               - msi.aggregate_time_fence_date),
                                                                      1, msi.aggregate_time_fence_date,
                                                                         trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                      2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                         NVL(D.SCHEDULE_SHIP_DATE,
                                                                                             D.USING_ASSEMBLY_DEMAND_DATE)))))) demand_date,
                                        trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                     2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                        NVL(D.SCHEDULE_SHIP_DATE,
                                                            D.USING_ASSEMBLY_DEMAND_DATE))) original_demand_date,
                        		decode(d.origination_type, 4, d.daily_demand_rate,
                        		           d.using_requirement_quantity) demand_quantity,
                                        decode(msi.aggregate_time_fence_date,
                                               NULL, peg1.allocated_quantity,
                                               decode(msi.bom_item_type,
                                                      5, 0,
                                                      peg1.allocated_quantity)) allocated_quantity,
                                        d.demand_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, d.origination_type, 51) origination_type,
                        		d.origination_type original_origination_type,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, NULL,
                                                   decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                          - msi.aggregate_time_fence_date),
                                                              1, 1,
                                                              NULL),
                                                          decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                          - msi.aggregate_time_fence_date),
                                                              1, NULL),
                                                              1)) pf_display_flag,
                        		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                        		d.sales_order_line_id,
                                        d.source_organization_id,
                                        d.using_assembly_item_id,
                                        d.customer_id,
                                        d.ship_to_site_id,
                                        /* New Allocation logic for time phased ATP */
/*                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   msi.product_family_id) product_family_id
                        	FROM    msc_full_pegging peg2,
                        	        msc_full_pegging peg1,
                        		msc_demands d,
                                        msc_supplies s,
                                        msc_system_items msi
                        	WHERE   peg1.plan_id = :p_plan_id
                        	AND     peg2.plan_id = peg1.plan_id
                        	AND     peg2.pegging_id = peg1.end_pegging_id
                        	AND     peg2.demand_id IN (-1, -2)
                        	AND     d.demand_id = peg1.demand_id
                        	AND     peg1.plan_id = d.plan_id
                        	AND     d.sr_instance_id = peg1.sr_instance_id
                        	AND     peg1.sr_instance_id=s.sr_instance_id
                        	AND     peg1.plan_id = s.plan_id
                        	AND     peg1.transaction_id = s.transaction_id
                        	AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31)
                        	AND     msi.plan_id = s.plan_id
                                AND     msi.inventory_item_id = s.inventory_item_id
                                AND     msi.sr_instance_id = s.sr_instance_id
                                AND     msi.organization_id = s.organization_id) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.product_family_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.demand_date >=  mv.effective_date (+)
                        AND     pegging_v.demand_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
                        AND     pegging_v.allocated_quantity <> 0
                	GROUP BY
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.demand_date,
                                pegging_v.original_demand_date,
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.original_origination_type,
                                pegging_v.pf_display_flag,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                pegging_v.source_organization_id,
                                pegging_v.using_assembly_item_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
                ELSE
                   x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                original_demand_date,
                                demand_quantity,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                original_origination_type,
                                pf_display_flag,
                                order_number,
                                sales_order_line_id,
                                demand_source_type,--cmro
                                source_organization_id,
                                using_assembly_item_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
                	(
                        SELECT /*+ ordered use_hash(peg2 peg1 d s msi)
                        			parallel(peg2,' || to_char(p_parallel_degree) || ')
                        			parallel(peg1,' || to_char(p_parallel_degree) || ')
                        			parallel(d,' || to_char(p_parallel_degree) || ')
                                                parallel(s,' || to_char(p_parallel_degree) || ')
                                                parallel(msi,' || to_char(p_parallel_degree) || ')
                        			full(peg2) full(peg1) full(d) full(s) full(msi) */
/*                                peg1.plan_id plan_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           decode(sign(s.new_schedule_date - msi.aggregate_time_fence_date),
                                               1, msi.product_family_id,
                                               msi.inventory_item_id)) inventory_item_id,
                                msi.inventory_item_id original_item_id,
                	        peg1.organization_id,
                	        peg1.sr_instance_id,
                	        :def_num demand_class,
                                decode(msi.aggregate_time_fence_date,
                                           NULL,trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                                    D.USING_ASSEMBLY_DEMAND_DATE))),
                                           decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                           2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              NVL(D.SCHEDULE_SHIP_DATE,
                                                                                  D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                  - msi.aggregate_time_fence_date),
                                                      1,trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                     2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                        NVL(D.SCHEDULE_SHIP_DATE,
                                                                            D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      msi.aggregate_time_fence_date+1),
                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                               - msi.aggregate_time_fence_date),
                                                   1, msi.aggregate_time_fence_date,
                                                   trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))))) demand_date,
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                    D.USING_ASSEMBLY_DEMAND_DATE))) original_demand_date,
                		MIN(decode(d.origination_type, 4, d.daily_demand_rate,
                		           d.using_requirement_quantity)) demand_quantity,
                                SUM(decode(msi.aggregate_time_fence_date,
                                       NULL, peg1.allocated_quantity,
                                       decode(msi.bom_item_type,
                                              5, 0,
                                              peg1.allocated_quantity))) allocated_quantity,
                                d.demand_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, d.origination_type, 51) origination_type,
                		d.origination_type original_origination_type,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, NULL,
                                           decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                           2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              NVL(D.SCHEDULE_SHIP_DATE,
                                                                                  D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                  - msi.aggregate_time_fence_date),
                                                      1, 1,
                                                      NULL),
                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                               - msi.aggregate_time_fence_date),
                                                   1, NULL),
                                                   1)) pf_display_flag,
                		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                		d.sales_order_line_id,
                		d.demand_source_type,--cmro
                                d.source_organization_id,
                                d.using_assembly_item_id,
                                d.customer_id,
                                d.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                	FROM    msc_full_pegging peg2,
                	        msc_full_pegging peg1,
                		msc_demands d,
                                msc_supplies s,
                                msc_system_items msi
                	WHERE   peg1.plan_id = :p_plan_id
                	AND     peg2.plan_id = peg1.plan_id
                	AND     peg2.pegging_id = peg1.end_pegging_id
                	AND     peg2.demand_id IN (-1, -2)
                	AND     d.demand_id = peg1.demand_id
                	AND     peg1.plan_id = d.plan_id
                	AND     d.sr_instance_id = peg1.sr_instance_id
                	AND     peg1.sr_instance_id=s.sr_instance_id
                	AND     peg1.plan_id = s.plan_id
                	AND     peg1.transaction_id = s.transaction_id
                	AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31)
                	AND     msi.plan_id = s.plan_id
                        AND     msi.inventory_item_id = s.inventory_item_id
                        AND     msi.sr_instance_id = s.sr_instance_id
                        AND     msi.organization_id = s.organization_id
                	GROUP BY
                                peg1.plan_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           decode(sign(s.new_schedule_date - msi.aggregate_time_fence_date),
                                               1, msi.product_family_id,
                                               msi.inventory_item_id)),
                                msi.inventory_item_id,
                	        peg1.organization_id,
                	        peg1.sr_instance_id,
                	        :def_num,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                          2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                             NVL(D.SCHEDULE_SHIP_DATE,
                                                                                 D.USING_ASSEMBLY_DEMAND_DATE))),
                                           decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                           2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              NVL(D.SCHEDULE_SHIP_DATE,
                                                                                  D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                  - msi.aggregate_time_fence_date),
                                                      1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                      2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                         NVL(D.SCHEDULE_SHIP_DATE,
                                                                             D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      msi.aggregate_time_fence_date+1),
                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                               - msi.aggregate_time_fence_date),
                                                   1, msi.aggregate_time_fence_date,
                                                   trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))))),
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                    D.USING_ASSEMBLY_DEMAND_DATE))),
                                d.demand_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, d.origination_type, 51),
                		d.origination_type,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, NULL,
                                           decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                           2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                              NVL(D.SCHEDULE_SHIP_DATE,
                                                                                  D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                                  - msi.aggregate_time_fence_date),
                                                      1, 1,
                                                      NULL),
                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                                               D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                               - msi.aggregate_time_fence_date),
                                                   1, NULL),
                                                   1)),
                		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
                		d.sales_order_line_id,
                		d.demand_source_type,--cmro
                                d.source_organization_id,
                                d.using_assembly_item_id,
                                d.customer_id,
                                d.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
                END IF;
        ELSE
                -- Prepare demands stmt for creation of bucketed demands/rollup supplies
                x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                original_demand_date,
                                demand_quantity,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                original_origination_type,
                                pf_display_flag,
                                order_number,
                                sales_order_line_id,
                                demand_source_type,--cmro
                                source_organization_id,
                                using_assembly_item_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
                        (SELECT
                                peg1.plan_id plan_id,
                                decode(sign(s.new_schedule_date - msi.aggregate_time_fence_date),
                                           1, msi.product_family_id,
                                           msi.inventory_item_id) inventory_item_id,
                                msi.inventory_item_id original_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                d.demand_class demand_class,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                                 1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                              2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                 NVL(D.SCHEDULE_SHIP_DATE,
                                                                     D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 msi.aggregate_time_fence_date+1),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, msi.aggregate_time_fence_date,
                                           trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                               D.USING_ASSEMBLY_DEMAND_DATE))))) demand_date,
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                    D.USING_ASSEMBLY_DEMAND_DATE))) original_demand_date,
                                MIN(decode(d.origination_type, 4, d.daily_demand_rate,
                		           d.using_requirement_quantity)) demand_quantity,
                                SUM(peg1.allocated_quantity),
                                d.demand_id,
                                51 origination_type, -- ATP Bucketed Demand
                                d.origination_type original_origination_type,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, 1,
                                              NULL),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, NULL),
                                           1) pf_display_flag,
                		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                d.source_organization_id,
                                d.using_assembly_item_id,
                                d.customer_id,
                                d.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        FROM    msc_full_pegging peg1,
                                msc_demands d,
                                msc_supplies s,
                                msc_system_items msi
                        WHERE   d.demand_id = peg1.demand_id
                        AND     d.plan_id = peg1.plan_id
                        AND     d.sr_instance_id = peg1.sr_instance_id
                        AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31)
                        AND     s.transaction_id = peg1.transaction_id
                        AND     s.plan_id = peg1.plan_id
                        AND     msi.plan_id = d.plan_id
                        AND     msi.inventory_item_id = d.inventory_item_id
                        AND     msi.sr_instance_id = d.sr_instance_id
                        AND     msi.organization_id = d.organization_id
                        --AND     nvl(msi.product_family_id, msi.inventory_item_id)<>msi.inventory_item_id
                        AND     msi.aggregate_time_fence_date is not null
                        AND     msi.bom_item_type <> 5
                        AND     msi.plan_id = :p_plan_id
                        GROUP BY
                                peg1.plan_id,
                                decode(sign(s.new_schedule_date - msi.aggregate_time_fence_date),
                                           1, msi.product_family_id,
                                           msi.inventory_item_id),
                                msi.inventory_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                d.demand_class,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                              2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                 NVL(D.SCHEDULE_SHIP_DATE,
                                                                     D.USING_ASSEMBLY_DEMAND_DATE))),
                                              msi.aggregate_time_fence_date+1),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE))) - msi.aggregate_time_fence_date),
                                           1, msi.aggregate_time_fence_date,
                                           trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                        2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                           NVL(D.SCHEDULE_SHIP_DATE,
                                                               D.USING_ASSEMBLY_DEMAND_DATE))))),
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,
                                                    D.USING_ASSEMBLY_DEMAND_DATE))),
                                d.demand_id,
                                51,
                                d.origination_type,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                   2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,
                                                                          D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, 1,
                                              NULL),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(D.SCHEDULE_SHIP_DATE,
                                                                       D.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, NULL),
                                           1),
                		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                d.source_organization_id,
                                d.using_assembly_item_id,
                                d.customer_id,
                                d.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        )';
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Prepare_Demands_Stmt1: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Prepare_Demands_Stmt1;

/*--Prepare_Demands_Stmt2---------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to:
|       -  Prepare demands stmt for preallocation + bucketting for demands
|            NOT pegged to excess/safety stock. (Demand priority AATP)
|  o  Prepares demand stmt for both share plan partition "yes" and "no".
+-------------------------------------------------------------------------*/
/*PROCEDURE Prepare_Demands_Stmt2(
	p_share_partition               IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS

BEGIN
        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_share_partition = 'Y' THEN
           x_sql_stmt := '
                INSERT INTO MSC_ALLOC_DEMANDS(';
        ELSE
           x_sql_stmt := '
                INSERT INTO ' || p_temp_table || '(';
        END IF;

        x_sql_stmt := x_sql_stmt ||'
                        plan_id,
                        inventory_item_id,
                        original_item_id,
                        organization_id,
                        sr_instance_id,
                        demand_class,
                        demand_date,
                        original_demand_date,
                        demand_quantity,
                        allocated_quantity,
                        parent_demand_id,
                        origination_type,
                        original_origination_type,
                        pf_display_flag,
                        order_number,
                        sales_order_line_id,
                        demand_source_type,--cmro
                        source_organization_id,
                        using_assembly_item_id,
                        customer_id,
                        ship_to_site_id,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date)
		(
		SELECT  /*+ use_hash(mv) parallel(mv,' || to_char(p_parallel_degree) || ')
				full(peg1.d1) full(peg1.d2) full(peg1.peg1) full(peg1.peg2) full(mv) full(peg1.tp) */
/*                        pegging_v.plan_id,
                        pegging_v.inventory_item_id,
                        pegging_v.original_item_id,
                        pegging_v.organization_id,
                        pegging_v.sr_instance_id,
                        NVL(mv.demand_class, :def_num) demand_class,
                        pegging_v.demand_date,
                        pegging_v.original_demand_date,
                        MIN(pegging_v.demand_quantity),
                        SUM(pegging_v.allocated_quantity),
                        pegging_v.parent_demand_id,
                        pegging_v.origination_type,
                        pegging_v.original_origination_type,
                        pegging_v.pf_display_flag,
                        pegging_v.order_number,
                        pegging_v.sales_order_line_id,
                        pegging_v.demand_source_type,--cmro
                        pegging_v.source_organization_id,
                        pegging_v.using_assembly_item_id,
                        pegging_v.customer_id,
                        pegging_v.ship_to_site_id,
			:l_user_id,
			:l_sysdate,
			:l_user_id,
			:l_sysdate
		FROM
                        (SELECT /*+ ordered use_hash(d2 peg2 peg1 tp)
					parallel(d2,' || to_char(p_parallel_degree) || ')
					parallel(d1,' || to_char(p_parallel_degree) || ')
					parallel(peg2,' || to_char(p_parallel_degree) || ')
					parallel(peg1,' || to_char(p_parallel_degree) || ')
                                        parallel(tp,'  || to_char(p_parallel_degree) || ') */
/*                                peg2.plan_id plan_id,
                                decode(sign(s.new_schedule_date - msi.aggregate_time_fence_date),
                                           1, msi.product_family_id,
                                           msi.inventory_item_id) inventory_item_id,
                                msi.inventory_item_id original_item_id,
                                peg2.organization_id,
                                peg2.sr_instance_id,
				NVL(d1.demand_class, :def_num) demand_class,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                              2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                 NVL(d2.SCHEDULE_SHIP_DATE,
                                                                     d2.USING_ASSEMBLY_DEMAND_DATE))),
                                           decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                              2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                 NVL(d2.SCHEDULE_SHIP_DATE,
                                                                     d2.USING_ASSEMBLY_DEMAND_DATE))) - msi.aggregate_time_fence_date),
                                                      1, trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                      2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                         NVL(d2.SCHEDULE_SHIP_DATE,
                                                                             d2.USING_ASSEMBLY_DEMAND_DATE))),
                                                      msi.aggregate_time_fence_date+1),
                                               decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                        2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                           NVL(d2.SCHEDULE_SHIP_DATE,
                                                                               d2.USING_ASSEMBLY_DEMAND_DATE)))
                                                                               - msi.aggregate_time_fence_date),
                                                   1, msi.aggregate_time_fence_date,
                                                   trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(d2.SCHEDULE_SHIP_DATE,
                                                                       d2.USING_ASSEMBLY_DEMAND_DATE)))))) demand_date,
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d2.SCHEDULE_SHIP_DATE,
                                                    d2.USING_ASSEMBLY_DEMAND_DATE))) original_demand_date,
                                decode(d2.origination_type, 4, d2.daily_demand_rate,
                		           d2.using_requirement_quantity) demand_quantity,
                                decode(msi.aggregate_time_fence_date,
                                       NULL, peg2.allocated_quantity,
                                       decode(msi.bom_item_type,
                                              5, 0,
                                              peg2.allocated_quantity)) allocated_quantity,
                                d2.demand_id parent_demand_id,
                                51 origination_type, -- ATP Bucketed Demand
                                d2.origination_type original_origination_type,
                                decode(sign(trunc(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                       1, decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                   2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                      NVL(d2.SCHEDULE_SHIP_DATE,
                                                                          d2.USING_ASSEMBLY_DEMAND_DATE)))
                                                                          - msi.aggregate_time_fence_date),
                                              1, 1,
                                              NULL),
                                       decode(sign(trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                                                2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                                   NVL(d2.SCHEDULE_SHIP_DATE,
                                                                       d2.USING_ASSEMBLY_DEMAND_DATE)))
                                                                       - msi.aggregate_time_fence_date),
                                           1, NULL),
                                           1) pf_display_flag,
                		decode(d2.origination_type, 1, to_char(d2.disposition_id), d2.order_number) order_number,
                                d2.sales_order_line_id,
                                d2.demand_source_type,--cmro
                                d2.source_organization_id,
                                d2.using_assembly_item_id,
                                d2.customer_id,
                                d2.ship_to_site_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           msi.product_family_id) product_family_id
                        FROM	msc_demands d2,
				msc_full_pegging peg2,
				msc_full_pegging peg1 ,
				msc_demands d1,
				msc_supplies s,
				msc_system_items msi
                        WHERE	peg2.plan_id = :p_plan_id
                        AND     peg2.plan_id = peg1.plan_id
                        AND	peg2.end_pegging_id = peg1.pegging_id
                        AND	peg2.sr_instance_id = peg1.sr_instance_id
                        AND	d1.plan_id = peg1.plan_id
                        AND	d1.demand_id = peg1.demand_id
                        AND	d1.sr_instance_id = peg1.sr_instance_id
                        AND	d2.plan_id = peg2.plan_id
                        AND	d2.demand_id = peg2.demand_id
                        AND	d2.sr_instance_id = peg2.sr_instance_id
                        AND	d2.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31)
                	AND     peg2.sr_instance_id=s.sr_instance_id
                	AND     peg2.plan_id = s.plan_id
                	AND     peg2.transaction_id = s.transaction_id
                	AND     msi.plan_id = s.plan_id
                        AND     msi.inventory_item_id = s.inventory_item_id
                        AND     msi.sr_instance_id = s.sr_instance_id
                        AND     msi.organization_id = s.organization_id
                        ) pegging_v,
			msc_item_hierarchy_mv mv
		WHERE   pegging_v.product_family_id = mv.inventory_item_id(+)
		AND     pegging_v.organization_id = mv.organization_id (+)
		AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
		AND     pegging_v.demand_date >=  mv.effective_date (+)
		AND     pegging_v.demand_date <=  mv.disable_date (+)
		AND	pegging_v.demand_class = mv.demand_class (+)
		AND     mv.level_id (+) = -1
		AND     pegging_v.allocated_quantity <> 0
		GROUP BY
                        pegging_v.plan_id,
                        pegging_v.inventory_item_id,
                        pegging_v.original_item_id,
                        pegging_v.organization_id,
                        pegging_v.sr_instance_id,
                        NVL(mv.demand_class, :def_num),
                        pegging_v.demand_date,
                        pegging_v.original_demand_date,
                        pegging_v.parent_demand_id,
                        pegging_v.origination_type,
                        pegging_v.original_origination_type,
                        pegging_v.pf_display_flag,
                        pegging_v.order_number,
                        pegging_v.sales_order_line_id,
                        pegging_v.demand_source_type,--cmro
                        pegging_v.source_organization_id,
                        pegging_v.using_assembly_item_id,
                        pegging_v.customer_id,
                        pegging_v.ship_to_site_id,
			:l_user_id,
			:l_sysdate,
			:l_user_id,
			:l_sysdate)';

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Prepare_Demands_Stmt2: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Prepare_Demands_Stmt2;

/*--Prepare_Supplies_Stmt1--------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to:
|       -  Prepare supplies stmt for preallocation + rollup for supplies
|            pegged to excess/safety stock. (Demand priority AATP)
|            :  Excess supply by demand class = No
|            :  Excess supply by demand class = Yes (for project atp)
|       -  Prepare supplies stmt for rollup. (All PDS ATP scenarios except
|            demand priority AATP)
|  o  Prepares supplies stmt for both share plan partition "yes" and "no".
+-------------------------------------------------------------------------*/
/*PROCEDURE Prepare_Supplies_Stmt1(
	p_share_partition               IN      VARCHAR2,
	p_demand_priority               IN      VARCHAR2,
	p_excess_supply_by_dc           IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS

BEGIN
        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_share_partition = 'Y' THEN
           x_sql_stmt := '
                INSERT INTO MSC_ALLOC_SUPPLIES(';
        ELSE
           x_sql_stmt := '
                INSERT INTO ' || p_temp_table || '(';
        END IF;

        IF p_demand_priority = 'Y' THEN
                /* Prepare supplies stmt for preallocation + creation of rollup supplies
                 * project atp changes
                 * If the profile is set to 'Yes' then:
                 *    o If supply has a demand class existing on allocation rule then
                 *      allocate the supply to that demand class.
                 *    o If supply has a demand class not present on allocation rule then
                 *      allocate the supply to 'OTHER'.
                 *    o If supply does not have a demand class present, allocate the supply
                 *      to 'OTHER'.
                 * Else: Allocate the supply to 'OTHER'*/
/*                IF p_excess_supply_by_dc = 'Y' THEN
                   x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                parent_transaction_id,
                                allocated_quantity,
                                supply_quantity,
                                order_type,
                                original_order_type,
                                order_number,
                                schedule_designator_id,
                                customer_id, -- not really required only used in rule based
                                ship_to_site_id, -- not really required only used in rule based
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
        		(
        	        SELECT	/*+  use_hash(pegging_v mv) parallel(mv,' || to_char(p_parallel_degree) || ')  */
/*                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.supply_date,
                                pegging_v.transaction_id,
                                SUM(pegging_v.allocated_quantity),
                                MIN(pegging_v.supply_quantity),
                                pegging_v.order_type,
                                pegging_v.original_order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        FROM
                                (SELECT  /*+ ordered use_hash(peg2 peg1) use_hash(peg1 s msi)
                				parallel(peg2,' || to_char(p_parallel_degree) || ')
                				parallel(peg1,' || to_char(p_parallel_degree) || ')
                				parallel(s,' || to_char(p_parallel_degree) || ')
                                                parallel(msi,' || to_char(p_parallel_degree) || ') */
/*                                        peg1.plan_id plan_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   decode(sign(TRUNC(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                                       1, msi.product_family_id,
                                                       msi.inventory_item_id)) inventory_item_id,
                                        msi.inventory_item_id original_item_id,
                                        peg1.organization_id,
                                        peg1.sr_instance_id,
                                        NVL(s.demand_class, :def_num) demand_class,
                                        TRUNC(s.new_schedule_date) supply_date,
                                        decode(msi.aggregate_time_fence_date,
                                               NULL, peg1.allocated_quantity,
                                               decode(msi.bom_item_type,
                                                      5, 0,
                                                      peg1.allocated_quantity)) allocated_quantity,
                                        s.new_order_quantity supply_quantity,
                                        peg1.transaction_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, s.order_type, 50) order_type
                                        s.order_type original_order_type,
                                        s.order_number,
                                        s.schedule_designator_id,
                                        s.customer_id,
                                        s.ship_to_site_id,
                                        decode(msi.aggregate_time_fence_date,
                                                   NULL, msi.inventory_item_id,
                                                   msi.product_family_id) product_family_id
                                FROM    msc_full_pegging peg2,
                                        msc_full_pegging peg1,
                                	msc_supplies s,
                                	msc_system_items msi
                                WHERE   peg1.plan_id = :p_plan_id
                                AND     peg2.plan_id = peg1.plan_id
                                AND     peg2.pegging_id = peg1.end_pegging_id
                                AND     peg2.demand_id IN (-1, -2)
                                AND     s.plan_id = peg1.plan_id
                                AND     s.transaction_id = peg1.transaction_id
                                AND     s.sr_instance_id = peg1.sr_instance_id
                                AND     msi.sr_instance_id = s.sr_instance_id
                                AND     msi.plan_id = s.plan_id
                                AND     msi.organization_id = s.organization_id
                                AND     msi.inventory_item_id = s.inventory_item_id) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.product_family_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.supply_date >=  mv.effective_date (+)
                        AND     pegging_v.supply_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
                        AND     pegging_v.allocated_quantity <> 0
        		GROUP BY
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.original_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.supply_date,
                                pegging_v.transaction_id,
                                pegging_v.order_type,
                                pegging_v.original_order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                pegging_v.customer_id,
                                pegging_v.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
                ELSE
                   x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                parent_transaction_id,
                                allocated_quantity,
                                supply_quantity,
                                order_type,
                                original_order_type,
                                order_number,
                                schedule_designator_id,
                                customer_id, -- not really required only used in rule based
                                ship_to_site_id, -- not really required only used in rule based
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
        		(
        		SELECT  /*+ ordered use_hash(peg2 peg1) use_hash(peg1 s tp cal)
        				parallel(peg2,' || to_char(p_parallel_degree) || ')
        				parallel(peg1,' || to_char(p_parallel_degree) || ')
        				parallel(s,' || to_char(p_parallel_degree) || ')
                                        parallel(tp,' || to_char(p_parallel_degree) || ') */
/*                                peg1.plan_id plan_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           decode(sign(TRUNC(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, msi.product_family_id,
                                               msi.inventory_item_id)) inventory_item_id,
                                msi.inventory_item_id original_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                :def_num demand_class,
                                TRUNC(s.new_schedule_date) supply_date,
                                SUM(decode(msi.aggregate_time_fence_date,
                                       NULL, peg1.allocated_quantity,
                                       decode(msi.bom_item_type,
                                              5, 0,
                                              peg1.allocated_quantity))) allocated_quantity,
                                MIN(s.new_order_quantity) supply_quantity,
                                peg1.transaction_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, s.order_type, 50) order_type,
                                s.order_type original_order_type,
                                s.order_number,
                                s.schedule_designator_id,
                                s.customer_id,
                                s.ship_to_site_id,
                                :l_user_id created_by,
                                :l_sysdate creation_date,
                                :l_user_id last_updated_by,
                                :l_sysdate last_update_date
        		FROM    msc_full_pegging peg2,
        		        msc_full_pegging peg1,
        			msc_supplies s,
        			msc_system_items msi
        		WHERE   peg1.plan_id = :p_plan_id
        		AND     peg2.plan_id = peg1.plan_id
        		AND     peg2.pegging_id = peg1.end_pegging_id
        		AND     peg2.demand_id IN (-1, -2)
        		AND     s.plan_id = peg1.plan_id
        		AND     s.transaction_id = peg1.transaction_id
        		AND     s.sr_instance_id = peg1.sr_instance_id
                        AND     msi.sr_instance_id = s.sr_instance_id
                        AND     msi.plan_id = s.plan_id
                        AND     msi.organization_id = s.organization_id
                        AND     msi.inventory_item_id = s.inventory_item_id
                        GROUP BY
                                peg1.plan_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           decode(sign(TRUNC(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, msi.product_family_id,
                                               msi.inventory_item_id)),
                                msi.inventory_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                :def_num,
                                TRUNC(s.new_schedule_date),
                                peg1.transaction_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, s.order_type, 50),
                                s.order_type,
                                s.order_number,
                                s.schedule_designator_id,
                                s.customer_id,
                                s.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
                END IF;
        ELSE
                -- Prepare supplies stmt for creation of rollup supplies
                x_sql_stmt := x_sql_stmt ||'
                                plan_id,
                                inventory_item_id,
                                original_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                parent_transaction_id,
                                allocated_quantity,
                                supply_quantity,
                                order_type,
                                original_order_type,
                                order_number,
                                schedule_designator_id,
                                customer_id,
                                ship_to_site_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date)
        		(
                        select  :p_plan_id,
                                decode(sign(TRUNC(s.new_schedule_date) - i.aggregate_time_fence_date),
                                        1, i.product_family_id, s.inventory_item_id),
                                s.inventory_item_id,
                                s.organization_id,
                                s.sr_instance_id,
                                s.demand_class,
                                TRUNC(s.new_schedule_date),
                                s.transaction_id,
                                s.new_order_quantity,
                                s.new_order_quantity,
                                50,
                                s.order_type,
                                s.order_number,
                                s.schedule_designator_id,
                                s.customer_id,
                                s.ship_to_site_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate
                        from    msc_supplies s,
                                msc_system_items i
                        where   i.aggregate_time_fence_date is not null
                        and     i.bom_item_type <> 5
                        and     i.plan_id = :p_plan_id
                        and     s.inventory_item_id = i.inventory_item_id
                        and     s.organization_id = i.organization_id
                        and     s.sr_instance_id = i.sr_instance_id
                        and     s.plan_id = i.plan_id
                        )';
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Prepare_Supplies_Stmt1: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Prepare_Supplies_Stmt1;

/*--Prepare_Supplies_Stmt2-----------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to:
|       -  Prepare supplies stmt for preallocation + supplies rollup for
|            supplies NOT pegged to excess/safety stock.(Demand priority AATP)
|  o  Prepares supplies stmt for both share plan partition "yes" and "no".
+----------------------------------------------------------------------------*/
/*PROCEDURE Prepare_Supplies_Stmt2(
	p_share_partition               IN      VARCHAR2,
	p_temp_table                    IN      VARCHAR2,
	p_parallel_degree               IN      NUMBER,
	x_sql_stmt                      OUT 	NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS

BEGIN
        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_share_partition = 'Y' THEN
           x_sql_stmt := '
                INSERT INTO MSC_ALLOC_SUPPLIES(';
        ELSE
           x_sql_stmt := '
                INSERT INTO ' || p_temp_table || '(';
        END IF;

        x_sql_stmt := x_sql_stmt ||'
                        plan_id,
                        inventory_item_id,
                        original_item_id,
                        organization_id,
                        sr_instance_id,
                        demand_class,
                        supply_date,
                        parent_transaction_id,
                        allocated_quantity,
                        supply_quantity,
                        order_type,
                        original_order_type,
                        order_number,
                        schedule_designator_id,
                        customer_id, -- not really required only used in rule based
                        ship_to_site_id, -- not really required only used in rule based
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date)
		(
		SELECT	/*+  use_hash(peg1 mv) parallel(mv,' || to_char(p_parallel_degree) || ')  */
/*                        pegging_v.plan_id,
                        pegging_v.inventory_item_id,
                        pegging_v.original_item_id,
                        pegging_v.organization_id,
                        pegging_v.sr_instance_id,
                        NVL(mv.demand_class, :def_num) demand_class,
                        pegging_v.supply_date,
                        pegging_v.transaction_id,
                        SUM(pegging_v.allocated_quantity),
                        MIN(pegging_v.supply_quantity),
                        pegging_v.order_type,
                        pegging_v.original_order_type,
                        pegging_v.order_number,
                        pegging_v.schedule_designator_id,
                        pegging_v.customer_id,
                        pegging_v.ship_to_site_id,
                        :l_user_id,
                        :l_sysdate,
                        :l_user_id,
                        :l_sysdate
		FROM
			(SELECT /*+  ordered use_hash(s peg2 peg1 d tp cal)
					parallel(peg2,' || to_char(p_parallel_degree) || ')
					parallel(peg1,' || to_char(p_parallel_degree) || ')
					parallel(s,' || to_char(p_parallel_degree) || ')
					parallel(d,' || to_char(p_parallel_degree) || ')
                                        parallel(tp,' || to_char(p_parallel_degree) || ') */
/*                                peg2.plan_id plan_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           decode(sign(TRUNC(s.new_schedule_date) - msi.aggregate_time_fence_date),
                                               1, msi.product_family_id,
                                               msi.inventory_item_id)) inventory_item_id,
                                msi.inventory_item_id original_item_id,
                                peg2.organization_id,
                                peg2.sr_instance_id,
                                NVL(d.demand_class, :def_num) demand_class,
                                TRUNC(s.new_schedule_date) supply_date,
                                decode(msi.aggregate_time_fence_date,
                                       NULL, peg2.allocated_quantity,
                                       decode(msi.bom_item_type,
                                              5, 0,
                                              peg2.allocated_quantity)) allocated_quantity,
                                s.new_order_quantity supply_quantity,
                                peg2.transaction_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, s.order_type, 50) order_type,
                                s.order_type original_order_type,
                                s.order_number,
                                s.schedule_designator_id,
                                s.customer_id,
                                s.ship_to_site_id,
                                decode(msi.aggregate_time_fence_date,
                                           NULL, msi.inventory_item_id,
                                           msi.product_family_id) product_family_id
			FROM	msc_supplies s,
				msc_full_pegging peg2,
				msc_full_pegging peg1,
				msc_demands d,
                                msc_system_items msi
			WHERE	peg2.plan_id = :p_plan_id
			  AND   peg2.plan_id = peg1.plan_id
			  AND	peg2.end_pegging_id = peg1.pegging_id
			  AND	d.plan_id = peg1.plan_id
			  AND	d.demand_id = peg1.demand_id
			  AND	d.sr_instance_id = peg1.sr_instance_id
			  AND	d.inventory_item_id = peg1.inventory_item_id
			  AND	s.plan_id = peg2.plan_id
			  AND	s.transaction_id = peg2.transaction_id
			  AND	s.sr_instance_id = peg2.sr_instance_id
                          AND   msi.sr_instance_id = s.sr_instance_id
                          AND   msi.plan_id = s.plan_id
                          AND   msi.organization_id = s.organization_id
                          AND   msi.inventory_item_id = s.inventory_item_id
                        ) pegging_v,
			msc_item_hierarchy_mv mv
		WHERE	pegging_v.product_family_id = mv.inventory_item_id(+)
		AND     pegging_v.organization_id = mv.organization_id (+)
		AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
		AND     pegging_v.supply_date >=  mv.effective_date (+)
		AND     pegging_v.supply_date <=  mv.disable_date (+)
		AND	pegging_v.demand_class = mv.demand_class (+)
		AND     mv.level_id (+) = -1
		AND     pegging_v.allocated_quantity <> 0
		GROUP BY
                        pegging_v.plan_id,
                        pegging_v.inventory_item_id,
                        pegging_v.original_item_id,
                        pegging_v.organization_id,
                        pegging_v.sr_instance_id,
                        NVL(mv.demand_class, :def_num),
                        pegging_v.supply_date,
                        pegging_v.transaction_id,
                        pegging_v.order_type,
                        pegging_v.original_order_type,
                        pegging_v.order_number,
                        pegging_v.schedule_designator_id,
                        pegging_v.customer_id,
                        pegging_v.ship_to_site_id,
                        :l_user_id,
                        :l_sysdate,
                        :l_user_id,
                        :l_sysdate)';

EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Prepare_Supplies_Stmt2: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Prepare_Supplies_Stmt2;

/*--Update_Pf_Display_Flag-----------------------------------------------------
|  o  Called from Pf_Post_Plan_Proc procedure to update Pf_Display_Flag to
|       handle scenario when a demand on one side of ATF is satisfied fully
|       from supplies on the other side of ATF.
+----------------------------------------------------------------------------*/
PROCEDURE Update_Pf_Display_Flag(
	p_plan_id                       IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
)
IS
        l_return_status                 VARCHAR2(1);

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Update_Pf_Display_Flag: ' || 'p_plan_id: ' || p_plan_id);
        END IF;

        -- Initializing API return code
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Performance tuning pending
        /*
        UPDATE  MSC_ALLOC_DEMANDS AD
        SET     Pf_Display_Flag = 1
        WHERE   AD.plan_id = p_plan_id
        --AND     AD.allocated_quantity = Demand_Quantity
        AND     AD.pf_display_flag is NULL
        AND     (AD.parent_demand_id, AD.demand_class, 1) in
                    (SELECT AD2.parent_demand_id, AD2.demand_class, count(*)
                     FROM   MSC_ALLOC_DEMANDS AD2
                     WHERE  AD2.plan_id = p_plan_id
                     GROUP BY AD2.parent_demand_id, AD2.demand_class
                    )
        AND     EXISTS (SELECT  1
                        FROM    MSC_SYSTEM_ITEMS I
                        WHERE   I.inventory_item_id = AD.inventory_item_id
                        AND     I.organization_id   = AD.organization_id
                        AND     I.sr_instance_id    = AD.sr_instance_id
                        AND     I.plan_id           = AD.plan_id
                        AND     I.aggregate_time_fence_date is not null);
       */
        --5631956 Modified SQL tuned for better performance.
        UPDATE  MSC_ALLOC_DEMANDS AD
        SET     Pf_Display_Flag = 1
        WHERE   AD.plan_id = p_plan_id
        AND     AD.pf_display_flag is NULL
        AND     EXISTS (SELECT 1
                        FROM   MSC_ALLOC_DEMANDS AD2
                        WHERE  AD2.plan_id = p_plan_id
                        AND    AD.parent_demand_id = AD2.parent_demand_id
                        AND    AD.demand_class = AD2.demand_class
                        GROUP BY AD2.parent_demand_id, AD2.demand_class
                        HAVING count(*) = 1)
        AND     EXISTS (SELECT  1
                        FROM    MSC_SYSTEM_ITEMS I
                        WHERE   I.inventory_item_id = AD.inventory_item_id
                        AND     I.organization_id   = AD.organization_id
                        AND     I.sr_instance_id    = AD.sr_instance_id
                        AND     I.plan_id           = AD.plan_id
                        AND     I.aggregate_time_fence_date is not null);
EXCEPTION
        WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Update_Pf_Display_Flag: ' || 'Error occurred: ' || to_char(sqlcode) || ':' || SQLERRM);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

END Update_Pf_Display_Flag;

-- CTO-PF start
/*--Create_PF_DP_Alloc_Reliefs-----------------------------------------------------
|  o  Called from Gen_Atp_Pegging procedure to insert bucketed demands and
|       rollup supplies in MSC_ATP_PEGGING in demand priority cases
+----------------------------------------------------------------------------*/

PROCEDURE Create_PF_DP_Alloc_Reliefs (p_plan_id         IN          NUMBER,
                                         p_insert_table    IN          VARCHAR2,
                                         p_user_id         IN          NUMBER,
                                         p_sysdate         IN          DATE,
                                         x_return_status   OUT NOCOPY  VARCHAR2
                                        )
IS

l_sql_stmt                      VARCHAR2(800);
l_sql_stmt_1                    VARCHAR2(7000);
l_sql_stmt_2                    VARCHAR2(7000);
-- Default Demand Class
l_def_dmd_class                 VARCHAR2(3) := '-1';


BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Create_PF_DP_Alloc_Reliefs Procedure *****');
     msc_sch_wb.atp_debug(' Plan Id : ' || p_plan_id );
     msc_sch_wb.atp_debug(' Insert Table parameter : ' || p_insert_table );
     msc_sch_wb.atp_debug(' User Id Paramenter : ' || p_user_id );
     msc_sch_wb.atp_debug(' Date Parameter : ' || p_sysdate );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug(' Inserting Demands');
    END IF;

    l_sql_stmt_1 := 'INSERT INTO  ' || p_insert_table ||
             '(reference_item_id,
             inventory_item_id,
             original_item_id,
             original_date,
             plan_id,
             sr_instance_id,
             organization_id,
             sales_order_line_id,
             demand_source_type,
             end_demand_id,
             bom_item_type,
             sales_order_qty,
             transaction_date,
             demand_id,
             demand_quantity,
             disposition_id,
             demand_class,
             consumed_qty,
             overconsumption_qty,
             supply_id,
             supply_quantity,
             allocated_quantity,
             relief_type,
             relief_quantity,
             pegging_id,
             prev_pegging_id,
             end_pegging_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             customer_id,
             customer_site_id)
    SELECT
             peg_v.reference_item_id,
             peg_v.inventory_item_id,
             peg_v.original_item_id,
             peg_v.original_date,
             peg_v.plan_id,
             peg_v.sr_instance_id,
             peg_v.organization_id,
             peg_v.sales_order_line_id,
             peg_v.demand_source_type,
             peg_v.end_demand_id,
             peg_v.bom_item_type,
             peg_v.sales_order_qty,
             peg_v.transaction_date,
             peg_v.demand_id ,
             peg_v.demand_quantity,
             peg_v.disposition_id,
             NVL(mv.demand_class, :l_def_dmd_class) demand_class ,
             peg_v.consumed_qty,
             peg_v.overconsumption_qty,
             peg_v.supply_id,
             peg_v.supply_quantity,
             peg_v.allocated_quantity,
             peg_v.relief_type,
             peg_v.relief_quantity,
             peg_v.pegging_id,
             peg_v.prev_pegging_id,
             peg_v.end_pegging_id,
             :p_user_id,
             :p_sysdate,
             :p_user_id,
             :p_sysdate,
             mv.partner_id,
             mv.partner_site_id

    FROM
        (SELECT mapt.reference_item_id reference_item_id,
                decode(mapt.atf_date,
                       NULL, mapt.inventory_item_id,
                       decode(sign(trunc(s.new_schedule_date) - mapt.atf_date),
                              1, mapt.product_family_id,
                              mapt.inventory_item_id
                              )
                       ) inventory_item_id,
                mapt.inventory_item_id original_item_id,
                mapt.transaction_date original_date,
                mapt.plan_id plan_id,
                mapt.sr_instance_id sr_instance_id,
                mapt.organization_id organization_id,
                mapt.sales_order_line_id sales_order_line_id,
                mapt.demand_source_type demand_source_type,
                mapt.end_demand_id end_demand_id,
                mapt.bom_item_type bom_item_type,
                mapt.sales_order_qty sales_order_qty,
                decode(mapt.atf_date,
                       NULL, trunc(mapt.transaction_date),
                       decode(sign(trunc(s.new_schedule_date) - mapt.atf_date),
                         1, decode(sign(trunc(mapt.transaction_date)- mapt.atf_date),
                                        1, trunc(mapt.transaction_date),
                                        mapt.atf_date+1
                                  ),
                         decode(sign(trunc(mapt.transaction_date)- mapt.atf_date),
                                     1, mapt.atf_date,
                                     trunc(mapt.transaction_date)
                                )
                              )
                       )transaction_date,
                mapt.demand_id demand_id,
                mapt.demand_quantity demand_quantity,
                mapt.disposition_id disposition_id,
                NVL(mapt.demand_class, :l_def_dmd_class) demand_class ,
                mapt.consumed_qty consumed_qty,
                mapt.overconsumption_qty overconsumption_qty,
                mapt.supply_id supply_id,
                mapt.supply_quantity supply_quantity,
                mapt.allocated_quantity allocated_quantity,
                decode(mapt.atf_date,
                       NULL,5,7) relief_type,
                mapt.relief_quantity  relief_quantity,
                mapt.pegging_id pegging_id,
                mapt.prev_pegging_id prev_pegging_id,
                mapt.end_pegging_id end_pegging_id,
                mapt.atf_date atf_date,
                mapt.product_family_id product_family_id
        FROM    msc_atp_peg_temp mapt,
                msc_supplies s
        WHERE   mapt.plan_id = :p_plan_id
        AND     mapt.relief_type = 3

        AND     s.sr_instance_id = mapt.sr_instance_id
        AND     s.plan_id = mapt.plan_id
        AND     s.transaction_id = mapt.supply_id) peg_v,
                msc_item_hierarchy_mv mv
    WHERE
             decode(peg_v.atf_date,
                       NULL,peg_v.inventory_item_id,
                       peg_v.product_family_id) = mv.inventory_item_id(+)
     AND     peg_v.organization_id = mv.organization_id (+)
     AND     peg_v.sr_instance_id = mv.sr_instance_id (+)
     AND     peg_v.transaction_date >=  mv.effective_date (+)
     AND     peg_v.transaction_date <=  mv.disable_date (+)
     AND     peg_v.demand_class = mv.demand_class (+)
     AND     mv.level_id (+) = -1';

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('SQL statement to be executed ' || length(l_sql_stmt_1) || ':' || l_sql_stmt_1);
    END IF;
    EXECUTE IMMEDIATE l_sql_stmt_1 USING
                        l_def_dmd_class,
                        p_user_id, p_sysdate, p_user_id, p_sysdate,
                        l_def_dmd_class,p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Create_PF_DP_Alloc_Reliefs:  Number of Demand rows inserted '||
                               SQL%ROWCOUNT);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug(' Inserting Supplies');
    END IF;

    l_sql_stmt_1 := 'INSERT INTO  ' || p_insert_table ||
             '(reference_item_id,
             inventory_item_id,
             plan_id,
             sr_instance_id,
             organization_id,
             sales_order_line_id,
             demand_source_type,
             end_demand_id,
             bom_item_type,
             sales_order_qty,
             transaction_date,
             demand_id,
             demand_quantity,
             disposition_id,
             demand_class,
             consumed_qty,
             overconsumption_qty,
             supply_id,
             supply_quantity,
             allocated_quantity,
             relief_type,
             relief_quantity,
             pegging_id,
             prev_pegging_id,
             end_pegging_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             customer_id,
             customer_site_id)
    SELECT   mapt.reference_item_id,
             mapt.inventory_item_id,
             mapt.plan_id,
             mapt.sr_instance_id,
             mapt.organization_id,
             mapt.sales_order_line_id,
             mapt.demand_source_type,
             mapt.end_demand_id,
             mapt.bom_item_type,
             mapt.sales_order_qty,
             mapt.transaction_date,
             mapt.demand_id ,
             mapt.demand_quantity,
             mapt.disposition_id,
             NVL(mv.demand_class, :l_def_dmd_class) demand_class ,
             mapt.consumed_qty,
             mapt.overconsumption_qty,
             mapt.supply_id,
             mapt.supply_quantity,
             mapt.allocated_quantity ,
             6,
             mapt.relief_quantity ,
             mapt.pegging_id,
             mapt.prev_pegging_id,
             mapt.end_pegging_id,
             :p_user_id,
             :p_sysdate,
             :p_user_id,
             :p_sysdate,
             mv.partner_id,
             mv.partner_site_id customer_site_id
    FROM    msc_atp_peg_temp mapt, msc_item_hierarchy_mv mv
    WHERE   mapt.plan_id = :p_plan_id
    AND     mapt.relief_type = 2
    AND     mapt.inventory_item_id = mv.inventory_item_id(+)
    AND     mapt.organization_id = mv.organization_id (+)
    AND     mapt.sr_instance_id = mv.sr_instance_id (+)
    AND     mapt.transaction_date >=  mv.effective_date (+)
    AND     mapt.transaction_date <=  mv.disable_date (+)
    AND     mapt.demand_class = mv.demand_class (+)
    AND     mv.level_id (+) = -1 '
    ;

    EXECUTE IMMEDIATE l_sql_stmt_1 USING
                        l_def_dmd_class,
                        p_user_id, p_sysdate, p_user_id, p_sysdate, p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Create_PF_DP_Alloc_Reliefs:  Number of Supply rows inserted '||
                               SQL%ROWCOUNT);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Inside main exception of Create_PF_DP_Alloc_Reliefs');
        msc_sch_wb.atp_debug ('Create_PF_DP_Alloc_Reliefs. Error : ' || sqlcode || ': '|| sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_PF_DP_Alloc_Reliefs;

/*--Create_PF_Allocation_Reliefs-----------------------------------------------------
|  o  Called from Gen_Atp_Pegging procedure to insert bucketed demands and
|       rollup supplies in MSC_ATP_PEGGING in non demand priority cases
+----------------------------------------------------------------------------*/

PROCEDURE Create_PF_Allocation_Reliefs (p_plan_id         IN          NUMBER,
                                         p_insert_table    IN          VARCHAR2,
                                         p_user_id         IN          NUMBER,
                                         p_sysdate         IN          DATE,
                                         x_return_status   OUT NOCOPY  VARCHAR2
                                        )
IS

l_sql_stmt                      VARCHAR2(800);
l_sql_stmt_1                    VARCHAR2(5000);
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Create_PF_Allocation_Reliefs Procedure *****');
     msc_sch_wb.atp_debug(' Plan Id : ' || p_plan_id );
     msc_sch_wb.atp_debug(' Insert Table parameter : ' || p_insert_table );
     msc_sch_wb.atp_debug(' User Id Paramenter : ' || p_user_id );
     msc_sch_wb.atp_debug(' Date Parameter : ' || p_sysdate );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug(' Inserting Demands');
    END IF;


    l_sql_stmt_1 := 'INSERT INTO  ' || p_insert_table || -- actually the insert table parameter.
             '(reference_item_id,
             inventory_item_id,
             original_item_id,
             original_date,
             plan_id,
             sr_instance_id,
             organization_id,
             sales_order_line_id,
             demand_source_type,
             end_demand_id,
             bom_item_type,
             sales_order_qty,
             transaction_date,
             demand_id,
             demand_quantity,
             disposition_id,
             consumed_qty,
             overconsumption_qty,
             supply_id,
             supply_quantity,
             allocated_quantity,
             relief_type,
             relief_quantity,
             pegging_id,
             prev_pegging_id,
             end_pegging_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             customer_id,
             customer_site_id)
    SELECT   mapt.reference_item_id reference_item_id,
             decode(sign(trunc(s.new_schedule_date) - mapt.atf_date),
                         1, mapt.product_family_id,
                            mapt.inventory_item_id) inventory_item_id,
             mapt.inventory_item_id,
             mapt.transaction_date,
             mapt.plan_id plan_id,
             mapt.sr_instance_id sr_instance_id,
             mapt.organization_id organization_id,
             mapt.sales_order_line_id sales_order_line_id,
             mapt.demand_source_type demand_source_type,
             mapt.end_demand_id end_demand_id,
             mapt.bom_item_type bom_item_type,
             mapt.sales_order_qty sales_order_qty,
             decode(sign(trunc(s.new_schedule_date) - mapt.atf_date),
                         1, decode(sign(trunc(mapt.transaction_date)- mapt.atf_date),
                                        1, trunc(mapt.transaction_date),
                                        mapt.atf_date+1),
                         decode(sign(trunc(mapt.transaction_date)- mapt.atf_date),
                                     1, mapt.atf_date,
                                     trunc(mapt.transaction_date)
                                )
                    ) transaction_date,
             mapt.demand_id demand_id,
             mapt.demand_quantity demand_quantity,
             mapt.disposition_id disposition_id,
             mapt.consumed_qty consumed_qty,
             mapt.overconsumption_qty overconsumption_qty,
             mapt.supply_id supply_id,
             mapt.supply_quantity supply_quantity,
             mapt.allocated_quantity allocated_quantity,
             7 relief_type, --PF ATP
             mapt.relief_quantity relief_quantity,
             mapt.pegging_id pegging_id,
             mapt.prev_pegging_id prev_pegging_id,
             mapt.end_pegging_id end_pegging_id,
             :p_user_id,
             :p_sysdate,
             :p_user_id,
             :p_sysdate,
             mapt.customer_id,
             mapt.customer_site_id
    FROM    msc_atp_peg_temp mapt,
            msc_supplies s
    WHERE   mapt.plan_id = :p_plan_id
    AND     mapt.relief_type = 3

    AND     s.sr_instance_id = mapt.sr_instance_id
    AND     s.plan_id = mapt.plan_id
    AND     s.transaction_id = mapt.supply_id';

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('SQL statement to be executed ' || length(l_sql_stmt_1) || ':' || l_sql_stmt_1);
    END IF;
    EXECUTE IMMEDIATE l_sql_stmt_1 USING
                        p_user_id, p_sysdate, p_user_id, p_sysdate, p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Create_PF_Allocation_Reliefs:  Number of Demand rows inserted '||
                               SQL%ROWCOUNT);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Inside main exception of Create_PF_Allocation_Reliefs');
        msc_sch_wb.atp_debug ('Create_PF_Allocation_Reliefs. Error : ' || sqlcode || ': '|| sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_PF_Allocation_Reliefs;
-- CTO-PF end
END MSC_ATP_PF;

/

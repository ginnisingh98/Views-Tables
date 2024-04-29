--------------------------------------------------------
--  DDL for Package MSC_ATP_PF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_PF" AUTHID CURRENT_USER AS
/* $Header: MSCPFATS.pls 120.1 2007/12/12 10:35:44 sbnaik ship $  */

/* Types of consumption*/
Backward                CONSTANT INTEGER := 1;
Forward                 CONSTANT INTEGER := 2;
Cum                     CONSTANT INTEGER := 3;
Bw_Fw_Cum               CONSTANT INTEGER := 4;
Bw_Fw                   CONSTANT INTEGER := 5;

/* Profile setup*/
Demand_Priority         CONSTANT INTEGER := 1;
User_Defined_DC         CONSTANT INTEGER := 2;
User_Defined_CC         CONSTANT INTEGER := 3;

MADT                    CONSTANT NUMBER         := 1;
MASDDT                  CONSTANT NUMBER         := 2;

TYPE Bucketed_Demands_Rec is RECORD (
        mem_item_id             NUMBER,
        mem_bd_date             DATE,
        mem_bd_qty              NUMBER,
        mem_display_flag        NUMBER,
        pf_item_id              NUMBER,
        pf_bd_date              DATE,
        pf_bd_qty               NUMBER,
        pf_display_flag         NUMBER,
        insert_mem_bd           VARCHAR2(1),
        insert_pf_bd            VARCHAR2(1)
);

PROCEDURE Add_PF_Bucketed_Demands(
        p_atp_rec          		IN	MRP_ATP_PVT.AtpRec,
        p_plan_id          		IN	NUMBER,
        p_parent_demand_id 		IN	NUMBER,
        p_refresh_number                IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Update_PF_Bucketed_Demands(
        p_plan_id                       IN	NUMBER,
        p_parent_demand_id              IN	NUMBER,
        p_demand_date                   IN	DATE,
        p_atf_date                      IN      DATE,
        p_old_demand_date_qty           IN      NUMBER,
        p_new_demand_date_qty           IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Increment_Bucketed_Demands_Qty(
        p_atp_rec               IN OUT  NOCOPY MRP_ATP_PVT.AtpRec,
        p_plan_id               IN	NUMBER,
        p_parent_demand_id      IN	NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2
);

PROCEDURE Move_PF_Bucketed_Demands(
        p_plan_id                       IN	NUMBER,
        p_parent_demand_id              IN	NUMBER,
        p_old_demand_date               IN	DATE,
        p_new_demand_date               IN	DATE,
        p_demand_qty                    IN      NUMBER,
        p_new_demand_date_qty           IN      NUMBER,
        p_atf_date                      IN      DATE,
        p_atf_date_qty                  IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        p_bkwd_pass_atf_date_qty         IN      NUMBER, --bug3397904
        p_atp_rec                       IN      MRP_ATP_PVT.AtpRec := NULL
);

PROCEDURE Find_PF_Bucketed_Demands(
        p_plan_id                       IN	NUMBER,
        p_parent_demand_id              IN	NUMBER,
        p_bucketed_demands_rec          IN OUT	NOCOPY MSC_ATP_PF.Bucketed_Demands_Rec,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

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
);

PROCEDURE Update_PF_Rollup_Supplies(
        p_plan_id          		IN	NUMBER,
        p_parent_transaction_id         IN	NUMBER,
        p_mem_item_id                   IN	NUMBER,
        p_pf_item_id                    IN	NUMBER,
        p_date                          IN      DATE,
        p_quantity                      IN      NUMBER,
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

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
        p_ato_model_line_id               IN      NUMBER,
        p_demand_source_type            IN      NUMBER,--cmro
        --bug3684383
        p_order_number                  IN      NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

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
);

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
);

PROCEDURE Set_Alloc_Rule_Variables (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Item_Alloc_Avail_Pf (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_level_id                      IN      NUMBER,
        p_itf                           IN      DATE,
        p_sys_next_date			IN	DATE,	--bug3099066
        p_atf_date                      IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Item_Alloc_Avail_Pf_Unalloc (
        p_member_id                     IN      NUMBER,
        p_family_id                     IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_level_id                      IN      NUMBER,
        p_itf                           IN      DATE,
        p_sys_next_date			IN	DATE,	--bug3099066
        p_atf_date                      IN      DATE,
        x_atp_dates                     OUT     NOCOPY MRP_ATP_PUB.date_arr,
        x_atp_qtys                      OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_atp_unalloc_qtys              OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

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
        p_sys_next_date			IN	DATE,	--bug3099066
        p_atf_date                      IN      DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

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
);

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
);

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
);

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
);

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
);

PROCEDURE Insert_SD_Into_Details_Temp (
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
);

PROCEDURE Populate_Original_Demand_Qty(
	p_table                         IN      NUMBER,
	p_session_id                    IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE PF_Atp_Consume(
        p_atp_qty                       IN OUT  NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        p_atp_period                    IN      MRP_ATP_PUB.date_arr  :=NULL,
        p_consumption_type              IN      NUMBER := Bw_Fw_Cum,
        p_atf_date                      IN      DATE := NULL
);

PROCEDURE PF_Atp_Alloc_Consume(
        p_atp_qty                       IN OUT  NOCOPY MRP_ATP_PUB.number_arr,
        p_atp_period                    IN      MRP_ATP_PUB.date_arr,
	p_atp_dc_tab	                IN      MRP_ATP_PUB.char80_arr,
	p_atf_date                      IN      DATE,
	x_dc_list_tab	                OUT     NOCOPY MRP_ATP_PUB.char80_arr,
	x_dc_start_index                OUT     NOCOPY MRP_ATP_PUB.number_arr,
	x_dc_end_index                  OUT     NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Period_Data_From_Sd_Temp(
        x_atp_period                    OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Unalloc_Data_From_Sd_Temp(
        x_atp_period                    OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
        p_unallocated_atp		IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
        x_return_status 		OUT     NOCOPY VARCHAR2
);

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
);

FUNCTION Get_Pf_Atp_Item_Id(
        p_instance_id	                IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_inventory_item_id             IN      NUMBER,
        p_organization_id               IN      NUMBER
)
RETURN NUMBER;

FUNCTION Get_Atf_Date(
        p_instance_id                   IN      NUMBER,
        p_inventory_item_id             IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_plan_id                       IN      NUMBER
)
RETURN DATE;

FUNCTION Get_Atf_Days(
        p_instance_id                   IN      NUMBER,
        p_inventory_item_id             IN      NUMBER,
        p_organization_id               IN      NUMBER
)
RETURN NUMBER;

PROCEDURE Get_Family_Item_Info(
        p_instance_id	                IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_inventory_item_id             IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_family_id                     OUT     NOCOPY NUMBER,
        p_sr_family_id                  OUT     NOCOPY NUMBER,
        p_atf_date                      OUT     NOCOPY DATE,
        --bug3700564
        p_family_name                   OUT     NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_PF_Plan_Info(
        p_instance_id	                IN      NUMBER,
        p_member_item_id                IN      NUMBER,
        p_family_item_id                IN      NUMBER,
        p_org_id                        IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        p_atf_date                      OUT     NOCOPY DATE,
        p_error_code                    OUT     NOCOPY NUMBER,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        p_parent_plan_id                IN      NUMBER DEFAULT NULL --bug3510475
);

PROCEDURE Populate_ATF_Dates(
        p_plan_id          		IN	NUMBER,
        x_member_count                  OUT     NOCOPY NUMBER,
        x_return_status                 OUT	NOCOPY VARCHAR2
);

PROCEDURE Pf_Post_Plan_Proc(
	ERRBUF                          OUT     NOCOPY VARCHAR2,
	RETCODE                         OUT     NOCOPY NUMBER,
	p_plan_id                       IN 	NUMBER,
	p_demand_priority               IN      VARCHAR2
);
--CTO-PF start
PROCEDURE Create_PF_Allocation_Reliefs (
        p_plan_id         IN          NUMBER,
        p_insert_table    IN          VARCHAR2,
        p_user_id         IN          NUMBER,
        p_sysdate         IN          DATE,
        x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE Create_PF_DP_Alloc_Reliefs (
        p_plan_id         IN          NUMBER,
        p_insert_table    IN          VARCHAR2,
        p_user_id          IN          NUMBER,
        p_sysdate         IN          DATE,
        x_return_status   OUT NOCOPY  VARCHAR2
);
--CTO-PF end
END MSC_ATP_PF;

/

--------------------------------------------------------
--  DDL for Package MSC_AATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_AATP_PVT" AUTHID CURRENT_USER AS
/* $Header: MSCAATPS.pls 120.1 2007/12/12 10:03:19 sbnaik ship $  */

G_HIERARCHY_PROFILE     NUMBER := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);

PROCEDURE Atp_Demand_Class_Consume(
	p_current_atp   	IN OUT  NoCopy MRP_ATP_PVT.ATP_Info,
	p_steal_atp     	IN OUT  NoCopy MRP_ATP_PVT.ATP_Info,
	p_atf_date          IN DATE := NULL);   -- time_phased_atp


PROCEDURE Add_to_Next_Steal_Atp(
	p_current_atp      	IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info, --rajjain AATP Forward Consumption
	p_next_steal_atp   	IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info);


PROCEDURE Item_Alloc_Cum_Atp(
	p_plan_id 	      IN NUMBER,
	p_level               IN NUMBER,
	p_identifier          IN NUMBER,
	p_scenario_id         IN NUMBER,
	p_inventory_item_id   IN NUMBER,
	p_organization_id     IN NUMBER,
	p_instance_id         IN NUMBER,
	p_demand_class        IN VARCHAR2,
	p_request_date        IN DATE,
	p_insert_flag         IN NUMBER,
	x_atp_info            OUT  NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          OUT  NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   OUT  NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
        p_get_mat_in_rec      IN   MSC_ATP_REQ.get_mat_in_rec,
	p_request_item_id     IN NUMBER, -- For time_phased_atp
	p_atf_date            IN DATE    -- For time_phased_atp
);


PROCEDURE Res_Alloc_Cum_Atp(
	p_plan_id             	IN 	NUMBER,
	p_level               	IN 	NUMBER,
	p_identifier          	IN 	NUMBER,
	p_scenario_id         	IN 	NUMBER,
	p_department_id       	IN 	NUMBER,
	p_resource_id	        IN 	NUMBER,
	p_organization_id     	IN 	NUMBER,
	p_instance_id         	IN 	NUMBER,
	p_demand_class        	IN 	VARCHAR2,
	p_request_date        	IN 	DATE,
	p_insert_flag         	IN 	NUMBER,
        p_max_capacity          IN      NUMBER,
        p_batchable_flag        IN      NUMBER,
        p_res_conversion_rate	IN	NUMBER,
        p_res_uom_type          IN      NUMBER,
	x_atp_info            	OUT 	NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          	OUT 	NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   	OUT 	NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ);

/* spec changed as part of ship_rec_cal changes
   various input parameters passed in a record atp_info_rec
*/
PROCEDURE Supplier_Alloc_Cum_Atp(
        p_sup_atp_info_rec      IN      MSC_ATP_REQ.ATP_Info_Rec,
	p_identifier          	IN 	NUMBER,
	p_request_date        	IN 	DATE,
	x_atp_info            	OUT 	NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          	OUT 	NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   	OUT 	NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ
);


PROCEDURE Get_DC_Info(
	p_instance_id 		IN 	NUMBER,
	p_inv_item_id 		IN 	NUMBER,
	p_org_id 		IN 	NUMBER,
	p_dept_id 		IN 	NUMBER,
	p_res_id  		IN 	NUMBER,
	p_demand_class 		IN 	VARCHAR2,
	p_request_date 		IN 	DATE,
	x_level_id            	OUT 	NoCopy NUMBER,
	x_priority  		OUT 	NoCopy NUMBER,
	x_alloc_percent		OUT 	NoCopy NUMBER,
	x_return_status       	OUT 	NoCopy VARCHAR2);


PROCEDURE View_Allocation(
	p_session_id         	IN    	NUMBER,
	p_inventory_item_id  	IN    	NUMBER,
	p_instance_id        	IN    	NUMBER,
	p_organization_id    	IN    	NUMBER,
	p_department_id      	IN    	NUMBER,
	p_resource_id        	IN    	NUMBER,
	p_demand_class       	IN    	VARCHAR2,
	x_return_status      	OUT   	NoCopy VARCHAR2);

PROCEDURE Stealing (
    p_atp_record                IN OUT  NoCopy MRP_ATP_PVT.AtpRec,
    p_parent_pegging_id         IN      NUMBER,
    p_scenario_id               IN      NUMBER,
    p_level                     IN      NUMBER,
    p_search                    IN      NUMBER,
    p_plan_id                   IN      NUMBER,
    p_net_demand                IN OUT  NoCopy NUMBER,
    x_total_mem_stealing_qty    OUT     NOCOPY NUMBER, -- For time_phased_atp
    x_total_pf_stealing_qty     OUT     NOCOPY NUMBER, -- For time_phased_atp
    x_atp_supply_demand         OUT     NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
    x_atp_period                OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
    x_return_status             OUT     NoCopy VARCHAR2,
    p_refresh_number            IN      NUMBER    -- For summary enhancement
);


END MSC_AATP_PVT;

/

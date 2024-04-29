--------------------------------------------------------
--  DDL for Package MRP_AATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_AATP_PVT" AUTHID CURRENT_USER AS
/* $Header: MRPAATPS.pls 115.12 2002/12/02 20:43:30 dsting noship $  */

PROCEDURE Atp_Demand_Class_Consume(
  p_current_atp   IN OUT  NoCopy MRP_ATP_PVT.ATP_Info,
  p_steal_atp     IN OUT  NoCopy MRP_ATP_PVT.ATP_Info);

PROCEDURE Add_to_Next_Steal_Atp(
  p_current_atp      IN      MRP_ATP_PVT.ATP_Info,
  p_next_steal_atp   IN OUT  NoCopy MRP_ATP_PVT.ATP_Info);

FUNCTION Get_Item_Demand_Alloc_Percent(
  p_plan_id 		IN NUMBER,
  p_demand_id 		IN NUMBER,
  p_demand_date 	IN DATE,
  p_assembly_item_id 	IN NUMBER,
  p_source_org_id       IN NUMBER,
  p_inventory_item_id   IN NUMBER,
  p_org_id 		IN NUMBER,
  p_instance_id 	IN NUMBER,
  p_origination_type 	IN NUMBER,
  p_record_class 	IN VARCHAR2,
  p_demand_class 	IN VARCHAR2,
  p_level_id            IN NUMBER)
RETURN NUMBER;

FUNCTION Get_DC_Alloc_Percent(
  p_instance_id 	IN NUMBER,
  p_inv_item_id 	IN NUMBER,
  p_org_id 		IN NUMBER,
  p_dept_id 		IN NUMBER,
  p_res_id  		IN NUMBER,
  p_demand_class 	IN VARCHAR2,
  p_request_date 	IN DATE)
RETURN NUMBER;

FUNCTION Get_Res_Demand_Alloc_Percent(
  p_demand_date 	IN DATE,
  p_assembly_item_id 	IN NUMBER,
  p_org_id 		IN NUMBER,
  p_instance_id 	IN NUMBER,
  p_dept_id             IN NUMBER,
  p_res_id              IN NUMBER,
  p_record_class 	IN VARCHAR2,
  p_demand_class 	IN VARCHAR2)
RETURN NUMBER;

PROCEDURE Item_Alloc_Cum_Atp(
  p_plan_id 		IN NUMBER,
  p_level               IN NUMBER,
  p_identifier          IN NUMBER,
  p_scenario_id         IN NUMBER,
  p_inventory_item_id 	IN NUMBER,
  p_organization_id 	IN NUMBER,
  p_instance_id 	IN NUMBER,
  p_demand_class 	IN VARCHAR2,
  p_request_date        IN DATE,
  p_insert_flag  	IN NUMBER,
  x_atp_info            OUT NoCopy MRP_ATP_PVT.ATP_Info,
  x_atp_period 		OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand 	OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ);

PROCEDURE Res_Alloc_Cum_Atp(
  p_plan_id             IN NUMBER,
  p_level               IN NUMBER,
  p_identifier          IN NUMBER,
  p_scenario_id         IN NUMBER,
  p_department_id       IN NUMBER,
  p_resource_id	        IN NUMBER,
  p_organization_id     IN NUMBER,
  p_instance_id         IN NUMBER,
  p_demand_class        IN VARCHAR2,
  p_request_date        IN DATE,
  p_insert_flag         IN NUMBER,
  p_max_capacity        IN      NUMBER,
  p_batchable_flag      IN      NUMBER,
  p_res_conversion_rate IN      NUMBER,
  p_res_uom_type	IN      NUMBER,
  x_atp_info            OUT NoCopy MRP_ATP_PVT.ATP_Info,
  x_atp_period          OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ);

PROCEDURE Supplier_Alloc_Cum_Atp(
  p_plan_id             IN NUMBER,
  p_level               IN NUMBER,
  p_identifier          IN NUMBER,
  p_scenario_id         IN NUMBER,
  p_supplier_id         IN NUMBER,
  p_supplier_site_id    IN NUMBER,
  p_inventory_item_id   IN NUMBER,
  p_organization_id     IN NUMBER,
  p_instance_id         IN NUMBER,
  p_demand_class        IN VARCHAR2,
  p_request_date        IN DATE,
  p_insert_flag         IN NUMBER,
  x_atp_info            OUT NoCopy MRP_ATP_PVT.ATP_Info,
  x_atp_period          OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ);

PROCEDURE Get_DC_Info(
  p_instance_id 	IN NUMBER,
  p_inv_item_id 	IN NUMBER,
  p_org_id 		IN NUMBER,
  p_dept_id 		IN NUMBER,
  p_res_id  		IN NUMBER,
  p_demand_class 	IN VARCHAR2,
  p_request_date 	IN DATE,
  x_level_id            OUT NoCopy NUMBER,
  x_priority  		OUT NoCopy NUMBER,
  x_alloc_percent	OUT NoCopy NUMBER,
  x_return_status       OUT NoCopy VARCHAR2);

PROCEDURE View_Allocation(
  p_session_id         IN    NUMBER,
  p_inventory_item_id  IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_department_id      IN    NUMBER,
  p_resource_id        IN    NUMBER,
  p_demand_class       IN    VARCHAR2,
  x_return_status      OUT   NoCopy VARCHAR2);

FUNCTION Get_Hierarchy_Demand_Class(
  p_partner_id         IN    NUMBER,
  p_partner_site_id    IN    NUMBER,
  p_inventory_item_id  IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_request_date       IN    DATE,
  p_level_id           IN    NUMBER,
  p_demand_class       IN    VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Allowed_Stolen_Percent(
  p_instance_id         IN NUMBER,
  p_inv_item_id         IN NUMBER,
  p_org_id              IN NUMBER,
  p_dept_id             IN NUMBER,
  p_res_id              IN NUMBER,
  p_demand_class        IN VARCHAR2,
  p_request_date        IN DATE)
RETURN NUMBER;

END MRP_AATP_PVT;

 

/

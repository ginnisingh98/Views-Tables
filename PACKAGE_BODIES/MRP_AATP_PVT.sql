--------------------------------------------------------
--  DDL for Package Body MRP_AATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_AATP_PVT" AS
/* $Header: MRPAATPB.pls 115.28 2003/10/14 07:18:21 ssurendr noship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MRP_AATP_PVT';


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Atp_Demand_Class_Consume(
        p_current_atp   IN OUT  NoCopy MRP_ATP_PVT.ATP_Info,
        p_steal_atp     IN OUT  NoCopy MRP_ATP_PVT.ATP_Info)
IS
BEGIN
	MSC_AATP_PVT.Atp_Demand_Class_Consume(p_current_atp, p_steal_atp);
END Atp_Demand_Class_Consume;


PROCEDURE Add_to_Next_Steal_Atp(
        p_current_atp      IN      MRP_ATP_PVT.ATP_Info,
        p_next_steal_atp   IN OUT  NoCopy MRP_ATP_PVT.ATP_Info)
IS
        l_current_atp      MRP_ATP_PVT.ATP_Info;
BEGIN
	-- modified to call MSC_AATP_PVT.Add_to_Next_Steal_Atp with l_current_atp
	-- due to the changes in spec after the AATP forward consumption changes.
	l_current_atp := p_current_atp;
	MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_atp, p_next_steal_atp);
END Add_to_Next_Steal_Atp;

FUNCTION Get_Item_Demand_Alloc_Percent(
	p_plan_id 		IN 	NUMBER,
	p_demand_id 		IN 	NUMBER,
	p_demand_date 		IN 	DATE,
	p_assembly_item_id 	IN 	NUMBER,
        p_source_org_id         IN      NUMBER,
	p_inventory_item_id 	IN 	NUMBER,
	p_org_id 		IN 	NUMBER,
	p_instance_id 		IN 	NUMBER,
	p_origination_type 	IN 	NUMBER,
	p_record_class 		IN 	VARCHAR2,
	p_demand_class 		IN 	VARCHAR2,
        p_level_id              IN      NUMBER)
RETURN NUMBER
IS
BEGIN
  return MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(
        p_plan_id,
        p_demand_id,
        p_demand_date,
        p_assembly_item_id,
        p_source_org_id,
        p_inventory_item_id,
        p_org_id,
        p_instance_id,
        p_origination_type,
        p_record_class,
        p_demand_class,
        p_level_id);

END Get_Item_Demand_Alloc_Percent;

FUNCTION Get_DC_Alloc_Percent(
	p_instance_id 	IN 	NUMBER,
	p_inv_item_id 	IN 	NUMBER,
	p_org_id 	IN 	NUMBER,
	p_dept_id 	IN 	NUMBER,
	p_res_id  	IN 	NUMBER,
	p_demand_class 	IN 	VARCHAR2,
	p_request_date 	IN 	DATE)
RETURN NUMBER
IS
BEGIN
  return MSC_AATP_FUNC.Get_DC_Alloc_Percent(
        p_instance_id,
        p_inv_item_id,
        p_org_id,
        p_dept_id,
        p_res_id,
        p_demand_class,
        p_request_date);
EXCEPTION
  WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_DC_Alloc_Percent: ' || 'Error code:' || to_char(sqlcode));
      END IF;
      return(0.0);
END Get_DC_Alloc_Percent;

FUNCTION Get_Res_Demand_Alloc_Percent(
	p_demand_date 		IN 	DATE,
	p_assembly_item_id 	IN 	NUMBER,
	p_org_id 		IN 	NUMBER,
	p_instance_id 		IN 	NUMBER,
	p_dept_id 		IN 	NUMBER,
	p_res_id  		IN 	NUMBER,
	p_record_class 		IN 	VARCHAR2,
	p_demand_class 		IN 	VARCHAR2)
RETURN NUMBER
IS
BEGIN
      return MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(
        p_demand_date,
        p_assembly_item_id,
        p_org_id,
        p_instance_id,
        p_dept_id,
        p_res_id,
        p_record_class,
        p_demand_class);

END GET_RES_DEMAND_ALLOC_PERCENT;

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
	x_atp_supply_demand   OUT  NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ)
IS
        p_get_mat_in_rec      MSC_ATP_REQ.get_mat_in_rec;
        -- time_phased_atp
        l_request_item_id     NUMBER;
        l_atf_date            DATE;
BEGIN
	-- dsting fake values since no one should be calling this
	-- and the spec changed in the msc files
	p_get_mat_in_rec.rounding_control_flag := 2;
	p_get_mat_in_rec.dest_inv_item_id := -1;
	p_get_mat_in_rec.infinite_time_fence_date := NULL;
	p_get_mat_in_rec.plan_name := 'MRPFOO';

	MSC_AATP_PVT.Item_Alloc_Cum_Atp(
        p_plan_id,
        p_level,
        p_identifier,
        p_scenario_id,
        p_inventory_item_id,
        p_organization_id,
        p_instance_id,
        p_demand_class,
        p_request_date,
        p_insert_flag,
        x_atp_info,
        x_atp_period,
        x_atp_supply_demand,
	p_get_mat_in_rec,
	l_request_item_id, -- For time_phased_atp
	l_atf_date);       -- For time_phased_atp

END Item_Alloc_Cum_Atp;

PROCEDURE Res_Alloc_Cum_Atp(
	p_plan_id 	      IN 	NUMBER,
	p_level               IN 	NUMBER,
	p_identifier          IN 	NUMBER,
	p_scenario_id         IN 	NUMBER,
	p_department_id       IN 	NUMBER,
	p_resource_id         IN 	NUMBER,
	p_organization_id     IN 	NUMBER,
	p_instance_id         IN 	NUMBER,
	p_demand_class        IN 	VARCHAR2,
	p_request_date        IN 	DATE,
	p_insert_flag         IN 	NUMBER,
        p_max_capacity        IN        NUMBER,
        p_batchable_flag      IN        NUMBER,
        p_res_conversion_rate IN        NUMBER,
        p_res_uom_type        IN        NUMBER,
	x_atp_info            OUT  	NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          OUT  	NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   OUT  	NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ)
IS
BEGIN
	MSC_AATP_PVT.Res_Alloc_Cum_Atp(
        p_plan_id,
        p_level,
        p_identifier,
        p_scenario_id,
        p_department_id,
        p_resource_id,
        p_organization_id,
        p_instance_id,
        p_demand_class,
        p_request_date,
        p_insert_flag,
        p_max_capacity,
        p_batchable_flag,
        p_res_conversion_rate,
        p_res_uom_type,
        x_atp_info,
        x_atp_period,
        x_atp_supply_demand);
END Res_Alloc_Cum_Atp;

PROCEDURE Supplier_Alloc_Cum_Atp(
p_plan_id 	      IN NUMBER,
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
x_atp_info            OUT  NoCopy MRP_ATP_PVT.ATP_Info,
x_atp_period          OUT  NoCopy MRP_ATP_PUB.ATP_Period_Typ,
x_atp_supply_demand   OUT  NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ
)
IS
BEGIN
	/* ship_rec_cal
	MSC_AATP_PVT.Supplier_Alloc_Cum_Atp(
		p_plan_id,
		p_level,
		p_identifier,
		p_scenario_id,
		p_supplier_id,
		p_supplier_site_id,
		p_inventory_item_id,
		p_organization_id,
		p_instance_id,
		p_demand_class,
		p_request_date,
		p_insert_flag,
                NULL,      -- SCLT changes Default value for p_sup_cap_cum_date
                '@@@',     -- For ship_rec_cal
                NULL,      -- For ship_rec_cal
		x_atp_info,
		x_atp_period,
		x_atp_supply_demand,
		NULL); -- for CTO*/
        NULL;
END Supplier_Alloc_Cum_Atp;

PROCEDURE Get_DC_Info(
	p_instance_id	IN 	NUMBER,
	p_inv_item_id	IN 	NUMBER,
	p_org_id	IN 	NUMBER,
	p_dept_id	IN 	NUMBER,
	p_res_id	IN 	NUMBER,
	p_demand_class	IN 	VARCHAR2,
	p_request_date	IN 	DATE,
        x_level_id      OUT     NoCopy NUMBER,
	x_priority	OUT  	NoCopy NUMBER,
	x_alloc_percent	OUT 	NoCopy NUMBER,
	x_return_status	OUT 	NoCopy VARCHAR2)
IS
BEGIN
	MSC_AATP_PVT.Get_DC_Info(
        p_instance_id,
        p_inv_item_id,
        p_org_id,
        p_dept_id,
        p_res_id,
        p_demand_class,
        p_request_date,
        x_level_id,
        x_priority,
        x_alloc_percent,
        x_return_status);
EXCEPTION
  WHEN OTHERS THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Get_DC_Info: ' || 'Error code:' || to_char(sqlcode));
	END IF;
	x_priority := -1;
	x_alloc_percent := 0;
	x_return_status := FND_API.G_RET_STS_ERROR;
END Get_DC_Info;

PROCEDURE View_Allocation(
  p_session_id         IN    NUMBER,
  p_inventory_item_id  IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_department_id      IN    NUMBER,
  p_resource_id        IN    NUMBER,
  p_demand_class       IN    VARCHAR2,
  x_return_status      OUT   NoCopy VARCHAR2
)
IS
BEGIN
	MSC_AATP_PVT.View_Allocation(
  		p_session_id,
  		p_inventory_item_id,
  		p_instance_id,
  		p_organization_id,
  		p_department_id,
  		p_resource_id,
  		p_demand_class,
  		x_return_status);
END View_allocation;

FUNCTION Get_Hierarchy_Demand_Class(
  p_partner_id         IN    NUMBER,
  p_partner_site_id    IN    NUMBER,
  p_inventory_item_id  IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_request_date       IN    DATE,
  p_level_id           IN    NUMBER,
  p_demand_class       IN    VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
	RETURN MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
  		p_partner_id,
  		p_partner_site_id,
  		p_inventory_item_id,
  		p_organization_id,
  		p_instance_id,
  		p_request_date,
  		p_level_id,
  		p_demand_class);
END Get_Hierarchy_Demand_Class;


FUNCTION Get_Allowed_Stolen_Percent(
  p_instance_id         IN NUMBER,
  p_inv_item_id         IN NUMBER,
  p_org_id              IN NUMBER,
  p_dept_id             IN NUMBER,
  p_res_id              IN NUMBER,
  p_demand_class        IN VARCHAR2,
  p_request_date        IN DATE)
RETURN NUMBER
IS
BEGIN
  return MSC_AATP_FUNC.Get_Allowed_Stolen_Percent(
  		p_instance_id,
  		p_inv_item_id,
  		p_org_id,
  		p_dept_id,
  		p_res_id,
  		p_demand_class,
  		p_request_date);
EXCEPTION
  WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'Error code:' || to_char(sqlcode));
      END IF;
      return(0.0);
END Get_Allowed_Stolen_Percent;

END MRP_AATP_PVT;

/

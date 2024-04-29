--------------------------------------------------------
--  DDL for Package MSC_AATP_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_AATP_FUNC" AUTHID CURRENT_USER AS
/* $Header: MSCFAATS.pls 120.1 2007/12/12 10:26:52 sbnaik ship $  */


FUNCTION Get_Allowed_Stolen_Percent(
  p_instance_id         IN NUMBER,
  p_inv_item_id         IN NUMBER,
  p_org_id              IN NUMBER,
  p_dept_id             IN NUMBER,
  p_res_id              IN NUMBER,
  p_demand_class        IN VARCHAR2,
  p_request_date        IN DATE)
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

FUNCTION Get_Res_Hierarchy_Demand_Class(
  p_partner_id         IN    NUMBER,
  p_partner_site_id    IN    NUMBER,
  p_department_id      IN    NUMBER,
  p_resource_id        IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_request_date       IN    DATE,
  p_level_id           IN    NUMBER,
  p_demand_class       IN    VARCHAR2)
RETURN VARCHAR2;



END MSC_AATP_FUNC;

/

--------------------------------------------------------
--  DDL for Package MSC_AATP_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_AATP_REQ" AUTHID CURRENT_USER AS
/* $Header: MSCRAATS.pls 120.1 2007/12/12 10:38:10 sbnaik ship $  */


PROCEDURE Item_Pre_Allocated_Atp(
    p_plan_id           IN 	NUMBER,
    p_level             IN 	NUMBER,
    p_identifier        IN 	NUMBER,
    p_scenario_id       IN 	NUMBER,
    p_inventory_item_id IN 	NUMBER,
    p_organization_id   IN 	NUMBER,
    p_instance_id       IN 	NUMBER,
    p_demand_class      IN 	VARCHAR2,
    p_request_date      IN 	DATE,
    p_insert_flag       IN 	NUMBER,
    x_atp_info          OUT NoCopy MRP_ATP_PVT.ATP_Info,
    x_atp_period        OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
    x_atp_supply_demand OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
    p_get_mat_in_rec    IN  MSC_ATP_REQ.get_mat_in_rec,
    p_refresh_number    IN  NUMBER,    -- For summary enhancement
    p_request_item_id   IN  NUMBER,    -- For time_phased_atp
    p_atf_date          IN  DATE);     -- For time_phased_atp

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
);


END MSC_AATP_REQ;

/

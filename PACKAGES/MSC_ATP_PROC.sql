--------------------------------------------------------
--  DDL for Package MSC_ATP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_PROC" AUTHID CURRENT_USER AS
/* $Header: MSCPATPS.pls 120.4.12010000.2 2009/09/13 18:13:00 sbnaik ship $  */


-- For supplier intransit LT project
G_VENDOR_SITE_ID        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
G_latest_ship_date_set  DATE; --4460369
G_latest_arr_date_set   DATE; --4460369

PROCEDURE add_inf_time_fence_to_period(
  p_level			IN  NUMBER,
  p_identifier                  IN  NUMBER,
  p_scenario_id                 IN  NUMBER,
  p_inventory_item_id           IN  NUMBER,
  p_request_item_id		IN  NUMBER,
  p_organization_id             IN  NUMBER,
  p_supplier_id                 IN  NUMBER,
  p_supplier_site_id            IN  NUMBER,
  p_infinite_time_fence_date    IN  DATE,
  x_atp_period                  IN OUT NOCOPY 	MRP_ATP_PUB.ATP_Period_Typ
);

PROCEDURE get_period_data_from_SD_temp(
  x_atp_period                  OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ
);

-- New procedure added as part of time_phased_atp to fix the
-- issue of not displaying correct quantities in ATP SD Window when
-- user opens ATP SD window from ATP pegging in allocated scenarios
PROCEDURE Get_Alloc_Data_From_Sd_Temp(
  x_atp_period                  OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_return_status               OUT NOCOPY VARCHAR2
);

PROCEDURE Atp_Sources (
	p_instance_id			IN	NUMBER,
	p_plan_id                   	IN   	NUMBER,
	p_inventory_item_id         	IN   	NUMBER,
	p_organization_id           	IN   	NUMBER,
	p_customer_id               	IN   	NUMBER,
	p_customer_site_id          	IN   	NUMBER,
	p_assign_set_id             	IN   	NUMBER,
        --s_cto_rearch
        p_Item_Sourcing_Info_Rec      IN   MSC_ATP_CTO.Item_Sourcing_Info_Rec,
        p_session_id                    IN      NUMBER,
        --e_cto_rearch
	--p_ship_set_item             	IN   	MRP_ATP_PUB.number_arr,
	x_atp_sources               	OUT  	NoCopy MRP_ATP_PVT.Atp_Source_Typ,
	x_return_status             	OUT  	NoCopy VARCHAR2,
	p_partner_type                  IN      NUMBER DEFAULT NULL, --2814895
	p_party_site_id                 IN      NUMBER DEFAULT NULL, --2814895
	p_order_line_id                 IN      NUMBER DEFAULT NULL  --2814895
);

PROCEDURE item_sources_extend(p_item_sourcing_rec
                         IN OUT NOCOPY MSC_ATP_CTO.Item_Sourcing_Info_Rec);

PROCEDURE Atp_Consume_Range (
	p_atp_qty			IN OUT	NoCopy MRP_ATP_PUB.number_arr,
	p_start_idx         		IN      NUMBER,
	p_end_idx         		IN      NUMBER
);

PROCEDURE Atp_Consume (
	p_atp_qty			IN OUT	NoCopy MRP_ATP_PUB.number_arr,
	p_counter         		IN      NUMBER
);


PROCEDURE Details_Output (
	p_atp_period			IN	MRP_ATP_PUB.ATP_Period_Typ,
	p_atp_supply_demand   		IN	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period          		IN OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   		IN OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_return_status       		OUT	NoCopy VARCHAR2
);


PROCEDURE get_dept_res_code (
	p_instance_id           	IN 	NUMBER,
	p_department_id         	IN 	NUMBER,
	p_resource_id           	IN 	NUMBER,
	p_organization_id       	IN 	NUMBER,
	x_department_code       	OUT 	NoCopy VARCHAR2,
	x_resource_code         	OUT 	NoCopy VARCHAR2
);


PROCEDURE Get_SD_Period_Rec(
	p_atp_period          		IN	MRP_ATP_PUB.ATP_Period_Typ,
	p_atp_supply_demand   		IN	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	p_identifier          		IN	NUMBER,
	p_scenario_id         		IN	NUMBER,
	p_new_scenario_id     		IN	NUMBER,
	x_atp_period          		IN OUT  NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   		IN OUT  NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_return_status       		OUT	NoCopy VARCHAR2
);


PROCEDURE get_org_default_info (
	p_instance_id            	IN 	NUMBER,
	p_organization_id        	IN 	NUMBER,
	x_default_atp_rule_id       	OUT 	NoCopy NUMBER,
	x_calendar_code             	OUT 	NoCopy VARCHAR2,
	x_calendar_exception_set_id 	OUT 	NoCopy NUMBER,
	x_default_demand_class      	OUT 	NoCopy VARCHAR2,
	x_org_code			OUT	NoCopy VARCHAR2
);


PROCEDURE inv_primary_uom_conversion (
	p_instance_id        		IN  	NUMBER,
	p_organization_id    		IN  	NUMBER,
	p_inventory_item_id  		IN  	NUMBER,
	p_uom_code           		IN  	VARCHAR2,
	x_primary_uom_code   		OUT 	NoCopy VARCHAR2,
	x_conversion_rate    		OUT 	NoCopy NUMBER
);

PROCEDURE Extend_Atp_Sources (
	p_atp_sources         	IN OUT NOCOPY  	MRP_ATP_PVT.Atp_Source_Typ,
	x_return_status       	OUT      	NoCopy VARCHAR2
);


Procedure Get_Plan_Info(
    p_instance_id 			IN	NUMBER,
    p_inventory_item_id 		IN 	NUMBER,
    p_organization_id 		IN 	NUMBER,
    p_demand_class 			IN 	VARCHAR2,
    -- x_plan_id                    OUT     NoCopy NUMBER,  commented for bug 2392456
    -- x_assign_set_id              OUT     NoCopy NUMBER   commented for bug 2392456
    x_plan_info_rec                 OUT     NoCopy MSC_ATP_PVT.plan_info_rec,   -- added for bug 2392456
    p_parent_plan_id                    IN      NUMBER DEFAULT NULL, --bug3510475
    p_time_phased_atp    IN VARCHAR2 DEFAULT 'N'
);


PROCEDURE Atp_Backward_Consume(
	p_atp_qty         		IN OUT  NoCopy MRP_ATP_PUB.number_arr
);


PROCEDURE Atp_Accumulate(
	p_atp_qty         		IN OUT  NoCopy MRP_ATP_PUB.number_arr
);

PROCEDURE ADD_COPRODUCTS(
    p_plan_id           IN NUMBER,
    p_instance_id       IN NUMBER,
    p_org_id            IN NUMBER,
    p_inv_item_id       IN NUMBER,
    p_request_date      IN DATE,
    p_demand_class      IN VARCHAR2,
    p_assembly_qty      IN NUMBER,
    p_parent_pegging_id IN NUMBER,
    p_rounding_flag     IN number, -- 2869830
    p_refresh_number    IN NUMBER,  -- For summary enhancement
    p_disposition_id    IN NUMBER -- 3766179
);


PROCEDURE get_Supply_Sources(
                             x_session_id         IN      NUMBER,
                             x_sr_instance_id     IN      NUMBER,
                             x_assignment_set_id  IN      NUMBER,
                             x_plan_id            IN      NUMBER,
                             x_calling_inst       IN      VARCHAR2,
                             x_ret_status         OUT     NoCopy VARCHAR2,
                             x_error_mesg         OUT     NoCopy VARCHAR2,
                             p_node_id            IN      NUMBER DEFAULT null, --bug3610706
                             p_requested_date     IN    DATE DEFAULT null -- 8524794
                             );


PROCEDURE msc_calculate_source_attrib
  ( l_customer_id                NUMBER,
    l_ship_to_site_use_id        NUMBER,
    l_dest_org_id                NUMBER,
    l_dest_instance_id           NUMBER,
    counter                      NUMBER,
    x_atp_sources                IN OUT NoCopy mrp_atp_pvt.atp_source_typ,
    x_other_cols                 IN OUT NoCopy order_sch_wb.other_cols_typ);


PROCEDURE   insert_atp_sources
  (x_session_id             NUMBER,
   x_dblink                 VARCHAR2,
   x_calling_inst           VARCHAR2,
   x_atp_sources            mrp_atp_pvt.atp_source_typ,
   x_other_cols             order_sch_wb.other_cols_typ);



PROCEDURE SHOW_SUMMARY_QUANTITY(p_instance_id          IN NUMBER,
                                p_plan_id              IN NUMBER,
                                p_organization_id      IN NUMBER,
                                p_inventory_item_id    IN NUMBER,
                                p_sd_date              IN DATE,
                                p_resource_id          IN NUMBER,
                                p_department_id        IN NUMBER,
                                p_supplier_id          IN NUMBER,
                                p_supplier_site_id     IN NUMBER,
                                p_dc_flag	       IN NUMBER,
                                p_demand_class         IN VARCHAR2,
                                p_mode                 IN NUMBER
                                );


PROCEDURE GET_ITEM_ATTRIBUTES(p_instance_id             IN  NUMBER,
                               p_plan_id                IN  NUMBER,
                               p_inventory_item_id      IN  NUMBER,
                               p_organization_id        IN  NUMBER,
                               p_item_attribute_rec    IN OUT NoCopy MSC_ATP_PVT.item_attribute_rec);


PROCEDURE GET_ORG_ATTRIBUTES (
	p_instance_id            	IN 	NUMBER,
	p_organization_id        	IN 	NUMBER,
	x_org_attribute_rec		OUT	NoCopy MSC_ATP_PVT.org_attribute_rec);

PROCEDURE get_global_org_info (
        p_instance_id                   IN      NUMBER,
        p_organization_id               IN      NUMBER);

PROCEDURE get_global_item_info (p_instance_id            IN  NUMBER,
                                p_plan_id                IN  NUMBER,
                                p_inventory_item_id      IN  NUMBER,
                                p_organization_id        IN  NUMBER,
                                p_item_attribute_rec     IN  MSC_ATP_PVT.item_attribute_rec);

-- New Procedure Supplier Capacity and Lead Time (SCLT) Project.

PROCEDURE get_global_plan_info (p_instance_id        IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_demand_class       IN VARCHAR2,
                                p_parent_plan_id     IN NUMBER DEFAULT NULL, --bug3510475
                                p_time_phased_atp    IN VARCHAR2 DEFAULT 'N');

--ubadrina bug 2265012 begin

TYPE Ship_Method_Rec IS RECORD (
ship_method VARCHAR2(30),
ship_method_text VARCHAR2(80),
intransit_time NUMBER);

g_ship_method_rec Ship_Method_Rec;

--ubadrina bug 2265012 end

--(ssurendr) Bug 2865389 OPM fix. Created a new procedure get_process_effectivity
--to get Process seq id,routing seq Id and Bill seq Id.
PROCEDURE get_process_effectivity (
                                p_plan_id             IN NUMBER,
                                p_item_id             IN NUMBER,
                                p_organization_id     IN NUMBER,
                                p_sr_instance_id      IN NUMBER,
                                p_new_schedule_date   IN DATE,
                                p_requested_quantity  IN NUMBER,
                                x_process_seq_id      OUT NOCOPY NUMBER,
                                x_routing_seq_id      OUT NOCOPY NUMBER,
                                x_bill_seq_id         OUT NOCOPY NUMBER,
                                x_op_seq_id           OUT NOCOPY NUMBER, --4570421
                                x_return_status       OUT NOCOPY varchar2);

---diag_atp
Procedure get_infinite_time_fence_date (p_instance_id             IN NUMBER,
                                       p_inventory_item_id        IN NUMBER,
                                       p_organization_id          IN NUMBER,
                                       p_plan_id                  IN NUMBER,
                                       x_infinite_time_fence_date OUT NoCopy DATE,
                                       x_atp_rule_name            OUT NoCopy VARCHAR2,
                                       -- Bug 3036513 Add additional parameters
                                       -- with defaults for resource infinite time fence.
                                       p_resource_id              IN NUMBER DEFAULT NULL,
                                       p_department_id            IN NUMBER DEFAULT NULL);


PROCEDURE Get_Shipping_Methods (

        p_from_organization_id            IN      number,
        p_to_organization_id              IN      number,
        p_to_customer_id                  IN      number,
        p_to_customer_site_id             IN      number,
        p_from_instance_id                IN      number,
        p_to_instance_id                  IN      number,
        p_session_id                      IN      number,
        p_calling_module                  IN      number,
        x_return_status                   OUT NOCOPY    varchar2
);

PROCEDURE ATP_Shipping_Lead_Time (
  p_from_loc_id                 IN NUMBER,        -- From Location ID
  p_to_customer_site_id         IN NUMBER,        -- To Customer Site ID
  p_session_id                  IN NUMBER,        -- A Unique Session ID
  x_ship_method                 IN OUT NOCOPY VARCHAR2,  -- Ship Method to Use
  x_intransit_time              OUT NOCOPY NUMBER,       -- The calculated in-transit Lead time
                                        -- Will be -1 when an error is encountered.
  x_return_status               OUT NOCOPY VARCHAR2      -- A return status variable
                                        --  FND_API.G_RET_STS_SUCCESS - on success
                                        --  FND_API.G_RET_STS_ERROR - on expected error
                                        --  FND_API.G_RET_STS_UNEXP_ERROR - on unexpected error
);

PROCEDURE Initialize_Set_Processing(
  p_set         IN              MRP_ATP_PUB.ATP_Rec_Typ,
  p_start       IN              NUMBER DEFAULT 1
);

PROCEDURE Process_Set_Line(
   p_set         IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
   i             IN              NUMBER,
   x_line_status OUT NOCOPY      NUMBER
);

PROCEDURE Process_Set_Dates_Errors(
   p_set         IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
   p_src_dest    IN              VARCHAR2,
   x_set_status  OUT NOCOPY      NUMBER,
   p_start       IN              NUMBER DEFAULT NULL,
   p_end         IN              NUMBER DEFAULT NULL
);

PROCEDURE Update_Set_SD_Dates(
   p_set        IN OUT NOCOPY      MRP_ATP_PUB.ATP_Rec_Typ,
   p_arrival_set IN    		   mrp_atp_pub.date_arr
);

PROCEDURE get_transit_time (
	p_from_loc_id       IN NUMBER,
	p_from_instance_id  IN NUMBER,
	p_to_loc_id         IN NUMBER,
	p_to_instance_id    IN NUMBER,
	p_session_id        IN NUMBER,
	p_partner_site_id   IN NUMBER,
	x_ship_method       IN OUT NoCopy VARCHAR2,
	x_intransit_time    OUT NoCopy NUMBER,
	p_supplier_site_id  IN NUMBER DEFAULT NULL,-- For supplier intransit LT project
	p_partner_type          IN      NUMBER DEFAULT NULL,--2814895
	p_party_site_id         IN      NUMBER DEFAULT NULL,--2814895
	p_order_line_id         IN      NUMBER DEFAULT NULL --2814895
);

PROCEDURE get_delivery_lead_time(
	p_from_org_id		IN	NUMBER,
	p_from_loc_id		IN 	NUMBER,
	p_instance_id	  	IN	NUMBER,
	p_to_org_id	  	IN	NUMBER,
	p_to_loc_id		IN 	NUMBER,
	p_to_instance_id 	IN	NUMBER,
	p_customer_id		IN	NUMBER,
	p_customer_site_id	IN	NUMBER,
	p_supplier_id		IN	NUMBER,
	p_supplier_site_id	IN	NUMBER,
	p_session_id	  	IN	NUMBER,
	p_partner_site_id	IN	NUMBER,
	p_ship_method	  	IN OUT 	NoCopy VARCHAR2,
	x_delivery_lead_time 	OUT 	NoCopy NUMBER,
        p_partner_type          IN      NUMBER DEFAULT NULL, --2814895
        p_party_site_id         IN      NUMBER DEFAULT NULL, --2814895
	p_order_line_id         IN      NUMBER DEFAULT NULL --2814895
);

-- append p2 to p1
PROCEDURE number_arr_cat (
        p1      IN OUT NOCOPY   mrp_atp_pub.number_arr,
        p2      IN              mrp_atp_pub.number_arr
);

-- append p2 to p1
PROCEDURE date_arr_cat (
        p1      IN OUT NOCOPY   mrp_atp_pub.date_arr,
        p2      IN              mrp_atp_pub.date_arr
);

-- loop through peg_ids and remove s/d recs
PROCEDURE cleanup_set(
        p_instance_id   IN      number,
        p_plan_id       IN      number,
        peg_ids         IN      mrp_atp_pub.number_arr,
        dmd_class_flag  IN      mrp_atp_pub.number_arr
);

-- supplier intransit LT
PROCEDURE Get_Supplier_Regions (p_vendor_site_id    IN  NUMBER,
                                p_calling_module    IN  NUMBER,
                                p_instance_id       IN  NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2
);

-- supplier intransit LT
/*--ATP_Intransit_LT-----------------------------------------------------------
| - Generic API to find intransit lead times to be called mainly by
|   products other than GOP.
| o p_src_dest            - whether being called from source or
|                           destination - 1:Source; 2:Destination
|                           supp-org is supported only from destination
| o p_session_id          - unique number identifying the current session
| o p_from_org_id         - used in org-org and org-cust scenario, should
|                           be null in supp-org case, not required if
|                           p_from_loc_id is provided
| o p_from_loc_id         - used in org-cust scenario, should be null in
|                           org-org and supp-org cases, not required if
|                           p_from_org_id is provided
| o p_from_vendor_site_id - used in supp-org scenario, should be null in
|                           org-org and supp-org cases, source id is expected
| o p_from_instance_id    - from party's instance id, not required when
|                           called from source
| o p_to_org_id           - used in org-org and supp-org scenario, should
|                           be null in org-cust case
| o p_to_loc_id           - used in org-cust scenario, should be null in
|                           org-org and supp-org cases, not required if
|                           p_to_customer_site_id is provided
| o p_to_customer_site_id - used in org-cust scenario, should be null in
|                           org-org and supp-org cases, not required if
|                           p_to_loc_id is provided
| o p_to_instance_id      - to party's instance id, not required when called
|                           from source
| o p_ship_method         - default ship method is used if not passed. if
|                           the passed ship method does not exist in shipping
|                           network then default ship method is returned
| o x_intransit_lead_time - intrasit lead time
| o x_return_status       - return status
+----------------------------------------------------------------------------*/

PROCEDURE ATP_Intransit_LT (p_src_dest              IN  NUMBER,
                            p_session_id            IN  NUMBER,
                            p_from_org_id           IN  NUMBER,
                            p_from_loc_id           IN  NUMBER,
                            p_from_vendor_site_id   IN  NUMBER,
                            p_from_instance_id      IN  NUMBER,
                            p_to_org_id             IN  NUMBER,
                            p_to_loc_id             IN  NUMBER,
                            p_to_customer_site_id   IN  NUMBER,
                            p_to_instance_id        IN  NUMBER,
                            p_ship_method           IN OUT  NoCopy VARCHAR2,
                            x_intransit_lead_time   OUT     NoCopy NUMBER,
                            x_return_status         OUT NOCOPY VARCHAR2
);

END MSC_ATP_PROC;


/

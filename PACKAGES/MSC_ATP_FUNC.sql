--------------------------------------------------------
--  DDL for Package MSC_ATP_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_FUNC" AUTHID CURRENT_USER AS
/* $Header: MSCFATPS.pls 120.1 2007/12/12 10:27:30 sbnaik ship $  */

FUNCTION get_atp_flag (p_instance_id            IN  NUMBER,
                       p_plan_id                IN  NUMBER,
	               p_inventory_item_id      IN  NUMBER,
                       p_organization_id        IN  NUMBER)
RETURN VARCHAR2;


FUNCTION get_atp_comp_flag (p_instance_id	     IN  NUMBER,
                            p_plan_id                IN  NUMBER,
			    p_inventory_item_id      IN  NUMBER,
                            p_organization_id        IN  NUMBER)
RETURN VARCHAR2;


FUNCTION get_location_id (p_instance_id		IN  NUMBER,
		          p_organization_id	IN  NUMBER,
                          p_customer_id		IN  NUMBER,
                          p_customer_site_id	IN  NUMBER,
			  p_supplier_id		IN  NUMBER,
			  p_supplier_site_id   	IN  NUMBER)
RETURN NUMBER;


FUNCTION get_infinite_time_fence_date (p_instance_id            IN NUMBER,
				       p_inventory_item_id	IN NUMBER,
			               p_organization_id 	IN NUMBER,
                                       p_plan_id                IN NUMBER)
RETURN DATE;


FUNCTION get_org_code (p_instance_id            IN NUMBER,
                       p_organization_id        IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_inv_item_name (p_instance_id            IN NUMBER,
                            p_inventory_item_id      IN NUMBER,
                            p_organization_id        IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_inv_item_id (p_instance_id            IN NUMBER,
                            p_inventory_item_id      IN NUMBER,
                            p_match_item_id          IN NUMBER,
                            p_organization_id        IN NUMBER)
RETURN NUMBER;


FUNCTION get_supplier_name (p_instance_id            IN NUMBER,
                            p_supplier_id            IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_supplier_site_name (p_instance_id            IN NUMBER,
                                 p_supplier_site_id	  IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_location_code (p_instance_id            IN NUMBER,
                            p_location_id            IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_sd_source_name (p_instance_id            IN NUMBER,
                             p_sd_type                IN NUMBER,
                             p_sd_source_type         IN NUMBER)
RETURN VARCHAR2;


FUNCTION prev_work_day(p_organization_id        IN  NUMBER,
                       p_instance_id            IN  NUMBER,
                       p_date                   IN  DATE)
RETURN DATE;


FUNCTION MPS_ATP(p_desig_id        IN  NUMBER)
RETURN NUMBER;


FUNCTION Get_Designator(p_desig_id        IN  NUMBER)
RETURN VARCHAR2;


FUNCTION Get_MPS_Demand_Class(p_desig_id        IN  NUMBER)
RETURN VARCHAR2;


FUNCTION NEXT_WORK_DAY_SEQNUM(p_organization_id        IN  NUMBER,
                       p_instance_id            IN  NUMBER,
                       p_date                   IN  DATE)
RETURN number;


FUNCTION get_tolerance_percentage(
                            p_instance_id         IN NUMBER,
                            p_plan_id             IN NUMBER,
                            p_inventory_item_id   IN NUMBER,
                            p_organization_id     IN NUMBER,
                            p_supplier_id         IN NUMBER,
                            p_supplier_site_id    IN NUMBER,
                            p_seq_num_difference  IN NUMBER -- For ship_rec_cal
                           )
RETURN NUMBER;


FUNCTION Get_Order_Number(p_supply_id        IN  NUMBER,
                          p_plan_id          IN  NUMBER)
RETURN VARCHAR2;


FUNCTION Get_Order_Type(p_supply_id        IN  NUMBER,
                        p_plan_id          IN  NUMBER)
RETURN NUMBER;

-- savirine, Sep24, 2001: added the parameters p_session_id and p_partner_site_id

FUNCTION get_interloc_transit_time (p_from_location_id IN NUMBER,
                                    p_from_instance_id IN NUMBER,
                                    p_to_location_id   IN NUMBER,
                                    p_to_instance_id   IN NUMBER,
                                    p_ship_method      IN VARCHAR2,
                                    p_session_id       IN NUMBER DEFAULT NULL,
                                    p_partner_site_id  IN NUMBER DEFAULT NULL)
return NUMBER;


FUNCTION Calc_Arrival_date(
                org_id                  IN NUMBER,
                instance_id             IN NUMBER,
		customer_id		IN NUMBER,
                bucket_type             IN NUMBER,
                sch_ship_date           IN DATE,
                req_arrival_date        IN DATE,
                delivery_lead_time      IN NUMBER

) RETURN DATE;


-- ngoel 9/28/2001, added this function for use in View MSC_SCATP_SOURCES_V to support
-- Region Level Sourcing.

FUNCTION Get_Session_id
RETURN NUMBER;

-- rajjain 02/19/2003 Bug 2788302 Begin
--pumehta added this function to get process_sequence_id to be populated when
--adding a planned order for Make Case.
FUNCTION get_process_seq_id(
                             p_plan_id           IN NUMBER,
                             p_item_id           IN NUMBER,
                             p_organization_id   IN NUMBER,
                             p_sr_instance_id    IN NUMBER,
                             p_new_schedule_date IN DATE
) RETURN NUMBER;
-- rajjain 02/19/2003 Bug 2788302 End

END MSC_ATP_FUNC;

/

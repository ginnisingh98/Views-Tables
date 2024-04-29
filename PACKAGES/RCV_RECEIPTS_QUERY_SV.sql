--------------------------------------------------------
--  DDL for Package RCV_RECEIPTS_QUERY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_RECEIPTS_QUERY_SV" AUTHID CURRENT_USER AS
/* $Header: RCVRCPQS.pls 120.0.12010000.1 2008/07/24 14:36:34 appldev ship $*/

/*===========================================================================
  PROCEDURE NAME: post_query()

  DESCRIPTION:
	This is the wrapper procedure for the Enter Receipts post query
	logic.

  USAGE:

  PARAMETERS:

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	24-MAY-95	Sanjay Kothary	Created
        24-JUL-01       Sanjay Kumar    Bug# 1432909
        20-AUG-01       Sanjay Kumar    Bug# 1942953
===========================================================================*/
/* Bug# 1942953 - Added x_from_org_id as a new parameter in the POST_QUERY */

-- <ENT RCPT PERF FPI>
TYPE NUM_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


PROCEDURE  POST_QUERY (  x_line_location_id		 IN NUMBER,
			 x_shipment_line_id		 IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_org_id                        IN NUMBER,
			 x_item_id			 IN NUMBER,
			 x_unit_of_measure_class	 IN VARCHAR2,
			 x_ship_to_location_id		 IN NUMBER,
			 x_vendor_id   	       		 IN NUMBER,
			 x_customer_id   	       	 IN NUMBER,
			 x_item_rev_control_flag_to	 IN VARCHAR2,
                         x_available_qty                 IN OUT NOCOPY NUMBER,
                         x_primary_qty	 		 IN OUT NOCOPY NUMBER,
			 x_tolerable_qty	         IN OUT NOCOPY NUMBER,
                         x_uom		                 IN OUT NOCOPY VARCHAR2,
			 x_primary_uom			 IN OUT NOCOPY VARCHAR2,
			 x_valid_ship_to_location	 IN OUT NOCOPY BOOLEAN,
	    		 x_num_of_distributions 	 IN OUT NOCOPY NUMBER,
    			 x_po_distributions_id 	 	 IN OUT NOCOPY NUMBER,
    			 x_destination_type_code 	 IN OUT NOCOPY VARCHAR2,
    			 x_destination_type_dsp  	 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_location_id	 IN OUT NOCOPY NUMBER,
    			 x_deliver_to_location	 	 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_person_id	 	 IN OUT NOCOPY NUMBER,
    			 x_deliver_to_person		 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_sub		 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_locator_id	 IN OUT NOCOPY NUMBER,
    			 x_wip_entity_id                 IN OUT NOCOPY NUMBER,
    			 x_wip_repetitive_schedule_id    IN OUT NOCOPY NUMBER,
    			 x_wip_line_id                	 IN OUT NOCOPY NUMBER,
    			 x_wip_operation_seq_num      	 IN OUT NOCOPY NUMBER,
    			 x_wip_resource_seq_num       	 IN OUT NOCOPY NUMBER,
    			 x_bom_resource_id            	 IN OUT NOCOPY NUMBER,
    			 x_to_organization_id         	 IN OUT NOCOPY NUMBER,
    			 x_job                        	 IN OUT NOCOPY VARCHAR2,
    			 x_line_num                   	 IN OUT NOCOPY VARCHAR2,
    			 x_sequence                   	 IN OUT NOCOPY NUMBER,
    			 x_department                 	 IN OUT NOCOPY VARCHAR2,
			 x_enforce_ship_to_loc 		 IN OUT NOCOPY VARCHAR2,
			 x_allow_substitutes   		 IN OUT NOCOPY VARCHAR2,
			 x_routing_id          		 IN OUT NOCOPY NUMBER,
			 x_qty_rcv_tolerance   		 IN OUT NOCOPY NUMBER,
			 x_qty_rcv_exception   		 IN OUT NOCOPY VARCHAR2,
			 x_days_early_receipt  		 IN OUT NOCOPY NUMBER,
			 x_days_late_receipt   		 IN OUT NOCOPY NUMBER,
			 x_rcv_days_exception  		 IN OUT NOCOPY VARCHAR2,
			 x_item_revision		 IN OUT NOCOPY VARCHAR2,
			 x_locator_control		 IN OUT NOCOPY NUMBER,
			 x_inv_destinations		 IN OUT NOCOPY BOOLEAN,
                         x_rate                          IN OUT NOCOPY NUMBER,
                         x_rate_date                     IN OUT NOCOPY DATE,
                         x_asn_type                      IN     VARCHAR2,
			 x_oe_order_header_id		 IN     NUMBER,
			 x_oe_order_line_id		 IN     NUMBER,
                         x_from_org_id                   IN NUMBER DEFAULT NULL,
-- <RCV ENH FPI START>
                         x_kanban_card_number         OUT NOCOPY VARCHAR2,
                         x_project_number             OUT NOCOPY VARCHAR2,
                         x_task_number                OUT NOCOPY VARCHAR2,
                         x_charge_account             OUT NOCOPY VARCHAR2
-- <RCV ENH FPI END>
   );

/*===========================================================================
  PROCEDURE NAME: post_query()

  DESCRIPTION:
	This is the overloading procedure intended to be used by INV team.


  CHANGE HISTORY:
        12/31/02 BAO created (for bug2730828)

===========================================================================*/
PROCEDURE  POST_QUERY (  x_line_location_id		 IN NUMBER,
			 x_shipment_line_id		 IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_org_id                        IN NUMBER,
			 x_item_id			 IN NUMBER,
			 x_unit_of_measure_class	 IN VARCHAR2,
			 x_ship_to_location_id		 IN NUMBER,
			 x_vendor_id   	       		 IN NUMBER,
			 x_customer_id   	       	 IN NUMBER,
			 x_item_rev_control_flag_to	 IN VARCHAR2,
                         x_available_qty                 IN OUT NOCOPY NUMBER,
                         x_primary_qty	 		 IN OUT NOCOPY NUMBER,
			 x_tolerable_qty	         IN OUT NOCOPY NUMBER,
                         x_uom		                 IN OUT NOCOPY VARCHAR2,
			 x_primary_uom			 IN OUT NOCOPY VARCHAR2,
			 x_valid_ship_to_location	 IN OUT NOCOPY BOOLEAN,
	    		 x_num_of_distributions 	 IN OUT NOCOPY NUMBER,
    			 x_po_distributions_id 	 	 IN OUT NOCOPY NUMBER,
    			 x_destination_type_code 	 IN OUT NOCOPY VARCHAR2,
    			 x_destination_type_dsp  	 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_location_id	 IN OUT NOCOPY NUMBER,
    			 x_deliver_to_location	 	 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_person_id	 	 IN OUT NOCOPY NUMBER,
    			 x_deliver_to_person		 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_sub		 IN OUT NOCOPY VARCHAR2,
    			 x_deliver_to_locator_id	 IN OUT NOCOPY NUMBER,
    			 x_wip_entity_id                 IN OUT NOCOPY NUMBER,
    			 x_wip_repetitive_schedule_id    IN OUT NOCOPY NUMBER,
    			 x_wip_line_id                	 IN OUT NOCOPY NUMBER,
    			 x_wip_operation_seq_num      	 IN OUT NOCOPY NUMBER,
    			 x_wip_resource_seq_num       	 IN OUT NOCOPY NUMBER,
    			 x_bom_resource_id            	 IN OUT NOCOPY NUMBER,
    			 x_to_organization_id         	 IN OUT NOCOPY NUMBER,
    			 x_job                        	 IN OUT NOCOPY VARCHAR2,
    			 x_line_num                   	 IN OUT NOCOPY VARCHAR2,
    			 x_sequence                   	 IN OUT NOCOPY NUMBER,
    			 x_department                 	 IN OUT NOCOPY VARCHAR2,
			 x_enforce_ship_to_loc 		 IN OUT NOCOPY VARCHAR2,
			 x_allow_substitutes   		 IN OUT NOCOPY VARCHAR2,
			 x_routing_id          		 IN OUT NOCOPY NUMBER,
			 x_qty_rcv_tolerance   		 IN OUT NOCOPY NUMBER,
			 x_qty_rcv_exception   		 IN OUT NOCOPY VARCHAR2,
			 x_days_early_receipt  		 IN OUT NOCOPY NUMBER,
			 x_days_late_receipt   		 IN OUT NOCOPY NUMBER,
			 x_rcv_days_exception  		 IN OUT NOCOPY VARCHAR2,
			 x_item_revision		 IN OUT NOCOPY VARCHAR2,
			 x_locator_control		 IN OUT NOCOPY NUMBER,
			 x_inv_destinations		 IN OUT NOCOPY BOOLEAN,
                         x_rate                          IN OUT NOCOPY NUMBER,
                         x_rate_date                     IN OUT NOCOPY DATE,
                         x_asn_type                      IN     VARCHAR2,
			 x_oe_order_header_id		 IN     NUMBER,
			 x_oe_order_line_id		 IN     NUMBER,
                         x_from_org_id                   IN NUMBER DEFAULT NULL);


-- <ENT RCPT PERF FPI START>

PROCEDURE exec_dynamic_sql(p_query      IN VARCHAR2,
                           p_val        IN RCV_RECEIPTS_QUERY_SV.NUM_TBL_TYPE,
                           x_exist      OUT NOCOPY VARCHAR2) ;

-- <ENT RCPT PERF FPI END>

END RCV_RECEIPTS_QUERY_SV;


/

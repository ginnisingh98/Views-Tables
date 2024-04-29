--------------------------------------------------------
--  DDL for Package WSMPLBTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLBTH" AUTHID CURRENT_USER AS
/* $Header: WSMLBTHS.pls 115.11 2002/11/13 03:25:50 abedajna ship $ */


FUNCTION Insert_Starting_Lot (
p_transaction_type IN NUMBER,
p_organization_id IN NUMBER,
p_wip_flag IN NUMBER,
p_split_flag IN NUMBER,
p_lot_number IN VARCHAR2,
p_inventory_item_id IN NUMBER,
p_quantity IN NUMBER,
p_subinventory_code IN VARCHAR2,
p_locator_id IN NUMBER,
p_revision IN VARCHAR2,
X_err_code OUT NOCOPY NUMBER,
X_err_msg OUT NOCOPY VARCHAR2
)
RETURN NUMBER;

PROCEDURE Insert_Resulting_Lot (
p_transaction_id          IN NUMBER ,
p_lot_number              IN VARCHAR2 ,
p_inventory_item_id       IN NUMBER ,
p_organization_id         IN NUMBER ,
p_quantity                IN NUMBER ,
p_subinventory_code       IN VARCHAR2,
p_locator_id		  IN NUMBER,
X_err_code OUT NOCOPY NUMBER,
X_err_msg OUT NOCOPY VARCHAR2
);

/* This procedure returns org level information that is needed
   at startup of the Create Lots form */

PROCEDURE get_org_values (
p_organization_id IN NUMBER,
p_acct_period_id OUT NOCOPY NUMBER,
p_org_locator_control OUT NOCOPY NUMBER,
X_err_code OUT NOCOPY NUMBER,
X_err_msg OUT NOCOPY VARCHAR2
 );


FUNCTION Create_New_Lot (
	 p_source_line_id IN NUMBER,
	 p_organization_id IN NUMBER,
	 p_primary_item_id IN NUMBER,
	 p_job_name IN VARCHAR2,
	 p_start_quantity IN NUMBER,
	 p_net_quantity IN NUMBER, /* APS-1-AM */
	 p_wip_entity_id IN NUMBER,
	 p_completion_subinventory IN VARCHAR2,
	 p_completion_locator_id IN NUMBER,
	 p_alternate_rtg IN VARCHAR2,
	 p_alternate_bom IN VARCHAR2,
	 p_description IN VARCHAR2,
	 p_job_type IN NUMBER,
	 p_bill_sequence_id IN NUMBER,
	 p_routing_sequence_id IN NUMBER,
	 p_bom_revision_date IN DATE,
	 p_routing_revision_date IN DATE,
	 p_bom_revision IN VARCHAR2,
	 p_routing_revision IN VARCHAR2,
	 p_start_date	IN DATE,
	 p_complete_date IN DATE,
	 p_class_code   IN VARCHAR2,
	 p_wjsi_group_id OUT NOCOPY NUMBER,
         p_coproducts_supply IN NUMBER, /* APS-1-AM */
	 x_err_code OUT NOCOPY NUMBER,
	 x_err_msg OUT NOCOPY VARCHAR2

) RETURN NUMBER ;




PROCEDURE UPDATE_WRO( p_wip_entity_id NUMBER,
		      p_operation_seq_num NUMBER,
		      p_inventory_item_id NUMBER,
		      x_err_code OUT NOCOPY NUMBER,
		      x_err_msg OUT NOCOPY VARCHAR2 );


/*BA#2326548*/
	PROCEDURE lot_creation_enter_genealogy(p_transaction_id IN NUMBER,
                                           p_organization_id IN NUMBER,
                                           p_starting_lot_number IN VARCHAR2,
                                           p_source_item_id IN NUMBER,
                                        p_resulting_lot_number IN VARCHAR2,
                                        p_err_code OUT NOCOPY NUMBER,
						p_err_msg OUT NOCOPY VARCHAR2);
/*EA#2326548*/


END WSMPLBTH;

 

/

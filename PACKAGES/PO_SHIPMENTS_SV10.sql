--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV10" AUTHID CURRENT_USER AS
/* $Header: POXPOSAS.pls 120.1 2006/07/27 23:48:02 dreddy noship $*/
/*===========================================================================
  FUNCTION NAME:	val_approval_status

  DESCRIPTION:		Validates if the shipment needs to be unapproved.

  PARAMETERS:		X_shipment_id             IN NUMBER,
		        X_shipment_type           IN VARCHAR2,
		        X_quantity                IN NUMBER,
		        X_amount                  IN NUMBER,
		        X_ship_to_location_id     IN NUMBER,
		        X_promised_date           IN DATE,
		        X_need_by_date            IN DATE,
		        X_shipment_num            IN NUMBER,
		        X_last_accept_date        IN DATE,
		        X_taxable_flag            IN VARCHAR2,
		        X_ship_to_organization_id IN NUMBER,
		        X_price_discount          IN NUMBER,
		        X_price_override          IN NUMBER,
                        p_start_date              IN DATE DEFAULT NULL,   -- <TIMEPHASED FPI>
                        p_end_date                IN DATE DEFAULT NULL)   -- <TIMEPHASED FPI>

  DESIGN REFERENCES:

  ALGORITHM:		Based on document type, look at different
			database columns to compare the input
			parameters to.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/3	Created
                        SIYER           6/7     Changed the return datatype
                                                from boolean to number in
                                                order to be able to
                                                return back a 3-state variable.
                                                X_need_to_approve
                                      Value     Meaning
                                        0       No need to re-approve
                                        1       Unapprove the document
                                        2       Unapprove doc AND shipment.

===========================================================================*/

  FUNCTION  val_approval_status
		      (X_shipment_id             IN NUMBER,
		       X_shipment_type           IN VARCHAR2,
		       X_quantity                IN NUMBER,
		       X_amount                  IN NUMBER,   -- Bug 5409088
		       X_ship_to_location_id     IN NUMBER,
		       X_promised_date           IN DATE,
		       X_need_by_date            IN DATE,
		       X_shipment_num            IN NUMBER,
		       X_last_accept_date        IN DATE,
		       X_taxable_flag            IN VARCHAR2,
		       X_ship_to_organization_id IN NUMBER,
		       X_price_discount          IN NUMBER,
		       X_price_override          IN NUMBER,
		       X_tax_code_id		 IN NUMBER,
                       p_start_date              IN DATE DEFAULT NULL,   /* <TIMEPHASED FPI> */
                       p_end_date                IN DATE DEFAULT NULL,   /* <TIMEPHASED FPI> */
                       p_days_early_receipt_allowed IN NUMBER)  -- <INBOUND LOGISTICS FPJ>
                       RETURN NUMBER ;

  function get_rcv_routing_name(X_rcv_routing_id IN NUMBER)
                       return varchar2;


/*===========================================================================
  PROCEDURE NAME:	get_shipment_post_query_info

  DESCRIPTION:		This procedure bundles serveral server procedures
                        which are invoked in the Shipments block POST_QUERY trigger.
                        This is to optimize the server procedures call and to
                        mininize the network triffic.

  PARAMETERS:		See Below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU           12/9/96	Created

===========================================================================*/

 procedure get_shipment_post_query_info(X_line_location_id 	IN NUMBER,
					X_shipment_type    	IN VARCHAR2,
					X_item_id          	IN NUMBER,
					X_ship_to_org_id 	IN NUMBER,
					X_total			IN OUT NOCOPY NUMBER,
					X_total_rtot_db		IN OUT NOCOPY NUMBER,
                                        X_Original_Date    	IN OUT NOCOPY DATE,
					X_item_status		IN OUT NOCOPY VARCHAR2,
                                        x_project_references_enabled IN OUT NOCOPY NUMBER,
                                        x_project_control_level IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:       get_price_update_flag

  DESCRIPTION:          This procedure returns a flag (Y/N) which decides
                        whether it is OK to change the price in the shipments
                        block.

  PARAMETERS:           See Below

  DESIGN REFERENCES:

  ALGORITHM:            The price should not be updatable when the destination
                        type is INVENTORY or SHOPFLOOR. In case of EXPENSE
                        destination, the accrual should be on receipt. In
                        addition there whould be no transaction which affects
                        accounting i.e there should be no receipt or billed
                        quantity against that shipment.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       GMUDGAL           11/2/98       Created

===========================================================================*/

procedure get_price_update_flag(X_line_location_id      IN NUMBER,
                                X_expense_accrual_code  in varchar2,
                                X_quantity_received     in number,
                                X_quantity_billed       in number,
                                X_prevent_price_update_flag in out NOCOPY varchar2) ;


END PO_SHIPMENTS_SV10;

 

/

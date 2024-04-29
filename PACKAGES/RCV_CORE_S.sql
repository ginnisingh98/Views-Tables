--------------------------------------------------------
--  DDL for Package RCV_CORE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_CORE_S" AUTHID CURRENT_USER AS
/* $Header: RCVCOCOS.pls 120.1 2005/08/12 02:42:40 spendokh noship $*/

/*===========================================================================
  PROCEDURE NAME:	val_destination_info

  DESCRIPTION:          Procedure validates whether the ship_to_location,
			deliver_to_location_id, destination organizations,
			destination subinventory or the deliver_to_person_id
 			that are specified as defaults on the PO are active
			for the transaction date.  If not, destination fields
			are nulled out.

			If the destination of an item in INVENTORY then
			looks up the default locator for that subinventory for
			the line item.

  PARAMETERS:

  Parameter	         IN/OUT	Datatype   Description
  -------------          ------ ---------- ----------------------------
  x_trx_date		  IN    DATE	   Transaction Date

  x_receipt_source_code	  IN    VARCHAR2   Receipt Source Code:
					        VENDOR
						INVENTORY
						INTERNAL

  x_line_loc_id		  IN    NUMBER     Line Location ID

  x_dist_id		  IN    NUMBER     Distribution ID

  x_ship_line_id	  IN    NUMBER     Shipment Line ID

  x_org_id		  IN    NUMBER     Organization ID

  x_item_id		  IN    NUMBER     Line Item ID

  x_ship_to_loc_id 	  OUT   NUMBER     Ship-To Location ID

  x_ship_to_loc_code	  OUT   VARCHAR2   Ship-To Location Code

  x_deliver_to_loc_id	  OUT   NUMBER     Deliver-To Location ID

  x_deliver_to_loc_code   OUT   VARCHAR2   Deliver-To Location Code

  x_dest_subinv		  OUT   VARCHAR2   Destination Subinventory

  x_locator_id		  OUT   NUMBER     Locator ID

  x_locator		  OUT   VARCHAR2   Locator

  x_dest_org_id		  OUT   NUMBER     Destination Organization ID

  x_dest_org_code         OUT   VARCHAR2   Destination Organization Code

  x_dest_type_code	  OUT   VARCHAR2   Destination Type Code

  x_deliver_to_person_id  OUT   NUMBER     Deliver-To Person ID

  x_deliver_to_person	  OUT   VARCHAR2   Deliver-To Person

  RETURN VALUE:	   Returns default values for:
			Ship-to location id
			Ship-to location code
			Deliver-to location id
			Deliver-to location code
			Destination Subinventory
			Locator id
			Locator
			Destination organization id
			Destination organization code
			Destination type code
			   EXPENSE
			   INVENTORY
			   SHOP FLOOR
			Deliver-to person id
			Deliver-to person

  DESIGN REFERENCES:	RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE val_destination_info (x_receipt_source_code   IN    VARCHAR2,
				x_trx_date		IN    DATE,
				x_line_loc_id		IN    NUMBER,
				x_dist_id		IN    NUMBER,
				x_ship_line_id		IN    NUMBER,
				x_org_id		IN    NUMBER,
				x_item_id		IN    NUMBER,
				x_ship_to_loc_id 	OUT NOCOPY   NUMBER,
				x_ship_to_loc_code	OUT NOCOPY   VARCHAR2,
    				x_deliver_to_loc_id	OUT NOCOPY   NUMBER,
				x_deliver_to_loc_code   OUT NOCOPY   VARCHAR2,
    				x_dest_subinv		OUT NOCOPY   VARCHAR2,
				x_locator_id		OUT NOCOPY   NUMBER,
				x_locator		OUT NOCOPY   VARCHAR2,
    				x_dest_org_id		OUT NOCOPY   NUMBER,
				x_dest_org_code		OUT NOCOPY   VARCHAR2,
				x_dest_type_code	OUT NOCOPY   VARCHAR2,
    				x_deliver_to_person_id	OUT NOCOPY   NUMBER,
				x_deliver_to_person	OUT NOCOPY   VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	get_receiving_controls

  DESCRIPTION:		Gets the following receiving controls:

			   Enforce Ship-to Location
			   Allow Substitute Receipts
			   Receipt Routing Header ID
			   Quantity Receipt Tolerance
			   Quantity Received Exception Code
			   Days Early Receipt Allowed
			   Days Late Receipt Allowed
			   Receipt Date Exception Code

			To determine the controls, the procedure searches up
			a path:

			   1) po_line_locations
			   2) mtl_system_items
			   3) po_vendors
 			   4) rcv_parameters

  PARAMETERS:		x_line_loc_id 	      IN  NUMBER
			x_item_id     	      IN  NUMBER
			x_vendor_id   	      IN  NUMBER
			x_org_id      	      IN  NUMBER
			x_enforce_ship_to_loc IN OUT VARCHAR2
			x_allow_substitutes   IN OUT VARCHAR2
			x_routing_id          IN OUT NUMBER
			x_qty_rcv_tolerance   IN OUT NUMBER
			x_qty_rcv_exception   IN OUT VARCHAR2
			x_days_early_receipt  IN OUT NUMBER
			x_days_late_receipt   IN OUT NUMBER
			x_rcv_date_exception  IN OUT VARCHAR2

  RETURN VALUE:

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_receiving_controls(x_line_loc_id 	       IN  NUMBER,
				 x_item_id     	       IN  NUMBER,
				 x_vendor_id   	       IN  NUMBER,
				 x_org_id      	       IN  NUMBER,
				 x_enforce_ship_to_loc IN OUT NOCOPY VARCHAR2,
				 x_allow_substitutes   IN OUT NOCOPY VARCHAR2,
				 x_routing_id          IN OUT NOCOPY NUMBER,
				 x_qty_rcv_tolerance   IN OUT NOCOPY NUMBER,
				 x_qty_rcv_exception   IN OUT NOCOPY VARCHAR2,
				 x_days_early_receipt  IN OUT NOCOPY NUMBER,
				 x_days_late_receipt   IN OUT NOCOPY NUMBER,
				 x_rcv_date_exception  IN OUT NOCOPY VARCHAR2,
				 p_payment_type        IN            VARCHAR2 DEFAULT NULL  --Bug 4549207
				 );


PROCEDURE get_receiving_controls                               -- <BUG 3365446>
(   p_order_type_lookup_code           IN         VARCHAR2
,   p_purchase_basis                   IN         VARCHAR2
,   p_line_location_id                 IN         NUMBER
,   p_item_id                          IN         NUMBER
,   p_org_id                           IN         NUMBER
,   p_vendor_id                        IN         NUMBER
,   p_drop_ship_flag                   IN         VARCHAR2 := 'N'
,   x_enforce_ship_to_loc_code         OUT NOCOPY VARCHAR2
,   x_allow_substitute_receipts        OUT NOCOPY VARCHAR2
,   x_routing_id                       OUT NOCOPY NUMBER
,   x_routing_name                     OUT NOCOPY VARCHAR2
,   x_qty_rcv_tolerance                OUT NOCOPY NUMBER
,   x_qty_rcv_exception_code           OUT NOCOPY VARCHAR2
,   x_days_early_receipt_allowed       OUT NOCOPY NUMBER
,   x_days_late_receipt_allowed        OUT NOCOPY NUMBER
,   x_receipt_days_exception_code      OUT NOCOPY VARCHAR2
,   p_payment_type                     IN         VARCHAR2 DEFAULT NULL  --Bug 4549207
);

/*===========================================================================
  FUNCTION NAME:	val_unique_receipt_num

  DESCRIPTION:		Function searches through rcv_shipment_headers looking
 			for the receipt number passed in.  If it finds a
			duplicate, it returns a value of FALSE.  If it doesn't
 			it searches through the po_history_receipts table
			looking for the receipt number passed in.  If it finds
			a duplicate, it returns a value of FALSE, otherwise it
			returns TRUE.

  PARAMETERS: 		x_receipt_num IN VARCHAR2

  RETURN VALUE:		TRUE if receipt number is unique, FALSE otherwise.

  DESIGN REFERENCES:	RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_unique_receipt_num(x_receipt_num IN VARCHAR2) RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_unique_shipment_num

  DESCRIPTION: 		Function searches through rcv_shipment_headers to
			validate that a shipment number is unique for
			a given vendor.

  PARAMETERS:		x_shipment_num	IN VARCHAR2
			x_vendor_id     IN NUMBER

  RETURN VALUE:		TRUE if shipment number is unique, FALSE otherwise.

  DESIGN REFERENCES:	RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_unique_shipment_num (x_shipment_num IN VARCHAR2,
				  x_vendor_id    IN NUMBER) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_ussgl_info

  DESCRIPTION:		Gets ussgl_transaction_code, government_context from
		  	po_line_locations.

  PARAMETERS:		x_line_location_id 	IN NUMBER
		 	x_ussgl_trx_code	OUT VARCHAR2
			x_govt_context		OUT VARCHAR2

  DESIGN REFERENCES:	RCVRCMUR.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_ussgl_info(x_line_location_id 	IN NUMBER,
			 x_ussgl_trx_code	OUT NOCOPY VARCHAR2,
			 x_govt_context		OUT NOCOPY VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:	val_po_shipment

  DESCRIPTION:  Call RCV_QUANTITIES_S.get_available_quantity to get the
		unit of measure, available and tolerable quantities for a
		po shipment.

  PARAMETERS:

  Parameter	       IN/OUT	Datatype   Description
  -------------------- -------- ---------- ----------------------------------
  x_trx_type		IN  	VARCHAR2   Transaction Type:
					      RECEIVE
					      MATCH

  x_parent_id	 	IN  	NUMBER     Line_location_id for Vendor Receipts
					   Shipment_line_id for Internal
						Receipts

  x_receipt_source_code IN  	VARCHAR2   Receipt Source Code:
					      VENDOR
					      INTERNAL
					      INVENTORY

  x_parent_trx_type	IN	VARCHAR    Parent Transaction Type

  x_grand_parent_id	IN 	NUMBER     Grand Parent ID

  x_correction_type	IN	VARCHAR2   Correction Type

  x_available_quantity	IN OUT 	NUMBER	   Quantity Available to Receive

  x_tolerable_qty	IN OUT 	NUMBER     Quantity Toleralbe to Receive

  x_uom			IN OUT 	VARCHAR2   Unit of Measure


  DESIGN REFERENCES:	RCVRCMUR.dd


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE val_po_shipment(x_trx_type		IN  VARCHAR2,
			  x_parent_id	 	IN  NUMBER,
			  x_receipt_source_code IN  VARCHAR2,
			  x_parent_trx_type	IN  VARCHAR2,
			  x_grand_parent_id	IN  NUMBER,
			  x_correction_type	IN  VARCHAR2,
			  x_available_quantity	IN OUT NOCOPY NUMBER,
			  x_tolerable_qty	IN OUT NOCOPY NUMBER,
			  x_uom			IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	val_exp_cas_func

  DESCRIPTION:
		- Ship to location is not available and the destination is to
		  receiving
 		- Deliver to Person/location is not available for Expense
		  Destination type and the destination is to final
  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
PROCEDURE val_exp_cas_func;


/*===========================================================================
  PROCEDURE NAME:	get_outside_processing_info

  DESCRIPTION:		Gets the following outside processing detials :

                           Job Schedule
                           Operation Sequence number
                           Department
                           WIp Line
                           BOM resource Id

  PARAMETERS:
                      x_po_distribution_id      IN NUMBER
                      x_organization_id         IN NUMBER
                      x_job_schedule           OUT VARCHAR2
                      x_operation_seq_num      OUT VARCHAR2
                      x_department             OUT VARCHAR2
                      x_wip_line               OUT VARCHAR2
                      x_bom_resource_id        OUT NUMBER,
	              x_po_operation_seq_num   OUT NUMBER,
        	      x_po_resource_seq_num    OUT NUMBER

  The po_operation and resource sequence numbers are off the po
  distribution and is used for inserting the transaction rather
  than the operation_seq_num which is derived from the wip tables
  and shows the next operation rather than the current one.  This
  value is used for display purposes


  RETURN VALUE:

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
procedure get_outside_processing_info ( x_po_distribution_id      IN NUMBER,
                                        x_organization_id         IN NUMBER,
                                        x_job_schedule           OUT NOCOPY VARCHAR2,
                                        x_operation_seq_num      OUT NOCOPY VARCHAR2,
                                        x_department             OUT NOCOPY VARCHAR2,
                                        x_wip_line               OUT NOCOPY VARCHAR2,
                                        x_bom_resource_id        OUT NOCOPY NUMBER,
	        		        x_po_operation_seq_num   OUT NOCOPY NUMBER,
	   	        	        x_po_resource_seq_num    OUT NOCOPY NUMBER
);

/*===========================================================================
  FUNCTION NAME:	get_note_count

  DESCRIPTION:

  PARAMETERS:     x_header_id     IN NUMBER
                  x_line_id       IN NUMBER
                  x_location_id   IN NUMBER
                  x_po_line_id    IN NUMBER
                  x_po_release_id IN NUMBER
                  x_po_header_id  IN NUMBER
                  x_item_id       IN NUMBER

  RETURN VALUE:   NUMBER

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
  FUNCTION GET_NOTE_COUNT ( x_header_id     IN NUMBER,
                            x_line_id       IN NUMBER,
                            x_location_id   IN NUMBER,
                            x_po_line_id    IN NUMBER,
                            x_po_release_id IN NUMBER,
                            x_po_header_id  IN NUMBER,
                            x_item_id       IN NUMBER) RETURN NUMBER ;
/*==========================================================================*/
  PROCEDURE OUT_OP_INFO ( x_wip_entity_id              IN NUMBER,
                          x_organization_id            IN NUMBER,
                          x_wip_repetitive_schedule_id IN NUMBER,
                          x_wip_operation_seq_num      IN NUMBER,
                          x_wip_resource_seq_num       IN NUMBER,
                          x_job_schedule_dsp          OUT NOCOPY VARCHAR2,
                          x_op_seq_num_dsp            OUT NOCOPY VARCHAR2,
                          x_department_code           OUT NOCOPY VARCHAR2);
/*==========================================================================*/
  PROCEDURE WIP_LINE_INFO ( x_wip_line_id              IN NUMBER,
                            x_org_id                   IN NUMBER,
                            x_wip_line_dsp            OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   DERIVE_SHIPMENT_INFO

  DESCRIPTION:      Procedure derives the shipment_header_id or shipment_num
                    based on information provided

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:   Raj Bhakta 07/09/97  Created
===========================================================================*/

  PROCEDURE DERIVE_SHIPMENT_INFO (
             X_header_record IN OUT NOCOPY  RCV_SHIPMENT_HEADER_SV.HeaderRecType);

/*===========================================================================
  PROCEDURE NAME:   DEFAULT_SHIPMENT_INFO

  DESCRIPTION:      Procedure defaults in information about the shipment record
                    based on information provided

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:   Raj Bhakta 07/09/97 Created
===========================================================================*/

  PROCEDURE DEFAULT_SHIPMENT_INFO  (
             X_header_record IN OUT NOCOPY  RCV_SHIPMENT_HEADER_SV.HeaderRecType);

/*===========================================================================
  PROCEDURE NAME:   VALIDATE_SHIPMENT_NUMBER

  DESCRIPTION:      Procedure validates the shipment record and returns
                    error status and error message based on pre-defined
                    business rules.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:   Raj Bhakta 10/30/96  Created
===========================================================================*/

  PROCEDURE VALIDATE_SHIPMENT_NUMBER (
             X_header_record IN OUT NOCOPY  RCV_SHIPMENT_HEADER_SV.HeaderRecType);

END RCV_CORE_S;

 

/

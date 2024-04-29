--------------------------------------------------------
--  DDL for Package RCV_TRANSACTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTIONS_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTXTXS.pls 115.3 2004/02/12 02:03:45 pjiang ship $*/

/*===========================================================================
  FUNCTION NAME:	val_receiving_controls

  DESCRIPTION:          Validates the receiving controls for express. There
   			are restrictions for this function since express
			doesn't validate all controls.  Here is a description
			of what is does.  To use this for standard
			functionality, we'll have to add the quantity
			tolerances and the ship-to-location and add a parameter
			for express/standard receiving.


      1. Receiving controls are only checked for vendor receipts. Intransit
         shipments cannot be rejected and we have not way to define org->org
         receiving controls.
      2. Controls are only checked if the exception level is 'REJECT'
      3. Quantity tolerances are not checked. It is not possible to
         over-receive an express receipt.
      4. Standard receipts will be created for the ship-to location
         specified on the PO so the 'enforce ship-to location' control
         is not tested.
      5. Routing controls are checked for both Vendor sourced and
         intransit receipts.



  PARAMETERS:

  Parameter	         IN/OUT	Datatype   Description
  -------------          ------ ---------- ----------------------------
  X_transaction_type     IN     VARCHAR2   What type of transaction are
                                           you validating(RECEIPT,TRANSFER,etc)
                                           (Used for routing checks)
  X_auto_transact_code   IN     VARCHAR2   Same as above except for direct
                                           receipts this is set to DELIVER
                                           (Also used for routing checks)

  X_expected_receipt_date IN    DATE       What is the promised/need by date
  X_transaction_date      IN    DATE       When was this transaction processed
  X_routing_header_id     IN    NUMBER     What is the routing for this trans
                                           1 = Standard Receipt
                                           2 = Inspection Required
                                           3 = Direct Receipt
  X_po_line_location_id   IN    NUMBER     What is the ling location to get
                                           the receiving controls
                                           (Debug: Should all the controls be
                                            passed in)
  X_item_id               IN    NUMBER     What is the item to get the
                                           receiving controls
  X_vendor_id             IN    NUMBER     Vendor Id - same reason as above
  X_to_organization_id    IN    NUMBER     Receiving org - same reason as above

  RETURN VALUE:	   Returns whether the values are valid for the receiving
		   controls

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION val_receiving_controls (
X_transaction_type      IN VARCHAR2,
X_auto_transact_code    IN VARCHAR2,
X_expected_receipt_date IN DATE,
X_transaction_date      IN DATE,
X_routing_header_id     IN NUMBER,
X_po_line_location_id   IN NUMBER,
X_item_id               IN NUMBER,
X_vendor_id             IN NUMBER,
X_to_organization_id    IN NUMBER)
RETURN NUMBER;

/*===========================================================================
  FUNCTION NAME:	val_wip_info

  DESCRIPTION:		Check that the required info for shop floor
			destinations are present: the
		   	job, the op seq num, the reource seq num, the
	 	  	repetive schedule and the wip line

  PARAMETERS:

  Parameter	         IN/OUT	Datatype   Description
  -------------          ------ ---------- ----------------------------
  X_to_organization_id    IN      NUMBER   Receiving Org
  X_wip_entity_id         IN      NUMBER   Wip Entity
  X_wip_operation_seq_num IN      NUMBER   Wip Oper Sequence Number
  X_wip_resource_seq_num  IN      NUMBER   Wip Resrc Sequence Number
  X_wip_line_id           IN      NUMBER   Wip Line
  X_wip_repetitive_schedule_id IN NUMBER   Wip Repetitve Schedule Id
  p_po_line_id            IN      NUMBER   PO Line Id -- bug 2619164


  RETURN VALUE:	   Returns whether the values are valid

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION val_wip_info (
X_to_organization_id         IN NUMBER,
X_wip_entity_id              IN NUMBER,
X_wip_operation_seq_num      IN NUMBER,
X_wip_resource_seq_num       IN NUMBER,
X_wip_line_id                IN NUMBER,
X_wip_repetitive_schedule_id IN NUMBER,
p_po_line_id                 IN NUMBER) -- bug 2619164
RETURN NUMBER;

/*===========================================================================
  PROCEDURE NAME:	val_if_inventory_destination

  DESCRIPTION:		Check to see if any of the distributions are of
			type inventory.  This is used to tell us if we need
			to check for item rev control for an item.  If there
			are no inventory destinations then you don't care
			about the item rev if it's not specified.

  PARAMETERS:		X_line_location_id  IN NUMBER
			X_shipment_line_id  IN NUMBER

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
FUNCTION val_if_inventory_destination (
X_line_location_id  IN NUMBER,
X_shipment_line_id  IN NUMBER)
RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	val_deliver_destination

  DESCRIPTION:		Ensure that all mandatory columns for each
			destination type are populated. If a mandatory
			column is not specified, the transaction
			cannot be processed via express.
			The exceptions are subinventory and locator.
			If a sub is provided it will be used otherwise
			the default receiving subinventory will
			be used (if available). Locator control is
			evaluated if a sub is provided or defaulted
			and if locator control is required, the default
			locator for the sub will be used.

  PARAMETERS:		X_to_organization_id     IN NUMBER
			X_item_id                IN NUMBER
			X_destination_type_code  IN VARCHAR2
			X_deliver_to_location_id IN NUMBER
			X_subinventory           IN VARCHAR2

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
FUNCTION val_deliver_destination (
X_to_organization_id     IN NUMBER,
X_item_id                IN NUMBER,
X_destination_type_code  IN VARCHAR2,
X_deliver_to_location_id IN NUMBER,
X_subinventory           IN VARCHAR2)
RETURN NUMBER;

/*===========================================================================

 PROCEDURE NAME:	val_destination_info

/*===========================================================================
  PROCEDURE NAME:	val_deliver_destination

  DESCRIPTION:

  Ensure that all destination information is still valid at the time of
  receipt.  A po can be created with a ship to location or a deliver to
  location that could become invalid by the time the receipt is entered.
  To ensure that the lov's for one of these fields does not come up
  because the item is not in the valid list, we will not populate the
  column if it is disabled


  PARAMETERS:		X_to_organization_id        IN NUMBER
			X_item_id                   IN NUMBER
			X_ship_to_location_id       IN NUMBER
			X_deliver_to_location_id    IN NUMBER
			X_deliver_to_person_id      IN NUMBER
			X_subinventory              IN VARCHAR2
			X_valid_ship_to_location    OUT BOOLEAN
			X_valid_deliver_to_location OUT BOOLEAN
			X_valid_deliver_to_person   OUT BOOLEAN
			X_valid_subinventory        OUT BOOLEAN


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/

PROCEDURE val_destination_info (
X_to_organization_id        IN NUMBER,
X_item_id                   IN NUMBER,
X_ship_to_location_id       IN NUMBER,
X_deliver_to_location_id    IN NUMBER,
X_deliver_to_person_id      IN NUMBER,
X_subinventory              IN VARCHAR2,
X_valid_ship_to_location    OUT NOCOPY BOOLEAN,
X_valid_deliver_to_location OUT NOCOPY BOOLEAN,
X_valid_deliver_to_person   OUT NOCOPY BOOLEAN,
X_valid_subinventory        OUT NOCOPY BOOLEAN);

/*===========================================================================
  FUNCTION NAME:	val_pending_receipt_trx

  DESCRIPTION:		If there are any receipt supply rows that have
			not been delivered and this line location has
			multiple distributions then it cannot be
			transacted since you don't know how the user
			will distribute that quantity

  PARAMETERS:		X_po_line_location_id IN NUMBER
			X_group_id            IN NUMBER

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
FUNCTION val_pending_receipt_trx (
X_po_line_location_id IN NUMBER,
X_group_id            IN NUMBER)
RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:	get_wip_info

  DESCRIPTION:		Goes out and gets the wip information related to
                        a po line.

  PARAMETERS:

 X_wip_entity_id              IN          NUMBER
 X_wip_repetitive_schedule_id IN          NUMBER
 X_wip_line_id                IN          NUMBER
 X_wip_operation_seq_num      IN          NUMBER
 X_wip_resource_seq_num       IN          NUMBER
 X_to_organization_id         IN          NUMBER
 X_job                        IN OUT      VARCHAR2
 X_line_num                   IN OUT      VARCHAR2
 X_sequence                   IN OUT      NUMBER
 X_department                 IN OUT      VARCHAR2

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
  FUNCTION NAME:	get_wip_info

===========================================================================*/
/*
** Go get the outside processing information for a given receipt line
*/

PROCEDURE get_wip_info
(X_wip_entity_id              IN          NUMBER,
 X_wip_repetitive_schedule_id IN          NUMBER,
 X_wip_line_id                IN          NUMBER,
 X_wip_operation_seq_num      IN          NUMBER,
 X_wip_resource_seq_num       IN          NUMBER,
 X_to_organization_id         IN          NUMBER,
 X_job                        IN OUT NOCOPY      VARCHAR2,
 X_line_num                   IN OUT NOCOPY      VARCHAR2,
 X_sequence                   IN OUT NOCOPY      NUMBER,
 X_department                 IN OUT NOCOPY      VARCHAR2);

/*===========================================================================

  PROCEDURE NAME: get_rma_dest_info

  DESCRIPTION:    Go get the destination information for a given RMA line

  PARAMETERS:

x_oe_order_header_id          IN                 NUMBER,
x_oe_order_line_id            IN                 NUMBER,
x_item_id                     IN                 NUMBER,
x_deliver_to_sub              IN OUT NOCOPY      VARCHAR2,
x_deliver_to_location_id      IN OUT NOCOPY      NUMBER,
x_deliver_to_location         IN OUT NOCOPY      VARCHAR2,
x_destination_type_dsp        IN OUT NOCOPY      VARCHAR2,
x_destination_type_code       IN OUT NOCOPY      VARCHAR2,
x_to_organization_id          IN OUT NOCOPY      NUMBER,
x_rate                        IN OUT NOCOPY      NUMBER,
x_rate_date                   IN OUT NOCOPY      DATE

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
/*
** Go get the destination information for a given RMA line
*/

PROCEDURE get_rma_dest_info
(x_oe_order_header_id         IN                 NUMBER,
x_oe_order_line_id            IN                 NUMBER,
x_item_id                     IN                 NUMBER,
x_deliver_to_sub              IN OUT NOCOPY      VARCHAR2,
x_deliver_to_location_id      IN OUT NOCOPY      NUMBER,
x_deliver_to_location         IN OUT NOCOPY      VARCHAR2,
x_destination_type_dsp        IN OUT NOCOPY      VARCHAR2,
x_destination_type_code       IN OUT NOCOPY      VARCHAR2,
x_to_organization_id          IN OUT NOCOPY      NUMBER,
x_rate                        IN OUT NOCOPY      NUMBER,
x_rate_date                   IN OUT NOCOPY      DATE);

END RCV_TRANSACTIONS_SV;

 

/

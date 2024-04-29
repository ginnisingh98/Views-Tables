--------------------------------------------------------
--  DDL for Package Body RCV_SUB_LOCATOR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SUB_LOCATOR_SV" AS
/* $Header: RCVTXLOB.pls 115.2 2002/11/25 21:42:25 sbull ship $*/


/*===========================================================================

  PROCEDURE NAME:	put_away_api

  DESCRIPTION:

  This function is meant to be an user extensible feature that allows the
  user to add derivation rules to set the default deliver subinventory
  and locator_id.  The Receipts, Transactions, and Returns forms in
  Oracle Purchasing use this function to determine what the default value
  for the sub and locator should be.  If you wish to create you're own
  rules for this function, then feel free to add any logic that you wish.

  PARAMETERS:

  x_line_location_id	   IN NUMBER - 	The primary key (line_location_id)
					from the po_line_locations table
					Only for Receipt_Source_Code = VENDOR

  x_po_distribution_id 	   IN NUMBER - 	The primary key (po_distribution_id)
					from the po_distributions table
					Only for Receipt_Source_Code = VENDOR

  x_shipment_line_id	   IN NUMBER -  The primary key (shipment_line_id)
					from the rcv_shipment_lines table

  x_receipt_source_code    IN VARCHAR2-	Describes the type of document the
					shipment is based upon.  Possible
					values are 'INTERNAL ORDER' (for
					internal requisition transaction),
					'INVENTORY' (for in-transit
					transaction),VENDOR (for purchase order
					transaction).  Source of this value is
					SHIPMENT SOURCE TYPE lookup value from
					po_lookup_codes.

  x_ship_from_org_id       IN NUMBER -  Organization that the shipment came
					from
					Only for Receipt_Source_Code =
					INTERNAL ORDER or INVENTORY


  x_ship_to_org_id         IN NUMBER -  Destination Organization for the
					shipment

  x_item_id		   IN NUMBER -  The item primary key from
					mtl_system_items

  x_item_revision    	   IN VARCHAR2-	The revision of the item that you are
					transacting

  x_vendor_id   	   IN NUMBER -	The vendor primary key from
					po_vendors

  x_ship_to_location_id	   IN NUMBER  - The ship to location id primary key
					from hr_locations

  x_deliver_to_location_id IN NUMBER  - The deliver to location id primary key
					from hr_locations

  x_deliver_to_person_id   IN NUMBER  - The deliver to person id primary key
					from hr_employees

  x_available_qty          IN NUMBER  - The quantity available to transact in
					the parent unit of measure.  The parent
					being for a receipt the purchase order
					line unit or for a inspection it's
					the receipt unit.

  x_uom		           IN VARCHAR2- Parent unit of measure.  The parent
					being for a receipt the purchase order
					line unit or for a inspection it's
					the receipt unit.

  x_primary_qty	 	   IN NUMBER  - The quantity available to transact in
					the primary unit of measure

  x_primary_uom		   IN VARCHAR2- Primary unit of measure.

  x_tolerable_qty	   IN NUMBER  - The maximum quantity that can be
					transacted based on quantity
					precentage tolerances.  This is only
					applicable to receipts since the max
					for other transactions is what's
					available for the parent transaction.

  x_routing_id             IN NUMBER  - The routing definition for the shipment
					1=Standard receipt, 2=Inspection
					3=Direct Receipt
  x_default_subinventory   IN VARCHAR2- The default subinventory derived
					using our standard rules and
					functionality.  For example, look at the
					purchase order distribution, if you don't
					find it there get it from the item. etc.
  x_default_locator_id     IN NUMBER  - The default locator_id derived
					using our standard rules and
					functionality
  x_subinventory           IN OUT VARCHAR2 - The outbound subinventory that
					     you've derived
  x_locator_id             IN OUT NUMBER   - The outbound locator_id that
					     you've derived

  RETURN VALUE		   BOOLEAN    - Not currently used

===========================================================================*/

FUNCTION put_away_api (	 x_line_location_id		 IN NUMBER,
                         x_po_distribution_id 	 	 IN NUMBER,
			 x_shipment_line_id		 IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_ship_from_org_id              IN NUMBER,
                         x_ship_to_org_id                IN NUMBER,
			 x_item_id			 IN NUMBER,
			 x_item_revision	         IN VARCHAR2,
			 x_vendor_id   	       		 IN NUMBER,
			 x_ship_to_location_id		 IN NUMBER,
    			 x_deliver_to_location_id	 IN NUMBER,
    			 x_deliver_to_person_id	 	 IN NUMBER,
                         x_available_qty                 IN NUMBER,
                         x_primary_qty	 		 IN NUMBER,
			 x_primary_uom			 IN VARCHAR2,
			 x_tolerable_qty	         IN NUMBER,
                         x_uom		                 IN VARCHAR2,
			 x_routing_id          		 IN NUMBER,
                         x_default_subinventory          IN VARCHAR2,
                         x_default_locator_id            IN NUMBER,
                         x_subinventory                  IN OUT NOCOPY VARCHAR2,
                         x_locator_id                    IN OUT NOCOPY NUMBER )
RETURN BOOLEAN IS

X_progress    VARCHAR2(4) := '000';

BEGIN

   X_progress := '010';

   /*
   ** Current functionality sets the outbound default subinventory and locator
   ** to the defaults that were passed in.  If you wish to create put away
   ** rules other than standard defaulting logic then feel free to add to
   ** this function.  The last action of this function should be to set the
   ** outbound subinventory and locator_id values.  This will in turn be used
   ** when querying the values for Enter Receipts, Enter Transactions, and
   ** Enter Returns.
   */
   x_subinventory := x_default_subinventory;
   x_locator_id   := x_default_locator_id;

   RETURN (TRUE);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('rcv_express_sv.put_away_api', X_progress,
        sqlcode);
   RAISE;

END put_away_api;

END rcv_sub_locator_sv;

/

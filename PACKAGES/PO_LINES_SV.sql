--------------------------------------------------------
--  DDL for Package PO_LINES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV" AUTHID CURRENT_USER as
/* $Header: POXPOL1S.pls 120.2 2005/08/17 06:55:20 arudas noship $ */

/*===========================================================================
  PACKAGE NAME:		PO_LINES_SV

  DESCRIPTION:		This package contains the server side Line level
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  FUNCTION/PROCEDURE:	get_line_num()
			val_line_num_unique()
			delete_line()
			delete_all_lines()
			delete_children()
			val_delete()
			val_update()
			val_approval_status()
			update_released_quantity()
===========================================================================*/



/*===========================================================================
  PROCEDURE NAME:	delete_line()

  DESCRIPTION:		This procedure contains the necessary server side
			Application Program Interfaces which verify deletion
			is permitted on a line, deletes the line, and deletes the
			children of that line.

  PARAMETERS:		X_type_lookup_code	IN	VARCHAR2
			X_po_line_id		IN	NUMBER
			X_row_id		IN	VARCHAR2
                        p_skip_validation       IN      VARCHAR2 DEFAULT NULL

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXSCERQ.dd

  ALGORITHM:		Call the delete validation routines for
			PO/RFQ/Quote lines.

			Delete Line

			Delete Children of line

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		05-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE delete_line
		(X_type_lookup_code  	IN	VARCHAR2,
		 X_po_line_id		IN	NUMBER,
		 X_row_id		IN	VARCHAR2,
                 p_skip_validation      IN      VARCHAR2 DEFAULT NULL);----<HTML Agreements R12>

/*===========================================================================
  PROCEDURE NAME:	delete_all_lines()

  DESCRIPTION:		This procedure deletes all children of a selected line.

  PARAMETERS:		X_po_header_id		IN	NUMBER
                        p_type_lookup_code      IN      VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE delete_all_lines( X_po_header_id	IN	NUMBER
                           ,p_type_lookup_code  IN      VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	delete_children()

  DESCRIPTION:		This procedure deletes all children of a selected line.

  PARAMETERS:		X_type_lookup_code	IN	VARCHAR2
			X_po_line_id		IN	NUMBER

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		05-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE delete_children
		(X_type_lookup_code  	IN	VARCHAR2,
		 X_po_line_id		IN	NUMBER);

/*===========================================================================
  PROCEDURE NAME:	check_line_deletion_allowed()

  DESCRIPTION:		This procedure is a delete validation routine for
			Purchase Orders.  It checks if there are any
			approved or previously approved shipments for the
			line, or if there are any encumbered shipments.  If
			any shipment meets these criterium, error messages
                        are placed on the stack.

  PARAMETERS:		X_po_line_id		IN	NUMBER,
			X_allow_delete	  	IN OUT	VARCHAR2
                        p_token                 IN VARCHAR2 DEFAULT NULL,
                        p_token_value           IN VARCHAR2 DEFAULT NULL

  NOTES:  This is the same procedure as val_line_delete, except exceptions
          are not raised.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		09-MAY-95	MSNYDER
===========================================================================*/


PROCEDURE check_line_deletion_allowed
		(X_po_line_id		IN	NUMBER,
		 X_allow_delete	  	IN OUT	NOCOPY VARCHAR2,
                 p_token		IN	VARCHAR2 DEFAULT NULL,
                 p_token_value		IN	VARCHAR2 DEFAULT NULL,
		 x_message_text         OUT     NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	val_delete()

  DESCRIPTION:		This procedure is a delete validation routine for
			Purchase Orders.  It checks if there are any
			approved or previously approved shipments for the
			line, or if there are any encumbered shipments.  If
			any shipment meets these criterium, the line cannot
			be deleted.

  PARAMETERS:		X_po_line_id		IN	NUMBER,
			X_allow_delete	  	IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		09-MAY-95	MSNYDER
===========================================================================*/


PROCEDURE test_val_line_delete(X_po_line_id		IN	NUMBER);

PROCEDURE val_line_delete
		(X_po_line_id		IN	NUMBER,
		 X_allow_delete	  	IN OUT	NOCOPY VARCHAR2,
                 p_token		IN	VARCHAR2 DEFAULT NULL,  -- Bug 3453216
                 p_token_value		IN	VARCHAR2 DEFAULT NULL); -- Bug 3453216
/*===========================================================================
   PROCEDURE NAME:	val_update()

  DESCRIPTION:		This procedure calls the shipment level procedure,
 			val_schedule_released_qty.  Based on the value
			of returned parameters, this procedure will display
			a message to the user informing them they cannot
			reduce the quantity ordered to less than what has
			already been released.

  PARAMETERS:		X_po_line_id		IN	NUMBER,
		 	X_quantity_ordered	IN	NUMBER

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		09-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE val_update(X_po_line_id		IN	NUMBER,
		     X_quantity_ordered		IN	NUMBER);

/*===========================================================================
  FUNCTION NAME:	val_approval_status()

  DESCRIPTION:		Validates if the line needs to be unapproved.

  PARAMETERS:		X_po_line_id			IN	NUMBER,
			X_type_lookup_code		IN	VARCHAR2,
			X_unit_price			IN 	NUMBER,
			X_line_num			IN	NUMBER,
			X_item_id			IN	NUMBER,
			X_item_description		IN	VARCHAR2,
	*MPO		X_quantity			IN	NUMBER,
			X_unit_meas_lookup_code		IN	VARCHAR2,
			X_from_header_id		IN	NUMBER,
			X_from_line_id			IN	NUMBER,
			X_hazard_class_id		IN	NUMBER,
			X_vendor_product_num		IN	VARCHAR2,
			X_un_number_id			IN	NUMBER,
			X_note_to_vendor		IN	VARCHAR2,
			X_item_revision			IN	VARCHAR2,
			X_category_id			IN	NUMBER,
			X_price_type_lookup_code	IN	VARCHAR2,
			X_not_to_exceed_price		IN	NUMBER,
	*PAG		X_quantity_committed		IN	NUMBER,
	*PAG		X_committed_amount		IN	NUMBER,
                        p_contract_id                   IN      NUMBER, -- <GC FPJ>
                        -- <SERVICES FPJ START>
                        X_contractor_first_name         IN      VARCHAR2,
                        X_contractor_last_name          IN      VARCHAR2,
                        X_assignment_start_date         IN      DATE,
                        X_amount_db                     IN      NUMBER
                        -- <SERVICES FPJ END>

  RETURN VALUE:		BOOLEAN

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		09-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_approval_status
		(X_po_line_id			IN	NUMBER,
		 X_type_lookup_code		IN	VARCHAR2,
		 X_unit_price			IN 	NUMBER,
		 X_line_num			IN	NUMBER,
		 X_item_id			IN	NUMBER,
		 X_item_description		IN	VARCHAR2,
		 X_quantity			IN	NUMBER,
		 X_unit_meas_lookup_code	IN	VARCHAR2,
		 X_from_header_id		IN	NUMBER,
		 X_from_line_id			IN	NUMBER,
		 X_hazard_class_id		IN	NUMBER,
		 X_vendor_product_num		IN	VARCHAR2,
		 X_un_number_id			IN	NUMBER,
		 X_note_to_vendor		IN	VARCHAR2,
		 X_item_revision		IN	VARCHAR2,
		 X_category_id			IN	NUMBER,
		 X_price_type_lookup_code	IN	VARCHAR2,
		 X_not_to_exceed_price		IN	NUMBER,
		 X_quantity_committed		IN	NUMBER,
		 X_committed_amount		IN	NUMBER,
                 p_contract_id                  IN      NUMBER    -- <GC FPJ>
);

-- <GC FPJ>
-- Add Contract_ID and remove contract_num

FUNCTION val_approval_status
		(X_po_line_id			IN	NUMBER,
		 X_type_lookup_code		IN	VARCHAR2,
		 X_unit_price			IN 	NUMBER,
		 X_line_num			IN	NUMBER,
		 X_item_id			IN	NUMBER,
		 X_item_description		IN	VARCHAR2,
		 X_quantity			IN	NUMBER,
		 X_unit_meas_lookup_code	IN	VARCHAR2,
		 X_from_header_id		IN	NUMBER,
		 X_from_line_id			IN	NUMBER,
		 X_hazard_class_id		IN	NUMBER,
		 X_vendor_product_num		IN	VARCHAR2,
		 X_un_number_id			IN	NUMBER,
		 X_note_to_vendor		IN	VARCHAR2,
		 X_item_revision		IN	VARCHAR2,
		 X_category_id			IN	NUMBER,
		 X_price_type_lookup_code	IN	VARCHAR2,
		 X_not_to_exceed_price		IN	NUMBER,
		 X_quantity_committed		IN	NUMBER,
		 X_committed_amount		IN	NUMBER,
                 X_expiration_date              IN      DATE,
		 p_contract_id                  IN      NUMBER,
                 X_contractor_first_name        IN      VARCHAR2 default null,
                 X_contractor_last_name         IN      VARCHAR2 default null,
                 X_assignment_start_date        IN      DATE     default null,
		 X_amount_db                    IN      NUMBER   default null
                ) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	update_released_quantity()

  DESCRIPTION:		This procedure will adjust the line level
			released quantity when a release shipment
			is inserted, updated, or deleted.

   PARAMETERS:		X_event			IN	VARCHAR2,
			X_shipment_type		IN	VARCHAR2,
			X_po_line_id		IN	NUMBER,
			X_original_quantity	IN	NUMBER,
			X_quantity		IN	NUMBER

  DESIGN REFERENCES:	../POXPOREL.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		10-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE update_released_quantity
		(X_event		IN	VARCHAR2,
		 X_shipment_type	IN	VARCHAR2,
		 X_po_line_id		IN	NUMBER,
		 X_original_quantity	IN	NUMBER,
		 X_quantity		IN	NUMBER);

END PO_LINES_SV;

 

/

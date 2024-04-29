--------------------------------------------------------
--  DDL for Package PO_NOTIF_CONTROLS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIF_CONTROLS_SV" AUTHID CURRENT_USER AS
/*$Header: POXPONCS.pls 120.0.12010000.1 2008/09/18 12:21:01 appldev noship $*/
/*===========================================================================
  PROCEDURE NAME:	delete_notifs()

  DESCRIPTION:
          	- Delete children when deleting header;
		  po lines all po line locations all po distributions planned
	          /std po notification controls planned/blanket
           	- Delete children when deleting header;
                  po lines al po line locations all po distribution planned/
		  std po notification controls 	planned/blanket po
		  notifications
[DEBUG; DELETE_NOTIFICATIONS]
		 attachements
[DEBUG; DELETE_ATTACHMENTS]

                - Update po_requisition_lines to remove the link to
    	    	 the shipment if you are deleting a standard or planned PO

        	UPDATE po_requisition_lines
    	   	SET    line_location_id = NULL
    	   	WHERE  line_location_id in (SELECT line_location_id
                FROM   po_line_locations
                WHERE  po_header_id = Delete_Me.po_header_id)

                         Refer Closed Issue #3.
  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 FUNCTION delete_notifs(X_po_header_id IN number)
          return boolean;

/*===========================================================================
  FUNCTION NAME:	val_notif_controls()

  DESCRIPTION:          This procedure checks amount based notification
                        control records for a planned, contract and
                        blanket purchase order.  If there are any amount
                        based control exist, it return TRUE to the caller.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       11/13/95   WLAU           created.
===========================================================================*/

 FUNCTION val_notif_controls (X_po_header_id number)
          return boolean;

/*===========================================================================
  FUNCTION NAME:	val_date_notif()

  DESCRIPTION:
        o VAL - check the notification controls when this field is changed.
           	If there are any date based controls , display the error
		message PO_PO_NFC_DATE_CONTROLS_EXIST.  This returns failu
        o VAL - check the notification controls when this field is changed.
           	If there are any date based controls , display the error
                message
           	PO_PO_NFC_DATE_CONTROLS_EXIST.  This returns failure.

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 FUNCTION val_date_notif(X_po_header_id number,
                         X_end_date    date)
            return boolean;

END PO_NOTIF_CONTROLS_SV;

/

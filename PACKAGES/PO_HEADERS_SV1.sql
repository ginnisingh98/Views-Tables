--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPOH1S.pls 120.2.12010000.2 2011/05/23 10:33:27 vegajula ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_HEADERS_SV1';

/*===========================================================================
  FUNCTION NAME:	lock_row_for_status_update

  DESCRIPTION:   	Locks the row in the po_headers table for update.

  PARAMETERS:		x_po_header_id		IN	NUMBER

  DESIGN REFERENCES:	POXDOAPP.dd, POXDOCON.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	7/26	created it
                        wlau    7/31    change api name
===========================================================================*/

PROCEDURE lock_row_for_status_update (x_po_header_id	  IN  NUMBER);

/*===========================================================================
  FUNCTION NAME:	val_po_encumbered()

  DESCRIPTION:
		- Can approve only if the following are true:
			- If approving from entry form, either can_preparer_approve flag = 'Y'
		          or user is not preparer of document.
			- Status of the doc is IN PROCESS, INCOMPLETE,
			    REQUIRES REAPPROVAL, REJECTED, or RETURNED.
			- If status is pre-approved, either the
			  req-encumbrance flag is off or the req is fully
			  encumbered.  (Call acceptance routine.)

  	    - If a PO:
		- Can approve only if the following are true:
			- status of the doc is IN PROCESS, INCOMPLETE, REJECTED, or REQUIRES
			  REAPPROVAL. (Call the approve routine)
			- if status is pre-approved, either PO_encumbrance flag is off or
			  the PO is fully encumbered. (Call acceptance routine)
 			- If approving from entry form, either can_preparer_approve_flag = 'Y'
			  or user is not preparer of document.
                - Can always forward document.
			- IF document has status INCOMPLETE, REQUIRES REAPPROVAL, REJECTED, RETURNED:
                          Call the submit routine
			- IF document has status IN PROCESS, PRE APPROVED: Call the forward routine
		- Can always reject document.
		- Can reserve for PO and releases only if
			- there are PO lines that are not cancelled and not finally closed
			  with encumbered_flag = 'N'and shipment type is not 'Price Break'.
  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXDOAPP.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

--PROCEDURE val_po_encumbered();



/*===========================================================================
  FUNCTION NAME:	val_delete()

  DESCRIPTION:   Checks if the PO/PA is not encumbered.
                 If itis encumbered, cannot delete the document.



  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

  FUNCTION val_delete(X_po_header_id IN NUMBER , X_type_lookup_code IN VARCHAR2)
           return boolean;

/*===========================================================================
  PROCEDURE NAME:	get_po_encumbered()

  DESCRIPTION:   Check if any distributions for a PO is encumbered.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 FUNCTION get_po_encumbered(X_po_header_id IN number)
          return boolean;

/*===========================================================================
  PROCEDURE NAME:	delete_children()

  DESCRIPTION:  Delete Lines, Shipments, Distributions for given PO/PA.
                If it is a Planned PO/Blanket, delete the relevant
                Notification Controls.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 PROCEDURE delete_children(X_po_header_id IN NUMBER , X_type_lookup_code IN VARCHAR2);

/*===========================================================================
  FUNCTION NAME:	delete_po()

  DESCRIPTION:   Check if the PO can be deleted :
                     i) Cannot delete if there exist any encumbered distribution.
                 If the PO can be deleted,
                   delete the header,
                   remove the reqisistion link to the shipment,
                   delete the children ( lines, shipments, distibutions, notif. controls)
                   delete attachments
                   delete notifications

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 FUNCTION delete_po(X_po_header_id     IN NUMBER,
                    X_type_lookup_code IN VARCHAR2,
		    p_skip_validation  IN VARCHAR2 DEFAULT NULL) --<HTML Agreements R12>
          return boolean;

--<HTML Agreements R12 Start>
PROCEDURE validate_delete_document(
                    p_doc_type          IN VARCHAR2
                   ,p_doc_header_id     IN NUMBER
                   ,p_doc_approved_date IN DATE
                   ,p_auth_status       IN VARCHAR2
                   ,p_style_disp_name   IN VARCHAR2
                   ,x_message_text      OUT NOCOPY VARCHAR2);

PROCEDURE delete_document( p_doc_type            IN VARCHAR2
                          ,p_doc_subtype         IN VARCHAR2
                          ,p_doc_header_id       IN NUMBER
                          ,p_ga_flag             IN VARCHAR2
                          ,p_conterms_exist_flag IN VARCHAR2
                          ,x_return_status       OUT NOCOPY VARCHAR2);

--<HTML Agreements R12 End>

/*===========================================================================
  PROCEDURE NAME:	delete_this_release()

  DESCRIPTION: Delete the Releases against the PA that is
               currently being deleted.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 PROCEDURE delete_this_release(X_po_header_id IN NUMBER);

/*===========================================================================
 * NOTE: MOVED to po_headers_sv11

  PROCEDURE NAME:	insert_po()

  DESCRIPTION:
          - call PO HEADERS table handler to insert the header
          - call notification API to create a notification
			[DEBUG;SEND_NOTIFICATION
  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: MOVED To po_headers_sv11
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	insert_children()

  DESCRIPTION:
          - call notification API to create a notification
			[DEBUG;SEND_NOTIFICATION]
  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

--PROCEDURE insert_children();


/*===========================================================================
  Bug 12405805
  PROCEDURE NAME:	delete_events_entities()

  DESCRIPTION:
       Use XLA APIs to delete unnecessary events and entities
  PARAMETERS: Doc type and Doc header id

  ALGORITHM: Delete all the Unprocessed events associated with the document.
  After that, if there are no Processed events associated with the document, we delete the entity associated with the document also.


  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/


PROCEDURE Delete_events_entities(p_doc_entity IN VARCHAR2,
                                 p_doc_id     IN NUMBER);



END PO_HEADERS_SV1;

/

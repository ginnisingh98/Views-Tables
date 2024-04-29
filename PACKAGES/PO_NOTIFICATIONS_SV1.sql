--------------------------------------------------------
--  DDL for Package PO_NOTIFICATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIFICATIONS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXBWN1S.pls 115.1 2002/11/25 23:08:49 sbull ship $*/

/*===========================================================================
  PROCEDURE NAME: 	delete_po_notif

  DESCRIPTION:		- This procedure is called by the following forms:
				- Enter POs
				- Enter PAs
				- Enter Releases
				- Enter REQs
				- Enter Quotes
				- Enter RFQs
				- Enter Acceptances
				- Control Documents

			- It is called when:
				- Document is deleted
				- Acceptance is entered
				- Document is finally closed or cancelled

			- It deletes all notifications for a given document.
			  For document of type BLANKET, it deletes all
			  notifications for releases against the blanket

			  The document types are:
				- STANDARD
				- PLANNED
				- INTERNAL
				- PURCHASE
				- BLANKET
				- CONTRACT
				- RELEASE
				- SCHEDULED
				- QUOTATION
				- RFQ

  PARAMETERS:		x_document_type_code IN  VARCHAR2,
		        x_object_id          IN  NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE delete_po_notif (x_document_type_code IN  VARCHAR2,
		             x_object_id          IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	delete_notif_by_id_type

  DESCRIPTION:		Deletes all notifications for a document given the
			document type and id.

  PARAMETERS:		x_object_id 	NUMBER,
   			x_doc_type  	VARCHAR

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE delete_notif_by_id_type(x_object_id 	NUMBER,
   				    x_doc_type  	VARCHAR2);

/*===========================================================================
  PROCEDURE NAME: 	send_po_notif

  DESCRIPTION:		- This procedure is called by the following forms:
				- Enter POs
				- Enter PAs
				- Enter Releases
				- Enter Requisitions
				- Enter Express Requsitions
				- Enter Quotes
				- Enter RFQs
				- Control Documents

			- It is called when:
				- Document is inserted
				- Document is updated
				- Document is put on hold
				- Document is released from hold

			- It deletes the notification for a given document
			  and inserts a new notification with updated information.
 			  For documents of type BLANKET, it deletes and reinserts
			  notifications for all releases against the blanket.
			  The document types are:
				- STANDARD
				- PLANNED
				- INTERNAL
				- PURCHASE
				- BLANKET
				- CONTRACT
				- RELEASE
				- SCHEDULED
				- QUOTATION
				- RFQ

  PARAMETERS:		x_document_type_code  IN  VARCHAR2,
	                x_object_id	      IN  NUMBER,
		        x_currency_code	      IN  VARCHAR2,
		        x_start_date_active   IN  DATE DEFAULT NULL,
		        x_end_date_active     IN  DATE DEFAULT NULL,
		        x_forward_to_id	      IN  NUMBER DEFAULT NULL,
			x_forward_from_id     IN  NUMBER DEFAULT NULL,
			x_note		      IN  VARCHAR2 DEFAULT NULL

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE send_po_notif(x_document_type_code  IN  VARCHAR2,
	                x_object_id	      IN  NUMBER,
		        x_currency_code	      IN  VARCHAR2 DEFAULT NULL,
		        x_start_date_active   IN  DATE DEFAULT NULL,
		        x_end_date_active     IN  DATE DEFAULT NULL,
		        x_forward_to_id	      IN  NUMBER DEFAULT NULL,
			x_forward_from_id     IN  NUMBER DEFAULT NULL,
			x_note		      IN  VARCHAR2 DEFAULT NULL);

/*===========================================================================
  PROCEDURE NAME: 	get_notif_data

  DESCRIPTION:		Retrieves the following information required for
			inserting a notification into the fnd_notifications
			table:
				- start effective date
				- recipient id
				- message name
				- document number
				- document description
				- release number if document type is RELEASE
				- currency code
				- document total
				- sender id
				- note from approver
				- document owner id
				- document creation date
				- acceptance due date if acceptance is required
   				- expiration date if document type is QUOTATION
   				- close date if document type is RFQ

  PARAMETERS:		x_document_type_code  	IN      VARCHAR2,
		    	x_object_id           	IN      NUMBER,
	            	x_end_date_active     	IN      DATE,
		    	x_start_date_active  	IN OUT  DATE,
		    	x_employee_id	  	IN OUT  NUMBER,
		    	x_message_name	  	IN OUT  VARCHAR2,
		    	x_doc_num		IN OUT  VARCHAR2,
			x_doc_creation_date	IN OUT  DATE,
			x_currency_code	  	IN OUT  VARCHAR2,
		    	x_from_id		IN OUT  VARCHAR2,
		    	x_note		  	IN OUT  VARCHAR2,
		    	x_expiration_date	IN OUT  DATE,
		    	x_close_date	  	IN OUT  DATE,
		    	x_acceptance_due_date 	IN OUT  DATE,
		    	x_attribute_array	IN OUT  ntn.char_array

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE get_notif_data (x_document_type_code  IN      VARCHAR2,
		    x_object_id           IN      NUMBER,
	            x_end_date_active     IN      DATE,
		    x_start_date_active	  IN OUT NOCOPY  DATE,
		    x_employee_id	  IN OUT NOCOPY  NUMBER,
		    x_message_name	  IN OUT NOCOPY  VARCHAR2,
		    x_doc_num		  IN OUT NOCOPY  VARCHAR2,
		    x_doc_creation_date   IN OUT NOCOPY  DATE,
		    x_currency_code	  IN OUT NOCOPY  VARCHAR2,
		    x_from_id		  IN OUT NOCOPY  NUMBER,
		    x_note		  IN OUT NOCOPY  VARCHAR2,
		    x_expiration_date	  IN OUT NOCOPY  DATE,
		    x_close_date	  IN OUT NOCOPY  DATE,
		    x_acceptance_due_date IN OUT NOCOPY  DATE);

END;

 

/

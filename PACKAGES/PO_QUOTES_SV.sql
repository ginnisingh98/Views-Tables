--------------------------------------------------------
--  DDL for Package PO_QUOTES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_QUOTES_SV" AUTHID CURRENT_USER as
/* $Header: POXSOQUS.pls 115.2 2002/11/25 22:38:50 sbull ship $ */
/*===========================================================================
  PACKAGE NAME:		PO_QUOTES_SV

  DESCRIPTION:		This package contains the Quotation specific
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  PROCEDURE NAMES:	val_header_delete()
			val_line_delete()
			val_reply()
			get_quote_status()
			get_from_rfq_defaults()
			get_approved_status()
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	val_header_delete()

  DESCRIPTION:		This procedure verifies that the document selected
			for deletion is not not referenced on a Purchase
			Order line.
			If it is referenced, deletion is prohibited.

  PARAMETERS:		X_po_header_id	  IN		NUMBER
			X_allow_delete	  IN OUT	BOOLEAN

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_header_delete
		(X_po_header_id	  IN		NUMBER);

PROCEDURE val_header_delete
		(X_po_header_id	  IN		NUMBER,
 		 X_allow_delete	  IN OUT	NOCOPY BOOLEAN);

/*===========================================================================
  PROCEDURE NAME:	val_line_delete()

  DESCRIPTION:		This procedure verifies that the line selected for
			deletion is not used in autosource rules, or is
			not referenced on a requisition or Purchase Order line.
			If it is used or referenced, deletion is prohibited.

  PARAMETERS:		X_po_line_id	  IN		NUMBER
			X_po_line_num	  IN		NUMBER
			X_po_header_id	  IN		NUMBER
			X_allow_delete	  IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		05-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_line_delete
		(X_po_line_id	  IN		NUMBER,
		 X_po_line_num	  IN		NUMBER,
		 X_po_header_id	  IN		NUMBER);

PROCEDURE val_line_delete
		(X_po_line_id	  IN		NUMBER,
		 X_po_line_num	  IN		NUMBER,
		 X_po_header_id	  IN		NUMBER,
 		 X_allow_delete	  IN OUT	NOCOPY VARCHAR2);

/*===========================================================================
  FUNCTION NAME:	val_reply()

  DESCRIPTION:		When entering a Quotation, if the user specifies an
			RFQ number for reference, this function checks to see
			if there is already a recorded quote for the selected
			supplier/site combination, and if there is one already
			existing, warns the user of it's existance.

  PARAMETERS:		X_from_header_id	IN	NUMBER
			X_vendor_id		IN	NUMBER
			X_vendor_site_id	IN	NUMBER

  RETURN VALUE:		BOOLEAN

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_reply
	(X_from_header_id	IN	NUMBER,
	 X_vendor_id		IN	NUMBER,
	 X_vendor_site_id	IN	NUMBER);

FUNCTION val_reply
	(X_from_header_id	IN	NUMBER,
	 X_vendor_id		IN	NUMBER,
	 X_vendor_site_id	IN	NUMBER) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_quote_status()

  DESCRIPTION:		This procedure verifies the quotation is not referenced
			on a purchase order (line), or used in autosource rules
			This is used when deciding if the supplier field is
			updateable or not.

  PARAMETERS:		X_po_header_id  	IN	NUMBER,
			X_quote_referenced	IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	08-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_get_quote_status
		(X_po_header_id  	IN	NUMBER);

PROCEDURE get_quote_status
		(X_po_header_id  	IN	NUMBER,
		 X_quote_referenced	IN OUT	NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	get_from_rfq_defaults()

  DESCRIPTION:		This procedure gets the following from RFQ number
			field defaults:
				o rfq_close_date
				o type_lookup_code
				o approval_required_flag

  PARAMETERS:		X_po_header_id		  IN		NUMBER
			X_rfq_close_date	  IN OUT	DATE
			X_from_type_lookup_code   IN OUT	VARCHAR2
			X_approval_required_flag  IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:		Kevin suggested defaulting more information when the user
			enters an RFQ number for reference.  I am not sure which
			other fields should be defaulted based on the RFQ number.
			Besides, that is what COPY function (autocreate) is for.
			Should we encompass that functionality in Entry form?
			For now, I am only including the fields we defaulted
			in Release 10.

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/
PROCEDURE test_get_from_rfq_defaults
	(X_from_header_id	   IN		NUMBER);

PROCEDURE get_from_rfq_defaults
	(X_from_header_id	   IN		NUMBER,
 	 X_rfq_close_date	   IN OUT	NOCOPY DATE,
	 X_from_type_lookup_code   IN OUT	NOCOPY VARCHAR2,
	 X_approval_required_flag  IN OUT	NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	get_approval_status()

  DESCRIPTION:		This procedure checks if a particular shipment line
			has been approved.

  PARAMETERS:		X_line_location_id	  IN		NUMBER
			X_approval_status  	  IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		03-JAN-96	MSNYDER
===========================================================================*/
PROCEDURE get_approval_status
		(X_line_location_id	  IN		NUMBER,
 		 X_approval_status	  IN OUT	NOCOPY VARCHAR2);

END PO_QUOTES_SV;

 

/

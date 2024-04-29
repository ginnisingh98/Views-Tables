--------------------------------------------------------
--  DDL for Package PO_RFQS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RFQS_SV" AUTHID CURRENT_USER as
/* $Header: POXSORFS.pls 120.0.12000000.3 2007/10/11 13:54:49 ppadilam ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_RFQS_SV

  DESCRIPTION:		This package contains the RFQ specific
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  PROCEDURE NAMES:	val_header_delete()
			val_line_delete()
			get_vendor_count()
			val_vendor_site()
			val_vendor_update()
===========================================================================*/


/*===========================================================================
  PROCEDURE NAME:	val_header_delete()

  DESCRIPTION:		This function verifies that the header selected for
			deletion has not been printed and is not referenced on
			a quotation.  If it has been printed or is referenced,
			deletion is prohibited.

  PARAMETERS:		X_po_header_id	  IN		NUMBER
			X_allow_delete	  IN OUT	BOOLEAN

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		05-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_header_delete(X_po_header_id	  IN	NUMBER);

PROCEDURE val_header_delete
		(X_po_header_id	  IN		NUMBER,
		 X_allow_delete	  IN OUT NOCOPY    	BOOLEAN);


/*===========================================================================
  PROCEDURE NAME:	val_line_delete()

  DESCRIPTION:		This procedure verifies that the line selected for
			deletion has not been autocreated to a quotation.
			If it has been autocreated, deletion is prohibited.

  PARAMETERS:		X_po_header_id		IN	NUMBER
			X_po_line_id		IN	NUMBER
			X_allow_delete	  	IN    	VARCHAR2

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		05-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_line_delete
		(X_po_line_id	  IN	NUMBER,
		 X_po_header_id	  IN	NUMBER);

PROCEDURE val_line_delete
		(X_po_line_id	  IN		NUMBER,
		 X_po_header_id	  IN		NUMBER,
		 X_allow_delete	  IN OUT NOCOPY    	VARCHAR2);

/*===========================================================================
  FUNCTION NAME:	get_vendor_count()

  DESCRIPTION:		This function gets the number of vendors included
			in a specific vendor list.

  PARAMETERS:		X_vendor_list_header_id IN	NUMBER

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		13-NOV-95	MSNYDER
===========================================================================*/

FUNCTION get_vendor_count
		(X_vendor_list_header_id  IN	NUMBER) RETURN NUMBER;

/*===========================================================================
  FUNCTION NAME:	val_vendor_site()

  DESCRIPTION:		This function verifies that a particular vendor/site
			combination is unique to an RFQ.

  PARAMETERS:		X_po_header_id		IN	NUMBER
			X_vendor_id		IN	NUMBER
			X_vendor_site_id	IN	NUMBER
			X_row_id		IN	NUMBER

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		15-NOV-95	MSNYDER
===========================================================================*/

FUNCTION val_vendor_site
		(X_po_header_id		IN	NUMBER,
		 X_vendor_id		IN	NUMBER,
		 X_vendor_site_id	IN	NUMBER,
		 X_row_id		IN	VARCHAR2) RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_vendor_update()

  DESCRIPTION:		This function performs a verification check when
			vendor information is changed.  If the vendor
			is already referenced on a quote, the change is
			not permitted.

  PARAMETERS:		X_po_header_id		IN	NUMBER
			X_vendor_id		IN	NUMBER
			X_vendor_site_id	IN	NUMBER
			X_row_id		IN	NUMBER

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		15-NOV-95	MSNYDER
===========================================================================*/

FUNCTION val_vendor_update
		(X_po_header_id		IN	NUMBER,
		 X_vendor_id		IN	NUMBER,
		 X_vendor_site_id	IN	NUMBER) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	copy_vendor_list_to_rfq()

  DESCRIPTION:		This procedure inserts the vendors on a particular
			vendor list into the PO_RFQ_VENDORS table.

  PARAMETERS:		X_row_id		IN OUT	VARCHAR2,
			X_po_header_id		IN OUT	NUMBER,
			X_max_sequence_num	IN	NUMBER,
			X_last_update_date	IN	DATE,
			X_last_updated_by	IN	NUMBER,
			X_last_update_login	IN	NUMBER,
			X_creation_date		IN	DATE,
			X_created_by		IN	NUMBER,
			X_list_header_id	IN	NUMBER

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		15-DEC-95	MSNYDER
===========================================================================*/
PROCEDURE copy_vendor_list_to_rfq
				(X_rowid		IN OUT	NOCOPY VARCHAR2,
			  	 X_po_header_id		IN OUT	NOCOPY NUMBER,
				 X_max_sequence_num	IN	NUMBER,
				 X_last_update_date	IN	DATE,
				 X_last_updated_by	IN	NUMBER,
				 X_last_update_login	IN	NUMBER,
				 X_creation_date	IN	DATE,
				 X_created_by		IN	NUMBER,
				 X_list_header_id	IN	NUMBER,
				 x_vendors_hold IN OUT NOCOPY VARCHAR2);   --  Bug # 6161855

END PO_RFQS_SV;

 

/

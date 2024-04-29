--------------------------------------------------------
--  DDL for Package PO_VENDOR_CONTACTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDOR_CONTACTS_SV" AUTHID CURRENT_USER AS
/* $Header: POXVDVCS.pls 120.0.12010000.2 2012/02/16 09:34:19 rkandima ship $*/

/*===========================================================================
  FUNCTION NAME:	val_vendor_contact()

  DESCRIPTION:		This function checks whether a given Supplier
			Contact is still valid.


  PARAMETERS:		p_vendor_contact_id IN NUMBER
                        p_vendor_site_id IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Changed to	14-AUG-1995	LBROADBE
			Function
===========================================================================*/
FUNCTION  val_vendor_contact(p_vendor_contact_id IN NUMBER,
                             p_vendor_site_id in NUMBER) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_vendor_contact()

  DESCRIPTION:
	 o DEF - If there is only one active contact for this site and the contact name
		 is not filled in yet, default the contact name.
  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_vendor_contact(X_vendor_site_id IN NUMBER, X_vendor_contact_id IN OUT NOCOPY number,
                             X_vendor_contact_name IN OUT NOCOPY varchar2 );


/*===========================================================================
  PROCEDURE NAME:	get_contact_info()

  DESCRIPTION:		Obtain the name of the vendor contact and phone
		 	using the vendor contact id.

  PARAMETERS:		x_vendor_contact_id	IN	NUMBER
			x_vendor_contact_name	OUT     VARCHAR2
			x_vendor_phone		OUT 	VARCHAR2

  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		10/21		Ramana Mulpury
===========================================================================*/

PROCEDURE get_contact_info  (x_vendor_contact_id 	IN 	NUMBER,
                             x_vendor_site_id           IN      NUMBER,
			     x_vendor_contact_name	IN OUT NOCOPY 	VARCHAR2,
			     x_vendor_phone		IN OUT NOCOPY 	VARCHAR2);

FUNCTION get_vendor_contact_id                             -- <Bug 3692519>
(    p_po_header_id        IN NUMBER
) RETURN NUMBER;

END PO_VENDOR_CONTACTS_SV;

/

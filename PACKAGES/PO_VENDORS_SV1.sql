--------------------------------------------------------
--  DDL for Package PO_VENDORS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIVDS.pls 115.2 2002/11/23 02:50:14 sbull ship $ */

/*==================================================================
  FUNCTION NAME:  val_vendor_info()

  DESCRIPTION:    This API is used to validate vendor info.
                  1). If only X_vendor_id is supplied, the remaining
                      two parameter are NULL.
                      API will validate vendor_id only.
                  2). If X_vendor_id and X_vendor_site_id are
                      specified, do step (1) and validation vendor_site
                       as well.
                  3). If all the parameters are specified, do step
                      (1) and (2) and validate vendor contact.

  PARAMETERS:	  X_vendor_id          IN NUMBER
                  X_vendor_site_type   IN VARCHAR2
                  X_vendor_site_id     IN NUMBER
                  X_vendor_contact_id  IN NUMBER
                  X_error_code         IN OUT VARCHAR2

  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API returns TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan
                  Modified      14-MAR-1996     Daisy Yu

=======================================================================*/
FUNCTION val_vendor_info(X_vendor_id         IN  NUMBER,
			 X_vendor_site_type  IN  VARCHAR2,
			 X_vendor_site_id    IN  NUMBER,
			 X_vendor_contact_id IN  NUMBER,
			 X_error_code        IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  derive_vendor_id()

  DESCRIPTION:    API used to derive vendor_id with vendor_name and/or
                  vendor_num as input arameters.

  PARAMETERS:	  X_vendor_name     IN VARCHAR2,
                  X_vendor_num      IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      API returns vendor_id (NUMBER) if found, NULL
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      12-MAR-1996     Mike Schifano

=======================================================================*/
FUNCTION derive_vendor_id(X_vendor_name IN VARCHAR2,
                          X_vendor_num  IN VARCHAR2)
                          return NUMBER;


END PO_VENDORS_SV1;

 

/

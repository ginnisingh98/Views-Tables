--------------------------------------------------------
--  DDL for Package PO_VENDOR_SITES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDOR_SITES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIVSS.pls 115.0 99/07/17 01:52:05 porting ship $ */

/*==================================================================
  FUNCTION NAME:  derive_vendor_site_id()

  DESCRIPTION:    API used to derive vendor_site_id with vendor_site_code
                  and vendor_id as input parameters.

  PARAMETERS:	  X_vendor_id         IN NUMBER,
                  X_vendor_site_code  IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      API returns vendor_site_id (NUMBER) if found,
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      12-MAR-1996     Daisy Yu

=======================================================================*/

FUNCTION derive_vendor_site_id(X_vendor_id        IN NUMBER,
                               X_vendor_site_code IN VARCHAR2) return NUMBER;

END PO_VENDOR_SITES_SV1;

 

/

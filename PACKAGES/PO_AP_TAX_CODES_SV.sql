--------------------------------------------------------
--  DDL for Package PO_AP_TAX_CODES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_TAX_CODES_SV" AUTHID CURRENT_USER AS
/* $Header: POXPITXS.pls 115.0 99/07/17 01:51:11 porting ship $ */

/*==================================================================
  FUNCTION NAME:  val_tax_name()

  DESCRIPTION:    This API is used to validate x_tax_name specified
                  is valid and active.

  PARAMETERS:	  x_tax_name  IN VARCHAR2

  DESIGN
  REFERENCES:	  832valapl.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_tax_name(x_tax_name IN VARCHAR2) RETURN BOOLEAN;

END PO_AP_TAX_CODES_SV;

 

/

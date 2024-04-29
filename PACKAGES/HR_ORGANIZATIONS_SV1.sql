--------------------------------------------------------
--  DDL for Package HR_ORGANIZATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATIONS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIOGS.pls 115.0 99/07/17 01:49:30 porting ship $ */

/*==================================================================
  FUNCTION NAME:  val_inv_organization_id()

  DESCRIPTION:    This API is used to validate x_inv_organization_id
                  specified is valid and active.

  PARAMETERS:	  x_inv_organization_id  IN NUMBER

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
 FUNCTION val_inv_organization_id(x_inv_organization_id IN NUMBER)
 RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  derive_organization_id()

  DESCRIPTION:    This API is used to derive x_organization_code
                  given organization_code(inventory org) as an
                  input parameter. This API will not check to see
                  if the inventory organization is active or not.

  PARAMETERS:	  x_organization_code  IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      return organization_id (NUMBER) if found;
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION derive_organization_id(X_organization_code IN VARCHAR2)
                             return NUMBER;

END HR_ORGANIZATIONS_SV1;

 

/

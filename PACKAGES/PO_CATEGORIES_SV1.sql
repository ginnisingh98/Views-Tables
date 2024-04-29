--------------------------------------------------------
--  DDL for Package PO_CATEGORIES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CATEGORIES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPICTS.pls 120.0.12000000.1 2007/07/27 08:33:33 grohit noship $ */

/*==================================================================
  FUNCTION NAME:  val_item_category_id()

  DESCRIPTION:    This API is used to validate x_category_id specified
                  is valid and active based on item_id and org_id
                  provided from input parameter.

  PARAMETERS:	  x_category_id      IN NUMBER,
                  x_item_id          IN NUMBER,
                  x_organization_id  IN NUMBER

  DESIGN
  REFERENCES:	  832valapl.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise;

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_item_category_id(x_category_id      IN NUMBER,
                               x_item_id          IN NUMBER,
                               x_organization_id  IN NUMBER) RETURN BOOLEAN;


/*==================================================================
  FUNCTION NAME:  derive_category_id()

  DESCRIPTION:    This API is used to derive x_category_id
                  This API will NOT check if the item category is active
                  or not.

  PARAMETERS:	  x_category     IN VARCHAR2


  DESIGN
  REFERENCES:	  832dvapl.doc

  ALGORITHM:      Returns category_id (NUMBER) if found; NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION derive_category_id(X_category IN VARCHAR2) return NUMBER;

/*==================================================================
  FUNCTION NAME:  get_default_purch_category_id()

  DESCRIPTION:    This API can be used to get the default category id
                  for purchasing default category set.

  PARAMETERS:


  DESIGN
  REFERENCES:	  832dfapi.doc

  ALGORITHM:      Returns category_id (NUMBER) if found; NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      12-MAR-1996     Daisy Yu

=======================================================================*/
FUNCTION  get_default_purch_category_id RETURN NUMBER;

/*==================================================================
  FUNCTION NAME:  val_item_category_id()

  DESCRIPTION:    This API is used to validate x_category_id specified
                  is valid and active.

  PARAMETERS:     x_category_id      IN NUMBER,

  DESIGN
  REFERENCES:     832valapl.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise;

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       19-FEB-1996     SODAYAR


=======================================================================*/
 FUNCTION val_category_id (X_category_id  IN NUMBER) RETURN boolean;

END PO_CATEGORIES_SV1;

 

/

--------------------------------------------------------
--  DDL for Package PO_ITEMS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ITEMS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPISIS.pls 120.0.12000000.1 2007/01/16 23:04:39 appldev ship $ */

/*==================================================================
  FUNCTION NAME:  val_item_id()

  DESCRIPTION:    This API is used to validate x_item_id specified
                  is valid and active.

  PARAMETERS:	  x_item_id                  IN NUMBER,
                  x_organization_id          IN NUMBER,
                  x_outside_operation_flag   IN VARCAHR2
  DESIGN
  REFERENCES:	  832vlapl.doc

  ALGORITHM:      API returns TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_item_id(x_item_id                  IN NUMBER,
                      x_organization_id          IN NUMBER,
                      x_outside_operation_flag   IN VARCHAR2) RETURN BOOLEAN;


/*==================================================================
  FUNCTION NAME:  derive_item_id()

  DESCRIPTION:    This API is used to derive inventory_item_id
                  either
                  1) Given item_number(segment values - flex
                     code = 'MSTK') and organization_id as
                     input parameters.
                  2) If item_number is not specified, it will try to
                     derive inventory_item_id using X_vendor_id and
                     X_vendor_product_num specified in the input
                     parameters.
                  This API will not check if the item is active.

  PARAMETERS:	  x_item_number          IN VARCHAR2,
                  X_vendor_product_num   IN VARCHAR2,
                  X_vendor_id            IN NUMBER,
                  X_organization_id      IN VARCHAR2,
                  X_error_code           IN OUT VARCHAR2

  DESIGN
  REFERENCES:	  832dvapl.doc

  ALGORITHM:      API returns item_id (NUMBER) if validation succeeds,
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR
		  Modified      12-MAR-1996     DXYU

=======================================================================*/
 FUNCTION derive_item_id(X_item_number          IN VARCHAR2,
                         X_vendor_product_num   IN VARCHAR2,
                         X_vendor_id            IN NUMBER,
                         X_organization_id      IN VARCHAR2,
                         X_error_code           IN OUT NOCOPY VARCHAR2)
 return NUMBER;

END PO_ITEMS_SV1;

 

/

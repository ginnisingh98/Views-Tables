--------------------------------------------------------
--  DDL for Package MTL_ITEM_REVISIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ITEM_REVISIONS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIIRS.pls 120.0.12000000.1 2007/07/27 08:32:05 grohit noship $ */

/*==================================================================
  FUNCTION NAME:  val_item_revision()

  DESCRIPTION:    This API is used to validate x_item_revision specified
                  is valid and active.

  PARAMETERS:	  x_item_revision      IN VARCHAR2,
                  x_inventory_item_id  IN NUMBER,
                  x_organization_id    IN NUMBER

  DESIGN
  REFERENCES:	  832valapl.doc

  ALGORITHM:      API will returnTRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_item_revision(x_item_revision      IN VARCHAR2,
                            x_inventory_item_id  IN NUMBER,
                            x_organization_id    IN NUMBER)
 RETURN BOOLEAN;

END MTL_ITEM_REVISIONS_SV1;

 

/

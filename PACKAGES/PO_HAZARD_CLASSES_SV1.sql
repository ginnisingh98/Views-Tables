--------------------------------------------------------
--  DDL for Package PO_HAZARD_CLASSES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HAZARD_CLASSES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIHCS.pls 120.0.12000000.1 2007/07/27 09:07:12 grohit noship $ */

/*==================================================================
  FUNCTION NAME:  val_hazard_class_id()

  DESCRIPTION:    This API is used to validate x_hazard_class_id
                  specified is valid and active.

  PARAMETERS:	  x_hazard_class_id  IN NUMBER

  DESIGN
  REFERENCES:	  832vlapl.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_hazard_class_id(x_hazard_class_id  IN NUMBER) RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  derive_hazard_class_id()

  DESCRIPTION:    This API is used to derive x_hazard_class with
                  hazard_class as an input parameter.

  PARAMETERS:	  x_hazard_class IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      API will return hazard_class_id(NUMBER) if found;
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION derive_hazard_class_id(X_hazard_class  IN VARCHAR2)
                             return NUMBER;

END PO_HAZARD_CLASSES_SV1;

 

/

--------------------------------------------------------
--  DDL for Package PO_LINE_TYPES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_TYPES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPILTS.pls 120.0.12000000.1 2007/07/27 08:34:26 grohit noship $ */

/*==================================================================
  FUNCTION NAME:  val_line_type_id()

  DESCRIPTION:    This API is used to validate x_line_type_id specified
                  is valid and active.

  PARAMETERS:	  x_line_type_id  IN NUMBER

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
 FUNCTION val_line_type_id(x_line_type_id  IN NUMBER) RETURN BOOLEAN;


/*==================================================================
  FUNCTION NAME:  derive_line_type_id()

  DESCRIPTION:    This API is used to derive x_line_type specified
                  is valid and active.

  PARAMETERS:	  x_line_type  IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapl.doc

  ALGORITHM:      API will return line_type_id (NUMBER) if found,
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION derive_line_type_id(X_line_type IN VARCHAR2) return NUMBER;

END PO_LINE_TYPES_SV1;

 

/

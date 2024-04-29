--------------------------------------------------------
--  DDL for Package PO_UN_NUMBERS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UN_NUMBERS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIUNS.pls 120.0.12000000.1 2007/07/27 08:35:58 grohit noship $ */

/*==================================================================
  FUNCTION NAME:  val_un_number_id()

  DESCRIPTION:    This API is used to validate x_un_number_id specified
                  is valid and active.

  PARAMETERS:	  x_un_number_id  IN NUMBER

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
 FUNCTION val_un_number_id(x_un_number_id IN NUMBER) RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  derive_un_number_id()

  DESCRIPTION:    This API is used to derive un_number_id given
                  un_number as input parameter.

  PARAMETERS:	  x_un_number  IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapl.doc

  ALGORITHM:      API return un_number_id (NUMBER) if found, NULL
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION  derive_un_number_id(X_un_number IN VARCHAR2)
                                   return NUMBER;

END PO_UN_NUMBERS_SV1;

 

/

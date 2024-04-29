--------------------------------------------------------
--  DDL for Package PO_DAILY_CONVERSION_TYPES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DAILY_CONVERSION_TYPES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIRTS.pls 120.0.12010000.1 2008/09/18 12:20:48 appldev noship $ */

/*==================================================================
  FUNCTION NAME:  val_rate_type_code()

  DESCRIPTION:    This API is used to validate rate_type and make
                  sure it is valid in gl_daily_conversion_types_v table.

  PARAMETERS:	  x_rate_type_code       IN VARCHAR2


  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan
		  Modified      13-MAR-1996     Daisy Yu

=======================================================================*/
 FUNCTION val_rate_type_code(x_rate_type_code  IN VARCHAR2)
 RETURN BOOLEAN;


/*==================================================================
  FUNCTION NAME:  derive_rate_type_code()

  DESCRIPTION:    This API is used to derive rate_type_code with
                  rate_type as input parameter.

  PARAMETERS:     x_rate_type   IN VARCHAR2

  DESIGN
  REFERENCES:     832dvapi.dd

  ALGORITHM:      API returns conversion_type (VARCHAR2) if found;
                  NULL otherwise.
  NOTES:

  OPEN ISSUES:

  CHANGE HISTORY:         Created       03-Mar-1996     Rajan Odayar
                          Modified      12-MAR-1996     Daisy Yu

=======================================================================*/

FUNCTION derive_rate_type_code(X_rate_type  IN VARCHAR2) return VARCHAR2;

END PO_DAILY_CONVERSION_TYPES_SV1;

/

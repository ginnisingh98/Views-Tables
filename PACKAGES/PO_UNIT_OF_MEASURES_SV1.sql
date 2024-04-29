--------------------------------------------------------
--  DDL for Package PO_UNIT_OF_MEASURES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UNIT_OF_MEASURES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIUMS.pls 120.0.12000000.1 2007/07/27 08:30:23 grohit noship $ */

/*==================================================================
  FUNCTION NAME:   val_unit_of_measure()

  DESCRIPTION:     This API is used to validate x_uom_code or
                   X_unit_of_measure specified
                   is valid and active.

  PARAMETERS:	   x_uom_code          IN VARCHAR2
		   x_unit_of_measure   IN VARCHAR2

  DESIGN
  REFERENCES:	   832vlapl.doc

  ALGORITHM:       API returns TRUE if validation succeeds, FALSE
                   otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU
		  Modified	29-APR-96	KKCHAN


=======================================================================*/
FUNCTION val_unit_of_measure(x_unit_of_measure IN VARCHAR2,
			     x_uom_code  IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================
  FUNCTION NAME:	val_item_unit_of_measure()

  DESCRIPTION:		This API is used to validate x_item_unit_of_measure
                        specified is valid and active.

  PARAMETERS:		x_item_unit_of_measure IN VARCHAR2,
                        x_item_id          IN NUMBER,
                        x_organization_id  IN NUMBER


  DESIGN REFERENCES:    832vlapl.doc

  ALGORITHM:            API returns TRUE if validation succeeds, FALSE
                        otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE HISTORY:	Created		19-FEB-1996	DXYU
			Modified	07-Jun-1996	KKCHAN
				* changed API name to val_item_unit_of_measure

=======================================================================*/

FUNCTION val_item_unit_of_measure(x_item_unit_of_measure IN VARCHAR2,
                           x_item_id          IN NUMBER,
                           x_organization_id  IN NUMBER ) RETURN BOOLEAN;


/*======================================================================
  FUNCTION NAME:	derive_unit_of_measure()

  DESCRIPTION:		This API is used to derive the unit_of_measure
                        given the uom_code as an input parameter.

  PARAMETERS:		x_uom_code   IN VARCHAR2


  DESIGN REFERENCES:    832dvapi.dd

  ALGORITHM:            API returns unit_of_measure (VARCHAR2) if found,
                        NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE HISTORY:	Created		19-FEB-1996	SODAYAR

=======================================================================*/
FUNCTION derive_unit_of_measure(X_uom_code IN VARCHAR2)
RETURN VARCHAR2;

END PO_UNIT_OF_MEASURES_SV1;

 

/

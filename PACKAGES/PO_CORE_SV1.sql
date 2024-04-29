--------------------------------------------------------
--  DDL for Package PO_CORE_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CORE_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPICOS.pls 120.1 2006/04/20 11:31:42 bao noship $ */

/*==================================================================
  FUNCTION NAME:  val_effective_date()

  DESCRIPTION:    This API is used to validate if x_effective_date
                  is within the range of x_start_date and X_end_date

  PARAMETERS:	  x_effective_date  IN DATE,
                  x_po_header_id    IN NUMBER

  DESIGN
  REFERENCES:	  832vlapl.doc

  ALGORITHM:      API return TRUE if validation succeeds; FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	22-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_effective_date(x_effective_date  IN DATE,
                             x_po_header_id    IN NUMBER)
 RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  val_numeric_value()

  DESCRIPTION:    This API is used to validate if x_value is a numeric
                  value

  PARAMETERS:	  x_value    IN VARCHAR2

  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API return TRUE if validation succeeds; FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	22-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION val_numeric_value(x_value  IN VARCHAR2) RETURN BOOLEAN;


/*==================================================================
  FUNCTION NAME:  val_start_and_end_date()

  DESCRIPTION:    This API is used to validate if x_start_date <=
                  x_end_date;

  PARAMETERS:	  x_start_date    IN DATE
                  x_end_date      IN DATE
  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	22-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION val_start_and_end_date(X_start_date  IN DATE,
			        X_end_date    IN DATE)
RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  val_flag_value()

  DESCRIPTION:    This API is used to validate if x_flag_value is valid
                  (the valid flag value is 'Y' or 'N')

  PARAMETERS:	  x_flag_value    IN VARCHAR2

  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds; FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	22-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION val_flag_value(x_flag_value  IN VARCHAR2) RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  default_po_unique_identifier()

  DESCRIPTION:    This API is used to obtain the system-generated
                  numbers for Oracle Purchasing tables which
                  requires special sequencing (defined in
                  po_unique_identifier_control)

                  It has one input parameter which specifies the table
                  which requires the sequence number. Valid table_name
                  are:
                       PO_HEADERS
                       PO_REQUISTION_HEADERS
                       PO_VENDORS
                       RCV_SHIPMENT_HEADERS
                       PO_HEADERS_QUOTE
                       PO_HEADERS_RFQ

  PARAMETERS:	  x_table_name   IN VARCHAR2


  DESIGN
  REFERENCES:	  832dfapi.doc

  ALGORITHM:      System generated number for the specified table
                  (NUMBER) if found; NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
                  Modified      12-MAR-1996     Daisy Yu

=======================================================================*/
FUNCTION default_po_unique_identifier(X_table_name  IN VARCHAR2)
 RETURN VARCHAR2;

-- bug5174177 START
FUNCTION  default_po_unique_identifier
( p_table_name IN VARCHAR2,
  p_org_id     IN NUMBER
) RETURN VARCHAR2;
-- bug5174177 END

/*==================================================================
  FUNCTION NAME:   val_max_and_min_qty()

  DESCRIPTION:     This API is used to validate if minimum qty is
                   less than maximum order qty.

  PARAMETERS:	   x_qty1     IN NUMBER,
                   x_qty2     IN NUMBER
  DESIGN
  REFERENCES:	   832vlapl.doc

  ALGORITHM:       API returns TRUE if successful, FALSE otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
FUNCTION val_max_and_min_qty(x_qty1  IN NUMBER,
                             x_qty2  IN NUMBER) RETURN BOOLEAN;

/*======================================================================
  FUNCTION NAME:	val_discount()

  DESCRIPTION:		This API is used to validate x_discount is within
                        0 and 100 range.

  PARAMETERS:		x_discount IN NUMBER


  DESIGN REFERENCES:    832vlapl.doc

  ALGORITHM:            Return TRUE if successful, FALSE otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE HISTORY:	Created		19-FEB-1996	DXYU

=======================================================================*/

FUNCTION val_discount(x_discount  IN NUMBER) RETURN BOOLEAN;

END PO_CORE_SV1;

 

/

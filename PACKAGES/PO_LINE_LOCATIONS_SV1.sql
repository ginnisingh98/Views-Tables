--------------------------------------------------------
--  DDL for Package PO_LINE_LOCATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_LOCATIONS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPILLS.pls 120.0.12010000.1 2008/09/18 12:20:47 appldev noship $ */


/*==================================================================
  FUNCTION NAME:  val_shipment_num()

  DESCRIPTION:    This API is used to validate the uniqueness of
                  shipment num in po_lines table.

  PARAMETERS:	  x_shipment_num  IN NUMBER,
                  x_shipment_type IN VARCHAR2,
                  x_po_header_id  IN NUMBER,
                  x_po_line_id    IN NUMBER,
                  x_rowid         IN VARCHAR2


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
 FUNCTION val_shipment_num(x_shipment_num  IN NUMBER,
                           x_shipment_type IN VARCHAR2,
                           x_po_header_id  IN NUMBER,
                           x_po_line_id    IN NUMBER,
                           x_rowid         IN VARCHAR2) RETURN BOOLEAN;


/*======================================================================
  FUNCTION NAME:	val_shipment_type()

  DESCRIPTION:		This API is used to validate shipment type and
                        make sure it is valid and active.

  PARAMETERS:		x_shipmetn_type  IN VARCHAR2

  DESIGN REFERENCES:    832vlapl.doc

  ALGORITHM:            API returns TRUE if validation succeeds, FALSE
                        otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE HISTORY:	Created		19-FEB-1996	DXYU

=======================================================================*/
 FUNCTION val_shipment_type(x_shipment_type  IN VARCHAR2,
                            x_lookup_code    IN VARCHAR2) RETURN BOOLEAN;


/*======================================================================
  FUNCTION NAME:  derive_line_location_id()

  DESCRIPTION:	  This API is used to derive lin_locaiton_id.

  PARAMETERS:	  x_po_header_id   IN NUMBER,
                  x_po_line_id     IN NUMBER

  DESIGN REFERENCES:    832dvapi.doc

  ALGORITHM:      API returns line_location_id (NUMBER) if found,
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE HISTORY:	Created		19-FEB-1996	 SODAYAR

=======================================================================*/
 FUNCTION derive_line_location_id(X_po_header_id IN NUMBER,
                                  X_po_line_id   IN NUMBER,
                                  X_shipment_num IN NUMBER) return NUMBER;

/*==================================================================
  FUNCTION NAME:  derive_location_id()

  DESCRIPTION:    This API is used to derive location_id given
                  location_code and location_usage as the input
                  parameter.

  PARAMETERS:	  X_location_code     IN VARCHAR2
                  X_location_usage    IN VARCHAR2

  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      API returns location_id (NUMBER) if found, NULL
                  otherwise.

  NOTES:          Valid value for X_locaiton_usage are :
                   'SHIP_TO'
                   'BILL_TO'
                   'RECEIVING'
                   'OFFICE'

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan
		  modified      13-MAR-1996     Daisy Yu

=======================================================================*/

FUNCTION derive_location_id(X_location_code  IN VARCHAR2,
                            X_location_usage IN VARCHAR2) return NUMBER;

/*==================================================================
  FUNCTION NAME:  val_location_id()

  DESCRIPTION:    This API is used to validate whether the location
                  specified in x_location_id is an active and valid
                  location for a specific vendor site. It also checks
                  whether the location is the correct bill_to/ship_to/
                  receiving/office site (depend on x_location_usage)

  PARAMETERS:	  x_location_id       IN NUMBER
                  x_location_type     IN VARCHAR2

  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API returns TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:           Valid value for X_locaiton_type are :
                   'SHIP_TO'
                   'BILL_TO'
                   'RECEIVING'
                   'OFFICE'

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan


=======================================================================*/
 FUNCTION val_location_id(X_location_id    IN NUMBER,
  		          X_location_type  IN VARCHAR2)
 RETURN BOOLEAN;

END PO_LINE_LOCATIONS_SV1;

/

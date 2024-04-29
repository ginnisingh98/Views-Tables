--------------------------------------------------------
--  DDL for Package RCV_HEADERS_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_HEADERS_INTERFACE_SV" AUTHID CURRENT_USER as
/* $Header: RCVHISVS.pls 120.0.12010000.1 2008/07/24 14:35:45 appldev ship $ */

/*===========================================================================
  PACKAGE NAME:		RCV_HEADERS_INTERFACE_SV

  DESCRIPTION:		Contains procedures used for implementing ASN
                        functionality

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:		    Raj Bhakta

  PROCEDURE/FUNCTION NAMES:
                            derive_shipment_header()
                            default_shipment_header()
                            validate_shipment_header()
                            insert_shipment_header()
                            validate_invoice_amount()

  HISTORY:	 11/01/96    Raj Bhakta Created

===========================================================================*/

/*===========================================================================
 PROCEDURE NAME:    derive_shipment_header()

  DESCRIPTION:      Calls procedures that derive missing information about a
                    shipment header based on information that is provided.

  PARAMETERS:       p_header_record IN OUT RCV_SHIPMENT_HEADER_SV.HeaderRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Raj Bhakta         11/01/96

===============================================================================*/
  PROCEDURE derive_shipment_header
                (p_header_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HeaderRecType);

/*===========================================================================
 PROCEDURE NAME:    derive_ship_to_org_from_rti()

  DESCRIPTION:      Calls procedures that derive ship to organization code
                    from the related transaction interface rows if none was
                    found at the header.  It will also try to use the
                    ship to location code and get an org that way.

  PARAMETERS:       p_header_record IN OUT RCV_SHIPMENT_HEADER_SV.HeaderRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Raj Bhakta         11/01/96

===============================================================================*/
  PROCEDURE derive_ship_to_org_from_rti
                (p_header_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HeaderRecType);


/*===========================================================================
 PROCEDURE NAME:    default_shipment_header()

  DESCRIPTION:      Calls procedures that default missing information about a
                    shipment header

  PARAMETERS:       p_header_record IN OUT RCV_SHIPMENT_HEADER_SV.HeaderRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Raj Bhakta         11/01/96

===============================================================================*/

  PROCEDURE default_shipment_header
                (p_header_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HeaderRecType);

/*===========================================================================
 PROCEDURE NAME:    validate_shipment_header()

  DESCRIPTION:      Calls procedures that validate information about a
                    shipment header based on information that is provided.

  PARAMETERS:       p_header_record IN OUT RCV_SHIPMENT_HEADER_SV.HeaderRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Raj Bhakta         11/01/96

===============================================================================*/

  PROCEDURE validate_shipment_header
                (p_header_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HeaderRecType);

/*===========================================================================
 PROCEDURE NAME:    validate_invoice_amount()

  DESCRIPTION:      Validates the invoice amount for certain business rules and
                    returns error status and error messages based on the success or
                    failure.

  PARAMETERS:       p_inv_rec IN OUT RCV_SHIPMENT_HEADER_SV.HeaderRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Raj Bhakta         11/01/96

===============================================================================*/

  PROCEDURE validate_invoice_amount
                (p_inv_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.InvRecType);

/*===========================================================================
 PROCEDURE NAME:    insert_shipment_header()

  DESCRIPTION:      Calls procedures that creates a shipment header record in the
                    rcv_shipment_header table

  PARAMETERS:       p_header_record in out RCV_SHIPMENT_HEADER_SV.HeaderRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Raj Bhakta         11/01/96

===============================================================================*/
  procedure insert_shipment_header
                (p_header_record in out NOCOPY RCV_SHIPMENT_HEADER_SV.HeaderRecType);

END RCV_HEADERS_INTERFACE_SV;

/

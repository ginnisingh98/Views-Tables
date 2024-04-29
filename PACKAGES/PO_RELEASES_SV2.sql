--------------------------------------------------------
--  DDL for Package PO_RELEASES_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELEASES_SV2" AUTHID CURRENT_USER as
/* $Header: POXPOR2S.pls 115.6 2004/03/24 15:37:02 manram ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_RELEASES_SV2

  DESCRIPTION:		Contains all server side procedures that access the
			PO_RELEASES entity

  CLIENT/SERVER:	SERVER

  LIBRARY NAME		NONE

  OWNER:		KPOWELL

  PROCEDURES/FUNCTIONS:
		        get_po_header_details()
			get_rel_total()
		        get_release_status()

===========================================================================*/

 PROCEDURE get_po_header_details(
		     X_po_header_id IN NUMBER,
		     X_type_lookup_code IN OUT NOCOPY VARCHAR2,
		     X_revision_num IN OUT NOCOPY NUMBER,
		     X_currency_code IN OUT NOCOPY VARCHAR2,
		     X_supplier_id IN OUT NOCOPY NUMBER,
		     X_supplier_name IN OUT NOCOPY VARCHAR2,
		     X_supplier_site_id IN OUT NOCOPY NUMBER,
		     X_supplier_site_name IN OUT NOCOPY VARCHAR2,
                     X_pay_on_code IN OUT NOCOPY VARCHAR2,
                     X_pay_on_dsp IN OUT NOCOPY VARCHAR2,
		     X_ship_to_location_id IN OUT NOCOPY NUMBER,
		     X_ship_to_location_code IN OUT NOCOPY VARCHAR2,
		     X_organization_id IN OUT NOCOPY NUMBER,
		     X_organization_code IN OUT NOCOPY VARCHAR2,
                     x_shipping_control IN OUT NOCOPY VARCHAR2,    -- <INBOUND LOGISITCS FPJ>
		     x_supply_agreement_flag  IN OUT NOCOPY VARCHAR2, --Bug#3514141
		     x_confirming_order_flag  IN OUT NOCOPY VARCHAR2); --Bug#3514141

/*===========================================================================
  FUNCTION NAME:        get_rel_total

  DESCRIPTION:          Gets the release total for the view
			PO_RELEASES_v

  PARAMETERS:           X_release_id        IN     NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       KPOWELL CREATED 11/1
===========================================================================*/
  FUNCTION get_rel_total(X_release_id NUMBER)
           return number;
  -- pragma restrict_references (get_rel_total,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION NAME:	get_release_status

  DESCRIPTION:		gets the auto, cancel, close, hold, frozen,
		       		reserved status of the release
			        for the view po_releases_v.

  PARAMETERS:	        See below.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 10/10

===========================================================================*/
  FUNCTION get_release_status(X_po_release_id NUMBER)
           return VARCHAR2;
  -- pragma restrict_references (get_release_status,WNDS,RNPS,WNPS);


END PO_RELEASES_SV2;

 

/

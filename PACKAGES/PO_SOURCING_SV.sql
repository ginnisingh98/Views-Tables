--------------------------------------------------------
--  DDL for Package PO_SOURCING_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SOURCING_SV" AUTHID CURRENT_USER as
/* $Header: POXSCS4S.pls 115.4 2003/11/12 22:14:38 jskim ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_SOURCING_SV

  DESCRIPTION:		This package contains the server side Supplier Item
			Catalog and Sourcing Application Program Interfaces
			(APIs).

  CLIENT/SERVER:	Server

  OWNER:		Liza Broadbent

  FUNCTION/PROCEDURE:	val_order_pad_line()
			get_approval_status()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	val_order_pad_line()

  DESCRIPTION:		This procedure is called to validate a source document
		 	line when the user adds records to the Order Pad in the
			Supplier-Item Catalog.  It also returns the List Price
			if a predefined item has been specified.



  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Updated		06-APR-1996	LBROADBE
===========================================================================*/
PROCEDURE val_order_pad_line
(
    p_item_id            IN     NUMBER,
    p_category_id        IN     NUMBER,
    p_vendor_id          IN     NUMBER,
    p_vendor_site_id     IN     NUMBER,
    p_vendor_contact_id  IN     NUMBER,
    p_currency_code      IN     VARCHAR2,
    p_ap_terms_id        IN     NUMBER,
    p_fob_lookup_code    IN     VARCHAR2,
    p_ship_via_code      IN     VARCHAR2,
    p_freight_terms_code IN     VARCHAR2,
    p_line_type_id       IN     NUMBER,
    p_unit_of_measure    IN     VARCHAR2,
    p_dest_org_id        IN     NUMBER,
    p_document_type      IN     VARCHAR2,
    p_structure_id       IN     NUMBER,
    p_source_type        IN     VARCHAR2,
    p_display_message    IN     VARCHAR2,
    p_cross_ref_type     IN     VARCHAR2,
    p_instance_org_id    IN     NUMBER,
    p_primary_inv_cost   IN     NUMBER,
    p_purchasing_org_id  IN     NUMBER,                 --< Shared Proc FPJ >
    X_multiple_flag      IN OUT NOCOPY VARCHAR2,
    X_messages_exist     IN OUT NOCOPY BOOLEAN,
    X_message            IN OUT NOCOPY VARCHAR2,
    X_category_val       IN OUT NOCOPY BOOLEAN,
    X_vendor_val         IN OUT NOCOPY BOOLEAN,
    X_vendor_site_val    IN OUT NOCOPY BOOLEAN,
    X_vendor_contact_val IN OUT NOCOPY BOOLEAN,
    X_currency_val       IN OUT NOCOPY BOOLEAN,
    X_ap_terms_val       IN OUT NOCOPY BOOLEAN,
    X_fob_lookup_val     IN OUT NOCOPY BOOLEAN,
    X_ship_via_val       IN OUT NOCOPY BOOLEAN,
    X_freight_terms_val  IN OUT NOCOPY BOOLEAN,
    X_line_type_val      IN OUT NOCOPY BOOLEAN,
    X_unit_of_meas_val   IN OUT NOCOPY BOOLEAN,
    X_list_price         IN OUT NOCOPY NUMBER,
    X_planned_item_flag  IN OUT NOCOPY VARCHAR2,
    X_primary_uom        IN OUT NOCOPY VARCHAR2,
    X_convert_inv_cost   IN OUT NOCOPY NUMBER,
    X_change_price       IN OUT NOCOPY BOOLEAN
);

/*===========================================================================
  FUNCTION NAME:	vendor_sourcing_status()

  DESCRIPTION:		This function returns an approval status for a given
			supplier/item combination based on whether they
			can be found on a current (as of SYSDATE) effective
			sourcing rule.  The function call is appended to the
			queries from the po_negotiated_sources_v and
			po_purchase_history_v views for the Supplier-Item
			Catalog.

  PARAMETERS:		X_item_id	     IN  NUMBER,
			X_vendor_id 	     IN  NUMBER,
			X_vendor_site_id     IN  NUMBER,
			X_organization_id    IN  NUMBER,
			X_autosource_rule_id IN  NUMBER,
			X_assignment_set_id  IN  NUMBER

  RETURN VALUE:		VARCHAR2

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:		This function does not include standard error
			handling as required to be called from a view.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	27-JUN-95	LBROADBE
===========================================================================*/
FUNCTION vendor_sourcing_status(X_item_id		  IN  NUMBER,
			     X_vendor_id 	  IN  NUMBER,
			     X_vendor_site_id	  IN  NUMBER,
			     X_organization_id    IN  NUMBER,
			     X_autosource_rule_id IN  NUMBER,
			     X_assignment_set_id  IN  NUMBER)
RETURN varchar2;

--PRAGMA restrict_references (vendor_sourcing_status,WNDS,RNPS,WNPS);

END PO_SOURCING_SV;

 

/

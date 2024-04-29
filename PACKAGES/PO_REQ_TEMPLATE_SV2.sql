--------------------------------------------------------
--  DDL for Package PO_REQ_TEMPLATE_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_TEMPLATE_SV2" AUTHID CURRENT_USER AS
/* $Header: POXRQT2S.pls 115.5 2003/10/21 20:29:14 nipagarw ship $*/

PROCEDURE get_req_line_info (
	x_rowid				IN	VARCHAR2,
	x_inv_org_id			IN	NUMBER,
	x_item_id			IN OUT	NOCOPY NUMBER,
	x_item_revision			IN OUT NOCOPY  VARCHAR2,
	x_item_description		IN OUT	NOCOPY VARCHAR2,
	x_category_id			IN OUT NOCOPY  NUMBER,
	x_unit_meas_lookup_code		IN OUT	NOCOPY VARCHAR2,
	x_unit_price			IN OUT NOCOPY  NUMBER,
	x_vendor_id			IN OUT NOCOPY  NUMBER,
	x_vendor_site_id		IN OUT NOCOPY  NUMBER,
	x_vendor_contact_id		IN OUT NOCOPY  NUMBER,
	x_vendor_product_code		IN OUT	NOCOPY VARCHAR2,
	x_suggested_buyer_id		IN OUT	NOCOPY NUMBER,
	x_source_type_code		IN OUT NOCOPY  VARCHAR2,
	x_source_organization_id	IN OUT NOCOPY  NUMBER,
	x_source_subinventory		IN OUT NOCOPY  VARCHAR2,
	x_line_type_id			IN OUT NOCOPY  NUMBER,
 	x_rfq_required_flag		IN OUT NOCOPY  VARCHAR2,
	x_vendor_source_context		IN OUT	NOCOPY VARCHAR2,
	x_org_id			IN OUT NOCOPY  NUMBER,
	x_line_type			IN OUT NOCOPY  VARCHAR2,
	x_order_type_lookup_code	IN OUT NOCOPY  VARCHAR2,
	x_source_type			IN OUT NOCOPY  VARCHAR2,
	x_suggested_buyer		IN OUT NOCOPY  VARCHAR2,
	x_vendor_name			IN OUT NOCOPY  VARCHAR2,
	x_vendor_contact		IN OUT NOCOPY  VARCHAR2,
	x_vendor_site			IN OUT NOCOPY  VARCHAR2,
	x_source_organization_name	IN OUT NOCOPY  VARCHAR2,
        x_amount                        IN OUT NOCOPY  NUMBER,  -- <SERVICES FPJ>
	x_negotiated_by_preparer_flag   IN OUT NOCOPY VARCHAR2); --<DBI FPJ>

FUNCTION duplicate_express_name (x_express_name  VARCHAR2)
	RETURN BOOLEAN;

-- iali bug 489705
FUNCTION duplicate_sequence_number (X_express_name	IN  VARCHAR2,
				    X_sequence_num      IN  NUMBER,
				    X_rowid             IN  VARCHAR2)
	RETURN BOOLEAN;

FUNCTION inventory_item_cost (x_inventory_item_id   VARCHAR2,
		              x_organization_id     VARCHAR2)
	RETURN NUMBER;

-- Bug 1006562
FUNCTION primary_unit_of_measure (x_inventory_item_id	IN VARCHAR2,
				  x_organization_id	IN VARCHAR2)
	RETURN VARCHAR2;

PROCEDURE get_order_type (x_line_type_id   		IN	NUMBER,
			  x_order_type_lookup_code	IN OUT NOCOPY  VARCHAR2);

END;

 

/

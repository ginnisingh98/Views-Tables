--------------------------------------------------------
--  DDL for Package PO_REQ_TEMPLATE_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_TEMPLATE_SV3" AUTHID CURRENT_USER AS
/* $Header: POXRQT3S.pls 115.4 2003/10/21 20:33:44 nipagarw ship $*/

PROCEDURE get_po_line_info (
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
	x_po_header_id			IN OUT NOCOPY  NUMBER,
	x_po_line_id			IN OUT NOCOPY  NUMBER,
	x_line_type_id			IN OUT NOCOPY  NUMBER,
	x_org_id			IN OUT NOCOPY  NUMBER,
	x_line_type			IN OUT NOCOPY  VARCHAR2,
	x_order_type_lookup_code	IN OUT	NOCOPY VARCHAR2,
	x_source_type			IN OUT NOCOPY  VARCHAR2,
	x_suggested_buyer		IN OUT NOCOPY  VARCHAR2,
	x_vendor_name			IN OUT NOCOPY  VARCHAR2,
	x_vendor_contact		IN OUT NOCOPY  VARCHAR2,
	x_vendor_site			IN OUT NOCOPY  VARCHAR2,
        x_amount                        IN OUT NOCOPY  NUMBER,  -- <SERVICES FPJ>
	x_negotiated_by_preparer_flag   IN OUT NOCOPY  VARCHAR2); --<DBI FPJ>
END;

 

/

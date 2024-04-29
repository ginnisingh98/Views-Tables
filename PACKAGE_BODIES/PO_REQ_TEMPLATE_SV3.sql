--------------------------------------------------------
--  DDL for Package Body PO_REQ_TEMPLATE_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_TEMPLATE_SV3" AS
/* $Header: POXRQT3B.pls 120.0.12010000.2 2011/11/15 05:29:15 rkandima ship $ */

/*===========================================================================

  PROCEDURE NAME:       get_po_line_info

===========================================================================*/

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
	x_negotiated_by_preparer_flag   IN OUT NOCOPY  VARCHAR2 --<DBI FPJ>
)
IS
BEGIN

    IF (x_rowid IS NOT NULL AND x_inv_org_id IS NOT NULL) THEN

        -- <SERVICES FPJ>
        -- Added the column amount to retrieve its value for
        -- Fixed Price Services lines
    	SELECT  pol.item_id,
       	    	pol.item_revision,
       	    	pol.item_description,
       	    	pol.category_id,
       	    	pol.unit_meas_lookup_code,
       	    	pol.unit_price,
       		poh.vendor_id,
       		poh.vendor_site_id,
       		poh.vendor_contact_id,
       		pol.vendor_product_num,
       		poh.agent_id,
       		'VENDOR',
       		decode(poh.type_lookup_code,
                	'BLANKET', pol.po_header_id, null),
       		decode(poh.type_lookup_code,
                	'BLANKET', pol.po_line_id, null),
       		pol.line_type_id,
		pol.org_id,
	    	plt.line_type,
		plt.order_type_lookup_code,
	    	plc.displayed_field,
	    	po_inq_sv.get_person_name(poh.agent_id),
	    	v.vendor_name,
	    	decode (vc.last_name, NULL, NULL, vc.last_name||', '||vc.first_name),
	    	vs.vendor_site_code,
                pol.amount,
		pol.negotiated_by_preparer_flag --<DBI FPJ>
    	INTO	x_item_id,
		x_item_revision	,
		x_item_description,
		x_category_id,
		x_unit_meas_lookup_code	,
		x_unit_price,
		x_vendor_id,
		x_vendor_site_id,
		x_vendor_contact_id,
		x_vendor_product_code,
		x_suggested_buyer_id,
		x_source_type_code,
		x_po_header_id,
		x_po_line_id,
		x_line_type_id,
		x_org_id,	-- debug: what is this for?
		x_line_type,
		x_order_type_lookup_code,
		x_source_type,
		x_suggested_buyer,
		x_vendor_name,
		x_vendor_contact,
		x_vendor_site,
                x_amount,
		x_negotiated_by_preparer_flag --<DBI FPJ>
	FROM  	po_lookup_codes	plc,
	    	po_line_types	plt,
            	po_vendor_contacts vc,
	    	po_vendor_sites  vs,
	    	po_vendors v,
       		mtl_system_items msi,
       		po_headers poh,
	 	po_lines pol
	WHERE   pol.rowid         = x_rowid
	AND    	poh.po_header_id         = pol.po_header_id
	AND    	nvl(pol.cancel_flag,'N') = 'N'
	AND    	nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
	AND    	pol.item_id              = msi.inventory_item_id (+)
	AND    	nvl(msi.organization_id, x_inv_org_id)
                 	= x_inv_org_id
	AND    	nvl(msi.outside_operation_flag,'N') = 'N'
    	AND     plt.line_type_id = pol.line_type_id
    	AND	plc.lookup_type (+) = 'REQUISITION SOURCE TYPE'
    	AND     plc.lookup_code (+) = 'VENDOR'
    	AND     v.vendor_id (+) = poh.vendor_id
    	AND     vc.vendor_contact_id (+) = poh.vendor_contact_id
        AND     vc.vendor_site_id(+)     = poh.vendor_site_id
    	AND     vs.vendor_site_id (+)    = poh.vendor_site_id;

    END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END;

END PO_REQ_TEMPLATE_SV3;

/

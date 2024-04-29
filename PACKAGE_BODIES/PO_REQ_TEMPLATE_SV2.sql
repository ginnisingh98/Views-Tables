--------------------------------------------------------
--  DDL for Package Body PO_REQ_TEMPLATE_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_TEMPLATE_SV2" AS
/* $Header: POXRQT2B.pls 115.9 2003/10/21 20:47:18 nipagarw ship $*/

/*===========================================================================

  PROCEDURE NAME:       get_req_line_info

===========================================================================*/

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
	x_negotiated_by_preparer_flag   IN OUT NOCOPY  VARCHAR2 --<DBI FPJ>
)
IS
BEGIN

    -- <SERVICES FPJ>
    -- Added the column amount to retrieve its value for
    -- Fixed Price Services lines.
    SELECT  porl.item_id,
       	    porl.item_revision,
       	    porl.item_description,
       	    porl.category_id,
       	    porl.unit_meas_lookup_code,
       	    porl.unit_price,
       	    porl.vendor_id,
       	    porl.vendor_site_id,
       	    porl.vendor_contact_id,
       	    porl.suggested_vendor_product_code,
       	    porl.suggested_buyer_id,
       	    nvl(porl.source_type_code, 'VENDOR'),
       	    porl.source_organization_id,
       	    porl.source_subinventory,
       	    porl.line_type_id,
	    porl.rfq_required_flag,
	    porl.vendor_source_context,
	    porl.org_id,
	    plt.line_type,
	    plt.order_type_lookup_code,
	    plc.displayed_field,
	    po_inq_sv.get_person_name(porl.suggested_buyer_id),
	    nvl(v.vendor_name,porl.suggested_vendor_name),
	    decode (vc.last_name, NULL, porl.suggested_vendor_contact, vc.last_name||', '||vc.first_name),
	    nvl(vs.vendor_site_code,porl.suggested_vendor_location),
	    ood.organization_name,
            porl.amount,
	    porl.negotiated_by_preparer_flag
    INTO    x_item_id,
	    x_item_revision,
	    x_item_description,
	    x_category_id,
	    x_unit_meas_lookup_code,
	    x_unit_price,
	    x_vendor_id,
	    x_vendor_site_id,
	    x_vendor_contact_id,
	    x_vendor_product_code,
	    x_suggested_buyer_id,
	    x_source_type_code,
	    x_source_organization_id,
	    x_source_subinventory,
	    x_line_type_id,
	    x_rfq_required_flag,
	    x_vendor_source_context,
	    x_org_id, 		    -- debug
	    x_line_type,
	    x_order_type_lookup_code,
	    x_source_type,
	    x_suggested_buyer,
	    x_vendor_name,
	    x_vendor_contact,
	    x_vendor_site,
	    x_source_organization_name,
            x_amount,
	    x_negotiated_by_preparer_flag
    FROM    po_lookup_codes	plc,
	    org_organization_definitions  ood,
	    po_line_types	plt,
            po_vendor_contacts vc,
	    po_vendor_sites  vs,
	    po_vendors v,
            mtl_system_items       msi,
	    po_requisition_lines   porl
    WHERE   porl.rowid      		  = x_rowid
    AND     nvl(porl.cancel_flag,'N')     = 'N'
    AND     nvl(porl.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND     porl.item_id                  = msi.inventory_item_id (+)
    AND     msi.organization_id (+)          = x_inv_org_id
    AND     nvl(msi.outside_operation_flag,'N') = 'N'
    AND     plt.line_type_id = porl.line_type_id
    AND	    plc.lookup_type (+) = 'REQUISITION SOURCE TYPE'
    AND     plc.lookup_code (+) = porl.source_type_code
    AND     v.vendor_id (+) = porl.vendor_id
    AND     vc.vendor_contact_id (+) = porl.vendor_contact_id
    AND     vs.vendor_site_id (+)    = porl.vendor_site_id
    AND	    ood.organization_id(+)   = porl.source_organization_id;



EXCEPTION
  WHEN OTHERS THEN RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       duplicate_express_name

===========================================================================*/

FUNCTION duplicate_express_name (x_express_name  VARCHAR2)
	RETURN BOOLEAN
IS
	dummy_char  VARCHAR2(1) := '';
BEGIN

  IF x_express_name IS NOT NULL THEN

    BEGIN

    SELECT 'Y'
    INTO   dummy_char
    FROM   po_reqexpress_headers porh
    WHERE  porh.express_name = x_express_name;

    return(TRUE);

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    return(false);
	WHEN OTHERS THEN
	    return(false);
    END;

  ELSE

    return (FALSE);

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       duplicate_sequence_number  ( iali bug 489705 )

===========================================================================*/

FUNCTION duplicate_sequence_number (X_express_name  IN  VARCHAR2,
  	                            X_sequence_num  IN  NUMBER,
			     	    X_rowid	    IN  VARCHAR2)
	RETURN BOOLEAN
IS
	dummy	   NUMBER;
BEGIN
    IF (X_sequence_num IS NOT NULL) THEN
    BEGIN

        SELECT  1
        INTO    dummy
        FROM    DUAL
        WHERE  not  exists (SELECT 'this line num exists already'
                           FROM   PO_REQEXPRESS_LINES
                           WHERE  EXPRESS_NAME = X_express_name
                           AND    SEQUENCE_NUM = X_sequence_num
   			   AND    (rowid      <> X_rowid OR X_rowid is NULL));
	return (FALSE);
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return (TRUE);
	WHEN OTHERS THEN
		return (TRUE);
    END;

    ELSE
	return (TRUE);

    END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END;  -- duplicate_sequence_number

/*===========================================================================

  PROCEDURE NAME:       inventory_item_cost

===========================================================================*/

FUNCTION inventory_item_cost (x_inventory_item_id   VARCHAR2,
		              x_organization_id     VARCHAR2)
	RETURN NUMBER
IS
	x_unit_price  NUMBER := 0;
BEGIN

  IF (x_organization_id IS NOT NULL AND
      x_inventory_item_id IS NOT NULL) THEN

    BEGIN

    SELECT item_cost
    INTO   x_unit_price
    FROM   cst_item_costs_for_gl_view
    WHERE  inventory_item_id = x_inventory_item_id
    AND    organization_id = x_organization_id;

    return(x_unit_price);

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    return(0);
	WHEN OTHERS THEN
	    return(0);
    END;

  ELSE
    return (0);
  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END;

-- debug:  This procedure is not needed.


-- Bug 1006562
-- Fetches the primary unit of measure for an item.
/*===========================================================================

  PROCEDURE NAME:	primary_unit_of_measure

============================================================================*/

FUNCTION primary_unit_of_measure (x_inventory_item_id 	IN VARCHAR2,
				  x_organization_id	IN VARCHAR2)
	RETURN VARCHAR2
IS
	x_primary_unit_of_measure  VARCHAR2(100) := NULL;
BEGIN

  IF (x_organization_id IS NOT NULL AND
      x_inventory_item_id IS NOT NULL) THEN

    BEGIN

    SELECT primary_unit_of_measure
    INTO   x_primary_unit_of_measure
    FROM   mtl_system_items
    WHERE  inventory_item_id = x_inventory_item_id
    AND    organization_id = x_organization_id;

    return(x_primary_unit_of_measure);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return(NULL);
      WHEN OTHERS THEN
        return(NULL);
    END;

  ELSE
    return(NULL);
  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END primary_unit_of_measure;

/*===========================================================================

  PROCEDURE NAME:       get_order_type

===========================================================================*/

PROCEDURE  get_order_type (x_line_type_id   		IN	NUMBER,
			   x_order_type_lookup_code	IN OUT NOCOPY  VARCHAR2)
IS
BEGIN

  IF (x_line_type_id IS NOT NULL) THEN

    BEGIN

	SELECT order_type_lookup_code
	INTO   x_order_type_lookup_code
	FROM   po_line_types
	WHERE  line_type_id = x_line_type_id;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    x_order_type_lookup_code := '';
	WHEN OTHERS THEN
	    raise;
    END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END;

END PO_REQ_TEMPLATE_SV2;

/

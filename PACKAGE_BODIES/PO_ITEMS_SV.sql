--------------------------------------------------------
--  DDL for Package Body PO_ITEMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ITEMS_SV" as
/* $Header: POXCOI1B.pls 120.2.12010000.7 2012/09/03 10:16:41 jksampat ship $ */
/*=============================  PO_ITEMS_SV  ===============================*/
g_chktype_TRACKING_QTY_IND_S CONSTANT
   MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND%TYPE
   := 'PS'; --<INVCONV R12>
/*===========================================================================

  FUNCTION NAME:	val_category()

===========================================================================*/
FUNCTION val_category(X_category_id  IN NUMBER,
		      X_structure_id IN NUMBER) return BOOLEAN IS

  X_progress      varchar2(3) := NULL;
  X_category_id_v number      := NULL;

BEGIN

  X_progress := '010';

  /* Check if the given Category is active */

  SELECT category_id
  INTO   X_category_id_v
  FROM   mtl_categories
  WHERE  sysdate < nvl(disable_date, sysdate + 1)
  AND	 enabled_flag = 'Y'
  AND    sysdate between nvl(start_date_active, sysdate -1)
  AND    nvl(end_date_active, sysdate + 1)
  AND    category_id = X_category_id
  AND	 structure_id = X_structure_id;

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('val_category',X_progress,sqlcode);
    raise;

END val_category;

/*===========================================================================

  PROCEDURE NAME:	val_item_org()

===========================================================================*/

PROCEDURE val_item_org
		(X_item_revision		IN	VARCHAR2,
		 X_item_id		 	IN	NUMBER,
		 X_master_ship_org_id	  	IN	NUMBER,
		 X_outside_operation_flag	IN	VARCHAR2,
		 X_item_valid		  	IN OUT	NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := '';

BEGIN

  x_progress := '010';

  /*
  ** If item does not have a revision, the following SQL statement
  ** will be executed to verify the line item is valid for the
  ** selected organization.
  */
  IF (X_item_revision IS NULL) THEN

	SELECT MAX('Y')  /*'item valid in the defaulted ship org'*/
	INTO   X_item_valid
	FROM   mtl_system_items msi
	WHERE  msi.inventory_item_id = X_item_id
	AND    msi.organization_id   = X_master_ship_org_id
	AND    msi.purchasing_enabled_flag = 'Y'
	AND    (  ( X_outside_operation_flag = 'Y'
	           AND nvl(msi.outside_operation_flag,'N') = 'Y')
	        OR X_outside_operation_flag = 'N'
	       );

	x_progress := '020';

	IF (X_item_valid is NULL) THEN
	  X_item_valid := 'N';
 	END IF;

  ELSE

  /*
  ** If item does have a revision, the following SQL statement
  ** will be executed to verify the line item and it's revision are
  ** valid for the selected organization.
  */
	SELECT MAX('Y')
	INTO   X_item_valid
	FROM   mtl_system_items   msi,
	       mtl_item_revisions mir
	WHERE  mir.organization_id   = X_master_ship_org_id
	AND    mir.revision          = X_item_revision
	AND    mir.inventory_item_id = X_item_id
	AND    msi.inventory_item_id = X_item_id
	AND    msi.organization_id   = X_master_ship_org_id
	AND    msi.purchasing_enabled_flag = 'Y'
	AND    (  ( X_outside_operation_flag = 'Y'
	           AND nvl(msi.outside_operation_flag,'N') = 'Y')
	        OR X_outside_operation_flag = 'N'
	       );

  	x_progress := '030';

	IF (X_item_valid is NULL) THEN
	  X_item_valid := 'N';
 	END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('val_item_org', x_progress, sqlcode);

END val_item_org;

/*===========================================================================

  PROCEDURE NAME:	get_item_info()

===========================================================================*/

PROCEDURE get_item_info(X_type_lookup_code		IN	VARCHAR2,
			X_category_set_id		IN	NUMBER,
			X_item_id			IN	NUMBER,
			X_inventory_organization_id	IN	NUMBER,
			X_source_type_lookup_code	IN	VARCHAR2,
			X_item_description		IN OUT	NOCOPY VARCHAR2,
			X_unit_meas_lookup_code		IN OUT	NOCOPY VARCHAR2,
			X_unit_price			IN OUT	NOCOPY NUMBER,
			X_category_id			IN OUT	NOCOPY NUMBER,
			X_purchasing_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			X_internal_order_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			X_outside_op_uom_type		IN OUT	NOCOPY VARCHAR2,
			X_inventory_asset_flag		IN OUT	NOCOPY VARCHAR2,
			X_allow_item_desc_update_flag	IN OUT	NOCOPY VARCHAR2,
			X_allowed_units_lookup_code	IN OUT	NOCOPY NUMBER,
			X_primary_unit_class		IN OUT	NOCOPY VARCHAR2,
			X_rfq_required_flag		IN OUT	NOCOPY VARCHAR2,
			X_un_number_id			IN OUT	NOCOPY NUMBER,
			X_hazard_class_id		IN OUT	NOCOPY NUMBER,
			X_inv_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_mrp_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_taxable_flag 			IN OUT NOCOPY 	VARCHAR2,
			X_market_price			IN OUT	NOCOPY NUMBER,
			X_invoice_close_tolerance	IN OUT	NOCOPY NUMBER,
			X_receive_close_tolerance	IN OUT	NOCOPY NUMBER,
			X_receipt_required_flag		IN OUT	NOCOPY VARCHAR2,
			X_restrict_subinventories_code	IN OUT	NOCOPY NUMBER,
			X_hazard_class			IN OUT	NOCOPY VARCHAR2,
			X_un_number			IN OUT	NOCOPY VARCHAR2,
			X_stock_enabled_flag		IN OUT	NOCOPY VARCHAR2,
			X_outside_operation_flag	IN OUT	NOCOPY VARCHAR2,
			--<INVCONV R12 START>
			X_secondary_default_ind		IN OUT NOCOPY VARCHAR2,
    	           	X_grade_control_flag		IN OUT NOCOPY VARCHAR2,
   			X_secondary_unit_of_measure	IN OUT NOCOPY VARCHAR2
   			--<INVCONV R12 END>
			) IS

x_progress VARCHAR2(3) := '';

BEGIN
  x_progress := '010';
  IF (X_item_id is NOT NULL) THEN

    po_items_sv.get_item_defaults
		       (X_type_lookup_code,
			X_category_set_id,
			X_item_id,
			X_inventory_organization_id,
			X_source_type_lookup_code,
			X_item_description,
			X_unit_meas_lookup_code,
			X_unit_price,
			X_category_id,
			X_purchasing_enabled_flag,
			X_internal_order_enabled_flag,
			X_outside_op_uom_type,
			X_inventory_asset_flag,
			X_allow_item_desc_update_flag,
			X_allowed_units_lookup_code,
			X_primary_unit_class,
			X_rfq_required_flag,
			X_un_number_id,
			X_hazard_class_id,
			X_inv_planned_item_flag,
			X_mrp_planned_item_flag,
			X_planned_item_flag,
			X_taxable_flag,
			X_market_price,
			X_invoice_close_tolerance,
			X_receive_close_tolerance,
			X_receipt_required_flag,
			X_restrict_subinventories_code,
			X_stock_enabled_flag,
			X_outside_operation_flag,
			--<INVCONV R12 START>
			X_secondary_default_ind,
		      	X_grade_control_flag,
   			X_secondary_unit_of_measure
			--<INVCONV R12 END>
			);
    x_progress := '020';

     /*
     ** Derive the un number from the returned un_number_id.
     */
     IF (X_un_number_id IS NOT NULL) THEN
       po_items_sv.get_un_number(X_un_number_id,
	      		         X_un_number);
       x_progress := '030';

     END IF;

     /*
     ** Derive the hazard class name from the returned hazard_class_id.
     */
     IF (X_hazard_class_id IS NOT NULL) THEN
       po_items_sv.get_hazard_class(X_hazard_class_id,
				    X_hazard_class);
       x_progress := '040';

     END IF;
  END if;
EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_item_info', x_progress, sqlcode);

END get_item_info;

/*===========================================================================

  PROCEDURE NAME:	get_item_defaults()

===========================================================================*/

PROCEDURE get_item_defaults
		 	(X_type_lookup_code		IN	VARCHAR2,
			 X_category_set_id		IN	NUMBER,
			 X_item_id			IN	NUMBER,
			 X_inventory_organization_id	IN	NUMBER,
			 X_source_type_lookup_code	IN	VARCHAR2,
		 	 X_item_description		IN OUT	NOCOPY VARCHAR2,
			 X_unit_meas_lookup_code	IN OUT	NOCOPY VARCHAR2,
			 X_unit_price			IN OUT	NOCOPY NUMBER,
			 X_category_id			IN OUT	NOCOPY NUMBER,
			 X_purchasing_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			 X_internal_order_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			 X_outside_op_uom_type		IN OUT	NOCOPY VARCHAR2,
			 X_inventory_asset_flag		IN OUT	NOCOPY VARCHAR2,
			 X_allow_item_desc_update_flag	IN OUT	NOCOPY VARCHAR2,
			 X_allowed_units_lookup_code	IN OUT	NOCOPY NUMBER,
			 X_primary_unit_class		IN OUT	NOCOPY VARCHAR2,
			 X_rfq_required_flag		IN OUT	NOCOPY VARCHAR2,
			 X_un_number_id			IN OUT	NOCOPY NUMBER,
			 X_hazard_class_id		IN OUT	NOCOPY NUMBER,
			 X_inv_planned_item_flag	IN OUT	NOCOPY VARCHAR2,
			 X_mrp_planned_item_flag	IN OUT	NOCOPY VARCHAR2,
			 X_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			 X_taxable_flag 		IN OUT NOCOPY 	VARCHAR2,
			 X_market_price			IN OUT	NOCOPY NUMBER,
			 X_invoice_close_tolerance	IN OUT	NOCOPY NUMBER,
			 X_receive_close_tolerance	IN OUT	NOCOPY NUMBER,
			 X_receipt_required_flag	IN OUT	NOCOPY VARCHAR2,
			 X_restrict_subinventories_code	IN OUT	NOCOPY NUMBER,
			 X_stock_enabled_flag		IN OUT NOCOPY 	VARCHAR2,
			 X_outside_operation_flag	IN OUT	NOCOPY VARCHAR2,
			 --<INVCONV R12 START>
			 X_secondary_default_ind	IN OUT NOCOPY VARCHAR2,
    	           	 X_grade_control_flag		IN OUT NOCOPY VARCHAR2,
   			 X_secondary_unit_of_measure	IN OUT NOCOPY VARCHAR2
   			 --<INVCONV R12 END>
			) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';

  /*
  ** If document is a requisition (type_lookup_code = INTERNAL or PURCHASE),
  ** a different SELECT statement is executed.
  */
  /* BUG: 656428 -  Added to_char conversion to the mrp_planning_code
  **                and the inventory_planning_code to avoid value errors.
  */

  IF (X_type_lookup_code IN ('INTERNAL', 'PURCHASE')) THEN

    x_progress := '020';

    SELECT msi.description,
	   decode(X_source_type_lookup_code, 'INVENTORY',
		  	nvl(msi.unit_of_issue, msi.primary_unit_of_measure),
                 	 msi.primary_unit_of_measure),
           msi.list_price_per_unit,
           mic.category_id,
           msi.purchasing_enabled_flag,
           msi.internal_order_enabled_flag,
           msi.outside_operation_uom_type,
           msi.inventory_asset_flag,
           msi.allow_item_desc_update_flag,
           msi.allowed_units_lookup_code,
           mum.uom_class,
           nvl(msi.rfq_required_flag, X_rfq_required_flag),
           nvl(msi.un_number_id,      X_un_number_id),
           nvl(msi.hazard_class_id,   X_hazard_class_id),
           decode(to_char(msi.inventory_planning_code),
                  NULL,'N',
                  '6', 'N',
                       'Y'),
           decode(to_char(msi.mrp_planning_code),
                  NULL,'N',
                  '6', 'N',
                       'Y'),
	   nvl(msi.stock_enabled_flag,'N'),
	   nvl(msi.outside_operation_flag,'N'),
	   --<INVCONV R12 START>
	   decode(msi.tracking_quantity_ind,
                  g_chktype_TRACKING_QTY_IND_S,msi.secondary_default_ind,NULL),
   	   msi.grade_control_flag,
   	   decode(msi.tracking_quantity_ind,
                  g_chktype_TRACKING_QTY_IND_S,mum2.unit_of_measure,NULL)
   	   --<INVCONV R12 END>
    INTO   X_item_description,
	   X_unit_meas_lookup_code,
	   X_unit_price,
	   X_category_id,
	   X_purchasing_enabled_flag,
	   X_internal_order_enabled_flag,
      	   X_outside_op_uom_type,
	   X_inventory_asset_flag,
	   X_allow_item_desc_update_flag,
	   X_allowed_units_lookup_code,
	   X_primary_unit_class,
	   X_rfq_required_flag,
	   X_un_number_id,
	   X_hazard_class_id,
	   X_inv_planned_item_flag,
	   X_mrp_planned_item_flag,
	   X_stock_enabled_flag,
	   X_outside_operation_flag,
	   --<INVCONV R12 START>
           X_secondary_default_ind,
    	   X_grade_control_flag	,
    	   X_secondary_unit_of_measure
    	   --<INVCONV R12 END>
    FROM   mtl_units_of_measure   mum,
           mtl_item_categories    mic,
           mtl_system_items       msi,
           mtl_parameters         mpa,
           mtl_units_of_measure   mum2  --<INVCONV R12>
    WHERE  mic.inventory_item_id = X_item_id
    AND    mic.category_set_id   = X_category_set_id
    AND    mic.organization_id   = X_inventory_organization_id
    AND    msi.organization_id   = X_inventory_organization_id
    AND    msi.inventory_item_id = X_item_id
    AND    mum.unit_of_measure   =
              decode(X_source_type_lookup_code,'INVENTORY',
                      nvl(msi.unit_of_issue, msi.primary_unit_of_measure),
                      msi.primary_unit_of_measure)
    AND    mpa.organization_id   = X_inventory_organization_id
    AND    msi.secondary_uom_code = mum2.uom_code(+) ; --<INVCONV R12>

    x_progress := '030';

  /*
  ** If document is NOT a requisition, perform a different SELECT
  ** (this SELECT doesn't take into consideration the source type)
  */
  ELSE

    x_progress := '040';

/* Bug # 2076346.
   Added conditions for mrp_planning_code 7,8,9. This will be used in the
   need_by_date validation in Shipments of Enter PO later.  */

    SELECT mic.category_id,
           decode(msi.mrp_planning_code, 3, 'Y', 4, 'Y', 7, 'Y', 8, 'Y', 9, 'Y',
		  decode(msi.inventory_planning_code,1,'Y',2,'Y', 'N')),
           msi.description,
           msi.list_price_per_unit,
	   msi.market_price,
	   msi.taxable_flag,
           msi.allow_item_desc_update_flag,
           msi.allowed_units_lookup_code,
           msi.primary_unit_of_measure,
	   mum.uom_class,
           msi.un_number_id,
           msi.hazard_class_id,
           msi.outside_operation_uom_type,
	   nvl(msi.invoice_close_tolerance, X_invoice_close_tolerance),
           nvl(msi.receive_close_tolerance, X_receive_close_tolerance),
           nvl(msi.receipt_required_flag,   X_receipt_required_flag),
           msi.restrict_subinventories_code,
           --<INVCONV R12 START>
	   decode(msi.tracking_quantity_ind,
                  g_chktype_TRACKING_QTY_IND_S,msi.secondary_default_ind,NULL),
   	   msi.grade_control_flag,
   	   decode(msi.tracking_quantity_ind,
                  g_chktype_TRACKING_QTY_IND_S,mum2.unit_of_measure,NULL)
   	   --<INVCONV R12 END>
    INTO   X_category_id,
	   X_planned_item_flag,
	   X_item_description,
	   X_unit_price,
	   X_market_price,
	   X_taxable_flag,
	   X_allow_item_desc_update_flag,
       	   X_allowed_units_lookup_code,
       	   X_unit_meas_lookup_code,
       	   X_primary_unit_class,
       	   X_un_number_id,
       	   X_hazard_class_id,
       	   X_outside_op_uom_type,
       	   X_invoice_close_tolerance,
       	   X_receive_close_tolerance,
       	   X_receipt_required_flag,
       	   X_restrict_subinventories_code,
       	   --<INVCONV R12 START>
           X_secondary_default_ind,
    	   X_grade_control_flag	,
    	   X_secondary_unit_of_measure
    	   --<INVCONV R12 END>
    FROM   mtl_units_of_measure   mum,
           mtl_item_categories    mic,
           mtl_system_items       msi,
           mtl_units_of_measure   mum2  --<INVCONV R12>
    WHERE  msi.inventory_item_id       = X_item_id
    AND    mic.inventory_item_id       = X_item_id
    AND    mic.category_set_id         = X_category_set_id
    AND    mic.organization_id         = X_inventory_organization_id
    AND    msi.organization_id         = X_inventory_organization_id
    AND    msi.primary_unit_of_measure = mum.unit_of_measure
    AND    msi.secondary_uom_code = mum2.uom_code(+) ; --<INVCONV R12>

    x_progress := '050';

  END IF;


   /*
   ** Bug 2198247. The item description should be
   ** fetched from mtl_system_item_tl not from
   ** mtl_system_items. So the following SELECT statement
   ** is added to get the description from mtl_system_items_tl.
   */


    SELECT   description
    INTO     X_item_description
    FROM     mtl_system_items_tl
    WHERE    inventory_item_id = X_item_id
    AND      language = USERENV('LANG')
    AND      organization_id = X_inventory_organization_id;

  -- End of Bug 2198247.

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_item_defaults', x_progress, sqlcode);

END get_item_defaults;

/*===========================================================================

  PROCEDURE NAME:	get_hazard_class()

===========================================================================*/

PROCEDURE get_hazard_class(X_hazard_class_id		IN	NUMBER,
			   X_hazard_class		IN OUT	NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';

  SELECT hazard_class
  INTO   X_hazard_class
  FROM   po_hazard_classes
  WHERE  hazard_class_id = X_hazard_class_id;

  x_progress := '020';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_hazard_class', x_progress, sqlcode);

END get_hazard_class;

/*===========================================================================

  PROCEDURE NAME:	get_un_number()

===========================================================================*/

PROCEDURE get_un_number(X_un_number_id			IN	NUMBER,
			X_un_number			IN OUT	NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';

  SELECT poun.un_number
  INTO   X_un_number
  FROM   po_un_numbers poun
  WHERE  poun.un_number_id = X_un_number_id;

  x_progress := '020';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_un_number', x_progress, sqlcode);

END get_un_number;

/*===========================================================================

  PROCEDURE NAME:	val_item_revision()

===========================================================================*/

PROCEDURE val_item_revision(X_item_revision		IN	VARCHAR2,
			    X_item_id			IN	NUMBER,
			    X_destination_org_id	IN OUT	NOCOPY NUMBER,
			    X_deliver_to_location_id	IN OUT	NOCOPY NUMBER,
			    X_destination_subinventory	IN OUT	NOCOPY VARCHAR2,
			    X_destination_org_name	IN OUT	NOCOPY VARCHAR2,
			    X_revision_is_valid		IN OUT	NOCOPY VARCHAR2) IS

x_progress 		VARCHAR2(3) := '';

BEGIN

  x_progress := '010';
  X_revision_is_valid := '';

  /*
  ** If an item revision is passed into this procedure, verify the revision
  ** is valid for the item in the current organization.
  */
  IF (X_item_revision is NOT NULL) THEN

    SELECT MAX('Y')
    INTO   X_revision_is_valid
    FROM   mtl_item_revisions mir
    WHERE  mir.organization_id   = X_destination_org_id
    AND    mir.revision          = X_item_revision
    AND    mir.inventory_item_id = X_item_id;

    x_progress := '020';

    /*
    ** If the revision is invalid, then set the organization,
    ** deliver to location, and destination subinventory to NULL, and
    ** display an error message.
    */
    IF (X_revision_is_valid is null) THEN

      SELECT organization_name
      INTO   X_destination_org_name
      FROM   org_organization_definitions
      WHERE  organization_id = X_destination_org_id;

      x_progress := '030';

      X_revision_is_valid := 'N';

      X_destination_org_id := '';
      X_deliver_to_location_id := '';
      X_destination_subinventory := '';

      po_message_s.app_error('PO_REQ_REV_NOT_VALID', 'REVISION', X_item_revision,
						     'ORG', X_destination_org_name);

    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('val_item_revision', x_progress, sqlcode);

END val_item_revision;

/*===========================================================================

  PROCEDURE NAME:	get_secondary_attributes()

===========================================================================*/


PROCEDURE get_secondary_attributes (
			   X_item_id                    IN      NUMBER,
			   X_inventory_organization_id  IN      NUMBER,
			   X_fetch_secondary_uom	IN      VARCHAR2 DEFAULT 'Y',
			   X_secondary_unit_of_measure	IN OUT  NOCOPY VARCHAR2,
			   X_secondary_default_ind	   OUT  NOCOPY VARCHAR2,
			   X_grade_control_flag		   OUT  NOCOPY VARCHAR2,
			   X_secondary_unit_of_measure_tl  OUT  NOCOPY VARCHAR2)  IS

/**    FETCH_SECONDARY_UOM  = 'N' - don't fetch secondary unit of measure
FETCH_SECONDARY_UOM  = 'Y' and secondary_unit_of_measure is not given
Fetch secondary unit of measure and secondary unit of measure_tl
FETCH_SECONDARY_UOM  = 'Y' and secondary_unit_of_measure is given
Fetch secondary unit of measure_tl  **/

BEGIN
   IF x_item_id IS NULL OR X_inventory_organization_id    IS NULL THEN
      RETURN;
   END IF;

   IF X_fetch_secondary_uom = 'Y'  and x_secondary_unit_of_measure IS NULL THEN

      SELECT decode(msi.tracking_quantity_ind,
                    g_chktype_TRACKING_QTY_IND_S,msi.secondary_default_ind,NULL),
   	     msi.grade_control_flag,
   	     decode(msi.tracking_quantity_ind,
                    g_chktype_TRACKING_QTY_IND_S,mum.unit_of_measure,NULL)
      INTO   X_secondary_default_ind, X_grade_control_flag,	X_secondary_unit_of_measure
      FROM   mtl_units_of_measure   mum, mtl_system_items       msi
      WHERE  msi.organization_id = X_inventory_organization_id
      AND    msi.inventory_item_id = X_item_id
      AND    mum.uom_code(+) = msi.secondary_uom_code ;

   ELSE
      SELECT decode(msi.tracking_quantity_ind,
                    g_chktype_TRACKING_QTY_IND_S,msi.secondary_default_ind,NULL),
	     msi.grade_control_flag
      INTO   X_secondary_default_ind, X_grade_control_flag
      FROM   mtl_system_items       msi
      WHERE  msi.organization_id = X_inventory_organization_id
      AND    msi.inventory_item_id = X_item_id ;
   END IF;

   IF  X_fetch_secondary_uom = 'Y' AND X_secondary_unit_of_measure is not null then
      po_lines_sv4.get_unit_meas_lookup_code_tl(X_secondary_unit_of_measure,
                                                X_secondary_unit_of_measure_tl);
   END IF;

   EXCEPTION WHEN OTHERS THEN
      po_message_s.sql_error('get_secondary_attributes', '010', sqlcode);
      RAISE;
END GET_SECONDARY_ATTRIBUTES ;


-- bug5467964 START

/*===========================================================================

  PROCEDURE NAME:	has_valid_item_rev_for_line

===========================================================================*/
PROCEDURE has_valid_item_rev_for_line
( p_item_id IN NUMBER,
  p_has_line_been_saved_flag IN VARCHAR2,
  p_po_line_id IN NUMBER,
  p_sob_id IN NUMBER,
  x_result OUT NOCOPY VARCHAR2
) IS

l_key PO_SESSION_GT.key%TYPE;
l_dummy NUMBER;
l_shipment_count NUMBER;

--Bug11658279
l_doc_type PO_HEADERS_ALL.type_lookup_code%TYPE;

BEGIN

    /* Bug 11658279 START- For a BPA, there may not be shipments when line is saved.
                    Bcoz of this, it is not necessary to check if all ship-to
		    orgs have particular item revision.
		    Making a fix to find all possible item revisions within org
		    for current sob in case of BPA line.
     */

  IF (p_has_line_been_saved_flag = 'Y') THEN


      SELECT type_lookup_code INTO l_doc_type
      FROM po_headers_all
      WHERE po_header_id = (SELECT po_header_id
                            FROM   po_lines_merge_v
							WHERE  po_line_id = p_po_line_id);
  END IF;
  -- Bug 11658279 END


  IF (l_doc_type = 'BLANKET' OR p_has_line_been_saved_flag = 'N') THEN  -- Bug 11658279 added condition to check if doc type is BPA.

    BEGIN

      -- if the line has not been saved, then find all possible
      -- revisions from within the org in current sob.
      SELECT 1
      INTO   l_dummy
      FROM   DUAL
      WHERE  EXISTS
             (SELECT MIR.revision
              FROM   mtl_item_revisions MIR,
                     org_organization_definitions OOD
              WHERE  OOD.set_of_books_id = p_sob_id
              AND    SYSDATE < NVL(OOD.disable_date, SYSDATE + 1)
              AND    MIR.organization_id = OOD.organization_id
              AND    MIR.inventory_item_id = p_item_id);

      x_result := FND_API.G_TRUE;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_result := FND_API.G_FALSE;
    END;
  ELSE

    l_key := PO_CORE_S.get_session_gt_nextval;

    -- if the line has been saved, then we return FND_API.TRUE only if
    -- all the non-cancelled shipments share at least one revision. This
    -- is essentially done by:

    -- (1) Count all occurences of the revision numbers for the orgs in
    --     shipment
    -- (2) Count the number of shipments
    -- (3) If a particular revision is shared among all orgs, the count
    --     for the revision should be the same as the shipment count


    INSERT INTO po_session_gt
    ( key,
      char1,
      num1
    )
    SELECT l_key,
           MIR.revision,
           count(*)
    FROM   po_line_locations_all PLL,
           mtl_item_revisions MIR,
           org_organization_definitions OOD
    WHERE  PLL.po_line_id = p_po_line_id
    AND    NVL(PLL.cancel_flag, 'N') = 'N'
    AND    MIR.inventory_item_id = p_item_id
    AND    OOD.set_of_books_id = p_sob_id
    AND    SYSDATE < NVL (OOD.disable_date, SYSDATE + 1)
    AND    PLL.ship_to_organization_id = OOD.organization_id
    AND    PLL.ship_to_organization_id = MIR.organization_id
    GROUP BY MIR.revision;

    SELECT count(*)
    INTO   l_shipment_count
    FROM   po_line_locations_merge_v
    WHERE  po_line_id = p_po_line_id
	AND    NVL(cancel_flag, 'N') = 'N';

    BEGIN
      -- If one of the revision counts is the same as the number of shipments,
      -- it means that all ship to orgs have this revision
      SELECT 1
      INTO   l_dummy
      FROM   DUAL
      WHERE  EXISTS
             ( SELECT 1
               FROM   po_session_gt
               WHERE  key = l_key
               AND    num1 = l_shipment_count );

      x_result := FND_API.G_TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_result := FND_API.G_FALSE;
    END;

    DELETE FROM po_session_gt WHERE key = l_key;


  END IF;


EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error('has_valid_item_rev_for_line', '010', sqlcode);
  RAISE;

END has_valid_item_rev_for_line;
-- bug5467964 END


END PO_ITEMS_SV;

/

--------------------------------------------------------
--  DDL for Package Body PO_SOURCING_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING_SV" as
/* $Header: POXSCS1B.pls 115.7 2004/06/22 02:10:05 mbhargav ship $ */


/*=============================  PO_SOURCING_SV  ============================*/

/*===========================================================================

  PROCEDURE NAME:	val_order_pad_line()

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
)
IS

  l_progress	          VARCHAR2(3)  := NULL;
  l_item_org_val	  BOOLEAN      := TRUE;

  -- <SERVICES FPJ START>
  l_order_type_lookup_code  po_lines_all.order_type_lookup_code%TYPE := null;
  l_purchase_basis          po_lines_all.purchase_basis%TYPE := null;
  l_category_id             NUMBER := null;
  l_unit_meas_lookup_code   po_lines_all.unit_meas_lookup_code%TYPE := null;
  l_unit_price              NUMBER := null;
  l_outside_operation_flag  po_line_types.outside_operation_flag%TYPE := null;
  l_receiving_flag          po_line_types.receiving_flag%TYPE := null;
  l_receive_close_tolerance NUMBER := null;
  -- <SERVICES FPJ END>

BEGIN

  /* Verify those data elements that should always present on a source
  ** document line.  If any of these required elements are NULL, then
  ** set the valid value to FALSE.
  */

  if ((p_category_id is null) and
      (p_structure_id is null)) then

    X_category_val := FALSE;
  else
    l_progress := '010';
    X_category_val := po_items_sv.val_category(p_category_id,
				               p_structure_id);
  end if;

  -- <SERVICES FPJ START>
  -- Need to retrieve the value basis to be used for validation
  -- of UOM. If the line is a new Services line, UOM has to be null
  IF (p_line_type_id is not null) THEN
      PO_LINE_TYPES_SV.get_line_type_def(p_line_type_id,
                                         l_order_type_lookup_code,
                                         l_purchase_basis,
                                         l_category_id,
                                         l_unit_meas_lookup_code,
                                         l_unit_price,
                                         l_outside_operation_flag,
                                         l_receiving_flag,
                                         l_receive_close_tolerance);
  END IF;
  -- <SERVICES FPJ END>

  IF (l_order_type_lookup_code <> 'FIXED PRICE' AND
      l_order_type_lookup_code is not null) THEN  -- <SERVICES FPJ>
      if (p_unit_of_measure is null) then
        X_unit_of_meas_val := FALSE;
      else
        l_progress := '020';
        X_unit_of_meas_val := po_uom_s.val_unit_of_measure(p_unit_of_measure);
      end if;
  -- <SERVICES FPJ START>
  ELSE
      X_unit_of_meas_val := TRUE;
  END IF;
  -- <SERVICES FPJ END>

  if (p_currency_code is null) then
    X_currency_val := FALSE;
  else
    l_progress := '030';
    X_currency_val := po_currency_sv.val_currency(p_currency_code);
  end if;

  if (p_line_type_id is null) then
    X_line_type_val := FALSE;
  else
    l_progress := '040';
    X_line_type_val:= po_line_types_sv.val_line_type(p_line_type_id);
  end if;

  /* If the source type is vendor, then validate the vendor-related
  ** information.  If this is an internally-sourced line, then we
  ** will validate the source org etc. when we validate the Order
  ** Pad record.
  */

  if (p_source_type = 'VENDOR') then

    l_progress := '050';
    X_vendor_val := po_vendors_sv.val_vendor(p_vendor_id);

    l_progress := '060';
    --< Shared Proc FPJ Start >
    X_vendor_site_val := po_vendor_sites_sv.val_vendor_site_id
                                    (p_document_type  => p_document_type,
                                     p_vendor_site_id => p_vendor_site_id,
                                     p_org_id         => p_purchasing_org_id);
    --< Shared Proc FPJ End >

    /* If a supplier contact has been specified, check to see if it
    ** is still active.
    */

    if (p_vendor_contact_id is not null
        and x_vendor_site_val) then  --<Bug 3692519>

      l_progress := '065';
      X_vendor_contact_val :=
           po_vendor_contacts_sv.val_vendor_contact(
                      p_vendor_contact_id => p_vendor_contact_id,
                      p_vendor_site_id => p_vendor_site_id); --<Bug 3692519>
    end if;
  end if;

  /* If the item and destination org are not null, get relevant item information.
  */

  if (p_item_id is not null) then
    if (p_dest_org_id is not null) then

      l_progress := '070';
      l_item_org_val := po_sourcing2_sv.get_item_detail(p_item_id,
				                        p_dest_org_id,
			                                X_planned_item_flag,
				                        X_list_price,
				                        X_primary_uom);
    end if;
  end if;


  /* Now for inventory-sourced lines, if the order pad line's UOM differs
  ** from the primary UOM, then we need to convert the inventory cost.
  */



  if ((p_item_id is null) or
      (X_primary_uom = p_unit_of_measure) or
      (p_primary_inv_cost is null) or
      (p_vendor_id is null) or
      (p_primary_inv_cost = 0) or
      (X_unit_of_meas_val = FALSE) and
      (p_source_type <> 'INVENTORY')) then

     X_change_price := FALSE;

/* Bug#2632638 Added the below condition in the Else part as for Inventory-
** Sourced lines, if the order pad line's UOM differs from the primary UOM,
** then only we need to convert the inventory cost and not for the other
** cases. */

  elsif (p_source_type = 'INVENTORY') then

     l_progress := '075';

     SELECT primary_unit_of_measure
     INTO   X_primary_uom
     FROM   mtl_system_items
     WHERE  inventory_item_id = p_item_id
     AND    organization_id   = p_dest_org_id;

    if (po_uom_sv2.convert_inv_cost(p_item_id,
				    p_unit_of_measure,
				    X_primary_uom,
				    p_primary_inv_cost,
				    X_convert_inv_cost) = TRUE) then

      X_change_price := TRUE;

    end if;
  end if;


  /* If disposition messages should be shown for the item/item master
  ** organization -- and we are working with a predefined item --
  ** get the disposition message for this combination.  If multiple
  ** messages exist, display an warning message indicating the user
  ** should look at the item cross references form.
  */

  if ((p_item_id is not null) and
      (p_instance_org_id is not null) and
      (p_display_message = 'Y') and
      (l_item_org_val = TRUE)) then

    X_messages_exist := po_sourcing_sv4.get_disposition_message(p_item_id,
								p_instance_org_id,
								p_cross_ref_type,
								X_message,
								X_multiple_flag);

  end if;

  /* If working within the Catalog from a purchase order, verify the terms
  ** and conditions.
  */

  if (p_document_type in ('PO', 'BLANKET')) then

    if (p_ap_terms_id is null) then
      X_ap_terms_val := FALSE;
    else
      l_progress := '120';
      X_ap_terms_val := po_terms_sv.val_payment_terms(p_ap_terms_id);
    end if;

    if (p_fob_lookup_code is null) then
      X_fob_lookup_val := FALSE;
    else
      l_progress := '130';
      X_fob_lookup_val := po_terms_sv.val_fob_code(p_fob_lookup_code);
    end if;

    if (p_freight_terms_code is null) then
      X_freight_terms_val := FALSE;
    else
      l_progress := '140';
      X_freight_terms_val := po_terms_sv.val_freight_code(p_freight_terms_code);
    end if;

    if (p_ship_via_code is null) then
      X_ship_via_val := FALSE;
    else
      l_progress := '150';
      X_ship_via_val := po_terms_sv.val_ship_via(p_ship_via_code,
						 p_instance_org_id);
    end if;

  end if;

EXCEPTION

  when others then
    po_message_s.sql_error('val_order_pad_line', l_progress, sqlcode);
    raise;

END val_order_pad_line;

/*===========================================================================

  FUNCTION NAME:	vendor_sourcing_status()

===========================================================================*/
FUNCTION vendor_sourcing_status(X_item_id		  IN  NUMBER,
			     X_vendor_id 	  IN  NUMBER,
			     X_vendor_site_id	  IN  NUMBER,
			     X_organization_id    IN  NUMBER,
			     X_autosource_rule_id IN  NUMBER,
			     X_assignment_set_id  IN  NUMBER)
RETURN varchar2 IS

  approval_status varchar2(20) := NULL;
  temp varchar2(20) := NULL;

BEGIN

  /* Note:  this function does not have std. error handling as required to be
  ** called from within a view.
  */

  /* One-time items do not have autosource rules associated with them,
  ** so approval status is not applicable here.
  */

  if (X_item_id is null or X_vendor_id is null) then

     approval_status := 'NOT APPLICABLE';

  elsif (x_assignment_set_id IS NULL) then

    /* If the query finds a row (only 1 AutoSource rule can be effective
    ** at any point in time so this will return only 1 row if a match is
    ** found), set the status to APPROVED.  If no data found, see EXCEPTION.
    **
    ** Note:  need 2 different selects because the AutoSource case is more
    ** precise -- need to check for the given rule id while the check in
    ** all other cases just needs to know if *any* rule is valid for the
    ** constraints.
    */

     if (X_autosource_rule_id is null) then
       select 'exists' into
       temp
       from  po_autosource_rules  par,
	     po_autosource_vendors pav
       where par.item_id = X_item_id
       and   pav.vendor_id = X_vendor_id
       and   par.autosource_rule_id = pav.autosource_rule_id
       and   trunc(sysdate) between
	     nvl(par.start_date, sysdate - 1) and
	     nvl(par.end_date, sysdate + 1);

     else
       select 'exists' into
       temp
       from  po_autosource_rules  par,
	     po_autosource_vendors pav
       where par.item_id = X_item_id
       and   pav.vendor_id = X_vendor_id
       and   par.autosource_rule_id = pav.autosource_rule_id
       and   par.autosource_rule_id = X_autosource_rule_id
       and   trunc(sysdate) between
	     nvl(par.start_date, sysdate - 1) and
	     nvl(par.end_date, sysdate + 1);

     end if;

     if (temp  = 'exists') then

 	approval_status := 'APPROVED';

     end if;

  else

     if (X_organization_id is null) then

       -- Quotations do not have deliver-to orgs.  Check that
       -- the vendor, site on the quotation is approved for that
       -- item in some org.

       select 'exists' into
       temp
       from  mrp_sources_v sv
       where sv.inventory_item_id = X_item_id
       and   sv.vendor_id = X_vendor_id
       and   nvl(sv.vendor_site_id, -1) = nvl(X_vendor_site_id, -1)
       and   sv.assignment_set_id = X_assignment_set_id
       and   trunc(sysdate) between
	     nvl(sv.effective_date, sysdate - 1) and
	     nvl(sv.disable_date, sysdate + 1);

     elsif (X_autosource_rule_id is null) then
       select 'exists' into
       temp
       from  mrp_sources_v sv
       where sv.inventory_item_id = X_item_id
       and   sv.vendor_id = X_vendor_id
       and   nvl(sv.vendor_site_id, -1) = nvl(X_vendor_site_id, -1)
       and   sv.assignment_set_id = X_assignment_set_id
       and   sv.organization_id = X_organization_id
       and   trunc(sysdate) between
	     nvl(sv.effective_date, sysdate - 1) and
	     nvl(sv.disable_date, sysdate + 1);

     else

       select 'exists' into
       temp
       from  mrp_sources_v sv
       where sv.inventory_item_id = X_item_id
       and   sv.sourcing_rule_id = X_autosource_rule_id
       and   sv.vendor_id = X_vendor_id
       and   nvl(sv.vendor_site_id, -1) = nvl(X_vendor_site_id, -1)
       and   sv.assignment_set_id = X_assignment_set_id
       and   sv.organization_id = X_organization_id
       and   trunc(sysdate) between
	     nvl(sv.effective_date, sysdate - 1) and
	     nvl(sv.disable_date, sysdate + 1);

      end if;

     if (temp  = 'exists') then

 	approval_status := 'APPROVED';

     end if;

  end if;

  return (approval_status);

EXCEPTION
  when no_data_found then

    return('NOT APPROVED');

  when others then

    return (NULL);

END;



END PO_SOURCING_SV;

/

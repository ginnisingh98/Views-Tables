--------------------------------------------------------
--  DDL for Package Body PO_ORGS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ORGS_SV2" as
/* $Header: POXCOO1B.pls 120.0.12000000.2 2007/04/26 08:43:07 vdurbhak ship $*/
/*=============================  PO_ORGS_SV2  =============================*/

/*===========================================================================

 FUNCTION NAME :  val_dest_org()

===========================================================================*/
function val_dest_org(x_destination_org_id in number,
		      x_item_id            in number,
		      x_item_revision      in varchar2,
		      x_destination_type   in varchar2,
		      x_sob_id		   in number,
		      x_source_type        in varchar2) return boolean is

  x_progress varchar2(3) := NULL;
  x_org_count number     := 0;

begin

  /* Perform the following basic org check in all cases (item is
  ** null or item is specified).
  */

  x_progress := '010';

  SELECT count(1)
  INTO   x_org_count
  FROM   org_organization_definitions ood
  WHERE  ood.organization_id = x_destination_org_id
  AND    ood.set_of_books_id = x_sob_id
  AND    sysdate < nvl(ood.disable_date, sysdate + 1);

  if (x_org_count = 0) then
    return (FALSE);
  else
    x_org_count := 0;
  end if;

  /* Now check item/org characteristics for predefined items.
  */
   /* Changes made due to Bug: 647379
  ** The Purchaseable attribute for destination type 'EXPENSE' need not be
  ** 'Y', if the source is not 'SUPPLIER'.
  ** Hence checking the code for destination type expense separately from Shopfl
oor destination
  */


  if (x_item_id is not null) then
    if (x_destination_type = 'INVENTORY') then

      /* If delivering to Inventory, the item need be Stockable always and purchaseable
      ** only if sourced from a vendor.  If sourced from stores,
      ** this is not a requirement.  If the source type is NULL
      ** at this point, the decode allows this SELECT to succeed.
      */

      x_progress := '020';

      SELECT count(1)
      INTO   x_org_count
      FROM   mtl_system_items msi
      WHERE  msi.organization_id = x_destination_org_id
      AND    msi.inventory_item_id = x_item_id
      AND    msi.stock_enabled_flag = 'Y'
      AND    decode(x_source_type, 'VENDOR', 'Y',
		  msi.purchasing_enabled_flag) = msi.purchasing_enabled_flag
      AND    (x_item_revision is null
	      OR
	      x_destination_org_id in
	      (SELECT mir.organization_id
     	       FROM   mtl_item_revisions mir
               WHERE  mir.inventory_item_id = x_item_id
	       AND    mir.revision = x_item_revision));

     elsif (x_destination_type = 'EXPENSE') then

      /* If delivering to Expense , the item need be Purchaseable
      ** only if sourced from a vendor.  If sourced from stores,
      ** this is not a requirement.  If the source type is NULL
      ** at this point, the decode allows this SELECT to succeed.
      */

       x_progress := '040';

       SELECT count(1)
       INTO   x_org_count
       FROM   mtl_system_items msi
       WHERE  msi.organization_id = x_destination_org_id
       AND    msi.inventory_item_id = x_item_id
       AND    decode(x_source_type, 'VENDOR', 'Y',
                  msi.purchasing_enabled_flag) = msi.purchasing_enabled_flag;
    else

      /* Check the  Shop Floor destinations.  This
      ** destination is always supported by purchase orders, so
      ** the items must be purchaseable and outside_operation_flag = 'Y'.
      */

      x_progress := '030';

      SELECT count(1)
      INTO   x_org_count
      FROM   mtl_system_items msi
      WHERE  msi.inventory_item_id = x_item_id
      AND    msi.organization_id = x_destination_org_id
      AND    msi.purchasing_enabled_flag = 'Y'
      AND    msi.outside_operation_flag = 'Y';
    end if;

    if (x_org_count = 0) then
      return (FALSE);
    end if;
  end if;

  return (TRUE);

exception

  when others then
    po_message_s.sql_error('val_dest_org', x_progress, sqlcode);
    raise;

end val_dest_org;

/*===========================================================================

 FUNCTION NAME :  val_source_org()

===========================================================================*/
function val_source_org(x_source_org_id       in number,
			x_destination_org_id  in number,
			x_destination_type    in varchar2,
			x_item_id             in number,
			x_item_revision	      in varchar2,
			x_sob_id	      in number,
		 	x_error_type	      in out NOCOPY varchar2) return boolean is

  x_progress       varchar2(3) := NULL;
  x_intransit_type number      := NULL;
  x_org_count      number      := 0;
--bug#3464868 creating a local variable
--to hold the value of internal_order_enabled_flag for
--the current item
  l_internal_ordered varchar2(1) := NULL;
begin

  /* Given that this function can yield two different failure
  ** types (each requiring a different error message), set an
  ** error type to tell the calling procedure how to handle
  ** a FALSE result.  The default case is an invalid organization.
  ** This is overwritten only if there is a problem with an item
  ** control mismatch in the source/destination orgs.
  */

  /* Ben: 4/3/97 bug#441341 We should not check the interorg transfers table when
          doing transfers within the same org, since this table will not have an entry
          for going from/to the same org.
  */

  IF x_source_org_id <> x_destination_org_id THEN

    x_error_type := 'INVALID_ORG';

    x_progress := '010';

    SELECT mip.intransit_type
    INTO   x_intransit_type
    FROM   org_organization_definitions ood,
	 mtl_system_items msi,
	 mtl_interorg_parameters mip
    WHERE  ood.organization_id = x_source_org_id
    AND    sysdate < nvl(ood.disable_date, sysdate + 1)
    AND	 mip.from_organization_id = x_source_org_id
    AND	 mip.to_organization_id = x_destination_org_id
    AND	 msi.organization_id = x_source_org_id
    AND    msi.inventory_item_id = x_item_id
    AND	 msi.internal_order_enabled_flag = 'Y'
    AND    msi.stock_enabled_flag = 'Y'
    AND    (x_item_revision is null
	  OR
	  x_source_org_id in
	  (SELECT mir.organization_id
     	   FROM   mtl_item_revisions mir
           WHERE  mir.inventory_item_id = x_item_id
	   AND    mir.revision = x_item_revision));

    x_progress := '020';

    if ((x_intransit_type = 1) and
      (x_destination_type = 'INVENTORY')) then

      /* For direct transfers (intransit type = 1), you cannot
      ** go from looser to tighter revision, lot, or serial
      ** control.
      */

      /* DEBUG -- need George to tell us if it is still a valid b-rule
      ** to check whether the rev is restricted as well for intransit
      ** shipments (intransit_type = 2) .  Spoke with Meg:  the problem
      ** from her understanding is NOT receiving -- we need to prevent
      ** passing a revision to OE.  This is what Req Import *should* be
      ** checking -- and Enter Reqs should prevent specifying a rev
      ** for inventory sourced lines.
      */

  /* Bug# 4446916, We need to allow for Source having serial control as
  * 'At Sales Order Issue' to destination having serial control as
  * 'At Receipt or Predefine'. Removed the 6( 'At Sales Order Issue') in code   *
  * -- (msi1.serial_number_control_code in (1,6) --
  */

      SELECT count(1)
      INTO   x_org_count
      FROM   mtl_system_items msi1,
  	   mtl_system_items msi2
      WHERE  msi1.inventory_item_id = x_item_id
      AND    msi1.organization_id = x_source_org_id
      AND    msi2.inventory_item_id = x_item_id
      AND    msi2.organization_id = x_destination_org_id
      AND    ((msi1.lot_control_code = 1 AND
             msi2.lot_control_code = 2)
             OR
             (msi1.serial_number_control_code in (1) AND
	      msi2.serial_number_control_code in (2,3,5))
	     OR
	     (msi1.revision_qty_control_code = 1 AND
	      msi2.revision_qty_control_code = 2));

      if (x_org_count = 1) then
        x_error_type := 'SRC_DEST_ORG_CONTROL_MISMATCH';
        return (FALSE);
      end if;
    end if;
-- bug#3464868 we need to check if the item is internally orderable
--when the source and destination organization id's are the same

  ELSIF (nvl(x_source_org_id,-1)=nvl(x_destination_org_id,-2)) THEN
    x_error_type := 'PO_RI_INT_ORD_NOT_ENABLED';

    SELECT 'Y'
    INTO   l_internal_ordered
    FROM   org_organization_definitions ood,
         mtl_system_items msi
    WHERE  ood.organization_id = x_source_org_id
    AND    sysdate < nvl(ood.disable_date, sysdate + 1)
    AND  msi.organization_id = x_source_org_id
    AND    msi.inventory_item_id = x_item_id
    AND  msi.internal_order_enabled_flag = 'Y'
    AND    msi.stock_enabled_flag = 'Y'
    AND    (x_item_revision is null
          OR
          x_source_org_id in
          (SELECT mir.organization_id
           FROM   mtl_item_revisions mir
           WHERE  mir.inventory_item_id = x_item_id
           AND    mir.revision = x_item_revision));

    x_progress := '022';
--bug#3464868

  END IF;
  return (TRUE);

exception
  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('val_source_org', x_progress, sqlcode);
    raise;

end val_source_org;

END PO_ORGS_SV2;

/

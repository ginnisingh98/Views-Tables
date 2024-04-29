--------------------------------------------------------
--  DDL for Package Body PO_SUBINVENTORIES_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SUBINVENTORIES_S2" as
/* $Header: POXCOS2B.pls 115.2 2002/11/25 23:37:48 sbull ship $*/

/*=========================== PO_SUBINVENTORIES_S2 =========================*/

/*===========================================================================

  FUNCTION NAME:	val_subinventory()

===========================================================================*/
function val_subinventory(x_dest_subinventory   in varchar2,
			  x_destination_org_id  in number,
			  x_source_type		in varchar2,
			  x_source_subinventory in varchar2,
			  x_source_org_id	in number,
			  x_transaction_date    in date,
			  x_item_id	        in number,
			  x_destination_type    in varchar2,
			  x_validation_type     in varchar2,
			  x_error_type		in out NOCOPY varchar2)
return boolean is

  x_progress          varchar2(3)  := NULL;
  x_sub_count         number       := 0;
  x_org_id            number       := NULL;
  x_subinventory      varchar2(30) := NULL;
  x_reservations      varchar2(1)  := NULL;
  x_allow_expense_sub varchar2(1)  := NULL;

begin

  /*
  ** If this function returns FALSE then
  ** the error type is used by the calling
  ** procedure to determine the message
  ** to be displayed. By default the message
  ** is set to 'INVALID_SUB'.
  */

   x_error_type := 'INVALID_SUB';

  /* Determine whether we should be validating the
  ** source or destination subinventories.
  */

  if (x_validation_type = 'DESTINATION') then
    x_org_id := x_destination_org_id;
    x_subinventory := x_dest_subinventory;

  elsif (x_validation_type = 'SOURCE') then
    x_org_id := x_source_org_id;
    x_subinventory := x_source_subinventory;

  end if;

  /* Check the common business rules that apply to both
  ** source and destination subinventories.
  */

  x_progress := '010';

  SELECT count(1)
  INTO   x_sub_count
  FROM   mtl_secondary_inventories msub,
	 mtl_system_items msi
  WHERE  msub.secondary_inventory_name = x_subinventory
  AND    msub.organization_id = x_org_id
  AND    x_transaction_date < nvl(msub.disable_date, x_transaction_date + 1)
  AND    msi.inventory_item_id = x_item_id
  AND	 msi.organization_id = x_org_id
  AND    (msi.restrict_subinventories_code = 2
          OR
	 (msi.restrict_subinventories_code = 1 and exists
	 (SELECT null
          FROM   mtl_item_sub_inventories mis
          WHERE  mis.organization_id = x_org_id
	  AND    mis.inventory_item_id = x_item_id
          AND    mis.secondary_inventory = x_subinventory)));

  if (x_sub_count = 0) then
    return (FALSE);
  else
    x_sub_count := 0;
  end if;

  /* Now check subinventory attributes that are unique to
  ** Inventory-sourced orders if we are performing source
  ** subinventory validation.
  */

  if ((x_validation_type = 'SOURCE') and
      (x_source_type = 'INVENTORY')) then

    /* If the source and destination orgs are the same, you cannot
    ** source and deliver to the same subinventory.  If the subs
    ** differ but the item is MRP planned, then the source subinventory
    ** must be non-nettable.
    */

    if ((x_source_org_id = x_destination_org_id) and
	(x_destination_type = 'INVENTORY')) then

      x_progress := '020';

      if (x_source_subinventory = x_dest_subinventory) then

        x_error_type := 'DEST_SUB_EQS_SRC_SUB';
        return (FALSE);

      elsif
          (po_subinventories_s2.val_mrp_src_sub(x_source_subinventory,
				                x_source_org_id,
				                x_destination_org_id,
				                x_item_id) = FALSE) then

        return (FALSE);
      end if;
    end if;

    /* Get the Order Entry reservations flag.  If
    ** this flag is set to 'Y', then the source
    ** subinventory must be reservable
    ** (reservable_type = 1).
    */

    x_progress := '030';
    fnd_profile.get('SO_RESERVATIONS', x_reservations);

    /* Ben: 2/13/97
    ** If order entry reservation is ON, then the source subinventory must
    ** be quantity-tracked (quantity_tracked=1) and reservable_type=1.
    ** Issue error message if that is not the case.
    */

    x_progress := '040';

    SELECT count(1)
    INTO   x_sub_count
    FROM   mtl_secondary_inventories msub
    WHERE  msub.secondary_inventory_name = x_source_subinventory
    AND    msub.organization_id = x_source_org_id
    AND    msub.quantity_tracked = 1
    AND    decode(x_reservations, 'Y', 1, msub.reservable_type)
			                = msub.reservable_type;

    IF x_sub_count = 0 THEN

       x_error_type := 'PO_RI_SRC_SUB_NOT_RESERVABLE';

       return(FALSE);
    END IF;

  end if; /* if ((x_validation_type = 'SOURCE')... */

  /* Now for internally sourced items going to inventory, check
  ** that the source and destination subinventories are valid based
  ** on their asset status in combination with the item's asset status
  ** in the source and destination orgs.
  */

  if (x_source_type = 'INVENTORY') then
    if ((x_source_subinventory is not null) and
        (x_source_org_id is not null) and
        (x_dest_subinventory is not null) and
        (x_destination_org_id is not null) and
        (x_destination_type = 'INVENTORY')) then

      if (po_subinventories_s3.val_expense_asset(x_item_id,
						 x_source_org_id,
						 x_source_subinventory,
						 x_destination_org_id,
						 x_dest_subinventory) = FALSE) then
        x_error_type := 'INVALID_EXP_ASSET_SUBS';
        return (FALSE);
      end if;
    end if;
  end if;

  return (TRUE);

exception
  when others then
    po_message_s.sql_error('val_subinventory', x_progress, sqlcode);
    raise;

end val_subinventory;


/*===========================================================================

  FUNCTION NAME:	val_mrp_src_sub()

===========================================================================*/
function val_mrp_src_sub(x_subinventory       in varchar2,
			 x_source_org_id      in number,
			 x_destination_org_id in number,
			 x_item_id	      in number) return boolean is

  x_progress  varchar2(3) := NULL;
  x_sub_count number      := 0;

begin

  /* If the source and destination organizations are the
  ** same, if the item is MRP planned, verify that the
  ** source subinventory is non-nettable.  If the
  ** mrp_planning_code is 3 or 4, the item is MRP planned
  ** and the subinventory availability type must = 2
  ** (non-nettable).
  */

  if (x_source_org_id = x_destination_org_id) then

    x_progress := '010';

    SELECT count(1)
    INTO   x_sub_count
    FROM   mtl_secondary_inventories msub,
	   mtl_system_items msi
    WHERE  msub.organization_id = x_source_org_id
    AND    msub.secondary_inventory_name = x_subinventory
    AND    msi.inventory_item_id = x_item_id
    AND    msi.organization_id = x_source_org_id
    AND    decode(msi.mrp_planning_code, '3', 2,
					 '4', 2, msub.availability_type)
					      = msub.availability_type;

    if (x_sub_count = 0) then
      return (FALSE);
    end if;
   end if;

  return (TRUE);

exception
  when others then
    po_message_s.sql_error('val_mrp_src_sub', x_progress, sqlcode);
    raise;
end val_mrp_src_sub;

END PO_SUBINVENTORIES_S2;

/

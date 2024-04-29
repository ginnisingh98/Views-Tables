--------------------------------------------------------
--  DDL for Package Body PO_SUBINVENTORIES_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SUBINVENTORIES_S3" as
/* $Header: POXCOS3B.pls 120.0.12010000.1 2008/09/18 12:20:55 appldev noship $*/

/*=========================== PO_SUBINVENTORIES_S3 =========================*/
/*===========================================================================

  FUNCTION NAME:	val_expense_asset ()

===========================================================================*/
function val_expense_asset(x_item_id		in number,
			   x_src_org_id		in number,
			   x_src_subinventory	in varchar2,
			   x_dest_org_id	in number,
			   x_dest_subinventory	in varchar2) return boolean is

  src_sub_asset_flag	number	     := null;
  src_item_asset_flag	varchar2(1)  := null;
  dest_sub_asset_flag	number	     := null;
  dest_item_asset_flag	varchar2(1)  := null;
  fob_point		number	     := null;
  intransit_type	number	     := null;
  progress		varchar2(3)  := null;

  CURSOR asset (x_subinventory in varchar2,
		x_org_id       in number,
		x_item_id      in number) is

    SELECT msub.asset_inventory,
           msi.inventory_asset_flag
    FROM   mtl_secondary_inventories msub,
	   mtl_system_items  	     msi
    WHERE  msub.secondary_inventory_name = x_subinventory
    AND	   msub.organization_id          = x_org_id
    AND	   msi.inventory_item_id	 = x_item_id
    AND	   msi.organization_id		 = x_org_id;

  CURSOR transfer is

    SELECT intransit_type,
           fob_point
    FROM   mtl_interorg_parameters
    WHERE  from_organization_id = x_src_org_id
    AND	   to_organization_id   = x_dest_org_id;

begin

  /* Identify whether the source  subinventory is asset or
  ** expense.  1 = Asset, 2 = Expense.  Also identify
  ** whether the item is an asset in the source org.
  ** Y = asset item, N = expense item.
  */

  progress := '10';

  open asset(x_src_subinventory,
	     x_src_org_id,
	     x_item_id);
  loop

    FETCH asset INTO src_sub_asset_flag,
		     src_item_asset_flag;

    exit when asset%NOTFOUND;
  end loop;
  close asset;

  /* Identify whether the destination subinventory is asset or
  ** expense.  1 = Asset, 2 = Expense.  Also identify
  ** whether the item is an asset in the destination org.
  ** Y = asset item, N = expense item.
  */

  progress := '20';

  open asset(x_dest_subinventory,
	     x_dest_org_id,
	     x_item_id);
  loop

    FETCH asset INTO dest_sub_asset_flag,
		     dest_item_asset_flag;

    exit when asset%NOTFOUND;
  end loop;
  close asset;

  /* Get the intransit type and FOB point for interorg
  ** transfers.  1 = Direct, 2 = Intransit.  1 = FOB
  ** Shipment, 2 = FOB Receipt.
  */

  progress := '30';

  open transfer;
  loop

    FETCH transfer INTO intransit_type,
			fob_point;

    exit when transfer%NOTFOUND;
  end loop;
  close transfer;

  /* Now call the routine that checks whether the item/sub
  ** combination is valid.
  */

  progress := '40';

  if (val_expense_asset(x_item_id,
			src_sub_asset_flag,
			src_item_asset_flag,
			dest_sub_asset_flag,
			dest_item_asset_flag,
			fob_point,
			intransit_type) = FALSE) then
    return (FALSE);
  else
    return (TRUE);
  end if;

exception
  when others then
    po_message_s.sql_error('val_expense_asset', progress, sqlcode);
    raise;

end val_expense_asset;

function val_expense_asset(x_item_id	          in number,
			   x_src_sub_asset_flag   in number,
			   x_src_item_asset_flag  in varchar2,
			   x_dest_sub_asset_flag  in number,
			   x_dest_item_asset_flag in varchar2,
			   x_fob_point		  in number,
			   x_intransit_type	  in number) return boolean is

  valid_combination boolean := TRUE;

begin

  /* Note:  key inventory values:
  **
  ** subinventory asset:  1 = Asset, 2 = Expense
  **
  ** item asset:	  Y = Asset, N = Expense
  **
  ** intransit type:	  1= Direct, 2 = Intransit
  **
  ** fob point:		  1 = Shipment, 2 = Receipt
  **
  */

  /* You are performing a direct transfer (fob is
  ** irrelevant).
  **
  ** Invalid combinations:  source item = asset
  **			    to item     = asset
  **			    source sub  = expense
  **			    to sub      = asset
  **
  **			    source item = expense
  **			    to item     = asset
  **			    to sub      = asset
  */

  if (x_intransit_type = 1) then
    if (((x_src_item_asset_flag = 'Y') and
         (x_dest_item_asset_flag = 'Y') and
         (x_src_sub_asset_flag = 2) and
         (x_dest_sub_asset_flag = 1)) or
        ((x_src_item_asset_flag = 'N') and
         (x_dest_item_asset_flag = 'Y') and
         (x_dest_sub_asset_flag = 2))) then
         valid_combination := FALSE;
      end if;

  /* You are performing an instrasit transfer
  ** with an fob point of origin (1 = Shipment).
  **
  ** Invalid combinations:  source item = expense
  **			    to item     = asset
  **
  **			    source item = asset
  **			    to item     = asset
  **			    from sub    = expense
  */

  elsif (x_fob_point = 1) then
    if (((x_src_item_asset_flag = 'Y') and
         (x_dest_item_asset_flag = 'N') and
         (x_src_sub_asset_flag = 2)) or
        ((x_src_item_asset_flag = 'N') and
         (x_dest_item_asset_flag = 'Y'))) then
        valid_combination := FALSE;
    end if;

  /* You are performing an intransit transfer
  ** with an fob point of destination (2 = Receipt).
  **
  ** Invalid combinations:  source item = asset
  **			    source sub  = expense
  **
  **			    source item = expense
  **			    to item     = asset
  **			    to sub      = asset
  */
  /* Bug : 711688
  ** Changed x_dest_sub_asset_flag to x_src_sub_asset_flag.
  ** As per the comments above, the invalid combination is
  ** source item = asset and source sub = expense  */

  elsif (x_fob_point = 2) then
    if (((x_src_item_asset_flag = 'Y') and
         (x_src_sub_asset_flag = 2)) or
        ((x_src_item_asset_flag = 'N') and
         (x_dest_item_asset_flag = 'Y') and
         (x_dest_sub_asset_flag = 1))) then
        valid_combination := FALSE;
    end if;
  end if;

  return (valid_combination);

end val_expense_asset;

END PO_SUBINVENTORIES_S3;

/

--------------------------------------------------------
--  DDL for Package Body PO_UOM_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UOM_SV2" as
/* $Header: RCVTXUOB.pls 120.0.12000000.4 2007/10/18 14:01:22 grohit ship $*/

/*=============================  PO_UOM_SV2  ==============================*/
/*===========================================================================

 FUNCTION NAME :  convert_inv_cost()

===========================================================================*/
function convert_inv_cost(x_item_id          in     number,
			  x_current_uom	     in     varchar2,
			  x_primary_uom	     in     varchar2,
			  x_primary_inv_cost in     number,
			  x_result_price     in out NOCOPY number) return boolean is

  convert_rate       number        := null;
  progress           varchar2(30)  := null;
  current_code	     varchar2(3)   := null;
  primary_code	     varchar2(3)   := null;

begin

  /* If the inventory price is zero or the primary UOM the
  ** the current user's UOM are the same, there is no reason
  ** to call the inventory convert routine.
  */

  if ((x_primary_inv_cost = 0) or
      (x_current_uom = x_primary_uom) or
      (x_primary_inv_cost is null)) then

    return (FALSE);

  else

    /* Get the uom conversion rate between 2 UOMs for
    ** a given item.  We need to obtain the code for
    ** the unit that we use in PO since Inventory's
    ** routine expects to get the code.
    */
    progress := '005';

    SELECT uom_code
    INTO   primary_code
    FROM   mtl_units_of_measure
    WHERE  unit_of_measure = x_primary_uom;

    progress := '006';

    /*
       Bug 2810994
       In the SELECT statement, changed mtl_units_of_measure to mtl_units_of_measure_vl
       and unit_of_measure to unit_of_measure_tl to handle translated values
    */
    /* 4718263 changed where condtion of the below SQL: in place of unit_of_measure_tl unit_of_measure should be used.
     from the Form we always pass unit_of_measure value not the translated value. */
    SELECT uom_code
    INTO   current_code
    FROM   mtl_units_of_measure_vl
    WHERE  unit_of_measure = x_current_uom;

    progress := '010';
    inv_convert.inv_um_conversion(primary_code,
				  current_code,
				  x_item_id,
				  convert_rate);

    x_result_price := round((x_primary_inv_cost/
			     convert_rate), 5);

    return (TRUE);

  end if;

  return (FALSE);

exception

  when others then
    po_message_s.sql_error('convert_inv_cost', progress, sqlcode);
    raise;

end convert_inv_cost;

/*===========================================================================

 FUNCTION NAME :  convert_quantity()

===========================================================================*/
function convert_quantity(x_item_id           in number,
			  x_source_org_id     in number,
			  x_order_quantity    in number,
			  x_order_uom         in varchar2,
			  x_result_quantity   in out NOCOPY number,
			  x_rounding_factor   in out NOCOPY number,
			  x_unit_of_issue     in out NOCOPY varchar2,
			  x_error_type        in out NOCOPY varchar2) return boolean is

  x_progress varchar2(3) := NULL;

begin

  /* Select the unit of issue and rounding factor for the
  ** soure organization and internally ordered item.
  */

  x_progress := '010';

  SELECT nvl(msi.unit_of_issue, NULL),
	 nvl(msi.rounding_factor, NULL)
  INTO	 x_unit_of_issue,
	 x_rounding_factor
  FROM   mtl_system_items msi
  WHERE  msi.inventory_item_id = x_item_id
  AND 	 msi.organization_id   = x_source_org_id;

  if ((x_unit_of_issue is null) or
      (x_rounding_factor is null) or
      (x_order_uom = x_unit_of_issue)) then

    x_error_type := 'CONVERT_NOT_REQUIRED';
    return (FALSE);

  end if;

  /* Call the UOM conversion routine to change the order quantity/order UOM
  ** into the unit of issue quantity/UOM.
  */

  x_progress := '020';

  x_result_quantity := inv_convert.inv_um_convert(x_item_id,
			 /* Precision */          10,
			                          x_order_quantity,
			 /* UOM Code */           NULL,
			 /* UOM Code */           NULL,
    		                           	  x_order_uom,
			                          x_unit_of_issue);

  /* A null result probably indicates bad data, and should
  ** be handled by the client.
  */

  if (x_result_quantity is null) then
    x_error_type := 'INV_UM_CONVERT_FAIL';
    return (FALSE);
  else
    return (TRUE);
  end if;

exception

  when others then
    po_message_s.sql_error('convert_quantity', x_progress, sqlcode);
    raise;

end convert_quantity;

PROCEDURE reqimport_convert_uom_qty (x_request_id in NUMBER ) IS

/* Bug#2470849, This procedure is called from Reqimport and it converts
the uom to the unit_of_issue of the Source uom and also rounds the quantity
depending on the rounding factor */

CURSOR inv_items IS

    select pri.rowid,
           pri.item_id,
           uomd.uom_code pri_uom_code,
           uoms.uom_code issue_uom_code,
           pri.quantity,
           pri.source_organization_id,
           pri.unit_of_measure,
           msi.unit_of_issue,
           msi.rounding_factor
    from po_requisitions_interface pri,
         mtl_system_items msi,
         mtl_units_of_measure uoms,
         mtl_units_of_measure uomd
    where msi.inventory_item_id = pri.item_id
      AND msi.organization_id   = pri.source_organization_id
      AND uoms.unit_of_measure = msi.unit_of_issue
      AND uomd.unit_of_measure = pri.unit_of_measure
      AND msi.unit_of_issue is NOT NULL
      AND pri.source_type_code = 'INVENTORY'
      AND pri.item_id is not NULL
      AND pri.source_organization_id is NOT NULL
      AND pri.unit_of_measure is NOT NULL
      AND pri.quantity > 0
      AND pri.request_id = x_request_id;

CURSOR Enforce_full_lot IS
     select enforce_full_lot_quantities
       from po_system_parameters;

x_quantity NUMBER;
x_round_quantity NUMBER;
remainder NUMBER;
x_rowid VARCHAR2(100);
x_enforce_full_lot_quantities VARCHAR2(30);

BEGIN
   OPEN  Enforce_full_lot;
   FETCH Enforce_full_lot into x_enforce_full_lot_quantities;
   if nvl(x_enforce_full_lot_quantities,'NONE') = 'NONE' then
        CLOSE Enforce_full_lot;
        return;
   End if;
   CLOSE Enforce_full_lot;
/* Bug# 3105048, Move the Close Cursor down. It was before the if
   and in case enforce_full_lot_quantities was other than NULL or NONE we
   would be closing the Cursor Twice which will lead to Invalid Cursor
   Error. */

   /* If enforce_full_lot_quantities is MANDATORY or ADVISORY then
      execute the Code below. 'Advisory' will be treated as 'Mandatory'
      for Requisitions created from Reqimport as per discussion with PM */

   FOR pri_inv IN inv_items LOOP

      /* Need to do the conversion only if the unit_of_issue and
         unit_of_measure are different */

      IF  pri_inv.unit_of_measure <> pri_inv.unit_of_issue then

             x_quantity:= inv_convert.inv_um_convert(pri_inv.item_id,
                                          10,
                                          pri_inv.quantity,
                                          pri_inv.pri_uom_code,
                                          pri_inv.issue_uom_code,
                                          pri_inv.unit_of_measure,
                                          pri_inv.unit_of_issue);
       ELSE
             x_quantity := pri_inv.quantity;

       END IF;

      /* if x_quantity is  = -99999 then the inv api returned a Error
         so don't process the row */

      if nvl(x_quantity,-99999) <> -99999
           and pri_inv.rounding_factor is NOT NULL then

    	if (x_quantity < 1) then
      	     remainder := x_quantity;
    	else
      	     remainder := mod(x_quantity, trunc(x_quantity));
    	end if;
    	if (remainder >= pri_inv.rounding_factor) then
      	     x_round_quantity := trunc(x_quantity) + 1;
    	elsif (remainder < pri_inv.rounding_factor) then
      	     x_round_quantity := trunc(x_quantity);
    	end if;

    	update po_requisitions_interface
          set (uom_code,
               unit_of_measure,
               quantity )= (Select pri_inv.issue_uom_code,
                                   pri_inv.unit_of_issue,
                                   x_round_quantity
                             from  sys.dual)
    	where   rowid= pri_inv.rowid;

      end if;

   END LOOP;
END reqimport_convert_uom_qty;


END PO_UOM_SV2;

/

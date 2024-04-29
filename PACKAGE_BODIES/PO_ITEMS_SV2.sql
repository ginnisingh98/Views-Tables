--------------------------------------------------------
--  DDL for Package Body PO_ITEMS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ITEMS_SV2" as
/* $Header: POXCOI2B.pls 120.0.12010000.2 2014/05/19 11:07:46 vthevark ship $ */
/*=============================  PO_ITEMS_SV2  ===============================*/

/*===========================================================================

  PROCEDURE NAME:	get_item_details()

===========================================================================*/
 procedure get_item_details( X_item_id                     IN     NUMBER,
                             X_inventory_organization_id   IN     NUMBER,
                             X_planned_item_flag           IN OUT NOCOPY VARCHAR2,
                             X_outside_operation_flag      IN OUT NOCOPY VARCHAR2,
                             X_outside_op_uom_type         IN OUT NOCOPY VARCHAR2,
                             X_invoice_close_tolerance     IN OUT NOCOPY NUMBER,
                             X_receive_close_tolerance     IN OUT NOCOPY NUMBER,
                             X_receipt_required_flag       IN OUT NOCOPY VARCHAR2,
                             X_stock_enabled_flag          IN OUT NOCOPY VARCHAR2,
			     X_internal_orderable	   IN OUT NOCOPY VARCHAR2,
			     X_purchasing_enabled	   IN OUT NOCOPY VARCHAR2,
			     X_inventory_asset_flag	   IN OUT NOCOPY VARCHAR2,
                             /* INVCONV BEGIN PBAMB */
                             X_secondary_default_ind	   IN OUT NOCOPY VARCHAR2,
    	                     X_grade_control_flag	   IN OUT NOCOPY VARCHAR2,
                             X_secondary_unit_of_measure   IN OUT NOCOPY VARCHAR2
                             /* INVCONV END PBAMB */) IS

      X_Progress    varchar2(3) := '';

 begin

      X_Progress := '010';
/*Bug 979118
  If the item's MRP Planning codes are (MRP/DRP-7
                                        MPS/DRP-8
                                        DRP    -9) then the item should be
  considered as a planned item.Prior to the fix items with planning codes
  MRP(3) and MPS(4) only were considered as a planned item.
*/

      SELECT  decode(msi.mrp_planning_code, 3,'Y',4,'Y',7,'Y',8,'Y',9,'Y',
              decode(msi.inventory_planning_code,1,'Y',2,'Y', 'N')),
              msi.outside_operation_flag ,
              msi.outside_operation_uom_type,
              msi.invoice_close_tolerance,
              receive_close_tolerance,
              msi.receipt_required_flag,
              nvl(msi.stock_enabled_flag,'N'),
              nvl(msi.internal_order_enabled_flag,'N'),
	      nvl(msi.purchasing_enabled_flag,'N'),
	      msi.inventory_asset_flag,
              decode(msi.tracking_quantity_ind,'PS',msi.secondary_default_ind,NULL),
 	      msi.grade_control_flag,
              decode(msi.tracking_quantity_ind,'PS',mum.unit_of_measure,NULL)
     INTO     X_planned_item_flag          ,
              X_outside_operation_flag     ,
              X_outside_op_uom_type        ,
              X_invoice_close_tolerance    ,
              X_receive_close_tolerance    ,
              X_receipt_required_flag      ,
              X_stock_enabled_flag	   ,
	      X_internal_orderable	   ,
	      X_purchasing_enabled	   ,
	      X_inventory_asset_flag       ,
	      /* INVCONV BEGIN PBAMB */
	      X_secondary_default_ind	   ,
              X_grade_control_flag	   ,
              X_secondary_unit_of_measure
              /* INVCONV END PBAMB */
     FROM   mtl_system_items msi , mtl_units_of_measure   mum
     WHERE  inventory_item_id = X_item_id
     AND    organization_id   = X_inventory_organization_id
     AND    mum.uom_code(+) = msi.secondary_uom_code;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN
          null;

     WHEN OTHERS THEN

         po_message_s.sql_error('get_item_details', X_progress, sqlcode);
         raise;

 end get_item_details;

 /*===========================================================================

  PROCEDURE NAME:	get_item_status

 ===========================================================================*/


 procedure get_item_status( X_item_id                      IN     NUMBER,
                            X_ship_org_id                  IN     NUMBER,
                            X_item_status                  IN OUT NOCOPY VARCHAR2) is
   X_Progress   varchar2(3) := NULL;

 begin
       X_Progress := '010';

       /* item_status values:
       ** 'O'  =  outside processing item
       ** 'E'  =  item stockable in the org
       ** 'D'  =  item defined but not stockable in org
       ** null =  item not defined in org   */

       X_item_status := '';

     /* 714670 - SVAIDYAN: If item id is null, return D for item status */

       IF (X_item_id is null) THEN
           X_item_status := 'D';
           return;
       END IF;

       SELECT decode(msi.outside_operation_flag,'Y','O',
              decode(msi.stock_enabled_flag,'Y','E','D'))
       INTO   X_item_status
       FROM   mtl_system_items msi
       WHERE  msi.organization_id   = X_ship_org_id
       AND    msi.inventory_item_id = X_item_id;


 exception
          when no_data_found then
               null;

          when others then
               po_message_s.sql_error('get_item_status',X_progress,to_char(sqlcode));
               raise;
 end get_item_status;


/*===========================================================================

  PROCEDURE NAME:	get_latest_item_rev

===========================================================================*/

/*
**   Get the latest implementation of an item rev
*/
PROCEDURE get_latest_item_rev (X_item_id         IN NUMBER,
                               X_organization_id IN NUMBER,
                               X_item_revision   IN OUT NOCOPY VARCHAR2,
                               X_rev_exists      OUT NOCOPY BOOLEAN) IS

X_progress       	     VARCHAR2(4)  := '000';

BEGIN

    X_item_revision := NULL;
    X_progress      := '700';
    /*
    ** Go get the latest item revision based on effectivity.
    ** Debug: Isn't there another function that we could use to do
    ** this
    */
    SELECT max(mir.revision)    -- Bug 448708 (a no of revisions could have same effective date
    INTO   X_item_revision      --             thus returning more than 1 row and causing errors
    FROM   mtl_item_revisions mir  --          Use max to return the maximum revision num)
    WHERE  mir.organization_id = X_organization_id
    AND    mir.inventory_item_id = X_item_id
    AND    mir.effectivity_date in
       (SELECT MAX(mir2.effectivity_date)
	FROM   mtl_item_revisions mir2
	WHERE  mir2.organization_id = X_organization_id
        AND    mir2.inventory_item_id = X_item_id
        /* Bug 1407438 - Filtering revisions which are not effective on current
           date and also those which are not implemented */
	AND    mir2.effectivity_date <= SYSDATE
	AND    mir2.implementation_date is not NULL);

       /*END Bug 1407438*/
    --dbms_output.put_line ('get_latest_item_rev: rev : ' || X_item_revision);

    X_rev_exists := TRUE;

    RETURN;
    /*
    ** If no rows were found then you have to bail out since the
    ** transaction cannot be processed
    */
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       --dbms_output.put_line ('A default item rev does not exist');
       X_rev_exists := FALSE;

    WHEN OTHERS THEN
       po_message_s.sql_error('get_latest_item_rev', x_progress, sqlcode);
    RAISE;

END get_latest_item_rev;

/*===========================================================================

  FUNCTION NAME:	val_item_rev_controls

===========================================================================*/
/*
** get the item revision control flag and if needed, try
** to get the most up-to-date revision.
** You only need to check for item rev if you're doing an
** express receipt/delivery for an inventory final destination
*/
FUNCTION val_item_rev_controls (
X_transaction_type      IN VARCHAR2,
X_auto_transact_code    IN VARCHAR2,
X_po_line_location_id   IN NUMBER,
X_shipment_line_id      IN NUMBER,
X_to_organization_id    IN NUMBER,
X_destination_type_code IN VARCHAR2,
X_item_id               IN NUMBER,
X_item_revision         IN VARCHAR2)
RETURN BOOLEAN IS

transaction_ok               BOOLEAN := FALSE;
inventory_receipt            BOOLEAN := FALSE;
X_item_rev_control           NUMBER  := 2;
default_item_revision        VARCHAR2(4) := '0';
X_progress 	             VARCHAR2(4) := '000';
item_rev_exists              BOOLEAN := FALSE;

BEGIN

   /*
   ** Check if any distributions for this receipt are destined for
   ** inventory.  If so then you need to check that there is a
   ** revision.  This is only for express receipts.  For express deliveries
   ** you can base it on the destination type
   */
   IF (X_transaction_type = 'RECEIVE') THEN

      inventory_receipt := rcv_transactions_sv.val_if_inventory_destination (
         X_po_line_location_id,
         X_shipment_line_id);
   ELSE
      /*
      ** If this is an express delivery then check the destination type
      ** of the transaction top determine the destination type
      */
      IF (X_destination_type_code = 'INVENTORY') THEN
         inventory_receipt := TRUE;
      END IF;

   END IF;

   IF (inventory_receipt) THEN
      --dbms_output.put_line ('val_rev_control : inventory_receipt : TRUE');
      null;
   ELSE
      --dbms_output.put_line ('val_rev_control : inventory_receipt : FALSE');
      null;
   END IF;

    /* Only check item rev control if the final destination is inventory */
    IF (NOT inventory_receipt) THEN
       transaction_ok := TRUE;

    ELSE

       /* Can only check the rev control if you have and item id */

       IF (X_item_id IS NOT NULL) THEN

	  X_progress := 400;

          SELECT msi.revision_qty_control_code
          INTO   X_item_rev_control
          FROM   mtl_system_items_kfv msi
          WHERE  X_item_id = msi.inventory_item_id
          AND    X_to_organization_id = msi.organization_id;

/* Express transactions were erroring out when item revision control was 1 and
   when default revision was used. This is because the code expects no revision
   when item_revision_control is 1 .  As default revision can be used for a
   a non -revision controlled item ,modified the code to check if the
   revision provided is default revision for a non-revision controlled item.
   For Bug 2058582 */
           -- Bug 18725461 : We need to honor the revision in the PO as default revision can be changes after PO creation.

           Select item_revision
           into   default_item_revision
           from   po_lines_all pl, po_line_locations_all pll
           where  pl.po_line_id = pll.po_line_id
           and    pll.line_location_id = X_po_line_location_id;

       ELSE
          /*
          ** If there is no item id then there should not be an item rev
          */
	  X_item_rev_control := 1;

       END IF;

/*
       dbms_output.put_line ('val_rev_control : X_item_rev_control : ' ||
	   to_char(X_item_rev_control));

       dbms_output.put_line ('val_rev_control :item_rev : ' ||
	   X_item_revision);
*/

       /* If the trx is still not ok then do the main check on the rev */
       IF (NOT transaction_ok) THEN

          /* Check to see that the control matches the item rev setting */
          IF (X_item_rev_control = 1 AND X_item_revision IS NULL) OR
             (X_item_rev_control =1 AND X_item_revision = default_item_revision)                     OR
	     (X_item_rev_control = 2 AND X_item_revision IS NOT NULL) OR
             (X_item_rev_control NOT IN (1,2)) THEN
             transaction_ok := TRUE;
          END IF;

      END IF;

   END IF;

   RETURN transaction_ok;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_item_rev_controls', x_progress, sqlcode);
   RAISE;

END val_item_rev_controls;


/*===========================================================================

  PROCEDURE NAME:	get_item_cost

===========================================================================*/

PROCEDURE get_item_cost (x_item_id   		 IN  NUMBER,
		        x_organization_id	 IN  NUMBER,
			x_inv_cost		 OUT NOCOPY NUMBER)
IS

x_progress  VARCHAR2(3) := NULL;

BEGIN

   /*
   ** Obtain the standard cost.
   */

   x_progress := '010';

   SELECT cic.item_cost
   INTO   x_inv_cost
   FROM   cst_item_costs_for_gl_view cic
   WHERE  cic.inventory_item_id = x_item_id
   AND    cic.organization_id   = x_organization_id;


 EXCEPTION
 WHEN NO_DATA_FOUND THEN
      x_inv_cost := 0;

 WHEN OTHERS THEN
      --dbms_output.put_line('In exception');
      po_message_s.sql_error('get_item_cost',
			      x_progress, sqlcode);
      raise;
END get_item_cost;

END PO_ITEMS_SV2;


/

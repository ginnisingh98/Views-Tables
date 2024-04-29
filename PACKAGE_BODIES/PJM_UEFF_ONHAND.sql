--------------------------------------------------------
--  DDL for Package Body PJM_UEFF_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_UEFF_ONHAND" AS
/* $Header: PJMUEOHB.pls 120.1 2006/02/10 14:44:38 exlin noship $ */
--
--  Name          : Onhand_Quantity
--  Pre-reqs      : None
--  Function      : This function returns onhand quantity for a specific
--                  unit number and item/org/rev/subinv/locator/lot that
--                  matches the unit number on the OE line
--
--
--  Parameters    :
--  IN            : X_source_line                   NUMBER
--                  X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--                  X_revision                      VARCHAR2
--                  X_subinventory                  VARCHAR2
--                  X_locator_id                    NUMBER
--                  X_lot_number                    VARCHAR2
--		    X_lpn_id			    NUMBER      BUG fix 2752979
--		    X_cost_group_id		    NUMBER      BUG fix 2752979
--
--
--  Returns       : NUMBER
--
FUNCTION Onhand_Quantity
( X_source_line                   IN     NUMBER
, X_item_id                       IN     NUMBER
, X_organization_id               IN     NUMBER
, X_revision                      IN     VARCHAR2
, X_subinventory                  IN     VARCHAR2
, X_locator_id                    IN     NUMBER
, X_lot_number                    IN     VARCHAR2
, X_lpn_id                        IN     NUMBER
, X_cost_group_id                 IN     NUMBER
) RETURN NUMBER IS

  L_quantity     NUMBER;
  L_unit_number  PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE;

BEGIN

   L_quantity := 0;  -- BUG fix 2752979

   if ( pjm_unit_eff.enabled = 'N' ) then
      return ( 0 );
   end if;

   if ( pjm_unit_eff.unit_effective_item
                    ( X_item_id, X_organization_id ) = 'N' ) then
      return ( 0 );
   end if;

   L_unit_number := PJM_UNIT_EFF.OE_Line_Unit_Number_Cached(X_source_line);
 --Bug #4726150
   --For requisition move orders, unit number is mandatory for unit effective items
   --and hence we need to use this table to derive l_unit_number
   IF (l_unit_number IS NULL) THEN
     BEGIN
       SELECT unit_number
       INTO   l_unit_number
       FROM   mtl_txn_request_lines_v
       WHERE  line_id = x_source_line
       AND    move_order_type = 1;
     EXCEPTION
       WHEN OTHERS THEN
         l_unit_number := NULL;
     END;
   END IF;
 --- End Bug #4726150

   SELECT count(*)
   INTO   L_quantity
   FROM   mtl_serial_numbers msn
   WHERE  msn.current_status = 3
   AND    msn.inventory_item_id = X_item_id
   AND    msn.current_organization_id = X_organization_id
   AND    msn.current_subinventory_code = X_subinventory
   AND    nvl(msn.current_locator_id,-3113) = nvl(X_locator_id,-3113)
   AND    nvl(msn.revision,'!@$') = nvl(X_revision,'!@$')
   AND    nvl(msn.lot_number,'!@$') = nvl(X_lot_number,'!@$')
   AND    nvl(msn.end_item_unit_number,'!@$') = nvl(L_unit_number,'!@$')
   AND    nvl(msn.lpn_id, -3113) = nvl(X_lpn_id, -3113)       			-- BUG fix 2752979
   AND    nvl(msn.cost_group_id, -3113) = nvl(X_cost_group_id, -3113);   	-- BUG fix 2752979

   return ( L_quantity );

EXCEPTION
   when others then
       return ( 0 );

END Onhand_Quantity;


--
--  Name          : Txn_Quantity
--  Pre-reqs      : None
--  Function      : This function returns transaction quantity for a specific
--                  transaction that matches the unit number on the OE line
--
--
--  Parameters    :
--  IN            : X_source_line                   NUMBER
--                  X_trx_temp_id                   NUMBER
--                  X_lot_number                    NUMBER
--
--  Returns       : NUMBER
--
FUNCTION Txn_Quantity
( X_source_line                   IN     NUMBER
, X_trx_temp_id                   IN     NUMBER
, X_lot_number                    IN     VARCHAR2
, X_Fetch_From_DB                 IN     VARCHAR2
, X_item_id                       IN     NUMBER
, X_organization_id               IN     NUMBER
, X_src_type_id                   IN     NUMBER
, X_trx_src_id                    IN     NUMBER
, X_rcv_trx_id                    IN     NUMBER
, X_trx_sign                      IN     NUMBER
, X_trx_src_line_id               IN     NUMBER
) RETURN NUMBER IS

  L_item_id           NUMBER;
  L_organization_id   NUMBER;
  L_src_type_id       NUMBER;
  L_trx_src_id        NUMBER;
  L_trx_src_line_id   NUMBER;
  L_rcv_trx_id        NUMBER;
  L_trx_qty           NUMBER;
  L_trx_sign          NUMBER;
  L_unit_number       PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE;

BEGIN

   if ( pjm_unit_eff.enabled = 'N' ) then
      return ( NULL );
   end if;

   if ( X_Fetch_From_DB = 'Y' ) then

     SELECT inventory_item_id
     ,      organization_id
     ,      transaction_source_type_id
     ,      transaction_source_id
     ,      trx_source_line_id
     ,      rcv_transaction_id
     ,      sign(primary_quantity)
     INTO   L_item_id
     ,      L_organization_id
     ,      L_src_type_id
     ,      L_trx_src_id
     ,      L_trx_src_line_id
     ,      L_rcv_trx_id
     ,      L_trx_sign
     FROM   mtl_material_transactions_temp
     WHERE  transaction_temp_id = X_trx_temp_id;

   else

     L_item_id         := X_item_id;
     L_organization_id := X_organization_id;
     L_src_type_id     := X_src_type_id;
     L_trx_src_id      := X_trx_src_id;
     L_trx_src_line_id := X_trx_src_line_id;
     L_rcv_trx_id      := X_rcv_trx_id;
     L_trx_sign        := X_trx_sign;

   end if;

   if ( pjm_unit_eff.unit_effective_item
                    ( L_item_id, L_organization_id ) = 'N' ) then
      return ( NULL );
   end if;

   L_unit_number := PJM_UNIT_EFF.OE_Line_Unit_Number_Cached(X_source_line);

   if ( L_src_type_id = 5 ) then

      --
      -- Transaction Source is WIP; get the unit number from the WIP header
      --
      if ( L_unit_number =
	   PJM_UNIT_EFF.WIP_Unit_Number(L_trx_src_id, L_organization_id) ) then
         return ( NULL );  -- NULL means quantity from transaction
      else
         return ( 0 );
      end if;

   elsif ( L_src_type_id in (1, 7) ) then

      --
      -- Transaction Source is PO/Internal Req; get the unit number from PO
      -- distribution or PO req distribution through RCV transaction
      --
      if ( L_unit_number = PJM_UNIT_EFF.RCV_Unit_Number(L_rcv_trx_id) ) then
         return ( NULL );  -- NULL means quantity from transaction
      else
         return ( 0 );
      end if;

   else

      --
      -- Bug 2752979
      --
      -- If the transaction source is a sales order line, there may or
      -- may not be corresponding serial number records; if so, then
      -- consider the entire transaction to be against a single unit
      -- number (stamped on the sales order line)
      --
      if ( L_src_type_id = 2 and L_trx_src_line_id is not null ) then

        SELECT count(fm_serial_number)
        INTO   L_trx_qty
        FROM   mtl_serial_numbers_temp msnt
        WHERE  msnt.transaction_temp_id in (
          SELECT X_trx_temp_id FROM dual
          UNION ALL
          SELECT serial_transaction_temp_id
          FROM   mtl_transaction_lots_temp
          WHERE  transaction_temp_id = X_trx_temp_id )
        AND    rownum = 1;

        if ( L_trx_qty = 0 ) then
          if ( L_unit_number =
                 PJM_UNIT_EFF.OE_Line_Unit_Number_Cached(L_trx_src_line_id) ) then
            return ( NULL );  -- NULL means quantity from transaction
          else
            return ( 0 );
          end if;
        end if;
      end if;

      --
      -- Transaction Source is other; get the unit number quantity from the
      -- transaction serials
      --
      SELECT count(*) * L_trx_sign
      INTO   L_trx_qty
      FROM   mtl_serial_numbers_temp msnt
      ,      mtl_serial_numbers msn
      WHERE  msnt.transaction_temp_id in (
        SELECT X_trx_temp_id FROM dual
        UNION ALL
        SELECT serial_transaction_temp_id
        FROM   mtl_transaction_lots_temp
        WHERE  transaction_temp_id = X_trx_temp_id )
      AND    msn.serial_number >= msnt.fm_serial_number
      AND    msn.serial_number <= nvl(msnt.to_serial_number , msnt.fm_serial_number)
      AND    length(msn.serial_number) = length(msnt.fm_serial_number)
      AND    msn.inventory_item_id = L_item_id
      AND    nvl(msn.lot_number,'!@$') = nvl(X_lot_number,'!@$')
      AND    msn.end_item_unit_number = L_unit_number;

      return ( L_trx_qty );

   end if;

EXCEPTION
   when others then
       return ( NULL );

END Txn_Quantity;

END;

/

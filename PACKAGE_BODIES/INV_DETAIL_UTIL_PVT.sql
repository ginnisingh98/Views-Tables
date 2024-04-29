--------------------------------------------------------
--  DDL for Package Body INV_DETAIL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DETAIL_UTIL_PVT" AS
/* $Header: INVVDEUB.pls 120.16.12010000.8 2010/04/22 09:40:12 kjujjuru ship $ */
--
-- File        : INVVDEUB.pls
-- Content     : INV_DETAIL_UTIL_PVT package body
-- Description : utlitities used by the detailing engine (both inv and wms versions)
-- Notes       :
-- Modified    : 10/22/99 bitang created
-- Modified    : 04/04/2002 grao bug# 228645
-- Package name used in error messages
--
g_pkg_name VARCHAR2(30) := 'INV_DETAIL_UTIL_PVT';
g_version_printed BOOLEAN := FALSE;
--
TYPE g_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--
-- The following types are used to define plsql tables for
-- inserting into transaction temporary tables
TYPE g_mmtt_tbl_type IS TABLE OF mtl_material_transactions_temp%ROWTYPE
  INDEX BY BINARY_INTEGER;
TYPE g_mtlt_tbl_type IS TABLE OF mtl_transaction_lots_temp%ROWTYPE
  INDEX BY BINARY_INTEGER;
TYPE g_msnt_tbl_type IS TABLE OF mtl_serial_numbers_temp%ROWTYPE
  INDEX BY BINARY_INTEGER;
--

--Cache for function is_sub_loc_lot_trx_allowed
g_isllta_subinventory_code    VARCHAR2(10);
g_isllta_locator_id    NUMBER;
g_isllta_lot_number    VARCHAR2(80);
g_lot_return      VARCHAR2(1);
g_sub_return      VARCHAR2(1);
g_loc_return      VARCHAR2(1);
g_isllta_transaction_type_id NUMBER;

-- Globals added for performance
g_transaction_uom_code  VARCHAR2(10);
g_base_uom_code      VARCHAR2(10);
g_nl_installed    BOOLEAN;
-- To preserve consistency reset g_serial_status_enabled to NULL if item or org changes
g_organization_id NUMBER;
g_inventory_item_id  NUMBER;
g_serial_status_enabled VARCHAR2(1);
g_serial_status      NUMBER;
g_serial_return   VARCHAR2(1);
g_transaction_type_id   NUMBER;
-- Used in get_acct_period
g_acct_organization_id  NUMBER;
g_acct_period_id        NUMBER;
g_debug  NUMBER;
g_conc_request_id number := FND_GLOBAL.CONC_REQUEST_ID;
g_conc_program boolean;


PROCEDURE print_debug( p_message VARCHAR2, p_level NUMBER := 9 ) IS
BEGIN

  IF (g_conc_program is null) or (g_debug is null) then
     g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     if (g_conc_request_id > 0) then
        g_conc_program := TRUE;
     end if;
  END IF;

  IF g_debug = 1 THEN
    --dbms_output.put_line(p_message);
    IF NOT g_version_printed THEN
        inv_log_util.trace('$Header: INVVDEUB.pls 120.16.12010000.8 2010/04/22 09:40:12 kjujjuru ship $', g_pkg_name, 1);
        g_version_printed := TRUE;
    END IF;
    inv_log_util.trace(
      p_message => p_message
    , p_module  => g_pkg_name
    , p_level   => p_level);

    gmi_reservation_util.println(p_message);
  END IF;
END print_debug;

-- find lot expiration date, and if not found, return null
FUNCTION get_lot_expiration_date
  (p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER,
   p_lot_number IN VARCHAR2)
  RETURN DATE IS
     --
     CURSOR l_cur IS
   SELECT  expiration_date
     FROM  mtl_lot_numbers
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id     = p_organization_id
     AND lot_number          = p_lot_number;
     --
     l_date DATE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_date;
   IF l_cur%notfound THEN
      l_date := NULL;
   END IF;
   CLOSE l_cur;
   RETURN l_date;
END get_lot_expiration_date;
--
-- read the request record into package variable and
-- initialize x_request_context
PROCEDURE get_request_context
  (x_return_status       OUT NOCOPY VARCHAR2   ,
   p_move_order_line_id  IN  NUMBER     ,
   x_request_context     OUT NOCOPY g_request_context_rec_type,
   x_request_line_rec    OUT NOCOPY g_request_line_rec_type,
   p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
   ) IS
      l_api_name VARCHAR2(30) := 'Get_Request_Context';
      l_allocate_serial_flag VARCHAR2(1);
      l_quantity_to_detail NUMBER;
      l_secondary_quantity_to_detail NUMBER; /* Bug 9172258 */

      CURSOR l_req_csr IS
         SELECT *
           FROM mtl_txn_request_lines
           WHERE line_id = p_move_order_line_id FOR UPDATE nowait;
      --
      l_primary_quantity  NUMBER;
      l_txn_type_id       NUMBER;
      l_inventory_item_id NUMBER;
      l_organization_id   NUMBER;
      l_end_assembly_pegging_flag VARCHAR2(1);
      --
/*      CURSOR l_context_csr IS
         SELECT
            mtt.transaction_action_id
           ,mtt.transaction_source_type_id
                ,msi.primary_uom_code
                ,msi.revision_qty_control_code
                ,msi.lot_control_code
           ,msi.serial_number_control_code
           ,msi.location_control_code
           ,mp.stock_locator_control_code
      ,msi.unit_volume
      ,msi.volume_uom_code
      ,msi.unit_weight
      ,msi.weight_uom_code
                ,msi.reservable_type
      ,NVL(msi.end_assembly_pegging_flag,'N')
      ,mp.allocate_serial_flag
           FROM  mtl_transaction_types mtt
                ,mtl_system_items      msi
                ,mtl_parameters        mp
         WHERE  mtt.transaction_type_id = l_txn_type_id
           AND  msi.inventory_item_id   = l_inventory_item_id
           AND  msi.organization_id     = l_organization_id
           AND mp.organization_id      = l_organization_id;
      --
*/
      CURSOR l_base_uom IS
    SELECT muom.uom_code
      FROM  mtl_units_of_measure_tl muom,mtl_units_of_measure_tl muom2
      WHERE muom2.uom_code = x_request_context.transaction_uom_code
      AND muom2.language = userenv('LANG')
      AND muom.uom_class = muom2.uom_class
      AND muom.language = userenv('LANG')
      AND muom.base_uom_flag = 'Y';


      --
      CURSOR l_ship_info_csr IS
         SELECT
           wdd.source_header_id oe_header_id,
           wdd.source_line_id   oe_line_id,
           NULL,
           wdd.customer_id,
           NULL,
           wdd.ship_to_location_id ship_to_location,
           NULL,
           wc.freight_code    -- Bug Fix 5594517
         FROM wsh_delivery_details wdd,
                wsh_carriers wc,
                wsh_carrier_services wcs
         WHERE wdd.move_order_line_id = p_move_order_line_id
           AND   wdd.move_order_line_id is NOT NULL
           AND   wdd.ship_method_code = wcs.ship_method_code (+)
           AND   wcs.carrier_id       = wc.carrier_id (+);

      CURSOR l_order_info_csr (p_src_line_id IN NUMBER) IS
         SELECT  oedtl.header_id oe_header_id,
           oedtl.line_id   oe_line_id,
           NULL,
           oedtl.sold_to_org_id,         -- customer_id
           NULL,
           NULL,
           NULL,
           oedtl.freight_carrier_code
         FROM oe_order_lines_all oedtl
         WHERE oedtl.line_id = p_src_line_id;

      --Bug #4598134 - Replace ra_customers with TCA entities
      CURSOR l_rma_info_csr IS
         SELECT
            oola.header_id
           ,oola.line_id
           ,NULL
           ,oola.sold_to_org_id
           --,rc.customer_number
           ,party.party_number
           ,NULL
           ,oola.shipment_number
           ,oola.freight_carrier_code
           FROM oe_order_lines_all oola
              , hz_parties party
              , hz_cust_accounts cust_acct
           WHERE oola.line_id = x_request_line_rec.reference_id
             AND cust_acct.cust_account_id = oola.sold_to_org_id
             AND cust_acct.party_id = party.party_id;

BEGIN
   --
   -- debugging section
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   x_return_status := fnd_api.g_ret_sts_success;
   -- get the request record
   print_debug('in context ');
   OPEN l_req_csr;
   BEGIN
      FETCH l_req_csr INTO x_request_line_rec;
   EXCEPTION
      WHEN timeout_on_resource THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
    inv_pp_debug.send_message_to_pipe('can not lock the move order line record');
      END IF;
      -- end of debugging section
      --
      RAISE timeout_on_resource;
      --
   END;
   print_debug('after fething req line');
   IF l_req_csr%notfound THEN
      print_debug('mo line not found ');
      IF inv_pp_debug.is_debug_mode THEN
    inv_pp_debug.send_message_to_pipe('mo line not found');
      END IF;
      fnd_message.set_name('INV','INV_PP_INPUT_LINE_NOTFOUND');
      fnd_message.set_token
        ('LINE_ID',fnd_number.number_to_canonical(p_move_order_line_id));
      fnd_msg_pub.ADD;
      CLOSE l_req_csr;
      RAISE fnd_api.g_exc_error;
   END IF;
   CLOSE l_req_csr;
   print_debug('init request_context');
   -- initialize x_request_context
   l_primary_quantity := x_request_line_rec.primary_quantity;
   l_txn_type_id := x_request_line_rec.transaction_type_id;
   l_inventory_item_id := x_request_line_rec.inventory_item_id;
   l_organization_id := x_request_line_rec.organization_id;
   If (inv_cache.set_mtt_rec(l_txn_type_id)  AND
        inv_cache.set_item_rec(l_organization_id, l_inventory_item_id)  AND
        inv_cache.set_org_rec(l_organization_id))  THEN

   print_debug('initing request_context ');
      x_request_context.transaction_action_id              := inv_cache.mtt_rec.transaction_action_id;
      x_request_context.transaction_source_type_id         := inv_cache.mtt_rec.transaction_source_type_id;
      x_request_context.primary_uom_code                   := inv_cache.item_rec.primary_uom_code;
      x_request_context.secondary_uom_code                 := inv_cache.item_rec.secondary_uom_code;
      x_request_context.item_revision_control              := inv_cache.item_rec.revision_qty_control_code;
      x_request_context.item_lot_control_code              := inv_cache.item_rec.lot_control_code;
      x_request_context.item_serial_control_code           := inv_cache.item_rec.serial_number_control_code;
      x_request_context.item_locator_control_code          := inv_cache.item_rec.location_control_code;
      x_request_context.org_locator_control_code           := inv_cache.org_rec.stock_locator_control_code;
      x_request_context.unit_volume                        := inv_cache.item_rec.unit_volume;
      x_request_context.volume_uom_code                    := inv_cache.item_rec.volume_uom_code;
      x_request_context.unit_weight                        := inv_cache.item_rec.unit_weight;
      x_request_context.weight_uom_code                    := inv_cache.item_rec.weight_uom_code;
      x_request_context.item_reservable_type               := inv_cache.item_rec.reservable_type;
      l_end_assembly_pegging_flag                          := NVL(inv_cache.item_rec.end_assembly_pegging_flag,'N');
      l_allocate_serial_flag                               := inv_cache.org_rec.allocate_serial_flag;
   ELSE
   print_debug('init request_context no data found');
      IF inv_pp_debug.is_debug_mode THEN
         inv_pp_debug.send_message_to_pipe('mo context not found');
      END IF;
      RAISE no_data_found;
   END IF;
   print_debug('after init request_context ');

   IF ( l_allocate_serial_flag <> 'N' ) THEN
     x_request_context.detail_any_serial := 1;
   ELSE
     x_request_context.detail_any_serial := 2;
   END IF;

   --commented out 2/6/03
   --bug 2778814
   --We now need to know if a item is serial controlled at issue, since it
   -- affects WMS putaway.  Move this logic into INVRSV4B.pls and WMSVPPEB.pls
   --IF x_request_context.item_serial_control_code = 6 THEN
   -- -- dynamic entry at sales order issue
   --   x_request_context.item_serial_control_code := 1; -- No serial control
   --END IF;
   --
   IF x_request_context.item_lot_control_code = 2
     AND x_request_line_rec.lot_number IS NOT NULL THEN
      x_request_context.lot_expiration_date := get_lot_expiration_date
                                         (l_organization_id
                                         , l_inventory_item_id
                                         , x_request_line_rec.lot_number
                                         );
   END IF;
   IF x_request_context.transaction_action_id IN (1,2,28,3,21,29,32,34) THEN
      x_request_context.type_code := 2;  -- picking  or transfer
    ELSE
      x_request_context.type_code := 1;  -- put away
   END IF;
   IF x_request_context.transaction_action_id IN (2,28,3) THEN
      x_request_context.transfer_flag := TRUE;
    ELSE
      x_request_context.transfer_flag := FALSE;
   END IF;
   --by default, set posting flag to Y (only set to No in WMS for
   --   put away move orders)
   if p_wave_simulation_mode = 'Y' then
	x_request_context.posting_flag := 'N';
   else
	x_request_context.posting_flag := 'Y';
   end if;
   x_request_context.transaction_uom_code :=
     x_request_line_rec.uom_code;

   print_debug('after flags ');
   IF NVL(g_transaction_uom_code,'@@@') <>  x_request_context.transaction_uom_code   THEN
      OPEN l_base_uom;
      FETCH l_base_uom INTO g_base_uom_code;
      IF l_base_uom%NOTFOUND THEN
         g_base_uom_code := NULL;
      END IF;
      CLOSE l_base_uom;
      g_transaction_uom_code := x_request_context.transaction_uom_code;
   END IF;
   x_request_context.base_uom_code := g_base_uom_code;


   -- compute quantity to detail in primary uom
   IF x_request_line_rec.quantity_detailed IS NULL THEN
      x_request_line_rec.quantity_detailed := 0;
   END IF;
   IF x_request_line_rec.quantity_delivered IS NULL THEN
      x_request_line_rec.quantity_delivered := 0;
   END IF;
   --compute quantity the rules engine should allocate
   --First, if the required quantity is less than quantity, use
   -- the required quantity as the new base.  Then the total allocations
   -- and already delivered plus the current allocation should not exceed
   -- the new base quantity.  Because of overpicking, the quantity
   -- delivered can sometimes exceed the quantity allocated.  We should
   -- take this into account

   l_quantity_to_detail := x_request_line_rec.quantity;

   /* Start Bug 9172258 */
   print_debug('inv_cache.item_rec.tracking_quantity_ind '||inv_cache.item_rec.tracking_quantity_ind);
   print_debug('(1)x_request_line_rec.secondary_quantity '||x_request_line_rec.secondary_quantity);
   IF (inv_cache.item_rec.tracking_quantity_ind = 'PS') THEN
      -- this item is dual UOM
      l_secondary_quantity_to_detail := x_request_line_rec.secondary_quantity;
   END IF;
   /* End Bug 9172258 */

   IF x_request_line_rec.required_quantity IS NOT NULL AND
      x_request_line_rec.required_quantity < l_quantity_to_detail THEN

      l_quantity_to_detail := x_request_line_rec.required_quantity;
      /* Start Bug 9172258 */
      IF (inv_cache.item_rec.tracking_quantity_ind = 'PS') THEN
         -- this item is dual UOM
         l_secondary_quantity_to_detail := x_request_line_rec.secondary_required_quantity;
      END IF;
      /* End Bug 9172258 */
   END IF;

   l_quantity_to_detail := l_quantity_to_detail -
        greatest(x_request_line_rec.quantity_detailed,
                 x_request_line_rec.quantity_delivered);

   IF x_request_context.transaction_uom_code <>
      x_request_context.primary_uom_code THEN

    x_request_line_rec.primary_quantity :=
     inv_convert.inv_um_convert
     (
      x_request_line_rec.inventory_item_id,
      NULL,
      l_quantity_to_detail,
      x_request_context.transaction_uom_code,
      x_request_context.primary_uom_code,
      NULL,
      NULL);
   ELSE
      x_request_line_rec.primary_quantity := l_quantity_to_detail;
   END IF;

   /* Start Bug 9172258 */
   print_debug('l_secondary_quantity_to_detail '||l_secondary_quantity_to_detail);
   print_debug('x_request_line_rec.secondary_quantity_detailed  '||x_request_line_rec.secondary_quantity_detailed);
   print_debug('x_request_line_rec.secondary_quantity_delivered '||x_request_line_rec.secondary_quantity_delivered);
   IF (inv_cache.item_rec.tracking_quantity_ind = 'PS') THEN
      -- this item is dual UOM
      x_request_line_rec.secondary_quantity := l_secondary_quantity_to_detail -
        greatest(NVL(x_request_line_rec.secondary_quantity_detailed ,0),
                 NVL(x_request_line_rec.secondary_quantity_delivered,0));
   END IF;
   print_debug('(2)x_request_line_rec.secondary_quantity '||x_request_line_rec.secondary_quantity);
   /* End Bug 9172258 */

   -- bug 5677255, keep the source_type_id for reservations, not overriding
   If x_request_line_rec.reference = 'ORDER_LINE_ID_RSV' Then
     null;
   Else
     x_request_line_rec.transaction_source_type_id := x_request_context.transaction_source_type_id;
   End if;
   --
   --for put away (but not transfer), copy organization_id into
   -- to_organization_id
   if (((x_request_context.type_code = 1) OR
   (x_request_context.transfer_flag = TRUE)) AND
       x_request_line_rec.to_organization_id IS NULL) THEN

     x_request_line_rec.to_organization_id := x_request_line_rec.organization_id;
   END IF;
   x_request_context.pick_strategy_id :=
     x_request_line_rec.pick_strategy_id;
   x_request_context.put_away_strategy_id :=
     x_request_line_rec.put_away_strategy_id;
   x_request_context.wms_task_type := NULL;
   x_request_context.end_assembly_pegging_code := 0;

   IF x_request_line_rec.transaction_source_type_id IN (2,8) THEN -- Order Entry
      OPEN l_ship_info_csr;
      FETCH l_ship_info_csr INTO
        x_request_context.txn_header_id,
        x_request_context.txn_line_id,
        x_request_context.txn_line_detail,
        x_request_context.customer_id,
        x_request_context.customer_number,
        x_request_context.ship_to_location,
        x_request_context.shipment_number,
        x_request_context.freight_code;
      IF l_ship_info_csr%notfound THEN
         IF inv_pp_debug.is_debug_mode THEN
            inv_pp_debug.send_message_to_pipe('mo shipping not found');
            inv_pp_debug.send_message_to_pipe('trans source type:' || x_request_line_rec.transaction_source_type_id);
         END IF;
         CLOSE l_ship_info_csr;
         -- bug 5677255, keep the source_type_id for reservations
         If x_request_line_rec.reference = 'ORDER_LINE_ID_RSV' Then
            -- fetch info from order line
            Open l_order_info_csr(x_request_line_rec.txn_source_line_id) ;
            Fetch l_order_info_csr INTO
              x_request_context.txn_header_id,
              x_request_context.txn_line_id,
              x_request_context.txn_line_detail,
              x_request_context.customer_id,
              x_request_context.customer_number,
              x_request_context.ship_to_location,
              x_request_context.shipment_number,
              x_request_context.freight_code;
              IF l_ship_info_csr%notfound THEN
                 IF inv_pp_debug.is_debug_mode THEN
                    inv_pp_debug.send_message_to_pipe('reservation mo order line not found');
                    inv_pp_debug.send_message_to_pipe('trans source type:' || x_request_line_rec.transaction_source_type_id);
                 END IF;
                 CLOSE l_order_info_csr;
                 RAISE no_data_found;
              End if;
            CLOSE l_order_info_csr;
            null;
         Else
            RAISE no_data_found;
         End if;
      END IF;
      CLOSE l_ship_info_csr;
      -- using mso header id as the demand source header id
      x_request_context.txn_header_id :=
                    inv_salesorder.get_salesorder_for_oeheader(x_request_context.txn_header_id);
     IF x_request_context.txn_header_id IS NULL THEN
        FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_GET_MSO_HEADER');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
      --
      --bug 1248138
      --not sure why this is happening, but it probably shouldn't be, so
      -- i'm commenting it out.
     /*
      UPDATE mtl_txn_request_lines
      SET txn_source_id = header_id
      WHERE line_id = p_move_order_line_id;
      */
    ELSIF x_request_line_rec.transaction_source_type_id = 12 THEN --RMA
      OPEN l_rma_info_csr;
      FETCH l_rma_info_csr INTO
        x_request_context.txn_header_id,
        x_request_context.txn_line_id,
        x_request_context.txn_line_detail,
        x_request_context.customer_id,
        x_request_context.customer_number,
        x_request_context.ship_to_location,
        x_request_context.shipment_number,
        x_request_context.freight_code;
      IF l_rma_info_csr%notfound THEN
         IF inv_pp_debug.is_debug_mode THEN
            inv_pp_debug.send_message_to_pipe('rma info not found');
            inv_pp_debug.send_message_to_pipe('trans source type:' || x_request_line_rec.transaction_source_type_id);
         END IF;
         CLOSE l_rma_info_csr;
         RAISE no_data_found;
      END IF;
      CLOSE l_rma_info_csr;

      --For a putaway move order created for an RMA Receipt, the txn_source_id
      --column of the move order line should point to the parent
      --record in RCV_TRANSACTIONS and should not be overridden
      IF (x_request_context.transaction_action_id = 27) THEN
        x_request_context.txn_header_id := x_request_line_rec.txn_source_id;
        x_request_context.txn_line_id := x_request_line_rec.txn_source_line_id;
      ELSE
        -- using mso header id as the demand source header id
        x_request_context.txn_header_id :=
          inv_salesorder.get_salesorder_for_oeheader(x_request_context.txn_header_id);
        IF x_request_context.txn_header_id IS NULL THEN
           FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_GET_MSO_HEADER');
           FND_MSG_PUB.Add;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

    -- Bug 2027368
    -- Because WIP move orders for backflush replenish have txn source
    -- type of 13, we can't check txn source type here.  Instead, we
    -- look at txn type.
    ELSIF x_request_line_rec.transaction_source_type_Id = 5 OR
          x_request_line_rec.transaction_type_id IN (35,51) THEN  -- WIP
      x_request_context.txn_header_id := x_request_line_rec.txn_source_id;
      x_request_context.txn_line_id :=
                           x_request_line_rec.txn_source_line_id;
      /* BUG 4737839 - done below
      --check whether item is pegged. This affects which material we allocate
      -- in INV detailing.
      If l_end_assembly_pegging_flag IN ('A','Y','B') Then
        --soft pegging
        x_request_context.end_assembly_pegging_code:= 1;
      Elsif l_end_assembly_pegging_flag IN ('I', 'X') Then
        --hard pegging
        x_request_context.end_assembly_pegging_code:= 2;
      End If;  --for all others, code is 0 (no pegging) */

    --For a putaway move order created for an PO, Int ship or Int Req receipt
    --the txn_source_id column of the move order line should point to the parent
    --record in RCV_TRANSACTIONS and should not be overridden
    ELSIF(
            (x_request_context.transaction_source_type_id = 1)
            OR(
               (
                x_request_context.transaction_source_type_id = 13
                OR x_request_context.transaction_source_type_id = 7
               )
               AND(x_request_context.transaction_action_id = 12)
              )
           ) THEN
      x_request_context.txn_header_id := x_request_line_rec.txn_source_id;
      x_request_context.txn_line_id := x_request_line_rec.txn_source_line_id;
    ELSE -- for all other transaction source types,
    --use the move order header/line as demand source header/line
      x_request_context.txn_header_id := x_request_line_rec.header_id;
      x_request_context.txn_line_id := x_request_line_rec.line_id;
   END IF;

   --BUG 4737839 : setting the assembly pegging flag should be done whatever the transaction source
   --check whether item is pegged. This affects which material we allocate
   -- in INV detailing.
   If l_end_assembly_pegging_flag IN ('A','Y','B') Then
     --soft pegging
     x_request_context.end_assembly_pegging_code:= 1;
   Elsif l_end_assembly_pegging_flag IN ('I', 'X') Then
     --hard pegging
     x_request_context.end_assembly_pegging_code:= 2;
   End If;  --for all others, code is 0 (no pegging)

   -- ugly, but we need to do this before the strategy search
   -- since users might have defined rules to use the primary_quantity in
   -- mtl_pp_strategy_mat_txn_tmp_v which is mapped to the move order line
   -- primary_quantity

   -- If data is changed then do update. Performance Improvement
   IF ((l_primary_quantity <> x_request_line_rec.primary_quantity) OR
   (x_request_context.transaction_source_type_id <> x_request_line_rec.transaction_source_type_id) OR
   (x_request_context.txn_header_id <> x_request_line_rec.txn_source_id) OR
   (x_request_context.txn_line_id <> x_request_line_rec.txn_source_line_id)) THEN
      UPDATE mtl_txn_request_lines SET
        primary_quantity =  x_request_line_rec.primary_quantity,
        transaction_source_type_id = x_request_context.transaction_source_type_id,
        txn_source_id = x_request_context.txn_header_id,
        txn_source_line_id = x_request_context.txn_line_id
        WHERE line_id = x_request_line_rec.line_id
        ;
   END IF;

   --
   -- debugging section
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe
   ('======== Move Order Line Information ========');
      inv_pp_debug.send_message_to_pipe('line_id                     '
               || x_request_line_rec.line_id);
      inv_pp_debug.send_message_to_pipe('header_id                   '
               || x_request_line_rec.header_id);
      inv_pp_debug.send_message_to_pipe('line_number                 '
               || x_request_line_rec.line_number);
      inv_pp_debug.send_message_to_pipe('organization_id             '
               || x_request_line_rec.organization_id);
      inv_pp_debug.send_message_to_pipe('inventory_item_id           '
               || x_request_line_rec.inventory_item_id);
      inv_pp_debug.send_message_to_pipe('revision                    '
               || x_request_line_rec.revision);
      inv_pp_debug.send_message_to_pipe('from_subinventory_id        '
               || x_request_line_rec.from_subinventory_id);
      inv_pp_debug.send_message_to_pipe('from_subinventory_code      '
               || x_request_line_rec.from_subinventory_code);
      inv_pp_debug.send_message_to_pipe('from_locator_id             '
               || x_request_line_rec.from_locator_id);
      inv_pp_debug.send_message_to_pipe('to_subinventory_code        '
               || x_request_line_rec.to_subinventory_code);
      inv_pp_debug.send_message_to_pipe('to_subinventory_id          '
               || x_request_line_rec.to_subinventory_id);
      inv_pp_debug.send_message_to_pipe('to_locator_id               '
               || x_request_line_rec.to_locator_id);
      inv_pp_debug.send_message_to_pipe('to_account_id               '
               || x_request_line_rec.to_account_id);
      inv_pp_debug.send_message_to_pipe('lot_number                  '
               || x_request_line_rec.lot_number);
      inv_pp_debug.send_message_to_pipe('serial_number_start         '
               || x_request_line_rec.serial_number_start);
      inv_pp_debug.send_message_to_pipe('serial_number_end           '
               || x_request_line_rec.serial_number_end);
      inv_pp_debug.send_message_to_pipe('uom_code                    '
               || x_request_line_rec.uom_code);
      inv_pp_debug.send_message_to_pipe('quantity                    '
               || x_request_line_rec.quantity);
      inv_pp_debug.send_message_to_pipe('quantity_delivered          '
               || x_request_line_rec.quantity_delivered);
      inv_pp_debug.send_message_to_pipe('quantity_detailed           '
               || x_request_line_rec.quantity_detailed);
      inv_pp_debug.send_message_to_pipe('date_required               '
               || x_request_line_rec.date_required);
      inv_pp_debug.send_message_to_pipe('reason_id                   '
               || x_request_line_rec.reason_id);
      inv_pp_debug.send_message_to_pipe('reference                   '
               || x_request_line_rec.reference);
      inv_pp_debug.send_message_to_pipe('reference_type_code         '
               || x_request_line_rec.reference_type_code);
      inv_pp_debug.send_message_to_pipe('reference_id                '
               || x_request_line_rec.reference_id);
      inv_pp_debug.send_message_to_pipe('project_id                  '
               || x_request_line_rec.project_id);
      inv_pp_debug.send_message_to_pipe('task_id                     '
               || x_request_line_rec.task_id);
      inv_pp_debug.send_message_to_pipe('transaction_header_id       '
               || x_request_line_rec.transaction_header_id);
      inv_pp_debug.send_message_to_pipe('line_status                 '
               || x_request_line_rec.line_status);
      inv_pp_debug.send_message_to_pipe('status_date                 '
               || x_request_line_rec.status_date);
      inv_pp_debug.send_message_to_pipe('txn_source_id               '
               || x_request_line_rec.txn_source_id);
      inv_pp_debug.send_message_to_pipe('txn_source_line_id          '
               || x_request_line_rec.txn_source_line_id);
      inv_pp_debug.send_message_to_pipe('txn_source_line_detail_id   '
               || x_request_line_rec.txn_source_line_detail_id);
      inv_pp_debug.send_message_to_pipe('transaction_type_id         '
               || x_request_line_rec.transaction_type_id);
      inv_pp_debug.send_message_to_pipe('transaction_source_type_id  '
               || x_request_line_rec.transaction_source_type_id);
      inv_pp_debug.send_message_to_pipe('primary_quantity            '
               || x_request_line_rec.primary_quantity);
      inv_pp_debug.send_message_to_pipe('to_organization_id          '
               || x_request_line_rec.to_organization_id);
      inv_pp_debug.send_message_to_pipe('put_away_strategy_id        '
               || x_request_line_rec.put_away_strategy_id);
      inv_pp_debug.send_message_to_pipe('pick_strategy_id            '
               || x_request_line_rec.pick_strategy_id);
      inv_pp_debug.send_message_to_pipe('unit_number                 '
               || x_request_line_rec.unit_number);
      inv_pp_debug.send_message_to_pipe
   ('======== Request Context ========');
      inv_pp_debug.send_message_to_pipe
        ('type_code                = '|| x_request_context.type_code);
      IF x_request_context.transfer_flag THEN
         inv_pp_debug.send_message_to_pipe('transfer_flag            = true');
       ELSE
         inv_pp_debug.send_message_to_pipe('transfer_flag            = false');
      END IF;
      inv_pp_debug.send_message_to_pipe
        ('transaction_action_id    = '|| x_request_context.transaction_action_id);
      inv_pp_debug.send_message_to_pipe
        ('item_revision_control    = '|| x_request_context.item_revision_control);
      inv_pp_debug.send_message_to_pipe
        ('item_lot_control_code    = '|| x_request_context.item_lot_control_code);
      inv_pp_debug.send_message_to_pipe
        ('item_serial_control_code = '|| x_request_context.item_serial_control_code);
      inv_pp_debug.send_message_to_pipe
        ('lot_expiration_date      = '|| x_request_context.lot_expiration_date);
      inv_pp_debug.send_message_to_pipe
        ('primary_uom_code         = '|| x_request_context.primary_uom_code);
      inv_pp_debug.send_message_to_pipe
        ('transaction_uom_code     = '|| x_request_context.transaction_uom_code);
      inv_pp_debug.send_message_to_pipe
        ('pick_strategy_id         = '|| x_request_context.pick_strategy_id);
      inv_pp_debug.send_message_to_pipe
        ('put_away_strategy_id     = '|| x_request_context.put_away_strategy_id);
      inv_pp_debug.send_message_to_pipe
        ('txn_header_id            = '|| x_request_context.txn_header_id);
      inv_pp_debug.send_message_to_pipe
        ('txn_line_id              = '|| x_request_context.txn_line_id);
      inv_pp_debug.send_message_to_pipe
        ('txn_line_detail          = '|| x_request_context.txn_line_detail);
      inv_pp_debug.send_message_to_pipe
        ('customer_id              = '|| x_request_context.customer_id);
      inv_pp_debug.send_message_to_pipe
        ('customer_number          = '|| x_request_context.customer_number);
      inv_pp_debug.send_message_to_pipe
        ('ship_to_location         = '|| x_request_context.ship_to_location);
      inv_pp_debug.send_message_to_pipe
        ('shipment_number          = '|| x_request_context.shipment_number);
      inv_pp_debug.send_message_to_pipe
        ('freight_code             = '|| x_request_context.freight_code);
      --
      inv_pp_debug.send_message_to_pipe
        ('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_error;
      IF l_req_csr%isopen THEN
         CLOSE l_req_csr;
      END IF;
      /*IF l_context_csr%isopen THEN
         CLOSE l_context_csr;
      END IF;*/
      IF l_ship_info_csr%isopen THEN
         CLOSE l_ship_info_csr;
      END IF;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF l_req_csr%isopen THEN
         CLOSE l_req_csr;
      END IF;
      /*IF l_context_csr%isopen THEN
         CLOSE l_context_csr;
      END IF;*/
      IF l_ship_info_csr%isopen THEN
         CLOSE l_ship_info_csr;
      END IF;
      --
   WHEN OTHERS THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF l_req_csr%isopen THEN
         CLOSE l_req_csr;
      END IF;
      /*IF l_context_csr%isopen THEN
         CLOSE l_context_csr;
      END IF; */
      IF l_ship_info_csr%isopen THEN
         CLOSE l_ship_info_csr;
      END IF;
      IF fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
      END IF;
END get_request_context;
--
-- compute picking detailing levels based on the move order line and
-- reservations
-- Added x_remaining_quantity as part of the bug fix for 2286454 and initilized with l_remain_pri_qty
PROCEDURE compute_pick_detail_level
  (x_return_status         OUT NOCOPY VARCHAR2,
   p_request_line_rec      IN  g_request_line_rec_type,
   p_request_context       IN  g_request_context_rec_type,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   x_detail_level_tbl      IN OUT nocopy g_detail_level_tbl_type,
   x_detail_level_tbl_size OUT NOCOPY NUMBER ,
   x_remaining_quantity    OUT NOCOPY NUMBER
   )
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_api_name VARCHAR2(30) := 'compute_pick_detail_level';
     l_remain_pri_qty     NUMBER;
     l_remain_sec_qty     NUMBER;
     l_pp_temp_qty        NUMBER;
     l_sec_pp_temp_qty    NUMBER;
     l_reserved_qty       NUMBER;
     l_sec_reserved_qty       NUMBER;
     l_res_index          NUMBER;
     l_index              NUMBER := 0;
BEGIN
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- split the picking request into multiple records
   -- based on reservations
   --
   -- store total quantity to split in l_remain_txn_qty
   l_remain_pri_qty := p_request_line_rec.primary_quantity;
   l_remain_sec_qty := p_request_line_rec.secondary_quantity;
   print_debug('in comupte detail , req sec qty '||l_remain_sec_qty);

   IF p_reservations.COUNT > 0
     AND p_request_context.type_code = 2 THEN
      FOR l_res_index IN 1..p_reservations.COUNT LOOP
         -- Fix for bug #1063622 - l_index was not always retaining
    -- its value upon exiting the loop.  Hence we have replaced
    -- it with variable l_res_index, which acts solely as a loop
    -- index, and mirroring its value to l_index
    l_index := l_res_index;

    -- decide the quantity for the new record
    l_reserved_qty :=
      p_reservations(l_index).primary_reservation_quantity -
      Nvl(p_reservations(l_index).detailed_quantity,0);
    l_sec_reserved_qty :=
      p_reservations(l_index).secondary_reservation_quantity -
      Nvl(p_reservations(l_index).secondary_detailed_quantity,0);
         print_debug('in comupte detail , res qty '||l_reserved_qty);
         print_debug('in comupte detail , res sec qty '||l_sec_reserved_qty);
    IF l_reserved_qty <= 0 THEN
       GOTO next_rsv;
    END IF;
    IF l_reserved_qty > l_remain_pri_qty THEN
       l_pp_temp_qty := l_remain_pri_qty;
       l_sec_pp_temp_qty := l_remain_sec_qty;
       l_remain_pri_qty := 0;
     ELSE
       l_pp_temp_qty := l_reserved_qty;
       l_sec_pp_temp_qty := l_sec_reserved_qty;
       l_remain_pri_qty := l_remain_pri_qty - l_reserved_qty;
    END IF;

         print_debug('in comupte detail , l_sec_pp_temp_qty '||l_sec_pp_temp_qty);
    -- FIX for BUG 2448249 - the default pick should come from the
    -- reservation and not from the move order. Changing the following
    -- IF statements for rev, sub, locator, lpn to check the reservation first
    -- decide revision
    IF p_reservations(l_index).revision IS NOT NULL THEN
       x_detail_level_tbl(l_index).revision :=
         p_reservations(l_index).revision;
     ELSIF p_request_line_rec.revision IS NOT NULL THEN
       x_detail_level_tbl(l_index).revision :=
         p_request_line_rec.revision;
     ELSE
       x_detail_level_tbl(l_index).revision := NULL;
    END IF;
    -- decide lot number
    IF p_reservations(l_index).lot_number IS NOT NULL THEN
       x_detail_level_tbl(l_index).lot_number :=
         p_reservations(l_index).lot_number;
     ELSIF p_request_line_rec.lot_number IS NOT NULL THEN
       x_detail_level_tbl(l_index).lot_number :=
         p_request_line_rec.lot_number;
     ELSE
       x_detail_level_tbl(l_index).lot_number := NULL;
    END IF;
    -- [ added the following code to support the allocation for serial reserved items ]
    -- [   decide serial Number  ]
    IF p_reservations(l_index).serial_number is NOT NULL THEN
       x_detail_level_tbl(l_index).serial_number := p_reservations(l_index).serial_number ;
       x_detail_level_tbl(l_index).serial_resv_flag := 'Y' ;
    ELSE
       x_detail_level_tbl(l_index).serial_number :=  NULL;
       x_detail_level_tbl(l_index).serial_resv_flag := 'N' ;
    END IF;

    -- decide sub
    IF p_reservations(l_index).subinventory_code
      IS NOT NULL THEN
       x_detail_level_tbl(l_index).subinventory_code :=
         p_reservations(l_index).subinventory_code;
     ELSIF p_request_line_rec.from_subinventory_code IS NOT NULL THEN
       x_detail_level_tbl(l_index).subinventory_code :=
         p_request_line_rec.from_subinventory_code;
     ELSE
       x_detail_level_tbl(l_index).subinventory_code := NULL;
    END IF;
    -- decide locator
    IF p_reservations(l_index).locator_id IS NOT NULL THEN
       x_detail_level_tbl(l_index).locator_id :=
         p_reservations(l_index).locator_id;
     ELSIF p_request_line_rec.from_locator_id IS NOT NULL THEN
       x_detail_level_tbl(l_index).locator_id :=
         p_request_line_rec.from_locator_id;
     ELSE
       x_detail_level_tbl(l_index).locator_id := NULL;
    END IF;
    -- decide lpn
    IF p_reservations(l_index).lpn_id IS NOT NULL THEN
       x_detail_level_tbl(l_index).lpn_id :=
         p_reservations(l_index).lpn_id;
     ELSIF p_request_line_rec.lpn_id IS NOT NULL THEN
       x_detail_level_tbl(l_index).lpn_id :=
         p_request_line_rec.lpn_id;
     ELSE
       x_detail_level_tbl(l_index).lpn_id := NULL;
    END IF;
    -- record the reservation id
    x_detail_level_tbl(l_index).reservation_id
      := p_reservations(l_index).reservation_id;
    --
    x_detail_level_tbl(l_index).primary_quantity     := l_pp_temp_qty;
    x_detail_level_tbl(l_index).secondary_quantity   := l_sec_pp_temp_qty;
    IF p_request_context.primary_uom_code <> p_request_context.transaction_uom_code THEN
            x_detail_level_tbl(l_index).transaction_quantity :=
         inv_convert.inv_um_convert
               (
          p_request_line_rec.inventory_item_id,
          NULL,
          l_pp_temp_qty,
          p_request_context.primary_uom_code,
          p_request_context.transaction_uom_code,
          NULL,
          NULL);
         ELSE
       x_detail_level_tbl(l_index).transaction_quantity := l_pp_temp_qty;
         END IF;

    IF l_remain_pri_qty = 0 THEN
       EXIT;
    END IF;
    <<next_rsv>>
      NULL;
      END LOOP;
   END IF;
   -- if reservation quantity is less than request quantity for detailing;
   -- Bug 1851999 - For staging transfers, we should only allocate
   -- the quantity that has been reserved.  We need this check to handle
   -- WIP reservations for sales orders.
   IF l_remain_pri_qty > 0 AND NOT
      (p_request_context.transaction_action_id = 28 AND
       p_reservations.count > 0) THEN
    l_index := x_detail_level_tbl.COUNT+1;
    x_detail_level_tbl(l_index).subinventory_code :=
      p_request_line_rec.from_subinventory_code;
    x_detail_level_tbl(l_index).locator_id :=
      p_request_line_rec.from_locator_id;
    x_detail_level_tbl(l_index).primary_quantity     :=
      l_remain_pri_qty;
    x_detail_level_tbl(l_index).secondary_quantity     :=
      l_remain_sec_qty;
    x_detail_level_tbl(l_index).transaction_quantity :=
      inv_convert.inv_um_convert
      (
       p_request_line_rec.inventory_item_id,
       NULL,
       l_remain_pri_qty,
       p_request_context.primary_uom_code,
       p_request_context.transaction_uom_code,
       NULL,
       NULL);
    l_remain_pri_qty := 0;
    x_detail_level_tbl(l_index).revision             :=
      p_request_line_rec.revision;
    x_detail_level_tbl(l_index).grade_code             :=
      p_request_line_rec.grade_code;
    x_detail_level_tbl(l_index).lot_number           :=
      p_request_line_rec.lot_number;
    x_detail_level_tbl(l_index).lpn_id           :=
      p_request_line_rec.lpn_id;
   END IF;
   x_detail_level_tbl_size := l_index;
   --
   x_return_status := l_return_status;

   -- Bug # 2286454-----------------------
   x_remaining_quantity :=  l_remain_pri_qty;

   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('detail table size: ' || x_detail_level_tbl_size);
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   --
EXCEPTION
   when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error ;
      --
   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      --
END compute_pick_detail_level;
--
PROCEDURE validate_and_init
  (x_return_status      OUT NOCOPY VARCHAR2,
   p_request_line_id    IN  NUMBER,
   p_suggest_serial     IN  VARCHAR2,
   x_request_line_rec   OUT NOCOPY g_request_line_rec_type,
   x_request_context    OUT NOCOPY g_request_context_rec_type,
   p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
   )
  IS
   l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_api_name VARCHAR2(30) := 'validate_and_init';
BEGIN
   --
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   --  Validation and Initialization
   --
   print_debug('in inv validate and init');
   IF p_request_line_id IS NULL THEN
      fnd_message.set_name('INV','INV_PP_TRX_REQ_LINE_ID_MISS');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   -- get request context
   print_debug('before context ');
   get_request_context(l_return_status,
             p_request_line_id,
             x_request_context,
             x_request_line_rec,
	     p_wave_simulation_mode
             );
   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   -- check whether quantity to detail is >0, if not, return
   IF x_request_line_rec.quantity IS NOT NULL
     AND x_request_line_rec.quantity >0
     AND (x_request_line_rec.quantity_detailed IS NULL
     OR x_request_line_rec.quantity_detailed
     < x_request_line_rec.quantity) THEN
      NULL;
    ELSE
      -- no quantity to detail, so return
      x_return_status := l_return_status;
      RETURN;
   END IF;
   --
   -- Determine whether serial numbers should be detailed.
   -- First, get value for profile
   -- If profile = 1, detail any serial number, not just those
   -- within the given range
   -- Bug 1712465 - We now get detail_any_serial from mtl_parameters
   --  in the get_request_context procedure.
   --x_request_context.detail_any_serial :=
   -- to_number(fnd_profile.value('INV:DETAIL_SERIAL_NUMBERS'));

   IF p_suggest_serial = fnd_api.g_true AND
      x_request_context.item_serial_control_code NOT IN (1,6) AND
      (x_request_context.detail_any_serial = 1 OR
   (x_request_line_rec.serial_number_start IS NOT NULL AND
    x_request_line_rec.serial_number_end IS NOT NULL)) THEN
      x_request_context.detail_serial := TRUE;
    ELSE
      x_request_context.detail_serial := FALSE;
      IF inv_pp_debug.is_debug_mode THEN
        inv_pp_debug.send_message_to_pipe('detail serial is FALSE');
      END IF;

   END IF;

   -- initialize serial output table
   init_output_serial_rows;
   x_return_status := l_return_status;
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   --
EXCEPTION
   when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error ;
      --
   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      if (fnd_msg_pub.check_msg_level(
             fnd_msg_pub.g_msg_lvl_unexp_error)) then
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      --
END validate_and_init;
--


FUNCTION is_sub_loc_lot_trx_allowed(
    p_transaction_type_id  IN NUMBER
   ,p_organization_id   IN NUMBER
   ,p_inventory_item_id IN NUMBER
   ,p_subinventory_code IN VARCHAR2
   ,p_locator_id     IN NUMBER
   ,p_lot_number     IN VARCHAR2
   ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(240);
  l_lot_status_enabled VARCHAR2(1);
  l_default_lot_status_id NUMBER;
  l_serial_status_enabled VARCHAR2(1);
  l_default_serial_status_id NUMBER;
  l_sub_return VARCHAR2(1);
  l_loc_return VARCHAR2(1);
  l_lot_return VARCHAR2(1);
  l_api_name constant varchar(30) := 'is_sub_loc_lot_trx_allowed';
  l_sub_status NUMBER;
  l_loc_status NUMBER;
  l_lot_status NUMBER;

  CURSOR c_sub_status IS
   SELECT status_id
     FROM mtl_secondary_inventories
    WHERE organization_id = p_organization_id
      AND secondary_inventory_name = p_subinventory_code;

  CURSOR c_loc_status IS
   SELECT status_id
     FROM mtl_item_locations
    WHERE organization_id = p_organization_id
      AND inventory_location_id = p_locator_id;

  CURSOR c_lot_status IS
   SELECT status_id
     FROM mtl_lot_numbers
    WHERE organization_id = p_organization_id
      AND inventory_item_id = p_inventory_item_id
      AND lot_number = p_lot_number;

BEGIN

  l_sub_return := 'Y';
  l_loc_return := 'Y';
  l_lot_return := 'Y';

  /* Performance issue - now check this flag only on INV side when
   * building dynamic SQL
   *--Check to see if status is enabled.  if not, return 'Y'
   *IF NOT inv_install.adv_inv_installed(NULL) THEN
   *   return 'Y';
   *END IF;
   */

  IF p_subinventory_code IS NOT NULL THEN
     -- get status
     IF (nvl(g_isllta_subinventory_code,'@@@') = p_subinventory_code
         AND nvl(g_isllta_transaction_type_id, -1) = p_transaction_type_id
         AND (inv_cache.is_pickrelease)) THEN --Bug 5246569
        l_sub_return := g_sub_return;
     ELSE
        OPEN c_sub_status;
        FETCH c_sub_status INTO l_sub_status;
        IF c_sub_status%FOUND AND l_sub_status IS NOT NULL THEN
           --check if txn type allowed with given sub status
           l_sub_return := inv_material_status_grp.is_trx_allowed(
                 p_status_id            => l_sub_status
                ,p_transaction_type_id  => p_transaction_type_id
                ,x_return_status        => l_return_status
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data);

           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             CLOSE c_sub_status;
             RAISE fnd_api.g_exc_unexpected_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
             CLOSE c_sub_status;
             RAISE fnd_api.g_exc_error;
           END IF;
        END IF;
        CLOSE c_sub_status;
        g_isllta_subinventory_code := p_subinventory_code;
        g_sub_return := l_sub_return;
        if nvl(g_isllta_transaction_type_id, -1) <> p_transaction_type_id THEN
           g_isllta_locator_id := NULL;
           g_isllta_lot_number := NULL;
        end if;
        g_isllta_transaction_type_id := p_transaction_type_id;
     END IF;
     print_debug('check sub_lot_loc_trx_allowed l_sub_return '||l_sub_return);
  END IF;

  IF p_locator_id IS NOT NULL THEN
     --get status
     IF (nvl(g_isllta_locator_id,-1) = p_locator_id
         AND nvl(g_isllta_transaction_type_id, -1) = p_transaction_type_id
         AND (inv_cache.is_pickrelease)) THEN --Bug 5246569
        l_loc_return := g_loc_return;
     ELSE
        OPEN c_loc_status;
        FETCH c_loc_status INTO l_loc_status;
        IF c_loc_status%FOUND AND l_loc_status IS NOT NULL THEN
           --check if txn type allowed with given locator status
           l_loc_return := inv_material_status_grp.is_trx_allowed(
                 p_status_id            => l_loc_status
                ,p_transaction_type_id  => p_transaction_type_id
                ,x_return_status        => l_return_status
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data);

           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             CLOSE c_loc_status;
             RAISE fnd_api.g_exc_unexpected_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
             CLOSE c_loc_status;
             RAISE fnd_api.g_exc_error;
           END IF;
        END IF;
        CLOSE c_loc_status;
        g_isllta_locator_id := p_locator_id;
        g_loc_return := l_loc_return;
        if nvl(g_isllta_transaction_type_id, -1) <> p_transaction_type_id THEN
           g_isllta_subinventory_code := NULL;
           g_isllta_lot_number := NULL;
        end if;
        g_isllta_transaction_type_id := p_transaction_type_id;
     END IF;
     print_debug('check sub_lot_loc_trx_allowed l_loc_return '||l_loc_return);
  END IF;

  --if item is lot status controlled, check if txn type is allowed
  inv_material_status_grp.get_lot_serial_status_control(
    p_organization_id   => p_organization_id
   ,p_inventory_item_id => p_inventory_item_id
   ,x_return_status  => l_return_status
   ,x_msg_count      => l_msg_count
   ,x_msg_data    => l_msg_data
   ,x_lot_status_enabled   => l_lot_status_enabled
   ,x_default_lot_status_id => l_default_lot_status_id
   ,x_serial_status_enabled => l_serial_status_enabled
   ,x_default_serial_status_id => l_default_serial_status_id);

  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  if l_lot_status_enabled = 'Y' AND p_lot_number IS NOT NULL THEN
     --get status
     IF (nvl(g_isllta_lot_number,'@@@') = p_lot_number
         AND nvl(g_isllta_transaction_type_id, -1) = p_transaction_type_id
         AND (inv_cache.is_pickrelease)) THEN --Bug 5246569
        l_lot_return := g_lot_return;
     ELSE
        OPEN c_lot_status;
        FETCH c_lot_status INTO l_lot_status;
        IF c_lot_status%FOUND AND l_lot_status IS NOT NULL THEN
           l_lot_return := inv_material_status_grp.is_trx_allowed(
                 p_status_id            => l_lot_status
                ,p_transaction_type_id  => p_transaction_type_id
                ,x_return_status        => l_return_status
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data);

           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             CLOSE c_lot_status;
             RAISE fnd_api.g_exc_unexpected_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
             CLOSE c_lot_status;
             RAISE fnd_api.g_exc_error;
           END IF;
        END IF;
        CLOSE c_lot_status;
        g_isllta_lot_number := p_lot_number;
        g_lot_return := l_lot_return;
        if nvl(g_isllta_transaction_type_id, -1) <> p_transaction_type_id THEN
           g_isllta_locator_id := NULL;
           g_isllta_subinventory_code := NULL;
        end if;
        g_isllta_transaction_type_id := p_transaction_type_id;
     END IF;
     print_debug('check sub_lot_loc_trx_allowed l_lot_return '||l_lot_return);
  END IF;

  IF (l_sub_return='Y' AND l_loc_return='Y' AND l_lot_return='Y') THEN
   return 'Y';
  ELSE
   return 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get( p_count => l_msg_count
                              ,p_data  => l_msg_data );
    return 'N';

END is_sub_loc_lot_trx_allowed;


FUNCTION is_serial_trx_allowed(
    p_transaction_type_id  IN NUMBER
   ,p_organization_id   IN NUMBER
   ,p_inventory_item_id IN NUMBER
   ,p_serial_status  IN NUMBER
   ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(240);
  l_lot_status_enabled VARCHAR2(1);
  l_default_lot_status_id NUMBER;
  l_serial_status_enabled VARCHAR2(1);
  l_default_serial_status_id NUMBER;
  l_serial_return VARCHAR2(1);
  l_api_name constant varchar(30) := 'is_serial_trx_allowed';

BEGIN

 l_serial_return := 'Y';


 /* Performance issue - now check this flag only on INV side when
  * building dynamic SQL
  *--Check to see if status is enabled.  if not, return 'Y'
  *IF NOT inv_install.adv_inv_installed(NULL) THEN
  *   return 'Y';
  *END IF;
  */


  IF ((p_organization_id <> NVL(g_organization_id,-999)) OR
      (p_inventory_item_id <> NVL(g_inventory_item_id,-999)) OR
      (g_serial_status_enabled IS NULL)) THEN
      --if item is serial status controlled, check if txn type is allowed
      g_organization_id := p_organization_id;
      g_inventory_item_id := p_inventory_item_id;

      inv_material_status_grp.get_lot_serial_status_control(
       p_organization_id   => p_organization_id
      ,p_inventory_item_id => p_inventory_item_id
      ,x_return_status  => l_return_status
      ,x_msg_count      => l_msg_count
      ,x_msg_data    => l_msg_data
      ,x_lot_status_enabled   => l_lot_status_enabled
      ,x_default_lot_status_id => l_default_lot_status_id
      ,x_serial_status_enabled => g_serial_status_enabled
      ,x_default_serial_status_id => l_default_serial_status_id);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;
  END IF;

  IF g_serial_status_enabled = 'Y' AND p_serial_status IS NOT NULL THEN
     IF ((p_serial_status = g_serial_status) AND
         (p_transaction_type_id = NVL(g_transaction_type_id,-999))) THEN
        l_serial_return := g_serial_return;
     ELSE
        g_serial_status := p_serial_status;
        g_transaction_type_id := p_transaction_type_id;

        g_serial_return := inv_material_status_grp.is_trx_allowed(
      p_status_id    => p_serial_status
     ,p_transaction_type_id   => p_transaction_type_id
     ,x_return_status   => l_return_status
     ,x_msg_count    => l_msg_count
     ,x_msg_data     => l_msg_data);

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        l_serial_return := g_serial_return;
     END IF;
  END IF;

  IF (l_serial_return = 'Y') THEN
   return 'Y';
  ELSE
   return 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get( p_count => l_msg_count
                              ,p_data  => l_msg_data );
    return 'N';

END is_serial_trx_allowed;

PROCEDURE build_sql (
   x_return_status      OUT   NOCOPY VARCHAR2
       ,x_sql_statement    OUT   NOCOPY LONG)
  IS

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   x_sql_statement := '
       SELECT
     x.organization_id
    ,x.inventory_item_id
    ,x.revision
    ,x.lot_number
    ,lot.expiration_date lot_expiration_date
    ,x.subinventory_code
    ,sub.reservable_type
    ,x.locator_id
    ,x.cost_group_id
    ,x.date_received date_received
    ,x.primary_quantity primary_quantity
    ,NULL lpn_id
    ,x.project_id project_id
    ,x.task_id task_id
       FROM
    (SELECT
             moq.organization_id
            ,moq.inventory_item_id
            ,moq.revision
            ,moq.lot_number
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.cost_group_id
            ,min(NVL(moq.orig_date_received,
                 moq.date_received)) date_received
            ,sum(moq.primary_transaction_quantity) primary_quantity
            ,moq.project_id
            ,moq.task_id
          FROM
            MTL_ONHAND_QUANTITIES_DETAIL moq
     WHERE
               moq.organization_id = :organization_id
      AND moq.inventory_item_id = :inventory_item_id
          GROUP BY
       moq.organization_id, moq.inventory_item_id
      ,moq.revision, moq.lot_number
           ,moq.subinventory_code, moq.locator_id
           ,moq.cost_group_id
           ,moq.project_id
           ,moq.task_id
         ) x
    ,mtl_secondary_inventories sub
         ,mtl_lot_numbers lot
       WHERE
       x.primary_quantity > 0
   AND x.organization_id = sub.organization_id
   AND x.subinventory_code = sub.secondary_inventory_name
        AND NVL(sub.disable_date, sysdate+1) > sysdate
   AND x.organization_id = lot.organization_id (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number = lot.lot_number (+)
      ';
END build_sql;


-- Description
--   Initialize the internal table that stores the serial numbers detailed
--   to empty
PROCEDURE init_output_serial_rows IS
BEGIN
   g_serial_tbl_ptr := 0;
   g_output_serial_rows.DELETE;
END init_output_serial_rows;
--
--  --------------------------------------------------------------------------
--  What does it do:
--  Sees if the passed serial number exists in our memory structure,
--  g_output_serial_rows.
--  If found, x_found = TRUE, else FALSE.
--  --------------------------------------------------------------------------
procedure search_serial_numbers(
  p_inventory_item_id  IN   NUMBER
, p_organization_id    IN   NUMBER
, p_serial_number      IN   VARCHAR2
, x_found              OUT  NOCOPY BOOLEAN
, x_return_status      OUT  NOCOPY VARCHAR2
, x_msg_count         OUT  NOCOPY NUMBER
, x_msg_data           OUT  NOCOPY VARCHAR2) is

-- constants
l_api_name  constant varchar(30) := 'search_serial_numbers';
begin
  x_return_status    := fnd_api.g_ret_sts_success;
  x_found            := FALSE;

  if (g_serial_tbl_ptr > 0) then
    for i in 1..g_serial_tbl_ptr loop

      if (g_output_serial_rows(i).inventory_item_id = p_inventory_item_id) and
         (g_output_serial_rows(i).organization_id   = p_organization_id)   and
         (g_output_serial_rows(i).serial_number     = p_serial_number) then
      x_found := TRUE;
      exit;
      end if;
    end loop;
  end if;
  --
exception
   when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error ;
      x_found := TRUE;

   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_found := TRUE;

   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_found := TRUE;

      if (fnd_msg_pub.check_msg_level(
             fnd_msg_pub.g_msg_lvl_unexp_error)) then
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;

end search_serial_numbers;
--
--  add serial number to pl/sql table
PROCEDURE add_serial_number(
    p_inventory_item_id IN NUMBER
   ,p_organization_id   IN NUMBER
   ,p_serial_number     IN VARCHAR2
   ,x_serial_index      OUT NOCOPY NUMBER
   ) IS

BEGIN

   g_serial_tbl_ptr := g_serial_tbl_ptr + 1;
   g_output_serial_rows(g_serial_tbl_ptr).serial_identifier :=
   g_serial_tbl_ptr;
   g_output_serial_rows(g_serial_tbl_ptr).inventory_item_id:=
   p_inventory_item_id;
   g_output_serial_rows(g_serial_tbl_ptr).organization_id:=
   p_organization_id;
   g_output_serial_rows(g_serial_tbl_ptr).serial_number:=
   p_serial_number;
   x_serial_index := g_serial_tbl_ptr;
END add_serial_number;

--  try to lock a serial number , return true if success, else flase
FUNCTION lock_serial_number
  (p_inventory_item_id  IN   NUMBER,
   p_serial_number      IN   VARCHAR2
   ) RETURN BOOLEAN
  IS
     CURSOR l_cur IS
   SELECT serial_number
     FROM mtl_serial_numbers
     WHERE inventory_item_id = p_inventory_item_id
     AND serial_number = p_serial_number
     FOR UPDATE nowait;
     l_serial_number VARCHAR2(30);
BEGIN
   OPEN l_cur;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RETURN FALSE;
   END IF;
   FETCH l_cur INTO l_serial_number;
   CLOSE l_cur;
   IF l_serial_number IS NULL THEN
      RETURN FALSE;
   END IF;
   RETURN TRUE;
EXCEPTION
   WHEN timeout_on_resource THEN
      RETURN FALSE;
   WHEN OTHERS THEN
      RETURN FALSE;
END lock_serial_number;
--
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Given the item/organization, inventory controls, quantity for a autodetailed
-- row and also from/to serial number range info,
-- it fetches and populates available serial numbers into g_output_serial_rows.
-- --------------------------------------------------------------------------
PROCEDURE get_serial_numbers (
  p_inventory_item_id       IN         NUMBER
, p_organization_id         IN         NUMBER
, p_revision                IN         VARCHAR2
, p_lot_number              IN         VARCHAR2
, p_subinventory_code       IN         VARCHAR2
, p_locator_id              IN         NUMBER
, p_required_sl_qty         IN         NUMBER
, p_from_range              IN         VARCHAR2
, p_to_range                IN         VARCHAR2
, p_unit_number             IN         VARCHAR2
, p_detail_any_serial       IN         NUMBER
, p_cost_group_id           IN         NUMBER
, p_transaction_type_id     IN         NUMBER
, x_available_sl_qty        OUT NOCOPY NUMBER
, x_serial_index            OUT NOCOPY NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_demand_source_type_id   IN         NUMBER   := null
, p_demand_source_header_id IN         NUMBER   := null
, p_demand_source_line_id   IN         NUMBER   := null
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Serial_Numbers';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER;
l_progress             VARCHAR2(10) := '0';

--bug 2620572 - allocate ordered by serial number
CURSOR msnc IS
  SELECT p_inventory_item_id
       , p_organization_id
       , msn.serial_number
       , null
    FROM  mtl_serial_numbers msn, inv_msn_gtemp img
    WHERE msn.inventory_item_id                    = p_inventory_item_id
    AND   msn.current_organization_id              = p_organization_id
    AND   nvl(msn.revision,'@@@')                  = nvl(p_revision,'@@@')
    AND   nvl(msn.lot_number, '@@@')               = nvl(p_lot_number,'@@@')
    AND   nvl(msn.current_subinventory_code,'@@@') = nvl(p_subinventory_code,'@@@')
    AND   nvl(msn.current_locator_id,-1)           = nvl(p_locator_id,-1)
    AND   nvl(msn.end_item_unit_number,'@@@')      = nvl(p_unit_number,'@@@')
    --AND   nvl(msn.cost_group_id,-1)      = nvl(p_cost_group_id, -1)
    AND   msn.current_status                       = 3
    AND  ((msn.group_mark_id is null) or (msn.group_mark_id = -1))
    AND   (p_detail_any_serial = 1 OR
           (p_from_range <= msn.serial_number AND
           Length(p_from_range) = Length(msn.serial_number))
           )
    AND   (p_detail_any_serial = 1 OR
           (msn.serial_number <= p_to_range AND
           Length(p_to_range) = Length(msn.serial_number))
           )
    AND msn.serial_number = img.serial_number (+)
    AND msn.inventory_item_id = img.inventory_item_id (+)
    AND msn.current_organization_id = img.organization_id (+)
    AND img.serial_number IS NULL
    ORDER BY msn.serial_number;

CURSOR validate_sn_cur IS
  SELECT img.inventory_item_id
       , img.organization_id
       , img.serial_number
       --, null dont forget
       , msn.status_id
  FROM inv_msn_gtemp img, mtl_serial_numbers msn
  WHERE img.use_flag = 0
    AND msn.serial_number = img.serial_number
    AND msn.inventory_item_id = img.inventory_item_id
    AND msn.current_organization_id = img.organization_id
    AND nvl(msn.revision,'@') = nvl(p_revision,'@')
    AND nvl(msn.lot_number, '@') = nvl(p_lot_number,'@')
    AND nvl(msn.current_subinventory_code,'@') = nvl(p_subinventory_code,'@')
    AND nvl(msn.current_locator_id,-1) = nvl(p_locator_id,-1)
    AND nvl(msn.end_item_unit_number,'@') = nvl(p_unit_number,'@')
    AND msn.current_status = 3;

l_allocate_serial_flag  VARCHAR2(1);
l_custom_select_serials INV_DETAIL_UTIL_PVT.g_serial_row_table_rec;
l_selected_serials      INV_DETAIL_UTIL_PVT.g_serial_row_table_rec;

BEGIN
  x_return_status    := fnd_api.g_ret_sts_success ;
  x_available_sl_qty := 0;
  x_serial_index     := 0;

  IF g_debug IS NULL or NOT INV_CACHE.is_pickrelease THEN
     g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),2);
  END IF;
  l_debug := g_debug;

  IF ( l_debug = 1 ) THEN
    print_debug('enter '||g_pkg_name||'.'||l_api_name, 1);
    print_debug('orgid='||p_organization_id||' itm='||p_inventory_item_id||' rev='||p_revision||' lot='||p_lot_number||' sub='||p_subinventory_code||' loc='||p_locator_id||' qty='||p_required_sl_qty||' fmsn='||p_from_range||' tosn='||p_to_range, 4);
    print_debug('unt='||p_unit_number||' det='||p_detail_any_serial||' cg='||p_cost_group_id||' trxtyp='||p_transaction_type_id||' styp='||p_demand_source_type_id||' shdr='||p_demand_source_header_id||' sln='||p_demand_source_line_id, 4);
  END IF;

  IF ( inv_cache.set_org_rec(p_organization_id) ) THEN
    l_allocate_serial_flag := inv_cache.org_rec.allocate_serial_flag;
    IF ( l_debug = 1 ) THEN
      print_debug('allocate_serial_flag= '||l_allocate_serial_flag);
    END IF;
  ELSE
    IF ( l_debug = 1 ) THEN
      print_debug('mo context not found');
    END IF;
    RAISE no_data_found;
  END IF;

  IF ( l_allocate_serial_flag = 'C' ) THEN
    INV_DETAIL_SERIAL_PUB.Get_User_Serial_Numbers (
      x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_inventory_item_id
    , p_revision                => p_revision
    , p_lot_number              => p_lot_number
    , p_subinventory_code       => p_subinventory_code
    , p_locator_id              => p_locator_id
    , p_required_sl_qty         => p_required_sl_qty
    , p_from_range              => p_from_range
    , p_to_range                => p_to_range
    , p_unit_number             => p_unit_number
    , p_cost_group_id           => p_cost_group_id
    , p_transaction_type_id     => p_transaction_type_id
    , p_demand_source_type_id   => p_demand_source_type_id
    , p_demand_source_header_id => p_demand_source_header_id
    , p_demand_source_line_id   => p_demand_source_line_id
    , x_serial_numbers          => l_custom_select_serials );

    IF ( x_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug('unexp_error from Get_User_Serial_Numbers');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug('error from Get_User_Serial_Numbers');
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    --Bulk insert the return values from user into temp table for validation
    BEGIN
      FORALL i IN l_custom_select_serials.serial_number.first..l_custom_select_serials.serial_number.last
      INSERT INTO inv_msn_gtemp (
        inventory_item_id
      , organization_id
      , serial_number
      , use_flag )
      values (
        l_custom_select_serials.inventory_item_id(i)
      , l_custom_select_serials.organization_id(i)
      , l_custom_select_serials.serial_number(i)
      , 0 );
    EXCEPTION
      WHEN OTHERS THEN
        IF ( l_debug = 1 ) THEN
          print_debug('Get_User_Serial_Numbers returned duplicate serials', 1);
        END IF;
        fnd_message.set_name('INV', 'INV_DUPLICATE_SERIAL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    --Retrieve only valid rows returned from api
    OPEN validate_sn_cur;
    FETCH validate_sn_cur
    BULK COLLECT INTO
      l_selected_serials.inventory_item_id
    , l_selected_serials.organization_id
    , l_selected_serials.serial_number
    , l_selected_serials.serial_status;
    CLOSE validate_sn_cur;

    --Delete any serial numbers not being used in inv_msn_gtemp
    DELETE FROM inv_msn_gtemp
    WHERE use_flag = 0;
  ELSE
    --bug 1348067 - causing serial numbers to detail twice
    -- we should initialize ptr once per detailing, not once per function call
    -- Serial_ptr_table now initialized in validate_and_init
    --g_serial_tbl_ptr := 0;
    OPEN msnc;
    FETCH msnc BULK COLLECT INTO
      l_selected_serials.inventory_item_id
    , l_selected_serials.organization_id
    , l_selected_serials.serial_number
    , l_selected_serials.serial_status;
    CLOSE msnc;
  END IF;

  IF l_selected_serials.serial_number.count > 0 THEN
    FOR i IN l_selected_serials.serial_number.first..l_selected_serials.serial_number.last LOOP
      IF (x_available_sl_qty >= p_required_sl_qty) THEN
        EXIT;
      END IF;

      IF ( is_serial_trx_allowed(
             p_transaction_type_id
           , p_organization_id
           , p_inventory_item_id
           , l_selected_serials.serial_status(i) ) = 'Y' ) THEN
        BEGIN
          INSERT INTO inv_msn_gtemp (
            serial_identifier
          , INVENTORY_ITEM_ID
          , organization_id
          , Serial_number
          , use_flag )
          VALUES (
            1
          , p_inventory_item_id
          , p_organization_id
          , l_selected_serials.serial_number(i)
          , 1 );

          -- if the serial number is available, we want to lock it now so that
          -- other concurrent sessions would not try to use it
          IF ( lock_serial_number(p_inventory_item_id, l_selected_serials.serial_number(i)) ) THEN
            -- Move last row pointer of g_output_serial_rows by 1.
            g_serial_tbl_ptr   := g_serial_tbl_ptr + 1;

            -- Another serial number that can be returned.
            x_available_sl_qty := x_available_sl_qty + 1;

            -- Record the index for the first serial number.
            -- This will be returned and also used here.
            if (x_available_sl_qty = 1) then
              x_serial_index := g_serial_tbl_ptr;
            end if;

            -- Populate g_output_serial_rows.
            -- All serial nos populated in this call will share the same serial
            -- identifier value. This is the pl/sql table index of the 1st row in
            -- the set of serial numbers populated in this call, in pl/sql table,
            -- g_output_serial_rows. It will also be used in the parent
            -- autodetailed row to provide a link to g_output_serial_rows. Using
            -- a pl/sql table index for a link rather than  some random number
            -- should make searching easier.

            g_output_serial_rows(g_serial_tbl_ptr).serial_identifier := x_serial_index;
            g_output_serial_rows(g_serial_tbl_ptr).inventory_item_id := p_inventory_item_id;
            g_output_serial_rows(g_serial_tbl_ptr).organization_id   := p_organization_id;
            g_output_serial_rows(g_serial_tbl_ptr).serial_number     := l_selected_serials.serial_number(i);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
          IF ( l_debug = 1 ) THEN
            print_debug('sn='||l_selected_serials.serial_number(i)||' skipped SQL err: '||SQLERRM(SQLCODE), 1);
          END IF;
        END;
      ELSIF ( l_debug = 1 ) THEN
       print_debug('sn='||l_selected_serials.serial_number(i)||' of wrong status='||l_selected_serials.serial_status(i));
      END IF;
    END LOOP;
  END IF;

  IF ( l_debug = 1 )THEN
    print_debug('exit '||g_pkg_name||'.'||l_api_name);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error then
    x_return_status    := fnd_api.g_ret_sts_error;
    x_available_sl_qty := 0;
    x_serial_index     := 0;

    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Exc err progress='||l_progress||' SQL err: '||SQLERRM(SQLCODE), 1);
    END IF;
  WHEN OTHERS THEN
    x_return_status    := fnd_api.g_ret_sts_unexp_error;
    x_available_sl_qty := 0;
    x_serial_index     := 0;

    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Others err progress='||l_progress||' SQL err: '||SQLERRM(SQLCODE), 1);
    END IF;

    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
END Get_Serial_Numbers;
--
-- insert record into mtl_material_transactions_temp
-- who columns will be derived in the procedure
PROCEDURE insert_mmtt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_mmtt_tbl       IN  g_mmtt_tbl_type
   ,p_mmtt_tbl_size  IN  INTEGER
   )
  IS
     l_api_name  CONSTANT VARCHAR2(30) := 'Insert_MMTT';
     l_today     DATE;
     l_user_id   NUMBER;
     l_login_id  NUMBER;
     l_rowid     VARCHAR2(20);
BEGIN
   --
   -- debugging portion
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   IF p_mmtt_tbl_size IS NULL OR p_mmtt_tbl_size <1 THEN
      RETURN;
   END IF;
   --
   l_today := SYSDATE;
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   --
   FOR l_counter IN 1..p_mmtt_tbl_size LOOP
     print_debug('in insert mmtt '||p_mmtt_tbl(l_counter).transaction_temp_id );
      INSERT INTO mtl_material_transactions_temp
        (
         transaction_header_id          ,
         transaction_temp_id            ,
         source_code                    ,
         source_line_id                 ,
         transaction_mode               ,
         lock_flag                      ,
         last_update_date               ,
         last_updated_by                ,
         creation_date                  ,
         created_by                     ,
         last_update_login              ,
         request_id                     ,
         program_application_id         ,
         program_id                     ,
         program_update_date            ,
         inventory_item_id              ,
         revision                       ,
         organization_id                ,
         subinventory_code              ,
         locator_id                     ,
         transaction_quantity           ,
         primary_quantity               ,
         secondary_transaction_quantity ,
         transaction_uom                ,
         secondary_uom_code             ,
         transaction_cost               ,
         transaction_type_id            ,
         transaction_action_id          ,
         transaction_source_type_id     ,
         transaction_source_id          ,
         transaction_source_name        ,
         transaction_date               ,
         acct_period_id                 ,
         distribution_account_id        ,
         transaction_reference          ,
         requisition_line_id            ,
         requisition_distribution_id    ,
         reason_id                      ,
         lot_number                     ,
         lot_expiration_date            ,
         serial_number                  ,
         receiving_document             ,
         demand_id                      ,
         rcv_transaction_id             ,
         move_transaction_id            ,
         completion_transaction_id      ,
         wip_entity_type                ,
         schedule_id                    ,
         repetitive_line_id             ,
         employee_code                  ,
         primary_switch                 ,
         schedule_update_code           ,
         setup_teardown_code            ,
         item_ordering                  ,
         negative_req_flag              ,
         operation_seq_num              ,
         picking_line_id                ,
         trx_source_line_id             ,
         trx_source_delivery_id         ,
         physical_adjustment_id         ,
         cycle_count_id                 ,
         rma_line_id                    ,
         customer_ship_id               ,
         currency_code                  ,
         currency_conversion_rate       ,
         currency_conversion_type       ,
         currency_conversion_date       ,
         ussgl_transaction_code         ,
         vendor_lot_number              ,
         encumbrance_account            ,
         encumbrance_amount             ,
         ship_to_location               ,
         shipment_number                ,
         transfer_cost                  ,
         transportation_cost            ,
         transportation_account         ,
         freight_code                   ,
         containers                     ,
         waybill_airbill                ,
         expected_arrival_date          ,
         transfer_subinventory          ,
         transfer_organization          ,
         transfer_to_location           ,
         new_average_cost               ,
         value_change                   ,
         percentage_change              ,
         material_allocation_temp_id    ,
         demand_source_header_id        ,
         demand_source_line             ,
         demand_source_delivery         ,
         item_segments                  ,
         item_description               ,
         item_trx_enabled_flag          ,
         item_location_control_code     ,
         item_restrict_subinv_code      ,
         item_restrict_locators_code    ,
         item_revision_qty_control_code ,
         item_primary_uom_code          ,
         item_uom_class                 ,
         item_shelf_life_code           ,
         item_shelf_life_days           ,
         item_lot_control_code          ,
         item_serial_control_code       ,
         item_inventory_asset_flag      ,
         allowed_units_lookup_code      ,
         department_id                  ,
         department_code                ,
         wip_supply_type                ,
         supply_subinventory            ,
         supply_locator_id              ,
         valid_subinventory_flag        ,
         valid_locator_flag             ,
         locator_segments               ,
         current_locator_control_code   ,
         number_of_lots_entered         ,
         wip_commit_flag                ,
         next_lot_number                ,
         lot_alpha_prefix               ,
         next_serial_number             ,
         serial_alpha_prefix            ,
         shippable_flag                 ,
         posting_flag                   ,
         required_flag                  ,
         process_flag                   ,
         error_code                     ,
         error_explanation              ,
         attribute_category             ,
         attribute1                     ,
         attribute2                     ,
         attribute3                     ,
         attribute4                     ,
         attribute5                     ,
         attribute6                     ,
         attribute7                     ,
         attribute8                     ,
         attribute9                     ,
         attribute10                    ,
         attribute11                    ,
         attribute12                    ,
         attribute13                    ,
         attribute14                    ,
         attribute15                    ,
         movement_id                    ,
         reservation_quantity           ,
         shipped_quantity               ,
         transaction_line_number        ,
         task_id                        ,
         to_task_id                     ,
         source_task_id                 ,
         project_id                     ,
         source_project_id              ,
         pa_expenditure_org_id          ,
         to_project_id                  ,
         expenditure_type               ,
         final_completion_flag          ,
         transfer_percentage            ,
         transaction_sequence_id        ,
         material_account               ,
         material_overhead_account      ,
         resource_account               ,
         outside_processing_account     ,
         overhead_account               ,
         flow_schedule                  ,
         cost_group_id                  ,
         demand_class                   ,
         qa_collection_id               ,
         kanban_card_id                 ,
         overcompletion_transaction_id  ,
         overcompletion_primary_qty     ,
         overcompletion_transaction_qty ,
         end_item_unit_number           ,
         scheduled_payback_date         ,
         line_type_code                 ,
         parent_transaction_temp_id     ,
         put_away_strategy_id           ,
         put_away_rule_id               ,
         pick_strategy_id               ,
         pick_rule_id                   ,
         common_bom_seq_id              ,
         common_routing_seq_id          ,
         cost_type_id                   ,
         org_cost_group_id              ,
         move_order_line_id             ,
         task_group_id                   ,
         pick_slip_number                ,
         reservation_id                  ,
         transaction_status              ,
         transfer_cost_group_id          ,
         lpn_id                          ,
         wms_task_type                   ,
         allocated_lpn_id                ,
         move_order_header_id            ,
         serial_allocated_flag           ,
         wms_task_status                 ,
         task_priority
)
VALUES
(
  p_mmtt_tbl(l_counter).transaction_header_id
       ,p_mmtt_tbl(l_counter).transaction_temp_id
       ,p_mmtt_tbl(l_counter).source_code
       ,p_mmtt_tbl(l_counter).source_line_id
       ,p_mmtt_tbl(l_counter).transaction_mode
       ,p_mmtt_tbl(l_counter).lock_flag
       ,l_today
       ,l_user_id
       ,l_today
       ,l_user_id
       ,l_login_id
       ,p_mmtt_tbl(l_counter).request_id
       ,p_mmtt_tbl(l_counter).program_application_id
       ,p_mmtt_tbl(l_counter).program_id
       ,p_mmtt_tbl(l_counter).program_update_date
       ,p_mmtt_tbl(l_counter).inventory_item_id
       ,p_mmtt_tbl(l_counter).revision
       ,p_mmtt_tbl(l_counter).organization_id
       ,p_mmtt_tbl(l_counter).subinventory_code
       ,p_mmtt_tbl(l_counter).locator_id
       ,p_mmtt_tbl(l_counter).transaction_quantity
       ,p_mmtt_tbl(l_counter).primary_quantity
       ,p_mmtt_tbl(l_counter).secondary_transaction_quantity
       ,p_mmtt_tbl(l_counter).transaction_uom
       ,p_mmtt_tbl(l_counter).secondary_uom_code
       ,p_mmtt_tbl(l_counter).transaction_cost
       ,p_mmtt_tbl(l_counter).transaction_type_id
       ,p_mmtt_tbl(l_counter).transaction_action_id
       ,p_mmtt_tbl(l_counter).transaction_source_type_id
       ,p_mmtt_tbl(l_counter).transaction_source_id
       ,p_mmtt_tbl(l_counter).transaction_source_name
       ,p_mmtt_tbl(l_counter).transaction_date
       ,p_mmtt_tbl(l_counter).acct_period_id
       ,p_mmtt_tbl(l_counter).distribution_account_id
       ,p_mmtt_tbl(l_counter).transaction_reference
       ,p_mmtt_tbl(l_counter).requisition_line_id
       ,p_mmtt_tbl(l_counter).requisition_distribution_id
       ,p_mmtt_tbl(l_counter).reason_id
       ,p_mmtt_tbl(l_counter).lot_number
       ,p_mmtt_tbl(l_counter).lot_expiration_date
       ,p_mmtt_tbl(l_counter).serial_number
       ,p_mmtt_tbl(l_counter).receiving_document
       ,p_mmtt_tbl(l_counter).demand_id
       ,p_mmtt_tbl(l_counter).rcv_transaction_id
       ,p_mmtt_tbl(l_counter).move_transaction_id
       ,p_mmtt_tbl(l_counter).completion_transaction_id
       ,p_mmtt_tbl(l_counter).wip_entity_type
       ,p_mmtt_tbl(l_counter).schedule_id
       ,p_mmtt_tbl(l_counter).repetitive_line_id
       ,p_mmtt_tbl(l_counter).employee_code
       ,p_mmtt_tbl(l_counter).primary_switch
       ,p_mmtt_tbl(l_counter).schedule_update_code
       ,p_mmtt_tbl(l_counter).setup_teardown_code
       ,p_mmtt_tbl(l_counter).item_ordering
       ,p_mmtt_tbl(l_counter).negative_req_flag
       ,p_mmtt_tbl(l_counter).operation_seq_num
       ,p_mmtt_tbl(l_counter).picking_line_id
       ,p_mmtt_tbl(l_counter).trx_source_line_id
       ,p_mmtt_tbl(l_counter).trx_source_delivery_id
       ,p_mmtt_tbl(l_counter).physical_adjustment_id
       ,p_mmtt_tbl(l_counter).cycle_count_id
       ,p_mmtt_tbl(l_counter).rma_line_id
       ,p_mmtt_tbl(l_counter).customer_ship_id
       ,p_mmtt_tbl(l_counter).currency_code
       ,p_mmtt_tbl(l_counter).currency_conversion_rate
       ,p_mmtt_tbl(l_counter).currency_conversion_type
       ,p_mmtt_tbl(l_counter).currency_conversion_date
       ,p_mmtt_tbl(l_counter).ussgl_transaction_code
       ,p_mmtt_tbl(l_counter).vendor_lot_number
       ,p_mmtt_tbl(l_counter).encumbrance_account
       ,p_mmtt_tbl(l_counter).encumbrance_amount
       ,p_mmtt_tbl(l_counter).ship_to_location
       ,p_mmtt_tbl(l_counter).shipment_number
       ,p_mmtt_tbl(l_counter).transfer_cost
       ,p_mmtt_tbl(l_counter).transportation_cost
       ,p_mmtt_tbl(l_counter).transportation_account
       ,p_mmtt_tbl(l_counter).freight_code
       ,p_mmtt_tbl(l_counter).containers
       ,p_mmtt_tbl(l_counter).waybill_airbill
       ,p_mmtt_tbl(l_counter).expected_arrival_date
       ,p_mmtt_tbl(l_counter).transfer_subinventory
       ,p_mmtt_tbl(l_counter).transfer_organization
       ,p_mmtt_tbl(l_counter).transfer_to_location
       ,p_mmtt_tbl(l_counter).new_average_cost
       ,p_mmtt_tbl(l_counter).value_change
       ,p_mmtt_tbl(l_counter).percentage_change
       ,p_mmtt_tbl(l_counter).material_allocation_temp_id
       ,p_mmtt_tbl(l_counter).demand_source_header_id
       ,p_mmtt_tbl(l_counter).demand_source_line
       ,p_mmtt_tbl(l_counter).demand_source_delivery
       ,p_mmtt_tbl(l_counter).item_segments
       ,p_mmtt_tbl(l_counter).item_description
       ,p_mmtt_tbl(l_counter).item_trx_enabled_flag
       ,p_mmtt_tbl(l_counter).item_location_control_code
       ,p_mmtt_tbl(l_counter).item_restrict_subinv_code
       ,p_mmtt_tbl(l_counter).item_restrict_locators_code
       ,p_mmtt_tbl(l_counter).item_revision_qty_control_code
       ,p_mmtt_tbl(l_counter).item_primary_uom_code
       ,p_mmtt_tbl(l_counter).item_uom_class
       ,p_mmtt_tbl(l_counter).item_shelf_life_code
       ,p_mmtt_tbl(l_counter).item_shelf_life_days
       ,p_mmtt_tbl(l_counter).item_lot_control_code
       ,p_mmtt_tbl(l_counter).item_serial_control_code
       ,p_mmtt_tbl(l_counter).item_inventory_asset_flag
       ,p_mmtt_tbl(l_counter).allowed_units_lookup_code
       ,p_mmtt_tbl(l_counter).department_id
       ,p_mmtt_tbl(l_counter).department_code
       ,p_mmtt_tbl(l_counter).wip_supply_type
       ,p_mmtt_tbl(l_counter).supply_subinventory
       ,p_mmtt_tbl(l_counter).supply_locator_id
       ,p_mmtt_tbl(l_counter).valid_subinventory_flag
       ,p_mmtt_tbl(l_counter).valid_locator_flag
       ,p_mmtt_tbl(l_counter).locator_segments
       ,p_mmtt_tbl(l_counter).current_locator_control_code
       ,p_mmtt_tbl(l_counter).number_of_lots_entered
       ,p_mmtt_tbl(l_counter).wip_commit_flag
       ,p_mmtt_tbl(l_counter).next_lot_number
       ,p_mmtt_tbl(l_counter).lot_alpha_prefix
       ,p_mmtt_tbl(l_counter).next_serial_number
       ,p_mmtt_tbl(l_counter).serial_alpha_prefix
       ,p_mmtt_tbl(l_counter).shippable_flag
       ,p_mmtt_tbl(l_counter).posting_flag
       ,p_mmtt_tbl(l_counter).required_flag
       ,p_mmtt_tbl(l_counter).process_flag
       ,p_mmtt_tbl(l_counter).error_code
       ,p_mmtt_tbl(l_counter).error_explanation
       ,p_mmtt_tbl(l_counter).attribute_category
       ,p_mmtt_tbl(l_counter).attribute1
       ,p_mmtt_tbl(l_counter).attribute2
       ,p_mmtt_tbl(l_counter).attribute3
       ,p_mmtt_tbl(l_counter).attribute4
       ,p_mmtt_tbl(l_counter).attribute5
       ,p_mmtt_tbl(l_counter).attribute6
       ,p_mmtt_tbl(l_counter).attribute7
       ,p_mmtt_tbl(l_counter).attribute8
       ,p_mmtt_tbl(l_counter).attribute9
       ,p_mmtt_tbl(l_counter).attribute10
       ,p_mmtt_tbl(l_counter).attribute11
       ,p_mmtt_tbl(l_counter).attribute12
       ,p_mmtt_tbl(l_counter).attribute13
       ,p_mmtt_tbl(l_counter).attribute14
       ,p_mmtt_tbl(l_counter).attribute15
       ,p_mmtt_tbl(l_counter).movement_id
       ,p_mmtt_tbl(l_counter).reservation_quantity
       ,p_mmtt_tbl(l_counter).shipped_quantity
       ,p_mmtt_tbl(l_counter).transaction_line_number
       ,p_mmtt_tbl(l_counter).task_id
       ,p_mmtt_tbl(l_counter).to_task_id
       ,p_mmtt_tbl(l_counter).source_task_id
       ,p_mmtt_tbl(l_counter).project_id
       ,p_mmtt_tbl(l_counter).source_project_id
       ,p_mmtt_tbl(l_counter).pa_expenditure_org_id
       ,p_mmtt_tbl(l_counter).to_project_id
       ,p_mmtt_tbl(l_counter).expenditure_type
       ,p_mmtt_tbl(l_counter).final_completion_flag
       ,p_mmtt_tbl(l_counter).transfer_percentage
       ,p_mmtt_tbl(l_counter).transaction_sequence_id
       ,p_mmtt_tbl(l_counter).material_account
       ,p_mmtt_tbl(l_counter).material_overhead_account
       ,p_mmtt_tbl(l_counter).resource_account
       ,p_mmtt_tbl(l_counter).outside_processing_account
       ,p_mmtt_tbl(l_counter).overhead_account
       ,p_mmtt_tbl(l_counter).flow_schedule
       ,p_mmtt_tbl(l_counter).cost_group_id
       ,p_mmtt_tbl(l_counter).demand_class
       ,p_mmtt_tbl(l_counter).qa_collection_id
       ,p_mmtt_tbl(l_counter).kanban_card_id
       ,p_mmtt_tbl(l_counter).overcompletion_transaction_id
       ,p_mmtt_tbl(l_counter).overcompletion_primary_qty
       ,p_mmtt_tbl(l_counter).overcompletion_transaction_qty
       ,p_mmtt_tbl(l_counter).end_item_unit_number
       ,p_mmtt_tbl(l_counter).scheduled_payback_date
       ,p_mmtt_tbl(l_counter).line_type_code
       ,p_mmtt_tbl(l_counter).parent_transaction_temp_id
       ,p_mmtt_tbl(l_counter).put_away_strategy_id
       ,p_mmtt_tbl(l_counter).put_away_rule_id
       ,p_mmtt_tbl(l_counter).pick_strategy_id
       ,p_mmtt_tbl(l_counter).pick_rule_id
       ,p_mmtt_tbl(l_counter).common_bom_seq_id
       ,p_mmtt_tbl(l_counter).common_routing_seq_id
       ,p_mmtt_tbl(l_counter).cost_type_id
       ,p_mmtt_tbl(l_counter).org_cost_group_id
       ,p_mmtt_tbl(l_counter).move_order_line_id
       ,p_mmtt_tbl(l_counter).task_group_id
       ,p_mmtt_tbl(l_counter).pick_slip_number
       ,p_mmtt_tbl(l_counter).reservation_id
       ,p_mmtt_tbl(l_counter).transaction_status
       ,p_mmtt_tbl(l_counter).transfer_cost_group_id
       ,p_mmtt_tbl(l_counter).lpn_id
       ,p_mmtt_tbl(l_counter).wms_task_type
       ,p_mmtt_tbl(l_counter).allocated_lpn_id
       ,p_mmtt_tbl(l_counter).move_order_header_id
       ,p_mmtt_tbl(l_counter).serial_allocated_flag
       ,p_mmtt_tbl(l_counter).wms_task_status
       ,p_mmtt_tbl(l_counter).task_priority
     );
   END LOOP;
   --
   -- debugging portion
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
EXCEPTION
   when fnd_api.g_exc_error then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_error;
      --
   when fnd_api.g_exc_unexpected_error then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
   when others then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) then
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      --
END insert_mmtt;
--
-- insert record into mtl_transaction_lots_temp
-- who columns will be derived in the procedure
PROCEDURE insert_mtlt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_mtlt_tbl       IN  g_mtlt_tbl_type
   ,p_mtlt_tbl_size  IN  INTEGER
   )
  IS
     l_api_name  CONSTANT VARCHAR2(30) := 'Insert_MTLT';
     l_today     DATE;
     l_user_id   NUMBER;
     l_login_id  NUMBER;
     l_rowid     VARCHAR2(20);
BEGIN
   --
   -- debugging portion
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   IF p_mtlt_tbl_size IS NULL OR p_mtlt_tbl_size < 1 THEN
      RETURN;
   END IF;
   --
   l_today := SYSDATE;
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   FOR l_counter IN 1..p_mtlt_tbl_size LOOP
      INSERT INTO mtl_transaction_lots_temp
   (
         transaction_temp_id
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date
         ,transaction_quantity
         ,primary_quantity
         ,secondary_quantity
	 ,secondary_unit_of_measure  -- Bug 8217560
         ,lot_number
         ,lot_expiration_date
         ,error_code
         ,serial_transaction_temp_id
         ,group_header_id
         ,put_away_rule_id
         ,pick_rule_id
         ,lot_attribute_category
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,c_attribute1
         ,c_attribute2
         ,c_attribute3
         ,c_attribute4
         ,c_attribute5
         ,c_attribute6
         ,c_attribute7
         ,c_attribute8
         ,c_attribute9
         ,c_attribute10
         ,c_attribute11
         ,c_attribute12
         ,c_attribute13
         ,c_attribute14
         ,c_attribute15
         ,c_attribute16
         ,c_attribute17
         ,c_attribute18
         ,c_attribute19
         ,c_attribute20
         ,n_attribute1
         ,n_attribute2
         ,n_attribute3
         ,n_attribute4
         ,n_attribute5
         ,n_attribute6
         ,n_attribute7
         ,n_attribute8
         ,n_attribute9
         ,n_attribute10
         ,d_attribute1
         ,d_attribute2
         ,d_attribute3
         ,d_attribute4
         ,d_attribute5
         ,d_attribute6
         ,d_attribute7
         ,d_attribute8
         ,d_attribute9
         ,d_attribute10
         ,grade_code
         ,origination_date
         ,date_code
         ,change_date
         ,age
         ,retest_date
         ,maturity_date
         ,item_size
         ,color
         ,volume
         ,volume_uom
         ,place_of_origin
         ,best_by_date
         ,length
         ,length_uom
         ,recycled_content
         ,thickness
         ,thickness_uom
         ,width
         ,width_uom
         ,territory_code
         ,supplier_lot_number
         ,vendor_name
         ,vendor_id
         ,curl_wrinkle_fold
         ,description
         ,expiration_action_date
         ,expiration_action_code
         ,hold_date
         )
      (SELECT
         p_mtlt_tbl(l_counter).transaction_temp_id
         ,l_today
         ,l_user_id
         ,l_today
         ,l_user_id
         ,l_login_id
         ,p_mtlt_tbl(l_counter).request_id
         ,p_mtlt_tbl(l_counter).program_application_id
         ,p_mtlt_tbl(l_counter).program_id
         ,p_mtlt_tbl(l_counter).program_update_date
         ,p_mtlt_tbl(l_counter).transaction_quantity
         ,p_mtlt_tbl(l_counter).primary_quantity
         ,p_mtlt_tbl(l_counter).secondary_quantity
	 ,p_mtlt_tbl(l_counter).secondary_unit_of_measure  --Bug# 8217560
         ,p_mtlt_tbl(l_counter).lot_number
         ,p_mtlt_tbl(l_counter).lot_expiration_date
         ,p_mtlt_tbl(l_counter).error_code
         ,p_mtlt_tbl(l_counter).serial_transaction_temp_id
         ,p_mtlt_tbl(l_counter).group_header_id
         ,p_mtlt_tbl(l_counter).put_away_rule_id
         ,p_mtlt_tbl(l_counter).pick_rule_id
         ,mln.lot_attribute_category
         ,mln.attribute_category
         ,mln.attribute1
         ,mln.attribute2
         ,mln.attribute3
         ,mln.attribute4
         ,mln.attribute5
         ,mln.attribute6
         ,mln.attribute7
         ,mln.attribute8
         ,mln.attribute9
         ,mln.attribute10
         ,mln.attribute11
         ,mln.attribute12
         ,mln.attribute13
         ,mln.attribute14
         ,mln.attribute15
         ,mln.c_attribute1
         ,mln.c_attribute2
         ,mln.c_attribute3
         ,mln.c_attribute4
         ,mln.c_attribute5
         ,mln.c_attribute6
         ,mln.c_attribute7
         ,mln.c_attribute8
         ,mln.c_attribute9
         ,mln.c_attribute10
         ,mln.c_attribute11
         ,mln.c_attribute12
         ,mln.c_attribute13
         ,mln.c_attribute14
         ,mln.c_attribute15
         ,mln.c_attribute16
         ,mln.c_attribute17
         ,mln.c_attribute18
         ,mln.c_attribute19
         ,mln.c_attribute20
         ,mln.n_attribute1
         ,mln.n_attribute2
         ,mln.n_attribute3
         ,mln.n_attribute4
         ,mln.n_attribute5
         ,mln.n_attribute6
         ,mln.n_attribute7
         ,mln.n_attribute8
         ,mln.n_attribute9
         ,mln.n_attribute10
         ,mln.d_attribute1
         ,mln.d_attribute2
         ,mln.d_attribute3
         ,mln.d_attribute4
         ,mln.d_attribute5
         ,mln.d_attribute6
         ,mln.d_attribute7
         ,mln.d_attribute8
         ,mln.d_attribute9
         ,mln.d_attribute10
         ,mln.grade_code
         ,mln.origination_date
         ,mln.date_code
         ,mln.change_date
         ,mln.age
         ,mln.retest_date
         ,mln.maturity_date
         ,mln.item_size
         ,mln.color
         ,mln.volume
         ,mln.volume_uom
         ,mln.place_of_origin
         ,mln.best_by_date
         ,mln.length
         ,mln.length_uom
         ,mln.recycled_content
         ,mln.thickness
         ,mln.thickness_uom
         ,mln.width
         ,mln.width_uom
         ,mln.territory_code
         ,mln.supplier_lot_number
         ,mln.vendor_name
         ,mln.vendor_id
         ,mln.curl_wrinkle_fold
         ,mln.description
         ,mln.expiration_action_date
         ,mln.expiration_action_code
         ,mln.hold_date
      FROM mtl_material_transactions_temp mmtt,
           mtl_lot_numbers mln
      WHERE mmtt.transaction_temp_id = p_mtlt_tbl(l_counter).transaction_temp_id
      and mln.inventory_item_id = mmtt.inventory_item_id
      and mln.organization_id = mmtt.organization_id
      and mln.lot_number = p_mtlt_tbl(l_counter).lot_number
      );
   END LOOP;
   --
   -- debugging portion
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
EXCEPTION
   when fnd_api.g_exc_error then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_error;
      --
   when fnd_api.g_exc_unexpected_error then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
   when others then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) then
    fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
      end if;
      --
END insert_mtlt;
--
-- insert record into mtl_serial_numbers_temp
-- who columns will be derived in the procedure
PROCEDURE insert_msnt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_msnt_tbl       IN  g_msnt_tbl_type
   ,p_msnt_tbl_size  IN  INTEGER
   )
  IS
     l_api_name  CONSTANT VARCHAR2(30) := 'Insert_MSNT';
     l_today     DATE;
     l_user_id   NUMBER;
     l_login_id  NUMBER;
     l_rowid     VARCHAR2(20);
BEGIN
   --
   -- debugging portion
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   IF p_msnt_tbl_size IS NULL OR p_msnt_tbl_size < 1 THEN
      RETURN;
   END IF;
   --
   l_today := SYSDATE;
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   FOR l_counter IN 1..p_msnt_tbl_size LOOP
      INSERT INTO mtl_serial_numbers_temp
   (
     transaction_temp_id
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,vendor_serial_number
    ,vendor_lot_number
    ,fm_serial_number
    ,to_serial_number
    ,serial_prefix
    ,error_code
    ,group_header_id
    ,parent_serial_number
    ,end_item_unit_number
    )
   VALUES
   (
     p_msnt_tbl(l_counter).transaction_temp_id
    ,l_today
    ,l_user_id
    ,l_today
    ,l_user_id
    ,l_login_id
    ,p_msnt_tbl(l_counter).request_id
    ,p_msnt_tbl(l_counter).program_application_id
    ,p_msnt_tbl(l_counter).program_id
    ,p_msnt_tbl(l_counter).program_update_date
    ,p_msnt_tbl(l_counter).vendor_serial_number
    ,p_msnt_tbl(l_counter).vendor_lot_number
    ,p_msnt_tbl(l_counter).fm_serial_number
    ,p_msnt_tbl(l_counter).to_serial_number
    ,p_msnt_tbl(l_counter).serial_prefix
    ,p_msnt_tbl(l_counter).error_code
    ,p_msnt_tbl(l_counter).group_header_id
    ,p_msnt_tbl(l_counter).parent_serial_number
    ,p_msnt_tbl(l_counter).end_item_unit_number
    );
   END LOOP;
   --
   -- debugging portion
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
EXCEPTION
   when fnd_api.g_exc_error then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_error;
      --
   when fnd_api.g_exc_unexpected_error then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
   when others then
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) then
    fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
      end if;
      --
END insert_msnt;
--
-- Start of comments
-- Name        : split_prefix_num
-- Function    : Separates prefix and numeric part of a serial number
-- Pre-reqs    : none
-- Parameters  :
--  p_serial_number        in     varchar2
--  p_prefix               in/out varchar2      the prefix
--  x_num                  out    varchar2(30)  the numeric portion
-- Notes       : privat procedure for internal use only
--               needed only once serial numbers are supported
-- End of comments
--
PROCEDURE split_prefix_num
  (
    p_serial_number        IN     VARCHAR2
   ,p_prefix               IN OUT NOCOPY VARCHAR2
   ,x_num                  OUT    NOCOPY VARCHAR2
   ) is
      l_counter                     number;
BEGIN
   IF p_prefix IS NOT NULL THEN
      x_num := SUBSTR(p_serial_number,length(p_prefix)+1);
    ELSE
      l_counter := length(p_serial_number);
      WHILE l_counter >= 0 AND SUBSTR(p_serial_number,l_counter,1) >= '0' AND
   SUBSTR(p_serial_number,l_counter,1) <= '9'
   LOOP
      l_counter := l_counter - 1;
   END LOOP;
   IF l_counter = 0 THEN
      p_prefix := NULL;
    ELSE
      p_prefix := SUBSTR(p_serial_number,1,l_counter);
   END IF;
   x_num := SUBSTR(p_serial_number,l_counter+1);
   END IF;
END split_prefix_num;
--
-- Subtract two serial numbers and return the difference
FUNCTION subtract_serials
  (
   p_operand1      IN VARCHAR2,
   p_operand2      IN VARCHAR2
   ) RETURN NUMBER IS
      l_prefix1       VARCHAR2(30);
      l_prefix2       VARCHAR2(30);
      l_num1          NUMBER;
      l_num2          NUMBER;
      l_return        NUMBER;
BEGIN
   split_prefix_num(p_operand1,l_prefix1,l_num1);
   split_prefix_num(p_operand2,l_prefix2,l_num2);
   IF l_prefix1 = l_prefix2
     OR l_prefix1 IS NULL AND l_prefix2 IS NULL THEN
      l_return := NVL(l_num2,0) - NVL(l_num1,0);
    ELSE
      l_return := 0;
   END IF;
   RETURN(l_return);
END subtract_serials;
--
-- get the next val of mtl_material_transactions_s
FUNCTION next_temp_id RETURN NUMBER IS
   CURSOR l_cursor IS SELECT mtl_material_transactions_s.NEXTVAL
     FROM dual;
   l_temp_id NUMBER;
BEGIN
   OPEN l_cursor;
   FETCH l_cursor INTO l_temp_id;
   IF l_cursor%notfound THEN
      CLOSE l_cursor;
      RAISE no_data_found;
   END IF;
   CLOSE l_cursor;
   RETURN l_temp_id;
END next_temp_id;
--
-- get accounting period for an organization on a specific date, return -1 if
-- no data found
-- (copied from inltgp.ppc)
FUNCTION get_acct_period_id
  ( p_organization_id IN NUMBER, p_date IN DATE)
  RETURN NUMBER IS
     CURSOR l_cur IS
   SELECT acct_period_id
     FROM     org_acct_periods
     WHERE    period_close_date IS NULL
       AND    organization_id = p_organization_id
            AND    INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Nvl(p_date, Sysdate),p_organization_id)
            BETWEEN trunc(period_start_date)  and trunc(schedule_close_date)
       ORDER BY period_start_date DESC, schedule_close_date ASC;
     l_val NUMBER;
BEGIN

   IF nvl(g_acct_organization_id,-1) = p_organization_id Then
      l_val := g_acct_period_id;
   ELSE
      OPEN l_cur;
      FETCH l_cur INTO l_val;
      IF l_cur%notfound THEN
         l_val := -1;
      END IF;
      CLOSE l_cur;
      g_acct_period_id := l_val;
      g_acct_organization_id := p_organization_id;
   END IF;

   RETURN l_val;
END get_acct_period_id;
--
--
PROCEDURE init_output_process_tbl
  IS
     l_api_name VARCHAR2(30) := 'Init_Output_Process_Tbl';
BEGIN
   --
   -- debugging section
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   g_output_process_tbl_size := 0;
   g_output_process_tbl.DELETE;
   --
   -- debugging section
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
END init_output_process_tbl;
--
--
PROCEDURE add_output (p_output_process_rec IN  g_output_process_rec_type)
  IS
BEGIN
   -- this procedure has no debug section since it might be called
   -- too many times
   g_output_process_tbl_size := g_output_process_tbl_size +1;
   g_output_process_tbl(g_output_process_tbl_size) := p_output_process_rec;
END add_output;
--
--
-- Description
--   Set the group_mark_id in mtl_serial_numbers for all serial numbers
--   used in the output table to be the move order line id that
--   initiates the detailing request, so that they would not be used
--   by later detailing.
--   Bug #1267029
-- Changed how mark_serial_number works. Now, this procedure
-- is called for each input line in mtl_serial_numbers_temp.
-- It takes the inventory_item_id, group_mark_id, serial number
-- start, and serial number end.  It does not look at all the
-- output process records.
PROCEDURE mark_serial_numbers
  (p_inventory_item_id   IN NUMBER
  ,p_group_mark_id       IN NUMBER
  ,p_serial_number_start IN VARCHAR2
  ,p_serial_number_end   IN VARCHAR2)
  IS
BEGIN
    UPDATE mtl_serial_numbers
   SET group_mark_id = p_group_mark_id
   WHERE inventory_item_id = p_inventory_item_id
   AND serial_number between p_serial_number_start and p_serial_number_end;
END mark_serial_numbers;
--
PROCEDURE print_output_process_tbl
  (p_request_context IN g_request_context_rec_type)
  IS
BEGIN
   NULL;
/*
   IF p_request_context.transfer_flag THEN
      dbms_output.put_line('transfer_flag y');
    ELSE
      dbms_output.put_line('transfer_flag n');
   END IF;
   dbms_output.put_line('printing output process table');
   FOR l_index IN 1..g_output_process_tbl_size LOOP
      dbms_output.put_line('>> revision                ' || g_output_process_tbl(l_index).revision );
      dbms_output.put_line('   from_subinventory_code  ' || g_output_process_tbl(l_index).from_subinventory_code );
      dbms_output.put_line('   from_locator_id         ' || g_output_process_tbl(l_index).from_locator_id        );
      dbms_output.put_line('   to_subinventory_code    ' || g_output_process_tbl(l_index).to_subinventory_code   );
      dbms_output.put_line('   to_locator_id           ' || g_output_process_tbl(l_index).to_locator_id          );
      dbms_output.put_line('   lot_number              ' || g_output_process_tbl(l_index).lot_number             );
      dbms_output.put_line('   lot_expiration_date     ' || g_output_process_tbl(l_index).lot_expiration_date    );
      dbms_output.put_line('   serial_number_start     ' || g_output_process_tbl(l_index).serial_number_start          );
      dbms_output.put_line('   serial_number_end       ' || g_output_process_tbl(l_index).serial_number_end     );
      dbms_output.put_line('   transaction_quantity    ' || g_output_process_tbl(l_index).transaction_quantity   );
      dbms_output.put_line('   primary_quantity        ' || g_output_process_tbl(l_index).primary_quantity       );
      dbms_output.put_line('   pick_rule_id            ' || g_output_process_tbl(l_index).pick_rule_id           );
      dbms_output.put_line('   put_away_rule_id        ' || g_output_process_tbl(l_index).put_away_rule_id       );
      dbms_output.put_line('   reservation_id          ' || g_output_process_tbl(l_index).reservation_id         );
   END LOOP;
 */
   FOR l_index IN 1..g_output_process_tbl_size LOOP
      print_debug('>> revision                ' || g_output_process_tbl(l_index).revision );
      print_debug('   from_subinventory_code  ' || g_output_process_tbl(l_index).from_subinventory_code );
      print_debug('   from_locator_id         ' || g_output_process_tbl(l_index).from_locator_id        );
      print_debug('   to_subinventory_code    ' || g_output_process_tbl(l_index).to_subinventory_code   );
      print_debug('   to_locator_id           ' || g_output_process_tbl(l_index).to_locator_id          );
      print_debug('   lot_number              ' || g_output_process_tbl(l_index).lot_number             );
      print_debug('   lot_expiration_date     ' || g_output_process_tbl(l_index).lot_expiration_date    );
      print_debug('   serial_number_start     ' || g_output_process_tbl(l_index).serial_number_start          );
      print_debug('   serial_number_end       ' || g_output_process_tbl(l_index).serial_number_end     );
      print_debug('   transaction_quantity    ' || g_output_process_tbl(l_index).transaction_quantity   );
      print_debug('   primary_quantity        ' || g_output_process_tbl(l_index).primary_quantity       );
      print_debug('   secondary_quantity      ' || g_output_process_tbl(l_index).secondary_quantity       );
      print_debug('   pick_rule_id            ' || g_output_process_tbl(l_index).pick_rule_id           );
      print_debug('   put_away_rule_id        ' || g_output_process_tbl(l_index).put_away_rule_id       );
      print_debug('   reservation_id          ' || g_output_process_tbl(l_index).reservation_id         );
   END LOOP;

END print_output_process_tbl;
--
-- update detailed quantity column for reservations
-- Description
--   This needs to be done after process_output procedure is called.
--   It updates the detailed quantity column in the corresponding reservation records
--   to reflect the fact the process_output procedure has created the suggestions in mmtt
PROCEDURE update_detailed_quantities
  (x_return_status OUT NOCOPY VARCHAR2)
  IS
     l_reservation_id NUMBER;
BEGIN
   FOR l_index IN 1..g_output_process_tbl_size LOOP
      l_reservation_id := g_output_process_tbl(l_index).reservation_id ;
      IF l_reservation_id IS NOT NULL THEN
    UPDATE mtl_reservations
      SET detailed_quantity = detailed_quantity + g_output_process_tbl(l_index).primary_quantity
       ,  secondary_detailed_quantity = secondary_detailed_quantity + g_output_process_tbl(l_index).secondary_quantity
      WHERE reservation_id = l_reservation_id;
      END IF;
   END LOOP;
   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('INV','INV_UPD_RSV_FAILED');
      FND_MSG_PUB.Add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END update_detailed_quantities;
--
-- create suggestion records.
-- insert into mtl_material_transactions_temp, mtl_serial_numbers_temp,
-- or mtl_transaction_lots_temp
PROCEDURE process_output
  (x_return_status    OUT NOCOPY VARCHAR2,
   p_request_line_rec IN  g_request_line_rec_type,
   p_request_context  IN  g_request_context_rec_type,
   p_plan_tasks       IN  BOOLEAN
   ) IS
      l_api_name         CONSTANT VARCHAR2(30) := 'Process_Output';
      l_debug            NUMBER;
      l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_insert_lot       BOOLEAN; -- insert a new lot record
      l_insert_serial    BOOLEAN; -- insert a new serial record
      l_insert_txn       BOOLEAN; -- insert a new transaction temp record
      l_txn_temp_id      NUMBER;
      l_txn_header_id    NUMBER;
      l_serial_temp_id   NUMBER;
      l_txn_temp_qty     NUMBER;
      l_lot_temp_qty     NUMBER;
      l_sec_txn_temp_qty     NUMBER;
      l_sec_lot_temp_qty     NUMBER;
      l_qty_sign         NUMBER;
      --
      l_mmtt_tbl         g_mmtt_tbl_type;
      l_mtlt_tbl         g_mtlt_tbl_type;
      l_msnt_tbl         g_msnt_tbl_type;
      l_mmtt_tbl_size    INTEGER;
      l_mtlt_tbl_size    INTEGER;
      l_msnt_tbl_size    INTEGER;
      --
      l_serial_index_start   INTEGER;
      l_serial_index_in_loop INTEGER;
      l_proj_enabled  NUMBER;
      l_today      DATE;
      l_status     VARCHAR2(1);
      l_msg_data           VARCHAR2(2000);
      l_msg_count  NUMBER;
      l_task_priority    NUMBER;
       --8498798
      l_l_txn_temp_qty   NUMBER;
      l_l_lot_temp_qty   NUMBER;

BEGIN
   -- debugging section
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   IF g_debug IS NULL or NOT INV_CACHE.is_pickrelease THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),2);
   END IF;
   l_debug := g_debug;

   IF l_debug = 1 THEN
     print_debug('in process output ');
     print_output_process_tbl(p_request_context);
   END IF;
   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   IF g_output_process_tbl_size IS NULL OR
     g_output_process_tbl_size < 1 THEN
      RETURN;
   END IF;
   g_insert_lot_flag := 0;
   g_insert_serial_flag := 0;
   --
   -- The following code is commented because
   -- the sign for the quantity in mtl_material_transactions_temp
   -- and mtl_transaction_lots_temp and mtl_serial_numbers_temp
   -- for the suggestion records will be positive always.
   -- The reason is that the move order transaction form
   -- and api expect the quantity to be positive regardless
   -- what transaction (pick/put) it is. The form or the
   -- api will actually call a procedure to negate the
   -- quantity if necessary, before performing the transactions
   --
   --    IF p_request_context.transfer_flag -- transfer
   --      OR p_request_context.type_code = 1 -- put away
   --      THEN
   --       l_qty_sign := 1;
   --     ELSE
   --       l_qty_sign := -1;
   --    END IF;
   l_qty_sign := 1;
   SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
     INTO l_txn_header_id FROM DUAL;
   g_transaction_header_id := l_txn_header_id;
   SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
     INTO l_txn_temp_id FROM DUAL;
   IF p_request_context.item_lot_control_code = 2 THEN
   SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
     INTO l_serial_temp_id FROM DUAL;
   END IF;
   l_mmtt_tbl_size := 0;
   l_mtlt_tbl_size := 0;
   l_msnt_tbl_size := 0;
   IF p_request_context.item_lot_control_code = 2 THEN
      l_lot_temp_qty := g_output_process_tbl(1).primary_quantity;
      l_sec_lot_temp_qty := g_output_process_tbl(1).secondary_quantity;
   END IF;
   l_txn_temp_qty := g_output_process_tbl(1).primary_quantity;
   l_sec_txn_temp_qty := g_output_process_tbl(1).secondary_quantity;
   --IF inv_pp_debug.is_debug_mode THEN
     print_debug('process output before loop, lot pri qty '||l_lot_temp_qty);
     print_debug('process output before loop, lot sec qty '||l_sec_lot_temp_qty);
     print_debug('process output before loop, txn pri qty '||l_txn_temp_qty);
     print_debug('process output before loop, txn sec qty '||l_sec_txn_temp_qty);
   --END IF;
   FOR l_index IN 2..g_output_process_tbl_size+1 LOOP
      l_insert_serial := FALSE;
      l_insert_lot := FALSE;
      l_insert_txn := FALSE;
      --bug 1500614 - added reservation_id to this stmt so that
      --we insert only one MMTT record per reservation id
      -- bug 2111022 - add cost_group_id to this stmt
      --bug 2573353 - remove cost group id from this stmt, as we
      -- no longer allocate cost group
      IF l_index = g_output_process_tbl_size+1
           OR p_request_context.item_revision_control =2
              AND g_output_process_tbl(l_index).revision
                  <> g_output_process_tbl(l_index-1).revision
           OR g_output_process_tbl(l_index).from_subinventory_code <>
              g_output_process_tbl(l_index-1).from_subinventory_code
           OR NOT(g_output_process_tbl(l_index).from_locator_id IS NULL
                  AND g_output_process_tbl(l_index-1).from_locator_id IS NULL
                  OR g_output_process_tbl(l_index).from_locator_id
                     = g_output_process_tbl(l_index-1).from_locator_id
                  )
           OR g_output_process_tbl(l_index).to_subinventory_code <>
              g_output_process_tbl(l_index-1).to_subinventory_code
           OR NOT(g_output_process_tbl(l_index).to_locator_id IS NULL
                  AND g_output_process_tbl(l_index-1).to_locator_id IS NULL
                  OR g_output_process_tbl(l_index).to_locator_id
                  = g_output_process_tbl(l_index-1).to_locator_id)
           OR NOT((g_output_process_tbl(l_index).reservation_id IS NULL
                  AND g_output_process_tbl(l_index-1).reservation_id IS NULL)
                  OR g_output_process_tbl(l_index).reservation_id
                  = g_output_process_tbl(l_index-1).reservation_id)
           OR NOT((g_output_process_tbl(l_index).lpn_id IS NULL
                  AND g_output_process_tbl(l_index-1).lpn_id IS NULL)
                  OR NVL(g_output_process_tbl(l_index).lpn_id, -9999)
                  = NVL(g_output_process_tbl(l_index-1).lpn_id, -9999))
          /*
           *OR NOT((g_output_process_tbl(l_index).from_cost_group_id IS NULL
           *     AND g_output_process_tbl(l_index-1).from_cost_group_id IS NULL)
           *      OR g_output_process_tbl(l_index).from_cost_group_id
           *      = g_output_process_tbl(l_index-1).from_cost_group_id)
           */
      THEN
         l_insert_txn := TRUE;
      END IF;
      IF p_request_context.item_lot_control_code = 2
        AND (l_insert_txn OR
             g_output_process_tbl(l_index).lot_number
             <> g_output_process_tbl(l_index-1).lot_number
            ) THEN
         l_insert_lot := TRUE;
         g_insert_lot_flag := 1;
      END IF;
      -- ugly, will try to clean later
      IF p_request_context.item_serial_control_code IN (2,5,6)
        AND g_output_process_tbl(l_index-1).serial_number_start IS NOT NULL
        AND (l_insert_txn OR l_insert_lot OR
       g_output_process_tbl(l_index).serial_number_start IS NULL
       OR g_output_process_tbl(l_index).serial_number_start
       <> g_output_process_tbl(l_index-1).serial_number_start)
      THEN
        -- I rather not do the range overlapping comparision in the
        -- condition for this if clause since that is overkill.
        -- I assume the serial number will not overlap
         l_insert_serial := TRUE;
         g_insert_serial_flag := 1;
      END IF;
      IF l_insert_serial THEN
        l_msnt_tbl_size := l_msnt_tbl_size +1;
        l_msnt_tbl(l_msnt_tbl_size).fm_serial_number := g_output_process_tbl(l_index-1).serial_number_start;
        l_msnt_tbl(l_msnt_tbl_size).to_serial_number := g_output_process_tbl(l_index-1).serial_number_end;
        l_msnt_tbl(l_msnt_tbl_size).end_item_unit_number := p_request_line_rec.unit_number;
         l_msnt_tbl(l_msnt_tbl_size).serial_prefix := '1';
        IF p_request_context.item_lot_control_code = 2 THEN
           l_msnt_tbl(l_msnt_tbl_size).transaction_temp_id := l_serial_temp_id;
        ELSE
           l_msnt_tbl(l_msnt_tbl_size).transaction_temp_id := l_txn_temp_id;
        END IF;
        mark_serial_numbers(
           p_request_line_rec.inventory_item_id,
           l_msnt_tbl(l_msnt_tbl_size).transaction_temp_id,
           l_msnt_tbl(l_msnt_tbl_size).fm_serial_number,
           l_msnt_tbl(l_msnt_tbl_size).to_serial_number);
      END IF;
      IF l_insert_lot THEN
         l_mtlt_tbl_size := l_mtlt_tbl_size +1;
         l_mtlt_tbl(l_mtlt_tbl_size).transaction_temp_id := l_txn_temp_id;
         l_mtlt_tbl(l_mtlt_tbl_size).primary_quantity := l_qty_sign * l_lot_temp_qty;
         l_mtlt_tbl(l_mtlt_tbl_size).secondary_quantity := l_qty_sign * l_sec_lot_temp_qty;
	 l_mtlt_tbl(l_mtlt_tbl_size).secondary_unit_of_measure := p_request_context.secondary_uom_code;  --Bug#8217560
         IF inv_pp_debug.is_debug_mode THEN
           print_debug('process output , lot pri qty '||l_lot_temp_qty);
           print_debug('process output , lot sec qty '||l_sec_lot_temp_qty);
         END IF;
         l_mtlt_tbl(l_mtlt_tbl_size).lot_number := g_output_process_tbl(l_index-1).lot_number;
         l_mtlt_tbl(l_mtlt_tbl_size).lot_expiration_date := g_output_process_tbl(l_index-1).lot_expiration_date;
         If l_insert_serial Then
           l_mtlt_tbl(l_mtlt_tbl_size).serial_transaction_temp_id := l_serial_temp_id;
         End If;
         IF p_request_context.primary_uom_code <> p_request_context.transaction_uom_code THEN

	    --Start 8498798: When the suggested qty is in decimals according to Txn Uom then convert the
	    -- Uom to Primary Uom so that the qty is a integer.
            l_l_lot_temp_qty := inv_convert.inv_um_convert
           (
            p_request_line_rec.inventory_item_id,
            NULL,
            l_lot_temp_qty,
            p_request_context.primary_uom_code,
            p_request_context.transaction_uom_code,
            NULL,
            NULL);

            IF (l_l_lot_temp_qty = Trunc(l_l_lot_temp_qty,0)) THEN
              l_mtlt_tbl(l_mtlt_tbl_size).transaction_quantity := l_qty_sign * l_l_lot_temp_qty;

            ELSE
              l_mtlt_tbl(l_mtlt_tbl_size).transaction_quantity := l_qty_sign * l_lot_temp_qty;

            END IF;
            /*
            l_mtlt_tbl(l_mtlt_tbl_size).transaction_quantity :=
              l_qty_sign *
              inv_convert.inv_um_convert
              (
               p_request_line_rec.inventory_item_id,
               NULL,
               l_lot_temp_qty,
               p_request_context.primary_uom_code,
               p_request_context.transaction_uom_code,
               NULL,
               NULL);  */
            -- End 8498798

         ELSE
            l_mtlt_tbl(l_mtlt_tbl_size).transaction_quantity := l_qty_sign * l_lot_temp_qty;
         END IF;
         l_mtlt_tbl(l_mtlt_tbl_size).pick_rule_id := g_output_process_tbl(l_index-1).pick_rule_id;
         l_mtlt_tbl(l_mtlt_tbl_size).put_away_rule_id := g_output_process_tbl(l_index-1).put_away_rule_id;
      END IF;
      IF l_insert_txn THEN
         l_mmtt_tbl_size := l_mmtt_tbl_size +1;
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_header_id := l_txn_header_id;
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_temp_id := l_txn_temp_id;
         l_mmtt_tbl(l_mmtt_tbl_size).inventory_item_id   := p_request_line_rec.inventory_item_id;
         l_mmtt_tbl(l_mmtt_tbl_size).revision := g_output_process_tbl(l_index-1).revision;
         l_mmtt_tbl(l_mmtt_tbl_size).organization_id := p_request_line_rec.organization_id;
         IF p_request_context.transfer_flag -- transfer
           OR p_request_context.type_code = 2 -- picking
           THEN
            l_mmtt_tbl(l_mmtt_tbl_size).subinventory_code := g_output_process_tbl(l_index-1).from_subinventory_code;
            l_mmtt_tbl(l_mmtt_tbl_size).locator_id := g_output_process_tbl(l_index-1).from_locator_id;
            --bug 2573353 - do not allocate cost group
            --l_mmtt_tbl(l_mmtt_tbl_size).cost_group_id := --  g_output_process_tbl(l_index-1).from_cost_group_id;
            IF p_request_context.transfer_flag THEN
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_subinventory := g_output_process_tbl(l_index-1).to_subinventory_code;
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_to_location := g_output_process_tbl(l_index-1).to_locator_id;
               --bug 2573353 - do not allocate cost group
               --l_mmtt_tbl(l_mmtt_tbl_size).transfer_cost_group_id := --  g_output_process_tbl(l_index-1).to_cost_group_id;
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_organization := p_request_line_rec.to_organization_id;
             ELSE
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_subinventory := NULL;
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_to_location := NULL;
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_organization := NULL;
               l_mmtt_tbl(l_mmtt_tbl_size).transfer_cost_group_id := NULL;
            END IF;
            -- for transfer or picking only, store the reservation id
            -- in the mmtt record
            l_mmtt_tbl(l_mmtt_tbl_size).reservation_id := g_output_process_tbl(l_index-1).reservation_id;
            l_mmtt_tbl(l_mmtt_tbl_size).allocated_lpn_id := g_output_process_tbl(l_index-1).lpn_id;
          ELSE -- put away
            l_mmtt_tbl(l_mmtt_tbl_size).subinventory_code :=
              g_output_process_tbl(l_index-1).to_subinventory_code;
            --bug 2573353 - do not allocate cost group
            --bug 2661134/2747315 - for putaway transactions, we need to
            --  copy the to cost group on the move order line to the
            --  MMTT record
            l_mmtt_tbl(l_mmtt_tbl_size).cost_group_id :=
              g_output_process_tbl(l_index-1).to_cost_group_id;
            l_mmtt_tbl(l_mmtt_tbl_size).locator_id :=
              g_output_process_tbl(l_index-1).to_locator_id;
            l_mmtt_tbl(l_mmtt_tbl_size).organization_id   :=
              p_request_line_rec.to_organization_id;
            -- 4292416: planned crossdocking
            IF p_request_line_rec.crossdock_type = 2
            THEN
               l_mmtt_tbl(l_mmtt_tbl_size).demand_source_header_id :=
                 p_request_line_rec.wip_entity_id;
               l_mmtt_tbl(l_mmtt_tbl_size).repetitive_line_id :=
                 p_request_line_rec.repetitive_schedule_id;
               l_mmtt_tbl(l_mmtt_tbl_size).operation_seq_num :=
                 p_request_line_rec.operation_seq_num;
               l_mmtt_tbl(l_mmtt_tbl_size).wip_supply_type :=
                 p_request_line_rec.wip_supply_type;
            END IF;
         END IF;
         l_mmtt_tbl(l_mmtt_tbl_size).primary_quantity:=
           l_qty_sign * l_txn_temp_qty;
         l_mmtt_tbl(l_mmtt_tbl_size).secondary_transaction_quantity:=
           l_qty_sign * l_sec_txn_temp_qty;
         IF inv_pp_debug.is_debug_mode THEN
             print_debug('process output , txn pri qty '||l_txn_temp_qty);
             print_debug('process output , txn sec qty '||l_sec_txn_temp_qty);
             inv_pp_debug.send_message_to_pipe('pri qty '|| l_txn_temp_qty);
             inv_pp_debug.send_message_to_pipe('qty_sign' || l_qty_sign);
             inv_pp_debug.send_message_to_pipe('sec qty '|| l_sec_txn_temp_qty);
         END IF;

	 --Start 8498798
           l_l_txn_temp_qty := inv_convert.inv_um_convert
           (
            p_request_line_rec.inventory_item_id,
            NULL,
            l_txn_temp_qty,
            p_request_context.primary_uom_code,
            p_request_context.transaction_uom_code,
            NULL,
            NULL);

            IF (l_l_txn_temp_qty = Trunc(l_l_txn_temp_qty,0)) THEN
              l_mmtt_tbl(l_mmtt_tbl_size).transaction_quantity := l_qty_sign * l_l_txn_temp_qty;
              l_mmtt_tbl(l_mmtt_tbl_size).transaction_uom := p_request_context.transaction_uom_code;

            ELSE
              l_mmtt_tbl(l_mmtt_tbl_size).transaction_quantity := l_qty_sign * l_txn_temp_qty;
              l_mmtt_tbl(l_mmtt_tbl_size).transaction_uom := p_request_context.primary_uom_code;

            --Bug9589679 Setting the uom and quantity to primary uom and primary quantity respectively.

	    IF l_index = 2 THEN
                UPDATE mtl_txn_request_lines
                SET quantity = Round(primary_quantity),
                uom_code = p_request_context.primary_uom_code
                WHERE line_id = p_request_line_rec.line_id;
            END IF;

            END IF;

            /*

           l_mmtt_tbl(l_mmtt_tbl_size).transaction_quantity :=
           l_qty_sign *
           inv_convert.inv_um_convert
           (
            p_request_line_rec.inventory_item_id,
            NULL,
            l_txn_temp_qty,
            p_request_context.primary_uom_code,
            p_request_context.transaction_uom_code,
            NULL,
            NULL);   */

            --End 8498798

	 /* jxlu bug 1544670: need to populate column item_primary_uom_code */
         l_mmtt_tbl(l_mmtt_tbl_size).item_primary_uom_code := p_request_context.primary_uom_code;
         /* end of bug 1544670  */
         /* BUG 5338723 - The lpn_id should be set from the output table if it was not supplied on the mo line */
         IF p_request_line_rec.lpn_id IS NOT NULL THEN
            l_mmtt_tbl(l_mmtt_tbl_size).lpn_id := p_request_line_rec.lpn_id;
         ELSE
            l_mmtt_tbl(l_mmtt_tbl_size).lpn_id := g_output_process_tbl(l_index-1).lpn_id;
         END IF;
         /* end of BUG 5338723 */
         l_mmtt_tbl(l_mmtt_tbl_size).secondary_uom_code          := p_request_context.secondary_uom_code;
         --l_mmtt_tbl(l_mmtt_tbl_size).lpn_id                      := p_request_line_rec.lpn_id;

         -- 8498798
	 -- l_mmtt_tbl(l_mmtt_tbl_size).transaction_uom          := p_request_context.transaction_uom_code;

         l_mmtt_tbl(l_mmtt_tbl_size).transaction_type_id         := p_request_line_rec.transaction_type_id;
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_action_id       := p_request_context.transaction_action_id;
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_source_type_id  := p_request_line_rec.transaction_source_type_id;
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_source_id       := p_request_context.txn_header_id;
         l_mmtt_tbl(l_mmtt_tbl_size).trx_source_line_id          := p_request_context.txn_line_id;
         l_mmtt_tbl(l_mmtt_tbl_size).trx_source_delivery_id      := p_request_context.txn_line_detail;
         l_mmtt_tbl(l_mmtt_tbl_size).demand_source_line          := p_request_context.txn_line_id;
         l_mmtt_tbl(l_mmtt_tbl_size).demand_source_delivery      := p_request_context.txn_line_detail;
         l_mmtt_tbl(l_mmtt_tbl_size).wms_task_type               := p_request_context.wms_task_type;
    --Add the new column WMS_tASK_STATUS to MMTT
    IF p_plan_tasks THEN
      -- set status to unreleased if plan_tasks is true
      l_mmtt_tbl(l_mmtt_tbl_size).wms_task_status := 8;
    ELSE
       -- set status to pending if plan_tasks is fasle
      l_mmtt_tbl(l_mmtt_tbl_size).wms_task_status := 1;
    END IF;

    --l_mmtt_tbl(l_mmtt_tbl_size).transaction_source_name :=
         --  p_request_line_rec.transaction_source_name;
         l_today := nvl(inv_cache.mo_transaction_date, SYSDATE);

         l_mmtt_tbl(l_mmtt_tbl_size).transaction_date := l_today;
    -- get accounting period id
    IF p_request_context.transfer_flag -- transfer
           OR p_request_context.type_code = 2 THEN -- picking
       l_mmtt_tbl(l_mmtt_tbl_size).acct_period_id :=
         get_acct_period_id(p_request_line_rec.organization_id,
             l_today);
     ELSE
       l_mmtt_tbl(l_mmtt_tbl_size).acct_period_id :=
         get_acct_period_id(p_request_line_rec.to_organization_id,
             l_today);
    END IF;
         IF l_mmtt_tbl(l_mmtt_tbl_size).acct_period_id = -1 THEN
            FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            raise FND_API.G_EXC_ERROR;
         END IF;
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_reference :=
           p_request_line_rec.reference;
         l_mmtt_tbl(l_mmtt_tbl_size).reason_id :=
           p_request_line_rec.reason_id;
    -- do not store lot number or lot expiration date in mmtt
    -- they are in the lots temp table (mtlt)
         l_mmtt_tbl(l_mmtt_tbl_size).lot_number := NULL;
         l_mmtt_tbl(l_mmtt_tbl_size).lot_expiration_date := NULL;
         l_mmtt_tbl(l_mmtt_tbl_size).serial_number := NULL;
         l_mmtt_tbl(l_mmtt_tbl_size).pick_rule_id :=
           g_output_process_tbl(l_index-1).pick_rule_id;
         l_mmtt_tbl(l_mmtt_tbl_size).put_away_rule_id :=
           g_output_process_tbl(l_index-1).put_away_rule_id;
         l_mmtt_tbl(l_mmtt_tbl_size).pick_strategy_id :=
           p_request_context.pick_strategy_id;
         l_mmtt_tbl(l_mmtt_tbl_size).put_away_strategy_id :=
           p_request_context.put_away_strategy_id;
         l_mmtt_tbl(l_mmtt_tbl_size).posting_flag :=
      p_request_context.posting_flag;
         l_mmtt_tbl(l_mmtt_tbl_size).process_flag := 'Y';
         l_mmtt_tbl(l_mmtt_tbl_size).transaction_status := 2; -- suggestions
         -- which column stores the request line id?
         l_mmtt_tbl(l_mmtt_tbl_size).move_order_line_id :=
           p_request_line_rec.line_id;
         /* BUG 3181559: item_lot_control_code and item_serial_control_code need to be populated */
         l_mmtt_tbl(l_mmtt_tbl_size).item_lot_control_code :=
           p_request_context.item_lot_control_code;
         l_mmtt_tbl(l_mmtt_tbl_size).item_serial_control_code :=
           p_request_context.item_serial_control_code;
         /* New columns move_order_header_id and serial_allocated_flag added to MMTT for Bulk Picking*/
         l_mmtt_tbl(l_mmtt_tbl_size).move_order_header_id :=
           p_request_line_rec.header_id;
         IF l_insert_serial THEN
           l_mmtt_tbl(l_mmtt_tbl_size).serial_allocated_flag := 'Y';
         ELSIF p_request_context.item_serial_control_code <> 1 THEN
           l_mmtt_tbl(l_mmtt_tbl_size).serial_allocated_flag := 'N';
         END IF;
         -- 4292157: task priority project
         l_task_priority := NVL(inv_cache.wpb_rec.task_priority,-1);
         IF l_task_priority > 0 AND inv_cache.wms_installed
         THEN
            l_mmtt_tbl(l_mmtt_tbl_size).task_priority := l_task_priority;
         END IF;

         -- IF ( WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= INV_RELEASE.G_J_RELEASE_LEVEL) then
         -- END IF;
        /* bug 2372764 - since we can pick from projects other than the
    *project on the move order line, we leave these columns blank
       *and let the TM derive the info
    l_mmtt_tbl(l_mmtt_tbl_size).project_id :=
      p_request_line_rec.project_id;
    l_mmtt_tbl(l_mmtt_tbl_size).task_id :=
      p_request_line_rec.task_id;
       */
    --if transaction_action is issue, and transaction_type is
    -- project_enabled or transaction source type is WIP,
    -- copy task and project into source task and proj
    IF p_request_context.transaction_action_id = 1 THEN --issue from stores

      IF p_request_line_rec.transaction_source_type_id = 5 THEN --WIP
               l_mmtt_tbl(l_mmtt_tbl_size).source_project_id :=
                 p_request_line_rec.project_id;
               l_mmtt_tbl(l_mmtt_tbl_size).source_task_id :=
                 p_request_line_rec.task_id;
           ELSE
        IF inv_cache.set_mtt_rec(p_request_line_rec.transaction_type_id) THEN
      l_proj_enabled :=  NVL(inv_cache.mtt_rec.type_class,2);
        END IF;

             --find out if network logistics is installed
        IF g_nl_installed is NULL THEN
                g_nl_installed := inv_check_product_install.check_cse_install(
                          x_return_status          =>  l_status
                         ,x_msg_count          =>  l_msg_count
                         ,x_msg_data           =>  l_msg_data);
        END IF;

             /* Bug 3228686. Move order issue to Project could be performed
              * in non-pjm enabled organization
              */

        IF l_proj_enabled = 1 THEN  --1 is enabled, 2 means not enabled
           l_mmtt_tbl(l_mmtt_tbl_size).source_project_id :=
       p_request_line_rec.project_id;
           l_mmtt_tbl(l_mmtt_tbl_size).source_task_id :=
       p_request_line_rec.task_id;
        END IF;
           END IF;

           /* Bug : 3622435. Issue transactions should be populated with
            * distribution_account_id.
       */

      l_mmtt_tbl(l_mmtt_tbl_size).distribution_account_id  :=
            p_request_line_rec.to_account_id;

      IF ( l_debug = 1 ) THEN
              print_debug('distribution_account_id = '
                || l_mmtt_tbl(l_mmtt_tbl_size).distribution_account_id);
           END IF;
    END IF;
      END IF;
      IF l_index >= g_output_process_tbl_size+1 THEN
         EXIT;  -- we are done with the output creation
      END IF;
      IF l_insert_lot THEN
         -- reset the quantity for the next mtlt record
         l_lot_temp_qty := 0;
         l_sec_lot_temp_qty := 0;
         -- see whether we need a new l_serial_temp_id
         IF p_request_context.item_serial_control_code IN (2,5,6) THEN
            -- get the serial temp id if serial control is yes
            SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
              INTO l_serial_temp_id FROM DUAL;
         END IF;
      END IF;
      IF p_request_context.item_lot_control_code = 2 THEN
         -- lot control is yes
         -- accumulate the quantity from g_output_process_tbl(l_index)
         -- for the lot
         -- to be inserted next time regardless whether serial number
         -- control is yes or no
         l_lot_temp_qty := l_lot_temp_qty
           + g_output_process_tbl(l_index).primary_quantity;
         l_sec_lot_temp_qty := l_sec_lot_temp_qty
           + g_output_process_tbl(l_index).secondary_quantity;
      END IF;
      IF l_insert_txn THEN
         -- reset the quantity for the next mmtt record
         l_txn_temp_qty := 0;
         l_sec_txn_temp_qty := 0;
         SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
              INTO l_txn_temp_id FROM DUAL;
      END IF;
      -- accumulate the quantity from g_output_process_tbl(l_index)
      -- for the next mmtt record
      l_txn_temp_qty := l_txn_temp_qty
        + g_output_process_tbl(l_index).primary_quantity;
      l_sec_txn_temp_qty := l_sec_txn_temp_qty
        + g_output_process_tbl(l_index).secondary_quantity;
   END LOOP;
   IF l_mmtt_tbl_size > 0 THEN
      insert_mmtt
        (
         x_return_status   => l_return_status   ,
         p_mmtt_tbl        => l_mmtt_tbl        ,
         p_mmtt_tbl_size   => l_mmtt_tbl_size
         );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   IF l_mtlt_tbl_size > 0 THEN
      insert_mtlt
        (
         x_return_status   => l_return_status   ,
         p_mtlt_tbl        => l_mtlt_tbl        ,
         p_mtlt_tbl_size   => l_mtlt_tbl_size
         );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   IF l_msnt_tbl_size > 0 THEN
      insert_msnt
        (
         x_return_status   => l_return_status   ,
         p_msnt_tbl        => l_msnt_tbl        ,
         p_msnt_tbl_size   => l_msnt_tbl_size
         );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   IF p_request_context.detail_serial AND
     (p_request_context.transfer_flag OR
      p_request_context.type_code = 2) THEN
      -- in the case of picking or transfer
      -- mark all serial numbers inserted above as used
      --bug #1267029 - mark serial numbers called once for each
      --output record.
      --mark_serial_numbers(p_request_line_rec, l_txn_temp_id);
      -- clear in memory serial numbers detailing table
      init_output_serial_rows;
   END IF;
   --Bug 1766302
   -- Quantity tree was reporting wrong values because we were updating
   -- detailed quantity but not updating the quantity tree.
   -- Since we update detailed_quantity in INV_PICK_RELEASE_PVT.Process_line,
   -- we don't need to do it here.
   --update_detailed_quantities(l_return_status);
   --IF l_return_status = fnd_api.g_ret_sts_error THEN
   --   RAISE fnd_api.g_exc_error;
   --END IF;
   --IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
   --   RAISE fnd_api.g_exc_unexpected_error;
   --END IF;
   x_return_status := l_return_status;
   --
   -- debugging section
   -- can be commented ut for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('=================== create output records: ');
      inv_pp_debug.send_message_to_pipe('# of records inserted to mtl_material_transactions_temp: '
               || l_mmtt_tbl_size);
      inv_pp_debug.send_message_to_pipe('# of records inserted to mtl_transaction_lots_temp: '
               || l_mtlt_tbl_size);
      inv_pp_debug.send_message_to_pipe('# of records inserted to mtl_serial_numbers_temp: '
               || l_msnt_tbl_size);
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
   WHEN OTHERS THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END process_output;
FUNCTION is_sub_loc_lot_reservable(
         p_organization_id            IN NUMBER
        ,p_inventory_item_id          IN NUMBER
        ,p_subinventory_code          IN VARCHAR2
        ,p_locator_id                 IN NUMBER
        ,p_lot_number                 IN VARCHAR2
) RETURN BOOLEAN IS
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(240);
  l_api_name constant varchar(30) := 'is_sub_loc_lot_rsv_allowed';
  l_sub_reservable NUMBER;
  l_loc_reservable NUMBER;
  l_lot_reservable NUMBER;

  CURSOR c_sub_status (p_organization_id in NUMBER
                    ,  p_subinventory_code in varchar2
                    )
  IS
  SELECT decode(reservable_type,2,0,reservable_type)
  FROM mtl_secondary_inventories
  WHERE organization_id = p_organization_id
   AND secondary_inventory_name = p_subinventory_code;

  CURSOR c_loc_status (p_organization_id in NUMBER
                    ,  p_locator_id in NUMBER
                    )
  IS
  SELECT decode(reservable_type,2,0,reservable_type)
  FROM mtl_item_locations
  WHERE organization_id = p_organization_id
   AND inventory_location_id = p_locator_id;

  CURSOR c_lot_status (p_organization_id in NUMBER
                    ,  p_lot_number in varchar2)
                    IS
  SELECT decode(reservable_type,2,0,reservable_type)
  FROM mtl_lot_numbers
  WHERE organization_id = p_organization_id
   AND inventory_item_id = p_inventory_item_id
   AND lot_number = p_lot_number;

BEGIN

  l_sub_reservable := 1;
  l_lot_reservable := 1;
  l_loc_reservable := 1;

  print_debug('check sub_lot_loc_reservable p_organization_id '||p_organization_id);
  print_debug('check sub_lot_loc_reservable p_subinventory_code '||p_subinventory_code);
  print_debug('check sub_lot_loc_reservable p_locator_id '||p_locator_id);
  print_debug('check sub_lot_loc_reservable p_lot_number '||p_lot_number);
  IF p_subinventory_code IS NOT NULL THEN
        OPEN c_sub_status(p_organization_id,p_subinventory_code);

        FETCH c_sub_status INTO l_sub_reservable;
        IF c_sub_status%NOTFOUND THEN
           l_sub_reservable := 0;
        END IF;
        CLOSE c_sub_status;
     print_debug('check sub_lot_loc_reservable l_sub_reservable '||l_sub_reservable);
  END IF;

  /* check the profile value, if set only sub reservable is checked */

  IF p_locator_id IS NOT NULL THEN
     --get status
        OPEN c_loc_status(p_organization_id, p_locator_id);
        FETCH c_loc_status INTO l_loc_reservable;
        IF c_loc_status%NOTFOUND THEN
           l_loc_reservable := 0;
        END IF;
        CLOSE c_loc_status;
     print_debug('check sub_lot_loc_reservable l_loc_reservable '||l_loc_reservable);
  END IF;

  if p_lot_number IS NOT NULL THEN
     --get status
        OPEN c_lot_status(p_organization_id, p_lot_number);
        FETCH c_lot_status INTO l_lot_reservable;
        IF c_lot_status%NOTFOUND THEN
           l_lot_reservable := 0;
        END IF;
        CLOSE c_lot_status;
     print_debug('check sub_lot_loc_reservable l_lot_reservable '||l_lot_reservable);
  END IF;

  IF (l_sub_reservable * l_loc_reservable * l_lot_reservable = 1 )THEN
     print_debug('check sub_lot_loc_reservable returning true ');
     return TRUE;
  ELSE
     print_debug('check sub_lot_loc_reservable returning false ');
     return FALSE;          -- anything with 0 is a 'N'
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get( p_count => l_msg_count
                              ,p_data  => l_msg_data );
     print_debug('check sub_lot_loc_reservable exception false ');
    return FALSE;

END is_sub_loc_lot_reservable;

FUNCTION get_organization_code(
         p_organization_id            IN NUMBER
) RETURN VARCHAR2 IS

l_organization_code       Varchar2(10);

Cursor get_org (p_organization_id IN NUMBER) is
Select organization_code
from mtl_parameters
Where organization_id = p_organization_id;
Begin
  Open get_org(p_organization_id);
  Fetch get_org into l_organization_code;
  Close get_org;
  Return l_organization_code;
End get_organization_code;

PROCEDURE set_mo_transact_date (
        p_date    IN   DATE) IS
BEGIN
  inv_cache.mo_transaction_date := p_date;
END;

PROCEDURE clear_mo_transact_date  IS
BEGIN
  inv_cache.mo_transaction_date := NULL;
END;


-- LPN Status Project
FUNCTION is_onhand_status_trx_allowed(
    p_transaction_type_id  IN NUMBER
   ,p_organization_id   IN NUMBER
   ,p_inventory_item_id IN NUMBER
   ,p_subinventory_code IN VARCHAR2
   ,p_locator_id     IN NUMBER
   ,p_lot_number     IN VARCHAR2
   ,p_lpn_id         IN NUMBER
   ) RETURN VARCHAR2 IS


  l_api_name VARCHAR2(30) := 'is_onhand_status_trx_allowed';
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(240);
  l_status_id NUMBER;
  l_status_return VARCHAR2(1):='Y';
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_progress VARCHAR2(20);


BEGIN

  IF ( l_debug = 1 ) THEN
    print_debug('enter '||g_pkg_name||'.'||l_api_name, 1);
    print_debug('orgid='||p_organization_id||' item='||p_inventory_item_id ||' lot='||p_lot_number||' sub='||p_subinventory_code||' loc='||p_locator_id, 1);
    print_debug('p_transaction_type_id='||p_transaction_type_id||' p_lpn_id='||p_lpn_id, 1);
  END IF;

   IF p_lpn_id IS NOT NULL THEN
         -- Entire LPN is being allocated

	  BEGIN
	      SELECT status_id into l_status_id
	      FROM mtl_onhand_quantities_detail
	      WHERE  organization_id = p_organization_id
              AND inventory_item_id = p_inventory_item_id
	      AND subinventory_code = p_subinventory_code
	      AND locator_id = p_locator_id
	      AND nvl(lot_number,-9999) = nvl(p_lot_number, -9999)
	      AND lpn_id = p_lpn_id
	      AND rownum = 1;

	       IF ( l_debug = 1 ) THEN
	         print_debug('Value of l_status_id:'||l_status_id, 1);
               END IF;

	      l_status_return := inv_material_status_grp.is_trx_allowed(
			 p_status_id            => l_status_id
			,p_transaction_type_id  => p_transaction_type_id
			,x_return_status        => l_status_return			,x_msg_count            => l_msg_count
			,x_msg_data             => l_msg_data);

               IF l_status_return = fnd_api.g_ret_sts_unexp_error THEN
	          RAISE fnd_api.g_exc_unexpected_error;
	       ELSIF l_status_return = fnd_api.g_ret_sts_error THEN
	          RAISE fnd_api.g_exc_error;
	       END IF;
          EXCEPTION
             WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                l_progress := 'WMSSCC-0890';
                print_debug('INV_DETAIL_UTIL_PVT:'||l_api_name||': Error occured'||l_progress, 1);
		RAISE fnd_api.g_exc_unexpected_error;
              END IF;
         END;

         IF ( l_debug = 1 ) THEN
             print_debug('Value of l_status_return:'||l_status_return, 1);
	 END IF;

       return l_status_return ;


    ELSE  --IF p_lpn_id IS NOT NULL THEN
     -- Allocation is across loose and packed material.

     BEGIN

	   	 SELECT 'Y' into l_status_return FROM DUAL WHERE EXISTS(
	 	 SELECT 1 FROM mtl_onhand_quantities_detail moqd
	               WHERE moqd.organization_id = p_organization_id
       	               AND moqd.inventory_item_id = p_inventory_item_id
                       AND moqd.subinventory_code = p_subinventory_code
	               AND nvl(moqd.locator_id,-999) = nvl(p_locator_id,-999)
	               AND nvl(moqd.lot_number,-999) = nvl(p_lot_number, -999)
	               AND NOT EXISTS(SELECT 1 from mtl_status_transaction_control mtc
	               WHERE mtc.status_id = moqd.status_id
                              AND mtc.transaction_type_id = p_transaction_type_id
	               AND mtc.is_allowed = 2 ));
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
	l_status_return:= 'N';
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
          l_progress := 'WMSSCC-08891';
	     print_debug('INV_DETAIL_UTIL_PVT:'||l_api_name||': Error occured'||l_progress, 1);
      END IF;
    END;
	RETURN l_status_return;

  END IF;     --IF p_lpn_id IS NOT NULL THEN
END is_onhand_status_trx_allowed;

-- LPN Status Project

END inv_detail_util_pvt;

/

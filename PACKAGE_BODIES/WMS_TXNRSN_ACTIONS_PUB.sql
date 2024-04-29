--------------------------------------------------------
--  DDL for Package Body WMS_TXNRSN_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TXNRSN_ACTIONS_PUB" AS
/* $Header: WMSTRSAB.pls 120.10.12010000.16 2010/03/03 10:26:24 skommine ship $ */

--  Global constant holding the package name

G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'wms_txnrsn_actions_pub';
l_g_ret_sts_error               CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
l_g_ret_sts_unexp_error         CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
l_g_ret_sts_success             CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;
g_trace_on                      CONSTANT NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

g_debug                                  NUMBER  := 1;
g_module_name                            VARCHAR2(30) := NULL;

/*
-- Moved to spec for Opp Cyc Counting bug#9248808
PROCEDURE cleanup_task(
               p_temp_id           IN            NUMBER
             , p_qty_rsn_id        IN            NUMBER
             , p_user_id           IN            NUMBER
             , p_employee_id       IN            NUMBER
             , p_envoke_workflow   IN            VARCHAR2
             , x_return_status     OUT NOCOPY    VARCHAR2
             , x_msg_count         OUT NOCOPY    NUMBER
             , x_msg_data          OUT NOCOPY    VARCHAR2);

*/

-- to turn off debugger, comment out the line 'dbms_output.put_line(msg);'
PROCEDURE mdebug(msg in VARCHAR2, module IN VARCHAR2 DEFAULT NULL)
  IS
BEGIN
  IF (g_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
        (p_err_msg => msg,
         p_module => g_pkg_name ||':'|| g_module_name || '.' || module,
         p_level => 9);
  END IF;
END;



PROCEDURE Inadequate_Qty
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_qty_picked                    IN  NUMBER:=0
   , p_qty_uom                       IN  VARCHAR2
   , p_carton_id                     IN  VARCHAR2:= NULL
   , p_user_id                       IN  VARCHAR2
   , p_reason_id                     IN  NUMBER
   )IS

      l_msg_count NUMBER;
      l_return_status VARCHAR2(10);
      l_msg_data VARCHAR2(230);
      l_carton_id VARCHAR2(60);
      l_user_id VARCHAR2(60);
      l_qty_picked NUMBER;
      l_picked_uom VARCHAR2(3);
      l_trans_uom VARCHAR2(3);
      l_converted_qty NUMBER;
      l_qty_diff_txn NUMBER;
      l_qty_diff_prim NUMBER;
      l_organization_id NUMBER;
      l_mmtt_id NUMBER;
      l_task_id NUMBER;
      l_reason_id NUMBER;
      l_item_id NUMBER;
      l_revision  VARCHAR2(3);
      l_locator_id NUMBER;
      l_sub_code  VARCHAR2(10);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot  VARCHAR2(80);
      l_discrepancy NUMBER;

      l_mso_header_id NUMBER;
      l_mso_line_id NUMBER;
      l_reservation_id NUMBER;
      l_missing_quantity NUMBER;
      l_transaction_quantity NUMBER;
      l_line_num NUMBER;
      l_oe_header_id NUMBER;

      l_mmtt_header_id NUMBER;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_proc_name VARCHAR2(30) := 'Inadequate_Qty';
BEGIN

   g_debug := l_debug;
   g_module_name := l_proc_name;
   l_carton_id:=p_carton_id;
   l_user_id:=p_user_id;
   l_qty_picked:=p_qty_picked;
   l_picked_uom:=p_qty_uom;
   l_organization_id:=p_organization_id;
   l_task_id:=p_task_id;
   l_reason_id:=p_reason_id;
   l_discrepancy:=1;

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (l_debug = 1) THEN
      mdebug('Inside wms_txnrsn_actions_pub.Inadequate Quantity: Before update quantity ');
   END IF;

    --Get MMTT id from WMS_Dispatched_tasks
   SELECT transaction_temp_id
     INTO l_mmtt_id
     FROM wms_dispatched_tasks
     WHERE task_id=p_task_id;
   IF (l_debug = 1) THEN
      mdebug('l_mmtt_id: '|| l_mmtt_id);
   END IF;

   SELECT inventory_item_id, locator_id,subinventory_code,revision,lot_number,
         move_order_line_id, reservation_id, transaction_quantity,transaction_header_id
   INTO l_item_id,l_locator_id, l_sub_code,l_revision,l_lot,
         l_line_num, l_reservation_id,l_transaction_quantity,l_mmtt_header_id
   FROM  mtl_material_transactions_temp
   WHERE transaction_temp_id=l_mmtt_id;
   IF (l_debug = 1) THEN
        mdebug('l_transaction_quantity: '|| l_transaction_quantity);
   END IF;

     -- Get UOM from MO Line which is the same as transaction_uom in MMTT
   SELECT uom_code
   INTO l_trans_uom
   FROM mtl_txn_request_lines
   WHERE line_id = l_line_num;
   IF (l_debug = 1) THEN
        mdebug('uom_code '|| l_trans_uom);
   END IF;

      l_qty_picked := INV_Convert.INV_UM_Convert(
      item_id  => l_item_id,
      precision => null,
      from_quantity  => l_qty_picked,
      from_unit => l_picked_uom,
      to_unit => l_trans_uom,
      from_name => null,
      to_name => null);
    l_qty_diff_txn  := l_transaction_quantity - l_qty_picked;

   IF (l_debug = 1) THEN
      mdebug('before update mo line');
   END IF;
   UPDATE mtl_txn_request_lines
    SET quantity_detailed = quantity_detailed-l_qty_diff_txn
    WHERE line_id = l_line_num;

   IF (l_debug = 1) THEN
      mdebug('after update mo line');
   END IF;
  -- update the primary quantity and transaction quantity in MMTT


  IF (l_debug = 1) THEN
     mdebug('l_qty_picked'||l_qty_picked);
     mdebug('l_qty_diff_txn'||l_qty_diff_txn);
  END IF;

   l_qty_diff_prim := wms_task_dispatch_gen.get_primary_quantity(
       p_item_id => l_item_id,
       p_organization_id => l_organization_id,
       p_from_quantity => l_qty_diff_txn,
       p_from_unit => l_trans_uom);

   IF (l_debug = 1) THEN
      mdebug('l_qty_diff_prim: '||l_qty_diff_prim);
      mdebug('before update mmtt');
   END IF;
  UPDATE mtl_material_transactions_temp
    SET primary_quantity = primary_quantity - l_qty_diff_txn,
    transaction_quantity = l_transaction_quantity - l_qty_diff_prim
    where transaction_temp_id=l_mmtt_id;

   IF (l_debug = 1) THEN
      mdebug('after update mmtt');
   END IF;

   SELECT oe_header_id
     INTO l_oe_header_id
     FROM wsh_inv_delivery_details_v
     WHERE move_order_line_id=l_line_num
     AND ROWNUM = 1;  -- bug fix 1837592, if the same mol being detailed to
                     --multiple records, this query will return multiple rows.


    -- Convert the demand source header id given
   -- (the OE header id) to the MTL_SALES_ORDERS id to be used.
     IF (l_debug = 1) THEN
        mdebug('l_oe_header_id: '||l_oe_header_id);
     END IF;

     l_mso_header_id := inv_salesorder.get_salesorder_for_oeheader(l_oe_header_id);

      IF l_mso_header_id IS NULL THEN
 FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_GET_MSO_HEADER');
 FND_MSG_PUB.Add;
 RAISE fnd_api.g_exc_unexpected_error;
     END IF;

       -- get data for p_missing_quantity
     l_missing_quantity := l_transaction_quantity - p_qty_picked;
     IF (l_debug = 1) THEN
        mdebug('l_missing_quantity: '||l_missing_quantity);
     END IF;

     -- for debugging
     IF (l_debug = 1) THEN
        mdebug('Before calling: inv_pick_release_pub.reserve_Unconfirmed_Quantity');
     END IF;

     -- Calling Reserve Unconfirmed Quantity API (from INVPPCIB.pls)
   inv_pick_release_pub.reserve_Unconfirmed_Quantity
  (
      p_api_version   => 1.0
      ,p_init_msg_list   => fnd_api.g_false
      ,p_commit    => fnd_api.g_false
      ,x_return_status          => l_return_status
      ,x_msg_count              => l_msg_count
      ,x_msg_data               => l_msg_data
      ,p_missing_quantity  => l_missing_quantity
      ,p_reservation_id   => l_reservation_id
      ,p_demand_source_header_id => l_mso_header_id
      ,p_demand_source_line_id  => NULL
      ,p_organization_id  => l_organization_id
      ,p_inventory_item_id  => l_item_id
      ,p_subinventory_code  => l_sub_code
      ,p_locator_id   => l_locator_id
      ,p_revision   => l_revision
      ,p_lot_number   => l_lot
   );
   IF (l_debug = 1) THEN
      mdebug ('x_return_status : '||  x_return_status );
   END IF;

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (l_debug = 1) THEN
             mdebug(' inv_pick_release_pub.reserve_Unconfirmed_Quantity  failed');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

     -- for debugging
     IF (l_debug = 1) THEN
        mdebug('After calling: inv_pick_release_pub.reserve_Unconfirmed_Quantity');
     END IF;
       IF (l_debug = 1) THEN
          mdebug('Before calling: log_exception');
       END IF;





   -- Log Exception

   Log_exception
     (  1.0
 , fnd_api.g_false
 , FND_API.G_false
 , l_return_status
 , l_msg_count
 , l_msg_data
 , l_organization_id
 , l_mmtt_header_id
 , l_task_id
 , l_reason_id
 , l_sub_code
 , l_locator_id
 , l_discrepancy
 , l_user_id
 , l_item_id
 , l_revision
 , l_lot
 );
   fnd_msg_pub.count_and_get
     (  p_count  => l_msg_count
 , p_data   => l_msg_data
 );

   IF (l_msg_count = 0) THEN
      IF (l_debug = 1) THEN
         mdebug('Successful');
      END IF;
    ELSIF (l_msg_count = 1) THEN
      IF (l_debug = 1) THEN
         mdebug('Not Successful');
         mdebug(replace(l_msg_data,chr(0),' '));
      END IF;
    ELSE
      IF (l_debug = 1) THEN
         mdebug('Not Successful2');
      END IF;
      For I in 1..l_msg_count LOOP
  l_msg_data := fnd_msg_pub.get(I,'F');
  IF (l_debug = 1) THEN
     mdebug(replace(l_msg_data,chr(0),' '));
  END IF;
      END LOOP;
   END IF;


   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      --  mdebug('FE');
      FND_MSG_PUB.Add_Exc_Msg
 (   'Inadequate Qty'
     ,   'Calling Log Exception'
     );
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (l_debug = 1) THEN
         mdebug('SE');
      END IF;
      FND_MSG_PUB.Add_Exc_Msg
 (  'Inadequate Qty'
    ,   'Calling Log Exception'
    );
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (l_debug = 1) THEN
      mdebug('end of amins api');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );


   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );


END inadequate_qty;



PROCEDURE Suggest_alternate_location
  (
   p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_mmtt_id                       IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_subinventory_code             IN  VARCHAR2
   , p_locator_id                    IN  NUMBER
   , p_carton_id                     IN  VARCHAR2:= NULL
   , p_user_id                       IN  VARCHAR2
   , p_qty_picked                    IN  NUMBER
   , p_line_num                      IN  NUMBER
   ) IS


      l_trolin_tbl            INV_Move_Order_PUB.Trolin_Tbl_Type;
      l_return_status         VARCHAR2(10):= FND_API.G_RET_STS_SUCCESS;
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(230);
      l_trohdr_val_rec        INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
      l_commit                VARCHAR2(1) := FND_API.G_FALSE;
      l_order_count           NUMBER := 1; /* total number of lines */

      l_trolin_val_tbl            INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
      l_trolin_rec             INV_Move_Order_PUB.trolin_rec_type;
      l_test mtl_txn_request_lines%ROWTYPE;

      l_det_cnt               NUMBER;
      l_next_task_id          NUMBER;
      l_print_mode            VARCHAR2(1):='E';
      l_user_id               VARCHAR2(60);


      l_person_id             NUMBER;
      l_eqp_id                NUMBER;
      l_eqp_ins               VARCHAR2(30);
      l_per_res_id            NUMBER;
      l_mac_res_id            NUMBER;
      l_priority              NUMBER;
      l_mmtt_id               NUMBER;
      l_task_id               NUMBER;
      l_line_num              NUMBER;

      l_organization_id       NUMBER;
      l_standard_operation_id NUMBER;
      l_transaction_temp_id   NUMBER;
      -- WF Fix Start
      l_missing_quantity NUMBER;
      l_oe_header_id     NUMBER;
      l_reservation_id   NUMBER;
      l_mso_header_id    NUMBER;

      l_item_id     NUMBER;
      l_sub_code    VARCHAR2(10);
      l_locator_id  NUMBER;
      l_revision    VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot         VARCHAR2(80);


      l_serial_control_code  NUMBER;
      l_lot_control_code     NUMBER;
      l_num_of_rows          NUMBER;
      l_detailed_qty         NUMBER;
      l_sec_detailed_qty     NUMBER := 0;   -- Bug 8312574
      l_rev                  VARCHAR2(3);
      l_from_loc_id          NUMBER;
      l_to_loc_id            NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number           VARCHAR2(80);
      l_expiration_date      DATE;
      v_transaction_temp_id  NUMBER;
      l_header_id            NUMBER;
      l_move_order_type      NUMBER;
      l_serial_flag          VARCHAR2(1):='F';

      l_mmtt_transaction_uom  VARCHAR2(3);
      l_mol_delta_qty        NUMBER;
      l_primary_qty          NUMBER;
      l_transaction_qty      NUMBER;

      l_old_quantity_detailed  NUMBER;
      l_new_quantity_detailed  NUMBER;

      l_primary_reservation_quantity  NUMBER;
      v_header_id           NUMBER;
      l_new_mmtt_cnt        NUMBER;
      l_old_mmtt_cnt        NUMBER;
      l_quantity_delivered  NUMBER;
      l_sec_qty_delivered   NUMBER := 0;   -- Bug 8312574

      l_rsv_rec               INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
      l_dummy_sn       INV_Reservation_Global.Serial_Number_Tbl_Type;
      l_qty_succ_reserved     NUMBER;
      l_sec_qty_succ_reserved NUMBER;
      l_cc_res_id             NUMBER;
      l_line_status           NUMBER;
      l_cc_transfer_flag      VARCHAR2(1):='Y';
      l_lot_qty               NUMBER :=0;
      l_detailed_quantity     NUMBER;
      l_to_account_id         NUMBER; --BUG#3048061
      l_new_mmtt_qty          NUMBER :=0; --BUG#3278170

      l_fm_serial_number VARCHAR2(30);
      l_to_serial_number VARCHAR2(30);

      l_msnt_cnt   NUMBER;
      l_serial_allocated_flag  VARCHAR2(1);
      l_mtlt_trans_qty    NUMBER;

      b_is_revision_control BOOLEAN;
      b_is_lot_control  BOOLEAN;
      b_is_serial_control BOOLEAN;

      l_qoh              NUMBER;
      l_rqoh             NUMBER;
      l_qr               NUMBER;
      l_qs               NUMBER;
      l_att              NUMBER;
      l_atr              NUMBER;
      l_cc_insert_flag   VARCHAR2(1):='Y';
      l_sqoh              NUMBER;
      l_srqoh             NUMBER;
      l_sqr               NUMBER;
      l_sqs               NUMBER;
      l_satt              NUMBER;
      l_satr              NUMBER;
      l_do_update_mmtt    VARCHAR2(1);    -- Bug : 6034090
      l_allocated_lpn_id NUMBER; --Bug 7504490 - Added this variable to fetch the allocated_lpn_id from MMTT
      -- Bug 8197499
      l_secondary_quantity NUMBER;
      l_sec_uom_code       VARCHAR2(3);
      l_sec_missing_qty    NUMBER;
      l_lot_sec_qty        NUMBER;
      l_mol_sec_delta_qty  NUMBER;
      l_sec_lot_qty        NUMBER := 0;


      CURSOR get_mmtt_rows IS
      SELECT organization_id,
             standard_operation_id,
             transaction_temp_id,
             operation_plan_id,
             move_order_line_id
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id=l_line_num
         AND transaction_temp_id <> l_mmtt_id;

      CURSOR get_mtlt_c(p_temp_id NUMBER) IS
        SELECT primary_quantity
             , lot_number
             , secondary_quantity  -- bug 8197499
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_temp_id;

      CURSOR c_fm_to_serial_number IS
       SELECT
         msnt.fm_serial_number,
         msnt.to_serial_number
         FROM  mtl_serial_numbers_temp msnt
         WHERE msnt.transaction_temp_id = p_mmtt_id;

      CURSOR c_fm_to_lot_serial_number IS
       SELECT
         msnt.fm_serial_number,
         msnt.to_serial_number
         FROM
         mtl_serial_numbers_temp msnt,
         mtl_transaction_lots_temp mtlt
         WHERE mtlt.transaction_temp_id = p_mmtt_id
   AND   msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

      -- WF Fix End

   --8267628 Cursor c_distinct_lpn added as part of this bug
   --8870624 Added NVL and ORDER BY below
   CURSOR c_distinct_lpn IS
    SELECT DISTINCT(NVL(lpn_id,-999))
    FROM mtl_onhand_quantities_detail moqd
    WHERE moqd.organization_id = l_organization_id
    AND moqd.subinventory_code =  p_subinventory_code
    AND moqd.locator_id = p_locator_id
    AND moqd.inventory_item_id = l_item_id
    ORDER BY 1 DESC;

   /*9301174*/
   CURSOR C_DISTINCT_LOT_LPN_CUR (l_lot VARCHAR2) IS
   SELECT DISTINCT(NVL(moqd.lpn_id,-999))
    FROM mtl_onhand_quantities_detail moqd
    WHERE moqd.organization_id = l_organization_id
    AND moqd.subinventory_code =  p_subinventory_code
    AND moqd.locator_id = p_locator_id
    AND moqd.inventory_item_id = l_item_id
    AND moqd.lot_number = l_lot
    ORDER BY 1 DESC;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_proc_name VARCHAR2(30) := 'Suggest_alternate_location';
    l_original_serial_number      inv_reservation_global.serial_number_tbl_type; --Bug#8267628
    l_new_rsv_id     NUMBER ; --8557758
    l_parent_line_id NUMBER := NULL ; --Bug8460179

BEGIN

   g_debug := l_debug;
   g_module_name := l_proc_name;
   l_user_id:=p_user_id;
   l_mmtt_id:=p_mmtt_id;
   l_task_id:=p_task_id;
   l_line_num:=p_line_num;
   l_organization_id := p_organization_id;

    -- l_line_num:=42837;
   IF (l_debug = 1) THEN
      mdebug('Line Num: '|| l_line_num);
   END IF;

   l_trolin_rec:= inv_trolin_util.query_row(p_line_id => l_line_num);

   l_item_id := l_trolin_rec.inventory_item_id;
   l_header_id := l_trolin_rec.header_id;
   mdebug('item'||l_item_id);
   mdebug('l_header_id:'||l_header_id);
   mdebug('mol uom code: '|| l_trolin_rec.uom_code);

   mdebug('Inside Suggest Alternate Location');


   if l_header_id is not null then

      begin
    select  move_order_type
      INTO  l_move_order_type
      from  mtl_txn_request_headers
     where  header_id=l_header_id;

     mdebug('MO_Line: l_move_order_type: '||l_move_order_type);
      exception
         when others then
            l_move_order_type := null;
            mdebug('others exception in selecting move order type');
      end;
   else
      mdebug('l_header_id is null');
   end if;

   BEGIN
 SELECT  revision
        ,lot_number
        ,reservation_id
        ,primary_quantity
        ,transaction_uom
        ,transaction_quantity
        ,transaction_source_id
	,allocated_lpn_id
        ,secondary_transaction_quantity --bug 8197499
        ,secondary_uom_code       --bug 8197499
	,parent_line_id    --Bug8460179
   INTO l_revision
       ,l_lot
       ,l_reservation_id
       ,l_primary_qty
       ,l_mmtt_transaction_uom
       ,l_transaction_qty
       ,l_mso_header_id
       ,l_allocated_lpn_id -- Bug 7504490 - Fetching allocated_lpn_id from MMTT
       ,l_secondary_quantity  --bug 8197499
       ,l_sec_uom_code        --bug 8197499
       ,l_parent_line_id    --8460179
   FROM mtl_material_transactions_temp
  WHERE transaction_temp_id = l_mmtt_id;

    mdebug('transaction_uom :'|| l_mmtt_transaction_uom);
    mdebug('primary_qty :'|| l_primary_qty);
    mdebug('transaction_quantity: '|| l_transaction_qty);
    mdebug('reservation_id: '|| l_reservation_id);
    mdebug('secondary_transaction_quantity: '|| l_secondary_quantity);  --bug 8197499
    mdebug('secondary_uom_code: '|| l_sec_uom_code);    --bug 8197499

   exception
        when others then
     mdebug('other exception encounted AA');
     l_reservation_id := null;
     l_mmtt_transaction_uom := null;
   end;

   if l_revision is not null then
       b_is_revision_control := TRUE;
   else
       b_is_revision_control := FALSE;
   end if;

   SELECT serial_number_control_code, lot_control_code
     INTO l_serial_control_code
         ,l_lot_control_code
     FROM mtl_system_items
    WHERE inventory_item_id = l_item_id
      AND organization_id   = l_organization_id;

   mdebug('l_serial_control_code:  '|| l_serial_control_code);
   mdebug('l_serial_flag:  '|| l_serial_flag);

   mdebug('l_header_id:  '|| l_header_id);

   mdebug('lot control code:'||l_lot_control_code);

   IF l_serial_control_code NOT IN (1,6) THEN     --?? should only be not equal 1
          l_serial_flag := 'T';
          b_is_serial_control := TRUE;
   else
          b_is_serial_control := FALSE;
   END IF;

   if l_lot_control_code = 2 then
       b_is_lot_control := TRUE;
   else
       b_is_lot_control := FALSE;
   end if;


   /*Bug#9268209 including the move orders of type 5 that are  generated from ingredient picking of
OPM  */
   if l_move_order_type IN ( 3,5) then

      if l_reservation_id is not NULL then

       -- get data for p_missing_quantity
        if  l_lot_control_code = 2 then
            mdebug('lot controlled item');
            l_lot_qty := 0;
            l_sec_lot_qty := 0;   --bug 8197499
            open get_mtlt_c(l_mmtt_id);
            loop
                fetch get_mtlt_c into l_missing_quantity, l_lot, l_sec_missing_qty; --bug 8197499
                exit when get_mtlt_c%NOTFOUND;
                mdebug('l_missing_quantity:'||l_missing_quantity);
                mdebug('l_lot:'||l_lot);
                mdebug('l_sec_missing_qty:'||l_sec_missing_qty);  --bug 8197499
                -- for debugging
                mdebug('Before calling: inv_pick_release_pub.reserve_Unconfirmed_lpn');

	        /* Bug 7504490 - Modified the call to the new API Reserve_Unconfqty_lpn for
	          both lpn and loose. Passing allocated_lpn_id to handle CC reservation for lpn*/

               inv_pick_release_pub.Reserve_Unconfqty_lpn
               (
               p_api_version                => 1.0
              ,p_init_msg_list              => fnd_api.g_false
              ,p_commit                     => fnd_api.g_false
              ,x_return_status              => l_return_status
              ,x_msg_count                  => l_msg_count
              ,x_msg_data                   => l_msg_data
	      ,x_new_rsv_id                 => l_new_rsv_id -- bug8557788
              ,p_missing_quantity           => l_missing_quantity
              ,p_secondary_missing_quantity => l_sec_missing_qty --Bug#9251210
              ,p_reservation_id             => l_reservation_id
              ,p_demand_source_header_id    => l_mso_header_id
              ,p_demand_source_line_id      => NULL
              ,p_organization_id            => l_organization_id
              ,p_inventory_item_id          => l_item_id
              ,p_subinventory_code          => p_subinventory_code
              ,p_locator_id                 => p_locator_id
              ,p_revision                   => l_revision
              ,p_lot_number                 => l_lot
	      ,p_lpn_id                     => l_allocated_lpn_id
               );

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  mdebug(' inv_pick_release_pub.Reserve_Unconfqty_lpn  failed');
                  l_cc_transfer_flag := 'F';
                  l_lot_qty := l_lot_qty + l_missing_quantity;
                  l_sec_lot_qty := l_sec_lot_qty + l_sec_missing_qty; --bug 8197499
               END IF;

               IF  l_allocated_lpn_id IS  NULL THEN /*9251210-delete the remaing reservation.*/

                  mdebug('Before calling:INV_RESERVATION_PVT.delete_reservation(),with res_id :'||l_new_rsv_id);
                  l_rsv_rec.reservation_id := l_new_rsv_id; --l_reservation_id;
                  INV_RESERVATION_PVT.delete_reservation
                  (
                   p_api_version_number    =>  1.0
                 , p_init_msg_lst          => fnd_api.g_false
                 , x_return_status         => l_return_status
                 , x_msg_count             => l_msg_count
                 , x_msg_data              => l_msg_data
                 , p_rsv_rec               => l_rsv_rec
                 , p_original_serial_number=> l_original_serial_number
                 , p_validation_flag       => fnd_api.g_true
                 );
                  mdebug ('l_return_status : '||  l_return_status );

                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       mdebug(' INV_RESERVATION_PVT.delete_reservation  failed !!!');
                       l_cc_transfer_flag := 'F';
                       l_lot_qty := l_missing_quantity;
                       l_sec_lot_qty := l_sec_missing_qty;
                  END IF;
                END IF; -- END of l_allocated_lpn_id

            end loop;
            close get_mtlt_c;

        else
            mdebug('not lot controlled item');
            l_missing_quantity := l_primary_qty;
            l_sec_missing_qty  := l_secondary_quantity; -- bug 8197499
            mdebug('l_missing_quantity: '||l_missing_quantity);
            mdebug('l_sec_missing_qty: ' ||l_sec_missing_qty);
            l_lot_qty := 0;
            l_lot_sec_qty := 0;  --bug 8197499

      --Incase of allocated LPN -> not null , reserve_Unconfirmed_lpn() is called as per Bug 7504490
      --Incase of  allocated LPN -> null, delete_reservation() is called as per Bug#8267628.
      --   Bug 7504490 - Modified the call to the new API Reserve_Unconfqty_lpn for
	--   both lpn and loose. Passing allocated_lpn_id to handle CC reservation for lpn


             mdebug('Before calling: inv_pick_release_pub.reserve_Unconfirmed_lpn');

             inv_pick_release_pub.Reserve_Unconfqty_lpn
              (
		    p_api_version                => 1.0
		   ,p_init_msg_list              => fnd_api.g_false
		   ,p_commit                     => fnd_api.g_false
		   ,x_return_status              => l_return_status
		   ,x_msg_count                  => l_msg_count
		   ,x_msg_data                   => l_msg_data
		   ,x_new_rsv_id                 => l_new_rsv_id -- bug8557758
                   ,p_secondary_missing_quantity => l_sec_missing_qty --Bug#9251210
		   ,p_missing_quantity           => l_missing_quantity
		   ,p_reservation_id             => l_reservation_id
		   ,p_demand_source_header_id    => l_mso_header_id
		   ,p_demand_source_line_id      => NULL
		   ,p_organization_id            => l_organization_id
		   ,p_inventory_item_id          => l_item_id
		   ,p_subinventory_code          => p_subinventory_code
		   ,p_locator_id                 => p_locator_id
		   ,p_revision                   => l_revision
		   ,p_lot_number                 => NULL
		   ,p_lpn_id                     => l_allocated_lpn_id
		 );

		 mdebug ('l_return_status : '||  l_return_status );

                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	                mdebug(' INV_RESERVATION_PVT.Reserve_Unconfqty_lpn  failed');
                        l_cc_transfer_flag := 'F';
                        l_lot_qty := l_missing_quantity;
                  END IF;

          IF  l_allocated_lpn_id IS  NULL THEN

               mdebug('Before calling:INV_RESERVATION_PVT.delete_reservation(),with res_id :'||l_new_rsv_id);
	       l_rsv_rec.reservation_id := l_new_rsv_id; --l_reservation_id;
               INV_RESERVATION_PVT.delete_reservation
	       (
	        p_api_version_number    =>  1.0
	      , p_init_msg_lst          => fnd_api.g_false
	      , x_return_status         => l_return_status
	      , x_msg_count             => l_msg_count
              , x_msg_data              => l_msg_data
	      , p_rsv_rec               => l_rsv_rec
	      , p_original_serial_number => l_original_serial_number
	      , p_validation_flag       => fnd_api.g_true
	      );

               mdebug ('l_return_status : '||  l_return_status );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         	       mdebug(' INV_RESERVATION_PVT.delete_reservation  failed');
                       l_cc_transfer_flag := 'F';
                       l_lot_qty := l_missing_quantity;
                       l_sec_lot_qty := l_sec_missing_qty; --bug 8197499
              END IF;
	  END IF; -- END of l_allocated_lpn_id
     end if; --End of Lot controlled.

     -- for debugging
     mdebug('After calling: inv_pick_release_pub.reserve_Unconfirmed_Quantity');

    ELSE

      mdebug('l_reservation_id is null');
    END IF;

   end if;

   -- zero out the quantity of mmtt in order to do pick release again

   -- delete task
   DELETE FROM wms_dispatched_tasks
     WHERE transaction_temp_id = l_mmtt_id;
   -- transfer reservation is taking care of detailed_quantity in mtl_reservations
   -- zero the quantity for original mmtt line so pick release is going to work

  mdebug('l_parent_line_id:'||l_parent_line_id);

  /* Bug 7504490 - Commented out the check for l_do_update_mmtt. The MMTT has to be
      updated to 0 quantity for the quantity tree to fetch correct quantity to reserve */

  UPDATE mtl_material_transactions_temp
         SET primary_quantity = 0
           , transaction_quantity = 0
           , secondary_transaction_quantity = DECODE(secondary_uom_code,NULL,NULL,0)
  WHERE transaction_temp_id IN ( l_mmtt_id ,l_parent_line_id) --8460179  , added  l_parent_line_id
    AND organization_id = l_organization_id;


   --- for lot controled item delete the mtlt record, in order to call pick release again

   if l_lot_control_code = 2 then   -- lot controlled item
         if l_serial_control_code NOT IN (1,6) then  -- serial controlled
      begin
        select count(*)
         into  l_msnt_cnt
         from  mtl_transaction_lots_temp mtlt
       ,mtl_serial_numbers_temp  msnt
        where  mtlt.transaction_temp_id = l_mmtt_id
          and  mtlt.serial_transaction_temp_id = msnt.transaction_temp_id;

        mdebug('l_msnt_cnt:'||l_msnt_cnt);
      exception
         when others then
      mdebug('other exception encounted. set l_msnt_cnt to 0');
      l_msnt_cnt := 0;
      end;
          end if;

    else     -- not lot controlled item
          if l_serial_control_code NOT IN (1,6)  then  -- serial controlled
      begin
        select count(*)
          into  l_msnt_cnt
          from  mtl_serial_numbers_temp  msnt
        where  transaction_temp_id = l_mmtt_id;

         mdebug('l_msnt_cnt:'||l_msnt_cnt);
      exception
            when others then
         mdebug('other exception encounted. set l_msnt_cnt to 0');
         l_msnt_cnt := 0;
      end;
          end if;

   end if;

   if l_msnt_cnt > 0 then
         l_serial_allocated_flag := 'Y';
   else
         l_serial_allocated_flag := 'N';
   end if;

   mdebug('l_serial_allocated_flag:'||l_serial_allocated_flag);


   IF l_lot_control_code > 1 THEN

    -- Lot controlled item

         IF l_serial_control_code NOT IN (1,6) AND
     l_serial_allocated_flag = 'Y' THEN
             begin
   -- Lot and Serial controlled item
   mdebug('lot + serial controlled  item');
   mdebug('p_mmtt_id:'||p_mmtt_id);
   mdebug('l_mmtt_id:'||l_mmtt_id);
   OPEN c_fm_to_lot_serial_number;
   LOOP
      mdebug('inside the loop');
      FETCH c_fm_to_lot_serial_number
        INTO l_fm_serial_number,l_to_serial_number;
      mdebug('after fetch');
      EXIT WHEN c_fm_to_lot_serial_number%NOTFOUND;

                    mdebug('within loop before update msn for from serial_number:'||l_fm_serial_number);

      UPDATE mtl_serial_numbers
        SET  group_mark_id = NULL
        WHERE inventory_item_id         = l_item_id
        AND   current_organization_id   = l_organization_id
        AND   serial_number BETWEEN l_fm_serial_number AND l_to_serial_number;

                    mdebug('within loop after update msn for to serial_number :' || l_to_serial_number);

   END LOOP;
   CLOSE c_fm_to_lot_serial_number;

   mdebug('before delete msnt');

   DELETE FROM mtl_serial_numbers_temp msnt
     WHERE msnt.transaction_temp_id IN
     (SELECT mtlt.serial_transaction_temp_id
      FROM  mtl_transaction_lots_temp mtlt
      WHERE mtlt.transaction_temp_id = l_mmtt_id);
   mdebug('after delete msnt');

      exception
   when no_data_found then
        mdebug(' cursor returns no data');
   when others then
        mdebug('other exception occurs');
      end;

         ELSE
        mdebug('only lot controlle item');
         END IF;

         --DELETE FROM mtl_transaction_lots_temp mtlt
         --WHERE mtlt.transaction_temp_id = l_mmtt_id;
         -- we need to use mtlt later and so far just zero out mtlt, later will delete them
         mdebug('zero out quantity of the mtlt for lot controlled item');
         update mtl_transaction_lots_temp
            set primary_quantity = 0
              , transaction_quantity = 0
              , secondary_quantity = DECODE(secondary_quantity,NULL,NULL,0)  --bug 8197499
          where transaction_temp_id IN ( l_mmtt_id ,l_parent_line_id) ; /*9251210*/

   ELSIF l_serial_control_code NOT IN (1,6) AND
     l_serial_allocated_flag = 'Y' THEN

   mdebug('serial controlled item');
   OPEN c_fm_to_serial_number;
   LOOP
      FETCH c_fm_to_serial_number
        INTO l_fm_serial_number,l_to_serial_number;
      EXIT WHEN c_fm_to_serial_number%NOTFOUND;

      UPDATE mtl_serial_numbers
        SET group_mark_id = NULL
        WHERE inventory_item_id         = l_item_id
        AND   current_organization_id   = l_organization_id
        AND   serial_number BETWEEN l_fm_serial_number AND l_to_serial_number;

   END LOOP;
   CLOSE c_fm_to_serial_number;

   DELETE FROM mtl_serial_numbers_temp msnt
     WHERE msnt.transaction_temp_id = l_mmtt_id;

   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;

     -- l_move_order_type <> 3  need to create a cycle count reservation
     -- need to create cycle count reservation for remaining qty in the sub/loc
               mdebug('before create cycle count reservation');
        l_rsv_rec.reservation_id           := NULL; -- cannot know
        l_rsv_rec.requirement_date               := Sysdate;
        l_rsv_rec.organization_id                := l_organization_id;
        l_rsv_rec.inventory_item_id              := l_item_id;
        l_rsv_rec.demand_source_type_id    := inv_reservation_global.g_source_type_cycle_count;
        l_rsv_rec.demand_source_name             := NULL;
        l_rsv_rec.demand_source_header_id        := -1; --l_header_id;
        l_rsv_rec.demand_source_line_id    := -1; --l_line_num;
        l_rsv_rec.demand_source_delivery   := NULL;
        l_rsv_rec.primary_uom_code              := NULL;
        l_rsv_rec.primary_uom_id                := NULL;
        l_rsv_rec.secondary_uom_code              := NULL;
        l_rsv_rec.secondary_uom_id                := NULL;
        l_rsv_rec.reservation_uom_code          := NULL;
        l_rsv_rec.reservation_uom_id            := NULL;
        l_rsv_rec.reservation_quantity          := NULL;   --l_transaction_qty;
        l_rsv_rec.primary_reservation_quantity  := l_primary_qty;
        l_rsv_rec.secondary_reservation_quantity := l_secondary_quantity;  --bug 8197499
        l_rsv_rec.autodetail_group_id           := NULL;
        l_rsv_rec.external_source_code          := NULL;
        l_rsv_rec.external_source_line_id       := NULL;
        l_rsv_rec.supply_source_type_id    := INV_Reservation_GLOBAL.g_source_type_inv;
        l_rsv_rec.supply_source_header_id       := NULL;
        l_rsv_rec.supply_source_line_id         := NULL;
        l_rsv_rec.supply_source_name            := NULL;
        l_rsv_rec.supply_source_line_detail     := NULL;
        l_rsv_rec.revision                      := l_revision;
        l_rsv_rec.subinventory_code             := p_subinventory_code;
        l_rsv_rec.subinventory_id               := NULL;
        l_rsv_rec.locator_id                    := p_locator_id;
        l_rsv_rec.lot_number                    := NULL;
        l_rsv_rec.lot_number_id                 := NULL;
        l_rsv_rec.pick_slip_number              := NULL;
	/* Bug 7504490 - Passing the allocated_lpn_id to the cycle count reservation record */
        l_rsv_rec.lpn_id                        := l_allocated_lpn_id;
        l_rsv_rec.attribute_category            := NULL;
        l_rsv_rec.attribute1                    := NULL;
        l_rsv_rec.attribute2                    := NULL;
        l_rsv_rec.attribute3                    := NULL;
        l_rsv_rec.attribute4                    := NULL;
        l_rsv_rec.attribute5                    := NULL;
        l_rsv_rec.attribute6                    := NULL;
        l_rsv_rec.attribute7                    := NULL;
        l_rsv_rec.attribute8                    := NULL;
        l_rsv_rec.attribute9                    := NULL;
        l_rsv_rec.attribute10                   := NULL;
        l_rsv_rec.attribute11                   := NULL;
        l_rsv_rec.attribute12                   := NULL;
        l_rsv_rec.attribute13                   := NULL;
        l_rsv_rec.attribute14                   := NULL;
        l_rsv_rec.attribute15                   := NULL;
        l_rsv_rec.ship_ready_flag                := NULL;
        l_rsv_rec.detailed_quantity              := NULL;

        mdebug('create new reservation');

        if  l_lot_control_code = 2 then
                mdebug('lot controlled item');
                l_lot_qty := 0;
                l_sec_lot_qty := 0;  --bug 8197499
                open get_mtlt_c(l_mmtt_id);
                loop
                    l_qty_succ_reserved := 0;
                    l_cc_res_id := 0;
                    fetch get_mtlt_c into l_rsv_rec.primary_reservation_quantity
                                        , l_rsv_rec.lot_number
                                        , l_rsv_rec.secondary_reservation_quantity;  --bug 8197499
                    exit when get_mtlt_c%NOTFOUND;
                    mdebug('l_missing_quantity:'|| l_rsv_rec.primary_reservation_quantity);
                    mdebug('l_lot:'||l_rsv_rec.lot_number);
		    mdebug('sec qty :'||l_rsv_rec.secondary_reservation_quantity);

		    IF (l_allocated_lpn_id IS NOT NULL ) THEN --9301174 added IF
		      mdebug('l_allocated_lpn_id => '||l_allocated_lpn_id);
                      -- calling query quantity tree API to get l_atr
                      mdebug('calling quantity tree API');
                      inv_quantity_tree_pub.clear_quantity_cache;
	    	       /* Bug 7504490- Passing allocated_lpn_id  to query_quantities to fetch the quantity to reserve
		             for the LPN when the MMTT is for an allocated lpn */
		      inv_quantity_tree_pub.query_quantities
	                ( p_api_version_number    =>   1.0
		        , p_init_msg_lst          =>   fnd_api.g_false
	                , x_return_status         =>   l_return_status
	                , x_msg_count             =>   l_msg_count
	                , x_msg_data              =>   l_msg_data
	                , p_organization_id       =>   l_organization_id
	                , p_inventory_item_id     =>   l_item_id
	                , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_reservation_mode
	                , p_is_revision_control   =>   b_is_revision_control
	                , p_is_lot_control        =>   b_is_lot_control
	                , p_is_serial_control     =>   b_is_serial_control
	                , p_grade_code            =>   null
	                , p_demand_source_type_id =>   -9999
	                , p_revision              =>   l_revision
	                , p_lot_number            =>   l_rsv_rec.lot_number
	                , p_subinventory_code     =>   p_subinventory_code
	                , p_locator_id            =>   p_locator_id
			, p_lpn_id                =>   l_allocated_lpn_id
	                , x_qoh                   =>   l_qoh
	                , x_rqoh                  =>   l_rqoh
		        , x_qr                    =>   l_qr
	                , x_qs                    =>   l_qs
	                , x_att                   =>   l_att
	                , x_atr                   =>   l_atr
	                , x_sqoh                  =>   l_sqoh
	                , x_srqoh                 =>   l_srqoh
		        , x_sqr                   =>   l_sqr
			, x_sqs                   =>   l_sqs
	                , x_satt                  =>   l_satt
		        , x_satr                  =>   l_satr
	               );
	              IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
                         mdebug('after calling qty tree l_atr:' || l_atr||' l_att: '||l_att);
                         mdebug('after calling qty tree l_atr:' || l_satr);
                         mdebug('after calling qty tree l_qoh:' || l_qoh ||' l_rqoh: '||l_rqoh||' l_qr:'||l_qr||' l_qs:'||l_qs);
	              ELSE
                         mdebug('calling qty tree API failed ');
                         if l_move_order_type = 3 then
                                 l_atr := 0;
                         else
                                 l_atr := l_rsv_rec.primary_reservation_quantity;
                         end if;
	              END IF;

                      mdebug('after calling quantity tree ARI, l_atr:'||l_atr);
                      mdebug('after calling quantity tree ARI, l_satr:'||l_satr);


                      l_rsv_rec.primary_reservation_quantity := l_atr;
                      l_rsv_rec.secondary_reservation_quantity := l_satr;



	              if l_atr <> 0 then

                       mdebug('Before calling: inv_reservation_pvt.create_reservation');

                       l_return_status := FND_API.G_RET_STS_SUCCESS;

                       INV_Reservation_pvt.Create_Reservation
	              (
		        p_api_version_number          => 1.0
  		      , p_init_msg_lst              => fnd_api.g_false
		      , x_return_status             => l_return_status
		      , x_msg_count                 => l_msg_count
		      , x_msg_data                  => l_msg_data
		      , p_rsv_rec                   => l_rsv_rec
		      , p_serial_number             => l_dummy_sn
		      , x_serial_number             => l_dummy_sn
		      , p_partial_reservation_flag  => fnd_api.g_false
		      , p_force_reservation_flag    => fnd_api.g_false
		      , p_validation_flag           => fnd_api.g_false
		      , x_quantity_reserved         => l_qty_succ_reserved
		      , x_secondary_quantity_reserved         => l_sec_qty_succ_reserved
		      , x_reservation_id            => l_cc_res_id
               	      );
                      -- Return an error if the create reservation call failed
                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
		          mdebug('error in create reservation');
                	  l_cc_insert_flag := 'F';
               	      ELSE
	                  mdebug('l_qty_succ_reserved :'|| l_qty_succ_reserved);
	                  mdebug('l_cc_res_id: '|| l_cc_res_id);
                       END IF;
	             else
	               mdebug(' l_atr is 0, no need to call create reservation API');
                     end if;
                    ELSE --l_allocated_lpn_id is NULL --9301174 starts
		      mdebug('l_allocated_lpn_id is null ');
                      inv_quantity_tree_pub.clear_quantity_cache;

		      OPEN C_DISTINCT_LOT_LPN_CUR(l_rsv_rec.lot_number);
                      LOOP
   		         FETCH C_DISTINCT_LOT_LPN_CUR INTO  l_rsv_rec.lpn_id;
		         EXIT WHEN C_DISTINCT_LOT_LPN_CUR%NOTFOUND;
                         IF (l_rsv_rec.lpn_id = -999 ) THEN
                            l_rsv_rec.lpn_id :=NULL;
                         END IF;

                         mdebug('lpn_id :'||l_rsv_rec.lpn_id );
                         inv_quantity_tree_pub.query_quantities
	                  ( p_api_version_number    =>   1.0
		          , p_init_msg_lst          =>   fnd_api.g_false
	                  , x_return_status         =>   l_return_status
	                  , x_msg_count             =>   l_msg_count
	                  , x_msg_data              =>   l_msg_data
	                  , p_organization_id       =>   l_organization_id
	                  , p_inventory_item_id     =>   l_item_id
	                  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_reservation_mode
	                  , p_is_revision_control   =>   b_is_revision_control
	                  , p_is_lot_control        =>   b_is_lot_control
	                  , p_is_serial_control     =>   b_is_serial_control
	                  , p_grade_code            =>   null
	                  , p_demand_source_type_id =>   -9999
	                  , p_revision              =>   l_revision
	                  , p_lot_number            =>   l_rsv_rec.lot_number
	                  , p_subinventory_code     =>   p_subinventory_code
	                  , p_locator_id            =>   p_locator_id
		          , p_lpn_id                =>   l_rsv_rec.lpn_id
	                  , x_qoh                   =>   l_qoh
	                  , x_rqoh                  =>   l_rqoh
		          , x_qr                    =>   l_qr
	                  , x_qs                    =>   l_qs
	                  , x_att                   =>   l_att
	                  , x_atr                   =>   l_atr
	                  , x_sqoh                  =>   l_sqoh
	                  , x_srqoh                 =>   l_srqoh
		          , x_sqr                   =>   l_sqr
			  , x_sqs                   =>   l_sqs
    	                  , x_satt                  =>   l_satt
  		          , x_satr                  =>   l_satr
	                  );
	                  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
                            mdebug('after calling qty tree l_atr:' || l_atr||' l_att: '||l_att);
                            mdebug('after calling qty tree l_atr:' || l_satr);
                            mdebug('after calling qty tree l_qoh:' || l_qoh ||' l_rqoh: '||l_rqoh||' l_qr:'||l_qr||' l_qs:'||l_qs);
	                  ELSE
                            mdebug('calling qty tree API failed ');
                            if l_move_order_type = 3 then
                                 l_atr := 0;
                            else
                                 l_atr := l_rsv_rec.primary_reservation_quantity;
                            end if;
	                   END IF;

                          mdebug('after calling quantity tree ARI, l_atr:'||l_atr);
                          mdebug('after calling quantity tree ARI, l_satr:'||l_satr);


                         l_rsv_rec.primary_reservation_quantity := l_atr;
                         l_rsv_rec.secondary_reservation_quantity := l_satr;



                        if l_atr <> 0 then

                         mdebug('Before calling: inv_reservation_pvt.create_reservation');
                         l_return_status := FND_API.G_RET_STS_SUCCESS;

                        INV_Reservation_pvt.Create_Reservation
	                 (
		        p_api_version_number          => 1.0
		        , p_init_msg_lst              => fnd_api.g_false
		        , x_return_status             => l_return_status
	                , x_msg_count                 => l_msg_count
		        , x_msg_data                  => l_msg_data
		        , p_rsv_rec                   => l_rsv_rec
		        , p_serial_number             => l_dummy_sn
		        , x_serial_number             => l_dummy_sn
		        , p_partial_reservation_flag  => fnd_api.g_false
		        , p_force_reservation_flag    => fnd_api.g_false
		        , p_validation_flag           => fnd_api.g_false
		        , x_quantity_reserved         => l_qty_succ_reserved
		        , x_secondary_quantity_reserved         => l_sec_qty_succ_reserved
		        , x_reservation_id            => l_cc_res_id
	                  );
                       -- Return an error if the create reservation call failed
                       IF l_return_status <> fnd_api.g_ret_sts_success THEN
		         mdebug('error in create reservation');
		         l_cc_insert_flag := 'F';
          	      ELSE
	                mdebug('l_qty_succ_reserved :'|| l_qty_succ_reserved);
   	                mdebug('l_cc_res_id: '|| l_cc_res_id);
                      END IF;
        	    else
	              mdebug(' l_atr is 0, no need to call create reservation API');
                    end if;
		end loop;
		close C_DISTINCT_LOT_LPN_CUR;
	     END IF; --allcoated_lpn --9301174 Ends
           end loop;
           close get_mtlt_c;
       else
           mdebug('not lot controlled item');

	 IF l_allocated_lpn_id IS NOT NULL THEN

             mdebug('calling quantity tree API with lpn_id :'||l_allocated_lpn_id);

	     inv_quantity_tree_pub.clear_quantity_cache;

	      /* Bug 7504490- Passing allocated_lpn_id  to query_quantities to fetch the quantity to reserve
                    for the LPN when the MMTT is for an allocated lpn */

	     inv_quantity_tree_pub.query_quantities
		 (  p_api_version_number    =>   1.0
	          , p_init_msg_lst          =>   fnd_api.g_false
		  , x_return_status         =>   l_return_status
	          , x_msg_count             =>   l_msg_count
	          , x_msg_data              =>   l_msg_data
	          , p_organization_id       =>   l_organization_id
	          , p_inventory_item_id     =>   l_item_id
		  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_reservation_mode
	          , p_is_revision_control   =>   b_is_revision_control
	          , p_is_lot_control        =>   b_is_lot_control
	          , p_is_serial_control     =>   b_is_serial_control
	          , p_grade_code            =>   null
	          , p_demand_source_type_id =>   -9999
		  , p_revision              =>   l_revision
	          , p_lot_number            =>   null
	          , p_subinventory_code     =>   p_subinventory_code
	          , p_locator_id            =>   p_locator_id
                  , p_lpn_id                =>   l_allocated_lpn_id --Bug#7504490
                  , x_qoh                   =>   l_qoh
	          , x_rqoh                  =>   l_rqoh
	          , x_qr                    =>   l_qr
	          , x_qs                    =>   l_qs
	          , x_att                   =>   l_att
	          , x_atr                   =>   l_atr
	          , x_sqoh                  =>   l_sqoh
	          , x_srqoh                 =>   l_srqoh
	          , x_sqr                   =>   l_sqr
	          , x_sqs                   =>   l_sqs
	          , x_satt                  =>   l_satt
	          , x_satr                  =>   l_satr
		  );
             IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		            mdebug('after calling qty tree l_atr:' || l_atr||' l_att:'||l_att);
		            mdebug('after calling qty tree l_qoh:' || l_qoh ||' l_rqoh: '||l_rqoh||' l_qr:'||l_qr||' l_qs:'||l_qs);
             ELSE
		            mdebug('calling qty tree API failed ');
		            l_atr := 0;
		            if l_move_order_type = 3 then
		                  l_atr := 0;
		            else
	                          l_atr := l_rsv_rec.primary_reservation_quantity;
		            end if;

	          END IF;
            mdebug('after calling quantity tree ARI, l_atr:'||l_atr);
            mdebug('after calling quantity tree ARI, l_satr:'||l_satr);


	    l_rsv_rec.primary_reservation_quantity := l_atr;
	    l_rsv_rec.secondary_reservation_quantity := l_satr;


            mdebug(' primary_reservation_quantity :'||l_rsv_rec.primary_reservation_quantity);

            l_return_status := FND_API.G_RET_STS_SUCCESS;

            mdebug('Before calling: inv_reservation_pvt.create_reservation');

            if l_atr <> 0 then

               INV_Reservation_pvt.Create_Reservation
	    (
	     p_api_version_number          => 1.0
	     , p_init_msg_lst              => fnd_api.g_false
	     , x_return_status             => l_return_status
	     , x_msg_count                 => l_msg_count
	     , x_msg_data                  => l_msg_data
	     , p_rsv_rec                   => l_rsv_rec
	     , p_serial_number             => l_dummy_sn
	     , x_serial_number             => l_dummy_sn
	     , p_partial_reservation_flag  => fnd_api.g_false
	     , p_force_reservation_flag    => fnd_api.g_false
	     , p_validation_flag           => fnd_api.g_false
	     , x_quantity_reserved         => l_qty_succ_reserved
	     , x_secondary_quantity_reserved         => l_sec_qty_succ_reserved
	     , x_reservation_id            => l_cc_res_id
	     );
           -- Return an error if the create reservation call failed
	         IF l_return_status <> fnd_api.g_ret_sts_success THEN
	            mdebug('error in create reservation');
	            l_cc_insert_flag := 'F';
           ELSE
	            mdebug('l_qty_succ_reserved :'|| l_qty_succ_reserved);
	            mdebug('l_cc_res_id: '|| l_cc_res_id);
           END IF;
        else
           mdebug('l_atr is o, no need to call create reservation API');
        end if;



        ELSE --allocated lpn: null

	   -- Start 8267628
  	   OPEN c_distinct_lpn ;
	   LOOP  --This Loop ends after create reservations for Non Lot controlled items .
	     FETCH c_distinct_lpn INTO l_rsv_rec.lpn_id;
	     EXIT WHEN c_distinct_lpn%NOTFOUND;
	     -- End 8267628

             IF (l_rsv_rec.lpn_id = -999 ) THEN --8870624
                 l_rsv_rec.lpn_id :=NULL;
             END IF;

             mdebug('calling quantity tree API with lpn_id :'||l_rsv_rec.lpn_id);

             inv_quantity_tree_pub.clear_quantity_cache;

	     inv_quantity_tree_pub.query_quantities
		 ( p_api_version_number    =>   1.0
	          , p_init_msg_lst          =>   fnd_api.g_false
		  , x_return_status         =>   l_return_status
	          , x_msg_count             =>   l_msg_count
	          , x_msg_data              =>   l_msg_data
	          , p_organization_id       =>   l_organization_id
	          , p_inventory_item_id     =>   l_item_id
		  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_reservation_mode
	          , p_is_revision_control   =>   b_is_revision_control
	          , p_is_lot_control        =>   b_is_lot_control
	          , p_is_serial_control     =>   b_is_serial_control
	          , p_grade_code            =>   null
	          , p_demand_source_type_id =>   -9999
		  , p_revision              =>   l_revision
	          , p_lot_number            =>   null
	          , p_subinventory_code     =>   p_subinventory_code
	          , p_locator_id            =>   p_locator_id
                  , p_lpn_id                =>   l_rsv_rec.lpn_id --Bug#8267628
	          , x_qoh                   =>   l_qoh
	          , x_rqoh                  =>   l_rqoh
	          , x_qr                    =>   l_qr
	          , x_qs                    =>   l_qs
	          , x_att                   =>   l_att
	          , x_atr                   =>   l_atr
	          , x_sqoh                  =>   l_sqoh
	          , x_srqoh                 =>   l_srqoh
	          , x_sqr                   =>   l_sqr
	          , x_sqs                   =>   l_sqs
	          , x_satt                  =>   l_satt
	          , x_satr                  =>   l_satr
		   );
             IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		    mdebug('after calling qty tree l_atr:' || l_atr||' l_att:'||l_att);
		    mdebug('after calling qty tree l_qoh:' || l_qoh ||' l_rqoh: '||l_rqoh||' l_qr:'||l_qr||' l_qs:'||l_qs);
             ELSE
		    mdebug('calling qty tree API failed ');
		    l_atr := 0;
		    if l_move_order_type = 3 then
		          l_atr := 0;
		    else
	                  l_atr := l_rsv_rec.primary_reservation_quantity;
		    end if;

	    END IF;
            mdebug('after calling quantity tree ARI, l_atr:'||l_atr);
            mdebug('after calling quantity tree ARI, l_satr:'||l_satr);


	    l_rsv_rec.primary_reservation_quantity := l_atr;
	    l_rsv_rec.secondary_reservation_quantity := l_satr;


            mdebug(' primary_reservation_quantity :'||l_rsv_rec.primary_reservation_quantity);

            l_return_status := FND_API.G_RET_STS_SUCCESS;

            mdebug('Before calling: inv_reservation_pvt.create_reservation');

            if l_atr <> 0 then

               INV_Reservation_pvt.Create_Reservation
	    (
	     p_api_version_number          => 1.0
	     , p_init_msg_lst              => fnd_api.g_false
	     , x_return_status             => l_return_status
	     , x_msg_count                 => l_msg_count
	     , x_msg_data                  => l_msg_data
	     , p_rsv_rec                   => l_rsv_rec
	     , p_serial_number             => l_dummy_sn
	     , x_serial_number             => l_dummy_sn
	     , p_partial_reservation_flag  => fnd_api.g_false
	     , p_force_reservation_flag    => fnd_api.g_false
	     , p_validation_flag           => fnd_api.g_false
	     , x_quantity_reserved         => l_qty_succ_reserved
	     , x_secondary_quantity_reserved         => l_sec_qty_succ_reserved
	     , x_reservation_id            => l_cc_res_id
	     );
           -- Return an error if the create reservation call failed
	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	     mdebug('error in create reservation');
	     l_cc_insert_flag := 'F';
           ELSE
	      mdebug('l_qty_succ_reserved :'|| l_qty_succ_reserved);
	      mdebug('l_cc_res_id: '|| l_cc_res_id);
           END IF;
        else
        mdebug('l_atr is o, no need to call create reservation API');
        end if;
       END LOOP; --8267628 Looping for distinct LPNs
       CLOSE c_distinct_lpn;
     END IF; --allocated lpn
  end if; --Lot control

   --Bug3633573  following deletion not required for mtlt

   --if l_lot_control_code = 2 then
     --  DELETE FROM mtl_transaction_lots_temp mtlt
      --   WHERE mtlt.transaction_temp_id = l_mmtt_id;
   --end if;

   l_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT quantity_detailed
        , line_status
        , NVL(quantity_delivered,0)
        , NVL(secondary_quantity_delivered,0)
     INTO l_old_quantity_detailed
        , l_line_status
        , l_quantity_delivered
        , l_sec_qty_delivered
     FROM mtl_txn_request_lines
    WHERE line_id = l_line_num;

    mdebug('l_quantity_delivered:'||l_quantity_delivered);
    mdebug('l_sec_qty_delivered:'||l_sec_qty_delivered);
    mdebug('l_line_status:'||l_line_status);
    mdebug('l_quantity_detailed:'||l_old_quantity_detailed);

    select count(*)
      into l_old_mmtt_cnt
      from  mtl_material_transactions_temp
      where move_order_line_id = l_line_num;

   --mdebug('before update mol, the quantity_detailed :' || l_old_quantity_detailed);
   mdebug('before update mol, the number of mmtt rows  :' || l_old_mmtt_cnt);

    -- update quantity_detailed at mol to refelect change at mmtt.

   --SAVEPOINT before_allocation;

   mdebug('update move order line before calling allocation APIs');

   if l_line_num is not null then

  if  (l_trolin_rec.uom_code = l_mmtt_transaction_uom) then
        l_mol_delta_qty := l_transaction_qty;
        mdebug('uom at mol is the same as uom at mmtt');
  else  l_mol_delta_qty := INV_Convert.inv_um_convert
        (item_id  => l_item_id,
  precision => null,
  from_quantity  => l_transaction_qty,
  from_unit => l_mmtt_transaction_uom,
  to_unit         => l_trolin_rec.uom_code,
  from_name => null,
  to_name         => null);
  mdebug('uom at mol is different than uom at mmtt');
  end if;

 mdebug('l_mol_delta_qty = ' || l_mol_delta_qty);
   /* BUG3278170 when the move order line has multiple tasks and
           one of the taks is already delivered and the short pick is done on
           the second task then pick release pub wouldnot consider the delivered qty
           and the pick release would behave erratically. Hence modifying the
           quantity, quantity_delivered, quantity_detailed as if the delivered task
           is not there on the MTRL. This is just hack on pick_release_pub as
           pick release being pblic api and is not designed to allocate a move order line with
           partial delivered qty on it. */
        -- Bug 3278170 fix is below patchset 'J' level
         IF (inv_control.g_current_release_level >= inv_release.g_j_release_level) THEN
             -- For patchset 'J'
             mdebug('In J patchset update move order line');
             -- bug 8197499 starts
             IF (l_sec_uom_code IS NOT NULL) THEN
                mdebug('l_sec_uom_code IS NOT NULL ' );
                l_mol_sec_delta_qty := INV_Convert.inv_um_convert
                                       (item_id   => l_item_id,
                                        precision => null,
                                        from_quantity  => l_mol_delta_qty,
                                        from_unit => l_trolin_rec.uom_code,
                                        to_unit   => l_sec_uom_code,
                                        from_name => null,
                                        to_name   => null);

                UPDATE mtl_txn_request_lines
                   SET quantity_detailed = quantity_detailed - l_mol_delta_qty
                     , secondary_quantity_detailed = secondary_quantity_detailed - l_mol_sec_delta_qty
                     , last_update_date = SYSDATE
                     , last_updated_by = l_user_id
                 WHERE organization_id = l_organization_id
                   AND line_id = l_line_num;
             ELSE  --bug 8197499 ends
                UPDATE mtl_txn_request_lines
                 SET quantity_detailed = quantity_detailed - l_mol_delta_qty
                   , last_update_date = SYSDATE
                   , last_updated_by = l_user_id
                WHERE organization_id = l_organization_id
                  AND line_id = l_line_num;
             END IF;
          ELSE
             -- 11.5.9 or lower, so no secondary qty update required
             -- fix for bug 3278170
             UPDATE mtl_txn_request_lines
                SET quantity_detailed = (nvl(quantity_detailed,0) -nvl(l_quantity_delivered,0))
                                         - l_mol_delta_qty --bug3278170
                  , last_update_date = SYSDATE
                  , last_updated_by = l_user_id
                  , quantity_delivered = 0 --bug3278170
                  , quantity = quantity - nvl(l_quantity_delivered,0) --bug3278170
              WHERE organization_id = l_organization_id
                AND line_id = l_line_num;
         END IF;

      if (l_reservation_id is not null)  then
         if l_cc_transfer_flag = 'F' then
            mdebug(' cycle count reservation transfer failed');
            update mtl_reservations
               set detailed_quantity = detailed_quantity - l_lot_qty
                 , secondary_detailed_quantity = secondary_detailed_quantity - l_sec_lot_qty  --bug 8197499
                 , last_update_date = SYSDATE
                 , last_updated_by = l_user_id
             WHERE organization_id = l_organization_id
               AND reservation_id = l_reservation_id;
         else
             mdebug(' cycle count reservation transfer successed');
             Begin  --Bug 3633573 added exception block to continue flow if no
                    --data is found out of select clause
             select primary_reservation_quantity
                        ,detailed_quantity
                   into  l_primary_reservation_quantity
                        ,l_detailed_quantity
                    from mtl_reservations
                   WHERE organization_id = l_organization_id
                     AND reservation_id = l_reservation_id;
               exception
                WHEN NO_DATA_FOUND THEN
                  mdebug('No data found in mtl_reservation ');
                  mdebug('Reservation id :'||l_reservation_id);
                  when others THEN
                    mdebug('In Others in reservations');
                   IF (l_debug = 1) THEN
                     mdebug('Log Exception2');
                 END IF;
              End;

       end if;
  mdebug('after update mol, the detailed_quantity at reservation :'|| l_detailed_quantity);
         mdebug('after update mol, the primary_quantity at reservation :' || l_primary_reservation_quantity);
      else
         mdebug('l_reservation_id is null ');
      end if;

      select quantity_detailed,
      to_account_id --BUG#3048061
       into  l_old_quantity_detailed,
      l_to_account_id --BUG#3048061
       from  mtl_txn_request_lines
       where line_id = l_line_num;

     mdebug('after update mol, the quantity_detailed :' || l_old_quantity_detailed);

   end if;


   SELECT mtl_material_transactions_s.nextval
     INTO v_header_id
     FROM dual;

   mdebug('v_header_id:  '|| v_header_id);

   mdebug('Before calling: INV_Replenish_Detail_PUB.Line_Details_PUB  ');

   l_detailed_qty := 0;

   INV_Replenish_Detail_PUB.Line_Details_PUB
           (
               p_line_id                => l_line_num
             , x_number_of_rows         => l_num_of_rows
             , x_detailed_qty           => l_detailed_qty
             , x_return_status          => l_return_status
             , x_msg_count              => l_msg_count
             , x_msg_data               => l_msg_data
             , x_revision               => l_rev
             , x_locator_id             => l_from_loc_id
             , x_transfer_to_location   => l_to_loc_id
             , x_lot_number             => l_lot_number
             , x_expiration_date        => l_expiration_date
             , x_transaction_temp_id    => v_transaction_temp_id
             , p_transaction_header_id  => v_header_id
             , p_transaction_mode       => NULL
             , p_move_order_type        => l_move_order_type
             , p_serial_flag            => l_serial_flag
           );

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         mdebug(' inv_replenish_detail_pub.line_details_pub failed');
       --ROLLBACK TO SAVEPOINT before_allocation;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --mdebug('After calling: INV_Replenish_Detail_PUB.Line_Details_PUB  ');

   mdebug('After calling: INV_Replenish_Detail_PUB.Line_Details_PUB: l_detailed_qty:' || l_detailed_qty);
   mdebug('After calling pick release: number_of_rows:'|| l_num_of_rows);
   mdebug(' v_transaction_temp_id: '|| v_transaction_temp_id);

   if (l_move_order_type <> 3 ) then
      -- Bug 8312574
      IF l_trolin_rec.secondary_uom IS NOT NULL THEN
         l_sec_detailed_qty := inv_convert.inv_um_convert
                               ( item_id       => l_trolin_rec.inventory_item_id,
                                 precision     => null,
                                 from_quantity => l_detailed_qty,
                                 from_unit     => l_trolin_rec.uom_code,
                                 to_unit       => l_trolin_rec.secondary_uom,
                                 from_name     => null,
                                 to_name       => null);
      END IF;

      UPDATE mtl_txn_request_lines
         SET quantity_detailed = l_detailed_qty + l_quantity_delivered
           , secondary_quantity_detailed = DECODE(secondary_uom_code,NULL,NULL,
                                              l_sec_detailed_qty + l_sec_qty_delivered)  -- Bug 8312574
       WHERE line_id = l_line_num
         AND organization_id = l_organization_id;

 -- Bug#3048061
        -- Update the distribution_account_id of MMTT
        -- from to_account_id of mtl_txn_request_lines
        -- Since, MOs allocated using MO Pick Slip Report too,
        -- along with manually allocated MO will populate
        -- the distribution_account_id of MMTT.

        IF  l_to_account_id is not null THEN
           UPDATE mtl_material_transactions_temp
           SET distribution_account_id = l_to_account_id
           WHERE move_order_line_id = l_line_num;
        END IF;

   end if;
     /* BUG3278170 values quantity, quantity_delivered, quantity_detailed
         set on MTRL before calling pick relase api are reset.*/
         -- this fix is for below J patchset, no sec UOM update required
        IF (inv_control.g_current_release_level <  inv_release.g_j_release_level)
        THEN
           SELECT sum(transaction_quantity)
             INTO l_new_mmtt_qty
             FROM mtl_material_transactions_temp
            WHERE move_order_line_id = l_line_num;

           UPDATE mtl_txn_request_lines
              SET quantity = nvl(l_new_mmtt_qty,0) + l_quantity_delivered ,
                  quantity_detailed = nvl(l_new_mmtt_qty,0) + l_quantity_delivered ,
                  quantity_delivered =  l_quantity_delivered
            WHERE organization_id = l_organization_id
              AND line_id = l_line_num;
                     --bug3278170
         END IF;

   fnd_msg_pub.count_and_get
     (  p_count  => l_msg_count
 , p_data   => l_msg_data
 );

   IF (l_msg_count = 0) THEN
      mdebug('Successful');
    ELSIF (l_msg_count = 1) THEN
      mdebug('Not Successful');
      mdebug(replace(l_msg_data,chr(0),' '));
    ELSE
      mdebug('Not Successful2');
      For I in 1..l_msg_count LOOP
  l_msg_data := fnd_msg_pub.get(I,'F');
  mdebug(replace(l_msg_data,chr(0),' '));
      END LOOP;
   END IF;


   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          FND_MSG_PUB.Add_Exc_Msg
 (   'Suggest Alt Loc'
     ,   'Call Pick Release'
     );
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           FND_MSG_PUB.Add_Exc_Msg
 (  'Suggest Alt Loc'
    ,   'Call Pick Release'
    );
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    mdebug('before exception section');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Raise FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
 THEN
  FND_MSG_PUB.Add_Exc_Msg
    (   'INV_Move_Order_PUB'
        ,   'Create_Move_Orders'
        );
      END IF;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Suggest_alternate_location ;





PROCEDURE Log_exception
  (
   p_api_version_number              IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_mmtt_id                       IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_reason_id                     IN  NUMBER
   , p_subinventory_code             IN  VARCHAR2
   , p_locator_id                    IN  NUMBER
   , p_discrepancy_type              IN  NUMBER
   , p_user_id                       IN  VARCHAR2
   , p_item_id                       IN  NUMBER:=NULL
   , p_revision                      IN  VARCHAR2:=NULL
   , p_lot_number                    IN  VARCHAR2:=NULL
   , p_lpn_id                        IN  NUMBER:=NULL
   , p_is_loc_desc                   IN  BOOLEAN := FALSE  --Added bug 3989684
   )IS

      l_sequence NUMBER;
      l_return_err VARCHAR2(230);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_proc_name VARCHAR2(30) := 'Log_exception';
   BEGIN

      --Calculate Sequence Number
      select wms_exceptions_s.NEXTVAL INTO l_sequence from dual;
      g_debug := l_debug;
      g_module_name := l_proc_name;
      IF (l_debug = 1) THEN
         mdebug('Inserting into exceptions');
         mdebug(l_sequence);
      END IF;
      INSERT INTO wms_exceptions(
     TASK_ID,
     SEQUENCE_NUMBER,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     PERSON_ID,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE  ,
     INVENTORY_LOCATION_ID,
     REASON_ID,
     DISCREPANCY_TYPE,
     SUBINVENTORY_CODE,
     LOT_NUMBER,
     REVISION,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     created_by,
     transaction_header_id,
                                 lpn_id
     )
 VALUES(p_mmtt_id,
        l_sequence,
        p_organization_id,
        p_item_id,
        p_user_id,
        Sysdate,
        Sysdate,
        p_locator_id,
        p_reason_id,
        p_discrepancy_type,
        p_subinventory_code,
        p_lot_number,
        p_revision,
        Sysdate,
        FND_GLOBAL.user_id,--p_user_id,Bug:2672785
        Sysdate,
        FND_GLOBAL.user_id,--p_user_id,Bug:2672785
        p_mmtt_id,
               p_lpn_id);

      --Bug #4058417 - Removed inline branching so that reason_id is
      --updated in MMTT for R12 as well
      IF (p_is_loc_desc) THEN   --Added for bug 3989684
        IF (l_debug = 1) THEN
          mdebug('p_is_loc_desc is True, updating MMTT header'||p_mmtt_id||' with reason id '||p_reason_id);
        END IF;

        UPDATE mtl_material_transactions_temp
        SET    reason_id = p_reason_id
        WHERE  transaction_header_id = p_mmtt_id;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

   exception
      when others THEN
  x_return_status:=FND_API.G_RET_STS_ERROR;

  l_return_err := 'Insert into WMS_Exceptions failed'||
    substrb(sqlerrm,1,55);
  raise_application_error(-20000,l_return_err);


  IF (l_debug = 1) THEN
     mdebug('Log Exception');
  END IF;

END log_exception;


/* Will be called for
   1. PICK NONE exception - from PickLoad page directly
   2. CURTAIL PICK - confirm qty < requested_qty
     -- cleanup task will be called for each temp_id with this case..usually only one
        EXCEPT in case of BULK, there will be multiple MMTTs selected for the given temp_id
     -- it should be called only for qty  exceptions where picked quantity < suggested quantity
     -- and not for overpicked qty
   3. CURTAIL PICK for all children of BULK-  */

PROCEDURE cleanup_task(
               p_temp_id           IN            NUMBER
             , p_qty_rsn_id        IN            NUMBER
             , p_user_id           IN            NUMBER
             , p_employee_id       IN            NUMBER
             , x_return_status     OUT NOCOPY    VARCHAR2
             , x_msg_count         OUT NOCOPY    NUMBER
             , x_msg_data          OUT NOCOPY    VARCHAR2)
IS
    l_mmtt_msg_cnt               NUMBER;
    l_mmtt_msg_data              VARCHAR2(2000);
    l_mmtt_return_status         VARCHAR2(1);


    l_mmtt_temp_id    NUMBER;
    l_item_id  NUMBER;
    l_org_id NUMBER;
    l_sub VARCHAR2(30);
    l_loc NUMBER;
    /* Bug 7504490*/
    l_allocated_lpn_id  NUMBER ;
    l_revision   VARCHAR2(3);

    l_proc_name VARCHAR2(60) := 'cleanup_task (wrapper)';
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);


       CURSOR rem_mmtt_csr IS
         SELECT mmtt.transaction_temp_id
         FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.organization_id = l_org_id
           AND mmtt.inventory_item_id = l_item_id
           AND mmtt.subinventory_code = l_sub
           AND mmtt.locator_id = l_loc
	   AND NVL(mmtt.revision, '@') = NVL(l_revision, '@') --Bug 7504490
           AND NVL(mmtt.allocated_lpn_id, -1)= NVL(l_allocated_lpn_id, -1) --Bug 7504490
           AND mmtt.transaction_temp_id <> p_temp_id
           AND mmtt.parent_line_id IS NULL  -- Bug# 5760606 - add condition so only non bulk tasks are considered
                                            -- without the condition curtail pick for bulk pick will fail since this cursor picks up child mmtt lines
           AND mmtt.item_lot_control_code = 1
           AND NOT EXISTS( /*Bug8304954-If no serial allocation, we should cleanup(only for non-lot case) */
                SELECT 1 FROM MTL_SERIAL_NUMBERS_TEMP MSNT
                WHERE MSNT.TRANSACTION_TEMP_ID= mmtt.transaction_temp_id --Should not have serials allocated.
               )
          AND NOT EXISTS (
           SELECT 1 FROM wms_dispatched_tasks
           WHERE transaction_temp_id= mmtt.transaction_temp_id
             AND status in (4,9)) ;

BEGIN

   IF (l_debug = 1) THEN
       mdebug('IN : ' || l_proc_name);
       -- Start Bug# 5760606 - added more debug info
       mdebug('cleanup_task (w): p_temp_id:' || p_temp_id);
       mdebug('cleanup_task (w): p_qty_rsn_id: ' || p_qty_rsn_id);
       mdebug('cleanup_task (w): p_user_id: ' || p_user_id);
       mdebug('cleanup_task (w): p_employee_id: ' || p_employee_id);
       -- End Bug# 5760606
    END IF;

   -- get the sub and loc where we picked the material from
   /* Bug 7504490 - Adding revision and allocated_lpn_id to the query */
   select organization_id,inventory_item_id,subinventory_code,locator_id,revision,allocated_lpn_id
   into l_org_id,l_item_id,l_sub,l_loc,l_revision,l_allocated_lpn_id
   from mtl_material_transactions_temp
   where transaction_temp_id = p_temp_id;

   IF (l_debug = 1) THEN
       mdebug('cleanup_task (w) : Calling for the other mmtts');
   END IF;

   OPEN rem_mmtt_csr;

   IF (l_debug = 1) THEN
       mdebug('cleanup_task (w) :Values of p_act_sub:' || l_sub);
       mdebug('cleanup_task (w) :Values of p_act_loc:' || l_loc);
   END IF;

   LOOP

       FETCH rem_mmtt_csr INTO  l_mmtt_temp_id ;
       EXIT WHEN rem_mmtt_csr%NOTFOUND ;

       IF (l_debug = 1) THEN
             mdebug('cleanup_task (w) :Calling cleanup task API with');
             mdebug('cleanup_task (w) :TEMPID: ' || l_mmtt_temp_id);
             mdebug('cleanup_task (w) :UserId: ' || p_user_id);
             mdebug('cleanup_task (w) :p_qty_disc_rsn : ' || p_qty_rsn_id);
       END IF;

       cleanup_task(
           p_temp_id       =>l_mmtt_temp_id
         , p_qty_rsn_id    =>p_qty_rsn_id
         , p_user_id       =>p_user_id
         , p_employee_id   =>p_employee_id
         , p_envoke_workflow => 'N'
         , x_return_status =>x_return_status
         , x_msg_count     =>x_msg_count
         , x_msg_data      =>x_msg_data  );

        IF (l_debug = 1) THEN
             mdebug('after calling cleanup_task for transaction:'||l_mmtt_temp_id);
        END IF;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN

         IF l_debug = 1 THEN
                mdebug('cleanup_task (W) :Error occurred while calling cleanup_task');
         END IF ;
             RAISE fnd_api.g_exc_error;

        END IF;

        END LOOP;

        CLOSE rem_mmtt_csr; --Closing the cursor




    -- call for the current line
    -- Bug# 5760606 - added more debug info
    mdebug('cleanup_task (w):  before calling cleanup_task for the current line');

    cleanup_task(
           p_temp_id       =>p_temp_id
         , p_qty_rsn_id    =>p_qty_rsn_id
         , p_user_id       =>p_user_id
         , p_employee_id   =>p_employee_id
         , p_envoke_workflow => 'Y'
         , x_return_status =>x_return_status
         , x_msg_count     =>x_msg_count
         , x_msg_data      =>x_msg_data  );
  mdebug('END : ' || l_proc_name );
  EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mdebug('ROLLBACK ' );
        ROLLBACK ;
        mdebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mdebug('ROLLBACK ' );
        ROLLBACK ;
        mdebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);


END;

PROCEDURE cleanup_task(
               p_temp_id           IN            NUMBER
             , p_qty_rsn_id        IN            NUMBER
             , p_user_id           IN            NUMBER
             , p_employee_id       IN            NUMBER
             , p_envoke_workflow   IN            VARCHAR2
             , x_return_status     OUT NOCOPY    VARCHAR2
             , x_msg_count         OUT NOCOPY    NUMBER
             , x_msg_data          OUT NOCOPY    VARCHAR2)
IS
    l_txn_hdr_id        NUMBER;
    l_txn_temp_id       NUMBER;
    l_org_id            NUMBER;
    l_item_id           NUMBER;
    l_sub               VARCHAR2(10);
    l_loc               NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot               VARCHAR2(80);
    l_rev               VARCHAR2(3);
    l_txn_qty           NUMBER;
    l_sec_txn_qty       NUMBER;
    l_other_mmtt_count  NUMBER;
    l_mo_line_id        NUMBER;
    l_mo_type           NUMBER;
    l_mol_qty           NUMBER;
    l_mol_qty_delivered NUMBER;
    l_mol_src_id        NUMBER;
    l_mol_src_line_id   NUMBER;
    l_mol_reference_id  NUMBER;
    l_mmtt_transaction_uom    VARCHAR2(3);
    l_mtrl_uom                VARCHAR2(3);
    l_primary_quantity        NUMBER;

    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_proc_name             VARCHAR2(30) :=  'CLEANUP_TASK';
    l_progress              VARCHAR2(30) :=  '100';
    l_wf                    NUMBER := -1;
    l_calling_program       VARCHAR2(30) :=  'CLEANUP_TASK: QTY EXCEPTION';
    l_update_parent  BOOLEAN := FALSE ;  -- No need to call update_parent_mmtt in
                                          -- INV_TRX_UTIL_PUB
    l_parent_line_id    NUMBER;    --For checking bulk task
    l_kill_mo_profile   NUMBER := NVL(FND_PROFILE.VALUE_WNPS('INV_KILL_MOVE_ORDER'),2);
    l_return_status     VARCHAR2(1);

     --Bug#6027401.
    l_reservation_id     NUMBER;
    l_pri_rsv_qty        NUMBER;
    l_rsv_qty            NUMBER;
    l_pri_rsv_uom        VARCHAR2(3);
    l_rsv_uom            VARCHAR2(3);
    l_old_upd_resv_rec   inv_reservation_global.mtl_reservation_rec_type;
    l_new_upd_resv_rec   inv_reservation_global.mtl_reservation_rec_type;
    l_upd_dummy_sn       inv_reservation_global.serial_number_tbl_type;
    --Bug#6027401.

    CURSOR c_mmtt_info IS
      SELECT mmtt.transaction_header_id
           , mmtt.transaction_temp_id
           , mmtt.parent_line_id    --For checking bulk task
           , mmtt.inventory_item_id
           , mmtt.organization_id
           , mmtt.revision
           , mmtt.lot_number
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.move_order_line_id
           , mmtt.transaction_quantity
           , mmtt.transaction_uom
           , mmtt.primary_quantity
           , mmtt.secondary_transaction_quantity   -- Bug 8312574
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions_temp t1
                         WHERE t1.parent_line_id = mmtt.transaction_temp_id)
      UNION ALL
      SELECT mmtt.transaction_header_id
           , mmtt.transaction_temp_id
           , mmtt.parent_line_id            --For checking bulk task
           , mmtt.inventory_item_id
           , mmtt.organization_id
           , mmtt.revision
           , mmtt.lot_number
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.move_order_line_id
           , mmtt.transaction_quantity
           , mmtt.transaction_uom
           , mmtt.primary_quantity
           , mmtt.secondary_transaction_quantity  -- Bug 8312574
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.parent_line_id = p_temp_id
         AND mmtt.parent_line_id <> mmtt.transaction_temp_id;
       -- This union by will end up getting all PARENTS too ***** mrana

    CURSOR c_mo_line_info IS
      SELECT mtrh.move_order_type
           , mtrl.txn_source_id
           , mtrl.txn_source_line_id
           , mtrl.reference_id
           , mtrl.quantity
           , mtrl.uom_code
           , mtrl.quantity_delivered
        FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl
       WHERE mtrl.line_id = l_mo_line_id
         AND mtrh.header_id = mtrl.header_id;

    CURSOR c_get_other_mmtt IS
      SELECT COUNT(*)
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = l_mo_line_id
         AND mmtt.transaction_temp_id <> l_txn_temp_id
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions_temp t1
                         WHERE t1.parent_line_id = mmtt.transaction_temp_id);

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    g_debug := l_debug;
    g_module_name := l_proc_name;
    l_progress := '110';
    IF (l_debug = 1) THEN
       mdebug('IN : ' || l_proc_name);
       mdebug ('l_progress: ' || l_progress );
       -- Start Bug# 5760606 - add more debug info
       mdebug('p_temp_id: ' || p_temp_id);
       mdebug('p_qty_rsn_id: ' || p_qty_rsn_id);
       mdebug('p_user_id: ' || p_user_id);
       mdebug('p_employee_id: ' || p_employee_id);
       mdebug('p_envoke_workflow: ' || p_envoke_workflow);
       -- End Bug# 5760606
    END IF;

    l_progress := '110';
    IF (l_debug = 1) THEN mdebug ('l_progress: ' || l_progress ); END IF;

    IF p_qty_rsn_id IS NOT NULL
    THEN
       BEGIN
          SELECT 1
            INTO l_wf
            FROM mtl_transaction_reasons
           WHERE reason_id = p_qty_rsn_id
             AND workflow_name IS NOT NULL
             AND workflow_name <> ' '
             AND workflow_process IS NOT NULL
             AND workflow_process <> ' ';
       EXCEPTION
   WHEN NO_DATA_FOUND THEN
              l_wf  := 0;
       END ;
    END IF;

    IF p_envoke_workflow='N' THEN
        l_wf  := 0;
    END IF;


    l_progress := '115';
    IF (l_debug = 1) THEN mdebug ('l_progress: ' || l_progress ); END IF;

    -- Insert the aborted task into wdth
    wms_insert_wdth_pvt.insert_into_wdth
      (x_return_status             => x_return_status,
       p_txn_header_id             => 0,
       p_transaction_temp_id       => p_temp_id,
       p_transaction_batch_id      => NULL,
       p_transaction_batch_seq     => NULL,
       p_transfer_lpn_id           => NULL,
       p_status                    => 11); -- aborted

    l_progress := '120';
    IF (l_debug = 1) THEN mdebug('l_wf: ' || l_wf); mdebug ('l_progress: ' || l_progress ); END IF;

    OPEN c_mmtt_info;
    LOOP
      FETCH c_mmtt_info INTO l_txn_hdr_id
                           , l_txn_temp_id
                           , l_parent_line_id
                           , l_item_id
                           , l_org_id
                           , l_rev
                           , l_lot
                           , l_sub
                           , l_loc
                           , l_mo_line_id
                           , l_txn_qty
                           , l_mmtt_transaction_uom
                           , l_primary_quantity
                           , l_sec_txn_qty;
      EXIT WHEN c_mmtt_info%NOTFOUND;

      l_progress := '200';
      IF (l_debug = 1) THEN
          mdebug ('l_progress: ' || l_progress );
          -- Bug# 5760606 - add more debug info
          mdebug('l_mo_line_id:' || l_mo_line_id || ', l_txn_hdr_id:' || l_txn_hdr_id || ', l_txn_temp_id:' || l_txn_temp_id || ', l_parent_line_id:' || l_parent_line_id);
      END IF;


      IF l_wf > 0
      THEN
            l_progress := '220';
            IF (l_debug = 1) THEN mdebug ('l_progress: ' || l_progress ); END IF;
            wms_workflow_wrappers.wf_wrapper
         (p_api_version          =>  1.0,
          p_init_msg_list        =>  fnd_api.g_false,
          p_commit               =>  fnd_api.g_false,
          p_org_id               =>  l_org_id ,
          p_rsn_id               =>  p_qty_rsn_id,
          p_calling_program      =>  l_calling_program,
          p_tmp_id               =>  l_txn_temp_id,
          p_quantity_picked      =>  l_txn_qty,
          p_dest_sub             =>  l_sub,
          p_dest_loc             =>  l_loc,
          x_return_status        =>  x_return_status ,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data);

            IF (l_debug = 1) THEN mdebug('x_return_status = ' || x_return_status); END IF;
            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 fnd_message.set_name('WMS', 'WMS_MULT_LPN_ERROR');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                 fnd_message.set_name('WMS', 'WMS_MULT_LPN_ERROR');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
            END IF;
            -- MRANA : added the following 3392471 . : 26-feb-04
            -- Cascade delete the current MMTT and WDT That was just processed

            DELETE FROM wms_dispatched_tasks WHERE transaction_temp_id = p_temp_id;
            IF SQL%NOTFOUND THEN
               mdebug ('NO WDT TO DELETE' );
               -- could not find the task to delete.. do not worry
               null;
            END IF;
            mdebug ('Calling INV_TRX_UTIL_PUB.delete_transaction ' );
            INV_TRX_UTIL_PUB.delete_transaction(
              x_return_status       => x_return_status
            , x_msg_data            => x_msg_data
            , x_msg_count           => x_msg_count
            , p_transaction_temp_id => l_txn_temp_id
            ,p_update_parent => l_update_parent
            );
            mdebug ('x_return_status ' || x_return_status);

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_debug = 1 THEN
                mdebug('CLEANUP_TASK: Error occurred while deleting MMTT');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;
      -- MRANA : 2/26/04 -- END IF; if Wf does not exist only then the following
                         --shld be performed
      ELSE  -- wf <=0
         l_progress := '250';
         IF (l_debug = 1) THEN mdebug ('l_progress: ' || l_progress ); END IF;
         OPEN  c_mo_line_info;
         FETCH c_mo_line_info
         INTO  l_mo_type,
               l_mol_src_id,
               l_mol_src_line_id,
               l_mol_reference_id,
               l_mol_qty,
               l_mtrl_uom,
               l_mol_qty_delivered;
         CLOSE c_mo_line_info;

         l_progress := '260';
         IF (l_debug = 1) THEN
         mdebug('cleanup_task: transaction_uom:'||l_mmtt_transaction_uom);
            mdebug('cleanup_task: move order line uom :'|| l_mtrl_uom);
         END IF;

         IF (l_mtrl_uom <> l_mmtt_transaction_uom)
         THEN
               l_progress := '270';
               IF (l_debug = 1) THEN
                  mdebug ('l_progress: ' || l_progress );
               END IF;
               l_txn_qty := INV_Convert.inv_um_convert
                      (item_id  => l_item_id,
                precision => null,
                from_quantity  => l_txn_qty,
                from_unit => l_mmtt_transaction_uom,
                to_unit         => l_mtrl_uom,
                from_name => null,
                to_name         => null);
         END IF;

         l_progress := '280';
         IF (l_debug = 1) THEN
            mdebug ('l_progress: ' || l_progress );
         END IF;
         OPEN c_get_other_mmtt;
         FETCH c_get_other_mmtt INTO l_other_mmtt_count;
         CLOSE c_get_other_mmtt;

         IF (l_debug = 1) THEN
           mdebug('CLEANUP_TASK: Number of MMTTs other than this MMTT : ' || l_other_mmtt_count);
         END IF;

         IF l_other_mmtt_count > 0 THEN
           IF (l_debug = 1) THEN
             mdebug('CLEANUP_TASK: Other MMTT lines exist too. So cant close MO Line');
           END IF;

           l_progress := '290';
           IF (l_debug = 1) THEN
               mdebug ('l_progress: ' || l_progress );
           END IF;

         --Bug#6027401. Begins
         BEGIN
           IF (l_debug = 1) THEN
             mdebug('CLEANUP_TASK: Before we update MO and delete MMTT, we need to update reservation ');
           END IF;
          SELECT nvl(mmtt.reservation_id,-1) , mr.primary_reservation_quantity ,
                mr.reservation_quantity, mr.primary_uom_code , mr.reservation_uom_code
          INTO l_reservation_id  , l_pri_rsv_qty, l_rsv_qty , l_pri_rsv_uom, l_rsv_uom
          FROM mtl_material_transactions_temp mmtt ,  mtl_reservations mr
	  WHERE mmtt.transaction_temp_id = l_txn_temp_id
          AND   mr.reservation_id = mmtt.reservation_id ;

          IF (l_debug = 1) THEN
           mdebug('CLEANUP_TASK: l_reservation_id:'||l_reservation_id || ' ,l_pri_rsv_qty :'
                                                  ||l_pri_rsv_qty||',l_rsv_qty :'||l_rsv_qty );
           mdebug('CLEANUP_TASK: MMTT.pri_qty:'||l_primary_quantity ||' ,l_pri_rsv_uom :'
                                                   ||l_pri_rsv_uom||',l_rsv_uom :'||l_rsv_uom );
          END IF;

          IF (l_rsv_qty  >  l_primary_quantity  ) THEN
           l_old_upd_resv_rec.reservation_id               := l_reservation_id ;
           l_new_upd_resv_rec.primary_reservation_quantity := l_pri_rsv_qty -  l_primary_quantity ;
           IF (l_pri_rsv_uom <> l_rsv_uom ) THEN
              l_new_upd_resv_rec.reservation_quantity      := l_rsv_qty - INV_Convert.inv_um_convert (
                                                                    item_id        => l_item_id,
                                                                     precision     => null,
                                                                     from_quantity => l_primary_quantity ,
                                                                     from_unit     => l_pri_rsv_uom,
                                                                     to_unit       => l_rsv_uom,
                                                                     from_name     => null,
                                                                     to_name       => null  );
          ELSE
             l_new_upd_resv_rec.reservation_quantity      := l_rsv_qty  -  l_primary_quantity ;
          END IF;

          IF (l_debug = 1) THEN
           mdebug('CLEANUP_TASK: Calling update_reservation api : ' );
          END IF;

          inv_reservation_pub.update_reservation(
		      p_api_version_number         => 1.0
	            , p_init_msg_lst               => fnd_api.g_false
	            , x_return_status              => x_return_status
		    , x_msg_count                  => x_msg_count
	            , x_msg_data                   => x_msg_data
		    , p_original_rsv_rec           => l_old_upd_resv_rec
	            , p_to_rsv_rec                 => l_new_upd_resv_rec
	            , p_original_serial_number     => l_upd_dummy_sn
	            , p_to_serial_number           => l_upd_dummy_sn
	            , p_validation_flag            => fnd_api.g_true
		    );

          IF (l_debug = 1) THEN
           mdebug('CLEANUP_TASK: return of update_reservation api : ' || x_return_status);
          END IF;
	 END IF;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            mdebug('CLEANUP_TASK: There is no reservation for this MMTT  ' );
          END IF;
       WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            mdebug('CLEANUP_TASK: OTHERS EXCEPTION !!!! while Updating reservation ' );
          END IF;
       END;
       --Bug#6027401. Ends.

       l_progress := '295';
       IF (l_debug = 1) THEN
          mdebug ('l_progress: ' || l_progress );
       END IF;
      --Bug#6027401. Ends.

       INV_TRX_UTIL_PUB.delete_transaction(
             x_return_status       => x_return_status
           , x_msg_data            => x_msg_data
           , x_msg_count           => x_msg_count
           , p_transaction_temp_id => l_txn_temp_id
           ,p_update_parent => l_update_parent
           );

           IF x_return_status <> fnd_api.g_ret_sts_success THEN
             IF l_debug = 1 THEN
               mdebug('CLEANUP_TASK: Error occurred while deleting MMTT');
             END IF;
             RAISE fnd_api.g_exc_error;
           END IF;

           IF (l_wf <= 0) or (p_qty_rsn_id <= 0) then
               l_progress := '300';
               IF (l_debug = 1) THEN
                  mdebug ('l_progress: ' || l_progress );
               END IF;
               UPDATE mtl_txn_request_lines
                  SET quantity_detailed = quantity_detailed - l_txn_qty
                    , secondary_quantity_detailed = DECODE(secondary_uom_code,NULL,NULL,
                                                      secondary_quantity_detailed - l_sec_txn_qty)  -- Bug 8312574
                    , last_update_date = SYSDATE
                    , last_updated_by  = p_user_id
                WHERE line_id = l_mo_line_id;
                mdebug ('quantity_detailed : ' || l_txn_qty );
           END IF;
         ELSE
           L_progress := '310';
           if (l_debug = 1) THEN
              mdebug ('l_progress: ' || l_progress );
               mdebug('CLEANUP_TASK: Just one MMTT line exists. Close MO');
           END IF;

           IF (l_mo_type IN ( INV_GLOBALS.G_MOVE_ORDER_PICK_WAVE,
                           INV_GLOBALS.G_MOVE_ORDER_MFG_PICK)) THEN
               l_progress := '320';
               IF (l_debug = 1) THEN
                  mdebug ('l_progress: ' || l_progress );
               END IF;
               DELETE FROM wms_dispatched_tasks WHERE transaction_temp_id = p_temp_id;

               IF SQL%NOTFOUND THEN
                  mdebug ('NO WDT TO DELETE' );
                  -- could not find the task to delete.. do not worry
                  null;
               END IF;
               inv_mo_backorder_pvt.backorder(
                 p_line_id       => l_mo_line_id
               , x_return_status => x_return_status
               , x_msg_count     => x_msg_count
               , x_msg_data      => x_msg_data
               );

               IF x_return_status <> l_g_ret_sts_success
               THEN
                 IF (l_debug = 1) THEN
                   mdebug('CLEANUP_TASK: Unexpected error occurrend while calling BackOrder API');
                 END IF;
                 RAISE fnd_api.g_exc_error;
               END IF;


           ELSIF l_mo_type IN (INV_GLOBALS.G_MOVE_ORDER_REQUISITION, INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT) THEN
               l_progress := '370';
               IF (l_debug = 1) THEN mdebug ('l_progress: ' || l_progress ); END IF;
             UPDATE mtl_txn_request_lines
                SET quantity_detailed = quantity_delivered
                  , secondary_quantity_detailed =
                      DECODE(secondary_uom_code,NULL,NULL,secondary_quantity_delivered)  -- Bug 8312574
                  , last_update_date = SYSDATE
                  , last_updated_by  = p_user_id
              WHERE line_id = l_mo_line_id;

             INV_TRX_UTIL_PUB.delete_transaction(
               x_return_status       => x_return_status
             , x_msg_data            => x_msg_data
             , x_msg_count           => x_msg_count
             , p_transaction_temp_id => l_txn_temp_id
             ,p_update_parent => l_update_parent
             );

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
               IF l_debug = 1 THEN
                 mdebug('CLEANUP_TASK: Error occurred while deleting MMTT');
               END IF;
               RAISE fnd_api.g_exc_error;
             END IF;

	     --Bug 5162468 for Fill kill zero pick condition
             --close the MO line

	     IF (l_kill_mo_profile = 1) and (l_mo_type =  INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT)
	        AND ((l_other_mmtt_count = 0) AND (NVL(l_mol_qty_delivered,0) =0)) THEN

		IF (l_debug = 1) THEN
		  l_progress := '375';
		   mdebug ('l_progress: ' || l_progress);
		   mdebug ('Check for MO line closing for Fill Kill pick none  ... ');
                   mdebug('Replenishment Move Order... pending task count :'|| l_other_mmtt_count);
                   mdebug('Replenishment Move Order... quantity delivered :'|| l_mol_qty_delivered);
                   mdebug('Replenishment Move Order... Closing the Move Order');
	       END IF;

               INV_MO_ADMIN_PUB.close_line(1.0,'F','F','F',l_mo_line_id,x_msg_count,x_msg_data,l_return_status);
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

	     END IF;


	     l_progress := '380';
             IF (l_debug = 1) THEN mdebug ('l_progress: ' || l_progress ); END IF;
             IF (l_wf <= 0) or (p_qty_rsn_id <= 0) then
                UPDATE mtl_txn_request_lines
                   SET quantity_detailed = quantity_delivered
                     , secondary_quantity_detailed =
                          DECODE(secondary_uom_code,NULL,NULL,secondary_quantity_delivered) -- Bug 8312574
                     , last_update_date = SYSDATE
                     , last_updated_by  = p_user_id
                 WHERE line_id = l_mo_line_id;
             END IF;
           END IF;
         END IF;
      END IF;  -- WF <=0
    END LOOP;

    wms_txnrsn_actions_pub.log_exception(
                             p_api_version_number         => 1.0
                           , p_init_msg_lst               => fnd_api.g_false
                           , p_commit                     => fnd_api.g_false
                           , x_return_status              => x_return_status
                           , x_msg_count                  => x_msg_count
                           , x_msg_data                   => x_msg_data
                           , p_organization_id            => l_org_id
                           , p_item_id                    => l_item_id
                           , p_revision                   => l_rev
                           , p_lot_number                 => l_lot
                           , p_subinventory_code          => l_sub
                           , p_locator_id                 => l_loc
                           , p_mmtt_id                    => p_temp_id
                           , p_task_id                    => p_temp_id
                           , p_reason_id                  => p_qty_rsn_id
                           , p_discrepancy_type           => 1
                           , p_user_id                    => p_employee_id);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_unexpected_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
       fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := '390';

    -- Bug# 5760606 - set global name back since it is changed in the above call to log_exception
    g_module_name := l_proc_name;

    l_progress := '400';

    -- For checking Bulk task.Check if p_temp_id passed is also
    --parent line id.If it's bulk task then call delete transaction.


    IF l_parent_line_id = p_temp_id
        THEN
         mdebug('Now calling delete transaction for parent line');
         INV_TRX_UTIL_PUB.delete_transaction(
                                             x_return_status       => x_return_status
                                             , x_msg_data            => x_msg_data
                                             , x_msg_count           => x_msg_count
                                             , p_transaction_temp_id => l_parent_line_id
                                             ,p_update_parent => l_update_parent
                                             );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            mdebug ('Clean up task in loop for deleting parent line ');
            IF l_debug = 1 THEN
               mdebug('CLEANUP_TASK: Error occurred while deleting parent line inMMTT');
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
    END IF; --for parent line IF

    CLOSE c_mmtt_info;
    --COMMIT; --???
  mdebug('END : ' || l_proc_name );
  EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mdebug('ROLLBACK ' );
        ROLLBACK ;
        mdebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mdebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mdebug('ROLLBACK ' );
        ROLLBACK ;
        mdebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mdebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END cleanup_task;


PROCEDURE process_exceptions
  (p_organization_id          IN NUMBER,
   p_employee_id              IN NUMBER,
   p_effective_start_date     IN DATE,
   p_effective_end_date       IN DATE,
   p_inventory_item_id        IN NUMBER,
   p_revision                 IN VARCHAR2,
   p_discrepancies            IN VARCHAR2,
   x_return_status            OUT nocopy VARCHAR2,
   x_msg_count                OUT nocopy NUMBER,
   x_msg_data                 OUT nocopy VARCHAR2) IS

    l_discrepancies       VARCHAR2(4000) := p_discrepancies;
    l_start_index         NUMBER;
    l_end_index           NUMBER;
    l_discrepancy         VARCHAR2(1000);
    l_reason_context_code VARCHAR2(2);
    l_reason_id           NUMBER;
    l_transaction_temp_id NUMBER;
    l_subinventory_code   wms_exceptions.subinventory_code%TYPE;
    l_locator_id          NUMBER;
    l_lpn_id              NUMBER;
    l_lot_number          mtl_lot_numbers.lot_number%TYPE;
    l_workflow_name       mtl_transaction_reasons.workflow_name%TYPE;
    l_workflow_process    mtl_transaction_reasons.workflow_process%TYPE;
    l_user_id             NUMBER := fnd_global.user_id;

BEGIN
   x_return_status := 'S';

   IF p_discrepancies IS NOT NULL THEN
      l_start_index := Instr(l_discrepancies, '{');
      l_end_index   := Instr(l_discrepancies, '}');

      WHILE l_start_index > 0 LOOP
  l_discrepancy := Substr(l_discrepancies, l_start_index + 1, l_end_index - l_start_index -1);
  l_discrepancies := Substr(l_discrepancies, l_end_index + 1);

  IF g_trace_on = 1 THEN
     mdebug(l_discrepancy, 'PROCESS_EXCEPTIONS');
  END IF;

  l_end_index   := Instr(l_discrepancy, '|');
  l_reason_context_code := Substr(l_discrepancy, 1, l_end_index -1);

  IF g_trace_on = 1 THEN
     mdebug('Reason Context Code: ' || l_reason_context_code, 'PROCESS_EXCEPTIONS');
  END IF;

  ---
  IF g_trace_on = 1 THEN
     mdebug('p_employee_id: ' || p_employee_id, 'PROCESS_EXCEPTIONS');
     mdebug('l_user_id:     ' || l_user_id, 'PROCESS_EXCEPTIONS');
  END IF;
  -----

  l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

  l_end_index   := Instr(l_discrepancy, '|');
  l_reason_id := To_number(Substr(l_discrepancy, 1, l_end_index -1));

  IF g_trace_on = 1 THEN
     mdebug('Reason ID: ' || l_reason_id, 'PROCESS_EXCEPTIONS');
  END IF;

  l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

  l_end_index   := Instr(l_discrepancy, '|');
  l_transaction_temp_id := To_number(Substr(l_discrepancy, 1, l_end_index -1));

  IF g_trace_on = 1 THEN
     mdebug('Transaction Temp ID: ' || l_transaction_temp_id, 'PROCESS_EXCEPTIONS');
  END IF;

  l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

  l_end_index   := Instr(l_discrepancy, '|');
  l_subinventory_code := Substr(l_discrepancy, 1, l_end_index -1);

  IF g_trace_on = 1 THEN
     mdebug('Subinventory Code: ' || l_subinventory_code, 'PROCESS_EXCEPTIONS');
  END IF;

  l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

  l_end_index   := Instr(l_discrepancy, '|');
  l_locator_id := To_number(Substr(l_discrepancy, 1, l_end_index -1));

  IF g_trace_on = 1 THEN
     mdebug('Locator ID: ' || l_locator_id, 'PROCESS_EXCEPTIONS');
  END IF;

         l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

  l_end_index   := Instr(l_discrepancy, '|');
  l_workflow_name := Substr(l_discrepancy, 1, l_end_index -1);

         IF Upper(l_workflow_name) = 'NULL' THEN
            l_workflow_name := NULL;
         END IF;

  IF g_trace_on = 1 THEN
     mdebug('Workflow Name: ' || l_workflow_name, 'PROCESS_EXCEPTIONS');
  END IF;

  l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

  l_end_index   := Instr(l_discrepancy, '|');

  IF l_end_index <> 0 THEN
     l_workflow_process := Substr(l_discrepancy, 1, l_end_index -1);
   ELSE
     l_workflow_process := Substr(l_discrepancy, 1);
  END IF;

         IF Upper(l_workflow_process) = 'NULL' THEN
            l_workflow_process := NULL;
         END IF;

  IF g_trace_on = 1 THEN
     mdebug('Workflow Process: ' || l_workflow_process, 'PROCESS_EXCEPTIONS');
  END IF;

  IF (l_reason_context_code = 'PS') THEN
     l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

     l_end_index   := Instr(l_discrepancy, '|');
     l_lpn_id := To_number(Substr(l_discrepancy, 1, l_end_index -1));

     IF g_trace_on = 1 THEN
        mdebug('LPN ID: ' || l_lpn_id, 'PROCESS_EXCEPTIONS');
     END IF;

     l_discrepancy := Substr(l_discrepancy, l_end_index + 1);

     l_lot_number := Substr(l_discrepancy, 1);

     IF g_trace_on = 1 THEN
        mdebug('Lot Number: ' || l_lot_number, 'PROCESS_EXCEPTIONS');
     END IF;

  END IF;

  IF (g_trace_on = 1) THEN
     mdebug('Inserting into exceptions', 'PROCESS_EXCEPTIONS');
  END IF;

  log_exception
    (p_api_version_number    => 1.0,
     p_init_msg_lst          => 'F',
     p_commit                => 'F',
     x_return_status         => x_return_status,
     x_msg_count             => x_msg_count,
     x_msg_data              => x_msg_data,
     p_organization_id       => p_organization_id,
     p_mmtt_id               => l_transaction_temp_id,
     p_task_id               => NULL,
     p_reason_id             => l_reason_id,
     p_subinventory_code     => l_subinventory_code,
     p_locator_id            => l_locator_id,
     p_discrepancy_type      => 1,
     --p_user_id               => l_user_id,
     p_user_id               => p_employee_id,
     p_item_id               => p_inventory_item_id,
     p_revision              => p_revision,
     p_lot_number            => l_lot_number,
            p_lpn_id                => l_lpn_id);

  l_start_index := Instr(l_discrepancies, '{');
  l_end_index   := Instr(l_discrepancies, '}');
      END LOOP;

   END IF;
END process_exceptions;

--Bug 6278066 Added a wrapper for log_exception
PROCEDURE Log_exception
(    x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_mmtt_id                       IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_reason_id                     IN  NUMBER
   , p_subinventory_code             IN  VARCHAR2
   , p_locator_id                    IN  NUMBER
   , p_discrepancy_type              IN  NUMBER
   , p_user_id                       IN  VARCHAR2
   , p_item_id                       IN  NUMBER:=NULL
   , p_revision                      IN  VARCHAR2:=NULL
   , p_lot_number                    IN  VARCHAR2:=NULL
   , p_lpn_id                        IN  NUMBER:=NULL
   , p_is_loc_desc                   IN  VARCHAR2
   )IS
	l_is_loc_desc		BOOLEAN;
  l_return_err VARCHAR2(230);
   BEGIN
	IF p_is_loc_desc = 'false' THEN
		l_is_loc_desc := FALSE;
	ELSE
		l_is_loc_desc := TRUE;
	END IF;

        Log_exception(
	     p_api_version_number         => 1.0
	   , p_init_msg_lst               => fnd_api.g_false
	   , p_commit                     => fnd_api.g_false
	   , x_return_status              => x_return_status
	   , x_msg_count                  => x_msg_count
	   , x_msg_data                   => x_msg_data
	   , p_organization_id            => p_organization_id
	   , p_mmtt_id                    => p_mmtt_id
	   , p_task_id                    => p_task_id
	   , p_reason_id                    => p_reason_id
	   , p_subinventory_code                    => p_subinventory_code
           , p_locator_id                    => p_locator_id
	   , p_discrepancy_type                    => p_discrepancy_type
	   , p_user_id                    => p_user_id
	   , p_item_id                    => p_item_id
	   , p_revision                    => p_revision
	   , p_lot_number                    => p_lot_number
	   , p_lpn_id                    => p_lpn_id
	   , p_is_loc_desc                    => l_is_loc_desc
	   );

EXCEPTION
      WHEN OTHERS THEN
		x_return_status:=FND_API.G_RET_STS_ERROR;
		l_return_err := 'Insert into WMS_Exceptions failed'||  substrb(sqlerrm,1,55);
		raise_application_error(-20000,l_return_err);

END Log_exception;

END wms_txnrsn_actions_pub  ;

/

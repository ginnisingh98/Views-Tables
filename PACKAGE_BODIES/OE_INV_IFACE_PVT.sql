--------------------------------------------------------
--  DDL for Package Body OE_INV_IFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INV_IFACE_PVT" AS
/* $Header: OEXVIIFB.pls 120.8.12010000.2 2009/07/14 09:09:51 spothula ship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Inv_Iface_PVT';

TYPE Profile_type IS RECORD
( oe_source_code VARCHAR2(240)
, user_id        NUMBER
, login_id       NUMBER
, request_id     NUMBER
, application_id NUMBER
, program_id     NUMBER);

profile_values  Profile_type;

--  Start of Comments
--  API name    OE_Inv_Iface_PVT
--  Type        Private
--  Version     Current version = 1.0
--              Initial version = 1.0

PROCEDURE Inventory_Interface
(
  p_line_id        IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

, x_result_out OUT NOCOPY VARCHAR2

)
IS
l_return_status         VARCHAR2(30);
l_line_rec              OE_Order_Pub.Line_Rec_Type;
l_sales_order_id        NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_rsv_rec               INV_RESERVATION_GLOBAL.mtl_reservation_rec_type;
l_rsv_tbl               INV_RESERVATION_GLOBAL.mtl_reservation_tbl_type;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
l_concat_segs           VARCHAR2(2000);
l_concat_ids            VARCHAR2(2000);
l_concat_descrs         VARCHAR2(2000);
l_trans_acc             NUMBER;
l_transaction_header_id NUMBER;
l_source_line_id        NUMBER;
l_revision_code         NUMBER;
l_lot_code              NUMBER;
l_serial_code           NUMBER;
l_subinventory          VARCHAR2(10);
l_order_number          NUMBER;
l_order_type_name       VARCHAR2(200);
reservation_flag        VARCHAR2(1) := 'N';
l_hold_result_out       VARCHAR2(30);
l_hold_return_status    VARCHAR2(30);
l_hold_msg_count        NUMBER;
l_hold_msg_data         VARCHAR2(240);
l_transaction_reference NUMBER;
l_transaction_interface_id NUMBER;
l_remained_qty          NUMBER;
l_remained_qty2          NUMBER; -- INVCONV
l_lot                   VARCHAR2(1);
l_revision              VARCHAR2(1);
l_locator                      NUMBER;
l_stock_locator_control_code   NUMBER;
l_locator_type                 NUMBER;
l_location_control_code        NUMBER;
l_transactable_flag            VARCHAR2(1);
l_index                       NUMBER;
l_ordered_date                DATE;
-- Process Order arguments

-- l_control_rec               OE_GLOBALS.control_rec_type;
l_line_tbl                  OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl              OE_ORDER_PUB.line_tbl_type;
/*
l_header_rec                OE_Order_PUB.Header_Rec_Type;
l_new_line_rec              OE_Order_PUB.Line_Rec_Type := OE_Order_Pub.G_MISS_LINE_REC;
l_new_line_tbl              OE_Order_PUB.Line_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_adj_out_tbl          OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_lot_serial_out_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;
l_Header_Adj_Att_tbl        OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl      OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
l_Header_price_Att_tbl      OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
l_Line_Price_Att_tbl        OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl          OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl        OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
*/

/* -- HW OPM BUG#:2536589 added variable to hold item_rec information
 l_item_rec         	 OE_ORDER_CACHE.item_rec_type;
 l_process_org           NUMBER;
 opm_msg_count           NUMBER;
 opm_msg_data            VARCHAR2(100);
 opm_lot_id              NUMBER ;
 x_reservation_id        NUMBER;

 -- HW end of chanegs for 2536589 */
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_trx_date_for_inv_iface     DATE; --bug5897965
BEGIN

   SAVEPOINT INVENTORY_INTERFACE;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INV IFACE: ENTERING INVENTORY INTERFACE' , 1 ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_result_out    := OE_GLOBALS.G_WFR_COMPLETE;

   profile_values.oe_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
   profile_values.user_id        := FND_GLOBAL.USER_ID;
   profile_values.login_id       := FND_GLOBAL.LOGIN_ID;
   profile_values.request_id     := 0;
   profile_values.application_id := 0;
   profile_values.program_id     := 0;

   OE_MSG_PUB.set_msg_context(
       p_entity_code        => 'LINE'
      ,p_entity_id          => p_line_id
      ,p_line_id            => p_line_id);

   /* check for holds */
   OE_HOLDS_PUB.CHECK_HOLDS(p_api_version => 1.0,
                     p_line_id => p_line_id,
                     p_wf_item => OE_GLOBALS.G_WFI_LIN,
                     p_wf_activity => 'INVENTORY_INTERFACE',
                     x_result_out => l_hold_result_out,
                     x_return_status => l_hold_return_status,
                     x_msg_count => l_hold_msg_count,
                     x_msg_data => l_hold_msg_data);

   IF ( l_hold_return_status = FND_API.G_RET_STS_SUCCESS AND
             l_hold_result_out = FND_API.G_TRUE ) THEN
   /* we are reusing the OE_INVOICING_HOLD message here,
      the message is generic, not invoicing specific */

          FND_MESSAGE.SET_NAME('ONT','OE_INVOICING_HOLD');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_result_out := OE_GLOBALS.G_WFR_ON_HOLD;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV IFACE: ACTIVITY ON HOLD , EXITING' , 5 ) ;
          END IF;
          RETURN;
   ELSIF l_hold_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV IFACE: CHECK HOLD API ERROR' , 5 ) ;
          END IF;
          RETURN;
   END IF;

   /* Query up the line rec */

   OE_Line_Util.Lock_Row(p_line_id=>p_line_id
                       , p_x_line_rec => l_line_rec
                       , x_return_status => l_return_status
                        );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INV IFACE: LOCK_ROW FAILED' , 5 ) ;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INV IFACE: LOCK_ROW FAILED' , 5 ) ;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
   END IF;

    OE_MSG_PUB.update_msg_context(
      p_header_id                  => l_line_rec.header_id
     ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
     ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
     ,p_change_sequence            => l_line_rec.change_sequence
     ,p_source_document_id         => l_line_rec.source_document_id
     ,p_source_document_line_id    => l_line_rec.source_document_line_id
     ,p_order_source_id            => l_line_rec.order_source_id
     ,p_source_document_type_id    => l_line_rec.source_document_type_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INV IFACE: LOCK_ROW COMPLETED' , 5 ) ;
   END IF;


 SELECT MTL_TRANSACTIONS_ENABLED_FLAG
 INTO   l_transactable_flag
 FROM   MTL_SYSTEM_ITEMS
 WHERE inventory_item_id = l_line_rec.inventory_item_id
 AND   organization_id   = l_line_rec.ship_from_org_id;

 IF l_line_rec.shippable_flag = 'Y' THEN
   IF nvl(l_line_rec.source_type_code, OE_GLOBALS.G_SOURCE_EXTERNAL)
            = OE_GLOBALS.G_SOURCE_EXTERNAL OR
          l_transactable_flag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_result_out := OE_GLOBALS.G_WFR_NOT_ELIGIBLE;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INV IFACE: INV IFACE NOT ELIGIBLE - EXTERNAL OR NON TRANSACTABLE' , 5 ) ;
      END IF;
      RETURN;
   END IF;

   IF l_line_rec.ship_from_org_id is null THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INV IFACE: INV IFACE INCOMPLETE - NO WAREHOUSE' , 5 ) ;
      END IF;
      FND_MESSAGE.SET_NAME('ONT', 'OE_INV_NO_WAREHOUSE');
      OE_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
      RETURN;
   END IF;

/* get order info */
   SELECT /* MOAC_SQL_CHANGE */  h.order_number,ot.name,h.ordered_date
   INTO   l_order_number,l_order_type_name,l_ordered_date
   FROM   oe_order_headers_all h, oe_order_types_v ot
   WHERE  h.header_id      = l_line_rec.header_id AND
          ot.order_type_id = h.order_type_id;

--
-- Bug # 4454055
-- Code is commented for Deferred Revenue Project
-- The COGS account generator workflow will no longer be called at shipping time, instead,
-- Inventory will stamp deferred cogs account on MMT transactions.
-- The deferred cogs account can be defined at each inventory org level.
-- When revenue is recognized, Costing will get notified and call the OM COGS
-- account generator to get the cogs account and recognize cogs in the same period where
-- revenue is recognized. Also when an order line is closed without getting invoiced,
-- cogs will be recognized at the closing time assuming there would be no future revenue recognition event.
--
-- This code is uncommented as back to get the functionality of 11.5.10 back. This is done in concurrence with the Inv and the Costing team.
--
-- Start Deferred Revenue Project
-- bug5897965, begin
   -- transaction date for inventory interface will be derived from the system parameter
   -- New system parameter is - Transaction Date for Inventory Interface Non Ship Process
   -- It will have the default value of Ordered Date (derived from order header as above)
   -- Other possible values are Sysdate, Schedule Ship Date from the Order line

   SELECT DECODE(OE_SYS_PARAMETERS.value('TRX_DATE_FOR_INV_IFACE'),
                                   'C',SYSDATE,
                                   'S',nvl(l_line_rec.schedule_ship_date,SYSDATE),
                                   l_ordered_date)
   INTO   l_trx_date_for_inv_iface
   FROM   DUAL;

   IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.add('Transaction Date derived from system parameter setup is '||l_trx_date_for_inv_iface,1);
   END IF;
--bug5897965, end

  IF OE_FLEX_COGS_PUB.Start_Process (
      p_api_version_number    => 1.0,
      p_line_id               => p_line_id,
      x_return_ccid           => l_trans_acc,
      x_concat_segs           => l_concat_segs,
      x_concat_ids            => l_concat_ids,
      x_concat_descrs         => l_concat_descrs,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data) <> FND_API.G_RET_STS_SUCCESS
  THEN
      -- if COGS workflow fails for some reason,
      -- we will return INCOMPLETE

      l_trans_acc := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INV IFACE: COGS FAIL' , 5 ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
      RETURN;
  END IF;

-- End Deferred Revenue Project


  -- if item is under lot/serial/revision control
  BEGIN
            SELECT revision_qty_control_code, lot_control_code, serial_number_control_code
            INTO l_revision_code, l_lot_code, l_serial_code
            FROM mtl_system_items
            WHERE inventory_item_id = l_line_rec.inventory_item_id
            AND   organization_id   = l_line_rec.ship_from_org_id;
  EXCEPTION
      WHEN OTHERS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'INV IFACE: REVISION/LOT SELECT FAILURE' , 5 ) ;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                RETURN;
  END;

  -- we dont support serial numbers
  IF nvl(l_serial_code, 1) <> 1 THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'INV IFACE: ITEM UNDER SERIAL CONTORL , ERROR' , 5 ) ;
             END IF;
             -- give a message here
             FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_SERIAL');
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
             RETURN;
  END IF;

  IF l_revision_code = 2 THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INV IFACE: ITEM UNDER REVISION CONTROL' , 5 ) ;
               END IF;
               l_revision := 'Y';
  END IF;

  IF l_lot_code = 2 THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INV IFACE: ITEM UNDER LOT CONTROL' , 5 ) ;
               END IF;
               l_lot := 'Y';
  END IF;

-- HW OPM BUG#:2536589
  IF l_lot_code = 1 THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INV IFACE: ITEM UNDER NON LOT CONTROL' , 5 ) ;
     END IF;
     l_lot := 'N';
  END IF;


  -- we will use this transaction_header_id for all
  -- interface lines
  SELECT mtl_material_transactions_s.nextval
  INTO l_transaction_header_id
  FROM dual;

  l_transaction_interface_id := l_transaction_header_id;

  l_transaction_reference := l_line_rec.header_id;


/* figure out nocopy reserved_quantity */

  --4504362
   l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                              (l_line_rec.header_id);

   -- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
																							);



   /*l_line_rec.reserved_quantity := OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id); */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INV IFACE: RESERVED_QTY = ' || TO_CHAR ( L_LINE_REC.RESERVED_QUANTITY ) , 5 ) ;
   END IF;


   -- INVCONV

   /*l_line_rec.reserved_quantity2 := OE_LINE_UTIL.Get_Reserved_Quantity2
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id); */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INV IFACE: RESERVED_QTY2 = ' || TO_CHAR ( L_LINE_REC.RESERVED_QUANTITY2 ) , 5 ) ;
   END IF;




/* --HW OPM BUG#:2536589 Need to initialize variable -- INVCONV NOT NEEDED NOW
   l_remained_qty := 0;

-- HW OPM BUG#:2536589 - Check if org is process or discrete
   IF oe_line_util.Process_Characteristics
      (l_line_rec.inventory_item_id
       ,l_line_rec.ship_from_org_id
       ,l_item_rec) THEN
       l_process_org := 1;
   ELSE
     l_process_org := 0;
   END IF;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'VALUE OF L_PROCESS_FLAG IS '||TO_CHAR ( L_PROCESS_ORG ) , 5 ) ;
END IF;   */


/* -- HW OPM BUG#:2536589 Check if requested_qty < qty_reserved for OPM   INVCONV NOT NEEDED NOW

   IF (l_process_org = 1 AND
       l_line_rec.reserved_quantity > l_line_rec.ordered_quantity  ) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INV IFACE FAILED: ORDERED_QTY IS < RESERVED_QTY FOR OPM' , 5 ) ;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
     ROLLBACK TO INVENTORY_INTERFACE;
     RETURN;
  END IF;
-- HW OPM BUG#:2536589 end of changes    */

   IF l_line_rec.reserved_quantity > 0 THEN
          reservation_flag := 'Y';
          IF l_line_rec.reserved_quantity < l_line_rec.ordered_quantity THEN
              -- partial reservation, we need to interface
              -- the unreserved qty as well
              l_remained_qty := l_line_rec.ordered_quantity - l_line_rec.reserved_quantity;
              l_remained_qty2 := l_line_rec.ordered_quantity2 - l_line_rec.reserved_quantity2; -- invconv

          END IF;

          l_rsv_rec.demand_source_header_id  := l_sales_order_id;
          l_rsv_rec.demand_source_line_id    := l_line_rec.line_id;
          l_rsv_rec.organization_id  := l_line_rec.ship_from_org_id;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV IFACE: CALLING INVS QUERY_RESERVATION ' , 1 ) ;
          END IF;

          inv_reservation_pub.query_reservation
              (  p_api_version_number       => 1.0
              , p_init_msg_lst              => FND_API.G_TRUE
              , x_return_status             => l_return_status
              , x_msg_count                 => l_msg_count
              , x_msg_data                  => l_msg_data
              , p_query_input               => l_rsv_rec
              , x_mtl_reservation_tbl       => l_rsv_tbl
              , x_mtl_reservation_tbl_count => l_count
              , x_error_code                => l_x_error_code
              , p_lock_records              => l_lock_records
              , p_sort_by_req_date          => l_sort_by_req_date
              );
                                 IF l_debug_level  > 0 THEN
                                     oe_debug_pub.add(  'INV IFACE: AFTER CALLING INVS QUERY_RESERVATION: ' || L_RETURN_STATUS || ' COUNT: ' || L_RSV_TBL.COUNT , 1 ) ;
                                 END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
             l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'INV IFACE: QUERY_RESERVATION FAILED' , 5 ) ;
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              RETURN;
          END IF;

-- LOOP to insert reservation record to interface table

         FOR I in 1..l_rsv_tbl.count LOOP
              -- validate the inventory control are being satisfied
              IF l_revision = 'Y' THEN
                 IF l_rsv_tbl(I).revision is null THEN
                        -- give a message
                        FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_REVISION');
                        OE_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
				    ROLLBACK TO INVENTORY_INTERFACE;
				    RETURN;
                 END IF;
              END IF;

              IF l_lot = 'Y' THEN

-- HW BUG#:2536589 Since OPM doesn't save lot information in the reservation record, we need
-- to branch and retrieve lot_id from OPM TRXN table
                IF ( l_rsv_tbl(I).lot_number is null ) THEN  -- INVCONV
                -- AND l_process_org = 0 ) THEN -- For discrete INVCONV
                       -- give a message
                        FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_LOT');
                        OE_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                        ROLLBACK TO INVENTORY_INTERFACE;
                        RETURN;
                END IF; -- INVCONV
            END IF;      -- of l_lot  == 'Y'



/* -- HW BUG#:2536589, item belongs to OPM and lot control       INVCONV
                ELSIF (l_process_org = 1 AND l_rsv_tbl(I).reservation_quantity <> 0) THEN  -- For OPM
-- Make sure lot exists and allocated for OPM
                   GMI_RESERVATION_UTIL.FIND_LOT_ID(
                     l_rsv_tbl(I).reservation_id
                     ,l_return_status
                     ,opm_msg_count
                     ,opm_msg_data);

-- This error is reported if lot_id is not found
                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'INV IFACE: FAILED TO FETCH LOT_ID INFORMATION FOR OPM TRXN FOR TRANS_ID' || TO_CHAR ( L_RSV_TBL ( I ) .RESERVATION_ID ) , 5 ) ;
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                      ROLLBACK TO INVENTORY_INTERFACE;
                      RETURN;
                   END IF; -- of error checking
                END IF;    -- of branching   */   --INVCONV



/*   --HW OPM BUG#:2536589 Item belongs to OPM. This call is for non-inv and  INVCONV
        -- inv opm items
              IF ( l_process_org = 1 AND
                   l_rsv_tbl(I).reservation_quantity <> 0
                   AND l_remained_qty = 0 ) THEN

                   GMI_Reservation_Util.update_opm_trxns(
                      l_rsv_tbl(I).reservation_id
                      ,l_line_rec.inventory_item_id
                      ,l_line_rec.ship_from_org_id
                      ,l_return_status
                      ,opm_msg_count
                      ,opm_msg_data);

                   IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'INV IFACE: FAILED TO UPDATE OPM TRXNS' , 5 ) ;
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                      ROLLBACK TO INVENTORY_INTERFACE;
                      RETURN;
                   END IF;

              END IF;  -- if process_org        */
              /* handle locator */

 /*    -- HW OPM BUG#:2536589 Need to branch since none of the followings are applicable to OPM
            IF ( l_process_org = 0 ) THEN   */-- INVCONV


              IF l_rsv_tbl(I).subinventory_code is null THEN
                 -- give a message
                 FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_RSV_SUB');
                 OE_MSG_PUB.ADD;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                 ROLLBACK TO INVENTORY_INTERFACE;
                 RETURN;
              ELSE
                 BEGIN
                 SELECT stock_locator_control_code
                 INTO   l_stock_locator_control_code
                 FROM   mtl_parameters
                 WHERE  organization_id = l_line_rec.ship_from_org_id ;


                 EXCEPTION
                     WHEN OTHERS THEN
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INV IFACE: LOCATOR CONTROL CODE FAILURE' , 5 ) ;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                        ROLLBACK TO INVENTORY_INTERFACE;
                        RETURN;
                 END;

                 BEGIN
                 SELECT locator_type
                 INTO   l_locator_type
                 FROM   mtl_secondary_inventories
                 WHERE  secondary_inventory_name = l_rsv_tbl(I).subinventory_code
                 AND    organization_id = l_line_rec.ship_from_org_id;

                 EXCEPTION
                     WHEN OTHERS THEN
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INV IFACE: LOCATOR TYPE FAILURE' , 5 ) ;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                        ROLLBACK TO INVENTORY_INTERFACE;
                        RETURN;
                 END;

                 BEGIN
                 SELECT location_control_code
                 INTO   l_location_control_code
                 FROM   mtl_system_items
                 WHERE  inventory_item_id = l_line_rec.inventory_item_id
                 AND    organization_id = l_line_rec.ship_from_org_id;
                 EXCEPTION
                     WHEN OTHERS THEN
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INV IFACE: LOCATION CONTROL CODE FAILURE' , 5 ) ;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                        ROLLBACK TO INVENTORY_INTERFACE;
                        RETURN;
                 END;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'INV IFACE: BEFORE LOCATOR_CONTROL API CALL' , 1 ) ;
                 END IF;
                 l_locator := INV_RESERVATION_UTIL_PVT.locator_control(
                         p_org_control => l_stock_locator_control_code
                        ,p_sub_control => l_locator_type
                        ,p_item_control => l_location_control_code);
                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'INV IFACE: AFTER LOCATOR_CONTROL API CALL - ' || TO_CHAR ( L_LOCATOR ) , 1 ) ;
                                       END IF;


                 IF l_locator > 1 THEN -- under locator control
                   IF l_rsv_tbl(I).locator_id is null THEN
                       -- give a message
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INV IFACE: ITEM UNDER LOCATOR CONTROL' , 5 ) ;
                        END IF;
                        FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_LOCATOR');
                        OE_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                        ROLLBACK TO INVENTORY_INTERFACE;
                        RETURN;
                   END IF;
                 END IF;

            END IF;
          --   END IF; -- of branch HW BUG#:2535689   INVCONV

/*  -- HW OPM BUG#:2536589 No need to populate these tables for OPM.  INVCONV -NOT NEEDED NOW FOR opm iNVENTORY CONVERGENCE
-- Added a branch
         IF ( l_process_org = 0 ) THEN  */

               SELECT oe_transactions_iface_s.nextval
               INTO l_source_line_id
               FROM dual;

              IF l_lot = 'Y' THEN
               INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE
               (
                SOURCE_CODE,
                SOURCE_LINE_ID,
                TRANSACTION_INTERFACE_ID,
                LOT_NUMBER,
                TRANSACTION_QUANTITY,
                SECONDARY_TRANSACTION_QUANTITY, -- INVCONV
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                SERIAL_TRANSACTION_TEMP_ID,
                ERROR_CODE,
                PROCESS_FLAG )
               VALUES
               (
                FND_PROFILE.VALUE('ONT_SOURCE_CODE'),
                l_source_line_id,
                l_transaction_interface_id,
                l_rsv_tbl(I).lot_number,
                (-1 * l_rsv_tbl(I).reservation_quantity),
                (-1 * l_rsv_tbl(I).secondary_reservation_quantity), --  INVCONV
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                null,
                null,
                'Y');

             END IF; -- under lot control


              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'INV IFACE: INSERTING RECORD - 1' , 1 ) ;

                  oe_debug_pub.add(  'SOURCE_CODE :' || FND_PROFILE.VALUE ( 'ONT_SOURCE_CODE' ) , 5 ) ;

                  oe_debug_pub.add(  'SOURCE_LINE_ID :' || L_SOURCE_LINE_ID , 5 ) ;

                  oe_debug_pub.add(  'SOURCE_HEADER_ID :' || L_TRANSACTION_REFERENCE , 5 ) ;

                  oe_debug_pub.add(  'PROCESS_FLAG :' || 1 , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_MODE :' || 1 , 5 ) ;

                  oe_debug_pub.add(  'LOCK_FLAG :' || 2 , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_HEADER_ID :' || L_TRANSACTION_HEADER_ID , 5 ) ;

                  oe_debug_pub.add(  'INVENTORY_ITEM_ID :' || L_LINE_REC.INVENTORY_ITEM_ID , 5 ) ;

                  oe_debug_pub.add(  'SUBINVENTORY_CODE :' || L_RSV_TBL ( I ) .SUBINVENTORY_CODE , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_QUANTITY :' || ( -1 * L_RSV_TBL ( I ) .RESERVATION_QUANTITY ) , 5 ) ;

                  oe_debug_pub.add(  'SECONDARY TRANSACTION_QUANTITY :' || ( -1 * L_RSV_TBL ( I ) .SECONDARY_RESERVATION_QUANTITY ) , 5 ) ; -- INVCONV


                  oe_debug_pub.add(  'TRANSACTION_DATE :' || l_trx_date_for_inv_iface, 5 ) ; --bug5897965

		  -- bug 5897965 oe_debug_pub.add(  'TRANSACTION_DATE :' || l_ordered_date , 5 ) ;

                  oe_debug_pub.add(  'ORGANIZATION_ID :' || L_RSV_TBL ( I ) .ORGANIZATION_ID , 5 ) ;

                  oe_debug_pub.add(  'ACCT_PERIOD_ID :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'LAST_UPDATE_DATE :' || SYSDATE , 5 ) ;

                  oe_debug_pub.add(  'LAST_UPDATED_BY :' || FND_GLOBAL.USER_ID , 5 ) ;

                  oe_debug_pub.add(  'CREATION_DATE :' || SYSDATE , 5 ) ;

                  oe_debug_pub.add(  'CREATED_BY :' || FND_GLOBAL.USER_ID , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_SOURCE_ID :' || L_SALES_ORDER_ID , 5 ) ;

                  oe_debug_pub.add(  'DSP_SEGMENT1 :' || L_ORDER_NUMBER , 5 ) ;

                  oe_debug_pub.add(  'DSP_SEGMENT2 :' || L_ORDER_TYPE_NAME , 5 ) ;

                  oe_debug_pub.add(  'DSP_SEGMENT3 :' || FND_PROFILE.VALUE ( 'ONT_SOURCE_CODE' ) , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_SOURCE_TYPE_ID :' || TO_CHAR ( 2 ) , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_ACTION_ID :' || TO_CHAR ( 1 ) , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_TYPE_ID :' || TO_CHAR ( 33 ) , 5 ) ;

                  oe_debug_pub.add(  'DISTRIBUTION_ACCOUNT_ID :' || L_TRANS_ACC , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_REFERENCE :' || L_TRANSACTION_REFERENCE , 5 ) ;

                  oe_debug_pub.add(  'TRX_SOURCE_LINE_ID :' || L_LINE_REC.LINE_ID , 5 ) ;

                  oe_debug_pub.add(  'TRX_SOURCE_DELIVERY_ID :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'REVISION :' || L_RSV_TBL ( I ) .REVISION , 5 ) ;

                  oe_debug_pub.add(  'LOCATOR_ID :' || L_RSV_TBL ( I ) .LOCATOR_ID , 5 ) ;

                  oe_debug_pub.add(  'LOC_SEGMENT1 :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'LOC_SEGMENT2 :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'LOC_SEGMENT3 :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'LOC_SEGMENT4 :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'REQUIRED_FLAG :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'PICKING_LINE_ID :' || TO_CHAR ( 0 ) , 5 ) ;

                  oe_debug_pub.add(  'TRANSFER_SUBINVENTORY :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'TRANSFER_ORGANIZATION :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'SHIP_TO_LOCATION_ID :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'REQUISITION_LINE_ID :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'TRANSACTION_UOM :' || L_LINE_REC.ORDER_QUANTITY_UOM , 5 ) ;

                  oe_debug_pub.add(  'TRANS INTERFACE_ID :' || L_TRANSACTION_INTERFACE_ID , 5 ) ;

                  oe_debug_pub.add(  'DEMAND_ID :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'SHIPMENT_NUMBER :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'CURRENCY_CODE :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'CURRENCY_CONVERSION_TYPE :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'CURRENCY_CONVERSION_DATE :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'CURRENCY_CONVERSION_RATE :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'ENCUMBRANCE_ACCOUNT :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'ENCUMBRANCE_AMOUNT :' || NULL , 5 ) ;

                  oe_debug_pub.add(  'PROJECT_ID :' || L_LINE_REC.PROJECT_ID , 5 ) ;

                  oe_debug_pub.add(  'TASK_ID :' || L_LINE_REC.TASK_ID , 5 ) ;
              END IF;

              INSERT INTO MTL_TRANSACTIONS_INTERFACE
              (
               SOURCE_CODE,
               SOURCE_LINE_ID,
               SOURCE_HEADER_ID,
               PROCESS_FLAG,
               TRANSACTION_MODE,
               LOCK_FLAG,
               TRANSACTION_HEADER_ID,
               INVENTORY_ITEM_ID,
               SUBINVENTORY_CODE,
               TRANSACTION_QUANTITY,
               SECONDARY_TRANSACTION_QUANTITY, -- INVCONV
               TRANSACTION_DATE,
               ORGANIZATION_ID,
               ACCT_PERIOD_ID,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               TRANSACTION_SOURCE_ID,
               DSP_SEGMENT1,
               DSP_SEGMENT2,
               DSP_SEGMENT3,
               TRANSACTION_SOURCE_TYPE_ID,
               TRANSACTION_ACTION_ID,
               TRANSACTION_TYPE_ID,
               DISTRIBUTION_ACCOUNT_ID,
               DST_SEGMENT1,
               DST_SEGMENT2,
               DST_SEGMENT3,
               DST_SEGMENT4,
               DST_SEGMENT5,
               DST_SEGMENT6,
               DST_SEGMENT7,
               DST_SEGMENT8,
               DST_SEGMENT9,
               DST_SEGMENT10,
               DST_SEGMENT11,
               DST_SEGMENT12,
               DST_SEGMENT13,
               DST_SEGMENT14,
               DST_SEGMENT15,
               DST_SEGMENT16,
               DST_SEGMENT17,
               DST_SEGMENT18,
               DST_SEGMENT19,
               DST_SEGMENT20,
               DST_SEGMENT21,
               DST_SEGMENT22,
               DST_SEGMENT23,
               DST_SEGMENT24,
               DST_SEGMENT25,
               DST_SEGMENT26,
               DST_SEGMENT27,
               DST_SEGMENT28,
               DST_SEGMENT29,
               DST_SEGMENT30,
               TRANSACTION_REFERENCE,
               TRX_SOURCE_LINE_ID,
               TRX_SOURCE_DELIVERY_ID,
               REVISION,
               LOCATOR_ID,
               LOC_SEGMENT1,
               LOC_SEGMENT2,
               LOC_SEGMENT3,
               LOC_SEGMENT4,
               REQUIRED_FLAG,
               PICKING_LINE_ID,
               TRANSFER_SUBINVENTORY,
               TRANSFER_ORGANIZATION,
               SHIP_TO_LOCATION_ID,
               REQUISITION_LINE_ID,
               TRANSACTION_UOM,
               TRANSACTION_INTERFACE_ID,
               DEMAND_ID,
               SHIPMENT_NUMBER,
               CURRENCY_CODE,
               CURRENCY_CONVERSION_TYPE,
               CURRENCY_CONVERSION_DATE,
               CURRENCY_CONVERSION_RATE,
               ENCUMBRANCE_ACCOUNT,
               ENCUMBRANCE_AMOUNT,
	       --CONTENT_LPN_ID,   -- added for bug 6313351
	       LPN_ID, --added for bug 8658984
               PROJECT_ID,
               TASK_ID)
           SELECT
               profile_values.oe_source_code,
               l_source_line_id,
               l_transaction_reference,
               1,       /* PROCESS_FLAG 	*/
               3,       /* TRANSACTION_MODE */
               2,       /* LOCK_FLAG  */
               l_transaction_header_id,
               l_line_rec.inventory_item_id,
               l_rsv_tbl(I).subinventory_code,
               (-1 * l_rsv_tbl(I).reservation_quantity),
               (-1 * l_rsv_tbl(I).secondary_reservation_quantity), -- INVCONV
               l_trx_date_for_inv_iface/*l_ordered_date*/, --bug5897965 l_ordered_date commented
               l_rsv_tbl(I).organization_id,
               null,
               sysdate,
               profile_values.user_id,
               sysdate,
               profile_values.user_id,
               l_sales_order_id, /* transaction_source_id */
               l_order_number,
               l_order_type_name,
               profile_values.oe_source_code,
               2,
               1,
               33,
               l_trans_acc,
               segment1,
               segment2,
               segment3,
               segment4,
               segment5,
               segment6,
               segment7,
               segment8,
               segment9,
               segment10,
               segment11,
               segment12,
               segment13,
               segment14,
               segment15,
               segment16,
               segment17,
               segment18,
               segment19,
               segment20,
               segment21,
               segment22,
               segment23,
               segment24,
               segment25,
               segment26,
               segment27,
               segment28,
               segment29,
               segment30,
               l_transaction_reference,
               l_line_rec.line_id,
               null,
               l_rsv_tbl(I).revision,
               l_rsv_tbl(I).locator_id,
               null,
               null,
               null,
               null,
               null,
               null, /* l_shipment_line_id */
               null, /* l_dest_subinv */
               null, /* l_to_org_id */
               null, /* l_location_id */
               null, /* l_req_line_id */
               l_line_rec.order_quantity_uom,
               l_transaction_interface_id, /* interface_id */
               null,
               null,
               null,
               null,
               null,
               null,
               null, /* l_budget_acct_id */
               null, /* l_unit_price * p_transaction_detail_qty */
	       l_rsv_tbl(I).lpn_id,   -- added for bug 6313351
               l_line_rec.project_id,
               l_line_rec.task_id
           FROM gl_code_combinations
           WHERE code_combination_id = l_trans_acc;

           SELECT mtl_material_transactions_s.nextval
           INTO   l_transaction_interface_id
           FROM   dual;
           -- for use when looping or used by the second
           -- insert into mtl_transactions_interface
           -- interface_id need to be unique for each interface record


 /* -- HW OPM end of BUG#:2536589     INVCONV
           END IF; --- if discete org  */

         END LOOP;

    END IF; -- with a reservation record

    IF l_line_rec.reserved_quantity = 0 OR l_remained_qty > 0 THEN

        -- line with no reservation record or
    -- line is with partial reservation

          -- check if subinventory exists on the line
          -- if not error out
          -- check if item is under lot/locator/revision control
          -- if so error out


/* check if subinventory exists on line */
/* -- HW OPM BUG#:2536589 No need to check subinventory for OPM               INVCONV
-- we need to branch.

        IF (l_process_org = 0 )THEN   */

          IF ( l_line_rec.subinventory is null or
               l_line_rec.subinventory = FND_API.G_MISS_CHAR )  THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'INV IFACE: SUBINV IS NULL OR MISS_CHAR FOR INSERT - 2' , 5 ) ;
                  END IF;
                  -- Give a message here
                  FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_SUB');
-- message should say if item is under revision/lot/locator control, use the
-- reservation form to reserve first
                  OE_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                  ROLLBACK TO INVENTORY_INTERFACE;
                  RETURN;
          END IF;

/* handle locator */

            BEGIN
              SELECT stock_locator_control_code
              INTO   l_stock_locator_control_code
              FROM   mtl_parameters
              WHERE  organization_id = l_line_rec.ship_from_org_id;
            EXCEPTION
              WHEN OTHERS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'INV IFACE: LOCATOR CONTROL CODE SELECT FAILURE' , 5 ) ;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                ROLLBACK TO INVENTORY_INTERFACE;
                RETURN;
            END;

            BEGIN
              SELECT locator_type
              INTO   l_locator_type
              FROM   mtl_secondary_inventories
              WHERE  secondary_inventory_name = l_line_rec.subinventory
              AND    organization_id = l_line_rec.ship_from_org_id;

            EXCEPTION
              WHEN OTHERS THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'INV IFACE: LOCATOR TYPE SELECT FAILURE' , 5 ) ;
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                  ROLLBACK TO INVENTORY_INTERFACE;
                  RETURN;
            END;


          BEGIN
          SELECT location_control_code
          INTO   l_location_control_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = l_line_rec.inventory_item_id
          AND    organization_id = l_line_rec.ship_from_org_id;
              -- ???? warehouse or validation org?
          EXCEPTION
              WHEN OTHERS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'INV IFACE: LOCATION CONTROL CODE FAILURE' , 5 ) ;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
                ROLLBACK TO INVENTORY_INTERFACE;
                RETURN;
          END;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV IFACE: BEFORE LOCATOR_CONTROL API CALL' , 1 ) ;
          END IF;

          l_locator := INV_RESERVATION_UTIL_PVT.locator_control(
                         p_org_control => l_stock_locator_control_code
                        ,p_sub_control => l_locator_type
                        ,p_item_control => l_location_control_code);
                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'INV IFACE: AFTER LOCATOR_CONTROL API CALL - ' || TO_CHAR ( L_LOCATOR ) , 1 ) ;
                                       END IF;

       --    END IF; -- of branching HW OPM BUG#:2536589   INVCONV

        IF (l_revision_code = 2 OR l_lot_code = 2 OR nvl(l_serial_code, 1) <> 1 OR
             l_locator > 1 )THEN
             -- 2 == YES
              IF nvl(l_serial_code, 1) <> 1 THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'INV IFACE: ITEM UNDER SERIAL CONTORL , ERROR' , 5 ) ;
                    END IF;
                    -- give a message here
                    FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_SERIAL');
                    OE_MSG_PUB.ADD;
              ELSE
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'INV IFACE: ITEM UNDER REVISION/LOT/LOCATOR CONTROL AND NO RESERVATION EXISTS' , 5 ) ;
                    END IF;
                    -- Give a message here
                    FND_MESSAGE.SET_NAME('ONT', 'OE_INV_IFACE_NO_RSV');
                    OE_MSG_PUB.ADD;
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
              ROLLBACK TO INVENTORY_INTERFACE;
              RETURN;

          END IF;

/*   -- HW OPm BUG#:2536589 Need to check for non-lot,non-inv OPM items.   INVCONV
        IF ( l_process_org = 1 AND l_lot = 'N' )  THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV IFACE: NO DEFAULT TRXN EXISTS FOR NON-LOT , NON-INV OPM ITEM' , 5 ) ;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_result_out := OE_GLOBALS.G_WFR_INCOMPLETE;
          ROLLBACK TO INVENTORY_INTERFACE;
          RETURN;
        END IF;    */

 /* -- HW OPM BUG#:2536589 Need to branch since OPM does not need to populate     INVCONV
-- mtl_transactions_interface table
   IF ( l_process_org = 0 ) THEN   */
    SELECT oe_transactions_iface_s.nextval
    INTO l_source_line_id
    FROM dual;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INV IFACE: INSERTING RECORD - 2' , 5 ) ;

      oe_debug_pub.add(  'SOURCE_CODE :' || FND_PROFILE.VALUE ( 'ONT_SOURCE_CODE' ) , 5 ) ;

      oe_debug_pub.add(  'SOURCE_LINE_ID :' || L_SOURCE_LINE_ID , 5 ) ;

      oe_debug_pub.add(  'SOURCE_HEADER_ID :' || L_TRANSACTION_REFERENCE , 5 ) ;

      oe_debug_pub.add(  'PROCESS_FLAG :' || 1 , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_MODE :' || 1 , 5 ) ;

      oe_debug_pub.add(  'LOCK_FLAG :' || 2 , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_HEADER_ID :' || L_TRANSACTION_HEADER_ID , 5 ) ;

      oe_debug_pub.add(  'INVENTORY_ITEM_ID :' || L_LINE_REC.INVENTORY_ITEM_ID , 5 ) ;

      oe_debug_pub.add(  'SUBINVENTORY_CODE :' || L_LINE_REC.SUBINVENTORY , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_QUANTITY :' || ( -1 * L_LINE_REC.ORDERED_QUANTITY ) || ' OR ' || ( -1 * L_REMAINED_QTY ) , 5 ) ;


-- (-1 * decode(reservation_flag, 'Y', l_remained_qty, l_line_rec.ordered_quantity)),1);


      -- bug 5897965 oe_debug_pub.add(  'TRANSACTION_DATE :' || l_ordered_date , 5 ) ;

       oe_debug_pub.add(  'TRANSACTION_DATE :' || l_trx_date_for_inv_iface , 5 ) ; --bug5897965

      oe_debug_pub.add(  'ORGANIZATION_ID :' || L_LINE_REC.SHIP_FROM_ORG_ID , 5 ) ;

      oe_debug_pub.add(  'ACCT_PERIOD_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'LAST_UPDATE_DATE :' || SYSDATE , 5 ) ;

      oe_debug_pub.add(  'LAST_UPDATED_BY :' || FND_GLOBAL.USER_ID , 5 ) ;

      oe_debug_pub.add(  'CREATION_DATE :' || SYSDATE , 5 ) ;

      oe_debug_pub.add(  'CREATED_BY :' || FND_GLOBAL.USER_ID , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_SOURCE_ID :' || L_SALES_ORDER_ID , 5 ) ;

      oe_debug_pub.add(  'DSP_SEGMENT1 :' || L_ORDER_NUMBER , 5 ) ;

      oe_debug_pub.add(  'DSP_SEGMENT2 :' || L_ORDER_TYPE_NAME , 5 ) ;

      oe_debug_pub.add(  'DSP_SEGMENT3 :' || FND_PROFILE.VALUE ( 'ONT_SOURCE_CODE' ) , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_SOURCE_TYPE_ID :' || TO_CHAR ( 2 ) , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_ACTION_ID :' || TO_CHAR ( 1 ) , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_TYPE_ID :' || TO_CHAR ( 33 ) , 5 ) ;

      oe_debug_pub.add(  'DISTRIBUTION_ACCOUNT_ID :' || L_TRANS_ACC , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_REFERENCE :' || L_TRANSACTION_REFERENCE , 5 ) ;

      oe_debug_pub.add(  'TRX_SOURCE_LINE_ID :' || L_LINE_REC.LINE_ID , 5 ) ;

      oe_debug_pub.add(  'TRX_SOURCE_DELIVERY_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'REVISION :' || NULL , 5 ) ;

      oe_debug_pub.add(  'LOCATOR_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'LOC_SEGMENT1 :' || NULL , 5 ) ;

      oe_debug_pub.add(  'LOC_SEGMENT2 :' || NULL , 5 ) ;

      oe_debug_pub.add(  'LOC_SEGMENT3 :' || NULL , 5 ) ;

      oe_debug_pub.add(  'LOC_SEGMENT4 :' || NULL , 5 ) ;

      oe_debug_pub.add(  'REQUIRED_FLAG :' || NULL , 5 ) ;

      oe_debug_pub.add(  'PICKING_LINE_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'TRANSFER_SUBINVENTORY :' || NULL , 5 ) ;

      oe_debug_pub.add(  'TRANSFER_ORGANIZATION :' || NULL , 5 ) ;

      oe_debug_pub.add(  'SHIP_TO_LOCATION_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'REQUISITION_LINE_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'TRANSACTION_UOM :' || L_LINE_REC.ORDER_QUANTITY_UOM , 5 ) ;

      oe_debug_pub.add(  'TRANS INTERFACE_ID :' || L_TRANSACTION_INTERFACE_ID , 5 ) ;

      oe_debug_pub.add(  'DEMAND_ID :' || NULL , 5 ) ;

      oe_debug_pub.add(  'SHIPMENT_NUMBER :' || NULL , 5 ) ;

      oe_debug_pub.add(  'CURRENCY_CODE :' || NULL , 5 ) ;

      oe_debug_pub.add(  'CURRENCY_CONVERSION_TYPE :' || NULL , 5 ) ;

      oe_debug_pub.add(  'CURRENCY_CONVERSION_DATE :' || NULL , 5 ) ;

      oe_debug_pub.add(  'CURRENCY_CONVERSION_RATE :' || NULL , 5 ) ;

      oe_debug_pub.add(  'ENCUMBRANCE_ACCOUNT :' || NULL , 5 ) ;

      oe_debug_pub.add(  'ENCUMBRANCE_AMOUNT :' || NULL , 5 ) ;

      oe_debug_pub.add(  'PROJECT_ID :' || L_LINE_REC.PROJECT_ID , 5 ) ;

      oe_debug_pub.add(  'TASK_ID :' || L_LINE_REC.TASK_ID , 5 ) ;
  END IF;

  INSERT INTO MTL_TRANSACTIONS_INTERFACE
        (
         SOURCE_CODE,
         SOURCE_LINE_ID,
         SOURCE_HEADER_ID,
         PROCESS_FLAG,
         TRANSACTION_MODE,
         LOCK_FLAG,
         TRANSACTION_HEADER_ID,
         INVENTORY_ITEM_ID,
         SUBINVENTORY_CODE,
         TRANSACTION_QUANTITY,
         SECONDARY_TRANSACTION_QUANTITY, -- INVCONV
         TRANSACTION_DATE,
         ORGANIZATION_ID,
         ACCT_PERIOD_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         TRANSACTION_SOURCE_ID,
         DSP_SEGMENT1,
         DSP_SEGMENT2,
         DSP_SEGMENT3,
         TRANSACTION_SOURCE_TYPE_ID,
         TRANSACTION_ACTION_ID,
         TRANSACTION_TYPE_ID,
         DISTRIBUTION_ACCOUNT_ID,
         DST_SEGMENT1,
         DST_SEGMENT2,
         DST_SEGMENT3,
         DST_SEGMENT4,
         DST_SEGMENT5,
         DST_SEGMENT6,
         DST_SEGMENT7,
         DST_SEGMENT8,
         DST_SEGMENT9,
         DST_SEGMENT10,
         DST_SEGMENT11,
         DST_SEGMENT12,
         DST_SEGMENT13,
         DST_SEGMENT14,
         DST_SEGMENT15,
         DST_SEGMENT16,
         DST_SEGMENT17,
         DST_SEGMENT18,
         DST_SEGMENT19,
         DST_SEGMENT20,
         DST_SEGMENT21,
         DST_SEGMENT22,
         DST_SEGMENT23,
         DST_SEGMENT24,
         DST_SEGMENT25,
         DST_SEGMENT26,
         DST_SEGMENT27,
         DST_SEGMENT28,
         DST_SEGMENT29,
         DST_SEGMENT30,
         TRANSACTION_REFERENCE,
         TRX_SOURCE_LINE_ID,
         TRX_SOURCE_DELIVERY_ID,
         REVISION,
         LOCATOR_ID,
         LOC_SEGMENT1,
         LOC_SEGMENT2,
         LOC_SEGMENT3,
         LOC_SEGMENT4,
         REQUIRED_FLAG,
         PICKING_LINE_ID,
         TRANSFER_SUBINVENTORY,
         TRANSFER_ORGANIZATION,
         SHIP_TO_LOCATION_ID,
         REQUISITION_LINE_ID,
         TRANSACTION_UOM,
         TRANSACTION_INTERFACE_ID,
         DEMAND_ID,
         SHIPMENT_NUMBER,
         CURRENCY_CODE,
         CURRENCY_CONVERSION_TYPE,
         CURRENCY_CONVERSION_DATE,
         CURRENCY_CONVERSION_RATE,
         ENCUMBRANCE_ACCOUNT,
         ENCUMBRANCE_AMOUNT,
         PROJECT_ID,
         TASK_ID)
         SELECT
         profile_values.oe_source_code,
         l_source_line_id,
         l_transaction_reference,
         1,       /* PROCESS_FLAG 	*/
         3,       /* TRANSACTION_MODE */
         2,       /* LOCK_FLAG  */
         l_transaction_header_id,
         l_line_rec.inventory_item_id,
         l_line_rec.subinventory,
         (-1 * decode(reservation_flag, 'Y', l_remained_qty, l_line_rec.ordered_quantity)),
         (-1 * decode(reservation_flag, 'Y', l_remained_qty2, l_line_rec.ordered_quantity2)), -- INVCONV
         l_trx_date_for_inv_iface/*l_ordered_date*/,  --bug5897965 l_ordered_date commented
         l_line_rec.ship_from_org_id,
         null,
         sysdate,
         profile_values.user_id,
         sysdate,
         profile_values.user_id,
         l_sales_order_id, /* transaction_source_id */
         l_order_number,
         l_order_type_name,
         profile_values.oe_source_code,
         2, /* l_trx_source_type_id */
         1, /* l_trx_action_id */
         33, /* l_trx_type_code */
         l_trans_acc,
         segment1,
         segment2,
         segment3,
         segment4,
         segment5,
         segment6,
         segment7,
         segment8,
         segment9,
         segment10,
         segment11,
         segment12,
         segment13,
         segment14,
         segment15,
         segment16,
         segment17,
         segment18,
         segment19,
         segment20,
         segment21,
         segment22,
         segment23,
         segment24,
         segment25,
         segment26,
         segment27,
         segment28,
         segment29,
         segment30,
         l_transaction_reference,
         l_line_rec.line_id,
         null,
         null, /* revision */
         null, /* locator */
         null,
         null,
         null,
         null,
         null,
         null, /* l_shipment_line_id */
         null, /* l_dest_subinv */
         null, /* l_to_org_id */
         null, /* l_location_id */
         null, /* l_req_line_id */
         l_line_rec.order_quantity_uom,
	 l_transaction_interface_id,
         null,
         null,
         null,
         null,
         null,
         null,
         null, /* l_budget_acct_id */
         null, /* l_unit_price * p_transaction_detail_qty */
         l_line_rec.project_id,
         l_line_rec.task_id
  FROM gl_code_combinations
  WHERE code_combination_id = l_trans_acc;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INV IFACE: FINISH INSERTING - 2 , CALLING UPDATE_FLOW_STATUS_CODE' , 1 ) ;
  END IF;

/* -- HW OPM BUG#:2536589       -- INVCONV
   END IF; -- of branching    */

  END IF;
  /* of partial reservation or no reservation line */

  /* update flow_status_code */
  OE_ORDER_WF_UTIL.Update_Flow_Status_Code(p_line_id => p_line_id
                             , p_flow_status_code => 'INVENTORY_INTERFACED'
                             , x_return_status => l_return_status);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INV IFACE: UPDATE FLOW STATUS CODE FAILED' , 5 ) ;
         END IF;
  END IF;

 END IF; -- If line is shippable

 -- do PTO explosion if necessary
 -- since we are not going to ship this line, SMC is unimportant here
 -- and as long as explosion_date is null, we explode it
 IF (l_line_rec.explosion_date     IS NULL        AND
     l_line_rec.top_model_line_id  IS NOT NULL    AND
     l_line_rec.ato_line_id        IS NULL)        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV IFACE: IT IS A PTO LINE WITHOUT EXPLOSION DATE' , 3 ) ;
          END IF;
          IF   l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
               l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
               l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'INV IFACE: IT IS ITEM TYPE : '|| L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
                    END IF;
                    -- Do the explosion
                    l_return_status := OE_Config_Util.Process_Included_Items(
                                                       p_line_id => l_line_rec.line_id
                                                      ,p_freeze  => TRUE
                                                      ,p_process_requests => TRUE);
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'INV IFACE: AFTER CALLING EXPLOSION : '|| L_RETURN_STATUS , 3 ) ;
                    END IF;
                    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'INV IFACE: FREEZE INCLUDED ITEM FAILED - UNEXP' , 1 ) ;
                       END IF;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'INV IFACE: FREEZE INCLUDED ITEM FAILED - EXP' , 1 ) ;
                       END IF;
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
          END IF;
 END IF;

/* bug 4659103: update of visible_demand_flag code removed */

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'INV IFACE: EXITING INVENTORY_INTERFACE' , 1 ) ;
 END IF;

EXCEPTION
	WHEN OTHERS THEN
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Interface'
            );
           END IF;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INV IFACE ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Inventory_Interface;

END OE_Inv_Iface_PVT;

/

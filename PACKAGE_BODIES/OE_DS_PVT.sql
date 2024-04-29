--------------------------------------------------------
--  DDL for Package Body OE_DS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DS_PVT" AS
/* $Header: OEXVDSRB.pls 120.15.12010000.3 2009/01/12 08:30:28 spothula ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_DS_PVT';
G_LINE_LOCATION_ID     NUMBER := NULL; --bug 4402566

FUNCTION Get_Char_of_accts (p_ship_from_org_id IN NUMBER) RETURN NUMBER;


PROCEDURE Decrement_Inventory(
             p_detail_id              IN  NUMBER,
             p_line_rec               IN  OE_ORDER_PUB.line_rec_type,
             p_transaction_id         IN  NUMBER,
             p_transaction_detail_qty IN  NUMBER,
             p_trans_qty2 IN  NUMBER, -- INVCONV
             p_inventory_item_id      IN  NUMBER,
             p_delivery               IN  NUMBER,
             p_lot_number             IN  VARCHAR2,
             p_revision               IN  VARCHAR2,
             p_secondary_inventory    IN  VARCHAR2,
             p_locator_id             IN  NUMBER,
             p_warehouse_id           IN  NUMBER,
             p_chart_of_accts         IN  NUMBER,
             p_trx_uom                IN  VARCHAR2,
	     p_sn_control_code        IN  NUMBER,
	     p_as_alpha_prefix        IN  VARCHAR2,
	     p_transaction_header_id  IN  NUMBER,
	     p_transfer_lpn_id	      IN  NUMBER, -- 3544019
x_return_status OUT NOCOPY VARCHAR2);


/* Procedure Decrement_Inventory_for_OPM( remove for INVCONV
             p_detail_id              IN  NUMBER,
             p_line_rec               IN  OE_ORDER_PUB.line_rec_type,
             p_transaction_id         IN  NUMBER,
             p_trans_qty              IN  NUMBER,
             p_trans_qty2             IN  NUMBER,
             p_inventory_item_id      IN  NUMBER,
             p_delivery               IN  NUMBER,
             p_lot_number             IN  VARCHAR2,
             p_sublot_no              IN  VARCHAR2,
             p_revision               IN  VARCHAR2,
             p_locator_id             IN  NUMBER,
             p_warehouse_id           IN  NUMBER,
             p_chart_of_accts         IN  NUMBER,
             p_trx_uom                IN  VARCHAR2,
             p_sn_control_code        IN  NUMBER,
             p_as_alpha_prefix        IN  VARCHAR2,
             p_transaction_header_id  IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2);  */


PROCEDURE Call_Process_Order
(p_orig_shipped           IN      NUMBER
,p_short_quantity         IN      NUMBER
,p_transaction_date       IN      DATE
,p_add_to_shipped         IN      NUMBER
,p_add_to_shipped2        IN      NUMBER
,p_line_rec               IN      OE_ORDER_PUB.Line_rec_Type
,x_return_status          OUT     NOCOPY VARCHAR2
);

PROCEDURE Create_reservation
(p_qty_to_be_reserved  IN      NUMBER
,p_qty2_to_be_reserved  IN      NUMBER default null -- INVCONV
,p_revision            IN      VARCHAR2
,p_locator_id          IN      NUMBER
,p_lot                 IN      VARCHAR2
,p_line_rec            IN      OE_ORDER_PUB.Line_Rec_Type
,x_qty_reserved        OUT     NOCOPY NUMBER
,x_qty2_reserved        OUT     NOCOPY NUMBER
,x_rsv_id              OUT     NOCOPY NUMBER
,x_return_status       OUT     NOCOPY VARCHAR2
,p_transfer_lpn_id     IN      NUMBER
);


/* --------------------------------------------------------------------
Procedure Name : DropShipment Receiving
Description    : This callback function is called from PO receiving function
                 for non-inventory items and INV for inventory items.
                 Fetch the record from RCV_TRANSACTIONS.
                 If there are records in RCV_LOT_TRANSACTIONS, fetch them
                 in a loop.
                 For each record in RCV_LOT_TRANSACTIONS (or for the one
                 record in RCV_TRANSACTIONS):
                 1. If the application is INV, call decrement inventory
                 2. Compute the quantity shipped.

                 If the application is INV, call
                 mtl_online_transaction_pub.process_online to decrement
                 inventory.

                 Call process order with the shipped quantity update.


----------------------------------------------------------------------- */

FUNCTION DropShipReceive( p_rcv_transaction_id      IN  NUMBER,
                          p_application_short_name  IN  VARCHAR2,
                          p_mode                    IN  NUMBER DEFAULT 0)

RETURN BOOLEAN
IS
  l_line_id                 NUMBER;
  l_line_rec                OE_ORDER_PUB.line_rec_type;
  l_transaction_id          NUMBER := p_rcv_transaction_id;
  l_application_short_name  VARCHAR2(3);
  l_pr_complete             NUMBER; /* Purchase Release complete */
  l_ordered_quantity        NUMBER := 0;
  l_qty_to_be_reserved      NUMBER := 0;
  l_cancelled_quantity      NUMBER := 0;
  l_shipped_quantity        NUMBER := 0;
  l_orig_short_quantity     NUMBER := 0;
  l_rcv_quantity            NUMBER := 0;
  l_lot_quantity            NUMBER := -1;
  l_short_quantity          NUMBER := 0;
  l_add_to_shipped          NUMBER := 0;
  l_unit_descr              VARCHAR2(25);
  l_order_uom               VARCHAR2(3);
  l_rcv_uom                 VARCHAR2(3);
  l_converted_qty           NUMBER;
  l_lot                     VARCHAR2(80) := null; -- INVCONV 4094197
  l_subinventory            VARCHAR2(10) := null;
  l_revision                VARCHAR2(3) := null;
  l_transactable            VARCHAR2(1);
  l_sub_reservable          NUMBER := 1;
  l_item_reservable         NUMBER := 1;
  l_organization_id         NUMBER;
  l_item_id                 NUMBER;
  l_locator_id              NUMBER := 0;
  l_delivery                NUMBER;
  l_sn_control_code         NUMBER;
  l_as_alpha_prefix         VARCHAR2(30);
  l_transaction_date        DATE;
  l_orig_shipped            NUMBER;  /* Bug 2312461 */

  l_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
  l_quantity_reserved       NUMBER;
  l_qty_to_reserve          NUMBER;
  l_rsv_id                  NUMBER := 0;
  l_sales_order_id          NUMBER;
  l_return_status           VARCHAR2(1);
  l_source_code             VARCHAR2(40) := fnd_profile.value('ONT_SOURCE_CODE');
  l_chart_of_accts          NUMBER;

  l_lot_set_id   NUMBER := null;

  -- For INV's process online API
  l_outcome                 BOOLEAN;
  l_error_code              VARCHAR2(10);
  l_error_explanation       VARCHAR2(100);

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(20000);


  -- temporary variable for debugging.
  l_database                  VARCHAR2(9);
  l_file_val                  VARCHAR2(80);

  -- PROCESS variables INVCONV
  l_orig_short_quantity2    NUMBER := 0;
  l_short_quantity2         NUMBER := 0;
  l_uom2                    VARCHAR2(3);
  l_add_to_shipped2         NUMBER := 0;
  l_rcv_quantity2           NUMBER := 0;
  l_lot_quantity2           NUMBER := 0;
  l_reserve_quantity2       NUMBER := 0;
  l_unit2                   VARCHAR2(25);
  l_quantity2_reserved       NUMBER; -- INVCONV
  l_qty2_to_be_reserved      NUMBER := 0; -- INVCONV
--  l_sublot_no               VARCHAR2(30); INVCONV
-- l_opm_order_uom           VARCHAR2(5);  INVCONV
--  l_opm_rcv_uom             VARCHAR2(5);  INVCONV
--  l_opm_item_id             NUMBER;         INVCONV
  l_orig_user_id            NUMBER;
  l_orig_resp_id            NUMBER;
  l_resp_appl_id            NUMBER;
  l_po_header_id            NUMBER; -- bug 4402566

  l_so_ou_id                NUMBER;
  l_po_ou_id                NUMBER;

  l_transfer_lpn_id	    NUMBER;	-- BUG 3544019



  -- Bug2407918. If more than one order lines are found because of multiple under-receipts, order
  --             them here, so that first row fetched corresponds to the most recently created line.
  CURSOR C1 IS
       SELECT OL.LINE_ID,
              RT.TRANSACTION_DATE,
              OL.ORG_ID,           -- bug 4402566
              OD.LINE_LOCATION_ID, -- bug 4402566
              RT.PO_HEADER_ID,     -- bug 4402566
              nvl(OL.SHIPPED_QUANTITY,0) shp_qty
       FROM   OE_ORDER_LINES_ALL     OL,
              OE_DROP_SHIP_SOURCES   OD,
              RCV_TRANSACTIONS       RT
       WHERE  OL.LINE_ID = OD.LINE_ID
       AND    OL.SOURCE_TYPE_CODE = 'EXTERNAL'
       AND    OD.PO_HEADER_ID = RT.PO_HEADER_ID
       AND    OD.PO_LINE_ID = RT.PO_LINE_ID
       AND    OL.OPEN_FLAG = 'Y'                --added for bug 7614745
       AND    OL.FLOW_STATUS_CODE = 'AWAITING_RECEIPT'
       AND    OD.LINE_LOCATION_ID = RT.PO_LINE_LOCATION_ID
       AND    RT.TRANSACTION_ID = l_transaction_id
       ORDER BY 1 desc;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  -- MOAC
  l_access_mode            VARCHAR2(1);
  l_current_org_id         NUMBER;
  l_reset_policy           BOOLEAN;
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*** Entering Dropshipreceive() in OE_DS_PVT *** ' , 1 ) ;
         oe_debug_pub.add('Proces Online Mode:'||p_mode , 1 ) ;
         oe_debug_pub.add('Transaction ID :' || P_RCV_TRANSACTION_ID , 1 ) ;
         oe_debug_pub.add('Application Short Name :' || P_APPLICATION_SHORT_NAME , 1 ) ;
     END IF;

     l_access_mode := mo_global.Get_access_mode(); -- MOAC
     l_current_org_id := mo_global.get_current_org_id();

     -- Fetch sales order line identifier. If selection fail, it means
     -- this receiving transaction is not DropShipment associated.
     -- Return success if selection fail.
     BEGIN
          --{ Bug2407918. run the loop only once.
          FOR i IN C1 LOOP
              l_line_id := i.line_id;
              G_LINE_LOCATION_ID := i.line_location_id; --bug 4402566
              l_po_header_id := i.po_header_id;         --bug 4402566
              l_so_ou_id := i.org_id;                   --bug 4402566
              l_transaction_date := i.transaction_date;
              l_orig_shipped := i.shp_qty;
              EXIT;
          END LOOP;

          IF l_line_id IS NULL THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'Unable to find the sales order identifier for this transaction '||sqlerrm , 1 ) ;
              END IF;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'Dropshipreceive(), This may not be a dropship transaction ' , 1 ) ;
              END IF;
              RETURN TRUE;
          END IF;
          -- Bug 2407918}

          -- bug 4393738 , moved query_row here to set the msg_context info
          OE_Line_Util.Query_Row(p_line_id => l_line_id, x_line_rec => l_line_rec);
          OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'LINE'
          ,p_entity_id                  => l_line_rec.line_id
          ,p_header_id                  => l_line_rec.header_id
          ,p_line_id                    => l_line_rec.line_id
          ,p_order_source_id            => l_line_rec.order_source_id
          ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
          ,p_change_sequence            => l_line_rec.change_sequence
          ,p_source_document_type_id    => l_line_rec.source_document_type_id
          ,p_source_document_id         => l_line_rec.source_document_id
          ,p_source_document_line_id    => l_line_rec.source_document_line_id
          );

     EXCEPTION
          WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('OE','OE_VAL_ORDER_CREDIT');
               OE_MSG_PUB.Add;
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'Unable to find the sales order identifier in dropshipreceive()'||sqlerrm , 1 ) ;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

     ---------------------------------------
     -- Changes for Enhanced Drop Shipments
     ---------------------------------------

     -- Set the Context only for Enhanced Drop Ships.
     /*
      SELECT org_id
       INTO l_so_ou_id
       FROM oe_order_lines_all
      WHERE line_id = l_line_id;


     SELECT  pol.org_id
       INTO  l_po_ou_id
       FROM  po_lines_all pol,
             oe_drop_ship_sources ds
      WHERE  ds.line_id      = l_line_id
        AND  ds.po_header_id = pol.po_header_id
        AND  ds.po_line_id   = pol.po_line_id;
     */
     --  commented for bug 4402566 and the sql below was added
     SELECT poh.org_id
     INTO l_po_ou_id
     FROM po_headers_all poh
     WHERE poh.po_header_id = l_po_header_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('SO Org Id: ' ||l_so_ou_id , 1 ) ;
         oe_debug_pub.add('PO Org Id: ' ||l_po_ou_id , 1 ) ;
     END IF;

     IF  l_po_ou_id <> l_so_ou_id THEN
       -- MOAC
       Mo_Global.Set_Policy_Context (p_access_mode =>'S', p_org_id => l_so_ou_id);
       l_reset_policy := TRUE;
     ELSE
       IF nvl(l_current_org_id,-99) <> l_so_ou_id THEN
         Mo_Global.Set_Policy_Context (p_access_mode => 'S', p_org_id => l_so_ou_id);
         l_reset_policy := TRUE;
       END IF;

    /* Commented for MOAC
         OE_ORDER_CONTEXT_GRP.Set_Created_By_Context
                            (p_header_id          =>       NULL
                            ,p_line_id            =>       l_line_id
                            ,x_orig_user_id       =>       l_orig_user_id
                            ,x_orig_resp_id       =>       l_orig_resp_id
                            ,x_orig_resp_appl_id  =>       l_resp_appl_id
                            ,x_return_status      =>       l_return_status
                            ,x_msg_count          =>       l_msg_count
                            ,x_msg_data           =>       l_msg_data
                            ); */
     END IF;


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Transaction date : ' ||l_transaction_date , 1 ) ;
         oe_debug_pub.add('Line ID : '||l_line_id||' already received qty => '||TO_CHAR ( l_orig_shipped) , 1 ) ;
     END IF;

     l_order_uom := l_line_rec.order_quantity_uom;
     l_orig_short_quantity := nvl(l_line_rec.ordered_quantity,0) - nvl(l_line_rec.shipped_quantity,0);

     /* OPM changes */
     l_uom2       := l_line_rec.ordered_quantity_uom2;
     l_orig_short_quantity2 := nvl(l_line_rec.ordered_quantity2,0)
                     - nvl(l_line_rec.shipped_quantity2,0);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Open quantity in the sales order => ' || L_ORIG_SHORT_QUANTITY , 1 ) ;
     END IF;
     l_short_quantity := l_orig_short_quantity;
     l_short_quantity2      := l_orig_short_quantity2;

     /*
     ** Fetch receiving transaction information: lot number, item revision
     ** subinventory, receiving quantity and transactable flag.
     */
     /* Bug2197831:Added a decode statement to check the revision of
        item-REVISION_QTY_CONTROL_CODE in MTL_SYSTEM_ITEMS and pass the
        value of the revision or NULL accordingly.
     */
     BEGIN

	    SELECT rt.quantity,
		   rt.unit_of_measure,
                   rt.uom_code,
                   rt.secondary_quantity,                  -- OPM
		   rt.secondary_unit_of_measure,           -- OPM
		   rt.organization_id,
		   rt.subinventory,
		   NVL(msinv.reservable_type, 2),
		   rt.locator_id,
		   rs.item_id,
                   decode(mi.revision_qty_control_code,2,rs.item_revision,NULL),
		   mi.mtl_transactions_enabled_flag,
		   mi.serial_number_control_code,
		   mi.auto_serial_alpha_prefix,
		   rt.transfer_lpn_id		--bug 3544019
	    INTO   l_rcv_quantity,
		   l_unit_descr,
                   l_rcv_uom,
                   l_rcv_quantity2,                     -- OPM
		   l_unit2,                             -- OPM
		   l_organization_id,
		   l_subinventory,
		   l_sub_reservable,
		   l_locator_id,
		   l_item_id,
		   l_revision,
		   l_transactable,
		   l_sn_control_code,
		   l_as_alpha_prefix,
		   l_transfer_lpn_id	-- bug 3544019
	    FROM   mtl_system_items		mi,
		   mtl_secondary_inventories 	msinv,
  		   rcv_shipment_lines		rs,
		   rcv_transactions		rt
	    WHERE  rt.transaction_id                 = l_transaction_id
	    AND	   rs.shipment_line_id               = rt.shipment_line_id
	    AND	   mi.organization_id                = rt.organization_id
	    AND	   mi.inventory_item_id              = rs.item_id
	    AND    msinv.organization_id(+)          = rt.organization_id
	    AND    msinv.secondary_inventory_name(+) = rt.subinventory;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'l_revision - '||L_REVISION ) ;
            END IF;


     EXCEPTION
	   WHEN NO_DATA_FOUND THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'SQL: Fail to retrieve the receiving information '||sqlerrm , 1 ) ;
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   WHEN OTHERS THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Error while retrieving receiving information '||sqlerrm , 1 ) ;
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Ordered uom code => '||L_ORDER_UOM , 5 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Received uom code => '||L_RCV_UOM , 5 ) ;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Receiving the items in the subinventory => '||L_SUBINVENTORY , 1 ) ;
     END IF;

     l_line_rec.subinventory := l_subinventory;

     /*
     ** There might be mutiple lots associated with one receiving
     ** transaction. while loop to create a reservation for each lot.
     */

     DECLARE CURSOR  transaction_info IS
     SELECT  rl.lot_num
             ,NVL( rl.quantity, -1)
             ,rl.secondary_quantity                            -- OPM
 --            ,rl.sublot_num                                    -- OPM
             ,rt.transaction_id
     FROM    rcv_lot_transactions rl,
             rcv_transactions rt
     WHERE   rt.transaction_id = l_transaction_id
     AND     rl.transaction_id (+) = rt.transaction_id;


     BEGIN

        OPEN transaction_info;

        FETCH transaction_info INTO
	      l_lot,
	      l_lot_quantity,
	      l_lot_quantity2,
	--      l_sublot_no, -- INVCONV
	      l_transaction_id;

        IF (l_lot_quantity = -1 ) THEN /* no lot associated */
            l_lot_quantity := l_rcv_quantity;
            l_lot_quantity2 := l_rcv_quantity2;
        END IF;


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Open qty available for receipt => ' || L_SHORT_QUANTITY , 1 ) ;
        END IF;

        LOOP

           /*
           ** Will use this sequence for inserting all records in
           ** MTL_INTERFACE tables during decrement inventory
           */

           SELECT mtl_material_transactions_s.nextval
           INTO l_lot_set_id
           FROM dual;

           IF l_lot_quantity <> -1 THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(' Lot number => ' || l_lot , 5 ) ;
              END IF;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(' Lot quantity => ' || l_lot_quantity , 5 ) ;
                  oe_debug_pub.add(' Lot quantity2 => ' || l_lot_quantity2 , 5 ) ; -- INVCONV
              END IF;
           END IF;

           IF (l_lot_quantity <= 0) THEN
                goto end_loop;
           END IF;


           /* OPM uom2 can not be changed */
           l_reserve_quantity2   := nvl(l_lot_quantity2,0);

           /*  Reserve the quantities in this lot */

           IF l_order_uom <> l_rcv_uom THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'Converting the unit of measurement ' , 5 ) ;
              END IF;
              l_converted_qty := OE_ORDER_MISC_UTIL.CONVERT_UOM (l_item_id,l_rcv_uom,l_order_uom,l_lot_quantity);

              /* -- need forking for OPM UOM conv INVCONV

              IF (INV_GMI_RSV_BRANCH.Process_Branch(l_line_rec.ship_from_org_id)) THEN

              -- This code is commented can we delete this code
              -- OPM Feb 2003 2683316 - changed the call to GMI
              -- uom_conversion and Get_OPMUOM_from_AppsUOM above to
              -- get_opm_converted_qty to resolve rounding issues


              l_converted_qty := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => l_line_rec.inventory_item_id,
              p_organization_id => l_line_rec.ship_from_org_id,
              p_apps_from_uom   => l_rcv_uom,
              p_apps_to_uom     => l_order_uom,
              p_original_qty    => l_lot_quantity);

              GMI_Reservation_Util.Println(' OPM converted qty in proc DropShipReceive '||
                                ' after new get_opm_converted_qty is  '|| l_converted_qty);
              --OPM Feb 2003 2683316 end

              END IF;
              -- end OPM forking for UOM conv
              */

              l_short_quantity := l_short_quantity - l_converted_qty;
              l_add_to_shipped := l_add_to_shipped + l_converted_qty;
              l_qty_to_be_reserved := l_converted_qty;

           ELSE
              l_add_to_shipped := l_add_to_shipped + l_lot_quantity;
              l_short_quantity := l_short_quantity - l_lot_quantity ;
              l_qty_to_be_reserved := l_lot_quantity;
           END IF;

           -- dual uom2 can not be changed INVCONV

           l_short_quantity2 := l_short_quantity2 - nvl(l_lot_quantity2,0);
           l_add_to_shipped2 := l_add_to_shipped2 + nvl(l_lot_quantity2,0);
					 l_qty2_to_be_reserved := l_lot_quantity2; -- INVCONV
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'Is subinventory reservable ? '||l_sub_reservable , 1 ) ;
           END IF;

           BEGIN
                 SELECT NVL(reservable_type,2)
                 INTO   l_item_reservable
                 FROM   mtl_system_items
                 WHERE  inventory_item_id = l_line_rec.inventory_item_id
                 AND    organization_id   = l_line_rec.ship_from_org_id;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'Is item reservable ? '||l_item_reservable , 1 ) ;
                 END IF;

           EXCEPTION WHEN OTHERS THEN
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'Error while checking item reservable ? '||sqlerrm , 1 ) ;
                 END IF;
                 l_item_reservable := 2;
           END;


           IF p_application_short_name = 'INV'  -- INVCONV AND
             -- (NOT INV_GMI_RSV_BRANCH.Process_Branch(l_line_rec.ship_from_org_id)) INVCONV
              AND p_mode = 0 THEN
              IF l_sub_reservable = 1 AND l_item_reservable = 1 THEN
                 Create_reservation
                          (p_qty_to_be_reserved       =>    l_qty_to_be_reserved
                          ,p_qty2_to_be_reserved       =>   l_qty2_to_be_reserved -- INVCONV
                          ,p_revision                 =>    l_revision
                          ,p_locator_id               =>    l_locator_id
                          ,p_lot                      =>    l_lot
                          ,p_line_rec                 =>    l_line_rec
                          ,x_qty_reserved             =>    l_quantity_reserved
                          ,x_qty2_reserved             =>   l_quantity2_reserved -- INVCONV
                          ,x_rsv_id                   =>    l_rsv_id
                          ,x_return_status            =>    l_return_status
                          ,p_transfer_lpn_id	      =>    l_transfer_lpn_id);
	-- bug 3544019

                IF l_return_status = FND_API.G_RET_STS_ERROR then
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Call to Create Reservation returned expected error '||sqlerrm,1) ;
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Call to Create Reservation returned unexpected error '||sqlerrm , 1 ) ;
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

           ELSE
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Item OR Subinventory Non-reservable ' , 1 ) ;
                 END IF;
                 l_quantity_reserved := l_qty_to_be_reserved;
                  l_quantity2_reserved := l_qty2_to_be_reserved; -- INVCONV
           END IF;

           END IF;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'After reservation check' , 1 ) ;
           END IF;


           -- Decrement Inventory

           l_chart_of_accts := Get_Char_of_accts (l_line_rec.ship_from_org_id);

           IF p_application_short_name = 'INV' AND
                                   p_mode = 0 THEN
              /* forking code for OPM  INVCONV NOT NEEDED NOW
              IF (INV_GMI_RSV_BRANCH.Process_Branch(l_line_rec.ship_from_org_id))
              THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'Calling decrement inventory for opm' , 1 ) ;
                END IF;
                Decrement_Inventory_for_OPM(
                   p_detail_id              => l_rsv_id,
                   p_line_rec               => l_line_rec,
                   p_transaction_id         => l_transaction_id,
                   p_trans_qty              => l_lot_quantity,
                   p_trans_qty2             => l_lot_quantity2,
                   p_inventory_item_id      => l_line_rec.inventory_item_id,
                   p_delivery               => null,
                   p_lot_number             => l_lot,
                   p_sublot_no              => l_sublot_no,
                   p_revision               => l_revision,
                   p_locator_id             => l_locator_id,
                   p_warehouse_id           => l_organization_id,
                   p_chart_of_accts         => l_chart_of_accts,
                   p_trx_uom                => l_rcv_uom,
                   p_sn_control_code        => l_sn_control_code,
                   p_as_alpha_prefix        => l_as_alpha_prefix,
                   p_transaction_header_id  => l_lot_set_id,
                   x_return_status          => l_return_status);
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('After calling decrement inventory for opm: ' || l_return_status,1) ;
                   END IF;
                IF l_return_status = FND_API.G_RET_STS_ERROR then
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              ElSE */
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'Calling decrement inventory()' , 1 ) ;
                END IF;
                Decrement_Inventory(
                       p_detail_id              => l_rsv_id,
                       p_line_rec               => l_line_rec,
                       p_transaction_id         => l_transaction_id,
                       p_transaction_detail_qty => l_lot_quantity,
                       p_trans_qty2             => l_lot_quantity2, -- INVCONV
                       p_inventory_item_id      => l_line_rec.inventory_item_id,
                       p_delivery               => null,
                       p_lot_number             => l_lot,
                       p_revision               => l_revision,
                       p_secondary_inventory    => l_subinventory,
                       p_locator_id             => l_locator_id,
                       p_warehouse_id           => l_organization_id,
                       p_chart_of_accts         => l_chart_of_accts,
                       p_trx_uom                => l_rcv_uom,
                       p_sn_control_code        => l_sn_control_code,
                       p_as_alpha_prefix        => l_as_alpha_prefix,
                       p_transaction_header_id  => l_lot_set_id,
		       p_transfer_lpn_id	=> l_transfer_lpn_id, --3544019
                       x_return_status          => l_return_status);

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'After calling decrement inventory : ' || l_return_status,1) ;
                END IF;

                IF l_return_status = FND_API.G_RET_STS_ERROR then
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Call to decrementinventory() returned expected error '||sqlerrm,1) ;
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Call to decrementinventory() returned unexpected error '||sqlerrm , 1 ) ;
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF; -- IF l_return_status = FND_API.G_RET_STS_ERROR then -- INVCONV
              --END IF;  -- INVCONV
           END IF;

           FETCH transaction_info INTO
	      l_lot,
	      l_lot_quantity,
	      l_lot_quantity2,
	       --l_sublot_no, -- INVCONV
	      l_transaction_id;
           EXIT WHEN transaction_info%NOTFOUND;
        END LOOP;
        << end_loop >>
        CLOSE transaction_info;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Final open quantity in the sales order => '||l_short_quantity,1) ;
        END IF;

    END;

    -- Calling Process Order to update Sales Order Lines.

    Call_Process_Order
          (p_orig_shipped           =>     l_orig_shipped
          ,p_short_quantity         =>     l_short_quantity
          ,p_transaction_date       =>     l_transaction_date
          ,p_add_to_shipped         =>     l_add_to_shipped
          ,p_add_to_shipped2        =>     l_add_to_shipped2
          ,p_line_rec               =>     l_line_rec
          ,x_return_status          =>     l_return_status
          );

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Call to process order returned unexpected error '||sqlerrm , 1 ) ;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Call to process order returned expected error '||sqlerrm , 1 ) ;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

    /* Commented for MOAC
    IF l_so_ou_id <> l_po_ou_id THEN

       FND_GLOBAL.Apps_Initialize
                    (user_id      => l_orig_user_id
                    ,resp_id      => l_orig_resp_id
                    ,resp_appl_id => l_resp_appl_id);
    END IF; */

    -- Reset The Context for Enhanced Dropshipments.
    IF l_reset_policy THEN -- MOAC
      Mo_Global.Set_Policy_Context (p_access_mode => l_access_mode,  p_org_id => l_current_org_id);
    END IF;


    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Exiting dropshipreceive() successfully ' , 1 ) ;
    END IF;

    OE_DEBUG_PUB.dumpdebug;
    OE_DEBUG_PUB.Debug_Off;

    RETURN TRUE;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Exiting dropshipreceive with exp. error => '||sqlerrm , 1 ) ;
        END IF;
        OE_MSG_PUB.Save_API_Messages(); -- bug 4393738
        OE_DEBUG_PUB.dumpdebug;
        OE_DEBUG_PUB.Debug_Off;
	RETURN FALSE;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Exiting dropshipreceive with unexp. error => '||sqlerrm , 1 ) ;
        END IF;
        OE_MSG_PUB.Save_API_Messages(); -- bug 4393738
        OE_DEBUG_PUB.dumpdebug;
        OE_DEBUG_PUB.Debug_Off;
	RETURN FALSE;
   WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Exiting dropshipreceive with others error => '||sqlerrm , 1 ) ;
        END IF;
        OE_MSG_PUB.Save_API_Messages(); -- bug 4393738
        OE_DEBUG_PUB.dumpdebug;
        OE_DEBUG_PUB.Debug_Off;
	RETURN FALSE;
END DropShipReceive;

/* --------------------------------------------------------------------
Procedure Name : Decrement_Inventory
Description    : This procedure inserts records in the MTL_TRANSACTION...
	         tables. The inserted records will be later processed by
                 mtl_online_transaction_pub.process_online API  (called
                 from the main dropshipreceive function, to decrement
                 inventory in the system.
                 This API is called in a loop from the DropShipReceive
                 function. The receiving transactions are stored in
                 RCV_TRANSACTIONS table and RCV_LOT_TRANSACTIONS (if there
                 are lot level transactions). This API will be called only
                 once (for the record in RCV_TRANSACTIONS) if not lots are
                 associated. If there are multiple lots in the transaction,
                 it will be called for every lot.

                 This API will insert records into

                 MTL_TRANSACTION_LOTS_INTERFACE: For every receipt in lot
                                                 (lot controlled items).
                 MTL_SERIAL_NUMBERS_INTERFACE  : For every serial number
                                                 receipt (serial controlled
                                                 items.)
                 MTL_TRANSACTIONS_INTERFACE    : For every transaction
                                                 (corresponds to qty recd
                                                  in RCV_TRANSACTIONS)

                 IMPORTANT: ALL THE RECORDS INSERTED IN THE ABOVE TABLE FOR A
                 PARTICULAR TRANSACTION HAVE THE SAME TRANSACTION_INTERFACE_ID.
                 We pass the p_transaction_header_id to this API which is
                 value we got from mtl_material_transactions_s sequence.
                 This value is assigned to the TRANSACTION_INTERFACE_ID.


----------------------------------------------------------------------- */

Procedure Decrement_Inventory(
             p_detail_id              IN  NUMBER,
             p_line_rec               IN  OE_ORDER_PUB.line_rec_type,
             p_transaction_id         IN  NUMBER,
             p_transaction_detail_qty IN  NUMBER,
             p_trans_qty2 IN  NUMBER, -- INVCONV
             p_inventory_item_id      IN  NUMBER,
             p_delivery               IN  NUMBER,
             p_lot_number             IN  VARCHAR2,
             p_revision               IN  VARCHAR2,
             p_secondary_inventory    IN  VARCHAR2,
             p_locator_id             IN  NUMBER,
             p_warehouse_id           IN  NUMBER,
             p_chart_of_accts         IN  NUMBER,
             p_trx_uom                IN  VARCHAR2,
	     p_sn_control_code        IN  NUMBER,
	     p_as_alpha_prefix        IN  VARCHAR2,
	     p_transaction_header_id  IN  NUMBER,
	     p_transfer_lpn_id	      IN  NUMBER,	-- 3544019
x_return_status OUT NOCOPY VARCHAR2)

IS
l_source_line_id           NUMBER;
l_lot_set_id               NUMBER;
l_trans_acc                NUMBER;
l_trx_source_type_id       NUMBER := 2;
l_trx_action_id            NUMBER := 1;
l_trx_type_code            NUMBER := 33;
l_ord_num                  NUMBER;
--l_order_type_name          VARCHAR2(30) := 'Standard'; bug 4456817
l_budget_acct_id           NUMBER := -1;
l_project_id               NUMBER := p_line_rec.project_id;
l_task_id                  NUMBER := p_line_rec.task_id;
l_transaction_reference    NUMBER := 0;
--l_order_number             NUMBER; bug 4456817
l_line_id                  NUMBER := p_line_rec.line_id;
l_shipment_line_id         NUMBER := 0;
l_delivery                 NUMBER := -1;
l_dest_subinv              VARCHAR2(30) := ' ';
l_to_org_id                NUMBER := -1;
l_location_id              NUMBER := 0;
l_req_line_id              NUMBER := 0;
l_unit_price               NUMBER;
l_concat_segs              VARCHAR2(2000);
l_concat_ids               VARCHAR2(2000);
l_concat_descrs            VARCHAR2(2000);
l_serial_set_id            NUMBER;
serial_counter             NUMBER;
l_transaction_date         DATE;
v_serial_number            VARCHAR2(30);
v_serial_number_temp       VARCHAR2(30);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
--l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_transaction_interface_id NUMBER := null;
l_transaction_header_id    NUMBER := p_transaction_header_id;
l_transaction_source_id    NUMBER ; /* sales_order_id */
l_converted_qty            NUMBER;       -- Bug-2311061
l_primary_uom                VARCHAR2(3);  -- Bug-2908567
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Entering decrement inventory() ' ) ;
      oe_debug_pub.add(' p_lot_number : ' || p_lot_number , 1 ) ;
      oe_debug_pub.add(' p_revision : ' || p_revision , 1 ) ;
      oe_debug_pub.add(' p_secondary_inventory : ' || p_secondary_inventory , 1 ) ;
      oe_debug_pub.add(' p_inventory_item_id : ' || p_inventory_item_id , 1 ) ;
      oe_debug_pub.add(' p_trx_uom : ' || p_trx_uom , 1 ) ;
      oe_debug_pub.add(' p_chart_of_accts : ' || p_chart_of_accts , 1 ) ;
      oe_debug_pub.add(' p_warehouse_id : ' || p_warehouse_id , 1 ) ;
      oe_debug_pub.add(' p_as_alpha_prefix : ' || p_as_alpha_prefix , 1 ) ;
      oe_debug_pub.add(' p_sn_control_code : ' || p_sn_control_code , 1 ) ;
      oe_debug_pub.add(' p_transaction_id : ' || p_transaction_id , 1 ) ;
  END IF;

  -- bug 5357879
  SAVEPOINT DECREMENT_INV;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  profile_values.oe_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
  profile_values.user_id        := FND_GLOBAL.USER_ID;
  profile_values.login_id       := FND_GLOBAL.LOGIN_ID;
  profile_values.request_id     := 0;
  profile_values.application_id := 0;
  profile_values.program_id     := 0;

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



  IF OE_FLEX_COGS_PUB.Start_Process (
      p_api_version_number    => 1.0,
      p_line_id               => p_line_rec.line_id,
      x_return_ccid           => l_trans_acc,
      x_concat_segs           => l_concat_segs,
      x_concat_ids            => l_concat_ids,
      x_concat_descrs         => l_concat_descrs,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data) <> FND_API.G_RET_STS_SUCCESS
  THEN

	l_trans_acc := NULL;
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Transaction account id : ' ||l_trans_acc,1 ) ;
  END IF;



 -- End Deferred Revenue Project


/*  SELECT oe_transactions_iface_s.nextval
  INTO l_source_line_id
  FROM dual; */

  -- Change for #2736818
  l_source_line_id := p_line_rec.line_id; -- Sales Order Line ID
  l_lot_set_id := p_transaction_header_id;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Source line id => ' || l_source_line_id , 1 ) ;
      oe_debug_pub.add(  'Selecting unique id for this transaction' , 1 ) ;
      oe_debug_pub.add(  'Transaction header ID :' || l_lot_set_id, 1 ) ;
  END IF;

  IF (p_lot_number is not null) THEN

     /* Insert lot transaction interface table */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Inserting lots' ) ;
     END IF;
     INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE
         (
           SOURCE_CODE,
           SOURCE_LINE_ID,
           TRANSACTION_INTERFACE_ID,
           LOT_NUMBER,
           TRANSACTION_QUANTITY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           SERIAL_TRANSACTION_TEMP_ID,
           ERROR_CODE,
           PROCESS_FLAG )
     VALUES
         (
          profile_values.oe_source_code,
          l_source_line_id,
          l_lot_set_id,
          p_lot_number,
          p_transaction_detail_qty,
          sysdate,
          profile_values.user_id,
          sysdate,
          profile_values.user_id,
          null,
          null,
          'Y');

  END IF; /* end insert lot */

  /*
      Inserting into serial number interface

  1.  If it is a predefined serial number controlled item
          i.e. serial number control code = 2
          then when doing an issue transaction ,get the
          serial numbers from prior receipt transactions for the
          same item,warehouse,locator combination.
  2.  If it is a serial controlled item with dynamic generation
          at receipt time i.e. serial number control code = 5
          logic is same as above when doing an issue transaction.
  3.  If it is a serial controlled item with dynamic generation
          at issue time generate the serial numbers with appropriate prefix .
          There is 1 serial number per quantity.

  */

  IF (p_sn_control_code = 2 OR
      p_sn_control_code = 5 OR
      p_sn_control_code = 6)
  THEN

    SELECT mtl_material_transactions_s.nextval
    INTO l_serial_set_id
    FROM dual;

    DECLARE
        --modified the following cursor for bug 6012741
	CURSOR get_received_serial_number IS
        SELECT rtrim(ltrim(msn.serial_number))
        FROM   mtl_serial_numbers msn
        WHERE  msn.inventory_item_id =   p_inventory_item_id
        AND    msn.current_organization_id =  p_warehouse_id
        AND    nvl(msn.current_subinventory_code,' ') = p_secondary_inventory
        AND    nvl(msn.current_locator_id,0) = nvl(p_locator_id,0)
        AND    msn.current_status=3
        AND    msn.group_mark_id is NULL
        AND exists (select 1 from mtl_material_transactions mmt, rcv_transactions rt
                      where mmt.transaction_id = msn.last_transaction_id
                        and mmt.transaction_source_type_id = 1
                        and rt.transaction_id = p_transaction_id
                        and rt.transaction_id = mmt.rcv_transaction_id
                        and msn.last_txn_source_id = rt.po_header_id);

    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    BEGIN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Inserting serial numbers after serial numbers fix' , 1 ) ;
        END IF;

        IF (p_sn_control_code = 2 OR p_sn_control_code = 5) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'Serial control code = 2 or 5' , 1 ) ;
            END IF;
            OPEN get_received_serial_number;
        ELSIF (p_sn_control_code = 6) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'Serial control code = 6' , 1 ) ;
            END IF;
        END IF;

        serial_counter := 0;

        -- If Order UOM and recieving UOM are not equal convert the
        -- quantity to insert serial numbers. Bug-2311061
        -- If Recieving UOM and Primary UOM are not same
        -- Convert the quantity to insert serial numbers Bug - 2908567

        BEGIN
            SELECT primary_uom_code
            INTO   l_primary_uom
            FROM   mtl_system_items
            WHERE  inventory_item_id  = p_line_rec.inventory_item_id
            AND    organization_id    = p_line_rec.ship_from_org_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 NULL;
        END ;

        IF l_primary_uom <> p_trx_uom THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Converting the unit of measurement ' , 1 ) ;
              oe_debug_pub.add('Primary UOM:'||l_primary_uom , 1 ) ;
              oe_debug_pub.add('Transaction UOM:'||p_trx_uom , 1 ) ;
          END IF;
          l_converted_qty := OE_ORDER_MISC_UTIL.CONVERT_UOM (
                                               p_line_rec.inventory_item_id,
                                               p_trx_uom,
                                               l_primary_uom,
                                               p_transaction_detail_qty);
        ELSE
          l_converted_qty := p_transaction_detail_qty;
        END IF;

        while serial_counter < l_converted_qty LOOP

        IF (p_sn_control_code = 6) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'in for loop s.n control code = 6' , 1 ) ;
           END IF;
           SELECT to_char(oe_mtl_sn_interface_s.nextval)
           INTO v_serial_number_temp
           FROM dual ;
           IF p_as_alpha_prefix is not null THEN
              v_serial_number := p_as_alpha_prefix || v_serial_number_temp;
           ELSE
              v_serial_number := v_serial_number_temp;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'Final serial number is ' || V_SERIAL_NUMBER , 1 ) ;
           END IF;
        ELSIF (p_sn_control_code = 2 OR p_sn_control_code = 5) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'Logic for s.n control code = 2 or 5 ' , 1 ) ;
           END IF;
	   FETCH get_received_serial_number INTO v_serial_number;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'Serial number fetched is => ' || v_serial_number , 1 ) ;
           END IF;
        END IF;

        BEGIN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'Inserting into mtl_serial_numbers_interface table ' , 1 ) ;
           END IF;

           insert into mtl_serial_numbers_interface
                    (transaction_interface_id,
                    source_code,
                    source_line_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    vendor_serial_number,
                    vendor_lot_number,
                    fm_serial_number,
                    to_serial_number,
                    error_code,
                    process_flag
                    )
             values
                   (
                  l_serial_set_id,  /*transaction_interface_id */
                  profile_values.oe_source_code, /*source_code */
                  l_source_line_id,             /*source_line_id */
                  sysdate,                     /*last_update_date*/
                  profile_values.user_id,      /*last_updated_by */
                  sysdate ,                    /*creation_date  */
                  profile_values.user_id,       /*created by  */
                  profile_values.login_id ,  /*last_update_login */
                  profile_values.request_id,        /*request_id */
                  profile_values.application_id, /*program_application_id */
                  profile_values.program_id,        /*program_id */
                  sysdate,                    /*program_update_date */
                  null,                     /* vendor_serial_number */
                  null,                     /* vendor_lot_number */
                  v_serial_number,           /* fm_serial_number */
                  null,                     /*to_serial_number */
                  null,                     /* error_code */
                  null                      /* process_flag */
                   ) ;

          EXCEPTION
             WHEN OTHERS THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'Failed inserting into mtl_serial_numbers_interface' , 1 ) ;
                  END IF;
                  -- bug 5357879
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  ROLLBACK TO DECREMENT_INV;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          /* Update the column group_mark_id with line_id, so that
             this serial number will not be used by another transaction
             and thus avoiding duplicates */

          IF ((p_sn_control_code = 2) OR
              (p_sn_control_code = 5))
          THEN

            BEGIN
               UPDATE mtl_serial_numbers
               SET  GROUP_MARK_ID = p_line_rec.line_id
               where inventory_item_id = p_inventory_item_id
               and current_organization_id = p_warehouse_id
               and nvl(current_locator_id,0) = nvl(p_locator_id,0)
               and serial_number = v_serial_number;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'Serial number updated is :' || v_serial_number , 1 ) ;
               END IF;
            EXCEPTION
              WHEN OTHERS THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Updating serial numbers failed '||sqlerrm , 1 ) ;
                   END IF;

                   -- bug 5357879
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   ROLLBACK TO DECREMENT_INV;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END;
          END IF;
          serial_counter := serial_counter + 1;
        END LOOP; /* while serial_counter < p_transaction_detail_qty */

    END;
  END IF; /* end serial number logic */

  IF (p_lot_number is not null) AND
     (p_sn_control_code = 2 OR
      p_sn_control_code = 5 OR
      p_sn_control_code = 6)
  THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'This is serial+lot controlled item' , 1 ) ;
     END IF;

     BEGIN

        UPDATE MTL_TRANSACTION_LOTS_INTERFACE
        SET    SERIAL_TRANSACTION_TEMP_ID = l_serial_set_id
        WHERE  TRANSACTION_INTERFACE_ID = l_lot_set_id;

     EXCEPTION
        WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'Updating serial_transaction_temp_id failed '||sqlerrm , 1 ) ;
              END IF;

              -- bug 5357879
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO DECREMENT_INV;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

  END IF;

  /* Determine the Transaction Interface ID for this transaction */

  if (p_lot_number is null) AND
     (p_sn_control_code = 2 OR p_sn_control_code = 5 OR p_sn_control_code = 6) then
     l_transaction_interface_id := l_serial_set_id;
  else
     l_transaction_interface_id := l_lot_set_id;
  end if;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Populating transaction_interface_id in mti as '||L_TRANSACTION_INTERFACE_ID , 1 ) ;
  END IF;

  BEGIN
      SELECT RT.TRANSACTION_DATE
      INTO   l_transaction_date
      FROM   RCV_TRANSACTIONS RT
      WHERE  RT.TRANSACTION_ID = p_transaction_id;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_transaction_date := sysdate;
      WHEN OTHERS THEN
           l_transaction_date := sysdate;
  END;

  l_transaction_reference := p_line_rec.header_id;
  l_transaction_source_id := get_mtl_sales_order_id(p_line_rec.header_id);
/* commented for bug 4456817
  BEGIN
      SELECT h.order_number,ot.name
      INTO   l_order_number,l_order_type_name
      FROM   oe_order_headers_all h, oe_order_types_v ot
      WHERE  h.header_id      = p_line_rec.header_id AND
             ot.order_type_id = h.order_type_id;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_transaction_date := sysdate;
      WHEN OTHERS THEN
           l_transaction_date := sysdate;
  END; */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Inserting header record' ) ;
      oe_debug_pub.add('Source_code : ' || fnd_profile.value ( 'ont_source_code' ) , 1 ) ;
      oe_debug_pub.add('Source_line_id : ' || l_source_line_id , 1 ) ;
      oe_debug_pub.add('Source_header_id : ' || l_transaction_reference , 1 ) ;
      oe_debug_pub.add('Process_flag : ' || 1 , 1 ) ;
      oe_debug_pub.add('Transaction_mode : ' || 1 , 1 ) ;
      oe_debug_pub.add('Lock_flag : ' || 2 , 1 ) ;
      oe_debug_pub.add('Transaction_header_id : ' || l_transaction_header_id , 1 ) ;
      oe_debug_pub.add('Inventory_item_id : ' || p_inventory_item_id , 1 ) ;
      oe_debug_pub.add('Subinventory_code : ' || p_secondary_inventory , 1 ) ;
      oe_debug_pub.add('Transaction_quantity : ' || ( -1 * p_transaction_detail_qty ) , 1 ) ;
      oe_debug_pub.add('Transaction_quantity2 : ' || ( -1 * p_trans_qty2 ) , 1 ) ; -- INVCONV
      oe_debug_pub.add('Transaction_date : ' || l_transaction_date , 1 ) ;
      oe_debug_pub.add('Organization_id : ' || p_warehouse_id , 1 ) ;
      oe_debug_pub.add('Transfer_lpn_id : ' || p_transfer_lpn_id,1) ; -- 3544019
      oe_debug_pub.add('Acct_period_id : ' || null , 1 ) ;
      oe_debug_pub.add('Last_update_date : ' || sysdate , 1 ) ;
      oe_debug_pub.add('Last_updated_by : ' || fnd_global.user_id , 1 ) ;
      oe_debug_pub.add('Creation_date : ' || sysdate , 1 ) ;
      oe_debug_pub.add('Created_by : ' || fnd_global.user_id , 1 ) ;
      oe_debug_pub.add('Transaction_source_id : ' || l_transaction_source_id , 1 ) ;
   --   oe_debug_pub.add('Dsp_segment1 : ' || l_order_number , 1 ) ; bug 4456817
   --   oe_debug_pub.add('Dsp_segment2 : ' || l_order_type_name , 1 ) ;
   --   oe_debug_pub.add('Dsp_segment3 : ' || fnd_profile.value ( 'ont_source_code' ) , 1 ) ;
      oe_debug_pub.add('Transaction_source_type_id : ' || l_trx_source_type_id , 1 ) ;
      oe_debug_pub.add('Transaction_action_id : ' || l_trx_action_id , 1 ) ;
      oe_debug_pub.add('Transaction_type_id : ' || l_trx_type_code , 1 ) ;
      oe_debug_pub.add('Distribution_account_id : ' || l_trans_acc , 1 ) ;
      oe_debug_pub.add('Transaction_reference : ' || l_transaction_reference , 1 ) ;
      oe_debug_pub.add('Trx_source_line_id : ' || l_line_id , 1 ) ;
      oe_debug_pub.add('Trx_source_delivery_id : ' || l_delivery , 1 ) ;
      oe_debug_pub.add('Revision : ' || p_revision , 1 ) ;
      oe_debug_pub.add('Locator_id : ' || p_locator_id , 1 ) ;
      oe_debug_pub.add('Loc_segment1 : ' || null , 1 ) ;
      oe_debug_pub.add('Loc_segment2 : ' || null , 1 ) ;
      oe_debug_pub.add('Loc_segment3 : ' || null , 1 ) ;
      oe_debug_pub.add('Loc_segment4 : ' || null , 1 ) ;
      oe_debug_pub.add('Required_flag : ' || null , 1 ) ;
      oe_debug_pub.add('Picking_line_id : ' || l_shipment_line_id , 1 ) ;
      oe_debug_pub.add('Transfer_subinventory : ' || l_dest_subinv , 1 ) ;
      oe_debug_pub.add('Transfer_organization : ' || l_to_org_id , 1 ) ;
      oe_debug_pub.add('Ship_to_location_id : ' || l_location_id , 1 ) ;
      oe_debug_pub.add('Requisition_line_id : ' || l_req_line_id , 1 ) ;
      oe_debug_pub.add('Transaction_uom : ' || p_trx_uom , 1 ) ;
      oe_debug_pub.add('Transaction interface_id : ' || l_transaction_interface_id , 1 ) ;
      oe_debug_pub.add('Demand_id : ' || null , 1 ) ;
      oe_debug_pub.add('Shipment_number : ' || null , 1 ) ;
      oe_debug_pub.add('Currency_code : ' || null , 1 ) ;
      oe_debug_pub.add('Currency_conversion_type : ' || null , 1 ) ;
      oe_debug_pub.add('Currency_conversion_date : ' || null , 1 ) ;
      oe_debug_pub.add('Currency_conversion_rate : ' || null , 1 ) ;
      oe_debug_pub.add('Encumbrance_account : ' || l_budget_acct_id , 1 ) ;
      oe_debug_pub.add('Encumbrance_amount : ' || l_unit_price * p_transaction_detail_qty , 1 ) ;
      oe_debug_pub.add('Project_id : ' || l_project_id , 1 ) ;
      oe_debug_pub.add('Task_id : ' || l_task_id , 1 ) ;
      oe_debug_pub.add('Before inserting records into mtl interface table..' , 1 ) ;
  END IF;

  -- 1517431 populate distribution account

  DECLARE
     l_segment1 varchar2(25) := NULL;
     l_segment2 varchar2(25) := NULL;
     l_segment3 varchar2(25) := NULL;
     l_segment4 varchar2(25) := NULL;
     l_segment5 varchar2(25) := NULL;
     l_segment6 varchar2(25) := NULL;
     l_segment7 varchar2(25) := NULL;
     l_segment8 varchar2(25) := NULL;
     l_segment9 varchar2(25) := NULL;
     l_segment10 varchar2(25) := NULL;
     l_segment11 varchar2(25) := NULL;
     l_segment12 varchar2(25) := NULL;
     l_segment13 varchar2(25) := NULL;
     l_segment14 varchar2(25) := NULL;
     l_segment15 varchar2(25) := NULL;
     l_segment16 varchar2(25) := NULL;
     l_segment17 varchar2(25) := NULL;
     l_segment18 varchar2(25) := NULL;
     l_segment19 varchar2(25) := NULL;
     l_segment20 varchar2(25) := NULL;
     l_segment21 varchar2(25) := NULL;
     l_segment22 varchar2(25) := NULL;
     l_segment23 varchar2(25) := NULL;
     l_segment24 varchar2(25) := NULL;
     l_segment25 varchar2(25) := NULL;
     l_segment26 varchar2(25) := NULL;
     l_segment27 varchar2(25) := NULL;
     l_segment28 varchar2(25) := NULL;
     l_segment29 varchar2(25) := NULL;
     l_segment30 varchar2(25) := NULL;
     CURSOR c_transacc_info IS
     SELECT segment1,
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
   	    segment30
     FROM   GL_CODE_COMBINATIONS
     WHERE  code_combination_id = l_trans_acc;
     BEGIN
     OPEN c_transacc_info;
     FETCH c_transacc_info INTO
   	    l_segment1,
   	    l_segment2,
   	    l_segment3,
   	    l_segment4,
   	    l_segment5,
   	    l_segment6,
   	    l_segment7,
   	    l_segment8,
   	    l_segment9,
   	    l_segment10,
   	    l_segment11,
   	    l_segment12,
   	    l_segment13,
   	    l_segment14,
   	    l_segment15,
   	    l_segment16,
   	    l_segment17,
   	    l_segment18,
   	    l_segment19,
   	    l_segment20,
   	    l_segment21,
   	    l_segment22,
   	    l_segment23,
   	    l_segment24,
   	    l_segment25,
   	    l_segment26,
   	    l_segment27,
   	    l_segment28,
   	    l_segment29,
   	    l_segment30;
      CLOSE c_transacc_info;

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
         --   DSP_SEGMENT1, bug 4456817
         --   DSP_SEGMENT2,
         --   DSP_SEGMENT3,
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
            TASK_ID,
	    CONTENT_LPN_ID) -- 3544019
            VALUES (
            profile_values.oe_source_code,
            l_source_line_id,
            l_transaction_reference,
            1,       /* PROCESS_FLAG 	*/
            3,       /* TRANSACTION_MODE */
            2,       /* LOCK_FLAG  */
            l_transaction_header_id,
            p_inventory_item_id,
            p_secondary_inventory,
            (-1 * p_transaction_detail_qty),
            (-1 * p_trans_qty2), -- INVCONV
            l_transaction_date,
            p_warehouse_id,
            null,
            sysdate,
            profile_values.user_id,
            sysdate,
            profile_values.user_id,
            l_transaction_source_id,
          --  l_order_number, bug 4456817
          --  l_order_type_name,
          --  profile_values.oe_source_code,
            l_trx_source_type_id,
            l_trx_action_id,
            l_trx_type_code,
            l_trans_acc,
            l_segment1,
            l_segment2,
            l_segment3,
            l_segment4,
            l_segment5,
            l_segment6,
            l_segment7,
            l_segment8,
            l_segment9,
            l_segment10,
            l_segment11,
            l_segment12,
            l_segment13,
            l_segment14,
            l_segment15,
            l_segment16,
            l_segment17,
            l_segment18,
            l_segment19,
            l_segment20,
            l_segment21,
            l_segment22,
            l_segment23,
            l_segment24,
            l_segment25,
            l_segment26,
            l_segment27,
            l_segment28,
            l_segment29,
            l_segment30,
            l_transaction_reference,
            l_line_id,
            decode(l_delivery,-1,null,l_delivery),
            p_revision,
            decode(p_locator_id,-1,null,p_locator_id),
            null,
            null,
            null,
            null,
            null,
            l_shipment_line_id,
            decode(l_dest_subinv,' ',null,l_dest_subinv),
            decode(l_to_org_id,-1,null,l_to_org_id),
            decode(l_location_id,0,null,l_location_id),
            decode(l_req_line_id,0,null,l_req_line_id),
            p_trx_uom,
            l_transaction_interface_id,
            null,
            null,
            null,
            null,
            null,
            null,
            decode(l_budget_acct_id,-1, null, l_budget_acct_id),
            decode(l_budget_acct_id,-1, null,
                   l_unit_price * p_transaction_detail_qty),
            decode(l_project_id, 0, null, l_project_id),
            decode(l_task_id, 0, null, l_task_id),
	    p_transfer_lpn_id); -- 3544019

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'Successfully inserted records in mtl interface table ' , 5 ) ;
                x_return_status := FND_API.G_RET_STS_SUCCESS; -- bug 5357879
            END IF;
     EXCEPTION WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'Failed while inserting records in mtl_transactions_interface '||sqlerrm , 1 ) ;
                oe_debug_pub.add(  'Sales order issue transaction will not occur ' , 1 ) ;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- bug 5357879
            ROLLBACK TO DECREMENT_INV;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

  -- Calling this API for immediate decrement of inventory

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Return from decrementinventory()',5 ) ;
  END IF;

END Decrement_Inventory;

/* --------------------------------------------------------------------
Procedure Name : Get_Char_of_accts
Description    :
----------------------------------------------------------------------- */
FUNCTION Get_Char_of_accts (p_ship_from_org_id IN NUMBER)
RETURN NUMBER
IS
l_chart_of_accs NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- SQL Performance ID 14882944, replacing org_organization_definitions with relevant base tables
  /*
  SELECT chart_of_accounts_id
  INTO l_chart_of_accs
  FROM org_organization_definitions
  WHERE org_organization_definitions.organization_id = p_ship_from_org_id; */

  SELECT chart_of_accounts_id INTO l_chart_of_accs
  FROM  gl_sets_of_books gsob, hr_organization_information hoi
  WHERE gsob.set_of_books_id = hoi.org_information1
    AND upper(hoi.org_information_context) = 'ACCOUNTING INFORMATION'
    AND hoi.organization_id = p_ship_from_org_id;

  RETURN l_chart_of_accs;
END Get_Char_of_accts;

/*--------------------------------------------------------------------------
Procedure Name : Get_mtl_sales_order_id
Description    : This funtion returns the SALES_ORDER_ID (frm mtl_sales_orders)
                 for a given heeader_id.
                 Every header in oe_order_headers_all will have a record
                 in MTL_SALES_ORDERS. The unique key to get the sales_order_id
                 from mtl_sales_orders is
                 Order_Number
                 Order_Type (in base language)
                 OM:Source Code profile option (stored as ont_source_code).

                 The above values are stored in a flex in MTL_SALES_ORDERS.
                 SEGMENT1 : stores the order number
                 SEGMENT2 : stores the order type
                 SEGMENT3 : stores the ont_source_code value

-------------------------------------------------------------------------- */
FUNCTION Get_mtl_sales_order_id(p_header_id IN NUMBER)
RETURN NUMBER
IS
l_source_code              VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
l_sales_order_id           NUMBER := 0;
l_order_type_name          VARCHAR2(80);
l_order_type_id            NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING GET_MTL_SALES_ORDER_ID IN DROPSHIPRECECEIVE ( ) ' , 3 ) ;
   END IF;

   BEGIN
      SELECT order_type_id
      INTO   l_order_type_id
      FROM   oe_order_headers
      WHERE header_id = p_header_id;
   EXCEPTION
      WHEN OTHERS THEN
          RAISE;
   END;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ORDER TYPE ID :' || L_ORDER_TYPE_ID , 3 ) ;
   END IF;

   BEGIN
     SELECT NAME
     INTO l_order_type_name
     FROM OE_TRANSACTION_TYPES_TL
     WHERE TRANSACTION_TYPE_ID = l_order_type_id
     AND language = (select language_code
                     from fnd_languages
                     where installed_flag = 'B');
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UNABLE TO LOCATE ORDER TYPE ID IN DROPSHIPRECEIVE ( ) '||sqlerrm , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ORDER TYPE: ' || L_ORDER_TYPE_NAME , 2 ) ;
       oe_debug_pub.add(  'SOURCE CODE: ' || L_SOURCE_CODE , 2 ) ;
   END IF;

   SELECT S.SALES_ORDER_ID
   INTO l_sales_order_id
   FROM MTL_SALES_ORDERS S,
        OE_ORDER_HEADERS H
   WHERE S.SEGMENT1 = TO_CHAR(H.ORDER_NUMBER)
   AND S.SEGMENT2 = l_order_type_name
   AND S.SEGMENT3 = l_source_code
   AND H.HEADER_ID = p_header_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXISTING GET_MTL_SALES_ORDER_ID ( ) WITH SALES ORDER ID => ' || L_SALES_ORDER_ID , 1 ) ;
   END IF;

   RETURN l_sales_order_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '2. L_SALES_ORDER_ID IS 0' , 5 ) ;
       END IF;
       RETURN 0;
    WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '2. L_SALES_ORDER_ID IS 0' , 5 ) ;
       END IF;
       RETURN 0;
END Get_mtl_sales_order_id;

/*-----------------------------------------------------------------
PROCEDURE :  Insert_OE_Drop_Ship_Source
DESCRIPTION:
-----------------------------------------------------------------*/

PROCEDURE Insert_OE_Drop_Ship_Source (P_Old_Line_ID IN NUMBER, P_New_Line_ID IN NUMBER) IS
l_Header_ID                    Number;
l_Org_ID                       Number;
l_Destination_Organization_ID  Number;
l_Requisition_Header_ID        Number;
l_Requisition_Line_ID          Number;
l_PO_Header_ID                 Number;
l_PO_Line_ID                   Number;
l_Line_Location_ID             Number;
l_PO_Release_ID                Number;
l_old_line_id                  Number := p_old_line_id;
l_new_line_id                  Number := p_new_line_id;

CURSOR old_drop_ship_line IS
SELECT Header_id,
	  Org_id,
       Destination_Organization_ID,
       Requisition_Header_ID,
       Requisition_Line_ID,
       PO_Header_ID,
       PO_Line_ID,
       Line_Location_ID,
       PO_Release_ID
FROM   OE_DROP_SHIP_SOURCES
WHERE  line_id = l_new_line_id
  AND  line_location_id = G_LINE_LOCATION_ID; -- bug 4402566

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   OPEN old_drop_ship_line;
   FETCH old_drop_ship_line
   INTO  l_header_id,
	    l_org_id,
	    l_destination_organization_id,
	    l_requisition_header_id,
	    l_requisition_line_id,
	    l_po_header_id,
	    l_po_line_id,
	    l_line_location_id,
	    l_po_release_id;
   CLOSE old_drop_ship_line;

   Insert Into OE_Drop_Ship_Sources
   (
    drop_ship_source_id,
    header_id,
    line_id,
    org_id,
    destination_organization_id,
    requisition_header_id,
    requisition_line_id,
    po_header_id,
    po_line_id,
    line_location_id,
    po_release_id,
    Creation_Date,
    Created_By,
    Last_Update_Date,
    Last_Updated_By
   )
    Values
   (
    oe_drop_ship_source_s.nextval,
    l_header_id,
    l_old_line_id,
    l_org_id,
    l_destination_organization_id,
    l_requisition_header_id,
    l_requisition_line_id,
    l_po_header_id,
    l_po_line_id,
    l_line_location_id,
    l_po_release_id,
    trunc(Sysdate),
    nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1),
    trunc(Sysdate),
    nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1)
   );

End Insert_OE_Drop_Ship_Source;

/* --------------------------------------------------------------------
Procedure Name : Decrement_Inventory_for_OPM
Description    : This procedure first check to see if the order line
			  has transaction or not. If it does have inv transaction
			  then, it would do the comparison. If they are the same,
			  this routine would do nothing. If they are not the same,
			  the old transactions would be deleted and new ones would be
			  inserted.Default lot is always checked. A default
			  transaction would be created if the item is not lot/location
			  ctl'ed and no transactions exist.

-----------------------------------------------------------------------*/

/*Procedure Decrement_Inventory_for_OPM(
             p_detail_id              IN  NUMBER,
             p_line_rec               IN  OE_ORDER_PUB.line_rec_type,
             p_transaction_id         IN  NUMBER,
             p_trans_qty              IN  NUMBER,
             p_trans_qty2             IN  NUMBER,
             p_inventory_item_id      IN  NUMBER,
             p_delivery               IN  NUMBER,
             p_lot_number             IN  VARCHAR2,
             p_sublot_no              IN  VARCHAR2,
             p_revision               IN  VARCHAR2,
             p_locator_id             IN  NUMBER,
             p_warehouse_id           IN  NUMBER,
             p_chart_of_accts         IN  NUMBER,
             p_trx_uom                IN  VARCHAR2,
             p_sn_control_code        IN  NUMBER,
             p_as_alpha_prefix        IN  VARCHAR2,
             p_transaction_header_id  IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_source_line_id           NUMBER;
l_lot_set_id               NUMBER;
l_trans_acc                NUMBER;
l_trans_qty                NUMBER;
l_ord_num                  NUMBER;
l_order_type_name          VARCHAR2(30) := 'Standard';
l_budget_acct_id           NUMBER := -1;
l_project_id               NUMBER := p_line_rec.project_id;
l_task_id                  NUMBER := p_line_rec.task_id;
l_transaction_reference    NUMBER := 0;
l_order_number             NUMBER;
l_line_id                  NUMBER := p_line_rec.line_id;
l_shipment_line_id         NUMBER := 0;
l_delivery                 NUMBER := -1;
l_to_org_id                NUMBER := -1;
l_location_id              NUMBER := 0;
l_req_line_id              NUMBER := 0;
l_unit_price               NUMBER;
l_concat_segs              VARCHAR2(2000);
l_concat_ids               VARCHAR2(2000);
l_concat_descrs            VARCHAR2(2000);
l_transaction_date         DATE;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_transaction_interface_id NUMBER := null;
l_transaction_header_id    NUMBER := p_transaction_header_id;
l_opm_item_id              NUMBER;
l_opm_item_no              VARCHAR2(32);
l_opm_item_um              VARCHAR2(5);
l_opm_trx_uom              VARCHAR2(5);
l_opm_lot_id               NUMBER;
l_opm_location             VARCHAR2(16);
l_opm_whse                 VARCHAR2(4);
l_exist                    NUMBER := 0;

Cursor get_opm_item_no IS
Select distinct segment1
From mtl_system_items
Where inventory_item_id = p_inventory_item_id
    and organization_id = p_warehouse_id;

Cursor get_opm_item_id IS
Select item_id, item_um
From ic_item_mst
Where item_no = l_opm_item_no;

Cursor get_opm_lot_id_sublot IS
Select lot_id
From ic_lots_mst
Where lot_no = p_lot_number
   And item_id = l_opm_item_id
   And lot_id <> 0
   And sublot_no = p_sublot_no;

Cursor get_opm_lot_id_no_sublot IS
Select lot_id
From ic_lots_mst
Where lot_no = p_lot_number
   And item_id = l_opm_item_id
   And lot_id <> 0
   And sublot_no is null;

Cursor get_opm_location IS
Select location
From ic_loct_mst
Where inventory_location_id = p_locator_id;

Cursor get_opm_whse IS
Select whse_code
From ic_whse_mst
Where mtl_organization_id = p_warehouse_id;

Cursor check_opm_inv IS
Select count(*)
From ic_tran_pnd
Where item_id = l_opm_item_id
   And lot_id = l_opm_lot_id
   And line_id = p_line_rec.line_id
   And doc_type = 'OMSO'
   And delete_mark = 0
   And completed_ind = 0;

Cursor check_opm_inv_default IS
Select count(*)
From ic_tran_pnd
Where item_id = l_opm_item_id
   And lot_id = 0
   And line_id = p_line_rec.line_id
   And doc_type = 'OMSO'
   And delete_mark = 0
   And completed_ind = 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING DECREMENT INVENTORY FOR OPM' ) ;
      oe_debug_pub.add(  ' P_LOT_NUMBER : ' || P_LOT_NUMBER , 1 ) ;
      oe_debug_pub.add(  ' P_INVENTORY_ITEM_ID : ' || P_INVENTORY_ITEM_ID , 1 ) ;
      oe_debug_pub.add(  ' P_ORGANIZATION_ID : ' || P_WAREHOUSE_ID , 1 ) ;
      oe_debug_pub.add(  ' P_TRX_UOM : ' || P_TRX_UOM , 1 ) ;
      oe_debug_pub.add(  ' P_CHART_OF_ACCTS : ' || P_CHART_OF_ACCTS , 1 ) ;
      oe_debug_pub.add(  ' P_AS_ALPHA_PREFIX : ' || P_AS_ALPHA_PREFIX , 1 ) ;
      oe_debug_pub.add(  ' P_SN_CONTROL_CODE : ' || P_SN_CONTROL_CODE , 1 ) ;
      oe_debug_pub.add(  ' P_TRANSACTION_ID : ' || P_TRANSACTION_ID , 1 ) ;
  END IF;

  profile_values.oe_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');

  /*
  ** Check For The Transaction Account
  */

/*  IF OE_FLEX_COGS_PUB.Start_Process (
      p_api_version_number    => 1.0,
      p_line_id               => p_line_rec.line_id,
      x_return_ccid           => l_trans_acc,
      x_concat_segs           => l_concat_segs,
      x_concat_ids            => l_concat_ids,
      x_concat_descrs         => l_concat_descrs,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data) <> FND_API.G_RET_STS_SUCCESS
  THEN */
     /* 1517431, If workflow fails to generate distribution acct,
	   populate as null */

/*	l_trans_acc := NULL;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TRANSACTION ACCOUNT ID ID : ' || L_TRANS_ACC , 1 ) ;
  END IF;

  l_trans_qty := p_trans_qty;
  /*OPM transactions in ic_tran_pnd

  Open get_opm_item_no;
  Fetch get_opm_item_no INTO l_opm_item_no;
  Close get_opm_item_no;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' P_OPM_ITEM_NO : ' || L_OPM_ITEM_NO , 1 ) ;
  END IF;

  Open get_opm_item_id;
  Fetch get_opm_item_id INTO l_opm_item_id, l_opm_item_um;
  Close get_opm_item_id;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' P_OPM_ITEM_ID : ' || L_OPM_ITEM_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' P_OPM_ITEM_UM : ' || L_OPM_ITEM_UM , 1 ) ;
  END IF;

  Open get_opm_whse;
  Fetch get_opm_whse INTO l_opm_whse;
  Close get_opm_whse;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' P_WAREHOUSE_ID : ' || L_OPM_WHSE , 1 ) ;
  END IF;

  l_opm_location := null;
  IF NVL(p_locator_id,0) <>0 THEN
    Open get_opm_location;
    Fetch get_opm_location INTO l_opm_location;
    Close get_opm_location;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' OPM_LOCATION : ' || L_OPM_LOCATION , 1 ) ;
  END IF;
  l_opm_lot_id := 0;
  IF (p_lot_number is not null) AND (p_sublot_no is not null) THEN
    Open get_opm_lot_id_sublot;
    Fetch get_opm_lot_id_sublot INTO l_opm_lot_id;
    Close get_opm_lot_id_sublot;
  ELSIF (p_lot_number is not null) THEN
    Open get_opm_lot_id_no_sublot;
    Fetch get_opm_lot_id_no_sublot INTO l_opm_lot_id;
    Close get_opm_lot_id_no_sublot;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' OPM_LOT_ID : ' || L_OPM_LOT_ID , 1 ) ;
  END IF;

  IF (p_lot_number is not null) THEN
    OPEN  check_opm_inv ;
    Fetch check_opm_inv INTO l_exist;
    CLOSE check_opm_inv;
  ELSE
    OPEN check_opm_inv_default ;
    Fetch check_opm_inv_default INTO l_exist;
    CLOSE check_opm_inv_default;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' L_EXIST : ' || L_EXIST , 1 ) ;
  END IF;

  GMI_RESERVATION_UTIL.Get_OPMUOM_from_AppsUOM(
          p_Apps_UOM                 => p_trx_uom
        , x_OPM_UOM                  => l_opm_trx_uom
        , x_return_status            => l_return_status
        , x_msg_count                => l_msg_count
        , x_msg_data                 => l_msg_data);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
     FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
     FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_trx_uom);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' OPM TRX UOM='||L_OPM_TRX_UOM||'.' , 1 ) ;
     END IF;
  END IF;
  IF l_opm_trx_uom <> l_opm_item_um THEN
  GMICUOM.icuomcv(pitem_id  => l_opm_item_id,
                  plot_id   => 0,
                  pcur_qty  => p_trans_qty,
                  pcur_uom  => p_trx_uom,
                  pnew_uom  => l_opm_trx_uom,
                  onew_qty  => l_trans_qty);
  END IF;

  IF nvl(l_exist,0) = 0 THEN
    GMI_RESERVATION_UTIL.create_transaction_for_rcv
    (
       p_whse_code     => l_opm_whse
     , p_transaction_id=> p_transaction_id
     , p_line_id       => p_line_rec.line_id
     , p_item_id       => l_opm_item_id
     , p_lot_id        => nvl(l_opm_lot_id,0)
     , p_location      => l_opm_location
     , p_qty1          => l_trans_qty
     , p_qty2          => p_trans_qty2
     , x_return_status => l_return_status
     , x_msg_count     => l_msg_count
     , x_msg_data      => l_msg_data
    ) ;
  END IF;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
              return_status='|| x_return_status||', x_msg_count='|| l_msg_count||'.');
     FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
     FND_MESSAGE.Set_Token('BY_PROC','OE_DROPSHIP_RCV.OPM_TRANSACTION');
     FND_MESSAGE.Set_Token('WHERE','Create_transaction');
     FND_MSG_PUB.Add;
     raise FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING DECREMENT INVENTORY' ) ;
  END IF;

END Decrement_Inventory_for_OPM; */

/*--------------------------------------------------------------+
Name          : Create_Reservation
Description   : This procedure will be called from Drop Ship
                Receive. This will call Inventory's Create
                reservation API to pu reservations on the order
                line and will return the reserved quantity.
Change Record :
+--------------------------------------------------------------*/

PROCEDURE Create_reservation
(p_qty_to_be_reserved  IN      NUMBER
,p_qty2_to_be_reserved  IN      NUMBER DEFAULT NULL --INVVCONV
,p_revision            IN      VARCHAR2
,p_locator_id          IN      NUMBER
,p_lot                 IN      VARCHAR2
,p_line_rec            IN      OE_ORDER_PUB.Line_Rec_Type
,x_qty_reserved        OUT     NOCOPY NUMBER
,x_qty2_reserved       OUT     NOCOPY NUMBER -- INVCONV
,x_rsv_id              OUT     NOCOPY NUMBER
,x_return_status       OUT     NOCOPY VARCHAR2
,p_transfer_lpn_id     IN      NUMBER -- 3544019
)IS

l_locator_id              NUMBER := 0;
l_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
l_quantity_reserved       NUMBER;
l_quantity2_reserved       NUMBER; -- INVCONV
l_qty2_to_be_reserved     NUMBER; --INVCONV
l_rsv_id                  NUMBER := 0;
l_sales_order_id          NUMBER;

l_msg_count               NUMBER;
l_msg_data                VARCHAR2(20000);

l_debug_level  CONSTANT   NUMBER := oe_debug_pub.g_debug_level;
l_return_status           VARCHAR2(1);

BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Populating inventory record before calling reservation ' , 1 ) ;
   END IF;

   -- Populate inventory record structure before calling reservation

   l_reservation_rec.reservation_id                := fnd_api.g_miss_num; -- cannot know
   l_reservation_rec.requirement_date              := p_line_rec.schedule_ship_date;
   l_reservation_rec.organization_id               := p_line_rec.ship_from_org_id;
   l_reservation_rec.inventory_item_id             := p_line_rec.inventory_item_id;
   l_reservation_rec.demand_source_type_id         := INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE;
   l_reservation_rec.demand_source_name            := NULL;

   -- Get demand_source_header_id from mtl_sales_orders

   l_sales_order_id := Get_mtl_sales_order_id(p_line_rec.header_id);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Sales Order ID  '||l_sales_order_id, 1 ) ;
   END IF;
    IF p_qty2_to_be_reserved = 0 then -- INVCONV
       l_qty2_to_be_reserved := NULL;
    else
       l_qty2_to_be_reserved := p_qty2_to_be_reserved;
    END IF;

    l_reservation_rec.demand_source_header_id      := l_sales_order_id;
    l_reservation_rec.demand_source_line_id        := p_line_rec.line_id;
    l_reservation_rec.demand_source_delivery       := NULL;
    l_reservation_rec.primary_uom_code             := NULL;
    l_reservation_rec.primary_uom_id               := NULL;
    l_reservation_rec.reservation_uom_code         := p_line_rec.order_quantity_uom;
    l_reservation_rec.reservation_uom_id           := NULL;
    l_reservation_rec.reservation_quantity         := p_qty_to_be_reserved;
    l_reservation_rec.secondary_uom_code           := p_line_rec.ordered_quantity_uom2; -- INVCONV 4066306
    l_reservation_rec.secondary_uom_id             := NULL;                             -- INVCONV 4066306
    l_reservation_rec.secondary_reservation_quantity := l_qty2_to_be_reserved; -- INVCONV
    l_reservation_rec.primary_reservation_quantity := NULL;
    l_reservation_rec.autodetail_group_id          := NULL;
    l_reservation_rec.external_source_code         := NULL;
    l_reservation_rec.external_source_line_id      := NULL;
    l_reservation_rec.supply_source_type_id        := INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INV;
    l_reservation_rec.supply_source_header_id      := NULL;
    l_reservation_rec.supply_source_line_id        := NULL;
    l_reservation_rec.supply_source_name           := NULL;
    l_reservation_rec.supply_source_line_detail    := NULL;
    l_reservation_rec.revision                     := p_revision;
    l_reservation_rec.subinventory_code            := p_line_rec.subinventory;
    l_reservation_rec.subinventory_id              := NULL;
    l_reservation_rec.locator_id                   := p_locator_id;
    l_reservation_rec.lot_number                   := p_lot;
    l_reservation_rec.lot_number_id                := NULL;
    l_reservation_rec.pick_slip_number             := NULL;
	-- for bug 3544019
    l_reservation_rec.lpn_id                       := p_transfer_lpn_id;
    l_reservation_rec.attribute_category           := NULL;
    l_reservation_rec.attribute1                   := NULL;  -- INVCONV 4066306
    l_reservation_rec.attribute2                   := NULL;  -- INVCONV 4066306
    l_reservation_rec.attribute3                   := NULL;  -- INVCONV 4066306
    l_reservation_rec.attribute4                   := NULL;
    l_reservation_rec.attribute5                   := NULL;
    l_reservation_rec.attribute6                   := NULL;
    l_reservation_rec.attribute7                   := NULL;
    l_reservation_rec.attribute8                   := NULL;
    l_reservation_rec.attribute9                   := NULL;
    l_reservation_rec.attribute10                  := NULL;
    l_reservation_rec.attribute11                  := NULL;
    l_reservation_rec.attribute12                  := NULL;
    l_reservation_rec.attribute13                  := NULL;
    l_reservation_rec.attribute14                  := NULL;
    l_reservation_rec.attribute15                  := NULL;
    l_reservation_rec.ship_ready_flag              := NULL;

    -- Call INV with action = RESERVE

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Calling clear cache' , 1 ) ;
    END IF;

    -- Inv_quantity_tree_grp.clear_quantity_cache;
    Inv_quantity_tree_pvt.mark_all_for_refresh
    (  p_api_version_number  => 1.0
     , p_init_msg_lst        => FND_API.G_TRUE
     , x_return_status       => l_return_status
     , x_msg_count           => l_msg_count
     , x_msg_data            => l_msg_data);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           oe_msg_pub.transfer_msg_stack;
           l_msg_count:=OE_MSG_PUB.COUNT_MSG;
           for I in 1..l_msg_count loop
               l_msg_data := OE_MSG_PUB.Get(I,'F');
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
               END IF;
           end loop;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            oe_msg_pub.transfer_msg_stack;
            l_msg_count:=OE_MSG_PUB.COUNT_MSG;
            for I in 1..l_msg_count loop
                l_msg_data := OE_MSG_PUB.Get(I,'F');
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
                END IF;
            end loop;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Calling inv to reserve quantity : ' || p_qty_to_be_reserved , 1 ) ;
        oe_debug_pub.add(  'Calling inv to reserve quantity2 : ' || p_qty2_to_be_reserved , 1 ) ;
    END IF;

    Inv_reservation_pub.create_reservation
                     (  p_api_version_number          => 1.0
                      , p_init_msg_lst              => FND_API.G_TRUE
                      , x_return_status             => l_return_status
                      , x_msg_count                 => l_msg_count
                      , x_msg_data                  => l_msg_data
                      , p_rsv_rec                   => l_reservation_rec
                      , p_serial_number             => l_dummy_sn
                      , x_serial_number             => l_dummy_sn
                      , p_partial_reservation_flag  => FND_API.G_FALSE
                      , p_force_reservation_flag    => FND_API.G_FALSE
                      , p_validation_flag           => FND_API.G_TRUE
                      , p_over_reservation_flag     => 2 -- bug 4864453
                      , x_quantity_reserved         => l_quantity_reserved
                      , x_secondary_quantity_reserved         => l_quantity2_reserved -- INVCONV
                      , x_reservation_id            => l_rsv_id
                      );

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Create reservation returns : ' || l_return_status , 1 ) ;
       oe_debug_pub.add(  l_msg_data , 1 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Reservation fails with unexpected error in dropshipreceive() : '||sqlerrm , 1 ) ;
          oe_debug_pub.add(  'Try receipt after setting sub/item non reservable' , 1 ) ;
       END IF;

       oe_msg_pub.transfer_msg_stack;
       l_msg_count:=OE_MSG_PUB.COUNT_MSG;
       for I in 1..l_msg_count loop
           l_msg_data := OE_MSG_PUB.Get(I,'F');
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_msg_data,1) ;
           END IF;
        end loop;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('reservation fails with expected error in dropshipreceive() : '||sqlerrm,1) ;
            oe_debug_pub.add(  'Try receipt after setting sub/item non reservable' , 1 ) ;
         END IF;
          oe_msg_pub.transfer_msg_stack;
          l_msg_count:=OE_MSG_PUB.COUNT_MSG;
          for I in 1..l_msg_count loop
              l_msg_data := OE_MSG_PUB.Get(I,'F');
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(l_msg_data,1) ;
              END IF;
          end loop;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Successfully reserved quantity => '||l_quantity_reserved,1) ;
      oe_debug_pub.add(  'Successfully reserved quantity2 => '||l_quantity2_reserved,1) ; -- INVCONV

     END IF;

     x_qty_reserved  := l_quantity_reserved;
     x_qty2_reserved  := l_quantity2_reserved; -- INVCONV
     x_rsv_id        := l_rsv_id;

     IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Exiting Create_Reservation ...',4);
     END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Expected Error in Create Reservation...',4);
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExpected Error in Create Reservation...'||sqlerrm,4);
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('When Others in Create Reservation...'||sqlerrm,4);
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Reservation;

-- bug 4393738
/* Dropship to call the Ship_Confirm_New */
/*--------------------------------------------------------------+
Name          : Call_Ship_Confirm_New
Description   : In R12 it was decided that dropship should call
                Ship_Confirm_New instead of the old Ship_Confirm API
+--------------------------------------------------------------*/
PROCEDURE Call_Ship_Confirm_New
(p_short_quantity         IN      NUMBER
,p_transaction_date       IN      DATE
,p_add_to_shipped         IN      NUMBER
,p_add_to_shipped2        IN      NUMBER
,p_line_rec               IN      OE_ORDER_PUB.Line_rec_Type
,x_return_status          OUT     NOCOPY VARCHAR2
,x_msg_count              OUT     NOCOPY NUMBER
,x_msg_data               OUT     NOCOPY VARCHAR2
)
IS
 l_ship_adj_line            OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type;
 l_non_bulk_req_line        OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
 l_non_bulk_ship_line       OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
 l_cal_tolerance_tbl        OE_Shipping_Integration_PUB.Cal_Tolerance_Tbl_Type;
 l_update_tolerance_flag    varchar2(1);
 l_new_tolerance_below      number;
 l_ship_beyond_flag         varchar2(1);
 l_fulfilled_flag           varchar2(1);
 l_proportion_broken_flag   varchar2(1);
 l_cal_tolr_return_status   varchar2(1);
 l_msg_count                number;
 l_msg_data                 VARCHAR2(20000);
 l_debug_level  CONSTANT    NUMBER := oe_debug_pub.g_debug_level;
 l_return_status            VARCHAR2(1);
BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('OEXVDSRB.pls: Inside Call_Ship_Confirm_New API',3);
  END IF;
  -- Extending the l_non_bulk_ship_line
  l_non_bulk_ship_line.fulfilled_flag.extend;
  l_non_bulk_ship_line.actual_shipment_date.extend;
  l_non_bulk_ship_line.shipping_quantity2.extend;
  l_non_bulk_ship_line.shipping_quantity.extend;
  l_non_bulk_ship_line.shipping_quantity_uom2.extend;
  l_non_bulk_ship_line.shipping_quantity_uom.extend;
  l_non_bulk_ship_line.line_id.extend;
  l_non_bulk_ship_line.header_id.extend;
  l_non_bulk_ship_line.top_model_line_id.extend;
  l_non_bulk_ship_line.ato_line_id.extend;
  l_non_bulk_ship_line.ship_set_id.extend;
  l_non_bulk_ship_line.arrival_set_id.extend;
  l_non_bulk_ship_line.inventory_item_id.extend;
  l_non_bulk_ship_line.ship_from_org_id.extend;
  l_non_bulk_ship_line.line_set_id.extend;
  l_non_bulk_ship_line.smc_flag.extend;
  l_non_bulk_ship_line.over_ship_reason_code.extend;
  l_non_bulk_ship_line.requested_quantity.extend;
  l_non_bulk_ship_line.requested_quantity2.extend;
  l_non_bulk_ship_line.pending_quantity.extend;
  l_non_bulk_ship_line.pending_quantity2.extend;
  l_non_bulk_ship_line.pending_requested_flag.extend;
  l_non_bulk_ship_line.order_quantity_uom.extend;
  l_non_bulk_ship_line.order_quantity_uom2.extend;
  l_non_bulk_ship_line.model_remnant_flag.extend;
  l_non_bulk_ship_line.ordered_quantity.extend;
  l_non_bulk_ship_line.ordered_quantity2.extend;
  l_non_bulk_ship_line.item_type_code.extend;
  l_non_bulk_ship_line.calculate_price_flag.extend;
  l_non_bulk_ship_line.source_type_code.extend; -- Added for bug 6877315

  IF (p_short_quantity > 0 ) THEN -- Partial receipt

    IF ((nvl(p_line_rec.ship_tolerance_above,0) > 0) OR
       (nvl(p_line_rec.ship_tolerance_below,0) > 0)) THEN -- tolerances specified

      l_cal_tolerance_tbl(1).line_id := p_line_rec.line_id;
      l_cal_tolerance_tbl(1).quantity_to_be_shipped := p_add_to_shipped;
      l_cal_tolerance_tbl(1).shipping_uom := p_line_rec.order_quantity_uom;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling OE_Shipping_Integration_PUB.Get_Tolerance to check the tolerances' ,3);
      END IF;

      OE_Shipping_Integration_PUB.Get_Tolerance(
           p_api_version_number       => 1.0,
           p_cal_tolerance_tbl        => l_cal_tolerance_tbl,
           x_update_tolerance_flag    => l_update_tolerance_flag,
           x_ship_tolerance           => l_new_tolerance_below,
           x_ship_beyond_tolerance    => l_ship_beyond_flag,
           x_shipped_within_tolerance => l_fulfilled_flag,
           x_config_broken            => l_proportion_broken_flag,
           x_return_status            => l_cal_tolr_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data);

      IF  l_cal_tolr_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_Shipping_Integration_PUB.Get_Tolerance returned Error', 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;

      -- If the qty received > the overship tolerance limit and the operation is
      -- to be restriced then the l_ship_beyond_flag = 'T' should be checked.

    ELSE -- Tolerance not specified and partial receipt hence line not fulfilled
       l_fulfilled_flag:='F';
    END IF;
  ELSE  -- full qty received , hence line fulfilled
    l_fulfilled_flag:='T';
  END IF;

  -- Populate the Non bulk ship line
  IF (NVL(l_fulfilled_flag, 'F') = 'T') THEN
    l_non_bulk_ship_line.fulfilled_flag(1):= 'Y';
  ELSE
    l_non_bulk_ship_line.fulfilled_flag(1):= 'N';
  END IF;
  l_non_bulk_ship_line.actual_shipment_date(1)   := p_transaction_date;
  l_non_bulk_ship_line.shipping_quantity2(1)     := p_add_to_shipped2;
  l_non_bulk_ship_line.shipping_quantity(1)      := p_add_to_shipped;
  l_non_bulk_ship_line.shipping_quantity_uom2(1) := p_line_rec.ordered_quantity_uom2;
  l_non_bulk_ship_line.shipping_quantity_uom(1)  := p_line_rec.order_quantity_uom;
  l_non_bulk_ship_line.line_id(1)                := p_line_rec.line_id;
  l_non_bulk_ship_line.header_id(1)              := p_line_rec.header_id;
  l_non_bulk_ship_line.top_model_line_id(1)      := p_line_rec.top_model_line_id;
  l_non_bulk_ship_line.ato_line_id(1)            := p_line_rec.ato_line_id;
  l_non_bulk_ship_line.ship_set_id(1)            := p_line_rec.ship_set_id;
  l_non_bulk_ship_line.arrival_set_id(1)         := p_line_rec.arrival_set_id;
  l_non_bulk_ship_line.inventory_item_id(1)      := p_line_rec.inventory_item_id;
  l_non_bulk_ship_line.ship_from_org_id(1)       := p_line_rec.ship_from_org_id;
  l_non_bulk_ship_line.line_set_id(1)            := p_line_rec.line_set_id;
  l_non_bulk_ship_line.smc_flag(1)               := p_line_rec.ship_model_complete_flag;
  l_non_bulk_ship_line.over_ship_reason_code(1)  := '0';
  l_non_bulk_ship_line.requested_quantity(1)     := p_add_to_shipped;
  l_non_bulk_ship_line.requested_quantity2(1)    := p_add_to_shipped2;
  l_non_bulk_ship_line.pending_quantity(1)       := NULL;
  l_non_bulk_ship_line.pending_quantity2(1)      := NULL;
  l_non_bulk_ship_line.pending_requested_flag(1) := NULL;
  l_non_bulk_ship_line.order_quantity_uom(1)     := p_line_rec.order_quantity_uom;
  l_non_bulk_ship_line.order_quantity_uom2(1)    := p_line_rec.ordered_quantity_uom2;
  l_non_bulk_ship_line.model_remnant_flag(1)     := p_line_rec.model_remnant_flag;
  l_non_bulk_ship_line.ordered_quantity(1)       := p_line_rec.ordered_quantity;
  l_non_bulk_ship_line.ordered_quantity2(1)      := p_line_rec.ordered_quantity2;
  l_non_bulk_ship_line.item_type_code(1)         := p_line_rec.item_type_code;
  l_non_bulk_ship_line.calculate_price_flag(1)   := p_line_rec.calculate_price_flag;
  l_non_bulk_ship_line.source_type_code(1)       := p_line_rec.source_type_code; -- Added for bug 6877315

  -- Calling Ship_confirm_new
  OE_Ship_Confirmation_Pub.Ship_Confirm_New
  ( P_ship_line_rec         => l_non_bulk_ship_line,
    P_requested_line_rec    => l_non_bulk_req_line,
    P_line_adj_rec          => l_ship_adj_line, -- not used in non_bulk_mode
    P_bulk_mode             => 'N',
    P_start_index           => 1, -- not used in non_bulk_mode
    P_end_index             => 1, -- not used in non_bulk_mode
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    x_return_status         => l_return_status);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXVDSRB.pls: OE_Ship_Confirmation_Pub.Ship_Confirm_New return_status='||l_return_status,3);
    END IF;

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

EXCEPTION
     WHEN OTHERS THEN
       x_return_status := l_return_status;
       x_msg_data      := l_msg_data;
       x_msg_count     := l_msg_count;
END Call_Ship_Confirm_New;

/*--------------------------------------------------------------+
Name          : Call_Process_Order
n_bulk_ship_line    OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
l_non_bulk_req_line     OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
Description   : This procedure will be called from Drop Ship
                Receive. This will call process order for
                updating shipped quantity on the order line
                and complete the ship line activity

Change Record :
+--------------------------------------------------------------*/

PROCEDURE Call_Process_Order
(p_orig_shipped           IN      NUMBER
,p_short_quantity         IN      NUMBER
,p_transaction_date       IN      DATE
,p_add_to_shipped         IN      NUMBER
,p_add_to_shipped2        IN      NUMBER
,p_line_rec               IN      OE_ORDER_PUB.Line_rec_Type
,x_return_status          OUT     NOCOPY VARCHAR2
)
IS
 -- Process Order arguments
 l_msg_count                 NUMBER;
 l_msg_data                  VARCHAR2(20000);

 l_control_rec               OE_GLOBALS.control_rec_type;
 l_line_tbl                  OE_ORDER_PUB.line_tbl_type;
 l_old_line_tbl              OE_ORDER_PUB.line_tbl_type;
 l_header_rec                OE_Order_PUB.Header_Rec_Type;
 l_new_line_rec              OE_Order_PUB.Line_Rec_Type;
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

 l_req_qty_tbl               OE_Ship_Confirmation_Pub.Req_Quantity_Tbl_Type;

 l_new_line_id               NUMBER;
 l_return_status             VARCHAR2(1);
 l_debug_level  CONSTANT     NUMBER := oe_debug_pub.g_debug_level;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
  -- tso
  l_top_container_model  Varchar2(1);
  l_part_of_container    Varchar2(1);

BEGIN

-- Bug 2312461: bypass the processing in OM if receiving has already been done once.

       IF (p_orig_shipped <> 0)  --one receipt already exists
       THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Receiving has already been done once. no processing in om' ) ;
           END IF;
       ELSE  --first receipt against this line

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Calling Call_Ship_Confirm_New API' , 1 ) ;
            END IF;

            -- Calling this new API, bug 4393738
            Call_Ship_Confirm_New
            (p_short_quantity   => p_short_quantity
            ,p_transaction_date => p_transaction_date
            ,p_add_to_shipped   => p_add_to_shipped
            ,p_add_to_shipped2  => p_add_to_shipped2
            ,p_line_rec         => p_line_rec
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('OEXVDSRB.pls: Call_Ship_Confirm_New returned unexpected error '||sqlerrm , 1 ) ;
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('OEXVDSRB.pls: Call_Ship_Confirm_New returned expected error '||sqlerrm , 1 ) ;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('OEXVDSRB.pls: After Call_Ship_Confirm_New, return_status='|| l_return_status,1) ;
            END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('OEXVDSRB.pls: Calling OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model...' , 5 ) ;
         END IF;

         -- TSO with Equipment, the non-shippable lines should have NULL shipped_quantity
         OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
        (p_line_id              =>  p_line_rec.line_id,
         p_top_model_line_id    =>  p_line_rec.top_model_line_id,
         x_top_container_model  =>  l_top_container_model,
         x_part_of_container    =>  l_part_of_container);

         IF l_part_of_container = 'Y' THEN

           UPDATE oe_order_lines_all
           SET    shipped_quantity = NULL
                 ,actual_shipment_date = NULL
                 ,lock_control     = lock_control + 1
           WHERE top_model_line_id = p_line_rec.top_model_line_id
             AND shippable_flag = 'N'
             AND shipped_quantity is not NULL;

           IF l_debug_level  > 0 AND
              SQL%FOUND THEN
             oe_debug_pub.add('Updated non-shippable lines of TSO ...',5);
           END IF;
         END IF;
         -- TSO with equipment ends

         IF ( p_short_quantity > 0 ) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('After call from process order api check if split has happened ' , 5 ) ;
            END IF;
            BEGIN
               SELECT max(line_id)
               INTO   l_new_line_id
               FROM   oe_order_lines_all
               WHERE  header_id = p_line_rec.header_id  --Bug2489150
                AND   split_from_line_id = p_line_rec.line_id
                AND   split_by = 'SYSTEM';     -- Bug-2437391
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Split line not found '||sqlerrm , 1 ) ;
                   END IF;
              WHEN OTHERS THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Unexpected: line not found '||sqlerrm , 1 ) ;
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            -- Bug2344242 added following if condition
            IF l_new_line_id is NOT NULL THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'Updating existing dropship record with new line '||l_new_line_id , 1 ) ;
                  END IF;

                  update oe_drop_ship_sources
                  set    line_id = l_new_line_id
                  where  line_id = p_line_rec.line_id;

                  insert_oe_drop_ship_source(p_line_rec.line_id, l_new_line_id);

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'After inserting drop ship source record ' , 5 ) ;
                  END IF;
            END IF;
         END IF;

       END IF; --one receipt already exists

       IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Exiting Call Process Order...',4);
       END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Expected Error in Call Process Order...',4);
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExpected Error in Call Process Order...'||sqlerrm,4);
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('When Others in Call Process Order...'||sqlerrm,4);
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Call_Process_Order;

------------------------------------------------------
--      *** Enhanced Dropshipments ***
------------------------------------------------------

/*--------------------------------------------------------------+
Name          : Check_Req_PO_Cancelled
Description   : This procedure will be used to check whether a
                Req or PO is cancelled or not. This will called
                before logging CMS delayed request. This will
                return true if req or PO is cancelled for a
                given line.

Change Record :
+--------------------------------------------------------------*/


FUNCTION Check_Req_PO_Cancelled
( p_line_id        IN    NUMBER
, p_header_id      IN    NUMBER
) RETURN BOOLEAN
IS
l_req_header_id         NUMBER;
l_po_header_id          NUMBER;
l_req_dsp               VARCHAR2(240);
l_req_err               VARCHAR2(240);
--l_po_status             VARCHAR2(4100);
l_req_status            VARCHAR2(4100);
--bug 4411054
l_po_status_rec         PO_STATUS_REC_TYPE;
l_return_status         VARCHAR2(1);
l_cancel_flag           VARCHAR2(1);
l_closed_code           VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_po_release_id         NUMBER; -- bug 5328526

BEGIN

  IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Entering Check_Req_PO_Cancelled.. ',1);
  END IF;

  SELECT  requisition_header_id, po_header_id, po_release_id
    INTO  l_req_header_id,l_po_header_id, l_po_release_id --bug 5328526
    FROM  oe_drop_ship_sources
   WHERE  line_id    = p_line_id
     AND  header_id  = p_header_id;

  IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Requisition:'||l_req_header_id||
                         ' PO:'||l_po_header_id||
                         ' PO Release:'||l_po_release_id,1);
  END IF;

  IF l_req_header_id is not null THEN

     l_req_status := PO_RELEASES_SV2.Get_Release_Status
                                    ( x_po_release_id => l_req_header_id
                                    );
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Requisition Status - '|| l_req_status, 3);
     END IF;

     IF l_req_status is null THEN
        PO_REQS_SV2.Get_Reqs_Auth_Status
                   (x_req_header_id              => l_req_header_id
                   ,x_req_header_auth_status     => l_req_status
                   ,x_req_header_auth_status_dsp => l_req_dsp
                   ,x_req_control_error_rc       => l_req_err
                   );

        l_req_status := UPPER(l_req_status);
     END IF;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('After Requisition Auth Status - '|| l_req_status, 3);
     END IF;

  END IF;


  IF l_po_header_id is not null THEN

     -- comment out for bug 4411054
     /*l_po_status := UPPER(PO_HEADERS_SV3.Get_PO_Status
                                        (x_po_header_id => l_po_header_id
                                        ));

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('PO Status : '|| l_po_status, 2);
     END IF;
     */
     PO_DOCUMENT_CHECKS_GRP.po_status_check
                                (p_api_version => 1.0
                                , p_header_id => l_po_header_id
                                , p_release_id => l_po_release_id --bug 5328526
                                , p_mode => 'GET_STATUS'
                                , x_po_status_rec => l_po_status_rec
                                , x_return_status => l_return_status);
    IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       l_cancel_flag := l_po_status_rec.cancel_flag(1);
       l_closed_code := l_po_status_rec.closed_code(1);
       IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Sucess call from PO_DOCUMENT_CHECKS_GRP.po_status_check',2);
            OE_DEBUG_PUB.Add('Cancel_flag : '|| l_cancel_flag, 2);
            OE_DEBUG_PUB.Add('Closed_code : '|| l_closed_code,2);
       END IF;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF  l_req_header_id is not null OR
          l_po_header_id is not null THEN

      IF (INSTR(nvl(l_req_status,'z'), 'CANCELLED') > 0 AND
          INSTR(nvl(l_req_status,'z'), 'FINALLY CLOSED') > 0) OR
         --(INSTR(nvl(l_po_status, 'z'), 'CANCELLED') > 0 AND
         -- INSTR(nvl(l_po_status, 'z'), 'FINALLY CLOSED') > 0) THEN
         (nvl(l_cancel_flag,'z')='Y' AND
         nvl(l_closed_code, 'z')= 'FINALLY CLOSED' ) THEN

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Requisition or PO is cancelled',1);
         END IF;

         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

  END IF;

  RETURN FALSE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('No Data Found in Check_Req_PO_Cancelled', 4);
         END IF;
         RETURN FALSE;
    WHEN OTHERS THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('When Others in Check_Req_PO_Cancelled'|| sqlerrm, 3);
         END IF;
         RETURN FALSE;
END Check_Req_PO_Cancelled;

/*--------------------------------------------------------------+
Name          :  Check_PO_Approved
Description   :  This procedure will be used in constraints
                 frame work and will be used to check whether a
                 PO is approved or not. For a given line id
                 get the po header id and call the PO API to
                 get the status. If it is approved return
                 true else false.
Change Record :
+--------------------------------------------------------------*/

Procedure Check_PO_Approved
( p_application_id               IN   NUMBER
, p_entity_short_name            IN   VARCHAR2
, p_validation_entity_short_name IN   VARCHAR2
, p_validation_tmplt_short_name  IN   VARCHAR2
, p_record_set_tmplt_short_name  IN   VARCHAR2
, p_scope                        IN   VARCHAR2
, p_result                       OUT NOCOPY /* file.sql.39 change */  NUMBER
)
IS

l_line_id          NUMBER := oe_line_security.g_record.line_id;
l_header_id        NUMBER := oe_line_security.g_record.header_id;
l_ato_line_id      NUMBER := oe_line_security.g_record.ato_line_id;
l_item_type_code   VARCHAR2(30) := oe_line_security.g_record.item_type_code;
l_source_type_code VARCHAR2(30) := oe_line_security.g_record.source_type_code;
l_operation        VARCHAR2(30) := oe_line_security.g_record.operation;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_po_header_id          NUMBER;
--bug 4411054
--l_po_status             VARCHAR2(4100);
l_po_status_rec         PO_STATUS_REC_TYPE;
l_return_status         VARCHAR2(1);
l_autorization_status   VARCHAR2(30);
l_po_release_id         NUMBER; -- bug 5328526

BEGIN

     p_result := 0;

     IF NVL(l_line_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
        RETURN;
     END IF;

     IF l_source_type_code <> 'EXTERNAL' OR
          NVL(l_source_type_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
        RETURN;
     END IF;

     IF (l_ato_line_id IS NOT NULL  AND
            l_ato_line_id <> FND_API.G_MISS_NUM) AND
           NOT (l_item_type_code in('OPTION','STANDARD') AND
                        l_ato_line_id =  l_line_id )  THEN

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('Line part of a ATO Model: '||l_ato_line_id, 2);
        END IF;

        SELECT  po_header_id, po_release_id
          INTO  l_po_header_id, l_po_release_id --bug 5328526
          FROM  oe_drop_ship_sources ds,oe_order_lines l
         WHERE  ds.header_id      = l_header_id
           AND  l.item_type_code  = 'CONFIG'
           AND  l.line_id         = ds.line_id
           AND  l.ato_line_id     = l_ato_line_id;

     ELSE

        IF (l_operation IS NOT NULL AND
               l_operation  <> FND_API.G_MISS_CHAR) AND
                   l_operation <> OE_GLOBALS.G_OPR_CREATE THEN

           SELECT  po_header_id, po_release_id
             INTO  l_po_header_id, l_po_release_id --bug 5328526
             FROM  oe_drop_ship_sources
            WHERE  line_id    = l_line_id
              AND  header_id  = l_header_id;
        END IF;

     END IF;

     IF l_po_header_id is not null THEN

        -- comment out for bug 4411054
        /*l_po_status := UPPER(PO_HEADERS_SV3.Get_PO_Status
                                        (x_po_header_id => l_po_header_id
                                        ));

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('Check PO Status : '|| l_po_status, 2);
        END IF;
        */

        PO_DOCUMENT_CHECKS_GRP.po_status_check
                                (p_api_version => 1.0
                                , p_header_id => l_po_header_id
                                , p_release_id => l_po_release_id --bug 5328526
                                , p_mode => 'GET_STATUS'
                                , x_po_status_rec => l_po_status_rec
                                , x_return_status => l_return_status);

        IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             l_autorization_status := l_po_status_rec.authorization_status(1);

             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('Sucess call from PO_DOCUMENT_CHECKS_GRP.po_status_check',2);
                OE_DEBUG_PUB.Add('Check PO Status : '|| l_autorization_status, 2);
             END IF;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     --IF (INSTR(nvl(l_po_status,'z'), 'APPROVED') <> 0 ) THEN
     IF(nvl(l_autorization_status,'z')= 'APPROVED')  THEN
          p_result := 1;
     ELSE
          p_result := 0;

     END IF;



EXCEPTION
     WHEN NO_DATA_FOUND THEN
         p_result := 0;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('No Data Found in Check_PO_Approved', 4);
         END IF;
     WHEN OTHERS THEN
         p_result := 1;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('When Others in Check_PO_Approved', 4);
         END IF;

End Check_PO_Approved;

/*--------------------------------------------------------------+
Name          :  OM_PO_Discrepancy_Exists
Description   :  This procedure will be used in constraints
                 frame work and will be used to check whether
                 there is any existing discrepancy between OM and PO
Change Record :
+--------------------------------------------------------------*/

Procedure OM_PO_Discrepancy_Exists
( p_application_id               IN   NUMBER
, p_entity_short_name            IN   VARCHAR2
, p_validation_entity_short_name IN   VARCHAR2
, p_validation_tmplt_short_name  IN   VARCHAR2
, p_record_set_tmplt_short_name  IN   VARCHAR2
, p_scope                        IN   VARCHAR2
, p_result                       OUT NOCOPY /* file.sql.39 change */  NUMBER
)
IS
l_line_id        NUMBER := oe_line_security.g_record.line_id;
l_header_id      NUMBER := oe_line_security.g_record.header_id;
l_drop_ship_flag VARCHAR2(1);
l_source_type_code VARCHAR2(10) := oe_line_security.g_record.source_type_code;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

    p_result := 0;

    IF NVL(l_line_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
       RETURN;
    END IF;

    IF l_source_type_code <> 'EXTERNAL' OR
         NVL(l_source_type_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
       RETURN;
    END IF;


    SELECT drop_ship_flag
    INTO   l_drop_ship_flag
    FROM   oe_drop_ship_sources l,po_requisition_lines_all rl
    WHERE  l.line_id              = l_line_id
    AND    l.header_id            = l_header_id
    AND    l.requisition_line_id  = rl.requisition_line_id;

    IF NVL(l_drop_ship_flag,'X') = 'X' THEN

       p_result := 0;

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('OM PO Discrepancy Exists', 4);
       END IF;
    ELSE
       p_result := 1;

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('No Discrepancy Exisits', 4);
       END IF;
    END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         p_result := 0;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('No Data Found in OM_PO_Discrepancy_Exists', 4);
         END IF;
     WHEN OTHERS THEN
         p_result := 1;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('When Others in OM_PO_Discrepancy_Exists', 4);
         END IF;
END OM_PO_Discrepancy_Exists;

END OE_DS_PVT;

/

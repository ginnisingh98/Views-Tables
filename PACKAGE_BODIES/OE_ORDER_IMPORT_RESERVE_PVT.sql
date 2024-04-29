--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_RESERVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_RESERVE_PVT" AS
/* $Header: OEXVIMRB.pls 120.3.12010000.2 2008/11/13 15:07:11 vmachett ship $ */

/*
---------------------------------------------------------------
--  Start of Comments
--  API name    OE_ORDER_IMPORT_RESERVE_PVT
--  Type        Private
--  Purpose  	Inventory Reservation
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes:
--
--  End of Comments
------------------------------------------------------------------
*/

/* ------------------------------------------------------------------
   Procedure: Reserve_Inventory
   ------------------------------------------------------------------
*/
G_ORDER_NUMBER          NUMBER;
G_ORIG_SYS_DOCUMENT_REF VARCHAR2(50);
PROCEDURE Reserve_Inventory (
   p_header_rec                 IN  OE_Order_Pub.Header_Rec_Type
  ,p_line_tbl                   IN  OE_Order_Pub.Line_Tbl_Type
  ,p_reservation_tbl		IN  OE_Order_Pub.Reservation_Tbl_Type
  ,p_header_val_rec             IN  OE_Order_Pub.Header_Val_Rec_Type
  ,p_line_val_tbl               IN  OE_Order_Pub.Line_Val_Tbl_Type
  ,p_reservation_val_tbl	IN  OE_Order_Pub.Reservation_Val_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

) IS
   l_header_rec                 OE_Order_Pub.Header_Rec_Type;
   l_line_tbl                   OE_Order_Pub.Line_Tbl_Type;
   l_reservation_tbl		OE_Order_Pub.Reservation_Tbl_Type;
   l_header_val_rec             OE_Order_Pub.Header_Val_Rec_Type;
   l_line_val_tbl               OE_Order_Pub.Line_Val_Tbl_Type;
   l_reservation_val_tbl	OE_Order_Pub.Reservation_Val_Tbl_Type;

   mtl_res_rec   		INV_RESERVATION_GLOBAL.mtl_reservation_rec_type;

   l_mtl_sales_order_id		NUMBER;
   l_reservation_id		     NUMBER;
   l_qty_already_rsv_loop     NUMBER := 0;
   l_qty_already_rsv_global   NUMBER := 0;
   l_qty_to_reserve           NUMBER := 0;
   l_msg_count			     NUMBER;
   l_msg_data			     VARCHAR2(2000);
   l_return_status		     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_reservable_type    NUMBER;
-- INVCONV

	 l_qty2_already_rsv_loop     NUMBER := 0;
   l_qty2_already_rsv_global   NUMBER := 0;
   l_qty2_to_reserve           NUMBER := 0;


   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   l_header_rec                 := p_header_rec;
   l_line_tbl                   := p_line_tbl;
   l_reservation_tbl            := p_reservation_tbl;
   l_header_val_rec             := p_header_val_rec;
   l_line_val_tbl               := p_line_val_tbl;
   l_reservation_val_tbl        := p_reservation_val_tbl;
   G_ORDER_NUMBER               := l_header_rec.order_number;
   G_ORIG_SYS_DOCUMENT_REF      := l_header_rec.orig_sys_document_ref;

   p_return_status		:= l_return_status;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE RESERVATION' ) ;
   END IF;

   FOR I in 1..l_reservation_tbl.count
   LOOP
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADER_ID: '|| L_HEADER_REC.HEADER_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE_ID: '|| L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .LINE_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ORG_ID: '|| L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .ORG_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'REQUEST_DATE: '|| L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .REQUEST_DATE ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ORD_QTY_UOM: '|| L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .ORDER_QUANTITY_UOM ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ORD_QTY: '|| L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .ORDERED_QUANTITY ) ;
     END IF;
-- Following code can be removed yet to confirm with old release
--   IF (nvl(l_reservation_tbl(I).revision,            FND_API.G_MISS_CHAR)
--				    <> FND_API.G_MISS_CHAR OR
--       nvl(l_reservation_tbl(I).lot_number_id,       FND_API.G_MISS_NUM)
--				    <> FND_API.G_MISS_NUM  OR
--       nvl(l_reservation_val_tbl(I).lot_number,      FND_API.G_MISS_CHAR)
--				    <> FND_API.G_MISS_CHAR OR
--       nvl(l_reservation_tbl(I).subinventory_id,     FND_API.G_MISS_NUM)
--				    <> FND_API.G_MISS_NUM  OR
--       nvl(l_reservation_val_tbl(I).subinventory_code, FND_API.G_MISS_CHAR)
--				    <> FND_API.G_MISS_CHAR OR
--       nvl(l_reservation_tbl(I).locator_id,          FND_API.G_MISS_NUM)
--			            <> FND_API.G_MISS_NUM)
-- Upto Here
-- Changed following line AND to IF
--  AND (l_reservation_tbl(I).quantity               > 0)
    IF  (l_reservation_tbl(I).quantity               > 0)

    AND  nvl(l_header_rec.header_id, FND_API.G_MISS_NUM)  <> FND_API.G_MISS_NUM
    AND  nvl(l_line_tbl(l_reservation_tbl(I).line_index).line_id,
				     FND_API.G_MISS_NUM)  <> FND_API.G_MISS_NUM
    -- This condition is removed for the bug 1579224 --
    -- Single Org installation ------------------------
    -- AND  nvl(l_line_tbl(l_reservation_tbl(I).line_index).org_id,
    --                      FND_API.G_MISS_NUM)  <> FND_API.G_MISS_NUM
    -- This condition is changed for the bug 1817012 --
    -- The check should be done with the schedule_ship_date
    -- Also check for the Null condition during testing
    -- AND  nvl(l_line_tbl(l_reservation_tbl(I).line_index).request_date,
    --                      FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE
    AND  nvl(l_line_tbl(l_reservation_tbl(I).line_index).schedule_ship_date,
				     FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE
    AND  nvl(l_line_tbl(l_reservation_tbl(I).line_index).order_quantity_uom,
				     FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
     THEN
     BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE SETTING RESERVATION PARAMETERS' ) ;
         END IF;


IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'REVISION: ' || L_RESERVATION_TBL ( I ) .REVISION ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LOT_NUMBER_ID: ' || L_RESERVATION_TBL ( I ) .LOT_NUMBER_ID ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LOT_NUMBER: ' || L_RESERVATION_VAL_TBL ( I ) .LOT_NUMBER ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SUBINVENTORY_ID: ' || L_RESERVATION_TBL ( I ) .SUBINVENTORY_ID ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SUBINVENTORY_CODE: '|| L_RESERVATION_VAL_TBL ( I ) .SUBINVENTORY_CODE ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LOCATOR_ID: ' || L_RESERVATION_TBL ( I ) .LOCATOR_ID ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'QUANTITY: ' || L_RESERVATION_TBL ( I ) .QUANTITY ) ;
END IF;


--      Get demand_source_header_id from mtl_sales_orders
        --4504362
          l_mtl_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(l_reservation_tbl(I).line_index).header_id);

         mtl_res_rec.reservation_id               := NULL;
         -- This condition is changed for the bug 1817012 --
         -- The check should be done with the schedule_ship_date
         -- mtl_res_rec.requirement_date          := l_line_tbl(l_reservation_tbl(I).line_index).request_date;
         mtl_res_rec.requirement_date             := l_line_tbl(l_reservation_tbl(I).line_index).schedule_ship_date;
         mtl_res_rec.organization_id              := l_line_tbl(l_reservation_tbl(I).line_index).ship_from_org_id;
         mtl_res_rec.inventory_item_id            := l_line_tbl(l_reservation_tbl(I).line_index).inventory_item_id;
-- aksingh this change made on 07/28/00 after 11i2
      If l_line_tbl(l_reservation_tbl(I).line_index).order_source_id = 10 then
         mtl_res_rec.demand_source_type_id        :=
 	     INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD; -- Internal Order
      else
         mtl_res_rec.demand_source_type_id        :=
 	     INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE; -- Order Entry
      end if;
	 mtl_res_rec.demand_source_name           := NULL;
	 mtl_res_rec.demand_source_header_id      := l_mtl_sales_order_id;
  	 mtl_res_rec.demand_source_line_id        := l_line_tbl(l_reservation_tbl(I).line_index).line_id;
-- bug# 1244758  	 mtl_res_rec.demand_source_delivery       := l_line_tbl(l_reservation_tbl(I).line_index).line_id;
      mtl_res_rec.demand_source_delivery       := NULL;
	 mtl_res_rec.primary_uom_code             := NULL;
	 mtl_res_rec.primary_uom_id               := NULL;
   	 mtl_res_rec.reservation_uom_code         := l_line_tbl(l_reservation_tbl(I).line_index).order_quantity_uom;
	 mtl_res_rec.reservation_uom_id           := NULL;
  	 mtl_res_rec.reservation_quantity         := l_reservation_tbl(I).quantity;
	 mtl_res_rec.primary_reservation_quantity := NULL;
	 mtl_res_rec.autodetail_group_id          := NULL;
	 mtl_res_rec.external_source_code         := NULL;
	 mtl_res_rec.external_source_line_id      := NULL;
	 mtl_res_rec.supply_source_type_id        :=
	             INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INV;
	 mtl_res_rec.supply_source_header_id      := NULL;
	 mtl_res_rec.supply_source_line_id        := NULL;
	 mtl_res_rec.supply_source_name           := NULL;
	 mtl_res_rec.supply_source_line_detail    := NULL;
	 mtl_res_rec.revision           := l_reservation_tbl(I).revision;
	 mtl_res_rec.subinventory_code	:= l_reservation_val_tbl(I).subinventory_code;
  	 mtl_res_rec.subinventory_id    := l_reservation_tbl(I).subinventory_id;
  	 mtl_res_rec.locator_id         := l_reservation_tbl(I).locator_id;
	 mtl_res_rec.lot_number         := l_reservation_val_tbl(I).lot_number;
  	 mtl_res_rec.lot_number_id      := l_reservation_tbl(I).lot_number_id;
	 mtl_res_rec.ship_ready_flag    := 2;
	 mtl_res_rec.pick_slip_number   := NULL;
	 mtl_res_rec.lpn_id             := NULL;
	 mtl_res_rec.attribute_category	:= l_reservation_tbl(I).attribute_category;
	 mtl_res_rec.attribute1         := l_reservation_tbl(I).attribute1;
	 mtl_res_rec.attribute2         := l_reservation_tbl(I).attribute2;
	 mtl_res_rec.attribute3         := l_reservation_tbl(I).attribute3;
	 mtl_res_rec.attribute4         := l_reservation_tbl(I).attribute4;
	 mtl_res_rec.attribute5         := l_reservation_tbl(I).attribute5;
	 mtl_res_rec.attribute6         := l_reservation_tbl(I).attribute6;
	 mtl_res_rec.attribute7         := l_reservation_tbl(I).attribute7;
	 mtl_res_rec.attribute8         := l_reservation_tbl(I).attribute8;
	 mtl_res_rec.attribute9         := l_reservation_tbl(I).attribute9;
	 mtl_res_rec.attribute10        := l_reservation_tbl(I).attribute10;
	 mtl_res_rec.attribute11        := l_reservation_tbl(I).attribute11;
	 mtl_res_rec.attribute12        := l_reservation_tbl(I).attribute12;
	 mtl_res_rec.attribute13        := l_reservation_tbl(I).attribute13;
	 mtl_res_rec.attribute14        := l_reservation_tbl(I).attribute14;
	 mtl_res_rec.attribute15        := l_reservation_tbl(I).attribute15;

-- aksingh for the bug# 1537689 and bug# 1661359
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DEMAND_SOURCE_HEADER_ID: '|| TO_CHAR ( L_HEADER_REC.HEADER_ID ) ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DEMAND_SOURCE_LINE_ID: ' || TO_CHAR ( L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .LINE_ID ) ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ORG_ID: ' || TO_CHAR ( L_LINE_TBL ( L_RESERVATION_TBL ( I ) .LINE_INDEX ) .ORG_ID ) ) ;
          END IF;
      l_qty_already_rsv_loop := 0;
      l_qty_to_reserve := 0;
      -- INVCONV
      l_qty2_already_rsv_loop := 0;
      l_qty2_to_reserve := 0;


-- bug1817012, ask if scheduling put the data on line record for reserved
-- quantity, then this call can be avoided.
      -- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     	OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id => l_header_rec.header_id)
                                              ,p_line_id   => l_line_tbl(l_reservation_tbl(I).line_index).line_id
                                              ,p_org_id    => l_line_tbl(l_reservation_tbl(I).line_index).org_id
                                              ,x_reserved_quantity =>  l_qty_already_rsv_loop
                                              ,x_reserved_quantity2 => l_qty2_already_rsv_loop
																							);

      /*l_qty_already_rsv_loop := OE_LINE_UTIL.get_reserved_quantity
          (p_header_id => OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id => l_header_rec.header_id),
           p_line_id   => l_line_tbl(l_reservation_tbl(I).line_index).line_id,
           p_org_id    => l_line_tbl(l_reservation_tbl(I).line_index).org_id); */

      l_qty_already_rsv_loop := nvl(l_qty_already_rsv_loop, 0);

-- INVCONV
      /*l_qty2_already_rsv_loop := OE_LINE_UTIL.get_reserved_quantity2
          (p_header_id => OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id => l_header_rec.header_id),
           p_line_id   => l_line_tbl(l_reservation_tbl(I).line_index).line_id,
           p_org_id    => l_line_tbl(l_reservation_tbl(I).line_index).org_id); */


      l_qty2_already_rsv_loop := nvl(l_qty2_already_rsv_loop, 0);

-- bug1817012, Check the l_qty_already_rsv_loop, At this stage for
-- reservation done during the scheduling, if it is reserved and there
-- are some additional information about the lot,subinv or something
-- we have to unreserve and re-reserve otherwise if no additional information
-- then we will leave the reservation as it is.
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'L_QTY_ALREADY_RSV_LOOP: ' || L_QTY_ALREADY_RSV_LOOP ) ;
          oe_debug_pub.add(  'L_QTY2_ALREADY_RSV_LOOP: ' || L_QTY2_ALREADY_RSV_LOOP ) ;
      END IF;

         --check

      if(I>1) then

         if (l_qty_already_rsv_loop >0 AND (l_reservation_tbl(I).line_index <> l_reservation_tbl(I-1).line_index) ) then
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'I>2' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CALLING UNRESERVE_LINE' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RESERVED_QUANTITY ' ||L_QTY_ALREADY_RSV_LOOP ) ;
							 oe_debug_pub.add(  'RESERVED_QUANTITY2 ' ||L_QTY2_ALREADY_RSV_LOOP ) ;
           END IF;

           IF l_qty2_already_rsv_loop = 0  -- INVCONV PAL
  								THEN
     							-- Currently setting the reserved2 quantity to null if it is zero.
     								l_qty2_already_rsv_loop := null;
  			   END IF;


           -- 4504362

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE CALLING OE_SCHEDULE_UTIL' ) ;
             END IF;
             --NULL; -- invconv inserted just for compile need to add qty2
              OE_SCHEDULE_UTIL.Unreserve_Line( p_line_rec => l_line_tbl(l_reservation_tbl(I).line_index),
              p_quantity_to_unreserve  => l_qty_already_rsv_loop,
               p_quantity2_to_unreserve  => l_qty2_already_rsv_loop, -- INVCONV
              x_return_status          => l_return_status);


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'AFTER CALLING UNRESERVE_LINE' ) ;
           END IF;

         end if;

      else
         if (l_qty_already_rsv_loop >0) then
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'I=1' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CALLING UNRESERVE_LINE' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RESERVED_QUANTITY ' ||L_QTY_ALREADY_RSV_LOOP ) ;
               oe_debug_pub.add(  'RESERVED2_QUANTITY ' ||L_QTY2_ALREADY_RSV_LOOP ) ;
           END IF;

           --4504362

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE CALLING OE_SCHEDULE_UTIL' ) ;
             END IF;
             OE_SCHEDULE_UTIL.Unreserve_Line(p_line_rec =>l_line_tbl(l_reservation_tbl(I).line_index),
              p_quantity_to_unreserve  => l_qty_already_rsv_loop,
              p_quantity2_to_unreserve  =>l_qty2_already_rsv_loop, -- INVCONV
             x_return_status          => l_return_status);


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'AFTER CALLING UNRESERVE_LINE' ) ;
           END IF;

         end if;

      end if;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CHECK' ) ;
     END IF;

      -- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     	OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id => l_header_rec.header_id)
                                              ,p_line_id   => l_line_tbl(l_reservation_tbl(I).line_index).line_id
                                              ,p_org_id    => l_line_tbl(l_reservation_tbl(I).line_index).org_id
                                              ,x_reserved_quantity =>  l_qty_already_rsv_loop
                                              ,x_reserved_quantity2 => l_qty2_already_rsv_loop
																							);



     /*l_qty_already_rsv_loop := OE_LINE_UTIL.get_reserved_quantity
          (p_header_id => OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id => l_header_rec.header_id),
           p_line_id   => l_line_tbl(l_reservation_tbl(I).line_index).line_id,
           p_org_id    => l_line_tbl(l_reservation_tbl(I).line_index).org_id); */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_QTY_ALREADY_RSV_LOOP'||L_QTY_ALREADY_RSV_LOOP ) ;
     END IF;
-- INVCONV
			/*l_qty2_already_rsv_loop := OE_LINE_UTIL.get_reserved_quantity2
          (p_header_id => OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id => l_header_rec.header_id),
           p_line_id   => l_line_tbl(l_reservation_tbl(I).line_index).line_id,
           p_org_id    => l_line_tbl(l_reservation_tbl(I).line_index).org_id); */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_QTY2_ALREADY_RSV_LOOP'||L_QTY2_ALREADY_RSV_LOOP ) ;
     END IF;


     l_qty_to_reserve :=
        l_line_tbl(l_reservation_tbl(I).line_index).ordered_quantity -
        l_qty_already_rsv_loop;

-- INVCONV
     l_qty2_to_reserve :=
        l_line_tbl(l_reservation_tbl(I).line_index).ordered_quantity2 -
        NVL(l_qty2_already_rsv_loop,0);

    IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_QTY_TO_RESERVE'||L_QTY_TO_RESERVE ) ;
         oe_debug_pub.add(  'L_QTY2_TO_RESERVE'||L_QTY2_TO_RESERVE ) ;
     END IF;


       IF (l_qty_to_reserve-l_reservation_tbl(I).quantity < 0)
       THEN

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
         OE_MSG_PUB.Add;
         --p_return_status := FND_API.G_RET_STS_ERROR;
         --EXIT;
         goto next_rec_rsrv;
       END IF;

-- end aksingh for the bug# 1537689 and bug# 1661359



      SELECT RESERVABLE_TYPE
      INTO   l_reservable_type
      FROM   MTL_SYSTEM_ITEMS
      WHERE  INVENTORY_ITEM_ID = l_line_tbl(l_reservation_tbl(I).line_index).inventory_item_id
      AND ORGANIZATION_ID = l_line_tbl(l_reservation_tbl(I).line_index).ship_from_org_id;



      IF l_reservation_tbl(I).operation in ('CREATE', 'INSERT') AND
         l_qty_to_reserve-l_reservation_tbl(I).quantity >= 0
      THEN

        IF(nvl(l_line_tbl(l_reservation_tbl(I).line_index).shippable_flag, 'N') = 'Y' and l_reservable_type =1) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BEFORE CALLING CREATE_RESERVATION' ) ;
          END IF;
                Create_Reservation (
        	    p_rsv       	=> mtl_res_rec
	           ,p_rsv_id    	=> l_reservation_id
	           ,p_msg_count 	=> l_msg_count
	           ,p_msg_data  	=> l_msg_data
	           ,p_return_status	=> l_return_status);
        END IF;
      END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING CREATE_RESERVATION' ) ;
         END IF;

      	 IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
         AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			             FND_API.G_RET_STS_UNEXP_ERROR)
         THEN
             p_return_status := l_return_status;
         END IF;

     EXCEPTION
     WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN RESERVE_INVENTORY: '||SQLERRM ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Reserve_Inventory');
      END IF;

     END;

     END IF;

   <<Next_Rec_Rsrv>>
     Null;
   END LOOP;

END Reserve_Inventory;


/* ------------------------------------------------------------------
   Procedure: Create_Reservation
   ------------------------------------------------------------------
*/

PROCEDURE Create_Reservation (
   p_rsv       		IN  INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
,p_rsv_id OUT NOCOPY NUMBER

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2

)
IS
   l_rsv       		INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE :=p_rsv;
   l_dummy_sn  		INV_RESERVATION_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
   l_rsv_id    		NUMBER;
   l_rsv_qty    	NUMBER;
	 l_rsv_qty2    	NUMBER; -- INVCONV
   l_msg_index 		NUMBER;
   l_msg_count 		NUMBER;
   l_msg_data  		VARCHAR2(240);
   l_return_status 	VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
        --Start of Bug#7564285
	l_rsv.secondary_reservation_quantity   := NULL;
	l_rsv.secondary_uom_code := NULL;
	l_rsv.secondary_uom_id := NULL;			--End of Bug#7564285

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING RESERVATIONS API' ) ;
	END IF;

	INV_RESERVATION_PUB.Create_Reservation (
	 	 p_api_version_number        => 1.0
		,p_init_msg_lst              => FND_API.G_TRUE
		,p_partial_reservation_flag  => FND_API.G_TRUE
		,p_force_reservation_flag    => FND_API.G_FALSE
		,p_validation_flag           => FND_API.G_TRUE
		,p_rsv_rec                   => l_rsv
		,p_serial_number             => l_dummy_sn
		,x_reservation_id            => l_rsv_id
		,x_quantity_reserved         => l_rsv_qty
		,x_secondary_quantity_reserved => l_rsv_qty2
		,x_serial_number             => l_dummy_sn
		,x_msg_count                 => l_msg_count
		,x_msg_data                  => l_msg_data
		,x_return_status             => l_return_status
		);

     IF l_return_status IN (FND_API.G_RET_STS_SUCCESS) THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'QUANTITY RESERVED: ' || TO_CHAR ( L_RSV_QTY ) ) ;
		    oe_debug_pub.add(  'QUANTITY2 RESERVED: ' || TO_CHAR ( L_RSV_QTY2 ) ) ;
	  END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RESERVATION ID: ' || TO_CHAR ( L_RSV_ID ) ) ;
		END IF;
	ELSE
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'RESERVATION RETURN STATUS: '|| L_RETURN_STATUS || ' IF ERROR EVEN THEN THE IMPORT SHOULD NOT FAIL' ) ;
	     END IF;
       fnd_file.put_line(FND_FILE.OUTPUT, 'Not able to reserve quantity for requisition number ' || G_ORIG_SYS_DOCUMENT_REF);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'MSG COUNT: '|| L_MSG_COUNT ) ;
		END IF;

	  	IF l_msg_count = 1 THEN
		   OE_Msg_Pub.Add_Text(p_message_text => l_msg_data);
		   IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  'ERROR: '|| L_MSG_DATA ) ;
		   END IF;
	  	ELSE
	   	   FOR i IN 1..l_msg_count
	   	   LOOP
		      FND_Msg_Pub.Get(
--  			p_msg_index     => FND_MSG_PUB.G_NEXT,
  			p_encoded       => FND_API.G_TRUE,
    			p_data          => l_msg_data,
    			p_msg_index_out => l_msg_index);

		      OE_Msg_Pub.Add_Text(p_message_text => l_msg_data);
		      IF l_debug_level  > 0 THEN
		          oe_debug_pub.add(  'ERROR: '|| L_MSG_DATA ) ;
		      END IF;
	   	   END LOOP;
	  	END IF;
	END IF;

        p_msg_count      := l_msg_count;
        p_msg_data       := l_msg_data;
        p_return_status  := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN CREATE_RESERVATION: '||SQLERRM ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BUT THE SUCCESS WILL BE RETURNED' ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         p_return_status  := FND_API.G_RET_STS_SUCCESS;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Create_Reservation');
      END IF;

END Create_Reservation;









PROCEDURE Delete_Reservation (
   p_rsv       		IN  INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2

)
IS
   l_rsv       		INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE :=p_rsv;
   l_dummy_sn  		INV_RESERVATION_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
   l_msg_index 		NUMBER;
   l_msg_count 		NUMBER;
   l_msg_data  		VARCHAR2(240);
   l_return_status 	VARCHAR2(1);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING DELETE RESERVATIONS API' ) ;
	END IF;

	INV_RESERVATION_PUB.Delete_Reservation (
	 	 p_api_version_number        => 1.0
		,p_init_msg_lst              => FND_API.G_TRUE
		,p_rsv_rec                   => l_rsv
		,p_serial_number             => l_dummy_sn
		,x_msg_count                 => l_msg_count
		,x_msg_data                  => l_msg_data
		,x_return_status             => l_return_status
		);

     IF l_return_status IN (FND_API.G_RET_STS_SUCCESS) THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RESERVATION DELETED' ) ;
             END IF;
	ELSE
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'RESERVATION RETURN STATUS: '|| L_RETURN_STATUS || ' IF ERROR EVEN THEN THE IMPORT SHOULD NOT FAIL' ) ;
	     END IF;
       fnd_file.put_line(FND_FILE.OUTPUT, 'Not able to cancel quantity for requisition number ' || G_ORIG_SYS_DOCUMENT_REF);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'MSG COUNT: '|| L_MSG_COUNT ) ;
		END IF;

	  	IF l_msg_count = 1 THEN
		   OE_Msg_Pub.Add_Text(p_message_text => l_msg_data);
		   IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  'ERROR: '|| L_MSG_DATA ) ;
		   END IF;
	  	ELSE
	   	   FOR i IN 1..l_msg_count
	   	   LOOP
		      FND_Msg_Pub.Get(
--  			p_msg_index     => FND_MSG_PUB.G_NEXT,
  			p_encoded       => FND_API.G_TRUE,
    			p_data          => l_msg_data,
    			p_msg_index_out => l_msg_index);

		      OE_Msg_Pub.Add_Text(p_message_text => l_msg_data);
		      IF l_debug_level  > 0 THEN
		          oe_debug_pub.add(  'ERROR: '|| L_MSG_DATA ) ;
		      END IF;
	   	   END LOOP;
	  	END IF;
	END IF;

        p_msg_count      := l_msg_count;
        p_msg_data       := l_msg_data;
        p_return_status  := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN DELETE_RESERVATION: '||SQLERRM ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BUT THE SUCCESS WILL BE RETURNED' ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         p_return_status  := FND_API.G_RET_STS_SUCCESS;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Delete_Reservation');
      END IF;

END Delete_Reservation;

END OE_ORDER_IMPORT_RESERVE_PVT;

/

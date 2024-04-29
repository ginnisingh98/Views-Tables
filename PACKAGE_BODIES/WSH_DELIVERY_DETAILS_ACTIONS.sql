--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_ACTIONS" as
/* $Header: WSHDDACB.pls 120.36.12010000.9 2010/04/26 07:34:45 mvudugul ship $ */

-- odaboval : Begin of OPM Changes (Pick_Confirm)
G_PACKAGE_NAME       CONSTANT   VARCHAR2(50) := 'WSH_DELIVERY_DETAILS_ACTIONS';

G_MAX_DECIMAL_DIGITS     CONSTANT   NUMBER := 9 ;
G_MAX_REAL_DIGITS     CONSTANT    NUMBER := 10 ;
G_RET_WARNING       CONSTANT    VARCHAR2(1):= 'W';

-- 2587777
G_ATO_RSV_PROFILE   VARCHAR2(240);
G_CODE_RELEASE_LEVEL            VARCHAR2(6);
g_header_id                     number;
-- 2587777

-- J: W/V Changes
cursor g_get_detail_info(detail_id in number) is
select released_status,
       gross_weight,
       net_weight,
       volume,
       container_flag,
       delivery_id
from   wsh_Delivery_details wdd,
       wsh_delivery_assignments_v wda
where  wdd.delivery_detail_id = detail_id
and    wdd.delivery_detail_id = wda.delivery_detail_id;

-- odaboval : End of OPM Changes (Pick_Confirm)
/*2442099*/
-- Forward declaration for the procedure Log_Exceptions

PROCEDURE Log_Exceptions(p_old_delivery_detail_id IN NUMBER,
                         p_new_delivery_detail_id IN NUMBER,
                         p_delivery_id            IN NUMBER,
                         p_action                 IN VARCHAR2 DEFAULT NULL);

-- Forward declaration
--  Procedure:    Split_Serial_Numbers_INT
--
--          x_old_detail_rec       original delivery detail information for splitting
--          x_new_delivery_detail_rec  new delivery detail to copy
--          p_old_shipped_quantity   shipped quantity to be updated on original detail
--          p_new_shipped_quantity   shipped quantity to be updated on new detail
--
--  Description:  Splits the serial number records for
--          the original delivery line
--          and its newly split delivery line.
--          x_old_detail_recand x_new_delivery_detail_rec will be updated with
--          new serial number information as needed (for serial_number, to_serial_number,
--          and transaction_temp_id).
PROCEDURE Split_Serial_Numbers_INT(
  x_old_detail_rec      IN OUT NOCOPY   SplitDetailRecType,
    x_new_delivery_detail_rec IN OUT NOCOPY   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
    p_old_shipped_quantity  IN    NUMBER,
    p_new_shipped_quantity  IN    NUMBER,
    x_return_status      OUT NOCOPY      VARCHAR2);


/*---------------------------------------------------------------------------------------------------
Procedure Name : Unreserve_delivery_detail
Description : This API calls Inventory's APIs to Unreserve. It first
         queries the reservation records, and then calls
         delete_reservations until the p_quantity_to_unreserve
         is satisfied.
Parameters      : p_delivery_detail_id         -> WSH_DELIVERY_DETAILS.delivery_detail_id corresponding to
                                                  which the reservations are to be Unreserved
                  p_quantity_to_unreserve      -> Quantity to Unreserve / Cycle Count
                  p_unreserve_mode             -> p_unreserve_mode             -> Either  'UNRESERVE'  or 'CYCLE_COUNT' or 'RETAIN_RSV'
                                                  Added 'RETAIN_RSV' for bug 4721577. WMS wants
                                                  reservations to be retained while Backordering
                                                  delivery detail lines.'
                  p_override_retain_ato_rsv    -> A 'Y' for this parameter will indicate to override the
                                                  Retain ATO REservations profile (yes). In short, this
                                                  will indicate that the Unreservation has to take place.
                                                  This is Passed as 'Y' from WSH_INTERFACE.delete_details,
                                                  an instance where the Reservations have to be reduced.
Brief Logic of Underlying IFs :
Loop Until All Resevation Records are Read; Classify the Rsvn. into Staged and UnStaged Rsvtns.
 IF ( LineType = 'Unstaged' and p_unreserve_mode = 'UNRESERVE' and Reservation is not staged) THEN
     IF ( Ato Line with Retain Rsvtn.) Don't Update or Delete the REservations
      Otherwise -- Reduce Detailed Qty and Prim.Rsvtn Qty and Call [Update Rsvn] OR [Delete Rsvtn]
 ELSIF ( LineType = 'staged' and unreserve_mode = 'UNRESERVE' and Reservation is staged)
                OR ( unreserve_mode <> 'UNRESERVE' , e.g. Cycle Count ) THEN
     Handle: ( rsv.Qty <= Qty. to UnReserve)
           IF ( ATO line ) then Update Staged Flag to UnStaged Otherwise (Delete REservation )
           OR Cycle_Count depending on the unreserve_mode
     Handle: ( rsv.Qty > Qty. to UnReserve)
         IF ( ATO Line ) THEN (Transfer Reservation and Update Rsvntn. Staged Flag to UnStaged for the
                 Split or Transferred Rsvtn.) Otherwise (Update Rsvtn.)
         OR (Cycle Count Process) depending on the unreserve_mode
End Loop;
------------------------------------------------------------------------------------------------------- */
-- HW 3121616 Added p_quantity2_to_unreserve
Procedure Unreserve_delivery_detail
( p_delivery_detail_id      IN NUMBER
, p_quantity_to_unreserve    IN  NUMBER
, p_quantity2_to_unreserve    IN  NUMBER default NULL
, p_unreserve_mode        IN  VARCHAR2
, p_override_retain_ato_rsv     IN  VARCHAR2    -- 2747520
, x_return_status        OUT NOCOPY  VARCHAR2
)


IS
l_rsv_rec        inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new_rec      inv_reservation_global.mtl_reservation_rec_type;
l_msg_count      NUMBER;
l_msg_data        VARCHAR2(3000);
l_rsv_id        NUMBER;
l_return_status    VARCHAR2(1);
l_reserve_msg_count      NUMBER := 0;
l_reserve_msg_data       VARCHAR2(4000) := NULL;
l_reserve_message      VARCHAR2(4000) := NULL;
l_reserve_status     VARCHAR2(1);
l_rsv_tbl        inv_reservation_global.mtl_reservation_tbl_type;
l_count        NUMBER;
l_dummy_sn        inv_reservation_global.serial_number_tbl_type;
l_qty_to_unreserve    NUMBER;
l_sales_order_id    NUMBER := NULL;
l_x_error_code      NUMBER;
l_lock_records      VARCHAR2(1);
l_sort_by_req_date    NUMBER ;
-- HW BUG#:2005977 for OPM
-- HW OPMCONV - Removed OPM variables

l_buffer        VARCHAR2(2000);

x_msg_count       NUMBER;
x_msg_data   VARCHAR2(3000);
l_trans_qty     NUMBER;
l_trans_qty2       NUMBER;
l_lock_status     BOOLEAN;
-- 2587777
l_staged_flag                   VARCHAR2(1);
l_new_rsv_id      NUMBER;
-- 2587777
l_unreserve_mode VARCHAR2(20);
l_lpn_id NUMBER;



Cursor c_line_details is
  select o.source_document_type_id ,
         o.line_id ,
         o.header_id ,
         o.preferred_grade ,
         o.ordered_quantity_uom2 ,
         o.ordered_quantity2 ,
         o.ato_line_id,    -- 2587777
         wdd.organization_id,
-- HW 4178299 - Get Item_id and uom
         wdd.inventory_item_id,
         wdd.requested_quantity_uom,
         wdd.subinventory,
         wdd.revision,
         wdd.locator_id,
	 -- X-dock changes, add 2 fields
         wdd.requested_quantity,
         wdd.requested_quantity2,
-- HW OPMCONV - Changed length from 30 to 80
         substr(wdd.lot_number,1,80) lot_number ,
         wdd.move_order_line_id,
         wdd.released_status, -- 2747520
         wdd.date_scheduled,  -- 2847687
	 wda.parent_delivery_detail_id --4721577
    from wsh_delivery_details wdd ,
         oe_order_lines_all o,
	 wsh_delivery_assignments_v wda
   where wdd.delivery_detail_id = p_delivery_Detail_id
     and wdd.delivery_detail_id = wda.delivery_detail_id
     and wdd.source_code = 'OE'
     and wdd.source_line_id = o.line_id ;

l_line_rec c_line_details%ROWTYPE ;
-- Bug 4721577
CURSOR c_lpn_id (c_delivery_detail_id NUMBER) IS
   SELECT wdd.lpn_id
   FROM   wsh_delivery_details wdd
   WHERE  wdd.delivery_detail_id = c_delivery_detail_id;

-- HW BUG#:2005977 for OPM

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNRESERVE_DELIVERY_DETAIL';
--
l_cancel_rsv_type  VARCHAR2(1);   -- 2747520: 'S'taged or 'U'nstaged
-- HW OPMCONV - Added Qty2
CURSOR c_nonstaged_qty is
SELECT nvl(sum(requested_quantity),0),nvl(sum(requested_quantity2),0)
FROM   wsh_delivery_details
WHERE
       source_line_id      = l_line_rec.line_id
and    source_header_id    = l_line_rec.header_id
and    organization_id     = l_line_rec.organization_id
and    released_status in ('R','B','N','S');

l_nonstaged_qty              NUMBER;
l_nonstaged_rsv_qty          NUMBER;
l_remaining_nonstaged_qty    NUMBER;
l_cancelled_reservation_qty  NUMBER;
-- HW OPMCONV - Added Qty2 variables
l_nonstaged_qty2              NUMBER;
l_nonstaged_rsv_qty2          NUMBER;
l_remaining_nonstaged_qty2    NUMBER;
l_dtld_qty2_to_unreserve      NUMBER;
l_qty2_to_unreserve    NUMBER;
-- 2747520
--
l_trolin_rec                 INV_MOVE_ORDER_PUB.Trolin_Rec_Type;
l_dtld_qty_to_unreserve      NUMBER;

BEGIN


  -- If the quantity to reserve is passed and null or missing, we do not
  -- need to go through this procedure.
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      -- 2587777

      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY2_TO_UNRESERVE',P_QUANTITY2_TO_UNRESERVE);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID:P_QUANTITY_TO_UNRESERVE:P_QUANTITY2_TO_UNRESERVE: P_UNRESERVE_MODE:
                                      P_OVERRIDE_RETAIN_ATO_RSV ;',
                                     P_DELIVERY_DETAIL_ID
                              ||':'||P_QUANTITY_TO_UNRESERVE
                              ||':'||P_QUANTITY2_TO_UNRESERVE
                              ||':'||P_UNRESERVE_MODE
                              ||':'||P_OVERRIDE_RETAIN_ATO_RSV);
  END IF;
  --
  IF p_quantity_to_unreserve is null OR
   p_quantity_to_unreserve = FND_API.G_MISS_NUM THEN
   goto end_of_loop;
  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'P_DELIVERY_DETAIL_ID : G_CODE_RELEASE_LEVEL ;'
                                          || P_DELIVERY_DETAIL_ID ||': '|| G_CODE_RELEASE_LEVEL  );
  END IF;
  --

  IF ( G_CODE_RELEASE_LEVEL is NULL ) THEN
    G_CODE_RELEASE_LEVEL := WSH_CODE_CONTROL.Get_Code_Release_Level;
  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'G_CODE_RELEASE_LEVEL ' || G_CODE_RELEASE_LEVEL  );
  END IF;
  --

  OPEN  c_line_details;
  FETCH c_line_details INTO  l_line_rec ;

  IF c_line_details%NOTFOUND THEN
  CLOSE c_line_details;
  goto end_of_loop;
  END IF;
  CLOSE c_line_details;

  -- HW BUG#:2005977
  --
  IF l_debug_on THEN
-- 2747520
      WSH_DEBUG_SV.log(l_module_name,'Ln_id:Hdr_id:Org_id:Src-doc-id:SubInv:Rev:Lot#:Locat-id ; ',
                       l_line_rec.line_id
               ||':'|| l_line_rec.header_id
               ||':'|| l_line_rec.organization_id
               ||':'|| l_line_rec.source_document_type_id
               ||':'|| l_line_rec.subinventory
               ||':'|| l_line_rec.revision
               ||':'|| l_line_rec.lot_number
-- HW 4178299  - Added inventory_item_id, uom and uom2
               ||':'|| l_line_rec.inventory_item_id
               ||':'|| l_line_rec.requested_quantity_uom
               ||':'|| l_line_rec.ordered_quantity_uom2
               ||':'|| l_line_rec.locator_id);
      WSH_DEBUG_SV.log(l_module_name,'ATO-Ln-id : Rel-Stat : Dt-Sched HH24:MI:SS ; ',
                       l_line_rec.ato_line_id
               ||':'|| l_line_rec.released_status
               ||':'|| to_char(l_line_rec.date_scheduled,'MM/DD/YYYY HH24:MI:SS'));

-- 2587777

  END IF;
  --
--HW OPMCONV - Removed checking for process org

  -- end of BUG#:2005977
  IF l_line_rec.source_document_type_id = 10 THEN
   -- This is an internal order line. We need to give
   -- a different demand source type for these lines.
      l_rsv_rec.demand_source_type_id   :=
      INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD;
          -- intenal order
  ELSE
    l_rsv_rec.demand_source_type_id  :=
      INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE; -- order entry
  END IF;

  -- Get demand_source_header_id from mtl_sales_orders

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  -- caching the sales_order_id : 2807093-2747520
  IF ( l_sales_order_id is NULL OR l_line_rec.header_id <> nvl(g_header_id, 0) ) THEN
    l_sales_order_id := inv_salesorder.get_salesorder_for_oeheader(
                          l_line_rec.header_id);
    g_header_id      := l_line_rec.header_id;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'L_SALES_ORDER_ID' || L_SALES_ORDER_ID  );
  END IF;
  --

  l_rsv_rec.demand_source_header_id     := l_sales_order_id;
  l_rsv_rec.demand_source_line_id := l_line_rec.line_id;

  -- Bug 1842613 : Initializing inventory controls present in wsh_delivery_details
  IF ( l_line_rec.organization_id IS NOT NULL )  THEN
   l_rsv_rec.organization_id := l_line_rec.organization_id;
  END IF;
  IF ( l_line_rec.subinventory IS NOT NULL) THEN
   l_rsv_rec.subinventory_code := l_line_rec.subinventory;
  END IF;
  IF ( l_line_rec.revision IS NOT NULL ) THEN
   l_rsv_rec.revision := l_line_rec.revision;
  END IF;
  IF ( l_line_rec.lot_number IS NOT NULL ) THEN
   l_rsv_rec.lot_number := l_line_rec.lot_number;
  END IF;
  IF ( l_line_rec.locator_id IS NOT NULL ) THEN
   l_rsv_rec.locator_id := l_line_rec.locator_id;
  END IF;
--Added condition p_unreserve_mode = 'RETAIN_RSV' for bug 4721577
IF ( p_unreserve_mode = 'RETAIN_RSV' AND
     l_line_rec.parent_delivery_detail_id IS NOT NULL AND
     wsh_util_validate.Check_Wms_Org(l_line_rec.organization_id)='Y') THEN
    OPEN  c_lpn_id(l_line_rec.parent_delivery_detail_id);
    FETCH c_lpn_id INTO l_lpn_id;
    IF (c_lpn_id%FOUND) THEN
	IF l_lpn_id is not null THEN
           l_rsv_rec.lpn_id := l_lpn_id;
        END IF;
    END IF;
    CLOSE c_lpn_id;
  END IF;
  --

  --bug 4950329: query only staged reservations for cycle-count
  IF (p_unreserve_mode = 'CYCLE_COUNT')  THEN
    l_rsv_rec.staged_flag := 'Y';
  END IF;


-- HW BUG#:2005977 for OPM. Need to branch
-- HW OPMCONV - No need to branch code
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.QUERY_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
-- Bug 3431358(Moved this code from top to here)
-- 2747520 : Set reservation_type to 'U'nstaged or 'S'taged
  IF (l_line_rec.released_status in ('R','B','N') ) THEN
      l_cancel_rsv_type := 'U';
      OPEN  c_nonstaged_qty;
      FETCH c_nonstaged_qty
      INTO  l_nonstaged_qty, l_nonstaged_qty2;
      CLOSE c_nonstaged_qty;
  ELSIF (l_line_rec.released_status in ('C','Y')) THEN
      l_cancel_rsv_type := 'S';
  ELSIF (l_line_rec.released_status = 'S') THEN
      l_cancel_rsv_type := 'U';
      --X-dock
      IF l_line_rec.move_order_line_id IS NOT NULL THEN
        l_trolin_rec := INV_TROLIN_UTIL.Query_Row(p_line_id => l_line_rec.move_order_line_id);
      ELSE -- MOL is null for X-dock case
        l_trolin_rec.quantity_detailed := l_line_rec.requested_quantity;
        l_trolin_rec.secondary_quantity_detailed := l_line_rec.requested_quantity2;
      END IF;
      -- end of X-dock changes

      IF (l_trolin_rec.quantity_detailed > 0) THEN
        l_dtld_qty_to_unreserve := l_trolin_rec.quantity_detailed;
-- HW OPMCONV - Added Qty2
        l_dtld_qty2_to_unreserve := l_trolin_rec.secondary_quantity_detailed;
      ELSE
-- HW OPMCONV - Added Qty2
        l_dtld_qty_to_unreserve := 0;
        l_dtld_qty2_to_unreserve := 0;
      END IF;
  ELSE
      l_cancel_rsv_type := 'X';   -- ignoring if not in above released status
  END IF;
-- 2747520
-- End Bug3431358

--2587777
         IF ( G_ATO_RSV_PROFILE  IS NULL ) THEN
            fnd_profile.get('WSH_RETAIN_ATO_RESERVATIONS', G_ATO_RSV_PROFILE);
            if ( G_ATO_RSV_PROFILE is NULL ) THEN     -- By Default this Profile is 'N'
                G_ATO_RSV_PROFILE := 'N';
            end if;
         END IF;
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'g_ato_rsv_profile',G_ATO_RSV_PROFILE);
         END IF;
--2587777

  --X-dock
  IF l_line_rec.released_status = WSH_DELIVERY_DETAILS_PKG.C_RELEASED_TO_WAREHOUSE THEN
    WSH_USA_INV_PVT.get_putaway_detail_id
      (p_detail_id          => p_delivery_detail_id,
       p_released_status    => l_line_rec.released_status,
       p_move_order_line_id => l_line_rec.move_order_line_id,
       x_detail_id          => l_rsv_rec.demand_source_line_detail,
       x_return_status      => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  --end of X-dock

   inv_reservation_pub.query_reservation
     (p_api_version_number        => 1.0,
      p_init_msg_lst              => fnd_api.g_true,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data,
      p_query_input               => l_rsv_rec,
      p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES,
      x_mtl_reservation_tbl       => l_rsv_tbl,
      x_mtl_reservation_tbl_count => l_count,
      x_error_code                => l_x_error_code,
      p_lock_records              => l_lock_records,
      p_sort_by_req_date          => l_sort_by_req_date
     );


  -- 2747520: for Non-Staged
   IF ( l_cancel_rsv_type = 'U') THEN
     l_nonstaged_rsv_qty  := 0;

     FOR l_counter in  1..l_count
     LOOP
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         INV_STAGED_RESERVATION_UTIL.query_staged_flag(
           x_return_status   =>  x_return_status,
           x_msg_count       =>  l_msg_count,
           x_msg_data        =>  l_msg_data,
           x_staged_flag     =>  l_staged_flag,
           p_reservation_id  =>  l_rsv_tbl(l_counter).reservation_id);

     IF l_staged_flag <> 'Y' THEN
-- HW OPMCONV - Added Qty2
      l_nonstaged_rsv_qty := l_nonstaged_rsv_qty + (l_rsv_tbl(l_counter).primary_reservation_quantity - nvl(l_rsv_tbl(l_counter).detailed_quantity,0));
      l_nonstaged_rsv_qty2 := l_nonstaged_rsv_qty2 + (l_rsv_tbl(l_counter).secondary_reservation_quantity - nvl(l_rsv_tbl(l_counter).detailed_quantity,0));
     END IF;

    END LOOP;
  END IF;
-- 2747520

   l_qty_to_unreserve   := p_quantity_to_unreserve;
-- HW OPMCONV - Added Qty2
   l_qty2_to_unreserve   := p_quantity2_to_unreserve;


-- HW 4178299 - Need to convert Qty2 to get correct value
   IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Value of Qty2_to_Unreserve before conversion is ',
                                          l_qty2_to_unreserve);

   END IF;

   IF ( l_qty2_to_unreserve is NOT NULL OR
        l_qty2_to_unreserve <> FND_API.G_MISS_NUM ) THEN

        l_qty2_to_unreserve := WSH_WV_UTILS.convert_uom
                 (
                  item_id      => l_line_rec.inventory_item_id
                 ,org_id       => l_line_rec.organization_id
                 ,from_uom     => l_line_rec.requested_quantity_uom
                 ,to_uom       => l_line_rec.ordered_quantity_uom2
                 ,quantity     => l_qty_to_unreserve
                 ,lot_number   => l_line_rec.lot_number);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Value of Qty2_to_Unreserve AFTER conversion is ',
                           l_qty2_to_unreserve);

        END IF;

   END IF;

-- HW end of 4178299



-- 2747520   -- if rsv_type = U
   IF ( l_cancel_rsv_type = 'U') THEN
    l_remaining_nonstaged_qty := l_nonstaged_qty - l_qty_to_unreserve;
-- HW OPMCONV - Added Qty2
    l_remaining_nonstaged_qty2 := l_nonstaged_qty2 - l_qty2_to_unreserve;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_rsv_qty:l_nonstaged_qty:l_dtld_qty_to_unreserve:l_remaining_nonstaged_qty ;',
                       l_nonstaged_rsv_qty
                ||':'||l_nonstaged_qty
                ||':'||l_dtld_qty_to_unreserve
                ||':'||l_remaining_nonstaged_qty );
-- HW OPMCONV - Added Qty2
        WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_rsv_qty2:l_nonstaged_qty:l_dtld_qty2_to_unreserve:l_remaining_nonstaged_qty2 ;',
                       l_nonstaged_rsv_qty2
                ||':'||l_nonstaged_qty2
                ||':'||l_dtld_qty2_to_unreserve
                ||':'||l_remaining_nonstaged_qty2 );

    END IF;
    -- Only Unreserve the Excess Unstgd. Rsvtns.
    IF (l_nonstaged_rsv_qty > l_remaining_nonstaged_qty) THEN
      l_qty_to_unreserve := l_nonstaged_rsv_qty - l_remaining_nonstaged_qty;
-- HW OPMCONV - Added Qty2
      l_qty2_to_unreserve := l_nonstaged_rsv_qty2 - l_remaining_nonstaged_qty2;
    ELSE
      l_qty_to_unreserve   := 0;
-- HW OPMCONV - Added Qty2
      l_qty2_to_unreserve   := 0;
    END IF;
   END IF;       -- if rsv_type = U
-- 2747520

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_rsv_tbl.COUNT:l_x_error_code :: ',
                                          l_rsv_tbl.COUNT||':'||l_x_error_code);
         END IF;

   FOR I IN 1..l_rsv_tbl.COUNT LOOP

       l_rsv_rec := l_rsv_tbl(I);
  --
  IF l_debug_on THEN
-- 2587777
          WSH_DEBUG_SV.log(l_module_name,'rsv.id:inv-item-id:Rsvtn-Qty:Org-id:SubInv-Code:Locator-id:Rev:Lot# ; ',
                        l_rsv_rec.reservation_id
                 ||':'||l_rsv_rec.inventory_item_id
                 ||':'||l_rsv_rec.reservation_quantity
                 ||':'||l_rsv_rec.secondary_reservation_quantity
                 ||':'||L_RSV_REC.ORGANIZATION_ID
                 ||':'||L_RSV_REC.SUBINVENTORY_CODE
                 ||':'||L_RSV_REC.LOCATOR_ID
                 ||':'||L_RSV_REC.REVISION
                 ||':'||L_RSV_REC.LOT_NUMBER  );
-- 2587777
  END IF;
  --
-- 2747520 : Query Staged Reservation
 IF l_debug_on THEN
  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
--
  inv_staged_reservation_util.query_staged_flag(
  x_return_status     => l_return_status
  , x_msg_count         => l_msg_count
  , x_msg_data          => l_msg_data
  , x_staged_flag       => l_staged_flag
  , p_reservation_id    => l_rsv_rec.reservation_id);
  --
  IF l_debug_on THEN

   WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS QUERY STAGED FLAG: ' || L_RETURN_STATUS  );
  END IF;
  --

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
  END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'RES QTY : QTY TO UNRESVRVE : l_staged_flag ; ',
                              L_RSV_REC.RESERVATION_QUANTITY
                       ||':'||L_QTY_TO_UNRESERVE
                       ||':'||l_staged_flag );

-- HW OPMCONV - Added Qty2
    WSH_DEBUG_SV.log(l_module_name, 'RES QTY2 : QTY2 TO UNRESVRVE : l_staged_flag ; ',
                              L_RSV_REC.SECONDARY_RESERVATION_QUANTITY
                       ||':'||L_QTY2_TO_UNRESERVE
                       ||':'||l_staged_flag );

 END IF;

 --
 -- 2747520 : This will also ensure that Only Non-Staged Staged line UnReserves Non-Stged Rsvtns.
 --          and Staged Rsvtns. UnReserves Staged Rsvtns.
 --
 -- cancel Non-Staged Reservations by non-stged lines
 IF (l_cancel_rsv_type = 'U' and p_unreserve_mode = 'UNRESERVE' and l_staged_flag <> 'Y') THEN

       -- Check if Retain ATO Profile
       IF ( l_line_rec.ato_line_id IS NOT NULL  AND
                nvl(p_override_retain_ato_rsv, 'N') = 'N' AND
                G_ATO_RSV_PROFILE    = 'Y'  AND
                G_CODE_RELEASE_LEVEL > '110508' ) THEN
          NULL;  -- Don't Update or Delete the REservations if the above criteria (ATO -Unstgd. Rsvn)is met
       ELSE

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'BEFORE l_prim_rsv_qty: tbl_detailed_qty ; ',
                                          l_rsv_tbl(I).primary_reservation_quantity ||':'||
                                          l_rsv_tbl(I).detailed_quantity);
-- HW OPMCONV - Added Qty2
          WSH_DEBUG_SV.log(l_module_name,'BEFORE l_secondary_rsv_qty: tbl_detailed_qty2 ; ',
                                          l_rsv_tbl(I).secondary_reservation_quantity ||':'||
                                          l_rsv_tbl(I).secondary_detailed_quantity);
        END IF;

        -- Start with orginal primary_reservation_quantity and detailed_quantity
        l_rsv_new_rec.primary_reservation_quantity := l_rsv_tbl(I).primary_reservation_quantity;
        l_rsv_new_rec.detailed_quantity            := nvl(l_rsv_tbl(I).detailed_quantity,0);

-- HW OPMCONV - Added Qty2
        l_rsv_new_rec.secondary_reservation_quantity := l_rsv_tbl(I).secondary_reservation_quantity;
        l_rsv_new_rec.secondary_detailed_quantity            := nvl(l_rsv_tbl(I).secondary_detailed_quantity,0);

        -- Tackle Detailed Quantity
        IF nvl(l_rsv_tbl(I).detailed_quantity,0) <> 0  THEN

           IF (l_dtld_qty_to_unreserve > 0) THEN
             IF (nvl(l_rsv_tbl(I).detailed_quantity,0) <= l_dtld_qty_to_unreserve) THEN
               l_dtld_qty_to_unreserve := l_dtld_qty_to_unreserve - nvl(l_rsv_tbl(I).detailed_quantity,0);
-- HW OPMCONV - Added Qty2
               l_dtld_qty2_to_unreserve := l_dtld_qty2_to_unreserve - nvl(l_rsv_tbl(I).secondary_detailed_quantity,0);

               l_rsv_new_rec.detailed_quantity := 0;
               l_rsv_new_rec.primary_reservation_quantity := l_rsv_new_rec.primary_reservation_quantity - nvl(l_rsv_tbl(I).detailed_quantity,0);
-- HW OPMCONV - Added Qty2
               l_rsv_new_rec.secondary_detailed_quantity := 0;
               l_rsv_new_rec.secondary_reservation_quantity := l_rsv_new_rec.secondary_reservation_quantity - nvl(l_rsv_tbl(I).secondary_detailed_quantity,0);
             ELSE
               l_rsv_new_rec.detailed_quantity := l_rsv_new_rec.detailed_quantity - l_dtld_qty_to_unreserve;
               l_rsv_new_rec.primary_reservation_quantity := l_rsv_new_rec.primary_reservation_quantity - l_dtld_qty_to_unreserve;
               l_dtld_qty_to_unreserve := 0;
-- HW OPMCONV - Added Qty2
               l_rsv_new_rec.secondary_detailed_quantity := l_rsv_new_rec.secondary_detailed_quantity - l_dtld_qty_to_unreserve;
               l_rsv_new_rec.secondary_reservation_quantity := l_rsv_new_rec.secondary_reservation_quantity - l_dtld_qty2_to_unreserve;
               l_dtld_qty2_to_unreserve := 0;
             END IF;
           END IF;

        END IF;

        -- Tackle Primary Reservation Quantity
        IF (l_qty_to_unreserve > 0) THEN
          IF ((l_rsv_new_rec.primary_reservation_quantity - l_rsv_new_rec.detailed_quantity) <= l_qty_to_unreserve) THEN
          IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ONE Before calculation l_qty_to_unreserve: ' || l_qty_to_unreserve  );

       END IF;
            l_qty_to_unreserve := l_qty_to_unreserve - (l_rsv_new_rec.primary_reservation_quantity - l_rsv_new_rec.detailed_quantity);
-- HW OPMCONV - Added Qty2
            l_qty2_to_unreserve := l_qty2_to_unreserve - (l_rsv_new_rec.secondary_reservation_quantity - l_rsv_new_rec.secondary_detailed_quantity);
             IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ONE After calculation l_qty_to_unreserve: ' || l_qty_to_unreserve  );

       END IF;

            l_rsv_new_rec.primary_reservation_quantity := l_rsv_new_rec.detailed_quantity;
-- HW OPMCONV - Added Qty2
            l_rsv_new_rec.secondary_reservation_quantity := l_rsv_new_rec.secondary_detailed_quantity;
          ELSE
            l_rsv_new_rec.primary_reservation_quantity := l_rsv_new_rec.primary_reservation_quantity - l_qty_to_unreserve;
            l_qty_to_unreserve := 0;
-- HW OPMCONV - Added Qty2
            l_rsv_new_rec.secondary_reservation_quantity := l_rsv_new_rec.secondary_reservation_quantity - l_qty2_to_unreserve;
            l_qty2_to_unreserve := 0;
          END IF;
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'NEW l_prim_rsv_qty: new tbl_detailed_qty ; ',
                                          l_rsv_new_rec.primary_reservation_quantity ||':'||
                                          l_rsv_new_rec.detailed_quantity);
-- HW OPMCONV - Added Qty2
          WSH_DEBUG_SV.log(l_module_name,'NEW l_seccondary_rsv_qty: new tbl_detailed_qty2 ; ',
                                          l_rsv_new_rec.secondary_reservation_quantity ||':'||
                                          l_rsv_new_rec.secondary_detailed_quantity);
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_pub.update_resevation 1',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

-- HW OPMCONV - NULL Qty2 if they are not presents
        IF ( (  l_rsv_new_rec.secondary_reservation_quantity = 0 OR
              l_rsv_new_rec.secondary_reservation_quantity = FND_API.G_MISS_NUM )
            OR ( l_rsv_new_rec.secondary_detailed_quantity = 0  OR
                 l_rsv_new_rec.secondary_detailed_quantity = FND_API.G_MISS_NUM ) ) THEN
                l_rsv_new_rec.secondary_reservation_quantity := NULL;
                l_rsv_new_rec.secondary_detailed_quantity := NULL;
        END IF;


        IF (l_rsv_new_rec.primary_reservation_quantity > 0) THEN



          inv_reservation_pub.update_reservation
             (p_api_version_number       => 1.0,
              p_init_msg_lst            => fnd_api.g_true,
              x_return_status           => l_return_status,
              x_msg_count               => l_msg_count,
              x_msg_data                => l_msg_data,
              p_original_rsv_rec        => l_rsv_rec,
              p_to_rsv_rec              => l_rsv_new_rec,
              p_original_serial_number  => l_dummy_sn, -- no serial contorl
              p_to_serial_number        => l_dummy_sn, -- no serial control
              p_validation_flag         => fnd_api.g_true,
	      -- Bug 5099694
              p_over_reservation_flag  =>3
             );

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS UPDATE REservation 1: ' || L_RETURN_STATUS  );
             WSH_DEBUG_SV.log(l_module_name,'l_new_prim_rsv_qty: tbl_detailed_qty ; ',
                                             l_rsv_new_rec.primary_reservation_quantity ||':'||
                                             l_rsv_tbl(I).detailed_quantity);
-- HW OPMCONV - Added Qty2
             WSH_DEBUG_SV.log(l_module_name,'l_new_secondary_rsv_qty: tbl_detailed_qty2 ; ',
                                             l_rsv_new_rec.secondary_reservation_quantity ||':'||
                                             l_rsv_tbl(I).secondary_detailed_quantity);
           END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

         ELSE

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_pub.delete_resevation 1',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           inv_reservation_pub.delete_reservation
           ( p_api_version_number => 1.0
           , p_init_msg_lst       => fnd_api.g_true
           , x_return_status      => l_return_status
           , x_msg_count          => l_msg_count
           , x_msg_data           => l_msg_data
           , p_rsv_rec            => l_rsv_rec
           , p_serial_number      => l_dummy_sn
           );

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS DELETE REservation 1: ' || L_RETURN_STATUS  );
           END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_qty_to_unreserve:l_dtld_qty_to_unreserve ; ',
                                           l_qty_to_unreserve ||':'||
                                           l_dtld_qty_to_unreserve);
-- HW OPMCONV - Added Qty2
           WSH_DEBUG_SV.log(l_module_name,'l_qty2_to_unreserve:l_dtld_qty2_to_unreserve ; ',
                                           l_qty2_to_unreserve ||':'||
                                           l_dtld_qty2_to_unreserve);
         END IF;


         IF ((l_qty_to_unreserve <= 0) AND (l_dtld_qty_to_unreserve <= 0)) THEN
           goto end_of_loop;
         END IF;

       END IF;  -- check ATO Profile

-- Added 'RETAIN_RSV' for bug 4721577
ELSIF ( (l_cancel_rsv_type = 'S' and l_staged_flag = 'Y' and p_unreserve_mode in ( 'UNRESERVE', 'RETAIN_RSV' ) ) OR
          (p_unreserve_mode not in ( 'UNRESERVE', 'RETAIN_RSV' ) ) ) THEN

     IF (l_rsv_rec.reservation_quantity <= l_qty_to_unreserve) THEN     -- rsv. Qty <=
-- Added 'RETAIN_RSV' for bug 4721577
      IF ( NVL(p_unreserve_mode, 'UNRESERVE') in ( 'UNRESERVE', 'RETAIN_RSV' ) ) THEN
-- 2587777 :                 -- Ato Item and for Patchset level higher than 'H' , i.e. from 'I' onwards
 IF ( ( ( l_line_rec.ato_line_id IS NOT NULL AND G_ATO_RSV_PROFILE = 'Y'AND nvl(p_override_retain_ato_rsv, 'N') = 'N' ) OR
                  ( p_unreserve_mode = 'RETAIN_RSV' ) ) AND
                G_CODE_RELEASE_LEVEL > '110508' )

	   THEN
           --
           -- Bug # 9583775 :  begin
           -- Calling the API INV_RESERVATION_PUB.transfer_reservation instead of
           -- just updating staged flag value. This is req. incase if there are
           -- other reservation record which is eligible for consolidation with
           -- the current res. record. If there is no other res. record then INV
           -- updates the current res. record (old behavior).
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_staged_flag: ',l_staged_flag);
           END IF;
           --
           IF ( nvl(l_staged_flag, 'N')  = 'Y') THEN
           --{ transfer/update reservation.
               l_rsv_new_rec                  := l_rsv_rec;
               l_rsv_new_rec.attribute1       := l_line_rec.preferred_grade;
               l_rsv_new_rec.attribute2       := l_line_rec.ordered_quantity2;
               l_rsv_new_rec.attribute3       := l_line_rec.ordered_quantity_uom2;
               l_rsv_new_rec.requirement_date := l_line_rec.date_scheduled;
               l_rsv_new_rec.ship_ready_flag  := 2;
               l_rsv_new_rec.staged_flag      := 'N';
               IF ( (  l_rsv_new_rec.secondary_reservation_quantity = 0 OR
                      l_rsv_new_rec.secondary_reservation_quantity = FND_API.G_MISS_NUM )
                 OR ( l_rsv_new_rec.secondary_detailed_quantity = 0 OR
                      l_rsv_new_rec.secondary_detailed_quantity = FND_API.G_MISS_NUM ) ) THEN
                     l_rsv_new_rec.secondary_reservation_quantity := NULL;
                     l_rsv_new_rec.secondary_detailed_quantity    := NULL;
               END IF;
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.TRANSFER_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               INV_RESERVATION_PUB.transfer_reservation
                (
                 p_api_version_number       => 1.0
                 , p_init_msg_lst           => fnd_api.g_true
                 , x_return_status          => l_return_status
                 , x_msg_count              => l_msg_count
                 , x_msg_data               => l_msg_data
                 , p_original_rsv_rec       => l_rsv_rec
                 , p_to_rsv_rec             => l_rsv_new_rec
                 , p_original_serial_number => l_dummy_sn -- no serial contorl
                 , p_to_serial_number       => l_dummy_sn -- no serial control
                 , p_validation_flag        => fnd_api.g_true
                 , x_to_reservation_id      => l_new_rsv_id
                  );
                  --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS TRANSFER RESERVATION: ' || L_RETURN_STATUS  );
                   WSH_DEBUG_SV.log(l_module_name,'New Rec: reservation id: ', l_new_rsv_id);
               END IF;
               --
               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
            --} transfer/update reservation.
            END IF;
            --- Bug # 9583775 :  End
          ELSE  -- Non- ATO Item
-- 2587777
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING INVS DELETE_RESERVATION'  );
           END IF;
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.DELETE_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --

           inv_reservation_pub.delete_reservation
             (p_api_version_number   => 1.0,
              p_init_msg_lst     => fnd_api.g_true,
              x_return_status       => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data       => l_msg_data,
              p_rsv_rec         => l_rsv_rec,
              p_serial_number       => l_dummy_sn
             );
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS DELETE_RESERVATION: ' || L_RETURN_STATUS  );
          END IF;
          --

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF; -- ATO line
    else      -- p_unreserve_mode = 'CYCLE_COUNT'
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit ONE INV_PICK_RELEASE_PUB.RESERVE_UNCONFIRMED_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.log(l_module_name, 'l_rsv_rec.reservation_quantity: '  || l_rsv_rec.reservation_quantity  );
        WSH_DEBUG_SV.log(l_module_name, ' l_rsv_rec.reservation_quantity2: ' || l_rsv_rec.secondary_reservation_quantity  );
      END IF;
      --
       IF ( l_rsv_rec.secondary_reservation_quantity = 0 OR
            l_rsv_rec.secondary_reservation_quantity =   FND_API.G_MISS_NUM ) THEN
            l_rsv_rec.secondary_reservation_quantity := NULL;
       END IF;
-- HW INVCONV - Added Qty2
      Inv_Pick_Release_Pub.Reserve_Unconfirmed_Quantity(
       p_api_version => 1.0,
       p_init_msg_list => FND_API.G_FALSE,
       p_commit => FND_API.G_FALSE,
       x_return_status => l_reserve_status,
       x_msg_count => l_reserve_msg_count,
       x_msg_data => l_reserve_msg_data,
       p_missing_quantity => l_rsv_rec.reservation_quantity ,
       p_missing_quantity2 => l_rsv_rec.secondary_reservation_quantity ,
       p_reservation_id => l_rsv_rec.reservation_id,
       p_demand_source_header_id => l_sales_order_id,
       p_demand_source_line_id => l_line_rec.line_id,
       p_organization_id => l_rsv_rec.organization_id,
       p_inventory_item_id => l_rsv_rec.inventory_item_id,
       p_subinventory_code => l_rsv_rec.subinventory_code ,
       p_locator_id => l_rsv_rec.locator_id,
       p_revision => l_rsv_rec.revision,
       p_lot_number => l_rsv_rec.lot_number);

       IF ((l_reserve_status = WSH_UTIL_CORE.G_RET_STS_ERROR) or
        (l_reserve_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN     -- rsv.status
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVE UNCONFIRMED QUANTITY FAILED'  );
            WSH_DEBUG_SV.logmsg(l_module_name, 'MESSAGE COUNT: '|| TO_CHAR ( L_RESERVE_MSG_COUNT )  );
        END IF;
        --
         IF (l_reserve_msg_count = 0)  or (l_reserve_msg_count is NULL) THEN  -- rsv.msg.count
          null;
          ELSE
          FOR i in 1 ..l_reserve_msg_count
          LOOP
             l_reserve_message := fnd_msg_pub.get(i,'T');
             l_reserve_message := replace(l_reserve_message,chr(0), ' ');
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,  L_RESERVE_MESSAGE  );
             END IF;
             --
          END LOOP;
         END if;   -- rsv.msg.count
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'RESERVE_UNCONFIRMED_QUANTITY FAILED.. GOING ON... '  );
         END IF;
         --
         END IF;
        end if;     -- rsv.status

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_qty_to_unreserve',
                            l_qty_to_unreserve);
          WSH_DEBUG_SV.log(l_module_name,'reservation_quantity',
                                         l_rsv_rec.reservation_quantity);
        END IF;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Before calculation l_qty_to_unreserve: ' || l_qty_to_unreserve  );

     END IF;

        l_qty_to_unreserve := l_qty_to_unreserve -
                                       l_rsv_rec.reservation_quantity;
-- HW OPMCONV- Added Qty2
       l_qty2_to_unreserve := l_qty2_to_unreserve -
                                       l_rsv_rec.secondary_reservation_quantity;
       IF l_debug_on THEN

          WSH_DEBUG_SV.logmsg(l_module_name, 'After calculation l_qty_to_unreserve: ' || l_qty_to_unreserve  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'After calculation l_qty2_to_unreserve: ' || l_qty2_to_unreserve  );

       END IF;

        IF (l_qty_to_unreserve <= 0) THEN
             goto end_of_loop;
        END IF;

     ELSE         --  rsv. qty >

       l_rsv_new_rec     := l_rsv_rec;

     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'OLD QTY : NEW QTY :: ' || L_RSV_REC.RESERVATION_QUANTITY
                                           ||': '|| L_RSV_NEW_REC.RESERVATION_QUANTITY  );

-- HW OPMCONV - Added Qty2
       WSH_DEBUG_SV.logmsg(l_module_name, 'OLD QTY2 : NEW QTY2 :: ' || L_RSV_REC.SECONDARY_RESERVATION_QUANTITY
                                           ||': '|| L_RSV_NEW_REC.SECONDARY_RESERVATION_QUANTITY  );
     END IF;
     --
     l_rsv_new_rec.attribute1  := l_line_rec.preferred_grade;
     l_rsv_new_rec.attribute2  := l_line_rec.ordered_quantity2;
     l_rsv_new_rec.attribute3  := l_line_rec.ordered_quantity_uom2;

-- Added 'RETAIN_RSV' for bug 4721577
                if ( NVL(p_unreserve_mode,'UNRESERVE') in ( 'RETAIN_RSV', 'UNRESERVE' ) ) then
 -- 2587777               -- Ato Item  and Patchset level higher than 'H', i.e. from 'I' onwards
         IF ( ( ( l_line_rec.ato_line_id IS NOT NULL      AND
                         G_ATO_RSV_PROFILE  = 'Y'     AND
                 nvl(p_override_retain_ato_rsv, 'N') = 'N' ) OR
                 ( p_unreserve_mode = 'RETAIN_RSV' ) ) AND
                           G_CODE_RELEASE_LEVEL > '110508' ) THEN

           --   transfer reservation for ATOs
           --   2747520: At this point, it is assumed that the Rsv. records are Staged Only (filtered above) and
           --    the detailed_qty. for such staged recs. will be always 0

           l_rsv_new_rec.reservation_quantity         := l_qty_to_unreserve ;
           l_rsv_new_rec.primary_reservation_quantity := l_qty_to_unreserve ;
-- HW OPMCONV- Added Qty2
           l_rsv_new_rec.secondary_reservation_quantity := l_qty2_to_unreserve ;
           l_rsv_new_rec.detailed_quantity            := least(nvl(l_rsv_rec.detailed_quantity, 0), l_qty_to_unreserve);
-- HW OPMCONV- Added Qty2
           l_rsv_new_rec.secondary_detailed_quantity  := least(nvl(l_rsv_rec.secondary_detailed_quantity, 0), l_qty2_to_unreserve);
-- 2847687 : after discussion with INV the Req.date will now be passed on as date_sched instead of sysdate
           l_rsv_new_rec.requirement_date             := l_line_rec.date_scheduled;
           l_rsv_new_rec.ship_ready_flag              := 2;
           -- BUG # 9583775: Pass staged flag as 'N' to match and consolidate
           --                with the other reservation records.
           --                Removed the code which queries and updates staged flag to 'N'
           l_rsv_new_rec.staged_flag                  := 'N';
-- R12, X-dock
           l_rsv_new_rec.demand_source_line_detail   := null;

            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'NEW Split Record QTY : Dtld QTY :: ' ||
                                                   L_RSV_NEW_REC.RESERVATION_QUANTITY ||': '||
                                                   L_RSV_NEW_REC.DETAILED_QUANTITY  );
-- HW OPMCONV - Added Qty2
              WSH_DEBUG_SV.logmsg(l_module_name, 'NEW Split Record QTY2 : Dtld QTY2 :: ' ||
                                                   L_RSV_NEW_REC.SECONDARY_RESERVATION_QUANTITY ||': '||
                                                   L_RSV_NEW_REC.SECONDARY_DETAILED_QUANTITY  );
            END IF;
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.TRANSFER_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --

-- HW OPMCONV - NULL Qty2 if they are not presents
        IF ( (  l_rsv_new_rec.secondary_reservation_quantity = 0 OR
              l_rsv_new_rec.secondary_reservation_quantity = FND_API.G_MISS_NUM )
            OR ( l_rsv_new_rec.secondary_detailed_quantity = 0 OR
                 l_rsv_new_rec.secondary_detailed_quantity = FND_API.G_MISS_NUM ) ) THEN
                l_rsv_new_rec.secondary_reservation_quantity := NULL;
                l_rsv_new_rec.secondary_detailed_quantity := NULL;
        END IF;


          INV_RESERVATION_PUB.transfer_reservation
              (p_api_version_number     => 1.0,
               p_init_msg_lst           => fnd_api.g_true,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data,
               p_original_rsv_rec       => l_rsv_rec,
               p_to_rsv_rec             => l_rsv_new_rec,
               p_original_serial_number => l_dummy_sn, -- no serial contorl
               p_to_serial_number       => l_dummy_sn, -- no serial control
               p_validation_flag        => fnd_api.g_true,
	       -- Bug 5099694
               p_over_reservation_flag  =>3,
               x_to_reservation_id      => l_new_rsv_id
              );
              --
              IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS TRANSFER RESERVATION: ' || L_RETURN_STATUS  );
               WSH_DEBUG_SV.log(l_module_name,'New Rec: reservation id: ', l_new_rsv_id);
              END IF;
              --

              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

           ELSE  -- (i.e. Not an ATO )
-- 2587777
   IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'TWO Before calculation l_qty_to_unreserve: ' || l_qty_to_unreserve  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'TWO Before calculation _rsv_new_rec.reservation_quantity: ' || l_rsv_new_rec.reservation_quantity  );

       END IF;

            l_rsv_new_rec.reservation_quantity :=  l_rsv_rec.reservation_quantity - l_qty_to_unreserve ;
-- HW OPMCONV - Added Qty2
            l_rsv_new_rec.secondary_reservation_quantity :=  l_rsv_rec.secondary_reservation_quantity - l_qty2_to_unreserve ;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'ONE After calculation l_rsv_new_rec.reservation_quantity: ' || l_rsv_new_rec.reservation_quantity  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'ONE After calculation l_rsv_new_rec.secondary_reservation_quantity: ' || l_rsv_new_rec.secondary_reservation_quantity  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'TWO Before calculation ll_rsv_new_rec.primary_reservation_quantity: ' || l_rsv_new_rec.primary_reservation_quantity );
                WSH_DEBUG_SV.logmsg(l_module_name, 'TWO Before calculation l_rsv_rec.reservation_quantity: ' || l_rsv_rec.reservation_quantity );
-- HW OPMCONV - Added Qty2
                WSH_DEBUG_SV.logmsg(l_module_name, 'TWO Before calculation ll_rsv_new_rec.secondary_reservation_quantity: ' || l_rsv_new_rec.secondary_reservation_quantity );
                WSH_DEBUG_SV.logmsg(l_module_name, 'TWO Before calculation l_rsv_rec.secondary_reservation_quantity: ' || l_rsv_rec.secondary_reservation_quantity );

            END IF;

            l_rsv_new_rec.primary_reservation_quantity := l_rsv_rec.reservation_quantity - l_qty_to_unreserve ;
-- HW OPMCONV - Added Qty2
            l_rsv_new_rec.secondary_reservation_quantity := l_rsv_rec.secondary_reservation_quantity - l_qty2_to_unreserve ;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'TWO After calculation ll_rsv_new_rec.primary_reservation_quantity: ' || l_rsv_new_rec.primary_reservation_quantity );
              WSH_DEBUG_SV.logmsg(l_module_name, 'TWO After calculation ll_rsv_new_rec.secondary_reservation_quantity: ' || l_rsv_new_rec.secondary_reservation_quantity );
            END IF;

           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.UPDATE_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           -- HW OPMCONV - NULL Qty2 if they are not presents
        IF (  l_rsv_new_rec.secondary_reservation_quantity = 0  OR
              l_rsv_new_rec.secondary_reservation_quantity = FND_API.G_MISS_NUM ) THEN

            l_rsv_new_rec.secondary_reservation_quantity := NULL;

        END IF;

           inv_reservation_pub.update_reservation
             (p_api_version_number     => 1.0,
              p_init_msg_lst           => fnd_api.g_true,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              p_original_rsv_rec       => l_rsv_rec,
              p_to_rsv_rec             => l_rsv_new_rec,
              p_original_serial_number => l_dummy_sn, -- no serial contorl
              p_to_serial_number       => l_dummy_sn, -- no serial control
              p_validation_flag        => fnd_api.g_true,
	     -- Bug 5099694
              p_over_reservation_flag  =>3
             );
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING INVS UPDATE_RESERVATION: ' || L_RETURN_STATUS  );
           END IF;
           --
           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN   -- UnExp Erro
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN    -- STS Error
            IF l_msg_data is not null THEN     -- msg.data not null
              fnd_message.set_encoded(l_msg_data);
              l_buffer := fnd_message.get;
             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.ADD_TEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             oe_msg_pub.add_text(p_message_text => l_buffer);
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR : '|| L_BUFFER  );
             END IF;
             --
            END IF;    -- msg.data not null
            RAISE FND_API.G_EXC_ERROR;
           END IF;      --  UnExp Error
        END IF;     -- (if ATO ..)
    else  -- p_unreserve_mode = 'CYCLE_COUNT'
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit TWO INV_PICK_RELEASE_PUB.RESERVE_UNCONFIRMED_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.log(l_module_name, 'p_missing_quantity: ' || l_qty_to_unreserve  );
          WSH_DEBUG_SV.log(l_module_name, 'p_missing_quantity2: '|| l_qty2_to_unreserve  );

      END IF;
      --

      IF ( l_qty2_to_unreserve = 0 or l_qty2_to_unreserve = FND_API.G_MISS_NUM) THEN
          l_qty2_to_unreserve := NULL;
      END IF;

      Inv_Pick_Release_Pub.Reserve_Unconfirmed_Quantity(
       p_api_version => 1.0,
       p_init_msg_list => FND_API.G_FALSE,
       p_commit => FND_API.G_FALSE,
       x_return_status => l_reserve_status,
       x_msg_count => l_reserve_msg_count,
       x_msg_data => l_reserve_msg_data,
       p_missing_quantity => l_qty_to_unreserve ,
       p_missing_quantity2 => l_qty2_to_unreserve ,
       p_reservation_id => l_rsv_rec.reservation_id ,
       p_demand_source_header_id => l_sales_order_id,
       p_demand_source_line_id => l_line_rec.line_id,
       p_organization_id => l_rsv_rec.organization_id,
       p_inventory_item_id => l_rsv_rec.inventory_item_id,
       p_subinventory_code => l_rsv_rec.subinventory_code ,
       p_locator_id => l_rsv_rec.locator_id,
       p_revision => l_rsv_rec.revision,
       p_lot_number => l_rsv_rec.lot_number);
     IF ((l_reserve_status = WSH_UTIL_CORE.G_RET_STS_ERROR) or
      (l_reserve_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN   -- Sts or UnExp. Error
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'RESERVE UNCONFIRMED QUANTITY FAILED'  );
      END IF;
      --
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'MESSAGE COUNT: '|| TO_CHAR ( L_RESERVE_MSG_COUNT )  );
      END IF;
      --
       IF (l_reserve_msg_count = 0)  or (l_reserve_msg_count is NULL) THEN   -- Msg. Count
        null;
       ELSE
        FOR i in 1 ..l_reserve_msg_count
        LOOP
         l_reserve_message := fnd_msg_pub.get(i,'T');
         l_reserve_message := replace(l_reserve_message,chr(0), ' ');
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  L_RESERVE_MESSAGE  );
         END IF;
         --
        END LOOP;
       END if;     -- If Msg. Count
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'RESERVE_UNCONFIRMED_QUANTITY FAILED.. GOING ON... '  );
      END IF;
      --
     END IF;   -- Sts or UnExp. Error
    END IF;    -- UnReserve Mode
    goto end_of_loop; -- Bug 2100800: Get out of the loop as there should be nothing more to unreserve.
   END IF;          -- Staged and  Cycle-Count
  END IF;  --  2747520: Cancel Unstaged
 END LOOP;
 null;

-- HW OPMCONV - Removed brnaching the code

 <<end_of_loop>>

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'EXITING UNRESERVE_DELIVERY_DETAIL '  );
  END IF;
  --

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  -- bug 2442178: added expected exceptions to appropriately set return status
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
    return;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
    return;

  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.UNRESERVE_DELIVERY_DETAIL',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Unreserve_delivery_detail ;


--
--Procedure:      Assign_Detail_to_Delivery
--Parameters:      p_detail_id,
--           p_delivery_id,
--           x_return_status
--           x_dlvy_has_lines : 'Y' :delivery has non-container lines.
--                              'N' : delivery does not have non-container lines
--           x_dlvy_freight_Terms_code : Delivery's freight term code
--Description:      This procedure will assign the specified
--           delivery_detail to the specIFied delivery
--           and return the status

PROCEDURE Assign_Detail_to_Delivery(
   P_DETAIL_ID     IN number,
   P_DELIVERY_ID     IN number,
   X_RETURN_STATUS    OUT NOCOPY  varchar2,
    x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
    x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2, -- J-IB-NPARIKH
    p_caller        IN VARCHAR2 --bug 5100229
   ) IS

CURSOR c_topmost_container IS
SELECT  delivery_detail_id
FROM  wsh_delivery_assignments_v
WHERE parent_delivery_detail_id is null
START WITH delivery_detail_id =p_detail_id
CONNECT BY prior parent_delivery_detail_id = delivery_detail_id
and rownum < 10;
--restricting to 10 levels (performance)

-- /== Workflow Changes
--WF: CMR
CURSOR c_get_del_lines_count(p_delv_id NUMBER) IS
SELECT 1
  FROM dual
 WHERE EXISTS
     ( SELECT 'x'
         FROM wsh_delivery_assignments  wda
            , wsh_delivery_details      wdd
        WHERE wda.delivery_id = p_delv_id
          AND (wda.type IN ('S', 'O') OR
               wda.type IS NULL)
          AND wda.delivery_detail_id = wdd.delivery_detail_id
          AND wdd.container_flag = 'N'
     );

CURSOR c_get_picked_lines_count(p_delv_id NUMBER) IS
SELECT 1
  FROM dual
 WHERE EXISTS
     ( SELECT 'x'
         FROM wsh_delivery_assignments  wda
            , wsh_delivery_details      wdd
        WHERE wda.delivery_id = p_delv_id
          AND (wda.type IN ('S', 'O') OR
               wda.type IS NULL)
          AND wda.delivery_detail_id = wdd.delivery_detail_id
          AND wdd.container_flag = 'N'
          AND wdd.pickable_flag = 'Y'
          AND wdd.released_status NOT IN ('R','X','N')
     );

CURSOR c_get_org_id ( p_delv_id NUMBER) IS
 SELECT organization_id
 FROM wsh_new_deliveries
 WHERE delivery_id=p_delv_id;

l_org_id NUMBER;
l_del_lines_count NUMBER;
l_process_started VARCHAR2(1);
l_return_status VARCHAR2(1);
l_wf_rs VARCHAR2(1);
l_start_wf BOOLEAN;
l_raise_pickinitiated_event BOOLEAN;
l_count_picked_lines Number;
l_del_entity_ids WSH_UTIL_CORE.column_tab_type;
l_purged_count    NUMBER;
--WF: CMR
l_raise_carrierselect_event BOOLEAN;
l_del_ids WSH_UTIL_CORE.ID_tab_type;
l_del_old_carrier_ids WSH_UTIL_CORE.ID_tab_type;
-- Workflow Changes ==/


l_topmost_delivery_detail_id NUMBER;

assign_fail exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_DETAIL_TO_DELIVERY';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
        WSH_DEBUG_SV.log(l_module_name,'x_dlvy_has_lines',x_dlvy_has_lines);
        WSH_DEBUG_SV.log(l_module_name,'x_dlvy_freight_terms_code',x_dlvy_freight_terms_code);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  /* if detail is not assigned to a container, update WDA. else find topmost container
  in the hierarchy (this can be a detail in case of loose details), iterate thru each
    level and assign each level to delivery any error in any level => rollback changes*/

  SAVEPOINT before_assign_topmost_cont;
  OPEN  c_topmost_container;
  FETCH   c_topmost_container INTO l_topmost_delivery_detail_id;
  IF    (c_topmost_container%FOUND)  THEN

     --/== Workflow Changes
     l_start_wf :=FALSE;
     l_raise_pickinitiated_event :=FALSE;

     OPEN c_get_del_lines_count(p_delivery_id);
     FETCH c_get_del_lines_count INTO l_del_lines_count;
     CLOSE c_get_del_lines_count;
     l_del_lines_count := NVL(l_del_lines_count,0);

     OPEN c_get_picked_lines_count(p_delivery_id);
     FETCH c_get_picked_lines_count INTO l_count_picked_lines;
     CLOSE c_get_picked_lines_count;
     l_count_picked_lines := NVL(l_count_picked_lines,0);

     IF (l_del_lines_count = 0) THEN
	 l_start_wf := TRUE;
	 l_raise_pickinitiated_event :=TRUE;
	 --WF: CMR CURRENTLY NOT IN USE
	 --l_raise_carrierselect_event :=TRUE;
     ELSIF (l_count_picked_lines =0) THEN
	l_raise_pickinitiated_event :=TRUE;
     END IF;
     -- Workflow Changes ==/
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_TOP_DETAIL_TO_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

     wsh_delivery_details_actions.assign_top_detail_to_delivery(
        P_DETAIL_ID => l_topmost_delivery_detail_id,
        P_DELIVERY_ID => p_delivery_id,
        X_RETURN_STATUS => x_return_status,
        x_dlvy_has_lines          => x_dlvy_has_lines,   -- J-IB-NPARIKH
        x_dlvy_freight_terms_code => x_dlvy_freight_terms_code,     -- J-IB-NPARIKHS
        p_caller         => p_caller --bug 5100229
            );

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      RAISE assign_fail;
    END IF;

     --/==  Workflow Changes
     IF (l_start_wf OR l_raise_pickinitiated_event ) THEN
             OPEN c_get_del_lines_count(p_delivery_id);
             FETCH c_get_del_lines_count INTO l_del_lines_count;
             CLOSE c_get_del_lines_count;
             l_del_lines_count := NVL(l_del_lines_count,0);

             OPEN c_get_picked_lines_count(p_delivery_id);
             FETCH c_get_picked_lines_count INTO l_count_picked_lines;
             CLOSE c_get_picked_lines_count;
             l_count_picked_lines := NVL(l_count_picked_lines,0);

	     OPEN c_get_org_id ( p_delivery_id );
	     FETCH c_get_org_id INTO l_org_id;
	     CLOSE c_get_org_id;
     END IF;

     IF ( l_start_wf AND l_del_lines_count > 0 )THEN
	-- Check for existing WF process and if it exists Call Purge Workflow
	-- After Purge, start a new workflow Process.
	-- Purging is required since a New Delivery Workflow will be selected according
	-- to the Delivery Detail Assigned to it
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.CHECK_WF_EXISTS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	WSH_WF_STD. Check_Wf_Exists(
						p_entity_type => 'DELIVERY',
						p_entity_id => p_delivery_id,
						x_wf_process_exists => l_process_started,
						x_return_status => l_return_status);
	IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'L_PROCESS_STARTED',l_process_started);
			WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
	END IF;

	IF(l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_process_started='Y' ) THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.PURGE_ENTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		l_del_entity_ids(1) := p_delivery_id;
		WSH_WF_STD.Purge_Entity(
			p_entity_type => 'DELIVERY',
			p_entity_ids  => l_del_entity_ids,
			x_success_count  => l_purged_count,
			x_return_status => l_return_status);
		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'L_PURGED_COUNT',l_purged_count);
			WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;
	 END IF;	-- If WorkFlow Exists

	 IF(l_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.START_WF_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		 WSH_WF_STD.start_wf_process(
								p_entity_type		=> 'DELIVERY',
								p_entity_id		=> p_delivery_id,
								p_organization_id	=>l_org_id,
								x_process_started	=>l_process_started,
								x_return_status	=>l_return_status
								 );
		 IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'L_PROCESS_STARTED',l_process_started);
			WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		 END IF;
	 END IF;

     END IF;-- If Start Workflow

     --Raise Event: Pick To Pod Workflow
     IF ( l_raise_pickinitiated_event AND  l_count_picked_lines > 0 ) THEN
		IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		WSH_WF_STD.Raise_Event(
					p_entity_type => 'DELIVERY',
					p_entity_id =>  p_delivery_id,
					p_event => 'oracle.apps.wsh.delivery.pik.pickinitiated' ,
					p_organization_id =>  l_org_id,
					x_return_status => l_wf_rs ) ;
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  p_delivery_id );
		     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
		 END IF;
     END IF;
     -- Done Raise Event: Pick To Pod Workflow
     /* CURRENTLY NOT IN USE
     --WF: CMR
     IF (l_raise_carrierselect_event) THEN
       l_del_ids(1) := p_delivery_id;
       WSH_WF_STD.Get_Carrier(p_del_ids => l_del_ids,
                              x_del_old_carrier_ids => l_del_old_carrier_ids,
                              x_return_status => l_wf_rs);

       IF (l_del_old_carrier_ids(1) IS NOT NULL) THEN

         WSH_WF_STD.Assign_Unassign_Carrier(p_delivery_id => l_del_ids(1),
                                            p_old_carrier_id => NULL,
                                            p_new_carrier_id => l_del_old_carrier_ids(1),
                                            x_return_status => l_wf_rs);
       END IF;

     END IF;
     */
     -- Workflow Changes ==/

  END IF;--for topmost container
  CLOSE  c_topmost_container;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return;
  --
  exception
    WHEN assign_fail THEN
      ROLLBACK TO before_assign_topmost_cont;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'ASSIGN_FAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ASSIGN_FAIL');
      END IF;
      --
    WHEN others THEN
      ROLLBACK TO before_assign_topmost_cont;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DELIVERY_DETAIL',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Assign_Detail_to_Delivery;

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Assign_Detail_to_Delivery(
    P_DETAIL_ID     IN NUMBER,
    P_DELIVERY_ID   IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY  VARCHAR2,
    p_caller        IN VARCHAR2 --bug 5100229
    ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'Assign_Detail_to_Delivery';
--
l_has_lines               VARCHAR2(1);
l_dlvy_freight_terms_code VARCHAR2(30);
--
BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_has_lines := WSH_DELIVERY_VALIDATIONS.has_lines
                        (
                            p_delivery_id => p_delivery_id
                        );
    --
    Assign_Detail_to_Delivery
        (
            p_detail_id               => p_detail_id,
            p_delivery_id             => p_delivery_id,
            X_RETURN_STATUS           => X_RETURN_STATUS,
            x_dlvy_has_lines          => l_has_lines,
            x_dlvy_freight_Terms_code => l_dlvy_freight_Terms_code,
            p_caller                  => p_caller --bug 5100229
        );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.Assign_Detail_to_Delivery',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Assign_Detail_to_Delivery;

-- OTM R12 : assign delivery detail

--========================================================================
-- PROCEDURE : Pre_Otm_Assign_Del_Detail
--
--             API added for R12 Glog Integration
--
-- PURPOSE :   To check whether the delivery was empty(no actual details)
--             before any delivery_detail is assigned.  Also checks if
--             if detail and containers are already on the same delivery
--
-- PARAMETERS:
--     p_delivery_id         delivery id
--     p_detail_id           delivery detail id
--     p_container1_id       container 1's id
--     p_container2_id       container 2's id
--     p_assignment_type     assignment types can be DD2D, DD2C, C2C.
--                           this covers detail to delivery, detail to container,
--                           container to container, and container to delivery will
--                           be same as DD2D.
--     x_delivery_was_empty  TRUE if it was empty, FALSE if it was not empty
--     x_tms_update          TRUE if tms update needed, FALSE if detail and
--                           containers already on the same delivery
--     x_gross_weight1       the gross weight of the detail or container getting assigned
--     x_gross_weight2       the gross weight of the container being assigned to.
--     x_return status       SUCCESS or ERROR
--========================================================================


PROCEDURE Pre_Otm_Assign_Del_Detail
                    (p_delivery_id        IN         NUMBER,
                     p_detail_id          IN         NUMBER,
                     p_container1_id      IN         NUMBER,
                     p_container2_id      IN         NUMBER,
                     p_assignment_type    IN         VARCHAR2,
                     x_delivery_was_empty OUT NOCOPY BOOLEAN,
                     x_assign_update      OUT NOCOPY BOOLEAN,
                     x_gross_weight1      OUT NOCOPY NUMBER,
                     x_gross_weight2      OUT NOCOPY NUMBER,
                     x_return_status      OUT NOCOPY VARCHAR2) IS

  CURSOR c_get_delivery_id(p_id IN NUMBER) IS
    SELECT delivery_id
    FROM   wsh_delivery_assignments
    WHERE  delivery_detail_id = p_id;

  CURSOR c_get_gross_weight (p_id NUMBER) IS
    SELECT nvl(gross_weight, 0)
    FROM   wsh_delivery_details
    WHERE  delivery_detail_id = p_id;

  l_is_delivery_empty    VARCHAR2(1);
  l_delivery1            NUMBER;
  l_delivery2            NUMBER;
  l_debug_on             BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PACKAGE_NAME||'.'||'Pre_Otm_Assign_Del_Detail';


BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
      WSH_DEBUG_SV.log(l_module_name, 'P_DETAIL_ID', p_detail_id);
      WSH_DEBUG_SV.log(l_module_name, 'P_CONTAINER1_ID', p_container1_id);
      WSH_DEBUG_SV.log(l_module_name, 'P_CONTAINER2_ID', p_container2_id);
      WSH_DEBUG_SV.log(l_module_name, 'P_ASSIGNMENT_TYPE', p_assignment_type);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_delivery_was_empty := FALSE;
  x_assign_update := TRUE;  -- default to true unless everything on the same delivery.

  IF (p_assignment_type = 'DD2D') THEN --detail to delivery, delivery id provided

    OPEN c_get_delivery_id(p_detail_id);
    FETCH c_get_delivery_id INTO l_delivery1;
    CLOSE c_get_delivery_id;

    OPEN c_get_gross_weight(p_detail_id);
    FETCH c_get_gross_weight INTO x_gross_weight1;
    CLOSE c_get_gross_weight;

    IF (l_delivery1 = p_delivery_id) THEN --already assigned to the delivery
      x_assign_update := FALSE; --same delivery, no need to update
    ELSE

      l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(p_delivery_id);
      IF (l_is_delivery_empty = 'Y') THEN
        x_delivery_was_empty := TRUE;
      ELSIF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  ELSIF (p_assignment_type IN ('DD2C', 'C2C')) THEN

    IF (p_assignment_type = 'DD2C') THEN
      --detail to container, check delivery id of p_detail_id and p_container1_id
      OPEN c_get_delivery_id(p_detail_id);
      FETCH c_get_delivery_id INTO l_delivery1;
      CLOSE c_get_delivery_id;

      OPEN c_get_delivery_id(p_container1_id);
      FETCH c_get_delivery_id INTO l_delivery2;
      CLOSE c_get_delivery_id;

      OPEN c_get_gross_weight(p_detail_id);
      FETCH c_get_gross_weight INTO x_gross_weight1;
      CLOSE c_get_gross_weight;

      OPEN c_get_gross_weight(p_container1_id);
      FETCH c_get_gross_weight INTO x_gross_weight2;
      CLOSE c_get_gross_weight;

    ELSE
      --container to container, check delivery id of p_container1_id and p_container2_id
      OPEN c_get_delivery_id(p_container1_id);
      FETCH c_get_delivery_id INTO l_delivery1;
      CLOSE c_get_delivery_id;

      OPEN c_get_delivery_id(p_container2_id);
      FETCH c_get_delivery_id INTO l_delivery2;
      CLOSE c_get_delivery_id;

      OPEN c_get_gross_weight(p_container1_id);
      FETCH c_get_gross_weight INTO x_gross_weight1;
      CLOSE c_get_gross_weight;

      OPEN c_get_gross_weight(p_container2_id);
      FETCH c_get_gross_weight INTO x_gross_weight2;
      CLOSE c_get_gross_weight;

    END IF;

    IF (l_delivery1 = l_delivery2) THEN --both belong to same delivery and not NULL
      x_assign_update := FALSE; --same delivery, no need to update
    ELSIF (l_delivery1 IS NOT NULL) THEN --cannot have both NOT NULL

      l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_delivery1);
      IF (l_is_delivery_empty = 'Y') THEN
        x_delivery_was_empty := TRUE;
      ELSIF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;
    ELSIF (l_delivery2 IS NOT NULL) THEN

      l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_delivery2);
      IF (l_is_delivery_empty = 'Y') THEN
        x_delivery_was_empty := TRUE;
      ELSIF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  ELSE
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Error in wrong assignment_type', p_assignment_type);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_delivery_was_empty', x_delivery_was_empty);
      WSH_DEBUG_SV.log(l_module_name, 'x_assign_update', x_assign_update);
      WSH_DEBUG_SV.log(l_module_name, 'x_gross_weight1', x_gross_weight1);
      WSH_DEBUG_SV.log(l_module_name, 'x_gross_weight2', x_gross_weight2);
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    IF c_get_gross_weight%ISOPEN THEN
      CLOSE c_get_gross_weight;
    END IF;

    IF c_get_delivery_id%ISOPEN THEN
      CLOSE c_get_delivery_id;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    IF c_get_gross_weight%ISOPEN THEN
      CLOSE c_get_gross_weight;
    END IF;

    IF c_get_delivery_id%ISOPEN THEN
      CLOSE c_get_delivery_id;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION OTHERS');
    END IF;
    --
    RETURN;

END Pre_Otm_Assign_Del_Detail;

--========================================================================
-- PROCEDURE : Post_Otm_Assign_Del_Detail
--
--             API added for R12 Glog Integration
--
-- PURPOSE :   updates delivery's tms_interface_flag via API
--             based on the changes of detail assignments to the delivery
--
-- PARAMETERS:
--     p_delivery_id         delivery_id
--     p_delivery_was_empty  whether the delivery was empty before the new
--                           assignment
--     p_tms_interface_flag  delivery's latest tms_interface_flag if available
--     p_gross_weight        delivery detail's gross weight if avilable
--     p_delivery_detail_ids table of delivery detail ids to get gross weight
--     x_return status       SUCCESS or ERROR
--========================================================================

PROCEDURE Post_Otm_Assign_Del_Detail
             (p_delivery_id         IN  NUMBER,
              p_delivery_was_empty  IN  BOOLEAN,
              p_tms_interface_flag  IN  VARCHAR2,
              p_gross_weight        IN  NUMBER,
              x_return_status       OUT NOCOPY VARCHAR2) IS


  l_call_update          VARCHAR2(1);
  l_return_status        VARCHAR2(1);
  l_tms_interface_flag   WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
  l_is_delivery_empty    VARCHAR2(1);
  l_interface_flag_tab   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_delivery_info        WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
  l_delivery_id_tab      WSH_UTIL_CORE.ID_TAB_TYPE;
  l_num_warnings         NUMBER;
  l_debug_on             BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PACKAGE_NAME||'.'||'Post_Otm_Assign_Del_Detail';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
      WSH_DEBUG_SV.log(l_module_name, 'P_DELIVERY_WAS_EMPTY', p_delivery_was_empty);
      WSH_DEBUG_SV.log(l_module_name, 'P_TMS_INTERFACE_FLAG', p_tms_interface_flag);
      WSH_DEBUG_SV.log(l_module_name, 'P_GROSS_WEIGHT', p_gross_weight);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_call_update := 'Y';
  l_delivery_id_tab(1) := p_delivery_id;

  IF (p_delivery_was_empty) THEN
    l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(p_delivery_id);

    IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_is_delivery_empty = 'Y') THEN
      l_call_update := 'N';
    ELSIF (l_is_delivery_empty = 'N') THEN
      IF (p_tms_interface_flag IS NOT NULL) THEN
        l_tms_interface_flag := p_tms_interface_flag;
      ELSE
        WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                     p_delivery_id   => p_delivery_id,
                     x_delivery_rec  => l_delivery_info,
                     x_return_status => l_return_status);

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_delivery_information');
          END IF;
          raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warnings := l_num_warnings + 1;
        END IF;
        l_tms_interface_flag := nvl(l_delivery_info.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT);

      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'P_DELIVERY_WAS_EMPTY - L_TMS_INTERFACE_FLAG', l_tms_interface_flag);
      END IF;

      IF (l_tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) THEN
        l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED;
      ELSIF (l_tms_interface_flag in
             (WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
              WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS)) THEN
        l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
      ELSE
        l_call_update := 'N';
      END IF;
    END IF;
  ELSE -- (NOT p_delivery_was_empty)
   l_interface_flag_tab(1) := NULL;
  --Bug7608629
  --removed code which checked for gross weight
  --now irrespective of gross weight  UPDATE_TMS_INTERFACE_FLAG will be called
  END IF;

  IF (l_call_update = 'Y') THEN
    WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
               p_delivery_id_tab        => l_delivery_id_tab,
               p_tms_interface_flag_tab => l_interface_flag_tab,
               x_return_status          => l_return_status);

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG '||l_return_status);
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      l_num_warnings := l_num_warnings + 1;
    END IF;
  END IF;


  IF (l_num_warnings > 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION OTHERS');
    END IF;
    --
    RETURN;
END Post_Otm_Assign_Del_Detail;

-- End of OTM R12 : assign delivery detail


--
--Procedure:    Assign_Detail_to_Cont
--Parameters:      p_detail_id,
--           p_parent_detail_id,
--           x_return_status
--Description:      This procedure will assign the specified
--           delivery_detail to the specIFied container
--           and return the status

--        if container is already assigned to a delivery,
--        its parent containers and child containers must
--        be also assigned to the same delivery already.
--        So all it needs to do IS just get the delivery_id
--        from the current container and assign it to the detail also.

--        if the detail is already assigned to a delivery,
--        then drill up and down to update the delivery id for all the
--        parent and chile containers



PROCEDURE Assign_Detail_To_Cont(
  p_detail_id     IN NUMBER,
  p_parent_detail_id   IN NUMBER,
  x_return_status    OUT NOCOPY  VARCHAR2)
IS

l_del_id_for_container c_del_id_for_cont_or_detail%ROWTYPE;
l_del_id_for_detail c_del_id_for_cont_or_detail%ROWTYPE;

l_group_by_flags WSH_DELIVERY_AUTOCREATE.group_by_flags_rec_type;

invalid_detail exception;
l_plan_flag varchar2(1);
l_content_count NUMBER;

/* H projects: pricing integration csun */
m     NUMBER := 0;
l_del_tab   WSH_UTIL_CORE.Id_Tab_Type;
l_return_status         VARCHAR2(1);
mark_reprice_error  EXCEPTION;
l_ship_to               NUMBER;
l_container_has_content BOOLEAN;
l_mdc_detail_tab WSH_UTIL_CORE.Id_Tab_Type;
l_ignore_det_tab WSH_UTIL_CORE.Id_Tab_Type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_DETAIL_TO_CONT';
--
  l_display_error   BOOLEAN;

  CURSOR c_get_shipto (v_container_id NUMBER) IS
  SELECT ship_to_location_id
  FROM wsh_delivery_details
  WHERE delivery_detail_id = v_container_id;

  -- Bug 3715176
  CURSOR c_get_plan_flag (v_delivery_id NUMBER) IS
  SELECT nvl(planned_flag,'N')
  FROM   wsh_new_deliveries
  WHERE  delivery_id = v_delivery_id;

  CURSOR c_get_content_count(v_delivery_detail_id NUMBER) IS
  SELECT count(*)
  FROM   wsh_delivery_assignments_v wda
  WHERE	 wda.parent_delivery_detail_id = v_delivery_detail_id And rownum = 1;
  -- Bug 3715176

  -- Bug 4452930
  CURSOR c_topmost_container(p_detail_id NUMBER) IS
  SELECT  delivery_detail_id
  FROM  wsh_delivery_assignments_v
  WHERE parent_delivery_detail_id is null
  START WITH delivery_detail_id =p_detail_id
  CONNECT BY prior parent_delivery_detail_id = delivery_detail_id
  and rownum < 10;
  --restricting to 10 levels (performance)
  l_topmost_cont NUMBER;

  -- Bug 4452930

l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_action_rec wsh_delivery_autocreate.action_rec_type;
l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
l_matched_entities wsh_util_core.id_tab_type;
l_out_rec wsh_delivery_autocreate.out_rec_type;
l_group_index NUMBER;

l_num_warnings          number := 0;

-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_sync_tmp_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_operation_type VARCHAR2(100);
-- K LPN CONV. rv

-- OTM R12 : update delivery
l_delivery_info_tab       WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_delivery_info           WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
l_new_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_tms_update              VARCHAR2(1);
l_trip_not_found          VARCHAR2(1);
l_trip_info_rec           WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
l_tms_version_number      WSH_NEW_DELIVERIES.TMS_VERSION_NUMBER%TYPE;
l_gc3_is_installed        VARCHAR2(1);

-- End of OTM R12 : update delivery

-- OTM R12 : assign delivery detail
l_delivery_was_empty      BOOLEAN;
l_tms_interface_flag      WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
l_gross_weight1           WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE;
l_gross_weight2           WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE;
l_delivery_detail_ids     WSH_GLBL_VAR_STRCT_GRP.NUM_TBL_TYPE;
l_assign_update           BOOLEAN;

-- End of OTM R12 : assign delivery detail

BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PARENT_DETAIL_ID',P_PARENT_DETAIL_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  l_assign_update := FALSE; --default assignment tms update to false
  -- End of OTM R12


  OPEN c_del_id_for_cont_or_detail(p_parent_detail_id);
  FETCH c_del_id_for_cont_or_detail into l_del_id_FOR_container;
  CLOSE c_del_id_for_cont_or_detail;

  OPEN c_del_id_for_cont_or_detail(p_detail_id);
  FETCH c_del_id_for_cont_or_detail into l_del_id_for_detail;
  CLOSE c_del_id_for_cont_or_detail;

  -- K LPN CONV. rv
  l_wms_org := wsh_util_validate.check_wms_org(l_del_id_FOR_container.organization_id);
  -- K LPN CONV. rv

  -- J: W/V Changes
  -- Return if the dd is already assigned to the specified container
  IF l_del_id_for_detail.parent_delivery_detail_id = p_parent_detail_id THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DD '||p_detail_id||' is already assigned to '||p_parent_detail_id||'. Returning');
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
  END IF;


  OPEN c_get_shipto(p_parent_detail_id);
  FETCH c_get_shipto into l_ship_to;
  IF c_get_shipto%NOTFOUND THEN
              l_ship_to := NULL;
  END IF;
  CLOSE c_get_shipto;

  l_container_has_content := l_ship_to IS NOT NULL;

  IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_del_id_FOR_container',
                           l_del_id_FOR_container.delivery_id);
          WSH_DEBUG_SV.log(l_module_name,'l_del_id_FOR_detail',
                           l_del_id_for_detail.delivery_id);
          WSH_DEBUG_SV.log(l_module_name,'l_ship_to', l_ship_to);
  END IF;
  /* Added code to check for grouping attributes */
  IF (l_del_id_for_detail.organization_id <>
                                l_del_id_for_container.organization_id) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_ORG_DIFF');
           FND_MESSAGE.SET_TOKEN('ENTITY1',p_detail_id);
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('ENTITY2',
              nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                           p_parent_detail_id));
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
  END IF;
  IF (l_del_id_for_detail.ship_from_location_id <>
                           l_del_id_for_container.ship_from_location_id) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
           FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('CONT_NAME',
                nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                        p_parent_detail_id));
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
  END IF;

  --J TP Release
  IF (l_del_id_for_detail.ignore_for_planning <>
                           l_del_id_for_container.ignore_for_planning) THEN

           -- R12: MDC
           -- If called by WMS, and line is part of a consol delivery,
           -- then the ignore for planning flag is always 'Y'. For WMS,
           -- we need to set the parent consol's ignore for planning status
           -- to be 'Y' before we attempt to pack.

           IF (l_wms_org = 'Y') AND
              ((l_del_id_for_detail.wda_type = 'O') OR (l_del_id_for_container.wda_type = 'O'))
           THEN --{
              IF l_del_id_for_detail.wda_type = 'O' THEN
                 l_ignore_det_tab(1) := p_parent_detail_id;
              ELSE
                 l_ignore_det_tab(1) := p_detail_id;
              END IF;

              WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'DLVB',
                    p_in_ids        => l_ignore_det_tab,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => x_return_status);

              IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_DIFF_IGNOREPLAN');
                 FND_MESSAGE.SET_TOKEN('ENTITY1',p_detail_id);
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('ENTITY2',
                 nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                        p_parent_detail_id));
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 RETURN;


              END IF;

           ELSE --}
              l_display_error := TRUE;
              IF (l_wms_org = 'Y')  AND (NOT l_container_has_content) THEN--{
                 --
                    l_ignore_det_tab(1) := p_parent_detail_id;
                    WSH_TP_RELEASE.change_ignoreplan_status
                      (p_entity        => 'DLVB',
                       p_in_ids        => l_ignore_det_tab,
                       p_action_code   => 'IGNORE_PLAN',
                       x_return_status => l_return_status);

                    IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN --{
                       l_display_error := TRUE;
                    ELSE
                       l_display_error := FALSE;
                    END IF;--}
              END IF ; --}

              IF l_display_error THEN --{
                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_DIFF_IGNOREPLAN');
                 FND_MESSAGE.SET_TOKEN('ENTITY1',p_detail_id);
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('ENTITY2',
                 nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                        p_parent_detail_id));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 RETURN;
              END IF; --}
           END IF;
  END IF;

  --
  -- J-IB-NPARIKH-{
  --
  IF (l_del_id_for_detail.line_direction <> l_del_id_for_container.line_direction)
  THEN
  --{
            --
            -- O line can be assigned to empty IO container
            -- IO line can be assigned to empty O container
            -- Otherwise, line and container's line direction must match
            --
            IF  l_del_id_for_detail.line_direction    IN ('O','IO')
            AND l_del_id_for_container.line_direction IN ('O','IO')
            THEN
            --{
                NULL;
            --}
            ELSE
            --{
                FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                FND_MESSAGE.SET_TOKEN('CONT_NAME',
                    nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                            p_parent_detail_id));
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
            --}
            END IF;
  --}
  END IF;
  --
  -- J-IB-NPARIKH-}
  --
  --
  IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.GET_GROUP_BY_ATTR',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_AUTOCREATE.get_group_by_attr(
           p_organization_id => l_del_id_for_detail.organization_id,
           p_client_id       => l_del_id_for_detail.client_id, -- LSP PROJECT :
           x_group_by_flags  => l_group_by_flags,
           x_return_status   => x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           x_return_status := x_return_status;
           WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
  END IF;

  /*---------
        When the container has no content then do not do these checks
        since all these attributes on the container will be null.
  ----------*/

  IF l_container_has_content THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_group_by_flags.customer',
                                                l_group_by_flags.customer);
              WSH_DEBUG_SV.log(l_module_name,'del_id_for_detail.customer',
                                        l_del_id_for_detail.customer_id);
              WSH_DEBUG_SV.log(l_module_name,'id_for_container.customer',
                                        l_del_id_for_container.customer_id);
           END IF;

    --- Bug 3715176
    -- If delivery is same for container and line then it should not check firm status.
    IF l_del_id_for_detail.delivery_id = l_del_id_for_container.delivery_id then
      NULL;

    Elsif l_del_id_for_detail.delivery_id is NOT NULL OR
          l_del_id_for_container.delivery_id is NOT NULL then
          Open  c_get_content_count(p_parent_detail_id);
	  Fetch c_get_content_count into l_content_count;
	  Close c_get_content_count;

      IF l_content_count > 0 THEN
	IF l_del_id_for_detail.delivery_id IS NOT NULL then
	     OPEN c_get_plan_flag(l_del_id_for_detail.delivery_id);
	     FETCH c_get_plan_flag into l_plan_flag;
	     CLOSE c_get_plan_flag;

  	  if l_plan_flag <> 'N' then
	         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_STATUS_NOT_PROPER');

		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
          end if;
	END IF;

	IF l_del_id_for_container.delivery_id IS NOT NULL then
	     OPEN c_get_plan_flag(l_del_id_for_container.delivery_id);
	     FETCH c_get_plan_flag into l_plan_flag;
	     CLOSE c_get_plan_flag;

  	  if l_plan_flag <> 'N' then
	         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_STATUS_NOT_PROPER');

		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
          end if;
	END IF;
      END IF;
    END IF;
    -- Bug 3715176

    /*  bug 2677298 frontport from bug 2655474: issue #1:
    **    set x_return_status to error if grouping attributes do not match
    */


    IF l_group_by_flags.customer = 'Y' THEN
              IF   (NVL(l_del_id_for_detail.customer_id,-1) <>
                             NVL(l_del_id_for_container.customer_id,-1)) THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                 FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('CONT_NAME',
                 nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                       p_parent_detail_id));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
              END IF;
   END IF;
   IF l_group_by_flags.intmed = 'Y' THEN
              IF (NVL(l_del_id_for_detail.intmed_ship_to_location_id,-1)<>
                 NVL(l_del_id_for_container.intmed_ship_to_location_id,-1))
              THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                 FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('CONT_NAME',
                  nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                  p_parent_detail_id));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
              END IF;
   END IF;

   IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'fob_code',
                                                 l_del_id_for_detail.fob_code);
               WSH_DEBUG_SV.log(l_module_name,'container fob_code',
                                              l_del_id_for_container.fob_code);
               WSH_DEBUG_SV.log(l_module_name,'fob',
                                                       l_group_by_flags.fob);
   END IF;

   IF l_group_by_flags.fob = 'Y' THEN
              IF  (NVL(l_del_id_for_detail.fob_code,'#')<>
                             NVL(l_del_id_for_container.fob_code,'#')) THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                 FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                  --
                 FND_MESSAGE.SET_TOKEN('CONT_NAME',
                 nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                       p_parent_detail_id));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
              END IF;
   END IF;
   IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'freight_terms_code',
                                     l_del_id_for_detail.freight_terms_code);
               WSH_DEBUG_SV.log(l_module_name,
                                              'container freight_terms_code',
                                    l_del_id_for_container.freight_terms_code);
                WSH_DEBUG_SV.log(l_module_name,'freight_terms',
                                               l_group_by_flags.freight_terms);
   END IF;

   IF l_group_by_flags.freight_terms = 'Y' THEN
              IF  (NVL(l_del_id_for_detail.freight_terms_code,'#')<>
                    NVL(l_del_id_for_container.freight_terms_code,'#')) THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                 FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('CONT_NAME',
                 nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                  p_parent_detail_id));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
              END IF;
   END IF;

   IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'ship_method_code',
                                        l_del_id_for_detail.ship_method_code);
              WSH_DEBUG_SV.log(l_module_name, 'container ship_method_code',
                                   l_del_id_for_container.ship_method_code);
              WSH_DEBUG_SV.log(l_module_name,'ship_method',
                                               l_group_by_flags.ship_method);
   END IF;

   IF l_group_by_flags.ship_method = 'Y' THEN
              IF  (NVL(NVL(l_del_id_for_detail.mode_of_transport,l_del_id_for_container.mode_of_transport),'#')<>
                   NVL(NVL(l_del_id_for_container.mode_of_transport,l_del_id_for_detail.mode_of_transport),'#'))
              OR  (NVL(NVL(l_del_id_for_detail.service_level,l_del_id_for_container.service_level),'#')<>
                   NVL(NVL(l_del_id_for_container.service_level,l_del_id_for_detail.service_level),'#'))
              OR  (NVL(NVL(l_del_id_for_detail.carrier_id,l_del_id_for_container.carrier_id),-1)<>
                   NVL(NVL(l_del_id_for_container.carrier_id,l_del_id_for_detail.carrier_id),-1)) THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                 FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('CONT_NAME',
                 nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                           p_parent_detail_id));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
              END IF;
    END IF;
   --
   -- LSP PROJECT : Verify client id value on DD as well as Cont.
   --          DD with x Client can be packed into a container with same client or NULL client
   IF WMS_DEPLOY.wms_deployment_mode = 'L' THEN
   --{
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Client_id', l_del_id_for_detail.client_id);
           WSH_DEBUG_SV.log(l_module_name, 'container Client_id',l_del_id_for_container.client_id);
           WSH_DEBUG_SV.log(l_module_name,'WMS_DEPLOY.wms_deployment_mode', WMS_DEPLOY.wms_deployment_mode);
       END IF;
       IF   ( NVL(l_del_id_for_detail.client_id,-1) <>  NVL(l_del_id_for_container.client_id,NVL(l_del_id_for_detail.client_id,-1))) THEN
       --{
           FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
           FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('CONT_NAME',
                nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
                                                       p_parent_detail_id));
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           return;
       --}
       END IF;
   --}
   END IF;
   -- LSP PROJECT : End
  END IF;
  /* End of Check for grouping attributes */

  IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'parent_delivery_detail_id',
                                l_del_id_for_detail.parent_delivery_detail_id);
                   WSH_DEBUG_SV.log(l_module_name,
                                     'container parent_delivery_detail_id',
                              l_del_id_for_container.parent_delivery_detail_id);
  END IF;

  /* Check to see if the line is already packed */
  IF (l_del_id_for_detail.parent_delivery_detail_id IS NOT NULL
      AND l_del_id_for_detail.parent_delivery_detail_id <>
        p_parent_detail_id
      ) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DET_PACK_ERROR');
      FND_MESSAGE.SET_TOKEN('DET_LINE',p_detail_id);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
         nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
               p_parent_detail_id));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
  END IF;
  /* End of Check to see if the line is already packed */


  -- J: W/V Changes
  IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_del_id_for_detail.released_status',
                                                      l_del_id_for_detail.released_status);
  END IF;

  IF l_del_id_for_detail.released_status = 'C' THEN
      Raise invalid_detail;
  END IF;


  /*  bug 2677298 frontport from bug 2655474: issue #2:
  **    set x_return_status to error if line and container are in different deliveries.
  */
  IF (l_del_id_for_detail.delivery_id <> l_del_id_for_container.delivery_id)  THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_DIFF_DELIVERIES');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    FND_MESSAGE.SET_TOKEN('CONT_NAME',
       nvl(wsh_container_utilities.get_cont_name(p_parent_detail_id),
             p_parent_detail_id));
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.Add_Message(x_return_status);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;

  -- J: W/V Changes
  -- The first DD_WV_Post_Process call will decrement the DD W/V from delivery
  -- The second DD_WV_Post_Process call will increment the delivery W/V with container W/V (since container has to be
  -- assigned to the delivery if the detail being assigned to container is already assigned to delivery)
  -- The third DD_WV_Post_Process will will increment the container W/V with DD W/V which in turn will adjust the
  -- delivery W/V, if the container is in a delivery.
  IF (l_del_id_for_detail.delivery_id is not null) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id => p_detail_id,
            p_diff_gross_wt      => -1 * l_del_id_for_detail.gross_weight,
            p_diff_net_wt        => -1 * l_del_id_for_detail.net_weight,
            p_diff_volume        => -1 * l_del_id_for_detail.volume,
            p_diff_fill_volume   => -1 * l_del_id_for_detail.volume,
            x_return_status      => l_return_status);

          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               --
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               WSH_UTIL_CORE.Add_Message(x_return_status);
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                   WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               return;
          END IF;

  END IF;

  /* container is already assigned to a delivery */

  /* bug 2691385 and 2655474: avoid unnecessary update if line is already in delivery. */
  /****
          !!!!! We should NOT assume that the delivery grouping attributes of the delivery match
          !!!!! with that of the delivery details.
          !!!!! Bugs 2794866, 2397552.
  ****/


  IF (l_del_id_for_container.delivery_id IS not null) and (l_del_id_for_detail.delivery_id is null) THEN


    -- OTM R12 : assign delivery detail, this is the case where detail is assigned to the delivery

    IF (l_gc3_is_installed = 'Y' AND
        nvl(l_del_id_for_container.ignore_for_planning, 'N') = 'N') THEN

      Pre_Otm_Assign_Del_Detail
              (p_delivery_id        => NULL,
               p_detail_id          => p_detail_id,
               p_container1_id      => p_parent_detail_id,
               p_container2_id      => NULL,
               p_assignment_type    => 'DD2C',
               x_delivery_was_empty => l_delivery_was_empty,
               x_assign_update      => l_assign_update,
               x_gross_weight1      => l_gross_weight1,
               x_gross_weight2      => l_gross_weight2,
               x_return_status      => l_return_status);

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error from Pre_Otm_Assign_Del_Detail');
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- End of OTM R12 : assign delivery detail


               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.CHECK_ASSIGN_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               l_attr_tab(1).entity_id := l_del_id_for_container.delivery_id;
               l_attr_tab(1).entity_type := 'DELIVERY';
               l_attr_tab(2).entity_id := p_detail_id;
               l_attr_tab(2).entity_type := 'DELIVERY_DETAIL';

               l_action_rec.action := 'MATCH_GROUPS';
               l_action_rec.check_single_grp := 'Y';

               WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab => l_group_tab,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => x_return_status);

               IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                     --
                     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     WSH_UTIL_CORE.Add_Message(x_return_status);
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                         WSH_DEBUG_SV.pop(l_module_name);
                     END IF;
                     return;
               END IF;



               IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                     --
                     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     WSH_UTIL_CORE.Add_Message(x_return_status);
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                         WSH_DEBUG_SV.pop(l_module_name);
                     END IF;
                     return;
               END IF;

    -- Update the delivery with the line's line direction

    -- Lock the delivery before update.

    BEGIN

       wsh_new_deliveries_pvt.lock_dlvy_no_compare(p_delivery_id => l_del_id_for_container.delivery_id);

    EXCEPTION

       WHEN OTHERS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
          WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.G_RET_STS_ERROR);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Could not lock delivery: ',l_del_id_for_container.delivery_id);
             WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
    END;

    l_group_index := l_group_tab.FIRST;

    -- OTM R12 : update delivery
    l_tms_update := 'N';
    l_new_interface_flag_tab(1) := NULL;

    IF (l_gc3_is_installed = 'Y' AND
        nvl(l_del_id_for_container.ignore_for_planning, 'N') = 'N') THEN
      l_trip_not_found := 'N';

      --get trip information for delivery, no update when trip not OPEN
      WSH_DELIVERY_VALIDATIONS.get_trip_information
                   (p_delivery_id     => l_del_id_for_container.delivery_id,
                    x_trip_info_rec   => l_trip_info_rec,
                    x_return_status   => l_return_status);

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_trip_information');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      IF (l_trip_info_rec.trip_id IS NULL) THEN
        l_trip_not_found := 'Y';
      END IF;

      -- only do changes when there's no trip or trip status is OPEN
      IF (l_trip_info_rec.status_code = 'OP' OR
          l_trip_not_found = 'Y') THEN

        WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                              p_delivery_id   => l_del_id_for_container.delivery_id,
                              x_delivery_rec  => l_delivery_info,
                              x_return_status => l_return_status);

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          x_return_status := l_return_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_delivery_information');
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

        -- if service level, mode of transport, or carrier id is changed
        -- with the nvl updates, then update is needed

        IF (nvl(l_delivery_info.service_level,
                nvl(l_group_tab(l_group_index).service_level, '@@')) <>
            nvl(l_delivery_info.service_level, '@@') OR
            nvl(l_delivery_info.mode_of_transport,
                nvl(l_group_tab(l_group_index).mode_of_transport, '@@')) <>
            nvl(l_delivery_info.mode_of_transport, '@@') OR
            nvl(l_delivery_info.carrier_id,
                nvl(l_group_tab(l_group_index).carrier_id, -1)) <>
            nvl(l_delivery_info.carrier_id, -1)) THEN

          IF (l_delivery_info.tms_interface_flag NOT IN
              (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
               WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
               WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
               WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
               WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED)) THEN
            l_tms_update := 'Y';
            l_delivery_info_tab(1) := l_delivery_info;
            l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
            l_tms_version_number := nvl(l_delivery_info.tms_version_number, 1) + 1;
          END IF;
        END IF; -- checking the value differences
      END IF; -- IF ((l_trip_not_found = 'N' AND
    END IF; -- IF (l_gc3_is_installed = 'Y'

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_gc3_is_installed', l_gc3_is_installed);
      WSH_DEBUG_SV.log(l_module_name, 'l_tms_update', l_tms_update);
      IF (l_tms_update = 'Y') THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_new_interface_flag_tab', l_new_interface_flag_tab(1));
        WSH_DEBUG_SV.log(l_module_name, 'l_tms_version_number', l_tms_version_number);
      END IF;
    END IF;

    -- End of OTM R12 : update delivery

    UPDATE wsh_new_deliveries
    SET shipment_direction = l_del_id_for_detail.line_direction,
        service_level = NVL(service_level,l_group_tab(l_group_index).service_level),
        mode_of_transport = NVL(mode_of_transport, l_group_tab(l_group_index).mode_of_transport),
        carrier_id = NVL(carrier_id, l_group_tab(l_group_index).carrier_id),
        -- OTM R12
        TMS_INTERFACE_FLAG = decode(l_tms_update, 'Y', l_new_interface_flag_tab(1), nvl(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
        TMS_VERSION_NUMBER = decode(l_tms_update, 'Y', l_tms_version_number, nvl(tms_version_number, 1)),
        -- End of OTM R12
        last_update_date = SYSDATE,
        last_updated_by =  FND_GLOBAL.USER_ID,
        last_update_login =  FND_GLOBAL.LOGIN_ID
    where delivery_id = l_del_id_for_container.delivery_id;

    -- OTM R12 : update delivery
    IF (l_gc3_is_installed = 'Y' AND l_tms_update = 'Y') THEN
      WSH_XC_UTIL.LOG_OTM_EXCEPTION(
                          p_delivery_info_tab      => l_delivery_info_tab,
                          p_new_interface_flag_tab => l_new_interface_flag_tab,
                          x_return_status          => l_return_status);

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_XC_UTIL.log_otm_exception');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;
    END IF;
    -- End of OTM R12 : update delivery

    -- K LPN CONV. rv
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    AND nvl(l_del_id_FOR_container.line_direction,'O') IN ('O', 'IO')
    AND
    (
      ((WSH_WMS_LPN_GRP.GK_WMS_PACK or WSH_WMS_LPN_GRP.GK_WMS_ASSIGN_DLVY) and l_wms_org = 'Y')
      OR
      ((WSH_WMS_LPN_GRP.GK_INV_PACK or WSH_WMS_LPN_GRP.GK_INV_ASSIGN_DLVY) and l_wms_org = 'N')
    )
    THEN
    --{
        l_sync_tmp_rec.delivery_detail_id := p_detail_id;
        l_sync_tmp_rec.parent_delivery_detail_id := l_del_id_for_detail.parent_delivery_detail_id;
        l_sync_tmp_rec.delivery_id := l_del_id_for_detail.delivery_id;
        l_sync_tmp_rec.operation_type := 'PRIOR';
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_WMS_SYNC_TMP_PKG.MERGE
        (
          p_sync_tmp_rec      => l_sync_tmp_rec,
          x_return_status     => l_return_status
        );
        --
        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        --
          x_return_status := l_return_status;
        --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
        --
          return;
        --
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        --
          l_num_warnings := l_num_warnings + 1;
        --
        END IF;
        --
    --}
    END IF;
    -- K LPN CONV. rv
    --

    UPDATE wsh_delivery_assignments_v
    SET parent_delivery_detail_id = p_parent_detail_id,
       delivery_id = l_del_id_for_container.delivery_id,
         last_update_date = SYSDATE,
         last_updated_by =  FND_GLOBAL.USER_ID,
         last_update_login =  FND_GLOBAL.LOGIN_ID
    WHERE delivery_detail_id = p_detail_id;

    -- OTM R12 : assign delivery detail
    IF (l_assign_update AND
        l_gc3_is_installed = 'Y' AND
        nvl(l_del_id_for_container.ignore_for_planning, 'N') = 'N') THEN

      IF (l_tms_update = 'Y') THEN
        l_tms_interface_flag := l_new_interface_flag_tab(1);
      ELSIF (l_trip_info_rec.status_code = 'OP' OR
             l_trip_not_found = 'Y') THEN
        l_tms_interface_flag := nvl(l_delivery_info.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT);
      ELSE
        l_tms_interface_flag := NULL;
      END IF;

      Post_Otm_Assign_Del_Detail
              (p_delivery_id         => l_del_id_for_container.delivery_id,
               p_delivery_was_empty  => l_delivery_was_empty,
               p_tms_interface_flag  => l_tms_interface_flag,
               p_gross_weight        => l_gross_weight1,  --using the gross weight of the detail
               x_return_status       => l_return_status);

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error from Post_Otm_Assign_Del_Detail');
        END IF;
        raise FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;
    END IF;
    -- End of OTM R12 : assign delivery detail

    -- K: MDC delete consolidation record of it exists
    l_mdc_detail_tab(1) := p_detail_id;
    WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                       p_detail_id_tab   => l_mdc_detail_tab,
                       x_return_status   => x_return_status);

    IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;


    /* H integration: Pricing integration csun , marking the delivery */
    m := m + 1;
    l_del_tab(m) := l_del_id_for_detail.delivery_id;
  ELSIF (l_del_id_for_container.delivery_id is null)
          OR   (l_del_id_for_container.delivery_id =  l_del_id_for_detail.delivery_id )THEN
    --
    -- K LPN CONV. rv
    -- Only packing.
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    AND nvl(l_del_id_FOR_container.line_direction,'O') IN ('O', 'IO')
    AND
    (
      (WSH_WMS_LPN_GRP.GK_WMS_PACK and l_wms_org = 'Y')
      OR
      (WSH_WMS_LPN_GRP.GK_INV_PACK and l_wms_org = 'N')
    )
    THEN
    --{
        --
        l_sync_tmp_rec.delivery_detail_id := p_detail_id;
        l_sync_tmp_rec.parent_delivery_detail_id := l_del_id_for_detail.parent_delivery_detail_id;
        l_sync_tmp_rec.delivery_id := l_del_id_for_detail.delivery_id;
        l_sync_tmp_rec.operation_type := 'PRIOR';
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_WMS_SYNC_TMP_PKG.MERGE
        (
          p_sync_tmp_rec      => l_sync_tmp_rec,
          x_return_status     => l_return_status
        );
        --
        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        --
          x_return_status := l_return_status;
        --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
        --
          return;
        --
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        --
          l_num_warnings := l_num_warnings + 1;
        --
        END IF;
        --
    --}
    END IF;
    -- K LPN CONV. rv
    --

    UPDATE wsh_delivery_assignments_v
    SET parent_delivery_detail_id = p_parent_detail_id,
    last_update_date = SYSDATE,
    last_updated_by =  FND_GLOBAL.USER_ID,
    last_update_login =  FND_GLOBAL.LOGIN_ID
    WHERE delivery_detail_id = p_detail_id;

    l_mdc_detail_tab(1) := p_detail_id;
    WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                       p_detail_id_tab   => l_mdc_detail_tab,
                       x_return_status   => x_return_status);

    IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;
  END IF;

  /* detail is already assigned to a delivery */
  /* updating delivery_id for all containers and details inside
     of the container AND updating delivery_id FOR all containers outside of the
     container */
  /* Bug 1571143 */
  /* bug 2677298 frontport from bug 2655474: update container only if it is not in delivery */
  IF (    (l_del_id_for_detail.delivery_id is not null)
            AND (l_del_id_for_container.delivery_id is null)  ) THEN

    -- K LPN CONV. rv
    -- Based on assumption that we are using wsh_delivery_assignments_v,
    -- delivery and its contents will belong to same organization.
    -- Similarly, container and its contents will belong to same organization.
    -- Hence, we are checking for WMS org or non-WMS org. at the
    -- parent level (i.e. delivery/container)
    -- rather than at line-level for performance reasons.

    -- If this assumptions were to be violated in anyway
    --    i.e Query was changed to refer to base table wsh_delivery_assignments instead of
    --     wsh_delivery_assignments_v
    -- or
    -- if existing query were to somehow return/fetch records where
    --    delivery and its contents may belong to diff. org.
    --    container and its contents may belong to diff. org.
    --    then
    --       Calls to check_wms_org needs to be re-adjusted at
    --       appropriate level (line/delivery/container).
    -- K LPN CONV. rv

    -- Bug 4452930
    OPEN c_topmost_container(p_parent_detail_id);
    FETCH c_topmost_container INTO l_topmost_cont;
    CLOSE c_topmost_container;

    IF   l_topmost_cont IS NULL THEN
      l_topmost_cont := p_parent_detail_id;
    END IF;


    -- OTM R12 : assign delivery detail,
    -- this is the case where container is assigned to delivery, had to get topmost container

    IF (l_gc3_is_installed = 'Y' AND
        nvl(l_del_id_for_container.ignore_for_planning, 'N') = 'N') THEN

      Pre_Otm_Assign_Del_Detail
              (p_delivery_id        => NULL,
               p_detail_id          => p_detail_id,
               p_container1_id      => l_topmost_cont,
               p_container2_id      => NULL,
               p_assignment_type    => 'DD2C',
               x_delivery_was_empty => l_delivery_was_empty,
               x_assign_update      => l_assign_update,
               x_gross_weight1      => l_gross_weight1,
               x_gross_weight2      => l_gross_weight2,
               x_return_status      => l_return_status);

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error from Pre_Otm_Assign_Del_Detail');
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- End of OTM R12 : assign delivery detail


    OPEN c_inside_outside_of_container(l_topmost_cont);
    -- Bug 4452930
    FETCH c_inside_outside_of_container bulk collect into
          l_sync_tmp_recTbl.delivery_detail_id_tbl,
          l_sync_tmp_recTbl.parent_detail_id_tbl,
          l_sync_tmp_recTbl.delivery_id_tbl;

    CLOSE c_inside_outside_of_container;
    IF (l_sync_tmp_recTbl.delivery_detail_id_tbl.count > 0 ) THEN
    --{

        --
        l_sync_tmp_recTbl.operation_type_tbl(1) := 'PRIOR';
        l_operation_type := 'PRIOR';
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        AND nvl(l_del_id_for_detail.line_direction,'O') IN ('O', 'IO')
        AND
        (
          (WSH_WMS_LPN_GRP.GK_WMS_ASSIGN_DLVY and l_wms_org = 'Y')
          OR
          (WSH_WMS_LPN_GRP.GK_INV_ASSIGN_DLVY and l_wms_org = 'N')
        )
        THEN
        --{
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
            (
              p_sync_tmp_recTbl   => l_sync_tmp_recTbl,
              x_return_status     => l_return_status,
              p_operation_type    => l_operation_type
            );
            --
            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            --
              x_return_status := l_return_status;
            --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
            --
              return;
            --
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            --
              l_num_warnings := l_num_warnings + 1;
            --
            END IF;
            --

        --}
        END IF;
        --

        FORALL i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last
        UPDATE wsh_delivery_assignments_v
        SET delivery_id = l_del_id_FOR_detail.delivery_id,
            last_update_date = SYSDATE,
            last_updated_by =  FND_GLOBAL.USER_ID,
            last_update_login =  FND_GLOBAL.LOGIN_ID
        WHERE delivery_detail_id = l_sync_tmp_recTbl.delivery_detail_id_tbl(i);

        -- OTM R12 : assign delivery detail
        -- executed only once since it's for the same delivery
        IF (l_assign_update AND
            l_gc3_is_installed = 'Y' AND
            nvl(l_del_id_for_detail.ignore_for_planning, 'N') = 'N') THEN

          -- when it comes here, OTM R12 update delivery is not called before
          -- inside the same procedure, so can't use those variables

          l_tms_interface_flag := NULL;

          Post_Otm_Assign_Del_Detail
            (p_delivery_id         => l_del_id_for_detail.delivery_id,
             p_delivery_was_empty  => l_delivery_was_empty,
             p_tms_interface_flag  => l_tms_interface_flag,
             p_gross_weight        => l_gross_weight2, --using the container gross weight
             x_return_status       => l_return_status);

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'error from Post_Otm_Assign_Del_Detail');
            END IF;
            raise FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warnings := l_num_warnings + 1;
          END IF;
        END IF;
        -- End of OTM R12 : assign delivery detail

        FOR i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last LOOP
            l_mdc_detail_tab(i) := l_sync_tmp_recTbl.delivery_detail_id_tbl(i);
        END LOOP;
        WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                       p_detail_id_tab => l_mdc_detail_tab,
                       x_return_status => x_return_status);

        IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        l_mdc_detail_tab.delete;
        l_sync_tmp_recTbl.delivery_detail_id_tbl.delete;
        l_sync_tmp_recTbl.parent_detail_id_tbl.delete;
        l_sync_tmp_recTbl.delivery_id_tbl.delete;
        l_sync_tmp_recTbl.operation_type_tbl.delete;

    --}
    END IF;
    -- K LPN CONV. rv

               -- J: W/V Changes
               -- Container is being assigned to delivery. Call DD_WV_Post_Process to adjust the W/V of the parent
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Assigning Container to Delivery');
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               WSH_WV_UTILS.DD_WV_Post_Process(
                 p_delivery_detail_id => p_parent_detail_id,
                 p_diff_gross_wt      => l_del_id_for_container.gross_weight,
                 p_diff_net_wt        => l_del_id_for_container.net_weight,
                 p_diff_volume        => l_del_id_for_container.volume,
                 p_diff_fill_volume   => l_del_id_for_container.volume,
                 x_return_status      => l_return_status);

               IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                    --
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    WSH_UTIL_CORE.Add_Message(x_return_status);
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                        WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    return;
               END IF;


    /* H integration: Pricing integration csun , marking the delivery */
    m := m + 1;
    l_del_tab(m) := l_del_id_for_detail.delivery_id;

   END IF;


         -- K LPN CONV. rv
         IF NOT( l_wms_org = 'Y' AND nvl(wsh_wms_lpn_grp.g_caller,'WSH') like 'WMS%')
         THEN
         --{
    -- J: W/V Changes
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_WV_UTILS.DD_WV_Post_Process(
               p_delivery_detail_id => p_detail_id,
               p_diff_gross_wt      => l_del_id_for_detail.gross_weight,
               p_diff_net_wt        => l_del_id_for_detail.net_weight,
               p_diff_volume        => l_del_id_for_detail.volume,
               p_diff_fill_volume   => l_del_id_for_detail.volume,
               x_return_status      => l_return_status);

             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   l_num_warnings := l_num_warnings + 1;
                ELSE
                  --
                  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  WSH_UTIL_CORE.Add_Message(x_return_status);
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                      WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  return;
                END IF;
             END IF;
         --}
         END IF;
         -- K LPN CONV. rv

   /*  H integration: Pricing integration csun   */
    IF l_del_tab.count > 0 THEN
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
    END IF;
    END IF;

  IF l_num_warnings > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  exception

  -- OTM R12 : assign delivery detail
  WHEN FND_API.G_EXC_ERROR then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  -- End of OTM R12 : assign delivery detail

  WHEN mark_reprice_error then
    FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    x_return_status := l_return_status;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
    END IF;
    --
  WHEN invalid_detail then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.SET_name('WSH', 'WSH_DET_CONFIRMED_DETAIL');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DETAIL');
    END IF;
    --
    RETURN;
  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_CONT',l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Assign_Detail_To_Cont;
-- -------------------------------------------------------------------------------
--Procedure:  Unssign_Detail_from_Cont
--Parameters: p_detail_id,
--    p_parent_detail_id,
--    x_return_status
--Description:  if detail is already assigned to a delivery which means
--    the container must be assigned to the same delivery too,
--    in this case even though the detail is getting removed
--    from the container, it will still stay assigned to the
--    delivery
--    if the container is already assigned to a delivery,
--    the detail must also be assigned to the same delivery


PROCEDURE Unassign_Detail_from_Cont(
  p_detail_id   IN NUMBER,
  x_return_status   OUT NOCOPY  VARCHAR2,
  p_validate_flag   IN VARCHAR2)
IS

invalid_detail exception;
-- J: W/V Changes
e_abort        exception;
l_param_info   WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_cont_fill_pc NUMBER;

/* H projects: pricing integration csun */
l_del_tab   WSH_UTIL_CORE.Id_Tab_Type;
l_return_status         VARCHAR2(1);
l_del_rec  C_DEL_ID_FOR_CONT_OR_DETAIL%ROWTYPE;
mark_reprice_error  EXCEPTION;

l_num_warnings          number := 0;
-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_mdc_detail_tab wsh_util_core.id_tab_type;

cursor l_parent_cnt_csr (p_cnt_inst_id IN NUMBER) is
select organization_id,
       nvl(line_direction,'O')
from wsh_delivery_details
where delivery_detail_id = p_cnt_inst_id
and container_flag = 'Y'
and source_code = 'WSH';

l_parent_cnt_orgn_id NUMBER;
l_parent_cnt_line_dir VARCHAR2(10);
-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_DETAIL_FROM_CONT';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        -- J: W/V Changes
  OPEN C_DEL_ID_FOR_CONT_OR_DETAIL(p_detail_id);
  FETCH C_DEL_ID_FOR_CONT_OR_DETAIL INTO l_del_rec;
  CLOSE C_DEL_ID_FOR_CONT_OR_DETAIL;


        IF l_del_rec.parent_delivery_detail_id is NULL THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DD '||p_detail_id||' is already unassigned. Returning');
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;

        -- LPN CONV. rv
        ELSE
          --
          open l_parent_cnt_csr(l_del_rec.parent_delivery_detail_id);
          fetch l_parent_cnt_csr into l_parent_cnt_orgn_id, l_parent_cnt_line_dir;
          close l_parent_cnt_csr;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,' parent cnt orgn id is', l_parent_cnt_orgn_id);
            WSH_DEBUG_SV.log(l_module_name,' parent cnt line dir is', l_parent_cnt_line_dir);
          END IF;
          --
          l_wms_org := wsh_util_validate.check_wms_org(l_parent_cnt_orgn_id);
          --
        -- LPN CONV. rv
          --
        END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_del_rec.released_status',l_del_rec.released_status);
  END IF;
  --

  IF l_del_rec.released_status = 'C' THEN
    Raise invalid_detail;
  END IF;

  -- K LPN CONV. rv

        IF NOT( l_wms_org = 'Y' AND nvl(wsh_wms_lpn_grp.g_caller,'WSH') like 'WMS%')
        THEN
        --{

            -- J: W/V Changes
            -- Decrement the DD W/V from container
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_WV_UTILS.DD_WV_Post_Process(
              p_delivery_detail_id => p_detail_id,
              p_diff_gross_wt      => -1 * l_del_rec.gross_weight,
              p_diff_net_wt        => -1 * l_del_rec.net_weight,
              p_diff_volume        => -1 * l_del_rec.volume,
              p_diff_fill_volume   => -1 * l_del_rec.volume,
              p_check_for_empty    => 'Y',
              x_return_status      => l_return_status);

            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   l_num_warnings := l_num_warnings + 1;
                ELSE
                 --
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status);
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                     WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 return;
               END IF;
            END IF;
        --}
        END IF;

  -- K LPN CONV. rv
  --
  -- K LPN CONV. rv
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  AND nvl(l_parent_cnt_line_dir,'O') IN ('O', 'IO')
  AND
  (
    (WSH_WMS_LPN_GRP.GK_WMS_UNPACK and l_wms_org = 'Y')
    OR
    (WSH_WMS_LPN_GRP.GK_INV_UNPACK and l_wms_org = 'N')
  )
  THEN
  --{
      l_sync_tmp_rec.delivery_detail_id := p_detail_id;
      l_sync_tmp_rec.parent_delivery_detail_id := l_del_rec.parent_delivery_detail_id;
      l_sync_tmp_rec.delivery_id := l_del_rec.delivery_id;
      l_sync_tmp_rec.operation_type := 'PRIOR';
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WMS_SYNC_TMP_PKG.MERGE
      (
        p_sync_tmp_rec      => l_sync_tmp_rec,
        x_return_status     => l_return_status
      );

      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
      THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_WMS_SYNC_TMP_PKG.MERGE returned ',l_return_status);
        END IF;
        RAISE e_abort;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;
  --}
  END IF;
  -- K LPN CONV. rv
  --
  UPDATE wsh_delivery_assignments_v
  SET parent_delivery_detail_id = NULL,
    last_update_date = SYSDATE,
    last_updated_by =  FND_GLOBAL.USER_ID,
    last_update_login =  FND_GLOBAL.LOGIN_ID
  WHERE delivery_detail_id = p_detail_id;
  l_mdc_detail_tab(1) := p_detail_id;
  WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                       p_detail_id_tab   => l_mdc_detail_tab,
                       x_return_status => x_return_status);

  IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;
  -- J: W/V Changes
  -- Need to recalculate the fill% if 'Percent Fill Basis' is Quantity
  -- Reason: DD_WV_Post_Process would have calculated the fill% but the delivery detail is not unassigned at
  --         that point of time. So the fill% will be wrong if 'Percent Fill Basis' is Quantity since the fill%
  --         calculation considers the delivery detail which is not yet unassigned
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  WSH_SHIPPING_PARAMS_PVT.Get(
    p_organization_id => l_del_rec.organization_id,
    x_param_info      => l_param_info,
    x_return_status   => l_return_status);

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||l_return_status);
    END IF;
    raise e_abort;
  END IF;

  IF (l_param_info.percent_fill_basis_flag = 'Q') THEN

    -- K LPN CONV. rv
    IF NOT( l_wms_org = 'Y' AND nvl(wsh_wms_lpn_grp.g_caller,'WSH') like 'WMS%')
    THEN
    --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Need to recalculate the fill% for container');
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CALC_CONT_FILL_PC',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

             WSH_WV_UTILS.ADJUST_PARENT_WV(
              p_entity_type   => 'CONTAINER',
              p_entity_id     => l_del_rec.parent_delivery_detail_id,
              p_gross_weight  => 0,
              p_net_weight    => 0,
              p_volume        => 0,
              p_filled_volume => 0,
              p_wt_uom_code   => l_del_rec.weight_uom_code,
              p_vol_uom_code  => l_del_rec.volume_uom_code,
              p_inv_item_id   => l_del_rec.inventory_item_id,
              x_return_status => l_return_status);

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
 	       THEN
               IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WV_UTILS.ADJUST_PARENT_WV returned '||l_return_status);
               END IF;
               RAISE e_abort;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               l_num_warnings := l_num_warnings + 1;
            END IF;

    --}
    END IF;
    -- K LPN CONV. rv
  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Delivery Id for l_del_rec',l_del_rec.delivery_id);
  END IF;
  --

        -- J: W/V Changes
        -- Assign the DD W/V back to delivery
        IF l_del_rec.delivery_id IS NOT NULL THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id => p_detail_id,
            p_diff_gross_wt      => l_del_rec.gross_weight,
            p_diff_net_wt        => l_del_rec.net_weight,
            p_diff_volume        => l_del_rec.volume,
            p_diff_fill_volume   => l_del_rec.volume,
            x_return_status      => l_return_status);
          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               l_num_warnings := l_num_warnings + 1;
            ELSE
               --
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               WSH_UTIL_CORE.Add_Message(x_return_status);
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                   WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               return;
            END IF;
          END IF;

        END IF;

  /*  H integration: Pricing integration csun */
  IF l_del_rec.delivery_id IS not NULL THEN
     l_del_tab.delete;
     l_del_tab(1) := l_del_rec.delivery_id;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
    END IF;
  END IF;

  IF l_num_warnings > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
exception
  -- J: W/V Changes
  WHEN e_abort THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN mark_reprice_error THEN
    FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    x_return_status := l_return_status;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
END IF;
--
  WHEN invalid_detail then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.SET_name('WSH', 'WSH_DET_CONFIRMED_DETAIL');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  WHEN others THEN
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_CONT',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unassign_Detail_FROM_Cont;


-- THIS PROCEDURE IS OBSOLETE
--
--Procedure:       Assign_Cont_To_Delivery
--Parameters:      p_detail_id,
--         p_delivery_id,
--         x_return_status
--Description:     This procedure is called when assigning a container to
--              a delivery.
--              It assigns all delivery lines and child containers to
--              the delivery as well.
--changing to just call assign_detail_to_delivery

PROCEDURE Assign_Cont_To_Delivery(
  P_DETAIL_ID IN NUMBER,
  P_DELIVERY_ID  IN NUMBER,
  X_RETURN_STATUS OUT NOCOPY  VARCHAR2) IS
assign_cont_del exception;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_CONT_TO_DELIVERY';
--
BEGIN
  --
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  --
  --
END Assign_Cont_To_Delivery;


-------------------------------------------------------------------
--Assign_Top_Detail_To_Delivery should only be called for the topmost
--container in a hierarchy/detail (if it is a loose detail) assigns
--all the details below (including containers) to delivery
-- x_dlvy_has_lines : 'Y' :delivery has non-container lines.
--                    'N' : delivery does not have non-container lines
-- x_dlvy_freight_Terms_code : Delivery's freight term code
-------------------------------------------------------------------


PROCEDURE Assign_Top_Detail_To_Delivery(
  P_DETAIL_ID     IN NUMBER,
  P_DELIVERY_ID   IN NUMBER,
  X_RETURN_STATUS OUT NOCOPY  VARCHAR2,
    x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    --
    x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
    p_caller        IN VARCHAR2 --bug 5100229
    ) IS

TYPE del_det_id_tab_type IS TABLE OF wsh_delivery_details.delivery_detail_id%TYPE INDEX BY BINARY_INTEGER;

l_rowid varchar2(150);
l_delivery_assignment_id NUMBER;
--  cont_id NUMBER;
del_id NUMBER;
l_summary varchar2(3000);
l_details varchar2(3000);
l_get_msg_count number;

l_cr_assn_status varchar2(30);
l_group_status varchar2(30);
l_arrival_status varchar2(30);
l_ship_method_match BOOLEAN;

l_attr_flag VARCHAR2(1) := 'N';
l_cont_name VARCHAR2(30);

invalid_del exception;
invalid_detail exception;
del_not_updatable exception;
grouping_attributes_not_match exception;
arrival_SET_failed exception;
ship_method_not_match exception;
l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
l_mdc_detail_tab wsh_util_core.id_tab_type;
DETAIL_DEL_FROM_to_not_SAME exception;
det_confirmed exception;
update_mol_carton_group_error exception;


CURSOR c_delivery IS
SELECT status_code,planned_flag, initial_pickup_location_id,ultimate_dropoff_location_id,
customer_id, intmed_ship_to_location_id, fob_code, freight_terms_code, ship_method_code,
carrier_id, mode_of_transport, service_level,
-- deliveryMerge
batch_id,
        NVL(shipment_direction,'O') shipment_direction,   -- J-IB-NPARIKH
        shipping_control,   -- J-IB-NPARIKH
        vendor_id,   -- J-IB-NPARIKH
        party_id,   -- J-IB-NPARIKH
        NVL(ignore_for_planning,'N') ignore_for_planning, --J TP Release ttrichy
        organization_id,    -- K LPN CONV. rv
        client_id  -- LSP PROJECT
FROM wsh_new_deliveries
WHERE delivery_id = p_delivery_id;
l_del c_delivery%ROWTYPE;

CURSOR c_detail(c_detail_id NUMBER) IS
SELECT wdd.delivery_detail_id, wdd.released_status, wdd.container_flag, wdd.ship_from_location_id, wdd.ship_to_location_id, wda.delivery_id, wdd.move_order_line_id, wdd.organization_id,
       wdd.freight_terms_code,   -- J-IB-NPARIKH
       NVL(line_direction,'O') line_direction,   -- J-IB-NPARIKH
       shipping_control,   -- J-IB-NPARIKH
       vendor_id,   -- J-IB-NPARIKH
       party_id,   -- J-IB-NPARIKH
       NVL(ignore_for_planning,'N') ignore_for_planning,--J TP Release ttrichy
       mode_of_transport, carrier_id, service_level,
       wda.parent_delivery_detail_id, -- K LPN CONV. rv
       wdd.gross_weight,               -- OTM R12 : assign delivery detail
       wdd.client_id -- LSP PROJECT
FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda
WHERE wdd.delivery_detail_id = wda.delivery_detail_id and wdd.delivery_detail_id = c_detail_id;


l_detail c_detail%ROWTYPE;

l_del_assign NUMBER;

CURSOR c_all_details_below IS
SELECT  delivery_detail_id
FROM  wsh_delivery_assignments_v
START WITH  delivery_detail_id = p_detail_id
CONNECT BY  prior delivery_detail_id = parent_delivery_detail_id;

CURSOR c_getdet_ignore IS
select NVL(ignore_for_planning, 'N') ignore_for_planning
from wsh_delivery_details
where delivery_detail_id=p_detail_id;

-- J: W/V Changes
l_detail_status         VARCHAR2(1);
l_gross_wt              NUMBER;
l_net_wt                NUMBER;
l_vol                   NUMBER;
l_container_flag        VARCHAR2(1);
l_delivery_id           NUMBER;

l_service_level         VARCHAR2(30);
l_mode_of_transport     VARCHAR2(30);
l_ship_method     VARCHAR2(30);
l_carrier_id            NUMBER;

l_dd_id      del_det_id_tab_type;
i        BINARY_INTEGER := 0;
j        BINARY_INTEGER :=0;

l_dummy_del_det_id NUMBER;

/* H projects: pricing integration csun */
l_scc_unassign_from_del  NUMBER := 0;
l_del_tab   WSH_UTIL_CORE.Id_Tab_Type;
l_status                WSH_LOOKUPS.meaning%TYPE;
l_return_status         VARCHAR2(1);

CURSOR get_lookup (l_code VARCHAR2) IS
  SELECT meaning
  FROM wsh_lookups
  WHERE lookup_type = 'DELIVERY_STATUS'
  AND lookup_code = l_code;

mark_reprice_error  EXCEPTION;
l_dlvy_freight_terms_code VARCHAR2(30);
l_update_dlvy             BOOLEAN;


l_msg_count      NUMBER;
l_msg_data       VARCHAR2(4000);

-- bug 2691385
l_detail_is_empty_cont VARCHAR2(1) := 'N';

l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_action_rec wsh_delivery_autocreate.action_rec_type;
l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
l_matched_entities wsh_util_core.id_tab_type;
l_out_rec wsh_delivery_autocreate.out_rec_type;

-- K LPN CONV. rv
l_detail_wms_org    VARCHAR2(10) := 'N';
l_line_dir          VARCHAR2(10);
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_num_warnings NUMBER := 0;
-- K LPN CONV. rv

-- OTM R12 : update delivery
l_delivery_info_tab       WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_delivery_info           WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
l_new_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_tms_update              VARCHAR2(1);
l_trip_not_found          VARCHAR2(1);
l_trip_info_rec           WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
l_tms_version_number      WSH_NEW_DELIVERIES.TMS_VERSION_NUMBER%TYPE;
l_gc3_is_installed        VARCHAR2(1);

-- End of OTM R12 : update delivery

-- OTM R12 : assign delivery detail
l_delivery_was_empty      BOOLEAN;
l_tms_interface_flag      WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
l_gross_weight1           WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE;
l_gross_weight2           WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE;
l_delivery_detail_ids     WSH_GLBL_VAR_STRCT_GRP.NUM_TBL_TYPE;
l_assign_update           BOOLEAN;
-- End of OTM R12 : assign delivery detail
--
l_client_id               NUMBER; -- LSP PROJECT
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_TOP_DETAIL_TO_DELIVERY';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
            WSH_DEBUG_SV.log(l_module_name,'x_dlvy_has_lines',x_dlvy_has_lines);
      WSH_DEBUG_SV.log(l_module_name,'P_CALLER',P_CALLER);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  l_assign_update := FALSE; --default assignment tms update to false
  -- End of OTM R12

        -- J: W/V Changes
        open g_get_detail_info(p_detail_id);
        fetch g_get_detail_info
        into l_detail_status,l_gross_wt, l_net_wt, l_vol, l_container_flag, l_delivery_id;
        close  g_get_detail_info;

        IF l_delivery_id is NOT NULL THEN
          IF l_delivery_id <> p_delivery_id THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_DET_ASSIGNED_DEL');
            FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
            FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_id);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status,l_module_name);
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
          ELSE
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'DD '||p_detail_id||' is already assigned to '||l_delivery_id||'. Returning');
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            return;
          END IF;
        END IF;


    --
    -- J-IB-NPARIKH-{
    IF x_dlvy_has_lines IS NULL
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'x_dlvy_has_lines');
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    -- J-IB-NPARIKH-}
    --
    --
  OPEN c_delivery;
  FETCH c_delivery into l_del;
  IF (c_delivery%NOTFOUND) THEN
    CLOSE c_delivery;
    RAISE INVALID_DEL;
  END IF;

  CLOSE c_delivery;

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'status_code',l_del.status_code);
   WSH_DEBUG_SV.log(l_module_name,'Delivery Freight Terms',l_del.freight_Terms_code);
  END IF;
  --
  /* security rule, delivery status should be open or packed and not planned  */
  /* the value for the flag can be Y or N updated with Bug 1559785*/
  IF ((l_del.status_code = 'CO') OR
      (l_del.status_code = 'IT') OR
      (l_del.status_code = 'CL') OR
      (l_del.status_code = 'SR') OR -- sperera 940/945
      (l_del.status_code = 'SC') OR
      (l_del.planned_flag IN ('Y','F')))
     AND l_del.shipment_direction IN ('O','IO')   -- J-IB-NPARIKH
  THEN
     IF l_del.planned_flag IN ('Y','F') THEN
        fnd_message.SET_name('WSH', 'WSH_PLAN_DEL_NOT_UPDATABLE');
     ELSE
        OPEN get_lookup(l_del.status_code);
        FETCH get_lookup INTO l_status;
        CLOSE get_lookup;
        fnd_message.SET_name('WSH', 'WSH_DET_DEL_NOT_UPDATABLE');
        FND_MESSAGE.SET_TOKEN('STATUS',l_status);
     END IF;
     RAISE DEL_NOT_UPDATABLE;
  END IF;


  -- OTM R12 : assign delivery detail
  IF (l_gc3_is_installed = 'Y' AND
      nvl(l_del.ignore_for_planning, 'N') = 'N') THEN

    Pre_Otm_Assign_Del_Detail
              (p_delivery_id        => p_delivery_id,
               p_detail_id          => p_detail_id,
               p_container1_id      => NULL,
               p_container2_id      => NULL,
               p_assignment_type    => 'DD2D',
               x_delivery_was_empty => l_delivery_was_empty,
               x_assign_update      => l_assign_update,
               x_gross_weight1      => l_gross_weight1,
               x_gross_weight2      => l_gross_weight2,
               x_return_status      => l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'error from Pre_Otm_Assign_Del_Detail');
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  -- End of OTM R12 : assign delivery detail

       --J TP Release ttrichy
       FOR cur in c_getdet_ignore LOOP
          IF l_del.ignore_for_planning <> cur.ignore_for_planning THEN
             fnd_message.set_name('WSH', 'WSH_DET_DEL_DIFF_IGNOREPLAN');
             IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             fnd_message.set_token('ENTITY1',nvl(wsh_container_utilities.get_cont_name(p_detail_id), p_detail_id));
             IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             fnd_message.set_token('ENTITY2',wsh_new_deliveries_pvt.get_name(p_delivery_id));
          END IF;
       END LOOP;

  OPEN c_all_details_below;
  --for locking all details
  LOOP
    FETCH c_all_details_below into l_dd_id(i);
    EXIT WHEN c_all_details_below%notfound;
    SELECT l_dd_id(i) into l_dummy_del_det_id
    FROM wsh_delivery_details
    WHERE delivery_detail_id=l_dd_id(i)
    FOR UPDATE NOWAIT;
    i:=i+1;
  END LOOP;
  CLOSE c_all_details_below;

  FOR j IN 0..(l_dd_id.COUNT-1) LOOP
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   /* For each detail */
    IF (l_dd_id(j) < 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.SET_name('WSH', 'WSH_DET_DETAIL_NOT_ASSIGNED');
      wsh_util_core.add_message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;




    OPEN c_detail(l_dd_id(j));
    FETCH c_detail into l_detail;
    CLOSE c_detail;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Released Status',l_detail.released_status);
        WSH_DEBUG_SV.log(l_module_name,'Delivery Id',l_detail.delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'p_Delivery Id',p_delivery_id);
       WSH_DEBUG_SV.log(l_module_name,'Line Freight Terms',l_detail.freight_Terms_code);
      END IF;
      --
    --
    -- Bypass this check for inbound lines as a they can be assigned to delivery
    -- during ASN/Receipt integration, (line status is C)
    --
    IF l_detail.released_status = 'C'
      AND l_detail.line_direction IN ('O','IO')   -- J-IB-NPARIKH
      THEN
      RAISE DET_CONFIRMED;
    END IF;


    IF  ((l_detail.delivery_id IS NOT NULL) AND (l_detail.delivery_id <> p_delivery_id)) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_DET_ASSIGNED_DEL');
       FND_MESSAGE.SET_TOKEN('DET_NAME',l_detail.delivery_detail_id);
            FND_MESSAGE.SET_TOKEN('DEL_NAME',l_detail.delivery_id);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status,l_module_name);
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
    END IF;

          IF l_detail.container_flag = 'Y' THEN --{ Bug 5100229
            -- bug 2691385 -  check to see if the container is empty
            WSH_CONTAINER_UTILITIES.Is_Empty (p_container_instance_id => l_dd_id(j),
                                            x_empty_flag => l_detail_is_empty_cont,
                                            x_return_status => x_return_status);
            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              return;
            END IF;
          ELSE --}{
             l_detail_is_empty_cont := 'E';
          END IF; --}

          -- If the container is empty, update the delivery grouping attributes for the container
          -- to be the delivery grouping attributes of the delivery.
          IF (l_detail_is_empty_cont = 'Y')
          THEN
          --{
                IF  l_detail.line_direction  IN ('O','IO')
                AND l_del.shipment_direction IN ('O','IO')
                THEN
                    l_detail.line_direction := l_del.shipment_direction;
                END IF;
                --
                /*
                IF  l_detail.line_direction  NOT IN ('O','IO')
                AND l_del.shipment_direction NOT IN ('O','IO')
                THEN
                    l_detail.line_direction := l_del.shipment_direction;
                END IF;
                */
                --
                -- K LPN CONV. rv
                --
                l_detail_wms_org := wsh_util_validate.check_wms_org(l_detail.organization_id);
                --
                IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                AND l_detail.line_direction IN ('O','IO')
                AND
                (
                  (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_detail_wms_org = 'Y')
                  OR
                  (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_detail_wms_org = 'N')
                )
                THEN
                --{
                    l_sync_tmp_rec.delivery_detail_id := l_dd_id(j);
                    l_sync_tmp_rec.operation_type := 'UPDATE';
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_WMS_SYNC_TMP_PKG.MERGE
                    (
                      p_sync_tmp_rec      => l_sync_tmp_rec,
                      x_return_status     => l_return_status
                    );

                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return Status is ',l_return_status);
                    END IF;
                    --
                    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                    --
                      x_return_status := l_return_status;
                    --
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                    --
                      return;
                    --
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                    --
                      l_num_warnings := l_num_warnings + 1;
                    --
                    END IF;
                    --
                --}
                END IF;
                -- K LPN CONV. rv

                UPDATE WSH_DELIVERY_DETAILS
                   SET ship_from_location_id = l_del.initial_pickup_location_id,
                       ship_to_location_id = l_del.ultimate_dropoff_location_id,
                       customer_id = l_del.customer_id,
                       intmed_ship_to_location_id = l_del.intmed_ship_to_location_id,
                       fob_code = l_del.fob_code,
                       freight_terms_code = l_del.freight_terms_code,
                       ship_method_code = l_del.ship_method_code,
                       service_level = l_del.service_level,
                       carrier_id = l_del.carrier_id,
                       mode_of_transport = l_del.mode_of_transport,
                       line_direction      = l_detail.line_direction ,   -- J-IB-NPARIKH
                       shipping_control    = l_del.shipping_control,   -- J-IB-NPARIKH
                       client_id           = l_del.client_id          -- LSP PROJECT
                 WHERE delivery_detail_id = l_dd_id(j);

                IF (SQL%NOTFOUND) THEN
                  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  RAISE NO_DATA_FOUND;
                END IF;

               --Bug 3383843
               -- Need to open and fetch again because of previous updates
               OPEN c_detail(l_dd_id(j));
               FETCH c_detail into l_detail;
               CLOSE c_detail;
              -- Bug 3383843

          --}
          END IF;
          -- end 2691385


    IF l_detail.container_flag='Y' THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CHECK_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_CONTAINER_ACTIONS.Check_Cont_Attributes (
      l_detail.delivery_detail_id,
      l_attr_flag,
      x_return_status);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.SET_name('WSH', 'WSH_CONT_ATTR_ERROR');
         FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_detail.delivery_detail_id);
      wsh_util_core.add_message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;

       /* security rule, group by attributes must be the same as the delivery's */
       /* Error */
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.CHECK_ASSIGN_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
      --

       l_attr_tab(1).entity_id := p_delivery_id;
       l_attr_tab(1).entity_type := 'DELIVERY';
       l_attr_tab(2).entity_id := l_detail.delivery_detail_id;
       l_attr_tab(2).entity_type := 'DELIVERY_DETAIL';

       l_action_rec.action := 'MATCH_GROUPS';
       l_action_rec.check_single_grp := 'Y';

       -- IF this procedure is called from autocreate-delivery then
       -- the matching is already done.

       IF NVL(p_caller , 'WSH') <> 'AUTOCREATE' THEN --{ bug 5100229
          WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab => l_group_tab,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => l_group_status);

          IF (l_group_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             --
             RETURN;
          END IF;
       END IF; --}

       -- Pack J: Generic Carrier
       -- Update the ship method components in the delivery
       -- to match the assigned delivery_detail.
       -- Also update the line direction.

       IF NVL(p_caller, 'WSH')  <> 'AUTOCREATE' THEN --{ bug 5100229

          -- if this is called from autocreate delivery then the ship
          -- method componants are already set there for the delivery.

          l_service_level  := l_group_tab(l_group_tab.first).service_level;
          l_mode_of_transport  := l_group_tab(l_group_tab.first).mode_of_transport;
          l_carrier_id        :=  l_group_tab(l_group_tab.first).carrier_id;
          l_ship_method        :=  l_group_tab(l_group_tab.first).ship_method_code;
          l_client_id          :=  l_group_tab(l_group_tab.first).client_id; -- LSP PROJECT
       END IF; --}

       -- OTM R12 : update delivery
       l_tms_update := 'N';
       l_new_interface_flag_tab(1) := NULL;

       IF (l_gc3_is_installed = 'Y' AND
           nvl(l_del.ignore_for_planning, 'N') = 'N') THEN
         l_trip_not_found := 'N';

         --get trip information for delivery, no update when trip not OPEN
         WSH_DELIVERY_VALIDATIONS.get_trip_information
                      (p_delivery_id     => p_delivery_id,
                       x_trip_info_rec   => l_trip_info_rec,
                       x_return_status   => l_return_status);

         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
           x_return_status := l_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_trip_information');
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         END IF;

         IF (l_trip_info_rec.trip_id IS NULL) THEN
           l_trip_not_found := 'Y';
         END IF;

         -- only do changes when there's no trip or trip status is OPEN
         IF (l_trip_info_rec.status_code = 'OP' OR
             l_trip_not_found = 'Y') THEN

           WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                                 p_delivery_id   => p_delivery_id,
                                 x_delivery_rec  => l_delivery_info,
                                 x_return_status => l_return_status);

           IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
             x_return_status := l_return_status;
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_delivery_information');
               WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             RETURN;
           END IF;

           -- if delivery is include for planning and service level, mode of
           -- transport, carrier id, or ship mdethod is changed with the nvl
           -- updates, then update is needed

           IF (nvl(l_delivery_info.service_level,
                   nvl(l_service_level, '@@')) <>
               nvl(l_delivery_info.service_level, '@@') OR
               nvl(l_delivery_info.mode_of_transport,
                   nvl(l_mode_of_transport, '@@')) <>
               nvl(l_delivery_info.mode_of_transport, '@@') OR
               nvl(l_delivery_info.carrier_id, nvl(l_carrier_id, -1)) <>
               nvl(l_delivery_info.carrier_id, -1) OR
               nvl(l_delivery_info.ship_method_code,
                   nvl(l_ship_method, '@@')) <>
               nvl(l_delivery_info.ship_method_code, '@@')) THEN

             IF (l_delivery_info.tms_interface_flag NOT IN
                 (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED)) THEN
               l_tms_update := 'Y';
               l_delivery_info_tab(1) := l_delivery_info;
               l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
               l_tms_version_number := nvl(l_delivery_info.tms_version_number, 1) + 1;
             END IF;
           END IF; -- checking the value differences
         END IF; -- IF ((l_trip_not_found = 'N' AND
       END IF; -- IF (l_gc3_is_installed = 'Y'

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_gc3_is_installed', l_gc3_is_installed);
         WSH_DEBUG_SV.log(l_module_name, 'l_tms_update', l_tms_update);
         IF (l_tms_update = 'Y') THEN
           WSH_DEBUG_SV.log(l_module_name, 'l_new_interface_flag_tab', l_new_interface_flag_tab(1));
           WSH_DEBUG_SV.log(l_module_name, 'l_tms_version_number', l_tms_version_number);
         END IF;
       END IF;

       -- End of OTM R12 : update delivery

       UPDATE WSH_NEW_DELIVERIES
          SET MODE_OF_TRANSPORT = decode(mode_of_transport, NULL, l_mode_of_transport, mode_of_transport),
              SERVICE_LEVEL = decode(service_level, NULL, l_service_level, service_level),
              CARRIER_ID = decode(carrier_id, NULL, l_carrier_id, carrier_id),
              SHIP_METHOD_CODE = decode(ship_method_code, NULL, l_ship_method, ship_method_code),
              SHIPMENT_DIRECTION = l_detail.line_direction,
              -- OTM R12
              TMS_INTERFACE_FLAG = decode(l_tms_update, 'Y', l_new_interface_flag_tab(1), nvl(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
              TMS_VERSION_NUMBER = decode(l_tms_update, 'Y', l_tms_version_number, nvl(tms_version_number, 1)),
              -- End of OTM R12
              client_id          = decode(client_id,NULL,l_client_id,client_id) -- LSP PROJECT
        WHERE delivery_id = p_delivery_id;

       -- OTM R12 : update delivery
       IF (l_gc3_is_installed = 'Y' AND l_tms_update = 'Y') THEN
         WSH_XC_UTIL.LOG_OTM_EXCEPTION(
                p_delivery_info_tab      => l_delivery_info_tab,
                p_new_interface_flag_tab => l_new_interface_flag_tab,
                x_return_status          => l_return_status);

         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
           x_return_status := l_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_XC_UTIL.log_otm_exception');
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         END IF;
       END IF;
       -- End of OTM R12 : update delivery

  /* security rule, ship-to-location and ship-FROM-location must be the
  same as the delivery's */
  /* Error */

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'initial_pickup_location_id'
                                         ,l_del.initial_pickup_location_id);
                     WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id',
                                          l_detail.ship_from_location_id);
                     WSH_DEBUG_SV.log(l_module_name,
                                          'ultimate_dropoff_location_id',
                                          l_del.ultimate_dropoff_location_id);
                     WSH_DEBUG_SV.log(l_module_name,'ship_to_location_id',
                                          l_detail.ship_to_location_id);
                   END IF;
       IF ((l_del.initial_pickup_location_id <> l_detail.ship_from_location_id)
        or (l_del.ultimate_dropoff_location_id <> l_detail.ship_to_location_id)
       or (l_detail.ship_to_location_id IS null)) THEN
      RAISE DETAIL_DEL_FROM_to_not_SAME ;
       END IF;
    --
    -- K LPN CONV. rv
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    AND l_detail.line_direction IN ('O', 'IO')
    AND l_detail.container_flag='Y'
    AND
    (
      (WSH_WMS_LPN_GRP.GK_WMS_ASSIGN_DLVY and l_detail_wms_org = 'Y')
      OR
      (WSH_WMS_LPN_GRP.GK_INV_ASSIGN_DLVY and l_detail_wms_org = 'N')
    )
    THEN
    --{
        l_sync_tmp_rec.delivery_detail_id := l_detail.delivery_detail_id;
        l_sync_tmp_rec.parent_delivery_detail_id := l_detail.parent_delivery_detail_id;
        l_sync_tmp_rec.delivery_id := l_detail.delivery_id;
        l_sync_tmp_rec.operation_type := 'PRIOR';
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_WMS_SYNC_TMP_PKG.MERGE
        (
          p_sync_tmp_rec      => l_sync_tmp_rec,
          x_return_status     => l_return_status
        );

        --
        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        --
          x_return_status := l_return_status;
        --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
        --
          return;
        --
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        --
          l_num_warnings := l_num_warnings + 1;
        --
        END IF;
        --
    --}
    END IF;
    -- K LPN CONV. rv
    --

    UPDATE wsh_delivery_assignments
    SET delivery_id = p_delivery_id,
        last_update_date = SYSDATE,
        last_updated_by =  FND_GLOBAL.USER_ID,
        last_update_login =  FND_GLOBAL.LOGIN_ID
    WHERE delivery_detail_id = l_detail.delivery_detail_id
      AND (type IN ('S', 'O') OR type IS NULL);

    IF (SQL%NOTFOUND) THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           RAISE NO_DATA_FOUND;
    END IF;

    l_mdc_detail_tab(1) := l_detail.delivery_detail_id;
    WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                       p_detail_id_tab     => l_mdc_detail_tab,
                       x_return_status => x_return_status);

    IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;


                -- J-IB-NPARIKH-{
                --
                --
                -- Set freight terms for inbound/drop-ship delivery
                --   For non-empty delivery, set freight term to null,
                --   if line's freight term is different
                --   For an empty delivery, set freight term to line's value
                --
                x_dlvy_freight_terms_code := l_del.freight_terms_code;
                --
                IF  NVL(l_detail.container_flag,'N') = 'N'
                AND l_detail.line_direction     NOT IN ('O','IO')
                THEN
                --{
                    IF  x_dlvy_has_lines                          = 'Y'
                    AND x_dlvy_freight_terms_code                 IS NOT NULL
                    AND NVL(l_detail.freight_terms_code,'!!!!!') <> x_dlvy_freight_terms_code
                    THEN
                        --
                        -- Non-empty delivery has different freight term than line's
                        -- So, we need to update delivery freight term to NULL
                        --
                        x_dlvy_freight_terms_code := NULL;
                    ELSIF x_dlvy_has_lines                          = 'N'
                    AND   NVL(l_detail.freight_terms_code,'!!!!!') <> NVL(x_dlvy_freight_terms_code,'!!!!!')
                    THEN
                        x_dlvy_freight_terms_code := l_detail.freight_terms_code;
                    END IF;
                    --
                    --
                    IF NVL(l_del.freight_terms_code,'!!!!!') <> NVL(x_dlvy_freight_terms_code,'!!!!!')
                    THEN
                    --{
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Delivery updated Freight Terms',x_dlvy_freight_terms_code);
                        END IF;
                        --

                        -- OTM R12 : update delivery
                        -- no code changes are needed for the following update
                        -- since this routine is only for Inbound/drop-ship
                        -- deliveries, OTM flow will never reach here

                        UPDATE  wsh_new_deliveries
                        SET     freight_terms_code = x_dlvy_freight_terms_code,
                                last_update_date   = SYSDATE,
                                last_updated_by    = FND_GLOBAL.USER_ID,
                                last_update_login  = FND_GLOBAL.LOGIN_ID
                        WHERE   delivery_id        = p_delivery_id;
                        --
                        IF (SQL%NOTFOUND)
                        THEN
                            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                            RAISE INVALID_DEL;
                        END IF;
                    --}
                    END IF;
                --}
                END IF;
                --
                x_dlvy_has_lines := 'Y';
                --
                -- J-IB-NPARIKH-}


             IF (l_detail.released_status = WSH_DELIVERY_DETAILS_PKG.C_RELEASED_TO_WAREHOUSE) THEN
             --{
               IF (wsh_util_validate.Check_Wms_Org(l_detail.organization_id)='Y') AND
                  (l_detail.move_order_line_id IS NOT NULL AND
                   (WSH_USA_INV_PVT.is_mo_type_putaway
                         (p_move_order_line_id => l_detail.move_order_line_id) = 'N') -- X-dock
                  ) THEN -- check if  wms org

               -- Update Cartonization ID.
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.update_mol_carton_group',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               INV_MO_Cancel_PVT.update_mol_carton_group
                 (p_line_id            => l_detail.move_order_line_id,
                  p_carton_grouping_id => p_delivery_id,
                  x_return_status      => x_return_status,
                  x_msg_cnt            => l_msg_count,
                  x_msg_data           => l_msg_data);

                IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                        WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                  RAISE update_mol_carton_group_error;
                END IF;
               END IF;
             --}
             END IF;

  --if container check attr flag, update container hierarchy
    IF l_detail.container_flag='Y' THEN
        IF l_attr_flag = 'N' THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_HIERARCHY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_CONTAINER_ACTIONS.Update_Cont_Hierarchy (
            NULL,
            p_delivery_id,
            l_detail.delivery_detail_id,
            x_return_status);
        IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UPD_ATTR_ERROR');
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_detail.delivery_detail_id);
          FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
          WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              return;
          END IF;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;--for container
    /* H projects: pricing integration csun , if any lines are
       successfully unassign from the delivery, the delivery needs to be marked
       for repricing */
    l_scc_unassign_from_del := l_scc_unassign_from_del + 1;
  END LOOP;
        /* For each detail*/


  -- OTM R12 : assign delivery detail
  IF (l_assign_update AND
      l_gc3_is_installed = 'Y' AND
      nvl(l_del.ignore_for_planning, 'N') = 'N') THEN

    IF (l_tms_update = 'Y') THEN
      l_tms_interface_flag := l_new_interface_flag_tab(1);
    ELSIF (l_trip_info_rec.status_code = 'OP' OR
           l_trip_not_found = 'Y') THEN
      l_tms_interface_flag := nvl(l_delivery_info.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT);
    ELSE
      l_tms_interface_flag := NULL;
    END IF;

    Post_Otm_Assign_Del_Detail
              (p_delivery_id         => p_delivery_id,
               p_delivery_was_empty  => l_delivery_was_empty,
               p_tms_interface_flag  => l_tms_interface_flag,
               p_gross_weight        => l_gross_weight1,
               x_return_status       => l_return_status);

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'error from Post_Otm_Assign_Del_Detail');
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      l_num_warnings := l_num_warnings + 1;
    END IF;
  END IF;
  -- End of OTM R12 : assign delivery detail

        -- J: W/V Changes
        -- Increment the delivery W/V by DD W/V
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id => p_detail_id,
          p_diff_gross_wt      => l_gross_wt,
          p_diff_net_wt        => l_net_wt,
          p_diff_volume        => l_vol,
          p_diff_fill_volume   => l_vol,
          x_return_status      => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
             --
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             WSH_UTIL_CORE.Add_Message(x_return_status);
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             return;
        END IF;

  --
  IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_scc_unassign_from_del',
                            l_scc_unassign_from_del);
  END IF;

        /*  H integration: Pricing integration csun */
        IF l_scc_unassign_from_del > 0 THEN
                l_del_tab.delete;
                l_del_tab(1) := p_delivery_id;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
          END IF;
  END IF;

  -- LPN CONV. rv
  IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
  ELSE
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
  END IF;
  -- LPN CONV. rv


--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
                -- J-IB-NPARIKH-{
                WHEN FND_API.G_EXC_ERROR THEN
                    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
                    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                    --
                    IF l_debug_on
                    THEN
                        WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
                    END IF;
                -- J-IB-NPARIKH-}

    WHEN  mark_reprice_error THEN
      FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      x_return_status := l_return_status;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
END IF;
--
                WHEN update_mol_carton_group_error THEN
      fnd_message.SET_name('WSH', 'WSH_MOL_CARTON_GROUP_ERROR');
                        x_return_status := l_return_status;
                        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

                      --
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'update_mol_carton_group_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:update_mol_carton_group_error');
                      END IF;


    WHEN INVALID_DEL THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.SET_name('WSH', 'WSH_DET_INVALID_DEL');
      wsh_util_core.add_message(x_return_status,l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DEL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DEL');
          END IF;
          RETURN;
          --
    WHEN DEL_NOT_UPDATABLE THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'DEL_NOT_UPDATABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DEL_NOT_UPDATABLE');
          END IF;
          --
          RETURN;
    WHEN INVALID_DETAIL THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.SET_name('WSH', 'WSH_DET_INVALID_DETAIL');
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
      wsh_util_core.add_message(x_return_status,l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DETAIL');
          END IF;
          --
          RETURN;
        WHEN DET_CONFIRMED THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.SET_name('WSH', 'WSH_DET_CONFIRMED_DETAIL');
            FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_detail_id);
            wsh_util_core.add_message(x_return_status,l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'DET_CONFIRMED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DET_CONFIRMED');
          END IF;
          --
          RETURN;
    WHEN detail_del_FROM_to_not_same THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.SET_name('WSH', 'WSH_DET_SHIP_F_T_N_MATCH');
      wsh_util_core.add_message(x_return_status,l_module_name);



--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DETAIL_DEL_FROM_TO_NOT_SAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DETAIL_DEL_FROM_TO_NOT_SAME');
END IF;
--
          RETURN;
    WHEN ship_method_not_match THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.SET_name('WSH', 'WSH_DET_SHIP_METHOD_NOT_MATCH');
      wsh_util_core.add_message(x_return_status,l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'SHIP_METHOD_NOT_MATCH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:SHIP_METHOD_NOT_MATCH');
          END IF;
          --
          RETURN;
    WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_TOP_DETAIL_TO_DELIVERY',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
          RETURN;
END Assign_Top_Detail_To_Delivery;
-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Assign_Top_Detail_To_Delivery(
    P_DETAIL_ID     IN NUMBER,
    P_DELIVERY_ID   IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY  VARCHAR2
    ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_TOP_DETAIL_TO_DELIVERY';
--
l_has_lines               VARCHAR2(1);
l_dlvy_freight_terms_code VARCHAR2(30);
--
BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_has_lines := WSH_DELIVERY_VALIDATIONS.has_lines
                        (
                            p_delivery_id => p_delivery_id
                        );
    --
    ASSIGN_TOP_DETAIL_TO_DELIVERY
        (
            p_detail_id               => p_detail_id,
            p_delivery_id             => p_delivery_id,
            X_RETURN_STATUS           => X_RETURN_STATUS,
            x_dlvy_has_lines               => l_has_lines,
            x_dlvy_freight_Terms_code => l_dlvy_freight_Terms_code
        );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_TOP_DETAIL_TO_DELIVERY',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Assign_Top_Detail_To_Delivery;

-- THIS PROCEDURE IS OBSOLETE
--
--Procedure:      Unassign_Cont_from_Delivery
--Parameters:      p_detail_id,
--            x_return_status
--Desription:     Unassign an container FROM a delivery
-- Note:         need to drill up down to UPDATE delivery_id to NULL

PROCEDURE Unassign_Cont_from_Delivery(
  p_detail_id   IN NUMBER,
  X_RETURN_STATUS  OUT NOCOPY  VARCHAR2,
  p_validate_flag  IN VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_CONT_FROM_DELIVERY';
--
BEGIN
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  --
END Unassign_Cont_FROM_Delivery;

--
--Procedure:      Assign_Cont_to_Cont
--Parameters:      p_detail_id1
--              p_detail_id2
--            x_return_status
--Desription:      Assigns a container to another container

-- it is called when assigning container1 to container2
-- if container1 is already assigned to a delivery,  then drill up and down
-- of the container2 and assign delivery_id to all the parent and child
-- containers of the container2.

-- if container2 is already assigned to a delivery,   then drill up and down
-- of container1 and assign delivery_id to all parent and child containers
-- of the container1


PROCEDURE Assign_Cont_To_Cont(
  p_detail_id1   IN NUMBER,
  p_detail_id2   IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)
IS

--Bug 3522687 : OMFST:J:R2:RG:APPLN HANGS WHILE PERFORMING MANUAL PACKING ACTION
--Modified cursor check_loop
/*
CURSOR check_loop(x_delivery_detail_id NUMBER) IS
 SELECT delivery_detail_id
 FROM wsh_delivery_assignments_v
 START WITH delivery_detail_id = x_delivery_detail_id
 CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;
*/

  CURSOR c_get_shipto (p_container_id NUMBER) IS
  SELECT ship_to_location_id
  FROM wsh_delivery_details
  WHERE delivery_detail_id = p_container_id;

  l_container_is_empty   BOOLEAN;
  l_ship_to_loc          NUMBER;
  l_display_error        BOOLEAN;


CURSOR check_loop(p_inner_cont_id NUMBER,p_outer_cont_id NUMBER) IS
  SELECT delivery_detail_id
  FROM   wsh_delivery_assignments_v
  WHERE delivery_detail_id =  p_outer_cont_id
  START WITH delivery_detail_id = p_inner_cont_id
  CONNECT BY prior delivery_detail_id = parent_delivery_detail_id;

  -- Bug 3715176
  CURSOR c_get_plan_flag (v_delivery_id NUMBER) IS
  SELECT nvl(planned_flag,'N')
  FROM   wsh_new_deliveries
  WHERE  delivery_id = v_delivery_id;

  CURSOR c_get_content_count(v_delivery_detail_id NUMBER) IS
  SELECT count(*)
  FROM   wsh_delivery_assignments_v wda
  WHERE	 wda.parent_delivery_detail_id = v_delivery_detail_id and rownum = 1;
  -- Bug 3715176

/*  Commenting this out - Bug 2457558
-- Bug 2167042-added to check fill percentage for a container
--             when packing a container

CURSOR Get_Min_Fill(v_cont_id NUMBER) IS
SELECT nvl(minimum_fill_percent,0)
  FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_cont_id
   AND container_flag = 'Y';

l_min_fill NUMBER;
l_fill NUMBER;
l_gross NUMBER;
l_net NUMBER;
l_volume NUMBER;
l_cont_name VARCHAR2(30);
x_pack_status VARCHAR2(30);

End of adding cursor for fill percentage
*/
l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_del_id_for_container1 C_DEL_ID_FOR_CONT_OR_DETAIL%ROWTYPE;
l_del_id_for_container2 C_DEL_ID_FOR_CONT_OR_DETAIL%ROWTYPE;

detail_cont_name WSH_DELIVERY_DETAILS.CONTAINER_NAME%TYPE;
parent_cont_name WSH_DELIVERY_DETAILS.CONTAINER_NAME%TYPE;

l_group_by_flags WSH_DELIVERY_AUTOCREATE.group_by_flags_rec_type;
/* H projects: pricing integration csun */
m	    NUMBER := 0;
l_del_tab   WSH_UTIL_CORE.Id_Tab_Type;
mark_reprice_error  EXCEPTION;
l_plan_flag varchar2(1);
l_content_count NUMBER;

l_out_container  NUMBER := 0 ;
--
-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_sync_tmp_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_num_warnings NUMBER := 0;
l_operation_type VARCHAR2(100);
-- K LPN CONV. rv
l_mdc_detail_tab   WSH_UTIL_CORE.Id_Tab_Type;
l_ignore_det_tab   WSH_UTIL_CORE.Id_Tab_Type;

-- OTM R12 : assign delivery detail
l_delivery_was_empty      BOOLEAN;
l_tms_interface_flag      WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
l_gross_weight1           WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE;
l_gross_weight2           WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE;
l_gc3_is_installed        VARCHAR2(1);
l_assign_update           BOOLEAN;
-- End of OTM R12 : assign delivery detail

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_CONT_TO_CONT';
--
BEGIN
  -- assumption:  IF both container1 and container2 are already
  -- assigned to deliveries. Both deliveries must be the same
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID1',P_DETAIL_ID1);
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID2',P_DETAIL_ID2);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  l_assign_update := FALSE;  --default assignment tms update to false
  -- End of OTM R12

  OPEN c_del_id_FOR_cont_or_detail(p_detail_id1);
  FETCH c_del_id_for_cont_or_detail into l_del_id_for_container1;
  CLOSE c_del_id_for_cont_or_detail;

        -- J: W/V Changes
  IF l_del_id_for_container1.parent_delivery_detail_id = p_detail_id2 THEN
      IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Cont '||p_detail_id1||' is already assigned to '||p_detail_id2||'. Returning');
            WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
  END IF;

  OPEN c_del_id_for_cont_or_detail(p_detail_id2);
  FETCH c_del_id_for_cont_or_detail into l_del_id_for_container2;
  CLOSE c_del_id_for_cont_or_detail;

  -- K LPN CONV. rv
  --
  l_wms_org := wsh_util_validate.check_wms_org(l_del_id_for_container2.organization_id);
  --
  -- K LPN CONV. rv
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'delivery_id 1',
                                         l_del_id_for_container1.delivery_id);
           WSH_DEBUG_SV.log(l_module_name,'organization_id 1',
                                      l_del_id_for_container1.organization_id);
           WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id 1',
                                 l_del_id_for_container1.ship_from_location_id);
           WSH_DEBUG_SV.log(l_module_name,'customer_id 1',
                                         l_del_id_for_container1.customer_id);
           WSH_DEBUG_SV.log(l_module_name,'intmed_ship_to_location_id 1',
                            l_del_id_for_container1.intmed_ship_to_location_id);
           WSH_DEBUG_SV.log(l_module_name,'fob_code 1',
                                         l_del_id_for_container1.fob_code);
           WSH_DEBUG_SV.log(l_module_name,'freight_terms_code 1',
                                   l_del_id_for_container1.freight_terms_code);
           WSH_DEBUG_SV.log(l_module_name,'ship_method_code 1',
                                      l_del_id_for_container1.ship_method_code);
           WSH_DEBUG_SV.log(l_module_name,'parent_delivery_detail_id 1',
                            l_del_id_for_container1.parent_delivery_detail_id);

           WSH_DEBUG_SV.log(l_module_name,'delivery_id 2',
                                         l_del_id_for_container2.delivery_id);
           WSH_DEBUG_SV.log(l_module_name,'organization_id 2',
                                      l_del_id_for_container2.organization_id);
           WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id 2',
                                 l_del_id_for_container2.ship_from_location_id);
           WSH_DEBUG_SV.log(l_module_name,'customer_id 2',
                                         l_del_id_for_container2.customer_id);
           WSH_DEBUG_SV.log(l_module_name,'intmed_ship_to_location_id 2',                                                       l_del_id_for_container2.intmed_ship_to_location_id);
           WSH_DEBUG_SV.log(l_module_name,'fob_code 2',
                                         l_del_id_for_container2.fob_code);
           WSH_DEBUG_SV.log(l_module_name,'freight_terms_code 2',
                                   l_del_id_for_container2.freight_terms_code);
           WSH_DEBUG_SV.log(l_module_name,'ship_method_code 2',
                                      l_del_id_for_container2.ship_method_code);
           WSH_DEBUG_SV.log(l_module_name,'parent_delivery_detail_id 2',
                            l_del_id_for_container2.parent_delivery_detail_id);
           WSH_DEBUG_SV.log(l_module_name,'customer',
                                             l_group_by_flags.customer);
           WSH_DEBUG_SV.log(l_module_name,'intmed',
                                            l_group_by_flags.intmed);
           WSH_DEBUG_SV.log(l_module_name,'fob', l_group_by_flags.fob);
           WSH_DEBUG_SV.log(l_module_name,'freight_terms',
                                             l_group_by_flags.freight_terms);
           WSH_DEBUG_SV.log(l_module_name,'ship_method',
                                             l_group_by_flags.ship_method);

        END IF;


     /* Check to see if the line is already packed */
     IF (l_del_id_for_container1.parent_delivery_detail_id IS NOT NULL
      AND l_del_id_for_container1.parent_delivery_detail_id <>
        p_detail_id2
      ) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DET_PACK_ERROR');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DET_LINE',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;

  -- OTM R12 : assign delivery detail
  IF (l_gc3_is_installed = 'Y' AND
      nvl(l_del_id_for_container1.ignore_for_planning, 'N') = 'N') THEN

    Pre_Otm_Assign_Del_Detail
              (p_delivery_id        => NULL,
               p_detail_id          => NULL,
               p_container1_id      => p_detail_id1,
               p_container2_id      => p_detail_id2,
               p_assignment_type    => 'C2C',
               x_delivery_was_empty => l_delivery_was_empty,
               x_assign_update      => l_assign_update,
               x_gross_weight1      => l_gross_weight1,
               x_gross_weight2      => l_gross_weight2,
               x_return_status      => l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
      --handle the error approriately to the procedure this code is in
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'error from Pre_Otm_Assign_Del_Detail');
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  -- End of OTM R12 : assign delivery detail

    --Bug 3522687 : OMFST:J:R2:RG:APPLN HANGS WHILE PERFORMING MANUAL PACKING ACTION
    --Cursor check_loop returns delivery_detail_id of the
    --outer container if outer container is packed in the inner container.

	OPEN check_loop(p_detail_id1,p_detail_id2);
	FETCH check_loop into l_out_container;

	-- If cursor returns then we have self nesting in containers

	IF (check_loop%FOUND) THEN

	     CLOSE check_loop;
 	     FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LOOP_NO_PACK');
		--
	     IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	     END IF;
		--
	     FND_MESSAGE.SET_TOKEN('DETAIL_CONTAINER',
		nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
		--
	     IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	     END IF;
		--
	     FND_MESSAGE.SET_TOKEN('PARENT_CONTAINER',
		nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
	     IF l_debug_on THEN
		  WSH_DEBUG_SV.pop(l_module_name);
             END IF;
		--
	    return;
	END IF;
        CLOSE check_loop;
    -- End of fix for bug 3522687

    /* Added code to validate grouping attributes for Child Container and master
    Container */
    IF (l_del_id_for_container1.organization_id <>
       l_del_id_for_container2.organization_id) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_ORG_DIFF');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('ENTITY1',
            nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('ENTITY2',
            nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    IF (l_del_id_for_container1.ship_from_location_id <>
       l_del_id_for_container2.ship_from_location_id) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
        nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
     END IF;

        --J TP Release
      IF (l_del_id_for_container1.ignore_for_planning <>
              l_del_id_for_container2.ignore_for_planning) THEN


           -- R12: MDC
           -- If called by WMS, and line is part of a consol delivery,
           -- then the ignore for planning flag is always 'Y'. For WMS,
           -- we need to set the child detail's ignore for planning status
           -- to be 'Y' before we attempt to pack.

           IF (l_wms_org = 'Y') AND
              ((l_del_id_for_container1.wda_type = 'O') OR (l_del_id_for_container2.wda_type = 'O')) --{
           THEN
              IF l_del_id_for_container1.wda_type = 'O' THEN
                 l_ignore_det_tab(1) := p_detail_id2;
              ELSE
                 l_ignore_det_tab(1) := p_detail_id1;
              END IF;

              WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'DLVB',
                    p_in_ids        => l_ignore_det_tab,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => x_return_status);

              IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN

                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_DIFF_IGNOREPLAN');
                 FND_MESSAGE.SET_TOKEN('ENTITY1',nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('ENTITY2',nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 RETURN;

              END IF;


           ELSE --}
              l_display_error := TRUE;
              IF (l_wms_org = 'Y')  THEN--{
                 OPEN c_get_shipto(p_detail_id2);
                 FETCH c_get_shipto INTO l_ship_to_loc;
                 CLOSE c_get_shipto;
                 --
                 l_container_is_empty := l_ship_to_loc IS NULL;
                 --
                 IF l_container_is_empty THEN --{


                    l_ignore_det_tab(1) := p_detail_id2;
                    WSH_TP_RELEASE.change_ignoreplan_status
                      (p_entity        => 'DLVB',
                       p_in_ids        => l_ignore_det_tab,
                       p_action_code   => 'IGNORE_PLAN',
                       x_return_status => l_return_status);

                    IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN --{
                       l_display_error := TRUE;
                    ELSE
                       l_display_error := FALSE;
                    END IF;--}
                 END IF; --}
              END IF ; --}

              IF l_display_error THEN --{
                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_DIFF_IGNOREPLAN');
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 FND_MESSAGE.SET_TOKEN('ENTITY1',nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 FND_MESSAGE.SET_TOKEN('ENTITY2',nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 RETURN;
              END IF; --}
           END IF;
        END IF;

            --
            -- J-IB-NPARIKH-{
            --
            --
            -- O container can be assigned to empty IO container
            -- IO container can be assigned to empty O container
            -- Otherwise, both containers' line direction must match
            --
            IF (l_del_id_for_container1.line_direction <> l_del_id_for_container2.line_direction)
            THEN
            --{
                IF  l_del_id_for_container1.line_direction IN ('O','IO')
                AND l_del_id_for_container2.line_direction IN ('O','IO')
                THEN
                --{
                    NULL;
                --}
                ELSE
                --{
                      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
                      --
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;
                      --
                      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
                              nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
                      --
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;
                      --
                      FND_MESSAGE.SET_TOKEN('CONT_NAME',
                            nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                      --
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                      --
                      RETURN;
                --}
                END IF;
            --}
            END IF;
            --
            -- J-IB-NPARIKH-}
            --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.GET_GROUP_BY_ATTR',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DELIVERY_AUTOCREATE.get_group_by_attr(
       p_organization_id => l_del_id_for_container1.organization_id,
       p_client_id       => l_del_id_for_container1.client_id, -- LSP PROJECT
       x_group_by_flags  => l_group_by_flags,
       x_return_status   => x_return_status);

    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := x_return_status;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

          --- Bug 3715176
          -- If delivery is same for container to pack and to be packed then it should not check firm status.
          IF l_del_id_for_container1.delivery_id = l_del_id_for_container2.delivery_id then
	        NULL;

	  Elsif l_del_id_for_container1.delivery_id is NOT NULL OR
	        l_del_id_for_container2.delivery_id is NOT NULL then

          Open  c_get_content_count(p_detail_id2);
	  Fetch c_get_content_count into l_content_count;
	  Close c_get_content_count;

          IF l_content_count > 0 THEN
	  IF l_del_id_for_container1.delivery_id IS NOT NULL then
	     OPEN c_get_plan_flag(l_del_id_for_container1.delivery_id);
	     FETCH c_get_plan_flag into l_plan_flag;
	     CLOSE c_get_plan_flag;

  	   if l_plan_flag <> 'N' then
	         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_STATUS_NOT_PROPER');

		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
             end if;
	   END IF;

	   IF l_del_id_for_container2.delivery_id IS NOT NULL then
	     OPEN c_get_plan_flag(l_del_id_for_container2.delivery_id);
	     FETCH c_get_plan_flag into l_plan_flag;
	     CLOSE c_get_plan_flag;

  	   if l_plan_flag <> 'N' then
	         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_STATUS_NOT_PROPER');

		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

                 WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
             end if;
	   END IF;
          END IF;
         END IF;
        -- Bug 3715176


    IF l_group_by_flags.customer = 'Y' THEN
      IF (l_del_id_for_container1.customer_id <>
       l_del_id_for_container2.customer_id) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;
    IF l_group_by_flags.intmed = 'Y' THEN
      IF (l_del_id_for_container1.intmed_ship_to_location_id <>
       l_del_id_for_container2.intmed_ship_to_location_id) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;
    IF l_group_by_flags.fob = 'Y' THEN
      IF (l_del_id_for_container1.fob_code <>
       l_del_id_for_container2.fob_code) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;
    IF l_group_by_flags.freight_terms = 'Y' THEN
      IF (l_del_id_for_container1.freight_terms_code <>
       l_del_id_for_container2.freight_terms_code) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;
    IF l_group_by_flags.ship_method = 'Y' THEN
      IF (NVL(l_del_id_for_container1.mode_of_transport, l_del_id_for_container2.mode_of_transport) <>
       NVL(l_del_id_for_container2.mode_of_transport, l_del_id_for_container1.mode_of_transport))
      OR (NVL(l_del_id_for_container1.service_level, l_del_id_for_container2.service_level) <>
       NVL(l_del_id_for_container2.service_level, l_del_id_for_container1.service_level))
      OR (NVL(l_del_id_for_container1.carrier_id, l_del_id_for_container2.carrier_id) <>
       NVL(l_del_id_for_container2.carrier_id, l_del_id_for_container1.carrier_id))
      THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NOT_MATCH');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id1), p_detail_id1));
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('CONT_NAME',
          nvl(wsh_container_utilities.get_cont_name(p_detail_id2), p_detail_id2));
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;
/* End of check for grouping attributes */


/* End of Check to see if the line is already packed */


  -- for bug 1336858 fix

  -- No need for savepoint
  -- savepoint before_cont_assignment;

        -- J: W/V Changes
        -- The first DD_WV_Post_Process call will decrement the cont1 W/V from delivery
        -- The second DD_WV_Post_Process call will increment the delivery W/V with cont2 W/V (since cont2 has to be
        -- assigned to the delivery if the cont1 being assigned to cont2 is already assigned to delivery)
        -- The third DD_WV_Post_Process cll will increment the cont2 W/V with cont1 W/V which in turn will adjust the
        -- delivery W/V, if the cont2 is in a delivery.
        IF (l_del_id_for_container1.delivery_id is not null) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id => p_detail_id1,
            p_diff_gross_wt      => -1 * l_del_id_for_container1.gross_weight,
            p_diff_net_wt        => -1 * l_del_id_for_container1.net_weight,
            p_diff_volume        => -1 * l_del_id_for_container1.volume,
            p_diff_fill_volume   => -1 * l_del_id_for_container1.volume,
            x_return_status      => l_return_status);

          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               --
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               WSH_UTIL_CORE.Add_Message(x_return_status);
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                   WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               return;
          END IF;

        END IF;

  IF (l_del_id_for_container1.delivery_id IS not NULL) THEN

          IF (l_del_id_for_container2.delivery_id IS NULL) THEN
	/* Bug 1571143,Combining the 2 cursors */
    -- K LPN CONV. rv
    -- Based on assumption that we are using wsh_delivery_assignments_v,
    -- delivery and its contents will belong to same organization.
    -- Similarly, container and its contents will belong to same organization.
    -- Hence, we are checking for WMS org or non-WMS org. at the
    -- parent level (i.e. delivery/container)
    -- rather than at line-level for performance reasons.

    -- If this assumptions were to be violated in anyway
    --    i.e Query was changed to refer to base table wsh_delivery_assignments instead of
    --     wsh_delivery_assignments_v
    -- or
    -- if existing query were to somehow return/fetch records where
    --    delivery and its contents may belong to diff. org.
    --    container and its contents may belong to diff. org.
    --    then
    --       Calls to check_wms_org needs to be re-adjusted at
    OPEN c_inside_outside_of_container(p_detail_id2);
    FETCH c_inside_outside_of_container BULK COLLECT INTO
          l_sync_tmp_recTbl.delivery_detail_id_tbl,
          l_sync_tmp_recTbl.parent_detail_id_tbl,
          l_sync_tmp_recTbl.delivery_id_Tbl;
    CLOSE c_inside_outside_of_container;
    IF (l_sync_tmp_recTbl.delivery_detail_id_tbl.count > 0 ) THEN
    --{
        --
        l_sync_tmp_recTbl.operation_type_tbl(1) := 'PRIOR';
        l_operation_type := 'PRIOR';
        --
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        AND nvl(l_del_id_for_container2.line_direction,'O') IN ('O', 'IO')
        AND
        (
          (WSH_WMS_LPN_GRP.GK_WMS_ASSIGN_DLVY and l_wms_org = 'Y')
          OR
          (WSH_WMS_LPN_GRP.GK_INV_ASSIGN_DLVY and l_wms_org = 'N')
        )
        THEN
        --{
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
            (
              p_sync_tmp_recTbl   => l_sync_tmp_recTbl,
              x_return_status     => l_return_status,
              p_operation_type    => l_operation_type
            );
            --
            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            --
              x_return_status := l_return_status;
            --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
            --
              return;
            --
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            --
              l_num_warnings := l_num_warnings + 1;
            --
            END IF;
            --
        --}
        END IF;
        --

        FORALL i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last
        UPDATE wsh_delivery_assignments_v
        SET delivery_id = l_del_id_for_container1.delivery_id,
            last_update_date = SYSDATE,
            last_updated_by =  FND_GLOBAL.USER_ID,
            last_update_login =  FND_GLOBAL.LOGIN_ID
        WHERE delivery_detail_id = l_sync_tmp_recTbl.delivery_detail_id_tbl(i);

        -- OTM R12 : assign delivery detail
        IF (l_assign_update AND
            l_gc3_is_installed = 'Y' AND
            nvl(l_del_id_for_container1.ignore_for_planning, 'N') = 'N') THEN

          l_tms_interface_flag := NULL;

          Post_Otm_Assign_Del_Detail
            (p_delivery_id         => l_del_id_for_container1.delivery_id,
             p_delivery_was_empty  => l_delivery_was_empty,
             p_tms_interface_flag  => l_tms_interface_flag,
             p_gross_weight        => l_gross_weight2, --using the gross weight of container2
             x_return_status       => l_return_status);

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'error from Post_Otm_Assign_Del_Detail');
            END IF;
            raise FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warnings := l_num_warnings + 1;
          END IF;

        END IF;
        -- End of OTM R12 : assign delivery detail

        FOR i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last LOOP
            l_mdc_detail_tab(i) := l_sync_tmp_recTbl.delivery_detail_id_tbl(i);
        END LOOP;
        WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                       p_detail_id_tab     => l_mdc_detail_tab,
                       x_return_status     => x_return_status);

        IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            return;
        END IF;
        l_mdc_detail_tab.delete;
        l_sync_tmp_recTbl.delivery_detail_id_tbl.delete;
        l_sync_tmp_recTbl.parent_detail_id_tbl.delete;
        l_sync_tmp_recTbl.delivery_id_tbl.delete;
        l_sync_tmp_recTbl.operation_type_tbl.delete;
    --}
    END IF;
    -- K LPN CONV. rv

                -- J: W/V Changes
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Assigning Container to Delivery');
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_WV_UTILS.DD_WV_Post_Process(
                  p_delivery_detail_id => p_detail_id2,
                  p_diff_gross_wt      => l_del_id_for_container2.gross_weight,
                  p_diff_net_wt        => l_del_id_for_container2.net_weight,
                  p_diff_volume        => l_del_id_for_container2.volume,
                  p_diff_fill_volume   => l_del_id_for_container2.volume,
                  x_return_status      => l_return_status);

                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                     --
                     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     WSH_UTIL_CORE.Add_Message(x_return_status);
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                         WSH_DEBUG_SV.pop(l_module_name);
                     END IF;
                     return;
                END IF;

    /* H projects: pricing integration csun , adding delivery */
    m := m+1;
    l_del_tab(m) := l_del_id_for_container1.delivery_id;
          END IF;

  ELSIF (l_del_id_FOR_container2.delivery_id IS NOT NULL) THEN

        /* Bug 1571143 ,Combining the 2 cursors */
    -- K LPN CONV. rv
    -- Based on assumption that we are using wsh_delivery_assignments_v,
    -- delivery and its contents will belong to same organization.
    -- Similarly, container and its contents will belong to same organization.
    -- Hence, we are checking for WMS org or non-WMS org. at the
    -- parent level (i.e. delivery/container)
    -- rather than at line-level for performance reasons.

    -- If this assumptions were to be violated in anyway
    --    i.e Query was changed to refer to base table wsh_delivery_assignments instead of
    --     wsh_delivery_assignments_v
    -- or
    -- if existing query were to somehow return/fetch records where
    --    delivery and its contents may belong to diff. org.
    --    container and its contents may belong to diff. org.
    --    then
    --       Calls to check_wms_org needs to be re-adjusted at
    OPEN c_inside_outside_of_container(p_detail_id1);
    FETCH c_inside_outside_of_container bulk collect into
          l_sync_tmp_recTbl.delivery_detail_id_tbl,
          l_sync_tmp_recTbl.parent_detail_id_tbl,
          l_sync_tmp_recTbl.delivery_id_tbl;

    CLOSE c_inside_outside_of_container;
    IF (l_sync_tmp_recTbl.delivery_detail_id_tbl.count > 0 ) THEN
    --{
        --
        l_sync_tmp_recTbl.operation_type_tbl(1) := 'PRIOR';
        l_operation_type := 'PRIOR';
        --
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        AND nvl(l_del_id_FOR_container2.line_direction,'O') IN ('O', 'IO')
        AND
        (
          (WSH_WMS_LPN_GRP.GK_WMS_ASSIGN_DLVY and l_wms_org = 'Y')
          OR
          (WSH_WMS_LPN_GRP.GK_INV_ASSIGN_DLVY and l_wms_org = 'N')
        )
        THEN
        --{
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
            (
              p_sync_tmp_recTbl   => l_sync_tmp_recTbl,
              x_return_status     => l_return_status,
              p_operation_type    => l_operation_type
            );
            --
            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            --
              x_return_status := l_return_status;
            --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
            --
              return;
            --
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            --
              l_num_warnings := l_num_warnings + 1;
            --
            END IF;
            --
        --}
        END IF;
        --

        FORALL i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last
        UPDATE wsh_delivery_assignments_v
        SET delivery_id = l_del_id_for_container2.delivery_id,
            last_update_date = SYSDATE,
            last_updated_by =  FND_GLOBAL.USER_ID,
            last_update_login =  FND_GLOBAL.LOGIN_ID
        WHERE delivery_detail_id = l_sync_tmp_recTbl.delivery_detail_id_tbl(i);

        -- OTM R12 : assign delivery detail
        IF (l_assign_update AND
            l_gc3_is_installed = 'Y' AND
            nvl(l_del_id_for_container2.ignore_for_planning, 'N') = 'N') THEN

          l_tms_interface_flag := NULL;

          Post_Otm_Assign_Del_Detail
            (p_delivery_id         => l_del_id_for_container2.delivery_id,
             p_delivery_was_empty  => l_delivery_was_empty,
             p_tms_interface_flag  => l_tms_interface_flag,
             p_gross_weight        => l_gross_weight1,  --using the gross weight of container1
             x_return_status       => l_return_status);

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'error from Post_Otm_Assign_Del_Detail');
            END IF;
            raise FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warnings := l_num_warnings + 1;
          END IF;
        END IF;
        -- End of OTM R12 : assign delivery detail


        FOR i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last LOOP
            l_mdc_detail_tab(i) := l_sync_tmp_recTbl.delivery_detail_id_tbl(i);
        END LOOP;
        WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                   p_detail_id_tab     => l_mdc_detail_tab,
                   x_return_status     => x_return_status);
        IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        l_mdc_detail_tab.delete;
        l_sync_tmp_recTbl.delivery_detail_id_tbl.delete;
        l_sync_tmp_recTbl.parent_detail_id_tbl.delete;
        l_sync_tmp_recTbl.delivery_id_tbl.delete;
        l_sync_tmp_recTbl.operation_type_tbl.delete;
    --}
    END IF;
    -- K LPN CONV. rv
    /* H projects: pricing integration csun , adding delivery */
    m := m+1;
    l_del_tab(m) := l_del_id_FOR_container2.delivery_id;
  END IF;


  --
  -- K LPN CONV. rv
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  AND nvl(l_del_id_FOR_container2.line_direction,'O') IN ('O', 'IO')
  AND
  (
   (WSH_WMS_LPN_GRP.GK_WMS_PACK and l_wms_org = 'Y')
   OR
   (WSH_WMS_LPN_GRP.GK_INV_PACK and l_wms_org = 'N')
  )
  THEN
  --{

      l_sync_tmp_rec.delivery_detail_id := p_detail_id1;
      l_sync_tmp_rec.parent_delivery_detail_id := l_del_id_FOR_container1.parent_delivery_detail_id;
      l_sync_tmp_rec.delivery_id := l_del_id_FOR_container1.delivery_id;
      l_sync_tmp_rec.operation_type := 'PRIOR';
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WMS_SYNC_TMP_PKG.MERGE
      (
        p_sync_tmp_rec      => l_sync_tmp_rec,
        x_return_status     => l_return_status
      );
      --
      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        --
        x_return_status := l_return_status;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
        --
      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        --
        l_num_warnings := l_num_warnings + 1;
        --
      END IF;
      --

  --}
  END IF;
  -- K LPN CONV. rv
  --
  UPDATE wsh_delivery_assignments_v
  SET parent_delivery_detail_id = p_detail_id2,
    last_update_date = SYSDATE,
    last_updated_by =  FND_GLOBAL.USER_ID,
    last_update_login =  FND_GLOBAL.LOGIN_ID
  WHERE delivery_detail_id = p_detail_id1;
  l_mdc_detail_tab(1) := p_detail_id1;
  WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                   p_detail_id_tab     => l_mdc_detail_tab,
                   x_return_status     => x_return_status);

  IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

        -- K LPN CONV. rv
        IF NOT( l_wms_org = 'Y' AND nvl(wsh_wms_lpn_grp.g_caller,'WSH') like 'WMS%')
        THEN
        --{
            -- J: W/V Changes
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_WV_UTILS.DD_WV_Post_Process(
              p_delivery_detail_id => p_detail_id1,
              p_diff_gross_wt      => l_del_id_for_container1.gross_weight,
              p_diff_net_wt        => l_del_id_for_container1.net_weight,
              p_diff_volume        => l_del_id_for_container1.volume,
              p_diff_fill_volume   => l_del_id_for_container1.volume,
              x_return_status      => l_return_status);

            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 --
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status);
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                     WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 return;
            END IF;
        --}
        END IF;
        -- K LPN CONV. rv


/*
  -- bug 1336858 fix: don't allow the user to pack a container in itself
  -- or create a loop of containers packed inside each other.
  -- We need to check if this assignment now creates a loop
  declare
    i NUMBER := 0;
  begin

    select container_name into detail_cont_name
    from wsh_delivery_details where delivery_detail_id = p_detail_id1;
    if SQL%NOTFOUND then
    detail_cont_name := '(' || p_detail_id1 || ')';
    end if;

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'detail_cont_name',
                                                       detail_cont_name);
          END IF;

    select container_name into parent_cont_name
    from wsh_delivery_details where delivery_detail_id = p_detail_id2;
    if SQL%NOTFOUND then
    detail_cont_name := '(' || p_detail_id2 || ')';
    end if;
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'parent_cont_name',
                                                       parent_cont_name);
          END IF;

    for c IN check_loop(p_detail_id1) loop
    i := i + 1; -- do nothing...
    end loop;

    exception
    WHEN others THEN
    rollback to before_cont_assignment;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.SET_name('WSH', 'WSH_CONT_LOOP_NO_PACK');
    fnd_message.set_token('DETAIL_CONTAINER', detail_cont_name);
    fnd_message.set_token('PARENT_CONTAINER', parent_cont_name);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected Error has occured. Oracle Err Mesg is'||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION1 : OTHERS');
    END IF;
    --
    return;
  end;
  -- end of check for assignment loop
*/

  IF l_del_tab.count > 0 THEN
    /*  H integration: Pricing integration csun
      when plan a delivery
    */
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
                    WSH_DEBUG_SV.log(l_module_name,'Count of l_del_tab',l_del_tab.count);
    END IF;
    --
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
    END IF;
  END IF;

  -- LPN CONV. rv
  IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
  ELSE
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
  END IF;
  -- LPN CONV. rv


--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  exception

    -- OTM R12 : assign delivery detail
    WHEN FND_API.G_EXC_ERROR then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    -- End of OTM R12 : assign delivery detail

    WHEN  mark_reprice_error THEN
      FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      x_return_status := l_return_status;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
      END IF;
      --
    WHEN others THEN
      if c_del_id_for_cont_or_detail%ISOPEN THEN
        close c_del_id_for_cont_or_detail;
      end if;
      if c_del_id_for_cont_or_detail%ISOPEN THEN
        close c_del_id_for_cont_or_detail;
      end if;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_CONT_TO_CONT',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Assign_Cont_To_Cont;

-- THIS API IS OBSOLETED.
--
--Procedure:      Unassign_Cont_From_Cont
--Parameters:      p_detail_id,
--            x_return_status
--Desription:     Unassign a container FROM another container
--             the assumption here IS that you are take the container
--              out of the immediate parent container ;
--              only need to null out the parent_detail_id.
--              if containers are assigned to any delivery, the assignment
--              will remain

PROCEDURE Unassign_Cont_FROM_Cont(
  p_detail_id   IN NUMBER,
  x_return_status  OUT NOCOPY  VARCHAR2)
IS

l_del_rec               C_DEL_ID_FOR_CONT_OR_DETAIL%ROWTYPE;
l_return_status         VARCHAR2(1);
-- J: W/V Changes
l_param_info   WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_cont_fill_pc NUMBER;
e_abort        exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_CONT_FROM_CONT';
--
BEGIN

  --
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  --
  --
END Unassign_Cont_from_Cont;




--
--Procedure:      Unassign_detail_from_Delivery
--Parameters:      p_detail_id,
--            x_return_status
--Desription:     Unassigns a detail from a delivery

PROCEDURE Unassign_Detail_from_Delivery(
  p_detail_id        IN NUMBER
, x_return_status     OUT NOCOPY  VARCHAR2
, p_validate_flag    IN VARCHAR2,
 p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type   -- J-IB-NPARIKH
)

IS
detail_not_assigned exception;
check_ship_SET_failed exception;
check_smc_failed exception;
del_not_updatable exception;
l_cost_count number;
l_return_status varchar2(30);
l_shp_SET BOOLEAN;
l_smc BOOLEAN;
l_packed number;
l_dummy_record number;
--added for Bug 2209035
CURSOR c_delivery1(p_del_id number)
IS
SELECT status_code, planned_flag,name,
        nvl(shipment_direction,'O') shipment_direction,   -- J-IB-NPARIKH
        ignore_for_planning -- OTM R12 : unassign delivery detail
FROM wsh_new_deliveries
WHERE delivery_id = p_del_id;

l_del1 c_delivery1%ROWTYPE;

l_shipping_param_info   WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
get_shipping_param_err  EXCEPTION;
adjust_parent_wv_err    EXCEPTION;

CURSOR c_assign_rec
IS
SELECT wda.delivery_id, wda.parent_delivery_detail_id,
       wdd.organization_id,
       wdd.weight_uom_code,
       wdd.volume_uom_code,
       wdd.inventory_item_id
FROM   wsh_delivery_assignments_v wda,
       wsh_delivery_details  wdd
WHERE  wda.delivery_detail_id = p_detail_id
and    wdd.delivery_detail_id = wda.delivery_detail_id
and   ((wda.delivery_id IS not null) or (wda.parent_delivery_detail_id IS not null));

l_assign c_assign_rec%ROWTYPE;
l_mdc_detail_tab wsh_util_core.id_tab_type;
/** We just need a Warning when ever we Unassign a Detail from a Delivery and
  if that Detail is part of a Ship Set */
l_delivery_detail_id NUMBER;
invalid_detail exception;
-- Update Cartonization if released warehouse and WMS org.

update_mol_carton_group_error exception;

cursor get_mo_line_id (p_del_det_id IN NUMBER) is
select move_order_line_id, organization_id
from wsh_delivery_details
where delivery_detail_id = p_del_det_id
and released_status = 'S';

cursor c_grouping_id is
select wsh_delivery_group_s.nextval from dual;

l_msg_count      NUMBER;
l_msg_data       VARCHAR2(4000);
l_det_org NUMBER;
l_mo_line_id NUMBER;
l_carton_grouping_id NUMBER;

CURSOR c_all_details_below IS
SELECT  delivery_detail_id,
        parent_delivery_detail_id, -- LPN CONV. rv
        delivery_id  -- LPN CONV. rv
FROM  wsh_delivery_assignments_v
START WITH  delivery_detail_id = p_detail_id
CONNECT BY  prior delivery_detail_id = parent_delivery_detail_id;

-- J: W/V Changes
l_detail_status         VARCHAR2(1);
l_gross_wt              NUMBER;
l_net_wt                NUMBER;
l_vol                   NUMBER;
l_container_flag        VARCHAR2(1);
l_delivery_id           NUMBER;

l_dd_id     WSH_UTIL_CORE.Id_Tab_Type;
l_del_id_tbl           WSH_UTIL_CORE.Id_Tab_Type; -- LPN CONV. rv
l_parent_dd_id_tbl     WSH_UTIL_CORE.Id_Tab_Type; -- LPN CONV. rv
l_line_dir_tbl         WSH_GLBL_VAR_STRCT_GRP.v3_Tbl_Type; -- LPN CONV. rv
l_cnt_flag_tbl         WSH_GLBL_VAR_STRCT_GRP.v3_Tbl_Type; -- LPN CONV. rv
l_det_org_id_tbl       WSH_UTIL_CORE.Id_Tab_Type; -- LPN CONV. rv
i        BINARY_INTEGER := 0;
j        BINARY_INTEGER :=0;

l_dummy_del_det_id NUMBER;
l_del_det_id NUMBER;

l_del_tab      WSH_UTIL_CORE.Id_Tab_Type;
l_status                WSH_LOOKUPS.meaning%TYPE;

CURSOR get_lookup (l_code VARCHAR2) IS
  SELECT meaning
  FROM wsh_lookups
  WHERE lookup_type = 'DELIVERY_STATUS'
  AND lookup_code = l_code;


mark_reprice_error         EXCEPTION;
remove_FC_error            EXCEPTION;
l_detail_is_empty_cont VARCHAR2(1);

l_ib_upd_flag              VARCHAR2(1);
l_rel_status              VARCHAR2(32767);

l_null_delivery_id        NUMBER; -- Bugfix 3768823

l_detail_tab              WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                  VARCHAR2(1); -- Return Status from DBI API

-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_loop_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_line_dir VARCHAR2(10);
l_num_warnings NUMBER := 0;

cursor l_parent_cnt_csr (p_cnt_inst_id IN NUMBER) is
select organization_id,
       nvl(line_direction,'O')
from wsh_delivery_details
where delivery_detail_id = p_cnt_inst_id
and container_flag = 'Y'
and source_code = 'WSH';

l_parent_cnt_orgn_id NUMBER;
l_parent_cnt_line_dir VARCHAR2(10);
-- K LPN CONV. rv
--

-- OTM R12 : unassign delivery detail
l_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_delivery_id_tab     WSH_UTIL_CORE.ID_TAB_TYPE;
l_is_delivery_empty   VARCHAR2(1);
l_gc3_is_installed    VARCHAR2(1);
l_call_update         VARCHAR2(1);
l_gross_weight        WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE;
l_gross_weight_tbl    WSH_UTIL_CORE.ID_TAB_TYPE;
-- End of OTM R12 : unassign delivery detail

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_DETAIL_FROM_DELIVERY';
--
BEGIN

/*changing as per discussion with PM -- if detail is in a container, unassign from container as well. if detail itself is a container, unassign all children from delivery as well*/

  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'p_action_prms.caller',p_action_prms.caller);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- End of OTM R12

  SAVEPOINT before_unassign;

  OPEN c_assign_rec;
  FETCH c_assign_rec into l_assign;
  IF ((c_assign_rec%NOTFOUND) OR (l_assign.delivery_id IS null)) THEN
    CLOSE c_assign_rec;
    RAISE DETAIL_NOT_ASSIGNED ;

  END IF;
  CLOSE c_assign_rec;



  OPEN c_delivery1(l_assign.delivery_id);
  FETCH c_delivery1 into l_del1;
  CLOSE c_delivery1;

    open g_get_detail_info(p_detail_id);
    fetch g_get_detail_info into l_detail_status,l_gross_wt, l_net_wt, l_vol, l_container_flag, l_delivery_id;
    close  g_get_detail_info;

				--
				-- Unassign lines is allowed during ASN/Receipt integration
				-- even though lines are shipped, so bypassing checks for those callers.
				--
    IF l_detail_status = 'C'
        AND NVL(p_action_prms.caller,'!!!!') NOT LIKE '%' || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX   -- J-IB-NPARIKH
        AND NVL(p_action_prms.caller,'!!!!') NOT LIKE WSH_UTIL_CORE.C_IB_ASN_PREFIX || '%'   -- J-IB-NPARIKH
        AND NVL(p_action_prms.caller,'!!!!') NOT LIKE WSH_UTIL_CORE.C_IB_RECEIPT_PREFIX || '%'   -- J-IB-NPARIKH
        THEN
     Raise invalid_detail;
    END IF;


        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_detail_status',
                                      l_detail_status);
            WSH_DEBUG_SV.log(l_module_name,'l_del1.status_code',
                                      l_del1.status_code);
            WSH_DEBUG_SV.log(l_module_name,'l_del1.planned_flag',
                                      l_del1.planned_flag);
            WSH_DEBUG_SV.log(l_module_name,'l_del1.name',
                                      l_del1.name);
            WSH_DEBUG_SV.log(l_module_name,'l_del1.ignore_for_planning',
                                      l_del1.ignore_for_planning);
            WSH_DEBUG_SV.log(l_module_name,'l_assign.delivery_id',
                                                    l_assign.delivery_id);
            WSH_DEBUG_SV.log(l_module_name,'_assign.parent_delivery_detail_id',
                                            l_assign.parent_delivery_detail_id);

         END IF;

  /* security rule: delivery status has to be open and not planned */
  /* Error */
				--
				-- Unassign lines is allowed during ASN/Receipt integration
				-- even though deliveries are shipped/planned, so bypassing checks
				-- for those callers.
				--
  IF (NVL(p_validate_flag, 'Y') = 'Y') THEN
    IF ((l_del1.status_code = 'CL') or
    (l_del1.status_code = 'IT') or
    (l_del1.status_code = 'CO') or
    (l_del1.status_code = 'SC') or  --sperera 940/945
    (l_del1.status_code = 'SR') or
    (l_del1.planned_flag IN ('Y','F') AND l_detail_status <> 'D')) /*Bug7025876 added AND condition*/
    --Bug 3543772   AND NVL(p_action_prms.caller,'!!!!') NOT LIKE '%' || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX   -- J-IB-NPARIKH
                AND NVL(p_action_prms.caller,'!!!!') NOT LIKE WSH_UTIL_CORE.C_IB_ASN_PREFIX || '%'   -- J-IB-NPARIKH
                AND NVL(p_action_prms.caller,'!!!!') NOT LIKE WSH_UTIL_CORE.C_IB_RECEIPT_PREFIX || '%'   -- J-IB-NPARIKH
                THEN
                          IF l_del1.planned_flag IN ('Y','F') THEN
                            fnd_message.SET_name('WSH', 'WSH_DET_UNASSIGN_FIRMDEL');
                            FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del1.name);
                          ELSE
                           OPEN get_lookup(l_del1.status_code);
                              FETCH get_lookup INTO l_status;
                           CLOSE get_lookup;
                           fnd_message.SET_name('WSH',
                                      'WSH_DET_DEL_NOT_UPDATABLE');
                           FND_MESSAGE.SET_TOKEN('STATUS',l_status);
                        END IF;
      RAISE DEL_NOT_UPDATABLE;
    END IF;

  END IF; -- validate flag IS Y

        IF l_container_flag = 'Y' THEN --{ --bug 5100229
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.Is_Empty',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           WSH_CONTAINER_UTILITIES.Is_Empty (p_container_instance_id => p_detail_id,
                                             x_empty_flag => l_detail_is_empty_cont,
                                             x_return_status => l_return_status);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              Raise invalid_detail;
           END IF;
        ELSE --}{
           l_detail_is_empty_cont := 'E';
        END IF; --}

  /* H projects: pricing integration csun */
  l_del_tab.delete;
  l_del_tab(1) := l_assign.delivery_id;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
    p_entity_type => 'DELIVERY',
    p_entity_ids   => l_del_tab,
    x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       RAISE mark_reprice_error;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS  THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'Mark_Reprice_Required completed with warnings.');
                      END IF;

       END IF;
    END IF;


        -- J: W/V Changes
        -- Decrement the parent W/V by DD W/V
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
        WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id => p_detail_id,
          p_diff_gross_wt      => -1 * l_gross_wt,
          p_diff_net_wt        => -1 * l_net_wt,
          p_diff_volume        => -1 * l_vol,
          p_diff_fill_volume   => -1 * l_vol,
          p_check_for_empty    => 'Y',
          x_return_status      => l_return_status);

       IF (l_return_status IN  (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
             --
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             WSH_UTIL_CORE.Add_Message(x_return_status);
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             return;
        END IF;

  -- OTM R12 : unassign delivery detail
  -- l_gross_weight <> 0 means that any of the unassigned detail has
  -- gross_weight <> 0, which will be used later
  IF (l_gc3_is_installed = 'Y' AND
      NVL(l_del1.ignore_for_planning, 'N') = 'N') THEN
    l_gross_weight := 0;
  END IF;
  -- End of OTM R12 : unassign delivery detail

  --loop thru each lower detail and unassign from del
  OPEN c_all_details_below;
  --for locking all details
  LOOP
    -- OTM R12 : unassign delivery detail, legacy issue
    --           l_del_id_tbl and l_parent_dd_id_tbl need to be switched
    FETCH c_all_details_below into l_dd_id(i), l_parent_dd_id_tbl(i), l_del_id_tbl(i);
    EXIT WHEN c_all_details_below%notfound;
    SELECT delivery_detail_id, nvl(line_direction, 'O'), container_flag,
           organization_id,
           gross_weight          -- OTM R12 : unassign delivery detail
      INTO l_dummy_del_det_id, l_line_dir_tbl(i), l_cnt_flag_tbl(i),
           l_det_org_id_tbl(i),
           l_gross_weight_tbl(i) -- OTM R12 : unassign delivery detail
    FROM wsh_delivery_details
    WHERE delivery_detail_id=l_dd_id(i)
    FOR UPDATE NOWAIT;

    -- OTM R12 : unassign delivery detail
    IF (l_gc3_is_installed = 'Y' AND
        NVL(l_del1.ignore_for_planning, 'N') = 'N' AND
        l_gross_weight = 0) THEN
      l_gross_weight := l_gross_weight + NVL(l_gross_weight_tbl(i),0);
    END IF;
    -- End of OTM R12 : unassign delivery detail

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_dd_id',l_dd_id(i));
      -- OTM R12 : unassign delivery detail
      WSH_DEBUG_SV.log(l_module_name,'l_del_id',l_del_id_tbl(i));
      WSH_DEBUG_SV.log(l_module_name,'l_gross_weight',l_gross_weight_tbl(i));
      -- End of OTM R12 : unassign delivery detail
    END IF;
    i := i+1;
  END LOOP;
  CLOSE c_all_details_below;

  l_null_delivery_id := null; --bugfix 3768823
  FOR j IN 0..(l_dd_id.COUNT-1) LOOP
    --
    -- K LPN CONV. rv
    --
    l_loop_wms_org := wsh_util_validate.check_wms_org(l_det_org_id_tbl(j));
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    AND l_line_dir_tbl(j) IN ('O', 'IO')
    AND l_cnt_flag_tbl(j) = 'Y'
    AND
    (
      (WSH_WMS_LPN_GRP.GK_WMS_UNASSIGN_DLVY and l_loop_wms_org = 'Y')
      OR
      (WSH_WMS_LPN_GRP.GK_INV_UNASSIGN_DLVY and l_loop_wms_org = 'N')
    )
    THEN
    --{
        l_sync_tmp_rec.delivery_detail_id := l_dd_id(j);
        l_sync_tmp_rec.parent_delivery_detail_id := l_parent_dd_id_tbl(j);
        l_sync_tmp_rec.delivery_id := l_del_id_tbl(j);
        l_sync_tmp_rec.operation_type := 'PRIOR';
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_WMS_SYNC_TMP_PKG.MERGE
        (
          p_sync_tmp_rec      => l_sync_tmp_rec,
          x_return_status     => l_return_status
        );
        --
        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          --
          x_return_status := l_return_status;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          return;
          --
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          --
          l_num_warnings := l_num_warnings + 1;
          --
        END IF;
        --
    --}
    END IF;
    -- K LPN CONV. rv
    --
    UPDATE wsh_delivery_assignments_v
       SET delivery_id = l_null_delivery_id, --bugfix 3768823
           last_update_date = SYSDATE,
           last_updated_by =  FND_GLOBAL.USER_ID,
           last_update_login =  FND_GLOBAL.LOGIN_ID
     WHERE delivery_detail_id = l_dd_id(j);

     -- bug 6700792: OTM Dock Door Appt Sched Proj
     --Upadating the loading sequence of the delivery detail to NULL while unassigning from delivery
     UPDATE wsh_delivery_details
     SET    load_seq_number = NULL,
            last_update_date = SYSDATE,
            last_updated_by =  FND_GLOBAL.USER_ID,
            last_update_login =  FND_GLOBAL.LOGIN_ID
     WHERE  delivery_detail_id = l_dd_id(j);

    IF (SQL%NOTFOUND) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      RAISE NO_DATA_FOUND;
    END IF;

    l_mdc_detail_tab(1) := l_dd_id(j);
    WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                       p_detail_id_tab     => l_mdc_detail_tab,
                       x_return_status => x_return_status);

    IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Updating for detail id',l_dd_id(j));
           END IF;


           -- J-IB-NPARIKH-{
           IF l_del1.shipment_Direction NOT IN ('O','IO')
           AND NVL(p_action_prms.caller,'!!!!') NOT LIKE '%' || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX
           THEN
                l_ib_upd_flag := 'Y';
           ELSE
                l_ib_upd_flag := 'N';
           END IF;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_ib_upd_flag',l_ib_upd_flag);
           END IF;
           --
           -- J-IB-NPARIKH-}



           IF l_detail_is_empty_cont ='Y' THEN
             --
             -- K LPN CONV. rv
             IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
             AND l_line_dir_tbl(j) IN ('O', 'IO')
             AND
             (
               (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_loop_wms_org = 'Y')
               OR
               (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_loop_wms_org = 'N')
             )
             THEN
             --{
                 l_sync_tmp_rec.delivery_detail_id := l_dd_id(j);
                 l_sync_tmp_rec.operation_type := 'UPDATE';
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_WMS_SYNC_TMP_PKG.MERGE
                 (
                   p_sync_tmp_rec      => l_sync_tmp_rec,
                   x_return_status     => l_return_status
                 );
                 --
                 IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                   --
                   x_return_status := l_return_status;
                   --
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
                     WSH_DEBUG_SV.pop(l_module_name);
                   END IF;
                   --
                   return;
                   --
                 ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                   --
                   l_num_warnings := l_num_warnings + 1;
                   --
                 END IF;
                 --
             --}
             END IF;
             -- K LPN CONV. rv
             --
             UPDATE wsh_delivery_details
             SET customer_id =  NULL,
                 ship_to_location_id = NULL,
                 intmed_ship_to_location_id = NULL,
                 fob_code = NULL,
                 freight_terms_code = NULL,
                 ship_method_code = NULL,
                 mode_of_transport = NULL,
                 service_level = NULL,
                 carrier_id = NULL,
                 deliver_to_location_id = NULL,
                 -- tracking_number = NULL, Bug# 3632485
                 line_direction = DECODE(line_direction,'IO','O',line_direction),   -- J-IB-NPARIKH
                 last_update_date = SYSDATE,
                 last_updated_by =  FND_GLOBAL.USER_ID,
                 last_update_login =  FND_GLOBAL.LOGIN_ID
             WHERE  delivery_detail_id = l_dd_id(j);
             IF (SQL%NOTFOUND) THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               RAISE NO_DATA_FOUND;
             END IF;
             --

           END IF;
           IF l_ib_upd_flag ='Y' THEN
             UPDATE wsh_delivery_details
             SET  ship_from_location_id  = -1,   -- J-IB-NPARIKH
               routing_req_id         = NULL,   -- J-IB-NPARIKH
               rcv_shipment_line_id   = NULL,   -- J-IB-NPARIKH
               shipped_quantity       = NULL,   -- J-IB-NPARIKH
               shipped_quantity2      = NULL,   -- J-IB-NPARIKH
               picked_quantity        = NULL,   -- J-IB-NPARIKH
               picked_quantity2       = NULL,   -- J-IB-NPARIKH
               received_quantity      = NULL,   -- J-IB-NPARIKH
               received_quantity2     = NULL,   -- J-IB-NPARIKH
               returned_quantity      = NULL,   -- J-IB-NPARIKH
               returned_quantity2     = NULL,   -- J-IB-NPARIKH
               earliest_pickup_date   = NULL,   -- J-IB-NPARIKH
               latest_pickup_date     = NULL,   -- J-IB-NPARIKH
               released_status        = DECODE(nvl(requested_quantity,0),0,
                                               'D',
                                               'X'),   -- J-IB-NPARIKH
               ignore_for_planning    = 'Y',   -- J-IB-NPARIKH
               --wv_frozen_flag    = DECODE(l_ib_upd_flag,'Y','N',wv_frozen_flag),   -- J-IB-NPARIKH
               last_update_date = SYSDATE,
               last_updated_by =  FND_GLOBAL.USER_ID,
               last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE  delivery_detail_id = l_dd_id(j)
            returning released_status into l_rel_status;
	    --bugfix 4530813
            IF (SQL%NOTFOUND) THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              RAISE NO_DATA_FOUND;
            END IF;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Rel Status after the update is ', l_rel_status);
            END IF;

               -- released_status        = DECODE(released_status,'D','D',
               --                                 nvl(shipped_quantity,picked_quantity,requested_quantity),0,'D',
               --                                 decode(p_action_prms.caller,'WSH_IB_RROQ',0,-1),requested_quantity,'D',
               --                                 'X'),   -- J-IB-NPARIKH
             -- DBI API needs to be called for update in released_status/requested_qty
             -- So cannot call for l_dd_id completely, since selected few of those are
             -- getting processed here.So keep the ids in a local table and call DBI API
             -- after the loop for l_dd_id table.
             l_detail_tab(l_detail_tab.count + 1) := l_dd_id(j);
           END IF;


           -- Update Cartonization id
           OPEN get_mo_line_id(l_dd_id(j));
           FETCH get_mo_line_id INTO l_mo_line_id, l_det_org;
           CLOSE get_mo_line_id;

           IF l_mo_line_id IS NOT NULL AND
              (WSH_USA_INV_PVT.is_mo_type_putaway(p_move_order_line_id => l_mo_line_id)='N') AND --X-dock
              (WSH_UTIL_VALIDATE.Check_Wms_Org(l_det_org)='Y')
           THEN

              OPEN c_grouping_id;
              FETCH c_grouping_id into l_carton_grouping_id;
              CLOSE c_grouping_id;

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.update_mol_carton_group',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              INV_MO_Cancel_PVT.update_mol_carton_group(
                                 x_return_status => x_return_status,
                                 x_msg_cnt  => l_msg_count,
                                 x_msg_data => l_msg_data,
                                 p_line_id  => l_mo_line_id,
                                 p_carton_grouping_id => l_carton_grouping_id);

              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
              THEN

                 RAISE update_mol_carton_group_error;

              END IF;


           END IF; -- IF (l_mo_line_id IS NOT NULL)...



  END LOOP;

  -- OTM R12 : unassign delivery detail
  --           executed only once after the loop assuming that all the
  --           delivery details fetched from cursor c_all_details_below belong
  --           to the same delivery
  IF (l_gc3_is_installed = 'Y' AND
      nvl(l_del1.ignore_for_planning, 'N') = 'N') THEN

    l_call_update := 'Y';
    l_delivery_id_tab(1) := l_assign.delivery_id;
    l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_assign.delivery_id);

    IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
      --handle the error approriately to the procedure this code is in
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_is_delivery_empty = 'Y') THEN
      l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED;
    ELSIF (l_is_delivery_empty = 'N') THEN
     l_interface_flag_tab(1) := NULL;
    --Bug7608629
    --removed code which checked for gross weight
    --now irrespective of gross weight  UPDATE_TMS_INTERFACE_FLAG will be called
    END IF;

    IF l_call_update = 'Y' THEN
      WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
              p_delivery_id_tab        => l_delivery_id_tab,
              p_tms_interface_flag_tab => l_interface_flag_tab,
              x_return_status          => l_return_status);

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG '||l_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;
    END IF;
  END IF;
  -- End of OTM R12 : unassign delivery detail

  -- Call DBI api after the loop
  -- DBI Project
  -- Update of wsh_delivery_details,  call DBI API after the action.
  -- This API will also check for DBI Installed or not
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail count-',l_detail_tab.count);
  END IF;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_detail_tab,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    x_return_status := l_dbi_rs;
    -- just pass this return status to caller API
    ROLLBACK TO before_unassign;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'DBI API call failed',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DBI API FAILED');
      END IF;
    RETURN;
  END IF;
  -- End of Code for DBI Project
  --

  --also unassign from container
  IF (l_assign.parent_delivery_detail_id IS NOT null) THEN
           -- K LPN CONV. rv
           --
           open l_parent_cnt_csr(l_assign.parent_delivery_detail_id);
           fetch l_parent_cnt_csr into l_parent_cnt_orgn_id, l_parent_cnt_line_dir;
           close l_parent_cnt_csr;
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' parent cnt orgn id is', l_parent_cnt_orgn_id);
             WSH_DEBUG_SV.log(l_module_name,' parent cnt line dir is', l_parent_cnt_line_dir);
           END IF;
           --
           l_wms_org := wsh_util_validate.check_wms_org(l_parent_cnt_orgn_id);
           --
           -- K LPN CONV. rv
           --
           IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
           AND nvl(l_parent_cnt_line_dir,'O') IN ('O', 'IO')
           AND
           (
             (WSH_WMS_LPN_GRP.GK_WMS_UNPACK and l_wms_org = 'Y')
             OR
             (WSH_WMS_LPN_GRP.GK_INV_UNPACK and l_wms_org = 'N')
           )
           THEN
           --{
               l_sync_tmp_rec.delivery_detail_id := p_detail_id;
               l_sync_tmp_rec.parent_delivery_detail_id := l_assign.parent_delivery_detail_id;
               l_sync_tmp_rec.delivery_id := l_assign.delivery_id;
               l_sync_tmp_rec.operation_type := 'PRIOR';
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               WSH_WMS_SYNC_TMP_PKG.MERGE
               (
                 p_sync_tmp_rec      => l_sync_tmp_rec,
                 x_return_status     => l_return_status
               );
               --
               IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                 --
                 x_return_status := l_return_status;
                 --
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
                   WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 return;
                 --
               ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                 --
                 l_num_warnings := l_num_warnings + 1;
                 --
               END IF;
               --
           --}
           END IF;
           -- K LPN CONV. rv
           --
           UPDATE wsh_delivery_assignments_v
           SET  parent_delivery_detail_id=NULL
           WHERE  delivery_detail_id = p_detail_id;

           --OTM Dock Door Appt Sched Proj
           --Upadating the loading sequence of the delivery detail to NULL while unassigning from delivery
           UPDATE wsh_delivery_details
           SET    load_seq_number = NULL,
                  last_update_date = SYSDATE,
                  last_updated_by =  FND_GLOBAL.USER_ID,
                  last_update_login =  FND_GLOBAL.LOGIN_ID
           WHERE  delivery_detail_id = p_detail_id;

	   IF (SQL%NOTFOUND) THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              RAISE NO_DATA_FOUND;
           END IF;

           l_mdc_detail_tab(1) := p_detail_id;
           WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                      p_detail_id_tab => l_mdc_detail_tab,
                      x_return_status => x_return_status);

           IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
               WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             return;
           END IF;

           WSH_SHIPPING_PARAMS_PVT.Get(
             p_organization_id     => l_assign.organization_id,
	     x_param_info          => l_shipping_param_info,
             x_return_status       => l_return_status);


           IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
	   THEN
              IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||l_return_status);
              END IF;
              RAISE get_shipping_param_err;
           END IF;


           IF l_shipping_param_info.PERCENT_FILL_BASIS_FLAG = 'Q' THEN

             WSH_WV_UTILS.ADJUST_PARENT_WV(
              p_entity_type   => 'CONTAINER',
              p_entity_id     => l_assign.parent_delivery_detail_id,
              p_gross_weight  => 0,
              p_net_weight    => 0,
              p_volume        => 0,
              p_filled_volume => 0,
              p_wt_uom_code   => l_assign.weight_uom_code,
              p_vol_uom_code  => l_assign.volume_uom_code,
              p_inv_item_id   => l_assign.inventory_item_id,
              x_return_status => l_return_status);

            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
 	       THEN
               IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WV_UTILS.ADJUST_PARENT_WV returned '||l_return_status);
               END IF;
               RAISE adjust_parent_wv_err;
            END IF;


           END IF;

  END IF;

   /* Bug 2769639, remove FTE generated FC for the delivery detail and all the delivery details below it */

   IF WSH_UTIL_CORE.FTE_Is_Installed = 'Y'  AND l_dd_id.count > 0
   AND NVL(p_action_prms.caller,'!!!!') NOT LIKE '%' || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX
   THEN
      WSH_FREIGHT_COSTS_PVT.Remove_FTE_Freight_Costs(
         p_delivery_details_tab => l_dd_id,
         x_return_status => l_return_status) ;
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
         l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         raise remove_FC_error;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         END IF;
      END IF;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Remove_FTE_Freight_Costs completed returns with status: ' ||
                          l_return_status);
      END IF;

      NULL;
   END IF;

   -- LPN CONV. rv
   IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     --
   ELSE
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     --
   END IF;
   -- LPN CONV. rv



--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
          WHEN mark_reprice_error  THEN
            x_return_status := l_return_status;
                  FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
        ROLLBACK TO before_unassign;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
        END IF;
        --
    WHEN detail_not_assigned THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.set_name('WSH', 'WSH_DET_DETAIL_NOT_ASSIGNED');
      wsh_util_core.add_message(x_return_status,l_module_name);
      ROLLBACK TO before_unassign;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'DETAIL_NOT_ASSIGNED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DETAIL_NOT_ASSIGNED');
      END IF;
      --
    WHEN del_not_updatable THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
      ROLLBACK TO before_unassign;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'DEL_NOT_UPDATABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DEL_NOT_UPDATABLE');
      END IF;
      --
                WHEN update_mol_carton_group_error THEN
      fnd_message.SET_name('WSH', 'WSH_MOL_CARTON_GROUP_ERROR');
                        x_return_status := l_return_status;
                        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

                      --
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'update_mol_carton_group_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:update_mol_carton_group_error');
                      END IF;

    WHEN check_ship_set_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SHIP_SET_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CHECK_SHIP_SET_FAILED');
END IF;
--
    WHEN check_smc_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SMC_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CHECK_SMC_FAILED');
      END IF;
      --
    WHEN remove_FC_error  THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Remove_FTE_Freight_Costs failed.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REMOVE_FC_ERROR');
      END IF;
      --
       FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      ROLLBACK TO before_unassign;

    WHEN get_shipping_param_err THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
      FND_MESSAGE.Set_Token('ORGANIZATION_CODE',
                        wsh_util_core.get_org_name(l_assign.organization_id));
      wsh_util_core.add_message(x_return_status,l_module_name);
      ROLLBACK TO before_unassign;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Failed to get Shipping Parameters',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GET_SHIPPING_PARAM_ERR');
      END IF;

    WHEN adjust_parent_wv_err THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WT_VOL_FAILED');
      FND_MESSAGE.SET_TOKEN('CONT_NAME',WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_assign.parent_delivery_detail_id));
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

      ROLLBACK TO before_unassign;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Failed to adjust the weight and volume of parent container '||to_char(l_assign.parent_delivery_detail_id),WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ADJUST_PARENT_WV_ERR');
      END IF;

    WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_DELIVERY',l_module_name);
      ROLLBACK TO before_unassign;


--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unassign_Detail_FROM_Delivery;


-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Unassign_Detail_from_Delivery(
  p_detail_id                IN NUMBER
, x_return_status         OUT NOCOPY  VARCHAR2
, p_validate_flag        IN VARCHAR2)

IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_DETAIL_FROM_DELIVERY';
--
l_action_prms   WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;  -- J-IB-NPARIKH
BEGIN

/*changing as per discussion with PM -- if detail is in a container, unassign from container as well. if detail itself is a container, unassign all children from delivery as well*/

    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
    END IF;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    UNASSIGN_DETAIL_FROM_DELIVERY (p_detail_id,
                                     x_return_status,
                                     p_validate_flag,
                                     l_action_prms);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
        WHEN others THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_DELIVERY',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END Unassign_Detail_FROM_Delivery;




--
--Procedure:      Unassign_multiple_details
--Parameters:      P_REC_OF_DETAIL_IDS
--              P_from_delivery
--              P_from_container
--            x_return_status
--Desription:     Unasigns multiple details FROM a delivery or a container
PROCEDURE Unassign_Multiple_Details(
  P_REC_OF_DETAIL_IDS  IN WSH_UTIL_CORE.ID_TAB_TYPE
, P_FROM_delivery    IN VARCHAR2
, P_FROM_container     IN VARCHAR2
, x_return_status    out NOCOPY  varchar2
, p_validate_flag    IN VARCHAR2
, p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type   -- J-IB-NPARIKH
)
IS

CURSOR c_multi_assign_rec(c_delivery_detail_id number)
IS
SELECT   delivery_id, parent_delivery_detail_id
FROM     wsh_delivery_assignments_v
WHERE delivery_detail_id = c_delivery_Detail_id
AND   ((delivery_id IS not null) or (parent_delivery_detail_id IS not null));
l_multi_assign_rec c_multi_assign_rec%ROWTYPE;

CURSOR c_multi_delivery(c_del_id number)
IS
SELECT *
FROM wsh_new_deliveries
WHERE delivery_id = c_del_id;
l_multi_delivery c_multi_delivery%ROWTYPE;

l_multi_cost_count number;
l_ship_set BOOLEAN;
l_smc_set BOOLEAN;
l_return_status varchar2(30);
check_ship_SET_failed exception;
check_smc_failed  exception;
l_num_errors    NUMBER;
l_num_warnings    NUMBER;
/*Bug 2136603- added variables */
l_gross NUMBER;
l_net NUMBER;
l_volume NUMBER;
l_fill NUMBER;
l_cont_name VARCHAR2(30);
--
l_dlvy_tbl         WSH_UTIL_CORE.key_value_tab_type;   -- J-IB-NPARIKH
l_dlvy_ext_tbl     WSH_UTIL_CORE.key_value_tab_type;   -- J-IB-NPARIKH
l_del_tab          WSH_UTIL_CORE.ID_TAB_TYPE;
l_index            NUMBER;
L_DLVY_FREIGHT_TERMS_CODE  VARCHAR2(30);

Cursor c_empty_delivery ( p_del_id number) --Pick To POD WF : Raise PO Cancellation for empty Inbound delivery
IS
SELECT wnd.delivery_id, wnd.organization_id
FROM wsh_new_deliveries wnd
WHERE wnd.delivery_id = p_del_id and wnd.shipment_direction='I'
and  not exists (  SELECT wda.delivery_id
FROM wsh_delivery_assignments_v  wda
WHERE wda.delivery_id =wnd.delivery_id  );
l_del_id NUMBER;
l_org_id NUMBER;
l_wf_rs VARCHAR2(1);

-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_MULTIPLE_DETAILS';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_DELIVERY',P_FROM_DELIVERY);
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_CONTAINER',P_FROM_CONTAINER);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- initialize summary variables
  l_num_warnings := 0;
  l_num_errors := 0;

  IF (p_from_delivery = 'Y') THEN
     FOR i in p_rec_of_detail_ids.FIRST .. p_rec_of_detail_ids.LAST
    LOOP
      OPEN c_multi_assign_rec(p_rec_of_detail_ids(i));
      FETCH c_multi_assign_rec INTO l_multi_assign_rec;

                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'p_rec_of_detail_ids',
                               p_rec_of_detail_ids(i));
                        END IF;

      IF (c_multi_assign_rec%NOTFOUND) THEN
        l_num_warnings := l_num_warnings + 1;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        fnd_message.SET_name('WSH','WSH_DET_SPEC_DET_NOT_ASSIGNED');
        fnd_message.SET_token('DELIVERY_DETAIL_ID', p_rec_of_detail_ids(i));
        wsh_util_core.add_message(x_return_status,l_module_name);
        /* go ahead and process the next line */
        CLOSE c_multi_assign_rec;
        GOTO start_over_1;
      END IF;
      CLOSE c_multi_assign_rec;

      IF (l_multi_assign_rec.delivery_id IS null) THEN
        l_num_warnings := l_num_warnings + 1;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        fnd_message.SET_name('WSH','WSH_DET_SPEC_DET_NOT_ASSIGNED');
        fnd_message.SET_token('DELIVERY_DETAIL_ID', p_rec_of_detail_ids(i));
        wsh_util_core.add_message(x_return_status,l_module_name);
        /* go ahead and process the next line */
        GOTO start_over_1;
      END IF;

            -- J-IB-NPARIKH-{
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_Cached_value',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            -- Build a cache of uniqye delivery IDs , from which lines are being unassigned
            --
            --
            WSH_UTIL_CORE.get_Cached_value
                (
                    p_cache_tbl         => l_dlvy_tbl,
                    p_cache_ext_tbl     => l_dlvy_ext_tbl,
                    p_key               => l_multi_assign_rec.delivery_id,
                    p_value             => l_multi_assign_rec.delivery_id,
                    p_action            => 'PUT',
                    x_return_status     => l_return_status
                );
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            -- J-IB-NPARIKH-}


      Unassign_detail_from_delivery(
        p_detail_id   =>   p_rec_of_detail_ids(i),
        p_validate_flag   =>  p_validate_flag,
        x_return_status   =>  l_return_status,
                p_action_prms       => p_action_prms   -- J-IB-NPARIKH
        );
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
         l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        l_num_errors := l_num_errors + 1;
      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;


      <<start_over_1>>
      NULL;
    END LOOP;
        --
        --
        -- J-IB-NPARIKH-{
        --
        l_index := l_dlvy_tbl.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{

            IF NVL(p_action_prms.caller,'!!!!') NOT LIKE WSH_UTIL_CORE.C_IB_RECEIPT_PREFIX || '%'   -- J-IB-NPARIKH
            THEN
            --{
		IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.calculate_cont_del_tpdates',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		l_del_tab(1) := l_dlvy_tbl(l_index).value;
		WSH_TP_RELEASE.calculate_cont_del_tpdates(
		  p_entity => 'DLVY',
		  p_entity_ids =>l_del_tab,
		  x_return_status => l_return_status);
		    --}
	      /*CURRENTLY NOT IN USE
	      IF ( p_action_prms.caller = WSH_UTIL_CORE.C_IB_PO_PREFIX  ) -- Added for Pick to POD WF
	      THEN	--PO cancellation unassigns DD from delivery, we check if delivery gets emptied out then we raise a event
			OPEN c_empty_delivery( l_dlvy_tbl(l_index).value )  ;
			Fetch c_empty_delivery into l_del_id, l_org_id;
			If (c_empty_delivery%FOUND )
			THEN
				 --Raise Event: Pick To Pod Workflow
				  WSH_WF_STD.Raise_Event(
							p_entity_type => 'DELIVERY',
							p_entity_id =>  l_del_id,
							p_event => 'oracle.apps.fte.delivery.ib.pocancelled' ,
							p_organization_id =>  l_org_id,
							x_return_status => l_wf_rs ) ;
				 IF l_debug_on THEN
				     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  l_del_id );
				     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
				 END IF;
				--Done Raise Event: Pick To Pod Workflow
			END IF;
			CLOSE c_empty_delivery;
		END IF;
		*/
            END IF;

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_dlvy_tbl(l_index).value',l_dlvy_tbl(l_index).value);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.update_freight_terms',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_NEW_DELIVERY_ACTIONS.update_freight_terms
                (
                    p_delivery_id        => l_dlvy_tbl(l_index).value,
                    p_action_code        => 'UNASSIGN',
                    x_return_status      => l_return_status,
                    x_freight_terms_code => l_dlvy_freight_terms_code
                );
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            l_index := l_dlvy_tbl.NEXT(l_index);
        --}
        END LOOP;
        --
        --
        l_index := l_dlvy_ext_tbl.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            --
            IF NVL(p_action_prms.caller,'!!!!') NOT LIKE WSH_UTIL_CORE.C_IB_RECEIPT_PREFIX || '%'   -- J-IB-NPARIKH
            THEN
            --{

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.calculate_cont_del_tpdates',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            l_del_tab(1) := l_dlvy_ext_tbl(l_index).value;
            WSH_TP_RELEASE.calculate_cont_del_tpdates(
              p_entity => 'DLVY',
              p_entity_ids =>l_del_tab,
              x_return_status => l_return_status);
            --}
		/*IF ( p_action_prms.caller = WSH_UTIL_CORE.C_IB_PO_PREFIX  ) -- Added for Pick to POD WF
		THEN	--PO cancellation unassigns DD from delivery, we check if delivery gets emptied out then we raise a event
			OPEN c_empty_delivery( l_dlvy_ext_tbl(l_index).value )  ;
			Fetch c_empty_delivery into l_del_id, l_org_id;
			If (c_empty_delivery%FOUND )
			THEN
				 --Raise Event: Pick To Pod Workflow
				  WSH_WF_STD.Raise_Event(
							p_entity_type => 'DELIVERY',
							p_entity_id =>  l_del_id,
							p_event => 'oracle.apps.fte.delivery.ib.pocancelled' ,
							p_organization_id =>  l_org_id,
							x_return_status => l_wf_rs ) ;
				 IF l_debug_on THEN
				     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  l_del_id );
				     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
				 END IF;
				--Done Raise Event: Pick To Pod Workflow
			END IF;
			CLOSE c_empty_delivery;
		END IF;*/
            END IF;

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_dlvy_ext_tbl(l_index).value',l_dlvy_ext_tbl(l_index).value);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.update_freight_terms',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_NEW_DELIVERY_ACTIONS.update_freight_terms
                (
                    p_delivery_id        => l_dlvy_ext_tbl(l_index).value,
                    p_action_code        => 'UNASSIGN',
                    x_return_status      => l_return_status,
                    x_freight_terms_code => l_dlvy_freight_terms_code
                );
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            l_index := l_dlvy_ext_tbl.NEXT(l_index);
        --}
        END LOOP;
        --
        -- J-IB-NPARIKH-}

  END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_num_errors', l_num_errors);
            WSH_DEBUG_SV.log(l_module_name,'l_num_warnings', l_num_warnings);
        END IF;

  IF (p_from_container = 'Y') THEN
    FOR i in  p_rec_of_detail_ids.FIRST .. p_rec_of_detail_ids.LAST
    LOOP
      OPEN c_multi_assign_rec(p_rec_of_detail_ids(i));
      FETCH c_multi_assign_rec INTO l_multi_assign_rec;
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'p_rec_of_detail_ids'
                                          ,p_rec_of_detail_ids(i));
                           WSH_DEBUG_SV.log(l_module_name,'l_multi_assign_rec',
                                               l_multi_assign_rec.delivery_id);
                        END IF;
      IF (c_multi_assign_rec%NOTFOUND) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        fnd_message.SET_name('WSH','WSH_DET_SPEC_DET_NOT_ASSIGNED');
        fnd_message.SET_token('DELIVERY_DETAIL_ID', p_rec_of_detail_ids(i));
        wsh_util_core.add_message(x_return_status,l_module_name);
        /* go ahead and process the next line */
         CLOSE c_multi_assign_rec;
        GOTO start_over_2;
      END IF;
      CLOSE c_multi_assign_rec;

/* Bug 2166715 - check if line was actually packed or not */
            IF l_multi_assign_rec.parent_delivery_detail_id IS NULL THEN                      l_num_warnings := l_num_warnings + 1;
              fnd_message.SET_name('WSH','WSH_CONT_UNASSG_NULL');
              wsh_util_core.add_message(x_return_status,l_module_name);
            END IF;

      Unassign_detail_FROM_cont(
        p_detail_id       =>   p_rec_of_detail_ids(i),
        p_validate_flag      => p_validate_flag,
        x_return_status    => l_return_status
        );
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
         l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        l_num_errors := l_num_errors + 1;
      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warnings := l_num_warnings + 1;

      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.calculate_cont_del_tpdates',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      l_del_tab(1) := l_multi_assign_rec.parent_delivery_detail_id;
      WSH_TP_RELEASE.calculate_cont_del_tpdates(
                  p_entity => 'DLVB',
                  p_entity_ids =>l_del_tab,
      x_return_status => l_return_status);

         <<start_over_2>>
        NULL;
    END LOOP;
  END IF;
  --
  -- K LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
        (
          p_in_rec             => l_lpn_in_sync_comm_rec,
          x_return_status      => l_return_status,
          x_out_rec            => l_lpn_out_sync_comm_rec
        );
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
      END IF;
      --
      --
      WSH_UTIL_CORE.API_POST_CALL
        (
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors,
          p_raise_error_flag => false
        );
  --}
  END IF;
  --
  -- K LPN CONV. rv
  --
  --
  IF (l_num_errors >= p_rec_of_detail_ids.COUNT) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF (l_num_warnings > 0 OR l_num_errors>0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_num_warnings',l_num_warnings);
            WSH_DEBUG_SV.log(l_module_name,'l_num_errors',l_num_errors);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  EXCEPTION
        -- J-IB-NPARIKH-{
       WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          --
          IF l_debug_on THEN
             wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
          END IF;
       --
       WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --
         --
         -- K LPN CONV. rv
         --
         IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
         THEN
         --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

             WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
               (
                 p_in_rec             => l_lpn_in_sync_comm_rec,
                 x_return_status      => l_return_status,
                 x_out_rec            => l_lpn_out_sync_comm_rec
               );
             --
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
             END IF;
             --
             --
             --
         --}
         END IF;
         --
         -- K LPN CONV. rv
         --
          IF l_debug_on THEN
             wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
          END IF;
       --

        -- J-IB-NPARIKH-}
    WHEN CHECK_SHIP_SET_FAILED THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SHIP_SET_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CHECK_SHIP_SET_FAILED');
      END IF;
      --
    WHEN check_smc_failed THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SMC_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CHECK_SMC_FAILED');
       END IF;
       --
    WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAIL',l_module_name);
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
--
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unassign_Multiple_Details;

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Unassign_Multiple_Details(
  P_REC_OF_DETAIL_IDS    IN WSH_UTIL_CORE.ID_TAB_TYPE
, P_FROM_delivery        IN VARCHAR2
, P_FROM_container       IN VARCHAR2
, x_return_status        out NOCOPY  varchar2
, p_validate_flag      IN VARCHAR2
)
IS


l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_MULTIPLE_DETAILS';
--
l_action_prms   WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;  -- J-IB-NPARIKH
BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_FROM_DELIVERY',P_FROM_DELIVERY);
        WSH_DEBUG_SV.log(l_module_name,'P_FROM_CONTAINER',P_FROM_CONTAINER);
        WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    UNASSIGN_MULTIPLE_DETAILS
        (
              P_REC_OF_DETAIL_IDS
            , P_FROM_delivery
            , P_FROM_container
            , x_return_status
            , p_validate_flag
            , l_action_prms
        );

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAIL',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
--
END Unassign_Multiple_Details;

--
--Procedure:      Assign_multiple_details
--Parameters:      P_REC_OF_DETAIL_IDS
--            P_delivery_id,
--            P_cont_ins_id,
--            x_return_status
--Desription:     Assings multiple details to a delivery or a container

PROCEDURE Assign_Multiple_Details(
  p_rec_of_detail_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
  p_delivery_id NUMBER,
  P_cont_ins_id number,
  x_return_status OUT NOCOPY  varchar2)
IS
l_rowid varchar2(150);
l_group_status varchar2(30);
l_ship_method_match boolean;
l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_TYPE;
l_cr_assg_status varchar2(30);
l_delivery_assignment_id NUMBER;
del_id number;
cont_id number;


CURSOR c_get_del_from_container(c_container_id number) IS
SELECT delivery_id
FROM wsh_delivery_assignments_v
WHERE delivery_detail_id = c_container_id;

l_num_errors    NUMBER;
l_num_warnings    NUMBER;


l_scc_unassign_from_del NUMBER  := 0;
l_scc_unassign_from_con NUMBER  := 0;
l_delivery_id           NUMBER := 0;
l_del_tab               WSH_UTIL_CORE.Id_Tab_Type;
l_return_status         VARCHAR2(1);
m                       NUMBER := 0;


mark_reprice_error      EXCEPTION;

/* Bug 2276586 */
l_delivery_id1 NUMBER;
delivery_id_locked exception  ;
PRAGMA EXCEPTION_INIT(delivery_id_locked, -54);



l_has_lines               VARCHAR2(1);
l_dlvy_freight_terms_code VARCHAR2(30);
--
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'ASSIGN_MULTIPLE_DETAILS';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_INS_ID',P_CONT_INS_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_del_tab.delete;
  l_num_errors := 0;
  l_num_warnings := 0;

  IF ((p_delivery_id = -9999)  AND (p_cont_ins_id = -9999 )) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  END IF;

-- Bug 2276586
   SELECT delivery_id, freight_Terms_code    -- J-IB-NPARIKH
     INTO l_delivery_id1, l_dlvy_freight_Terms_code
     FROM wsh_new_deliveries
    WHERE delivery_id = p_delivery_id
      FOR UPDATE NOWAIT;

  IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Locking for Delivery id ',l_delivery_id1);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.has_lines',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

    -- J-IB-NPARIKH-{
    --
    -- Determine if delivery has any non-container lines
    --
    l_has_lines := WSH_DELIVERY_VALIDATIONS.has_lines
                        (
                            p_delivery_id => p_delivery_id
                        );
    --
    -- J-IB-NPARIKH-}


    FOR i IN P_REC_OF_DETAIL_IDS.FIRST .. P_REC_OF_DETAIL_IDS.LAST
  LOOP

    IF (p_delivery_id <> -9999) THEN
      /* assigning it to a delivery */
       --
       IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'Delivery id ',p_rec_of_detail_ids(i));

           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_delivery_details_actions.assign_detail_to_delivery(
          p_detail_id => P_REC_OF_DETAIL_IDS(i),
          p_delivery_id => p_delivery_id,
          x_return_status => x_return_status,
          x_dlvy_has_lines          => l_has_lines,   -- J-IB-NPARIKH
          x_dlvy_freight_terms_code => l_dlvy_freight_terms_code   -- J-IB-NPARIKH
                );

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          l_num_errors := l_num_errors + 1;
        ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          l_num_warnings := l_num_warnings + 1;
        END IF;
        goto start_over;
      /* H project : pricing integration csun , need to mark the reprice
                     flag if any of the delivery detail is assigned */
      ELSE
         l_scc_unassign_from_del := l_scc_unassign_from_del + 1;
      END IF;
      END IF;

    IF (p_cont_ins_id <> -9999) THEN
                         -- J: W/V Changes
                         -- replaced the direct update with Assign_Detail_To_Cont API
                         wsh_delivery_details_actions.Assign_Detail_To_Cont(
                           p_detail_id        => P_REC_OF_DETAIL_IDS(i),
                           p_parent_detail_id => p_cont_ins_id,
                           x_return_status    => x_return_status);

       IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          l_num_errors := l_num_errors + 1;
        ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          l_num_warnings := l_num_warnings + 1;
        END IF;
        goto start_over;
       /* H project : pricing integration csun , need to mark the reprice
                     flag if any of the delivery detail is assigned */
       ELSE
                           l_scc_unassign_from_con  :=  l_scc_unassign_from_con + 1;
       END IF;

    END IF;
      <<start_over>>
      NULL;
  END LOOP;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                       'l_scc_unassign_from_del',
                        l_scc_unassign_from_del);
          WSH_DEBUG_SV.log(l_module_name,
                       'l_scc_unassign_from_con',
                        l_scc_unassign_from_con);
        END IF;

  IF (l_num_errors > 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Ret status is error',l_num_errors);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  ELSIF (l_num_warnings > 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;


  /* H projects: pricing integration csun get the delivery id the container is
  assigned to  and mark the delivery */
  IF l_scc_unassign_from_del > 0  THEN
      m := m + 1;
      l_del_tab(m) := p_delivery_id;
  END IF;
  IF l_scc_unassign_from_con > 0 THEN
     OPEN c_get_del_from_container(p_cont_ins_id) ;
     FETCH c_get_del_from_container INTO l_delivery_id;
     CLOSE c_get_del_from_container;
     IF l_delivery_id <> 0 and l_delivery_id IS NOT NULL THEN
        m := m + 1;
        l_del_tab(m) := l_delivery_id;
     END IF;
  END IF;
        IF l_del_tab.count > 0 THEN
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
    END IF;
   END IF;


--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  exception
  WHEN mark_reprice_error THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.SET_name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    wsh_util_core.add_message(x_return_status,l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
END IF;
--
        WHEN delivery_id_locked THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.SET_name('WSH', 'WSH_NO_LOCK');
    wsh_util_core.add_message(x_return_status,l_module_name);
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Id Locked exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION : DELIVERY_ID_LOCKED');
          END IF;
          --
          return;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_ID_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIVERY_ID_LOCKED');
END IF;
--
  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_MULTIPLE_DETAILS',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Assign_Multiple_Details;



/*************************/
/*   CODE FOR AUTO PACKING */
-- This API has been created to be called
-- from Auto Pack Lines
-- Purpose is to split a delivery line as many times
-- as required by just one call , rather than calling
-- Split API multiple times

--
--Procedure:
--Parameters:    p_from_detail_id
--          p_req_quantity
--          p_new_detail_id
--          x_return_status
--Desription:
--        Splits a delivery detail according the new requested
--        quantity. The newly created the detail has the requested
--        quantity as p_req_quantity and the old detail has the
--
-- fabdi start : PICK CONFIRM
--added a new parameter called p_req_quantity2      requested quantity as requested_quantity - p_requested_quantity
-- fabdi end : PICK CONFIRM
-- HW BUG#:1636578 added a new parameter p_converted_flag

/*****************************************************
  SPLIT_DELIVERY_DETAILS_BULK api
*****************************************************/
PROCEDURE Split_Delivery_Details_Bulk (
p_from_detail_id     IN  NUMBER,
p_req_quantity       IN OUT NOCOPY  NUMBER,
p_unassign_flag     IN  VARCHAR2 ,
p_req_quantity2     IN  NUMBER ,
p_converted_flag     IN VARCHAR2,
p_manual_split   IN VARCHAR2 ,
p_num_of_split        IN NUMBER ,       -- for empty container cases
x_new_detail_id      OUT NOCOPY  NUMBER,
x_dd_id_tab      OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
x_return_status     OUT NOCOPY  VARCHAR2
)
IS

l_new_delivery_detail_id number;
-- HW OPMCONV. Removed OPM variables

-- HW OPMCONV - Removed Format of qty2
l_qty2            NUMBER;
l_split_shipped_qty2      NUMBER(19,9):= NULL;
-- HW BUG#:1636578 variable to calculate new qty2
l_new_req_qty2 NUMBER;
l_original_shipped_qty2    NUMBER(19,9):= NULL;


l_new_req_qty   NUMBER;
l_new_pick_qty  NUMBER;

l_new_pick_qty2 NUMBER;

l_delivery_id  number;
l_parent_delivery_detail_id number;
assignment number;
l_delivery_assignment_id number;
detail_rowid VARCHAR2(30);
assignment_rowid VARCHAR2(30);
total number;
l_cr_dt_status varchar2(30);
l_cr_assg_status varchar2(30);
l_output_quantity number;
l_return_status   varchar2(1);
l_qty_return_status varchar2(30);

chk_decimal_qty_failed exception;
quantity_over EXCEPTION;
negative_qty  EXCEPTION;
zero_qty    EXCEPTION;
/*   H integration: Pricing integration csun
   mark reprice required flag when split_delivery_details
 */
l_entity_ids   WSH_UTIL_CORE.id_tab_type;
reprice_required_err   EXCEPTION;
l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
l_delivery_details_info WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_split_weight number;
l_split_volume number;
l_split_return_status varchar2(30);
l_shipped_quantity     NUMBER := NULL;
l_old_stage_qty      NUMBER := NULL;
l_ser_qty          NUMBER := NULL;


l_dd_id_tab     WSH_UTIL_CORE.id_tab_type;
l_num_of_split   NUMBER;

  old_delivery_detail_rec SplitDetailRecType;

l_inv_controls_rec   WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;


-- Bug 2637876
l_original_shipped_qty   NUMBER;
l_split_shipped_qty   NUMBER;
l_serial_tab              WSH_DELIVERY_DETAILS_ACTIONS.serial_tab;
i NUMBER;
j NUMBER;
l_serial_orig_rec WSH_DELIVERY_DETAILS_ACTIONS.SplitDetailRecType;
l_new_serial_rec WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_transaction_id_tab     WSH_UTIL_CORE.id_tab_type;
l_serial_number WSH_DELIVERY_DETAILS.serial_number%TYPE;
TYPE l_sr_no_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
l_serial_number_tab l_sr_no_tab;
l_id1 NUMBER;
l_s1 VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'SPLIT_DELIVERY_DETAILS_BULK';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_DETAIL_ID',P_FROM_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_REQ_QUANTITY',P_REQ_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_UNASSIGN_FLAG',P_UNASSIGN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_REQ_QUANTITY2',P_REQ_QUANTITY2);
      WSH_DEBUG_SV.log(l_module_name,'P_CONVERTED_FLAG',P_CONVERTED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_MANUAL_SPLIT',P_MANUAL_SPLIT);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN c_split_detail_info(p_from_detail_id);
  FETCH c_split_detail_info into old_delivery_detail_rec;
  CLOSE c_split_detail_info;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',
                               old_delivery_detail_rec.delivery_detail_id);
       WSH_DEBUG_SV.log(l_module_name,'picked_quantity',
                               old_delivery_detail_rec.picked_quantity);
       WSH_DEBUG_SV.log(l_module_name,'organization_id',
                               old_delivery_detail_rec.organization_id);
       WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',
                               old_delivery_detail_rec.inventory_item_id);
       WSH_DEBUG_SV.log(l_module_name,'requested_quantity_uom',
                               old_delivery_detail_rec.requested_quantity_uom);
    END IF;

  -- Bug 2419301 : Set oe_interfaced_flag to MISS CHAR so that create_new_detail_from_old API
  --               determines the value of oe_interfaced_flag for newly created dd
  old_delivery_detail_rec.oe_interfaced_flag:= NULL;


  -- Bug 1289812
  -- check if this split is valid operation
  IF (p_req_quantity >= NVL(old_delivery_detail_rec.picked_quantity,
                  old_delivery_detail_rec.requested_quantity)) THEN
  RAISE quantity_over;
  END IF;
  -- Bug 1299636
  -- check if this quantity to split is positive
  IF (p_req_quantity = 0) THEN
  RAISE zero_qty;
  ELSIF (p_req_quantity < 0) THEN
  RAISE negative_qty;
  END IF;
  l_qty2 := p_req_quantity2 ;

  /* need to validate the quantity passed meets the decimal quantity
   standard */

  --Check if org is a process one or not for the current record
  --
-- HW OPMCONV - Removed checking for process org

         --  Patch J:  Catch Weights
         --  Need to split the secondary quantity in proportion to the primary quantity.
         --  Catch weight support currently only for non-opm lines.

         IF old_delivery_detail_rec.picked_quantity2 IS NOT NULL and p_req_quantity2 IS NULL
            and (NVL(old_delivery_detail_rec.picked_quantity,0) <> 0) THEN

            l_qty2 :=  old_delivery_detail_rec.picked_quantity2 * (p_req_quantity/old_delivery_detail_rec.picked_quantity);
            l_qty2 :=  round(l_qty2, 5);

         ELSE

            l_qty2 := p_req_quantity2 ;

         END IF;


   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_DETAILS_VALIDATIONS.check_decimal_quantity(
        p_item_id    => old_delivery_detail_rec.inventory_item_id,
        p_organization_id => old_delivery_detail_rec.organization_id,
        p_input_quantity  => p_req_quantity,
        p_uom_code    => old_delivery_detail_rec.requested_quantity_UOM,
        x_output_quantity => l_output_quantity,
        x_return_status   => l_qty_return_status);

   IF (l_qty_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
    RAISE chk_decimal_qty_failed;
   END IF;
   IF (l_output_quantity IS not NULL) THEN
     p_req_quantity := l_output_quantity;
   END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE CALLING SPLIT_DETAIL_INT_BULK AND P_REQ_QUANTITY IS '||P_REQ_QUANTITY  );
      WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE CALLING SPLIT_DETAIL_INT_BULK AND P_QUANTITY_TO_SPLIT2 IS '||L_QTY2  );
  END IF;
  --



-- HW 2735317. Need to branch
-- HW OPMCONV - Removed branching

-- Fix for Bug 2637876 begins here
-- to split serial numbers while auto packing

-- Delete the PL SQL tables
  l_serial_tab.delete;
  l_dd_id_tab.delete;
  l_transaction_id_tab.delete;
  l_serial_number_tab.delete;

-- Only for cases where transaction temp id is not null
  IF old_delivery_detail_rec.transaction_temp_id IS NOT NULL THEN

    l_serial_orig_rec := old_delivery_detail_rec; -- use old record
    l_original_shipped_qty := old_delivery_detail_rec.shipped_quantity;
    l_split_shipped_qty := p_req_quantity;

    j := 0;

    FOR i IN 1..p_num_of_split
    LOOP
-- recalculate the shipped quantity
    l_original_shipped_qty := l_original_shipped_qty - l_split_shipped_qty;
    Split_Serial_Numbers_INT(x_old_detail_rec  => l_serial_orig_rec,
       x_new_delivery_detail_rec => l_new_serial_rec,
       p_old_shipped_quantity=> l_original_shipped_qty,
       p_new_shipped_quantity=> l_split_shipped_qty,
       x_return_status  => l_split_return_status);

    j := j + 1;

    l_transaction_id_tab(j) := l_new_serial_rec.transaction_temp_id;
    l_serial_number_tab(j) := l_new_serial_rec.serial_number;

    l_serial_tab(j).transaction_temp_id := l_new_serial_rec.transaction_temp_id;
    l_serial_tab(j).serial_number := l_new_serial_rec.serial_number;
    l_serial_tab(j).to_serial_number := l_new_serial_rec.to_serial_number;

    END LOOP;

    old_delivery_detail_rec.serial_number := l_serial_orig_rec.serial_number;
    old_delivery_detail_rec.transaction_temp_id := l_serial_orig_rec.transaction_temp_id;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Old DD id',old_delivery_detail_rec.delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name,'Old serial Number',old_delivery_detail_rec.serial_number);
      WSH_DEBUG_SV.log(l_module_name,'Old Temp id',old_delivery_detail_rec.transaction_temp_id);
      WSH_DEBUG_SV.log(l_module_name,'l_transaction_id_tab.COUNT',l_transaction_id_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'l_serial_number_tab.COUNT',l_serial_number_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'l_serial_tab.COUNT',l_serial_tab.count);
    END IF;

  END IF;

-- HW OPMCONV. Removed parameter  l_process_flag
  Split_Detail_INT_Bulk(
       p_old_delivery_detail_rec => old_delivery_detail_rec,
       p_quantity_to_split     => p_req_quantity,
       p_quantity_to_split2   => l_qty2,
       p_unassign_flag       => p_unassign_flag,
       p_converted_flag     => p_converted_flag,
       p_manual_split     => p_manual_split,
       p_num_of_split               => p_num_of_split,
       x_split_detail_id     => x_new_detail_id,
       x_return_status       => x_return_status,
       x_dd_id_tab       => l_dd_id_tab
                  );

 -- Message will be set in split_detail_int_bulk
   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                         ) THEN
     return;
   END IF;

   x_dd_id_tab := l_dd_id_tab;

-- HW 2735317. Need to branch
-- HW OPMCONV - Removed branching
  IF (old_delivery_detail_rec.transaction_temp_id IS NOT NULL
      OR old_delivery_detail_rec.serial_number IS NOT NULL) THEN

    -- Bug 4455732 : Combining transaction_temp_id and serial_number update into single cursor
    -- since single quantity detail can have transaction_temp_id also.
    FORALL i IN 1..l_dd_id_tab.count
    UPDATE wsh_delivery_details
       SET serial_number = decode(l_serial_number_tab(i),FND_API.G_MISS_CHAR,NULL,
                                   NULL,serial_number,l_serial_number_tab(i)) ,
           transaction_temp_id = decode(l_transaction_id_tab(i),FND_API.G_MISS_NUM,NULL,
                                         NULL,transaction_temp_id,l_transaction_id_tab(i))
     WHERE delivery_detail_id = l_dd_id_tab(i);

  END IF;  -- end of transaction temp id is not null


  /*  H integration: Pricing integration csun
    mark repirce required flag when split delivery details
   */
   l_entity_ids(1) := old_delivery_detail_rec.delivery_detail_id;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'entity id 1-',l_entity_ids(1));
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY_DETAIL',
       p_entity_ids   => l_entity_ids,
       x_return_status  => l_return_status);
   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                         ) THEN
      raise reprice_required_err;
   END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
  WHEN chk_decimal_qty_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_DECIMAL_QTY_NOT_VALID');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CHK_DECIMAL_QTY_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CHK_DECIMAL_QTY_FAILED');
    END IF;
    --
  WHEN quantity_over THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_SPLIT_EXCEED');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'QUANTITY_OVER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:QUANTITY_OVER');
    END IF;
    --
  WHEN zero_qty THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_NO_ZERO_NUM');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'ZERO_QTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ZERO_QTY');
    END IF;
    --
  WHEN negative_qty THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_NO_NEG_NUM');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'NEGATIVE_QTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NEGATIVE_QTY');
    END IF;
    --
  WHEN reprice_required_err THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'REPRICE_REQUIRED_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REPRICE_REQUIRED_ERR');
    END IF;
    --
  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS_BULK',l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END SPLIT_DELIVERY_DETAILS_BULK;

/*****************************************************************
  Description :-

  Currently being used values of p_manual_split are

NULL - default, normal mode of splitting backordered quantity
     then shipped quantity
Y - split staged quantity
C - split shipped quantity then backordered quantity (from packing code)
B - called from update_inventory_info for OPM's use
M - called from update_inventory_info for OPM's use
S - called from update_inventory_info for OPM's use
U - called from update_inventory_info for OPM's use

*******************************************************************/

-- This API is called from split_delivery_details_bulk with
-- new parameters and functionality of Bulk creation of records

/*****************************************************
-----   SPLIT_DETAIL_INT_BULK api
*****************************************************/
-- HW OPMCONV - Removed parameter p_process_flag
PROCEDURE Split_Detail_INT_bulk(
   p_old_delivery_detail_rec    IN  SplitDetailRecType,
   p_new_source_line_id  IN  NUMBER,
   p_quantity_to_split   IN  NUMBER,
   p_quantity_to_split2  IN  NUMBER  ,
   p_unassign_flag     IN  VARCHAR2 ,
   p_converted_flag   IN  VARCHAR2 ,
   p_manual_split   IN  VARCHAR2 ,
   p_split_sn     IN  VARCHAR2 ,
   p_num_of_split        IN NUMBER,        -- for empty container cases
   x_split_detail_id   OUT NOCOPY  NUMBER,
   x_return_status     OUT NOCOPY  VARCHAR2,
   x_dd_id_tab      OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
  ) IS

l_new_delivery_detail_id number;

--HW OPMCONV - Removed OPM variables

-- HW OPMCONV. Removed format of 19,9
l_qty2            NUMBER;
-- HW OPMCONV. Removed format of 19,9
l_split_shipped_qty2      NUMBER := NULL;
-- HW BUG#:1636578 variable to calculate new qty2
l_new_req_qty2 NUMBER;
-- HW OPMCONV. Removed format of 19,9
l_original_shipped_qty2    NUMBER := NULL;

l_new_req_qty   NUMBER;
l_new_pick_qty  NUMBER;
-- HW OPMCONV. No need for this variable anymore
--l_new_pick_qty2 NUMBER;

l_delivery_id  number;
l_parent_delivery_detail_id number;
assignment number;
l_delivery_assignment_id number;
assignment_rowid VARCHAR2(30);
total number;
l_cr_dt_status varchar2(30);
l_cr_assg_status varchar2(30);
l_output_quantity number;
l_qty_return_status varchar2(30);
new_det_wt_vol_failed exception;
old_det_wt_vol_failed exception;
l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
l_delivery_details_info WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_split_weight number;
l_split_volume number;
l_split_return_status varchar2(30);
l_shipped_quantity     NUMBER := NULL;
l_old_stage_qty      NUMBER := NULL;
l_ser_qty          NUMBER := NULL;

l_original_shipped_qty   NUMBER := NULL;
l_original_cc_qty     NUMBER := NULL;
l_split_shipped_qty  NUMBER := NULL;
l_split_cc_qty      NUMBER := NULL;
-- HW OPMCONV. Removed format of 19,9
l_split_cc_qty2    NUMBER := NULL;
-- HW OPMCONV. Removed format of 19,9
l_original_cc_qty2     NUMBER := NULL;
l_return_status     VARCHAR2(30);
-- HW OPMCONV - Removed OPM excpetion

-- J: W/V Changes
l_total_gross_wt NUMBER;
l_total_net_wt   NUMBER;
l_total_vol      NUMBER;
l_org_wv_qty     NUMBER;
l_new_wv_qty     NUMBER;
l_final_req_qty  NUMBER; --bug# 6689448 (replenishment project)

l_inv_controls_rec   WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;


WSH_SN_SPLIT_ERR        EXCEPTION;
WSH_NO_DATA_FOUND                               EXCEPTION;

l_num_of_split        NUMBER; -- added for BULK Auto packing
l_dd_id_tab           WSH_UTIL_CORE.id_tab_type;
l_da_id_tab           WSH_UTIL_CORE.id_tab_type;

l_updated_delivery_detail_rec          SplitDetailRecType;

l_req_qty_update_index    NUMBER;
-- HW Added qty2
l_req_qty2_update_index    NUMBER;

CURSOR c_get_req_pick_qty(p_del_det IN NUMBER) IS
SELECT requested_quantity, picked_quantity,requested_quantity2
FROM wsh_delivery_details
WHERE delivery_detail_id = p_del_det;



-- Bug 2734868
l_requested_quantity WSH_DELIVERY_DETAILS.requested_quantity%TYPE;
-- HW 12345 Added qty2
l_requested_quantity2 WSH_DELIVERY_DETAILS.requested_quantity%TYPE;
l_picked_quantity WSH_DELIVERY_DETAILS.picked_quantity%TYPE;
wsh_split_error EXCEPTION;

l_detail_tab    WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs        VARCHAR2(1); -- Return Status from DBI API

--
l_action VARCHAR2(100) := 'SPLIT-LINE';
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'SPLIT_DETAIL_INT_BULK';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_NEW_SOURCE_LINE_ID',P_NEW_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY_TO_SPLIT',P_QUANTITY_TO_SPLIT);
      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY_TO_SPLIT2',P_QUANTITY_TO_SPLIT2);
      WSH_DEBUG_SV.log(l_module_name,'P_UNASSIGN_FLAG',P_UNASSIGN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_CONVERTED_FLAG',P_CONVERTED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_MANUAL_SPLIT',P_MANUAL_SPLIT);
      WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_SN',P_SPLIT_SN);
      WSH_DEBUG_SV.log(l_module_name,'old shipped_quantity',
                                    p_old_delivery_detail_rec.shipped_quantity);
      WSH_DEBUG_SV.log(l_module_name,'old cycle_count_quantity',
                                p_old_delivery_detail_rec.cycle_count_quantity);
      WSH_DEBUG_SV.log(l_module_name,'old cycle_count_quantity2',
                               p_old_delivery_detail_rec.cycle_count_quantity2);
      WSH_DEBUG_SV.log(l_module_name,'old shipped_quantity2',
                               p_old_delivery_detail_rec.shipped_quantity2);
      WSH_DEBUG_SV.log(l_module_name,'old picked_quantity',
                               p_old_delivery_detail_rec.picked_quantity);
      WSH_DEBUG_SV.log(l_module_name,'old net_weight',
                               p_old_delivery_detail_rec.net_weight);
      WSH_DEBUG_SV.log(l_module_name,'old requested_quantity',
                               p_old_delivery_detail_rec.requested_quantity);
      WSH_DEBUG_SV.log(l_module_name,'old inventory_item_id',
                               p_old_delivery_detail_rec.inventory_item_id);
      WSH_DEBUG_SV.log(l_module_name,'old volume',
                               p_old_delivery_detail_rec.volume);
      WSH_DEBUG_SV.log(l_module_name,'old weight_uom_code',
                               p_old_delivery_detail_rec.weight_uom_code);
      WSH_DEBUG_SV.log(l_module_name,'old volume_uom_code',
                               p_old_delivery_detail_rec.volume_uom_code);
      WSH_DEBUG_SV.log(l_module_name,'old delivery_detail_id',
                               p_old_delivery_detail_rec.delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name,'old container_flag',
                               p_old_delivery_detail_rec.container_flag);
  END IF;
  --
  SAVEPOINT split_savepoint;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  /* need to validate the quantity passed meets the decimal quantity
     standard */


-- HW OPMCONV - Removed branching

  l_qty2 := p_quantity_to_split2;

    -- For bug 1307771. If shipped quantity is NULL.  Then leave the new
    -- shipped quantity to be NULL
  IF (p_old_delivery_detail_rec.shipped_quantity IS NULL AND p_old_delivery_detail_rec.cycle_count_quantity IS NULL) THEN
  l_split_shipped_qty := NULL;
  l_split_cc_qty := NULL;
  l_split_shipped_qty2 :=NULL;
  l_split_cc_qty2 := NULL;
     IF l_debug_on THEN
 	WSH_DEBUG_SV.log(l_module_name,' p_old_delivery_detail_rec.shipped_quantity ',p_old_delivery_detail_rec.shipped_quantity);
 	WSH_DEBUG_SV.log(l_module_name,' p_old_delivery_detail_rec.cycle_count_quantity ',p_old_delivery_detail_rec.cycle_count_quantity );
     END IF;

  ELSIF (p_manual_split = 'C') THEN

    l_split_shipped_qty := LEAST(p_old_delivery_detail_rec.shipped_quantity,
                   p_quantity_to_split);
  l_split_shipped_qty2 := LEAST(p_old_delivery_detail_rec.shipped_quantity2,
                  p_quantity_to_split2);
    l_split_cc_qty := LEAST(p_old_delivery_detail_rec.cycle_count_quantity,
                (p_quantity_to_split - nvl(l_split_shipped_qty,0)));
  l_split_cc_qty2 := LEAST(p_old_delivery_detail_rec.cycle_count_quantity2,
               (p_quantity_to_split2 - NVL(l_split_shipped_qty2,0)));

  l_original_shipped_qty := p_old_delivery_detail_rec.shipped_quantity     -
 l_split_shipped_qty;
  l_original_cc_qty   := p_old_delivery_detail_rec.cycle_count_quantity   -
 l_split_cc_qty;
  l_original_shipped_qty2 := p_old_delivery_detail_rec.shipped_quantity2   -
 l_split_shipped_qty2;
  l_original_cc_qty2    := p_old_delivery_detail_rec.cycle_count_quantity2 -
 l_split_cc_qty2;

 ELSIF (p_manual_split = 'Y') THEN

  /* bug 1983460
  if the call is from ship confirm to split only the stage quantity
   the split delivery detail has null shipped and cc quantities.
  */

    l_split_shipped_qty := NULL;
    l_split_cc_qty := NULL;
      l_split_shipped_qty2 :=NULL;
      l_split_cc_qty2 := NULL;

  /* bug 1983460
  since the split shipped and split cc quantities are null, we should
  leave the original shipped and original cc quantities as they are.
  */

  l_original_shipped_qty := p_old_delivery_detail_rec.shipped_quantity;
  l_original_cc_qty   := p_old_delivery_detail_rec.cycle_count_quantity;
  l_original_shipped_qty2 := p_old_delivery_detail_rec.shipped_quantity2;

  l_original_cc_qty2    := p_old_delivery_detail_rec.cycle_count_quantity2;


  ELSE
  -- use cc qty to split p_quantity_to_split before we use shipped qty to complete the quantity split
  --  (This takes care of splitting lines to backorder/cycle-count, for example.)
  -- assumption: the quantities' relationships are valid

  l_split_cc_qty  := LEAST(p_old_delivery_detail_rec.cycle_count_quantity,   p_quantity_to_split);
  l_split_cc_qty2 := LEAST(p_old_delivery_detail_rec.cycle_count_quantity2,  p_quantity_to_split2);

  -- fail-safe: NVL to ensure that shipped qtys can still be split even if cc qtys are NULL
  l_split_shipped_qty  := LEAST(p_old_delivery_detail_rec.shipped_quantity,  (p_quantity_to_split  - NVL(l_split_cc_qty,0)));
  l_split_shipped_qty2 := LEAST(p_old_delivery_detail_rec.shipped_quantity2, (p_quantity_to_split2 - NVL(l_split_cc_qty2,0)));

  -- update original line's quantities accordingly
  l_original_shipped_qty := p_old_delivery_detail_rec.shipped_quantity     - l_split_shipped_qty;
  l_original_cc_qty   := p_old_delivery_detail_rec.cycle_count_quantity   - l_split_cc_qty;

  l_original_shipped_qty2 := p_old_delivery_detail_rec.shipped_quantity2   - l_split_shipped_qty2;
  l_original_cc_qty2    := p_old_delivery_detail_rec.cycle_count_quantity2 - l_split_cc_qty2;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,' l_split_cc_qty ',l_split_cc_qty);
    WSH_DEBUG_SV.log(l_module_name,' l_split_cc_qty2 ',l_split_cc_qty2 );
  END IF;

  --
  /*
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.INITIALIZE_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_DETAILS_PKG.initialize_detail(
              p_delivery_detail_rec  =>  l_delivery_details_info);
  */

  IF p_old_delivery_detail_rec.picked_quantity IS NULL THEN
  l_delivery_details_info.requested_quantity := p_quantity_to_split;
  ELSE
  l_delivery_details_info.requested_quantity := LEAST(p_old_delivery_detail_rec.requested_quantity, p_quantity_to_split);
  l_delivery_details_info.picked_quantity := p_quantity_to_split;
-- HW OPM for OM changes
-- HW OPMCONV. No need to use   l_new_pick_qty2
--l_delivery_details_info.picked_quantity2  := nvl(nvl(l_qty2,l_new_pick_qty2),FND_API.G_MISS_NUM);
l_delivery_details_info.picked_quantity2  := nvl(l_qty2,FND_API.G_MISS_NUM);

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, ' l_delivery_details_info.requested_quantity2',l_delivery_details_info.requested_quantity2);
  END IF;

  --Bug 7291415. 0 to be considered as valid value. Following IF condition modified.
   --IF ( NVL(l_qty2, 0) = 0  OR l_qty2 < 0 ) THEN
  IF ( NVL(l_qty2, -999) = -999  OR l_qty2 < 0 ) THEN

  l_delivery_details_info.requested_quantity2 := FND_API.G_MISS_NUM;
  ELSE
  l_delivery_details_info.requested_quantity2 := l_qty2;
  END IF;

-- Bug 2181132 in Bulk API
-- pass the value which is input
   l_delivery_details_info.source_line_set_id :=
          p_old_delivery_detail_rec.source_line_set_id;

  IF p_new_source_line_id IS NOT NULL THEN
  l_delivery_details_info.source_line_id := p_new_source_line_id;
  END IF;


  -- J: W/V Changes
  IF p_old_delivery_detail_rec.wv_frozen_flag = 'Y' THEN
    l_org_wv_qty := NVL(NVL(p_old_delivery_detail_rec.shipped_quantity,p_old_delivery_detail_rec.picked_quantity), p_old_delivery_detail_rec.requested_quantity);

    IF (p_manual_split = 'Y') THEN
      -- p_manual_split is 'Y' only when splitting for staged delivery details during ship confirm
      -- Staged delivery details W/V should always be reset back to original W/V
      l_new_wv_qty := 0;
    ELSE
      SELECT NVL(decode(l_split_shipped_qty,FND_API.G_MISS_NUM,null,l_split_shipped_qty),
                        NVL(decode(l_delivery_details_info.picked_quantity,FND_API.G_MISS_NUM,null,l_delivery_details_info.picked_quantity),
                            decode(l_delivery_details_info.requested_quantity,FND_API.G_MISS_NUM,null,l_delivery_details_info.requested_quantity)))
      INTO   l_new_wv_qty
      FROM   dual;
    END IF;

    IF l_org_wv_qty <> 0 THEN
      l_delivery_details_info.gross_weight :=  round( (l_new_wv_qty/l_org_wv_qty) * p_old_delivery_detail_rec.gross_weight ,5);
      l_delivery_details_info.net_weight   :=  round( (l_new_wv_qty/l_org_wv_qty) * p_old_delivery_detail_rec.net_weight ,5);
      l_delivery_details_info.volume       :=  round( (l_new_wv_qty/l_org_wv_qty) * p_old_delivery_detail_rec.volume ,5);
    ELSE
      l_delivery_details_info.gross_weight := 0;
      l_delivery_details_info.net_weight   := 0;
      l_delivery_details_info.volume       := 0;
    END IF;

  END IF;

  IF (l_split_shipped_qty is not null and l_split_shipped_qty = 0) or (p_manual_split = 'Y') THEN
    l_delivery_details_info.wv_frozen_flag  := 'N';
  ELSE
    l_delivery_details_info.wv_frozen_flag  := p_old_delivery_detail_rec.wv_frozen_flag;
  END IF;
  l_delivery_details_info.weight_uom_code := p_old_delivery_detail_rec.weight_uom_code;
  l_delivery_details_info.volume_uom_code := p_old_delivery_detail_rec.volume_uom_code;

  l_delivery_details_info.shipped_quantity := nvl(l_split_shipped_qty,FND_API.G_MISS_NUM);
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_split_shipped_qty2',l_split_shipped_qty2);
  END IF;
  IF ( NVL(l_split_shipped_qty2, 0) = 0 ) THEN
  l_delivery_details_info.shipped_quantity2 := FND_API.G_MISS_NUM;
  ELSE
  l_delivery_details_info.shipped_quantity2 := l_split_shipped_qty2;
  END IF;
  IF ( NVL(l_qty2, 0) = 0 OR l_qty2 < 0  ) THEN
  l_delivery_details_info.cancelled_quantity2 := FND_API.G_MISS_NUM;
  ELSE
  -- Bug 2116595
  l_delivery_details_info.cancelled_quantity2 := FND_API.G_MISS_NUM;
  END IF;

  l_delivery_details_info.cycle_count_quantity := nvl(l_split_cc_qty,FND_API.G_MISS_NUM);
-- HW OPMCONV - No need to branch
--  IF ( p_process_flag = FND_API.G_TRUE ) THEN
  l_delivery_details_info.cycle_count_quantity2 := nvl(l_split_cc_qty2,FND_API.G_MISS_NUM);
--  END IF;

  -- Bug 2116595
  l_delivery_details_info.cancelled_quantity := FND_API.G_MISS_NUM;
  l_delivery_details_info.split_from_detail_id := p_old_delivery_detail_rec.delivery_detail_id;

  l_delivery_details_info.container_flag := p_old_delivery_detail_rec.container_flag;
  l_delivery_details_info.master_serial_number := FND_API.G_MISS_CHAR;
  l_delivery_details_info.serial_number := FND_API.G_MISS_CHAR;
  l_delivery_details_info.to_serial_number := FND_API.G_MISS_CHAR;
  l_delivery_details_info.transaction_temp_id := FND_API.G_MISS_NUM;
  l_delivery_details_info.last_update_date := SYSDATE;
  l_delivery_details_info.last_updated_by :=  FND_GLOBAL.USER_ID;
  l_delivery_details_info.last_update_login :=  FND_GLOBAL.LOGIN_ID;
  -- Bug 2419301
  l_delivery_details_info.oe_interfaced_flag := p_old_delivery_detail_rec.oe_interfaced_flag;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'SPLIT_DETAIL_INT_BULK: OE_INTERFACED_FLAG '||L_DELIVERY_DETAILS_INFO.OE_INTERFACED_FLAG  );
  END IF;
  --

  l_new_delivery_detail_id := NULL;


  l_updated_delivery_detail_rec := p_old_delivery_detail_rec;

-- The Split Serial Number has not been tested
-- this needs to be modified for Bulk split

-- HW OPMCONV - Remove the whole branch since the code was commented

 l_num_of_split := p_num_of_split;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DD_FROM_OLD_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
-- call to new API
-- with a value for p_num_of_rec
  WSH_DELIVERY_DETAILS_PKG.create_dd_from_old_bulk(
      p_delivery_detail_rec  =>  l_delivery_details_info,
            p_delivery_detail_id    =>   p_old_delivery_detail_rec.delivery_detail_id,
                  p_num_of_rec            =>     l_num_of_split,
      x_dd_id_tab   =>   l_dd_id_tab,
      x_return_status         =>   l_cr_dt_status);

 -- Bug 2870267
  -- The bulk API above creates delivery details with a requested qty
  -- of l_delivery_details_info.requested_quantity for each of the new details created.
  -- However if we overpick, the sum of these requested qtys would add up to
  -- the picked qty and not the requested qty of the original line.
  -- We need to make sure that the sum of the requested quantities add up to the requested quantity
  -- of the original line, and that the extra requested quantities that add up to the
  -- original picked quantity are zeroed out.

  OPEN c_get_req_pick_qty (p_old_delivery_detail_rec.delivery_detail_id);

  FETCH c_get_req_pick_qty INTO l_requested_quantity, l_picked_quantity,
         l_requested_quantity2;

  IF c_get_req_pick_qty%NOTFOUND THEN

    RAISE WSH_NO_DATA_FOUND;

  END IF;

  CLOSE c_get_req_pick_qty;

  --bug# 6689448 (replenishment project) (begin) : call WMS for whenever there is split on replenishment requested
  -- delivery detail lines with the new quantity for the old delivery detail line on p_primary_quantity parameter.
  -- Inturn WMS creates a new replenishment record for p_split_delivery_detail_id with old delivery detail line old qty - old delivery detail line
  --  new quantity (p_primary_quantity).
  IF ( p_old_delivery_detail_rec.replenishment_status = 'R' and p_old_delivery_detail_rec.released_status in ('R','B')) THEN
  --{
      l_final_req_qty := l_requested_quantity;
      FOR i IN 1..l_dd_id_tab.count LOOP
      --{
          l_final_req_qty := l_final_req_qty - l_delivery_details_info.requested_quantity;
          IF ((l_final_req_qty = l_requested_quantity) OR (l_final_req_qty < 0)) THEN
              EXIT;
          END IF;
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL(
               p_delivery_detail_id       => p_old_delivery_detail_rec.delivery_detail_id,
               p_primary_quantity         => l_final_req_qty,
               p_split_delivery_detail_id => l_dd_id_tab(i),
               x_return_status            => x_return_status );
          IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          --{
              rollback to split_savepoint;
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
          --}
          END IF;
      --}
      END LOOP;
  --}
  END IF;
  --bug# 6689448 (replenishment project):end

  IF (l_picked_quantity > l_requested_quantity) AND (l_delivery_details_info.requested_quantity <> 0)  THEN --{


     -- Calculate the index of the delivery detail from the created table at which the sum of the new
     -- requested quantities would equal (or exceed) the requested quantity of the original line.

     l_req_qty_update_index := CEIL(l_requested_quantity/l_delivery_details_info.requested_quantity);
-- HW 12345 Added qty2
     IF ( l_delivery_details_info.requested_quantity2 <> 0 ) THEN
       l_req_qty2_update_index := CEIL(l_requested_quantity2/l_delivery_details_info.requested_quantity2);
     ELSE
       l_req_qty2_update_index := NULL;
     END IF;

     -- If not a clean split, we need to update the requested quantity of the delivery detail at this
     -- index such that the sum of the requested quantities of all the new delivery details before this index
     -- plus the requested qty at this index add up to the original requested quantity.

     IF l_req_qty_update_index > (l_requested_quantity/l_delivery_details_info.requested_quantity) THEN

        -- Bug 3178233 - Need to add the IF condition because the update will fail in the following example:
        --               requested_quantity = 3, picked_quantity = 4, and split quantity is 2
        --               l_req_qty_update_index = CEIL(3/2) = 2
        --               Update at l_dd_id_tab(l_req_qty_update_index) = l_dd_id_tab(2) is a non-exist value which will fail.
        IF l_req_qty_update_index <= l_dd_id_tab.count THEN
-- 12345 HW added qty2
           update wsh_delivery_details
           set requested_quantity = l_requested_quantity - ((l_req_qty_update_index - 1) * l_delivery_details_info.requested_quantity),
               requested_quantity2 = decode(l_delivery_details_info.requested_quantity2, fnd_api.g_miss_num, NULL, l_requested_quantity2 - ((l_req_qty2_update_index - 1) * l_delivery_details_info.requested_quantity2))
           where delivery_detail_id = l_dd_id_tab(l_req_qty_update_index);
        END IF;
     END IF;

     -- Set the requested quantity to zero in all the newly created lines after the above index.

     FORALL i in (l_req_qty_update_index + 1) .. l_dd_id_tab.count
-- HW added qty2
     update wsh_delivery_details
     set requested_quantity = 0,
         requested_quantity2 = 0
     where delivery_detail_id = l_dd_id_tab(i);

    --
    -- DBI Project,Above 2 updates for requested quantity need to be tracked for DBI Call
    -- These can be combined since both use l_dd_id_tab
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- DBI API will check if DBI is installed
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_dd_id_tab.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_dd_id_tab,
       p_dml_type               => 'UPDATE',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    -- Only Handle Unexpected error
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_dbi_rs;
      rollback to split_savepoint;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
    -- End of Code for DBI Project
    --

  END IF;  --}

  -- END Bug 2870267

-- J: W/V Changes
  IF p_old_delivery_detail_rec.wv_frozen_flag = 'N' THEN
    -- Bug 4416863
    -- During Partial Shipping with the remain qty as staged, w/v value should not be
    -- deducted again from the original line since during entering shipped_quantity
    -- w/v has been calculated for the original line.
    IF (p_manual_split = 'Y') THEN
      l_total_net_wt   := 0;
      l_total_gross_wt := 0;
      l_total_vol      := 0;
    ELSE
    -- end bug 4416863
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      l_total_net_wt := 0;
      l_total_gross_wt := 0;
      l_total_vol := 0;
      FOR i in 1..l_dd_id_tab.count LOOP

        WSH_WV_UTILS.Detail_Weight_Volume(
          p_delivery_detail_id => l_dd_id_tab(i),
          p_update_flag        => 'Y',
          x_net_weight         => l_split_weight,
          x_volume             => l_split_volume,
          x_return_status      => l_split_return_status);
        IF (l_split_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          RAISE new_det_wt_vol_failed;
        END IF;

        l_total_net_wt := l_total_net_wt + l_split_weight;
        l_total_vol := l_total_vol + l_split_volume;

      END LOOP;
      l_total_gross_wt := l_total_net_wt;
    END IF;
  ELSE
     l_total_net_wt   := p_num_of_split * l_delivery_details_info.net_weight;
     l_total_gross_wt := p_num_of_split * l_delivery_details_info.gross_weight;
     l_total_vol      := p_num_of_split * l_delivery_details_info.volume;
  END IF;

  l_delivery_assignments_info.type := 'S';

  IF (p_unassign_flag = 'N') THEN
    l_delivery_assignments_info.delivery_id := p_old_delivery_detail_rec.delivery_id;
    l_delivery_assignments_info.parent_delivery_detail_id := p_old_delivery_detail_rec.parent_delivery_detail_id;
    IF p_old_delivery_detail_rec.wda_type =  'C' THEN
       l_delivery_assignments_info.type := 'O';
       l_delivery_assignments_info.parent_delivery_detail_id := NULL;
    END IF;
  ELSE
    l_delivery_assignments_info.delivery_id := NULL;
    l_delivery_assignments_info.parent_delivery_detail_id := NULL;
  END IF;

  l_delivery_assignments_info.delivery_detail_id := l_new_delivery_detail_id;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIV_ASSIGNMENT_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

  -- this is a bulk call
  -- with new parameter of p_num_of_rec
  -- and pass l_dd_id_tab which will pass the delivery detail id
  wsh_delivery_details_pkg.create_deliv_assignment_bulk(
      p_delivery_assignments_info => l_delivery_assignments_info,
                        p_num_of_rec => l_num_of_split,
                        p_dd_id_tab    => l_dd_id_tab,
      x_da_id_tab => l_da_id_tab,
      x_return_status => l_cr_assg_status
      );

 -- K: MDC: We need to create the consolidation records as well
 --         If necessary.
 IF (p_unassign_flag = 'N') AND (p_old_delivery_detail_rec.wda_type =  'C') THEN

    l_delivery_assignments_info.type := 'C';
    l_delivery_assignments_info.parent_delivery_id := p_old_delivery_detail_rec.parent_delivery_id;
    l_delivery_assignments_info.parent_delivery_detail_id := p_old_delivery_detail_rec.parent_delivery_detail_id;

    wsh_delivery_details_pkg.create_deliv_assignment_bulk(
                      p_delivery_assignments_info => l_delivery_assignments_info,
                      p_num_of_rec                => l_num_of_split,
                      p_dd_id_tab                 => l_dd_id_tab,
                      x_da_id_tab                 => l_da_id_tab,
                      x_return_status             => l_cr_assg_status
                   );
    IF l_cr_assg_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR,
                          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                        ) THEN
       x_return_status := l_cr_assg_status;
       return;
    END IF;


 END IF;

/*2442099*/
  FOR i in 1..l_dd_id_tab.count
  LOOP
   Log_Exceptions(p_old_delivery_detail_rec.delivery_detail_id,l_dd_id_tab(i),l_delivery_assignments_info.delivery_id,l_action);
 END LOOP;

  -- this is FOR RETURN variable
  x_dd_id_tab := l_dd_id_tab;

  /* NC - Added the following for OPM  BUG#1675561 */
  /* LG BUG#:2005977 */
  /* LG new */

  --
-- HW OPMCONV - Removed branching

  /* Bug 2177410, also update net_weight and volume of original delivery detail
   because non item does not use WSH_WV_UTILS.Detail_Weight_Volume to
   adjust the net_weight and volume  */

  x_split_detail_id := l_new_delivery_detail_id;

-- update original shipped qty since this was not decremented correctly before.
-- now decrement it with proper split number

-- Bug 2734868
-- If nvl(picked,requested) quantity is set to zero, error
-- should not be allowed
-- example in case of 12(req) - 12(pic) - 15(ship) when l_num_of_split = 7

  IF (nvl(GREATEST(l_picked_quantity - (l_num_of_split*p_quantity_to_split),0
                   ),
         GREATEST(l_requested_quantity - (l_num_of_split*l_delivery_details_info.requested_quantity),0
                  )
         ) <= 0
     )THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'CANNOT SPLIT, NEED TO REVISIT THE QUANTITIES');
    END IF;

    RAISE wsh_split_error;

  END IF;

-- End of Bug 2734868

-- OPM HW Included this fix in 3011758
-- Modified requested_quantity2,picked_quantity2 and shipped_quantity2
-- to be the same as quantity1s

  UPDATE wsh_delivery_details
  SET requested_quantity  = GREATEST(requested_quantity - (l_num_of_split*l_delivery_details_info.requested_quantity), 0),
    requested_quantity2   = GREATEST(requested_quantity2 -(l_num_of_split*l_qty2), 0),
     picked_quantity       = GREATEST(picked_quantity - (l_num_of_split*p_quantity_to_split),0),
-- HW OPMCONV. No need to use l_new_pick_qty2
--  picked_quantity2      = GREATEST(picked_quantity2 - (l_num_of_split* nvl(l_qty2,l_new_pick_qty2)),0),
    picked_quantity2      = GREATEST(picked_quantity2 - (l_num_of_split* l_qty2) ,0),
    --shipped_quantity    = l_original_shipped_qty - p_quantity_to_split,
    shipped_quantity    = l_original_shipped_qty - GREATEST((l_num_of_split -1) * p_quantity_to_split,0),
    shipped_quantity2   = l_original_shipped_qty2 - GREATEST((l_num_of_split -1) * nvl(l_qty2,0),0),
    --shipped_quantity2   = l_original_shipped_qty2 - ((greatest(l_num_of_split -1),0) * p_quantity_to_split),
    cycle_count_quantity  = l_original_cc_qty,
    cycle_count_quantity2 = l_original_cc_qty2,
    serial_number   = decode(l_updated_delivery_detail_rec.serial_number,FND_API.G_MISS_CHAR,NULL,
                                          NULL,serial_number,l_updated_delivery_detail_rec.serial_number),
    to_serial_number  = decode(l_updated_delivery_detail_rec.to_serial_number,FND_API.G_MISS_CHAR,NULL,
                                          NULL,to_serial_number,l_updated_delivery_detail_rec.to_serial_number),
    transaction_temp_id   = decode(l_updated_delivery_detail_rec.transaction_temp_id,FND_API.G_MISS_NUM,NULL,
                                          NULL,transaction_temp_id,l_updated_delivery_detail_rec.transaction_temp_id),
-- J: W/V Changes
    gross_weight          =  gross_weight - l_total_gross_wt,
    net_weight            =  net_weight - l_total_net_wt,
    volume                =  volume - l_total_vol,
-- End J: W/V Changes
    last_update_date   = SYSDATE,
    last_updated_by = FND_GLOBAL.USER_ID,
    last_update_login  = FND_GLOBAL.LOGIN_ID
  WHERE delivery_detail_id = p_old_delivery_detail_rec.delivery_detail_id;

  /* call the wv util to calculate the wv for the original detail too */
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.requested_quantity'
                               ,l_delivery_details_info.requested_quantity);
     WSH_DEBUG_SV.log(l_module_name,'l_qty2',l_qty2);
     WSH_DEBUG_SV.log(l_module_name,'l_original_shipped_qty',
                                                      l_original_shipped_qty);
     WSH_DEBUG_SV.log(l_module_name,'l_original_cc_qty2',l_original_cc_qty2);
     WSH_DEBUG_SV.log(l_module_name,'l_original_cc_qty',l_original_cc_qty);
  END IF;
  --

  --
  -- DBI Project
  -- Update of wsh_delivery_details where requested_quantity/released_status
  -- are changed, call DBI API after the update.
  -- This API will also check for DBI Installed or not
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_old_delivery_detail_rec.delivery_detail_id);
  END IF;
  l_detail_tab(1) := p_old_delivery_detail_rec.delivery_detail_id;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_detail_tab,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    x_return_status := l_dbi_rs;
    -- just pass this return status to caller API
    rollback to split_savepoint;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;
  -- End of Code for DBI Project
  --


  -- J: W/V Changes
  -- Decrement the DD W/V from parent if p_unassign_flag is 'Y'
  IF (p_unassign_flag = 'Y') THEN
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id => p_old_delivery_detail_rec.delivery_detail_id,
          p_diff_gross_wt      => -1 * l_total_gross_wt,
          p_diff_net_wt        => -1 * l_total_net_wt,
          p_diff_fill_volume   => -1 * l_total_vol,
          x_return_status      => l_return_status);

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         --
         rollback to split_savepoint;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status);
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return;
    END IF;
  END IF;

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);

  END IF;
  --

  EXCEPTION
-- HW OPMCONV. Removed OPM excpetion

  WHEN old_det_wt_vol_failed THEN
    rollback to split_savepoint;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_WT_VOL_FAILED');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',  p_old_delivery_detail_rec.delivery_detail_id);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OLD_DET_WT_VOL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OLD_DET_WT_VOL_FAILED');
    END IF;
    --
  WHEN new_det_wt_vol_failed THEN
    rollback to split_savepoint;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_WT_VOL_FAILED');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',  l_new_DELIVERY_DETAIL_ID);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'NEW_DET_WT_VOL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NEW_DET_WT_VOL_FAILED');
    END IF;
    --
  WHEN WSH_SPLIT_ERROR THEN
    rollback to split_savepoint;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_SPLIT_ERROR');
    fnd_message.set_token('DETAIL_ID',  p_old_delivery_detail_rec.delivery_detail_id);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SPLIT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_SPLIT_ERROR');
    END IF;
  WHEN WSH_SN_SPLIT_ERR THEN
    rollback to split_savepoint;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_SN_SPLIT_ERR');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SN_SPLIT_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_SN_SPLIT_ERR');
    END IF;

  WHEN WSH_NO_DATA_FOUND THEN
    IF c_get_req_pick_qty%ISOPEN THEN
      CLOSE c_get_req_pick_qty;
    END IF;
    rollback to split_savepoint;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_NO_DATA_FOUND');
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_DATA_FOUND');
    END IF;
    --
  WHEN others THEN
    IF c_get_req_pick_qty%ISOPEN THEN
      CLOSE c_get_req_pick_qty;
    END IF;
    rollback to split_savepoint;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DETAIL_INT_BULK',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END SPLIT_DETAIL_INT_BULK;

/*************************/
--
--Procedure:
--Parameters:    p_from_detail_id
--          p_req_quantity
--          p_new_detail_id
--          x_return_status
--Desription:
--        Splits a delivery detail according the new requested
--        quantity. The newly created the detail has the requested
--        quantity as p_req_quantity and the old detail has the
--
-- fabdi start : PICK CONFIRM
--added a new parameter called p_req_quantity2      requested quantity as requested_quantity - p_requested_quantity
-- fabdi end : PICK CONFIRM
-- HW BUG#:1636578 added a new parameter p_converted_flag

/*****************************************************
-----   SPLIT_DELIVERY_DETAILS api
*****************************************************/
PROCEDURE Split_Delivery_Details (
p_from_detail_id     IN  NUMBER,
p_req_quantity       IN OUT NOCOPY  NUMBER,
x_new_detail_id      OUT NOCOPY  NUMBER,
x_return_status     OUT NOCOPY  VARCHAR2,
p_unassign_flag     IN  VARCHAR2 ,
p_req_quantity2     IN  NUMBER ,
p_converted_flag     IN VARCHAR2,
p_manual_split   IN VARCHAR2 )
IS

l_new_delivery_detail_id number;

-- HW OPMCONV - Removed OPM variables

-- HW OPMCONV. Remove format 19,9
l_qty2            NUMBER;
l_split_shipped_qty2      NUMBER(19,9):= NULL;
-- HW BUG#:1636578 variable to calculate new qty2
l_new_req_qty2 NUMBER;
l_original_shipped_qty2    NUMBER(19,9):= NULL;

l_new_req_qty   NUMBER;
l_new_pick_qty  NUMBER;
-- HW OPMCONV. No need to use l_new_pick_qty2
--l_new_pick_qty2 NUMBER;

-- STOPPED HERE --

l_delivery_id  number;
l_parent_delivery_detail_id number;
assignment number;
l_delivery_assignment_id number;
detail_rowid VARCHAR2(30);
assignment_rowid VARCHAR2(30);
total number;
l_cr_dt_status varchar2(30);
l_cr_assg_status varchar2(30);
l_output_quantity number;
l_return_status   varchar2(1);
l_qty_return_status varchar2(30);

chk_decimal_qty_failed exception;
quantity_over EXCEPTION;
negative_qty  EXCEPTION;
zero_qty    EXCEPTION;
fail_create_detail EXCEPTION;
/*   H integration: Pricing integration csun
   mark reprice required flag when split_delivery_details
 */
l_entity_ids   WSH_UTIL_CORE.id_tab_type;
reprice_required_err   EXCEPTION;
l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
l_delivery_details_info WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_split_weight number;
l_split_volume number;
l_split_return_status varchar2(30);
l_shipped_quantity     NUMBER := NULL;
l_old_stage_qty      NUMBER := NULL;
l_ser_qty          NUMBER := NULL;


  old_delivery_detail_rec SplitDetailRecType;

l_inv_controls_rec   WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'SPLIT_DELIVERY_DETAILS';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_DETAIL_ID',P_FROM_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_REQ_QUANTITY',P_REQ_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_UNASSIGN_FLAG',P_UNASSIGN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_REQ_QUANTITY2',P_REQ_QUANTITY2);
      WSH_DEBUG_SV.log(l_module_name,'P_CONVERTED_FLAG',P_CONVERTED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_MANUAL_SPLIT',P_MANUAL_SPLIT);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN c_split_detail_info(p_from_detail_id);
  FETCH c_split_detail_info into old_delivery_detail_rec;
  CLOSE c_split_detail_info;

  -- Bug 2419301 : Set oe_interfaced_flag to MISS CHAR so that create_new_detail_from_old API
  --               determines the value of oe_interfaced_flag for newly created dd
  old_delivery_detail_rec.oe_interfaced_flag:= NULL;


  -- Bug 1289812
  -- check if this split is valid operation
  IF (
        p_req_quantity >= NVL(old_delivery_detail_rec.picked_quantity,old_delivery_detail_rec.requested_quantity)
      AND NVL(old_delivery_detail_rec.line_direction,'O') IN ('O','IO')  -- J-IB-NPARIKH
     )
     OR
     (
        p_req_quantity >= NVL(
                                old_delivery_detail_rec.received_quantity,
                                NVL(old_delivery_detail_rec.shipped_quantity,
                                NVL(old_delivery_detail_rec.picked_quantity,
                                old_delivery_detail_rec.requested_quantity))
                             )     -- J-IB-NPARIKH
      AND NVL(old_delivery_detail_rec.line_direction,'O') NOT IN ('O','IO')   -- J-IB-NPARIKH
     )
  THEN
  RAISE quantity_over;
  END IF;
  -- Bug 1299636
  -- check if this quantity to split is positive
  IF (p_req_quantity = 0) THEN
  RAISE zero_qty;
  ELSIF (p_req_quantity < 0) THEN
  RAISE negative_qty;
  END IF;
  l_qty2 := p_req_quantity2 ;

  /* need to validate the quantity passed meets the decimal quantity
   standard */

  --Check if org is a process one or not for the current record
  --
-- HW OPMCONV - Removed checking for process org

         --  Patch J:  Catch Weights
         --  Need to split the secondary quantity in proportion to the primary quantity.
         --  Catch weight support currently only for non-opm lines.

         IF   old_delivery_detail_rec.picked_quantity2 IS NOT NULL and p_req_quantity2 IS NULL
            and (NVL(old_delivery_detail_rec.picked_quantity,0) <> 0)
            AND NVL(old_delivery_detail_rec.line_direction,'O') in ('O','IO') -- J-IB-NPARIKH
         THEN

            l_qty2 :=  old_delivery_detail_rec.picked_quantity2 * (p_req_quantity/old_delivery_detail_rec.picked_quantity);
            l_qty2 :=  round(l_qty2,5);
            IF l_debug_on THEN
 	      wsh_debug_sv.log(l_module_name,' l_qty2 ',l_qty2);
 	    END IF;
         ELSE

            l_qty2 := p_req_quantity2 ;

         END IF;





   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_DETAILS_VALIDATIONS.check_decimal_quantity(
        p_item_id    => old_delivery_detail_rec.inventory_item_id,
        p_organization_id => old_delivery_detail_rec.organization_id,
        p_input_quantity  => p_req_quantity,
        p_uom_code    => old_delivery_detail_rec.requested_quantity_UOM,
        x_output_quantity => l_output_quantity,
        x_return_status   => l_qty_return_status);

   IF (l_qty_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
    RAISE chk_decimal_qty_failed;
   END IF;
   IF (l_output_quantity IS not NULL) THEN
     p_req_quantity := l_output_quantity;
   END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE CALLING SPLIT_DETAIL_INT AND P_REQ_QUANTITY IS '||P_REQ_QUANTITY  );
  END IF;
  --
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE CALLING SPLIT_DETAIL_INT AND P_QUANTITY_TO_SPLIT2 IS '||L_QTY2  );
  END IF;
  --

-- HW OPMCONV - Removed l_process_flag parameter
  Split_Detail_INT(
       p_old_delivery_detail_rec => old_delivery_detail_rec,
       p_quantity_to_split     => p_req_quantity,
       p_quantity_to_split2   => l_qty2,
       p_unassign_flag       => p_unassign_flag,
       p_converted_flag     => p_converted_flag,
       p_manual_split     => p_manual_split,
       x_split_detail_id     => x_new_detail_id,
       x_return_status       => x_return_status);

   -- Bug 3724578 : Return back to the caller if any error occurs
   --               while splitting the delivery detail line
   --- Message will be set in  Split_Detail_INT
  IF x_return_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
    		       ) THEN
    return;
  END IF;

  --bug# 6689448 (replenishment project) (begin) : call WMS for whenever there is split on replenishment requested
  -- delivery detail lines with the new quantity for the old delivery detail line on p_primary_quantity parameter.
  -- Inturn WMS creates a new replenishment record for p_split_delivery_detail_id with old delivery detail line old qty - old delivery detail line
  --  new quantity (p_primary_quantity).
  IF ( old_delivery_detail_rec.replenishment_status = 'R' and old_delivery_detail_rec.released_status in ('R','B')) THEN
  --{
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL(
          p_delivery_detail_id       => old_delivery_detail_rec.delivery_detail_id,
          p_primary_quantity         => old_delivery_detail_rec.requested_quantity - p_req_quantity,
          p_split_delivery_detail_id => x_new_detail_id,
          x_return_status            => x_return_status);
      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      --{
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
      --}
      END IF;
   --}
   END IF;
   --bug# 6689448 (replenishment project): end

  /*  H integration: Pricing integration csun
    mark repirce required flag when split delivery details
   */
   l_entity_ids(1) := old_delivery_detail_rec.delivery_detail_id;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY_DETAIL',
       p_entity_ids   => l_entity_ids,
       x_return_status  => l_return_status);
   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      raise reprice_required_err;
   END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
  WHEN chk_decimal_qty_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_DECIMAL_QTY_NOT_VALID');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CHK_DECIMAL_QTY_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CHK_DECIMAL_QTY_FAILED');
    END IF;
    --
  WHEN quantity_over THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_SPLIT_EXCEED');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'QUANTITY_OVER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:QUANTITY_OVER');
    END IF;
    --
  WHEN zero_qty THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_NO_ZERO_NUM');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'ZERO_QTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ZERO_QTY');
    END IF;
    --
  WHEN negative_qty THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_NO_NEG_NUM');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'NEGATIVE_QTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NEGATIVE_QTY');
    END IF;
    --
  WHEN reprice_required_err THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'REPRICE_REQUIRED_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REPRICE_REQUIRED_ERR');
    END IF;
    --
  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END SPLIT_DELIVERY_DETAILS;

/*****************************************************************
  Description :-

  Currently being used values of p_manual_split are

NULL - default, normal mode of splitting backordered quantity
     then shipped quantity
Y - split staged quantity
C - split shipped quantity then backordered quantity (from packing code)
B - called from update_inventory_info for OPM's use
M - called from update_inventory_info for OPM's use
S - called from update_inventory_info for OPM's use
U - called from update_inventory_info for OPM's use

*******************************************************************/

/*****************************************************
-----   SPLIT_DETAIL_INT api
*****************************************************/
-- HW OPMCONV. Removed p_process_flag
PROCEDURE Split_Detail_INT(
         p_old_delivery_detail_rec    IN  SplitDetailRecType,
         p_new_source_line_id  IN  NUMBER  ,
         p_quantity_to_split   IN  NUMBER,
         p_quantity_to_split2  IN  NUMBER   ,
         p_unassign_flag     IN  VARCHAR2 ,
         p_converted_flag   IN  VARCHAR2 ,
         p_manual_split   IN  VARCHAR2 ,
         p_split_sn     IN  VARCHAR2 ,
         x_split_detail_id   OUT NOCOPY  NUMBER,
         x_return_status     OUT NOCOPY  VARCHAR2)
IS
l_new_delivery_detail_id number;
-- HW OPMCONV. Removed OPM variables

-- HW OPMCONV. Removed format of 19,9
l_qty2            NUMBER;
l_split_shipped_qty2      NUMBER(19,9):= NULL;
-- HW BUG#:1636578 variable to calculate new qty2
l_new_req_qty2 NUMBER;
-- HW OPMCONV. Removed format of 19,9
l_original_shipped_qty2    NUMBER := NULL;

l_new_req_qty   NUMBER;
l_new_pick_qty  NUMBER;
-- HW OPMCONV. No need to use l_new_pick_qty2
--l_new_pick_qty2 NUMBER;

l_delivery_id  number;
l_parent_delivery_detail_id number;
assignment number;
l_delivery_assignment_id number;
detail_rowid VARCHAR2(30);
assignment_rowid VARCHAR2(30);
total number;
l_cr_dt_status varchar2(30);
l_cr_assg_status varchar2(30);
l_output_quantity number;
l_qty_return_status varchar2(30);
new_det_wt_vol_failed exception;
old_det_wt_vol_failed exception;
l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
l_delivery_details_info WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_split_weight number;
l_split_volume number;
l_split_return_status varchar2(30);
l_shipped_quantity     NUMBER := NULL;
l_old_stage_qty      NUMBER := NULL;
l_ser_qty          NUMBER := NULL;

l_original_req_qty   NUMBER := NULL;
l_original_req_qty2  NUMBER := NULL;
l_original_picked_qty  NUMBER := NULL;
l_original_picked_qty2   NUMBER := NULL;
l_original_recvd_qty   NUMBER := NULL;
l_original_recvd_qty2  NUMBER := NULL;
l_original_rtv_qty   NUMBER := NULL;
l_original_rtv_qty2  NUMBER := NULL;
l_split_req_qty  NUMBER := NULL;
l_split_req_qty2   NUMBER := NULL;
l_split_picked_qty   NUMBER := NULL;
l_split_picked_qty2  NUMBER := NULL;
l_split_recvd_qty  NUMBER := NULL;
l_split_recvd_qty2   NUMBER := NULL;
l_split_rtv_qty  NUMBER := NULL;
l_split_rtv_qty2   NUMBER := NULL;
l_original_shipped_qty   NUMBER := NULL;
l_original_cc_qty     NUMBER := NULL;
l_split_shipped_qty  NUMBER := NULL;
l_split_cc_qty      NUMBER := NULL;
-- HW OPMCONV. Removed format of 19,9
l_split_cc_qty2    NUMBER := NULL;
-- HW OPMCONV. Removed format of 19,9
l_original_cc_qty2     NUMBER := NULL;
l_return_status     VARCHAR2(30);
-- J: W/V Changes
l_total_gross_wt NUMBER;
l_total_net_wt   NUMBER;
l_total_vol      NUMBER;
l_org_wv_qty     NUMBER;
l_new_wv_qty     NUMBER;

-- HW OPMCONV. Removed OPM excpetion


l_inv_controls_rec   WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;

WSH_CREATE_DET_ERR EXCEPTION;
WSH_SN_SPLIT_ERR        EXCEPTION;

l_updated_delivery_detail_rec          SplitDetailRecType;

l_detail_tab WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs     VARCHAR2(1); -- Return Status from DBI API
--
l_upd_wv_on_split_stg_dd VARCHAR2(1);  -- bug #7580785.
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'SPLIT_DETAIL_INT';
--
l_action VARCHAR2(100) := 'SPLIT-LINE';
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_NEW_SOURCE_LINE_ID',P_NEW_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY_TO_SPLIT',P_QUANTITY_TO_SPLIT);
      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY_TO_SPLIT2',P_QUANTITY_TO_SPLIT2);
      WSH_DEBUG_SV.log(l_module_name,'P_UNASSIGN_FLAG',P_UNASSIGN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_CONVERTED_FLAG',P_CONVERTED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_MANUAL_SPLIT',P_MANUAL_SPLIT);
      WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_SN',P_SPLIT_SN);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  /* need to validate the quantity passed meets the decimal quantity
     standard */


-- HW OPMCONV. Removed branching
  l_qty2 := p_quantity_to_split2;


IF NVL(p_old_delivery_detail_rec.line_direction,'O') IN ('O','IO') -- J-IB-NPARIKH
THEN
--{

    -- For bug 1307771. If shipped quantity is NULL.  Then leave the new
    -- shipped quantity to be NULL
  IF (p_old_delivery_detail_rec.shipped_quantity IS NULL AND p_old_delivery_detail_rec.cycle_count_quantity IS NULL) THEN
  l_split_shipped_qty := NULL;
  l_split_cc_qty := NULL;
  l_split_shipped_qty2 :=NULL;
  l_split_cc_qty2 := NULL;
    IF l_debug_on THEN
 	WSH_DEBUG_SV.log(l_module_name,' p_old_delivery_detail_rec.shipped_quantity ',p_old_delivery_detail_rec.shipped_quantity);
 	WSH_DEBUG_SV.log(l_module_name,' p_old_delivery_detail_rec.cycle_count_quantity ',p_old_delivery_detail_rec.cycle_count_quantity );
    END IF;
  ELSIF (p_manual_split = 'C') THEN

    l_split_shipped_qty := LEAST(p_old_delivery_detail_rec.shipped_quantity,
                   p_quantity_to_split);
  l_split_shipped_qty2 := LEAST(p_old_delivery_detail_rec.shipped_quantity2,
                  p_quantity_to_split2);
    l_split_cc_qty := LEAST(p_old_delivery_detail_rec.cycle_count_quantity,
                (p_quantity_to_split - nvl(l_split_shipped_qty,0)));
  l_split_cc_qty2 := LEAST(p_old_delivery_detail_rec.cycle_count_quantity2,
               (p_quantity_to_split2 - NVL(l_split_shipped_qty2,0)));

  l_original_shipped_qty := p_old_delivery_detail_rec.shipped_quantity     -
 l_split_shipped_qty;
  l_original_cc_qty   := p_old_delivery_detail_rec.cycle_count_quantity   -
 l_split_cc_qty;
  l_original_shipped_qty2 := p_old_delivery_detail_rec.shipped_quantity2   -
 l_split_shipped_qty2;
  l_original_cc_qty2    := p_old_delivery_detail_rec.cycle_count_quantity2 -
 l_split_cc_qty2;

 ELSIF (p_manual_split = 'Y') THEN

  /* bug 1983460
  if the call is from ship confirm to split only the stage quantity
   the split delivery detail has null shipped and cc quantities.
  */

    l_split_shipped_qty := NULL;
    l_split_cc_qty := NULL;
      l_split_shipped_qty2 :=NULL;
      l_split_cc_qty2 := NULL;

  /* bug 1983460
  since the split shipped and split cc quantities are null, we should
  leave the original shipped and original cc quantities as they are.
  */

  l_original_shipped_qty := p_old_delivery_detail_rec.shipped_quantity;
  l_original_cc_qty   := p_old_delivery_detail_rec.cycle_count_quantity;
  l_original_shipped_qty2 := p_old_delivery_detail_rec.shipped_quantity2;

  l_original_cc_qty2    := p_old_delivery_detail_rec.cycle_count_quantity2;
    IF l_debug_on THEN
 	WSH_DEBUG_SV.log(l_module_name,' l_split_cc_qty ',l_split_cc_qty);
 	WSH_DEBUG_SV.log(l_module_name,' l_split_cc_qty2 ',l_split_cc_qty2 );
    END IF;

  ELSE
  -- use cc qty to split p_quantity_to_split before we use shipped qty to complete the quantity split
  --  (This takes care of splitting lines to backorder/cycle-count, for example.)
  -- assumption: the quantities' relationships are valid

  l_split_cc_qty  := LEAST(p_old_delivery_detail_rec.cycle_count_quantity,   p_quantity_to_split);
  l_split_cc_qty2 := LEAST(p_old_delivery_detail_rec.cycle_count_quantity2,  p_quantity_to_split2);

  -- fail-safe: NVL to ensure that shipped qtys can still be split even if cc qtys are NULL
  l_split_shipped_qty  := LEAST(p_old_delivery_detail_rec.shipped_quantity,  (p_quantity_to_split  - NVL(l_split_cc_qty,0)));
  l_split_shipped_qty2 := LEAST(p_old_delivery_detail_rec.shipped_quantity2, (p_quantity_to_split2 - NVL(l_split_cc_qty2,0)));

  -- update original line's quantities accordingly
  l_original_shipped_qty := p_old_delivery_detail_rec.shipped_quantity     - l_split_shipped_qty;
  l_original_cc_qty   := p_old_delivery_detail_rec.cycle_count_quantity   - l_split_cc_qty;

  l_original_shipped_qty2 := p_old_delivery_detail_rec.shipped_quantity2   - l_split_shipped_qty2;
  l_original_cc_qty2    := p_old_delivery_detail_rec.cycle_count_quantity2 - l_split_cc_qty2;
  END IF;

  --
 /*
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.INITIALIZE_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_DETAILS_PKG.initialize_detail(
              p_delivery_detail_rec  =>  l_delivery_details_info);
  */

  IF p_old_delivery_detail_rec.picked_quantity IS NULL THEN
  l_delivery_details_info.requested_quantity := p_quantity_to_split;
  ELSE
  l_delivery_details_info.requested_quantity := LEAST(p_old_delivery_detail_rec.requested_quantity, p_quantity_to_split);
  l_delivery_details_info.picked_quantity := p_quantity_to_split;
-- HW OPM for OM changes
   l_delivery_details_info.requested_quantity2 := LEAST(p_old_delivery_detail_rec.requested_quantity2, p_quantity_to_split2);
 --  l_delivery_details_info.picked_quantity2  := nvl(NVL(l_qty2,l_new_pick_qty2),FND_API.G_MISS_NUM);
-- HW OPMCONV. No need to use l_new_pick_qty2
  l_delivery_details_info.picked_quantity2  := nvl(l_qty2,FND_API.G_MISS_NUM);
  END IF;

   IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, ' l_delivery_details_info.requested_quantity2',l_delivery_details_info.requested_quantity2);
   END IF;

   --Bug 7291415. 0 to be considered as valid value. Following IF condition modified.
   --IF ( NVL(l_qty2, 0) = 0  OR l_qty2 < 0 ) THEN
  IF ( NVL(l_qty2, -999) = -999  OR l_qty2 < 0 ) THEN
    l_delivery_details_info.requested_quantity2 := FND_API.G_MISS_NUM;
  ELSE
    l_delivery_details_info.requested_quantity2 := l_qty2;
  END IF;
  --
  --
-- J-IB-NPARIKH-{
  l_original_req_qty     := GREATEST(p_old_delivery_detail_rec.requested_quantity
                            - l_delivery_details_info.requested_quantity, 0);
  l_original_req_qty2    := GREATEST(p_old_delivery_detail_rec.requested_quantity2 - l_qty2, 0);
  l_original_picked_qty  := p_old_delivery_detail_rec.picked_quantity - p_quantity_to_split;
  --l_original_picked_qty2 := p_old_delivery_detail_rec.picked_quantity2 - nvl(l_qty2,l_new_pick_qty2);
  l_original_picked_qty2 := p_old_delivery_detail_rec.picked_quantity2 - l_qty2;
  --
  l_original_recvd_qty   := p_old_delivery_detail_rec.received_quantity;
  l_original_recvd_qty2  := p_old_delivery_detail_rec.received_quantity2;
  l_split_recvd_qty      := NULL;
  l_split_recvd_qty2     := NULL;
  -- J-IB-NPARIKH-}


--}
  IF l_debug_on THEN
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_req_qty ',l_original_req_qty);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_req_qty2 ',l_original_req_qty2);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_picked_qty ',l_original_picked_qty);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_picked_qty2 ',l_original_picked_qty2);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_shipped_qty ',l_original_shipped_qty);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_shipped_qty2 ',l_original_shipped_qty2);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_recvd_qty ',l_original_recvd_qty);
 	WSH_DEBUG_SV.log(l_module_name, ' l_original_recvd_qty2 ',l_original_recvd_qty2);
  END IF;
ELSE  --    -- J-IB-NPARIKH
--{
				--
				-- For inbound and drop-ship lines,
				-- calculate quantities for new(child) line and original line
				-- For new line, quantities are
				--               LEAST( qty. on original line, input quantity to be split)
				-- For original line, quantities are
				--               GREATEST( qty. on original line -  qty. on new line, 0 )
				-- For a line with picked=12, requested=10, if we split 11 then
				--    new line      : picked=11, requested=10
				--    original line : picked=1, requested=0
				--
				--
    l_split_cc_qty          := NULL;
    l_split_cc_qty2         := NULL;
    l_split_rtv_qty       := least(p_old_delivery_detail_rec.returned_quantity, p_quantity_to_split);
    l_split_recvd_qty       := least(p_old_delivery_detail_rec.received_quantity, p_quantity_to_split);
    l_split_shipped_qty     := least(p_old_delivery_detail_rec.shipped_quantity,  p_quantity_to_split);
    l_split_picked_qty      := least(p_old_delivery_detail_rec.picked_quantity,   p_quantity_to_split);
    l_split_req_qty         := least(p_old_delivery_detail_rec.requested_quantity,p_quantity_to_split);
    --
    l_split_rtv_qty2      := least(p_old_delivery_detail_rec.returned_quantity2, l_qty2);
    l_split_recvd_qty2      := least(p_old_delivery_detail_rec.received_quantity2, l_qty2);
    l_split_shipped_qty2    := least(p_old_delivery_detail_rec.shipped_quantity2,  l_qty2);
    l_split_picked_qty2     := least(p_old_delivery_detail_rec.picked_quantity2,   l_qty2);
    l_split_req_qty2        := least(p_old_delivery_detail_rec.requested_quantity2,l_qty2);
    --
    --
    l_delivery_details_info.requested_quantity  := nvl(l_split_req_qty, FND_API.G_MISS_NUM);
    l_delivery_details_info.requested_quantity2 := nvl(l_split_req_qty2,FND_API.G_MISS_NUM);
    l_delivery_details_info.picked_quantity     := nvl(l_split_picked_qty, FND_API.G_MISS_NUM);
    l_delivery_details_info.picked_quantity2    := nvl(l_split_picked_qty2,FND_API.G_MISS_NUM);
    l_delivery_details_info.shipped_quantity  := nvl(l_split_shipped_qty, FND_API.G_MISS_NUM);
    l_delivery_details_info.shipped_quantity2 := nvl(l_split_shipped_qty2,FND_API.G_MISS_NUM);
    l_delivery_details_info.received_quantity  := nvl(l_split_recvd_qty, FND_API.G_MISS_NUM);
    l_delivery_details_info.received_quantity2 := nvl(l_split_recvd_qty2,FND_API.G_MISS_NUM);
    l_delivery_details_info.returned_quantity  := nvl(l_split_rtv_qty, FND_API.G_MISS_NUM);
    l_delivery_details_info.returned_quantity2 := nvl(l_split_rtv_qty2,FND_API.G_MISS_NUM);
    --
    --
    l_original_shipped_qty  := GREATEST(
                                        p_old_delivery_detail_rec.shipped_quantity
                                        - NVL(l_split_shipped_qty,0),
                                        0
                                        );
    l_original_cc_qty       := GREATEST(
                                        p_old_delivery_detail_rec.cycle_count_quantity
                                        - NVL(l_split_cc_qty,0),
                                        0
                                        );
    l_original_shipped_qty2 := GREATEST(
                                        p_old_delivery_detail_rec.shipped_quantity2
                                        - NVL(l_split_shipped_qty2,0),
                                        0
                                        );
    l_original_cc_qty2      := GREATEST(
                                        p_old_delivery_detail_rec.cycle_count_quantity2
                                        - NVL(l_split_cc_qty2,0),
                                        0
                                        );
    --
    l_original_req_qty      := GREATEST(
                                        p_old_delivery_detail_rec.requested_quantity
                                        - NVL(l_split_req_qty,0),
                                        0
                                        );
    l_original_req_qty2     := GREATEST(
                                        p_old_delivery_detail_rec.requested_quantity2
                                        - NVL(l_split_req_qty2,0),
                                        0
                                        );
    l_original_picked_qty   := GREATEST(
                                        p_old_delivery_detail_rec.picked_quantity
                                        - NVL(l_split_picked_qty,0),
                                        0
                                        );
    l_original_picked_qty2  := GREATEST(
                                        p_old_delivery_detail_rec.picked_quantity2
                                        - NVL(l_split_picked_qty2,0),
                                        0
                                        );
    l_original_recvd_qty   := GREATEST(
                                        p_old_delivery_detail_rec.received_quantity
                                        - NVL(l_split_recvd_qty,0),
                                        0
                                        );
    l_original_recvd_qty2  := GREATEST(
                                        p_old_delivery_detail_rec.received_quantity2
                                        - NVL(l_split_recvd_qty2,0),
                                        0
                                        );

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,' l_delivery_details_info.requested_quantity', l_delivery_details_info.requested_quantity);
       WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.requested_quantity2',l_delivery_details_info.requested_quantity2);
       WSH_DEBUG_SV.log(l_module_name,' l_delivery_details_info.shipped_quantity', l_delivery_details_info.shipped_quantity);
       WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.shipped_quantity2',l_delivery_details_info.shipped_quantity2);
       WSH_DEBUG_SV.log(l_module_name,' l_delivery_details_info.received_quantity', l_delivery_details_info.received_quantity);
       WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.received_quantity2',l_delivery_details_info.received_quantity2);
       WSH_DEBUG_SV.log(l_module_name,' l_delivery_details_info.returned_quantity', l_delivery_details_info.returned_quantity);
       WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.returned_quantity2',l_delivery_details_info.returned_quantity2);
       WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.picked_quantity',l_delivery_details_info.picked_quantity);
       WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.picked_quantity2',l_delivery_details_info.picked_quantity2);
       WSH_DEBUG_SV.log(l_module_name,'l_original_shipped_qty',l_original_shipped_qty);
       WSH_DEBUG_SV.log(l_module_name,'l_original_shipped_qty2',l_original_shipped_qty2);
       WSH_DEBUG_SV.log(l_module_name,'l_original_cc_qty',l_original_cc_qty);
       WSH_DEBUG_SV.log(l_module_name,'l_original_cc_qty2',l_original_cc_qty2);
       WSH_DEBUG_SV.log(l_module_name,'l_original_req_qty',l_original_req_qty);
       WSH_DEBUG_SV.log(l_module_name,'l_original_req_qty2',l_original_req_qty2);
       WSH_DEBUG_SV.log(l_module_name,'l_original_picked_qty',l_original_picked_qty);
       WSH_DEBUG_SV.log(l_module_name,'l_original_picked_qty2',l_original_picked_qty2);
       WSH_DEBUG_SV.log(l_module_name,'l_original_recvd_qty',l_original_recvd_qty);
       WSH_DEBUG_SV.log(l_module_name,'l_original_recvd_qty2',l_original_recvd_qty2);
       WSH_DEBUG_SV.log(l_module_name,'l_original_rtv_qty',l_original_rtv_qty);
       WSH_DEBUG_SV.log(l_module_name,'l_original_rtv_qty2',l_original_rtv_qty2);
    END IF;

  --
--}
END IF;

-- Bug 2181132 in current code for single line
-- donot need the check for null
  l_delivery_details_info.source_line_set_id :=
          p_old_delivery_detail_rec.source_line_set_id;

  IF p_new_source_line_id IS NOT NULL THEN
  l_delivery_details_info.source_line_id := p_new_source_line_id;
  END IF;

  -- J: W/V Changes
  IF p_old_delivery_detail_rec.wv_frozen_flag = 'Y' THEN
    l_org_wv_qty := NVL(p_old_delivery_detail_rec.received_quantity,NVL(p_old_delivery_detail_rec.shipped_quantity,NVL(p_old_delivery_detail_rec.picked_quantity, p_old_delivery_detail_rec.requested_quantity)));

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Frozen Y');
    END IF;

    IF (p_manual_split = 'Y') THEN
      -- p_manual_split is 'Y' only when splitting for staged delivery details during ship confirm
      -- Staged delivery details W/V should always be reset back to original W/V
      l_new_wv_qty := 0;
    ELSE
      SELECT NVL(decode(l_split_recvd_qty,FND_API.G_MISS_NUM,null,l_split_recvd_qty),
                      NVL(decode(l_split_shipped_qty,FND_API.G_MISS_NUM,null,l_split_shipped_qty),
                          NVL(decode(l_delivery_details_info.picked_quantity,FND_API.G_MISS_NUM,null,l_delivery_details_info.picked_quantity),
                              decode(l_delivery_details_info.requested_quantity,FND_API.G_MISS_NUM,null,l_delivery_details_info.requested_quantity))))
      INTO   l_new_wv_qty
      FROM   dual;
    END IF;

    IF l_org_wv_qty <> 0 THEN
      l_delivery_details_info.gross_weight :=  round( (l_new_wv_qty/l_org_wv_qty) * p_old_delivery_detail_rec.gross_weight, 5);
      l_delivery_details_info.net_weight   :=  round( (l_new_wv_qty/l_org_wv_qty) * p_old_delivery_detail_rec.net_weight, 5);
      l_delivery_details_info.volume       :=  round( (l_new_wv_qty/l_org_wv_qty) * p_old_delivery_detail_rec.volume, 5);
    ELSE
      l_delivery_details_info.gross_weight := 0;
      l_delivery_details_info.net_weight   := 0;
      l_delivery_details_info.volume       := 0;
    END IF;


  END IF;

  IF (l_split_shipped_qty is not null and l_split_shipped_qty = 0) OR (p_manual_split = 'Y') THEN
    l_delivery_details_info.wv_frozen_flag  := 'N';
  ELSE
    l_delivery_details_info.wv_frozen_flag  := p_old_delivery_detail_rec.wv_frozen_flag;
  END IF;
  l_delivery_details_info.weight_uom_code := p_old_delivery_detail_rec.weight_uom_code;
  l_delivery_details_info.volume_uom_code := p_old_delivery_detail_rec.volume_uom_code;

  l_delivery_details_info.shipped_quantity := nvl(l_split_shipped_qty,FND_API.G_MISS_NUM);
  IF ( NVL(l_split_shipped_qty2, 0) = 0 ) THEN
  l_delivery_details_info.shipped_quantity2 := FND_API.G_MISS_NUM;
  ELSE
  l_delivery_details_info.shipped_quantity2 := l_split_shipped_qty2;
  END IF;
  --
  --
  l_delivery_details_info.received_quantity  := nvl(l_split_recvd_qty, FND_API.G_MISS_NUM);
  l_delivery_details_info.received_quantity2 := nvl(l_split_recvd_qty2,FND_API.G_MISS_NUM);
  --
  IF ( NVL(l_qty2, 0) = 0 OR l_qty2 < 0  ) THEN
  l_delivery_details_info.cancelled_quantity2 := FND_API.G_MISS_NUM;
  ELSE
  -- Bug 2116595
  l_delivery_details_info.cancelled_quantity2 := FND_API.G_MISS_NUM;
  END IF;

  l_delivery_details_info.cycle_count_quantity := nvl(l_split_cc_qty,FND_API.G_MISS_NUM);
-- HW OPMCONV. No need to fork code
--  IF ( p_process_flag = FND_API.G_TRUE ) THEN
    l_delivery_details_info.cycle_count_quantity2 := nvl(l_split_cc_qty2,FND_API.G_MISS_NUM);
--  END IF;

  -- Bug 2116595
  l_delivery_details_info.cancelled_quantity := FND_API.G_MISS_NUM;
  l_delivery_details_info.split_from_detail_id := p_old_delivery_detail_rec.delivery_detail_id;

  l_delivery_details_info.container_flag := p_old_delivery_detail_rec.container_flag;
  l_delivery_details_info.master_serial_number := FND_API.G_MISS_CHAR;
  l_delivery_details_info.serial_number := FND_API.G_MISS_CHAR;
  l_delivery_details_info.to_serial_number := FND_API.G_MISS_CHAR;
  l_delivery_details_info.transaction_temp_id := FND_API.G_MISS_NUM;
  l_delivery_details_info.last_update_date := SYSDATE;
  l_delivery_details_info.last_updated_by :=  FND_GLOBAL.USER_ID;
  l_delivery_details_info.last_update_login :=  FND_GLOBAL.LOGIN_ID;
  -- Bug 2419301
  l_delivery_details_info.oe_interfaced_flag := p_old_delivery_detail_rec.oe_interfaced_flag;

  l_new_delivery_detail_id := NULL;


  l_updated_delivery_detail_rec := p_old_delivery_detail_rec;

-- HW OPMCONV - Removed branching
  -- are there serial numbers to split?

  /* bug 1983460
   if p_manual_split is 'Y', only stage quantity is involved.
   Staged quantities can't have serial numbers and hence no need to call
  */


  IF (  p_split_sn = 'Y'
    AND NVL(p_old_delivery_detail_rec.shipped_quantity, 0) > NVL(l_original_shipped_qty, 0)
    AND ( (p_old_delivery_detail_rec.transaction_temp_id IS NOT NULL)
       OR (p_old_delivery_detail_rec.serial_number IS NOT NULL)
      )
  AND (NVL(p_manual_split,'!') <> 'Y')
    ) THEN

    Split_Serial_Numbers_INT(
       x_old_detail_rec     => l_updated_delivery_detail_rec,
       x_new_delivery_detail_rec => l_delivery_details_info,
       p_old_shipped_quantity => l_original_shipped_qty,
       p_new_shipped_quantity => l_split_shipped_qty,
       x_return_status       => l_split_return_status);

    IF (l_split_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    RAISE wsh_sn_split_err;
    END IF;

  END IF; -- are there serial numbers to split?

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_NEW_DETAIL_FROM_OLD',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_DETAILS_PKG.create_new_detail_from_old(
              p_delivery_detail_rec  =>  l_delivery_details_info,
              p_delivery_detail_id    =>   p_old_delivery_detail_rec.delivery_detail_id,
              x_row_id          =>   detail_rowid,
              x_delivery_detail_id    =>   l_new_delivery_detail_id,
              x_return_status      =>  l_cr_dt_status);

              IF l_cr_dt_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE WSH_CREATE_DET_ERR;
              END IF;


  /* call wv util to calculate the weight and volume of the new detail */
  -- J: W/V Changes
  l_upd_wv_on_split_stg_dd := 'N'; -- bug # 7580785
  IF p_old_delivery_detail_rec.wv_frozen_flag = 'N' THEN
  --{
      -- bug # 7580785 :
      -- During Partial Shipping with the remain qty as staged, w/v value should not be
      -- deducted again from the original line since during entering shipped_quantity
      -- w/v has been calculated for the original line but W/V should be calculated on split staged DD.
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_WV_UTILS.Detail_Weight_Volume(
          p_delivery_detail_id => l_new_delivery_detail_id,
          p_update_flag        => 'Y',
          x_net_weight         => l_split_weight,
          x_volume             => l_split_volume,
          x_return_status      => l_split_return_status);
      IF (l_split_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          RAISE new_det_wt_vol_failed;
      END IF;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, ' After Update w/v');
          WSH_DEBUG_SV.log(l_module_name, 'l_split_weight',l_split_weight);
          WSH_DEBUG_SV.log(l_module_name, 'l_split_volume',l_split_volume);
          WSH_DEBUG_SV.log(l_module_name, 'p_manual_split',p_manual_split);
      END IF;
      -- Bug 4416863
      -- During Partial Shipping with the remain qty as staged, w/v value should not be
      -- deducted again from the original line since during entering shipped_quantity
      -- w/v has been calculated for the original line.
      IF (p_manual_split = 'Y') THEN
          l_total_net_wt   := 0;
          l_total_gross_wt := 0;
          l_total_vol      := 0;
          -- bug # 7580785: Needs to post the w/v changes to delivery after creating assignment records
          l_upd_wv_on_split_stg_dd := 'Y';
      ELSE
      -- end bug 4416863
          l_total_net_wt   := l_split_weight;
          l_total_gross_wt := l_split_weight;
          l_total_vol      := l_split_volume;
      END IF;
  ELSE
     l_total_net_wt   := l_delivery_details_info.net_weight;
     l_total_gross_wt := l_delivery_details_info.gross_weight;
     l_total_vol      := l_delivery_details_info.volume;
  END IF;

  IF (p_unassign_flag = 'N') THEN
    l_delivery_assignments_info.type := 'S';
    l_delivery_assignments_info.delivery_id := p_old_delivery_detail_rec.delivery_id;
    l_delivery_assignments_info.parent_delivery_detail_id := p_old_delivery_detail_rec.parent_delivery_detail_id;
    IF p_old_delivery_detail_rec.wda_type = 'C' THEN
       l_delivery_assignments_info.type := 'O';
       l_delivery_assignments_info.parent_delivery_detail_id := NULL;
    END IF;
  ELSE
    l_delivery_assignments_info.delivery_id := NULL;
    l_delivery_assignments_info.parent_delivery_detail_id := NULL;
  END IF;

  l_delivery_assignments_info.delivery_detail_id := l_new_delivery_detail_id;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_ASSIGNMENTS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_delivery_details_pkg.create_delivery_assignments(
      l_delivery_assignments_info,
      assignment_rowid,
      l_delivery_assignment_id,
      l_cr_assg_status
      );

  -- Bug 3724578 : Return back to the caller if any error occurs
  --              while creating the delivery detail assignments
  --- Message will be set in  create_delivery_assignments
  IF l_cr_assg_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR,
                          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                        ) THEN
     x_return_status := l_cr_assg_status;
    return;
  END IF;

  -- K: MDC: We need to create consolidation records if necessary.

  IF (p_unassign_flag = 'N') AND (p_old_delivery_detail_rec.wda_type = 'C') THEN

      l_delivery_assignments_info.parent_delivery_id := p_old_delivery_detail_rec.parent_delivery_id;
      l_delivery_assignments_info.parent_delivery_detail_id := p_old_delivery_detail_rec.parent_delivery_detail_id;
      l_delivery_assignments_info.type := 'C';

      wsh_delivery_details_pkg.create_delivery_assignments(
      l_delivery_assignments_info,
      assignment_rowid,
      l_delivery_assignment_id,
      l_cr_assg_status
      );

      IF l_cr_assg_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR,
                          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                        ) THEN
         x_return_status := l_cr_assg_status;
         return;
      END IF;

  END IF;



/*2442099*/
  Log_Exceptions(p_old_delivery_detail_rec.delivery_detail_id,l_new_delivery_detail_id,l_delivery_assignments_info.delivery_id,l_action);

  /* NC - Added the following for OPM  BUG#1675561 */
  /* LG BUG#:2005977 */
  /* LG new */

/* HW OPMCONV - Removed branching
  /* Bug 2177410, also update net_weight and volume of original delivery detail
   because non item does not use WSH_WV_UTILS.Detail_Weight_Volume to
   adjust the net_weight and volume  */

  x_split_detail_id := l_new_delivery_detail_id;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'Before Update wsh_delivery_details');
     WSH_DEBUG_SV.log(l_module_name, 'serial_number',l_updated_delivery_detail_rec.serial_number);
     WSH_DEBUG_SV.log(l_module_name, 'to_serial_number',l_updated_delivery_detail_rec.to_serial_number);
     WSH_DEBUG_SV.log(l_module_name, 'transaction_temp_id',l_updated_delivery_detail_rec.transaction_temp_id);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_req_qty ',l_original_req_qty);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_req_qty2 ',l_original_req_qty2);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_picked_qty ',l_original_picked_qty);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_picked_qty2 ',l_original_picked_qty2);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_shipped_qty ',l_original_shipped_qty);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_shipped_qty2 ',l_original_shipped_qty2);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_recvd_qty ',l_original_recvd_qty);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_recvd_qty2 ',l_original_recvd_qty2);--
     WSH_DEBUG_SV.log(l_module_name, ' l_original_rtv_qty ',l_original_rtv_qty);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_rtv_qty2 ',l_original_rtv_qty2);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_cc_qty ',l_original_cc_qty);
     WSH_DEBUG_SV.log(l_module_name, ' l_original_cc_qty2 ',l_original_cc_qty2);
  END IF;

  UPDATE wsh_delivery_details
  SET requested_quantity    = l_original_req_qty,    -- J-IB-NPARIKH, GREATEST(requested_quantity - l_delivery_details_info.requested_quantity, 0),
      requested_quantity2   = l_original_req_qty2,    -- J-IB-NPARIKH, GREATEST(requested_quantity2 - l_qty2, 0),
      picked_quantity      = l_original_picked_qty,    -- J-IB-NPARIKH, picked_quantity - p_quantity_to_split,
      picked_quantity2    = l_original_picked_qty2,    -- J-IB-NPARIKH, picked_quantity2 - nvl(l_qty2,l_new_pick_qty2),
    shipped_quantity    = l_original_shipped_qty,
    shipped_quantity2  = l_original_shipped_qty2,
      received_quantity    = l_original_recvd_qty,   -- J-IB-NPARIKH
      received_quantity2  = l_original_recvd_qty2,       -- J-IB-NPARIKH
      --returned_quantity    = l_original_rtv_qty,   -- J-IB-NPARIKH
      --returned_quantity2  = l_original_rtv_qty2,       -- J-IB-NPARIKH
    cycle_count_quantity  = l_original_cc_qty,
    cycle_count_quantity2 = l_original_cc_qty2,
    serial_number  = decode(l_updated_delivery_detail_rec.serial_number,FND_API.G_MISS_CHAR,NULL,
                                          NULL,serial_number,l_updated_delivery_detail_rec.serial_number),
    to_serial_number  = decode(l_updated_delivery_detail_rec.to_serial_number,FND_API.G_MISS_CHAR,NULL,
                                          NULL,to_serial_number,l_updated_delivery_detail_rec.to_serial_number),
    transaction_temp_id  = decode(l_updated_delivery_detail_rec.transaction_temp_id, FND_API.G_MISS_NUM,NULL,
                                          NULL,transaction_temp_id,l_updated_delivery_detail_rec.transaction_temp_id),
-- J: W/V Changes
    gross_weight          =  gross_weight - l_total_gross_wt,
    net_weight            =  net_weight - l_total_net_wt,
    volume                =  volume - l_total_vol,
-- End J: W/V Changes
    last_update_date   = SYSDATE,
    last_updated_by = FND_GLOBAL.USER_ID,
    last_update_login  = FND_GLOBAL.LOGIN_ID
  WHERE delivery_detail_id = p_old_delivery_detail_rec.delivery_detail_id;

  -- DBI Project
  -- Update of wsh_delivery_details where requested_quantity/released_status
  -- are changed, call DBI API after the update.
  -- This API will also check for DBI Installed or not
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_old_delivery_detail_rec.delivery_detail_id);
  END IF;
  l_detail_tab(1) := p_old_delivery_detail_rec.delivery_detail_id;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_detail_tab,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    x_return_status := l_dbi_rs;
    -- just pass this return status to caller API
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;
  -- End of Code for DBI Project
  --
  -- bug # 7580785 : W/V should be populated on delivery.
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_upd_wv_on_split_stg_dd',l_upd_wv_on_split_stg_dd);
  END IF;
  IF (l_upd_wv_on_split_stg_dd = 'Y') THEN
  --{
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id  => l_new_delivery_detail_id,
          p_diff_gross_wt       => l_split_weight,
          p_diff_net_wt         => l_split_weight,
          p_diff_fill_volume    => NULL,
          p_diff_volume         => l_split_volume,
          x_return_status       => l_split_return_status);
      IF (l_split_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          RAISE new_det_wt_vol_failed;
      END IF;
  --}
  END IF;
  -- Bug # 7580785 : end
  --
  -- J: W/V Changes
  -- Decrement the DD W/V from parent if p_unassign_flag is 'Y'
  IF (p_unassign_flag = 'Y') THEN
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id => p_old_delivery_detail_rec.delivery_detail_id,
          p_diff_gross_wt      => -1 * l_total_gross_wt,
          p_diff_net_wt        => -1 * l_total_net_wt,
          p_diff_fill_volume   => -1 * l_total_vol,
          x_return_status      => l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status);
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return;
    END IF;
  END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
-- HW OPMCONV. Removed OPM exception

  WHEN old_det_wt_vol_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_WT_VOL_FAILED');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',  p_old_delivery_detail_rec.delivery_detail_id);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'OLD_DET_WT_VOL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OLD_DET_WT_VOL_FAILED');
    END IF;
    --
  WHEN new_det_wt_vol_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_DET_WT_VOL_FAILED');
    FND_MESSAGE.SET_TOKEN('DETAIL_ID',  l_new_DELIVERY_DETAIL_ID);
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'NEW_DET_WT_VOL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NEW_DET_WT_VOL_FAILED');
    END IF;
    --
  WHEN WSH_SN_SPLIT_ERR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_SN_SPLIT_ERR');
    wsh_util_core.add_message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SN_SPLIT_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_SN_SPLIT_ERR');
    END IF;
    --
  WHEN WSH_CREATE_DET_ERR THEN
    x_return_status := l_cr_dt_status;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SN_SPLIT_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DET_ERR');
    END IF;

        WHEN others THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DETAIL_INT',l_module_name);
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                END IF;
                --
END SPLIT_DETAIL_INT;

/*****************************************************
-----   SPLIT_SERIAL_NUMBERS_INT api
*****************************************************/

PROCEDURE Split_Serial_Numbers_INT(
  x_old_detail_rec      IN OUT  NOCOPY  SplitDetailRecType,
    x_new_delivery_detail_rec IN OUT  NOCOPY  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
    p_old_shipped_quantity  IN    NUMBER,
    p_new_shipped_quantity  IN    NUMBER,
    x_return_status      OUT NOCOPY      VARCHAR2) IS

  l_ser_qty  NUMBER;

  l_real_serial_prefix WSH_DELIVERY_DETAILS.SERIAL_NUMBER%TYPE;
  l_prefix_length   NUMBER;
  l_fm_numeric     NUMBER;
  l_to_numeric     NUMBER;
  l_range_count   NUMBER;
  l_qty_to_split     NUMBER;
  l_new_sn       WSH_DELIVERY_DETAILS.SERIAL_NUMBER%TYPE;
  l_new_to_sn     WSH_DELIVERY_DETAILS.TO_SERIAL_NUMBER%TYPE;
  l_old_to_sn     WSH_DELIVERY_DETAILS.TO_SERIAL_NUMBER%TYPE;
  l_transaction_temp_id  NUMBER := NULL;
  l_success             NUMBER;

-- Bug 3782838
  CURSOR  c_sn_ranges(x_tt_id IN NUMBER) IS
  SELECT  msnt.rowid,
          msnt.transaction_temp_id,
          msnt.fm_serial_number,
          msnt.to_serial_number,
          msnt.attribute_category,
          msnt.attribute1,
          msnt.attribute2,
          msnt.attribute3,
          msnt.attribute4,
          msnt.attribute5,
          msnt.attribute6,
          msnt.attribute7,
          msnt.attribute8,
          msnt.attribute9,
          msnt.attribute10,
          msnt.attribute11,
          msnt.attribute12,
          msnt.attribute13,
          msnt.attribute14,
          msnt.attribute15,
          msnt.dff_updated_flag
  FROM  mtl_serial_numbers_temp msnt
  WHERE   msnt.transaction_temp_id = x_tt_id
  ORDER BY  msnt.fm_serial_number DESC;

  CURSOR c_temp_id IS
  select mtl_material_transactions_s.nextval
  from dual;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'SPLIT_SERIAL_NUMBERS_INT';
--
BEGIN

  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_OLD_SHIPPED_QUANTITY',P_OLD_SHIPPED_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_NEW_SHIPPED_QUANTITY',P_NEW_SHIPPED_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'old serial_number',
                                       x_old_detail_rec.serial_number);
      WSH_DEBUG_SV.log(l_module_name,'old to_serial_number',
                                       x_old_detail_rec.to_serial_number);
      WSH_DEBUG_SV.log(l_module_name,'old transaction_temp_id',
                                       x_old_detail_rec.transaction_temp_id);
      WSH_DEBUG_SV.log(l_module_name,'old shipped_quantity',
                                       x_old_detail_rec.shipped_quantity);
      WSH_DEBUG_SV.log(l_module_name,'old delivery_detail_id',
                                       x_old_detail_rec.delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name,'old organization_id',
                                       x_old_detail_rec.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'old inventory_item_id',
                                       x_old_detail_rec.inventory_item_id);

  END IF;
  --
  IF p_old_shipped_quantity = 0 THEN
  -- new delivery line has the full shipped quantity and gets all serial number info

  x_new_delivery_detail_rec.serial_number     := x_old_detail_rec.serial_number;
  x_new_delivery_detail_rec.to_serial_number  := x_old_detail_rec.to_serial_number;
  x_new_delivery_detail_rec.transaction_temp_id := x_old_detail_rec.transaction_temp_id;

  x_old_detail_rec.serial_number     := FND_API.G_MISS_CHAR;
  x_old_detail_rec.to_serial_number  :=  FND_API.G_MISS_CHAR;
  x_old_detail_rec.transaction_temp_id := FND_API.G_MISS_NUM;

  ELSIF p_old_shipped_quantity < x_old_detail_rec.shipped_quantity THEN
  -- we are reducing old shipped quantity

  IF x_old_detail_rec.transaction_temp_id IS NULL THEN

    IF x_old_detail_rec.to_serial_number IS NOT NULL THEN

    -- we have one range SERIAL_NUMBER - TO_SERIAL_NUMBER to split
    l_real_serial_prefix := RTRIM(x_old_detail_rec.serial_number,
                    '0123456789');
    l_prefix_length   := NVL(LENGTH(l_real_serial_prefix), 0);
    l_fm_numeric     := TO_NUMBER(SUBSTR(x_old_detail_rec.serial_number,
                       l_prefix_length + 1));
    l_to_numeric     := TO_NUMBER(SUBSTR(x_old_detail_rec.to_serial_number,
                         l_prefix_length + 1));
    l_range_count   := l_to_numeric - l_fm_numeric + 1;

    IF l_range_count > p_old_shipped_quantity THEN
      -- we need to split the serial number range.
      l_qty_to_split   := l_range_count - p_old_shipped_quantity;

      l_new_to_sn := x_old_detail_rec.to_serial_number;
      l_old_to_sn := l_real_serial_prefix
             || LPAD(TO_CHAR(l_to_numeric-l_qty_to_split),
                LENGTH(x_old_detail_rec.serial_number) - l_prefix_length,
                '0');

      l_new_sn  := l_real_serial_prefix
             || LPAD(TO_CHAR(l_to_numeric-l_qty_to_split+1),
                LENGTH(x_old_detail_rec.serial_number) - l_prefix_length,
                '0');

      -- compress range of same serial numbers to individual serial number
      IF l_old_to_sn = x_old_detail_rec.serial_number THEN
      l_old_to_sn :=  FND_API.G_MISS_CHAR;
      END IF;
      IF l_new_to_sn = l_new_sn THEN
      l_new_to_sn :=  FND_API.G_MISS_CHAR;
      END IF;

      x_old_detail_rec.to_serial_number     := l_old_to_sn;
      x_new_delivery_detail_rec.serial_number := l_new_sn;
      x_new_delivery_detail_rec.to_serial_number := l_new_to_sn;

    END IF;  -- l_range_count > p_old_shipped_quantity
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'serial_number',
                                      x_new_delivery_detail_rec.serial_number);
                   WSH_DEBUG_SV.log(l_module_name,'to_serial_number',
                                    x_new_delivery_detail_rec.to_serial_number);
                END IF;

    END IF; -- x_old_detail_rec.to_serail_number IS NULL

  ELSE

    -- we have at least one record in MTL_SERIAL_NUMBERS_TEMP
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_SERIAL_QTY',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_ser_qty := WSH_DELIVERY_DETAILS_INV.Get_Serial_Qty(
            p_organization_id => x_old_detail_rec.organization_id,
            p_delivery_detail_id => x_old_detail_rec.delivery_detail_id);
    l_qty_to_split := l_ser_qty - p_old_shipped_quantity;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'L_QTY_TO_SPLIT',l_qty_to_split);
    END IF;
    --

    IF l_qty_to_split >= 1 THEN

    IF p_new_shipped_quantity >= 1 THEN  -- Bug 3782838, Generate id for Single also
    --IF l_qty_to_split > 1 THEN
      -- more than one serial number, we need new transaction_temp_id
      OPEN  c_temp_id;
      FETCH c_temp_id INTO   l_transaction_temp_id;
      IF  c_temp_id%NOTFOUND THEN
      CLOSE c_temp_id;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status is error',x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
      CLOSE c_temp_id;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_transaction_temp_id',
                                                     l_transaction_temp_id);
                  END IF;
    END IF;
    x_new_delivery_detail_rec.transaction_temp_id := nvl(l_transaction_temp_id,FND_API.G_MISS_NUM);

    FOR c IN c_sn_ranges(x_old_detail_rec.transaction_temp_id) LOOP

      -- Bug 3782838 : Retain transaction_temp_id for single serial number
      IF (l_qty_to_split <= 0) THEN
        EXIT;  -- finished with splitting serial numbers
      END IF;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'c.to_serial_number',
                                                         c.to_serial_number);
                     WSH_DEBUG_SV.log(l_module_name,'c.fm_serial_number',
                                                         c.fm_serial_number);
                  END IF;

      -- OR condition added for bug 4424259, making l_range_count = 1 if from and to serial numbers are same.
      IF c.to_serial_number IS NULL  OR ( c.fm_serial_number = c.to_serial_number ) THEN
      l_range_count := 1;
      ELSE
      -- serial number range
      l_real_serial_prefix := RTRIM(c.fm_serial_number,
                     '0123456789');
      l_prefix_length   := NVL(LENGTH(l_real_serial_prefix), 0);
      l_fm_numeric     := TO_NUMBER(SUBSTR(c.fm_serial_number,
                        l_prefix_length + 1));
      l_to_numeric     := TO_NUMBER(SUBSTR(c.to_serial_number,
                        l_prefix_length + 1));
      l_range_count   := l_to_numeric - l_fm_numeric + 1;
      END IF; -- c.to_serial_number IS NULL
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_range_count',
                                                        l_range_count);
                     WSH_DEBUG_SV.log(l_module_name,'l_qty_to_split',
                                                        l_qty_to_split);
                  END IF;

      IF l_range_count > l_qty_to_split THEN

      l_new_to_sn := c.to_serial_number;
      l_old_to_sn := l_real_serial_prefix
               || LPAD(TO_CHAR(l_to_numeric-l_qty_to_split),
                  LENGTH(c.fm_serial_number) - l_prefix_length,
                  '0');
      l_new_sn  := l_real_serial_prefix
               || LPAD(TO_CHAR(l_to_numeric-l_qty_to_split+1),
                  LENGTH(c.fm_serial_number) - l_prefix_length,
                  '0');

      IF p_old_shipped_quantity >= 1 THEN
        -- Bug 3782838 : Retain id for single serial number
        -- update record only if old delivery line still has at least 1 to ship.
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_old_to_sn',l_old_to_sn);
        END IF;
        UPDATE mtl_serial_numbers_temp
        SET  to_serial_number = l_old_to_sn,
            serial_prefix    = TO_CHAR(l_range_count - l_qty_to_split),
            last_update_date  = SYSDATE,
          last_updated_by  = FND_GLOBAL.USER_ID,
          last_update_login   = FND_GLOBAL.LOGIN_ID
        WHERE  rowid = c.rowid;
      END IF;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'inserting into mtl_serial_numbers_temp'
                        ,l_transaction_temp_id);
      END IF;

-- Changes for 3782838
      IF l_transaction_temp_id IS NOT NULL THEN
        INSERT INTO mtl_serial_numbers_temp
          (TRANSACTION_TEMP_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           FM_SERIAL_NUMBER,
           TO_SERIAL_NUMBER,
           SERIAL_PREFIX,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           DFF_UPDATED_FLAG)
          VALUES
          (l_transaction_temp_id,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.LOGIN_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           l_new_sn,
           l_new_to_sn,
           TO_CHAR(l_qty_to_split),
           c.attribute_category,
           c.attribute1,
           c.attribute2,
           c.attribute3,
           c.attribute4,
           c.attribute5,
           c.attribute6,
           c.attribute7,
           c.attribute8,
           c.attribute9,
           c.attribute10,
           c.attribute11,
           c.attribute12,
           c.attribute13,
           c.attribute14,
           c.attribute15,
           c.dff_updated_flag
           );
-- End of changes for 3782838

                        -- bug 2740681
                              IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'Before Calling  Serial_Check.Inv_Unmark_Serial');
                               WSH_DEBUG_SV.log(l_module_name,'l_new_sn,l_new_to_sn,inventory_item_id', l_new_sn
                                                              ||','||l_new_to_sn
                                                              ||','||x_old_detail_rec.inventory_item_id);
                              END IF;
                              Serial_Check.Inv_Unmark_Serial(
                                l_new_sn,
                                l_new_to_sn,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                x_old_detail_rec.inventory_item_id);

                              IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'After Calling  Serial_Check.Inv_Unmark_Serial');
                              END IF;

                              IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'Before Calling  Serial_Check.Inv_mark_Serial');
                               WSH_DEBUG_SV.log(l_module_name,'l_new_sn',l_new_sn);
                               WSH_DEBUG_SV.log(l_module_name,'l_new_to_sn',l_new_to_sn);
                               WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',x_old_detail_rec.inventory_item_id);
                               WSH_DEBUG_SV.log(l_module_name,'organization_id',x_old_detail_rec.organization_id);
                               WSH_DEBUG_SV.log(l_module_name,'l_transaction_temp_id',l_transaction_temp_id);
                              END IF;
                              Serial_Check.Inv_Mark_Serial(
                                l_new_sn,
                                l_new_to_sn,
                                x_old_detail_rec.inventory_item_id,
                                x_old_detail_rec.organization_id,
                                l_transaction_temp_id,
                                l_transaction_temp_id,
                                l_transaction_temp_id,
                                l_success);
                              IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'After Serial_Check.Inv_mark_Serial l_success',l_success);
                              END IF;

                              IF l_success < 0 THEN
                                 FND_MESSAGE.SET_NAME('WSH','WSH_SER_RANGE_MK_ERROR');
                                 FND_MESSAGE.SET_TOKEN('FM_SERIAL',l_new_sn);
                                 FND_MESSAGE.SET_TOKEN('TO_SERIAL',l_new_to_sn);
                                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                                 WSH_UTIL_CORE.Add_Message(x_return_status);
                              END IF;
                        -- bug 2740681

      ELSE
        x_new_delivery_detail_rec.serial_number := c.to_serial_number;
      END IF;

      l_qty_to_split := 0;

                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'new serial_number',
                                      x_new_delivery_detail_rec.serial_number);
                        END IF;
      ELSE
                       IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Split qty is grater than range');
                       END IF;

      IF l_transaction_temp_id IS NOT NULL THEN
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name,
                               'Updating mtl_serial_numbers_temp',
                                l_transaction_temp_id);
                          END IF;
        -- we need to assign the full serial number range to the new line
        UPDATE mtl_serial_numbers_temp
        SET  transaction_temp_id = l_transaction_temp_id,
          last_update_date  = SYSDATE,
          last_updated_by  = FND_GLOBAL.USER_ID,
          last_update_login   = FND_GLOBAL.LOGIN_ID
        WHERE  rowid = c.rowid;

                          --Bug 2740681
                             IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'Before Calling  Serial_Check.Inv_Unmark_Serial');
                               WSH_DEBUG_SV.log(l_module_name,'fm_serial_number,to_serial_number,inventory_item_id', c.fm_serial_number ||','||c.to_serial_number ||','||x_old_detail_rec.inventory_item_id);
                             END IF;
                             Serial_Check.Inv_Unmark_Serial(
                                c.fm_serial_number,
                                c.to_serial_number,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                x_old_detail_rec.inventory_item_id);
                              IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'After Calling  Serial_Check.Inv_Unmark_Serial');
                              END IF;

                              IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'Before Calling  Serial_Check.Inv_mark_Serial');
                               WSH_DEBUG_SV.log(l_module_name,'fm_serial_number',c.fm_serial_number);
                               WSH_DEBUG_SV.log(l_module_name,'to_serial_number',c.to_serial_number);
                               WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',x_old_detail_rec.inventory_item_id);
                               WSH_DEBUG_SV.log(l_module_name,'organization_id',x_old_detail_rec.organization_id);
                               WSH_DEBUG_SV.log(l_module_name,'l_transaction_temp_id',l_transaction_temp_id);
                              END IF;
                              Serial_Check.Inv_Mark_Serial(
                                c.fm_serial_number,
                                c.to_serial_number,
                                x_old_detail_rec.inventory_item_id,
                                x_old_detail_rec.organization_id,
                                l_transaction_temp_id,
                                l_transaction_temp_id,
                                l_transaction_temp_id,
                                l_success);
                              IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'After Serial_Check.Inv_mark_Serial l_success',l_success);
                              END IF;

                              IF l_success < 0 THEN
                                 FND_MESSAGE.SET_NAME('WSH','WSH_SER_RANGE_MK_ERROR');
                                 FND_MESSAGE.SET_TOKEN('FM_SERIAL', c.fm_serial_number);
                                 FND_MESSAGE.SET_TOKEN('TO_SERIAL', c.to_serial_number);
                                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                                 WSH_UTIL_CORE.Add_Message(x_return_status);
                              END IF;
                          --bug 2740681
      ELSE
        -- we need to remove this serial number range (which has count of 1)
        x_new_delivery_detail_rec.serial_number := c.fm_serial_number;
        DELETE mtl_serial_numbers_temp
        WHERE  rowid = c.rowid;
      END IF;

      l_qty_to_split := l_qty_to_split - l_range_count;

      END IF; -- l_range_count > l_qty_to_split
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_qty_to_split',
                                                   l_qty_to_split);
                  END IF;

      IF (l_qty_to_split <= 0) AND (p_old_shipped_quantity > 1) THEN
      -- finished with splitting serial numbers
      EXIT;
      END IF;

    END LOOP;  -- c_sn_ranges

    END IF; -- l_qty_to_split >= 1

  END IF;  -- x_old_detail_rec.transaction_temp_id IS NULL

  END IF;  -- p_old_shipped_quantity < x_old_detail_rec.shipped_quantity

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
  WHEN others THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
  wsh_util_core.default_handler('WSH_USA_ACTIONS_PVT.SPLIT_SERIAL_NUMBERS_INT',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Split_Serial_Numbers_INT;

-- THIS PROCEDURE IS OBSOLETE
--
-- Name
--   Explode_Delivery_Details
-- Purpose
--   Takes individual lines FROM MTL_SERIAL_NUMBERS_TEMP that
--   are under serial number control and explodes them into multiple
--   lines based on the serial numbers entered.
--
--   Bug 1752809: rewritten to explode into serial number ranges.
--        This improves interface performance by minimizing
--        number of delivery lines needed to interface serial numbers.
--
-- Arguments
--   P_Delivery_Detail_Id FOR which IS under Serial number
--   control and hence must do the explosion
--   P_Return_Status
--
--
PROCEDURE EXPLODE_DELIVERY_DETAILS(
  p_delivery_detail_id number,
  x_return_status out NOCOPY  varchar2)
IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'EXPLODE_DELIVERY_DETAILS';
--
BEGIN
  --
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  --
  --
END explode_delivery_Details;


/*
REM This API will unassign a line ( delivery_detail or container) from the Delivery and unapck it.
REM If the unpack results in the container ( holding the line/container) becoming empty
REM then it would unpack the container and unassign it from Delivery too.
REM the unpack/unassign is done recursively, till all empty containers resulting from the initial
REM unpacked line are unassigned/unpacked.
REM If there is an empty container already packed inside another container, and did not
REM become empty because of the current line was unpacked, those containers are left
REM packed/assigned to the Delivery.
*/
PROCEDURE unassign_unpack_empty_cont (
                                p_ids_tobe_unassigned IN wsh_util_core.id_tab_type,
                                p_validate_flag   IN VARCHAR2,
                                x_return_status   OUT NOCOPY  VARCHAR2
                              )
IS

CURSOR get_container(detail_id NUMBER) IS
SELECT  parent_delivery_detail_id,
        delivery_id     -- Bug#3542095
FROM    wsh_delivery_assignments_v
WHERE   delivery_detail_id = detail_id;

CURSOR get_lines (cont_id NUMBER, detail_id NUMBER) IS
SELECT delivery_detail_id
FROM   wsh_delivery_assignments_v
WHERE  parent_delivery_detail_id = cont_id
AND    delivery_detail_id <> detail_id;

l_parent_container_id   wsh_util_core.id_tab_type ;
l_delivery_id           wsh_delivery_assignments_v.delivery_id%type;
l_return_status         VARCHAR2(1):=NULL ;
l_line_id               NUMBER := NULL;

-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
e_return_excp EXCEPTION;

cursor l_get_cnt_org_csr(p_detail_id IN NUMBER) is
select organization_id,
       nvl(line_direction,'O')
from   wsh_delivery_details
where  delivery_detail_id = p_detail_id;

l_orgn_id NUMBER;
l_line_dir VARCHAR2(10);
l_wms_org VARCHAR2(10) := 'N';
-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_UNPACK_EMPTY_CONT';
--

BEGIN

  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     --
     WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF ( p_ids_tobe_unassigned.COUNT = 0 ) THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
     RETURN;
  END IF;

  FOR i in 1..p_ids_tobe_unassigned.COUNT LOOP
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'detail to be unassigned ',p_ids_tobe_unassigned(i));
     END IF;
     -- Get the parent container, if it exists
     OPEN get_container(p_ids_tobe_unassigned(i));
     FETCH get_container
     INTO l_parent_container_id(1)
          , l_delivery_id; -- Bug#3542095
     IF get_container%NOTFOUND THEN
        l_parent_container_id(1) := NULL;
     END IF;
     CLOSE get_container;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     -- Unassign the Line or Container
     -- because this
     wsh_delivery_details_actions.unassign_detail_from_delivery(
                                    p_detail_id          => p_ids_tobe_unassigned(i),
                                    p_validate_flag      => p_validate_flag,
                                    x_return_status      => l_return_status
                                    );

     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'AFTER CALLING UNASSIGN_DETAIL_FROM_DELIVERY: ', L_RETURN_STATUS);
     END IF;
     --
     -- Check if the Parent Container is empty, if yes, recursivelly call this API
     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_DET_ERROR');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id)); -- Bug#3542095
        FND_MESSAGE.SET_TOKEN('DET_NAME',p_ids_tobe_unassigned(i));
        x_return_status := l_return_status;
        WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           --
           --IF l_debug_on THEN
              --WSH_DEBUG_SV.pop(l_module_name);
           --END IF;
           --
           --RETURN; LPN CONV. rv
           raise e_return_excp; -- LPN CONV. rv
        END IF;
     END IF;

     IF l_parent_container_id(1) IS NOT NULL THEN
        OPEN get_lines(l_parent_container_id(1), p_ids_tobe_unassigned(i));
        FETCH get_lines INTO l_line_id;
        IF get_lines%NOTFOUND THEN
           l_line_id := NULL;
        END IF;
        CLOSE get_lines;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'L_LINE_ID ', L_LINE_ID);
        END IF;

        IF l_line_id IS NULL THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_UNPACK_EMPTY_CONT
                                               recursively for ',l_parent_container_id(1));
           END IF;

           -- lpn conv
           -- This needs to be done so that the WMS enabled LPNs that become empty
           -- need to be deleted at a later stage through Confirm_Delivery
           open  l_get_cnt_org_csr(l_parent_container_id(1));
           fetch l_get_cnt_org_csr into l_orgn_id, l_line_dir;
           close l_get_cnt_org_csr;
           l_wms_org := wsh_util_validate.check_wms_org(l_orgn_id);
           IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
           AND l_line_dir IN ('O', 'IO')
           AND l_wms_org = 'Y' THEN
           --{
               insert into wsh_wms_sync_tmp
                      (delivery_detail_id,
                       operation_type,
                       creation_date)
               values (l_parent_container_id(1),
                       'DELETE',
                       WSH_WMS_LPN_GRP.G_HW_TIME_STAMP);
           --}
           END IF;
           -- lpn conv

           unassign_unpack_empty_cont ( p_ids_tobe_unassigned => l_parent_container_id,
                                        p_validate_flag   => p_validate_flag,
                                        x_return_status   => l_return_status);
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'After calling UNASSIGN_UNPACK_EMPTY_CONT: ', L_RETURN_STATUS);
           END IF;
           IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
              IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status ;
              ELSIF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status ;
              END IF;
           END IF;
           IF x_return_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
              --IF l_debug_on THEN
                 --WSH_DEBUG_SV.pop(l_module_name);
              --END IF;
              --RETURN; LPN CONV. rv
              raise e_return_excp; -- LPN CONV. rv
           END IF;
        END IF; -- end of l_line_id is null

     END IF;

  END LOOP;

  --
  -- K LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
        (
          p_in_rec             => l_lpn_in_sync_comm_rec,
          x_return_status      => l_return_status,
          x_out_rec            => l_lpn_out_sync_comm_rec
        );
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
      END IF;
      --
      --
      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status ;
        ELSIF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status ;
        END IF;
      END IF;

  --}
  END IF;
  --
  -- K LPN CONV. rv
  --
  -- Added a pop as it was missing.
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN e_return_excp THEN
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_return_excp');
          END IF;

  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.unassign_unpack_empty_cont');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
  END IF;
  --
      --
      -- K LPN CONV. rv
      --
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
            (
              p_in_rec             => l_lpn_in_sync_comm_rec,
              x_return_status      => l_return_status,
              x_out_rec            => l_lpn_out_sync_comm_rec
            );
          --
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
          END IF;
          --
          --
      --}
      END IF;
      --
      -- K LPN CONV. rv
      --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --

END unassign_unpack_empty_cont;

/*2442099*/

PROCEDURE Log_Exceptions(p_old_delivery_detail_id IN NUMBER,
                         p_new_delivery_detail_id IN NUMBER,
                         p_delivery_id            IN NUMBER,
                         p_action                 IN VARCHAR2 DEFAULT NULL)

IS

cursor parent_del_exception is
--Changed for BUG#3330869
--SELECT *
SELECT  message,
	exception_name,
	trip_id,
	trip_name,
	trip_stop_id,
	delivery_id,
	delivery_name,
	delivery_assignment_id,
	container_name,
	inventory_item_id,
	lot_number,
-- HW OPMCONV - No need for sublot_number
--      sublot_number,
	revision,
	serial_number,
	unit_of_measure,
	unit_of_measure2,
	subinventory,
	locator_id,
	arrival_date,
	departure_date,
	error_message,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
	attribute13,
        attribute14,
        attribute15,
	request_id,
	logged_at_location_id,
	logging_entity,
	logging_entity_id,
	exception_location_id,
	manually_logged,
	batch_id,
        status
--select *
from wsh_exceptions
where delivery_detail_id = p_old_delivery_detail_id;

l_exception_return_status               VARCHAR2(30);
l_exception_msg_count                   NUMBER;
l_exception_msg_data                    VARCHAR2(4000) := NULL;
l_dummy_exception_id                    NUMBER;
l_exception_error_message               VARCHAR2(2000) := NULL;
l_qty1                                  NUMBER;
l_qty2                                  NUMBER;
l_trip_id                               NUMBER;
l_trip_name                             VARCHAR2(30);
l_trip_stop_id                          NUMBER;
l_delivery_id                           NUMBER;
l_delivery_name                         VARCHAR2(30);
l_departure_date                        DATE;
l_arrival_date                          DATE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'Log_Exceptions';
--

BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
  WSH_DEBUG_SV.push(l_module_name);
  --
  WSH_DEBUG_SV.log(l_module_name,'P_OLD_DELIVERY_DETAIL_ID',P_OLD_DELIVERY_DETAIL_ID);
  WSH_DEBUG_SV.log(l_module_name,'P_NEW_DELIVERY_DETAIL_ID',P_NEW_DELIVERY_DETAIL_ID);
  WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  --
  END IF;

  select requested_quantity,requested_quantity2 into l_qty1,l_qty2
  from wsh_delivery_details
  where delivery_detail_id = p_new_delivery_detail_id;

  IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
        FOR pexceptions in parent_del_exception
        LOOP
        IF p_delivery_id is NOT NULL THEN
                l_trip_id := pexceptions.trip_id;
                l_trip_name := pexceptions.trip_name;
                l_trip_stop_id := pexceptions.trip_stop_id;
                l_delivery_id := pexceptions.delivery_id;
                l_delivery_name := pexceptions.delivery_name;
                l_departure_date := pexceptions.departure_date;
                l_arrival_date := pexceptions.arrival_date;
        ELSE
                l_trip_id := NULL;
                l_trip_name := NULL;
                l_trip_stop_id := NULL;
                l_delivery_id := NULL;
                l_delivery_name := NULL;
                l_departure_date := NULL;
                l_arrival_date := NULL;
        END IF;

        -- Bug 4481016,During Split, Exceptions will not be updated
        -- To ensure exceptions are logged against split delivery detail, its required
        -- to pass null to l_dummy_exception_id which is used to determine, when to INSERT
        -- and when to UPDATE exceptions
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'EXCEPTION NAME-',pexceptions.exception_name);
          WSH_DEBUG_SV.log(l_module_name,'p_action -',p_action);

        END IF;

        l_dummy_exception_id := NULL;

        wsh_xc_util.log_exception(
                      p_api_version             => 1.0,
                      x_return_status           => l_exception_return_status,
                      x_msg_count               => l_exception_msg_count,
                      x_msg_data                => l_exception_msg_data,
                      x_exception_id            => l_dummy_exception_id ,
                      p_exception_location_id   => pexceptions.exception_location_id,
                      p_logged_at_location_id   => pexceptions.logged_at_location_id,
                      p_logging_entity          => pexceptions.logging_entity,
                      p_logging_entity_id       => pexceptions.logging_entity_id,
                      p_exception_name          => pexceptions.exception_name,
                      p_message                 => pexceptions.message,
--                      p_severity                => pexceptions.severity,
                      p_manually_logged         => pexceptions.manually_logged,
--                      p_exception_handling      => pexceptions.status,
                      p_trip_id                 => l_trip_id,
                      p_trip_name               => l_trip_name,
                      p_trip_stop_id            => l_trip_stop_id,
                      p_delivery_id             => l_delivery_id,
                      p_delivery_name           => l_delivery_name,
                      p_delivery_detail_id      => p_new_delivery_detail_id,
                      p_delivery_assignment_id  => pexceptions.delivery_assignment_id,
                      p_container_name          => pexceptions.container_name,
                      p_inventory_item_id       => pexceptions.inventory_item_id,
                      p_lot_number              => pexceptions.lot_number,
-- HW OPMCONV - No need for sublot_number
--                    p_sublot_number           => pexceptions.sublot_number,
                      p_revision                => pexceptions.revision,
                      p_serial_number           => pexceptions.serial_number,
                      p_unit_of_measure         => pexceptions.unit_of_measure,
                      p_quantity                => l_qty1,
                      p_unit_of_measure2        => pexceptions.unit_of_measure2,
                      p_quantity2               => l_qty2,
                      p_subinventory            => pexceptions.subinventory,
                      p_locator_id              => pexceptions.locator_id,
                      p_arrival_date            => l_arrival_date,
                      p_departure_date          => l_departure_date,
                      p_error_message           => pexceptions.error_message,
                      p_attribute_category      => pexceptions.attribute_category,
                      p_attribute1              => pexceptions.attribute1,
                      p_attribute2              => pexceptions.attribute2,
                      p_attribute3              => pexceptions.attribute3,
                      p_attribute4              => pexceptions.attribute4,
                      p_attribute5              => pexceptions.attribute5,
                      p_attribute6              => pexceptions.attribute6,
                      p_attribute7              => pexceptions.attribute7,
                      p_attribute8              => pexceptions.attribute8,
                      p_attribute9              => pexceptions.attribute9,
                      p_attribute10             => pexceptions.attribute10,
                      p_attribute11             => pexceptions.attribute11,
                      p_attribute12             => pexceptions.attribute12,
                      p_attribute13             => pexceptions.attribute13,
                      p_attribute14             => pexceptions.attribute14,
                      p_attribute15             => pexceptions.attribute15,
                      p_request_id              => pexceptions.request_id,
                      p_batch_id                => pexceptions.batch_id,
                      p_status                  => pexceptions.status,
                      p_action                  => p_action);

        END LOOP;
        IF (l_exception_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_XC_UTIL.LOG_EXCEPTION DID NOTRETURN SUCCESS'  );
        END IF;
        --
        END IF;

  IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;

END Log_Exceptions;
/*2442099*/

--  Procedure:      Consolidate_Source_Line
--
--  Parameters: p_Cons_Source_Line_Rec_Tab  -> List of delivery details and its corresponding req qtys,
--		 			       bo qtys, source line ids and delivery ids.
--		x_consolidate_ids     ->  Contains the list of existing BO dd_ids, into which the dd_ids passed
--					  in the parameter p_Cons_Source_Line_Rec_Tab got consolidated.
--
--  Description:    This is an internal API.
--                  Consolidates all the unpacked and unassigned back order delivery detail lines
--                  into one delivery detail Line for the given source_line_id. x_consolidate_ids(i)
--                  contains final consolidated delivery detail id corresponding to the ith record
--                  in p_Cons_Source_Line_Rec_Tab.
--
-- HW OPM BUG#:3121616 added requested_quantity2
PROCEDURE Consolidate_Source_Line(
    p_Cons_Source_Line_Rec_Tab  IN           WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab,
    x_consolidate_ids           OUT  NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
    x_return_status             OUT  NOCOPY  VARCHAR2 ) IS

CURSOR get_bo_dds_cur(p_delivery_detail_id IN NUMBER, p_source_line_id IN NUMBER,p_delivery_id IN NUMBER) is
SELECT  wdd.delivery_detail_id, wdd.requested_quantity,wdd.requested_quantity2
FROM  wsh_delivery_details wdd,
      wsh_delivery_assignments_v wda
WHERE     wdd.source_line_id = p_source_line_id
AND       wdd.delivery_detail_id <> p_delivery_detail_id
AND       wdd.released_status = 'B'
AND       wdd.replenishment_status IS NULL --bug# 6749200 (replenishment project)
AND       wdd.delivery_detail_id = wda.delivery_detail_id
AND       wdd.container_flag = 'N'
AND	  wdd.source_code = 'OE'    -- Enables the Consolidation ONLY for the lines imported from Order Management.
AND       (( wda.delivery_id is NULL AND wda.parent_delivery_detail_id is NULL )
              OR ( wda.delivery_id = nvl(p_delivery_id,-99)))
FOR UPDATE NOWAIT;

CURSOR get_line_info_cur(p_line_id IN NUMBER) is
SELECT shipping_instructions,
       packing_instructions
FROM oe_order_lines_all
WHERE line_id = p_line_id;


-- Tables to store delivery detail id's

l_cons_dd_ids		       WSH_UTIL_CORE.Id_Tab_Type; -- To store the final delivery details
l_cons_qtys                    WSH_UTIL_CORE.Id_Tab_Type;
-- HW OPM BUG#:3121616 added qty2s
l_cons_qty2s                   WSH_UTIL_CORE.Id_Tab_Type;
l_partial_dd_ids               WSH_UTIL_CORE.Id_Tab_Type; -- To store partial Back Order Del Det
l_partial_org_req_qtys         WSH_UTIL_CORE.Id_Tab_Type;
l_partial_req_qtys             WSH_UTIL_CORE.Id_Tab_Type;
-- HW OPM BUG#:3121616 added qty2s
l_partial_req_qty2s            WSH_UTIL_CORE.Id_Tab_Type;
l_delete_dd_ids                WSH_UTIL_CORE.Id_Tab_Type; -- To store the Del Det to be deleted
-- Bug#3399109 :Changed the Data Type from Id_Tab_Type to tbl_varchar
l_ship_instructions            WSH_UTIL_CORE.tbl_varchar; -- To store shipping instructions
l_pack_instructions            WSH_UTIL_CORE.tbl_varchar; -- To store packing instructions



l_del_det_Id                        NUMBER;
l_req_qty                           NUMBER;
-- HW OPM BUG#:3121616 added qty2s
l_req_qty2                          NUMBER;
l_total_req_qty                     NUMBER := 0;
-- HW OPM BUG#:3121616 added qty2s
l_total_req_qty2                    NUMBER := 0;
l_temp_cnt                          NUMBER;


l_user_id                   NUMBER;
l_login_id                  NUMBER;
l_return_status             VARCHAR2(30);
-- J: W/V Changes
l_tmp_weight                NUMBER;
l_tmp_volume                NUMBER;
l_new_gross_wt              NUMBER;
l_new_net_wt                NUMBER;
l_new_vol                   NUMBER;
l_gross_weight              NUMBER;
l_net_weight                NUMBER;
l_volume                    NUMBER;
l_wv_frozen_flag            VARCHAR2(1);

l_dbi_rs                    VARCHAR2(1); -- Return Status from DBI API
l_dd_txn_id    NUMBER;
l_txn_return_status  VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CONSOLIDATE_SOURCE_LINE';
--

BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL  THEN

     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN

  WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_user_id  := FND_GLOBAL.user_id;
  l_login_id := FND_GLOBAL.login_id;

  FOR i IN 1..p_Cons_Source_Line_Rec_Tab.count  --{ Looping thru' the input params
  LOOP
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'********* Processing the Delivery Detail Id:',p_Cons_Source_Line_Rec_Tab(i).delivery_detail_id);
    END IF;
    --
    l_temp_cnt := l_delete_dd_ids.COUNT;
    l_total_req_qty   := 0;

    OPEN get_bo_dds_cur(p_Cons_Source_Line_Rec_Tab(i).delivery_detail_id,p_Cons_Source_Line_Rec_Tab(i).source_line_id,p_Cons_Source_Line_Rec_Tab(i).delivery_id);

    LOOP  --{  Fetch all the unassigned unpacked  Backordered  Delivery Details for the same source line id

   -- HW OPM BUG#:3121616 added qty2
      FETCH get_bo_dds_cur INTO l_del_det_Id,l_req_qty,l_req_qty2;
      EXIT WHEN (get_bo_dds_cur%NOTFOUND);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         --
         WSH_DEBUG_SV.log(l_module_name,'Found Existing Back Order Del Det line: ',l_del_det_Id);
      END IF;
      --
      l_delete_dd_ids(l_delete_dd_ids.COUNT + 1) :=l_del_det_Id;
      l_total_req_qty := l_total_req_qty + l_req_qty;
-- HW OPM BUG#:3121616 added qty2
      l_total_req_qty2 := l_total_req_qty2 + l_req_qty2;

    END LOOP; --} done fetching the existing unasssigned unpacked Backorder lines
    CLOSE get_bo_dds_cur;

    IF ( l_delete_dd_ids.COUNT > l_temp_cnt ) --{ Consolidation is possible or not
    THEN
       -- Use the last Deliver Detail found for the consolidation purpose, accordingly
       -- delete the delivery details id from l_delete_dd_ids table.
       l_cons_dd_ids (l_cons_dd_ids.COUNT + 1) := l_delete_dd_ids(l_delete_dd_ids.COUNT);
       l_delete_dd_ids.delete(l_delete_dd_ids.COUNT);
       l_cons_qtys(l_cons_qtys.COUNT + 1) := l_total_req_qty + p_Cons_Source_Line_Rec_Tab(i).bo_qty;
-- HW OPM BUG#:3121616 added qty2s
       l_cons_qty2s(l_cons_qty2s.COUNT + 1) := l_total_req_qty2 + p_Cons_Source_Line_Rec_Tab(i).bo_qty2;
-- end of 3121616


       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Consolidated Into Delivery Detail Id ',l_cons_dd_ids(l_cons_dd_ids.COUNT));
       END IF;

       -- Getting the shipping and packing instructions from the source line id. which are to be assigned
       -- to final delivery detail for the given source line id.
       open get_line_info_cur(p_Cons_Source_Line_Rec_Tab(i).source_line_id);
       fetch get_line_info_cur into l_ship_instructions(l_ship_instructions.COUNT + 1),l_pack_instructions(l_pack_instructions.COUNT + 1);
       close get_line_info_cur;

       --  Storing the final delivery detail id in the out parameter
       x_consolidate_ids(i):= l_cons_dd_ids(l_cons_dd_ids.COUNT);

       -- If it is partial back ordering then don't delete it, update the existing delivery detail
       -- Qty otherwise delete the delivery detail being processing.
       IF ( p_Cons_Source_Line_Rec_Tab(i).bo_qty < p_Cons_Source_Line_Rec_Tab(i).req_qty ) --{ Is is partial BO
       THEN
          l_partial_dd_ids (l_partial_dd_ids.COUNT + 1) := p_Cons_Source_Line_Rec_Tab(i).delivery_detail_id;
          l_partial_org_req_qtys(l_partial_req_qtys.COUNT + 1) := p_Cons_Source_Line_Rec_Tab(i).req_qty;
          l_partial_req_qtys (l_partial_req_qtys.COUNT + 1) := p_Cons_Source_Line_Rec_Tab(i).req_qty - p_Cons_Source_Line_Rec_Tab(i).bo_qty;
-- HW OPM BUG#:3121616 added qty2s
          l_partial_req_qty2s (l_partial_req_qty2s.COUNT + 1) := p_Cons_Source_Line_Rec_Tab(i).req_qty2 - p_Cons_Source_Line_Rec_Tab(i).bo_qty2;
-- end of 3121616
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Updating Req Qty for the Del Det Id (Bo Qty < Req. Qty) ',l_partial_dd_ids (l_partial_dd_ids.COUNT));
          END IF;
          --
       ELSE
          l_delete_dd_ids(l_delete_dd_ids.COUNT+1):= p_Cons_Source_Line_Rec_Tab(i).delivery_detail_id;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Deleting the Del Det Id (Bo Qty = Req qty)',l_delete_dd_ids(l_delete_dd_ids.COUNT));
          END IF;
          --
      END IF; --} Is it Partial BO
   ELSE -- No consolidation if possible for the delivery Detail id
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'No Existing Back Order Del Det Lines found');
      END IF;
      --
      x_consolidate_ids (i) := p_Cons_Source_Line_Rec_Tab(i).delivery_detail_id;
   END IF; --} Check for existing back order lines

  END LOOP;  --} End of the Delivery Detail Table

  IF (get_bo_dds_cur%ISOPEN) THEN
      CLOSE get_bo_dds_cur;
  END IF;


  -- Handling the Tables created in the above process (BULK Collect)
  -- Deleting all the Delivery Detail in the Delete table
  FOR i IN 1..l_delete_dd_ids.COUNT
  LOOP  -- {
     -- deleting the delivery detail line
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.DELETE_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details(
                    p_delivery_detail_id  => l_delete_dd_ids(i),
                    x_return_status       => l_return_status );

     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'After calling DELETE_DELIVERY_DETAILS: ' || l_return_status );
     END IF;
     --
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  END LOOP; -- }

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Updating details for consolidation.Detail Count-',l_cons_dd_ids.count);
  END IF;
  -- Updating the selected Delivery Details for the consolidation with corresponding total Qty
  FOR i IN 1..l_cons_dd_ids.COUNT LOOP
	-- HW OPM BUG#:3121616 added qty2s
	  UPDATE wsh_delivery_details
	  SET requested_quantity  =  l_cons_qtys(i),
	      requested_quantity2  = l_cons_qty2s(i),
	     tracking_number     = null,
	     master_container_item_id = null,
	     detail_container_item_id = null,
	     seal_code                = null,
	     shipping_instructions    = l_ship_instructions(i),
	     packing_instructions     =  l_pack_instructions(i)
	  WHERE delivery_detail_id     = l_cons_dd_ids (i);

        WSH_DD_TXNS_PVT.create_dd_txn_from_dd  (p_delivery_detail_id => l_cons_dd_ids(i),
 										x_dd_txn_id => l_dd_txn_id,
 										x_return_status =>l_txn_return_status);

         IF (l_txn_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                  x_return_status := l_txn_return_status;
                  RETURN;
        END IF;
   END LOOP;

  --
  -- DBI Project
  -- Update of wsh_delivery_details where requested_quantity/released_status
  -- are changed, call DBI API after the update.
  -- DBI API will check if DBI is installed
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_cons_dd_ids.count);
  END IF;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_cons_dd_ids,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  -- Only Handle Unexpected error
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    --
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- End of Code for DBI Project
  --

  -- Bug#3670261
  -- Deleting the Freight Costs associated with the delivery details selected for Consolidation
  FORALL i IN 1..l_cons_dd_ids.COUNT
  DELETE FROM WSH_FREIGHT_COSTS
  WHERE  delivery_detail_id = l_cons_dd_ids(i);
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Freight Cost Rows deleted',SQL%ROWCOUNT);
  END IF;

  -- J: W/V Changes
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'l_cons_dd_ids.COUNT '||l_cons_dd_ids.COUNT);
  END IF;

  IF l_cons_dd_ids.COUNT > 0 THEN

    FOR l_index in l_cons_dd_ids.FIRST..l_cons_dd_ids.LAST LOOP

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WV_UTILS.Detail_Weight_Volume(
        p_delivery_detail_id => l_cons_dd_ids(l_index),
        p_update_flag        => 'Y',
        p_post_process_flag  => 'Y',
        p_calc_wv_if_frozen  => 'Y',
        x_net_weight         => l_tmp_weight,
        x_volume             => l_tmp_volume,
        x_return_status      => l_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
      END IF;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status := l_return_status;
      END IF;

    END LOOP;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Updating partial bkorder cases.Detail Count-',l_partial_dd_ids.count);
  END IF;
  -- Updating the partial Back order cases. Qty should be subtracted for the partial case
  FORALL i IN 1..l_partial_dd_ids.COUNT
-- HW OPM BUG#:3121616 added qty2s
  UPDATE wsh_delivery_details
  SET requested_quantity = l_partial_req_qtys(i),
      requested_quantity2 = l_partial_req_qty2s(i)
  WHERE delivery_detail_id = l_partial_dd_ids (i);

  --
  -- DBI Project
  -- Update of wsh_delivery_details where requested_quantity/released_status
  -- are changed, call DBI API after the update.
  -- DBI API will check if DBI is installed
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_partial_dd_ids.count);
  END IF;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_partial_dd_ids,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  -- Only Handle Unexpected error
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    --
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- End of Code for DBI Project
  --

  -- We need to adjust the W/V if DDs W/V is frozen
  IF l_partial_dd_ids.COUNT > 0 THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'l_partial_dd_ids.COUNT '||l_partial_dd_ids.COUNT);
    END IF;

    FOR l_index in l_partial_dd_ids.FIRST..l_partial_dd_ids.LAST LOOP

      SELECT gross_weight,
             net_weight,
             volume,
             nvl(wv_frozen_flag,'Y')
      INTO   l_gross_weight,
             l_net_weight,
             l_volume,
             l_wv_frozen_flag
      FROM   wsh_delivery_details
      WHERE  delivery_detail_id = l_partial_dd_ids(l_index);

      IF l_wv_frozen_flag = 'Y' THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'W/V Frozen flag is Y for DD '||l_partial_dd_ids(l_index));
        END IF;

        l_new_gross_wt := round(l_gross_weight * (l_partial_req_qtys(l_index)/l_partial_org_req_qtys(l_index)) ,5);
        l_new_net_wt   := round(l_net_weight * (l_partial_req_qtys(l_index)/l_partial_org_req_qtys(l_index)) ,5);
        l_new_vol      := round(l_volume * (l_partial_req_qtys(l_index)/l_partial_org_req_qtys(l_index)) ,5);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Updating DD '||l_partial_dd_ids(l_index)||' with Gross '||l_new_gross_wt||' Net '||l_new_net_wt||' Vol '||l_new_vol);
        END IF;

        UPDATE wsh_delivery_details
        set    gross_weight = l_new_gross_wt,
               net_weight   = l_new_net_wt,
               volume       = l_new_vol
        WHERE  delivery_detail_id = l_partial_dd_ids(l_index);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id => l_partial_dd_ids(l_index),
          p_diff_gross_wt      => -1 * (l_gross_weight - l_new_gross_wt),
          p_diff_net_wt        => -1 * (l_net_weight - l_new_net_wt),
          p_diff_fill_volume   => -1 * (l_volume - l_new_vol),
          x_return_status      => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          --
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.Add_Message(x_return_status);
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
        END IF;

      END IF;
    END LOOP;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            --
            return;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
            END IF;
            --
            return;


      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Source_Lines ' );
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
          --
END Consolidate_Source_Line;


--
--  Procedure:   Process_Delivery_Details
--  Parameters:
--	p_delivery_detail_id:  delivery detail id need to be processed
--	p_bo_qty	    :  backordered quantity to unreserve
--	p_overpick_qty	    :  overpicked quantity to unreserve
--	p_bo_mode	    :  either UNRESERVE/CYCLE_COUNT
--	p_delete_flag	    :  'Y' will delete the delivery detail passed
--			       'N' doesnot delete.
--  Description: This procedure will do unreservation, unpack/unassign
--  for the passed delivery detail id. It deletes the delivery detail
--  if p_delete_flag is passed as 'Y'.
--  Added this procedure as part of code changes for the Bug#3317692
PROCEDURE Process_Delivery_Details (
 	p_delivery_detail_id	IN   NUMBER,
	p_bo_qty		IN   NUMBER,
	p_bo_qty2s		IN   NUMBER,
	p_overpick_qty		IN   NUMBER,
	p_bo_mode		IN   VARCHAR2,
        p_delete_flag	        IN   VARCHAR2 DEFAULT NULL,
 	x_return_status		OUT  NOCOPY   VARCHAR2
) IS

l_delivery_detail_ids		WSH_UTIL_CORE.Id_Tab_Type;
l_idx				NUMBER;

l_inventory_item_id     NUMBER   := NULL;
l_organization_id       NUMBER   := NULL;
l_subinventory          VARCHAR2(10) := NULL;
l_serial_number         VARCHAR2(30) := NULL;
l_transaction_temp_id   NUMBER   := NULL;
l_inv_controls_rec      WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;
l_return_status         VARCHAR2(5) := NULL;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'PROCESS_DELIVERY_DETAILS';
--
BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',p_delivery_detail_id);
	    WSH_DEBUG_SV.log(l_module_name,'P_BO_QTY',p_bo_qty);
	    WSH_DEBUG_SV.log(l_module_name,'P_OVERPICK_QTY',p_overpick_qty);
	    WSH_DEBUG_SV.log(l_module_name,'P_BO_MODE',P_BO_MODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_FLAG',P_DELETE_FLAG);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
	l_delivery_detail_ids(1) := p_delivery_detail_id;
        IF (p_delete_flag = 'Y') THEN --{
	        WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont (
		               p_ids_tobe_unassigned  => l_delivery_detail_ids ,
                               p_validate_flag => 'N',
                               x_return_status   => l_return_status
                              );
		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			raise FND_API.G_EXC_ERROR;
	        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
	END IF; --}

	IF (p_bo_qty > 0) THEN --{
		--
	        -- Debug Statements
		--
		IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Unreserving the Backordered quantity ',WSH_DEBUG_SV.C_PROC_LEVEL);
	     	      WSH_DEBUG_SV.logmsg(l_module_name,'... delivery_detail_id '|| p_delivery_detail_id,WSH_DEBUG_SV.C_PROC_LEVEL);
		      WSH_DEBUG_SV.logmsg(l_module_name,'... backordered quantity '||p_bo_qty ,WSH_DEBUG_SV.C_PROC_LEVEL);
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNRESERVE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
	        wsh_delivery_details_actions.unreserve_delivery_detail(
		       p_delivery_Detail_id    => p_delivery_detail_id,
		       p_unreserve_mode        => p_bo_mode ,
	               p_quantity_to_unreserve => p_bo_qty,
                       p_override_retain_ato_rsv    => 'N',
       		       p_quantity2_to_unreserve => p_bo_qty2s,
	               x_return_status         => l_return_status
	              );
		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		       raise FND_API.G_EXC_ERROR;
		ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	  	END IF;
	END IF; --}

	IF (p_overpick_qty > 0) THEN --{
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Unreserving the Backordered quantity ',WSH_DEBUG_SV.C_PROC_LEVEL);
	     	      WSH_DEBUG_SV.logmsg(l_module_name,'... delivery_detail_id '|| p_delivery_detail_id,WSH_DEBUG_SV.C_PROC_LEVEL);
		      WSH_DEBUG_SV.logmsg(l_module_name,'... overpicked quantity '||p_overpick_qty ,WSH_DEBUG_SV.C_PROC_LEVEL);
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNRESERVE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
	       --Bug 4721577 Do not retain reservation for overpicked quantities
		IF p_bo_mode = 'RETAIN_RSV' THEN
	          wsh_delivery_details_actions.unreserve_delivery_detail(
		       p_delivery_Detail_id    => p_delivery_detail_id,
		       p_unreserve_mode        => 'UNRESERVE' ,
	               p_quantity_to_unreserve => p_overpick_qty,
                       p_override_retain_ato_rsv    => 'Y',
       		       p_quantity2_to_unreserve => p_bo_qty2s,
	               x_return_status         => l_return_status
	              );
                ELSE
		wsh_delivery_details_actions.unreserve_delivery_detail(
		       p_delivery_Detail_id    => p_delivery_detail_id,
		       p_unreserve_mode        => p_bo_mode ,
	               p_quantity_to_unreserve => p_overpick_qty,
                       p_override_retain_ato_rsv    => 'Y',
       		       p_quantity2_to_unreserve => p_bo_qty2s,
	               x_return_status         => l_return_status
	              );
		END IF;
		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		       raise FND_API.G_EXC_ERROR;
		ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	  	END IF;
	END IF;  --}

        IF (p_delete_flag = 'Y') THEN --{
		--
	        -- Debug Statements
		--
		IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--

		WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details(
			p_delivery_detail_id => p_delivery_detail_id,
			p_cancel_flag        => 'N',
			x_return_status      => l_return_status);
		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			raise FND_API.G_EXC_ERROR;
	        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
	END IF;  --}

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

  EXCEPTION
   	WHEN others THEN
 		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.Process_Delivery_Details',l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
		--
END Process_Delivery_Details;

--  Procedure:      Consolidate_Delivery_Details
--
--  Parameters: p_delivery_details_tab  -> list of delivery details and its corresponding req qtys, bo qtys,
--		 			   source line ids and delivery ids
--              p_bo_mode		-> Either  'UNRESERVE'  or 'CYCLE_COUNT' or 'RETAIN_RSV'
--                                         'RETAIN_RSV' added for bug 4721577, however this API is not affected
--                                         beacuse of this change.
--		x_cons_delivery_details_tab -> This is a filtered table of p_delivery_details_tab.
--					   This contains the list of dd_ids into which the dd_ids passed
--		                           in the parameter p_delivery_details_tab get consolidated.
--					   This also contains the corresponding req qtys, bo qyts and
--					   source line ids. Corresponding delivery_id field will be NULL.
--		x_remain_bo_qtys	-> Contains the sum of backorder quantities of delivery details(except
--					   for the dd_id in x_cons_delivery_details_tab) for each source line.
--					   x_remain_bo_qtys has a quantity for each dd_id in
--					   x_cons_delivery_details_tab.
--  Description:    This API is Internally used by ShipConfirm to
--                  consolidate the delivery details going to be BackOrdered.
--                  This Procedure takes the list of delivery details
--                  under a Delivery and consolidates them into one
--                  delivery detail for each source line id.
--
-- HW OPM BUG#:3121616 Added x_remain_bo_qty2s
PROCEDURE Consolidate_Delivery_Details(
	 	p_delivery_details_tab  IN     WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab,
		p_bo_mode	        IN     VARCHAR2,
	 	x_cons_delivery_details_tab  OUT NOCOPY  WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab,
		x_remain_bo_qtys	OUT NOCOPY   WSH_UTIL_CORE.Id_Tab_Type,
                x_remain_bo_qty2s	OUT NOCOPY   WSH_UTIL_CORE.Id_Tab_Type,
		x_return_status		OUT NOCOPY   VARCHAR2
    ) IS
l_line_ids		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the source line ids passed as parameter
l_detail_ids		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the delivery detail ids passed as parameter
l_delivery_details_tab  WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab;   -- Stores the delivery detail records with req-qty >0
l_freight_detail_ids	WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the delivery details for which the freight costs need to be deleted.
l_req_qtys		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the requested quantities passed as parameter
l_bo_qtys		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the BO quantities passed as parameter
l_overpick_qtys         WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the Overpicked quantities passed as parameter
-- HW OPM BUG#:3121616 added qty2s
l_bo_qty2s		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the BO quantities2 passed as parameter
l_cons_dd_ids		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores consolidate dd_id for line_id at l_cons_dd_ids(line_id)
l_cons_dd_flags		WSH_UTIL_CORE.Column_Tab_Type;
l_cons_bo_qtys		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores bo qty of consolidate dd_id for line_id at l_cons_bo_ids(line_id)
l_cons_overpick_qtys    WSH_UTIL_CORE.Id_Tab_Type;  -- Stores overpicked qty of consolidate dd_id for line_id at l_cons_bo_ids(line_id)
-- HW OPM BUG#:3121616 added qty2s
l_cons_bo_qty2s		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores bo qty2 of consolidate dd_id for line_id at l_cons_bo2_ids(line_id)
l_cons_req_qtys		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores req qty of consolidate dd_id for line_id at l_cons_req_ids(line_id)
l_delete_dd_ids		WSH_UTIL_CORE.Id_Tab_Type;  -- Stores the all delivery details need to be deleted(that are getting
 					               -- completely BackOrdered), except one delivery detail for each source line.

l_curr_line_id		NUMBER;  -- This temporary variable stores the current line_id in a loop.
l_cons_dd_id		NUMBER;	 -- This contains the delivery_detail_id that gets consolidation into
l_found_complete_bo	VARCHAR2(1);
l_total_bo_qty		NUMBER;
-- HW OPM BUG#:3121616 added qty2s
l_total_bo_qty2         NUMBER;
l_return_status		VARCHAR2(1);

l_idx			NUMBER := 1;
l_cmp_idx		NUMBER := 1;
l_next_idx		NUMBER := 1;

l_detail_tab            WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs                VARCHAR2(1); -- Return Status from DBI API

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CONSOLIDATE_DELIVERY_DETAILS';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);

      WSH_DEBUG_SV.log(l_module_name,'P_BO_MODE',p_bo_mode);
  END IF;
  --

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Store the passed parameter values into local pl/sql tables
  FOR i IN p_delivery_details_tab.FIRST .. p_delivery_details_tab.LAST LOOP --{
	l_detail_ids(i) := p_delivery_details_tab(i).delivery_detail_id;
	l_line_ids(i)   := p_delivery_details_tab(i).source_line_id;
	l_req_qtys(i)   := p_delivery_details_tab(i).req_qty;
	l_bo_qtys(i)    := p_delivery_details_tab(i).bo_qty;
        l_overpick_qtys(i)    := p_delivery_details_tab(i).overpick_qty;    -- Bug#3263952
-- HW OPM BUG#:3121616 added qty2s
	l_bo_qty2s(i)   := p_delivery_details_tab(i).bo_qty2;

        IF p_delivery_details_tab(i).req_qty = 0 THEN
	        l_cons_dd_flags(i) := 'Y';
        ELSE
	        l_cons_dd_flags(i) := 'N';
        END IF;

  END LOOP; --}

  -- Following Code gets the dd_id for each source_line, that will be used for consolidation
  -- from the passed list of delivery details.
  l_idx := p_delivery_details_tab.FIRST;
  WHILE l_idx IS NOT NULL
  LOOP  -- {

     -- Do not consider dd's with requested_quantity = 0 , for consolidation now . These are already
     -- marked earlier.
      IF p_delivery_details_tab(l_idx).req_qty > 0 THEN
	       l_delivery_details_tab(l_idx) := p_delivery_details_tab(l_idx);
      END IF;
      l_idx := p_delivery_details_tab.NEXT(l_idx);
  END LOOP; --}

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Finding the delivery detail to Consolidate into, from the input list',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  -- Mark the corresponding entry in l_cons_dd_flags(i) to 'Y', if l_detail_ids(i) is
  -- the consolidated delivery detail. Mark l_cons_dd_flags(i) to 'N' otherwise.
  -- Logic: Parse thru the entire list for a source line and set the first found completely backordered
  --        delivery detail as the consolidate delivery detail.
  --	    If we don't find the completely backordered delivery detail under the source line,
  --	    then set the first delivery detail in the list for the source line as the consolidate delivery detail.
  --
  l_idx := l_delivery_details_tab.FIRST;
  WHILE l_idx IS NOT NULL
  LOOP  -- {
	l_found_complete_bo := 'N';
	IF (l_delivery_details_tab(l_idx).bo_qty = l_delivery_details_tab(l_idx).req_qty ) THEN --{
		l_found_complete_bo  := 'Y';
		l_cons_dd_flags(l_idx) := 'Y';
 	END IF; --}

	l_next_idx := l_delivery_details_tab.NEXT(l_idx);
	WHILE l_next_idx IS NOT NULL
	LOOP  --{
		IF l_delivery_details_tab(l_next_idx).source_line_id = l_delivery_details_tab(l_idx).source_line_id THEN
		    IF l_found_complete_bo = 'N' AND
			      (l_delivery_details_tab(l_next_idx).bo_qty = l_delivery_details_tab(l_next_idx).req_qty) THEN
			 l_found_complete_bo  := 'Y';
			 l_cons_dd_flags(l_next_idx) := 'Y';
		    END IF;
	            l_delivery_details_tab.DELETE(l_next_idx);
		END IF;
  	        l_next_idx := l_delivery_details_tab.NEXT(l_next_idx);
	END LOOP; --}

	IF l_found_complete_bo = 'N' THEN
        	l_cons_dd_flags(l_idx) := 'Y';
	END IF;
	l_delivery_details_tab.DELETE(l_idx);

	l_idx := l_delivery_details_tab.NEXT(l_idx);
  END LOOP;  --}
  --

  -- Keep the delivery_detail_ids used for consolidation and the corresponding quantities
  -- to pass them back to the Caller.
  l_idx := p_delivery_details_tab.FIRST;
  WHILE l_idx IS NOT NULL
  LOOP  --{
	IF l_cons_dd_flags(l_idx) = 'Y' THEN --{
  	     x_cons_delivery_details_tab(x_cons_delivery_details_tab.COUNT+1).delivery_detail_id :=  p_delivery_details_tab(l_idx).delivery_detail_id;
  	     x_cons_delivery_details_tab(x_cons_delivery_details_tab.COUNT).req_qty  :=  p_delivery_details_tab(l_idx).req_qty;
  	     x_cons_delivery_details_tab(x_cons_delivery_details_tab.COUNT).bo_qty   :=  p_delivery_details_tab(l_idx).bo_qty;
-- HW OPM BUG#:3121616 added qty2s
  	     x_cons_delivery_details_tab(x_cons_delivery_details_tab.COUNT).bo_qty2         :=  p_delivery_details_tab(l_idx).bo_qty2;
  	     x_cons_delivery_details_tab(x_cons_delivery_details_tab.COUNT).source_line_id  :=  p_delivery_details_tab(l_idx).source_line_id;
	     x_cons_delivery_details_tab(x_cons_delivery_details_tab.COUNT).overpick_qty := p_delivery_details_tab(l_idx).overpick_qty;
								     -- Bug#3263952
	     IF l_debug_on THEN
               IF p_delivery_details_tab(l_idx).req_qty > 0 THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Delivery details of the Source Line '||p_delivery_details_tab(l_idx).source_line_id ||
			' are getting consolidated into dd_id :'||p_delivery_details_tab(l_idx).delivery_detail_id,WSH_DEBUG_SV.C_PROC_LEVEL);
  	       END IF;
	     END IF;
	END IF;  --}
  	l_idx := p_delivery_details_tab.NEXT(l_idx);
  END LOOP; --}

  --  loop thru' input delivery details using the index variable l_idx.
  --  add the backordered quantities of the all the delivery details under the same line_id
  --  and delete those delivery details from the pl/sql table l_detail_ids.
  l_idx := l_detail_ids.FIRST;
  WHILE l_idx IS NOT NULL
  LOOP  --{ loop thru' l_detail_ids
        l_curr_line_id := l_line_ids(l_idx);

  	-- Calculating the consolidate backorder quantity for l_curr_line_id.
  	-- Loop thru' the list and sum up the backorder quantities of the delivery details for l_curr_line_id.
	-- Delete the delivery_details of l_curr_line_id from the pl/sql table l_detail_ids,
	-- after getting the corresponding backorder quantity.
	l_total_bo_qty := 0;  -- Used to store the Consolidated BO qty.
-- HW OPM BUG#:3121616 added qty2s
	l_total_bo_qty2 := 0;  -- Used to store the Consolidated BO qty2
  	l_cmp_idx := l_idx;  -- Starting from l_idx, find all dds from l_detail_ids which belong to the
		 	     -- current line id
	WHILE l_cmp_idx IS NOT NULL
	LOOP --{
	    IF ( (l_curr_line_id = l_line_ids(l_cmp_idx)) AND (l_cons_dd_flags(l_cmp_idx) <> 'Y') ) THEN
	 --{
     	        l_total_bo_qty := l_total_bo_qty + l_bo_qtys(l_cmp_idx);
-- HW OPM BUG#:3121616 added qty2s
                l_total_bo_qty2 := l_total_bo_qty2 + l_bo_qty2s(l_cmp_idx);

                -- If a delivery detail is completely backorderd, delete it physically(pass p_delete_flag as 'Y'
		-- to process_delivery_details).
		IF l_bo_qtys(l_cmp_idx) = l_req_qtys(l_cmp_idx) THEN
	     --{
	           --
		   IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Process_Delivery_Details',WSH_DEBUG_SV.C_PROC_LEVEL);
	  	      WSH_DEBUG_SV.logmsg(l_module_name,'.. to process completely backordered delivery detail '||l_detail_ids(l_cmp_idx),WSH_DEBUG_SV.C_PROC_LEVEL);
		   END IF;
		   --
		   Process_Delivery_Details (
		 	p_delivery_detail_id	=> l_detail_ids(l_cmp_idx),
			p_bo_qty		=> l_bo_qtys(l_cmp_idx),
			p_overpick_qty		=> l_overpick_qtys(l_cmp_idx),
			p_bo_mode		=> p_bo_mode,
		        p_delete_flag	        => 'Y',
			p_bo_qty2s		=> l_bo_qty2s(l_cmp_idx),
		 	x_return_status		=> l_return_status
			);
	  	   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			raise FND_API.G_EXC_ERROR;
		   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		        raise FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

   	        -- If a delivery detail is partially backordered , unreserve the backordered
		-- quantity and later update its requested quantity. This delivery detail should not be
		-- deleted ( pass p_delete_flag as 'N' to process_delivery_details).
		ELSIF ((l_bo_qtys(l_cmp_idx) > 0 OR l_overpick_qtys(l_cmp_idx) > 0)) THEN
		   --
		   IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Process_Delivery_Details',WSH_DEBUG_SV.C_PROC_LEVEL);
      	  	      WSH_DEBUG_SV.logmsg(l_module_name,'.. to process partially backordered delivery detail '||l_detail_ids(l_cmp_idx),WSH_DEBUG_SV.C_PROC_LEVEL);
		   END IF;
		   --
	  	   Process_Delivery_Details (
		 	p_delivery_detail_id	=> l_detail_ids(l_cmp_idx),
			p_bo_qty		=> l_bo_qtys(l_cmp_idx),
			p_overpick_qty		=> l_overpick_qtys(l_cmp_idx),
			p_bo_mode		=> p_bo_mode,
		        p_delete_flag	        => 'N',
			p_bo_qty2s		=> l_bo_qty2s(l_cmp_idx),
		 	x_return_status		=> l_return_status
			);
	  	   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			raise FND_API.G_EXC_ERROR;
		   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		        raise FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

-- HW OPM BUG#:3121616 added qty2s
 	           update wsh_delivery_details
		   set requested_quantity = requested_quantity - l_bo_qtys(l_cmp_idx),
                       requested_quantity2 = requested_quantity2 - l_bo_qty2s(l_cmp_idx),
                       picked_quantity = picked_quantity - l_bo_qtys(l_cmp_idx) - l_overpick_qtys(l_cmp_idx),
                       picked_quantity2 = picked_quantity2 - l_bo_qty2s(l_cmp_idx),
	               cycle_count_quantity = 0,
                       cycle_count_quantity2 = 0
	           where delivery_detail_id = l_detail_ids(l_cmp_idx);
                   -- DBI needs to track the delivery details whose requested_qty or released_status changes
                   -- Populate the delivery details involved here and then make a single call after the
                   -- loop ends
                   l_detail_tab(l_detail_tab.count + 1) := l_detail_ids(l_cmp_idx);
		END IF;  --}
  	      --}
  	        l_detail_ids.DELETE(l_cmp_idx);

	    -- delivery detail with l_cons_dd_flags(l_cmp_idx)='Y' should be deleted from l_detail_ids.
	    ELSIF ( l_line_ids(l_cmp_idx) = l_curr_line_id ) THEN
	        l_detail_ids.DELETE(l_cmp_idx);
            END IF;
	 --}
            l_cmp_idx := l_detail_ids.NEXT(l_cmp_idx);
        END LOOP; --} inner Loop(l_cmp_idx)

        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity/released_status
        -- are changed, call DBI API after the update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail count-',l_detail_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => l_detail_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          -- just pass this return status to caller API
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- End of Code for DBI Project
        --

	-- Assign the Consolidate BO qtys to the OUT parameter
--Bug 7257451 now storing the remain bo qty's in x_remain_bo_qtys/x_remain_bo_qty2s at same index(l_next_idx)
--as in x_cons_delivery_details_tab so that both table are in sync
	l_next_idx := x_cons_delivery_details_tab.FIRST;
	WHILE l_next_idx IS NOT NULL
	LOOP --{
	    IF x_cons_delivery_details_tab(l_next_idx).source_line_id = l_curr_line_id THEN
		IF x_cons_delivery_details_tab(l_next_idx).req_qty = 0 THEN
			x_remain_bo_qtys(l_next_idx) := 0;
		  	x_remain_bo_qty2s(l_next_idx) := 0;
	        ELSE
		  	x_remain_bo_qtys(l_next_idx) := l_total_bo_qty;
		-- Bug#3670261
		-- Delete the Freight Costs only if Consolidation happens and
		-- if delivery detail is going to be completely backordered.
		IF (l_total_bo_qty > 0 AND
		  x_cons_delivery_details_tab(l_next_idx).req_qty = x_cons_delivery_details_tab(l_next_idx).bo_qty) THEN
		      l_freight_detail_ids(l_freight_detail_ids.COUNT+1) := x_cons_delivery_details_tab(l_next_idx).delivery_detail_id;
		END IF;
		--
	-- HW OPM BUG#:3121616 added qty2s. Added NVL since x_remain_bo_qtys2 is
        -- an OUT parameter and for discrete and OPM single UOM lines returning NULL
        -- will cause a problem
		  	x_remain_bo_qty2s(l_next_idx) := nvl(l_total_bo_qty2,0);
		END IF;
	    END IF;
       	    l_next_idx := x_cons_delivery_details_tab.NEXT(l_next_idx);
	END LOOP;  --}
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'Consolidated Backordered Quantity of the Source Line '||l_curr_line_id||' is '||l_total_bo_qty,WSH_DEBUG_SV.C_PROC_LEVEL);
-- HW OPM BUG#:3121616 added qty2s
	   WSH_DEBUG_SV.logmsg(l_module_name,'Consolidated Backordered Quantity2 of the Source Line '||l_curr_line_id||' is '||l_total_bo_qty2,WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
  	l_idx := l_detail_ids.NEXT(l_idx);
  END LOOP;   -- } Outer Loop(l_idx)

  -- Bug#3670261
  -- Deleting the Freight Costs associated with the delivery details selected for Consolidation
  FORALL i IN 1..l_freight_detail_ids.COUNT
  DELETE FROM WSH_FREIGHT_COSTS
  WHERE  delivery_detail_id = l_freight_detail_ids(i);
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Freight Cost Rows deleted',SQL%ROWCOUNT);
  END IF;

  l_req_qtys.DELETE;
  l_bo_qtys.DELETE;
-- HW OPM BUG#:3121616 added qty2s
  l_bo_qty2s.DELETE;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occired.',wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Delivery_Details',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

END Consolidate_Delivery_Details;


-- K: MDC
PROCEDURE Delete_Consol_Record(
                       p_detail_id_tab IN wsh_util_core.id_tab_type,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'delete_consol_record';
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FORALL i in p_detail_id_tab.first..p_detail_id_tab.LAST
   update wsh_delivery_assignments
   set type = 'S'
   where type = 'O'
   and delivery_detail_id = p_detail_id_tab(i);

   IF sql%found THEN

     FORALL i in p_detail_id_tab.first..p_detail_id_tab.LAST
     delete from wsh_delivery_assignments
     where delivery_detail_id = p_detail_id_tab(i)
     and type = 'C';

   END IF;
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Top_Detail_from_Delivery',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Delete_Consol_Record;

PROCEDURE Create_Consol_Record(
                    p_detail_id_tab IN wsh_util_core.id_tab_type,
                    x_return_status OUT NOCOPY VARCHAR2) IS

 cursor c_get_consolidation_delivery (p_det_id IN NUMBER) is
 select l1.delivery_id, l2.delivery_id
 from wsh_delivery_legs l1, wsh_delivery_legs l2, wsh_delivery_assignments a
 where a.delivery_detail_id = p_det_id
 and l1.delivery_id = a.delivery_id
 and l1.parent_delivery_leg_id = l2.delivery_leg_id
 and a.parent_delivery_detail_id is NULL
 and NVL(a.type, 'S') = 'S';

 l_consol_delivery_id_tab wsh_util_core.id_tab_type;
 l_delivery_id_tab wsh_util_core.id_tab_type;
 l_detail_id_tab wsh_util_core.id_tab_type;
 l_delivery_id NUMBER;
 l_consol_delivery_id NUMBER;
 i NUMBER;
 j NUMBER := 0;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'create_consol_record';

BEGIN
--
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_detail_id_tab.count',p_detail_id_tab.count );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  i := p_detail_id_tab.FIRST;

  WHILE i is NOT NULL LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'p_detail_id_tab(i)',  p_detail_id_tab(i) );
    END IF;
    OPEN c_get_consolidation_delivery(p_detail_id_tab(i));
    FETCH c_get_consolidation_delivery
    INTO l_delivery_id, l_consol_delivery_id;
    IF c_get_consolidation_delivery%FOUND THEN
       j := j + 1;
       l_consol_delivery_id_tab(j) := l_consol_delivery_id;
       l_delivery_id_tab(j) := l_delivery_id;
       l_detail_id_tab(j) := p_detail_id_tab(i);
    END IF;
    CLOSE c_get_consolidation_delivery;
    i := p_detail_id_tab.next(i);

  END LOOP;

  IF l_detail_id_tab.count > 0 THEN

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'updating tabcount', l_detail_id_tab.count);
     END IF;
     FORALL i in l_detail_id_tab.first..l_detail_id_tab.count
     update wsh_delivery_assignments
     set type = 'O',
         parent_delivery_detail_id = NULL
     where NVL(type, 'S') = 'S'
     and delivery_detail_id = l_detail_id_tab(i);

     FORALL i in l_detail_id_tab.first..l_detail_id_tab.count
     INSERT INTO wsh_delivery_assignments (
     delivery_id,
     parent_delivery_id,
     delivery_detail_id,
     parent_delivery_detail_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     program_application_id,
     program_id,
     program_update_date,
     request_id,
     active_flag,
     delivery_assignment_id,
     type
     ) VALUES (
     l_delivery_id_tab(i),
     l_consol_delivery_id_tab(i),
     l_detail_id_tab(i),
     NULL,
     SYSDATE,
     FND_GLOBAL.USER_ID,
     SYSDATE,
     FND_GLOBAL.USER_ID,
     FND_GLOBAL.USER_ID,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     wsh_delivery_assignments_s.nextval,
     'C'
     );


  END IF;


  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Create_Consol_Record;

END WSH_DELIVERY_DETAILS_ACTIONS;

/

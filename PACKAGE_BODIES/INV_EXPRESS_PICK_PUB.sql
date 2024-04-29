--------------------------------------------------------
--  DDL for Package Body INV_EXPRESS_PICK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EXPRESS_PICK_PUB" AS
/* $Header: INVEXPRB.pls 120.4 2006/09/14 10:13:15 bradha noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_EXPRESS_PICK_PUB';
g_true         VARCHAR2(10) := 'T';
g_pr_status_cntr  NUMBER :=0;
/* Cached values for locator control of Org and Sub */
g_organization_id NUMBER;
g_org_loc_control_code NUMBER;
g_subinventory_code    VARCHAR2(10);
g_sub_loc_control_code NUMBER;
G_LOGIN_ID NUMBER;
G_USER_ID NUMBER;
G_LOGIN_ID NUMBER;
G_PROG_APPID NUMBER;
G_PROG_ID   NUMBER;
G_REQUEST_ID  NUMBER;

PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
BEGIN
    inv_pick_wave_pick_confirm_pub.tracelog(p_message, p_module);
END;


-- This function returns TRUE if the reservation passed in is detailed
-- False  otherwise.
FUNCTION check_detailed_rsv(p_mo_line_rec        INV_Move_Order_PUB.TROLIN_REC_TYPE
                           ,p_reservation_rec    INV_reservation_global.mtl_reservation_rec_type)
RETURN BOOLEAN IS

l_detailed    BOOLEAN;
BEGIN
   l_detailed := TRUE;

   IF p_reservation_rec.subinventory_code IS NULL THEN
      Return False;
   END IF;

   IF NOT INV_CACHE.set_item_rec(p_mo_line_rec.organization_id, p_mo_line_rec.inventory_item_id) THEN
      print_debug('Inventory Cache Set Item Rec Failed', 'INV_Express_Pick_Pub.Check_Detailed_Rsv');
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   If (inv_cache.item_rec.lot_control_code = 2) AND l_detailed THEN
      if p_reservation_rec.lot_number IS NULL THEN
         l_detailed := FALSE;
      end if;
   END IF;

   If (inv_cache.item_rec.revision_qty_control_code = 2) AND l_detailed THEN
      if p_reservation_rec.revision IS NULL THEN
         l_detailed := FALSE;
      end if;
   END IF;

   /* Locators not supported - If Org, Item or Sub is locator controlled don't match */
   /* If reservation has locator don't match */
   If (inv_cache.item_rec.location_control_code in (2,3)) THEN
      l_detailed := FALSE;
   END IF;

   If (p_reservation_rec.locator_id is NOT NULL) THEN
      l_detailed := FALSE;
   END IF;

   IF l_detailed THEN
      IF p_mo_line_rec.organization_id <> nvl(g_organization_id,-9999) OR
         p_reservation_rec.subinventory_code <> nvl(g_subinventory_code,'-9999') THEN

         IF NOT INV_CACHE.set_tosub_rec(p_mo_line_rec.organization_id, p_reservation_rec.subinventory_code) THEN
            print_debug('Inventory Cache Set ToSub Rec Failed', 'INV_Express_Pick_Pub.Check_Detailed_Rsv');
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF NOT INV_CACHE.set_org_rec(p_mo_line_rec.organization_id) THEN
            print_debug('Inventory Cache Set ORG Rec Failed', 'INV_Express_Pick_Pub.Check_Detailed_Rsv');
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         g_organization_id := p_mo_line_rec.organization_id;
         g_subinventory_code := p_reservation_rec.subinventory_code;
         g_sub_loc_control_code := inv_cache.org_rec.stock_locator_control_code;
         g_org_loc_control_code := inv_cache.tosub_rec.locator_type;
      END IF;

      If g_sub_loc_control_code in (2,3) OR g_org_loc_control_code in (2,3) THEN
         l_detailed := FALSE;
      end if;
   END IF;

   Return l_detailed;

END check_detailed_rsv;


PROCEDURE PICK_RELEASE ( p_api_version               IN      NUMBER
        ,p_init_msg_list             IN      VARCHAR2
        ,P_commit                    IN      VARCHAR2
        ,x_return_status             OUT NOCOPY     VARCHAR2
        ,x_msg_count                 OUT NOCOPY     NUMBER
        ,x_msg_data                  OUT NOCOPY     VARCHAR2
        ,p_mo_line_tbl               IN      INV_Move_Order_PUB.TROLIN_TBL_TYPE
        ,p_grouping_rule_id          IN      NUMBER
        ,p_allow_partial_pick        IN      VARCHAR2
        ,p_reservations_tbl          IN      inv_reservation_global.mtl_reservation_tbl_type
        ,p_pick_release_status_tbl   OUT NOCOPY     inv_express_pick_pub.p_pick_release_status_tbl
        ) IS

/*CURSOR c_rsv_rec (p_demand_source_type_id   NUMBER
                 ,p_demand_source_line_id   NUMBER) IS
      SELECT   reservation_id
             , requirement_date
             , organization_id
             , inventory_item_id
             , demand_source_type_id
             , demand_source_name
             , demand_source_header_id
             , demand_source_line_id
             , demand_source_delivery
             , primary_uom_code
             , primary_uom_id
             , reservation_uom_code
             , reservation_uom_id
             , reservation_quantity
             , primary_reservation_quantity
             , detailed_quantity
             , autodetail_group_id
             , external_source_code
             , external_source_line_id
             , supply_source_type_id
             , supply_source_header_id
             , supply_source_line_id
             , supply_source_name
             , supply_source_line_detail
             , revision
             , subinventory_code
             , subinventory_id
             , locator_id
             , lot_number
             , lot_number_id
             , pick_slip_number
             , lpn_id
             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
             , ship_ready_flag
         from mtl_reservations
         where demand_source_type_id =p_demand_source_type_id
           and demand_source_line_id = p_demand_source_line_id
           and supply_source_type_id = 13
           and nvl(Staged_flag,'N') <> 'Y'
           and nvl(detailed_quantity,0) = 0
         order by primary_reservation_quantity;
	 Commented out for 3237610*/


l_rsv_rec_tbl   inv_reservation_global.mtl_reservation_tbl_type ;
l_rsv_rec_ret_tbl   inv_reservation_global.mtl_reservation_tbl_type ;
l_rsv_rec       inv_reservation_global.mtl_reservation_rec_type;
l_rsv_rec_param       inv_reservation_global.mtl_reservation_rec_type; --Added for bug3237610
l_return_status         VARCHAR2(1);
l_loop_index            NUMBER;
l_loop_status           NUMBER;
l_line_index            NUMBER;
l_delivery_detail_id    NUMBER;
l_source_type_id        NUMBER;
l_source_line_id        NUMBER;
l_debug                 NUMBER;
is_debug                BOOLEAN;
l_ship_set_start_index  NUMBER;
l_ship_set_start_status NUMBER;
l_cur_ship_set_id       NUMBER;
l_rsv_qty               NUMBER;
l_dd_qty                NUMBER;
l_error_code            NUMBER; --Bug3237610 added code
l_counter               NUMBER; -- Added for Bug3237610
    l_rsv_count         NUMBER;
    l_dtl_rsv_count         NUMBER;
    l_mo_line_count     NUMBER;
    l_api_version     CONSTANT NUMBER                             := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)                       := 'Express_Pick_Release';
l_staged_flag         VARCHAR2(2);
l_rsv_start         NUMBER;   -- Added for bug 3946186

BEGIN

   -- because the debug profile  rarely changes, only check it once per
   -- session, instead of once per batch
   IF is_debug IS NULL THEN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     if l_debug = 1 then
       is_debug := TRUE;
     else
       is_debug := FALSE;
     end if;
   END IF;

   -- Set savepoint for this API
   If is_debug then
    print_debug('Inside Express Pick_Release', 'INV_Express_Pick_Pub.Pick_Release');
   End If;

   SAVEPOINT EXPRESS_PICK_RELEASE;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.Compatible_API_Call(l_api_version , p_api_version ,
        l_api_name , G_PKG_NAME) THEN
     If is_debug then
      print_debug('Fnd_APi not compatible','INV_Express_Pick_Pub.Pick_Release');
     End If;
     RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_Boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   -- Validate parameters

   -- First determine whether the table of move order lines in p_mo_line_tbl has
   -- any records
   l_mo_line_count := p_mo_line_tbl.COUNT;
   IF l_mo_line_count = 0 THEN
     If is_debug then
       print_debug('No Lines to pick', 'INV_Express_Pick_Pub.Pick_Release');
     End If;

      ROLLBACK TO EXPRESS_PICK_RELEASE;
      FND_MESSAGE.SET_NAME('INV','INV_NO_LINES_TO_PICK');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Validate parameter for allowing partial pick release
   IF p_allow_partial_pick <> fnd_api.g_true AND
      p_allow_partial_pick <> fnd_api.g_false THEN

      If is_debug then
        print_debug('Error: invalid partial pick parameter',
                    'INV_Express_Pick_Pub.Pick_Release');
      End If;
      ROLLBACK TO Express_Pick_Release;
      FND_MESSAGE.SET_NAME('INV','INV_INVALID_PARTIAL_PICK_PARAM');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   /*Start with first delivery detail in the list */
   l_loop_index :=   p_mo_line_tbl.first;
   g_pr_status_cntr := 1;

   LOOP
     l_line_index := l_loop_index;
     /* Use this to reset line_index whether staying on current line or skipping
        to end of failed shipset */
     l_loop_index := l_line_index + 1;
     If is_debug then
         print_debug('Loop through delivery details',
                     'Inv_Express_Pick_Pub.Pick_Release');
     End If;
     IF p_mo_line_tbl(l_line_index).ship_set_id IS NOT NULL AND
         (l_cur_ship_set_id IS NULL OR
          l_cur_ship_set_id <> p_mo_line_tbl(l_line_index).ship_set_id) THEN

        SAVEPOINT SHIPSET;
        l_cur_ship_set_id := p_mo_line_tbl(l_line_index).ship_set_id;
        l_ship_set_start_index := l_line_index;
        l_ship_set_start_status := g_pr_status_cntr;
        If is_debug then
          print_debug('Start Shipset :' || l_cur_ship_set_id,
                     'Inv_Express_Pick_Pub.Pick_Release');
        End If;
     ELSIF l_cur_ship_set_id IS NOT NULL AND
           p_mo_line_tbl(l_line_index).ship_set_id IS NULL THEN
       If is_debug then
         print_debug('End of Shipset :' || l_cur_ship_set_id,
                     'Inv_Express_Pick_Pub.Pick_Release');
       End If;
        l_cur_ship_set_id := NULL;
        l_ship_set_start_index := NULL;
        l_ship_set_start_status := NULL;
     END IF;

     If is_debug then
        print_debug('Current positions - line_index : ' || l_line_index ||
                   '  g_pr_status_cntr : ' || g_pr_status_cntr,
                   'Inv_Express_Pick_Pub.Pick_Release');
     End If;
     l_delivery_detail_id:= p_mo_line_tbl(l_line_index).txn_source_line_detail_id;
     p_pick_release_status_tbl(g_pr_status_cntr).delivery_detail_id := l_delivery_detail_id;

     IF NOT INV_CACHE.set_mtt_rec(p_mo_line_tbl(l_line_index).transaction_type_id) THEN
        print_debug('Inventory Cache Set Transaction Type Rec Failed', 'INV_Express_Pick_Pub.Pick_Release');
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     l_source_type_id := inv_cache.mtt_rec.transaction_source_type_id;
     l_source_line_id := p_mo_line_tbl(l_line_index).TXN_source_line_id;

     If is_debug then
        print_debug('Checking reservations for Delivery Detail : ' || l_delivery_detail_id,
                   'Inv_Express_Pick_Pub.Pick_Release');
     End If;
     /* Get  All Unstaged reservations for SALES ORDER LINE  */
     /* and ignore all unstaged or non detailed reservations */
     l_rsv_count := 0;
     l_dtl_rsv_count := 0;
     l_rsv_qty := 0;
     l_rsv_rec_tbl.delete;

     /* Added for bug3237610*/
     --l_rsv_rec_param.staged_flag := 'N';
     l_rsv_rec_param.demand_source_type_id := l_source_type_id;
     l_rsv_rec_param.demand_source_line_id := l_source_line_id;
     l_rsv_rec_param.supply_source_type_id := 13;

     inv_reservation_pub.query_reservation(
      p_api_version_number          =>  p_api_version
      , x_return_status             =>  x_return_status
      , x_msg_count                 =>  x_msg_count
      , x_msg_data                  =>  x_msg_data
      , p_query_input               =>  l_rsv_rec_param
      , x_mtl_reservation_tbl       =>  l_rsv_rec_ret_tbl
      , x_mtl_reservation_tbl_count =>  l_rsv_count
      , x_error_code                =>  l_error_code
     );

     IF is_debug then
          print_debug('l_return_status from query_reservation is '
            || x_return_status, 'Inv_Express_Pick_Pub.Pick_Release');
        End If;

        IF x_return_status = fnd_api.g_ret_sts_error THEN
           IF is_debug then
             print_debug('Error from INV_QUANTITY_TREE_PVT.Lock_Tree',
                        'Inv_Express_Pick_Pub.Pick_release');
           END IF;
           RAISE fnd_api.g_exc_error ;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
           If is_debug then
             print_debug('Unexpected error from INV_QUANTITY_TREE_PVT.Lock_Tree',
                        'Inv_Express_Pick_Pub.Pick_release');
           End If;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
    /*Bug3237610 ends*/

     If is_debug then
        print_debug('Number of reservations ' || l_rsv_count, 'Inv_Express_Pick_Pub.Pick_Release');
     End If;
     l_rsv_start := 1;
     --l_rsv_count := l_rsv_rec_tbl.count;
     FOR l_counter IN l_rsv_start..l_rsv_count LOOP
        --l_rsv_rec := l_rsv_rec_tbl(l_counter);

       --Added bug3237610

        If is_debug then
           print_debug('Check whether reservation detailed rsv id : ' || l_rsv_rec_ret_tbl(l_counter).reservation_id, 'Inv_Express_Pick_Pub.Pick_Release');
        End If;
        inv_staged_reservation_util.query_staged_flag
           (x_return_status  => x_return_status
            ,x_msg_count      => x_msg_count
            ,x_msg_data       => x_msg_data
            ,x_staged_flag    => l_staged_flag
            ,p_reservation_id  => l_rsv_rec_ret_tbl(l_counter).reservation_id);

         IF is_debug then
          print_debug('l_return_status from query_staged_flag is '
            || x_return_status, 'Inv_Express_Pick_Pub.Pick_Release');
        End If;

        IF x_return_status = fnd_api.g_ret_sts_error THEN
           IF is_debug then
             print_debug('Error from INV_QUANTITY_TREE_PVT.Lock_Tree',
                        'Inv_Express_Pick_Pub.Pick_release');
           END IF;
           RAISE fnd_api.g_exc_error ;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
           If is_debug then
             print_debug('Unexpected error from INV_QUANTITY_TREE_PVT.Lock_Tree',
                        'Inv_Express_Pick_Pub.Pick_release');
           End If;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --End bug3237610

        IF nvl(l_staged_flag,'N') <>  'Y' then
         IF check_detailed_rsv(p_mo_line_tbl(l_line_index), l_rsv_rec_ret_tbl(l_counter)) THEN
            l_dtl_rsv_count := l_dtl_rsv_count +1;
            l_rsv_rec_tbl(l_dtl_rsv_count):= l_rsv_rec_ret_tbl(l_counter);
            l_rsv_qty := l_rsv_qty+l_rsv_rec_ret_tbl(l_counter).primary_reservation_quantity;
            If is_debug then
             print_debug('Reservation is Detailed' || l_dtl_rsv_count, 'Inv_Express_Pick_Pub.Pick_Release');
            End If;
         END IF;
        END IF;
     END LOOP;

     l_dd_qty := p_mo_line_tbl(l_line_index).quantity ;
     /* This is  expected quantity to Pick release */
     If is_debug then
        print_debug('Quantity required to be Detailed ' || l_dd_qty, 'Inv_Express_Pick_Pub.Pick_Release');
        print_debug('Quantity in detailed reservations' || l_rsv_qty, 'Inv_Express_Pick_Pub.Pick_Release');
        print_debug('Current Ship Set ' || l_cur_ship_set_id, 'Inv_Express_Pick_Pub.Pick_Release');
     End If;


     IF (l_rsv_qty > 0) AND
        ((l_rsv_qty  >= l_dd_qty) OR
         ((l_rsv_qty < l_dd_qty) AND (p_allow_partial_pick = g_true) AND (l_cur_ship_set_id IS NULL)))
        THEN
       --Lock item/org comobo so that no Pick release process could not  release them concurrently.

        INV_QUANTITY_TREE_PVT.Lock_Tree(p_api_version_number => l_api_version
                          , p_init_msg_lst       => fnd_api.g_false
                          , x_return_status      => x_return_status
                          , x_msg_count          => x_msg_count
                          , x_msg_data           => x_msg_data
                          , p_organization_id    => p_mo_line_tbl(l_line_index).organization_id
                          , p_inventory_item_id  => p_mo_line_tbl(l_line_index).inventory_item_id);

        IF is_debug then
          print_debug('l_return_status from lock_tree is '
            || x_return_status, 'Inv_Express_Pick_Pub.Pick_Release');
        End If;

        IF x_return_status = fnd_api.g_ret_sts_error THEN
           IF is_debug then
             print_debug('Error from INV_QUANTITY_TREE_PVT.Lock_Tree',
                        'Inv_Express_Pick_Pub.Pick_release');
           END IF;
           RAISE fnd_api.g_exc_error ;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
           If is_debug then
             print_debug('Unexpected error from INV_QUANTITY_TREE_PVT.Lock_Tree',
                        'Inv_Express_Pick_Pub.Pick_release');
           End If;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        stage_dd_rsv(p_mo_line_rec    => P_MO_LINE_TBL(l_line_index)
                   , p_reservation_tbl     => L_RSV_REC_TBL
                   , p_pick_release_status_tbl   => p_pick_release_status_tbl
                   , x_return_status       => x_return_status
                   , x_msg_count           => x_msg_count
                   , x_msg_data            => x_msg_data);

        IF x_return_status = fnd_api.g_ret_sts_error THEN
           IF is_debug then
             print_debug('Error from Stage_DD_RSV',
                        'Inv_Express_Pick_Pub.Pick_release');
           END IF;
           RAISE fnd_api.g_exc_error ;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
           If is_debug then
             print_debug('Unexpected error from Stage DD RSV',
                        'Inv_Express_Pick_Pub.Pick_release');
           End If;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;


     ELSE -- l_rsv_qty =0  OR partial not allowed

         -- For shipsets, if any of the lines fail to allocate completely,
         -- rollback all allocations and then Skip all delivery details in Ship Set
         -- Report skipped status to shipping
        If is_debug then
           print_debug('Update shipping that ship set detailing failed',
                       'Inv_Express_Pick_Pub.Pick_Release');
        End If;

        If l_cur_ship_set_id is not null then
           If is_debug then
              print_debug('Rollback for shipset :' || l_cur_ship_set_id,
                        'Inv_Express_Pick_Pub.Pick_Release');
           End If;

           ROLLBACK TO SHIPSET;
           l_loop_index :=l_ship_set_start_index;
           l_loop_status := l_ship_set_start_status;
           LOOP
              p_pick_release_status_tbl(l_loop_status).Pick_status:='I';
              IF p_pick_release_status_tbl(l_loop_status).delivery_detail_id IS NULL THEN
                 p_pick_release_status_tbl(l_loop_status).delivery_detail_id :=  p_mo_line_tbl(l_loop_index).txn_source_line_detail_id;
              END IF;

              EXIT WHEN p_mo_line_tbl.LAST = l_loop_index;

              l_loop_status :=l_loop_status + 1;

              IF (l_loop_status > p_pick_release_status_tbl.LAST) OR
                 (p_pick_release_status_tbl(l_loop_status).delivery_detail_id <> p_mo_line_tbl(l_loop_index).txn_source_line_detail_id) THEN
                 l_loop_index :=l_loop_index + 1;
              END IF;

              Exit when l_cur_ship_set_id <> p_mo_line_tbl(l_loop_index).ship_set_id;
           END LOOP;
	   -- If loop reaches end of deliveries then set line_index to loop_index to force
           -- exit from outer loop processing deliveries
           IF (p_mo_line_tbl.LAST = l_loop_index) THEN
              l_line_index := l_loop_index;
           END IF;
        END IF;

        p_pick_release_status_tbl(g_pr_status_cntr).Pick_status:='F';
        g_pr_status_cntr := p_pick_release_status_tbl.LAST + 1;
     END IF;

     EXIT WHEN l_line_index = p_mo_line_tbl.last;
   END LOOP;  ---Main Loop
EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO EXPRESS_PICK_RELEASE;
         --dbms_output.put_line('SQLERRM'||SQLERRM);
         print_debug('SQLERRM'||SQLERRM, 'Inv_Express_Pick_Pub.Pick_Release');
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN OTHERS THEN
        ROLLBACK TO EXPRESS_PICK_RELEASE;
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);

END PICK_RELEASE;


PROCEDURE   STAGE_DD_RSV(P_mo_line_REC             IN INV_Move_Order_PUB.Trolin_Rec_Type
	                ,p_Reservation_tbl         IN inv_reservation_global.mtl_reservation_tbl_type
                        ,p_pick_release_status_tbl IN OUT NOCOPY INV_EXPRESS_PICK_PUB.p_pick_release_status_tbl
                       , x_return_status      OUT NOCOPY VARCHAR2
                       , x_msg_count          OUT NOCOPY NUMBER
                       , x_msg_data           OUT NOCOPY VARCHAR2) IS
/*This API stage a Delivery detail if reservations are detailed
and also mark serials and update reservations.
This require Digital enhancement as pre-req to work correctly if items are serial controlled
since we are not exploding serialized items.

Kalyan
*/

TYPE  inv_staged_rsv_id_rec   IS RECORD
    ( delivery_detail_id         NUMBER
     ,Split_delivery_detail_id   NUMBER
     ,Reservation_id             NUMBER
     ,Transaction_temp_id        NUMBER
     ,l_serial_index             NUMBER
     ,staged_quantity            NUMBER
     ,staged_secondary_quantity  NUMBER --INVCONV kkillams
      );
TYPE inv_staged_rsv_id_tbl is TABLE of inv_staged_rsv_id_rec
INDEX BY BINARY_INTEGER;
L_API_NAME     VARCHAR2(20):='STAGED_DD_RSV';
l_rsv_rec_tbl     inv_reservation_global.mtl_reservation_tbl_type ;
l_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
l_original_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
l_new_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
l_orig_delivery_detail_id NUMBER;
l_staged_rsv_id_tbl  inv_staged_rsv_id_tbl;
l_shipping_attr               wsh_interface.changedattributetabtype;
l_original_serial_number inv_reservation_global.serial_number_tbl_type;

l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_rsv_index NUMBER :=0; --Split rsv counter
l_remain_dd_qty NUMBER :=0;
l_new_dd_id  NUMBER;
l_qty2 NUMBER;
l_rsv_temp_rec   inv_reservation_global.mtl_reservation_rec_type;
l_mtl_reservation   inv_reservation_global.mtl_reservation_tbl_type ;
l_mtl_reservation_count NUMBER;

l_temp_index NUMBER :=0;
l_delivery_detail_id  NUMBER;
l_source_header_id    NUMBER;
l_source_line_id      NUMBER;
l_orig_dd_req_qty     NUMBER;
l_rsv_count           NUMBER;
l_reserved_qty        NUMBER;

L_NEW_RESERVATION_ID  NUMBER;
DELIVERY_DETAIL_ID    NUMBER;
L_TRANSACTION_TEMP_ID NUMBER;
l_reservation_id      NUMBER;
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(100);
L_ERROR_CODE          VARCHAR2(100);
l_index               NUMBER;
l_res_index           NUMBER;  --Split wdd counter
l_to_serial_number     inv_reservation_global.serial_number_tbl_type;
l_last_rsv            BOOLEAN:=false;
l_rsv_last_index      NUMBER:=0;

l_serial_number_control_code NUMBER:=0;
is_serial_controlled Boolean :=false;
l_serial_number  VARCHAR2(30);
x_available_sl_qty NUMBER:=0;
x_serial_index     NUMBER;
x_serial_number    VARCHAR2(30);
g_transaction_temp_id NUMBER;
l_transferred_rsv_qty NUMBER :=0;
l_partial_pick BOOLEAN :=false;
l_InvPCInRecType              wsh_integration.invpcinrectype;

--INVCONV kkillams
l_orig_sec_req_qty        NUMBER;
l_remain_sec_qty          NUMBER;
l_reserved_sec_qty        NUMBER;
l_available_sec_qty       NUMBER := 0;
l_transferred_rsv_sec_qty NUMBER := 0;
l_preferred_grade         VARCHAR2(150);
--END INVCONV kkillams


BEGIN
x_return_status :=fnd_api.g_ret_sts_success;
  IF NOT INV_CACHE.set_item_rec(p_mo_line_rec.organization_id, p_mo_line_rec.inventory_item_id) THEN
     print_debug('Inventory Cache Set Item Rec Failed', 'INV_Express_Pick_Pub.Pick_Release');
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  IF inv_cache.item_rec.serial_number_control_code NOT IN (1,6) then
   print_debug('Item is Serialized ','INV_Express_Pick_Pub.Pick_Release');
     is_serial_controlled :=true;
  END IF;

l_rsv_rec_tbl :=p_Reservation_tbl;
l_orig_delivery_detail_id := P_mo_line_rec.txn_source_Line_detail_id;
l_orig_dd_req_qty :=P_MO_LINE_REC.quantity;
l_remain_dd_qty := l_orig_dd_req_qty;

--INVCONV kkillams
l_orig_sec_req_qty    := p_mo_line_rec.secondary_quantity;
l_remain_sec_qty      := p_mo_line_rec.secondary_quantity;
--END INVCONV kkillams

      l_rsv_index := l_rsv_rec_tbl.FIRST;
      l_rsv_count :=l_rsv_rec_tbl.count;
      l_rsv_last_index :=l_rsv_rec_tbl.LAST;
      print_debug(' l_rsv_last_index '||l_rsv_last_index,'EXPRESS_PICK');
      print_debug('Reservation count '||l_rsv_count,'INV_Express_Pick_Pub.Pick_Release');
      LOOP
        l_original_rsv_rec := l_rsv_rec_tbl(l_rsv_index);
        l_new_rsv_rec :=l_original_rsv_rec;
        l_new_rsv_rec.reservation_id:=NULL;
        l_reserved_qty := l_original_rsv_rec.primary_reservation_quantity;
        l_reserved_sec_qty := l_original_rsv_rec.secondary_reservation_quantity;  --INVCONV KKILLAMS
        print_debug('l_current_reserved_qty '||l_reserved_qty,'INV_Express_Pick_Pub.Pick_Release');
        print_debug('l_remain_dd_qty 1 '||l_remain_dd_qty,'INV_Express_Pick_Pub.Pick_Release');
        IF l_remain_dd_qty >l_reserved_qty THEN
           l_new_rsv_rec.primary_reservation_quantity :=l_reserved_qty;
           l_new_rsv_rec.reservation_quantity :=NULL;
           l_remain_dd_qty :=l_remain_dd_qty -l_reserved_qty;
           --INVCONV kkillams
           l_new_rsv_rec.secondary_reservation_quantity := l_reserved_sec_qty;
           l_remain_sec_qty :=NVL(l_remain_sec_qty,0) -NVL(l_reserved_sec_qty,0);
           IF l_remain_sec_qty = 0 THEN
              l_remain_sec_qty := NULL;
           END IF;
           --END INVCONV kkillams
        ELSE
           l_new_rsv_rec.primary_reservation_quantity := l_remain_dd_qty;
           l_remain_dd_qty :=0;
           --INVCONV kkillams
           l_new_rsv_rec.secondary_reservation_quantity := l_remain_sec_qty;

           IF l_remain_sec_qty IS NOT NULL THEN
              l_remain_sec_qty :=0;
           END IF;
           --END INVCONV kkillams
        END IF;--Remain_dd_qty

	IF l_new_rsv_rec.secondary_reservation_quantity = 0 THEN
		l_new_rsv_rec.secondary_reservation_quantity := NULL;
	END IF;
            print_debug('modified l_remain_dd_qty 1 '||l_remain_dd_qty,'INV_Express_Pick_Pub.Pick_Release');
            IF IS_SERIAL_CONTROLLED THEN
                             print_debug('Calling Pick serial Numbers ','INV_Express_Pick_Pub.Pick_Release');
                             PICK_SERIAL_NUMBERS(
                                 p_inventory_item_id	=>l_new_rsv_rec .inventory_item_id
                                , p_organization_id	=> l_new_rsv_rec.organization_id
                                , p_revision		=> l_new_rsv_rec.revision
                                , p_lot_number		=>   l_new_rsv_rec.lot_number
                                 ,p_subinventory_code	=> l_new_rsv_rec.subinventory_code
                                , p_locator_id		=> l_new_rsv_rec.locator_id
                                , p_required_sl_qty      => l_new_rsv_rec.primary_reservation_quantity
                                , p_unit_number          => null
                                , p_reservation_id       => l_original_rsv_rec.reservation_id -- Bug 5517498
                                , x_available_sl_qty     => x_available_sl_qty
                                , g_transaction_temp_id  => g_transaction_temp_id
                                , x_serial_index         => x_serial_index
                                , x_return_status        => l_return_status
                                , x_msg_count            => l_msg_count
                                , x_msg_data             => l_msg_data
                                , x_serial_number        => x_serial_number  -- Bug 5517498
				);
                             print_debug('return status '||l_return_status,'INV_Express_Pick_Pub.Pick_Release');
                             print_debug('g_transaction_temp_id'||g_transaction_temp_id,'INV_Express_Pick_Pub.Pick_Release');
                             print_debug('Available Serial qty'||x_available_sl_qty,'INV_Express_Pick_Pub.Pick_Release');
                             print_debug('x_serial_index'||x_serial_index,'INV_Express_Pick_Pub.Pick_Release');
             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
               IF x_available_sl_qty < l_new_rsv_rec.primary_reservation_quantity THEN
                   l_remain_dd_qty := l_remain_dd_qty +  (l_new_rsv_rec.primary_reservation_quantity- x_available_sl_qty);
                   l_new_rsv_rec.primary_reservation_quantity := x_available_sl_qty;
                   --INVCONV kkillams
                   IF l_new_rsv_rec.secondary_uom_code IS NOT NULL THEN
                     l_available_sec_qty:=    inv_convert.inv_um_convert(
                                                    ITEM_ID                  => l_new_rsv_rec.inventory_item_id,
                                                    LOT_NUMBER               => l_new_rsv_rec.lot_number,
                                                    ORGANIZATION_ID          => l_new_rsv_rec.organization_id,
                                                    PRECISION                => NULL,
                                                    FROM_QUANTITY            => x_available_sl_qty,
                                                    FROM_UNIT                => l_new_rsv_rec.primary_uom_code,
                                                    TO_UNIT                  => l_new_rsv_rec.secondary_uom_code,
                                                    FROM_NAME                => NULL,
                                                    TO_NAME                  => NULL);
                   l_remain_sec_qty := NVL(l_remain_sec_qty,0) +  (NVL(l_new_rsv_rec.secondary_reservation_quantity,0) - NVL(l_available_sec_qty,0));
                   IF l_remain_sec_qty =0 THEN
                      l_remain_sec_qty :=  NULL;
                   END IF;
                   l_new_rsv_rec.secondary_reservation_quantity := l_available_sec_qty;

                   END IF;
                   --END INVCONV kkillams
               END IF;


	      -- Bug 5517498 Passing serial_reservation_quantity and serial_number to the new reservation record
              l_new_rsv_rec.serial_reservation_quantity := x_available_sl_qty;
              IF x_available_sl_qty = 1 THEN
	        l_new_rsv_rec.serial_number := x_serial_number;
              END IF;
           END IF;
            l_transferred_rsv_qty :=l_transferred_rsv_qty + l_new_rsv_rec.primary_reservation_quantity;
             --      l_new_rsv_rec.staged_flag := 'Y';
              l_new_rsv_rec.detailed_quantity :=0;
              l_new_rsv_rec.ship_ready_flag := 1;
              l_new_rsv_rec.requirement_date :=SYSDATE;
--dbms_output.put_line('about to call transfer_reservation');
               inv_reservation_pub.transfer_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_original_rsv_rec           => l_original_rsv_rec
              , p_to_rsv_rec                 => l_new_rsv_rec
              , p_original_serial_number     => l_to_serial_number
              , p_to_serial_number           => l_to_serial_number
              , p_validation_flag            => fnd_api.g_false
              , x_to_reservation_id          => l_reservation_id
              );
             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;


--dbms_output.put_line('l_return_status '||l_return_status);
print_debug('msg from Transfer rsv '||substr(l_msg_data,1,100),'INV_Express_pick.Pick_release');
            inv_staged_reservation_util.update_staged_flag(x_return_status => l_return_status,
                                                           x_msg_count => x_msg_count,
                                                           x_msg_data => x_msg_data,
                                                           p_reservation_id => l_reservation_id,
                                                           p_staged_flag => 'Y');
            IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            if l_remain_dd_qty >0  then
              print_debug('Calling Split line','INV_Express_pick.Pick_release ');

                  WSH_DELIVERY_DETAILS_PUB.split_line(
                      p_api_version => 1.0
                    , x_return_status    => l_return_status
                    , x_msg_count        => l_msg_count
                    , x_msg_data         => l_msg_data
                    ,p_from_detail_id => l_orig_delivery_detail_id
                    ,x_new_detail_id  => l_new_dd_id
                    ,x_split_quantity  => l_new_rsv_rec.primary_reservation_quantity
                    ,x_split_quantity2 => l_new_rsv_rec.secondary_reservation_quantity);
                 print_debug('Return status '||l_return_status,'INV_Express_pick.Pick_release ');
                 print_debug('l_new_dd_id '||l_new_dd_id,'INV_Express_pick.Pick_release ');
              IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
             end if; --l_remain_dd_qty >0
               l_temp_index :=l_temp_index+1;
            l_staged_rsv_id_tbl(l_temp_index).reservation_id :=l_reservation_id;
            l_staged_rsv_id_tbl(l_temp_index).staged_quantity := l_new_rsv_rec.primary_reservation_quantity;
            l_staged_rsv_id_tbl(l_temp_index).staged_secondary_quantity := l_new_rsv_rec.secondary_reservation_quantity; --INVCONV kkillams
            l_staged_rsv_id_tbl(l_temp_index).delivery_detail_id :=l_orig_delivery_detail_id;
            if l_new_dd_id is NOT NULL then
            l_staged_rsv_id_tbl(l_temp_index).Split_delivery_detail_id:=l_new_dd_id;
            end if;
              l_new_dd_id :=NULL;
            l_staged_rsv_id_tbl(l_temp_index).Transaction_temp_id :=g_transaction_temp_id;
            l_staged_rsv_id_tbl(l_temp_index).l_serial_index :=x_serial_index;
           EXIT WHEN l_rsv_index =l_rsv_rec_tbl.LAST OR l_remain_dd_qty =0 ;
              l_rsv_index :=l_rsv_rec_tbl.NEXT(l_rsv_index);
       END LOOP;
      if l_orig_dd_req_qty > l_transferred_rsv_qty then
       print_debug('Partial Pick Total Staged'||l_transferred_rsv_qty, 'INV_Express_pick.Pick_release ');
       l_partial_pick :=true;
      end if;

 --Now split wdd for each reservation record and call shipping to stage them
        FOR  l_index IN 1..l_staged_rsv_id_tbl.count LOOP
              l_res_index := l_index;
           l_rsv_temp_rec :=NULL;
           l_rsv_temp_rec.reservation_id :=l_staged_rsv_id_tbl(l_res_index).reservation_id;
        print_debug('Current reservation_id '||l_rsv_temp_rec.reservation_id,
                       'INV_Express_pick.Pick_release ');
         inv_reservation_pub.query_reservation(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_query_input                => l_rsv_temp_rec
        , x_mtl_reservation_tbl        => l_mtl_reservation
        , x_mtl_reservation_tbl_count  => l_mtl_reservation_count
        , x_error_code                 => l_error_code
        );
             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

 print_debug('Split WDD'||l_staged_rsv_id_tbl(l_res_index).split_delivery_detail_id
                     ,'INV_Express_pick.Pick_release ');

 print_debug('Original WDD '||l_staged_rsv_id_tbl(l_res_index).delivery_detail_id
                  ,'INV_Express_pick.Pick_release ');
   --Lock newly created WDD and original also.
       BEGIN
        SELECT     delivery_detail_id
                 , source_header_id
                 , source_line_id
                 , preferred_grade  --INVCONV kkillams
              INTO l_delivery_detail_id
                 , l_source_header_id
                 , l_source_line_id
                 , l_preferred_grade  --INVCONV kkillams
              FROM wsh_delivery_details
             WHERE delivery_detail_id =
                  nvl(l_staged_rsv_id_tbl(l_res_index).split_delivery_detail_id,
                        l_staged_rsv_id_tbl(l_res_index).delivery_detail_id)
              FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('INV', 'INV_DELIV_INFO_MISSING');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
      l_shipping_attr(1).preferred_grade      := l_preferred_grade;  --INVCONV kkillams
      l_shipping_attr(1).source_header_id     := l_source_header_id;
      l_shipping_attr(1).source_line_id       := l_source_line_id;
      l_shipping_attr(1).ship_from_org_id     := l_mtl_reservation(1).organization_id;
      l_shipping_attr(1).subinventory         := l_mtl_reservation(1).subinventory_code;
      l_shipping_attr(1).revision             := l_mtl_reservation(1).revision;
      l_shipping_attr(1).lot_number           := l_mtl_reservation(1).lot_number;
      l_shipping_attr(1).locator_id           := l_mtl_reservation(1).locator_id;
      l_shipping_attr(1).Picked_quantity      := l_staged_rsv_id_tbl(l_res_index).staged_quantity;
      l_shipping_attr(1).Picked_quantity2     := l_staged_rsv_id_tbl(l_res_index).staged_secondary_quantity;  ---INVCONV kkillams
      l_shipping_attr(1).released_status      := 'Y';
      l_shipping_attr(1).delivery_detail_id   := nvl(l_staged_rsv_id_tbl(l_res_index).split_delivery_detail_id,
                     l_staged_rsv_id_tbl(l_res_index).delivery_detail_id);
      -- BUG 3604139
      -- For each reservation reset the transaction_temp_id passed to shipping. This caused a problem
      -- when moving from passing in a single serial number to many serial numbers, as shipping
      -- expects either the single serial or the transaction_temp_id not both.
      l_InvPCInRecType.transaction_temp_id := NULL;
      l_shipping_attr(1).serial_number := NULL;
      IF l_staged_rsv_id_tbl(l_res_index).transaction_temp_id IS NOT NULL THEN
         IF l_staged_rsv_id_tbl(l_res_index).l_serial_index > 1 THEN
              l_InvPCInRecType.transaction_temp_id :=l_staged_rsv_id_tbl(l_res_index).transaction_temp_id;

         ELSE
           SELECT fm_serial_number INTO l_serial_number
           FROM mtl_serial_numbers_temp WHERE
                transaction_temp_id = l_staged_rsv_id_tbl(l_res_index).transaction_temp_id;
           print_debug('fm_serial_number '||l_serial_number,'Inv_Express_Pick.Pick_release');
           l_shipping_attr(1).serial_number :=l_serial_number;
         END IF;
     END IF;


     l_InvPCInRecType.source_code :='INV';
     l_InvPCInRecType.api_version_number :=1.0;
     WSH_INTEGRATION.Set_Inv_PC_Attributes
        ( p_in_attributes         =>   l_InvPCInRecType,
          x_return_status         =>   l_return_status,
          x_msg_count             =>   l_msg_count,
          x_msg_data             =>    l_msg_data );
     print_debug('after Set_Inv_PC_Attributes Ret status'||l_return_status, 'Inv_Express_Pick.Pick_release');

     IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        print_debug('return error E from Set_Inv_PC_Attributes', 'Inv_Express_Pick.Pick_release');
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        print_debug('return error U from Set_Inv_PC_Attributes', 'Inv_Express_Pick.Pick_release');
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

            l_shipping_attr(1).action_flag:='U';
           wsh_interface.update_shipping_attributes(p_source_code => 'INV',
                                                    p_changed_attributes => l_shipping_attr,
                                                    x_return_status => l_return_status);
         IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         p_pick_release_status_tbl(g_pr_status_cntr).delivery_detail_id := l_staged_rsv_id_tbl(l_res_index).delivery_detail_id;
         p_pick_release_status_tbl(g_pr_status_cntr).Pick_status :='S';
      if l_staged_rsv_id_tbl(l_res_index).split_delivery_detail_id is not null then
         p_pick_release_status_tbl(g_pr_status_cntr).split_delivery_id := l_staged_rsv_id_tbl(l_res_index).split_delivery_detail_id;
      end if;
         g_pr_status_cntr :=g_pr_status_cntr+1;

      END LOOP;
      if l_partial_pick then   --Load original WDD if partial Pick otherwise shipping do not know
       p_pick_release_status_tbl(g_pr_status_cntr).delivery_detail_id := l_orig_delivery_detail_id;
        p_pick_release_status_tbl(g_pr_status_cntr).Pick_status :='P';
         g_pr_status_cntr :=g_pr_status_cntr+1;
      end if;
x_return_status :=l_return_status ;
print_debug(' Exit status from Stage_dd_rsv'||x_return_status,'Inv_Express_pick.Pick_release' );

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('SQLERRM'||SQLERRM);
        --
        x_return_status := FND_API.G_RET_STS_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('SQLERRM'||SQLERRM);
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN OTHERS THEN
        --ROLLBACK TO EXPRESS_PICK_PUB;
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
END STAGE_DD_RSV;

PROCEDURE   PICK_SERIAL_NUMBERS(
                                  p_inventory_item_id	IN NUMBER
                                , p_organization_id	IN NUMBER
                                , p_revision	        IN VARCHAR2
                                , p_lot_number		IN VARCHAR2
                                , p_subinventory_code	IN VARCHAR2
                                , p_locator_id		IN NUMBER
		                , p_required_sl_qty     IN NUMBER
			        , p_unit_number         IN NUMBER
				, p_reservation_id      IN NUMBER   -- Bug 5517498
	                        , x_available_sl_qty	OUT NOCOPY NUMBER
		                , g_transaction_temp_id	OUT NOCOPY NUMBER
			        , x_serial_index        OUT NOCOPY NUMBER
				, x_return_status       OUT NOCOPY VARCHAR2
	                        , x_msg_count           OUT NOCOPY NUMBER
		                , x_msg_data            OUT NOCOPY VARCHAR2
			        , x_serial_number       OUT NOCOPY VARCHAR2 -- Bug 5517498
				)  IS
 cursor msnc IS
          SELECT  msn.serial_number
            FROM  mtl_serial_numbers msn
            WHERE msn.inventory_item_id                    = p_inventory_item_id
            AND   msn.current_organization_id              = p_organization_id
            AND   nvl(msn.revision,'@@@')                  = nvl(p_revision,'@@@')
            AND   nvl(msn.lot_number, '@@@')               = nvl(p_lot_number,'@@@')
            AND   nvl(msn.current_subinventory_code,'@@@') = nvl(p_subinventory_code,'@@@')
            AND   nvl(msn.current_locator_id,-1)           = nvl(p_locator_id,-1)
  --          AND   nvl(msn.end_item_unit_number,'@@@')      = nvl(p_unit_number,'@@@')
            AND   msn.current_status                       = 3
            AND  ((msn.group_mark_id is null) or (msn.group_mark_id = -1))
            ORDER BY msn.serial_number;
-- Added cursor for bug 5517498
 cursor msn_reserved IS
        SELECT msn.serial_number
          FROM mtl_serial_numbers msn
          WHERE msn.reservation_id = p_reservation_id
          ORDER BY msn.serial_number;

l_msnt_tbl_size NUMBER:=0;
G_LOGIN_ID NUMBER;
G_USER_ID NUMBER;
G_LOGIN_ID NUMBER;
G_PROG_APPID NUMBER;
G_PROG_ID   NUMBER;
G_REQUEST_ID  NUMBER;
--g_transaction_temp_id NUMBER;
l_serial_number VARCHAR2(100);
BEGIN
x_return_status :=fnd_api.g_ret_sts_success;

print_debug('Required Serialqty '||p_required_sl_qty,
              'INV_Express_pick.Pick_release');
  if G_USER_ID IS NULL OR G_REQUEST_ID IS NULL then
   G_USER_ID    := FND_GLOBAL.user_id ;
   G_PROG_APPID := FND_GLOBAL.prog_appl_id    ;
   G_PROG_ID    := FND_GLOBAL.conc_program_id;
   G_REQUEST_ID := FND_GLOBAL.conc_request_id ;
  end if;
   g_transaction_temp_id :=NULL;
   x_available_sl_qty :=0;
   x_serial_index :=0;

  -- Begin of Bug Fix 5517498
  FOR msn_rec IN msn_reserved LOOP
    --dbms_output.put_line('inside loop ');
      print_debug('getting serial numbers based on reservation_id ','INV_Express_pick.Pick_release');
      if g_transaction_temp_id is NULL then
       print_debug('get new Transaction_temp_id ','Inv_Express_pick.Pick_release');
         SELECT mtl_material_transactions_s.NEXTVAL into g_transaction_temp_id
     FROM dual;
      end if;
         IF (x_available_sl_qty >= p_required_sl_qty) THEN
             EXIT;
          END IF;
print_debug('lock Serial ',
              'INV_Express_pick.Pick_release');

        BEGIN
         SELECT serial_number into l_serial_number
          FROM mtl_serial_numbers
          WHERE inventory_item_id = p_inventory_item_id
          AND serial_number = msn_rec.serial_number
          FOR UPDATE nowait;
         EXCEPTION
         WHEN OTHERS then
             null;
         END;

             l_msnt_tbl_size := l_msnt_tbl_size +1;
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
          g_transaction_temp_id
         ,sysdate
         ,g_user_id
         ,sysdate
         ,g_user_id
         ,null
         ,g_request_id
         ,g_prog_appid
         ,G_PROG_ID
         ,sysdate
         ,null
         ,null
         ,msn_rec.serial_number
         ,msn_rec.serial_number
         ,1
         ,null
         ,null
         ,null
         ,null
         );


         UPDATE mtl_serial_numbers
        SET group_mark_id = g_transaction_temp_id
        WHERE inventory_item_id = p_inventory_item_id
        AND serial_number =msn_rec.serial_number;

     x_available_sl_qty := x_available_sl_qty + 1;
      x_serial_index :=x_serial_index+1;
      l_serial_number := msn_rec.serial_number;
  END LOOP;
    -- End  of Bug Fix 5517498

  IF x_available_sl_qty < p_required_sl_qty THEN  -- Added If condition for Bug 5517498
  FOR msn_rec IN msnc LOOP
    --dbms_output.put_line('inside loop ');
      if g_transaction_temp_id is NULL then
       print_debug('get new Transaction_temp_id ','Inv_Express_pick.Pick_release');
         SELECT mtl_material_transactions_s.NEXTVAL into g_transaction_temp_id
     FROM dual;
      end if;
         IF (x_available_sl_qty >= p_required_sl_qty) THEN
             EXIT;
          END IF;
print_debug('lock Serial ',
              'INV_Express_pick.Pick_release');

        BEGIN
         SELECT serial_number into l_serial_number
          FROM mtl_serial_numbers
          WHERE inventory_item_id = p_inventory_item_id
          AND serial_number = msn_rec.serial_number
          FOR UPDATE nowait;
         EXCEPTION
         WHEN OTHERS then
             null;
         END;

             l_msnt_tbl_size := l_msnt_tbl_size +1;
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
          g_transaction_temp_id
         ,sysdate
         ,g_user_id
         ,sysdate
         ,g_user_id
         ,null
         ,g_request_id
         ,g_prog_appid
         ,G_PROG_ID
         ,sysdate
         ,null
         ,null
         ,msn_rec.serial_number
         ,msn_rec.serial_number
         ,1
         ,null
         ,null
         ,null
         ,null
         );


         UPDATE mtl_serial_numbers
        SET group_mark_id = g_transaction_temp_id,
            reservation_id = p_reservation_id
        WHERE inventory_item_id = p_inventory_item_id
        AND serial_number =msn_rec.serial_number;

     x_available_sl_qty := x_available_sl_qty + 1;
      x_serial_index :=x_serial_index+1;
      l_serial_number := msn_rec.serial_number;

   END LOOP;
   END IF;

   x_serial_index :=l_msnt_tbl_size;
   -- Returning x_serial_number for Bug Fix 5517498
   IF x_available_sl_qty = 1 THEN
	x_serial_number := l_serial_number;
   END IF;
   print_debug('Available Serial '||x_available_sl_qty,'INV_Express_pick.Pick_release');
   print_debug('return status '||x_return_status,'INV_Express_pick.Pick_release');



EXCEPTION
   when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error ;
        x_available_sl_qty := 0;
        x_serial_index := 0;

   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_available_sl_qty := 0;
 x_serial_index := 0;

   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_available_sl_qty := 0;
      x_serial_index := 0;

      if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
         fnd_msg_pub.add_exc_msg('Pick Serial Numbers', 'PICK Serial Numbers ');
      end if;

END pick_serial_numbers;
END INV_EXPRESS_PICK_PUB;

/

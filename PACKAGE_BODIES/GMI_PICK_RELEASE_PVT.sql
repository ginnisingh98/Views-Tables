--------------------------------------------------------
--  DDL for Package Body GMI_PICK_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PICK_RELEASE_PVT" AS
/*  $Header: GMIVPKRB.pls 120.0 2005/05/25 16:00:43 appldev noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVPKRB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick Release process.                                               |
 |                                                                         |
 | - Process_Line                                                          |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-May-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Pick_Release_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GMI_Pick_Release_PVT';

PROCEDURE Process_Line
  (
     p_api_version                   IN  NUMBER
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_commit                        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_hdr_rec                    IN  GMI_Move_Order_Global.mo_hdr_rec
   , p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
   , p_grouping_rule_id              IN  NUMBER
   , p_print_mode                    IN  VARCHAR2
   , p_allow_partial_pick            IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_allow_delete                  IN  VARCHAR2 DEFAULT NULL
   , x_detail_rec_count              OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

/*  Define local variables */
l_api_version			CONSTANT NUMBER := 1.0;
l_api_name			CONSTANT VARCHAR2(30) := 'Process_Line';

l_qry_rsv_rec                   inv_reservation_global.mtl_reservation_rec_type;

l_pick_slip_mode                VARCHAR2(1);

l_mo_line_rec                   GMI_Move_Order_Global.mo_line_rec;
l_demand_info                   wsh_inv_delivery_details_v%ROWTYPE;
l_reservable_type               NUMBER;
l_sub_reservable_type           NUMBER;
l_demand_source_type            NUMBER;
l_mso_header_id                 NUMBER;
l_quantity_detailed             NUMBER;
l_allocated_transactions        NUMBER;

l_api_error_code                NUMBER;
l_api_error_msg                 VARCHAR2(100);

/*  Define local cursors */
CURSOR c_mtl_items( org_id IN NUMBER
                  , item_id IN NUMBER) IS
   SELECT reservable_type
   FROM mtl_system_items
   WHERE inventory_item_id = item_id
   AND   organization_id = org_id;

CURSOR c_second_inventory( org_id IN NUMBER
                         , subinv_code IN VARCHAR2) IS
   SELECT reservable_type
   FROM mtl_secondary_inventories
   WHERE organization_id = org_id
   AND   secondary_inventory_name = subinv_code;

CURSOR c_transaction_type( txn_type_id IN NUMBER) IS
   SELECT t.transaction_source_type_id
   FROM mtl_transaction_types t, mtl_txn_source_types st
   WHERE t.transaction_source_type_id = st.transaction_source_type_id
   AND   t.transaction_type_id = txn_type_id;
CURSOR c_get_delivery_detail IS
   SELECT delivery_detail_id
      ,   requested_quantity
      ,   requested_quantity2
      ,   source_line_id
   FROM wsh_delivery_details
   WHERE move_order_line_id = p_mo_line_rec.line_id
      AND released_status = 'S';

CURSOR c_get_trans_for_del(source_line_id NUMBER
                         , delivery_detail_id NUMBER) IS
   SELECT nvl(sum(abs(trans_qty)), 0), nvl(sum(abs(trans_qty2)),0)
   FROM ic_tran_pnd
   WHERE line_id = source_line_id
     AND line_detail_id = delivery_detail_id
     AND delete_mark = 0 ;


CURSOR c_get_trans_id IS
SELECT  trans_id, line_id
FROM    ic_tran_pnd
WHERE   line_id =  p_mo_line_rec.txn_source_line_id
AND     line_detail_id IN (
               SELECT  delivery_detail_id
               FROM    wsh_delivery_details
               WHERE   move_order_line_id = p_mo_line_rec.line_id
               AND     source_line_id = p_mo_line_rec.txn_source_line_id
               AND     released_status IN ('R', 'S'))
AND     doc_type = 'OMSO'
AND     delete_mark = 0
AND     staged_ind = 0
AND     completed_ind = 0
AND     (lot_id >0 OR location <> 'l_IC$DEFAULT_LOCT');

ic_tran_tbl_row         c_get_trans_id%ROWTYPE;


l_del_trans_qty   NUMBER;
l_del_trans_qty2  NUMBER;
l_trans_id        NUMBER;
l_tran_rec        GMI_TRANS_ENGINE_PUB.ictran_rec;
l_tran_row        IC_TRAN_PND%ROWTYPE;
l_p_allow_delete  VARCHAR2(3);

 l_IC$DEFAULT_LOCT       VARCHAR2(255)DEFAULT NVL(FND_PROFILE.VALUE('IC$DEFAULT_LOCT'),' ') ;
l_GML$DEL_ALC_BEFORE_AUTO VARCHAR2(255) DEFAULT NVL(FND_PROFILE.VALUE('GML$DEL_ALC_BEFORE_AUTO'),' ') ;


BEGIN
gmi_reservation_util.println('Value of p_grouping_rule_idp_grouping_rule_id in process_line  is '||p_grouping_rule_id);
   GMI_Reservation_Util.PrintLn('Entering_GMI_Pick_Release_PVT.');

   SAVEPOINT Process_Line_PVT;
   /*  Standard Call to check for call compatibility */
   IF NOT fnd_api.Compatible_API_Call(l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   /*  Initialize API return status to success */
   x_return_status := FND_API.g_ret_sts_success;

--==================================================================

  l_p_allow_delete := p_allow_delete;
  GMI_Reservation_Util.PrintLn('l_p_allow_delete = ' || l_p_allow_delete);

  GMI_Reservation_Util.PrintLn('l_IC$DEFAULT_LOCT = ' || l_IC$DEFAULT_LOCT) ;
  GMI_Reservation_Util.PrintLn('l_GML$DEL_ALC_BEFORE_AUTO = ' || l_GML$DEL_ALC_BEFORE_AUTO) ;

  IF (UPPER(l_p_allow_delete) = 'YES')
     OR (l_p_allow_delete IS NULL AND UPPER(l_GML$DEL_ALC_BEFORE_AUTO) = 'YES')
  THEN

        OPEN c_get_trans_id;
        FETCH c_get_trans_id INTO ic_tran_tbl_row;
        IF (c_get_trans_id%FOUND) THEN
                WHILE c_get_trans_id%FOUND LOOP

                l_tran_rec.trans_id := ic_tran_tbl_row.trans_id;

                GMI_Reservation_Util.PrintLn('l_tran_rec.trans_id = ' || l_tran_rec.trans_id);

                GMI_TRANS_ENGINE_PUB.delete_pending_transaction
                ( 1
                , FND_API.G_FALSE
                , FND_API.G_FALSE
                , FND_API.G_VALID_LEVEL_FULL
                , l_tran_rec
                , l_tran_row
                , x_return_status
                , x_msg_count
                , x_msg_data
                );

                GMI_Reservation_Util.PrintLn('return from DELETE PENDING TRANS x_return_status = ' || x_return_status);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        FETCH c_get_trans_id INTO ic_tran_tbl_row;
        END LOOP;
        CLOSE c_get_trans_id;
    END IF;
  END IF ;
GMI_Reservation_Util.PrintLn('outside of lizloop');

--==================================================================


   /*  Return success immediately if the line is already fully detailed */
   IF NVL(p_mo_line_rec.quantity_detailed, 0) >= NVL(p_mo_line_rec.quantity, 0) THEN
     GMI_Reservation_Util.PrintLn('Exiting_GMI_Pick_Release_PVT. fully detailed no Error');
     /*  odab removed it in order to get the x_detail_rec_count  */
     /* odab return; */
     /*  NEED TO put it back ( for performance) */
   END IF;

   /*  Override the printing mode to deferred if allow partial pick is false. */
   /*  Otherwise set it based on the parameter passed in. */
   -- Bug 1717145, 2-Apr-2001, odaboval, set the print_mode
   IF (p_allow_partial_pick = FND_API.G_FALSE)
   THEN
     l_pick_slip_mode := 'E';
   ELSE
     l_pick_slip_mode := p_print_mode;
   END IF;

   GMI_Reservation_Util.PrintLn('Entering_GMI_Pick_Release_PVT. Before Set_Org_Client_Info, ps_mode='||l_pick_slip_mode);
   inv_project.set_org_client_info(x_return_status, p_mo_line_Rec.organization_id);

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PVT. Before Get_Delivery_Details');
   /*  Determine the demand source and delivery information for the given line. */
   GMI_Pick_Release_Util.Get_Delivery_Details(
         p_mo_line_id           => p_mo_line_rec.line_id
       , x_inv_delivery_details => l_demand_info
       , x_return_status        => x_return_status
       , x_msg_count            => x_msg_count
       , x_msg_data             => x_msg_data);

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PVT. To find : Item='||p_mo_line_rec.inventory_item_id||', org_id='||p_mo_line_rec.organization_id);
   OPEN c_mtl_items( p_mo_line_rec.organization_id
                  , p_mo_line_rec.inventory_item_id);
   FETCH c_mtl_items
        INTO l_reservable_type;

   IF ( c_mtl_items%NOTFOUND )
   THEN
      FND_MESSAGE.SET_NAME('GMI','INV_ITEM_NOTFOUND');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_mo_line_rec.organization_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_mo_line_rec.inventory_item_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_mtl_items;

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PVT. To find : SecondInventory, from_subInv_code='||p_mo_line_rec.from_subinventory_code);

   IF ( p_mo_line_rec.from_subinventory_code is not NULL )
   THEN
      OPEN c_second_inventory( p_mo_line_rec.organization_id
                             , p_mo_line_rec.from_subinventory_code);
      FETCH c_second_inventory
           INTO l_sub_reservable_type;

      IF ( c_second_inventory%NOTFOUND )
      THEN
         FND_MESSAGE.SET_NAME('GMI','INV_DELIV_INFO_MISSING');
         FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_mo_line_rec.organization_id);
         FND_MESSAGE.Set_Token('FROM_SUBINVENTORY_CODE', p_mo_line_rec.from_subinventory_code);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_second_inventory;
   END IF;

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PVT. To find : TransactionType, TransactionType='||p_mo_line_rec.transaction_type_id);

   OPEN c_transaction_type(p_mo_line_rec.transaction_type_id);
   FETCH c_transaction_type
        INTO l_demand_source_type;

   IF ( c_transaction_type%NOTFOUND )
   THEN
      FND_MESSAGE.set_name('GMI', 'INV_INT_TXN_CODE');
      FND_MESSAGE.Set_Token('TRANSACTION_TYPE_ID', p_mo_line_rec.transaction_type_id);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_transaction_type;

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PVT. Transaction Type found!');

   /*  Compute the MTL_SALES_ORDERS header ID to use when dealing with reservations.*/
   l_mso_header_id := INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(l_demand_info.oe_header_id);
   IF ( l_mso_header_id IS NULL ) THEN
     FND_MESSAGE.SET_NAME('GMI','INV_COULD_NOT_GET_MSO_HEADER');
     FND_MESSAGE.Set_Token('OE_HEADER_ID', l_demand_info.oe_header_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* find out the corresponding delivery detail id to fill in ic_tran_pnd */
   /* this could result more than 1 delivery, need to do a loop for the deliveries */

   GMI_Reservation_Util.PrintLn('p_mo_line_rec.unit_number is ' || p_mo_line_Rec.unit_number);
   /*  Retrieve reservation information for that demand source */
   /*  only if the item is reservable */
   IF( l_reservable_type = 1 AND nvl(l_sub_reservable_type, 1) = 1 )
   THEN
      FOR delivery IN c_get_delivery_detail LOOP
         GMI_Reservation_Util.PrintLn('(opm_dbg) Realloc reservation info for demand source :');
         l_qry_rsv_rec.organization_id 	        := p_mo_line_rec.organization_id;
         l_qry_rsv_rec.inventory_item_id 	        := p_mo_line_rec.inventory_item_id;
         l_qry_rsv_rec.demand_source_type_id       := l_demand_source_type;
         l_qry_rsv_rec.demand_source_header_id     := l_mso_header_id;
         l_qry_rsv_rec.demand_source_line_id       := l_demand_info.oe_line_id;
         l_qry_rsv_rec.supply_source_type_id       := FND_API.G_MISS_NUM;
         l_qry_rsv_rec.reservation_uom_code        := p_mo_line_rec.uom_code;
         /* B1800659 */
         --l_qry_rsv_rec.reservation_quantity        := nvl(p_mo_line_rec.quantity,0)
         --                                             - nvl(p_mo_line_rec.quantity_delivered,0);
         --l_qry_rsv_rec.attribute2                  := p_mo_line_rec.secondary_quantity;
         --                                             - nvl(p_mo_line_rec.secondary_quantity_delivered,0);
         l_qry_rsv_rec.requirement_date            := p_mo_line_rec.date_required;
         /* using mo line quanity may not be correct if there are more than 1 delivery
           for the mo line */
         OPEN c_get_trans_for_del(delivery.source_line_id, delivery.delivery_detail_id);
         Fetch c_get_trans_for_del INTO l_del_trans_qty,l_del_trans_qty2;
         Close c_get_trans_for_del;

         l_qry_rsv_rec.reservation_quantity        := delivery.requested_quantity
                                                       - l_del_trans_qty;
         l_qry_rsv_rec.attribute1                  := p_mo_line_rec.qc_grade;
         l_qry_rsv_rec.attribute2                  := delivery.requested_quantity2
                                                       - l_del_trans_qty2;
         l_qry_rsv_rec.attribute3                  := p_mo_line_rec.secondary_uom_code;
         l_qry_rsv_rec.attribute4                  := delivery.delivery_detail_id;
         IF l_qry_rsv_rec.reservation_quantity < 0 THEN
           l_qry_rsv_rec.reservation_quantity        := 0;
           l_qry_rsv_rec.attribute2                  := 0;
         END IF;

         GMI_Reservation_Util.PrintLn('(opm_dbg) organization_id='||l_qry_rsv_rec.organization_id);
         GMI_Reservation_Util.PrintLn('(opm_dbg) inv_item_id='||l_qry_rsv_rec.inventory_item_id);
         GMI_Reservation_Util.PrintLn('(opm_dbg) source_header_id='||l_qry_rsv_rec.demand_source_header_id);
         GMI_Reservation_Util.PrintLn('(opm_dbg) source_line_id='||l_qry_rsv_rec.demand_source_line_id);
         GMI_Reservation_Util.PrintLn('(opm_dbg) Res_UOM_code='||l_qry_rsv_rec.reservation_uom_code);
         GMI_Reservation_Util.PrintLn('(opm_dbg) Shedule_ship_date='||l_qry_rsv_rec.requirement_date);

         GMI_Reservation_Util.PrintLn('UOM_CODE='||p_mo_line_rec.uom_code);
         GMI_Reservation_Util.PrintLn('SO line qty='||p_mo_line_rec.quantity);
         GMI_Reservation_Util.PrintLn(' attribute1='||l_qry_rsv_rec.attribute1);
         GMI_Reservation_Util.PrintLn(' attribute2='||l_qry_rsv_rec.attribute2);
         GMI_Reservation_Util.PrintLn(' attribute3='||l_qry_rsv_rec.attribute3);
         GMI_Reservation_Util.PrintLn(' attribute4='||l_qry_rsv_rec.attribute4);

         /* l_qry_rsv_rec.ship_ready_flag	  := 2;	-- only records which are not ship ready */

         GMI_Reservation_Util.Reallocate(
                  p_query_input            => l_qry_rsv_rec
                , x_allocated_trans        => l_allocated_transactions
                , x_allocated_qty          => l_quantity_detailed
                , x_return_status          => x_return_status
                , x_msg_count              => x_msg_count
                , x_msg_data               => x_msg_data);

         /*  Return an error if the Reallocation call failed */
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              ROLLBACK TO Process_Line_PVT;
              FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Reallocate');
              FND_MESSAGE.Set_Token('WHERE', 'GMI_Pick_Release_PVT.Process_Line');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;
   END IF; /*  The item is reservable */

   /* ============================================================================ */
   /*  Once the Reallocation done, need to update the MO_Line with the new detailed_qty */
   /* ============================================================================ */
   /*  Update the detailed quantity (and if possible, the sourcing information)  */
   /*  of the Move Order Line */
   /*  If the move order line is not fully detailed, update the  */
   /*  return status as appropriate. */
   GMI_Reservation_Util.PrintLn('ictrans count='||GMI_Reservation_Util.ic_tran_rec_tbl.COUNT);
   GMI_Reservation_Util.PrintLn('qty detailed='||l_quantity_detailed);
   GMI_Reservation_Util.PrintLn('mo_line.primary_qty='||p_mo_line_rec.primary_quantity);
   /*  I think that I don't have to return an error when I can't Pick Full !!! (odab) */
   /*  IF l_quantity_detailed < p_mo_line_rec.primary_quantity THEN */
   /*       GMI_Reservation_Util.PrintLn('qty detailed < mo_line.primary_qty : Couldnt Pick Full'); */
   /*       ROLLBACK TO Process_Line_PVT; */
   /*       FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_PICK_FULL'); */
   /*       FND_MSG_PUB.Add; */
   /*       RAISE fnd_api.g_exc_unexpected_error; */
   /*  END IF; */

   /* ============================================================================ */
   /*  Set the returned values : */
   /* ============================================================================ */

   /*  -1 : The Default Lot row, which is not encounted */
   x_detail_rec_count := l_allocated_transactions ;

   l_mo_line_rec := p_mo_line_rec;
   l_mo_line_rec.quantity_detailed := nvl(l_quantity_detailed, 0) + NVL(l_mo_line_rec.quantity_delivered, 0);
   l_mo_line_rec.txn_source_id := l_mso_header_id;
   l_mo_line_rec.txn_source_line_id := l_demand_info.oe_line_id;

gmi_reservation_util.println('Value of p_grouping_rule_id  in Process Line before update_row is '||p_grouping_rule_id);
   GMI_Reservation_Util.PrintLn('calling GMI_Move_Order_line_UTIL.Update_Row');
   GMI_Move_Order_Line_UTIL.Update_Row(l_mo_line_rec);

gmi_reservation_util.println('Value of p_grouping_rule_id in process_line before calling Create_Pick_Slip_and_Print is '||p_grouping_rule_id);
   /* =======================================================================================*/
   /*  Pick Slip (data + printing) */
   /* ======================================================================================= */
   GMI_Pick_Release_Util.Create_Pick_Slip_and_Print(
               p_mo_line_rec            => l_mo_line_rec
             , p_inv_delivery_details   => l_demand_info
             , p_pick_slip_mode         => l_pick_slip_mode
             , p_grouping_rule_id       => p_grouping_rule_id
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data);

             /* , p_allow_partial_pick     => p_allow_partial_pick */

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ROLLBACK TO Process_Line_PVT;
        FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
        FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Pick_Release_Util.Create_Pick_Slip_and_Print');
        FND_MESSAGE.Set_Token('WHERE', 'GMI_Pick_Release_PVT.Process_Line');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
   END IF;


GMI_Reservation_Util.PrintLn('In the end of GMI_Pick_Release_PVT.Process_Line : NO Error, detail_rec_count='||x_detail_rec_count);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Process_Line;

END GMI_Pick_Release_PVT;

/

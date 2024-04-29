--------------------------------------------------------
--  DDL for Package Body GML_BATCH_OM_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_BATCH_OM_RES_PVT" AS
/*  $Header: GMLORESB.pls 115.33 2004/06/11 20:03:49 nchekuri noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMLOUTLB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GML_BATCH_OM_RES_PVT
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              OPM reservation for a batch.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

G_PKG_NAME  CONSTANT  VARCHAR2(30):='GML_BATCH_OM_RES_PVT';

 PROCEDURE build_trans_rec
 (
    p_trans_row       IN   ic_tran_pnd%rowtype
  , x_trans_rec       IN OUT  NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
 );
 PROCEDURE build_res_rec
 (
    p_res_row       IN   gml_batch_so_reservations%rowtype
  , x_res_rec       OUT  NOCOPY GML_BATCH_OM_UTIL.gme_om_reservation_rec
 ) ;
 PROCEDURE PRINT_DEBUG
 (
   p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
  ,p_routine          IN  VARCHAR2
 ) ;

 PROCEDURE create_reservation_from_FPO
 (
    P_FPO_batch_id           IN    NUMBER
  , P_New_batch_id           IN    NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_so_line_rec              GML_BATCH_OM_UTIL.so_line_rec;
  l_batch_line_rec           GML_BATCH_OM_UTIL.batch_line_rec;
  l_rule_rec                 GML_BATCH_OM_UTIL.gme_om_rule_rec;
  l_reservation_rec          GML_BATCH_OM_UTIL.gme_om_reservation_rec;
  l_batch_line_id            NUMBER;
  l_fpo_batch_line_id        NUMBER;
  l_whse_code                VARCHAR2(5);
  l_planned_qty              NUMBER;
  l_planned_qty2             NUMBER;
  l_res_count                NUMBER;
  l_avg_qty                  NUMBER;
  l_avg_qty2                 NUMBER;
  l_item_id                  NUMBER;
  l_reserved_qty             NUMBER;
  l_reserved_qty2            NUMBER;
  l_remaining_qty            NUMBER;
  l_plan_cmplt_date          date;

  Cursor check_whse (p_batch_line_id IN NUMBER) IS
  Select distinct whse_code
  From gml_batch_so_reservations
  Where batch_line_id = p_batch_line_id;

  Cursor get_batch_line (p_batch_id IN NUMBER) IS
  Select material_detail_id
       , item_id
  From gme_material_details
  where batch_id = p_batch_id
    and line_type <> -1            -- not ingredient
    ;

  Cursor get_res_for_whse (p_whse_code IN VARCHAR2
                       ,   p_batch_line_id IN NUMBER) IS
  Select *
  From gml_batch_so_reservations
  Where batch_line_id = p_batch_line_id
     and whse_code = p_whse_code
     and delete_mark = 0
     and reserved_qty <> 0
  Order by scheduled_ship_date
        ,  shipment_priority
     ;

  Cursor get_planned_qty (p_batch_line_id IN NUMBER
                       ,  p_whse_code     IN VARCHAR2) is
  Select abs(sum(trans_qty)), abs(sum(trans_qty2))
  From ic_tran_pnd
  Where line_id = p_batch_line_id
     and whse_code = p_whse_code
     and doc_type = 'PROD'
     and delete_mark = 0
     and completed_ind = 0
     ;
  Cursor get_res_count(p_batch_line_id IN NUMBER
                    ,  p_whse_code     IN VARCHAR2) Is
  Select count(1)
  From gml_batch_so_reservations
  Where batch_line_id = p_batch_line_id
     and whse_code = p_whse_code
     and delete_mark = 0
     and reserved_qty <> 0
     ;

  Cursor get_new_batch_line (p_batch_id  IN NUMBER
                       ,     p_item_id   IN NUMBER) is
  Select material_detail_id
  From gme_material_details
  Where batch_id = p_batch_id
     and item_id = p_item_id
     and line_type <> -1
     ;
  Cursor get_new_batch_cmpt_date (p_batch_id IN NUMBER) is
  Select plan_cmplt_date
  From gme_batch_header
  where batch_id = p_batch_id;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_reservation_Util.PrintLn(' create_reservation_from_FPO ');
  /* loop through all the product lines in the batch */
  For batch_line in get_batch_line(p_FPO_batch_id) Loop
     l_fpo_batch_line_id := batch_line.material_detail_id ;
     l_item_id           := batch_line.item_id ;
     GMI_reservation_Util.PrintLn(' FPO batch_line_id '||l_fpo_batch_line_id);
     /* check reservation exist or not */
     IF NOT GML_BATCH_OM_UTIL.check_reservation
         (
            P_Batch_line_id          => l_fpo_batch_line_id
          , X_return_status          => x_return_status
          , X_msg_cont               => x_msg_cont
          , X_msg_data               => x_msg_data
         )
     THEN
        goto next_batch_line;
     END IF;

     /* get the new batch_line_id for the created batch */
     Open get_new_batch_line(p_new_batch_id, l_item_id);
     Fetch get_new_batch_line Into l_batch_line_id;
     Close get_new_batch_line;

     GMI_reservation_Util.PrintLn(' NEW batch_line_id '||l_batch_line_id);
     /* loop to see if different whse may have exist */
     For each_whse in check_whse(l_fpo_batch_line_id) Loop
        l_whse_code := each_whse.whse_code;
        l_so_line_rec.whse_code := each_whse.whse_code;
        l_batch_line_rec.batch_line_id := l_fpo_batch_line_id;
        GMI_reservation_Util.PrintLn(' reservation whse '||l_whse_code);

        GML_BATCH_OM_UTIL.get_rule
              (
                   P_so_line_rec            => l_so_line_rec
                 , P_batch_line_rec         => l_batch_line_rec
                 , X_gme_om_rule_rec        => l_rule_rec
                 , X_return_status          => x_return_status
                 , X_msg_cont               => x_msg_cont
                 , X_msg_data               => x_msg_data
              );
        /* get the qty for the newly created batch */
        Open get_planned_qty( l_batch_line_id, l_whse_code);
        Fetch get_planned_qty
        Into l_planned_qty
          ,  l_planned_qty2
          ;
        Close get_planned_qty;
        GMI_reservation_Util.PrintLn(' NEW batch Planned qty '||l_planned_qty);

        Open get_new_batch_cmpt_date (p_new_batch_id) ;
        Fetch get_new_batch_cmpt_date Into l_plan_cmplt_date;
        Close get_new_batch_cmpt_date;
        /* check the rule */
        IF l_rule_rec.allocation_priority = 2 THEN -- evenly distributed
           Open get_res_count( l_fpo_batch_line_id, l_whse_code);
           Fetch get_res_count Into l_res_count;
           Close get_res_count;
           IF l_res_count <> 0 THEN
              l_avg_qty := l_planned_qty / l_res_count;
              l_avg_qty2 := l_planned_qty2 / l_res_count;
           END IF;
        END IF;
        /* process the reservations made in this whse */
        l_remaining_qty := l_planned_qty;
        for each_rec in get_res_for_whse(l_whse_code
                                       , l_fpo_batch_line_id)
        Loop
           /* check the batch planned cplt date with the scheduled_ship_date
            * if the date is out, skip this record
            */
           GMI_reservation_Util.PrintLn(' build res record for the new batch');
           IF each_rec.scheduled_ship_date > l_plan_cmplt_date THEN
              Goto next_res_line;
           END IF;
           EXIT WHEN l_remaining_qty <= 0 ;
           /* build reservation rec for the new batch line */
           IF each_rec.reserved_qty < l_planned_qty THEN
              l_reserved_qty := each_rec.reserved_qty;
              l_reserved_qty2 := each_rec.reserved_qty2;
           ELSE
              l_reserved_qty := l_planned_qty;
              l_reserved_qty2 := l_planned_qty2;
           END IF;

           build_res_rec( each_rec, l_reservation_rec);

           l_reservation_rec.batch_id := p_NEW_batch_id;
           l_reservation_rec.rule_id := l_rule_rec.rule_id;
           l_reservation_rec.batch_line_id := l_batch_line_id;
           l_reservation_rec.batch_type := 0;
           IF l_rule_rec.allocation_priority = 2 THEN -- evenly distributed
              l_reserved_qty := l_avg_qty ;
              l_reserved_qty2 := l_avg_qty2 ;
           END IF;
           l_reservation_rec.reserved_qty := l_reserved_qty;
           l_reservation_rec.reserved_qty2 := l_reserved_qty2;
           GMI_reservation_Util.PrintLn(' new reserved qty '||l_reserved_qty);

           GML_BATCH_OM_UTIL.insert_reservation
           (
                P_Gme_om_reservation_rec => l_reservation_rec
              , X_return_status          => x_return_status
              , X_msg_cont               => x_msg_cont
              , X_msg_data               => x_msg_data
           );
           l_remaining_qty := l_remaining_qty - l_reserved_qty;
           /* update the fpo reservation records */
           Update gml_batch_so_reservations
           Set reserved_qty = reserved_qty - l_reserved_qty
             , reserved_qty2 = reserved_qty2 - l_reserved_qty2
           Where batch_res_id = each_rec.batch_res_id;
           <<next_res_line>>
           null;
        END Loop;
     END LOOP;
     <<next_batch_line>>
     null;
  END loop;
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    /*   Get message count and data*/
    FND_MSG_PUB.count_and_get
     (   p_count  => x_msg_cont
       , p_data  => x_msg_data
     );
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Expected');
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'convert_FPO'
                              );
      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_cont
         , p_data  => x_msg_data
       );
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Others');

 END create_reservation_from_FPO;

 PROCEDURE create_allocations
 (
    P_batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , P_gme_om_rule_rec        IN    GML_BATCH_OM_UTIL.gme_om_rule_rec
  , P_Gme_trans_row          IN    ic_tran_pnd%rowtype
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

 l_so_line_rec            GML_BATCH_OM_UTIL.so_line_rec;
 l_rule_rec               GML_BATCH_OM_UTIL.gme_om_rule_rec;
 l_history_rec            GML_BATCH_OM_UTIL.alloc_history_rec;
 l_gme_trans_row          ic_tran_pnd%rowtype;
 l_tran_rec               GMI_TRANS_ENGINE_PUB.ictran_rec;
 l_dft_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
 l_tran_row               IC_TRAN_PND%ROWTYPE;
 l_res_count              NUMBER;
 l_avg_qty                NUMBER;
 l_avg_qty2               NUMBER;
 l_remaining_alloc_qty    NUMBER;
 l_remaining_alloc_qty2   NUMBER;
 l_go_ahead               NUMBER;
 l_orderable              NUMBER;
 l_status_ctl             NUMBER;
 l_dft_trans_id           NUMBER;
 l_alloc_done             NUMBER;
 l_over_alloc             NUMBER;
 l_total_alloc            NUMBER;
 l_total_alloc2           NUMBER;
 l_total_req              NUMBER;
 l_total_req2             NUMBER;
 l_lot_status             VARCHAR2(10);
 l_prod_whse              VARCHAR2(10);

 Cursor find_reservations (p_batch_line_id IN NUMBER
                         , p_whse_code IN VARCHAR ) is
 Select res.scheduled_ship_date
    ,   res.shipment_priority
    ,   res.batch_res_id
    ,   res.reserved_qty
    ,   res.reserved_qty2
    ,   res.batch_line_id
    ,   res.so_line_id
    ,   res.delivery_detail_id
    ,   res.batch_id
 From gml_batch_so_reservations res
    , wsh_delivery_details wdd
 Where   res.batch_line_id = p_batch_line_id
     and res.delete_mark = 0
     and res.reserved_qty <> 0
     and res.whse_code = p_whse_code
     and res.delivery_detail_id = wdd.delivery_detail_id
     and wdd.released_status in ('B', 'R', 'S') --               dont bother looking at the ones staged
 Union
 Select res.scheduled_ship_date
    ,   res.shipment_priority
    ,   res.batch_res_id
    ,   res.reserved_qty
    ,   res.reserved_qty2
    ,   res.batch_line_id
    ,   res.so_line_id
    ,   res.delivery_detail_id
    ,   res.batch_id
 From gml_batch_so_reservations res
    , oe_order_lines_all ol
 Where   res.batch_line_id = p_batch_line_id
     and res.delete_mark = 0
     and res.reserved_qty <> 0
     and res.whse_code = p_whse_code
     and res.so_line_id = ol.line_id
     and ol.booked_flag = 'N'
 Order by 1
        , 2
     ;
 Cursor check_status_ctl(p_item_id IN NUMBER) IS
 Select status_ctl
 From ic_item_mst
 Where item_id = p_item_id;

 Cursor check_alloc_qty (p_so_line_id IN NUMBER) is
 Select abs(sum(trans_qty)), abs(sum(trans_qty2))
 From ic_Tran_pnd
 Where line_id = p_so_line_id
  and  doc_type = 'OMSO'
  and  delete_mark = 0
  and  (lot_id <> 0 or location <> GMI_Reservation_Util.G_DEFAULT_LOCT)
  and  completed_ind = 0
  ;
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_RESERVATION_UTIL.println('Create Allocations ');
  l_rule_rec := p_gme_om_rule_rec;
  l_gme_trans_row := p_gme_trans_row;
  l_prod_whse := l_gme_trans_row.whse_code;

  GMI_RESERVATION_UTIL.println(' Production whse code is '|| l_prod_whse);

  IF l_rule_rec.rule_id is null THEN
     l_so_line_rec.whse_code := p_gme_trans_row.whse_code;
     GML_BATCH_OM_UTIL.get_rule
           (
                P_so_line_rec            => l_so_line_rec
              , P_batch_line_rec         => p_batch_line_rec
              , X_gme_om_rule_rec        => l_rule_rec
              , X_return_status          => x_return_status
              , X_msg_cont               => x_msg_cont
              , X_msg_data               => x_msg_data
           );
  END IF;
  IF l_rule_rec.allocation_priority = 2 THEN /* distribute evenly*/
     GMI_RESERVATION_UTIL.println('Create Allocations: distribute evenly');
     Select count(1)
     Into l_res_count
     From gml_batch_so_reservations
     Where batch_line_id = p_batch_line_rec.batch_line_id
        and delete_mark = 0
        and reserved_qty <> 0
        and whse_code = l_gme_trans_row.whse_code -- beta testing
        ;
     IF l_res_count <> 0 THEN
        l_avg_qty := abs(l_gme_trans_row.trans_qty) / l_res_count;
        l_avg_qty2 := abs(l_gme_trans_row.trans_qty2) / l_res_count;
     END IF;
  END IF;
  /* query all the reservation rec for this batch line*/
  l_remaining_alloc_qty := abs(l_gme_trans_row.trans_qty);
  l_remaining_alloc_qty2 := abs(l_gme_trans_row.trans_qty2);
  For res_rec in find_reservations(p_batch_line_rec.batch_line_id, l_prod_whse) Loop
     EXIT WHEN l_remaining_alloc_qty <= 0 ;

     /* build history rec */
     l_history_rec.Batch_id            := res_rec.batch_id;
     l_history_rec.Batch_line_id       := res_rec.batch_line_id;
     l_history_rec.So_line_id          := res_rec.so_line_id;
     l_history_rec.Batch_res_id        := res_rec.batch_res_id;
     l_history_rec.Batch_trans_id      := l_gme_trans_row.trans_id;
     l_history_rec.trans_id            := null;
     l_history_rec.Whse_code           := l_gme_trans_row.whse_code;
     l_history_rec.Reserved_qty        := res_rec.reserved_qty;
     l_history_rec.Reserved_qty2       := res_rec.reserved_qty2;
     l_history_rec.Trans_um            := l_gme_trans_row.trans_um;
     l_history_rec.Trans_um2           := l_gme_trans_row.trans_um2;
     l_history_rec.rule_id             := l_rule_rec.rule_id;

     l_go_ahead := 1;
     /* check default lot */
     GMI_RESERVATION_UTIL.find_default_lot
        (  x_return_status      => x_return_status,
            x_msg_count         => x_msg_cont,
            x_msg_data          => x_msg_data,
            x_reservation_id    => l_dft_trans_id,
            p_line_id           => res_rec.so_line_id
        );
     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        GMI_RESERVATION_UTIL.println('Error returned by find default lot');
        FND_MESSAGE.SET_NAME('GML', 'GML_NO_DFLT_TRAN');
        l_history_rec.failure_reason :=  FND_MESSAGE.GET;
        l_go_ahead := 0;
     END IF;
     IF nvl(l_dft_trans_id,0) = 0 THEN
        GMI_RESERVATION_UTIL.println('Error returned by find default lot');
        FND_MESSAGE.SET_NAME('GML', 'GML_NO_DFLT_TRAN');
        l_history_rec.failure_reason :=  FND_MESSAGE.GET;
        l_go_ahead := 0;
     END IF;
     l_dft_tran_rec.trans_id := l_dft_trans_id ;
     IF NOT GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_dft_tran_rec, l_dft_tran_rec ) THEN
        GMI_RESERVATION_UTIL.println('Error returned by find default lot');
        FND_MESSAGE.SET_NAME('GML', 'GML_NO_DFLT_TRAN');
        l_history_rec.failure_reason :=  FND_MESSAGE.GET;
        l_go_ahead := 0;
     END IF;
     /* build the trans_rec */
     IF l_go_ahead = 1 THEN
        GMI_RESERVATION_UTIL.println('Create Allocations: building trans rec ');
        l_tran_rec := l_dft_tran_rec;
        GMI_RESERVATION_UTIL.println('Create Allocations: tran.line_id'||l_tran_rec.line_id);
        PRINT_DEBUG (l_tran_rec,'before build Transaction');
        build_trans_rec
                       (
                          p_trans_row       => p_gme_trans_row
                        , x_trans_rec       => l_tran_rec
                       );
        IF l_rule_rec.allocation_priority = 2 THEN /* distribute evenly*/
           l_tran_rec.trans_qty      := -1 * l_avg_qty;
           l_tran_rec.trans_qty2     := -1 * l_avg_qty2;
        ELSE
           IF res_rec.reserved_qty <= abs(l_remaining_alloc_qty) THEN
              l_tran_rec.trans_qty := -1 * res_rec.reserved_qty;
              l_tran_rec.trans_qty2 := -1 * res_rec.reserved_qty2;
           Else
              l_tran_rec.trans_qty := -1 * l_remaining_alloc_qty;
              l_tran_rec.trans_qty2 := -1 * l_remaining_alloc_qty2;
           END IF;
           l_over_alloc := 0;
           /* check the over_pick_enabled and the total allocated qty to see if over allocate
            * then
            * 1) adjust the trans_qty and trans_qty2
            * 2) set l_over_alloc = 1
            */
           IF nvl(fnd_profile.value('WSH_OVERPICK_ENABLED'),'N') = 'N' THEN
              Open check_alloc_qty (res_rec.so_line_id);
              Fetch check_alloc_qty Into l_total_alloc, l_total_alloc2;
              Close check_alloc_qty;
              l_total_req := l_total_alloc + abs(l_dft_tran_rec.trans_qty) ;
              l_total_req2 := l_total_alloc2 + abs(l_dft_tran_rec.trans_qty2) ;
              IF abs(l_tran_rec.trans_qty) > (l_total_req - l_total_alloc) THEN
                 GMI_RESERVATION_UTIL.println('Create alloc: over pick is not allowed, adjust qty');
                 /* allocate what is left in the dflt */
                 l_tran_rec.trans_qty := -1 * (l_total_req - l_total_alloc) ;
                 l_tran_rec.trans_qty2 := -1 * (l_total_req2 - l_total_alloc2) ;
                 l_over_alloc := 1;
                 GMI_RESERVATION_UTIL.println('Create alloc: trans qty '||l_tran_rec.trans_qty);
                 GMI_RESERVATION_UTIL.println('Create alloc: trans qty2 '||l_tran_rec.trans_qty2);
              END IF;
              IF l_tran_rec.trans_qty >= 0 THEN /* already fulfilled */
                 FND_MESSAGE.SET_NAME('GML', 'GML_OVER_ALLOC_NOT_ALLOWED');
                 l_history_rec.failure_reason :=  FND_MESSAGE.GET;
                 l_go_ahead := 0;
              END IF;
           END IF;
        END IF;
        PRINT_DEBUG (l_tran_rec,'after build Transaction');
     END IF;

     /* check lot status if status controled */
     Open check_status_ctl(l_gme_trans_row.item_id);
     Fetch check_status_ctl Into l_status_ctl;
     Close check_status_ctl;
     IF l_status_ctl <> 0 THEN
        IF l_gme_trans_row.lot_status is null THEN
           FND_MESSAGE.SET_NAME('GML', 'GML_PROD_NULL_STS');
           --FND_MESSAGE.SET_TOKEN('LOT_STS', l_gme_trans_row.lot_status);
           l_history_rec.failure_reason :=  FND_MESSAGE.GET;
           GMI_RESERVATION_UTIL.println('Create alloc: Lot status ctl with gme trans status is null');
           l_go_ahead := 0;
        ELSE
           l_lot_status := l_gme_trans_row.lot_status ;
           IF nvl(p_batch_line_rec.release_type,0) = 20 THEN
              GMI_RESERVATION_UTIL.println('Create alloc: Regenerate allocations');
              -- It is a regenerate (set it to value of 20 in regenerate, internal use )
              /* check the lot_status in ic_loct_inv, where the status may have been changed from original setting*/
              Select lot_status
              Into l_lot_status
              From ic_loct_inv
              Where lot_id = l_gme_trans_row.lot_id
                AND location = l_gme_trans_row.location
                AND whse_code = l_gme_trans_row.whse_code
                AND item_id = l_gme_trans_row.item_id
                And delete_mark = 0
                ;
           END IF;
           GMI_RESERVATION_UTIL.println('Create alloc: Lot status '|| l_lot_status);
           Select order_proc_ind
           Into l_orderable
           From ic_lots_sts
           Where lot_status = l_lot_status;
           IF l_orderable = 0 THEN
              FND_MESSAGE.SET_NAME('GML', 'GML_LOT_STS_NOT_ORD');
              FND_MESSAGE.SET_TOKEN('LOT_STS', l_gme_trans_row.lot_status);
              l_history_rec.failure_reason :=  FND_MESSAGE.GET;
              l_go_ahead := 0;
              GMI_RESERVATION_UTIL.println('Create alloc: Lot status is NOT orderable, OMSO is not created');
              GML_GME_API_PVT.g_not_to_delete := 1;
              GMI_RESERVATION_UTIL.println('Create alloc: global g_not_to_delete '||GML_GME_API_PVT.g_not_to_delete);

              GML_GME_API_PVT.g_not_to_notify := 1;

           ELSE
              /* set the lot_status for trans */
              l_tran_rec.lot_status := l_lot_status;
              l_go_ahead := 1;
           END IF;
        END IF;
     END IF;

     /* assign line_detail_id for the trans */
     l_tran_rec.line_detail_id := res_rec.delivery_detail_id;
     l_alloc_done := 0;

     IF l_go_ahead = 1 THEN
        GMI_TRANS_ENGINE_PUB.create_pending_transaction
                        (p_api_version      => 1.0,
                         p_init_msg_list    => FND_API.G_TRUE,
                         p_commit           => FND_API.G_FALSE,
                         p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                         p_tran_rec         => l_tran_rec,
                         x_tran_row         => l_tran_row,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_cont,
                         x_msg_data         => x_msg_data
                        );
        IF x_return_status = fnd_api.g_ret_sts_success Then
           GMI_reservation_Util.PrintLn('create_allocation, Success');
           l_history_rec.trans_id := l_tran_row.trans_id;
           l_alloc_done   := 1;
        ELSE
           GMI_reservation_Util.PrintLn('create_allocation, alloc creation error');
           FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
           FND_MESSAGE.Set_Token('WHERE', 'Check rules');
           FND_MSG_PUB.ADD;
           l_history_rec.failure_reason := 'all stack of msgs';
        END IF;
        GMI_RESERVATION_UTIL.balance_default_lot
          ( p_ic_default_rec            => l_dft_tran_rec
          , p_opm_item_id               => l_dft_tran_rec.item_id
          , x_return_status             => x_return_status
          , x_msg_count                 => x_msg_cont
          , x_msg_data                  => x_msg_data
          );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
          FND_MESSAGE.SET_NAME('GML', 'GML_CANNOT_BAL_DFLT_TRAN');
          FND_MESSAGE.SET_TOKEN('LOT_STS', l_gme_trans_row.lot_status);
          l_history_rec.failure_reason :=  FND_MESSAGE.GET;
        END IF;
     END IF;
     IF nvl(p_batch_line_rec.release_type,0) = 20 THEN
        /* IF regenerate, set the current history to delete */
        Update gml_batch_so_alloc_history
        set delete_mark = 1
        Where batch_res_id = res_rec.batch_res_id
           And batch_trans_id = l_gme_trans_row.trans_id
           And failure_reason is not null;
     END IF;
     /* insert history record */
     GML_BATCH_OM_UTIL.insert_alloc_history
           (
                P_alloc_history_rec      => l_history_rec
              , X_return_status          => x_return_status
              , X_msg_cont               => x_msg_cont
              , X_msg_data               => x_msg_data
           );

     l_remaining_alloc_qty := l_remaining_alloc_qty - abs(l_tran_rec.trans_qty);
     l_remaining_alloc_qty2 := l_remaining_alloc_qty2 - abs(l_tran_rec.trans_qty2);
     IF l_alloc_done = 1 THEN
        /* update the reservation record */
        Update gml_batch_so_reservations
        Set allocated_ind = 1
          , reserved_qty = reserved_qty - abs(l_tran_row.trans_qty)
          , reserved_qty2 = reserved_qty2 - abs(l_tran_row.trans_qty2)
        Where batch_res_id = res_rec.batch_res_id;
        /* delete the reservation record if over allocated */
        IF l_over_alloc = 1 THEN
           Update gml_batch_so_reservations
           Set delete_mark = 1
           Where batch_res_id = res_rec.batch_res_id;
        END IF;
     END IF;
  END loop;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    /*   Get message count and data*/
    FND_MSG_PUB.count_and_get
     (   p_count  => x_msg_cont
       , p_data  => x_msg_data
     );
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Expected');
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'create_allocations'
                              );
      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_cont
         , p_data  => x_msg_data
       );
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Others');

 END create_allocations;

 PROCEDURE cancel_alloc_for_trans
 (
    P_Batch_trans_id         IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_tran_rec              GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_dft_tran_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_row              IC_TRAN_PND%ROWTYPE;
  l_trans_id              NUMBER;

  Cursor find_nonstgd_alloc_for_trans (P_batch_trans_id IN NUMBER) IS
  Select ic.trans_id
  From ic_tran_pnd ic
     , gml_batch_so_alloc_history his
  Where his.batch_trans_id = p_batch_trans_id
    and his.trans_id = ic.trans_id
    and ic.line_id = his.line_id
    and ic.staged_ind = 0
    and ic.delete_mark = 0
    and ic.doc_type = 'OMSO'
    ;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* this would remove all the un-staged trans */
  GMI_RESERVATION_UTIL.PrintLn('Cancel_alloc_for_Trans ');
  GMI_RESERVATION_UTIL.PrintLn('   Batch trans id '|| p_batch_trans_id);
  IF p_batch_trans_id is not null THEN
     /* find out the unstaged trans converted from this batch trans line */
     for alloc_rec in find_nonstgd_alloc_for_trans(p_batch_trans_id) Loop
     /* call gmi api to delete this trans */
         l_trans_id := alloc_rec.trans_id;
         l_tran_rec.trans_id := l_trans_id;
         GMI_RESERVATION_UTIL.PrintLn(' Deleting trans_id '||l_trans_id);
         IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_tran_rec, l_tran_rec ) THEN
            GMI_TRANS_ENGINE_PUB.delete_pending_transaction
                            (p_api_version      => 1.0,
                             p_init_msg_list    => FND_API.G_TRUE,
                             p_commit           => FND_API.G_FALSE,
                             p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                             p_tran_rec         => l_tran_rec,
                             x_tran_row         => l_tran_row,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_cont,
                             x_msg_data         => x_msg_data
                            );
            IF x_return_status <> fnd_api.g_ret_sts_success Then
               GMI_reservation_Util.PrintLn('Delete OMSO trans for Batch trans');
               FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
               FND_MESSAGE.Set_Token('WHERE', 'Check rules');
               FND_MSG_PUB.ADD;
            END IF;
         END IF;
         l_dft_tran_rec.line_id := l_tran_rec.line_id;
         l_dft_tran_rec.trans_id := null;
         GMI_RESERVATION_UTIL.find_default_lot
            (  x_return_status      => x_return_status,
                x_msg_count         => x_msg_cont,
                x_msg_data          => x_msg_data,
                x_reservation_id    => l_dft_tran_rec.trans_id,
                p_line_id           => l_tran_rec.line_id
            );

         IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_dft_tran_rec, l_dft_tran_rec ) THEN
           GMI_RESERVATION_UTIL.balance_default_lot
             ( p_ic_default_rec            => l_dft_tran_rec
             , p_opm_item_id               => l_dft_tran_rec.item_id
             , x_return_status             => x_return_status
             , x_msg_count                 => x_msg_cont
             , x_msg_data                  => x_msg_data
             );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
           END IF;
         END IF;
     END loop;
  END IF;
 END cancel_alloc_for_trans;

 PROCEDURE cancel_alloc_for_batch
 (
    P_Batch_id               IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_tran_rec               GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_dft_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_row               IC_TRAN_PND%ROWTYPE;
  l_batch_trans_id         NUMBER;

  Cursor find_nonstgd_alloc_for_batch (P_batch_id IN NUMBER) IS
  Select ic.trans_id
  From ic_tran_pnd ic
     , gml_batch_so_alloc_history his
  Where his.batch_id = p_batch_id
    and his.trans_id = ic.trans_id
    and ic.line_id = his.line_id
    and ic.staged_ind = 0
    and ic.completed_ind = 0
    and ic.delete_mark = 0
    and ic.doc_type = 'OMSO'
    ;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* this would remove all the un-staged trans */
  IF p_batch_id is not null THEN
     /* find out the unstaged trans for this batch line */
     for alloc_rec in find_nonstgd_alloc_for_batch(p_batch_id) Loop
        l_tran_rec.trans_id := alloc_rec.trans_id;
        GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION(
                            p_api_version      => 1.0
                           ,p_init_msg_list    => FND_API.G_TRUE
                           ,p_commit           => FND_API.G_FALSE
                           ,p_validation_level => FND_API.G_VALID_LEVEL_NONE
                           ,p_tran_rec         => l_tran_rec
                           ,x_tran_row         => l_tran_row
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_cont
                           ,x_msg_data         => x_msg_data);
        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d After DELETE_PENDING_TRANSACTION.');
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
          GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Delete_Transaction().');
          FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
          FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION');
          FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        GML_BATCH_OM_RES_PVT.cancel_alloc_for_trans
              (
                   P_Batch_trans_id         => l_batch_trans_id
                 , X_return_status          => X_return_status
                 , X_msg_cont               => X_msg_cont
                 , X_msg_data               => X_msg_data
              );

     /* call gmi api to delete this trans */
     end loop;
  END IF;
 END cancel_alloc_for_batch;

 PROCEDURE cancel_alloc_for_batch_line
 (
    P_Batch_line_id          IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_batch_trans_id           NUMBER;

  Cursor find_nonstgd_alloc_for_batch (P_batch_line_id IN NUMBER) IS
  Select ic.trans_id
  From ic_tran_pnd ic
     , gml_batch_so_alloc_history his
  Where his.batch_line_id = p_batch_line_id
    and his.trans_id = ic.trans_id
    and ic.line_id = his.line_id
    and ic.staged_ind = 0
    and ic.delete_mark = 0
    and ic.doc_type = 'OMSO'
    ;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* this would remove all the un-staged trans */
  IF p_batch_line_id is not null THEN
     /* find out the unstaged trans for this batch line */
     for alloc_rec in find_nonstgd_alloc_for_batch(p_batch_line_id) Loop
        l_batch_trans_id := alloc_rec.trans_id;
        GML_BATCH_OM_RES_PVT.cancel_alloc_for_trans
              (
                   P_Batch_trans_id         => l_batch_trans_id
                 , X_return_status          => X_return_status
                 , X_msg_cont               => X_msg_cont
                 , X_msg_data               => X_msg_data
              );
     /* call gmi api to delete this trans */
     end loop;
  END IF;
 END cancel_alloc_for_batch_line;

 PROCEDURE cancel_res_for_batch_line
 (
    P_Batch_line_id          IN    NUMBER default null
  , P_whse_code              IN    VARCHAR2 default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_batch_trans_id           NUMBER;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_reservation_Util.PrintLn('cancel_res_for_batch_line: batch_line_id '||p_batch_line_id);
  GMI_reservation_Util.PrintLn('cancel_res_for_batch_line: whse_code '||p_whse_code);
  /* this would remove all the un-staged trans */
  IF p_batch_line_id is not null and p_whse_code is null THEN
     Update gml_batch_so_reservations
     Set delete_mark = 1
     Where batch_line_id = p_batch_line_id
        and delete_mark = 0;
     IF SQL%NOTFOUND THEN
        GMI_reservation_Util.PrintLn('cancel_res_for_batch_line: no reservations');
     END IF;
  END IF;
  IF p_batch_line_id is not null and p_whse_code is not null THEN
     Update gml_batch_so_reservations
     Set delete_mark = 1
     Where batch_line_id = p_batch_line_id
        and whse_code = p_whse_code
        and delete_mark = 0;
     IF SQL%NOTFOUND THEN
        GMI_reservation_Util.PrintLn('cancel_res_for_batch_line: no reservations');
     END IF;
  END IF;
 END cancel_res_for_batch_line;

 PROCEDURE cancel_res_for_so_line
 (
    P_so_line_id             IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_batch_trans_id           NUMBER;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_reservation_Util.PrintLn('cancel_res_for_so_line: so_line_id '||p_so_line_id);
  /* this would remove all the un-staged trans */
  IF p_so_line_id is not null THEN
     Update gml_batch_so_reservations
     Set delete_mark = 1
     Where so_line_id = p_so_line_id
        and delete_mark = 0;
     IF SQL%NOTFOUND THEN
        GMI_reservation_Util.PrintLn('cancel_res_for_so_line: no reservations');
     END IF;
  END IF;
 END cancel_res_for_so_line;

 PROCEDURE cancel_res_for_batch
 (
    P_Batch_id               IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_reservation_Util.PrintLn('cancel_res_for_batch: batch_id '||p_batch_id);
  /* this would remove all the un-staged trans */
  IF p_batch_id is not null THEN
     Update gml_batch_so_reservations
     Set delete_mark = 1
     Where batch_id = p_batch_id
        and delete_mark = 0;
     IF SQL%NOTFOUND THEN
        GMI_reservation_Util.PrintLn('cancel_res_for_batch: no reservations');
     END IF;
  END IF;
 END cancel_res_for_batch;

 PROCEDURE cancel_batch
 (
    P_Batch_id               IN    NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /*
     Remove all outstanding reservations and allocations
     When batch is in 'WIP, only terminate can occur. Anything completed remians
     so NO allocations would be removed.
  */
  GML_BATCH_OM_RES_PVT.cancel_res_for_batch
           (
                P_Batch_id               => p_batch_id
              , X_return_status          => x_return_status
              , X_msg_cont               => x_msg_cont
              , X_msg_data               => x_msg_data
           );
  /*GML_BATCH_OM_RES_PVT.cancel_alloc_for_batch
           (
                P_Batch_id               => p_batch_id
              , X_return_status          => x_return_status
              , X_msg_cont               => x_msg_cont
              , X_msg_data               => x_msg_data
           );
   */
 END cancel_batch;

 PROCEDURE notify_CSR
 (
    P_Batch_id               IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_So_line_id             IN    NUMBER default null
  , P_batch_trans_id         IN    NUMBER default null
  , P_whse_code              IN    VARCHAR2 default null
  , P_action_code	     IN    VARCHAR2
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
  l_csr_id                NUMBER;

  l_batch_id			NUMBER;
  l_so_header_id		NUMBER;
  l_so_line_id			NUMBER;
  l_action_code			VARCHAR2(200);
  l_whse_code			VARCHAR2(4);
  l_batch_type			NUMBER;
  l_no_of_staged_alloc		NUMBER;
  l_no_of_unstaged_alloc	NUMBER;
  l_last_updated_by		NUMBER;
  l_created_by			NUMBER;
  l_session_id			NUMBER;
  l_batch_line_id		NUMBER;
  l_old_header_id		NUMBER;
  l_new_header_id		NUMBER;


  CURSOR So_line_id_for_batch(p_batch_id IN NUMBER) Is
  SELECT Distinct so_line_id
    FROM gml_batch_so_reservations
   WHERE batch_id = p_batch_id
     and delete_mark = 0
     and reserved_qty <> 0;

  CURSOR Get_batch_type(p_batch_id IN NUMBER) IS
   SELECT batch_type
     FROM gme_batch_header
    WHERE batch_id = p_batch_id;


  CURSOR So_line_id_for_batch_line(p_batch_line_id IN NUMBER) Is
  SELECT Distinct so_line_id
    FROM gml_batch_so_reservations
   WHERE batch_line_id = p_batch_line_id
     and delete_mark = 0
     and reserved_qty <> 0;

  CURSOR get_batch_id_for_line(p_batch_line_id IN NUMBER) Is
  SELECT gl.batch_id,gh.batch_type
    FROM gme_material_details gl,
         gme_batch_header  gh
   WHERE gl.material_detail_id = p_batch_line_id
     and gl.batch_id = gh.batch_id;



  Cursor so_line_id_for_batch_trans (p_batch_trans_id IN NUMBER) IS
  Select distinct ictran.line_id
  From ic_tran_pnd ictran
    ,  gml_batch_so_alloc_history his
  Where his.batch_trans_id = p_batch_trans_id
    and his.trans_id = ictran.trans_id
    and ictran.doc_type = 'OMSO'
    and ictran.delete_mark = 0
    and ictran.staged_ind = 0
    and ictran.completed_ind = 0
    ;

  Cursor get_batch_id_for_trans (p_batch_trans_id IN NUMBER) IS
  SELECT batch_id
        ,batch_type
        ,batch_line_id
    FROM gml_batch_so_alloc_history
    WHERE batch_trans_id = p_batch_trans_id;


   CURSOR CSR_for_so_line(p_so_line_id IN NUMBER) IS
   SELECT last_updated_by, created_by,header_id
     FROM oe_order_lines_all
    WHERE line_id = p_so_line_id;

  Cursor find_nonstgd_alloc_for_trans (P_batch_trans_id IN NUMBER) IS
  Select count(*)
  From ic_tran_pnd ic
     , gml_batch_so_alloc_history his
  Where his.batch_trans_id = p_batch_trans_id
    and his.trans_id = ic.trans_id
    and ic.line_id = his.line_id
    and ic.staged_ind = 0
    and ic.delete_mark = 0
    and ic.doc_type = 'OMSO'
    ;

  Cursor find_staged_alloc_for_trans (P_batch_trans_id IN NUMBER) IS
  Select count(*)
  From ic_tran_pnd ic
     , gml_batch_so_alloc_history his
  Where his.batch_trans_id = p_batch_trans_id
    and his.trans_id = ic.trans_id
    and ic.line_id = his.line_id
    and ic.staged_ind = 1
    and ic.delete_mark = 0
    and ic.doc_type = 'OMSO'
    ;
  Cursor check_mul_line_id1 (p_user_id IN number
                         , p_batch_id IN NUMBER) IS
  Select distinct so_line_id
  From gml_batch_so_reservations
  Where created_by = p_user_id
    and batch_id = p_batch_id;

  Cursor check_mul_line_id2 (p_user_id IN number
                         , p_batch_id IN NUMBER
                         , p_batch_line_id IN NUMBER) IS
  Select distinct so_line_id
  From gml_batch_so_reservations
  Where created_by = p_user_id
    and batch_id = p_batch_id
    and batch_line_id = p_batch_line_id;

 BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_session_id := USERENV('sessionid');
  l_batch_line_id := p_batch_line_id ;
  l_batch_id := p_batch_id;
  l_whse_code := p_whse_code;

  /* will send the work flow */
  GMI_RESERVATION_UTIL.PrintLn('Entering Notify_ CSR ...........');

  IF p_batch_id is not null THEN

     GMI_RESERVATION_UTIL.PrintLn('Notify CSR : Batch_id is'|| p_batch_id);
     OPEN so_line_id_for_batch(p_batch_id);
     FETCH so_line_id_for_batch INTO l_so_line_id;
     IF(so_line_id_for_batch%NOTFOUND) THEN
       CLOSE so_line_id_for_batch;
       GMI_RESERVATION_UTIL.PrintLn(' so_line_id_for_batch%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;

     CLOSE so_line_id_for_batch;

     OPEN get_batch_type(p_batch_id);
     FETCH get_batch_type INTO l_batch_type;
     IF(get_batch_type%NOTFOUND) THEN
       CLOSE get_batch_type;
       GMI_RESERVATION_UTIL.PrintLn(' get_batch_type%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;

     CLOSE get_batch_type;

  END IF;

  IF p_batch_line_id is not null THEN
     GMI_RESERVATION_UTIL.PrintLn('Notify CSR : Batch_line_id is '|| p_batch_line_id);
     OPEN so_line_id_for_batch_line(p_batch_line_id);
     FETCH so_line_id_for_batch_line INTO l_so_line_id;
     IF(so_line_id_for_batch_line%NOTFOUND) THEN
       CLOSE so_line_id_for_batch_line;
       GMI_RESERVATION_UTIL.PrintLn(' so_line_id_for_batch_line%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;
     CLOSE so_line_id_for_batch_line;

     OPEN get_batch_id_for_line(p_batch_line_id);
     FETCH get_batch_id_for_line INTO l_batch_id,l_batch_type;
     IF(get_batch_id_for_line%NOTFOUND) THEN
       CLOSE get_batch_id_for_line;
       GMI_RESERVATION_UTIL.PrintLn(' get_batch_id_for_line%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;
     CLOSE get_batch_id_for_line;

  END IF;
  IF p_batch_trans_id is not null THEN

     GMI_RESERVATION_UTIL.PrintLn('Notify CSR : Batch_trans_id is '|| p_batch_trans_id);

     OPEN so_line_id_for_batch_trans(p_batch_trans_id);
     FETCH so_line_id_for_batch_trans INTO l_so_line_id;
     IF(so_line_id_for_batch_trans%NOTFOUND) THEN
       CLOSE so_line_id_for_batch_trans;
       GMI_RESERVATION_UTIL.PrintLn(' so_line_id_for_batch_trans%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;
     CLOSE so_line_id_for_batch_trans;

     OPEN get_batch_id_for_trans(p_batch_trans_id);
     FETCH get_batch_id_for_trans INTO l_batch_id,l_batch_type, l_batch_line_id;
     IF(get_batch_id_for_trans%NOTFOUND) THEN
       CLOSE get_batch_id_for_trans;
       GMI_RESERVATION_UTIL.PrintLn(' get_batch_id_for_trans%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;

     CLOSE get_batch_id_for_trans;

  END IF;

  IF p_so_line_id is not null THEN
     /* send notification to all CSRs for this so_line_rec */
     null;
  END IF;


  GMI_RESERVATION_UTIL.PrintLn('Notify CSR : so_line_id is'|| l_so_line_id);
  GMI_RESERVATION_UTIL.PrintLn('Notify CSR : p_whse_code is'|| l_whse_code);
  GMI_RESERVATION_UTIL.PrintLn('Notify CSR : p_action_code is'|| p_action_code);

  l_action_code := p_action_code;

  IF(p_action_code  = 'CANCEL') THEN

    IF(l_batch_type = 10) THEN
       l_action_code := 'CANCEL_FPO';
    ELSE
       l_action_code := 'CANCEL_BATCH';
    END IF;
  END IF;

  IF(p_action_code = 'CMPLT_DATE_CHANGE') THEN
     l_action_code := 'PLAN_COMPL_DATE_CHANGED';
  END IF;

  IF(p_action_code = 'WHSE_CHANGED') THEN

     OPEN find_nonstgd_alloc_for_trans(p_batch_trans_id);
     FETCH find_nonstgd_alloc_for_trans INTO l_no_of_unstaged_alloc;
     IF(find_nonstgd_alloc_for_trans%NOTFOUND) THEN
       CLOSE find_nonstgd_alloc_for_trans;
       GMI_RESERVATION_UTIL.PrintLn(' find_nonstgd_alloc_for_trans%NOTFOUND, returning from Notify CSR');
       RETURN;
     END IF;
     CLOSE find_nonstgd_alloc_for_trans;

     IF (l_no_of_unstaged_alloc >= 1) THEN
        l_action_code := 'CHANGE_PROD_WHSE_UNSTAGED_ALLO';
     ELSE
        OPEN find_staged_alloc_for_trans(p_batch_trans_id);
        FETCH find_staged_alloc_for_trans INTO l_no_of_staged_alloc;
        IF(find_staged_alloc_for_trans%NOTFOUND) THEN
           CLOSE find_staged_alloc_for_trans;
           GMI_RESERVATION_UTIL.PrintLn(' find_staged_alloc_for_trans%NOTFOUND, returning from Notify CSR');
           RETURN;
        END IF;

        CLOSE find_nonstgd_alloc_for_trans;

        IF(l_no_of_staged_alloc >= 1) THEN
          l_action_code := 'CHANGE_PROD_WHSE_STAGED_ALLOC';
        END IF;

      END IF;

  END IF;


  GMI_RESERVATION_UTIL.PrintLn('Notify CSR : l_action_code is'|| l_action_code);

  OPEN CSR_for_so_line(l_so_line_id);
  FETCH CSR_for_so_line INTO  l_last_updated_by,l_created_by, l_so_header_id;
  IF(CSR_for_so_line%NOTFOUND) THEN
     CLOSE CSR_for_so_line;
     GMI_RESERVATION_UTIL.PrintLn(' CSR_for_so_line%NOTFOUND, returning from Notify CSR');
     RETURN;
  END IF;
  CLOSE CSR_for_so_line;
  GMI_RESERVATION_UTIL.PrintLn('Notify CSR : l_last_updated_by is '||l_last_updated_by);
  GMI_RESERVATION_UTIL.PrintLn('Initiating the Workflow......');
  GML_BATCH_WORKFLOW_PKG.Init_wf( p_session_id  => l_session_id
         , p_approver    => l_last_updated_by
         , p_so_header_id=> l_so_header_id
         , p_so_line_id  => l_so_line_id
         , p_batch_id    => l_batch_id
         , p_batch_line_id => NULL
         , p_whse_code   => l_whse_code
         , p_action_code   => l_action_code );

  IF(l_last_updated_by <> l_created_by) THEN

     GMI_RESERVATION_UTIL.PrintLn('Notify CSR : l_created_by is '||l_created_by);
     GMI_RESERVATION_UTIL.PrintLn('Initiating the Workflow......');

     GML_BATCH_WORKFLOW_PKG.Init_wf( p_session_id  => l_session_id
            , p_approver    => l_created_by
            , p_so_header_id=> l_so_header_id
            , p_so_line_id  => l_so_line_id
            , p_batch_id    => l_batch_id
            , p_batch_line_id => NULL
            , p_whse_code   => l_whse_code
            , p_action_code   => l_action_code );
  END IF;

  /* check to see if the same user has multiple sales lines for the reservations */
  /* for each sales order or header_id, one notification is sent */
  IF nvl(l_batch_line_id,0) = 0 THEN
     for mul_line in check_mul_line_id1 (l_last_updated_by, l_batch_id ) Loop
        l_old_header_id := l_so_header_id ;
        l_so_line_id    := mul_line.so_line_id ;
        /* Get the Order and Line Information */
        OPEN CSR_for_so_line(l_so_line_id);
        FETCH CSR_for_so_line INTO  l_last_updated_by,l_created_by, l_new_header_id ;
        CLOSE CSR_for_so_line;
        IF l_new_header_id <> l_old_header_id THEN
           l_so_header_id := l_new_header_id;
           l_old_header_id := l_new_header_id;

           GMI_RESERVATION_UTIL.PrintLn('Notify CSR : Multiple sales orders, header_id'||l_so_header_id);
           GMI_RESERVATION_UTIL.PrintLn('Initiating the Workflow......');
           GML_BATCH_WORKFLOW_PKG.Init_wf( p_session_id  => l_session_id
                  , p_approver    => l_last_updated_by
                  , p_so_header_id=> l_so_header_id
                  , p_so_line_id  => l_so_line_id
                  , p_batch_id    => l_batch_id
                  , p_batch_line_id => NULL
                  , p_whse_code   => l_whse_code
                  , p_action_code   => l_action_code );

           IF(l_last_updated_by <> l_created_by) THEN

              GMI_RESERVATION_UTIL.PrintLn('Notify CSR : l_created_by is '||l_created_by);
              GMI_RESERVATION_UTIL.PrintLn('Initiating the Workflow......');

              GML_BATCH_WORKFLOW_PKG.Init_wf( p_session_id  => l_session_id
                     , p_approver    => l_created_by
                     , p_so_header_id=> l_so_header_id
                     , p_so_line_id  => l_so_line_id
                     , p_batch_id    => l_batch_id
                     , p_batch_line_id => NULL
                     , p_whse_code   => l_whse_code
                     , p_action_code   => l_action_code );
           END IF;
        END IF;
     END LOOP;
  Else
     for mul_line in check_mul_line_id2 (l_last_updated_by, l_batch_id, l_batch_line_id ) Loop
        l_old_header_id := l_so_header_id ;
        l_so_line_id    := mul_line.so_line_id ;
        OPEN CSR_for_so_line(l_so_line_id);
        FETCH CSR_for_so_line INTO  l_last_updated_by,l_created_by, l_new_header_id ;
        CLOSE CSR_for_so_line;
        IF l_new_header_id <> l_old_header_id THEN
           l_so_header_id := l_new_header_id;
           l_old_header_id := l_new_header_id;

           GMI_RESERVATION_UTIL.PrintLn('Notify CSR : Multiple sales orders, header_id'||l_so_header_id);
           GMI_RESERVATION_UTIL.PrintLn('Initiating the Workflow......');
           GML_BATCH_WORKFLOW_PKG.Init_wf( p_session_id  => l_session_id
                  , p_approver    => l_last_updated_by
                  , p_so_header_id=> l_so_header_id
                  , p_so_line_id  => l_so_line_id
                  , p_batch_id    => l_batch_id
                  , p_batch_line_id => NULL
                  , p_whse_code   => l_whse_code
                  , p_action_code   => l_action_code );

           IF(l_last_updated_by <> l_created_by) THEN

              GMI_RESERVATION_UTIL.PrintLn('Notify CSR : l_created_by is '||l_created_by);
              GMI_RESERVATION_UTIL.PrintLn('Initiating the Workflow......');

              GML_BATCH_WORKFLOW_PKG.Init_wf( p_session_id  => l_session_id
                     , p_approver    => l_created_by
                     , p_so_header_id=> l_so_header_id
                     , p_so_line_id  => l_so_line_id
                     , p_batch_id    => l_batch_id
                     , p_batch_line_id => NULL
                     , p_whse_code   => l_whse_code
                     , p_action_code   => l_action_code );
           END IF;
        END IF;
     END LOOP;
  END IF;


  GMI_RESERVATION_UTIL.PrintLn('Exiting Notify_CSR  .............');

EXCEPTION

WHEN OTHERS THEN
    GMI_RESERVATION_UTIL.PrintLn('WARNING....  In Others Exception in Notify CSR');
    GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));

 END notify_CSR;

 PROCEDURE regenerate_alloc
 (
    P_alloc_history_rec      IN  GML_BATCH_OM_UTIL.alloc_history_rec
  , x_return_status          OUT NOCOPY VARCHAR2
 ) IS
  l_batch_line_rec        GML_BATCH_OM_UTIL.batch_line_rec ;
  l_gme_om_rule_rec       GML_BATCH_OM_UTIL.gme_om_rule_rec;
  l_Gme_trans_row         ic_tran_pnd%rowtype;
  l_omso_trans_id         NUMBER;
  l_msg_cont              NUMBER;
  l_msg_data              VARCHAR2(300);
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_batch_line_rec.batch_line_id := p_alloc_history_rec.batch_line_id;
  l_gme_om_rule_rec.rule_id := null;
  Select *
  Into l_gme_trans_row
  From ic_tran_pnd
  Where trans_id = p_alloc_history_rec.batch_trans_id;
  IF SQL%NOTFOUND THEN
     GMI_reservation_Util.PrintLn('regenerate_alloc: no gme_trans');
  END IF;
  /* set release type = 20, internal use */
  l_batch_line_rec.release_type := 20;
  GML_BATCH_OM_RES_PVT.create_allocations
           (
              P_batch_line_rec         => l_batch_line_rec
            , P_gme_om_rule_rec        => l_gme_om_rule_rec
            , P_Gme_trans_row          => l_gme_trans_row
            , X_return_status          => x_return_status
            , X_msg_cont               => l_msg_cont
            , X_msg_data               => l_msg_data
           ) ;

  IF x_return_status = fnd_api.g_ret_sts_success Then
     /* delete the history record because new history records are created */
     update gml_batch_so_alloc_history
     set delete_mark = 1
     Where alloc_rec_id = p_alloc_history_rec.alloc_rec_id;

     /* NC Bug#3470056 Call pick confirm if the flag is set */
     IF l_gme_om_rule_rec.auto_pick_confirm = 'Y'  THEN
           GMI_RESERVATION_UTIL.println('Allocation is successful. Pickconfirm');
           /* get the mo line id for the source line */
           GML_BATCH_OM_RES_PVT.pick_confirm
           (
              P_batch_line_rec         => l_batch_line_rec
            , P_Gme_trans_row          => l_gme_trans_row
            , X_return_status          => x_return_status
            , X_msg_cont               => l_msg_cont
            , X_msg_data               => l_msg_data
           );

           IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
              GMI_RESERVATION_UTIL.PrintLn('WARNING : Pick Confirm Returned error after re-generating the allocations');
           END IF;

      END IF;

  ELSE
     GMI_reservation_Util.PrintLn('In Else part after GML_BATCH_OM_RES_PVT.create_allocations returned a status other than success In regenerate_alloc');
     GMI_reservation_Util.PrintLn('OM_UTIL, checking rule failure');
     FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
     FND_MESSAGE.Set_Token('WHERE', 'Check rules');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  GML_GME_API_PVT.g_not_to_notify := 1;
 END regenerate_alloc;

 PROCEDURE process_om_reservations
 (
    p_from_batch_id          IN  NUMBER default null
  , P_batch_line_rec         IN  GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_trans_row          IN  ic_tran_pnd%rowtype
  , P_batch_action           IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
 ) IS
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 null;
 END process_om_reservations;

 PROCEDURE split_reservations
 (   p_old_delivery_detail_id  IN  NUMBER
   , p_new_delivery_detail_id  IN  NUMBER
   , p_old_source_line_id      IN  NUMBER
   , p_new_source_line_id      IN  NUMBER
   , p_qty_to_split            IN  NUMBER
   , p_qty2_to_split           IN  NUMBER
   , p_orig_qty                IN  NUMBER
   , p_orig_qty2               IN  NUMBER
   , p_action                  IN  VARCHAR2
   , x_return_status           OUT NOCOPY VARCHAR2
   , x_msg_count               OUT NOCOPY NUMBER
   , x_msg_data                OUT NOCOPY VARCHAR2
 ) IS
  l_fulfilled_qty          NUMBER;
  l_qty_to_fulfil          NUMBER;
  l_qty2_to_fulfil         NUMBER;
  l_so_line_rec            GML_BATCH_OM_UTIL.so_line_rec;
  l_batch_line_rec         GML_BATCH_OM_UTIL.batch_line_rec;
  l_reservation_rec        GML_BATCH_OM_UTIL.gme_om_reservation_rec;

  cursor c_reservations IS
    SELECT reserved_qty
        ,  reserved_qty2
        ,  batch_res_id
      FROM gml_batch_so_reservations
     WHERE so_line_id = p_old_source_line_id
       AND delivery_detail_id = p_old_delivery_detail_id
       AND delete_mark = 0
       AND reserved_qty <> 0
     ORDER BY 1 ; /* the smaller qty is at the top, keep in mind it is neg */
                              /* or should consider the alloc rules */
  cursor c_reservations1 IS  -- Not booked
    SELECT reserved_qty
        ,  reserved_qty2
        ,  batch_res_id
      FROM gml_batch_so_reservations
     WHERE so_line_id = p_old_source_line_id
       AND delete_mark = 0
       AND reserved_qty <> 0
     ORDER BY 1; /* the smaller qty is at the top, keep in mind it is neg */
                              /* or should consider the alloc rules */
  res_rec c_reservations%rowtype;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_reservation_Util.PrintLn('Split Reservations for GME');
  /* check the reservations, if non exists, exit */
  IF p_old_source_line_id is not null THEN
     IF NOT GML_BATCH_OM_UTIL.check_reservation
        (
          P_so_line_id             => p_old_source_line_id
        , X_return_status          => x_return_status
        , X_msg_cont               => x_msg_count
        , X_msg_data               => x_msg_data
        )
     THEN
        GMI_reservation_Util.PrintLn('Split Reservations: No reservations found for so line ');
        return;
     END IF;
  END IF;
  IF p_old_delivery_detail_id is not null THEN
     IF NOT GML_BATCH_OM_UTIL.check_reservation
        (
          P_delivery_detail_id     => p_old_delivery_detail_id
        , X_return_status          => x_return_status
        , X_msg_cont               => x_msg_count
        , X_msg_data               => x_msg_data
        )
     THEN
        GMI_reservation_Util.PrintLn('Split Reservations: No reservations found for wdd line ');
        return;
     END IF;
  END IF;
  GMI_RESERVATION_UTIL.Println(' p_old_delivery_detail_id '||p_old_delivery_detail_id);
  GMI_RESERVATION_UTIL.Println(' p_new_delivery_detail_id '||p_new_delivery_detail_id);
  GMI_RESERVATION_UTIL.Println(' p_old_source_line_id '||p_old_source_line_id);
  GMI_RESERVATION_UTIL.Println(' p_new_source_line_id '||p_new_source_line_id);

  IF p_action = 'B' THEN -- Back ordering or staging
     Update gml_batch_so_reservations
     Set so_line_id = p_new_source_line_id
     Where so_line_id = p_old_source_line_id
       And delete_mark = 0
       And reserved_qty <> 0;
  END IF;
  IF p_action = 'O' THEN -- all others, just to split
     /* this used to be for NONcontroled items or non inv*/

       /*IF (p_new_delivery_detail_id is NOT NULL) AND (p_old_source_line_id is NOT NULL) AND
           (p_new_source_line_id is NOT NULL) AND (p_old_source_line_id  <> p_new_source_line_id) THEN
           Update gml_batch_so_reservtions
              Set so_line_id  = p_new_source_line_id
           Where so_line_id  = p_old_source_line_id
            and delivery_detail_id = p_new_delivery_detail_id
            and delte_mark = 0
            and reserved_qty <> 0;
           GMI_RESERVATION_UTIL.PrintLn('Updated Here');
         END IF;*/
     -- all GME reservations now are for controlled items only
     l_fulfilled_qty := 0;
     l_qty_to_fulfil  := p_orig_qty - p_qty_to_split;
     l_qty2_to_fulfil := p_orig_qty2 - p_qty2_to_split;
     --l_qty_to_fulfil  := p_qty_to_split;
     --l_qty2_to_fulfil := p_qty2_to_split;

     GMI_RESERVATION_UTIL.Println('in split_res, qty to split '||p_qty_to_split);
     GMI_RESERVATION_UTIL.Println('in split_res, qty2 to split '||p_qty2_to_split);
     GMI_RESERVATION_UTIL.Println('in split_res, qty to fulfil '||l_qty_to_fulfil);
     IF p_old_delivery_detail_id is null THEN -- not booked
        Open c_reservations1;
     ELSE
        Open c_reservations;
     END IF;
     Loop
     -- for res_rec in c_reservations Loop
        IF p_old_delivery_detail_id is null THEN -- not booked
           Fetch c_reservations1 into res_rec;
        ELSE
           Fetch c_reservations into res_rec;
        END IF;
        EXIT WHEN res_rec.batch_res_id is null;
        IF p_old_delivery_detail_id is null THEN -- not booked
           EXIT WHEN c_reservations1%NOTFOUND;
        ELSE
           EXIT WHEN c_reservations%NOTFOUND;
        END IF;
        IF abs(res_rec.reserved_qty) < l_qty_to_fulfil THEN
          /* do nothing for the res */
          GMI_RESERVATION_UTIL.Println('in split_res, keep trans the same for batch_res_id '||res_rec.batch_res_id);
          GMI_RESERVATION_UTIL.Println('in split_res, reserved_qty '||res_rec.reserved_qty);
          l_qty_to_fulfil := l_qty_to_fulfil - abs(res_rec.reserved_qty);
          l_qty2_to_fulfil := l_qty2_to_fulfil - abs(res_rec.reserved_qty2);
        ELSIF res_rec.reserved_qty > l_qty_to_fulfil AND l_qty_to_fulfil > 0 THEN
          update gml_batch_so_reservations
          set reserved_qty =  l_qty_to_fulfil
            , reserved_qty2 = l_qty2_to_fulfil
          Where batch_res_id = res_rec.batch_res_id;

          GMI_RESERVATION_UTIL.Println('in split_res, split res '||res_rec.batch_res_id);
          GMI_RESERVATION_UTIL.Println('in split_res, reserved_qty '||res_rec.reserved_qty);
          l_so_line_rec.so_line_id := null;
          l_batch_line_rec.batch_line_id := null;
          l_reservation_rec.batch_res_id := res_rec.batch_res_id;
          /* create a new res for the new wdd, and new line_id if applicable */
          GML_BATCH_OM_UTIL.query_reservation
           (
              P_So_line_rec            => l_so_line_rec
            , P_Batch_line_rec         => l_batch_line_rec
            , P_Gme_om_reservation_rec => l_reservation_rec
            , X_return_status          => x_return_status
            , X_msg_cont               => x_msg_count
            , X_msg_data               => x_msg_data
           ) ;
          l_reservation_rec.batch_res_id := null;
          l_reservation_rec.reserved_qty := res_rec.reserved_qty - l_qty_to_fulfil;
          l_reservation_rec.reserved_qty2 := res_rec.reserved_qty2 - l_qty2_to_fulfil;
          l_reservation_rec.so_line_id := p_new_source_line_id;
          l_reservation_rec.delivery_detail_id := p_new_delivery_detail_id;
          GML_BATCH_OM_UTIL.insert_reservation
           (
              P_Gme_om_reservation_rec => l_reservation_rec
            , X_return_status          => x_return_status
            , X_msg_cont               => x_msg_count
            , X_msg_data               => x_msg_data
           ) ;
          /* qty filfilled*/
          l_qty_to_fulfil := 0;
          l_qty2_to_fulfil := 0;
        ELSIF l_qty_to_fulfil <= 0 THEN
          GMI_RESERVATION_UTIL.Println('in split_res, update res '||res_rec.batch_res_id);
          GMI_RESERVATION_UTIL.Println('in split_res, reserved_qty '||res_rec.reserved_qty);
          -- simply update the rest with the new wdd id and new line_id
          update gml_batch_so_reservations
          set delivery_detail_id = p_new_delivery_detail_id
            , so_line_id = p_new_source_line_id
          Where batch_res_id = res_rec.batch_res_id;
        END IF;
     END LOOP;
     IF p_old_delivery_detail_id is null THEN -- not booked
        Close c_reservations1;
     ELSE
        Close c_reservations;
     END IF;
  END IF;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    /*   Get message count and data*/
    FND_MSG_PUB.count_and_get
     (   p_count  => x_msg_count
       , p_data  => x_msg_data
     );
    GMI_reservation_Util.PrintLn('Split reservations: EXCEPTION: Expected');
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'Split_reservations'
                              );
      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      GMI_reservation_Util.PrintLn('Split reservations EXCEPTION: Others');

 END split_reservations;

 PROCEDURE split_reservations_from_om
 (   p_old_source_line_id      IN  NUMBER
   , p_new_source_line_id      IN  NUMBER
   , p_qty_to_split            IN  NUMBER    -- remaining qty to the old line_id
   , p_qty2_to_split           IN  NUMBER    -- remaining qty2 to the old line_id
   , p_orig_qty                IN  NUMBER
   , p_orig_qty2               IN  NUMBER
   , x_return_status           OUT NOCOPY VARCHAR2
   , x_msg_count               OUT NOCOPY NUMBER
   , x_msg_data                OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GML_BATCH_OM_RES_PVT.split_reservations
     (  p_old_delivery_detail_id  => null
     ,  p_new_delivery_detail_id  => null
     ,  p_old_source_line_id      => p_old_source_line_id
     ,  p_new_source_line_id      => p_new_source_line_id
     ,  p_qty_to_split            => p_orig_qty - p_qty_to_split   -- oppsite from OM
     ,  p_qty2_to_split           => p_orig_qty - p_qty2_to_split
     ,  p_orig_qty                => p_orig_qty
     ,  p_orig_qty2               => p_orig_qty2
     ,  p_action                  => 'O'
     ,  x_return_status           => x_return_status
     ,  x_msg_count               => x_msg_count
     ,  x_msg_data                => x_msg_data
     ) ;

 END split_reservations_from_om;

 PROCEDURE check_gmeres_for_so_line
 (   p_so_line_id          IN NUMBER
   , p_delivery_detail_id  IN NUMBER
   , x_return_status       OUT NOCOPY VARCHAR2
 ) IS
  l_msg_cont              NUMBER;
  l_msg_data              VARCHAR2(300);
 BEGIN
  IF NOT GML_BATCH_OM_UTIL.check_reservation
       (
          p_so_line_id             => p_so_line_id
        , X_return_status          => x_return_status
        , X_msg_cont               => l_msg_cont
        , X_msg_data               => l_msg_data
       )
  THEN
     return;
  END IF;

  update gml_batch_so_reservations
  set delivery_detail_id = p_delivery_detail_id
  Where so_line_id = p_so_line_id
   and  delete_mark = 0;

 END check_gmeres_for_so_line;

 PROCEDURE pick_confirm
 (
    P_batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_trans_row          IN    ic_tran_pnd%rowtype
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

 l_mo_line_id             NUMBER;
 l_delivery_detail_id     NUMBER;
 l_detailed_qty           NUMBER;
 l_detailed_qty2          NUMBER;
 l_qty_um                 VARCHAR2(5);
 l_qty_um2                VARCHAR2(5);

 Cursor get_wdd_id (p_batch_trans_id  IN NUMBER) IS
 Select line_detail_id
 From ic_tran_pnd
 Where delete_mark = 0
  and  trans_id in
     (Select trans_id
      From gml_batch_so_alloc_history
      Where  batch_trans_id = p_batch_trans_id
        and  delete_mark = 0
     )
 ;

 Cursor get_mo_line_id (p_batch_line_id IN NUMBER ) IS
 Select distinct wdd.move_order_line_id
 From wsh_delivery_details wdd
   ,  ic_tran_pnd ictran
 Where wdd.delivery_detail_id = ictran.line_detail_id
  and  ictran.delete_mark = 0
  and  ictran.trans_id in
     (Select trans_id
      From gml_batch_so_alloc_history
      Where  batch_line_id = p_batch_line_id
        and  delete_mark = 0
     )
 ;

 BEGIN
  l_mo_line_id := 0;
  /* get the move order line id */
  for mo_id_rec in get_mo_line_id(p_batch_line_rec.batch_line_id) loop
     l_mo_line_id := mo_id_rec.move_order_line_id;
     GMI_RESERVATION_UTIL.println('Pick confirm move order line id  '|| l_mo_line_id);
     IF nvl(l_mo_line_id, 0) <> 0 THEN
        GMI_MOVE_ORDER_LINE_UTIL.Line_Pick_Confirm
           (  p_mo_line_id                    => l_mo_line_id
           ,  p_init_msg_list                 => 1
           ,  p_move_order_type               => 3
           ,  x_delivered_qty                 => l_detailed_qty
           ,  x_qty_UM                        => l_qty_um
           ,  x_delivered_qty2                => l_detailed_qty2
           ,  x_qty_UM2                       => l_qty_um2
           ,  x_return_status                 => x_return_status
           ,  x_msg_count                     => x_msg_cont
           ,  x_msg_data                      => x_msg_data
           );
        IF x_return_status <> fnd_api.g_ret_sts_success Then
           GMI_reservation_Util.PrintLn('pick confirm failed ');
           FND_MESSAGE.SET_NAME('GMI','GMI_PICK_CONFIRM');
           FND_MESSAGE.Set_Token('WHERE', 'pick confirm ');
           FND_MSG_PUB.ADD;
           --RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
  end loop;
 END pick_confirm ;

 PROCEDURE build_trans_rec
 (
    p_trans_row       IN   ic_tran_pnd%rowtype
  , x_trans_rec       IN OUT  NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
 ) IS
 BEGIN
  x_trans_rec.trans_id       := null;
  x_trans_rec.item_id        := p_trans_row.item_id;
  x_trans_rec.co_code        := p_trans_row.co_code;
  x_trans_rec.orgn_code      := p_trans_row.orgn_code;
  x_trans_rec.whse_code      := p_trans_row.whse_code;
  x_trans_rec.lot_id         := p_trans_row.lot_id;
  x_trans_rec.location       := p_trans_row.location;
  x_trans_rec.doc_type       := 'OMSO';
  x_trans_rec.reason_code    := null;
  x_trans_rec.trans_date     := sysdate;
  x_trans_rec.qc_grade       := p_trans_row.qc_grade;
  x_trans_rec.lot_status     := p_trans_row.lot_status;
  x_trans_rec.trans_um       := p_trans_row.trans_um;
  x_trans_rec.trans_um2      := p_trans_row.trans_um2;
  x_trans_rec.staged_ind     := 0;

 END build_trans_rec;

 PROCEDURE build_res_rec
 (
    p_res_row       IN   gml_batch_so_reservations%rowtype
  , x_res_rec       OUT  NOCOPY GML_BATCH_OM_UTIL.gme_om_reservation_rec
 ) IS
 BEGIN
  x_res_rec.batch_res_id        := null;
  x_res_rec.item_id             := p_res_row.item_id;
  x_res_rec.whse_code           := p_res_row.whse_code;
  x_res_rec.order_id            := p_res_row.order_id;
  x_res_rec.so_line_id          := p_res_row.so_line_id;
  x_res_rec.delivery_detail_id  := p_res_row.delivery_detail_id;
  x_res_rec.mo_line_id          := p_res_row.mo_line_id;
  x_res_rec.uom1                := p_res_row.qty_uom;
  x_res_rec.uom2                := p_res_row.qty2_uom;
  x_res_rec.sched_ship_date     := p_res_row.scheduled_ship_date;

 END build_res_rec;

PROCEDURE PRINT_DEBUG
(
  p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
 ,p_routine          IN  VARCHAR2
)
IS
BEGIN

GMI_RESERVATION_UTIL.println(' *** Called From -> ' || p_routine );
GMI_RESERVATION_UTIL.println(' TRANS_ID    -> '  || p_tran_rec.trans_id);
GMI_RESERVATION_UTIL.println(' ITEM_ID     -> '  || p_tran_rec.item_id);
GMI_RESERVATION_UTIL.println(' LINE_ID     -> '  || p_tran_rec.line_id);
GMI_RESERVATION_UTIL.println(' CO_CODE     -> '  || p_tran_rec.co_code);
GMI_RESERVATION_UTIL.println(' ORGN_CODE   -> '  || p_tran_rec.orgn_code);
GMI_RESERVATION_UTIL.println(' WHSE_CODE   -> '  || p_tran_rec.whse_code);
GMI_RESERVATION_UTIL.println(' LOT_ID      -> '  || p_tran_rec.lot_id);
GMI_RESERVATION_UTIL.println(' LOCATION    -> '  || p_tran_rec.location);
GMI_RESERVATION_UTIL.println(' DOC_ID      -> '  || p_tran_rec.doc_id);
GMI_RESERVATION_UTIL.println(' DOC_TYPE    -> '  || p_tran_rec.doc_type);
GMI_RESERVATION_UTIL.println(' DOC_LINE    -> '  || p_tran_rec.doc_line);
GMI_RESERVATION_UTIL.println(' LINE_TYPE   -> '  || p_tran_rec.line_type);
GMI_RESERVATION_UTIL.println(' REAS_CODE   -> '  || p_tran_rec.reason_code);
GMI_RESERVATION_UTIL.println(' TRANS_DATE  -> '  || p_tran_rec.trans_date);
GMI_RESERVATION_UTIL.println(' TRANS_QTY   -> '  || p_tran_rec.trans_qty);
GMI_RESERVATION_UTIL.println(' TRANS_QTY2  -> '  || p_tran_rec.trans_qty2);
GMI_RESERVATION_UTIL.println(' QC_GRADE    -> '  || p_tran_rec.qc_grade);
GMI_RESERVATION_UTIL.println(' LOT_STATUS  -> '  || p_tran_rec.lot_status);
GMI_RESERVATION_UTIL.println(' TRANS_STAT  -> '  || p_tran_rec.trans_stat);
GMI_RESERVATION_UTIL.println(' TRANS_UM    -> '  || p_tran_rec.trans_um);
GMI_RESERVATION_UTIL.println(' TRANS_UM2   -> '  || p_tran_rec.trans_um2);
GMI_RESERVATION_UTIL.println(' USER_ID     -> '  || p_tran_rec.user_id);
GMI_RESERVATION_UTIL.println(' TEXT_CODE   -> '  || p_tran_rec.text_code);
GMI_RESERVATION_UTIL.println(' NON_INV     -> '  || p_tran_rec.non_inv);
GMI_RESERVATION_UTIL.println(' STAGED_IND  -> '  || p_tran_rec.staged_ind);

END PRINT_DEBUG;

END GML_BATCH_OM_RES_PVT;

/

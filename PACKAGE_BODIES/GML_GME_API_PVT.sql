--------------------------------------------------------
--  DDL for Package Body GML_GME_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_GME_API_PVT" AS
/*  $Header: GMLFGMEB.pls 120.0 2005/05/25 16:37:22 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private APIs  relating to OPM                 |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GML_GME_API_PVT
  Type      : Private
  Function  : This package contains Private API procedures used to
              OPM reservation for a batch.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

 G_PROD_YIELDED     Number(5) := 0;    -- Product has not been yielded
 G_BATCH_ID         Number(15):= 0;    -- Batch id for the session
 G_BATCH_LINE_ID    Number(15):= 0;    -- Batch line id for the session

 PROCEDURE process_om_reservations
 (
    P_from_batch_id          IN  NUMBER default null
  , P_batch_line_rec         IN  GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_trans_row          IN  ic_tran_pnd%rowtype
  , P_batch_action           IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
 ) IS
  l_so_line_rec           GML_BATCH_OM_UTIL.so_line_rec ;
  l_rule_rec              GML_BATCH_OM_UTIL.gme_om_rule_rec ;
  l_history_rec           GML_BATCH_OM_UTIL.alloc_history_rec;
  ll_history_rec          GML_BATCH_OM_UTIL.alloc_history_rec;
  l_batch_line_rec        GML_BATCH_OM_UTIL.batch_line_rec ;
  l_batch_id              NUMBER;
  l_batch_line_id         NUMBER;
  l_batch_trans_id        NUMBER;
  l_msg_cont              NUMBER;
  l_msg_data              VARCHAR2(300);
  l_old_gme_trans_row     ic_tran_pnd%rowtype;
  l_new_gme_trans_row     ic_tran_pnd%rowtype;
  l_tran_row              ic_tran_pnd%rowtype;
  l_res_qty               NUMBER;
  l_res_qty2              NUMBER;
  l_trans_qty             NUMBER;
  l_trans_qty2            NUMBER;
  l_planned_qty           NUMBER;
  l_planned_qty2          NUMBER;
  l_whse_code             VARCHAR2(5);
  l_trans_id              NUMBER;
  l_tran_rec              GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_dft_tran_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_notify                NUMBER;
  l_update_history        NUMBER;
  l_return_status         VARCHAR2(30);

  Cursor get_trans_row (p_trans_id IN NUMBER) is
  Select *
  from ic_tran_pnd
  where trans_id = p_trans_id;

  Cursor check_res_whse (p_batch_line_id IN NUMBER) is
  Select distinct whse_code
  From gml_batch_so_reservations
  Where batch_line_id = p_batch_line_id;

  Cursor get_res_qty(p_batch_line_id IN NUMBER
                   , p_whse_code IN VARCHAR2) is
  Select sum(reserved_qty), sum(reserved_qty2)
  From gml_batch_so_reservations
  Where batch_line_id = p_batch_line_id
   and  whse_code = p_whse_code
   and  delete_mark = 0;

  Cursor get_planned_qty (p_batch_line_id IN NUMBER
                       ,  p_whse_code IN VARCHAR2) is
  Select abs(sum(nvl(trans_qty,0))), abs(sum(nvl(trans_qty2,0)))
  From ic_tran_pnd
  Where line_id = p_batch_line_id
    and whse_code = p_whse_code
    and doc_type in ('PROD', 'FPO')
    and delete_mark = 0
    and completed_ind = 0;

  Cursor get_trans_id (P_batch_trans_id IN NUMBER) IS
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

  Cursor get_total_OMSO (p_gme_trans_id IN NUMBER) IS
  Select abs(sum(trans_qty)),abs(sum(trans_qty2))
  From ic_tran_pnd ic
    ,  gml_batch_so_alloc_history his
  Where his.batch_trans_id = p_gme_trans_id
    and his.trans_id = ic.trans_id
    and his.delete_mark = 0
    and ic.delete_mark = 0
    and ic.completed_ind = 0
    ;

  Cursor get_history_id (p_gme_trans_id in NUMBER) IS
  Select alloc_rec_id
  From gml_batch_so_alloc_history
  Where batch_trans_id = p_gme_trans_id
    and delete_mark = 0
    ;

  Cursor get_res_for_batch_line(p_batch_line_id In NUMBER) is
  Select scheduled_ship_date
  From gml_batch_so_reservations
  Where batch_line_id = p_batch_line_id
    and delete_mark = 0
    and reserved_qty <> 0
    ;

  Cursor get_lnid_for_batch(p_batch_id In NUMBER) is
  Select distinct batch_line_id
  From gml_batch_so_reservations
  Where batch_id = p_batch_id
    and delete_mark = 0
    and reserved_qty <> 0
    ;

 BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  l_notify := 0;
  l_update_history := 0;

  GMI_RESERVATION_UTIL.println('--- Process_OM_reservations --- ');
  GMI_RESERVATION_UTIL.println('Action code '||p_batch_action);
  GMI_RESERVATION_UTIL.println('p_from_batch_id'||p_from_batch_id);
  GMI_RESERVATION_UTIL.println('p_batch_line.batch_id '||p_batch_line_rec.batch_id);
  GMI_RESERVATION_UTIL.println('p_batch_line.batch_line_id '||p_batch_line_rec.batch_line_id);
  GMI_RESERVATION_UTIL.println('p_batch_line.trans_id '||p_batch_line_rec.trans_id);
  GMI_RESERVATION_UTIL.println('p_gme_trans_row.trans_id '||p_gme_trans_row.trans_id);
  GMI_RESERVATION_UTIL.println('g_batch_id '||g_batch_id);
  GMI_RESERVATION_UTIL.println('g_batch_line_id '||g_batch_line_id);
  l_batch_line_rec := p_batch_line_rec;
  l_batch_id := p_batch_line_rec.batch_id;
  l_batch_line_id := p_batch_line_rec.batch_line_id;
  l_batch_trans_id := p_batch_line_rec.trans_id;
  l_new_gme_trans_row := p_gme_trans_row;

  IF g_batch_id = 0 THEN
     g_batch_id := l_batch_id ;  -- initialize the gloable variable
  END IF;
  IF g_batch_line_id = 0 THEN
     g_batch_line_id := l_batch_line_id ;  -- initialize the gloable variable
  END IF;

  IF l_batch_id <> g_batch_id OR l_batch_line_id <> g_batch_line_id THEN
     GMI_RESERVATION_UTIL.println('reset global ');
     g_batch_id := l_batch_id;
     g_batch_line_id := l_batch_line_id;
     g_prod_yielded := 0; -- Batch initiation
     GML_GME_API_PVT.g_not_to_delete := 0; -- always delete reservation when availability is 0
  END IF;

  IF p_from_batch_id is not null THEN
     l_batch_id := p_from_batch_id;
  END IF;

  /* check the reservations, if non exists, exit */
  IF l_batch_line_id is not null THEN
     IF NOT GML_BATCH_OM_UTIL.check_reservation
         (
            P_Batch_line_id          => p_batch_line_rec.batch_line_id
          , X_return_status          => x_return_status
          , X_msg_cont               => l_msg_cont
          , X_msg_data               => l_msg_data
         )
     THEN
        return;
     END IF;
  END IF;
  IF l_batch_id is not null THEN
     IF NOT GML_BATCH_OM_UTIL.check_reservation
         (
            P_Batch_id               => l_batch_id
          , X_return_status          => x_return_status
          , X_msg_cont               => l_msg_cont
          , X_msg_data               => l_msg_data
         )
     THEN
        return;
     END IF;
  END IF;

  -- Batch level actions
  IF p_batch_action = 'CONVERT' THEN
     GMI_RESERVATION_UTIL.PrintLn(' Batch level actions: CONVERT');
     /* FPO convert to batches */
     IF p_from_batch_id is null THEN
        GMI_RESERVATION_UTIL.println('PRocess_om_reservations ...FPO batch_id is null');
        return;
     END IF;
     GML_BATCH_OM_RES_PVT.create_reservation_from_FPO
       (
          P_FPO_batch_id           => p_from_batch_id
        , P_New_batch_id           => p_batch_line_rec.batch_id
        , X_return_status          => x_return_status
        , X_msg_cont               => l_msg_cont
        , X_msg_data               => l_msg_data
       );
     return;
  END IF;

  IF p_batch_action = 'DELETE' THEN
      /* 1) cancel-terminate batch -- batch level done here
      * 2) reserval batch at the trans level -- batch line level blocks below
      */
     IF p_batch_line_rec.batch_id is not null
        and p_batch_line_rec.batch_line_id is null
        and p_batch_line_rec.trans_id is null
     THEN
        GMI_RESERVATION_UTIL.PrintLn(' Batch level actions: DELETE');
        GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....Calling GML_BATCH_OM_RES_PVT.cancel_batch');
        For res in get_lnid_for_batch(p_batch_line_rec.batch_id) Loop
           l_batch_line_rec.batch_line_id := res.batch_line_id;
           /* get the rule for the batch line */
           GML_BATCH_OM_UTIL.get_rule
                 (
                    P_so_line_rec            => l_so_line_rec
                  , P_batch_line_rec         => l_batch_line_rec
                  , X_gme_om_rule_rec        => l_rule_rec
                  , X_return_status          => x_return_status
                  , X_msg_cont               => l_msg_cont
                  , X_msg_data               => l_msg_data
                 );
           IF l_rule_rec.order_notification = 'Y' THEN
              GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....Calling GML_BATCH_OM_RES_PVT.notify_CSR');
              GML_BATCH_OM_RES_PVT.notify_CSR
                 (
                   P_Batch_line_id          => res.batch_line_id
                 , P_action_code            => 'CANCEL'
                 , X_return_status          => x_return_status
                 , X_msg_cont               => l_msg_cont
                 , X_msg_data               => l_msg_data
                 );
           END IF;
         END LOOP;

         GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....After GML_BATCH_OM_RES_PVT.cancel_batch');
         GML_BATCH_OM_RES_PVT.cancel_batch
           (
              P_Batch_id               => p_batch_line_rec.batch_id
            , X_return_status          => x_return_status
            , X_msg_cont               => l_msg_cont
            , X_msg_data               => l_msg_data
           );
        return;
     END IF;
  END IF;

  IF p_batch_line_rec.batch_id is not null
     And p_batch_line_rec.batch_line_id is null THEN
     IF p_batch_action = 'NOTIFY_CSR' THEN
        GMI_RESERVATION_UTIL.PrintLn(' Batch level actions: NOTIFY_CSR');
        /* check to see the planned complt date */
        For res in get_lnid_for_batch(p_batch_line_rec.batch_id) Loop
           l_batch_line_rec.batch_line_id := res.batch_line_id;
           /* get the rule for the batch line */
           GML_BATCH_OM_UTIL.get_rule
                 (
                    P_so_line_rec            => l_so_line_rec
                  , P_batch_line_rec         => l_batch_line_rec
                  , X_gme_om_rule_rec        => l_rule_rec
                  , X_return_status          => x_return_status
                  , X_msg_cont               => l_msg_cont
                  , X_msg_data               => l_msg_data
                 );
           IF l_rule_rec.order_notification = 'Y' THEN
              For res_line in get_res_for_batch_line(res.batch_line_id) Loop
                 IF p_batch_line_rec.cmplt_date > res_line.scheduled_ship_date THEN
                    GML_BATCH_OM_RES_PVT.notify_CSR
                    (
                       P_batch_id               => p_batch_line_rec.batch_id
                     , P_action_code            => 'CMPLT_DATE_CHANGE'
                     , X_return_status          => x_return_status
                     , X_msg_cont               => l_msg_cont
                     , X_msg_data               => l_msg_data
                    );
                 END IF;
              END LOOP;
           END IF;
        END LOOP;
        return;
     END IF;
  END IF;

  -- Batch line level or trans level actions
  /* get the rule for this batch line */
  l_so_line_rec.so_line_id := null;
  /* always use the whse from the gme trans */
  l_so_line_rec.whse_code := p_gme_trans_row.whse_code;
  GML_BATCH_OM_UTIL.get_rule
        (
           P_so_line_rec            => l_so_line_rec
         , P_batch_line_rec         => p_batch_line_rec
         , X_gme_om_rule_rec        => l_rule_rec
         , X_return_status          => x_return_status
         , X_msg_cont               => l_msg_cont
         , X_msg_data               => l_msg_data
        );
  IF l_rule_rec.order_notification = 'Y' THEN
     l_notify := 1;
  END IF;
  /* based on the p_batch_action code, do the appropriate calls */
  IF p_batch_action = 'COMPLETE' THEN
     /* action at batch side is either ADDC or UPDP with completed_ind = 1
      * We will create OMSO allocations based on the reservations */
     GML_BATCH_OM_RES_PVT.create_allocations
       (
          P_batch_line_rec         => p_batch_line_rec
        , P_gme_om_rule_rec        => l_rule_rec
        , P_Gme_trans_row          => p_gme_trans_row
        , X_return_status          => x_return_status
        , X_msg_cont               => l_msg_cont
        , X_msg_data               => l_msg_data
       );
     /* if rule says so
        pick confirm is done per batch not per trans
        Moved pick confirm to UPDP where UPDP is called from GME per batch consolidation
      */
     g_prod_yielded := 1;
     /* set g_not_to_delete to 1 if convertion is waiting for the lot status */
  END IF;
  IF p_batch_action = 'DELETE' THEN
     /* actions at the batch side could be
      * 1) cancel-terminate batch -- batch level, above
      * 2) reserval batch at the trans level
      */
      GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations...... IF p_batch_action = DELETE');
      IF l_rule_rec.order_notification = 'Y' THEN
        GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....Calling GML_BATCH_OM_RES_PVT.notify_CSR');
        GML_BATCH_OM_RES_PVT.notify_CSR
           (
              P_Batch_trans_id         => p_batch_line_rec.trans_id
            , P_action_code            => 'CANCEL'
            , X_return_status          => x_return_status
            , X_msg_cont               => l_msg_cont
            , X_msg_data               => l_msg_data
           );
      END IF;
      IF p_batch_line_rec.trans_id is not null THEN
        GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....IF p_gme_trans_row.trans_id is not null');
        GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....Calling GML_BATCH_OM_RES_PVT.cancel_alloc_for_trans');
        GML_BATCH_OM_RES_PVT.cancel_alloc_for_trans
           (
              P_Batch_trans_id         => p_batch_line_rec.trans_id
            , X_return_status          => x_return_status
            , X_msg_cont               => l_msg_cont
            , X_msg_data               => l_msg_data
           );
      END IF;
      return;
  END IF;
  IF p_batch_action = 'NOTIFY_CSR' THEN
     /* p_batch_line_rec.trans_id will be passed as the from trans_id
      * p_gme_trans_row.trans_id will be passed as the new (to be updated) trans_id
      */
     IF p_batch_line_rec.trans_id is not null THEN
        GMI_RESERVATION_UTIL.println('Fetch old gme trans '||p_batch_line_rec.trans_id);
        Open get_trans_row(p_batch_line_rec.trans_id);
        Fetch get_trans_row
        Into l_old_gme_trans_row;
        Close get_trans_row;
     END IF;
     /* if p_batch_line_rec.batch_line_id is passed, meaning UPDP at GME
      * 1) planned qty is changed
      * 2) update pending to complete
      */
     IF p_batch_line_rec.batch_line_id is not null THEN
        GMI_RESERVATION_UTIL.println('batch line level');
        /* 1) Reduce planned qty  or any pending transactions change
                  -- no actions for increasing qty
         *    the trans_row would be pending
         */
        IF p_gme_trans_row.trans_id is null THEN -- Pending transactions
           GMI_RESERVATION_UTIL.println('UPDP, pending trans is changed');
           For whse_rec in check_res_whse(p_batch_line_rec.batch_line_id) LOOP
              l_whse_code := whse_rec.whse_code;
              Open get_res_qty(l_batch_line_id, l_whse_code);
              Fetch get_res_qty
              Into l_res_qty, l_res_qty2;
              Close get_res_qty;
              GMI_RESERVATION_UTIL.println('UPDP, total res qty '|| l_res_qty);

              Open get_planned_qty(l_batch_line_id, l_whse_code);
              Fetch get_planned_qty
              Into l_planned_qty, l_planned_qty2;
              Close get_planned_qty;

              GMI_RESERVATION_UTIL.println('UPDP, total planned qty '|| nvl(l_planned_qty,0));
              GMI_RESERVATION_UTIL.println(' global g_not_to_notify '||GML_GME_API_PVT.g_not_to_notify);
              IF (l_res_qty > nvl(l_planned_qty,0) * (1+ l_rule_rec.allocation_tolerance/100))
                  and l_notify = 1
                  and GML_GME_API_PVT.g_not_to_notify <> 1
              THEN
                 /* pending qty has been reduced
                  * check the tolerance
                  */
                 GMI_RESERVATION_UTIL.println('UPDP, planned qty is changed');
                 GMI_RESERVATION_UTIL.println('Process_om_reservations...UPDP Pending Qty is reduced');
                 GMI_RESERVATION_UTIL.println('Process_om_reservations...Pending Qty is reduced Calling GML_BATCH_OM_RES_PVT.notify_CSR');
                 GML_BATCH_OM_RES_PVT.notify_CSR
                 (
                    P_batch_line_id         => p_batch_line_rec.batch_line_id
                  , P_whse_code		     => l_whse_code
                  , P_action_code            => 'REDUCE_PLANNED_QTY'
                  , X_return_status          => x_return_status
                  , X_msg_cont               => l_msg_cont
                  , X_msg_data               => l_msg_data
                 );
                 /* if planned qty becomes 0, delete all the res for this whse */
                 GMI_RESERVATION_UTIL.println(' global g_not_to_delete '||GML_GME_API_PVT.g_not_to_delete);
                 IF (nvl(l_planned_qty,0) <= 0 AND GML_GME_API_PVT.g_not_to_delete = 0) THEN
                    GML_BATCH_OM_RES_PVT.cancel_res_for_batch_line
                    (
                      P_Batch_line_id          => p_batch_line_rec.batch_line_id
                    , P_whse_code              => l_whse_code
                    , X_return_status          => x_return_status
                    , X_msg_cont               => l_msg_cont
                    , X_msg_data               => l_msg_data
                    ) ;
                 END IF;
              END IF;
           END LOOP;
        END IF;
        IF p_gme_trans_row.trans_id is not null
           and l_old_gme_trans_row.completed_ind = 0
           and p_gme_trans_row.completed_ind = 1
        THEN
           GMI_RESERVATION_UTIL.println('UPDP, update pending to complete');
           GML_BATCH_OM_RES_PVT.create_allocations
             (
                P_batch_line_rec         => p_batch_line_rec
              , P_gme_om_rule_rec        => l_rule_rec
              , P_Gme_trans_row          => p_gme_trans_row
              , X_return_status          => x_return_status
              , X_msg_cont               => l_msg_cont
              , X_msg_data               => l_msg_data
             );

           g_prod_yielded := 1;

        END IF;

        GMI_RESERVATION_UTIL.println('    Global value g_prod_yielded  '||g_prod_yielded);
        /* Pick confirm is here after consolidation at GME side */
        IF l_rule_rec.auto_pick_confirm = 'Y' AND g_prod_yielded = 1 THEN
           GMI_RESERVATION_UTIL.println('Product yielded. Now Pickconfirm');
           /* get the mo line id for the source line */
           GML_BATCH_OM_RES_PVT.pick_confirm
           (
              P_batch_line_rec         => p_batch_line_rec
            , P_Gme_trans_row          => p_gme_trans_row
            , X_return_status          => x_return_status
            , X_msg_cont               => l_msg_cont
            , X_msg_data               => l_msg_data
           );
        END IF;
     END IF; -- batch line level
     IF p_batch_line_rec.trans_id is not null
        and p_gme_trans_row.trans_id is not null THEN
        GMI_RESERVATION_UTIL.println('transaction level');
        IF l_old_gme_trans_row.completed_ind = 1
           and l_new_gme_trans_row.completed_ind = 1
        THEN
           GMI_RESERVATION_UTIL.println('UPDC, update the completed transaction');
           /* 1) if qty is increased, new OMSO should be created for the newly added qty
            */
           GMI_RESERVATION_UTIL.println('UPDC, old trans_qty '|| l_old_gme_trans_row.trans_qty);
           GMI_RESERVATION_UTIL.println('UPDC, new trans_qty '|| l_new_gme_trans_row.trans_qty);
           GMI_RESERVATION_UTIL.println('UPDC, old lot_id '|| l_old_gme_trans_row.lot_id);
           GMI_RESERVATION_UTIL.println('UPDC, new lot_id '|| l_new_gme_trans_row.lot_id);
           GMI_RESERVATION_UTIL.println('UPDC, old location '|| l_old_gme_trans_row.location);
           GMI_RESERVATION_UTIL.println('UPDC, new location '|| l_new_gme_trans_row.location);
           GMI_RESERVATION_UTIL.println('UPDC, old whse_code '|| l_old_gme_trans_row.whse_code);
           GMI_RESERVATION_UTIL.println('UPDC, new whse_code '|| l_new_gme_trans_row.whse_code);
           IF abs(l_new_gme_trans_row.trans_qty) > abs(l_old_gme_trans_row.trans_qty) THEN
              GMI_RESERVATION_UTIL.println('   New qty added');
              Open get_total_OMSO(l_old_gme_trans_row.trans_id);
              Fetch get_total_OMSO Into l_trans_qty, l_trans_qty2;
              Close get_total_OMSO;
              GMI_RESERVATION_UTIL.println('      Total OMSO trans_qty '||l_trans_qty);
              GMI_RESERVATION_UTIL.println('      Total OMSO trans_qty2 '||l_trans_qty2);
              l_new_gme_trans_row.trans_qty := -1 * (abs(l_new_gme_trans_row.trans_qty)
                                               - abs(l_trans_qty));
              l_new_gme_trans_row.trans_qty2 := -1 * (abs(l_new_gme_trans_row.trans_qty2)
                                               - abs(l_trans_qty2));
              GML_BATCH_OM_RES_PVT.create_allocations
                (
                   P_batch_line_rec         => p_batch_line_rec
                 , P_gme_om_rule_rec        => l_rule_rec
                 , P_Gme_trans_row          => l_new_gme_trans_row
                 , X_return_status          => x_return_status
                 , X_msg_cont               => l_msg_cont
                 , X_msg_data               => l_msg_data
                );
              /* update history ? */
              /* increasing qty is to create neg orginal qty and create new trans with the new qty*/
              l_update_history := 1;
              g_prod_yielded := 1;

           ELSIF abs(l_new_gme_trans_row.trans_qty) < abs(l_old_gme_trans_row.trans_qty) THEN
              /* qty is reduced, backflash */
              GMI_RESERVATION_UTIL.println(' Process_om_reservations completed batch  qty reduced');
              /* notify CSR */
              l_notify := 1;
              GMI_RESERVATION_UTIL.println(' Process_om_reservations completed batch  qty reduced calling GML_BATCH_OM_RES_PVT.notify_CSR');
              GML_BATCH_OM_RES_PVT.notify_CSR
                 (
                    P_batch_trans_id         => p_batch_line_rec.trans_id
                  , P_action_code            => 'REDUCE_QTY_ON_COMPLETED_BATCH'
                  , X_return_status          => l_return_status
                  , X_msg_cont               => l_msg_cont
                  , X_msg_data               => l_msg_data
                 );

              /* decreasing qty is to create neg orginal qty and create new trans with the new qty*/
              l_update_history := 1;
           END IF;

           /* 2) lot_id is changed
            */
            IF l_new_gme_trans_row.lot_id <> l_old_gme_trans_row.lot_id THEN
              GMI_RESERVATION_UTIL.println('Lot is changed from '|| l_old_gme_trans_row.lot_id);
              GMI_RESERVATION_UTIL.println('                to '|| l_new_gme_trans_row.lot_id);
              For trans_rec in get_trans_id(l_batch_trans_id) LOOP
                 l_trans_id := trans_rec.trans_id;
                 l_tran_rec.trans_id := l_trans_id;
                 IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_tran_rec, l_tran_rec ) THEN
                    l_tran_rec.lot_id := l_new_gme_trans_row.lot_id;
                    GMI_RESERVATION_UTIL.println('       Changing lot_id for trans_id '|| l_trans_id);
                    GMI_TRANS_ENGINE_PUB.update_pending_transaction
                                    (p_api_version      => 1.0,
                                     p_init_msg_list    => FND_API.G_TRUE,
                                     p_commit           => FND_API.G_FALSE,
                                     p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                                     p_tran_rec         => l_tran_rec,
                                     x_tran_row         => l_tran_row,
                                     x_return_status    => x_return_status,
                                     x_msg_count        => l_msg_cont,
                                     x_msg_data         => l_msg_data
                                    );
                    IF x_return_status <> fnd_api.g_ret_sts_success Then
                       GMI_reservation_Util.PrintLn('update complete trans, alloc creation error');
                       FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
                       FND_MESSAGE.Set_Token('WHERE', 'Check rules');
                       FND_MSG_PUB.ADD;
                    END IF;
                    /* no need
                    l_dft_tran_rec.line_id := l_tran_rec.line_id;
                    l_dft_tran_rec.trans_id := null;
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
                    */
                    l_update_history := 1;
                 END IF;
              END LOOP;
              l_notify := 1;
            END IF;
           /* 3) location is changed
            */
            IF l_new_gme_trans_row.location <> l_old_gme_trans_row.location THEN
              GMI_RESERVATION_UTIL.println('Location is changed from '|| l_old_gme_trans_row.location);
              GMI_RESERVATION_UTIL.println('                      to '|| l_new_gme_trans_row.location);
              For trans_rec in get_trans_id(l_batch_trans_id) LOOP
                 l_trans_id := trans_rec.trans_id;
                 l_tran_rec.trans_id := l_trans_id;
                 IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_tran_rec, l_tran_rec ) THEN
                    l_tran_rec.location := l_new_gme_trans_row.location;
                    GMI_RESERVATION_UTIL.println('       Changing location for trans_id '|| l_trans_id);
                    GMI_TRANS_ENGINE_PUB.update_pending_transaction
                                    (p_api_version      => 1.0,
                                     p_init_msg_list    => FND_API.G_TRUE,
                                     p_commit           => FND_API.G_FALSE,
                                     p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                                     p_tran_rec         => l_tran_rec,
                                     x_tran_row         => l_tran_row,
                                     x_return_status    => x_return_status,
                                     x_msg_count        => l_msg_cont,
                                     x_msg_data         => l_msg_data
                                    );
                    IF x_return_status <> fnd_api.g_ret_sts_success Then
                       GMI_reservation_Util.PrintLn('update complete trans, alloc creation error');
                       FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
                       FND_MESSAGE.Set_Token('WHERE', 'Check rules');
                       FND_MSG_PUB.ADD;
                    END IF;
                 END IF;
              END LOOP;
              l_notify := 1;
              l_update_history := 1;
            END IF;
           /* 4) whse_code is changed
            */
            IF l_new_gme_trans_row.whse_code <> l_old_gme_trans_row.whse_code THEN
              GMI_RESERVATION_UTIL.println('Process_Om_reservations .....Whse is Changed');
              GMI_RESERVATION_UTIL.println('Process_Om_reservations .....Completed batch tran is deleted');
              GMI_RESERVATION_UTIL.println('Process_Om_reservations .........Before  deleting OMSO trans');
              GMI_RESERVATION_UTIL.println('Process_om_Reservations.... First Notify CSR');
              l_notify := 1;
              /* Send a notification */
               GML_BATCH_OM_RES_PVT.notify_CSR
                 (
                    P_batch_trans_id         => l_batch_trans_id
                  , P_action_code            => 'WHSE_CHANGED'
                  , X_return_status          => x_return_status
                  , X_msg_cont               => l_msg_cont
                  , X_msg_data               => l_msg_data
                 );

              GMI_RESERVATION_UTIL.println(' Deleting OMSO trans');
              GML_BATCH_OM_RES_PVT.cancel_alloc_for_trans
                 (
                      P_Batch_trans_id         => l_batch_trans_id
                    , X_return_status          => X_return_status
                    , X_msg_cont               => l_msg_cont
                    , X_msg_data               => l_msg_data
                 );

              /* we don't change the history because old trans are deleted and still
               * linked with the old gme trans */
            END IF;

           /* 5) trans_date is changed
            * check the scheduled ship date, if over, notify
            */

           /* balance the default lot */
           /* notify the CSR */
           /*
           IF l_notify = 1 THEN
              GMI_RESERVATION_UTIL.println('Notifications to CSR    ');
              GML_BATCH_OM_RES_PVT.notify_CSR
              (
                 P_batch_trans_id         => p_batch_line_rec.trans_id
               , X_return_status          => x_return_status
               , X_msg_cont               => l_msg_cont
               , X_msg_data               => l_msg_data
           );
           END IF;
           */
           /* the old trans is deleted and replaced by the new trans
            * need to update the history table to keep the link alive
            */
           /* just do the update */
           /* update gml_batch_so_alloc_history
           Set batch_trans_id = l_new_gme_trans_row.trans_id
           Where  batch_trans_id = l_old_gme_trans_row.trans_id
              and nvl(trans_id,0) <> 0
              and delete_mark = 0
           ;
           */
           -- insert new record with new info
           IF l_update_history = 1 THEN
              for his_rec in get_history_id (l_old_gme_trans_row.trans_id) LOOP
                 /* delete the old history record  */
                 update gml_batch_so_alloc_history
                 Set delete_mark = 1
                 Where  alloc_rec_id = his_rec.alloc_rec_id
                 ;
                 GMI_RESERVATION_UTIL.println('      delete history.alloc_rec_id '||his_rec.alloc_rec_id);
                 GMI_RESERVATION_UTIL.println('             old batch_trans_id '||l_old_gme_trans_row.trans_id);
                 l_history_rec.alloc_rec_id := his_rec.alloc_rec_id;
                 GML_BATCH_OM_UTIL.query_alloc_history
                 (
                   P_alloc_history_rec      => l_history_rec
                 , X_return_status          => x_return_status
                 , X_msg_cont               => l_msg_cont
                 , X_msg_data               => l_msg_data
                 ) ;
                 GMI_RESERVATION_UTIL.println('      new history.batch_trans_id '||l_history_rec.batch_trans_id);
                 l_history_rec.alloc_rec_id := null;
                 l_history_rec.batch_trans_id := l_new_gme_trans_row.trans_id;
                 l_history_rec.location := l_new_gme_trans_row.location;
                 l_history_rec.lot_id   := l_new_gme_trans_row.lot_id;
                 GMI_RESERVATION_UTIL.println('          for batch_res_id '||l_history_rec.batch_res_id);
                 GML_BATCH_OM_UTIL.insert_alloc_history
                     (
                          P_alloc_history_rec      => l_history_rec
                        , X_return_status          => x_return_status
                        , X_msg_cont               => l_msg_cont
                        , X_msg_data               => l_msg_data
                     );
              END LOOP;
           END IF;
        END IF;  -- UPDC changed trans is still a complted trans
        IF l_old_gme_trans_row.completed_ind = 1
           and l_new_gme_trans_row.completed_ind = 0
        THEN
           /* uncomplete the completed trans */
           GMI_RESERVATION_UTIL.println('UPDP, update complete to pending');
           GML_BATCH_OM_RES_PVT.cancel_alloc_for_trans
                 (
                      P_Batch_trans_id         => l_old_gme_trans_row.trans_id
                    , X_return_status          => X_return_status
                    , X_msg_cont               => l_msg_cont
                    , X_msg_data               => l_msg_data
                 );
           IF l_rule_rec.order_notification = 'Y' THEN
             GMI_RESERVATION_UTIL.PrintLn(' In Process_om_reservations....Canceling the PROD transaction');
             GML_BATCH_OM_RES_PVT.notify_CSR
                (
                   P_Batch_trans_id         => p_batch_line_rec.trans_id
                 , P_action_code            => 'CANCEL'
                 , X_return_status          => x_return_status
                 , X_msg_cont               => l_msg_cont
                 , X_msg_data               => l_msg_data
                );
           END IF;
        END IF; -- update complted to pending
     END IF; -- trans level
  END IF;

 END process_om_reservations;

END GML_GME_API_PVT;

/

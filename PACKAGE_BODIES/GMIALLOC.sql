--------------------------------------------------------
--  DDL for Package Body GMIALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIALLOC" AS
-- $Header: gmialocb.pls 115.6 2004/03/18 21:46:39 jsrivast noship $

/* ========================================================
   This package is only for the use of Inventory module
   and will be used for validating/updating the pending
   transactions which will be drawing from the inventory when
   there is a mass move immediate or move immediate.
   Jalaj Srivastava Bug 3282770
     Modified signatures of procedures update_pending_allocations
     and CHECK_ALLOC_QTY.
     Added procedure VALIDATE_MOVEALLOC_FORMASSMOVE.
   ======================================================== */


/* ==================================================================
   Procedure: update_pending_allocations

   Description: This procedure is used for updating the pending
                transactions in the ic_tran_pnd table which will
                be drawing from the inventory when there is a
                mass move immediate or move immediate.
                Pending txn are those txns where the delete_mark
                is 0 and completed_ind is 0 and the txn is not the
                default txn. This procedure updates only those txns
                where trans_qty is negative.
                For lot controlled items default txn have a lot_id
                0 and location as default location.

   History  Jalaj Srivastava Bug 2024229
             1. we are concerned only with lot controlled items
             2. we never update OM txns
             3. if we cannot move allocations then we error out (done
                from the form)
            Jalaj Srivastava Bug 2519568
	    ic_summ_inv is now a view.
	    Removed all updates to ic_summ_inv from this procedure.
            Jalaj Srivastava Bug 3282770
              Modified signature to follow api standards.
              Added proper error handling.
              Reorganized the logic/code.
              Allow OMSO allocations to be moved.
   ================================================================== */
/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMIALLOC';

procedure update_pending_allocations
  ( p_api_version          IN               NUMBER
   ,p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT NOCOPY       VARCHAR2
   ,x_msg_count            OUT NOCOPY       NUMBER
   ,x_msg_data             OUT NOCOPY       VARCHAR2
   ,pdoc_id                IN               NUMBER
   ,pto_whse_code          IN               VARCHAR2
   ,pto_location           IN               VARCHAR2
  )
AS
  l_api_name           CONSTANT VARCHAR2(30)   := 'UPDATE_PENDING_ALLOCATIONS' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;

  /*===============Variable Declarations==================================*/
  Cursor Cur_get_trans_cmp is
    select whse_code, location,lot_id,item_id
    from   ic_tran_cmp
    where  doc_type  = 'TRNI'
    and    doc_id    = pdoc_id
    and    line_type = -1
    and    lot_id    > 0;

  Cursor Cur_get_trans_pnd(pcur_get_trans_cmp Cur_get_trans_cmp%ROWTYPE) is
    select trans_id,item_id,lot_id,whse_code,location,qc_grade,trans_qty,
           trans_qty2,doc_type,doc_id,line_id
    from   ic_tran_pnd
    where  item_id       = pcur_get_trans_cmp.item_id
    and    lot_id        = pcur_get_trans_cmp.lot_id
    and    whse_code     = pcur_get_trans_cmp.whse_code
    and    location      = pcur_get_trans_cmp.location
    and    doc_type NOT IN ('PROD','OPSO','OMSO')
    and    delete_mark   = 0
    and    completed_ind = 0
    and    trans_qty     < 0
    UNION ALL
    select trans_id,pnd.item_id,lot_id,whse_code,location,qc_grade,trans_qty,
           trans_qty2,doc_type,doc_id,pnd.line_id
    from   ic_tran_pnd pnd , pm_matl_dtl matl
    where  pnd.item_id       = pcur_get_trans_cmp.item_id
    and    pnd.lot_id        = pcur_get_trans_cmp.lot_id
    and    pnd.whse_code     = pcur_get_trans_cmp.whse_code
    and    pnd.location      = pcur_get_trans_cmp.location
    and    pnd.doc_type      = 'PROD'
    and    pnd.delete_mark   = 0
    and    pnd.completed_ind = 0
    and    pnd.trans_qty     < 0
    and    matl.batch_id     = pnd.doc_id
    and    matl.line_id      = pnd.line_id
    and    matl.phantom_id   IS NULL
    UNION ALL
    select trans_id,pnd.item_id,lot_id,whse_code,location,qc_grade,trans_qty,
    trans_qty2,doc_type,doc_id,pnd.line_id
    from   ic_tran_pnd pnd, op_ordr_dtl ordr, op_hold_cds hold
    where  pnd.item_id        = pcur_get_trans_cmp.item_id
    and    pnd.lot_id         = pcur_get_trans_cmp.lot_id
    and    pnd.whse_code      = pcur_get_trans_cmp.whse_code
    and    pnd.location       = pcur_get_trans_cmp.location
    and    pnd.doc_type       = 'OPSO'
    and    pnd.delete_mark    = 0
    and    pnd.completed_ind  = 0
    and    pnd.trans_qty      < 0
    and    ordr.line_id       = pnd.line_id
    and    ordr.order_id      = pnd.doc_id
    and    ordr.delete_mark   = 0
    and    hold.holdreas_code = ordr.holdreas_code
    and    hold.invcommit_ind = 0
    and    hold.delete_mark   = 0
    and    (     (not exists (select 1
                              from op_cust_itm
                              where cust_id           = ordr.shipcust_id
                              and   item_id           = pcur_get_trans_cmp.item_id
                              and   whse_restrictions = 1
                              and   delete_mark       = 0
                             )
                 )
             OR  (exists     (select 1
                              from  op_cust_itm
                              where cust_id           = ordr.shipcust_id
                              and   item_id           = pcur_get_trans_cmp.item_id
                              and   whse_restrictions = 1
                              and   whse_code         = pto_whse_code
                              and   delete_mark       = 0
                             )
                 )
           )
    UNION ALL
    select trans_id,item_id,lot_id,whse_code,location,qc_grade,trans_qty,
           trans_qty2,doc_type,doc_id,line_id
    from   ic_tran_pnd
    where  item_id       = pcur_get_trans_cmp.item_id
    and    lot_id        = pcur_get_trans_cmp.lot_id
    and    whse_code     = pcur_get_trans_cmp.whse_code
    and    location      = pcur_get_trans_cmp.location
    and    doc_type      ='OMSO'
    and    delete_mark   = 0
    and    completed_ind = 0
    and    trans_qty     < 0
    and    staged_ind    = 0
    and    whse_code     = pto_whse_code;

  orderid NUMBER;
  UPDATE_OP_ORDR_DTL VARCHAR2(1);
  l_user_id NUMBER    := FND_GLOBAL.user_id;

/*====================End of Variable Declarations==============================*/
BEGIN
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
  SAVEPOINT update_pending_allocations;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  --start of update of pending allocations
  --first loop to get the move txns
  FOR Cur_get_trans_cmp_rec in Cur_get_trans_cmp LOOP
    --second loop for matching record from ic_tran_pnd which need to be updated
    FOR Cur_get_trans_pnd_rec in Cur_get_trans_pnd(Cur_get_trans_cmp_rec) LOOP
      --{
      IF (Cur_get_trans_pnd_rec.doc_type = 'OPSO') THEN
        --{
        IF (Cur_get_trans_cmp_rec.whse_code <> pto_whse_code) THEN
          --{
          BEGIN
            select order_id
            into   orderid
            from   op_ordr_hdr
            where  order_id       = Cur_get_trans_pnd_rec.doc_id
            and    delete_mark    = 0
            FOR UPDATE NOWAIT;

            UPDATE_OP_ORDR_DTL := 'Y';
          EXCEPTION
            WHEN OTHERS THEN
              UPDATE_OP_ORDR_DTL := 'N';
          END;--}
        END IF;--}
      END IF;--}
      --{
      IF (     (Cur_get_trans_pnd_rec.doc_type <> 'OPSO')
           OR  (    (Cur_get_trans_pnd_rec.doc_type = 'OPSO')
                AND (    (Cur_get_trans_cmp_rec.whse_code = pto_whse_code)
                      OR (UPDATE_OP_ORDR_DTL = 'Y')
                    )
               )
         ) THEN

        UPDATE IC_TRAN_PND
        SET WHSE_CODE        = pto_whse_code,
            LOCATION         = pto_location,
            LAST_UPDATED_BY  = l_user_id,
            LAST_UPDATE_DATE = SYSDATE
        WHERE   trans_id = Cur_get_trans_pnd_rec.trans_id;
      END IF;--}
      --{
      IF (     (Cur_get_trans_pnd_rec.doc_type = 'OPSO')
           AND (Cur_get_trans_cmp_rec.whse_code <> pto_whse_code)
           AND (UPDATE_OP_ORDR_DTL = 'Y')
         ) THEN

        UPDATE OP_ORDR_DTL
        SET    FROM_WHSE        = pto_whse_code,
               LAST_UPDATED_BY  = l_user_id,
               LAST_UPDATE_DATE = SYSDATE
        WHERE line_id        = Cur_get_trans_pnd_rec.line_id
        and   order_id       = Cur_get_trans_pnd_rec.doc_id
        and   delete_mark    = 0;

      END IF;--}
      --{
      IF (     (Cur_get_trans_pnd_rec.doc_type = 'XFER')
           AND (Cur_get_trans_cmp_rec.whse_code <> pto_whse_code)
         ) THEN

        UPDATE IC_XFER_MST
        SET    FROM_WAREHOUSE   = pto_whse_code,
               FROM_LOCATION    = pto_location,
               LAST_UPDATED_BY  = l_user_id,
               LAST_UPDATE_DATE = SYSDATE
        WHERE transfer_id = Cur_get_trans_pnd_rec.doc_id;
      END IF;--}

    END LOOP;

  END LOOP;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_AND_GET
    (p_count => x_msg_count, p_data  => x_msg_data);

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to update_pending_allocations;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to update_pending_allocations;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to update_pending_allocations;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


END UPDATE_PENDING_ALLOCATIONS;

/* =======================================================================
   Procedure: check_alloc_qty

   Description: This procedure is used for validating
                moving allocations for move immediate.
                Pending txn are those txns where the delete_mark
                is 0 and completed_ind is 0 and the txn is not the
                default txn.
                For lot controlled items default txn have a lot_id
                0 and location as default location.

                This procedure considers only actual onhand qty, move quantity
                and the total allocations qty( where trans_qty <0). It
                does not look at pending transactions which are going to
                add to the inventory.

                If move qty <= (onhand qty - total allocations qty) then
                   returns 0
                   no need to update allocations

                If move qty > (onhand qty - total allocations qty) and
                   move qty >= total allocations qty
                   returns 1
                   allocations need to be updated

                If move qty > (onhand qty - total allocations qty) and
                   move qty < total allocations qty
                   returns -1
                   allocations need to be but cannot be updated

   History  Jalaj Srivastava Bug 2024229
             1. we are concerned only with lot controlled items
             2. we never update OM txns
             3. if we cannot move allocations then we error out (done
                from the form)
            Jalaj Srivastava Bug 3282770
              Modified signature to follow api standards.
              Added proper error handling.
              Reorganized the logic/code.
              If OMSO allocations exist then moving allcoations not allowed
              if the move is to a different warehouse.
              If any pick confirmed OMSO allocations exist then moving
              allcoations not allowed
   ======================================================================== */


PROCEDURE CHECK_ALLOC_QTY
  ( p_api_version          IN               NUMBER
   ,p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT NOCOPY       VARCHAR2
   ,x_msg_count            OUT NOCOPY       NUMBER
   ,x_msg_data             OUT NOCOPY       VARCHAR2
   ,pfrom_whse_code        IN               VARCHAR2
   ,pfrom_location         IN               VARCHAR2
   ,plot_id                IN               NUMBER
   ,pitem_id               IN               NUMBER
   ,pmove_qty              IN               NUMBER
   ,pto_whse_code          IN               VARCHAR2
   ,x_move_allocations     OUT NOCOPY       VARCHAR2
  )
  AS

  l_api_name           CONSTANT VARCHAR2(30)   := 'CHECK_ALLOC_QTY' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  onhandqty NUMBER := 0;
  allocqty  NUMBER := 0;
  tempqty   NUMBER := 0;
  OMSO_txn_count NUMBER := 0;
  OMSO_pick_confirmed_txn_count NUMBER := 0;

BEGIN
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  /* Get onhand */
  select NVL(sum(nvl(loct_onhand,0)),0)
  into   onhandqty
  from   ic_loct_inv
  where  item_id   = pitem_id
  and    lot_id    = plot_id
  and    whse_code = pfrom_whse_code
  and    location  = pfrom_location;

  /* Get allocated quantity for transactions other than PROD and OPSO */
  select nvl(abs(sum(nvl(trans_qty,0))),0)
  into   tempqty
  from   ic_tran_pnd
  where  item_id       = pitem_id
  and    lot_id        = plot_id
  and    whse_code     = pfrom_whse_code
  and    location      = pfrom_location
  and    doc_type NOT IN ('PROD','OPSO')
  and    delete_mark   = 0
  and    completed_ind = 0
  and    trans_qty     < 0;

  allocqty :=tempqty;

  /* Get allocated quantity for PROD transactions */
  select nvl(abs(sum(nvl(trans_qty,0))),0)
  into   tempqty
  from   ic_tran_pnd itp, pm_matl_dtl pmd
  where  itp.item_id   = pitem_id
  and    itp.lot_id    = plot_id
  and    itp.whse_code = pfrom_whse_code
  and    itp.location  = pfrom_location
  and    itp.doc_type  ='PROD'
  and    itp.delete_mark = 0
  and    itp.completed_ind = 0
  and    itp.trans_qty     < 0
  and    pmd.batch_id = itp.doc_id
  and    pmd.line_id  = itp.line_id
  and    pmd.phantom_id IS NULL;

  allocqty := allocqty + tempqty;

  /* Get allocated quantity for OPSO transactions */
  select nvl(abs(sum(nvl(trans_qty,0))),0)
  into   tempqty
  from   ic_tran_pnd itp, op_ordr_dtl ood, op_hold_cds ohc
  where itp.item_id       = pitem_id
  and   itp.lot_id        = plot_id
  and   itp.whse_code     = pfrom_whse_code
  and   itp.location      = pfrom_location
  and   itp.doc_type      ='OPSO'
  and   itp.delete_mark   = 0
  and   itp.completed_ind = 0
  and   itp.trans_qty     < 0
  and   ood.line_id       = itp.line_id
  and   ood.order_id      = itp.doc_id
  and   ood.delete_mark   = 0
  and   ohc.holdreas_code = ood.holdreas_code
  and   ohc.invcommit_ind = 0
  and   ohc.delete_mark   = 0;

  allocqty := allocqty + tempqty;

  --{
  IF  ( (allocqty > 0) and (pmove_qty >(onhandqty - allocqty)) ) THEN
      --{
      IF (pmove_qty >= allocqty) THEN

        select count(1)
        into   OMSO_txn_count
        from   ic_tran_pnd pnd
        where  pnd.item_id       = pitem_id
        and    pnd.lot_id        = plot_id
        and    pnd.whse_code     = pfrom_whse_code
        and    pnd.location      = pfrom_location
        and    pnd.doc_type      ='OMSO'
        and    pnd.delete_mark   = 0
        and    pnd.completed_ind = 0
        and    pnd.trans_qty     < 0;

        --{
        IF (OMSO_txn_count > 0) THEN
          /* *****************************************************************
             check if OMSO txns exist
             if they exist and the move is to a different warehouse then
             we cannot move allocations
             ***************************************************************** */
          --{
          IF (pfrom_whse_code <> pto_whse_code) THEN

            FND_MESSAGE.SET_NAME('GMI','GMI_MOVE_TO_DIFF_WHSE');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;--}
          /* *****************************************************************
             check if OMSO txns exist
             if they exist and any OMSO allocation is pick confirmed then the
             allocations cannot be moved.
             ***************************************************************** */
          select count(1)
          into   OMSO_pick_confirmed_txn_count
          from   ic_tran_pnd pnd
          where  pnd.item_id   = pitem_id
          and    pnd.lot_id        = plot_id
          and    pnd.whse_code     = pfrom_whse_code
          and    pnd.location      = pfrom_location
          and    pnd.doc_type      ='OMSO'
          and    pnd.delete_mark   = 0
          and    pnd.completed_ind = 0
          and    pnd.trans_qty     < 0
          and    pnd.staged_ind    = 1;
          --{
          IF (OMSO_pick_confirmed_txn_count > 0) THEN
            FND_MESSAGE.SET_NAME('GMI','GMI_PICK_CNFRMD_ALLOC_EXISTS');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;--}

        END IF;--}
          --allocations can be moved.
        x_move_allocations := 'Y';
      ELSE
        FND_MESSAGE.SET_NAME('GMI','GMI_UNABLE_TO_MOVE_ALLOCATIONS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;--}
  ELSE
    --no need to move allocations
    x_move_allocations := 'N'; /* move qty is less than or equal to unallocated qty */
  END IF;--}

  FND_MSG_PUB.Count_AND_GET
  (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END CHECK_ALLOC_QTY;

/* =======================================================================
   Procedure: VALIDATE_MOVEALLOC_FORMASSMOVE

   Description: This procedure is used to validate moving allocations
                when there is a mass move immediate.
                Allocations are those txns where the delete_mark
                is 0 and completed_ind is 0 and the txn is not the
                default txn.
                For lot controlled items default txn have a lot_id
                0 and location as default location.
                This procedure considers only actual onhand qty, move quantity
                and the total allocations qty( where trans_qty <0). It
                does not look at pending transactions which are going to
                add to the inventory.

                If move qty <= (onhand qty - total allocations qty) then
                   returns 0
                   no need to update allocations

                If move qty > (onhand qty - total allocations qty) and
                   move qty >= total allocations qty
                   returns 1
                   allocations need to be updated

                If move qty > (onhand qty - total allocations qty) and
                   move qty < total allocations qty
                   returns -1
                   allocations need to be but cannot be updated

            Jalaj Srivastava Bug 3282770
              Added this procedure.
              If OMSO allocations exist then moving allcoations not allowed
              if the move is to a different warehouse.
              If any pick confirmed OMSO allocations exist then moving
              allcoations not allowed
   ======================================================================== */


PROCEDURE VALIDATE_MOVEALLOC_FORMASSMOVE
  ( p_api_version          IN               NUMBER
   ,p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT NOCOPY       VARCHAR2
   ,x_msg_count            OUT NOCOPY       NUMBER
   ,x_msg_data             OUT NOCOPY       VARCHAR2
   ,pfrom_whse_code        IN               VARCHAR2
   ,pto_whse_code          IN               VARCHAR2
   ,pjournal_id            IN               NUMBER
  )
  AS

  l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_MOVEALLOC_FORMASSMOVE' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  OMSO_txn_count NUMBER := 0;
  OMSO_pick_confirmed_txn_count NUMBER := 0;

BEGIN
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

        SELECT count(1)
        INTO   OMSO_txn_count
        FROM   ic_tran_pnd pnd, ic_adjs_jnl jnl
        WHERE  jnl.journal_id    = pjournal_id
        AND    jnl.line_type     = -1
        AND    jnl.lot_id        > 0
        AND    pnd.item_id       = jnl.item_id
        AND    pnd.lot_id        = jnl.lot_id
        AND    pnd.whse_code     = jnl.whse_code
        AND    pnd.location      = jnl.location
        AND    pnd.doc_type      = 'OMSO'
        AND    pnd.delete_mark   = 0
        AND    pnd.completed_ind = 0
        AND    pnd.trans_qty     < 0;

        --{
        IF (OMSO_txn_count > 0) THEN
          /* *****************************************************************
             check if OMSO txns exist
             if they exist and the move is to a different warehouse then
             we cannot move allocations
             ***************************************************************** */
          --{
          IF (pfrom_whse_code <> pto_whse_code) THEN

            FND_MESSAGE.SET_NAME('GMI','GMI_MOVE_TO_DIFF_WHSE');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;--}
          /* *****************************************************************
             check if OMSO txns exist
             if they exist and any OMSO allocation is pick confirmed then the
             allocations cannot be moved.
             ***************************************************************** */
          select count(1)
          into   OMSO_pick_confirmed_txn_count
          FROM   ic_tran_pnd pnd, ic_adjs_jnl jnl
          WHERE  jnl.journal_id    = pjournal_id
          AND    jnl.line_type     = -1
          AND    jnl.lot_id        > 0
          AND    pnd.item_id       = jnl.item_id
          AND    pnd.lot_id        = jnl.lot_id
          AND    pnd.whse_code     = jnl.whse_code
          AND    pnd.location      = jnl.location
          AND    pnd.doc_type      = 'OMSO'
          AND    pnd.delete_mark   = 0
          AND    pnd.completed_ind = 0
          AND    pnd.trans_qty     < 0
          AND    pnd.staged_ind    = 1;
          --{
          IF (OMSO_pick_confirmed_txn_count > 0) THEN
            FND_MESSAGE.SET_NAME('GMI','GMI_PICK_CNFRMD_ALLOC_EXISTS');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;--}

        END IF;--}

  FND_MSG_PUB.Count_AND_GET
  (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END VALIDATE_MOVEALLOC_FORMASSMOVE;

END GMIALLOC;


/

--------------------------------------------------------
--  DDL for Package Body GML_INTORD_LOT_STS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_INTORD_LOT_STS" AS
/* $Header: GMLIOLSB.pls 115.1 2004/01/20 16:30:41 pbamb noship $*/


-----------------------------------------------------------------------------
-- Define private package constants.
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- Declare private package variables.
-----------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Forward procedure declarations
--------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_porc_lot_status
--Pre-reqs:
-- None
--Modifies:
-- None
--Locks:
-- None.
--Function:
-- This procedure returns the lot status which is used for creating PORC
-- transactions.
--Parameters:
--  Otherwise, include the IN:, IN OUT:, and/or OUT: sections as needed.
--IN:
-- p_item_id
--  item id
-- p_whse_code
--  receiving warehouse
-- p_lot_id
--  items Lot id
-- p_location
--  receiving warehouse location
-- p_ship_lot_status
--  shipped lot status
--IN OUT:
--  x_rcpt_lot_status
--  receipt lot status
--OUT:
-- x_txn_allowed
--  whether transaction is allowed, Y or N
-- x_return_status
--  return status of the procedure
-- x_msg_data
--  message returned from procedure
--Notes:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE derive_porc_lot_status
 (  p_item_id                 IN            NUMBER
 ,  p_whse_code               IN            VARCHAR2
 ,  p_lot_id                  IN            NUMBER
 ,  p_location                IN            VARCHAR2
 ,  p_ship_lot_status         IN            VARCHAR2
 ,  x_rcpt_lot_status         IN OUT NOCOPY VARCHAR2
 ,  x_txn_allowed                OUT NOCOPY VARCHAR2
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  x_msg_data                   OUT NOCOPY VARCHAR2
 ) IS

  -- declare cursor to fetch ic_loct_inv lot status and onhand qty
  CURSOR get_inv_sts_qty IS
  SELECT loct_onhand, lot_status
  FROM   ic_loct_inv
  WHERE  item_id   = p_item_id
  AND    whse_code = p_whse_code
  AND    lot_id    = p_lot_id
  AND    location  = p_location;

  l_onhand_lot_qty     NUMBER          := 0;
  l_onhand_lot_status  VARCHAR2(4);
  l_return_status      VARCHAR2(1);
  l_msg_data           VARCHAR2(1000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_ship_lot_status IS NULL THEN
     x_msg_data        := 'null p_ship_lot_status passed to proc derive_porc_lot_status';
     x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
     x_txn_allowed     := 'N';
     x_rcpt_lot_status := NULL;
     RETURN;
  END IF;


  -- fetch the inv lot status and onhand qty
  OPEN  get_inv_sts_qty;
  FETCH get_inv_sts_qty INTO l_onhand_lot_qty,l_onhand_lot_status;
  -- it is a new lot or inventory does not exist
  IF get_inv_sts_qty%NOTFOUND THEN
     l_onhand_lot_status := NULL;
     l_onhand_lot_qty    := NULL;
  END IF;
  CLOSE get_inv_sts_qty;

  /* if it is a new lot or inventory does not exist
  ,  allow the transaction irrespective of move_diff_sts  */
  IF (l_onhand_lot_qty IS NULL AND l_onhand_lot_status IS NULL) THEN
     x_txn_allowed     := 'Y';
     x_rcpt_lot_status := p_ship_lot_status;
     RETURN;
  END IF;

  -- it is an existing lot and move_diff_sts = 0
  IF GML_INTORD_LOT_STS.G_move_diff_stat = 0 THEN
     IF (l_onhand_lot_qty >= 0 AND p_ship_lot_status <> l_onhand_lot_status) THEN
        x_txn_allowed     := 'N';
        x_rcpt_lot_status := NULL;
        RETURN;
     ELSIF (p_ship_lot_status = l_onhand_lot_status) THEN
        x_txn_allowed     := 'Y';
        x_rcpt_lot_status := p_ship_lot_status;
        RETURN;
     END IF;
  END IF;

  /* it is an existing lot and move_diff_sts = 1
     allow the transaction irrespective of onhand qty  */
  IF GML_INTORD_LOT_STS.G_move_diff_stat = 1 THEN
     x_txn_allowed     := 'Y';
     x_rcpt_lot_status := l_onhand_lot_status;
     RETURN;
  END IF;

  -- it is an existing lot and move_diff_sts = 2
  IF GML_INTORD_LOT_STS.G_move_diff_stat = 2 THEN
     IF (p_ship_lot_status = l_onhand_lot_status) THEN
        x_txn_allowed     := 'Y';
        x_rcpt_lot_status := p_ship_lot_status;
        RETURN;
     ELSIF (l_onhand_lot_qty <> 0 AND p_ship_lot_status <> l_onhand_lot_status) THEN
        x_txn_allowed     := 'N';
        x_rcpt_lot_status := NULL;
        RETURN;
     ELSIF (l_onhand_lot_qty = 0 AND p_ship_lot_status <> l_onhand_lot_status) THEN
        x_txn_allowed     := 'Y';
        x_rcpt_lot_status := p_ship_lot_status;
        -- change the onhand_lot_status status to ship_lot_status in ic_lot_inv
        GML_INTORD_LOT_STS.change_inv_lot_status(  p_item_id       =>  p_item_id
                                               , p_whse_code     =>  p_whse_code
                                               , p_lot_id        =>  p_lot_id
                                               , p_location      =>  p_location
                                               , p_to_status     =>  p_ship_lot_status
                                               , x_return_status =>  l_return_status
                                               , x_msg_data      =>  l_msg_data );
                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      x_msg_data        := l_msg_data;
                      x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
                      x_txn_allowed     := 'N';
                      x_rcpt_lot_status := NULL;
                   END IF;
        RETURN;
     END IF;
  END IF;


EXCEPTION
    WHEN OTHERS THEN
       x_msg_data        := 'derive_porc_lot_status failed unexpected error';
       x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
       x_txn_allowed     := 'N';
       x_rcpt_lot_status := NULL;

END derive_porc_lot_status;

-------------------------------------------------------------------------------
--Start of Comments
--Name: change_inv_lot_status
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- This procedure ic called for changing the onhand lot status.
--
--Parameters:
--  Otherwise, include the IN:, IN OUT:, and/or OUT: sections as needed.
--IN:
-- p_item_id
--  item id
-- p_whse_code
--  ic_loct_inv whse
-- p_lot_id
--  items Lot id
-- p_location
--  ic_loct_inv location
-- p_to_status
--  status to which the ic_loct_inv needs to be changed.
--IN OUT:
--
--OUT:
-- x_return_status
--  return status of the procedure
-- x_msg_data
--  message returned from procedure
--Notes:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE change_inv_lot_status
 (  p_item_id                 IN            NUMBER
 ,  p_whse_code               IN            VARCHAR2
 ,  p_lot_id                  IN            NUMBER
 ,  p_location                IN            VARCHAR2
 ,  p_to_status               IN            VARCHAR2
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  x_msg_data                   OUT NOCOPY VARCHAR2
 ) IS

l_item_rec              IC_ITEM_MST%ROWTYPE;
l_trans_rec             GMIGAPI.qty_rec_typ;
l_ic_jrnl_mst_row       ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_row1      ic_adjs_jnl%ROWTYPE;
l_ic_adjs_jnl_row2      ic_adjs_jnl%ROWTYPE;
l_status                VARCHAR2(1);
l_count                 NUMBER;
l_data                  VARCHAR2(1000);
l_count_msg             NUMBER;
l_dummy_cnt             NUMBER  := 0;
l_reason_code_security  VARCHAR2(1) := 'N';

l_message_data          VARCHAR2(2000);

CURSOR lot_details IS
SELECT lot_no, sublot_no
FROM   ic_lots_mst
WHERE  lot_id = p_lot_id;

l_lot_details lot_details%ROWTYPE;

CURSOR Get_Reason_Code IS
SELECT reason_code
FROM   sy_reas_cds
WHERE  delete_mark = 0
AND    (l_reason_code_security = 'Y')
AND    (reason_code in (select reason_code from gma_reason_code_security
        where (doc_type = 'PORC' or doc_type IS NULL) and
        (responsibility_id = FND_GLOBAL.RESP_id or responsibility_id IS NULL)))
UNION ALL
SELECT  reason_code
FROM    sy_reas_cds
WHERE   delete_mark = 0;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT  *
  INTO    l_item_rec
  FROM    ic_item_mst
  WHERE   item_id     = p_item_id;

  IF l_item_rec.status_ctl = 0 THEN
     x_msg_data      := 'Item is not status controlled';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RETURN;
  END IF;

  SELECT s.co_code, w.orgn_code
  INTO   l_trans_rec.co_code, l_trans_rec.orgn_code
  FROM   ic_whse_mst w, sy_orgn_mst s
  WHERE  w.whse_code = p_whse_code
  AND    w.orgn_code = s.orgn_code;

  OPEN  lot_details;
  FETCH lot_details INTO l_lot_details;
  CLOSE lot_details;

  l_trans_rec.trans_type      := 4;
  l_trans_rec.trans_date      := SYSDATE;
  l_trans_rec.item_no         := l_item_rec.item_no;
  l_trans_rec.lot_no          := l_lot_details.lot_no;
  l_trans_rec.sublot_no       := l_lot_details.sublot_no;
  l_trans_rec.from_whse_code  := p_whse_code;
  l_trans_rec.from_location   := p_location;
  l_trans_rec.lot_status      := p_to_status;

  l_reason_code_security := nvl(fnd_profile.value('GMA_REASON_CODE_SECURITY'), 'N');
  OPEN  Get_Reason_Code;
  FETCH Get_Reason_Code into l_trans_rec.reason_code;
  IF Get_Reason_Code%NOTFOUND THEN
     CLOSE Get_Reason_Code;

    BEGIN
      UPDATE IC_LOCT_INV
      SET    lot_status = p_to_status
      WHERE  item_id    = p_item_id
      AND    whse_code  = p_whse_code
      AND    location   = p_location
      AND    lot_id     = p_lot_id;

    EXCEPTION WHEN OTHERS THEN
      x_msg_data      := 'Error updating the status in ic_loct_inv';
      x_return_status := FND_API.G_RET_STS_ERROR;
    END;
    RETURN;

    IF Get_Reason_Code%ISOPEN THEN
       CLOSE Get_Reason_Code;
    END IF;
  END IF; /* IF Get_Reason_Code%NOTFOUND */

  l_trans_rec.trans_qty := NULL;
  l_trans_rec.user_name := FND_GLOBAL.USER_NAME;

  -- Set the context for the GMI APIs
     IF( NOT Gmigutl.Setup(l_trans_rec.user_name) ) THEN
      x_msg_data      := 'Error during Gmigutl.Setup';
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
     END IF;

  -- Call the standard API and check the return status
     BEGIN
        Gmipapi.Inventory_Posting
                ( p_api_version         => 3.0
                , p_init_msg_list       => 'T'
                , p_commit              => 'F'
                , p_validation_level    => 100
                , p_qty_rec             => l_trans_rec
                , x_ic_jrnl_mst_row     => l_ic_jrnl_mst_row
                , x_ic_adjs_jnl_row1    => l_ic_adjs_jnl_row1
                , x_ic_adjs_jnl_row2    => l_ic_adjs_jnl_row2
                , x_return_status       => l_status
                , x_msg_count           => l_count
                , x_msg_data            => l_data
                );

              IF( l_status IN ('U','E') )  THEN
                -- API Failed. Error message must be on stack.
                l_count_msg := fnd_msg_pub.Count_Msg;

                FOR l_loop_cnt IN 1..l_count_msg
                LOOP
                   FND_MSG_PUB.GET(P_msg_index     => l_loop_cnt,
                                   P_data          => l_data,
                                   P_encoded       => 'F',
                                   P_msg_index_out => l_dummy_cnt);

                   l_message_data := l_message_data||l_data;
                END LOOP;
                x_msg_data      := 'Inv Posting Failed  '||l_message_data;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
              END IF;

     EXCEPTION
        WHEN OTHERS THEN
           x_msg_data      := 'Inv Posting Failed, Unexpected error';
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END;


EXCEPTION
    WHEN OTHERS THEN
        x_msg_data      := 'change_inv_lot_status failed, unexpected error';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END change_inv_lot_status;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_omso_lot_status
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- This procedure returns a plsql table containing lot id and lot status.
-- for shipped transactions.
--Parameters:
--  Otherwise, include the IN:, IN OUT:, and/or OUT: sections as needed.
--IN:
-- p_req_line_id
--  requisition line id.
-- p_item_id
--  item id
--IN OUT:
-- x_lot_sts_tbl
--  plsql table containing lot id and lot status.
--OUT:
-- x_return_status
--  return status of the procedure
-- x_msg_data
--  message returned from procedure
--Notes:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_omso_lot_status
 (  p_req_line_id             IN            NUMBER
 ,  p_item_id                 IN            NUMBER
 ,  x_lot_sts_tab             IN OUT NOCOPY lot_sts_table
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  x_msg_data                   OUT NOCOPY VARCHAR2
 ) IS

  -- declare cursor to fetch shipped lot and status
  CURSOR get_omso_lots IS
  SELECT lot_id,lot_status
  FROM   ic_tran_pnd
  WHERE  doc_type      = 'OMSO'
  AND    item_id       = p_item_id
  AND    completed_ind = 1
  AND    delete_mark   = 0
  AND    line_id  IN(SELECT line_id FROM oe_order_lines_all
                     WHERE  source_document_line_id = p_req_line_id);

  l_number  NUMBER := 1;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --delete plsql table before populating
  x_lot_sts_tab.DELETE;

  FOR r_get_omso_lots in get_omso_lots LOOP
      x_lot_sts_tab(l_number).lot_id     := r_get_omso_lots.lot_id;
      x_lot_sts_tab(l_number).lot_status := r_get_omso_lots.lot_status;
      l_number := l_number + 1;
  END LOOP;

EXCEPTION
    WHEN OTHERS THEN
       x_msg_data      := 'get_omso_lot_status failed unexpected error';
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_omso_lot_status;


END GML_INTORD_LOT_STS;

/

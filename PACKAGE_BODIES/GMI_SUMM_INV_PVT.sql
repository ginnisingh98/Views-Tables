--------------------------------------------------------
--  DDL for Package Body GMI_SUMM_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_SUMM_INV_PVT" AS
/*  $Header: GMIVBUSB.pls 115.5 2000/11/28 08:57:56 pkm ship      $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVBUSB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For Business Layer        |
 |     Logic For IC_SUMM_INV                                               |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 +=========================================================================+
  API Name  : GMI_SUMM_INV_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_SUMM_INV transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes


  Body end of comments
*/

/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_SUMM_INV_PVT';

PROCEDURE PENDING
(
 p_tran_rec  IN  GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_return_status   OUT VARCHAR2
)
IS
err_num    NUMBER;
err_msg    VARCHAR2(200);
l_summ_inv IC_SUMM_INV%ROWTYPE;

BEGIN

  /*   Initialize return status to sucess */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*  Assign All default Values To Record Type */

  l_summ_inv.onhand_qty 	     :=0;
  l_summ_inv.onhand_qty2 	     :=NULL;
  l_summ_inv.onhand_prod_qty 	     :=0;
  l_summ_inv.onhand_prod_qty2 	     :=NULL;
  l_summ_inv.onhand_order_qty 	     :=0;
  l_summ_inv.onhand_order_qty2 	     :=NULL;
  l_summ_inv.onhand_ship_qty 	     :=0;
  l_summ_inv.onhand_ship_qty2 	     :=NULL;
  l_summ_inv.committedprod_qty       :=0;
  l_summ_inv.committedprod_qty2      :=NULL;
  l_summ_inv.onprod_qty              :=0;
  l_summ_inv.onprod_qty2             :=NULL;
  l_summ_inv.committedsales_qty      :=0;
  l_summ_inv.committedsales_qty2     :=NULL;
  l_summ_inv.onpurch_qty             :=0;
  l_summ_inv.onpurch_qty2            :=NULL;
  l_summ_inv.intransit_qty           :=0;
  l_summ_inv.intransit_qty2          :=NULL;


  /*  Copy required Fields From Ic_tran_rec record Type. */

  l_summ_inv.item_id          := p_tran_rec.item_id;
  l_summ_inv.whse_code        := p_tran_rec.whse_code;
  l_summ_inv.qc_grade         := p_tran_rec.qc_grade;
  l_summ_inv.last_updated_by  := p_tran_rec.user_id;
  l_summ_inv.created_by       := p_tran_rec.user_id;
  l_summ_inv.last_update_date := SYSDATE;
  l_summ_inv.creation_date    := SYSDATE;


  /* Firm Planned Orders */

  IF p_tran_rec.doc_type='FPO' THEN
    RETURN; /* No Update Needed For Firm Planned Orders */
  END IF;

  /* Production Batches */

  IF p_tran_rec.doc_type='PROD' THEN
     /* If Ingredient Lines */
     IF p_tran_rec.line_type = -1 THEN
          l_summ_inv.committedprod_qty  := p_tran_rec.trans_qty  * -1;
          l_summ_inv.committedprod_qty2 := p_tran_rec.trans_qty2 * -1;
     ELSE
        /* Products And By Products
        Increase Expected Production quantity */

        l_summ_inv.onprod_qty  := p_tran_rec.trans_qty;
        l_summ_inv.onprod_qty2 := p_tran_rec.trans_qty2;
     END IF;
  END IF;

  /* Sales Orders And Shipments */

  IF ( p_tran_rec.doc_type='OMSO') OR ( p_tran_rec.doc_type ='OPSO') THEN
    /* increase committed sales Quantity */
      l_summ_inv.committedsales_qty  := p_tran_rec.trans_qty  *-1;
      l_summ_inv.committedsales_qty2 := p_tran_rec.trans_qty2 *-1;
  END IF;

  /* Purchase Orders  And Receipts */

  IF ( p_tran_rec.doc_type='PORD')  OR (p_tran_rec.doc_type = 'RECV') THEN
    /* increase expected purchase Quantity */
      l_summ_inv.onpurch_qty  := p_tran_rec.trans_qty;
      l_summ_inv.onpurch_qty2 := p_tran_rec.trans_qty2;
  END IF;

  /* Transfers */

  IF p_tran_rec.doc_type = 'XFER' THEN
	l_summ_inv.intransit_qty := p_tran_rec.trans_qty ;
	l_summ_inv.intransit_qty2:= p_tran_rec.trans_qty2;
  END IF;

  /*  Update Inventory Summary Table -- */

  IF NOT GMI_SUMM_INV_DB_PVT.UPDATE_IC_SUMM_INV( p_summ_inv => l_summ_inv)
   THEN
      IF NOT GMI_SUMM_INV_DB_PVT.INSERT_IC_SUMM_INV( p_summ_inv => l_summ_inv)
        THEN
        FND_MESSAGE.SET_NAME('GMI','GMI_IC_SUMM_INV_INSERT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'PENDING');



END PENDING;

PROCEDURE COMPLETED
(
 p_tran_rec  IN  GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_return_status   OUT VARCHAR2
)
IS
err_num    NUMBER;
err_msg    VARCHAR2(200);

l_summ_inv             IC_SUMM_INV%ROWTYPE;
l_lots_sts             IC_LOTS_STS%ROWTYPE;
BEGIN

   /*   Initialize return status to sucess */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*  Assign All default Values To Record Type */

   l_summ_inv.onhand_qty 	   :=0;
   l_summ_inv.onhand_qty2 	   :=NULL;
   l_summ_inv.onhand_prod_qty 	   :=0;
   l_summ_inv.onhand_prod_qty2 	   :=NULL;
   l_summ_inv.onhand_order_qty 	   :=0;
   l_summ_inv.onhand_order_qty2    :=NULL;
   l_summ_inv.onhand_ship_qty 	   :=0;
   l_summ_inv.onhand_ship_qty2 	   :=NULL;
   l_summ_inv.committedprod_qty    :=0;
   l_summ_inv.committedprod_qty2   :=NULL;
   l_summ_inv.onprod_qty           :=0;
   l_summ_inv.onprod_qty2          :=NULL;
   l_summ_inv.committedsales_qty   :=0;
   l_summ_inv.committedsales_qty2  :=NULL;
   l_summ_inv.onpurch_qty          :=0;
   l_summ_inv.onpurch_qty2         :=NULL;
   l_summ_inv.intransit_qty        :=0;
   l_summ_inv.intransit_qty2       :=NULL;


   /*  Copy required Fields From Ic_tran_row  Type. */

   l_summ_inv.item_id          := p_tran_rec.item_id;
   l_summ_inv.whse_code        := p_tran_rec.whse_code;
   l_summ_inv.qc_grade         := p_tran_rec.qc_grade;
   l_summ_inv.last_updated_by  := p_tran_rec.user_id;
   l_summ_inv.created_by       := p_tran_rec.user_id;
   l_summ_inv.last_update_date := SYSDATE;
   l_summ_inv.creation_date    := SYSDATE;

   IF p_tran_rec.lot_status IS NULL THEN
      l_lots_sts.nettable_ind   :=1;
      l_lots_sts.order_proc_ind :=1;
      l_lots_sts.prod_ind       :=1;
      l_lots_sts.shipping_ind   :=1;
      l_lots_sts.rejected_ind   :=1;
   ELSE
      /*  Get Specific Values for Passed In status. */

      IF NOT ( GMI_SUMM_INV_DB_PVT.GET_LOT_ATTRIBUTES
	       (
	         p_lot_status => p_tran_rec.lot_status,
	         x_lots_sts   => l_lots_sts
	       )
	   )
          THEN

             FND_MESSAGE.SET_NAME('GMI','IC_INVALID_LOT_STATUS');
             FND_MESSAGE.SET_TOKEN('LOT_STATUS', p_tran_rec.lot_status);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF;

  /* Nettable Lots */

  IF l_lots_sts.nettable_ind =1 THEN
      l_summ_inv.onhand_qty   := p_tran_rec.trans_qty;
      l_summ_inv.onhand_qty2  := p_tran_rec.trans_qty2;
  END IF;

  /* Available For Production */

  IF l_lots_sts.prod_ind =1 THEN
      l_summ_inv.onhand_prod_qty   := p_tran_rec.trans_qty;
      l_summ_inv.onhand_prod_qty2  := p_tran_rec.trans_qty2;
  END IF;

  /* Available For Sales */

  IF l_lots_sts.order_proc_ind =1 THEN
      l_summ_inv.onhand_order_qty   := p_tran_rec.trans_qty;
      l_summ_inv.onhand_order_qty2  := p_tran_rec.trans_qty2;
  END IF;

  /* Available For Shipping */

  IF l_lots_sts.shipping_ind =1 THEN
      l_summ_inv.onhand_ship_qty   := p_tran_rec.trans_qty;
      l_summ_inv.onhand_ship_qty2  := p_tran_rec.trans_qty2;
  END IF;

  /*  Update Inventory Summary Table -- */

  IF NOT GMI_SUMM_INV_DB_PVT.UPDATE_IC_SUMM_INV( p_summ_inv => l_summ_inv)
  THEN

     IF NOT GMI_SUMM_INV_DB_PVT.INSERT_IC_SUMM_INV( p_summ_inv => l_summ_inv)
     THEN
       FND_MESSAGE.SET_NAME('GMI','GMI_IC_SUMM_INV_INSERT');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'COMPLETED');

END COMPLETED;

END GMI_SUMM_INV_PVT;

/

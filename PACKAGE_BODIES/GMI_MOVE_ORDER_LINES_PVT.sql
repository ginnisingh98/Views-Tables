--------------------------------------------------------
--  DDL for Package Body GMI_MOVE_ORDER_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MOVE_ORDER_LINES_PVT" AS
/*  $Header: GMIVMOLB.pls 115.20 2004/02/05 17:04:30 lswamy ship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVMOLB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Private Routines relating to GMI              |
 |     Move Order LINES.                                                   |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  Hverddin        Created                                |
 |   			   			                           |
 +=========================================================================+
  API Name  : GMI_Move_Order_LINES_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_MOVE_ORDER_LINES_PVT';

PROCEDURE Process_Move_Order_LINES
 (
   p_api_version_number          IN  NUMBER
 , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_flag             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
 , p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_mo_line_tbl                 IN  GMI_Move_Order_Global.MO_LINE_TBL
 , x_mo_line_tbl                 OUT NOCOPY GMI_Move_Order_Global.MO_LINE_TBL
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 )
 IS
 l_api_name           CONSTANT VARCHAR2 (30) := 'PROCESS_MOVE_ORDER_LINES';
 l_api_version_number CONSTANT NUMBER        := 1.0;
 l_msg_count          NUMBER  :=0;
 l_msg_data           VARCHAR2(2000);
 l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_mo_line_rec        GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
 l_mo_line_tbl        GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;
 l_opm_item_id        NUMBER;
 l_opm_noninv_ind     NUMBER;
 l_opm_lot_ctl        NUMBER;
 l_opm_loct_ctl       NUMBER;
 l_def_count          NUMBER := 0;
 l_whse_code          VARCHAR2(4);
 l_default_tran_rec   GMI_TRANS_ENGINE_PUB.ictran_rec;

 CURSOR get_opm_item IS
   Select distinct ic.item_id ,
          ic.noninv_ind,
          ic.lot_ctl,
          ic.loct_ctl
   From ic_item_mst ic,
        mtl_system_items mtl
   Where mtl.inventory_item_id = l_mo_line_rec.inventory_item_id
    And mtl.segment1= ic.item_no;

 CURSOR get_detailed_qtys IS
   Select sum(abs(trans_qty)), sum(abs(trans_qty2))
   From ic_tran_pnd
   Where line_id = l_mo_line_rec.txn_source_line_id
    -- And item_id = l_opm_item_id (commenting this line so that index on line_id gets used)
    And lot_id <> 0
    And doc_type = 'OMSO'
    And delete_mark = 0
    And completed_ind = 0;

 CURSOR get_default_detailed_qtys IS
   Select sum(abs(trans_qty)), sum(abs(trans_qty2))
   From ic_tran_pnd
   Where line_id = l_mo_line_rec.txn_source_line_id
   -- And item_id = l_opm_item_id (commenting this line so that index on line_id gets used)
    And lot_id = 0
    And doc_type = 'OMSO'
    And delete_mark = 0
    And completed_ind = 0;

 CURSOR mo_line_exist IS
   Select line_id
   From ic_txn_request_lines
   Where txn_source_line_id = l_mo_line_rec.txn_source_line_id;

  IC$DEFAULT_LOCT        VARCHAR2(255) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  l_trans_id NUMBER;

/* Uday Phadtare Bug 2973135 */
  CURSOR get_default_trans(p_line_id NUMBER, p_item_id NUMBER) IS
  SELECT count(*)
  FROM   ic_tran_pnd
  WHERE  line_id       = p_line_id
  AND    doc_type      = 'OMSO'
  -- AND    item_id       = p_item_id (commenting this line so that index on line_id gets used)
  AND    staged_ind    = 0
  AND    completed_ind = 0
  AND    delete_mark   = 0
  AND    lot_id        = 0
  AND    location      = ic$default_loct
  AND    line_detail_id IS NULL;

/* Uday Phadtare Bug 2973135 */
  -- Get whse information
  CURSOR get_whse_code( p_organization_id NUMBER ) IS
  SELECT whse_code
  FROM   IC_WHSE_MST
  WHERE  mtl_organization_id = p_organization_id;

  BEGIN
   /* Standard Start OF API savepoint */
   SAVEPOINT move_order_LINES;
gmi_reservation_util.println('In move_order_lines_pvt');

   /*  DBMS_OUTPUT.PUT_LINE('IN MOVE ORDER LINES'); */

   /*  Standard call to check for call compatibility. */

   IF NOT FND_API.Compatible_API_CALL ( l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , G_PKG_NAME
                                       )
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

/*  Initialize message list if p_int_msg_lst is set TRUE. */
   IF FND_API.to_boolean(p_init_msg_lst)
   THEN
     FND_MSG_PUB.Initialize;
   END IF;
/* Initialize API return status to sucess */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  WSH_Util_Core.PrintLn('Move_Order_LINES PVT COUNT=> '||p_mo_line_tbl.COUNT);
  gmi_reservation_util.PrintLn('Move_Order_LINES PVT COUNT=> '||p_mo_line_tbl.COUNT);

  FOR I in 1..p_mo_line_TBL.COUNT LOOP
     gmi_reservation_util.println('In loop');
     l_mo_line_rec := p_mo_line_tbl(I);
     WSH_Util_Core.PrintLn('move order line for source line_id > '|| l_mo_line_rec.txn_source_line_id );
     WSH_Util_Core.PrintLn('Check Missing For  Row > '||  I );
     IF check_required( p_mo_line_rec => l_mo_line_rec) THEN
       FND_MESSAGE.SET_NAME('GMI','Required Values Missing In Lines');
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     /*  Need To Set l_trolin_rec.primary_quantity */
     /*  Initially Lets Set it to Requested Quantity ( quantity) */
     /*  Since they should be the same. */
     l_mo_line_rec.primary_quantity := l_mo_line_rec.quantity;
     WSH_Util_Core.PrintLn('Operation Row ==> '||l_mo_line_rec.operation);
     IF l_mo_line_rec.operation = INV_GLOBALS.G_OPR_DELETE THEN
       /*  physically delete this row */
       /*  This first Queries To see If Any Reservations Exist */
       /*  ( GMI Transcations) Then deletes or Updates. */
       /*  Else it will just delete this line. */
        gmi_reservation_util.println('Operation delete');
       GMI_Move_Order_LINE_Util.delete_Row( l_mo_line_rec.LINE_id);
     ELSE
gmi_reservation_util.println('Going to fetch opm_item');
       Open get_opm_item;
       Fetch get_opm_item Into l_opm_item_id,
                               l_opm_noninv_ind,
                               l_opm_lot_ctl,
                               l_opm_loct_ctl;
       Close get_opm_item;

       IF l_mo_line_rec.operation = INV_GLOBALS.G_OPR_UPDATE THEN
gmi_reservation_util.println('Operation update');
      	 IF (l_opm_lot_ctl <> 0 OR l_opm_loct_ctl <> 0) THEN
      	 gmi_reservation_util.println('Going to fetch get_detailed_qtys ');
      	   Open get_detailed_qtys;
      	   Fetch get_detailed_qtys Into l_mo_line_rec.quantity_detailed,
      	                              l_mo_line_rec.secondary_quantity_detailed;
      	   Close get_detailed_qtys;

           -- Bug 1987780, Sept-2001, odaboval added the delivered qty :
           IF ( NVL(l_mo_line_rec.quantity_delivered,0) > NVL(l_mo_line_rec.quantity_detailed, 0) )
           THEN
              l_mo_line_rec.quantity_delivered := l_mo_line_rec.quantity_detailed;
              l_mo_line_rec.secondary_quantity_delivered := l_mo_line_rec.secondary_quantity_detailed;
           END IF;
      	 ELSE
           gmi_reservation_util.println('Going to fetch get_default_detailed_qtys');
      	   Open get_default_detailed_qtys;
      	   Fetch get_default_detailed_qtys Into l_mo_line_rec.quantity_detailed,
      	                              l_mo_line_rec.secondary_quantity_detailed;
      	   Close get_default_detailed_qtys;
      	 END IF;
       END IF;

       /*  Is This correct To Set Status Date */
       l_mo_line_rec.status_date := NVL(l_mo_line_rec.status_date,SYSDATE);

       /*  Set Generic defaults */
       l_mo_line_rec.last_update_date   := SYSDATE;
       l_mo_line_rec.last_updated_by    := FND_GLOBAL.USER_ID;
       l_mo_line_rec.last_update_login  := FND_GLOBAL.USER_ID;

       IF l_mo_line_rec.operation = INV_GLOBALS.G_OPR_UPDATE THEN
         /*  This will first check if old_line quantity or line_status */
         /*  or quantity_detailed is different from New Then Call */
         /*  query to get reservations and do update logic. */
         /*  Else it will just update this row.  */
          gmi_reservation_util.println('Going to update row');
         GMI_Move_Order_LINE_Util.update_Row( l_mo_line_rec);
       ELSIF l_mo_line_rec.operation = INV_GLOBALS.G_OPR_CREATE THEN
	 /*  Set create defaults */
         gmi_reservation_util.println('Going to get get new id');
         l_mo_line_rec.creation_date   := SYSDATE;
         l_mo_line_rec.created_by      := FND_GLOBAL.USER_ID;
         /*  Get New LINES Id Via Sequence */
         -- BEGIN Bug 2628244 - Use of sequence MTL_TXN_REQUEST_LINES_S instead of gmi_mo_LINE_id_s
         --select gmi_mo_LINE_id_s.nextval
         select MTL_TXN_REQUEST_LINES_S.nextval
         -- END Bug 2628244
         INTO   l_mo_line_rec.LINE_id
         FROM   DUAL;

         WSH_Util_Core.PrintLn('Insert For Row > '|| I);
         gmi_reservation_util.println('Going to intsert line in move order ');
         GMI_Move_Order_LINE_Util.Insert_Row( l_mo_line_rec);

         /* Begin Bug 2973135 Uday Phadtare */
         --Check if default transaction exists
         OPEN  get_default_trans(l_mo_line_rec.txn_source_line_id, l_opm_item_id);
         FETCH get_default_trans into l_def_count;
         CLOSE get_default_trans;

         /* create a default lot transaction from scratch if it does not exist */
         IF l_def_count = 0 THEN
            OPEN  get_whse_code(l_mo_line_rec.organization_id);
            FETCH get_whse_code INTO l_whse_code;
            CLOSE get_whse_code;

            GMI_Reservation_Util.PrintLn('Transaction with default : NOTFOUND ');
            GMI_RESERVATION_UTIL.Create_dflt_lot_from_scratch
             (  p_whse_code       => l_whse_code
              , p_line_id         => l_mo_line_rec.txn_source_line_id
              , p_item_id         => l_opm_item_id
              , p_qty1            => l_mo_line_rec.primary_quantity
              , p_qty2            => l_mo_line_rec.secondary_quantity
              , x_return_status   => l_return_status
              , x_msg_count       => x_msg_count
              , x_msg_data        => x_msg_data
             );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                GMI_reservation_Util.PrintLn('Error returned by Create_dflt_lot_from_scratch in Process_Move_Order_LINES');
                FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
                FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.create_dflt_lot_from_scratch');
                FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            GMI_RESERVATION_UTIL.find_default_lot
                  (   x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data,
                      x_reservation_id    => l_trans_id,
                      p_line_id           => l_mo_line_rec.txn_source_line_id
                  );
            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               GMI_RESERVATION_UTIL.println('Error returned by find default lot');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            l_default_tran_rec.trans_id := l_trans_id;

            IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND(l_default_tran_rec, l_default_tran_rec) THEN
              GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| l_mo_line_rec.txn_source_line_id);
              GMI_RESERVATION_UTIL.balance_default_lot
                (  p_ic_default_rec            => l_default_tran_rec
                 , p_opm_item_id               => l_default_tran_rec.item_id
                 , x_return_status             => x_return_status
                 , x_msg_count                 => x_msg_count
                 , x_msg_data                  => x_msg_data
                );
              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                GMI_reservation_Util.PrintLn('Error returned by balance_default_lot in Process_Move_Order_LINES');
                FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
                FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
                FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END IF;
         END IF;
         /* End Bug 2973135 Uday Phadtare */

       END IF;
    END IF;

    l_mo_line_tbl(I) := l_mo_line_rec;
    gmi_reservation_util.println('Value of line id for l_mo_line_rec is '||l_mo_line_rec.line_id);
  END LOOP;

  /*  Load Output table */

  x_mo_line_tbl := l_mo_line_tbl;

  WSH_Util_Core.PrintLn('Count MOL Table => '|| x_mo_line_tbl.COUNT);

  /* FND_MESSAGE.Set_Name('GMI','Entering_GMI_Create_Move_Order_LINES'); */
  /* FND_MSG_PUB.Add; */
  /* RAISE FND_API.G_EXC_ERROR; */

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;

	 FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
					      , l_api_name
	      				);


      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );



END Process_Move_Order_LINES;

FUNCTION check_required
 (
  p_mo_line_rec        IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
 )
 RETURN BOOLEAN
 IS
BEGIN

  WSH_Util_Core.PrintLn('Operation Row ==> '||p_mo_line_rec.operation);
  WSH_Util_Core.PrintLn('header id ==> '||p_mo_line_rec.header_id);
  WSH_Util_Core.PrintLn('line num  ==> '||p_mo_line_rec.line_number);
  WSH_Util_Core.PrintLn('org id    ==> '||p_mo_line_rec.organization_id);
  WSH_Util_Core.PrintLn('Item id   ==> '||p_mo_line_rec.inventory_item_id);
  WSH_Util_Core.PrintLn('uom code  ==> '||p_mo_line_rec.uom_code);
  WSH_Util_Core.PrintLn('quantity  ==> '||p_mo_line_rec.quantity);
  WSH_Util_Core.PrintLn('status    ==> '||p_mo_line_rec.line_status);
  WSH_Util_Core.PrintLn('trans id  ==> '||p_mo_line_rec.transaction_type_id);

 IF ( p_mo_line_rec.operation = INV_GLOBALS.G_OPR_CREATE)  THEN

    IF  p_mo_line_rec.header_id           is NULL OR
        p_mo_line_rec.line_number         is NULL OR
        p_mo_line_rec.organization_id     is NULL OR
        p_mo_line_rec.inventory_item_id   is NULL OR
        p_mo_line_rec.uom_code            is NULL OR
        p_mo_line_rec.quantity            is NULL OR
        p_mo_line_rec.line_status         is NULL OR
        p_mo_line_rec.transaction_type_id is NULL THEN

	   RETURN TRUE;

	ELSE
	   RETURN FALSE;

     END IF;


 ELSIF ( p_mo_line_rec.operation = INV_GLOBALS.G_OPR_UPDATE)  THEN

    IF  p_mo_line_rec.header_id           is NULL OR
        p_mo_line_rec.line_id             is NULL OR
        p_mo_line_rec.line_number         is NULL OR
        p_mo_line_rec.organization_id     is NULL OR
        p_mo_line_rec.inventory_item_id   is NULL OR
        p_mo_line_rec.uom_code            is NULL OR
        p_mo_line_rec.quantity            is NULL OR
        p_mo_line_rec.line_status         is NULL OR
        p_mo_line_rec.transaction_type_id is NULL THEN

	   RETURN TRUE;

	ELSE
	   RETURN FALSE;

     END IF;

  /*  This should Catch DELETE, LOCK_ROW and QUERY */
  /*  Which all need a LINES ID. */
  ELSE

    IF  p_mo_line_rec.header_id        is NULL OR
        p_mo_line_rec.LINE_id         is NULL THEN
	   RETURN TRUE;
    ELSE
	   RETURN FALSE;
    END IF;

 END IF;

 RETURN TRUE;


 EXCEPTION
																 WHEN OTHERS THEN
	 FND_MESSAGE.SET_NAME('GMI','UNEXPECTED ERROR CHECK MISSING');
      RETURN TRUE;

END CHECK_REQUIRED;


END GMI_Move_Order_LINES_PVT;

/

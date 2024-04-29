--------------------------------------------------------
--  DDL for Package Body GMI_PICK_WAVE_CONFIRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PICK_WAVE_CONFIRM_PVT" AS
/*  $Header: GMIVPWCB.pls 120.1 2005/08/30 08:24:08 nchekuri noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVPWCB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Private Routines relating to GMI              |
 |     Move Order LINES.                                                   |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  Hverddin        Created                                |
 |     09/10/01     HW    BUG#:1941429 Added code to supoort cross_docking |
 |     11/22/2002   PKU   BUG# 2675737 Secondary qty should not be checked |
 |                        for over or under shipment tolerances            |
 |	                                                                   |
 |     Dec. 5th, 2002 HW  Added NOCOPY to Pick_confirm procedure           |
 |     Jan. 23rd,2004 HAW 3387829. Issue with splitting non-lot and        |
 |                        non-inv items. Problem is populating the correct |
 |                        trans_id during pick confirm which affected      |
 |                        the split and there was a mismatch between       |
 |                        shipping lines and transactions in line_detail_id|
 |    Sep. 3rd, 2004 HAW  BUG#:3871662. Removed cursor check_wsh           |
 |    Sep. 3rd  2004 PKU  BUG 3859774                                      |
 |    ONLY primary allocations should be compared with primary available   |
 +=========================================================================+
  API Name  : GMI_PICK_WAVE_CONFIRM_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/
PROCEDURE check_quantity_to_pick(
	p_order_line_id           IN  NUMBER,
        p_quantity_to_pick        IN  NUMBER,
        p_quantity2_to_pick       IN  NUMBER DEFAULT NULL,
        x_allowed_flag            OUT NOCOPY VARCHAR2,
        x_max_quantity_allowed    OUT NOCOPY NUMBER,
        x_max_quantity2_allowed   OUT NOCOPY NUMBER,
        x_avail_req_quantity      OUT NOCOPY NUMBER,
        x_avail_req_quantity2     OUT NOCOPY NUMBER,
        x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Min_Max_Tolerance_Quantity
(
     p_api_version_number       IN  NUMBER
,    p_line_id                  IN  NUMBER
,    x_min_remaining_quantity   OUT NOCOPY NUMBER
,    x_max_remaining_quantity   OUT NOCOPY NUMBER
,    x_min_remaining_quantity2  OUT NOCOPY NUMBER
,    x_max_remaining_quantity2  OUT NOCOPY NUMBER
,    x_return_status            OUT NOCOPY VARCHAR2
,    x_msg_count                OUT NOCOPY NUMBER
,    x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE dump_shp_attrb_data
(
     p_shipping_attr IN WSH_INTERFACE.ChangedAttributeTabType
);

-- BEGIN Bug 3776538
PROCEDURE truncate_trans_qty
(
     p_line_id            IN number,
     p_delivery_detail_id IN number,
     p_default_location   IN varchar2,
     is_lot_loct_ctl      IN boolean,
     x_return_status      OUT NOCOPY VARCHAR2
);
-- END Bug 3776538

G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_PICK_WAVE_CONFIRM_PVT';




-- HW BUG# 2296620
G_WARNING_SHIP_SET  CONSTANT  VARCHAR2(1):='X';

PROCEDURE CHECK_SHIP_SET (
    p_ship_set_id                 IN NUMBER
  , p_manual_pick                 IN VARCHAR2
  , x_return_status               OUT NOCOPY VARCHAR2
  )
IS

l_api_name              CONSTANT VARCHAR2 (30) := 'PICK_CONFIRM';
l_api_version_number    CONSTANT NUMBER        := 1.0;

cursor get_qty IS
 SELECT quantity,
        quantity_detailed,
        line_status
 FROM IC_TXN_REQUEST_LINES
 WHERE ship_set_id = p_ship_set_id
AND   LINE_STATUS = 7;



l_warning               EXCEPTION;
l_manual_warning        EXCEPTION;
l_ship_set_id NUMBER;

 BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_ship_set_id := p_ship_set_id;

    For mo_line in get_qty LOOP

     IF ( mo_line.quantity > mo_line.quantity_detailed ) THEN

       gmi_reservation_util.println('HELLO from the loop');
       gmi_reservation_util.println('Value of quantity in chk_ship_set is '||mo_line.quantity );
       gmi_reservation_util.println('Value of l_qty_detailed is ' ||mo_line.quantity_detailed);

       IF ( p_manual_pick = 'Y' ) THEN
       gmi_reservation_util.println('Raising manual warning');
         RAISE l_manual_warning;
       ELSIF ( p_manual_pick ='N')THEN
         gmi_reservation_util.println('Ship set is broken. Qty allocated less than requested');
         RAISE l_warning;
       END IF; -- of manual or auto allocation

     END IF;  -- if qty > qty_detaild

   END LOOP;  -- end of loop */
   gmi_reservation_util.println('HELLO from end of chk-set prc.');


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := fnd_api.g_ret_sts_error;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    WHEN l_warning THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

    WHEN l_manual_warning THEN
      x_return_status := G_WARNING_SHIP_SET;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;


 END CHECK_SHIP_SET;

-- HW end of 2296620
/* LG added delivery detail id so it can be performed on a single delivery only */
-- HW OPM changes for NOCOPY
-- Added NOCOPY to x_mo_line_tbl
PROCEDURE PICK_CONFIRM
 (
   p_api_version_number          IN  NUMBER
 , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_flag             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
 , p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_delivery_detail_id          IN  NUMBER DEFAULT NULL
 , p_mo_line_tbl                 IN  GMI_Move_Order_Global.MO_LINE_TBL
 , x_mo_line_tbl                 OUT NOCOPY GMI_Move_Order_Global.MO_LINE_TBL
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 , p_manual_pick             IN VARCHAR2 DEFAULT NULL
 )
 IS
 l_api_name              CONSTANT VARCHAR2 (30) := 'PICK_CONFIRM';
 l_api_version_number    CONSTANT NUMBER        := 1.0;

 l_msg_count             NUMBER  :=0;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_mo_line_rec           GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
 l_mo_line_tbl           GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;
 l_location              IC_TRAN_PND.LOCATION%TYPE;
 l_ic_item_mst_rec       GMI_RESERVATION_UTIL.ic_item_mst_rec;
 l_shipping_attr         WSH_INTERFACE.ChangedAttributeTabType;
 l_trans_qty             NUMBER;
 l_trans_qty2            NUMBER;
 l_trans_qty_sts         NUMBER;
 l_trans_qty2_sts        NUMBER;
 l_converted_trans_qty   NUMBER;
 l_sum_trans_qty         NUMBER;
 l_sum_trans_qty2        NUMBER;
 l_requested_qty         NUMBER;
 l_requested_qty2        NUMBER;
 l_source_header_id      NUMBER;
 l_source_line_id        NUMBER;
 l_delivery_detail_id    NUMBER;
 l_delivery_qty          NUMBER;
 l_default_transaction   NUMBER(1);
 l_default_exist          NUMBER(1) := 1;
 l_action_flag           VARCHAR2(1);
 l_order_quantity_uom    VARCHAR2(3);
 l_whse_code             VARCHAR2(5);
 l_organization_id       NUMBER;
 l_backorder_qty         NUMBER;
 l_backorder_qty2        NUMBER;
 l_count                 NUMBER;
 l_whse_ctl              NUMBER;
 l_allowed               VARCHAR2(1);
 l_max_qty               NUMBER;
 l_max_qty2              NUMBER;
 l_status_ctl            NUMBER;
 l_orderable_ind         NUMBER;
 l_shipable_ind          NUMBER;
 l_backorder_del         NUMBER;
 l_transactable          NUMBER;

 l_manual_pick           VARCHAR2(1);
 l_no_error              VARCHAR2(1) :='1' ;
 l_warning               EXCEPTION;
 l_tolerance_warning     EXCEPTION;
 l_tolerance_flag        NUMBER := 0;
 l_warning_flag          NUMBER := 0 ;
-- Begin Bug 3609713
 l_allowneginv           NUMBER;
 l_onhand1		 NUMBER;
 l_onhand2		 NUMBER;
 l_alloc1		 NUMBER;
 l_alloc2		 NUMBER;
 l_inv_negative		 NUMBER := 0;
-- End Bug 3609713

  l_ALLOW_OPM_TRUNCATE_TXN VARCHAR2(4);                  -- Bug 3776538
 /*  define Cursors; */

 /*  If Item is Lot or  Location Controlled */

 CURSOR cur_txn_no_default ( p_line_id   NUMBER,
                             p_location  VARCHAR2,
                             p_item_id   NUMBER)
 is
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd
 WHERE  line_id       = p_line_id
 AND    (  lot_id       > 0
        OR location <> p_location )
 -- AND	   item_id       = p_item_id                            -- REMOVED for bug 3403418
 AND    doc_type      = 'OMSO'
 AND    staged_ind    = 0
 AND    completed_ind = 0
 AND    delete_mark   = 0
 AND    line_detail_id in
    (Select delivery_detail_id
     From wsh_delivery_details
     Where move_order_line_id = l_mo_line_rec.line_id
        and released_status in ('R','S'));

 /*  If Item is NOT Lot AND NOT Location Controlled */

 CURSOR cur_txn_with_default ( p_line_id   NUMBER,
                               p_item_id   NUMBER)
 is
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd
 WHERE  line_id       = p_line_id
 -- AND    item_id       = p_item_id                            -- REMOVED for bug 3403418
 AND    doc_type      = 'OMSO'
 AND    staged_ind    = 0
 AND    completed_ind = 0
 AND    delete_mark   = 0;

 CURSOR check_default_lot ( p_line_id   NUMBER,
                            p_item_id   NUMBER)
 IS
  SELECT count(*)
  FROM ic_tran_pnd
  WHERE  line_id       = p_line_id
    -- AND    item_id       = p_item_id                         -- REMOVED for bug 3403418
    AND    doc_type      = 'OMSO'
    AND    staged_ind    = 0
    AND    completed_ind = 0
    AND    delete_mark   = 0;

 CURSOR mo_line_txn_c ( p_line_id   IN NUMBER,
                        p_location  IN VARCHAR2,
                        p_item_id   IN NUMBER,
                        p_delivery_detail_id IN NUMBER)
 IS
 SELECT tran.trans_id,
        ABS(tran.trans_qty) trans_qty,
        ABS(tran.trans_qty2) trans_qty2,
        tran.qc_grade,
        tran.location,
        lots.lot_no,
        lots.lot_id,
        lots.sublot_no,
        loct.INVENTORY_LOCATION_ID locator_id
  FROM  IC_TRAN_PND tran,
        IC_LOTS_MST lots,
        IC_LOCT_MST loct
  WHERE lots.lot_id        = tran.lot_id
  AND   lots.item_id       = tran.item_id
  AND   lots.delete_mark   = 0
  AND   tran.line_id       = p_line_id
  AND   (  tran.lot_id       > 0
        OR tran.location <> p_location )
 -- AND   tran.item_id       = p_item_id                        -- REMOVED for bug 3403418
  AND   tran.doc_type      = 'OMSO'
  AND   tran.staged_ind    = 0
  AND   tran.completed_ind = 0
  AND   tran.delete_mark   = 0
  AND   loct.delete_mark(+)   = 0
  AND   loct.whse_code  (+)   = tran.whse_code
  AND   loct.location   (+)   = tran.location
  AND   tran.line_detail_id  = l_delivery_detail_id;

l_mo_line_txn_rec mo_line_txn_c%ROWTYPE;

 CURSOR get_whse_code IS
  SELECT whse_code,loct_ctl
  FROM ic_whse_mst
  WHERE mtl_organization_id = l_organization_id;

 CURSOR get_delivery IS
   SELECT delivery_detail_id
        , source_header_id
        , source_line_id
        , requested_quantity
        , requested_quantity2
   FROM   wsh_delivery_details
   WHERE  move_order_line_id = l_mo_line_rec.line_id
   AND    move_order_line_id IS NOT NULL
   AND    released_status = 'S';

  -- Begin Bug 3609713
  CURSOR check_onhand_qty(p_item_id    IN NUMBER,
                          p_whse_code  IN VARCHAR2,
                          p_lot_id     IN NUMBER,
                          p_location   IN VARCHAR2)
  IS
    Select loct_onhand
          ,nvl(loct_onhand2,0)
    From  ic_loct_inv inv
    Where inv.item_id = p_item_id
      AND inv.whse_code = p_whse_code
      AND inv.lot_id = p_lot_id
      AND inv.location  = p_location;

  CURSOR check_staged(p_item_id    IN NUMBER,
                      p_whse_code  IN VARCHAR2,
                      p_lot_id     IN NUMBER,
                      p_location   IN VARCHAR2)
  IS
    Select nvl(sum(trans_qty),0)
          ,nvl(sum(nvl(trans_qty2,0)),0)
    From  ic_tran_pnd pnd
    Where pnd.completed_ind =0
    AND pnd.delete_mark = 0
    AND pnd.staged_ind = 1
    AND pnd.doc_type= 'OMSO'
    AND pnd.item_id = p_item_id
    AND pnd.whse_code = p_whse_code
    AND pnd.lot_id = p_lot_id
    AND pnd.location  = p_location;
  -- End Bug 3609713

 CURSOR qty_sum_for_del IS
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd
 WHERE  line_id        = l_mo_line_rec.txn_source_line_id
    AND line_detail_id = l_delivery_detail_id
    AND delete_mark    = 0;

 CURSOR check_open_del IS
   Select count(*)
   From wsh_delivery_details
   Where move_order_line_id = l_mo_line_rec.line_id
      And source_line_id = l_mo_line_rec.txn_source_line_id
      And released_status = 'S';

/* bug 2202841, add status ctl, only the shippable can be transacted */
 CURSOR get_status_ctl(p_item_id NUMBER)
 is
 Select status_ctl
 From ic_item_mst
 Where item_id=p_item_id;

 CURSOR cur_txn_no_dflt_sts( p_line_id   NUMBER,
                             p_item_id   NUMBER,
                             p_mo_line_id   NUMBER)
 is
 SELECT SUM(ABS(nvl(trans_qty,0))),SUM(ABS(nvl(trans_qty2,0)))
 FROM   ic_tran_pnd trans
      , ic_loct_inv lots
      , ic_lots_sts sts
 WHERE  trans.line_id       = p_line_id
 AND    trans.lot_id       > 0
 -- AND    trans.item_id       = p_item_id                      -- REMOVED for bug 3403418
 AND    trans.doc_type      = 'OMSO'
 AND    trans.staged_ind    = 0
 AND    trans.completed_ind = 0
 AND    trans.delete_mark   = 0
 AND lots.item_id = trans.item_id
 AND lots.whse_code = trans.whse_code
 AND lots.lot_id = trans.lot_id
 AND lots.location = trans.location
 AND lots.lot_status = sts.lot_status (+)
 AND NVL(sts.shipping_ind,1) = 1
-- AND NVL(sts.order_proc_ind,1)=1 PK Bug 3470116
 AND NVL(sts.rejected_ind,0) = 0
 AND    trans.line_detail_id in
    (Select delivery_detail_id
     From wsh_delivery_details
     Where move_order_line_id = p_mo_line_id
        and released_status in ('R','S'))
 ;

CURSOR check_lot_sts (p_item_id    IN NUMBER,
                      p_whse_code  IN VARCHAR2,
                      p_lot_id     IN NUMBER,
                      p_location   IN VARCHAR2)
IS
  Select order_proc_ind
      ,  shipping_ind
  From ic_lots_sts sts
     , ic_loct_inv inv
  Where inv.item_id = p_item_id
    AND inv.whse_code = p_whse_code
    AND inv.lot_id = p_lot_id
    AND inv.location  = p_location
    AND inv.lot_status = sts.lot_status
   ;
 CURSOR qty_sum_for_del_sts IS
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd tran
      , ic_loct_inv inv                        -- get status
      , ic_lots_sts sts                        -- status check
 WHERE    tran.line_id        = l_mo_line_rec.txn_source_line_id
    AND   tran.line_detail_id = l_delivery_detail_id
    AND   tran.delete_mark    = 0
    AND   inv.item_id          = tran.item_id
    AND   inv.whse_code        = tran.whse_code
    AND   inv.lot_id           = tran.lot_id
    AND   inv.location         = tran.location
    AND   inv.lot_status       = sts.lot_status (+)
    AND   NVL(sts.shipping_ind,1) = 1
--    AND   NVL(sts.order_proc_ind,1)=1 PK Bug 3470116
    AND   NVL(sts.rejected_ind,0) = 0
    ;

/* Begin Enhancement 2320442 - Lakshmi Swamy */

   CURSOR New_txn_nonctl_CUR ( p_line_id  IN  NUMBER,
                               p_item_id  IN  NUMBER,
                               p_line_detail_id IN NUMBER) IS
   SELECT trans_id
        , trans_qty
        , trans_qty2
     FROM ic_tran_pnd
    WHERE  line_id        = p_line_id
    --  AND  item_id        = p_item_id                         -- REMOVED for bug 3403418
      AND  doc_type       = 'OMSO'
      AND  staged_ind     = 1
      AND  completed_ind  = 0
      AND  delete_mark    = 0
      AND  line_detail_id = p_line_detail_id;

  l_trans_id              NUMBER;
  d_trans_id               NUMBER;
  l_validation_level      VARCHAR2(4) := FND_API.G_VALID_LEVEL_FULL;
  l_available_qty         NUMBER;
  l_available_qty2        NUMBER;
  l_tran_row              IC_TRAN_PND%ROWTYPE;
  l_pick_slip_number      NUMBER;
  OM_G_installed          VARCHAR2(30);
  l_allow_negative_inv	  NUMBER; /* 2690711 */
/* End Enhancement 2320442 - Lakshmi Swamy */

  Cursor check_wsh IS
   SELECT object_name
     FROM user_objects
    WHERE object_name = 'WSH_USA_INV_PVT'
      AND object_type = 'PACKAGE BODY';

 BEGIN
   /*  Standard Start OF API savepoint */
    SAVEPOINT PICK_WAVE_CONFIRM;
    -- Begin Bug 3609713
    l_allowneginv := NVL(FND_PROFILE.VALUE('IC$ALLOWNEGINV'),0);
    --End Bug 3609713

   /*DBMS_OUTPUT.PUT_LINE('IN MOVE ORDER LINES');  */

   /*  Standard call to check for call compatibility. */

   IF NOT FND_API.Compatible_API_CALL
          (  l_api_version_number
           , p_api_version_number
           , l_api_name
           , G_PKG_NAME
           )
   THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   /*  Initialize message list if p_int_msg_lst is set TRUE. */

   IF FND_API.to_boolean(p_init_msg_lst)
     THEN
     FND_MSG_PUB.Initialize;
   END IF;

  /*  Initialize API return status to sucess */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  GMI_Reservation_Util.PrintLn('PICK_WAVE_CONFIRM PVT COUNT=> '||p_mo_line_tbl.COUNT);

  /*  Get System Constant For Default Location Value. */

    l_location:= FND_PROFILE.Value_Specific(
           name    => 'IC$DEFAULT_LOCT'
           , user_id => l_mo_line_rec.last_updated_by
           );

  FOR I in 1..p_mo_line_TBL.COUNT LOOP
    l_mo_line_rec := p_mo_line_tbl(I);
    GMI_RESERVATION_UTIL.PrintLn('Check Missing For  Row > '||  I );
    IF check_required( p_mo_line_rec => l_mo_line_rec) THEN
       WSH_Util_Core.PrintLn('Check Missing Falied ');
       FND_MESSAGE.SET_NAME('GMI','GMI_REQUIRED_MISSING');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

-- HW BUG#:2296620 call to check ship_sets
  l_manual_pick := p_manual_pick;

  gmi_reservation_util.println('Value of p_manual_pick is '||l_manual_pick);


  IF ( l_manual_pick = 'N') THEN
    gmi_reservation_util.println('Value of count is '||p_mo_line_TBL.COUNT);

gmi_reservation_util.println('Value of ship_Set id is '||   l_mo_line_rec.ship_set_id);
gmi_reservation_util.println('Value of l_mo_line_rec.quantity_detailed is '||l_mo_line_rec.quantity_Detailed);
    IF (l_mo_line_rec.ship_set_id IS NOT NULL ) THEN
       check_ship_set
        (
          p_ship_set_id               =>  l_mo_line_rec.ship_set_id
          ,p_manual_pick               =>  l_manual_pick
          ,x_return_status             =>  x_return_status
        );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_no_error := '0';
         IF ( x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
           RAISE l_warning;
         ELSE
           RAISE FND_API.G_EXC_ERROR;
         END IF;

       ELSE
         l_no_error :='1';
       END IF;  -- of error checking
     END IF;  -- of ship_Set_id

    ELSE
      l_no_error := '1';
    END IF; -- of manual_pick

-- HW BUG#:2296620
   IF ( l_no_error = '1' ) THEN

gmi_reservation_util.println('Going to pick confirm');


    /*  Need To check The Value Of detailed_qty */
    /*  And quantity_delivered. */
    /*  If they are Equal or Detailed is 0 Nothing needs to be done */
    /*  Should I exit Loop Or Raise an exception */

    /*IF ( l_mo_line_rec.quantity_delivered = l_mo_line_rec.quantity_detailed )
        OR ( l_mo_line_rec.quantity_detailed = 0) THEN
        FND_MESSAGE.SET_NAME('INV', 'INV_PICK_QTY_ERROR');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
    END IF; */

    /*  Get Process Item details */
    GMI_RESERVATION_UTIL.Get_OPM_item_from_Apps
    (
      p_organization_id          => l_mo_line_rec.organization_id
    , p_inventory_item_id        => l_mo_line_rec.inventory_item_id
    , x_ic_item_mst_rec          => l_ic_item_mst_rec
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
       FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
       FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.Get_OPM_item_from_Apps');
       FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    GMI_Reservation_Util.PrintLn('Item Found. Now Qty treatment');
    /*  Now Check Item Characteristics  */
    /*  HAM Does this logic cover all cases */
    /*  What about loct_ctl=1 and lot_ctl=0 or visa versa. */
    /*  Set quantity Fields to 0; */
    l_trans_qty  := 0;
    l_trans_qty2 := 0;
    l_organization_id := l_mo_line_rec.organization_id;
    Open get_whse_code;
    Fetch get_whse_code into l_whse_code, l_whse_ctl;
    Close get_whse_code;

    GMI_Reservation_Util.PrintLn('Item : lot_ctl='||l_ic_item_mst_rec.lot_ctl||', loct_ctl='||l_ic_item_mst_rec.loct_ctl);
    IF ( l_ic_item_mst_rec.lot_ctl <> 0 ) OR ( l_ic_item_mst_rec.loct_ctl * l_whse_ctl<> 0)
    THEN
       l_default_transaction :=0; /*  Do not Transact default Lot.  */
       /* get status ctl */
       Open get_status_ctl(p_item_id => l_ic_item_mst_rec.item_id);
       Fetch get_status_ctl INTO l_status_ctl;
       Close get_status_ctl;
       /*  Get TXN Quantities */
       OPEN cur_txn_no_default
                          ( p_line_id   => l_mo_line_rec.txn_source_line_id,
                            p_location   => l_location,
                            p_item_id    => l_ic_item_mst_rec.item_id
                           );

       FETCH cur_txn_no_default INTO l_trans_qty, l_trans_qty2;
       IF cur_txn_no_default%NOTFOUND THEN
          CLOSE cur_txn_no_default;
          GMI_Reservation_Util.PrintLn('txn_no_default : NOTFOUND ');
          FND_MESSAGE.SET_NAME('GMI','GMI_REQUIRED_MISSING');
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE cur_txn_no_default;
       l_trans_qty_sts := l_trans_qty;
       l_trans_qty2_sts := l_trans_qty2;
       IF nvl(l_status_ctl, 0) <> 0 THEN -- status ctl
         GMI_Reservation_Util.PrintLn('status controled');
         OPEN cur_txn_no_dflt_sts
                            ( p_line_id   => l_mo_line_rec.txn_source_line_id,
                              p_item_id    => l_ic_item_mst_rec.item_id,
                              p_mo_line_id   => l_mo_line_rec.line_id
                             );

         FETCH cur_txn_no_dflt_sts INTO l_trans_qty, l_trans_qty2;  -- this portion would be transacted
         IF cur_txn_no_dflt_sts%NOTFOUND THEN
            CLOSE cur_txn_no_dflt_sts;
            GMI_Reservation_Util.PrintLn('txn_no_default : NOTFOUND ');
            FND_MESSAGE.SET_NAME('GMI','GMI_REQUIRED_MISSING');
         END IF;
         CLOSE cur_txn_no_dflt_sts;
         GMI_Reservation_Util.PrintLn('trans_qty '||l_trans_qty ||' trans_qty2 '||l_trans_qty2 );
       END IF;
    ELSE /* not lot controled or location controled */
      l_default_transaction :=1; /*  Transact default Lot.          */
      /*  Get TXN Quantities */
      OPEN check_default_lot
              ( p_line_id   => l_mo_line_rec.txn_source_line_id,
                p_item_id   => l_ic_item_mst_rec.item_id
              );
      FETCH check_default_lot into l_msg_count;
      CLOSE check_default_lot;
      IF l_msg_count = 0 THEN
         GMI_Reservation_Util.PrintLn('txn_with_default : NOTFOUND ');
         /* if default is not found at this stage, user should still able to transact */
         /* the so line with the full qty*/
         /* this is also true for non inventory controled items*/
         /* the move order qtys are already in item_um1 and item_um2*/
         l_trans_qty := l_mo_line_rec.quantity;
         l_trans_qty2 := l_mo_line_rec.secondary_quantity;
         /*RAISE FND_API.G_EXC_ERROR; */
         /* create a default lot to avoid troubles in shipping */
         GMI_RESERVATION_UTIL.Create_dflt_lot_from_scratch
         (
            p_whse_code    => l_whse_code
          , p_line_id      => l_mo_line_rec.txn_source_line_id
          , p_item_id      => l_ic_item_mst_rec.item_id
          , p_qty1         => l_mo_line_rec.quantity
          , p_qty2         => l_mo_line_rec.secondary_quantity
          , x_return_status            => l_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
         THEN
            FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
            FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.create_dflt_lot_from_scratch');
            FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         OPEN cur_txn_with_default
               ( p_line_id   => l_mo_line_rec.txn_source_line_id,
                 p_item_id   => l_ic_item_mst_rec.item_id
                );
         FETCH cur_txn_with_default INTO l_trans_qty, l_trans_qty2;
         CLOSE cur_txn_with_default;
      END IF;
    END IF;

    /*  Now Set delivered Quantities */
    GMI_Reservation_Util.PrintLn('Now Set the delivered Quantities');
    l_mo_line_rec.quantity_delivered := NVL(l_mo_line_rec.quantity_delivered,0)
                                           + NVL(l_trans_qty,0);

    /*  Ham May Need To Add Logic To Save As NULL not 0 */
    /*  NOTE NULL + anything = NULL; */
    l_mo_line_rec.secondary_quantity_delivered := NVL(l_mo_line_rec.secondary_quantity_delivered, 0)
                                                                 + NVL(l_trans_qty2,0);

    -- Bug 1777799, odaboval Added this test for populating detailed_qty:
    IF (NVL(l_mo_line_rec.quantity_detailed, 0) = 0)
    THEN
        l_mo_line_rec.quantity_detailed := l_mo_line_rec.quantity_delivered;
        l_mo_line_rec.secondary_quantity_detailed := l_mo_line_rec.secondary_quantity_delivered;
    END IF;

    /*  If default Lot is really the actual lot */
    /*  Then unless you pick confirm everything */
    /*  Then throw an ERROR: */

    GMI_Reservation_Util.PrintLn('default_transaction='||l_default_transaction);
    GMI_Reservation_Util.PrintLn('qty_delivered='||l_mo_line_rec.quantity_delivered||', qty_delivered2='||l_mo_line_rec.secondary_quantity_delivered);
    GMI_Reservation_Util.PrintLn('qty='||l_mo_line_rec.quantity);

    /*  Set Status Of Mo_line_rec To Closed if Fully delivered */
    /*  requsted qty . */

    IF l_mo_line_rec.quantity_delivered >= l_mo_line_rec.quantity THEN
       /* check over shipment tolerance */
          -- for non ctl items, no allocation is made but the default trans
          -- qty is updated by the system, can not be over allocating
       IF (l_mo_line_rec.quantity_delivered > l_mo_line_rec.quantity )
          AND (l_default_transaction <> 1) THEN
          GMI_Pick_Wave_Confirm_PVT.Check_Shipping_Tolerances
            (  x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data,
               x_allowed             => l_allowed,
               x_max_quantity        => l_max_qty,
               x_max_quantity2       => l_max_qty2,
               p_line_id             => l_mo_line_rec.line_id,
               p_quantity            => l_trans_qty,
               p_quantity2           => l_trans_qty2
           );
          IF x_return_status  <> 'S' THEN
            fnd_message.set_name('INV', 'INV_CHECK_TOLERANCE_ERROR');
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            IF l_allowed = 'N' THEN
              GMI_Reservation_Util.PrintLn('ATTENTION :');
              GMI_Reservation_Util.PrintLn('MOVE ORDER line : line_id ='||l_mo_line_rec.line_id ||
                            ' can not be transacted because picked qty exceeds over shippment tolerance. '||
                            ' The allocated quantity is '|| l_trans_qty ||' but the max allowed quantity is'||
                            l_max_qty || ' Please reduce allocation quantity ');

              /* NC Bug #2557029 */
  	      FND_MESSAGE.SET_NAME('GMI','GMI_API_OVER_SHIP_TOLERANCE');
              FND_MESSAGE.SET_TOKEN('QUANTITY1',to_char(l_trans_qty));
              FND_MESSAGE.SET_TOKEN('QUANTITY2',to_char(l_max_qty));
              FND_MESSAGE.SET_TOKEN('LINE_ID',l_mo_line_rec.line_id);
              GMI_PICK_CONFIRM_PUB.PrintMsg('ERROR: MOVE ORDER line : line_id ='||l_mo_line_rec.line_id ||
                                ' can not be transacted because picked qty exceeds over shippment tolerance. '||
                                'The allocated quantity is '|| l_trans_qty ||' but the max allowed quantity is'||
                                        l_max_qty || ' Please reduce allocation quantity ');
              FND_MSG_PUB.Add;
              l_tolerance_flag := 1;
              /* NC End of Bug #2557029 */

              goto next_line;
            END IF ;
          END IF;
       END IF;
       l_mo_line_rec.line_status :=5;
    END IF;

    /*  Update Move Order Line record */
    GMI_Reservation_Util.PrintLn('Now, update the MO row');
    GMI_MOVE_ORDER_LINE_UTIL.Update_ROW(p_mo_line_rec => l_mo_line_rec);


    /* Bug 2499153 */
    /* check to see if WSH G is installed, the file WSHUSAIB.pls is newly introduced in G
       so checking if the object exists or not would do*/

    OPEN  check_wsh;
    FETCH check_wsh INTO OM_G_installed;
    IF (check_wsh%NOTFOUND) THEN
      OM_G_installed := NULL;
      GMI_Reservation_Util.PrintLn('OM_G_installed not found');
    END IF;
    GMI_Reservation_Util.PrintLn('OM_G_installed ' || OM_G_installed);
    CLOSE check_wsh;

    /*  Set Up status Flag */
    if (l_mo_line_rec.quantity_delivered < l_mo_line_rec.quantity )
    THEN
         if l_default_transaction = 0  THEN
            l_action_flag := 'M';
         else
            l_action_flag := 'S'; /* Should Never Happen */
         end if;
    ELSE
         if l_default_transaction = 0  THEN
            l_action_flag := 'M';
         else
           if (l_ic_item_mst_rec.noninv_ind = 1) then
            l_action_flag := 'U';
           else
            if (OM_G_installed is NOT NULL) THEN  -- Condition introduced for bug2499153
              l_action_flag := 'M';  /* Enhancement 2320442 - Changed from U to M */
            else
              l_action_flag := 'U';
            end if;
           end if;
         end if;
    END IF;

    GMI_Reservation_Util.PrintLn('Action Flag is '||l_action_flag);
    /*  Save The SUM Of the transaction QTY's This May Be Used */
    /*  Further In The Code ...... */

    l_sum_trans_qty   := l_trans_qty;
    l_sum_trans_qty2  := l_trans_qty2;

    /*  Now Let  Build shipping API record */
    GMI_Reservation_Util.PrintLn('Now, Let us Build shipping API record');
    /*  Maybe i should set context switch to get correct Org. */

    -- Bug 1805216, added NOT NULL in the cursor.
    /*SELECT a.delivery_detail_id, a.oe_header_id, a.oe_line_id
          , b.order_quantity_uom
    INTO l_delivery_detail_id
        , l_source_header_id
        , l_source_line_id
        , l_order_quantity_uom
    FROM   oe_order_lines_all b
          , wsh_inv_delivery_details_v a
    WHERE  a.move_order_line_id = l_mo_line_rec.line_id
    AND    a.move_order_line_id IS NOT NULL
    AND    a.oe_line_id = b.line_id
    AND    a.released_status = 'S';*/
    FOR delivery IN get_delivery LOOP /* there could be more than 1 del for the same mo line*/
      l_delivery_detail_id := delivery.delivery_detail_id;
      l_source_header_id   := delivery.source_header_id;
      l_source_line_id     := delivery.source_line_id;
      l_requested_qty      := delivery.requested_quantity;
      l_requested_qty2     := delivery.requested_quantity2;

      /* if p_delivery_detail_id is passed, meaning only transact this delivery, Loop would stop*/
      IF p_delivery_detail_id is not null AND p_delivery_detail_id <> l_delivery_detail_id THEN
        /* go to next record */
        goto del_loop_end;
      END IF;

      --
      -- Bug 3776538 - Transaction quantities should be truncated to 5 decimals upfront
      --
      l_ALLOW_OPM_TRUNCATE_TXN := nvl(fnd_profile.value ('ALLOW_OPM_TRUNCATE_TXN'),'N');
      GMI_Reservation_Util.PrintLn('(GMIVPWCB)Profile: ALLOW_OPM_TRUNCATE_TXN '||l_ALLOW_OPM_TRUNCATE_TXN);
      IF (l_ALLOW_OPM_TRUNCATE_TXN = 'Y') THEN
         GMI_Reservation_Util.PrintLn('Truncating the transaction quantities before TRANSACT');
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         truncate_trans_qty (p_line_id            => l_mo_line_rec.txn_source_line_id,
                             p_delivery_detail_id => l_delivery_detail_id,
                             p_default_location   => l_location,
                             is_lot_loct_ctl      => TRUE,
                             x_return_status      => l_return_status);
         --
         -- Fail the pick confirm process if exception occured during truncation of transactions
         --
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
            FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.truncate_trans_qty');
            FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      -- End 3776538

      IF  l_default_transaction = 0 THEN /* lot or loct controled */
           /* get total trans_qtys for this del */
        Open qty_sum_for_del;
        Fetch qty_sum_for_del INTO l_sum_trans_qty, l_sum_trans_qty2;
        Close qty_sum_for_del ;
        l_trans_qty := l_sum_trans_qty;
        l_trans_qty2 := l_sum_trans_qty2;
        l_trans_qty_sts := l_trans_qty;
        l_trans_qty2_sts := l_trans_qty2;
        gmi_reservation_util.println('qty_sum_for_del l_trans_qty '||l_trans_qty);
        gmi_reservation_util.println('qty_sum_for_del l_trans_qty2 '||l_trans_qty2);

        l_backorder_del := 0;
        IF nvl(l_status_ctl, 0) <> 0 THEN -- status ctl
           Open qty_sum_for_del_sts;
           Fetch qty_sum_for_del_sts INTO l_sum_trans_qty, l_sum_trans_qty2;
           Close qty_sum_for_del_sts ;
           l_trans_qty := nvl(l_sum_trans_qty,0);
           l_trans_qty2 := nvl(l_sum_trans_qty2,0);
           gmi_reservation_util.println('qty_sum_for_del_sts l_trans_qty '||l_trans_qty);
           gmi_reservation_util.println('qty_sum_for_del_sts l_trans_qty2 '||l_trans_qty2);
           IF (l_trans_qty_sts > l_trans_qty ) THEN -- lots allocated, but may not be transactable
              gmi_reservation_util.println('lots allocated, but may not be transactable ');
              l_backorder_del := 1;
           END IF;
        END IF;
      END IF;

      l_shipping_attr(1).source_header_id := l_source_header_id;
      l_shipping_attr(1).source_line_id := l_source_line_id;
      l_shipping_attr(1).subinventory := l_mo_line_rec.to_subinventory_code;
      l_shipping_attr(1).released_status := 'Y';
      l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;

      GMI_Reservation_Util.PrintLn('Shipping Values : source_header_id='||l_shipping_attr(1).source_header_id);
      GMI_Reservation_Util.PrintLn('Shipping Values : source_line_id='||l_shipping_attr(1).source_line_id);
      GMI_Reservation_Util.PrintLn('Shipping Values : delivery_detail_id='||l_shipping_attr(1).delivery_detail_id);

      l_shipping_attr(1).preferred_grade   := l_mo_line_rec.qc_grade;
      l_shipping_attr(1).lot_number        := NULL;
     -- l_shipping_attr(1).sublot_number     := NULL; /*Commented for R12. P1 Bug#4561095 */
      l_shipping_attr(1).locator_id        := NULL;
      l_shipping_attr(1).ship_from_org_id  := l_mo_line_rec.organization_id;
      l_shipping_attr(1).action_flag       := l_action_flag;

      IF  l_default_transaction = 0 THEN /* lot or loct controled */
        GMI_Reservation_Util.PrintLn('before getting transaction, line_id='||l_mo_line_rec.txn_source_line_id
           ||', location='||l_location||', item_id='||l_ic_item_mst_rec.item_id);
        OPEN mo_line_txn_c ( p_line_id    => l_mo_line_rec.txn_source_line_id,
                                p_location   => l_location,
                                p_item_id    => l_ic_item_mst_rec.item_id,
                                p_delivery_detail_id =>l_delivery_detail_id
                              );
        GMI_Reservation_Util.PrintLn('After Call to mo_line_txn_c');


        /* Bug2621228 - Following assignments made */
        l_sum_trans_qty  := GREATEST (l_sum_trans_qty, l_requested_qty);
        IF (l_requested_qty >  l_sum_trans_qty) THEN
           l_sum_trans_qty2 :=  l_requested_qty2;
        END IF;

        LOOP
          FETCH mo_line_txn_c into l_mo_line_txn_rec;
              EXIT when mo_line_txn_c%NOTFOUND;

          GMI_Reservation_Util.PrintLn('a transaction is found : trans_id='||l_mo_line_txn_rec.trans_id);

          GMI_Reservation_Util.PrintLn('Trans id = '||l_mo_line_txn_rec.trans_id);
          GMI_Reservation_Util.PrintLn('lot_no   = '||l_mo_line_txn_rec.lot_no);
          GMI_Reservation_Util.PrintLn('lot_id   = '||l_mo_line_txn_rec.lot_id);
          GMI_Reservation_Util.PrintLn('sublot_no= '||l_mo_line_txn_rec.sublot_no);
          GMI_Reservation_Util.PrintLn('Grade    = '||l_mo_line_txn_rec.qc_grade);
          GMI_Reservation_Util.PrintLn('trans_qty= '||l_mo_line_txn_rec.trans_qty);
          GMI_Reservation_Util.PrintLn('qty2     = '||l_mo_line_txn_rec.trans_qty2);
          GMI_Reservation_Util.PrintLn('locator  = '||l_mo_line_txn_rec.locator_id);
          /* check the status to see it is transactable */
          GMI_Reservation_Util.PrintLn('check status  = '||l_mo_line_txn_rec.locator_id);
          /* for non status ctl item, no check */
          l_orderable_ind := 1;
          l_shipable_ind  := 1;
          IF nvl(l_status_ctl,0) <> 0 THEN
              Open check_lot_sts(
                      p_item_id    => l_ic_item_mst_rec.item_id,
                      p_whse_code  => l_whse_code,
                      p_lot_id     => l_mo_line_txn_rec.lot_id,
                      p_location   => l_mo_line_txn_rec.location
                      );
              Fetch check_lot_sts INTO l_orderable_ind, l_shipable_ind;
              Close check_lot_sts;
          END IF;

          GMI_Reservation_Util.PrintLn('orderable status ind : '||l_orderable_ind);
          GMI_Reservation_Util.PrintLn('shipable  status ind : '||l_shipable_ind);

          -- Begin Bug 3609713
          GMI_Reservation_Util.PrintLn(' Lot_ctl '||l_ic_item_mst_rec.lot_ctl);
          GMI_Reservation_Util.PrintLn(' Allow negative Inventory : '||l_allowneginv);

          -- Bug 3859774
          -- If inventory is not allowed to go -ve and the lots are shippable!
          --
          IF (l_allowneginv <> 1 AND NVL(l_shipable_ind, 0) <> 0)  THEN
            OPEN check_onhand_qty(
                      p_item_id    => l_ic_item_mst_rec.item_id,
                      p_whse_code  => l_whse_code,
                      p_lot_id     => l_mo_line_txn_rec.lot_id,
                      p_location   => l_mo_line_txn_rec.location
                      );
            FETCH check_onhand_qty INTO l_onhand1, l_onhand2;
            IF check_onhand_qty%NOTFOUND THEN
               l_onhand1 := 0;
               l_onhand2 := 0;
            END IF;
            CLOSE check_onhand_qty;
            GMI_Reservation_Util.PrintLn('Onhand  for lot : '||l_onhand1);
            GMI_Reservation_Util.PrintLn('Onhand2 for lot : '||l_onhand2);

            OPEN check_staged(
                      p_item_id    => l_ic_item_mst_rec.item_id,
                      p_whse_code  => l_whse_code,
                      p_lot_id     => l_mo_line_txn_rec.lot_id,
                      p_location   => l_mo_line_txn_rec.location
                      );
            FETCH check_staged INTO l_alloc1, l_alloc2;
            CLOSE check_staged;
            GMI_Reservation_Util.PrintLn('allocated  for lot : '||l_alloc1);
            GMI_Reservation_Util.PrintLn('allocated2 for lot : '||l_alloc2);
            -- Bug 3859774
            -- ONLY primary allocations should be compared with primary available.
            --
            IF ((l_onhand1 + l_alloc1) < ABS(l_mo_line_txn_rec.trans_qty)) THEN
              GMI_Reservation_Util.PrintLn(' Inventory checked : Going negative !');
              l_inv_negative := 1;
            ELSE
              GMI_Reservation_Util.PrintLn(' Inventory checked : Not going negative ');
              l_inv_negative := 0;
            END IF;
          ELSE -- of (l_allowneginv <> 1 AND nvl(l_shipable_ind, 0) <> 0)
            GMI_Reservation_Util.PrintLn(' Item Not lot controlled or Negative inventory Allowed OR ... ');
            GMI_Reservation_Util.PrintLn(' ... Negative Inventory not checked since lot is not shipable ');
            l_inv_negative := 0;
          END IF;

          IF (( nvl(l_shipable_ind, 0)) <> 0
              AND (l_inv_negative = 0)) THEN -- transact if both orderable and shipable PK Bug 3470116 use only shipping

          -- End Bug 3609713

            /* NC Added trans_id Bug#1675561 */
            l_shipping_attr(1).trans_id         := l_mo_line_txn_rec.trans_id;
            l_shipping_attr(1).lot_number       := l_mo_line_txn_rec.lot_no;
            --l_shipping_attr(1).sublot_number    := l_mo_line_txn_rec.sublot_no; /* R12 P1 Bug#4561095 */
            l_shipping_attr(1).preferred_grade  := l_mo_line_txn_rec.qc_grade;
            l_shipping_attr(1).locator_id       := l_mo_line_txn_rec.locator_id;
            l_return_status := '';
            l_shipping_attr(1).ordered_quantity  := l_mo_line_txn_rec.trans_qty;
            l_shipping_attr(1).ordered_quantity2 := l_mo_line_txn_rec.trans_qty2;

            GMI_Reservation_Util.PrintLn('total trans qty  = '||l_trans_qty);
            GMI_Reservation_Util.PrintLn('total requested qty  = '||l_requested_qty);


            /* overpicking changes */
            /* Bug 2621228 - Logic below is changed to populate picked/pending quantity in post G scenario */

            IF (l_trans_qty > l_requested_qty AND OM_G_installed IS NULL ) OR   -- Pre G with over picking
               (OM_G_installed IS NOT NULL)                                THEN -- Post G code -- always populate the picked and pending qtys
               l_shipping_attr(1).picked_quantity  := l_mo_line_txn_rec.trans_qty;
               l_shipping_attr(1).picked_quantity2 := l_mo_line_txn_rec.trans_qty2;

               l_shipping_attr(1).pending_quantity  := nvl(l_sum_trans_qty,0) - nvl(l_mo_line_txn_rec.trans_qty,0);
               l_shipping_attr(1).pending_quantity2 := nvl(l_sum_trans_qty2,0) - nvl(l_mo_line_txn_rec.trans_qty2,0);

               l_sum_trans_qty  := l_sum_trans_qty  - l_shipping_attr(1).picked_quantity;
               l_sum_trans_qty2 := l_sum_trans_qty2 - l_shipping_attr(1).picked_quantity2;

               IF l_shipping_attr(1).pending_quantity < 0 THEN
                  l_shipping_attr(1).pending_quantity := 0;
                  l_shipping_attr(1).pending_quantity2 := 0;
               End IF;
            END IF;

            /* End bug 2621228  */
            /* end of over pick */

            GMI_Reservation_Util.PrintLn('Before Calling the Update_Shipping_Attributes trans_id='||l_mo_line_txn_rec.trans_id);

            -- Bug 3776538
            dump_shp_attrb_data(p_shipping_attr => l_shipping_attr);

            WSH_INTERFACE.Update_Shipping_Attributes
                     (p_source_code               => 'INV',
                      p_changed_attributes        => l_shipping_attr,
                      x_return_status             => l_return_status
                     );
            GMI_Reservation_Util.PrintLn('Return Status from [1] Update_Shipping_Attributes Call '||l_return_status);

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
               THEN
                  FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
                  FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.call_to_WSH_interface');
                  FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

            /*  Now Update staged_ind in transaction record from 0 to 1 */
            /*  HAM Will Have to be More Selective */
            /*  On Update i.e lot_id, qc_grade, locator_id, */
            /*  NC added delivery_detail_id  and staged_ind in the where clause */
            /*  -- BUG#1675561*/

            UPDATE ic_tran_pnd    -- NOT NEEDED
            SET    staged_ind =1
       	           --line_detail_id = l_shipping_attr(1).delivery_detail_id
            WHERE  trans_id = l_mo_line_txn_rec.trans_id AND
                   staged_ind <> 1 and delete_mark <> 1;


            /* Setting the pick slip number  - Bug2455422 */

            GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip (l_mo_line_rec.organization_id , l_mo_line_rec.line_id,
                             x_return_status, x_msg_count, x_msg_data, l_pick_slip_number);
            GMI_reservation_Util.PrintLn('pick slip number is '|| l_pick_slip_number);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
              GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_lots: Error returned by GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip.', 'pick_lots.log');
              FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip');
              FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            UPDATE ic_tran_pnd
               SET pick_slip_number = l_pick_slip_number
             WHERE trans_id = l_mo_line_txn_rec.trans_id;

            /* End of Setting the pick slip number  - Bug2455422 */


            GMI_Reservation_Util.PrintLn('Before Loop 1');
          -- Begin Bug 3609713
          ELSIF (nvl(l_shipable_ind, 0) = 0) THEN
            GMI_Reservation_Util.PrintLn('LOTs not transactable for Status ');
            l_mo_line_rec.line_status :=7;
            GMI_Reservation_Util.PrintLn('Updating mo line status to OPEN- lot status');
            GMI_MOVE_ORDER_LINE_UTIL.Update_ROW(p_mo_line_rec => l_mo_line_rec);
          ELSE
            GMI_Reservation_Util.PrintLn('LOTs not transactable for Negative Inventory ');
            l_mo_line_rec.line_status :=7;
            l_mo_line_rec.quantity_delivered := NVL(l_mo_line_rec.quantity_delivered,0)
                                                 - l_mo_line_txn_rec.trans_qty;
            l_mo_line_rec.secondary_quantity_delivered := NVL(l_mo_line_rec.secondary_quantity_delivered, 0)
                                                                 - NVL(l_mo_line_txn_rec.trans_qty2,0);

            GMI_Reservation_Util.PrintLn('Updating mo line status to OPEN- Negative Inventory');
            GMI_MOVE_ORDER_LINE_UTIL.Update_ROW(p_mo_line_rec => l_mo_line_rec);
          -- End Bug 3609713
          END IF;
        END LOOP;
        CLOSE mo_line_txn_c; /*2423869*/

        /* HW BUG#:1941429OPM cross docking --  find out backorder qtys */
        --IF (l_mo_line_rec.quantity_delivered < l_mo_line_rec.quantity ) THEN
        /* if picked less, back order */
        gmi_reservation_util.println('l_trans_qty '||l_trans_qty);
        gmi_reservation_util.println('l_requested_qty '||l_requested_qty);

        -- Bug 3776538
        gmi_reservation_util.println('Remaining qty '|| (l_requested_qty - l_trans_qty));
        IF (l_trans_qty < l_requested_qty OR l_backorder_del = 1 ) THEN
           gmi_reservation_util.println('Qtys are not same. so need to mark line as a backorder');
           gmi_reservation_util.println('Value of l_mo_line_rec.quantity_delivered is '||l_mo_line_rec.quantity_delivered);
           gmi_reservation_util.println('Value of l_mo_line_rec.quantity is '||l_mo_line_rec.quantity);
           gmi_reservation_util.println('Value of l_mo_line_rec.status is '||l_mo_line_rec.line_status);
           /* find out the remaining delivery  */
           /* Bug2621228 - l_sum_trans_qty replaced by l_trans_qty */
           l_backorder_qty  := l_requested_qty -  l_trans_qty;
           l_backorder_qty2 := l_requested_qty2 - l_trans_qty2;
           GMI_Reservation_Util.PrintLn('backordering in pickconfirm  ');
           GMI_Reservation_Util.PrintLn('backorder qty = '|| l_backorder_qty);
           GMI_Reservation_Util.PrintLn('backorder qty2 = '|| l_backorder_qty2);
           l_shipping_attr(1).preferred_grade         := NULL;
           l_shipping_attr(1).lot_number              := NULL;
           --l_shipping_attr(1).sublot_number           := NULL; /* R12 P1 Bug#4561095 */
           l_shipping_attr(1).locator_id              := NULL;
           l_shipping_attr(1).subinventory            := NULL;
           l_shipping_attr(1).action_flag             := 'B';
           l_shipping_attr(1).cycle_count_quantity    := l_backorder_qty;
           l_shipping_attr(1).cycle_count_quantity2   := l_backorder_qty2;
           l_shipping_attr(1).released_status         := '';
           l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;
           GMI_Reservation_Util.PrintLn('backordering Update_Shipping_Attributes delivery_detail_id= '
                 ||l_delivery_detail_id);

           -- Bug 3776538
           dump_shp_attrb_data(p_shipping_attr => l_shipping_attr);

           WSH_INTERFACE.Update_Shipping_Attributes
                    (p_source_code               => 'INV',
                     p_changed_attributes        => l_shipping_attr,
                     x_return_status             => l_return_status
                    );
           GMI_Reservation_Util.PrintLn('Return Status from [2] Update_Shipping_Attributes Call '||l_return_status);

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
              FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
              FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.call_to_WSH_interface');
              FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);
              RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
         /* HW end of bug #:1941429 */
      ELSE   /* non lot or loct controled */

           IF (OM_G_installed is  NULL) THEN
               GMI_Reservation_Util.PrintLn('Working with Default lot - Pre G scenario');
               l_return_status := '';

               -- Bug 3776538
               dump_shp_attrb_data(p_shipping_attr => l_shipping_attr);

               WSH_INTERFACE.Update_Shipping_Attributes
                  (p_source_code               => 'INV',
                   p_changed_attributes        => l_shipping_attr,
                   x_return_status             => l_return_status
                   );
               GMI_Reservation_Util.PrintLn('Return Status from [3] Update_Shipping_Attributes Call '||l_return_status);

           ELSE

             GMI_Reservation_Util.PrintLn('Working with Default lot - Post G scenario');
            /*  Just Working with default lot */
            /* Begin Enhancement 2320442 - Lakshmi Swamy */

            /*  Bug 2462993 */

-- HAW 3387829 Commented some unnecessary calls and
-- some code is now shared between non-inventory amd
-- non-lot control items

/*             IF (l_ic_item_mst_rec.noninv_ind = 1) THEN
               GMI_Reservation_Util.PrintLn('Just Working with noninventory item');
               GMI_Reservation_Util.PrintLn('Delivery detail id '||l_shipping_attr(1).delivery_detail_id);
               l_return_status := '';
*/

/* HAW  3387829 */
-- Since Non-Inv and Non-Lot are executing the same procedure:
--- GMI_PICK_WAVE_CONFIRM_PVT.BALANCE_NONCTL_INV_TRAN, let's call it once for
-- both of them and call New_txn_nonctl_CUR as well.
-- Earlier there was no call to New_txn_nonctl_CUR for non-inventory items
-- and trans_id was never popualated which caused the issue reported in
-- bug 3387829

               /* Bug 2901317 - Treating non-inventory as non-controlled item */
             gmi_reservation_util.println('Calling GMI_PICK_WAVE_CONFIRM_PVT.BALANCE_NONCTL_INV_TRAN');
             GMI_PICK_WAVE_CONFIRM_PVT.BALANCE_NONCTL_INV_TRAN
                (
                  p_mo_line_rec            => l_mo_line_rec ,
                  p_commit                 => p_commit,
                  p_item_id                => l_ic_item_mst_rec.item_id,
                  p_whse_code              => l_whse_code,
                  p_requested_qty          => l_requested_qty,
                  p_requested_qty2         => l_requested_qty2,
                  p_delivery_detail_id     => l_delivery_detail_id,
                  x_available_qty          => l_available_qty,
                  x_available_qty2         => l_available_qty2,
                  x_tran_row               => l_tran_row,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data
                );
               /* End bug 2901317 */

             OPEN New_txn_nonctl_CUR ( l_mo_line_rec.txn_source_line_id,
                                      l_ic_item_mst_rec.item_id,l_delivery_detail_id);
             FETCH New_txn_nonctl_CUR INTO l_trans_id, l_trans_qty, l_trans_qty2;
             IF  (New_txn_nonctl_CUR%NOTFOUND) THEN
                 l_trans_qty := 0;
             END IF;
             CLOSE  New_txn_nonctl_CUR;

             /* End Bug 2462993 */

             IF (l_trans_qty <> 0) THEN
                 l_shipping_attr(1).preferred_grade         := NULL;
                 l_shipping_attr(1).lot_number              := NULL;
                -- l_shipping_attr(1).sublot_number           := NULL; /* R12 P1 Bug#4561095*/
                 l_shipping_attr(1).locator_id              := NULL;
                 l_return_status := '';
                 l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;
                 l_shipping_attr(1).released_status := 'Y';
                 l_shipping_attr(1).trans_id        :=  l_trans_id;
                 l_shipping_attr(1).ordered_quantity:=  (-1) * l_trans_qty;
                 l_shipping_attr(1).ordered_quantity2:= (-1) * l_trans_qty2;
                 l_shipping_attr(1).subinventory     := l_mo_line_rec.to_subinventory_code;

                 /* Begin bug 2621228 - picked/pending quantity populated for nonctl items */
                 l_shipping_attr(1).picked_quantity  := (-1) *  l_trans_qty;
                 l_shipping_attr(1).picked_quantity2 := (-1) *  l_trans_qty2;
                 /* l_available_qty below is same as l_trans_qty */
                 IF (l_available_qty < l_requested_qty ) THEN
                   l_shipping_attr(1).pending_quantity   :=  l_requested_qty  - l_available_qty;
                   l_shipping_attr(1).pending_quantity2  :=  l_requested_qty2 - l_available_qty2;
                 ELSE
                   l_shipping_attr(1).pending_quantity  := 0;
                   l_shipping_attr(1).pending_quantity2 := 0;
                 END IF;
                 /* End Bug 2621228 */

                 GMI_Reservation_Util.PrintLn('Shiping values Action flag '|| l_shipping_attr(1).action_flag);
                 GMI_Reservation_Util.PrintLn('Shipping values Ordered qty '||l_shipping_attr(1).ordered_quantity);
                 GMI_Reservation_Util.PrintLn('l_available_qty1 '|| l_available_qty);
                 GMI_Reservation_Util.PrintLn('l_requested_qty  '||l_requested_qty);

                 -- Bug 3776538
                 dump_shp_attrb_data(p_shipping_attr => l_shipping_attr);

                 WSH_INTERFACE.Update_Shipping_Attributes
                    (p_source_code               => 'INV',
                     p_changed_attributes        => l_shipping_attr,
                     x_return_status             => l_return_status
                    );

                GMI_Reservation_Util.PrintLn('Return Status from [4] Update_Shipping_Attributes Call '||l_return_status);

               /* Begin Bug2936797 - Nulling out pick slip number on default Lot */

-- HAW 3387829. There is a difference between non-lot and non-inventory
-- Let's keep the original call to find_default_lot for non-lot items

/* HAW added the if condition to deal with non-lot control items*/
                 IF (l_ic_item_mst_rec.noninv_ind <> 1)THEN
                    GMI_Reservation_Util.PrintLn('Working with noncontrolled inventory item - Post G');
                    GMI_Reservation_Util.PrintLn('Calling GMI_RESERVATION_UTIL.find_default_lot - Post G for l_mo_line_rec.txn_source_line_id'||l_mo_line_rec.txn_source_line_id);
                    GMI_RESERVATION_UTIL.find_default_lot
                     (  x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_reservation_id    => d_trans_id,
                        p_line_id           => l_mo_line_rec.txn_source_line_id
                     );
                    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                       GMI_RESERVATION_UTIL.println('Error returned by find default lot');
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    IF (d_trans_id is NOT NULL) THEN
                      UPDATE ic_tran_pnd
                      SET pick_slip_number = NULL
                      WHERE trans_id = d_trans_id;
                    END IF;
                   /* End Bug2936797 */

                 END IF;

                 IF (l_available_qty < l_requested_qty )  THEN
                   l_shipping_attr(1).trans_id                := l_tran_row.trans_id;
                   l_shipping_attr(1).subinventory            := NULL;
                   l_shipping_attr(1).action_flag             := 'B';
                   l_shipping_attr(1).cycle_count_quantity    := l_requested_qty  - l_available_qty;
                   l_shipping_attr(1).cycle_count_quantity2   := l_requested_qty2  - l_available_qty2;
                   l_shipping_attr(1).released_status         := '';
                   l_return_status := '';

                   GMI_Reservation_Util.PrintLn('Shipping values cycle count quantity '||l_shipping_attr(1).cycle_count_quantity);

                   -- Bug 3776538
                   dump_shp_attrb_data(p_shipping_attr => l_shipping_attr);

                   WSH_INTERFACE.Update_Shipping_Attributes
                     (p_source_code               => 'INV',
                      p_changed_attributes        => l_shipping_attr,
                      x_return_status             => l_return_status
                      );
                   GMI_Reservation_Util.PrintLn('Return Status from [5] Update_Shipping_Attributes Call '||l_return_status);



                 END IF; -- of l_available_qty < l_requested_qty
             END IF;     -- of l_trans_qty <> 0
           END IF;       -- OM_G_installed */
      END IF;            -- non lot or loct controled
      <<del_loop_end>>
      null;
    END LOOP; /* delivery loop */


    /* End Enhancement 2320442 - Lakshmi Swamy */
    /* should also close this move order line ,if no more delivery left (no 'S')*/

    IF l_mo_line_rec.quantity_delivered < l_mo_line_rec.quantity THEN
        Select count(*)
        INTO l_count
        From wsh_delivery_details
        Where move_order_line_id = l_mo_line_rec.line_id
           And source_line_id = l_mo_line_rec.txn_source_line_id
           And released_status = 'S';
        IF l_count = 0 THEN
          l_mo_line_rec.line_status :=5;
          l_mo_line_rec.quantity := l_mo_line_rec.quantity_detailed;
          GMI_Reservation_Util.PrintLn('Now, update the MO row');
          GMI_MOVE_ORDER_LINE_UTIL.Update_ROW(p_mo_line_rec => l_mo_line_rec);
        END IF;
    END IF;

     <<NEXT_LINE>>
     l_mo_line_tbl(I) := l_mo_line_rec;
     x_return_status  := l_return_status;

     GMI_Reservation_Util.PrintLn('Before Loop 2');
     null;
    END IF; -- HW of l_no_error =1  for BUG:2296620
  END LOOP; /* mo line tbl loop */


  /*  Load Output table */

  x_mo_line_tbl := l_mo_line_tbl;
  WSH_Util_Core.PrintLn('Count MOL Table => '|| x_mo_line_tbl.COUNT);
  IF( l_warning_flag = 1 ) THEN
     RAISE l_warning;
  END IF;

  IF( l_tolerance_flag = 1 ) THEN
     RAISE l_tolerance_warning;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PICK_WAVE_CONFIRM;
      -- Bug 3859774
      IF (mo_line_txn_c%ISOPEN) THEN
         CLOSE mo_line_txn_c;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO PICK_WAVE_CONFIRM;
      x_return_status := fnd_api.g_ret_sts_unexp_error;


   FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                                  ,l_api_name
                                 );

-- HW BUG#:2296620
   WHEN l_warning THEN
    ROLLBACK TO PICK_WAVE_CONFIRM;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
-- HW end of 2296620

   /* NC Bug #2557029 */
   WHEN l_tolerance_warning THEN
     x_return_status := 'X';
   /* NC end of Bug #2557029 */

   WHEN OTHERS THEN
   ROLLBACK TO PICK_WAVE_CONFIRM;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                                  ,l_api_name
                                 );


      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );



END PICK_CONFIRM;

FUNCTION check_required
 (
  p_mo_line_rec        IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
 )
 RETURN BOOLEAN
 IS
BEGIN

  WSH_Util_Core.PrintLn('header id ==> '||p_mo_line_rec.header_id);
  WSH_Util_Core.PrintLn('line num  ==> '||p_mo_line_rec.line_number);
  WSH_Util_Core.PrintLn('org id    ==> '||p_mo_line_rec.organization_id);
  WSH_Util_Core.PrintLn('Item id   ==> '||p_mo_line_rec.inventory_item_id);
  WSH_Util_Core.PrintLn('uom code  ==> '||p_mo_line_rec.uom_code);
  WSH_Util_Core.PrintLn('quantity  ==> '||p_mo_line_rec.quantity);
  WSH_Util_Core.PrintLn('status    ==> '||p_mo_line_rec.line_status);
  WSH_Util_Core.PrintLn('trans id  ==> '||p_mo_line_rec.transaction_type_id);

    IF  p_mo_line_rec.header_id           is NULL OR
        p_mo_line_rec.line_number         is NULL OR
        p_mo_line_rec.organization_id     is NULL OR
        p_mo_line_rec.inventory_item_id   is NULL OR
        p_mo_line_rec.uom_code            is NULL OR
        p_mo_line_rec.quantity            is NULL OR
        p_mo_line_rec.line_status         is NULL OR
        p_mo_line_rec.transaction_type_id is NULL THEN

     RETURN TRUE;
     WSH_Util_Core.PrintLn('Return True');
  ELSE
     WSH_Util_Core.PrintLn('Return False');
     RETURN FALSE;
  END IF;

RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
                                'Check Required'
                              );

      RETURN TRUE;

END CHECK_REQUIRED;

PROCEDURE Get_Opm_converted_qty
(
   p_opm_item_id       IN NUMBER,
   p_apps_from_uom     IN VARCHAR2,
   p_apps_to_uom       IN VARCHAR2,
   p_opm_lot_id        IN  NUMBER,
   p_original_qty      IN  NUMBER,
   x_converted_qty     OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
l_api_name           CONSTANT VARCHAR2 (30) := 'Get_OPM_converted_qty';
l_opm_from_uom       VARCHAR2(4);
l_opm_to_uom         VARCHAR2(4);
l_opm_lot_id         NUMBER;
BEGIN

   /*  Lets Set Return Status to Sucess To Begin With. */

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*  Check Input Values */

   IF ( p_opm_item_id is NULL
	 OR p_opm_item_id = 0
	 OR p_opm_item_id = FND_API.G_MISS_NUM ) THEN
	 FND_MESSAGE.Set_Name('GMI','MISSING');
	 FND_MESSAGE.Set_Token('MISSING', 'Opm Item Id');
	 FND_MSG_PUB.Add;
	 raise FND_API.G_EXC_ERROR;
   END IF;

   IF ( p_apps_from_uom is NULL
	 OR p_apps_from_uom = FND_API.G_MISS_CHAR ) THEN
	 FND_MESSAGE.Set_Name('GMI','MISSING');
	 FND_MESSAGE.Set_Token('MISSING', 'apps from uom');
	 FND_MSG_PUB.Add;
	 raise FND_API.G_EXC_ERROR;
   END IF;

   IF ( p_apps_to_uom is NULL
	 OR p_apps_to_uom = FND_API.G_MISS_CHAR) THEN
	 FND_MESSAGE.Set_Name('GMI','MISSING');
	 FND_MESSAGE.Set_Token('MISSING', 'apps to uom');
	 FND_MSG_PUB.Add;
	 raise FND_API.G_EXC_ERROR;
   END IF;

   IF ( p_original_qty is NULL
	 OR p_apps_to_uom = FND_API.G_MISS_NUM ) THEN
	 FND_MESSAGE.Set_Name('GMI','MISSING');
	 FND_MESSAGE.Set_Token('MISSING', 'Original Qty Value');
	 FND_MSG_PUB.Add;
	 raise FND_API.G_EXC_ERROR;
   END IF;

   /*  Now Input Values have Been Validated Lets Get OPM */
   /*  Equaivalent UOM codes. */

   /*  Lets Get OPM From UOM code from apps from uom code */

   GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
   (
     p_Apps_UOM      => p_apps_from_uom,
	x_OPM_UOM       => l_opm_from_uom,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data
   );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
	 FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_apps_from_uom);
	 FND_MSG_PUB.Add;
	 RAISE FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('Convert From OPM UOM => ' || l_opm_from_uom);


   /*  Lets Get OPM to UOM code from apps to uom code */

   GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
   (
     p_Apps_UOM      => p_apps_to_uom,
	x_OPM_UOM       => l_opm_to_uom,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data
   );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
	 FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_apps_to_uom);
	 FND_MSG_PUB.Add;
	 RAISE FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('Convert To OPM UOM => ' || l_opm_from_uom);



   IF ( p_opm_lot_id is NULL
	 OR p_opm_item_id = FND_API.G_MISS_NUM ) THEN
	 l_opm_lot_id := 0;
   ELSE
      l_opm_lot_id := p_opm_lot_id;
   END IF;

   GMI_reservation_Util.PrintLn('Lot Id       => ' || l_opm_lot_id);
   GMI_reservation_Util.PrintLn('Original Qty => ' || p_original_qty);

   /*  OKay We have the values Lets Convert..... */

   GMICUOM.icuomcv
   (
	pitem_id  => p_opm_item_id,
     plot_id   => l_opm_lot_id,
     pcur_qty  => p_original_qty,
     pcur_uom  => l_opm_from_uom,
     pnew_uom  => l_opm_to_uom,
	onew_qty  => x_converted_qty
   );


   GMI_reservation_Util.PrintLn('converted Qty  => ' || x_converted_qty);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := fnd_api.g_ret_sts_error;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 ROLLBACK TO PICK_WAVE_CONFIRM;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

	 FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                                  ,l_api_name
                                 );

   WHEN OTHERS THEN
	 ROLLBACK TO PICK_WAVE_CONFIRM;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

	 FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                                  ,l_api_name
                                 );


END get_opm_converted_qty;

--Check_Shipping_Tolerances
--
-- This API checks to make sure that transacting the current allocation
-- does not exceed shipping tolerances.
-- This procedure should only be called for Pick Wave move orders
-- p_line_id : the move order line id.
-- p_quantity: the quantity to be transacted
-- x_allowed: 'Y' if txn is allowed, 'N' otherwise
-- x_max_quantity: the maximum quantity that can be pick confirmed
--     without exceeding shipping tolerances


PROCEDURE Check_Shipping_Tolerances
( x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_allowed             OUT NOCOPY VARCHAR2,
  x_max_quantity        OUT NOCOPY NUMBER,
  x_max_quantity2       OUT NOCOPY NUMBER,
  p_line_id             IN  NUMBER,
  p_quantity            IN  NUMBER,
  p_quantity2           IN  NUMBER
) IS

  l_allowed 	  VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_api_name      CONSTANT VARCHAR2(30) := 'Check_Shipping_Tolerances';
  l_txn_source_line_id NUMBER;
  l_max_quantity NUMBER;
  l_avail_req_qty NUMBER;
  l_max_quantity2 NUMBER;
  l_avail_req_qty2 NUMBER;

  CURSOR c_txn_source IS
    SELECT txn_source_line_id
      FROM ic_txn_request_lines
     WHERE line_id = p_line_id;

  CURSOR c_source_line IS
    SELECT source_line_id
      FROM wsh_delivery_details
     WHERE move_order_line_id = p_line_id;

BEGIN

  -- By default, allow the transaction.
  l_allowed := 'Y';
  l_return_status := fnd_api.g_ret_sts_success;
  l_max_quantity := 1e125;

  -- get sales order line id from the move order line
  OPEN c_txn_source;
  FETCH c_txn_source into l_txn_source_line_id;
  IF c_txn_source%NOTFOUND THEN
     CLOSE c_txn_source;            -- Bug 3859774
     RAISE fnd_api.g_exc_error;
  END IF;
  CLOSE c_txn_source;

  -- If for some reason the txn_source_line_id on the move order line is
  -- not yet populated, get the order line directly from the delivery
  -- details
  IF l_txn_source_line_id IS NULL THEN
    OPEN c_source_line;
    FETCH c_source_line INTO l_txn_source_line_id;
    If c_source_line%NOTFOUND Then
       l_txn_source_line_id := NULL;
    End If;
    CLOSE c_source_line;            -- Bug 3859774
  END IF;

  IF l_txn_source_line_id IS NOT NULL THEN
     check_quantity_to_pick(
         p_order_line_id           => l_txn_source_line_id
        ,p_quantity_to_pick        => p_quantity
        ,p_quantity2_to_pick       => p_quantity2
        ,x_allowed_flag            => l_allowed
        ,x_max_quantity_allowed    => l_max_quantity
        ,x_max_quantity2_allowed   => l_max_quantity2
        ,x_avail_req_quantity      => l_avail_req_qty
        ,x_avail_req_quantity2     => l_avail_req_qty2
        ,x_return_status           => l_return_status
      );
      If l_return_status = FND_API.G_RET_STS_ERROR Then
         raise FND_API.G_EXC_ERROR;
      Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;
  END IF;

  x_max_quantity := l_max_quantity;
  x_allowed := l_allowed;
  x_return_status := l_return_status;

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_allowed := 'N';
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                             ,p_data => x_msg_data);

  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_allowed := 'N';
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                             ,p_data => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_allowed := 'N';
    IF fnd_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
       (G_PKG_NAME
        ,l_api_name);
    END IF;

END Check_Shipping_Tolerances;

-----------------------------------------------------------------------------
--
-- Procedure:		check_quantity_to_pick
-- Parameters:		p_order_line_id,   - order line being picked
--                      p_quantity_to_pick - quantity to transact that
--                                           will be checked
--                      x_allowed_flag - 'Y' = allowed, 'N' = not allowed
--                      x_max_quantity_allowed - maximum quantity
--                                               that can be picked
--                      x_avail_req_quantity - req quantity not yet staged
--			x_return_status
-- Description:   	Checks if the quantity to pick is within overshipment
--                      tolerance, based on the quantities requested and
--                      staged and assignments to deliveries or containers.
--                      Also returns the maximum quantity allowed to pick.
-- History:             HW Added Qty2 for OPM and changed procedure parameters
-----------------------------------------------------------------------------

PROCEDURE check_quantity_to_pick(
	p_order_line_id           IN  NUMBER,
        p_quantity_to_pick        IN  NUMBER,
        p_quantity2_to_pick       IN  NUMBER DEFAULT NULL,
        x_allowed_flag            OUT NOCOPY VARCHAR2,
        x_max_quantity_allowed    OUT NOCOPY NUMBER,
        x_max_quantity2_allowed   OUT NOCOPY NUMBER,
        x_avail_req_quantity      OUT NOCOPY NUMBER,
        x_avail_req_quantity2     OUT NOCOPY NUMBER,
	x_return_status           OUT NOCOPY VARCHAR2) IS


-- HW OPM retrieve uom2
CURSOR c_detail_info(x_source_line_id IN NUMBER) IS
  SELECT inventory_item_id,
         organization_id,
         requested_quantity_uom,
         requested_quantity_uom2,
         ship_tolerance_above
  FROM   wsh_delivery_details
  WHERE  source_line_id = x_source_line_id
  AND    source_code = 'OE'
  AND    container_flag = 'N'
  AND    rownum = 1;


-- HW OPM added qty2
CURSOR c_detail_staged_quantities(x_source_line_id IN NUMBER) IS
  SELECT NVL(SUM(requested_quantity), 0) net_requested_qty,
         NVL(SUM(NVL(picked_quantity, requested_quantity)), 0) net_staged_qty,
         NVL(SUM(NVL(requested_quantity2,0)), 0) net_requested_qty2,
         NVL(SUM(NVL(picked_quantity2, requested_quantity2)), 0) net_staged_qty2
  FROM   wsh_delivery_details
  WHERE  source_line_id = x_source_line_id
  AND    source_code    = 'OE'
  AND    container_flag = 'N'
  AND    released_status IN ('X', 'Y', 'C');


CURSOR c_ordered_quantity(x_source_line_id  IN NUMBER,
                          x_item_id         IN NUMBER,
                          x_primary_uom     IN VARCHAR2) IS
  SELECT WSH_WV_UTILS.CONVERT_UOM(order_quantity_uom,
                                  x_primary_uom,
                                  ordered_quantity,
                                  x_item_id) quantity ,
         order_quantity_uom
  FROM   oe_order_lines_all
  WHERE  line_id = x_source_line_id;


-- HW OPM cursor for OPM
  CURSOR c_ordered_quantity_opm(x_source_line_id  IN NUMBER)IS

  SELECT ordered_quantity,
         order_quantity_uom,
         ordered_quantity2,
         ordered_quantity_uom2
  FROM   oe_order_lines_all
  WHERE  line_id = x_source_line_id;

l_found_flag      BOOLEAN;
l_detail_info     c_detail_info%ROWTYPE;
l_staged_info     c_detail_staged_quantities%ROWTYPE;
l_order_line      c_ordered_quantity%ROWTYPE;
--HW OPM variable for OPM cursor
l_order_line_opm  c_ordered_quantity_opm%ROWTYPE;
quantity          NUMBER;
l_max_quantity2   NUMBER;
l_min_quantity2   NUMBER;
l_max_quantity    NUMBER;
l_min_quantity    NUMBER;
l_msg_count       NUMBER;
l_msg_data   VARCHAR2(2000);
l_return_status varchar2(30);

l_apps_uom_ordered_quantity NUMBER := 0; -- Bug 2900072

l_req_qty_left    NUMBER;
others       EXCEPTION;

-- HW OPM new varibales
l_process_flag    VARCHAR2(1) :=FND_API.G_FALSE;
l_req_qty2_left    NUMBER;
l_apps_uom       VARCHAR2(4);
l_opm_uom        VARCHAR2(4);
l_apps_uom2       VARCHAR2(4);
l_opm_uom2        VARCHAR2(4);
l_ic_item_mst_rec GMI_RESERVATION_UTIL.ic_item_mst_rec;


BEGIN

  gmi_reservation_util.println('Inside GMI_PICK_WAVE_CONFIRM_PVT.check_quantity_to_pick');
  OPEN  c_detail_info(p_order_line_id);
  FETCH c_detail_info INTO l_detail_info;
  l_found_flag := c_detail_info%FOUND;
  CLOSE c_detail_info;

-- HW OPM Added qty2
  IF NOT l_found_flag THEN
    FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
    x_allowed_flag         := 'N';
    x_max_quantity_allowed := NULL;
    x_avail_req_quantity   := NULL;
    x_max_quantity2_allowed := NULL;
    x_avail_req_quantity2   := NULL;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    RETURN;
  END IF;

-- HW OPM Need to check the org for forking
  IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_detail_info.organization_id)
   THEN
     l_process_flag := FND_API.G_FALSE;
  ELSE
     l_process_flag := FND_API.G_TRUE;
  END IF;


  OPEN  c_detail_staged_quantities(p_order_line_id);
  FETCH c_detail_staged_quantities INTO l_staged_info;
  l_found_flag := c_detail_staged_quantities%FOUND;
  CLOSE c_detail_staged_quantities;

-- HW OPM Added qty2
  IF NOT l_found_flag THEN
    FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
    x_allowed_flag         := 'N';
    x_max_quantity_allowed := NULL;
    x_avail_req_quantity   := NULL;
    x_max_quantity2_allowed := NULL;
    x_avail_req_quantity2   := NULL;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    RETURN;
  END IF;

-- HW OPM for debugging puproses. Print values
  IF ( l_process_flag = FND_API.G_TRUE ) THEN
    gmi_reservation_util.println('Value of l_staged_info.net_requested_qty is '||l_staged_info.net_requested_qty);
    gmi_reservation_util.println('Value of l_staged_info.net_requested_qty2 is '||l_staged_info.net_requested_qty2);
    gmi_reservation_util.println('Value of l_staged_info.net_staged_qty is '||l_staged_info.net_staged_qty);
    gmi_reservation_util.println('Value of l_staged_info.net_satged_qty2 is '||l_staged_info.net_staged_qty2);
  END IF;

-- HW OPM Need to branch
  IF (l_process_flag = FND_API.G_FALSE ) THEN
    OPEN  c_ordered_quantity(p_order_line_id,
                             l_detail_info.inventory_item_id,
                             l_detail_info.requested_quantity_uom);
    FETCH c_ordered_quantity INTO l_order_line;
    l_found_flag := c_ordered_quantity%FOUND;
    CLOSE c_ordered_quantity;
  ELSE
    OPEN c_ordered_quantity_opm(p_order_line_id);
    FETCH c_ordered_quantity_opm INTO l_order_line_opm;
    quantity := GMI_Reservation_Util.get_opm_converted_qty(
                  p_apps_item_id    => l_detail_info.inventory_item_id,
                  p_organization_id => l_detail_info.organization_id,
                  p_apps_from_uom   => l_order_line_opm.order_quantity_uom,
                  p_apps_to_uom     => l_detail_info.requested_quantity_uom,
                  p_original_qty    => l_order_line_opm.ordered_quantity);

    l_found_flag := c_ordered_quantity_opm%FOUND;
    CLOSE c_ordered_quantity_opm;

  END IF;  -- of branching

-- HW OPM Added qty2
  IF NOT l_found_flag THEN
    FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
    x_allowed_flag         := 'N';
    x_max_quantity_allowed := NULL;
    x_avail_req_quantity   := NULL;
    x_max_quantity2_allowed := NULL;
    x_avail_req_quantity2   := NULL;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    RETURN;
  END IF;

  Get_Min_Max_Tolerance_Quantity
  (
       p_api_version_number         => 1.0
  ,    p_line_id                    => p_order_line_id
  ,    x_min_remaining_quantity     => l_min_quantity
  ,    x_max_remaining_quantity     => l_max_quantity
  ,    x_min_remaining_quantity2    => l_min_quantity2
  ,    x_max_remaining_quantity2    => l_max_quantity2
  ,    x_return_status              => l_return_status
  ,    x_msg_count                  => l_msg_count
  ,    x_msg_data                   => l_msg_data );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    raise others ;
  END IF;

-- HW added for debugging purposes
  IF ( l_process_flag = FND_API.G_TRUE ) THEN
   gmi_reservation_util.println('Value of l_min_quantity is '||l_min_quantity);
   gmi_reservation_util.println('Value of l_min_quantity2 is '||l_min_quantity2);
   gmi_reservation_util.println('Value of l_max_quantity  is '||l_max_quantity);
   gmi_reservation_util.println('Value of l_max_quantity2  is '||l_max_quantity2);
  END IF;


-- HW Need to branch
  IF ( l_process_flag = FND_API.G_FALSE ) THEN
     l_max_quantity :=  WSH_WV_UTILS.CONVERT_UOM(l_order_line.order_quantity_uom,
						l_detail_info.requested_quantity_uom,
						l_max_quantity,
						l_detail_info.inventory_item_id)
	   	    - l_staged_info.net_staged_qty;

      l_req_qty_left := GREATEST(0,
                             (l_order_line.quantity
                              - l_staged_info.net_requested_qty)
                            );

   ELSE
     l_max_quantity := GMI_Reservation_Util.get_opm_converted_qty(
                       p_apps_item_id    => l_detail_info.inventory_item_id,
                       p_organization_id => l_detail_info.organization_id,
                       p_apps_from_uom   => l_order_line_opm.order_quantity_uom,
                       p_apps_to_uom     => l_detail_info.requested_quantity_uom,
                       p_original_qty    => l_max_quantity)
         - l_staged_info.net_staged_qty;

       gmi_reservation_util.println('l_order_line_opm.ordered_quantity    '||l_order_line_opm.ordered_quantity);
       gmi_reservation_util.println('l_order_line_opm.order_quantity_uom  '||l_order_line_opm.order_quantity_uom);
       gmi_reservation_util.println('l_detail_info.requested_quantity_uom '||l_detail_info.requested_quantity_uom);

      -- BEGIN Bug 2900072 - If the order UOM is different than item's UOM convert Ordered quantity
      IF (l_order_line_opm.order_quantity_uom <> l_detail_info.requested_quantity_uom) THEN
         l_apps_uom_ordered_quantity := GMI_Reservation_Util.get_opm_converted_qty(
                       p_apps_item_id    => l_detail_info.inventory_item_id,
                       p_organization_id => l_detail_info.organization_id,
                       p_apps_from_uom   => l_order_line_opm.order_quantity_uom,
                       p_apps_to_uom     => l_detail_info.requested_quantity_uom,
                       p_original_qty    => l_order_line_opm.ordered_quantity);
      ELSE
         l_apps_uom_ordered_quantity := l_order_line_opm.ordered_quantity;
      END IF;

      gmi_reservation_util.println('l_apps_uom_ordered_quantity '||l_apps_uom_ordered_quantity);

      l_req_qty_left := GREATEST(0,
                             (l_apps_uom_ordered_quantity
                              - l_staged_info.net_requested_qty)
                            );
      -- END Bug 2900072

     l_max_quantity2 := nvl(l_max_quantity2,0) - nvl(l_staged_info.net_staged_qty2,0);

     l_req_qty2_left := GREATEST(0,
                             (l_order_line_opm.ordered_quantity2
                              - l_staged_info.net_requested_qty2)
                            );

  END IF; -- of branching


-- HW added for debugging purposes
 IF ( l_process_flag = FND_API.G_TRUE ) THEN
    gmi_reservation_util.println('Value of quantity is '||quantity);
    gmi_reservation_util.println('Value of l_order_line_opm.quantity2 is '||l_order_line_opm.ordered_quantity2);
    gmi_reservation_util.println('Value of l_req_qty_left is '|| l_req_qty_left);
    gmi_reservation_util.println('Value of l_req_qty2_left is '|| l_req_qty2_left);
  END IF;


  IF p_quantity_to_pick < 0 THEN
    x_allowed_flag    := 'N';
-- HW OPM added a checj for qty2
  ELSIF( p_quantity_to_pick > l_max_quantity) THEN
        -- Pupakare Begin BUG 2675737
        --OR
        --nvl(p_quantity2_to_pick,0) > nvl(l_max_quantity2,0) THEN
        -- End   BUG 2675737
    x_allowed_flag    := 'N';
  ELSE
    x_allowed_flag    := 'Y';
  END IF;

  x_max_quantity_allowed := l_max_quantity;
  x_avail_req_quantity   := l_req_qty_left;
-- HW OPM added qty2
  x_max_quantity2_allowed := l_max_quantity2;
  x_avail_req_quantity2   := l_req_qty2_left;

  -- HW for debugging purposes, print values
  IF ( l_process_flag = FND_API.G_TRUE ) THEN
    gmi_reservation_util.println('Value of x_max_quantity_allowed is '||x_max_quantity_allowed);
    gmi_reservation_util.println('Value of x_max_quantity2_allowed is '||x_max_quantity2_allowed);
    gmi_reservation_util.println('Value of  x_avail_req_quantity is '||x_avail_req_quantity);
    gmi_reservation_util.println('Value of x_avail_req_quantity2 is '||x_avail_req_quantity2);
  END IF;

  x_return_status        := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      IF c_detail_info%ISOPEN THEN
        CLOSE c_detail_info;
      END IF;
      IF c_detail_staged_quantities%ISOPEN THEN
        CLOSE c_detail_staged_quantities;
      END IF;
      IF c_ordered_quantity%ISOPEN THEN
        CLOSE c_ordered_quantity;
      END IF;
-- HW closing OPM cursor
      IF c_ordered_quantity_opm%ISOPEN THEN
        CLOSE c_ordered_quantity_opm;
      END IF;

      x_allowed_flag         := 'N';
      x_max_quantity_allowed := NULL;
      x_avail_req_quantity   := NULL;
-- HW Added for OPM
      x_max_quantity2_allowed := NULL;
      x_avail_req_quantity2   := NULL;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.check_quantity_to_pick');

END check_quantity_to_pick;

PROCEDURE Get_Min_Max_Tolerance_Quantity
(
     p_api_version_number	IN  NUMBER
,    p_line_id			IN  NUMBER
,    x_min_remaining_quantity	OUT NOCOPY NUMBER
,    x_max_remaining_quantity	OUT NOCOPY NUMBER
,    x_min_remaining_quantity2	OUT NOCOPY NUMBER
,    x_max_remaining_quantity2	OUT NOCOPY NUMBER
,    x_return_status		OUT NOCOPY VARCHAR2
,    x_msg_count		OUT NOCOPY NUMBER
,    x_msg_data			OUT NOCOPY VARCHAR2
)

IS

	l_api_version_number	CONSTANT NUMBER := 1.0;
	l_api_name		CONSTANT VARCHAR2(30) := 'Get_Min_Max_Tolerance_Quantity';
	l_line_set_id		        NUMBER;
	l_ship_tolerance_above	        NUMBER;
	l_ship_tolerance_below	        NUMBER;
	l_tolerance_quantity_below	NUMBER;
	l_tolerance_quantity_above	NUMBER;
	l_tolerance_quantity2_below	NUMBER;
	l_tolerance_quantity2_above	NUMBER;

	l_ordered_quantity		NUMBER;
	l_shipped_quantity		NUMBER;
	l_shipping_quantity		NUMBER;
	l_min_quantity_remaining	NUMBER;
	l_max_quantity_remaining	NUMBER;
-- HW OPM added qty2 for OPM
	l_ordered_quantity2		NUMBER;
	l_shipped_quantity2		NUMBER;
	l_shipping_quantity2		NUMBER;
	l_min_quantity_remaining2	NUMBER;
	l_max_quantity_remaining2	NUMBER;

        l_top_model_line_id             NUMBER;
        l_ato_line_id                   NUMBER;

BEGIN

	gmi_reservation_util.println('Entering GMI_PICK_WAVE_CONFIRM_PVT.Get_Min_Max_Tolerance_Quantity');

	x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
    	IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    	THEN
       	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
*/
-- HW OPM retrieve qty2 for OPM
	SELECT	ship_tolerance_below,
		ship_tolerance_above,
		line_set_id,
		ordered_quantity,
		shipped_quantity,
		ordered_quantity2,
		shipped_quantity2,
                top_model_line_id,
                ato_line_id
	INTO	l_ship_tolerance_below,
		l_ship_tolerance_above,
		l_line_set_id,
		l_ordered_quantity,
		l_shipped_quantity,
		l_ordered_quantity2,
		l_shipped_quantity2,
                l_top_model_line_id,
                l_ato_line_id
	FROM	OE_ORDER_LINES_ALL
	WHERE	line_id = p_line_id;

        IF  nvl(l_top_model_line_id,-1) = nvl(l_ato_line_id,-1) AND
            l_top_model_line_id IS NOT NULL THEN

            gmi_reservation_util.println('It is a ATO MODEL ');

            SELECT  line_set_id
            INTO    l_line_set_id
            FROM    OE_ORDER_LINES_ALL
            WHERE   line_id = l_top_model_line_id;

            gmi_reservation_util.println('Line set id : '||l_line_set_id);

        END IF;

	IF	l_line_set_id IS NOT NULL THEN
-- HW Sum qty2 for OPM
		gmi_reservation_util.println('Line set id : '||l_line_set_id);
		SELECT	SUM(ordered_quantity)
		,	SUM(shipped_quantity)
		,	SUM(shipping_quantity)
		,       SUM(nvl(ordered_quantity2,0))
		,	SUM(nvl(shipped_quantity2,0))
		,	SUM(nvl(shipping_quantity2,0))
		INTO    l_ordered_quantity
		,	l_shipped_quantity
		,	l_shipping_quantity
		,       l_ordered_quantity2
		,	l_shipped_quantity2
		,	l_shipping_quantity2
		FROM	oe_order_lines_all
		WHERE 	line_set_id	= l_line_set_id;

	END IF;

	gmi_reservation_util.println('Total ordered quantity : '||to_char(l_ordered_quantity));
	gmi_reservation_util.println('Total shipped quantity : '||to_char(l_shipped_quantity));

	l_tolerance_quantity_below	:=	nvl(l_ordered_quantity,0)*nvl(l_ship_tolerance_below,0)/100;
	l_tolerance_quantity_above	:=	nvl(l_ordered_quantity,0)*nvl(l_ship_tolerance_above,0)/100;
	l_tolerance_quantity2_below	:=	nvl(l_ordered_quantity2,0)*nvl(l_ship_tolerance_below,0)/100;
	l_tolerance_quantity2_above	:=	nvl(l_ordered_quantity2,0)*nvl(l_ship_tolerance_above,0)/100;

	gmi_reservation_util.println('Tolerance quantity below : '||l_tolerance_quantity_below);
	gmi_reservation_util.println('Tolerance quantity above : '||l_tolerance_quantity_above);
	gmi_reservation_util.println('Tolerance quantity2 below : '||l_tolerance_quantity2_below);
	gmi_reservation_util.println('Tolerance quantity2 above : '||l_tolerance_quantity2_above);

	l_min_quantity_remaining := l_ordered_quantity - nvl(l_shipped_quantity,0) - l_tolerance_quantity_below;
	l_max_quantity_remaining := l_ordered_quantity - nvl(l_shipped_quantity,0) + l_tolerance_quantity_above;

-- HW Get min and max qty2 for OPM
	l_min_quantity_remaining2 := nvl(l_ordered_quantity2,0) - nvl(l_shipped_quantity2,0) - l_tolerance_quantity2_below;
	l_max_quantity_remaining2 := nvl(l_ordered_quantity2,0) - nvl(l_shipped_quantity2,0) + l_tolerance_quantity2_above;

	gmi_reservation_util.println('Min remaining quantity   : '||l_min_quantity_remaining);
	gmi_reservation_util.println('Max remaining quantity   : '||l_max_quantity_remaining);

-- HW Print Qty2 for OPM
	gmi_reservation_util.println('Min remaining quantity2   : '||l_min_quantity_remaining2);
	gmi_reservation_util.println('Max remaining quantity2   : '||l_max_quantity_remaining2);

	IF	l_min_quantity_remaining < 0 THEN

		l_min_quantity_remaining := 0;

	END IF;

	IF	l_min_quantity_remaining2 < 0 THEN
-- HW reset qty2 for OPM
                l_min_quantity_remaining2 := 0;

	END IF;

	IF	l_max_quantity_remaining < 0 THEN

		l_max_quantity_remaining := 0;
	END IF;

	IF	l_max_quantity_remaining2 < 0 THEN
-- HW reset qty2 for OPM
		l_max_quantity_remaining2 := 0;

	END IF;

	x_min_remaining_quantity := l_min_quantity_remaining;
	x_max_remaining_quantity := l_max_quantity_remaining;

-- HW added qty2 for OPM
	x_min_remaining_quantity2 := nvl(l_min_quantity_remaining2,0);
	x_max_remaining_quantity2 := nvl(l_max_quantity_remaining2,0);

	gmi_reservation_util.println('Return Min remaining quantity   : '||x_min_remaining_quantity);
	gmi_reservation_util.println('Return Max remaining quantity   : '||x_max_remaining_quantity);

-- HW print qty2 for OPM
	gmi_reservation_util.println('Return Min remaining quantity2   : '||x_min_remaining_quantity2);
	gmi_reservation_util.println('Return Max remaining quantity2   : '||x_max_remaining_quantity2);

	gmi_reservation_util.println('Exiting GMI_PICK_WAVE_CONFIRM_PVT.Get_Min_Max_Tolerance_Quantity '||x_return_status);

EXCEPTION

	WHEN NO_DATA_FOUND THEN

	x_min_remaining_quantity := 0;
	x_max_remaining_quantity := 0;

-- HW reset values for qty2 for OPM
        x_min_remaining_quantity2 := 0;
	x_max_remaining_quantity2 := 0;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	gmi_reservation_util.println('Unexpected Error : '||sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	WHEN OTHERS THEN

		gmi_reservation_util.println('Unexpected Error : '||sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Min_Max_Tolerance_Quantity'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Min_Max_Tolerance_Quantity;


/* Following procedure created for bug2901317*/
PROCEDURE BALANCE_NONINV_TRAN
 (
   p_dflt_nonctl_tran_rec         IN GMI_TRANS_ENGINE_PUB.ictran_rec
 , p_commit                       IN VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_requested_qty                IN NUMBER
 , p_requested_qty2               IN NUMBER
 , p_delivery_detail_id           IN NUMBER
 , x_tran_row                    OUT NOCOPY IC_TRAN_PND%ROWTYPE
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 )
 IS

l_dflt_nonctl_tran_rec  GMI_TRANS_ENGINE_PUB.ictran_rec;
l_validation_level      VARCHAR2(4) := FND_API.G_VALID_LEVEL_FULL;
BEGIN

     l_dflt_nonctl_tran_rec := p_dflt_nonctl_tran_rec;

    /* Split ic_tran_pnd to have remaining quantity backordered.
       set the staged ind on original line to 1 */

     l_dflt_nonctl_tran_rec.trans_qty  := (-1) *(ABS(l_dflt_nonctl_tran_rec.trans_qty) -  p_requested_qty);
     l_dflt_nonctl_tran_rec.trans_qty2 := (-1) *(ABS(l_dflt_nonctl_tran_rec.trans_qty2) - p_requested_qty2);

     GMI_Reservation_Util.PrintLn('Updating pending txn with qty '||l_dflt_nonctl_tran_rec.trans_qty );

     l_dflt_nonctl_tran_rec.staged_ind := 0;
     l_dflt_nonctl_tran_rec.line_detail_id := null;


     /* Updating the default transaction with backordered quantity */
     GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_commit           => p_commit
      ,p_validation_level => l_validation_level
      ,p_tran_rec         => l_dflt_nonctl_tran_rec
      ,x_tran_row         => x_tran_row
      ,x_return_status    => x_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in PICK_CONFIRM:
         Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.' );
       GMI_reservation_Util.PrintLn(x_msg_data); -- Bug 3859774
       FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
       FND_MESSAGE.Set_Token('WHERE', 'PICK_CONFIRM');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_dflt_nonctl_tran_rec.trans_id   := NULL;
     l_dflt_nonctl_tran_rec.line_detail_id := p_delivery_detail_id;
     l_dflt_nonctl_tran_rec.staged_ind := 1;
     l_dflt_nonctl_tran_rec.trans_qty  := -1 * p_requested_qty;
     l_dflt_nonctl_tran_rec.trans_qty2 := -1 * p_requested_qty2;


     GMI_Reservation_Util.PrintLn('Creating new pending txn with req qty '||l_dflt_nonctl_tran_rec.trans_qty );

     /* Creating a new transaction with the staged quantity */
     GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
      ( p_api_version      => 1.0
      , p_init_msg_list    => FND_API.G_FALSE
      , p_commit           => FND_API.G_FALSE
      , p_validation_level => FND_API.G_VALID_LEVEL_FULL
      , p_tran_rec         => l_dflt_nonctl_tran_rec
      , x_tran_row         => x_tran_row
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
         return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
       GMI_reservation_Util.PrintLn(x_msg_data); -- Bug 3859774
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
       FND_MESSAGE.Set_Token('WHERE','PICK_CONFIRM');
       FND_MSG_PUB.Add;
       raise FND_API.G_EXC_ERROR;
     END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END;

/* Following procedure added for Enhancement 2320442 - Lakshmi Swamy */
/* Bug2901317 - April 21st 2003 - Made changes to incorporate non-inventory items */


PROCEDURE BALANCE_NONCTL_INV_TRAN
 (
   p_mo_line_rec                  IN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
 , p_commit                       IN VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_item_id                      IN NUMBER
 , p_whse_code                    IN VARCHAR2
 , p_requested_qty                IN NUMBER
 , p_requested_qty2               IN NUMBER
 , p_delivery_detail_id           IN NUMBER
 , x_available_qty               OUT NOCOPY NUMBER
 , x_available_qty2              OUT NOCOPY NUMBER
 , x_tran_row                    OUT NOCOPY IC_TRAN_PND%ROWTYPE
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 )
 IS

  CURSOR loct_onhand_CUR IS
   SELECT loct_onhand , loct_onhand2
     FROM ic_loct_inv
    WHERE whse_code   = p_whse_code
      AND item_id     = p_item_id
      AND lot_id      = 0
      AND location    = GMI_RESERVATION_UTIL.G_DEFAULT_LOCT
      AND delete_mark = 0;


  CURSOR staged_qty_CUR  IS
   SELECT NVL(sum(trans_qty),0), NVL(sum(trans_qty2),0)
     FROM ic_tran_pnd
    WHERE item_id       = p_item_id
      AND whse_code     = p_whse_code
      AND doc_type      = 'OMSO'
      AND staged_ind    = 1
      AND delete_mark   = 0
      AND completed_ind = 0;

  CURSOR tot_bkordr_qty_CUR IS
   SELECT sum(requested_quantity), sum(requested_quantity2)
     FROM wsh_delivery_details
    WHERE released_status = 'B'
      AND source_line_id  = p_mo_line_rec.txn_source_line_id;

-- HW BUG# 3871662: Issue:Cursor check_wsh violated the standards.
-- Removed the cursor since it's not being used in this procedure

  Cursor item_mst_dtl IS
   Select noninv_ind
     from ic_item_mst
    where item_id = p_item_id;

  l_trans_id               NUMBER;
  l_dflt_nonctl_tran_rec   GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_dflt_nonctl_tran_rec1  GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_validation_level       VARCHAR2(4) := FND_API.G_VALID_LEVEL_FULL;
  l_tran_row               IC_TRAN_PND%ROWTYPE;
  l_onhand_qty             NUMBER := 0; -- Bug 2910069
  l_onhand_qty2            NUMBER := 0; -- Bug 2910069
  l_backorder_qty          NUMBER := 0;
  l_backorder_qty2         NUMBER := 0;
  l_commit_qty   	   NUMBER := 0;
  l_commit_qty2  	   NUMBER := 0;
  l_pick_slip_number 	   NUMBER := 0;

  l_allow_negative_inv	NUMBER; /* 2690711 */
  l_noninv_ind          NUMBER;



  BEGIN

      GMI_Reservation_Util.PrintLn('Handling Noninventory/Non-controlled Items');

      GMI_RESERVATION_UTIL.find_default_lot
        (  x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           x_reservation_id    => l_trans_id,
           p_line_id           => p_mo_line_rec.txn_source_line_id
        );

      l_dflt_nonctl_tran_rec1.trans_id := l_trans_id;

      IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
         (l_dflt_nonctl_tran_rec1, l_dflt_nonctl_tran_rec ) THEN

        Open  item_mst_dtl;
        Fetch item_mst_dtl INTO l_noninv_ind;
        Close item_mst_dtl;

        IF (l_noninv_ind = 1) THEN
         GMI_Reservation_Util.PrintLn('Non Inventory Item');
         IF (p_requested_qty < ABS(l_dflt_nonctl_tran_rec.trans_qty)) THEN

           GMI_PICK_WAVE_CONFIRM_PVT.BALANCE_NONINV_TRAN
                (
                  p_dflt_nonctl_tran_rec   => l_dflt_nonctl_tran_rec,
                  p_commit                 => p_commit,
                  p_requested_qty          => p_requested_qty,
                  p_requested_qty2         => p_requested_qty2,
                  p_delivery_detail_id     => p_delivery_detail_id,
                  x_tran_row               => l_tran_row,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data
                );

           RETURN;
         END IF;
        END IF;


        /* Begin Bug 2690711 */

        l_allow_negative_inv := FND_PROFILE.VALUE('IC$ALLOWNEGINV');

        IF (l_noninv_ind = 1) OR (l_allow_negative_inv = 1) THEN

          l_dflt_nonctl_tran_rec.trans_qty   := (-1) * p_requested_qty;
          l_dflt_nonctl_tran_rec.trans_qty2  := (-1) * p_requested_qty2;
          GMI_Reservation_Util.PrintLn('Irrespective of available quantity, transacting all the requested quantity');

          l_dflt_nonctl_tran_rec.line_detail_id := p_delivery_detail_id;
          l_dflt_nonctl_tran_rec.staged_ind := 1;

          /* Updating the default transaction with requested quantity */
          GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
              p_api_version      => 1.0
             ,p_init_msg_list    => FND_API.G_FALSE
             ,p_commit           => p_commit
             ,p_validation_level => l_validation_level
             ,p_tran_rec         => l_dflt_nonctl_tran_rec
             ,x_tran_row         => l_tran_row
             ,x_return_status    => x_return_status
             ,x_msg_count        => x_msg_count
             ,x_msg_data         => x_msg_data);

          x_available_qty  :=  p_requested_qty;
          x_available_qty2 :=  p_requested_qty2;

          x_tran_row := l_tran_row;


          /* Begin Bug2936797 - populating pick slip number for non-controlled item */
          /* Setting the pick slip number */

            IF (l_noninv_ind = 1) THEN
                RETURN;
            END IF;

            GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip
             ( p_organization_id       => p_mo_line_rec.organization_id
             , p_line_id               => p_mo_line_rec.line_id
             , x_return_status         => x_return_status
             , x_msg_count             => x_msg_count
             , x_msg_data              => x_msg_data
             , x_pick_slip_number      => l_pick_slip_number
             );

            GMI_reservation_Util.PrintLn('pick slip number is '|| l_pick_slip_number);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
             GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_lots: Error returned by GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip.', 'pick_lots.log');
             FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
             FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip');
             FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
            END IF;

            UPDATE ic_tran_pnd
               SET pick_slip_number = l_pick_slip_number
             WHERE trans_id = l_tran_row.trans_id;

           /* End Bug2936797 */
          RETURN;
        END IF;
        /* End Bug 2690711 */

        OPEN  loct_onhand_CUR;
        FETCH loct_onhand_CUR INTO l_onhand_qty,l_onhand_qty2;
        CLOSE loct_onhand_CUR;

        OPEN  staged_qty_CUR;
        FETCH staged_qty_CUR INTO l_commit_qty,l_commit_qty2;
        CLOSE staged_qty_CUR;

        GMI_Reservation_Util.PrintLn('l_commit_qty is '||l_commit_qty);
        GMI_Reservation_Util.PrintLn('l_onhand_qty is '||l_onhand_qty);

        IF (ABS(l_commit_qty) < l_onhand_qty ) THEN
          x_available_qty :=  l_onhand_qty  - (-1 * l_commit_qty);
          x_available_qty2 := l_onhand_qty2 - (-1 * l_commit_qty2);
        ELSE
          x_available_qty  := 0;
          x_available_qty2 := 0;
        END IF;

        GMI_Reservation_Util.PrintLn('x available qty '||x_available_qty);
        GMI_Reservation_Util.PrintLn('p_requested_qty '||p_requested_qty);

        IF (x_available_qty <> 0) THEN
          IF (x_available_qty < p_requested_qty) THEN
             /* Split ic_tran_pnd to have remaining quantity backordered.
                set the staged ind on original line to 1 */

            l_backorder_qty  := p_requested_qty  - x_available_qty;
            l_backorder_qty2 := p_requested_qty2 - x_available_qty2;
            l_dflt_nonctl_tran_rec.trans_qty  :=  -1 * ((-1 * l_dflt_nonctl_tran_rec.trans_qty)  - p_requested_qty  + l_backorder_qty);
            l_dflt_nonctl_tran_rec.trans_qty2 :=  -1 * ((-1 * l_dflt_nonctl_tran_rec.trans_qty2) - p_requested_qty2 + l_backorder_qty2);

            GMI_Reservation_Util.PrintLn('1. Updating pending txn with qty '||l_dflt_nonctl_tran_rec.trans_qty );
            l_dflt_nonctl_tran_rec.staged_ind := 0;
            l_dflt_nonctl_tran_rec.line_detail_id := null;

            /* Updating the default transaction with backordered quantity */
            GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
              p_api_version      => 1.0
             ,p_init_msg_list    => FND_API.G_FALSE
             ,p_commit           => p_commit
             ,p_validation_level => l_validation_level
             ,p_tran_rec         => l_dflt_nonctl_tran_rec
             ,x_tran_row         => l_tran_row
             ,x_return_status    => x_return_status
             ,x_msg_count        => x_msg_count
             ,x_msg_data         => x_msg_data);

            l_dflt_nonctl_tran_rec.trans_id   := NULL;
            l_dflt_nonctl_tran_rec.line_detail_id := p_delivery_detail_id;
            l_dflt_nonctl_tran_rec.staged_ind := 1;
            l_dflt_nonctl_tran_rec.trans_qty  := -1 * x_available_qty;
            l_dflt_nonctl_tran_rec.trans_qty2 := -1 * x_available_qty2;

            GMI_Reservation_Util.PrintLn('1. creating new pending txn with avail qty '||l_dflt_nonctl_tran_rec.trans_qty );

            /* Creating a new transaction with the staged quantity */
            GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
              ( p_api_version      => 1.0
              , p_init_msg_list    => FND_API.G_FALSE
              , p_commit           => FND_API.G_FALSE
              , p_validation_level => FND_API.G_VALID_LEVEL_FULL
              , p_tran_rec         => l_dflt_nonctl_tran_rec
              , x_tran_row         => l_tran_row
              , x_return_status    => x_return_status
              , x_msg_count        => x_msg_count
              , x_msg_data         => x_msg_data
              );

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
                 return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
              GMI_reservation_Util.PrintLn(x_msg_data); -- Bug 3859774
              FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
              FND_MESSAGE.Set_Token('WHERE','Create_Default_Lot');
              FND_MSG_PUB.Add;
              raise FND_API.G_EXC_ERROR;
            END IF;

          ELSIF (p_requested_qty <> ABS(l_dflt_nonctl_tran_rec.trans_qty)) THEN
             /* Split ic_tran_pnd to have remaining quantity backordered.
               set the staged ind on original line to 1 */

             l_dflt_nonctl_tran_rec.trans_qty  := (-1) *(ABS(l_dflt_nonctl_tran_rec.trans_qty) -  p_requested_qty);
             l_dflt_nonctl_tran_rec.trans_qty2 := (-1) *(ABS(l_dflt_nonctl_tran_rec.trans_qty2) - p_requested_qty2);

             GMI_Reservation_Util.PrintLn('2. Updating pending txn with qty '||l_dflt_nonctl_tran_rec.trans_qty );

             l_dflt_nonctl_tran_rec.staged_ind := 0;
             l_dflt_nonctl_tran_rec.line_detail_id := null;

             /* Updating the default transaction with backordered quantity */
             GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
               p_api_version      => 1.0
              ,p_init_msg_list    => FND_API.G_FALSE
              ,p_commit           => p_commit
              ,p_validation_level => l_validation_level
              ,p_tran_rec         => l_dflt_nonctl_tran_rec
              ,x_tran_row         => l_tran_row
              ,x_return_status    => x_return_status
              ,x_msg_count        => x_msg_count
              ,x_msg_data         => x_msg_data);

             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) in PICK_CONFIRM:
                 Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.' );
               GMI_reservation_Util.PrintLn(x_msg_data); -- Bug 3859774
               FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
               FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
               FND_MESSAGE.Set_Token('WHERE', 'PICK_CONFIRM');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             END IF;

             l_dflt_nonctl_tran_rec.trans_id   := NULL;
             l_dflt_nonctl_tran_rec.line_detail_id := p_delivery_detail_id;
             l_dflt_nonctl_tran_rec.staged_ind := 1;
             l_dflt_nonctl_tran_rec.trans_qty  := -1 * p_requested_qty;
             l_dflt_nonctl_tran_rec.trans_qty2 := -1 * p_requested_qty2;

             GMI_Reservation_Util.PrintLn('2. creating new pending txn with req qty '||l_dflt_nonctl_tran_rec.trans_qty );

             /* Creating a new transaction with the staged quantity */
             GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
              ( p_api_version      => 1.0
              , p_init_msg_list    => FND_API.G_FALSE
              , p_commit           => FND_API.G_FALSE
              , p_validation_level => FND_API.G_VALID_LEVEL_FULL
              , p_tran_rec         => l_dflt_nonctl_tran_rec
              , x_tran_row         => l_tran_row
              , x_return_status    => x_return_status
              , x_msg_count        => x_msg_count
              , x_msg_data         => x_msg_data
              );

             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
                 return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
               GMI_reservation_Util.PrintLn(x_msg_data); -- Bug 3859774
               FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
               FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
               FND_MESSAGE.Set_Token('WHERE','PICK_CONFIRM');
               FND_MSG_PUB.Add;
               raise FND_API.G_EXC_ERROR;
             END IF;

          ELSE

             l_dflt_nonctl_tran_rec.line_detail_id := p_delivery_detail_id;
             l_dflt_nonctl_tran_rec.staged_ind := 1;

             GMI_Reservation_Util.PrintLn('3. Updating pending txn with staged ind/delivery id');

             GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
               p_api_version      => 1.0
              ,p_init_msg_list    => FND_API.G_FALSE
              ,p_commit           => p_commit
              ,p_validation_level => l_validation_level
              ,p_tran_rec         => l_dflt_nonctl_tran_rec
              ,x_tran_row         => l_tran_row
              ,x_return_status    => x_return_status
              ,x_msg_count        => x_msg_count
              ,x_msg_data         => x_msg_data);

             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) in PICK_CONFIRM:
                 Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.' );
                 GMI_reservation_Util.PrintLn(x_msg_data); -- Bug 3859774
                 FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
                 FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
               FND_MESSAGE.Set_Token('WHERE', 'PICK_CONFIRM');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             END IF;

          END IF;


        /* Setting the pick slip number */

        GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip
         ( p_organization_id       => p_mo_line_rec.organization_id
         , p_line_id               => p_mo_line_rec.line_id
         , x_return_status         => x_return_status
         , x_msg_count             => x_msg_count
         , x_msg_data              => x_msg_data
         , x_pick_slip_number      => l_pick_slip_number
         );

        GMI_reservation_Util.PrintLn('pick slip number is '|| l_pick_slip_number);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
         GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_lots: Error returned by GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip.', 'pick_lots.log');
         FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
         FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip');
         FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
        END IF;

        GMI_reservation_Util.PrintLn('l_tran_row.trans_id '||l_tran_row.trans_id );
        UPDATE ic_tran_pnd
           SET pick_slip_number = l_pick_slip_number
         WHERE trans_id = l_tran_row.trans_id;

        x_tran_row := l_tran_row;
        END IF;  /* IF (x_available_qty <> 0) */
      END IF;  /* IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND */

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END BALANCE_NONCTL_INV_TRAN;



/* this procedure is called only from ICTOTRX.fmb where the private
 * API would be shielded from the form call */
PROCEDURE FORM_PICK_CONFIRM
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
 , p_manual_pick             IN VARCHAR2 DEFAULT NULL
 )
 IS
 BEGIN
        GMI_Pick_Wave_Confirm_PVT.Pick_Confirm(
            p_api_version_number     => 1.0,
            p_init_msg_lst           => FND_API.G_FALSE,
            p_validation_flag        => FND_API.G_VALID_LEVEL_FULL,
            p_commit                 => p_commit,
            p_delivery_detail_id     => null,
            p_mo_line_tbl            => p_mo_line_tbl,
            x_mo_line_tbl            => x_mo_line_tbl,
            x_return_status          => x_return_status,
            x_msg_data               => x_msg_data,
            x_msg_count              => x_msg_count);

 END form_pick_confirm;

-- Added this procedure for bug 3776538
PROCEDURE truncate_trans_qty
(
     p_line_id            IN number,
     p_delivery_detail_id IN number,
     p_default_location   IN varchar2,
     is_lot_loct_ctl      IN boolean,
     x_return_status      OUT NOCOPY VARCHAR2
) IS

 CURSOR lot_loct_ctl_trans
 IS
 SELECT trans_id, trans_qty, trans_qty2
  FROM  IC_TRAN_PND tran,
        IC_LOTS_MST lots,
        IC_LOCT_MST loct
  WHERE lots.lot_id        = tran.lot_id
  AND   lots.item_id       = tran.item_id
  AND   lots.delete_mark   = 0
  AND   tran.line_id       = p_line_id
  AND   (tran.lot_id       > 0 OR tran.location <> p_default_location )
  AND   tran.doc_type      = 'OMSO'
  AND   tran.staged_ind    = 0
  AND   tran.completed_ind = 0
  AND   tran.delete_mark   = 0
  AND   loct.delete_mark(+) = 0
  AND   loct.whse_code  (+) = tran.whse_code
  AND   loct.location   (+) = tran.location
  AND   tran.line_detail_id = p_delivery_detail_id
  FOR UPDATE OF trans_qty, trans_qty2 NOWAIT;

  l_TRUNCATE_TO_LENGTH CONSTANT INTEGER := 5;

 BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   GMI_Reservation_Util.PrintLn('Inside truncate_trans_qty');
   GMI_Reservation_Util.PrintLn('Parameters- p_line_id:'||p_line_id||', p_delivery_detail_id:'||p_delivery_detail_id||', p_default_location:'||p_default_location);
   IF (is_lot_loct_ctl = TRUE) THEN
      FOR lot_loct_ctl_trans_rec in lot_loct_ctl_trans
      LOOP
         update ic_tran_pnd
         set    trans_qty = trunc (trans_qty,  l_TRUNCATE_TO_LENGTH),
                trans_qty2= trunc (trans_qty2, l_TRUNCATE_TO_LENGTH)
         where  current of lot_loct_ctl_trans;
         GMI_Reservation_Util.PrintLn('Truncated transaction with trans_id: '||lot_loct_ctl_trans_rec.trans_id||' to '||l_TRUNCATE_TO_LENGTH||'th decimal');
      END LOOP;
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
       gmi_reservation_util.println(SQLERRM);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 END truncate_trans_qty;

 PROCEDURE dump_shp_attrb_data (p_shipping_attr IN WSH_INTERFACE.ChangedAttributeTabType) IS
 BEGIN
   gmi_reservation_util.println('Writing Data from dump_shp_attrb_data');
   GMI_Reservation_Util.PrintLn('Delivery Detail ID  - '||p_shipping_attr(1).delivery_detail_id);
   GMI_Reservation_Util.PrintLn('Line ID             - '||p_shipping_attr(1).source_line_id);
   GMI_Reservation_Util.PrintLn('Action Flag         - '||p_shipping_attr(1).action_flag);
   GMI_Reservation_Util.PrintLn('ordered_quantity1   - '||p_shipping_attr(1).ordered_quantity);
   GMI_Reservation_Util.PrintLn('ordered_quantity2   - '||p_shipping_attr(1).ordered_quantity2);
   GMI_Reservation_Util.PrintLn('Backorder quantity1 - '||p_shipping_attr(1).cycle_count_quantity);
   GMI_Reservation_Util.PrintLn('Backorder quantity2 - '||p_shipping_attr(1).cycle_count_quantity2);
   GMI_Reservation_Util.PrintLn('Released Status     - '||p_shipping_attr(1).released_status);
   GMI_Reservation_Util.PrintLn('picked_quantity1    - '||p_shipping_attr(1).picked_quantity);
   GMI_Reservation_Util.PrintLn('picked_quantity2    - '||p_shipping_attr(1).picked_quantity2);
   GMI_Reservation_Util.PrintLn('pending_quantity1   - '||p_shipping_attr(1).pending_quantity);
   GMI_Reservation_Util.PrintLn('pending_quantity2   - '||p_shipping_attr(1).pending_quantity2);
 END dump_shp_attrb_data;


END GMI_PICK_WAVE_CONFIRM_PVT;

/

--------------------------------------------------------
--  DDL for Package Body GMI_OM_ALLOC_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_OM_ALLOC_API_PUB" AS
/*  $Header: GMIOMAPB.pls 120.0 2005/05/25 15:51:25 appldev noship $  */
/* +=========================================================================+
 |                Copyright (c) 2002 Oracle Corporation                    |
 |                         All righTs reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIOMAPB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains PUBLIC utilities  relating to OPM             |
 |     reservation.                                                        |
 |                                                                         |
 | -- Allocate_OPM_Orders					           |
 |									   |
 | HISTORY                                                                 |
 | 		19-AUG-2002  nchekuri        Created 			   |
 |									   |
 +=========================================================================+
  API Name  : GMI_OM_ALLOC_API_PUB
  Type      : Public Package Body
  Function  : This package contains Public Utilities procedures used to
              OPM reservation process.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


/*  Global variables  */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='GMI_OM_ALLOC_API_PUB';

/* ========================================================================*/
/***************************************************************************/
/*
|    PARAMETERS:
|   	      p_api_version          Known api version
|             p_init_msg_list        FND_API.G_TRUE to reset list
|             p_commit		     Commit flag. API commits if this is set.
|             x_return_status        Return status
|             x_msg_count            Number of messages in the list
|             x_msg_data             Text of messages
|             p_tran_rec	     Input transaction record
|
|     VERSION   : current version         1.0
|                 initial version         1.0
|     COMMENT   : Creates,updates or deletes an opm reservation in ic_tran_pnd
|		  table table with information specified in p_tran_rec.
|
|     Notes :
|       --	The passed qties are positive
|       --	if trans_id > 0, then the action code would be either update
|	        or delete.
|
|       --	if trans_id = 0, then ureate a new transaction.
|
|       --	line_id is mandatory in any case.
|
|    	--	Values for action_code are 'INSERT','UPDATE' and 'DELETE'
|
|       --	Note that each UOM will be in passed in p_tran_rec as
|		AppsUOM (3char). Need to be converted back to OPMUOM.
|	--	Update is for quantities only.
|
****************************************************************************
| ========================================================================  */

PROCEDURE Allocate_OPM_Orders(
		p_api_version	 IN	     NUMBER
	        ,p_init_msg_list IN 	     VARCHAR2
		,p_commit	 IN   	     VARCHAR2
                ,p_tran_rec      IN          IC_TRAN_REC_TYPE
                ,x_return_status OUT NOCOPY  VARCHAR2
                ,x_msg_count 	 OUT NOCOPY  NUMBER
                ,x_msg_data   	 OUT NOCOPY  VARCHAR2 ) IS


-- Standard constants to be used to check for call compatibility.
l_api_version   CONSTANT        NUMBER          := 1.0;
l_api_name      CONSTANT        VARCHAR2(30):= 'allocate_opm_orders';

-- Local Variables.

l_tran_rec	IC_TRAN_REC_TYPE;
l_pick_lots_rec GMI_TRANS_ENGINE_PUB.ictran_rec;
l_line_status	VARCHAR2(30);
l_count			NUMBER;
l_line_detail_id	NUMBER;
l_mo_line_id 		NUMBER DEFAULT NULL;
l_inventory_item_id	NUMBER;
l_schedule_ship_date	DATE;
l_ordered_quantity_uom  VARCHAR2(3);
l_ordered_quantity_uom2 VARCHAR2(3);
l_ordered_quantity      NUMBER;
l_ordered_quantity2     NUMBER;
l_requested_quantity    NUMBER;
l_requested_quantity2   NUMBER;
l_line_id		NUMBER;
l_default_lot		VARCHAR2(32);
l_default_location	VARCHAR2(32);
l_tmp_qty		NUMBER;
l_tmp_qty2		NUMBER;
l_opm_um		VARCHAR2(4);
--l_order_um		VARCHAR2(3);
l_apps_um		VARCHAR2(3);
l_order_um2		VARCHAR2(3);
l_loc_inactive		NUMBER;
l_ship_from_org_id      NUMBER;
l_ic_item_mst_rec	ic_item_mst_b%ROWTYPE;
l_ic_whse_mst_rec	ic_whse_mst%ROWTYPE;
l_ic_lots_mst_rec 	ic_lots_mst%ROWTYPE;
l_message		VARCHAR2(1000);
i			NUMBER;
l_epsilon		NUMBER;
l_error_flag		VARCHAR2(1) DEFAULT FND_API.G_FALSE;
l_return_val		NUMBER:=0;
n			NUMBER;


l_allow_negative_inv	NUMBER;
l_overpick_enabled	VARCHAR2(2);
l_error_code            NUMBER;
l_delete_mark		NUMBER;
l_completed_ind 	NUMBER;
l_staged_ind		NUMBER;
l_reason_code           VARCHAR2(4) := NULL;               /* Bug 3700211 */


CURSOR oe_order_lines_cur(p_line_id IN NUMBER) IS
   SELECT flow_status_code
	  ,inventory_item_id
	  ,ship_from_org_id
	  ,schedule_ship_date
	  ,order_quantity_uom
	  ,ordered_quantity_uom2
	  ,ordered_quantity
	  ,ordered_quantity2
   FROM   oe_order_lines_all
   WHERE  line_id = p_line_id;

CURSOR reas_code_cur(p_reas_code IN VARCHAR2) IS
   SELECT reason_code
   FROM   sy_reas_cds
   WHERE  reason_code = p_reas_code
     AND  delete_mark <> 1;

CURSOR line_detail_id_Cur(p_line_id IN NUMBER) IS
   SELECT delivery_detail_id,move_order_line_id
   FROM   wsh_delivery_details
   WHERE  source_line_id = p_line_id;

CURSOR source_line_id_Cur(p_line_detail_id IN NUMBER) IS
   SELECT source_line_id
   FROM   wsh_delivery_details
   WHERE  delivery_detail_id = p_line_detail_id;

CURSOR ic_whse_mst_cur(p_organization_id IN NUMBER ) IS
   SELECT *
   FROM   IC_WHSE_MST
   WHERE  mtl_organization_id = p_organization_id;

CURSOR get_loct_inv_dtls_cur(p_item_id IN NUMBER
			    ,p_lot_id IN NUMBER
			    ,p_whse_code IN VARCHAR2
			    ,p_location IN VARCHAR) IS
   SELECT  loct_onhand
	  ,loct_onhand2
          ,lot_status
	  ,delete_mark
   FROM   ic_loct_inv
   WHERE  item_id    = p_item_id
     AND  lot_id     = NVL(p_lot_id ,0)
     AND  whse_code  = p_whse_code
     AND  location   = NVL(p_location,l_default_location);

CURSOR get_loct_inv_dtls_cur2(p_item_id IN NUMBER
			    ,p_lot_id IN NUMBER
			    ,p_whse_code IN VARCHAR2) IS
   SELECT  loct_onhand
	  ,loct_onhand2
          ,lot_status
	  ,delete_mark
   FROM   ic_loct_inv
   WHERE  item_id    = p_item_id
     AND  lot_id     = NVL(p_lot_id ,0)
     AND  whse_code  = p_whse_code;

CURSOR lot_status_cur(p_lot_status VARCHAR2) IS
   SELECT  nettable_ind
	  ,order_proc_ind
	  ,rejected_ind
     FROM   ic_lots_sts
    WHERE   lot_status  = p_lot_status;

CURSOR ic_loct_mst_cur(p_location IN VARCHAR2
		      ,p_whse_code IN VARCHAR2) IS
   SELECT delete_mark
   FROM   ic_loct_mst
   WHERE  location = p_location
     AND  whse_code = p_whse_code;

 CURSOR get_commited_qty_cur IS
    SELECT   NVL(ABS(SUM(trans_qty)),0)
	   , NVL(ABS(SUM(trans_qty2)),0)
      FROM IC_TRAN_PND a
     WHERE a.lot_id = l_ic_lots_mst_rec.lot_id
       AND a.item_id = l_ic_item_mst_rec.item_id
       AND a.location =  NVL(l_tran_rec.location ,l_default_location)
       AND a.whse_code = l_ic_whse_mst_rec.whse_code
       AND a.trans_id <> NVL(l_tran_rec.trans_id,0)
       AND a.delete_mark = 0
       AND a.completed_ind = 0
       AND a.trans_qty < 0;

-- BEGIN - BUG 2789268 Pushkar Upakare - Added p_line_id to following cursor.
CURSOR get_alloc_qty_for_ddl_cur(p_line_id IN NUMBER, p_line_detail_id IN NUMBER) IS
   SELECT NVL(ABS(SUM(trans_qty)),0)
	 ,NVL(ABS(SUM(trans_qty2)),0)
     FROM IC_TRAN_PND
    WHERE line_id = p_line_id
      AND line_detail_id = p_line_detail_id
      AND doc_type = 'OMSO'
      AND delete_mark = 0;
-- END BUG 2789268

CURSOR get_alloc_qty_for_line_cur(p_line_id IN NUMBER) IS
   SELECT NVL(ABS(SUM(trans_qty)),0)
	 ,NVL(ABS(SUM(trans_qty2)),0)
     FROM IC_TRAN_PND
    WHERE line_id = p_line_id
      AND doc_type = 'OMSO'
      AND delete_mark = 0;

CURSOR validate_trans_id_cur(p_trans_id IN NUMBER) IS
   SELECT delete_mark,completed_ind,staged_ind
     FROM ic_tran_pnd
    WHERE trans_id = p_trans_id;

CURSOR requested_qty_cur(p_line_detail_id IN NUMBER) IS
   SELECT requested_quantity,requested_quantity2
     FROM wsh_delivery_details
    WHERE delivery_detail_id = p_line_detail_id;

CURSOR mo_line_id_cur(p_line_detail_id IN NUMBER) IS
   SELECT move_order_line_id
     FROM wsh_delivery_details
    WHERE delivery_detail_id = p_line_detail_id;

/* Some More Variables */

l_loct_inv_rec		get_loct_inv_dtls_cur%ROWTYPE;
l_lot_status_rec	lot_status_cur%ROWTYPE;
l_commit_qty		NUMBER DEFAULT 0;
l_commit_qty2 		NUMBER DEFAULT 0;
l_onhand_qty 		NUMBER DEFAULT 0;
l_onhand_qty2 		NUMBER DEFAULT 0;
l_picked_qty	   	NUMBER DEFAULT 0;
l_picked_qty2	 	NUMBER DEFAULT 0;
l_available_qty	   	NUMBER DEFAULT 0;
l_available_qty2 	NUMBER DEFAULT 0;

BEGIN

    /*Init variables
    =========================================*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_default_lot := FND_PROFILE.VALUE('IC$DEFAULT_LOT');
   l_default_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
   l_allow_negative_inv := FND_PROFILE.VALUE('IC$ALLOWNEGINV');
   l_overpick_enabled := FND_PROFILE.VALUE('WSH_OVERPICK_ENABLED');

   --
   -- BUG 3581429 Added the following anonymous block
   --
   BEGIN
      l_epsilon := to_number(NVL(FND_PROFILE.VALUE('IC$EPSILON'),0)) ;
      n := (-1) * round(log(10,l_epsilon));
   EXCEPTION
      WHEN OTHERS THEN
         n := 9;
   END;

   /* Standard begin of API savepoint
   ===========================================*/
   SAVEPOINT Allocate_OPM_Orders_SP;

   /*Standard call to check for call compatibility.
      ==============================================*/

   IF NOT FND_API.compatible_api_call (
                                l_api_version,
                                p_api_version,
                                l_api_name,
                                G_PKG_NAME)
   THEN
      PrintMsg('FND_API.compatible_api_call failed');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   /* Check p_init_msg_list
    =========================================*/
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   /*Move allocation record to local variable
   ========================================*/
   l_tran_rec := p_tran_rec;
   l_tran_rec.location := UPPER(l_tran_rec.location);

   /* Print the input parameters to the Debug File
    ==============================================*/

    PrintMsg('The Input Parameters are :  ');
    PrintMsg('=========================   ');
    PrintMsg('	p_api_version		: '||p_api_version);
    PrintMsg('	p_init_msg_list		: '||p_init_msg_list);
    PrintMsg('	p_commit		: '||p_commit);
    PrintMsg('	p_tran_rec.trans_id	: '||p_tran_rec.trans_id);
    PrintMsg('	p_tran_rec.line_id	: '||p_tran_rec.line_id);
    PrintMsg('	p_tran_rec.line_detail_id :'||p_tran_rec.line_detail_id);
    PrintMsg('	p_tran_rec.lot_id 	: '||p_tran_rec.lot_id);
    PrintMsg('	p_tran_rec.lot_no 	: '||p_tran_rec.lot_no);
    PrintMsg('	p_tran_rec.sublot_no 	: '||p_tran_rec.sublot_no);
    PrintMsg('	p_tran_rec.location 	: '||p_tran_rec.location);
    PrintMsg('	p_tran_rec.trans_qty 	: '||p_tran_rec.trans_qty);
    PrintMsg('	p_tran_rec.trans_qty2 	: '||p_tran_rec.trans_qty2);
    PrintMsg('	p_tran_rec.trans_um 	: '||p_tran_rec.trans_um);
    PrintMsg('	p_tran_rec.trans_date 	: '||p_tran_rec.trans_date);
    PrintMsg('	p_tran_rec.reason_code  : '||p_tran_rec.reason_code);
    PrintMsg('	p_tran_rec.action_code  : '||p_tran_rec.action_code);
    PrintMsg('=========================   ');
    PrintMsg('   ');
    PrintMsg('   ');

    PrintMsg('PROFILE VALUES 	        :');
    PrintMsg('==========================   ');
    PrintMsg('IC$ALLOWNEGINV       : '||l_allow_negative_inv);
    PrintMsg('WSH_OVERPICK_ENABLED : '||l_overpick_enabled);
    PrintMsg('IC$DEFAULT_LOT       : '||l_default_lot);
    PrintMsg('IC$DEFAULT_LOCT      : '||l_default_location);
    PrintMsg('ROUNDING NUMBER      : '||n);
    PrintMsg('   ');


   /* Check action_code
     =======================================*/

   IF( UPPER(NVL(l_tran_rec.action_code, 'N')) not in ('INSERT', 'UPDATE', 'DELETE'))
   THEN
      PrintMsg('ERROR - Validation failed on action_code Only ');
      FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_ACTION_CODE');
      FND_MESSAGE.SET_TOKEN('ACTION_CODE ',l_tran_rec.action_code );
      FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /*====================================
    Validations
   ======================================*/


   /* Trans_id
   ==============*/
   IF( UPPER(NVL(l_tran_rec.action_code,'N')) IN ('DELETE','UPDATE'))
   THEN
      IF( NVL(l_tran_rec.trans_id,0) = 0 )
      THEN
         PrintMsg('ERROR - Validation failed for trans_id');
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GML','GMI_API_TRANS_ID_REQUIRED');
         FND_MESSAGE.SET_TOKEN('ACTION_CODE ',l_tran_rec.action_code );
         FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSIF( NVL(l_tran_rec.trans_id,0) <> 0)
   THEN
      PrintMsg('ERROR - Trans_id  not required for INSERT');
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_TRANS_ID_NOT_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ACTION_CODE ',l_tran_rec.action_code );
      FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF( UPPER(NVL(l_tran_rec.action_code,'N')) IN ('DELETE','UPDATE') AND
       NVL(l_tran_rec.trans_id,0) <> 0 )
   THEN

      OPEN validate_trans_id_cur(l_tran_rec.trans_id);
      FETCH validate_trans_id_cur INTO l_delete_mark,l_completed_ind,l_staged_ind;

      IF( validate_trans_id_cur%NOTFOUND)
      THEN
         CLOSE validate_trans_id_cur;
         PrintMsg('ERROR - Invalid Trans_id for action code : '||l_tran_rec.action_code);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GML','GMI_API_INVALID_TRANS_ID');
         FND_MESSAGE.SET_TOKEN('TRANS_ID',l_tran_rec.trans_id );
         FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.LINE_ID );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_delete_mark = 1)
      THEN
         CLOSE validate_trans_id_cur;
	 PrintMsg('ERROR - Invalid Trans_id Transaction is already deleted : '||l_tran_rec.trans_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GML','GMI_API_TRANS_DELETED');
         FND_MESSAGE.SET_TOKEN('TRANS_ID ',l_tran_rec.trans_id );
         FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_completed_ind = 1)
      THEN
 	 CLOSE validate_trans_id_cur;
	 PrintMsg('ERROR - Invalid Trans_id Transaction is already completed : '||l_tran_rec.trans_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GML','GMI_API_TRANS_COMPLETED');
         FND_MESSAGE.SET_TOKEN('TRANS_ID ',l_tran_rec.trans_id );
         FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_staged_ind = 1)
      THEN
         CLOSE validate_trans_id_cur;
	 PrintMsg('ERROR - Invalid Trans_id Transaction is already staged : '||l_tran_rec.trans_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GML','GMI_API_TRANS_STAGED');
         FND_MESSAGE.SET_TOKEN('TRANS_ID ',l_tran_rec.trans_id );
         FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


   END IF; /* action code 'DELETE' OR 'UPDATE' and trans_id <>0) */

   l_pick_lots_rec.trans_id := l_tran_rec.trans_id;

   PrintMsg('l_pick_lots_rec.trans_id   : '||l_pick_lots_rec.trans_id);

   /* Line_id
    ==============*/
   IF (NVL(l_tran_rec.line_id,0) = 0 )
   THEN
      PrintMsg('ERROR - validation failed on line id');
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','MISSING');
      FND_MESSAGE.SET_TOKEN('MISSING','line_id');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE

      OPEN oe_order_lines_cur(l_tran_rec.line_id);
      FETCH oe_order_lines_cur INTO l_line_status,l_inventory_item_id,
            l_ship_from_org_id,l_schedule_ship_date,l_ordered_quantity_uom,
	    l_ordered_quantity_uom2,l_ordered_quantity,l_ordered_quantity2;

      IF(oe_order_lines_cur%NOTFOUND)
      THEN
         PrintMsg('ERROR - in oe_order_lines_cur%NOTFOUND : Invalid line_id');
         l_error_flag := FND_API.G_TRUE;
         CLOSE oe_order_lines_cur;
         FND_MESSAGE.SET_NAME('GML','GMI_API_INVALID_LINE_ID');
         FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      PrintMsg('Quantity1 on the Sales Order Line is : '|| l_ordered_quantity);
      PrintMsg('Quantity2 on the Sales Order Line is : '|| l_ordered_quantity2);
      PrintMsg('Uom1 on the Sales Order Line is      : '|| l_ordered_quantity_uom);
      PrintMsg('Uom2 on the Sales Order Line is      : '|| l_ordered_quantity_uom2);
      PrintMsg('Sales Order Line Status is           : '|| l_line_status);
      PrintMsg('Sched Ship Date on the Sales Order Line is      : '|| l_schedule_ship_date);


      IF (oe_order_lines_cur%ISOPEN )
      THEN
         CLOSE oe_order_lines_cur;
      END IF;

      IF (l_line_status = 'CLOSED' OR l_line_status = 'CANCELLED' OR
          l_line_status = 'FULFILLED' OR l_line_status = 'SHIPPED')
      THEN

          PrintMsg('ERROR - Invalid line_status : '||l_line_status);
          l_error_flag := FND_API.G_TRUE;
	  FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_LINE_STATUS');
          FND_MESSAGE.SET_TOKEN('LINE_STATUS ',l_line_status);
          FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

      END IF;

      l_pick_lots_rec.line_id := l_tran_rec.line_id;
      l_pick_lots_rec.trans_um2 := l_ordered_quantity_uom2;

      PrintMsg('l_pick_lots_rec.line_id     : '||l_pick_lots_rec.line_id);
      PrintMsg('l_pick_lots_rec.trans_um2   : '||l_pick_lots_rec.trans_um2);


   END IF;  -- Line_id;

   /* Line_detail_id
    ====================*/

   /* If the line_detail_id is passed, see if it belongs to the line */
   IF ( NVL(l_tran_rec.line_detail_id,0) <> 0 )
   THEN
      OPEN source_line_id_cur(l_tran_rec.line_detail_id);
      FETCH source_line_id_cur INTO l_line_id;

      IF (source_line_id_cur%NOTFOUND)
      THEN
         PrintMsg('ERROR - source_line_id_cur%NOTFOUND, line_detail_id :'||
		   l_tran_rec.line_detail_id);
         CLOSE source_line_id_cur;
      END IF;

      IF(source_line_id_cur%ISOPEN)
      THEN
	 CLOSE source_line_id_cur;
      END IF;


      IF (l_line_id <> l_tran_rec.line_id)
      THEN
          PrintMsg('ERROR - Invalid line_detail_id : '||l_line_detail_id);
          l_error_flag := FND_API.G_TRUE;
          FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_LINE_DETAIL_ID');
          FND_MESSAGE.SET_TOKEN('LINE_DETAIL_ID ',l_tran_rec.line_detail_id);
          FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id);
          FND_MSG_PUB.Add;  /****  Define this message ****/
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_pick_lots_rec.line_detail_id := l_tran_rec.line_detail_id;


       /* Fetch the mo_line_id if there's one */

      OPEN mo_line_id_cur(l_tran_rec.line_detail_id);
      FETCH mo_line_id_cur INTO l_mo_line_id;
      IF (mo_line_id_cur%NOTFOUND)
      THEN
         l_mo_line_id := NULL;
         PrintMsg('No move order line for this delivery line. line_detail_id :'||
		l_tran_rec.line_detail_id);
         CLOSE mo_line_id_cur;
      END IF;

      IF(mo_line_id_cur%ISOPEN)
      THEN
         CLOSE mo_line_id_cur;
      END IF;

      PrintMsg('l_mo_line_id	: '||l_mo_line_id);

   ELSE  /*If line_detail_id is not passed fetch it from wsh_delivery_details*/

      SELECT count(*) into l_count
      FROM   wsh_delivery_details
      WHERE  source_line_id = l_tran_rec.line_id;

      /* if there there's more then one line_detail_id */
      IF ( l_count > 1 )
      THEN
          PrintMsg(' There are more than one delivery lines for this line_id : '||
			l_tran_rec.line_id || 'Please specify one');
 	  l_error_flag := FND_API.G_TRUE;
          FND_MESSAGE.SET_NAME('GMI','MISSING');
          FND_MESSAGE.SET_TOKEN('MISSING','Line_detail_id');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_count = 1)
      THEN
	  OPEN line_detail_id_cur(l_tran_rec.line_id);
	  FETCH line_detail_id_cur INTO l_line_detail_id,l_mo_line_id;

          IF(line_detail_id_cur%NOTFOUND)
 	  THEN
	      PrintMsg('ERROR - line_detail_id_cur%NOTFOUND for line_id'||
		 	l_tran_rec.line_id);
              l_error_flag := FND_API.G_TRUE;
 	      CLOSE line_detail_id_cur;
              FND_MESSAGE.SET_NAME('GMI','MISSING');
              FND_MESSAGE.SET_TOKEN('MISSING','Line_detail_id');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;

          END IF;

	  IF(line_detail_id_cur%ISOPEN)
          THEN
	     CLOSE line_detail_id_cur;
	  END IF;

          l_tran_rec.line_detail_id := l_line_detail_id;
          l_pick_lots_rec.line_detail_id := l_line_detail_id;


      ELSE
          l_tran_rec.line_detail_id := NULL;
          l_pick_lots_rec.line_detail_id := NULL;
      END IF;


   END IF;  /* If line_detail_id is not passed */

   PrintMsg('l_pick_lots_rec.line_detail_id   : '||l_pick_lots_rec.line_detail_id);

   /* Reason Code
    =============*/
   IF (l_tran_rec.reason_code IS NOT NULL) /* Bug 3700211 - Changed the in condition */
   THEN
      OPEN  reas_code_cur(l_tran_rec.reason_code);
      FETCH reas_code_cur INTO l_reason_code;
      IF (reas_code_cur%NOTFOUND)
      THEN
         PrintMsg('ERROR - Invalid reason_ code : '||l_tran_rec.reason_code);
         CLOSE reas_code_cur;
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_REASON_CODE');
         FND_MESSAGE.SET_TOKEN('REASON_CODE ',l_tran_rec.reason_code);
         FND_MESSAGE.SET_TOKEN('LINE_ID ',l_tran_rec.line_id);
         FND_MESSAGE.SET_TOKEN('TRANS_ID ',l_tran_rec.trans_id);
         FND_MESSAGE.SET_TOKEN('LINE_DETAIL_ID ',l_tran_rec.line_detail_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(reas_code_cur%ISOPEN)
      THEN
         CLOSE reas_code_cur;
      END IF;

      l_pick_lots_rec.reason_code := l_tran_rec.reason_code;
   ELSE
      l_pick_lots_rec.reason_code := NULL;
   END IF;

   PrintMsg('l_pick_lots_rec.reason_code   : '||l_pick_lots_rec.reason_code);

   /* Warehouse
    =============*/

    OPEN ic_whse_mst_cur(l_ship_from_org_id);
    FETCH ic_whse_mst_cur INTO l_ic_whse_mst_rec;

    IF(ic_whse_mst_cur%NOTFOUND)
    THEN
       PrintMsg('ic_whse_mst_cur%NOTFOUND for Organization '||l_ship_from_org_id);
       CLOSE ic_whse_mst_cur;
       l_error_flag := FND_API.G_TRUE;
       FND_MESSAGE.SET_NAME('GMI','GMI_API_WHSE_NOT_FOUND');
       FND_MESSAGE.SET_TOKEN('ORG', l_ship_from_org_id);
       FND_MESSAGE.SET_TOKEN('LINE_ID', l_tran_rec.line_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       CLOSE ic_whse_mst_cur;
    END IF;


    l_pick_lots_rec.whse_code := l_ic_whse_mst_rec.whse_code;

   PrintMsg('l_pick_lots_rec.whse_code     : '||l_pick_lots_rec.whse_code);
   PrintMsg('l_whse_mst_rec.loct_ctl       : '||l_ic_whse_mst_rec.loct_ctl);

  /* Item
  ========== */

   -- Get OPM Item Id from  Inventory_item_id
   Get_Item_Details(
           p_organization_id          => l_ship_from_org_id
         , p_inventory_item_id        => l_inventory_item_id
         , x_ic_item_mst_rec          => l_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data) ;


   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      PrintMsg('ERROR - Get Item Details returned Error ');
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.Set_Name('GMI','GMI_API_ITEM_NOT_FOUND');
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', l_inventory_item_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', l_ship_from_org_id);
      FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   PrintMsg('l_ic_item_mst_rec.dualum_ind     : '|| l_ic_item_mst_rec.dualum_ind);
   PrintMsg('l_ic_item_mst_rec.loct_ctl       : '|| l_ic_item_mst_rec.loct_ctl);
   PrintMsg('l_ic_item_mst_rec.lot_ctl        : '|| l_ic_item_mst_rec.lot_ctl);
   PrintMsg('l_ic_item_mst_rec.sublot_ctl     : '|| l_ic_item_mst_rec.sublot_ctl);
   PrintMsg('l_ic_item_mst_rec.status_ctl     : '|| l_ic_item_mst_rec.status_ctl);
   PrintMsg('l_ic_item_mst_rec.grade_ctl      : '|| l_ic_item_mst_rec.grade_ctl);    /* BUG 2966077 */

      /* Must not be a non inventory item */
   IF (l_ic_item_mst_rec.noninv_ind = 1)
   THEN
      PrintMsg('ERROR - Item is a non inventory item :'|| l_ic_item_mst_rec.item_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_NONINV_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

      /* Must be active */
   ELSIF (l_ic_item_mst_rec.inactive_ind = 1)
   THEN
      PrintMsg('ERROR - Inactive item :'|| l_ic_item_mst_rec.item_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_INACTIVE_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

      /* Item should not be a no control item */
   ELSIF (l_ic_item_mst_rec.lot_ctl = 0 AND (l_ic_item_mst_rec.loct_ctl = 0) )
   THEN
      PrintMsg('ERROR - No Controls  item :'|| l_ic_item_mst_rec.item_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_NO_CONTROL_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   /* See if either item is or the warehouse is not location controlled */
   IF( (l_ic_item_mst_rec.loct_ctl  * l_ic_whse_mst_rec.loct_ctl ) = 0 AND
       NVL(l_tran_rec.location,' ') = ' ')
   THEN
      PrintMsg('Either the item or the warehouse is not location controlled,
		default location will be used');
      l_tran_rec.location := l_default_location;

   END IF;


   /* Verify that item is lot/sublot controlled if lot/sublot or
      lot id are specified  */

   IF(( (NVL(p_tran_rec.lot_no,' ') <> ' ' AND p_tran_rec.lot_no <> l_default_lot)
	OR NVL(p_tran_rec.lot_id,0) <> 0) AND
       l_ic_item_mst_rec.lot_ctl <> 1 )
   THEN
      PrintMsg('ERROR - lot is specified but item is
			not lot controlled'|| l_ic_item_mst_rec.item_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_NOT_LOT_CONTROL_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO_',l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF( NVL(p_tran_rec.sublot_no,' ') <> ' '  AND
        	l_ic_item_mst_rec.sublot_ctl <> 1)
   THEN
      PrintMsg('ERROR - sublot is specified but item is not sublot controlled , Item_no : '||
		l_ic_item_mst_rec.item_no ||' Sublot_no : '|| p_tran_rec.sublot_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_SUBLOT_NOT_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_pick_lots_rec.item_id := l_ic_item_mst_rec.item_id;
   PrintMsg('l_pick_lots_rec.item_id    : '|| l_pick_lots_rec.item_id);

   /* Location
    ============  */

   /* If a location is specified verify that the item is location controlled
      and the warehouse is location controlled */

   IF ( NVL(l_tran_rec.location,' ') <> ' ' AND
        l_tran_rec.location <> l_default_location AND
       (l_ic_item_mst_rec.loct_ctl * l_ic_whse_mst_rec.loct_ctl) = 0)
   THEN
      PrintMsg('location is specified but either the item or the warehouse not location controlled :'
		|| l_ic_item_mst_rec.item_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_NON_LOCT_CTL_ITEM_WHSE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_ic_whse_mst_rec.whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_tran_rec.location);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   /* If a location is not specified and the item is location controlled */
   IF( NVL(l_tran_rec.location,' ') = ' '  AND
       (l_ic_item_mst_rec.loct_ctl * l_ic_whse_mst_rec.loct_ctl) <> 0 )
   THEN
      PrintMsg('location is NOT specified but item and warehouse are location controlled :'||
		l_ic_item_mst_rec.item_no);
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.SET_NAME('GMI','GMI_API_LOCATION_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_ic_item_mst_rec.item_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_ic_whse_mst_rec.whse_code);
      FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   /* If whse is non validated location controlled, do not validate location but verify that
      the length is <= 16 */

   IF ( l_ic_whse_mst_rec.loct_ctl * l_ic_whse_mst_rec.loct_ctl > 1)
   THEN
      IF( LENGTH(l_tran_rec.location) > 16 )
      THEN
         PrintMsg('Non validated location length can not be  > 16 : '||
		l_ic_item_mst_rec.item_no);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GMI','GMI_API_LOCT_INVALID_LENGTH');
         FND_MESSAGE.SET_TOKEN('LOCATION',l_tran_rec.location);
         FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

         /* This is not a non validated location */

   ELSIF(l_ic_whse_mst_rec.loct_ctl * l_ic_whse_mst_rec.loct_ctl = 1 AND NVL(l_tran_rec.location,' ') <> ' ')
   THEN
          /* In not non validated location */
      /* Check that the location is active */

     OPEN ic_loct_mst_cur( l_tran_rec.location,l_ic_whse_mst_rec.whse_code);
     FETCH ic_loct_mst_cur INTO l_loc_inactive;

     IF ic_loct_mst_cur%NOTFOUND
     THEN
         close ic_loct_mst_cur;
         PrintMsg('ic_loct_mst_cur%NOTFOUND - Location is not found : '|| l_tran_rec.location);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_LOCATION');
         FND_MESSAGE.SET_TOKEN('LOCATION',l_tran_rec.location);
         FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_loc_inactive = 1)
      THEN
         PrintMsg('Location Specified is NOT Active : '|| l_tran_rec.location);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_LOCATION');
         FND_MESSAGE.SET_TOKEN('LOCATION',l_tran_rec.location);
         FND_MESSAGE.SET_TOKEN('LINE_ID',l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF; /* non validated location */

   l_pick_lots_rec.location := UPPER(l_tran_rec.location);

   PrintMsg('l_pick_lots_rec.location    : '|| l_pick_lots_rec.location);

   /* Lot/Sublot - Lot_id
    ======================== */

   /* Get lot details from ic_lots_mst */

  IF (l_ic_item_mst_rec.lot_ctl <> 0 )
  THEN

     Get_Lot_Details(
		l_ic_item_mst_rec.item_id
		,l_tran_rec.lot_no
		,l_tran_rec.sublot_no
		,l_tran_rec.lot_id
		,l_ic_lots_mst_rec
		,x_return_status
		,x_msg_count
		,x_msg_data);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
         PrintMsg(' Get_Lot_Details failed, Lot_no :'||l_tran_rec.lot_no||
		' lot_id : '||l_tran_rec.lot_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_LOT_NOT_FOUND');
         FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('SUBLOT_NO', l_tran_rec.sublot_no);
         FND_MESSAGE.Set_Token('LOT_ID', l_tran_rec.lot_id);
         FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_tran_rec.lot_no := l_ic_lots_mst_rec.lot_no;

      /* Make sure the lot is active */
      IF( l_ic_lots_mst_rec.inactive_ind = 1)
      THEN
         PrintMsg(' ERROR : Lot is not active , Lot_no : '||l_tran_rec.lot_no||
		'  lot_id : '||l_tran_rec.lot_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_INACTIVE_LOT');
         FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* Is it expired? */
      IF( l_ic_lots_mst_rec.expire_date <  SYSDATE)
      THEN
         PrintMsg(' Lot is Expired , Lot_no '||l_tran_rec.lot_no||
		', lot_id : '||l_tran_rec.lot_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_EXPIRED_LOT');
         FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* Is it Deleted? */
      IF( l_ic_lots_mst_rec.delete_mark = 1)
      THEN
         PrintMsg(' Lot is Deleted , Lot_no '||l_tran_rec.lot_no||
		'lot_id : '||l_tran_rec.lot_id);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_DELETED_LOT');
         FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- BEGIN BUG 2966077
      -- Is GRADE null for grade controlled item?
      IF( NVL(l_ic_item_mst_rec.grade_ctl, 0) > 0 AND l_ic_lots_mst_rec.qc_grade IS NULL)
      THEN
         PrintMsg(' GRADE for LOT '||l_tran_rec.lot_no ||' IS NOT VALID');
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','IC_INVALID_QC_GRADE');
         FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --END BUG 2966077

   ELSE /* item is not lot controlled */

      l_ic_lots_mst_rec.lot_id := 0;

   END IF; /* if item is lot_ctl */

   /* Get lot_status from ic_loct_inv */

--  IF( l_ic_item_mst_rec.status_ctl > 0 ) /* check  */
--  THEN

   PrintMsg ('  ** Item_id   : '|| l_ic_item_mst_rec.item_id);
   PrintMsg ('  ** lot_id    : '|| l_ic_lots_mst_rec.lot_id);
   PrintMsg ('  ** Whse_code : '|| l_ic_whse_mst_rec.whse_code);
   PrintMsg ('  ** location  : '|| l_tran_rec.location);

   OPEN get_loct_inv_dtls_cur(l_ic_item_mst_rec.item_id
	        ,l_ic_lots_mst_rec.lot_id
		,l_ic_whse_mst_rec.whse_code
		,l_tran_rec.location);

   FETCH get_loct_inv_dtls_cur INTO l_loct_inv_rec;

   IF (get_loct_inv_dtls_cur%NOTFOUND)
   THEN

      /* What if the warehouse is non location controlled? */

      IF( l_ic_whse_mst_rec.loct_ctl * l_ic_whse_mst_rec.loct_ctl > 1)
      THEN
         OPEN get_loct_inv_dtls_cur2(l_ic_item_mst_rec.item_id
		                  ,l_ic_lots_mst_rec.lot_id
				  ,l_ic_whse_mst_rec.whse_code);

	 FETCH get_loct_inv_dtls_cur2 INTO l_loct_inv_rec;

         IF(get_loct_inv_dtls_cur2%NOTFOUND)
         THEN
            CLOSE get_loct_inv_dtls_cur2;
	    PrintMsg('No inventory in ic_loct_inv for the item, whse,lot combination ');
            --l_error_flag := FND_API.G_TRUE;
            --FND_MESSAGE.Set_Name('GMI','GMI_API_NO_INVENTORY');
            --FND_MESSAGE.Set_Token('item_no', l_ic_item_mst_rec.item_no);
            --FND_MESSAGE.Set_Token('lot_no', l_tran_rec.lot_no);
            --FND_MSG_PUB.Add;
            --RAISE FND_API.G_EXC_ERROR;
         ELSE
            CLOSE get_loct_inv_dtls_cur2;
         END IF;

      ELSE /* Else print that the row is not found in ic_loct_inv */

          CLOSE get_loct_inv_dtls_cur;
          PrintMsg('No inventory in ic_loct_inv for the item, whse,lot,location combination ');
          --l_error_flag := FND_API.G_TRUE;
          --FND_MESSAGE.Set_Name('GMI','GMI_API_NO_INVENTORY');
          --FND_MESSAGE.Set_Token('item_no', l_ic_item_mst_rec.item_no);
          --FND_MESSAGE.Set_Token('lot_no', l_tran_rec.lot_no);
          --FND_MSG_PUB.Add;
          --RAISE FND_API.G_EXC_ERROR;
      END IF;

   ELSE
      CLOSE get_loct_inv_dtls_cur;
   END IF;

   l_onhand_qty  := l_loct_inv_rec.loct_onhand;
   l_onhand_qty2 := l_loct_inv_rec.loct_onhand2;

   PrintMsg('l_onhand_qty  from ic_loct_inv    : '|| l_onhand_qty);
   PrintMsg('l_onhand_qty2 from ic_loct_inv    : '|| l_onhand_qty2);


   IF( l_ic_item_mst_rec.status_ctl > 0 )
   THEN

      OPEN lot_status_cur(l_loct_inv_rec.lot_status);
      FETCH lot_status_cur INTO l_lot_status_rec;

      IF (lot_status_cur%NOTFOUND)
      THEN
         CLOSE lot_status_cur;
         PrintMsg('ERROR - No row in ic_lots_sts');
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_LOT_STATUS_NOT_FOUND');
	 FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
	 FND_MESSAGE.Set_Token('LOT_STATUS', l_loct_inv_rec.lot_status);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;

      ELSE
         CLOSE lot_status_cur;
      END IF;

      IF(  l_lot_status_rec.rejected_ind = 1 )
      THEN
         PrintMsg('Rejected ind is 1 - unusable lot'|| l_ic_lots_mst_rec.lot_no);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GMI','GMI_API_REJECTED_LOT');
	 FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      IF(l_lot_status_rec.order_proc_ind = 0)
      THEN
         PrintMsg('Order_proc_ind is 0 - unusable lot'|| l_ic_lots_mst_rec.lot_no);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.SET_NAME('GMI', 'GMI_API_LOT_NOT_ORDERABLE');
	 FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_lot_status_rec.nettable_ind <> 1)
      THEN
         PrintMsg('Lot is not Nettable Lot_no :'||l_ic_lots_mst_rec.lot_no);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_LOT_NOT_NETTABLE');
	 FND_MESSAGE.Set_Token('LOT_NO', l_tran_rec.lot_no);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF; /* Status_ctl >0  */

   l_pick_lots_rec.lot_id := l_ic_lots_mst_rec.lot_id;
   l_pick_lots_rec.lot_status := l_loct_inv_rec.lot_status;

   PrintMsg('l_pick_lots_rec.lot_id	: '||l_pick_lots_rec.lot_id);

   -- BEGIN BUG 2966077
   IF ( NVL(l_ic_item_mst_rec.grade_ctl, 0) > 0) THEN
      l_pick_lots_rec.qc_grade := l_ic_lots_mst_rec.qc_grade;
      PrintMsg('l_pick_lots_rec.qc_grade : '||l_pick_lots_rec.qc_grade);
   END IF;
   --END BUG 2966077

   /* Trans_uom
   ===============*/

   /* The passed uom is always 3 char apps UOM.
      If passed check if it's different from item's primary,if so see if
     conversion exists */

   IF ( NVL(l_tran_rec.trans_um,' ') = ' ')
   THEN
      PrintMsg('ERROR - Trans_um is not passed ');
      l_error_flag := FND_API.G_TRUE;
      FND_MESSAGE.Set_Name('GMI','GMI_API_UOM_REQUIRED');
      FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
      FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   ELSE  /* l_tran_rec.trans_um is NOT NULL */

      gmi_reservation_util.Get_AppsUOM_from_OpmUOM(
            p_OPM_UOM                 => l_ic_item_mst_rec.item_um
          , x_Apps_UOM                 => l_apps_um
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         PrintMsg('ERROR - uom conversion does not exist for: '||l_ic_item_mst_rec.item_um);
         l_error_flag := FND_API.G_TRUE;
         FND_MESSAGE.Set_Name('GMI','GMI_API_APPS_UOM_NOT_FOUND');
         FND_MESSAGE.Set_Token('OPM_UOM',l_ic_item_mst_rec.item_um);
         FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF ( l_tran_rec.trans_um <> l_apps_um )
      THEN

          GMI_RESERVATION_UTIL.Get_OPMUOM_from_AppsUOM(
              p_apps_uom         =>l_tran_rec.trans_um,
              x_opm_uom          =>l_opm_um,
              x_return_status    =>x_return_status,
              x_msg_count        =>x_msg_count,
              x_msg_data         =>x_msg_data);

          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             PrintMsg('ERROR: OPM UOM not found for apps uom : '|| l_tran_rec.trans_um);
             l_error_flag := FND_API.G_TRUE;
             FND_MESSAGE.Set_Name('GMI','GMI_API_OPM_UOM_NOT_FOUND');
             FND_MESSAGE.Set_Token('APPS_UOM', l_tran_rec.trans_um);
             FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          PrintMsg('to uom (OPM) '||l_opm_um);

          GMICUOM.icuomcv(
              pitem_id         =>l_ic_item_mst_rec.item_id,
              plot_id          =>l_ic_lots_mst_rec.lot_id,
              pcur_qty         =>l_tran_rec.trans_qty,
              pcur_uom         =>l_opm_um,
              pnew_uom         =>l_ic_item_mst_rec.item_um,
              onew_qty         =>l_tmp_qty);


          PrintMsg('converted_qty l_tmp_qty before rounding : '|| l_tmp_qty);

      	  l_tmp_qty:=round(l_tmp_qty, n);

          PrintMsg('converted_qty l_tmp_qty after rounding : '|| l_tmp_qty);


          IF( NVL(l_tmp_qty, -1) < 0 )
          --IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   	  THEN
             PrintMsg('ERROR - from GMICUOM.icuomcv, pcur_uom : ' || l_opm_um || 'pnew_uom : '||l_ic_item_mst_rec.item_um);
             l_error_flag := FND_API.G_TRUE;
             FND_MESSAGE.Set_Name('GMI','GMI_API_UOM_CONV_NOT_FOUND');
             FND_MESSAGE.Set_Token('FROM_UOM', l_opm_um);
             FND_MESSAGE.Set_Token('TO_UOM', l_ic_item_mst_rec.item_um);
             FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
             FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;

          ELSE
             l_pick_lots_rec.trans_qty := l_tmp_qty;
	    -- l_pick_lots_rec.trans_um  := l_ic_item_mst_rec.item_um;
	     l_pick_lots_rec.trans_um  := l_apps_um;
          END IF;

      ELSE  /* l_tran_rec.trans_um = l_apps_um */


         l_pick_lots_rec.trans_qty := l_tran_rec.trans_qty;
        -- l_pick_lots_rec.trans_um  := l_ic_item_mst_rec.item_um;
         l_pick_lots_rec.trans_um  := l_apps_um;
         l_tmp_qty := l_tran_rec.trans_qty;
      END IF;

      PrintMsg('l_pick_lots_rec.trans_um	: '||l_pick_lots_rec.trans_um);
      PrintMsg('l_pick_lots_rec.trans_qty	: '||l_pick_lots_rec.trans_qty);

    END IF; /* IF ( NVL(l_tran_rec.trans_um,' ') = ' ')  */


   /*Trans_qty2
   ===============*/


   /* if the action_code is Insert or Update and Item is dual controlled then
      this should be > 0. If not supplied will be defaulted for dual1 and dual2. */

   IF( UPPER(NVL(l_tran_rec.action_code, 'N')) in('INSERT', 'UPDATE')
       AND l_ic_item_mst_rec.dualum_ind > 0 )
   THEN

      GMICUOM.icuomcv( pitem_id  => l_ic_item_mst_rec.item_id,
                          plot_id   => l_ic_lots_mst_rec.lot_id,
                          pcur_qty  => l_tmp_qty,
                          pcur_uom  => l_ic_item_mst_rec.item_um,
                          pnew_uom  => l_ic_item_mst_rec.item_um2,
                          onew_qty  => l_tmp_qty2);

      PrintMsg('converted_qty l_tmp_qty2  before rounding'|| l_tmp_qty2);
      l_tmp_qty2:=round(l_tmp_qty2, n);
      PrintMsg('converted_qty l_tmp_qty2  after rounding'|| l_tmp_qty2);


      IF( NVL(l_tran_rec.trans_qty2,0)= 0 )
      THEN
         IF ( l_ic_item_mst_rec.dualum_ind in (1,2))
         THEN
            l_pick_lots_rec.trans_qty2 := l_tmp_qty2;

         ELSIF(l_ic_item_mst_rec.dualum_ind = 3)
         THEN
	    PrintMsg('ERROR - Trans_qty2 for a dual3 item Can not be NULL. Please provide
		  a valid trans_qty2 ');
            l_error_flag := FND_API.G_TRUE;
            FND_MESSAGE.Set_Name('GMI','GMI_API_QTY2_REQUIRED_DUAL3');
            FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
            FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      ELSE  /* trans_qty2 is not 0,in this case check deviation */

         IF (nvl(l_ic_item_mst_rec.deviation_hi,0) <> 0 AND
		l_tran_rec.trans_qty2 > l_tmp_qty2 *(1 + l_ic_item_mst_rec.deviation_hi)) THEN
	    PrintMsg('ERROR - Trans_qty2 Deviation Hi error ');
	    l_error_flag := FND_API.G_TRUE;
            FND_MESSAGE.SET_NAME('GMI','GMI_API_DEVIATION_ERR');
            FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
            FND_MESSAGE.Set_Token('QTY', l_pick_lots_rec.trans_qty);
            FND_MESSAGE.Set_Token('QTY2', l_tran_rec.trans_qty2);
            FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;

         ELSIF (nvl(l_ic_item_mst_rec.deviation_lo,0)<>0 AND
		l_tran_rec.trans_qty2 < l_tmp_qty2 * (1-l_ic_item_mst_rec.deviation_lo)) THEN
	    PrintMsg('ERROR - Trans_qty2 Deviation Lo error ');
            l_error_flag := FND_API.G_TRUE;
            FND_MESSAGE.SET_NAME('GMI','GMI_API_DEVIATION_ERR');
            FND_MESSAGE.Set_Token('QTY', l_pick_lots_rec.trans_qty);
            FND_MESSAGE.Set_Token('QTY2', l_tran_rec.trans_qty2);
            FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
            FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;

         END IF;

         l_pick_lots_rec.trans_qty2 := NVL(l_tran_rec.trans_qty2,0);


      END IF; /* If trans_qty2 = 0) */

      PrintMsg('l_pick_lots_rec.trans_qty2 : '||l_pick_lots_rec.trans_qty2);

   END IF; /* Action code */


   /*Trans_qty
   ===============*/
   /* For action code Insert or Update trans_qty must be > 0) */
   IF (UPPER(NVL(l_tran_rec.action_code, 'N'))in ('INSERT', 'UPDATE'))
   THEN
      IF( NVL(l_tran_rec.trans_qty,0) <= 0 )
      THEN
	  PrintMsg('ERROR - trans_qty Has to be > 0 For actions INSERT and Update ');
          l_error_flag := FND_API.G_TRUE;
          FND_MESSAGE.Set_Name('GMI','GMI_API_QTY_REQ_FOR_ACT_CODE');
          FND_MESSAGE.Set_Token('ACTION_CODE', l_tran_rec.action_code);
          FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN  get_commited_qty_cur;
      FETCH get_commited_qty_cur
      INTO  l_commit_qty
      	   ,l_commit_qty2;
      IF(get_commited_qty_cur%NOTFOUND)
      THEN
         PrintMsg('ERROR - get_commited_qty_cur%NOTFOUND ');
         CLOSE get_commited_qty_cur;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         CLOSE get_commited_qty_cur;
      END IF;

      PrintMsg('l_commit_qty	: '|| l_commit_qty);
      PrintMsg('l_commit_qty2	: '|| l_commit_qty2);

      l_commit_qty2 := round(l_commit_qty2, n);
      PrintMsg('l_commit_qty2 after rounding : '|| l_commit_qty2);


      l_available_qty    := l_onhand_qty  - l_commit_qty;
      l_available_qty2   := l_onhand_qty2  - l_commit_qty2;

      PrintMsg('l_available_qty (onhand - commited) : '|| l_available_qty);
      PrintMsg('l_available_qty2			   : '|| l_available_qty2);
      PrintMsg('  ');

      /* Check if -ve inventory is allowed */

      IF(l_allow_negative_inv <> 1)  THEN
         IF ( (l_pick_lots_rec.trans_qty > l_available_qty) OR
              ( NVL(l_pick_lots_rec.trans_qty2,0) > NVL(l_available_qty2,0)) )
         THEN
            IF(l_allow_negative_inv = 0) THEN
               PrintMsg('ERROR - -ve inventory is not allowed. This allocation would  drive the inventory -ve. ');
               l_error_flag := FND_API.G_TRUE;
               FND_MESSAGE.SET_NAME('GMI','GMI_API_INVQTYNEG');
               FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;

            ELSIF(l_allow_negative_inv = 2) THEN
               PrintMsg('Warning - This allocation would drive the inventory -ve. ');
               FND_MESSAGE.SET_NAME('GMI','GMI_API_WARNINVQTYNEG');
               FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
               FND_MSG_PUB.Add;
            END IF;
         END IF;
      END IF; /* Check -ve inventory */


      IF (NVL(l_tran_rec.line_detail_id,0) <> 0 )
      THEN
         -- BEGIN - BUG 2789268 Pushkar Upakare - Passed p_line_id to get_alloc_qty_for_ddl_cur cursor.
         OPEN  get_alloc_qty_for_ddl_cur(l_tran_rec.line_id, l_tran_rec.line_detail_id);
         -- END - BUG 2789268

         FETCH get_alloc_qty_for_ddl_cur INTO
             l_picked_qty,l_picked_qty2;

         IF(get_alloc_qty_for_ddl_cur%NOTFOUND)
         THEN
            PrintMsg('ERROR - get_alloc_qty_for_ddl_cur%NOTFOUND');
            CLOSE get_alloc_qty_for_ddl_cur;
         END IF;

         IF(get_alloc_qty_for_ddl_cur%ISOPEN )
         THEN
            CLOSE get_alloc_qty_for_ddl_cur;
         END IF;

         PrintMsg('Picked quantities for Delivery Detail are : ');
	 PrintMsg('---------------------------------------------');
	 PrintMsg('l_picked_qty	 : '|| l_picked_qty);
	 PrintMsg('l_picked_qty2 : '|| l_picked_qty2);
	 PrintMsg('---------------------------------------------');
         PrintMsg('  ');

      ELSE

         OPEN get_alloc_qty_for_line_cur(l_tran_rec.line_id);
         FETCH get_alloc_qty_for_line_cur INTO
             l_picked_qty ,l_picked_qty2;

         IF(get_alloc_qty_for_line_cur%NOTFOUND)
         THEN
            PrintMsg('ERROR - get_alloc_qty_for_line_cur%NOTFOUND');
            CLOSE get_alloc_qty_for_line_cur;
         END IF;

         IF(get_alloc_qty_for_line_cur%ISOPEN )
         THEN
 	    CLOSE get_alloc_qty_for_line_cur;
         END IF;

         PrintMsg('Picked quantities for the line are : ');
	 PrintMsg('---------------------------------------------');
	 PrintMsg('l_picked_qty	 : '|| l_picked_qty);
	 PrintMsg('l_picked_qty2 : '|| l_picked_qty2);
	 PrintMsg('---------------------------------------------');
	 PrintMsg('  ');

      END IF;

      /* Check if lot is indivisible */

      IF(l_ic_item_mst_rec.lot_indivisible = 1)
      THEN

	 IF ( (l_pick_lots_rec.trans_qty < l_available_qty) OR
            (  NVL(l_pick_lots_rec.trans_qty2,0)  < NVL(l_available_qty2,0) )) /* check trans_qty2 */
         THEN
            IF ( NVL(l_overpick_enabled,'N') = 'Y')
            THEN

	       PrintMsg('**Lot is indivisible. trans_qty is less than available qty and
			 over picking is enabled. Hence set the trans_qty = available_qty');

	       l_pick_lots_rec.trans_qty := l_available_qty;
	       l_pick_lots_rec.trans_qty2 := l_available_qty2;

               PrintMsg('l_pick_lots_rec.trans_qty	: '|| l_pick_lots_rec.trans_qty);
               PrintMsg('l_pick_lots_rec.trans_qty2	: '|| l_pick_lots_rec.trans_qty2);
	       PrintMsg('  ');

            ELSE  /* Over Picking is not enabled and the lot is indivisible. so error */
	       PrintMsg('ERROR - lot is indivisible. trans_qty is less than
				available qty and over picking is not enabled');
               l_error_flag := FND_API.G_TRUE;
               FND_MESSAGE.Set_Name('GMI','GMI_API_LOT_INDIV_NO_OVEPIC');
               FND_MESSAGE.Set_Token('LOT_NO', l_ic_lots_mst_rec.lot_no);
               FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
               FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;

            END IF;
         ELSIF ( (l_pick_lots_rec.trans_qty > l_available_qty) OR
		 ( NVL(l_pick_lots_rec.trans_qty2,0) > NVL(l_available_qty2,0) ) )
         THEN

	    PrintMsg('trans_qty is greater than available qty and Hence set the trans_qty = available_qty');

            l_pick_lots_rec.trans_qty := l_available_qty;
            l_pick_lots_rec.trans_qty2 := l_available_qty2;

            PrintMsg('l_pick_lots_rec.trans_qty	 : '|| l_pick_lots_rec.trans_qty);
            PrintMsg('l_pick_lots_rec.trans_qty2 : '|| l_pick_lots_rec.trans_qty2);
            PrintMsg('  ');

         END IF;

     END IF; /* Lot indivisible */


     /* Also, if the over pick is not enabled then, make sure that by allocating
        the trans_qty we are not over-picking */

      IF ( NVL(l_overpick_enabled,'N') = 'N')
      THEN
         IF (NVL(l_tran_rec.line_detail_id,0) <> 0 )
         THEN

            /* Get the requested_quantities */

            OPEN  requested_qty_cur(l_tran_rec.line_detail_id);
            FETCH requested_qty_cur INTO
                  l_requested_quantity,l_requested_quantity2;

            IF(requested_qty_cur%NOTFOUND)
            THEN
               PrintMsg('ERROR - requested_qty_cur%NOTFOUND');
               CLOSE requested_qty_cur;
            END IF;

            IF(requested_qty_cur%ISOPEN )
            THEN
               CLOSE requested_qty_cur;
            END IF;

            PrintMsg('Requested quantities for Delivery Detail are : ');
            PrintMsg('---------------------------------------------');
            PrintMsg('l_requested_quantity  : '|| l_requested_quantity);
            PrintMsg('l_requested_quantity2 : '|| l_requested_quantity2);
            PrintMsg('---------------------------------------------');
            PrintMsg('  ');

         ELSE  /* The ordered quantity would be the requested quantity */

             /* Convert the Ordered_quantity to item's Primary  If the ordered_quantity is not
	        In Item's Primary Uom */
             IF (l_ordered_quantity_uom <> l_apps_um)
             THEN
                l_requested_quantity := 0;
                PrintMsg('Ordered Quantity is not in Items primary uom. So convert');

                GMI_RESERVATION_UTIL.Get_OPMUOM_from_AppsUOM(
              		p_apps_uom         =>l_ordered_quantity_uom,
              		x_opm_uom          =>l_opm_um,
              	        x_return_status    =>x_return_status,
                        x_msg_count        =>x_msg_count,
                        x_msg_data         =>x_msg_data);

          	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             	   PrintMsg('ERROR: OPM UOM not found for apps uom : '|| l_ordered_quantity_uom);
                   l_error_flag := FND_API.G_TRUE;
                   FND_MESSAGE.Set_Name('GMI','GMI_API_OPM_UOM_NOT_FOUND');
             	   FND_MESSAGE.Set_Token('APPS_UOM', l_ordered_quantity_uom);
             	   FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
             	   FND_MSG_PUB.Add;
             	   RAISE FND_API.G_EXC_ERROR;
                 END IF;

		 GMICUOM.icuomcv(
              		pitem_id         =>l_ic_item_mst_rec.item_id,
              		plot_id          =>l_ic_lots_mst_rec.lot_id,
              		pcur_qty         =>l_ordered_quantity,
              		pcur_uom         =>l_opm_um,
              		pnew_uom         =>l_ic_item_mst_rec.item_um,
              		onew_qty         =>l_requested_quantity);

          	 PrintMsg('converted_qty l_requested_quantity  before rounding'|| l_requested_quantity);

          	 l_requested_quantity:=round(l_requested_quantity, n);

          	 PrintMsg('converted_qty l_requested_quantity  after rounding'|| l_requested_quantity);


             ELSE /* l_ordered_quantity_uom = l_apps_um */

                l_requested_quantity :=  l_ordered_quantity;
                PrintMsg('Converted quantity( Items uom) for Sales Order line is : '
			 || l_requested_quantity);
	        PrintMsg('	');

             END IF;

	     l_requested_quantity2 := l_ordered_quantity2;

            PrintMsg('---------------------------------------------');
            PrintMsg('l_quantity  : '|| l_requested_quantity);
            PrintMsg('l_quantity2 : '|| l_requested_quantity2);
            PrintMsg('---------------------------------------------');
	    PrintMsg('	');

         END IF;

         /* Check whether we would be Over Picking by allocating the Specified Quantity */

         IF( (l_pick_lots_rec.trans_qty > (l_requested_quantity - l_picked_qty)))
             /* Not checking for qty2  */
	     --	OR (NVL(l_pick_lots_rec.trans_qty2,0) >
             --	( NVL(l_requested_quantity2,0) - NVL(l_picked_qty2,0)))
	 THEN

               PrintMsg('trans_qty  	     : '|| l_pick_lots_rec.trans_qty);
               PrintMsg('requested_quantity  : '|| l_requested_quantity);
               PrintMsg('picked_qty  	     : '|| l_picked_qty);
	       PrintMsg('	');
               PrintMsg('trans_qty2  	     : '|| l_pick_lots_rec.trans_qty2);
               PrintMsg('requested_quantity2 : '|| l_requested_quantity2);
               PrintMsg('picked_qty2  	     : '|| l_picked_qty2);
	       PrintMsg('	');
	       PrintMsg('ERROR - Over picking is not enabled');
               l_error_flag := FND_API.G_TRUE;
               FND_MESSAGE.Set_Name('GMI','GMI_API_OVERPICK_NOT_ALLOWED');
               FND_MESSAGE.Set_Token('ITEM_NO', l_ic_item_mst_rec.item_no);
               FND_MESSAGE.Set_Token('LINE_ID', l_tran_rec.line_id);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF; /* Over pick not enabled */

   END IF; /* Action code */

   IF (l_tran_rec.action_code = 'DELETE')
   THEN
      l_pick_lots_rec.trans_qty := 0;
      l_pick_lots_rec.trans_qty := 0;

      PrintMsg('l_pick_lots_rec.trans_qty	: '||l_pick_lots_rec.trans_qty);
      PrintMsg('l_pick_lots_rec.trans_qty2	: '||l_pick_lots_rec.trans_qty2);

   END IF;

   /*Trans_date
   ==============*/
   /* If trans date is not passed, assign schedule_ship_date */

   IF ( l_tran_rec.trans_date IS NULL)
   THEN
      l_tran_rec.trans_date := l_schedule_ship_date;
   END IF;

   /* Validate the transaction date */

   l_return_val := GMICCAL.trans_date_validate
                      (l_tran_rec.trans_date,
                       l_ic_whse_mst_rec.orgn_code,
                       l_ic_whse_mst_rec.whse_code
                      );

   IF l_return_val <> 0 THEN

    IF l_return_val = GMICCAL.INVCAL_FISCALYR_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_CAL_FISCALYR_ERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_PERIOD_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_CAL_CLOSED_IND_ERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_ORGN_PARM_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_INVALID_ORGN_ERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_CO_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_COCODEERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_WHSE_PARM_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_BLANKWHSE');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_WHSE_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_WHSE_CODE');
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_ic_whse_mst_rec.whse_code);
      FND_MSG_PUB.Add;
    ELSIF l_return_val IN (GMICCAL.INVCAL_PERIOD_CLOSED,
                           GMICCAL.INVCAL_WHSE_CLOSED) THEN

      FND_MESSAGE.SET_NAME('GMI','IC_API_TXN_POST_CLOSED');
      FND_MESSAGE.SET_TOKEN('DATE',l_tran_rec.trans_date);
      FND_MESSAGE.SET_TOKEN('WAREH',l_ic_whse_mst_rec.whse_code);
      FND_MSG_PUB.Add;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','ICCAL_GENL_ERR');
      FND_MSG_PUB.Add;
    END IF;
    l_error_flag := FND_API.G_TRUE;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   l_pick_lots_rec.trans_date := l_tran_rec.trans_date;

    IF(l_error_flag = FND_API.G_TRUE)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --RAISE FND_API.G_EXC_ERROR;
      RETURN;
    END IF;

   /* Build the record for Set_Pick_Lots Private API
   ==================================================*/
   GMI_RESERVATION_UTIL.Set_Pick_Lots (
		p_ic_tran_rec    => l_pick_lots_rec
      	      , p_mo_line_id     => l_mo_line_id
 	      , p_commit	 => p_commit
   	      , x_return_status  => x_return_status
   	      , x_msg_count      => x_msg_count
   	      , x_msg_data 	 => x_msg_data );


   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      PrintMsg('in allocate_opm_orders.call to
			set_pick_lots returns error');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('GMI','GMI_SET_PIC_LOTS_ERROR');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', l_ship_from_org_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', l_inventory_item_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
      RETURN;
   ELSE
      PrintMsg('Successfully returning from Allocate_OPM_Orders');
   END IF;


/* EXCEPTION HANDLING
====================*/
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT Allocate_Opm_Orders_SP;


      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVEPOINT Allocate_Opm_Orders_SP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
         FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Allocate_Opm_Orders_SP;
       FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Allocate_OPM_Orders;

/*--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Lot_Details                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve lot master details                                  |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_lots_mst      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_id      IN  NUMBER       - Item ID of lot to be retrieved     |
--|    p_lot_no       IN  VARCHAR2(32) - Lot number of lot to be retrieved  |
--|    p_sublot_no    IN  VARCHAR2(32) - Sublot number to be retrieved      |
--|    p_lot_id       IN  NUMBER       - lot id to be retrieved             |
--|    x_ic_lots_mst  OUT RECORD       - Record containing ic_lots_mst      |
--|    x_return_status OUT VARCHAR2    					    |
--|    x_msg_count    OUT NUMBER 					    |
--|    x_msg_data     OUT VARCHAR2					    |
--|                                                                         |
--| HISTORY                                                                 |
--|    16-SEP-2002      NC            Created                               |
--+=========================================================================+*/
PROCEDURE Get_Lot_Details
( p_item_id  	    IN          ic_lots_mst.item_id%TYPE
, p_lot_no	    IN          ic_lots_mst.lot_no%TYPE
, p_sublot_no	    IN          ic_lots_mst.sublot_no%TYPE
, p_lot_id	    IN          ic_lots_mst.lot_id%TYPE
, x_ic_lots_mst     OUT  NOCOPY ic_lots_mst%ROWTYPE
, x_return_status   OUT  NOCOPY VARCHAR2
, x_msg_count	    OUT  NOCOPY NUMBER
, x_msg_data        OUT  NOCOPY VARCHAR2
)
IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Lot_Details';

CURSOR ic_lots_mst_c1 IS
SELECT *
FROM ic_lots_mst
WHERE
    lot_no      = p_lot_no
AND ( sublot_no   = p_sublot_no OR
      sublot_no is NULL)
AND item_id     = p_item_id;

CURSOR ic_lots_mst_c2 IS
SELECT *
FROM ic_lots_mst
WHERE
    lot_id      = p_lot_id
AND item_id     = p_item_id;

BEGIN

   /*  Init variables  */
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF ( NVL(p_lot_id,-1) <> -1) THEN

      OPEN ic_lots_mst_c2;
      FETCH ic_lots_mst_c2 INTO x_ic_lots_mst;

      IF (ic_lots_mst_c2%NOTFOUND) THEN
         CLOSE ic_lots_mst_c2;
         PrintMsg('Error : In Get_Lot_Details .Invalid Lot_id = '||
		p_lot_id||', item_id = '||p_item_id);

         FND_MESSAGE.Set_Name('GMI','GMI_API_LOT_NOT_FOUND');
         FND_MESSAGE.Set_Token('LOT_NO', p_lot_no);
         FND_MESSAGE.Set_Token('SUBLOT_NO', p_sublot_no);
         FND_MESSAGE.Set_Token('LOT_ID', p_lot_id);
         FND_MSG_PUB.Add;

         RAISE FND_API.G_EXC_ERROR;

      END IF;

      IF (ic_lots_mst_c2%ISOPEN)
      THEN
        CLOSE ic_lots_mst_c2;
      END IF;

   ELSE
      OPEN ic_lots_mst_c1;
      FETCH ic_lots_mst_c1 INTO x_ic_lots_mst;

      IF (ic_lots_mst_c1%NOTFOUND) THEN
         CLOSE ic_lots_mst_c1;
         PrintMsg('Error :in Get_Lot_Details .Invalid Lot_No/Sublot_no = '
                 ||p_lot_no|| ', Sublot_no = '||p_sublot_no);

         FND_MESSAGE.Set_Name('GMI','GMI_API_LOT_NOT_FOUND');
         FND_MESSAGE.Set_Token('LOT_NO', p_lot_no);
         FND_MESSAGE.Set_Token('SUBLOT_NO', p_sublot_no);
         FND_MESSAGE.Set_Token('LOT_ID', p_lot_id);
         FND_MSG_PUB.Add;

         RAISE FND_API.G_EXC_ERROR;

      END IF;

      IF(ic_lots_mst_c1%ISOPEN)
      THEN
	 CLOSE ic_lots_mst_c1;
      END IF;
   END IF;

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
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Get_Lot_Details;
/*--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Item_Details                                                     |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve item master details                                 |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_lots_mst      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_organization_id    IN  NUMBER       - Inventory Organization Id    |
--|    p_inventory_item_id  IN  VARCHAR2(32) - Inventory Item Id            |
--|    x_ic_item_mst_rec    OUT IC_ITEM_MST%ROWTYPE  Record containing     |
--|				ic_item_mst				    |
--|    x_return_status	    OUT VARCHAR2     - Return Status 		    |
--|    x_msg_count	    OUT NUMBER
--|    x_msg_data	    OUT VARCHAR2
--|                                                                         |
--| HISTORY                                                                 |
--|    16-SEP-2002      NC            Created                               |
--+=========================================================================+*/

PROCEDURE Get_Item_Details
   ( p_organization_id     IN         NUMBER
   , p_inventory_item_id   IN  	      NUMBER
   , x_ic_item_mst_rec     OUT NOCOPY IC_ITEM_MST_B%ROWTYPE
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Item_Details';

CURSOR ic_item_mst_cur ( discrete_org_id  IN NUMBER
              , discrete_item_id IN NUMBER) IS
SELECT ic.*
FROM   ic_item_mst_b    ic
     , mtl_system_items mtl
WHERE  delete_mark = 0
AND    ic.item_no = mtl.segment1
AND    mtl.organization_id = discrete_org_id
AND    mtl.inventory_item_id = discrete_item_id;

BEGIN

   /*  Init variables  */
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   OPEN ic_item_mst_cur( p_organization_id , p_inventory_item_id);
   FETCH ic_item_mst_cur INTO x_ic_item_mst_rec;

   IF ic_item_mst_cur%NOTFOUND THEN
      CLOSE ic_item_mst_cur;
      PrintMsg('Error ic_item_mst_cur%NOTFOUND inv_item_ id='
                 ||p_inventory_item_id||', org_id='||p_organization_id);
      FND_MESSAGE.Set_Name('GMI','GMI_API_ITEM_NOT_FOUND');
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);

      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      CLOSE ic_item_mst_cur;
      PrintMsg(' Item_no = '|| x_ic_item_mst_rec.item_no);
   END IF;

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
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Get_Item_Details;

/*--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    PrintMsg                                                     	    |
--|                                                                         |
--| USAGE                                                                   |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    Used  Print Debug messages in a log file                             |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_msg		VARCHAR2  Message text				    |
--|    p_file_name	VARCHAR2  File Name 				    |
--|                                                                         |
--| HISTORY                                                                 |
--|    29-SEP-2002      NC            Created                               |
============================================================================*/

PROCEDURE PrintMsg
   ( p_msg                           IN  VARCHAR2
   , p_file_name                     IN  VARCHAR2
   ) IS

CURSOR get_log_file_location IS
SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value) location, USERENV('SESSIONID') sessionid
FROM   v$parameter
WHERE  name = 'utl_file_dir';

l_location           VARCHAR2(255);
l_log                UTL_FILE.file_type;
l_time               VARCHAR2(10);
l_file_name          VARCHAR2(80);
l_sessionid          NUMBER := 0;
l_debug_level	     VARCHAR2(240) := TO_NUMBER(NVL(fnd_profile.value ('ONT_DEBUG_LEVEL'),0));

BEGIN

   IF (l_debug_level >=  5)
   THEN

      IF (p_file_name = '0')
      THEN
         l_file_name := 'ALOPM';
      ELSE
         l_file_name := p_file_name;
      END IF;

      OPEN   get_log_file_location;
      FETCH  get_log_file_location into l_location, l_sessionid;
      CLOSE  get_log_file_location;

      l_file_name := l_file_name || l_sessionid;

      l_log := UTL_FILE.fopen(l_location, l_file_name, 'a');

      IF UTL_FILE.IS_OPEN(l_log) THEN
         UTL_FILE.put_line(l_log, p_msg);
         UTL_FILE.fflush(l_log);
         UTL_FILE.fclose(l_log);
      END IF;

   END IF;

EXCEPTION

    WHEN OTHERS THEN
       NULL;

END PrintMsg;



END GMI_OM_ALLOC_API_PUB;


/

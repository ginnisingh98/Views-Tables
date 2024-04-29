--------------------------------------------------------
--  DDL for Package Body GMI_OM_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_OM_UTILITIES_PKG" AS
/*  $Header: GMIUTOMB.pls 120.0 2005/05/25 16:19:12 appldev noship $    */
/* ===========================================================================
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMIUTOMB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Body of package   GMI_OM_UTILITIES_PKG                             |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  17-NOV-04 Created                                                      |
 |  17-NOV-04 parkumar Added Functionality for BackOrder and Delete        |
 |                     Allocations for a Move Order Line                   |
 |                           - Delete_Alloc_BackOrder_MO_Line              |
 ===========================================================================
*/

/*   Global constant holding the package name   */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GMI_OM_UTILITIES_PKG';

  -- Delete_Alloc_BackOrder_MO_Line
  -- Bug 3874270
  -- This Function deletes Allocations for a Move Order Line if called with
  -- p_mode = 'DA' and Backorders a Move Order Line if called with
  -- p_mode = 'BO'.
  -- If any allocations exist for the move order line, then they are deleted
  -- All the Delivery Detail Lines are backordered and screen refreshed.
  -- The move order line is closed
  -- The order line status remains unchanged


FUNCTION  Delete_Alloc_BackOrder_MO_Line(
         p_txn_source_line_id        IN    NUMBER,
         p_line_id                   IN    NUMBER,
         p_mode                      IN    VARCHAR2)
 RETURN  BOOLEAN IS

 -- p_mode : 'DA' For Delete Allocations, 'BO' For BackOrdering

   l_IC$DEFAULT_LOCT 	VARCHAR2(255) DEFAULT NVL(FND_PROFILE.VALUE('IC$DEFAULT_LOCT'),' ') ;
   l_tran_rec        	GMI_TRANS_ENGINE_PUB.ictran_rec;
   l_txn_source_line_id	NUMBER	:= p_txn_source_line_id;
   l_line_id		NUMBER	:= p_line_id;

   CURSOR  Wdd_Cur IS
   SELECT  move_order_line_id
 	  ,delivery_detail_id
	  ,source_header_id
	  ,source_line_id
	  ,released_status
    FROM  wsh_delivery_details
   WHERE  source_line_id     = l_txn_source_line_id
     AND  move_order_line_id = l_line_id
     AND  released_status    = 'S'
     AND  source_code	     = 'OE';


  CURSOR  Get_Trans_Id_Cur(p_delivery_detail_id IN NUMBER) IS
  SELECT  trans_id ,line_id, trans_qty, trans_qty2
    FROM  ic_tran_pnd
   WHERE  line_id = l_txn_source_line_id
     AND  line_detail_id = p_delivery_detail_id
     AND  doc_type	 = 'OMSO'
     AND  completed_ind	 = 0
     AND  delete_mark    = 0
     AND  staged_ind	<> 1
     AND  ( lot_id <> 0 OR location <> l_IC$DEFAULT_LOCT);

  CURSOR Get_Default_Trans(p_line_id ic_tran_pnd.line_id%TYPE) IS
  SELECT trans_id
    FROM ic_tran_pnd
   WHERE line_id        = p_line_id
     AND line_detail_id IS NULL
     AND doc_type       = 'OMSO'
     AND delete_mark    = 0
     AND completed_ind  = 0
     AND staged_ind     = 0
     AND ( lot_id = 0 AND location = l_IC$DEFAULT_LOCT);

   l_in_tran_rec             gmi_trans_engine_pub.ictran_rec;
   l_out_tran_rec            gmi_trans_engine_pub.ictran_rec;
   l_default_trans_id        NUMBER;
   wdd_row		     wdd_cur%ROWTYPE;
   get_trans_id_row	     get_trans_id_cur%ROWTYPE;
   l_return_status  	     VARCHAR2(1);
   l_tran_row        	     IC_TRAN_PND%ROWTYPE;
   l_msg_count	             NUMBER  :=0;
   l_msg_data		     VARCHAR2(2000) := '';
   l_mode	             VARCHAR2(2);
   l_api_return_status       VARCHAR2(10);
   l_shipping_attr	     WSH_INTERFACE.ChangedAttributeTabType;
   l_mo_line	             GMI_Move_Order_Global.mo_line_rec;
   l_organization_id	     IC_TXN_REQUEST_LINES.organization_id%TYPE ;
   l_quantity		     NUMBER := 0;
   l_transaction_quantity    NUMBER := 0;
   l_secondary_quantity	     NUMBER := 0;
   l_transaction_quantity2   NUMBER := 0;
   l_allocations_Not_exists  NUMBER := 0;

   l_trans_qty  NUMBER := 0;
   l_trans_qty2 NUMBER := 0;


BEGIN
   gmi_reservation_util.println('In Function Delete_Alloc_BackOrder_MO_Line');

    /* Standard begin of API savepoint
   ===========================================*/
   SAVEPOINT Delete_Alloc_BackOrder_MO_Line;

   l_mode    := p_mode;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN	wdd_cur;
   LOOP
      FETCH wdd_cur INTO wdd_row;
      EXIT WHEN wdd_cur%NOTFOUND;
      l_trans_qty  := 0;
      l_trans_qty2 := 0;

      OPEN get_trans_id_cur(wdd_row.delivery_detail_id);
      LOOP
            FETCH  get_trans_id_cur INTO get_trans_id_row;
            EXIT WHEN get_trans_id_cur%NOTFOUND;

            l_tran_rec.trans_id  := get_trans_id_row.trans_id;
	    gmi_reservation_util.println('In Function Delete_Alloc_BackOrder_MO_Line Before delete_pending_transaction');
            GMI_TRANS_ENGINE_PUB.delete_pending_transaction (
	                1
                	, FND_API.G_FALSE
                	, FND_API.G_FALSE
                	, FND_API.G_VALID_LEVEL_FULL
                	, l_tran_rec
                	, l_tran_row
                	, l_return_status
                	, l_msg_count
                	, l_msg_data);

	    gmi_reservation_util.println('Return Status from  delete_pending_transaction'|| l_return_status);

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	       gmi_reservation_util.println('Error Status from  delete_pending_transaction');
	       raise FND_API.G_EXC_ERROR;
	    END IF;

	    l_trans_qty  := nvl(l_trans_qty,0)  + nvl(abs(get_trans_id_row.trans_qty),0);
            l_trans_qty2 := nvl(l_trans_qty2,0) + nvl(abs(get_trans_id_row.trans_qty2),0);

      END LOOP;
      CLOSE get_trans_id_cur;

      IF  l_mode = 'BO' THEN
         SELECT organization_id
 	   INTO l_organization_id
	   FROM IC_TXN_REQUEST_LINES
          WHERE  LINE_ID = l_line_id;

         l_shipping_attr(1).source_header_id    := wdd_row.source_header_id;
         l_shipping_attr(1).source_line_id      := wdd_row.source_line_id;
         l_shipping_attr(1).ship_from_org_id    := l_organization_id;
         l_shipping_attr(1).released_status     := wdd_row.released_status;
         l_shipping_attr(1).delivery_detail_id	:= wdd_row.delivery_detail_id;
         l_shipping_attr(1).action_flag		      := 'B';

         WSH_INTERFACE.Update_Shipping_Attributes (
			                  p_source_code		      => 'INV'
                       ,p_changed_attributes	=> l_shipping_attr
                       ,x_return_status		    => l_api_return_status
                     );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             gmi_reservation_util.println('Error Status from  WSH_INTERFACE.Update_Shipping_Attributes');
             raise FND_API.G_EXC_ERROR;
          END IF;

      END IF; /*  IF ( l_mode = 'BO') THEN */

    END LOOP; /* wdd_cur */

    CLOSE wdd_cur;

    IF (l_mode = 'BO')  THEN
	UPDATE 	IC_TXN_REQUEST_LINES
	   SET  LINE_STATUS = 5,
                quantity_detailed = quantity_detailed  - nvl(l_trans_qty,0),
                secondary_quantity_detailed = secondary_quantity_detailed  - nvl(l_trans_qty2,0)
 	 WHERE 	LINE_ID	= l_line_id;--:TOLINES_BLK.LINE_ID;
    ELSE
       UPDATE  IC_TXN_REQUEST_LINES
          SET  quantity_detailed = quantity_detailed  - nvl(l_trans_qty,0),
               secondary_quantity_detailed = secondary_quantity_detailed  - nvl(l_trans_qty2,0)
        WHERE  LINE_ID = l_line_id;--:TOLINES_BLK.LINE_ID;
    END IF;


    OPEN Get_Default_Trans(l_txn_source_line_id) ;
    FETCH Get_Default_Trans INTO l_default_trans_id;
    IF( Get_Default_Trans%NOTFOUND) THEN
       CLOSE  Get_Default_Trans;
       gmi_reservation_util.println('Get_Default_Trans%NOTFOUND in Delete_Alloc_BackOrder_MO_Line');
       RETURN   FALSE;
    END IF ;

    CLOSE Get_Default_Trans;

    IF NVL(l_default_trans_id,0)  <>  0 THEN
       l_in_tran_rec.trans_id := l_default_trans_id ;

       IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_in_tran_rec, l_out_tran_rec)  THEN
          gmi_reservation_util.println('In Delete_Alloc_BackOrder_MO_Line before call to GMI_Reservation_Util.balance_default_lot');
          GMI_Reservation_Util.balance_default_lot(
                       p_ic_default_rec            => l_out_tran_rec
                     , p_opm_item_id               => l_out_tran_rec.item_id
                     , x_return_status             => l_return_status
                     , x_msg_count                 => l_msg_count
                     , x_msg_data                  => l_msg_data
                     );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
             gmi_reservation_util.println('Error Status from  GMI_Reservation_Util.balance_default_lot');
             raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;
     END IF; /*  IF NVL(l_default_trans_id,0)  <>  0 THEN */

    IF wdd_cur%ISOPEN THEN
      CLOSE wdd_cur;
    END IF;
    IF get_default_trans%ISOPEN THEN
      CLOSE get_default_trans;
    END IF;
    IF get_trans_id_cur%ISOPEN THEN
      CLOSE get_trans_id_cur;
    END IF;

    gmi_reservation_util.println('Successfully Returning from Delete_Alloc_BackOrder_MO_Line');

RETURN TRUE;
EXCEPTION

WHEN fnd_api.g_exc_error THEN

    ROLLBACK TO SAVEPOINT Delete_Alloc_BackOrder_MO_Line;

    GMI_Reservation_Util.PrintLn('Exception fnd_api.g_exc_error Delete_Alloc_BackOrder_MO_Line');
    IF wdd_cur%ISOPEN THEN
      CLOSE wdd_cur;
    END IF;
    IF get_default_trans%ISOPEN THEN
      CLOSE get_default_trans;
    END IF;
    IF get_trans_id_cur%ISOPEN THEN
      CLOSE get_trans_id_cur;
    END IF;

    RETURN FALSE;
 WHEN fnd_api.g_exc_unexpected_error THEN
     ROLLBACK TO SAVEPOINT Delete_Alloc_BackOrder_MO_Line;

    GMI_Reservation_Util.PrintLn('Exception fnd_api.g_exc_error Delete_Alloc_BackOrder_MO_Line');
    IF wdd_cur%ISOPEN THEN
      CLOSE wdd_cur;
    END IF;
    IF get_default_trans%ISOPEN THEN
      CLOSE get_default_trans;
    END IF;
    IF get_trans_id_cur%ISOPEN THEN
      CLOSE get_trans_id_cur;
    END IF;

WHEN Others THEN

    ROLLBACK TO SAVEPOINT Delete_Alloc_BackOrder_MO_Line;

    GMI_Reservation_Util.PrintLn('Others Exception Delete_Alloc_BackOrder_MO_Line');
    IF wdd_cur%ISOPEN THEN
      CLOSE wdd_cur;
    END IF;
    IF get_default_trans%ISOPEN THEN
      CLOSE get_default_trans;
    END IF;
    IF get_trans_id_cur%ISOPEN THEN
      CLOSE get_trans_id_cur;
    END IF;

    RETURN FALSE;


 END   Delete_Alloc_BackOrder_MO_Line;

END GMI_OM_UTILITIES_PKG;


/

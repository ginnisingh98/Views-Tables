--------------------------------------------------------
--  DDL for Package Body GMI_SHIPPING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_SHIPPING_UTIL" AS
/*  $Header: GMIUSHPB.pls 120.0 2005/05/25 15:53:56 appldev noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUSHPS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     shipping.                                                           |
 |                                                                         |
 | HISTORY                                                                 |
 | B1495550 15-Nov-2000 hwahdani Changed NONE by IC$DEFAULT_LOCT           |
 | B1504749 21-Nov-2000 odaboval Changed the CLOSE cursor management.      |
 | B1504749 05-Dec-2000 odaboval Added where clause on released_status.    |
 | B1577035 12-Jan-2001 KYH      Set staged_ind = 0 in backorder scenario  |
 | B1503309 27-MAR-2001 Hverddin Changed Logic to calculate                |
 |                               l_reduction_factor                        |
 | B172755  04/09/01 HW Need to add sublot_no is NULL to sql statement     |
 |                      when sublot_number is null because sublot_no is    |
 |                       part of the key                                   |
 | B1826752  06/08/01 HW Issue with clearing out lot information           |
 |                      when updating wsh_delivery_details.                |
 |                      in GMI_APPLY_BACKORDER_UPDATES                     |
 | B1854224  06/27/01 HW close the comment for bug 1826752 in              |
 |                      GMI_APPLY_BACKORDER_UPDATES                        |
 | B2547509  12/06/01 Uday Phadtare Adding the message returned by         |
 |                      Inventory Engine in the log file after calling     |
 |                      UPDATE_PENDING_TO_COMPLETED.                       |
 |                    Also added code to change the trans_date to sysdate  |
 |                      if the date is in closed period and also undelete  |
 |                      the transaction if it is deleted by mistake.       |
 | V. Ajay Kumar  09-JAN-2003  BUG#2736088                                 |
 |    Removed the reference to "apps".                                     |
 | B2775197  01/29/03 Uday Phadtare Do not complete the transaction if the |
 |                    inventory is going negative and the profile, allow   |
 |                    neg inv is not equal to 1.                           |
 |                                                                         |
 | Hasan Wahdani 10/2003 3206991 Added an overloading procedure with a     |
 |                    different parameters. WSH module passes a table of   |
 |                    trips stops in WSH.J and prior to that, only stop_id |
 |                    was being passed.                                    |
 |                                                                         |
 | Hasan Wahdani 12/2003 Removed the Overloading procedure and replaced it |
 |                    with GMI_UPDATE_ORDER.process_order (GMIUSITB.pls)   |
 |                    due to compilation issues                            |
 |                                                                         |
 | Hasan Wahdani 02/2004 BUG: 3434884 GSCC issue to get proper Schema      |
 |                            Names.                                       |
 | Hasan Wahdani 02/2004 BUG: 3385851 Added for Pushkar                    |
 | Hasan Wahdani 02/2004 BUG: HW 3388186 Added a new procedure             |
 |                            UPDATE_NEW_LINE_DETAIL_ID. See comments      |
 |                            by procedure                                 |
 +=========================================================================+
*/
PROCEDURE GMI_UPDATE_SHIPMENT_TXN_new
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , p_actual_ship_date              IN  DATE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

FUNCTION GMI_TRANS_DATE(p_trans_date date, p_orgn_code VARCHAR2, p_whse_code VARCHAR2) RETURN DATE;

FUNCTION INVENTORY_GOING_NEG(p_tran_rec GMI_TRANS_ENGINE_PUB.ictran_rec) return BOOLEAN;

procedure check_loct_ctl (
    p_inventory_item_id             IN NUMBER
   ,p_mtl_organization_id           IN NUMBER
   ,x_ctl_ind                       OUT NOCOPY VARCHAR2) ;

INVENTORY_NEG_WARNING EXCEPTION;

PROCEDURE GMI_CREATE_BACKORDER_TXN
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   )
IS
  l_old_transaction_row    ic_tran_pnd%ROWTYPE;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_line_id                ic_tran_pnd.line_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_reduction_factor       NUMBER;
  l_delta_trans_qty2       NUMBER;
  l_trans_id               NUMBER;
  l_staged_ind             NUMBER;
  l_lock_status            BOOLEAN;

  CURSOR default_transaction_c IS
    SELECT trans_id, staged_ind
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_shipping_line.source_line_id
  --  AND    item_id = l_item_id                        -- REMOVED for bug 3403418
    AND    lot_id  = 0
    AND    location = l_location
    AND    completed_ind = 0
    AND    delete_mark = 0
    ORDER BY staged_ind;

  CURSOR get_opm_transaction_c
  IS
    SELECT trans_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_shipping_line.source_line_id
  --  AND    item_id = l_item_id                        -- REMOVED for bug 3403418
    AND    lot_id  = l_lot_id
    AND    location = l_location
    AND    completed_ind = 0
    AND    staged_ind = 1
    AND    delete_mark = 0
    ORDER BY trans_id;
  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;


BEGIN

  /*  Standard Start OF API savepoint */

  SAVEPOINT process_backorders;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  GMI_RESERVATION_UTIL.println('Start Of OPM BackOrder Routine');

  /*  Try and retrieve the original transaction. To do this we need */
  /*  to determine a number of keys so that we can locate the correct */
  /*  row in ic_tran_pnd. If any of these retrievals fails there is no */
  /*  point in continuing, so let the exception raised take over. */

  GMI_reservation_Util.PrintLn('Find OPM Item ID');

  SELECT iim.item_id INTO l_item_id
  FROM   ic_item_mst iim,
         mtl_system_items msi
  WHERE  msi.inventory_item_id = p_shipping_line.inventory_item_id
  AND    msi.organization_id = p_shipping_line.organization_id
  AND    msi.segment1 = iim.item_no;

  IF p_shipping_line.locator_id IS NULL
  THEN
    /* hwahdani BUG#:1495550 get proper value of default location from profile */
    l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  ELSE
    SELECT location INTO l_location
    FROM   ic_loct_mst
    WHERE  inventory_location_id = p_shipping_line.locator_id;
  END IF;

  IF p_shipping_line.lot_number IS NULL
  THEN
    l_lot_id := 0;
  ELSIF p_shipping_line.sublot_number IS NULL
-- HW BUG#:1727553 added sublot_no is NULL
  THEN
    SELECT lot_id INTO l_lot_id
    FROM   ic_lots_mst
    WHERE  item_id = l_item_id
    AND    lot_no = p_shipping_line.lot_number
    AND    sublot_no IS NULL ;
  ELSE
    SELECT lot_id INTO l_lot_id
    FROM   ic_lots_mst
    WHERE  item_id = l_item_id
    AND    lot_no = p_shipping_line.lot_number
    AND    sublot_no = p_shipping_line.sublot_number;
  END IF;

  /*  With the above retrievals successfully done we can  */
  /*  try to locate the transaction we need. Again, if this fails */
  /*  we cannot proceed so let the exception raised take over. */

  GMI_reservation_Util.PrintLn('Find OPM Original Transaction');

  /*  Could Select More than one Line With Matching Keys */
  /*  We do not care which matching record we select */
  /*  since we are ordering by trans_id, therefore */
  /*  Exit after First Select. */

  GMI_RESERVATION_UTIL.println('LINE_ID  => ' || p_shipping_line.source_line_id);
  GMI_RESERVATION_UTIL.println('ITEM_ID  => ' || l_item_id);
  GMI_RESERVATION_UTIL.println('LOT_ID   => ' || l_lot_id);
  GMI_RESERVATION_UTIL.println('Location => ' || l_location);

  OPEN get_opm_transaction_c;
  LOOP
     FETCH get_opm_transaction_c INTO l_old_transaction_rec.trans_id;
     IF get_opm_transaction_c%NOTFOUND THEN
           /* B1504749, 21-Nov-2000 odaboval : added CLOSE cursor here. */
           --CLOSE get_opm_transaction_c;

           GMI_RESERVATION_UTIL.println('OPM Transaction Not Found');
           --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     EXIT; /*  Exit after First Select */
  END LOOP;

  --CLOSE get_opm_transaction_c;

  GMI_RESERVATION_UTIL.println('TRANS_ID  => ' || l_old_transaction_rec.trans_id);
  GMI_RESERVATION_UTIL.println('Cycle_count  => ' || p_shipping_line.cycle_count_quantity);

IF get_opm_transaction_c%NOTFOUND THEN
  CLOSE get_opm_transaction_c;
  GMI_RESERVATION_UTIL.println('l_return_status  => ' || x_return_status);
ELSE
 CLOSE get_opm_transaction_c;
 /*  original hwahdani IF ( l_lot_id = 0 and l_location is NULL) THEN */
  /*  BUG#:1495550 check if l_location is not NULL */
  IF ( l_lot_id = 0 and l_location = FND_PROFILE.VALUE('IC$DEFAULT_LOCT'))
  THEN
      GMI_reservation_Util.PrintLn('Default Transaction Is Not LOT/LOC controlled');
      GMI_reservation_Util.PrintLn('Action is  => Revert staged_ind to zero');
      /* BUG 1577035 BEGIN Set staged_ind = 0 in backorder scenario
      ============================================================= */
      /* BUG 1575873 the qty becomes 0 when back order is created, the
           default qty should be the cycle count qty */
      UPDATE ic_tran_pnd
        SET staged_ind = 0,
            trans_qty = -1 * p_shipping_line.cycle_count_quantity,
            trans_qty2 = -1 * p_shipping_line.cycle_count_quantity2
        WHERE trans_id = l_old_transaction_rec.trans_id;

      IF SQL%NOTFOUND THEN
        FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
        FND_MESSAGE.Set_Token('BY_PROC', 'Update default staged indicator');
        FND_MESSAGE.Set_Token('WHERE', 'GMI_Create_Backorder_Txn');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      /* BUG 1577035 END
      ================== */
  ELSE

  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
     (l_old_transaction_rec, l_old_transaction_rec )
  THEN
    /*  We have the transaction we need.  */
    /*  Before Completing any transactions lets Lock The Rows. */
    /*  Calling OPM Lock Inventory Routine. */
   -- PK Bug 3527599 No need to lock IC_LOCT_INV when deleting pending txn.

    IF ABS(l_old_transaction_rec.trans_qty) = p_shipping_line.cycle_count_quantity
    THEN
      GMI_RESERVATION_UTIL.println('BackOrder Full Staged Qty');

      /*  Delete Original Tranaction  */

      GMI_RESERVATION_UTIL.println('Delete Original Transaction');

      GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_old_transaction_rec
      , l_old_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*  I am Assuming That There Will Always Be A Default Transaction. */
      /*  So Lets Get It. */

      /*  Set the value of location for Default Transaction */
      /*  Needs to be replaced with profile check in future. */

      /*  hwahdani BUG#:1495550 get proper value of default location from profile */
      l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

      OPEN default_transaction_c;
      FETCH default_transaction_c INTO l_trans_id, l_staged_ind;
        IF default_transaction_c%NOTFOUND THEN
           Close default_transaction_c;
           GMI_RESERVATION_UTIL.println('Default Transaction Not Found');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      Close default_transaction_c;

      /*  Set Trans Id To fetch */

      l_old_transaction_rec.trans_id := l_trans_id;

      IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
        (l_old_transaction_rec, l_old_transaction_rec )
      THEN
           GMI_RESERVATION_UTIL.println('Found Transaction ID => '|| l_old_transaction_rec.trans_id);

         l_new_transaction_rec := l_old_transaction_rec;
         l_new_transaction_rec.trans_qty := -1 * (p_shipping_line.cycle_count_quantity + ABS(l_old_transaction_rec.trans_qty));
         l_new_transaction_rec.trans_qty2 := -1 * (p_shipping_line.cycle_count_quantity2 + ABS(l_old_transaction_rec.trans_qty2));

         PRINT_DEBUG (l_new_transaction_rec,' Update Default Transaction');

         GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
         ( 1
         , FND_API.G_FALSE
         , FND_API.G_FALSE
         , FND_API.G_VALID_LEVEL_FULL
         , l_new_transaction_rec
         , l_new_transaction_row
         , x_return_status
         , x_msg_count
         , x_msg_data
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

    ELSE

       GMI_RESERVATION_UTIL.println('Start Of OPM Partial BackOrder Routine');

      /*  We are creating a partial back order. In a similar way */
      /*  to above, reverse out the existing allocations and then */
      /*  post a new one with amounts reduced by the back order */
      /*  quantity. */



      GMI_RESERVATION_UTIL.println('Backout Original Staged Qty ' || l_old_transaction_rec.trans_qty);

      GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_old_transaction_rec
      , l_old_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error returned by Delete_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*  Reduce the existing transaction quantity by the amount  */
      /*  being back-ordered (any trans_qty2 figures are reduced */
      /*  in proportion) and then write out the new transaction for */
      /*  the amount being Left At Staging. */


      l_new_transaction_rec := l_old_transaction_rec;

      /* Bug 1503309 Start New l_reduction_factor Logic */

      IF l_new_transaction_rec.trans_qty2 is NULL THEN
         l_reduction_factor := NULL;
      ELSE
         l_reduction_factor := ABS(l_new_transaction_rec.trans_qty2)/ ABS(l_new_transaction_rec.trans_qty);
      END IF;
      GMI_RESERVATION_UTIL.println('Reduction Factor => ' || l_reduction_factor);
      l_new_transaction_rec.trans_qty := -1 * (ABS(l_new_transaction_rec.trans_qty) - p_shipping_line.cycle_count_quantity);
      l_new_transaction_rec.trans_qty2 := -1 * (ABS(l_new_transaction_rec.trans_qty)) * l_reduction_factor;
      /* Bug 1503309 End of New l_reduction_factor Logic */

      /* NC Added line_detail_id Bug#1675561 */
      l_new_transaction_rec.line_detail_id := p_shipping_line.delivery_detail_id;

      GMI_RESERVATION_UTIL.println('line_detail_id ' || p_shipping_line.delivery_detail_id);
      GMI_RESERVATION_UTIL.println('Back Qty ' || p_shipping_line.cycle_count_quantity);
      GMI_RESERVATION_UTIL.println('Back Qty2 ' || p_shipping_line.cycle_count_quantity2);
      GMI_RESERVATION_UTIL.println('Write New Staged Qty ' || l_new_transaction_rec.trans_qty);
      GMI_RESERVATION_UTIL.println('Write New Staged Qty2 ' || l_new_transaction_rec.trans_qty2);

      GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_new_transaction_rec
      , l_new_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*  We now need to sort out the transaction for the default lot.  */
      /*   There are three cases to consider and the cursor will retrieve */
      /*  the characteristics of the row we need (if it exists) */

      /*  a) If an unstaged default lot transaction exists, increase the */
      /*     quantities in it by the back order quantities */
      /*     otherwise */
      /*  b) If a staged default lot transaction exists, create a new */
      /*     unstaged transaction for the backorder quantities */
      /*     otherwise */
      /*  c) If no default transaction exists, create the same transaction */
      /*     as would have been created in 'b'. */

      /*  Set the value of location for Default Transaction */
      /*  Needs to be replaced with profile check in future. */

      /*  hwahdani BUG#:1495550 get proper value of default location from profile */
      l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

      OPEN default_transaction_c;
      FETCH default_transaction_c INTO l_trans_id, l_staged_ind;
      IF default_transaction_c%NOTFOUND
      OR l_staged_ind = 1
      THEN
        CLOSE default_transaction_c;
        /*  We need to create the default, unstaged row */

        gmi_reservation_util.println('Creating Default Row Transaction For Back Ordered Qty');

        l_new_transaction_rec.trans_id := NULL;
        l_new_transaction_rec.trans_qty := - p_shipping_line.cycle_count_quantity;
        l_new_transaction_rec.trans_qty2:= - p_shipping_line.cycle_count_quantity2;
        l_new_transaction_rec.lot_id := 0;
        l_new_transaction_rec.location := 'NONE';
        l_new_transaction_rec.staged_ind := 0;

        PRINT_DEBUG (l_old_transaction_rec,'Create Default Back Order');

        GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
        ( 1
        , FND_API.G_FALSE
        , FND_API.G_FALSE
        , FND_API.G_VALID_LEVEL_FULL
        , l_new_transaction_rec
        , l_new_transaction_row
        , x_return_status
        , x_msg_count
        , x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          /* B1504749, 21-Nov-2000 odaboval : removed CLOSE cursor here. */
          /* CLOSE default_transaction_c; */

          GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSE
         CLOSE default_transaction_c;
        /*  We need to increase the amounts in the existing transaction */
        l_old_transaction_rec.trans_id := l_trans_id;

        IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
           (l_old_transaction_rec, l_old_transaction_rec )
        THEN
          l_old_transaction_rec.trans_qty := -1 * (ABS(l_old_transaction_rec.trans_qty) + p_shipping_line.cycle_count_quantity);

          l_old_transaction_rec.trans_qty2 := -1 * (ABS(l_old_transaction_rec.trans_qty2) + p_shipping_line.cycle_count_quantity2);

          PRINT_DEBUG (l_old_transaction_rec,'Update Default Back Order');

          GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
          ( 1
          , FND_API.G_FALSE
          , FND_API.G_FALSE
          , FND_API.G_VALID_LEVEL_FULL
          , l_old_transaction_rec
          , l_old_transaction_row
          , x_return_status
          , x_msg_count
          , x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
            /* B1504749, 21-Nov-2000 odaboval : removed CLOSE cursor here. */
            /* CLOSE default_transaction_c; */

            GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      END IF;

    END IF;
  ELSE
    GMI_RESERVATION_UTIL.println('could not locate the original transaction');
    /*  We could not locate the original transaction. */
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF; /*  Non-loc or location controlled  */
END IF;

  EXCEPTION
  WHEN OTHERS
  THEN
    rollback to process_backorders;
    x_return_status := FND_API.G_RET_STS_ERROR;
    /* B1504749, 21-Nov-2000 odaboval : removed CLOSE cursor here. */
    /* CLOSE default_transaction_c; */
END GMI_CREATE_BACKORDER_TXN;

/* this unreserve would delete the trans for this trans_id
and balancing the default lot*/
PROCEDURE unreserve_inv
( p_trans_id            IN NUMBER
, x_return_status                 OUT NOCOPY VARCHAR2)
IS
  l_transaction_row    ic_tran_pnd%ROWTYPE;
  l_line_id                ic_tran_pnd.line_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_reduction_factor       NUMBER;
  l_delta_trans_qty2       NUMBER;
  l_trans_id               NUMBER;
  l_staged_ind             NUMBER;
  l_lock_status            BOOLEAN;
  l_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_default_trans_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_msg_count number;
  l_msg_data varchar2(3000);

  CURSOR default_transaction_c IS
    SELECT trans_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = l_transaction_rec.line_id
  --  AND    item_id = l_item_id                     -- REMOVED for bug 3403418
    AND    lot_id  = 0
    AND    location = l_location
    AND    completed_ind = 0
    AND    delete_mark = 0
    ORDER BY staged_ind;

BEGIN

  /*  Standard Start OF API savepoint */

  GMI_RESERVATION_UTIL.println('deleting trans ');
  SAVEPOINT process_backorders;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_transaction_rec.trans_id := p_trans_id;
  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
     (l_transaction_rec, l_transaction_rec )
  THEN
     GMI_reservation_Util.PrintLn('Find OPM Item ID');

     l_item_id := l_transaction_rec.item_id;
     l_location := l_transaction_rec.location;
     GMI_RESERVATION_UTIL.println('LINE_ID  => ' || l_transaction_rec.line_id);
     GMI_RESERVATION_UTIL.println('ITEM_ID  => ' || l_item_id);
     GMI_RESERVATION_UTIL.println('LOT_ID   => ' || l_lot_id);
     GMI_RESERVATION_UTIL.println('Location => ' || l_location);

     -- PK Bug 3527599 No need to lock IC_LOCT_INV when deleting pending txn.

     GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
     ( 1
     , FND_API.G_FALSE
     , FND_API.G_FALSE
     , FND_API.G_VALID_LEVEL_FULL
     , l_transaction_rec
     , l_transaction_row
     , x_return_status
     , l_msg_count
     , l_msg_data
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF;
  /*  hwahdani BUG#:1495550 get proper value of default location from profile */
  l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

  GMI_RESERVATION_UTIL.find_default_lot
           (  x_return_status     => x_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_data,
              x_reservation_id    => l_trans_id,
              p_line_id           => l_transaction_rec.line_id
           );

  IF nvl(l_trans_id,0) = 0 THEN
     GMI_RESERVATION_UTIL.println('Default Transaction Not Found');
     --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     /* create a default lot, in case we are backordering */
     l_transaction_rec.location := l_location;
     l_transaction_rec.lot_id := 0;
     l_transaction_rec.trans_qty := 0;
     l_transaction_rec.trans_qty2 := 0;
     l_transaction_rec.staged_ind := 0;
     l_transaction_rec.line_detail_id := null;
     GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
         ( p_api_version      => 1.0
         , p_init_msg_list    => FND_API.G_FALSE
         , p_commit           => FND_API.G_FALSE
         , p_validation_level => FND_API.G_VALID_LEVEL_FULL
         , p_tran_rec         => l_transaction_rec
         , x_tran_row         => l_transaction_row
         , x_return_status    => x_return_status
         , x_msg_count        => l_msg_count
         , x_msg_data         => l_msg_data
         );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       GMI_RESERVATION_UTIL.PrintLn('Error returned by creating pending default lot');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     l_trans_id := l_transaction_row.trans_id;
     GMI_RESERVATION_UTIL.println('created Default Transaction trans_id '||l_trans_id);
  END IF;

  l_transaction_rec.trans_id := l_trans_id;

  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
     (l_transaction_rec, l_transaction_rec )
  THEN
     /* balance the default lot */
     GMI_RESERVATION_UTIL.balance_default_lot
       ( p_ic_default_rec            => l_transaction_rec
       , p_opm_item_id               => l_transaction_rec.item_id
       , x_return_status             => x_return_status
       , x_msg_count                 => l_msg_count
       , x_msg_data                  => l_msg_data
       );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  EXCEPTION
  WHEN OTHERS
  THEN
    rollback to process_backorders;
    x_return_status := FND_API.G_RET_STS_ERROR;
END unreserve_inv;

-- this is obsoleted once the WSH had made changes for backorder, new int, omchanges
PROCEDURE GMI_UPDATE_SHIPMENT_TXN
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , p_actual_ship_date              IN  DATE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   )
IS

  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_old_transaction_row    ic_tran_pnd%ROWTYPE;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_line_id                ic_tran_pnd.line_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_delta_trans_qty2       NUMBER;
  l_delta_trans_qty1       NUMBER;
  l_trans_id               NUMBER;
  l_lock_status            BOOLEAN;
  /* NC Added the following parameters. Bug#1675561 */
  l_line_detail_id         NUMBER;
  l_trans_count            NUMBER;
  l_loct_ctl            NUMBER;
  l_whse_ctl            NUMBER;
  l_lot_ctl            NUMBER;
  l_src_qty            NUMBER;
  l_cnt_trans              NUMBER;

  CURSOR default_transaction_c
  IS
    SELECT trans_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_shipping_line.source_line_id
   -- AND    item_id = l_item_id                            -- REMOVED for bug 3403418
    AND    lot_id  = 0
    AND    location = l_location
    AND    completed_ind = 0
    AND    delete_mark = 0;
    /* LG overpicking backorder */
    /* since the default lot is shared for non controled items,
       here we just have to find out the line and complete the qty as needed*/
--    AND    staged_ind = 1;

  CURSOR get_opm_transaction_c
  IS
    SELECT trans_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_shipping_line.source_line_id
--    AND    item_id = l_item_id                        -- REMOVED for bug 3403418
    AND    lot_id  = l_lot_id
    AND    location = l_location
    AND    completed_ind = 0
    AND    staged_ind = 1
    AND    delete_mark = 0
/* temporary fix for 1794681 */
/* Have to back this temp fix out because staging is not working. If split shipping line 3 and 7 for
  the original qty of 10, there is no way that the invnetory could be found Since this issue is an
  internal issue, before the complete fix for delivery detail in ic_tran_pnd, leave the issue
  as it is for now, this is a bigger issue for corrugated */
    --AND    trans_qty >= -1 * ABS(p_shipping_line.requested_quantity + 0.000005)
    --AND    trans_qty <= -1 * ABS(p_shipping_line.requested_quantity - 0.000005)
    ORDER BY trans_id;

  /* NC Added the following two cursors. Bug#1675561 */
  CURSOR get_opm_trans_count
  IS
    SELECT count(*)
    FROM ic_tran_pnd
    WHERE doc_type = 'OMSO'
    AND    line_id = p_shipping_line.source_line_id
  --  AND    item_id = l_item_id                        -- REMOVED for bug 3403418
    AND    lot_id  = l_lot_id
    AND    location = l_location
    AND    completed_ind = 0
    AND    staged_ind = 1
    AND    delete_mark = 0;
  --  ORDER BY trans_id;                                -- REMOVED for bug 3403418

  CURSOR get_opm_transaction_c2
  IS
    SELECT trans_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_shipping_line.source_line_id
    AND    line_detail_id = p_shipping_line.delivery_detail_id
    AND    delete_mark = 0
    ORDER BY trans_id;

  /* B2547509 Added following cursor */
  CURSOR get_opm_transaction_cnt
  IS
    SELECT count(*)
    FROM   ic_tran_pnd itp
    WHERE  doc_type       ='OMSO'
    AND    line_id        = p_shipping_line.source_line_id
    AND    line_detail_id = p_shipping_line.delivery_detail_id
    AND    delete_mark    = 1
    AND    exists (select 1
                   from   wsh_delivery_Details
                   where  line_id            = p_shipping_line.source_line_id
                   and    delivery_detail_id = p_shipping_line.delivery_detail_id
                   and    shipped_quantity   = (-1)*itp.trans_qty);

  CURSOR get_whse IS
   Select loct_ctl
   From ic_whse_mst
   Where mtl_organization_id = p_shipping_line.organization_id;

  --BEGIN BUG#2736088 V. Ajay Kumar
  --Removed the refence to "apps".
-- HW BUG#3434884. Need to pass schema name
  Cursor check_wsh (l_schema VARCHAR2) IS
  Select object_name
  From all_objects
  Where object_name = 'WSH_USA_INV_PVT'
    AND object_type = 'PACKAGE BODY'
    AND OWNER = l_schema;

  --END BUG#2736088


  l_dummy                 VARCHAR2(30);

  l_ship_qty_above        NUMBER;
  l_ship_qty_below        NUMBER;
  l_allowneginv           NUMBER;
-- HW bug # 3434884
  l_ret                   BOOLEAN;
  l_schema            VARCHAR2(30);


BEGIN
  /*  Standard Start OF API savepoint */

  SAVEPOINT process_shipments;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  /* Bug 2775197 */

-- HW BUG 3434884 - GSCC issue. Need to get proper Schema Name

      select oracle_username
      into   l_schema
      from   fnd_oracle_userid
      where  read_only_flag = 'U';


  gmi_reservation_util.println('Value of schema name is '||l_schema);
-- HW 3385851. Added this fix for Pushkar
  BEGIN
    l_allowneginv := nvl(fnd_profile.value('IC$ALLOWNEGINV'),0);
    EXCEPTION
      WHEN OTHERS THEN
          gmi_reservation_util.println('Error in reading PROFILE: Allow Negative Inventory');
          l_allowneginv := 0;
  END;
-- end of 3385851
  GMI_RESERVATION_UTIL.println('Start Of OPM Inventory Interface Routine');
  GMI_RESERVATION_UTIL.println('delivery_detail_id '||p_shipping_line.delivery_detail_id);

  /* check to see if WSH G is installed, the file WSHUSAIB.pls is new introduced in G
     so check the object exsits or not would do*/
-- HW BUG 3434884- Added parameter l_schema parameter
  Open check_wsh(l_schema);
  Fetch check_wsh INTO l_dummy;
  IF check_wsh%FOUND THEN
     GMI_RESERVATION_UTIL.println('calling GMI_UPDATE_SHIPMENT_TXN_NEW');
     GMI_UPDATE_SHIPMENT_TXN_NEW
       ( p_shipping_line        => p_shipping_line
         , p_actual_ship_date   => p_actual_ship_date
         , x_return_status      => x_return_status
         , x_msg_count          => x_msg_count
         , x_msg_data           => x_msg_data
        );
     GMI_RESERVATION_UTIL.println('Finished calling GMI_Shipping_Util.GMI_UPDATE _SHIPMENT_TXN');
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        GMI_RESERVATION_UTIL.println('Error Could Not Complete');
        Close check_wsh;  /* B2886561 close cursor before exception */
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     IF check_wsh%ISOPEN THEN
        Close check_wsh;
     END IF;

     RETURN;

  END IF;
  Close check_wsh;

  /*  Try and retrieve the original transaction. To do this we need */
  /*  to determine a number of keys so that we can locate the correct */
  /*  row in ic_tran_pnd. If any of these retrievals fails there is no */
  /*  point in continuing, so let the exception raised take over. */

  SELECT iim.item_id, iim.lot_ctl, iim.loct_ctl INTO l_item_id,l_lot_ctl, l_loct_ctl
  FROM   ic_item_mst iim,
         mtl_system_items msi
  WHERE  msi.inventory_item_id = p_shipping_line.inventory_item_id
  AND    msi.organization_id = p_shipping_line.organization_id
  AND    msi.segment1 = iim.item_no;

  IF p_shipping_line.locator_id IS NULL
  THEN
    /*  hwahdani BUG#:1495550 get proper value of default location from profile */
    l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  ELSE
    SELECT location INTO l_location
    FROM   ic_loct_mst
    WHERE  inventory_location_id = p_shipping_line.locator_id;
  END IF;

  GMI_RESERVATION_UTIL.println('LOT_NUMBER  => ' || p_shipping_line.lot_number);
  GMI_RESERVATION_UTIL.println('SUBLOT_NUMBER  => ' || p_shipping_line.sublot_number);

  IF p_shipping_line.lot_number IS NULL
  THEN
    l_lot_id := 0;
  ELSIF p_shipping_line.sublot_number IS NULL
  /*HW BUG#:1727553 added sublot_no is NULL */
  THEN
    SELECT lot_id INTO l_lot_id
    FROM   ic_lots_mst
    WHERE  item_id = l_item_id
    AND    lot_no = p_shipping_line.lot_number
    AND    sublot_no IS NULL ;
  ELSE
    SELECT lot_id INTO l_lot_id
    FROM   ic_lots_mst
    WHERE  item_id = l_item_id
    AND    lot_no = p_shipping_line.lot_number
    AND    sublot_no = p_shipping_line.sublot_number;
  END IF;

  /*  With the above retrievals successfully done we can  */
  /*  try to locate the transaction we need. Again, if this fails */
  /*  we cannot proceed so let the exception raised take over. */

  GMI_RESERVATION_UTIL.println('OPM Trying To Retrieve the Correct old Transaction');
  GMI_RESERVATION_UTIL.println('LINE_ID  => ' || p_shipping_line.source_line_id);
  GMI_RESERVATION_UTIL.println('ITEM_ID  => ' || l_item_id);
  GMI_RESERVATION_UTIL.println('LOT_ID   => ' || l_lot_id);
  GMI_RESERVATION_UTIL.println('Location => ' || l_location);

  /* NC - Added the following code. Bug#1675561 and Bug#1794681  */
  Open get_whse;
  Fetch get_whse into l_whse_ctl;
  Close get_whse;

  IF l_lot_ctl = 0 and (l_loct_ctl * l_whse_ctl) =0 THEN
     OPEN default_transaction_c;
     FETCH default_transaction_c INTO l_old_transaction_rec.trans_id;
     CLOSE default_transaction_c;
  ELSE
     OPEN  get_opm_trans_count;
     FETCH get_opm_trans_count into l_trans_count;
     CLOSE get_opm_trans_count;

     IF l_trans_count =  1 THEN
        OPEN  get_opm_transaction_c;
        FETCH get_opm_transaction_c INTO l_old_transaction_rec.trans_id;
        CLOSE get_opm_transaction_c;

     ELSIF l_trans_count <> 1 THEN
       OPEN get_opm_transaction_c2;
       LOOP
          FETCH get_opm_transaction_c2 INTO l_old_transaction_rec.trans_id;
          IF get_opm_transaction_c2%NOTFOUND THEN
              Close get_opm_transaction_c2;
              GMI_RESERVATION_UTIL.println('OPM Transaction Not Found: get_opm_transaction_c2');
              /* Begin B2547509 */
              /* Check if this transaction is deleted by chance */
              OPEN  get_opm_transaction_cnt;
              FETCH get_opm_transaction_cnt into l_cnt_trans;
              CLOSE get_opm_transaction_cnt;
              IF (l_cnt_trans > 1) THEN
                 GMI_RESERVATION_UTIL.println('Multiple deleted transactions found - Manual updates are necessary');
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (l_cnt_trans = 1) THEN
                 /* update the transaction's delete mark to 0 and proceed */
                 UPDATE ic_tran_pnd
                 SET    delete_mark    = 0
                 WHERE  doc_type       = 'OMSO'
                 AND    line_id        = p_shipping_line.source_line_id
                 AND    line_detail_id = p_shipping_line.delivery_detail_id
                 AND    delete_mark    = 1
                 returning trans_id into l_old_transaction_rec.trans_id;
                 GMI_RESERVATION_UTIL.println('Undeleted transaction '||to_char(l_old_transaction_rec.trans_id));
              ELSE
                 GMI_RESERVATION_UTIL.println('Transaction for the line_id/line_detail_id not found or');
                 GMI_RESERVATION_UTIL.println(' the shipped quantity and transaction quantity do not match');
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              /* End B2547509 */
          END IF;

          EXIT; /*  Exit after First Select */
       END LOOP;
       /* B2886561 check if cursor is open before closing */
       IF get_opm_transaction_c2%ISOPEN THEN
          CLOSE get_opm_transaction_c2;
       END IF;

     /*ELSE
         GMI_RESERVATION_UTIL.println('OPM Transaction Not Found');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;*/
     END IF;
  END IF;


  GMI_RESERVATION_UTIL.println('Retrieve OPM Transaction => ' ||l_old_transaction_rec.trans_id );
  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
     (l_old_transaction_rec, l_old_transaction_rec )
  THEN

     l_src_qty := GMI_RESERVATION_UTIL.Get_Opm_converted_qty
           (
               p_apps_item_id     => p_shipping_line.inventory_item_id,
               p_organization_id  => p_shipping_line.organization_id,
               p_apps_from_uom    => p_shipping_line.src_requested_quantity_uom,
               p_apps_to_uom      => p_shipping_line.requested_quantity_uom,
               p_original_qty     => p_shipping_line.src_requested_quantity
           ) ;
     l_ship_qty_above := p_shipping_line.ship_tolerance_above * abs(l_src_qty) /100;
     l_ship_qty_below := p_shipping_line.ship_tolerance_below * abs(l_src_qty) /100;
     GMI_RESERVATION_UTIL.println('shipping tolerance above %' ||p_shipping_line.ship_tolerance_above);
     GMI_RESERVATION_UTIL.println('shipping tolerance below %' ||p_shipping_line.ship_tolerance_below);
     GMI_RESERVATION_UTIL.println('shipping tolerance above qty' ||l_ship_qty_above);
     GMI_RESERVATION_UTIL.println('shipping tolerance below qty' ||l_ship_qty_below);

    /*  We have the transaction we need. See if we are shipping within */
    /*  the permitted tolerance. If we are, then we reverse out the */
    /*  existing transaction, insert a new transaction for the  */
    /*  shipped amount and then complete it. If the quantity exactly */
    /*  matches the transaction quantity, simply complete the one */
    /*  which already exists. */
    /*  Before Completing any transactions lets Lock The Rows. */
    /*  Calling OPM Lock Inventory Routine. */

      -- PK Bug 3527599 Moving Lock_Inventory call from here to just before
      -- UPDATE_PENDING_TO_COMPLETED call.

    GMI_RESERVATION_UTIL.println('Correct Transaction Found');
    PRINT_DEBUG (l_old_transaction_rec,'FETCH RECORD');

    /*  Note That OPM Trans Qtys Are Negative and that the shipped qtys */
    /*  Are Positive. Therefore For Checks Convert the Trans_qty to a positive */
    /*  Value Using ABS() rather than ( -1 * variable). */

    GMI_RESERVATION_UTIL.println('Shipped  Qty => ' || p_shipping_line.shipped_quantity);
    GMI_RESERVATION_UTIL.println('Transaction Qty => ' || ABS(l_old_transaction_rec.trans_qty));


    PRINT_DEBUG (l_old_transaction_rec,'Original Transaction');

    IF p_shipping_line.shipped_quantity = ABS(l_src_qty)
    THEN

      GMI_RESERVATION_UTIL.println('Ship Qty = Trans Qty');
      GMI_RESERVATION_UTIL.println('Completing existing transaction');
      PRINT_DEBUG (l_old_transaction_rec,'COMPLETE RECORD');

      /*  Need To Update The Actual Shipment Date */

      /* l_old_transaction_rec.trans_date := p_actual_ship_date; */
      /* Bug 2547509 */
      l_old_transaction_rec.trans_date := GMI_TRANS_DATE (p_actual_ship_date,
                                                          l_old_transaction_rec.orgn_code,
                                                          l_old_transaction_rec.whse_code);
      /* Bug 2775197 */
      IF  l_allowneginv <> 1 THEN
         IF INVENTORY_GOING_NEG(l_old_transaction_rec) THEN
            GMI_RESERVATION_UTIL.println('Profile GMI: Allow Negative Inventory = '||to_char(l_allowneginv));
            GMI_RESERVATION_UTIL.println('WARNING:Inventory going negative. Transaction not completed for Trans ID '||
                                         to_char(l_old_transaction_rec.trans_id));
            rollback to process_shipments;
            RAISE INVENTORY_NEG_WARNING;
         END IF;
       END IF;

      /* NC Added line_detail_id. Bug#1675561 */

       -- PK Bug 3527599 Moving Lock_Inventory call here from above.
       GMI_reservation_Util.PrintLn('Attempt to Lock Inventory');

       GMI_Locks.Lock_Inventory
          (
            i_item_id      => l_old_transaction_rec.item_id
          , i_whse_code    => l_old_transaction_rec.whse_code
          , i_lot_id       => l_old_transaction_rec.lot_id
          , i_lot_status   => l_old_transaction_rec.lot_status
          , i_location     => l_old_transaction_rec.location
          , o_lock_status  => l_lock_status
          );

       IF (l_lock_status = FALSE) THEN
          GMI_reservation_Util.PrintLn('Lock_Inventory Failed');
          FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
          FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Locks.Lock_Inventory');
          FND_MESSAGE.Set_Token('WHERE', 'GMI_UPDATE_SHIPMENT_TXN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_old_transaction_rec
      , l_old_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error Could Not Complete');
        GMI_RESERVATION_UTIL.println('Inv Eng Msg:'||x_msg_data);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF p_shipping_line.shipped_quantity <= ABS(l_src_qty)
                                           + l_ship_qty_above
         AND p_shipping_line.shipped_quantity >= ABS(l_src_qty)
                                           - l_ship_qty_below
    THEN

      GMI_RESERVATION_UTIL.println('Shipping Within Tolerance');

      GMI_RESERVATION_UTIL.println('Delete Original Transaction');
      PRINT_DEBUG (l_old_transaction_rec, 'DELETE RECORD');

      GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_old_transaction_rec
      , l_old_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error returned by Delete_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_new_transaction_rec := l_old_transaction_rec;
      l_new_transaction_rec.trans_qty2:= -1 * p_shipping_line.shipped_quantity2;
      l_new_transaction_rec.trans_qty := -1 * p_shipping_line.shipped_quantity;
      l_new_transaction_rec.trans_id  := NULL;

      /* NC Added line_detail_id. Bug1675561 */
      l_new_transaction_rec.line_detail_id := p_shipping_line.delivery_detail_id;


      GMI_RESERVATION_UTIL.println('Write New Transaction');
      PRINT_DEBUG (l_new_transaction_rec,'CREATE NEW');

      GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_new_transaction_rec
      , l_new_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_new_transaction_rec.trans_id := l_new_transaction_row.trans_id;

      /*  Need To Update The Actual Shipment Date */

      /* l_new_transaction_rec.trans_date := p_actual_ship_date; */
      /* Bug 2547509 */
      l_new_transaction_rec.trans_date := GMI_TRANS_DATE (p_actual_ship_date,
                                                          l_new_transaction_rec.orgn_code,
                                                          l_new_transaction_rec.whse_code);
      /* Bug 2775197 */
      IF  l_allowneginv <> 1 THEN
         IF INVENTORY_GOING_NEG(l_new_transaction_rec) THEN
            GMI_RESERVATION_UTIL.println('Profile GMI: Allow Negative Inventory = '||to_char(l_allowneginv));
            GMI_RESERVATION_UTIL.println('WARNING:Inventory going negative. Transaction not completed for Trans ID '||
                                         to_char(l_new_transaction_rec.trans_id));
            rollback to process_shipments;
            RAISE INVENTORY_NEG_WARNING;
         END IF;
       END IF;

      GMI_RESERVATION_UTIL.println('Update New Transaction => Completed');

      PRINT_DEBUG (l_new_transaction_rec,'UPDATE TO COMPLETE');

      GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_new_transaction_rec
      , l_new_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error Could Not Complete');
        GMI_RESERVATION_UTIL.println('Inv Eng Msg:'||x_msg_data);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      GMI_RESERVATION_UTIL.find_default_lot
           (  x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              x_reservation_id    => l_trans_id,
              p_line_id           => l_new_transaction_rec.line_id
           );
      IF nvl(l_trans_id,0) > 0 THEN -- bug 2124600
        l_new_transaction_rec.trans_id := l_trans_id;
        IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
           (l_new_transaction_rec, l_new_transaction_rec )
        THEN
          l_new_transaction_rec.trans_qty := 0;
          l_new_transaction_rec.trans_qty2 := 0;

          GMI_RESERVATION_UTIL.println('shipping within tolerance ');
          PRINT_DEBUG (l_new_transaction_rec,' 0 out Default Transaction');

          GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
          ( 1
          , FND_API.G_FALSE
          , FND_API.G_FALSE
          , FND_API.G_VALID_LEVEL_FULL
          , l_new_transaction_rec
          , l_new_transaction_row
          , x_return_status
          , x_msg_count
          , x_msg_data
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      END IF;
    ELSIF p_shipping_line.shipped_quantity >
          ABS(l_src_qty) + l_ship_qty_above
    THEN
      GMI_RESERVATION_UTIL.println('Shipping More Than Tolerance');
      /*  Complain. We are not allowed to overship */
      NULL;
    ELSE
      /* the split of inv for lot controled item is done in ship confirm */
      /* so this portion of the code is only applicable for non-controled items or over pick */
      IF l_lot_ctl = 0 and l_loct_ctl * l_whse_ctl = 0 THEN
         GMI_RESERVATION_UTIL.println('Creating Partial Shipment');

         l_new_transaction_rec := l_old_transaction_rec;

         GMI_RESERVATION_UTIL.println('Delete Original Transaction');
         PRINT_DEBUG (l_old_transaction_rec,'Delete Original');

         GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
         ( 1
         , FND_API.G_FALSE
         , FND_API.G_FALSE
         , FND_API.G_VALID_LEVEL_FULL
         , l_old_transaction_rec
         , l_old_transaction_row
         , x_return_status
         , x_msg_count
         , x_msg_data
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
           GMI_RESERVATION_UTIL.println('Error returned by Delete_Pending_Transaction');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         /*  Create a new transaction for the shipped quantity */

         l_new_transaction_rec.trans_qty2:= -1 * p_shipping_line.shipped_quantity2;
         l_new_transaction_rec.trans_qty := -1 * p_shipping_line.shipped_quantity;
         l_new_transaction_rec.trans_id  := NULL;
         /* LG backorder, it is always trun the staged as 1 for lot controled items,
           not quite so for non controled, thus this is neccessary */
         l_new_transaction_rec.staged_ind  := 1;

          /* NC - Added line_detail_id. Bug1675561 */
         l_new_transaction_rec.line_detail_id := p_shipping_line.delivery_detail_id;


         GMI_RESERVATION_UTIL.println('Create New Transaction For Shipped Qty');
         PRINT_DEBUG (l_new_transaction_rec,'Create NEW');

         GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
         ( 1
         , FND_API.G_FALSE
         , FND_API.G_FALSE
         , FND_API.G_VALID_LEVEL_FULL
         , l_new_transaction_rec
         , l_new_transaction_row
         , x_return_status
         , x_msg_count
         , x_msg_data
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
           GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_new_transaction_rec.trans_id := l_new_transaction_row.trans_id;
         /*  Need To Update The Actual Shipment Date */
         /* l_new_transaction_rec.trans_date := p_actual_ship_date; */
         /* Bug 2547509 */
         l_new_transaction_rec.trans_date := GMI_TRANS_DATE (p_actual_ship_date,
                                                             l_new_transaction_rec.orgn_code,
                                                             l_new_transaction_rec.whse_code);
         /* Bug 2775197 */
         IF  l_allowneginv <> 1 THEN
            IF INVENTORY_GOING_NEG(l_new_transaction_rec) THEN
               GMI_RESERVATION_UTIL.println('Profile GMI: Allow Negative Inventory = '||to_char(l_allowneginv));
               GMI_RESERVATION_UTIL.println('WARNING:Inventory going negative. Transaction not completed for Trans ID '||
                                         to_char(l_new_transaction_rec.trans_id));
               rollback to process_shipments;
               RAISE INVENTORY_NEG_WARNING;
            END IF;
         END IF;

         GMI_RESERVATION_UTIL.println('Update New Transaction to Completed');
         PRINT_DEBUG (l_new_transaction_rec,'UPDATE NEW');

         GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
         ( 1
         , FND_API.G_FALSE
         , FND_API.G_FALSE
         , FND_API.G_VALID_LEVEL_FULL
         , l_new_transaction_rec
         , l_new_transaction_row
         , x_return_status
         , x_msg_count
         , x_msg_data
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
           GMI_RESERVATION_UTIL.println('Error : Cannot Complete the transaction.');
           GMI_RESERVATION_UTIL.println('Inv Eng Msg:'||x_msg_data);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         GMI_RESERVATION_UTIL.println('Handle Split');
         GMI_RESERVATION_UTIL.println('OLD QTY = > ' || l_old_transaction_rec.trans_qty);
         GMI_RESERVATION_UTIL.println('NEW QTY = > ' || l_new_transaction_rec.trans_qty);
         GMI_RESERVATION_UTIL.println('BACK QTY = > ' || p_shipping_line.cycle_count_quantity);

         /*  We now need to sort out the transaction for the default lot.  */
         /*  There are two cases to consider and the cursor will retrieve */
         /*  the characteristics of the row we need (if it exists) */

         /*  a) If a staged default lot transaction exists, create a new */
         /*     staged transaction for the residual quantities */
         /*     otherwise */
         /*  c) If no default transaction exists, create the same transaction */
         /*     as would have been created in 'b'. */

         l_delta_trans_qty1:= ABS(l_old_transaction_rec.trans_qty) -
                              ABS(l_new_transaction_rec.trans_qty);

         l_delta_trans_qty2:= ABS(l_old_transaction_rec.trans_qty2) -
                              ABS(l_new_transaction_rec.trans_qty2);

         /*  Added Following Logic To Get Correct TXN Qty's */

         IF l_delta_trans_qty1 > 0 THEN
            l_delta_trans_qty1 := l_delta_trans_qty1 * -1;
            l_delta_trans_qty2 := l_delta_trans_qty2 * -1;
         END IF;

         /*   End Logic To Get Correct TXN Qty's */
         GMI_RESERVATION_UTIL.println('delta Qty  = > ' || l_delta_trans_qty1);
         GMI_RESERVATION_UTIL.println('delta Qty2 = > ' || l_delta_trans_qty2);

         /* get the defualt trans */
         OPEN default_transaction_c;
         FETCH default_transaction_c INTO l_trans_id;
         IF default_transaction_c%NOTFOUND
         THEN
           /* B1504749, 21-Nov-2000 odaboval : added CLOSE cursor here. */
           CLOSE default_transaction_c;

           GMI_RESERVATION_UTIL.println('Create New Transaction For Staged');
           /*  We need to create the default, staged row */

           l_new_transaction_rec.trans_id := NULL;
           l_new_transaction_rec.trans_qty := l_delta_trans_qty1;
           l_new_transaction_rec.trans_qty2:= l_delta_trans_qty2;
           /* LG overpicking backorder , only non controled split would happen here
             and it would for back order only */
           l_new_transaction_rec.staged_ind := 0;

           l_new_transaction_rec.line_detail_id := null;


           PRINT_DEBUG (l_new_transaction_rec,'CREATE NEW Staged');

           GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
           ( 1
           , FND_API.G_FALSE
           , FND_API.G_FALSE
           , FND_API.G_VALID_LEVEL_FULL
           , l_new_transaction_rec
           , l_new_transaction_row
           , x_return_status
           , x_msg_count
           , x_msg_data
           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           GMI_RESERVATION_UTIL.println('created trans_id='||l_new_transaction_row.trans_id);
           GMI_RESERVATION_UTIL.println('and its staged_ind='||l_new_transaction_row.staged_ind);

         ELSE
           /* B1504749, 21-Nov-2000 odaboval : added CLOSE cursor here. */
           CLOSE default_transaction_c;

           /*  We need to increase the amounts in the existing transaction */
           l_old_transaction_rec.trans_id := l_trans_id;
           IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
              (l_old_transaction_rec, l_old_transaction_rec )
           THEN
             l_old_transaction_rec.trans_qty := l_old_transaction_rec.trans_qty +
                                                l_delta_trans_qty1;
             l_old_transaction_rec.trans_qty2:= l_old_transaction_rec.trans_qty2 +
                                                l_delta_trans_qty2;

             GMI_RESERVATION_UTIL.println('Update Default For Staged');

             GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
             ( 1
             , FND_API.G_FALSE
             , FND_API.G_FALSE
             , FND_API.G_VALID_LEVEL_FULL
             , l_old_transaction_rec
             , l_old_transaction_row
             , x_return_status
             , x_msg_count
             , x_msg_data
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS
             THEN
               GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
         END IF;
      ELSE
         /* over picking but shipped less than picked */
         /* keep in mind that the inv split is done in ship confirm */
         /* do 2 things here, complete the inv with the shipped qty
            then balance the default */
         GMI_RESERVATION_UTIL.println('overpicked, but shipping < picked ');
         l_new_transaction_rec := l_old_transaction_rec;
         l_new_transaction_rec.trans_qty2:= -1 * p_shipping_line.shipped_quantity2;
         l_new_transaction_rec.trans_qty := -1 * p_shipping_line.shipped_quantity;
         /* l_new_transaction_rec.trans_date := p_actual_ship_date; */
         /* Bug 2547509 */
         l_new_transaction_rec.trans_date := GMI_TRANS_DATE (p_actual_ship_date,
                                                             l_new_transaction_rec.orgn_code,
                                                             l_new_transaction_rec.whse_code);
         /* Bug 2775197 */
         IF  l_allowneginv <> 1 THEN
            IF INVENTORY_GOING_NEG(l_new_transaction_rec) THEN
               GMI_RESERVATION_UTIL.println('Profile GMI: Allow Negative Inventory = '||to_char(l_allowneginv));
               GMI_RESERVATION_UTIL.println('WARNING:Inventory going negative. Transaction not completed for Trans ID '||
                                         to_char(l_new_transaction_rec.trans_id));
               rollback to process_shipments;
               RAISE INVENTORY_NEG_WARNING;
            END IF;
         END IF;

         GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
         ( 1
         , FND_API.G_FALSE
         , FND_API.G_FALSE
         , FND_API.G_VALID_LEVEL_FULL
         , l_new_transaction_rec
         , l_new_transaction_row
         , x_return_status
         , x_msg_count
         , x_msg_data
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
           GMI_RESERVATION_UTIL.println('Error : Cannot Complete the transaction.');
           GMI_RESERVATION_UTIL.println('Inv Eng Msg:'||x_msg_data);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         /* find the default transaction */
         OPEN default_transaction_c;
         FETCH default_transaction_c INTO l_trans_id;
         CLOSE default_transaction_c;
         l_new_transaction_rec.trans_id := l_trans_id;
         IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
            (l_new_transaction_rec, l_new_transaction_rec )
         THEN
           GMI_RESERVATION_UTIL.println('balancing default lot.');
           GMI_RESERVATION_UTIL.balance_default_lot
             ( p_ic_default_rec            => l_new_transaction_rec
             , p_opm_item_id               => l_new_transaction_rec.item_id
             , x_return_status             => x_return_status
             , x_msg_count                 => x_msg_count
             , x_msg_data                  => x_msg_data
             );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
      END IF;

      /* B1504749, 21-Nov-2000 odaboval : removed CLOSE cursor here. */
      /* CLOSE default_transaction_c; */
    END IF;
  ELSE
    GMI_RESERVATION_UTIL.println('could not locate the original transaction');
    /*  We could not locate the original transaction. */
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  EXCEPTION

  WHEN INVENTORY_NEG_WARNING THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

  WHEN NO_DATA_FOUND THEN
    rollback to  process_shipments;
    x_return_status := FND_API.G_RET_STS_ERROR;
    GMI_RESERVATION_UTIL.Println('Raised No Data Found');

  WHEN OTHERS
  THEN
    rollback to  process_shipments;
    x_return_status := FND_API.G_RET_STS_ERROR;
    GMI_RESERVATION_UTIL.Println('Raised When Others');

    /* B1504749, 21-Nov-2000 odaboval : removed CLOSE cursor here. */
    /* CLOSE default_transaction_c; */
END GMI_UPDATE_SHIPMENT_TXN;

/* rewritten after OM changes from wsh */
PROCEDURE GMI_UPDATE_SHIPMENT_TXN_new
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , p_actual_ship_date              IN  DATE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   )
IS

  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_def_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_old_transaction_row    ic_tran_pnd%ROWTYPE;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_line_id                ic_tran_pnd.line_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_delta_trans_qty2       NUMBER;
  l_delta_trans_qty1       NUMBER;
  l_trans_id               NUMBER;
  l_lock_status            BOOLEAN;
  l_line_detail_id         NUMBER;
  l_loct_ctl               NUMBER;
  l_whse_ctl               NUMBER;
  l_lot_ctl                NUMBER;
  l_default_trans_id       NUMBER;
  l_cnt_trans              NUMBER;

  /* this cursor should include the default lot for the non ctl items
     The split happens for the interface in split_trans */
  CURSOR get_opm_transaction_c
  IS
    SELECT trans_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_shipping_line.source_line_id
    AND    line_detail_id = p_shipping_line.delivery_detail_id
    AND    delete_mark = 0
    ORDER BY trans_id;

  /* B2547509 Added following cursor */
  CURSOR get_opm_transaction_cnt
  IS
    SELECT count(*)
    FROM   ic_tran_pnd itp
    WHERE  doc_type       ='OMSO'
    AND    line_id        = p_shipping_line.source_line_id
    AND    line_detail_id = p_shipping_line.delivery_detail_id
    AND    delete_mark    = 1
    AND    exists (select 1
                   from   wsh_delivery_Details
                   where  line_id            = p_shipping_line.source_line_id
                   and    delivery_detail_id = p_shipping_line.delivery_detail_id
                   and    shipped_quantity   = (-1)*itp.trans_qty);

  l_ship_qty_above        NUMBER;
  l_ship_qty_below        NUMBER;
  l_allowneginv           NUMBER;

BEGIN
  /*  Standard Start OF API savepoint */

  SAVEPOINT process_shipments;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  GMI_RESERVATION_UTIL.println('Start Of OPM Inventory Interface Routine');
  GMI_RESERVATION_UTIL.println('delivery_detail_id '||p_shipping_line.delivery_detail_id);
  GMI_RESERVATION_UTIL.println('shipped_qty '||p_shipping_line.shipped_quantity);

  OPEN get_opm_transaction_c;
  FETCH get_opm_transaction_c INTO l_old_transaction_rec.trans_id;
  IF get_opm_transaction_c%NOTFOUND THEN
     Close get_opm_transaction_c;
     GMI_RESERVATION_UTIL.println('OPM Transaction Not Found: get_opm_transaction_c');
     /* Begin B2547509 */
     /* Check if this transaction is deleted by chance */
     OPEN  get_opm_transaction_cnt;
     FETCH get_opm_transaction_cnt into l_cnt_trans;
     CLOSE get_opm_transaction_cnt;
     IF (l_cnt_trans > 1) THEN
        GMI_RESERVATION_UTIL.println('Multiple deleted transactions found - Manual updates are necessary');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_cnt_trans = 1) THEN
        /*  update the transaction's delete mark to 0 and proceed */
        UPDATE ic_tran_pnd
        SET    delete_mark    = 0
        WHERE  doc_type       = 'OMSO'
        AND    line_id        = p_shipping_line.source_line_id
        AND    line_detail_id = p_shipping_line.delivery_detail_id
        AND    delete_mark    = 1
        returning trans_id into l_old_transaction_rec.trans_id;
        GMI_RESERVATION_UTIL.println('Undeleted transaction '||to_char(l_old_transaction_rec.trans_id));
     ELSE
        GMI_RESERVATION_UTIL.println('Transaction for the line_id/line_detail_id not found or');
        GMI_RESERVATION_UTIL.println(' the shipped quantity and transaction quantity do not match');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     /* End B2547509 */
  END IF;
  /* B2886561 check if cursor is open before closing */
  IF get_opm_transaction_c%ISOPEN THEN
     CLOSE get_opm_transaction_c;
  END IF;

  GMI_RESERVATION_UTIL.println('Retrieve OPM Transaction => ' ||l_old_transaction_rec.trans_id );
  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
     (l_old_transaction_rec, l_old_transaction_rec )
  THEN
     -- PK Bug 3527599 Moving Lock_Inventory call from here to just before
     -- UPDATE_PENDING_TO_COMPLETED call.

     GMI_RESERVATION_UTIL.println('Correct Transaction Found');

     GMI_RESERVATION_UTIL.println('Shipped  Qty => ' || p_shipping_line.shipped_quantity);
     GMI_RESERVATION_UTIL.println('Transaction Qty => ' || ABS(l_old_transaction_rec.trans_qty));
     GMI_RESERVATION_UTIL.println('Completing existing transaction');

     l_new_transaction_rec := l_old_transaction_rec;
     l_new_transaction_rec.trans_qty2:= -1 * p_shipping_line.shipped_quantity2;
     l_new_transaction_rec.trans_qty := -1 * p_shipping_line.shipped_quantity;
     /* l_new_transaction_rec.trans_date := p_actual_ship_date; */
     /* Bug 2547509 */
     l_new_transaction_rec.trans_date := GMI_TRANS_DATE (p_actual_ship_date,
                                                         l_new_transaction_rec.orgn_code,
                                                         l_new_transaction_rec.whse_code);
     /* Bug 2775197 */
     -- HW 3385851. Added this fix for Pushkar
  BEGIN
    l_allowneginv := nvl(fnd_profile.value('IC$ALLOWNEGINV'),0);
    EXCEPTION
      WHEN OTHERS THEN
          gmi_reservation_util.println('Error in reading PROFILE: Allow Negative Inventory');
          l_allowneginv := 0;
  END;
-- end of 3385851
     IF  l_allowneginv <> 1 THEN
        IF INVENTORY_GOING_NEG(l_new_transaction_rec) THEN
           GMI_RESERVATION_UTIL.println('Profile GMI: Allow Negative Inventory = '||to_char(l_allowneginv));
           GMI_RESERVATION_UTIL.println('WARNING:Inventory going negative. Transaction not completed for Trans ID '||
                                         to_char(l_new_transaction_rec.trans_id));
           rollback to process_shipments;
           RAISE INVENTORY_NEG_WARNING;
        END IF;
     END IF;

     -- PK Bug 3527599 Moving Lock_Inventory call here from above.
     GMI_reservation_Util.PrintLn('Attempt to Lock Inventory');
     GMI_Locks.Lock_Inventory
          (
            i_item_id      => l_old_transaction_rec.item_id
          , i_whse_code    => l_old_transaction_rec.whse_code
          , i_lot_id       => l_old_transaction_rec.lot_id
          , i_lot_status   => l_old_transaction_rec.lot_status
          , i_location     => l_old_transaction_rec.location
          , o_lock_status  => l_lock_status
          );

     IF (l_lock_status = FALSE) THEN
          GMI_reservation_Util.PrintLn('Lock_Inventory Failed');
          FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
          FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Locks.Lock_Inventory');
          FND_MESSAGE.Set_Token('WHERE', 'GMI_UPDATE_SHIPMENT_TXN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     PRINT_DEBUG (l_new_transaction_rec,'COMPLETE RECORD');

     GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
     ( 1
     , FND_API.G_FALSE
     , FND_API.G_FALSE
     , FND_API.G_VALID_LEVEL_FULL
     , l_new_transaction_rec
     , l_new_transaction_row
     , x_return_status
     , x_msg_count
     , x_msg_data
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        GMI_RESERVATION_UTIL.println('Error Could Not Complete');
        GMI_RESERVATION_UTIL.println('Inv Eng Msg:'||x_msg_data);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     /* only need to balance default lot for overpickiing */
     GMI_RESERVATION_UTIL.println('find_deafult_lot ');
     /* find the default transaction */
     GMI_RESERVATION_UTIL.find_default_lot
           (  x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              x_reservation_id    => l_trans_id,
              p_line_id           => l_new_transaction_rec.line_id
           );
     /* because OM int is done first, there might not be a default lot associated with this line_id*/
     IF nvl(l_trans_id,0) > 0 THEN -- no balancing if no default exist
        l_new_transaction_rec.trans_id := l_trans_id;
        IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
           (l_new_transaction_rec, l_new_transaction_rec )
        THEN
          l_ship_qty_above := p_shipping_line.ship_tolerance_above * abs(l_old_transaction_rec.trans_qty) /100;
          l_ship_qty_below := p_shipping_line.ship_tolerance_below * abs(l_old_transaction_rec.trans_qty) /100;
          GMI_RESERVATION_UTIL.println('shipping tolerance above %' ||p_shipping_line.ship_tolerance_above/100);
          GMI_RESERVATION_UTIL.println('shipping tolerance below %' ||p_shipping_line.ship_tolerance_below/100);
          GMI_RESERVATION_UTIL.println('shipping tolerance above qty' ||l_ship_qty_above);
          GMI_RESERVATION_UTIL.println('shipping tolerance below qty' ||l_ship_qty_below);
          /* if ship within tolerance, 0 out the default lot */
          IF p_shipping_line.shipped_quantity <= ABS(p_shipping_line.requested_quantity )
                                           + l_ship_qty_above
             AND p_shipping_line.shipped_quantity >= ABS(p_shipping_line.requested_quantity)
                                           - l_ship_qty_below
          THEN
            l_new_transaction_rec.trans_qty := 0;
            l_new_transaction_rec.trans_qty2 := 0;

            GMI_RESERVATION_UTIL.println('shipping within tolerance ');
            PRINT_DEBUG (l_new_transaction_rec,' 0 out Default Transaction');

            GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
            ( 1
            , FND_API.G_FALSE
            , FND_API.G_FALSE
            , FND_API.G_VALID_LEVEL_FULL
            , l_new_transaction_rec
            , l_new_transaction_row
            , x_return_status
            , x_msg_count
            , x_msg_data
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          ELSE
            GMI_RESERVATION_UTIL.println('balancing default lot.');
            GMI_RESERVATION_UTIL.balance_default_lot
               ( p_ic_default_rec            => l_new_transaction_rec
               , p_opm_item_id               => l_new_transaction_rec.item_id
               , x_return_status             => x_return_status
               , x_msg_count                 => x_msg_count
               , x_msg_data                  => x_msg_data
               );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
               GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        END IF;
     END IF;
  END IF;

  EXCEPTION

  WHEN INVENTORY_NEG_WARNING THEN
    RAISE;

  WHEN NO_DATA_FOUND THEN
    rollback to  process_shipments;
    x_return_status := FND_API.G_RET_STS_ERROR;
    GMI_RESERVATION_UTIL.Println('Raised No Data Found');

  WHEN OTHERS
  THEN
    rollback to  process_shipments;
    x_return_status := FND_API.G_RET_STS_ERROR;
    GMI_RESERVATION_UTIL.Println('Raised When Others');

END GMI_UPDATE_SHIPMENT_TXN_new;

PROCEDURE GMI_APPLY_BACKORDER_UPDATES
   ( p_original_source_line_id       IN  NUMBER
   , p_source_line_id                IN  NUMBER
   , p_action_flag                   IN  VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   )
IS

-- HW BUG#: 1826752
l_delivery_detail_id NUMBER;
l_source_line_id NUMBER;
l_released_status VARCHAR2(5);
l_lot_number VARCHAR2(32);
l_sublot_number VARCHAR2(32);

 Cursor get_bad_delivery  IS
   Select delivery_detail_id , source_line_id,
   released_status,lot_number,sublot_number
   From wsh_delivery_details
   Where  source_line_id = p_source_line_id
   AND   released_status NOT IN ('C','Y');
-- HW END OF BUG#:1826752



  Cursor get_move_order IS
  SELECT move_order_line_id, released_status
  FROM   wsh_delivery_details
  WHERE  source_line_id  = p_source_line_id
  AND    released_status = 'S';
/*   odaboval : Oct-2000, in the where_clause, taken the */
/*              p_source_line_id instead of p_original_source_line_id, in order to */
/*              get the right line. */
/*    WHERE  source_line_id  = p_original_source_line_id */

  l_move_order get_move_order%rowtype;

BEGIN

  /*  Let's First Update all the move order lines ( backordered and */
  /*  Not Pick Confirmed). */

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  GMI_RESERVATION_UTIL.println('In GMI BACKORDER UPDATE');
  GMI_RESERVATION_UTIL.println('P_source_line_id => ' || p_source_line_id);
  GMI_RESERVATION_UTIL.println('Original SOURCE => ' || p_original_source_line_id );

  Open get_move_order;

  LOOP
        FETCH get_move_order into  l_move_order;
        EXIT WHEN get_move_order%NOTFOUND;

     GMI_RESERVATION_UTIL.println('Mo_ID=' || l_move_order.move_order_line_id ||', txn_source_line_id='||p_source_line_id ||', Status='|| l_move_order.released_status);

     Update IC_TXN_REQUEST_LINES
        SET    TXN_SOURCE_LINE_ID = p_source_line_id
        WHERE  line_id = l_move_order.move_order_line_id;

        IF (SQL%NOTFOUND) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            GMI_RESERVATION_UTIL.println('Error In Updating MO LINE');
            Close get_move_order;  /* B2886561 close cursor before exception */
            RAISE NO_DATA_FOUND;
        END IF;

  END LOOP;
  IF get_move_order%ISOPEN THEN
    Close get_move_order;
  END IF;

-- HW BUG#:1826752
  open get_bad_delivery ;

  LOOP
  FETCH get_bad_delivery into  l_delivery_detail_id,
        l_source_line_id, l_released_status,l_lot_number,l_sublot_number;
  EXIT WHEN get_bad_delivery%NOTFOUND;
     GMI_RESERVATION_UTIL.println('Clearing out information for:');
     GMI_RESERVATION_UTIL.println('++++++++++ ');
     GMI_RESERVATION_UTIL.println('Delivery_detail_id '||l_delivery_detail_id);
     GMI_RESERVATION_UTIL.println('Source_line_id '||l_source_line_id);
     GMI_RESERVATION_UTIL.println('Released_status '||l_released_status);
     GMI_RESERVATION_UTIL.println('Lot_number '||l_lot_number);
     GMI_RESERVATION_UTIL.println('Sublot_number '||l_sublot_number);
     GMI_RESERVATION_UTIL.println('++++++++++ ');
  END LOOP;
  CLOSE get_bad_delivery;
-- HW END OF BUG#:1826752


  /*  When a backorder line has been created in oe_order_line_all,   */
  /*  the outstanding pending transactions must be updated to point */
  /*  to the new line_id.          */
  /*  The shipping line must be updated to align with backorder  */
  /*  default lot transactions (cycle count quantity) */

          /* B1504749, 5-Dec-2000 odaboval : added released_status clause */
-- HW BUG#:1854224 closed the comment properly
          /* HW BUG#:1826752 exclude shipped (C) and staged (Y) */
          UPDATE wsh_delivery_details
          SET locator_id = NULL,
              lot_number = NULL,
              sublot_number = NULL
          WHERE source_line_id = p_source_line_id
          AND   released_status NOT IN ('Y','C')
          AND   p_action_flag = 'B';
          /*  HAM RE_CHECK */
          /*  and ship_confirm_action_flag = 'B'; */
          IF (SQL%NOTFOUND)
          THEN
               GMI_RESERVATION_UTIL.println('No Update in wsh_delivery_details, line_id='||p_source_line_id);

--               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
--               RAISE NO_DATA_FOUND;
          END IF;

GMI_RESERVATION_UTIL.println('New  Line Id => '|| p_source_line_id );
GMI_RESERVATION_UTIL.println('Orig Line Id => '|| p_original_source_line_id);



  /* this only happens for non control item where the shared default lot is not good */
  /*IF p_action_flag = 'B' THEN
     UPDATE ic_tran_pnd
     SET line_id = p_source_line_id ,
         staged_ind = 0
     WHERE line_id = p_original_source_line_id and
         doc_type = 'OMSO' and
         completed_ind = 0 and
         delete_mark = 0;
  ELSE*/
     UPDATE ic_tran_pnd
     SET line_id = p_source_line_id
     WHERE line_id = p_original_source_line_id and
         doc_type = 'OMSO' and
         completed_ind = 0 and
         delete_mark = 0;
  --END IF;
  IF (SQL%NOTFOUND) THEN
     /* bug 1783859 */
     /*for a pure back order line, this trans may not exsit, no error should be returned*/
     GMI_RESERVATION_UTIL.println('No Update in ic_tran_pnd, line_id='||p_source_line_id);
                --x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                --RAISE NO_DATA_FOUND;
        END IF;


GMI_RESERVATION_UTIL.println('At the end of GMI_Apply_BacKOrder_Updated, No Error.');

  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
   GMI_RESERVATION_UTIL.println('No Data Found raised');
  WHEN OTHERS
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
   GMI_RESERVATION_UTIL.println('RAISE WHEN OTHERS');
END GMI_APPLY_BACKORDER_UPDATES;

/* NC Added the following two procedures. Bug#1675561 */
PROCEDURE UPDATE_OPM_TRANSACTION
   ( p_old_delivery_detail_id  IN NUMBER,
     p_lot_number              IN VARCHAR2,
     p_sublot_number           IN VARCHAR2,
     p_organization_id         IN NUMBER,
     p_inventory_item_id       IN NUMBER,
     p_old_source_line_id      IN NUMBER,
     p_locator_id              IN NUMBER,
     p_new_delivery_detail_id  IN  NUMBER,
     p_old_req_quantity        IN  NUMBER,
     p_old_req_quantity2       IN  NUMBER,
     p_req_quantity            IN  NUMBER,
     p_req_quantity2           IN  NUMBER DEFAULT NULL,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2)
IS
  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_old_transaction_row    ic_tran_pnd%ROWTYPE ;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_line_id                ic_tran_pnd.line_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_line_detail_id         wsh_delivery_details.delivery_detail_id%TYPE;
  l_reduction_factor       NUMBER;
  l_delta_trans_qty2       NUMBER;
  l_trans_id               NUMBER;
  l_staged_ind             NUMBER;
  l_lot_ctl                NUMBER;
  l_loct_ctl               NUMBER;
  l_whse_ctl               NUMBER;
  l_lock_status            BOOLEAN;
  l_count                  NUMBER;

  /* Begin Enhancement 2320442 - Lakshmi Swamy */
  l_noninv_ind             NUMBER;

  /* Commented out the following cursor and rewrote it */

  /* CURSOR is_only_default IS
  Select opm.lot_ctl
       , opm.loct_ctl
       , whse.loct_ctl
  From ic_item_mst opm
    , mtl_system_items mtl
    , ic_whse_mst whse
  Where mtl.inventory_item_id = p_inventory_item_id
    and mtl.organization_id = p_organization_id
    and mtl.segment1 = opm.item_no
    and whse.mtl_organization_id = p_organization_id; */

  CURSOR is_only_default IS
    Select noninv_ind
    From ic_item_mst opm,mtl_system_items mtl
    Where mtl.inventory_item_id = p_inventory_item_id
    and mtl.organization_id = p_organization_id
    and mtl.segment1 = opm.item_no;

   /* End Enhancement 2320442 - Lakshmi Swamy */

  CURSOR fetch_opm_transaction
        ( p_old_delievery_detail_id  NUMBER,
          p_old_source_line_id  NUMBER
        ) IS
  SELECT trans_id from
  ic_tran_pnd
  WHERE line_id = p_old_source_line_id
  AND   line_detail_id = p_old_delivery_detail_id
  AND   completed_ind = 0
  AND   delete_mark = 0
  AND   staged_ind = 1;

BEGIN
  SAVEPOINT update_txn;

  /* First  if the item is non inv or non controled, it only has default
     no split for a default transaction */

  /* Begin Enhancement 2320442, 2901317 - Lakshmi Swamy */

  /* OPEN is_only_default;
  FETCH is_only_default into l_lot_ctl, l_loct_ctl,l_whse_ctl;
  CLOSE is_only_default;

  IF (l_lot_ctl = 0 AND (l_loct_ctl * l_whse_ctl ) = 0) THEN
     RETURN;
  END IF; */

  /* OPEN is_only_default;
  FETCH is_only_default into l_noninv_ind;
  CLOSE is_only_default;

  IF (l_noninv_ind = 1) THEN
     RETURN;
  END IF; */

  /* End Enhancement 2320442, 2901317 - Lakshmi Swamy */

  SELECT iim.item_id INTO l_item_id
  FROM   ic_item_mst iim,
         mtl_system_items msi
  WHERE  msi.inventory_item_id = p_inventory_item_id
  AND    msi.organization_id = p_organization_id
  AND    msi.segment1 = iim.item_no;

  IF p_locator_id IS NULL
  THEN
    l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  ELSE
    SELECT location INTO l_location
    FROM   ic_loct_mst
    WHERE  inventory_location_id = p_locator_id;
  END IF;

  GMI_RESERVATION_UTIL.println('LOT_NUMBER  => ' || p_lot_number);
  GMI_RESERVATION_UTIL.println('SUBLOT_NUMBER  => ' || p_sublot_number);

  IF p_lot_number IS NULL
  THEN
    l_lot_id := 0;
  ELSIF p_sublot_number IS NULL
  THEN
    SELECT lot_id INTO l_lot_id
    FROM   ic_lots_mst
    WHERE  item_id = l_item_id
    AND    lot_no = p_lot_number
    AND    sublot_no IS NULL ;
  ELSE
    SELECT lot_id INTO l_lot_id
    FROM   ic_lots_mst
    WHERE  item_id = l_item_id
    AND    lot_no = p_lot_number
    AND    sublot_no = p_sublot_number;
  END IF;

  /*  With the above retrievals successfully done we can  */
  /*  try to locate the transaction we need. Again, if this fails */
  /*  we cannot proceed so let the exception raised take over. */

  GMI_RESERVATION_UTIL.println('Retrieving OLD TRX in UPDATE_OPM_TRANSACTION ');
  GMI_RESERVATION_UTIL.println('LINE_ID  => ' || p_old_source_line_id);
  GMI_RESERVATION_UTIL.println('LINE_DETAIL_ID  => ' || p_old_delivery_detail_id);
  GMI_RESERVATION_UTIL.println('ITEM_ID  => ' || l_item_id);
  GMI_RESERVATION_UTIL.println('LOT_ID   => ' || l_lot_id);
  GMI_RESERVATION_UTIL.println('Location => ' || l_location);

  OPEN fetch_opm_transaction(p_old_delivery_detail_id,
                             p_old_source_line_id
                             );
  FETCH fetch_opm_transaction INTO  l_old_transaction_rec.trans_id;
  IF(fetch_opm_transaction%NOTFOUND) THEN
    CLOSE fetch_opm_transaction;
    GMI_RESERVATION_UTIL.println('Transaction Not Found in UPDATE_OPM_TRXS');
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE fetch_opm_transaction;

  GMI_RESERVATION_UTIL.println('Retrieve OPM Transaction => ' ||l_old_transaction_rec.trans_id );
  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND (l_old_transaction_rec, l_old_transaction_rec )
  THEN
     GMI_reservation_Util.printLn('OPM Transaction found in OPM_UPDATE_TRXS');
     -- PK Bug 3527599 No need to lock IC_LOCT_INV when updating / creating pending txn.

      GMI_RESERVATION_UTIL.println('Correct Transaction Found');

      PRINT_DEBUG (l_old_transaction_rec,'FETCH RECORD');

      l_old_transaction_rec.trans_qty := -1 * (p_old_req_quantity - p_req_quantity);
      l_old_transaction_rec.trans_qty2 := -1 * (p_old_req_quantity2 - p_req_quantity2);

      GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
        ( 1
        , FND_API.G_FALSE
        , FND_API.G_FALSE
        , FND_API.G_VALID_LEVEL_FULL
        , l_old_transaction_rec
        , l_old_transaction_row
        , x_return_status
        , x_msg_count
        , x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_new_transaction_rec := l_old_transaction_rec;
      l_new_transaction_rec.line_detail_id := p_new_delivery_detail_id;
      l_new_transaction_rec.trans_id := NULL;
      l_new_transaction_rec.trans_qty := -1 * (p_req_quantity);
      l_new_transaction_rec.trans_qty2 := -1 * (p_req_quantity2);

      GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
      ( 1
      , FND_API.G_FALSE
      , FND_API.G_FALSE
      , FND_API.G_VALID_LEVEL_FULL
      , l_new_transaction_rec
      , l_new_transaction_row
      , x_return_status
      , x_msg_count
      , x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    rollback to  update_txn;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE NO_DATA_FOUND;
    GMI_RESERVATION_UTIL.Println('Raised When No Data Found in UPDATE_OPM_TRANSACTION');

    WHEN OTHERS THEN
    rollback to  update_txn;
    x_return_status := FND_API.G_RET_STS_ERROR;
    GMI_RESERVATION_UTIL.Println('Raised When Others in UPDATE_OPM_TRANSACTION');
END UPDATE_OPM_TRANSACTION;

PROCEDURE UPDATE_OPM_IC_TRAN_PND
( p_delivery_detail_id IN NUMBER,
  p_trans_id           IN NUMBER,
  p_staged_flag        IN NUMBER) IS

BEGIN
  IF ( p_delivery_detail_id IS NOT NULL AND p_trans_id is not NULL) THEN

      IF(p_staged_flag = 0) THEN
         UPDATE ic_tran_pnd
         SET    line_detail_id = p_delivery_detail_id
         WHERE  trans_id = p_trans_id ;
      ELSIF (p_staged_flag = 1) THEN
         UPDATE ic_tran_pnd
         SET    line_detail_id = p_delivery_detail_id,
                staged_ind = 1
         WHERE  trans_id = p_trans_id ;
      END IF;

  END IF;

EXCEPTION
 WHEN OTHERS THEN
 GMI_RESERVATION_UTIL.println('*** In update_opm_ic_tran_pnd');
 GMI_RESERVATION_UTIL.println('*** When Others exception raised');
END UPDATE_OPM_IC_TRAN_PND;

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

/* this procedure creates a row in rcv_transaction_interface and calls the
   reveiving transaction processer
 */

PROCEDURE create_rcv_transaction
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , p_trip_stop_rec                 IN  wsh_trip_stops%ROWTYPE
   , p_group_id                      IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2)
IS

l_delivery_id number := NULL;
l_trx_source_type_id number := NULL;
l_trx_action_id number := NULL;
l_trx_type_code number := NULL;
l_error_code number := NULL;
l_error_text varchar2(2000) := NULL;
l_ultimate_dropoff_date DATE := NULL;
l_waybill varchar2(30) := NULL;
l_total_ship_qty number := NULL;
l_total_req_qty number := NULL;
l_req_distribution_id NUMBER := NULL;
l_transfer_subinventory   VARCHAR2(10) := NULL;
l_source_code             VARCHAR2(40) := NULL;
l_transfer_organization   NUMBER := NULL;
l_ship_to_location_id    NUMBER := NULL;
l_requisition_line_id     NUMBER :=NULL;
x_error_code VARCHAR2(240) := NULL;
l_sales_order_id NUMBER := NULL;
l_account                 NUMBER := NULL;
l_group_id                 NUMBER := NULL;
rc                         NUMBER := NULL;
l_transaction_id           NUMBER := NULL;
l_charge_account_id        NUMBER;
l_accrual_account_id       NUMBER;
l_detail_rec            wsh_delivery_details%ROWTYPE;
l_trip_stop_rec         wsh_trip_stops%ROWTYPE;
l_item_desc             VARCHAR2(240) := NULL;
l_unit_of_measure       VARCHAR2(25);
l_secondary_unit_of_measure     VARCHAR2(25);
l_locator_id       NUMBER;
l_subinventory     VARCHAR2(10) := NULL;
l_ctl_ind          VARCHAR2(1) := 'N';
l_del_ship_qty     NUMBER;     -- B3925583
l_del_ship_qty_uom VARCHAR2(25); -- B3925583
CURSOR c_order_line_info(c_order_line_id number) is
SELECT source_document_type_id
     , source_document_id
     , source_document_line_id
from     oe_order_lines_all
where  line_id = c_order_line_id;
l_order_line_info c_order_line_info%ROWTYPE;

CURSOR c_delivery_info is
SELECT a.delivery_id
     , d.waybill
     , d.ultimate_dropoff_date
from wsh_delivery_assignments a,
    wsh_delivery_details dd,
    wsh_new_deliveries d
where  a.delivery_detail_id = dd.delivery_detail_id
and   d.delivery_id = a.delivery_id
and     dd.delivery_detail_id = p_shipping_line.delivery_detail_id
and NVL(dd.container_flag, 'N') = 'N';

CURSOR c_po_info(c_po_line_id number, c_source_document_id number) is
SELECT   destination_type_code,
      destination_subinventory,
      source_organization_id,
      destination_organization_id,
      deliver_to_location_id,
      pl.requisition_line_id,
      pd.distribution_id
from      po_requisition_lines_all pl,
          po_req_distributions_all pd
where    pl.requisition_line_id = c_po_line_id
and      pl.requisition_header_id = c_source_document_id
and      pl.requisition_line_id = pd.requisition_line_id;
l_po_info c_po_info%ROWTYPE;

Cursor get_item_desc IS
Select description
From mtl_system_items
Where inventory_item_id = p_shipping_line.inventory_item_id
   and organization_id = p_shipping_line.organization_id;

CURSOR c_mtl_interorg_parameters (c_from_organization_id NUMBER , c_to_organization_id NUMBER) IS
   SELECT intransit_type
   FROM   mtl_interorg_parameters
   WHERE  from_organization_id = c_from_organization_id AND
          to_organization_id = c_to_organization_id;

Cursor get_default_loct (p_org_id number) IS
Select locator_id
    ,  subinventory_code
From MTL_ITEM_LOC_DEFAULTS
Where inventory_item_id = p_shipping_line.inventory_item_id
   and organization_id = p_org_id;

Cursor get_default_sub (p_org_id number) IS
Select subinventory_code
From  MTL_ITEM_SUB_DEFAULTS
Where inventory_item_id = p_shipping_line.inventory_item_id
and   organization_id = p_org_id;

l_intransit_type NUMBER;

BEGIN
  l_detail_rec := p_shipping_line;
  l_trip_stop_rec := p_trip_stop_rec;
  OPEN c_order_line_info(l_detail_rec.source_line_id);
  FETCH c_order_line_info into l_order_line_info;
  if (c_order_line_info%NOTFOUND) THEN
     CLOSE c_order_line_info;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     GMI_RESERVATION_UTIL.Println('Sales order not valid');
     return;
  END if;
  CLOSE c_order_line_info;

  IF (l_order_line_info.source_document_type_id <> 10) THEN /* internal order */
    RETURN;
  ELSE
    GMI_RESERVATION_UTIL.Println('This line is part of an OPM internal order');

    OPEN c_delivery_info;
    FETCH c_delivery_info
    into l_delivery_id
       , l_waybill
       , l_ultimate_dropoff_date
       ;
    if (c_delivery_info%NOTFOUND) THEN
       CLOSE c_delivery_info;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       GMI_RESERVATION_UTIL.Println('Delivery Detail is not assigned to any delivery');
       return;
       -- raise NOT_ASSIGNED_TO_DEL_ERROR;
    END if;
    CLOSE c_delivery_info;

    /* only for internal purchase orders, we need to fetch the po info */
    OPEN c_po_info(l_order_line_info.source_document_line_id,
                   l_order_line_info.source_document_id);
    FETCH c_po_info into l_po_info;
    if c_po_info%NOTFOUND then
       CLOSE c_po_info;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.Println('Requisition line not found');
       return;
    end if;
    CLOSE c_po_info;
    GMI_RESERVATION_UTIL.Println('Requisition line id:' || l_order_line_info.source_document_line_id);
    GMI_RESERVATION_UTIL.Println('Destination_type_code:' ||l_po_info.destination_type_code );
    GMI_RESERVATION_UTIL.Println('Source organization id:' ||l_po_info.source_organization_id );
    GMI_RESERVATION_UTIL.Println('Destination organization id:' ||l_po_info.destination_organization_id );

    l_transfer_subinventory := l_po_info.destination_subinventory;
    l_transfer_organization := l_po_info.destination_organization_id;
    l_requisition_line_id := l_po_info.requisition_line_id;
    l_ship_to_location_id := l_po_info.deliver_to_location_id;
    l_req_distribution_id := l_po_info.distribution_id;

    IF (l_po_info.destination_type_code = 'EXPENSE') THEN
       GMI_RESERVATION_UTIL.println('Store issue');
       l_trx_source_type_id := 8;
       l_trx_action_id := 1;
       l_trx_type_code := 34 /* Store_issue */;
    ELSIF (l_po_info.destination_type_code = 'INVENTORY') AND
        (l_po_info.source_organization_id = l_po_info.destination_organization_id) THEN
        GMI_RESERVATION_UTIL.println('Sub inventory transfer');
        l_trx_source_type_id := 8;
        l_trx_action_id := 2;
        l_trx_type_code := 50 /* Subinv_xfer */;
    ELSIF (l_po_info.destination_organization_id <> l_po_info.source_organization_id) THEN
          /* Bug 2137423, check mtl_interorg_parameters to decide transaction codes */
          OPEN c_mtl_interorg_parameters( l_po_info.source_organization_id,
                                          l_po_info.destination_organization_id);
          FETCH c_mtl_interorg_parameters INTO l_intransit_type;
          IF c_mtl_interorg_parameters%NOTFOUND THEN
          /* default to intransit */
             GMI_RESERVATION_UTIL.println('In transit shipment');
             l_trx_source_type_id := 8;
             l_trx_action_id := 21;
             l_trx_type_code := 62; /* intransit_shpmnt */
          ELSE
             IF l_intransit_type = 1 THEN
                GMI_RESERVATION_UTIL.println('In direct shipment');
                l_trx_source_type_id := 8;
                l_trx_action_id := 3;
                l_trx_type_code := 54; /* direct shipment */
             ELSE
                GMI_RESERVATION_UTIL.println('In transit shipment');
                l_trx_source_type_id := 8;
                l_trx_action_id := 21;
                l_trx_type_code := 62; /* intransit_shpmnt */
             END IF;
          END IF;
          CLOSE c_mtl_interorg_parameters;
    END IF;
    --If for direct receipt then
    IF l_trx_action_id = 3 THEN
       --check if item is location controlled
       --bug 3380763
       check_loct_ctl
             ( p_inventory_item_id      => p_shipping_line.inventory_item_id
              ,p_mtl_organization_id    => l_po_info.destination_organization_id
              ,x_ctl_ind                => l_ctl_ind
            ) ;
       --if yes then get default subinv and locator from MTL_ITEM_LOC_DEFAULTS
       IF l_ctl_ind = 'Y' THEN
          Open get_default_loct(l_po_info.destination_organization_id) ;
          Fetch get_default_loct into l_locator_id, l_subinventory;
          IF get_default_loct%NOTFOUND THEN
          /* check to see the item is location ctl, if not, raise error */
              GMI_RESERVATION_UTIL.println('Item and the dest Org are location controlled,
                              but no default location setup');
              FND_MESSAGE.Set_Name('GMI','GMI_LOCATION_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC', 'NO DESTINATION DEFAULT_LOC SETUP');
              FND_MESSAGE.Set_Token('WHERE', 'GMI_Create_rcv_trans');
              FND_MSG_PUB.Add;
              Close get_default_loct; /* B2886561 close cursor before exception */
	      /* Bug #3415847 punkumar,commeting out the exception so that it does not stop insertion of record in RTI
              RAISE FND_API.G_EXC_ERROR;
		*/
           END IF;
       --esle if item not location cotrolled then get def subinv from MTL_ITEM_SUB_DEFAULTS
       ELSIF l_ctl_ind = 'N' THEN
          Open get_default_sub(l_po_info.destination_organization_id) ;
          Fetch get_default_sub into l_subinventory;
          IF get_default_sub%NOTFOUND THEN
          /* check to see the item is location ctl, if not, raise error */
              GMI_RESERVATION_UTIL.println('no default subinventory setup for direct receipt');
              FND_MESSAGE.Set_Name('GMI','GMI_LOCATION_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC', 'NO DESTINATION DEFAULT_SUB SETUP');
              FND_MESSAGE.Set_Token('WHERE', 'GMI_Create_rcv_trans');
              FND_MSG_PUB.Add;
              Close get_default_sub; /* B2886561 close cursor before exception */
	      /* Bug #3415847 punkumar,commeting out the exception so that it does not stop insertion of record in RTI
              RAISE FND_API.G_EXC_ERROR;
		*/
           END IF;
       END IF;
       --Close cursors.
       IF get_default_loct%ISOPEN THEN
         Close get_default_loct;
       END IF;
       IF get_default_sub%ISOPEN THEN
         Close get_default_sub;
       END IF;
    END IF;

    --l_account := PO_REQ_DIST_SV1.get_dist_account( l_requisition_line_id  ) ;  -- Bug 1610178

    /*if (  l_account = -11 ) then
       wsh_util_core.println ( 'Error: More than one Distribution accounts ' || l_account );
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
       return;
    elsif  ( l_account is null ) then
       wsh_util_core.println ( 'Error: Cannot get Distribution account ' || l_account );
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
       return;
    end if ;

    wsh_util_core.println ( 'Distribution account is ' || l_account );
    */
    if (l_detail_rec.source_code = 'OE') then
      if (WSH_SHIP_CONFIRM_ACTIONS.ont_source_code is NULL) then
         WSH_SHIP_CONFIRM_ACTIONS.ont_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
      end if;
      l_source_code := WSH_SHIP_CONFIRM_ACTIONS.ont_source_code;
    else
      l_source_code := 'OKE';
    end if;
      GMI_RESERVATION_UTIL.get_OPM_account
                         (
                           v_dest_org_id      => l_po_info.destination_organization_id,
                           v_apps_item_id     => l_detail_rec.inventory_item_id,
                           v_vendor_site_id   => l_detail_rec.org_id ,
                           x_cc_id            => l_charge_account_id,
                           x_ac_id            => l_accrual_account_id
                         );

    GMI_RESERVATION_UTIL.println('Source_code:'|| l_source_code);
    GMI_RESERVATION_UTIL.println('charge_account_id:'|| l_charge_account_id);

    Open get_item_desc;
    Fetch get_item_desc INTO l_item_desc;
    Close get_item_desc;

    GMI_RESERVATION_UTIL.println('Inserting Detail ' || l_detail_rec.delivery_detail_id || ' into RCV_TRANSACTIONS_INTERFACE ');
    select RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL into l_transaction_id from dual;
    l_group_id := p_group_id;

    l_secondary_unit_of_measure := null;

    /*bug 2316449 - Fetch the 25 char Unit of Measure from mtl_units_of_measure for both the UOMs*/
    If l_detail_rec.requested_quantity_uom is not null then
        select   UNIT_OF_MEASURE
        into     l_unit_of_measure
        from  mtl_units_of_measure
        where uom_code =l_detail_rec.requested_quantity_uom;
    End if;

    If l_detail_rec.requested_quantity_uom2 is not null then
        select   UNIT_OF_MEASURE
        into  l_secondary_unit_of_measure
        from  mtl_units_of_measure
        where  uom_code =l_detail_rec.requested_quantity_uom2 ;
    End if;

    -- PK Begin  Bug 3925583

    l_del_ship_qty       := l_detail_rec.shipped_quantity;
    l_del_ship_qty_uom   := l_detail_rec.src_requested_quantity_uom;

    IF (l_detail_rec.requested_quantity_uom2 is not null) AND ( l_detail_rec.src_requested_quantity_uom = l_detail_rec.src_requested_quantity_uom2) THEN
          l_del_ship_qty       := l_detail_rec.shipped_quantity2;
          l_del_ship_qty_uom   := l_detail_rec.src_requested_quantity_uom2;
          l_unit_of_measure    := l_secondary_unit_of_measure;

    END IF;
    -- PK End  Bug 3925583
    -- PK Also changed values to these local variable for Insert into rcv_transactions_interface

    GMI_RESERVATION_UTIL.println('transaction_id ' || l_transaction_id);
    GMI_RESERVATION_UTIL.println('group_id ' ||  l_group_id);
    GMI_RESERVATION_UTIL.println('interface_source_code ' ||  l_source_code);
    GMI_RESERVATION_UTIL.println('interface_source_line_id ' ||  l_detail_rec.source_line_id);
    GMI_RESERVATION_UTIL.println('last_update_date ' ||  sysdate);
     GMI_RESERVATION_UTIL.println('last_updated_by ' || FND_GLOBAL.user_id);
     GMI_RESERVATION_UTIL.println('creation_date ' || sysdate);
     GMI_RESERVATION_UTIL.println('created_by ' || FND_GLOBAL.user_id);
     GMI_RESERVATION_UTIL.println('item_id ' || l_detail_rec.inventory_item_id);
     GMI_RESERVATION_UTIL.println('item_revision ' || l_detail_rec.revision);
     GMI_RESERVATION_UTIL.println('from_org_id ' || l_detail_rec.organization_id);
     GMI_RESERVATION_UTIL.println('to_org_id ' || l_transfer_organization);
     GMI_RESERVATION_UTIL.println('intrasit_owning_org_id ' || l_transfer_organization);
     GMI_RESERVATION_UTIL.println('quantity ' || l_del_ship_qty);
     GMI_RESERVATION_UTIL.println('unit_of_measure ' || l_detail_rec.requested_quantity_uom);
     GMI_RESERVATION_UTIL.println('uom_code ' || l_del_ship_qty_uom);
     GMI_RESERVATION_UTIL.println('secondary_quantity ' || l_detail_rec.shipped_quantity2);
     GMI_RESERVATION_UTIL.println('secondary_uom_code ' || l_detail_rec.requested_quantity_uom2);
     GMI_RESERVATION_UTIL.println('secondary_unit_of_measure ' || l_secondary_unit_of_measure);
     GMI_RESERVATION_UTIL.println('primary_qty ' || null);
     GMI_RESERVATION_UTIL.println('primary_uom ' || null);
     GMI_RESERVATION_UTIL.println('transaction_type ' || 'SHIP');
     GMI_RESERVATION_UTIL.println('transaction_date ' || l_trip_stop_rec.actual_departure_date);
     GMI_RESERVATION_UTIL.println('shipment_num ' || l_delivery_id);
     GMI_RESERVATION_UTIL.println('freight_carrier_code ' || null);
     GMI_RESERVATION_UTIL.println('transfer_cost ' || null);
     GMI_RESERVATION_UTIL.println('transportation_cost ' || null);
     GMI_RESERVATION_UTIL.println('transportation_account ' || null);
     GMI_RESERVATION_UTIL.println('number_of_containers ' || null);
     GMI_RESERVATION_UTIL.println('waybill ' || l_waybill);
     GMI_RESERVATION_UTIL.println('inventory_transaction_id ' || null);
     GMI_RESERVATION_UTIL.println('destination_type_code ' || l_po_info.destination_type_code);
     --GMI_RESERVATION_UTIL.println('transaction_action_id ' || decode(l_trx_action_id,2,'DELIVER',3,'DELIVER',1,'DELIVER','SHIP'));
     GMI_RESERVATION_UTIL.println('receipt_source_code ' || 'INTERNAL ORDER');
     GMI_RESERVATION_UTIL.println('source_document_code ' || 'REQ');
     GMI_RESERVATION_UTIL.println('processing_status_code ' || 'RUNNING');
     GMI_RESERVATION_UTIL.println('transaction_status_code ' || 'PENDING');
     GMI_RESERVATION_UTIL.println('processing_code_mode ' || 'ONLINE');
     GMI_RESERVATION_UTIL.println('from_subinventory ' || l_detail_rec.subinventory);
     GMI_RESERVATION_UTIL.println('subinventory ' || l_transfer_subinventory);
     GMI_RESERVATION_UTIL.println('locator_id ' || l_detail_rec.locator_id);
     GMI_RESERVATION_UTIL.println('category_id ' || null);
     GMI_RESERVATION_UTIL.println('expected_receipt_date ' || l_ultimate_dropoff_date);
     GMI_RESERVATION_UTIL.println('currency_code ' || null);
     GMI_RESERVATION_UTIL.println('currency_conversion_rate ' || null);
     GMI_RESERVATION_UTIL.println('currency_conversion_date ' || SYSDATE);
     GMI_RESERVATION_UTIL.println('currency_conversion_type ' || null);
     GMI_RESERVATION_UTIL.println('ussgl_transaction_code ' || null);
     GMI_RESERVATION_UTIL.println('ship_to_location_id ' || l_ship_to_location_id);
     GMI_RESERVATION_UTIL.println('requisition_line_id ' || l_requisition_line_id);
     GMI_RESERVATION_UTIL.println('req_distribution_id ' || l_req_distribution_id);
     GMI_RESERVATION_UTIL.println('item_description ' || l_item_desc);
     GMI_RESERVATION_UTIL.println('shipped_date ' || l_trip_stop_rec.actual_departure_date);
     GMI_RESERVATION_UTIL.println('routing_header_id ' || null);
     GMI_RESERVATION_UTIL.println('reason_id ' || null);
     GMI_RESERVATION_UTIL.println('movement_id ' || null);
     GMI_RESERVATION_UTIL.println('transfer_percentage ' || null);

/* Bug # 3363725 , punkumar , modified insert sql to insert delivery_detail_id in comments column */

INSERT INTO RCV_TRANSACTIONS_INTERFACE
     (
     INTERFACE_TRANSACTION_ID,
     GROUP_ID,
     INTERFACE_SOURCE_CODE,
     INTERFACE_SOURCE_LINE_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     ITEM_ID,
     ITEM_REVISION,
     FROM_ORGANIZATION_ID,
     TO_ORGANIZATION_ID,
     INTRANSIT_OWNING_ORG_ID,
     QUANTITY,
     UNIT_OF_MEASURE,
     UOM_CODE,
     SECONDARY_QUANTITY,
     SECONDARY_UOM_CODE,
     SECONDARY_UNIT_OF_MEASURE,
     PRIMARY_QUANTITY,
     PRIMARY_UNIT_OF_MEASURE,
     TRANSACTION_TYPE,
     TRANSACTION_DATE,
     SHIPMENT_NUM,
     FREIGHT_CARRIER_CODE,
     TRANSFER_COST,
     TRANSPORTATION_COST,
     TRANSPORTATION_ACCOUNT_ID,
     NUM_OF_CONTAINERS,
     WAYBILL_AIRBILL_NUM,
     INV_TRANSACTION_ID,
     DESTINATION_TYPE_CODE,
     AUTO_TRANSACT_CODE,
     RECEIPT_SOURCE_CODE,
     SOURCE_DOCUMENT_CODE,
     PROCESSING_STATUS_CODE,
     TRANSACTION_STATUS_CODE,
     PROCESSING_MODE_CODE,
     FROM_SUBINVENTORY,
     SUBINVENTORY,
     LOCATOR_ID,
     CATEGORY_ID,
     EXPECTED_RECEIPT_DATE,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_RATE,
     CURRENCY_CONVERSION_DATE,
     CURRENCY_CONVERSION_TYPE,
     USSGL_TRANSACTION_CODE,
     SHIP_TO_LOCATION_ID,
     REQUISITION_LINE_ID,
     REQ_DISTRIBUTION_ID,
     ITEM_DESCRIPTION,
     SHIPPED_DATE,
     ROUTING_HEADER_ID,
     REASON_ID,
     MOVEMENT_ID,
     TRANSFER_PERCENTAGE,
     CHARGE_ACCOUNT_ID,
     DOCUMENT_SHIPMENT_LINE_NUM ,
     COMMENTS
     )
   VALUES
    (
     l_transaction_id,                         /* interface_transaction_id*/
     l_group_id,                               /* group_id*/
     l_source_code,                            /* interface_source_code */
     l_detail_rec.source_line_id,              /* interface_source_line_id */
     sysdate,                                  /* last_update_date */
     FND_GLOBAL.user_id,                       /* last_updated_by */
     sysdate,                                  /* creation_date */
     FND_GLOBAL.user_id,                       /* created_by */
     l_detail_rec.inventory_item_id,           /* item_id */
     l_detail_rec.revision,                    /* item_revision */
     l_detail_rec.organization_id,             /* from_organization_id */
     l_transfer_organization,                  /* to_organization_id */
     l_transfer_organization,                  /* intransit_owning_org_id */
     l_del_ship_qty,                           /* quantity */
     l_unit_of_measure,                        /* unit_of_measure */
     l_del_ship_qty_uom,                       /* uom_code */
     l_detail_rec.shipped_quantity2,           /* secondary_quantity */
     l_detail_rec.requested_quantity_uom2,     /* secondary_uom_code */
     l_secondary_unit_of_measure,              /* secondary_unit_of_measure */
     null,                                     /* primary qty*/
     null,                                     /* primary uom*/
     'SHIP',                                   /* transaction_type ?*/
     l_trip_stop_rec.actual_departure_date,    /* transaction_date */
     l_delivery_id,                            /* shipment_num */
     null,                                     /* freight_carrier_code */
     null,                                     /* transfer_cost */
     null,                                     /* transportation_cost */
     null,                                     /* transportation_account_id */
     null,                                     /* number_of_containers */
     l_waybill,                                /* waybill_airbill_number*/
     null,                                     /* inventory_transaction_id */
     l_po_info.destination_type_code,          /* destination_type_code */
     decode(l_trx_action_id,1, 'DELIVER', 2,'DELIVER',3,'DELIVER','SHIP'), /*auto_transact_code*/
     'INTERNAL ORDER',                         /* Receipt_source_code*/
     'REQ',                                    /* source_document_code*/
     'RUNNING',                                /* processing_status_code */
     'PENDING',                                /* transaction_status_code */
     'ONLINE',                                 /* processing_code_mode */
     l_detail_rec.subinventory,                /* from_subinventory*/
     decode(l_trx_action_id, 3, l_subinventory,l_transfer_subinventory),                /* subinventory*/
     decode(l_trx_action_id, 3, l_locator_id, l_detail_rec.locator_id) ,                /* locator_id*/
     null,                                     /* category_id*/
     l_ultimate_dropoff_date,                  /* expected_receipt_date */
     null,                                     /* currency_code */
     null,                                     /* currency_convertion_rate */
     SYSDATE,                                  /* currency_convertion_date */
     null,                                     /* currency_convertion_type */
     null,                                     /* ussgl_transaction_code */
     l_ship_to_location_id,                    /* ship_to_location_id */
     l_requisition_line_id,                    /* requisition_line_id */
     l_req_distribution_id,                    /* req_distribution_id */
     l_item_desc,                              /* item_description */
     l_trip_stop_rec.actual_departure_date,    /* shipped_date */
     null,                                     /* routing_header_id */
     null,                                     /* reason_id */
     null,                                     /* movement_id */
     null,                                     /* transfer_percentage */
     l_charge_account_id,                      /* charge_account_id */
     l_detail_rec.delivery_detail_id ,          /*DOCUMENT_SHIPMENT_LINE_NUM*/
     'OPM WDD:' || to_char(l_detail_rec.delivery_detail_id )
     );
     --decode(l_trx_action_id,3,l_transfer_organization,l_detail_rec.organization_id), /* from_organization_id */
     --decode(l_trx_action_id,3,l_detail_rec.organization_id,l_transfer_organization), /* to_organization_id */
     GMI_reservation_Util.PrintLn(
       'in create_rcv_transaction: for inserting in RCV_TRANSACTIONS_INTERFACE, sqlcode is '||SQLCODE||'.');
  End if;
EXCEPTION
    WHEN OTHERS THEN
    GMI_reservation_Util.PrintLn(
       'in create_rcv_transaction: for inserting in RCV_TRANSACTIONS_INTERFACE, sqlcode is '||SQLCODE||'.');

END  create_rcv_transaction;

/* this procedure process_OPM_orders is created for internal orders only *
 * Please see bug 1788352 */


PROCEDURE process_OPM_orders(p_stop_id           IN  NUMBER
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ) IS
l_completion_status     VARCHAR2(30) := 'NORMAL';

l_delivery_id number;
request_id number;
l_error_code number;
l_msg_count number;
l_msg_data varchar2(3000);
l_error_text varchar2(2000);
l_transaction_header_id number ;
l_return_status varchar2(30);
l_if_internal   number ;

CURSOR pickup_deliveries IS
SELECT dg.delivery_id , st.transaction_header_id
     FROM   wsh_delivery_legs dg,
         wsh_new_deliveries dl,
         wsh_trip_stops st
     WHERE     st.stop_id = dg.pick_up_stop_id AND
         st.stop_id = p_stop_id AND
         st.stop_location_id = dl.initial_pickup_location_id AND
         dg.delivery_id = dl.delivery_id  ;

-- Bug 3764091 Added NOT EXISTS to the cursor below so that wdd which is already synchronized to PO
-- side is not inserted again in rcv_transactions_interface.
CURSOR c_detail_in_delivery is
   SELECT   dd.delivery_detail_id, dd.source_line_id
   FROM     wsh_delivery_details dd, wsh_delivery_assignments da
   WHERE    dd.delivery_detail_id             = da.delivery_detail_id
   AND      da.delivery_id                    = l_delivery_id
   AND      NVL(dd.inv_interfaced_flag , 'N') = 'Y'
   AND      dd.container_flag                 = 'N'
   AND      dd.source_code                    = 'OE'
   AND  NOT EXISTS(select 1
                   from   rcv_shipment_lines rsl, oe_order_lines_all oel
                   where  oel.line_id             = dd.source_line_id
                   and    rsl.requisition_line_id = oel.source_document_line_id
                   and    rsl.comments            = 'OPM WDD:'||to_char(dd.delivery_detail_id));

l_detail_in_delivery c_detail_in_delivery%ROWTYPE;

CURSOR c_order_line_info(c_order_line_id number) is
SELECT source_document_type_id
     , source_document_id
     , source_document_line_id
     , ship_from_org_id
from     oe_order_lines_all
where  line_id = c_order_line_id;

l_order_line_info c_order_line_info%ROWTYPE;
rc                         NUMBER := NULL;
l_group_id                 NUMBER := 0;

CURSOR c_details_for_interface(p_del_detail_id number)  is
SELECT * from wsh_delivery_details
where delivery_detail_id = p_del_detail_id
and container_flag = 'N';
l_detail_rec c_details_for_interface%ROWTYPE;

CURSOR c_trip_stop (c_trip_stop_id NUMBER ) IS
   SELECT * FROM WSH_TRIP_STOPS
   WHERE STOP_ID = c_trip_stop_id;
l_trip_stop_rec c_trip_stop%ROWTYPE;

 BEGIN

   l_if_internal := 0 ;


   GMI_RESERVATION_UTIL.Println ('in GMI process_OPM_orders for stop '||p_stop_id );

   FOR del IN pickup_deliveries LOOP
     l_delivery_id := del.delivery_id;
     GMI_RESERVATION_UTIL.Println ('in GMI found delivery'  ||   l_delivery_id);
     OPEN c_detail_in_delivery ;
     LOOP
       FETCH c_detail_in_delivery into l_detail_in_delivery;
       EXIT WHEN c_detail_in_delivery%NOTFOUND;

         OPEN c_order_line_info(l_detail_in_delivery.source_line_id);
         FETCH c_order_line_info into l_order_line_info;
         if (c_order_line_info%NOTFOUND) THEN
            CLOSE c_order_line_info;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            GMI_RESERVATION_UTIL.Println('Warning, Sales order not valid');
            CLOSE c_detail_in_delivery;  /* B2886561 close this cursor before return */
            return;
         END if;
         CLOSE c_order_line_info;

         IF (l_order_line_info.source_document_type_id = 10
             and INV_GMI_RSV_BRANCH.Process_Branch(l_order_line_info.ship_from_org_id) )
         THEN /* internal order */
            l_if_internal := 1;  -- internal order

            IF nvl(l_group_id,0) = 0 THEN
               /* only do this once */
               select RCV_INTERFACE_GROUPS_S.NEXTVAL INTO l_group_id FROM DUAL;
            END IF;
            OPEN c_details_for_interface(l_detail_in_delivery.delivery_detail_id);
            FETCH c_details_for_interface into l_detail_rec;
            if c_details_for_interface%NOTFOUND then
               CLOSE c_details_for_interface;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               WSH_UTIL_CORE.Println('Warning, Delivery Detail ' ||l_detail_in_delivery.delivery_detail_id ||' not found');
               IF c_detail_in_delivery%ISOPEN THEN  /* B2886561 close this cursor before return */
                  CLOSE c_detail_in_delivery;
               END IF;
               return;
            end if;
            CLOSE c_details_for_interface;

            OPEN c_trip_stop(p_stop_id);
            FETCH c_trip_stop into l_trip_stop_rec;
              if c_trip_stop%NOTFOUND then
               CLOSE c_trip_stop;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               WSH_UTIL_CORE.Println('Warning, Trip Stop '|| p_stop_id ||' not found');
               IF c_detail_in_delivery%ISOPEN THEN  /* B2886561 close this cursor before return */
                  CLOSE c_detail_in_delivery;
               END IF;
               return;
              end if;
            oe_debug_pub.add('Found Trip Stop '|| p_stop_id);
            CLOSE c_trip_stop;

            GMI_RESERVATION_UTIL.Println ('found internal order line in this delivery  '  ||   l_delivery_id);
            -- internal orders, insert into rcv_transactions_interface
            Oe_Debug_Pub.Add('This line is part of an internal order');
            GMI_SHIPPING_UTIL.create_rcv_transaction
                ( p_shipping_line   => l_detail_rec
                , p_trip_stop_rec   => l_trip_stop_rec
                , p_group_id        => l_group_id
                , x_return_status    => l_return_status
                , x_msg_count        => l_msg_count
                , x_msg_data         => l_msg_data
                );
            oe_debug_pub.add('Finished calling GMI_Shipping_Util.create_rcv_transaction');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                WSH_UTIL_CORE.println('Warning ...');
                WSH_UTIL_CORE.println('Failed GMI_Shipping_Util.create_rcv_transaction for delivery ID '
                      || l_detail_rec.DELIVERY_DETAIL_ID );
              x_return_status := l_return_status;
            END IF;

         END IF;
      END LOOP;
    CLOSE c_detail_in_delivery;
   END LOOP;


   IF ( l_if_internal = 1 ) THEN
      rc := fnd_request.submit_request(
          'PO',
          'RVCTP',
          null,
          null,
          false,
          'IMMEDIATE',
          l_group_id,
          fnd_global.local_chr(0),
          NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL);
   END IF;

END process_OPM_orders;



PROCEDURE MATCH_LINES IS
--BEGIN BUG#2736088 V. Ajay Kumar
--Removed the reference to "apps".
CURSOR c_get_lines
IS
SELECT
  mp1.organization_code ORG, mp2.organization_code WHSE
, soh.order_number SO_NUMBER
, sol.line_number LINE_NO
, sol.line_id LINE_ID
, sol.ordered_quantity ORDER_QTY
, wdd.inventory_item_id ITEM_ID
, wdd.organization_id SHIP_ORG
, wdd.delivery_detail_id  SHIP_ID
, wdd.SHIPPED_QUANTITY  SHIP_QTY
, wdd.locator_id LOCATOR_ID
, wdd.lot_number
, wdd.sublot_number
, wdd.released_status SHIP_STATUS
FROM wsh_delivery_details wdd
, oe_order_headers_all soh
, oe_order_lines_all sol
, mtl_parameters mp1
, mtl_parameters mp2
WHERE wdd.source_line_id  = sol.line_id
AND mp1.organization_id = sol.org_id
AND mp2.organization_id = sol.ship_from_org_id
AND sol.flow_status_code = 'AWAITING_SHIPPING'
AND wdd.released_status IN ('C','Y')
AND soh.header_id = sol.header_id
AND NVL(wdd.oe_interfaced_flag,'N') <> 'Y'
-- AND NVL(wdd.inv_interfaced_flag,'N') = 'N'
-- AND NVL(wts.PENDING_INTERFACE_FLAG,'N') <> 'Y'
ORDER BY 1, 2 ,3,4;
--END BUG#2736088


CURSOR get_opm_transaction_c ( p_line     in  number,
                               p_item_id  in  number,
                               p_lot_id   in number,
                               p_location in varchar
                             )
IS SELECT trans_id, line_detail_id
    FROM   ic_tran_pnd
    WHERE  doc_type='OMSO'
    AND    line_id = p_line
    AND    item_id = p_item_id
    AND    lot_id  = p_lot_id
    AND    location = p_location
    AND    staged_ind = 1
    AND    line_detail_id is null
    AND    delete_mark = 0;

CURSOR c_get_item_info ( pitem_id in number, porg_id in number)
IS
SELECT iim.item_id
FROM   ic_item_mst iim,
       mtl_system_items msi
WHERE  msi.inventory_item_id = pitem_id
AND    msi.organization_id   = porg_id
AND    msi.segment1 = iim.item_no;

l_default_location   VARCHAR2(30);
/* these lines are pick released but yet to be staged, therefore all the inv info in wdd
   does not exist yet*/

--BEGIN BUG#2736088 V. Ajay Kumar
--Removed the reference to "apps".
Cursor get_unstaged_lines IS
SELECT
  mp1.organization_code ORG, mp2.organization_code WHSE
, soh.order_number SO_NUMBER
, sol.line_number LINE_NO
, sol.line_id LINE_ID
, sol.ordered_quantity ORDER_QTY
, wdd.inventory_item_id ITEM_ID
, wdd.organization_id SHIP_ORG
, wdd.delivery_detail_id  SHIP_ID
, wdd.SHIPPED_QUANTITY  SHIP_QTY
FROM ic_txn_request_lines mo
, wsh_delivery_details wdd
, oe_order_headers_all soh
, oe_order_lines_all sol
, mtl_parameters mp1
, mtl_parameters mp2
 Where soh.header_id = sol.header_id
   and sol.line_id = mo.txn_source_line_id
   AND sol.flow_status_code = 'AWAITING_SHIPPING'
   AND mp1.organization_id = sol.org_id
   AND mp2.organization_id = sol.ship_from_org_id
   and mo.line_status in (3,7)
   and mo.line_id = wdd.move_order_line_id
   and wdd.released_status = 'S'
;
--END BUG#2736088
Cursor count_trans_unstaged( p_line_id IN NUMBER
                         , l_default_location IN VARCHAR2)
IS
SELECT
  count(*)
From ic_tran_pnd
Where line_id = p_line_id
 And doc_type = 'OMSO'
 And line_detail_id is null
 And delete_mark = 0
 And staged_ind = 0
 And completed_ind = 0
 And (lot_id <> 0 or location <> l_default_location )  -- NON default
;

--BEGIN BUG#2736088 V. Ajay Kumar
--Removed the reference to "apps".
Cursor count_unstaged_wdd_for_mo (p_line_id IN NUMBER)
IS
Select count(*)
FROM ic_txn_request_lines mo
, wsh_delivery_details wdd
 Where mo.txn_source_line_id = p_line_id
   and mo.line_status in (3,7)
   and mo.line_id = wdd.move_order_line_id
   and mo.txn_source_line_id = wdd.source_line_id
   and wdd.released_status = 'S'
;

l_init_msg_list              VARCHAR2(255) := FND_API.G_TRUE;
--END BUG#2736088
l_return_status              VARCHAR2(1);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_required_lines             NUMBER;
l_total_lines                NUMBER;
l_qty_found                  NUMBER;
l_updates                    NUMBER;
l_old_trans                  NUMBER;
l_new_trans                  NUMBER;
l_not_found                  NUMBER;
l_short_qty                  NUMBER;
l_xtra_qty                   NUMBER;
v_outputfile                 UTL_FILE.FILE_TYPE;
l_db_name                    VARCHAR2(10);
l_old_response               VARCHAR2(10);
l_location                   VARCHAR2(10);
l_trans_id                   NUMBER;
l_item_id                    NUMBER;
l_line_detail_id            NUMBER;
l_lot_id                    NUMBER;
NON_OPM_WHSE                EXCEPTION;
l_non_opm_whse              NUMBER;
l_trans_updated             NUMBER;
l_detail_exists             NUMBER;
l_trans_notfound            NUMBER;
l_time                      VARCHAR2(10);
l_trans_count            NUMBER;
l_wdd_count            NUMBER;
/*
l_DIR   Varchar2(255)     := nvl(fnd_profile.value
                             ('OE_DEBUG_LOG_DIRECTORY'), '/tmp');
*/

/*
If /tmp OR the dir specified in the profile itself is not one of the values for database parameter 'utl_file_dir' this will fail . Added the following cursor toget the default directory NC - 11/26/01
*/

CURSOR get_log_file_location IS
SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
FROM v$parameter
WHERE name = 'utl_file_dir';

l_FILE  Varchar2(255)     := NULL;
l_DIR   Varchar2(255)     := NULL;
CANNOT_OPEN  EXCEPTION;


BEGIN

  SELECT TO_CHAR(SYSDATE,'SSSSS') INTO l_time
  FROM DUAL;
  l_FILE := 'MATCHLINES'||l_time;
  --DBMS_OUTPut.disable;
  --  DBMS_OUTPut.enable(1000000);

  /*  Getting the log file location from 'utl_file_dir' parameter itself
      is not fool proof , for it could have values like '*' . But in this
      case, FOPEN would fail and OTHERS exception should catch it.
  */

  OPEN   get_log_file_location;
  FETCH  get_log_file_location into l_DIR;
  CLOSE  get_log_file_location;

  v_outputfile := UTL_FILE.FOPEN(l_DIR,l_FILE,'W');

  /* NC - added 11/26/01 . Say fopen did not fail,there still could be
     a problem with the file handler.
  */
  IF NOT UTL_FILE.IS_OPEN(v_outputfile) THEN
     raise CANNOT_OPEN;
  END IF;

  select name into l_db_name
  from v$database;

  UTL_FILE.putf(v_outputfile,'\n***************************************\n');
  UTL_FILE.putf(v_outputfile,'******* DATABASE  - %s \n',l_db_name);
  UTL_FILE.putf(v_outputfile,'******* RUN DATE  - %s \n',TO_CHAR(SYSDATE,'DD-MM-YY HH24:MI:SS'));
  UTL_FILE.putf(v_outputfile,'******************************************\n');

  UTL_FILE.putf(v_outputfile,'\n INITIALIZE MSG STACK\n');
  --BEGIN BUG#2736088 V. Ajay Kumar
  --Removed the reference to "apps"
  FND_MSG_PUB.INITIALIZE;
  --END BUG#2736088
  l_required_lines :=0;
  l_non_opm_whse   :=0;
  l_trans_updated  :=0;
  l_trans_notfound :=0;
  l_detail_exists  :=0;

  FOR lines IN c_get_lines LOOP
    l_required_lines := l_required_lines + 1;
    IF l_old_response <> lines.org THEN
      UTL_FILE.putf(v_outputfile,'\n ****** START RESPONSE ******\n');
    END IF;

    UTL_FILE.putf(v_outputfile,'\n RESP           => %s',lines.org);
    UTL_FILE.putf(v_outputfile,'\n WHSE           => %s',lines.WHSE);
    UTL_FILE.putf(v_outputfile,'\n ORDER NO       => %s',lines.SO_NUMBER);
    UTL_FILE.putf(v_outputfile,'\n LINE NO        => %s',lines.LINE_NO);
    UTL_FILE.putf(v_outputfile,'\n ORDER QTY      => %s',lines.ORDER_QTY);
    UTL_FILE.putf(v_outputfile,'\n SOURCE LINE ID => %s\n',lines.LINE_ID);

    BEGIN
     IF ( NOT INV_GMI_RSV_BRANCH.Process_Branch
              (p_organization_id => lines.ship_org )
          ) THEN
         RAISE NON_OPM_WHSE;
     ELSE
         -- Find Matching Transactions
         OPEN c_get_item_info( lines.item_id, lines.ship_org);
          FETCH c_get_item_info INTO l_item_id;
          IF c_get_item_info%NOTFOUND THEN
           UTL_FILE.putf(v_outputfile,'\n ITEM DETAILS NOT FOUND\n');
           RAISE NO_DATA_FOUND;
          END IF;
         CLOSE c_get_item_info;
         IF lines.locator_id IS NULL
            THEN
            l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
         ELSE
            SELECT location INTO l_location
            FROM   ic_loct_mst
            WHERE  inventory_location_id = lines.locator_id;
         END IF;
         IF lines.lot_number IS NULL
             THEN
             l_lot_id := 0;
         ELSIF lines.sublot_number IS NULL
              THEN
              SELECT lot_id INTO l_lot_id
              FROM   ic_lots_mst
              WHERE  item_id = l_item_id
              AND    lot_no = lines.lot_number
              AND    sublot_no IS NULL ;
         ELSE
              SELECT lot_id INTO l_lot_id
              FROM   ic_lots_mst
              WHERE  item_id = l_item_id
              AND    lot_no = lines.lot_number
              AND    sublot_no = lines.sublot_number;
         END IF;
         OPEN get_opm_transaction_c(lines.line_id,
                                    l_item_id, l_lot_id,l_location);
           LOOP
           FETCH get_opm_transaction_c INTO l_trans_id, l_line_detail_id;
           IF get_opm_transaction_c%NOTFOUND THEN
              UTL_FILE.putf(v_outputfile,'\n ***** ERROR ******');
              UTL_FILE.putf(v_outputfile,'\n OPM TRANSACTION NOT FOUND ');
              UTL_FILE.putf(v_outputfile,'\n LINE_ID %s',lines.line_id);
              UTL_FILE.putf(v_outputfile,'\n ITEM_ID %s',l_item_id);
              UTL_FILE.putf(v_outputfile,'\n LOT_ID  %s',l_lot_id);
              UTL_FILE.putf(v_outputfile,'\n LOCAT   %s',l_location);
              UTL_FILE.putf(v_outputfile,'\n WHSE   %s', lines.SHIP_ORG);
              UTL_FILE.putf(v_outputfile,'\n ***** ERROR ******\n');
              l_trans_notfound := l_trans_notfound +1;
              EXIT;
           ELSE
             UTL_FILE.putf(v_outputfile,' MATCHING TRANS = %s',l_trans_id);
             UTL_FILE.putf(v_outputfile,',LINE DETAIL ID = %s\n',l_line_detail_id);
             -- Check if Line detail id NOT populated
             IF l_line_detail_id is NULL THEN
                -- Okay Now Perform Updates
                UPDATE IC_TRAN_PND
                SET LINE_DETAIL_ID = lines.SHIP_ID
                WHERE TRANS_ID = l_trans_id;
                l_trans_updated := l_trans_updated +1;
             ELSE
                -- Line Detail Id Already Populated.
                l_detail_exists := l_detail_exists +1;
             END IF;
           END IF;
           EXIT; /*  Exit after First Select */
         END LOOP;
         CLOSE get_opm_transaction_c;
     END IF; /* For OPM WHSE CHECK */

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
                UTL_FILE.putf(v_outputfile,'\n NO DATA FOUND\n');
                CLOSE c_get_item_info;
        WHEN NON_OPM_WHSE THEN
                UTL_FILE.putf(v_outputfile,'\n NON OPM SHIPMENT \n');
                l_non_opm_whse := l_non_opm_whse + 1;
    END; /* inner begin */
    l_old_response := lines.org;
  END LOOP; /* FOR ALL ORDERS */

  /* find out the offset lines for unstaged */
  l_default_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  FOR lines IN get_unstaged_lines LOOP
    l_required_lines := l_required_lines + 1;
    IF l_old_response <> lines.org THEN
      UTL_FILE.putf(v_outputfile,'\n ****** unstaged shipping lines ******\n');
    END IF;
    BEGIN
     IF ( NOT INV_GMI_RSV_BRANCH.Process_Branch
                 (p_organization_id => lines.ship_org )
             ) THEN
         RAISE NON_OPM_WHSE;
     ELSE
        Open count_trans_unstaged( lines.line_id, l_default_location);
        Fetch count_trans_unstaged Into l_trans_count;
        Close count_trans_unstaged;
        If l_trans_count <> 0 THEN
           UTL_FILE.putf(v_outputfile,'\n RESP           => %s',lines.org);
           UTL_FILE.putf(v_outputfile,'\n WHSE           => %s',lines.WHSE);
           UTL_FILE.putf(v_outputfile,'\n ORDER NO       => %s',lines.SO_NUMBER);
           UTL_FILE.putf(v_outputfile,'\n LINE NO        => %s',lines.LINE_NO);
           UTL_FILE.putf(v_outputfile,'\n ORDER QTY      => %s',lines.ORDER_QTY);
           UTL_FILE.putf(v_outputfile,'\n SOURCE LINE ID => %s\n',lines.LINE_ID);
           Open count_unstaged_wdd_for_mo(lines.line_id);
           Fetch count_unstaged_wdd_for_mo Into l_wdd_count;
           Close count_unstaged_wdd_for_mo;
           IF l_wdd_count = 1 THEN
             /* get the dd_id for this wdd */

             --BEGIN BUG#2736088 V. Ajay Kumar
             --Removed the reference to "apps".

             Select wdd.delivery_detail_id
             Into l_line_detail_id
             FROM ic_txn_request_lines mo
             , wsh_delivery_details wdd
              Where mo.txn_source_line_id = lines.line_id
                and mo.line_status in (3,7)
                and mo.line_id = wdd.move_order_line_id
                and mo.txn_source_line_id = wdd.source_line_id
                and wdd.released_status = 'S';
             --END BUG#2736088

             /* find out all the trans and update them to the wdd dd_id */
             Update ic_tran_pnd
             Set line_detail_id = l_line_detail_id
             Where line_id = lines.line_id
              And doc_type = 'OMSO'
              And line_detail_id is null
              And delete_mark = 0
              And staged_ind = 0
              And completed_ind = 0
              And (lot_id <> 0 or location <> l_default_location )  -- NON default
              ;
           ELSIF l_wdd_count > 1 THEN
              UTL_FILE.putf(v_outputfile,'\n ***********Order Number '|| lines.so_number||
                        'needs manual attention \n');
           END IF;
        END IF;
     END IF;
     EXCEPTION
           WHEN NO_DATA_FOUND THEN
                   UTL_FILE.putf(v_outputfile,'\n NO DATA FOUND\n');
                   CLOSE c_get_item_info;
           WHEN NON_OPM_WHSE THEN
                   UTL_FILE.putf(v_outputfile,'\n NON OPM SHIPMENT \n');
                   l_non_opm_whse := l_non_opm_whse + 1;
    END; /* inner begin */
    l_old_response := lines.org;
  END LOOP; /* FOR ALL ORDERS */

  UTL_FILE.putf(v_outputfile,'\n ************ SUMMARY   *********** \n');
  UTL_FILE.putf(v_outputfile,'\n TOTAL LINES PROCESSED   => %s\n',l_required_lines);
  UTL_FILE.putf(v_outputfile,'\n TOTAL OPM   PROCESSED   => %s\n',l_required_lines - l_non_opm_whse);
  UTL_FILE.putf(v_outputfile,'\n TOTAL TRANS NOT FOUND   => %s\n',l_trans_notfound);
  UTL_FILE.putf(v_outputfile,'\n TOTAL TRANS UPDATED     => %s\n',l_trans_updated);
  UTL_FILE.putf(v_outputfile,'\n TOTAL LINE DETAIL TRANS => %s\n',l_detail_exists);
  UTL_FILE.putf(v_outputfile,'\n ********************************* \n');
  UTL_FILE.FCLOSE(v_outputfile);

EXCEPTION

 WHEN CANNOT_OPEN THEN
     --DBMS_OUTPUT.enable(10000);
     --dbms_output.put_line('Can not open utl_file');
     null;
 WHEN OTHERS THEN
     --DBMS_OUTPUT.enable(10000);
     --dbms_output.put_line('In others exception : procedure match_lines');
     null;
END MATCH_LINES;

/* new procedure split_opm_trans
  This is a generic routine called by split_records in shipping then
  Split_Detail_INT
  if the line is staged, it would call update_opm_transactions
  if not it would call split_trans
*/
/* NOTE : NC - 11/2/01  commented the first parameter and redeclared this
  record type in the spec(GMIUSHPS.pls). This needs to be uncommented
  and the record type needs to be deleted from the spec when OM changes
  are incorporated */

PROCEDURE split_opm_trans
   ( p_old_delivery_detail_id  IN  NUMBER,
     p_released_status         IN  VARCHAR2,
     p_lot_number              IN  VARCHAR2,
     p_sublot_number           IN  VARCHAR2,
     p_organization_id         IN  NUMBER,
     p_inventory_item_id       IN  NUMBER,
     p_old_source_line_id      IN  NUMBER,
     p_locator_id              IN  NUMBER,
     p_old_req_quantity        IN  NUMBER,
     p_old_req_quantity2       IN  NUMBER,
     p_new_delivery_detail_id  IN  NUMBER,
     p_qty_to_split            IN  NUMBER,
     p_qty2_to_split           IN  NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2)
IS
  l_new_delivery_detail_id NUMBER;
BEGIN
  SAVEPOINT split_txn;
  l_new_delivery_detail_id := p_new_delivery_detail_id;
  IF ( p_released_status = 'Y' )
  THEN
     oe_debug_pub.add('Calling update_opm_transaction.',2);
     GMI_RESERVATION_UTIL.println('splitting the OPM inv, update_opm_transaction', 'opm.log');

     GMI_SHIPPING_UTIL.update_opm_transaction(
                            p_old_delivery_detail_id =>   p_old_delivery_detail_id,
                            p_lot_number             =>   p_lot_number,
                            p_sublot_number          =>   p_sublot_number,
                            p_organization_id        =>   p_organization_id,
                            p_inventory_item_id      =>   p_inventory_item_id,
                            p_old_source_line_id     =>   p_old_source_line_id,
                            p_locator_id             =>   p_locator_id,
                            p_new_delivery_detail_id =>   l_new_delivery_detail_id,
                            p_old_req_quantity       =>   p_old_req_quantity,
                            p_old_req_quantity2      =>   p_old_req_quantity2,
                            p_req_quantity           =>   p_qty_to_split,
                            p_req_quantity2          =>   NVL(p_qty2_to_split,0),
                            x_return_status          =>   x_return_status,
                            x_msg_count              =>   x_msg_count,
                            x_msg_data               =>   x_msg_data );
     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     oe_debug_pub.add('Done calling update_opm_transaction',2);
  ELSE /* not staged */
     GMI_SHIPPING_UTIL.split_trans
         ( p_old_delivery_detail_id     => p_old_delivery_detail_id,
           p_new_delivery_detail_id     => l_new_delivery_detail_id,
           p_old_source_line_id         => p_old_source_line_id,
           p_new_source_line_id         => p_old_source_line_id,
           p_qty_to_split               => p_qty_to_split,
           p_qty2_to_split              => NVL(p_qty2_to_split,0),
           x_return_status              => x_return_status,
           x_msg_count                  => x_msg_count,
           x_msg_data                   => x_msg_data
           );
     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     oe_debug_pub.add('Done calling split_trans',2);

  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    rollback to  update_txn;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE NO_DATA_FOUND;
    GMI_RESERVATION_UTIL.Println('Raised When No Data Found in split_opm_trans');

    WHEN OTHERS THEN
    rollback to  split_txn;
    x_return_status := FND_API.G_RET_STS_ERROR;
    GMI_RESERVATION_UTIL.Println('Raised When Others in split_opm_trans');
END split_opm_trans;

/* this procedure fulfills the trans for the old dd and updates the rest of
  trans for the new dd
  in the process, split the trans if neccessary
*/
PROCEDURE split_trans
   ( p_old_delivery_detail_id  IN  NUMBER,
     p_new_delivery_detail_id  IN  NUMBER,
     p_old_source_line_id      IN  NUMBER,
     p_new_source_line_id      IN  NUMBER,
     p_qty_to_split            IN  NUMBER,
     p_qty2_to_split           IN  NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2)
IS
  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_old_transaction_row    ic_tran_pnd%ROWTYPE ;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_trans_id               ic_tran_pnd.trans_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_line_detail_id         wsh_delivery_details.delivery_detail_id%TYPE;
  l_new_delivery_detail_id NUMBER;
  l_source_line_id         NUMBER;
  l_fulfilled_qty          NUMBER;
  l_qty_to_fulfil          NUMBER;
  l_qty2_to_fulfil         NUMBER;
  l_orig_qty               NUMBER;
  l_orig_qty2              NUMBER;
  l_lot_ctl                NUMBER;
  l_loct_ctl               NUMBER;
  l_whse_ctl               NUMBER;
  l_doc_id                 NUMBER;
  l_inventory_item_id      NUMBER;
  l_organization_id        NUMBER;
  l_whse_code              VARCHAR2(5);
  l_released_status        VARCHAR2(5);
  l_noninv_ind             NUMBER; /* Bug 2901317 */
  l_orig_txn_exists        NUMBER; /* Bug 2985470 */


  cursor c_reservations IS
    SELECT trans_id, doc_id
      FROM ic_tran_pnd
     WHERE line_id = p_old_source_line_id
       AND line_detail_id = p_old_delivery_detail_id
       AND delete_mark = 0
       AND doc_type = 'OMSO'
       AND trans_qty <> 0
     ORDER BY staged_ind desc
             ,trans_qty desc; /* the smaller qty is at the top, keep in mind it is neg */
                              /* or should consider the alloc rules */
  CURSOR get_original_qty IS
  Select requested_quantity
       , requested_quantity2
       , released_status
       , source_line_id
       , inventory_item_id
       , organization_id
  From wsh_delivery_details
  Where delivery_detail_id = p_old_delivery_detail_id;

  Cursor Get_item_info IS
    Select ic.item_id
         , ic.lot_ctl
         , ic.loct_ctl
         , ic.noninv_ind  /* Bug 2901317 */
    From ic_item_mst ic
       , mtl_system_items mtl
    Where ic.item_no = mtl.segment1
      and mtl.inventory_item_id = l_inventory_item_id
      and mtl.organization_id = l_organization_id;

  Cursor nonctl_reservation IS
     SELECT trans_id
       FROM ic_tran_pnd
      WHERE line_id        = p_old_source_line_id
        AND line_detail_id = p_old_delivery_detail_id
        AND delete_mark = 0
        AND doc_type = 'OMSO'
        AND staged_ind = 1
        AND trans_qty <> 0;

BEGIN
    GMI_RESERVATION_UTIL.Println(' in split_trans');
    GMI_RESERVATION_UTIL.Println(' p_old_delivery_detail_id '||p_old_delivery_detail_id);
    GMI_RESERVATION_UTIL.Println(' p_new_delivery_detail_id '||p_new_delivery_detail_id);
    GMI_RESERVATION_UTIL.Println(' p_old_source_line_id '||p_old_source_line_id);
    GMI_RESERVATION_UTIL.Println(' p_new_source_line_id '||p_new_source_line_id);
    l_fulfilled_qty := 0;

    Open get_original_qty;
    Fetch get_original_qty
    Into l_orig_qty
       , l_orig_qty2
       , l_released_status
       , l_source_line_id
       , l_inventory_item_id
       , l_organization_id
       ;
    Close get_original_qty;

    /* get lot_ctl and loct_ctl */
    Open get_item_info;
    Fetch get_item_info
    Into l_item_id
       , l_lot_ctl
       , l_loct_ctl
       , l_noninv_ind /* Bug 2901317 */
       ;
    Close get_item_info;

    /* get whse loct_ctl */
    Select loct_ctl
    Into l_whse_ctl
    From ic_whse_mst
    Where mtl_organization_id = l_organization_id;

    l_qty_to_fulfil  := l_orig_qty - p_qty_to_split;
    l_qty2_to_fulfil := l_orig_qty2 - p_qty2_to_split;

    GMI_RESERVATION_UTIL.Println('in split_trans');
    GMI_RESERVATION_UTIL.Println('in split_trans, relased_status '||l_released_status);
    GMI_RESERVATION_UTIL.Println('in split_trans, qty to split'||p_qty_to_split);
    GMI_RESERVATION_UTIL.Println('in split_trans, qty2 to split'||p_qty2_to_split);
    GMI_RESERVATION_UTIL.Println('in split_trans, qty to fulfil'||l_qty_to_fulfil);
    IF l_released_status = 'B' THEN /* back orders*/
      IF (l_noninv_ind = 1 OR (l_lot_ctl = 0 AND l_loct_ctl * l_whse_ctl = 0)) THEN
      --  null;
      /* Bug2901317 */
      OPEN nonctl_reservation;
      FETCH nonctl_reservation INTO l_trans_id;
      CLOSE nonctl_reservation;
      /* End Bug2901317 */
      ELSE
         GMI_RESERVATION_UTIL.Println('in split_trans, updating the trans for new line_id');
         OPEN c_reservations;
         LOOP
            FETCH c_reservations INTO l_trans_id, l_doc_id;
            EXIT WHEN c_reservations%NOTFOUND;
            Update ic_tran_pnd
            Set line_id = p_new_source_line_id
            Where trans_id = l_trans_id;
            GMI_RESERVATION_UTIL.Println('l_trans_id is '||l_trans_id);
         END LOOP;
      END IF;

      /* update the default lot to the new line_id */
      oe_debug_pub.add('Going to update ic_tranPnd with new line_id :'||p_new_source_line_id
           ||' for trans_id '||l_trans_id,2);
      IF l_trans_id > 0 THEN
          Update ic_tran_pnd
          Set line_id = p_new_source_line_id
          Where trans_id = l_trans_id;
      END IF;

      oe_debug_pub.add('Going to find old default lot in split_reservation',2);
      GMI_RESERVATION_UTIL.find_default_lot
       (  x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           x_reservation_id    => l_trans_id,
           p_line_id           => p_old_source_line_id
       );
      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         GMI_RESERVATION_UTIL.println('Error returned by find default lot');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_old_transaction_rec.trans_id := l_trans_id;
      IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
        (l_old_transaction_rec, l_old_transaction_rec )
      THEN
         l_orig_txn_exists := 1; --Bug3149635
         GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| p_old_source_line_id);
         GMI_RESERVATION_UTIL.balance_default_lot
           ( p_ic_default_rec            => l_old_transaction_rec
           , p_opm_item_id               => l_old_transaction_rec.item_id
           , x_return_status             => x_return_status
           , x_msg_count                 => x_msg_count
           , x_msg_data                  => x_msg_data
           );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
           GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
        l_orig_txn_exists := 0;  --Bug3149635
      END IF;

      oe_debug_pub.add('Going to find new default lot in split_reservation',2);

      GMI_RESERVATION_UTIL.find_default_lot
       (  x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           x_reservation_id    => l_trans_id,
           p_line_id           => p_new_source_line_id
       );

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         GMI_RESERVATION_UTIL.println('Error returned by find default lot');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --Bug3149635 (added AND condition below)
      IF (nvl(l_trans_id, 0) = 0  AND l_orig_txn_exists = 1 ) THEN
         l_old_transaction_rec.trans_id := null;
         l_old_transaction_rec.line_id := p_new_source_line_id;
         l_old_transaction_rec.line_detail_id := null;
         -- create a new default
         GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION(
            p_api_version      => 1.0
           ,p_init_msg_list    => FND_API.G_FALSE
           ,p_commit           => FND_API.G_FALSE
           ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
           ,p_tran_rec         => l_old_transaction_rec
           ,x_tran_row         => l_new_transaction_row
           ,x_return_status    => x_return_status
           ,x_msg_count        => x_msg_count
           ,x_msg_data         => x_msg_data);

         GMI_reservation_Util.PrintLn('created new default lot with trans_id '||l_new_transaction_row.trans_id);
         GMI_reservation_Util.PrintLn('created new default lot with line_detail_id '||l_new_transaction_row.line_detail_id);
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
         THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot (Create DefaultLot): Error returned by GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION.');
            FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
            FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_old_transaction_rec.trans_id := l_new_transaction_row.trans_id;
      ELSE
          l_old_transaction_rec.trans_id := l_trans_id;
      END IF;
      IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
        (l_old_transaction_rec, l_old_transaction_rec )
      THEN
         GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| p_new_source_line_id);
         GMI_RESERVATION_UTIL.balance_default_lot
           ( p_ic_default_rec            => l_old_transaction_rec
           , p_opm_item_id               => l_old_transaction_rec.item_id
           , x_return_status             => x_return_status
           , x_msg_count                 => x_msg_count
           , x_msg_data                  => x_msg_data
           );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
           GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
      /* split reservations if neccessary */
      GML_BATCH_OM_RES_PVT.split_reservations
         (  p_old_delivery_detail_id  => p_old_delivery_detail_id
         ,  p_new_delivery_detail_id  => p_new_delivery_detail_id
         ,  p_old_source_line_id      => p_old_source_line_id
         ,  p_new_source_line_id      => p_new_source_line_id
         ,  p_qty_to_split            => p_qty_to_split
         ,  p_qty2_to_split           => p_qty2_to_split
         ,  p_orig_qty                => l_orig_qty
         ,  p_orig_qty2               => l_orig_qty2
         ,  p_action                  => 'B'
         ,  x_return_status           => x_return_status
         ,  x_msg_count               => x_msg_count
         ,  x_msg_data                => x_msg_data
         ) ;
    ELSE
      IF (l_noninv_ind = 1 OR (l_lot_ctl = 0 AND l_loct_ctl * l_whse_ctl = 0)) THEN
        -- null;
        /* Bug2901317 */
        IF (p_new_delivery_detail_id is NOT NULL) AND (p_old_source_line_id is NOT NULL) AND
           (p_new_source_line_id is NOT NULL) AND (p_old_source_line_id  <> p_new_source_line_id) THEN
         Update ic_tran_pnd
            Set line_id  = p_new_source_line_id
          Where line_id  = p_old_source_line_id
            and line_detail_id = p_new_delivery_detail_id;
          GMI_RESERVATION_UTIL.PrintLn('Updated Here');
         END IF;
         /* End Bug2901317 */
      ELSE
         OPEN c_reservations;
         LOOP
            FETCH c_reservations INTO l_trans_id, l_doc_id;
            EXIT WHEN c_reservations%NOTFOUND;

            l_old_transaction_rec.trans_id := l_trans_id;

            IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
              (l_old_transaction_rec, l_old_transaction_rec )
            THEN
               GMI_RESERVATION_UTIL.Println('got trans for trans_id '||l_trans_id);
               GMI_RESERVATION_UTIL.Println('l_qty_to_fulfil '||l_qty_to_fulfil);
               GMI_RESERVATION_UTIL.Println('l_qty2_to_fulfil '||l_qty2_to_fulfil);
               IF abs(l_old_transaction_rec.trans_qty) < l_qty_to_fulfil THEN
                 /* do nothing for the tran */
                 GMI_RESERVATION_UTIL.Println('in split_trans, keep trans the same for trans_id '||l_trans_id);
                 GMI_RESERVATION_UTIL.Println('in split_trans, trans_qty '||l_old_transaction_rec.trans_qty);
                 l_qty_to_fulfil := l_qty_to_fulfil - abs(l_old_transaction_rec.trans_qty);
                 l_qty2_to_fulfil := l_qty2_to_fulfil - abs(l_old_transaction_rec.trans_qty2);
               ELSIF abs(l_old_transaction_rec.trans_qty) > l_qty_to_fulfil
                     AND l_qty_to_fulfil > 0 THEN
                 /* not sure why this */
                 --l_old_transaction_rec.trans_qty := -1 * (l_qty_to_fulfil);
                 --l_old_transaction_rec.trans_qty2 := -1 * (l_qty2_to_fulfil);

                 update ic_tran_pnd
                 set trans_qty = -1 * l_qty_to_fulfil
                   , trans_qty2 = -1 * l_qty2_to_fulfil
                 Where trans_id = l_trans_id;

                 /* create a new trans for the new wdd, and new line_id if applicable */
                 l_new_transaction_rec := l_old_transaction_rec;
                 l_new_transaction_rec.line_detail_id := p_new_delivery_detail_id;
                 l_new_transaction_rec.trans_id := NULL;
                 l_new_transaction_rec.trans_qty := -1 * (abs(l_new_transaction_rec.trans_qty)
                                                   - l_qty_to_fulfil);
                 l_new_transaction_rec.trans_qty2 := -1 * (abs(l_new_transaction_rec.trans_qty2)
                                                   - l_qty2_to_fulfil);
                 l_new_transaction_rec.line_id := p_new_source_line_id;

                 GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
                 ( 1
                 , FND_API.G_FALSE
                 , FND_API.G_FALSE
                 , FND_API.G_VALID_LEVEL_FULL
                 , l_new_transaction_rec
                 , l_new_transaction_row
                 , x_return_status
                 , x_msg_count
                 , x_msg_data
                 );

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                 THEN
                   GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
                 /* qty filfilled*/
                 l_qty_to_fulfil := 0;
                 l_qty2_to_fulfil := 0;
               ELSIF l_qty_to_fulfil <= 0 THEN
                 /* simply update the rest with the new wdd id and new line_id */
                 update ic_tran_pnd
                 set line_detail_id = p_new_delivery_detail_id
                   , line_id = p_new_source_line_id
                 Where trans_id = l_trans_id;
               END IF;
            END IF;
         END LOOP;
         CLOSE c_reservations;
         /* need to balance default lot for both new sol and old sol */
         GMI_RESERVATION_UTIL.find_default_lot
             (  x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                x_reservation_id    => l_trans_id,
                p_line_id           => p_old_source_line_id
             );
         l_orig_txn_exists := 0;   -- B2985470
         IF l_trans_id > 0 THEN  -- if it does not exist, don't bother
            l_old_transaction_rec.trans_id := l_trans_id;
            -- B2985470 old line has txn new should also have one.
            l_orig_txn_exists := 1;  -- B2985470

            IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
              (l_old_transaction_rec, l_old_transaction_rec )
            THEN
               GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| p_old_source_line_id);
               GMI_RESERVATION_UTIL.balance_default_lot
                 ( p_ic_default_rec            => l_old_transaction_rec
                 , p_opm_item_id               => l_old_transaction_rec.item_id
                 , x_return_status             => x_return_status
                 , x_msg_count                 => x_msg_count
                 , x_msg_data                  => x_msg_data
                 );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                 GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
         END IF;
         GMI_RESERVATION_UTIL.find_default_lot
             (  x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                x_reservation_id    => l_trans_id,
                p_line_id           => p_new_source_line_id
             );
         IF l_trans_id > 0 AND p_new_source_line_id <> p_old_source_line_id
         THEN  -- if it does not exist, don't bother
            l_old_transaction_rec.trans_id := l_trans_id;

            IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
              (l_old_transaction_rec, l_old_transaction_rec )
            THEN
               GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| p_new_source_line_id);
               GMI_RESERVATION_UTIL.balance_default_lot
                 ( p_ic_default_rec            => l_old_transaction_rec
                 , p_opm_item_id               => l_old_transaction_rec.item_id
                 , x_return_status             => x_return_status
                 , x_msg_count                 => x_msg_count
                 , x_msg_data                  => x_msg_data
                 );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                 GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
         -- Begin Bug 2985470
         ELSIF (l_orig_txn_exists = 1 AND p_new_source_line_id <> p_old_source_line_id) THEN -- need to create txn for split line.
            /* create a new trans for the new wdd, and new line_id if applicable */
            l_new_transaction_rec := l_old_transaction_rec;
            l_new_transaction_rec.trans_id := NULL;
            -- p_qty_to_split are in primary UOM
            l_new_transaction_rec.trans_qty := -1 * (abs(p_qty_to_split));
            l_new_transaction_rec.trans_qty2 := -1 * (abs(p_qty2_to_split));
            l_new_transaction_rec.line_id := p_new_source_line_id;

            GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
            ( 1
            , FND_API.G_FALSE
            , FND_API.G_FALSE
            , FND_API.G_VALID_LEVEL_FULL
            , l_new_transaction_rec
            , l_new_transaction_row
            , x_return_status
            , x_msg_count
            , x_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            /* qty filfilled*/
            l_qty_to_fulfil := 0;
            l_qty2_to_fulfil := 0;

            -- PK added
            GMI_RESERVATION_UTIL.find_default_lot
            (  x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               x_reservation_id    => l_trans_id,
               p_line_id           => p_new_source_line_id
            );
            IF l_trans_id > 0 AND p_new_source_line_id <> p_old_source_line_id
            THEN  -- if it does not exist, don't bother
              l_old_transaction_rec.trans_id := l_trans_id;

              IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
                (l_old_transaction_rec, l_old_transaction_rec )
              THEN
                GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| p_new_source_line_id);
                GMI_RESERVATION_UTIL.balance_default_lot
                ( p_ic_default_rec            => l_old_transaction_rec
                , p_opm_item_id               => l_old_transaction_rec.item_id
                , x_return_status             => x_return_status
                , x_msg_count                 => x_msg_count
                , x_msg_data                  => x_msg_data
                );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                  GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF;
            END IF;

         -- End Bug 2985470
         END IF;
      END IF;
      /* split reservations if neccessary */
      GML_BATCH_OM_RES_PVT.split_reservations
         (   p_old_delivery_detail_id  => p_old_delivery_detail_id
         ,  p_new_delivery_detail_id  => p_new_delivery_detail_id
         ,  p_old_source_line_id      => p_old_source_line_id
         ,  p_new_source_line_id      => p_new_source_line_id
         ,  p_qty_to_split            => p_qty_to_split
         ,  p_qty2_to_split           => p_qty2_to_split
         ,  p_orig_qty                => l_orig_qty
         ,  p_orig_qty2               => l_orig_qty2
         ,  p_action                  => 'O'
         ,  x_return_status           => x_return_status
         ,  x_msg_count               => x_msg_count
         ,  x_msg_data                => x_msg_data
         ) ;
   END IF;

END split_trans;

/* this procedure is called in confirm_deliveries for non ctl items*/
/* For Enhancement 2320442, code in following procedure commented out
   for non-controlled inventory items -  Lakshmi Swamy */
/* Bug 2901317 - Following procedure commented out for non-inv items */

procedure check_non_ctl (
    p_delivery_detail_id IN NUMBER
   ,p_shipped_quantity   IN NUMBER
   ,p_shipped_quantity2  IN NUMBER
   ,x_return_status      OUT NOCOPY VARCHAR2
   )
IS
  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_old_transaction_row    ic_tran_pnd%ROWTYPE ;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_trans_id               ic_tran_pnd.trans_id%TYPE;
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_location               ic_tran_pnd.location%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;
  l_line_detail_id         wsh_delivery_details.delivery_detail_id%TYPE;
  l_source_line_id         NUMBER;
  l_inventory_item_id      NUMBER;
  l_organization_id        NUMBER;
  l_whse_code              VARCHAR2(5);
  l_released_status        VARCHAR2(5);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(255);
  l_ctl_ind                VARCHAR2(1);
  l_been_there             NUMBER;
  l_get_trans              NUMBER;
  l_noninv_ind             NUMBER;

  Cursor get_wdd_info IS
  Select source_line_id
      ,  organization_id
      ,  inventory_item_id
  From wsh_delivery_details
  Where delivery_detail_id = p_delivery_detail_id;

  cursor c_reservations IS
    SELECT trans_id
      FROM ic_tran_pnd
     WHERE line_id = l_source_line_id
       AND line_detail_id = p_delivery_detail_id
       AND delete_mark = 0
       AND doc_type = 'OMSO'
       AND trans_qty <> 0;

  Cursor Get_item_info IS
    Select ic.noninv_ind
      From ic_item_mst ic
         , mtl_system_items mtl
     Where ic.item_no = mtl.segment1
       and mtl.inventory_item_id = l_inventory_item_id
       and mtl.organization_id = l_organization_id;

BEGIN

    RETURN; /* Bug 2901317 and Enhancement 2320442 */
    GMI_RESERVATION_UTIL.println('in check_non_ctl  NON ctl item');
    Open get_wdd_info;
    Fetch get_wdd_info
    Into l_source_line_id
       , l_organization_id
       , l_inventory_item_id
       ;
    Close get_wdd_info;

    Open  Get_item_info;
    Fetch Get_item_info INTO l_noninv_ind;
    Close Get_item_info;

     IF (l_noninv_ind = 1) THEN /* Following code only for non-inventory items - Bug2462993 */
       l_been_there := 0;
       Open c_reservations;
       Fetch c_reservations Into l_trans_id;
       IF c_reservations%NOTFOUND THEN
          l_trans_id := 0;
       END IF;
       Close c_reservations;
       IF l_trans_id <> 0 THEN  -- already ship confirmed, then reopened
          l_been_there := 1;
          update ic_tran_pnd
          set delete_mark=1
          Where trans_id=l_trans_id;
       END IF;

       GMI_RESERVATION_UTIL.find_default_lot
         (  x_return_status     => x_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            x_reservation_id    => l_trans_id,
            p_line_id           => l_source_line_id
         );
       l_get_trans := 0;
       l_old_transaction_rec.trans_id := l_trans_id;
       IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
             (l_old_transaction_rec, l_old_transaction_rec )
       THEN
          l_get_trans := 1;
       END IF;
       IF l_been_there = 1 AND l_get_trans = 1 THEN
          /* need to balance defualt lot */
          GMI_RESERVATION_UTIL.balance_default_lot
            ( p_ic_default_rec            => l_old_transaction_rec
            , p_opm_item_id               => l_old_transaction_rec.item_id
            , x_return_status             => x_return_status
            , x_msg_count                 => l_msg_count
            , x_msg_data                  => l_msg_data
            );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
            GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          l_get_trans := 0;
          /* need to fetch it again */
          IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
                (l_old_transaction_rec, l_old_transaction_rec )
          THEN
             l_get_trans := 1;
          END IF;
       END IF;

       IF l_get_trans = 1 THEN
          GMI_RESERVATION_UTIL.println('will update ictranpndNON ctl item','opm.log');
          IF p_shipped_quantity >= abs(l_old_transaction_rec.trans_qty) THEN -- ship the whole thing and more
             /* this line is no longer default trans */
             l_old_transaction_rec.trans_qty := -1 * (p_shipped_quantity);
             l_old_transaction_rec.trans_qty2 := -1 * (p_shipped_quantity2);
             update ic_tran_pnd
             set trans_qty = l_old_transaction_rec.trans_qty
                , trans_qty2 = l_old_transaction_rec.trans_qty2
                , line_detail_id = p_delivery_detail_id
                , staged_ind = 1
             Where trans_id = l_trans_id;

          ELSE -- partial ship
            GMI_RESERVATION_UTIL.println('split the default lot ','opm.log');
            update ic_tran_pnd
            set trans_qty = -1 * p_shipped_quantity
               , trans_qty2 = -1 * p_shipped_quantity2
               , line_detail_id = p_delivery_detail_id
               , staged_ind = 1
            Where trans_id = l_trans_id;
            /* create a new trans with the un shipped qtys for the default trans*/
            l_new_transaction_rec := l_old_transaction_rec;
            l_new_transaction_rec.trans_id := NULL;
            l_new_transaction_rec.trans_qty := -1 * (abs(l_new_transaction_rec.trans_qty)
                                                  - p_shipped_quantity);
            l_new_transaction_rec.trans_qty2 := -1 * (abs(l_new_transaction_rec.trans_qty2)
                                                  - p_shipped_quantity2);
            l_new_transaction_rec.line_detail_id := null;

            GMI_RESERVATION_UTIL.println('create trans '||l_trans_id );
            GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
            ( 1
            , FND_API.G_FALSE
            , FND_API.G_FALSE
            , FND_API.G_VALID_LEVEL_FULL
            , l_new_transaction_rec
            , l_new_transaction_row
            , x_return_status
            , l_msg_count
            , l_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            GMI_RESERVATION_UTIL.println('create trans '||l_new_transaction_row.trans_id );
          END IF;
       END IF;
    END IF;
END check_non_ctl;

Procedure unreserve_delivery_detail
        ( p_delivery_detail_id     IN NUMBER
        , p_quantity_to_unreserve  IN NUMBER
        , p_quantity_to_unreserve2 IN NUMBER default NULL
        , p_unreserve_mode         IN VARCHAR2
        , x_return_status          OUT NOCOPY VARCHAR2
        ) IS
l_trans_id                 NUMBER;
l_transaction_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
l_transaction_row          ic_tran_pnd%ROWTYPE;
l_new_transaction_row      ic_tran_pnd%ROWTYPE;
l_new_transaction_rec      GMI_TRANS_ENGINE_PUB.ictran_rec;
x_msg_count                NUMBER;
x_msg_data                 VARCHAR2(3000);
l_trans_qty                NUMBER;
l_trans_qty2               NUMBER;
l_quantity_to_unreserve    NUMBER;
l_quantity_to_unreserve2   NUMBER;
l_lock_status              BOOLEAN;

cursor c_get_opm_txn is
  Select trans_id
       , trans_qty
       , trans_qty2
  From ic_tran_pnd
  Where line_detail_id = p_delivery_detail_id
     --and line_id = p_source_line_id
     and doc_type='OMSO'
     and delete_mark = 0;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN c_get_opm_txn;
  GMI_RESERVATION_UTIL.println('unreserve wdd ' || p_delivery_detail_id);
  --GMI_RESERVATION_UTIL.println('unreserve line_id ' || p_source_line_id);
  l_quantity_to_unreserve    := p_quantity_to_unreserve;
  l_quantity_to_unreserve2   := p_quantity_to_unreserve2;
  --LOOP
  FETCH c_get_opm_txn
  into l_trans_id
     , l_trans_qty
     , l_trans_qty2
     ;
  CLOSE c_get_opm_txn;
  --EXIT WHEN c_get_opm_txn%NOTFOUND;
  l_transaction_rec.trans_id := l_trans_id;
  IF nvl(l_trans_id, 0) <> 0 THEN
     IF ( p_unreserve_mode = 'UNRESERVE') then
        IF abs(l_trans_qty) <= l_quantity_to_unreserve THEN
           GMI_SHIPPING_UTIL.unreserve_inv
               (  p_trans_id            => l_trans_id
               , x_return_status       => x_return_status
               );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.println('Error returned by Delete_Pending_Transaction');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        ELSE
          GMI_RESERVATION_UTIL.println('update the ic_tran_pnd');
           Update ic_tran_pnd
           Set trans_qty = -1 * (abs(l_trans_qty) - l_quantity_to_unreserve)
            ,  trans_qty2 = -1 * (abs(l_trans_qty2) - l_quantity_to_unreserve2)
           Where trans_id = l_trans_id;
        END IF;
     ELSE -- p_unreserve_mode = 'CYCLE_COUNT'
        update ic_tran_pnd
        set staged_ind = 0
        Where trans_id = l_trans_id;
     END IF; -- of mode
  END IF; -- l_trans_id
  --END LOOP;

  EXCEPTION
  WHEN OTHERS  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

END unreserve_delivery_detail;

/* Bug 2547509. Function to validate the trans_date. Returns sysdate if date is in closed period */

FUNCTION GMI_TRANS_DATE (p_trans_date date, p_orgn_code VARCHAR2, p_whse_code VARCHAR2) return DATE IS
  v_retval     NUMBER;
  l_trans_date date;
BEGIN
     l_trans_date := p_trans_date;
     v_retval := GMICCAL.trans_date_validate(p_trans_date,
                                             p_orgn_code,
                                             p_whse_code);
     IF (v_retval IN (-23, -25)) THEN
        /* -23 = Date is within a closed Inventory calendar period */
        /* -25 = Warehouse has been closed for the period          */
        l_trans_date := SYSDATE;
        GMI_RESERVATION_UTIL.println('Completing existing transaction in current open inventory period '||
                                      to_char(l_trans_date));
     END IF;
     return l_trans_date;
END GMI_TRANS_DATE;


/* Bug 2775197. Function to check if inventory is going negative. Returns TRUE if inventory is going negative */

FUNCTION INVENTORY_GOING_NEG(p_tran_rec GMI_TRANS_ENGINE_PUB.ictran_rec) return BOOLEAN IS
  l_retval     BOOLEAN := FALSE;
  l_noninv_ind NUMBER;
  l_onhand_qty NUMBER;
  l_allow_negative_inv NUMBER ;

  CURSOR Cur_non_inv IS
     SELECT noninv_ind
     FROM   ic_item_mst
     WHERE  item_id = p_tran_rec.item_id;

  CURSOR Cur_get_onhand_qty(p_tran_rec GMI_TRANS_ENGINE_PUB.ictran_rec) IS
     SELECT loct_onhand as qty
     FROM   ic_loct_inv
     WHERE  item_id   = p_tran_rec.item_id
     AND    whse_code = p_tran_rec.whse_code
     AND    lot_id    = p_tran_rec.lot_id
     AND    location  = p_tran_rec.location;

BEGIN
     OPEN  Cur_non_inv;
     FETCH Cur_non_inv INTO l_noninv_ind;
     CLOSE Cur_non_inv;

     IF l_noninv_ind = 1 THEN
        return FALSE;
     END IF;

     OPEN  Cur_get_onhand_qty(p_tran_rec);
     FETCH Cur_get_onhand_qty INTO l_onhand_qty;
     IF Cur_get_onhand_qty%FOUND THEN
        IF ABS(p_tran_rec.trans_qty) > l_onhand_qty THEN
           l_retval := TRUE;
        ELSE
           l_retval := FALSE;
        END IF;
     ELSE
        l_retval := TRUE;
     END IF;
     CLOSE Cur_get_onhand_qty;

     return l_retval;

END INVENTORY_GOING_NEG;

--Check if item and warehouse comination is location control
-- procedure added for bug 3380763
procedure check_loct_ctl (
    p_inventory_item_id             IN NUMBER
   ,p_mtl_organization_id           IN NUMBER
   ,x_ctl_ind                       OUT NOCOPY VARCHAR2)
IS
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_loct_ctl               NUMBER;
  l_whse_ctl               NUMBER;

  Cursor Get_item_info IS
  SELECT iim.item_id, iim.loct_ctl
  FROM   ic_item_mst iim,
         mtl_system_items msi
  WHERE  msi.inventory_item_id = p_inventory_item_id
  AND    msi.organization_id = p_mtl_organization_id
  AND    msi.segment1 = iim.item_no;


BEGIN
    /* get lot_ctl and loct_ctl */
    GMI_reservation_Util.PrintLn('check_loct_ctl for item_id '|| p_inventory_item_id
          ||' for org '||p_mtl_organization_id);
    Open get_item_info;
    Fetch get_item_info
    Into l_item_id
       , l_loct_ctl
       ;
    Close get_item_info;

    /* get whse loct_ctl */
    Select loct_ctl
    Into l_whse_ctl
    From ic_whse_mst
    Where mtl_organization_id = p_mtl_organization_id;

    IF (l_loct_ctl * l_whse_ctl) = 0 THEN
      x_ctl_ind := 'N';
    ElSE
      x_ctl_ind := 'Y';
    END IF;
    GMI_reservation_Util.PrintLn('check_loct_ctl returning '|| x_ctl_ind);
End check_loct_ctl;

-- HW 3388186
-- This procedure is introduced because of WSH Consolidate backorder Line Project in 11510
-- p_cons_dd_id Consolidated delivery_detail_id
-- p_old_dd_ids Old delivery_detail_ids that were consolidated

-- This procedure will take old delivery details,source line id
-- and match with the old ones to update the inventory transactions
-- with new delivery_detail_id
-- This procedure is called from WSHDDSPB.pls (11510), procedure: Backorder
-- This procedure will be called when Consolidated Backorder Line
-- is checked in Global Parameter under Shipping > Setup and
-- Action is Cycle Count All

PROCEDURE UPDATE_NEW_LINE_DETAIL_ID
 (  p_cons_dd_id       IN NUMBER
  , p_old_dd_ids       IN WSH_UTIL_CORE.Id_Tab_Type
  , x_return_status    OUT NOCOPY VARCHAR2
  )
 IS

-- Get the eligible records from inventory
 CURSOR GET_IC_RECORDS (l_source_line_id IN NUMBER
 			, l_dd_id IN NUMBER)IS
 SELECT line_id,line_detail_id
 FROM  IC_TRAN_PND IC
 WHERE IC.line_id = l_source_line_id
 AND   ic.line_detail_id = l_dd_id
 AND   IC.staged_ind = 0
 AND   IC.trans_qty <> 0
 AND   IC.doc_type='OMSO'
 AND   IC.delete_mark = 0 ;

 -- Find the proper source_line_Id from WSH using
 -- the consolidated dd_id
 CURSOR find_new_source_line (l_dd_id NUMBER) IS
 SELECT WDD.source_line_id
 FROM   WSH_DELIVERY_DETAILS WDD
 WHERE  WDD.delivery_detail_id = l_dd_id
 AND    WDD.container_flag = 'N'
 AND	WDD.source_code = 'OE'
 AND    WDD.released_status='B';

-- local variables
l_line_id            NUMBER;
l_ic_dd              NUMBER;
l_new_source_line_id NUMBER ;
l_wdd_id             NUMBER;


BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   gmi_reservation_util.println('In GMI_SHIPPING_UTIL.UPDATE_NEW_LINE_DETAIL_ID');
   gmi_reservation_util.println('Value of p_cons_dd_id is '||p_cons_dd_id);

-- Find the source_line_id associated with the new consolidated
-- backorder line from WSH

   OPEN find_new_source_line( p_cons_dd_id);

   FETCH find_new_source_line into l_new_source_line_id;
   IF ( find_new_source_line%NOTFOUND) THEN
     CLOSE find_new_source_line;
     gmi_reservation_util.println('Can not find source_line from WSH_DELIVERY_DETAILS for source_line'||p_cons_dd_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     RETURN;
   END IF;
   CLOSE find_new_source_line;

   IF ( l_new_source_line_id is NOT NULL ) THEN  -- source_line_id is found
     gmi_reservation_util.println('Found new line_id and it is '||l_new_source_line_id);

-- Loop through the old delivery_detail_ids to update them
-- with the new values
     for i IN p_old_dd_ids.FIRST .. p_old_dd_ids.LAST LOOP --{
       l_wdd_id := p_old_dd_ids(i);

-- Get source_line and original line_detail_id from IC_TRAN_PND

       OPEN GET_IC_RECORDS(l_new_source_line_id, l_wdd_id);
       FETCH GET_IC_RECORDS into l_line_id,l_ic_dd;

       gmi_reservation_util.println('Value of l_line_id is '||l_new_source_line_id);
       gmi_reservation_util.println('Value of l_icc_dd is '||l_ic_dd);
       gmi_reservation_util.println('Value of old dd is '||p_old_dd_ids(i));


-- Make sure values are not null and match old dd_id in IC_TRAN_PND
       IF ( ( nvl(l_line_id, 0) <> 0)  AND ( p_old_dd_ids(i) = l_ic_dd )
         AND  ( ( nvl(l_ic_dd, 0) <> 0) )) THEN

-- Update Inventoryu with new delivery_detail_id
         gmi_reservation_util.println('Update ic_tran_pnd with new line_detail_id '||p_cons_dd_id);
         UPDATE IC_TRAN_PND IC
         SET    IC.line_detail_id = p_cons_dd_id
         WHERE  IC.line_detail_id = l_ic_dd
         AND    IC.line_id        = l_line_id ;

         IF (SQL%NOTFOUND) THEN
           GMI_RESERVATION_UTIL.println('Error In Updating IC_TRAN_PND');
           RAISE NO_DATA_FOUND;
         END IF; -- of error updating

       END IF;   -- of line_id and old_dd_id

       IF GET_IC_RECORDS%ISOPEN THEN
         CLOSE GET_IC_RECORDS;
       END IF;

     END LOOP; -- of old_dd_ids
   ELSE
     gmi_reservation_util.println('Cannot find source_line_id');
   END IF;     -- of source_line_id




-- If any cursors are open, close them!
   IF find_new_source_line%ISOPEN THEN
      CLOSE find_new_source_line;
   END IF;

   IF GET_IC_RECORDS%ISOPEN THEN
      CLOSE GET_IC_RECORDS;
   END IF;


   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   gmi_reservation_util.println('Done calling GMI_SHIPPING_UTIL.UPDATE_NEW_LINE_DETAIL_ID');

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE NO_DATA_FOUND;
       GMI_RESERVATION_UTIL.Println('Raised When No Data Found in GMI_SHIPPING_UTIL.UPDATE_NEW_LINE_DETAIL_ID');

    WHEN OTHERS  THEN

      IF GET_IC_RECORDS%ISOPEN THEN
        CLOSE GET_IC_RECORDS;
      END IF;

      IF find_new_source_line%ISOPEN THEN
        CLOSE find_new_source_line;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

END UPDATE_NEW_LINE_DETAIL_ID;


END GMI_Shipping_Util;

/

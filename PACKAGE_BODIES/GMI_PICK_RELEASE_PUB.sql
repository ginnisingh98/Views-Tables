--------------------------------------------------------
--  DDL for Package Body GMI_PICK_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PICK_RELEASE_PUB" AS
/*  $Header: GMIPPKRB.pls 120.0 2005/05/25 16:21:25 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPPKRB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick Release process.                                               |
 |                                                                         |
 | - Auto_Detail                                                           |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     27-Apr-2000  odaboval        Created                                |
 |     09/10/01 HW BUG#:1941429 Added code to support cross_docking        |								            |
 +=========================================================================+
  API Name  : GMI_Pick_Release_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GMI_Pick_Release_PUB';
-- HW BUG#:2643440 -removed G_MISS_XXX from p_grouping_rule_id and
-- added DEFAULT NULL
PROCEDURE Auto_Detail
  (
     p_api_version                   IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_validation_flag               IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_hdr_rec                    IN  GMI_Move_Order_Global.mo_hdr_rec
   , p_mo_line_tbl                   IN  GMI_Move_Order_Global.mo_line_tbl
   , p_grouping_rule_id              IN  NUMBER DEFAULT NULL
   , p_allow_delete                  IN  VARCHAR2 DEFAULT NULL
   , x_pick_release_status           OUT NOCOPY INV_Pick_Release_PUB.INV_Release_Status_Tbl_Type
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

-- HW BUG#:1941429 cross_docking
CURSOR FIND_QTY  (l_source_line_id NUMBER)IS
select sum(ABS(trans_qty)), nvl(ABS(sum(trans_qty2)),0)
        from IC_TRAN_PND
       where line_id = l_source_line_id
       AND   completed_ind = 0
       AND   delete_mark = 0
       AND   lot_id <> 0
       AND   staged_ind = 0;

-- HW BUG#:1941429
CURSOR get_trans_id (l_source_line_id NUMBER) IS
select trans_id
from ic_tran_pnd
where line_id = l_source_line_id
       AND   completed_ind = 0
       AND   delete_mark = 0
       AND   staged_ind = 0;


l_api_version              NUMBER := 1.0;
l_api_name                 VARCHAR2(30) := 'Auto_Detail';

l_line_index               BINARY_INTEGER;
l_mo_line                  GMI_Move_Order_Global.mo_line_rec;
l_organization_id          NUMBER;
l_grouping_rule_id         NUMBER;
l_get_header_rule          NUMBER;
l_api_return_status        VARCHAR2(10);
l_processed_row_count      NUMBER := 0;
l_detail_rec_count         NUMBER := 0;
l_print_mode               VARCHAR2(1);

-- HW variables for BUG#:1941429
l_shipping_attr            WSH_INTERFACE.ChangedAttributeTabType;
l_quantity NUMBER;
l_trans_id NUMBER ;
l_secondary_quantity NUMBER;
l_line_status NUMBER;
l_source_line_id  NUMBER;
l_transaction_quantity NUMBER;
l_transaction_quantity2 NUMBER;
l_source_header_id NUMBER;
l_released_status VARCHAR2(1);
l_delivery_detail_id NUMBER;
l_p_allow_delete	VARCHAR2(3);

BEGIN
/* =======================================================================
  Raise a temporary error, for Dummy calls
 =======================================================================  */
/*      FND_MESSAGE.SET_NAME('GMI','GMI_RSV_UNAVAILABLE');   */
/*      OE_MSG_PUB.Add;     */
/*      RAISE FND_API.G_EXC_ERROR;   */

   GMI_Reservation_Util.PrintLn('Entering_GMI_Pick_Release....');
/* =====================================================================
   Initialization
  =====================================================================  */
   /*    Initialize API return status to success    */
gmi_reservation_util.println('Value of p_grouping_rule_id in Auto_Detail is '||p_grouping_rule_id);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   GMI_Reservation_Util.PrintLn('EXITING  GMI_Pick_Release....');

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, Before Init status');
   /*    Set a SavePoint    */
   SAVEPOINT Pick_Release_PUB;

   /*  Standard Call to check for call compatibility   */
   IF NOT FND_API.Compatible_API_Call(l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME) THEN
   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, Error in Compatible_API_Call');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /*  Initialize message list if p_init_msg_list is set to true   */
   IF FND_API.to_Boolean(p_init_msg_lst) THEN
      FND_MSG_PUB.initialize;
   END IF;
   /*  =====================================================================
        Validate parameters
       =====================================================================
     First determine whether the table of move order lines in p_mo_line_tbl has
     any records
    */
   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, Before Validation');

   IF ( p_mo_line_tbl.COUNT = 0 )
   THEN
   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, Validation Error count=0');
      ROLLBACK TO Pick_Release_PUB;
      FND_MESSAGE.SET_NAME('INV','INV_NO_LINES_TO_PICK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /*  Validate that all move order lines are from the same org, that all lines
     have a status of pre-approved (7) or approved (3), and that all of the move
     order lines are of type Pick Wave (3)
   */
   l_line_index := p_mo_line_tbl.FIRST;
   l_mo_line := p_mo_line_tbl(l_line_index);
   l_organization_id := l_mo_line.organization_id;
   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, Before loop org_id='||l_organization_id);
   LOOP
      /*  Verify that the lines are all for the same organization   */
      IF l_mo_line.organization_id <> l_organization_id THEN
         GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, In loop Error pick_different_org');
         FND_MESSAGE.SET_NAME('GMI','INV_PICK_DIFFERENT_ORG');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*  Verify that the line status is approved or pre-approved    */
      IF (l_mo_line.line_status <> 3 AND l_mo_line.line_status <> 7) THEN
         GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, In loop Error Pick_line_Status');
         FND_MESSAGE.SET_NAME('GMI','INV_PICK_LINE_STATUS');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*  Verify that the move order type is Pick Wave (3)   */
   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, In loop org_id='||l_organization_id||', index='||l_line_index);
      EXIT WHEN l_line_index = p_mo_line_tbl.LAST;
      l_line_index := p_mo_line_tbl.NEXT(l_line_index);
   END LOOP;

   /*  Determine what printing mode to use when pick releasing lines.
     Parameter p_org_parameters.print_pick_slip_mode
     The Move Order Lines may need to have their grouping rule ID defaulted from
     the header.
     This is only necessary if the Grouping Rule ID was not passed in as
     a parameter.
    */
-- HW BUG#:2643440 Replaced comparison to G_MISS_NUM with NULL
   IF p_grouping_rule_id IS NOT NULL THEN
      	l_grouping_rule_id := p_grouping_rule_id;
      	l_get_header_rule := 2;

   ELSE
      	l_get_header_rule := 1;

   END IF;

   GMI_Reservation_Util.PrintLn('GMI_Pick_Release_PUB, Validation complete');
   /*  =====================================================================
     Validation complete; begin pick release processing row-by-row
       =====================================================================
   */
   l_line_index := p_mo_line_tbl.FIRST;
   l_organization_id := l_mo_line.organization_id;
   LOOP
     l_mo_line := p_mo_line_tbl(l_line_index);
     /*  First retrieve the new Grouping Rule ID if necessary.   */
     IF l_get_header_rule = 1 THEN
        /*   If the header did not have a grouping rule ID, retrieve it from
         the organization-level default.
         */
        IF l_mo_line.grouping_rule_id IS NULL THEN
          /*   odab  l_mo_line.grouping_rule_id := p_org_parameters.pick_slip_rule_id; */
          null;
        END IF;
     END IF;

     -- Bug 1717145, 02-Apr-2001  odaboval, set the pickSlip printMode :
     BEGIN
       SELECT NVL(print_pick_slip_mode, 'E')
       INTO l_print_mode
       FROM WSH_SHIPPING_PARAMETERS
       WHERE organization_id = l_organization_id;
     EXCEPTION
       WHEN no_data_found THEN
         GMI_Reservation_Util.PrintLn('WARNING: print_pick_slip_mode not defined for org_id='||l_organization_id);
         l_print_mode := 'E';
     END;

     /* Call the Pick Release Process_Line API on the current Move Order Line */

	l_p_allow_delete := p_allow_delete;

      GMI_Reservation_Util.PrintLn('l_p_allow_delete = ' || l_p_allow_delete) ;
      GMI_Reservation_Util.PrintLn('calling GMI_Pick_Release_PVT.process_line. mo_line_id='||l_mo_line.line_id||', sched_ship_date='||l_mo_line.date_required||', ps_mode='||l_print_mode);
   gmi_reservation_util.println('Value of p_grouping_rule_idp_grouping_rule_id in Auto_Detail before calling process_line is '||p_grouping_rule_id);
   gmi_reservation_util.println('Value of l_grouping_rule_idp_grouping_rule_id in Auto_Detail before calling process_line is '||l_grouping_rule_id);
      GMI_Pick_Release_PVT.Process_Line(
         p_api_version          => 1.0
        ,p_validation_flag      => fnd_api.g_true
        ,p_commit               => fnd_api.g_false
        ,p_mo_hdr_rec           => p_mo_hdr_rec
        ,p_mo_line_rec          => l_mo_line
        ,p_grouping_rule_id     => l_grouping_rule_id
        ,p_print_mode           => l_print_mode
        ,p_allow_delete         => l_p_allow_delete
        ,x_detail_rec_count     => l_detail_rec_count
        ,x_return_status        => l_api_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
        );

      GMI_Reservation_Util.PrintLn('l_return_status from process_line is ' || l_api_return_status);
      IF l_api_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*  If partial picking is not allowed or a Move Order Line cannot be pick
        released, and the parameter to allow partial picking is false, then the
        API should rollback all changes and return an error.
      */
            x_pick_release_status.delete;
            ROLLBACK TO Pick_Release_PUB;
            FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_PICK_FULL');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /* HW BUG#:1941429 code for cross_docking */

      /* select line_status into l_line_status
      from ic_txn_request_lines
      where line_id = l_mo_line.line_id ;

      -- Need to check lines that are approved and pre-approved (status 3 and 7)

      IF ( l_mo_line.line_status <> 5 ) THEN
       gmi_reservation_util.println('In Auto_detail GMIPPKRB  move order <> 5 ');
       -- Need to find the record in delivery_details to map it to OPM ic_tran_pnd
       BEGIN
            gmi_reservation_util.println('In Aut_detail Going to select line_id from shipping');
            select source_line_id,delivery_detail_id into
                   l_source_line_id, l_delivery_detail_id
            from wsh_delivery_details
            where move_order_line_id = l_mo_line.line_id ;
       EXCEPTION
          WHEN no_data_found THEN
          ROLLBACK TO SAVEPOINT Pick_Release_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.count_and_get
           (   p_count  => x_msg_count
             , p_data  => x_msg_data
           );
       END ;
       gmi_reservation_util.println('In Auto_detail  going to sum qty from ic_tran_pnd');
       gmi_reservation_util.println('In Auto_detail  value of l_delivery_detail_id '||l_delivery_detail_id);
       gmi_reservation_util.println('In Auto_detail value of l_source_line_id '||l_source_line_id);
       gmi_reservation_util.println('In Auto_detail value of l_quantity '||l_quantity);

       BEGIN
         select sum(requested_quantity),nvl(sum(requested_quantity2),0)
         into l_quantity, l_secondary_quantity
         from wsh_delivery_details
         where source_line_id=l_source_line_id ;
       EXCEPTION
          WHEN no_data_found then
          GMI_Reservation_Util.Println('No Shipping data found in Auto_detail',
              'Inv_Pick_Release_Pub.Pick_Release');
                ROLLBACK TO SAVEPOINT Pick_Release_PUB;
                FND_MESSAGE.SET_NAME('INV','INV_DELIV_INFO_MISSING');
                FND_MSG_PUB.Add;
          RAISE fnd_api.g_exc_unexpected_error;
       END;

       gmi_reservation_util.println('Value of l_quantity from WDD '||l_quantity);
       gmi_reservation_util.println('Value of l_secondary_quantity from '||l_secondary_quantity);

       OPEN get_trans_id (l_source_line_id);
       FETCH get_trans_id into l_trans_id;
       IF (get_trans_id%NOTFOUND ) THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         GMI_RESERVATION_UTIL.PRINTLN('Error retrieving trans_id from ic_tran_pnd');
         RAISE NO_DATA_FOUND;
         CLOSE get_trans_id;
         RETURN;
       END IF;

       CLOSE get_trans_id;

       OPEN FIND_QTY(l_source_line_id);
       FETCH FIND_QTY into l_transaction_quantity, l_transaction_quantity2;
       IF ( FIND_QTY%NOTFOUND ) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          GMI_RESERVATION_UTIL.PRINTLN('Error retrieving info from ic_tran_pnd');
          RAISE NO_DATA_FOUND;
          CLOSE FIND_QTY;
          RETURN;
       END IF;

       gmi_reservation_util.println('Done getting info from ic_tran_pnd and value of l_transaction_quantity is '||l_transaction_quantity);
       CLOSE FIND_QTY;

       gmi_reservation_util.println('In Auto_detail value of l_quantity '||l_quantity);

       IF ( l_transaction_quantity < l_quantity ) THEN
         GMI_Reservation_Util.PrintLn('Pick Short -back order in GMI_PICK_RELEASE_PUB.Auto_detail');
         BEGIN
           select delivery_detail_id, source_header_id, source_line_id,
                  released_status
                  into l_delivery_detail_id, l_source_header_id, l_source_line_id,
                  l_released_status
                  from  wsh_delivery_details
                  where source_line_id = l_source_line_id
                  and move_order_line_id is NULL
                  and   released_status = 'R';
           EXCEPTION
               WHEN no_data_found then
           GMI_Reservation_Util.Println('No Shipping data found in Auto_detail',
              'Inv_Pick_Release_Pub.Pick_Release');
               ROLLBACK TO SAVEPOINT Pick_Release_PUB;
               FND_MESSAGE.SET_NAME('INV','INV_DELIV_INFO_MISSING');
               FND_MSG_PUB.Add;
         RAISE fnd_api.g_exc_unexpected_error;
         END;
         gmi_reservation_util.println('In Auto_detail going to call update_shipping');
         --Call Update_Shipping_Attributes to backorder detail line
         l_shipping_attr(1).source_header_id := l_source_header_id;
         l_shipping_attr(1).trans_id := l_trans_id;
         l_shipping_attr(1).source_line_id := l_source_line_id;
         l_shipping_attr(1).ship_from_org_id := l_mo_line.organization_id;
         l_shipping_attr(1).released_status := l_released_status;
         l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;
         l_shipping_attr(1).action_flag := 'B';
         l_shipping_attr(1).cycle_count_quantity := l_quantity - l_transaction_quantity ;
         l_shipping_attr(1).cycle_count_quantity2 := nvl(l_secondary_quantity - l_transaction_quantity2,0);
         l_shipping_attr(1).subinventory := l_mo_line.from_subinventory_code;
         l_shipping_attr(1).locator_id := l_mo_line.from_locator_id;

      gmi_reservation_util.println('value of l_shipping_attr(1).cycle_count_quantity1 before calling update shipping att is '||l_shipping_attr(1).cycle_count_quantity);
      gmi_reservation_util.println('value of l_shipping_attr(1).cycle_count_quantity2 before calling update shipping att is '||l_shipping_attr(1).cycle_count_quantity2);

         WSH_INTERFACE.Update_Shipping_Attributes
              (p_source_code               => 'INV',
               p_changed_attributes        => l_shipping_attr,
               x_return_status             => l_api_return_status
              );
         IF( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
            GMI_Reservation_Util.Println('Retrun error from update shipping attributes',
                       'GMI_Pick_Release_Pub.Auto_Detail');
            raise FND_API.G_EXC_ERROR;
         END IF;

         UPDATE IC_TXN_REQUEST_LINES
         SET quantity = l_transaction_quantity,
                secondary_quantity = l_transaction_quantity2
         where line_id = l_mo_line.line_id;
       END IF; -- of (l_transaction_quantity < l_quantity)
     END IF ;  -- of ( line_status <> 5 )
     -- HW end of changes for cross docking BUG#:1941429*/

      /*  Populate return status structure with the processing status of this row.  */
      l_processed_row_count := l_processed_row_count + 1;
      GMI_Reservation_Util.PrintLn('In Loop, Set the return pick_release_status rec_type row='||l_processed_row_count||', detail_rec_count='||l_detail_rec_count);
      x_pick_release_status(l_processed_row_count).mo_line_id := l_mo_line.line_id;
      x_pick_release_status(l_processed_row_count).return_status := l_api_return_status;
      x_pick_release_status(l_processed_row_count).detail_rec_count := l_detail_rec_count;

      /*     l_detail_rec_count := 0;  */
      /*  Update the Pick Release API's return status to an error if the line could
       not be processed.  Note that processing of other lines will continue.
      */
      IF l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
         l_api_return_status = FND_API.G_RET_STS_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      GMI_Reservation_Util.PrintLn('Before Next loop No Error');

      EXIT WHEN l_line_index = p_mo_line_tbl.LAST;
      l_line_index := p_mo_line_tbl.NEXT(l_line_index);
   END LOOP;

x_return_status := l_api_return_status;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.PrintLn('End of Pick_ReleasePUB Error (Rollback to Savepoint)');
      ROLLBACK TO SAVEPOINT Pick_Release_PUB;

      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data   */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.PrintLn('End of Pick_ReleasePUB ErrorOther (Rollback to Savepoint)');
      ROLLBACK TO SAVEPOINT Pick_Release_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data   */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Auto_Detail;


END GMI_Pick_Release_PUB;

/

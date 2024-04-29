--------------------------------------------------------
--  DDL for Package Body GMI_PICK_RELEASE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PICK_RELEASE_UTIL" AS
/*  $Header: GMIUPKRB.pls 115.17 2004/01/26 20:28:22 lswamy ship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUPKRS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Utilities procedures relating to GMI          |
 |     Pick Release process.                                               |
 |                                                                         |
 | - Get_Delivery_Details                                                  |
 | - Create_Pick_Slip_and_Print                                            |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     04-May-2000  odaboval        Created                                |
 |     03-06-2003 BUG#: 2837671                                            |
 |                Changed the call to wsh_pr_pick_slip_number              |
 |                to call inv_pr_pick_slip_number if 110509 installed      |
 |                This was changed per shipping recommendation since the   |
 |                INV team is the owner of the pick slip package           |
 |                This fix is included in patch 2694399.                   |
 |								           |
 +=========================================================================+
  API Name  : GMI_Pick_Release_Util
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GMI_Pick_Release_Util';

PROCEDURE Get_Delivery_Details
   ( p_mo_line_id                    IN  NUMBER
   , x_inv_delivery_details          OUT NOCOPY WSH_INV_DELIVERY_DETAILS_V%ROWTYPE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

/*  Define local variables   */
l_api_version			CONSTANT NUMBER := 1.0;
l_api_name			CONSTANT VARCHAR2(30) := 'Get_Delivery_Details';


-- Bug 1805216, added NOT NULL in the cursor.
CURSOR c_delivery( mo_line_id IN NUMBER) IS
   SELECT *
   FROM wsh_inv_delivery_details_v
   WHERE move_order_line_id = mo_line_id
   AND   move_order_line_id IS NOT NULL
   AND   released_status = 'S';


BEGIN

/*  Init Return Status  */
x_return_status := FND_API.G_RET_STS_SUCCESS;

GMI_Reservation_Util.PrintLn('In Get_Delivery_Details mo_line_id='||p_mo_line_id);

OPEN c_delivery( p_mo_line_id);
FETCH c_delivery
      INTO x_inv_delivery_details;

IF ( c_delivery%NOTFOUND )
THEN
   FND_MESSAGE.SET_NAME('GMI','INV_DELIV_INFO_MISSING');
   FND_MESSAGE.Set_Token('MO_LINE_ID',p_mo_line_id);
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END IF;

GMI_Reservation_Util.PrintLn('In Get_Delivery_Details NO Error');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
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
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Get_Delivery_Details;

PROCEDURE Create_Pick_Slip_and_Print
   ( p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
   , p_inv_delivery_details          IN  WSH_INV_DELIVERY_DETAILS_V%ROWTYPE
   , p_pick_slip_mode                IN  VARCHAR2
   , p_grouping_rule_id              IN  NUMBER
   , p_allow_partial_pick            IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

/*  Define local variables */
l_api_version                  CONSTANT NUMBER := 1.0;
l_api_name                     CONSTANT VARCHAR2(30) := 'Create_Pick_Slip_and_Print';

l_trans_id                     NUMBER;
/*  The transaction temp ID of the move order  */
/*  line detail being processed    */
l_sub_code                     VARCHAR2(10);
/*  The subinventory code for the move order  */
/*  line detail being processed  */
l_pick_slip_mode               VARCHAR2(1);
/*  The print pick slip mode (immediate or   */
/*  deferred) that should be used   */
l_pick_slip_number             NUMBER;
/* The pick slip number to put on the  */
/*  Move Order Line Details for a Line.  */
l_reservation_detailed_qty     NUMBER;
/*  The qty detailed for a reservation.  */
l_ready_to_print               VARCHAR2(1);
/*  The flag for whether we need to  */
/* commit and print after receiving   */
/*  the current pick slip number.   */
l_api_error_msg                VARCHAR2(100);
/*  The error message returned by certain  */
/*  APIs called within Process_Line  */
l_api_return_status            VARCHAR2(1);
/* The return status of APIs called  */
/*  within the Process Line API.  */
l_report_set_id                NUMBER;
l_request_number               VARCHAR2(80);
-- HW BUG#:2009229
l_call_mode                       VARCHAR2(1);

-- bug 3069040
IC$DEFAULT_LOCT        VARCHAR2(255) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

/*  Cursors :  */
CURSOR c_mold_crs (mo_source_line_id IN NUMBER)
IS
   SELECT trans_id, whse_code
   FROM ic_tran_pnd
   WHERE line_id = mo_source_line_id
   AND pick_slip_number IS NULL
   AND (lot_id <> 0 or location <> ic$default_loct); -- added this condition for bug3069040


CURSOR c_doc_set (request_number IN NUMBER)
IS
   SELECT document_set_id
   FROM wsh_picking_batches
   WHERE name  = l_request_number;

CURSOR c_mo_header (mo_header_id  IN NUMBER,
                     mo_organization_id IN NUMBER)
IS
   SELECT request_number
   FROM ic_txn_request_headers
   WHERE header_id = mo_header_id
   AND organization_id = mo_organization_id;


BEGIN
   GMI_Reservation_Util.PrintLn('Entering Create_Pick_Slip_and_Print ');

   SAVEPOINT Process_Pick_Slip_Number;

   /* Obtain the pick slip number for each Move Order Line Detail created  */
   OPEN c_mold_crs (p_mo_line_rec.txn_source_line_id);
   LOOP
      /* Retrieve each Move Order Line Detail and get the pick slip number for each   */
      FETCH c_mold_crs INTO l_trans_id, l_sub_code;
      EXIT WHEN c_mold_crs%NOTFOUND;

      GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print trans_id='||l_trans_id||', whse_code='||l_sub_code);

      -- Bug 1717145 : Apr-2001 odaboval replaced package GMI by WSH
      --  (Theorically, the GMI package GMI_Pr_Pick_Slip_Number becomes useless)
-- HW BUG#:2009229 added new parameter x_call_mode since shipping
-- changed the number of paramters passed to this routine
      l_call_mode:=NULL;
gmi_reservation_util.println('Value of p_pick_slip_mode is '||p_pick_slip_mode);
gmi_reservation_util.println('Value of p_grouping_rule_id is '||p_grouping_rule_id);
gmi_reservation_util.println('Value of p_mo_line_rec.organization_id is '||p_mo_line_rec.organization_id);
gmi_reservation_util.println('Value of p_inv_delivery_details.oe_header_id is '||p_inv_delivery_details.oe_header_id);
gmi_reservation_util.println('Value of p_inv_delivery_details.customer_id is '||p_inv_delivery_details.customer_id);
gmi_reservation_util.println('Value of p_inv_delivery_details.freight_code is '||p_inv_delivery_details.freight_code);
gmi_reservation_util.println('Value of p_inv_delivery_details.ship_to_location is '||p_inv_delivery_details.ship_to_location);
gmi_reservation_util.println('Value of p_inv_delivery_details.shipment_priority_code is '||p_inv_delivery_details.shipment_priority_code);
gmi_reservation_util.println('Value of l_sub_code is '||l_sub_code);
gmi_reservation_util.println('Value of p_inv_delivery_details.trip_stop_id is '||p_inv_delivery_details.trip_stop_id);
gmi_reservation_util.println('Value of p_inv_delivery_details.shipping_delivery_id is '||p_inv_delivery_details.shipping_delivery_id);

-- HAW 2837671 Check if 110509 is installed and call the correct package
   IF (wsh_code_control.get_code_release_level < '110509') THEN
      WSH_Pr_Pick_Slip_Number.Get_Pick_Slip_Number
              ( p_ps_mode                    => p_pick_slip_mode
              , p_pick_grouping_rule_id      => p_grouping_rule_id
              , p_org_id                     => p_mo_line_rec.organization_id
              , p_header_id                  => p_inv_delivery_details.oe_header_id
              , p_customer_id                => p_inv_delivery_details.customer_id
              , p_ship_method_code           => p_inv_delivery_details.freight_code
              , p_ship_to_loc_id             => p_inv_delivery_details.ship_to_location
              , p_shipment_priority          => p_inv_delivery_details.shipment_priority_code
              , p_subinventory               => l_sub_code
              , p_trip_stop_id               => p_inv_delivery_details.trip_stop_id
              , p_delivery_id                => p_inv_delivery_details.shipping_delivery_id
              , x_pick_slip_number           => l_pick_slip_number
              , x_ready_to_print             => l_ready_to_print
              , x_api_status                 => l_api_return_status
              , x_error_message              => l_api_error_msg
              , x_call_mode                  => l_call_mode);

   ELSE -- Call the new INV package
      INV_pr_Pick_Slip_number.Get_Pick_Slip_Number
              ( p_ps_mode                    => p_pick_slip_mode
              , p_pick_grouping_rule_id      => p_grouping_rule_id
              , p_org_id                     => p_mo_line_rec.organization_id
              , p_header_id                  => p_inv_delivery_details.oe_header_id
              , p_customer_id                => p_inv_delivery_details.customer_id
              , p_ship_method_code           => p_inv_delivery_details.freight_code
              , p_ship_to_loc_id             => p_inv_delivery_details.ship_to_location
              , p_shipment_priority          => p_inv_delivery_details.shipment_priority_code
              , p_subinventory               => l_sub_code
              , p_trip_stop_id               => p_inv_delivery_details.trip_stop_id
              , p_delivery_id                => p_inv_delivery_details.shipping_delivery_id
              , x_pick_slip_number           => l_pick_slip_number
              , x_ready_to_print             => l_ready_to_print
              , x_api_status                 => l_api_return_status
              , x_error_message              => l_api_error_msg
              , x_call_mode                  => l_call_mode);

   END IF; -- 2837671 End of checking release value

      GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print pick_slip_number='||l_pick_slip_number||', ret_stat='||l_api_return_status);
      IF (l_api_return_status <> FND_API.G_RET_STS_SUCCESS
         OR l_pick_slip_number = -1)
      THEN
        GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print Error returned by Get_Pick_Slip_Number, status='||l_api_return_status);
        ROLLBACK TO Process_Pick_Slip_Number;
        FND_MESSAGE.SET_NAME('INV','INV_NO_PICK_SLIP_NUMBER');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;



      /*  Assign the pick slip number to the record in IC_TRAN_PND  */
      GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print update ic_tran_pnd with pick_slip_number='||l_pick_slip_number);
      UPDATE ic_tran_pnd
      SET pick_slip_number = l_pick_slip_number
      WHERE trans_id = l_trans_id;

      /*  If the pick slip is ready to be printed (and partial picking is allowed) commit */

      /*  and print at this point. */
-- HW BUG#:2009229 added check for l_call_mode
      GMI_Reservation_Util.PrintLn('(opm_dbg) In Create_Pick_Slip_and_Print ready_to_prt='||l_ready_to_print||', allow_partial_pick='||p_allow_partial_pick);

      -- HW BUG#:2296620 added a check for ship_set_id
      GMI_Reservation_Util.PrintLn('(opm_dbg) In Create_Pick_Slip_and_Print ready_to_prt='||l_ready_to_print||', allow_partial_pick='||p_allow_partial_pick);
      IF (l_ready_to_print = FND_API.G_TRUE
      AND p_allow_partial_pick = FND_API.G_TRUE
      AND p_mo_line_rec.ship_set_id IS NULL
      AND l_call_mode is NULL )
      THEN
/*  do I have to commit ? */
         -- COMMIT WORK;

         /*  ========================================================================  */
         /*  Get for more Info :  */
         /*  ======================================================================== */
         OPEN c_mo_header(p_mo_line_rec.header_id,
                          p_mo_line_rec.organization_id);
         FETCH c_mo_header
               INTO l_request_number;
         IF ( c_mo_header%NOTFOUND )
         THEN
            GMI_Reservation_Util.PrintLn('(opm_dbg) In Create_Pick_Slip_and_Print Request_number not found for header_id='||p_mo_line_rec.header_id);
            CLOSE c_mo_header;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_mo_header;

         OPEN c_doc_set( l_request_number);
         FETCH c_doc_set
               INTO l_report_set_id;
         IF (c_doc_set%NOTFOUND)
         THEN
            GMI_Reservation_Util.PrintLn('(opm_dbg) In Create_Pick_Slip_and_Print doc_set_id not found for request_number='||l_request_number);
            CLOSE c_doc_set;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_doc_set;

         GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print call Print_Pick_Slip report_set_id='||l_report_set_id);
         -- Bug 1717145 : Apr-2001 odaboval replaced package GMI by WSH
         --  (Theorically, the GMI package GMI_Pr_Pick_Slip_Number becomes useless)
         WSH_Pr_Pick_Slip_Number.Print_Pick_Slip
             ( p_pick_slip_number      => l_pick_slip_number
             , p_report_set_id         => l_report_set_id
             , p_organization_id       => p_mo_line_rec.organization_id
             , x_api_status            => l_api_return_status
             , x_error_message         => l_api_error_msg);

         IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print Error returned by Print_Pick_Slip, status='||l_api_return_status);
           ROLLBACK TO Process_Pick_Slip_Number;
           FND_MESSAGE.SET_NAME('INV','INV_PRINT_PICK_SLIP_FAILED');
           FND_MESSAGE.SET_TOKEN('PICK_SLIP_NUM', to_char(l_pick_slip_number));
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print before loop');
   END LOOP;
   CLOSE c_mold_crs;

GMI_Reservation_Util.PrintLn('In Create_Pick_Slip_and_Print NO Error');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data  */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Create_Pick_Slip_and_Print;

/* The following procedure is created for enhancement 1928979 - lswamy*/
PROCEDURE Create_Manual_Alloc_Pickslip
   ( p_organization_id       IN NUMBER
   , p_line_id               IN NUMBER
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , x_pick_slip_number     OUT NOCOPY NUMBER
   ) IS

  CURSOR pnd_txn_pickslip_CUR (mo_source_line_id IN NUMBER) IS
   SELECT pick_slip_number
     FROM ic_tran_pnd
    WHERE line_id = mo_source_line_id
      AND pick_slip_number is NOT NULL
      AND (location     <> GMI_Reservation_Util.G_DEFAULT_LOCT OR  lot_id <> 0)
      AND delete_mark   = 0
      AND completed_ind = 0
      AND doc_type      = 'OMSO';

  --Bug3294071
  CURSOR pnd_txn_pickslip_noctl_CUR (mo_source_line_id IN NUMBER) IS
   SELECT pick_slip_number
     FROM ic_tran_pnd
    WHERE line_id = mo_source_line_id
      AND pick_slip_number is NOT NULL
      AND delete_mark   = 0
      AND completed_ind = 0
      AND doc_type      = 'OMSO';

  CURSOR get_item_ctl (p_item_id IN NUMBER) IS
   SELECT lot_ctl, loct_ctl, noninv_ind
     FROM ic_item_mst
    WHERE item_id = p_item_id;

   CURSOR get_whse_ctl (p_whse_code IN VARCHAR2) IS
   SELECT loct_ctl
     FROM ic_whse_mst
    WHERE whse_code=p_whse_code;
  -- End Bug3294071


  CURSOR pnd_txn_CUR (mo_source_line_id IN NUMBER) IS
   SELECT whse_code,item_id
     FROM ic_tran_pnd
    WHERE line_id = mo_source_line_id;

  CURSOR mo_header_CUR (p_header_id NUMBER) IS
    SELECT grouping_rule_id
      FROM ic_txn_request_headers
     WHERE HEADER_ID = p_header_id;

  l_mo_line_rec  GMI_Move_Order_Global.mo_line_rec;
  l_demand_info WSH_INV_DELIVERY_DETAILS_V%ROWTYPE;
  l_print_mode VARCHAR2(1);
  l_grouping_rule_id NUMBER;
  l_dummy            VARCHAR2(30);
  l_trans_id         NUMBER;
  l_sub_code         VARCHAR2(10);
  l_api_name         CONSTANT VARCHAR2(30) := 'Create_Manual_Alloc_Pickslip ';

-- Bug3294071
  l_item_id          NUMBER;
  l_lot_ctl          NUMBER;
  l_whse_loct_ctl    NUMBER;
  l_noninv_ind       NUMBER;
  l_item_loct_ctl    NUMBER;
  l_ready_to_print   VARCHAR2(1);
  l_call_mode        VARCHAR2(1);
  l_whse_code        VARCHAR2(10);
BEGIN

    GMI_Reservation_Util.PrintLn('IN create Manual alloc pickslip');
    l_mo_line_rec := GMI_MOVE_ORDER_LINE_util.Query_Row( p_line_id );
    -- Bug3294071
    -- Modified and included the following code.
    -- This ensures that if there is a pick slip number for
    -- a noncontrol item - we return without any more processing.
    -- This used to happen only for lot controlled item before.
      SAVEPOINT Process_Pick_Slip_Number;

      OPEN  pnd_txn_CUR (l_mo_line_rec.txn_source_line_id);
      FETCH pnd_txn_CUR INTO l_whse_code,l_item_id;
      CLOSE pnd_txn_CUR;

      OPEN  get_item_ctl(l_item_id);
      FETCH get_item_ctl INTO l_lot_ctl,l_item_loct_ctl, l_noninv_ind;
      CLOSE get_item_ctl;

      OPEN  get_whse_ctl(l_whse_code);
      FETCH get_whse_ctl INTO l_whse_loct_ctl;
      CLOSE get_whse_ctl;

      IF  (l_noninv_ind = 0) THEN
        IF (l_lot_ctl <> 0 OR (l_item_loct_ctl * l_whse_loct_ctl <> 0) ) THEN
          OPEN  pnd_txn_pickslip_CUR (l_mo_line_rec.txn_source_line_id);
          FETCH pnd_txn_pickslip_CUR INTO x_pick_slip_number;
          IF (pnd_txn_pickslip_CUR%FOUND) THEN
            CLOSE pnd_txn_pickslip_CUR;
            return;
          END IF;
        ELSE
           OPEN pnd_txn_pickslip_noctl_CUR(l_mo_line_rec.txn_source_line_id);
           FETCH pnd_txn_pickslip_noctl_CUR INTO x_pick_slip_number;
            IF (pnd_txn_pickslip_noctl_CUR%FOUND) THEN
              CLOSE pnd_txn_pickslip_noctl_CUR;
              return;
            END IF;
        END IF;
      END IF;
    -- End bug3294071


    GMI_Pick_Release_Util.Get_Delivery_Details(
         p_mo_line_id           => p_line_id
       , x_inv_delivery_details => l_demand_info
       , x_return_status        => x_return_status
       , x_msg_count            => x_msg_count
       , x_msg_data             => x_msg_data);


    BEGIN
       SELECT NVL(print_pick_slip_mode, 'E')
       INTO l_print_mode
       FROM WSH_SHIPPING_PARAMETERS
       WHERE organization_id = p_organization_id;
    EXCEPTION
       WHEN no_data_found THEN
        GMI_Reservation_Util.PrintLn('WARNING: print_pick_slip_mode not defined for org_id='||p_organization_id);
        l_print_mode := 'E';
    END;

    OPEN mo_header_CUR(l_mo_line_rec.header_id);
    FETCH mo_header_CUR INTO l_grouping_rule_id;
    CLOSE mo_header_CUR;

    x_pick_slip_number := NULL;
    -- Bug3294071(making call directly here to get the pick slip number )
    /* GMI_Pick_Release_Util.Create_Pick_Slip_and_Print(
               p_mo_line_rec            => l_mo_line_rec
             , p_inv_delivery_details   => l_demand_info
             , p_pick_slip_mode         => l_print_mode
             , p_grouping_rule_id       => l_grouping_rule_id
             , p_pick_slip_number       => x_pick_slip_number
             , p_sub_code               => l_sub_code
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
        FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Pick_Release_Util.Create_Pick_Slip_and_Print');
        FND_MESSAGE.Set_Token('WHERE', 'GMI_Pick_Release_PVT.Process_Line');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF; */

     GMI_Reservation_Util.PrintLn(' Calling appropriate WSH or INV wrapper as to get the pick slip number  ');
     IF (wsh_code_control.get_code_release_level < '110509') THEN
       WSH_Pr_Pick_Slip_Number.Get_Pick_Slip_Number
              ( p_ps_mode                    => l_print_mode
              , p_pick_grouping_rule_id      => l_grouping_rule_id
              , p_org_id                     => l_mo_line_rec.organization_id
              , p_header_id                  => l_demand_info.oe_header_id
              , p_customer_id                => l_demand_info.customer_id
              , p_ship_method_code           => l_demand_info.freight_code
              , p_ship_to_loc_id             => l_demand_info.ship_to_location
              , p_shipment_priority          => l_demand_info.shipment_priority_code
              , p_subinventory               => l_whse_code
              , p_trip_stop_id               => l_demand_info.trip_stop_id
              , p_delivery_id                => l_demand_info.shipping_delivery_id
              , x_pick_slip_number           => x_pick_slip_number
              , x_ready_to_print             => l_ready_to_print
              , x_api_status                 => x_return_status
              , x_error_message              => x_msg_data
              , x_call_mode                  => l_call_mode);

     ELSE -- Call the new INV package
       INV_pr_Pick_Slip_number.Get_Pick_Slip_Number
              ( p_ps_mode                    => l_print_mode
              , p_pick_grouping_rule_id      => l_grouping_rule_id
              , p_org_id                     => l_mo_line_rec.organization_id
              , p_header_id                  => l_demand_info.oe_header_id
              , p_customer_id                => l_demand_info.customer_id
              , p_ship_method_code           => l_demand_info.freight_code
              , p_ship_to_loc_id             => l_demand_info.ship_to_location
              , p_shipment_priority          => l_demand_info.shipment_priority_code
              , p_subinventory               => l_whse_code
              , p_trip_stop_id               => l_demand_info.trip_stop_id
              , p_delivery_id                => l_demand_info.shipping_delivery_id
              , x_pick_slip_number           => x_pick_slip_number
              , x_ready_to_print             => l_ready_to_print
              , x_api_status                 => x_return_status
              , x_error_message              => x_msg_data
              , x_call_mode                  => l_call_mode);

     END IF; -- 2837671 End of checking release value

     GMI_Reservation_Util.PrintLn('In Create_Manual_alloc_pickslip pick_slip_number='||x_pick_slip_number||', ret_stat='||x_return_status);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS
         OR x_pick_slip_number = -1)
     THEN
        GMI_Reservation_Util.PrintLn('In Create_Manual_alloc_pickslip Error returned by Get_Pick_Slip_Number, status='||x_return_status);
        ROLLBACK TO Process_Pick_Slip_Number;
        FND_MESSAGE.SET_NAME('INV','INV_NO_PICK_SLIP_NUMBER');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     GMI_Reservation_Util.PrintLn('In Create_Manual_alloc_pickslip NO Error');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data   => x_msg_data
       );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data   => x_msg_data
       );

END Create_Manual_Alloc_Pickslip;

/* Bug3294071 */
/* Created following procedure Lswamy*/

PROCEDURE UPDATE_TXN_WITH_PICK_SLIP
   (   p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
     , p_pick_slip_number              IN  NUMBER
     , x_return_status                 OUT NOCOPY VARCHAR2
     , x_msg_count                     OUT NOCOPY NUMBER
     , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS


  l_whse_code        VARCHAR2(10);
  l_item_id          NUMBER;
  l_lot_ctl          NUMBER;
  l_whse_loct_ctl    NUMBER;
  l_noninv_ind       NUMBER;
  l_item_loct_ctl    NUMBER;
  IC$DEFAULT_LOCT    VARCHAR2(255) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  l_trans_id         NUMBER;
  l_api_name         CONSTANT VARCHAR2(30) := 'Update txn with Pick Slip ';

  CURSOR allocations_trans_id IS
   Select trans_id
   From ic_tran_pnd
   Where line_id = p_mo_line_rec.txn_source_line_id
     and doc_type = 'OMSO'
     and delete_mark = 0
     and completed_ind = 0
     and (lot_id <> 0 or location <> ic$default_loct);


   CURSOR pnd_txn_CUR (mo_source_line_id IN NUMBER) IS
   SELECT whse_code, item_id
     FROM ic_tran_pnd
    WHERE line_id = mo_source_line_id;


  CURSOR get_item_ctl (p_item_id IN NUMBER) IS
   SELECT lot_ctl, loct_ctl, noninv_ind
     FROM ic_item_mst
    WHERE item_id = p_item_id;

   CURSOR get_whse_ctl (p_whse_code IN VARCHAR2) IS
   SELECT loct_ctl
     FROM ic_whse_mst
    WHERE whse_code=p_whse_code;


BEGIN

      OPEN  pnd_txn_CUR (p_mo_line_rec.txn_source_line_id);
      FETCH pnd_txn_CUR INTO l_whse_code,l_item_id;
      CLOSE pnd_txn_CUR;

      OPEN  get_item_ctl(l_item_id);
      FETCH get_item_ctl INTO l_lot_ctl,l_item_loct_ctl, l_noninv_ind;
      CLOSE get_item_ctl;

      OPEN  get_whse_ctl(l_whse_code);
      FETCH get_whse_ctl INTO l_whse_loct_ctl;
      CLOSE get_whse_ctl;

      IF  (l_noninv_ind = 0) THEN
           IF (l_lot_ctl <> 0 OR (l_item_loct_ctl * l_whse_loct_ctl <> 0) ) THEN
             FOR transaction_ids IN allocations_trans_id LOOP
                UPDATE ic_tran_pnd
                SET    pick_slip_number = p_pick_slip_number
                WHERE  trans_id = transaction_ids.trans_id;
             END LOOP;
           ELSE
              SELECT trans_id
                INTO l_trans_id
                FROM ic_tran_pnd
               WHERE line_id = p_mo_line_rec.txn_source_line_id
                 AND doc_type = 'OMSO'
                 AND delete_mark = 0
                 AND completed_ind = 0
                 AND staged_ind = 0
                 AND (lot_id = 0 and location = ic$default_loct);

              UPDATE ic_tran_pnd
                 SET pick_slip_number = p_pick_slip_number
               WHERE trans_id = l_trans_id;
           END IF;
      END IF;

      GMI_Reservation_Util.PrintLn('In UPDATE_TXN_WITH_PICK_SLIP  NO Error');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data   => x_msg_data
       );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data   => x_msg_data
       );

END UPDATE_TXN_WITH_PICK_SLIP;

END GMI_Pick_Release_Util;

/

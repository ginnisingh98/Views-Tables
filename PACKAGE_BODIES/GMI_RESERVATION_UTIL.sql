--------------------------------------------------------
--  DDL for Package Body GMI_RESERVATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RESERVATION_UTIL" AS
/*  $Header: GMIURSVB.pls 120.0 2005/05/25 15:57:16 appldev noship $  */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 | - Check_Missing                                                         |
 | - Validation_for_Query                                                  |
 | - Validation_Before_Allocate                                            |
 | - Get_Default_Lot                                                       |
 | - Create_Default_Lot                                                    |
 | - Get_Allocation                                                        |
 | - Get_OPMUOM_from_AppsUOM                                               |
 | - Get_AppsUOM_from_OPMUOM                                               |
 | - Get_Org_from_SO_Line                                                  |
 | - Get_OPM_item_from_Apps                                                |
 | - Reallocate                                                            |
 | - Transfer_Msg_Stack  - Removed and put into OE_MSG_PUB                 |
 | - Get_DefaultLot_from_ItemCtl                                           |
 | - PrintLn                                                               |
 | - Validation_ictran_pnd                                                 |
 | - Set_Pick_Lots                                                         |
 | - Create_Empty_Default_Lot                                              |
 | - Default_Lot_Exist                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 | 07-MAR-2000  odaboval        Created                                    |
 | 27-Apr-2000  mpetrosi Removed Transfer_Msg_Stack to OE_MSG_PUB          |
 | 15-Nov-2000  odaboval B1471071 Changes the setting of the trans_date.   |
 | 16-Nov-2000  odaboval B1390816 Added a check on the Horizon period.     |
 | 12-Apr-2001  KYH      B1731567 Correct 2 co_codes sharing 1 variable    |
 | 03-JUL-2001  HVERDDIN Added Old Cursors For UOM routines, this is       |
 |                       For Customers Not On OPM mini-pack E. Uncomment   |
 |                       these and Comment Out Original Search For MINI-E  |
 | 20/08/2001   FABDI    B2023369 Move Order Locking issue                 |
 | 20-Jun-2002  pupakare B2418860 Commented out the code to validate the   |
 |                       demand source header id in Check_Missing proc     |
 | 09/16/02     HAW      BUG#:2536589 New procedures: update_opm_trxns,    |
 |                       and find_lot_id.                                  |
 |                       These procedures are called from OM file          |
 |                       OEXVIIFB.pls in procedure Inventory_Interface     |
 |                       Thess procedures will be called if user uses      |
 |                       the Bill To functionality from Order Pad          |
 | 9/29/02 	NC       Added p_commit parameter for Set_pick_lots inorder|
 |			 to support the Public API allocate_opm_orders.    |
 |			 added IF condition to commit only if this commit  |
 |			 flag is set.					   |
 | Oct, 2002    HW       Added new procedures to support WSH.I -           |
 |                       Harmonization project.                            |
 |                       Two new procedures:Validate_lot_number and        |
 |                       line_allocated                                    |
 |									   |
 | Nov, 2002    HW BUG#:2654963 Added p_delivery_detail_id to proc         |
 |                       line_allocated                                    |
 | Nov, 2002    HW       BUG#:2654963 Added p_delivery_detail_id to proc.  |
 |                       line_allocated.                                   |
 |                                                                         |
 | Nov, 2002    HW       bug#2677054 - WSH.I project                       |
 | Feb, 2003    PK       Bug#2749329 - Commented call to Lock_inventory in |
 |                       set_pick_lots.                                    |
 | Apr, 2004    Vipul    BUG#3503593 - Added code in Procedure             |
 |                       create_transaction_for_rcv to convert the qty into|
 |                       item's uom.                                       |
 | Aug  2004    Plowe    BUG#3770264 - Added code in Procedures            |
 |                       create_transaction_for_rcv, set_pick_lots and     |
 |											 create_dflt_lot_from_scratch to                   |
 |											 retrieve correct lang 														 |
 |											 for retrieval of mtl_sales_orders                 |
 +=========================================================================+
  API Name  : GMI_Reservation_Util
  Type      : Private Package Body
  Function  : This package contains Private Utilities procedures used to
              OPM reservation process.
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


/*  Global variables  */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='GMI_Reservation_UTIL';

/* B1731568  -  There is a need to distinguish between the co_code
                associated with the OPM cust_no and that associated with
                inventory transactions (orgn_code owning the warehouse).
                This global var is to be used when writing inv transactions
                to ic_tran_pnd/ic_tran_cmp */

g_co_code       IC_TRAN_PND.CO_CODE%TYPE;

PROCEDURE Check_Missing
   ( p_event                         IN  VARCHAR2
   , p_rec_to_check                  IN  INV_Reservation_Global.mtl_reservation_rec_type
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Missing';

BEGIN
/* =======================================================================
  Init variables
 =======================================================================  */
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (p_event = 'QUERY') THEN
   /* =======================================================================
     At Query(Pub) we just need to check :
          organization_id
          demand_source_header_id
          demand_source_line_id
    ======================================================================= */
   IF (  p_rec_to_check.organization_id IS NULL
      OR p_rec_to_check.organization_id = 0
      OR p_rec_to_check.organization_id = FND_API.G_MISS_NUM )
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(q): Error, organization_id missing ');
      FND_MESSAGE.Set_Name('GMI','MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'Organization_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   /* Begin - Bug 2418860 */
   /*
   IF (  p_rec_to_check.demand_source_header_id IS NULL
      OR p_rec_to_check.demand_source_header_id = 0
      OR p_rec_to_check.demand_source_header_id = FND_API.G_MISS_NUM )
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(q): Error, demand_source_header_id missing ');
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'demand_source_header_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;
   */
   /* End - Bug 2418860 */

   IF (  p_rec_to_check.demand_source_line_id IS NULL
      OR p_rec_to_check.demand_source_line_id = 0
      OR p_rec_to_check.demand_source_line_id = FND_API.G_MISS_NUM )
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(q): Error, demand_source_line_id missing ');
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'demand_source_line_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;
ELSIF p_event = 'CREATE' THEN
   /* =======================================================================
     At Create(Pub) we just need to check :
          organization_id
          demand_source_header_id
          demand_source_line_id
          demand_source_type_id
          inventory_item_id
          reservation_uom_code
          reservation_quantity
          requirement_date

    ======================================================================= */

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check organization_id ');
   IF (  p_rec_to_check.organization_id IS NULL
      OR p_rec_to_check.organization_id = 0
      OR p_rec_to_check.organization_id = FND_API.G_MISS_NUM )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'Organization_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   /* Begin - Bug 2418860 */
   /*
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check demand_source_header_id ');
   IF (  p_rec_to_check.demand_source_header_id IS NULL
      OR p_rec_to_check.demand_source_header_id = 0
      OR p_rec_to_check.demand_source_header_id = FND_API.G_MISS_NUM )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'demand_source_header_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;
   */
   /* End - Bug 2418860 */

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check demand_source_line_id ');
   IF (  p_rec_to_check.demand_source_line_id IS NULL
      OR p_rec_to_check.demand_source_line_id = 0
      OR p_rec_to_check.demand_source_line_id = FND_API.G_MISS_NUM )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'demand_source_line_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check demand_source_type_id ');
   IF (  p_rec_to_check.demand_source_type_id IS NULL
      OR p_rec_to_check.demand_source_type_id = 0
      OR p_rec_to_check.demand_source_type_id = FND_API.G_MISS_NUM )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'demand_source_type_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check inventory_item_id ');
   IF (  p_rec_to_check.inventory_item_id IS NULL
      OR p_rec_to_check.inventory_item_id = 0
      OR p_rec_to_check.inventory_item_id = FND_API.G_MISS_NUM )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'inventory_item_id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check reservation_uom_code ');
   IF (  p_rec_to_check.reservation_uom_code IS NULL
      OR p_rec_to_check.reservation_uom_code = FND_API.G_MISS_CHAR )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'reservation_uom_code');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check reservation_quantity ');
   IF (  p_rec_to_check.reservation_quantity IS NULL
      OR p_rec_to_check.reservation_quantity = 0
      OR p_rec_to_check.reservation_quantity = FND_API.G_MISS_NUM )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'reservation_quantity');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Check_Mising(c): Check requirement_date ');
   IF (  p_rec_to_check.requirement_date IS NULL
      OR p_rec_to_check.requirement_date = FND_API.G_MISS_DATE )
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'requirement_date');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;
END IF;

GMI_reservation_Util.PrintLn('(opm_dbg) end of Util.Check_Mising(q): No Error  ');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) end of Util.Check_Mising(q): EXP Error count='||x_msg_count);

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

      GMI_reservation_Util.PrintLn('(opm_dbg) end of Util.Check_Mising(q): UNEXP Error count='||x_msg_count);

END Check_Missing;

PROCEDURE Validation_for_Query
   ( p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , x_opm_um                        OUT NOCOPY VARCHAR2
   , x_apps_um                       OUT NOCOPY VARCHAR2
   , x_ic_item_mst_rec               OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , x_error_code                    OUT NOCOPY NUMBER  /* Added parameter, Bug 2168710 */
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Validation_for_Query';


/* ====== variables ========================================================================== */
l_inventory_item_id    NUMBER;
l_order_quantity_uom   VARCHAR2(3);

/* ====== cursors ============================================================================  */
CURSOR c_sales_order (om_line_id IN NUMBER) IS
SELECT inventory_item_id,
       order_quantity_uom
FROM oe_order_lines_all
WHERE line_id = om_line_id;


BEGIN
/* ======================================================================= */
/*  Init variables     */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_error_code := 0; /* Bug2168710 */

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Entering Validation_For_Query. line_id='
             ||p_query_input.demand_source_line_id);
/* =============================================================================================  */
/*  Get sales order lines details */
/* ============================================================================================= */
OPEN c_sales_order(p_query_input.demand_source_line_id);
FETCH c_sales_order
        INTO l_inventory_item_id,
             l_order_quantity_uom;

IF c_sales_order%NOTFOUND THEN
   /* ================================================================ */
   /*  Don't raise any error here, because no reservation has been created for that line (anyway) */
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: om_line_id=NOTFOUND='
                    ||p_query_input.demand_source_line_id||'.');
/*  ================================================================*/
   /* FND_MESSAGE.Set_Name('GMI','SO_Not_Found');  */
   /*  FND_MESSAGE.Set_Token('LINE_ID', p_query_input.demand_source_line_id); */
   /* FND_MSG_PUB.Add; */
   /* RAISE FND_API.G_EXC_ERROR; */
ELSE
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: inv_item_id='||l_inventory_item_id||'.');

   /* ============================================================================================= */
   /*  Get Item details */
   /* ============================================================================================= */
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Entering Validation_For_Query. item_id='
                      ||l_inventory_item_id);
   Get_OPM_item_from_Apps(
           p_organization_id          => p_query_input.organization_id
         , p_inventory_item_id        => l_inventory_item_id
         , x_ic_item_mst_rec          => x_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_query_input.organization_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', l_inventory_item_id);
      FND_MSG_PUB.Add;
      CLOSE c_sales_order;               -- Bug 3598280
      raise FND_API.G_EXC_ERROR;
   END IF;



   /* ============================================================================================= */
   /*  Get UOM details */
   /* ============================================================================================= */
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Entering Validation_For_Query.');
   x_apps_um := l_order_quantity_uom;
   Get_OPMUOM_from_AppsUOM(
           p_Apps_UOM                 => l_order_quantity_uom
         , x_OPM_UOM                  => x_opm_um
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);


   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
      FND_MESSAGE.Set_Token('APPS_UOM_CODE', l_order_quantity_uom);
      FND_MSG_PUB.Add;
      CLOSE c_sales_order;                   -- Bug 3598280
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: uom1='||x_opm_um||'.');
   END IF;

END IF;
CLOSE c_sales_order;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      /* Begin - Bug 2168710 */
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_code := SQLCODE;
      /* End - Bug 2168710 */

      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Exp_Error ');

   WHEN OTHERS THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Error in Select='||SQLCODE||'.');
      x_return_status := SQLCODE;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Validation_for_Query;


PROCEDURE Get_Default_Lot
   ( x_ic_tran_pnd_index             OUT NOCOPY BINARY_INTEGER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Default_Lot';

i    BINARY_INTEGER;

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_ic_tran_pnd_index := 0;

GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_Default_Lot. default lot='
           ||GMI_Reservation_Util.G_DEFAULT_LOCT||', ic_tran.COUNT='
           ||GMI_Reservation_Util.ic_tran_rec_tbl.COUNT);

IF GMI_Reservation_Util.ic_tran_rec_tbl.COUNT > 0
THEN
   i  := GMI_Reservation_Util.ic_tran_rec_tbl.COUNT;
   WHILE i >= 1
   LOOP
      IF  (ic_tran_rec_tbl(i).location = GMI_Reservation_Util.G_DEFAULT_LOCT
          AND ic_tran_rec_tbl(i).lot_id  = 0 )
      THEN
          x_ic_tran_pnd_index := i;
          /*  Exit at the next loop. */
          i := 0;
          /*  EXIT; */
      ELSE
          i := i - 1;
      END IF;
   END LOOP;
END IF;

   IF x_ic_tran_pnd_index = 0
   THEN
      /*  the default lot doesn't exist */
GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_default_lot_qty. no default lot.');
   ELSE
GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_default_lot_qty. default lot exists.
                default_lot_index='||x_ic_tran_pnd_index);

   END IF;
GMI_reservation_Util.PrintLn('(opm_dbg) end of Util Get_default_lot_qty NO Error.');

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

END Get_Default_Lot;

/* ======================================================================= */
/*  In this procedure, only when create the default lot, uses the Item UOM. */
/*   So convert the quantities into Item UOMs */
/* ======================================================================= */
PROCEDURE Create_Default_Lot
   ( p_allocation_rec                IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
   , p_ic_item_mst_rec               IN  GMI_Reservation_Util.ic_item_mst_rec
   , p_orgn_code                     IN  VARCHAR2
   , p_trans_id                      IN  NUMBER DEFAULT NULL
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Default_Lot';

l_ictran_rec         GMI_TRANS_ENGINE_PUB.ictran_rec;
l_tran_row           IC_TRAN_PND%ROWTYPE;
l_tmp_qty            NUMBER(19,9);

ll_trans_id          NUMBER;

-- BEGIN - Bug 3216096
Cursor get_line_info (l_line_id IN number) IS
  Select SCHEDULE_SHIP_DATE
  From   oe_order_lines_all
  Where  line_id = l_line_id;

l_schedule_ship_date DATE;
-- END   - Bug 3216096

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

GMI_reservation_Util.PrintLn('(opm_dbg) in Util Create_default_lot.');
   /*  Fill the ic_tran_pnd record type, and then insert into ic_tran_pnd */
   l_ictran_rec.item_id        := p_ic_item_mst_rec.item_id;
   l_ictran_rec.line_id        := p_allocation_rec.line_id;
   l_ictran_rec.co_code        := g_co_code;                -- B1731567
   l_ictran_rec.orgn_code      := p_orgn_code;
   l_ictran_rec.whse_code      := p_allocation_rec.whse_code;
   l_ictran_rec.lot_id         := 0;          /* the default lot */
   l_ictran_rec.location       := GMI_Reservation_Util.G_DEFAULT_LOCT;
   l_ictran_rec.doc_id         := p_allocation_rec.doc_id;
   l_ictran_rec.doc_type       := 'OMSO';
   l_ictran_rec.doc_line       := p_allocation_rec.doc_line;
   l_ictran_rec.line_type      := 0;
   l_ictran_rec.reason_code    := NULL;
   l_ictran_rec.trans_date     := p_allocation_rec.trans_date;
   l_ictran_rec.qc_grade       := p_allocation_rec.prefqc_grade;
   l_ictran_rec.user_id        := p_allocation_rec.user_id;
   l_ictran_rec.staged_ind     := 0;
   l_ictran_rec.event_id       := 0;

  /* ============================================================================== */
  /*  Convert order quantity into item's uom quantity */
  /*  If order UM differs from inventory UM, conversion is required.*/
  /*  The allocations are recorded as transactions written in the inventory UM */
  /* ============================================================================== */
  GMI_reservation_Util.PrintLn('(opm_dbg) in Util Create_default_lot. before call GMICUOM order_um1='
            ||p_allocation_rec.order_um1||', item_um='||p_ic_item_mst_rec.item_um||'.' );
  IF (p_allocation_rec.order_um1 <> p_ic_item_mst_rec.item_um)
  THEN
    GMICUOM.icuomcv(pitem_id  => p_ic_item_mst_rec.item_id,
                    plot_id   => 0,
                    pcur_qty  => p_allocation_rec.order_qty1,
                    pcur_uom  => p_allocation_rec.order_um1,
                    pnew_uom  => p_ic_item_mst_rec.item_um,
                    onew_qty  => l_tmp_qty);


      /*  Invert the quantity for ic_tran_pnd */
      l_ictran_rec.trans_qty := l_tmp_qty * (-1);

  ELSE
    l_ictran_rec.trans_qty := p_allocation_rec.order_qty1 * (-1);
  END IF;

  l_ictran_rec.trans_um  := p_ic_item_mst_rec.item_um;
  GMI_reservation_Util.PrintLn('(opm_dbg) in Util Create_default_lot. trans_um='
           ||p_ic_item_mst_rec.item_um||', trans_qty='||l_ictran_rec.trans_qty||'.' );

   /*  Note that the UOM2 are already in the Item UOM2. No need to convert. */
   l_ictran_rec.trans_qty2 := p_allocation_rec.order_qty2 * (-1);
   l_ictran_rec.trans_um2  := p_allocation_rec.order_um2;

   /* odab remove on 30-Aug-2000
   IF ( p_ic_item_mst_rec.dualum_ind > 0 )
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util Create_default_lot. Need to populate qty2/um2.');
      l_ictran_rec.trans_um2  := p_ic_item_mst_rec.item_um2;

      GMICUOM.icuomcv(pitem_id  => p_ic_item_mst_rec.item_id,
                      plot_id   => 0,
                      pcur_qty  => l_ictran_rec.trans_qty,
                      pcur_uom  => l_ictran_rec.trans_um,
                      pnew_uom  => l_ictran_rec.trans_um2,
                      onew_qty  => l_ictran_rec.trans_qty2);

   ELSE
      l_ictran_rec.trans_qty2 := NULL;
      l_ictran_rec.trans_um2  := NULL;
   END IF;
   odab */

   /*  odab : I need to more investigate this pb. */
   /*      why trans_qty2 >0 ! it should alway be <0 ! */
   IF (nvl(l_ictran_rec.trans_qty2,0) > 0)
   THEN
      l_ictran_rec.trans_qty2 := l_ictran_rec.trans_qty2 * (-1);
   END IF;

   IF (p_trans_id is NULL)
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util Create_default_lot.
                 before call create_pending_transaction qty1='||l_ictran_rec.trans_qty||' '
                 ||l_ictran_rec.trans_um||', qty2='||l_ictran_rec.trans_qty2||' '||l_ictran_rec.trans_um2);

      GMI_Reservation_Util.Default_Lot_Exist
           ( p_line_id        => l_ictran_rec.line_id
           , p_item_id        => l_ictran_rec.item_id
           , x_trans_id       => ll_trans_id
           , x_return_status  => x_return_status
           , x_msg_count      => x_msg_count
           , x_msg_data       => x_msg_data);

      IF (ll_trans_id is NULL)
      THEN

         -- BEGIN - Bug 3216096
         -- Get the scheduled to ship date from the line
         Open  get_line_info (l_ictran_rec.line_id);
         Fetch get_line_info into l_schedule_ship_date;
         Close get_line_info;
         l_ictran_rec.trans_date := l_schedule_ship_date;
         -- END   - Bug 3216096

         GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
           ( p_api_version      => 1.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_commit           => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , p_tran_rec         => l_ictran_rec
           , x_tran_row         => l_tran_row
           , x_return_status    => x_return_status
           , x_msg_count        => x_msg_count
           , x_msg_data         => x_msg_data
           );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
                 return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
            GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
            FND_MESSAGE.Set_Token('WHERE','Create_Default_Lot');
            FND_MSG_PUB.Add;
            raise FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         GMI_reservation_Util.PrintLn('(opm_dbg) Dont create the default lot again (Shouldnt be here) - 1 ! ');
      END IF;
   ELSE
      l_ictran_rec.trans_id := p_trans_id;

      GMI_reservation_Util.PrintLn('(opm_dbg) in Util Create_default_lot.
                 before call update_pending_transaction qty1='||l_ictran_rec.trans_qty||' '
                 ||l_ictran_rec.trans_um||', qty2='||l_ictran_rec.trans_qty2||' '
                 ||l_ictran_rec.trans_um2||', trans_id='||l_ictran_rec.trans_id);

      GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
            ( p_api_version      => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_commit           => FND_API.G_FALSE
            , p_validation_level => FND_API.G_VALID_LEVEL_FULL
            , p_tran_rec         => l_ictran_rec
            , x_tran_row         => l_tran_row
            , x_return_status    => x_return_status
            , x_msg_count        => x_msg_count
            , x_msg_data         => x_msg_data);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Default_Lot:
                 Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.' );
         GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
         FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
         FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
         FND_MESSAGE.Set_Token('WHERE', 'Create_Default_Lot');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;

GMI_reservation_Util.PrintLn('(opm_dbg) end of Util Create_default_lot x_return_status='
                 || x_return_status||', x_msg_count='|| x_msg_count||'.');
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

END Create_Default_Lot;

PROCEDURE Validation_Before_Allocate
   ( p_mtl_rsv_rec       IN  INV_Reservation_Global.mtl_reservation_rec_type
   , x_allocation_rec    OUT NOCOPY GMI_Auto_Allocate_PUB.gmi_allocation_rec
   , x_ic_item_mst_rec   OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_orgn_code         OUT NOCOPY VARCHAR2
   , x_return_status     OUT NOCOPY VARCHAR2
   , x_msg_count         OUT NOCOPY NUMBER
   , x_msg_data          OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Validation_before_Allocate';
l_tmp_qty            NUMBER(19,9);

/* ==== Cursors ============================================================== */
/*  removed from this cursor : */
/*     oe_order_header_all oeh, */
/*  AND   oeh.header_id  = oel.header_id */

--B1731567 - Retrieve co_code associated with cust_no to give the customer key
--============================================================================
/* bug 2245351, to carry the code forward without forking, we will eliminate the use
  of op_cust_mst
  the co_code should be same as g_co_code */
CURSOR c_customer_and_so_info (oe_line_id IN NUMBER) IS
SELECT oel.sold_to_org_id
     , oel.ship_to_org_id
     , oel.line_number + (oel.shipment_number / 10)
     , oel.org_id
FROM  oe_order_lines_all oel
WHERE  oel.line_id = oe_line_id;

CURSOR c_user IS
SELECT user_id,
       user_name
FROM fnd_user
WHERE  user_id = FND_GLOBAL.USER_ID;

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;


GMI_reservation_Util.PrintLn('(opm_dbg) Entering  Util validation_before_allocate:');

/* ============================================================================================= */
/*  Initialize the allocation record type */
/*  Note that the Qty are not converted (only the Apps/OPM UOM) */
/* ============================================================================================= */
x_allocation_rec.doc_id       := p_mtl_rsv_rec.demand_source_header_id;
x_allocation_rec.line_id      := p_mtl_rsv_rec.demand_source_line_id;
x_allocation_rec.trans_date   := p_mtl_rsv_rec.requirement_date;
x_allocation_rec.prefqc_grade := p_mtl_rsv_rec.attribute1;
x_allocation_rec.order_qty1   := p_mtl_rsv_rec.reservation_quantity;
IF (p_mtl_rsv_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
  x_allocation_rec.line_detail_id   := null;
ELSE
  x_allocation_rec.line_detail_id   := to_number(p_mtl_rsv_rec.attribute4);
END IF;

/*  qty2 is set after test on value of dualum_ind  */
/*  x_allocation_rec.order_qty2   := p_mtl_rsv_rec.attribute2; */
x_allocation_rec.user_id      := FND_GLOBAL.user_id;


/* ============================================================================================= */
/*  Check Source Type */
/* ============================================================================================= */
/*  IF (p_mtl_rsv_rec.demand_source_name <> 'OMSO') THEN */
   /* raise_application_error(-20001,'source type='||p_mtl_rsv_rec.demand_source_name||', not OMSO');*/
/*  END IF; */

/* ============================================================================================= */
/*  Get whse, and organization code from Process.               */
/* ============================================================================================= */
INV_GMI_RSV_Branch.Get_Process_Org(
          p_organization_id     => p_mtl_rsv_rec.organization_id,
          x_opm_whse_code       => x_allocation_rec.whse_code,
          x_opm_co_code         => g_co_code,          -- B1731567
          x_opm_orgn_code       => x_orgn_code,
          x_return_status       => x_return_status );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_Util.Validation_Before_Allocate
                 ERROR:Returned by Get_Process_Org.');
   FND_MESSAGE.Set_Name('GMI','GMI_GET_PROCESS_ORG');
   FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_mtl_rsv_rec.organization_id);
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END IF;

x_allocation_rec.co_code      := g_co_code;

/* ============================================================================================= */
/*  Get Item details */
/* ============================================================================================= */
Get_OPM_item_from_Apps(
           p_organization_id          => p_mtl_rsv_rec.organization_id
         , p_inventory_item_id        => p_mtl_rsv_rec.inventory_item_id
         , x_ic_item_mst_rec          => x_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);


GMI_reservation_Util.PrintLn('(opm_dbg) in Util v: item_no='||x_ic_item_mst_rec.item_no);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_Util.Validation_Before_Allocate
                 ERROR:Returned by Get_OPM_item_from_Apps.');
   FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
   FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_mtl_rsv_rec.organization_id);
   FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_mtl_rsv_rec.inventory_item_id);
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
ELSE
   x_allocation_rec.item_no      := x_ic_item_mst_rec.item_no;
END IF;



/*=========================================================================================== */
/*  Get Customer details */
/* ============================================================================================= */
/*
IN A NEXT VERSION : CUST_ID is going to be returned
*/
/*  B1731567 - Retrieve co_code which is part of the customer key
    ============================================================*/
    OPEN c_customer_and_so_info(x_allocation_rec.line_id);
    FETCH c_customer_and_so_info
         INTO x_allocation_rec.of_cust_id,
              x_allocation_rec.ship_to_org_id,
              x_allocation_rec.doc_line,
              x_allocation_rec.org_id;

   IF (c_customer_and_so_info%NOTFOUND) THEN
      CLOSE c_customer_and_so_info;
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util v: cust_no=NOTFOUND');
      FND_MESSAGE.Set_Name('GMI','GMI_CUST_INFO');
      FND_MESSAGE.Set_Token('SO_LINE_ID', x_allocation_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util v: cust_no='||x_allocation_rec.cust_no||',
                 doc_line='||x_allocation_rec.doc_line);
   END IF;
   CLOSE c_customer_and_so_info;


/* ============================================================================================= */
/*  Get UOM details */
/*  Allocated UOM1 = The primary UOM of the item */
/*             if order_um1 <> primary UOM */
/*                then */
/*                      convert the reserved qty into primary UOM of the item */
/*  */
/*  Allocated UOM2 = the dual UOM of the item */
/* ============================================================================================= */
Get_OPMUOM_from_AppsUOM(
           p_Apps_UOM                 => p_mtl_rsv_rec.reservation_uom_code
         , x_OPM_UOM                  => x_allocation_rec.order_um1
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);


IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
   FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
   FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_mtl_rsv_rec.reservation_uom_code);
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
ELSE
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util v: uom1='||x_allocation_rec.order_um1||'.');
END IF;

IF (x_ic_item_mst_rec.dualum_ind > 0) THEN
   /*  No need to convert Apps/OPM UOM, because in the Sales Order line, UOM2 is always the Item UOM2. */
   x_allocation_rec.order_qty2   := p_mtl_rsv_rec.attribute2;
   x_allocation_rec.order_um2    := x_ic_item_mst_rec.item_um2;

ELSE
   x_allocation_rec.order_qty2   := NULL;
   x_allocation_rec.order_um2    := NULL;
END IF;

/* ============================================================================================= */
/*  Convert Reservation quantity into the Item UOM : */
/*  Only if allocation_class is MANUAL allocation (for the default lot) */
/*   This means that the Order_Qties/UOM are passed to the Allocation Engine.  */
/* ============================================================================================= */
/*  odab Added this on 1-Sept-2000, because it is not passed by the SO. */
IF (x_allocation_rec.order_um2 is null
   and x_ic_item_mst_rec.item_um2 is not null)
THEN

IF (x_allocation_rec.order_um1 <> x_ic_item_mst_rec.item_um
    AND (x_ic_item_mst_rec.alloc_class = ' ' OR x_ic_item_mst_rec.alloc_class IS NULL))
THEN
   GMICUOM.icuomcv(pitem_id  => x_ic_item_mst_rec.item_id,
                   plot_id   => 0,
                   pcur_qty  => p_mtl_rsv_rec.reservation_quantity,
                   pcur_uom  => x_allocation_rec.order_um1,
                   pnew_uom  => x_ic_item_mst_rec.item_um,
                   onew_qty  => l_tmp_qty);

   x_allocation_rec.order_qty1 := l_tmp_qty;
   x_allocation_rec.order_um1 := x_ic_item_mst_rec.item_um;

ELSE
   x_allocation_rec.order_qty1 := p_mtl_rsv_rec.reservation_quantity;
END IF;

   /*  Calculation of Qty2 from Qty1 */
   IF x_ic_item_mst_rec.dualum_ind > 0
   THEN
      x_allocation_rec.order_um2  := x_ic_item_mst_rec.item_um2;

      GMICUOM.icuomcv(pitem_id  => x_ic_item_mst_rec.item_id,
                      plot_id   => 0,
                      pcur_qty  => x_allocation_rec.order_qty1,
                      pcur_uom  => x_allocation_rec.order_um1,
                      pnew_uom  => x_allocation_rec.order_um2,
                      onew_qty  => l_tmp_qty);

      x_allocation_rec.order_qty2 := l_tmp_qty;


   ELSE
      x_allocation_rec.order_qty2 := NULL;
      x_allocation_rec.order_um2  := NULL;
   END IF;
END IF;

/* ============================================================================================= */
/*  Get User details not needed */
/* ============================================================================================= */

GMI_reservation_Util.PrintLn('(opm_dbg) Exiting  Util validation_before_allocate:');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.PrintLn('Exiting  Util validation_before_allocate: Error');
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.PrintLn('Exiting  Util validation_before_allocate: ErrorOther');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Validation_Before_Allocate;

PROCEDURE Get_Allocation
   ( p_trans_id                      IN  NUMBER
   , x_ic_tran_pnd_index             OUT NOCOPY BINARY_INTEGER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Allocation';

i    BINARY_INTEGER;

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_ic_tran_pnd_index := 0;

GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_Allocation.');
IF GMI_Reservation_Util.ic_tran_rec_tbl.COUNT > 0
THEN
   i  := 1;
   WHILE i <= GMI_Reservation_Util.ic_tran_rec_tbl.COUNT
   LOOP
      IF  (ic_tran_rec_tbl(i).trans_id = p_trans_id )
      THEN
          x_ic_tran_pnd_index := i;
          /*  Exit at the next loop. */
          i := GMI_Reservation_Util.ic_tran_rec_tbl.COUNT +1;
          /*  EXIT; */
      ELSE
          i := i + 1;
      END IF;
   END LOOP;
END IF;

   IF x_ic_tran_pnd_index = 0
   THEN
      /*  the default lot doesn't exist */
GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_Allocation. no transaction='||p_trans_id);
   ELSE
GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_Allocation. Allocation exists.');

   END IF;
GMI_reservation_Util.PrintLn('(opm_dbg) end of Util Get_Allocation.');

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


END Get_Allocation;

PROCEDURE Get_OPMUOM_from_AppsUOM(
     p_Apps_UOM                      IN  VARCHAR2
   , x_OPM_UOM                       OUT NOCOPY VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_OPMUOM_from_AppsUOM';

/* For OPM MiniPack E customers */
CURSOR c_uom (discrete_uom IN VARCHAR) IS
SELECT sy.um_code
FROM mtl_units_of_measure mtl,
     sy_uoms_mst sy
WHERE sy.unit_of_measure = mtl.unit_of_measure
AND   mtl.uom_code = discrete_uom;

/*
Only UNCOMMENT for NON - MINI-E customers
CURSOR c_uom (discrete_uom IN VARCHAR) IS
SELECT sy.um_code
FROM mtl_units_of_measure mtl,
     sy_uoms_mst sy
WHERE sy.um_code = mtl.unit_of_measure
AND   mtl.uom_code = discrete_uom;
*/

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;


OPEN c_uom(p_Apps_UOM);
FETCH c_uom
	INTO x_OPM_UOM;

IF c_uom%NOTFOUND THEN
   FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
   FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_Apps_UOM);
   FND_MSG_PUB.Add;
   CLOSE c_uom;                                  -- Bug 3598280
   RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE c_uom;


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


END Get_OPMUOM_from_AppsUOM;

PROCEDURE Get_AppsUOM_from_OPMUOM(
     p_OPM_UOM                       IN  VARCHAR2
   , x_Apps_UOM                      OUT NOCOPY VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_AppsUOM_from_OPMUOM';


/* For OPM MiniPack E customers */
CURSOR c_uom (process_uom IN VARCHAR) IS
SELECT mtl.uom_code
FROM mtl_units_of_measure mtl,
     sy_uoms_mst sy
WHERE sy.unit_of_measure = mtl.unit_of_measure
AND   sy.um_code = process_uom;

/*
Only UNCOMMENT for NON - MINI-E customers
CURSOR c_uom (process_uom IN VARCHAR) IS
SELECT mtl.uom_code
FROM mtl_units_of_measure mtl,
     sy_uoms_mst sy
WHERE sy.um_code = mtl.unit_of_measure
AND   sy.um_code = process_uom;
*/


BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;


OPEN c_uom(p_OPM_UOM);
FETCH c_uom
	INTO x_Apps_UOM;

IF c_uom%NOTFOUND THEN
   FND_MESSAGE.Set_Name('GMI','GMI_APPS_UOM_NOT_FOUND');
   FND_MESSAGE.Set_Token('OPM_UOM_CODE', p_OPM_UOM);
   FND_MSG_PUB.Add;
   CLOSE c_uom;                                   -- Bug 3598280
   RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE c_uom;


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

END Get_AppsUOM_from_OPMUOM;

PROCEDURE Get_Org_from_SO_Line
   ( p_oe_line_id                    IN  NUMBER
   , x_organization_id               OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Org_from_SO_Line';

CURSOR c_org (oe_line_id IN NUMBER) IS
SELECT ship_from_org_id
FROM  oe_order_lines_all
WHERE line_id = oe_line_id;

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_org line_id='||p_oe_line_id);

OPEN c_org(p_oe_line_id);
FETCH c_org
	INTO x_organization_id;

IF c_org%NOTFOUND THEN
   FND_MESSAGE.Set_Name('GMI','GMI_ORG_NOT_FOUND_IN_OE');
   FND_MESSAGE.Set_Token('SO_LINE_ID', p_oe_line_id);
   FND_MSG_PUB.Add;
   CLOSE c_org;                                      -- Bug 3598280
   RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE c_org;

GMI_reservation_Util.PrintLn('(opm_dbg) in Util Get_org org_id='||x_organization_id);

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

END Get_Org_from_SO_Line;


PROCEDURE Get_OPM_item_from_Apps
   ( p_organization_id               IN  NUMBER
   , p_inventory_item_id             IN  NUMBER
   , x_ic_item_mst_rec               OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_OPM_item_from_Apps';

CURSOR c_item ( discrete_org_id  IN NUMBER
              , discrete_item_id IN NUMBER) IS
SELECT item_id
     , discrete_item_id
     , item_no
     , whse_item_id
     , item_um
     , item_um2
     , dualum_ind
     , alloc_class
     , noninv_ind
     , deviation_lo
     , deviation_hi
     , grade_ctl
     , inactive_ind
     , lot_ctl
     , lot_indivisible
     , loct_ctl
FROM  ic_item_mst
WHERE delete_mark = 0
AND   item_no in (SELECT segment1
	FROM mtl_system_items
	WHERE organization_id   = discrete_org_id
        AND   inventory_item_id = discrete_item_id);

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_item( p_organization_id
           , p_inventory_item_id);
FETCH c_item
        INTO x_ic_item_mst_rec;

IF c_item%NOTFOUND THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: item_no=NOTFOUND inv_item_id='
                 ||p_inventory_item_id||', org_id='||p_organization_id);
   FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
   FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
   FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
   FND_MSG_PUB.Add;
   CLOSE c_item;                             -- Bug 3598280
   RAISE FND_API.G_EXC_ERROR;
ELSE
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: item_no='||x_ic_item_mst_rec.item_no||'.');
END IF;
CLOSE c_item;


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

END Get_OPM_item_from_Apps;

PROCEDURE Reallocate
   ( p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , x_allocated_trans               OUT NOCOPY NUMBER
   , x_allocated_qty                 OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Reallocate';

l_serial_number                      inv_reservation_global.serial_number_tbl_type;
l_partial_reservation_flag           VARCHAR2(2) := FND_API.G_FALSE;
l_quantity_reserved                  NUMBER(19,9);
l_reservation_id                     NUMBER;
l_mtl_reservation_tbl                inv_reservation_global.mtl_reservation_tbl_type;
l_mtl_reservation_rec                inv_reservation_global.mtl_reservation_rec_type;
l_reservation_count                  NUMBER;
l_error_code                         NUMBER;

l_default_lot_index                  BINARY_INTEGER;
l_default_lot_qty                    NUMBER(19,9);
l_default_lot_um                     VARCHAR2(3);
l_primary_reservation_qty            NUMBER(19,9);
l_secondary_reservation_qty          NUMBER(19,9);
l_allocated_transactions             NUMBER;
l_delta_Not_Alloc_qty                NUMBER(19,9);
l_delta_Not_Alloc_qty2               NUMBER(19,9);
l_default_tran_rec                   GMI_TRANS_ENGINE_PUB.ictran_rec;

l_qc_grade                           VARCHAR2(10);
l_trans_qty2                         NUMBER(19,9);
l_trans_um2                          VARCHAR2(4);

-- BUG 3538734
l_organization_id           	     NUMBER;
l_inventory_item_id         	     NUMBER;
l_ctl_ind                            VARCHAR2(1);

/* ====== cursors ============================================================================*/
CURSOR c_sales_order_line (om_line_id IN NUMBER) IS
SELECT preferred_grade,
       ordered_quantity2 * (-1),
       ordered_quantity_uom2,
       ship_from_org_id,                    -- BUG 3538734
       inventory_item_id
FROM oe_order_lines_all
WHERE line_id = om_line_id;


BEGIN

GMI_Reservation_Util.PrintLn('Entering GMI_Reservation_Util.Reallocate');
GMI_Reservation_Util.PrintLn('(opm_dbg) attribute1='||p_query_input.attribute1);
GMI_Reservation_Util.PrintLn('(opm_dbg) attribute2='||p_query_input.attribute2);
GMI_Reservation_Util.PrintLn('(opm_dbg) attribute3='||p_query_input.attribute3);
GMI_Reservation_Util.PrintLn('(opm_dbg) attribute4='||p_query_input.attribute4);
GMI_Reservation_Util.PrintLn('(opm_dbg) reservation_qty= '||p_query_input.reservation_quantity);

/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

SAVEPOINT Reallocate_Transactions;


/* ========================================================== */
/*  Get Process features from the sales order. */
/* ========================================================== */
OPEN c_sales_order_line(p_query_input.demand_source_line_id);
FETCH c_sales_order_line
INTO  l_qc_grade
   ,  l_trans_qty2
   ,  l_trans_um2
   ,  l_organization_id                      -- BUG 3538734
   ,  l_inventory_item_id;

IF (c_sales_order_line%NOTFOUND)
THEN
     GMI_Reservation_Util.printLn('Query SO_line failed with so_line_id='||p_query_input.demand_source_line_id);

     FND_MESSAGE.Set_Name('GMI','GMI_QRY_SO_FAILED');
     FND_MESSAGE.Set_Token('SO_LINE_ID', p_query_input.demand_source_line_id);
     FND_MESSAGE.Set_Token('WHERE', l_api_name);
     FND_MSG_PUB.Add;
     CLOSE c_sales_order_line;               -- Bug 3598280
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
CLOSE c_sales_order_line;


IF (p_query_input.reservation_quantity > 0)
THEN
   /* should use query input quanitity*/
   /* ============================================================================================= */
   /*  Prepare the mtl_reservation_rec in order to call Create_Reservation :*/
   /* ============================================================================================= */
   l_mtl_reservation_rec.reservation_id               := NULL; /*  cannot know  */
   l_mtl_reservation_rec.requirement_date             := p_query_input.requirement_date;
   l_mtl_reservation_rec.organization_id              := p_query_input.organization_id;
   l_mtl_reservation_rec.inventory_item_id            := p_query_input.inventory_item_id;
   l_mtl_reservation_rec.demand_source_type_id 	      := p_query_input.demand_source_type_id;
   l_mtl_reservation_rec.demand_source_name           := NULL;
   l_mtl_reservation_rec.demand_source_header_id      := p_query_input.demand_source_header_id;
   l_mtl_reservation_rec.demand_source_line_id 	      := p_query_input.demand_source_line_id;
   l_mtl_reservation_rec.demand_source_delivery	      := NULL;
   l_mtl_reservation_rec.primary_uom_code             := p_query_input.reservation_uom_code;
   l_mtl_reservation_rec.primary_uom_id               := NULL;
   l_mtl_reservation_rec.reservation_uom_code         := p_query_input.reservation_uom_code;
   l_mtl_reservation_rec.reservation_uom_id           := NULL;
   l_mtl_reservation_rec.reservation_quantity         := p_query_input.reservation_quantity;
   l_mtl_reservation_rec.primary_reservation_quantity := p_query_input.reservation_quantity;
   l_mtl_reservation_rec.autodetail_group_id          := NULL;
   l_mtl_reservation_rec.external_source_code         := NULL;
   l_mtl_reservation_rec.external_source_line_id      := NULL;
   l_mtl_reservation_rec.supply_source_header_id      := NULL;
   l_mtl_reservation_rec.supply_source_line_id        := NULL;
   l_mtl_reservation_rec.supply_source_name           := NULL;
   l_mtl_reservation_rec.supply_source_line_detail    := NULL;
   l_mtl_reservation_rec.revision                     := NULL;
   l_mtl_reservation_rec.subinventory_code            := NULL;
   l_mtl_reservation_rec.subinventory_id              := NULL;
   l_mtl_reservation_rec.locator_id                   := NULL;
   l_mtl_reservation_rec.lot_number                   := NULL;
   l_mtl_reservation_rec.lot_number_id                := NULL;
   l_mtl_reservation_rec.pick_slip_number             := NULL;
   l_mtl_reservation_rec.lpn_id                       := NULL;
   l_mtl_reservation_rec.attribute_category           := NULL;
   l_mtl_reservation_rec.attribute1                   := l_qc_grade;
   l_mtl_reservation_rec.attribute2                   := p_query_input.attribute2;
   l_mtl_reservation_rec.attribute3                   := l_trans_um2;
   /* attribute4 is used for line_detail_id*/
   l_mtl_reservation_rec.attribute4                   := p_query_input.attribute4;
   l_mtl_reservation_rec.attribute5                   := NULL;
   l_mtl_reservation_rec.attribute6                   := NULL;
   l_mtl_reservation_rec.attribute7                   := NULL;
   l_mtl_reservation_rec.attribute8                   := NULL;
   l_mtl_reservation_rec.attribute9                   := NULL;
   l_mtl_reservation_rec.attribute10                  := NULL;
   l_mtl_reservation_rec.attribute11                  := NULL;
   l_mtl_reservation_rec.attribute12                  := NULL;
   l_mtl_reservation_rec.attribute13                  := NULL;
   l_mtl_reservation_rec.attribute14                  := NULL;
   l_mtl_reservation_rec.attribute15                  := NULL;
   l_mtl_reservation_rec.ship_ready_flag              := 2;
   l_mtl_reservation_rec.detailed_quantity            := 0;


   GMI_Reservation_Util.printLn(' (opm_dbg) just before calling Create_Reservation for qty='||
                             l_delta_Not_Alloc_qty||', shed_ship_date='||l_mtl_reservation_rec.requirement_date);
   GMI_Reservation_Util.printLn(' (opm_dbg) more info: qty='||l_mtl_reservation_rec.reservation_quantity||',
                            um='||l_mtl_reservation_rec.reservation_uom_code||',
                            qty2='||l_mtl_reservation_rec.attribute2||', um2='||l_mtl_reservation_rec.attribute3);
   GMI_Reservation_PUB.Create_Reservation
          (  p_api_version_number        => 1.0
           , p_init_msg_lst              => FND_API.G_FALSE
           , x_return_status             => x_return_status
           , x_msg_count                 => x_msg_count
           , x_msg_data                  => x_msg_data
           , p_rsv_rec                   => l_mtl_reservation_rec
           , p_serial_number             => l_serial_number
           , x_serial_number             => l_serial_number
           , p_partial_reservation_flag  => l_partial_reservation_flag
           , p_force_reservation_flag    => FND_API.G_TRUE
           , x_quantity_reserved         => l_quantity_reserved
           , x_reservation_id            => l_reservation_id
           );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) before Transfer_Msg_Stack');
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  /*  At this stage, the Reallocation is done. */
ELSE
   GMI_Reservation_Util.printLn(' (opm_dbg) Nothing to Auto-Detail.');
END IF;   /*  End of l_delta_Not_Alloc_qty >0 */

GMI_RESERVATION_PUB.query_reservation
     (  p_api_version_number        => 1.0
      , p_query_input               => p_query_input
      , x_mtl_reservation_tbl       => l_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count => l_reservation_count
      , x_error_code                => l_error_code
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      );

/*  Return an error if the query reservations call failed */
IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
THEN
        GMI_Reservation_Util.printLn('return error from query reservation');
        FND_MESSAGE.Set_Name('GMI','GMI_QRY_RSV_FAILED');
        FND_MESSAGE.Set_Token('SO_LINE_ID', p_query_input.demand_source_line_id);
        FND_MESSAGE.Set_Token('WHERE', l_api_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

GMI_Reservation_Util.printLn('After Query_Res, count='||l_reservation_count);
IF (l_reservation_count <= 0)
THEN
   IF (l_reservation_count < 0)
   THEN
        GMI_Reservation_Util.printLn('Invalid value for reservation_count='||l_reservation_count);
        FND_MESSAGE.Set_Name('INV','INV_INVALID_COUNT');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   GMI_Reservation_Util.printLn('As nothing reserved, need to build the default_lot rec_type,
                 by querying the sales order, then populate the mtl rec_type');

   l_default_lot_index := 1;

   GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index).qc_grade  := l_qc_grade;
   GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index).trans_qty2:= l_trans_qty2;
   GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index).trans_um2 := l_trans_um2;
   GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index).line_id   := p_query_input.demand_source_line_id;

   l_delta_Not_Alloc_qty := p_query_input.reservation_quantity;
   l_delta_Not_Alloc_qty2 := p_query_input.attribute2;
   l_default_lot_um      := p_query_input.reservation_uom_code;

   GMI_Reservation_Util.PrintLn(' (opm_dbg) Nothing reserved');

ELSE
   GMI_reservation_Util.PrintLn('(opm_dbg) in Reallocate, qty='
                 ||GMI_Reservation_Util.ic_tran_rec_tbl(1).trans_qty||',
                 qty2='||GMI_Reservation_Util.ic_tran_rec_tbl(1).trans_qty2);

   /*  Get the Default Lot, and default lot quantity */
   /*  Retrieve the default lot in the transaction (being aware of the item controls) */
   GMI_Reservation_Util.Get_Default_Lot(
           x_ic_tran_pnd_index        => l_default_lot_index
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Reallocate, ERROR:Returned by Get_Default_Lot.');
      FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC','GMI_Reservation_Util.Get_Default_Lot');
      FND_MESSAGE.Set_Token('WHERE','Reallocate');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Reallocate, qty='
                 ||GMI_Reservation_Util.ic_tran_rec_tbl(1).trans_qty||',
                 qty2='||GMI_Reservation_Util.ic_tran_rec_tbl(1).trans_qty2);
END IF;

l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);

balance_default_lot
   ( p_ic_default_rec            => l_default_tran_rec
   , p_opm_item_id               => l_default_tran_rec.item_id
   , x_return_status             => x_return_status
   , x_msg_count                 => x_msg_count
   , x_msg_data                  => x_msg_data
   );

   -- BEGIN - BUG 3538734
   check_lot_loct_ctl
    ( p_inventory_item_id      => l_inventory_item_id
     ,p_mtl_organization_id    => l_organization_id
     ,x_ctl_ind                => l_ctl_ind
    ) ;

   IF (l_ctl_ind = 'Y') THEN                      --- either lot or location control exists
      select NVL(SUM(ABS(TRANS_QTY)),0)
      into   x_allocated_qty
      from   ic_tran_pnd
      where line_id = p_query_input.demand_source_line_id
      and trans_id <>  l_default_tran_rec.trans_id
      and (lot_id <> 0 or location <> gmi_reservation_util.g_default_loct)
      and doc_type='OMSO'
      and delete_mark =0
      and completed_ind=0;
   ELSE                                           --- no control
      select NVL(SUM(ABS(TRANS_QTY)),0)
      into   x_allocated_qty
      from   ic_tran_pnd
      where line_id = p_query_input.demand_source_line_id
      and lot_id = 0
      and location = gmi_reservation_util.g_default_loct
      and doc_type='OMSO'
      and delete_mark =0
      and completed_ind=0;
   END IF;
   -- END - BUG 3538734

   /* HW 2296620 This is wrong !!!!!
   x_allocated_qty   := l_quantity_reserved; */

   Select count(*)
   INTO x_allocated_trans
   From ic_tran_pnd
   Where line_id = p_query_input.demand_source_line_id
     And line_detail_id = p_query_input.attribute4
     And delete_mark=0;

  GMI_Reservation_Util.printLn('End of GMI_Reservation.Reallocate. No Error, Allocated_qty='||x_allocated_qty);
  GMI_Reservation_Util.printLn('End of GMI_Reservation.Reallocate. No Error, Allocated_transactions='||x_allocated_trans);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT Reallocate_Transactions;
      GMI_Reservation_Util.printLn('End of GMI_Reservation.Reallocate. Error');
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Reallocate_Transactions;
      GMI_Reservation_Util.printLn('End of GMI_Reservation.Reallocate. ErrorOthers');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Reallocate;




PROCEDURE Get_DefaultLot_from_ItemCtl
   ( p_organization_id               IN  NUMBER
   , p_inventory_item_id             IN  NUMBER
   , x_default_lot_index             OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_DefaultLot_from_ItemCtl';

l_ic_item_mst_rec                    GMI_Reservation_Util.ic_item_mst_rec;

-- added by fabdi 10/01/2001
-- fix for bug # 1574957
l_whse_ctl		number;

Cursor get_whse_ctl (org_id IN NUMBER)
IS
select loct_ctl
from ic_whse_mst
where mtl_organization_id = org_id;

-- end fabdi

BEGIN

/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

/*  Get the Default Lot, and default lot quantity */
/*  Retrieve the default lot in the transaction */
GMI_Reservation_Util.Get_Default_Lot(
           x_ic_tran_pnd_index        => x_default_lot_index
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in Get_DefaultLot_from_ItemCtl, ERROR:Returned by Get_Default_Lot.');
   FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC','GMI_Reservation_Util.Get_Default_Lot');
   FND_MESSAGE.Set_Token('WHERE','Get_DefaultLot_from_ItemCtl');
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END IF;

/* ============================================================================================= */
/*  Get Item details */
/* ============================================================================================= */
Get_OPM_item_from_Apps(
           p_organization_id          => p_organization_id
         , p_inventory_item_id        => p_inventory_item_id
         , x_ic_item_mst_rec          => l_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);


GMI_Reservation_Util.printLn('After Get_OPM_Item : item_no='||l_ic_item_mst_rec.item_no);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
   GMI_Reservation_Util.printLn('(opm_dbg) in end of Get_DefaultLot_from_ItemCtl ERROR:Returned by Get_OPM_item_from_Apps.');
   FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
   FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
   FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END IF;


/* ============================================================================================= */
/*  If the Item is NOT lot_ctl and location_ctl, then the default lot qty has to be taken */
/*           ===> the allocated qty includes the default lot qty. */
/*  so I change the value of x_default_lot_index to the opposite ! */
/*  in order to correctly use the following loop. */
/*============================================================================================ */


-- added by fabdi 10/01/2001
-- fix for bug # 1574957
OPEN get_whse_ctl(p_organization_id);
FETCH get_whse_ctl INTO l_whse_ctl;
-- end fabdi

GMI_Reservation_Util.printLn('(opm_dbg) l_whse_ctl='||l_whse_ctl);
/* the correct condition should be lot_ctl and( loct_ctl or whse loct_ctl)*/
IF (l_ic_item_mst_rec.lot_ctl = 0) AND (l_ic_item_mst_rec.loct_ctl = 0 OR l_whse_ctl = 0)
THEN
   x_default_lot_index := (-1) * x_default_lot_index;
END IF;

CLOSE get_whse_ctl;

GMI_Reservation_Util.printLn('(opm_dbg) x_default_lot_index='||x_default_lot_index);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.printLn('End of Get_DefaultLot_from_ItemCtl. Error');
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.printLn('End of Get_DefaultLot_from_ItemCtl. ErrorOthers');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Get_DefaultLot_from_ItemCtl;




PROCEDURE PrintLn
   ( p_msg                           IN  VARCHAR2
   , p_file_name                     IN  VARCHAR2 DEFAULT '0'
   ) IS

CURSOR get_log_file_location IS
SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
FROM v$parameter
WHERE name = 'utl_file_dir';

l_api_name           CONSTANT VARCHAR2 (30) := 'PrintLn';
l_location           VARCHAR2(255);
l_log                UTL_FILE.file_type;
l_debug_level	     VARCHAR2(240) := fnd_profile.value ('ONT_DEBUG_LEVEL');
l_time 		     VARCHAR2(10);
l_file_name	     VARCHAR2(80);

BEGIN


-- WSH_Util_Core.PrintLn(p_msg);
oe_debug_pub.add(p_msg, 1);

/* Hardcode the log file name */
/*IF (p_file_name = '0') THEN
    l_file_name := 'OPMLOG';
ELSE l_file_name := p_file_name;
END IF;*/
/* always write to OPMLOG */
l_file_name := 'OPMLOG';

l_debug_level := NVL(TO_NUMBER(l_debug_level),0);

IF (l_debug_level =  5)
THEN
   l_file_name := l_file_name||FND_GLOBAL.user_id;

   OPEN   get_log_file_location;
   FETCH  get_log_file_location into l_location;
   CLOSE  get_log_file_location;

   l_log := UTL_FILE.fopen(l_location, l_file_name, 'a');
   IF UTL_FILE.IS_OPEN(l_log) THEN
      UTL_FILE.put_line(l_log, p_msg);
      UTL_FILE.fflush(l_log);
      UTL_FILE.fclose(l_log);
   END IF;

   IF (p_file_name <> '0') THEN
     l_file_name := p_file_name||FND_GLOBAL.user_id;

     OPEN   get_log_file_location;
     FETCH  get_log_file_location into l_location;
     CLOSE  get_log_file_location;

     l_log := UTL_FILE.fopen(l_location, l_file_name, 'a');
     IF UTL_FILE.IS_OPEN(l_log) THEN
        UTL_FILE.put_line(l_log, p_msg);
        UTL_FILE.fflush(l_log);
        UTL_FILE.fclose(l_log);
     END IF;
   END IF;

END IF;

EXCEPTION

    WHEN OTHERS THEN
        NULL;

END PrintLn;

PROCEDURE Validation_ictran_rec
   ( p_ic_tran_rec                   IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , x_ic_tran_rec                   OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) Is

l_api_name           CONSTANT VARCHAR2 (30) := 'Validation_ictran_rec';

CURSOR Get_Orgn_Co_from_Whse (whse IN VARCHAR2)
IS
SELECT sy.co_code,
       sy.orgn_code
FROM   sy_orgn_mst sy,
       ic_whse_mst wh
WHERE  sy.orgn_code = wh.orgn_code
AND    wh.whse_code = whse;

BEGIN

   /* ======================================================================= */
   /*  Init variables  */
   /* ======================================================================= */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_ic_tran_rec := p_ic_tran_rec;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_id='||p_ic_tran_rec.trans_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: line_id='||p_ic_tran_rec.line_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: item_id='||p_ic_tran_rec.item_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: co_code='||p_ic_tran_rec.co_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: orgn_code='||p_ic_tran_rec.orgn_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: whse_code='||p_ic_tran_rec.whse_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: lot_id='||p_ic_tran_rec.lot_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: location='||p_ic_tran_rec.location, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: doc_id='||p_ic_tran_rec.doc_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: doc_type='||p_ic_tran_rec.doc_type, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: doc_line='||p_ic_tran_rec.doc_line, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: line_type='||p_ic_tran_rec.line_type, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: reason_code='||p_ic_tran_rec.reason_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_date='||p_ic_tran_rec.trans_date, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_qty='||p_ic_tran_rec.trans_qty, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_qty2='||p_ic_tran_rec.trans_qty2, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: qc_grade='||p_ic_tran_rec.qc_grade, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: lot_no='||p_ic_tran_rec.lot_no, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: sublot_no='||p_ic_tran_rec.sublot_no, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: lot_status='||p_ic_tran_rec.lot_status, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_um='||p_ic_tran_rec.trans_um, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_um2='||p_ic_tran_rec.trans_um2, 'pick_lots.log');
/*    GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: staged_ind='||p_ic_tran_rec.staged_ind, 'pick_lots.log'); */
/*    GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: text_code='||p_ic_tran_rec.text_code, 'pick_lots.log'); */

   IF p_ic_tran_rec.text_code = 0 THEN
     x_ic_tran_rec.text_code := NULL;
   END IF;
   x_ic_tran_rec.staged_ind := 0;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check trans_id ', 'pick_lots.log');
   IF (  p_ic_tran_rec.trans_id = 0
      OR p_ic_tran_rec.trans_id IS NULL
      OR p_ic_tran_rec.trans_id = FND_API.G_MISS_NUM)
   THEN
      x_ic_tran_rec.trans_id := 0;
      GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Set trans_id=0 ', 'pick_lots.log');
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'trans_id');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check item_id ', 'pick_lots.log');
   IF (  p_ic_tran_rec.item_id = 0
      OR p_ic_tran_rec.item_id IS NULL
      OR p_ic_tran_rec.item_id = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'item_id');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check line_id ', 'pick_lots.log');
   IF (  p_ic_tran_rec.line_id = 0
      OR p_ic_tran_rec.line_id IS NULL
      OR p_ic_tran_rec.line_id = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'line_id');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check whse_code ', 'pick_lots.log');
   IF (  p_ic_tran_rec.whse_code = ''
      OR p_ic_tran_rec.whse_code IS NULL
      OR p_ic_tran_rec.whse_code = FND_API.G_MISS_CHAR)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'whse_code');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check co_code/orgn_code ', 'pick_lots.log');

   IF (  p_ic_tran_rec.co_code = ''
      OR p_ic_tran_rec.co_code IS NULL
      OR p_ic_tran_rec.co_code = FND_API.G_MISS_CHAR)
   OR (  p_ic_tran_rec.orgn_code = ''
      OR p_ic_tran_rec.orgn_code IS NULL
      OR p_ic_tran_rec.orgn_code = FND_API.G_MISS_CHAR)
   THEN
      OPEN Get_Orgn_Co_from_Whse(p_ic_tran_rec.whse_code);
      FETCH Get_Orgn_Co_from_Whse
            INTO x_ic_tran_rec.co_code,
                 x_ic_tran_rec.orgn_code;

      IF (Get_Orgn_Co_from_Whse%NOTFOUND)
      THEN
         FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
         FND_MESSAGE.Set_Token('MISSING', 'NOTFOUND co_code/orgn_code');
         FND_MSG_PUB.Add;
         CLOSE Get_Orgn_Co_from_Whse;
         raise FND_API.G_EXC_ERROR;
      END IF;
      CLOSE Get_Orgn_Co_from_Whse;

      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'co_code/orgn_code');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;


   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check lot_id ', 'pick_lots.log');
   IF (  p_ic_tran_rec.lot_id = 0
      OR p_ic_tran_rec.lot_id IS NULL
      OR p_ic_tran_rec.lot_id = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'lot_id');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check location ', 'pick_lots.log');
   IF (  p_ic_tran_rec.location = ''
      OR p_ic_tran_rec.location IS NULL
      OR p_ic_tran_rec.location = FND_API.G_MISS_CHAR)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'location');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check doc_id ', 'pick_lots.log');
   IF (  p_ic_tran_rec.doc_id = 0
      OR p_ic_tran_rec.doc_id IS NULL
      OR p_ic_tran_rec.doc_id = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'doc_id');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check doc_type ', 'pick_lots.log');
   IF (  p_ic_tran_rec.doc_type = ''
      OR p_ic_tran_rec.doc_type IS NULL
      OR p_ic_tran_rec.doc_type = FND_API.G_MISS_CHAR)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'doc_type');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check doc_line ', 'pick_lots.log');
   IF (  p_ic_tran_rec.doc_line = 0
      OR p_ic_tran_rec.doc_line IS NULL
      OR p_ic_tran_rec.doc_line = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'doc_line');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check line_type ', 'pick_lots.log');
   IF (  p_ic_tran_rec.line_type = 0
      OR p_ic_tran_rec.line_type IS NULL
      OR p_ic_tran_rec.line_type = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'line_type');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check trans_qty ', 'pick_lots.log');
   IF (  p_ic_tran_rec.trans_qty = 0
      OR p_ic_tran_rec.trans_qty IS NULL
      OR p_ic_tran_rec.trans_qty = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'trans_qty');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check trans_qty2 ', 'pick_lots.log');
   IF (  p_ic_tran_rec.trans_qty2 = 0
      OR p_ic_tran_rec.trans_qty2 IS NULL
      OR p_ic_tran_rec.trans_qty2 = FND_API.G_MISS_NUM)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'trans_qty2');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check trans_um ', 'pick_lots.log');
   IF (  p_ic_tran_rec.trans_um = ''
      OR p_ic_tran_rec.trans_um IS NULL
      OR p_ic_tran_rec.trans_um = FND_API.G_MISS_CHAR)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'trans_um');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check trans_um2 ', 'pick_lots.log');
   IF (  p_ic_tran_rec.trans_um2 = ''
      OR p_ic_tran_rec.trans_um2 IS NULL
      OR p_ic_tran_rec.trans_um2 = FND_API.G_MISS_CHAR)
   THEN
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'trans_um2');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;

   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: Check trans_date ', 'pick_lots.log');
   IF (  p_ic_tran_rec.trans_date IS NULL
      OR p_ic_tran_rec.trans_date = FND_API.G_MISS_DATE)
   THEN
/*       x_ic_tran_rec.trans_date := sysdate;  */
      FND_MESSAGE.Set_Name('GMI','GMI_MISSING');
      FND_MESSAGE.Set_Token('MISSING', 'trans_date');
      FND_MSG_PUB.Add;
   /*    raise FND_API.G_EXC_ERROR;   */
   END IF;



   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_id='||x_ic_tran_rec.trans_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: line_id='||x_ic_tran_rec.line_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: item_id='||x_ic_tran_rec.item_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: co_code='||x_ic_tran_rec.co_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: orgn_code='||x_ic_tran_rec.orgn_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: whse_code='||x_ic_tran_rec.whse_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: lot_id='||x_ic_tran_rec.lot_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: location='||x_ic_tran_rec.location, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: doc_id='||x_ic_tran_rec.doc_id, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: doc_type='||x_ic_tran_rec.doc_type, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: doc_line='||x_ic_tran_rec.doc_line, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: line_type='||x_ic_tran_rec.line_type, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: reason_code='||x_ic_tran_rec.reason_code, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_date='||x_ic_tran_rec.trans_date, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_qty='||x_ic_tran_rec.trans_qty, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_qty2='||x_ic_tran_rec.trans_qty2, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: qc_grade='||x_ic_tran_rec.qc_grade, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: lot_no='||x_ic_tran_rec.lot_no, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: sublot_no='||x_ic_tran_rec.sublot_no, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: lot_status='||x_ic_tran_rec.lot_status, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_um='||x_ic_tran_rec.trans_um, 'pick_lots.log');
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: trans_um2='||x_ic_tran_rec.trans_um2, 'pick_lots.log');
/*    GMI_reservation_Util.PrintLn('(opm_dbg) in Util.Validation_ictran_rec: staged_ind='||x_ic_tran_rec.staged_ind, 'pick_lots.log'); */

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.printLn('End of Validation_ic_tran_rec. Error', 'pick_lots.log');
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.printLn('End of Validation_ic_tran_rec. ErrorOthers', 'pick_lots.log');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END Validation_ictran_rec;


/* ======================================================================== */
/*  Notes : */
/*        The passed qties are positive */
/*    if trans_id > 0, then : */
/*        If new_qty = 0, then delete reservation */
/*        If new_qty > 0, then update transaction */
/*    if trans_id = 0, then : */
/*        Create a new transaction. */
/*   */
/*    line_id is mandatory in any case. */
/*    when trans_id=0, then whse_code is mandatory. */
/*  */
/*    co_code and orgn_code are null when they are passed by ACCEPT(Pick_Lot) */
/*    doc_line and doc_id are null when they are passed by ACCEPT(Pick_Lot) */
/*  */
/*  Note that each UOM will be in passed in p_ic_tran_rec as AppsUOM (3char). */
/*       Need to be converted back to OPMUOM. */
/*  */
/*  Note2 : If default lot, then the lot_Status has to be null. */
/*  */
/*  The item_id is the OPM one. */
/* ======================================================================== */
PROCEDURE Set_Pick_Lots
   ( p_ic_tran_rec                   IN OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_mo_line_id                    IN  NUMBER
   , p_commit			     IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS


l_api_name                  CONSTANT VARCHAR2(30) := 'Set_Pick_Lots';
l_api_version               CONSTANT VARCHAR2(10) := '1.0';

l_whse_code                 VARCHAR2(4);
l_commit                    VARCHAR2(5) := FND_API.G_FALSE;
l_validation_level          VARCHAR2(4) := FND_API.G_VALID_LEVEL_FULL;
l_validation_flag           VARCHAR2(10) := FND_API.G_TRUE;
l_rsv_rec                   inv_reservation_global.mtl_reservation_rec_type;
l_serial_number             inv_reservation_global.serial_number_tbl_type;
l_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
l_mtl_reservation_tbl_count NUMBER;
l_error_code                NUMBER;
l_default_lot_index         NUMBER;
l_original_tran_index       NUMBER;
l_default_tran_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
l_original_tran_rec         GMI_TRANS_ENGINE_PUB.ictran_rec;
l_ic_tran_rec               GMI_TRANS_ENGINE_PUB.ictran_rec;
ll_ic_tran_rec              GMI_TRANS_ENGINE_PUB.ictran_rec;
l_temp_tran_row             ic_tran_pnd%ROWTYPE;

l_delta_qty1                NUMBER(19,9);
l_delta_qty2                NUMBER(19,9);
-- HW nocopy
l_uom1                      VARCHAR2(4);
l_uom2                      VARCHAR2(4);
/*  For creating the default_lot */
l_organization_id           NUMBER;
l_site_use_id               NUMBER;
l_demand_source_header_id   NUMBER;
l_demand_source_line_id     NUMBER;
l_trans_date                DATE;
l_doc_line                  NUMBER;
l_need_update_default_lot   BOOLEAN;

/*  For Change lot in an existing allocated transaction : */
l_change_lot                BOOLEAN;
l_deleted_qty1              NUMBER(19,9);
l_deleted_qty2              NUMBER(19,9);

/*  For the Allocation rules. */
l_op_alot_prm_rec           op_alot_prm%ROWTYPE;
l_inventory_item_id         NUMBER;
l_ic_item_mst_rec           GMI_Reservation_Util.ic_item_mst_rec;
l_cust_no                   op_cust_mst.cust_no%TYPE;
l_co_code                   op_cust_mst.co_code%TYPE; --B1731567 co_code of cust

/* added by fabdi 20/08/2001 Bug 2023369 */
locked_by_other_user          EXCEPTION;
PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);
l_ic_txn_request_lines         ic_txn_request_lines%ROWTYPE;
l_NEW_ALLOCATED_QTY		NUMBER;
l_NEW_ALLOCATED_QTY2 		NUMBER;
l_whse_ctl			NUMBER;
l_lock_status                   BOOLEAN;

Cursor get_whse_ctl (org_id IN NUMBER)
IS
select loct_ctl
from ic_whse_mst
where mtl_organization_id = org_id;

/* end fabdi */

/* ===CURSOR=============================================================== */
/* B1731567 - Retrieve co_code relating to cust_no
   ==============================================*/
CURSOR c_sales_order_info(so_line_id NUMBER) IS
SELECT sol.ship_from_org_id
     , mtl.sales_order_id
     , sol.line_id
     , sol.schedule_ship_date
     , sol.line_number + (sol.shipment_number / 10)
     , sol.inventory_item_id
     , sol.ship_to_org_id
FROM   oe_order_lines_all sol
     , oe_order_headers_all soh
     , oe_transaction_types_tl tt
     , mtl_sales_orders mtl
WHERE  mtl.segment1 = to_char(soh.order_number)
   AND mtl.segment2  = tt.name
   AND mtl.segment3  = fnd_profile.value('ONT_SOURCE_CODE')
  -- AND tt.language = userenv('LANG') -- OPM bug 3770264
   AND tt.language =  (select language_code   -- OPM bug 3770264
                         from fnd_languages
                         where installed_flag = 'B')
   AND tt.transaction_type_id = soh.order_type_id
   AND soh.header_id = sol.header_id
   AND sol.line_id   = so_line_id ;

Cursor get_cust_no IS
Select opc.cust_no
From op_cust_mst opc
   , sy_orgn_mst som
   , ic_whse_mst whse
Where whse.mtl_organization_id = l_organization_id
  and whse.orgn_code = som.orgn_code
  and som.co_code =opc.co_code
  and opc.of_ship_to_site_use_id(+) = l_site_use_id ;

l_pick_slip_number NUMBER;

BEGIN

/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;
SAVEPOINT Accept_Pick_Lots;

l_need_update_default_lot := TRUE;
l_change_lot              := FALSE;

ll_ic_tran_rec := p_ic_tran_rec;

GMI_reservation_Util.PrintLn('Entering Set_Pick_Lots, trans_date='||to_char(p_ic_tran_rec.trans_date, 'DD/MM/YYYY HH24:MI:SS'));
GMI_reservation_Util.PrintLn('                        reason_code='||p_ic_tran_rec.reason_code);

/* do this first to resolve a performance issue  1846396*/
/* do nothing if no real allocations */
IF (nvl(ll_ic_tran_rec.trans_id,0) = 0 AND nvl(ll_ic_tran_rec.trans_qty,0) = 0) THEN
  RETURN;
END IF;

IF (NVL(ll_ic_tran_rec.line_id, 0) <= 0)
THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Because trans_line_id (='||ll_ic_tran_rec.line_id||') is not >0');
   FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Validation_ictran_rec');
   FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
ELSE
   /* ================================================================ */
   /*  Init variables before calling QueryReservation: */
   /* ================================================================ */
   OPEN c_sales_order_info(ll_ic_tran_rec.line_id);
   /* B1731567 - retrieve co_code relating to cust_no */
   FETCH c_sales_order_info
   INTO l_organization_id
      , l_demand_source_header_id
      , l_demand_source_line_id
      , l_trans_date
      , l_doc_line
      , l_inventory_item_id
      , l_site_use_id ;

   IF (c_sales_order_info%NOTFOUND)
   THEN
      CLOSE c_sales_order_info;
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots : sales_order(line_id='||ll_ic_tran_rec.line_id||')=NOTFOUND', 'pick_lots.log');
      FND_MESSAGE.Set_Name('GMI','GMI_QRY_SO_FAILED');
      FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
      FND_MESSAGE.Set_Token('SO_LINE_ID', ll_ic_tran_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots FOUND: line_id='||ll_ic_tran_rec.line_id||'.', 'pick_lots.log');
   END IF;
   CLOSE c_sales_order_info;

   ll_ic_tran_rec.doc_id     := l_demand_source_header_id;

   /*  The date is passed by the ICPCKLOT.fmb, so I don't overwrite it. */
   /*  B1471071, odaboval 15-Nov-2000 : Set the transaction date to the schedule ship date when it is null. */
   IF (ll_ic_tran_rec.trans_date IS NULL)
   THEN
       ll_ic_tran_rec.trans_date := l_trans_date;
   END IF;
   ll_ic_tran_rec.doc_line    := l_doc_line;

   /* ============================================================================================= */
   /*  Get whse, and organization code from Process.               */
   /* ============================================================================================= */
   INV_GMI_RSV_Branch.Get_Process_Org(
          p_organization_id     => l_organization_id,
          x_opm_whse_code       => l_whse_code,
          x_opm_co_code         => ll_ic_tran_rec.co_code,
          x_opm_orgn_code       => ll_ic_tran_rec.orgn_code,
          x_return_status       => x_return_status );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     OR (l_whse_code <> ll_ic_tran_rec.whse_code)
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_Util.Set_Pick_Lots ERROR:Returned by Get_Process_Org.');
      FND_MESSAGE.Set_Name('GMI','GMI_GET_PROCESS_ORG');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', l_organization_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_co_code := ll_ic_tran_rec.co_code;
   /* ============================================================================================= */
   /*  Get Item details*/
   /* =============================================================================================*/
   GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Entering Validation_For_Query. item_id='||l_inventory_item_id);
   Get_OPM_item_from_Apps(
           p_organization_id          => l_organization_id
         , p_inventory_item_id        => l_inventory_item_id
         , x_ic_item_mst_rec          => l_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', l_organization_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', l_inventory_item_id);
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   /*  B1390816, odaboval 16-Nov-2000 : Added a check on the Horizon period. */
   /* ======================================================================= */
   /*  Check : Allocation Rules Validity */
   /* ======================================================================= */

   OPEN get_cust_no;
   FETCH get_cust_no INTO l_cust_no;
   /* B1731567 - retrieve co_code relating to cust_no */
   IF get_cust_no%NOTFOUND THEN
      GMI_reservation_Util.PrintLn('cust_no not found whse co_code/site_use_id ');
      CLOSE get_cust_no;
   ELSE
      CLOSE get_cust_no;                                   -- Bug 3598280
      GMI_ALLOCATION_RULES_PVT.GET_ALLOCATION_PARMS
                           ( p_co_code       => l_co_code, --B1731567
                             p_cust_no       => l_cust_no,
                             p_alloc_class   => l_ic_item_mst_rec.alloc_class,
                             x_op_alot_prm   => l_op_alot_prm_rec,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                            );

      /*  if no allocation rules found, then Raise Exception and return  */
      /* ------------------------------------------------------------------------ */
      IF ((l_op_alot_prm_rec.alloc_class = ' ') OR
         (l_op_alot_prm_rec.delete_mark = 1))
      THEN
         GMI_Reservation_Util.PrintLn('(opm_dbg) allocation - Error missing  allocation parms',1);
         FND_MESSAGE.SET_NAME('GML','GML_NO_ALLOCATION_PARMS');
         FND_MESSAGE.SET_TOKEN('ALLOC_CLASS', l_ic_item_mst_rec.alloc_class);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*  It is not possible to allocate (create/update) if the period between  */
      /*   trans_date and sysdate is greater than the Horizon period. */
      /* --------------------------------------------------------------------- */
      IF (l_op_alot_prm_rec.alloc_horizon > 0) AND
         (p_ic_tran_rec.trans_date > (SYSDATE + l_op_alot_prm_rec.alloc_horizon))
      THEN
         GMI_Reservation_Util.PrintLn('(opm_dbg) allocation horizon is out - using '|| l_op_alot_prm_rec.alloc_horizon||' days.');
         GMI_Reservation_Util.PrintLn('(opm_dbg) do allocate from sysdate > ' || (p_ic_tran_rec.trans_date + l_op_alot_prm_rec.alloc_horizon));
         GMI_Reservation_Util.PrintLn('(opm_dbg) or choose trans_date < '|| (SYSDATE + l_op_alot_prm_rec.alloc_horizon));
         FND_MESSAGE.SET_NAME('GML','SO_E_ALLOC_HORIZON_ERR');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*  ==================================================================== */
      /*  End of check : trans_date validity */
      /* ===================================================================== */
   END IF;

END IF;

/* ============================================================================================== */
/*  Convert the Apps UOM into OPM UOM.(because ICPCKLOT.fmb always gives a rec_type with Apps UOM (char3)) */
/* ============================================================================================== */

IF (ll_ic_tran_rec.trans_um is not NULL)
THEN
-- HW nocopy replaced ll_ic_tran_rec.trans_um with l_uom1
   Get_OPMUOM_from_AppsUOM(
           p_Apps_UOM                 => ll_ic_tran_rec.trans_um
         , x_OPM_UOM                  => l_uom1
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

ll_ic_tran_rec.trans_um :=l_uom1;
   GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: trans_um='||ll_ic_tran_rec.trans_um||'.', 'pick_lots.log');
END IF;

IF (ll_ic_tran_rec.trans_um2 is not NULL)
THEN
   Get_OPMUOM_from_AppsUOM(
           p_Apps_UOM                 => ll_ic_tran_rec.trans_um2
         , x_OPM_UOM                  => l_uom2
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);
ll_ic_tran_rec.trans_um2:=l_uom2;
   GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: trans_um2='||ll_ic_tran_rec.trans_um2||'.', 'pick_lots.log');
END IF;


/* ============================================================================================== */
/*   So I need to get the Reservations, and find out where is the default lot. */
/* ============================================================================================== */
IF (ll_ic_tran_rec.line_id > 0)
THEN
   l_rsv_rec.organization_id         := l_organization_id;
   l_rsv_rec.demand_source_header_id := l_demand_source_header_id;
   l_rsv_rec.demand_source_line_id   := l_demand_source_line_id;

   l_validation_flag := FND_API.G_FALSE;

   GMI_reservation_pub.Query_reservation
           (  p_api_version_number        => 1.0
            , p_init_msg_lst              => FND_API.G_FALSE
            , x_return_status             => x_return_status
            , x_msg_count                 => x_msg_count
            , x_msg_data                  => x_msg_data
            , p_validation_flag           => l_validation_flag
            , p_query_input               => l_rsv_rec
            , p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
            , x_mtl_reservation_tbl       => l_mtl_reservation_tbl
            , x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count
            , x_error_code                => l_error_code
            , p_lock_records              => FND_API.G_FALSE
            , p_sort_by_req_date          => INV_RESERVATION_GLOBAL.G_QUERY_NO_SORT
            );

   /* ======================================================================================= */
   /*  There may not be any rows, and it should be possible ! (if not auto-allocate before) */
   /*  Case where Nothing is Reserved.   */
   /* ======================================================================================= */
   IF (GMI_Reservation_Util.ic_tran_rec_tbl.COUNT = 0)
   THEN
         GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: No Error but No Rows Found in reservation', 'pick_lots.log');
         /*      Create the default lot */
         GMI_Reservation_Util.Create_Empty_Default_Lot
               ( p_ic_tran_rec        => ll_ic_tran_rec
               , p_organization_id    => l_organization_id
               , x_default_lot_index  => l_default_lot_index
               , x_return_status      => x_return_status
               , x_msg_count          => x_msg_count
               , x_msg_data           => x_msg_data);

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Returned by Create_Empty_Default_Lot(1).', 'pick_lots.log');
           FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
           FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Create_Empty_Default_Lot');
           FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         l_need_update_default_lot := FALSE;

         /* ======================================================================================= */
         /*  At this stage, the Query_Reservation has been called by reate_Empty_Default_Lot */
         /*     to update the memory table GMI_Reservation_Util.ic_tran_rec_tbl. */
         /* ======================================================================================= */

   END IF;

   /*  There may have been a problem getting the rows */
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Returned by Query_Reservation.', 'pick_lots.log');
     FND_MESSAGE.SET_NAME('GMI','GMI_QRY_RSV_FAILED');
     FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
     FND_MESSAGE.Set_Token('SO_LINE_ID', l_rsv_rec.demand_source_line_id);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   /*  At this point the table should have rows */
   IF (GMI_Reservation_Util.ic_tran_rec_tbl.COUNT > 0)
   THEN
      /*  Retrieve the default lot transaction we'll need it later */
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: we have rows now calling Get_Default_Lot.', 'pick_lots.log');
      GMI_Reservation_Util.Get_Default_Lot(
           x_ic_tran_pnd_index        => l_default_lot_index
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Returned by Get_Default_Lot.', 'pick_lots.log');
        FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
        FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Default_Lot');
        FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* ============================================================================================= */
      /*  Lock rows in ic_loct_inv. */
      /* ============================================================================================= */
      -- Bug 2749329 Do not lock. Lock_inventory call and return handling is commented.
/*
      GMI_Locks.Lock_Inventory(
               i_item_id               => ll_ic_tran_rec.item_id
             , i_whse_code             => ll_ic_tran_rec.whse_code
             , o_lock_status           => l_lock_status
             );

      IF (l_lock_status = FALSE) THEN
             GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots ERROR:Returned by Lock_Inventory.');
             FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
             FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Locks.Lock_Inventory');
             FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: default_lot_index='||l_default_lot_index, 'pick_lots.log');
      /* ======================================================================================= */
      /*  Case where a reservation has been called but the default lot is not created. */
      /*  Need to create a default lot : */
      /* ======================================================================================= */
      IF (l_default_lot_index=0)
      THEN
         GMI_Reservation_Util.Create_Empty_Default_Lot
               ( p_ic_tran_rec        => ll_ic_tran_rec
               , p_organization_id    => l_organization_id
               , x_default_lot_index  => l_default_lot_index
               , x_return_status      => x_return_status
               , x_msg_count          => x_msg_count
               , x_msg_data           => x_msg_data);

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Returned by Create_Empty_Default_Lot(2).', 'pick_lots.log');
           FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
           FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Create_Empty_Default_Lot');
           FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         l_need_update_default_lot := FALSE;

         /* ======================================================================================= */
         /*  At this stage, the Query_Reservation has been called by reate_Empty_Default_Lot */
         /*     to update the memory table GMI_Reservation_Util.ic_tran_rec_tbl. */
         /* ======================================================================================= */

      END IF;
      /*  Populate local default row to hold values for comparision */
      l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);

      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots u:: saved default transaction to local rec.', 'pick_lots.log');

      /* ============================================================================================== */
      /*  Populate the rec_types (with the original values) and make the choices. */
      /* ============================================================================================== */
      IF (ll_ic_tran_rec.trans_id >0)
      THEN
         /* ============================================================================================== */
         /*  At this stage, it is either a delete (allocated transaction) or an update (default lot transaction) : */
         /*  Make the choice here : */
         /* ============================================================================================== */
         /*  --------------------------------------------------------------------------------------- */
         /*  Populate local original rec to hold values for comparision */
         /*  if this is not the default rec copy the original rec to l_original_tran_rec */
         /*  else this is the default rec copy the default rec to l_original_tran_rec */
         /*  --------------------------------------------------------------------------------------- */
         GMI_reservation_Util.PrintLn('opm_dbg) in Set_Pick_Lots: l_default_tran_rec.trans_id is ' || l_default_tran_rec.trans_id, 'pick_lots.log');
         GMI_reservation_Util.PrintLn('opm_dbg) in Set_Pick_Lots: p_original_rsv_rec.reservation_id is ' || ll_ic_tran_rec.trans_id, 'pick_lots.log');
         IF (l_default_tran_rec.trans_id <> ll_ic_tran_rec.trans_id)
         THEN
            /*  This is NOT the default lot. */
            GMI_Reservation_Util.Get_Allocation(
                              p_trans_id          => ll_ic_tran_rec.trans_id
                             ,x_ic_tran_pnd_index => l_original_tran_index
                             ,x_return_status     => x_return_status
                             ,x_msg_count         => x_msg_count
                             ,x_msg_data          => x_msg_data);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Returned by Get_Allocation.', 'pick_lots.log');
               FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
               FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Allocation');
               FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Not updating the default, save orig trans to local rec.', 'pick_lots.log');
            l_original_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_original_tran_index);
         ELSE
            GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Updating the default, save default trans to local rec.', 'pick_lots.log');
            l_original_tran_rec := l_default_tran_rec;
         END IF;
      ELSE
         /* ==============================================================================================*/
         /*  trans_id = 0, So create transaction. */
         /* ============================================================================================== */
         l_ic_tran_rec         := ll_ic_tran_rec;

         GMI_Reservation_Util.Validation_ictran_rec
                             (p_ic_tran_rec       => ll_ic_tran_rec
                             ,x_ic_tran_rec       => l_ic_tran_rec
                             ,x_return_status     => x_return_status
                             ,x_msg_count         => x_msg_count
                             ,x_msg_data          => x_msg_data);

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error Returned by Validation_ictran_rec.', 'pick_lots.log');
            FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Validation_ictran_rec');
            FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_ic_tran_rec.doc_id  := l_demand_source_header_id;
         l_ic_tran_rec.line_id := l_demand_source_line_id;

         ll_ic_tran_rec := l_ic_tran_rec;
      END IF;
   ELSE
      /* ============================================================================================== */
      /*  Nothing reserved. */
      /*  This case may cause a pb, if there is an allocated transaction manually created without default lot created. */
      /*                    I may need to call Create_reservation in this case !. */
      /*                    Or create the default lot.  */
      /*  Shouldn't go here !!! */
      /* ============================================================================================== */
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Nothing Reserved (PROBLEM?).', 'pick_lots.log');
      l_default_lot_index := 0;
   END IF;
END IF;

/* ==============================================================================================*/
/*  Process the Transaction : */
/*    Update Transaction (either update qty - if no Change lot, or Delete/Create - if Change lot) */
/*    Delete Transaction */
/*    Create a new transaction */
/* ============================================================================================== */
GMI_reservation_Util.PrintLn('(opm_dbg)in Set_Pick_Lots: What to do : trans_id='||ll_ic_tran_rec.trans_id||', trans_qty='||ll_ic_tran_rec.trans_qty||', trans_date='||ll_ic_tran_rec.trans_date, 'pick_lots.log');
IF (ll_ic_tran_rec.trans_id > 0 AND ll_ic_tran_rec.trans_qty <>0)
THEN
   IF (l_original_tran_rec.lot_id = p_ic_tran_rec.lot_id)
      AND (l_original_tran_rec.location = p_ic_tran_rec.location)
   THEN
      /* ======================================================= */
      /*  Calculate the delta: */
      /*  Note that delta should be <0. */
      /*  If it is >0, We won't have to update the default lot. NO*/
      /*  If it is >0, update the default qty = 0 NO*/
      /* ======================================================= */
      l_delta_qty1 := l_original_tran_rec.trans_qty  + ll_ic_tran_rec.trans_qty;
      l_delta_qty2 := l_original_tran_rec.trans_qty2 + ll_ic_tran_rec.trans_qty2;

      /* ======================================================= */
      /*  Beginning of the process */
      /*  Note that in ll_ic_tran_rec, qties are >0 */
      /* ======================================================= */
      l_original_tran_rec.trans_qty  := (-1) * ll_ic_tran_rec.trans_qty;
      l_original_tran_rec.trans_qty2 := (-1) * ll_ic_tran_rec.trans_qty2;
      l_original_tran_rec.trans_date := ll_ic_tran_rec.trans_date;
      l_original_tran_rec.reason_code := ll_ic_tran_rec.reason_code;
      GMI_reservation_Util.PrintLn('(opm_dbg)in Set_Pick_Lots: Update the transaction qty to:' || l_original_tran_rec.trans_qty , 'pick_lots.log');
      GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
             p_api_version      => 1.0
            ,p_init_msg_list    => FND_API.G_FALSE
            ,p_commit           => l_commit
            ,p_validation_level => l_validation_level
            ,p_tran_rec         => l_original_tran_rec
            ,x_tran_row         => l_temp_tran_row
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.', 'pick_lots.log');
         GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
         FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
         FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
         FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      /*  Need to delete the Original transaction, and then create a new one. */
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_Lots: Change of Lot...', 'pick_lots.log');
      l_change_lot := TRUE;
   END IF;
END IF;

/* ========================================================================= */
/*  trans_id >0, and Qty = 0, then delete the transaction */
/* ========================================================================= */
IF (ll_ic_tran_rec.trans_id > 0 AND ll_ic_tran_rec.trans_qty = 0)
    OR (l_change_lot = TRUE)
THEN
   GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, Before calling Delete_Reservation', 'pick_lots.log');

   /* ========================================================================= */
   /*  Init variables (l_rsv_rec has already been setup)*/
   /* ========================================================================= */
   l_rsv_rec.reservation_id := ll_ic_tran_rec.trans_id;

   GMI_Reservation_PVT.Delete_Reservation(
        x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_validation_flag           => l_validation_flag
      , p_rsv_rec    	            => l_rsv_rec
      , p_serial_number             => l_serial_number
   );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, Error returned by Delete_Reservation, Error='||x_return_status, 'pick_lots.log');
      FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_PVT.Delete_Reservation');
      FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

END IF;

/* ========================================================================= */
/*  trans_id =0, and Qty > 0, then create a new OMSO transaction */
/* ========================================================================= */
IF (ll_ic_tran_rec.trans_id = 0 AND ll_ic_tran_rec.trans_qty <> 0)
    OR (l_change_lot = TRUE)
THEN
   GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, Before creating new transaction', 'pick_lots.log');
   IF (l_change_lot = FALSE)
   THEN
      l_original_tran_rec := l_ic_tran_rec;
   ELSE
      l_original_tran_rec := ll_ic_tran_rec;
      l_original_tran_rec.trans_id := null;
   END IF;

   /* ======================================================= */
   /*  Beginning of the process */
   /*    By security, the lot_status is set to null. (04-Sept-2000) */
   /* ======================================================= */
   l_original_tran_rec.doc_type   := 'OMSO';
   /* hverddin Commented out lot_staus defaulting
      l_original_tran_rec.lot_status := null;
      For Bug 1790512 18-MAY-01
   */
   l_original_tran_rec.event_id   := null;
   l_original_tran_rec.text_code  := null;
   l_original_tran_rec.trans_qty  := (-1) * ll_ic_tran_rec.trans_qty;
   l_original_tran_rec.trans_um   := ll_ic_tran_rec.trans_um;
   l_original_tran_rec.trans_qty2 := (-1) * ll_ic_tran_rec.trans_qty2;
   l_original_tran_rec.trans_um2  := ll_ic_tran_rec.trans_um2;

gmi_reservation_util.println('Value of l_original_tran_rec.trans_qty is '||l_original_tran_rec.trans_qty);
gmi_reservation_util.println('Value of l_original_tran_rec.trans_qty2 is '||l_original_tran_rec.trans_qty2);
gmi_reservation_util.println('Value of    l_original_tran_rec.trans_um is '||   l_original_tran_rec.trans_um);
gmi_reservation_util.println('Value of    l_original_tran_rec.trans_um2 is '||   l_original_tran_rec.trans_um2);
   GMI_reservation_Util.PrintLn('(opm_dbg)in Set_Pick_Lots: Create the new transaction :', 'pick_lots.log');
   GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION(
             p_api_version      => 1.0
            ,p_init_msg_list    => FND_API.G_FALSE
            ,p_commit           => l_commit
            ,p_validation_level => l_validation_level
            ,p_tran_rec         => l_original_tran_rec
            ,x_tran_row         => l_temp_tran_row
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in Set_Pick_lots: Error returned by GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION.', 'pick_lots.log');
      GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
      FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
      FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Begin enhancement 1928979 - lakshmi swamy */

   IF (p_mo_line_id is NOT NULL) THEN
     GMI_Pick_Release_Util.Create_Manual_Alloc_Pickslip ( l_organization_id , p_mo_line_id,
                                     x_return_status, x_msg_count, x_msg_data, l_pick_slip_number);

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
      WHERE trans_id = l_temp_tran_row.trans_id;
   END IF;
   /* End enhancement 1928979 - lakshmi swamy */

   p_ic_tran_rec.trans_id := l_temp_tran_row.trans_id;

END IF;
/* balancing default lot no matter what action has been taken in allocations */

l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);
balance_default_lot
   ( p_ic_default_rec            => l_default_tran_rec
   , p_opm_item_id               => l_default_tran_rec.item_id
   , x_return_status             => x_return_status
   , x_msg_count                 => x_msg_count
   , x_msg_data                  => x_msg_data
   );

/* added by fabdi 20/08/2001 Bug 2023369 */
   GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, p_ic_tran_rec.line_id= '||p_ic_tran_rec.line_id, 'pick_lots.log');

   GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, p_mo_line_id = '||p_mo_line_id, 'pick_lots.log');
  if p_mo_line_id IS NOT NULL
  THEN
   select *
   into l_ic_txn_request_lines
   from ic_txn_request_lines
   where LINE_ID = p_mo_line_id
   for update OF quantity_detailed, secondary_quantity_detailed NOWAIT;

   OPEN get_whse_ctl(l_organization_id);
   FETCH get_whse_ctl INTO l_whse_ctl;
   CLOSE get_whse_ctl;

   GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, l_ic_item_mst_rec.lot_ctl= '||l_ic_item_mst_rec.lot_ctl, 'pick_lots.log');
   GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, l_organization_id= '||l_organization_id, 'pick_lots.log');

   IF l_ic_item_mst_rec.lot_ctl <> 0
   THEN
    SELECT SUM(ABS(TRANS_QTY)), SUM(ABS(TRANS_QTY2))
    INTO l_NEW_ALLOCATED_QTY, l_NEW_ALLOCATED_QTY2
    from ic_tran_pnd
    where line_id = p_ic_tran_rec.line_id
    and staged_ind = 0
    and completed_ind = 0
    and delete_mark = 0
    and lot_id <> 0
    and doc_type = 'OMSO'
    and line_detail_id in
      (Select delivery_detail_id
       From wsh_delivery_details
       Where move_order_line_id = p_mo_line_id);
   ELSIF ((l_ic_item_mst_rec.loct_ctl * l_whse_ctl) <> 0 )
   THEN
    SELECT SUM(ABS(TRANS_QTY)), SUM(ABS(TRANS_QTY2))
    INTO l_NEW_ALLOCATED_QTY, l_NEW_ALLOCATED_QTY2
    from ic_tran_pnd
    where line_id = p_ic_tran_rec.line_id
    and staged_ind = 0
    and completed_ind = 0
    and delete_mark = 0
    and location <> GMI_Reservation_Util.G_DEFAULT_LOCT
    and doc_type = 'OMSO'
    and line_detail_id in
      (Select delivery_detail_id
       From wsh_delivery_details
       Where move_order_line_id = p_mo_line_id);
   ELSE
    SELECT SUM(ABS(TRANS_QTY)), SUM(ABS(TRANS_QTY2))
    INTO l_NEW_ALLOCATED_QTY, l_NEW_ALLOCATED_QTY2
    from ic_tran_pnd
    where line_id = p_ic_tran_rec.line_id
    and staged_ind = 0
    and completed_ind = 0
    and delete_mark = 0
    and doc_type = 'OMSO';
   END IF;

   IF SQL%FOUND THEN
    GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, l_NEW_ALLOCATED_QTY= '||l_NEW_ALLOCATED_QTY, 'pick_lots.log');
    GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, l_NEW_ALLOCATED_QTY2= '||l_NEW_ALLOCATED_QTY2, 'pick_lots.log');

    update ic_txn_request_lines
    set quantity_detailed = nvl(quantity_delivered,0) + NVL(l_NEW_ALLOCATED_QTY,0)
    ,   secondary_quantity_detailed = nvl(secondary_quantity_delivered,0) + NVL(l_NEW_ALLOCATED_QTY2,0)
    where line_id = p_mo_line_id;
   ELSE
    GMI_Reservation_Util.PrintLn('(opm_dbg) In Set_Pick_Lots, Transaction Not Found for= '||p_ic_tran_rec.line_id, 'pick_lots.log');
   END IF;
  END IF;

/* end fabdi */

/*  Oct-2000 : odaboval added the commit in order to solve the problem of switching between ICPCKLOT.fmb's tabs. */
/*             Only commit if called via Apps. (not SQLPLUS) */

 /*  NC - 11/13/01 changed IF(FND_GLOBAL.user_id > 0)  to IF(FND_GLOBAL.user_id >= 0).
          User_id 0 is a valid one( sysadmin). Bug#2108143 .This issue caused problems at numerous customers'.*/
IF (FND_GLOBAL.user_id >= 0)
THEN
   IF ( p_commit = FND_API.G_TRUE)
   THEN
      GMI_Reservation_Util.printLn('End of Set_Pick_Lots. No Error (COMMIT)', 'pick_lots.log');
      COMMIT;
   ELSE
     GMI_Reservation_Util.printLn('End of Set_Pick_Lots. No Error but  Not Commiting as the commit_flag is not set',
				'pick_lots.log');
   END IF;
ELSE
   GMI_Reservation_Util.printLn('End of Set_Pick_Lots. Error (NO COMMIT)','pick_lots.log');
END IF;

    GMI_Reservation_Util.PrintLn('(opm_dbg) END of Set_Pick_Lots', 'pick_lots.log');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT Accept_Pick_Lots;

      GMI_Reservation_Util.printLn('End of Set_Pick_Lots. Error (Rollback)');
      FND_MESSAGE.Set_Name('GMI','UNEXPECTED_ERROR');
      FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
      FND_MESSAGE.Set_Token('WHAT', 'ExpectedError');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN locked_by_other_user
    THEN
      ROLLBACK TO SAVEPOINT Accept_Pick_Lots;
      GMI_Reservation_Util.printLn('End of Set_Pick_Lots. Error (Rollback) -  lock error in Move Order Line', 'pick_lots.log');
      FND_MESSAGE.Set_Name('GMI','UNEXPECTED_ERROR');
      FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
      FND_MESSAGE.Set_Token('WHAT', 'LockError');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Accept_Pick_Lots;

      GMI_Reservation_Util.printLn('End of Set_Pick_Lots. ErrorOthers (Rollback)');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Set_Pick_Lots;

PROCEDURE balance_default_lot
   ( p_ic_default_rec                IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_opm_item_id                   IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS
l_line_rec                  OE_ORDER_PUB.line_rec_type;
l_requested_qty             NUMBER;
l_requested_qty2            NUMBER;
l_order_uom                 VARCHAR2(5);
l_whse_code                 VARCHAR2(5);
l_trans_qty                 NUMBER;
l_trans_qty2                NUMBER;
l_commit                    VARCHAR2(5) := FND_API.G_FALSE;
l_validation_level          VARCHAR2(4) := FND_API.G_VALID_LEVEL_FULL;
l_ic_tran_rec               GMI_TRANS_ENGINE_PUB.ictran_rec;
l_temp_tran_row             ic_tran_pnd%ROWTYPE;
l_organization_id           NUMBER;
l_inventory_item_id         NUMBER;
l_ctl_ind                   VARCHAR2(1) ;
l_opm_item_id               NUMBER;
l_trans_um                  VARCHAR2(5);
l_trans_um2                 VARCHAR2(5);
l_orgn_code                 VARCHAR2(6);

Cursor get_trans_qty IS
Select nvl(sum(trans_qty),0), nvl(sum(trans_qty2),0)
From ic_tran_pnd
Where line_id = l_line_rec.line_id
   And doc_type = 'OMSO'
   And item_id = p_opm_item_id
   And delete_mark = 0
   And (lot_id <> 0
           OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

/* need to consider the non ctl items where after partial ship or stage,
   the default is split only after ship confirm
   a new oe line may or may not be created depends on the situation*/
/* for a default lot, staged=1 means it is shipconfirmed
   completed=1 means it has been interfaced */
Cursor get_trans_qty_non_ctl IS
Select nvl(sum(trans_qty),0), nvl(sum(trans_qty2),0)
From ic_tran_pnd
Where line_id = l_line_rec.line_id
   And doc_type = 'OMSO'
   And item_id = p_opm_item_id
   And (staged_ind = 1 or completed_ind = 1)
   And delete_mark = 0
   And (lot_id = 0 AND location = GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

-- Bug 3829535 added NVL
Cursor get_line_rec IS
Select order_quantity_uom
      ,NVL(ordered_quantity,0)
      ,NVL(ordered_quantity2,0)
      ,ship_from_org_id
      ,inventory_item_id
From  oe_order_lines_all
Where line_id = l_line_rec.line_id;

Cursor get_whse_code IS
Select whse_code
   ,   orgn_code
From ic_whse_mst
Where mtl_organization_id = l_organization_id;

Cursor get_opm_item_id (p_org_id in NUMBER
                      , p_inv_item_id in NUMBER)
       IS
Select ic.item_id
    ,  ic.item_um
    ,  ic.item_um2
From ic_item_mst ic
  ,  mtl_system_items mtl
Where mtl.organization_id = p_org_id
  and mtl.inventory_item_id = p_inv_Item_id
  and mtl.segment1 = ic.item_no;
BEGIN
  l_ic_tran_rec := p_ic_default_rec;
  /* query the line information */
  /*
  OE_Line_Util.Query_Row
              (
              p_line_id  => p_ic_default_rec.line_id,
              x_line_rec => l_line_rec
              );
  Query row was causing a problem at a customer's site. replacing it
  with the follwoing cursor.  - NC 10/26/01 */

  l_line_rec.line_id := p_ic_default_rec.line_id;
  GMI_reservation_Util.PrintLn('(opm_dbg)Balancing the default lot for order line_id: '||l_line_rec.line_id);

  Open get_line_rec;
  Fetch get_line_rec
  INTO l_line_rec.order_quantity_uom
     , l_line_rec.ordered_quantity
     , l_line_rec.ordered_quantity2
     , l_organization_id
     , l_inventory_item_id
     ;
  Close get_line_rec;

  /* get the order uom for OPM */
  Get_OPMUOM_from_AppsUOM
         (
           p_Apps_UOM                 => l_line_rec.order_quantity_uom
         , x_OPM_UOM                  => l_order_uom
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data
         );
  GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, l_order_uom: '||l_order_uom);
  /* with the available of changing item on the order pad, this item_id in the old trans
   * may have been changed, need to fetch the new one
   * bug 3018143
   */
  /* convert the ordered qty to requested qty in item_uom */
  Open get_opm_item_id(l_organization_id, l_inventory_item_id);
  Fetch get_opm_item_id
  Into l_opm_item_id
     , l_trans_um
     , l_trans_um2;
  Close get_opm_item_id;

  -- Bug 3829535 added IF condition
  IF (l_order_uom <> l_trans_um) THEN
      GMI_reservation_Util.PrintLn('(opm_dbg)converting order qty: '||l_line_rec.ordered_quantity||' to item uom '||l_trans_um);
      GMICUOM.icuomcv
         (
           pitem_id  => l_opm_item_id
         , plot_id   => 0
         , pcur_qty  => l_line_rec.ordered_quantity
         , pcur_uom  => l_order_uom
         , pnew_uom  => l_trans_um
         , onew_qty  => l_requested_qty
         );
  ELSE
      l_requested_qty := l_line_rec.ordered_quantity;
  END IF;
  l_requested_qty2 := l_line_rec.ordered_quantity2;
  /* get the total supply qtys */
  l_trans_qty := 0;
  l_trans_qty2 := 0;
  /* see if it is a ctl item */
  GMI_RESERVATION_UTIL.check_lot_loct_ctl
    ( p_inventory_item_id      => l_inventory_item_id
     ,p_mtl_organization_id    => l_organization_id
     ,x_ctl_ind                => l_ctl_ind
    ) ;
  IF l_ctl_ind = 'Y' THEN
     Open get_trans_qty;
     Fetch get_trans_qty INTO l_trans_qty, l_trans_qty2;
     Close get_trans_qty;
  ELSE  -- no ctl
     Open get_trans_qty_non_ctl;
     Fetch get_trans_qty_non_ctl INTO l_trans_qty, l_trans_qty2;
     Close get_trans_qty_non_ctl;
  END IF;

  l_trans_qty := ABS(l_trans_qty);
  l_trans_qty2 := ABS(l_trans_qty2);
  /* demand qtys should be requested - trans */
  l_ic_tran_rec.trans_qty := -1 * (l_requested_qty - l_trans_qty);
  l_ic_tran_rec.trans_qty2 := -1 * (l_requested_qty2 - l_trans_qty2);
  /* if trans_qty is 0 or neg, both would be 0*/
  IF l_ic_tran_rec.trans_qty >= 0 THEN
    l_ic_tran_rec.trans_qty := 0;
    l_ic_tran_rec.trans_qty2 := 0;
  END IF;
  /* if trans_qty2 is 0 or neg, both would be 0*/
  IF l_ic_tran_rec.trans_qty2 >= 0 THEN
    l_ic_tran_rec.trans_qty := 0;
    l_ic_tran_rec.trans_qty2 := 0;
  END IF;

  GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, qty1: '||l_ic_tran_rec.trans_qty);
  GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, qty2: '||l_ic_tran_rec.trans_qty2);

  /* check the whse, if it is changed, simply delete the trans and create a new default */
  Open get_whse_code;
  Fetch get_whse_code
  Into l_whse_code
     , l_orgn_code;
  Close get_whse_code;

  IF (l_whse_code <> l_ic_tran_rec.whse_code OR l_opm_item_id <> p_opm_item_id) THEN
     GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, whse or item change ');
     GMI_reservation_Util.PrintLn('   old whse '||l_whse_code);
     GMI_reservation_Util.PrintLn('   new whse '||l_ic_tran_rec.whse_code);
     GMI_reservation_Util.PrintLn('   old item_id '||l_opm_item_id);
     GMI_reservation_Util.PrintLn('   new item_id '||l_ic_tran_rec.item_id);
     GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION(
                         p_api_version      => 1.0
                        ,p_init_msg_list    => fnd_api.g_false
                        ,p_commit           => l_commit
                        ,p_validation_level => l_validation_level
                        ,p_tran_rec         => l_ic_tran_rec
                        ,x_tran_row         => l_temp_tran_row
                        ,x_return_status    => x_return_status
                        ,x_msg_count        => x_msg_count
                        ,x_msg_data         => x_msg_data);
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d After DELETE_PENDING_TRANSACTION.');
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Delete_Transaction().');
       GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION');
       FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_ic_tran_rec.trans_id := null;
     l_ic_tran_rec.whse_code := l_whse_code;
     l_ic_tran_rec.orgn_code := l_orgn_code;
     l_ic_tran_rec.item_id   := l_opm_item_id;
     l_ic_tran_rec.trans_um  := l_trans_um;
     l_ic_tran_rec.trans_um2 := l_trans_um2;

     GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION(
        p_api_version      => 1.0
       ,p_init_msg_list    => FND_API.G_FALSE
       ,p_commit           => l_commit
       ,p_validation_level => l_validation_level
       ,p_tran_rec         => l_ic_tran_rec
       ,x_tran_row         => l_temp_tran_row
       ,x_return_status    => x_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot (Create DefaultLot): Error returned by GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION.', 'pick_lots.log');
        GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
        FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
        FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
        FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      /* cancel all the reservations for GME */
      GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, cancel reservation for line_id '||l_ic_tran_rec.line_id);
      GML_BATCH_OM_RES_PVT.cancel_res_for_so_line
      (
         P_so_line_id             => l_ic_tran_rec.line_id
       , X_return_status          => x_return_status
       , X_msg_cont               => x_msg_count
       , X_msg_data               => x_msg_data
      ) ;

  ELSE
     GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, update pending trans');
     GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
               (
                p_api_version      => 1.0
               ,p_init_msg_list    => FND_API.G_FALSE
               ,p_commit           => l_commit
               ,p_validation_level => l_validation_level
               ,p_tran_rec         => l_ic_tran_rec
               ,x_tran_row         => l_temp_tran_row
               ,x_return_status    => x_return_status
               ,x_msg_count        => x_msg_count
               ,x_msg_data         => x_msg_data
               );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot:  ERROR');
       GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
       FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
       FND_MESSAGE.Set_Token('WHERE', 'Set_Pick_Lots');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;
  /* if the trans_qty is 0, remove all the outstand GME reservations as well */
      /* cancel all the reservations for GME */
  /*IF l_ic_tran_rec.trans_qty = 0 THEN
      GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, cancel res');
      GML_BATCH_OM_RES_PVT.cancel_res_for_so_line
      (
         P_so_line_id             => l_ic_tran_rec.line_id
       , X_return_status          => x_return_status
       , X_msg_cont               => x_msg_count
       , X_msg_data               => x_msg_data
      ) ;
  END IF;
 */
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    /*   Get message count and data*/
    GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
  WHEN OTHERS THEN
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));

END;

PROCEDURE Create_Empty_Default_Lot
   ( p_ic_tran_rec                   IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_organization_id               IN  NUMBER
   , x_default_lot_index             OUT NOCOPY BINARY_INTEGER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Empty_Default_Lot';
l_api_version               CONSTANT VARCHAR2(10) := '1.0';

l_lock_status           BOOLEAN;
l_validation_flag           VARCHAR2(10) := FND_API.G_TRUE;
l_commit                    VARCHAR2(5) := FND_API.G_FALSE;
l_validation_level          VARCHAR2(4) := FND_API.G_VALID_LEVEL_FULL;

l_temp_tran_row             ic_tran_pnd%ROWTYPE;
l_original_tran_rec         GMI_TRANS_ENGINE_PUB.ictran_rec;
l_rsv_rec                   inv_reservation_global.mtl_reservation_rec_type;
l_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
l_mtl_reservation_tbl_count NUMBER;
l_error_code                NUMBER;

ll_trans_id          NUMBER;

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;


          SAVEPOINT Empty_Default_lot;

          /* ============================================================================================= */
          /*  Create the default Lot. */
          /* ============================================================================================= */
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. Need to create default lot');

          /* ============================================================================================= */
          /*  Lock rows in ic_loct_inv. */
          /* ============================================================================================= */
          GMI_Locks.Lock_Inventory(
               i_item_id               => p_ic_tran_rec.item_id
             , i_whse_code             => p_ic_tran_rec.whse_code
             , o_lock_status           => l_lock_status
             );

          IF (l_lock_status = FALSE) THEN
             GMI_reservation_Util.PrintLn('(opm_dbg) in end of Create_Empty_Default_Lot c ERROR:Returned by Lock_Inventory.');
             FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
             FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Locks.Lock_Inventory');
             FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          /* ============================================================================================= */
          /*  No default lot exist AND MANUAL Allocation. Then create the default lot */
          /* ============================================================================================= */
          /*  Fill the ic_tran_pnd record type, and then insert into ic_tran_pnd */
          l_original_tran_rec.item_id        := p_ic_tran_rec.item_id;
          l_original_tran_rec.line_id        := p_ic_tran_rec.line_id;
          l_original_tran_rec.co_code        := p_ic_tran_rec.co_code;
          l_original_tran_rec.orgn_code      := p_ic_tran_rec.orgn_code;
          l_original_tran_rec.whse_code      := p_ic_tran_rec.whse_code;
          l_original_tran_rec.lot_id         := 0;          /* the default lot */
          l_original_tran_rec.lot_no         := 'NONE';     /* the default lot */
          l_original_tran_rec.location       := GMI_Reservation_Util.G_DEFAULT_LOCT;
          l_original_tran_rec.doc_id         := p_ic_tran_rec.doc_id;
          l_original_tran_rec.doc_type       := 'OMSO';
          l_original_tran_rec.doc_line       := p_ic_tran_rec.doc_line;
          l_original_tran_rec.line_type      := 0;
          l_original_tran_rec.trans_qty      := 0;
          l_original_tran_rec.trans_um       := p_ic_tran_rec.trans_um;
          l_original_tran_rec.trans_qty2     := 0;
          l_original_tran_rec.trans_um2      := p_ic_tran_rec.trans_um2;
          l_original_tran_rec.reason_code    := NULL;
          l_original_tran_rec.trans_date     := p_ic_tran_rec.trans_date;
          l_original_tran_rec.qc_grade       := p_ic_tran_rec.qc_grade;
          l_original_tran_rec.user_id        := FND_GLOBAL.user_id;
          l_original_tran_rec.staged_ind     := 0;
          l_original_tran_rec.event_id       := 0;
          l_original_tran_rec.text_code      := NULL;

          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. item_id='||l_original_tran_rec.item_id);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. line_id='||l_original_tran_rec.line_id);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. co_code='||l_original_tran_rec.co_code);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. orgn_code='||l_original_tran_rec.orgn_code);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. whse_code='||l_original_tran_rec.whse_code);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. location='||l_original_tran_rec.location);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. doc_id='||l_original_tran_rec.doc_id);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. doc_line='||l_original_tran_rec.doc_line);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. trans_um='||l_original_tran_rec.trans_um);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. trans_um2='||l_original_tran_rec.trans_um2);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. trans_date='||l_original_tran_rec.trans_date);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. qc_grade='||l_original_tran_rec.qc_grade);
          GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot. user_id='||l_original_tran_rec.user_id);

          /* =================================================== */
          /*  Check that the default lot doesnt exist. */
          /* =================================================== */
          GMI_Reservation_Util.Default_Lot_Exist
               ( p_line_id        => l_original_tran_rec.line_id
               , p_item_id        => l_original_tran_rec.item_id
               , x_trans_id       => ll_trans_id
               , x_return_status  => x_return_status
               , x_msg_count      => x_msg_count
               , x_msg_data       => x_msg_data);

          IF (ll_trans_id is NULL)
          THEN
             GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION(
                p_api_version      => 1.0
               ,p_init_msg_list    => FND_API.G_FALSE
               ,p_commit           => l_commit
               ,p_validation_level => l_validation_level
               ,p_tran_rec         => l_original_tran_rec
               ,x_tran_row         => l_temp_tran_row
               ,x_return_status    => x_return_status
               ,x_msg_count        => x_msg_count
               ,x_msg_data         => x_msg_data);

             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
             THEN
                GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot (Create DefaultLot): Error returned by GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION.', 'pick_lots.log');
                GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
                FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
                FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
                FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
         ELSE
            GMI_reservation_Util.PrintLn('(opm_dbg) Dont create the default lot again (Shouldnt be here) - 2 ! ');
         END IF;

         GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot (Create DefaultLot): trans_id='||l_temp_tran_row.trans_id, 'pick_lots.log');

         /* ==================================================================================== */
         /*  Need to update the memory table of Reservation. */
         /* ==================================================================================== */
         l_rsv_rec.organization_id         := p_organization_id;
         l_rsv_rec.demand_source_header_id := p_ic_tran_rec.doc_id;
         l_rsv_rec.demand_source_line_id   := p_ic_tran_rec.line_id;

         l_validation_flag := FND_API.G_FALSE;

         GMI_reservation_pub.Query_reservation
           (  p_api_version_number        => 1.0
            , p_init_msg_lst              => FND_API.G_FALSE
            , x_return_status             => x_return_status
            , x_msg_count                 => x_msg_count
            , x_msg_data                  => x_msg_data
            , p_validation_flag           => l_validation_flag
            , p_query_input               => l_rsv_rec
            , p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
            , x_mtl_reservation_tbl       => l_mtl_reservation_tbl
            , x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count
            , x_error_code                => l_error_code
            , p_lock_records              => FND_API.G_FALSE
            , p_sort_by_req_date          => INV_RESERVATION_GLOBAL.G_QUERY_NO_SORT
            );

         /*  There may not be any rows, and it should be possible ! (if not auto-allocate before) */
         IF (GMI_Reservation_Util.ic_tran_rec_tbl.COUNT = 0)
         THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot: No Error but No Rows Found in reservation (ERROR)', 'pick_lots.log');
           FND_MESSAGE.SET_NAME('GMI','GMI_QRY_RSV_FAILED');
           FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
           FND_MESSAGE.Set_Token('SO_LINE_ID', l_rsv_rec.demand_source_line_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         /*  There may have been a problem getting the rows */
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
         THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot: Error Returned by Query_Reservation(2).', 'pick_lots.log');
           FND_MESSAGE.SET_NAME('GMI','GMI_QRY_RSV_FAILED');
           FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
           FND_MESSAGE.Set_Token('SO_LINE_ID', l_rsv_rec.demand_source_line_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot: we have rows now calling Get_Default_Lot.', 'pick_lots.log');
         GMI_Reservation_Util.Get_Default_Lot(
              x_ic_tran_pnd_index        => x_default_lot_index
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data);

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot: Error Returned by Get_Default_Lot.', 'pick_lots.log');
           FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
           FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Default_Lot');
           FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot: default_lot_index='||x_default_lot_index, 'pick_lots.log');
         IF (x_default_lot_index=0)
         THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in Create_Empty_Default_Lot: Still no default lot = ERROR.', 'pick_lots.log');
           FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
           FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Default_Lot');
           FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT Empty_Default_lot;

      GMI_Reservation_Util.printLn('End of Create_Empty_Default_Lot. Error');
      FND_MESSAGE.Set_Name('GMI','UNEXPECTED_ERROR');
      FND_MESSAGE.Set_Token('WHERE', 'Create_Empty_Default_Lot');
      FND_MESSAGE.Set_Token('WHAT', 'ExpectedError');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Empty_Default_lot;

      GMI_Reservation_Util.printLn('End of Create_Empty_Default_Lot. ErrorOthers');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Create_Empty_Default_Lot;

PROCEDURE Default_Lot_Exist
   ( p_line_id                       IN  NUMBER
   , p_item_id                       IN  NUMBER
   , x_trans_id                      OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Default_Lot_Exist';
l_api_version               CONSTANT VARCHAR2(10) := '1.0';

/*  Cursor for Checking the Default Lot existence : */
CURSOR c_default_exist(l_line_id IN NUMBER,
                       l_item_id IN NUMBER) IS
SELECT /*+ INDEX (ic_tran_pnd, ic_tran_pndi3) */trans_id
FROM ic_tran_pnd
WHERE lot_id = 0
AND delete_mark = 0
AND doc_type = 'OMSO'
AND item_id = l_item_id
AND line_id = l_line_id;

BEGIN
/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_default_exist( p_line_id, p_item_id);
FETCH c_default_exist
    INTO x_trans_id;

IF (c_default_exist%NOTFOUND)
THEN
   GMI_Reservation_Util.PrintLn('(opm_dbg) end of Default_Lot_Exist : No default lot, Ok.');
ELSE
   GMI_Reservation_Util.PrintLn('(opm_dbg) end of Default_Lot_Exist : One default lot already, no need to create another one.');
END IF;
CLOSE c_default_exist;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.printLn('End of Default_Lot_Exist. Error');
      FND_MESSAGE.Set_Name('GMI','UNEXPECTED_ERROR');
      FND_MESSAGE.Set_Token('WHERE', 'Default_Lot_Exist');
      FND_MESSAGE.Set_Token('WHAT', 'ExpectedError');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.printLn('End of Default_Lot_Exist. ErrorOthers');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Default_Lot_Exist;

Procedure create_dflt_lot_from_scratch
   ( p_whse_code                     IN VARCHAR2
   , p_line_id                       IN NUMBER
   , p_item_id                       IN NUMBER
   , p_qty1                          IN NUMBER
   , p_qty2                          IN NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS
  l_ictran_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_row     IC_TRAN_PND%ROWTYPE;
  l_uom1         Varchar2(5);
  l_uom2         Varchar2(5);
  l_orgn_code    Varchar2(10);
  l_co_code      Varchar2(10);
  l_whse_code    Varchar2(10);
  l_doc_id       NUMBER;

  Cursor get_orgn_code IS
   Select w.orgn_code, co.co_code
   From ic_whse_mst w, sy_orgn_mst co
   Where w.whse_code = p_whse_code
     AND w.orgn_code = co.orgn_code;
  Cursor get_doc_id IS
   Select mtl.sales_order_id
   From mtl_sales_orders mtl,
     oe_order_lines_all sol,
     oe_order_headers_all soh,
     oe_transaction_types_tl tt
   Where sol.line_id = p_line_id
       AND mtl.segment1 = to_char(soh.order_number)
       AND mtl.segment2 = tt.name
  --     AND tt.language = userenv('LANG') -- OPM bug 3770264
       AND tt.language =  (select language_code   -- OPM bug 3770264
                         from fnd_languages
                         where installed_flag = 'B')
       AND mtl.segment3  = fnd_profile.value('ONT_SOURCE_CODE')
       AND tt.transaction_type_id = soh.order_type_id
       AND sol.header_id = soh.header_id;
  Cursor get_uom IS
    Select item_um, item_um2
    From ic_item_mst
    Where item_id = p_item_id;

  -- BEGIN - Bug 3216096.
  -- Bug 3558787 get line Number as well
Cursor get_line_info (l_line_id IN number) IS
  Select SCHEDULE_SHIP_DATE, line_number+(shipment_number / 10)
  From   oe_order_lines_all
  Where  line_id = l_line_id;

  l_schedule_ship_date DATE;
  l_line_number NUMBER;
  -- END   - Bug 3216096

Begin

   Open get_uom;
   Fetch get_uom Into l_uom1,l_uom2;
   Close get_uom;
   Open get_doc_id;
   Fetch get_doc_id Into l_doc_id;
   Close get_doc_id;
   Open get_orgn_code;
   Fetch get_orgn_code Into l_orgn_code, l_co_code;
   Close get_orgn_code;

   -- BEGIN - Bug 3216096 Bug 3558787 added l_line_number
   -- Get the scheduled to ship date from the line
   Open get_line_info (p_line_id);
   Fetch get_line_info into l_schedule_ship_date, l_line_number;
   Close get_line_info;
   -- END   - Bug 3216096

   GMI_reservation_Util.PrintLn('(opm_dbg) Create_default_lot from scratch','opm.log');
   l_ictran_rec.trans_id        := null;
   l_ictran_rec.lot_id          := 0;
   l_ictran_rec.location        := GMI_Reservation_Util.G_DEFAULT_LOCT;
   l_ictran_rec.trans_qty       := -1 * p_qty1;
   l_ictran_rec.trans_qty2      := -1 * p_qty2;
   l_ictran_rec.qc_grade        := null;
   l_ictran_rec.lot_status      := null;
   l_ictran_rec.trans_date      := l_schedule_ship_date; -- Bug 3216096
   l_ictran_rec.item_id         := p_ITEM_ID;
   l_ictran_rec.line_id         := p_LINE_ID;
   l_ictran_rec.co_code         := l_co_code;
   l_ictran_rec.orgn_code       := l_orgn_code;
   l_ictran_rec.whse_code       := p_whse_code;
   l_ictran_rec.doc_id          := l_doc_id;
   l_ictran_rec.doc_type        := 'OMSO';
   l_ictran_rec.doc_line        := l_line_number;  -- Bug 3558787
   l_ictran_rec.line_type       := 0;      -- Check this value.
   l_ictran_rec.reason_code     := NULL;
   l_ictran_rec.trans_stat      := NULL;
   l_ictran_rec.trans_um        := l_uom1;
   l_ictran_rec.trans_um2       := l_uom2;
   l_ictran_rec.staged_ind      := 0;
   l_ictran_rec.event_id        := 0;
   l_ictran_rec.text_code       := NULL;
   l_ictran_rec.user_id         := NULL;
   l_ictran_rec.create_lot_index := NULL;

   GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
           ( p_api_version      => 1.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_commit           => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , p_tran_rec         => l_ictran_rec
           , x_tran_row         => l_tran_row
           , x_return_status    => x_return_status
           , x_msg_count        => x_msg_count
           , x_msg_data         => x_msg_data
   );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
              return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
     GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
     FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
     FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
     FND_MESSAGE.Set_Token('WHERE','Create_Default_Lot');
     FND_MSG_PUB.Add;
     raise FND_API.G_EXC_ERROR;
  END IF;
END create_dflt_lot_from_scratch;

Procedure create_transaction_for_rcv
   ( p_whse_code                     IN VARCHAR2
   , p_transaction_id                IN NUMBER
   , p_line_id                       IN NUMBER
   , p_item_id                       IN NUMBER
   , p_lot_id                        IN NUMBER
   , p_location                      IN VARCHAR2
   , p_qty1                          IN NUMBER
   , p_qty2                          IN NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

  l_ictran_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_row            IC_TRAN_PND%ROWTYPE;
  l_uom1                Varchar2(5);
  l_uom2                Varchar2(5);
  l_orgn_code           Varchar2(10);
  l_co_code             Varchar2(10);
  l_whse_code           Varchar2(10);
  l_doc_id              NUMBER;
  l_locator_id          NUMBER;
  l_item_loct_ctl       NUMBER;
  l_whse_loct_ctl       NUMBER;
  l_inv_item_id         NUMBER;
  l_cnt                 NUMBER;
  l_msg_data            VARCHAR2(250);
  l_rcv_trans_type      Varchar2(25);
  l_rcv_qty             NUMBER;

  Cursor get_orgn_code IS
   Select w.orgn_code
        , co.co_code
        , w.loct_ctl
   From ic_whse_mst w, sy_orgn_mst co
   Where w.whse_code = p_whse_code
     AND w.orgn_code = co.orgn_code;
  Cursor get_doc_id IS
   Select mtl.sales_order_id
        , sol.inventory_item_id
   From mtl_sales_orders mtl,
     oe_order_lines_all sol,
     oe_order_headers_all soh,
     oe_transaction_types_tl tt
   Where sol.line_id = p_line_id
       AND mtl.segment1 = to_char(soh.order_number)
       AND mtl.segment2 = tt.name
       AND mtl.segment3  = fnd_profile.value('ONT_SOURCE_CODE')
       --AND tt.language = userenv('LANG') -- OPM bug 3770264
       AND tt.language =  (select language_code   -- OPM bug 3770264
                         from fnd_languages
                         where installed_flag = 'B')
       AND tt.transaction_type_id = soh.order_type_id
       AND sol.header_id = soh.header_id;
  Cursor get_uom IS
    Select item_um
         , item_um2
         , loct_ctl
    From ic_item_mst
    Where item_id = p_item_id;

  Cursor get_rcv_trans(p_transaction_id IN NUMBER) IS
    Select transaction_date
        ,  locator_id
        ,  transaction_type
        ,  quantity
        ,  uom_code  --BUG#3503593
    From rcv_transactions
    Where transaction_id = p_transaction_id;
    --BEGIN BUG#3503593
    l_uom_code varchar2(4);
    l_uom    varchar2(25);
    l_qty  NUMBER;
    --END BUG#3503593

  Cursor get_grade IS
    Select qc_grade
    From ic_lots_mst
    Where lot_id = p_lot_id;

  Cursor get_location(p_locator_id IN NUMBER) IS
    Select location
    From ic_loct_mst
    Where inventory_location_id = p_locator_id;

  Cursor get_mtl_location (p_locator_id IN NUMBER
                      ,    p_inventory_item_id IN NUMBER) IS
    Select segment1
    From mtl_item_locations
    Where inventory_location_id = p_locator_id;

  Cursor get_lot_status (p_lot_id IN NUMBER
                  ,      p_whse_code IN VARCHAR2
                  ,      p_location IN VARCHAR2
                  ,      p_item_id  IN NUMBER)
                  IS
    Select lot_status
    From ic_loct_inv
    Where item_id = p_item_id
      and lot_id = p_lot_id
      and location = p_location
      and whse_code = p_whse_code;

  -- BEGIN Bug 3558787 get line Number
  Cursor get_line_info (l_line_id IN number) IS
    Select SCHEDULE_SHIP_DATE, line_number+(shipment_number / 10)
    From   oe_order_lines_all
    Where  line_id = l_line_id;

    l_schedule_ship_date DATE;
    l_line_number NUMBER;
  -- END  Bug 3558787

Begin

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   GMI_reservation_Util.PrintLn('(opm_dbg) entering the trans for rcv ');
   Open get_uom;
   Fetch get_uom
   Into l_uom1
       ,l_uom2
       ,l_item_loct_ctl
       ;
   Close get_uom;
   Open get_doc_id;
   Fetch get_doc_id
   Into l_doc_id
      , l_inv_item_id
        ;
   Close get_doc_id;
   Open get_orgn_code;
   Fetch get_orgn_code
   Into l_orgn_code
      , l_co_code
      , l_whse_loct_ctl
      ;
   Close get_orgn_code;

   -- BEGIN  Bug 3558787 get line Number
   Open get_line_info (p_line_id);
   Fetch get_line_info into l_schedule_ship_date, l_line_number;
   Close get_line_info;
   -- END Bug 3558787


   GMI_reservation_Util.PrintLn('(opm_dbg) Create_lot from scratch');
   l_ictran_rec.location              := NVL(p_location,GMI_Reservation_Util.G_DEFAULT_LOCT);
   l_ictran_rec.trans_id              := null;
   l_ictran_rec.trans_qty             := -1 * p_qty1;
   l_ictran_rec.trans_qty2            := -1 * p_qty2;
   l_ictran_rec.qc_grade              := null;
   l_ictran_rec.lot_status            := null;
   l_ictran_rec.trans_date            := null;
   l_ictran_rec.trans_date            := NULL;
   l_ictran_rec.item_id               := p_ITEM_ID;
   l_ictran_rec.line_id               := p_LINE_ID;
   l_ictran_rec.co_code               := l_co_code;
   l_ictran_rec.orgn_code             := l_orgn_code;
   l_ictran_rec.whse_code             := p_whse_code;
   l_ictran_rec.doc_id                := l_doc_id;
   l_ictran_rec.doc_type              := 'OMSO';
   l_ictran_rec.doc_line              := l_line_number;	 --Bug 3558787
   l_ictran_rec.line_type             := 2;	 -- Bug 3850980 2 is Drop Shipments.
   l_ictran_rec.reason_code           := NULL;
   l_ictran_rec.trans_stat            := NULL;
   l_ictran_rec.trans_um              := l_uom1;
   l_ictran_rec.trans_um2             := l_uom2;
   l_ictran_rec.staged_ind            := 1;
   l_ictran_rec.event_id              := 0;
   l_ictran_rec.non_inv               := 0;
   l_ictran_rec.text_code             := NULL;
   l_ictran_rec.user_id               := NULL;
   l_ictran_rec.create_lot_index      := NULL;
   IF p_lot_id <> 0 THEN
     l_ictran_rec.lot_id                := p_lot_id;
     Open get_grade;
     Fetch get_grade Into l_ictran_rec.qc_grade;
     Close get_grade;
     GMI_RESERVATION_UTIL.println('qc_grade  '||l_ictran_rec.qc_grade);
   ELSE
     l_ictran_rec.lot_id                := 0;
   END IF;

   l_ictran_rec.trans_id := l_tran_row.trans_id;
   GMI_RESERVATION_UTIL.println('trans_id  '||l_ictran_rec.trans_id);
   Open get_rcv_trans (p_transaction_id);
   Fetch get_rcv_trans
   Into l_ictran_rec.trans_date
       ,l_locator_id
       ,l_rcv_trans_type
       ,l_rcv_qty
       ,l_uom_code --BUG#3503593
       ;
   Close get_rcv_trans;

   --BEGIN BUG#3503593
   GMI_RESERVATION_UTIL.Get_OPMUOM_from_AppsUOM(
           p_Apps_UOM                 => l_uom_code
         , x_OPM_UOM                  => l_uom
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

   IF l_ictran_rec.trans_um <> l_uom THEN
     GMICUOM.icuomcv(pitem_id  => l_ictran_rec.item_id ,
                     plot_id   => l_ictran_rec.lot_id,
                     pcur_qty  => p_qty1,
                     pcur_uom  => l_uom,
                     pnew_uom  => l_ictran_rec.trans_um,
                     onew_qty  => l_qty);
     l_ictran_rec.trans_qty   := -1 * l_qty;
   END IF;
   --END BUG#3503593

   IF ( l_rcv_trans_type = 'RETURN TO RECEIVING' or l_rcv_trans_type = 'RETURN TO VENDOR') THEN
     GMI_RESERVATION_UTIL.println('rcv type is return  '||l_rcv_trans_type);
     GMI_RESERVATION_UTIL.println('rcv type is return  , no transactions are created');
     RETURN;
   END IF;
   GMI_RESERVATION_UTIL.println('trans_date  '||l_ictran_rec.trans_date);
   IF nvl(l_locator_id, 0) <> 0 THEN
     IF l_whse_loct_ctl * l_item_loct_ctl = 1 THEN
        Open get_location (l_locator_id);
        Fetch get_location Into l_ictran_rec.location;
        Close get_location;
     ELSE
        Open get_mtl_location (l_locator_id, l_inv_item_id);
        Fetch get_mtl_location Into l_ictran_rec.location;
        Close get_mtl_location;
     END IF;
   END IF;
   --BUG#3503593 Changed CORREET to CORRECT.
   IF ( l_rcv_trans_type = 'CORRECT') THEN
     GMI_RESERVATION_UTIL.println('rcv type is correct  '||l_rcv_trans_type);
     IF( l_rcv_qty < 0 ) THEN
       --BEGIN BUG#3503593
       IF l_ictran_rec.trans_um <> l_uom THEN
         l_ictran_rec.trans_qty := l_qty;
       ELSE
         l_ictran_rec.trans_qty := p_qty1;
       END IF;
       --END BUG#3503593
       l_ictran_rec.trans_qty2  := p_qty2;
     END IF;
   END IF;

   GMI_RESERVATION_UTIL.println('location  '||l_ictran_rec.location);
   GMI_RESERVATION_UTIL.println('lot_id  '||l_ictran_rec.lot_id);
   GMI_RESERVATION_UTIL.println('whse_code  '||l_ictran_rec.whse_code);
   Open get_lot_status(l_ictran_rec.lot_id
                     , l_ictran_rec.whse_code
                     , l_ictran_rec.location
                     , l_ictran_rec.item_id);
   Fetch get_lot_status INTO l_ictran_rec.lot_status;
   IF get_lot_status%NOTFOUND THEN
      l_ictran_rec.lot_status := null;
   END IF;
   Close get_lot_status;
   GMI_RESERVATION_UTIL.println('lot_status  '||l_ictran_rec.lot_status);

   GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
           ( p_api_version      => 1.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_commit           => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , p_tran_rec         => l_ictran_rec
           , x_tran_row         => l_tran_row
           , x_return_status    => x_return_status
           , x_msg_count        => x_msg_count
           , x_msg_data         => x_msg_data
   );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) Error in creating transaction for receiving');
     GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
              return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
     GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
     FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
     FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
     FND_MESSAGE.Set_Token('WHERE','create_transaction_for_rcv');
     FND_MSG_PUB.Add;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_ictran_rec.trans_id := l_tran_row.trans_id;
   GMI_RESERVATION_UTIL.println('trans_id  '||l_ictran_rec.trans_id);

   GMI_RESERVATION_UTIL.println('after create pending transaction  ');
   GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
   (
    p_api_version      =>  1
   ,p_init_msg_list    =>  FND_API.G_FALSE
   ,p_commit           =>  FND_API.G_FALSE
   ,p_validation_level =>  FND_API.G_VALID_LEVEL_FULL
   ,p_tran_rec         =>  l_ictran_rec
   ,x_tran_row         =>  l_tran_row
   ,x_return_status    =>  x_return_status
   ,x_msg_count        =>  x_msg_count
   ,x_msg_data         =>  x_msg_data
   );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN

     GMI_reservation_Util.PrintLn('(opm_dbg) Error return by UPDATE_PENDING_TO_COMPLETED,
              return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
     GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
     FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
     FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED');
     FND_MESSAGE.Set_Token('WHERE','create_transaction_for_rcv');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
      FND_MSG_PUB.count_and_get
       (  p_encoded=> FND_API.G_FALSE
         , p_count  => x_msg_count
         , p_data  => x_msg_data
       );
     for l_cnt in 1..x_msg_count loop
        l_msg_data := FND_MSG_PUB.GET(l_cnt,'F');
        GMI_reservation_Util.PrintLn('for_rcv '||l_msg_data);
     end loop;
      GMI_reservation_Util.PrintLn('for rcv:EXP Error count='||x_msg_count);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  'RESERVATION_UTIL'
                               , 'create_trans_for_rcv'
                              );

      /*   Get message count and data  */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

     for l_cnt in 1..x_msg_count loop
        l_msg_data := FND_MSG_PUB.GET(l_cnt,'F');
        GMI_reservation_Util.PrintLn('for_rcv '||l_msg_data);
     end loop;
      GMI_reservation_Util.PrintLn('for rcv:EXP Error count='||x_msg_count);

END create_transaction_for_rcv;

Procedure get_OPM_account ( v_dest_org_id    IN NUMBER,
                           v_apps_item_id    IN NUMBER,
                           v_vendor_site_id  IN number,
                           x_cc_id           OUT NOCOPY NUMBER,
                           x_ac_id           OUT NOCOPY NUMBER)
IS
l_subinv_type         varchar2(25);
l_dest_sub_inv        VARCHAR2(25);
l_inv_item_type       VARCHAR2(25);
l_asset_subinv        NUMBER;
l_account             number := NULL;
l_accrual_account             number := NULL;
l_vendor_site_id      number;
l_asset_item_flag     VARCHAR2(1);
l_status              varchar2(1);

CURSOR get_asset_flag IS
 Select inventory_asset_flag
 From mtl_system_items
 Where organization_id = v_dest_org_id
   and inventory_item_id = v_apps_item_id;

Cursor get_subinv IS
 Select whse_code
 From ic_whse_mst
 Where mtl_organization_id = v_dest_org_id;

CURSOR Get_asset_sub IS
 Select asset_inventory
 From mtl_secondary_inventories
 Where organization_id        = v_dest_org_id
  and  secondary_inventory_name = l_dest_sub_inv ;
BEGIN
  GMI_reservation_Util.PrintLn('(opm_dbg) dest_org_id '||v_dest_org_id);
  OPEN get_asset_flag;
  FETCH get_asset_flag into l_asset_item_flag ;
  CLOSE get_asset_flag;
  if l_asset_item_flag = 'Y' then
    l_inv_item_type :=  'ASSET';
  else
    l_inv_item_type := 'EXPENSE';
  end if;

  l_dest_sub_inv := null;
  Open get_subinv;
  Fetch get_subinv Into l_dest_sub_inv;
  Close get_subinv;

  GMI_reservation_Util.PrintLn('(opm_dbg) inventory_item_id '|| v_apps_item_id);
  GMI_reservation_Util.PrintLn('(opm_dbg) inv_item_type '|| l_inv_item_type);
  GMI_reservation_Util.PrintLn('(opm_dbg) ventor_site_id '|| v_vendor_site_id);
  GMI_reservation_Util.PrintLn('(opm_dbg) dest_sub_inv '|| l_dest_sub_inv);
  if l_inv_item_type = 'ASSET' then
    if l_dest_sub_inv is not null then
      OPEN get_asset_sub;
      FETCH get_asset_sub into l_asset_subinv ;
      CLOSE get_asset_sub;

      if (l_asset_subinv = 1) then
        l_subinv_type := 'ASSET' ;
      elsif (l_asset_subinv = 2) then
        l_subinv_type  :=  'EXPENSE';
      else
        l_subinv_type := '';
      end if;
    else /* Dest. sub inv is null */
        l_subinv_type := '';
    end if;
  else /* l_inv_item_type = 'EXPENSE' */
    l_subinv_type := '' ;
  end if;

  GMI_reservation_Util.PrintLn('(opm_dbg) subinv_type '|| l_subinv_type);
  GMI_reservation_Util.PrintLn('(opm_dbg) dest_org_id '|| v_dest_org_id);

  if l_inv_item_type = 'ASSET' then
    GML_ACCT_GENERATE.generate_opm_acct
                    ('INVENTORY' ,
                      l_inv_item_type,
                      l_subinv_type,
                      v_dest_org_id,
                      v_apps_item_id,
                      v_vendor_site_id,
                      l_account
                    );
  elsif l_inv_item_type = 'EXPENSE' then
    GML_ACCT_GENERATE.generate_opm_acct
                      ('EXPENSE' ,
                       '',
                       '',
                       v_dest_org_id,
                       v_apps_item_id,
                       v_vendor_site_id,
                       l_account);

 end if;
 GML_ACCT_GENERATE.generate_opm_acct
                      ('ACCRUAL' ,
                       '',
                       '',
                       v_dest_org_id,
                       v_apps_item_id,
                       v_vendor_site_id,
                       l_accrual_account);

 x_cc_id := l_account;
 x_ac_id := l_accrual_account;

END Get_OPM_account;

/* this procedure is created for when booking a so line, a new delviery would be created,
  if user has already allocated inv in order pad, here we would update this trans with
  the new delivery_detail_id */
Procedure check_OPM_trans_for_so_line
        ( p_so_line_id                IN NUMBER,
          p_new_delivery_detail_id    IN NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2)
IS
l_count                 number := 0;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Select count(*)
  INTO l_count
  From ic_tran_pnd
  Where line_id = p_so_line_id
    and doc_type='OMSO'
    and delete_mark=0
    and completed_ind=0
    and staged_ind=0
    and line_detail_id is null
    and (lot_id<>0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

  --B2523798 Add check for location not equal to default location to
  --accomodate for location only items.
  IF l_count <> 0 THEN
     Update ic_tran_pnd
     Set line_detail_id = p_new_delivery_detail_id
     Where line_id = p_so_line_id
       and doc_type='OMSO'
       and delete_mark=0
       and completed_ind=0
       and staged_ind=0
       and line_detail_id is null
       and (lot_id<>0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);
  END IF;
  /* call update reservations for gme */
  GML_BATCH_OM_RES_PVT.check_gmeres_for_so_line
     (    p_so_line_id          => p_so_line_id
        , p_delivery_detail_id  => p_new_delivery_detail_id
        , x_return_status       => x_return_status
     ) ;
END check_OPM_trans_for_so_line;

FUNCTION Get_Opm_converted_qty
(
   p_apps_item_id      IN NUMBER,
   p_organization_id   IN NUMBER,
   p_apps_from_uom     IN VARCHAR2,
   p_apps_to_uom       IN VARCHAR2,
   p_original_qty      IN  NUMBER,
   p_lot_id            IN  NUMBER DEFAULT 0
) RETURN NUMBER IS

l_inventory_item_id                    NUMBER;
l_ic_item_mst_rec                      GMI_RESERVATION_UTIL.ic_item_mst_rec;
l_return_status                        VARCHAR2(30);
l_msg_count                            NUMBER;
l_msg_data                             VARCHAR2(5);
l_opm_from_uom                         VARCHAR2(5);
l_opm_to_uom                           VARCHAR2(5);
l_converted_qty                        NUMBER;
l_epsilon                              NUMBER;
n                                      NUMBER;

-- BEGIN Bug 3776538
l_ALLOW_OPM_TRUNCATE_TXN               VARCHAR2(4);
l_TRUNCATE_TO_LENGTH          CONSTANT INTEGER := 5;
-- END Bug 3776538

BEGIN
  l_inventory_item_id := p_apps_item_id;

  GMI_reservation_Util.PrintLn('in GMI: Get_OPM_converted_qty ');
  GMI_reservation_Util.PrintLn('from uom (APPS) '||p_apps_from_uom);
  GMI_reservation_Util.PrintLn('to uom (APPS) '||p_apps_to_uom);

      GMI_RESERVATION_UTIL.Get_OPM_Item_From_Apps(
      p_organization_id => p_organization_id,
      p_inventory_item_id => l_inventory_item_id,
      x_ic_item_mst_rec => l_ic_item_mst_rec,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      GMI_RESERVATION_UTIL.Get_OPMUOM_from_AppsUOM(
              p_apps_uom         =>p_apps_from_uom,
              x_opm_uom          =>l_opm_from_uom,
              x_return_status    =>l_return_status,
              x_msg_count        =>l_msg_count,
              x_msg_data         =>l_msg_data);
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
          FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_apps_from_uom);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      GMI_reservation_Util.PrintLn('from uom (OPM) '||l_opm_from_uom);
      GMI_RESERVATION_UTIL.Get_OPMUOM_from_AppsUOM(
              p_apps_uom         =>p_apps_to_uom,
              x_opm_uom          =>l_opm_to_uom,
              x_return_status    =>l_return_status,
              x_msg_count        =>l_msg_count,
              x_msg_data         =>l_msg_data);
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('GMI','GMI_OPM_UOM_NOT_FOUND');
          FND_MESSAGE.Set_Token('APPS_UOM_CODE', p_apps_to_uom);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      GMI_reservation_Util.PrintLn('to uom (OPM) '||l_opm_to_uom);

      GMICUOM.icuomcv(
              pitem_id         =>l_ic_item_mst_rec.item_id,
              plot_id          =>p_lot_id,
              pcur_qty         =>p_original_qty,
              pcur_uom         =>l_opm_from_uom,
              pnew_uom         =>l_opm_to_uom,
              onew_qty         =>l_converted_qty);
      IF l_converted_qty < 0 THEN
          GMI_reservation_Util.PrintLn('conversion error code'|| l_converted_qty);
          FND_MESSAGE.Set_Name('GMI','GMICUOM.icuomcv');
          FND_MESSAGE.Set_Token('CONVERSION_ERROR', p_apps_to_uom);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

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

      GMI_reservation_Util.PrintLn('converted_qty '|| l_converted_qty);
      --
      -- Bug 3776538 - See if the converted qty should be trucated rather than rounded!
      --
      l_ALLOW_OPM_TRUNCATE_TXN := nvl(fnd_profile.value ('ALLOW_OPM_TRUNCATE_TXN'),'N');
      GMI_Reservation_Util.PrintLn('Profile: ALLOW_OPM_TRUNCATE_TXN '||l_ALLOW_OPM_TRUNCATE_TXN);
      IF (l_ALLOW_OPM_TRUNCATE_TXN = 'Y') THEN
         l_converted_qty:=trunc(l_converted_qty, l_TRUNCATE_TO_LENGTH);
         GMI_reservation_Util.PrintLn('converted_qty after truncating '|| l_converted_qty);
      ELSE
         l_converted_qty:=round(l_converted_qty, n);
         GMI_reservation_Util.PrintLn('converted_qty after rounding '|| l_converted_qty);
      END IF;
      -- End 3776538


  return l_converted_qty;

END Get_Opm_converted_qty;

Procedure query_staged_flag
 ( x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_staged_flag       OUT NOCOPY VARCHAR2,
   p_reservation_id    IN NUMBER) IS
l_staged_flag NUMBER;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   GMI_reservation_Util.PrintLn('(opm_dbg) trans_id '|| p_reservation_id);
   Select staged_ind
   Into l_staged_flag
   From ic_tran_pnd
   Where trans_id = p_reservation_id;

   IF l_staged_flag = 1 THEN
     x_staged_flag := 'Y';
   ELSE
     x_staged_flag := 'N';
   END IF;
END query_staged_flag;

Procedure find_default_lot
 ( x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_reservation_id    OUT NOCOPY VARCHAR2,
   p_line_id           IN NUMBER) IS

 CURSOR find_trans IS
   Select trans_id
   From ic_tran_pnd
   Where line_id = p_line_id
   And doc_type = 'OMSO'
   And delete_mark = 0
   And completed_ind = 0
   And staged_ind = 0
   And (lot_id = 0
           AND location = GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   GMI_reservation_Util.PrintLn('(opm_dbg) in find_default_lot defaultloc '
   || GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);
   GMI_reservation_Util.PrintLn('(opm_dbg) in find_default_lot line_id '|| p_line_id);
   Open find_trans;
   Fetch find_trans Into x_reservation_id;
   IF find_trans%NOTFOUND THEN
      x_reservation_id := 0;
   END IF;
   Close find_trans;

   GMI_reservation_Util.PrintLn('(opm_dbg) find_default_lot trans_id '|| x_reservation_id);
END find_default_lot;

procedure check_lot_loct_ctl (
    p_inventory_item_id             IN NUMBER
   ,p_mtl_organization_id           IN NUMBER
   ,x_ctl_ind                       OUT NOCOPY VARCHAR2)
IS
  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_lot_ctl                NUMBER;
  l_loct_ctl               NUMBER;
  l_whse_ctl               NUMBER;
  l_inventory_item_id      NUMBER;
  l_organization_id        NUMBER;
  l_whse_code              VARCHAR2(5);

  Cursor Get_item_info IS
  SELECT iim.item_id, iim.lot_ctl, iim.loct_ctl
  FROM   ic_item_mst iim,
         mtl_system_items msi
  WHERE  msi.inventory_item_id = p_inventory_item_id
  AND    msi.organization_id = p_mtl_organization_id
  AND    msi.segment1 = iim.item_no;


BEGIN
    /* get lot_ctl and loct_ctl */
    GMI_reservation_Util.PrintLn('check_lot_loct_ctl for item_id '|| p_inventory_item_id
          ||' for org '||p_mtl_organization_id);
    Open get_item_info;
    Fetch get_item_info
    Into l_item_id
       , l_lot_ctl
       , l_loct_ctl
       ;
    Close get_item_info;

    /* get whse loct_ctl */
    Select loct_ctl
    Into l_whse_ctl
    From ic_whse_mst
    Where mtl_organization_id = p_mtl_organization_id;

    IF l_lot_ctl = 0 AND (l_loct_ctl * l_whse_ctl) = 0 THEN
      x_ctl_ind := 'N';
    ElSE
      x_ctl_ind := 'Y';
    END IF;
    GMI_reservation_Util.PrintLn('check_lot_loct_ctl returning '|| x_ctl_ind);
End check_lot_loct_ctl;

/* this procedure is called by OM for the order lines which are not interfaced with shipping
  -- not yet booked :-...
*/
PROCEDURE split_trans_from_om
   ( p_old_source_line_id      IN  NUMBER,
     p_new_source_line_id      IN  NUMBER,
     p_qty_to_split            IN  NUMBER,    -- remaining qty to the old line_id
     p_qty2_to_split           IN  NUMBER,    -- remaining qty2 to the old line_id
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2)
IS
  l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_new_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_old_transaction_row    ic_tran_pnd%ROWTYPE ;
  l_new_transaction_row    ic_tran_pnd%ROWTYPE;
  l_trans_id               ic_tran_pnd.trans_id%TYPE;
  l_new_trans_id           ic_tran_pnd.trans_id%TYPE;
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

  cursor c_reservations IS
    SELECT trans_id, doc_id
      FROM ic_tran_pnd
     WHERE line_id = p_old_source_line_id
       AND delete_mark = 0
       AND doc_type = 'OMSO'
       AND trans_qty <> 0
       And (lot_id <> 0                 -- only real trans
           OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
     ORDER BY trans_qty desc; /* the smaller qty is at the top, keep in mind it is neg */
                              /* or should consider the alloc rules */
  cursor c_reserved_qty IS
    SELECT abs(sum(trans_qty)),abs(sum(trans_qty2))
      FROM ic_tran_pnd
     WHERE line_id = p_old_source_line_id
       AND delete_mark = 0
       AND completed_ind = 0
       AND staged_ind = 0
       AND doc_type = 'OMSO'
       AND trans_qty <> 0;

  Cursor Get_item_info IS
    Select ic.item_id
         , ic.lot_ctl
         , ic.loct_ctl
    From ic_item_mst ic
       , mtl_system_items mtl
    Where ic.item_no = mtl.segment1
      and mtl.inventory_item_id = l_inventory_item_id
      and mtl.organization_id = l_organization_id;

  /* Begin bug 2871929 */
  Cursor c_order_line_info IS
    SELECT inventory_item_id, Ship_from_org_id
      FROM oe_order_lines_all
     WHERE line_id = p_old_source_line_id;
  /* End bug 2871929 */

BEGIN
    GMI_RESERVATION_UTIL.Println('in split_trans_from OM where order has not been booked');
    GMI_RESERVATION_UTIL.Println(' p_old_source_line_id '||p_old_source_line_id);
    GMI_RESERVATION_UTIL.Println(' p_new_source_line_id '||p_new_source_line_id);
    l_fulfilled_qty := 0;

    /* Begin bug 2871929 */
    /* Variables l_item_id, l_organization_id used in subsequent
       cursors were NOT INITIALIAZED at all */

    Open  c_order_line_info;
    Fetch c_order_line_info INTO l_item_id,l_organization_id;
    Close c_order_line_info;
    /* End bug 2871929 */

    GMI_RESERVATION_UTIL.Println('l_organization_id '||l_organization_id);


    /* get lot_ctl and loct_ctl */
    Open get_item_info;
    Fetch get_item_info
    Into l_item_id
       , l_lot_ctl
       , l_loct_ctl
       ;
    Close get_item_info;

    Open c_reserved_qty;
    Fetch c_reserved_qty
    Into l_orig_qty
       , l_orig_qty2
       ;
    Close c_reserved_qty;
    /* get whse loct_ctl */
    Select loct_ctl
    Into l_whse_ctl
    From ic_whse_mst
    Where mtl_organization_id = l_organization_id;

    l_qty_to_fulfil  := p_qty_to_split;
    l_qty2_to_fulfil := p_qty2_to_split;

    GMI_RESERVATION_UTIL.Println('in split_trans, qty to split'||p_qty_to_split);
    GMI_RESERVATION_UTIL.Println('in split_trans, qty2 to split'||p_qty2_to_split);
    oe_debug_pub.add('Going to find default lot in split_reservation',2);
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
    IF l_trans_id > 0 THEN
       oe_debug_pub.add('Going to find default lot in for new line ',2);
       GMI_RESERVATION_UTIL.find_default_lot
           (  x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              x_reservation_id    => l_new_trans_id,
              p_line_id           => p_new_source_line_id
            );
        IF nvl(l_new_trans_id, 0) =  0 THEN -- B2985470 changed <> to =
        /* if not exist, create a default trans for the new line_id */
        /* this would be just a place holder where trans_qty would be 0 */
        /* trans qty would be udpated when balance default lot is called */
          l_old_transaction_rec.trans_id := l_trans_id;
          IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
            (l_old_transaction_rec, l_old_transaction_rec )
          THEN
             l_new_transaction_rec := l_old_transaction_rec;
             l_new_transaction_rec.trans_id := NULL;
             l_new_transaction_rec.trans_qty := 0;
             l_new_transaction_rec.trans_qty2 := 0;
             l_new_transaction_rec.line_id := p_new_source_line_id;

             GMI_RESERVATION_UTIL.PrintLn('creating the default trans for the new line');
             GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
             ( p_api_version      =>  1
             , p_init_msg_list    =>  FND_API.G_FALSE
             , p_commit           =>  FND_API.G_FALSE
             , p_validation_level =>  FND_API.G_VALID_LEVEL_FULL
             , p_tran_rec         =>  l_new_transaction_rec
             , x_tran_row         =>  l_new_transaction_row
             , x_return_status    =>  x_return_status
             , x_msg_count        =>  x_msg_count
             , x_msg_data         =>  x_msg_data
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS
             THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) Error in creating default transaction ');
               GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
                          return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
               GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
               FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
               FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
               FND_MESSAGE.Set_Token('WHERE','split_trans_from_om');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;
       END IF;
    END IF;

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
          IF abs(l_old_transaction_rec.trans_qty) <= l_qty_to_fulfil THEN
            /* do nothing for the tran */
            GMI_RESERVATION_UTIL.Println('in split_trans, keep trans the same for trans_id '||l_trans_id);
            GMI_RESERVATION_UTIL.Println('in split_trans, trans_qty '||l_old_transaction_rec.trans_qty);
            l_qty_to_fulfil := l_qty_to_fulfil - abs(l_old_transaction_rec.trans_qty);
            l_qty2_to_fulfil := l_qty2_to_fulfil - abs(l_old_transaction_rec.trans_qty2);
          ELSIF abs(l_old_transaction_rec.trans_qty) > l_qty_to_fulfil
                AND l_qty_to_fulfil > 0 THEN

            update ic_tran_pnd
            set trans_qty = -1 * l_qty_to_fulfil
              , trans_qty2 = -1 * l_qty2_to_fulfil
            Where trans_id = l_trans_id;

            /* create a new trans for the new wdd, and new line_id if applicable */
            l_new_transaction_rec := l_old_transaction_rec;
            l_new_transaction_rec.trans_id := NULL;
            l_new_transaction_rec.trans_qty := -1 * (abs(l_new_transaction_rec.trans_qty)
                                              - l_qty_to_fulfil);
            l_new_transaction_rec.trans_qty2 := -1 * (abs(l_new_transaction_rec.trans_qty2)
                                              - l_qty2_to_fulfil);
            l_new_transaction_rec.line_id := p_new_source_line_id;

            GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
            ( p_api_version      =>  1
            , p_init_msg_list    =>  FND_API.G_FALSE
            , p_commit           =>  FND_API.G_FALSE
            , p_validation_level =>  FND_API.G_VALID_LEVEL_FULL
            , p_tran_rec         =>  l_new_transaction_rec
            , x_tran_row         =>  l_new_transaction_row
            , x_return_status    =>  x_return_status
            , x_msg_count        =>  x_msg_count
            , x_msg_data         =>  x_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) Error in creating transaction ');
               GMI_reservation_Util.PrintLn('(opm_dbg) Error return by Create_Pending_Transaction,
                          return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
               GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
               FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
               FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION');
               FND_MESSAGE.Set_Token('WHERE','split_trans_from_om');
               FND_MSG_PUB.Add;

              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            /* no more fulfilment */
            l_qty_to_fulfil := 0;
            l_qty2_to_fulfil := 0;
          ELSIF l_qty_to_fulfil <= 0 THEN
            /* do nothing */
            null;
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
    IF l_trans_id > 0 THEN  -- if it does not exist, don't bother
       l_old_transaction_rec.trans_id := l_trans_id;

       IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
         (l_old_transaction_rec, l_old_transaction_rec )
       THEN
          GMI_RESERVATION_UTIL.PrintLn('balancing default lot for old source line_id '|| p_old_source_line_id);
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
          GMI_RESERVATION_UTIL.PrintLn('balancing default lot for new source line_id '|| p_new_source_line_id);
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
    /* split the reservations if necessary */
    GML_BATCH_OM_RES_PVT.split_reservations_from_om
       ( p_old_source_line_id      => p_old_source_line_id
        ,p_new_source_line_id      => p_new_source_line_id
        ,p_qty_to_split            => p_qty_to_split
        ,p_qty2_to_split           => p_qty2_to_split
        ,p_orig_qty                => l_orig_qty
        ,p_orig_qty2               => l_orig_qty
        ,x_return_status           => x_return_status
        ,x_msg_count               => x_msg_count
        ,x_msg_data                => x_msg_data
       );

    GMI_RESERVATION_UTIL.PrintLn('Exit split_trans_from_OM');
END split_trans_from_om;

-- HW OPM BUG#:2536589 New procedure
PROCEDURE update_opm_trxns(
     p_trans_id                IN NUMBER,
     p_inventory_item_id       IN NUMBER,
     p_organization_id         IN NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2)

 IS

 l_old_transaction_rec   GMI_TRANS_ENGINE_PUB.ictran_rec;
 l_old_transaction_row   ic_tran_pnd%ROWTYPE;

-- HW cursor for cntl items
 CURSOR get_opm_txn_cntl (p_trans_id NUMBER) IS
 SELECT IC.trans_id

 FROM   IC_TRAN_PND IC
 WHERE  IC.trans_id = p_trans_id
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    IC.STAGED_IND = 0
 AND    ( IC.LOT_ID <> 0 OR
          IC.LOCATION <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

 -- Cursor for non-ctl items
CURSOR get_opm_txn_non_cntl (p_trans_id NUMBER) IS
 SELECT IC.trans_id

 FROM   IC_TRAN_PND IC
 WHERE  IC.trans_id = p_trans_id
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    IC.STAGED_IND = 0
 AND    ( IC.LOT_ID = 0 OR
          IC.LOCATION = GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);



l_ctl_ind  VARCHAR2(1);
 BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


 /* see if item is a ctl item */
  GMI_RESERVATION_UTIL.check_lot_loct_ctl
    ( p_inventory_item_id      => p_inventory_item_id
     ,p_mtl_organization_id    => p_organization_id
     ,x_ctl_ind                => l_ctl_ind
    );


  IF l_ctl_ind = 'Y' THEN -- control/location items
    gmi_reservation_util.println('Going to open cursor for lot/location items');
    OPEN get_opm_txn_cntl(p_trans_id);
    FETCH get_opm_txn_cntl into l_old_transaction_rec.trans_id;
    IF get_opm_txn_cntl%NOTFOUND THEN
      CLOSE get_opm_txn_cntl;
      gmi_reservation_util.println('Failed to fetch trans_id in update_opm_trxns for lot/location item= '||p_trans_id);
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    CLOSE get_opm_txn_cntl;

  ELSE  -- non ctl
    gmi_reservation_util.println('Going to open cursor for non-lot/non location');
    OPEN get_opm_txn_non_cntl(p_trans_id);
    FETCH get_opm_txn_non_cntl into l_old_transaction_rec.trans_id;
    IF get_opm_txn_non_cntl%NOTFOUND THEN
      CLOSE get_opm_txn_non_cntl;
      gmi_reservation_util.println('Failed to fetch trans_id in update_opm_trxns for non-lot/non location= '||p_trans_id);
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    CLOSE get_opm_txn_non_cntl;
  END IF;

  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
    (l_old_transaction_rec, l_old_transaction_rec )  THEN

-- Update staged_ind
    l_old_transaction_rec.staged_ind :=1;
-- Make the Bill-To transactions unique so subledger can identify them since
-- there are no records in wsh_delivery_details
    l_old_transaction_rec.line_detail_id := -999;
    GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED
             (
              p_api_version      =>  1
             ,p_init_msg_list    =>  FND_API.G_FALSE
             ,p_commit           =>  FND_API.G_FALSE
             ,p_validation_level =>  FND_API.G_VALID_LEVEL_FULL
             ,p_tran_rec         =>  l_old_transaction_rec
             ,x_tran_row         =>  l_old_transaction_row
             ,x_return_status    =>  x_return_status
             ,x_msg_count        =>  x_msg_count
             ,x_msg_data         =>  x_msg_data
              );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               GMI_reservation_Util.PrintLn('(opm_dbg) Error in updating transaction ');
               GMI_reservation_Util.PrintLn('(opm_dbg) Error return by UPDATE_PENDING_TO_COMPLETED,
                          return_status='|| x_return_status||', x_msg_count='|| x_msg_count||'.');
               GMI_reservation_Util.PrintLn('Error Message '|| x_msg_data);
               FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
               FND_MESSAGE.Set_Token('BY_PROC','GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TO_COMPLETED');
               FND_MESSAGE.Set_Token('WHERE','update_opm_trxns');
               FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF; -- of update

  ELSE -- of fetching trxn
    gmi_reservation_util.println('Failed to fetch opm trxn in update_opm_trxns for trans_id:'||p_trans_id);
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF; -- of fetching OPM trx

  gmi_reservation_util.println('Done upating ic_tran_pnd in update_opm_trxns.');

 END update_opm_trxns;

-- HW OPM BUG#:2536589 New procedure
PROCEDURE find_lot_id (
     p_trans_id                IN NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2)

IS

-- Cursor to fetch all lots for items that are lot control
CURSOR lot_info IS
SELECT IC.LOT_ID
FROM IC_TRAN_PND IC
WHERE IC.TRANS_ID = P_TRANS_ID
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    IC.STAGED_IND = 0
 AND    IC.LOT_ID <> 0;

x_lot_id NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  gmi_reservation_util.println('In GMI_reservation_util.find_lot_id');
  OPEN lot_info ;
  FETCH lot_info into x_lot_id ;
  IF lot_info%NOTFOUND THEN
    CLOSE lot_info ;
    gmi_reservation_util.println('Failed to fetch lot_id in in find_lot_id for trans _id= '||p_trans_id);
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE lot_info;

  gmi_reservation_util.println('Done fetching lot_id in find_lot_id');

  END find_lot_id ;


-- HW OPM -added for Harmonization project for WSH.I
PROCEDURE validate_lot_number (
   p_inventory_item_id                   IN NUMBER,
   p_organization_id           IN NUMBER,
   p_lot_number                IN VARCHAR2,
   x_return_status             OUT NOCOPY VARCHAR2) IS


 l_return_status       VARCHAR2(1);
 l_okay                BOOLEAN;
 l_ic_item_mst_rec     GMI_RESERVATION_UTIL.ic_item_mst_rec;
 l_msg_data            VARCHAR2(2000);
 l_msg_count           NUMBER;
 opm_item_id           NUMBER;
 l_lot_number          VARCHAR2(32);           -- Bug 3598280 - Made the variable varchar2(32) from varchar2(4)
 x_msg_count           NUMBER;
 x_msg_data            VARCHAR2(1000);
 l_api_name           CONSTANT VARCHAR2 (30) := 'validate_lot_number';

  CURSOR get_lot_no (opm_item_id IN NUMBER) IS
  SELECT lot_no
  FROM IC_LOTS_MST
  WHERE item_id = opm_item_id
  AND lot_no = p_lot_number ;

  BEGIN

-- Get OPM item information
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    GMI_RESERVATION_UTIL.Get_OPM_Item_From_Apps(
           p_organization_id =>p_organization_id,
           p_inventory_item_id => p_inventory_item_id,
           x_ic_item_mst_rec => l_ic_item_mst_rec,
           x_return_status  => l_return_status,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       raise FND_API.G_EXC_ERROR;
       RETURN;
    END IF;

    opm_item_id := l_ic_item_mst_rec.item_id ;

    OPEN get_lot_no(opm_item_id);
    FETCH get_lot_no into l_lot_number;
    IF get_lot_no%NOTFOUND THEN
      CLOSE get_lot_no ;
      gmi_reservation_util.println('Failed to fetch lot_no in validate_lot_no');
        x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    CLOSE get_lot_no;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Exp_Error ');

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
            (
               p_count  => x_msg_count,
               p_data  =>  x_msg_data,
	       p_encoded => FND_API.G_FALSE
            );

      WHEN OTHERS THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Error in Select='||SQLCODE||'.');
        x_return_status := SQLCODE;

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

  END validate_lot_number;

-- HW OPM -added for Harmonization project for WSH.I
-- This procedure will be called from the shipping transaction form
-- from the action procedure when user requests a split.
-- HW BUG#:2654963 Added p_delivery_detail_id to proc.
PROCEDURE line_allocated (
   p_inventory_item_id      IN NUMBER,
   p_organization_id        IN NUMBER,
   p_line_id                IN NUMBER,
   p_delivery_detail_id     IN NUMBER DEFAULT NULL,
   check_status             OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2)

 IS

-- HW cursor for ctl_items
 CURSOR get_opm_txn_cntl IS
 SELECT COUNT(1)

 FROM   IC_TRAN_PND IC
 WHERE  IC.LINE_ID = p_line_id
 AND    IC.line_detail_id=p_delivery_detail_id
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    ( IC.LOT_ID <> 0 OR
          IC.LOCATION <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

 -- Cursor for non-ctl items
CURSOR get_opm_txn_non_cntl  IS
 SELECT COUNT(1)

 FROM   IC_TRAN_PND IC
 WHERE  IC.trans_id = p_line_id
 AND    IC.line_detail_id=p_delivery_detail_id
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    ( IC.LOT_ID = 0 OR
          IC.LOCATION = GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);


  l_ctl_ind  VARCHAR2(1);

  l_lot_id NUMBER;
  l_whse_code VARCHAR2(5);
  l_location VARCHAR(20);
  l_count NUMBER;

  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(1000);
  l_api_name           CONSTANT VARCHAR2 (30) := 'line_allocated';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


 /* see if item is a ctl item */
  GMI_RESERVATION_UTIL.check_lot_loct_ctl
    ( p_inventory_item_id      => p_inventory_item_id
     ,p_mtl_organization_id    => p_organization_id
     ,x_ctl_ind                => l_ctl_ind
    );


  IF l_ctl_ind = 'Y' THEN -- control/location items
    gmi_reservation_util.println('Going to open cursor for lot/location items');
    OPEN get_opm_txn_cntl;
    FETCH get_opm_txn_cntl into l_count;
    IF ( get_opm_txn_cntl%NOTFOUND OR l_count = 0 ) THEN
      check_status := 0; -- No allocation
    ELSE
      check_status :=1; -- Line is allocated
    END IF;

    CLOSE get_opm_txn_cntl;

  ELSE  -- non ctl
    gmi_reservation_util.println('Going to open cursor for non-lot/non location');
    OPEN get_opm_txn_non_cntl;
    FETCH get_opm_txn_non_cntl into l_count;
    IF ( get_opm_txn_non_cntl%NOTFOUND OR l_count = 0  ) THEN
      check_status := 0; -- No allocation
    ELSE
      check_status :=1; -- Line is allocated
    END IF;

    CLOSE get_opm_txn_non_cntl;

  END IF;


EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Exp_Error ');

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
            (
               p_count  => x_msg_count,
               p_data  =>  x_msg_data,
	       p_encoded => FND_API.G_FALSE
            );

      WHEN OTHERS THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Error in Select='||SQLCODE||'.');
        x_return_status := SQLCODE;

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

    END line_allocated;


-- HW Added for bug#2677054 - WSH.I project
-- This rotine will be called from WSH Group API
-- WSH_DELIVERY_DETAILS_GRP.Delivery_Detail_Action
-- to check if line is allocated to lot_indivisble or not


PROCEDURE is_line_allocated (
   p_inventory_item_id      IN NUMBER,
   p_organization_id        IN NUMBER,
   p_delivery_detail_id     IN NUMBER DEFAULT NULL,
   check_status             OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2)
IS


-- HW cursor for ctl_items
 CURSOR get_opm_txn_cntl IS
 SELECT COUNT(1)

 FROM   IC_TRAN_PND IC
 WHERE  IC.line_detail_id=p_delivery_detail_id
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    ( IC.LOT_ID <> 0 OR
          IC.LOCATION <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

 -- Cursor for non-ctl items
CURSOR get_opm_txn_non_cntl  IS
 SELECT COUNT(1)

 FROM   IC_TRAN_PND IC
 WHERE   IC.line_detail_id=p_delivery_detail_id
 AND    IC.DOC_TYPE='OMSO'
 AND    IC.DELETE_MARK =0
 AND    IC.COMPLETED_IND =0
 AND    ( IC.LOT_ID = 0 OR
          IC.LOCATION = GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);


  l_ctl_ind  VARCHAR2(1);

  l_lot_id NUMBER;
  l_whse_code VARCHAR2(5);
  l_location VARCHAR(20);
  l_count NUMBER;
  l_ic_item_mst_rec                    GMI_Reservation_Util.ic_item_mst_rec;
  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(1000);
  l_api_name           CONSTANT VARCHAR2 (30) := 'is_line_allocated';
  return_status VARCHAR2(10);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  gmi_reservation_util.println('In procedure is_line_allocated');

-- Get item info

  Get_OPM_item_from_Apps(
           p_organization_id          => p_organization_id
         , p_inventory_item_id        => p_inventory_item_id
         , x_ic_item_mst_rec          => l_ic_item_mst_rec
         , x_return_status            => return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

  IF (return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
  END IF;

  IF ( l_ic_item_mst_rec.lot_indivisible = 1 ) THEN
 /* see if item is a ctl item */
    GMI_RESERVATION_UTIL.check_lot_loct_ctl
    ( p_inventory_item_id      => p_inventory_item_id
     ,p_mtl_organization_id    => p_organization_id
     ,x_ctl_ind                => l_ctl_ind
    );


    IF l_ctl_ind = 'Y' THEN -- control/location items
      gmi_reservation_util.println('Going to open cursor for lot/location items');
      OPEN get_opm_txn_cntl;
      FETCH get_opm_txn_cntl into l_count;
      IF ( get_opm_txn_cntl%NOTFOUND OR l_count = 0 ) THEN
        check_status := 0; -- No allocation
      ELSE
        check_status :=1; -- Line is allocated
      END IF;

      CLOSE get_opm_txn_cntl;

    ELSE  -- non ctl
      gmi_reservation_util.println('Going to open cursor for non-lot/non location');
      OPEN get_opm_txn_non_cntl;
      FETCH get_opm_txn_non_cntl into l_count;
      IF ( get_opm_txn_non_cntl%NOTFOUND OR l_count = 0  ) THEN
        check_status := 0; -- No allocation
      ELSE
        check_status :=1; -- Line is allocated
      END IF;

      CLOSE get_opm_txn_non_cntl;

    END IF;    -- of ctl_item

  ELSE
    gmi_reservation_util.println('Not lot indivisible');
    check_status :=0;
  END IF; -- of lot_ind


EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Exp_Error ');

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
            (
               p_count  => x_msg_count,
               p_data  =>  x_msg_data,
	       p_encoded => FND_API.G_FALSE
            );

      WHEN OTHERS THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Util q: Error in Select='||SQLCODE||'.');
        x_return_status := SQLCODE;

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END is_line_allocated;

-- PK Added for bug#3055126 - WSH.J
-- This rotine will be called from WSH Group API
-- WSH_DELIVERY_DETAILS_GRP.Create_Update_Delivery_Detail
-- If this group layer API is called from public API
-- WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes
-- Actual call is from WSHDDGPB.pls PROCEDURE  Validate_Delivery_Detail
-- This procedure checks if quantity1 and quantity2 ( Shipped or Cycle Count0
-- are within tolerance and can raise these exceptions.
-- 1) Required quantity not populated
-- 2) Deviation_hi
-- 3) Deviation_lo

PROCEDURE validate_opm_quantities(
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER,
   p_quantity          IN OUT NOCOPY NUMBER,
   p_quantity2         IN OUT NOCOPY NUMBER,
   p_lot_number        IN VARCHAR2,
   p_sublot_number     IN VARCHAR2,
   x_check_status      OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2)
IS

  l_ic_item_mst_rec                    GMI_Reservation_Util.ic_item_mst_rec;
  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(1000);
  l_api_name            CONSTANT VARCHAR2 (30) := 'validate_opm_quantities';
  return_status         VARCHAR2(10);
  l_lot_id              NUMBER;
  l_return              NUMBER;

  CURSOR cur_lot_id_with_sublot IS
  SELECT ic.lot_id
  FROM   ic_lots_mst ic
  WHERE  ic.item_id = l_ic_item_mst_rec.item_id
    AND  ic.lot_no = p_lot_number
    AND  ic.sublot_no = p_sublot_number;

  CURSOR cur_lot_id_with_lot    IS
  SELECT ic.lot_id
  FROM   ic_lots_mst ic
  WHERE  ic.item_id = l_ic_item_mst_rec.item_id
    AND  ic.lot_no = p_lot_number
    AND  ic.sublot_no IS NULL;

BEGIN

-- Get OPM Item
-- Check OPM Item controls.
-- See if required qty1 and qty2 are populated
-- (Add later Default if not populated).
-- If item is dual control and both fields are not populated then raise exception
-- If both are populated then get lot_id from lot_no and sublot_no. If lot not found use lot_id = 0
-- Call dev_validation API. If valid return success if not return exception.
-- x_check_status 1- Success  2- Required field not populated  3- IC_DEVIATION_HI_ERR 4- IC_DEVIATION_LO_ERR
--
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_check_status  := 1;
  gmi_reservation_util.println('Calling Get_OPM_item_from_Apps from validate_opm_quantities');
  Get_OPM_item_from_Apps(
           p_organization_id          => p_organization_id
         , p_inventory_item_id        => p_inventory_item_id
         , x_ic_item_mst_rec          => l_ic_item_mst_rec
         , x_return_status            => return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);
  gmi_reservation_util.println('BaCK FROM  Get_OPM_item_from_Apps IN validate_opm_quantities');

  IF (return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MSG_PUB.Add;
      x_check_status  := 0;
      raise FND_API.G_EXC_ERROR;
  END IF;

  IF ( l_ic_item_mst_rec.dualum_ind > 0 ) THEN
    IF (nvl(p_quantity,fnd_api.g_miss_num) = fnd_api.g_miss_num ) THEN
        gmi_reservation_util.println('Item Dual Control. Field not populated Qty1= '||p_quantity);
        x_check_status  := 2;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    ELSIF ( nvl(p_quantity2,fnd_api.g_miss_num) = fnd_api.g_miss_num) THEN
        gmi_reservation_util.println('Item Dual Control. Field not populated  Qty2= '||p_quantity2);
        x_check_status  := 5;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;
  ELSE -- Item is Not dual control No need to check
    IF (nvl(p_quantity,fnd_api.g_miss_num) = fnd_api.g_miss_num) THEN
       x_check_status  := 2;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
    ELSE
       GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Item Not dualUM. No need to check ');
       x_check_status  := 1;
       RETURN;
    END IF;
  END IF;
  -- Get lot_id.
  GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Lot '|| p_lot_number || ' Sublot '|| p_sublot_number);
  IF ( l_ic_item_mst_rec.lot_ctl = 0 ) THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Item Not Lot Control.');
       l_lot_id := 0;
  ELSIF (p_lot_number IS NOT NULL AND p_sublot_number IS NOT NULL) THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Sublot Not Null.');
        OPEN cur_lot_id_with_sublot;
        FETCH cur_lot_id_with_sublot INTO l_lot_id;
        IF (cur_lot_id_with_sublot%NOTFOUND) THEN
           l_lot_id := 0;
        END IF;
        CLOSE cur_lot_id_with_sublot;
  ELSIF (p_lot_number IS NOT NULL AND p_sublot_number IS NULL) THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Sublot Is Null.');
        OPEN cur_lot_id_with_lot;
        FETCH cur_lot_id_with_lot INTO l_lot_id;
        IF (cur_lot_id_with_lot%NOTFOUND) THEN
           l_lot_id := 0;
        END IF;
        CLOSE cur_lot_id_with_sublot;
  ELSE
        l_lot_id := 0;
  END IF;
  GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: lot_id '||l_lot_id);
  -- We have item_id, lot_id, qty1 and qty2 Now call deviation check
  l_return := GMICVAL.dev_validation(l_ic_item_mst_rec.item_id
                                     ,l_lot_id
			             ,p_quantity
			             ,l_ic_item_mst_rec.item_um
			             ,p_quantity2
                                     ,l_ic_item_mst_rec.item_um2
			             ,0);

  IF(l_return = -68) THEN
        --  'IC_DEVIATION_HI_ERR'
        x_check_status  := 3;
        x_return_status := FND_API.G_RET_STS_ERROR;
  ELSIF (l_return = -69) THEN
       -- 'IC_DEVIATION_LO_ERR'
        x_check_status  := 4;
        x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
        x_check_status  := 1;
  END IF;


EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Exp_Error ');

      WHEN OTHERS THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in Util validate_opm_quantities: Error in Select='||SQLCODE||'.');
        x_return_status := SQLCODE;

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END validate_opm_quantities;

END GMI_Reservation_Util;

/

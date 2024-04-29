--------------------------------------------------------
--  DDL for Package Body GMI_RESERVATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RESERVATION_PVT" AS
/*  $Header: GMIVRSVB.pls 115.72 2004/06/07 17:10:35 pkanetka ship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVRSVB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private procedures relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 | - Query_Reservation                                                     |
 | - Create_Reservation                                                    |
 | - Update_Reservation                                                    |
 | - Delete_Reservation                                                    |
 | - Transfer_Reservation                                                  |
 | - Check_Shipping_Details                                                |
 | - Calculate_Prior_Reservations
 |                                                                         |
 | HISTORY                                                                 |
 | 21-feb-2000 odaboval             Created                                |
 |  7-Nov-2000 odaboval, B1479751 : Added the test and a  message.         |
 | 28-Nov-2000 odaboval, B1504749 : in Query_reservation, swapped columns  |
 |             staged_ind with event_id.                                   |
 | 24-AUG-2001 NC Added line_detail_id in the SELECT in Query_Reservation  |
 |             Bug#1675561                                                 |
 | 03-OCT-2001  odaboval, local fix for bug 2025611                        |
 |                        added procedure Check_Shipping_Details           |
 | 24-JAN-2002 plowe --   added rounding fix for query_reservation so that |
 |                        reserved quantity rounding for recurring decimals|
 |                        uses GMI: EPSILON for decimal precision rounding |
 |                        in case where primary item UOM is different to   |
 |                        ordered quantity UOM.                            |
 | 13-JAN-2003  NC  - Added procedure Calculate_prior_reservations.        |
 |                    for prior reservations project. Bug#2670928          |
 | 23-MAR-2004  P.Raghu  Bug#3411704                                       |
 |                       Modified procedure Update_Reservation such that   |
 |                       reserved quantity is calculated if it is equal to |
 |                       FND_API.G_MISS_NUM.                               |
 +========================================================================+
  API Name  : GMI_Reservation_PVT
  Type      : Private - Package Body
  Function  : This package contains Private procedures used to
              OPM reservation process.
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


/*  Global variables */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='GMI_Reservation_PVT';

-- HW BUG#:1941429 OPM cross_docking. Record table to hold information

   TYPE demRecTyp_opm IS RECORD (
          whse_code               VARCHAR2(4),
          item_id                 NUMBER,
          qty_available          NUMBER,
          qty2_available          NUMBER,
          qty_committed           NUMBER,
          qty2_committed          NUMBER
          );

   TYPE demRecTabTyp_opm IS TABLE OF demRecTyp_opm INDEX BY BINARY_INTEGER;
   g_demand_table demRecTabTyp_opm;

-- PK Bug#3297382 New PL/SQL Table defined to hold shipset information

   TYPE shipset_rectyp_opm IS RECORD (
         shipset_id          NUMBER,
         order_id            NUMBER,
         shipset_valid	     VARCHAR2(1),
         shipset_reserved    VARCHAR2(1)
         );

   TYPE shipset_tabtyp_opm IS TABLE OF  shipset_rectyp_opm  INDEX BY BINARY_INTEGER;
   g_shipset_table  shipset_tabtyp_opm;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Query_Reservation                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Query reservations included in table IC_TRAN_PND.                      |
 |   If found, fetch data into a table of rec_type.                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Query reservations included in table IC_TRAN_PND.                      |
 |   If found, fetch data into a table of rec_type.                         |
 |                                                                          |
 | PARAMETERS                                                               |
 |    x_return_status             OUT VARCHAR2     - Return Status          |
 |    x_msg_count                 OUT NUMBER       -                        |
 |    x_msg_data                  OUT VARCHAR2     -                        |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_query_input               IN  rec_type     -                        |
 |    p_lock_records              IN  VARCHAR2     -                        |
 |    x_mtl_reservation_tbl       OUT rec_type     -                        |
 |    x_mtl_reservation_tbl_count OUT NUMBER       -                        |
 |    x_error_code                OUT NUMBER       -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |     24-JAN-2002  plowe added rounding fix for query_reservation so that  |
 |                        reserved quantity rounding for recurring decimals |
 |                        uses GMI: EPSILON for decimal precision rounding  |
 |                        in case where primary item UOM is different to    |
 |                        ordered quantity UOM.                             |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Query_Reservation
  (
     x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_mtl_reservation_tbl           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   ) IS


/* ============================================================================= */
/*  Variables */
l_api_name             CONSTANT VARCHAR2 (30) := 'Query_Reservation';

l_ic_tran_rec_tbl_empty GMI_Reservation_Util.l_ic_tran_rec_tbl;
rec_index BINARY_INTEGER :=1;
i BINARY_INTEGER :=1;

l_quantity_to_convert        NUMBER;
l_converted_quantity         NUMBER;
l_OPM_order_um               VARCHAR2(4);
l_Apps_order_um              VARCHAR2(3);
l_Apps_primary_um            VARCHAR2(3);
l_ic_item_mst_rec            GMI_Reservation_Util.ic_item_mst_rec;

-- OPM 2115306
l_epsilon                    NUMBER;
n                            NUMBER;
-- OPM 2115306 end


TYPE ref_cursor_type IS REF CURSOR;
c_Get_Reservation      ref_cursor_type;


BEGIN

GMI_reservation_Util.PrintLn('(opm_dbg) entering proc GMI_Reservation_PVT.query_reservation (PVT q)');
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : reservation_id='||p_query_input.reservation_id||'.');
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : organization_id='||p_query_input.organization_id||'.');
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : demand_source_type_id='||p_query_input.demand_source_type_id||'.');
/*  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : demand_source_name='||p_query_input.demand_source_name||'.'); */
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : demand_source_header_id='||p_query_input.demand_source_header_id||'.');
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : demand_source_line_id='||p_query_input.demand_source_line_id||'.');
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : inventory_item_id='||p_query_input.inventory_item_id||'.');
/*  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : primary_uom_code='||p_query_input.primary_uom_code||'.'); */
/*  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : reservation_uom_code='||p_query_input.reservation_uom_code||'.'); */
/*  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q : reservation_quantity='||p_query_input.reservation_quantity||'.'); */

/*  Initialize API return status to success */
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* ============================================================================================= */
/*  Reinit the transaction cache.  */
/* ============================================================================================= */
GMI_Reservation_Util.ic_tran_rec_tbl := l_ic_tran_rec_tbl_empty;
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q begin COUNT reservation='||GMI_Reservation_Util.ic_tran_rec_tbl.COUNT||'.');

/* =============================================================================================  */
/*  Choose which cursor from trans_id or line_id                                                  */
/*  Line_id is the most common use of the API.                                                    */
/*  ============================================================================================= */
/*  With line_id, the cursor returns all rows attached to the sales order line.                   */
/*       (the default Lot, and the allocated lots)                                                */
/*  ============================================================================================= */
/*  With trans_id, the cursor returns only one row.                                               */
/*                                                                                                */
/* =============================================================================================  */
/* 28-Nov-2000, B1504749, odaboval : swapped columns staged_ind with event_id                     */
OPEN c_Get_Reservation FOR
           SELECT   trans_id
                  , item_id
                  , line_id
                  , co_code
                  , orgn_code
                  , whse_code
                  , lot_id
                  , location
                  , doc_id
                  , doc_type
                  , doc_line
                  , line_type
                  , reason_code
                  , trans_date
                  , trans_qty
                  , trans_qty2
                  , qc_grade
                  , NULL         /*  lot no  */
                  , NULL         /*  sublot no  */
                  , lot_status
                  , trans_stat
                  , trans_um
                  , trans_um2
                  , staged_ind
                  , event_id
                  , text_code
                  , NULL      /*  user id  */
                  , NULL      /*  create_lot_index  */
                  , NULL      /*  non_inv field */
                  , line_detail_id
                 FROM ic_tran_pnd
                 WHERE doc_type ='OMSO'
                 AND   delete_mark = 0
                 AND   completed_ind = 0
                 AND   line_id = p_query_input.demand_source_line_id
                 ORDER BY lot_id DESC;

GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q before loop ROWCOUNT='||c_Get_Reservation%ROWCOUNT);
/* ============================================================================================= */
/*  Retrieve the reservation */
/* ============================================================================================= */
rec_index := 1;
LOOP
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q in loop='||rec_index);
   FETCH c_Get_Reservation
   INTO GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).item_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).line_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).co_code
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).orgn_code
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).whse_code
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).lot_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).location
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).doc_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).doc_type
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).doc_line
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).line_type
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).reason_code
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_date
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_qty
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_qty2
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).qc_grade
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).lot_no
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).sublot_no
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).lot_status
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_stat
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_um
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_um2
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).staged_ind
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).event_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).text_code
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).user_id
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).create_lot_index
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).non_inv
      , GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).line_detail_id
   ;
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q before loop ROWCOUNT='||c_Get_Reservation%ROWCOUNT);
   EXIT WHEN c_Get_Reservation%NOTFOUND;

   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q just after fetch, trans_id='||GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_id);
   GMI_reservation_Util.PrintLn('qty1='||GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_qty);
   GMI_reservation_Util.PrintLn('qty2='||GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_qty2);

   l_quantity_to_convert := GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_qty;
   l_converted_quantity  := 0;
   /*  always Get the Apps Primary UM for the Item : */
   /* only need to do this once */
   IF rec_index = 1 THEN
      GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM(
                     p_OPM_UOM       => GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_um
                   , x_Apps_UOM      => l_Apps_primary_um
                   , x_return_status => x_return_status
                   , x_msg_count     => x_msg_count
                   , x_msg_data      => x_msg_data);

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
         FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
         FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM');
         FND_MESSAGE.Set_Token('WHERE', 'Query_Reservation');
         FND_MSG_PUB.Add;
         raise FND_API.G_EXC_ERROR;
      END IF;
      /* ============================================================================================= */
      /*  Validation for the query (private level) */
      /* ============================================================================================= */
      GMI_Reservation_Util.Validation_for_Query
          ( p_query_input                   => p_query_input
          , x_opm_um                        => l_OPM_order_um
          , x_apps_um                       => l_Apps_order_um
          , x_ic_item_mst_rec               => l_ic_item_mst_rec
          , x_return_status                 => x_return_status
          , x_msg_count                     => x_msg_count
          , x_msg_data                      => x_msg_data
          , x_error_code                    => x_error_code); /* Bug 2168710 - Added parameter */

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
          FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
          FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Validation_for_Query');
          FND_MESSAGE.Set_Token('WHERE', 'Query_Reservation');
          /* x_error_code := x_return_status ; */ /* Bug 2168710 */
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Add;
          raise FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /* ============================================================================================= */
   /*  Convert reserved quantity (in ic_tran_pnd, so OPM) into the reservation_UOM of the SO. */
   /* =============================================================================================*/
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q OPM_order_um='||l_OPM_order_um||', item_um='||l_ic_item_mst_rec.item_um||'.');
   IF (l_OPM_order_um <> l_ic_item_mst_rec.item_um)
   THEN
      GMICUOM.icuomcv(pitem_id  => l_ic_item_mst_rec.item_id
                    , plot_id   => 0
                    , pcur_qty  => l_quantity_to_convert
                    , pcur_uom  => l_ic_item_mst_rec.item_um
                    , pnew_uom  => l_OPM_order_um
                    , onew_qty  => l_converted_quantity);

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

      l_converted_quantity := round(l_converted_quantity, n); -- OPM 2115306
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q converted qty AFTER rounding = '|| l_converted_quantity);
   ELSE
      l_converted_quantity := l_quantity_to_convert;
   END IF;


   /* ============================================================================================= */
   /*  Populate the mtl_reservation rec type */
   /*   and the ic_tran_rec table */
   /* ============================================================================================= */
   GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).user_id  := FND_GLOBAL.USER_ID;
   GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).non_inv  := l_ic_item_mst_rec.noninv_ind;

   x_mtl_reservation_tbl(rec_index).reservation_id          := GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_id;
   x_mtl_reservation_tbl(rec_index).organization_id         := p_query_input.organization_id;
   x_mtl_reservation_tbl(rec_index).inventory_item_id       := l_ic_item_mst_rec.inventory_item_id;
   x_mtl_reservation_tbl(rec_index).demand_source_header_id := GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).doc_id;
   x_mtl_reservation_tbl(rec_index).demand_source_line_id   := GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).line_id;
   /* hwahdani 1388867 */
   x_mtl_reservation_tbl(rec_index).demand_source_type_id   := INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE;
   x_mtl_reservation_tbl(rec_index).requirement_date        := GMI_RESERVATION_UTIL.ic_tran_rec_tbl(rec_index).trans_date;
   /* end of 1388867 */

   /*  Quantities in mtl_reservation_tbl are >0, those in ic_tran_rec_tbl are <=0. */
   x_mtl_reservation_tbl(rec_index).primary_reservation_quantity := (-1) * GMI_Reservation_Util.ic_tran_rec_tbl(rec_index).trans_qty;
   x_mtl_reservation_tbl(rec_index).primary_uom_code        := l_Apps_primary_um;
   x_mtl_reservation_tbl(rec_index).reservation_quantity    := (-1) * l_converted_quantity;
   x_mtl_reservation_tbl(rec_index).reservation_uom_code    := l_Apps_order_um;
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q reservation_quantity='||x_mtl_reservation_tbl(rec_index).reservation_quantity||'.');

   x_mtl_reservation_tbl(rec_index).attribute1              := GMI_RESERVATION_UTIL.ic_tran_rec_tbl(rec_index).qc_grade  ;
   x_mtl_reservation_tbl(rec_index).attribute2              := (-1) * GMI_RESERVATION_UTIL.ic_tran_rec_tbl(rec_index).trans_qty2  ;
   x_mtl_reservation_tbl(rec_index).attribute3              := GMI_RESERVATION_UTIL.ic_tran_rec_tbl(rec_index).trans_um2  ;
   x_mtl_reservation_tbl(rec_index).attribute4              := GMI_RESERVATION_UTIL.ic_tran_rec_tbl(rec_index).line_detail_id  ;
   x_mtl_reservation_tbl(rec_index).detailed_quantity       := 0;
  rec_index := rec_index + 1;
END LOOP;
CLOSE c_Get_Reservation;

GMI_reservation_Util.PrintLn('(opm_dbg) in PVT q COUNT reservation='||GMI_Reservation_Util.ic_tran_rec_tbl.COUNT||'.');
x_mtl_reservation_tbl_count := GMI_Reservation_Util.ic_tran_rec_tbl.COUNT;



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
      IF (   SQLCODE <> 0
         AND SQLCODE <> 100)
      THEN
         x_error_code := SQLCODE;
         GMI_reservation_Util.PrintLn('(opm_dbg) in GMI_Reservation_PVT.Query_reservation SQLCODE:error='||SQLCODE||'.');
         FND_MESSAGE.Set_Name('GMI','GMI_SQL_ERROR');
         FND_MESSAGE.Set_Token('WHERE', 'Query_Reservation');
         FND_MESSAGE.Set_Token('SQL_CODE', SQLCODE);
         FND_MESSAGE.Set_Token('SQL_ERRM', SQLERRM);
         FND_MSG_PUB.Add;
         raise FND_API.G_EXC_ERROR;
      END IF;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Query_Reservation;

/*  Api start of comments */
/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Reservation                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Create reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Create reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    x_return_status             OUT VARCHAR2     - Return Status          |
 |    x_msg_count                 OUT NUMBER       -                        |
 |    x_msg_data                  OUT VARCHAR2     -                        |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_rsv_rec                   IN  rec_type     -                        |
 |    p_serial_number             IN  rec_type     -                        |
 |    x_serial_number             OUT rec_type     -                        |
 |    x_quantity_reserved         OUT rec_type     -                        |
 |    x_reservation_id            OUT NUMBER       -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Create_Reservation
  (
     x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_rsv_rec                       IN  INV_reservation_global.mtl_reservation_rec_type
   , p_serial_number                 IN  INV_reservation_global.serial_number_tbl_type
   , x_serial_number                 OUT NOCOPY INV_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_force_reservation_flag        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , x_quantity_reserved             OUT NOCOPY NUMBER
   , x_reservation_id                OUT NOCOPY NUMBER
  ) IS

  /* ==== Variables ============================================================== */
  l_api_name              CONSTANT VARCHAR2 (30) := 'Create_Reservation';
  l_default_lot_index     BINARY_INTEGER;
  l_mtl_reservation_tbl   inv_reservation_global.mtl_reservation_tbl_type;
  l_mtl_rsv_tbl_count     NUMBER;
  x_error_code            NUMBER;
  l_lock_status           BOOLEAN;
  l_allocation_rec        GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec;
  l_ic_item_mst_rec       GMI_Reservation_Util.ic_item_mst_rec;
  l_cust_no               op_cust_mst.cust_no%TYPE;
  l_orgn_code             sy_orgn_mst.orgn_code%TYPE;
  l_trans_id              NUMBER;
  X_ALLOCATED_QTY1        NUMBER;
  X_ALLOCATED_QTY2        NUMBER;
  l_default_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  i                       BINARY_INTEGER :=1;
  -- added by fabdi 10/01/2001
  -- fix for bug # 1574957
  l_whse_ctl              number;
--B1766055 - Retrieve whse loct_ctl data using primary key
--========================================================
  Cursor get_whse_ctl IS
    select loct_ctl
    from ic_whse_mst
    where whse_code = l_allocation_rec.whse_code;
  -- end fabdi
 CURSOR check_detailed_allocations IS
 SELECT SUM(ABS(trans_qty))
 FROM   ic_tran_pnd
 WHERE  line_id       = p_rsv_rec.demand_source_line_id
 AND    doc_type      = 'OMSO'
 AND    staged_ind    = 0
 AND    completed_ind = 0
 AND    lot_id <> 0
 AND    delete_mark   = 0;
BEGIN
  GMI_reservation_Util.PrintLn('(opm_dbg) Entering proc GMI_Reservation_PVT.Create_reservation ');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : user_id='||FND_GLOBAL.USER_ID||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : reservation_id='||p_rsv_rec.reservation_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : organization_id='||p_rsv_rec.organization_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : inventory_item_id='||p_rsv_rec.inventory_item_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : requirement_date='||p_rsv_rec.requirement_date||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : demand_source_type_id='||p_rsv_rec.demand_source_type_id||'.');
  /*  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : demand_source_name='||p_rsv_rec.demand_source_name||'.'); */
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : demand_source_header_id='||p_rsv_rec.demand_source_header_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : demand_source_line_id='||p_rsv_rec.demand_source_line_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : primary_uom_id='||p_rsv_rec.primary_uom_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : primary_uom_code='||p_rsv_rec.primary_uom_code||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : reservation_uom_code='||p_rsv_rec.reservation_uom_code||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : reservation_quantity='||p_rsv_rec.reservation_quantity||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : prim_reservation_quantity='||p_rsv_rec.primary_reservation_quantity||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : detailed_quantity='||p_rsv_rec.detailed_quantity||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : external_source_code='||p_rsv_rec.external_source_code||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : subinventory_code='||p_rsv_rec.subinventory_code||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : subinventory_id='||p_rsv_rec.subinventory_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : attribute1='||p_rsv_rec.attribute1||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : attribute2='||p_rsv_rec.attribute2||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : attribute3='||p_rsv_rec.attribute3||'.');

  /* ============================================================================================= */
  /*  Initialize API return status to success */
  /* =============================================================================================*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* if detailed allocation exists, no need to go through the process
     because auto alloation engin does not take detailed lines for requests
   */
  /* not to do this any more bug 1830327 */
  /*Open check_detailed_allocations;
  Fetch check_detailed_allocations into x_allocated_qty1;
  Close check_detailed_allocations;
  IF nvl(x_allocated_qty1,0) <> 0 THEN
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : details exits, no auto allocations ');
  ELSE*/
    /* =============================================================================================*/
    /*  If allocations exist then the reservation_quantity == 0, and I don't create anything */
    /*  Need to check that assumption! */
    /* ============================================================================================= */
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : Begin of treatment');

    IF (p_rsv_rec.reservation_quantity = 0)
    THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Nothing to reserve.');
       FND_MESSAGE.Set_Name('GMI','GMI_NOTHING_TO_RESERVE');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* =============================================================================================*/
    /*  Following a pb in August2000, as the query_reservation seems to not be called systematically,*/
    /*  I need to call Query_Reservation by myself.*/
    /* ============================================================================================= */
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c: GMI_Reservation_Util.ic_tran_rec_tbl.COUNT = 0, calling Query_Reservation.');
    GMI_reservation_pub.Query_Reservation
                      ( p_api_version_number        => 1.0
                      , p_init_msg_lst              => FND_API.G_FALSE
                      , x_return_status             => x_return_status
                      , x_msg_count                 => x_msg_count
                      , x_msg_data                  => x_msg_data
                      , p_validation_flag           => p_validation_flag
                      , p_query_input               => p_rsv_rec
                      , p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
                      , x_mtl_reservation_tbl       => l_mtl_reservation_tbl
                      , x_mtl_reservation_tbl_count => l_mtl_rsv_tbl_count
                      , x_error_code                => x_error_code
                      , p_lock_records              => FND_API.G_FALSE
                      , p_sort_by_req_date          => inv_reservation_global.g_query_no_sort
                      );

    /*  There may have been a problem getting the rows */
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c: Error Returned by Query_Reservation.');
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_reservation_pub.Query_Reservation');
       FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*  At this point the table ic_tran_rec_tbl should have rows*/

    /* =============================================================================================*/
    /*   Validation then fill the l_allocation_rec in.*/
    /* =============================================================================================*/
    GMI_Reservation_Util.Validation_before_Allocate(
        p_mtl_rsv_rec           => p_rsv_rec
      , x_allocation_rec        => l_allocation_rec
      , x_ic_item_mst_rec       => l_ic_item_mst_rec
      , x_orgn_code             => l_orgn_code
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data);

    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
    THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Returned by Validation_Before_Allocate.');
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Validation_before_Allocate');
       FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;



    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : default_loct='||GMI_Reservation_Util.G_DEFAULT_LOCT||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : default_lot_index='||l_default_lot_index||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : alloc_class='||l_ic_item_mst_rec.alloc_class||'.');

    /* =============================================================================================*/
    /*  No allocation exist and rules are AUTO_ALLOC. Then call OPM_auto_allocation and the transaction engine.*/
    /* =============================================================================================*/
    /*  Allocation rec type :*/
    /*                  l_allocation_rec.doc_id       := demand_source_header_id             done*/
    /*                  l_allocation_rec.line_id      := demand_source_line_id               done*/
    /*                  l_allocation_rec.item_no      := (c_item)                            done*/
    /*                  l_allocation_rec.whse_code    := INV_GMI_RSV_Branch.Get_Process_Org  done*/
    /*                  l_allocation_rec.co_code      := INV_GMI_RSV_Branch.Get_Process_Org  done*/
    /*                  l_allocation_rec.cust_no      := (c_customer)*/
    /*                  l_allocation_rec.prefqc_grade := attribute1                          done*/
    /*                  l_allocation_rec.order_qty1   := reservation_quantity                done*/
    /*                  l_allocation_rec.order_qty2   := attribute2                          done */
    /*                  l_allocation_rec.order_um1    := reservation_uom_code (c_uom)        done*/
    /*                  l_allocation_rec.order_um2    := attribute3 (c_uom)                  done*/
    /*                  l_allocation_rec.trans_date   := requirement_date                    done*/
    /*                  l_allocation_rec.user_id      := FND_GLOBAL.USER_ID (c_user)         done*/
    /*                  l_allocation_rec.user_name    := FND_GLOBAL.USER_ID (c_user)         done*/
    /* =============================================================================================*/
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.doc_id='||l_allocation_rec.doc_id||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.line_id='||l_allocation_rec.line_id||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.item_no='||l_allocation_rec.item_no||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.whse_code='||l_allocation_rec.whse_code||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.co_code='||l_allocation_rec.co_code||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.cust_no='||l_allocation_rec.cust_no||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.grade='||l_allocation_rec.prefqc_grade||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_qty1='||l_allocation_rec.order_qty1||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_qty2='||l_allocation_rec.order_qty2||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_um1='||l_allocation_rec.order_um1||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_um2='||l_allocation_rec.order_um2||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.trans_date='||l_allocation_rec.trans_date||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.user_id='||l_allocation_rec.user_id||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.user_name='||l_allocation_rec.user_name||'.');
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c Calls Auto Allocation Engine');

    /* =============================================================================================*/
    /*   Check the existence of the default lot for the transaction/item*/
    /* =============================================================================================*/
    /*  Test the default_Loct constant.*/
    IF (GMI_Reservation_Util.G_DEFAULT_LOCT IS NULL)
    THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Cannot get default lot.');
       FND_MESSAGE.Set_Name('GMI','SY_API_UNABLE_TO_GET_CONSTANT');
       FND_MESSAGE.Set_Token('CONSTANT_NAME','IC$DEFAULT_LOCT');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    /*  Retrieve the default lot in the transaction*/
    GMI_Reservation_Util.Get_Default_Lot(
           x_ic_tran_pnd_index        => l_default_lot_index
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Returned by Get_Default_Lot.');
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Default_Lot');
       FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* =============================================================================================*/
    /*  Lock rows in ic_loct_inv.*/
    /* =============================================================================================*/
    /* Bug 2521215 Do not Lock Inventory when Allocating
    GMI_Locks.Lock_Inventory(
           i_item_id               => l_ic_item_mst_rec.item_id
         , i_whse_code             => l_allocation_rec.whse_code
         , o_lock_status           => l_lock_status
         );

    IF (l_lock_status = FALSE) THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Returned by Lock_Inventory.');
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Locks.Lock_Inventory');
       FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
       FND_MSG_PUB.Add;
       GMI_reservation_Util.PrintLn('return 1 in lock inventory');
       RETURN;
     --  RAISE FND_API.G_EXC_ERROR;  Bug2516545
    END IF;

    End Bug 2521215 */

    IF (l_default_lot_index = 0) THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : Going to create the Default Lot');
       /* =============================================================================================*/
       /*  No default lot exist AND MANUAL Allocation. Then create the default lot*/
       /* =============================================================================================*/
       l_trans_id := NULL;
       /* bug 1687531, moved here from out side of if */
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c before Create_Default_Lot orgn_code='||l_orgn_code||', trans_id(if not null then UPDATE default_lot)='||l_trans_id);
       GMI_Reservation_Util.Create_Default_Lot(
               p_allocation_rec        => l_allocation_rec
             , p_ic_item_mst_rec       => l_ic_item_mst_rec
             , p_orgn_code             => l_orgn_code
             , p_trans_id              => l_trans_id
             , x_return_status         => x_return_status
             , x_msg_count             => x_msg_count
             , x_msg_data              => x_msg_data);

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
       THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Returned by Create_Default_Lot.');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Create_Default_Lot');
            FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSE
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c DefaultLot already exist NO Error (Going to update the default lot transaction).');
       l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);
       /* bug 2240221*/
       IF p_rsv_rec.requirement_date <> FND_API.G_MISS_DATE THEN
          l_default_tran_rec.trans_date := p_rsv_rec.requirement_date ;
       END IF;


       GMI_reservation_Util.PrintLn('(opm_dbg) p_rsv_rec.inventory_item_id='||p_rsv_rec.inventory_item_id);
       GMI_reservation_Util.PrintLn('(opm_dbg) opm_item_id='||l_default_tran_rec.item_id);
       GMI_reservation_Util.PrintLn('(opm_dbg) l_ic_item_mst_rec.item_id='||l_ic_item_mst_rec.item_id);

       /* Start bug 2711467 */
       IF (l_default_tran_rec.item_id <> l_ic_item_mst_rec.item_id) THEN
           l_default_tran_rec.item_id   := l_ic_item_mst_rec.item_id;
           l_default_tran_rec.trans_um  := l_ic_item_mst_rec.item_um;
           l_default_tran_rec.trans_um2 := l_ic_item_mst_rec.item_um2;
       END IF;

          /* End bug 2711467*/

           GMI_RESERVATION_UTIL.balance_default_lot
             ( p_ic_default_rec            => l_default_tran_rec
             , p_opm_item_id               => l_default_tran_rec.item_id
             , x_return_status             => x_return_status
             , x_msg_count                 => x_msg_count
             , x_msg_data                  => x_msg_data
             );
           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
                GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Update_Transaction() updating the default record.');
                FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
                FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
                FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
       /* =============================================================================================*/
       /*  Set the trans_id of the default transaction (passed as a parameter)*/
       /* =============================================================================================*/
       l_trans_id := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index).trans_id;
    END IF;


    /* =============================================================================================*/
    /*  Call the Allocation engine if :*/
    /*    - Allocation class is defined*/
    /*    - item is lot control or location control*/
    /* =============================================================================================*/
-- B1766055 - Ensure l_whse_ctl is populated with loct_ctl setting
   OPEN get_whse_ctl;
   FETCH get_whse_ctl INTO l_whse_ctl;
   CLOSE get_whse_ctl;
-- B1766055 END
   GMI_reservation_Util.PrintLn('OPM  Whse LOCATION CTL is : ' || l_whse_ctl);
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : alloc_class='||l_ic_item_mst_rec.alloc_class||', lot_ctl='||l_ic_item_mst_rec.lot_ctl||', loct_ctl='||l_ic_item_mst_rec.loct_ctl);
    -- added by fabdi 10/01/2001
    -- fix for bug # 1574957
    IF (l_ic_item_mst_rec.lot_ctl > 0) OR
       (l_ic_item_mst_rec.loct_ctl > 0 AND l_whse_ctl > 0)
    -- end fabdi
    THEN
      IF ( (l_ic_item_mst_rec.alloc_class <> FND_API.G_MISS_CHAR
         AND l_ic_item_mst_rec.alloc_class IS NOT NULL )
         AND p_force_reservation_flag = FND_API.G_TRUE)
      THEN
         /*  7-Nov-2000 odaboval : Bug 1479751 : Added the test and a message.*/
         /* comment this out, no need after bug 2245351*/
         /*IF (l_allocation_rec.cust_no = ' ' OR l_allocation_rec.cust_no IS NULL)
         THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : Customer is not synchronized. SO_line_id='||l_allocation_rec.line_id);
           FND_MESSAGE.Set_Name('GML','GML_CUST_NOT_OPM_SYNCHRONIZED');
           FND_MESSAGE.Set_Token('SO_LINE_ID', l_allocation_rec.line_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;*/
         /*  End of Bug 1479751*/

         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : Lock Rows then Call allocation engine');
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.grade='||l_allocation_rec.prefqc_grade||'.');
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_qty1='||l_allocation_rec.order_qty1||'.');
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_qty2='||l_allocation_rec.order_qty2||'.');
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_um1='||l_allocation_rec.order_um1||'.');
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c alloc_rec.order_um2='||l_allocation_rec.order_um2||'.');
         /* =============================================================================================*/
         /*  Lock rows in ic_loct_inv.*/
         /* =============================================================================================*/
         /* Bug 2521215 Do not Lock Inventory when Allocating
         GMI_Locks.Lock_Inventory(
             i_item_id               => l_ic_item_mst_rec.item_id
           , i_whse_code             => l_allocation_rec.whse_code
           , o_lock_status           => l_lock_status
           );

         IF (l_lock_status = FALSE) THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Returned by Lock_Inventory.');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Locks.Lock_Inventory');
            FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
            FND_MSG_PUB.Add;
            -- RAISE FND_API.G_EXC_ERROR;  Bug2516545
            GMI_reservation_Util.PrintLn('return 2 in lock inventory');
            RETURN;
         END IF;
         End Bug 2521215 */

         GMI_Auto_Allocate_PUB.Allocate_Inventory(
              P_API_VERSION             => 1.0
            , P_INIT_MSG_LIST           => FND_API.G_FALSE
            , P_COMMIT                  => FND_API.G_FALSE
            , P_VALIDATION_LEVEL        => FND_API.G_VALID_LEVEL_FULL
            , P_ALLOCATION_REC          => l_allocation_rec
            , X_RESERVATION_ID          => X_RESERVATION_ID
            , X_ALLOCATED_QTY1          => X_ALLOCATED_QTY1
            , X_ALLOCATED_QTY2          => X_ALLOCATED_QTY2
            , X_RETURN_STATUS           => X_RETURN_STATUS
            , X_MSG_COUNT               => X_MSG_COUNT
            , X_MSG_DATA                => X_MSG_DATA
            );

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c ERROR:Returned by Allocate_Inventory.');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Auto_Allocate_PUB.Allocate_Inventory');
            FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
       ELSE
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : Manual Allocation or HighLevelReservation: Only Default Lot.');
       END IF;
    ELSE
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT c : Item Not Lot or Location controlled : Only Default Lot.');
    END IF;
  --END IF;

  /* =============================================================================================*/
  /*  Returned values*/
  /* =============================================================================================*/
  x_quantity_reserved := p_rsv_rec.reservation_quantity;
  x_reservation_id    := p_rsv_rec.demand_source_line_id;

  GMI_reservation_Util.PrintLn('(opm_dbg) in end of PVT c No Error, quantity_reserved='||x_quantity_reserved||'.');

EXCEPTION

   /* =============================================================================================*/
   /*  Error*/
   /* =============================================================================================*/
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.PrintLn('in end of PVT c ERROR.');
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.PrintLn('in end of PVT c ERROR:Other.');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Create_Reservation;



/*  Api start of comments*/
/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Update_Reservation                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Update reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Update reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT VARCHAR2     - Return Status          |
 |    x_msg_count                 OUT NUMBER       -                        |
 |    x_msg_data                  OUT VARCHAR2     -                        |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_original_rsv_rec          IN  rec_type     -                        |
 |    p_to_rsv_rec                IN  rec_type     -                        |
 |    p_serial_number             IN  rec_type     -                        |
 |    x_serial_number             OUT rec_type     -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |     23-MAR-2004  P.Raghu  Bug#3411704                                    |
 |                           Reserved quantity is calculated correctly if it|
 |                           is equal to FND_API.G_MISS_NUM.                |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Update_Reservation
  (
     x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   ) IS

  l_commit                        VARCHAR2(5) := fnd_api.g_false;
  l_validation_level              VARCHAR2(4) := fnd_api.g_valid_level_full;
  l_api_name                      CONSTANT VARCHAR2(30) := 'Update_Reservation';
  l_api_version                   CONSTANT VARCHAR2(10) := '1.0';

  l_temp_tran_row                 IC_TRAN_PND%ROWTYPE;
  l_ic_tran_row                   IC_TRAN_PND%ROWTYPE;

  l_default_tran_rec              GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_original_tran_rec             GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_default_lot_index             BINARY_INTEGER;
  l_original_tran_index           BINARY_INTEGER;

  l_to_rsv_qty                    NUMBER;
  l_original_rsv_qty              NUMBER;
  l_delta_rsv_qty                 NUMBER;
  l_delta_tran_qty                NUMBER;

  l_to_rsv_um                     VARCHAR2(3);
  l_opm_uom                       VARCHAR2(4);
  l_orig_conv_to_new_rsv_qty      NUMBER;
  l_new_rsv_to_item_um_qty        NUMBER;
  l_new_rsv_to_item_um_qty2       NUMBER;
  l_default_lot_quantity          NUMBER;
  l_default_loct                  VARCHAR2(4) := fnd_profile.value('IC$DEFAULT_LOCT');
  l_old_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
  l_old_mtl_rsv_tbl_count         NUMBER;
  x_error_code                    NUMBER;


BEGIN
GMI_reservation_Util.PrintLn('(opm_dbg) Entering PVT u.');
x_return_status := FND_API.G_RET_STS_SUCCESS;

/*   GMI_Reservation_Util.Validation_before_Update(
           p_mtl_rsv_rec   => p_to_rsv_rec
          ,x_ic_tran_rec   => l_ic_tran_rec_out
          ,x_orgn_code     => x_orgn_code
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data);
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u : Error Returned by Validation_before_Update');
     FND_MESSAGE.SET_NAME('GMI','ERROR_IN_VALIDATION_BEFORE_UPDATE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
GMI_reservation_Util.PrintLn('ATTRIBUTE2 => ' || p_to_rsv_rec.attribute2);
GMI_reservation_Util.PrintLn('ATTRIBUTE3 => ' || p_to_rsv_rec.attribute3);

/*  The query_reservation may not have been called prior to getting here so call it now */
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Reinit GMI_Reservation_Util.ic_tran_rec_tbl, calling Query_Reservation.');
GMI_reservation_pub.Query_Reservation
                     ( p_api_version_number        => 1.0
                      ,p_init_msg_lst              => fnd_api.g_false
                      ,x_return_status             => x_return_status
                      ,x_msg_count                 => x_msg_count
                      ,x_msg_data                  => x_msg_data
                      ,p_validation_flag           => p_validation_flag
                      ,p_query_input               => p_original_rsv_rec
                      ,p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
                      ,x_mtl_reservation_tbl       => l_old_mtl_reservation_tbl
                      ,x_mtl_reservation_tbl_count => l_old_mtl_rsv_tbl_count
                      ,x_error_code                => x_error_code
                      ,p_lock_records              => fnd_api.g_false
                      ,p_sort_by_req_date          => inv_reservation_global.g_query_no_sort
                      );

/*  There may not be any rows*/
IF (GMI_Reservation_Util.ic_tran_rec_tbl.COUNT = 0) THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error No Rows Found in mtl_reservation');
   FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
   FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
   FND_MESSAGE.Set_Token('SO_LINE_ID', p_original_rsv_rec.demand_source_line_id);
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
END IF;

/*  There may have been a problem getting the rows*/
IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error Returned by Query_Reservation.');
   FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_reservation_pub.Query_Reservation');
   FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
END IF;

/*  At this point the table should have rows*/

/*  Retrieve the default lot transaction we'll need it later */
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u:: we have rows now calling Get_Default_Lot.');
GMI_Reservation_Util.Get_Default_Lot(
           x_ic_tran_pnd_index        => l_default_lot_index
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error Returned by Get_Default_Lot.');
    FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
    FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Default_Lot');
    FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END IF;

/*  Populate local default row to hold values for comparision*/
l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);

GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u:: saved default transaction to local rec.');

/*  ---------------------------------------------------------------------------------------*/
/*  Populate local original rec to hold values for comparision*/
/*  if this is not the default rec copy the original rec to l_original_tran_rec*/
/*  else this is the default rec copy the default rec to l_original_tran_rec*/
/*  ---------------------------------------------------------------------------------------*/
GMI_reservation_Util.PrintLn('opm_dbg) in PVT u: l_default_tran_rec.trans_id is ' || l_default_tran_rec.trans_id);
GMI_reservation_Util.PrintLn('opm_dbg) in PVT u: p_original_rsv_rec.reservation_id is ' || p_original_rsv_rec.reservation_id);
IF (l_default_tran_rec.trans_id <> p_original_rsv_rec.reservation_id)
THEN
      GMI_Reservation_Util.Get_Allocation(
                              p_trans_id          => p_original_rsv_rec.reservation_id
                             ,x_ic_tran_pnd_index => l_original_tran_index
                             ,x_return_status     => x_return_status
                             ,x_msg_count         => x_msg_count
                             ,x_msg_data          => x_msg_data);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error Returned by Get_Allocation.');
         FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
         FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Allocation');
         FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Not updating the default, save orig trans to local rec.');
      l_original_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_original_tran_index);
ELSE
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Updating the default, save default trans to local rec.');
      l_original_tran_rec := l_default_tran_rec;
END IF;

/*  -----------------------------------------------------------------------------------*/
/*  Convert the new rsv qty to the opm item uom*/
/*  This way it doesn't matter what the new rsv uom is */
/*  -----------------------------------------------------------------------------------*/
/*  map to rsv um to opm um*/
  IF p_to_rsv_rec.primary_reservation_quantity = FND_API.G_MISS_NUM
   or nvl(p_to_rsv_rec.primary_reservation_quantity,0) = 0 THEN
     l_to_rsv_qty := p_to_rsv_rec.reservation_quantity;
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: primary_res_qty is null and rsv qty is'||l_to_rsv_qty);
     l_to_rsv_um := p_to_rsv_rec.reservation_uom_code;
     --Begin Bug#3411704
     IF l_to_rsv_qty = FND_API.G_MISS_NUM THEN
        l_to_rsv_qty := p_original_rsv_rec.primary_reservation_quantity;
     END IF;
     --End Bug#3411704
     -- IF l_to_rsv_um is NULL THEN
     /* Bug 2882209*/
     -- PK Bug 3606481. l_to_rsv_um should not be compared to FND_API.G_MISS_NUM. Removed part of OR clause.
     IF (l_to_rsv_um is NULL OR l_to_rsv_um = FND_API.G_MISS_CHAR) THEN
        l_to_rsv_um := p_original_rsv_rec.reservation_uom_code;
     END IF;
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: rsv uom is'||l_to_rsv_um);
     GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM(p_apps_uom        => l_to_rsv_um
                                                 ,x_opm_uom         => l_opm_uom
                                                 ,x_return_status   => x_return_status
                                                 ,x_msg_count       => x_msg_count
                                                 ,x_msg_data        => x_msg_data);

  ELSE
     l_to_rsv_qty := p_to_rsv_rec.primary_reservation_quantity;
     l_opm_uom := l_original_tran_rec.trans_um;
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: primary_res_qty is not null '||l_to_rsv_qty);
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: uom '||l_opm_uom);
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_ERROR)
  THEN
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error Returned by Get_OPMUOMfromAppsUOM ');
       FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
       FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM');
       FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*  convert the new rsv qty to the item um qty*/
  IF (l_original_tran_rec.trans_um <> l_opm_uom)
  THEN
       GMICUOM.icuomcv(pitem_id => l_original_tran_rec.item_id
                      ,plot_id  => l_original_tran_rec.lot_id
                      ,pcur_qty => l_to_rsv_qty
                      ,pcur_uom => l_opm_uom
                      ,pnew_uom => l_original_tran_rec.trans_um
                      ,onew_qty => l_new_rsv_to_item_um_qty);
  ELSE
       l_new_rsv_to_item_um_qty := l_to_rsv_qty;
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: new qty'||l_new_rsv_to_item_um_qty);
  END IF;

/*  Okay Lets Check For Secondary Quantities. We should Store*/
/*  The Secondary Qty in p_to_rsv_rec. Attribute2 the UOM is*/
/*  Always the same as the transaction in IC_TRAN_PND*/
/*  Therefore there will be no conversions so Store the Value.*/

 GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: attribute2'||p_to_rsv_rec.attribute2);
IF p_to_rsv_rec.attribute2 = FND_API.G_MISS_CHAR or p_to_rsv_rec.attribute2 is null
THEN
     l_new_rsv_to_item_um_qty2 := NULL;
ELSE
     l_new_rsv_to_item_um_qty2 := to_number(p_to_rsv_rec.attribute2);
END IF;
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: qty2'||l_new_rsv_to_item_um_qty2);

/*  Compare reservation qtys if new qty is greater than old qty then add difference to the default*/
/*  l_orig_conv_to_new_rsv_qty is the same whether the uom changed or not, it is the new reservation quantity*/
/*  next we need to convert it to the ic_tran_pnd uom which is the item primary uom*/
/*  ---------------------------------------------------------------------------------*/
/*  If the new qty is greater than the old qty add the change to the default row qty*/
/*  ---------------------------------------------------------------------------------*/
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: l_new_rsv_to_item_um_qty is ' || l_new_rsv_to_item_um_qty);
GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: l_original_tran_rec.trans_qty is ' || l_original_tran_rec.trans_qty);
/* ======================================================= */
/*  if the trans_id is the default_lot's trans_id*/
/*  then*/
/*      Update the default_lot with Delta*/
/*  else*/
/*      if NewQty > OldQty*/
/*      then*/
/*          Update the default_lot with Delta*/
/*      else*/
/*          Delete the Allocated lot*/
/*          and */
/*          Update the default_lot with Delta*/
/*  endif*/
/*  endif*/
/* ======================================================= */
/*  Beginning of the process*/
/* =======================================================*/
/* bug 2240221*/
IF p_to_rsv_rec.requirement_date <> FND_API.G_MISS_DATE THEN
  l_default_tran_rec.trans_date := p_to_rsv_rec.requirement_date;
END IF;

IF (l_default_tran_rec.trans_id = p_original_rsv_rec.reservation_id)
THEN

    l_default_tran_rec.trans_qty  := -1 * ABS(l_new_rsv_to_item_um_qty);
    l_default_tran_rec.trans_qty2 := -1 * ABS(l_new_rsv_to_item_um_qty2);
    /*  l_default_tran_rec.non_inv := 0;*/
    GMI_reservation_Util.PrintLn('(opm_dbg)in PVT u: Update PRIM  default Lot  to:' || l_default_tran_rec.trans_qty );
    GMI_reservation_Util.PrintLn('(opm_dbg)in PVT u: Update SECO default Lot  to:' || l_default_tran_rec.trans_qty2 );
    GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
             p_api_version      => 1.0
            ,p_init_msg_list    => fnd_api.g_false
            ,p_commit           => l_commit
            ,p_validation_level => l_validation_level
            ,p_tran_rec         => l_default_tran_rec
            ,x_tran_row         => l_temp_tran_row
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.');
      FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
      FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

ELSE
    /*  the p_to_rsv_rec is not the default lot ...*/

    /*  If the new qty is less than the old qty, check the default row*/
    IF (l_new_rsv_to_item_um_qty >= ABS(l_original_tran_rec.trans_qty)) THEN
        /*  Here we have to update the default_lot, only.*/

       l_default_tran_rec.trans_qty := -1 * (ABS(l_default_tran_rec.trans_qty)                                         + ABS(l_new_rsv_to_item_um_qty));

       l_default_tran_rec.trans_qty2 := -1 * (ABS(l_default_tran_rec.trans_qty2)                                         + ABS(l_new_rsv_to_item_um_qty2));

        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: New qty is More than old ');
        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Update default row trans_qty to '|| l_default_tran_rec.trans_qty);
        GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
                           p_api_version      => 1.0
                          ,p_init_msg_list    => fnd_api.g_false
                          ,p_commit           => l_commit
                          ,p_validation_level => l_validation_level
                          ,p_tran_rec         => l_default_tran_rec
                          ,x_tran_row         => l_temp_tran_row
                          ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error returned by GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION.');
           FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
           FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
           FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        /*  --------------------------------------------------------------------*/
        /*  Otherwise call opm delete reservation to remove old allocation*/
        /*  -------------------------------------------------------------------- */
        GMI_reservation_Util.PrintLn('(opm_dbg) in UpdateReserv: The new rsv qty is smaller than the default qty.' );
        GMI_reservation_Util.PrintLn('(opm_dbg) in UpdateReserv: We must delete the old reservation.' );

        /*   Find the matching ic_tran_rec_tbl record for the rsv_rec passed in*/
        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: deleting allocation.');
        /*  This command will disappear when Query is changed to set it correctly*/
        /*  l_original_tran_rec.non_inv := 0;*/
        /*  Delete the record since it is not the default record*/
        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Deleting transaction record res_id='||p_original_rsv_rec.reservation_id);
        GMI_reservation_Util.PrintLn('(opm_dbg) trans_id='|| l_original_tran_rec.trans_id );

        GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION(
                              p_api_version      => 1.0
                             ,p_init_msg_list    => fnd_api.g_false
                             ,p_commit           => l_commit
                             ,p_validation_level => l_validation_level
                             ,p_tran_rec         => l_original_tran_rec
                             ,x_tran_row         => l_temp_tran_row
                             ,x_return_status    => x_return_status
                             ,x_msg_count        => x_msg_count
                             ,x_msg_data         => x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: ERROR Returned by Delete_Transaction().');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION');
            FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: After DELETE_PENDING_TRANSACTION.');

        /*  Transfer the deleted qties to the default_lot + new requested Values.*/
        l_default_tran_rec.trans_qty := -1 * (ABS(l_default_tran_rec.trans_qty)                                          + ABS(l_new_rsv_to_item_um_qty));

        l_default_tran_rec.trans_qty2:= -1 * (ABS(l_default_tran_rec.trans_qty2)                                        + ABS(l_new_rsv_to_item_um_qty2));


        /*  Using the modified copy update the default record by calling the transaction engine*/
        GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
                       p_api_version       => 1.0
                      ,p_init_msg_list     => fnd_api.g_false
                      ,p_commit            => l_commit
                      ,p_validation_level  => l_validation_level
                      ,p_tran_rec          => l_default_tran_rec
                      ,x_tran_row          => l_temp_tran_row
                      ,x_return_status     => x_return_status
                      ,x_msg_count         => x_msg_count
                      ,x_msg_data          => x_msg_data);

          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: ERROR Returned by Update_Pending_Transaction updating the default record.');
              FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
              FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;
END IF;

/*  -------------------------------------*/
/*  Re Query before leaving*/
/*  -------------------------------------*/
GMI_reservation_Util.PrintLn('(opm_dbg) in before leaving PVT u: calling Query_Reservation.');
GMI_reservation_pub.Query_Reservation
               ( p_api_version_number        => 1.0
                ,p_init_msg_lst              => fnd_api.g_false
                ,x_return_status             => x_return_status
                ,x_msg_count                 => x_msg_count
                ,x_msg_data                  => x_msg_data
                ,p_validation_flag           => p_validation_flag
                --,p_query_input               => p_to_rsv_rec
                ,p_query_input               => p_original_rsv_rec
                ,p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
                ,x_mtl_reservation_tbl       => l_old_mtl_reservation_tbl
                ,x_mtl_reservation_tbl_count => l_old_mtl_rsv_tbl_count
                ,x_error_code                => x_error_code
                ,p_lock_records              => fnd_api.g_false
                ,p_sort_by_req_date          => inv_reservation_global.g_query_no_sort
                );

/*  There may not be any rows*/
IF (GMI_Reservation_Util.ic_tran_rec_tbl.COUNT = 0)
THEN
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Called Query_Reservation Received NoError No Rows Found in mtl_reservation');
/*     FND_MESSAGE.Set_Name('GMI','GMI_QRY_RSV_NOT_FOUND');*/
/*     FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');*/
/*     FND_MESSAGE.Set_Token('SO_LINE_ID', p_to_rsv_rec.demand_source_line_id);*/
/*     FND_MSG_PUB.ADD;*/
/*     RAISE FND_API.G_EXC_ERROR;*/
END IF;

/*  There may have been a problem getting the rows*/
IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
THEN
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u: Error Returned by Query_Reservation.');
    FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
    FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Query_Reservation');
    FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END IF;


GMI_reservation_Util.PrintLn('(opm_dbg) leaving PVT u NO Error');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Expected');

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Others');

END Update_Reservation;



/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Delete_Reservation                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Delete reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Delete reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    x_return_status             OUT VARCHAR2     - Return Status          |
 |    x_msg_count                 OUT NUMBER       -                        |
 |    x_msg_data                  OUT VARCHAR2     -                        |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_rsv_rec                   IN  rec_type     -                        |
 |    p_serial_number             IN  rec_type     -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Delete_Reservation
  (
     x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_validation_flag          IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_rsv_rec                  IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number            IN  inv_reservation_global.serial_number_tbl_type
   ) IS

  l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Reservation';

  l_commit                      VARCHAR2(5)  := fnd_api.g_false;
  l_validation_level            VARCHAR2(4)  := fnd_api.g_valid_level_full;
  l_default_tran_rec            GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_to_delete_rec          GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_temp_tran_row               IC_TRAN_PND%ROWTYPE;
  l_default_lot_index           BINARY_INTEGER;
  l_allocated_lot_index         BINARY_INTEGER;
  l_default_lot_quantity1       NUMBER;
  l_default_lot_quantity2       NUMBER;
  l_new_default_lot_quantity1   NUMBER;
  l_new_default_lot_quantity2   NUMBER;
  x_error_code                  NUMBER;
  x_mtl_reservation_tbl_count   NUMBER;
  x_mtl_reservation_tbl         inv_reservation_global.mtl_reservation_tbl_type;

  -- Begin 3248046 (lswamy)
  Cursor get_line_rec(l_line_id IN NUMBER)IS
  Select ship_from_org_id
    From oe_order_lines_all
   Where line_id = l_line_id;

  Cursor get_whse_code(l_organization_id IN NUMBER) IS
  Select whse_code
    From ic_whse_mst
   Where mtl_organization_id = l_organization_id;

  l_organization_id NUMBER;
  l_whse_code VARCHAR2(5);
  -- End Bug3248046

BEGIN
  GMI_reservation_Util.PrintLn('(opm_dbg) in proc OPM_Reservation_PVT.OPM_Delete_reservation ');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: reservation_id='||p_rsv_rec.reservation_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: organization_id='||p_rsv_rec.organization_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: inventory_item_id='||p_rsv_rec.inventory_item_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: demand_source_type_id='||p_rsv_rec.demand_source_type_id||'.');
  /*  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: demand_source_name='||p_rsv_rec.demand_source_name||'.'); */
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: demand_source_header_id='||p_rsv_rec.demand_source_header_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: demand_source_line_id='||p_rsv_rec.demand_source_line_id||'.');
  GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: primary_uom_code='||p_rsv_rec.primary_uom_code||'.');

  /*  Initialize API return status to success*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*  Always re-Query before doing anything. */
  GMI_reservation_pub.Query_reservation
           (  p_api_version_number        => 1.0
            , p_init_msg_lst              => fnd_api.g_false
            , x_return_status             => x_return_status
            , x_msg_count                 => x_msg_count
            , x_msg_data                  => x_msg_data
            , p_validation_flag           => p_validation_flag
            , p_query_input               => p_rsv_rec
            , p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
            , x_mtl_reservation_tbl       => x_mtl_reservation_tbl
            , x_mtl_reservation_tbl_count => x_mtl_reservation_tbl_count
            , x_error_code                => x_error_code
            , p_lock_records              => fnd_api.g_false
            , p_sort_by_req_date          => inv_reservation_global.g_query_no_sort
            );

  /*  If we were able to find records then*/
  IF (GMI_Reservation_Util.ic_tran_rec_tbl.COUNT <= 0)
  THEN
        GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: No records found to delete.');
        FND_MESSAGE.Set_name('GMI','GMI_ERROR');
        FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Query_Reservation');
        FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  GMI_Reservation_Util.Get_Default_Lot(
              x_ic_tran_pnd_index        => l_default_lot_index
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
     GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: No records found to delete.');
     FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
     FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Default_Lot');
     FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*   Find the matching ic_tran_rec_tbl record for the rsv_rec passed in*/
  IF (p_rsv_rec.reservation_id <> GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index).trans_id)
  THEN
     /*  If the record is not the default record then just delete the record*/

       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: deleting allocation.');

       /*  Get the Allocation*/
       GMI_Reservation_Util.Get_Allocation(
              p_trans_id                 => p_rsv_rec.reservation_id
            , x_ic_tran_pnd_index        => l_allocated_lot_index
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data);

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Get_Allocation().');
         FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
         FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Get_Allocation');
         FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       /* added the following condition for OM changes when org id is changed
          the array does not contain newly created default lot*/
       IF l_allocated_lot_index <> 0 THEN
          /*  Save a copy of the record to be deleted*/
          l_tran_to_delete_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_allocated_lot_index);

          /*  This command will desappear whem Query is going to set it correctly*/
          /*  l_tran_to_delete_rec.non_inv := 0;*/
          /*  Delete the record since it is not the default record*/
          GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: Deleting transaction record res_id='||p_rsv_rec.reservation_id||', trans_id='||GMI_Reservation_Util.ic_tran_rec_tbl(l_allocated_lot_index).trans_id );

          GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION(
                                p_api_version      => 1.0
                               ,p_init_msg_list    => fnd_api.g_false
                               ,p_commit           => l_commit
                               ,p_validation_level => l_validation_level
                               ,p_tran_rec         => l_tran_to_delete_rec
                               ,x_tran_row         => l_temp_tran_row
                               ,x_return_status    => x_return_status
                               ,x_msg_count        => x_msg_count
                               ,x_msg_data         => x_msg_data);

          GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d After DELETE_PENDING_TRANSACTION.');

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
              GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Delete_Transaction().');
              FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
              FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION');
              FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

       END IF;
       l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);
       GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d: Qties to update: qty=='||l_default_tran_rec.trans_qty||', qty2='||l_default_tran_rec.trans_qty2);

       GMI_RESERVATION_UTIL.balance_default_lot
         ( p_ic_default_rec            => l_default_tran_rec
         , p_opm_item_id               => l_default_tran_rec.item_id
         , x_return_status             => x_return_status
         , x_msg_count                 => x_msg_count
         , x_msg_data                  => x_msg_data
         );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
       THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Update_Transaction() updating the default record.');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
            FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE

      -- Begin 3248046
      -- Bug3035697 ( as part of this bug, we eliminated update pending transaction
      -- and called balance_default_lot instead)
      -- We now conditionally call balance_default_lot

       GMI_reservation_Util.PrintLn('(opm_dbg) ELSE PORTION - Handling default transaction');
       l_default_tran_rec := GMI_Reservation_Util.ic_tran_rec_tbl(l_default_lot_index);

       OPEN  get_line_rec(l_default_tran_rec.line_id);
       FETCH get_line_rec INTO l_organization_id;
       CLOSE get_line_rec;

       OPEN  get_whse_code(l_organization_id);
       FETCH get_whse_code INTO l_whse_code;
       CLOSE get_whse_code;

       IF (l_whse_code <> l_default_tran_rec.whse_code) THEN
         GMI_reservation_Util.PrintLn('Calling Balancing when there is whse change');
         GMI_RESERVATION_UTIL.balance_default_lot
          ( p_ic_default_rec            => l_default_tran_rec
          , p_opm_item_id               => l_default_tran_rec.item_id
          , x_return_status             => x_return_status
          , x_msg_count                 => x_msg_count
          , x_msg_data                  => x_msg_data
          );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
         THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Balancing the default record.');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_RESERVATION_UTIL.balance_default_lot');
            FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

       ELSE
          /*  If the record is the default record then don't delete it just set the quantity to zero*/
         l_default_tran_rec.trans_qty  := 0 ;
         l_default_tran_rec.trans_qty2 := 0 ;
         GMI_reservation_Util.PrintLn('updating to zero for the default transction ');
         GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION(
                           p_api_version       => 1.0
                          ,p_init_msg_list     => fnd_api.g_false
                          ,p_commit            => l_commit
                          ,p_validation_level  => l_validation_level
                          ,p_tran_rec          => l_default_tran_rec
                          ,x_tran_row          => l_temp_tran_row
                          ,x_return_status     => x_return_status
                          ,x_msg_count         => x_msg_count
                          ,x_msg_data          => x_msg_data);
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
         THEN
            GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d ERROR: Returned by Update_Transaction() updating the default record.');
            FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
            FND_MESSAGE.Set_Token('BY_PROC', 'GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION');
            FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
       -- End Bug3248046
      /* cancel all the reservations for GME */
      GMI_reservation_Util.PrintLn('(opm_dbg)in balancing the default lot, cancel res');
      GML_BATCH_OM_RES_PVT.cancel_res_for_so_line
      (
         P_so_line_id             => l_default_tran_rec.line_id
       , X_return_status          => x_return_status
       , X_msg_cont               => x_msg_count
       , X_msg_data               => x_msg_data
      ) ;

    END IF;

GMI_reservation_Util.PrintLn('(opm_dbg) leaving PVT d NO Error');

/*  When there is an exception*/
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d EXCEPTION: Expected');

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT d EXCEPTION: Others');


END Delete_Reservation;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Transfer_Reservation                                                 |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Transfer reservation - Not Used, just a message                        |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Transfer reservation - Not Used, just a message                        |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT VARCHAR2     - Return Status          |
 |    x_msg_count                 OUT NUMBER       -                        |
 |    x_msg_data                  OUT VARCHAR2     -                        |
 |    p_is_transfer_supply        IN  VARCHAR2     -                        |
 |    p_original_rsv_rec          IN  rec_type     -                        |
 |    p_to_rsv_rec                IN  rec_type     -                        |
 |    p_original_serial_number    IN  rec_type     -                        |
 |    p_to_serial_number          IN  rec_type     -                        |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    x_to_reservation_id         OUT NUMBER       -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Transfer_Reservation
  (
     p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_is_transfer_supply            IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , x_to_reservation_id             OUT NOCOPY NUMBER
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Transfer_Reservation';

BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_RSV_UNAVAILABLE');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Transfer_Reservation;

/* Bug 3297382 Forward Declaration of Calc_Reservation_For_shipset */

PROCEDURE  Calc_Reservation_For_shipset(
                    p_shipset_id              IN NUMBER,
                    p_organization_id         IN NUMBER,
                    p_item_id                 IN NUMBER,
                    p_source_header_id        IN NUMBER,
                    p_whse_code               IN VARCHAR2,
                    p_whse_loct_ctl           IN NUMBER,
                    p_chk_inv                 IN VARCHAR2,
                    p_requested_quantity      IN NUMBER,
                    p_requested_quantity2     IN NUMBER DEFAULT NULL,
                    x_shipset_reserved        OUT NOCOPY VARCHAR2);


/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    calculate_reservation                                                 |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   This procedure calculates qty used for a specific item                 |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |       p_organization_id          IN NUMBER                               |
 |       p_item_id                  IN NUMBER                               |
 |       p_demand_source_line_id    IN NUMBER                               |
 |       p_requested_quantity       IN NUMBER                               |
 |       p_requested_quantity2      IN NUMBER DEFAULT NULL                  |
 |       x_result_qty1              OUT NUMBER                              |
 |       x_result_qty2              OUT NUMBER                              |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |    September, 2001 Hasan Wahdani                                         |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/

-- HW BUG#:1941429 added a new procedure to calculate reservation and remaining qty
-- for cross_docking
   PROCEDURE Calculate_Reservation(
   p_organization_id         IN NUMBER,
   p_item_id                 IN NUMBER,
   p_demand_source_line_id   IN NUMBER,
   p_delivery_detail_id      IN NUMBER,
   p_requested_quantity      IN NUMBER,
   p_requested_quantity2     IN NUMBER DEFAULT NULL,
   x_result_qty1             OUT NOCOPY NUMBER,
   x_result_qty2             OUT NOCOPY NUMBER
   )IS

l_demand_exists BOOLEAN;
l_count NUMBER := 0;
l_reservation_quantity NUMBER := 0;
l_reservation_quantity2 NUMBER := 0;
l_onhand_qty NUMBER := 0;
l_onhand_qty2 NUMBER := 0;
l_committedsales_qty NUMBER := 0;
l_committedsales_qty2 NUMBER := 0;
l_trans_qty NUMBER := 0;
l_trans_qty2 NUMBER := 0;
l_used_reserved_quantity NUMBER := 0;
l_used_reserved_quantity2 NUMBER := 0;
l_index NUMBER := 0;
l_whse_code VARCHAR2(5);
l_is_grade_ctl VARCHAR2(2);
l_chk_inv VARCHAR2(5);
x_return_status VARCHAR2(20);
l_status VARCHAR2(4);
l_qty_reserved NUMBER;
l_qty2_reserved NUMBER;
l_qty_reserved_default NUMBER;
l_qty2_reserved_default NUMBER;
l_qty_reserved_real NUMBER;
l_qty2_reserved_real NUMBER;
l_qty_remaining NUMBER;
l_qty2_remaining NUMBER;
/* bug 2499153 */
l_item_loct_ctl NUMBER;
l_whse_loct_ctl NUMBER;
l_lot_ctl       NUMBER;
l_noninv_ind    NUMBER;
l_inventory_item_id    NUMBER;
l_is_noctl      BOOLEAN := FALSE;
l_def_trans_qty  NUMBER := 0;
l_def_trans_qty2 NUMBER := 0;
l_default_loct   VARCHAR2(4) := fnd_profile.value('IC$DEFAULT_LOCT');
/* Bug 3297382  shipset declarations */
l_shipset_id     NUMBER;
l_source_header_id NUMBER;
l_shipset_reserved VARCHAR2(1);
l_enforce_shipset  VARCHAR2(1);
--Bug 3551144
l_high_lev_res_qty  NUMBER := 0;
l_high_lev_res_qty2 NUMBER := 0;
l_real_high_lev_res_qty  NUMBER := 0;
l_real_high_lev_res_qty2 NUMBER := 0;
l_net_high_lev_res_qty  NUMBER := 0;
l_net_high_lev_res_qty2 NUMBER := 0;

-- Get qty on hand
   CURSOR qty_on_hand(l_whse_code VARCHAR2,p_item_id NUMBER) IS
   SELECT SUM(nvl(s.onhand_order_qty,0)),
          SUM(nvl(s.onhand_order_qty2,0)),
          SUM(nvl(s.committedsales_qty,0)),
          SUM(nvl(s.committedsales_qty2,0))
   FROM   ic_summ_inv s
   WHERE  s.item_id = p_item_id
   AND    s.whse_code = l_whse_code;

-- Get whse information
  CURSOR get_whse_code (l_organization_id NUMBER ) IS
  SELECT whse_code ,loct_ctl
  FROM IC_WHSE_MST
  WHERE mtl_organization_id = l_organization_id ;

-- Get item ctl
   CURSOR get_item_ctl  IS
   SELECT loct_ctl,lot_ctl,noninv_ind
     FROM ic_item_mst
    WHERE item_id=p_item_id;

  -- Get the inventory_item_id for the org
  Cursor get_inventory_item_id IS
  Select inventory_item_id
  From mtl_system_items_b mtl
     , ic_item_mst ic
  Where ic.item_id = p_item_id
    and mtl.organization_id = p_organization_id
    and ic.item_no = mtl.segment1;

  -- Get the allocated qty, this part is not deducted from onhand yet
  CURSOR reserved_quantity_real(p_item_id NUMBER
                               ,l_whse_code VARCHAR2) is
  SELECT ABS(SUM(nvl(trans_qty,0))),
         ABS(SUM(nvl(trans_qty2,0)))
  FROM   ic_tran_pnd
  WHERE  item_id = p_item_id
  AND    whse_code = l_whse_code
  AND    (lot_id <> 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
  AND    completed_ind = 0
  AND    delete_mark = 0
  AND    trans_qty < 0;                 -- pending incoming is sorta available, but not real yet
                                        -- Only at the time this qty is received, it becomes truely available

  CURSOR reserved_quantity_nonctl( p_organization_id NUMBER
                                  ,p_inventory_item_id NUMBER ) is
  Select sum(nvl(requested_quantity,0)), sum(nvl(requested_quantity2,0))
  From wsh_delivery_details
  Where organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id
    and released_status in ('S', 'Y');

  -- Get the allocated qty for this delivery detail line
  CURSOR Get_trans_for_del IS
  SELECT ABS(SUM(nvl(trans_qty,0))),
         ABS(SUM(nvl(trans_qty2,0)))
  FROM   ic_tran_pnd
  WHERE  line_id = p_demand_source_line_id
  AND    line_detail_id = p_delivery_detail_id
  AND    doc_type='OMSO'
  AND    completed_ind = 0
  AND    delete_mark = 0;

/* Bug 3297382  shipset cursor declarations */
  CURSOR get_shipset_id IS
  SELECT nvl(ship_set_id, 0), source_header_id
  FROM   wsh_delivery_details
  WHERE  delivery_detail_id = p_delivery_detail_id;

  CURSOR Shipping_parameters( v_org_id IN NUMBER) IS
  SELECT NVL(ENFORCE_SHIP_SET_AND_SMC,'N')
  FROM   WSH_SHIPPING_PARAMETERS
  WHERE  ORGANIZATION_ID = v_org_id;

--Bug 3551144
  -- Get high level reserved qty. That is sum of requested qtys for all delivery detail lines which are
  -- relesed to warehouse for a given warehouse and item combination.
  CURSOR high_level_reserved_qty(p_organization_id NUMBER, p_inventory_item_id NUMBER) is
  SELECT NVL(sum(nvl(requested_quantity,0)),0), NVL(sum(nvl(requested_quantity2,0)),0)
  FROM   wsh_delivery_details
  WHERE  organization_id   = p_organization_id
  AND    inventory_item_id = p_inventory_item_id
  AND    source_code       = 'OE'
  AND    released_status   = 'S';

--Bug 3551144
  --Get sum of allocated qty against high level reserved qty
  CURSOR high_level_res_qty_real(p_item_id NUMBER,l_whse_code VARCHAR2) is
  SELECT NVL(ABS(SUM(nvl(trans_qty,0))),0), NVL(ABS(SUM(nvl(trans_qty2,0))),0)
  FROM   ic_tran_pnd itp
  WHERE  item_id   = p_item_id
  AND    whse_code = l_whse_code
  AND    (lot_id <> 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
  AND    completed_ind = 0
  AND    delete_mark   = 0
  AND    trans_qty     < 0
  AND  EXISTS(SELECT 1
              FROM   wsh_delivery_details
              WHERE  delivery_detail_id = itp.line_detail_id
              AND    source_code       = 'OE'
              AND    released_status   = 'S');

 BEGIN

  gmi_reservation_util.println('value of  is p_organization_id'|| p_organization_id);
  gmi_reservation_util.println('value of p_demand_source_line_id is ' ||p_demand_source_line_id);
  gmi_reservation_util.println('Value of item_id is '||p_item_id);
  gmi_reservation_util.println('value of p_requested_quantity is '||p_requested_quantity);
  gmi_reservation_util.println('value of p_requested_quantity2 is '||p_requested_quantity2);


-- Get whse code
   OPEN get_whse_code (p_organization_id);
   FETCH get_whse_code INTO l_whse_code,l_whse_loct_ctl;
   IF ( get_whse_code%NOTFOUND ) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     GMI_RESERVATION_UTIL.PRINTLN('Error retrieving whse code');
     RAISE NO_DATA_FOUND;
     CLOSE get_whse_code;
     RETURN;
   END IF;

   CLOSE get_whse_code;

   gmi_reservation_util.PRINTLN('Value of Whse Code is '||l_whse_code);
-- Get value of profile
-- l_is_grade_ctl := FND_PROFILE.VALUE('IC$AVAILABLE_BY_GRADE');


-- Bug 2499153. Get item ctl.
   OPEN  get_item_ctl;
   FETCH get_item_ctl INTO l_item_loct_ctl, l_lot_ctl, l_noninv_ind;
   CLOSE get_item_ctl;

   IF (l_lot_ctl = 0 AND (l_item_loct_ctl * l_whse_loct_ctl)= 0) THEN
     l_is_noctl := TRUE;
     GMI_Reservation_Util.PrintLn('Working with no control item');
   END IF;

-- End Bug 2499153

   Open  get_inventory_item_id;
   Fetch get_inventory_item_id into l_inventory_item_id;
   Close get_inventory_item_id;

   l_chk_inv := FND_PROFILE.VALUE('GML_CHK_INV_PICK_REL');



   gmi_reservation_util.println('check profile GML_CHK_INV_PICK_REL is '||l_chk_inv);
   IF (l_chk_inv = 'N' OR l_noninv_ind = 1 ) THEN
     x_result_qty1 := p_requested_quantity;
     x_result_qty2 := p_requested_quantity2;
     RETURN;
   END IF;

   -- Bug 3297382 If the line belongs to a shipset call new procedure Calculate_reservation_for_shipset

   OPEN get_shipset_id;
   FETCH get_shipset_id INTO l_shipset_id, l_source_header_id;
   CLOSE get_shipset_id;

   IF (l_shipset_id <> 0) THEN

     gmi_reservation_util.println('Line has Shipset '||l_shipset_id);

     -- Now check if shipping Parameter for the warehouse have Enforce shipset flag set.
     OPEN Shipping_parameters(p_organization_id);
     FETCH Shipping_parameters INTO l_enforce_shipset;
     CLOSE Shipping_parameters;

     gmi_reservation_util.println('Enforce shipset in Shipping parameters for the warehouse is set as  '||l_enforce_shipset);

     IF ( l_enforce_shipset = 'Y') THEN

       gmi_reservation_util.println('Line Has Shipset and shipset is enforced for the warehouse');
       gmi_reservation_util.println('Calling Calc_Reservation_For_shipset');

       Calc_Reservation_For_shipset(
          p_shipset_id           => l_shipset_id
         ,p_organization_id      => p_organization_id
         ,p_item_id              => p_item_id
         ,p_source_header_id     => l_source_header_id
         ,p_whse_code            => l_whse_code
         ,p_whse_loct_ctl        => l_whse_loct_ctl
         ,p_chk_inv              => l_chk_inv
         ,p_requested_quantity   => p_requested_quantity
         ,p_requested_quantity2  => p_requested_quantity2
         ,x_shipset_reserved     => l_shipset_reserved
         );

        IF (l_shipset_reserved = 'Y') THEN
           x_result_qty1 := p_requested_quantity;
           x_result_qty2 := p_requested_quantity2;
           RETURN;
        ELSE
           x_result_qty1 := 0;
           x_result_qty2 := 0;
           RETURN;
        END IF;
     END IF;  -- ( l_enforce_shipset = 'Y')
   END IF; -- (l_shipset_id <> 0)

   -- End Bug 3297382 Shipset enhancement

   l_demand_exists := FALSE;
     FOR i in 1..g_demand_table.COUNT LOOP
       IF (g_demand_table(i).item_id= p_item_id AND
           g_demand_table(i).whse_code = l_whse_code) THEN
         l_index := i;
         l_demand_exists := TRUE;
         gmi_reservation_util.println('Value of item_id found in loop is '||g_demand_table(i).item_id);
         gmi_reservation_util.println('In opm calculate_reservation Found the Reservation Details');
         gmi_reservation_util.println('value of g_demand_table(l_count).qty_available found is '||g_demand_table(i).qty_available);
         gmi_reservation_util.println('value of g_demand_table(l_count).qty_committed found is '||g_demand_table(i).qty_committed);
         gmi_reservation_util.println('value of g_demand_table(l_count).qty2_available found is '||g_demand_table(i).qty2_available);
         gmi_reservation_util.println('value of g_demand_table(l_count).qty2_committed found is '||g_demand_table(i).qty2_committed);
         EXIT;
       END IF;
     END LOOP;

   IF (not l_demand_exists) THEN
     gmi_reservation_util.Println('Fetching Reservation Details');

     IF (l_is_noctl = TRUE) THEN
       gmi_reservation_util.Println('inventory_item_id is '||l_inventory_item_id);
       OPEN  reserved_quantity_nonctl(p_organization_id,l_inventory_item_id);
       FETCH reserved_quantity_nonctl INTO l_qty_reserved_real,l_qty2_reserved_real;
       CLOSE reserved_quantity_nonctl;
     ELSE
       OPEN reserved_quantity_real(p_item_id,l_whse_code);
       FETCH reserved_quantity_real into l_qty_reserved_real,l_qty2_reserved_real;
       CLOSE reserved_quantity_real;
     END IF;
     l_qty_reserved_real := nvl(l_qty_reserved_real, 0);
     l_qty2_reserved_real := nvl(l_qty2_reserved_real, 0);

     gmi_reservation_util.println('value of l_qty_reserved_real '|| l_qty_reserved_real);
     gmi_reservation_util.println('value of l_qty2_reserved_real '|| l_qty2_reserved_real);

-- Let's increment the counter

     l_count := g_demand_table.COUNT + 1;

     g_demand_table(l_count).item_id := p_item_id;
     g_demand_table(l_count).whse_code := l_whse_code;

     --Bug 3551144 added OR condition
      IF (l_chk_inv = 'Y' OR l_chk_inv = 'S') THEN
         OPEN  qty_on_hand(l_whse_code,p_item_id);
         FETCH qty_on_hand INTO
         g_demand_table(l_count).qty_available,
         g_demand_table(l_count).qty2_available,
         g_demand_table(l_count).qty_committed,
         g_demand_table(l_count).qty2_committed ;
         CLOSE qty_on_hand;
      END IF;

      --begin bug 3551144
        IF (l_chk_inv = 'S') THEN
           -- In case of l_is_noctl = TRUE high_level_reserved_qty is considered as part of l_qty_reserved_real
           IF (l_is_noctl = FALSE) THEN
              OPEN  high_level_reserved_qty(p_organization_id,l_inventory_item_id);
              FETCH high_level_reserved_qty INTO l_high_lev_res_qty, l_high_lev_res_qty2;
              CLOSE high_level_reserved_qty;
              gmi_reservation_util.println('value of l_high_lev_res_qty '||l_high_lev_res_qty);
              gmi_reservation_util.println('value of l_high_lev_res_qty2 '||l_high_lev_res_qty2);
              OPEN  high_level_res_qty_real(p_item_id,l_whse_code);
              FETCH high_level_res_qty_real into l_real_high_lev_res_qty,l_real_high_lev_res_qty2;
              CLOSE high_level_res_qty_real;
              gmi_reservation_util.println('value of l_real_high_lev_res_qty '||l_real_high_lev_res_qty);
              gmi_reservation_util.println('value of l_real_high_lev_res_qty2 '||l_real_high_lev_res_qty2);
              l_net_high_lev_res_qty  := l_high_lev_res_qty - l_real_high_lev_res_qty;
              l_net_high_lev_res_qty2 := l_high_lev_res_qty2 - l_real_high_lev_res_qty2;
              IF l_net_high_lev_res_qty < 0 THEN  -- This could happen in case of over allocation.
                 l_net_high_lev_res_qty  := 0;
                 l_net_high_lev_res_qty2 := 0;
              END IF;
              gmi_reservation_util.println('value of l_net_high_lev_res_qty '||l_net_high_lev_res_qty);
              gmi_reservation_util.println('value of l_net_high_lev_res_qty2 '||l_net_high_lev_res_qty2);
              g_demand_table(l_count).qty_available  := g_demand_table(l_count).qty_available  - l_net_high_lev_res_qty;
              g_demand_table(l_count).qty2_available := g_demand_table(l_count).qty2_available - l_net_high_lev_res_qty2;
           END IF;
        END IF;
      --end bug 3551144

        g_demand_table(l_count).qty_available  := nvl(g_demand_table(l_count).qty_available ,0);
        g_demand_table(l_count).qty2_available := nvl(g_demand_table(l_count).qty2_available,0);
        g_demand_table(l_count).qty_committed  := nvl(g_demand_table(l_count).qty_committed, 0);
        g_demand_table(l_count).qty2_committed := nvl(g_demand_table(l_count).qty2_committed,0);
        gmi_reservation_util.println('value of g_demand_table(l_count).qty_available '||g_demand_table(l_count).qty_available);
        gmi_reservation_util.println('value of g_demand_table(l_count).qty2_available '||g_demand_table(l_count).qty2_available);
        gmi_reservation_util.println('value of g_demand_table(l_count).qty_committed '||g_demand_table(l_count).qty_committed);
        gmi_reservation_util.println('value of g_demand_table(l_count).qty2_committed '||g_demand_table(l_count).qty2_committed);

        l_index := l_count;

    --Bug 3551144 added OR condition
     IF (l_chk_inv = 'Y' OR l_chk_inv = 'S') THEN
        g_demand_table(l_index).qty_available  :=  g_demand_table(l_index).qty_available - l_qty_reserved_real;
        g_demand_table(l_index).qty2_available :=  g_demand_table(l_index).qty2_available - l_qty2_reserved_real;
     END IF;

     IF g_demand_table(l_index).qty_available < 0 THEN
        g_demand_table(l_index).qty_available := 0;
        g_demand_table(l_index).qty2_available := 0;
     END IF;
     IF g_demand_table(l_index).qty2_available < 0 THEN
        g_demand_table(l_index).qty2_available := 0;
     END IF;
   END IF; -- of not l_demand_exists

   -- Let's get qty reserved from ic_tran_pnd
   gmi_reservation_util.println('value of p_demand_source_line_id before calling res_qty is '||p_demand_source_line_id);
   gmi_reservation_util.println('Value of p_item_id before calling res_q is '||p_item_id);
   gmi_reservation_util.println('Value of l_whse_code before calling res_q is '||l_whse_code);

   IF (l_is_noctl = TRUE) THEN
     l_qty_reserved  := 0;
     l_qty2_reserved := 0;
   ELSE
     OPEN  get_trans_for_del;
     FETCH get_trans_for_del into l_qty_reserved,l_qty2_reserved;
     CLOSE get_trans_for_del;
   END IF;
   l_qty_reserved := nvl(l_qty_reserved, 0);
   l_qty2_reserved := nvl(l_qty2_reserved, 0);

   gmi_reservation_util.println('Value of l_qty_reserved is '||l_qty_reserved);
   gmi_reservation_util.println('Value of l_qty2_reserved is '||l_qty2_reserved);
   gmi_reservation_util.println('value of l_count before checking is '||l_count);
   gmi_reservation_util.println('Value of l_index before checking is '||l_index);

   l_qty_remaining := p_requested_quantity - l_qty_reserved;
   l_qty2_remaining := p_requested_quantity2 - l_qty2_reserved;

   gmi_reservation_util.println('Value of remainig requested qty is '||l_qty_remaining);
   gmi_reservation_util.println('Value of remainig requested qty2 is '||l_qty2_remaining);
   gmi_reservation_util.println('Value of g_demand_table(l_index).qty_available '||g_demand_table(l_index).qty_available);

   IF l_qty_remaining <= 0 THEN
     x_result_qty1 := p_requested_quantity;
     x_result_qty2 := p_requested_quantity2;
   ELSE -- remaining qty is > 0
     IF ( g_demand_table(l_index).qty_available - l_qty_remaining >= 0 ) THEN
       gmi_reservation_util.println('RELEASE TO WHSE');
       gmi_reservation_util.println('Returning Qty reserved from calculate_reservation');
       x_result_qty1 := p_requested_quantity;
       x_result_qty2 := p_requested_quantity2;
       g_demand_table(l_index).qty_available := g_demand_table(l_index).qty_available - p_requested_quantity ;
       g_demand_table(l_index).qty2_available := nvl(g_demand_table(l_index).qty2_available - p_requested_quantity2,0) ;
       gmi_reservation_util.println('x_result_qty1 '||x_result_qty1);
       gmi_reservation_util.println('x_result_qty2 '||x_result_qty2);

     ELSIF ( g_demand_table(l_index).qty_available - l_qty_remaining < 0
             AND g_demand_table(l_index).qty_available > 0 ) THEN -- SPLIT
       gmi_reservation_util.println('SPLIT');
       gmi_reservation_util.println('Returning Qty available from caclulate_reservation');
       x_result_qty1 :=  g_demand_table(l_index).qty_available + l_qty_reserved;
       x_result_qty2 :=  g_demand_table(l_index).qty2_available + l_qty2_reserved;
       IF x_result_qty2 < 0 THEN
          x_result_qty2 := 0;
       END IF;
       g_demand_table(l_index).qty_available := g_demand_table(l_index).qty_available
                  - x_result_qty1 ;
       g_demand_table(l_index).qty2_available := nvl(g_demand_table(l_index).qty2_available
                  - x_result_qty2,0) ;
       gmi_reservation_util.println('x_result_qty1 '||x_result_qty1);
       gmi_reservation_util.println('x_result_qty2 '||x_result_qty2);

     ELSIF ( g_demand_table(l_index).qty_available <= 0 )THEN -- Backorder line
       /*gmi_reservation_util.println('BACKORDER');
       gmi_reservation_util.println('Returning 0 from calculate_reservation');*/
       x_result_qty1 := 0;
       x_result_qty2 := 0;
       --/* bug 2585286, if the availability at high level has already been driven to sub-zero
       -- * need to check the real allocations for the del because user still can allocate a perticular
       -- * lot-location in order pad, this piece should be allowed to move to whse -- */
       IF nvl(l_qty_reserved,0) <> 0 THEN
          x_result_qty1 := l_qty_reserved;
          x_result_qty2 := l_qty2_reserved;
       END IF;
       g_demand_table(l_index).qty_available := g_demand_table(l_index).qty_available
                  - l_qty_reserved ;
       g_demand_table(l_index).qty2_available := nvl(g_demand_table(l_index).qty2_available
                  - l_qty2_reserved,0) ;
       IF x_result_qty1 <> 0 THEN
          gmi_reservation_util.println('RELEASE qty1 '|| x_result_qty1 || ' TO WHSE because detail reservatin exists');
          gmi_reservation_util.println('x_result_qty1 '||x_result_qty1);
          gmi_reservation_util.println('x_result_qty2 '||x_result_qty2);
       ELSE
          gmi_reservation_util.println('BACKORDER');
          gmi_reservation_util.println('Returning 0 from calculate_reservation');
          gmi_reservation_util.println('x_result_qty1 '||x_result_qty1);
          gmi_reservation_util.println('x_result_qty2 '||x_result_qty2);
       END IF;
     END IF;
   END IF;

   return;

  EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN NO_DATA_FOUND THEN
     GMI_RESERVATION_UTIL.PRINTLN('No Data found raised error in GMI_Reservation_PVT.calculate_reservation');

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     GMI_RESERVATION_UTIL.PRINTLN('RAISE WHEN OTHERS');


   END Calculate_Reservation;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Check_Shipping_Details                                                |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Check the released_status of the shipping details in order to          |
 |   raise a message if there is a released_status = Y (staged)             |
 |                                                or C (shipped)            |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_rsv_rec                   IN  rec_type     -                        |
 |    x_return_status             OUT VARCHAR2     - Return Status          |
 |    x_msg_count                 OUT NUMBER       -                        |
 |    x_msg_data                  OUT VARCHAR2     -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     02-OCT-2001  odaboval        Created, bug 2025611                    |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Check_Shipping_Details
   ( p_rsv_rec                  IN  inv_reservation_global.mtl_reservation_rec_type
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Shipping_Details';
l_released_status    VARCHAR2(2);


-- odaboval, Oct-2001, standalone fix for Tropicana.
CURSOR c_get_wsh_released_status( l_so_line_id IN NUMBER) IS
SELECT released_status
FROM wsh_delivery_details
WHERE released_status IN ('Y', 'C')
AND source_line_id = l_so_line_id;

BEGIN

/*  Initialize API return status to success */
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_get_wsh_released_status(p_rsv_rec.demand_source_line_id);
FETCH c_get_wsh_released_status
   INTO l_released_status;

IF (c_get_wsh_released_status%NOTFOUND)
THEN
   -- There is no problem, the user can delete_reservation.
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT Check_Shipping_Details, Unreserve is allowed. ');
ELSE
   GMI_reservation_Util.PrintLn('(opm_dbg) in PVT Check_Shipping_Details, Unreserve is forbidden. ');
   x_return_status := FND_API.G_RET_STS_ERROR;
END IF;

CLOSE c_get_wsh_released_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF c_get_wsh_released_status%ISOPEN THEN
         CLOSE c_get_wsh_released_status;
      END IF;

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT Check_Shipping_Details EXCEPTION: Others, SqlCode='||SQLCODE);

      IF c_get_wsh_released_status%ISOPEN THEN
         CLOSE c_get_wsh_released_status;
      END IF;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );



END Check_Shipping_Details;

PROCEDURE query_qty_for_ATP(
   p_organization_id         IN NUMBER,
   p_item_id                 IN NUMBER,
   p_demand_source_line_id   IN NUMBER,
   x_onhand_qty1             OUT NOCOPY NUMBER,
   x_onhand_qty2             OUT NOCOPY NUMBER,
   x_avail_qty1              OUT NOCOPY NUMBER,
   x_avail_qty2              OUT NOCOPY NUMBER
   )IS

l_onhand_qty1                NUMBER := 0;
l_onhand_qty2                NUMBER := 0;
l_committedsales_qty1        NUMBER := 0;
l_committedsales_qty2        NUMBER := 0;
l_trans_qty                  NUMBER := 0;
l_trans_qty2                 NUMBER := 0;
l_whse_code                  VARCHAR2(5);
l_grade                      VARCHAR2(6);
l_qty_reserved               NUMBER := 0;
l_qty2_reserved              NUMBER := 0;
l_qty_reserved_default       NUMBER := 0;
l_qty2_reserved_default      NUMBER := 0;
l_qty_reserved_real          NUMBER := 0;
l_qty2_reserved_real         NUMBER := 0;
l_qty_available              NUMBER := 0;
l_qty2_available             NUMBER := 0;
l_grade_ctl                  NUMBER := 0;

-- Get qty on hand
   CURSOR qty_on_hand(l_whse_code VARCHAR2,p_item_id NUMBER) IS
   SELECT SUM(nvl(s.onhand_order_qty,0)),
          SUM(nvl(s.onhand_order_qty2,0)),
          SUM(nvl(s.committedsales_qty,0)),
          SUM(nvl(s.committedsales_qty2,0))
   FROM   ic_summ_inv s
   WHERE  s.item_id = p_item_id
   AND    s.whse_code = l_whse_code;

-- Get whse information
  CURSOR get_whse_code (l_organization_id NUMBER ) IS
  SELECT whse_code
  FROM IC_WHSE_MST
  WHERE mtl_organization_id = l_organization_id ;

-- get grade_ctl
  Cursor get_grade_ctl IS
  Select grade_ctl
  from ic_item_mst
  where item_id=p_item_id;

  -- Get qty reserved for this order line for a grade
  CURSOR reserved_quantity_for_grd(l_whse_code VARCHAR2,
                                   p_item_id NUMBER,
                                   l_qc_grade VARCHAR2) is
  SELECT SUM(nvl(trans_qty,0)),
         SUM(nvl(trans_qty2,0))
  FROM   ic_tran_pnd
  WHERE  item_id = p_item_id
--  AND    line_id = p_demand_source_line_id
  AND    whse_code = l_whse_code
  AND    completed_ind = 0
  AND    delete_mark = 0
--  AND    doc_type='OMSO'
  AND    qc_grade = l_qc_grade
  AND line_type = decode(doc_type,'PROD',-1,line_type); --Bug3163165

  CURSOR reserved_quantity_for_atp(l_whse_code VARCHAR2,
                                   p_item_id NUMBER) is
  SELECT SUM(nvl(trans_qty,0)),
         SUM(nvl(trans_qty2,0))
  FROM   ic_tran_pnd
  WHERE  item_id = p_item_id
--  AND    line_id = p_demand_source_line_id
  AND    whse_code = l_whse_code
  AND    completed_ind = 0
  AND    delete_mark = 0
  AND line_type = decode(doc_type,'PROD',-1,line_type); --Bug3163165

-- Get qty on hand for a grade
   CURSOR qty_on_hand_grade(l_whse_code VARCHAR2,
                            p_item_id NUMBER,
                            l_qc_grade VARCHAR2) IS
   SELECT SUM(nvl(s.onhand_order_qty,0)),
          SUM(nvl(s.onhand_order_qty2,0)),
          SUM(nvl(s.committedsales_qty,0)),
          SUM(nvl(s.committedsales_qty2,0))
   FROM   ic_summ_inv s
   WHERE  s.item_id = p_item_id
   AND    s.whse_code = l_whse_code
   AND    s.qc_grade = l_qc_grade
   ;

-- Get the committed sales for this order line
  CURSOR Get_trans_for_null_del IS            -- this would include the default lot
  SELECT SUM(ABS(nvl(trans_qty,0))),
         SUM(ABS(nvl(trans_qty2,0)))
  FROM   ic_tran_pnd
  WHERE  line_id = p_demand_source_line_id
  AND    doc_type='OMSO'
  AND    completed_ind = 0
  AND    delete_mark = 0;

 Cursor c_get_grade (p_line_id number) IS
 SELECT preferred_grade
 FROM oe_order_lines_all
 WHERE line_id = p_line_id;

 BEGIN

  gmi_reservation_util.println('value of  is p_organization_id'|| p_organization_id);
  gmi_reservation_util.println('value of p_demand_source_line_id is ' ||p_demand_source_line_id);
  gmi_reservation_util.println('Value of item_id is '||p_item_id);

-- Get whse code
   OPEN get_whse_code (p_organization_id);
   FETCH get_whse_code INTO l_whse_code;
   IF ( get_whse_code%NOTFOUND ) THEN
     GMI_RESERVATION_UTIL.PRINTLN('Error retrieving whse code');
     RAISE NO_DATA_FOUND;
     CLOSE get_whse_code;
     RETURN;
   END IF;

   CLOSE get_whse_code;

   gmi_reservation_util.PRINTLN('Value of Whse Code is '||l_whse_code);
   Open get_grade_ctl;
   Fetch get_grade_ctl Into l_grade_ctl;
   Close get_grade_ctl;
   gmi_reservation_util.Println('For ATP window');
   OPEN c_get_grade(p_demand_source_line_id);
   FETCH c_get_grade into l_grade;
   CLOSE c_get_grade;

   IF (l_grade_ctl > 0 and l_grade is not null) THEN
      gmi_reservation_util.Println('For grade ');
      OPEN reserved_quantity_for_grd(l_whse_code,p_item_id,l_grade);
      FETCH reserved_quantity_for_grd into l_qty_reserved_real,l_qty2_reserved_real;
      CLOSE reserved_quantity_for_grd;
   ELSE   -- not grade ctl
      gmi_reservation_util.Println('For NON grade ');
      OPEN reserved_quantity_for_atp(l_whse_code,p_item_id);
      FETCH reserved_quantity_for_atp into l_qty_reserved_real,l_qty2_reserved_real;
      CLOSE reserved_quantity_for_atp;
   END IF;
   l_qty_reserved_real := nvl(l_qty_reserved_real, 0);
   l_qty2_reserved_real := nvl(l_qty2_reserved_real, 0);
   gmi_reservation_util.Println('total reserved in ic_tran_pnd qty '|| l_qty_reserved_real);
   gmi_reservation_util.Println('total reserved in ic_tran_pnd qty2 '|| l_qty2_reserved_real);

   IF (l_grade_ctl > 0 and l_grade is not null) THEN
   --- from ATP window
      OPEN qty_on_hand_grade(l_whse_code,p_item_id,l_grade);
      FETCH qty_on_hand_grade INTO
         l_onhand_qty1,
         l_onhand_qty2,
         l_committedsales_qty1,
         l_committedsales_qty2;
      CLOSE qty_on_hand_grade;
   ELSE
      OPEN qty_on_hand(l_whse_code,p_item_id);
      FETCH qty_on_hand INTO
         l_onhand_qty1,
         l_onhand_qty2,
         l_committedsales_qty1,
         l_committedsales_qty2;
      CLOSE qty_on_hand;
   END IF;

   l_onhand_qty1:= nvl(l_onhand_qty1,0);
   l_onhand_qty2:= nvl(l_onhand_qty2,0);
   l_committedsales_qty1:= nvl(l_committedsales_qty1, 0);
   l_committedsales_qty2:= nvl(l_committedsales_qty2,0);
   gmi_reservation_util.println('value of l_onhand_qty1'||l_onhand_qty1);
   gmi_reservation_util.println('value of l_onhand_qty2'||l_onhand_qty2);
   gmi_reservation_util.println('value of l_committedsales_qty1'||l_committedsales_qty1);
   gmi_reservation_util.println('value of l_committedsales_qty2'||l_committedsales_qty2);

   -- Begin Bug 2801666 - Pushkar Upakare
   l_qty_available  :=  l_onhand_qty1 + l_qty_reserved_real;
   l_qty2_available :=  l_onhand_qty2 + l_qty2_reserved_real;
   -- End   Bug 2801666

   -- Let's get qty reserved from ic_tran_pnd

   OPEN get_trans_for_null_del;
   FETCH get_trans_for_null_del into l_qty_reserved,l_qty2_reserved;
   CLOSE get_trans_for_null_del;

   l_qty_reserved := nvl(l_qty_reserved, 0);
   l_qty2_reserved := nvl(l_qty2_reserved, 0);

   gmi_reservation_util.println('value of l_qty_reserved  for this line is '||l_qty_reserved);
   gmi_reservation_util.println('value of l_qty2_reserved for this line is '||l_qty2_reserved);

   x_onhand_qty1 := l_onhand_qty1 ;
   x_onhand_qty2 := l_onhand_qty2 ;
   x_avail_qty1 := l_qty_available + l_qty_reserved;
   x_avail_qty2 := l_qty2_available+ l_qty2_reserved ;

   gmi_reservation_util.println('value of x_onhand_qty1 is '||x_onhand_qty1);
   gmi_reservation_util.println('value of x_avail_qty1  is '||x_avail_qty1);

   return;
END query_qty_for_ATP;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    calculate_prior_reservations                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   This procedure calculates  reservationsqty for a particular            |
 |   sales order/delivery detail line.                                      |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |       p_organization_id          IN NUMBER                               |
 |       p_item_id                  IN NUMBER                               |
 |       p_demand_source_line_id    IN NUMBER                               |
 |       p_requested_quantity       IN NUMBER                               |
 |       p_requested_quantity2      IN NUMBER                               |
 |       x_result_qty1             OUT NUMBER                               |
 |       x_result_qty2             OUT NUMBER                               |
 |       x_return_status           OUT NOCOPY VARCHAR2                      |
 |       x_msg_count               OUT NOCOPY NUMBER                        |
 |       x_msg_data                OUT NOCOPY VARCHAR2                      |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |    1/13/03     NC      Added to support Prior Reservations while pick--  |
 |                            Releasing.  Bug#2670928                       |
 +==========================================================================+
  Api end of comments
*/

PROCEDURE Calculate_Prior_Reservations(
                 p_organization_id         IN NUMBER
                ,p_item_id                 IN NUMBER
                ,p_demand_source_line_id   IN NUMBER
                ,p_delivery_detail_id      IN NUMBER
                ,p_requested_quantity      IN NUMBER
                ,p_requested_quantity2     IN NUMBER
                ,x_result_qty1             OUT NOCOPY NUMBER
                ,x_result_qty2             OUT NOCOPY NUMBER
                ,x_return_status           OUT NOCOPY VARCHAR2
                ,x_msg_count               OUT NOCOPY NUMBER
                ,x_msg_data                OUT NOCOPY VARCHAR2) IS

-- Standard Constants.

l_api_name      CONSTANT        VARCHAR2(30):= 'Calculate_Prior_Reservations';

-- Local Variables

l_qty_reserved          NUMBER;
l_qty2_reserved         NUMBER;
l_qty_remaining         NUMBER;
l_qty2_remaining        NUMBER;
l_item_loct_ctl         NUMBER;
l_whse_loct_ctl         NUMBER;
l_whse_code             VARCHAR2(5);
l_lot_ctl               NUMBER;
l_noninv_ind            NUMBER;
l_inventory_item_id     NUMBER;
l_is_noctl              BOOLEAN := FALSE;

 -- Cursor to Get the allocated qty for this deilery
CURSOR Get_trans_for_del IS
   SELECT ABS(SUM(nvl(trans_qty,0))),
          ABS(SUM(nvl(trans_qty2,0)))
     FROM  ic_tran_pnd
    WHERE  line_id = p_demand_source_line_id
      AND  line_detail_id = p_delivery_detail_id
      AND  doc_type='OMSO'
      AND  completed_ind = 0
      AND  delete_mark = 0;

 -- Get whse information
CURSOR get_whse_code (l_organization_id NUMBER ) IS
   SELECT whse_code ,loct_ctl
     FROM ic_whse_mst
    WHERE mtl_organization_id = l_organization_id ;

-- Get item ctl
CURSOR get_item_ctl  IS
   SELECT loct_ctl,lot_ctl,noninv_ind
     FROM ic_item_mst
    WHERE  item_id=p_item_id;

BEGIN

   GMI_RESERVATION_UTIL.PrintLn('In Procedure Calulate_Prior_Reservations');

   /*  Initialize  return status to success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_item_ctl;
   FETCH get_item_ctl INTO l_item_loct_ctl, l_lot_ctl, l_noninv_ind;
   IF(get_item_ctl%NOTFOUND)
   THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      CLOSE get_item_ctl;
      GMI_RESERVATION_UTIL.PrintLn('Error retrieving item details');
      FND_MESSAGE.Set_Name('GMI','GMI_API_ITEM_NOT_FOUND');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      CLOSE get_item_ctl;
   END IF;

   -- Get whse code
   OPEN get_whse_code (p_organization_id);
   FETCH get_whse_code INTO l_whse_code,l_whse_loct_ctl;
   IF ( get_whse_code%NOTFOUND ) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      CLOSE get_whse_code;
      GMI_RESERVATION_UTIL.PrintLn('Error retrieving whse code');
      FND_MESSAGE.SET_NAME('GMI','GMI_API_WHSE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ORG', p_organization_id);
      FND_MESSAGE.SET_TOKEN('LINE_ID', p_demand_source_line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      CLOSE get_whse_code;
   END IF;

   IF (l_lot_ctl = 0 AND (l_item_loct_ctl * l_whse_loct_ctl)= 0)
   THEN
     l_is_noctl := TRUE;
     GMI_RESERVATION_UTIL.PrintLn('Working with no control item');
   ELSE
     l_is_noctl := FALSE;
   END IF;

   IF ( l_noninv_ind = 1 or l_is_noctl = TRUE )
   THEN
      x_result_qty1 := p_requested_quantity;
      x_result_qty2 := p_requested_quantity2;
      RETURN;
   END IF;

   /*IF (l_is_noctl = TRUE)
   THEN
      l_qty_reserved := 0;
      l_qty2_reserved := 0;
   ELSE*/
   IF (l_is_noctl <> TRUE) THEN
      OPEN  get_trans_for_del;
      FETCH get_trans_for_del  INTO l_qty_reserved,l_qty2_reserved;
      IF (get_trans_for_del%NOTFOUND ) THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         CLOSE get_trans_for_del;
         GMI_RESERVATION_UTIL.PrintLn('Error retrieving Reserved qunatity');
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         CLOSE get_trans_for_del;
      END IF;
   END IF;

   l_qty_reserved := nvl(l_qty_reserved, 0);
   l_qty2_reserved := nvl(l_qty2_reserved, 0);

   GMI_RESERVATION_UTIL.PrintLn('Value of l_qty_reserved is '||l_qty_reserved);
   GMI_RESERVATION_UTIL.PrintLn('Value of l_qty2_reserved is '||l_qty2_reserved);

   l_qty_remaining  := p_requested_quantity - l_qty_reserved;
   l_qty2_remaining := p_requested_quantity2 - l_qty2_reserved;

   GMI_RESERVATION_UTIL.PrintLn('Value of remainig requested qty is '||l_qty_remaining);
   GMI_RESERVATION_UTIL.PrintLn('Value of remainig requested qty2 is '||l_qty2_remaining);

   IF l_qty_remaining <= 0 THEN
      x_result_qty1 := p_requested_quantity;
      x_result_qty2 := p_requested_quantity2;
   ELSE -- remaining qty is > 0
      x_result_qty1 := l_qty_reserved;
      x_result_qty2 := l_qty2_reserved;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   GMI_RESERVATION_UTIL.PrintLn('Returning from Procedure Calulate_Prior_Reservations with Success');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      GMI_RESERVATION_UTIL.PrintLn('Exeption GMI_Reservation_PVT.calculate_prior_reservations');
      FND_MSG_PUB.Add_Exc_Msg (
                        G_PKG_NAME
                      , l_api_name);

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get (
                        p_count  => x_msg_count
                        , p_data  => x_msg_data);

   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     GMI_RESERVATION_UTIL.PrintLn('No Data found Exception GMI_Reservation_PVT.calculate_prior_reservations');

     FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name);

      /*   Get message count and data */
     FND_MSG_PUB.count_and_get
                          ( p_count  => x_msg_count
                          , p_data  => x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     GMI_RESERVATION_UTIL.PrintLn('OTHERS Exception GMI_Reservation_PVT.calculate_prior_reservations');

     FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name);

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get (
                        p_count  => x_msg_count
                      , p_data  => x_msg_data);

END calculate_prior_reservations;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Calc_Reservation_For_shipset                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Local                                                                 |
 |                                                                          |
 | USAGE                                                                    |
 |   This procedure calculates  reservationsqty for a particular            |
 |   sales order/delivery detail line.                                      |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |                  p_shipset_id              IN NUMBER,                    |
 |                  p_organization_id         IN NUMBER,                    |
 |                  p_item_id                 IN NUMBER,      opm item_id   |
 |                  p_source_header_id        IN NUMBER,                    |
 |                  p_whse_code               IN VARCHAR2,                  |
 |                  p_whse_loct_ctl           IN NUMBER,                    |
 |                  p_chk_inv                 IN VARCHAR2,                  |
 |                  p_requested_quantity      IN NUMBER,                    |
 |                  p_requested_quantity2     IN NUMBER DEFAULT NULL,       |
 |                  x_shipset_reserved        OUT NOCOPY VARCHAR2           |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    x_shipset_reserved                                                    |
 |       'Y' if Shipset is reserved. 'N' if shipset is not reserved         |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    03/16/2004     PK   Added code to support shipset during pickrelease  |
 |                        Enhancement Bug #3297382                          |
 +==========================================================================+
  Api end of comments
*/

PROCEDURE Calc_Reservation_For_shipset(
                    p_shipset_id              IN NUMBER,
                    p_organization_id         IN NUMBER,
                    p_item_id                 IN NUMBER,
                    p_source_header_id        IN NUMBER,
                    p_whse_code               IN VARCHAR2,
                    p_whse_loct_ctl           IN NUMBER,
                    p_chk_inv                 IN VARCHAR2,
                    p_requested_quantity      IN NUMBER,
                    p_requested_quantity2     IN NUMBER DEFAULT NULL,
                    x_shipset_reserved        OUT NOCOPY VARCHAR2)IS

-- Declaration section

l_shipset_found  NUMBER := 0;
l_opm_itm_id     NUMBER;
l_apps_itm_id    NUMBER;
l_item_loct_ctl NUMBER;
l_lot_ctl       NUMBER;
l_noninv_ind    NUMBER;
l_demand_exists BOOLEAN;
l_is_noctl      BOOLEAN := FALSE;
l_qty_reserved_real NUMBER;
l_qty2_reserved_real NUMBER;
l_count NUMBER := 0;
l_index NUMBER := 0;
l_source_line_id NUMBER;
l_def_trans_qty   NUMBER := 0;
l_def_trans_qty2  NUMBER := 0;
l_shipset_qty_avl NUMBER := 1;
l_default_loct   VARCHAR2(4) := fnd_profile.value('IC$DEFAULT_LOCT');
--Bug 3551144
l_high_lev_res_qty  NUMBER := 0;
l_high_lev_res_qty2 NUMBER := 0;
l_real_high_lev_res_qty  NUMBER := 0;
l_real_high_lev_res_qty2 NUMBER := 0;
l_net_high_lev_res_qty  NUMBER := 0;
l_net_high_lev_res_qty2 NUMBER := 0;

-- Cursor Declarations

  CURSOR shipset_item IS
  Select delivery_detail_id, inventory_item_id, organization_id, source_line_id, requested_quantity, requested_quantity2
  FROM   wsh_delivery_details
  WHERE  source_header_id = p_source_header_id
    AND  ship_set_id = p_shipset_id
    AND  source_code = 'OE'
    AND  released_status <> 'D';

  itm_rec  shipset_item%ROWTYPE;

  CURSOR shipset_item_group IS
  Select inventory_item_id, Sum(requested_quantity) total_requested
  FROM   wsh_delivery_details
  WHERE  source_header_id = p_source_header_id
    AND  ship_set_id = p_shipset_id
    AND  source_code = 'OE'
    AND  released_status <> 'D'
  Group by inventory_item_id;

  itm_group_rec  shipset_item_group%ROWTYPE;

  CURSOR opm_itm(l_apps_itm_id NUMBER)   IS
  SELECT item_id
  FROM  ic_item_mst
  WHERE delete_mark = 0
    AND   item_no in (SELECT segment1
                      FROM mtl_system_items
                      WHERE organization_id   = p_organization_id
                      AND   inventory_item_id = l_apps_itm_id);

  CURSOR get_item_ctl(l_opm_itm_id NUMBER)  IS
  SELECT loct_ctl,lot_ctl,noninv_ind
    FROM ic_item_mst
   WHERE item_id=l_opm_itm_id;

  CURSOR reserved_quantity_nonctl(l_apps_itm_id NUMBER ) is
  Select sum(nvl(requested_quantity,0)), sum(nvl(requested_quantity2,0))
  From wsh_delivery_details
  Where organization_id = p_organization_id
    and inventory_item_id = l_apps_itm_id
    and released_status in ('S', 'Y');


  CURSOR reserved_quantity_real(l_opm_itm_id NUMBER
                                ,l_whse_code VARCHAR2 ) is
  SELECT ABS(SUM(nvl(trans_qty,0))),
         ABS(SUM(nvl(trans_qty2,0)))
  FROM   ic_tran_pnd
  WHERE  item_id = l_opm_itm_id
  AND    whse_code = l_whse_code
  AND    (lot_id <> 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
  AND    completed_ind = 0
  AND    delete_mark = 0
  AND    trans_qty < 0;

  CURSOR qty_on_hand(l_whse_code VARCHAR2,l_opm_itm_id NUMBER) IS
  SELECT SUM(nvl(s.onhand_order_qty,0)),
         SUM(nvl(s.onhand_order_qty2,0)),
         SUM(nvl(s.committedsales_qty,0)),
         SUM(nvl(s.committedsales_qty2,0))
  FROM   ic_summ_inv s
  WHERE  s.item_id = l_opm_itm_id
  AND    s.whse_code = l_whse_code;

 --Bug 3551144
  -- Get high level reserved qty. That is sum of requested qtys for all delivery detail lines which are
  -- relesed to warehouse for a given warehouse and item combination.
  CURSOR high_level_reserved_qty(p_organization_id NUMBER, p_inventory_item_id NUMBER) is
  SELECT NVL(sum(nvl(requested_quantity,0)),0), NVL(sum(nvl(requested_quantity2,0)),0)
  FROM   wsh_delivery_details
  WHERE  organization_id   = p_organization_id
  AND    inventory_item_id = p_inventory_item_id
  AND    source_code       = 'OE'
  AND    released_status   = 'S';

--Bug 3551144
  --Get sum of allocated qty against high level reserved qty
  CURSOR high_level_res_qty_real(p_item_id NUMBER,l_whse_code VARCHAR2) is
  SELECT NVL(ABS(SUM(nvl(trans_qty,0))),0), NVL(ABS(SUM(nvl(trans_qty2,0))),0)
  FROM   ic_tran_pnd itp
  WHERE  item_id   = p_item_id
  AND    whse_code = l_whse_code
  AND    (lot_id <> 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
  AND    completed_ind = 0
  AND    delete_mark   = 0
  AND    trans_qty     < 0
  AND  EXISTS(SELECT 1
              FROM   wsh_delivery_details
              WHERE  delivery_detail_id = itp.line_detail_id
              AND    source_code       = 'OE'
              AND    released_status   = 'S');

BEGIN

  GMI_Reservation_Util.PrintLn('IN Calc_Reservation_For_shipset id ' || p_shipset_id );
  --   check if record exists and shipset is already valid.
  --   If valid return requested quantity as quantity reserved.
  FOR i in 1..g_shipset_table.COUNT LOOP
    IF (g_shipset_table(i).shipset_id = p_shipset_id) THEN
       l_shipset_found := 1;
       IF (g_shipset_table(i).shipset_reserved = 'Y' AND g_shipset_table(i).shipset_valid = 'Y') THEN
           GMI_Reservation_Util.PrintLn('Shipset Found in global table - RESERVED - Exiting from calc_reservation_for_shipset');
           x_shipset_reserved := 'Y';
           RETURN;
       ELSIF (g_shipset_table(i).shipset_reserved = 'N' OR g_shipset_table(i).shipset_valid = 'N') THEN
           GMI_Reservation_Util.PrintLn('Shipset Found in global table - NOT RESERVED - Exiting from calc_reservation_for_shipset');
           x_shipset_reserved := 'N';
           RETURN;
       END IF;
    END IF;
  END LOOP;

  GMI_Reservation_Util.PrintLn('Shipset NOT FOUND in global table ');


  -- If l_shipset_found is still zero need to load shipset in demand table.
  IF (l_shipset_found = 0) THEN
    -- Building demand table for shipset.
    FOR itm_rec IN shipset_item LOOP
      l_apps_itm_id := itm_rec.inventory_item_id;
      OPEN opm_itm(l_apps_itm_id);
      FETCH opm_itm INTO l_opm_itm_id;
      CLOSE opm_itm;

      OPEN get_item_ctl(l_opm_itm_id);
      FETCH get_item_ctl INTO l_item_loct_ctl, l_lot_ctl, l_noninv_ind;
      CLOSE get_item_ctl;

      IF (l_lot_ctl = 0 AND (l_item_loct_ctl * p_whse_loct_ctl)= 0) THEN
        l_is_noctl := TRUE;
        GMI_Reservation_Util.PrintLn('Working with no control item in shipset');
      END IF;

      -- Now copy code below to build Demand table
      l_demand_exists := FALSE;
      FOR i in 1..g_demand_table.COUNT LOOP
        l_index := i;
        IF (g_demand_table(i).item_id= l_opm_itm_id AND
            g_demand_table(i).whse_code = p_whse_code) THEN
          l_demand_exists := TRUE;
          gmi_reservation_util.println('Building demand table for shipset if not already done');
          gmi_reservation_util.println('Value of item_id found in loop is '||g_demand_table(i).item_id);
          gmi_reservation_util.println('In opm calc_reservation_for_shipset Found the Reservation Details');
          gmi_reservation_util.println('value of g_demand_table(i).qty_available found is '||g_demand_table(i).qty_available);
          gmi_reservation_util.println('value of g_demand_table(i).qty_committed found is '||g_demand_table(i).qty_committed);
          gmi_reservation_util.println('value of g_demand_table(i).qty2_available found is '||g_demand_table(i).qty2_available);
          gmi_reservation_util.println('value of g_demand_table(i).qty2_committed found is '||g_demand_table(i).qty2_committed);
          EXIT;
        END IF;
      END LOOP;

      IF (not l_demand_exists) THEN
          gmi_reservation_util.Println('Building demand table For Shipset item id ' || l_opm_itm_id );

          IF (l_is_noctl = TRUE) THEN
            gmi_reservation_util.println('Item warehouse combination is No Control');
            gmi_reservation_util.Println('inventory_item_id is '||l_apps_itm_id);
            OPEN  reserved_quantity_nonctl(l_apps_itm_id);
            FETCH reserved_quantity_nonctl INTO l_qty_reserved_real,l_qty2_reserved_real;
            CLOSE reserved_quantity_nonctl;
          ELSE
            OPEN reserved_quantity_real(l_opm_itm_id, p_whse_code);
            FETCH reserved_quantity_real into l_qty_reserved_real,l_qty2_reserved_real;
            CLOSE reserved_quantity_real;
          END IF;
          l_qty_reserved_real := nvl(l_qty_reserved_real, 0);
          l_qty2_reserved_real := nvl(l_qty2_reserved_real, 0);

          gmi_reservation_util.println('value of l_qty_reserved_real '|| l_qty_reserved_real);
          gmi_reservation_util.println('value of l_qty2_reserved_real '|| l_qty2_reserved_real);

  -- Let's increment the counter

          l_count := g_demand_table.COUNT + 1;

          g_demand_table(l_count).item_id := l_opm_itm_id;
          g_demand_table(l_count).whse_code := p_whse_code;

     --Bug 3551144 added OR condition
      IF (p_chk_inv = 'Y' OR p_chk_inv = 'S') THEN
            OPEN  qty_on_hand(p_whse_code,l_opm_itm_id);
            FETCH qty_on_hand INTO
            g_demand_table(l_count).qty_available,
            g_demand_table(l_count).qty2_available,
            g_demand_table(l_count).qty_committed,
            g_demand_table(l_count).qty2_committed ;
            CLOSE qty_on_hand;
      END IF;

      --begin bug 3551144
        IF (p_chk_inv = 'S') THEN
           -- In case of l_is_noctl = TRUE high_level_reserved_qty is considered as part of l_qty_reserved_real
           IF (l_is_noctl = FALSE) THEN
              OPEN  high_level_reserved_qty(p_organization_id,l_apps_itm_id);
              FETCH high_level_reserved_qty INTO l_high_lev_res_qty, l_high_lev_res_qty2;
              CLOSE high_level_reserved_qty;
              gmi_reservation_util.println('value of l_high_lev_res_qty '||l_high_lev_res_qty);
              gmi_reservation_util.println('value of l_high_lev_res_qty2 '||l_high_lev_res_qty2);
              OPEN  high_level_res_qty_real(p_item_id,p_whse_code);
              FETCH high_level_res_qty_real into l_real_high_lev_res_qty,l_real_high_lev_res_qty2;
              CLOSE high_level_res_qty_real;
              gmi_reservation_util.println('value of l_real_high_lev_res_qty '||l_real_high_lev_res_qty);
              gmi_reservation_util.println('value of l_real_high_lev_res_qty2 '||l_real_high_lev_res_qty2);
              l_net_high_lev_res_qty  := l_high_lev_res_qty - l_real_high_lev_res_qty;
              l_net_high_lev_res_qty2 := l_high_lev_res_qty2 - l_real_high_lev_res_qty2;
              IF l_net_high_lev_res_qty < 0 THEN  -- This could happen in case of over allocation.
                 l_net_high_lev_res_qty  := 0;
                 l_net_high_lev_res_qty2 := 0;
              END IF;
              gmi_reservation_util.println('value of l_net_high_lev_res_qty '||l_net_high_lev_res_qty);
              gmi_reservation_util.println('value of l_net_high_lev_res_qty2 '||l_net_high_lev_res_qty2);
              g_demand_table(l_count).qty_available  := g_demand_table(l_count).qty_available  - l_net_high_lev_res_qty;
              g_demand_table(l_count).qty2_available := g_demand_table(l_count).qty2_available - l_net_high_lev_res_qty2;
           END IF;
        END IF;
      --end bug 3551144

          l_index := l_count;

       --Bug 3551144 added OR condition
          IF (p_chk_inv = 'Y' OR p_chk_inv = 'S') THEN
             g_demand_table(l_index).qty_available  :=  g_demand_table(l_index).qty_available - l_qty_reserved_real;
             g_demand_table(l_index).qty2_available :=  g_demand_table(l_index).qty2_available - l_qty2_reserved_real;
          END IF;

          IF g_demand_table(l_index).qty_available < 0 THEN
             g_demand_table(l_index).qty_available := 0;
             g_demand_table(l_index).qty2_available := 0;
          END IF;
          IF g_demand_table(l_index).qty2_available < 0 THEN
             g_demand_table(l_index).qty2_available := 0;
          END IF;

          gmi_reservation_util.Println('Demand table Built For Shipset item id ' || l_opm_itm_id );
          gmi_reservation_util.println('value of g_demand_table(l_index).qty_available '||g_demand_table(l_index).qty_available);
          gmi_reservation_util.println('value of g_demand_table(l_index).qty2_available '||g_demand_table(l_index).qty2_available);
          gmi_reservation_util.println('value of g_demand_table(l_index).qty_committed '||g_demand_table(l_index).qty_committed);
          gmi_reservation_util.println('value of g_demand_table(l_index).qty2_committed '||g_demand_table(l_index).qty2_committed);


      END IF; -- of not l_demand_exists
      -- End copy of code below.
    END LOOP;

    gmi_reservation_util.println('Global Demand table is now available for all items in  Shipset id  '||p_shipset_id);

    -- Now done building demand table. We should loop again to see if demand can be fulfilled.
    -- Validation loop should use group by item since same item/warehouse can exist in shipset (Generally not but it can)
    -- You have itm_rec for requested_qty and l_opm_itm_id. Find the record in demand table and check if .
    -- Demand can be fulfilled. If it can not be fulfilled then set l_shipset_qty_avl to zero and exit.
    l_shipset_qty_avl := 1;
    FOR itm_group_rec IN shipset_item_group LOOP
      l_apps_itm_id := itm_group_rec.inventory_item_id;
      OPEN opm_itm(l_apps_itm_id);
      FETCH opm_itm INTO l_opm_itm_id;
      CLOSE opm_itm;
      gmi_reservation_util.println('Checking availability in global demand table for Item id  '||l_opm_itm_id);
      -- Find the rec in demand table
      FOR i in 1..g_demand_table.COUNT LOOP
        IF (g_demand_table(i).item_id= l_opm_itm_id AND
            g_demand_table(i).whse_code = p_whse_code) THEN
          IF (g_demand_table(i).qty_available < itm_group_rec.total_requested) THEN
            gmi_reservation_util.println('Demand can NOT be fulfilled for Item id  '||l_opm_itm_id);
            l_shipset_qty_avl := 0;
            EXIT;
          ELSE
            gmi_reservation_util.println('Demand can be FULFILLED for Item id  '||l_opm_itm_id);
          END IF;
        END IF;
      END LOOP;
      IF (l_shipset_qty_avl = 0) THEN
        gmi_reservation_util.println('Demand check FAILED for Shipset id  '||p_shipset_id);
        EXIT;
      END IF;
    END LOOP;
    -- if l_shipset_qty_avl is still 1 means shipset availability check is successful. Then go and also book the demand
    -- for all the lines ( another loop) and enter Fulfilled record in PL/SQL table. Then return original requested quantity
    -- p_requested_quantity + (2) as reserved quantities and return.
    -- If it is zero then enter Failed record in PL/SQL table and return with Zero quantity reserved.
    IF (l_shipset_qty_avl = 0) THEN
      l_count := g_shipset_table.COUNT + 1;
      g_shipset_table(l_count).shipset_id := p_shipset_id;
      g_shipset_table(l_count).order_id   := p_source_header_id;
      g_shipset_table(l_count).shipset_valid := 'N';
      g_shipset_table(l_count).shipset_reserved := 'N';
      x_shipset_reserved := 'N';
      gmi_reservation_util.println('Exiting calc_reservation_for_shipset check FAILED for Shipset id  '||p_shipset_id);
      RETURN;
    ELSIF (l_shipset_qty_avl = 1) THEN
      l_count := g_shipset_table.COUNT + 1;
      g_shipset_table(l_count).shipset_id := p_shipset_id;
      g_shipset_table(l_count).order_id   := p_source_header_id;
      g_shipset_table(l_count).shipset_valid := 'Y';
      g_shipset_table(l_count).shipset_reserved := 'N';
      gmi_reservation_util.println('Record added to global table check SUCCESSFUL for Shipset id  '||p_shipset_id);
    END IF;
    -- Now book the demand for shipset
    gmi_reservation_util.println('Now Booking demand for Shipset id  '||p_shipset_id);
    FOR itm_rec IN shipset_item LOOP
      l_apps_itm_id := itm_rec.inventory_item_id;
      OPEN opm_itm(l_apps_itm_id);
      FETCH opm_itm INTO l_opm_itm_id;
      CLOSE opm_itm;
      FOR i in 1..g_demand_table.COUNT LOOP
        IF (g_demand_table(i).item_id= l_opm_itm_id AND
            g_demand_table(i).whse_code = p_whse_code) THEN
            gmi_reservation_util.println('Booking demand for Item id  '||l_opm_itm_id);
            g_demand_table(i).qty_available  :=  g_demand_table(i).qty_available - itm_rec.requested_quantity;
            g_demand_table(i).qty2_available :=  g_demand_table(i).qty2_available - nvl(itm_rec.requested_quantity2, 0);
            gmi_reservation_util.Println('Demand table Updated For Shipset item id ' || l_opm_itm_id );
            gmi_reservation_util.println('value of g_demand_table(i).qty_available '||g_demand_table(i).qty_available);
            gmi_reservation_util.println('value of g_demand_table(i).qty2_available '||g_demand_table(i).qty2_available);

            EXIT;
        END IF;
      END LOOP;
    END LOOP;
    -- Now Update g_shipset_table to mark Shipset as reserved.
    g_shipset_table(l_count).shipset_reserved := 'Y';
    x_shipset_reserved := 'Y';
    gmi_reservation_util.println('EXITING Record Updated- RESERVED Shipset id  '||p_shipset_id);
    RETURN;


  END IF; -- (l_shipset_found = 0)


END Calc_Reservation_For_shipset;


END GMI_Reservation_PVT;

/

--------------------------------------------------------
--  DDL for Package Body GMI_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_OM_UTIL" AS
/*  $Header: GMIOMUTB.pls 115.6 2004/03/08 17:06:34 uphadtar noship $ */
/*
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIOMUTB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains generic utilities relating to OPM and OM.     |
 |                                                                         |
 |                                                                         |
 +=========================================================================+
*/

/*
  ==========================================================================
    p_original_line_rec is RMA line record.
    p_reference_line_rec is referenced sales order line record for which
    RMA is being created.
  ==========================================================================
*/
PROCEDURE GMI_GET_RMA_LOTS_QTY
   ( p_original_line_rec                  IN  OE_Order_PUB.Line_Rec_Type
   , p_reference_line_rec                 IN  OE_Order_PUB.Line_Rec_Type
   , p_x_lot_serial_tbl                   IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
   , x_return_status                      OUT NOCOPY VARCHAR2
   )  IS

  l_lot_serial_tbl   OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_sum_return_qty   NUMBER := 0;
  l_number           NUMBER := 0;
  l_trans_qty        NUMBER := 0;
  l_trans_qty2       NUMBER := 0; -- OPM 2380194
  l_lot_trxn_qty     NUMBER := 0; -- Bug 3387203
  l_lot_trxn_qty2    NUMBER := 0; -- Bug 3387203
  l_rma_qty          NUMBER := 0;
  l_trans_apps_um    VARCHAR2(3);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(100);
  err_num            NUMBER;
  err_msg            VARCHAR2(100);

  CURSOR  item_dtl IS
  SELECT  iim.lot_ctl, iim.dualum_ind
  FROM    ic_item_mst iim, mtl_system_items msi
  WHERE   msi.inventory_item_id = p_reference_line_rec.inventory_item_id
  AND     msi.organization_id   = p_reference_line_rec.ship_from_org_id
  AND     msi.segment1          = iim.item_no;

  rec_item_dtl item_dtl%ROWTYPE;

  CURSOR trans_dtl IS
  SELECT itp.lot_id, ilm.lot_no, ilm.sublot_no, ABS(itp.trans_qty) trans_qty, itp.trans_um,
         ABS(itp.trans_qty2) trans_qty2, itp.trans_um2
  FROM   ic_tran_pnd itp, ic_lots_mst ilm
  WHERE  itp.doc_type      ='OMSO'
  AND    itp.line_id       = p_original_line_rec.reference_line_id
  AND    itp.delete_mark   = 0
  AND    itp.completed_ind = 1
  AND    itp.lot_id        <> 0
  AND    itp.trans_qty     <> 0
  AND    itp.staged_ind    = 1
  AND    itp.line_detail_id is not null
  AND    ilm.item_id = itp.item_id
  AND    ilm.lot_id  = itp.lot_id
  ORDER BY trans_id;


BEGIN

    GMI_RESERVATION_UTIL.Println('In Procedure GMI_OM_UTIL.GMI_GET_RMA_LOTS_QTY');

    l_rma_qty := p_original_line_rec.ordered_quantity;

    /* Clear Table */
    l_Lot_serial_tbl.DELETE;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    GMI_RESERVATION_UTIL.Println('Getting item details for Apps Item ID '
                                  ||to_char(p_reference_line_rec.inventory_item_id));
    OPEN  item_dtl;
    FETCH item_dtl into rec_item_dtl;
    CLOSE item_dtl;

    IF rec_item_dtl.lot_ctl = 1 THEN
       GMI_RESERVATION_UTIL.Println('Fetching lot quantities for order line id '||
                                     to_char(p_original_line_rec.reference_line_id));
       FOR r_trans_dtl IN trans_dtl LOOP


          /* Exit the loop if lot item qty reaches line return qty. */
          IF (l_sum_return_qty = l_rma_qty) THEN
             EXIT;
          END IF;

          IF (l_number = 0) THEN  /* get apps uom just once */
             GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM(
                     p_OPM_UOM       => r_trans_dtl.trans_um
                   , x_Apps_UOM      => l_trans_apps_um
                   , x_return_status => x_return_status
                   , x_msg_count     => l_msg_count
                   , x_msg_data      => l_msg_data);
          END IF;

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              GMI_RESERVATION_UTIL.Println('Unable to Get_AppsUOM_from_OPMUOM');
              x_return_status := FND_API.G_RET_STS_ERROR;
              EXIT;
          END IF;

          /* if item primary uom and rma uom are different convert trans qty */
          IF (l_trans_apps_um <> p_original_line_rec.order_quantity_uom) THEN
              l_trans_qty := GMI_RESERVATION_UTIL.Get_Opm_converted_qty
                              ( p_apps_item_id     => p_reference_line_rec.inventory_item_id
                               ,p_organization_id  => p_reference_line_rec.ship_from_org_id
                               ,p_apps_from_uom    => l_trans_apps_um
                               ,p_apps_to_uom      => p_original_line_rec.order_quantity_uom
                               ,p_original_qty     => r_trans_dtl.trans_qty );
          ELSE
              l_trans_qty := r_trans_dtl.trans_qty;
          END IF;

          IF (OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' ) THEN  -- OPM 2380194
             l_trans_qty2 := r_trans_dtl.trans_qty2;
          END IF;

          l_sum_return_qty   := l_sum_return_qty + l_trans_qty;
          l_number           := l_number + 1;

          /* lot indivisibility is not considered here.                         */
          /* need to assign partial lot qty when l_rma_qty is less shipped qty. */
          IF (l_sum_return_qty > l_rma_qty) THEN
              l_lot_trxn_qty       := l_rma_qty - (l_sum_return_qty - l_trans_qty);
              l_sum_return_qty     := l_rma_qty;  /* this assignment is for exiting from loop */

              /* need to derive secondary qty because partial lot qty is considered */
              IF ( OE_CODE_CONTROL.Get_Code_Release_Level >= '110510') THEN
                  IF (rec_item_dtl.dualum_ind > 0 ) THEN
                     l_lot_trxn_qty2 := GMI_RESERVATION_UTIL.Get_Opm_converted_qty
                                        ( p_apps_item_id     => p_reference_line_rec.inventory_item_id
                                         ,p_organization_id  => p_reference_line_rec.ship_from_org_id
                                         ,p_apps_from_uom    => p_original_line_rec.order_quantity_uom
                                         ,p_apps_to_uom      => p_original_line_rec.ordered_quantity_uom2
                                         ,p_original_qty     => l_lot_trxn_qty
                                         ,p_lot_id           => r_trans_dtl.lot_id );
                  ELSE
                     l_lot_trxn_qty2  := l_trans_qty2;
                  END IF;
              END IF;
          ELSE
             l_lot_trxn_qty   := l_trans_qty;
             IF (OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' ) THEN
                 l_lot_trxn_qty2  := l_trans_qty2;
             END IF;
          END IF;

          GMI_RESERVATION_UTIL.Println('lot_no = '||r_trans_dtl.lot_no);
          GMI_RESERVATION_UTIL.Println('sublot_no = '||r_trans_dtl.sublot_no);
          GMI_RESERVATION_UTIL.Println('lot_trxn_qty = '||to_char(l_lot_trxn_qty));
          GMI_RESERVATION_UTIL.Println('lot_trxn_qty2 = '||to_char(l_lot_trxn_qty2));

          l_lot_serial_tbl(l_number)            := OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
          l_lot_serial_tbl(l_number).lot_number := r_trans_dtl.lot_no;
          l_lot_serial_tbl(l_number).quantity   := l_lot_trxn_qty;

          IF (OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' ) THEN -- OPM 2380194
            l_lot_serial_tbl(l_number).sublot_number := r_trans_dtl.sublot_no;
            l_lot_serial_tbl(l_number).quantity2     := l_lot_trxn_qty2;
          END IF;

       END LOOP;

       IF (l_number = 0) THEN
        /* commenting following line because referencing unshipped line was giving errors. May be its an OM issue */
            /* x_return_status := FND_API.G_RET_STS_ERROR; */
            GMI_RESERVATION_UTIL.Println('Could not fetch lot quantities for order line id '||
                                          to_char(p_original_line_rec.reference_line_id));
       END IF;

    END IF;  /*  IF rec_item_dtl.lot_ctl = 1 */

    p_x_lot_serial_tbl := l_lot_serial_tbl;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      GMI_RESERVATION_UTIL.Println('Raised When Others in GMI_RMA_LOT_QTY');
      err_num := SQLCODE;
      err_msg := SUBSTRB(SQLERRM, 1, 100);
      GMI_RESERVATION_UTIL.Println(to_char(err_num)||'=>'||err_msg);

END GMI_GET_RMA_LOTS_QTY;

FUNCTION GMI_GET_SECONDARY_QTY
   (
      p_delivery_detail_id  IN NUMBER,
      p_primary_quantity   IN NUMBER
   ) RETURN NUMBER IS

l_line_id NUMBER;
l_lot_id  NUMBER;
l_organization_id NUMBER;
l_inventory_item_id                    NUMBER;
l_apps_from_uom 		       VARCHAR2(5);
l_apps_to_uom 		               VARCHAR2(5);
l_return_status                        VARCHAR2(30);
l_msg_count                            NUMBER;
l_msg_data                             VARCHAR2(5);
l_opm_from_uom                         VARCHAR2(5);
l_opm_to_uom                           VARCHAR2(5);
l_converted_qty                        NUMBER;

CURSOR Get_wdd_rec IS
  SELECT * from wsh_delivery_details
  where delivery_detail_id = p_delivery_detail_id;

WDD_REC Get_wdd_rec%rowtype;

CURSOR Get_lot_id IS
  SELECT LOT_ID from ic_tran_pnd
  where  line_detail_id = p_delivery_detail_id and
         line_id = l_line_id and
         doc_type = 'OMSO' and
         delete_mark = 0 and
         staged_ind = 1;
BEGIN

OPEN Get_wdd_rec;
FETCH Get_wdd_rec into WDD_REC;
IF Get_wdd_rec%FOUND THEN
 l_inventory_item_id :=  WDD_REC.INVENTORY_ITEM_ID;
 l_line_id           :=  WDD_REC.SOURCE_LINE_ID;
 l_organization_id   :=  WDD_REC.ORGANIZATION_ID;
 l_apps_from_uom     :=  WDD_REC.SRC_REQUESTED_QUANTITY_UOM;
 l_apps_to_uom       :=  WDD_REC.SRC_REQUESTED_QUANTITY_UOM2;
END IF;

CLOSE Get_wdd_rec;

IF l_apps_to_uom IS NULL THEN
 RETURN NULL;
END IF;


OPEN  Get_lot_id;
FETCH Get_lot_id into l_lot_id;
CLOSE Get_lot_id;

l_converted_qty := GMI_Reservation_Util.Get_Opm_converted_qty
                   (
           	     l_inventory_item_id,
   		     l_organization_id,
   		     l_apps_from_uom,
   		     l_apps_to_uom,
   		     p_primary_quantity,
   		     nvl(l_lot_id, 0)
		   );
RETURN l_converted_qty;

END GMI_GET_SECONDARY_QTY;


END GMI_OM_UTIL;

/

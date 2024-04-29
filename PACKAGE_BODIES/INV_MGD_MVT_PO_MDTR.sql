--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_PO_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_PO_MDTR" AS
-- $Header: INVPMDRB.pls 120.12.12010000.7 2010/01/13 12:23:38 skolluku ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVPMDRB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_PO_MDTR                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_PO_Transactions                                               |
--|     Get_Dropship_SO_Line                                              |
--|     Get_PO_Details                                                    |
--|     Get_Dropshipment_Details                                          |
--|     Update_PO_Transactions                                            |
--|     Get_RTV_Transactions                                              |
--|     Get_Blanket_Info                                                  |
--|     Get_RMA_Transactions                                              |
--|     Get_RMA_Details                                                   |
--|     Get_Parent_Mvt                                                    |
--|     Get_IO_Arrival_Txn                                                |
--|     Get_IO_Arrival_Details                                            |
--|                                                                       |
--| HISTORY                                                               |
--|     16/04/2007 Neelam Soni   Bug 5920143. Added support for Include   |
--|                              Establishments.                          |
--|     25-Jun-08  kdevadas     Bug 6839063 - Modified the cursor in      |
--|                             Get_RMA_Details to fetch the		  |
--|				ship_to_org_id from the line details	  |
--|				rather than the header. The cursor was	  |
--|				always picking the default ship_to in	  |
--|				the header which is incorrect             |
--|     05-Aug-08  Ajmittal     Bug 7165989 - Movement Statistics  RMA    |
--|                             Triangulation uptake.			  |
--|				Modified procs:Update_PO_transaction,     |
--|				Get_RMA_Details, Get_RMA_Transaction   	  |
--|				Changed check condition in Update_PO_Txn. |
--+=======================================================================+

--===================
-- CONSTANTS
--===================
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_PO_MDTR.';


--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Get_PO_Transactions    PRIVATE
-- PARAMETERS: po_crsr                 REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for PO and returns the cursor.
--========================================================================

PROCEDURE Get_PO_Transactions
( po_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.poCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_PO_Transactions';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF po_crsr%ISOPEN THEN
     CLOSE po_crsr;
  END IF;

--Fix performance bug 4912552, use hr_organization_information to replace
--org_organization_definitions according to proposal from INV
--karthik.gnanamurthy, because inventory organization is already existing
--in rcv_transactions, so it's not required to validate the organization
--again in mtl_parameters or hr_all_organization_units as OOD does
IF NVL(p_movement_transaction.creation_method,'A') = 'A' THEN

  OPEN po_crsr FOR
    SELECT
      rcv.transaction_id
   ,  rcv.parent_transaction_id
   ,  rcv.transaction_type
   ,  rcv.po_header_id
   ,  rcv.po_line_id
   ,  rcv.po_line_location_id
   ,  rcv.source_document_code
   ,  rcv.vendor_site_id
   ,  rcv.transaction_date
   ,  rcv.organization_id
   ,  rcv.subinventory
  FROM
    RCV_TRANSACTIONS rcv
  , hr_organization_information hoi
  WHERE   rcv.organization_id  = hoi.organization_id
    AND   hoi.org_information_context = 'Accounting Information'
    AND   rcv.mvt_stat_status  = 'NEW'
    AND   (rcv.transaction_type IN ('RECEIVE','RETURN TO VENDOR','MATCH')
           OR (rcv.transaction_type = 'CORRECT'
              AND rcv.destination_type_code = 'RECEIVING'))
    AND   rcv.source_document_code = 'PO'
    AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
    AND   rcv.transaction_date BETWEEN p_start_date AND p_end_date
    ORDER BY rcv.transaction_id;
ELSE
  OPEN po_crsr FOR
    SELECT
      rcv.transaction_id
   ,  rcv.parent_transaction_id
   ,  rcv.transaction_type
   ,  rcv.po_header_id
   ,  rcv.po_line_id
   ,  rcv.po_line_location_id
   ,  rcv.source_document_code
   ,  rcv.vendor_site_id
   ,  rcv.transaction_date
   ,  rcv.organization_id
   ,  rcv.subinventory
  FROM
    RCV_TRANSACTIONS rcv
   ,RCV_SHIPMENT_HEADERS rsh
   ,hr_organization_information hoi
  WHERE   rcv.shipment_header_id = rsh.shipment_header_id
    AND   rcv.organization_id  = hoi.organization_id
    AND   hoi.org_information_context = 'Accounting Information'
    AND   rsh.ship_to_org_id   = hoi.organization_id
    AND   rcv.mvt_stat_status    = 'NEW'
    AND   (rcv.transaction_type IN ('RECEIVE','RETURN TO VENDOR','MATCH')
          OR (rcv.transaction_type = 'CORRECT'
              AND rcv.destination_type_code = 'RECEIVING'))
    AND   rcv.source_document_code = 'PO'
    AND   rsh.receipt_num        = p_movement_transaction.receipt_num
    AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
    AND   rcv.organization_id    = p_movement_transaction.organization_id;
END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_PO_Transactions;

--========================================================================
-- PROCEDURE : Get_Dropship_SO_Line         PRIVATE
-- PARAMETERS: p_movement_transaction  movement transaction record
--             x_drop_ship_source_id
--             x_destination_org_id
-- COMMENT   : Get drop ship so line
--========================================================================
PROCEDURE Get_Dropship_SO_Line
(x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_drop_ship_source_id OUT NOCOPY NUMBER
, x_destination_org_id  OUT NOCOPY NUMBER
)
IS
l_count                NUMBER;
l_rt_seq               NUMBER;
l_so_seq               NUMBER;
l_rcv_transaction_id   NUMBER;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Dropship_SO_Line';

--Check if it's a dropship, and if it's a partial receipt dropship
CURSOR l_drpshp_count IS
SELECT
  count(*)
FROM
  oe_drop_ship_sources
WHERE po_header_id = x_movement_transaction.po_header_id
  AND po_line_id   = x_movement_transaction.po_line_id
  AND line_location_id = x_movement_transaction.po_line_location_id
GROUP BY line_location_id;

--Sort rcv transaction id for drop ship
CURSOR l_rt IS
SELECT
  transaction_id
FROM
  rcv_transactions
WHERE po_header_id = x_movement_transaction.po_header_id
  AND po_line_id = x_movement_transaction.po_line_id
  AND po_line_location_id = x_movement_transaction.po_line_location_id
  AND transaction_type = 'RECEIVE'
ORDER BY transaction_id;

CURSOR l_drpshp_om IS
  SELECT
    po_header_id
  , po_line_id
  , header_id
  , line_id
  , drop_ship_source_id
  , destination_organization_id
  FROM
    OE_DROP_SHIP_SOURCES
  WHERE po_header_id        = x_movement_transaction.po_header_id
  AND   po_line_id          = x_movement_transaction.po_line_id
  AND   line_location_id    = x_movement_transaction.po_line_location_id
ORDER BY line_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --Process dropship info
  OPEN l_drpshp_count;
  FETCH l_drpshp_count
  INTO l_count;

  IF l_drpshp_count%NOTFOUND
  THEN
    --not a dropship
    x_drop_ship_source_id := null;
  ELSE
    IF l_count = 1
    THEN
      --regular dropship, fetch so header id and line id
      OPEN  l_drpshp_om;
      FETCH l_drpshp_om
      INTO
        x_movement_transaction.po_header_id
      , x_movement_transaction.po_line_id
      , x_movement_transaction.order_header_id
      , x_movement_transaction.order_line_id
      , x_drop_ship_source_id
      , x_destination_org_id;
      CLOSE l_drpshp_om;
    ELSIF l_count > 1
    THEN
      --dropship with multiple receipts
      l_rt_seq := 0;
      OPEN l_rt;
      LOOP
        FETCH l_rt INTO
          l_rcv_transaction_id;

        l_rt_seq := l_rt_seq + 1;

        IF l_rcv_transaction_id = x_movement_transaction.rcv_transaction_id
        THEN
          EXIT;
        --Fix bug 5060410, incase no match found, exit anyway to avoice endless loop
        ELSIF l_rt_seq = l_count
        THEN
          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                          , G_MODULE_NAME
                            || '.no rt id matched - data problem - exit loop anyway'
                          ,'data has problem');
          END IF;

          EXIT;
        END IF;
        --EXIT WHEN l_rcv_transaction_id = x_movement_transaction.rcv_transaction_id;
      END LOOP;
      CLOSE l_rt;

      --SO order line loop
      l_so_seq := 0;
      OPEN  l_drpshp_om;
      LOOP
        FETCH l_drpshp_om
        INTO
          x_movement_transaction.po_header_id
        , x_movement_transaction.po_line_id
        , x_movement_transaction.order_header_id
        , x_movement_transaction.order_line_id
        , x_drop_ship_source_id
        , x_destination_org_id;

        l_so_seq := l_so_seq + 1;
        EXIT WHEN l_so_seq = l_rt_seq;
      END LOOP;
      CLOSE l_drpshp_om;
    END IF;
  END IF;
  CLOSE l_drpshp_count;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Get_Dropship_SO_Line;

--========================================================================
-- PROCEDURE : Get_PO_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for PO
--========================================================================

PROCEDURE Get_PO_Details
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
 l_receipt_transaction INV_MGD_MVT_DATA_STR.Receipt_Transaction_Rec_Type;
 l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
 l_rtv_code             VARCHAR2(2);
 l_rtv_eu_code          VARCHAR2(3);
 l_arrival_code         VARCHAR2(3);
 l_arrival_eu_code      VARCHAR2(3);
 l_parent_period_name   VARCHAR2(15);
 l_parent_id            NUMBER;
 l_correct_qty          NUMBER;
 l_correct_parimary_qty NUMBER;
 l_drop_ship_source_id  NUMBER;
 l_destination_org_id   NUMBER;

 l_source_unit_measure  VARCHAR2(25);
 l_source_uom_code      VARCHAR2(3);
 l_unit_price           NUMBER;
 l_uom_conv_rate        NUMBER;
 l_procedure_name CONSTANT VARCHAR2(30) := 'Get_PO_Details';

CURSOR po_details IS
  SELECT
    po.po_header_id
  , po.transaction_type
  , po.transaction_id
  , po.parent_transaction_id
  , po.movement_id
  , po.po_line_id
  , po.po_line_location_id
  , po.organization_id
  , po.currency_code
  , po.currency_conversion_type
  , po.currency_conversion_rate
  , po.currency_conversion_date
  , poh.vendor_id
  , poh.vendor_site_id
  , po.shipment_header_id
  , po.shipment_line_id
  , po.invoice_id
  , rsl.item_id
  , rsl.item_description
  , po.uom_code
  , po.source_doc_unit_of_measure
  , po.quantity
  , po.primary_quantity
  --, nvl(cst.item_cost,0)
  , poh.fob_lookup_code
  , poh.ship_to_location_id
  , NVL(po.po_unit_price,0)
  , po.country_of_origin_code
  , po.requisition_line_id
  , NVL(rsh.freight_carrier_code,'3')
  , po.po_release_id
  , poh.type_lookup_code
  , po.consigned_flag
  FROM
    RCV_TRANSACTIONS po
  , RCV_SHIPMENT_HEADERS rsh
  , RCV_SHIPMENT_LINES rsl
  , PO_HEADERS_ALL poh
  , PO_LINES_ALL pol
  --, CST_ITEM_COSTS_FOR_GL_VIEW cst
  WHERE po.shipment_header_id  = rsh.shipment_header_id
    AND rsh.shipment_header_id = rsl.shipment_header_id
    AND po.shipment_line_id    = rsl.shipment_line_id
    AND po.po_line_id          = pol.po_line_id
    AND poh.po_header_id       = pol.po_header_id
    --AND rsl.to_organization_id = cst.organization_id (+)
    --AND rsl.item_id            = cst.inventory_item_id (+)
    AND po.transaction_id      = x_movement_transaction.rcv_transaction_id;

  --Fix bug 4238031 get uom code for po document
  CURSOR l_uom IS
  SELECT
    muc.uom_code
  FROM
    MTL_UOM_CONVERSIONS_VIEW muc
  WHERE muc.inventory_item_id= x_movement_transaction.inventory_item_id
  AND   muc.organization_id  = x_movement_transaction.organization_id
  AND   muc.unit_of_measure  = l_source_unit_measure;

  --Fix bug 4207119
  CURSOR c_item_cost IS
  SELECT
    item_cost
  FROM
    CST_ITEM_COSTS_FOR_GL_VIEW
  WHERE organization_id = x_movement_transaction.organization_id
    AND inventory_item_id = x_movement_transaction.inventory_item_id;

CURSOR l_adj IS
  SELECT
    period_name
  FROM
    MTL_MOVEMENT_STATISTICS
  WHERE movement_id = l_parent_id;

--Fix bug 2412655, PO correction transaction
--Curor to get corrected quantity
CURSOR l_correct_quantity IS
  SELECT
    SUM(quantity)
  , SUM(primary_quantity)
  FROM
    rcv_transactions
  WHERE parent_transaction_id = x_movement_transaction.rcv_transaction_id
    AND mvt_stat_status = 'NEW'
    AND transaction_type = 'CORRECT';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_stat_typ_transaction := p_stat_typ_transaction;
  x_return_status        := 'Y';

  OPEN   po_details;
  FETCH  po_details INTO
    x_movement_transaction.po_header_id
  , l_receipt_transaction.transaction_type
  , x_movement_transaction.rcv_transaction_id
  , l_receipt_transaction.parent_transaction_id
  , x_movement_transaction.movement_id
  , x_movement_transaction.po_line_id
  , x_movement_transaction.po_line_location_id
  , x_movement_transaction.organization_id
  , x_movement_transaction.currency_code
  , x_movement_transaction.currency_conversion_type
  , x_movement_transaction.currency_conversion_rate
  , x_movement_transaction.currency_conversion_date
  , x_movement_transaction.vendor_id
  , x_movement_transaction.vendor_site_id
  , x_movement_transaction.shipment_header_id
  , x_movement_transaction.shipment_line_id
  , x_movement_transaction.invoice_id
  , x_movement_transaction.inventory_item_id
  , x_movement_transaction.item_description
  , x_movement_transaction.transaction_uom_code
  , l_source_unit_measure
  , x_movement_transaction.transaction_quantity
  , x_movement_transaction.primary_quantity
  --, x_movement_transaction.item_cost
  , x_movement_transaction.delivery_terms
  , x_movement_transaction.ship_to_site_use_id
  , l_unit_price
  , x_movement_transaction.origin_territory_code
  , x_movement_transaction.requisition_line_id
  , x_movement_transaction.transport_mode
  , x_movement_transaction.release_id
  , x_movement_transaction.type_lookup_code
  , x_movement_transaction.consigned_flag;

  IF po_details%NOTFOUND
  THEN
    CLOSE po_details;
    x_return_status := 'N';

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name || '.end return N'
                    ,'exit procedure'
                    );
    END IF;
    RETURN;
  END IF;
  CLOSE po_details;

  --Get item cost  fix bug 4207119
  OPEN c_item_cost;
  FETCH c_item_cost INTO
    x_movement_transaction.item_cost;
  CLOSE c_item_cost;

  --Fix bug 2412655 PO correction transaction, open correct quantity cursor
  OPEN l_correct_quantity;
  FETCH l_correct_quantity
  INTO
    l_correct_qty
  , l_correct_parimary_qty;

  IF l_correct_quantity%NOTFOUND
  THEN
    l_correct_qty := 0;
    l_correct_parimary_qty := 0;
    CLOSE l_correct_quantity;
  END IF;
  CLOSE l_correct_quantity;

  x_movement_transaction.transaction_quantity :=
      x_movement_transaction.transaction_quantity + NVL(l_correct_qty,0);
  x_movement_transaction.primary_quantity :=
      x_movement_transaction.primary_quantity + NVL(l_correct_parimary_qty,0);

  --Get source document uom code
  OPEN l_uom;
  FETCH l_uom INTO
    l_source_uom_code;

  IF l_uom%NOTFOUND
  THEN
    l_source_uom_code := x_movement_transaction.transaction_uom_code;
  END IF;
  CLOSE l_uom;

  --PO source uom maynot be same as received qty uom,thus when calculate document
  --line ext value, we need to consider uom conversion
  IF x_movement_transaction.transaction_uom_code <> l_source_uom_code
  THEN
    INV_CONVERT.Inv_Um_Conversion
    ( from_unit   => x_movement_transaction.transaction_uom_code
    , to_unit     => l_source_uom_code
    , item_id     => x_movement_transaction.inventory_item_id
    , uom_rate    => l_uom_conv_rate
    );
  ELSE
   l_uom_conv_rate := 1;
  END IF;

  --Set document unit price and document line value
  --This unit price will be for each transaction uom
  x_movement_transaction.document_unit_price :=
          NVL(l_unit_price,0) * l_uom_conv_rate;
  x_movement_transaction.document_line_ext_value :=
       x_movement_transaction.document_unit_price *
       NVL(x_movement_transaction.transaction_quantity,0);

  x_movement_transaction.movement_type :='A';
  x_movement_transaction.document_source_type :='PO';

  IF x_movement_transaction.currency_code IS NULL THEN
     x_movement_transaction.currency_code :=
	l_stat_typ_transaction.gl_currency_code;
  END IF;

  INV_MGD_MVT_UTILS_PKG.Get_Vendor_Info
  (x_movement_transaction => x_movement_transaction);

  --Get drop ship info (bug 3788843, 5060410)
  IF l_receipt_transaction.transaction_type = 'RECEIVE'
  THEN
    Get_Dropship_SO_Line
    (x_movement_transaction => x_movement_transaction
    , x_drop_ship_source_id => l_drop_ship_source_id
    , x_destination_org_id  => l_destination_org_id
    );
  END IF;

  --Consigned support
  IF x_movement_transaction.consigned_flag = 'Y'
  THEN
    x_movement_transaction.transaction_nature := '12';
  ELSE
    x_movement_transaction.transaction_nature := '11';
  END IF;

  IF (l_receipt_transaction.transaction_type = 'RETURN TO VENDOR')
  THEN
    x_movement_transaction.movement_type      := 'D';
    x_movement_transaction.transaction_nature := '21'; --for both consign and non consign
    x_movement_transaction.document_source_type := 'RTV';
    x_movement_transaction.movement_id          := null;
    l_rtv_code := x_movement_transaction.dispatch_territory_code;
    x_movement_transaction.dispatch_territory_code :=
       x_movement_transaction.destination_territory_code ;
    x_movement_transaction.destination_territory_code := l_rtv_code;
    l_rtv_eu_code := x_movement_transaction.dispatch_territory_eu_code;
    x_movement_transaction.dispatch_territory_eu_code :=
       x_movement_transaction.destination_territory_eu_code ;
    x_movement_transaction.destination_territory_eu_code := l_rtv_eu_code;
  ELSIF (l_receipt_transaction.transaction_type = 'CORRECT')
  THEN
    --Processor process here, the correction transactions are
    --in a different period from the parent transaction and the
    --parent transaction are closed already, so the correction
    --transactions created here should be of movement type 'DA'
    --or 'AA' depend on the quantity
    IF x_movement_transaction.transaction_quantity < 0
    THEN
      x_movement_transaction.movement_type      := 'DA';
      x_movement_transaction.transaction_quantity :=
              abs(x_movement_transaction.transaction_quantity);
      x_movement_transaction.primary_quantity :=
              abs(x_movement_transaction.primary_quantity);
    ELSE
      x_movement_transaction.movement_type      := 'AA';
    END IF;

    --This assignment is used in create movment statistics to keep the parent mvt id
    x_movement_transaction.movement_id := x_movement_transaction.parent_movement_id;
  ELSE
    --regular PO
    x_movement_transaction.movement_type      := 'A';
  END IF;

  IF NVL(l_drop_ship_source_id , FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
  THEN
    x_movement_transaction.movement_type        := 'A';
    x_movement_transaction.document_source_type := 'PO';
    x_movement_transaction.organization_id      := l_destination_org_id;
    x_movement_transaction.transaction_nature       := '17';
    --Bug:5920143. Triangulation Country and Origin Country are assigned with
    --proper values for a logical PO Arrival record.
    x_movement_transaction.triangulation_country_code :=
                     x_movement_transaction.destination_territory_code;
    IF (x_movement_transaction.origin_territory_code IS  null )
    THEN
     x_movement_transaction.origin_territory_code :=
                     x_movement_transaction.dispatch_territory_code;
    END IF;
    -- If it is a ESL transaction set the drop shipment flag for ESL
    IF UPPER(x_movement_transaction.stat_type) = 'ESL'
    THEN
      x_movement_transaction.esl_drop_shipment_code   := 1;
    END IF;

    x_movement_transaction.document_line_ext_value :=
         abs(x_movement_transaction.document_line_ext_value);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_PO_Details;

--========================================================================
-- PROCEDURE : Get_DropShipment_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for PO
--========================================================================

PROCEDURE Get_DropShipment_Details
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
 l_receipt_transaction INV_MGD_MVT_DATA_STR.Receipt_Transaction_Rec_Type;
 l_shipment_transaction INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
 l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
 l_procedure_name CONSTANT VARCHAR2(30) := 'Get_DropShipment_Details';

CURSOR l_drpshp_so_om IS
  SELECT
    oola.ship_to_org_id
  , ooha.fob_point_code
  , NVL(ooha.freight_terms_code, '3')
  , oola.line_id
  , ooha.header_id
  , ooha.order_number
  , oola.line_number
  --, oola.ship_from_org_id   keep the organization_id from drop ship PO
  , oola.sold_from_org_id
--  , oola.shipped_quantity
  , nvl(ooha.invoice_to_org_id,ooha.sold_to_org_id)
  , ooha.sold_to_org_id
  , oola.order_quantity_uom
  , oola.inventory_item_id
  , si.description
  , si.primary_uom_code
  , ooha.transactional_curr_code
  , ooha.conversion_type_code
  , ooha.conversion_rate
  , ooha.conversion_rate_date
  --, nvl(cst.item_cost,0)
  , NVL(oola.unit_selling_price,0)
  , abs(nvl(oola.unit_selling_price,0) * nvl(oola.shipped_quantity,0)) doc_line_ext
  , oola.orig_sys_line_ref
  , ooha.orig_sys_document_ref
  , rac.party_name
  , rac.party_number
  FROM
    OE_ORDER_HEADERS_ALL ooha
  , OE_ORDER_LINES_ALL oola
  , HZ_PARTIES rac
  , HZ_CUST_ACCOUNTS hzc
  , MTL_SYSTEM_ITEMS si
  --, CST_ITEM_COSTS_FOR_GL_VIEW cst
  WHERE ooha.header_id           = oola.header_id
    AND oola.inventory_item_id   = si.inventory_item_id
    AND oola.ship_from_org_id    = si.organization_id
    AND rac.party_id             = hzc.party_id
    AND ooha.sold_to_org_id      = hzc.cust_account_id
    --AND oola.ship_from_org_id    = cst.organization_id(+)
    --AND oola.inventory_item_id   = cst.inventory_item_id(+)
    AND oola.line_id             = x_movement_transaction.order_line_id;

  --Fix bug 4207119
  CURSOR c_item_cost IS
  SELECT
    cst.item_cost
  FROM
    CST_ITEM_COSTS_FOR_GL_VIEW cst
  , oe_order_lines_all oola
  WHERE cst.organization_id   = oola.ship_from_org_id
    AND cst.inventory_item_id = oola.inventory_item_id
    AND oola.line_id          = x_movement_transaction.order_line_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

    l_stat_typ_transaction := p_stat_typ_transaction;
    x_return_status        := 'Y';

    OPEN l_drpshp_so_om;
    FETCH l_drpshp_so_om INTO
    x_movement_transaction.ship_to_site_use_id
    , x_movement_transaction.delivery_terms
    , x_movement_transaction.transport_mode
    , x_movement_transaction.order_line_id
    , x_movement_transaction.order_header_id
    , x_movement_transaction.order_number
    , x_movement_transaction.line_number
   -- , x_movement_transaction.organization_id
    , l_shipment_transaction.org_id
--    , x_movement_transaction.shipped_quantity
    , x_movement_transaction.bill_to_site_use_id
    , x_movement_transaction.bill_to_customer_id
    , x_movement_transaction.transaction_uom_code
    , x_movement_transaction.inventory_item_id
    , x_movement_transaction.item_description
    , x_movement_transaction.primary_uom_code
    , x_movement_transaction.currency_code
    , x_movement_transaction.currency_conversion_type
    , x_movement_transaction.currency_conversion_rate
    , x_movement_transaction.currency_conversion_date
    --, x_movement_transaction.item_cost
    , x_movement_transaction.document_unit_price
    , x_movement_transaction.document_line_ext_value
    , l_shipment_transaction.req_line_num
    , l_shipment_transaction.req_num
    , x_movement_transaction.customer_name
    , x_movement_transaction.customer_number;

    IF l_drpshp_so_om%NOTFOUND
    THEN
      CLOSE l_drpshp_so_om;
      x_return_status := 'N';

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_procedure_name || '.end return N'
                      ,'exit procedure'
                      );
      END IF;
      RETURN;
    ELSE
        CLOSE l_drpshp_so_om;
    END IF;

    --Get item cost   fix bug 4207119
    OPEN c_item_cost;
    FETCH c_item_cost INTO
      x_movement_transaction.item_cost;
    CLOSE c_item_cost;

  x_movement_transaction.movement_type        := 'D';
  x_movement_transaction.document_source_type := 'SO';

  x_movement_transaction.transaction_nature       := '17';

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_DropShipment_Details;



--========================================================================
-- PROCEDURE : Update_PO_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_PO_Transactions
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_mvt_stat_status      IN RCV_TRANSACTIONS.mvt_stat_status%TYPE /*Bug 7165989 */
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_receipt_transaction INV_MGD_MVT_DATA_STR.Receipt_Transaction_Rec_Type;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Update_PO_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  -- Update the transaction table
   /* 7165989 - Update mvt_stat_status in RCV_TRANSACTIONS based of the records */
  /* created for the RMA triangulation. Any non-RMA triangulation should be stamped*/
  /* with PROCESSED status*/
   IF (p_mvt_stat_status is NULL OR (p_mvt_stat_status <> 'FORDISP'
                                   AND p_mvt_stat_status <> 'FORARVL') )
 THEN

	  UPDATE RCV_TRANSACTIONS
	  SET mvt_stat_status   = 'PROCESSED'
	  ,   movement_id       = p_movement_transaction.movement_id
	  WHERE transaction_id  = p_movement_transaction.rcv_transaction_id;
ELSE
	  UPDATE RCV_TRANSACTIONS
	  SET mvt_stat_status   = p_mvt_stat_status
	  ,   movement_id       = p_movement_transaction.movement_id
	  WHERE transaction_id  = p_movement_transaction.rcv_transaction_id;
 END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Update_PO_Transactions;

--========================================================================
-- PROCEDURE : Get_RTV_Transactions    PRIVATE
-- PARAMETERS: rtv_crsr                 REF cursor
--             x_return_status         return status
-- COMMENT   :
--             This opens the cursor for RTV and returns the cursor.
--========================================================================

PROCEDURE Get_RTV_Transactions
( rtv_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.rtvCurTyp
, p_parent_id             IN  NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_RTV_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF rtv_crsr%ISOPEN THEN
     CLOSE rtv_crsr;
  END IF;

  OPEN rtv_crsr FOR
    SELECT NVL(vendor_site_id,null)
    ,    NVL(parent_transaction_id,null)
    ,    transaction_type
    FROM   RCV_TRANSACTIONS
    WHERE  transaction_id = p_parent_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_RTV_Transactions;


--========================================================================
-- PROCEDURE : Get_Blanket_Info  PUBLIC
-- PARAMETERS: p_movement_transaction  IN  Movement Statistics Record
--             x_movement_transaction  OUT Movement Statistics Record
-- COMMENT   : Procedure to populate the Blanket PO Info
--=========================================================================

PROCEDURE Get_Blanket_Info
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Blanket_Info';

CURSOR l_bpo
IS
SELECT
    po.po_release_id
  , po.po_line_location_id
  , poh.type_lookup_code
FROM
  RCV_TRANSACTIONS po
, PO_HEADERS_ALL   poh
WHERE   po.po_header_id   = poh.po_header_id
AND     po.transaction_id = x_movement_transaction.rcv_transaction_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_movement_transaction := x_movement_transaction;

  OPEN  l_bpo;
  FETCH l_bpo
  INTO
    x_movement_transaction.release_id
  , x_movement_transaction.po_line_location_id
  , x_movement_transaction.type_lookup_code;
  CLOSE l_bpo;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_movement_transaction := l_movement_transaction;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_Blanket_Info;


--========================================================================
-- PROCEDURE : Get_RMA_Transactions    PRIVATE
-- PARAMETERS: rma_crsr                 REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for RMA and returns the cursor.
--========================================================================

PROCEDURE Get_RMA_Transactions
( rma_crsr               IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.poCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_RMA_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF rma_crsr%ISOPEN THEN
     CLOSE rma_crsr;
  END IF;

--Fix performance bug 4912552, use hr_organization_information to replace
--org_organization_definitions according to proposal from INV
--karthik.gnanamurthy, because inventory organization is already existing
--in rcv_transactions, so it's not required to validate the organization
--again in mtl_parameters or hr_all_organization_units as OOD does
--Fix bug 5437773, replace oola.sold_from_org_id with oola.org_id
--org_id is the correct column to get operating unit

IF NVL(p_movement_transaction.creation_method,'A') = 'A' THEN
  --Fix bug3057775. Pick up RMA at the LE where this RMA is created
  --when the receipt LE is different from creating LE. This is for
  --invoice based triangulation mode.
  --R12 Legal entity new data model uptake, replace hr_operating_units base tables
  --with XLE package, because this view is not existed anymore
  OPEN rma_crsr FOR
  SELECT
    rcv.transaction_id
 ,  rcv.parent_transaction_id
 ,  rcv.transaction_type
 ,  rcv.source_document_code
 ,  rcv.customer_site_id
 ,  rcv.oe_order_header_id
 ,  rcv.oe_order_line_id
 ,  rcv.transaction_date
 ,  rcv.organization_id
 ,  rcv.subinventory
 ,  rcv.mvt_stat_status -- 7165989
  FROM
    RCV_TRANSACTIONS rcv
  , oe_order_lines_all oola
  , hr_organization_information hoi /*Bug 8467743*/
  WHERE rcv.oe_order_line_id  = oola.line_id
  AND   rcv.mvt_stat_status IN ('NEW', 'FORDISP', 'FORARVL') -- 7165989 Changes for RMA triangulation
  AND   rcv.transaction_type IN ('DELIVER')
  AND   rcv.source_document_code = 'RMA'
  AND   rcv.transaction_date BETWEEN p_start_date AND p_end_date
  AND hoi.org_information_context = 'Operating Unit Information'  /*Bug 8467743*/
  AND hoi.organization_id = nvl(oola.org_id,oola.sold_from_org_id)              /*Bug 8467743*/
  AND p_movement_transaction.entity_org_id =TO_NUMBER(hoi.org_information2) /*Bug 8467743*/
/*AND   p_movement_transaction.entity_org_id =
        XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info
        ('SOLD_TO', oola.sold_to_org_id
         , null, null, oola.org_id)*/
UNION
  SELECT                     --regular case: receipt LE is same as creating LE
    rcv.transaction_id
 ,  rcv.parent_transaction_id
 ,  rcv.transaction_type
 ,  rcv.source_document_code
 ,  rcv.customer_site_id
 ,  rcv.oe_order_header_id
 ,  rcv.oe_order_line_id
 ,  rcv.transaction_date
 ,  rcv.organization_id
 ,  rcv.subinventory
 ,  rcv.mvt_stat_status -- 7165989
  FROM
    RCV_TRANSACTIONS rcv
  , hr_organization_information hoi
  WHERE rcv.organization_id  = hoi.organization_id
    AND hoi.org_information_context = 'Accounting Information'
  AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
  AND   rcv.mvt_stat_status IN ('NEW', 'FORDISP', 'FORARVL') -- 7165989 Changes for RMA triangulation
  AND   rcv.transaction_type IN ('DELIVER')
  AND   rcv.source_document_code = 'RMA'
  AND   rcv.transaction_date BETWEEN p_start_date AND p_end_date;
ELSE
  OPEN rma_crsr FOR
  SELECT
    rcv.transaction_id
 ,  rcv.parent_transaction_id
 ,  rcv.transaction_type
 ,  rcv.source_document_code
 ,  rcv.customer_site_id
 ,  rcv.oe_order_header_id
 ,  rcv.oe_order_line_id
 ,  rcv.transaction_date
 ,  rcv.organization_id
 ,  rcv.subinventory
 ,  rcv.mvt_stat_status -- 7165989
  FROM
    RCV_TRANSACTIONS rcv
 ,  RCV_SHIPMENT_HEADERS rsh
 ,  oe_order_lines_all oola
 , hr_organization_information hoi /*Bug 8467743*/
  WHERE rcv.shipment_header_id  = rsh.shipment_header_id
  AND   rcv.oe_order_line_id  = oola.line_id
  AND   rsh.receipt_num         = p_movement_transaction.receipt_num
  AND   rcv.mvt_stat_status IN ('NEW', 'FORDISP', 'FORARVL') -- 7165989 Changes for RMA triangulation
  AND   rcv.transaction_type IN ('DELIVER')
  AND   rcv.source_document_code = 'RMA'
  AND hoi.org_information_context = 'Operating Unit Information'  /*Bug 8467743*/
  AND hoi.organization_id = nvl(oola.org_id,oola.sold_from_org_id)              /*Bug 8467743*/
  AND p_movement_transaction.entity_org_id =TO_NUMBER(hoi.org_information2) /*Bug 8467743*/
/*AND   p_movement_transaction.entity_org_id =
        XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info
        ('SOLD_TO', oola.sold_to_org_id
        , null, null, oola.org_id)*/
UNION
  SELECT
    rcv.transaction_id
 ,  rcv.parent_transaction_id
 ,  rcv.transaction_type
 ,  rcv.source_document_code
 ,  rcv.customer_site_id
 ,  rcv.oe_order_header_id
 ,  rcv.oe_order_line_id
 ,  rcv.transaction_date
 ,  rcv.organization_id
 ,  rcv.subinventory
 ,  rcv.mvt_stat_status -- 7165989
 FROM
    RCV_TRANSACTIONS rcv
 ,  RCV_SHIPMENT_HEADERS rsh
 ,  hr_organization_information hoi
  WHERE rcv.shipment_header_id  = rsh.shipment_header_id
  AND   rcv.organization_id     = hoi.organization_id
  AND   hoi.org_information_context = 'Accounting Information'
  AND   rsh.ship_to_org_id   = hoi.organization_id
  AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
  AND   rsh.receipt_num         = p_movement_transaction.receipt_num
  AND   rcv.organization_id     = p_movement_transaction.organization_id
  AND   rcv.mvt_stat_status IN ('NEW', 'FORDISP', 'FORARVL') -- 7165989 Changes for RMA triangulation
  AND   rcv.transaction_type IN ('DELIVER')
  AND   rcv.source_document_code = 'RMA';
END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_RMA_Transactions;

--========================================================================
-- PROCEDURE : Get_RMA_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for RMA
--========================================================================

PROCEDURE Get_RMA_Details
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
 l_receipt_transaction INV_MGD_MVT_DATA_STR.Receipt_Transaction_Rec_Type;
 l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
 l_order_uom          OE_ORDER_LINES_ALL.Pricing_Quantity_Uom%TYPE;
 l_uom_conv_rate        NUMBER;
 l_unit_price           NUMBER;
 l_procedure_name CONSTANT VARCHAR2(30) := 'Get_RMA_Details';

 /*bug 8435314 Add logic for config Item in RMA*/
 l_qty_selling_price    OE_ORDER_LINES_ALL.Unit_Selling_Price%TYPE;
 l_currency_code        OE_ORDER_HEADERS_ALL.Transactional_Curr_Code%TYPE;
 l_error_code           NUMBER;
 l_return_status        VARCHAR2(1);
 l_item_type_code       OE_ORDER_LINES_ALL.Item_Type_Code%TYPE;
 l_So_line_Id           NUMBER;
 CURSOR l_rma_config IS
  SELECT DISTINCT 'CONFIG' FROM mtl_system_items
   WHERE inventory_item_id=x_movement_transaction.inventory_item_id
     AND auto_created_config_flag='Y'
     AND base_item_id IS NOT null;
  /*End bug 8435314 */

CURSOR rma_details IS
  SELECT
    po.transaction_id
  , po.organization_id
  , abs(po.quantity)
  , po.uom_code
  --, po.transaction_date    timezone support do not populate again
  , abs(po.primary_quantity)
  , rsl.item_id
  , rsl.item_description
  --, si.description
  --, nvl(cst.item_cost,0)
  , ooha.fob_point_code
  , NVL(abs(oola.unit_selling_price),0)
  --, po.oe_order_header_id
  --, po.oe_order_line_id
  --, ooha.ship_to_org_id
  , oola.ship_to_org_id   /* bug 6839063  - line details are used instead of header details */
  , ooha.sold_to_org_id
  , nvl(ooha.invoice_to_org_id,ooha.sold_to_org_id)
  , ooha.transactional_curr_code
  , ooha.conversion_type_code
  , ooha.conversion_rate
  , ooha.conversion_rate_date
  , rsl.shipment_header_id
  , rsl.shipment_line_id
  , ooha.org_id
  , oola.order_quantity_uom
  , ooha.sold_from_org_id -- 7165989
  , oola.return_attribute2 -- 8435314
  FROM
    RCV_TRANSACTIONS po
  , RCV_SHIPMENT_HEADERS rsh
  , RCV_SHIPMENT_LINES rsl
  , OE_ORDER_HEADERS_ALL ooha
  , OE_ORDER_LINES_ALL oola
  --, MTL_SYSTEM_ITEMS si
  --, CST_ITEM_COSTS_FOR_GL_VIEW cst
  WHERE po.shipment_header_id  = rsh.shipment_header_id
    AND rsh.shipment_header_id = rsl.shipment_header_Id
    AND po.shipment_line_id    = rsl.shipment_line_id
    AND po.oe_order_header_id  = ooha.header_id
    AND ooha.header_id         = oola.header_id
    AND po.oe_order_line_id    = oola.line_id
    --AND rsh.organization_id    = si.organization_id
    --AND rsl.item_id            = si.inventory_item_id
    --AND si.organization_id     = cst.organization_id (+)
    --AND si.inventory_item_id   = cst.inventory_item_id (+)
    AND po.transaction_id      = x_movement_transaction.rcv_transaction_id;

 --Fix bug 4207119
  CURSOR c_item_cost IS
  SELECT
    item_cost
  FROM
    CST_ITEM_COSTS_FOR_GL_VIEW
  WHERE organization_id   = x_movement_transaction.organization_id
    AND inventory_item_id = x_movement_transaction.inventory_item_id;

/*CURSOR l_uom IS
  SELECT
    muc.uom_code
  FROM
    MTL_UOM_CONVERSIONS_VIEW muc
  WHERE muc.inventory_item_id= x_movement_transaction.inventory_item_id
  AND   muc.organization_id  = x_movement_transaction.organization_id
  AND   muc.unit_of_measure  = l_receipt_transaction.primary_unit_of_measure;*/

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_stat_typ_transaction := p_stat_typ_transaction;
  x_return_status        := 'Y';

  OPEN   rma_details;
  FETCH  rma_details INTO
    x_movement_transaction.rcv_transaction_id
  , x_movement_transaction.organization_id
  , x_movement_transaction.transaction_quantity
  , x_movement_transaction.transaction_uom_code
  --, x_movement_transaction.transaction_date
  , x_movement_transaction.primary_quantity
  , x_movement_transaction.inventory_item_id
  , x_movement_transaction.item_description
  --, x_movement_transaction.item_cost
  , x_movement_transaction.delivery_terms
  , l_unit_price
  --, x_movement_transaction.order_header_id
  --, x_movement_transaction.order_line_id
  , x_movement_transaction.ship_to_site_use_id
  , x_movement_transaction.ship_to_customer_id
  , x_movement_transaction.bill_to_site_use_id
  , x_movement_transaction.currency_code
  , x_movement_transaction.currency_conversion_type
  , x_movement_transaction.currency_conversion_rate
  , x_movement_transaction.currency_conversion_date
  , x_movement_transaction.shipment_header_id
  , x_movement_transaction.shipment_line_id
  , x_movement_transaction.org_id
  , l_order_uom
  , x_movement_transaction.sold_from_org_id -- 7165989
  , l_So_line_Id;--8435314

    IF rma_details%NOTFOUND THEN
      CLOSE rma_details;
      x_return_status := 'N';

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_procedure_name || '.end return N'
                      ,'exit procedure'
                      );
      END IF;
      RETURN;
    END IF;

  CLOSE rma_details;

  --Get item cost   fix bug 4207119
  OPEN c_item_cost;
  FETCH c_item_cost INTO
    x_movement_transaction.item_cost;
  CLOSE c_item_cost;

  /*OPEN l_uom;
  FETCH l_uom INTO
    x_movement_transaction.transaction_uom_code;

  IF l_uom%NOTFOUND THEN
   x_movement_transaction.transaction_uom_code :=
     substrb(l_receipt_transaction.primary_unit_of_measure,1,3);
  END IF;

  CLOSE l_uom;*/

  --SO order uom maynot be same as receipt qty uom,thus when calculate document
  --line ext value, we need to consider uom conversion
  /*bug 8435314 Check for config Item*/
  FND_FILE.put_line(FND_FILE.log, 'x_movement_transaction.order_line_id 1 is  : '||x_movement_transaction.order_line_id);
  Open l_rma_config;
        Fetch l_rma_config into l_item_type_code;
        Close l_rma_config;
  --Get document unit price for CTO item
   FND_FILE.put_line(FND_FILE.log, 'The Item is  : '||X_movement_transaction.inventory_item_id || ' '||l_item_type_code);
   FND_FILE.put_line(FND_FILE.log, 'l_unit_price 1 is  : '||l_unit_price);
  IF l_item_type_code = 'CONFIG'
  THEN
    --Call BOM procedure to get unit selling price
    FND_FILE.put_line(FND_FILE.log, 'l_So_line_Id 1 is  : '||l_So_line_Id);
    CTO_PUBLIC_UTILITY_PK.Get_Selling_Price
    ( p_config_line_id     => l_So_line_Id
    , x_unit_selling_price => l_unit_price
    , x_qty_selling_price  => l_qty_selling_price
    , x_currency_code      => l_currency_code
    , x_return_status      => l_return_status
    , x_error_code         => l_error_code
    );
    FND_FILE.put_line(FND_FILE.log, 'l_unit_price 2 is  : '||l_unit_price);
  END IF;
 /*End bug 8435314 */
  IF x_movement_transaction.transaction_uom_code <> l_order_uom
  THEN
    INV_CONVERT.Inv_Um_Conversion
    ( from_unit   => x_movement_transaction.transaction_uom_code
    , to_unit     => l_order_uom
    , item_id     => x_movement_transaction.inventory_item_id
    , uom_rate    => l_uom_conv_rate
    );
  ELSE
   l_uom_conv_rate := 1;
  END IF;

  --Set document unit price and document line value
  --This unit price would be for each transaction uom
  x_movement_transaction.document_unit_price :=
          NVL(l_unit_price,0) * l_uom_conv_rate;
  x_movement_transaction.document_line_ext_value :=
       abs(x_movement_transaction.document_unit_price *
       x_movement_transaction.transaction_quantity);

  IF x_movement_transaction.currency_code IS NULL THEN
     x_movement_transaction.currency_code :=
	l_stat_typ_transaction.gl_currency_code;
  END IF;

    x_movement_transaction.movement_type                   := 'A';
    x_movement_transaction.document_source_type            := 'RMA';
   -- x_movement_transaction.currency_conversion_rate        := 1;
    x_movement_transaction.transaction_nature              := '20';

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_RMA_Details;

--========================================================================
-- PROCEDURE : Get_Parent_Mvt          PRIVATE
-- PARAMETERS: p_rcv_transaction_id    transaction id
--             p_movement_transaction  movement transaction record
--             x_movement_id           movement id
--             x_movement_status       movement status
--             x_source_type           document source type
-- COMMENT   : Get movement id, movement status and source type of given
--             transaction id
--========================================================================
PROCEDURE Get_Parent_Mvt
( p_movement_transaction IN
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_rcv_transaction_id IN NUMBER
, x_movement_id       OUT NOCOPY NUMBER
, x_movement_status   OUT NOCOPY VARCHAR2
, x_source_type       OUT NOCOPY VARCHAR2
)
IS
BEGIN
  SELECT
    movement_id
  , movement_status
  , document_source_type
  INTO
    x_movement_id
  , x_movement_status
  , x_source_type
  FROM
    mtl_movement_statistics
  WHERE usage_type         =  p_movement_transaction.usage_type
    AND stat_type          =  p_movement_transaction.stat_type
    AND zone_code          =  p_movement_transaction.zone_code
    AND entity_org_id      =  p_movement_transaction.entity_org_id
    AND rcv_transaction_id =  p_rcv_transaction_id;

EXCEPTION
  WHEN OTHERS THEN
    x_movement_id := null;
    x_movement_status := null;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Parent_Mvt'||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_Parent_Mvt;

--========================================================================
-- PROCEDURE : Get_IO_Arrival_Txn    PRIVATE
-- PARAMETERS: io_arrival_crsr       REF cursor
--             x_return_status       return status
--             p_start_date          Transaction start date
--             p_end_date            Transaction end date
-- COMMENT   :
--             This opens the cursor for IO arrival and returns the cursor.
--========================================================================

PROCEDURE Get_IO_Arrival_Txn
( io_arrival_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.poCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_IO_Arrival_Txn';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF io_arrival_crsr%ISOPEN THEN
     CLOSE io_arrival_crsr;
  END IF;

  --Fix performance bug 4912552, use hr_organization_information to replace
  --org_organization_definitions according to proposal from INV
  --karthik.gnanamurthy, because inventory organization is already existing
  --in rcv_transactions, so it's not required to validate the organization
  --again in mtl_parameters or hr_all_organization_units as OOD does

  IF NVL(p_movement_transaction.creation_method,'A') = 'A'
  THEN
    --Fix bug 3364811, move order lines and delivery table out of
    --io_arrival_crsr so that no duplicate rcv transactions picked
    OPEN io_arrival_crsr FOR
    SELECT
      rcv.transaction_id
    , rcv.transaction_date
    , rcv.organization_id
    , rcv.subinventory
    , rcv.requisition_line_id
    , prha.segment1
    , rcv.oe_order_line_id /* Added for bug 9024785*/
    FROM
      rcv_transactions rcv
    , po_requisition_lines_all prla
    , po_requisition_headers_all prha
    , oe_order_headers_all orha
    , hr_organization_information hoi
    WHERE rcv.requisition_line_id = prla.requisition_line_id
      AND prla.requisition_header_id = prha.requisition_header_id
      AND prha.requisition_header_id = orha.source_document_id
      AND orha.order_source_id = 10  --oe_order_sources tbl
      AND orha.orig_sys_document_ref = prha.segment1
      AND rcv.organization_id        = hoi.organization_id
      AND hoi.org_information_context = 'Accounting Information'
      AND rcv.mvt_stat_status  = 'NEW'
      AND rcv.transaction_type = 'RECEIVE'
      AND NVL(rcv.source_document_code,'REQ') = 'REQ'
      AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
      AND rcv.transaction_date BETWEEN p_start_date AND p_end_date
    ORDER BY rcv.transaction_id;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_IO_Arrival_Txn;

--========================================================================
-- PROCEDURE : Get_IO_Arrival_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for IO Arrival
--========================================================================

PROCEDURE Get_IO_Arrival_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_unit_of_measure         rcv_transactions.unit_of_measure%TYPE;
l_transport_mode          mtl_movement_statistics.transport_mode%TYPE;
l_document_unit_price     mtl_movement_statistics.document_unit_price%TYPE;
l_item_type_code          OE_ORDER_LINES_ALL.Item_Type_Code%TYPE;
l_mvt_stat_status         rcv_transactions.mvt_stat_status%TYPE;

l_unit_selling_price   OE_ORDER_LINES_ALL.Unit_Selling_Price%TYPE;
l_qty_selling_price    OE_ORDER_LINES_ALL.Unit_Selling_Price%TYPE;
l_currency_code        OE_ORDER_HEADERS_ALL.Transactional_Curr_Code%TYPE;
l_error_code           NUMBER;
l_return_status        VARCHAR2(1);
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_IO_Arrival_Details';

CURSOR io_po_details IS
  SELECT
    rcv.transaction_id
  , rcv.organization_id
  , rcv.movement_id
  , rcv.mvt_stat_status
  , rcv.currency_code
  , rcv.currency_conversion_type
  , rcv.currency_conversion_rate
  , rcv.currency_conversion_date
  , rcv.shipment_header_id
  , rcv.shipment_line_id
  , rsl.item_id
  , rsl.item_description
  , rcv.unit_of_measure
  , rcv.quantity
  , rcv.primary_quantity
  --, nvl(cst.item_cost,0)
  , NVL(rcv.po_unit_price,0)
  , rcv.country_of_origin_code
  , NVL(rsh.freight_carrier_code,'3')
  FROM
    RCV_TRANSACTIONS rcv
  , RCV_SHIPMENT_HEADERS rsh
  , RCV_SHIPMENT_LINES rsl
  --, CST_ITEM_COSTS_FOR_GL_VIEW cst
  WHERE rcv.shipment_header_id  = rsh.shipment_header_id
    AND rsh.shipment_header_id = rsl.shipment_header_id
    AND rcv.shipment_line_id    = rsl.shipment_line_id
    --AND rsl.to_organization_id = cst.organization_id (+)
    --AND rsl.item_id            = cst.inventory_item_id (+)
    AND rcv.transaction_id      = x_movement_transaction.rcv_transaction_id;

CURSOR io_so_details IS
  SELECT
    oola.ship_to_org_id ship_to_site_use_id
  , wdd.fob_code delivery_terms
  , NVL(wdd.ship_method_code,'3') transport_mode
  --, to_number(NULL) picking_line_id
  , oola.line_id
  , ooha.header_id
  , ooha.order_number
  , oola.line_number
  , ooha.sold_to_org_id ship_to_customer_id
  , nvl(ooha.invoice_to_org_id,ooha.sold_to_org_id) bill_to_site_use_id
  , ooha.sold_to_org_id bill_to_customer_id
  , NVL(oola.unit_selling_price,0) doc_unit_price
  , oola.source_document_id req_hd_id
  , oola.source_document_line_id req_ln_id
  --, to_number(NULL) pick_slip_ref
  , rac.party_name cust_name
  , rac.party_number cust_number
  , substrb(rac.province,1,30) area
  , wnd.name shipment_reference
  , oola.item_type_code
  FROM
    WSH_NEW_DELIVERIES_OB_GRP_V wnd
  , wsh_delivery_assignments_v wda
  , WSH_DELIVERY_DETAILS_OB_GRP_V wdd
  , OE_ORDER_HEADERS_ALL ooha
  , OE_ORDER_LINES_ALL oola
  , HZ_PARTIES rac
  , HZ_CUST_ACCOUNTS hzc
  WHERE wnd.delivery_id             = wda.delivery_id
    AND wda.delivery_detail_id      = wdd.delivery_detail_id
    AND wdd.source_line_id          = oola.line_id
    AND ooha.header_id              = oola.header_id
    AND oola.line_id                = wdd.source_line_id
    AND oola.header_id              = wdd.source_header_id
    AND rac.party_id                = hzc.party_id
    AND ooha.sold_to_org_id         = hzc.cust_account_id
    AND wdd.delivery_detail_id      = x_movement_transaction.picking_line_detail_id;

CURSOR l_uom IS
  SELECT
    muc.uom_code
  FROM
    MTL_UOM_CONVERSIONS_VIEW muc
  WHERE muc.inventory_item_id= x_movement_transaction.inventory_item_id
  AND   muc.organization_id  = x_movement_transaction.organization_id
  AND   muc.unit_of_measure  = l_unit_of_measure;

  --Fix bug 4207119
  CURSOR c_item_cost IS
  SELECT
    item_cost
  FROM
    CST_ITEM_COSTS_FOR_GL_VIEW
  WHERE organization_id = x_movement_transaction.organization_id
    AND inventory_item_id = x_movement_transaction.inventory_item_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status        := 'Y';

  --Get IO receiving details
  OPEN   io_po_details;
  FETCH  io_po_details INTO
    x_movement_transaction.rcv_transaction_id
  , x_movement_transaction.organization_id
  , x_movement_transaction.movement_id
  , l_mvt_stat_status
  , x_movement_transaction.currency_code
  , x_movement_transaction.currency_conversion_type
  , x_movement_transaction.currency_conversion_rate
  , x_movement_transaction.currency_conversion_date
  , x_movement_transaction.shipment_header_id
  , x_movement_transaction.shipment_line_id
  , x_movement_transaction.inventory_item_id
  , x_movement_transaction.item_description
  , l_unit_of_measure
  , x_movement_transaction.transaction_quantity
  , x_movement_transaction.primary_quantity
  --, x_movement_transaction.item_cost
  , x_movement_transaction.document_unit_price
  , x_movement_transaction.origin_territory_code
  , x_movement_transaction.transport_mode;

  IF io_po_details%NOTFOUND
  THEN
    CLOSE io_po_details;
    x_return_status := 'N';

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name || '.end return N at io_po_details'
                    ,'exit procedure'
                    );
    END IF;
    RETURN;
  END IF;
  CLOSE io_po_details;

  --Get item cost     fix bug 4207119
  OPEN c_item_cost;
  FETCH c_item_cost INTO
    x_movement_transaction.item_cost;
  CLOSE c_item_cost;

  OPEN l_uom;
  FETCH l_uom INTO
    x_movement_transaction.transaction_uom_code;

  IF l_uom%NOTFOUND THEN
   x_movement_transaction.transaction_uom_code := substrb(l_unit_of_measure,1,3);
  END IF;
  CLOSE l_uom;

  IF x_movement_transaction.currency_code IS NULL
  THEN
    x_movement_transaction.currency_code := x_movement_transaction.gl_currency_code;
  END IF;

  --Get IO sales order details
  OPEN io_so_details;
  FETCH io_so_details INTO
      x_movement_transaction.ship_to_site_use_id
    , x_movement_transaction.delivery_terms
    , l_transport_mode
    --, x_movement_transaction.picking_line_id
    , x_movement_transaction.order_line_id
    , x_movement_transaction.order_header_id
    , x_movement_transaction.order_number
    , x_movement_transaction.line_number
    , x_movement_transaction.ship_to_customer_id
    , x_movement_transaction.bill_to_site_use_id
    , x_movement_transaction.bill_to_customer_id
    , l_document_unit_price
    , x_movement_transaction.requisition_header_id
    , x_movement_transaction.requisition_line_id
    --, x_movement_transaction.pick_slip_reference
    , x_movement_transaction.customer_name
    , x_movement_transaction.customer_number
    , x_movement_transaction.area            --the area for receiving side
    , x_movement_transaction.shipment_reference
    , l_item_type_code;

  IF io_so_details%NOTFOUND
  THEN
    CLOSE io_so_details;
    x_return_status := 'N';

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name || '.end return N at io_so_details'
                    ,'exit procedure'
                    );
    END IF;
    RETURN;
  END IF;
  CLOSE io_so_details;

  IF (x_movement_transaction.movement_id IS NOT NULL)
     AND (NVL(l_mvt_stat_status,'NEW')='MODIFIED')
  THEN
    x_movement_transaction.movement_type            := 'AA';
  ELSE
    x_movement_transaction.movement_type            := 'A';
  END IF;

  x_movement_transaction.transaction_nature       := '10';

  IF x_movement_transaction.origin_territory_code IS NULL
  THEN
    x_movement_transaction.origin_territory_code    :=
               x_movement_transaction.dispatch_territory_code;
  END IF;

  --Doc unit price and line ext value
  x_movement_transaction.document_unit_price      := x_movement_transaction.item_cost;
  x_movement_transaction.document_line_ext_value  := x_movement_transaction.document_unit_price *
                                                     x_movement_transaction.transaction_quantity;
  --Get IO details
  INV_MGD_MVT_SO_MDTR.Get_IO_Details
  ( x_movement_transaction => x_movement_transaction
  , x_return_status        => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Get_IO_Arrival_Details;

END INV_MGD_MVT_PO_MDTR;

/

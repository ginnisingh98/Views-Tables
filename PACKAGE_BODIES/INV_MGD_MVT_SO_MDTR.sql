--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_SO_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_SO_MDTR" AS
-- $Header: INVSMDRB.pls 120.11.12010000.3 2009/06/03 10:56:30 ajmittal ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVSMDRB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_SO_MDTR                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_SO_Transactions                                               |
--|     Get_TwoLeOneCntry_Txns                                            |
--|     Get_Triangulation_Txns                                            |
--|     Get_SO_Details                                                    |
--|     Get_KIT_SO_Details                                                |
--|     Update_SO_Transactions                                            |
--|     Update_KIT_SO_Transactions                                        |
--|     Get_IO_Details                                                    |
--|     Get_KIT_Status                                                    |
--|                                                                       |
--| HISTORY                                                               |
--+=======================================================================

--===================
-- CONSTANTS
--===================
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_SO_MDTR.';

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Get_SO_Transactions    PRIVATE
-- PARAMETERS: so_crsr                 REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for SO and returns the cursor.
--========================================================================

PROCEDURE Get_SO_Transactions
( so_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.soCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_SO_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF so_crsr%ISOPEN THEN
     CLOSE so_crsr;
  END IF;

  --Fix bug 2976193 remove hr_locations_all
  --Fix bug 3506597, replace confirm_date with initial_pickup_date
  --Fix bug 3624099, add hints according to Performance team's suggestion
  --Fix perf bug 4912552, use hr_organization_information to replace
  --org_organization_definitions according to proposal from INV
  --karthik.gnanamurthy, because inventory organization is already existing
  --in rcv_transactions, so it's not required to validate the organization
  --again in mtl_parameters or hr_all_organization_units as OOD does
  IF NVL(p_movement_transaction.creation_method,'A') = 'A'
  THEN
    IF NVL(p_movement_transaction.document_source_type,'SO') = 'IO'
    THEN
      OPEN so_crsr FOR
      SELECT
        wdd.delivery_detail_id picking_line_detail_id
      , wdd.organization_id warehouse_id
      , ol.ship_to_org_id ultimate_ship_to_id
      , wnd.initial_pickup_date  date_closed
      , ol.line_id
      , oh.order_number
      , ras.bill_to_site_use_id
      , ol.item_type_code
      , ol.link_to_line_id
      FROM
        WSH_NEW_DELIVERIES_OB_GRP_V wnd
      , wsh_delivery_assignments_v wda
      , WSH_DELIVERY_DETAILS_OB_GRP_V wdd
      , hr_organization_information hoi
      , OE_ORDER_LINES_ALL ol
      , OE_ORDER_HEADERS_ALL oh
      , HZ_CUST_SITE_USES_ALL ras
      WHERE wnd.delivery_id                 = wda.delivery_id
        AND wda.delivery_detail_id          = wdd.delivery_detail_id
        AND wdd.source_line_id              = ol.line_id
        AND ol.header_id                    = oh.header_id
        AND wdd.source_code                 = 'OE'
        AND wnd.organization_id             = hoi.organization_id --fix perf bug 4912552
        AND hoi.org_information_context = 'Accounting Information'
        AND ol.ship_to_org_id               = ras.site_use_id
        AND OE_INSTALL.Get_Active_Product  = 'ONT'
        AND oh.order_source_id      = 10
        AND wdd.shipped_quantity > 0
        AND wnd.status_code in ('IT','CL')
        AND wdd.mvt_stat_status in ('NEW','MODIFIED')
        --AND ol.item_type_code <> 'INCLUDED'          --Fix bug4185582
        AND hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
        AND wnd.initial_pickup_date between p_start_date and p_end_date;
    ELSE
      OPEN so_crsr FOR
      SELECT
        wdd.delivery_detail_id picking_line_detail_id
      , wdd.organization_id warehouse_id
      , ol.ship_to_org_id ultimate_ship_to_id
      , wnd.initial_pickup_date  date_closed
      , ol.line_id
      , oh.order_number
      , ras.bill_to_site_use_id
      , ol.item_type_code
      , ol.link_to_line_id
      FROM
        WSH_NEW_DELIVERIES_OB_GRP_V wnd
      , wsh_delivery_assignments_v wda
      , WSH_DELIVERY_DETAILS_OB_GRP_V wdd
      , hr_organization_information hoi
      , OE_ORDER_LINES_ALL ol
      , OE_ORDER_HEADERS_ALL oh
      , HZ_CUST_SITE_USES_ALL ras
      WHERE wnd.delivery_id                 = wda.delivery_id
        AND wda.delivery_detail_id          = wdd.delivery_detail_id
        AND wdd.source_line_id              = ol.line_id
        AND ol.header_id                    = oh.header_id
        AND wdd.source_code                 = 'OE'
        AND wnd.organization_id             = hoi.organization_id --fix perf bug2812364
        AND hoi.org_information_context = 'Accounting Information'
        AND ol.ship_to_org_id               = ras.site_use_id
        AND OE_INSTALL.Get_Active_Product  = 'ONT'
        AND wdd.shipped_quantity > 0
        AND wnd.status_code in ('IT','CL')
        AND wdd.mvt_stat_status in ('NEW','MODIFIED','FORDISP')
        --AND ol.item_type_code <> 'INCLUDED'                       --Fix bug4185582
        AND hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
        AND wnd.initial_pickup_date between p_start_date and p_end_date;
    END IF;
  ELSE
    OPEN so_crsr FOR
    SELECT
      wdd.delivery_detail_id picking_line_detail_id
    , wdd.organization_id warehouse_id
    , ol.ship_to_org_id ultimate_ship_to_id
    , wnd.initial_pickup_date  date_closed
    , ol.line_id
    , oh.order_number
    , ras.bill_to_site_use_id
    , ol.item_type_code
    , ol.link_to_line_id
    FROM
      WSH_NEW_DELIVERIES_OB_GRP_V wnd
    , wsh_delivery_assignments_v wda
    , WSH_DELIVERY_DETAILS_OB_GRP_V wdd
    , OE_ORDER_LINES_ALL ol
    , OE_ORDER_HEADERS_ALL oh
    , HZ_CUST_SITE_USES_ALL ras
    , hr_organization_information hoi
    WHERE wnd.delivery_id                 = wda.delivery_id
      AND wda.delivery_detail_id          = wdd.delivery_detail_id
      AND wdd.source_line_id              = ol.line_id
      AND ol.header_id                    = oh.header_id
      AND wdd.source_code                 = 'OE'
      AND wnd.organization_id             = hoi.organization_id --fix perf bug2812364
      AND hoi.org_information_context     = 'Accounting Information'
      AND ol.ship_to_org_id               = ras.site_use_id
      AND OE_INSTALL.Get_Active_Product  = 'ONT'
      AND wdd.shipped_quantity > 0
      AND wnd.status_code in ('IT','CL')
      AND wdd.mvt_stat_status in ('NEW','MODIFIED','FORDISP')
      --AND ol.item_type_code <> 'INCLUDED'                      --Fix bug4185582
      AND hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
      AND wnd.initial_pickup_date is NOT NULL
      AND wnd.name = p_movement_transaction.shipment_reference;
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

END Get_SO_Transactions;

--========================================================================
-- PROCEDURE : Get_Triangulation_Txns    PRIVATE
-- PARAMETERS: sot_crsr                 REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             Get SO transactions for the legal entity which initiates
--             this SO (not pick release side). This will be used to
--             create Arrival transaction for this legal entity in case
--             of invoice based triangulation mode. The dispatch record
--             will be picked by the regular Get_SO_Transaction
--========================================================================

PROCEDURE Get_Triangulation_Txns
( sot_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.soCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Triangulation_Txns';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF sot_crsr%ISOPEN THEN
     CLOSE sot_crsr;
  END IF;

  --Fix performance bug2812364, remove table oe_order_headers_all and
  --and hz_cust_site_uses_all
  --R12 Legal entity uptake, replace hr_operating_units base tables with XLE package
  --because this view is not existed anymore
  --Fix bug 5443301, replace ol.sold_from_org_id with ol.org_id
  --org_id is the correct column to get operating unit
  IF NVL(p_movement_transaction.creation_method,'A') = 'A'
  THEN
    OPEN sot_crsr FOR
    SELECT
      wdd.delivery_detail_id picking_line_detail_id
    , wdd.organization_id warehouse_id
    , ol.ship_to_org_id ultimate_ship_to_id
    , wnd.initial_pickup_date  date_closed
    , ol.line_id
    , wdd.source_header_number
    , ol.item_type_code
    , ol.link_to_line_id
    FROM
      WSH_NEW_DELIVERIES_OB_GRP_V wnd
    , wsh_delivery_assignments_v wda
    , WSH_DELIVERY_DETAILS_OB_GRP_V wdd
    , OE_ORDER_LINES_ALL ol
    , hr_organization_information hoi /*Bug 8467743*/
    WHERE wnd.delivery_id                 = wda.delivery_id
      AND wda.delivery_detail_id          = wdd.delivery_detail_id
      AND wdd.source_line_id              = ol.line_id
      AND wdd.source_code                 = 'OE'
      AND OE_INSTALL.Get_Active_Product  = 'ONT'
      AND wdd.shipped_quantity > 0
      AND ol.order_source_id <> 10
      AND wnd.status_code in ('IT','CL')
      AND wdd.mvt_stat_status in ('NEW','MODIFIED','FORARVL')
      AND wnd.initial_pickup_date between p_start_date and p_end_date
      AND hoi.org_information_context = 'Operating Unit Information'  /*Bug 8467743*/
      AND hoi.organization_id = nvl(ol.org_id,ol.sold_from_org_id)              /*Bug 8467743*/
      AND p_movement_transaction.entity_org_id =TO_NUMBER(hoi.org_information2); /*Bug 8467743*/
    /*      XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info
          ('SOLD_TO', ol.sold_to_org_id
          , null, null, ol.org_id);*/
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

END Get_Triangulation_Txns;

--========================================================================
-- PROCEDURE : Get_TwoLeOneCntry_Txns    PRIVATE
-- PARAMETERS: sot_crsr                 REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--========================================================================

PROCEDURE Get_TwoLeOneCntry_Txns
( sot_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.soCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_le_location          VARCHAR2(80);

BEGIN
null;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';
  WHEN OTHERS THEN
    x_return_status := 'N';

END Get_TwoLeOneCntry_Txns;


--========================================================================
-- PROCEDURE : Get_SO_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for PO
--========================================================================

PROCEDURE Get_SO_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)

IS
  l_shipment_transaction INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
  l_unit_selling_price   OE_ORDER_LINES_ALL.Unit_Selling_Price%TYPE;
  l_qty_selling_price    OE_ORDER_LINES_ALL.Unit_Selling_Price%TYPE;
  l_currency_code        OE_ORDER_HEADERS_ALL.Transactional_Curr_Code%TYPE;
  l_error_code           NUMBER;
  l_return_status        VARCHAR2(1);
  l_item_type_code       oe_order_lines_all.item_type_code%TYPE;
  l_order_uom            OE_ORDER_LINES_ALL.order_Quantity_Uom%TYPE;
  l_uom_conv_rate        NUMBER;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_SO_Details';

  --Fix bug 3318761, replace wsh_shipping_details_v with wdd and wnd tables
  --For performance reason, calculate item cost separately
  --Timezone support,not select transaction date here again

  --Fix bug 5443301, replace oola.sold_from_org_id with oola.org_id
  --org_id is the correct column to get operating unit and
  --oola.sold_from_org_id is no more populated by OM
  CURSOR so_details IS
  SELECT
    --oola.ship_to_org_id
    wdd.fob_code
  , NVL(wdd.ship_method_code,'3')
  , wdd.delivery_detail_id
  --, oola.line_id
  , ooha.header_id
  , ooha.order_number
  , oola.line_number
  , wdd.organization_id
  --, oola.sold_from_org_id
  , oola.org_id
  , wdd.delivery_detail_id
  , wdd.shipped_quantity
  , wdd.mvt_stat_status
  , wdd.movement_id
  , ooha.sold_to_org_id
  , nvl(ooha.invoice_to_org_id,ooha.sold_to_org_id)
  , ooha.sold_to_org_id
  , wdd.requested_quantity_uom
  , wdd.inventory_item_id
  , si.description
  , si.primary_uom_code
  , ooha.transactional_curr_code
  , ooha.conversion_type_code
  , ooha.conversion_rate
  , ooha.conversion_rate_date
  , oola.unit_selling_price
  , oola.orig_sys_line_ref
  , ooha.orig_sys_document_ref
  , ooha.order_source_id
  , rac.party_name
  , rac.party_number
  , substrb(rac.province,1,30)
  , wnd.name
  , oola.item_type_code
  , oola.order_quantity_uom
  FROM
    OE_ORDER_HEADERS_ALL ooha
  , OE_ORDER_LINES_ALL oola
  , wsh_delivery_details_ob_grp_v wdd
  , wsh_new_deliveries_ob_grp_v   wnd
  , wsh_delivery_assignments_v wda
  , HZ_PARTIES rac
  , HZ_CUST_ACCOUNTS hzc
  , MTL_SYSTEM_ITEMS si
  WHERE wnd.delivery_id             = wda.delivery_id
    AND wda.delivery_detail_id      = wdd.delivery_detail_id
    AND ooha.header_id              = oola.header_id
    AND oola.line_id                = wdd.source_line_id
    AND rac.party_id                = hzc.party_id
    AND ooha.sold_to_org_id         = hzc.cust_account_id
    AND wdd.inventory_item_id       = si.inventory_item_id
    AND wdd.organization_id         = si.organization_id
    AND wdd.delivery_detail_id = x_movement_transaction.picking_line_detail_id;

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

  OPEN   so_details;
  FETCH  so_details INTO
      --x_movement_transaction.ship_to_site_use_id
      x_movement_transaction.delivery_terms
    , x_movement_transaction.transport_mode
    , x_movement_transaction.picking_line_id
   -- , x_movement_transaction.order_line_id
    , x_movement_transaction.order_header_id
    , x_movement_transaction.order_number
    , x_movement_transaction.line_number
    , x_movement_transaction.organization_id
    , l_shipment_transaction.so_org_id
    , x_movement_transaction.picking_line_detail_id
    , x_movement_transaction.transaction_quantity
    , l_shipment_transaction.mvt_stat_status
    , x_movement_transaction.movement_id
    , x_movement_transaction.ship_to_customer_id
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
    , l_unit_selling_price
    , l_shipment_transaction.req_line_num
    , l_shipment_transaction.req_num
    , l_shipment_transaction.order_source_id
    , x_movement_transaction.customer_name
    , x_movement_transaction.customer_number
    , x_movement_transaction.area
    , x_movement_transaction.shipment_reference
    , l_item_type_code
    , l_order_uom;

  IF so_details%NOTFOUND THEN
    CLOSE so_details;
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
  CLOSE so_details;

  IF (x_movement_transaction.movement_id IS NOT NULL)
     AND (NVL(l_shipment_transaction.mvt_stat_status,'NEW')='MODIFIED')
  THEN
    x_movement_transaction.movement_type            := 'DA';
  ELSE
    x_movement_transaction.movement_type            := 'D';
  END IF;

  x_movement_transaction.document_source_type     := 'SO';
  x_movement_transaction.transaction_nature       := '11';

  --Change in R12, origin country should be same as of the shipping warehouse
  x_movement_transaction.origin_territory_code    :=
  INV_MGD_MVT_UTILS_PKG.Get_Org_Location
  (p_warehouse_id => x_movement_transaction.organization_id);
               --x_movement_transaction.dispatch_territory_code;

  IF x_movement_transaction.currency_code IS NULL
  THEN
    x_movement_transaction.currency_code :=
    x_movement_transaction.gl_currency_code;
  END IF;

  --Get document unit price for CTO item
  IF l_item_type_code = 'CONFIG'
  THEN
    --Call BOM procedure to get unit selling price
    CTO_PUBLIC_UTILITY_PK.Get_Selling_Price
    ( p_config_line_id     => x_movement_transaction.order_line_id
    , x_unit_selling_price => l_unit_selling_price
    , x_qty_selling_price  => l_qty_selling_price
    , x_currency_code      => l_currency_code
    , x_return_status      => l_return_status
    , x_error_code         => l_error_code
    );
  END IF;

  --SO order uom maynot be same as shipped qty uom,thus when calculate document
  --line ext value, we need to consider uom conversion
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
          NVL(l_unit_selling_price,0) * l_uom_conv_rate;
  x_movement_transaction.document_line_ext_value :=
       x_movement_transaction.document_unit_price *
       NVL(x_movement_transaction.transaction_quantity,0);

  --Get item cost for regular item
  OPEN c_item_cost;
  FETCH c_item_cost INTO
    x_movement_transaction.item_cost;
  CLOSE c_item_cost;

  /*-- If the sales order is a OPM sales order, get the item cost
  -- that is related to the OPM.
  IF (INV_MGD_MVT_UTILS_PKG.Is_Line_A_Process_Line
       (p_organization_id   => x_movement_transaction.organization_id
       ,p_inventory_item_id => x_movement_transaction.inventory_item_id))
  THEN
    INV_MGD_MVT_UTILS_PKG.Get_OPM_Item_Cost
      ( p_inventory_item_id  => x_movement_transaction.inventory_item_id
      , p_organization_id    => x_movement_transaction.organization_id
      , p_transaction_date   => x_movement_transaction.transaction_date
      , x_item_cost          => x_movement_transaction.item_cost
      , x_currency_code      => l_opm_curr_code
      , x_return_status      => l_opm_return_status
      , x_msg_count          => l_opm_msg_count
      , x_msg_data           => l_opm_msg_data
      );
  END IF;*/

  -- IF order category is of type P then it is an IO source type
  IF l_shipment_transaction.order_source_id = 10
  THEN
    x_movement_transaction.document_source_type := 'IO';

    Get_IO_Details
    ( x_movement_transaction => x_movement_transaction
    , x_return_status        => x_return_status
    );
  END IF;

  --Find out the operating unit where this SO is shipped
  IF x_movement_transaction.organization_id IS NOT NULL
  THEN
    SELECT
      TO_NUMBER(HOI2.ORG_INFORMATION3)
    INTO
      l_shipment_transaction.org_id
    FROM
      HR_ORGANIZATION_INFORMATION HOI1
    , HR_ORGANIZATION_INFORMATION HOI2
    , MTL_PARAMETERS MP
    WHERE MP.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
      AND MP.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
      AND HOI1.ORG_INFORMATION1 = 'INV'
      AND HOI1.ORG_INFORMATION2 = 'Y'
      AND HOI1.ORG_INFORMATION_CONTEXT = 'CLASS'
      AND HOI2.ORG_INFORMATION_CONTEXT = 'Accounting Information'
      AND mp.organization_id = x_movement_transaction.organization_id;
  END IF;

  IF ((l_shipment_transaction.org_id <> l_shipment_transaction.so_org_id)
      AND NVL(l_shipment_transaction.org_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
      AND NVL(l_shipment_transaction.so_org_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
  THEN
    x_movement_transaction.triangulation_country_code :=
    INV_MGD_MVT_UTILS_PKG.Get_Org_Location
    (p_warehouse_id => l_shipment_transaction.so_org_id);

    x_movement_transaction.triangulation_country_eu_code :=
    INV_MGD_MVT_UTILS_PKG.Convert_Territory_Code
    (x_movement_transaction.triangulation_country_code);
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

END Get_SO_Details;

--========================================================================
-- PROCEDURE : Get_KIT_SO_Details         PRIVATE
-- PARAMETERS: x_movement_transaction  movement transaction record
--             p_link_to_line_id       parent line id
-- COMMENT   : Get all the additional data required for KIT SO
--========================================================================
PROCEDURE Get_KIT_SO_Details
( p_link_to_line_id      IN VARCHAR2
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
  l_unit_selling_price   OE_ORDER_LINES_ALL.Unit_Selling_Price%TYPE;
  l_order_uom            OE_ORDER_LINES_ALL.order_Quantity_Uom%TYPE;
  l_uom_conv_rate        NUMBER;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_KIT_SO_Details';

  --Get line information for kit item line
  CURSOR c_kit_line IS
  SELECT
    oola.line_number
  , oola.unit_selling_price
  , NVL(oola.shipped_quantity, oola.fulfilled_quantity)
  , oola.order_quantity_uom
  , oola.order_quantity_uom
  , oola.ship_from_org_id
  , oola.inventory_item_id
  , msi.description
  , msi.primary_uom_code
  FROM
    oe_order_lines_all oola
  , mtl_system_items msi
  WHERE oola.inventory_item_id = msi.inventory_item_id
    AND oola.ship_from_org_id  = msi.organization_id
    AND line_id = p_link_to_line_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN c_kit_line;
  FETCH c_kit_line INTO
    x_movement_transaction.line_number
  , l_unit_selling_price
  , x_movement_transaction.transaction_quantity
  , x_movement_transaction.transaction_uom_code
  , l_order_uom
  , x_movement_transaction.organization_id
  , x_movement_transaction.inventory_item_id
  , x_movement_transaction.item_description
  , x_movement_transaction.primary_uom_code;

  CLOSE c_kit_line;

  --SO order uom maynot be same as shipped qty uom,thus when calculate document
  --line ext value, we need to consider uom conversion
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
          NVL(l_unit_selling_price,0) * l_uom_conv_rate;
  x_movement_transaction.document_line_ext_value :=
       x_movement_transaction.document_unit_price *
       NVL(x_movement_transaction.transaction_quantity,0);

  --Create record for parent kit, so set line id to parent line id
  x_movement_transaction.order_line_id := p_link_to_line_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name
                    ,'when no data found exception'
                  );
    END IF;

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name
                    ,'when others exception'
                  );
    END IF;

END Get_KIT_SO_Details;


--========================================================================
-- PROCEDURE : Get_IO_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for IO
--========================================================================

PROCEDURE Get_IO_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)

IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_IO_Details';

  --Get requisition header and line id
  CURSOR l_Get_Req_Info IS
  SELECT
    source_document_id
  , source_document_line_id
  FROM
    oe_order_lines_all oola
  , po_requisition_headers_all prha
  WHERE prha.requisition_header_id = oola.source_document_id
    AND line_id = x_movement_transaction.order_line_id;

  CURSOR l_io_organization IS
  SELECT
    source_organization_id
  , destination_organization_id
  FROM
    po_requisition_lines_all
  WHERE
    requisition_line_id = x_movement_transaction.requisition_line_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status        := 'Y';

  OPEN l_Get_Req_Info;
  FETCH l_Get_Req_Info INTO
    x_movement_transaction.requisition_header_id
  , x_movement_transaction.requisition_line_id;

  IF l_Get_Req_Info%NOTFOUND
  THEN
    x_return_status := 'N';
  END IF;

  CLOSE l_Get_Req_Info;

  IF x_movement_transaction.requisition_line_id IS NOT NULL
  THEN
    OPEN l_io_organization;
    FETCH l_io_organization INTO
      x_movement_transaction.from_organization_id
    , x_movement_transaction.to_organization_id;

    IF l_io_organization%NOTFOUND
    THEN
      x_return_status := 'N';
    END IF;

    CLOSE l_io_organization;
  END IF;

  x_movement_transaction.invoice_id           := null;
  x_movement_transaction.invoice_batch_id     := null;
  x_movement_transaction.invoice_line_ext_value  := null;
  x_movement_transaction.invoice_quantity     := null;
  x_movement_transaction.invoice_unit_price   := null;
  x_movement_transaction.invoice_line_ext_value := null;
  x_movement_transaction.invoice_line_reference := null;
  x_movement_transaction.customer_trx_line_id   := null;
  x_movement_transaction.financial_document_flag := 'NOT_REQUIRED';
  x_movement_transaction.document_source_type   := 'IO';

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

END Get_IO_Details;

--========================================================================
-- PROCEDURE : Update_SO_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_SO_Transactions
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_status               IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_shipment_transaction INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
  l_mvt_stat_status      wsh_delivery_details.mvt_stat_status%TYPE;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Update_SO_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  --Find out the current status
  SELECT mvt_stat_status
  INTO   l_mvt_stat_status
  FROM   wsh_delivery_details_ob_grp_v
  WHERE  delivery_detail_id  = p_movement_transaction.picking_line_detail_id;

  -- Update the transaction table
  IF l_mvt_stat_status = 'NEW'
  THEN
    IF p_status = 'ARRIVALPROCESSED'
    THEN
      --cross legal entity SO, the arrival is already created,so set the status
      --to "FORDISP" to be picked up again when run processor in other legal
      --entity
      UPDATE wsh_delivery_details
      SET    mvt_stat_status   = 'FORDISP'
           , movement_id       = p_movement_transaction.movement_id
      WHERE  delivery_detail_id  = p_movement_transaction.picking_line_detail_id;
    ELSIF p_status = 'DISPPROCESSED'
    THEN
      --cross legal entity SO, the dispatch is already created,so set the status
      --to "FORARVL" to be picked up again when run processor in other legal
      --entity
      UPDATE wsh_delivery_details
      SET    mvt_stat_status   = 'FORARVL'
           , movement_id       = p_movement_transaction.movement_id
      WHERE  delivery_detail_id  = p_movement_transaction.picking_line_detail_id;
    ELSE
      --Regular SO
      UPDATE wsh_delivery_details
      SET    mvt_stat_status   = 'PROCESSED'
           , movement_id       = p_movement_transaction.movement_id
      WHERE  delivery_detail_id  = p_movement_transaction.picking_line_detail_id;
    END IF;
  ELSE
    UPDATE wsh_delivery_details
    SET    mvt_stat_status   = 'PROCESSED'
           , movement_id       = p_movement_transaction.movement_id
    WHERE  delivery_detail_id  = p_movement_transaction.picking_line_detail_id;
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

END Update_SO_Transactions;

--========================================================================
-- PROCEDURE : Update_KIT_SO_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_KIT_SO_Transactions
( p_movement_id          IN  NUMBER
, p_delivery_detail_id   IN  NUMBER
, p_link_to_line_id      IN  NUMBER
, p_status               IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_shipment_transaction INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
  l_mvt_stat_status      wsh_delivery_details.mvt_stat_status%TYPE;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Update_KIT_SO_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  --Find out the current status
  SELECT mvt_stat_status
  INTO   l_mvt_stat_status
  FROM   wsh_delivery_details_ob_grp_v
  WHERE  delivery_detail_id  = p_delivery_detail_id;

  -- Update the transaction table
  IF l_mvt_stat_status = 'NEW'
  THEN
    IF p_status = 'ARRIVALPROCESSED'
    THEN
      --cross legal entity SO, the arrival is already created,so set the status
      --to "FORDISP" to be picked up again when run processor in other legal
      --entity
      UPDATE wsh_delivery_details
      SET    mvt_stat_status   = 'FORDISP'
           , movement_id       = p_movement_id
      WHERE  source_line_id IN (SELECT line_id              --fix bug 4185582
                                FROM oe_order_lines_all
                                WHERE link_to_line_id = p_link_to_line_id);
    ELSIF p_status = 'DISPPROCESSED'
    THEN
      --cross legal entity SO, the dispatch is already created,so set the status
      --to "FORARVL" to be picked up again when run processor in other legal
      --entity
      UPDATE wsh_delivery_details
      SET    mvt_stat_status   = 'FORARVL'
           , movement_id       = p_movement_id
      WHERE  source_line_id IN (SELECT line_id              --fix bug 4185582
                                FROM oe_order_lines_all
                                WHERE link_to_line_id = p_link_to_line_id);
    ELSE
      --Regular SO
      UPDATE wsh_delivery_details
      SET    mvt_stat_status   = 'PROCESSED'
           , movement_id       = p_movement_id
      WHERE  source_line_id IN (SELECT line_id              --fix bug 4185582
                                FROM oe_order_lines_all
                                WHERE link_to_line_id = p_link_to_line_id);
    END IF;
  ELSE
    UPDATE wsh_delivery_details
    SET    mvt_stat_status   = 'PROCESSED'
           , movement_id       = p_movement_id
    WHERE  source_line_id IN (SELECT line_id              --fix bug 4185582
                                FROM oe_order_lines_all
                                WHERE link_to_line_id = p_link_to_line_id);
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

END Update_KIT_SO_Transactions;


--========================================================================
-- FUNCTION  : Get_KIT_Status
-- PARAMETERS: p_delivery_detail_id
-- COMMENT   : Function that returns the status of a movement kit record
--             if a movement record for kit has been created, the status
--             returned is 'Y', otherwise return 'N'
--=========================================================================
FUNCTION Get_KIT_Status
( p_delivery_detail_id IN NUMBER
)
RETURN VARCHAR2
IS
l_kit_status          VARCHAR2(1);
l_mvt_status          VARCHAR2(30);
l_function_name CONSTANT VARCHAR2(30) := 'Get_KIT_Status';

CURSOR l_kit_processed
IS
  SELECT
    mvt_stat_status
  FROM
    wsh_delivery_details
  WHERE
    delivery_detail_id = p_delivery_detail_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_function_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN l_kit_processed;
  FETCH l_kit_processed INTO
    l_mvt_status;
  CLOSE l_kit_processed;

  --if mvt status is in 'PROCESSED' or 'FORARVL' (for SO triangulation)
  --then a kit record has been created, set the status to 'Y'
  IF l_mvt_status IN ('PROCESSED', 'FORARVL')
  THEN
    l_kit_status := 'Y';
  ELSE
    l_kit_status := 'N';
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_function_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  RETURN (l_kit_status);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'. too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_KIT_Status;

--========================================================================
-- FUNCTION  : Get_KIT_Triangulation_Status
-- PARAMETERS: p_delivery_detail_id
-- COMMENT   : Function that returns the status of a movement kit record
--             if a movement record for kit has been created, the status
--             returned is 'Y', otherwise return 'N'
--=========================================================================
FUNCTION Get_KIT_Triangulation_Status
( p_delivery_detail_id IN NUMBER
)
RETURN VARCHAR2
IS
l_kit_status          VARCHAR2(1);
l_mvt_status          VARCHAR2(30);
l_api_name CONSTANT VARCHAR2(30) := 'Get_KIT_Triangulation_Status';

CURSOR l_kit_processed
IS
  SELECT
    mvt_stat_status
  FROM
    wsh_delivery_details
  WHERE
    delivery_detail_id = p_delivery_detail_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN l_kit_processed;
  FETCH l_kit_processed INTO
    l_mvt_status;
  CLOSE l_kit_processed;

  --if mvt status is in 'PROCESSED' or 'FORDISP' (for SO triangulation)
  --then a kit record has been created, set the status to 'Y'
  IF l_mvt_status IN ('PROCESSED', 'FORDISP')
  THEN
    l_kit_status := 'Y';
  ELSE
    l_kit_status := 'N';
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  RETURN (l_kit_status);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_KIT_Triangulation_Status;

END INV_MGD_MVT_SO_MDTR;

/

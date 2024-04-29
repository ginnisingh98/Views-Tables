--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_ONT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_ONT_PVT" AS
-- $Header: JMFVSKOB.pls 120.27.12010000.2 2010/03/17 13:34:15 abhissri ship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|   JMFVSKOB.pls                                                        |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains ONT related calls that the Interlock          |
--|   accesses when processing SHIKYU transactions                        |
--|                                                                       |
--| PUBLIC FUNCTIONS/PROCEDURES:                                          |
--|   Calculate_Ship_Date                                                 |
--|   Process_Replenishment_SO                                            |
--|                                                                       |
--| HISTORY                                                               |
--|   05/09/2005 pseshadr     Created                                     |
--|   07/08/2005 vchu         Fixed GSCC error File.Pkg.21                |
--|   09/07/2005 vchu         Fixed Bug 4597298: removed reference to     |
--|                           RA_CUSTOMERS, which have been obsoleted     |
--|                           for R12, in Process_Replenishment_SO.       |
--|   10/17/2005 vchu         Modified signatures for Calculate_Ship_Date |
--|                           and Process_Replenishment_SO to fix an      |
--|                           issue with the calculation of scheduled     |
--|                           ship date.                                  |
--|   10/26/2005 vchu         Modified the logic of                       |
--|                           Process_Replenishment_SO to be dependent on |
--|                           the associated Replenishment PO rather than |
--|                           the Subcontracting PO if the action is 'C'  |
--|   02/15/2006 vchu         Changed the header comments of              |
--|                           Calculate_Ship_Date to specify that it has  |
--|                           has been made public.                       |
--|   03/23/2006 vchu         Fixed bug 5090721: Set last_updated_by and  |
--|                           last_update_login in the update statements. |
--|   03/24/2006 vchu         Fixed bug 4885422: Modified the logic in    |
--|                           Process_Replenishment_SO to handle the case |
--|                           where the current price of the SHIKYU       |
--|                           Component is defined in a secondary UOM.    |
--|   03/24/2006 vchu         Fixed bug 5090721: Removed commented code.  |
--|   03/24/2006 vchu         Cleaned up indentation and changed the      |
--|                           calls to FND_LOG.string to be enclosed in a |
--|                           single IF statement instead of nested ID    |
--|                           statements.                                 |
--|   04/05/2006 vchu         Modified the Price Quoting logic of         |
--|                           Process_Replenishment_SO to get the price   |
--|                           of the component directly from the price    |
--|                           list instead of making a second call to     |
--|                           the Process Order API.  Also, added         |
--|                           exception handling logic to handle the case |
--|                           where there are more than one price         |
--|                           effective (more than one price list line)   |
--|                           for the component.                          |
--|   04/12/2006 vchu         Fixed bug 5154755: Added logic to rollback  |
--|                           the newly created Sales Order, if its       |
--|                           unit_selling_price is NULL.  Also added the |
--|                           logic to update the JMF_SHIKYU_COMPONENTS   |
--|                           record to update the price list id and      |
--|                           currency even if there are too many         |
--|                           effective price list lines.                 |
--|   04/13/2006 vchu         Polished up the FND Log Messages.           |
--|   04/18/2006 rajkrish     Fixed bug 5002921: Set entity_code and      |
--|                           request_type of the l_action_request_tbl    |
--|                           in order to book the Sales Order.           |
--|   04/21/2006 vchu         Removed commented code.                     |
--|   05/03/2006 vchu         Fixed bug 5201694: Modified                 |
--|                           Process_Replenishment_SO to set context to  |
--|                           the OU specified in the concurrent request, |
--|                           instead the OU specified in the             |
--|                           'MO: Operating Unit' profile option.        |
--|   05/05/2006 rajkrish     Fixed bug 5209846 : Modified                |
--|                           Process_Replenishment_SO to get the Org ID  |
--|                           from the Replenishment PO Shipment, if      |
--|                           mo_global.get_current_org_id returned NULL. |
--|                           This is crucial for the Interlock Worker    |
--|                           since it is not MOAC enabled (in order to   |
--|                           support more then one OU).                  |
--|   05/08/2006 vchu         Fixed bug 5212219: Get the project and task |
--|                           ID from the distributions of the            |
--|                           Replenishment PO Shipment, and pass it to   |
--|                           the line level table parameter of the       |
--|                           Process Order API.                          |
--|                           Also fixed a stamping issue of the          |
--|                           primary_uom_price column of the             |
--|                           JMF_SHIKYU_COMPONENTS table in cases where  |
--|                           the value of the uom and primary uom        |
--|                           columns are the same primary UOM is active  |
--|                           in the price list.  This caused an          |
--|                           allocation issue for the sync-ship          |
--|                           components after an additional price check  |
--|                           was added to Create_New_Replenishment_Po_So |
--|                           of the JMF_SHIKYU_ALLOCATION_PVT package.   |
--|   05/09/2006 vchu         Fixed bug 5216720: Modified the             |
--|                           c_project_cur cursor to get Project ID and  |
--|                           Task ID from the Replenishment PO instead   |
--|                           of the Subcontracting PO.                   |
--|   05/11/2006 vchu         Modified various queries to get the         |
--|                           promised_date from PO_LINE_LOCATIONS_ALL    |
--|                           if need_by_date is NULL.                    |
--|   08/24/2006 vchu         Fixed bug 5485115: Remove the dependency on |
--|                           OE_PRICE_LIST_LINES in by querying the base |
--|                           table QP_LIST_LINES to get the unit_code    |
--|                           and list_price for the specific             |
--|                           subcontracting component.                   |
--|   11/08/2006 vchu         Fixed bug 5649321: Added an additional      |
--|                           where clause condition in the query to get  |
--|                           the Bill-to site ID of the customer (in     |
--|                           Process_Replenishment_SO), in order to      |
--|                           select only the active Bill-To site.        |
--|   1-May-08 kdevadas       Bug 7000413: If Rep SO creation fails,      |
--|                         complete the request in warning and log the   |
--|                           error in the request log                    |
--+=======================================================================+

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'JMF_SHIKYU_ONT_PVT';
g_log_enabled          BOOLEAN;

--=============================================
-- PROCEDURES AND FUNCTIONS
--=============================================

--========================================================================
-- PROCEDURE : Calculate_Ship_Date    PUBLIC
-- PARAMETERS:
--             p_subcontract_po_shipment_id  Subcontracting Order Shipment ID
--             p_component_item_id           SHIKYU Component to be shipped
--             p_oem_organization_id         OEM Organization
--             p_tp_organization_id          TP Organization
--             p_need_by_date                Need By Date of the corresponding
--                                           Replenishment PO Shipment
--             x_ship_date                   Ship Date calculated to meet the
--                                           passed in Need_By_Date
-- COMMENT   : This procedure computes the scheduled ship date for the component
--             based on the WIP start date and item lead times.
--========================================================================
PROCEDURE Calculate_Ship_Date
( p_subcontract_po_shipment_id IN  NUMBER
, p_component_item_id          IN  NUMBER
, p_oem_organization_id        IN  NUMBER
, p_tp_organization_id         IN  NUMBER
, p_quantity                   IN  NUMBER
, p_need_by_date               IN  DATE
, x_ship_date                  OUT NOCOPY DATE
)
IS

  l_program        CONSTANT VARCHAR2(30) := 'Calculate_Ship_Date';
  l_intransit_time NUMBER;
  l_wip_start_date DATE;
  l_need_by_date   DATE;
  l_osa_item_id    NUMBER;

  CURSOR c_interorg IS
  SELECT NVL(intransit_time,0)
  FROM   mtl_interorg_ship_methods
  WHERE  from_organization_id = p_oem_organization_id
  AND    to_organization_id   = p_tp_organization_id
  AND    default_flag         =1;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;

    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;

  OPEN c_interorg;
  FETCH c_interorg
  INTO  l_intransit_time;

  IF c_interorg%NOTFOUND
  THEN
    l_intransit_time :=0;
  END IF;
  CLOSE c_interorg;

  IF p_need_by_date IS NULL AND
     p_subcontract_po_shipment_id IS NOT NULL
    THEN

    -- Modified this query to get the need by date from the PO Line Location
    -- directly

    SELECT NVL(plla.need_by_date, plla.promised_date)
         , jso.osa_item_id
    INTO
      l_need_by_date
    , l_osa_item_id
    FROM
      jmf_subcontract_orders jso,
      po_line_locations_all  plla
    WHERE subcontract_po_shipment_id = p_subcontract_po_shipment_id
    AND   plla.line_location_id = jso.subcontract_po_shipment_id;

    JMF_SHIKYU_WIP_PVT.Compute_Start_Date
    ( p_need_by_date       => l_need_by_date
    , p_item_id            => l_osa_item_id
    , p_oem_organization   => p_oem_organization_id
    , p_tp_organization    => p_tp_organization_id
    , p_quantity           => p_quantity
    , x_start_date         => l_wip_start_date
    );

    IF g_log_enabled AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': l_wip_start_date = '
                    || l_wip_start_date
                    );
    END IF;

    x_ship_date := l_wip_start_date - l_intransit_time;

  ELSE

    IF g_log_enabled AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': p_need_by_date = '
                    || p_need_by_date
                    );
    END IF;

    x_ship_date := p_need_by_date - l_intransit_time;

  END IF; /* p_need_by_date IS NULL AND
             p_subcontract_po_shipment_id IS NOT NULL */

  IF x_ship_date < sysdate
  THEN
    x_ship_date := sysdate;
  END IF;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Returning x_ship_date = ' || x_ship_date
                  );
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;

    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': End'
                );
  END IF;

END Calculate_Ship_Date;

--========================================================================
-- PROCEDURE : Process_Replenishment_SO       PUBLIC
-- PARAMETERS: p_action              Action
--                                   'C'- Create new job
--                                   'D'- Delete Job
--                                   'U'- Update Job
--                                   'Q'- Price Quote
--            x_return_status         Return Status
-- COMMENT   : This procedure populates data in the interface table
--             and creates a replenishment SO for the subcontracting
--             order shipment line
--========================================================================
PROCEDURE Process_Replenishment_SO
( p_action                     IN  VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_quantity                   IN  NUMBER
, p_item_id                    IN  NUMBER
, p_replen_po_shipment_id      IN  NUMBER
, p_oem_organization_id        IN  NUMBER
, p_tp_organization_id         IN  NUMBER
, x_order_line_id              OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

  TYPE l_project_rec IS RECORD
  ( project_id       NUMBER
  , task_id          NUMBER
  );

  TYPE l_project_Tabtype IS TABLE of l_project_rec
    INDEX BY PLS_INTEGER;

  l_program CONSTANT VARCHAR2(30) := 'Process_Replenishment_SO';

  l_oe_header_rec             oe_order_pub.Header_Rec_Type;
  l_oe_line_rec               oe_order_pub.Line_Rec_Type;

  l_msg_count                 number;
  l_msg_data                  varchar2(2000);
  l_return_status             varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_header_rec                oe_order_pub.Header_Rec_Type;
  l_header_val_rec            oe_order_pub.Header_Val_Rec_Type  ;
  l_Header_Adj_tbl            oe_order_pub.Header_Adj_Tbl_Type;
  l_Header_Adj_val_tbl        oe_order_pub.Header_Adj_Val_Tbl_Type;
  l_Header_price_Att_tbl      oe_order_pub.Header_Price_Att_Tbl_Type;
  l_Header_Adj_Att_tbl        oe_order_pub.Header_Adj_Att_Tbl_Type;
  l_Header_Adj_Assoc_tbl      oe_order_pub.Header_Adj_Assoc_Tbl_Type;
  l_Header_Scredit_tbl        oe_order_pub.Header_Scredit_Tbl_Type;
  l_Header_Scredit_val_tbl    oe_order_pub.Header_Scredit_Val_Tbl_Type;
  l_line_tbl                  oe_order_pub.Line_Tbl_Type;
  l_line_val_tbl              oe_order_pub.Line_Val_Tbl_Type;
  l_Line_Adj_tbl              oe_order_pub.Line_Adj_Tbl_Type;
  l_Line_Adj_val_tbl          oe_order_pub.Line_Adj_Val_Tbl_Type;
  l_Line_price_Att_tbl        oe_order_pub.Line_Price_Att_Tbl_Type;
  l_Line_Adj_Att_tbl          oe_order_pub.Line_Adj_Att_Tbl_Type;
  l_Line_Adj_Assoc_tbl        oe_order_pub.Line_Adj_Assoc_Tbl_Type;
  l_Line_Scredit_tbl          oe_order_pub.Line_Scredit_Tbl_Type  ;
  l_Line_Scredit_val_tbl      oe_order_pub.Line_Scredit_Val_Tbl_Type;
  l_Lot_Serial_tbl            oe_order_pub.Lot_Serial_Tbl_Type;
  l_Lot_Serial_val_tbl        oe_order_pub.Lot_Serial_Val_Tbl_Type;
  l_action_request_tbl        oe_order_pub.Request_Tbl_Type;
  l_ship_date                 DATE;
  l_quantity                  NUMBER;
  l_primary_uom_code          VARCHAR2(3);
  l_unit_price                NUMBER;
  l_component_price           NUMBER;
  l_price_list_id             NUMBER;
  l_price_list_uom            VARCHAR2(3);
  l_pl_uom_qty                NUMBER;
  l_line_type_id              NUMBER;
  l_currency_code             OE_PRICE_LISTS.CURRENCY_CODE%TYPE;
  l_control_rec               oe_globals.control_rec_type;
  l_x_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
  l_x_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_x_line_tbl                OE_Order_PUB.Line_Tbl_Type;
  l_x_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
  l_x_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_x_action_request_tbl      OE_Order_PUB.request_tbl_type;
  l_x_lot_serial_tbl          OE_Order_PUB.lot_serial_tbl_type;
  l_hdr_payment_tbl           OE_Order_PUB.Header_Payment_Tbl_Type;
  l_line_payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
  l_org_id                    NUMBER;
  l_pl_count                  NUMBER;
  l_customer_id               NUMBER;
  l_bill_to_id                NUMBER;
  l_order_type_id             NUMBER;
  l_replen_po_need_by_date    DATE;
  l_uom_conversion_rate       NUMBER;
  l_item_number				  VARCHAR2(2000);

  l_no_price_list_found       EXCEPTION;
  l_too_many_effective_prices EXCEPTION;
  l_null_unit_price           EXCEPTION;
  l_too_many_project_task_ref EXCEPTION;

  l_client_info_org_id        NUMBER;
  l_project_id                NUMBER;
  l_task_id                   NUMBER;

  l_project_tbl               l_project_Tabtype;
  l_sub_comp             MTL_SYSTEM_ITEMS_B.segment1%TYPE;
  l_order_number         PO_HEADERS_ALL.SEGMENT1%TYPE;
  l_message         VARCHAR(2000);
  l_status_flag     BOOLEAN;

  -- Bug 5216720: Should get Project ID and Task ID from the Replenishment
  -- PO, not the Subcontracting PO

  CURSOR c_project_cur IS
  SELECT distinct project_id
       , task_id
  FROM   po_distributions_all
  WHERE  line_location_id = p_replen_po_shipment_id
  AND    project_id IS NOT NULL;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;

    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': p_action = ' || p_action
                  || ', p_subcontract_po_shipment_id = ' || p_subcontract_po_shipment_id
                  || ', p_item_id = ' || p_item_id
                  || ', p_quantity = ' || p_quantity
                  || ', p_replen_po_shipment_id = ' || p_replen_po_shipment_id
		  --Bugfix 9315131: Added debug statements
		  || ', p_oem_organization_id = ' || p_oem_organization_id
		  || ', p_tp_organization_id = ' || p_tp_organization_id
                  );
  END IF;

  -- Bug 5201694: Should set context to OU specified in the concurrent request,
  -- not the OU specified in the 'MO: Operating Unit' profile option.

  --l_org_id := FND_PROFILE.VALUE('ORG_ID');
  l_org_id := mo_global.get_current_org_id;


  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
      , G_PKG_NAME
      , '>> ' || l_program
      ||': Org ID from mo_global.get_current_org_id = ' || l_org_id
         );
  END IF;

  -- Bug 5209846 : Get the Operating Unit (Org ID) from the Replenishment PO
  -- Shipment, if mo_global.get_current_org_id returned NULL.  This is necessary
  -- for the Interlock Worker since the Worker Concurrent Program is not MOAC
  -- enabled (to support more then one OU).

  BEGIN

    IF l_org_id is NULL
      THEN
      SELECT org_id
      INTO   l_org_id
      FROM   po_line_locations_all
      WHERE  line_location_id = p_replen_po_shipment_id;
    END IF;

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program ||': Org ID selected from PO_LINE_LOCATIONS_ALL = '
                      || l_org_id
             );
     END IF;

  END;

  MO_GLOBAL.set_policy_context('S', l_org_id);

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||': Org ID from FND_PROFILE = ' || FND_PROFILE.VALUE('ORG_ID')
                  );
  END IF;

  SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
  INTO   l_client_info_org_id
  FROM   DUAL;

  IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||': Org ID from CLIENT_INFO = ' || l_client_info_org_id
                  );
  END IF;

  IF l_client_info_org_id <> l_org_id
    THEN
    fnd_client_info.set_org_context(TO_CHAR(l_org_id));

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                    || ': Setting the Org Context of CLIENT_INFO to the OU specified for MOAC ('
                    || l_org_id || ')'
                  );
    END IF;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;
  END IF;

  l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
  l_oe_line_rec   := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_quantity      := p_quantity;

  -- Bugs 5212219: To get the appropriate project and task reference from
  -- the Replenishment PO

  OPEN c_project_cur;
  FETCH c_project_cur
  BULK COLLECT INTO l_project_tbl;

  IF l_project_tbl.COUNT > 1
  THEN

    RAISE l_too_many_project_task_ref;

  ELSIF l_project_tbl.COUNT = 1
    THEN

    l_project_id := l_project_tbl(l_project_tbl.FIRST).project_id;
    l_task_id    := l_project_tbl(l_project_tbl.FIRST).task_id;

  ELSE

    l_project_id := NULL;
    l_task_id    := NULL;

  END IF; /* IF l_project_tbl.COUNT > 1 */

  CLOSE c_project_cur;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Project ID = ' || l_project_id
                    || ', Task ID = ' || l_task_id
                  );
  END IF;

  -- Get customer id
  SELECT TO_NUMBER(org_information1)
  INTO   l_header_rec.sold_to_org_id
  FROM   HR_ORGANIZATION_INFORMATION
  WHERE  organization_id = p_tp_organization_id
  AND    org_information_context = 'Customer/Supplier Association';

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||': Ship To customer id = ' || l_header_rec.sold_to_org_id
                  );
  END IF;

  -- Bug 4597298
  -- Remove reference to RA_CUSTOMERS, which have been obsoleted for R12
  -- The view oe_invoice_to_orgs_v selects HZ_CUST_SITE_USES_ALL.CUST_ACCOUNT_ID
  -- as customer_id, and HZ_CUST_SITE_USES_ALL.CUST_ACCOUNT_ID is just a foreign
  -- key to HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID.  So it should be safe to just
  -- remove the join with RA_CUSTOMERS, since the replacement object for getting
  -- the CUSTOMER_ID of RA_CUSTOMERS is HZ_CUST_ACCOUNTS.

  -- Get Bill-To customer site id
  -- Bug 5201694

  -- Bug 5649321: Added an additional where clause condition to get only the
  -- active Bill-To site.  This avoids a 'More than one row fetched'
  -- exception being thrown if there exists any inactive sites.

  SELECT site.site_use_id
  INTO   l_header_rec.invoice_to_org_id
  FROM   hz_cust_site_uses_all site,
         hz_cust_acct_sites_all acct_site
  WHERE  site.cust_acct_site_id = acct_site.cust_acct_site_id
  AND    site.site_use_code = 'BILL_TO'
  AND    site.org_id = acct_site.org_id
  AND    acct_site.cust_account_id = l_header_rec.sold_to_org_id
  AND    site.status = 'A';

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': Bill To org id = ' || l_header_rec.invoice_to_org_id
                  );
  END IF;

  -- Get the SHIKYU default order type from the shikyu-enabled Shipping Network
  -- from the OEM to the TP
  SELECT shikyu_default_order_type_id
  INTO   l_header_rec.order_type_id
  FROM   mtl_interorg_parameters
  WHERE  from_organization_id =  p_oem_organization_id
  AND    to_organization_id   =  p_tp_organization_id;

  -- Get the default outbound line type of the SHIKYU default order type
  SELECT default_outbound_line_type_id
  INTO   l_line_type_id
  FROM   oe_transaction_Types_all
  WHERE  transaction_type_id = l_header_rec.order_type_id;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': SHIKYU Default Order Type = ' || l_header_rec.order_type_id
                  || ', Default Outbound Line Type = ' || l_line_type_id
                  );
  END IF;

  BEGIN
    IF p_replen_po_shipment_id IS NOT NULL
    THEN
      SELECT NVL(need_by_date, promised_date)
      INTO   l_replen_po_need_by_date
      FROM   po_line_locations_all
      WHERE  line_location_id = p_replen_po_shipment_id;

      IF g_log_enabled AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program
                      || ': Replenishment PO Need By Date = ' || l_replen_po_need_by_date
                      );
  END IF;

    ELSE
      l_replen_po_need_by_date := NULL;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_replen_po_need_by_date := NULL;
  END;

  Calculate_Ship_Date
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_component_item_id          => p_item_id
  , p_oem_organization_id        => p_oem_organization_id
  , p_tp_organization_id         => p_tp_organization_id
  , p_quantity                   => l_quantity
  , p_need_by_date               => l_replen_po_need_by_date
  , x_ship_date                  => l_ship_date
  );

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Ship date = ' || l_ship_date
                  );
  END IF;

  l_customer_id := l_header_rec.sold_to_org_id;
  l_bill_to_id  := l_header_rec.invoice_to_org_id;
  l_order_type_id := l_header_rec.order_type_id;
  l_header_rec.ship_from_org_id :=
    p_oem_organization_id;

  l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
  l_header_rec.transaction_phase_code:= 'F';

  -- SO Line record
  l_line_tbl(1) := l_oe_line_rec;
  l_line_tbl(1).ordered_quantity := p_quantity;
  l_line_tbl(1).inventory_item_id := p_item_id;
  l_line_tbl(1).schedule_ship_Date := l_ship_date;
  l_line_tbl(1).request_date := l_ship_date;
  l_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
  l_line_tbl(1).line_type_id := l_line_type_id;
  l_line_tbl(1).project_id := l_project_id;
  l_line_tbl(1).task_id := l_task_id;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Parameters passing to Process Order:'
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Ordered_quantity = ' || p_quantity
                  || ', Item = ' || p_item_id
                  || ', Ship Date = ' || l_ship_date
                  || ', Line type = ' || l_line_type_id
                  );
  END IF;

  SELECT primary_uom_code
  INTO   l_primary_uom_code
  FROM   mtl_system_items_b
  WHERE  inventory_item_id = p_item_id
  AND    organization_id   = p_oem_organization_id;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||': Primary UOM = '|| l_primary_uom_code
                  );
  END IF;

  IF NVL(p_action,'C') = 'C'
    THEN

    IF g_log_enabled AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': p_action = ''C'': Getting UOM from Replenishment PO Shipment'
                    );
    END IF;

    IF p_replen_po_shipment_id IS NOT NULL
    THEN

      -- Get the UOM and quantity from the Replenishment PO Shipment to
      -- which the Replenishment SO Line to be created will be connected

      SELECT muomvl.uom_code,
             plla.quantity
      INTO   l_price_list_uom,
             l_quantity
      FROM   po_line_locations_all plla,
             mtl_units_of_measure_vl muomvl
      WHERE  plla.line_location_id = p_replen_po_shipment_id
      AND    plla.unit_meas_lookup_code = muomvl.unit_of_measure;

    ELSE

      -- Assume primary UOM is to be used if no reference to a Replenishment PO is provided

      l_price_list_uom := l_primary_uom_code;

    END IF; /* IF p_replen_po_shipment_id IS NOT NULL */

    IF g_log_enabled AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': l_price_list_uom = ' || l_price_list_uom
                    || ', l_quantity = ' || l_quantity
                    );
    END IF;

    l_line_tbl(1).visible_demand_flag := 'Y';
    l_line_tbl(1).order_quantity_uom := l_price_list_uom;
    l_line_tbl(1).ordered_quantity := l_quantity;

    -- Setting the values of the action_request_tbl in order to book the
    -- Sales Order
    l_action_request_tbl(1).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;
    l_action_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;

  END IF; /* IF NVL(p_action,'C') = 'C' */

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Calling Process Order, Creating SAVEPOINT before_process_order'
                  );
  END IF;

  SAVEPOINT before_process_order;

  OE_Order_PVT.Process_order
  ( p_api_version_number      => 1.0
  , p_init_msg_list           => FND_API.G_TRUE
  , x_return_status           => l_return_status
  , x_msg_count               => l_msg_count
  , x_msg_data                => l_msg_data
  , p_control_rec             => l_control_rec
  , p_x_header_Rec            => l_header_rec
  , p_x_line_tbl              => l_line_tbl
  , p_x_action_request_tbl    => l_action_request_tbl
  , p_x_Header_Adj_tbl        => l_x_Header_Adj_tbl
  , p_x_Header_Scredit_tbl    => l_x_Header_Scredit_tbl
  , p_x_Line_Adj_tbl          => l_x_Line_Adj_tbl
  , p_x_Line_Scredit_tbl      => l_x_Line_Scredit_tbl
  , p_x_Lot_Serial_tbl        => l_x_lot_serial_tbl
  , p_x_Header_price_Att_tbl  => l_Header_price_Att_tbl
  , p_x_Header_Adj_Att_tbl    => l_Header_Adj_Att_tbl
  , p_x_Header_Adj_Assoc_tbl  => l_Header_Adj_Assoc_tbl
  , p_x_Line_price_Att_tbl    => l_Line_price_Att_tbl
  , p_x_Line_Adj_Att_tbl      => l_Line_Adj_Att_tbl
  , p_x_Line_Adj_Assoc_tbl    => l_Line_Adj_Assoc_tbl
  , p_x_header_payment_tbl    => l_hdr_payment_tbl
  , p_x_line_payment_tbl      => l_line_payment_tbl
  );

  x_return_status := l_return_status;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': Process Order returned ' || l_return_status
                  || ', Sales Order Line ID = ' || l_line_tbl(1).line_id
                  );
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_REPLENISH_SO_ERR');
    FND_MSG_PUB.Add;
  /*  Bug 7000413 - Start */
  /* Log the error in the Concurrent Request log  if allocation fails */
    BEGIN
      SELECT segment1
      INTO l_order_number
      FROM po_headers_all poh
      WHERE EXISTS
      (SELECT 1 FROM po_line_locations_all poll
       WHERE poll.line_location_id = p_subcontract_po_shipment_id
       AND poll.po_header_id = poh.po_header_id);

      SELECT segment1
      INTO l_sub_comp
      FROM mtl_system_items_b
      WHERE inventory_item_id = p_item_id
      AND organization_id = p_tp_organization_id ;

      fnd_message.set_name('JMF','JMF_SHK_REP_SO_ERROR');
      fnd_message.set_token('SUB_ORDER', l_order_number );
      fnd_message.set_token('SUB_COMP', l_sub_comp);
      l_message := fnd_message.GET();
      fnd_file.put_line(fnd_file.LOG,  l_message);
      l_status_flag := FND_CONCURRENT.set_completion_status('WARNING',NULL);
    EXCEPTION
    WHEN OTHERS THEN
      NULL; -- Return null if there is an error in fetching the message
    END;
  /*  Bug 7000413 - End */


  END IF;

  -- To get price list id and price from the Sales Order Line
  -- just created by Process_Order API

  SELECT unit_selling_price,
         price_list_id
  INTO   l_unit_price,
         l_price_list_id
  FROM   oe_order_lines_all
  WHERE  line_id = l_line_tbl(1).line_id;

  IF l_price_list_id IS NULL
    THEN
    RAISE l_no_price_list_found;
  END IF;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': From Sales Order Line ID ' || l_line_tbl(1).line_id
                  || ': Price List ID = '|| l_price_list_id
                  || ', Unit Price = ' || l_unit_price
                  );
  END IF;

  -- Get the currency which the price list is in
  SELECT currency_code
  INTO   l_currency_code
  FROM   oe_price_lists
  WHERE  price_list_id = l_price_list_id;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': Price List Currency Code = ' || l_currency_code
                   );
  END IF;

  BEGIN

    -- Bug 5485115: Remove the dependency on OE_PRICE_LIST_LINES, which is a
    -- synonym on QP_PRICE_LIST_LINES_V that has a where clause condition that
    -- calls QP_UTIL.Get_Item_Validation_Org, which returns the value of
    -- the QP: Item Validation Organization profile option.
    -- The following query was rewritten to select from the based table
    -- QP_LIST_LINES, instead of the OE_PRICE_LIST_LINES view.

    /* Commenting as part of bugfix 9315131. Rewriting this sql.
    SELECT qp_price_list_pvt.get_product_uom_code(list_line_id),
           operand
    INTO   l_price_list_uom,
           l_component_price
    FROM   qp_list_lines
    WHERE  list_header_id = l_price_list_id
    AND    qp_price_list_pvt.get_inventory_item_id(list_line_id) = p_item_id
    AND    l_ship_date BETWEEN
           NVL(start_date_active, l_ship_date - 1)
           AND
           NVL(end_date_active, l_ship_date + 1);
    */

    SELECT qp_price_list_pvt.get_product_uom_code(qp.list_line_id),
           qp.operand
    INTO   l_price_list_uom,
           l_component_price
    FROM   qp_list_lines qp
    WHERE  qp.list_header_id = l_price_list_id
    AND EXISTS (SELECT 1
                 FROM qp_pricing_attributes qpa
                 WHERE qpa.list_line_id = qp.list_line_id
                   AND qpa.product_attribute_context = 'ITEM'
                   AND qpa.product_attribute =  'PRICING_ATTRIBUTE1'
                   AND to_number(product_attr_value) = p_item_id
                   AND ROWNUM = 1)
    AND    l_ship_date  BETWEEN
           NVL(start_date_active, l_ship_date - 1)
           AND
           NVL(end_date_active, l_ship_date + 1);

  EXCEPTION
    WHEN TOO_MANY_ROWS THEN

      IF NVL(p_action,'C') = 'Q'
        THEN

        -- Update the shikyu component with the price list id and
        -- the currency although the pricing UOM and shikyu component
        -- price could not be obtained
        UPDATE jmf_shikyu_components
        SET currency = l_currency_code
          , price_list_id = l_price_list_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          , last_update_login = FND_GLOBAL.login_id
        WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
        AND    oem_organization_id = p_oem_organization_id
        AND    shikyu_component_id = p_item_id;

	--Debugging changes for bug 9315131
	IF g_log_enabled AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_PKG_NAME
                     , '>> ' || l_program
                    || ': New Msg: After updating jmf_shikyu_components for shipment:' || p_subcontract_po_shipment_id
		    || 'p_item_id:' || p_item_id
                      );
        END IF;

      END IF;

      RAISE l_too_many_effective_prices;
  END;

  IF g_log_enabled AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': Price List UOM = '|| l_price_list_uom
                  || ', List Price = ' || l_component_price
                  );
      END IF;

  IF NVL(p_action,'C') = 'C' AND l_unit_price IS NULL
    THEN

    IF g_log_enabled AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': p_action = ''C'' and Unit Price is NULL: Rollback the created Sales Order'
                    );
    END IF;

    -- Rollback the creation of the Sales Order if the action
    -- is Create, but the unit selling price of the created
    -- Sales Order Line is NULL
    ROLLBACK to before_process_order;

    RAISE l_null_unit_price;

  END IF; /* IF NVL(p_action,'C') = 'C' AND l_unit_price IS NULL */

  IF NVL(p_action,'C') = 'Q'
  THEN

    IF g_log_enabled AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': p_action = ''Q'''
                    );
    END IF;

    -- If the price list line currently effective for the component is
    -- not defined in the primary uom
    IF l_primary_uom_code <> l_price_list_uom
      THEN

      IF g_log_enabled AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program
                      || ': Price List UOM <> Primary UOM: '
                      || 'Getting UOM Conversion Rate from '
                      || l_primary_uom_code || ' to ' || l_price_list_uom
                      );
      END IF;

      -- Fix for Bug 4885422: Get the conversion rate between the primary and
      -- secondary UOMs, and then get the unit price of the SHIKYU component
      -- in the primary UOM, since the current price is defined in secondary UOM.

      l_uom_conversion_rate := JMF_SHIKYU_UTIL.Get_Uom_Conversion_Rate
                               ( P_from_unit => l_price_list_uom
                               , P_to_unit   => l_primary_uom_code
                               , P_item_id   => p_item_id
                               );

      l_unit_price := l_component_price / l_uom_conversion_rate;

      IF g_log_enabled
         AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program
                      || ': l_component_price = ' || l_component_price
                      || ', l_uom_conversion_rate = ' || l_uom_conversion_rate
                      || ', l_unit_price = ' || l_unit_price
                      );
      END IF;

    ELSE

      l_unit_price := l_component_price;

    END IF; /* l_primary_uom_code <> l_price_list_uom */

    ROLLBACK TO before_process_order; -- get_price;

    IF p_subcontract_po_shipment_id IS NOT NULL
      THEN

      IF g_log_enabled AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program || ': Updating JMF_SHIKYU_COMPONENTS table'
                      );
      END IF;

      UPDATE jmf_shikyu_components
      SET primary_uom_price = l_unit_price
        , primary_uom = l_primary_uom_code
        , uom         = l_price_list_uom
        , currency    = l_currency_code
        , price_list_id = l_price_list_id
        , shikyu_component_price = l_component_price
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.login_id
      WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
      AND    oem_organization_id = p_oem_organization_id
      AND    shikyu_component_id = p_item_id;

      IF g_log_enabled AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program || ': Updated JMF_SHIKYU_COMPONENTS table'
                      );
      END IF;

    END IF; /* IF p_subcontract_po_shipment_id IS NOT NULL */

  END IF; /* IF NVL(p_action,'C') = 'Q' */

  x_order_line_id := l_line_tbl(1).line_id;

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Returning x_order_line_id = ' || x_order_line_id
                );
  END IF;

  IF l_client_info_org_id <> l_org_id
    THEN
    fnd_client_info.set_org_context(TO_CHAR(l_client_info_org_id));

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                    || ': Setting the Org Context of CLIENT_INFO back to the original value ('
                    || l_client_info_org_id || ')'
                  );
    END IF;

  END IF;

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': End'
                );
  END IF;

EXCEPTION

  WHEN l_too_many_effective_prices THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    ROLLBACK TO before_process_order;

    IF g_log_enabled AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      SELECT concatenated_segments
      INTO   l_item_number
      FROM   MTL_SYSTEM_ITEMS_VL
      WHERE  organization_id = p_oem_organization_id
      AND    inventory_item_id = p_item_id;

      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Too many prices effective for item "' || l_item_number || '"');
    END IF;

  WHEN l_no_price_list_found THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF g_log_enabled AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      SELECT concatenated_segments
      INTO   l_item_number
      FROM   MTL_SYSTEM_ITEMS_VL
      WHERE  organization_id = p_oem_organization_id
      AND    inventory_item_id = p_item_id;

      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_PKG_NAME
                    , '>> ' || l_program || ': No effective price list found for item "' || l_item_number || '"');
    END IF;

  WHEN l_null_unit_price THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF g_log_enabled AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      SELECT concatenated_segments
      INTO   l_item_number
      FROM   MTL_SYSTEM_ITEMS_VL
      WHERE  organization_id = p_oem_organization_id
      AND    inventory_item_id = p_item_id;

      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Unit price could not be obtained for '
                    || l_item_number
                    || ' from the Price List'
                    );

      IF l_price_list_uom <> l_line_tbl(1).order_quantity_uom
        THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                      , G_PKG_NAME
                      , '>> ' || l_program || ': Unit of Measure specified for the Replenishment PO ('
                      || l_line_tbl(1).order_quantity_uom
                      || ') does not correspond to the Unit of Measure currectly effective ('
                      || l_price_list_uom
                      || ') in the Price List'
                      );
      END IF;
    END IF;

  WHEN l_too_many_project_task_ref THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF g_log_enabled AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_PKG_NAME
                    , '>> ' || l_program || ': More than one Project and Task reference found'
                    );
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_REPLENISH_SO_ERR');
    FND_MSG_PUB.add;

    IF g_log_enabled AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_PKG_NAME
                    , '>> ' || l_program || ': OTHER EXCEPTION: ' || sqlerrm);
    END IF;

END Process_Replenishment_SO;

END JMF_SHIKYU_ONT_PVT;

/

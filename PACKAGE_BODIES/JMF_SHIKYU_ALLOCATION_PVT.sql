--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_ALLOCATION_PVT" AS
--$Header: JMFVSKAB.pls 120.27.12010000.2 2008/09/18 18:32:43 rrajkule ship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME:          JMFVSKAB.pls                                          |
--|                                                                           |
--|  DESCRIPTION:       Package body of the Business Object API for the       |
--|                     SHIKYU allocations.                                   |
--|                     Allocations are associations between Subcontracting   |
--|                     Components and Replenishment Sales Order Lines used   |
--|                     to track the Replenishments consumed by the           |
--|                     Subcontracting orders when manufacturing OSA items.   |
--|                                                                           |
--|                     This package contains procedures/functions to find    |
--|                     available replenishments, and to create, decrease,    |
--|                     delete allocations.                                   |
--|                                                                           |
--| PUBLIC FUNCTIONS/PROCEDURES:                                              |
--|   Allocate_Quantity                                                       |
--|   Allocate_Quantity                                                       |
--|   Get_Available_Replenishment_So                                          |
--|   Get_Available_Replenishment_Po                                          |
--|   Create_New_Replenishment_Po_So                                          |
--|   Create_New_Replenishment_So                                             |
--|   Create_New_Allocations                                                  |
--|   Allocate_Prepositioned_Comp                                             |
--|   Allocate_Syncship_Comp                                                  |
--|   Reduce_Allocations                                                      |
--|   Delete_Allocations                                                      |
--|   Reconcile_Partial_Shipments                                             |
--|   Reconcile_Closed_Shipments                                              |
--|   Reconcile_Replen_Excess_Qty                                             |
--|                                                                           |
--| PRIVATE FUNCTIONS/PROCEDURES:                                             |
--|   Get_Replen_So_Attributes                                                |
--|   Get_Allocation_Attributes                                               |
--|   Populate_Replenishment                                                  |
--|   Validate_Price                                                          |
--|   Validate_Project_Task_Ref                                               |
--|   Reduce_One_Allocation                                                   |
--|   Initialize                                                              |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   19-MAY-2005       vchu  Created.                                        |
--|   07-JUL-2005       vchu  Fixed GSCC errors.                              |
--|   01-AUG-2005       vchu  Modified the Validate_Project_Task_Ref          |
--|                           procedure to validate the project and task      |
--|                           reference of a Replenishment Sales Order Line   |
--|                           against the JMF_SUBCONTRACT_ORDERS record for   |
--|                           the Subcontracting Order instead of the         |
--|                           PO_LINES_ALL record.                            |
--|   03-AUG-2005       vchu  Added the Initialize procedure to perform API   |
--|                           Intialization.                                  |
--|   04-AUG-2005       vchu  Modified the Get_Available_Replenishment_So     |
--|                           procedure: added a where clause condition to    |
--|                           c_avail_replen_so_cur to only select the        |
--|                           replenishments with remaining quantity > 0.     |
--|   04-AUG-2005       vchu  Added more in-line comments.  Removed the       |
--|                           commented code because of the removal of the    |
--|                           uom parameters from most procedures.            |
--|   18-AUG-2005       vchu  Modified the where clause of the                |
--|                           c_avail_replen_so_cur cursor to remove the      |
--|                           calls to to_date.                               |
--|   29-SEP-2005       vchu  Modified INSERT INTO JMF_SHIKYU_ALLOCATIONS     |
--|                           statement in Allocate_Quantity to populate the  |
--|                           UOM column with l_primary_uom instead of        |
--|                           l_allocated_uom.                                |
--|   12-OCT-2005       vchu  Modified the order by clause of the query for   |
--|                           the c_avail_replen_po_cur cursor to create      |
--|                           allocations in FIFO order of need-by-date, PO   |
--|                           Number, Line Number and Shipment Number.        |
--|   17-OCT-2005       vchu  Modified calls to JMF_SHIKYU_ONT_PVT.           |
--|                           Process_Replenishment_SO due to a               |
--|                           change of signature.  Also added the where      |
--|                           clause condition "pha.approved_flag = 'Y'" to   |
--|                           the query of the c_avail_replen_po_cur cursor   |
--|                           in the Get_Available_Replenishment_Po procedure |
--|   26-OCT-2005       vchu  Replaced dbms_output calls with FND_LOG calls.  |
--|                           Also modified the value to populate into the    |
--|                           TP_SUPPLIER_ID and TP_SUPPLIER_SITE_ID columns  |
--|                           of the JMF_SHIKYU_REPLENISHMENTS table for      |
--|                           fixing the wrong value issue of the             |
--|                           Manufacturing Partner / MP site as described    |
--|                           in bug 4651480.                                 |
--|   09-NOV-2005       vchu  Modified the query of the c_avail_replen_so_cur |
--|                           to order first by schedule_ship_date.  Also     |
--|                           modified the logic to set the value of the      |
--|                           l_threshold_date local variable in the          |
--|                           Get_Available_Replenishment_So procedure, in    |
--|                           order to find available replenishment SOs to    |
--|                           fulfill Subcontracting Orders with WIP jobs for |
--|                           which the scheduled completion date has passed. |
--|                           Also added additional FND Log messages to the   |
--|                           Create_New_Allocations procedure.               |
--|   18-NOV-2005       vchu  Added the condition NVL(cancel_flag, 'N') = 'N' |
--|                           to the where clause of c_avail_replen_po_cur    |
--|                           (for PO Header, Line and Line Location levels)  |
--|                           in order to filter out the cancelled            |
--|                           Replenishment POs.                              |
--|   14-FEB-2006       vchu  Bug fix for 4997830: Added open cursor statement|
--|                           for c_subcontract_po_allocations in the         |
--|                           Reconcile_Replen_Excess_Qty procedure.          |
--|   27-MAR-2006       vchu  Fixed bug 5090721: Set last_update_date,        |
--|                           last_updated_by and last_update_login in the    |
--|                           update statements.                              |
--|   21-APR-2006       vchu  Modified the Reconcile_Partial_Shipments        |
--|                           procedure (for bug 5166092):                    |
--|                           1) Modified the INSERT statement for            |
--|                           JMF_SHIKYU_REPLENISHMENTS to populate the       |
--|                           additional_supply, primary_uom, and the primary |
--|                           uom quantity columns properly.                  |
--|                           2) Added an UPDATE statement to update the      |
--|                           allocable quantity of the parent Replenishment  |
--|                           SO Line after reducing the quantity that was    |
--|                           splitted into child SO Lines.                   |
--|   25_APR-2006   rajkrish  Bug fix for 5166092:                            |
--|                           Partial shipments process. Changed the OM       |
--|                           cursor fetching the child records.              |
--|                           Added more debug log.                           |
--|   29-APR-2006       vchu  Added a call to validate_price after calling    |
--|                           Create_New_Replenishment_Po_So in               |
--|                           Allocate_Syncship_Comp, to make sure that the   |
--|                           price of the newly created Replenishment SO     |
--|                           Line does match the price of the SHIKYU         |
--|                           Component price.  These two prices might be     |
--|                           different if the sync-ship component of a       |
--|                           Subcontracting Order didn't get allocated in    |
--|                           the same Interlock run which loaded the         |
--|                           Subcontracting Order itself, and the price of   |
--|                           the component happened to have been changed on  |
--|                           the price list.                                 |
--|   02-MAY-2006       vchu  Bug 5197415: Added the p_skip_po_replen_creation|
--|                           parameter to Create_New_Allocations and         |
--|                           Allocate_Syncship_Comp, in order to give the    |
--|                           option of skipping the creation of new          |
--|                           Replenishment POs for sync-ship components.     |
--|                           The Interlock Concurrent Program would use this |
--|                           option if creation of Replenishment SOs has     |
--|                           already failed when trying to create            |
--|                           Replenishment SOs for the Replenishment POs     |
--|                           that do not yet present in the                  |
--|                           JMF_SHIKYU_REPLENISHMENTS table.                |
--|   08-MAY-2006       vchu  Modified validate_price to consider the uom     |
--|                           column first before the primary uom column of   |
--|                           the jmf_shikyu_components table.                |
--|                           Also added debug log messages.                  |
--|   09-MAY-2006       vchu  Added a call to Validate_Project_Task_Ref after |
--|                           calling Create_New_Replenishment_Po_So in       |
--|                           Allocate_Syncship_Comp, to make sure that the   |
--|                           project and task reference of the newly created |
--|                           Replenishment SO Line actually matches that of  |
--|                           the Subcontracting Order Shipment.              |
--|   10-MAY-2006       vchu  Added a WHEN OTHERS THEN statement to the       |
--|                           EXCEPTION block of all the procedures to print  |
--|                           out the sqlerrm.  Also replaced hardcoding of   |
--|                           the 'S' status by FND_API.G_RET_STS_SUCCESS.    |
--|   11-MAY-2006       vchu  Modified Delete_Allocations to only update      |
--|                           the allocated_quantity of the corresponding     |
--|                           jmf_shikyu_replenishments record if there were  |
--|                           indeed allocations being deleted.  The wrong    |
--|                           condition was used to check for an empty table  |
--|                           before.  Should check to see if                 |
--|                           x_deleted_allocations_tbl.FIRST is NULL or not  |
--|                           Also modified various queries to get the        |
--|                           promised_date from the PO_LINE_LOCATIONS_ALL    |
--|                           table if need_by_date is NULL.                  |
--|  25-MAY-2006    rajkrish  Added the NOT EXISTS caluse in the              |
--|                           INSERT into JMF table in partial_reconcile      |
--|  13-JUN-2006        vchu  Bug fix for 5291292:                            |
--|                           Modified delete_allocations to reference the    |
--|                           replenishment so line of the allocation         |
--|                           currently being processed using the             |
--|                           replenishment_so_line_id of the records of      |
--|                           x_deleted_allocations_tbl from the RETURNING    |
--|                           clause of the DELETE statements, instead of     |
--|                           using the p_replen_so_line_id parameter.        |
--|  27-JUN-2006        vchu  Fixed the Reconcile_Replen_Excess_Qty procedure:|
--|                           1) Modified the calculation to get the actual   |
--|                           quantity to be reduced because of the excess    |
--|                           quantity, which used to cause over deallocation |
--|                           2) Set the return status to Y as long as the    |
--|                           whole quantity to be reduced has been processed.|
--|                           The procedure used to return error if the       |
--|                           Subcontracting Order that got deallocated       |
--|                           cannot be reallocated because there are no more |
--|                           Replenishment Orders with available quantity.   |
--|  06-AUG-2006    rajkrish  Partial reconciliation changes. 5437721         |
--|                           Replace the child SO cursor with the            |
--|                           CONNECT BY clause.                              |
--|  22-AUG-2006        vchu  Bug fix for bug 5260244: Truncated the time     |
--|                           component of the schedule_ship_date of a        |
--|                           Replenishment Sales Order Line before adding    |
--|                           the intransit lead time and comparing the sum   |
--|                           to the threshold date.  This is required for    |
--|                           the case where the threshold date happens to    |
--|                           fall on the same date as the schedule_ship_date,|
--|                           since Process Order API always defaults the     |
--|                           time of the scheduled_ship_date to be 23:59:00. |
--|  20-SEP-2006        vchu  Bug fix for bug 5510544: Modified the query of  |
--|                           the cursor c_avail_replen_so_cur of the         |
--|                           Get_Available_Replenishment_So procedure to     |
--|                           recognize the already received so lines as      |
--|                           available for allocation, in the case where     |
--|                           p_arrived_so_lines_only = 'Y', which is         |
--|                           typically used by the Adjustments Concurrent    |
--|                           Program.                                        |
--|  22-NOV-2006        vchu  Bug fix for bug 5675563: Replaced the ocurrences|
--|                           of shipping_quantity_uom in the cursor query    |
--|                           for c_avail_replen_so_cur in the procedure      |
--|                           Get_Available_Replenishment_So with             |
--|                           order_quantity_uom, since shipped_quantity is   |
--|                           in order_quantity_uom.                          |
--|   04-OCT-2007    kdevadas 12.1 Buy/Sell Subcontracting changes            |
--|                           Reference - GBL_BuySell_TDD.doc                 |
--|                           Reference - GBL_BuySell_FDD.doc                 |
--|   01-MAY-2008      kdevadas  Bug 7000413 -  In case of errors during      |
--|                              allocation, the appropriate message is       |
--|                              set and displayed in the request log         |
--|   18-SEP-2008   rrajkule  Bug 7383574-Changed cursor C_child_so_lines_CSR |
--|                           to have inline view to avoid FTS.               |
--+===========================================================================+

--=============================================
-- CONSTANTS
--=============================================

G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || G_PKG_NAME || '.';

--=============================================
-- GLOBAL VARIABLES
--=============================================

g_fnd_debug   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

--=============================================
-- PRIVATE HELPER PROCEDURES/FUNCTIONS
--=============================================

PROCEDURE Get_Replen_So_Attributes
( p_replen_so_line_id         IN  NUMBER
, x_header_id                 OUT NOCOPY NUMBER
, x_allocable_primary_uom_qty OUT NOCOPY NUMBER
, x_allocated_primary_uom_qty OUT NOCOPY NUMBER
, x_uom                       OUT NOCOPY VARCHAR2
, x_primary_uom               OUT NOCOPY VARCHAR2
, x_replen_so_line_exists     OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Allocation_Attributes
( p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_replen_so_line_id          IN  NUMBER
, x_allocated_qty              OUT NOCOPY NUMBER
, x_uom                        OUT NOCOPY VARCHAR2
, x_allocation_exists          OUT NOCOPY VARCHAR2
);

PROCEDURE Populate_Replenishment
( p_replen_so_line_id     IN NUMBER
, p_replen_po_shipment_id IN NUMBER
, p_component_id          IN NUMBER
, p_oem_organization_id   IN NUMBER
, p_tp_organization_id    IN NUMBER
, p_primary_uom           IN VARCHAR2
, p_primary_uom_qty       IN NUMBER
, p_additional_supply     IN VARCHAR2
);

FUNCTION Validate_Price
( p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
)
RETURN BOOLEAN;

FUNCTION Validate_Project_Task_Ref
( p_subcontract_po_shipment_id IN NUMBER
--, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
)
RETURN BOOLEAN;

PROCEDURE Reduce_One_Allocation
( p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
, p_remain_qty_to_reduce       IN NUMBER
, p_existing_alloc_qty         IN NUMBER
, p_alloc_uom                  IN VARCHAR2
, x_reduced_allocations_rec    OUT NOCOPY g_allocation_qty_rec_type
);

PROCEDURE Initialize
( p_api_version       IN  NUMBER
, p_input_api_version IN  NUMBER
, p_api_name          IN  VARCHAR2
, p_init_msg_list     IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
);

--=============================================
-- PUBLIC PROCEDURES/FUNCTIONS
--=============================================

--=============================================================================
-- PROCEDURE NAME: Allocate_Quantity
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_api_version                   Standard API parameter
--   p_init_msg_list                 Standard API parameter
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_replen_so_line_id             Replenishment Sales Order Line Identifier
--   p_primary_uom                   primary Unit Of Measure code of the
--                                   SHIKYU Component to be allocated
--   p_qty_to_allocate               Quantity to be allocated in primary UOM
-- OUT:
--   x_return_status                 Standard API parameter
--   x_msg_count                     Standard API parameter
--   x_msg_data                      Standard API parameter
--   x_qty_allocated                 Actual allocated quantity
--
-- DESCRIPTION   : Create allocations between the Subcontracting PO Shipment
--                 and Replenishment SO Line specified by the IN parameters
--                 for the specified quantity of the SHIKYU Component in
--                 its primary UOM.
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Allocate_Quantity
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
, p_primary_uom                IN VARCHAR2
, p_qty_to_allocate            IN NUMBER
, x_qty_allocated              OUT NOCOPY NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Allocate_Quantity';
l_api_version CONSTANT NUMBER := 1.0;

l_qty_to_allocate      NUMBER;
l_exists               VARCHAR2(1) := 'N';

l_primary_uom          JMF_SHIKYU_REPLENISHMENTS.primary_uom%TYPE;
l_replen_uom           JMF_SHIKYU_REPLENISHMENTS.uom%TYPE;
l_replen_allocated_primary_qty
  JMF_SHIKYU_REPLENISHMENTS.allocated_primary_uom_quantity%TYPE;
l_replen_allocable_primary_qty
  JMF_SHIKYU_REPLENISHMENTS.allocable_primary_uom_quantity%TYPE;
l_replen_allocated_qty JMF_SHIKYU_REPLENISHMENTS.allocated_quantity%TYPE;
l_replen_allocable_qty JMF_SHIKYU_REPLENISHMENTS.allocable_quantity%TYPE;
l_allocated_uom        JMF_SHIKYU_ALLOCATIONS.uom%TYPE;
l_allocation_qty       JMF_SHIKYU_ALLOCATIONS.allocated_quantity%TYPE;
l_replen_so_header_id  OE_ORDER_LINES_ALL.header_id%TYPE := NULL;
l_sub_comp             MTL_SYSTEM_ITEMS_B.segment1%TYPE;
l_order_number         PO_HEADERS_ALL.SEGMENT1%TYPE;
l_message         VARCHAR(2000);
l_status_flag     BOOLEAN;


l_oem_organization_id  JMF_SUBCONTRACT_ORDERS.oem_organization_id%TYPE;
l_tp_organization_id   JMF_SUBCONTRACT_ORDERS.tp_organization_id%TYPE;

g_replen_so_line_not_exist EXCEPTION;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  -- TO DO: Call reconcile_replen_so_line_split here!  (Do we need this?)

  -- Look for the Replenishment Sales Order Line in the
  -- JMF_SHIKYU_REPLENISHMENTS and get the related attributes
  -- by calling a private procedure.
  Get_Replen_So_Attributes
  ( p_replen_so_line_id         => p_replen_so_line_id
  , x_header_id                 => l_replen_so_header_id
  , x_allocable_primary_uom_qty => l_replen_allocable_primary_qty
  , x_allocated_primary_uom_qty => l_replen_allocated_primary_qty
  , x_uom                       => l_replen_uom
  , x_primary_uom               => l_allocated_uom
  , x_replen_so_line_exists     => l_exists
  );

  -- If the Sales Order Line does not exist in the JMF_REPLENISHMENTS table yet
  IF l_exists = 'N'
  THEN
    RAISE g_replen_so_line_not_exist;
  END IF;  /* IF l_exists = 'N' */

  l_qty_to_allocate := p_qty_to_allocate;
  l_primary_uom := p_primary_uom;

  -- If the Replenishment SO Line does not have enough quantity to satisfy
  -- the requirement specified by the IN parameter p_qty_to_allocate,
  -- set the quantity to be allocated to the maximum capacity that the
  -- Replenishment SO Line can accomodate (allocable_primary_uom_quantity)
  IF l_replen_allocable_primary_qty - l_replen_allocated_primary_qty < l_qty_to_allocate
  THEN
    l_qty_to_allocate := l_replen_allocable_primary_qty - l_replen_allocated_primary_qty;
  END IF; /* IF l_replen_allocable_primary_qty - l_replen_allocated_primary_qty < p_qty_to_allocate */

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name|| ': l_qty_to_allocate = ' || l_qty_to_allocate);
  END IF;

  -- Look for an allocation record between the Subcontracting Component
  -- and the Replenishment SO Line specified by the IN parameters,
  -- and get the already allocated quantity.
  Get_Allocation_Attributes
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_component_id => p_component_id
  , p_replen_so_line_id => p_replen_so_line_id
  , x_allocated_qty => l_allocation_qty
  , x_uom => l_allocated_uom
  , x_allocation_exists => l_exists
  );

  IF l_primary_uom IS NULL
  THEN

    IF l_allocated_uom IS NULL
    THEN

      -- Get the OEM Organization ID
      JMF_SHIKYU_UTIL.Get_Subcontract_Order_Org_Ids
      ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
      , x_oem_organization_id        => l_oem_organization_id
      , x_tp_organization_id         => l_tp_organization_id
      );

      l_primary_uom := JMF_SHIKYU_UTIL.Get_Primary_Uom_Code
                       ( p_inventory_item_id => p_component_id
                       , p_organization_id   => l_oem_organization_id
                       );
    ELSE
      l_primary_uom := l_allocated_uom;
    END IF; /* IF l_allocated_uom IS NULL */

  END IF; /* IF l_primary_uom IS NULL */

  -- If an allocation record does not already exist between the
  -- Subcontracting Order Shipment and the Replenishment Order Line
  IF l_exists = 'N'
  THEN
    INSERT INTO jmf_shikyu_allocations
    ( SUBCONTRACT_PO_SHIPMENT_ID
	, SHIKYU_COMPONENT_ID
	, REPLENISHMENT_SO_LINE_ID
	, ALLOCATED_QUANTITY
	, UOM
	, LAST_UPDATE_DATE
	, LAST_UPDATED_BY
	, CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_LOGIN
    )
    VALUES
    ( p_subcontract_po_shipment_id
    , p_component_id
    , p_replen_so_line_id
    , l_qty_to_allocate
    , l_primary_uom
    , sysdate
    , FND_GLOBAL.user_id
    , sysdate
    , FND_GLOBAL.user_id
    , FND_GLOBAL.login_id
    );

  -- If previous allocations have been created between the Subcontracting
  -- Order Shipment and the Replenishment Order Line
  ELSE
    l_allocation_qty := l_allocation_qty + l_qty_to_allocate;

    UPDATE jmf_shikyu_allocations
    SET    allocated_quantity = l_allocation_qty,
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  subcontract_po_shipment_id  = p_subcontract_po_shipment_id
    AND    replenishment_so_line_id = p_replen_so_line_id
    AND    shikyu_component_id = p_component_id;

  END IF; /* IF l_exists = 'N' */

  -- Pass the actual newly allocated quantity back to the caller as
  -- OUT parameter
  x_qty_allocated := l_qty_to_allocate;

  /*  Bug 7000413 - Start */
  /* Log the error in the Concurrent Request log  if allocation fails */
  IF x_qty_allocated = 0 THEN
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
      WHERE inventory_item_id = p_component_id
      AND organization_id = l_tp_organization_id ;

      fnd_message.set_name('JMF','JMF_SHK_ALLOCATION_ERROR');
      fnd_message.set_token('SUB_ORDER', l_order_number );
      fnd_message.set_token('SUB_COMP', l_sub_comp);
      l_message := fnd_message.GET();
      fnd_file.put_line(fnd_file.LOG,  l_message);
      l_status_flag := FND_CONCURRENT.set_completion_status('WARNING',NULL);
    EXCEPTION
    WHEN OTHERS THEN
      NULL; -- Return null if there is an error in fetching the message
    END;
  END IF;
  /*  Bug 7000413 - End */

  -- Add the quantity to be allocated to the total allocated
  -- quantity of the Replenishment Sales Order Line
  l_replen_allocated_primary_qty := l_replen_allocated_primary_qty + l_qty_to_allocate;

  -- Convert the allocated quantity of the Replenishment SO Line
  -- to the UOM of the SO Line, if it is not the Primary UOM, after
  -- the new allocation
  IF l_primary_uom <> l_replen_uom
  THEN

    l_replen_allocated_qty
      := INV_CONVERT.inv_um_convert
         ( item_id       => p_component_id
         , precision     => 5
         , from_quantity => l_replen_allocated_primary_qty
         , from_unit     => l_primary_uom
         , to_unit       => l_replen_uom
         , from_name     => null
         , to_name       => null
         );

  ELSE

    l_replen_allocated_qty := l_replen_allocated_primary_qty;

  END IF; /* IF l_primary_uom <> l_replen_uom */

  -- update allocated_quantity and allocated_primary_uom_quantity
  -- of the Replenishment SO Line after the new allocation
  UPDATE JMF_SHIKYU_REPLENISHMENTS
  SET    allocated_primary_uom_quantity = l_replen_allocated_primary_qty,
         allocated_quantity = l_replen_allocated_qty,
         last_update_date = sysdate,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.login_id
  WHERE  replenishment_so_line_id = p_replen_so_line_id;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_replen_allocated_primary_qty = ' || l_replen_allocated_primary_qty);
  END IF;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION
  WHEN g_replen_so_line_not_exist THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_replen_so_line_not_exist'
                    , 'Sales Order with ID ' || p_replen_so_line_id ||
                      ' not in JMF_SHIKYU_REPLENISHMENTS table');
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name  || '.others_exception'
                    , sqlerrm);
    END IF;

END Allocate_Quantity;

--=============================================================================
-- PROCEDURE NAME: Allocate_Quantity
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_api_version                   Standard API parameter
--   p_init_msg_list                 Standard API parameter
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_qty_to_allocate               Quantity to be allocated in primary UOM
--   p_available_replen_tbl          PL/SQL table containing the replenishment
--                                   SO Lines available for allocations to
--                                   the Subcontracting PO shipment specified
-- OUT:
--   x_return_status                 Standard API parameter
--   x_msg_count                     Standard API parameter
--   x_msg_data                      Standard API parameter
--   x_qty_allocated                 Actual allocated quantity
--
-- DESCRIPTION   : Create allocations between the Subcontracting PO Shipment
--                 and the list of available Replenishment SO Lines, specified
--                 by the IN parameters, for the specified quantity of the
--                 SHIKYU Component in its primary UOM.
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 26-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Allocate_Quantity
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty_to_allocate            IN  NUMBER
, p_available_replen_tbl       IN  g_replen_so_qty_tbl_type
, x_qty_allocated              OUT NOCOPY NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Allocate_Quantity';
l_api_version CONSTANT NUMBER := 1.0;

l_tbl_index            NUMBER;
l_qty_to_allocate      NUMBER;
l_remaining_qty        NUMBER;
l_qty_allocated        NUMBER;
-- Local variable to hold the individual records with references
-- to the Replenishment SO Lines with remaining quantity
l_available_replen_rec g_replen_so_qty_rec_type;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  l_tbl_index := p_available_replen_tbl.FIRST;
  l_remaining_qty := p_qty_to_allocate;

  -- Loop through the PL/SQL table containing references to the
  -- Replenishment SO Lines with remaining quantity
  IF p_available_replen_tbl.COUNT > 0
  THEN

    LOOP

      l_available_replen_rec := p_available_replen_tbl(l_tbl_index);

      -- Determine the quantity to be allocated from the Replenishment
      -- SO Line represented by the current g_replen_so_qty_rec_type record
      IF l_available_replen_rec.primary_uom_qty > l_remaining_qty
      THEN
        l_qty_to_allocate := l_remaining_qty;
      ELSE
        l_qty_to_allocate := l_available_replen_rec.primary_uom_qty;
      END IF; /* l_available_replen_rec.primary_uom_qty > l_remaining_qty */

      Allocate_Quantity
      ( p_api_version                => 1.0
      , p_init_msg_list              => p_init_msg_list
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
      , p_component_id               => p_component_id
      , p_replen_so_line_id          => l_available_replen_rec.replenishment_so_line_id
      , p_primary_uom                => l_available_replen_rec.primary_uom
      , p_qty_to_allocate            => l_qty_to_allocate
      , x_qty_allocated              => l_qty_allocated
      );

      l_remaining_qty := l_remaining_qty - l_qty_allocated;

      l_tbl_index := p_available_replen_tbl.next(l_tbl_index);
      EXIT WHEN l_tbl_index IS NULL OR l_remaining_qty <= 0;

    END LOOP;

  END IF; /* p_available_replen_tbl.COUNT > 0 */

  -- Pass the actual newly allocated quantity (requested qty - remaining qty
  -- that cannot be allocated) back to the caller as OUT parameter
  x_qty_allocated := p_qty_to_allocate - l_remaining_qty;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Allocate_Quantity;

--=============================================================================
-- PROCEDURE NAME: Get_Available_Replenishment_So
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_api_version                   Standard API parameter
--   p_init_msg_list                 Standard API parameter
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_qty                           Quantity of the specified subcontracting
--                                   component required
-- OUT:
--   x_return_status                 Standard API parameter
--   x_msg_count                     Standard API parameter
--   x_msg_data                      Standard API parameter
--   x_available_replen_tbl          PL/SQL table containing records of
--                                   g_replen_so_qty_rec_type that represents
--                                   the list of Replenishment Sales Order Lines
--                                   with unallocated quantity available to
--                                   fulfill the requirement specified by p_qty
--   x_remaining_qty                 the remaining quantity that cannot be matched
--                                   to any available Replenishment SO Lines
--                                   with remaining quantity.
--
-- DESCRIPTION   : Returns a PL/SQL table (as an OUT parameter) containing the
--                 containing records of g_replen_so_qty_rec_type that represent the
--                 list of Replenishment SO Lines that can fulfill the allocation
--                 requirement for the subcontracting component and the quantity
--                 specified by the IN parameters.  A Replenishment SO Line can
--                 fulfill the allocation requirement of a Subcontracting Component
--                 only if the price and also the project/task reference match.
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--                 04-AUG-05    VCHU    Added a where clause condition to
--                                      c_avail_replen_so_cur to only select
--                                      the replenishments with
--                                      allocable_quantity > 0.
--=============================================================================
PROCEDURE Get_Available_Replenishment_So
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, p_include_additional_supply  IN  VARCHAR2
, p_arrived_so_lines_only      IN  VARCHAR2
, x_available_replen_tbl       OUT NOCOPY g_replen_so_qty_tbl_type
, x_remaining_qty              OUT NOCOPY NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Get_Available_Replenishment_So';
l_api_version CONSTANT NUMBER := 1.0;

l_wip_job_start_date    WIP_DISCRETE_JOBS.scheduled_start_date%TYPE;
l_wip_job_complete_date WIP_DISCRETE_JOBS.scheduled_completion_date%TYPE;
l_ship_lead_time        MTL_INTERORG_SHIP_METHODS.intransit_time%TYPE;

l_remaining_qty         NUMBER;
l_tbl_index             NUMBER;
l_out_tbl_index         NUMBER;
-- Date to compare with the expected arrival date of a Replenishment
-- SO Line.  Either the Start Date or the Completion Date of the WIP
-- Job, or SYSDATE (if only already arrived SO Lines should be considered).
l_threshold_date        DATE;

l_avail_replen_so_tbl   g_replen_so_qty_tbl_type;
l_avail_replen_so_rec   g_replen_so_qty_rec_type;

g_no_wip_job_found_exc     EXCEPTION;
g_no_ship_method_found_exc EXCEPTION;

l_oem_organization_id mtl_interorg_ship_methods.from_organization_id%TYPE;
l_tp_organization_id mtl_interorg_ship_methods.to_organization_id%TYPE;
l_message         VARCHAR(2000);
l_status_flag     BOOLEAN;
l_tp_organization MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
l_oem_organization MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;




-- Cursor to get the available Replenishment SO Lines with remaining
-- quantity for the Subcontracting Component specified by the IN
-- parameters
CURSOR c_avail_replen_so_cur IS
  SELECT DISTINCT jsr.replenishment_so_line_id,
                  jsr.shikyu_component_id,
                  jsr.allocable_quantity - jsr.allocated_quantity,
                  jsr.uom,
                  jsr.allocable_primary_uom_quantity - jsr.allocated_primary_uom_quantity,
                  jsr.primary_uom,
                  oola.schedule_ship_date
  FROM   jmf_shikyu_replenishments jsr,
         jmf_subcontract_orders jso,
         oe_order_lines_all oola
  WHERE  jsr.oem_organization_id = jso.oem_organization_id
  AND    jsr.tp_organization_id = jso.tp_organization_id
  AND    jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    jsr.shikyu_component_id = p_component_id
  AND    jsr.replenishment_so_line_id = oola.line_id
  AND    ((TRUNC(oola.schedule_ship_date) + l_ship_lead_time <=
           NVL(l_threshold_date, TRUNC(oola.schedule_ship_date) + l_ship_lead_time))
          OR
          (p_arrived_so_lines_only = 'Y'
           AND
           NVL(oola.shipped_quantity, 0) > 0
           AND
           jsr.allocated_primary_uom_quantity <
           INV_CONVERT.inv_um_convert( jsr.shikyu_component_id
                                     , 5
                                     , oola.shipped_quantity
                                     , oola.order_quantity_uom
                                     , JMF_SHIKYU_UTIL.Get_Primary_Uom_Code
                                       ( jsr.shikyu_component_id
                                       , jsr.tp_organization_id)
                                     , null
                                     , null)))
  AND    jsr.allocable_primary_uom_quantity - jsr.allocated_primary_uom_quantity > 0
  AND    DECODE(p_include_additional_supply,
                'Y', NVL(jsr.additional_supply, 'N'),
                'N')
         = NVL(jsr.additional_supply, 'N')
  ORDER BY oola.schedule_ship_date,
           jsr.replenishment_so_line_id;

-- Cursor to get the WIP Scheduled Start Date and End Date
CURSOR c_wip_date_cur IS
  SELECT wdj.scheduled_start_date,
         wdj.scheduled_completion_date
  FROM   WIP_DISCRETE_JOBS wdj,
         JMF_SUBCONTRACT_ORDERS jso
  WHERE  wdj.wip_entity_id = jso.wip_entity_id
  AND    wdj.organization_id = jso.tp_organization_id
  AND    jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id;

-- Cursor to get the Shipping Lead Time from the
-- Shipping Network from the OEM Org to the TP Org
CURSOR c_ship_lead_time_cur IS
  SELECT NVL(mism.intransit_time, 0)
        , FROM_organization_id
        , to_organization_id
  FROM   MTL_INTERORG_SHIP_METHODS mism,
         JMF_SUBCONTRACT_ORDERS jso
  WHERE  mism.from_organization_id = jso.oem_organization_id
  AND    mism.to_organization_id = jso.tp_organization_id
  AND    mism.default_flag = 1
  AND    jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id;

BEGIN
  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  x_available_replen_tbl.delete;

  l_remaining_qty := p_qty;

  -- Derive l_threshold_date to prepare for opening the c_avail_replen_so_cur

  -- If all Replenishment SO Lines with remaining quantity should be picked up
  IF NVL(p_arrived_so_lines_only, 'N') = 'N'
  THEN

    -- Get the scheduled start date and completion date of the WIP job
    OPEN c_wip_date_cur;
    FETCH c_wip_date_cur
    INTO  l_wip_job_start_date, l_wip_job_complete_date;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_wip_job_start_date = '|| l_wip_job_start_date
                      || ', l_wip_job_complete_date = ' || l_wip_job_complete_date);
    END IF;

    IF c_wip_date_cur%NOTFOUND
    THEN

      CLOSE c_wip_date_cur;
      RAISE g_no_wip_job_found_exc;
    END IF; /* IF c_wip_date_cur%NOTFOUND */

    CLOSE c_wip_date_cur;

    -- If the WIP Job has not started yet
    IF l_wip_job_start_date > SYSDATE
    THEN
      l_threshold_date := l_wip_job_start_date;
    ELSIF l_wip_job_complete_date >= SYSDATE
    THEN
      l_threshold_date := l_wip_job_complete_date;
    ELSE
      l_threshold_date := null;
    END IF; /* IF l_wip_job_start_date > SYSDATE */

  -- If only the Replenishment SO Lines that have physically arrived at
  -- the TP Org should be picked up (which is the case when allocating
  -- for the case of an over receipt of an OSA item)
  ELSE

    l_threshold_date := SYSDATE;

  END IF; /* NVL(p_arrived_so_lines_only, 'N') = 'N' */

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_threshold_date = '|| l_threshold_date);
  END IF;

  -- Get the Shipping Lead Time to prepare for opening the
  -- c_avail_replen_so_cur
  OPEN c_ship_lead_time_cur;
  FETCH c_ship_lead_time_cur INTO l_ship_lead_time, l_oem_organization_id, l_tp_organization_id;

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_ship_lead_time = ' || l_ship_lead_time);
  END IF;

  IF c_ship_lead_time_cur%NOTFOUND
  THEN
    CLOSE c_ship_lead_time_cur;
      /*  Bug 7000413 - Start */
      /* Log the error in the Concurrent Request log   */
      BEGIN

      IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
      THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_PREFIX || l_api_name
                      , 'oem_organization_id '||l_oem_organization_id);

        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_PREFIX || l_api_name
                      , 'tp_organization_id '||l_tp_organization_id);
      END IF;

        SELECT organization_code INTO l_oem_organization
        FROM mtl_parameters mip
        WHERE exists
          (SELECT 1 FROM jmf_subcontract_orders jso
           WHERE subcontract_po_shipment_id = p_subcontract_po_shipment_id
           AND jso.oem_organization_id = mip.organization_id);


        SELECT organization_code INTO l_tp_organization
        FROM mtl_parameters mip
        WHERE exists
          (SELECT 1 FROM jmf_subcontract_orders jso
           WHERE subcontract_po_shipment_id = p_subcontract_po_shipment_id
           AND jso.tp_organization_id = mip.organization_id);

        fnd_message.set_name('JMF','JMF_SHK_NO_SHIP_METHOD');
        fnd_message.set_token('OEM', l_oem_organization);
        fnd_message.set_token('MP', l_tp_organization);
        l_message := fnd_message.GET();
        fnd_file.put_line(fnd_file.LOG,  l_message);
        l_status_flag := FND_CONCURRENT.set_completion_status('WARNING',NULL);
      EXCEPTION
      WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y' AND
        FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
        THEN

          FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , 'Error in set status of ship method '||SQLERRM);
        END IF;
        NULL; -- Return null if there is an error in fetching the message
      END;
      /*  Bug 7000413 - End */


    RAISE g_no_ship_method_found_exc;
  END IF; /* IF c_wip_date_cur%NOTFOUND */

  CLOSE c_ship_lead_time_cur;

  -- Get the Replenishment SO Lines with remaining quantity
  OPEN c_avail_replen_so_cur;
  FETCH c_avail_replen_so_cur
  BULK COLLECT INTO l_avail_replen_so_tbl;

  l_tbl_index := l_avail_replen_so_tbl.FIRST;
  l_out_tbl_index := 1;

  -- Loop through the table containing references to the Replenishment SO Lines
  -- with remaining quantity.
  -- If that the price and the project/task references of the SO Line match with
  -- those of the Subcontracting Component to be allocated to, add that to the
  -- PL/SQL table to be passed out (x_available_replen_tbl).
  -- The local variable l_remaining_qty is used to keep track of the remaining
  -- quantity that has not been matched to an available Replenishment SO Line yet.
  IF l_avail_replen_so_tbl.COUNT > 0
  THEN

    LOOP

      l_avail_replen_so_rec := l_avail_replen_so_tbl(l_tbl_index);

      IF (g_fnd_debug = 'Y' AND
        FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
      THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_PREFIX || l_api_name
                      , l_api_name || ': Loop iteration ' || l_out_tbl_index
                        || ': Replenishment SO Line ID = '
                        || l_avail_replen_so_rec.replenishment_so_line_id);
      END IF;

      IF (Validate_Project_Task_Ref
          ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
          , p_replen_so_line_id          => l_avail_replen_so_rec.replenishment_so_line_id
          )
          AND
          Validate_Price
          ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
          , p_component_id               => p_component_id
          , p_replen_so_line_id          => l_avail_replen_so_rec.replenishment_so_line_id
          )
         )
      THEN

        IF (g_fnd_debug = 'Y' AND
          FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
        THEN
          FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                        , G_MODULE_PREFIX || l_api_name
                        , l_api_name || ': Validation of Price and Project/Task passed');
        END IF;

        x_available_replen_tbl(l_out_tbl_index) := l_avail_replen_so_rec;
        l_out_tbl_index := l_out_tbl_index + 1;
        l_remaining_qty := l_remaining_qty - l_avail_replen_so_rec.primary_uom_qty;
      END IF; /* IF (Validate_Project_Task_Ref(...) AND Validate_Price(...) */

      l_tbl_index := l_avail_replen_so_tbl.next(l_tbl_index);
      EXIT WHEN l_tbl_index IS NULL OR l_remaining_qty <= 0;

    END LOOP;

  END IF; /* IF l_avail_replen_so_tbl.COUNT > 0 */

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_remaining_qty = '|| l_remaining_qty);
  END IF;

  IF l_remaining_qty < 0
  THEN
    l_remaining_qty := 0;
  END IF;

  x_remaining_qty := l_remaining_qty;

  CLOSE c_avail_replen_so_cur;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN g_no_wip_job_found_exc THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_no_wip_job_found_excc'
                    , 'No WIP Job found for Subcontracting Order Shipment with ID = '
                      || p_subcontract_po_shipment_id);
    END IF;

  WHEN g_no_ship_method_found_exc THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_no_ship_method_found_exc'
                    , 'Cannot get Shipping Lead Time from the Shipping Network from '
                      || 'the OEM Org to the TP Org');
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Get_Available_Replenishment_So;

--=============================================================================
-- PROCEDURE NAME: Get_Available_Replenishment_Po
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_api_version                   Standard API parameter
--   p_init_msg_list                 Standard API parameter
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_qty                           Quantity of the specified subcontracting
--                                   component required
-- OUT:
--   x_return_status                 Standard API parameter
--   x_msg_count                     Standard API parameter
--   x_msg_data                      Standard API parameter
--   x_available_replen_tbl          PL/SQL table containing records of
--                                   g_replen_po_qty_rec_type that represents
--                                   the list of Replenishment PO Shipments
--                                   with remaining quantity that does not
--                                   correspond to any Replenishment SO Line yet
--   x_remaining_qty                 the remaining quantity that cannot be matched
--                                   to any existing Replenishment PO Shipoments
--                                   with quantity that does not correspond to
--                                   a Replenishment SO Line.
--
-- DESCRIPTION   : Returns a PL/SQL table (as an OUT parameter) containing
--                 records of g_replen_po_qty_rec_type that represent the
--                 list of Replenishment PO Shipments that can fulfill
--                 the allocation requirement (by having corresponding
--                 Replenishment SO Lines created) for the subcontracting
--                 component and the quantity specified by the IN parameters.
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Get_Available_Replenishment_Po
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, x_available_replen_tbl       OUT NOCOPY g_replen_po_qty_tbl_type
, x_remaining_qty              OUT NOCOPY NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Get_Available_Replenishment_Po';
l_api_version CONSTANT NUMBER := 1.0;

l_primary_uom           MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE;
l_replen_po_primary_uom MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE;

l_oem_organization_id JMF_SUBCONTRACT_ORDERS.oem_organization_id%TYPE;
l_tp_organization_id  JMF_SUBCONTRACT_ORDERS.tp_organization_id%TYPE;

l_avail_replen_po_tbl g_replen_po_qty_tbl_type;
l_avail_replen_po_rec g_replen_po_qty_rec_type;

l_tbl_index             NUMBER;
l_out_tbl_index         NUMBER;
l_remaining_qty         NUMBER;
l_replen_po_ordered_qty NUMBER;
l_uom_rate              NUMBER;

-- Cursor to get the available Replenishment PO Shipments with
-- remaining quantity that does not correspond to any Replenishment
-- SO Line yet
CURSOR c_avail_replen_po_cur IS
  SELECT DISTINCT plla.line_location_id,
                  pla.item_id,
                  plla.quantity,
                  muomv.uom_code,
                  plla.quantity,
                  muomv.uom_code,
                  NVL(plla.need_by_date, plla.promised_date),
                  pha.segment1,
                  pla.line_num,
                  plla.shipment_num
  FROM  jmf_subcontract_orders jso,
        hr_organization_information hoi,
        po_line_locations_all plla,
        po_lines_all pla,
        po_headers_all pha,
        mtl_units_of_measure_vl muomv
  WHERE jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND   hoi.organization_id = jso.oem_organization_id
  AND   hoi.org_information_context = 'Customer/Supplier Association'
  AND   TO_NUMBER(hoi.org_information3) = pha.vendor_id
  AND   TO_NUMBER(hoi.org_information4) = pha.vendor_site_id
  AND   plla.ship_to_organization_id = jso.tp_organization_id
  AND   plla.po_line_id = pla.po_line_id
  AND   plla.po_header_id = pha.po_header_id
  AND   pla.item_id = p_component_id
  AND   pha.approved_flag = 'Y'
  AND   NVL(pha.cancel_flag, 'N') = 'N'
  AND   NVL(pla.cancel_flag, 'N') = 'N'
  AND   NVL(plla.cancel_flag, 'N') = 'N'
  AND   plla.unit_meas_lookup_code = muomv.unit_of_measure
  AND   NOT EXISTS (SELECT jsr.replenishment_so_line_id
                    FROM   jmf_shikyu_replenishments jsr
                    WHERE  jsr.replenishment_po_shipment_id = plla.line_location_id)
  ORDER BY NVL(plla.need_by_date, plla.promised_date),
           pha.segment1,
           pla.line_num,
           plla.shipment_num;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  -- Get the OEM Organization and TP Organization IDs
  JMF_SHIKYU_UTIL.Get_Subcontract_Order_Org_Ids
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , x_oem_organization_id        => l_oem_organization_id
  , x_tp_organization_id         => l_tp_organization_id
  );

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_oem_organization_id = ' || l_oem_organization_id
                      || ', l_tp_organization_id = ' || l_tp_organization_id);
  END IF;

  -- Get the primaru UOM code of the Subcontracting Component
  l_primary_uom := JMF_SHIKYU_UTIL.Get_Primary_Uom_Code
                   ( p_inventory_item_id => p_component_id
                   , p_organization_id   => l_oem_organization_id
                   );

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_primary_uom = ' || l_primary_uom);
  END IF;

  l_remaining_qty := p_qty;
  x_available_replen_tbl.DELETE;

  OPEN c_avail_replen_po_cur;
  FETCH c_avail_replen_po_cur
  BULK COLLECT INTO l_avail_replen_po_tbl;

  l_tbl_index := l_avail_replen_po_tbl.FIRST;
  l_out_tbl_index := 1;

  -- Loop through the PL/SQL table containing the records of g_replen_po_qty_rec_type
  -- representing the Replenishment PO Shipments with remaining quantity that does
  -- not correspond to any Replenishment SO Line yet
  IF l_avail_replen_po_tbl.COUNT > 0
  THEN

    LOOP

      l_uom_rate := NULL;
      l_avail_replen_po_rec := l_avail_replen_po_tbl(l_tbl_index);

      IF (g_fnd_debug = 'Y' AND
        FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
      THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_PREFIX || l_api_name
                      , l_api_name || ': Loop iteration: ' || l_tbl_index
                        || ', l_primary_uom = ' || l_primary_uom
                        || ', l_avail_replen_po_rec.uom = ' || l_avail_replen_po_rec.uom);
      END IF;

      -- If the Replenishment PO was not created in the primary UOM of the
      -- SHIKYU component, convert the avialblae qty to be in the primary UOM
      IF l_primary_uom <> l_avail_replen_po_rec.uom
      THEN

        l_avail_replen_po_rec.primary_uom := l_primary_uom;
        l_avail_replen_po_rec.primary_uom_qty
          := INV_CONVERT.inv_um_convert
          ( item_id       => p_component_id
          , precision     => 5
          , from_quantity => l_avail_replen_po_rec.qty
          , from_unit     => l_avail_replen_po_rec.uom
          , to_unit       => l_primary_uom
          , from_name     => null
          , to_name       => null
          );

      END IF; /* IF l_primary_uom <> l_avail_replen_po_rec.uom */

      IF (g_fnd_debug = 'Y' AND
        FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
      THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_PREFIX || l_api_name
                      , l_api_name || ': replenishment_po_shipment_id = '
                        || l_avail_replen_po_rec.replenishment_po_shipment_id
                        || ', qty = ' || l_avail_replen_po_rec.qty
                        || ', uom = ' || l_avail_replen_po_rec.uom);
      END IF;

      x_available_replen_tbl(l_out_tbl_index) := l_avail_replen_po_rec;
      l_out_tbl_index := l_out_tbl_index + 1;
      l_remaining_qty := l_remaining_qty - l_avail_replen_po_rec.primary_uom_qty;

      l_tbl_index := l_avail_replen_po_tbl.next(l_tbl_index);
      EXIT WHEN l_tbl_index IS NULL OR l_remaining_qty <= 0;

    END LOOP;

  END IF; /* IF l_avail_replen_po_tbl.COUNT > 0 */

  IF l_remaining_qty < 0
  THEN
    x_remaining_qty := 0;
  ELSE
    x_remaining_qty := l_remaining_qty;
  END IF; /* IF l_remaining_qty < 0 */

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': x_remaining_qty = ' || x_remaining_qty);
  END IF;

  CLOSE c_avail_replen_po_cur;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Get_Available_Replenishment_Po;

--=============================================================================
-- PROCEDURE NAME: Create_New_Replenishment_Po_So
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_uom
--   p_qty                           Quantity (in primary UOM) of the new
--                                   Replenishment PO Shipment and Sales Order
--                                   Line to be created
-- OUT:
--   x_new_replen_po_rec
--   x_new_replen_so_rec
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Create_New_Replenishment_Po_So
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, x_new_replen_so_rec          OUT NOCOPY g_replen_so_qty_rec_type
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Create_New_Replenishment_Po_So';
l_api_version CONSTANT NUMBER := 1.0;

l_component_uom             JMF_SHIKYU_COMPONENTS.uom%TYPE;
l_primary_uom               JMF_SHIKYU_COMPONENTS.primary_uom%TYPE;
l_component_price           JMF_SHIKYU_COMPONENTS.shikyu_component_price%TYPE;
l_primary_uom_price         JMF_SHIKYU_COMPONENTS.primary_uom_price%TYPE;
l_oem_organization_id       JMF_SUBCONTRACT_ORDERS.oem_organization_id%TYPE;
l_tp_organization_id        JMF_SUBCONTRACT_ORDERS.tp_organization_id%TYPE;
l_new_replen_so_line_id     OE_ORDER_LINES_ALL.line_id%TYPE;
l_new_replen_po_shipment_id PO_LINE_LOCATIONS_ALL.line_location_id%TYPE;
l_new_replen_qty            NUMBER;

g_process_replen_po_exc EXCEPTION;
g_process_replen_so_exc EXCEPTION;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  -- Create a new Replenishment PO with the passed in quantity
  JMF_SHIKYU_PO_PVT.Process_Replenishment_PO
  ( p_action                     => 'C'
  , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_qty
  , p_item_id                    => p_component_id
  , x_po_line_location_id        => l_new_replen_po_shipment_id
  , x_return_status              => x_return_status
  );

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': x_return_status from JMF_SHIKYU_PO_PVT.Process_Replenishment_PO = '
                    || x_return_status
                    || ', x_po_line_location_id = ' || l_new_replen_po_shipment_id);
  END IF;

  -- *** vchu: new code 8/18
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN

    RAISE g_process_replen_po_exc;

  END IF;
  -- *** vchu end: new code 8/18

  IF l_new_replen_po_shipment_id IS NOT NULL
  THEN
    -- To get component uom and primary uom of the SHIKYU Component
    JMF_SHIKYU_UTIL.Get_Shikyu_Component_Price
    ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_shikyu_component_id        => p_component_id
    , x_component_uom              => l_component_uom
    , x_component_price            => l_component_price
    , x_primary_uom                => l_primary_uom
    , x_primary_uom_price          => l_primary_uom_price
    );

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_component_uom = ' || l_component_uom
                      || ', l_component_price = ' || l_component_price
                      || ', l_primary_uom = ' || l_primary_uom
                      || ', l_primary_uom_price = ' || l_primary_uom_price);
    END IF;

    IF l_component_uom <> l_primary_uom
    THEN

      l_new_replen_qty := INV_CONVERT.inv_um_convert
                          ( item_id       => p_component_id
                          , precision     => 5
                          , from_quantity => p_qty
                          , from_unit     => l_primary_uom
                          , to_unit       => l_component_uom
                          , from_name     => null
                          , to_name       => null
                          );
    ELSE

      l_new_replen_qty := p_qty;

    END IF; /* IF l_component_uom <> l_primary_uom */

    -- Get OEM Organization and TP Organization IDs
    JMF_SHIKYU_UTIL.Get_Subcontract_Order_Org_Ids
    ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , x_oem_organization_id        => l_oem_organization_id
    , x_tp_organization_id         => l_tp_organization_id
    );

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_new_replen_qty = ' || l_new_replen_qty);
    END IF;

    -- Creating a new Replenishment SO Line
    JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO
    ( p_action                     => 'C'
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_quantity                   => l_new_replen_qty
    , p_item_id                    => p_component_id
    , p_replen_po_shipment_id      => l_new_replen_po_shipment_id
    , p_oem_organization_id        => l_oem_organization_id
    , p_tp_organization_id         => l_tp_organization_id
    , x_order_line_id              => l_new_replen_so_line_id
    , x_return_status              => x_return_status
    );

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': x_return_status from JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO = '
                      || x_return_status);
    END IF;

    -- *** vchu: new code 8/18
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN

      RAISE g_process_replen_so_exc;

    END IF;
    -- *** vchu end: new code 8/18

    -- Insert the new Replenishment SO Line into the
    -- JMF_SHIKYU_REPLENISHMENTS table
    Populate_Replenishment
    ( p_replen_so_line_id     => l_new_replen_so_line_id
    , p_replen_po_shipment_id => l_new_replen_po_shipment_id
    , p_component_id          => p_component_id
    , p_oem_organization_id   => l_oem_organization_id
    , p_tp_organization_id    => l_tp_organization_id
    , p_primary_uom           => l_primary_uom
    , p_primary_uom_qty       => p_qty
    , p_additional_supply     => 'N'
    );

    -- Set the OUT parameter x_new_replen_so_rec with the uom and quantity
    -- information for the newly created Replenishment SO Line
    x_new_replen_so_rec.replenishment_so_line_id := l_new_replen_so_line_id;
    x_new_replen_so_rec.qty := l_new_replen_qty;
    x_new_replen_so_rec.uom := l_component_uom;
    x_new_replen_so_rec.primary_uom_qty := p_qty;
    x_new_replen_so_rec.primary_uom := l_primary_uom;

  END IF;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION
  WHEN g_process_replen_po_exc THEN

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_process_replen_po_exc'
                    , 'Process_Replenishment_PO API returns a status of ' || x_return_status);
    END IF;

  WHEN g_process_replen_so_exc THEN

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_process_replen_so_exc'
                    , 'Process_Replenishment_SO API returns a status of ' || x_return_status);
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Create_New_Replenishment_Po_So;

-- Call in the case of pre-positioned components
--=============================================================================
-- PROCEDURE NAME: Create_New_Replenishment_So
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_uom
--   p_qty                           Quantity of the new Replenishment Sales
--                                   Order Line to be created
-- OUT:
--   x_new_replen_tbl
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Create_New_Replenishment_So
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, p_additional_supply          IN VARCHAR2
, x_new_replen_tbl             OUT NOCOPY g_replen_so_qty_tbl_type
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Create_New_Replenishment_So';
l_api_version CONSTANT NUMBER := 1.0;

l_component_uom          VARCHAR2(3);
l_primary_uom            VARCHAR2(3);
l_oem_organization_id    NUMBER;
l_tp_organization_id     NUMBER;
l_component_uom_qty      NUMBER;
l_remaining_qty          NUMBER;
l_actual_remaining_qty   NUMBER;
l_tbl_index              NUMBER;
l_replen_so_tbl_index    NUMBER;
l_new_replen_qty         NUMBER;
l_new_replen_primary_qty NUMBER;
l_new_order_line_id      NUMBER;
l_replen_po_qty          NUMBER;
l_replen_po_primary_qty  NUMBER;

l_avail_replen_po_tbl    g_replen_po_qty_tbl_type;
l_replen_po_rec          g_replen_po_qty_rec_type;

g_process_replen_so_exc  EXCEPTION;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  -- To clear the passed in table of type g_replen_so_qty_tbl_type
  -- for storing the newly created Replenishment SO Lines
  x_new_replen_tbl.delete;

  -- TO-DO: Call a UTIL procedure?  Or put in BEGIN/EXCEPTION/END block?
  SELECT jso.oem_organization_id,
         jso.tp_organization_id,
         jsc.uom,
         jsc.primary_uom
  INTO   l_oem_organization_id,
         l_tp_organization_id,
         l_component_uom,
         l_primary_uom
  FROM   jmf_subcontract_orders jso,
         jmf_shikyu_components  jsc
  WHERE  jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    jso.subcontract_po_shipment_id = jsc.subcontract_po_shipment_id
  AND    jsc.shikyu_component_id = p_component_id;

  -- Get the PL/SQL table containing records of g_replen_po_qty_rec_type
  -- that represents the list of Replenishment PO Shipments with remaining
  -- quantity that does not correspond to any Replenishment SO Line yet
  Get_Available_Replenishment_Po
  ( p_api_version                => 1.0
  , p_init_msg_list              => p_init_msg_list
  , x_return_status              => x_return_status
  , x_msg_count                  => x_msg_count
  , x_msg_data                   => x_msg_data
  , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_component_id               => p_component_id
  , p_qty                        => p_qty
  , x_available_replen_tbl       => l_avail_replen_po_tbl
  , x_remaining_qty              => l_remaining_qty
  );

  l_tbl_index := l_avail_replen_po_tbl.FIRST;
  l_actual_remaining_qty := p_qty;
  l_replen_so_tbl_index := 1;

  -- Loop through the list of available Replenishment PO Shipments
  -- and create corresponding Replenishment SO Lines
  IF l_avail_replen_po_tbl.COUNT > 0
  THEN

  LOOP

    l_replen_po_rec := l_avail_replen_po_tbl(l_tbl_index);

    l_replen_po_primary_qty := l_replen_po_rec.primary_uom_qty;
    l_replen_po_qty := l_replen_po_rec.qty;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': Loop Iteration: ' || l_tbl_index
                      || ': l_replen_po_rec.replenishment_po_shipment_id = '
                      || l_replen_po_rec.replenishment_po_shipment_id);
    END IF;

    IF(l_replen_po_rec.uom <> l_component_uom)
    THEN

      l_new_replen_qty := INV_CONVERT.inv_um_convert
                          ( item_id       => p_component_id
                          , precision     => 5
                          , from_quantity => l_replen_po_qty
                          , from_unit     => l_replen_po_rec.uom
                          , to_unit       => l_component_uom
                          , from_name     => null
                          , to_name       => null
                          );

      l_new_replen_qty := FLOOR(l_new_replen_qty);

      -- Convert the qty of the new Replenishment SO Line to be
      -- created back to primary UOM for calculation of the
      -- remaining quantity, for which there are no matching
      -- Replenishment PO to create a new Replenishment SO Line
      -- against
      IF(l_component_uom <> l_primary_uom)
      THEN

        l_new_replen_primary_qty := INV_CONVERT.inv_um_convert
                                    ( item_id       => p_component_id
                                    , precision     => 5
                                    , from_quantity => l_new_replen_qty
                                    , from_unit     => l_component_uom
                                    , to_unit       => l_primary_uom
                                    , from_name     => null
                                    , to_name       => null
                                    );

      ELSE

        l_new_replen_primary_qty := l_new_replen_qty;

      END IF; /* IF(l_component_uom <> l_primary_uom) */

    ELSE

      l_new_replen_qty := l_replen_po_rec.qty;
      l_new_replen_primary_qty := l_replen_po_rec.primary_uom_qty;

    END IF; /* IF(l_replen_po_rec.uom <> l_component_uom) */

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': Loop Iteration: ' || l_tbl_index
                      || ', l_component_uom = ' || l_component_uom
                      || ', l_primary_uom = ' || l_primary_uom
                      || ', l_replen_po_rec.uom = ' || l_replen_po_rec.uom
                      || ', l_new_replen_primary_qty = '||l_new_replen_primary_qty);
    END IF;

    -- Creating a new Replenishment SO Line
    JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO
    ( p_action                     => 'C'
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_quantity                   => l_new_replen_primary_qty
    , p_item_id                    => p_component_id
    , p_replen_po_shipment_id      => l_replen_po_rec.replenishment_po_shipment_id
    , p_oem_organization_id        => l_oem_organization_id
    , p_tp_organization_id         => l_tp_organization_id
    , x_order_line_id              => l_new_order_line_id
    , x_return_status              => x_return_status
    );

    -- *** vchu: new code 8/18
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN

      RAISE g_process_replen_so_exc;

    END IF;
    -- *** vchu end: new code 8/18

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': return status from JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO = '
                      || x_return_status);
    END IF;

    IF (g_fnd_debug = 'Y' AND
        FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_replen_po_rec.replenishment_po_shipment_id = '
                      || l_replen_po_rec.replenishment_po_shipment_id || ', l_new_order_line_id = '
                      || l_new_order_line_id);
    END IF;

    -- Insert the new Replenishment SO Line into the
    -- JMF_SHIKYU_REPLENISHMENTS table
    Populate_Replenishment
    ( p_replen_so_line_id     => l_new_order_line_id
    , p_replen_po_shipment_id => l_replen_po_rec.replenishment_po_shipment_id
    , p_component_id          => p_component_id
    , p_oem_organization_id   => l_oem_organization_id
    , p_tp_organization_id    => l_tp_organization_id
    , p_primary_uom           => l_primary_uom
    , p_primary_uom_qty       => l_new_replen_primary_qty
    , p_additional_supply     => p_additional_supply
    );

    -- Insert a record into the x_new_replen_tbl to store the SO Line ID and
    -- quantity of the newly created Replenishment SO Line
    x_new_replen_tbl(l_replen_so_tbl_index).replenishment_so_line_id := l_new_order_line_id;
    x_new_replen_tbl(l_replen_so_tbl_index).qty := l_new_replen_qty;
    x_new_replen_tbl(l_replen_so_tbl_index).uom := l_component_uom;
    x_new_replen_tbl(l_replen_so_tbl_index).primary_uom_qty := l_new_replen_primary_qty;
    x_new_replen_tbl(l_replen_so_tbl_index).primary_uom := l_primary_uom;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': x_new_replen_tbl(l_replen_so_tbl_index).qty = '
                      || x_new_replen_tbl(l_replen_so_tbl_index).qty);
    END IF;

    IF (g_fnd_debug = 'Y' AND
        FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': x_new_replen_tbl(l_replen_so_tbl_index).uom = '
                      || x_new_replen_tbl(l_replen_so_tbl_index).uom);
    END IF;

    l_replen_so_tbl_index := l_replen_so_tbl_index + 1;

    l_actual_remaining_qty := l_actual_remaining_qty - l_new_replen_primary_qty;

    l_tbl_index := l_avail_replen_po_tbl.next(l_tbl_index);
    EXIT WHEN l_tbl_index IS NULL OR l_actual_remaining_qty <= 0;

  END LOOP;

  END IF; /* IF l_avail_replen_po_tbl.COUNT > 0 */

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION
  WHEN g_process_replen_so_exc THEN

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_process_replen_so_exc'
                    , 'Process_Replenishment_SO API returns a status of ' || x_return_status);
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Create_New_Replenishment_So;

--=============================================================================
-- PROCEDURE NAME: Create_New_Allocations
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_api_version                   Standard API parameter
--   p_init_msg_list                 Standard API parameter
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_qty                           Quantity of allocations to be created
--   p_skip_po_replen_creation       Skip creation of new Replenishment PO for
--                                   sync-ship component (in cases where there
--                                   are not enough available Replenishments)
--                                   if the value is 'Y'
-- OUT:
--   x_return_status                 Standard API parameter
--   x_msg_count                     Standard API parameter
--   x_msg_data                      Standard API parameter
--
-- DESCRIPTION   : Create allocations for the Subcontracting Component and
--                 the quantity specified by the IN parmeters.  This procedure
--                 determines whether the SHIKYU component is Pre-positioned
--                 or Sync-ship, and then call the corresponding procedure to
--                 create the actual allocations
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Create_New_Allocations
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_qty                        IN NUMBER
, p_skip_po_replen_creation    IN VARCHAR2
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Create_New_Allocations';
  l_api_version CONSTANT NUMBER       := 1.0;

  l_subcontracting_component MTL_SYSTEM_ITEMS.subcontracting_component%TYPE;

  g_non_shikyu_component_exc EXCEPTION;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': in Sync-ship case');
  END IF;

  -- Get the type of the SHIKYU Component, since the allocation logic is
  -- different for Pre-positioned and Sync-ship components
  SELECT msib.subcontracting_component
  INTO   l_subcontracting_component
  FROM   MTL_SYSTEM_ITEMS_B msib,
         JMF_SUBCONTRACT_ORDERS jso
  WHERE  jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    msib.inventory_item_id = p_component_id
  AND    msib.organization_id = jso.tp_organization_id;

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': p_subcontract_po_shipment_id = '|| p_subcontract_po_shipment_id);

    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': p_component_id = '|| p_component_id
                    || ', p_qty = ' || p_qty );

  END IF;

  -- If the SHIKYU Component is Pre-Positioned
  IF l_subcontracting_component = 1
  THEN

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': in Pre-Positioned case');
    END IF;

    Allocate_Prepositioned_Comp
    ( p_api_version                => 1.0
    , p_init_msg_list              => p_init_msg_list
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    , p_qty                        => p_qty
    );

  -- If the SHIKYU Component is Sync-ship
  ELSIF l_subcontracting_component = 2
  THEN

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': in Sync-ship case');
    END IF;

    Allocate_Syncship_Comp
    ( p_api_version                => 1.0
    , p_init_msg_list              => p_init_msg_list
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    , p_qty                        => p_qty
    , p_skip_po_replen_creation    => p_skip_po_replen_creation
    );

  ELSE
    -- Raise an exception if the SHIKYU is not Pre-positioned or Sync-ship
    RAISE g_non_shikyu_component_exc;

  END IF; /* IF l_subcontracting_component = 1 */

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.no_data_found'
                    , 'Subcontracting Order Shipment ID' || p_subcontract_po_shipment_id ||
                      ' or Component ID ' || p_component_id || ' does not exist');
    END IF;

  WHEN g_non_shikyu_component_exc THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_non_shikyu_component_exc'
                    , 'The component to allocate is not Sync-ship or Pre-Positioned');
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Create_New_Allocations;

--=============================================================================
-- PROCEDURE NAME: Allocate_Prepositioned_Comp
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_uom
--   p_qty                           Quantity to be allocated
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Allocate_Prepositioned_Comp
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_qty                        IN NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Allocate_Prepositioned_Comp';
l_api_version CONSTANT NUMBER := 1.0;

l_available_replen_tbl g_replen_so_qty_tbl_type;
l_remaining_qty        NUMBER;
l_qty_allocated        NUMBER;
l_sub_comp             MTL_SYSTEM_ITEMS_B.segment1%TYPE;
l_order_number         PO_HEADERS_ALL.SEGMENT1%TYPE;
l_message         VARCHAR(2000);
l_status_flag     BOOLEAN;
l_tp_organization_id MTL_PARAMETERS.ORGANIZATION_ID%type;


BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  Get_Available_Replenishment_So
  ( p_api_version                => 1.0
  , p_init_msg_list              => p_init_msg_list
  , x_return_status              => x_return_status
  , x_msg_count                  => x_msg_count
  , x_msg_data                   => x_msg_data
  , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_component_id               => p_component_id
  , p_qty                        => p_qty
  , p_include_additional_supply  => 'Y'
  , p_arrived_so_lines_only      => 'N'
  , x_available_replen_tbl       => l_available_replen_tbl
  , x_remaining_qty              => l_remaining_qty
  );

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_remaining_qty = ' || l_remaining_qty);
  END IF;

  -- *** vchu: new code 8/18

  l_qty_allocated := 0;

  IF l_remaining_qty < p_qty
  THEN

    Allocate_Quantity
    ( p_api_version                => 1.0
    , p_init_msg_list              => p_init_msg_list
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    , p_qty_to_allocate            => p_qty - l_remaining_qty
    , p_available_replen_tbl       => l_available_replen_tbl
    , x_qty_allocated              => l_qty_allocated
    );

  END IF;
  -- *** vchu end: new code 8/18

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_qty_allocated = ' || l_qty_allocated);
  END IF;

  IF l_qty_allocated < p_qty
  THEN

    -- Call Create_New_Replenishment_So to find available Replenishment PO Shipments
    -- with remaining qty and create corresponding Replenishment SO Lines for that qty
    Create_New_Replenishment_So
    ( p_api_version                => 1.0
    , p_init_msg_list              => p_init_msg_list
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    --, p_primary_uom                => NULL
    , p_qty                        => l_remaining_qty
    , p_additional_supply          => 'N'
    , x_new_replen_tbl             => l_available_replen_tbl
    );

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': return status from Create_New_Replenishment_So = '
                      || x_return_status);
    END IF;

    -- *** vchu: new code 8/18
    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      -- Allocate the remaining qty required to the Replenishment SO Lines newly
      -- created according to the existing Replenishment PO Shipments with remaining
      -- quantity
      Allocate_Quantity
      ( p_api_version                => 1.0
      , p_init_msg_list              => p_init_msg_list
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
      , p_component_id               => p_component_id
      , p_qty_to_allocate            => l_remaining_qty
      , p_available_replen_tbl       => l_available_replen_tbl
      , x_qty_allocated              => l_qty_allocated
      );
    END IF;
    -- *** vchu: new code 8/18

  END IF;

  /*  Bug 7000413 - Start */
  /* Log the error in the Concurrent Request log  if allocation fails */
  IF l_qty_allocated = 0 THEN
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
      FROM mtl_system_items_b msi
      WHERE inventory_item_id = p_component_id
      AND exists
      (SELECT 1
       FROM jmf_subcontract_orders jso
       WHERE subcontract_po_shipment_id =  p_subcontract_po_shipment_id
       AND jso.tp_organization_id = msi.organization_id );


      fnd_message.set_name('JMF','JMF_SHK_ALLOCATION_ERROR');
      fnd_message.set_token('SUB_ORDER', l_order_number );
      fnd_message.set_token('SUB_COMP', l_sub_comp);
      l_message := fnd_message.GET();
      fnd_file.put_line(fnd_file.LOG,  l_message);
      l_status_flag := FND_CONCURRENT.set_completion_status('WARNING',NULL);
    EXCEPTION
    WHEN OTHERS THEN
      NULL; -- Return null if there is an error in fetching the message
    END;
  END IF;
  /*  Bug 7000413 - End */




  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Allocate_Prepositioned_Comp;

--=============================================================================
-- PROCEDURE NAME: Allocate_Syncship_Comp
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_uom
--   p_qty                           Quantity to be allocated
--   p_skip_po_replen_creation       Skip creation of new Replenishment PO in
--                                   cases where there are not enough available
--                                   Replenishments, if the value is 'Y'
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Allocate_Syncship_Comp
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_qty                        IN NUMBER
, p_skip_po_replen_creation    IN VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Allocate_Syncship_Comp';
l_api_version CONSTANT NUMBER := 1.0;

l_remaining_qty        NUMBER;
l_qty_allocated        NUMBER;

l_available_replen_tbl g_replen_so_qty_tbl_type;
l_new_replen_so_rec    g_replen_so_qty_rec_type;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': p_subcontract_po_shipment_id = ' || p_subcontract_po_shipment_id
                    || ', p_component_id = ' || p_component_id
                    || ', p_qty = ' || p_qty
                    || ', p_skip_po_replen_creation = ' || p_skip_po_replen_creation);
  END IF;

  Get_Available_Replenishment_So
  ( p_api_version                => 1.0
  , p_init_msg_list              => p_init_msg_list
  , x_return_status              => x_return_status
  , x_msg_count                  => x_msg_count
  , x_msg_data                   => x_msg_data
  , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_component_id               => p_component_id
  , p_qty                        => p_qty
  , p_include_additional_supply  => 'N'
  , p_arrived_so_lines_only      => 'N'
  , x_available_replen_tbl       => l_available_replen_tbl
  , x_remaining_qty              => l_remaining_qty
  );

  l_qty_allocated := 0;

  IF l_remaining_qty < p_qty
  THEN

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_remaining_qty = ' || l_remaining_qty
                      || ', p_qty = ' || p_qty);
    END IF;

    Allocate_Quantity
    ( p_api_version                => 1.0
    , p_init_msg_list              => p_init_msg_list
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    -- *** vchu: new code 8/18
    , p_qty_to_allocate            => p_qty - l_remaining_qty
    -- *** vchu end: new code 8/18
    , p_available_replen_tbl       => l_available_replen_tbl
    , x_qty_allocated              => l_qty_allocated
    );

  END IF;

  IF (g_fnd_debug = 'Y'
     AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': p_skip_po_replen_creation = '
                    || p_skip_po_replen_creation);
  END IF;

  IF l_qty_allocated < p_qty
     AND p_skip_po_replen_creation <> 'Y'
  THEN

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_qty_allocated = ' || l_qty_allocated
                      || ', p_qty = ' || p_qty);
    END IF;

    Create_New_Replenishment_Po_So
    ( p_api_version                => 1.0
    , p_init_msg_list              => p_init_msg_list
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    , p_qty                        => l_remaining_qty
    , x_new_replen_so_rec          => l_new_replen_so_rec
    );

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': x_return_status = ' || x_return_status);
    END IF;

    -- *** vchu: new code 8/18
    IF x_return_status = FND_API.G_RET_STS_SUCCESS
       AND
       Validate_Price
       ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
       , p_component_id               => p_component_id
       , p_replen_so_line_id          => l_new_replen_so_rec.replenishment_so_line_id
       )
       AND
       Validate_Project_Task_Ref
       ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
       , p_replen_so_line_id          => l_new_replen_so_rec.replenishment_so_line_id
       )
    THEN

      Allocate_Quantity
      ( p_api_version                => 1.0
      , p_init_msg_list              => p_init_msg_list
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
      , p_component_id               => p_component_id
      , p_replen_so_line_id          => l_new_replen_so_rec.replenishment_so_line_id
      , p_primary_uom                => l_new_replen_so_rec.primary_uom
      , p_qty_to_allocate            => l_remaining_qty
      , x_qty_allocated              => l_qty_allocated
      );

    END IF;
    -- *** vchu end: new code 8/18

  END IF; /* IF l_qty_allocated < p_qty */

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Allocate_Syncship_Comp;

--=============================================================================
-- PROCEDURE NAME: Reduce_Allocations
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_api_version                   Standard API parameter
--   p_init_msg_list                 Standard API parameter
--   p_subcontract_po_shipment_id    Subcontract Order Shipment Identifier
--   p_component_id                  SHIKYU Component Identifier
--   p_replen_so_line_id             Replenishment Sales Order Line Identifier
--   p_qty_to_reduce                 Quantity to be deallocated
-- OUT:
--   x_return_status                 Standard API parameter
--   x_msg_count                     Standard API parameter
--   x_msg_data                      Standard API parameter
--   x_actual_reduced_qty            The actual quantity that was deallocated
--   x_reduced_allocations_tbl       PL/SQL Table containing information such
--                                   as the actual deallocated quantity from
--                                   the allocations being reduced.
--
-- DESCRIPTION   : Decrease allocations between the subcontracting component
--                 and the replenishment according to the p_qty_to_decrease.
--                 If p_replen_so_line_id is NULL, then decrease allocations
--                 in all replenishment lines in FIFO order of the scheduled
--                 ship date.
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
PROCEDURE Reduce_Allocations
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
, p_qty_to_reduce              IN NUMBER
, x_actual_reduced_qty         OUT NOCOPY NUMBER
, x_reduced_allocations_tbl    OUT NOCOPY g_allocation_qty_tbl_type
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Reduce_Allocations';
l_api_version CONSTANT NUMBER       := 1.0;

TYPE l_allocation_detail_rec_type IS RECORD
  ( subcontract_po_shipment_id NUMBER
  , replenishment_so_line_id   NUMBER
  , component_id               NUMBER
  , qty                        NUMBER
  , qty_uom                    VARCHAR2(3)
  , replen_so_line_ship_date   OE_ORDER_LINES_ALL.SCHEDULE_SHIP_DATE%TYPE
  , replen_so_number           OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE
  , replen_so_line_number      OE_ORDER_LINES_ALL.LINE_NUMBER%TYPE
  );

TYPE l_allocation_detail_tbl_type IS TABLE OF l_allocation_detail_rec_type INDEX BY BINARY_INTEGER;

l_allocations_tbl          l_allocation_detail_tbl_type;
l_reduced_allocations_rec  g_allocation_qty_rec_type;

l_existing_alloc_qty       NUMBER;
l_remain_qty_to_reduce     NUMBER;
l_allocations_tbl_index    NUMBER;
l_reduced_allocs_tbl_index NUMBER;
l_existing_alloc_uom       VARCHAR2(3);

g_no_alloc_found_exc       EXCEPTION;

-- Cursor to select the information regarding all allocations for
-- the Subcontracting Component specified by the IN parameters,
-- in FIFO order of the scheduled ship date, SO number and SO line
-- number
CURSOR c_subcontract_po_alloc_cur IS
  SELECT DISTINCT jsa.subcontract_po_shipment_id
       , oola.line_id
       , jsa.shikyu_component_id
       , jsa.allocated_quantity
       , jsa.uom
       , oola.schedule_ship_date
       , ooha.order_number
       , oola.line_number
  FROM   JMF_SHIKYU_ALLOCATIONS jsa,
         OE_ORDER_LINES_ALL     oola,
         OE_ORDER_HEADERS_ALL   ooha
  WHERE  jsa.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    jsa.shikyu_component_id = p_component_id
  AND    oola.line_id = jsa.replenishment_so_line_id
  AND    ooha.header_id = oola.header_id
  ORDER BY oola.schedule_ship_date DESC,
           ooha.order_number DESC,
           oola.line_number DESC;

-- Cursor to select the information regarding the allocations between
-- the Subcontracting Component and the Replenishment SO Line specified
-- by the IN parameters
CURSOR c_alloc_cur IS
  SELECT jsa.allocated_quantity, jsa.uom
  FROM   JMF_SHIKYU_ALLOCATIONS jsa
  WHERE  jsa.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    jsa.replenishment_so_line_id = p_replen_so_line_id;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  x_reduced_allocations_tbl.DELETE;

  IF p_replen_so_line_id IS NULL
  THEN

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': p_replen_so_line_id IS NULL');
    END IF;

    OPEN c_subcontract_po_alloc_cur;
    FETCH c_subcontract_po_alloc_cur
    BULK COLLECT INTO l_allocations_tbl;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': fetched c_subcontract_po_alloc_cur');
    END IF;

    IF l_allocations_tbl.count <= 0
    THEN
      RAISE g_no_alloc_found_exc;
    END IF; /* IF l_allocations_tbl.count <= 0 */

    l_allocations_tbl_index := l_allocations_tbl.FIRST;
    l_remain_qty_to_reduce := p_qty_to_reduce;
    l_reduced_allocs_tbl_index := 1;

    -- To reduce more than one Replenishment SO Line allocated to the
    -- Subcontracting Component specified, in FIFO order of the scheduled
    -- ship date
    -- i.e. reduce from multiple JMF_SHIKYU_ALLOCATIONS record
    IF l_allocations_tbl.COUNT > 0
    THEN
      -- Loop through the PL/SQL table containing records of g_allocation_qty_tbl_type
      -- representing the allocations for the specified Subcontracting Component,
      -- until the qty to be deallocated is reached or all allocations have been
      -- examined.
      LOOP

        IF (g_fnd_debug = 'Y' AND
          FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
        THEN
          FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                        , G_MODULE_PREFIX || l_api_name
                        , l_api_name || ': Loop Iteration: '
                          || l_allocations_tbl_index);
        END IF;

        Reduce_One_Allocation
        ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
        , p_component_id               => p_component_id
        , p_replen_so_line_id          => l_allocations_tbl(l_allocations_tbl_index).replenishment_so_line_id
        , p_remain_qty_to_reduce       => l_remain_qty_to_reduce
        , p_existing_alloc_qty         => l_allocations_tbl(l_allocations_tbl_index).qty
        , p_alloc_uom                  => l_allocations_tbl(l_allocations_tbl_index).qty_uom
        , x_reduced_allocations_rec    => l_reduced_allocations_rec
        );

        x_reduced_allocations_tbl(l_reduced_allocs_tbl_index) := l_reduced_allocations_rec;

        -- Increment the index for the OUT table to pass out information of the
        -- allocations being reduced
        l_reduced_allocs_tbl_index := l_reduced_allocs_tbl_index + 1;

        -- Update the remaining qty to be reduced
        l_remain_qty_to_reduce := l_remain_qty_to_reduce - l_reduced_allocations_rec.qty;

        IF (g_fnd_debug = 'Y' AND
          FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
        THEN
          FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                        , G_MODULE_PREFIX || l_api_name
                        , l_api_name || ': From Reduce_Allocations: l_remain_qty_to_reduce = '
                          || l_remain_qty_to_reduce);
        END IF;

        l_allocations_tbl_index := l_allocations_tbl.next(l_allocations_tbl_index);
        EXIT WHEN l_allocations_tbl_index IS NULL OR l_remain_qty_to_reduce <= 0;

      END LOOP;
    END IF; /* IF l_allocations_tbl.COUNT > 0 */
    x_actual_reduced_qty := p_qty_to_reduce - l_remain_qty_to_reduce;

    CLOSE c_subcontract_po_alloc_cur;

  -- To reduce from the Replenishment SO Line specified
  -- i.e. reduce from only one JMF_SHIKYU_ALLOCATIONS record
  ELSE

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': p_replen_so_line_id IS NOT NULL');
    END IF;

    OPEN c_alloc_cur;
    FETCH c_alloc_cur INTO l_existing_alloc_qty, l_existing_alloc_uom;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': fetched c_alloc_cur');
    END IF;

    IF c_alloc_cur%NOTFOUND
    THEN
      RAISE g_no_alloc_found_exc;
    END IF; /* IF c_alloc_cur%NOTFOUND */

    CLOSE c_alloc_cur;

    Reduce_One_Allocation
    ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
    , p_component_id               => p_component_id
    , p_replen_so_line_id          => p_replen_so_line_id
    , p_remain_qty_to_reduce       => p_qty_to_reduce
    , p_existing_alloc_qty         => l_existing_alloc_qty
    , p_alloc_uom                  => l_existing_alloc_uom
    , x_reduced_allocations_rec    => l_reduced_allocations_rec
    );

    x_reduced_allocations_tbl(1) := l_reduced_allocations_rec;

    x_actual_reduced_qty := l_reduced_allocations_rec.qty;

  END IF; /* IF p_replen_so_line_id IS NULL */

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': x_actual_reduced_qty = '|| x_actual_reduced_qty);
  END IF;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN g_no_alloc_found_exc THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name  || '.g_no_alloc_found_exc'
                    , 'Allocation(s) not found and cannot be reduced');
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Reduce_Allocations;

--=============================================================================
-- PROCEDURE NAME: Delete_Allocations
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id   Subcontract Order Shipment Identifier
--   p_component_id                 SHIKYU Component Identifier
--   p_replen_so_line_id            Replenishment Sales Order Line Identifier
-- OUT:
--   x_deleted_allocations_tbl      Table containing information of the deleted
--                                  allocations
-- DESCRIPTION   : Delete allocation for a Subcontracting Order Shipment.
--                 If p_component_id is null, all allocations created for the
--                 Subcontracting Order Shipment with
--                 p_subcontract_po_shipment_id would be deleted.  Otherwise,
--                 only allocations created for that particular component
--                 would be deleted.
--                 If both p_component_id and p_replen_so_line_id are not null,
--                 only the allocations between the Subcontracting Component
--                 and the Replenishment Sales Order Line would be deleted.
--                 The p_replen_so_line_id is simply ignored unless
--                 p_componenet_id is not null.
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================
-- Delete All Allocations
PROCEDURE Delete_Allocations
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
, x_deleted_allocations_tbl     OUT NOCOPY g_allocation_qty_tbl_type
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Allocations';
l_api_version CONSTANT NUMBER := 1.0;

l_tbl_index               NUMBER;
l_deleted_primary_uom_qty NUMBER;
l_replen_uom              VARCHAR2(3);

BEGIN

  -- *** TO-DO: Update allocated_quantity and its primary UOM counterparts
  --

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  IF p_subcontract_po_shipment_id IS NOT NULL
    THEN

    IF p_component_id IS NOT NULL
      THEN

      IF p_replen_so_line_id IS NULL
        THEN

        DELETE FROM jmf_shikyu_allocations
        WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
        AND    shikyu_component_id = p_component_id
        RETURNING subcontract_po_shipment_id,
                  replenishment_so_line_id,
                  shikyu_component_id,
                  allocated_quantity,
                  uom
        BULK COLLECT INTO x_deleted_allocations_tbl;

      ELSE

        DELETE FROM jmf_shikyu_allocations
        WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
        AND    shikyu_component_id = p_component_id
        AND    replenishment_so_line_id = p_replen_so_line_id
        RETURNING subcontract_po_shipment_id,
                  replenishment_so_line_id,
                  shikyu_component_id,
                  allocated_quantity,
                  uom
        BULK COLLECT INTO x_deleted_allocations_tbl;

      END IF; /* IF p_replen_so_line_id IS NULL */

    ELSE /* IF p_component_id IS NULL */

      DELETE FROM jmf_shikyu_allocations
      WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
      RETURNING subcontract_po_shipment_id,
                replenishment_so_line_id,
                shikyu_component_id,
                allocated_quantity,
                uom
      BULK COLLECT INTO x_deleted_allocations_tbl;

    END IF; /* IF p_component_id IS NOT NULL */

  ELSE

    IF p_replen_so_line_id IS NOT NULL
      THEN

      DELETE FROM jmf_shikyu_allocations
      WHERE  replenishment_so_line_id = p_replen_so_line_id
      RETURNING subcontract_po_shipment_id,
                replenishment_so_line_id,
                shikyu_component_id,
                allocated_quantity,
                uom
      BULK COLLECT INTO x_deleted_allocations_tbl;

    END IF; /* IF p_replen_so_line_id IS NOT NULL */

  END IF; /* IF p_subcontract_po_shipment_id IS NOT NULL */

  -- This would be NULL if the table is empty
  l_tbl_index := x_deleted_allocations_tbl.FIRST;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN

    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX
                  , '>> ' || G_MODULE_PREFIX || l_api_name
                    || ': x_deleted_allocations_tbl.FIRST = ' || NVL(TO_CHAR(l_tbl_index), 'NULL'));
  END IF;

  IF l_tbl_index IS NOT NULL
  THEN
    LOOP

      dbms_output.put_line('In Loop : IF x_deleted_allocations_tbl IS NOT NULL AND x_deleted_allocations_tbl.COUNT > 0');

      -- Get UOM of the Replenishment SO Line
      SELECT jsr.uom
      INTO   l_replen_uom
      FROM   JMF_SHIKYU_REPLENISHMENTS jsr
      WHERE  jsr.replenishment_so_line_id = x_deleted_allocations_tbl(l_tbl_index).replenishment_so_line_id;

      IF l_replen_uom <> x_deleted_allocations_tbl(l_tbl_index).qty_uom
      THEN

        l_deleted_primary_uom_qty := INV_CONVERT.inv_um_convert
                                     ( item_id       => x_deleted_allocations_tbl(l_tbl_index).component_id
                                     , precision     => 5
                                     , from_quantity => x_deleted_allocations_tbl(l_tbl_index).qty
                                     , from_unit     => x_deleted_allocations_tbl(l_tbl_index).qty_uom
                                     , to_unit       => l_replen_uom
                                     , from_name     => null
                                     , to_name       => null
                                     );
      ELSE

        l_deleted_primary_uom_qty := x_deleted_allocations_tbl(l_tbl_index).qty;

      END IF;

      UPDATE jmf_shikyu_replenishments
      SET    allocated_quantity = allocated_quantity - l_deleted_primary_uom_qty,
             allocated_primary_uom_quantity
             = allocated_primary_uom_quantity - x_deleted_allocations_tbl(l_tbl_index).qty,
             last_update_date = sysdate,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
      WHERE  replenishment_so_line_id = x_deleted_allocations_tbl(l_tbl_index).replenishment_so_line_id;

      l_tbl_index := x_deleted_allocations_tbl.next(l_tbl_index);
      EXIT WHEN l_tbl_index IS NULL;

    END LOOP;
  END IF; /* IF l_tbl_index IS NOT NULL */

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Delete_Allocations;

--=============================================================================
-- PROCEDURE NAME: Reconcile_Closed_Shipments
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--
-- OUT:
--
-- DESCRIPTION   :
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 31-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Reconcile_Closed_Shipments
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Reconcile_Closed_Shipments';
l_api_version CONSTANT NUMBER := 1.0;

-- Cursor to pick up the newly closed and over-shipped Replenishment
-- SO Lines
CURSOR c_over_ship_so_lines_cur IS
  SELECT jsr.replenishment_so_line_id,
         jsr.shikyu_component_id,
         oola.shipped_quantity,
         jsr.uom,
         oola.ordered_quantity,
         jsr.primary_uom,
         oola.schedule_ship_date
  FROM   jmf_shikyu_replenishments jsr,
         oe_order_lines_all oola
  WHERE  jsr.replenishment_so_line_id = oola.line_id
  AND    jsr.status <> 'CLOSED'
  AND    jsr.status <> 'CANCELLED'
  AND    oola.open_flag = 'N'
  AND    oola.shipped_quantity <> oola.ordered_quantity
  AND    oola.shipped_quantity <> jsr.allocable_quantity;

l_closed_so_line_tbl  g_replen_so_qty_tbl_type;
l_closed_so_line_rec  g_replen_so_qty_rec_type;
l_tbl_index           NUMBER;
l_ordered_qty         OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_ordered_primary_qty NUMBER;

BEGIN

  -- API Initialization
  Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );

  OPEN c_over_ship_so_lines_cur;
  FETCH c_over_ship_so_lines_cur
  BULK COLLECT INTO l_closed_so_line_tbl;

  l_tbl_index := l_closed_so_line_tbl.FIRST;

  IF l_closed_so_line_tbl.COUNT > 0
  THEN

    LOOP

      l_closed_so_line_rec := l_closed_so_line_tbl(l_tbl_index);

      -- Since the primary UOM equivalence of the shipped quantity is not stored
      -- anywhere and needs to be calculated, we use the primary_uom_qty field of
      -- the l_closed_so_line_rec to store the ordered_quantity instead.
      l_ordered_qty := l_closed_so_line_rec.primary_uom_qty;

      IF l_closed_so_line_rec.uom <> l_closed_so_line_rec.primary_uom
      THEN

        l_closed_so_line_rec.primary_uom_qty
          := INV_CONVERT.inv_um_convert
             ( item_id       => l_closed_so_line_rec.component_id
             , precision     => 5
             , from_quantity => l_closed_so_line_rec.qty
             , from_unit     => l_closed_so_line_rec.uom
             , to_unit       => l_closed_so_line_rec.primary_uom
             , from_name     => null
             , to_name       => null
             );

        l_ordered_primary_qty
          := INV_CONVERT.inv_um_convert
             ( item_id       => l_closed_so_line_rec.component_id
             , precision     => 5
             , from_quantity => l_ordered_qty
             , from_unit     => l_closed_so_line_rec.uom
             , to_unit       => l_closed_so_line_rec.primary_uom
             , from_name     => null
             , to_name       => null
             );

      END IF; /* IF l_closed_so_line_rec.uom <> l_closed_so_line_rec.primary_uom */

      -- Under shipment case: if the SO Line is closed, but the shipped_quantity
      -- is less than the ordered_quantity
      IF l_ordered_qty > l_closed_so_line_rec.qty
      THEN
        -- Deallocate based on LIFO order of Need By Date of the Subcontracting
        -- Orders already allocated to the current Replenishment SO Line
        Reconcile_Replen_Excess_Qty
        ( p_api_version          => 1.0
        , p_init_msg_list        => p_init_msg_list
        , x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , p_replen_order_line_id => l_closed_so_line_rec.replenishment_so_line_id
        , p_excess_qty           => l_closed_so_line_rec.primary_uom_qty - l_ordered_primary_qty
        );

      END IF; /* IF l_ordered_qty > l_closed_so_line_rec.qty */

      -- Updating the allocable quantity to the shipped quantity of the SO Line
      UPDATE JMF_SHIKYU_REPLENISHMENTS
      SET    allocable_quantity = l_closed_so_line_rec.qty,
             allocable_primary_uom_quantity = l_closed_so_line_rec.primary_uom_qty,
             status = 'CLOSED',
             last_update_date = sysdate,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
      WHERE  replenishment_so_line_id = l_closed_so_line_rec.replenishment_so_line_id;

      l_tbl_index := l_closed_so_line_tbl.next(l_tbl_index);
      EXIT WHEN l_tbl_index IS NULL;

    END LOOP;

  END IF; /* IF l_closed_so_line_tbl.COUNT > 0 */

  CLOSE c_over_ship_so_lines_cur;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Reconcile_Closed_Shipments;

--=============================================================================
-- PROCEDURE NAME: Reconcile_Replen_Excess_Qty
-- TYPE          : PUBLIC
-- PARAMETERS    :
-- IN:
--
-- OUT:
--
-- DESCRIPTION   :
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 31-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Reconcile_Replen_Excess_Qty
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_replen_order_line_id IN  NUMBER
, p_excess_qty           IN  NUMBER
)
IS

l_api_name       CONSTANT VARCHAR2(30) := 'Reconcile_Replen_Excess_Qty';
l_api_version    CONSTANT NUMBER       := 1.0;

TYPE l_allocation_detail_rec_type IS RECORD
  ( subcontract_po_shipment_id NUMBER
  , replenishment_so_line_id   NUMBER
  , component_id               NUMBER
  , qty                        NUMBER
  , qty_uom                    VARCHAR2(3)
  , po_shipment_need_by_date   PO_LINE_LOCATIONS_ALL.NEED_BY_DATE%TYPE
  , po_header_num              PO_HEADERS_ALL.SEGMENT1%TYPE
  , po_line_num                PO_LINES_ALL.LINE_NUM%TYPE
  , po_shipment_num            PO_LINE_LOCATIONS_ALL.SHIPMENT_NUM%TYPE
  );

TYPE l_allocation_detail_tbl_type IS TABLE OF l_allocation_detail_rec_type INDEX BY BINARY_INTEGER;

l_subcontract_po_shipment_id JMF_SUBCONTRACT_ORDERS.subcontract_po_shipment_id%TYPE;
l_primary_uom                JMF_SHIKYU_COMPONENTS.primary_uom%TYPE;
l_component_id               JMF_SHIKYU_COMPONENTS.shikyu_component_id%TYPE;
l_allocable_qty              JMF_SHIKYU_REPLENISHMENTS.allocable_quantity%TYPE;
l_allocable_primary_qty      JMF_SHIKYU_REPLENISHMENTS.allocable_primary_uom_quantity%TYPE;
l_allocated_primary_qty      JMF_SHIKYU_REPLENISHMENTS.allocated_primary_uom_quantity%TYPE;
l_unallocated_primary_qty    NUMBER;
l_shipped_primary_qty        NUMBER;
l_shipped_qty                OE_ORDER_LINES_ALL.shipped_quantity%TYPE;
l_ordered_uom                OE_ORDER_LINES_ALL.order_quantity_uom%TYPE;

l_tbl_index                  NUMBER;
l_qty_to_reduce              NUMBER;
l_actual_reduced_qty         NUMBER;
l_remaining_qty_to_reduce    NUMBER;

l_reduced_allocations_rec    g_allocation_qty_rec_type;
l_reduced_allocations_tbl    g_allocation_qty_tbl_type;
l_allocations_tbl            l_allocation_detail_tbl_type;
l_allocations_rec            l_allocation_detail_rec_type;

g_qty_not_fully_dealloc_exc  EXCEPTION;

CURSOR c_subcontract_po_allocations IS
  SELECT jsa.subcontract_po_shipment_id,
         jsa.replenishment_so_line_id,
         jsa.shikyu_component_id,
         jsa.allocated_quantity,
         jsa.uom,
         NVL(plla.need_by_date, plla.promised_date),
         pha.segment1,
         pla.line_num,
         plla.shipment_num
  FROM   JMF_SHIKYU_ALLOCATIONS jsa,
         PO_LINE_LOCATIONS_ALL plla,
         PO_LINES_ALL pla,
         PO_HEADERS_ALL pha
  WHERE  jsa.replenishment_so_line_id = p_replen_order_line_id
  AND    jsa.shikyu_component_id = l_component_id
  AND    jsa.subcontract_po_shipment_id = plla.line_location_id
  AND    plla.po_line_id = pla.po_line_id
  AND    plla.po_header_id = pha.po_header_id
  ORDER BY NVL(plla.need_by_date, plla.promised_date) DESC,
           pha.segment1 DESC,
           pla.line_num DESC,
           plla.shipment_num DESC;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE))
    THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
    THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- End API initialization

  Select jsr.shikyu_component_id,
         jsr.primary_uom,
         jsr.allocable_primary_uom_quantity,
         jsr.allocated_primary_uom_quantity,
         oola.shipped_quantity,
         oola.order_quantity_uom
  INTO   l_component_id,
         l_primary_uom,
         l_allocable_primary_qty,
         l_allocated_primary_qty,
         l_shipped_primary_qty,
         l_ordered_uom
  FROM   JMF_SHIKYU_REPLENISHMENTS jsr,
         OE_ORDER_LINES_ALL oola
  WHERE  jsr.REPLENISHMENT_SO_LINE_ID = p_replen_order_line_id
  AND    jsr.replenishment_so_line_id = oola.line_id;

  l_unallocated_primary_qty := l_allocable_primary_qty - l_allocated_primary_qty;

  -- If the excess quantity <= the remaining unallocated quantity of
  -- the Replenishment SO Line, and thus no existing allocations need
  -- to be deallocated.
  IF p_excess_qty = 0 OR p_excess_qty <= l_unallocated_primary_qty
    THEN
    RETURN;
  END IF;
/*
  -- Convert shipped_qty to primary uom if uom of SO Line <> primary uom
  IF l_primary_uom = l_ordered_uom
    THEN
    l_shipped_primary_qty := l_shipped_qty;
  ELSE
    l_shipped_primary_qty := INV_CONVERT.inv_um_convert
                             ( item_id             => l_component_id
                             , precision           => 5
                             , from_quantity       => l_shipped_qty
                             , from_unit           => l_ordered_uom
                             , to_unit             => l_primary_uom
                             , from_name           => null
                             , to_name             => null
                             );
  END IF;
*/

  -- Deallocate returned quantity
  IF p_excess_qty >= l_allocable_primary_qty
    THEN

    -- Remove all allocations of the Replenishment SO Line
    JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations
    ( P_API_VERSION                => 1.0
    , P_INIT_MSG_LIST              => p_init_msg_list
    , X_RETURN_STATUS              => x_return_status
    , X_MSG_COUNT                  => x_msg_count
    , X_MSG_DATA                   => x_msg_data
    , P_SUBCONTRACT_PO_SHIPMENT_ID => NULL
    , P_COMPONENT_ID               => NULL
    , P_REPLEN_SO_LINE_ID          => p_replen_order_line_id
    , X_DELETED_ALLOCATIONS_TBL    => l_reduced_allocations_tbl
    );

    -- Remove the Replenishment SO Line from the JMF_SHIKYU_REPLENISHMENTS table,
    -- since excess qty = allocable qty, and hence there are no available qty on
    -- this Replenishment SO Line anymore
    DELETE FROM jmf_shikyu_replenishments
    WHERE  replenishment_so_line_id = p_replen_order_line_id;

    -- Loop through the table containing the subcontracting orders
    -- being deallocated by the Delete_Allocations procedure,
    -- and then reallocate them by calling Create_New_Allocations
    IF l_reduced_allocations_tbl.COUNT > 0
      THEN

      l_tbl_index := l_reduced_allocations_tbl.FIRST;

      LOOP
        l_reduced_allocations_rec := l_reduced_allocations_tbl(l_tbl_index);

        Create_New_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => p_init_msg_list
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_subcontract_po_shipment_id => l_reduced_allocations_rec.subcontract_po_shipment_id
        , p_component_id               => l_reduced_allocations_rec.component_id
        , p_qty                        => l_reduced_allocations_rec.qty
        , p_skip_po_replen_creation     => 'N'
        );

        l_tbl_index := l_reduced_allocations_tbl.next(l_tbl_index);
        EXIT WHEN l_tbl_index IS NULL;

      END LOOP;

    END IF;

  ELSE --p_excess_qty < l_allocable_primary_qty

    -- Calculate the actual allocated quantity that needs to be reduced
    l_unallocated_primary_qty := l_allocable_primary_qty - l_allocated_primary_qty;
    l_remaining_qty_to_reduce := p_excess_qty - l_unallocated_primary_qty;

    -- Calculate the new allocable quantity by subtracting the excess quantity
    l_allocable_primary_qty := l_allocable_primary_qty - p_excess_qty;

    -- Convert the new allocable qty to primary uom if uom of SO Line <> primary uom
    IF l_primary_uom = l_ordered_uom
      THEN
      l_allocable_qty := l_allocable_primary_qty;
    ELSE
      l_allocable_qty := INV_CONVERT.inv_um_convert
                         ( item_id             => l_component_id
                         , precision           => 5
                         , from_quantity       => l_allocable_primary_qty
                         , from_unit           => l_primary_uom
                         , to_unit             => l_ordered_uom
                         , from_name           => null
                         , to_name             => null
                         );
    END IF;

    -- Update the allocable qty of the Replensiment SO Line being reconciled, so that
    -- it will not be reallocated again to the Subcontracting Order Shipments being
    -- deallocated from it in order to reconcile the excess qty
    UPDATE JMF_SHIKYU_REPLENISHMENTS
    SET    allocable_quantity = l_allocable_qty,
           allocable_primary_uom_quantity = l_allocable_primary_qty,
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  replenishment_so_line_id = p_replen_order_line_id;

    OPEN c_subcontract_po_allocations;

    FETCH c_subcontract_po_allocations
    BULK COLLECT INTO l_allocations_tbl;

    IF l_allocations_tbl.COUNT > 0
      THEN

      l_tbl_index := l_allocations_tbl.FIRST;

      LOOP

        l_allocations_rec := l_allocations_tbl(l_tbl_index);

        IF l_remaining_qty_to_reduce < l_allocations_rec.qty
          THEN
          l_qty_to_reduce := l_remaining_qty_to_reduce;
        ELSE
          l_qty_to_reduce := l_allocations_rec.qty;
        END IF;

        Reduce_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => p_init_msg_list
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_subcontract_po_shipment_id => l_allocations_rec.subcontract_po_shipment_id
        , p_component_id               => l_allocations_rec.component_id
        , p_replen_so_line_id          => p_replen_order_line_id
        , p_qty_to_reduce              => l_qty_to_reduce
        , x_actual_reduced_qty         => l_actual_reduced_qty
        , x_reduced_allocations_tbl    => l_reduced_allocations_tbl
        );

        IF l_reduced_allocations_tbl.COUNT > 0
          THEN
          Create_New_Allocations
          ( p_api_version                => 1.0
          , p_init_msg_list              => p_init_msg_list
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_subcontract_po_shipment_id => l_reduced_allocations_tbl(1).subcontract_po_shipment_id
          , p_component_id               => l_reduced_allocations_tbl(1).component_id
          , p_qty                        => l_reduced_allocations_tbl(1).qty
          , p_skip_po_replen_creation     => 'N'
          );
          l_remaining_qty_to_reduce := l_remaining_qty_to_reduce - l_qty_to_reduce;
        END IF;

        l_tbl_index := l_allocations_tbl.next(l_tbl_index);
        EXIT WHEN l_tbl_index IS NULL OR l_remaining_qty_to_reduce <= 0;

      END LOOP;

      IF l_remaining_qty_to_reduce > 0
        THEN
        RAISE g_qty_not_fully_dealloc_exc;
      ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

    END IF;
  END IF;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    */
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.NO_DATA_FOUND'
                    , 'No Data Found - Replenishment Sales Order Line: ' || p_replen_order_line_id);
    END IF;

  WHEN g_qty_not_fully_dealloc_exc THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.g_qty_not_fully_dealloc_exc'
                    , 'Excess Quantity of Replenishment Sales Order Line ' || p_replen_order_line_id
                      || ' cannot be fully deallocated');
    END IF;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Reconcile_Replen_Excess_Qty;

---------------------------------------------------------------------
-- PROCEDURE Reconcile_Partial_Shipments
-- Comments: THis api will reconcile the following scenarios
--           1) SO replenishments partially shipped / line split
--           2) SO replenishment lines canceled
-----------------------------------------------------------------------
PROCEDURE Reconcile_Partial_Shipments
( p_api_version       IN  NUMBER
, p_init_msg_list     IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, p_from_organization IN NUMBER
, p_to_organization   IN NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Reconcile_Partial_Shipments';
l_api_version CONSTANT NUMBER       := 1.0;

l_deleted_qty         NUMBER;
l_total_qty           NUMBER;
l_decreased_qty       NUMBER;
l_allocated_quantity  NUMBER;
l_parent_so_line_id   NUMBER;
l_return_status       VARCHAR2(3);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(300);
l_header_id           NUMBER;
l_primary_uom_qty NUMBER;
l_uom
  MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE;
l_primary_uom
  MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE;

l_reduced_allocations_tbl
  JMF_SHIKYU_ALLOCATION_PVT.g_allocation_qty_tbl_type;

l_deleted_allocations_tbl
  JMF_SHIKYU_ALLOCATION_PVT.g_allocation_qty_tbl_type;

CURSOR C_SHIKYU_REPLENISHMENT_CSR IS
SELECT jsr.replenishment_so_line_id      replenishment_so_line_id
     , jsr.replenishment_so_header_id    replenishment_so_header_id
     , jsr.schedule_ship_date            schedule_ship_date
     , jsr.replenishment_po_header_id    replenishment_po_header_id
     , jsr.replenishment_po_line_id      replenishment_po_line_id
     , jsr.replenishment_po_shipment_id  replenishment_po_shipment_id
     , jsr.oem_organization_id           oem_organization_id
     , jsr.tp_organization_id            tp_organization_id
     , oeh.cancelled_flag                oeh_cancelled_flag
     , oel.cancelled_flag                oel_cancelled_flag
     , oel.shipped_quantity              oel_shipped_quantity
     , oel.ordered_quantity              oel_ordered_quantity
     , jsr.shikyu_component_id           shikyu_component_id
     , jsr.ORDERED_QUANTITY              jsr_ordered_quantity
     , jsr.ALLOCATED_PRIMARY_UOM_QUANTITY  allocated_primary_UOM_quantity
   --, oel.closed_flag                   closed_flag
     , jsa.subcontract_po_shipment_id    subcontract_po_shipment_id
     , jsr.ALLOCABLE_PRIMARY_UOM_QUANTITY  allocable_primary_UOM_quantity
     , jsr.allocable_quantity            allocable_quantity
     , jsr.allocated_quantity            allocated_quantity
FROM JMF_SHIKYU_REPLENISHMENTS jsr
   , OE_ORDER_LINES_ALL        oel
   , OE_ORDER_HEADERS_ALL      oeh
   , JMF_SHIKYU_ALLOCATIONS    jsa
WHERE oeh.header_id                = jsr.REPLENISHMENT_SO_HEADER_ID
  AND oel.header_id                = oeh.header_id
  AND oel.line_id                  = jsr.replenishment_so_line_id
  AND jsa.shikyu_component_id      = jsr.shikyu_component_id
  AND jsa.replenishment_so_line_id = jsr.replenishment_so_line_id
  AND ( oeh.cancelled_flag  = 'Y'  OR
        oel.cancelled_flag = 'Y'   OR
        oel.ordered_quantity  < jsr.allocable_quantity );
        -- oel.ordered_quantity < jsr.ordered_quantity


/*Bug 7383574: Changed the cursor to have inline view to avoid FTS*/
CURSOR C_child_so_lines_CSR IS
  SELECT line_id
       , ordered_quantity
       , schedule_ship_date
       , header_id
       , split_from_line_id
       , line_number  FROM (
			  SELECT line_id
			       , ordered_quantity
			       , schedule_ship_date
			       , header_id
			       , split_from_line_id
			       , line_number
			  FROM oe_order_lines_all
			  WHERE header_id = l_header_id  )
       CONNECT BY PRIOR line_id = split_from_line_id
       START WITH line_id       = l_parent_so_line_id;

--originally replaced by rajesh for the partial reconcile bug5166092
-- introduced again for 5437721

/*
CURSOR C_child_so_lines_CSR IS
  SELECT line_id
       , ordered_quantity
       , schedule_ship_date
       , header_id
       , split_from_line_id
  FROM oe_order_lines_all
 WHERE   header_id = l_header_id
 and   split_from_line_id = l_parent_so_line_id ;
*/
-- commented out for bug 5437721. The CONNECT BY should work


BEGIN

-- In this api the following logic is used ( overall logic )
-- From the JMF replenishments table, select the SO replenishment lines
-- which have been either
--           1) Split OR
--           2) Cancel|
--     If split :
--         1) Reduce the allocations ( if components already allocated)
--         2) update the JMF replenishments table for the parent SO line rec
--         3) Insert new records for the split child lines in the
--            replenishments table
--         4) If in step (1) qty allocations were reduced, re-allocate them
--           invoking the allocation api's

--    IF CANCEL:
--         1) Reduce the allocations ( if components already allocated)
--         2) remove the record from the replenishments table
--         3) If in step (1) qty allocations were reduced, re-allocate them
--           invoking the allocation api's

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API Initialization
  /*Initialize
  ( p_api_version       => l_api_version
  , p_input_api_version => p_api_version
  , p_api_name          => l_api_name
  , p_init_msg_list     => p_init_msg_list
  , x_return_status     => x_return_status
  );
  */

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || 'After Initialize'
                  , NULL);
  END IF;
  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || 'p_from_organization => '
                  , p_from_organization);
  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || ' p_to_organization => '
                  , p_to_organization );
  END IF;

  FOR C_SHIKYU_REPLENISHMENT_rec IN C_SHIKYU_REPLENISHMENT_CSR
  LOOP
  BEGIN
    l_deleted_qty         := 0 ;
    l_decreased_qty       := 0 ;
    l_allocated_quantity  := 0 ;
    l_parent_so_line_id   := NULL ;
    l_header_id           := NULL ;
    l_parent_so_line_id   :=
    C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID ;
    l_header_id  := C_SHIKYU_REPLENISHMENT_rec.replenishment_so_header_id ;

    IF g_fnd_debug = 'Y'
    THEN
       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
      , 'JMFVSKAB : CURSOR C_SHIKYU_REPLENISHMENT_rec l_parent_so_line_id => '
                  , l_parent_so_line_id );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB :  C_SHIKYU_REPLENISHMENT_rec l_header_id => '
                  , l_header_id);
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB : C_SHIKYU_REPLENISHMENT_rec.oel_cancelled_flag '
                  , C_SHIKYU_REPLENISHMENT_rec.oel_cancelled_flag );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB : C_SHIKYU_REPLENISHMENT_rec.oeh_cancelled_flag '
                  ,C_SHIKYU_REPLENISHMENT_rec.oeh_cancelled_flag );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.jsr_ordered_quantity '
                  , C_SHIKYU_REPLENISHMENT_rec.jsr_ordered_quantity);
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
         , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.replenishment_po_shipment_id '
          , C_SHIKYU_REPLENISHMENT_rec.replenishment_po_shipment_id );

       END IF;
       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
    , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.allocated_primary_UOM_quantity'
                  , C_SHIKYU_REPLENISHMENT_rec.allocated_primary_UOM_quantity);
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
      , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.allocable_primary_UOM_quantity '
                  , C_SHIKYU_REPLENISHMENT_rec.allocable_primary_UOM_quantity);
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
      , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.allocable_quantity '
                  , C_SHIKYU_REPLENISHMENT_rec.allocable_quantity );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
      , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.allocated_quantity '
                  , C_SHIKYU_REPLENISHMENT_rec.allocated_quantity );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.oel_ordered_quantity '
                  , C_SHIKYU_REPLENISHMENT_rec.oel_ordered_quantity );
       END IF;
       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
               , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.oel_shipped_quantity '
               , C_SHIKYU_REPLENISHMENT_rec.oel_shipped_quantity );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id '
                  , C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id);
       END IF;
    END IF;


    IF C_SHIKYU_REPLENISHMENT_rec.oel_cancelled_flag = 'Y' OR
       C_SHIKYU_REPLENISHMENT_rec.oeh_cancelled_flag = 'Y'
    THEN
      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Invoke JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations '
                  , C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id);
       END IF;

      JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations
      ( p_api_version                => 1.0
      , p_init_msg_list              => NULL
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_subcontract_po_shipment_id =>
          C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id
      , p_component_id               =>
          C_SHIKYU_REPLENISHMENT_rec.shikyu_component_id
      , p_replen_so_line_id          =>
          C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID
      , x_deleted_allocations_tbl    => l_deleted_allocations_tbl
      );

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :AFter l_deleted_allocations_tbl.count '
                  , l_deleted_allocations_tbl.COUNT );
       END IF;

      -- There should be only one record in the table because
      -- the deleteion is occuring for a specifc
      -- p_replen_so_line_id, p_component_id, p_subcontract_po_shipment_id

      IF l_deleted_allocations_tbl.COUNT > 0
      THEN
        l_deleted_qty  :=  l_deleted_allocations_tbl(1).qty ;
      ELSE
        l_deleted_qty := 0;
      END IF; /* IF l_deleted_allocations_tbl.COUNT > 0 */

      DELETE FROM JMF_SHIKYU_REPLENISHMENTS
      WHERE REPLENISHMENT_SO_LINE_ID =
            C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID
      AND   REPLENISHMENT_SO_HEADER_ID =
            C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_header_id  ;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :AFter DELETE FROM JMF_SHIKYU_REPLENISHMENTS '
                  , C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID );
       END IF;


      IF l_deleted_qty > 0
      THEN
       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :1Cal JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations '
                  , l_deleted_qty );
       END IF;

        Create_New_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => NULL
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_subcontract_po_shipment_id =>
            C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id
        , p_component_id               =>
            C_SHIKYU_REPLENISHMENT_rec.shikyu_component_id
        , p_qty                        => l_deleted_qty
        , p_skip_po_replen_creation     => 'N'
        );
      END IF; /* l_deleted_qty > 0 */

    ELSE  ---- partial case

     -- Calculate the primary UOM qty
     -- decrease allocations
     -- update the quantity in the JMF replenishments
     -- insert record into the JMF replenishment table for the new line
     -- create new allocations for the decreased quantity

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Before primary UOM calculation '
                  , l_decreased_qty );
       END IF;

      -- Get the UOM and primary UOM of the parent Replenishment SO Line.
      -- UOM Conversion needs to be for the new allocable quantity of the
      -- parent SO Line.  Also needs to be done for the ordered and allocable
      -- quantities of the child Replenishment SO Lines newly splitted from
      -- the parent SO Line.
      SELECT UOM,
             PRIMARY_UOM
      INTO   l_uom,
             l_primary_uom
      FROM JMF_SHIKYU_REPLENISHMENTS
      WHERE REPLENISHMENT_SO_LINE_ID  =
            C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID;

      -- Converting the new allocable quantity of the parent SO Line
      -- to the primary UOM
      IF l_uom <> l_primary_uom
        THEN

        l_primary_uom_qty
          := INV_CONVERT.inv_um_convert
          ( item_id       => C_SHIKYU_REPLENISHMENT_rec.shikyu_component_id
          , precision     => 5
          , from_quantity => C_SHIKYU_REPLENISHMENT_rec.oel_ordered_quantity
          , from_unit     => l_uom
          , to_unit       => l_primary_uom
          , from_name     => null
          , to_name       => null
          );

      ELSE

        l_primary_uom_qty := C_SHIKYU_REPLENISHMENT_rec.oel_ordered_quantity;

      END IF;

      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :after UOM : l_primary_uom_qty => '|| l_primary_uom_qty
                  , C_SHIKYU_REPLENISHMENT_rec.allocable_primary_UOM_quantity );
       END IF;

      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Call JMF_SHIKYU_ALLOCATION_PVT.Reduce_Allocations '
                  , C_SHIKYU_REPLENISHMENT_rec.allocable_primary_UOM_quantity -
                l_primary_uom_qty );
       END IF;

      JMF_SHIKYU_ALLOCATION_PVT.Reduce_Allocations
      ( p_api_version                 => 1.0
      , p_init_msg_list               => NULL
      , x_return_status               => l_return_status
      , x_msg_count                   => l_msg_count
      , x_msg_data                    => l_msg_data
      , p_subcontract_po_shipment_id  =>
          C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id
      , p_component_id               =>
          C_SHIKYU_REPLENISHMENT_rec.shikyu_component_id
      , p_replen_so_line_id          =>
          C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID
      , p_qty_to_reduce              =>
          C_SHIKYU_REPLENISHMENT_rec.allocable_primary_UOM_quantity -
                NVL(l_primary_uom_qty,0)
      , x_reduced_allocations_tbl    => l_reduced_allocations_tbl
      , x_actual_reduced_qty         => l_decreased_qty
      );

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :after JMF_SHIKYU_ALLOCATION_PVT.Reduce_Allocations '
                  , l_return_status );
       END IF;

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :l_decreased_qty => '
                  , l_decreased_qty);
       END IF;


      -- Get the UOM and primary UOM of the parent Replenishment SO Line.
      -- Need to update the allocable quantity columns of the parent
      -- Replenishment SO Line, since some of this quantity has been
      -- splitted into the child SO Lines.  This needs to be done in
      -- order to prevent over-allocation of the parent SO Line.
      UPDATE JMF_SHIKYU_REPLENISHMENTS
      SET    allocable_quantity =
               C_SHIKYU_REPLENISHMENT_rec.oel_ordered_quantity,
             allocable_primary_uom_quantity = l_primary_uom_qty
      WHERE  REPLENISHMENT_SO_LINE_ID =
             C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID;

      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :after UPDATE JMF_SHIKYU_REPLENISHMENTS '
                  , C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID );
       END IF;

      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Before CURSOR C_child_so_lines_CSR for parent line '
                  , l_parent_so_line_id );
       END IF;


      FOR C_child_so_lines_rec IN C_child_so_lines_CSR
      LOOP

       IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Looping C_child_so_lines_CSR line_id '
                  , C_child_so_lines_rec.line_id );
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Looping C_child_so_lines_CSR Header_id '
                  , C_child_so_lines_rec.header_id );
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Looping C_child_so_lines_CSR split_from_line_id '
                  , C_child_so_lines_rec.split_from_line_id );
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Looping C_child_so_lines_CSR line_number '
                  , C_child_so_lines_rec.line_number );
       END IF;
        -- Converting the ordered quantity of the child Replenishment
        -- SO Lines newly splitted from the parent SO Line
        IF l_uom <> l_primary_uom
          THEN

          l_primary_uom_qty
            := INV_CONVERT.inv_um_convert
            ( item_id       => C_SHIKYU_REPLENISHMENT_rec.shikyu_component_id
            , precision     => 5
            , from_quantity => C_child_so_lines_rec.ordered_quantity
            , from_unit     => l_uom
            , to_unit       => l_primary_uom
            , from_name     => null
            , to_name       => null
            );

        ELSE

          l_primary_uom_qty := C_child_so_lines_rec.ordered_quantity;

        END IF;

        IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Before insert after UOM '
                  , l_primary_uom_qty );
        END IF;

-- Insert ONLY if the C_child_so_lines_rec.line_id is not already
-- present in the table

        INSERT INTO JMF_SHIKYU_REPLENISHMENTS
        ( REPLENISHMENT_SO_LINE_ID
        , REPLENISHMENT_SO_HEADER_ID
        , SCHEDULE_SHIP_DATE
        , REPLENISHMENT_PO_HEADER_ID
        , REPLENISHMENT_PO_LINE_ID
        , REPLENISHMENT_PO_SHIPMENT_ID
        , OEM_ORGANIZATION_ID
        , TP_ORGANIZATION_ID
        , TP_SUPPLIER_ID
        , TP_SUPPLIER_SITE_ID
        , SHIKYU_COMPONENT_ID
        , ORDERED_QUANTITY
        , ALLOCATED_QUANTITY
        , ALLOCABLE_QUANTITY
        , ORDERED_PRIMARY_UOM_QUANTITY
        , ALLOCATED_PRIMARY_UOM_QUANTITY
        , ALLOCABLE_PRIMARY_UOM_QUANTITY
        , UOM
        , PRIMARY_UOM
        , ADDITIONAL_SUPPLY
        , ORG_ID
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , REQUEST_ID
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        )
        SELECT
          C_child_so_lines_rec.line_id
        , C_child_so_lines_rec.header_id
        , C_child_so_lines_rec.schedule_ship_date
        , REPLENISHMENT_PO_HEADER_ID
        , REPLENISHMENT_PO_LINE_ID
        , REPLENISHMENT_PO_SHIPMENT_ID
        , OEM_ORGANIZATION_ID
        , TP_ORGANIZATION_ID
        , TP_SUPPLIER_ID
        , TP_SUPPLIER_SITE_ID
        , SHIKYU_COMPONENT_ID
        , C_child_so_lines_rec.ordered_quantity  -- ordered qty
        , 0                                      -- allocated qty
        , C_child_so_lines_rec.ordered_quantity  -- allocable qty
        , l_primary_uom_qty                      -- ordered qty in primary UOM
        , 0                                      -- allocated qty in primary UOM
        , l_primary_uom_qty                      -- allocable qty in primary UOM
        , UOM
        , PRIMARY_UOM
        , ADDITIONAL_SUPPLY
        , ORG_ID
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , REQUEST_ID
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        FROM JMF_SHIKYU_REPLENISHMENTS  jsr
        WHERE REPLENISHMENT_SO_LINE_ID  =
              C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID
          AND NOT EXISTS (
              SELECT jsr1.REPLENISHMENT_SO_LINE_ID
              FROM JMF_SHIKYU_REPLENISHMENTS jsr1
              WHERE jsr1.REPLENISHMENT_SO_LINE_ID =
                      C_child_so_lines_rec.line_id );

        /*AND   REPLENISHMENT_SO_HEADER_ID =
              C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_header_ID;*/

      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :after INSERT child = '|| C_child_so_lines_rec.line_id
                  , C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID );
       END IF;

      END LOOP;  -- child so line loop

      IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Out of child SO cursor: main REPLENISHMENT_SO_LINE_ID '
                  , C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID );
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :Out of child SO cursor: main REPLENISHMENT_SO_header_ID '
                  , C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_header_ID );
       END IF;


      IF l_decreased_qty > 0
      THEN
        Create_New_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => NULL
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_subcontract_po_shipment_id =>
            C_SHIKYU_REPLENISHMENT_rec.subcontract_po_shipment_id
        , p_component_id               =>
            C_SHIKYU_REPLENISHMENT_rec.shikyu_component_id
        , p_qty                        => l_decreased_qty
        , p_skip_po_replen_creation     => 'N'
        );

        IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
         THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          , 'JMFVSKAB :2after JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations '
                  , l_decreased_qty );
        END IF;

      END IF; -- l_decreased_qty

    END IF; /* IF C_SHIKYU_REPLENISHMENT_rec.oel_cancelled_flag = 'Y' OR
                  C_SHIKYU_REPLENISHMENT_rec.oeh_cancelled_flag = 'Y' */
            -- cancel or partial
    COMMIT;

    IF  FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE
    THEN
          FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB: Partial_reconcile COMMIT inside loop SO line  '
                  , C_SHIKYU_REPLENISHMENT_rec.REPLENISHMENT_SO_LINE_ID);
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF  FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE
       THEN
          FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKAB: Partial_reconcile EXCEPTION inside loop '
                  , SQLERRM );
       END IF;

  END ;
  END LOOP; -- Main C_SHIKYU_REPLENISHMENT_rec loop

   x_return_status :=  'S' ;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || 'JMFVSKAB partial reconcile ' || '.end'
                  , l_api_name || ' Exit');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                      , G_MODULE_PREFIX || l_api_name || '.g_exc_error'
                      , l_api_name || ': FND_API.G_EXC_ERROR'
                      );

        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                      , G_MODULE_PREFIX || l_api_name || '.g_exc_error'
                      , l_api_name || ': SQLERRM : '|| SQLERRM
                      );
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                      , G_MODULE_PREFIX || l_api_name || '.g_exc_unexpected_error'
                      , l_api_name || ': FND_API.G_EXC_UNEXPECTED_ERROR'
                      );

        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                      , G_MODULE_PREFIX || l_api_name || '.g_exc_unexpected_error'
                      , l_api_name || ': SQLERRM : '|| SQLERRM
                      );
    END IF;

  WHEN OTHERS THEN

    ROLLBACK ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , sqlerrm);
    END IF;

END Reconcile_Partial_Shipments ;

/* Private Helper Functions/Procedures */

--=============================================================================
-- PROCEDURE NAME: Get_Replen_So_Attributes
-- TYPE          : PRIVATE
-- PARAMETERS    :
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Replen_So_Attributes
( p_replen_so_line_id         IN  NUMBER
, x_header_id                 OUT NOCOPY NUMBER
, x_allocable_primary_uom_qty OUT NOCOPY NUMBER
, x_allocated_primary_uom_qty OUT NOCOPY NUMBER
, x_uom                       OUT NOCOPY VARCHAR2
, x_primary_uom               OUT NOCOPY VARCHAR2
, x_replen_so_line_exists     OUT NOCOPY VARCHAR2
)
IS

BEGIN

  x_header_id                 := NULL;
  x_allocable_primary_uom_qty := NULL;
  x_allocated_primary_uom_qty := NULL;
  x_uom                       := NULL;
  x_replen_so_line_exists     := 'N';

  SELECT oola.header_id,
         jsr.allocable_primary_uom_quantity,
         jsr.allocated_primary_uom_quantity,
         jsr.uom,
         jsr.primary_uom,
         'Y'
  INTO   x_header_id,
         x_allocable_primary_uom_qty,
         x_allocated_primary_uom_qty,
         x_uom,
         x_primary_uom,
         x_replen_so_line_exists
  FROM   JMF_SHIKYU_REPLENISHMENTS jsr,
         OE_ORDER_LINES_ALL oola
  WHERE  jsr.replenishment_so_line_id = p_replen_so_line_id
  AND    jsr.replenishment_so_line_id = oola.line_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_replen_so_line_exists := 'N';

END Get_Replen_So_Attributes;

--=============================================================================
-- PROCEDURE NAME: Get_Allocation_Attributes
-- TYPE          : PRIVATE
-- PARAMETERS    :
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Allocation_Attributes
( p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_replen_so_line_id          IN  NUMBER
, x_allocated_qty              OUT NOCOPY NUMBER
, x_uom                        OUT NOCOPY VARCHAR2
, x_allocation_exists          OUT NOCOPY VARCHAR2
)
IS

BEGIN

  x_allocated_qty     := NULL;
  x_uom               := NULL;
  x_allocation_exists := 'N';

  SELECT jsa.allocated_quantity,
         jsa.uom,
         'Y'
  INTO   x_allocated_qty,
         x_uom,
         x_allocation_exists
  FROM   JMF_SHIKYU_ALLOCATIONS jsa
  WHERE  jsa.replenishment_so_line_id = p_replen_so_line_id
  AND    jsa.shikyu_component_id = p_component_id
  AND    jsa.subcontract_po_shipment_id  = p_subcontract_po_shipment_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_allocation_exists := 'N';

END Get_Allocation_Attributes;

--=============================================================================
-- PROCEDURE NAME : Populate_Replenishment
-- TYPE           : PRIVATE
-- PARAMETERS     :
-- IN:
--   p_component_id                 SHIKYU Component Identifier
--   p_replen_so_line_id            Replenishment Sales Order Line Identifier
-- DESCRIPTION    :
--
-- EXCEPTIONS     :
--
-- CHANGE HISTORY: 25-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Populate_Replenishment
( p_replen_so_line_id     IN NUMBER
, p_replen_po_shipment_id IN NUMBER
, p_component_id          IN NUMBER
, p_oem_organization_id   IN NUMBER
, p_tp_organization_id    IN NUMBER
, p_primary_uom           IN VARCHAR2
, p_primary_uom_qty       IN NUMBER
, p_additional_supply     IN VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Populate_Replenishment';

-- Information from Replenishment SO Line

l_replen_so_header_id OE_ORDER_LINES_ALL.header_id%TYPE;
l_schedule_ship_date  OE_ORDER_LINES_ALL.schedule_ship_date%TYPE;
l_ordered_uom         OE_ORDER_LINES_ALL.order_quantity_uom%TYPE;
l_ordered_qty         OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_org_id              OE_ORDER_LINES_ALL.org_id%TYPE;

-- Information from Replenishment PO Shipment

l_replen_po_header_id PO_LINE_LOCATIONS_ALL.po_header_id%TYPE;
l_replen_po_line_id   PO_LINE_LOCATIONS_ALL.po_line_id%TYPE;
--l_supplier_id         PO_HEADERS_ALL.vendor_id%TYPE;
--l_supplier_site_id    PO_HEADERS_ALL.vendor_site_id%TYPE;

l_tp_supplier_id      JMF_SHIKYU_REPLENISHMENTS.tp_supplier_id%TYPE;
l_tp_supplier_site_id JMF_SHIKYU_REPLENISHMENTS.tp_supplier_site_id%TYPE;

-- Information computed for JMF_SHIKYU_REPLENISHMENTS

l_primary_uom_qty     JMF_SHIKYU_REPLENISHMENTS.ordered_primary_uom_quantity%TYPE;
l_primary_uom         JMF_SHIKYU_REPLENISHMENTS.primary_uom%TYPE;

BEGIN

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.invoked'
                    , l_api_name|| ' Entry');
  END IF;

  -- Getting information from the Replenishment PO Shipment

  SELECT plla.po_header_id,
         plla.po_line_id
  INTO   l_replen_po_header_id,
         l_replen_po_line_id
  FROM   PO_LINE_LOCATIONS_ALL plla
  WHERE  plla.line_location_id = p_replen_po_shipment_id;

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_replen_po_header_id = '|| l_replen_po_header_id
                    || ', l_replen_po_line_id = '|| l_replen_po_line_id
                    || ', p_replen_po_shipment_id = ' || p_replen_po_shipment_id);
  END IF;

  -- Getting information from the Replenishment SO Line

  SELECT oola.header_id,
         oola.ordered_quantity,
         oola.order_quantity_uom,
         oola.schedule_ship_date,
         oola.org_id
  INTO   l_replen_so_header_id,
         l_ordered_qty,
         l_ordered_uom,
         l_schedule_ship_date,
         l_org_id
  FROM   OE_ORDER_LINES_ALL oola
  WHERE  oola.line_id = p_replen_so_line_id;

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_replen_so_header_id = '|| l_replen_so_header_id
                    || ', l_ordered_qty = '|| l_ordered_qty
                    || ', l_ordered_uom = ' || l_ordered_uom
                    || ', l_schedule_ship_date = ' || l_schedule_ship_date
                    || ', l_org_id = ' || l_org_id);
  END IF;

  -- To get the supplier id and supplier site id associated
  -- with the TP Organization
  SELECT TO_NUMBER(org_information3),
         TO_NUMBER(org_information4)
  INTO   l_tp_supplier_id,
         l_tp_supplier_site_id
  FROM   hr_organization_information
  WHERE  organization_id = p_tp_organization_id
  AND    org_information_context = 'Customer/Supplier Association';

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_tp_supplier_id = ' || l_tp_supplier_id
                    || ', l_tp_supplier_site_id = ' || l_tp_supplier_site_id
                  );
  END IF;

  IF p_primary_uom IS NULL
  THEN

    l_primary_uom := JMF_SHIKYU_UTIL.Get_Primary_Uom_Code
                     ( p_inventory_item_id => p_component_id
                     , p_organization_id   => p_oem_organization_id
                     );

  ELSE

    l_primary_uom := p_primary_uom;

  END IF; /* F p_primary_uom IS NULL */

  IF p_primary_uom_qty IS NULL
  THEN

    l_primary_uom_qty := INV_CONVERT.inv_um_convert
                         ( item_id       => p_component_id
                         , precision     => 5
                         , from_quantity => l_ordered_qty
                         , from_unit     => l_ordered_uom
                         , to_unit       => p_primary_uom
                         , from_name     => null
                         , to_name       => null
                         );

  ELSE

    l_primary_uom_qty := p_primary_uom_qty;

  END IF; /* IF p_primary_uom_qty IS NULL */

  /*  IF p_additional_supply NOT IN ('Y', 'N')
    THEN
    p_additional_supply = 'N';
  END IF; /* IF p_additional_supply NOT IN ('Y', 'N') */

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_primary_uom = ' || l_primary_uom
                    || ', l_primary_uom_qty = ' || l_primary_uom_qty
                  );
  END IF;

  INSERT INTO JMF_SHIKYU_REPLENISHMENTS
  ( replenishment_so_line_id
  , replenishment_so_header_id
  , schedule_ship_date
  , replenishment_po_header_id
  , replenishment_po_line_id
  , replenishment_po_shipment_id
  , oem_organization_id
  , tp_organization_id
  , tp_supplier_id
  , tp_supplier_site_id
  , shikyu_component_id
  , ordered_quantity
  , allocated_quantity
  , allocable_quantity
  , ordered_primary_uom_quantity
  , allocated_primary_uom_quantity
  , allocable_primary_uom_quantity
  , uom
  , primary_uom
  , org_id
  , additional_supply
  , status
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login
  )
  VALUES
  ( p_replen_so_line_id
  , l_replen_so_header_id
  , l_schedule_ship_date
  , l_replen_po_header_id
  , l_replen_po_line_id
  , p_replen_po_shipment_id
  , p_oem_organization_id
  , p_tp_organization_id
  , l_tp_supplier_id
  , l_tp_supplier_site_id
  , p_component_id
  , l_ordered_qty
  , 0
  , l_ordered_qty
  , l_primary_uom_qty
  , 0
  , l_primary_uom_qty
  , l_ordered_uom
  , l_primary_uom
  , l_org_id
  , p_additional_supply
  , NULL
  , SYSDATE
  , FND_GLOBAL.user_id
  , SYSDATE
  , FND_GLOBAL.user_id
  , FND_GLOBAL.login_id
  );

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

END Populate_Replenishment;

--=============================================================================
-- FUNCTION NAME : Validate_Price
-- TYPE          : PRIVATE
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id   Subcontract Order Shipment Identifier
--   p_component_id                 SHIKYU Component Identifier
--   p_replen_so_line_id            Replenishment Sales Order Line Identifier
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================

FUNCTION Validate_Price
( p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
)
RETURN BOOLEAN
IS

  l_api_name CONSTANT VARCHAR2(30) := 'Validate_Price';

  l_count   NUMBER      := 0;
  l_ret_val BOOLEAN     := FALSE;

  /* 12.1 Buy/Sell Subcontracting changes */
  l_oem_org_id number;
  l_mp_org_id number;
  l_subcontracting_type  varchar2(1);

BEGIN

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.invoked'
                    , l_api_name|| ' Entry');
  END IF;

  /* 12.1 Buy/Sell Subcontracting changes */
  /* Check if subcomponent price is the same as the shipment price
     ONLY for Chargeable Subcontracting; this validation is not
     required for a Buy/Sell subcontracting relationship */

  SELECT
    oem_organization_id, tp_organization_id
  INTO
    l_oem_org_id, l_mp_org_id
  FROM
    JMF_SUBCONTRACT_ORDERS
  WHERE subcontract_po_shipment_id = p_subcontract_po_shipment_id;

  l_subcontracting_type := JMF_SHIKYU_GRP.get_subcontracting_type(l_oem_org_id, l_mp_org_id);

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , ' subcontracting_type is '|| l_subcontracting_type );
  END IF;

  If NVL(l_subcontracting_type, 'B') = 'B'
  THEN
    return TRUE;
  ELSE
  BEGIN
    SELECT count(*)
    INTO   l_count
    FROM   jmf_shikyu_components jsc
    WHERE  jsc.shikyu_component_id = p_component_id
    AND    jsc.subcontract_po_shipment_id = p_subcontract_po_shipment_id
    AND    EXISTS (SELECT 'x'
                  FROM   oe_order_lines_all oola,
                          oe_order_headers_all ooha
                  WHERE  oola.line_id = p_replen_so_line_id
                  AND    oola.inventory_item_id = p_component_id
                  AND    oola.price_list_id = jsc.price_list_id
                  AND    oola.header_id = ooha.header_id
                  AND    ooha.transactional_curr_code = jsc.currency
                  AND    oola.unit_selling_price
                          = DECODE(oola.pricing_quantity_uom,
                                  jsc.uom        , jsc.shikyu_component_price,
                                  jsc.primary_uom, jsc.primary_uom_price,
                                  -1));

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_count = '|| l_count
                    );
    END IF;

    IF l_count >= 1
    THEN
      l_ret_val := TRUE;
    END IF; /* IF count >= 1*/

    RETURN l_ret_val;

  END;
  END IF;

END Validate_Price;

--=============================================================================
-- FUNCTION NAME : Validate_Project_Task_Ref
-- TYPE          : PRIVATE
--
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id   Subcontract Order Shipment Identifier
--   p_component_id                 SHIKYU Component Identifier
--   p_replen_so_line_id            Replenishment Sales Order Line Identifier
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================

FUNCTION Validate_Project_Task_Ref
( p_subcontract_po_shipment_id IN NUMBER
--, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
)
RETURN BOOLEAN
IS

  l_api_name CONSTANT VARCHAR2(30) := 'Validate_Project_Task_Ref';

  l_count   NUMBER  := 0;
  l_ret_val BOOLEAN := FALSE;

BEGIN

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.invoked'
                    , l_api_name|| ' Entry');
  END IF;

  -- project_control_level: Project = 1, Task = 2
  SELECT count(*)
  INTO   l_count
  FROM   mtl_parameters         mtlp,
         jmf_subcontract_orders jso
  WHERE  mtlp.organization_id = jso.tp_organization_id
  AND    jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    (  (mtlp.project_control_level = 1
             AND EXISTS (SELECT 'x'
                         FROM    oe_order_lines_all oola
                         WHERE   oola.line_id = p_replen_so_line_id
                         AND     jso.project_id IS NOT NULL
                         AND     jso.project_id = oola.project_id
                         AND     NVL(jso.task_id, -1) = NVL(oola.task_id, -1)))
         OR (mtlp.project_control_level = 2
             AND EXISTS (SELECT 'x'
                         FROM   oe_order_lines_all oola
                         WHERE  oola.line_id = p_replen_so_line_id
                         AND    jso.project_id IS NOT NULL
                         AND    jso.task_id IS NOT NULL
                         AND    jso.project_id = oola.project_id
                         AND    jso.task_id = oola.task_id))
         OR (jso.project_id IS NULL
             AND jso.task_id IS NULL
             AND EXISTS (SELECT 'x'
                         FROM   oe_order_lines_all oola
                         WHERE  oola.line_id = p_replen_so_line_id
                         AND    oola.project_id IS NULL
                         AND    oola.task_id IS NULL))
         );

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_count = '|| l_count
                  );
  END IF;

  IF l_count >= 1
  THEN
    l_ret_val := TRUE;
  END IF; /* IF count >= 1*/

  RETURN l_ret_val;

END Validate_Project_Task_Ref;

--=============================================================================
-- PROCEDURE NAME : Reduce_One_Allocation
-- TYPE          : PRIVATE
--
-- PARAMETERS    :
-- IN:
--   p_subcontract_po_shipment_id   Subcontract Order Shipment Identifier
--   p_component_id                 SHIKYU Component Identifier
--   p_replen_so_line_id            Replenishment Sales Order Line Identifier
--   p_remain_qty_to_reduce
--   p_existing_alloc_qty
--   p_alloc_uom
--   x_reduced_allocations_rec
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 19-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Reduce_One_Allocation
( p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
, p_replen_so_line_id          IN NUMBER
, p_remain_qty_to_reduce       IN NUMBER
, p_existing_alloc_qty         IN NUMBER
, p_alloc_uom                  IN VARCHAR2
, x_reduced_allocations_rec    OUT NOCOPY g_allocation_qty_rec_type
)
IS

  l_api_name CONSTANT VARCHAR2(30) := 'Reduce_One_Allocation';

  l_remain_qty_to_reduce   NUMBER;
  l_new_allocated_qty      NUMBER;
  l_reduce_replen_uom_qty  NUMBER;
  l_replen_uom             VARCHAR2(3);

BEGIN

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.invoked'
                    , l_api_name|| ' Entry');
  END IF;

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': p_subcontract_po_shipment_id = ' || p_subcontract_po_shipment_id
                    || 'p_component_id = ' || p_component_id
                    || 'p_replen_so_line_id = ' || p_replen_so_line_id
                  );
  END IF;

  l_remain_qty_to_reduce := p_remain_qty_to_reduce;

  IF l_remain_qty_to_reduce < p_existing_alloc_qty
  THEN

    l_new_allocated_qty := p_existing_alloc_qty - l_remain_qty_to_reduce;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_remain_qty_to_reduce (' || l_remain_qty_to_reduce
                      || ') < p_existing_alloc_qty (' || p_existing_alloc_qty
                      || '), l_new_allocated_qty = ' || l_new_allocated_qty
                    );
    END IF;

    UPDATE    JMF_SHIKYU_ALLOCATIONS
    SET       allocated_quantity = l_new_allocated_qty
    WHERE     subcontract_po_shipment_id = p_subcontract_po_shipment_id
    AND       replenishment_so_line_id = p_replen_so_line_id
    RETURNING subcontract_po_shipment_id,
              replenishment_so_line_id,
              shikyu_component_id,
              allocated_quantity,
              uom
    INTO      x_reduced_allocations_rec;

    -- Updating the qty field of the OUT bound record parameter
    -- x_reduced_allocations_rec to the actual quantity being reduced.
    -- The RETURNING statement would only give the previous value of
    -- the allocated_quantity column before the update operation.
    x_reduced_allocations_rec.qty := l_remain_qty_to_reduce;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': Updated JMF_SHIKYU_ALLOCATIONS table, '
                      || 'x_reduced_allocations_rec.qty = '
                      || x_reduced_allocations_rec.qty
                    );
    END IF;

  ELSE

    l_remain_qty_to_reduce := p_existing_alloc_qty;

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_remain_qty_to_reduce (' || l_remain_qty_to_reduce
                      || ') >= p_existing_alloc_qty (' || p_existing_alloc_qty || ')'
                    );
    END IF;

    DELETE FROM JMF_SHIKYU_ALLOCATIONS
    WHERE subcontract_po_shipment_id = p_subcontract_po_shipment_id
    AND   replenishment_so_line_id = p_replen_so_line_id
    RETURNING subcontract_po_shipment_id,
              replenishment_so_line_id,
              shikyu_component_id,
              allocated_quantity,
              uom
    INTO x_reduced_allocations_rec;
  END IF; /* IF l_remain_qty_to_reduce < p_existing_alloc_qty */

  -- Get UOM of the Replenishment SO Line
  SELECT uom
  INTO   l_replen_uom
  FROM   JMF_SHIKYU_REPLENISHMENTS
  WHERE  replenishment_so_line_id = p_replen_so_line_id;

  IF (g_fnd_debug = 'Y' AND
    FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name || ': l_replen_uom = ' || l_replen_uom
                  );
  END IF;

  IF l_replen_uom <> p_alloc_uom
  THEN

    IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name
                    , l_api_name || ': l_replen_uom (' || l_replen_uom
                      || ') <> p_alloc_uom (' || p_alloc_uom || ')'
                    );
    END IF;

    l_reduce_replen_uom_qty := INV_CONVERT.inv_um_convert
                                ( item_id       => p_component_id
                                , precision     => 5
                                , from_quantity => l_remain_qty_to_reduce
                                , from_unit     => p_alloc_uom
                                , to_unit       => l_replen_uom
                                , from_name     => null
                                , to_name       => null
                                );
  ELSE

    l_reduce_replen_uom_qty := l_remain_qty_to_reduce;

  END IF; /* IF l_replen_uom <> p_alloc_uom */

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name
                  , l_api_name|| ': l_replen_uom = ' || l_replen_uom
                    || ', l_reduce_replen_uom_qty = ' || l_reduce_replen_uom_qty
                    || ', p_alloc_uom = ' || p_alloc_uom
                    || ', l_remain_qty_to_reduce = ' || l_remain_qty_to_reduce);
  END IF;

  -- Update the allocated and allocable quantities (and their primary
  -- UOM counterparts) of the Replenishment SO Line that was deallocated
  -- from the Subcontracting Component specified by the IN parameters
  UPDATE    JMF_SHIKYU_REPLENISHMENTS
  SET       allocated_quantity = allocated_quantity - l_remain_qty_to_reduce,
            allocated_primary_uom_quantity = allocated_primary_uom_quantity - l_reduce_replen_uom_qty
  WHERE     replenishment_so_line_id = p_replen_so_line_id;

  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , l_api_name || ' Exit');
  END IF;

END Reduce_One_Allocation;

--=============================================================================
-- PROCEDURE NAME : Initialize
-- TYPE           : PRIVATE
--
-- PARAMETERS     :
-- IN:
--   p_api_version
--   p_input_api_version
--   p_api_name
--   p_init_msg_list
--   x_return_status
--
-- RETURN:
--
-- DESCRIPTION    :
--
-- EXCEPTIONS     :
--
-- CHANGE HISTORY: 16-JUN-05    VCHU    Created.
--=============================================================================

PROCEDURE Initialize
( p_api_version       IN  NUMBER
, p_input_api_version IN  NUMBER
, p_api_name          IN  VARCHAR2
, p_init_msg_list     IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
)
IS

BEGIN

  -- FND Logging at the start of the Procedure
  IF (g_fnd_debug = 'Y' AND
      FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
  THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || p_api_name || '.invoked'
                    , G_MODULE_PREFIX || p_api_name|| ' Entry');
  END IF;

  -- Start API initialization

  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( p_api_version
                                    , p_input_api_version
                                    , p_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- End API initialization

END Initialize;

END JMF_SHIKYU_ALLOCATION_PVT;

/

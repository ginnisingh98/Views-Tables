--------------------------------------------------------
--  DDL for Package Body AHL_OSP_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_COST_PVT" AS
/* $Header: AHLVOSCB.pls 120.5 2008/01/30 22:34:01 jaramana ship $ */

-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_OSP_COST_PVT';

G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_OSP_COST_PVT';

-----------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Get_OSP_Cost
--  Type              : Private
--  Function          : Private API to calculate the Outside Proessing cost of
--                      a CMRO Work order.
--  Pre-reqs    :
--  Parameters  :
--      p_workorder_id                  IN      NUMBER       Required
--      x_osp_cost                      OUT     NUMBER       Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_OSP_Cost
(
   x_return_status       OUT  NOCOPY    VARCHAR2,
   p_workorder_id          IN   NUMBER,
   x_osp_cost              OUT  NOCOPY   NUMBER) IS
--

--yazhou 24-Aug-2006 starts
--Bug fix#5496848

  CURSOR get_osp_line_dtls_csr IS
/** Changed by jaramana on January 11, 2008 for the Requisition ER 6034236
    SELECT osp_order_line_id, osp_order_id, service_item_id, service_item_description,
           service_item_uom_code, quantity, po_line_id, inventory_org_id
    FROM AHL_OSP_ORDER_LINES
    WHERE WORKORDER_ID = p_workorder_id
      AND STATUS_CODE IS NULL;  -- (Not PO_CANCELLED or PO_DELETED)
**/
    SELECT ospl.osp_order_line_id, ospl.osp_order_id, ospl.service_item_id, ospl.service_item_description,
           ospl.service_item_uom_code, ospl.quantity, ospl.po_line_id, ospl.inventory_org_id,
           ospl.po_req_line_id, locs.po_line_id req_loc_po_line_id
    FROM AHL_OSP_ORDER_LINES ospl, PO_REQUISITION_LINES_ALL reql, PO_LINE_LOCATIONS_ALL locs
    WHERE ospl.WORKORDER_ID = p_workorder_id
      AND ospl.STATUS_CODE IS NULL  -- (Not PO_CANCELLED or PO_DELETED)
      AND ospl.po_req_line_id = reql.requisition_line_id (+)
      AND reql.LINE_LOCATION_ID = locs.LINE_LOCATION_ID (+);
/** End change by jaramana on January 11, 2008 for the Requisition ER 6034236 **/

  CURSOR get_po_line_price_csr(p_po_line_id IN NUMBER) IS
  SELECT pol.unit_price*pol.quantity extended_price, po.currency_code
   from po_lines_all pol, po_headers_all po
   WHERE po_line_id = p_po_line_id
     AND pol.po_header_id = po.po_header_id;

/** Added by jaramana on January 11, 2008 for the Requisition ER 6034236 **/
  CURSOR get_req_line_price_csr(p_req_line_id IN NUMBER) IS
  SELECT reql.unit_price*reql.quantity extended_price, reql.currency_code
   from PO_REQUISITION_LINES_ALL reql
   WHERE requisition_line_id = p_req_line_id;

   CURSOR currency_code_csr(p_org_id IN NUMBER) IS
   select   currency_code
     from   cst_acct_info_v COD,
	    GL_SETS_OF_BOOKS GSOB
    where   COD.Organization_Id = p_org_id
      AND   LEDGER_ID = GSOB.SET_OF_BOOKS_ID
      AND   NVL(operating_unit, mo_global.get_current_org_id())= mo_global.get_current_org_id();

   l_po_currency_code  po_headers.currency_code%type := null;
   l_ou_currency_code  gl_sets_of_books.currency_code%type := null;

/* commented out since workorder org should be the same as osp line org

  CURSOR get_wo_org_id_csr IS
  --Modified by mpothuku to fix the Perf Bug #4919299 on 09-Mar-06
    SELECT vst.organization_id from
           ahl_workorders wo,
           ahl_visit_tasks_b vts,
           ahl_visits_b vst
     WHERE wo.visit_task_id = vts.visit_task_id
       AND vts.visit_id = vst.visit_id
       AND wo.WORKORDER_ID = p_workorder_id;
*/


  CURSOR get_osp_order_dtls_csr (p_osp_order_id IN NUMBER) IS
    SELECT status_code, po_header_id, order_type_code
    FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id;

  CURSOR get_item_dtls_csr(p_item_id IN NUMBER,
                           p_org_id  IN NUMBER) IS
    SELECT LIST_PRICE_PER_UNIT, PRIMARY_UOM_CODE
    FROM MTL_SYSTEM_ITEMS_KFV
    WHERE INVENTORY_ITEM_ID = p_item_id
      AND ORGANIZATION_ID = p_org_id;
--
   l_api_name               CONSTANT VARCHAR2(30) := 'Get_OSP_Cost';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_OSP_Cost';
   l_osp_line_rec           get_osp_line_dtls_csr%ROWTYPE;
   l_osp_order_rec          get_osp_order_dtls_csr%ROWTYPE;
--   l_inv_org_id             NUMBER;
   l_temp_uom_code          MTL_SYSTEM_ITEMS_KFV.PRIMARY_UOM_CODE%TYPE;
   l_unit_price             NUMBER;
   l_converted_qty          NUMBER;
--
BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Initialize the return value to zero
  x_osp_cost := 0;
  IF p_workorder_id IS NULL THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_workorder_id is null');
    END IF;
    -- AHL_PRD_NULL_WORKORDER_ID
    RETURN;
  ELSE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_workorder_id = ' || p_workorder_id);
    END IF;
  END IF;

/* commented out since workorder org should be the same as osp line org

  OPEN get_wo_org_id_csr;
  FETCH get_wo_org_id_csr INTO l_inv_org_id;
  IF(get_wo_org_id_csr%NOTFOUND) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Work order id is invalid.');
    END IF;
    CLOSE get_wo_org_id_csr;
    RETURN;
  ELSE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Got Inv Org Id as ' || l_inv_org_id || ' for Work order');
    END IF;
  CLOSE get_wo_org_id_csr;
  END IF;
*/

  OPEN get_osp_line_dtls_csr;
  FETCH get_osp_line_dtls_csr into l_osp_line_rec;
  IF(get_osp_line_dtls_csr%NOTFOUND) THEN
    -- No OSP Order has been created for this Work order
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'No Active OSP Order line found for this workorder.');
    END IF;
    CLOSE get_osp_line_dtls_csr;
    RETURN;
  END IF;
  CLOSE get_osp_line_dtls_csr;

/** Changed by jaramana on January 11, 2008 for the Requisition ER 6034236
  IF(l_osp_line_rec.po_line_id IS NOT NULL) THEN
    -- A PO Line has been created for this OSP Line: Get the Cost from the PO
    OPEN get_po_line_price_csr(l_osp_line_rec.po_line_id);
**/
  IF(l_osp_line_rec.po_line_id IS NOT NULL OR l_osp_line_rec.req_loc_po_line_id IS NOT NULL) THEN
    -- A PO Line has been created for this OSP Line: Get the Cost from the PO
    OPEN get_po_line_price_csr(NVL(l_osp_line_rec.po_line_id, l_osp_line_rec.req_loc_po_line_id));
/** End change by jaramana on January 11, 2008 for the Requisition ER 6034236 **/
    FETCH get_po_line_price_csr INTO x_osp_cost, l_po_currency_code;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Price retrieved from PO Line with Id ' || l_osp_line_rec.po_line_id ||
                                                            ' is: ' || x_osp_cost);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Currency Code retrieved from PO Line with Id ' || l_osp_line_rec.po_line_id ||
                                                            ' is: ' || l_po_currency_code);

    END IF;

    IF get_po_line_price_csr%NOTFOUND THEN

       x_osp_cost:=0;
       CLOSE get_po_line_price_csr;
       RETURN;

    END IF;

    CLOSE get_po_line_price_csr;

    --Since the PO currency can be different from that of the OU
    --Check if currency conversion is required

     -- Get the currency for current OU
     OPEN currency_code_csr(l_osp_line_rec.inventory_org_id);
     FETCH currency_code_csr into l_ou_currency_code;
     CLOSE currency_code_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Currency Code retrieved from OU is: ' || l_ou_currency_code);
    END IF;

     IF(l_ou_currency_code is NULL)THEN
         FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_NO_CURRENCY');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			        fnd_log.level_error,
			        L_DEBUG_KEY,'No curency is defined for the organization of the osp order line'
		        );
         END IF;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_po_currency_code <> l_ou_currency_code THEN

           x_osp_cost := gl_currency_api.convert_amount (
                  x_from_currency    =>l_po_currency_code,
                  x_to_currency      =>l_ou_currency_code,
                  x_conversion_date  =>SYSDATE,
                  x_conversion_type  =>'Corporate',
                  x_amount           => x_osp_cost );
      END IF;
--    RETURN;
--yazhou 24-Aug-2006 ends
/** Added by jaramana on January 11, 2008 for the Requisition ER 6034236 **/
  ELSIF (l_osp_line_rec.po_req_line_id IS NOT NULL) THEN
    -- A Requisition has been created: try to get the cost as price of the requisition
    OPEN get_req_line_price_csr(l_osp_line_rec.po_req_line_id);
    FETCH get_req_line_price_csr INTO x_osp_cost, l_po_currency_code;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'Price and Currency code retrieved from Requisition Line with Id ' || l_osp_line_rec.po_req_line_id ||
                     ' are: ' || x_osp_cost || ' and ' || l_po_currency_code);
    END IF;
    IF get_req_line_price_csr%NOTFOUND THEN
       x_osp_cost := 0;
       CLOSE get_req_line_price_csr;
       RETURN;
    END IF;

    CLOSE get_req_line_price_csr;

    --Check if currency conversion is required
    -- Get the currency for current OU
    OPEN currency_code_csr(l_osp_line_rec.inventory_org_id);
    FETCH currency_code_csr into l_ou_currency_code;
    CLOSE currency_code_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Currency Code retrieved from OU is: ' || l_ou_currency_code);
    END IF;

    IF(l_ou_currency_code is NULL)THEN
      FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_NO_CURRENCY');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, 'No curency is defined for the organization of the osp order line.');
      END IF;
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_po_currency_code <> l_ou_currency_code THEN
      x_osp_cost := gl_currency_api.convert_amount (
                  x_from_currency    => l_po_currency_code,
                  x_to_currency      => l_ou_currency_code,
                  x_conversion_date  => SYSDATE,
                  x_conversion_type  => 'Corporate',
                  x_amount           => x_osp_cost );
    END IF;
/** End addition by jaramana on January 11, 2008 for the Requisition ER 6034236 **/

  ELSE
    -- No PO has been created: Try to get the cost by other means
    OPEN get_osp_order_dtls_csr(p_osp_order_id => l_osp_line_rec.osp_order_id);
    FETCH get_osp_order_dtls_csr INTO l_osp_order_rec;
    CLOSE get_osp_order_dtls_csr;
    IF (l_osp_order_rec.order_type_code = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_LOAN OR
        l_osp_order_rec.order_type_code = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_BORROW) THEN
      -- Cannot calculate cost for Loan and Borrow Orders
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Cannot calculate cost of OSP Orders of type ' || l_osp_order_rec.order_type_code);
      END IF;
      RETURN;
    ELSIF (l_osp_line_rec.service_item_id IS NULL OR l_osp_line_rec.service_item_uom_code IS NULL OR l_osp_line_rec.quantity IS NULL) THEN
      -- Cannot calculate cost: Insufficient information
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Cannot calculate cost due to insufficient OSP Line information: ' ||
                                                             ' Service Item Id: ' || l_osp_line_rec.service_item_id ||
                                                             ', Service Item Quantity: ' || l_osp_line_rec.quantity ||
                                                             ', Service Item UOM: ' || l_osp_line_rec.service_item_uom_code);
      END IF;
      RETURN;
    ELSE
      -- Calculate the Cost
      -- Get the primary UOM and Unit Price of the Service Item
--yazhou 24-Aug-2006 starts
--Bug fix#5496848

      OPEN get_item_dtls_csr(p_item_id => l_osp_line_rec.service_item_id,
                             p_org_id  => l_osp_line_rec.inventory_org_id);

--yazhou 24-Aug-2006 ends

      FETCH get_item_dtls_csr INTO l_unit_price, l_temp_uom_code;
      CLOSE get_item_dtls_csr;
      IF (l_temp_uom_code IS NULL OR l_unit_price IS NULL) THEN
        -- If either is null, return zero
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Insufficient Service Item information: Primary UOM Code: ' || l_temp_uom_code ||
                                                               ', List Price per unit: ' || l_unit_price);
        END IF;
        RETURN;
      END IF;
      IF (l_temp_uom_code = l_osp_line_rec.service_item_uom_code) THEN
        --  Calculate Price as Price = Qty * Price per Unit
        x_osp_cost := l_osp_line_rec.quantity * l_unit_price;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'UOM Codes are same. Calculated price as Quantity (' || l_osp_line_rec.quantity ||
                                                               ') * List Price per Unit (' || l_unit_price || ') = ' || x_osp_cost);
        END IF;
      ELSE
        --  UOM Codes are different: Convert Quantity from OSP Line Service Item UOM to Primary UOM of the Service Item
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'UOM Codes are different. About to convert From Service Item UOM (' ||
                                                                l_osp_line_rec.service_item_uom_code || ') to Primary UOM (' ||
                                                                l_temp_uom_code || ') by calling inv_convert.inv_um_convert');
        END IF;
        l_converted_qty := inv_convert.inv_um_convert(item_id       => l_osp_line_rec.service_item_id,
                                                      precision     => 2, -- Hardcoded to 2
                                                      from_quantity => l_osp_line_rec.quantity,
                                                      from_unit     => l_osp_line_rec.service_item_uom_code,
                                                      to_unit       => l_temp_uom_code,
                                                      from_name     => null,
                                                      to_name       => null);

        IF (l_converted_qty <0) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_OSP_UOM_CONVERT_INV');
          FND_MESSAGE.Set_Token('UOM1', l_osp_line_rec.service_item_uom_code);
          FND_MESSAGE.Set_Token('UOM2', l_temp_uom_code);
          FND_MSG_PUB.ADD;
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

         --  Calculate Price as Price = Converted_Qty * Price per Unit
        x_osp_cost := l_converted_qty * l_unit_price;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Converted Quantity: ' || l_converted_qty ||
                                                               '. Calculated price as Converted Quantity (' || l_converted_qty ||
                                                               ') * List Price per Unit (' || l_unit_price || ') = ' || x_osp_cost);
        END IF;  -- Log Level
      END IF;  -- Same or different UOM Codes
    END IF;  -- Can calculate Cost
  END IF;  -- Has PO or not

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_osp_cost := 0;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_osp_cost := 0;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   x_osp_cost := 0;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_OSP_Cost;

END AHL_OSP_COST_PVT;

/

--------------------------------------------------------
--  DDL for Package Body AHL_OSP_RCV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_RCV_PVT" AS
/* $Header: AHLVORCB.pls 120.10 2008/04/02 14:51:32 sathapli noship $ */

-- Global variable containing package name for debugs messages
G_PKG_NAME              CONSTANT  VARCHAR2(30) := 'AHL_OSP_RCV_PVT';
G_TRANSACTION_TABLE     CONSTANT  VARCHAR2(30) := 'OE_ORDER_LINES_ALL';
G_CSI_T_SOURCE_LINE_REF CONSTANT  VARCHAR2(50) := 'AHL_OSP_ORDER_LINES';
-- Ship-only transaction type
G_OM_ORDER              CONSTANT  VARCHAR2(30) := 'OM_SHIPMENT';
-- Return transaction type
G_OM_RETURN             CONSTANT  VARCHAR2(30) := 'RMA_RECEIPT';

--Shipment Group API parameters
x_header_rec                    OE_ORDER_PUB.Header_Rec_Type;
x_header_val_rec                OE_ORDER_PUB.Header_Val_Rec_Type;
x_Header_Adj_tbl                OE_ORDER_PUB.Header_Adj_Tbl_Type;
x_Header_Adj_val_tbl            OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
x_Header_price_Att_tbl          OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
x_Header_Adj_Att_tbl            OE_ORDER_PUB.Header_Adj_Att_Tbl_Type ;
x_Header_Adj_Assoc_tbl          OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
x_Header_Scredit_tbl            OE_ORDER_PUB.Header_Scredit_Tbl_Type;
x_Header_Scredit_val_tbl        OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
x_line_tbl                      OE_ORDER_PUB.Line_Tbl_Type;
x_line_val_tbl                  OE_ORDER_PUB.Line_Val_Tbl_Type;
x_Line_Adj_tbl                  OE_ORDER_PUB.Line_Adj_Tbl_Type;
x_Line_Adj_val_tbl              OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
x_Line_price_Att_tbl            OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
x_Line_Adj_Att_tbl              OE_ORDER_PUB.Line_Adj_Att_Tbl_Type ;
x_Line_Adj_Assoc_tbl            OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
x_Line_Scredit_tbl              OE_ORDER_PUB.Line_Scredit_Tbl_Type;
x_Line_Scredit_val_tbl          OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
x_Lot_Serial_tbl                OE_ORDER_PUB.Lot_Serial_Tbl_Type;
x_Lot_Serial_val_tbl            OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
x_action_request_tbl            OE_ORDER_PUB.Request_Tbl_Type;

---------------------------------------------------------------------
-- Declare local/private APIs defined in the package later         --
---------------------------------------------------------------------

PROCEDURE Validate_Receiving_Params (
    p_rma_receipt_rec     IN               RMA_Receipt_Rec_Type
);

PROCEDURE Update_OSP_Line_Exch_Instance(
    p_osp_order_id   IN NUMBER,
    p_osp_line_id    IN NUMBER,
    p_exchange_instance_id   IN NUMBER);

PROCEDURE Update_OSP_Order_Lines(
    p_osp_order_id  IN NUMBER,
    p_osp_line_id   IN NUMBER,
    p_oe_ship_line_id       IN NUMBER,
    p_oe_return_line_id     IN NUMBER);

---------------------------------------------------------------------
-- Define the APIs for the package                                 --
---------------------------------------------------------------------

-- Start of Comments --
--  Function name    : Can_Receive_Against_OSP
--  Type             : Public
--  Functionality    : Function to determine if an OSP Order is 'ready for receipt'.
--                     It returns FND_API.G_TRUE if a receipt can be done. Otherwise, it returns FND_API.G_FALSE.
--  Pre-reqs         :
--
--  Parameters:
--
--   p_osp_order_id       IN    NUMBER      OSP Order Id
--
--  Version:
--
--   Initial Version      1.0
--
-- End of Comments --

FUNCTION Can_Receive_Against_OSP (
    p_osp_order_id        IN    NUMBER
)
RETURN VARCHAR2 IS

-- Cursor to get the shipment header id, i.e. oe_header_id, for the given OSP order id.
CURSOR get_oe_header_id (c_osp_order_id NUMBER) IS
SELECT oe_header_id
  FROM AHL_OSP_ORDERS_B
 WHERE osp_order_id = c_osp_order_id;

-- Cursor to check whether the shipment, i.e. oe_header_id is booked or not.
CURSOR chk_shipment_booked (c_oe_header_id NUMBER) IS
SELECT 'X'
  FROM OE_ORDER_HEADERS_ALL
 WHERE header_id   = c_oe_header_id
   AND booked_flag = 'Y';

-- Cursor to get all the RMA type lines for the given sales order.
CURSOR get_rma_lines (c_oe_header_id NUMBER) IS
SELECT OLA.line_id
  FROM OE_ORDER_LINES_ALL OLA, OE_LINE_TYPES_V OLT
 WHERE OLA.header_id           = c_oe_header_id
   AND OLT.line_type_id        = OLA.line_type_id
   AND OLT.order_category_code = 'RETURN';

--
l_api_name     CONSTANT VARCHAR2(30) := 'Can_Receive_Against_OSP';
l_debug_key    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_oe_header_id          AHL_OSP_ORDERS_B.oe_header_id%TYPE;
l_oe_line_id            OE_ORDER_LINES_ALL.line_id%TYPE;
l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.begin', 'API called with p_osp_order_id: '||p_osp_order_id);
    END IF;

    -- Check for the given OSP order id. If NULL, return FND_API.G_FALSE.
    IF (p_osp_order_id IS NULL) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'OSP order id is NULL. Returning False.');
        END IF;

        RETURN FND_API.G_FALSE;
    END IF;

    -- Get the shipment header id, i.e. oe_header_id, for the given OSP order id.
    OPEN get_oe_header_id(p_osp_order_id);
    FETCH get_oe_header_id INTO l_oe_header_id;
    CLOSE get_oe_header_id;

    -- Check for the oe_header_id. If NULL, it means no shipment has been created. Return FND_API.G_FALSE.
    IF (l_oe_header_id IS NULL) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'oe_header_id is NULL for the OSP order: '||p_osp_order_id||'. Returning False.');
        END IF;

        RETURN FND_API.G_FALSE;
    END IF;

    -- Check whether the shipment, i.e. oe_header_id is booked or not.
    OPEN chk_shipment_booked(l_oe_header_id);
    FETCH chk_shipment_booked INTO l_dummy;
    IF (chk_shipment_booked%NOTFOUND) THEN
        -- The shipment is not booked. Return FND_API.G_FALSE.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Shipment '||l_oe_header_id||' is not booked. Returning False.');
        END IF;

        CLOSE chk_shipment_booked;
        RETURN FND_API.G_FALSE;
    END IF;
    CLOSE chk_shipment_booked;

    -- For a booked shipment, get all the RMA type lines.
    OPEN get_rma_lines(l_oe_header_id);
    LOOP
        FETCH get_rma_lines INTO l_oe_line_id;
        EXIT WHEN get_rma_lines%NOTFOUND;

        -- Check whether the receipt can be done against the RMA line id or not.
        IF (Can_Receive_Against_RMA(l_oe_line_id) = FND_API.G_TRUE) THEN
            -- Receipt against RMA can be done for this line. Return FND_API.G_TRUE.
            CLOSE get_rma_lines;
            RETURN FND_API.G_TRUE;
        ELSIF (Can_Receive_Against_PO(l_oe_line_id) = FND_API.G_TRUE) THEN
            -- Receipt against PO can be done for this line. Return FND_API.G_TRUE.
            CLOSE get_rma_lines;
            RETURN FND_API.G_TRUE;
        END IF;
    END LOOP;
    CLOSE get_rma_lines;

    -- If none of the shipment/PO lines can be received, return FND_API.G_FALSE.
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                       'None of the shipment/PO lines can be received. Returnig False.');
    END IF;

    RETURN FND_API.G_FALSE;
END Can_Receive_Against_OSP;


-- Start of Comments --
--  Function name    : Can_Receive_Against_PO
--  Type             : Public
--  Functionality    : Function to determine if a receipt against PO can be done given an RMA line.
--                     It returns FND_API.G_TRUE if a receipt can be done. Otherwise, it returns FND_API.G_FALSE.
--  Pre-reqs         :
--
--  Parameters:
--
--   p_return_line_id     IN    NUMBER      RMA Line Id
--
--  Version:
--
--   Initial Version      1.0
--
-- End of Comments --

FUNCTION Can_Receive_Against_PO (
    p_return_line_id      IN    NUMBER
)
RETURN VARCHAR2 IS

-- Cursor to check whether the given return line is valid or not.
CURSOR chk_return_line (c_oe_line_id NUMBER) IS
SELECT 'X'
  FROM OE_ORDER_LINES_ALL
 WHERE line_id      = c_oe_line_id
   AND line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID');

-- SATHAPLI::Bug 6877509 - changes start, 02-Apr-08
-- Cursor to get the ordered and shipped quantities of the given return line.
-- If the return line has been split (like in partial qty receive for non-serialized items), we have to look at
-- the cumulative qty of all the split lines so as to decide that the shipped qty is equal to or less than the ordered qty.
/*
CURSOR get_oe_quantities (c_oe_line_id NUMBER) IS
SELECT ordered_quantity, shipped_quantity
  FROM OE_ORDER_LINES_ALL
 WHERE line_id = c_oe_line_id;
*/
CURSOR get_oe_quantities (c_oe_header_id NUMBER, c_oe_line_number NUMBER) IS
SELECT SUM(ordered_quantity), SUM(shipped_quantity)
  FROM OE_ORDER_LINES_ALL
 WHERE header_id                = c_oe_header_id
   AND line_number              = c_oe_line_number
   AND NVL(cancelled_flag, 'X') <> 'Y';

/*
NOTE: Instead of using the line_number, we can use split_from_line_id and get the cumulative qty using a hierarchical query.
But there is no index present on the column split_from_line_id in the table OE_ORDER_LINES_ALL, and the hierarchical query is
performance intensive. This approach may be pursued in the future, if need be.
*/

-- Cursor to get the header_id and line_number of the given return line. This is mainly for split lines.
CURSOR get_oe_split_line_details (c_oe_line_id NUMBER) IS
SELECT header_id, line_number
  FROM OE_ORDER_LINES_ALL
 WHERE line_id = c_oe_line_id;
-- SATHAPLI::Bug 6877509 - changes end, 02-Apr-08

-- Cursor to get the PO header id for the OSP order corresponding to the given return line id.
-- Only those OSP orders need to be considered, which have the status as PO_CREATED or REQ_CREATED.
CURSOR get_po_header_id (c_oe_return_line_id NUMBER) IS
SELECT AOB.po_header_id,
       AOB.po_req_header_id,
       AOL.osp_order_id
  FROM AHL_OSP_ORDER_LINES AOL, AHL_OSP_ORDERS_B AOB
 WHERE AOL.oe_return_line_id = c_oe_return_line_id
   AND AOL.osp_order_id      = AOB.osp_order_id
   AND AOB.status_code       IN ('PO_CREATED', 'REQ_CREATED')
   AND ROWNUM = 1;

-- Cursor to check whether the given Purchase order is approved or not.
CURSOR chk_po_header_approved (c_po_header_id NUMBER) IS
SELECT 'X'
  FROM PO_HEADERS_ALL
 WHERE NVL(approved_flag, 'N') = 'Y'
   AND po_header_id            = c_po_header_id;

-- Cursor to check whether the given Requisition is approved or not.
CURSOR chk_po_req_approved (c_po_req_header_id NUMBER) IS
SELECT 'X'
  FROM PO_REQUISITION_HEADERS_ALL
 WHERE NVL(authorization_status, 'X') = 'APPROVED'
   AND requisition_header_id          = c_po_req_header_id;

-- Cursor to get the PO line quantity details for all the OSP order lines, corresponding to the given return line id.
-- Only those OSP order lines need to be considered, which doesn't have the status as PO_DELETED or PO_CANCELLED, or
-- REQ_DELETED or REQ_CANCELLED.
CURSOR get_po_line_quantity1 (c_oe_return_line_id NUMBER) IS
SELECT AOL.po_line_id,
       AOL.po_req_line_id,
       POL.quantity,
       (SELECT SUM(PLL.quantity_received)
          FROM PO_LINE_LOCATIONS_ALL PLL
         WHERE PLL.po_line_id = POL.po_line_id) quantity_received
  FROM AHL_OSP_ORDER_LINES AOL, PO_LINES_ALL POL
 WHERE AOL.oe_return_line_id     = c_oe_return_line_id
   AND POL.po_line_id(+)         = AOL.po_line_id
   AND NVL(AOL.status_code, 'X') <> 'PO_DELETED'
   AND NVL(AOL.status_code, 'X') <> 'PO_CANCELLED'
   AND NVL(AOL.status_code, 'X') <> 'REQ_DELETED'
   AND NVL(AOL.status_code, 'X') <> 'REQ_CANCELLED';

-- Cursor to get the PO line quantity details for the given PO line id.
-- This will be used for those PO lines, which have been derived from Requisition lines.
CURSOR get_po_line_quantity2 (c_po_line_id NUMBER) IS
SELECT POL.quantity,
       (SELECT SUM(PLL.quantity_received)
          FROM PO_LINE_LOCATIONS_ALL PLL
         WHERE PLL.po_line_id = POL.po_line_id) quantity_received
  FROM PO_LINES_ALL POL
 WHERE POL.po_line_id = c_po_line_id;

-- Cursor to get the PO line for the given Requisition line id. Only approved POs will be considered.
CURSOR get_po_line (c_po_req_line_id NUMBER) IS
SELECT PLL.po_line_id
  FROM PO_LINE_LOCATIONS_ALL PLL, PO_REQUISITION_LINES REQ,
       PO_HEADERS_ALL POH
 WHERE REQ.requisition_line_id     = c_po_req_line_id
   AND PLL.line_location_id        = REQ.line_location_id
   AND PLL.po_header_id            = POH.po_header_id
   AND NVL(POH.approved_flag, 'N') = 'Y';

--
l_api_name     CONSTANT VARCHAR2(30) := 'Can_Receive_Against_PO';
l_debug_key    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_osp_order_id          AHL_OSP_ORDERS_B.osp_order_id%TYPE;
l_po_header_id          AHL_OSP_ORDERS_B.po_header_id%TYPE;
l_po_req_header_id      AHL_OSP_ORDERS_B.po_req_header_id%TYPE;
l_po_line_id            AHL_OSP_ORDER_LINES.po_line_id%TYPE;
l_po_req_line_id        AHL_OSP_ORDER_LINES.po_req_line_id%TYPE;
l_oe_ordered_qty        OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_oe_shipped_qty        OE_ORDER_LINES_ALL.shipped_quantity%TYPE;
l_po_line_qty           NUMBER;
l_po_line_tot_qty       NUMBER;
l_dummy                 VARCHAR2(1);

l_oe_hdr_id             OE_ORDER_LINES_ALL.header_id%TYPE;
l_oe_line_no            OE_ORDER_LINES_ALL.line_number%TYPE;

TYPE PO_LINE_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_po_line_tbl           PO_LINE_TBL_TYPE;
l_merged_req_line       BOOLEAN      := FALSE;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.begin', 'API called with p_return_line_id: '||p_return_line_id);
    END IF;

    -- Check whether the given return line is valid or not.
    OPEN chk_return_line(p_return_line_id);
    FETCH chk_return_line INTO l_dummy;
    IF (chk_return_line%NOTFOUND) THEN
        -- The given return line is invalid. Return FND_API.G_FALSE.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Return line: '||p_return_line_id||' is invalid. Returnig False.');
        END IF;

        CLOSE chk_return_line;
        RETURN FND_API.G_FALSE;
    END IF;
    CLOSE chk_return_line;

    -- SATHAPLI::Bug 6877509 - changes start, 02-Apr-08
    -- Get the header_id and line_number of the given return line.
    OPEN get_oe_split_line_details(p_return_line_id);
    FETCH get_oe_split_line_details INTO l_oe_hdr_id, l_oe_line_no;
    CLOSE get_oe_split_line_details;

    -- Get the ordered and shipped quantities of the given return line.
    -- OPEN get_oe_quantities(p_return_line_id);
    OPEN get_oe_quantities(l_oe_hdr_id, l_oe_line_no);
    FETCH get_oe_quantities INTO l_oe_ordered_qty, l_oe_shipped_qty;
    CLOSE get_oe_quantities;
    -- SATHAPLI::Bug 6877509 - changes end, 02-Apr-08

    -- PO receipt should be enabled only after RMA receipt is complete. For this, check for the ordered and
    -- shipped quantities of the given return line. If the shipped quantity is less than the
    -- ordered quantity, then it means there is still quantity left to be returned. Return FND_API.G_FALSE.
    IF (l_oe_shipped_qty IS NULL OR l_oe_shipped_qty < l_oe_ordered_qty) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Shipped quantity is NULL, or less than the ordered quantity for the return line: '||p_return_line_id||
                           '. As receipt against RMA is not complete yet, returning False.');
        END IF;

        RETURN FND_API.G_FALSE;
    END IF;

    -- Get the PO header id for the OSP order corresponding to the given return line id.
    OPEN get_po_header_id(p_return_line_id);
    FETCH get_po_header_id INTO l_po_header_id, l_po_req_header_id, l_osp_order_id;
    IF (get_po_header_id%FOUND) THEN
        IF (l_po_header_id IS NULL) THEN
            -- As the PO header id is NULL, check for the requisition header id.
            IF (l_po_req_header_id IS NULL) THEN
                -- Even the requisition header id is NULL. Return FND_API.G_FALSE.
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Both PO and requisition headers are NULL for the OSP order: '||l_osp_order_id||
                                   '. Returning False.');
                END IF;

                CLOSE get_po_header_id;
                RETURN FND_API.G_FALSE;
            ELSE
                -- Check whether the Requisition is approved or not.
                -- If not approved, return FND_API.G_FALSE.
                OPEN chk_po_req_approved(l_po_req_header_id);
                FETCH chk_po_req_approved INTO l_dummy;
                IF (chk_po_req_approved%NOTFOUND) THEN
                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                       'Requisition: '||l_po_header_id||' is not approved. Returning False.');
                    END IF;

                    CLOSE chk_po_req_approved;
                    CLOSE get_po_header_id;
                    RETURN FND_API.G_FALSE;
                END IF;
                CLOSE chk_po_req_approved;
            END IF; -- if l_po_req_header_id IS NULL
        ELSE
            -- Check whether the Purchase order is approved or not.
            -- If not approved, return FND_API.G_FALSE.
            OPEN chk_po_header_approved(l_po_header_id);
            FETCH chk_po_header_approved INTO l_dummy;
            IF (chk_po_header_approved%NOTFOUND) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Purchase order: '||l_po_header_id||' is not approved. Returning False.');
                END IF;

                CLOSE chk_po_header_approved;
                CLOSE get_po_header_id;
                RETURN FND_API.G_FALSE;
            END IF;
            CLOSE chk_po_header_approved;
        END IF; -- if l_po_header_id IS NULL
    ELSE
        -- This means that the OSP order is not in the PO_CREATED or REQ_CREATED status. Return FND_API.G_FALSE.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'OSP order: '||l_osp_order_id||' is not in status PO_CREATED or REQ_CREATED. Returnig False.');
        END IF;

        CLOSE get_po_header_id;
        RETURN FND_API.G_FALSE;
    END IF; -- if get_po_header_id%FOUND
    CLOSE get_po_header_id;

    -- After the OSP order and Purchase order or Requisition checks above, check for the PO line quantity for each OSP order line.
    OPEN get_po_line_quantity1(p_return_line_id);
    LOOP
        FETCH get_po_line_quantity1 INTO l_po_line_id, l_po_req_line_id, l_po_line_qty, l_po_line_tot_qty;
        EXIT WHEN get_po_line_quantity1%NOTFOUND;

        -- If PO line is NULL, get it from the Requisition line.
        l_merged_req_line := FALSE; -- Set merged Requisition line flag as FALSE at the start of the loop
        IF (l_po_line_id IS NULL) THEN
            OPEN get_po_line(l_po_req_line_id);
            FETCH get_po_line INTO l_po_line_id;
            IF (get_po_line%FOUND) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'PO line id was NULL. Got it as '||l_po_line_id||' from the Requisition line: '||l_po_req_line_id);
                END IF;

                -- Check for merged Requisition lines, i.e. whether this PO line has already been checked or not.
                IF (l_po_line_tbl.EXISTS(l_po_line_id)) THEN
                    l_merged_req_line := TRUE;
                ELSE
                    l_merged_req_line := FALSE;
                    l_po_line_tbl(l_po_line_id) := l_po_line_id;

                    -- Get the PO line quantity and the total received quantity.
                    OPEN get_po_line_quantity2(l_po_line_id);
                    FETCH get_po_line_quantity2 INTO l_po_line_qty, l_po_line_tot_qty;
                    CLOSE get_po_line_quantity2;
                END IF;
            ELSE
                -- Either PO is not created or its not approved.
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Either PO is not created or its not approved. Returning False');
                END IF;

                CLOSE get_po_line;
                CLOSE get_po_line_quantity1;
                RETURN FND_API.G_FALSE;
            END IF; -- if get_po_line%FOUND
            CLOSE get_po_line;
        END IF;

        -- For any of the PO lines, if the total received quantity is not less than the line quantity, return FND_API.G_FALSE.
        -- No need to check this for merged Requisition lines, this check would already have happened for the first Requisition line.
        IF NOT l_merged_req_line AND NOT (l_po_line_tot_qty < l_po_line_qty) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                               'Total received quantity is not less than the line quantity for PO line id: '||l_po_line_id||'.'||
                               ' Returning False.');
            END IF;

            CLOSE get_po_line_quantity1;
            RETURN FND_API.G_FALSE;
        END IF;
    END LOOP;
    CLOSE get_po_line_quantity1;

    -- If all the checks have been validated, return FND_API.G_TRUE.
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                       'All checks validated. Returnig True.');
    END IF;

    RETURN FND_API.G_TRUE;
END Can_Receive_Against_PO;


-- Start of Comments --
--  Function name    : Can_Receive_Against_RMA
--  Type             : Public
--  Functionality    : Function to determine if a receipt can be done against a given RMA line.
--                     It returns FND_API.G_TRUE if a receipt can be done. Otherwise, it returns FND_API.G_FALSE.
--  Pre-reqs         :
--
--  Parameters:
--
--   p_return_line_id     IN    NUMBER      RMA Line Id
--
--  Version:
--
--   Initial Version      1.0
--
-- End of Comments --

FUNCTION Can_Receive_Against_RMA (
    p_return_line_id      IN    NUMBER
)
RETURN VARCHAR2 IS

-- Cursor to check whether the given return line is valid or not.
CURSOR chk_return_line (c_oe_line_id NUMBER) IS
SELECT 'X'
  FROM OE_ORDER_LINES_ALL
 WHERE line_id      = c_oe_line_id
   AND line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID');

-- Cursor to check whether the shipment is booked or not.
CURSOR chk_shipment_booked (c_oe_line_id NUMBER) IS
SELECT OHA.header_id
  FROM OE_ORDER_LINES_ALL OLA, OE_ORDER_HEADERS_ALL OHA
 WHERE OLA.line_id     = c_oe_line_id
   AND OHA.header_id   = OLA.header_id
   AND OHA.booked_flag = 'Y';

-- Cursor to get the ship line id of the OSP order lines, that correspond to the given return line.
CURSOR get_osp_ship_line_id (c_oe_return_line_id NUMBER) IS
SELECT oe_ship_line_id
  FROM AHL_OSP_ORDER_LINES
 WHERE oe_return_line_id = c_oe_return_line_id
   AND ROWNUM = 1;

-- Cursor to get the ordered and shipped quantities of the given return line.
CURSOR get_oe_quantities (c_oe_line_id NUMBER) IS
SELECT ordered_quantity, shipped_quantity
  FROM OE_ORDER_LINES_ALL
 WHERE line_id = c_oe_line_id;

--
l_api_name     CONSTANT VARCHAR2(30) := 'Can_Receive_Against_RMA';
l_debug_key    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_oe_header_id          OE_ORDER_HEADERS_ALL.header_id%TYPE;
l_oe_ship_line_id       AHL_OSP_ORDER_LINES.oe_ship_line_id%TYPE;
l_ship_line_qty_rec     get_oe_quantities%ROWTYPE;
l_return_line_qty_rec   get_oe_quantities%ROWTYPE;
l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.begin', 'API called with p_return_line_id: '||p_return_line_id);
    END IF;

    -- Check whether the given return line is valid or not.
    OPEN chk_return_line(p_return_line_id);
    FETCH chk_return_line INTO l_dummy;
    IF (chk_return_line%NOTFOUND) THEN
        -- The given return line is invalid. Return FND_API.G_FALSE.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Return line: '||p_return_line_id||' is invalid. Returnig False.');
        END IF;

        CLOSE chk_return_line;
        RETURN FND_API.G_FALSE;
    END IF;
    CLOSE chk_return_line;

    -- Check whether the shipment is booked or not.
    OPEN chk_shipment_booked(p_return_line_id);
    FETCH chk_shipment_booked INTO l_oe_header_id;
    IF (chk_shipment_booked%NOTFOUND) THEN
        -- The shipment is not booked. Return FND_API.G_FALSE.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Shipment order: '||l_oe_header_id||' is not booked. Returnig False.');
        END IF;

        CLOSE chk_shipment_booked;
        RETURN FND_API.G_FALSE;
    END IF;
    CLOSE chk_shipment_booked;


    -- Get the ship line id of the OSP order lines, that correspond to the given return line.
    OPEN get_osp_ship_line_id(p_return_line_id);
    FETCH get_osp_ship_line_id INTO l_oe_ship_line_id;
    IF (get_osp_ship_line_id%FOUND) THEN
        -- If the ship line id is NULL, return FND_API.G_FALSE.
        IF (l_oe_ship_line_id IS NULL) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                               'Ship line id for the return line: '||p_return_line_id||' is NULL. Returning False.');
            END IF;

            CLOSE get_osp_ship_line_id;
            RETURN FND_API.G_FALSE;
        ELSE
            -- Get the ordered and shipped quantities of the ship line.
            OPEN get_oe_quantities(l_oe_ship_line_id);
            FETCH get_oe_quantities INTO l_ship_line_qty_rec;
            CLOSE get_oe_quantities;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key, 'l_oe_ship_line_id: '||l_oe_ship_line_id);
                FND_LOG.string(FND_LOG.level_statement, l_debug_key, 'l_ship_line_qty_rec.shipped_quantity: '||l_ship_line_qty_rec .shipped_quantity);
            END IF;

            -- Shipment should have been done for any receipt to take place. For this, check the shipped quantity.
            -- If the shipped quantity is NULL or zero, it means shipment hasn't been done yet. Return FND_API.G_FALSE.
            IF (l_ship_line_qty_rec.shipped_quantity IS NULL OR l_ship_line_qty_rec.shipped_quantity = 0) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Shipment for the return line: '||p_return_line_id||' has not been done yet. Returning False.');
                END IF;

                CLOSE get_osp_ship_line_id;
                RETURN FND_API.G_FALSE;
            END IF;
        END IF;
    END IF;
    CLOSE get_osp_ship_line_id;

    -- Get the ordered and shipped quantities of the given return line.
    OPEN get_oe_quantities(p_return_line_id);
    FETCH get_oe_quantities INTO l_return_line_qty_rec;
    CLOSE get_oe_quantities;

    -- Check for the ordered and shipped quantities of the given return line. If the shipped quantity is not less than the
    -- ordered quantity, then it means there is no quantity left to be returned. Return FND_API.G_FALSE.
    IF NOT (nvl(l_return_line_qty_rec.shipped_quantity,0) < l_return_line_qty_rec.ordered_quantity) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Shipped quantity is not less than the ordered quantity for the return line: '||p_return_line_id||'.'||
                           ' Returning False.');
        END IF;

        RETURN FND_API.G_FALSE;
    END IF;

    -- If all the checks have been validated, return FND_API.G_TRUE.
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                       'All checks validated. Returnig True.');
    END IF;

    RETURN FND_API.G_TRUE;
END Can_Receive_Against_RMA;


-- Start of Comments --
--  Procedure name   : Receive_Against_PO
--  Type             : Public
--  Functionality    : Procedure to receive against PO lines given an RMA line.
--  Pre-reqs         :
--
--  Parameters:
--
--  Standard IN Parameters:
--   p_api_version        IN    NUMBER      Required
--   p_init_msg_list      IN    VARCHAR2    Default     FND_API.G_FALSE
--   p_commit             IN    VARCHAR2    Default     FND_API.G_FALSE
--   p_validation_level   IN    NUMBER      Required
--   p_module_type        IN    VARCHAR2    Default     NULL
--
--  Standard OUT Parameters:
--   x_return_status      OUT   VARCHAR2    Required
--   x_msg_count          OUT   NUMBER      Required
--   x_msg_data           OUT   VARCHAR2    Required
--
--  Receive_Against_PO Parameters:
--   p_return_line_id     IN    NUMBER      RMA Line Id
--   x_request_id         OUT   NUMBER      Request id of the call request of the concurrent program, i.e. 'RVCTP'.
--
--  Version:
--
--   Initial Version      1.0
--
-- End of Comments --

PROCEDURE Receive_Against_PO (
    p_api_version         IN               NUMBER,
    p_init_msg_list       IN               VARCHAR2    := FND_API.G_FALSE,
    p_commit              IN               VARCHAR2    := FND_API.G_FALSE,
    p_validation_level    IN               NUMBER,
    p_module_type         IN               VARCHAR2    := NULL,
    x_return_status       OUT    NOCOPY    VARCHAR2,
    x_msg_count           OUT    NOCOPY    NUMBER,
    x_msg_data            OUT    NOCOPY    VARCHAR2,
    p_return_line_id      IN               NUMBER,
    x_request_id          OUT    NOCOPY    NUMBER
) IS

-- Cursor to get the PO header id for the OSP order corresponding to the given return line id.
-- Only those OSP orders need to be considered, which have the status as PO_CREATED or REQ_CREATED.
CURSOR get_po_header_id (c_oe_return_line_id NUMBER) IS
SELECT AOB.po_header_id,
       AOB.po_req_header_id,
       AOB.osp_order_number
  FROM AHL_OSP_ORDER_LINES AOL, AHL_OSP_ORDERS_B AOB
 WHERE AOL.oe_return_line_id = c_oe_return_line_id
   AND AOL.osp_order_id      = AOB.osp_order_id
   AND AOB.status_code       IN ('PO_CREATED', 'REQ_CREATED')
   AND ROWNUM = 1;

-- Cursor to get the PO details.
CURSOR get_po_header_details1 (c_po_header_id NUMBER) IS
SELECT vendor_id, vendor_site_id
  FROM PO_HEADERS_ALL
 WHERE NVL(approved_flag, 'N') = 'Y'
   AND po_header_id            = c_po_header_id;

-- Cursor to get the PO details. This will be used only for those PO headers, which are derived from the Requisition.
CURSOR get_po_header_details2 (c_po_line_id NUMBER) IS
SELECT POH.vendor_id, POH.vendor_site_id
  FROM PO_HEADERS_ALL POH, PO_LINES_ALL POL
 WHERE POL.po_line_id   = c_po_line_id
   AND POH.po_header_id = POL.po_header_id
   AND ROWNUM = 1;

-- Cursor to check whether the given Requisition is approved or not.
CURSOR chk_po_req_approved (c_po_req_header_id NUMBER) IS
SELECT 'X'
  FROM PO_REQUISITION_HEADERS_V
 WHERE NVL(authorization_status, 'X') = 'APPROVED'
   AND requisition_header_id          = c_po_req_header_id;

-- Cursor to get the PO line quantity details for all the OSP order lines, corresponding to the given return line id.
-- Only those OSP order lines need to be considered, which doesn't have the status as PO_DELETED or PO_CANCELLED, or
-- REQ_DELETED or REQ_CANCELLED.
CURSOR get_po_line_quantity1 (c_oe_return_line_id NUMBER) IS
SELECT AOL.po_line_id,
       AOL.po_req_line_id,
       POL.quantity,
       (SELECT SUM(PLL.quantity_received)
          FROM PO_LINE_LOCATIONS_ALL PLL
         WHERE PLL.po_line_id = POL.po_line_id) quantity_received
  FROM AHL_OSP_ORDER_LINES AOL, PO_LINES_ALL POL
 WHERE AOL.oe_return_line_id     = c_oe_return_line_id
   AND POL.po_line_id(+)         = AOL.po_line_id
   AND NVL(AOL.status_code, 'X') <> 'PO_DELETED'
   AND NVL(AOL.status_code, 'X') <> 'PO_CANCELLED'
   AND NVL(AOL.status_code, 'X') <> 'REQ_DELETED'
   AND NVL(AOL.status_code, 'X') <> 'REQ_CANCELLED';

-- Cursor to get the PO line quantity details for the given PO line id.
-- This will be used for those PO lines, which have been derived from Requisition lines.
CURSOR get_po_line_quantity2 (c_po_line_id NUMBER) IS
SELECT POL.quantity,
       (SELECT SUM(PLL.quantity_received)
          FROM PO_LINE_LOCATIONS_ALL PLL
         WHERE PLL.po_line_id = POL.po_line_id) quantity_received
  FROM PO_LINES_ALL POL, PO_LINE_LOCATIONS_ALL PLL
 WHERE POL.po_line_id = c_po_line_id;

-- Cursor to get the PO line for the given Requisition line id. Only approved POs will be considered.
CURSOR get_po_line (c_po_req_line_id NUMBER) IS
SELECT PLL.po_line_id
  FROM PO_LINE_LOCATIONS_ALL PLL, PO_REQUISITION_LINES REQ,
       PO_HEADERS_ALL POH
 WHERE REQ.requisition_line_id     = c_po_req_line_id
   AND PLL.line_location_id        = REQ.line_location_id
   AND PLL.po_header_id            = POH.po_header_id
   AND NVL(POH.approved_flag, 'N') = 'Y';

-- Cursor to check whether a pending receipt transaction exists for a given PO line id.
CURSOR chk_pending_transaction (c_po_line_id NUMBER) IS
SELECT 'X'
  FROM RCV_TRANSACTIONS_INTERFACE
 WHERE po_line_id             = c_po_line_id
   AND processing_status_code = 'PENDING';

-- Cursor to get the 'ship to org id' for a given PO line id.
CURSOR get_ship_to_org_id (c_po_line_id NUMBER) IS
SELECT ship_to_organization_id
  FROM PO_LINE_LOCATIONS_ALL
 WHERE po_line_id = c_po_line_id;

-- Cursor to get the 'ship to location id' for a given PO line id.
CURSOR get_ship_to_loc_id (c_po_line_id NUMBER) IS
SELECT ship_to_location_id
  FROM PO_LINE_LOCATIONS_ALL
 WHERE po_line_id = c_po_line_id;

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Receive_Against_PO';
l_debug_key    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_osp_order_number      AHL_OSP_ORDERS_B.osp_order_number%TYPE;
l_po_header_id          AHL_OSP_ORDERS_B.po_header_id%TYPE;
l_po_req_header_id      AHL_OSP_ORDERS_B.po_req_header_id%TYPE;
l_po_vendor_id          AHL_OSP_ORDERS_B.vendor_id%TYPE;
l_po_vendor_site_id     AHL_OSP_ORDERS_B.vendor_site_id%TYPE;
l_po_line_id            AHL_OSP_ORDER_LINES.po_line_id%TYPE;
l_po_req_line_id        AHL_OSP_ORDER_LINES.po_req_line_id%TYPE;
l_ship_to_org_id        PO_LINE_LOCATIONS_ALL.ship_to_organization_id%TYPE;
l_ship_to_loc_id        PO_LINE_LOCATIONS_ALL.ship_to_location_id%TYPE;
l_po_line_qty           NUMBER;
l_po_line_tot_qty       NUMBER;
l_po_diff_qty           NUMBER;
l_req_id                NUMBER;
l_dummy                 VARCHAR2(1);
l_temp                  NUMBER;
l_hdr_inserted          BOOLEAN      := FALSE;
l_po_lines_exist        BOOLEAN      := FALSE;

TYPE PO_LINE_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_po_line_tbl           PO_LINE_TBL_TYPE;
l_merged_req_line       BOOLEAN      := FALSE;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.begin', 'Start of the API. p_return_line_id: '||p_return_line_id);
    END IF;

    -- Standard start of API savepoint.
    SAVEPOINT Receive_Against_PO_Pvt;

    -- Initialize Procedure return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Get the PO header id for the OSP order corresponding to the given return line id.
    OPEN get_po_header_id(p_return_line_id);
    FETCH get_po_header_id INTO l_po_header_id, l_po_req_header_id, l_osp_order_number;
    IF (get_po_header_id%FOUND) THEN
        IF (l_po_header_id IS NULL) THEN
            -- As the PO header id is NULL, check for the requisition header id.
            IF (l_po_req_header_id IS NULL) THEN
                -- Even the requisition header id is NULL. Raise an exception.
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Both PO and requisition headers are NULL for the OSP order: '||l_osp_order_number||
                                   '. Raising exception.');
                END IF;

                CLOSE get_po_header_id;
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_PO_REQ_NULL'); -- Receipt cannot be done as neither the purchase order nor the requisition exist for this OSP order.
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                -- Check whether the Requisition is approved or not.
                -- If not approved, raise an exception.
                OPEN chk_po_req_approved(l_po_req_header_id);
                FETCH chk_po_req_approved INTO l_dummy;
                IF (chk_po_req_approved%NOTFOUND) THEN
                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                       'Requisition: '||l_po_header_id||' is not approved. Raising exception.');
                    END IF;

                    CLOSE chk_po_req_approved;
                    CLOSE get_po_header_id;
                    FND_MESSAGE.set_name('AHL', 'AHL_OSP_REQ_NOT_APRVD'); -- Receipt cannot be done as the requisition is not approved.
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE chk_po_req_approved;
            END IF; -- if l_po_req_header_id IS NULL
        ELSE
            -- Get the Purchase order details. If not approved, raise an exception.
            OPEN get_po_header_details1(l_po_header_id);
            FETCH get_po_header_details1 INTO l_po_vendor_id, l_po_vendor_site_id;
            IF (get_po_header_details1%NOTFOUND) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Purchase order: '||l_po_header_id||' is not approved. Raising exception.');
                END IF;

                CLOSE get_po_header_details1;
                CLOSE get_po_header_id;
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_PO_NOT_APRVD'); -- Receipt cannot be done as the purchase order is not approved.
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE get_po_header_details1;
        END IF; -- if l_po_header_id IS NULL
    ELSE
        -- This means that the OSP order is not in the PO_CREATED or REQ_CREATED status. Raise an exception.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'OSP order: '||l_osp_order_number||' is not in status PO_CREATED or REQ_CREATED. Raising exception.');
        END IF;

        CLOSE get_po_header_id;
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORDER_INVALID'); -- The status of the OSP order (ORDER_NUM) is not valid for receiving.
        FND_MESSAGE.set_token('ORDER_NUM', l_osp_order_number);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF; -- if get_po_header_id%FOUND
    CLOSE get_po_header_id;

    -- Get the PO line quantity and the total received quantity.
    OPEN get_po_line_quantity1(p_return_line_id);
    LOOP
        FETCH get_po_line_quantity1 INTO l_po_line_id, l_po_req_line_id, l_po_line_qty, l_po_line_tot_qty;
        EXIT WHEN get_po_line_quantity1%NOTFOUND;

        -- If PO line is NULL, get it from the Requisition line.
        l_merged_req_line := FALSE; -- Set merged Requisition line flag as FALSE at the start of the loop
        IF (l_po_line_id IS NULL) THEN
            OPEN get_po_line(l_po_req_line_id);
            FETCH get_po_line INTO l_po_line_id;
            IF (get_po_line%FOUND) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'PO line id was NULL. Got it as '||l_po_line_id||' from the Requisition line: '||l_po_req_line_id);
                END IF;

                -- Check for merged Requisition lines, i.e. whether this PO line has already been checked or not.
                IF (l_po_line_tbl.EXISTS(l_po_line_id)) THEN
                    l_merged_req_line := TRUE;
                ELSE
                    l_merged_req_line := FALSE;
                    l_po_line_tbl(l_po_line_id) := l_po_line_id;

                    -- Get the PO line quantity and the total received quantity.
                    OPEN get_po_line_quantity2(l_po_line_id);
                    FETCH get_po_line_quantity2 INTO l_po_line_qty, l_po_line_tot_qty;
                    CLOSE get_po_line_quantity2;

                    -- Get the Vendor details for the derived PO line.
                    OPEN get_po_header_details2(l_po_line_id);
                    FETCH get_po_header_details2 INTO l_po_vendor_id, l_po_vendor_site_id;
                    CLOSE get_po_header_details2;
                END IF;
            ELSE
                -- Either PO is not created or its not approved. Raise exception.
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Either PO is not created or its not approved. Raising Exception');
                END IF;

                CLOSE get_po_line;
                CLOSE get_po_line_quantity1;
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_PO_NULL_OR_INVLD'); -- Either the purchase order is not created or it is not approved.
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF; -- if get_po_line%FOUND
            CLOSE get_po_line;
        END IF;

        -- Do the rest of the processing only for those PO lines for which the total received quantity is less than the line quantity.
        -- Do not process merged Requisition lines, i.e. PO lines already processed.
        IF NOT l_merged_req_line AND (l_po_line_tot_qty < l_po_line_qty) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                               'Processing for PO line id: '||l_po_line_id);
            END IF;

            -- Set the l_po_lines_exist flag.
            IF (NOT l_po_lines_exist) THEN
                l_po_lines_exist := TRUE;
            END IF;

            -- Check whether a pending receipt transaction exists for this PO line id.
            OPEN chk_pending_transaction(l_po_line_id);
            FETCH chk_pending_transaction INTO l_dummy;
            IF (chk_pending_transaction%FOUND) THEN
                -- Pending receipt transaction exists for this PO line id. Raise an exception.
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Pending transactions exist for PO line id: '||l_po_line_id);
                END IF;

                CLOSE chk_pending_transaction;
                CLOSE get_po_line_quantity1;
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_PO_PENDING_TRNSCTN'); -- Some of the purchase order lines for this return line have pending transactions.
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE chk_pending_transaction;

            -- Insert a record in RCV_HEADERS_INTERFACE table as a header of these PO lines.
            IF (NOT l_hdr_inserted) THEN
                -- Set the l_hdr_inserted flag.
                l_hdr_inserted := TRUE;

                -- Get the 'ship to org id' for this PO line id.
                OPEN get_ship_to_org_id(l_po_line_id);
                FETCH get_ship_to_org_id INTO l_ship_to_org_id;
                CLOSE get_ship_to_org_id;

                INSERT INTO RCV_HEADERS_INTERFACE(
                    HEADER_INTERFACE_ID,
                    GROUP_ID,
                    PROCESSING_STATUS_CODE,
                    RECEIPT_SOURCE_CODE,
                    TRANSACTION_TYPE,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY,
                    VENDOR_ID,
                    VENDOR_SITE_ID,
                    SHIP_TO_ORGANIZATION_ID
                ) VALUES (
                    PO.RCV_HEADERS_INTERFACE_S.NEXTVAL,
                    PO.RCV_INTERFACE_GROUPS_S.NEXTVAL,
                    'PENDING',
                    'VENDOR',
                    'NEW',
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    l_po_vendor_id,
                    l_po_vendor_site_id,
                    l_ship_to_org_id
                );

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Transaction header inserted.');
                END IF;
            END IF; -- l_hdr_inserted check

            -- Get the 'ship to location id' for this PO line id.
            OPEN get_ship_to_loc_id(l_po_line_id);
            FETCH get_ship_to_loc_id INTO l_ship_to_loc_id;
            CLOSE get_ship_to_loc_id;

            -- Get the difference between the PO line quantity and the total received quantity.
            l_po_diff_qty := l_po_line_qty - l_po_line_tot_qty;

            -- Insert a record in RCV_TRANSACTIONS_INTERFACE table corresponsing to this PO line.
            INSERT INTO RCV_TRANSACTIONS_INTERFACE(
                INTERFACE_TRANSACTION_ID,
                HEADER_INTERFACE_ID,
                GROUP_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                CREATION_DATE,
                CREATED_BY,
                TRANSACTION_TYPE,
                TRANSACTION_DATE,
                PROCESSING_STATUS_CODE,
                PROCESSING_MODE_CODE,
                TRANSACTION_STATUS_CODE,
                QUANTITY,
                AUTO_TRANSACT_CODE,
                RECEIPT_SOURCE_CODE,
                SOURCE_DOCUMENT_CODE,
                VALIDATION_FLAG,
                PO_HEADER_ID,
                PO_LINE_ID,
                SHIP_TO_LOCATION_ID
            ) VALUES (
                PO.RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL,
                PO.RCV_HEADERS_INTERFACE_S.CURRVAL,
                PO.RCV_INTERFACE_GROUPS_S.CURRVAL,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                'RECEIVE',
                SYSDATE,
                'PENDING',
                'BATCH',
                'PENDING',
                l_po_diff_qty,
                'RECEIVE',
                'VENDOR',
                'PO',
                'Y',
                l_po_header_id,
                l_po_line_id,
                l_ship_to_loc_id
            );

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                               'Transaction record inserted for PO line id: '||l_po_line_id);
            END IF;
        END IF; -- (l_po_line_tot_qty < l_po_line_qty)
    END LOOP; -- PO lines loop
    CLOSE get_po_line_quantity1;

    -- Check for the l_po_lines_exist flag. If not set, raise an exception.
    IF (NOT l_po_lines_exist) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'No PO lines could be found to do a receipt against. Raising exception.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ALL_PO_LINES_RCVD'); -- All the purchase order lines for this return line have been received.
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- After the interface tables been populated above, submit request for calling the Concurrent Program 'RVCTP'.
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                       'Submitting the request for calling the Concurrent Program RVCTP.');
    END IF;

    -- Get the current value of the sequence PO.RCV_INTERFACE_GROUPS_S, required for submitting the request.
    SELECT PO.RCV_INTERFACE_GROUPS_S.CURRVAL INTO l_temp FROM DUAL;

    l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    application => 'PO',
                    program     => 'RVCTP',
										--Modified by mpothuku on 04-Mar-2007 for the Bug 6862891
                    argument1   => 'BATCH',
                    argument2   => l_temp,
                    argument3   => MO_GLOBAL.get_current_org_id()
                );

    IF (l_req_id = 0) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Concurrent request failed.');
        END IF;
    ELSE
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Concurrent request successful. Request id: '||l_req_id);
        END IF;
    END IF;

    -- Set the OUT parameter x_request_id with l_req_id.
    x_request_id := l_req_id;

    -- Standard call to get message count and initialise the OUT parameters.
    FND_MSG_PUB.Count_And_Get
    ( p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE
    );

    -- Commit work if p_commit is TRUE.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.end', 'End of the API. x_request_id: '||x_request_id);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Receive_Against_PO_Pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Receive_Against_PO_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

    WHEN OTHERS THEN
        ROLLBACK TO Receive_Against_PO_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);

        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);
END Receive_Against_PO;


-- Start of Comments --
--  Procedure name   : Receive_Against_RMA
--  Type             : Public
--  Functionality    : Procedure to receive against a given RMA line.
--                     Also does any Part Number/Serial Number change or an Exchange prior to doing the receipt.
--  Pre-reqs         :
--
--  Parameters:
--
--  Standard IN Parameters:
--   p_api_version        IN    NUMBER      Required
--   p_init_msg_list      IN    VARCHAR2    Default     FND_API.G_FALSE
--   p_commit             IN    VARCHAR2    Default     FND_API.G_FALSE
--   p_validation_level   IN    NUMBER      Required
--   p_module_type        IN    VARCHAR2    Default     NULL
--
--  Standard OUT Parameters:
--   x_return_status      OUT   VARCHAR2    Required
--   x_msg_count          OUT   NUMBER      Required
--   x_msg_data           OUT   VARCHAR2    Required
--
--  Receive_Against_PO Parameters:
--   p_rma_receipt_rec    IN    RMA_Receipt_Rec_Type    RMA receipt record
--   x_request_id         OUT   NUMBER                  Request id of the call request of the concurrent program, i.e. 'RVCTP'.
--   x_return_line_id     OUT   NUMBER                  New RMA Line id against which the receipt has been done.
--
--  Version:
--
--   Initial Version      1.0
--
-- End of Comments --

PROCEDURE Receive_Against_RMA (
    p_api_version         IN               NUMBER,
    p_init_msg_list       IN               VARCHAR2    := FND_API.G_FALSE,
    p_commit              IN               VARCHAR2    := FND_API.G_FALSE,
    p_validation_level    IN               NUMBER,
    p_module_type         IN               VARCHAR2    := NULL,
    x_return_status       OUT    NOCOPY    VARCHAR2,
    x_msg_count           OUT    NOCOPY    NUMBER,
    x_msg_data            OUT    NOCOPY    VARCHAR2,
    p_rma_receipt_rec     IN               RMA_Receipt_Rec_Type,
    x_request_id          OUT    NOCOPY    NUMBER,
    x_return_line_id      OUT    NOCOPY    NUMBER
) IS

-- Cursor to get the sales order details.
CURSOR oe_order_line_details_csr (c_oe_line_id NUMBER) IS
SELECT inventory_item_id,
       sold_to_org_id customer_id,
       ship_to_org_id customer_site_id,
       ship_from_org_id organization_id,
       subinventory,
       header_id oe_order_header_id,
       line_id oe_order_line_id
  FROM oe_order_lines_all
 WHERE line_id = c_oe_line_id;

CURSOR inv_item_ctrls_csr (c_inv_item_id NUMBER,c_org_id NUMBER) IS
SELECT serial_number_control_code,
       lot_control_code,
       nvl(comms_nl_trackable_flag,'N')
  FROM mtl_system_items_b
 WHERE inventory_item_id = c_inv_item_id
   AND organization_id = c_org_id;

CURSOR get_IB_subtrns_inst_dtls_csr (c_oe_line_id NUMBER) IS
SELECT tld.instance_id,
       csi.inventory_item_id,
       csi.serial_number,
       csi.lot_number
  FROM csi_t_transaction_lines tl,
       csi_t_txn_line_details tld,
       csi_item_instances csi
 WHERE tl.source_transaction_id = c_oe_line_id
   AND tl.source_transaction_table = 'OE_ORDER_LINES_ALL'
   AND tl.transaction_line_id = tld.transaction_line_id
   AND tld.instance_id = csi.instance_id;

CURSOR get_osp_order_dtls(c_oe_line_id NUMBER) IS
  SELECT osp.osp_order_id,
         osp.order_type_code,
         oel.source_document_line_id osp_line_id,
         osp.object_version_number
    FROM oe_order_lines_all oel,
         ahl_osp_orders_b osp
   WHERE oel.header_id = osp.oe_header_id
     AND oel.line_id = c_oe_line_id;

CURSOR get_osp_order_line_dtls(c_osp_line_id NUMBER) IS
  SELECT inventory_item_id,
         serial_number,
         lot_number,
         exchange_instance_id
    FROM ahl_osp_order_lines
   WHERE osp_order_line_id = c_osp_line_id;

CURSOR ahl_oe_lot_serial_id_csr (c_oe_line_id  NUMBER) IS
  SELECT lot_number,
         from_serial_number serial_number
   FROM oe_lot_serial_numbers
  WHERE line_id = c_oe_line_id;

CURSOR get_item_number(c_inv_item_id NUMBER) IS
  SELECT concatenated_segments
   FROM mtl_system_items_kfv
  WHERE inventory_item_id = c_inv_item_id
    AND rownum = 1;

CURSOR get_oe_line_id(c_osp_line_id NUMBER) IS
  SELECT oe_return_line_id
   FROM ahl_osp_order_lines
  WHERE osp_order_line_id = c_osp_line_id;

CURSOR get_instance_id(c_inv_item_id NUMBER, c_serial_number VARCHAR2) IS
  SELECT instance_id
   FROM csi_item_instances
  WHERE inventory_item_id = c_inv_item_id
    AND serial_number = c_serial_number;

 -- Cursor to check whether a pending receipt transaction exists for a given order line id.
CURSOR chk_pending_transaction (c_oe_line_id NUMBER) IS
SELECT 'X'
  FROM RCV_TRANSACTIONS_INTERFACE
 WHERE oe_order_line_id = c_oe_line_id
   AND processing_status_code = 'PENDING';

CURSOR get_err_tranansaction_dtls(c_oe_line_id NUMBER) IS
SELECT interface_transaction_id, header_interface_id
  FROM RCV_TRANSACTIONS_INTERFACE
 WHERE oe_order_line_id = c_oe_line_id
   AND processing_status_code = 'ERROR';

CURSOR get_same_phyitem_order_lines(c_osp_order_line_id IN NUMBER) IS
SELECT matched_ol.osp_order_line_id
  FROM ahl_osp_order_lines matched_ol,
       ahl_osp_order_lines passed_ol
 WHERE passed_ol.osp_order_line_id = c_osp_order_line_id
   AND passed_ol.inventory_item_id = matched_ol.inventory_item_id
   AND passed_ol.serial_number = matched_ol.serial_number;

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Receive_Against_RMA';
l_debug_key    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
--
l_part_num_change_flag  BOOLEAN      := FALSE;
l_exchange_flag         BOOLEAN      := FALSE;
l_return_line_id        NUMBER;
l_intf_hdr_id           NUMBER;
l_group_id              NUMBER;
l_intf_transaction_id   NUMBER;
l_mtl_transaction_id    NUMBER;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_employee_id           NUMBER;
l_serial_control_code   NUMBER;
l_lot_control_code      NUMBER;
l_is_ib_trackable       VARCHAR2(1);
l_IB_subtrns_inst_rec get_IB_subtrns_inst_dtls_csr%ROWTYPE;
l_osp_order_id          NUMBER;
l_osp_order_type        VARCHAR2(30);
l_trans_serial_number   mtl_serial_numbers.serial_number%TYPE;
l_trans_lot_number      mtl_lot_numbers.lot_number%TYPE;
l_osp_line_id           NUMBER;
l_oe_order_line_rec     oe_order_line_details_csr%ROWTYPE;
l_oe_lot_serial_rec     ahl_oe_lot_serial_id_csr%ROWTYPE;
l_osp_order_line_rec    get_osp_order_line_dtls%ROWTYPE;
l_curr_org_id           NUMBER;
l_serialnum_change_rec  AHL_OSP_SHIPMENT_PUB.Sernum_Change_Rec_Type;
l_new_item_number       VARCHAR2(40);
l_new_oe_line_id        NUMBER;
l_osp_ord_obj_ver       NUMBER;
l_osp_order_rec         AHL_OSP_ORDERS_PVT.osp_order_rec_type;
l_oe_line_tbl           OE_ORDER_PUB.LINE_TBL_TYPE;
l_oe_lot_serial_tbl     OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;
l_derived_instance_id   NUMBER;
l_del_oe_lines_tbl      AHL_OSP_SHIPMENT_PUB.SHIP_ID_TBL_TYPE;
l_osp_order_lines_tbl   AHL_OSP_ORDERS_PVT.OSP_ORDER_LINES_TBL_TYPE;
l_request_id            NUMBER;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_oe_line_rec           OE_ORDER_PUB.line_rec_type;
l_rma_line_canceled     boolean;
l_ib_trans_deleted      boolean;
l_dummy                 VARCHAR2(1);
l_err_intf_trans_id     NUMBER;
l_err_intf_hdr_id       NUMBER;
l_same_ser_ospline_id   NUMBER;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key ||'.begin', 'Start of the API.');
    END IF;

    -- Standard start of API savepoint.
    SAVEPOINT Receive_Against_RMA_Pvt;

    -- Initialize Procedure return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_return_line_id := null;

    --Log the input parameters
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RETURN_LINE_ID:'||p_rma_receipt_rec.RETURN_LINE_ID);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RECEIVING_ORG_ID:'||p_rma_receipt_rec.RECEIVING_ORG_ID);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RECEIVING_SUBINVENTORY:'||p_rma_receipt_rec.RECEIVING_SUBINVENTORY);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RECEIVING_LOCATOR_ID:'||p_rma_receipt_rec.RECEIVING_LOCATOR_ID);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RECEIPT_QUANTITY:'||p_rma_receipt_rec.RECEIPT_QUANTITY);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RECEIPT_UOM_CODE:'||p_rma_receipt_rec.RECEIPT_UOM_CODE);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'RECEIPT_DATE:'||p_rma_receipt_rec.RECEIPT_DATE);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'NEW_SERIAL_NUMBER:'||p_rma_receipt_rec.NEW_SERIAL_NUMBER);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'NEW_SERIAL_TAG_CODE:'||p_rma_receipt_rec.NEW_SERIAL_TAG_CODE);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'NEW_LOT_NUMBER:'||p_rma_receipt_rec.NEW_LOT_NUMBER);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'NEW_ITEM_REV_NUMBER:'||p_rma_receipt_rec.NEW_ITEM_REV_NUMBER);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'EXCHANGE_ITEM_ID:'||p_rma_receipt_rec.EXCHANGE_ITEM_ID);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'EXCHANGE_SERIAL_NUMBER:'||p_rma_receipt_rec.EXCHANGE_SERIAL_NUMBER);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'EXCHANGE_LOT_NUMBER:'||p_rma_receipt_rec.EXCHANGE_LOT_NUMBER);
    END IF;

    -- Check whether a pending receipt transaction exists for this return line id.
    OPEN chk_pending_transaction(p_rma_receipt_rec.RETURN_LINE_ID);
    FETCH chk_pending_transaction INTO l_dummy;
    IF (chk_pending_transaction%FOUND) THEN
        -- Pending receipt transaction exists for this PO line id. Raise an exception.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key, 'Pending transactions exist for oe line id: '||p_rma_receipt_rec.RETURN_LINE_ID);
        END IF;
        CLOSE chk_pending_transaction;
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_OE_TRANS_PENDING'); -- The return line has pending transactions.
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE chk_pending_transaction;

    /* Validate the input parameters. This api will throw any validation errors */
    validate_receiving_params(p_rma_receipt_rec);

    -- Check for part number change attributes.
    IF (p_rma_receipt_rec.new_item_id IS NOT NULL OR p_rma_receipt_rec.new_serial_number IS NOT NULL) THEN
        -- Set the l_part_num_change_flag.
        l_part_num_change_flag := TRUE;
    END IF;

    -- Check for exchange attributes.
    IF (p_rma_receipt_rec.exchange_item_id IS NOT NULL OR p_rma_receipt_rec.exchange_serial_number IS NOT NULL OR
        p_rma_receipt_rec.exchange_lot_number IS NOT NULL) THEN
        -- Set the l_exchange_flag.
        l_exchange_flag := TRUE;
    END IF;

    --Derive the osp_line_id for which the part number/serial change is being performed
    OPEN get_osp_order_dtls(p_rma_receipt_rec.return_line_id);
    FETCH get_osp_order_dtls INTO l_osp_order_id,l_osp_order_type,l_osp_line_id,l_osp_ord_obj_ver;
    CLOSE get_osp_order_dtls;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_id:'||l_osp_order_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_type:'||l_osp_order_type);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_line_id:'|| l_osp_line_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_ord_obj_ver:'|| l_osp_ord_obj_ver);
    END IF;

    --Retrieve the Return Line details
    OPEN oe_order_line_details_csr(p_rma_receipt_rec.return_line_id);
    FETCH oe_order_line_details_csr INTO l_oe_order_line_rec;
    CLOSE oe_order_line_details_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.inventory_item_id:'||l_oe_order_line_rec.inventory_item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.customer_id:'||l_oe_order_line_rec.customer_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.customer_site_id:'||l_oe_order_line_rec.customer_site_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.organization_id:'||l_oe_order_line_rec.organization_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.subinventory:'||l_oe_order_line_rec.subinventory);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.oe_order_header_id:'||l_oe_order_line_rec.oe_order_header_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.oe_order_line_id:'||l_oe_order_line_rec.oe_order_line_id);
    END IF;

    --Part Number change is being performed
    IF (l_part_num_change_flag) THEN

      IF(l_osp_line_id is not null AND AHL_OSP_SHIPMENT_PUB.Is_part_chg_valid_for_ospline(l_osp_line_id) = 'Y')
      THEN
        OPEN get_item_number(p_rma_receipt_rec.new_item_id);
        FETCH get_item_number INTO l_new_item_number;
        CLOSE get_item_number;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_new_item_number:'||l_new_item_number);
        END IF;
        l_serialnum_change_rec.OSP_LINE_ID := l_osp_line_id;
        l_serialnum_change_rec.NEW_ITEM_NUMBER := l_new_item_number;
        l_serialnum_change_rec.NEW_ITEM_REV_NUMBER := p_rma_receipt_rec.NEW_ITEM_REV_NUMBER;
        l_serialnum_change_rec.NEW_LOT_NUMBER := p_rma_receipt_rec.NEW_LOT_NUMBER;
        l_serialnum_change_rec.NEW_SERIAL_NUMBER := p_rma_receipt_rec.NEW_SERIAL_NUMBER;
        l_serialnum_change_rec.NEW_SERIAL_TAG_CODE := p_rma_receipt_rec.NEW_SERIAL_TAG_CODE;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Before calling AHL_OSP_SHIPMENT_PUB.Process_Osp_SerialNum_Change');
        END IF;

        AHL_OSP_SHIPMENT_PUB.Process_Osp_SerialNum_Change
        (
          p_api_version           => 1.0,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          p_serialnum_change_rec  => l_serialnum_change_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'After calling AHL_OSP_SHIPMENT_PUB.Process_Osp_SerialNum_Change');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_return_status: '||l_return_status);
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --Retrieve the new return line id
        OPEN get_oe_line_id(l_osp_line_id);
        FETCH get_oe_line_id INTO l_new_oe_line_id;
        CLOSE get_oe_line_id;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_new_oe_line_id: '||l_new_oe_line_id);
        END IF;

        x_return_line_id := l_new_oe_line_id;

      ELSE
        --Part number change cannot be performed for the return line.
        FND_MESSAGE.Set_Name('AHL','AHL_OSP_CHG_OSPL_INV');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

    ELSIF (l_exchange_flag) THEN
    --Exchange is being performed for the return line
      l_rma_line_canceled := false;
      l_ib_trans_deleted := false;
      IF(l_osp_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE) THEN
        l_osp_order_rec.OSP_ORDER_ID := l_osp_order_id;
        l_osp_order_rec.ORDER_TYPE_CODE := AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE;
        l_osp_order_rec.OBJECT_VERSION_NUMBER := l_osp_ord_obj_ver;
        l_osp_order_rec.OPERATION_FLAG := 'U';

        --Save the OE Return Line information, before deletion
        l_oe_line_rec := OE_LINE_UTIL.QUERY_ROW(p_line_id => p_rma_receipt_rec.RETURN_LINE_ID);
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Queried the OM Line Record');
        END IF;

        /* Convert the Service Order into Exchange Order. All the existing RMA lines will be cancelled if there was no
           receipt performed on any of the lines. */
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Before calling AHL_OSP_ORDERS_PVT.process_osp_order for order conversion');
        END IF;
        AHL_OSP_ORDERS_PVT.process_osp_order(
                p_api_version      => 1.0,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                p_module_type      => NULL,
                p_x_osp_order_rec  => l_osp_order_rec,
                p_x_osp_order_lines_tbl => l_osp_order_lines_tbl,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'After calling AHL_OSP_ORDERS_PVT.process_osp_order for order conversion');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_return_status: '||l_return_status);
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_rma_line_canceled := true;
        --Need to change the order type, if the conversion is indeed successful. Depending on the order type, the serial number/lot
        --number are dervived for receipt.
        l_osp_order_type := AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE;

     ELSE--Existing Order is already an Exchange Order
        --Derive the exchange item properties
        OPEN inv_item_ctrls_csr(p_rma_receipt_rec.EXCHANGE_ITEM_ID, p_rma_receipt_rec.receiving_org_id);
        FETCH inv_item_ctrls_csr INTO l_serial_control_code,l_lot_control_code,l_is_ib_trackable;
        CLOSE inv_item_ctrls_csr;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_serial_control_code:'||l_serial_control_code);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_lot_control_code:'||l_lot_control_code);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_is_ib_trackable:'|| l_is_ib_trackable);
        END IF;
        IF(l_is_ib_trackable = 'Y') THEN
          l_derived_instance_id := null;
          OPEN get_instance_id(p_rma_receipt_rec.EXCHANGE_ITEM_ID,p_rma_receipt_rec.exchange_serial_number);
          FETCH get_instance_id INTO l_derived_instance_id;
          CLOSE get_instance_id;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_derived_instance_id:'||l_derived_instance_id);
          END IF;
        END IF;

        --First compare the exchange_item_id with the item on the return line.
        IF(l_oe_order_line_rec.inventory_item_id = p_rma_receipt_rec.EXCHANGE_ITEM_ID) THEN
          /*
          Note that, even if the item is same, the serial entered by the user may be different from
          the one on the return line. For non-IB tracked items this serial may be matched with the one on the
          oe_lot_serial table. But we are not accounting such differences in the current logic
          */
          --Use the entered serial to derive the instance_id
          IF(l_is_ib_trackable = 'Y') THEN
            OPEN get_osp_order_line_dtls(l_osp_line_id);
            FETCH get_osp_order_line_dtls INTO l_osp_order_line_rec;
            CLOSE get_osp_order_line_dtls;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_line_rec.exchange_instance_id:'||l_osp_order_line_rec.exchange_instance_id);
            END IF;
            IF(nvl(l_derived_instance_id,-1) <> nvl(l_osp_order_line_rec.exchange_instance_id,-1)) THEN
              AHL_OSP_SHIPMENT_PUB.Delete_IB_Transaction(
                p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => p_validation_level,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_oe_line_id            => p_rma_receipt_rec.return_line_id);

                l_ib_trans_deleted := true;
            END IF;
          END IF;--IF(l_is_ib_trackable = 'Y') THEN
        ELSE--item on the oe order line is different from that of the exchange instance entered by the user
          --Cancel the RMA line
          --Save the OE Return Line information, before deletion
          l_oe_line_rec := OE_LINE_UTIL.QUERY_ROW(p_line_id => p_rma_receipt_rec.RETURN_LINE_ID);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Queried the OM Line Record');
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calling the Delete_Cancel_Order');
          END IF;

          l_del_oe_lines_tbl(1) := p_rma_receipt_rec.return_line_id;
          AHL_OSP_SHIPMENT_PUB.Delete_Cancel_Order (
                p_api_version              => 1.0,
                p_init_msg_list            => FND_API.G_FALSE, -- Don't initialize the Message List
                p_commit                   => FND_API.G_FALSE, -- Don't commit independently
                p_oe_header_id             => null,  -- Not deleting the shipment header: Only the lines
                p_oe_lines_tbl             => l_del_oe_lines_tbl,  -- Lines to be deleted/Cancelled
                p_cancel_flag              => FND_API.G_FALSE,  -- Do Deletes if possible, Cancels if not
                x_return_status            => l_return_status ,
                x_msg_count                => l_msg_count ,
                x_msg_data                 => l_msg_data
            );
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from Delete_Cancel_Order, l_return_status = ' || l_return_status);
          END IF;
          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          l_rma_line_canceled := true;
        END IF;--IF(l_oe_order_line_rec.inventory_item_id = p_rma_receipt_rec.EXCHANGE_ITEM_ID) THEN
      END IF;--IF(l_osp_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE) THEN

      --The following holds good for both service orders and exchange orders
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        IF(l_rma_line_canceled) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_rma_line_canceled: true');
        ELSE
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_rma_line_canceled: false');
        END IF;
        IF(l_ib_trans_deleted) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_ib_trans_deleted: true');
        ELSE
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_ib_trans_deleted: false');
        END IF;
      END IF;

      IF(l_rma_line_canceled) THEN
        l_oe_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
        l_oe_lot_serial_tbl := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL;

        /* Create a new RMA Line, corresponding to the receipt */
        l_oe_line_tbl(1) := l_oe_line_rec;
        l_oe_line_tbl(1).inventory_item_id := p_rma_receipt_rec.EXCHANGE_ITEM_ID;
        l_oe_line_tbl(1).line_id := FND_API.G_MISS_NUM;
        l_oe_line_tbl(1).line_number := FND_API.G_MISS_NUM;
        l_oe_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

        IF(p_rma_receipt_rec.EXCHANGE_SERIAL_NUMBER is not NULL OR p_rma_receipt_rec.EXCHANGE_LOT_NUMBER is not NULL) THEN
          --populate the lot_serial_rec
          l_oe_lot_serial_tbl(1).lot_serial_id := FND_API.G_MISS_NUM;
          l_oe_lot_serial_tbl(1).lot_number := p_rma_receipt_rec.exchange_lot_number;
          l_oe_lot_serial_tbl(1).from_serial_number := p_rma_receipt_rec.exchange_serial_number;
          l_oe_lot_serial_tbl(1).quantity := l_oe_line_rec.ordered_quantity;
          l_oe_lot_serial_tbl(1).line_index := 1;
          l_oe_lot_serial_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
        END IF;
        /*Create the new RMA line*/
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call OE_ORDER_GRP.PROCESS_ORDER');
        END IF;

        OE_ORDER_GRP.PROCESS_ORDER(
          p_api_version_number  => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_header_rec          => x_header_rec,
          p_header_val_rec      => x_header_val_rec,
          p_line_tbl            => l_oe_line_tbl,
          p_line_val_tbl        => x_line_val_tbl,
          p_lot_serial_tbl      => l_oe_lot_serial_tbl,
          x_header_rec          => x_header_rec,
          x_header_val_rec      => x_header_val_rec,
          x_Header_Adj_tbl       =>  x_Header_Adj_tbl,
          x_Header_Adj_val_tbl   =>  x_Header_Adj_val_tbl,
          x_Header_price_Att_tbl =>  x_Header_price_Att_tbl,
          x_Header_Adj_Att_tbl   => x_Header_Adj_Att_tbl,
          x_Header_Adj_Assoc_tbl =>  x_Header_Adj_Assoc_tbl,
          x_Header_Scredit_tbl    =>   x_Header_Scredit_tbl,
          x_Header_Scredit_val_tbl =>    x_Header_Scredit_val_tbl,
          x_line_tbl               =>     x_line_tbl      ,
          x_line_val_tbl           =>    x_line_val_tbl ,
          x_Line_Adj_tbl           =>   x_Line_Adj_tbl    ,
          x_Line_Adj_val_tbl       =>  x_Line_Adj_val_tbl,
          x_Line_price_Att_tbl     =>   x_Line_price_Att_tbl,
          x_Line_Adj_Att_tbl       =>  x_Line_Adj_Att_tbl ,
          x_Line_Adj_Assoc_tbl     =>  x_Line_Adj_Assoc_tbl,
          x_Line_Scredit_tbl       => x_Line_Scredit_tbl ,
          x_Line_Scredit_val_tbl   =>  x_Line_Scredit_val_tbl,
          x_Lot_Serial_tbl         => x_Lot_Serial_tbl  ,
          x_Lot_Serial_val_tbl     => x_Lot_Serial_val_tbl   ,
          x_action_request_tbl     => x_action_request_tbl  );

        --populate the return_line_id with the one that was created in the OM API call.
        x_return_line_id := x_line_tbl(1).line_id;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed OE_ORDER_GRP.PROCESS_ORDER, x_return_status = ' || x_return_status);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'x_return_line_id = ' || x_return_line_id);
        END IF;

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FOR i IN 1..x_msg_count LOOP
            OE_MSG_PUB.Get(p_msg_index => i,
                           p_encoded => FND_API.G_FALSE,
                           p_data    => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
            fnd_msg_pub.add_exc_msg(p_pkg_name       => 'OE_ORDER_PUB',
                                    p_procedure_name => 'processOrder',
                                    p_error_text     => substr(l_msg_data,1,240));
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OE:Err Msg '||i||'.' || l_msg_data);
            END IF;

          END LOOP;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /* Update the osp_line with the new RMA line id*/
        OPEN get_same_phyitem_order_lines(l_osp_line_id);
        LOOP
          FETCH get_same_phyitem_order_lines INTO l_same_ser_ospline_id;
          EXIT WHEN get_same_phyitem_order_lines%NOTFOUND;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_same_ser_ospline_id: ' || l_same_ser_ospline_id);
          END IF;
          Update_OSP_Order_Lines(
              p_osp_order_id      => l_osp_order_id,
              p_osp_line_id  => l_same_ser_ospline_id,
              p_oe_ship_line_id   => FND_API.G_MISS_NUM ,
              p_oe_return_line_id => x_return_line_id);
        END LOOP;
        CLOSE get_same_phyitem_order_lines;
      END IF;--IF(l_rma_line_canceled) THEN

      IF(l_is_ib_trackable = 'Y' AND (l_rma_line_canceled OR l_ib_trans_deleted)) THEN
        /* Update the osp_line with the new exchange instance id*/
        OPEN get_same_phyitem_order_lines(l_osp_line_id);
        LOOP
          FETCH get_same_phyitem_order_lines INTO l_same_ser_ospline_id;
          EXIT WHEN get_same_phyitem_order_lines%NOTFOUND;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_same_ser_ospline_id: ' || l_same_ser_ospline_id);
          END IF;
          Update_OSP_Line_Exch_Instance(
             p_osp_order_id      => l_osp_order_id,
             p_osp_line_id       => l_same_ser_ospline_id,
             p_exchange_instance_id  =>  l_derived_instance_id);
        END LOOP;
        CLOSE get_same_phyitem_order_lines;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calling Create_IB_Transaction ' );
        END IF;

        /* Create the new IB transaction */
        AHL_OSP_SHIPMENT_PUB.Create_IB_Transaction(
          p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => p_validation_level,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          p_osp_order_type        => AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE,
          p_oe_line_type          => 'RETURN',
          p_oe_line_id            => nvl(x_return_line_id,p_rma_receipt_rec.return_line_id),
          p_csi_instance_id       => l_derived_instance_id);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return status from Create_IB_Transaction: ' || l_return_status);
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;--IF(l_is_ib_trackable = 'Y' AND (l_rma_line_canceled OR l_ib_trans_deleted)) THEN

    END IF;--IF (l_part_num_change_flag) THEN

    l_return_line_id := nvl(x_return_line_id,p_rma_receipt_rec.return_line_id);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_return_line_id:'||l_return_line_id);
    END IF;

    IF(x_return_line_id is not null) THEN
      --New return line has been created. Retrieve the Return Line details
      OPEN oe_order_line_details_csr(x_return_line_id);
      FETCH oe_order_line_details_csr INTO l_oe_order_line_rec;
      CLOSE oe_order_line_details_csr;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.inventory_item_id:'||l_oe_order_line_rec.inventory_item_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.customer_id:'||l_oe_order_line_rec.customer_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.customer_site_id:'||l_oe_order_line_rec.customer_site_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.organization_id:'||l_oe_order_line_rec.organization_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.subinventory:'||l_oe_order_line_rec.subinventory);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.oe_order_header_id:'||l_oe_order_line_rec.oe_order_header_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_order_line_rec.oe_order_line_id:'||l_oe_order_line_rec.oe_order_line_id);
      END IF;

    END IF;

    --Delete any errored transactions before creating a new receipt.
    OPEN get_err_tranansaction_dtls(p_rma_receipt_rec.RETURN_LINE_ID);
    FETCH get_err_tranansaction_dtls INTO l_err_intf_trans_id,l_err_intf_hdr_id;
    CLOSE get_err_tranansaction_dtls;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_err_intf_trans_id:'||l_err_intf_trans_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_err_intf_hdr_id:'||l_err_intf_hdr_id);
    END IF;

    IF(l_err_intf_trans_id is not NULL) THEN
      --Delete the pending transactions.
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Deleting the pending transactions');
      END IF;

      DELETE FROM PO_INTERFACE_ERRORS
            WHERE INTERFACE_LINE_ID = l_err_intf_trans_id
              AND INTERFACE_HEADER_ID = l_err_intf_hdr_id;

      DELETE FROM MTL_SERIAL_NUMBERS_INTERFACE
            WHERE PRODUCT_TRANSACTION_ID = l_err_intf_trans_id;

      DELETE FROM MTL_TRANSACTION_LOTS_INTERFACE
            WHERE PRODUCT_TRANSACTION_ID = l_err_intf_trans_id;

      DELETE FROM RCV_TRANSACTIONS_INTERFACE
            WHERE INTERFACE_TRANSACTION_ID = l_err_intf_trans_id;

      DELETE FROM RCV_HEADERS_INTERFACE
            WHERE HEADER_INTERFACE_ID = l_err_intf_hdr_id;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Deleted the pending transactions');
      END IF;
    END IF;

    --Initialize the sequences that are to be used.
    SELECT PO.RCV_HEADERS_INTERFACE_S.NEXTVAL INTO l_intf_hdr_id FROM sys.dual;
    SELECT PO.RCV_INTERFACE_GROUPS_S.NEXTVAL INTO l_group_id FROM sys.dual;
    SELECT PO.RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL INTO l_intf_transaction_id from sys.dual;
    SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL INTO l_mtl_transaction_id from sys.dual;

    --select the user related ids
    SELECT FND_GLOBAL.USER_ID INTO l_user_id from sys.dual;
    SELECT FND_GLOBAL.LOGIN_ID INTO l_login_id from sys.dual;
    SELECT FND_GLOBAL.EMPLOYEE_ID INTO l_employee_id from sys.dual;

    --Insert values into the RCV_HEADERS_INTERFACE
    INSERT INTO RCV_HEADERS_INTERFACE
    (
      HEADER_INTERFACE_ID,
      GROUP_ID,
      PROCESSING_STATUS_CODE,
      RECEIPT_SOURCE_CODE,
      TRANSACTION_TYPE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      CUSTOMER_ID,
      CUSTOMER_SITE_ID,
      SHIP_TO_ORGANIZATION_ID,
      AUTO_TRANSACT_CODE,
      EMPLOYEE_ID
    )
    VALUES
    (
      l_intf_hdr_id,                            --HEADER_INTERFACE_ID,
      l_group_id,                               --GROUP_ID,
      'PENDING',                                --PROCESSING_STATUS_CODE,
      'CUSTOMER',                               --RECEIPT_SOURCE_CODE,
      'NEW',                                    --TRANSACTION_TYPE,
      SYSDATE,                                  --LAST_UPDATE_DATE,
      l_user_id,                                --LAST_UPDATED_BY,
      l_login_id,                               --LAST_UPDATE_LOGIN,
      SYSDATE,                                  --CREATION_DATE,
      l_user_id,                                --CREATED_BY,
      l_oe_order_line_rec.customer_id,          --CUSTOMER_ID,
      l_oe_order_line_rec.customer_site_id,     --CUSTOMER_SITE_ID
      l_oe_order_line_rec.organization_id,      --SHIP_TO_ORGANIZATION_ID
      'DELIVER',                                --AUTO_TRANSACT_CODE
      l_employee_id                             --EMPLOYEE_ID
    );

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_intf_hdr_id:'||l_intf_hdr_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_group_id:'||l_group_id);
    END IF;

    INSERT INTO RCV_TRANSACTIONS_INTERFACE
    (
      INTERFACE_TRANSACTION_ID,
      HEADER_INTERFACE_ID,
      GROUP_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      TRANSACTION_TYPE,
      TRANSACTION_DATE,
      PROCESSING_STATUS_CODE,
      PROCESSING_MODE_CODE,
      TRANSACTION_STATUS_CODE,
      QUANTITY,
      AUTO_TRANSACT_CODE,
      RECEIPT_SOURCE_CODE,
      SOURCE_DOCUMENT_CODE,
      VALIDATION_FLAG,
      OE_ORDER_HEADER_ID,
      OE_ORDER_LINE_ID,
      TO_ORGANIZATION_ID,
      SUBINVENTORY,
      LOCATOR_ID,
      INTERFACE_SOURCE_CODE,
      UOM_CODE
    )
    VALUES
    (
      l_intf_transaction_id,                  --INTERFACE_TRANSACTION_ID,
      l_intf_hdr_id,                          --HEADER_INTERFACE_ID,
      l_group_id,                             --GROUP_ID,
      SYSDATE,                                --LAST_UPDATE_DATE,
      l_user_id,                              --LAST_UPDATED_BY,
      SYSDATE,                                --CREATION_DATE,
      l_user_id,                              --CREATED_BY,
      l_login_id,                             --LAST_UPDATE_LOGIN,
      'RECEIVE',                              --TRANSACTION_TYPE,
      p_rma_receipt_rec.receipt_date,         --TRANSACTION_DATE,
      'PENDING',                              --PROCESSING_STATUS_CODE,
      --Modified by mpothuku on 04-Mar-2007 for the Bug 6862891
      'BATCH',                                --PROCESSING_MODE_CODE,
      'PENDING',                              --TRANSACTION_STATUS_CODE,
      p_rma_receipt_rec.receipt_quantity,     --QUANTITY,
      'DELIVER',                              --AUTO_TRANSACT_CODE: 'DELIVER' is needed to ensure delivery of the receipt
      'CUSTOMER',                             --RECEIPT_SOURCE_CODE,
      'RMA',                                  --SOURCE_DOCUMENT_CODE,
      'Y',                                    --VALIDATION_FLAG,
      l_oe_order_line_rec.oe_order_header_id, --OE_ORDER_HEADER_ID,
      l_oe_order_line_rec.oe_order_line_id,   --OE_ORDER_LINE_ID,
      l_oe_order_line_rec.organization_id,    --TO_ORGANIZATION_ID
      p_rma_receipt_rec.receiving_subinventory,--SUBINVENTORY
      p_rma_receipt_rec.receiving_locator_id, --LOCATOR_ID
      'AHL',                                  --INTERFACE_SOURCE_CODE
      p_rma_receipt_rec.receipt_uom_code      --UOM_CODE
    );

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_intf_transaction_id:'||l_intf_transaction_id);
    END IF;

    IF(l_osp_line_id is NULL) THEN
    --The return is being performed for a spare part. Retrieve the lot and serial from the oe_lot_serial record
      OPEN ahl_oe_lot_serial_id_csr(p_rma_receipt_rec.return_line_id);
      FETCH ahl_oe_lot_serial_id_csr INTO l_oe_lot_serial_rec;
      CLOSE ahl_oe_lot_serial_id_csr;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_lot_serial_rec.lot_number:'||l_oe_lot_serial_rec.lot_number);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_oe_lot_serial_rec.serial_number:'||l_oe_lot_serial_rec.serial_number);
      END IF;
    ELSE
      OPEN get_osp_order_line_dtls(l_osp_line_id);
      FETCH get_osp_order_line_dtls INTO l_osp_order_line_rec;
      CLOSE get_osp_order_line_dtls;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_line_rec.inventory_item_id:'
        ||l_osp_order_line_rec.inventory_item_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_line_rec.lot_number:'||l_osp_order_line_rec.lot_number);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_line_rec.serial_number:'||l_osp_order_line_rec.serial_number);
      END IF;
    END IF;

    OPEN inv_item_ctrls_csr(l_oe_order_line_rec.inventory_item_id, p_rma_receipt_rec.receiving_org_id);
    FETCH inv_item_ctrls_csr INTO l_serial_control_code,l_lot_control_code,l_is_ib_trackable;
    CLOSE inv_item_ctrls_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_serial_control_code:'||l_serial_control_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_lot_control_code:'||l_lot_control_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_is_ib_trackable:'|| l_is_ib_trackable);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_osp_order_type:'|| l_osp_order_type);
    END IF;

    IF(l_is_ib_trackable = 'Y') THEN
      OPEN get_IB_subtrns_inst_dtls_csr(l_return_line_id);
      FETCH get_IB_subtrns_inst_dtls_csr INTO l_IB_subtrns_inst_rec;
      CLOSE get_IB_subtrns_inst_dtls_csr;
    END IF;

    IF (l_serial_control_code IN (2,5,6)) THEN
      IF(l_osp_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE) THEN
        --Item is serial controlled
        IF(l_is_ib_trackable = 'Y') THEN
          --Derive the serial number from the instance, which may have undergone serial number changes.
          l_trans_serial_number := l_IB_subtrns_inst_rec.serial_number;
        ELSE
          IF(l_osp_line_id is NULL) THEN
            --For spare parts use the lot serial record
            l_trans_serial_number := l_oe_lot_serial_rec.serial_number;
          ELSE
            --For non-IB tracked serialized items use the serial_number from the osp order line
            l_trans_serial_number := l_osp_order_line_rec.serial_number;
          END IF;
        END IF;--IF(l_is_ib_trackable = 'Y')
      ELSIF(l_osp_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
        IF(l_osp_line_id is NULL) THEN
          l_trans_serial_number := l_oe_lot_serial_rec.serial_number;
        ELSE
          l_trans_serial_number := p_rma_receipt_rec.exchange_serial_number;
        END IF;
      END IF;--IF(l_osp_order_type = 'SERVICE')
    END IF;--IF (l_serial_control_code IN (2,5,6))

    IF (l_lot_control_code = 2) THEN
      IF(l_osp_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE) THEN
        --Item is serial controlled
        IF(l_is_ib_trackable = 'Y') THEN
          --Derive the serial number from the instance, which may have undergone serial number changes.
          l_trans_lot_number := l_IB_subtrns_inst_rec.lot_number;
        ELSE
          IF(l_osp_line_id is NULL) THEN
            --For spare parts use the lot serial record
            l_trans_lot_number := l_oe_lot_serial_rec.lot_number;
          ELSE
            --For non-IB tracked lot controlled items use the serial_number from the osp order line
            l_trans_lot_number := l_osp_order_line_rec.lot_number;
          END IF;
        END IF;--IF(l_is_ib_trackable = 'Y')
      ELSIF(l_osp_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
        IF(l_osp_line_id is NULL) THEN
          l_trans_lot_number := l_oe_lot_serial_rec.lot_number;
        ELSE
          l_trans_lot_number := p_rma_receipt_rec.exchange_lot_number;
        END IF;
      END IF;--IF(l_osp_order_type = 'SERVICE')
    END IF;--IF (l_lot_control_code = 1)

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_trans_serial_number:'||l_trans_serial_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_trans_lot_number:'||l_trans_lot_number);
    END IF;

    IF(l_trans_lot_number is not null) THEN
      INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE
      (
        TRANSACTION_INTERFACE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LOT_NUMBER,
        TRANSACTION_QUANTITY,
        PRIMARY_QUANTITY,
        PRODUCT_CODE,
        PRODUCT_TRANSACTION_ID
      )
      VALUES
      (
        l_mtl_transaction_id,                 --TRANSACTION_INTERFACE_ID,
        SYSDATE,                              --LAST_UPDATE_DATE,
        FND_GLOBAL.USER_ID,                   --LAST_UPDATED_BY,
        SYSDATE,                              --CREATION_DATE,
        FND_GLOBAL.USER_ID,                   --CREATED_BY,
        FND_GLOBAL.LOGIN_ID,                  --LAST_UPDATE_LOGIN,
        l_trans_lot_number,                   --LOT_NUMBER,
        p_rma_receipt_rec.RECEIPT_QUANTITY,   --TRANSACTION_QUANTITY
        p_rma_receipt_rec.RECEIPT_QUANTITY,   --PRIMARY_QUANTITY
        'RCV',                                --PRODUCT_CODE,
        l_intf_transaction_id                 --PRODUCT_TRANSACTION_ID
      );
    END IF;


    IF(l_trans_serial_number is not null) THEN
      INSERT INTO MTL_SERIAL_NUMBERS_INTERFACE
      (
        TRANSACTION_INTERFACE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        FM_SERIAL_NUMBER,
        TO_SERIAL_NUMBER,
        PRODUCT_CODE,
        PRODUCT_TRANSACTION_ID
      )
      VALUES
      (
        l_mtl_transaction_id,           --TRANSACTION_INTERFACE_ID,
        SYSDATE,                        --LAST_UPDATE_DATE,
        FND_GLOBAL.USER_ID,             --LAST_UPDATED_BY,
        SYSDATE,                        --CREATION_DATE,
        FND_GLOBAL.USER_ID,             --CREATED_BY,
        FND_GLOBAL.LOGIN_ID,             --LAST_UPDATE_LOGIN,
        l_trans_serial_number,          --FM_SERIAL_NUMBER,
        l_trans_serial_number,          --TO_SERIAL_NUMBER,
        'RCV',                          --PRODUCT_CODE,
        l_intf_transaction_id           --PRODUCT_TRANSACTION_ID
      );
    END IF;

    l_curr_org_id := MO_GLOBAL.get_current_org_id();
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'l_curr_org_id:'||l_curr_org_id);
    END IF;
    FND_REQUEST.SET_ORG_ID(l_curr_org_id);
    --Invoke the 'Receiving Transaction Processor' Concurrent Program
    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
            application => 'PO',
            program     => 'RVCTP',
            --Modified by mpothuku on 04-Mar-2007 for the Bug 6862891
            argument1   => 'BATCH',  -- mode
            argument2   => l_group_id,  -- group_id
            argument3   => l_curr_org_id  -- Operating Unit (Vision Project Manufacturing USD)
            );

    IF (l_request_id = 0) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Concurrent request failed.');
        END IF;
    ELSE
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Concurrent request successful. Request id: '||l_request_id);
        END IF;
    END IF;

    -- Set the OUT parameter x_request_id with l_req_id.
    x_request_id := l_request_id;

    -- Standard call to get message count and initialise the OUT parameters.
    FND_MSG_PUB.Count_And_Get
    ( p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE
    );

    -- Commit work if p_commit is TRUE.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key || '.end', 'End of the API.'||
                       ' x_request_id: '||x_request_id||
                       ', x_return_line_id: '||x_return_line_id);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Receive_Against_RMA_Pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Receive_Against_RMA_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

    WHEN OTHERS THEN
        ROLLBACK TO Receive_Against_RMA_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);

        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);
END Receive_Against_RMA;


-- Start of Comments --
--  Procedure name   : Validate_Receiving_Params
--  Type             : Private
--  Functionality    : Local helper procedure to validate user entered values. In case of any invalid values,
--                     this API will raise an appropriate exception which will be handled by the calling API.
--  Pre-reqs         :
--
--  Parameters:
--
--  Validate_Receiving_Params Parameters:
--   p_rma_receipt_rec    IN    RMA_Receipt_Rec_Type    RMA receipt record
--
--  Version:
--
--   Initial Version      1.0
--
-- End of Comments --

PROCEDURE Validate_Receiving_Params (
    p_rma_receipt_rec     IN               RMA_Receipt_Rec_Type
) IS

-- Cursor to check whether the given return line is valid or not.
CURSOR chk_return_line (c_oe_line_id NUMBER) IS
SELECT 'X'
  FROM OE_ORDER_LINES_ALL
 WHERE line_id      = c_oe_line_id
   AND line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID');

-- Cursor to check whether the shipment is booked or not.
CURSOR chk_shipment_booked (c_oe_line_id NUMBER) IS
SELECT OHA.header_id
  FROM OE_ORDER_LINES_ALL OLA, OE_ORDER_HEADERS_ALL OHA
 WHERE OLA.line_id     = c_oe_line_id
   AND OHA.header_id   = OLA.header_id
   AND OHA.booked_flag = 'Y';

-- Cursor to get the ship line id of the OSP order lines, that correspond to the given return line.
CURSOR get_osp_ship_line_id (c_oe_return_line_id NUMBER) IS
SELECT oe_ship_line_id
  FROM AHL_OSP_ORDER_LINES
 WHERE oe_return_line_id = c_oe_return_line_id
   AND ROWNUM = 1;

-- Cursor to get the ordered and shipped quantities of the given return line.
CURSOR get_oe_quantities (c_oe_line_id NUMBER) IS
SELECT ordered_quantity, shipped_quantity
  FROM OE_ORDER_LINES_ALL
 WHERE line_id = c_oe_line_id;

-- Cursor to check that the 'ship from org id' is same as the 'receiving org id' for a given return line.
CURSOR chk_org_id (c_oe_line_id NUMBER, c_rcv_org_id NUMBER) IS
SELECT 'X'
  FROM OE_ORDER_LINES_ALL
 WHERE line_id                   = c_oe_line_id
   AND NVL(ship_from_org_id, -1) = c_rcv_org_id;

--
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Receiving_Params';
l_debug_key    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_oe_header_id          OE_ORDER_HEADERS_ALL.header_id%TYPE;
l_oe_ship_line_id       AHL_OSP_ORDER_LINES.oe_ship_line_id%TYPE;
l_oe_ordered_qty        OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_oe_shipped_qty        OE_ORDER_LINES_ALL.shipped_quantity%TYPE;
l_valid_flag            BOOLEAN      := TRUE;
l_part_num_change_flag  BOOLEAN      := FALSE;
l_exchange_flag         BOOLEAN      := FALSE;
l_dummy                 VARCHAR2(1);
l_ship_line_qty_rec     get_oe_quantities%ROWTYPE;
l_return_line_qty_rec   get_oe_quantities%ROWTYPE;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.begin', 'Start of the API.');
    END IF;

    -- Check for necessary/mandatory fields.
    IF (p_rma_receipt_rec.return_line_id IS NULL         OR p_rma_receipt_rec.receiving_org_id IS NULL OR
        p_rma_receipt_rec.receiving_subinventory IS NULL OR p_rma_receipt_rec.receipt_quantity IS NULL OR
        p_rma_receipt_rec.receipt_uom_code IS NULL       OR p_rma_receipt_rec.receipt_date IS NULL) THEN
        -- Add an error message to the FND stack.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Mandatory fields have not been entered.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_COM_REQD_PARAM_MISSING'); -- Required parameter is missing.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;

    -- Check for part number change attributes.
    IF (p_rma_receipt_rec.new_item_id IS NOT NULL OR p_rma_receipt_rec.new_serial_number IS NOT NULL) THEN
        -- Set the l_part_num_change_flag.
        l_part_num_change_flag := TRUE;
    END IF;

    -- Check for exchange attributes.
    IF (p_rma_receipt_rec.exchange_item_id IS NOT NULL OR p_rma_receipt_rec.exchange_serial_number IS NOT NULL OR
        p_rma_receipt_rec.exchange_lot_number IS NOT NULL) THEN
        -- Set the l_exchange_flag.
        l_exchange_flag := TRUE;
    END IF;

    -- Check for the flags l_part_num_change_flag and l_exchange_flag.
    IF (l_part_num_change_flag AND l_exchange_flag) THEN
        -- Add an error message to the FND stack as part number change and exchange cannot be done together.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Part number change and exchange cannot be done together.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_NO_PN_CHG_EXCHG_TGTHR'); -- Part number change and Exchange cannot be done together.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;

    -- Check whether the return line id is valid or not.
    OPEN chk_return_line(p_rma_receipt_rec.return_line_id);
    FETCH chk_return_line INTO l_dummy;
    IF (chk_return_line%NOTFOUND) THEN
        -- Add an error message as the given return line is invalid.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Return line: '||p_rma_receipt_rec.return_line_id||' is invalid.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RMA_LINE_INVALID'); -- Return line is invalid.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;
    CLOSE chk_return_line;

    -- Check whether the shipment is booked or not.
    OPEN chk_shipment_booked(p_rma_receipt_rec.return_line_id);
    FETCH chk_shipment_booked INTO l_oe_header_id;
    IF (chk_shipment_booked%NOTFOUND) THEN
        -- Add an error message as the shipment is not booked.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Shipment order: '||l_oe_header_id||' is not booked.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RMA_SHPMNT_NOT_BKD'); -- Shipment is not booked.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;
    CLOSE chk_shipment_booked;


    -- Get the ship line id of the OSP order lines, that correspond to the given return line.
    OPEN get_osp_ship_line_id(p_rma_receipt_rec.return_line_id);
    FETCH get_osp_ship_line_id INTO l_oe_ship_line_id;
    IF (get_osp_ship_line_id%FOUND) THEN
        -- Add an error message if the ship line id is NULL.
        IF (l_oe_ship_line_id IS NULL) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                               'Ship line id for the return line: '||p_rma_receipt_rec.return_line_id||' is NULL.');
            END IF;

            FND_MESSAGE.set_name('AHL', 'AHL_OSP_SHIP_LINE_NULL'); -- Shipment line does not exist for this return line.
            FND_MSG_PUB.ADD;

            -- Set the l_valid_flag as FALSE.
            l_valid_flag := FALSE;
        ELSE
            -- Get the ordered and shipped quantities of the ship line.
            OPEN get_oe_quantities(l_oe_ship_line_id);
            FETCH get_oe_quantities INTO l_ship_line_qty_rec;
            CLOSE get_oe_quantities;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_debug_key, 'l_oe_ship_line_id: '||l_oe_ship_line_id);
                FND_LOG.string(FND_LOG.level_statement, l_debug_key, 'l_ship_line_qty_rec.shipped_quantity: '||l_ship_line_qty_rec.shipped_quantity);
            END IF;

            -- Shipment should have been done for any receipt to take place. For this, check the shipped quantity.
            -- If the shipped quantity is NULL or zero, it means shipment hasn't been done yet. Add an error message.
            IF (l_ship_line_qty_rec.shipped_quantity IS NULL OR l_ship_line_qty_rec.shipped_quantity = 0) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                                   'Shipment for the return line: '||p_rma_receipt_rec.return_line_id||' has not been done yet.');
                END IF;

                FND_MESSAGE.set_name('AHL', 'AHL_OSP_SHIPMENT_NOT_DONE'); -- Shipping has not been done for the ship line corresponding to this return line.
                FND_MSG_PUB.ADD;

                -- Set the l_valid_flag as FALSE.
                l_valid_flag := FALSE;
            END IF;
        END IF;
    END IF;
    CLOSE get_osp_ship_line_id;

    -- Get the ordered and shipped quantities of the given return line.
    OPEN get_oe_quantities(p_rma_receipt_rec.return_line_id);
    FETCH get_oe_quantities INTO l_return_line_qty_rec;
    CLOSE get_oe_quantities;

    -- Check for the ordered and shipped quantities of the given return line. If the shipped quantity is not less than the
    -- ordered quantity, then it means there is no quantity left to be returned. Add an error message.
    IF NOT (l_return_line_qty_rec.shipped_quantity < l_return_line_qty_rec.ordered_quantity) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Shipped qty is not less than the ordered qty for the return line: '||p_rma_receipt_rec.return_line_id);
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RECEIPT_CMPLT'); -- Receipt is complete for this return line.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;

    -- Check for the receipt date. If it is in future, add an error message.
    IF (TRUNC(p_rma_receipt_rec.receipt_date) > TRUNC(SYSDATE)) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Receipt date: '||p_rma_receipt_rec.receipt_date||' is in future.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RECEIPT_DATE_INVALID'); -- Receipt cannot be done for a future date.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;

    -- Check that the 'ship from org id' is same as the 'receiving org id' for a given return line.
    OPEN chk_org_id(p_rma_receipt_rec.return_line_id, p_rma_receipt_rec.receiving_org_id);
    FETCH chk_org_id INTO l_dummy;
    IF (chk_org_id%NOTFOUND) THEN
        -- Add an error message.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'Receipt org is different from the one set in the return line.');
        END IF;

        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RECEIPT_ORG_INVALID'); -- Receiving organization is different from the one set for the return line.
        FND_MSG_PUB.ADD;

        -- Set the l_valid_flag as FALSE.
        l_valid_flag := FALSE;
    END IF;
    CLOSE chk_org_id;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        IF (l_valid_flag) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.end', 'End of the API.'||
                           ' l_valid_flag is TRUE, no exception raised.');
        ELSE
            FND_LOG.string(FND_LOG.level_procedure, l_debug_key||'.end', 'End of the API.'||
                           ' l_valid_flag is FALSE, exception raised.');
        END IF;
    END IF;

    -- Check l_valid_flag. If FALSE, raise an exception which will be handled in the calling API.
    IF (NOT l_valid_flag) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_debug_key,
                           'As l_valid_flag is FALSE, raising an exception.');
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;
END Validate_Receiving_Params;


--  Procedure name   : Update_OSP_Line_Exch_Instance
--  Type             : Private
--  Functionality    : Local helper procedure to update exchange instance of the osp order lines
--  Pre-reqs         :

PROCEDURE Update_OSP_Line_Exch_Instance(
    p_osp_order_id   IN NUMBER,
    p_osp_line_id    IN NUMBER,
    p_exchange_instance_id   IN NUMBER
)IS


-- Check if the instance is a valid IB instance
-- Also not part of relationship

  CURSOR val_exg_instance_id_csr(p_instance_id IN NUMBER) IS
  SELECT 'x' FROM csi_item_instances csi
   WHERE instance_id = p_instance_id
     AND nvl(csi.active_end_date, sysdate + 1) > sysdate
     AND NOT EXISTS
     (select subject_id
        from csi_ii_relationships
       where subject_id = p_instance_id
         and relationship_type_code = 'COMPONENT-OF'
         and NVL(ACTIVE_START_DATE, SYSDATE - 1) < SYSDATE
         AND NVL(ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE) ;

l_exist VARCHAR2(1);
-- retrieve order line details

 CURSOR ahl_osp_lines_csr(p_osp_id IN NUMBER, p_osp_line_id IN NUMBER) IS

  SELECT  a.OSP_ORDER_LINE_ID,
          a.OBJECT_VERSION_NUMBER,
          a.LAST_UPDATE_DATE,
          a.LAST_UPDATED_BY,
          a.LAST_UPDATE_LOGIN,
          a.OSP_ORDER_ID,
          a.OSP_LINE_NUMBER,
          a.STATUS_CODE,
          a.PO_LINE_TYPE_ID,
          a.SERVICE_ITEM_ID,
          a.SERVICE_ITEM_DESCRIPTION,
          a.SERVICE_ITEM_UOM_CODE,
          a.NEED_BY_DATE,
          a.SHIP_BY_DATE,
          a.PO_LINE_ID,
          a.OE_SHIP_LINE_ID,
          a.OE_RETURN_LINE_ID,
          a.WORKORDER_ID,
          a.OPERATION_ID,
          a.EXCHANGE_INSTANCE_ID,
          a.INVENTORY_ITEM_ID,
          a.INVENTORY_ORG_ID,
          a.SERIAL_NUMBER,
          a.LOT_NUMBER,
          a.INVENTORY_ITEM_UOM,
          a.INVENTORY_ITEM_QUANTITY,
          a.SUB_INVENTORY,
          a.QUANTITY,
          a.ATTRIBUTE_CATEGORY,
          a.ATTRIBUTE1,
          a.ATTRIBUTE2,
          a.ATTRIBUTE3,
          a.ATTRIBUTE4,
          a.ATTRIBUTE5,
          a.ATTRIBUTE6,
          a.ATTRIBUTE7,
          a.ATTRIBUTE8,
          a.ATTRIBUTE9,
          a.ATTRIBUTE10,
          a.ATTRIBUTE11,
          a.ATTRIBUTE12,
          a.ATTRIBUTE13,
          a.ATTRIBUTE14,
          a.ATTRIBUTE15,
          a.PO_REQ_LINE_ID
    FROM AHL_OSP_ORDER_LINES a
    WHERE a.osp_order_id = p_osp_id
      AND a.osp_order_line_id = p_osp_line_id;

--
  l_row_check      VARCHAR2(1):='N';
--
BEGIN

  -- Validate exchange instance
  IF(p_exchange_instance_id is not null) THEN
    OPEN val_exg_instance_id_csr(p_exchange_instance_id);
    FETCH val_exg_instance_id_csr INTO l_exist;
    IF (val_exg_instance_id_csr %NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_OSP_SHIP_COMPONENT');
          FND_MSG_PUB.ADD;
          CLOSE val_exg_instance_id_csr;
          RAISE Fnd_Api.g_exc_error;
    END IF;
    CLOSE val_exg_instance_id_csr;
  END IF;

  FOR l_osp_line_rec IN ahl_osp_lines_csr(p_osp_order_id, p_osp_line_id)
   LOOP
     l_row_check := 'Y';

     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => l_osp_line_rec.OE_SHIP_LINE_ID,
            P_OE_RETURN_LINE_ID        => l_osp_line_rec.OE_RETURN_LINE_ID,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
            P_EXCHANGE_INSTANCE_ID     => p_exchange_instance_id,
            P_INVENTORY_ITEM_ID        => l_osp_line_rec.INVENTORY_ITEM_ID,
            P_INVENTORY_ORG_ID         => l_osp_line_rec.INVENTORY_ORG_ID,
            P_INVENTORY_ITEM_UOM       => l_osp_line_rec.INVENTORY_ITEM_UOM,
            P_INVENTORY_ITEM_QUANTITY  => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
            P_SUB_INVENTORY            => l_osp_line_rec.SUB_INVENTORY,
            P_LOT_NUMBER               => l_osp_line_rec.LOT_NUMBER,
            P_SERIAL_NUMBER            => l_osp_line_rec.SERIAL_NUMBER,
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );
    END LOOP;

    IF l_row_check = 'N' THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_INVALID_LINE_ITEM');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
    END IF;

END Update_OSP_Line_Exch_Instance;


--  Procedure name   : Update_OSP_Order_Lines
--  Type             : Private
--  Functionality    : Local helper procedure to update shipment line id and return line id of the osp order lines
--  Pre-reqs         :

PROCEDURE Update_OSP_Order_Lines(
        p_osp_order_id  IN NUMBER,
        p_osp_line_id   IN NUMBER,
        p_oe_ship_line_id       IN NUMBER,
        p_oe_return_line_id     IN NUMBER
       ) IS
--
 CURSOR ahl_osp_lines_csr(p_osp_id IN NUMBER, p_osp_line_id IN NUMBER) IS
    SELECT  a.OSP_ORDER_LINE_ID,
            a.OBJECT_VERSION_NUMBER,
            a.LAST_UPDATE_DATE,
            a.LAST_UPDATED_BY,
            a.LAST_UPDATE_LOGIN,
            a.OSP_ORDER_ID,
            a.OSP_LINE_NUMBER,
            a.STATUS_CODE,
            a.PO_LINE_TYPE_ID,
            a.SERVICE_ITEM_ID,
            a.SERVICE_ITEM_DESCRIPTION,
            a.SERVICE_ITEM_UOM_CODE,
            a.NEED_BY_DATE,
            a.SHIP_BY_DATE,
            a.PO_LINE_ID,
            a.OE_SHIP_LINE_ID,
            a.OE_RETURN_LINE_ID,
            a.WORKORDER_ID,
            a.OPERATION_ID,
            a.EXCHANGE_INSTANCE_ID,
            a.INVENTORY_ITEM_ID,
            a.INVENTORY_ORG_ID,
            a.SERIAL_NUMBER,
            a.LOT_NUMBER,
            a.INVENTORY_ITEM_UOM,
            a.INVENTORY_ITEM_QUANTITY,
            a.SUB_INVENTORY,
            a.QUANTITY,
            a.ATTRIBUTE_CATEGORY,
            a.ATTRIBUTE1,
            a.ATTRIBUTE2,
            a.ATTRIBUTE3,
            a.ATTRIBUTE4,
            a.ATTRIBUTE5,
            a.ATTRIBUTE6,
            a.ATTRIBUTE7,
            a.ATTRIBUTE8,
            a.ATTRIBUTE9,
            a.ATTRIBUTE10,
            a.ATTRIBUTE11,
            a.ATTRIBUTE12,
            a.ATTRIBUTE13,
            a.ATTRIBUTE14,
            a.ATTRIBUTE15,
            a.PO_REQ_LINE_ID
    FROM AHL_OSP_ORDER_LINES a
    WHERE a.osp_order_id = p_osp_id
      AND a.osp_order_line_id = p_osp_line_id;
--
  l_oe_ship_line_id      NUMBER;
  l_oe_return_line_id    NUMBER;
  l_row_check      VARCHAR2(1):='N';
--
BEGIN

   FOR l_osp_line_rec IN ahl_osp_lines_csr(p_osp_order_id, p_osp_line_id)
  LOOP
     l_row_check := 'Y';
     IF ( p_oe_ship_line_id IS NOT NULL
  AND p_oe_ship_line_id <> FND_API.G_MISS_NUM) THEN
          l_oe_ship_line_id := p_oe_ship_line_id;
     ELSE
          l_oe_ship_line_id := l_osp_line_rec.oe_ship_line_id;
     END IF;

     IF (p_oe_return_line_id IS NOT NULL
  AND p_oe_return_line_id <> FND_API.G_MISS_NUM) THEN
          l_oe_return_line_id := p_oe_return_line_id;
     ELSE
          l_oe_return_line_id := l_osp_line_rec.oe_return_line_id;
     END IF;

     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => l_oe_ship_line_id,
            P_OE_RETURN_LINE_ID        => l_oe_return_line_id,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
            P_EXCHANGE_INSTANCE_ID     => l_osp_line_rec.EXCHANGE_INSTANCE_ID,
            P_INVENTORY_ITEM_ID        => l_osp_line_rec.INVENTORY_ITEM_ID,
            P_INVENTORY_ORG_ID         => l_osp_line_rec.INVENTORY_ORG_ID,
            P_INVENTORY_ITEM_UOM       => l_osp_line_rec.INVENTORY_ITEM_UOM,
            P_INVENTORY_ITEM_QUANTITY  => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
            P_SUB_INVENTORY            => l_osp_line_rec.SUB_INVENTORY,
            P_LOT_NUMBER               => l_osp_line_rec.LOT_NUMBER,
            P_SERIAL_NUMBER            => l_osp_line_rec.SERIAL_NUMBER,
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );
    END LOOP;

    IF l_row_check = 'N' THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_INVALID_LINE_ITEM');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
    END IF;

END Update_OSP_Order_Lines;

END AHL_OSP_RCV_PVT;

/

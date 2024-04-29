--------------------------------------------------------
--  DDL for Package Body AHL_OSP_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_PO_PVT" AS
/* $Header: AHLVOPPB.pls 120.14.12010000.2 2009/08/24 11:10:53 sathapli ship $ */

-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_OSP_PO_PVT';

G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_OSP_PO_PVT';

G_JSP_MODULE        CONSTANT VARCHAR2(30) := 'JSP';

G_PO_APP_CODE       CONSTANT VARCHAR2(2)  := 'PO';
G_PDOI_CODE         CONSTANT VARCHAR2(30) := 'POXPOPDOI';
G_AHL_OSP_PREFIX    CONSTANT VARCHAR2(30) := 'AHL OSP Order ';
G_PROCESS_CODE      CONSTANT VARCHAR2(30) := 'PENDING';
G_ACTION_CODE       CONSTANT VARCHAR2(30) := 'ORIGINAL';
G_DOC_TYPE_CODE     CONSTANT VARCHAR2(30) := 'STANDARD';
G_INCOMPLETE_STATUS CONSTANT VARCHAR2(30) := 'INCOMPLETE';

G_NO_FLAG           CONSTANT VARCHAR2(1)  := 'N';
G_YES_FLAG          CONSTANT VARCHAR2(1)  := 'Y';

-- PO Closed codes
G_PO_CLOSED         CONSTANT VARCHAR2(30) := 'CLOSED';
G_PO_FINALLY_CLOSED CONSTANT VARCHAR2(30) := 'FINALLY CLOSED';
G_PO_OPEN           CONSTANT VARCHAR2(30) := 'OPEN';

-- Default Values for One-time Items
-- Changed default price to zero: jaramana on June 22, 2005
--G_DEFAULT_PRICE     CONSTANT NUMBER       := 0.01;
G_DEFAULT_PRICE     CONSTANT NUMBER       := 0;
G_DEFAULT_CATEGORY  CONSTANT VARCHAR2(30) := 'MISC.MISC';

-- OSP Order Statuses
G_OSP_ENTERED_STATUS    CONSTANT VARCHAR2(30) := 'ENTERED';
G_OSP_SUBMITTED_STATUS  CONSTANT VARCHAR2(30) := 'SUBMITTED';
G_OSP_SUB_FAILED_STATUS CONSTANT VARCHAR2(30) := 'SUBMISSION_FAILED';
G_OSP_PO_CREATED_STATUS CONSTANT VARCHAR2(30) := 'PO_CREATED';
-- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
G_OSP_REQ_SUB_FAILED_STATUS CONSTANT VARCHAR2(30) := 'REQ_SUBMISSION_FAILED';

-- OSP Order Line Statuses
G_OL_PO_CANCELLED_STATUS CONSTANT VARCHAR2(30) := 'PO_CANCELLED';
G_OL_PO_DELETED_STATUS   CONSTANT VARCHAR2(30) := 'PO_DELETED';

-- Log Constants: Transaction Types
G_TXN_TYPE_PO_CREATION  CONSTANT VARCHAR2(30) := 'PO Creation';
G_TXN_TYPE_PO_SYNCH     CONSTANT VARCHAR2(30) := 'PO Synchronization';
G_TXN_TYPE_PO_UPDATE    CONSTANT VARCHAR2(30) := 'PO Update';

-- Log Constants: Document Types
G_DOC_TYPE_OSP          CONSTANT VARCHAR2(30) := 'OSP';
G_DOC_TYPE_PO           CONSTANT VARCHAR2(30) := 'PO';

-- PO Line Types
G_PO_LINE_TYPE_QUANTITY CONSTANT VARCHAR2(30) := 'QUANTITY';
-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

TYPE PO_Header_Rec_Type IS RECORD (
        OSP_ORDER_ID            NUMBER,
        VENDOR_ID               NUMBER,
        VENDOR_SITE_ID          NUMBER,
        BUYER_ID                NUMBER,
        VENDOR_CONTACT_ID       NUMBER -- Added by jaramana on May 27, 2005 to support Inventory Service Order
        );

TYPE PO_Line_Rec_Type IS RECORD (
        OSP_LINE_ID             NUMBER,
        LINE_NUMBER             NUMBER,
        PO_LINE_TYPE_ID         NUMBER,
        ITEM_ID                 NUMBER,
        ITEM_DESCRIPTION        VARCHAR2(240),
        QUANTITY                NUMBER,
        UOM_CODE                VARCHAR2(3),
        NEED_BY_DATE            DATE,
        SHIP_TO_ORG_ID          NUMBER,
        SHIP_TO_LOC_ID          NUMBER
        -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
        , WIP_ENTITY_ID         NUMBER
        , PROJECT_ID            NUMBER
        , TASK_ID               NUMBER
        );

TYPE PO_Line_Tbl_Type IS TABLE OF PO_Line_Rec_Type INDEX BY BINARY_INTEGER;

------------------------------
-- Declare Local Procedures --
------------------------------

  -- Validate OSP Order for PO Header Creation
  PROCEDURE Validate_PO_Header(
     p_po_header_rec IN PO_Header_Rec_Type);

  -- Validate PO Lines
  PROCEDURE Validate_PO_Lines(
     p_po_line_tbl IN PO_Line_Tbl_Type,
     p_osp_order_id IN NUMBER);

  -- Insert a record into the PO_HEADERS_INTERFACE table
  PROCEDURE Insert_PO_Header(
     p_po_header_rec  IN  PO_Header_Rec_Type,
     x_intf_header_id OUT NOCOPY NUMBER,
     x_batch_id       OUT NOCOPY NUMBER);

  -- Inserts records into the PO_LINES_INTERFACE table
  PROCEDURE Insert_PO_Lines(
     p_po_line_tbl    IN PO_Line_Tbl_Type,
     p_intf_header_id IN NUMBER);

  -- Calls the Concurrent Program to Create Purchase Order
  PROCEDURE Call_PDOI_Program(
     p_batch_id   IN  NUMBER,
     x_request_id OUT NOCOPY NUMBER);

  -- Calls the PDOI API directly to Create Purchase Order
  -- TO BE USED FOR DEBUGGING PURPOSE ONLY
  PROCEDURE Call_PDOI_API(
     p_batch_id IN NUMBER);

  -- This Procedure updates AHL_OSP_ORDERS_B with the Batch Id and Request Id
  PROCEDURE Record_OSP_Submission(
     p_osp_order_id IN NUMBER,
     p_batch_id     IN NUMBER,
     p_request_id   IN NUMBER,
     p_intf_hdr_id  IN NUMBER);

  -- This Local Procedure updates OSP Tables with PO Information for one OSP Order
  PROCEDURE Associate_OSP_PO(
     p_osp_order_id IN  NUMBER,
     x_po_header_id OUT NOCOPY NUMBER);

  -- This Procedure updates AHL_OSP_ORDERS_B's PO_HEADER_ID and sets STATUS_CODE to PO_CREATED
  PROCEDURE Set_PO_Header_ID(
     p_osp_order_id IN NUMBER,
     p_po_header_id IN NUMBER);

  -- This Procedure updates AHL_OSP_ORDER_LINES.PO_LINE_ID
  PROCEDURE Set_PO_Line_ID(
     p_osp_order_line_id IN NUMBER,
     p_po_line_id IN NUMBER);

  -- This Procedure updates AHL_OSP_ORDERS_B.STATUS_CODE to SUBMISSION_FAILED
  PROCEDURE Set_Submission_Failed(
     p_osp_order_id IN NUMBER);

  -- This Procedure handles cancelled PO Lines and is Part of PO Synchronization.
  -- This procedure commits its work if p_commit is set to true and
  -- if there were no errors during the execution of this procedure.
  -- It does not check the message list for performing the commit action
  PROCEDURE Handle_Cancelled_PO_Lines(
     p_commit         IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2);

  -- This Procedure handles deleted PO Lines and is Part of PO Synchronization.
  -- This procedure commits its work if p_commit is set to true and
  -- if there were no errors during the execution of this procedure.
  -- It does not check the message list for performing the commit action
  PROCEDURE Handle_Deleted_PO_Lines(
     p_commit         IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2);

  -- This Procedure handles Approved POs and is Part of PO Synchronization.
  -- This procedure commits its work if p_commit is set to true and
  -- if there were no errors during the execution of this procedure.
  -- It does not check the message list for performing the commit action
  PROCEDURE Handle_Approved_POs(
     p_commit         IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2);

  -- This Procedure updates a record of AHL_OSP_ORDERS_B using the table handler.
  -- All updates to this table from this Package should go through this procedure only
  PROCEDURE Update_OSP_Order(
     p_osp_order_id IN NUMBER,
     p_batch_id     IN NUMBER    := NULL,
     p_request_id   IN NUMBER    := NULL,
     p_status_code  IN VARCHAR2  := NULL,
     p_po_header_id IN NUMBER    := NULL,
     p_intf_hdr_id  IN NUMBER    := NULL);

  FUNCTION Get_Item_Price(
     p_osp_line_id IN NUMBER) RETURN NUMBER;

/** The following two procedures Handle_Deleted_PO_Headers and Handle_Deleted_Sales_Orders
  * were added by jaramana on March 31, 2006 to implement the ER 5074660
***/
  -- This Procedure handles deleted PO Headers and is Part of PO Synchronization.
  -- This procedure commits its work if p_commit is set to true and
  -- if there were no errors during the execution of this procedure.
  -- It does not check the message list for performing the commit action
  PROCEDURE Handle_Deleted_PO_Headers(
     p_commit         IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2);

  -- This Procedure handles deleted Sales Orders and is Part of PO Synchronization.
  -- This procedure commits its work if p_commit is set to true and
  -- if there were no errors during the execution of this procedure.
  -- It does not check the message list for performing the commit action
  PROCEDURE Handle_Deleted_Sales_Orders(
     p_commit         IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2);

  --Added by mpothuku on 10-Oct-2007 for fixing the Bug 6436184
  FUNCTION get_charge_account_id
  (
    p_inv_org_id  IN  NUMBER,
    p_item_id IN  NUMBER
  ) RETURN NUMBER;
  --mpothuku End

  -- SATHAPLI::Bug 8583364, 21-Aug-2009
  -- Function to create PO number, if PO numbering is set to 'MANUAL'. Accordingly, returns the created number, or NULL.
  FUNCTION create_manual_PO_Number
  (
    p_org_id       IN NUMBER,
    p_osp_order_id IN NUMBER
  ) RETURN VARCHAR2;

-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

-----------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Create_Purchase_Order
--  Type              : Private
--  Function          : Validates OSP Information and inserts records into PO Interface tables
--                      Launches Concurrent Program to initiate PO creation
--                      Updates OSP table with request id batch id and interface header id
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create_Purchase_Order Parameters:
--      p_osp_order_id                  IN      NUMBER  Required
--         The Id of the OSP Order for which to create the Purchase Order
--      x_batch_id                      OUT     NUMBER              Required
--         Contains the batch id if the concurrent program was launched successfuly.
--      x_request_id                    OUT     NUMBER              Required
--         Contains the concurrent request id if the concurrent program was launched successfuly.
--      x_interface_header_id           OUT     NUMBER              Required
--         Contains the interface header id generated for the po_headers_interface table.
--
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_Purchase_Order
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_osp_order_id          IN            NUMBER    := NULL,  -- Required if Number is not given
    p_osp_order_number      IN            NUMBER    := NULL,  -- Required if Id is not given
    x_batch_id              OUT  NOCOPY   NUMBER,
    x_request_id            OUT  NOCOPY   NUMBER,
    x_interface_header_id   OUT  NOCOPY   NUMBER,
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Create_Purchase_Order';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_Purchase_Order';

  CURSOR l_osp_id_csr(p_osp_order_number IN NUMBER) IS
    SELECT OSP_ORDER_ID
    FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_NUMBER = p_osp_order_number;

  CURSOR l_osp_dtls_csr(p_osp_order_id IN NUMBER) IS
    -- VENDOR_CONTACT_ID added by jaramana on May 27, 2005
    SELECT VENDOR_ID, VENDOR_SITE_ID, PO_AGENT_ID, PO_BATCH_ID, PO_INTERFACE_HEADER_ID, VENDOR_CONTACT_ID
    , STATUS_CODE -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
    FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id;

-- Begin ER 266135 Fix
/*
  CURSOR l_osp_line_dtls_csr(p_osp_order_id IN NUMBER) IS
    SELECT OL.OSP_ORDER_LINE_ID, OL.OSP_LINE_NUMBER, OL.SERVICE_ITEM_ID,
           OL.SERVICE_ITEM_DESCRIPTION, WO.QUANTITY, OL.NEED_BY_DATE,
           OL.SERVICE_ITEM_UOM_CODE, OL.PO_LINE_TYPE_ID,
           BOM.ORGANIZATION_ID, BOM.LOCATION_ID
    FROM AHL_OSP_ORDER_LINES OL, AHL_WORKORDERS_V WO, BOM_DEPARTMENTS BOM
    WHERE OL.OSP_ORDER_ID = p_osp_order_id AND
          WO.WORKORDER_ID = OL.WORKORDER_ID AND
          BOM.DEPARTMENT_ID (+) = WO.DEPARTMENT_ID;
*/
-- Changed by jaramana on May 27, 2005 to support Inventory Service Orders
--  CURSOR l_osp_line_dtls_csr(p_osp_order_id IN NUMBER) IS
--    SELECT OL.OSP_ORDER_LINE_ID, OL.OSP_LINE_NUMBER, OL.SERVICE_ITEM_ID,
--           OL.SERVICE_ITEM_DESCRIPTION, OL.QUANTITY, OL.NEED_BY_DATE,
--           OL.SERVICE_ITEM_UOM_CODE, OL.PO_LINE_TYPE_ID,
---- Changed by jaramana on May 26, 2005 to Fix bug 4393374
----           BOM.ORGANIZATION_ID, BOM.LOCATION_ID
--           WO.ORGANIZATION_ID, BOM.LOCATION_ID
--    FROM AHL_OSP_ORDER_LINES OL, AHL_WORKORDERS_OSP_V WO, BOM_DEPARTMENTS BOM
--    WHERE OL.OSP_ORDER_ID = p_osp_order_id AND
--          WO.WORKORDER_ID = OL.WORKORDER_ID AND
--          BOM.DEPARTMENT_ID (+) = WO.DEPARTMENT_ID;
-- End ER 266135 Fix

-- Changed by jaramana on October 26, 2005 for ER 4544642
  CURSOR l_osp_line_dtls_csr(p_osp_order_id IN NUMBER) IS
    SELECT OL.OSP_ORDER_LINE_ID, OL.OSP_LINE_NUMBER, OL.SERVICE_ITEM_ID,
           OL.SERVICE_ITEM_DESCRIPTION, OL.QUANTITY, OL.NEED_BY_DATE,
           OL.SERVICE_ITEM_UOM_CODE, OL.PO_LINE_TYPE_ID,
/**
           OL.INVENTORY_ORG_ID, BOM.LOCATION_ID
    FROM AHL_OSP_ORDER_LINES OL, AHL_WORKORDERS_OSP_V WO, BOM_DEPARTMENTS BOM
**/
           OL.INVENTORY_ORG_ID, DECODE(OL.WORKORDER_ID, NULL, HAOU.LOCATION_ID, BOM.LOCATION_ID)
           -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
           , WO.WIP_ENTITY_ID
           , WDJ.PROJECT_ID
           , WDJ.TASK_ID
/*
    FROM AHL_OSP_ORDER_LINES OL, AHL_WORKORDERS_OSP_V WO, BOM_DEPARTMENTS BOM, HR_ALL_ORGANIZATION_UNITS HAOU
*/
    -- Changes made by jaramana on December 19, 2005
    -- to improve the performace of this SQL.
    -- Removed reference to AHL_WORKORDERS_OSP_V and instead joined directly with
    -- WIP_DISCRETE_JOBS to get the work order department
    FROM AHL_OSP_ORDER_LINES OL, AHL_WORKORDERS WO, BOM_DEPARTMENTS BOM, HR_ALL_ORGANIZATION_UNITS HAOU, WIP_DISCRETE_JOBS WDJ
    WHERE OL.OSP_ORDER_ID = p_osp_order_id AND
          WO.WORKORDER_ID (+) = OL.WORKORDER_ID AND
/**
          BOM.DEPARTMENT_ID (+) = WO.DEPARTMENT_ID;
**/
/*
          BOM.DEPARTMENT_ID (+) = WO.DEPARTMENT_ID AND
*/
          WDJ.WIP_ENTITY_ID (+) = WO.WIP_ENTITY_ID AND
          BOM.DEPARTMENT_ID (+) = WDJ.OWNING_DEPARTMENT AND
          HAOU.ORGANIZATION_ID = OL.INVENTORY_ORG_ID;

  -- Added by jaramana on June 24, 2005 to get the updated Return to Org
  -- Updated by jaramana on March 20, 2006 to get the Org Location for fixing Bug 5104282
  CURSOR get_return_to_org_csr(p_osp_line_id IN NUMBER) IS
    SELECT oola.ship_from_org_id, HAOU.LOCATION_ID
    FROM oe_order_lines_all oola, ahl_osp_order_lines aool, HR_ALL_ORGANIZATION_UNITS HAOU
    WHERE oola.line_id = aool.oe_return_line_id and
          HAOU.ORGANIZATION_ID = oola.ship_from_org_id and
          aool.osp_order_line_id = p_osp_line_id;

   l_po_header              PO_Header_Rec_Type;
   l_po_line_tbl            PO_Line_Tbl_Type;
   l_intf_hdr_id            NUMBER;
   l_batch_id               NUMBER;
   l_old_batch_id           NUMBER := null;
   l_old_intf_header_id     NUMBER := null;
   l_request_id             NUMBER := 0;
   l_temp_num               NUMBER := 0;
   l_temp_ret_org_id        NUMBER;
   l_temp_ret_org_loc_id    NUMBER;

   -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
   l_curr_status            AHL_OSP_ORDERS_B.STATUS_CODE%TYPE;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Create_Purchase_Order_pvt;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing

  IF FND_API.to_boolean( p_default ) THEN
    -- No special default settings required in this API
    NULL;
  END IF;

  -- Start processing

  -- Create the Header Rec
  IF (p_osp_order_id IS NOT NULL) THEN
    l_po_header.OSP_ORDER_ID := p_osp_order_id;
  ELSE
    -- Convert the Order number to Id
--dbms_output.put_line('Perfoming OSP Order Number to Id conversion');
    OPEN l_osp_id_csr(p_osp_order_number);
    FETCH l_osp_id_csr INTO l_po_header.OSP_ORDER_ID;
    CLOSE l_osp_id_csr;
  END IF;

  OPEN l_osp_dtls_csr(l_po_header.OSP_ORDER_ID);
  FETCH l_osp_dtls_csr INTO l_po_header.VENDOR_ID,
                            l_po_header.VENDOR_SITE_ID,
                            l_po_header.BUYER_ID,
                            l_old_batch_id,  -- For Purging Interface table records
                            l_old_intf_header_id,  -- -do-
                            l_po_header.VENDOR_CONTACT_ID,
                            l_curr_status; -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
  CLOSE l_osp_dtls_csr;
--dbms_output.put_line('Got Header Rec ');
  -- Validate Header
  Validate_PO_Header(l_po_header);
--dbms_output.put_line('Validated Header Rec ');
  -- Create the Lines Table
  OPEN l_osp_line_dtls_csr(p_osp_order_id);
  LOOP
    FETCH l_osp_line_dtls_csr INTO l_po_line_tbl(l_temp_num).OSP_LINE_ID,
                                   l_po_line_tbl(l_temp_num).LINE_NUMBER,
                                   l_po_line_tbl(l_temp_num).ITEM_ID,
                                   l_po_line_tbl(l_temp_num).ITEM_DESCRIPTION,
                                   l_po_line_tbl(l_temp_num).QUANTITY,
                                   l_po_line_tbl(l_temp_num).NEED_BY_DATE,
                                   l_po_line_tbl(l_temp_num).UOM_CODE,
                                   l_po_line_tbl(l_temp_num).PO_LINE_TYPE_ID,
                                   l_po_line_tbl(l_temp_num).SHIP_TO_ORG_ID,
                                   l_po_line_tbl(l_temp_num).SHIP_TO_LOC_ID,
                                   -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
                                   l_po_line_tbl(l_temp_num).WIP_ENTITY_ID,
                                   l_po_line_tbl(l_temp_num).PROJECT_ID,
                                   l_po_line_tbl(l_temp_num).TASK_ID;
    EXIT WHEN l_osp_line_dtls_csr%NOTFOUND;

    -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
          ' Fetching from l_osp_line_dtls_csr. l_temp_num = ' || l_temp_num ||
          ', OSP_LINE_ID = ' || l_po_line_tbl(l_temp_num).OSP_LINE_ID ||
          ', WIP_ENTITY_ID = ' || l_po_line_tbl(l_temp_num).WIP_ENTITY_ID ||
          ', PROJECT_ID = ' || l_po_line_tbl(l_temp_num).PROJECT_ID ||
          ', TASK_ID = ' || l_po_line_tbl(l_temp_num).TASK_ID);
    END IF;

    -- Added by jaramana on June 24, 2005 to get the updated Return to Org.
    -- It will now be possible to change the Warehouse in the return lines of a Shipment.
    -- This change will ensure that the PO Shipment gets this changed Org.
    -- Updated by jaramana on March 20, 2006 for fixing Bug 5104282
    OPEN get_return_to_org_csr(l_po_line_tbl(l_temp_num).OSP_LINE_ID);
    FETCH get_return_to_org_csr INTO l_temp_ret_org_id, l_temp_ret_org_loc_id;
    IF (get_return_to_org_csr%FOUND AND l_temp_ret_org_id IS NOT NULL) THEN
      IF (l_temp_ret_org_id <> l_po_line_tbl(l_temp_num).SHIP_TO_ORG_ID) THEN
        l_po_line_tbl(l_temp_num).SHIP_TO_ORG_ID := l_temp_ret_org_id;
        -- Update the Ship To Location only if the Return To Org is different
        -- from the Line's Inventory Org
        l_po_line_tbl(l_temp_num).SHIP_TO_LOC_ID := l_temp_ret_org_loc_id;
      END IF;
    END IF;
    CLOSE get_return_to_org_csr;

    l_temp_num := l_temp_num + 1;
  END LOOP;
  CLOSE l_osp_line_dtls_csr;
  l_po_line_tbl.DELETE(l_temp_num);  -- Delete the last (null) record
--dbms_output.put_line('Created Lines Table ');
  -- Validate Lines
  Validate_PO_Lines(l_po_line_tbl, l_po_header.OSP_ORDER_ID);
--dbms_output.put_line('Validated Lines Table ');
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
--dbms_output.put_line('no errors : going onto insert into po_headers_interface ');
  -- Insert Row into PO_HEADERS_INTERFACE
  Insert_PO_Header(p_po_header_rec  => l_po_header,
                   x_intf_header_id => l_intf_hdr_id,
                   x_batch_id       => l_batch_id);
--dbms_output.put_line('Inserted row into po_headers_interface. x_intf_header_id = ' || l_intf_hdr_id);
--dbms_output.put_line('x_batch_id = ' || l_batch_id);
  -- Insert rows into PO_LINES_INTERFACE
  Insert_PO_Lines(p_po_line_tbl    => l_po_line_tbl,
                  p_intf_header_id => l_intf_hdr_id);
--dbms_output.put_line('inserted rows into po_lines_interface ');
  -- Purge Error records from prior submission (if any)
  -- Begin Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
  IF (l_old_intf_header_id IS NOT NULL AND l_curr_status = G_OSP_SUB_FAILED_STATUS) THEN
    -- PO Submission had failed earlier
    DELETE FROM PO_INTERFACE_ERRORS WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
    DELETE FROM PO_HEADERS_INTERFACE WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
    DELETE FROM PO_LINES_INTERFACE WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
    DELETE FROM PO_DISTRIBUTIONS_INTERFACE WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
  ELSIF (l_curr_status = G_OSP_REQ_SUB_FAILED_STATUS) THEN
    -- Requisition Submission had failed earlier
    -- Delete from the Errors table first so that the subquery can use po_requisitions_interface_all
    DELETE FROM po_interface_errors
     WHERE INTERFACE_TRANSACTION_ID in
           (SELECT transaction_id
              FROM po_requisitions_interface_all
             WHERE INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME
               AND INTERFACE_SOURCE_LINE_ID = l_po_header.OSP_ORDER_ID);
    DELETE FROM po_requisitions_interface_all
     WHERE INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME
       AND INTERFACE_SOURCE_LINE_ID = l_po_header.OSP_ORDER_ID;
  END IF;
  -- End Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
--dbms_output.put_line('Purged error records ');
  -- Launch Concurrent Program to create PO
--dbms_output.put_line('About to call Concurrent program ');
  Call_PDOI_Program(p_batch_id   => l_batch_id,
                    x_request_id => l_request_id);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Concurrent Program Request Submitted. Request Id = ' || l_request_id);
  END IF;
--dbms_output.put_line('Concurrent Program called. Request Id = ' || l_request_id);
  -- Check if request was submitted without error
  IF (l_request_id = 0) THEN
    -- Add Error Message generated by Concurrent Manager to Message List
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

--dbms_output.put_line('Recording OSP Submission... ');
  -- Update OSP Table with batch id, request id and interface header id
  Record_OSP_Submission(p_osp_order_id => p_osp_order_id,
                        p_batch_id     => l_batch_id,
                        p_request_id   => l_request_id,
                        p_intf_hdr_id  => l_intf_hdr_id);

--dbms_output.put_line('Recorded OSP Submission ');
  -- Set Return parameters
  x_batch_id := l_batch_id;
  x_request_id := l_request_id;
  x_interface_header_id := l_intf_hdr_id;

--dbms_output.put_line('Completed Processing ');
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing. Checking for errors');
  END IF;
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Log this transaction in the Log Table
  AHL_OSP_UTIL_PKG.Log_Transaction(p_trans_type_code    => G_TXN_TYPE_PO_CREATION,
                                   p_src_doc_id         => p_osp_order_id,
                                   p_src_doc_type_code  => G_DOC_TYPE_OSP,
                                   p_dest_doc_id        => l_batch_id,
                                   p_dest_doc_type_code => G_DOC_TYPE_PO);

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
--dbms_output.put_line('About to commit work ');
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

--dbms_output.put_line('About to return from procedure ');
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Create_Purchase_Order_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Create_Purchase_Order_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    ROLLBACK TO Create_Purchase_Order_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_Purchase_Order',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

END Create_Purchase_Order;

----------------------------------------

-- Start of Comments --
--  Procedure name    : Associate_OSP_With_PO
--  Type              : Private
--  Function          : Updates AHL_OSP_ORDERS_B.PO_HEADER_ID and
--                      AHL_OSP_ORDER_LINES.PO_LINE_ID with PO_HEADER_ID and
--                      PO_LINE_ID respectively for a single submitted OSP Order.
--                      Does not give error if the OSP Order is already associated
--                      or if there is no corresponding PO yet.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Associate_New_PO_Lines Parameters:
--      p_osp_order_id                  IN      NUMBER                    Required
--         Id of the OSP Order containing the PO Lines
--      x_po_header_id                  OUT     NUMBER                    Required
--         Id of the associated PO Header if the association succeeded.
--
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Associate_OSP_With_PO
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_osp_order_id          IN            NUMBER,
    x_po_header_id          OUT  NOCOPY   NUMBER,
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2) IS

  CURSOR l_validate_osp_csr(p_osp_order_id IN NUMBER) IS
    SELECT PO_HEADER_ID FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id;
-- Don't throw error based on status
--      AND STATUS_CODE = G_OSP_SUBMITTED_STATUS;

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Associate_OSP_With_PO';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Associate_OSP_With_PO';
   l_dummy                  VARCHAR2(1);
   l_po_header_id           NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Associate_OSP_With_PO_pvt;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_boolean( p_default ) THEN
    -- No special default settings required in this API
    NULL;
  END IF;

--dbms_output.put_line('Beginning Processing...  ');
  -- Validate OSP Order Id
  IF (p_osp_order_id IS NULL OR p_osp_order_id = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
--dbms_output.put_line('OSP Order Id is null');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    OPEN l_validate_osp_csr(p_osp_order_id);
    FETCH l_validate_osp_csr INTO l_po_header_id;
    IF (l_validate_osp_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_INVALID');
      FND_MESSAGE.Set_Token('OSP_ID', p_osp_order_id);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      CLOSE l_validate_osp_csr;
--dbms_output.put_line('OSP Order Id ' || p_osp_order_id || ' is invalid');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_po_header_id IS NOT NULL) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Order Id ' || p_osp_order_id || ' is already associated with PO ' || l_po_header_id);
      END IF;
--dbms_output.put_line('OSP Order Id ' || p_osp_order_id || ' is already associated with PO ' || l_po_header_id);
      -- No need to throw an exception
      /*
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_PO_HDR_ASSCTD');
      FND_MESSAGE.Set_Token('OSP_ID', p_osp_order_id);
      FND_MSG_PUB.ADD;
      CLOSE l_validate_osp_csr;
      RAISE FND_API.G_EXC_ERROR;
      */
    ELSE
      -- Make the association
--dbms_output.put_line('About to Make Association ');
      Associate_OSP_PO(p_osp_order_id => p_osp_order_id,
                       x_po_header_id => x_po_header_id);
--dbms_output.put_line('Completed Making Association ');
    END IF;
    CLOSE l_validate_osp_csr;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing. Checking for errors');
  END IF;
--dbms_output.put_line('Completed Processing. Checking for errors ');
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
--dbms_output.put_line('About to commit');
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to commit');
    END IF;
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
--dbms_output.put_line('About to return ');
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Associate_OSP_With_PO_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Associate_OSP_With_PO_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
   ROLLBACK TO Associate_OSP_With_PO_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Associate_OSP_With_PO',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Associate_OSP_With_PO;

----------------------------------------

-- Start of Comments --
--  Procedure name    : Associate_All_OSP_POs
--  Type              : Private
--  Function          : Updates AHL_OSP_ORDERS_B.PO_HEADER_ID and
--                      AHL_OSP_ORDER_LINES.PO_LINE_ID with PO_HEADER_ID and
--                      PO_LINE_ID respectively for all submitted OSP Orders.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Associate_All_OSP_POs
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2) IS

  CURSOR l_get_osps_csr IS
    SELECT OSP_ORDER_ID FROM AHL_OSP_ORDERS_B
    WHERE STATUS_CODE = G_OSP_SUBMITTED_STATUS
      AND PO_HEADER_ID IS NULL
      AND PO_BATCH_ID IS NOT NULL
      -- Added by jaramana on April 7, 2008 for bug 6609988
      AND OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id();

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Associate_All_OSP_POs';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Associate_All_OSP_POs';
   l_dummy                  VARCHAR2(1);
   l_osp_order_id           NUMBER;
   l_po_header_id           NUMBER;
   l_temp_count             NUMBER := 0;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Associate_All_OSP_POs_pvt;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_boolean( p_default ) THEN
    -- No special default settings required in this API
    NULL;
  END IF;

  -- Start processing
  OPEN l_get_osps_csr;
  LOOP
    FETCH l_get_osps_csr INTO l_osp_order_id;
    EXIT WHEN l_get_osps_csr%NOTFOUND;
    Associate_OSP_PO(p_osp_order_id => l_osp_order_id,
                     x_po_header_id => l_po_header_id);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Associated OSP Order with Id ' || l_osp_order_id || ' to PO with Id ' || l_po_header_id);
    END IF;
    l_temp_count := l_temp_count + 1;
  END LOOP;
  --Added by jaramana on 7-JAN-2008
  CLOSE l_get_osps_csr;
  --jaramana End
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Associated ' || l_temp_count || ' OSP Orders with POs');
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing. Checking for errors');
  END IF;
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to COMMIT work.');
    END IF;
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Associate_All_OSP_POs_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Associate_All_OSP_POs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
   ROLLBACK TO Associate_All_OSP_POs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Associate_All_OSP_POs',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Associate_All_OSP_POs;

-- Start of Comments --
--  Procedure name    : PO_Synch_All_OSPs
--  Type              : Private
--  Function          : Synchronizes all OSPs based on the PO Status
--                      1. Handles successfully completed PO Submissions (Updates OSP tables)
--                      2. Handles failed PO Submissions (Updates OSP Status)
--                      3. Handles cancelled PO Lines (Updates OSP Line status, delete shipments)
--                      4. Handles deleted PO Lines  (Updates OSP Line status, delete shipments)
--                      5. Handles Approved POs (Books Shipment, notifies shipper?)
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  PO_Synch_All_OSPs Parameters:
--      p_concurrent_flag               IN      VARCHAR2     Default  N.
--        Writes debug Information to Concurrent Program's Log File if set to 'Y'
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE PO_Synch_All_OSPs
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_concurrent_flag       IN            VARCHAR2  := 'N',
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'PO_Synch_All_OSPs';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.PO_Synch_All_OSPs';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure. Operating Unit = ' || MO_GLOBAL.get_current_org_id());
  END IF;

  -- No need of a Savepoint: Individual procedures commit or rollback
  -- within themselves.
  -- Standard start of API savepoint
  --SAVEPOINT PO_Synch_All_OSPs_pvt;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_boolean( p_default ) THEN
    -- No special default settings required in this API
    NULL;
  END IF;

  -- Start processing
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Starting PO Synch process...');
  END IF;

  -- First make all associations (PO Header Id, PO Line Id, Status updates)
  ASSOCIATE_ALL_OSP_POs(p_api_version   => 1.0,
                        p_commit        => p_commit,  --Commit this independent of other operations
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Associating OSPs with POs');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Associating OSPs with POs, Return Status = ' || x_return_status);
  END IF;

  /** The following calls to the Handle_Deleted_PO_Headers and Handle_Deleted_Sales_Orders
    * procedures were added by jaramana on March 31, 2006 to implement the ER 5074660
  ***/
  -- Handle Deleted PO Headers
  HANDLE_DELETED_PO_HEADERS(p_commit        => p_commit,  --Commit this independent of other operations
                            x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Deleted PO Headers');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Deleted PO Headers, Return Status = ' || x_return_status);
  END IF;

  -- Handle Deleted Sales Orders
  HANDLE_DELETED_SALES_ORDERS(p_commit        => p_commit,  --Commit this independent of other operations
                              x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Deleted Sales Orders');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Deleted Sales Orders, Return Status = ' || x_return_status);
  END IF;

  -- Handle Canceled POs
  HANDLE_CANCELLED_PO_LINES(p_commit        => p_commit,   --Commit this independent of other operations
                            x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Cancelled PO Lines');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Cancelled PO Lines, Return Status = ' || x_return_status);
  END IF;

  -- Handle Deleted PO Lines
  HANDLE_DELETED_PO_LINES(p_commit        => p_commit,  --Commit this independent of other operations
                          x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Deleted PO Lines');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Deleted PO Lines, Return Status = ' || x_return_status);
  END IF;

  -- Handle Approved POs
  HANDLE_APPROVED_POs(p_commit        => p_commit,  --Commit this independent of other operations
                      x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Approved POs');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Approved POs, Return Status = ' || x_return_status);
  END IF;

  -- Begin Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing Purchase Orders. About to start processing Requisitions.');
  END IF;
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed PO Synch Process. About to start processing Requisitions by calling AHL_OSP_PO_REQ_PVT.PO_Synch_All_Requisitions.');
  END IF;
  AHL_OSP_PO_REQ_PVT.PO_Synch_All_Requisitions(p_api_version      => 1.0,
                                               p_init_msg_list    => FND_API.G_FALSE,
                                               p_commit           => p_commit, --Commit this independent of other operations
                                               p_validation_level => p_validation_level,
                                               p_default          => p_default,
                                               p_module_type      => p_module_type,
                                               p_concurrent_flag  => p_concurrent_flag,
                                               x_return_status    => x_return_status,
                                               x_msg_count        => x_msg_count,
                                               x_msg_data         => x_msg_data);

  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed processing Requisitions.');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from AHL_OSP_PO_REQ_PVT.PO_Synch_All_Requisitions, Return Status = ' || x_return_status);
  END IF;
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'AHL_OSP_PO_REQ_PVT.PO_Synch_All_Requisitions Did not succeed');
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;  -- Rollback and return error
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;  -- Rollback and return error
    END IF;
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing Requisitions. About to check for errors.');
  END IF;
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Requisition Synch Process. Checking for errors');
  END IF;
  -- End changes by jaramana on January 7, 2008 for the Requisition ER 6034236
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;  --Note that commit might already have taken place
  END IF;

  -- Standard check of p_commit
-- No need to commit: Individual procedures commit or rollback
-- within themselves.
--  IF FND_API.TO_BOOLEAN(p_commit) THEN
--      COMMIT WORK;   --Note that commit might already have taken place
--  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
-- No need to rollback: Individual procedures commit or rollback
-- within themselves.
--   ROLLBACK TO PO_Synch_All_OSPs_pvt;  --Note that commit might already have taken place
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Caught Execution Exception: ' || x_msg_data);
  END IF;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Caught Execution Exception: ' || x_msg_data);
  END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- No need to rollback: Individual procedures commit or rollback
-- within themselves.
--   ROLLBACK TO PO_Synch_All_OSPs_pvt;  --Note that commit might already have taken place
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Caught Unexpected Exception: ' || x_msg_data);
  END IF;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Caught Unexpected Exception: ' || x_msg_data);
  END IF;

 WHEN OTHERS THEN
-- No need to rollback: Individual procedures commit or rollback
-- within themselves.
--   ROLLBACK TO PO_Synch_All_OSPs_pvt;  --Note that commit might already have taken place
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'PO_Synch_All_OSPs',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Caught Unknown Exception: ' || x_msg_data);
  END IF;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Caught Unknown Exception: ' || x_msg_data);
  END IF;

END PO_Synch_All_OSPs;
--------------------------------------
-- End Public Procedure Definitions --
--------------------------------------

----------------------------------------
-- Public Function Definitions follow --
----------------------------------------

----------------------------------------
-- This function determines if the specified Purchase Order is closed
----------------------------------------
FUNCTION Is_PO_Closed(p_po_header_id IN NUMBER) RETURN VARCHAR2 IS

  --Modified by mpothuku on 16-Nov-06 for fixing the Bug 5673483
  CURSOR l_get_po_cstatus_csr(p_po_header_id IN NUMBER) IS
    SELECT NVL(CLOSED_CODE, G_PO_OPEN), NVL(CANCEL_FLAG, 'N') FROM PO_HEADERS_ALL
    WHERE PO_HEADER_ID = p_po_header_id;

   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Is_PO_Closed';
   l_closed_status  VARCHAR2(30);
   l_cancel_flag    VARCHAR2(1);

BEGIN
  IF (p_po_header_id IS NULL OR p_po_header_id = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_PO_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RETURN 'N';
  END IF;
  OPEN l_get_po_cstatus_csr(p_po_header_id);
  FETCH l_get_po_cstatus_csr INTO l_closed_status,l_cancel_flag;
  IF (l_get_po_cstatus_csr%NOTFOUND) THEN
  --Modified by mpothuku on 16-Nov-06 for fixing the Bug 5673483
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_PO_ID_INVALID');
    FND_MESSAGE.Set_Token('PO_ID', p_po_header_id);
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    --This would mean that the PO is deleted from PO forms and we may need to do a Synch
    CLOSE l_get_po_cstatus_csr;
    RETURN 'N';
  END IF;
  CLOSE l_get_po_cstatus_csr;
  IF ((l_closed_status = G_PO_CLOSED) OR (l_closed_status = G_PO_FINALLY_CLOSED) OR (l_cancel_flag = 'Y')) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
END Is_PO_Closed;

----------------------------------------
-- This function determines if the specified OSP Order has any new PO Line
----------------------------------------
FUNCTION Has_New_PO_Line(p_osp_order_id IN NUMBER) RETURN VARCHAR2 IS
  CURSOR l_get_new_po_line_csr(p_osp_order_id IN NUMBER) IS
    SELECT PL.PO_LINE_ID
    FROM PO_LINES_ALL PL, AHL_OSP_ORDERS_B OSP
    WHERE PL.PO_HEADER_ID = OSP.PO_HEADER_ID AND
          OSP.OSP_ORDER_ID = p_osp_order_id AND
          NVL(PL.CANCEL_FLAG, 'N') <> 'Y' AND
          PL.PO_LINE_ID NOT IN (SELECT PO_LINE_ID from AHL_OSP_ORDER_LINES
                                WHERE OSP_ORDER_ID = p_osp_order_id);
  l_po_line_id NUMBER;

BEGIN
  OPEN l_get_new_po_line_csr(p_osp_order_id);
  FETCH l_get_new_po_line_csr INTO l_po_line_id;
  IF (l_get_new_po_line_csr%NOTFOUND) THEN
    -- No new PO Line
    CLOSE l_get_new_po_line_csr;
    RETURN 'N';
  ELSE
    -- Has new PO Line(s)
    CLOSE l_get_new_po_line_csr;
    RETURN 'Y';
  END IF;
END Has_New_PO_Line;

-------------------------------------
-- End Public Function Definitions --
-------------------------------------

----------------------------------------
-- Local Procedure Definitions follow --
----------------------------------------

----------------------------------------
-- This Procedure validates the OSP Order for PO Header Creation
----------------------------------------
PROCEDURE Validate_PO_Header(
   p_po_header_rec IN PO_Header_Rec_Type) IS

  CURSOR l_validate_osp_csr(p_osp_order_id IN NUMBER) IS
    SELECT 'x' FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id
-- The following condition commented out by jaramana on request of jeli
-- on May 27, 2005 so that status update can be done later.
      -- AND STATUS_CODE = G_OSP_SUBMITTED_STATUS
      FOR UPDATE OF PO_BATCH_ID, PO_REQUEST_ID;  -- Lock Row

  CURSOR l_validate_supplier_csr(p_supplier_id IN NUMBER) IS
    SELECT 'x' FROM PO_VENDORS_VIEW
    WHERE VENDOR_ID = p_supplier_id
      AND ENABLED_FLAG = G_YES_FLAG
      AND NVL(VENDOR_START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
      AND NVL(VENDOR_END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE;

  CURSOR l_validate_supp_site_csr(p_supp_site_id IN NUMBER,
                                  p_supp_id      IN NUMBER) IS
    SELECT 'x' FROM PO_VENDOR_SITES
    WHERE VENDOR_SITE_ID = p_supp_site_id
    AND   VENDOR_ID = p_supp_id
    AND   NVL(INACTIVE_DATE, SYSDATE + 1) > SYSDATE
    AND   NVL(RFQ_ONLY_SITE_FLAG, G_NO_FLAG) = G_NO_FLAG
    AND   PURCHASING_SITE_FLAG = G_YES_FLAG;
    -- NOTE: Organization filtering is done by the PO_VENDOR_SITES view itself

  -- Added by jaramana on May 27, 2005 for Inventory Service Order
  CURSOR l_validate_vendor_contact_csr(p_vendor_contact_id IN NUMBER,
                                       p_supp_site_id      IN NUMBER) IS
    SELECT 'x' FROM PO_VENDOR_CONTACTS
    WHERE VENDOR_CONTACT_ID = p_vendor_contact_id
    AND   VENDOR_SITE_ID = p_supp_site_id;
    -- May have to check INACTIVE_DATE > SYSDATE also?

  CURSOR l_validate_buyer_csr(p_buyer_id IN NUMBER) IS
    SELECT 'x' FROM PO_AGENTS_NAME_V
    WHERE BUYER_ID = p_buyer_id;
    -- NOTE: Effective Date filtering is done by the PO_AGENTS_NAME_V view itself

  l_dummy       VARCHAR2(1);
  l_temp_count  NUMBER;
  l_org_id      NUMBER := NULL;
  L_DEBUG_KEY   CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_PO_Header';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- OSP Order Id
  IF (p_po_header_rec.OSP_ORDER_ID IS NULL OR p_po_header_rec.OSP_ORDER_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_osp_csr(p_po_header_rec.OSP_ORDER_ID);
    FETCH l_validate_osp_csr INTO l_dummy;
    IF (l_validate_osp_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_INVALID');
      FND_MESSAGE.Set_Token('OSP_ID', p_po_header_rec.OSP_ORDER_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_osp_csr;
  END IF;

  -- Supplier
  IF (p_po_header_rec.VENDOR_ID IS NULL OR p_po_header_rec.VENDOR_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SUPPLIER_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_supplier_csr(p_po_header_rec.VENDOR_ID);
    FETCH l_validate_supplier_csr INTO l_dummy;
    IF (l_validate_supplier_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SUPP_INVALID');
      FND_MESSAGE.Set_Token('SUPP_ID', p_po_header_rec.VENDOR_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_supplier_csr;
  END IF;

  -- Supplier Site
  IF (p_po_header_rec.VENDOR_SITE_ID IS NULL OR p_po_header_rec.VENDOR_SITE_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SSITE_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_supp_site_csr(p_po_header_rec.VENDOR_SITE_ID, p_po_header_rec.VENDOR_ID);
    FETCH l_validate_supp_site_csr INTO l_dummy;
    IF (l_validate_supp_site_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SSITE_INVALID');
      FND_MESSAGE.Set_Token('SS_ID', p_po_header_rec.VENDOR_SITE_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_supp_site_csr;
  END IF;

  -- Added by jaramana on May 27, 2005 for Inventory Service Order
  -- Vendor Contact (Optional)
  IF (p_po_header_rec.VENDOR_CONTACT_ID IS NOT NULL AND p_po_header_rec.VENDOR_CONTACT_ID <> FND_API.G_MISS_NUM) THEN
    OPEN l_validate_vendor_contact_csr(p_po_header_rec.VENDOR_CONTACT_ID, p_po_header_rec.VENDOR_SITE_ID);
    FETCH l_validate_vendor_contact_csr INTO l_dummy;
    IF (l_validate_vendor_contact_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_VCONTACT_INVALID');
      FND_MESSAGE.Set_Token('V_CONTACT_ID', p_po_header_rec.VENDOR_CONTACT_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_vendor_contact_csr;
  END IF;
  -- End Change for Inventory Service Order

  -- Buyer
  IF (p_po_header_rec.BUYER_ID IS NULL OR p_po_header_rec.BUYER_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_BUYER_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_buyer_csr(p_po_header_rec.BUYER_ID);
    FETCH l_validate_buyer_csr INTO l_dummy;
    IF (l_validate_buyer_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_BUYER_INVALID');
      FND_MESSAGE.Set_Token('BUYER_ID', p_po_header_rec.BUYER_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_buyer_csr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Validate_PO_Header;

----------------------------------------
-- This Procedure validates the PO Lines
----------------------------------------
PROCEDURE Validate_PO_Lines(
   p_po_line_tbl  IN PO_Line_Tbl_Type,
   p_osp_order_id IN NUMBER) IS

  CURSOR l_validate_item_csr(p_item_id IN NUMBER,
                             p_org_id  IN NUMBER) IS
    SELECT 'x' FROM MTL_SYSTEM_ITEMS_KFV
    WHERE INVENTORY_ITEM_ID = p_item_id
      AND ENABLED_FLAG = G_YES_FLAG
      AND PURCHASING_ENABLED_FLAG = G_YES_FLAG
      AND INVENTORY_ITEM_FLAG = G_NO_FLAG -- No Physical Items
      AND NVL(START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
      AND NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE
      AND ORGANIZATION_ID = p_org_id
      AND NVL(OUTSIDE_OPERATION_FLAG, G_NO_FLAG) = G_NO_FLAG;

  CURSOR l_validate_line_type_csr(p_line_type_id IN NUMBER) IS
    SELECT 'x' FROM PO_LINE_TYPES
    WHERE ORDER_TYPE_LOOKUP_CODE = G_PO_LINE_TYPE_QUANTITY
    AND NVL(OUTSIDE_OPERATION_FLAG, G_NO_FLAG) = G_NO_FLAG
    AND LINE_TYPE_ID = p_line_type_id;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_PO_Lines';
  l_org_id    NUMBER := NULL;
  l_dummy     VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the current Org
  l_org_id := MO_GLOBAL.get_current_org_id();

  IF (l_org_id IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_ORG_NOT_SET');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --dbms_output.put_line('p_po_line_tbl.COUNT = ' || p_po_line_tbl.COUNT);
  -- Non zero count
  IF (p_po_line_tbl.COUNT = 0) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_NO_PO_LINES');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RETURN;  -- Cannot do any further validation
  END IF;

  FOR i IN p_po_line_tbl.FIRST..p_po_line_tbl.LAST LOOP
    -- Item
    IF (p_po_line_tbl(i).ITEM_ID IS NOT NULL AND p_po_line_tbl(i).ITEM_ID <> FND_API.G_MISS_NUM) THEN
      -- Non One-time Item
      -- Changed by jaramana on May 26, 2005 to fix Bug 4393374
      -- OPEN l_validate_item_csr(p_po_line_tbl(i).ITEM_ID, l_org_id);
      OPEN l_validate_item_csr(p_po_line_tbl(i).ITEM_ID, p_po_line_tbl(i).SHIP_TO_ORG_ID);
      FETCH l_validate_item_csr INTO l_dummy;
      IF (l_validate_item_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_ITEM_INVALID');
        FND_MESSAGE.Set_Token('ITEM', p_po_line_tbl(i).ITEM_ID);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
      CLOSE l_validate_item_csr;
    ELSE
      -- One-time Item: Description is mandatory
      IF (TRIM(p_po_line_tbl(i).ITEM_DESCRIPTION) IS NULL OR p_po_line_tbl(i).ITEM_DESCRIPTION = FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_IDESC_NULL');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
      -- One-time Item: UOM is mandatory
      IF (TRIM(p_po_line_tbl(i).UOM_CODE) IS NULL OR p_po_line_tbl(i).UOM_CODE = FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_UOM_CODE_NULL');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
    END IF;

    -- Quantity
    IF (p_po_line_tbl(i).QUANTITY IS NULL OR p_po_line_tbl(i).QUANTITY = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_QUANTITY_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      IF (p_po_line_tbl(i).QUANTITY <= 0) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_QUANTITY_INVALID');
        FND_MESSAGE.Set_Token('QUANTITY', p_po_line_tbl(i).QUANTITY);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
    END IF;

    -- Need By Date
    IF (p_po_line_tbl(i).NEED_BY_DATE IS NULL OR p_po_line_tbl(i).NEED_BY_DATE = FND_API.G_MISS_DATE) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_NEED_BY_DATE_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      IF (TRUNC(p_po_line_tbl(i).NEED_BY_DATE) < TRUNC(SYSDATE)) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_NBDATE_INVALID');
        FND_MESSAGE.Set_Token('NBDATE', p_po_line_tbl(i).NEED_BY_DATE);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
    END IF;

    -- Ship To Organization
    IF (p_po_line_tbl(i).SHIP_TO_ORG_ID IS NULL OR p_po_line_tbl(i).SHIP_TO_ORG_ID = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SHIP_TO_ORG_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;

    -- Commented out by jaramana on May 27, 2005 for Inventory Service Orders.
    -- For Inventory based OSP Lines, it will not be possible to get this location.
    -- For workorder based lines, we get this from the workorder Department.
    -- Need to check if this field is mandatory for PO creation.
    -- Ship To Location
/***
    IF (p_po_line_tbl(i).SHIP_TO_LOC_ID IS NULL OR p_po_line_tbl(i).SHIP_TO_LOC_ID = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SHIP_TO_LOC_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
***/
    -- Line Type
    IF (p_po_line_tbl(i).PO_LINE_TYPE_ID IS NULL OR p_po_line_tbl(i).PO_LINE_TYPE_ID = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_LN_TYPE_ID_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      OPEN l_validate_line_type_csr(p_po_line_tbl(i).PO_LINE_TYPE_ID);
      FETCH l_validate_line_type_csr INTO l_dummy;
      IF (l_validate_line_type_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_LN_TYPE_ID_INVALID');
        FND_MESSAGE.Set_Token('LINE_TYPE_ID', p_po_line_tbl(i).PO_LINE_TYPE_ID);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
      CLOSE l_validate_line_type_csr;
    END IF;

  END LOOP;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Validate_PO_Lines;

----------------------------------------
-- This Procedure inserts a record into the PO_HEADERS_INTERFACE table
----------------------------------------
PROCEDURE Insert_PO_Header(
   p_po_header_rec  IN  PO_Header_Rec_Type,
   x_intf_header_id OUT NOCOPY NUMBER,
   x_batch_id       OUT NOCOPY NUMBER) IS

  CURSOR l_get_osp_order_dtls_csr(p_osp_order_id IN NUMBER) IS
    SELECT OSP_ORDER_NUMBER, DESCRIPTION FROM AHL_OSP_ORDERS_VL
    WHERE OSP_ORDER_ID = p_osp_order_id;

  l_description            VARCHAR2(256);
  l_OSP_description        VARCHAR2(256) := NULL;
  l_interface_src_code     VARCHAR2(30);
  l_intf_hdr_id            NUMBER;
  l_batch_id               NUMBER;
  l_currency_code          VARCHAR2(15) := NULL;
  l_temp_n                 NUMBER := 0;
  l_temp_v                 VARCHAR2(240) := NULL;
  l_curr_org_id            NUMBER;
  l_manual_po_number       PO_HEADERS_INTERFACE.DOCUMENT_NUM%TYPE := NULL;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Insert_PO_Header';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Get Batch Id
/*
  SELECT NVL(MAX(batch_id), 0) + 1 INTO l_batch_id FROM po_headers_interface;
*/
   -- Changes made by jaramana on December 19, 2005
   -- to improve the performace of this SQL by removing the Full Index Scan
   -- Since batch_id is optional, no need to get it using the max value.
   -- Instead, hard code it to the OSP Order Id
   l_batch_id := p_po_header_rec.OSP_ORDER_ID;

  -- Generate PO Header Id
  SELECT PO_HEADERS_INTERFACE_S.NEXTVAL INTO l_intf_hdr_id FROM sys.dual;

  -- Description
  OPEN l_get_osp_order_dtls_csr(p_po_header_rec.OSP_ORDER_ID);
  FETCH l_get_osp_order_dtls_csr INTO l_temp_n, l_OSP_description;
  CLOSE l_get_osp_order_dtls_csr;
  l_description := G_AHL_OSP_PREFIX || l_temp_n;
  IF(l_OSP_description IS NOT NULL) THEN
    l_description := l_description || ' - ' || SUBSTR(l_OSP_description, 1, 200);
  END IF;

  -- Get currency if required
  -- If set either at Site or Supplier Level, no need to set.
  -- Else retrieve from Set-Of-Books and set explicitly
  BEGIN
    -- Check if currency is available at vendor site level
    SELECT invoice_currency_code INTO l_temp_v FROM po_vendor_sites
    WHERE vendor_site_id = p_po_header_rec.vendor_site_id AND
          vendor_id = p_po_header_rec.vendor_id;
    IF(l_temp_v IS NULL) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Could not get currency for Supplier ' || p_po_header_rec.vendor_id || ' Trying at Site ' || p_po_header_rec.vendor_site_id);
      END IF;
      -- If not check if available at vendor level
      SELECT invoice_currency_code INTO l_temp_v FROM po_vendors
      WHERE vendor_id = p_po_header_rec.vendor_id;
      IF(l_temp_v IS NULL) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Could not get currency for Supplier ' || p_po_header_rec.vendor_id || ' and Site ' || p_po_header_rec.vendor_site_id || ', Trying from set of Books.');
        END IF;
        -- If not, get currency from set_of_books and set l_currency_code
        SELECT GSB.currency_code INTO l_currency_code
          FROM   FINANCIALS_SYSTEM_PARAMETERS FSP, GL_SETS_OF_BOOKS GSB
          WHERE  FSP.set_of_books_id = GSB.set_of_books_id;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Got currency from Set Of Books: ' || l_currency_code);
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_CURRENCY_NOT_SET');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      RAISE;
  END;

  -- Added by jaramana on Sep 9, 2005 for MOAC Uptake
  l_curr_org_id := MO_GLOBAL.get_current_org_id();

  -- SATHAPLI::Bug 8583364, 21-Aug-2009, call create_manual_PO_Number to get the manual PO number
  l_manual_po_number := create_manual_PO_Number(l_curr_org_id, p_po_header_rec.OSP_ORDER_ID);

  -- Insert row into PO_HEADERS_INTERFACE
  INSERT INTO PO_HEADERS_INTERFACE (
    INTERFACE_HEADER_ID,
    BATCH_ID,
    INTERFACE_SOURCE_CODE,
    PROCESS_CODE,
    ACTION,
    DOCUMENT_TYPE_CODE,
    CURRENCY_CODE,
    AGENT_ID,
    VENDOR_ID,
    VENDOR_SITE_ID,
    VENDOR_CONTACT_ID, -- Added by jaramana on May 27, 2005 for Inventory Service Orders
    COMMENTS,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    REFERENCE_NUM,
    DOCUMENT_NUM,     -- SATHAPLI::Bug 8583364, 21-Aug-2009, l_manual_po_number to be passed - either NULL or created
    ORG_ID            -- Added by jaramana on Sep 9, 2005 for MOAC Uptake
  ) VALUES (
    l_intf_hdr_id,
    l_batch_id,
    AHL_GLOBAL.AHL_APP_SHORT_NAME,   -- INTERFACE_SOURCE_CODE = 'AHL'
    G_PROCESS_CODE,     -- 'PENDING'
    G_ACTION_CODE,      -- 'ORIGINAL'
    G_DOC_TYPE_CODE,    -- 'STANDARD'
    l_currency_code,
    p_po_header_rec.BUYER_ID,
    p_po_header_rec.VENDOR_ID,
    p_po_header_rec.VENDOR_SITE_ID,
    p_po_header_rec.VENDOR_CONTACT_ID, -- Added by jaramana on May 27, 2005 for Inventory Service Orders
    l_description,
    AHL_GLOBAL.AHL_OSP_PROGRAM_ID,
    AHL_GLOBAL.AHL_APPLICATION_ID,
    p_po_header_rec.OSP_ORDER_ID,
    l_manual_po_number, -- SATHAPLI::Bug 8583364, 21-Aug-2009, l_manual_po_number to be passed - either NULL or created
    l_curr_org_id -- Added by jaramana on Sep 9, 2005 for MOAC Uptake
  );

  -- Set Output parameters
  x_intf_header_id := l_intf_hdr_id;
  x_batch_id := l_batch_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Insert_PO_Header;

----------------------------------------
-- This Procedure inserts a record into the PO_LINES_INTERFACE table
----------------------------------------
PROCEDURE Insert_PO_Lines(
   p_po_line_tbl  IN  PO_Line_Tbl_Type,
   p_intf_header_id IN NUMBER) IS

-- Commented out by jaramana on June 22, 2005
-- Calling the new utility method Get_Item_Price instead
/*
  CURSOR l_chk_price_csr(p_item_id IN NUMBER,
                         p_org_id  IN NUMBER) IS
    SELECT 'x' FROM MTL_SYSTEM_ITEMS_KFV
    WHERE INVENTORY_ITEM_ID = p_item_id
      AND ORGANIZATION_ID = p_org_id
      AND LIST_PRICE_PER_UNIT IS NOT NULL;
*/

  -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
  CURSOR get_prj_task_comp_date_csr (c_task_id IN NUMBER) IS
    SELECT COMPLETION_DATE from pa_tasks
     where task_id = c_task_id;
  l_task_completion_date DATE;

  --Added by mpothuku on 12-oct-2007 as until the ER 5758813 is implemented, the visit task dates will not be propagated to projects.
  CURSOR get_vst_task_comp_date_csr (c_osp_line_id IN NUMBER) IS
    SELECT vtsk.end_date_time
      from ahl_visit_tasks_b vtsk,
           ahl_osp_order_lines ospl,
           ahl_workorders wo
     where ospl.osp_order_line_id = c_osp_line_id
       and ospl.workorder_id = wo.workorder_id
       and wo.visit_task_id = vtsk.visit_task_id;
  l_vst_task_completion_date DATE;

  l_expenditure_item_type pa_expenditure_types.expenditure_type%type;

  l_org_id           NUMBER := NULL;
  l_price            NUMBER := NULL;
  l_category         VARCHAR2(30) := NULL;
  l_dummy            VARCHAR2(1);
  l_line_num         NUMBER := 0;
  l_ship_to_org_id   NUMBER := NULL;
  l_ship_to_loc_id   NUMBER := NULL;

  -- Added by jaramana on Nov 28, 2005 for ER 4736326
  -- To create distributions automatically
  l_intf_line_id     NUMBER;
  --Added by mpothuku on 21-Aug-2007 to fix the Bug 6436184
  l_charge_acct_id   NUMBER := NULL;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Insert_PO_Lines';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the current Org to get Item Price
  l_org_id := MO_GLOBAL.get_current_org_id();

  FOR i IN p_po_line_tbl.FIRST..p_po_line_tbl.LAST LOOP
    IF (p_po_line_tbl(i).ITEM_ID IS NULL) THEN
      -- One time items defaulting
      l_price := G_DEFAULT_PRICE;
      l_category := G_DEFAULT_CATEGORY;
    ELSE
      l_category := null;  -- Purchasing defaults the category from the item
      -- Changed by jaramana on June 22, 2005
      l_price := Get_Item_Price(p_po_line_tbl(i).OSP_LINE_ID);
    END IF;

    -- Added by jaramana on Nov 28, 2005 for ER 4736326
    -- Generate PO Line Interface Id
    SELECT PO_LINES_INTERFACE_S.NEXTVAL INTO l_intf_line_id FROM sys.dual;
    -- Insert row into PO_LINES_INTERFACE
    INSERT INTO PO_LINES_INTERFACE (
      INTERFACE_LINE_ID,
      INTERFACE_HEADER_ID,
      LINE_NUM,
      LINE_TYPE_ID,
      ITEM_ID,
      ITEM_DESCRIPTION,
      CATEGORY,
      UOM_CODE,
      UNIT_PRICE,
      QUANTITY,
      NEED_BY_DATE,
      LINE_REFERENCE_NUM,
      SHIP_TO_ORGANIZATION_ID,
      SHIP_TO_LOCATION_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID
    ) VALUES (
      l_intf_line_id,
      p_intf_header_id,
      p_po_line_tbl(i).LINE_NUMBER,
      p_po_line_tbl(i).PO_LINE_TYPE_ID,
      p_po_line_tbl(i).ITEM_ID,
      p_po_line_tbl(i).ITEM_DESCRIPTION,
      l_category,
      p_po_line_tbl(i).UOM_CODE,
      l_price,
      p_po_line_tbl(i).QUANTITY,
      p_po_line_tbl(i).NEED_BY_DATE,
      p_po_line_tbl(i).OSP_LINE_ID,
      p_po_line_tbl(i).SHIP_TO_ORG_ID,
      p_po_line_tbl(i).SHIP_TO_LOC_ID,
      AHL_GLOBAL.AHL_OSP_PROGRAM_ID,
      AHL_GLOBAL.AHL_APPLICATION_ID
    );
    -- Added by jaramana on Jan 5, 2006 for ER 4736326
    -- Check the profile OSP Default PO Distribution Creation to see if the Distribution is to be created
    IF (NVL(FND_PROFILE.VALUE('AHL_OSP_DEF_PO_DIST'), 'N') = 'Y') THEN
      -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
      -- Insert row into PO_DISTRIBUTIONS_INTERFACE to create a distribution
      IF p_po_line_tbl(i).task_id IS NOT NULL THEN
        OPEN get_prj_task_comp_date_csr(p_po_line_tbl(i).task_id);
        FETCH get_prj_task_comp_date_csr INTO l_task_completion_date;
        CLOSE get_prj_task_comp_date_csr;
        --If the project task completion is not populated (ER 5758813), then use the visit task's end date.
        IF(l_task_completion_date is NULL) THEN
          OPEN get_vst_task_comp_date_csr(p_po_line_tbl(i).osp_line_id);
          FETCH get_vst_task_comp_date_csr INTO l_task_completion_date;
          CLOSE get_vst_task_comp_date_csr;
        END IF;
      ELSE
        l_task_completion_date := NULL;
      END IF;

      l_expenditure_item_type := FND_PROFILE.VALUE('AHL_OSP_EXPENDITURE_TYPE');
      IF(l_expenditure_item_type IS NULL) THEN
        l_expenditure_item_type := 'Outside Processing';
      END IF;

      --Fix for the  Bug 6436184
      l_charge_acct_id := get_charge_account_id(p_po_line_tbl(i).SHIP_TO_ORG_ID, p_po_line_tbl(i).ITEM_ID);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_charge_acct_id before inserting: '|| l_charge_acct_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_task_completion_date : '|| to_char(l_task_completion_date, 'DD-MON-YYYY HH24:MI:SS'));
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_expenditure_item_type : '|| l_expenditure_item_type);
      END IF;
      --mpothuku End

      INSERT INTO PO_DISTRIBUTIONS_INTERFACE (
        INTERFACE_HEADER_ID,
        INTERFACE_LINE_ID,
        INTERFACE_DISTRIBUTION_ID,
        QUANTITY_ORDERED,
        PROGRAM_ID,
        PROGRAM_APPLICATION_ID,
        CREATION_DATE,
        CREATED_BY
        -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
        ,WIP_ENTITY_ID
        ,PROJECT_RELEATED_FLAG
        ,PROJECT_ACCOUNTING_CONTEXT
        ,PROJECT_ID
        ,TASK_ID
        ,EXPENDITURE_TYPE
        ,EXPENDITURE_ORGANIZATION_ID
        ,EXPENDITURE_ITEM_DATE
        ,CHARGE_ACCOUNT_ID

      ) VALUES (
        p_intf_header_id,
        l_intf_line_id,
        PO_DISTRIBUTIONS_INTERFACE_S.NEXTVAL,
        p_po_line_tbl(i).QUANTITY,
        AHL_GLOBAL.AHL_OSP_PROGRAM_ID,
        AHL_GLOBAL.AHL_APPLICATION_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID
        -- Added by mpothuku on 10-oct-2007 to fix bug 6431740
        ,p_po_line_tbl(i).wip_entity_id
        ,DECODE(p_po_line_tbl(i).project_id, null, null, 'Y')
        ,DECODE(p_po_line_tbl(i).project_id, null, null, 'Y')
        ,p_po_line_tbl(i).project_id
        ,p_po_line_tbl(i).task_id
        ,DECODE(p_po_line_tbl(i).project_id, null, null, l_expenditure_item_type)
        ,DECODE(p_po_line_tbl(i).project_id, null, null,p_po_line_tbl(i).SHIP_TO_ORG_ID)
        ,l_task_completion_date
        ,l_charge_acct_id
      );
       --Added by mpothuku on 10-oct-2007 to fix bug 6431740
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
            ' Inserting into PO_DISTRIBUTIONS_INTERFACE. INTERFACE_HEADER_ID = ' || p_intf_header_id ||
            ', INTERFACE_LINE_ID = ' || l_intf_line_id ||
            ', WIP_ENTITY_ID = ' || p_po_line_tbl(i).wip_entity_id ||
            ', PROJECT_ID = ' || p_po_line_tbl(i).project_id ||
            ', TASK_ID = ' || p_po_line_tbl(i).task_id ||
            ', EXPENDITURE_TYPE = ' ||l_expenditure_item_type ||
            ', EXPENDITURE_ORGANIZATION_ID = ' || p_po_line_tbl(i).SHIP_TO_ORG_ID ||
            ', EXPENDITURE_ITEM_DATE = ' || to_char(l_task_completion_date, 'DD-MON-YYYY HH24:MI:SS'));
      END IF;
    END IF;
  END LOOP;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Insert_PO_Lines;

----------------------------------------
-- This Procedure calls the Concurrent Program to Create
-- Purchase Order
----------------------------------------
PROCEDURE Call_PDOI_Program(
   p_batch_id   IN  NUMBER,
   x_request_id OUT NOCOPY NUMBER) IS

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Call_PDOI_Program';
  l_curr_org_id            NUMBER;

BEGIN
  -- Added by jaramana on Sep 9, 2005 for MOAC Uptake
  l_curr_org_id := MO_GLOBAL.get_current_org_id();
  FND_REQUEST.SET_ORG_ID(l_curr_org_id);

  x_request_id := FND_REQUEST.SUBMIT_REQUEST(
          application => G_PO_APP_CODE,
          program     => G_PDOI_CODE,
          argument1   => NULL,  -- Buyer
          argument2   => G_DOC_TYPE_CODE,  -- Document Type
          argument3   => NULL,  -- Document Sub Type
          argument4   => G_NO_FLAG,  -- Create or Update Items
          argument5   => NULL,  -- Create Sourcing Rules
          argument6   => G_INCOMPLETE_STATUS,  -- Approval Status
          argument7   => NULL,  -- Release Generation Method
          argument8   => p_batch_id,  -- Batch Id
          argument9   => NULL, --Org Id
	  argument10  => NULL  --global agreement flag
          );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Request Submitted. Request Id = ' || x_request_id);
  END IF;
END Call_PDOI_Program;

----------------------------------------
-- This Procedure calls the PDOI API directly to Create Purchase Order
-- TO BE USED FOR DEBUGGING PURPOSE ONLY
----------------------------------------
PROCEDURE Call_PDOI_API(p_batch_id IN NUMBER) IS
BEGIN
  po_docs_interface_sv5.process_po_headers_interface(
          X_selected_batch_id   => p_batch_id,
          X_buyer_id            => NULL,
          X_document_type       => G_DOC_TYPE_CODE,
          X_document_subtype    => NULL,
          X_create_items        => G_NO_FLAG,
          X_create_sourcing_rules_flag  => G_NO_FLAG,
          X_rel_gen_method      => NULL,
          X_approved_status     => NULL,
          X_commit_interval     => 1,
          X_process_code        => G_PROCESS_CODE);

   --dbms_output.enable;
   --dbms_output.put_line('==>PDOI completed at ' || fnd_date.date_to_chardt(SYSDATE));
   --dbms_output.put_line('See log file of comops/comfam in /sqlcom/log directory.');

END Call_PDOI_API;

----------------------------------------
-- This Local Procedure updates OSP Tables with
-- PO Information for one OSP Order
----------------------------------------
PROCEDURE Associate_OSP_PO(
   p_osp_order_id IN  NUMBER,
   x_po_header_id OUT NOCOPY NUMBER) IS

/*
  CURSOR l_get_po_hdr_csr(p_osp_order_id IN NUMBER) IS
    SELECT PO_HEADER_ID FROM PO_HEADERS_ALL
    WHERE REFERENCE_NUM = p_osp_order_id AND
    INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME;
*/
  -- Changes made by jaramana on December 19, 2005
  -- to improve the performace of this SQL by removing the Full Table Access
  CURSOR l_get_po_hdr_csr(p_osp_order_id IN NUMBER) IS
    SELECT PO.PO_HEADER_ID FROM PO_HEADERS_ALL PO, AHL_OSP_ORDERS_B OSP
    WHERE PO.REFERENCE_NUM = p_osp_order_id AND
    OSP.OSP_ORDER_ID = p_osp_order_id AND
    PO.VENDOR_ID = OSP.VENDOR_ID AND
    PO.VENDOR_SITE_ID = OSP.VENDOR_SITE_ID AND
    PO.INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME;

  CURSOR l_get_osp_lines_csr(p_osp_order_id IN NUMBER) IS
    SELECT OSP_ORDER_LINE_ID FROM AHL_OSP_ORDER_LINES
    WHERE PO_LINE_ID IS NULL
    AND OSP_ORDER_ID = p_osp_order_id;

  CURSOR l_get_po_line_csr(p_osp_order_line_id IN NUMBER,
                            p_po_header_id      IN NUMBER) IS
    SELECT PO_LINE_ID FROM PO_LINES_ALL
    WHERE LINE_REFERENCE_NUM = p_osp_order_line_id AND
    PO_HEADER_ID = p_po_header_id;

  CURSOR l_get_request_id_csr(p_osp_order_id IN NUMBER) IS
    SELECT PO_REQUEST_ID FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id;

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Associate_OSP_PO';
   l_po_header_id           NUMBER;
   l_osp_order_line_id      NUMBER;
   l_po_line_id             NUMBER;
   l_request_id             NUMBER;
   l_phase                  VARCHAR2(100);
   l_status                 VARCHAR2(100);
   l_dev_phase              VARCHAR2(100);
   l_dev_status             VARCHAR2(100);
   l_message                VARCHAR2(1000);
   l_retval                 BOOLEAN;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  OPEN l_get_po_hdr_csr(p_osp_order_id);
  FETCH l_get_po_hdr_csr INTO x_po_header_id;
  IF (l_get_po_hdr_csr%FOUND) THEN
    -- Update AHL_OSP_ORDERS_B's PO_HEADER_ID
--dbms_output.put_line('About to Update  AHL_OSP_ORDERS_B.PO_HEADER_ID with ' || x_po_header_id);
    Set_PO_Header_Id(p_osp_order_id => p_osp_order_id,
                     p_po_header_id => x_po_header_id);

--dbms_output.put_line('Updated po_header_id. Logging Transaction...');
    AHL_OSP_UTIL_PKG.Log_Transaction(p_trans_type_code    => G_TXN_TYPE_PO_SYNCH,
                                     p_src_doc_id         => p_osp_order_id,
                                     p_src_doc_type_code  => G_DOC_TYPE_OSP,
                                     p_dest_doc_id        => x_po_header_id,
                                     p_dest_doc_type_code => G_DOC_TYPE_PO);

    -- Get PO Lines for all OSP Lines
--dbms_output.put_line('About to get all lines...');
    OPEN l_get_osp_lines_csr(p_osp_order_id);
    LOOP
      FETCH l_get_osp_lines_csr INTO l_osp_order_line_id;
      EXIT WHEN l_get_osp_lines_csr%NOTFOUND;
      OPEN l_get_po_line_csr(l_osp_order_line_id, x_po_header_id);
      FETCH l_get_po_line_csr INTO l_po_line_id;
      IF (l_get_po_line_csr%FOUND) THEN
      --dbms_output.put_line('About to set po_line_id ' || l_po_line_id || ' for osp line ' || l_osp_order_line_id );
        Set_PO_Line_Id(p_osp_order_line_id => l_osp_order_line_id,
                       p_po_line_id        => l_po_line_id);
      ELSE
--dbms_output.put_line('OSP Line Id ' || l_osp_order_line_id || ' is not yet associated with a PO Line.');
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Line Id ' || l_osp_order_line_id || ' is not yet associated with a PO Line');
        END IF;
      END IF;
      CLOSE l_get_po_line_csr;
    END LOOP;
    CLOSE l_get_osp_lines_csr;
  ELSE
--dbms_output.put_line('No matching PO Header Id found.');
    -- Set Return PO Header Value to null
    x_po_header_id := null;
    -- Check if the Concurrent Program has completed
    OPEN l_get_request_id_csr(p_osp_order_id);
    FETCH l_get_request_id_csr INTO l_request_id;
    CLOSE l_get_request_id_csr;
    IF (l_request_id IS NOT NULL AND l_request_id <> 0) THEN
--dbms_output.put_line('Getting Concurrent Program Status ');
      l_retval := FND_CONCURRENT.GET_REQUEST_STATUS(request_id => l_request_id,
                                                    phase      => l_phase,
                                                    status     => l_status,
                                                    dev_phase  => l_dev_phase,
                                                    dev_status => l_dev_status,
                                                    message    => l_message);
--dbms_output.put_line('l_dev_phase = ' || l_dev_phase || ', l_dev_status = ' || l_dev_status );
--dbms_output.put_line('l_message = ' || l_message);
--      IF ((l_retval = TRUE) AND (l_dev_phase = 'COMPLETE') AND (l_dev_status <> 'NORMAL')) THEN
      -- Status can be NORMAL even if the PO Creation had failed.
      -- So setting status to SUBMISSION_FAILED if the Concurrent Program has completed
      -- but the PO Header is not set
      IF ((l_retval = TRUE) AND (l_dev_phase = 'COMPLETE')) THEN
        -- Abnormal Termination
--dbms_output.put_line('Concurrent Program has completed. Setting Status to SUBMISSION_FAILED.');
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Concurrent Program with Request Id ' || l_request_id || ' has terminated. dev_status = ' || l_dev_status || ', message = ' || l_message);
        END IF;
        -- Set the Status of OSP Order to Submission Failed
        Set_Submission_Failed(p_osp_order_id);
      END IF;
    END IF;
  END IF;
  CLOSE l_get_po_hdr_csr;
--dbms_output.put_line('About to exit Associate_OSP_PO ');
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Associate_OSP_PO;

----------------------------------------
-- This Procedure handles cancelled PO Lines and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action
----------------------------------------
PROCEDURE Handle_Cancelled_PO_Lines(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_cancelled_po_lines_csr IS
    SELECT PL.PO_LINE_ID, OL.OSP_ORDER_LINE_ID, PO.REFERENCE_NUM,
           OL.OBJECT_VERSION_NUMBER, OSP.OBJECT_VERSION_NUMBER
    FROM PO_LINES_ALL PL, PO_HEADERS_ALL PO, AHL_OSP_ORDER_LINES OL,
         AHL_OSP_ORDERS_B OSP
    WHERE PL.CANCEL_FLAG = 'Y' AND                         -- Canceled PO Line
          PL.PO_HEADER_ID = PO.PO_HEADER_ID AND
          PO.INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME AND  -- AHL Created PO
          PO.REFERENCE_NUM = OL.OSP_ORDER_ID AND           -- Related to the OSP Order
          OSP.OSP_ORDER_ID = PO.REFERENCE_NUM AND
          -- Added by jaramana on April 7, 2008 for bug 6609988
          OSP.OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id() AND
          OL.PO_LINE_ID = PL.PO_LINE_ID AND
          NVL(OL.STATUS_CODE, ' ') <> G_OL_PO_CANCELLED_STATUS       -- Not yet updated
          ORDER BY PO.REFERENCE_NUM;                       -- One OSP Order at a time

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Cancelled_PO_Lines';
   l_osp_order_id           NUMBER := -1;
   l_osp_order_line_id      NUMBER;
   l_po_line_id             NUMBER;
   l_prev_osp_order_id      NUMBER := -1;
   l_table_index            NUMBER := 0;
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(1000);
   l_osp_order_rec          AHL_OSP_ORDERS_PVT.osp_order_rec_type;
   l_osp_order_lines_tbl    AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type;
   l_commit_flag            BOOLEAN := true;
   l_osp_obj_ver_num        NUMBER;
   l_ol_obj_ver_num         NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT Handle_Cancelled_PO_Lines_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN l_get_cancelled_po_lines_csr;
  LOOP
    FETCH l_get_cancelled_po_lines_csr INTO l_po_line_id,
                                            l_osp_order_line_id,
                                            l_osp_order_id,
                                            l_ol_obj_ver_num,
                                            l_osp_obj_ver_num;
    EXIT WHEN l_get_cancelled_po_lines_csr%NOTFOUND;
    IF (l_osp_order_id <> l_prev_osp_order_id) THEN
      IF (l_prev_osp_order_id <> -1) THEN
        -- Cancel all OSP Lines pertaining to the previous OSP Order
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Cancelling OSP Line for Order ' || l_prev_osp_order_id);
        END IF;
        AHL_OSP_ORDERS_PVT.process_osp_order(p_api_version           => 1.0,
                                             p_init_msg_list         => FND_API.G_FALSE,
                                             p_commit                => FND_API.G_FALSE,
                                             p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                                             p_x_osp_order_rec       => l_osp_order_rec,
                                             p_x_osp_order_lines_tbl => l_osp_order_lines_tbl,
                                             x_return_status         => l_return_status,
                                             x_msg_count             => l_msg_count,
                                             x_msg_data              => l_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error while Cancelling OSP Line for OSP Order ' || l_prev_osp_order_id);
          END IF;
          l_commit_flag := false;
        END IF;
        -- Delete table used by prior call
        l_osp_order_lines_tbl.DELETE;
      END IF;
      -- Update API Record with new OSP Order Id
      l_osp_order_rec.OSP_ORDER_ID := l_osp_order_id;
      l_osp_order_rec.OBJECT_VERSION_NUMBER := l_osp_obj_ver_num;
      l_prev_osp_order_id := l_osp_order_id;
      l_table_index := 0;
    END IF;
    -- Copy OSP Line Id into API's Line Table at l_table_index
    l_osp_order_lines_tbl(l_table_index).OSP_ORDER_LINE_ID := l_osp_order_line_id;
    -- Copy Line's Object Version Nnumber into API's Line Table at l_table_index
    l_osp_order_lines_tbl(l_table_index).OBJECT_VERSION_NUMBER := l_ol_obj_ver_num;
    -- Set OSP Line Status to G_OL_PO_CANCELLED_STATUS in API's Line Table
    l_osp_order_lines_tbl(l_table_index).STATUS_CODE := G_OL_PO_CANCELLED_STATUS;
    -- Set Operation to Update in the line rec
    l_osp_order_lines_tbl(l_table_index).OPERATION_FLAG := AHL_OSP_ORDERS_PVT.G_OP_UPDATE;

    l_table_index := l_table_index + 1;
  END LOOP;
  CLOSE l_get_cancelled_po_lines_csr;
  IF (l_prev_osp_order_id <> -1) THEN
    -- Save the Last Cancellation
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Cancelling OSP Line for Order ' || l_prev_osp_order_id);
    END IF;
    AHL_OSP_ORDERS_PVT.process_osp_order(p_api_version           => 1.0,
                                         p_init_msg_list         => FND_API.G_FALSE,
                                         p_commit                => FND_API.G_FALSE,
                                         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                                         p_x_osp_order_rec       => l_osp_order_rec,
                                         p_x_osp_order_lines_tbl => l_osp_order_lines_tbl,
                                         x_return_status         => l_return_status,
                                         x_msg_count             => l_msg_count,
                                         x_msg_data              => l_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error while Cancelling OSP Line for OSP Order ' || l_prev_osp_order_id);
      END IF;
      l_commit_flag := false;
    END IF;
  END IF;
  IF (l_commit_flag = false) THEN
    RAISE FND_API.G_EXC_ERROR;  -- Rollback and return error
  END IF;
  -- No errors in current procedure: Check only passed in flag
  IF (FND_API.TO_BOOLEAN(p_commit)) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to COMMIT work.');
    END IF;
    COMMIT WORK;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Handle_Cancelled_PO_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Cancelled_PO_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Cancelled_PO_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Cancelled_PO_Lines',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Cancelled_PO_Lines;

----------------------------------------
-- This Procedure handles deleted PO Lines and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action.
----------------------------------------
PROCEDURE Handle_Deleted_PO_Lines(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_deleted_po_lines_csr IS
    SELECT OL.OSP_ORDER_ID, OL.OSP_ORDER_LINE_ID,
           OL.OBJECT_VERSION_NUMBER, OSP.OBJECT_VERSION_NUMBER
    FROM AHL_OSP_ORDER_LINES OL, AHL_OSP_ORDERS_B OSP
    WHERE OL.PO_LINE_ID IS NOT NULL AND                -- PO Created
          NVL(OL.STATUS_CODE, ' ') <> G_OL_PO_DELETED_STATUS AND -- Not yet updated
          OSP.OSP_ORDER_ID = OL.OSP_ORDER_ID AND
          -- Added by jaramana on April 7, 2008 for bug 6609988
          OSP.OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id() AND
          NOT EXISTS (SELECT PO_LINE_ID FROM PO_LINES_ALL WHERE PO_LINE_ID = OL.PO_LINE_ID)  -- PO Line Deleted
          ORDER BY OL.OSP_ORDER_ID;                    -- One OSP Order at a time

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Deleted_PO_Lines';
   l_osp_order_id           NUMBER := -1;
   l_osp_order_line_id      NUMBER;
   l_prev_osp_order_id      NUMBER := -1;
   l_table_index            NUMBER := 0;
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(1000);
   l_osp_order_rec          AHL_OSP_ORDERS_PVT.osp_order_rec_type;
   l_osp_order_lines_tbl    AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type;
   l_commit_flag            BOOLEAN := true;
   l_osp_obj_ver_num        NUMBER;
   l_ol_obj_ver_num         NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT Handle_Deleted_PO_Lines_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN l_get_deleted_po_lines_csr;
  LOOP
    FETCH l_get_deleted_po_lines_csr INTO l_osp_order_id,
                                          l_osp_order_line_id,
                                          l_ol_obj_ver_num,
                                          l_osp_obj_ver_num;
    EXIT WHEN l_get_deleted_po_lines_csr%NOTFOUND;
    IF (l_osp_order_id <> l_prev_osp_order_id) THEN
      IF (l_prev_osp_order_id <> -1) THEN
        -- PO Delete all OSP Lines pertaining to the previous OSP Order
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleting OSP Line for Order ' || l_prev_osp_order_id);
        END IF;
        AHL_OSP_ORDERS_PVT.process_osp_order(p_api_version           => 1.0,
                                             p_init_msg_list         => FND_API.G_FALSE,
                                             p_commit                => FND_API.G_FALSE,
                                             p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                                             p_x_osp_order_rec       => l_osp_order_rec,
                                             p_x_osp_order_lines_tbl => l_osp_order_lines_tbl,
                                             x_return_status         => l_return_status,
                                             x_msg_count             => l_msg_count,
                                             x_msg_data              => l_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error while Deleting OSP Line for OSP Order ' || l_prev_osp_order_id);
          END IF;
          l_commit_flag := false;
        END IF;
        -- Delete table used by prior call
        l_osp_order_lines_tbl.DELETE;
      END IF;
      -- Update API Record with new OSP Order Id
      l_osp_order_rec.OSP_ORDER_ID := l_osp_order_id;
      l_osp_order_rec.OBJECT_VERSION_NUMBER := l_osp_obj_ver_num;
      l_prev_osp_order_id := l_osp_order_id;
      l_table_index := 0;
    END IF;
    -- Copy OSP Line Id into API's Line Table at l_table_index
    l_osp_order_lines_tbl(l_table_index).OSP_ORDER_LINE_ID := l_osp_order_line_id;
    -- Copy Line's Object Version Nnumber into API's Line Table at l_table_index
    l_osp_order_lines_tbl(l_table_index).OBJECT_VERSION_NUMBER := l_ol_obj_ver_num;
    -- Set  OSP Line Status to G_OL_PO_DELETED_STATUS in API's Line Table
    l_osp_order_lines_tbl(l_table_index).STATUS_CODE := G_OL_PO_DELETED_STATUS;
    -- Set Operation to Update in the line rec
    l_osp_order_lines_tbl(l_table_index).OPERATION_FLAG := AHL_OSP_ORDERS_PVT.G_OP_UPDATE;
    l_table_index := l_table_index + 1;
  END LOOP;
  CLOSE l_get_deleted_po_lines_csr;
  IF (l_prev_osp_order_id <> -1) THEN
    -- Save the Last Deletion
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleting OSP Line for Order ' || l_prev_osp_order_id);
    END IF;
    AHL_OSP_ORDERS_PVT.process_osp_order(p_api_version           => 1.0,
                                         p_init_msg_list         => FND_API.G_FALSE,
                                         p_commit                => FND_API.G_FALSE,
                                         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                                         p_x_osp_order_rec       => l_osp_order_rec,
                                         p_x_osp_order_lines_tbl => l_osp_order_lines_tbl,
                                         x_return_status         => l_return_status,
                                         x_msg_count             => l_msg_count,
                                         x_msg_data              => l_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error while Deleting OSP Line for OSP Order ' || l_prev_osp_order_id);
      END IF;
      l_commit_flag := false;
    END IF;
  END IF;

  IF (l_commit_flag = false) THEN
    RAISE FND_API.G_EXC_ERROR;  -- Rollback and return error
  END IF;
  -- No errors in current procedure: Check only passed in flag
  IF (FND_API.TO_BOOLEAN(p_commit)) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to COMMIT work.');
    END IF;
    COMMIT WORK;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Handle_Deleted_PO_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Deleted_PO_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Deleted_PO_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Deleted_PO_Lines',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Deleted_PO_Lines;

----------------------------------------
-- This Procedure handles Approved POs and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action.
----------------------------------------
PROCEDURE Handle_Approved_POs(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_approved_POs_csr IS
    SELECT OSP.OSP_ORDER_ID, OSP.PO_HEADER_ID, OSP.OE_HEADER_ID
    FROM AHL_OSP_ORDERS_B OSP, PO_HEADERS_ALL PO
    WHERE OSP.STATUS_CODE = G_OSP_PO_CREATED_STATUS AND      -- PO Created
          OSP.PO_HEADER_ID = PO.PO_HEADER_ID AND             -- Join
          -- Added by jaramana on April 7, 2008 for bug 6609988
          OSP.OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id() AND
          PO.APPROVED_FLAG = G_YES_FLAG AND                  -- Approved PO
          NVL(PO.CANCEL_FLAG, G_NO_FLAG) <> G_YES_FLAG AND   -- Not Cancelled
          NVL(PO.CLOSED_CODE, G_PO_OPEN) NOT LIKE '%CLOSED'; -- Not Closed

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Approved_POs';
   l_osp_order_id           NUMBER;
   l_po_header_id           NUMBER;
   l_oe_header_id           NUMBER;
   l_temp_num               NUMBER := 0;
   l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(1000);

   l_shipment_IDs_Tbl       AHL_OSP_SHIPMENT_PUB.Ship_ID_Tbl_Type;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT Handle_Approved_POs_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN l_get_approved_pos_csr;
  LOOP
    FETCH l_get_approved_POs_csr INTO l_osp_order_id,
                                      l_po_header_id,
                                      l_oe_header_id;
    EXIT WHEN l_get_approved_POs_csr%NOTFOUND;
    IF (l_oe_header_id IS NOT NULL) THEN
      l_temp_num := l_temp_num + 1;  -- One based index
      -- Populate the table with this Shipment Id
      l_shipment_IDs_Tbl(l_temp_num) := l_oe_header_id;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Booking Shipment with Id: ' || l_oe_header_id);
      END IF;
    END IF;
  END LOOP;
  CLOSE l_get_approved_POs_csr;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Number of Approvals to be submitted: ' || l_temp_num);
  END IF;
  IF (l_temp_num > 0) THEN
    -- Call Shipment API. This API will not throw an error or
    -- re-book if the shipment is already booked
    AHL_OSP_SHIPMENT_PUB.Book_Order(p_api_version      => 1.0,
                                    p_init_msg_list    => FND_API.G_FALSE,
                                    p_commit           => FND_API.G_FALSE,
                                    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                    p_oe_header_tbl    => l_shipment_IDs_Tbl,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data);
  END IF;

  x_return_status := l_return_status;
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'AHL_OSP_SHIPMENT_PUB.Book_Order Did not succeed');
    END IF;
    RAISE FND_API.G_EXC_ERROR;  -- Rollback and return error
  END IF;
  -- No errors in current procedure: Check only passed in flag
  IF (FND_API.TO_BOOLEAN(p_commit)) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'AHL_OSP_SHIPMENT_PUB.Book_Order Succeeded. About to COMMIT work.');
    END IF;
    COMMIT WORK;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Handle_Approved_POs_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Approved_POs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Approved_POs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Approved_POs',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Approved_POs;

/** The following two procedures Handle_Deleted_PO_Headers and Handle_Deleted_Sales_Orders
  * were added by jaramana on March 31, 2006 to implement the ER 5074660
***/
----------------------------------------
-- This Procedure handles Deleted PO Headers and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action.
-- Functionality:
-- After a PO has been created for an OSP Order, it is possible for the PO
-- to be manually deleted (using Purchasing responsibility) before the PO is approved.
-- Since this deletion will result in an OSP Order referring to a non-existent PO,
-- we need to change the OSP order to bring it to a consistent state.
-- This procedure basically looks for OSP Orders for which the PO has been deleted
-- and resets some values and corrects the status of the order as well as the lines
-- so that the OSP Order can be resubmitted and a different PO can be created.
-- This procedure does a direct update of the AHL_OSP_ORDERS_B and the AHL_OSP_ORDER_LINES
-- tables and does not call the process_osp_order API to avoid unwanted validations
----------------------------------------
PROCEDURE Handle_Deleted_PO_Headers(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR get_po_deleted_osps_csr IS
    SELECT osp.osp_order_id,
           osp.object_version_number,
           osp.po_header_id,
           osp.status_code,
           osp.order_type_code
    FROM ahl_osp_orders_b osp
    WHERE osp.status_code = G_OSP_PO_CREATED_STATUS AND
          osp.order_type_code in ('SERVICE', 'EXCHANGE') AND
          -- Added by jaramana on April 7, 2008 for bug 6609988
          osp.operating_unit_id = MO_GLOBAL.get_current_org_id() AND
          NOT EXISTS (SELECT 1 FROM po_headers_all where po_header_id = osp.po_header_id);

  CURSOR get_osp_line_dtls_csr(c_osp_order_id IN NUMBER) IS
    SELECT ospl.osp_order_id,
           ospl.osp_order_line_id,
           ospl.object_version_number,
           ospl.status_code,
           ospl.po_line_id
    FROM ahl_osp_order_lines ospl
    WHERE ospl.osp_order_id = c_osp_order_id;

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Deleted_PO_Headers';
   l_temp_num               NUMBER := 0;
   l_osp_details_rec        get_po_deleted_osps_csr%ROWTYPE;
   l_osp_line_details_rec   get_osp_line_dtls_csr%ROWTYPE;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT Handle_Deleted_PO_Headers_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Get all OSP Orders for which the PO Header has been deleted
  OPEN get_po_deleted_osps_csr;
  LOOP
    FETCH get_po_deleted_osps_csr into l_osp_details_rec;
    EXIT WHEN get_po_deleted_osps_csr%NOTFOUND;
    l_temp_num := l_temp_num + 1;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing PO Deletion for OSP Order ' || l_osp_details_rec.osp_order_id);
    END IF;
    -- Get the Line Details
    OPEN get_osp_line_dtls_csr(c_osp_order_id => l_osp_details_rec.osp_order_id);
    LOOP
      FETCH get_osp_line_dtls_csr into l_osp_line_details_rec;
      EXIT WHEN get_osp_line_dtls_csr%NOTFOUND;
      IF (l_osp_line_details_rec.status_code IS NULL) THEN
        IF (l_osp_line_details_rec.po_line_id IS NOT NULL) THEN
          -- Reset the value of PO_LINE_ID and increment OVN (status_code is already null)
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Updating OSP Line with Id ' || l_osp_line_details_rec.osp_order_line_id);
          END IF;
          Set_PO_Line_ID(p_osp_order_line_id => l_osp_line_details_rec.osp_order_line_id,
                         p_po_line_id        => null);
        END IF;
      ELSE
        -- Physically delete this line (PO_DELETED or PO_CANCELLED)
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleting OSP Line with Id ' || l_osp_line_details_rec.osp_order_line_id);
        END IF;
        DELETE FROM ahl_osp_order_lines
        WHERE osp_order_line_id = l_osp_line_details_rec.osp_order_line_id;
      END IF;
    END LOOP;
    CLOSE get_osp_line_dtls_csr;
    -- Now for the OSP Order Header, reset PO_HEADER_ID, PO_BATCH_ID, PO_REQUEST_ID and PO_INTERFACE_HEADER_ID.
    -- set STATUS_CODE to "ENTERED" and increment OVN
    update ahl_osp_orders_b
    set po_header_id = null,
        po_batch_id = null,
        po_request_id = null,
        po_interface_header_id = null,
        status_code = G_OSP_ENTERED_STATUS,
        object_version_number =  l_osp_details_rec.object_version_number + 1,
        last_update_date    = TRUNC(sysdate),
        last_updated_by     = fnd_global.user_id,
        last_update_login   = fnd_global.login_id
    where osp_order_id = l_osp_details_rec.osp_order_id;
  END LOOP;
  CLOSE get_po_deleted_osps_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processed PO Deletion for ' || l_temp_num || ' OSP Orders');
  END IF;

  IF (FND_API.TO_BOOLEAN(p_commit)) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to COMMIT work.');
    END IF;
    COMMIT WORK;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Handle_Deleted_PO_Headers_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Deleted_PO_Headers_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Deleted_PO_Headers_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Deleted_PO_Headers',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Deleted_PO_Headers;

----------------------------------------
-- This Procedure handles Deleted Sales Orders and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action.
-- Functionality:
-- After a Sales Order has been created for an OSP Order, it is possible for the SO
-- to be manually deleted (using Order Management responsibility) before the SO is booked.
-- Since this deletion will result in an OSP Order referring to a non-existent SO,
-- we need to change the OSP order to bring it to a consistent state.
-- This procedure basically looks for OSP Orders for which the SO has been deleted
-- and resets some values of the order as well as the lines so that a new shipment
-- can be created for the OSP Order if required.
-- This procedure does a direct update of the AHL_OSP_ORDERS_B and the AHL_OSP_ORDER_LINES
-- tables and does not call the process_osp_order API to avoid unwanted validations.
----------------------------------------
PROCEDURE Handle_Deleted_Sales_Orders(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR get_so_deleted_osps_csr IS
    SELECT osp.osp_order_id,
           osp.object_version_number,
           osp.oe_header_id,
           osp.status_code
    FROM ahl_osp_orders_b osp
    WHERE osp.status_code <> 'CLOSED' AND
          osp.oe_header_id IS NOT NULL AND
          -- Added by jaramana on April 7, 2008 for bug 6609988
          osp.operating_unit_id = MO_GLOBAL.get_current_org_id() AND
          NOT EXISTS (SELECT 1 FROM oe_order_headers_all where header_id = osp.oe_header_id);

  CURSOR get_osp_line_dtls_csr(c_osp_order_id IN NUMBER) IS
    SELECT ospl.osp_order_line_id,
           ospl.object_version_number,
           ospl.oe_ship_line_id,
           ospl.oe_return_line_id
    FROM ahl_osp_order_lines ospl
    WHERE ospl.osp_order_id = c_osp_order_id AND
          (ospl.oe_ship_line_id IS NOT NULL OR ospl.oe_return_line_id IS NOT NULL);

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Deleted_Sales_Orders';
   l_temp_num               NUMBER := 0;
   l_osp_details_rec        get_so_deleted_osps_csr%ROWTYPE;
   l_osp_line_details_rec   get_osp_line_dtls_csr%ROWTYPE;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT Handle_Deleted_SOs_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get all OSP Orders for which the PO Header has been deleted
  OPEN get_so_deleted_osps_csr;
  LOOP
    FETCH get_so_deleted_osps_csr into l_osp_details_rec;
    EXIT WHEN get_so_deleted_osps_csr%NOTFOUND;
    l_temp_num := l_temp_num + 1;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing SO Deletion for OSP Order ' || l_osp_details_rec.osp_order_id);
    END IF;
    -- Get the Details of lines that have a ship or a return line
    OPEN get_osp_line_dtls_csr(c_osp_order_id => l_osp_details_rec.osp_order_id);
    LOOP
      FETCH get_osp_line_dtls_csr into l_osp_line_details_rec;
      EXIT WHEN get_osp_line_dtls_csr%NOTFOUND;
      -- Reset the value of oe_ship_line_id and oe_return_line_id and increment OVN
      update ahl_osp_order_lines
      set oe_ship_line_id       = null,
          oe_return_line_id     = null,
          object_version_number = l_osp_line_details_rec.object_version_number + 1,
          last_update_date    = TRUNC(sysdate),
          last_updated_by     = fnd_global.user_id,
          last_update_login   = fnd_global.login_id
      where osp_order_line_id = l_osp_line_details_rec.osp_order_line_id;
    END LOOP;
    CLOSE get_osp_line_dtls_csr;
    -- Now for the OSP Order Header, reset OE_HEADER_ID and increment OVN
    update ahl_osp_orders_b
    set OE_HEADER_ID = null,
        object_version_number =  l_osp_details_rec.object_version_number + 1,
        last_update_date    = TRUNC(sysdate),
        last_updated_by     = fnd_global.user_id,
        last_update_login   = fnd_global.login_id
    where osp_order_id = l_osp_details_rec.osp_order_id;
  END LOOP;
  CLOSE get_so_deleted_osps_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processed SO Deletion for ' || l_temp_num || ' OSP Orders');
  END IF;

  -- No errors in current procedure: Check only passed in flag
  IF (FND_API.TO_BOOLEAN(p_commit)) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to COMMIT work.');
    END IF;
    COMMIT WORK;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Handle_Deleted_SOs_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Deleted_SOs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Deleted_SOs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Deleted_Sales_Orders',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Deleted_Sales_Orders;

----------------------------------------
-- This Procedure updates AHL_OSP_ORDERS_B with the Batch Id, Request Id and Interface Header Id
----------------------------------------
PROCEDURE Record_OSP_Submission(
   p_osp_order_id IN NUMBER,
   p_batch_id     IN NUMBER,
   p_request_id   IN NUMBER,
   p_intf_hdr_id  IN NUMBER) IS
BEGIN
  Update_OSP_Order(p_osp_order_id => p_osp_order_id,
                   p_batch_id     => p_batch_id,
                   p_request_id   => p_request_id,
                   p_intf_hdr_id  => p_intf_hdr_id);
END Record_OSP_Submission;

----------------------------------------
-- This Procedure updates AHL_OSP_ORDERS_B's PO_HEADER_ID and sets STATUS_CODE to PO_CREATED
----------------------------------------
PROCEDURE Set_PO_Header_ID(
   p_osp_order_id IN NUMBER,
   p_po_header_id IN NUMBER) IS
BEGIN
  Update_OSP_Order(p_osp_order_id => p_osp_order_id,
                   p_po_header_id => p_po_header_id,
                   p_status_code => G_OSP_PO_CREATED_STATUS);
END Set_PO_Header_ID;

----------------------------------------
-- This Procedure updates AHL_OSP_ORDERS_B.STATUS_CODE to SUBMISSION_FAILED
----------------------------------------
PROCEDURE Set_Submission_Failed(
   p_osp_order_id IN NUMBER) IS
BEGIN
  Update_OSP_Order(p_osp_order_id => p_osp_order_id,
                   p_status_code  => G_OSP_SUB_FAILED_STATUS);
END Set_Submission_Failed;

----------------------------------------
-- This Procedure updates AHL_OSP_ORDER_LINES.PO_LINE_ID
----------------------------------------
PROCEDURE Set_PO_Line_ID(
   p_osp_order_line_id IN NUMBER,
   p_po_line_id IN NUMBER) IS

  CURSOR l_osp_line_dtls_csr(p_osp_line_id IN NUMBER) IS
    SELECT
      OBJECT_VERSION_NUMBER,
      OSP_ORDER_ID,
      OSP_LINE_NUMBER,
      STATUS_CODE,
      PO_LINE_TYPE_ID,
      SERVICE_ITEM_ID,
      SERVICE_ITEM_DESCRIPTION,
      SERVICE_ITEM_UOM_CODE,
      NEED_BY_DATE,
      SHIP_BY_DATE,
      PO_LINE_ID,
      OE_SHIP_LINE_ID,
      OE_RETURN_LINE_ID,
      WORKORDER_ID,
      OPERATION_ID,
      QUANTITY,
      EXCHANGE_INSTANCE_ID,
      INVENTORY_ITEM_ID,
      INVENTORY_ORG_ID,
      INVENTORY_ITEM_UOM,
      INVENTORY_ITEM_QUANTITY,
      SUB_INVENTORY,
      LOT_NUMBER,
      SERIAL_NUMBER,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
-- Begin Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
      PO_REQ_LINE_ID
-- End Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
    FROM AHL_OSP_ORDER_LINES
    WHERE OSP_ORDER_LINE_ID = p_osp_order_line_id;

    l_osp_line_dtls_rec l_osp_line_dtls_csr%ROWTYPE;
    L_DEBUG_KEY         CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Set_PO_Line_ID';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Retrieve the current record
  OPEN l_osp_line_dtls_csr(p_osp_order_line_id);
  FETCH l_osp_line_dtls_csr INTO l_osp_line_dtls_rec;
  IF (l_osp_line_dtls_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_LINE_ID_INVALID');
    FND_MESSAGE.Set_Token('OSP_LINE_ID', p_osp_order_line_id);
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    CLOSE l_osp_line_dtls_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE l_osp_line_dtls_csr;

  -- Update cursor variable's PO Line ID
  l_osp_line_dtls_rec.PO_LINE_ID := p_po_line_id;

  -- Call Table Handler
  AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW(
        P_OSP_ORDER_LINE_ID         => p_osp_order_line_id,
        P_OBJECT_VERSION_NUMBER     => l_osp_line_dtls_rec.OBJECT_VERSION_NUMBER + 1,  -- Updated
        P_OSP_ORDER_ID              => l_osp_line_dtls_rec.OSP_ORDER_ID,
        P_OSP_LINE_NUMBER           => l_osp_line_dtls_rec.OSP_LINE_NUMBER,
        P_STATUS_CODE               => l_osp_line_dtls_rec.STATUS_CODE,
        P_PO_LINE_TYPE_ID           => l_osp_line_dtls_rec.PO_LINE_TYPE_ID,
        P_SERVICE_ITEM_ID           => l_osp_line_dtls_rec.SERVICE_ITEM_ID,
        P_SERVICE_ITEM_DESCRIPTION  => l_osp_line_dtls_rec.SERVICE_ITEM_DESCRIPTION,
        P_SERVICE_ITEM_UOM_CODE     => l_osp_line_dtls_rec.SERVICE_ITEM_UOM_CODE,
        P_NEED_BY_DATE              => l_osp_line_dtls_rec.NEED_BY_DATE,
        P_SHIP_BY_DATE              => l_osp_line_dtls_rec.SHIP_BY_DATE,
        P_PO_LINE_ID                => l_osp_line_dtls_rec.PO_LINE_ID,  -- Updated
        P_OE_SHIP_LINE_ID           => l_osp_line_dtls_rec.OE_SHIP_LINE_ID,
        P_OE_RETURN_LINE_ID         => l_osp_line_dtls_rec.OE_RETURN_LINE_ID,
        P_WORKORDER_ID              => l_osp_line_dtls_rec.WORKORDER_ID,
        P_OPERATION_ID              => l_osp_line_dtls_rec.OPERATION_ID,
        P_QUANTITY                  => l_osp_line_dtls_rec.QUANTITY,
        P_EXCHANGE_INSTANCE_ID      => l_osp_line_dtls_rec.EXCHANGE_INSTANCE_ID,
        P_INVENTORY_ITEM_ID         => l_osp_line_dtls_rec.INVENTORY_ITEM_ID,
        P_INVENTORY_ORG_ID          => l_osp_line_dtls_rec.INVENTORY_ORG_ID,
        P_INVENTORY_ITEM_UOM        => l_osp_line_dtls_rec.INVENTORY_ITEM_UOM,
        P_INVENTORY_ITEM_QUANTITY   => l_osp_line_dtls_rec.INVENTORY_ITEM_QUANTITY,
        P_SUB_INVENTORY             => l_osp_line_dtls_rec.SUB_INVENTORY,
        P_LOT_NUMBER                => l_osp_line_dtls_rec.LOT_NUMBER,
        P_SERIAL_NUMBER             => l_osp_line_dtls_rec.SERIAL_NUMBER,
        P_ATTRIBUTE_CATEGORY        => l_osp_line_dtls_rec.ATTRIBUTE_CATEGORY,
        P_ATTRIBUTE1                => l_osp_line_dtls_rec.ATTRIBUTE1,
        P_ATTRIBUTE2                => l_osp_line_dtls_rec.ATTRIBUTE2,
        P_ATTRIBUTE3                => l_osp_line_dtls_rec.ATTRIBUTE3,
        P_ATTRIBUTE4                => l_osp_line_dtls_rec.ATTRIBUTE4,
        P_ATTRIBUTE5                => l_osp_line_dtls_rec.ATTRIBUTE5,
        P_ATTRIBUTE6                => l_osp_line_dtls_rec.ATTRIBUTE6,
        P_ATTRIBUTE7                => l_osp_line_dtls_rec.ATTRIBUTE7,
        P_ATTRIBUTE8                => l_osp_line_dtls_rec.ATTRIBUTE8,
        P_ATTRIBUTE9                => l_osp_line_dtls_rec.ATTRIBUTE9,
        P_ATTRIBUTE10               => l_osp_line_dtls_rec.ATTRIBUTE10,
        P_ATTRIBUTE11               => l_osp_line_dtls_rec.ATTRIBUTE11,
        P_ATTRIBUTE12               => l_osp_line_dtls_rec.ATTRIBUTE12,
        P_ATTRIBUTE13               => l_osp_line_dtls_rec.ATTRIBUTE13,
        P_ATTRIBUTE14               => l_osp_line_dtls_rec.ATTRIBUTE14,
        P_ATTRIBUTE15               => l_osp_line_dtls_rec.ATTRIBUTE15,
-- Begin Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
        P_PO_REQ_LINE_ID            => l_osp_line_dtls_rec.PO_REQ_LINE_ID,
-- End Changes by jaramana on January 7, 2008 for the Requisition ER 6034236
        P_LAST_UPDATE_DATE          => TRUNC(sysdate),  -- Updated
        P_LAST_UPDATED_BY           => fnd_global.user_id,  -- Updated
        P_LAST_UPDATE_LOGIN         => fnd_global.login_id);  -- Updated

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Set_PO_Line_ID;

----------------------------------------
-- This Procedure updates a record of AHL_OSP_ORDERS_B using the table handler
-- All updates to this table from this Package should go through this procedure only
----------------------------------------
PROCEDURE Update_OSP_Order(
   p_osp_order_id IN NUMBER,
   p_batch_id     IN NUMBER    := NULL,
   p_request_id   IN NUMBER    := NULL,
   p_status_code  IN VARCHAR2  := NULL,
   p_po_header_id IN NUMBER    := NULL,
   p_intf_hdr_id  IN NUMBER    := NULL
   ) IS

  CURSOR l_osp_dtls_csr(p_osp_order_id IN NUMBER) IS
    SELECT
      OBJECT_VERSION_NUMBER,
      OSP_ORDER_NUMBER,
      ORDER_TYPE_CODE,
      SINGLE_INSTANCE_FLAG,
      PO_HEADER_ID,
      OE_HEADER_ID,
      VENDOR_ID,
      VENDOR_SITE_ID,
      VENDOR_CONTACT_ID,
      CUSTOMER_ID,
      ORDER_DATE,
      CONTRACT_ID,
      CONTRACT_TERMS,
      OPERATING_UNIT_ID,
      PO_SYNCH_FLAG,
      STATUS_CODE,
      PO_BATCH_ID,
      PO_INTERFACE_HEADER_ID,
      PO_REQUEST_ID,
      PO_AGENT_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      DESCRIPTION,
      PO_REQ_HEADER_ID  -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
    FROM AHL_OSP_ORDERS_VL
    WHERE OSP_ORDER_ID = p_osp_order_id;

    l_osp_dtls_rec l_osp_dtls_csr%ROWTYPE;
    L_DEBUG_KEY         CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_OSP_Order';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Retrieve the current record
  OPEN l_osp_dtls_csr(p_osp_order_id);
  FETCH l_osp_dtls_csr INTO l_osp_dtls_rec;
  IF (l_osp_dtls_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_INVALID');
    FND_MESSAGE.Set_Token('OSP_ID', p_osp_order_id);
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    CLOSE l_osp_dtls_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE l_osp_dtls_csr;

  -- Update non-null local variables into cursor variable
  IF (p_batch_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_BATCH_ID := p_batch_id;
  END IF;
  IF (p_request_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_REQUEST_ID := p_request_id;
  END IF;
  IF (p_status_code IS NOT NULL) THEN
    l_osp_dtls_rec.STATUS_CODE := p_status_code;
  END IF;
  IF (p_po_header_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_HEADER_ID := p_po_header_id;
  END IF;
  IF (p_intf_hdr_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_INTERFACE_HEADER_ID := p_intf_hdr_id;
  END IF;

  -- Call Table Handler
  AHL_OSP_ORDERS_PKG.UPDATE_ROW(
    X_OSP_ORDER_ID          => p_osp_order_id,
    X_OBJECT_VERSION_NUMBER => l_osp_dtls_rec.OBJECT_VERSION_NUMBER + 1,  -- Updated
    X_OSP_ORDER_NUMBER      => l_osp_dtls_rec.OSP_ORDER_NUMBER,
    X_ORDER_TYPE_CODE       => l_osp_dtls_rec.ORDER_TYPE_CODE,
    X_SINGLE_INSTANCE_FLAG  => l_osp_dtls_rec.SINGLE_INSTANCE_FLAG,
    X_PO_HEADER_ID          => l_osp_dtls_rec.PO_HEADER_ID,  -- Updated
    X_OE_HEADER_ID          => l_osp_dtls_rec.OE_HEADER_ID,
    X_VENDOR_ID             => l_osp_dtls_rec.VENDOR_ID,
    X_VENDOR_SITE_ID        => l_osp_dtls_rec.VENDOR_SITE_ID,
    X_VENDOR_CONTACT_ID     => l_osp_dtls_rec.VENDOR_CONTACT_ID,
    X_CUSTOMER_ID           => l_osp_dtls_rec.CUSTOMER_ID,
    X_ORDER_DATE            => l_osp_dtls_rec.ORDER_DATE,
    X_CONTRACT_ID           => l_osp_dtls_rec.CONTRACT_ID,
    X_CONTRACT_TERMS        => l_osp_dtls_rec.CONTRACT_TERMS,
    X_OPERATING_UNIT_ID     => l_osp_dtls_rec.OPERATING_UNIT_ID,
    X_PO_SYNCH_FLAG         => l_osp_dtls_rec.PO_SYNCH_FLAG,
    X_STATUS_CODE           => l_osp_dtls_rec.STATUS_CODE,  -- Updated
    X_PO_BATCH_ID           => l_osp_dtls_rec.PO_BATCH_ID,  -- Updated
    X_PO_REQUEST_ID         => l_osp_dtls_rec.PO_REQUEST_ID,  -- Updated
    X_PO_INTERFACE_HEADER_ID => l_osp_dtls_rec.PO_INTERFACE_HEADER_ID,  -- Updated
    X_PO_AGENT_ID           => l_osp_dtls_rec.PO_AGENT_ID,
    X_ATTRIBUTE_CATEGORY    => l_osp_dtls_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1            => l_osp_dtls_rec.ATTRIBUTE1,
    X_ATTRIBUTE2            => l_osp_dtls_rec.ATTRIBUTE2,
    X_ATTRIBUTE3            => l_osp_dtls_rec.ATTRIBUTE3,
    X_ATTRIBUTE4            => l_osp_dtls_rec.ATTRIBUTE4,
    X_ATTRIBUTE5            => l_osp_dtls_rec.ATTRIBUTE5,
    X_ATTRIBUTE6            => l_osp_dtls_rec.ATTRIBUTE6,
    X_ATTRIBUTE7            => l_osp_dtls_rec.ATTRIBUTE7,
    X_ATTRIBUTE8            => l_osp_dtls_rec.ATTRIBUTE8,
    X_ATTRIBUTE9            => l_osp_dtls_rec.ATTRIBUTE9,
    X_ATTRIBUTE10           => l_osp_dtls_rec.ATTRIBUTE10,
    X_ATTRIBUTE11           => l_osp_dtls_rec.ATTRIBUTE11,
    X_ATTRIBUTE12           => l_osp_dtls_rec.ATTRIBUTE12,
    X_ATTRIBUTE13           => l_osp_dtls_rec.ATTRIBUTE13,
    X_ATTRIBUTE14           => l_osp_dtls_rec.ATTRIBUTE14,
    X_ATTRIBUTE15           => l_osp_dtls_rec.ATTRIBUTE15,
    X_DESCRIPTION           => l_osp_dtls_rec.DESCRIPTION,
    X_PO_REQ_HEADER_ID      => l_osp_dtls_rec.PO_REQ_HEADER_ID, -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
    X_LAST_UPDATE_DATE      => TRUNC(sysdate),  -- Updated
    X_LAST_UPDATED_BY       => fnd_global.user_id,  -- Updated
    X_LAST_UPDATE_LOGIN     => fnd_global.login_id);  -- Updated
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Update_OSP_Order;

----------------------------------------
-- This Function gets the price of an item.
-- The current logic is very simple: If the price is set at the inventory org,
-- this price is returned. If not, it returns null, letting Purchasing default in this case.
-- This has been made a separate function rather than inlining so that in case this logic
-- needs to be changed in the future, the impact will be localized.
----------------------------------------

FUNCTION Get_Item_Price(p_osp_line_id IN NUMBER) RETURN NUMBER IS

  CURSOR l_get_org_price_csr IS
    SELECT LIST_PRICE_PER_UNIT FROM MTL_SYSTEM_ITEMS_B MSIB, AHL_OSP_ORDER_LINES ospl
    WHERE MSIB.INVENTORY_ITEM_ID = ospl.service_item_id
      AND MSIB.ORGANIZATION_ID = ospl.inventory_org_id
      AND ospl.osp_order_line_id = p_osp_line_id;
/*
  CURSOR l_get_master_price_csr IS
    SELECT MSIK.LIST_PRICE_PER_UNIT FROM MTL_SYSTEM_ITEMS_KFV MSIK, MTL_PARAMETERS MP
    WHERE MSIK.INVENTORY_ITEM_ID = p_item_id
      AND MSIK.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID
      AND MP.ORGANIZATION_ID = p_org_id;
*/
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Item_Price';
  l_price          NUMBER := NULL;

BEGIN
  OPEN l_get_org_price_csr;
  FETCH l_get_org_price_csr INTO l_price;
  CLOSE l_get_org_price_csr;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_osp_line_id: ' || p_osp_line_id || ', Price: ' || l_price);
  END IF;
  RETURN l_price;
END Get_Item_Price;

--Added by mpothuku on 10-Oct-2007 for fixing the Bug 6436184
----------------------------------------
-- This function derived the charge_account_id
----------------------------------------
FUNCTION get_charge_account_id(
  p_inv_org_id  IN  NUMBER,
  p_item_id IN  NUMBER
) RETURN NUMBER IS

  CURSOR get_exp_acct_item_csr(c_inv_org_id IN NUMBER, c_item_id IN NUMBER) IS
    SELECT expense_account
      FROM mtl_system_items_b
     WHERE organization_id = c_inv_org_id
       AND inventory_item_id = c_item_id;

  CURSOR get_mtl_acct_org_csr(c_inv_org_id IN NUMBER) IS
    SELECT material_account
      FROM mtl_parameters
     WHERE organization_id = c_inv_org_id;

   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.get_charge_account_id';
   l_charge_acct_id NUMBER := null;
   l_item_account_set BOOLEAN := FALSE;

BEGIN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_inv_org_id: '|| p_inv_org_id);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_item_id: '|| p_item_id);
  END IF;

  IF(p_item_id is NULL) THEN
    --It is a one-time item
    l_item_account_set := FALSE;
  ELSE
    --Item is present, retrieve the item's expense account.
    OPEN get_exp_acct_item_csr(p_inv_org_id, p_item_id);
    FETCH get_exp_acct_item_csr INTO l_charge_acct_id;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_charge_acct_id from item: '|| l_charge_acct_id);
    END IF;
    CLOSE get_exp_acct_item_csr;
    IF(l_charge_acct_id is not NULL) THEN
      l_item_account_set := TRUE;
    ELSE
      --Expense account not set at the Item Level.
      l_item_account_set := FALSE;
    END IF;

  END IF;

  IF (l_item_account_set = FALSE) THEN
    --Retrieve the Org's Material Account Id
    OPEN get_mtl_acct_org_csr(p_inv_org_id);
    FETCH get_mtl_acct_org_csr INTO l_charge_acct_id;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_charge_acct_id from Org: '|| l_charge_acct_id);
    END IF;
    CLOSE get_mtl_acct_org_csr;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_charge_acct_id: '|| l_charge_acct_id);
  END IF;

  RETURN l_charge_acct_id;

END get_charge_account_id;
--mpothuku End

-- SATHAPLI::Bug 8583364, 21-Aug-2009
-- Function to create PO number, if PO numbering is set to 'MANUAL'. Accordingly, returns the created number, or NULL.
-- Creates PO number as the concatenation of the following:
-- 1) Profile 'AHL_OSP_PO_NUMBER_PREFIX' value - NULL or otherwise (only if 'MANUAL' PO numbering is set to 'ALPHANUMERIC' type).
-- 2) OSP Order Number.
FUNCTION create_manual_PO_Number
(
  p_org_id       IN NUMBER,
  p_osp_order_id IN NUMBER
) RETURN VARCHAR2 IS

  -- cursor to check if PO numbering is set to 'MANUAL'
  CURSOR chk_manual_PO_Numbering (c_org_id NUMBER) IS
    SELECT 'X'
    FROM   PO_SYSTEM_PARAMETERS_ALL
    WHERE  user_defined_po_num_code = 'MANUAL'
    AND    org_id                   = c_org_id;

  -- cursor to check if 'MANUAL' PO numbering type is set to 'ALPHANUMERIC'
  CURSOR chk_manual_PO_Num_Type (c_org_id NUMBER) IS
    SELECT 'X'
    FROM   PO_SYSTEM_PARAMETERS_ALL
    WHERE  manual_po_num_type = 'ALPHANUMERIC'
    AND    org_id             = c_org_id;

  -- cursor to get the OSP order number for a given order id
  CURSOR get_OSP_Order_Number (c_order_id NUMBER) IS
    SELECT osp_order_number
    FROM   AHL_OSP_ORDERS_B
    WHERE  osp_order_id = c_order_id;

  l_debug_key     CONSTANT VARCHAR2(150)                          := G_LOG_PREFIX || '.create_manual_PO_Number';
  l_manual_po_number       PO_HEADERS_INTERFACE.DOCUMENT_NUM%TYPE := NULL;
  l_osp_order_number       NUMBER;
  l_dummy                  VARCHAR2(1);

BEGIN

  -- check if PO numbering is set to 'MANUAL'
  OPEN chk_manual_PO_Numbering(p_org_id);
  FETCH chk_manual_PO_Numbering INTO l_dummy;
  IF (chk_manual_PO_Numbering%FOUND) THEN
    -- fetch the OSP order number for the OSP order id
    OPEN get_OSP_Order_Number(p_osp_order_id);
    FETCH get_OSP_Order_Number INTO l_osp_order_number;
    CLOSE get_OSP_Order_Number;

    -- if l_manual_po_number to be created exceeds the DB precision, raise error
    BEGIN
      -- check if 'MANUAL' PO numbering type is set to 'ALPHANUMERIC'
      OPEN chk_manual_PO_Num_Type(p_org_id);
      FETCH chk_manual_PO_Num_Type INTO l_dummy;
      IF (chk_manual_PO_Num_Type%FOUND) THEN
        -- prepend profile 'AHL_OSP_PO_NUMBER_PREFIX' value
        l_manual_po_number := FND_PROFILE.VALUE('AHL_OSP_PO_NUMBER_PREFIX');
      END IF;
      CLOSE chk_manual_PO_Num_Type;

      l_manual_po_number := l_manual_po_number || l_osp_order_number;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key,
                         'l_manual_po_number exceeded PO_HEADERS_INTERFACE.DOCUMENT_NUM%TYPE precision.');
        END IF;

        CLOSE chk_manual_PO_Numbering;

        FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_FIGURE_LENGTH_INVALID'); -- Entered value for Figure exceeded the limit
        FND_MSG_PUB.ADD;
        RAISE;
    END;
  END IF;
  CLOSE chk_manual_PO_Numbering;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key,
                   'l_manual_po_number to be returned => '||l_manual_po_number);
  END IF;

  RETURN l_manual_po_number;

END create_manual_PO_Number;

-------------------------------
-- End Local Procedures --
-------------------------------

END AHL_OSP_PO_PVT;

/

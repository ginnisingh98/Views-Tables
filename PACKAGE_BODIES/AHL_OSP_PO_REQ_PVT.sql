--------------------------------------------------------
--  DDL for Package Body AHL_OSP_PO_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_PO_REQ_PVT" AS
/* $Header: AHLVPRQB.pls 120.3 2008/04/08 23:13:25 jaramana noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'AHL_OSP_PO_REQ_PVT';
G_LOG_PREFIX                CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_OSP_PO_REQ_PVT';

G_NO_FLAG                   CONSTANT VARCHAR2(1)   := 'N';
G_YES_FLAG                  CONSTANT VARCHAR2(1)   := 'Y';

G_PO_APP_CODE               CONSTANT VARCHAR2(2)   := 'PO';
G_REQIMPORT_PROG_CODE       CONSTANT VARCHAR2(30)  := 'REQIMPORT';

-- OSP Order Statuses
G_OSP_ENTERED_STATUS        CONSTANT VARCHAR2(30)  := 'ENTERED';
G_OSP_SUBMITTED_STATUS      CONSTANT VARCHAR2(30)  := 'SUBMITTED';
G_OSP_SUB_FAILED_STATUS     CONSTANT VARCHAR2(30)  := 'SUBMISSION_FAILED';
G_OSP_REQ_SUB_FAILED_STATUS CONSTANT VARCHAR2(30)  := 'REQ_SUBMISSION_FAILED';
G_OSP_PO_CREATED_STATUS     CONSTANT VARCHAR2(30)  := 'PO_CREATED';
G_OSP_REQ_CREATED_STATUS    CONSTANT VARCHAR2(30)  := 'REQ_CREATED';
G_OSP_REQ_SUBMITTED_STATUS  CONSTANT VARCHAR2(30)  := 'REQ_SUBMITTED';
G_OSP_CLOSED_STATUS         CONSTANT VARCHAR2(30)  := 'CLOSED';

-- OSP Order Line Statuses
G_OL_REQ_CANCELLED_STATUS   CONSTANT VARCHAR2(30)  := 'REQ_CANCELLED';
G_OL_REQ_DELETED_STATUS     CONSTANT VARCHAR2(30)  := 'REQ_DELETED';

-- Log Constants: Transaction Types
G_TXN_TYPE_PO_REQ_CREATION  CONSTANT VARCHAR2(30)  := 'Requisition Creation';
G_TXN_TYPE_PO_SYNCH         CONSTANT VARCHAR2(30)  := 'PO Synchronization';

-- Log Constants: Document Types
G_DOC_TYPE_OSP              CONSTANT VARCHAR2(30)  := 'OSP';
G_DOC_TYPE_PO               CONSTANT VARCHAR2(30)  := 'PO';
G_DOC_TYPE_PO_REQ           CONSTANT VARCHAR2(30)  := 'REQ';

-- Default Values for One-time Items
G_DEFAULT_PRICE             CONSTANT NUMBER        := 0;
G_DEFAULT_CATEGORY_SEG1     CONSTANT VARCHAR2(40)  := 'MISC';
G_DEFAULT_CATEGORY_SEG2     CONSTANT VARCHAR2(40)  := 'MISC';

-- PO Line Types
G_PO_LINE_TYPE_QUANTITY     CONSTANT VARCHAR2(30)  := 'QUANTITY';

-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

TYPE PO_Req_Header_Rec_Type IS RECORD (
        OSP_ORDER_ID            NUMBER,
        OPERATING_UNIT_ID       NUMBER,
        VENDOR_ID               NUMBER,
        VENDOR_SITE_ID          NUMBER,
        BUYER_ID                NUMBER,
        DESCRIPTION             VARCHAR2(240),
        VENDOR_CONTACT_ID       NUMBER
        );

TYPE PO_Req_Line_Rec_Type IS RECORD (
        OSP_LINE_ID             NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        LINE_NUMBER             NUMBER,
        PO_LINE_TYPE_ID         NUMBER,
        ITEM_ID                 NUMBER,
        ITEM_DESCRIPTION        VARCHAR2(240),
        QUANTITY                NUMBER,
        UOM_CODE                VARCHAR2(3),
        NEED_BY_DATE            DATE,
        SHIP_TO_ORG_ID          NUMBER,
        SHIP_TO_LOC_ID          NUMBER,
        WIP_ENTITY_ID           NUMBER,
        PROJECT_ID              NUMBER,
        TASK_ID                 NUMBER
        );

TYPE PO_Req_Line_Tbl_Type IS TABLE OF PO_Req_Line_Rec_Type INDEX BY BINARY_INTEGER;

------------------------------
-- Declare Local Procedures --
------------------------------

-- Validate OSP Order for Req Header Creation
PROCEDURE Validate_PO_Req_Header(
   p_po_Req_header_rec IN PO_Req_Header_Rec_Type);

-- Validate Requisition Lines
PROCEDURE Validate_PO_Req_Lines(
   p_po_req_line_tbl IN PO_Req_Line_Tbl_Type,
   p_osp_order_id IN NUMBER);

-- Insert a record into the PO_REQUISITIONS_INTERFACE_ALL table
PROCEDURE Insert_Into_Req_Interface(
   p_po_req_hdr_rec  IN  PO_Req_Header_Rec_Type,
   p_po_req_line_tbl IN  PO_Req_Line_Tbl_Type,
   x_batch_id        OUT NOCOPY NUMBER);

-- Calls the Concurrent Program to Create Requisition
PROCEDURE Call_Req_Import_Program(
   p_batch_id     IN  NUMBER,
   p_osp_order_id IN  NUMBER,
   x_request_id   OUT NOCOPY NUMBER);

-- This Procedure updates a record of AHL_OSP_ORDERS_B using the table handler.
-- All updates to this table from this Package should go through this procedure only
PROCEDURE Update_OSP_Order(
   p_osp_order_id     IN NUMBER,
   p_po_req_header_id IN NUMBER    := NULL,
   p_batch_id         IN NUMBER    := NULL,
   p_request_id       IN NUMBER    := NULL,
   p_status_code      IN VARCHAR2  := NULL
);

-- This Local Procedure updates OSP Tables with Requisition Information for one OSP Order
PROCEDURE Associate_New_Req(
   p_osp_order_id     IN  NUMBER,
   x_po_req_header_id OUT NOCOPY NUMBER);

-- This Procedure updates AHL_OSP_ORDERS_B's PO_REQ_HEADER_ID and sets STATUS_CODE to REQUISITION_CREATED
PROCEDURE Set_PO_Req_Header_ID(
   p_osp_order_id     IN NUMBER,
   p_po_req_header_id IN NUMBER);

-- This Procedure updates AHL_OSP_ORDER_LINES.P_PO_REQ_LINE_ID
PROCEDURE Update_Osp_Order_Lines(
   p_osp_order_line_id IN NUMBER,
   p_po_req_line_id    IN NUMBER := NULL);

-- This Procedure updates AHL_OSP_ORDERS_B.STATUS_CODE to SUBMISSION_FAILED
PROCEDURE Set_Req_Submission_Failed(
   p_osp_order_id IN NUMBER);

-- This Procedure handles deleted Requisition Headers from Purchasing and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action
PROCEDURE Handle_Deleted_Req_Headers(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2);

-- This Procedure handles cancelled Req Lines and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action
PROCEDURE Handle_Cancelled_Req_Lines(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2);

-- This Procedure handles deleted Req Lines and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action
PROCEDURE Handle_Deleted_Req_Lines(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2);

-- Helper function to get the Charge Account Id to fill
-- po_requisitions_interface.CHARGE_ACCOUNT_ID, given the Item and Org.
FUNCTION get_charge_account_id
(
  p_inv_org_id  IN  NUMBER,
  p_item_id     IN  NUMBER
) RETURN NUMBER;

-----------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Create_PO_Requisition
--  Type              : Private
--  Function          : Validates OSP Information and inserts records into PO Requisition Interface tables
--                      Launches Concurrent Program to initiate PO Requisition creation
--                      Updates OSP table with request id, batch id and interface header id
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
--  Create_PO_Requisition Parameters:
--      p_osp_order_id                  IN      NUMBER  Required
--         The Id of the OSP Order for which to create the Purchase Requisition
--      p_osp_order_number              IN      NUMBER  Required
--         The Number of the OSP Order for which to create the Purchase Requisition
--      x_batch_id                      OUT     NUMBER              Required
--         Contains the batch id if the concurrent program was launched successfuly.
--      x_request_id                    OUT     NUMBER              Required
--         Contains the concurrent request id if the concurrent program was launched successfuly.
--
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_PO_Requisition
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN            VARCHAR2  := NULL,
    p_osp_order_id          IN            NUMBER    := NULL,  -- Required if Number is not given
    p_osp_order_number      IN            NUMBER    := NULL,  -- Required if Id is not given
    x_batch_id              OUT  NOCOPY   NUMBER,
    x_request_id            OUT  NOCOPY   NUMBER,
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Create_PO_Requisition';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_PO_Requisition';

  CURSOR l_osp_id_csr(p_osp_order_number IN NUMBER) IS
    SELECT OSP_ORDER_ID
    FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_NUMBER = p_osp_order_number;

  CURSOR l_osp_dtls_csr(p_osp_order_id IN NUMBER) IS
    SELECT B.VENDOR_ID,
           B.VENDOR_SITE_ID,
           B.OPERATING_UNIT_ID,
           B.PO_AGENT_ID,
           B.PO_BATCH_ID,
           TL.DESCRIPTION,
           B.PO_INTERFACE_HEADER_ID,
           B.VENDOR_CONTACT_ID,
           B.STATUS_CODE
    FROM   AHL_OSP_ORDERS_B B, AHL_OSP_ORDERS_TL TL
    WHERE  B.OSP_ORDER_ID  = p_osp_order_id
    AND    TL.OSP_ORDER_ID = B.OSP_ORDER_ID
    AND    TL.LANGUAGE     = userenv('LANG');

  CURSOR l_osp_line_dtls_csr(p_osp_order_id IN NUMBER) IS
    SELECT OL.OSP_ORDER_LINE_ID,
           OL.OBJECT_VERSION_NUMBER,
           OL.OSP_LINE_NUMBER,
           OL.SERVICE_ITEM_ID,
           OL.SERVICE_ITEM_DESCRIPTION,
           OL.QUANTITY,
           OL.NEED_BY_DATE,
           OL.SERVICE_ITEM_UOM_CODE,
           OL.PO_LINE_TYPE_ID,
           OL.INVENTORY_ORG_ID,
           DECODE(OL.WORKORDER_ID, NULL, HAOU.LOCATION_ID, BOM.LOCATION_ID),
           WO.WIP_ENTITY_ID,
           WDJ.PROJECT_ID,
           WDJ.TASK_ID
    FROM AHL_OSP_ORDER_LINES OL, AHL_WORKORDERS WO, BOM_DEPARTMENTS BOM, HR_ALL_ORGANIZATION_UNITS HAOU, WIP_DISCRETE_JOBS WDJ
    WHERE OL.OSP_ORDER_ID = p_osp_order_id AND
          WO.WORKORDER_ID (+) = OL.WORKORDER_ID AND
          WDJ.WIP_ENTITY_ID (+) = WO.WIP_ENTITY_ID AND
          BOM.DEPARTMENT_ID (+) = WDJ.OWNING_DEPARTMENT AND
          HAOU.ORGANIZATION_ID = OL.INVENTORY_ORG_ID
    ORDER BY OL.OSP_LINE_NUMBER;

  CURSOR get_return_to_org_csr(p_osp_line_id IN NUMBER) IS
    SELECT oola.ship_from_org_id, HAOU.LOCATION_ID
    FROM oe_order_lines_all oola, ahl_osp_order_lines aool, HR_ALL_ORGANIZATION_UNITS HAOU
    WHERE oola.line_id = aool.oe_return_line_id and
          HAOU.ORGANIZATION_ID = oola.ship_from_org_id and
          aool.osp_order_line_id = p_osp_line_id;

   l_po_req_header          PO_Req_Header_Rec_Type;
   l_po_req_line_tbl        PO_Req_Line_Tbl_Type;
   l_intf_hdr_id            NUMBER;
   l_batch_id               NUMBER;
   l_old_batch_id           NUMBER := null;
   l_old_intf_header_id     NUMBER := null;
   l_request_id             NUMBER := 0;
   l_temp_num               NUMBER := 0;
   l_temp_ret_org_id        NUMBER;
   l_temp_ret_org_loc_id    NUMBER;
   l_status                 VARCHAR2(30);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Create_PO_Requisition_pvt;

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

  -- Start processing

  -- Create the Header Rec
  IF (p_osp_order_id IS NOT NULL) THEN
    l_po_req_header.OSP_ORDER_ID := p_osp_order_id;
  ELSE
    -- Convert the Order number to Id
    OPEN l_osp_id_csr(p_osp_order_number);
    FETCH l_osp_id_csr INTO l_po_req_header.OSP_ORDER_ID;
    CLOSE l_osp_id_csr;
  END IF;

  OPEN l_osp_dtls_csr(l_po_req_header.OSP_ORDER_ID);
  FETCH l_osp_dtls_csr INTO l_po_req_header.VENDOR_ID,
                            l_po_req_header.VENDOR_SITE_ID,
                            l_po_req_header.OPERATING_UNIT_ID,
                            l_po_req_header.BUYER_ID,
                            l_old_batch_id,        -- For Purging Interface table records
                            l_po_req_header.DESCRIPTION,
                            l_old_intf_header_id,  -- For Purging Interface table records
                            l_po_req_header.VENDOR_CONTACT_ID,
                            l_status;
  CLOSE l_osp_dtls_csr;

  -- Validate Header
  Validate_PO_Req_Header(l_po_req_header);
  -- Create the Lines Table
  OPEN l_osp_line_dtls_csr(p_osp_order_id);
  LOOP
    FETCH l_osp_line_dtls_csr INTO l_po_req_line_tbl(l_temp_num).OSP_LINE_ID,
                                   l_po_req_line_tbl(l_temp_num).OBJECT_VERSION_NUMBER,
                                   l_po_req_line_tbl(l_temp_num).LINE_NUMBER,
                                   l_po_req_line_tbl(l_temp_num).ITEM_ID,
                                   l_po_req_line_tbl(l_temp_num).ITEM_DESCRIPTION,
                                   l_po_req_line_tbl(l_temp_num).QUANTITY,
                                   l_po_req_line_tbl(l_temp_num).NEED_BY_DATE,
                                   l_po_req_line_tbl(l_temp_num).UOM_CODE,
                                   l_po_req_line_tbl(l_temp_num).PO_LINE_TYPE_ID,
                                   l_po_req_line_tbl(l_temp_num).SHIP_TO_ORG_ID,
                                   l_po_req_line_tbl(l_temp_num).SHIP_TO_LOC_ID,
                                   l_po_req_line_tbl(l_temp_num).WIP_ENTITY_ID,
                                   l_po_req_line_tbl(l_temp_num).PROJECT_ID,
                                   l_po_req_line_tbl(l_temp_num).TASK_ID;

    EXIT WHEN l_osp_line_dtls_csr%NOTFOUND;

    OPEN get_return_to_org_csr(l_po_req_line_tbl(l_temp_num).OSP_LINE_ID);
    FETCH get_return_to_org_csr INTO l_temp_ret_org_id, l_temp_ret_org_loc_id;
    IF (get_return_to_org_csr%FOUND AND l_temp_ret_org_id IS NOT NULL) THEN
      IF (l_temp_ret_org_id <> l_po_req_line_tbl(l_temp_num).SHIP_TO_ORG_ID) THEN
        l_po_req_line_tbl(l_temp_num).SHIP_TO_ORG_ID := l_temp_ret_org_id;
        -- Update the Ship To Location also from the Line's Inventory Org
        -- if the Return To Org is different
        l_po_req_line_tbl(l_temp_num).SHIP_TO_LOC_ID := l_temp_ret_org_loc_id;
      END IF;
    END IF;
    CLOSE get_return_to_org_csr;

    l_temp_num := l_temp_num + 1;
  END LOOP;
  CLOSE l_osp_line_dtls_csr;
  l_po_req_line_tbl.DELETE(l_temp_num);  -- Delete the last (null) record
  -- Validate Lines
  Validate_PO_Req_Lines(l_po_req_line_tbl, l_po_req_header.OSP_ORDER_ID);
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Insert Rows into PO_REQUISITIONS_INTERFACE_ALL

  -- Purge Error records from prior submission (if any)
  IF (l_status = G_OSP_REQ_SUB_FAILED_STATUS) THEN
      DELETE FROM po_interface_errors
          WHERE INTERFACE_TRANSACTION_ID in
                (SELECT transaction_id
                  FROM po_requisitions_interface_all
                 WHERE INTERFACE_SOURCE_CODE    = AHL_GLOBAL.AHL_APP_SHORT_NAME
                   AND INTERFACE_SOURCE_LINE_ID = l_po_req_header.OSP_ORDER_ID);
      DELETE FROM po_requisitions_interface_all
            WHERE INTERFACE_SOURCE_CODE    = AHL_GLOBAL.AHL_APP_SHORT_NAME
              AND INTERFACE_SOURCE_LINE_ID = l_po_req_header.OSP_ORDER_ID;

  ELSIF(l_status = G_OSP_SUB_FAILED_STATUS and l_old_intf_header_id IS NOT NULL) THEN
    -- Earlier, User tried to create a PO (not a requisition) and that failed.
    DELETE FROM PO_INTERFACE_ERRORS WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
    DELETE FROM PO_HEADERS_INTERFACE WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
    DELETE FROM PO_LINES_INTERFACE WHERE
      INTERFACE_HEADER_ID = l_old_intf_header_id;
  END IF;

  Insert_Into_Req_Interface(p_po_req_hdr_rec  => l_po_req_header,
                            p_po_req_line_tbl => l_po_req_line_tbl,
                            x_batch_id        => l_batch_id);

  -- Launch Concurrent Program to create PO Requisition
  Call_Req_Import_Program(p_batch_id     => l_batch_id,
                          p_osp_order_id => l_po_req_header.OSP_ORDER_ID,
                          x_request_id   => l_request_id);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'PO Req Concurrent Program Request Submitted. Request Id = ' || l_request_id);
  END IF;
  -- Check if request was submitted without error
  IF (l_request_id = 0) THEN
    -- Add Error Message generated by Concurrent Manager to Message List
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Update OSP Table with batch id, request id
  Update_OSP_Order(p_osp_order_id => p_osp_order_id,
                   p_batch_id     => l_batch_id,
                   p_request_id   => l_request_id);

  -- Set Return parameters
  x_batch_id   := l_batch_id;
  x_request_id := l_request_id;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing. Checking for errors');
  END IF;
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Log this transaction in the Log Table
  AHL_OSP_UTIL_PKG.Log_Transaction(p_trans_type_code    => G_TXN_TYPE_PO_REQ_CREATION,
                                   p_src_doc_id         => p_osp_order_id,
                                   p_src_doc_type_code  => G_DOC_TYPE_OSP,
                                   p_dest_doc_id        => l_batch_id,
                                   p_dest_doc_type_code => G_DOC_TYPE_PO_REQ);

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
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
   ROLLBACK TO Create_PO_Requisition_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Create_PO_Requisition_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO Create_PO_Requisition_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_PO_Requisition',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END Create_PO_Requisition;

-- Start of Comments --
--  Procedure name    : PO_Synch_All_Requisitions
--  Type              : Private
--  Function          : Synchronizes all OSPs based on the Requisition Status
--                      1. Handles successfully completed Requisition Submissions (Updates OSP tables)
--                      2. Handles failed Requisition Submissions (Updates OSP Status)
--                      3. Handles Cancelled Requisition Lines (Updates OSP Line status, deletes shipment lines)
--                      4. Handles Deleted Requisition Lines  (Updates OSP Line status, deletes shipment lines)
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
--  PO_Synch_All_Requisitions parameters:
--      p_concurrent_flag               IN      VARCHAR2     Default  N.
--        Writes debug Information to Concurrent Program's Log File if set to 'Y'
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE PO_Synch_All_Requisitions
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
   l_api_name               CONSTANT VARCHAR2(30) := 'PO_Synch_All_Requisitions';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.PO_Synch_All_Requisitions';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- No need of a Savepoint: Individual procedures commit or rollback
  -- within themselves.

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
     fnd_file.put_line(fnd_file.log, 'Starting Requisition Synch process...');
  END IF;

  -- First make all associations (PO Req Header Id, PO Req Line Id, Status updates)
  Associate_All_New_Reqs(p_api_version   => 1.0,
                         p_commit        => p_commit,  --Commit this independent of other operations
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Associating OSPs with POs');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Associating OSPs with Requisitions, Return Status = ' || x_return_status);
  END IF;

  Handle_Deleted_Req_Headers(p_commit        => p_commit,  --Commit this independent of other operations
                             x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Deleted PO Requisition Headers.');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Deleted PO Requisition Headers, Return Status = ' || x_return_status);
  END IF;


  -- Handle Canceled PO Requisitions
  Handle_Cancelled_Req_Lines(p_commit        => p_commit,   --Commit this independent of other operations
                             x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Cancelled PO Requisition Lines.');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Cancelled PO Requisition Lines, Return Status = ' || x_return_status);
  END IF;

  -- Handle Deleted PO Requisition Lines
  Handle_Deleted_Req_Lines(p_commit        => p_commit,  --Commit this independent of other operations
                           x_return_status => x_return_status);
  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Handling Deleted PO Requisition Lines.');
     fnd_file.put_line(fnd_file.log, 'Return Status = ' || x_return_status);
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Handling Deleted PO Requisition Lines, Return Status = ' || x_return_status);
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing. Checking for errors.');
  END IF;

  IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Completed Requisition Synch Process. Checking for errors.');
  END IF;
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
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'PO_Synch_All_Requisitions',
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

END PO_Synch_All_Requisitions;

----------------------------------------

-- Start of Comments --
--  Procedure name    : Associate_All_New_Reqs
--  Type              : Private
--  Function          : Updates AHL_OSP_ORDERS_B.PO_REQ_HEADER_ID and
--                      AHL_OSP_ORDER_LINES.PO_REQ_LINE_ID with REQUISITION_HEADER_ID and
--                      REQUISITION_LINE_ID respectively for all submitted OSP Orders (for Requisitions).
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

PROCEDURE Associate_All_New_Reqs
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

  CURSOR l_get_osps_for_reqs_csr IS
    SELECT OSP_ORDER_ID FROM AHL_OSP_ORDERS_B
    WHERE STATUS_CODE = G_OSP_REQ_SUBMITTED_STATUS
      AND PO_REQ_HEADER_ID IS NULL
      AND PO_BATCH_ID IS NOT NULL
      -- Added by jaramana on April 7, 2008 for bug 6609988
      AND OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id();

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Associate_All_New_Reqs';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Associate_All_New_Reqs';
   l_dummy                  VARCHAR2(1);
   l_osp_order_id           NUMBER;
   l_po_req_header_id       NUMBER;
   l_temp_count             NUMBER := 0;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Associate_All_New_Reqs_pvt;

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
  OPEN l_get_osps_for_reqs_csr;
  LOOP
    FETCH l_get_osps_for_reqs_csr INTO l_osp_order_id;
    EXIT WHEN l_get_osps_for_reqs_csr%NOTFOUND;
    Associate_New_Req(p_osp_order_id     => l_osp_order_id,
                      x_po_req_header_id => l_po_req_header_id);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Associated OSP Order with Id ' || l_osp_order_id || ' to Requisition with Id ' || l_po_req_header_id);
    END IF;
    l_temp_count := l_temp_count + 1;
  END LOOP;
  CLOSE l_get_osps_for_reqs_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Associated ' || l_temp_count || ' OSP Orders with Requisitions');
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing. Checking for errors.');
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
   ROLLBACK TO Associate_All_New_Reqs_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                             p_data    => x_msg_data,
                             p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Associate_All_New_Reqs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                             p_data    => x_msg_data,
                             p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
   ROLLBACK TO Associate_All_New_Reqs_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'Associate_All_New_Reqs',
                             p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                             p_data    => x_msg_data,
                             p_encoded => fnd_api.g_false);

END Associate_All_New_Reqs;

-------------------------------------------------------------------------
-- This Procedure inserts a record into the PO_REQUISITIONS_INTERFACE_ALL table
-------------------------------------------------------------------------
PROCEDURE Insert_Into_Req_Interface
(
   p_po_req_hdr_rec  IN  PO_Req_Header_Rec_Type,
   p_po_req_line_tbl IN  PO_Req_Line_Tbl_Type,
   x_batch_id        OUT NOCOPY NUMBER
) IS

  l_org_id           NUMBER       := NULL;
  l_price            NUMBER       := NULL;
  l_category         VARCHAR2(30) := NULL;
  l_category_seg1    VARCHAR2(40) := NULL;
  l_category_seg2    VARCHAR2(40) := NULL;
  l_charge_acct_id   NUMBER       := NULL;

  CURSOR get_prj_task_comp_date_csr (c_task_id IN NUMBER) IS
    SELECT COMPLETION_DATE from pa_tasks
     where task_id = c_task_id;

  l_task_completion_date DATE;
  l_expenditure_item_type pa_expenditure_types.expenditure_type%type;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Insert_Into_Req_Interface';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the current Org to get Item Price
  l_org_id := MO_GLOBAL.get_current_org_id();

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_po_req_line_tbl.count: '|| p_po_req_line_tbl.count);
  END IF;

  FOR i IN p_po_req_line_tbl.FIRST..p_po_req_line_tbl.LAST LOOP
    IF (p_po_req_line_tbl(i).ITEM_ID IS NULL) THEN
      -- One time items defaulting
      l_price         := G_DEFAULT_PRICE;
      l_category_seg1 := G_DEFAULT_CATEGORY_SEG1;
      l_category_seg2 := G_DEFAULT_CATEGORY_SEG2;
    ELSE
      -- Purchasing defaults the category from the item
      l_category_seg1 := null;
      l_category_seg2 := null;

      /*
      Item pricing information is also derived in the UNIT_PRICE and CURRENCY_UNIT_PRICE columns.
      If no sourcing rules are found for the item, supplier sourcing fails and the UNIT_PRICE is
      defaulted from the item master for supplier requisition lines
      */
      l_price := null;
    END IF;

     -- Insert row into PO_REQUISITIONS_INTERFACE_ALL
    l_charge_acct_id := get_charge_account_id(p_po_req_line_tbl(i).SHIP_TO_ORG_ID, p_po_req_line_tbl(i).ITEM_ID);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_charge_acct_id before inserting: '|| l_charge_acct_id);
    END IF;

    -- Project related fields to link the distributions to Projects
    IF p_po_req_line_tbl(i).TASK_ID IS NOT NULL THEN
      OPEN get_prj_task_comp_date_csr(p_po_req_line_tbl(i).TASK_ID);
      FETCH get_prj_task_comp_date_csr INTO l_task_completion_date;
      CLOSE get_prj_task_comp_date_csr;
    ELSE
      l_task_completion_date := NULL;
    END IF;

    l_expenditure_item_type := FND_PROFILE.VALUE('AHL_OSP_EXPENDITURE_TYPE');
    IF(l_expenditure_item_type IS NULL) THEN
      l_expenditure_item_type := 'Outside Processing';
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_task_completion_date : '|| to_char(l_task_completion_date, 'DD-MON-YYYY HH24:MI:SS'));
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_expenditure_item_type : '|| l_expenditure_item_type);
    END IF;

    INSERT INTO po_requisitions_interface_all
    (
        INTERFACE_SOURCE_CODE,
        INTERFACE_SOURCE_LINE_ID,
        REFERENCE_NUM,
        LINE_TYPE_ID,
        SOURCE_TYPE_CODE,
        DESTINATION_TYPE_CODE,
        AUTHORIZATION_STATUS,
        PREPARER_ID,
        ITEM_ID,
        ITEM_DESCRIPTION,
        QUANTITY,
        CATEGORY_SEGMENT1,
        CATEGORY_SEGMENT2,
        UOM_CODE,
        UNIT_PRICE,
        NEED_BY_DATE,
        DESTINATION_ORGANIZATION_ID,
        DELIVER_TO_LOCATION_ID,
        DELIVER_TO_REQUESTOR_ID,
        SUGGESTED_BUYER_ID,
        SUGGESTED_VENDOR_ID,
        SUGGESTED_VENDOR_SITE_ID,
        SUGGESTED_VENDOR_CONTACT_ID,
        HEADER_DESCRIPTION,
        --Project related fields to link the distributions to Projects
        WIP_ENTITY_ID,
        PROJECT_ID,
        TASK_ID,
        --Project related fields End
        GROUP_CODE,
        BATCH_ID,
        ORG_ID,
        PROGRAM_ID,
        PROGRAM_APPLICATION_ID,
        CHARGE_ACCOUNT_ID,
        --Project related fields to link the distributions to Projects
        PROJECT_ACCOUNTING_CONTEXT,
        EXPENDITURE_TYPE,
        EXPENDITURE_ORGANIZATION_ID,
        EXPENDITURE_ITEM_DATE
        --Project related fields End
      )
      VALUES
      (
        AHL_GLOBAL.AHL_APP_SHORT_NAME,          --INTERFACE_SOURCE_CODE
        p_po_req_hdr_rec.OSP_ORDER_ID,          --INTERFACE_SOURCE_LINE_ID
        p_po_req_line_tbl(i).OSP_LINE_ID,       --REFERENCE_NUM
        p_po_req_line_tbl(i).PO_LINE_TYPE_ID,   --LINE_TYPE_ID
        'VENDOR',                               --SOURCE_TYPE_CODE
        'EXPENSE',                              --DESTINATION_TYPE_CODE
        'INCOMPLETE',                           --AUTHORIZATION_STATUS
        FND_GLOBAL.EMPLOYEE_ID,                 --PREPARER_ID (Should be logged in user)
        p_po_req_line_tbl(i).ITEM_ID,           --ITEM_ID
        p_po_req_line_tbl(i).ITEM_DESCRIPTION,  --ITEM_DESCRIPTION
        p_po_req_line_tbl(i).QUANTITY,          --QUANTITY
        l_category_seg1,                        --CATEGORY_SEGMENT1
        l_category_seg2,                        --CATEGORY_SEGMENT2
        p_po_req_line_tbl(i).UOM_CODE,          --UOM_CODE
        l_price,                                --UNIT_PRICE
        p_po_req_line_tbl(i).NEED_BY_DATE,      --NEED_BY_DATE
        p_po_req_line_tbl(i).SHIP_TO_ORG_ID,    --DESTINATION_ORGANIZATION_ID
        p_po_req_line_tbl(i).SHIP_TO_LOC_ID,    --DELIVER_TO_LOCATION_ID
        FND_GLOBAL.EMPLOYEE_ID,                 --DELIVER_TO_REQUESTOR_ID
        p_po_req_hdr_rec.BUYER_ID,              --SUGGESTED_BUYER_ID
        p_po_req_hdr_rec.VENDOR_ID,             --SUGGESTED_VENDOR_ID
        p_po_req_hdr_rec.VENDOR_SITE_ID,        --SUGGESTED_VENDOR_SITE_ID
        p_po_req_hdr_rec.VENDOR_CONTACT_ID,     --SUGGESTED_VENDOR_CONTACT_ID
        SUBSTR(p_po_req_hdr_rec.DESCRIPTION, 1, 240),  --HEADER_DESCRIPTION

        p_po_req_line_tbl(i).WIP_ENTITY_ID,     --WIP_ENTITY_ID
        p_po_req_line_tbl(i).PROJECT_ID,        --PROJECT_ID
        p_po_req_line_tbl(i).TASK_ID,           --TASK_ID

        p_po_req_hdr_rec.OSP_ORDER_ID,          --GROUP_CODE
        p_po_req_hdr_rec.OSP_ORDER_ID,          --BATCH_ID
        p_po_req_hdr_rec.OPERATING_UNIT_ID,     --ORG_ID
        AHL_GLOBAL.AHL_OSP_PROGRAM_ID,          --PROGRAM_ID
        AHL_GLOBAL.AHL_APPLICATION_ID,          --PROGRAM_APPLICATION_ID
        l_charge_acct_id,                       --CHARGE_ACCOUNT_ID

        decode(p_po_req_line_tbl(i).PROJECT_ID, null, null, 'Y'), --PROJECT_ACCOUNTING_CONTEXT
        decode(p_po_req_line_tbl(i).PROJECT_ID, null, null, l_expenditure_item_type), --EXPENDITURE_TYPE
        decode(p_po_req_line_tbl(i).PROJECT_ID, null, null, p_po_req_line_tbl(i).SHIP_TO_ORG_ID),  --EXPENDITURE_ORGANIZATION_ID
        l_task_completion_date --EXPENDITURE_ITEM_DATE
      );

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
            ' Inserting into po_requisitions_interface_all: '||
            ' WIP_ENTITY_ID = ' || p_po_req_line_tbl(i).WIP_ENTITY_ID ||
            ', PROJECT_ID = ' || p_po_req_line_tbl(i).PROJECT_ID ||
            ', TASK_ID = ' || p_po_req_line_tbl(i).TASK_ID ||
            ', EXPENDITURE_TYPE = ' || l_expenditure_item_type ||
            ', EXPENDITURE_ORGANIZATION_ID = ' || p_po_req_line_tbl(i).SHIP_TO_ORG_ID ||
            ', EXPENDITURE_ITEM_DATE = ' || to_char(l_task_completion_date, 'DD-MON-YYYY HH24:MI:SS'));
      END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Inserted One Record.');
    END IF;

  END LOOP;
  x_batch_id := p_po_req_hdr_rec.OSP_ORDER_ID;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Insert_Into_Req_Interface;

----------------------------------------
-- This Procedure calls the Concurrent Program to
-- Create a Purchasing Requisition
----------------------------------------
PROCEDURE Call_Req_Import_Program(
   p_batch_id     IN  NUMBER,
   p_osp_order_id IN  NUMBER,
   x_request_id   OUT NOCOPY NUMBER) IS

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Call_Req_Import_Program';
  l_curr_org_id            NUMBER;

BEGIN
  -- Added by jaramana on Feb 7, 2008
  l_curr_org_id := MO_GLOBAL.get_current_org_id();
  FND_REQUEST.SET_ORG_ID(l_curr_org_id);

  x_request_id := FND_REQUEST.SUBMIT_REQUEST(
          application => G_PO_APP_CODE,
          program     => G_REQIMPORT_PROG_CODE,
          argument1   => AHL_GLOBAL.AHL_APP_SHORT_NAME,  -- Origin of requisition (INTERFACE_SOURCE_CODE)
          argument2   => p_osp_order_id,  -- ID of batch to be imported (BATCH_ID)
          argument3   => p_osp_order_id,  -- Parameter to group reqs by (GROUP_BY)
          argument4   => NULL,  -- Last Requisition Number
          argument5   => 'N',   -- Speicfies if Multiple Distributions are to be created
          argument6   => 'N'   -- Specifies if requisition approval has to be initiated
          );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Request Submitted. Request Id = ' || x_request_id);
  END IF;
END Call_Req_Import_Program;

-----------------------------------------------------------------------
-- This Procedure validates the OSP Order for PO Requisition Creation
-----------------------------------------------------------------------
PROCEDURE Validate_PO_Req_Header(
   p_po_req_header_rec IN PO_Req_Header_Rec_Type) IS

  CURSOR l_validate_osp_csr(p_osp_order_id IN NUMBER) IS
    SELECT 'x' FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id
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
  L_DEBUG_KEY   CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_PO_Req_Header';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- OSP Order Id
  IF (p_po_req_header_rec.OSP_ORDER_ID IS NULL OR p_po_req_header_rec.OSP_ORDER_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_osp_csr(p_po_req_header_rec.OSP_ORDER_ID);
    FETCH l_validate_osp_csr INTO l_dummy;
    IF (l_validate_osp_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_OSP_ID_INVALID');
      FND_MESSAGE.Set_Token('OSP_ID', p_po_req_header_rec.OSP_ORDER_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_osp_csr;
  END IF;

  -- Supplier
  IF (p_po_req_header_rec.VENDOR_ID IS NULL OR p_po_req_header_rec.VENDOR_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SUPPLIER_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_supplier_csr(p_po_req_header_rec.VENDOR_ID);
    FETCH l_validate_supplier_csr INTO l_dummy;
    IF (l_validate_supplier_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SUPP_INVALID');
      FND_MESSAGE.Set_Token('SUPP_ID', p_po_req_header_rec.VENDOR_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_supplier_csr;
  END IF;

  -- Supplier Site
  IF (p_po_req_header_rec.VENDOR_SITE_ID IS NULL OR p_po_req_header_rec.VENDOR_SITE_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SSITE_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_supp_site_csr(p_po_req_header_rec.VENDOR_SITE_ID, p_po_req_header_rec.VENDOR_ID);
    FETCH l_validate_supp_site_csr INTO l_dummy;
    IF (l_validate_supp_site_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SSITE_INVALID');
      FND_MESSAGE.Set_Token('SS_ID', p_po_req_header_rec.VENDOR_SITE_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_supp_site_csr;
  END IF;

  -- Vendor Contact (Optional)
  IF (p_po_req_header_rec.VENDOR_CONTACT_ID IS NOT NULL AND p_po_req_header_rec.VENDOR_CONTACT_ID <> FND_API.G_MISS_NUM) THEN
    OPEN l_validate_vendor_contact_csr(p_po_req_header_rec.VENDOR_CONTACT_ID, p_po_req_header_rec.VENDOR_SITE_ID);
    FETCH l_validate_vendor_contact_csr INTO l_dummy;
    IF (l_validate_vendor_contact_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_VCONTACT_INVALID');
      FND_MESSAGE.Set_Token('V_CONTACT_ID', p_po_req_header_rec.VENDOR_CONTACT_ID);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE l_validate_vendor_contact_csr;
  END IF;

  -- Buyer
  IF (p_po_req_header_rec.BUYER_ID IS NULL OR p_po_req_header_rec.BUYER_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_BUYER_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN l_validate_buyer_csr(p_po_req_header_rec.BUYER_ID);
    FETCH l_validate_buyer_csr INTO l_dummy;
    IF (l_validate_buyer_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_BUYER_INVALID');
      FND_MESSAGE.Set_Token('BUYER_ID', p_po_req_header_rec.BUYER_ID);
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

END Validate_PO_Req_Header;

----------------------------------------------------
-- This Procedure validates the PO Requisition Lines
----------------------------------------------------
PROCEDURE Validate_PO_Req_Lines(
   p_po_req_line_tbl  IN PO_Req_Line_Tbl_Type,
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

  -- Non zero count
  IF (p_po_req_line_tbl.COUNT = 0) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_NO_PO_LINES');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RETURN;  -- Cannot do any further validation
  END IF;

  FOR i IN p_po_req_line_tbl.FIRST..p_po_req_line_tbl.LAST LOOP
    -- Item
    IF (p_po_req_line_tbl(i).ITEM_ID IS NOT NULL AND p_po_req_line_tbl(i).ITEM_ID <> FND_API.G_MISS_NUM) THEN
      -- Non One-time Item
      OPEN l_validate_item_csr(p_po_req_line_tbl(i).ITEM_ID, p_po_req_line_tbl(i).SHIP_TO_ORG_ID);
      FETCH l_validate_item_csr INTO l_dummy;
      IF (l_validate_item_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_ITEM_INVALID');
        FND_MESSAGE.Set_Token('ITEM', p_po_req_line_tbl(i).ITEM_ID);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
      CLOSE l_validate_item_csr;
    ELSE
      -- One-time Item: Description is mandatory
      IF (TRIM(p_po_req_line_tbl(i).ITEM_DESCRIPTION) IS NULL OR p_po_req_line_tbl(i).ITEM_DESCRIPTION = FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_IDESC_NULL');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
      -- One-time Item: UOM is mandatory
      IF (TRIM(p_po_req_line_tbl(i).UOM_CODE) IS NULL OR p_po_req_line_tbl(i).UOM_CODE = FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_UOM_CODE_NULL');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
    END IF;

    -- Quantity
    IF (p_po_req_line_tbl(i).QUANTITY IS NULL OR p_po_req_line_tbl(i).QUANTITY = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_QUANTITY_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      IF (p_po_req_line_tbl(i).QUANTITY <= 0) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_QUANTITY_INVALID');
        FND_MESSAGE.Set_Token('QUANTITY', p_po_req_line_tbl(i).QUANTITY);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
    END IF;

    -- Need By Date
    IF (p_po_req_line_tbl(i).NEED_BY_DATE IS NULL OR p_po_req_line_tbl(i).NEED_BY_DATE = FND_API.G_MISS_DATE) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_NEED_BY_DATE_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      IF (TRUNC(p_po_req_line_tbl(i).NEED_BY_DATE) < TRUNC(SYSDATE)) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_NBDATE_INVALID');
        FND_MESSAGE.Set_Token('NBDATE', p_po_req_line_tbl(i).NEED_BY_DATE);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
    END IF;

    -- Ship To Organization
    IF (p_po_req_line_tbl(i).SHIP_TO_ORG_ID IS NULL OR p_po_req_line_tbl(i).SHIP_TO_ORG_ID = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_SHIP_TO_ORG_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;

    -- Line Type
    IF (p_po_req_line_tbl(i).PO_LINE_TYPE_ID IS NULL OR p_po_req_line_tbl(i).PO_LINE_TYPE_ID = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_LN_TYPE_ID_NULL');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      OPEN l_validate_line_type_csr(p_po_req_line_tbl(i).PO_LINE_TYPE_ID);
      FETCH l_validate_line_type_csr INTO l_dummy;
      IF (l_validate_line_type_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_LN_TYPE_ID_INVALID');
        FND_MESSAGE.Set_Token('LINE_TYPE_ID', p_po_req_line_tbl(i).PO_LINE_TYPE_ID);
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
END Validate_PO_Req_Lines;

----------------------------------------
-- This Procedure updates a record of AHL_OSP_ORDERS_B using the table handler
-- All updates to this table from this Package should go through this procedure only
----------------------------------------
PROCEDURE Update_OSP_Order(
   p_osp_order_id     IN NUMBER,
   p_po_req_header_id IN NUMBER   := NULL,
   p_batch_id         IN NUMBER   := NULL,
   p_request_id       IN NUMBER   := NULL,
   p_status_code      IN VARCHAR2 := NULL
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
      PO_REQ_HEADER_ID,
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
      DESCRIPTION
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
  IF (p_po_req_header_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_REQ_HEADER_ID := p_po_req_header_id;
  END IF;
  IF (p_batch_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_BATCH_ID := p_batch_id;
  END IF;
  IF (p_request_id IS NOT NULL) THEN
    l_osp_dtls_rec.PO_REQUEST_ID := p_request_id;
  END IF;
  IF (p_status_code IS NOT NULL) THEN
    l_osp_dtls_rec.STATUS_CODE := p_status_code;
  END IF;

  -- Call Table Handler
  AHL_OSP_ORDERS_PKG.UPDATE_ROW(
    X_OSP_ORDER_ID          => p_osp_order_id,
    X_OBJECT_VERSION_NUMBER => l_osp_dtls_rec.OBJECT_VERSION_NUMBER + 1,  -- Updated
    X_OSP_ORDER_NUMBER      => l_osp_dtls_rec.OSP_ORDER_NUMBER,
    X_ORDER_TYPE_CODE       => l_osp_dtls_rec.ORDER_TYPE_CODE,
    X_SINGLE_INSTANCE_FLAG  => l_osp_dtls_rec.SINGLE_INSTANCE_FLAG,
    X_PO_HEADER_ID          => l_osp_dtls_rec.PO_HEADER_ID,
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
    X_PO_INTERFACE_HEADER_ID => l_osp_dtls_rec.PO_INTERFACE_HEADER_ID,
    X_PO_REQ_HEADER_ID      => l_osp_dtls_rec.PO_REQ_HEADER_ID,  -- Updated
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
    X_LAST_UPDATE_DATE      => TRUNC(sysdate),  -- Updated
    X_LAST_UPDATED_BY       => fnd_global.user_id,  -- Updated
    X_LAST_UPDATE_LOGIN     => fnd_global.login_id);  -- Updated
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Update_OSP_Order;

----------------------------------------
-- This Local Procedure updates OSP Tables with
-- PO Information for one OSP Order
----------------------------------------
PROCEDURE Associate_New_Req(
   p_osp_order_id     IN         NUMBER,
   x_po_req_header_id OUT NOCOPY NUMBER) IS

  CURSOR l_get_po_req_hdr_csr(p_osp_order_id IN NUMBER) IS
    SELECT POREQ.REQUISITION_HEADER_ID
    FROM PO_REQUISITION_HEADERS_ALL POREQ, AHL_OSP_ORDERS_B OSP
    WHERE POREQ.INTERFACE_SOURCE_LINE_ID = p_osp_order_id AND
          OSP.OSP_ORDER_ID = p_osp_order_id AND
          OSP.OPERATING_UNIT_ID = POREQ.ORG_ID AND
          POREQ.INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME;

  CURSOR l_get_osp_lines_csr(p_osp_order_id IN NUMBER) IS
    SELECT OSP_ORDER_LINE_ID FROM AHL_OSP_ORDER_LINES
    WHERE PO_REQ_LINE_ID IS NULL
    AND OSP_ORDER_ID = p_osp_order_id;

  CURSOR l_get_po_req_line_csr(p_osp_order_line_id IN NUMBER, p_po_req_header_id IN NUMBER) IS
    SELECT REQUISITION_LINE_ID FROM PO_REQUISITION_LINES_ALL
    WHERE REFERENCE_NUM = p_osp_order_line_id AND
    REQUISITION_HEADER_ID = p_po_req_header_id;

  CURSOR l_get_request_id_csr(p_osp_order_id IN NUMBER) IS
    SELECT PO_REQUEST_ID FROM AHL_OSP_ORDERS_B
    WHERE OSP_ORDER_ID = p_osp_order_id;

  CURSOR check_req_completeness_csr(c_po_req_header_id IN NUMBER) IS
    select 1 from dual where
    (select count(*) from AHL_OSP_ORDER_LINES where OSP_ORDER_ID = p_osp_order_id) =
    (select count(*) from
     PO_REQUISITION_LINES_ALL REQL, AHL_OSP_ORDER_LINES OSPL
     where OSPL.OSP_ORDER_ID = p_osp_order_id
       AND REQL.REFERENCE_NUM = OSPL.osp_order_line_id
       AND REQL.REQUISITION_HEADER_ID = c_po_req_header_id);

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Associate_New_Req';
   l_po_req_header_id       NUMBER;
   l_osp_order_line_id      NUMBER;
   l_po_req_line_id         NUMBER;
   l_request_id             NUMBER;
   l_phase                  VARCHAR2(100);
   l_status                 VARCHAR2(100);
   l_dev_phase              VARCHAR2(100);
   l_dev_status             VARCHAR2(100);
   l_message                VARCHAR2(1000);
   l_retval                 BOOLEAN;
   l_temp_num               NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  OPEN l_get_po_req_hdr_csr(p_osp_order_id);
  FETCH l_get_po_req_hdr_csr INTO x_po_req_header_id;
  IF (l_get_po_req_hdr_csr%FOUND) THEN
    -- Ensure that the Requisition is created in its entirety
    OPEN check_req_completeness_csr(x_po_req_header_id);
    FETCH check_req_completeness_csr INTO l_temp_num;
    IF (check_req_completeness_csr%NOTFOUND) THEN
      -- The Requisition has been created only PARTIALLY: Flag as Failed
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Requisition Creation succeeded only PARTIALLY for OSP Order Id ' || p_osp_order_id ||
                                                             ', Requisition Header Id: ' || x_po_req_header_id);
      END IF;
      Set_Req_Submission_Failed(p_osp_order_id);
    ELSE
      -- Update AHL_OSP_ORDERS_B's PO_REQ_HEADER_ID
      --dbms_output.put_line('About to Update  AHL_OSP_ORDERS_B.PO_REQ_HEADER_ID with ' || x_po_req_header_id);
      Set_PO_Req_Header_Id(p_osp_order_id     => p_osp_order_id,
                           p_po_req_header_id => x_po_req_header_id);

      --dbms_output.put_line('Updated po_req_header_id. Logging Transaction...');
      AHL_OSP_UTIL_PKG.Log_Transaction(p_trans_type_code    => G_TXN_TYPE_PO_SYNCH,
                                       p_src_doc_id         => p_osp_order_id,
                                       p_src_doc_type_code  => G_DOC_TYPE_PO_REQ,
                                       p_dest_doc_id        => x_po_req_header_id,
                                       p_dest_doc_type_code => G_DOC_TYPE_OSP);

      -- Get PO Lines for all OSP Lines
      OPEN l_get_osp_lines_csr(p_osp_order_id);
      LOOP
        FETCH l_get_osp_lines_csr INTO l_osp_order_line_id;
        EXIT WHEN l_get_osp_lines_csr%NOTFOUND;
        OPEN l_get_po_req_line_csr(l_osp_order_line_id, x_po_req_header_id);
        FETCH l_get_po_req_line_csr INTO l_po_req_line_id;
        IF (l_get_po_req_line_csr%FOUND) THEN
          Update_Osp_Order_Lines(p_osp_order_line_id => l_osp_order_line_id,
                                 p_po_req_line_id    => l_po_req_line_id);
        ELSE
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Line Id ' || l_osp_order_line_id || ' is not yet associated with a PO Req Line');
          END IF;
        END IF;
        CLOSE l_get_po_req_line_csr;
      END LOOP;
      CLOSE l_get_osp_lines_csr;
    END IF;  -- check_req_completeness_csr FOUND or not
    CLOSE check_req_completeness_csr;
  ELSE
    -- Set Return PO Header Value to null
    x_po_req_header_id := null;
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
      -- IF ((l_retval = TRUE) AND (l_dev_phase = 'COMPLETE') AND (l_dev_status <> 'NORMAL')) THEN
      -- Status can be NORMAL even if the Requisition Creation had failed.
      -- So setting status to REQ_SUBMISSION_FAILED if the Concurrent Program has completed
      -- but the Requisition Header is not set
      IF ((l_retval = TRUE) AND (l_dev_phase = 'COMPLETE')) THEN
        -- Abnormal Termination
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Concurrent Program with Request Id ' || l_request_id || ' has terminated. dev_status = ' || l_dev_status || ', message = ' || l_message);
        END IF;
        -- Set the Status of OSP Order to Submission Failed
        Set_Req_Submission_Failed(p_osp_order_id);
      END IF;
    END IF;
  END IF;
  CLOSE l_get_po_req_hdr_csr;
  --dbms_output.put_line('About to exit Associate_New_Req ');
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Associate_New_Req;


----------------------------------------
-- This Procedure updates AHL_OSP_ORDERS_B's PO_REQ_HEADER_ID and sets STATUS_CODE to REQUISITION_CREATED
----------------------------------------
PROCEDURE Set_PO_Req_Header_ID(
   p_osp_order_id IN NUMBER,
   p_po_req_header_id IN NUMBER) IS
BEGIN
  Update_OSP_Order(p_osp_order_id => p_osp_order_id,
                   p_po_req_header_id => p_po_req_header_id,
                   p_status_code => G_OSP_REQ_CREATED_STATUS);
END Set_PO_Req_Header_ID;

----------------------------------------
-- This Procedure updates the Osp Order Lines with the PO_REQ_LINE_ID
----------------------------------------
PROCEDURE Update_Osp_Order_Lines(
   p_osp_order_line_id IN NUMBER,
   p_po_req_line_id IN NUMBER := NULL) IS

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
      PO_REQ_LINE_ID,
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
      ATTRIBUTE15
    FROM AHL_OSP_ORDER_LINES
    WHERE OSP_ORDER_LINE_ID = p_osp_order_line_id;

    l_osp_line_dtls_rec l_osp_line_dtls_csr%ROWTYPE;
    L_DEBUG_KEY         CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_Osp_Order_Lines';

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

  -- Update cursor variable's PO Req Line ID and PO intf transaction id

  IF (p_po_req_line_id IS NOT NULL) THEN
    l_osp_line_dtls_rec.PO_REQ_LINE_ID := p_po_req_line_id;
  END IF;

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
        P_PO_LINE_ID                => l_osp_line_dtls_rec.PO_LINE_ID,
        P_PO_REQ_LINE_ID            => l_osp_line_dtls_rec.PO_REQ_LINE_ID,  -- Updated
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
        P_LAST_UPDATE_DATE          => TRUNC(sysdate),  -- Updated
        P_LAST_UPDATED_BY           => fnd_global.user_id,  -- Updated
        P_LAST_UPDATE_LOGIN         => fnd_global.login_id);  -- Updated

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Update_Osp_Order_Lines;


-- This Procedure updates AHL_OSP_ORDERS_B.STATUS_CODE to REQ_SUBMISSION_FAILED
PROCEDURE Set_Req_Submission_Failed(
   p_osp_order_id IN NUMBER) IS
BEGIN
  Update_OSP_Order(p_osp_order_id => p_osp_order_id,
                   p_status_code  => G_OSP_REQ_SUB_FAILED_STATUS);
END Set_Req_Submission_Failed;

----------------------------------------
-- This Procedure handles Deleted PO Req Headers and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action.
-- Functionality:
-- After a PO Requisition has been created for an OSP Order, it is possible for the Requisition
-- to be manually deleted (using Purchasing responsibility) before the Requisition is approved.
-- Since this deletion will result in an OSP Order referring to a non-existent Requisition,
-- we need to change the OSP order to bring it to a consistent state.
-- This procedure basically looks for OSP Orders for which the Requisition has been deleted
-- and resets some values and corrects the status of the order as well as the lines
-- so that the OSP Order can be resubmitted and a different Requisition can be created.
-- This procedure does a direct update of the AHL_OSP_ORDERS_B and the AHL_OSP_ORDER_LINES
-- tables and does not call the process_osp_order API to avoid unwanted validations
----------------------------------------
PROCEDURE Handle_Deleted_Req_Headers(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR get_req_deleted_osps_csr IS
    SELECT osp.osp_order_id,
           osp.object_version_number,
           osp.po_req_header_id,
           osp.status_code,
           osp.order_type_code
    FROM ahl_osp_orders_b osp
    WHERE osp.status_code = G_OSP_REQ_CREATED_STATUS AND
          osp.order_type_code in ('SERVICE', 'EXCHANGE') AND
          -- Added by jaramana on April 7, 2008 for bug 6609988
          osp.operating_unit_id = MO_GLOBAL.get_current_org_id() AND
          NOT EXISTS (SELECT 1 FROM po_requisition_headers_all where requisition_header_id = osp.po_req_header_id);

  CURSOR get_osp_line_dtls_csr(c_osp_order_id IN NUMBER) IS
    SELECT ospl.osp_order_id,
           ospl.osp_order_line_id,
           ospl.object_version_number,
           ospl.status_code,
           ospl.po_req_line_id
    FROM ahl_osp_order_lines ospl
    WHERE ospl.osp_order_id = c_osp_order_id;

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Deleted_Req_Headers';
   l_temp_num               NUMBER := 0;
   l_osp_details_rec        get_req_deleted_osps_csr%ROWTYPE;
   l_osp_line_details_rec   get_osp_line_dtls_csr%ROWTYPE;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT Handle_Deleted_Req_Headers_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Get all OSP Orders for which the PO Header has been deleted
  OPEN get_req_deleted_osps_csr;
  LOOP
    FETCH get_req_deleted_osps_csr into l_osp_details_rec;
    EXIT WHEN get_req_deleted_osps_csr%NOTFOUND;
    l_temp_num := l_temp_num + 1;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing PO Req Deletion for OSP Order ' || l_osp_details_rec.osp_order_id);
    END IF;
    -- Get the Line Details
    OPEN get_osp_line_dtls_csr(c_osp_order_id => l_osp_details_rec.osp_order_id);
    LOOP
      FETCH get_osp_line_dtls_csr into l_osp_line_details_rec;
      EXIT WHEN get_osp_line_dtls_csr%NOTFOUND;
      IF (l_osp_line_details_rec.status_code IS NULL) THEN
        IF (l_osp_line_details_rec.po_req_line_id IS NOT NULL) THEN
          -- Reset the value of PO_REQ_LINE_ID and increment OVN (status_code is already null)
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Updating OSP Line with Id ' || l_osp_line_details_rec.osp_order_line_id);
          END IF;
          update ahl_osp_order_lines
             set po_req_line_id = null,
                 object_version_number =  l_osp_line_details_rec.object_version_number + 1,
                 last_update_date    = TRUNC(sysdate),
                 last_updated_by     = fnd_global.user_id,
                 last_update_login   = fnd_global.login_id
           where osp_order_line_id = l_osp_line_details_rec.osp_order_line_id;
        END IF;
      ELSE
        -- Physically delete this line (REQ_DELETED, REQ_CANCELLED)
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleting OSP Line with Id ' || l_osp_line_details_rec.osp_order_line_id);
        END IF;
        DELETE FROM ahl_osp_order_lines
        WHERE osp_order_line_id = l_osp_line_details_rec.osp_order_line_id;
      END IF;
    END LOOP;
    CLOSE get_osp_line_dtls_csr;
    -- Now for the OSP Order Header, reset PO_REQ_HEADER_ID, PO_BATCH_ID, PO_REQUEST_ID
    -- set STATUS_CODE to "ENTERED" and increment OVN
    update ahl_osp_orders_b
    set po_req_header_id = null,
        po_batch_id = null,
        po_request_id = null,
        status_code = G_OSP_ENTERED_STATUS,
        object_version_number =  l_osp_details_rec.object_version_number + 1,
        last_update_date    = TRUNC(sysdate),
        last_updated_by     = fnd_global.user_id,
        last_update_login   = fnd_global.login_id
    where osp_order_id = l_osp_details_rec.osp_order_id;
  END LOOP;
  CLOSE get_req_deleted_osps_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processed PO Req Deletion for ' || l_temp_num || ' OSP Orders');
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
   ROLLBACK TO Handle_Deleted_Req_Headers_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Deleted_Req_Headers_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Deleted_Req_Headers_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Deleted_Req_Headers',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
END Handle_Deleted_Req_Headers;

----------------------------------------
-- This Procedure handles cancelled Req Lines and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action
----------------------------------------
PROCEDURE Handle_Cancelled_Req_Lines(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_cancelled_req_lines_csr IS
    SELECT REQL.REQUISITION_LINE_ID,
           OL.OSP_ORDER_LINE_ID,
           REQH.INTERFACE_SOURCE_LINE_ID,
           OL.OBJECT_VERSION_NUMBER,
           OSP.OBJECT_VERSION_NUMBER
      FROM PO_REQUISITION_LINES_ALL REQL,
           PO_REQUISITION_HEADERS_ALL REQH,
           AHL_OSP_ORDER_LINES OL,
           AHL_OSP_ORDERS_B OSP
     WHERE nvl(REQL.CANCEL_FLAG,'N') = 'Y' AND -- Canceled Req Line
           REQL.REQUISITION_HEADER_ID = REQH.REQUISITION_HEADER_ID AND
           REQH.INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME AND  -- AHL Created Req
           REQH.INTERFACE_SOURCE_LINE_ID = OSP.OSP_ORDER_ID AND  -- Related to the OSP Order
           OSP.OSP_ORDER_ID = OL.OSP_ORDER_ID AND
           -- Added by jaramana on April 7, 2008 for bug 6609988
           OSP.OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id() AND
           OL.PO_REQ_LINE_ID = REQL.REQUISITION_LINE_ID AND
           NVL(OL.STATUS_CODE, ' ') <> G_OL_REQ_CANCELLED_STATUS       -- Not yet updated
           ORDER BY REQH.INTERFACE_SOURCE_LINE_ID;                    -- One OSP Order at a time

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Cancelled_Req_Lines';
   l_osp_order_id           NUMBER := -1;
   l_osp_order_line_id      NUMBER;
   l_po_req_line_id         NUMBER;
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
  SAVEPOINT Handle_Cancelled_Req_Lines_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN l_get_cancelled_req_lines_csr;
  LOOP
    FETCH l_get_cancelled_req_lines_csr INTO l_po_req_line_id,
                                            l_osp_order_line_id,
                                            l_osp_order_id,
                                            l_ol_obj_ver_num,
                                            l_osp_obj_ver_num;
    EXIT WHEN l_get_cancelled_req_lines_csr%NOTFOUND;
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
    -- Set OSP Line Status to G_OL_REQ_CANCELLED_STATUS in API's Line Table
    l_osp_order_lines_tbl(l_table_index).STATUS_CODE := G_OL_REQ_CANCELLED_STATUS;
    -- Set Operation to Update in the line rec
    l_osp_order_lines_tbl(l_table_index).OPERATION_FLAG := AHL_OSP_ORDERS_PVT.G_OP_UPDATE;

    l_table_index := l_table_index + 1;
  END LOOP;
  CLOSE l_get_cancelled_req_lines_csr;
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
   ROLLBACK TO Handle_Cancelled_Req_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Cancelled_Req_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Cancelled_Req_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Cancelled_Req_Lines',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Cancelled_Req_Lines;

----------------------------------------
-- This Procedure handles deleted Req Lines and is Part of PO Synchronization.
-- This procedure commits its work if p_commit is set to true and
-- if there were no errors during the execution of this procedure.
-- It does not check the message list for performing the commit action.
----------------------------------------
PROCEDURE Handle_Deleted_Req_Lines(
   p_commit         IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_deleted_req_lines_csr IS
    SELECT OL.OSP_ORDER_ID, OL.OSP_ORDER_LINE_ID,
           OL.OBJECT_VERSION_NUMBER, OSP.OBJECT_VERSION_NUMBER
    FROM AHL_OSP_ORDER_LINES OL, AHL_OSP_ORDERS_B OSP
    WHERE OL.PO_REQ_LINE_ID IS NOT NULL AND                -- PO Created
          NVL(OL.STATUS_CODE, ' ') <> G_OL_REQ_DELETED_STATUS AND -- Not yet updated
          OSP.OSP_ORDER_ID = OL.OSP_ORDER_ID AND
          -- Added by jaramana on April 7, 2008 for bug 6609988
          OSP.OPERATING_UNIT_ID = MO_GLOBAL.get_current_org_id() AND
          NOT EXISTS (SELECT REQUISITION_LINE_ID FROM PO_REQUISITION_LINES_ALL WHERE REQUISITION_LINE_ID = OL.PO_REQ_LINE_ID) -- Req Line Deleted
          ORDER BY OL.OSP_ORDER_ID;                    -- One OSP Order at a time

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Deleted_Req_Lines';
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
  SAVEPOINT Handle_Deleted_Req_Lines_pvt;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN l_get_deleted_req_lines_csr;
  LOOP
    FETCH l_get_deleted_req_lines_csr INTO l_osp_order_id,
                                           l_osp_order_line_id,
                                           l_ol_obj_ver_num,
                                           l_osp_obj_ver_num;
    EXIT WHEN l_get_deleted_req_lines_csr%NOTFOUND;
    IF (l_osp_order_id <> l_prev_osp_order_id) THEN
      IF (l_prev_osp_order_id <> -1) THEN
        -- Req Delete all OSP Lines pertaining to the previous OSP Order
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
    -- Set  OSP Line Status to G_OL_REQ_DELETED_STATUS in API's Line Table
    l_osp_order_lines_tbl(l_table_index).STATUS_CODE := G_OL_REQ_DELETED_STATUS;
    -- Set Operation to Update in the line rec
    l_osp_order_lines_tbl(l_table_index).OPERATION_FLAG := AHL_OSP_ORDERS_PVT.G_OP_UPDATE;
    l_table_index := l_table_index + 1;
  END LOOP;
  CLOSE l_get_deleted_req_lines_csr;
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
   ROLLBACK TO Handle_Deleted_Req_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Handle_Deleted_Req_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   ROLLBACK TO Handle_Deleted_Req_Lines_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Deleted_Req_Lines',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
   END IF;

END Handle_Deleted_Req_Lines;

----------------------------------------
-- This function determines if the Requsition is closed/cancelled.
----------------------------------------
FUNCTION Is_PO_Req_Closed(p_po_req_header_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR l_is_req_closed_csr(p_po_req_header_id IN NUMBER) IS
    SELECT 1
      FROM po_requisition_headers_all poh
     WHERE poh.requisition_header_id = p_po_req_header_id
       AND (nvl(poh.closed_code, 'OPEN') IN ('CANCELLED', 'CLOSED','FINALLY CLOSED', 'REJECTED', 'RETURNED')
            OR
            nvl(poh.authorization_status, 'INCOMPLETE') = 'CANCELLED'
           );

  --Verify that the passed PO_REQ_HEADER_ID is valid
  CURSOR l_val_req_hdr_id_csr(p_po_req_header_id IN NUMBER) IS
    SELECT poh.requisition_header_id
      FROM po_requisition_headers_all poh
     WHERE poh.requisition_header_id = p_po_req_header_id;


   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Is_PO_Req_Closed';
   l_closed_status  VARCHAR2(30);
   l_cancel_flag    VARCHAR2(1);
   l_dummy          NUMBER;


BEGIN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'PO_REQ_HEADER_ID: '|| p_po_req_header_id);
  END IF;

  IF (p_po_req_header_id IS NULL OR p_po_req_header_id = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_REQ_ID_NULL');
    FND_MSG_PUB.ADD;
    RETURN 'N';
  ELSE
    --validate the requisition_header_id. If it is not present, it may mean that user need to perform a PO Synch
    OPEN l_val_req_hdr_id_csr(p_po_req_header_id);
    FETCH l_val_req_hdr_id_csr INTO l_dummy;
    IF (l_val_req_hdr_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_REQ_HDR_ID_INV');
      FND_MESSAGE.Set_Token('REQ_HDR_ID', p_po_req_header_id);
      FND_MSG_PUB.ADD;
      CLOSE l_val_req_hdr_id_csr;
      RETURN 'N';
    END IF;
    CLOSE l_val_req_hdr_id_csr;

  END IF;

  OPEN l_is_req_closed_csr(p_po_req_header_id);
  FETCH l_is_req_closed_csr INTO l_dummy;
  IF (l_is_req_closed_csr%FOUND) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Requisition is closed');
    END IF;
    CLOSE l_is_req_closed_csr;
    RETURN 'Y';
  END IF;
  CLOSE l_is_req_closed_csr;

  RETURN 'N';

END Is_PO_Req_Closed;

----------------------------------------------
-- This function derives the charge_account_id
----------------------------------------------
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

END AHL_OSP_PO_REQ_PVT;

/

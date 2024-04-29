--------------------------------------------------------
--  DDL for Package AHL_OSP_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_ORDERS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVOSPS.pls 120.2 2008/01/30 22:37:08 jaramana ship $ */

  G_OP_CREATE        CONSTANT  VARCHAR(1) := 'C';
  G_OP_UPDATE        CONSTANT  VARCHAR(1) := 'U';
  G_OP_DELETE        CONSTANT  VARCHAR(1) := 'D';

  --YES NO FLAGS
  G_NO_FLAG           CONSTANT VARCHAR2(1)  := 'N';
  G_YES_FLAG          CONSTANT VARCHAR2(1)  := 'Y';

  --OSP Order Statuses
  G_OSP_ENTERED_STATUS    CONSTANT VARCHAR2(30) := 'ENTERED';
  G_OSP_SUBMITTED_STATUS  CONSTANT VARCHAR2(30) := 'SUBMITTED';
  G_OSP_SUB_FAILED_STATUS CONSTANT VARCHAR2(30) := 'SUBMISSION_FAILED';
  G_OSP_PO_CREATED_STATUS CONSTANT VARCHAR2(30) := 'PO_CREATED';
  G_OSP_CLOSED_STATUS     CONSTANT VARCHAR2(30) := 'CLOSED';
  G_OSP_DELETED_STATUS    CONSTANT VARCHAR2(30) := 'HEADER_DELETED';

  -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
  G_OSP_REQ_SUBMITTED_STATUS  CONSTANT VARCHAR2(30) := 'REQ_SUBMITTED';
  G_OSP_REQ_SUB_FAILED_STATUS CONSTANT VARCHAR2(30) := 'REQ_SUBMISSION_FAILED';
  G_OSP_REQ_CREATED_STATUS    CONSTANT VARCHAR2(30) := 'REQ_CREATED';
  -- jaramana End

  --OSP Order Line Statuses
  G_OL_PO_CANCELLED_STATUS CONSTANT VARCHAR2(30) := 'PO_CANCELLED';
  G_OL_PO_DELETED_STATUS   CONSTANT VARCHAR2(30) := 'PO_DELETED';
  -- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
  G_OL_REQ_CANCELLED_STATUS CONSTANT VARCHAR2(30) := 'REQ_CANCELLED';
  G_OL_REQ_DELETED_STATUS   CONSTANT VARCHAR2(30) := 'REQ_DELETED';
  --jaramana End

  --OSP ORDER Type codes
  G_OSP_ORDER_TYPE_SERVICE  CONSTANT VARCHAR2(30) := 'SERVICE';
  G_OSP_ORDER_TYPE_EXCHANGE CONSTANT VARCHAR2(30) := 'EXCHANGE';          --item exchange enhancement
  G_OSP_ORDER_TYPE_LOAN     CONSTANT VARCHAR2(30) := 'LOAN';
  G_OSP_ORDER_TYPE_BORROW   CONSTANT VARCHAR2(30) := 'BORROW';

  -- WORKORDER status codes
  G_OSP_WO_RELEASED  CONSTANT VARCHAR2(1) := '3';
  G_OSP_WO_CANCELLED CONSTANT VARCHAR2(1) := '7';
  G_OSP_WO_CLOSED    CONSTANT VARCHAR2(2) := '12';
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE OSP_ORDER_REC_TYPE IS RECORD (
    OPERATION_FLAG         VARCHAR2(1),
    OSP_ORDER_ID           NUMBER,
    OBJECT_VERSION_NUMBER  NUMBER,
    LAST_UPDATE_DATE       DATE,
    LAST_UPDATED_BY        NUMBER,
    CREATION_DATE          DATE,
    CREATED_BY             NUMBER,
    LAST_UPDATE_LOGIN      NUMBER,
    OSP_ORDER_NUMBER       NUMBER,
    ORDER_TYPE_CODE        VARCHAR2(30),
    STATUS_CODE            VARCHAR2(30),
    ORDER_DATE             DATE,
    DESCRIPTION            VARCHAR2(2000),
    OPERATING_UNIT_ID      NUMBER,
    SINGLE_INSTANCE_FLAG   VARCHAR2(1),
    VENDOR_ID              NUMBER,
    VENDOR_NAME            VARCHAR2(240),
    VENDOR_SITE_ID         NUMBER,
    VENDOR_SITE_CODE       VARCHAR2(15),
    VENDOR_CONTACT_ID      NUMBER,
    VENDOR_CONTACT         VARCHAR2(60),
    PO_SYNCH_FLAG          VARCHAR2(1),
    PO_HEADER_ID           NUMBER,
    PO_BATCH_ID            NUMBER,
    PO_REQUEST_ID          NUMBER,
    PO_AGENT_ID            NUMBER,
    BUYER_NAME             VARCHAR2(240),
    PO_INTERFACE_HEADER_ID NUMBER,
    OE_HEADER_ID           NUMBER,
    CUSTOMER_ID            NUMBER,
    CUSTOMER_NAME          VARCHAR2(360),
    CONTRACT_ID            NUMBER,
    CONTRACT_NUMBER        VARCHAR2(120),
    CONTRACT_TERMS         VARCHAR2(256),
    ATTRIBUTE_CATEGORY     VARCHAR2(30),
    ATTRIBUTE1             VARCHAR2(150),
    ATTRIBUTE2             VARCHAR2(150),
    ATTRIBUTE3             VARCHAR2(150),
    ATTRIBUTE4             VARCHAR2(150),
    ATTRIBUTE5             VARCHAR2(150),
    ATTRIBUTE6             VARCHAR2(150),
    ATTRIBUTE7             VARCHAR2(150),
    ATTRIBUTE8             VARCHAR2(150),
    ATTRIBUTE9             VARCHAR2(150),
    ATTRIBUTE10            VARCHAR2(150),
    ATTRIBUTE11            VARCHAR2(150),
    ATTRIBUTE12            VARCHAR2(150),
    ATTRIBUTE13            VARCHAR2(150),
    ATTRIBUTE14            VARCHAR2(150),
    ATTRIBUTE15            VARCHAR2(150),
-- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
    PO_REQ_HEADER_ID       NUMBER);

TYPE OSP_ORDER_LINE_REC_TYPE IS RECORD (
    OPERATION_FLAG            VARCHAR2(1),
    SHIPMENT_CREATION_FLAG    VARCHAR2(1),
    OSP_ORDER_LINE_ID         NUMBER,
    OBJECT_VERSION_NUMBER     NUMBER,
    LAST_UPDATE_DATE          DATE,
    LAST_UPDATED_BY           NUMBER,
    CREATION_DATE             DATE,
    CREATED_BY                NUMBER,
    LAST_UPDATE_LOGIN         NUMBER,
    OSP_ORDER_ID              NUMBER,
    OSP_LINE_NUMBER           NUMBER,
    STATUS_CODE               VARCHAR2(30),
    NEED_BY_DATE              DATE,
    SHIP_BY_DATE              DATE,
    PO_LINE_TYPE_ID           NUMBER,
    PO_LINE_TYPE              VARCHAR2(25),
    PO_LINE_ID                NUMBER,
    OE_SHIP_LINE_ID           NUMBER,
    OE_RETURN_LINE_ID         NUMBER,
    SERVICE_ITEM_ID           NUMBER,
    SERVICE_ITEM_NUMBER       VARCHAR2(40),
    SERVICE_ITEM_DESCRIPTION  VARCHAR2(2000),
    SERVICE_ITEM_UOM_CODE     VARCHAR2(3),
    QUANTITY                  NUMBER,
    WORKORDER_ID              NUMBER,
    JOB_NUMBER                VARCHAR2(80),
    OPERATION_ID              NUMBER,
    INVENTORY_ITEM_ID         NUMBER,
    INVENTORY_ORG_ID          NUMBER,
    ITEM_NUMBER               VARCHAR2(40),
    INVENTORY_ITEM_UOM        VARCHAR2(3),
    INVENTORY_ITEM_QUANTITY   NUMBER,
    SUB_INVENTORY             VARCHAR2(10),
    LOT_NUMBER                mtl_lot_numbers.lot_number%TYPE,
    SERIAL_NUMBER             VARCHAR2(30),
    EXCHANGE_INSTANCE_NUMBER  VARCHAR2(30),
    EXCHANGE_INSTANCE_ID      NUMBER,
    ATTRIBUTE_CATEGORY        VARCHAR2(30),
    ATTRIBUTE1                VARCHAR2(150),
    ATTRIBUTE2                VARCHAR2(150),
    ATTRIBUTE3                VARCHAR2(150),
    ATTRIBUTE4                VARCHAR2(150),
    ATTRIBUTE5                VARCHAR2(150),
    ATTRIBUTE6                VARCHAR2(150),
    ATTRIBUTE7                VARCHAR2(150),
    ATTRIBUTE8                VARCHAR2(150),
    ATTRIBUTE9                VARCHAR2(150),
    ATTRIBUTE10               VARCHAR2(150),
    ATTRIBUTE11               VARCHAR2(150),
    ATTRIBUTE12               VARCHAR2(150),
    ATTRIBUTE13               VARCHAR2(150),
    ATTRIBUTE14               VARCHAR2(150),
    ATTRIBUTE15               VARCHAR2(150),
-- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
    PO_REQ_LINE_ID            NUMBER);
----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE OSP_ORDER_LINES_TBL_TYPE IS TABLE OF OSP_ORDER_LINE_REC_TYPE INDEX BY BINARY_INTEGER;

/* for debugging this internal procedure
  TYPE item_service_rel_rec_type IS RECORD (
    inv_org_id  NUMBER,
    inv_item_id NUMBER,
    service_item_id NUMBER);
  TYPE item_service_rels_tbl_type IS TABLE OF item_service_rel_rec_type INDEX BY BINARY_INTEGER;
*/

------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : process_osp_order
--  Type              : Private
--  Function          : For a given set of osp order header and lines, will validate and insert/update/delete
--                      the osp order information.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_osp_order Parameters:
--
--       p_x_osp_order_rec         IN OUT  AHL_OSP_ORDERS_PVT.osp_order_rec_type    Required
--         OSP Order Header record
--       p_x_osp_order_lines_tbl        IN OUT  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type   Required
--         OSP Order Lines
--
--
--  Version :
--                Initial Version   1.0
--
--  End of Comments.
/*
PROCEDURE process_osp_order_old(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_osp_order_rec       IN OUT NOCOPY  OSP_ORDER_REC_TYPE,
    p_x_osp_order_lines_tbl IN OUT NOCOPY  OSP_ORDER_LINES_TBL_TYPE,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);
*/
--This is the new procedure for Inventory Service Orders including work order based
PROCEDURE process_osp_order(
  p_api_version           IN              NUMBER    := 1.0,
  p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
  p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_module_type           IN              VARCHAR2  := NULL,
  p_x_osp_order_rec       IN OUT NOCOPY   osp_order_rec_type,
  p_x_osp_order_lines_tbl IN OUT NOCOPY   osp_order_lines_tbl_type,
  x_return_status         OUT NOCOPY      VARCHAR2,
  x_msg_count             OUT NOCOPY      NUMBER,
  x_msg_data              OUT NOCOPY      VARCHAR2);

/* For debugging purpose
PROCEDURE derive_default_vendor(
  p_item_service_rels_tbl IN item_service_rels_tbl_type,
  x_vendor_id             OUT NOCOPY NUMBER,
  x_vendor_site_id        OUT NOCOPY NUMBER,
  x_vendor_contact_id     OUT NOCOPY NUMBER);
*/

End AHL_OSP_ORDERS_PVT;

/

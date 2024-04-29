--------------------------------------------------------
--  DDL for Package AHL_OSP_RCV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_RCV_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVORCS.pls 120.1 2008/02/12 09:16:35 sathapli noship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs    --
---------------------------------------------------------------------

-- Record of attributes needed to do a receipt against an RMA.
-- Also included attributes needed for Part Number/Serial Number change and for doing an Exchange.
TYPE RMA_Receipt_Rec_Type IS RECORD (
    RETURN_LINE_ID               NUMBER,
    RECEIVING_ORG_ID             NUMBER,
    RECEIVING_SUBINVENTORY       VARCHAR2(10),
    RECEIVING_LOCATOR_ID         NUMBER,
    RECEIPT_QUANTITY             NUMBER,
    RECEIPT_UOM_CODE             VARCHAR2(3),
    RECEIPT_DATE                 DATE,
    -- Following NEW% attributes are for use only if Part Number/Serial Number change is to be done.
    NEW_ITEM_ID                  NUMBER,
    NEW_SERIAL_NUMBER            VARCHAR2(30),
    NEW_SERIAL_TAG_CODE          VARCHAR2(30),
    NEW_LOT_NUMBER               VARCHAR2(80),
    NEW_ITEM_REV_NUMBER          VARCHAR2(3),
    -- Following EXCHANGE% attributes are for use only if Exchange is to be done.
    EXCHANGE_ITEM_ID             NUMBER,
    EXCHANGE_SERIAL_NUMBER       VARCHAR2(30),
    EXCHANGE_LOT_NUMBER          VARCHAR2(80)
);


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
RETURN VARCHAR2;


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
RETURN VARCHAR2;


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
RETURN VARCHAR2;


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
);


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
);

END AHL_OSP_RCV_PVT;

/

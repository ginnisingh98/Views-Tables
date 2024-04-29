--------------------------------------------------------
--  DDL for Package AHL_OSP_PO_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_PO_REQ_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPRQS.pls 120.0 2008/01/30 22:38:37 jaramana noship $ */
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------

------------------------
-- Declare Procedures --
------------------------
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
--         Contains the batch id if the concurrent program was launched successfully.
--      x_request_id                    OUT     NUMBER              Required
--         Contains the concurrent request id if the concurrent program was launched successfully.
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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);

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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);

-- Start of Comments --
--  Procedure name    : PO_Synch_All_Requisitions
--  Type              : Private
--  Function          : Synchronizes all OSPs based on the Requisition Status
--                      1. Handles successfully completed Requisition Submissions (Updates OSP tables)
--                      2. Handles failed Requsition Submissions (Updates OSP Status)
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
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);


-- This function determines if the Requisition is closed/cancelled.
FUNCTION Is_PO_Req_Closed(p_po_req_header_id IN NUMBER) RETURN VARCHAR2;

END AHL_OSP_PO_REQ_PVT;

/

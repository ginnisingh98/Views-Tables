--------------------------------------------------------
--  DDL for Package AHL_OSP_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_PO_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVOPPS.pls 115.1 2002/12/04 19:22:47 jaramana noship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------

------------------------
-- Declare Procedures --
------------------------

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
--      p_osp_order_id                  IN      NUMBER  Required only if Number is null
--         The Id of the OSP Order for which to create the Purchase Order
--      p_osp_order_number              IN      NUMBER  Required only if Id is null
--         The number of the OSP Order for which to create the Purchase Order
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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);

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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);

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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);

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
--      p_concurrent_flag               IN      VARCHAR2     Default  N.
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
    x_msg_data              OUT  NOCOPY   VARCHAR2
);

-- This function determines if the specified Purchase Order is closed
-- Returns 'Y' if the PO is Closed, 'N' if not.
-- If the PO Id is invalid, 'N' is returned and the Error Message is set.
FUNCTION Is_PO_Closed(p_po_header_id IN NUMBER) RETURN VARCHAR2;

-- This function determines if the specified OSP Order has any new PO Line
-- Returns 'Y' if the present, 'N' if not.
FUNCTION Has_New_PO_Line(p_osp_order_id IN NUMBER) RETURN VARCHAR2;

End AHL_OSP_PO_PVT;

 

/

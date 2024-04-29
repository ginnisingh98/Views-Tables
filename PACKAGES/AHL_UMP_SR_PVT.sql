--------------------------------------------------------
--  DDL for Package AHL_UMP_SR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_SR_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUSRS.pls 120.2 2005/12/01 09:02:55 sracha noship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE SR_MR_Association_Rec_Type IS RECORD (
        OPERATION_FLAG          VARCHAR2(1),    -- 'C' (Create) or 'D' (Delete) Only
        MR_TITLE                VARCHAR2(80),
        MR_VERSION              NUMBER,
        MR_HEADER_ID            NUMBER,
        UE_RELATIONSHIP_ID      NUMBER,         -- OUT parameter for Create Operation
        UNIT_EFFECTIVITY_ID     NUMBER,         -- OUT parameter for Create Operation
        OBJECT_VERSION_NUMBER   NUMBER,         -- OVN of Unit Effectivity, Mandatory for Delete
        RELATIONSHIP_CODE       VARCHAR2(30),   -- Always 'PARENT' or null
        CSI_INSTANCE_ID         NUMBER,         -- Instance to which the MR is associated
        CSI_INSTANCE_NUMBER     VARCHAR2(30)
        );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE SR_MR_Association_Tbl_Type IS TABLE OF SR_MR_Association_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Create_SR_Unit_Effectivity
--  Type              : Private
--  Function          : Private API to create a SR type unit effectivity. Called by corresponding Public procedure.
--                      Uses CS_SERVICEREQUEST_PVT.USER_HOOKS_REC to get SR Details.
--  Pre-reqs    :
--  Parameters  :
--      x_return_status                 OUT     VARCHAR2     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_SR_Unit_Effectivity
(
   x_return_status         OUT  NOCOPY   VARCHAR2
);

----------------------------------------
-- Start of Comments --
--  Procedure name    : Process_SR_Updates
--  Type              : Private
--  Function          : Private API to process changes to a (current or former) CMRO type SR
--                      by adding, removing or updating SR type unit effectivities.
--                      Called by the corresponding public procedure.
--                      Uses CS_SERVICEREQUEST_PVT.USER_HOOKS_REC to get SR Details.
--  Pre-reqs    :
--  Parameters  :
--      x_return_status                 OUT     VARCHAR2     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_SR_Updates
(
   x_return_status         OUT  NOCOPY   VARCHAR2
);

----------------------------------------
-- Start of Comments --
--  Procedure name    : Process_SR_MR_Associations
--  Type              : Private
--  Function          : Processes new and removed MR associations with a CMRO type SR by
--                      creating or removing unit effectivities and corresponding relationships.
--                      Called by the corresponding public procedure.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Process_SR_MR_Associations Parameters:
--      p_user_id                       IN      NUMBER       Required
--         The Id of the user calling this API
--      p_login_id                      IN      NUMBER       Required
--         The Login Id of the user calling this API
--      p_request_id                    IN      NUMBER       Required if p_request_number is null
--         The Id of the Service Request
--      p_object_version_number         IN      NUMBER       Required
--         The object version number of the Service Request
--      p_request_number                IN      VARCHAR2     Required if p_request_id is null
--         The request number of the Service Request
--      p_x_sr_mr_association_tbl       IN OUT  AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type  Required
--         The Table of records containing the details about the associations and disassociations
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_SR_MR_Associations
(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
   p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT  NOCOPY   VARCHAR2,
   x_msg_count             OUT  NOCOPY   NUMBER,
   x_msg_data              OUT  NOCOPY   VARCHAR2,
   p_user_id               IN            NUMBER,
   p_login_id              IN            NUMBER,
   p_request_id            IN            NUMBER,
   p_object_version_number IN            NUMBER,
   p_request_number        IN            VARCHAR2,
   p_x_sr_mr_association_tbl IN OUT  NOCOPY  AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type
);

----------------------------------------

End AHL_UMP_SR_PVT;

 

/

--------------------------------------------------------
--  DDL for Package AHL_UMP_SR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_SR_GRP" AUTHID CURRENT_USER AS
/* $Header: AHLGUSRS.pls 115.0 2003/09/17 22:40:06 jaramana noship $ */

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Create_SR_Unit_Effectivity
--  Type              : Public
--  Function          : Group Hook API to create a SR type unit effectivity.
--                      Called by the CMRO type Service Request as Post Insert Internal hook.
--                      Uses CS_SERVICEREQUEST_PVT.USER_HOOKS_REC to get SR Details.
--  Pre-reqs    :
--  Parameters  :
--
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
--  Type              : Public
--  Function          : Group Hook API to process updates to a (current or former) CMRO type
--                      SR by adding, removing or updating SR type unit effectivities.
--                      Called by the Service Request as Post Update internal hook.
--                      Uses CS_SERVICEREQUEST_PVT.USER_HOOKS_REC to get SR Details.
--  Pre-reqs    :
--  Parameters  :
--
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
--  Type              : Public
--  Function          : Processes new and removed MR associations with a CMRO type SR.
--                      This API will be called by the Service Request module whenever new MRs
--                      are associated to or existing MRs are disassociated from a CMRO type SR.
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
--      p_x_sr_mr_association_tbl       IN OUT NOCOPY  AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type  Required
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
   p_x_sr_mr_association_tbl  IN OUT NOCOPY  AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type
);

----------------------------------------

End AHL_UMP_SR_GRP;

 

/

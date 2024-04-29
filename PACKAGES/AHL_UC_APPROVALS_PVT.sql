--------------------------------------------------------
--  DDL for Package AHL_UC_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_APPROVALS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUAPS.pls 120.1 2005/06/29 08:18:07 sagarwal noship $ */


--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : INITIATE_UC_APPROVALS
--  Type              : Private
--  Function          : This procedure is called to initiate the approval process for a Unit
--                      Configuration, once the user submits it for Approvals.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_UC_APPROVALS Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--
--
--  History:
--      06/02/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE INITIATE_UC_APPROVALS(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN  NUMBER,
  p_object_version_number   IN  NUMBER,
  x_return_status           OUT NOCOPY      VARCHAR2,
  x_msg_count               OUT NOCOPY      NUMBER,
  x_msg_data                OUT NOCOPY      VARCHAR2

 );

--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : COMPLETE_UC_APPROVAL
--  Type              : Private
--  Function          : This procedure is called internally to complete the Approval Process.
--
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_UC_APPROVALS Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--      p_approval_status               IN      VARCHAR2                    Required
--         The approval status of the Unit Configuration after the approval process
--
--  History:
--      06/02/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE COMPLETE_UC_APPROVAL(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN  NUMBER,
  p_object_version_number   IN  NUMBER,
  p_approval_status         IN  VARCHAR2,
  x_return_status           OUT NOCOPY      VARCHAR2,
  x_msg_count               OUT NOCOPY      NUMBER,
  x_msg_data                OUT NOCOPY      VARCHAR2
 );


--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : INITIATE_QUARANTINE
--  Type              : Private
--  Function          : This procedure is called to initiate the approval process for a Unit
--                      Configuration Quarantine, once the user submits it for Approvals.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_QUARANTINE Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--
--  History:
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE INITIATE_QUARANTINE
 (
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_TRUE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN         NUMBER,
  p_object_version_number   IN         NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 );


--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : INITIATE_DEACTIVATE_QUARANTINE
--  Type              : Private
--  Function          : This procedure is called to initiate the approval process for a Unit
--                      Configuration deactivate Quarantine, once the user submits it for Approvals.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_DEACTIVATE_QUARANTINE Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--
--  History:
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE INITIATE_DEACTIVATE_QUARANTINE
 (
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_TRUE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN         NUMBER,
  p_object_version_number   IN         NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 );


 --------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : COMPLETE_QUARANTINE_APPROVAL
--  Type              : Private
--  Function          : This procedure is called internally to complete the Approval Process.
--
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  COMPLETE_QUARANTINE_APPROVAL Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--      p_approval_status               IN      VARCHAR2                    Required
--         The approval status of the Unit Configuration after the approval process
--
--  History:
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------
PROCEDURE COMPLETE_QUARANTINE_APPROVAL(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN  NUMBER,
  p_object_version_number   IN  NUMBER,
  p_approval_status         IN  VARCHAR2,
  x_return_status           OUT NOCOPY      VARCHAR2,
  x_msg_count               OUT NOCOPY      NUMBER,
  x_msg_data                OUT NOCOPY      VARCHAR2
 );



END AHL_UC_APPROVALS_PVT;

 

/

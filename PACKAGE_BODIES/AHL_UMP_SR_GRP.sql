--------------------------------------------------------
--  DDL for Package Body AHL_UMP_SR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_SR_GRP" AS
/* $Header: AHLGUSRB.pls 115.0 2003/09/17 22:40:58 jaramana noship $ */

-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_SR_GRP';

G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_UMP_SR_GRP';

-----------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
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
   x_return_status         OUT  NOCOPY   VARCHAR2) IS

   l_api_name               CONSTANT VARCHAR2(30) := 'Create_SR_Unit_Effectivity';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_SR_Unit_Effectivity';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call AHL_UMP_SR_PVT.Create_SR_Unit_Effectivity');
  END IF;

  AHL_UMP_SR_PVT.Create_SR_Unit_Effectivity(
    x_return_status       => x_return_status
  );

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to AHL_UMP_SR_PVT.Create_SR_Unit_Effectivity. x_return_status = ' || x_return_status);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_SR_Unit_Effectivity',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;

END Create_SR_Unit_Effectivity;

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
   x_return_status         OUT  NOCOPY   VARCHAR2) IS

   l_api_name               CONSTANT VARCHAR2(30) := 'Process_SR_Updates';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_SR_Updates';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call AHL_UMP_SR_PVT.Process_SR_Updates');
  END IF;

  AHL_UMP_SR_PVT.Process_SR_Updates(
    x_return_status         => x_return_status
  );

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to AHL_UMP_SR_PVT.Process_SR_Updates. x_return_status = ' || x_return_status);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_SR_Updates',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;

END Process_SR_Updates;

----------------------------------------

-- Start of Comments --
--  Procedure name    : Process_SR_MR_Associations
--  Type              : Public
--  Function          : Processes new and removed MR associations with a CMRO type SR.
--                      This API will be called by the Service Request module whenever new MRs
--                      are associated to or existing MRs are disassociated from a CMRO type SR.
--                      .
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
--      p_request_id                    IN      NUMBER       Required
--         The Id of the Service Request
--      p_object_version_number         IN      NUMBER       Required
--         The object version number of the Service Request
--      p_request_number                IN      NUMBER       Required
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
   p_x_sr_mr_association_tbl  IN OUT NOCOPY  AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Process_SR_MR_Associations';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_SR_MR_Associations';

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Process_SR_MR_Associations_pvt;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call AHL_UMP_SR_PVT.Process_SR_MR_Associations');
  END IF;

  AHL_UMP_SR_PVT.Process_SR_MR_Associations(
    p_api_version             => p_api_version,
    p_init_msg_list           => p_init_msg_list,
    p_commit                  => FND_API.G_FALSE,
    p_validation_level        => p_validation_level,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data,
    p_user_id                 => p_user_id,
    p_login_id                => p_login_id,
    p_request_id              => p_request_id,
    p_object_version_number   => p_object_version_number,
    p_request_number          => p_request_number,
    p_x_sr_mr_association_tbl => p_x_sr_mr_association_tbl
  );

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to AHL_UMP_SR_PVT.Process_SR_MR_Associations. x_return_status = ' || x_return_status);
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Commit.');
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
   ROLLBACK TO Process_SR_MR_Associations_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Process_SR_MR_Associations_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    ROLLBACK TO Process_SR_MR_Associations_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_SR_MR_Associations',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

END Process_SR_MR_Associations;

----------------------------------------

--------------------------------------
-- End Public Procedure Definitions --
--------------------------------------

END AHL_UMP_SR_GRP;

/

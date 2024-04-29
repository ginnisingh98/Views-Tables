--------------------------------------------------------
--  DDL for Package Body AHL_UC_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_VALIDATION_PUB" AS
/* $Header: AHLPUCVB.pls 120.2 2007/12/21 12:42:10 sathapli ship $ */


 G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_UC_VALIDATION_PUB';

-------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Validate_Completeness
--  Type        : Private
--  Function    : Validates the unit's completeness and checks for ALL validations.
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Completeness Parameters:
--   p_unit_header_id   IN           NUMBER Required.
--          The header identifier of the Unit Configuration
--   x_error_tbl        OUT NOCOPY   Error_Tbl_Type Required
--          A table listing all the Errors.
--
--  End of Comments.
-------------------------------------------------------------------------------
PROCEDURE Validate_Completeness (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id      IN           NUMBER,
    x_error_tbl           OUT  NOCOPY    Error_Tbl_Type)
IS
--
CURSOR validate_uc_header_id_csr (c_unit_header_id IN NUMBER) IS
  SELECT unit_config_status_code
  FROM   ahl_unit_config_headers
  WHERE  unit_config_header_id = c_unit_header_id
    AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
    AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
  FOR UPDATE OF unit_config_status_code NOWAIT;
--
  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Completeness';

  l_uc_status_code   ahl_unit_config_headers.unit_config_status_code%TYPE;
  l_error_table       Error_Tbl_Type;
  l_evaluation_status VARCHAR2(1);
--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Validate_Completeness;

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

  IF (p_unit_header_id IS NULL OR p_unit_header_id = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
    FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
    FND_MSG_PUB.add;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- ACL :: Changes for R12
  IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_unit_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --List Extra nodes
  AHL_UC_POS_NECES_PVT.list_extra_nodes(
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => p_unit_header_id,
    p_csi_instance_id               => null,
        x_evaluation_status             => l_evaluation_status,
        p_x_error_table                 => l_error_table,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );

  --List Missing Positions
  AHL_UC_POS_NECES_PVT.list_missing_positions(
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => p_unit_header_id,
        p_csi_instance_id               => null,
        x_evaluation_status             => l_evaluation_status,
        p_x_error_table                 => l_error_table,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );


   --Validate Rules
    AHL_MC_RULE_ENGINE_PVT.Validate_Rules_For_Unit (
            p_api_version                   => 1.0,
            p_init_msg_list                 => p_init_msg_list,
            p_validation_level              => p_validation_level,
            x_return_status                 => x_return_status,
            x_msg_count                     => x_msg_count,
            x_msg_data                      => x_msg_data,
            p_unit_header_id                => p_unit_header_id,
            p_rule_type                     => 'MANDATORY',
        p_check_subconfig_flag          => FND_API.G_TRUE,
            p_x_error_tbl                   => l_error_table,
        x_evaluation_status             => l_evaluation_status
          );

   -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
   -- Perform Quantity Validations
   AHL_UC_POS_NECES_PVT.Validate_Position_Quantities (
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => p_unit_header_id,
        p_csi_instance_id               => null,
        x_evaluation_status             => l_evaluation_status,
        p_x_error_table                 => l_error_table,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

   --validate the uc header id
   OPEN validate_uc_header_id_csr(p_unit_header_id);
   FETCH validate_uc_header_id_csr INTO l_uc_status_code;
   IF (validate_uc_header_id_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UC_HEADER_ID_INVALID');
       FND_MESSAGE.Set_Token('UC_HEADER_ID', p_unit_header_id);
       FND_MSG_PUB.ADD;
       CLOSE validate_uc_header_id_csr;
       RAISE  FND_API.G_EXC_ERROR;
   END IF;
   CLOSE validate_uc_header_id_csr;

   IF (l_uc_status_code = 'INCOMPLETE' AND
       l_error_table.COUNT = 0) THEN
      UPDATE AHL_UNIT_CONFIG_HEADERS
         SET UNIT_CONFIG_STATUS_CODE = 'COMPLETE',
         OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
         LAST_UPDATE_DATE      = sysdate,
         LAST_UPDATED_BY       = fnd_global.USER_ID,
         LAST_UPDATE_LOGIN     = fnd_global.LOGIN_ID
    WHERE unit_config_header_id = p_unit_header_id;
   ELSIF (l_error_table.COUNT >0 AND
       l_uc_status_code = 'COMPLETE') THEN
       UPDATE AHL_UNIT_CONFIG_HEADERS
         SET UNIT_CONFIG_STATUS_CODE = 'INCOMPLETE',
         OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
         LAST_UPDATE_DATE      = sysdate,
         LAST_UPDATED_BY       = fnd_global.USER_ID,
         LAST_UPDATE_LOGIN     = fnd_global.LOGIN_ID
    WHERE unit_config_header_id = p_unit_header_id;
  END IF;

  --Setting output parameters
  x_error_tbl := l_error_table;

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

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Rollback to Validate_Completeness;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Validate_Completeness;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Validate_Completeness;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Validate_Completeness;


--------------------------------
-- Start of Comments --
--  Procedure name    : Validate_Complete_For_Pos
--  Type        : Private
--  Function    : Validates the unit's completeness and checks for ALL validations.
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Complete_For_Pos Parameters:
--   p_unit_header_id         IN    NUMBER Required.
--       p_csi_instance_id            IN   NUMBER Required.
--       x_error_tbl     OUT NOCOPY   AHL_MC_VALIDATION_PUB.error_tbl_Type Required
--
--  End of Comments.

PROCEDURE Validate_Complete_For_Pos (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_csi_instance_id     IN           NUMBER,
    x_error_tbl       OUT NOCOPY       Error_Tbl_Type)
IS
--
  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Complete_For_Pos';
  l_error_table       Error_Tbl_Type;
  l_evaluation_status VARCHAR2(1);
--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Validate_Complete_For_Pos;

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

  --List Extra nodes
  AHL_UC_POS_NECES_PVT.list_extra_nodes(
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => null,
    p_csi_instance_id               => p_csi_instance_id,
        x_evaluation_status             => l_evaluation_status,
        p_x_error_table                 => l_error_table,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );

  --List Missing Positions
  AHL_UC_POS_NECES_PVT.list_missing_positions(
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => null,
        p_csi_instance_id               => p_csi_instance_id,
        x_evaluation_status             => l_evaluation_status,
        p_x_error_table                 => l_error_table,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );


   --Validate Rules
    AHL_MC_RULE_ENGINE_PVT.Validate_Rules_For_Position (
            p_api_version                   => 1.0,
            p_init_msg_list                 => p_init_msg_list,
            p_validation_level              => p_validation_level,
            x_return_status                 => x_return_status,
            x_msg_count                     => x_msg_count,
            x_msg_data                      => x_msg_data,
            p_item_instance_id              => p_csi_instance_id,
            p_rule_type                     => 'MANDATORY',
            p_x_error_tbl                   => l_error_table,
        x_evaluation_status             => l_evaluation_status
          );

   -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
   -- Perform Quantity Validations
   AHL_UC_POS_NECES_PVT.Validate_Position_Quantities (
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => null,
        p_csi_instance_id               => p_csi_instance_id,
        x_evaluation_status             => l_evaluation_status,
        p_x_error_table                 => l_error_table,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

  --Setting output parameters
  x_error_tbl := l_error_table;

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

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Rollback to Validate_Complete_For_Pos;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Validate_Complete_For_Pos;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Validate_Complete_For_Pos;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
END Validate_Complete_For_Pos;


-------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Check_Completeness
--  Type        : Private
--  Function    : Check the unit's completeness
--   Complete/Incomplete status if current status is complete or incomplete..
--  Pre-reqs    :
--  Parameters  :
--
--  Check_Completeness Parameters:
--   p_unit_header_id         IN            NUMBER Required.
--          The header identifier of the Unit Configuration
--   x_evaluation_status     OUT  NOCOPY    VARCHAR2
--          The evaluation status of the Unit Configutation.Returns a FND_API.G_TRUE or FND_API.G_FALSE
--  End of Comments.
-------------------------------------------------------------------------------
PROCEDURE Check_Completeness (
    p_api_version         IN             NUMBER,
    p_init_msg_list       IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id      IN             NUMBER,
    x_evaluation_status   OUT  NOCOPY    VARCHAR2)
IS
--
  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'Check_Completeness';
--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Check_Completeness;

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
  x_evaluation_status := 'U';

  IF (p_unit_header_id IS NULL OR p_unit_header_id = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
    FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
    FND_MSG_PUB.add;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Check for Extra nodes
  AHL_UC_POS_NECES_PVT.check_extra_nodes(
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => p_unit_header_id,
        x_evaluation_status             => x_evaluation_status,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );
   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
   END IF;


  IF ( x_evaluation_status = FND_API.G_TRUE ) THEN
    --Check for Missing Positions
    AHL_UC_POS_NECES_PVT.check_missing_positions(
            p_api_version                   => 1.0,
            p_init_msg_list                 => p_init_msg_list,
            p_validation_level              => p_validation_level,
            p_uc_header_id                  => p_unit_header_id,
            x_evaluation_status             => x_evaluation_status,
            x_return_status                 => x_return_status,
            x_msg_count                     => x_msg_count,
            x_msg_data                      => x_msg_data
        );
     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  IF ( x_evaluation_status = FND_API.G_TRUE ) THEN
    --Check for Rules
    AHL_MC_RULE_ENGINE_PVT.Check_Rules_For_Unit (
            p_api_version                   => 1.0,
            p_init_msg_list                 => p_init_msg_list,
            p_validation_level              => p_validation_level,
            p_unit_header_id                => p_unit_header_id,
        p_rule_type                     => 'MANDATORY',
            p_check_subconfig_flag          => FND_API.G_TRUE,
            x_evaluation_status               => x_evaluation_status,
            x_return_status                 => x_return_status,
            x_msg_count                     => x_msg_count,
            x_msg_data                      => x_msg_data
        );
     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
    IF (x_evaluation_status <> 'F') THEN
      -- Perform Quantity Checks
      AHL_UC_POS_NECES_PVT.Check_Position_Quantities (
        p_api_version                   => 1.0,
        p_init_msg_list                 => p_init_msg_list,
        p_validation_level              => p_validation_level,
        p_uc_header_id                  => p_unit_header_id,
        x_evaluation_status             => x_evaluation_status,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );

      -- Check Error Message stack.
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count > 0 THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
    END IF;

   END IF;

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

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Rollback to Check_Completeness;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Check_Completeness;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Check_Completeness;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Check_Completeness;


END AHL_UC_VALIDATION_PUB;

/

--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UNITMAINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UNITMAINT_PUB" AS
--/* $Header: AHLPUMXB.pls 115.5 2003/10/17 05:32:09 sracha noship $ */


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_UNITMAINT_PUB';

------------------------------
-- Declare Local Procedures --
------------------------------

------------------------
-- Define Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Capture_MR_Updates
--  Type              : Public
--  Function          : For a given set of instances, will record their statuses with either
--                      accomplishment date or deferred-next due date or termination date with
--                      their corresponding counter and counter values.
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
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  Capture MR Update Parameters:
--       p_unit_Effectivity_tbl         IN      Unit_Effectivity_tbl_type  Required
--         List of all unit effectivities whose status, due or accomplished dates
--         and counter values need to be captured
--       p_x_Unit_Threshold_tbl         IN OUT  Unit_Threshold_tbl_type    Required
--         List of all thresholds (counters and counter values) when a MR becomes due
--       p_x_Unit_Accomplish_tbl        IN OUT  Unit_Accomplish_tbl_type   Required
--         List of all counters and corresponding counter values when the MR was last accomplished
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Capture_MR_Updates (
    p_api_version           IN            NUMBER    := 1.0,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_unit_Effectivity_tbl  IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_tbl_type,
    p_x_unit_threshold_tbl  IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
    p_x_unit_accomplish_tbl IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2)  IS


  l_api_name       CONSTANT VARCHAR2(30) := 'Capture_MR_Updates';
  l_api_version    CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Capture_MR_Updates_Pub;

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

  -- Call Private API.
  AHL_UMP_UNITMAINT_PVT.Capture_MR_Updates(
     	                      p_api_version           => 1.0,
                              p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                              p_unit_Effectivity_tbl  => p_unit_Effectivity_tbl,
                              p_x_unit_threshold_tbl  => p_x_unit_threshold_tbl,
                              p_x_unit_accomplish_tbl => p_x_unit_accomplish_tbl,
                              x_return_status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data );



  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Capture_MR_Updates_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Capture_MR_Updates_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Capture_MR_Updates_Pub;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Master_Config',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


END Capture_MR_Updates;





------------------------
-- Define Procedures Terminate_MR_Instances --
------------------------

-- Start of Comments --
--  Procedure name    : Terminate_MR_Instances
--  Type              : Public
--  Function          :
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--
--  Terminate_MR_Instances Parameters :
--  p_old_mr_header_id    IN            NUMBER,
--  p_old_mr_title        IN            VARCHAR2,
--  p_old_version_number  IN            NUMBER,
--  p_new_mr_header_id    IN            NUMBER,
--  p_new_mr_title        IN            VARCHAR2,
--  p_new_version_number  IN            NUMBER,
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Terminate_MR_Instances (
    p_api_version         IN            NUMBER    := 1.0,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default             IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type         IN            VARCHAR2  := NULL,
    p_old_mr_header_id    IN            NUMBER,
    p_old_mr_title        IN            VARCHAR2,
    p_old_version_number  IN            NUMBER,
    p_new_mr_header_id    IN            NUMBER    := NULL,
    p_new_mr_title        IN            VARCHAR2  := NULL,
    p_new_version_number  IN            NUMBER    := NULL,
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2 ) IS


  l_api_name       CONSTANT VARCHAR2(30) := 'Terminate_MR_Instances';
  l_api_version    CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Terminate_MR_Instances_Pub;

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

  -- Call Private API.
  AHL_UMP_UNITMAINT_PVT.Terminate_MR_Instances (
    p_api_version           =>          1.0,
    p_validation_level      =>          FND_API.G_VALID_LEVEL_FULL,
    p_old_mr_header_id      =>          p_old_mr_header_id,
    p_old_mr_title          =>          p_old_mr_title,
    p_old_version_number    =>          p_old_version_number,
    p_new_mr_header_id      =>          p_new_mr_header_id,
    p_new_mr_title          =>          p_new_mr_title,
    p_new_version_number    =>          p_new_version_number,
    x_return_status         =>          x_return_status,
    x_msg_count             =>          x_msg_count,
    x_msg_data              =>          x_msg_data );



  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Terminate_MR_Instances_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Terminate_MR_Instances_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Terminate_MR_Instances_Pub;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Terminate_MR_Instances',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


END Terminate_MR_Instances;

-- Start of Comments --
--  Procedure name    : Process_UnitEffectivity
--  Type        : Private
--  Function    : Manages Create/Modify/Delete operations of applicable maintenance
--                requirements on a unit.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL _FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--

--
--  Process_UnitEffectivity Parameters :
--      If no input parameters are passed, then effectivity will be built for all units.
--      If either p_mr_header_id OR p_mr_title and p_mr_version_number are passed, then effectivity
--      will be built for all units having this maintenance requirement; p_mr_header_id being the unique
--      identifier of a maintenance requirement.
--      If either p_csi_item_instance_id OR p_csi_instance_number are passed, then effectivity
--        will be built for the unit this item instance belongs to.
--      If either p_unit_name OR p_unit_config_header_id are passed, then effectivity will be
--        built for the unit configuration.
--

PROCEDURE Process_UnitEffectivity (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default                IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type            IN            VARCHAR2  := NULL,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    p_mr_header_id           IN            NUMBER    := NULL,
    p_mr_title               IN            VARCHAR2  := NULL,
    p_mr_version_number      IN            NUMBER    := NULL,
    p_unit_config_header_id  IN            NUMBER    := NULL,
    p_unit_name              IN            VARCHAR2  := NULL,
    p_csi_item_instance_id   IN            NUMBER    := NULL,
    p_csi_instance_number    IN            VARCHAR2  := NULL)

IS

  l_api_name       CONSTANT VARCHAR2(30) := 'Process_UnitEffectivity';
  l_api_version    CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Process_UnitEffectivity_PUB;

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

  -- Call Private API.
  AHL_UMP_UNITMAINT_PVT.Process_UnitEffectivity(
                          p_api_version         => 1.0,
                          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_mr_header_id        => p_mr_header_id,
                          p_mr_title            => p_mr_title,
                          p_mr_version_number   => p_mr_version_number,
                          p_unit_config_header_id => p_unit_config_header_id,
                          p_unit_name             => p_unit_name,
                          p_csi_item_instance_id  => p_csi_item_instance_id,
                          p_csi_instance_number   => p_csi_instance_number);

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Process_UnitEffectivity_PUB;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Process_UnitEffectivity_PUB;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_UnitEffectivity_PUB;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_UnitEffectivity',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


END Process_UnitEffectivity;

End AHL_UMP_UNITMAINT_PUB;

/

--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UNITMAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UNITMAINT_PVT" AS
/* $Header: AHLVUMXB.pls 120.20.12010000.8 2009/11/05 01:42:35 sracha ship $ */


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_UnitMaint_PVT';

G_DEBUG                      VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

TYPE CounterCurTyp is REF CURSOR;


-------------------------------
-- Declare Local Procedures --
-------------------------------
  -- Converts Value to Id for a Threshold
  PROCEDURE Convert_Threshold_Val_To_ID(
     p_x_unit_threshold_rec IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_rec_type,
     x_return_status           OUT NOCOPY VARCHAR2);

  -- Converts Value to Id for an Accomplishment
  PROCEDURE Convert_Accomplish_Val_To_ID(
     p_x_unit_accomplish_rec IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

  -- Converts Value to Id for an Unit Effectivity
  PROCEDURE Convert_Effectivity_Val_To_ID(
     p_x_unit_Effectivity_rec IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type,
     x_return_status          OUT    NOCOPY VARCHAR2);

  -- Validates an Unit Effectivity
  PROCEDURE Validate_Effectivity(
     p_unit_Effectivity_rec IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type,
     p_authorized_user_flag IN            VARCHAR2 := 'N',
     x_return_status        IN OUT NOCOPY VARCHAR2);

  -- Validates Thresholds
  PROCEDURE Validate_Thresholds(
     p_unit_threshold_tbl   IN OUT  NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
     x_return_status        IN OUT  NOCOPY VARCHAR2);

  -- Validates Accomplishments
  -- Added accomplishment date to fix bug# 6750836.
  PROCEDURE Validate_Accomplishments(
     p_unit_accomplish_tbl  IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
     p_accomplishment_date  IN            DATE,
     p_ue_status_code       IN            VARCHAR2,
     x_return_status        IN OUT NOCOPY VARCHAR2);

  -- Updates a Unit Effectivity
  PROCEDURE Update_Unit_Effectivity(
     p_unit_Effectivity_rec IN AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type);

  -- Terminates a descendent Unit Effectivity
  PROCEDURE Terminate_Descendent(
     p_descendent_ue_id IN NUMBER);

  -- Updates Thresholds
  PROCEDURE Update_Thresholds(
     p_unit_Effectivity_rec IN AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type,
     p_x_unit_threshold_tbl IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type);

  -- Updates Accomplishments
  -- Added p_unit_Effectivity_rec for R12: for counter lock
  PROCEDURE Update_Accomplishments(
     p_x_unit_accomplish_tbl IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
     p_unit_Effectivity_rec  IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type);

  -- Copies updated Thresholds from a sublist back to the original master list
  PROCEDURE Restore_Thresholds(
     p_x_unit_threshold_tbl   IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
     p_unit_threshold_tbl     IN     AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type);

  -- Copies updated Accomplishments from a sublist back to the original master list
  PROCEDURE Restore_Accomplishments(
     p_x_unit_accomplish_tbl   IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
     p_unit_accomplish_tbl     IN     AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type);

  -- Calls FMP API to match counters before accomplishments and terminations
  PROCEDURE Match_Counters_with_FMP(
     p_unit_effectivity_id     IN  NUMBER,
     p_item_instance_id        IN  NUMBER,
     p_mr_header_id            IN  NUMBER,
     x_counters                OUT NOCOPY VARCHAR2,
     x_return_status           OUT NOCOPY VARCHAR2);

  -- Converts value to ID for an MR.
  Procedure Convert_MRID (p_x_mr_id        IN OUT NOCOPY  NUMBER,
                          p_mr_title       IN             VARCHAR2,
                          p_version_number IN             NUMBER);

  -- Converts value to ID for a Unit Configuration.
  Procedure Convert_Unit (p_x_uc_header_id IN OUT NOCOPY  NUMBER,
                          p_unit_name      IN             VARCHAR2);

  -- Converts value to ID for an item instance.
  Procedure Convert_Instance (p_x_csi_item_instance_id IN OUT NOCOPY  NUMBER,
                              p_csi_instance_number    IN             VARCHAR2);

  -- Validation procedure.
  Procedure Validate_Input_Parameters (p_mr_header_id  IN  NUMBER,
                                       p_x_csi_item_instance_id   IN OUT NOCOPY NUMBER,
                                       p_unit_config_header_id  IN  NUMBER);

  -- AMSRINIV : Bug #4360784.. Removed p_unit_config_header_id as a input for Validate_PM_Input_Parameters
  -- Tamal: Bug #4207212, #4114368 Begin
  -- Validation procedure for PM mode.
  Procedure Validate_PM_Input_Parameters (p_mr_header_id  IN  NUMBER,
                                          p_csi_item_instance_id   IN  NUMBER,
                                          p_contract_number  IN  VARCHAR2,
                                          p_contract_modifier  IN  VARCHAR2);
  -- Tamal: Bug #4207212, #4114368 End

  -- Procedure to mark a unit effectivity as MR-Terminated.
  PROCEDURE MR_Terminate(p_unit_effectivity_id IN NUMBER);

  -- To log error messages into a log file if called from concurrent process.
  PROCEDURE log_error_messages;

-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

-- Start of Comments --
--  Procedure name    : Process_UnitEffectivity
--  Type        : Private
--  Function    : Manages Create/Modify/Delete operations for unit maintenance requirements.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_UnitEffectivity Parameters :
--      If no input parameters are passed, then effectivity will be built for all units.
--      If either p_mr_header_id OR p_mr_title and p_mr_version_number are passed, then effectivity
--        will be built for all units having this maintenance requirement.
--      If either p_csi_item_instance_id OR p_csi_instance_number are passed, then effectivity
--        will be built for the specfic unit this item instance belongs to.
--      If either p_unit_name OR p_unit_config_header_id are passed, then effectivity will be
--        built for this specific unit configuration.
--      p_mr_header_id is the unique identifier of a maintenance requirement.
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
    p_csi_instance_number    IN            VARCHAR2  := NULL

)  IS

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Process_UnitEffectivity';

  -- Local variables.
  l_mr_id                  NUMBER  := p_mr_header_id;
  l_unit_config_header_id  NUMBER  := p_unit_config_header_id;
  l_csi_item_instance_id   NUMBER  := p_csi_item_instance_id;
  l_msg_count              NUMBER;


BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Process_UnitEffectivity_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Add debug mesg.
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || l_api_name);
  END IF;

  -- Convert Value to IDs and validate.
  -- For maintenance requirement.
  IF (l_mr_id IS NULL OR l_mr_id = FND_API.G_MISS_NUM) THEN
    Convert_MRID (l_mr_id, p_mr_title, p_mr_version_number);
  END IF;

  -- For instance id.
  IF (l_csi_item_instance_id IS NULL OR
      l_csi_item_instance_id = FND_API.G_MISS_NUM) THEN
    Convert_Instance (l_csi_item_instance_id, p_csi_instance_number);
  END IF;

  -- For unit name.
  IF (l_unit_config_header_id IS NULL OR
      l_unit_config_header_id = FND_API.G_MISS_NUM) THEN
    Convert_Unit (l_unit_config_header_id, p_unit_name);
  END IF;

  Validate_Input_Parameters (l_mr_id, l_csi_item_instance_id, l_unit_config_header_id);

  -- Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

 -- Depending on input parameters call procedures for processing.
  IF (l_mr_id IS NOT NULL) THEN
           -- process all units affected by the MR.
           AHL_UMP_ProcessUnit_PVT.Process_MRAffected_Units (
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            x_return_status => x_return_status,
                            p_mr_header_id  => l_mr_id);

  ELSIF (l_csi_item_instance_id IS NOT NULL) THEN
           -- Call Process Unit for the item instance.
           AHL_UMP_ProcessUnit_PVT.Process_Unit (
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            x_return_status        => x_return_status,
                            p_csi_item_instance_id => l_csi_item_instance_id);


  ELSE
           -- process all units.
           AHL_UMP_ProcessUnit_PVT.Process_All_Units (
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            x_return_status        => x_return_status);

  END IF;

  -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Process_UnitEffectivity_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;



 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Process_UnitEffectivity_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_UnitEffectivity_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_UnitEffectivity_PVT',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

    -- Disable debug
    AHL_DEBUG_PUB.disable_debug;

END Process_UnitEffectivity;

--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Build_UnitEffectivity
--  Type        : Private
--  Function    : This procedure will build unit and item effectivity and commit.
--                Build_UnitEffectivity will commit at a unit level. If the
--                unit has any errors, then rollback will be performed for that unit only.
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
-- Parameters:
--  If no input parameters are passed, then effectivity will be built for all units.
--  If either p_mr_header_id OR p_mr_title and p_mr_version_number are passed, then effectivity
--  will be built for all units having this maintenance requirement; p_mr_header_id being
--  the unique
--  identifier of a maintenance requirement.
--  If either p_csi_item_instance_id OR p_csi_instance_number are passed, then effectivity
--  will be built for the unit this item instance belongs to.
--  If either p_unit_name OR p_unit_config_header_id are passed, then effectivity will be
--  built for the unit configuration.
--

PROCEDURE Build_UnitEffectivity (
              p_init_msg_list          IN            VARCHAR2 := FND_API.G_FALSE,
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
              p_csi_instance_number    IN            VARCHAR2  := NULL,
              -- Tamal: Bug #4207212, #4114368 Begin
              p_contract_number        IN            VARCHAR2  := NULL,
              p_contract_modifier      IN            VARCHAR2  := NULL,
              -- Tamal: Bug #4207212, #4114368 End
              p_concurrent_flag        IN            VARCHAR2  := 'N' ,
              -- sracha: Added parameter to launch multiple workers.
              p_num_of_workers         IN            NUMBER    := 1,
              p_mtl_category_id        IN            NUMBER    := NULL,
              p_process_option         IN            VARCHAR2  := NULL)
IS

  -- Local variables.
  l_api_name               VARCHAR2(200) := 'Build_UnitEffectivity';
  l_mr_id                  NUMBER  := p_mr_header_id;
  l_unit_config_header_id  NUMBER  := p_unit_config_header_id;
  l_csi_item_instance_id   NUMBER  := p_csi_item_instance_id;
  l_contract_number        VARCHAR2(120)  := p_contract_number;
  l_contract_modifier      VARCHAR2(120)  := p_contract_modifier;
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Add debug mesg.
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || l_api_name);
  END IF;

  -- Convert Value to IDs and validate.
  -- For maintenance requirement.
  IF (l_mr_id IS NULL OR l_mr_id = FND_API.G_MISS_NUM) THEN
    Convert_MRID (l_mr_id, p_mr_title, p_mr_version_number);
  END IF;

  -- For instance id.
  IF (l_csi_item_instance_id IS NULL OR
      l_csi_item_instance_id = FND_API.G_MISS_NUM) THEN
    Convert_Instance (l_csi_item_instance_id, p_csi_instance_number);
  END IF;

  -- For unit name.
  IF (l_unit_config_header_id IS NULL OR
      l_unit_config_header_id = FND_API.G_MISS_NUM) THEN
    Convert_Unit (l_unit_config_header_id, p_unit_name);
  END IF;

  --AMSRINIV: Bug #4360784
  -- Tamal: Bug #4207212, #4114368 Begin
  IF (ahl_util_pkg.is_pm_installed = 'Y')
  THEN
    Validate_PM_Input_Parameters (l_mr_id, l_csi_item_instance_id, l_contract_number, l_contract_modifier);
  ELSE
    Validate_Input_Parameters (l_mr_id, l_csi_item_instance_id, l_unit_config_header_id);
  END IF;
  -- Tamal: Bug #4207212, #4114368 End

  -- Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Depending on input parameters call procedures for processing.
  -- Tamal: Bug #4207212, #4114368 Begin
  IF (l_contract_number IS NOT NULL and ahl_util_pkg.is_pm_installed = 'Y') THEN
        -- Process all units affected by the contract number...
        AHL_UMP_ProcessUnit_PVT.Process_PM_Contracts
        (
            p_commit            => FND_API.G_TRUE,
            p_init_msg_list     => FND_API.G_FALSE,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            x_return_status     => x_return_status,
            p_contract_number   => l_contract_number,
            p_contract_modifier => l_contract_modifier,
            p_concurrent_flag   => p_concurrent_flag
        );
  -- Tamal: Bug #4207212, #4114368 End
  ELSIF (l_mr_id IS NOT NULL) THEN
           -- process all units affected by the MR.
           AHL_UMP_ProcessUnit_PVT.Process_MRAffected_Units (
                            p_commit           => FND_API.G_TRUE,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data,
                            x_return_status    => x_return_status,
                            p_mr_header_id     => l_mr_id,
                            p_concurrent_flag  => p_concurrent_flag,
                            p_num_of_workers   => p_num_of_workers,
                            p_mtl_category_id  => p_mtl_category_id,
                            p_process_option   => p_process_option);

  ELSIF (l_csi_item_instance_id IS NOT NULL) THEN
           -- Call Process Unit for the item instance.
           AHL_UMP_ProcessUnit_PVT.Process_Unit (
                            p_commit               => FND_API.G_TRUE,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            x_return_status        => x_return_status,
                            p_csi_item_instance_id => l_csi_item_instance_id,
                            p_concurrent_flag      => p_concurrent_flag);

  ELSE
           -- process all units.
           AHL_UMP_ProcessUnit_PVT.Process_All_Units (
                            p_commit               => FND_API.G_TRUE,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            x_return_status        => x_return_status,
                            p_concurrent_flag      => p_concurrent_flag,
                            p_num_of_workers       => p_num_of_workers,
                            p_mtl_category_id      => p_mtl_category_id,
                            p_process_option       => p_process_option);

  END IF;

  -- Check return status.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Building Unit Effectivity failed. Refer to the error message below.');
     log_error_messages;
   END IF;
   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;



 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Building Unit Effectivity failed. Refer to the error message below.');
     log_error_messages;
   END IF;
   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Build_UnitEffectivity_PVT',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

    IF (p_concurrent_flag = 'Y') THEN
     fnd_file.put_line(fnd_file.log, 'Building Unit Effectivity failed. Refer to the error message below.');
     log_error_messages;
    END IF;

    -- Disable debug
    AHL_DEBUG_PUB.disable_debug;

END Build_UnitEffectivity;

-----------------------------

PROCEDURE Capture_MR_Updates
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_unit_Effectivity_tbl  IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_tbl_type,
    p_x_unit_threshold_tbl  IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
    p_x_unit_accomplish_tbl IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2) IS

   l_api_version            CONSTANT NUMBER := 1.5;
   l_api_name               CONSTANT VARCHAR2(30) := 'Capture_MR_Updates';
   l_unit_Effectivity_rec   AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type;
   l_unit_threshold_tbl     AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type;
   l_unit_accomplish_tbl    AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type;
   l_MR_Initialization_flag VARCHAR2(1) := 'N';
   l_prev_status            VARCHAR2(30);
   l_prev_object_version_no NUMBER;
   l_counter_index          BINARY_INTEGER   := 0;
   l_temp_return_status     VARCHAR2(30);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Capture_MR_Updates_pvt;

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

  -- Begin Processing

  -- Enable Debug (optional)
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Check if the user is authorized: is in role AHL_UMP_MR_INITIALIZE
  -- This functionality is not available now. So allow always
  l_MR_Initialization_flag := 'Y';

  IF (p_unit_Effectivity_tbl.COUNT > 0) THEN
    -- If from JSP, nullify counter ids since they come from LOV
    IF (p_module_type = 'JSP') THEN
        IF (p_x_unit_threshold_tbl.COUNT > 0) THEN
          FOR i IN p_x_unit_threshold_tbl.FIRST..p_x_unit_threshold_tbl.LAST LOOP
            p_x_unit_threshold_tbl(i).COUNTER_ID := null;
          END LOOP;
        END IF;
        IF (p_x_unit_accomplish_tbl.COUNT > 0) THEN
          FOR j IN p_x_unit_accomplish_tbl.FIRST..p_x_unit_accomplish_tbl.LAST LOOP
            p_x_unit_accomplish_tbl(j).COUNTER_ID := null;
          END LOOP;
        END IF;
    END IF;

    IF FND_API.to_boolean( p_default ) THEN
      -- No special default settings required in this API
      null;
    END IF;
    IF G_DEBUG='Y'  THEN
      AHL_DEBUG_PUB.debug('Beginning Processing... ', 'UMP');
    END IF;
    -- Start processing
    FOR i IN p_unit_Effectivity_tbl.FIRST..p_unit_Effectivity_tbl.LAST LOOP
      -- Initialize Return Status for this Unit Effectivity to SUCCESS
      l_temp_return_status := FND_API.G_RET_STS_SUCCESS;
      l_unit_Effectivity_rec := p_unit_Effectivity_tbl(i);

      -- Resolve Values to Ids
      convert_effectivity_val_to_id(l_unit_Effectivity_rec, l_temp_return_status);
      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('Resolved Values to Id for Effectivity', 'UMP');
      END IF;
      -- Ignore errors from the resolution process
      l_temp_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate the current unit effectivity record
      Validate_Effectivity(l_unit_Effectivity_rec, l_MR_Initialization_flag, l_temp_return_status);
      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('Validated Effectivity, Status = ' || l_temp_return_status, 'UMP');

      END IF;
      -- Continue processing this effectivity only if there are no errors
      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('About to process thresholds', 'UMP');
        AHL_DEBUG_PUB.debug('Count threshold:' || p_x_unit_threshold_tbl.count, 'UMP');
      END IF;
      IF l_temp_return_status = FND_API.G_RET_STS_SUCCESS THEN
        -- Get all the thresholds for the current effectivity
        IF (p_x_unit_threshold_tbl.COUNT > 0) THEN
          l_counter_index := 0;
          FOR j IN p_x_unit_threshold_tbl.FIRST..p_x_unit_threshold_tbl.LAST LOOP
            IF (p_x_unit_threshold_tbl(j).UNIT_EFFECTIVITY_ID = l_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID) THEN
              l_counter_index := l_counter_index + 1;
              l_unit_threshold_tbl(l_counter_index) := p_x_unit_threshold_tbl(j);
            END IF;
          END LOOP;  /* thresholds-table */
          Validate_Thresholds(l_unit_threshold_tbl, l_temp_return_status);
          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('Validated Threshold', 'UMP');
          END IF;
        END IF;

        IF G_DEBUG='Y'  THEN
          AHL_DEBUG_PUB.debug('About to process accomplishments', 'UMP');
          AHL_DEBUG_PUB.debug('Count accomplishments Tbl:' || p_x_unit_accomplish_tbl.count, 'UMP');
        END IF;
        -- Get all the accomplishments for the current effectivity
        IF (p_x_unit_accomplish_tbl.COUNT > 0) THEN
          l_counter_index := 0;
          FOR k IN p_x_unit_accomplish_tbl.FIRST..p_x_unit_accomplish_tbl.LAST LOOP
            IF (p_x_unit_accomplish_tbl(k).UNIT_EFFECTIVITY_ID = l_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID) THEN
              l_counter_index := l_counter_index + 1;
              l_unit_accomplish_tbl(l_counter_index) := p_x_unit_accomplish_tbl(k);
            END IF;
          END LOOP;  /* accomplishments-table */
          Validate_Accomplishments(l_unit_accomplish_tbl, l_unit_Effectivity_rec.ACCOMPLISHED_DATE,
                                   l_unit_Effectivity_rec.STATUS_CODE, l_temp_return_status);
          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('Validated Accomplishment', 'UMP');
          END IF;
        END IF;

        -- Proceed to updating the database only if there are no errors
        IF l_temp_return_status = FND_API.G_RET_STS_SUCCESS THEN

          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('About to update thresholds', 'UMP');
          END IF;
          -- First Update the Unit Thresholds Table
          Update_Thresholds(l_unit_Effectivity_rec,
                            l_unit_threshold_tbl);
          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('About to restore thresholds', 'UMP');
          END IF;
          -- Restore the saved thresholds in the IN OUT parameter
          Restore_Thresholds(p_x_unit_threshold_tbl, l_unit_threshold_tbl);

          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('About to update accomplishments', 'UMP');
          END IF;
          -- Next Update the Unit Accomplishments Table
          Update_Accomplishments(l_unit_accomplish_tbl, l_unit_Effectivity_rec);
          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('About to restore accomplishments', 'UMP');
          END IF;
          -- Restore the saved accomplishments in the IN OUT parameter
          Restore_Accomplishments(p_x_unit_accomplish_tbl, l_unit_accomplish_tbl);

          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('About to update unit effectivity', 'UMP');
          END IF;
          -- Finally update the Unit Effectivities Table
          Update_Unit_Effectivity(l_unit_Effectivity_rec);
          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('Updated unit effectivity', 'UMP');
          END IF;
        END IF;
      END IF;

      -- Clear the local tables to prepare for next Unit effectivity
      l_unit_threshold_tbl.DELETE;
      l_unit_accomplish_tbl.DELETE;
    END LOOP;  /* effectivity-table */
  END IF;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Completed Processing. Checking for errors', 'UMP');
  END IF;
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
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

  -- Disable debug (if enabled)
  AHL_DEBUG_PUB.disable_debug;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Capture_MR_Updates_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Capture_MR_Updates_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
   Rollback to Capture_MR_Updates_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF (SQLCODE = -54) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_UMP_RECORD_LOCKED');
     FND_MSG_PUB.ADD;
   ELSE
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Capture_MR_Updates',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
   END IF;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

END Capture_MR_Updates;

-----------------------------

PROCEDURE Validate_For_Initialize
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_unit_effectivity_id   IN            NUMBER,
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2
) IS


  CURSOR l_child_mr_csr(p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UE_RELATIONSHIPS
    WHERE related_ue_id = p_ue_id;

  CURSOR l_prior_initializations_csr(p_mr_id IN NUMBER,
                                     p_item_instance_id IN NUMBER,
                                     p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE MR_HEADER_ID = p_mr_id AND
    CSI_ITEM_INSTANCE_ID = p_item_instance_id AND
    status_code IN ('INIT-DUE', 'INIT-ACCOMPLISHED') AND
    UNIT_EFFECTIVITY_ID <> p_ue_id;

  CURSOR l_ue_details_csr(p_ue_id IN NUMBER) IS
    SELECT MR_HEADER_ID, CSI_ITEM_INSTANCE_ID, REPETITIVE_MR_FLAG, STATUS_CODE
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE UNIT_EFFECTIVITY_ID = p_ue_id;

  l_api_version            CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate_For_Initialize';
  l_junk                   VARCHAR2(1);
  l_mr_id                  NUMBER;
  l_item_instance_id       NUMBER;
  l_repetitive_mr_flag     VARCHAR2(1);
  l_status_code            VARCHAR2(30);
  l_MR_Initialization_flag VARCHAR2(1) := 'N';
  l_last_accomplish_date   DATE := null;
  l_last_ue_id             NUMBER := null;
  l_temp_status            BOOLEAN;
  l_temp_status_code       VARCHAR2(30);
  l_temp_deferral_flag     BOOLEAN;

  l_prior_ue_status        VARCHAR2(30);

  -- added for visit validation
  l_visit_status           VARCHAR2(100);

BEGIN
  --IF G_DEBUG='Y'  THEN
  --  AHL_DEBUG_PUB.enable_debug;
  --END IF;
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

  -- Begin Processing

  -- Ensure that the User is authorized to initialize
  -- This functionality is not available now. So allow always
  l_MR_Initialization_flag := 'Y';
  IF (l_MR_Initialization_flag <> 'Y') THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_UNAUTHORIZED_USER');
    FND_MSG_PUB.ADD;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Unauthorized User', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (p_unit_effectivity_id IS NULL OR p_unit_effectivity_id = FND_API.G_MISS_NUM) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_ID_NULL');
    FND_MSG_PUB.ADD;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Null Effectivity', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Ensure that this is not a repetitive MR
  OPEN l_ue_details_csr(p_unit_effectivity_id);
  FETCH l_ue_details_csr INTO l_mr_id, l_item_instance_id, l_repetitive_mr_flag, l_status_code;
  IF (l_ue_details_csr%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_ID_INVALID');
    FND_MESSAGE.Set_Token('UEID', p_unit_effectivity_id);
    FND_MSG_PUB.ADD;
    CLOSE l_ue_details_csr;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Invalid Effectivity Id', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  ELSE
    --Ensure that unit is not locked
    IF(AHL_UTIL_UC_PKG.IS_UNIT_QUARANTINED(p_unit_header_id => null, p_instance_id => l_item_instance_id) = FND_API.G_TRUE) THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.Set_Name('AHL','AHL_UMP_INIT_UNIT_LOCKED');
          FND_MSG_PUB.ADD;
	  CLOSE l_ue_details_csr;
	  RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (l_repetitive_mr_flag = 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_INVALID_MR_TYPE');
      FND_MSG_PUB.ADD;
      --IF G_DEBUG='Y'  THEN
        --AHL_DEBUG_PUB.debug('Repetitive Effectivity', 'UMP:Validate_For_Initialize');
      --END IF;
      CLOSE l_ue_details_csr;
      RAISE  FND_API.G_EXC_ERROR;
    ELSE
      CLOSE l_ue_details_csr;
    END IF;
  END IF;

  -- Ensure that this is not a child MR
  OPEN l_child_mr_csr(p_unit_effectivity_id);
  FETCH l_child_mr_csr INTO l_junk;
  IF (l_child_mr_csr%FOUND) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_CHILD_MR');
    FND_MSG_PUB.ADD;
    CLOSE l_child_mr_csr;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Child MR', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  ELSE
    CLOSE l_child_mr_csr;
  END IF;

  -- Ensure that the Current status is null, init-due or init-accomplished only
  IF ((l_status_code IS NOT NULL) AND (l_status_code <> 'INIT-DUE') AND (l_status_code <> 'INIT-ACCOMPLISHED')) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_INVALID_STATUS');
    FND_MESSAGE.Set_Token('STATUS', l_status_code);
    FND_MSG_PUB.ADD;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Invalid Status: ' || 'l_status_code', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Ensure that there are no prior accomplishments
  AHL_UMP_UTIL_PKG.get_last_accomplishment(l_item_instance_id, l_mr_id, l_last_accomplish_date, l_last_ue_id, l_temp_deferral_flag, l_temp_status_code, l_temp_status);
  IF (l_temp_status = FALSE) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (l_temp_status_code <> 'INIT-ACCOMPLISHED' and l_last_accomplish_date IS NOT null) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_ALRDY_ACCMPLSHD');
    FND_MSG_PUB.ADD;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Already Accomplished', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Ensure that there are no prior initializations
  OPEN l_prior_initializations_csr(l_mr_id, l_item_instance_id, p_unit_effectivity_id);
  FETCH l_prior_initializations_csr INTO l_prior_ue_status;
  IF (l_prior_initializations_csr%FOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (l_prior_ue_status = 'DEFERRED') THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_ALRDY_DEFERRED');
        FND_MSG_PUB.ADD;
    ELSE
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_ALRDY_INITLZD');
    FND_MSG_PUB.ADD;
    END IF;
    CLOSE l_prior_initializations_csr;
    --IF G_DEBUG='Y'  THEN
      --AHL_DEBUG_PUB.debug('Has prior Initializations', 'UMP:Validate_For_Initialize');
    --END IF;
    RAISE  FND_API.G_EXC_ERROR;
  ELSE
    CLOSE l_prior_initializations_csr;
  END IF;

  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
--    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
--       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
--                               p_procedure_name => 'Validate_For_Initialize',
--                               p_error_text     => SUBSTR(SQLERRM,1,240));
--    END IF;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Validate_For_Initialize;

----------------------------------------
-- Local Procedure Definitions follow --
----------------------------------------

PROCEDURE Convert_Effectivity_Val_To_ID(
     p_x_unit_Effectivity_rec IN OUT  NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type,
     x_return_status          OUT     NOCOPY VARCHAR2 ) IS

  CURSOR l_get_mr_id_csr(p_mr_title          IN VARCHAR2,
                     p_mr_version_number IN NUMBER) IS
    SELECT MR_HEADER_ID
    FROM  AHL_MR_HEADERS_B
    WHERE TITLE = p_mr_title AND
          VERSION_NUMBER = p_mr_version_number;

  CURSOR l_get_item_instance_id_csr(p_instance_number IN VARCHAR2) IS
    SELECT INSTANCE_ID
    FROM  CSI_ITEM_INSTANCES
    WHERE INSTANCE_NUMBER = p_instance_number;

  CURSOR l_get_status_code_csr(p_status_meaning IN VARCHAR2) IS
    SELECT LOOKUP_CODE
    FROM  fnd_lookup_values_vl
    WHERE lookup_type = 'AHL_UNIT_EFFECTIVITY_STATUS' AND
          MEANING = p_status_meaning;

   l_mr_id             NUMBER;
   l_item_instance_id  NUMBER;
   l_status_code       VARCHAR2(30);

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Resolve MR_ID
  IF(p_x_unit_Effectivity_rec.MR_ID IS NULL OR p_x_unit_Effectivity_rec.MR_ID = FND_API.G_MISS_NUM) THEN
    IF((p_x_unit_Effectivity_rec.MR_TITLE IS NOT NULL AND p_x_unit_Effectivity_rec.MR_TITLE <> FND_API.G_MISS_CHAR) AND
       (p_x_unit_Effectivity_rec.MR_VERSION_NUMBER IS NOT NULL AND p_x_unit_Effectivity_rec.MR_VERSION_NUMBER <> FND_API.G_MISS_NUM)) THEN
      OPEN l_get_mr_id_csr(p_x_unit_Effectivity_rec.MR_TITLE, p_x_unit_Effectivity_rec.MR_VERSION_NUMBER);
      FETCH l_get_mr_id_csr INTO l_mr_id;
      IF (l_get_mr_id_csr%FOUND) THEN
        p_x_unit_Effectivity_rec.MR_ID := l_mr_id;
      ELSE
        -- No match
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE l_get_mr_id_csr;
    ELSE
      -- Insufficient information to retrieve mr_id
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  -- Resolve CSI_ITEM_INSTANCE_ID
  IF(p_x_unit_Effectivity_rec.CSI_ITEM_INSTANCE_ID IS NULL OR p_x_unit_Effectivity_rec.CSI_ITEM_INSTANCE_ID = FND_API.G_MISS_NUM) THEN
    IF(p_x_unit_Effectivity_rec.CSI_INSTANCE_NUMBER IS NOT NULL AND p_x_unit_Effectivity_rec.CSI_INSTANCE_NUMBER <> FND_API.G_MISS_CHAR) THEN
      OPEN l_get_item_instance_id_csr(p_x_unit_Effectivity_rec.CSI_INSTANCE_NUMBER);
      FETCH l_get_item_instance_id_csr INTO l_item_instance_id;
      IF (l_get_item_instance_id_csr%FOUND) THEN
        p_x_unit_Effectivity_rec.CSI_ITEM_INSTANCE_ID := l_item_instance_id;
      ELSE
        -- No match
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE l_get_item_instance_id_csr;
    ELSE
      -- Insufficient information to retrieve item instance id
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  -- Resolve STATUS_CODE
  IF(p_x_unit_Effectivity_rec.STATUS_CODE IS NULL OR p_x_unit_Effectivity_rec.STATUS_CODE = FND_API.G_MISS_CHAR) THEN
    IF(p_x_unit_Effectivity_rec.STATUS IS NOT NULL AND p_x_unit_Effectivity_rec.STATUS <> FND_API.G_MISS_CHAR) THEN
      OPEN l_get_status_code_csr(p_x_unit_Effectivity_rec.STATUS);
      FETCH l_get_status_code_csr INTO l_status_code;
      IF (l_get_status_code_csr%FOUND) THEN
        p_x_unit_Effectivity_rec.STATUS_CODE := l_status_code;
      ELSE
        -- No match
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE l_get_status_code_csr;
    ELSE
      -- Insufficient information to retrieve status code
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  --

END Convert_Effectivity_Val_To_ID;

------------------------------------

PROCEDURE Convert_Threshold_Val_To_ID(
     p_x_unit_threshold_rec IN OUT  NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_Rec_Type,
     x_return_status        OUT     NOCOPY VARCHAR2 ) IS

  CURSOR l_get_counter_id(p_counter_name IN VARCHAR2,
                          p_ue_id        IN NUMBER) IS
    /*SELECT co.counter_id
    FROM csi_cp_counters_v co, ahl_unit_effectivities_app_v ue
    WHERE co.COUNTER_NAME = p_counter_name AND
    ue.UNIT_EFFECTIVITY_ID = p_ue_id AND
    ue.csi_item_instance_id = CUSTOMER_PRODUCT_ID;*/

    --performace tuning related change

    /*SELECT c.counter_id
    FROM CS_COUNTERS C, CS_COUNTER_GROUPS CTRGRP, CSI_ITEM_INSTANCES CII, MTL_SYSTEM_ITEMS_KFV MSITEM, ahl_unit_effectivities_app_v ue
    WHERE C.COUNTER_GROUP_ID(+) = CTRGRP.COUNTER_GROUP_ID
    AND CTRGRP.SOURCE_OBJECT_CODE = 'CP'
    AND CTRGRP.SOURCE_OBJECT_ID = CII.INSTANCE_ID
    AND MSITEM.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
    AND MSITEM.ORGANIZATION_ID = CII.INV_MASTER_ORGANIZATION_ID
    AND ue.csi_item_instance_id = CII.INSTANCE_ID
    AND c.NAME = p_counter_name
    AND ue.UNIT_EFFECTIVITY_ID = p_ue_id;*/

	--Priyan
	--Query changes due to performance related issues
	--Refer Bug # 4918732

	select
		cc.counter_id
	from
		csi_counters_vl cc,
        csi_counter_associations cca,
        ahl_unit_effectivities_b ue
	where
			cc.counter_id (+)       = cca.counter_id
		and cca.source_object_code = 'CP'
		and cca.source_object_id   = ue.csi_item_instance_id
		and cc.name                = p_counter_name
		--and cc.counter_template_name = p_counter_name
		and ue.unit_effectivity_id = p_ue_id;

  l_counter_id  NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Resolve Counter_ID
  IF (p_x_unit_threshold_rec.counter_id IS NULL) OR (p_x_unit_threshold_rec.counter_id =  FND_API.G_MISS_NUM) THEN
    IF ((p_x_unit_threshold_rec.counter_name IS NOT NULL AND p_x_unit_threshold_rec.counter_name <> FND_API.G_MISS_CHAR) AND
        (p_x_unit_threshold_rec.unit_effectivity_id IS NOT NULL AND p_x_unit_threshold_rec.unit_effectivity_id <> FND_API.G_MISS_NUM))THEN
      OPEN l_get_counter_id(p_x_unit_threshold_rec.counter_name, p_x_unit_threshold_rec.unit_effectivity_id);
      FETCH l_get_counter_id INTO l_counter_id;
      IF (l_get_counter_id%FOUND) THEN
        p_x_unit_threshold_rec.counter_id := l_counter_id;
      ELSE
        -- No match
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE l_get_counter_id;
    ELSE
      -- Insufficient information to retrieve counter_id
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Convert_Threshold_Val_To_ID;

------------------------------------

PROCEDURE Convert_Accomplish_Val_To_ID(
     p_x_unit_accomplish_rec IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2 ) IS

    CURSOR l_get_counter_id(p_counter_name IN VARCHAR2,
                          p_ue_id        IN NUMBER) IS
    /*SELECT co.counter_id
    FROM csi_cp_counters_v co, ahl_unit_effectivities_app_v ue
    WHERE co.COUNTER_NAME = p_counter_name AND
    ue.UNIT_EFFECTIVITY_ID = p_ue_id AND
    ue.csi_item_instance_id = CUSTOMER_PRODUCT_ID;*/

    --performace tuning related change
    /*
    SELECT c.counter_id
    FROM CS_COUNTERS C, CS_COUNTER_GROUPS CTRGRP, CSI_ITEM_INSTANCES CII, MTL_SYSTEM_ITEMS_KFV MSITEM, ahl_unit_effectivities_app_v ue
    WHERE C.COUNTER_GROUP_ID(+) = CTRGRP.COUNTER_GROUP_ID
    AND CTRGRP.SOURCE_OBJECT_CODE = 'CP'
    AND CTRGRP.SOURCE_OBJECT_ID = CII.INSTANCE_ID
    AND MSITEM.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
    AND MSITEM.ORGANIZATION_ID = CII.INV_MASTER_ORGANIZATION_ID
    AND ue.csi_item_instance_id = CII.INSTANCE_ID
    AND c.NAME = p_counter_name
    AND ue.UNIT_EFFECTIVITY_ID = p_ue_id; */

    select
        cc.counter_id
    from
        csi_counters_vl cc,
        csi_counter_associations cca,
        ahl_unit_effectivities_b ue
    where
        cc.counter_id (+)       = cca.counter_id
        and cca.source_object_code = 'CP'
        and cca.source_object_id   = ue.csi_item_instance_id
        and cc.name                = p_counter_name
        --and cc.counter_template_name = p_counter_name
        and ue.unit_effectivity_id = p_ue_id;

  l_counter_id  NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Resolve Counter_ID
  IF (p_x_unit_accomplish_rec.counter_id IS NULL) OR (p_x_unit_accomplish_rec.counter_id =  FND_API.G_MISS_NUM) THEN
    IF ((p_x_unit_accomplish_rec.counter_name IS NOT NULL AND p_x_unit_accomplish_rec.counter_name <> FND_API.G_MISS_CHAR) AND
        (p_x_unit_accomplish_rec.unit_effectivity_id IS NOT NULL AND p_x_unit_accomplish_rec.unit_effectivity_id <> FND_API.G_MISS_NUM))THEN
      OPEN l_get_counter_id(p_x_unit_accomplish_rec.counter_name, p_x_unit_accomplish_rec.unit_effectivity_id);
      FETCH l_get_counter_id INTO l_counter_id;
      IF (l_get_counter_id%FOUND) THEN
        p_x_unit_accomplish_rec.counter_id := l_counter_id;
      ELSE
        -- No match
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE l_get_counter_id;
    ELSE
      -- Insufficient information to retrieve counter_id
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Convert_Accomplish_Val_To_ID;

-----------------------------

PROCEDURE Validate_Effectivity
(
   p_unit_Effectivity_rec IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type,
   p_authorized_user_flag IN            VARCHAR2 := 'N',
   x_return_status        IN OUT NOCOPY VARCHAR2) IS

  CURSOR l_invalid_descendents_csr(p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM ahl_unit_effectivities_app_v
    WHERE (status_code not in ('INIT-ACCOMPLISHED', 'TERMINATED', 'MR-TERMINATE', 'ACCOMPLISHED','SR-CLOSED','DEFERRED','CANCELLED') OR status_code IS NULL)
    AND unit_effectivity_id in (
        SELECT related_ue_id
        FROM ahl_ue_relationships
        START WITH ue_id = p_ue_id
        AND relationship_code = 'PARENT'
        CONNECT BY ue_id = PRIOR related_ue_id
        AND relationship_code = 'PARENT');

  CURSOR l_prior_initializations_csr(p_mr_id IN NUMBER,
                                     p_item_instance_id IN NUMBER,
                                     p_ue_id IN NUMBER) IS
    SELECT status_code
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE MR_HEADER_ID = p_mr_id AND
    CSI_ITEM_INSTANCE_ID = p_item_instance_id AND
    status_code IN ('INIT-DUE', 'INIT-ACCOMPLISHED','DEFERRED') AND
    UNIT_EFFECTIVITY_ID <> p_ue_id;

  CURSOR l_ue_details_csr(p_ue_id IN NUMBER) IS
    SELECT STATUS_CODE, OBJECT_VERSION_NUMBER, MR_HEADER_ID,
           CSI_ITEM_INSTANCE_ID, PRECEDING_UE_ID,SERVICE_LINE_ID
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE UNIT_EFFECTIVITY_ID = p_ue_id;

  -- Added p_service_line_id as part of bugfix 6903768(FP for bug# 5764351).
  CURSOR l_prior_ue_csr(p_mr_id IN NUMBER,
                        p_item_instance_id IN NUMBER,
                        p_service_line_id  IN NUMBER) IS
    /*
    SELECT UNIT_EFFECTIVITY_ID
    FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE MR_HEADER_ID = p_mr_id AND
    CSI_ITEM_INSTANCE_ID = p_item_instance_id AND
    FORECAST_SEQUENCE = (SELECT MIN(FORECAST_SEQUENCE) FROM AHL_UNIT_EFFECTIVITIES_APP_V
                         WHERE MR_HEADER_ID = p_mr_id AND
                               CSI_ITEM_INSTANCE_ID = p_item_instance_id AND
                              (STATUS_CODE IS NULL OR
                               STATUS_CODE = 'INIT-DUE'))
    AND (STATUS_CODE IS NULL OR STATUS_CODE = 'INIT-DUE');
    */

    -- For preventive maintenance bug# 4692366, changing logic to base
    -- on min unit_effectivity_id as duplicate forecast seq can exist if
    -- contract numbers are different(renewal, modification cases).
    SELECT MIN(unit_effectivity_id)
    FROM AHL_UNIT_EFFECTIVITIES_VL
    WHERE MR_HEADER_ID = p_mr_id AND
          CSI_ITEM_INSTANCE_ID = p_item_instance_id AND
          service_line_id = p_service_line_id AND
          (STATUS_CODE IS NULL OR
           STATUS_CODE IN ('INIT-DUE'));

  CURSOR l_get_pred_details_csr(p_pred_ue_id IN NUMBER) IS
    SELECT MR_HEADER_ID, CSI_ITEM_INSTANCE_ID
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE UNIT_EFFECTIVITY_ID = p_pred_ue_id;

  CURSOR l_validate_status_csr(p_status_code IN VARCHAR2) IS
    SELECT 'x'
    FROM FND_LOOKUP_VALUES_VL
    WHERE LOOKUP_TYPE = 'AHL_UNIT_EFFECTIVITY_STATUS' AND
    LOOKUP_CODE IN ('ACCOMPLISHED','INIT-ACCOMPLISHED','INIT-DUE','CANCELLED') AND
    LOOKUP_CODE = p_status_code;

  -- Added for 11.5.10 enhancements.
  CURSOR l_qa_collection_csr(p_qa_collection_id IN NUMBER) IS
    SELECT collection_id
    FROM QA_RESULTS
    WHERE collection_id = p_qa_collection_id
      AND rownum < 2;

  -- validate deferral ID
  CURSOR l_unit_deferral_csr (p_unit_deferral_id IN NUMBER) IS
    SELECT 'x'
    FROM ahl_unit_deferrals_b
    WHERE unit_deferral_id = p_unit_deferral_id
      AND unit_deferral_type = 'INIT-DUE';

  -- For bug# 4172783.
  CURSOR l_ue_err_details_csr (p_ue_id IN NUMBER) IS
    SELECT CSI.instance_number, UE.due_date, MR.title
    FROM ahl_unit_effectivities_b UE, ahl_mr_headers_b MR,
         csi_item_instances CSI
    WHERE UE.unit_effectivity_id = p_ue_id
      AND UE.mr_header_id = MR.mr_header_id
      AND UE.csi_item_instance_id = CSI.instance_id;

  CURSOR l_servq_num_csr (p_ue_id IN NUMBER,  p_object_type IN VARCHAR2,
                          p_subject_type IN VARCHAR2, p_link_type_id IN NUMBER) IS
    SELECT CS.incident_number
    FROM cs_incident_links CLK, CS_INCIDENTS_ALL_B CS
    WHERE CS.incident_id = CLK.subject_id
      AND CLK.object_id = p_ue_id
      AND CLK.object_type = p_object_type
      AND CLK.subject_type = p_subject_type
      AND CLK.link_type_id = p_link_type_id;

  -- Added to validate if UE ID is a child UE.
  CURSOR l_child_mr_csr(p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UE_RELATIONSHIPS
    WHERE related_ue_id = p_ue_id;

   l_prev_status            VARCHAR2(30);
   l_prev_object_version_no NUMBER;
   l_item_instance_id       NUMBER;
   l_mr_id                  NUMBER;
   l_preceding_ue_id        NUMBER := null;
   l_last_accomplished_date DATE := null;
   l_junk                   VARCHAR2(1);
   l_temp_ue_id             NUMBER;
   l_pred_mr_id             NUMBER;
   l_pred_item_instance_id  NUMBER;
   l_last_ue_id             NUMBER := null;
   l_temp_status            BOOLEAN;
   l_temp_status_code       VARCHAR2(30);
   l_temp_deferral_flag     BOOLEAN;

   l_prior_ue_status        VARCHAR2(20);

   l_err_instance_number    CSI_ITEM_INSTANCES.instance_number%TYPE;
   l_err_due_date           DATE;
   l_err_title              ahl_mr_headers_b.title%TYPE;
   l_err_serreq_num         cs_incidents_all_b.incident_number%TYPE;
   l_service_line_id        ahl_unit_effectivities_b.service_line_id%TYPE;
   -- added to validate visit status.
   l_visit_status           VARCHAR2(100);

BEGIN
      -- DO NOT Initialize API return status to success

      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('Start of Validate Effectivity:' || p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID, 'UMP');
        AHL_DEBUG_PUB.debug('Start Validation Set1:' || x_return_status, 'UMP');
      END IF;

      -- Check if the unit effectivity id is not null
      IF (p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID IS NULL OR p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_ID_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Check if the status is valid
      --IF (p_unit_Effectivity_rec.STATUS_CODE IS NOT NULL AND p_unit_Effectivity_rec.STATUS_CODE <> FND_API.G_MISS_CHAR) THEN
        OPEN l_validate_status_csr(p_unit_Effectivity_rec.STATUS_CODE);
        FETCH l_validate_status_csr into l_junk;
        IF (l_validate_status_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_STATUS_INVALID');
          FND_MESSAGE.Set_Token('STATUS', p_unit_Effectivity_rec.STATUS_CODE);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE l_validate_status_csr;
      --END IF;

      -- If the status is INIT-ACCOMPLISHED or INIT-DUE, ensure that the user has permission
      IF ((p_unit_Effectivity_rec.STATUS_CODE = 'INIT-ACCOMPLISHED') OR (p_unit_Effectivity_rec.STATUS_CODE = 'INIT-DUE')) THEN
        IF (p_authorized_user_flag = 'N') THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_UNAUTHORIZED_USER');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          --RAISE USER_NOT_AUTHORIZED;
        END IF;

        -- validate that UE is not assigned to any visit.
        IF (p_unit_Effectivity_rec.STATUS_CODE = 'INIT-ACCOMPLISHED') THEN
          l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
          IF (l_visit_status IS NOT NULL) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_VISIT_ASSIGNED');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;

        -- validate that UE is not a child UE.
        OPEN l_child_mr_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
        FETCH l_child_mr_csr INTO l_junk;
        IF (l_child_mr_csr%FOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_CHILD_MR');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE l_child_mr_csr;

      END IF;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        -- Cannot proceed further
        RETURN;
      END IF;

      -- Retrieve current status, object version no. mr_id, item_instance id and
      -- preceding ue id for current ue
      OPEN l_ue_details_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
      FETCH l_ue_details_csr into
      l_prev_status, l_prev_object_version_no, l_mr_id, l_item_instance_id, l_preceding_ue_id,
      l_service_line_id;
      IF (l_ue_details_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_ID_INVALID');
        FND_MESSAGE.Set_Token('UEID',p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Cannot proceed further
        RETURN;
      END IF;
      CLOSE l_ue_details_csr;

      --Ensure that unit is not locked
      IF(AHL_UTIL_UC_PKG.IS_UNIT_QUARANTINED(p_unit_header_id => null, p_instance_id => l_item_instance_id) = FND_API.G_TRUE) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_INIT_UNIT_LOCKED');
          FND_MSG_PUB.ADD;
          RETURN; -- cannot proceed further
      END IF;

      -- Returning only after doing all of the following checks

      -- If object version no is different, write error message and skip to next unit effectivity
      IF(l_prev_object_version_no <> p_unit_Effectivity_rec.OBJECT_VERSION_NUMBER) THEN
--        FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_CHANGED');
        FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

-- 07/03/2002: Allow termination even if visit is in execution
--      -- Ensure that an in-progress MR is not terminated
--      IF(p_unit_Effectivity_rec.STATUS_CODE = 'TERMINATED') THEN
--        -- Call VWP API to ensure that this is not assigned to a visit
--        -- and if the visit is not in progress
--        IF(AHL_UMP_UTIL_PKG.Is_UE_In_Execution(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID) = TRUE) THEN
--          FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_IN_EXEC');
--          FND_MSG_PUB.ADD;
--          x_return_status := FND_API.G_RET_STS_ERROR;
--        END IF;
--      END IF;

      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('p_unit_Effectivity_rec.STATUS_CODE:' || p_unit_Effectivity_rec.STATUS_CODE, 'UMP');
        AHL_DEBUG_PUB.debug('p_unit_Effectivity_rec.SET_DUE_DATE:' || p_unit_Effectivity_rec.SET_DUE_DATE, 'UMP');
        AHL_DEBUG_PUB.debug('p_unit_Effectivity_rec.ACCOMPLISHED_DATE:' || p_unit_Effectivity_rec.ACCOMPLISHED_DATE, 'UMP');
      END IF;

      -- Both the dates (due and accomplished) should not be set. Only one should be set.
      IF (p_unit_Effectivity_rec.STATUS_CODE IS NOT NULL) THEN
        IF ((p_unit_Effectivity_rec.SET_DUE_DATE IS NOT NULL AND p_unit_Effectivity_rec.SET_DUE_DATE <> FND_API.G_MISS_DATE) AND
            (p_unit_Effectivity_rec.ACCOMPLISHED_DATE IS NOT NULL AND p_unit_Effectivity_rec.ACCOMPLISHED_DATE <> FND_API.G_MISS_DATE)) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_BOTH_DATES_SET');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- If the status is INIT-ACCOMPLISHED, or ACCOMPLISHED, ensure that the accomplished date is set
      IF ((p_unit_Effectivity_rec.STATUS_CODE = 'INIT-ACCOMPLISHED') OR
          (p_unit_Effectivity_rec.STATUS_CODE = 'ACCOMPLISHED')) THEN
        -- validate ACCOMPLISHED_DATE = G_MISS_DATE for INIT-ACCOMPLISHED later in update_unit_effectivity proc.
        IF (p_unit_Effectivity_rec.ACCOMPLISHED_DATE IS NULL OR (p_unit_Effectivity_rec.ACCOMPLISHED_DATE = FND_API.G_MISS_DATE AND p_unit_Effectivity_rec.STATUS_CODE = 'ACCOMPLISHED')) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSHD_DATE_NULL');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF (p_unit_Effectivity_rec.ACCOMPLISHED_DATE <> FND_API.G_MISS_DATE
               AND p_unit_Effectivity_rec.ACCOMPLISHED_DATE > sysdate) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACC_DATE_IN_FUTR');
          FND_MESSAGE.Set_Token('ACCDATE',p_unit_Effectivity_rec.ACCOMPLISHED_DATE);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        -- If this is a group MR, ensure that all descendents are accomplished
        /*
        OPEN l_invalid_descendents_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
        FETCH l_invalid_descendents_csr INTO l_junk;
        IF (l_invalid_descendents_csr%FOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_CHILD_UNACCMPLSHD');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE l_invalid_descendents_csr;
        */
      END IF;

      -- Ensure that the previous status of the current effectivity is not MR-TERMINATE, DEFERRED or SR-CLOSED or CANCELLED.
      -- Allow updates to UE in status ACCOMPLISHED and TERMINATED. Only Counter values can be updated for this case.
      IF ((l_prev_status = 'MR-TERMINATE') OR (l_prev_status = 'DEFERRED') OR
          (l_prev_status = 'SR-CLOSED') OR (l_prev_status = 'CANCELLED') ) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_INVALID_STTS_CHNG');
        FND_MESSAGE.Set_Token('FROM_STATUS', l_prev_status);
        FND_MESSAGE.Set_Token('TO_STATUS', p_unit_Effectivity_rec.STATUS_CODE);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- If initializing, ensure that there are no prior initializations or accomplishments
      IF ((p_unit_Effectivity_rec.STATUS_CODE = 'INIT-ACCOMPLISHED') OR (p_unit_Effectivity_rec.STATUS_CODE = 'INIT-DUE')) THEN
        -- Ensure that there are no prior accomplishments
        AHL_UMP_UTIL_PKG.get_last_accomplishment(l_item_instance_id, l_mr_id, l_last_accomplished_date, l_last_ue_id, l_temp_deferral_flag, l_temp_status_code, l_temp_status);
        IF (l_temp_status = FALSE) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_temp_status_code <> 'INIT-ACCOMPLISHED' and l_last_accomplished_date IS NOT null) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ALRDY_ACCMPLSHD');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        -- Ensure that there are no prior initializations
        OPEN l_prior_initializations_csr(l_mr_id, l_item_instance_id, p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
        FETCH l_prior_initializations_csr INTO l_prior_ue_status;
        IF (l_prior_initializations_csr%FOUND) THEN
          IF (l_prior_ue_status = 'DEFERRED') THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_ALRDY_DEFERRED');
            FND_MSG_PUB.ADD;
          ELSE
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_ALRDY_INITLZD');
            FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE l_prior_initializations_csr;
      END IF;

      -- If accomplishing or terminating, ensure that the most recent accomplishment
      -- of this MR for this instance has an accomplishment date before the
      -- currently set accomplishment date
      -- Check for l_mr_id not null for Service Request accomplishment.
      IF ((p_unit_Effectivity_rec.STATUS_CODE = 'ACCOMPLISHED' OR p_unit_Effectivity_rec.STATUS_CODE = 'TERMINATED') AND l_mr_id IS NOT NULL) THEN
        AHL_UMP_UTIL_PKG.get_last_accomplishment(l_item_instance_id, l_mr_id, l_last_accomplished_date, l_last_ue_id, l_temp_deferral_flag, l_temp_status_code, l_temp_status);
        IF (l_temp_status = FALSE) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (AHL_UTIL_PKG.IS_PM_INSTALLED = 'Y') THEN
          IF (p_unit_Effectivity_rec.ACCOMPLISHED_DATE < l_last_accomplished_date) THEN
            -- Get service request number.
            OPEN l_servq_num_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
                                 'AHL_UMP_EFF','SR',6);
            FETCH l_servq_num_csr INTO l_err_serreq_num;
            CLOSE l_servq_num_csr;

            FND_MESSAGE.Set_Name('AHL','AHL_UMP_LTR_ACCMPLSH_EXSTS');
            FND_MESSAGE.Set_Token('UEID', p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
            FND_MESSAGE.Set_Token('NEW_ACC_DATE',to_char(p_unit_Effectivity_rec.ACCOMPLISHED_DATE,fnd_date.outputDT_mask));
            FND_MESSAGE.Set_Token('ACC_DATE',to_char(l_last_accomplished_date,fnd_date.outputDT_mask));
            FND_MESSAGE.Set_Token('SERVQ_NUM',l_err_serreq_num);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;

      -- Enable this validation for PM only as the execution sequence needs to be retained
      -- for cases where schedule is defined in Contracts. We use the due date to get the next
      -- set of open records.

      -- If TERMINATING or ACCOMPLISHING, ensure that this is the earliest
      -- effectivity (nothing outstanding) for the given MR
      IF (AHL_UTIL_PKG.IS_PM_INSTALLED = 'Y') THEN
        IF ((p_unit_Effectivity_rec.STATUS_CODE = 'TERMINATED') OR
            (p_unit_Effectivity_rec.STATUS_CODE = 'ACCOMPLISHED')) THEN
          OPEN l_prior_ue_csr(l_mr_id, l_item_instance_id,l_service_line_id);
          FETCH l_prior_ue_csr INTO l_temp_ue_id;
          IF (l_prior_ue_csr%FOUND) THEN
            IF (l_temp_ue_id <> p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID) THEN
              -- get full details for error message. For bug# 4172783.
              OPEN l_ue_err_details_csr(l_temp_ue_id);
              FETCH l_ue_err_details_csr INTO l_err_instance_number, l_err_due_date,
                                              l_err_title;
              CLOSE l_ue_err_details_csr;

              -- Get service request number.
              OPEN l_servq_num_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
                                   'AHL_UMP_EFF','SR',6);
              FETCH l_servq_num_csr INTO l_err_serreq_num;
              CLOSE l_servq_num_csr;

              FND_MESSAGE.Set_Name('AHL','AHL_UMP_ERLR_EFF_EXISTS');
              FND_MESSAGE.Set_Token('INST', l_err_instance_number);
              FND_MESSAGE.Set_Token('BEF_UEID', l_temp_ue_id);
              FND_MESSAGE.Set_Token('UEID',p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
              FND_MESSAGE.Set_Token('DUEDATE',l_err_due_date);
              FND_MESSAGE.Set_Token('TITLE',l_err_title);
              FND_MESSAGE.Set_Token('SERVQ_NUM',l_err_serreq_num);
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
          CLOSE l_prior_ue_csr;
        END IF;
      END IF;

      -- If INIT-ACCOMPLISHED, ensure that the predecessor (if any)
      -- has at least one accomplishment
      IF (p_unit_Effectivity_rec.STATUS_CODE IN ('INIT-ACCOMPLISHED','ACCOMPLISHED','TERMINATED')
           AND (l_preceding_ue_id IS NOT NULL)) THEN
        -- Get the item instance id and the mr_id for the preceding ue
        OPEN l_get_pred_details_csr(l_preceding_ue_id);
        FETCH l_get_pred_details_csr INTO l_pred_mr_id, l_pred_item_instance_id;
        IF (l_get_pred_details_csr%FOUND) THEN
          AHL_UMP_UTIL_PKG.get_last_accomplishment(l_pred_item_instance_id, l_pred_mr_id, l_last_accomplished_date, l_last_ue_id, l_temp_deferral_flag, l_temp_status_code, l_temp_status);
          IF (l_temp_status = FALSE) THEN
            CLOSE l_get_pred_details_csr;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          IF (l_last_accomplished_date IS NULL) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_PRED_NOT_ACCMPLSHD');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
        CLOSE l_get_pred_details_csr;
      END IF;

      -- If terminating, ensure that the Accomplished Date if given, is in the past
      IF (p_unit_Effectivity_rec.STATUS_CODE = 'TERMINATED' OR p_unit_Effectivity_rec.STATUS_CODE = 'MR-TERMINATE') THEN
        IF (p_unit_Effectivity_rec.ACCOMPLISHED_DATE IS NOT NULL AND p_unit_Effectivity_rec.ACCOMPLISHED_DATE <> FND_API.G_MISS_DATE) THEN
          IF (TRUNC(p_unit_Effectivity_rec.ACCOMPLISHED_DATE) > TRUNC(sysdate)) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACC_DATE_IN_FUTR');
            FND_MESSAGE.Set_Token('ACCDATE', p_unit_Effectivity_rec.ACCOMPLISHED_DATE);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;

      -- If INIT-DUE, ensure that the Set Due Date if given, is in the future
      IF (p_unit_Effectivity_rec.STATUS_CODE = 'INIT-DUE') THEN
        IF (p_unit_Effectivity_rec.SET_DUE_DATE IS NOT NULL AND p_unit_Effectivity_rec.SET_DUE_DATE <> FND_API.G_MISS_DATE) THEN
          IF (TRUNC(p_unit_Effectivity_rec.SET_DUE_DATE) < TRUNC(sysdate)) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_DUE_DATE_IN_PAST');
            FND_MESSAGE.Set_Token('DUEDATE', p_unit_Effectivity_rec.SET_DUE_DATE);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;

      -- Validate CollectionID if present.
      IF (p_unit_Effectivity_rec.qa_collection_id IS NOT NULL) AND
         (p_unit_Effectivity_rec.qa_collection_id <> FND_API.G_MISS_NUM) THEN
         OPEN l_qa_collection_csr  (p_unit_Effectivity_rec.qa_collection_id);
         IF l_qa_collection_csr%NOTFOUND THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_QA_COLLECTION_INVALID');
            FND_MESSAGE.Set_Token('COLLECT_ID', p_unit_Effectivity_rec.qa_collection_id);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         CLOSE l_qa_collection_csr;

         -- This validation already done above.
         -- Validate the current UE status is not ACCOMPLISHED.
         IF (l_prev_status = 'ACCOMPLISHED' OR l_prev_status = 'TERMINATED' OR
             l_prev_status = 'DEFERRED' OR l_prev_status = 'INIT-ACCOMPLISHED' OR
             l_prev_status = 'SR-CLOSED' OR l_prev_status = 'CANCELLED') THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_INVALID_STTS_CHNG');
            FND_MESSAGE.Set_Token('FROM_STATUS', l_prev_status);
            FND_MESSAGE.Set_Token('TO_STATUS', p_unit_Effectivity_rec.STATUS_CODE);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

      END IF;

      -- Validate Deferral ID if present.
      IF (p_unit_Effectivity_rec.unit_deferral_id IS NOT NULL) AND
         (p_unit_Effectivity_rec.unit_deferral_ID <> FND_API.G_MISS_NUM) THEN
         OPEN l_unit_deferral_csr (p_unit_Effectivity_rec.unit_deferral_id);
         FETCH l_unit_deferral_csr INTO l_junk;
         IF (l_unit_deferral_csr%NOTFOUND) THEN
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_DEFERRAL_INVALID');
           FND_MESSAGE.Set_Token('DEFERRAL_ID', p_unit_Effectivity_rec.unit_deferral_id);
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

      END IF;

END Validate_Effectivity;
------------------------------------

PROCEDURE Validate_Thresholds
(
   p_unit_threshold_tbl   IN OUT  NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
   x_return_status        IN OUT  NOCOPY VARCHAR2) IS

  CURSOR l_validate_counter_csr(p_ue_id      IN NUMBER,
                                p_counter_id IN NUMBER) IS
    /*
    SELECT NVL(net_reading, 0)
    FROM  CSI_CP_COUNTERS_V CO, AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE co.customer_product_id = ue.csi_item_instance_id and
          ue.unit_effectivity_id = p_ue_id and
          co.counter_id = p_counter_id;
    */

    /*
    SELECT NVL(net_reading, 0)
    FROM csi_counter_values_v cv, csi_counter_associations cca, AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE cca.source_object_code = 'CP'
      AND cca.source_object_id = ue.csi_item_instance_id
      AND cca.counter_id = cv.counter_id
      AND ue.unit_effectivity_id = p_ue_id
      AND cv.counter_id = p_counter_id
      ORDER BY cv.value_timestamp desc;
    */
    -- Added for R12 IB Uptake. If counter does not have any reading,
    -- csi_counter_values_v does not retrieve any row.
    -- split above cursor into 2 cursors.
    SELECT 'x'
    FROM CSI_COUNTERS_VL CC, csi_counter_associations cca, AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE cca.source_object_code = 'CP'
      AND cca.source_object_id = ue.csi_item_instance_id
      AND cca.counter_id = cc.counter_id
      AND ue.unit_effectivity_id = p_ue_id
      AND cc.counter_id = p_counter_id;

    -- Added for R12 bug# 6080133.
    CURSOR get_ctr_reading_csr(p_counter_id IN NUMBER) IS
    SELECT NVL(CCR.net_reading, 0)
    FROM
      CSI_COUNTERS_VL CC,
      CSI_COUNTER_READINGS CCR
    WHERE
      CCR.COUNTER_ID = CC.COUNTER_ID
      AND nvl(CCR.disabled_flag,'N') = 'N'
      AND CC.COUNTER_ID = p_counter_id
    ORDER BY
      CCR.VALUE_TIMESTAMP DESC;

  CURSOR l_get_prev_ctr_csr(p_threshold_id IN NUMBER) IS
    SELECT OBJECT_VERSION_NUMBER, COUNTER_ID
    FROM  AHL_UNIT_THRESHOLDS
    WHERE UNIT_THRESHOLD_ID = p_threshold_id;

  CURSOR l_ue_id_check_csr(p_threshold_id IN NUMBER, p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UNIT_THRESHOLDS UTH, AHL_UNIT_DEFERRALS_B UDF
    WHERE UTH.unit_deferral_id = UDF.unit_deferral_ID AND
          UTH.UNIT_THRESHOLD_ID = p_threshold_id AND
          UDF.UNIT_EFFECTIVITY_ID = p_ue_id AND
          UDF.Unit_deferral_type = 'INIT-DUE';

   l_prev_object_version_no NUMBER;
   l_prev_counter           NUMBER;
   l_net_reading            NUMBER;
   l_return_status          VARCHAR2(30);
   l_junk                   VARCHAR2(1);

BEGIN
  -- DO NOT Initialize API return status to success

  IF (p_unit_threshold_tbl.COUNT > 0) THEN

    FOR i IN p_unit_threshold_tbl.FIRST..p_unit_threshold_tbl.LAST LOOP

      -- Resolve Counter Id
      Convert_Threshold_Val_To_ID(p_unit_threshold_tbl(i), l_return_status);

      -- Ensure that for Modify or delete operation, the threshold id is present
      IF (p_unit_threshold_tbl(i).OPERATION_FLAG = 'M' OR p_unit_threshold_tbl(i).OPERATION_FLAG = 'D') THEN
        IF (p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID IS NULL OR p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_THRESHOLD_ID_NULL');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- Ensure that for Modify operation, the unit effectivity Id matches the threshold
      IF (p_unit_threshold_tbl(i).OPERATION_FLAG = 'M') THEN
        OPEN l_ue_id_check_csr(p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID,
                               p_unit_threshold_tbl(i).UNIT_EFFECTIVITY_ID);
        FETCH l_ue_id_check_csr INTO l_junk;
        IF (l_ue_id_check_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_ID_INVALID');
          FND_MESSAGE.Set_Token('UEID', p_unit_threshold_tbl(i).UNIT_EFFECTIVITY_ID);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE l_ue_id_check_csr;
      END IF;

      -- Ensure that the Counter ID is valid for a Create or Modify operation
      IF (p_unit_threshold_tbl(i).COUNTER_ID IS NULL OR p_unit_threshold_tbl(i).COUNTER_ID = FND_API.G_MISS_NUM) THEN
        IF (p_unit_threshold_tbl(i).OPERATION_FLAG = 'C' OR p_unit_threshold_tbl(i).OPERATION_FLAG = 'M') THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_COUNTER_INVALID');
          FND_MESSAGE.Set_Token('COUNTER', p_unit_threshold_tbl(i).COUNTER_NAME);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- Ensure that the counter is appropriate for the current item instance
      IF (p_unit_threshold_tbl(i).COUNTER_ID IS NOT NULL AND p_unit_threshold_tbl(i).COUNTER_ID <> FND_API.G_MISS_NUM) THEN
        OPEN l_validate_counter_csr(p_unit_threshold_tbl(i).UNIT_EFFECTIVITY_ID, p_unit_threshold_tbl(i).COUNTER_ID);
        FETCH l_validate_counter_csr INTO l_junk;
        IF (l_validate_counter_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_COUNTER_INVALID');
          FND_MESSAGE.Set_Token('COUNTER', p_unit_threshold_tbl(i).COUNTER_NAME);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          -- get counter reading.
          OPEN get_ctr_reading_csr(p_unit_threshold_tbl(i).COUNTER_ID);
          FETCH get_ctr_reading_csr INTO l_net_reading;
          IF (get_ctr_reading_csr%NOTFOUND) THEN
            l_net_reading := 0;
          END IF;
          CLOSE get_ctr_reading_csr;
        END IF;
        CLOSE l_validate_counter_csr;
      END IF;

      -- Ensure that the Threshold has not changed
      IF (p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID IS NOT NULL AND p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID <> FND_API.G_MISS_NUM) THEN
        -- Retrieve object version no. for this threshold
        OPEN l_get_prev_ctr_csr(p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID);
        FETCH l_get_prev_ctr_csr into l_prev_object_version_no, l_prev_counter;
        IF (l_get_prev_ctr_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_THRSHLD_ID_INVALID');
          FND_MESSAGE.Set_Token('THRESHOLDID', p_unit_threshold_tbl(i).UNIT_THRESHOLD_ID);
          FND_MSG_PUB.ADD;
          CLOSE l_get_prev_ctr_csr;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
        CLOSE l_get_prev_ctr_csr;
        -- Check if object version no is different
        IF(l_prev_object_version_no <> p_unit_threshold_tbl(i).OBJECT_VERSION_NUMBER) THEN
--          FND_MESSAGE.Set_Name('AHL','AHL_UMP_THRESHOLD_CHANGED');
--          FND_MESSAGE.Set_Token('COUNTER', p_unit_threshold_tbl(i).COUNTER_NAME);
          FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
        -- For modify operation, ensure that the counter (id) has not changed
        IF (p_unit_threshold_tbl(i).OPERATION_FLAG = 'M') THEN
          IF (p_unit_threshold_tbl(i).COUNTER_ID <> l_prev_counter) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_THR_COUNTER_CHANGED');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;

      -- Ensure that the counter value is valid
      IF (p_unit_threshold_tbl(i).OPERATION_FLAG = 'C' OR p_unit_threshold_tbl(i).OPERATION_FLAG = 'M') THEN
        IF (p_unit_threshold_tbl(i).COUNTER_VALUE IS NULL OR p_unit_threshold_tbl(i).COUNTER_VALUE = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_CNTR_VALUE_MISSING');
          FND_MESSAGE.Set_Token('COUNTER', p_unit_threshold_tbl(i).COUNTER_NAME);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          -- Ensure that the entered value is not lesser than the Net Reading
          IF (p_unit_threshold_tbl(i).COUNTER_VALUE < l_net_reading) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_CTR_VAL_LESSER');
            FND_MESSAGE.Set_Token('COUNTER', p_unit_threshold_tbl(i).COUNTER_NAME);
            FND_MESSAGE.Set_Token('ENTVAL', p_unit_threshold_tbl(i).COUNTER_VALUE);
            FND_MESSAGE.Set_Token('CURRVAL', l_net_reading);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;
    END LOOP;  -- All thresholds
  END IF;
END Validate_Thresholds;

------------------------------------

-- Added accomplishment date to fix bug# 6750836.
PROCEDURE Validate_Accomplishments
(
   p_unit_accomplish_tbl  IN OUT  NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
   p_accomplishment_date  IN             DATE,
   p_ue_status_code       IN             VARCHAR2,
   x_return_status        IN OUT  NOCOPY VARCHAR2) IS

  CURSOR l_validate_counter_csr(p_ue_id      IN NUMBER,
                                p_counter_id IN NUMBER) IS

    /*
    SELECT NVL(net_reading, 0)
    FROM  CSI_CP_COUNTERS_V CO, AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE co.customer_product_id = ue.csi_item_instance_id and
          ue.unit_effectivity_id = p_ue_id and
          co.counter_id = p_counter_id;
    */
    -- Added for R12 IB Uptake. If counter does not have any reading,
    -- csi_counter_values_v does not retrieve any row.
    -- split above cursor into 2 cursors.
    SELECT 'x'
    FROM CSI_COUNTERS_VL CC, csi_counter_associations cca, AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE cca.source_object_code = 'CP'
      AND cca.source_object_id = ue.csi_item_instance_id
      AND cca.counter_id = cc.counter_id
      AND ue.unit_effectivity_id = p_ue_id
      AND cc.counter_id = p_counter_id;

  -- Added for R12 bug# 6080133.
  CURSOR get_ctr_reading_csr(p_counter_id IN NUMBER,
                             p_accomplishment_date IN DATE) IS
    SELECT NVL(CCR.net_reading, 0)
    FROM
      CSI_COUNTERS_VL CC,
      CSI_COUNTER_READINGS CCR
    WHERE
      CCR.COUNTER_ID = CC.COUNTER_ID
      AND CC.COUNTER_ID = p_counter_id
      AND nvl(CCR.disabled_flag,'N') = 'N'
      AND CCR.VALUE_TIMESTAMP <= p_accomplishment_date
    ORDER BY
      CCR.VALUE_TIMESTAMP DESC;

  -- Added for R12 bug# 6080133.
  CURSOR get_max_ctr_reading_csr(p_counter_id IN NUMBER,
                                 p_accomplishment_date IN DATE) IS
    SELECT NVL(CCR.net_reading, 0), CCR.VALUE_TIMESTAMP
    FROM
      CSI_COUNTERS_VL CC,
      CSI_COUNTER_READINGS CCR
    WHERE
      CCR.COUNTER_ID = CC.COUNTER_ID
      AND CC.COUNTER_ID = p_counter_id
      AND nvl(CCR.disabled_flag,'N') = 'N'
      AND trunc(CCR.VALUE_TIMESTAMP) <= trunc(p_accomplishment_date)
    ORDER BY
      CCR.VALUE_TIMESTAMP DESC;

  -- Added for R12 bug# 7016783.
  CURSOR get_nxt_max_ctr_reading_csr(p_counter_id IN NUMBER,
                                     p_accomplishment_date IN DATE) IS
    SELECT NVL(CCR.net_reading, 0)
    FROM
      CSI_COUNTER_READINGS CCR
    WHERE
      CCR.COUNTER_ID = p_counter_id
      -- fix for bug# 7016783. pick next highest counter value.
      AND nvl(CCR.disabled_flag,'N') = 'N'
      AND trunc(CCR.VALUE_TIMESTAMP) > trunc(p_accomplishment_date)
    ORDER BY
      -- fix for bug# 7016783
      CCR.VALUE_TIMESTAMP ASC;

  CURSOR l_get_prev_ctr_csr(p_accomplishment_id IN NUMBER) IS
    SELECT OBJECT_VERSION_NUMBER, COUNTER_ID
    FROM  AHL_UNIT_ACCOMPLISHMNTS
    WHERE UNIT_ACCOMPLISHMNT_ID = p_accomplishment_id;

  CURSOR l_ue_id_check_csr(p_accomplishment_id IN NUMBER, p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UNIT_ACCOMPLISHMNTS
    WHERE UNIT_ACCOMPLISHMNT_ID = p_accomplishment_id AND
    UNIT_EFFECTIVITY_ID = p_ue_id;

   l_prev_object_version_no NUMBER;
   l_prev_counter           NUMBER;
   l_net_reading            NUMBER;
   l_return_status          VARCHAR2(30);
   l_junk                   VARCHAR2(1);

   -- added to fix bug# 9075500
   l_net_reading_more       NUMBER;
   l_net_reading_less       NUMBER;
   L_VALUE_TIMESTAMP        DATE;

BEGIN
  -- DO NOT Initialize API return status to success

  IF (p_unit_accomplish_tbl.COUNT > 0) THEN

    FOR i IN p_unit_accomplish_tbl.FIRST..p_unit_accomplish_tbl.LAST LOOP
      -- initialize
      l_net_reading_more := 0;
      l_net_reading_less := 0;
      L_VALUE_TIMESTAMP  := NULL;
      l_net_reading      := 0;

      -- Resolve Counter Id
      Convert_Accomplish_Val_To_ID(p_unit_accomplish_tbl(i), l_return_status);

      -- Ensure that for Modify or delete operation, the accomplishment id is present
      IF (p_unit_accomplish_tbl(i).OPERATION_FLAG = 'M' OR p_unit_accomplish_tbl(i).OPERATION_FLAG = 'D') THEN
        IF (p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID IS NULL OR p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCOMPLISH_ID_NULL');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- Ensure that for Modify operation, the UE Id matches the accomplishment
      IF (p_unit_accomplish_tbl(i).OPERATION_FLAG = 'M') THEN
        OPEN l_ue_id_check_csr(p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID,
                               p_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID);
        FETCH l_ue_id_check_csr INTO l_junk;
        IF (l_ue_id_check_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_ID_INVALID');
          FND_MESSAGE.Set_Token('UEID', p_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE l_ue_id_check_csr;
      END IF;

      -- Ensure that the Counter ID is valid for a Create or Modify operation
      IF (p_unit_accomplish_tbl(i).COUNTER_ID IS NULL OR p_unit_accomplish_tbl(i).COUNTER_ID = FND_API.G_MISS_NUM) THEN
        IF (p_unit_accomplish_tbl(i).OPERATION_FLAG = 'C' OR p_unit_accomplish_tbl(i).OPERATION_FLAG = 'M') THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_COUNTER_INVALID');
          FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- Ensure that the counter is appropriate for the current item instance
      IF (p_unit_accomplish_tbl(i).COUNTER_ID IS NOT NULL AND p_unit_accomplish_tbl(i).COUNTER_ID <> FND_API.G_MISS_NUM) THEN
        -- Add check for accomplishment date - need in the case of init-accomplishment update when the
        -- user passes G MISS date or NULL. We bypass date validation in validate_effectivity
        -- to allow for init-accomplishment deletion along with counter values; so there is a
        -- possibility for accomplishment date to be null or g-miss date.
        IF (p_accomplishment_date IS NULL OR p_accomplishment_date = FND_API.G_MISS_DATE)
        THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSHD_DATE_NULL');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
        -- Modified for IB uptake of R12 schema. Split original cursor into 2 cursors.
        OPEN l_validate_counter_csr(p_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID,
                                    p_unit_accomplish_tbl(i).COUNTER_ID);
        FETCH l_validate_counter_csr INTO l_junk;
        IF (l_validate_counter_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_COUNTER_INVALID');
          FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          IF (p_ue_status_code = 'INIT-ACCOMPLISHED') THEN
            -- 11/03/09: modified validations to fix bug# 9075500
            -- get max counter reading.
            -- Added accomplishment date to fix bug# 6750836.
            OPEN get_max_ctr_reading_csr(p_unit_accomplish_tbl(i).COUNTER_ID, p_accomplishment_date);
            FETCH get_max_ctr_reading_csr INTO l_net_reading_less, l_value_timestamp;
            IF (get_max_ctr_reading_csr%FOUND AND trunc(l_value_timestamp) = trunc(p_accomplishment_date)) THEN
              -- counter reading available in accomplishment date
              l_net_reading := l_net_reading_less;
            ELSE
              -- added to fix bug# 7016783.
              OPEN get_nxt_max_ctr_reading_csr(p_unit_accomplish_tbl(i).COUNTER_ID, p_accomplishment_date);
              FETCH get_nxt_max_ctr_reading_csr INTO l_net_reading_more;
              IF ((get_nxt_max_ctr_reading_csr%NOTFOUND) AND (get_max_ctr_reading_csr%NOTFOUND)) THEN
                -- no counter readings available in the system
                l_net_reading := 0;
              ELSIF ((get_nxt_max_ctr_reading_csr%NOTFOUND) AND (get_max_ctr_reading_csr%FOUND)) THEN
                l_net_reading := l_net_reading_less;
                IF (p_unit_accomplish_tbl(i).COUNTER_VALUE < l_net_reading_less) THEN
                  FND_MESSAGE.Set_Name('AHL','AHL_UMP_CTR_VAL_LESS');
                  FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
                  FND_MESSAGE.Set_Token('ENTVAL', p_unit_accomplish_tbl(i).COUNTER_VALUE);
                  FND_MESSAGE.Set_Token('CURRVAL', l_net_reading_less);
                  FND_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
              ELSIF ((get_nxt_max_ctr_reading_csr%FOUND) AND (get_max_ctr_reading_csr%NOTFOUND)) THEN
                -- no counter reading before and on accomplishment date
                l_net_reading := l_net_reading_more;
              ELSIF ((get_nxt_max_ctr_reading_csr%FOUND) AND (get_max_ctr_reading_csr%FOUND)) THEN
                l_net_reading := l_net_reading_more; -- used later for validation with counter value.
                -- counter reading before and after accomplishment date available.
                -- but no reading on accomplishment date itself.
                IF (p_unit_accomplish_tbl(i).COUNTER_VALUE < l_net_reading_less) THEN
                  FND_MESSAGE.Set_Name('AHL','AHL_UMP_CTR_VAL_LESS');
                  FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
                  FND_MESSAGE.Set_Token('ENTVAL', p_unit_accomplish_tbl(i).COUNTER_VALUE);
                  FND_MESSAGE.Set_Token('CURRVAL', l_net_reading_less);
                  FND_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
              END IF;
              CLOSE get_nxt_max_ctr_reading_csr;
            END IF;
            CLOSE get_max_ctr_reading_csr;
          ELSE -- status code <> 'INIT-ACCOMPLISHED'
            -- get counter reading.
            -- Added accomplishment date to fix bug# 6750836.
            OPEN get_ctr_reading_csr(p_unit_accomplish_tbl(i).COUNTER_ID, p_accomplishment_date);
            FETCH get_ctr_reading_csr INTO l_net_reading;
            IF (get_ctr_reading_csr%NOTFOUND) THEN
              l_net_reading := 0;
            END IF;
            CLOSE get_ctr_reading_csr;
          END IF;
        END IF;
        CLOSE l_validate_counter_csr;
      END IF;

      -- Ensure that the Accomplishment has not changed
      IF (p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID IS NOT NULL AND p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID <> FND_API.G_MISS_NUM) THEN
        -- Retrieve object version no. for this accomplishment
        OPEN l_get_prev_ctr_csr(p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID);
        FETCH l_get_prev_ctr_csr into l_prev_object_version_no, l_prev_counter;
        IF (l_get_prev_ctr_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSH_ID_INVALID');
          FND_MESSAGE.Set_Token('ACCOMPLISHMENTID', p_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID);
          FND_MSG_PUB.ADD;
          CLOSE l_get_prev_ctr_csr;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
        CLOSE l_get_prev_ctr_csr;
        -- Check if object version no is different
        IF(l_prev_object_version_no <> p_unit_accomplish_tbl(i).OBJECT_VERSION_NUMBER) THEN
--          FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSHMNT_CHANGED');
--          FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
          FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
        -- For modify operation, ensure that the counter (id) has not changed
        IF (p_unit_accomplish_tbl(i).OPERATION_FLAG = 'M') THEN
          IF (p_unit_accomplish_tbl(i).COUNTER_ID <> l_prev_counter) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACC_COUNTER_CHANGED');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;

      -- Ensure that the counter value is valid
      IF (p_unit_accomplish_tbl(i).OPERATION_FLAG = 'C' OR p_unit_accomplish_tbl(i).OPERATION_FLAG = 'M') THEN
        IF (p_unit_accomplish_tbl(i).COUNTER_VALUE IS NULL OR p_unit_accomplish_tbl(i).COUNTER_VALUE = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_CNTR_VALUE_MISSING');
          FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          -- Ensure that the entered value is not greater than the Net Reading
          IF (p_unit_accomplish_tbl(i).COUNTER_VALUE > l_net_reading) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_CTR_VAL_GREATER');
            FND_MESSAGE.Set_Token('COUNTER', p_unit_accomplish_tbl(i).COUNTER_NAME);
            FND_MESSAGE.Set_Token('ENTVAL', p_unit_accomplish_tbl(i).COUNTER_VALUE);
            FND_MESSAGE.Set_Token('CURRVAL', l_net_reading);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
      END IF;

    END LOOP; -- All Accomplishments
  END IF;
END Validate_Accomplishments;

------------------------------------
-- This procedure updates an Unit Effectivity
-- It also ensures that if there are no counters during
-- initialization, then the date is set
------------------------------------

PROCEDURE Update_Unit_Effectivity
(
   p_unit_Effectivity_rec IN AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type) IS

  CURSOR l_threshold_exists_csr(p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UNIT_THRESHOLDS UTH, AHL_UNIT_DEFERRALS_B UDF
    WHERE UTH.unit_deferral_id = UDF.unit_deferral_id
       AND UDF.unit_deferral_type = 'INIT-DUE'
       AND UDF.unit_effectivity_id = p_ue_id;

  CURSOR l_accomplish_exists_csr(p_ue_id IN NUMBER) IS
    SELECT 'x'
    FROM  AHL_UNIT_ACCOMPLISHMNTS
    WHERE unit_effectivity_id = p_ue_id;

  CURSOR l_get_unit_effectivity_csr(p_ue_id IN NUMBER) IS
    SELECT
      OBJECT_VERSION_NUMBER,
      CSI_ITEM_INSTANCE_ID,
      MR_INTERVAL_ID,
      MR_EFFECTIVITY_ID,
      MR_HEADER_ID,
      STATUS_CODE,
      DUE_DATE,
      ACCOMPLISHED_DATE,
      SET_DUE_DATE,
      DUE_COUNTER_VALUE,
      FORECAST_SEQUENCE,
      REPETITIVE_MR_FLAG,
      TOLERANCE_FLAG,
      DATE_RUN,
      PRECEDING_UE_ID,
      MESSAGE_CODE,
      REMARKS,
      SERVICE_LINE_ID,
      PROGRAM_MR_HEADER_ID,
      CANCEL_REASON_CODE,
      EARLIEST_DUE_DATE,
      LATEST_DUE_DATE,
      DEFER_FROM_UE_ID,
      CS_INCIDENT_ID,
      QA_COLLECTION_ID,
      ORIG_DEFERRAL_UE_ID,
      APPLICATION_USG_CODE,
      OBJECT_TYPE,
      COUNTER_ID,
      MANUALLY_PLANNED_FLAG,
      LOG_SERIES_CODE,
      LOG_SERIES_NUMBER,
      FLIGHT_NUMBER,
      MEL_CDL_TYPE_CODE,
      POSITION_PATH_ID,
      ATA_CODE,
      UNIT_CONFIG_HEADER_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE unit_effectivity_id = p_ue_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR l_get_descendents(p_ue_id IN NUMBER) IS
        SELECT related_ue_id
        FROM ahl_ue_relationships
        START WITH ue_id = p_ue_id
        AND relationship_code = 'PARENT'
        CONNECT BY ue_id = PRIOR related_ue_id
        AND relationship_code = 'PARENT';

    CURSOR l_get_accomplishments(p_ue_id IN NUMBER) IS
        SELECT UNIT_ACCOMPLISHMNT_ID
        FROM ahl_unit_accomplishmnts
        WHERE UNIT_EFFECTIVITY_ID = p_ue_id;

    CURSOR l_get_thresholds(p_ue_id IN NUMBER) IS
        SELECT UNIT_THRESHOLD_ID
        FROM ahl_unit_thresholds
        WHERE UNIT_DEFERRAL_ID = p_ue_id;

    CURSOR ahl_unit_def_csr(p_ue_id IN NUMBER) IS
        SELECT unit_deferral_id,
               ata_sequence_id,
               object_version_number,
               unit_deferral_type,
               approval_status_code,
               defer_reason_code,
               skip_mr_flag,
               affect_due_calc_flag,
               set_due_date,
               deferral_effective_on,
               remarks,approver_notes,attribute_category, attribute1,
               attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
               attribute8, attribute9, attribute10, attribute11, attribute12,
               attribute13, attribute14, attribute15
        FROM ahl_unit_deferrals_vl
        WHERE unit_effectivity_id = p_ue_id
         AND UNIT_DEFERRAL_TYPE = 'INIT-DUE'
        FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

   l_ue_rec                 l_get_unit_effectivity_csr%rowtype;

   l_descendent_ue_id       NUMBER;
   l_status_code            VARCHAR2(30);
   l_accomplished_date      DATE;
   l_set_due_date           DATE;
   l_junk                   VARCHAR2(1);
   l_date_missing_flag      boolean := false;
   l_accomplishment_id      NUMBER;
   l_threshold_id           NUMBER;
   l_return_status          VARCHAR2(32);
   l_counters_msg           VARCHAR2(1000);

   -- Added for 11.5.10.
   l_unit_deferral_operation VARCHAR2(1) := 'X';
   l_unit_deferral_id        NUMBER;
   l_unit_def_rec            ahl_unit_def_csr%ROWTYPE;
   l_rowid                   VARCHAR2(30);


BEGIN
  l_status_code := p_unit_Effectivity_rec.status_code;
  l_accomplished_date := p_unit_Effectivity_rec.ACCOMPLISHED_DATE;
  l_set_due_date := p_unit_Effectivity_rec.SET_DUE_DATE;

  -- Get current state
  OPEN l_get_unit_effectivity_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
  FETCH l_get_unit_effectivity_csr INTO l_ue_rec;
  CLOSE l_get_unit_effectivity_csr;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('In Update_Unit_Effectivity', 'UMP');
    AHL_DEBUG_PUB.debug('Unit Eff ID:' || p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID, 'UMP');
    AHL_DEBUG_PUB.debug('l_status_code:' || l_status_code, 'UMP');
    AHL_DEBUG_PUB.debug('l_ue_rec.status_code:' || l_ue_rec.status_code, 'UMP');

  END IF;

  -- If there are no accomplishments during initialization, reset status to null
  -- If the accomplishment date is not set during termination, set it to sysdate
  IF (l_status_code = 'INIT-DUE') THEN
    OPEN l_threshold_exists_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
    FETCH l_threshold_exists_csr INTO l_junk;
    IF (l_threshold_exists_csr%NOTFOUND) THEN
      IF(l_set_due_date = FND_API.G_MISS_DATE) THEN
        l_status_code := null;
        l_unit_deferral_operation := 'D';
      ELSE
        l_unit_deferral_operation := 'U';
      END IF;
    ELSE
        l_unit_deferral_operation := 'U';
    END IF;
    CLOSE l_threshold_exists_csr;

  ELSIF (l_status_code = 'INIT-ACCOMPLISHED') THEN
    OPEN l_accomplish_exists_csr(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
    FETCH l_accomplish_exists_csr INTO l_junk;
    IF (l_accomplish_exists_csr%NOTFOUND) THEN
      IF(l_accomplished_date IS NULL OR l_accomplished_date = FND_API.G_MISS_DATE) THEN
        l_status_code := null;
      END IF;
    -- raise error if date is null or g_miss.
    ELSIF (l_accomplished_date IS NULL OR l_accomplished_date = FND_API.G_MISS_DATE) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSHD_DATE_NULL');
        FND_MSG_PUB.ADD;
        RETURN;
    END IF;
    CLOSE l_accomplish_exists_csr;
    -- For INIT-ACCOMPLISHED, reset DUE_DATE, DUE_COUNTER_VALUE and MR_INTERVAL_ID
    l_ue_rec.DUE_DATE := null;
    l_ue_rec.earliest_due_date := null;
    l_ue_rec.latest_due_date := null;
    l_ue_rec.DUE_COUNTER_VALUE := null;
    l_ue_rec.MR_INTERVAL_ID := null;
  ELSIF (l_status_code = 'TERMINATED' OR l_status_code = 'MR-TERMINATE') THEN
    IF (l_accomplished_date IS NULL OR l_accomplished_date = FND_API.G_MISS_DATE) THEN
      l_accomplished_date := sysdate;
    END IF;
  END IF;

  -- If object version no is different, write error message and skip to next unit effectivity
  IF(l_ue_rec.OBJECT_VERSION_NUMBER <> p_unit_Effectivity_rec.OBJECT_VERSION_NUMBER) THEN
--    FND_MESSAGE.Set_Name('AHL','AHL_UMP_UE_CHANGED');
    FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  /* Moved this validation to the end of this procedure to validate after
   * init-accomplishment deletes as well.
  -- If this an accomplishment, init-accomplishment or termination, ensure that
  -- values for all counters are given by calling FMP API
  IF l_ue_rec.MR_HEADER_ID IS NOT NULL THEN
   IF (l_status_code = 'TERMINATED' OR l_status_code = 'MR-TERMINATE' OR
     l_status_code = 'ACCOMPLISHED') OR (l_status_code = 'INIT-ACCOMPLISHED' AND l_ue_rec.status_code IS NULL) THEN
    Match_Counters_with_FMP(
      p_unit_effectivity_id => p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
      p_item_instance_id    => l_ue_rec.CSI_ITEM_INSTANCE_ID,
      p_mr_header_id        => l_ue_rec.MR_HEADER_ID,
      x_counters            => l_counters_msg,
      x_return_status       => l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_MISSING_COUNTERS');
      FND_MESSAGE.Set_Token('COUNTERS', l_counters_msg);
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;
   END IF;
  END IF;
  */

  -- Handle G_MISS and null values
  IF l_accomplished_date = FND_API.G_MISS_DATE THEN
    l_accomplished_date := null;
  ELSIF l_accomplished_date IS NULL THEN
    l_accomplished_date := l_ue_rec.accomplished_date;
  END IF;

  -- For qa collection id.
  IF p_unit_Effectivity_rec.qa_collection_id = FND_API.G_MISS_NUM THEN
    l_ue_rec.qa_collection_id := null;
  ELSIF p_unit_Effectivity_rec.qa_collection_id IS NOT NULL THEN
    l_ue_rec.qa_collection_id := p_unit_Effectivity_rec.qa_collection_id ;
  END IF;

  IF p_unit_Effectivity_rec.REMARKS = FND_API.G_MISS_CHAR THEN
    l_ue_rec.REMARKS := null;
  ELSIF p_unit_Effectivity_rec.REMARKS IS NOT null THEN
    l_ue_rec.REMARKS := p_unit_Effectivity_rec.REMARKS;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE_CATEGORY := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE_CATEGORY IS NOT null THEN
    l_ue_rec.ATTRIBUTE_CATEGORY := p_unit_Effectivity_rec.ATTRIBUTE_CATEGORY;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE1 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE1 IS NOT null THEN
    l_ue_rec.ATTRIBUTE1 := p_unit_Effectivity_rec.ATTRIBUTE1;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE2 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE2 IS NOT null THEN
    l_ue_rec.ATTRIBUTE2 := p_unit_Effectivity_rec.ATTRIBUTE2;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE3 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE3 IS NOT null THEN
    l_ue_rec.ATTRIBUTE3 := p_unit_Effectivity_rec.ATTRIBUTE3;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE4 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE4 IS NOT null THEN
    l_ue_rec.ATTRIBUTE4 := p_unit_Effectivity_rec.ATTRIBUTE4;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE5 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE5 IS NOT null THEN
    l_ue_rec.ATTRIBUTE5 := p_unit_Effectivity_rec.ATTRIBUTE5;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE6 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE6 IS NOT null THEN
    l_ue_rec.ATTRIBUTE6 := p_unit_Effectivity_rec.ATTRIBUTE6;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE7 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE7 IS NOT null THEN
    l_ue_rec.ATTRIBUTE7 := p_unit_Effectivity_rec.ATTRIBUTE7;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE8 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE8 IS NOT null THEN
    l_ue_rec.ATTRIBUTE8 := p_unit_Effectivity_rec.ATTRIBUTE8;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE9 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE9 IS NOT null THEN
    l_ue_rec.ATTRIBUTE9 := p_unit_Effectivity_rec.ATTRIBUTE9;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE10 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE10 IS NOT null THEN
    l_ue_rec.ATTRIBUTE10 := p_unit_Effectivity_rec.ATTRIBUTE10;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE11 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE11 IS NOT null THEN
    l_ue_rec.ATTRIBUTE11 := p_unit_Effectivity_rec.ATTRIBUTE11;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE12 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE12 IS NOT null THEN
    l_ue_rec.ATTRIBUTE12 := p_unit_Effectivity_rec.ATTRIBUTE12;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE13 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE13 IS NOT null THEN
    l_ue_rec.ATTRIBUTE13 := p_unit_Effectivity_rec.ATTRIBUTE13;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE14 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE14 IS NOT null THEN
    l_ue_rec.ATTRIBUTE14 := p_unit_Effectivity_rec.ATTRIBUTE14;
  END IF;
  IF p_unit_Effectivity_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
    l_ue_rec.ATTRIBUTE15 := null;
  ELSIF p_unit_Effectivity_rec.ATTRIBUTE15 IS NOT null THEN
    l_ue_rec.ATTRIBUTE15 := p_unit_Effectivity_rec.ATTRIBUTE15;
  END IF;

  -- Call Table Handler to update record
  AHL_UNIT_EFFECTIVITIES_PKG.update_row(
            x_unit_effectivity_id => p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
            x_csi_item_instance_id => l_ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id => l_ue_rec.MR_INTERVAL_ID,
            x_mr_effectivity_id => l_ue_rec.MR_EFFECTIVITY_ID,
            x_mr_header_id => l_ue_rec.MR_HEADER_ID,
            x_status_code => l_status_code,
            x_due_date => l_ue_rec.DUE_DATE,
            x_due_counter_value => l_ue_rec.DUE_COUNTER_VALUE,
            x_forecast_sequence => l_ue_rec.FORECAST_SEQUENCE,
            x_repetitive_mr_flag => l_ue_rec.REPETITIVE_MR_FLAG,
            x_tolerance_flag => l_ue_rec.TOLERANCE_FLAG,
            x_remarks => l_ue_rec.REMARKS,
            x_message_code => l_ue_rec.MESSAGE_CODE,
            x_preceding_ue_id => l_ue_rec.PRECEDING_UE_ID,
            x_date_run => l_ue_rec.DATE_RUN,
            x_set_due_date => null,
            x_accomplished_date => l_accomplished_date,
            x_service_line_id   => l_ue_rec.service_line_id,
            x_program_mr_header_id => l_ue_rec.program_mr_header_id,
            x_cancel_reason_code   => l_ue_rec.cancel_reason_code,
            x_earliest_due_date    => l_ue_rec.earliest_due_date,
            x_latest_due_date      => l_ue_rec.latest_due_date,
            x_defer_from_ue_id     => l_ue_rec.defer_from_ue_id,
            x_qa_collection_id     => l_ue_rec.qa_collection_id,
            x_cs_incident_id       => l_ue_rec.cs_incident_id,
            x_orig_deferral_ue_id  => l_ue_rec.orig_deferral_ue_id,
            x_application_usg_code  => l_ue_rec.application_usg_code,
            x_object_type           => l_ue_rec.object_type,
            x_counter_id            => l_ue_rec.counter_id,
            x_manually_planned_flag => l_ue_rec.manually_planned_flag,
            X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
            X_ATA_CODE              => l_ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
            x_attribute_category => l_ue_rec.ATTRIBUTE_CATEGORY,
            x_attribute1 => l_ue_rec.ATTRIBUTE1,
            x_attribute2 => l_ue_rec.ATTRIBUTE2,
            x_attribute3 => l_ue_rec.ATTRIBUTE3,
            x_attribute4 => l_ue_rec.ATTRIBUTE4,
            x_attribute5 => l_ue_rec.ATTRIBUTE5,
            x_attribute6 => l_ue_rec.ATTRIBUTE6,
            x_attribute7 => l_ue_rec.ATTRIBUTE7,
            x_attribute8 => l_ue_rec.ATTRIBUTE8,
            x_attribute9 => l_ue_rec.ATTRIBUTE9,
            x_attribute10 => l_ue_rec.ATTRIBUTE10,
            x_attribute11 => l_ue_rec.ATTRIBUTE11,
            x_attribute12 => l_ue_rec.ATTRIBUTE12,
            x_attribute13 => l_ue_rec.ATTRIBUTE13,
            x_attribute14 => l_ue_rec.ATTRIBUTE14,
            x_attribute15 => l_ue_rec.ATTRIBUTE15,
            x_object_version_number => l_ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_last_update_date => TRUNC(sysdate),
            x_last_updated_by => fnd_global.user_id,
            x_last_update_login => fnd_global.login_id);


  -- Update/Delete the unit_deferrals record.
  OPEN ahl_unit_def_csr (p_unit_Effectivity_rec.unit_effectivity_id);
  FETCH ahl_unit_def_csr INTO l_unit_def_rec;
  IF (ahl_unit_def_csr%FOUND) THEN
    IF (l_unit_deferral_operation = 'D') THEN
       -- Check Object version.
       IF (l_unit_def_rec.object_version_number <> p_unit_Effectivity_rec.unit_deferral_object_version)
       THEN
         FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       AHL_UNIT_DEFERRALS_PKG.delete_row(x_unit_deferral_id => l_unit_def_rec.unit_deferral_id);

    ELSIF (l_unit_deferral_operation = 'U') THEN

       -- Check Object version.
       IF (l_unit_def_rec.object_version_number <> p_unit_Effectivity_rec.unit_deferral_object_version)
       THEN
         FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF l_set_due_date = FND_API.G_MISS_DATE THEN
         l_set_due_date := null;
       ELSIF l_set_due_date IS NULL THEN
         l_set_due_date  := l_unit_def_rec.set_due_date;
       END IF;

       IF (nvl(l_unit_def_rec.set_due_date, sysdate+1) <> nvl(l_set_due_date, sysdate+1)) THEN
         AHL_UNIT_DEFERRALS_PKG.update_row(
            x_unit_deferral_id => l_unit_def_rec.unit_deferral_id,
            x_ata_sequence_id => l_unit_def_rec.ata_sequence_id,
            x_object_version_number => l_unit_def_rec.object_version_number + 1,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_date => sysdate,
            x_last_update_login => fnd_global.login_id,
            x_unit_effectivity_id => p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
            x_unit_deferral_type => l_unit_def_rec.unit_deferral_type,
            x_set_due_date => l_set_due_date,
            x_deferral_effective_on => l_unit_def_rec.deferral_effective_on,
            x_approval_status_code => l_unit_def_rec.approval_status_code,
            x_defer_reason_code => l_unit_def_rec.defer_reason_code,
            x_affect_due_calc_flag => l_unit_def_rec.affect_due_calc_flag,
            x_skip_mr_flag => l_unit_def_rec.skip_mr_flag,
            x_remarks => l_unit_def_rec.remarks,
            x_approver_notes => l_unit_def_rec.approver_notes,
            x_user_deferral_type => null,
            x_attribute_category => l_unit_def_rec.attribute_category,
            x_attribute1 => l_unit_def_rec.attribute1,
            x_attribute2 => l_unit_def_rec.attribute2,
            x_attribute3 => l_unit_def_rec.attribute3,
            x_attribute4 => l_unit_def_rec.attribute4,
            x_attribute5 => l_unit_def_rec.attribute5,
            x_attribute6 => l_unit_def_rec.attribute6,
            x_attribute7 => l_unit_def_rec.attribute7,
            x_attribute8 => l_unit_def_rec.attribute8,
            x_attribute9 => l_unit_def_rec.attribute9,
            x_attribute10 => l_unit_def_rec.attribute10,
            x_attribute11 => l_unit_def_rec.attribute11,
            x_attribute12 => l_unit_def_rec.attribute12,
            x_attribute13 => l_unit_def_rec.attribute13,
            x_attribute14 => l_unit_def_rec.attribute14,
            x_attribute15 => l_unit_def_rec.attribute15
            );
      END IF; -- set due date.
    END IF;
  ELSE -- unit deferral not found.
    -- If set due date is not null, create a new unit deferral record.
    -- Create unit_deferral record.
    AHL_UNIT_DEFERRALS_PKG.insert_row(
            x_rowid => l_rowid,
            x_unit_deferral_id => l_unit_deferral_id,
            x_ata_sequence_id => null,
            x_object_version_number => 1,
            x_created_by => fnd_global.user_id,
            x_creation_date => sysdate,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_date => sysdate,
            x_last_update_login => fnd_global.login_id,
            x_unit_effectivity_id => p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
            x_unit_deferral_type => 'INIT-DUE',
            x_set_due_date => p_unit_Effectivity_rec.set_due_date,
            x_deferral_effective_on => null,
            x_approval_status_code => null,
            x_defer_reason_code => null,
            x_affect_due_calc_flag => 'Y',
            x_skip_mr_flag => null,
            x_remarks => null,
            x_approver_notes => null,
            x_user_deferral_type => null,
            x_attribute_category => null,
            x_attribute1 => null,
            x_attribute2 => null,
            x_attribute3 => null,
            x_attribute4 => null,
            x_attribute5 => null,
            x_attribute6 => null,
            x_attribute7 => null,
            x_attribute8 => null,
            x_attribute9 => null,
            x_attribute10 => null,
            x_attribute11 => null,
            x_attribute12 => null,
            x_attribute13 => null,
            x_attribute14 => null,
            x_attribute15 => null
            );

  END IF;
  CLOSE ahl_unit_def_csr ;

  -- Post Processing
  -- If this is a parent of a group, terminate all its descendents also
  IF (l_status_code = 'TERMINATED') THEN
    OPEN l_get_descendents(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
    LOOP
      FETCH l_get_descendents into l_descendent_ue_id;
      EXIT WHEN l_get_descendents%NOTFOUND;
      Terminate_Descendent(l_descendent_ue_id);
    END LOOP;
    CLOSE l_get_descendents;
  END IF;

  -- If this is an INIT-DUE, remove all accomplishments if any exists
  IF (l_status_code = 'INIT-DUE') THEN
    OPEN l_get_accomplishments(p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
    LOOP
      FETCH l_get_accomplishments into l_accomplishment_id;
      EXIT WHEN l_get_accomplishments%NOTFOUND;
      AHL_UNIT_ACCOMPLISH_PKG.delete_row(l_accomplishment_id);
    END LOOP;
    CLOSE l_get_accomplishments;
  END IF;

  -- If this is an INIT-ACCOMPLISHED, remove all thresholds if any exists
  IF (l_status_code = 'INIT-ACCOMPLISHED') THEN
    OPEN ahl_unit_def_csr (p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID);
    FETCH ahl_unit_def_csr INTO l_unit_def_rec;
    IF (ahl_unit_def_csr%FOUND) THEN

      -- delete thresholds.
      OPEN l_get_thresholds(l_unit_def_rec.unit_deferral_id);
      LOOP
        FETCH l_get_thresholds into l_threshold_id;
        EXIT WHEN l_get_thresholds%NOTFOUND;
        AHL_UNIT_THRESHOLDS_PKG.delete_row(l_threshold_id);
      END LOOP;
      CLOSE l_get_thresholds;

      -- delete unit_deferrals.
      AHL_UNIT_DEFERRALS_PKG.delete_row(x_unit_deferral_id => l_unit_def_rec.unit_deferral_id);

    END IF;
    CLOSE ahl_unit_def_csr;
  END IF;

  -- For an MR, if this an accomplishment, init-accomplishment or termination, ensure that
  -- values for all counters are given by calling FMP API
  IF l_ue_rec.MR_HEADER_ID IS NOT NULL THEN
     IF (l_status_code = 'TERMINATED' OR --l_status_code = 'MR-TERMINATE' OR
        l_status_code = 'ACCOMPLISHED' OR l_status_code = 'INIT-ACCOMPLISHED')
     THEN
       Match_Counters_with_FMP(
         p_unit_effectivity_id => p_unit_Effectivity_rec.UNIT_EFFECTIVITY_ID,
         p_item_instance_id    => l_ue_rec.CSI_ITEM_INSTANCE_ID,
         p_mr_header_id        => l_ue_rec.MR_HEADER_ID,
         x_counters            => l_counters_msg,
         x_return_status       => l_return_status);
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         FND_MESSAGE.Set_Name('AHL','AHL_UMP_MISSING_COUNTERS');
         FND_MESSAGE.Set_Token('COUNTERS', l_counters_msg);
         FND_MSG_PUB.ADD;
         --RETURN;
       END IF;
     END IF;
  END IF;

END Update_Unit_Effectivity;

------------------------------------
-- This procedure terminates a descendent unit effectivity
-- Only the following fields are affected (The rest are retained):
--   OBJECT_VERSION_NUMBER
--   STATUS_CODE
--   ACCOMPLISHED_DATE
--   LAST_UPDATE_DATE
--   LAST_UPDATED_BY
--   LAST_UPDATE_LOGIN
------------------------------------
PROCEDURE Terminate_Descendent(
   p_descendent_ue_id IN NUMBER) IS
  CURSOR l_get_unit_effectivity_csr(p_ue_id IN NUMBER) IS
    SELECT
      OBJECT_VERSION_NUMBER,
      CSI_ITEM_INSTANCE_ID,
      MR_INTERVAL_ID,
      MR_EFFECTIVITY_ID,
      MR_HEADER_ID,
      DUE_DATE,
      DUE_COUNTER_VALUE,
      FORECAST_SEQUENCE,
      REPETITIVE_MR_FLAG,
      TOLERANCE_FLAG,
      REMARKS,
      MESSAGE_CODE,
      PRECEDING_UE_ID,
      DATE_RUN,
      SET_DUE_DATE,
      SERVICE_LINE_ID,
      PROGRAM_MR_HEADER_ID,
      CANCEL_REASON_CODE,
      EARLIEST_DUE_DATE,
      LATEST_DUE_DATE,
      DEFER_FROM_UE_ID,
      CS_INCIDENT_ID,
      QA_COLLECTION_ID,
      ORIG_DEFERRAL_UE_ID,
      APPLICATION_USG_CODE,
      OBJECT_TYPE,
      COUNTER_ID,
      MANUALLY_PLANNED_FLAG,
      LOG_SERIES_CODE,
      LOG_SERIES_NUMBER,
      FLIGHT_NUMBER,
      MEL_CDL_TYPE_CODE,
      POSITION_PATH_ID,
      ATA_CODE,
      UNIT_CONFIG_HEADER_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE unit_effectivity_id = p_ue_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

   l_ue_rec   l_get_unit_effectivity_csr%rowtype;

BEGIN
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Terminating Descendent with ue_id ' || p_descendent_ue_id, 'UMP');
  END IF;
  OPEN l_get_unit_effectivity_csr(p_descendent_ue_id);
  FETCH l_get_unit_effectivity_csr INTO l_ue_rec;
  CLOSE l_get_unit_effectivity_csr;

  -- Call Table Handler to update record
  AHL_UNIT_EFFECTIVITIES_PKG.update_row(
            x_unit_effectivity_id => p_descendent_ue_id,
            x_csi_item_instance_id => l_ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id => l_ue_rec.MR_INTERVAL_ID,
            x_mr_effectivity_id => l_ue_rec.MR_EFFECTIVITY_ID,
            x_mr_header_id => l_ue_rec.MR_HEADER_ID,
            x_status_code => 'TERMINATED',
            x_due_date => l_ue_rec.DUE_DATE,
            x_due_counter_value => l_ue_rec.DUE_COUNTER_VALUE,
            x_forecast_sequence => l_ue_rec.FORECAST_SEQUENCE,
            x_repetitive_mr_flag => l_ue_rec.REPETITIVE_MR_FLAG,
            x_tolerance_flag => l_ue_rec.TOLERANCE_FLAG,
            x_remarks => l_ue_rec.REMARKS,
            x_message_code => l_ue_rec.MESSAGE_CODE,
            x_preceding_ue_id => l_ue_rec.PRECEDING_UE_ID,
            x_date_run => l_ue_rec.DATE_RUN,
            x_set_due_date => l_ue_rec.SET_DUE_DATE,
            x_accomplished_date => TRUNC(sysdate),
            x_service_line_id  => l_ue_rec.service_line_id,
            x_program_mr_header_id => l_ue_rec.program_mr_header_id,
            x_cancel_reason_code => l_ue_rec.cancel_reason_code,
            x_earliest_due_date  => l_ue_rec.earliest_due_date,
            x_latest_due_date    => l_ue_rec.latest_due_date,
            x_defer_from_ue_id     => l_ue_rec.defer_from_ue_id,
            x_qa_collection_id     => l_ue_rec.qa_collection_id,
            x_orig_deferral_ue_id  => l_ue_rec.orig_deferral_ue_id,
            x_cs_incident_id       => l_ue_rec.cs_incident_id,
            x_application_usg_code => l_ue_rec.application_usg_code,
            x_object_type          => l_ue_rec.object_type,
            x_counter_id           => l_ue_rec.counter_id,
            x_manually_planned_flag => l_ue_rec.manually_planned_flag,
            X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
            X_ATA_CODE              => l_ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
            x_attribute_category => l_ue_rec.ATTRIBUTE_CATEGORY,
            x_attribute1 => l_ue_rec.ATTRIBUTE1,
            x_attribute2 => l_ue_rec.ATTRIBUTE2,
            x_attribute3 => l_ue_rec.ATTRIBUTE3,
            x_attribute4 => l_ue_rec.ATTRIBUTE4,
            x_attribute5 => l_ue_rec.ATTRIBUTE5,
            x_attribute6 => l_ue_rec.ATTRIBUTE6,
            x_attribute7 => l_ue_rec.ATTRIBUTE7,
            x_attribute8 => l_ue_rec.ATTRIBUTE8,
            x_attribute9 => l_ue_rec.ATTRIBUTE9,
            x_attribute10 => l_ue_rec.ATTRIBUTE10,
            x_attribute11 => l_ue_rec.ATTRIBUTE11,
            x_attribute12 => l_ue_rec.ATTRIBUTE12,
            x_attribute13 => l_ue_rec.ATTRIBUTE13,
            x_attribute14 => l_ue_rec.ATTRIBUTE14,
            x_attribute15 => l_ue_rec.ATTRIBUTE15,
            x_object_version_number => l_ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_last_update_date => TRUNC(sysdate),
            x_last_updated_by => fnd_global.user_id,
            x_last_update_login => fnd_global.login_id);

END Terminate_Descendent;

------------------------------------
-- This procedure saves the thresholds by calling
-- the insert_row, update_row or delete_row methods
-- of the Thresholds table handler
------------------------------------
PROCEDURE Update_Thresholds(
    p_unit_Effectivity_rec IN AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type,
    p_x_unit_threshold_tbl IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type) IS

  CURSOR l_get_unit_threshold_csr(p_threshold_id IN NUMBER) IS
    SELECT OBJECT_VERSION_NUMBER,
      --UNIT_EFFECTIVITY_ID,
      UNIT_DEFERRAL_ID,
      COUNTER_ID,
      CTR_VALUE_TYPE_CODE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    FROM AHL_UNIT_THRESHOLDS
    WHERE UNIT_THRESHOLD_ID = p_threshold_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR l_get_dup_counter_csr(p_unit_def_id IN NUMBER,
                               p_counter_id  IN NUMBER) IS
    SELECT 'x'
    FROM AHL_UNIT_THRESHOLDS UTH
    WHERE UTH.unit_deferral_id = p_unit_def_id AND
          UTH.COUNTER_ID = p_counter_id;

  CURSOR l_get_def_csr(p_ue_id      IN NUMBER) IS
    SELECT unit_deferral_id
    FROM AHL_UNIT_DEFERRALS_B UDF
    WHERE UDF.UNIT_EFFECTIVITY_ID = p_ue_id AND
          UDF.UNIT_DEFERRAL_TYPE = 'INIT-DUE';

  l_threshold_details  l_get_unit_threshold_csr%ROWTYPE;
  l_junk               VARCHAR2(1);
  l_unit_deferral_id   NUMBER;
  l_rowid              VARCHAR2(30);

BEGIN
  IF (p_x_unit_threshold_tbl.COUNT > 0) THEN
    FOR i IN p_x_unit_threshold_tbl.FIRST..p_x_unit_threshold_tbl.LAST LOOP
      IF (p_x_unit_threshold_tbl(i).OPERATION_FLAG = 'D') THEN
        -- delete row
        AHL_UNIT_THRESHOLDS_PKG.delete_row(p_x_unit_threshold_tbl(i).UNIT_THRESHOLD_ID);
      ELSIF (p_x_unit_threshold_tbl(i).OPERATION_FLAG = 'M') THEN
        -- modify row
        OPEN l_get_unit_threshold_csr(p_x_unit_threshold_tbl(i).UNIT_THRESHOLD_ID);
        FETCH l_get_unit_threshold_csr INTO l_threshold_details;
        IF (l_get_unit_threshold_csr%FOUND) THEN
          -- If object version no is different, write error message and skip to next unit effectivity
          IF(l_threshold_details.OBJECT_VERSION_NUMBER <> p_x_unit_threshold_tbl(i).OBJECT_VERSION_NUMBER) THEN
--            FND_MESSAGE.Set_Name('AHL','AHL_UMP_THRESHOLD_CHANGED');
--            FND_MESSAGE.Set_Token('COUNTER', p_x_unit_threshold_tbl(i).COUNTER_NAME);
            FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
            FND_MSG_PUB.ADD;
            RETURN;
          END IF;
          p_x_unit_threshold_tbl(i).OBJECT_VERSION_NUMBER := l_threshold_details.OBJECT_VERSION_NUMBER + 1;
          -- Handle G_MISS and null values
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY := l_threshold_details.ATTRIBUTE_CATEGORY;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE1 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE1 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE1 := l_threshold_details.ATTRIBUTE1;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE2 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE2 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE2 := l_threshold_details.ATTRIBUTE2;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE3 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE3 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE3 := l_threshold_details.ATTRIBUTE3;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE4 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE4 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE4 := l_threshold_details.ATTRIBUTE4;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE5 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE5 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE5 := l_threshold_details.ATTRIBUTE5;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE6 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE6 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE6 := l_threshold_details.ATTRIBUTE6;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE7 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE7 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE7 := l_threshold_details.ATTRIBUTE7;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE8 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE8 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE8 := l_threshold_details.ATTRIBUTE8;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE9 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE9 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE9 := l_threshold_details.ATTRIBUTE9;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE10 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE10 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE10 := l_threshold_details.ATTRIBUTE10;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE11 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE11 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE11 := l_threshold_details.ATTRIBUTE11;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE12 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE12 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE12 := l_threshold_details.ATTRIBUTE12;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE13 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE13 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE13 := l_threshold_details.ATTRIBUTE13;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE14 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE14 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE14 := l_threshold_details.ATTRIBUTE14;
          END IF;
          IF p_x_unit_threshold_tbl(i).ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE15 := null;
          ELSIF p_x_unit_threshold_tbl(i).ATTRIBUTE15 IS null THEN
            p_x_unit_threshold_tbl(i).ATTRIBUTE15 := l_threshold_details.ATTRIBUTE15;
          END IF;

          -- Call table handler to update
          AHL_UNIT_THRESHOLDS_PKG.update_row (
            P_UNIT_THRESHOLD_ID       => p_x_unit_threshold_tbl(i).UNIT_THRESHOLD_ID,
            --P_UNIT_EFFECTIVITY_ID     => l_threshold_details.UNIT_EFFECTIVITY_ID,
            P_UNIT_DEFERRAL_ID        => l_threshold_details.UNIT_DEFERRAL_ID,
            P_CTR_VALUE_TYPE_CODE     => l_threshold_details.CTR_VALUE_TYPE_CODE,
            P_COUNTER_ID              => l_threshold_details.COUNTER_ID,
            P_COUNTER_VALUE           => p_x_unit_threshold_tbl(i).COUNTER_VALUE,
            P_ATTRIBUTE_CATEGORY      => p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1              => p_x_unit_threshold_tbl(i).ATTRIBUTE1,
            P_ATTRIBUTE2              => p_x_unit_threshold_tbl(i).ATTRIBUTE2,
            P_ATTRIBUTE3              => p_x_unit_threshold_tbl(i).ATTRIBUTE3,
            P_ATTRIBUTE4              => p_x_unit_threshold_tbl(i).ATTRIBUTE4,
            P_ATTRIBUTE5              => p_x_unit_threshold_tbl(i).ATTRIBUTE5,
            P_ATTRIBUTE6              => p_x_unit_threshold_tbl(i).ATTRIBUTE6,
            P_ATTRIBUTE7              => p_x_unit_threshold_tbl(i).ATTRIBUTE7,
            P_ATTRIBUTE8              => p_x_unit_threshold_tbl(i).ATTRIBUTE8,
            P_ATTRIBUTE9              => p_x_unit_threshold_tbl(i).ATTRIBUTE9,
            P_ATTRIBUTE10             => p_x_unit_threshold_tbl(i).ATTRIBUTE10,
            P_ATTRIBUTE11             => p_x_unit_threshold_tbl(i).ATTRIBUTE11,
            P_ATTRIBUTE12             => p_x_unit_threshold_tbl(i).ATTRIBUTE12,
            P_ATTRIBUTE13             => p_x_unit_threshold_tbl(i).ATTRIBUTE13,
            P_ATTRIBUTE14             => p_x_unit_threshold_tbl(i).ATTRIBUTE14,
            P_ATTRIBUTE15             => p_x_unit_threshold_tbl(i).ATTRIBUTE15,
            P_OBJECT_VERSION_NUMBER   => p_x_unit_threshold_tbl(i).OBJECT_VERSION_NUMBER,
            P_LAST_UPDATE_DATE        => TRUNC(sysdate),
            P_LAST_UPDATED_BY         => fnd_global.user_id,
            P_LAST_UPDATE_LOGIN       => fnd_global.login_id);
          ELSE
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_THRSHLD_ID_INVALID');
            FND_MESSAGE.Set_Token('THRESHOLDID', p_x_unit_threshold_tbl(i).UNIT_THRESHOLD_ID);
            FND_MSG_PUB.ADD;
          END IF;
          CLOSE l_get_unit_threshold_csr;
      ELSIF (p_x_unit_threshold_tbl(i).OPERATION_FLAG = 'C') THEN
        -- insert threshold row
        -- Check if record exists in ahl_unit_deferral.
        OPEN l_get_def_csr(p_x_unit_threshold_tbl(i).UNIT_EFFECTIVITY_ID);
        FETCH l_get_def_csr INTO l_unit_deferral_id;
        IF (l_get_def_csr%FOUND) THEN
          OPEN l_get_dup_counter_csr(l_unit_deferral_id, p_x_unit_threshold_tbl(i).COUNTER_ID);
          FETCH l_get_dup_counter_csr INTO l_junk;
          IF (l_get_dup_counter_csr%FOUND) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_DUPLICATE_COUNTER');
            FND_MESSAGE.Set_Token('COUNTERID', p_x_unit_threshold_tbl(i).COUNTER_ID);
            FND_MSG_PUB.ADD;
            CLOSE l_get_dup_counter_csr;
            RETURN;
          END IF;
          CLOSE l_get_dup_counter_csr;
        ELSE
          -- Create unit_deferral record.
          AHL_UNIT_DEFERRALS_PKG.insert_row(
            x_rowid => l_rowid,
            x_unit_deferral_id => l_unit_deferral_id,
            x_ata_sequence_id => null,
            x_object_version_number => 1,
            x_created_by => fnd_global.user_id,
            x_creation_date => sysdate,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_date => sysdate,
            x_last_update_login => fnd_global.login_id,
            x_unit_effectivity_id => p_x_unit_threshold_tbl(i).unit_effectivity_id,
            x_unit_deferral_type => 'INIT-DUE',
            x_set_due_date => p_unit_Effectivity_rec.set_due_date,
            x_deferral_effective_on => null,
            x_approval_status_code => null,
            x_defer_reason_code => null,
            x_affect_due_calc_flag => 'Y',
            x_skip_mr_flag => null,
            x_remarks => null,
            x_approver_notes => null,
            x_user_deferral_type => null,
            x_attribute_category => null,
            x_attribute1 => null,
            x_attribute2 => null,
            x_attribute3 => null,
            x_attribute4 => null,
            x_attribute5 => null,
            x_attribute6 => null,
            x_attribute7 => null,
            x_attribute8 => null,
            x_attribute9 => null,
            x_attribute10 => null,
            x_attribute11 => null,
            x_attribute12 => null,
            x_attribute13 => null,
            x_attribute14 => null,
            x_attribute15 => null
            );

        END IF;
        CLOSE l_get_def_csr;

        p_x_unit_threshold_tbl(i).OBJECT_VERSION_NUMBER := 1;
        -- Handle G_MISS and null values
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE1 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE2 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE3 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE4 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE5 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE6 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE7 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE8 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE9 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE10 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE11 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE12 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE13 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE14 := null;
        END IF;
        IF p_x_unit_threshold_tbl(i).ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
          p_x_unit_threshold_tbl(i).ATTRIBUTE15 := null;
        END IF;
        -- Call table handler to insert
        AHL_UNIT_THRESHOLDS_PKG.insert_row (
          P_X_UNIT_THRESHOLD_ID     => p_x_unit_threshold_tbl(i).UNIT_THRESHOLD_ID,
          --P_UNIT_EFFECTIVITY_ID     => p_x_unit_threshold_tbl(i).UNIT_EFFECTIVITY_ID,
          P_UNIT_DEFERRAL_ID        => l_UNIT_DEFERRAL_ID,
          P_COUNTER_ID              => p_x_unit_threshold_tbl(i).COUNTER_ID,
          P_COUNTER_VALUE           => p_x_unit_threshold_tbl(i).COUNTER_VALUE,
          P_CTR_VALUE_TYPE_CODE     => 'DEFER_TO',
          P_ATTRIBUTE_CATEGORY      => p_x_unit_threshold_tbl(i).ATTRIBUTE_CATEGORY,
          P_ATTRIBUTE1              => p_x_unit_threshold_tbl(i).ATTRIBUTE1,
          P_ATTRIBUTE2              => p_x_unit_threshold_tbl(i).ATTRIBUTE2,
          P_ATTRIBUTE3              => p_x_unit_threshold_tbl(i).ATTRIBUTE3,
          P_ATTRIBUTE4              => p_x_unit_threshold_tbl(i).ATTRIBUTE4,
          P_ATTRIBUTE5              => p_x_unit_threshold_tbl(i).ATTRIBUTE5,
          P_ATTRIBUTE6              => p_x_unit_threshold_tbl(i).ATTRIBUTE6,
          P_ATTRIBUTE7              => p_x_unit_threshold_tbl(i).ATTRIBUTE7,
          P_ATTRIBUTE8              => p_x_unit_threshold_tbl(i).ATTRIBUTE8,
          P_ATTRIBUTE9              => p_x_unit_threshold_tbl(i).ATTRIBUTE9,
          P_ATTRIBUTE10             => p_x_unit_threshold_tbl(i).ATTRIBUTE10,
          P_ATTRIBUTE11             => p_x_unit_threshold_tbl(i).ATTRIBUTE11,
          P_ATTRIBUTE12             => p_x_unit_threshold_tbl(i).ATTRIBUTE12,
          P_ATTRIBUTE13             => p_x_unit_threshold_tbl(i).ATTRIBUTE13,
          P_ATTRIBUTE14             => p_x_unit_threshold_tbl(i).ATTRIBUTE14,
          P_ATTRIBUTE15             => p_x_unit_threshold_tbl(i).ATTRIBUTE15,
          P_OBJECT_VERSION_NUMBER   => p_x_unit_threshold_tbl(i).OBJECT_VERSION_NUMBER,
          P_LAST_UPDATE_DATE        => TRUNC(sysdate),
          P_LAST_UPDATED_BY         => fnd_global.user_id,
          P_CREATION_DATE           => TRUNC(sysdate),
          P_CREATED_BY              => fnd_global.user_id,
          P_LAST_UPDATE_LOGIN       => fnd_global.login_id);
      ELSE
        -- unrecognized operation flag
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_OPERATION_INVALID');
        FND_MESSAGE.Set_Token('OPERATION', p_x_unit_threshold_tbl(i).OPERATION_FLAG);
        FND_MSG_PUB.ADD;
      END IF;
    END LOOP;
  END IF;
END Update_Thresholds;

------------------------------------
-- This procedure saves the accomplishments by calling
-- the insert_row, update_row or delete_row methods
-- of the Accomplishments table handler
------------------------------------
PROCEDURE Update_Accomplishments(
   p_x_unit_accomplish_tbl IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
   p_unit_Effectivity_rec  IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_rec_type) IS

  CURSOR l_get_unit_accomplish_csr(p_accomplish_id IN NUMBER) IS
    SELECT OBJECT_VERSION_NUMBER,
      UNIT_EFFECTIVITY_ID,
      COUNTER_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    FROM AHL_UNIT_ACCOMPLISHMNTS
    WHERE UNIT_ACCOMPLISHMNT_ID = p_accomplish_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR l_get_dup_counter_csr(p_ue_id      IN NUMBER,
                               p_counter_id IN NUMBER) IS
    SELECT 'x'
    FROM AHL_UNIT_ACCOMPLISHMNTS
    WHERE UNIT_EFFECTIVITY_ID = p_ue_id AND
    COUNTER_ID = p_counter_id;

  l_accomplish_details  l_get_unit_accomplish_csr%ROWTYPE;
  l_junk                VARCHAR2(1);

  l_counter_reading_lock_rec  csi_ctr_datastructures_pub.ctr_reading_lock_rec;
  l_reading_lock_id           NUMBER;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_return_status             VARCHAR2(1);

BEGIN
  IF (p_x_unit_accomplish_tbl.COUNT > 0) THEN
    FOR i IN p_x_unit_accomplish_tbl.FIRST..p_x_unit_accomplish_tbl.LAST LOOP
      IF (p_x_unit_accomplish_tbl(i).OPERATION_FLAG = 'D') THEN
        -- delete row
        AHL_UNIT_ACCOMPLISH_PKG.delete_row(p_x_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID);
      ELSIF (p_x_unit_accomplish_tbl(i).OPERATION_FLAG = 'M') THEN
        -- modify row
        OPEN l_get_unit_accomplish_csr(p_x_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID);
        FETCH l_get_unit_accomplish_csr INTO l_accomplish_details;
        IF (l_get_unit_accomplish_csr%FOUND) THEN
          -- If object version no is different, write error message and skip to next unit effectivity
          IF(l_accomplish_details.OBJECT_VERSION_NUMBER <> p_x_unit_accomplish_tbl(i).OBJECT_VERSION_NUMBER) THEN
--            FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSHMNT_CHANGED');
--            FND_MESSAGE.Set_Token('COUNTER', p_x_unit_accomplish_tbl(i).COUNTER_NAME);
            FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
            FND_MSG_PUB.ADD;
            RETURN;
          END IF;
          p_x_unit_accomplish_tbl(i).OBJECT_VERSION_NUMBER := l_accomplish_details.OBJECT_VERSION_NUMBER + 1;
          -- Handle G_MISS and null values
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY := l_accomplish_details.ATTRIBUTE_CATEGORY;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE1 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE1 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE1 := l_accomplish_details.ATTRIBUTE1;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE2 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE2 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE2 := l_accomplish_details.ATTRIBUTE2;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE3 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE3 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE3 := l_accomplish_details.ATTRIBUTE3;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE4 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE4 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE4 := l_accomplish_details.ATTRIBUTE4;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE5 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE5 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE5 := l_accomplish_details.ATTRIBUTE5;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE6 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE6 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE6 := l_accomplish_details.ATTRIBUTE6;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE7 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE7 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE7 := l_accomplish_details.ATTRIBUTE7;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE8 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE8 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE8 := l_accomplish_details.ATTRIBUTE8;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE9 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE9 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE9 := l_accomplish_details.ATTRIBUTE9;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE10 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE10 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE10 := l_accomplish_details.ATTRIBUTE10;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE11 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE11 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE11 := l_accomplish_details.ATTRIBUTE11;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE12 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE12 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE12 := l_accomplish_details.ATTRIBUTE12;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE13 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE13 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE13 := l_accomplish_details.ATTRIBUTE13;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE14 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE14 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE14 := l_accomplish_details.ATTRIBUTE14;
          END IF;
          IF p_x_unit_accomplish_tbl(i).ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE15 := null;
          ELSIF p_x_unit_accomplish_tbl(i).ATTRIBUTE15 IS null THEN
            p_x_unit_accomplish_tbl(i).ATTRIBUTE15 := l_accomplish_details.ATTRIBUTE15;
          END IF;

          -- Call table handler to update
          AHL_UNIT_ACCOMPLISH_PKG.update_row (
            P_UNIT_ACCOMPLISHMNT_ID   => p_x_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID,
            P_UNIT_EFFECTIVITY_ID     => p_x_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID,
            P_COUNTER_ID              => p_x_unit_accomplish_tbl(i).COUNTER_ID,
            P_COUNTER_VALUE           => p_x_unit_accomplish_tbl(i).COUNTER_VALUE,
            P_ATTRIBUTE_CATEGORY      => p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1              => p_x_unit_accomplish_tbl(i).ATTRIBUTE1,
            P_ATTRIBUTE2              => p_x_unit_accomplish_tbl(i).ATTRIBUTE2,
            P_ATTRIBUTE3              => p_x_unit_accomplish_tbl(i).ATTRIBUTE3,
            P_ATTRIBUTE4              => p_x_unit_accomplish_tbl(i).ATTRIBUTE4,
            P_ATTRIBUTE5              => p_x_unit_accomplish_tbl(i).ATTRIBUTE5,
            P_ATTRIBUTE6              => p_x_unit_accomplish_tbl(i).ATTRIBUTE6,
            P_ATTRIBUTE7              => p_x_unit_accomplish_tbl(i).ATTRIBUTE7,
            P_ATTRIBUTE8              => p_x_unit_accomplish_tbl(i).ATTRIBUTE8,
            P_ATTRIBUTE9              => p_x_unit_accomplish_tbl(i).ATTRIBUTE9,
            P_ATTRIBUTE10             => p_x_unit_accomplish_tbl(i).ATTRIBUTE10,
            P_ATTRIBUTE11             => p_x_unit_accomplish_tbl(i).ATTRIBUTE11,
            P_ATTRIBUTE12             => p_x_unit_accomplish_tbl(i).ATTRIBUTE12,
            P_ATTRIBUTE13             => p_x_unit_accomplish_tbl(i).ATTRIBUTE13,
            P_ATTRIBUTE14             => p_x_unit_accomplish_tbl(i).ATTRIBUTE14,
            P_ATTRIBUTE15             => p_x_unit_accomplish_tbl(i).ATTRIBUTE15,
            P_OBJECT_VERSION_NUMBER   => p_x_unit_accomplish_tbl(i).OBJECT_VERSION_NUMBER,
            P_LAST_UPDATE_DATE        => TRUNC(sysdate),
            P_LAST_UPDATED_BY         => fnd_global.user_id,
            P_LAST_UPDATE_LOGIN       => fnd_global.login_id);
          ELSE
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_ACCMPLSH_ID_INVALID');
            FND_MESSAGE.Set_Token('ACCOMPLISHMENTID', p_x_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID);
            FND_MSG_PUB.ADD;
          END IF;
          CLOSE l_get_unit_accomplish_csr;
      ELSIF (p_x_unit_accomplish_tbl(i).OPERATION_FLAG = 'C') THEN
        -- insert row
        OPEN l_get_dup_counter_csr(p_x_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID, p_x_unit_accomplish_tbl(i).COUNTER_ID);
        FETCH l_get_dup_counter_csr INTO l_junk;
        IF (l_get_dup_counter_csr%FOUND) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_DUPLICATE_COUNTER');
          FND_MESSAGE.Set_Token('COUNTERID', p_x_unit_accomplish_tbl(i).COUNTER_ID);
          FND_MSG_PUB.ADD;
          CLOSE l_get_dup_counter_csr;
          RETURN;
        END IF;
        CLOSE l_get_dup_counter_csr;
        p_x_unit_accomplish_tbl(i).OBJECT_VERSION_NUMBER := 1;
        -- Handle G_MISS and null values
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE1 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE2 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE3 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE4 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE5 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE6 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE7 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE8 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE9 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE10 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE11 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE12 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE13 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE14 := null;
        END IF;
        IF p_x_unit_accomplish_tbl(i).ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
          p_x_unit_accomplish_tbl(i).ATTRIBUTE15 := null;
        END IF;
        -- Call table handler to insert
        AHL_UNIT_ACCOMPLISH_PKG.insert_row (
          P_X_UNIT_ACCOMPLISHMNT_ID => p_x_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID,
          P_UNIT_EFFECTIVITY_ID     => p_x_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID,
          P_COUNTER_ID              => p_x_unit_accomplish_tbl(i).COUNTER_ID,
          P_COUNTER_VALUE           => p_x_unit_accomplish_tbl(i).COUNTER_VALUE,
          P_ATTRIBUTE_CATEGORY      => p_x_unit_accomplish_tbl(i).ATTRIBUTE_CATEGORY,
          P_ATTRIBUTE1              => p_x_unit_accomplish_tbl(i).ATTRIBUTE1,
          P_ATTRIBUTE2              => p_x_unit_accomplish_tbl(i).ATTRIBUTE2,
          P_ATTRIBUTE3              => p_x_unit_accomplish_tbl(i).ATTRIBUTE3,
          P_ATTRIBUTE4              => p_x_unit_accomplish_tbl(i).ATTRIBUTE4,
          P_ATTRIBUTE5              => p_x_unit_accomplish_tbl(i).ATTRIBUTE5,
          P_ATTRIBUTE6              => p_x_unit_accomplish_tbl(i).ATTRIBUTE6,
          P_ATTRIBUTE7              => p_x_unit_accomplish_tbl(i).ATTRIBUTE7,
          P_ATTRIBUTE8              => p_x_unit_accomplish_tbl(i).ATTRIBUTE8,
          P_ATTRIBUTE9              => p_x_unit_accomplish_tbl(i).ATTRIBUTE9,
          P_ATTRIBUTE10             => p_x_unit_accomplish_tbl(i).ATTRIBUTE10,
          P_ATTRIBUTE11             => p_x_unit_accomplish_tbl(i).ATTRIBUTE11,
          P_ATTRIBUTE12             => p_x_unit_accomplish_tbl(i).ATTRIBUTE12,
          P_ATTRIBUTE13             => p_x_unit_accomplish_tbl(i).ATTRIBUTE13,
          P_ATTRIBUTE14             => p_x_unit_accomplish_tbl(i).ATTRIBUTE14,
          P_ATTRIBUTE15             => p_x_unit_accomplish_tbl(i).ATTRIBUTE15,
          P_OBJECT_VERSION_NUMBER   => p_x_unit_accomplish_tbl(i).OBJECT_VERSION_NUMBER,
          P_LAST_UPDATE_DATE        => TRUNC(sysdate),
          P_LAST_UPDATED_BY         => fnd_global.user_id,
          P_CREATION_DATE           => TRUNC(sysdate),
          P_CREATED_BY              => fnd_global.user_id,
          P_LAST_UPDATE_LOGIN       => fnd_global.login_id);

          /* Commented out call for locking counter reading for bug# 6388834.
           * User can adjust counter readings/record for prior dated counter
           * readings after MR signoff.
          -- lock counter reading if UMP being accomplished.
          IF (p_unit_Effectivity_rec.status_code = 'ACCOMPLISHED' OR
              p_unit_Effectivity_rec.status_code = 'TERMINATED') THEN
               l_counter_reading_lock_rec.reading_lock_date := p_unit_Effectivity_rec.accomplished_date;
               l_counter_reading_lock_rec.counter_id := p_x_unit_accomplish_tbl(i).COUNTER_ID;
               l_counter_reading_lock_rec.source_line_ref_id := p_x_unit_accomplish_tbl(i).UNIT_ACCOMPLISH_ID;
               l_counter_reading_lock_rec.source_line_ref := 'MAINTENANCE_ACCOMPLISHMENT';

               CSI_COUNTER_PUB.Create_Reading_Lock
               (
                    p_api_version          => 1.0,
                    p_commit               => FND_API.G_FALSE,
                    p_init_msg_list        => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                    p_ctr_reading_lock_rec => l_counter_reading_lock_rec,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data,
                    x_reading_lock_id     => l_reading_lock_id
               );

               -- Raise errors if exception occurs
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

          END IF;
          */
      ELSE
        -- unrecognized operation flag
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_OPERATION_INVALID');
        FND_MESSAGE.Set_Token('OPERATION', p_x_unit_accomplish_tbl(i).OPERATION_FLAG);
        FND_MSG_PUB.ADD;
      END IF;
    END LOOP;
  END IF;
END Update_Accomplishments;

------------------------------------
-- This procedure transfers data to the master
-- table from the sub list
------------------------------------
PROCEDURE Restore_Thresholds(
   p_x_unit_threshold_tbl   IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
   p_unit_threshold_tbl     IN     AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type) IS
   l_index         NUMBER;
   l_curr_ue_id    NUMBER;
BEGIN
  IF (p_unit_threshold_tbl.COUNT > 0) THEN
    l_index := p_unit_threshold_tbl.FIRST;
    l_curr_ue_id := p_unit_threshold_tbl(l_index).UNIT_EFFECTIVITY_ID;
    FOR i IN p_x_unit_threshold_tbl.FIRST..p_x_unit_threshold_tbl.LAST LOOP
      IF (p_x_unit_threshold_tbl(i).UNIT_EFFECTIVITY_ID = l_curr_ue_id) THEN
        p_x_unit_threshold_tbl(i) := p_unit_threshold_tbl(l_index);
        l_index := l_index + 1;
      END IF;
    END LOOP;
  END IF;
END Restore_Thresholds;

------------------------------------
-- This procedure transfers data to the master
-- table from the sub list
------------------------------------
PROCEDURE Restore_Accomplishments(
   p_x_unit_accomplish_tbl   IN OUT NOCOPY AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
   p_unit_accomplish_tbl     IN     AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type) IS
   l_index         NUMBER;
   l_curr_ue_id    NUMBER;
BEGIN
  IF (p_unit_accomplish_tbl.COUNT > 0) THEN
    l_index := p_unit_accomplish_tbl.FIRST;
    l_curr_ue_id := p_unit_accomplish_tbl(l_index).UNIT_EFFECTIVITY_ID;
    FOR i IN p_x_unit_accomplish_tbl.FIRST..p_x_unit_accomplish_tbl.LAST LOOP
      IF (p_x_unit_accomplish_tbl(i).UNIT_EFFECTIVITY_ID = l_curr_ue_id) THEN
        p_x_unit_accomplish_tbl(i) := p_unit_accomplish_tbl(l_index);
        l_index := l_index + 1;
      END IF;
    END LOOP;
  END IF;
END Restore_Accomplishments;

------------------------------------
-- This procedure checks if all required counters are available for a given UE.
-- Uses FMP API in the process
------------------------------------
PROCEDURE Match_Counters_with_FMP(
   p_unit_effectivity_id IN  NUMBER,
   p_item_instance_id    IN  NUMBER,
   p_mr_header_id        IN  NUMBER,
   x_counters            OUT NOCOPY VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2) IS

   l_temp_counter_name  VARCHAR2(30);
   l_temp_sql_str       VARCHAR2(4000);
   l_fmp_eff            VARCHAR2(3000);
   l_fmp_sql            VARCHAR2(3500);
   l_inst_sql           VARCHAR2(250);
   l_acc_sql            VARCHAR2(250);
   l_counters_csr       CounterCurTyp;
   l_effectivities_tbl  AHL_FMP_PVT.APPLICABLE_MR_TBL_TYPE;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(30);
   l_counters_msg       VARCHAR2(1000);

   CURSOR get_unmatched_counter(p_mr_effectivity_id IN NUMBER,
                                   p_instance_id IN NUMBER,
                                   p_unit_effectivity_id IN NUMBER)
      IS
      -- Fix for bug# 6956784. Replace CS_COUNTERS with csi_counter_template_vl.
      -- select distinct name counter_name from cs_counters co, ahl_mr_intervals mr
      select distinct name counter_name from csi_counter_template_vl co, ahl_mr_intervals mr
      where co.counter_id = mr.counter_id
      and mr.mr_effectivity_id = p_mr_effectivity_id
      intersect
      /* Fix for bug# 6956784. Replace CS_COUNTERS with CSI_COUNTERS_VL.
       * Use COUNTER_TEMPLATE_NAME for counter name
       * Uptake R12 Counters Changes.
      SELECT c.name
           FROM CS_COUNTERS C, CS_COUNTER_GROUPS CTRGRP, CSI_ITEM_INSTANCES CII--, MTL_SYSTEM_ITEMS_KFV MSITEM
           WHERE C.COUNTER_GROUP_ID = CTRGRP.COUNTER_GROUP_ID
           AND CTRGRP.SOURCE_OBJECT_CODE = 'CP'
           AND CTRGRP.SOURCE_OBJECT_ID = CII.INSTANCE_ID
           --AND MSITEM.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
           --AND MSITEM.ORGANIZATION_ID = CII.INV_MASTER_ORGANIZATION_ID
           AND CII.INSTANCE_ID = p_instance_id
      */
      SELECT cc.COUNTER_TEMPLATE_NAME counter_name
           FROM csi_counters_vl cc,
           csi_counter_associations cca --, CSI_ITEM_INSTANCES CII
           WHERE cc.counter_id = cca.counter_id
             and cca.source_object_code = 'CP'
             and cca.source_object_id   = p_instance_id
      MINUS
      --SELECT c.name counter_name
      SELECt c.COUNTER_TEMPLATE_NAME counter_name
           --FROM CS_COUNTERS C, ahl_unit_accomplishmnts ua
           FROM csi_counters_vl C, ahl_unit_accomplishmnts ua
           WHERE c.COUNTER_ID = UA.COUNTER_ID
        AND UA.unit_effectivity_id = p_unit_effectivity_id;

BEGIN
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Entering Match_Counters_with_FMP', 'UMP');
    AHL_DEBUG_PUB.debug('Input CSI:MR:' || p_item_instance_id || ':' || p_mr_header_id, 'UMP');
    AHL_DEBUG_PUB.debug('p_unit_effectivity_id:' || p_unit_effectivity_id, 'UMP');
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Call FMP API to get the list of effectivities for this MR_ID and item_instance_id
  AHL_FMP_PVT.GET_APPLICABLE_MRS(
    p_api_version         => 1.0,
    p_init_msg_list       => FND_API.G_FALSE,
    p_commit              => FND_API.G_FALSE,
    p_validation_level    => 20,
    x_return_status       => l_return_status,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    p_item_instance_id    => p_item_instance_id,
    p_mr_header_id        => p_mr_header_id,
    p_components_flag     => 'N',
    x_applicable_mr_tbl   => l_effectivities_tbl
  );

  -- Raise errors if exceptions occur
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- fix for bug number 6761311

  /*IF (l_effectivities_tbl.COUNT = 0) THEN
    RETURN;
  ELSE
    l_fmp_eff := '(';
    FOR i IN l_effectivities_tbl.FIRST..l_effectivities_tbl.LAST LOOP
      l_fmp_eff := l_fmp_eff || l_effectivities_tbl(i).MR_EFFECTIVITY_ID || ',';
    END LOOP;
    l_fmp_eff := rtrim(l_fmp_eff, ',') || ')';
    IF G_DEBUG='Y'  THEN
      AHL_DEBUG_PUB.debug('Match_Counters_with_FMP: Effectivities list from FMP: ' || l_fmp_eff, 'UMP');
    END IF;
  END IF;

  -- Counters for the given MR
  -- Modified from cs_counters_v to csi_counter_template_vl for R12 bug# 6080133.
  --l_fmp_sql := ' select distinct name counter_name from cs_counters_v co, ahl_mr_intervals mr';
  l_fmp_sql := ' select distinct name counter_name from csi_counter_template_vl co, ahl_mr_intervals mr';
  l_fmp_sql := l_fmp_sql || ' where co.counter_id = mr.counter_id and';
  l_fmp_sql := l_fmp_sql || ' mr.mr_effectivity_id in ' || l_fmp_eff;

  -- Counters for the given item instance
  --l_inst_sql := ' select distinct counter_name from csi_cp_counters_v';
  l_inst_sql := ' select distinct counter_template_name counter_name from csi_counters_vl cc, csi_counter_associations cca ';
  l_inst_sql := l_inst_sql || ' where cc.counter_id = cca.counter_id and cca.source_object_code = ''CP'' and cca.source_object_id = :1';

  -- Counters for the Accomplishment
  --l_acc_sql := ' select distinct counter_name from csi_cp_counters_v co, ahl_unit_accomplishmnts ua';
  l_acc_sql := ' select distinct counter_template_name counter_name from csi_counters_vl cc, ahl_unit_accomplishmnts ua';
  l_acc_sql := l_acc_sql || ' where ua.unit_effectivity_id = :2';
  l_acc_sql := l_acc_sql || ' and ua.counter_id = cc.counter_id';
  l_acc_sql := l_acc_sql || ' order by counter_name ';

  l_temp_sql_str := l_fmp_sql || ' INTERSECT ' || l_inst_sql || ' MINUS ' || l_acc_sql;
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Match_Counters_with_FMP: Final SQL: ' || l_temp_sql_str, 'UMP');

  END IF;
  OPEN l_counters_csr for l_temp_sql_str USING p_item_instance_id, p_unit_effectivity_id;
  l_counters_msg := '';
  LOOP
    FETCH l_counters_csr INTO l_temp_counter_name;
    EXIT WHEN l_counters_csr%NOTFOUND;
    l_counters_msg := l_counters_msg || l_temp_counter_name || ', ';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END LOOP;
  CLOSE l_counters_csr;
  l_counters_msg := rtrim(l_counters_msg);
  l_counters_msg := rtrim(l_counters_msg, ',');
  x_counters := l_counters_msg;*/

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Count of l_effectivities_tbl:' || l_effectivities_tbl.count , 'UMP');
    AHL_DEBUG_PUB.debug('p_unit_effectivity_id:' || p_unit_effectivity_id, 'UMP');
  END IF;

  IF (l_effectivities_tbl.COUNT = 0) THEN
      RETURN;
    ELSE
      l_counters_msg := '';
      FOR i IN l_effectivities_tbl.FIRST..l_effectivities_tbl.LAST LOOP
        FOR counter_name_rec IN get_unmatched_counter(l_effectivities_tbl(i).MR_EFFECTIVITY_ID
                        ,p_item_instance_id,p_unit_effectivity_id) LOOP
            l_counters_msg := l_counters_msg || counter_name_rec.counter_name || ', ';
            x_return_status := FND_API.G_RET_STS_ERROR;
        END LOOP;
      END LOOP;
  END IF;
  l_counters_msg := rtrim(l_counters_msg);
  l_counters_msg := rtrim(l_counters_msg, ',');
  x_counters := l_counters_msg;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('x_counters:' || x_counters, 'UMP');
    AHL_DEBUG_PUB.debug('Exiting Match_Counters_with_FMP', 'UMP');

  END IF;
END Match_Counters_with_FMP;

------------------------------------



------------------------
-- Define  Procedures --
------------------------
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


   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Terminate_MR_Instances';
   l_new_mr_header_id       NUMBER;
   l_old_mr_header_id       NUMBER;
   l_effective_to_date      DATE;
   l_effective_from_date    DATE;
   l_visit_status           VARCHAR2(30);

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(30);
   --l_old_mr_item_instance_tbl       AHL_FMP_PVT.MR_ITEM_INSTANCE_TBL_TYPE;
   l_new_mr_item_instance_tbl       AHL_FMP_PVT.MR_ITEM_INSTANCE_TBL_TYPE;




  CURSOR l_get_mr_header_id(p_mr_title IN VARCHAR2, p_version_number IN NUMBER) IS
         SELECT MR_HEADER_ID  FROM AHL_MR_HEADERS_B
         WHERE TITLE = p_mr_title AND VERSION_NUMBER = p_version_number;

  CURSOR l_get_effective_to_date(p_mr_header_id IN NUMBER) IS
     SELECT EFFECTIVE_TO, application_usg_code FROM AHL_MR_HEADERS_VL WHERE MR_HEADER_ID = p_mr_header_id;

  CURSOR l_get_effective_from_date(p_mr_header_id IN NUMBER) IS
     SELECT EFFECTIVE_FROM FROM AHL_MR_HEADERS_VL WHERE MR_HEADER_ID = p_mr_header_id;

  CURSOR l_unit_effectivity_csr(p_header_id IN NUMBER,p_mr_effective_to_date IN DATE) IS SELECT
                      EFF.UNIT_EFFECTIVITY_ID,
                      EFF.CSI_ITEM_INSTANCE_ID,
                      EFF.MR_INTERVAL_ID     ,
                      EFF.MR_EFFECTIVITY_ID  ,
                      EFF.MR_HEADER_ID       ,
                      EFF.STATUS_CODE        ,
                      EFF.DUE_DATE           ,
                      EFF.DUE_COUNTER_VALUE  ,
                      EFF.FORECAST_SEQUENCE  ,
                      EFF.REPETITIVE_MR_FLAG,
                      EFF.TOLERANCE_FLAG    ,
                      EFF.REMARKS           ,
                      EFF.MESSAGE_CODE      ,
                      EFF.PRECEDING_UE_ID    ,
                      EFF.DATE_RUN,
                      EFF.SET_DUE_DATE,
                      EFF.ACCOMPLISHED_DATE,
                      EFF.SERVICE_LINE_ID,
                      EFF.PROGRAM_MR_HEADER_ID,
                      EFF.CANCEL_REASON_CODE,
                      EFF.EARLIEST_DUE_DATE,
                      EFF.LATEST_DUE_DATE,
                      EFF.DEFER_FROM_UE_ID,
                      EFF.CS_INCIDENT_ID,
                      EFF.QA_COLLECTION_ID,
                      EFF.ORIG_DEFERRAL_UE_ID,
                      EFF.APPLICATION_USG_CODE,
                      EFF.OBJECT_TYPE,
                      EFF.COUNTER_ID,
                      EFF.MANUALLY_PLANNED_FLAG,
                      EFF.LOG_SERIES_CODE,
                      EFF.LOG_SERIES_NUMBER,
                      EFF.FLIGHT_NUMBER,
                      EFF.MEL_CDL_TYPE_CODE,
                      EFF.POSITION_PATH_ID,
                      EFF.ATA_CODE,
                      EFF.UNIT_CONFIG_HEADER_ID,
                      EFF.ATTRIBUTE_CATEGORY,
                      EFF.ATTRIBUTE1,
                      EFF.ATTRIBUTE2,
                      EFF.ATTRIBUTE3,
                      EFF.ATTRIBUTE4,
                      EFF.ATTRIBUTE5,
                      EFF.ATTRIBUTE6,
                      EFF.ATTRIBUTE7,
                      EFF.ATTRIBUTE8,
                      EFF.ATTRIBUTE9,
                      EFF.ATTRIBUTE10,
                      EFF.ATTRIBUTE11,
                      EFF.ATTRIBUTE12,
                      EFF.ATTRIBUTE13,
                      EFF.ATTRIBUTE14,
                      EFF.ATTRIBUTE15,
                      EFF.OBJECT_VERSION_NUMBER,
                      EFF.LAST_UPDATE_DATE,
                      EFF.LAST_UPDATED_BY    ,
                      EFF.LAST_UPDATE_LOGIN
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V EFF
      WHERE EFF.MR_HEADER_ID = p_header_id
        AND object_type = 'MR'
     -- AND (EFF.status_code is null or EFF.status_code in ('INIT-DUE','DEFERRED'))
        AND (EFF.status_code is null or EFF.status_code = 'INIT-DUE')
        AND not exists (select 'x' from ahl_ue_relationships where
                        related_ue_id = EFF.unit_effectivity_id)
        AND TRUNC(NVL(EFF.DUE_DATE,SYSDATE)) > TRUNC(p_mr_effective_to_date)
        FOR UPDATE NOWAIT;

   l_ue_rec                 l_unit_effectivity_csr%ROWTYPE;

   CURSOR l_ue_descendent_csr(p_effectivity_id IN NUMBER) IS SELECT
                      EFF.UNIT_EFFECTIVITY_ID,
                      EFF.CSI_ITEM_INSTANCE_ID,
                      EFF.MR_INTERVAL_ID     ,
                      EFF.MR_EFFECTIVITY_ID  ,
                      EFF.MR_HEADER_ID       ,
                      EFF.STATUS_CODE        ,
                      EFF.DUE_DATE           ,
                      EFF.DUE_COUNTER_VALUE  ,
                      EFF.FORECAST_SEQUENCE  ,
                      EFF.REPETITIVE_MR_FLAG,
                      EFF.TOLERANCE_FLAG    ,
                      EFF.REMARKS           ,
                      EFF.MESSAGE_CODE      ,
                      EFF.PRECEDING_UE_ID    ,
                      EFF.DATE_RUN,
                      EFF.SET_DUE_DATE,
                      EFF.ACCOMPLISHED_DATE,
                      EFF.SERVICE_LINE_ID,
                      EFF.PROGRAM_MR_HEADER_ID,
                      EFF.CANCEL_REASON_CODE,
                      EFF.EARLIEST_DUE_DATE,
                      EFF.LATEST_DUE_DATE,
                      EFF.DEFER_FROM_UE_ID,
                      EFF.CS_INCIDENT_ID,
                      EFF.QA_COLLECTION_ID,
                      EFF.ORIG_DEFERRAL_UE_ID,
                      EFF.APPLICATION_USG_CODE,
                      EFF.OBJECT_TYPE,
                      EFF.COUNTER_ID,
                      EFF.MANUALLY_PLANNED_FLAG,
                      EFF.LOG_SERIES_CODE,
                      EFF.LOG_SERIES_NUMBER,
                      EFF.FLIGHT_NUMBER,
                      EFF.MEL_CDL_TYPE_CODE,
                      EFF.POSITION_PATH_ID,
                      EFF.ATA_CODE,
                      EFF.UNIT_CONFIG_HEADER_ID,
                      EFF.ATTRIBUTE_CATEGORY,
                      EFF.ATTRIBUTE1,
                      EFF.ATTRIBUTE2,
                      EFF.ATTRIBUTE3,
                      EFF.ATTRIBUTE4,
                      EFF.ATTRIBUTE5,
                      EFF.ATTRIBUTE6,
                      EFF.ATTRIBUTE7,
                      EFF.ATTRIBUTE8,
                      EFF.ATTRIBUTE9,
                      EFF.ATTRIBUTE10,
                      EFF.ATTRIBUTE11,
                      EFF.ATTRIBUTE12,
                      EFF.ATTRIBUTE13,
                      EFF.ATTRIBUTE14,
                      EFF.ATTRIBUTE15,
                      EFF.OBJECT_VERSION_NUMBER,
                      EFF.LAST_UPDATE_DATE,
                      EFF.LAST_UPDATED_BY,
                      EFF.LAST_UPDATE_LOGIN
           FROM AHL_UNIT_EFFECTIVITIES_APP_V EFF
              WHERE EFF.UNIT_EFFECTIVITY_ID IN
                   (SELECT REL.RELATED_UE_ID FROM AHL_UE_RELATIONSHIPS REL
                       WHERE REL.ORIGINATOR_UE_ID = p_effectivity_id)
           FOR UPDATE NOWAIT;
                 --   AND REL.UE_ID = EFF.UNIT_EFFECTIVITY_ID;


   -- For processsing object type = 'SR'
   /*CURSOR ahl_sr_ue_csr(p_mr_header_id IN NUMBER) IS
     SELECT UE1.unit_effectivity_id
       FROM ahl_unit_effectivities_app_v UE,
            ahl_ue_relationships UER, ahl_unit_effectivities_b UE1
       WHERE UER.ue_id = UE.unit_effectivity_id
         AND UER.related_ue_id = UE1.unit_effectivity_id
         AND UE.object_type = 'SR'
         AND (UE.status_code is null or UE.status_code = 'INIT-DUE')
         AND UE1.mr_header_id = p_mr_header_id;*/-- commented for performance tuning
   /*-Start-----Above cursor go devided into two----------*/

   CURSOR  ahl_sr_ue_valid_csr(p_mr_header_id IN NUMBER,
                               p_unit_effectivity_id IN NUMBER) IS
     SELECT 'x'
     FROM ahl_unit_effectivities_app_v UE1
     WHERE UE1.unit_effectivity_id = p_unit_effectivity_id
      AND UE1.mr_header_id = p_mr_header_id;

   CURSOR ahl_sr_ue_csr IS
     SELECT UER.related_ue_id
     FROM ahl_unit_effectivities_app_v UE, ahl_ue_relationships UER
     WHERE UER.ue_id = UE.unit_effectivity_id
     AND UER.relationship_code = 'PARENT'
     AND UE.object_type = 'SR'
     AND (UE.status_code is null or UE.status_code = 'INIT-DUE');

   /*-End-----split---------------------------------------*/


   CURSOR get_descendents_csr(p_ue_id IN NUMBER) IS
     SELECT related_ue_id
     FROM ahl_ue_relationships
     START WITH ue_id = p_ue_id
        AND relationship_code = 'PARENT'
      CONNECT BY ue_id = PRIOR related_ue_id
        AND relationship_code = 'PARENT';

   l_ue_descendent_rec        l_ue_descendent_csr%ROWTYPE;
   l_application_usg_code     ahl_mr_headers_b.application_usg_code%TYPE;
   l_junk                     varchar2(1);
   --l_req_id                   number;

   CURSOR get_mr_copy_dtls_csr(p_mr_header_id IN NUMBER) IS
   SELECT COPY_INIT_ACCOMPL_FLAG, COPY_DEFERRALS_FLAG FROM AHL_MR_HEADERS_APP_V
   WHERE MR_HEADER_ID = p_mr_header_id;

   l_COPY_FIRST_DUE_FLAG VARCHAR2(1);
   l_COPY_DEFERRALS_FLAG VARCHAR2(1);

   CURSOR l_cp_ue_csr(p_header_id IN NUMBER,p_csi_item_instance_id IN NUMBER) IS SELECT
                      EFF.UNIT_EFFECTIVITY_ID,
                      EFF.CSI_ITEM_INSTANCE_ID,
                      EFF.MR_INTERVAL_ID     ,
                      EFF.MR_EFFECTIVITY_ID  ,
                      EFF.MR_HEADER_ID       ,
                      EFF.STATUS_CODE        ,
                      EFF.DUE_DATE           ,
                      EFF.DUE_COUNTER_VALUE  ,
                      EFF.FORECAST_SEQUENCE  ,
                      EFF.REPETITIVE_MR_FLAG,
                      EFF.TOLERANCE_FLAG    ,
                      EFF.REMARKS           ,
                      EFF.MESSAGE_CODE      ,
                      EFF.PRECEDING_UE_ID    ,
                      EFF.DATE_RUN,
                      EFF.SET_DUE_DATE,
                      EFF.ACCOMPLISHED_DATE,
                      EFF.SERVICE_LINE_ID,
                      EFF.PROGRAM_MR_HEADER_ID,
                      EFF.CANCEL_REASON_CODE,
                      EFF.EARLIEST_DUE_DATE,
                      EFF.LATEST_DUE_DATE,
                      EFF.DEFER_FROM_UE_ID,
                      EFF.CS_INCIDENT_ID,
                      EFF.QA_COLLECTION_ID,
                      EFF.ORIG_DEFERRAL_UE_ID,
                      EFF.APPLICATION_USG_CODE,
                      EFF.OBJECT_TYPE,
                      EFF.COUNTER_ID,
                      EFF.MANUALLY_PLANNED_FLAG,
                      EFF.LOG_SERIES_CODE,
                      EFF.LOG_SERIES_NUMBER,
                      EFF.FLIGHT_NUMBER,
                      EFF.MEL_CDL_TYPE_CODE,
                      EFF.POSITION_PATH_ID,
                      EFF.ATA_CODE,
                      EFF.UNIT_CONFIG_HEADER_ID,
                      EFF.ATTRIBUTE_CATEGORY,
                      EFF.ATTRIBUTE1,
                      EFF.ATTRIBUTE2,
                      EFF.ATTRIBUTE3,
                      EFF.ATTRIBUTE4,
                      EFF.ATTRIBUTE5,
                      EFF.ATTRIBUTE6,
                      EFF.ATTRIBUTE7,
                      EFF.ATTRIBUTE8,
                      EFF.ATTRIBUTE9,
                      EFF.ATTRIBUTE10,
                      EFF.ATTRIBUTE11,
                      EFF.ATTRIBUTE12,
                      EFF.ATTRIBUTE13,
                      EFF.ATTRIBUTE14,
                      EFF.ATTRIBUTE15,
                      EFF.OBJECT_VERSION_NUMBER,
                      EFF.LAST_UPDATE_DATE,
                      EFF.LAST_UPDATED_BY    ,
                      EFF.LAST_UPDATE_LOGIN
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V EFF
      WHERE EFF.MR_HEADER_ID = p_header_id
        AND EFF.CSI_ITEM_INSTANCE_ID = p_csi_item_instance_id
        AND object_type = 'MR'
     -- AND (EFF.status_code is null or EFF.status_code in ('INIT-DUE','DEFERRED'))
        AND (EFF.status_code  = 'MR-TERMINATE')
        AND not exists (select 'x' from ahl_ue_relationships where
                        related_ue_id = EFF.unit_effectivity_id);

l_copy_record BOOLEAN;
l_copy_ud_record BOOLEAN;

CURSOR unit_deferral_id_csr(p_unit_effectivity_id IN NUMBER) IS
SELECT unit_deferral_id from ahl_unit_deferrals_b
where UNIT_EFFECTIVITY_ID = p_unit_effectivity_id
AND UNIT_DEFERRAL_TYPE = 'INIT-DUE';

l_unit_deferral_id NUMBER;
l_unit_effectivity_id NUMBER;
l_rowid               VARCHAR2(30);




BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Terminate_MR_Instances_pvt;

  -- Enable Debug (optional)
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('Beginning Processing... ', 'UMP-TERMINATE: ');
  END IF;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('After call compatible api ', 'UMP-TERMINATE:');
    AHL_DEBUG_PUB.debug('Input Parameters:');
    AHL_DEBUG_PUB.debug('p_new_mr_header_id: ' || p_new_mr_header_id);
    AHL_DEBUG_PUB.debug('p_old_mr_header_id: ' || p_old_mr_header_id);
    AHL_DEBUG_PUB.debug('p_old_mr_title: ' || p_old_mr_title);
    AHL_DEBUG_PUB.debug('p_old_version_number: ' || p_old_version_number);
    AHL_DEBUG_PUB.debug('p_new_mr_header_id: ' || p_new_mr_header_id);
    AHL_DEBUG_PUB.debug('p_new_mr_title: ' || p_new_mr_title);
    AHL_DEBUG_PUB.debug('p_new_version_number: ' || p_new_version_number);
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing

  l_new_mr_header_id := p_new_mr_header_id;
  l_old_mr_header_id := p_old_mr_header_id;

  --resolve new mr_header_id

  IF(p_new_mr_header_id IS NULL OR p_new_mr_header_id = FND_API.G_MISS_NUM) THEN
    IF((p_new_mr_title IS NOT NULL AND p_new_mr_title <> FND_API.G_MISS_CHAR) AND
       (p_new_version_number IS NOT NULL AND p_new_version_number <> FND_API.G_MISS_NUM)) THEN

         OPEN l_get_mr_header_id(p_new_mr_title, p_new_version_number);
           FETCH l_get_mr_header_id INTO l_new_mr_header_id;
           -- IF (l_get_mr_header_id%NOTFOUND) THEN
         CLOSE l_get_mr_header_id;
     END IF;
   END IF;


  --resolve old mr_header_id

  IF(p_old_mr_header_id IS NULL OR p_old_mr_header_id = FND_API.G_MISS_NUM) THEN
    IF((p_old_mr_title IS NOT NULL AND p_old_mr_title <> FND_API.G_MISS_CHAR) AND
       (p_old_version_number IS NOT NULL AND p_old_version_number <> FND_API.G_MISS_NUM)) THEN
         OPEN l_get_mr_header_id(p_old_mr_title, p_old_version_number);
           FETCH l_get_mr_header_id INTO l_old_mr_header_id;
         CLOSE l_get_mr_header_id;
    END IF;
  END IF;

  IF (l_old_mr_header_id IS NULL) THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_TERMNT_MR_DET_MAND');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   -- RETURN;
  END IF;

/*
  IF (l_new_mr_header_id IS NULL) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_CUR_MR_DET_MAND');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   -- RETURN;
  END IF;
*/

  OPEN l_get_effective_to_date(l_old_mr_header_id);
    FETCH l_get_effective_to_date INTO l_effective_to_date, l_application_usg_code; --, l_effective_from_date;
    IF (l_get_effective_to_date%FOUND) THEN
      --check if effective to date has passed
     /* IF( TRUNC(l_effective_to_date) > TRUNC(SYSDATE)) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_EFF_TO_DATE');
        FND_MESSAGE.Set_Token('EFF_TO', l_effective_to_date);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; */

      -- Set the profile for due date calculation as the work flow user may not have this
      -- profile set.
      FND_PROFILE.PUT('AHL_APPLN_USG', l_application_usg_code);

    END IF;
  CLOSE l_get_effective_to_date;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('l_effective_to_date = ' || l_effective_to_date);
  END IF;


  IF (l_new_mr_header_id IS NOT NULL) THEN
    OPEN l_get_effective_from_date(l_new_mr_header_id);
      FETCH l_get_effective_from_date INTO l_effective_from_date;
      IF (l_get_effective_from_date%NOTFOUND) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_NOTFOUND');
         FND_MESSAGE.Set_Token('MR_ID',l_new_mr_header_id);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    CLOSE l_get_effective_from_date;
  END IF;

  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('l_effective_from_date = ' || l_effective_from_date);
  END IF;

 OPEN l_unit_effectivity_csr(l_old_mr_header_id,l_effective_to_date);
 LOOP
    FETCH l_unit_effectivity_csr INTO l_ue_rec;             --l_ue_id, l_repetitive_flag, l_status_code;

    IF G_DEBUG='Y'  THEN
      AHL_DEBUG_PUB.debug('l_ue_rec.unit_effectivity_id = ' || l_ue_rec.UNIT_EFFECTIVITY_ID);
      AHL_DEBUG_PUB.debug('l_ue_rec.mr_header_id = ' || l_ue_rec.mr_header_id);
      AHL_DEBUG_PUB.debug('l_ue_rec.object_version_number = ' || l_ue_rec.object_version_number);
    END IF;
    EXIT WHEN l_unit_effectivity_csr%NOTFOUND;


    l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status ( l_ue_rec.UNIT_EFFECTIVITY_ID);

    -- only if visit is in planning status we must mark an exception or delete.
    -- if visit is already on the floor, we do nothing.
    IF (nvl(l_visit_status,'X') NOT IN ('RELEASED','CLOSED')) THEN
      IF (l_ue_rec.REPETITIVE_MR_FLAG = 'N'
          OR l_ue_rec.STATUS_CODE = 'INIT-DUE' OR l_ue_rec.defer_from_ue_id IS NOT NULL) THEN

          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('IN if repetitive_mr_flag = N');
          END IF;
          l_ue_rec.STATUS_CODE := 'MR-TERMINATE';
          l_ue_rec.MESSAGE_CODE := 'TERMINATE-W-NEW-REV';
          l_ue_rec.ACCOMPLISHED_DATE := SYSDATE;

          IF G_DEBUG='Y'  THEN
            AHL_DEBUG_PUB.debug('before update record status to MR-TERMINATE');
           END IF;
          AHL_UNIT_EFFECTIVITIES_PKG.UPDATE_ROW (
            x_unit_effectivity_id =>        l_ue_rec.UNIT_EFFECTIVITY_ID,
            x_csi_item_instance_id =>       l_ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id =>             l_ue_rec.MR_INTERVAL_ID     ,
            x_MR_EFFECTIVITY_ID =>          l_ue_rec.MR_EFFECTIVITY_ID  ,
            x_MR_HEADER_ID =>               l_ue_rec.MR_HEADER_ID       ,
            x_STATUS_CODE =>                l_ue_rec.STATUS_CODE        ,
            x_DUE_DATE =>                   l_ue_rec.DUE_DATE           ,
            x_DUE_COUNTER_VALUE =>          l_ue_rec.DUE_COUNTER_VALUE  ,
            x_FORECAST_SEQUENCE =>          l_ue_rec.FORECAST_SEQUENCE  ,
            x_REPETITIVE_MR_FLAG =>         l_ue_rec.REPETITIVE_MR_FLAG,
            x_TOLERANCE_FLAG =>             l_ue_rec.TOLERANCE_FLAG    ,
            x_REMARKS =>                    l_ue_rec.REMARKS           ,
            x_MESSAGE_CODE =>               l_ue_rec.MESSAGE_CODE      ,
            x_PRECEDING_UE_ID =>            l_ue_rec.PRECEDING_UE_ID    ,
            x_DATE_RUN =>                   l_ue_rec.DATE_RUN,
            x_SET_DUE_DATE =>               l_ue_rec.SET_DUE_DATE,
            x_ACCOMPLISHED_DATE =>          l_ue_rec.ACCOMPLISHED_DATE,
            x_SERVICE_LINE_ID =>            l_ue_rec.SERVICE_LINE_ID,
            x_PROGRAM_MR_HEADER_ID =>       l_ue_rec.PROGRAM_MR_HEADER_ID,
            x_CANCEL_REASON_CODE =>         l_ue_rec.CANCEL_REASON_CODE,
            x_EARLIEST_DUE_DATE =>          l_ue_rec.EARLIEST_DUE_DATE,
            x_LATEST_DUE_DATE =>            l_ue_rec.LATEST_DUE_DATE,
            x_defer_from_ue_id =>           l_ue_rec.defer_from_ue_id,
            x_qa_collection_id =>           l_ue_rec.qa_collection_id,
            x_orig_deferral_ue_id =>        l_ue_rec.orig_deferral_ue_id,
            x_cs_incident_id  =>            l_ue_rec.cs_incident_id,
            x_application_usg_code =>       l_ue_rec.application_usg_code,
            x_object_type          =>       l_ue_rec.object_type,
            x_counter_id           =>       l_ue_rec.counter_id,
            x_manually_planned_flag =>      l_ue_rec.manually_planned_flag,
            X_LOG_SERIES_CODE       =>      l_ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     =>      l_ue_rec.log_series_number,
            X_FLIGHT_NUMBER         =>      l_ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     =>      l_ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      =>      l_ue_rec.position_path_id,
            X_ATA_CODE              =>      l_ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  =>     l_ue_rec.unit_config_header_id,
            x_ATTRIBUTE_CATEGORY =>         l_ue_rec.ATTRIBUTE_CATEGORY,
            x_ATTRIBUTE1 =>                 l_ue_rec.ATTRIBUTE1,
            x_ATTRIBUTE2 =>                 l_ue_rec.ATTRIBUTE2,
            x_ATTRIBUTE3 =>                 l_ue_rec.ATTRIBUTE3,
            x_ATTRIBUTE4 =>                 l_ue_rec.ATTRIBUTE4,
            x_ATTRIBUTE5 =>                 l_ue_rec.ATTRIBUTE5,
            x_ATTRIBUTE6 =>                 l_ue_rec.ATTRIBUTE6,
            x_ATTRIBUTE7 =>                 l_ue_rec.ATTRIBUTE7,
            x_ATTRIBUTE8 =>                 l_ue_rec.ATTRIBUTE8,
            x_ATTRIBUTE9 =>                 l_ue_rec.ATTRIBUTE9,
            x_ATTRIBUTE10 =>                l_ue_rec.ATTRIBUTE10,
            x_ATTRIBUTE11 =>                l_ue_rec.ATTRIBUTE11,
            x_ATTRIBUTE12 =>                l_ue_rec.ATTRIBUTE12,
            x_ATTRIBUTE13 =>                l_ue_rec.ATTRIBUTE13,
            x_ATTRIBUTE14 =>                l_ue_rec.ATTRIBUTE14,
            x_ATTRIBUTE15 =>                l_ue_rec.ATTRIBUTE15,
            x_OBJECT_VERSION_NUMBER =>      l_ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_LAST_UPDATE_DATE =>           sysdate,
            X_LAST_UPDATED_BY  =>           fnd_global.user_id,
            X_LAST_UPDATE_LOGIN  =>         fnd_global.login_id);

            IF G_DEBUG='Y'  THEN
              AHL_DEBUG_PUB.debug('After update record');
            END IF;

          --update all descendent Unit Effectivities
          OPEN l_ue_descendent_csr(l_ue_rec.UNIT_EFFECTIVITY_ID);
          LOOP
             FETCH l_ue_descendent_csr INTO l_ue_descendent_rec;
             EXIT WHEN l_ue_descendent_csr%NOTFOUND;

             IF G_DEBUG='Y'  THEN
               AHL_DEBUG_PUB.debug('descedant ue_id' || l_ue_descendent_rec.UNIT_EFFECTIVITY_ID);
             END IF;
             l_ue_descendent_rec.STATUS_CODE := 'MR-TERMINATE';
             l_ue_descendent_rec.MESSAGE_CODE := 'TERMINATE-W-NEW-REV';
             l_ue_descendent_rec.ACCOMPLISHED_DATE := SYSDATE;
             AHL_UNIT_EFFECTIVITIES_PKG.UPDATE_ROW (
               x_unit_effectivity_id =>     l_ue_descendent_rec.UNIT_EFFECTIVITY_ID,
               x_csi_item_instance_id =>    l_ue_descendent_rec.CSI_ITEM_INSTANCE_ID,
               x_mr_interval_id =>          l_ue_descendent_rec.MR_INTERVAL_ID     ,
               x_MR_EFFECTIVITY_ID =>       l_ue_descendent_rec.MR_EFFECTIVITY_ID  ,
               x_MR_HEADER_ID =>            l_ue_descendent_rec.MR_HEADER_ID       ,
               x_STATUS_CODE =>             l_ue_descendent_rec.STATUS_CODE        ,
               x_DUE_DATE =>                l_ue_descendent_rec.DUE_DATE           ,
               x_DUE_COUNTER_VALUE =>       l_ue_descendent_rec.DUE_COUNTER_VALUE  ,
               x_FORECAST_SEQUENCE =>       l_ue_descendent_rec.FORECAST_SEQUENCE  ,
               x_REPETITIVE_MR_FLAG =>      l_ue_descendent_rec.REPETITIVE_MR_FLAG,
               x_TOLERANCE_FLAG =>          l_ue_descendent_rec.TOLERANCE_FLAG    ,
               x_REMARKS =>                 l_ue_descendent_rec.REMARKS           ,
               x_MESSAGE_CODE =>            l_ue_descendent_rec.MESSAGE_CODE      ,
               x_PRECEDING_UE_ID =>         l_ue_descendent_rec.PRECEDING_UE_ID    ,
               x_DATE_RUN =>                l_ue_descendent_rec.DATE_RUN,
               x_SET_DUE_DATE =>            l_ue_descendent_rec.SET_DUE_DATE,
               x_ACCOMPLISHED_DATE =>       l_ue_descendent_rec.ACCOMPLISHED_DATE,
               x_SERVICE_LINE_ID =>         l_ue_descendent_rec.SERVICE_LINE_ID,
               x_PROGRAM_MR_HEADER_ID =>    l_ue_descendent_rec.PROGRAM_MR_HEADER_ID,
               x_CANCEL_REASON_CODE =>      l_ue_descendent_rec.CANCEL_REASON_CODE,
               x_EARLIEST_DUE_DATE =>       l_ue_descendent_rec.EARLIEST_DUE_DATE,
               x_LATEST_DUE_DATE =>         l_ue_descendent_rec.LATEST_DUE_DATE,
               x_defer_from_ue_id =>        l_ue_descendent_rec.defer_from_ue_id,
               x_qa_collection_id =>        l_ue_descendent_rec.qa_collection_id,
               x_orig_deferral_ue_id =>     l_ue_descendent_rec.orig_deferral_ue_id,
               x_cs_incident_id  =>         l_ue_descendent_rec.cs_incident_id,
               x_application_usg_code =>    l_ue_descendent_rec.application_usg_code,
               x_object_type          =>    l_ue_descendent_rec.object_type,
               x_counter_id           =>    l_ue_descendent_rec.counter_id,
               x_manually_planned_flag =>   l_ue_descendent_rec.manually_planned_flag,
               X_LOG_SERIES_CODE       =>   l_ue_descendent_rec.log_series_code,
               X_LOG_SERIES_NUMBER     =>   l_ue_descendent_rec.log_series_number,
               X_FLIGHT_NUMBER         =>   l_ue_descendent_rec.flight_number,
               X_MEL_CDL_TYPE_CODE     =>   l_ue_descendent_rec.mel_cdl_type_code,
               X_POSITION_PATH_ID      =>   l_ue_descendent_rec.position_path_id,
               X_ATA_CODE              =>   l_ue_descendent_rec.ATA_CODE,
               X_UNIT_CONFIG_HEADER_ID  =>  l_ue_descendent_rec.unit_config_header_id,
               x_ATTRIBUTE_CATEGORY =>      l_ue_descendent_rec.ATTRIBUTE_CATEGORY,
               x_ATTRIBUTE1 =>              l_ue_descendent_rec.ATTRIBUTE1,
               x_ATTRIBUTE2 =>              l_ue_descendent_rec.ATTRIBUTE2,
               x_ATTRIBUTE3 =>              l_ue_descendent_rec.ATTRIBUTE3,
               x_ATTRIBUTE4 =>              l_ue_descendent_rec.ATTRIBUTE4,
               x_ATTRIBUTE5 =>              l_ue_descendent_rec.ATTRIBUTE5,
               x_ATTRIBUTE6 =>              l_ue_descendent_rec.ATTRIBUTE6,
               x_ATTRIBUTE7 =>              l_ue_descendent_rec.ATTRIBUTE7,
               x_ATTRIBUTE8 =>              l_ue_descendent_rec.ATTRIBUTE8,
               x_ATTRIBUTE9 =>              l_ue_descendent_rec.ATTRIBUTE9,
               x_ATTRIBUTE10 =>             l_ue_descendent_rec.ATTRIBUTE10,
               x_ATTRIBUTE11 =>             l_ue_descendent_rec.ATTRIBUTE11,
               x_ATTRIBUTE12 =>             l_ue_descendent_rec.ATTRIBUTE12,
               x_ATTRIBUTE13 =>             l_ue_descendent_rec.ATTRIBUTE13,
               x_ATTRIBUTE14 =>             l_ue_descendent_rec.ATTRIBUTE14,
               x_ATTRIBUTE15 =>             l_ue_descendent_rec.ATTRIBUTE15,
               x_OBJECT_VERSION_NUMBER =>   l_ue_descendent_rec.OBJECT_VERSION_NUMBER + 1,
               x_LAST_UPDATE_DATE =>        sysdate,
               x_LAST_UPDATED_BY   =>       fnd_global.user_id,
               X_LAST_UPDATE_LOGIN  =>      fnd_global.login_id);


          END LOOP;
          CLOSE l_ue_descendent_csr;
     -- END IF;
      ELSIF (l_ue_rec.REPETITIVE_MR_FLAG = 'Y') THEN
         IF (nvl(l_visit_status,'X') =  'PLANNING') THEN

            IF G_DEBUG='Y'  THEN
              AHL_DEBUG_PUB.debug('In repetitive_mr_flag = Y');
            END IF;
            l_ue_rec.STATUS_CODE := 'EXCEPTION';
            l_ue_rec.MESSAGE_CODE := 'TERMINATE-W-NEW-REV';
            l_ue_rec.ACCOMPLISHED_DATE := SYSDATE;

            IF G_DEBUG='Y'  THEN
              AHL_DEBUG_PUB.debug('Before update record status to EXCEPTION');
            END IF;
            AHL_UNIT_EFFECTIVITIES_PKG.UPDATE_ROW (
            x_unit_effectivity_id =>        l_ue_rec.UNIT_EFFECTIVITY_ID,
            x_csi_item_instance_id =>       l_ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id =>             l_ue_rec.MR_INTERVAL_ID     ,
            x_MR_EFFECTIVITY_ID =>          l_ue_rec.MR_EFFECTIVITY_ID  ,
            x_MR_HEADER_ID =>               l_ue_rec.MR_HEADER_ID       ,
            x_STATUS_CODE =>                l_ue_rec.STATUS_CODE        ,
            x_DUE_DATE =>                   l_ue_rec.DUE_DATE           ,
            x_DUE_COUNTER_VALUE =>          l_ue_rec.DUE_COUNTER_VALUE  ,
            x_FORECAST_SEQUENCE =>          l_ue_rec.FORECAST_SEQUENCE  ,
            x_REPETITIVE_MR_FLAG =>         l_ue_rec.REPETITIVE_MR_FLAG,
            x_TOLERANCE_FLAG =>             l_ue_rec.TOLERANCE_FLAG    ,
            x_REMARKS =>                    l_ue_rec.REMARKS           ,
            x_MESSAGE_CODE =>               l_ue_rec.MESSAGE_CODE      ,
            x_PRECEDING_UE_ID =>            l_ue_rec.PRECEDING_UE_ID    ,
            x_DATE_RUN =>                   l_ue_rec.DATE_RUN,
            x_SET_DUE_DATE =>               l_ue_rec.SET_DUE_DATE,
            x_ACCOMPLISHED_DATE =>          l_ue_rec.ACCOMPLISHED_DATE,
            x_SERVICE_LINE_ID =>            l_ue_rec.SERVICE_LINE_ID,
            x_PROGRAM_MR_HEADER_ID =>       l_ue_rec.PROGRAM_MR_HEADER_ID,
            x_CANCEL_REASON_CODE =>         l_ue_rec.CANCEL_REASON_CODE,
            x_EARLIEST_DUE_DATE =>          l_ue_rec.EARLIEST_DUE_DATE,
            x_LATEST_DUE_DATE =>            l_ue_rec.LATEST_DUE_DATE,
            x_defer_from_ue_id =>           l_ue_rec.defer_from_ue_id,
            x_qa_collection_id =>           l_ue_rec.qa_collection_id,
            x_orig_deferral_ue_id =>        l_ue_rec.orig_deferral_ue_id,
            x_cs_incident_id  =>            l_ue_rec.cs_incident_id,
            x_application_usg_code =>       l_ue_rec.application_usg_code,
            x_object_type          =>       l_ue_rec.object_type,
            x_counter_id           =>       l_ue_rec.counter_id,
            x_manually_planned_flag =>      l_ue_rec.manually_planned_flag,
            X_LOG_SERIES_CODE       =>      l_ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     =>      l_ue_rec.log_series_number,
            X_FLIGHT_NUMBER         =>      l_ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     =>      l_ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      =>      l_ue_rec.position_path_id,
            X_ATA_CODE              =>      l_ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  =>     l_ue_rec.unit_config_header_id,
            x_ATTRIBUTE_CATEGORY =>         l_ue_rec.ATTRIBUTE_CATEGORY,
            x_ATTRIBUTE1 =>                 l_ue_rec.ATTRIBUTE1,
            x_ATTRIBUTE2 =>                 l_ue_rec.ATTRIBUTE2,
            x_ATTRIBUTE3 =>                 l_ue_rec.ATTRIBUTE3,
            x_ATTRIBUTE4 =>                 l_ue_rec.ATTRIBUTE4,
            x_ATTRIBUTE5 =>                 l_ue_rec.ATTRIBUTE5,
            x_ATTRIBUTE6 =>                 l_ue_rec.ATTRIBUTE6,
            x_ATTRIBUTE7 =>                 l_ue_rec.ATTRIBUTE7,
            x_ATTRIBUTE8 =>                 l_ue_rec.ATTRIBUTE8,
            x_ATTRIBUTE9 =>                 l_ue_rec.ATTRIBUTE9,
            x_ATTRIBUTE10 =>                l_ue_rec.ATTRIBUTE10,
            x_ATTRIBUTE11 =>                l_ue_rec.ATTRIBUTE11,
            x_ATTRIBUTE12 =>                l_ue_rec.ATTRIBUTE12,
            x_ATTRIBUTE13 =>                l_ue_rec.ATTRIBUTE13,
            x_ATTRIBUTE14 =>                l_ue_rec.ATTRIBUTE14,
            x_ATTRIBUTE15 =>                l_ue_rec.ATTRIBUTE15,
            x_OBJECT_VERSION_NUMBER =>      l_ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_LAST_UPDATE_DATE =>           sysdate, --l_ue_rec.LAST_UPDATE_DATE,
            x_LAST_UPDATED_BY  =>           fnd_global.user_id, --l_ue_rec.LAST_UPDATED_BY,
            x_LAST_UPDATE_LOGIN  =>         fnd_global.login_id); -- l_ue_rec.LAST_UPDATE_LOGIN );


            IF G_DEBUG='Y'  THEN
              AHL_DEBUG_PUB.debug('After update record');
            END IF;
             --update all descendent Unit Effectivities
            OPEN l_ue_descendent_csr(l_ue_rec.UNIT_EFFECTIVITY_ID);
            LOOP
             FETCH l_ue_descendent_csr INTO l_ue_descendent_rec;
             EXIT WHEN l_ue_descendent_csr%NOTFOUND;
             l_ue_descendent_rec.STATUS_CODE := 'EXCEPTION';
             --l_ue_descendent_rec.MESSAGE_CODE := 'TERMINATE-W-NEW-REV';
             l_ue_descendent_rec.ACCOMPLISHED_DATE := SYSDATE;

              IF G_DEBUG='Y'  THEN
                AHL_DEBUG_PUB.debug('start update status to Exception descedant ue_id' || l_ue_descendent_rec.UNIT_EFFECTIVITY_ID);
              END IF;
             AHL_UNIT_EFFECTIVITIES_PKG.UPDATE_ROW (
               x_unit_effectivity_id =>     l_ue_descendent_rec.UNIT_EFFECTIVITY_ID,
               x_csi_item_instance_id =>    l_ue_descendent_rec.CSI_ITEM_INSTANCE_ID,
               x_mr_interval_id =>          l_ue_descendent_rec.MR_INTERVAL_ID     ,
               x_MR_EFFECTIVITY_ID =>       l_ue_descendent_rec.MR_EFFECTIVITY_ID  ,
               x_MR_HEADER_ID =>            l_ue_descendent_rec.MR_HEADER_ID       ,
               x_STATUS_CODE =>             l_ue_descendent_rec.STATUS_CODE        ,
               x_DUE_DATE =>                l_ue_descendent_rec.DUE_DATE           ,
               x_DUE_COUNTER_VALUE =>       l_ue_descendent_rec.DUE_COUNTER_VALUE  ,
               x_FORECAST_SEQUENCE =>       l_ue_descendent_rec.FORECAST_SEQUENCE  ,
               x_REPETITIVE_MR_FLAG =>      l_ue_descendent_rec.REPETITIVE_MR_FLAG,
               x_TOLERANCE_FLAG =>          l_ue_descendent_rec.TOLERANCE_FLAG    ,
               x_REMARKS =>                 l_ue_descendent_rec.REMARKS           ,
               x_MESSAGE_CODE =>            l_ue_descendent_rec.MESSAGE_CODE      ,
               x_PRECEDING_UE_ID =>         l_ue_descendent_rec.PRECEDING_UE_ID    ,
               x_DATE_RUN =>                l_ue_descendent_rec.DATE_RUN,
               x_SET_DUE_DATE =>            l_ue_descendent_rec.SET_DUE_DATE,
               x_ACCOMPLISHED_DATE =>       l_ue_descendent_rec.ACCOMPLISHED_DATE,
               x_SERVICE_LINE_ID =>         l_ue_descendent_rec.SERVICE_LINE_ID,
               x_PROGRAM_MR_HEADER_ID =>    l_ue_descendent_rec.PROGRAM_MR_HEADER_ID,
               x_CANCEL_REASON_CODE =>      l_ue_descendent_rec.CANCEL_REASON_CODE,
               x_EARLIEST_DUE_DATE =>       l_ue_descendent_rec.EARLIEST_DUE_DATE,
               x_LATEST_DUE_DATE =>         l_ue_descendent_rec.LATEST_DUE_DATE,
               x_defer_from_ue_id =>        l_ue_descendent_rec.defer_from_ue_id,
               x_qa_collection_id =>        l_ue_descendent_rec.qa_collection_id,
               x_orig_deferral_ue_id =>     l_ue_descendent_rec.orig_deferral_ue_id,
               x_cs_incident_id  =>         l_ue_descendent_rec.cs_incident_id,
               x_application_usg_code =>    l_ue_descendent_rec.application_usg_code,
               x_object_type          =>    l_ue_descendent_rec.object_type,
               x_counter_id         =>      l_ue_descendent_rec.counter_id,
               x_manually_planned_flag =>   l_ue_descendent_rec.manually_planned_flag,
               X_LOG_SERIES_CODE       =>   l_ue_descendent_rec.log_series_code,
               X_LOG_SERIES_NUMBER     =>   l_ue_descendent_rec.log_series_number,
               X_FLIGHT_NUMBER         =>   l_ue_descendent_rec.flight_number,
               X_MEL_CDL_TYPE_CODE     =>   l_ue_descendent_rec.mel_cdl_type_code,
               X_POSITION_PATH_ID      =>   l_ue_descendent_rec.position_path_id,
               X_ATA_CODE              =>   l_ue_descendent_rec.ATA_CODE,
               X_UNIT_CONFIG_HEADER_ID  =>  l_ue_descendent_rec.unit_config_header_id,
               x_ATTRIBUTE_CATEGORY =>      l_ue_descendent_rec.ATTRIBUTE_CATEGORY,
               x_ATTRIBUTE1 =>              l_ue_descendent_rec.ATTRIBUTE1,
               x_ATTRIBUTE2 =>              l_ue_descendent_rec.ATTRIBUTE2,
               x_ATTRIBUTE3 =>              l_ue_descendent_rec.ATTRIBUTE3,
               x_ATTRIBUTE4 =>              l_ue_descendent_rec.ATTRIBUTE4,
               x_ATTRIBUTE5 =>              l_ue_descendent_rec.ATTRIBUTE5,
               x_ATTRIBUTE6 =>              l_ue_descendent_rec.ATTRIBUTE6,
               x_ATTRIBUTE7 =>              l_ue_descendent_rec.ATTRIBUTE7,
               x_ATTRIBUTE8 =>              l_ue_descendent_rec.ATTRIBUTE8,
               x_ATTRIBUTE9 =>              l_ue_descendent_rec.ATTRIBUTE9,
               x_ATTRIBUTE10 =>             l_ue_descendent_rec.ATTRIBUTE10,
               x_ATTRIBUTE11 =>             l_ue_descendent_rec.ATTRIBUTE11,
               x_ATTRIBUTE12 =>             l_ue_descendent_rec.ATTRIBUTE12,
               x_ATTRIBUTE13 =>             l_ue_descendent_rec.ATTRIBUTE13,
               x_ATTRIBUTE14 =>             l_ue_descendent_rec.ATTRIBUTE14,
               x_ATTRIBUTE15 =>             l_ue_descendent_rec.ATTRIBUTE15,
               x_OBJECT_VERSION_NUMBER =>   l_ue_descendent_rec.OBJECT_VERSION_NUMBER + 1,
               x_LAST_UPDATE_DATE =>        sysdate, --l_ue_descendent_rec.LAST_UPDATE_DATE,
               x_LAST_UPDATED_BY =>         fnd_global.user_id, --l_ue_descendent_rec.LAST_UPDATED_BY    ,
               x_LAST_UPDATE_LOGIN =>       fnd_global.login_id); --l_ue_descendent_rec.LAST_UPDATE_LOGIN );
            END LOOP;
            CLOSE l_ue_descendent_csr;

        ELSE
            AHL_UNIT_EFFECTIVITIES_PKG.Delete_Row(l_ue_rec.UNIT_EFFECTIVITY_ID);

            --Delete Descendants effectivities
            OPEN l_ue_descendent_csr(l_ue_rec.UNIT_EFFECTIVITY_ID);
            LOOP
              FETCH l_ue_descendent_csr INTO l_ue_descendent_rec;
              EXIT WHEN l_ue_descendent_csr%NOTFOUND;

               IF G_DEBUG='Y'  THEN
                 AHL_DEBUG_PUB.debug('start delete descedant ue_id' ||l_ue_descendent_rec.UNIT_EFFECTIVITY_ID);
                END IF;
              AHL_UNIT_EFFECTIVITIES_PKG.Delete_Row(l_ue_descendent_rec.UNIT_EFFECTIVITY_ID);
            END LOOP;
            CLOSE l_ue_descendent_csr;

        END IF;
      END IF;   -- end if mr_repetitive_flag = 'Y'
    END IF;  -- visit status.
  END LOOP;

   CLOSE l_unit_effectivity_csr;

   IF G_DEBUG='Y'  THEN
     AHL_DEBUG_PUB.debug('Start of Processing SRs');
   END IF;

   -- Process for SRs.
   FOR ahl_sr_ue_rec IN ahl_sr_ue_csr LOOP
    OPEN ahl_sr_ue_valid_csr(l_old_mr_header_id, ahl_sr_ue_rec.RELATED_UE_ID);
    FETCH ahl_sr_ue_valid_csr INTO l_junk;
    IF(ahl_sr_ue_valid_csr%FOUND)THEN
      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('Found ue:' || ahl_sr_ue_rec.RELATED_UE_ID);
      END IF;

     l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status ( ahl_sr_ue_rec.RELATED_UE_ID);

     -- only if visit is in planning status we must mark it for termination.
     -- if visit is already on the floor, we do nothing.
     IF (nvl(l_visit_status,'X') NOT IN ('RELEASED','CLOSED')) THEN

       IF G_DEBUG='Y'  THEN
         AHL_DEBUG_PUB.debug('Processing ue:' || ahl_sr_ue_rec.RELATED_UE_ID || ' for termination');
       END IF;

       MR_Terminate (ahl_sr_ue_rec.RELATED_UE_ID);

       -- For child MRs.
       FOR descendent_rec IN get_descendents_csr(ahl_sr_ue_rec.RELATED_UE_ID) LOOP
         MR_Terminate (descendent_rec.related_ue_id);
       END LOOP;

     END IF; -- Visit status.
    END IF;--end of if found
    CLOSE ahl_sr_ue_valid_csr;
   END LOOP;

   -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     x_return_status := 'U';
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(l_new_mr_header_id  IS NOT NULL)THEN
    UPDATE AHL_MR_HEADERS_B
    SET TERMINATION_REQUIRED_FLAG = 'N'
    WHERE MR_HEADER_ID=l_old_mr_header_id;

    OPEN get_mr_copy_dtls_csr(l_new_mr_header_id);
    FETCH get_mr_copy_dtls_csr INTO l_COPY_FIRST_DUE_FLAG,l_COPY_DEFERRALS_FLAG;
    CLOSE get_mr_copy_dtls_csr;
    IF(l_COPY_FIRST_DUE_FLAG = 'Y' OR l_COPY_DEFERRALS_FLAG = 'Y') THEN
      AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS(
            p_api_version          =>  1.0,
            p_init_msg_list        =>  FND_API.G_FALSE,
            p_commit               =>  FND_API.G_FALSE,
            p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_mr_header_id         => l_new_mr_header_id,
            p_mr_effectivity_id    => NULL,
            p_top_node_flag        => 'N',
            p_unique_inst_flag     => 'N',
            p_sort_flag            => 'N',
            x_mr_item_inst_tbl     =>  l_new_mr_item_instance_tbl
      );
      IF(l_return_status = 'U') THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF(l_return_status = 'E') THEN
       RAISE  FND_API.G_EXC_ERROR;
      END IF;

      IF (l_new_mr_item_instance_tbl.COUNT) > 0 THEN
         FOR i IN l_new_mr_item_instance_tbl.FIRST..l_new_mr_item_instance_tbl.LAST LOOP
            FOR cp_ue_rec IN l_cp_ue_csr(l_old_mr_header_id,l_new_mr_item_instance_tbl(i).ITEM_INSTANCE_ID) LOOP
               l_copy_record := FALSE;
               l_copy_ud_record := FALSE;
               IF(NVL(l_COPY_DEFERRALS_FLAG,'N') = 'N') THEN
                  cp_ue_rec.DEFER_FROM_UE_ID := NULL;
                  cp_ue_rec.ORIG_DEFERRAL_UE_ID := NULL;
               ELSE
                  IF cp_ue_rec.DEFER_FROM_UE_ID IS NOT NULL THEN
                    l_copy_record := TRUE;
                  END IF;
               END IF;

               cp_ue_rec.status_code := NULL;
               l_unit_deferral_id := NULL;

               IF(NVL(l_COPY_FIRST_DUE_FLAG,'N') = 'Y') THEN
                 -- check whether init due data exists
                  OPEN unit_deferral_id_csr(cp_ue_rec.unit_effectivity_id);
                  FETCH unit_deferral_id_csr INTO l_unit_deferral_id;
                  IF(unit_deferral_id_csr%FOUND)THEN
                    l_copy_record := TRUE;
                    l_copy_ud_record := TRUE;
                    cp_ue_rec.status_code := 'INIT-DUE';
                  END IF;
                  CLOSE unit_deferral_id_csr;
               END IF;

               IF(l_copy_record)THEN
                 AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
                    X_ROWID               =>  l_rowid,
                    X_UNIT_EFFECTIVITY_ID =>   l_unit_effectivity_id,
                    X_CSI_ITEM_INSTANCE_ID  => cp_ue_rec.csi_item_instance_id,
                    X_MR_INTERVAL_ID        => cp_ue_rec.mr_interval_id,
                    X_MR_EFFECTIVITY_ID     => cp_ue_rec.mr_effectivity_id,
                    X_MR_HEADER_ID          => l_new_mr_header_id,
                    X_STATUS_CODE           => cp_ue_rec.status_code, /* status_code */
                    X_DUE_DATE              => cp_ue_rec.due_date,
                    X_DUE_COUNTER_VALUE     => cp_ue_rec.due_counter_value,
                    X_FORECAST_SEQUENCE     => cp_ue_rec.forecast_sequence,
                    X_REPETITIVE_MR_FLAG    => cp_ue_rec.repetitive_mr_flag,
                    X_TOLERANCE_FLAG        => cp_ue_rec.tolerance_flag,
                    X_REMARKS               => null, /* remarks */
                    X_MESSAGE_CODE          => null,
                    X_PRECEDING_UE_ID       => null, /* p_x_temp_mr_rec.preceding_ue_id */
                    X_DATE_RUN              => sysdate, /* date_run */
                    X_SET_DUE_DATE          => cp_ue_rec.set_due_date,
                    X_ACCOMPLISHED_DATE     => null, /* accomplished date */
                    X_SERVICE_LINE_ID       => cp_ue_rec.service_line_id,
                    X_PROGRAM_MR_HEADER_ID  => cp_ue_rec.program_mr_header_id,
                    X_CANCEL_REASON_CODE    => null, /* cancel_reason_code */
                    X_EARLIEST_DUE_DATE     => cp_ue_rec.earliest_due_date,
                    X_LATEST_DUE_DATE       => cp_ue_rec.latest_due_date,
                    X_defer_from_ue_id      => cp_ue_rec.DEFER_FROM_UE_ID,
                    X_cs_incident_id        => null,
                    X_qa_collection_id      => null,
                    X_orig_deferral_ue_id   => cp_ue_rec.ORIG_DEFERRAL_UE_ID,
                    X_application_usg_code  => cp_ue_rec.APPLICATION_USG_CODE,
                    X_object_type           => 'MR',
                    X_counter_id            => cp_ue_rec.counter_id,
                    X_MANUALLY_PLANNED_FLAG => cp_ue_rec.MANUALLY_PLANNED_FLAG,
                    X_LOG_SERIES_CODE       => cp_ue_rec.LOG_SERIES_CODE,
                    X_LOG_SERIES_NUMBER     => cp_ue_rec.LOG_SERIES_NUMBER,
                    X_FLIGHT_NUMBER         => cp_ue_rec.FLIGHT_NUMBER,
                    X_MEL_CDL_TYPE_CODE     => cp_ue_rec.MEL_CDL_TYPE_CODE,
                    X_POSITION_PATH_ID      => cp_ue_rec.POSITION_PATH_ID,
                    X_ATA_CODE              => cp_ue_rec.ATA_CODE,
                    X_UNIT_CONFIG_HEADER_ID  => cp_ue_rec.UNIT_CONFIG_HEADER_ID,
                    X_ATTRIBUTE_CATEGORY    => cp_ue_rec.ATTRIBUTE_CATEGORY,
                    X_ATTRIBUTE1            => cp_ue_rec.ATTRIBUTE1,
                    X_ATTRIBUTE2            =>  cp_ue_rec.ATTRIBUTE2,
                    X_ATTRIBUTE3            =>  cp_ue_rec.ATTRIBUTE3,
                    X_ATTRIBUTE4            => cp_ue_rec.ATTRIBUTE4,
                    X_ATTRIBUTE5            =>  cp_ue_rec.ATTRIBUTE5,
                    X_ATTRIBUTE6            =>  cp_ue_rec.ATTRIBUTE6,
                    X_ATTRIBUTE7            =>  cp_ue_rec.ATTRIBUTE7,
                    X_ATTRIBUTE8            =>  cp_ue_rec.ATTRIBUTE8,
                    X_ATTRIBUTE9            =>  cp_ue_rec.ATTRIBUTE9,
                    X_ATTRIBUTE10           =>  cp_ue_rec.ATTRIBUTE10,
                    X_ATTRIBUTE11           =>  cp_ue_rec.ATTRIBUTE11,
                    X_ATTRIBUTE12           =>  cp_ue_rec.ATTRIBUTE12,
                    X_ATTRIBUTE13           =>  cp_ue_rec.ATTRIBUTE13,
                    X_ATTRIBUTE14           =>  cp_ue_rec.ATTRIBUTE14,
                    X_ATTRIBUTE15           =>  cp_ue_rec.ATTRIBUTE15,
                    X_OBJECT_VERSION_NUMBER => 1, /* object version */
                    X_CREATION_DATE         => sysdate,
                    X_CREATED_BY            => fnd_global.user_id,
                    X_LAST_UPDATE_DATE      => sysdate,
                    X_LAST_UPDATED_BY       => fnd_global.user_id,
                    X_LAST_UPDATE_LOGIN     => fnd_global.login_id );
                 IF(l_copy_ud_record)THEN
                   Update AHL_UNIT_DEFERRALS_B SET UNIT_EFFECTIVITY_ID = l_unit_effectivity_id,
                          last_update_date = sysdate,
                          object_version_number = object_version_number + 1,
                          LAST_UPDATED_BY = fnd_global.user_id,
                          LAST_UPDATE_LOGIN = fnd_global.login_id
                   WHERE unit_deferral_id = l_unit_deferral_id;
                 END IF;
               END IF;
             END LOOP;
            END LOOP;
           END IF; -- call fmp if
      END IF; -- count > 0
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
      IF G_DEBUG='Y'  THEN
        AHL_DEBUG_PUB.debug('Committed Changes', 'UMP');
      END IF;
  END IF;

  /* commented call from here as BUE api commits. Launching concurrent program instead.
  IF (l_new_mr_header_id IS NOT NULL AND trunc(l_effective_from_date) <= trunc(sysdate)) THEN
      AHL_UMP_UNITMAINT_PVT.Build_UnitEffectivity (
            p_init_msg_list          =>  FND_API.G_FALSE,
            p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
            p_default                   =>    FND_API.G_TRUE,
            p_module_type          =>  NULL,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_mr_header_id          => l_new_mr_header_id
          ) ;

    IF(l_return_status = 'U') THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF(l_return_status = 'E') THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

  END IF;
  */

  -- launch concurrent program to build UEs for applicable old and new MRs.
  -- commenting the cc pgm - modified for FP bug# 7414814
  /*
  l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE, l_old_mr_header_id,
                                         l_new_mr_header_id);
  IF (l_req_id = 0 OR l_req_id IS NULL) THEN
    IF G_debug = 'Y' THEN
      AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
    END IF;
  END IF;
  */

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Terminate_MR_Instances_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Terminate_MR_Instances_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   -- Disable debug
   AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Terminate_MR_Instances_pvt;
    IF (SQLCODE = -54) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_UMP_RECORD_LOCKED');
     FND_MSG_PUB.ADD;
    ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Terminate_MR_Instances_pvt',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
      END IF;
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


    -- Disable debug
    AHL_DEBUG_PUB.disable_debug;

END TERMINATE_MR_INSTANCES;


------------------------------
-- Define Local Procedures --
------------------------------
PROCEDURE Convert_MRID (p_x_mr_id        IN OUT NOCOPY  NUMBER,
                        p_mr_title       IN             VARCHAR2,
                        p_version_number IN             NUMBER)
IS

  -- For case where title and version is known.
  CURSOR ahl_mr_headers_csr (p_title          IN  VARCHAR2,
                             p_version_number IN  NUMBER) IS
    /*SELECT mr_header_id, effective_to
    FROM   ahl_mr_headers_v
    WHERE title = p_title
          AND version_number = p_version_number;*/
    SELECT mr_header_id, effective_to
    FROM   ahl_mr_headers_app_v
    WHERE title = p_title
          AND version_number = p_version_number;

  -- local variables.
  l_mr_id  NUMBER;
  l_effective_to ahl_mr_headers_app_v.EFFECTIVE_TO%TYPE;
  l_mr_title  ahl_mr_headers_app_v.TITLE%TYPE;
  l_version_number ahl_mr_headers_app_v.VERSION_NUMBER%TYPE;

BEGIN

  IF (p_x_mr_id IS NULL OR p_x_mr_id = FND_API.G_MISS_NUM) THEN
     IF (p_mr_title IS NOT NULL AND p_mr_title <> FND_API.G_MISS_CHAR) AND
        (p_version_number IS NOT NULL AND p_version_number <> FND_API.G_MISS_NUM) THEN
        OPEN ahl_mr_headers_csr(p_mr_title, p_version_number);
        FETCH ahl_mr_headers_csr INTO l_mr_id, l_effective_to;
        IF (ahl_mr_headers_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name ('AHL','AHL_UMP_PUE_TITLE_INVALID');
          FND_MESSAGE.Set_Token('TITLE',p_mr_title);
          FND_MESSAGE.Set_Token('VERSION',p_version_number);
          FND_MSG_PUB.ADD;
        ELSIF (trunc(l_effective_to) < trunc(sysdate)) THEN
          FND_MESSAGE.Set_Name ('AHL','AHL_UMP_PUE_MR_EXPIRED');
          FND_MESSAGE.Set_Token('TITLE',p_mr_title);
          FND_MESSAGE.Set_Token('VERSION',p_version_number);
          FND_MSG_PUB.ADD;
        ELSE
          p_x_mr_id := l_mr_id;
        END IF;
        CLOSE ahl_mr_headers_csr;
     END IF;
  END IF;

END Convert_MRID;

PROCEDURE Convert_Unit (p_x_uc_header_id  IN OUT NOCOPY  NUMBER,
                        p_unit_name       IN             VARCHAR2)
IS

  CURSOR ahl_uc_headers_csr(p_unit_name IN VARCHAR2) IS
    SELECT unit_config_header_id
    FROM   ahl_unit_config_headers
    WHERE  name = p_unit_name;

  l_uc_header_id  NUMBER;
  l_junk          VARCHAR2(1);

BEGIN

 IF (p_x_uc_header_id IS NULL OR p_x_uc_header_id = FND_API.G_MISS_NUM) THEN
    IF (p_unit_name IS NOT NULL AND p_unit_name <> FND_API.G_MISS_CHAR) THEN
      OPEN ahl_uc_headers_csr(p_unit_name);
      FETCH ahl_uc_headers_csr INTO l_uc_header_id;
      IF (ahl_uc_headers_csr%NOTFOUND) THEN
         FND_MESSAGE.Set_Name ('AHL','AHL_UMP_PUE_UNIT_INVALID');
         FND_MESSAGE.Set_Token('NAME',p_unit_name);
         FND_MSG_PUB.ADD;
      ELSE
         p_x_uc_header_id := l_uc_header_id;
      END IF;
    END IF;
  END IF;

END Convert_Unit;

PROCEDURE Convert_Instance (p_x_csi_item_instance_id  IN OUT NOCOPY  NUMBER,
                            p_csi_instance_number     IN             VARCHAR2)
IS

  CURSOR csi_item_instances_csr(p_csi_instance_number IN VARCHAR2) IS
    SELECT instance_id
    FROM   csi_item_instances
    WHERE  instance_number = p_csi_instance_number;
    -- bypass validation to fix bug# 8861642
    --AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  l_csi_item_instance_id  NUMBER;

BEGIN

  IF (p_x_csi_item_instance_id IS NULL OR
      p_x_csi_item_instance_id = FND_API.G_MISS_NUM) THEN
    IF (p_csi_instance_number IS NOT NULL AND
        p_csi_instance_number <> FND_API.G_MISS_CHAR) THEN
      -- get instance_id.
      OPEN csi_item_instances_csr (p_csi_instance_number);
      FETCH csi_item_instances_csr INTO l_csi_item_instance_id;
      IF (csi_item_instances_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name ('AHL','AHL_UMP_PUE_INST_NOTFOUND');
        FND_MESSAGE.Set_Token('NUMBER',p_csi_instance_number);
        FND_MSG_PUB.ADD;
      ELSE
        p_x_csi_item_instance_id := l_csi_item_instance_id;
      END IF;
      CLOSE csi_item_instances_csr;
    END IF;
  END IF;

END Convert_Instance;

-------------------------------
-- Validate input parameters.
Procedure Validate_Input_Parameters (p_mr_header_id  IN  NUMBER,
                                     p_x_csi_item_instance_id IN OUT NOCOPY NUMBER,
                                     p_unit_config_header_id  IN  NUMBER)
IS

  -- To validate mr id.
  CURSOR ahl_mr_headers_csr(p_mr_header_id   IN  NUMBER) IS
    SELECT title, version_number, effective_to, effective_from
    FROM  ahl_mr_headers_app_v
    WHERE mr_header_id = p_mr_header_id;

  -- To validate instance.
  CURSOR csi_item_instances_csr(p_csi_item_instance_id IN  NUMBER) IS
    SELECT instance_number --, active_end_date
    FROM csi_item_instances
    WHERE instance_id = p_csi_item_instance_id;

  -- To validate unit.
  CURSOR ahl_unit_config_headers_csr (p_uc_header_id IN NUMBER) IS
    SELECT name, active_start_date, active_end_date, csi_item_instance_id
    FROM  ahl_unit_config_headers
    WHERE unit_config_header_id = p_uc_header_id;

  l_effective_from ahl_mr_headers_app_v.EFFECTIVE_FROM%TYPE;
  l_effective_to   ahl_mr_headers_app_v.EFFECTIVE_TO%TYPE;
  l_mr_title       ahl_mr_headers_app_v.TITLE%TYPE;
  l_version_number ahl_mr_headers_app_v.VERSION_NUMBER%TYPE;
  l_csi_item_instance_id  NUMBER;
  l_active_end_date       DATE;
  l_active_start_date     DATE;
  l_name                  ahl_unit_config_headers.name%TYPE;
  l_instance_number       csi_item_instances.instance_number%TYPE;

BEGIN

  -- validate mr id.
  IF (p_mr_header_id IS NOT NULL) THEN
    OPEN ahl_mr_headers_csr (p_mr_header_id);
    FETCH ahl_mr_headers_csr INTO l_mr_title, l_version_number,
                                  l_effective_to, l_effective_from;
    IF (ahl_mr_headers_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_NOTFOUND');
      FND_MESSAGE.Set_Token('MR_ID',p_mr_header_id);
      FND_MSG_PUB.ADD;
      CLOSE ahl_mr_headers_csr;
      --dbms_output.put_line('MR not found.');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( trunc(l_effective_from) > trunc(sysdate) OR
            trunc(sysdate) > trunc(l_effective_to)) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_EXPIRED');
    FND_MESSAGE.Set_Token('TITLE',l_mr_title);
      FND_MESSAGE.Set_Token('VERSION',l_version_number);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('MR is not valid for today.');
    END IF;

    CLOSE ahl_mr_headers_csr;
  END IF;

  -- validate item instance.
  IF (p_x_csi_item_instance_id IS NOT NULL) THEN
    OPEN csi_item_instances_csr (p_x_csi_item_instance_id);
    FETCH csi_item_instances_csr INTO l_instance_number; --, l_active_end_date;
    IF (csi_item_instances_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INSTID_NOTFOUND');
      FND_MESSAGE.Set_Token('INST_ID', p_x_csi_item_instance_id);
      FND_MSG_PUB.ADD;
      CLOSE csi_item_instances_csr;
      --dbms_output.put_line('Instance not found');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    /* Bypass validation to fix bug# 8567880. If instance is expired, delete UMP.
       Done in procedure process_unit.
    ELSIF (trunc(l_active_end_date) < trunc(sysdate)) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INST_EXPIRED');
      FND_MESSAGE.Set_Token('NUMBER', l_instance_number);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Instance has expired');
    */
    END IF;
    CLOSE csi_item_instances_csr;
  END IF;

  -- Validate unit config id.
  IF (p_unit_config_header_id IS NOT NULL) THEN
     OPEN ahl_unit_config_headers_csr (p_unit_config_header_id);
     FETCH ahl_unit_config_headers_csr INTO l_name, l_active_start_date,
                     l_active_end_date, l_csi_item_instance_id;
     IF (ahl_unit_config_headers_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UNIT_NOTFOUND');
       FND_MESSAGE.Set_Token('UNIT_ID',p_unit_config_header_id);
       FND_MSG_PUB.ADD;
       --dbms_output.put_line('Unit not found');
       CLOSE ahl_unit_config_headers_csr;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       -- Dates obsoleted 11.5.10.
--     ELSIF (trunc(l_active_start_date) > trunc(sysdate) OR
--            trunc(sysdate) > trunc(l_active_end_date)) THEN
--       FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UC_EXPIRED');
--       FND_MESSAGE.Set_Token('NAME',l_name);
--       FND_MSG_PUB.ADD;
       --dbms_output.put_line('Unit has expired');
     ELSIF (p_x_csi_item_instance_id IS NULL) THEN
       p_x_csi_item_instance_id := l_csi_item_instance_id;
     END IF;
  END IF;

  -- Validate for too many parameters.
  -- If both item instance and mr_id present then raise error.
  IF (p_mr_header_id IS NOT NULL AND p_x_csi_item_instance_id IS NOT NULL) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INPUT_INVALID');
    -- Fix for bug# 3962903.
    --FND_MESSAGE.Set_Token('MR_ID',p_mr_header_id);
    --FND_MESSAGE.Set_Token('INST_ID',p_x_csi_item_instance_id);
    FND_MSG_PUB.ADD;
  END IF;

  -- If both p_unit_config_header_id and p_x_csi_item_instance_id are not
  -- null, then p_x_csi_item_instance_id should match l_csi_item_instance_id.
  IF ((p_x_csi_item_instance_id IS NOT NULL) AND
     (p_unit_config_header_id IS NOT NULL)) THEN
     IF (l_csi_item_instance_id <> p_x_csi_item_instance_id) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INPUT_INVALID');
       -- Fix for bug# 3962903.
       --FND_MESSAGE.Set_Token('MR_ID',p_mr_header_id);
       --FND_MESSAGE.Set_Token('INST_ID',p_x_csi_item_instance_id);
       FND_MSG_PUB.ADD;
     END IF;
  END IF;


END Validate_Input_Parameters;

-- AMSRINIV : #4360784 Modified Validate_PM_Input_Parameters so that Validate_Input_Parameters needn't be called. Begin
-- Tamal: Bug #4207212, #4114368 Begin
-- Validation procedure for PM mode.
Procedure Validate_PM_Input_Parameters (p_mr_header_id  IN  NUMBER,
                                        p_csi_item_instance_id   IN  NUMBER,
                                        p_contract_number  IN  VARCHAR2,
                                        p_contract_modifier  IN  VARCHAR2)
IS
    -- To validate mr id.
    CURSOR ahl_mr_headers_csr(p_mr_header_id   IN  NUMBER) IS
        SELECT title, version_number, effective_to, effective_from
        FROM  ahl_mr_headers_app_v
        WHERE mr_header_id = p_mr_header_id;

    -- To validate instance.
    CURSOR csi_item_instances_csr(p_csi_item_instance_id IN  NUMBER) IS
        SELECT instance_number --, active_end_date
        FROM csi_item_instances
        WHERE instance_id = p_csi_item_instance_id;

    -- Invalid assumption post bug #4360784. Fixed by AMSRINIV
    -- The assumption in this package is that Validate_Input_Parameters has already been called before calling this
    -- R12: replaced okc_k_headers_b with okc_k_headers_all_b for MOAC (ref bug# 4337173).
    cursor contract_number_csr
    is
        select 'x'
        from okc_k_headers_all_b
        where contract_number = p_contract_number
        and nvl(contract_number_modifier, 'X') = nvl(decode(p_contract_modifier, FND_API.G_MISS_CHAR, null, p_contract_modifier), 'X');

        l_effective_from ahl_mr_headers_app_v.EFFECTIVE_FROM%TYPE;
        l_effective_to   ahl_mr_headers_app_v.EFFECTIVE_TO%TYPE;
        l_mr_title       ahl_mr_headers_app_v.TITLE%TYPE;
        l_version_number ahl_mr_headers_app_v.VERSION_NUMBER%TYPE;
        l_csi_item_instance_id  NUMBER;
        --l_active_end_date       DATE;
        l_active_start_date     DATE;
        l_instance_number       csi_item_instances.instance_number%TYPE;
        l_dummy VARCHAR2(1);

BEGIN

      -- validate mr id.
    IF (p_mr_header_id IS NOT NULL) THEN
    OPEN ahl_mr_headers_csr (p_mr_header_id);
    FETCH ahl_mr_headers_csr INTO l_mr_title, l_version_number,
                                  l_effective_to, l_effective_from;
    IF (ahl_mr_headers_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_NOTFOUND');
      FND_MESSAGE.Set_Token('MR_ID',p_mr_header_id);
      FND_MSG_PUB.ADD;
      CLOSE ahl_mr_headers_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( trunc(l_effective_from) > trunc(sysdate) OR
            trunc(sysdate) > trunc(l_effective_to)) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_EXPIRED');
      FND_MESSAGE.Set_Token('TITLE',l_mr_title);
      FND_MESSAGE.Set_Token('VERSION',l_version_number);
      FND_MSG_PUB.ADD;
    END IF;

    CLOSE ahl_mr_headers_csr;
  END IF;

  -- validate item instance.
  IF (p_csi_item_instance_id IS NOT NULL) THEN
    OPEN csi_item_instances_csr (p_csi_item_instance_id);
    FETCH csi_item_instances_csr INTO l_instance_number; --, l_active_end_date;
    IF (csi_item_instances_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INSTID_NOTFOUND');
      FND_MESSAGE.Set_Token('INST_ID', p_csi_item_instance_id);
      FND_MSG_PUB.ADD;
      CLOSE csi_item_instances_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    /* Bypass validation to fix bug# 8567880. If instance is expired, validate and delete UMP.
       Done in procedure process_unit.
    ELSIF (l_active_end_date < sysdate) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INST_EXPIRED');
      FND_MESSAGE.Set_Token('NUMBER', l_instance_number);
      FND_MSG_PUB.ADD;
    */
    END IF;
    CLOSE csi_item_instances_csr;
  END IF;

    -- Validate whether contract number + modifier combination exists
    -- Validate whether contract modifier is NOT NULL but contract number IS NULL
    IF (p_contract_number is not null and p_contract_number <> FND_API.G_MISS_CHAR)
    THEN
        OPEN contract_number_csr;
        FETCH contract_number_csr INTO l_dummy;
        IF (contract_number_csr%NOTFOUND)
        THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_CONT_NOTFOUND');
            FND_MESSAGE.Set_Token('CONTRACT',p_contract_number);
            FND_MESSAGE.Set_Token('MODIFIER',p_contract_modifier);
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE contract_number_csr;
    ELSIF (p_contract_modifier IS NOT NULL and p_contract_modifier <> FND_API.G_MISS_CHAR)
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_CONT_MOD_INV');
        FND_MESSAGE.Set_Token('MODIFIER',p_contract_modifier);
        FND_MSG_PUB.ADD;
    END IF;

    -- Validate for too many params(any combination of 2 is an issue)
    IF (
        (p_mr_header_id IS NOT NULL AND p_csi_item_instance_id IS NOT NULL)
        OR
        (
                (p_mr_header_id IS NOT NULL or p_csi_item_instance_id IS NOT NULL)
                and
                p_contract_number IS NOT NULL
        )
    )
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_PM_INPUT_INVALID');
        FND_MSG_PUB.ADD;
    END IF;
END Validate_PM_Input_Parameters;
-- Tamal: Bug #4207212, #4114368 End
-- AMSRINIV: Bug #4360784. End

-- Procedure to mark a UE record as MR-Terminated.
PROCEDURE MR_Terminate(p_unit_effectivity_id IN NUMBER) IS

  CURSOR get_unit_effectivity_csr(p_ue_id IN NUMBER) IS
    SELECT
      OBJECT_VERSION_NUMBER,
      CSI_ITEM_INSTANCE_ID,
      MR_INTERVAL_ID,
      MR_EFFECTIVITY_ID,
      MR_HEADER_ID,
      STATUS_CODE,
      ACCOMPLISHED_DATE,
      DUE_DATE,
      DUE_COUNTER_VALUE,
      FORECAST_SEQUENCE,
      REPETITIVE_MR_FLAG,
      TOLERANCE_FLAG,
      REMARKS,
      MESSAGE_CODE,
      PRECEDING_UE_ID,
      DATE_RUN,
      SET_DUE_DATE,
      SERVICE_LINE_ID,
      PROGRAM_MR_HEADER_ID,
      CANCEL_REASON_CODE,
      EARLIEST_DUE_DATE,
      LATEST_DUE_DATE,
      DEFER_FROM_UE_ID,
      CS_INCIDENT_ID,
      QA_COLLECTION_ID,
      ORIG_DEFERRAL_UE_ID,
      APPLICATION_USG_CODE,
      OBJECT_TYPE,
      COUNTER_ID,
      MANUALLY_PLANNED_FLAG,
      LOG_SERIES_CODE,
      LOG_SERIES_NUMBER,
      FLIGHT_NUMBER,
      MEL_CDL_TYPE_CODE,
      POSITION_PATH_ID,
      ATA_CODE,
      UNIT_CONFIG_HEADER_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    FROM  AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE unit_effectivity_id = p_ue_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

   l_ue_rec   get_unit_effectivity_csr%rowtype;

BEGIN
  IF G_DEBUG='Y'  THEN
    AHL_DEBUG_PUB.debug('MR-Terminating UE record with ue_id ' || p_unit_effectivity_id, 'UMP');
  END IF;

  OPEN get_unit_effectivity_csr(p_unit_effectivity_id);
  FETCH get_unit_effectivity_csr INTO l_ue_rec;
  CLOSE get_unit_effectivity_csr;

  l_ue_rec.STATUS_CODE := 'MR-TERMINATE';
  l_ue_rec.MESSAGE_CODE := 'TERMINATE-W-NEW-REV';
  l_ue_rec.ACCOMPLISHED_DATE := SYSDATE;

  -- Call Table Handler to update record
  AHL_UNIT_EFFECTIVITIES_PKG.update_row(
            x_unit_effectivity_id => p_unit_effectivity_id,
            x_csi_item_instance_id => l_ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id => l_ue_rec.MR_INTERVAL_ID,
            x_mr_effectivity_id => l_ue_rec.MR_EFFECTIVITY_ID,
            x_mr_header_id => l_ue_rec.MR_HEADER_ID,
            x_status_code => l_ue_rec.STATUS_CODE,
            x_due_date => null,
            x_due_counter_value => null,
            x_forecast_sequence => null,
            x_repetitive_mr_flag => null,
            x_tolerance_flag => null,
            x_remarks => l_ue_rec.REMARKS,
            x_message_code => l_ue_rec.message_code,
            x_preceding_ue_id => l_ue_rec.PRECEDING_UE_ID,
            x_date_run => l_ue_rec.DATE_RUN,
            x_set_due_date => l_ue_rec.SET_DUE_DATE,
            x_accomplished_date => TRUNC(sysdate),
            x_service_line_id  => l_ue_rec.service_line_id,
            x_program_mr_header_id => l_ue_rec.program_mr_header_id,
            x_cancel_reason_code => l_ue_rec.cancel_reason_code,
            x_earliest_due_date  => l_ue_rec.earliest_due_date,
            x_latest_due_date    => l_ue_rec.latest_due_date,
            x_defer_from_ue_id     => l_ue_rec.defer_from_ue_id,
            x_qa_collection_id     => l_ue_rec.qa_collection_id,
            x_orig_deferral_ue_id  => l_ue_rec.orig_deferral_ue_id,
            x_cs_incident_id       => l_ue_rec.cs_incident_id,
            x_application_usg_code => l_ue_rec.application_usg_code,
            x_object_type          => l_ue_rec.object_type,
            x_counter_id           => l_ue_rec.counter_id,
            x_manually_planned_flag => l_ue_rec.manually_planned_flag,
            X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
            X_ATA_CODE              => l_ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
            x_attribute_category => l_ue_rec.ATTRIBUTE_CATEGORY,
            x_attribute1 => l_ue_rec.ATTRIBUTE1,
            x_attribute2 => l_ue_rec.ATTRIBUTE2,
            x_attribute3 => l_ue_rec.ATTRIBUTE3,
            x_attribute4 => l_ue_rec.ATTRIBUTE4,
            x_attribute5 => l_ue_rec.ATTRIBUTE5,
            x_attribute6 => l_ue_rec.ATTRIBUTE6,
            x_attribute7 => l_ue_rec.ATTRIBUTE7,
            x_attribute8 => l_ue_rec.ATTRIBUTE8,
            x_attribute9 => l_ue_rec.ATTRIBUTE9,
            x_attribute10 => l_ue_rec.ATTRIBUTE10,
            x_attribute11 => l_ue_rec.ATTRIBUTE11,
            x_attribute12 => l_ue_rec.ATTRIBUTE12,
            x_attribute13 => l_ue_rec.ATTRIBUTE13,
            x_attribute14 => l_ue_rec.ATTRIBUTE14,
            x_attribute15 => l_ue_rec.ATTRIBUTE15,
            x_object_version_number => l_ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_last_update_date => TRUNC(sysdate),
            x_last_updated_by => fnd_global.user_id,
            x_last_update_login => fnd_global.login_id);


END MR_Terminate;

-- Tamal: Bug #4207212, #4114368 Begin
PROCEDURE Building_PM_Unit_Effectivities (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER,
    p_mr_header_id          IN          NUMBER := NULL,
    p_csi_item_instance_id  IN          NUMBER := NULL,
    p_contract_number       IN          VARCHAR2 := NULL,
    p_contract_modifier     IN          VARCHAR2 := NULL,
    p_num_of_workers        IN          NUMBER   := 1
)
IS

    l_return_status     VARCHAR2(30);
    l_msg_count         NUMBER;

    l_api_name          VARCHAR2(30) := 'Building_PM_Unit_Effectivities';
    l_api_version       NUMBER := 1.0;

BEGIN

    -- Initialize error message stack by default
    FND_MSG_PUB.Initialize;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        retcode := 2;
        errbuf := FND_MSG_PUB.Get;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Build_UnitEffectivity (
        p_init_msg_list         => FND_API.G_TRUE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        p_default               => FND_API.G_TRUE,
        p_module_type           => NULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => errbuf,
        p_mr_header_id          => p_mr_header_id,
        p_csi_item_instance_id  => p_csi_item_instance_id,
        p_contract_number       => p_contract_number,
        p_contract_modifier     => p_contract_modifier,
        p_concurrent_flag       => 'Y',
        p_num_of_workers        => p_num_of_workers
    );

    l_msg_count := FND_MSG_PUB.Count_Msg;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        retcode := 2;  -- error based only on return status
    ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
        retcode := 1;  -- warning based on return status + msg count
    ELSE
        retcode := 0;  -- success, since nothing is wrong
    END IF;
END Building_PM_Unit_Effectivities;
-- Tamal: Bug #4207212, #4114368 End

-- SATHAPLI::Bug# 6504069, 26-Mar-2008
-- API to build the unit effectivities for all the attached units for a given PC.
-- The API is configured as the concurrent program AHLPCUEFF.
PROCEDURE Building_PC_Unit_Effectivities (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER,
    p_pc_header_id          IN          NUMBER
) IS

    CURSOR check_for_pc_csr (c_pc_header_id NUMBER) IS
        SELECT 'X'
        FROM   ahl_pc_headers_b
        WHERE  pc_header_id = c_pc_header_id
        AND    status       = 'COMPLETE';

    CURSOR get_mr_for_pc_csr (c_pc_header_id NUMBER) IS
        SELECT mrh.mr_header_id, mre.mr_effectivity_id
        FROM   ahl_mr_headers_b mrh, ahl_mr_effectivities mre,
               ahl_pc_nodes_b pcn
        WHERE  mrh.mr_header_id = mre.mr_header_id
        AND    mre.pc_node_id   = pcn.pc_node_id
        AND    pcn.pc_header_id = c_pc_header_id
        AND    TRUNC(NVL(mrh.effective_to, SYSDATE+1)) > TRUNC(SYSDATE);

--
    l_return_status         VARCHAR2(30);
    l_msg_count             NUMBER;

    l_api_version           NUMBER        := 1.0;
    l_api_name     CONSTANT VARCHAR2(30)  := 'Building_PC_Unit_Effectivities';
    l_full_name    CONSTANT VARCHAR2(100) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    TYPE MR_ITM_INST_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_pc_mr_item_inst_tbl   MR_ITM_INST_TBL_TYPE;
    l_get_mr_for_pc_rec     get_mr_for_pc_csr%ROWTYPE;
    l_mr_item_inst_tbl      AHL_FMP_PVT.MR_ITEM_INSTANCE_TBL_TYPE;
    indx                    NUMBER;
    l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_full_name,'Start of the API');
    END IF;

    -- initialize error message stack
    FND_MSG_PUB.Initialize;

    -- standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           ' Incompatible call. Raising exception.');
        END IF;

        retcode := 2;
        errbuf  := FND_MSG_PUB.Get;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- check for pc_header_id validity
    OPEN check_for_pc_csr(p_pc_header_id);
    FETCH check_for_pc_csr INTO l_dummy;
    IF check_for_pc_csr%NOTFOUND THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           ' Invalid PC');
        END IF;

        CLOSE check_for_pc_csr;
        -- invalid pc_header_id
        FND_MESSAGE.Set_Name('AHL','AHL_PC_NOT_FOUND');
        FND_MSG_PUB.ADD;

        retcode := 2;
        errbuf  := FND_MSG_PUB.Get;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE check_for_pc_csr;

    -- get all the applicable MRs for the PC
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' p_pc_header_id => '||p_pc_header_id);
    END IF;

    OPEN get_mr_for_pc_csr(p_pc_header_id);
    LOOP
        FETCH get_mr_for_pc_csr INTO l_get_mr_for_pc_rec;
        EXIT WHEN get_mr_for_pc_csr%NOTFOUND;

        -- get the top level applicable instances for the MR
        AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS(
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => errbuf,
            p_mr_header_id          => l_get_mr_for_pc_rec.mr_header_id,
            p_mr_effectivity_id     => l_get_mr_for_pc_rec.mr_effectivity_id,
            p_top_node_flag         => 'Y',
            p_unique_inst_flag      => 'Y',
            x_mr_item_inst_tbl      => l_mr_item_inst_tbl);

        -- check for the return status
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement,l_full_name,
                               ' Raising exception with x_return_status => '||l_return_status);
            END IF;

            retcode := 2;
            errbuf  := FND_MSG_PUB.Get;

            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- populate the associative array of instances for the PC
        IF (l_mr_item_inst_tbl.COUNT > 0) THEN
            FOR i IN l_mr_item_inst_tbl.FIRST..l_mr_item_inst_tbl.LAST LOOP
                indx := l_mr_item_inst_tbl(i).item_instance_id;
                l_pc_mr_item_inst_tbl(indx) := l_mr_item_inst_tbl(i).item_instance_id;
            END LOOP;
        END IF;
    END LOOP;
    CLOSE get_mr_for_pc_csr;

    -- put all the applicable instances for the PC in the debug logs
    indx := l_pc_mr_item_inst_tbl.FIRST;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        WHILE indx IS NOT NULL LOOP
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' l_pc_mr_item_inst_tbl indx, item_instance_id => '||indx||
                           ' ,'||l_pc_mr_item_inst_tbl(indx));
            indx := l_pc_mr_item_inst_tbl.NEXT(indx);
        END LOOP;
    END IF;

    -- for each of the top level instances fetched in l_pc_mr_item_inst_tbl above, call the API Build_UnitEffectivity
    indx := l_pc_mr_item_inst_tbl.FIRST;
    WHILE indx IS NOT NULL LOOP
        -- call the API Build_UnitEffectivity
        Build_UnitEffectivity (
            p_init_msg_list         => FND_API.G_TRUE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            p_default               => FND_API.G_TRUE,
            p_module_type           => NULL,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => errbuf,
            p_csi_item_instance_id  => l_pc_mr_item_inst_tbl(indx),
            p_concurrent_flag       => 'Y');

        l_msg_count := FND_MSG_PUB.Count_Msg;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- error based only on return status
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                               ' Build_UnitEffectivity failed for l_pc_mr_item_inst_tbl(indx) => '||
                               l_pc_mr_item_inst_tbl(indx));
            END IF;

            retcode := 2;
            EXIT; -- stop building unit effectivities for rest of the instances
        ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            -- warning based on return status + msg count
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                               ' Build_UnitEffectivity had warnings for l_pc_mr_item_inst_tbl(indx) => '||
                               l_pc_mr_item_inst_tbl(indx));
            END IF;

            retcode := 1;
        ELSE
            -- success, since nothing is wrong
            retcode := 0;
        END IF;

        indx := l_pc_mr_item_inst_tbl.NEXT(indx);
    END LOOP;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_full_name,'End of the API');
    END IF;

END Building_PC_Unit_Effectivities;

--------------------------------------------------------------------------
-- To log error messages into a log file if called from concurrent process.
-- fix for bug#3602277
---------------------------------------------------------------------------

PROCEDURE log_error_messages IS

l_msg_count      NUMBER;
l_msg_index_out  NUMBER;
l_msg_data       VARCHAR2(2000);

BEGIN

IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start log error messages');
END IF;

 -- Standard call to get message count.
l_msg_count := FND_MSG_PUB.Count_Msg;

FOR i IN 1..l_msg_count LOOP
  FND_MSG_PUB.get (
      p_msg_index      => i,
      p_encoded        => FND_API.G_FALSE,
      p_data           => l_msg_data,
      p_msg_index_out  => l_msg_index_out );

  fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_msg_data);
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Err message-'||l_msg_index_out||':' || substr(l_msg_data,1,240));
  END IF;

END LOOP;

IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start log error messages');
END IF;


END log_error_messages;
-------------------------------
-- End Local Procedures --
-------------------------------

------------------------------------------------------------------------------------------------
-- API added for the concurrent program "Process Terminated Maintenance Requirements".
-- This API is to be used with Concurrent program.
-- Bug # 8570734
------------------------------------------------------------------------------------------------
PROCEDURE process_terminated_MRs (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER
)
IS

l_api_name          VARCHAR2(30) := 'process_terminated_MRs';
l_api_version       NUMBER := 1.0;

CURSOR get_terminated_mrs_csr
IS
SELECT
   mr_header_id,
   title,
   version_number,
   effective_to,
   application_usg_code
FROM
   AHL_MR_HEADERS_B
WHERE
   TRUNC(effective_to) <= TRUNC(SYSDATE)
   AND MR_STATUS_CODE = 'COMPLETE'
   AND TERMINATION_REQUIRED_FLAG = 'Y'
   ORDER BY mr_header_id;

CURSOR GetNewMR_csr(C_TITLE  VARCHAR2,C_VERSION_NUMBER NUMBER,C_APP_CODE VARCHAR2,c_effective_from DATE)
 IS
 SELECT mr_header_id,
        version_number
 FROM AHL_MR_HEADERS_B
 WHERE TITLE=C_TITLE
 AND VERSION_NUMBER = C_VERSION_NUMBER+1
 AND APPLICATION_USG_CODE=C_APP_CODE
 AND MR_STATUS_CODE = 'COMPLETE'
 AND TRUNC(effective_from) >= trunc(c_effective_from);

l_new_mr_rec                  GetNewMR_csr%rowtype;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_err_msg               VARCHAR2(2000);
l_buffer_limit          NUMBER   := 1000;
l_index                 NUMBER;

BEGIN

    -- Initialize error message stack by default
    FND_MSG_PUB.Initialize;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        retcode := 2;
        errbuf := FND_MSG_PUB.Get;
    END IF;

    -- perform validations -- start

    fnd_file.put_line(fnd_file.log, 'At the begining of the process...');

    FOR get_terminated_mr IN get_terminated_mrs_csr LOOP

       SAVEPOINT process_terminated_MRs_pvt;

       fnd_file.put_line(fnd_file.log, 'Currently processing Terminated MR Title -> '|| get_terminated_mr.title);
       fnd_file.put_line(fnd_file.log, 'MR Header ID -> '|| get_terminated_mr.mr_header_id);
       fnd_file.put_line(fnd_file.log, 'MR Header ID -> '|| get_terminated_mr.version_number);

       OPEN GetNewMR_csr(get_terminated_mr.title,get_terminated_mr.version_number,
                         get_terminated_mr.application_usg_code,get_terminated_mr.effective_to);
       FETCH GetNewMR_csr INTO l_new_mr_rec.mr_header_id, l_new_mr_rec.version_number;
       IF(GetNewMR_csr%NOTFOUND) THEN
         CLOSE GetNewMR_csr;
         fnd_file.put_line(fnd_file.log, 'Next revision could not be found for -> '|| get_terminated_mr.title);
         fnd_file.put_line(fnd_file.log, 'Error rolling back');
         retcode := 2;  -- Error
         ROLLBACK TO process_terminated_MRs_pvt;
	       RETURN;
       ELSE
          Terminate_MR_Instances(
	                                 p_api_version         	=> l_api_version,
	                                 p_init_msg_list        => FND_API.G_FALSE,
	                                 p_commit              	=> FND_API.G_FALSE,
	                                 p_validation_level    	=>  FND_API.G_VALID_LEVEL_FULL,
	                                 p_default             	=> FND_API.G_TRUE,
	                                 p_module_type         	=>'API',
	                                 p_old_mr_header_id    	=> get_terminated_mr.mr_header_id,
	                                 p_old_mr_title        	=> get_terminated_mr.title,
	                                 p_old_version_number	=> get_terminated_mr.version_number,
	                                 p_new_mr_header_id    	=> l_new_mr_rec.mr_header_id,
	                                 p_new_mr_title        	=> get_terminated_mr.title,
	                                 p_new_version_number  	=> l_new_mr_rec.version_number,
	                                 x_return_status       	=> l_return_Status,
	                                 x_msg_count           	=>l_msg_count,
                                  x_msg_data            	=>l_msg_data);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           -- log a warning
          fnd_file.put_line(fnd_file.log, 'Maintenance Requirement -> '||get_terminated_mr.title||' is not processed for termination because of following error(s)');
          fnd_file.put_line(fnd_file.log, '---------------------------------------------------------------------------------');

          LOOP
              l_err_msg := FND_MSG_PUB.GET;
              IF l_err_msg IS NULL THEN
                EXIT;
              END IF;
              fnd_file.put_line(fnd_file.log, l_err_msg);
          END LOOP;
          ROLLBACK TO process_terminated_MRs_pvt;
          retcode := 2;  -- Error
          RETURN;
        END IF;
      END IF;
      CLOSE GetNewMR_csr;
    COMMIT;
    END LOOP; -- end of outer for loop

    retcode := 0;  -- success, since nothing is wrong

    fnd_file.put_line(fnd_file.log, 'End of processing Terminated Maintenance Requirements..');

END process_terminated_MRs;

END AHL_UMP_UNITMAINT_PVT;

/

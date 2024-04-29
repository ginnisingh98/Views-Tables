--------------------------------------------------------
--  DDL for Package AHL_UMP_UNITMAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UNITMAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUMXS.pls 120.1.12010000.3 2009/07/14 04:58:42 sikumar ship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Unit_Effectivity_Rec_Type IS RECORD (
        UNIT_EFFECTIVITY_ID     NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATED_BY         NUMBER,
        CREATION_DATE           DATE,
        CREATED_BY              NUMBER,
        LAST_UPDATE_LOGIN       NUMBER,
        CSI_ITEM_INSTANCE_ID    NUMBER,
        -- Maps to CSI_ITEM_INSTANCE_ID
        CSI_INSTANCE_NUMBER     VARCHAR2(30),
        MR_INTERVAL_ID          NUMBER,
        MR_EFFECTIVITY_ID       NUMBER,
        MR_ID                   NUMBER,
        -- Following two map to MR_ID
        MR_TITLE                VARCHAR2(80),
        MR_VERSION_NUMBER       NUMBER,
        STATUS_CODE             VARCHAR2(30),
        -- Maps to STATUS_CODE
        STATUS                  VARCHAR2(80),
        DUE_DATE                DATE,
        DUE_COUNTER_VALUE       NUMBER,
        FORECAST_SEQUENCE       NUMBER,
        REPETITIVE_MR_FLAG      VARCHAR2(1),
        TOLERANCE_FLAG          VARCHAR2(1),
        MESSAGE_CODE            VARCHAR2(30),
        PRECEDING_UE_ID         NUMBER,
        REMARKS                 VARCHAR2(4000),
        DATE_RUN                DATE,
        SET_DUE_DATE            DATE,
        ACCOMPLISHED_DATE       DATE,
        -- Added for 11.5.10 Enhancements.
        QA_COLLECTION_ID        NUMBER,
        UNIT_DEFERRAL_ID        NUMBER,
        UNIT_DEFERRAL_OBJECT_VERSION  NUMBER,
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150)
        );

TYPE Unit_Threshold_Rec_Type IS RECORD (
        UNIT_THRESHOLD_ID       NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATED_BY         NUMBER,
        CREATION_DATE           DATE,
        CREATED_BY              NUMBER,
        LAST_UPDATE_LOGIN       NUMBER,
        UNIT_EFFECTIVITY_ID     NUMBER,
        COUNTER_ID              NUMBER,
        -- Maps to COUNTER_ID
        COUNTER_NAME            VARCHAR2(30),
        COUNTER_VALUE           NUMBER,
        OPERATION_FLAG          VARCHAR2(1),
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150),
        -- Added for 11.5.10 Enhancements.
        UNIT_DEFERRAL_ID        NUMBER
        );

TYPE Unit_Accomplish_Rec_Type IS RECORD (
        UNIT_ACCOMPLISH_ID      NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATED_BY         NUMBER,
        CREATION_DATE           DATE,
        CREATED_BY              NUMBER,
        LAST_UPDATE_LOGIN       NUMBER,
        UNIT_EFFECTIVITY_ID     NUMBER,
        COUNTER_ID              NUMBER,
        -- Maps to COUNTER_ID
        COUNTER_NAME            VARCHAR2(30),
        COUNTER_VALUE           NUMBER,
        OPERATION_FLAG          VARCHAR2(1),
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150)
        );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Unit_Effectivity_Tbl_Type IS TABLE OF Unit_Effectivity_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Unit_Threshold_Tbl_Type IS TABLE OF Unit_Threshold_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Unit_Accomplish_Tbl_Type IS TABLE OF Unit_Accomplish_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

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
    p_csi_instance_number    IN            VARCHAR2  := NULL

);


-- Start of Comments --
--  Procedure name    : Build_UnitEffectivity
--  Type        : Private
--  Function    : This procedure will build unit and item effectivity and commit. Build_UnitEffectivity will commit at a unit level. If the
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
-- Details:
-- p_mr_header_id is the mr_header_id.
-- p_mr_title and p_mr_version_number will be used to resolve VALUE to ID conversion
--   for p_mr_header_id.
-- p_unit_config_header_id is the unit configuration ID.
-- p_unit_name will be used to resolve  VALUE to ID conversion for p_unit_config_header_id.
-- p_csi_item_instance_id is the instance_id from csi_item_instances.
-- p_csi_instance_number will be used to resolve VALUE to ID conversion for
--   p_csi_item_instance_id.
-- p_commit will always be true; so the caller need not do an explicit commit.
--   Build_UnitEffectivity will commit at a unit level. If the unit has any errors,
--   then rollback will be performed for that unit only.
-- p_concurrent_flag will be 'Y' if this procedure is called by the concurrent program else it
--   will be N. Default is N.
--
PROCEDURE Build_UnitEffectivity (
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default                IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type            IN            VARCHAR2  := NULL,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2,
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
    p_concurrent_flag        IN            VARCHAR2  := 'N',
    -- sracha: Added parameter for number of workers to fix perf issue bug# 6893404
    p_num_of_workers         IN            NUMBER    := 1,
    p_mtl_category_id        IN            NUMBER    := NULL,
    p_process_option         IN            VARCHAR2  := NULL
);

-- Start of Comments --
--  Procedure name    : Capture_MR_Updates
--  Type              : Private
--  Function          : For a given set of instances, will record their statuses with either
--                      accomplishment date or deferred-next due date or termination date with
--                      their corresponding counter and counter values.
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
--  Capture MR Update Parameters:
--      p_unit_Effectivity_tbl         IN      Unit_Effectivity_tbl_type  Required
--         List of all unit effectivities whose status, due or accomplished dates
--         and counter values need to be captured
--      p_x_Unit_Threshold_tbl         IN OUT  Unit_Threshold_tbl_type    Required
--         List of all thresholds (counters and counter values) when a MR becomes due
--      p_x_Unit_Accomplish_tbl        IN OUT  Unit_Accomplish_tbl_type   Required
--         List of all counters and corresponding counter values when the MR was last accomplished
--
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Capture_MR_Updates
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_unit_Effectivity_tbl  IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_tbl_type,
    p_x_unit_threshold_tbl  IN OUT NOCOPY       AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
    p_x_unit_accomplish_tbl IN OUT NOCOPY       AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Validate_For_Initialize
--  Type              : Private
--  Function          : For a given unit effectivity id, determined if it can be initialized.
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
--  Validate_For_Initialize Parameters:
--      p_unit_effectivity_id           IN      Id of Unit Effectivity to be initialized  Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Validate_For_Initialize
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
    -- This parameter does not make any sense in this method. Added for standard compliance
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    -- This parameter does not make any sense in this method. Added for standard compliance
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    -- This parameter does not make any sense in this method. Added for standard compliance
    p_default               IN            VARCHAR2  := FND_API.G_TRUE,
    -- This parameter does not make any sense in this method. Added for standard compliance
    p_module_type           IN            VARCHAR2  := NULL,
    p_unit_effectivity_id   IN            NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);



----------------------------------------
-- Declare Procedures for Terminate MR Instances --
----------------------------------------
-- Start of Comments --
--  Procedure name    : Terminate_MR_Instances
--  Type        : Public
--  Function    : Terminate MR Instances
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
PROCEDURE Terminate_MR_Instances(
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
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2 );

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
);
-- Tamal: Bug #4207212, #4114368 End

-- SATHAPLI::Bug# 6504069, 26-Mar-2008
-- API to build the unit effectivities for all the attached units for a given PC.
-- The API is configured as the concurrent program AHLPCUEFF.
PROCEDURE Building_PC_Unit_Effectivities (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER,
    p_pc_header_id          IN          NUMBER
);

------------------------------------------------------------------------------------------------
-- API added for the concurrent program "Process Terminated Maintenance Requirements".
-- This API is to be used with Concurrent program.
-- Bug # 8570734
------------------------------------------------------------------------------------------------
PROCEDURE process_terminated_MRs (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER
);

End AHL_UMP_UNITMAINT_PVT;

/

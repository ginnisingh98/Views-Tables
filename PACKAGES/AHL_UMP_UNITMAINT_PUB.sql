--------------------------------------------------------
--  DDL for Package AHL_UMP_UNITMAINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UNITMAINT_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUMXS.pls 120.0 2005/05/26 00:08:39 appldev noship $ */
/*#
 * Builds and Calculates Unit and Item instance Maintenance Plan Schedule.  Also Updates unit and item instance Maintenance Plan Schedule
 * with deferral and accomplishment details.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Maintain Unit Maintenance Plan Schedule
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_UNIT_EFFECTIVITY
 */

------------------------
-- Declare Procedures --
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
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * For a given set of instances, records their statuses with either accomplishment date or deferred-next due date
 * or termination date with their corresponding counter and counter values.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_unit_Effectivity_tbl Unit Effectivity Table of type AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_tbl_type
 * @param p_x_unit_threshold_tbl Unit Thresholds Details Table of type AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type
 * @param p_x_unit_accomplish_tbl Unit Accomplishment Details Table of type AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Capture Unit Maintenance Plan Updates
 */
PROCEDURE Capture_MR_Updates (
    p_api_version           IN            NUMBER    := 1.0,
    p_init_msg_list         IN            VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_unit_Effectivity_tbl  IN            AHL_UMP_UNITMAINT_PVT.Unit_Effectivity_tbl_type,
    p_x_unit_threshold_tbl  IN OUT NOCOPY       AHL_UMP_UNITMAINT_PVT.Unit_Threshold_tbl_type,
    p_x_unit_accomplish_tbl IN OUT NOCOPY       AHL_UMP_UNITMAINT_PVT.Unit_Accomplish_tbl_type,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2);



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
--   p_mr_header_id        IN            VARCHAR2,
--   p_old_mr_header_id    IN            VARCHAR2,

--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * Terminate a Unit Maintenance Plan Schedule based on termination of a Maintenance Requirement. Also creates a new Unit Maintenance
 * Plan based on new Maintenance Requirementthat replaces the terminated Maintenance Requirement.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type Module Type Value always NULL, For internal use
 * @param p_default Defaulting , default value FND_API.G_TRUE
 * @param p_old_mr_header_id Terminated Maintenance Requirement ID
 * @param p_old_mr_title Terminated Maintenance Requirement Title
 * @param p_old_version_number Terminated Maintenance Requirement Version Number
 * @param p_new_mr_header_id New Maintenance Requirement ID
 * @param p_new_mr_title New Maintenance Requirement Title
 * @param p_new_version_number New Maintenance Requirement Version Number
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Terminate Unit Maintenance Plan Schedule
 */
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
    x_msg_data            OUT  NOCOPY   VARCHAR2 );



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
/*#
 * Builds applicable Unit Maintenance Plan Schedule for a Unit or Item Instance
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Defaulting , default value FND_API.G_TRUE
 * @param p_module_type Module Type Value always NULL, For internal use
 * @param p_mr_header_id Maintenance Requirement Header ID
 * @param p_mr_title Maintenance Requirement Title
 * @param p_mr_version_number Maintenance Requirement Version Number
 * @param p_unit_config_header_id Unit Configuration Header ID
 * @param p_unit_name Unit Configuration Name
 * @param p_csi_item_instance_id CSI Item Instance ID
 * @param p_csi_instance_number CSI Item Instance Number
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Unit Maintenance Plan Schedule
 */
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


End AHL_UMP_UNITMAINT_PUB;

 

/

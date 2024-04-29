--------------------------------------------------------
--  DDL for Package AHL_UC_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_VALIDATION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUCVS.pls 120.0 2005/05/26 01:26:10 appldev noship $ */
/*#
 * This package provides the APIs for validating a Unit Configuration.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Unit Configuration Validation
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_UNIT_CONFIG
 */

---------------------------------
-- Define Table Type for Node --
---------------------------------
TYPE Error_Tbl_Type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------
--------------------------------
-- Start of Comments --
--  Procedure name    : Validate_Completeness
--  Type        : Private
--  Function    : Validates the unit's completeness and checks for ALL validations.
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Completeness Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--       x_error_tbl     OUT NOCOPY   AHL_MC_VALIDATION_PUB.error_tbl_Type Required
--
--  End of Comments.
/*#
 * This API is used to validate the Unit's completeness.
 * Does perform other validations also.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_unit_header_id Header ID for the record
 * @param x_error_tbl Record of the type AHL_MC_VALIDATION_PUB.error_tbl_Type Required
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Unit Configuration Completeness
 */
PROCEDURE Validate_Completeness (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id	  IN 	       NUMBER,
    x_error_tbl 	  OUT NOCOPY       Error_Tbl_Type);

--------------------------------
-- Start of Comments --
--  Procedure name    : Check_Completeness
--  Type        : Private
--  Function    : Check the unit's completeness and update
--   Complete/Incomplete status if current status is complete or incomplete..
--  Pre-reqs    :
--  Parameters  :
--
--  Check_Completeness Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--
--  End of Comments.
/*#
 * This API is used to check the completeness of a Unit.
 * It also updates the status if current status is complete or in-complete.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_unit_header_id Header ID for the record
 * @param x_evaluation_status Contains the result of the evaluation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Unit Configuration Completeness
 */
PROCEDURE Check_Completeness (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id	  IN 	       NUMBER,
    x_evaluation_status   OUT  NOCOPY    VARCHAR2);

--------------------------------
-- Start of Comments --
--  Procedure name    : Validate_Complete_For_Pos
--  Type        : Private
--  Function    : Validates the unit's completeness and checks for ALL validations.
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Complete_For_Pos Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--       p_csi_instance_id            IN   NUMBER Required.
--       x_error_tbl     OUT NOCOPY   AHL_MC_VALIDATION_PUB.error_tbl_Type Required
--
--  End of Comments.
/*#
 * This API is used to Validate the completeness of a Unit.
 * It also does other validations.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction , default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_csi_instance_id Instance id
 * @param x_error_tbl results of the validation of type AHL_MC_VALIDATION_PUB.error_tbl_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Complete for Positions
 */
PROCEDURE Validate_Complete_For_Pos (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_csi_instance_id     IN           NUMBER,
    x_error_tbl 	  OUT NOCOPY       Error_Tbl_Type);


End AHL_UC_VALIDATION_PUB;

 

/

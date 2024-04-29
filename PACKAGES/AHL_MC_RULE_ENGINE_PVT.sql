--------------------------------------------------------
--  DDL for Package AHL_MC_RULE_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_RULE_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRUES.pls 115.1 2003/09/26 00:49:39 cxcheng noship $ */


------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Check_Rules_For_Unit
--  Type        : Private
--  Function    : Checks rule completeness for unit
--  Pre-reqs    :
--  Parameters  :
--
--  Check_Rules_For_Unit Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--	 p_check_subconfig_flag	      IN    VARCHAR2, T/F whether to check
--					  subconfig rules
--       p_rule_type              IN VARCHAR2 Rule Type: MANDATORY or FLEET
--       x_evaluation_status    OUT VARCHAR2 T/F for the evaluation
-- result of all the rules
--
--
--  End of Comments.

PROCEDURE Check_Rules_For_Unit (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id	  IN 	       NUMBER,
    p_rule_type           IN            VARCHAR2,
    p_check_subconfig_flag IN 		VARCHAR2 := FND_API.G_TRUE,
    x_evaluation_status	  OUT  NOCOPY	 VARCHAR2);

------------------------
-- Start of Comments --
--  Procedure name    : Validate_Rules_For_Unit
--  Type        : Private
--  Function    : Validate all rule completeness for unit
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Rules_For_Unit Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--	 p_check_subconfig_flag	      IN    VARCHAR2, T/F whether to check
--					  subconfig rules
--       p_rule_type              IN VARCHAR2 Rule Type: MANDATORY or FLEET
--       x_evaluation_status    OUT VARCHAR2 T/F for the evaluation
--                          result of all the rules
--       p_x_error_tbl      IN OUT Lists all the error messages for failed rules
--  End of Comments.

PROCEDURE Validate_Rules_For_Unit (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id	  IN 	       NUMBER,
    p_rule_type           IN            VARCHAR2,
    p_check_subconfig_flag IN 		VARCHAR2 := FND_API.G_TRUE,
    p_x_error_tbl	  IN OUT NOCOPY  AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
    x_evaluation_status	  OUT  NOCOPY	 VARCHAR2);

------------------------
-- Start of Comments --
--  Procedure name    : Validate_Rules_For_Position
--  Type        : Private
--  Function    : Validate rules for one position
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Rules_For_Position Parameters:
--	 p_item_instance_id	      IN    NUMBER Required.
--       p_rule_type              IN VARCHAR2 Rule Type: MANDATORY or FLEET
--       x_evaluation_status    OUT VARCHAR2 T/F for the evaluation
--                          result of all the rules
--       p_x_error_tbl      IN OUT Lists all the error messages for failed rules--
--  End of Comments.

PROCEDURE Validate_Rules_For_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_item_instance_id   IN 	       NUMBER,
    p_rule_type           IN            VARCHAR2,
    p_x_error_tbl	  IN OUT NOCOPY  AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
    x_evaluation_status	  OUT  NOCOPY	 VARCHAR2);

------------------------
-- Start of Comments --
--  Procedure name    : Evaluate_Rule
--  Type        : Private
--  Function    : Evaluate 1 rule against 1 starting position
--  Pre-reqs    :
--  Parameters  :
--
--  Evaludate_Rule Parameters:
--	 p_item_instance_id	      IN    NUMBER Required.
--	 p_rule_id		      IN    NUMBER Required. Rule to eval.
--      x_eval_result       OUT VARCHAR2 T/F/U depending on rule
--                             evaluation result.
--  End of Comments.

PROCEDURE Evaluate_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_item_instance_id   IN 	       NUMBER,
    p_rule_id		  IN 		NUMBER,
    x_eval_result	  OUT  NOCOPY	 VARCHAR2);


End AHL_MC_RULE_ENGINE_PVT;

 

/

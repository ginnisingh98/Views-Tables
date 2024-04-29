--------------------------------------------------------
--  DDL for Package AHL_MC_RULE_STMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_RULE_STMT_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRSTS.pls 120.1 2007/12/21 13:35:48 sathapli ship $ */


------------------------
-- Declare Procedures --
------------------------
--------------------------------
-- Start of Comments --
--  Procedure name    : Validate_Rule_Stmt
--  Type        : Private
--  Function    : Validates the rule statement for statement errors.
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Rule_Stmt Parameters:
--       p_rule_stmt_rec      IN   AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type Required
--
--  End of Comments.

PROCEDURE Validate_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_stmt_rec 	  IN       AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type);

--------------------------------
-- Start of Comments --
--  Procedure name    : Insert_Rule_Stmt
--  Type        : Private
--  Function    : Writes to DB the rule stmt
--  Pre-reqs    :
--  Parameters  :
--
--  Insert_Rule_Stmt Parameters:
--       p_x_rule_stmt_rec      IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type Required
--
--  End of Comments.

PROCEDURE Insert_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module              IN           VARCHAR2  := 'JSP',
    p_x_rule_stmt_rec 	  IN OUT NOCOPY  AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type);

--------------------------------
-- Start of Comments --
--  Procedure name    : Update_Rule_Stmt
--  Type        : Private
--  Function    : Writes to DB the rule stmt
--  Pre-reqs    :
--  Parameters  :
--
--  Update_Rule_Stmt Parameters:
--       p_x_rule_stmt_rec      IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type Required
--
--  End of Comments.

PROCEDURE Update_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN 	       VARCHAR2  := 'JSP',
    p_rule_stmt_rec 	  IN           AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type);

--------------------------------
-- Start of Comments --
--  Procedure name    : Copy_Rule_Stmt
--  Type        : Private
--  Function    : Writes to DB the rule stmt by copying the rule stmt
--  Pre-reqs    :
--  Parameters  :
--
--  Update_Rule_Stmt Parameters:
--	 p_rule_stmt_id	      IN    NUMBER Required. rule stmt to copy
--       p_to_rule_id            IN    NUMBER  Required rule_id for insert purpose
--       p_to_mc_header_id    IN NUMBER Requred. mc_header_id to copy to
--       x_rule_stmt_id       OUT NOCOPY NUMBER   the new rule_stmt_id
--
--  End of Comments.

PROCEDURE Copy_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_stmt_id	  IN 	       NUMBER,
    p_to_rule_id          IN           NUMBER,
    p_to_mc_header_id     IN 		NUMBER,
    x_rule_stmt_id        OUT  NOCOPY   NUMBER);

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Rule_Stmts
--  Type        : Private
--  Function    : Deletes all the Rule statements corresponding to a rule
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Rule Parameters:
--       p_rule_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Rule_Stmts (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_id		  IN 	       NUMBER);

--------------------------------
-- Start of Comments --
--  Procedure name    : validate_quantity_rules_for_mc
--  Type        : Private
--  Function    : Validates all the quantity rule statements for a given MC.
--  Pre-reqs    :
--  Parameters  :
--
--  validate_quantity_rules_for_mc Parameters:
--       p_mc_header_id      IN   NUMBER Required
--
--  API added for FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
--
--  End of Comments.

PROCEDURE validate_quantity_rules_for_mc (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_mc_header_id        IN           NUMBER,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2);

--

End AHL_MC_RULE_STMT_PVT;

/

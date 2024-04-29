--------------------------------------------------------
--  DDL for Package AHL_MC_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPMCRS.pls 120.0.12010000.1 2008/11/26 14:16:29 sathapli noship $ */
/*#
 * Package containing public APIs to create, update and delete MC rules.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname MC Rules
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MASTER_CONFIG
 */

------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Insert_Rule
--  Type              : Public
--  Function          : Does user input validation and calls private API Insert_Rule
--  Pre-reqs          :
--  Parameters        :
--
--  Insert_Rule Parameters:
--       p_x_rule_rec    IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Rec_Type         Required
--	 p_rule_stmt_tbl IN            AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments

/*#
 * Procedure for creating an MC rule.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module Parameter to indicate from where the API is being called, default value 'JSP'
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_x_rule_rec Rule record of type AHL_MC_RULE_PVT.Rule_Rec_Type
 * @param p_rule_stmt_tbl Rule statement table as it appears on the UI of type AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type associated with a rule.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Rule
 */
PROCEDURE Insert_Rule (
    p_api_version         IN               NUMBER,
    p_init_msg_list       IN               VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN               VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module		  IN               VARCHAR2  := 'JSP',
    p_rule_stmt_tbl       IN               AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    p_x_rule_rec 	  IN OUT NOCOPY    AHL_MC_RULE_PVT.Rule_Rec_Type,
    x_return_status       OUT    NOCOPY    VARCHAR2,
    x_msg_count           OUT    NOCOPY    NUMBER,
    x_msg_data            OUT    NOCOPY    VARCHAR2
);

------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Update_Rule
--  Type              : Public
--  Function          : Does user input validation and calls private API Update_Rule
--  Pre-reqs          :
--  Parameters        :
--
--  Update_Rule Parameters:
--       p_rule_rec      IN               AHL_MC_RULE_PVT.Rule_Rec_Type         Required
--	 p_rule_stmt_tbl IN               AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments

/*#
 * Procedure for updating an MC rule.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module Parameter to indicate from where the API is being called, default value 'JSP'
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_rule_rec Rule record of type AHL_MC_RULE_PVT.Rule_Rec_Type
 * @param p_rule_stmt_tbl Rule statement table as it appears on the UI of type AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type associated with a rule.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Rule
 */
PROCEDURE Update_Rule (
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module		  IN            VARCHAR2  := 'JSP',
    p_rule_rec            IN            AHL_MC_RULE_PVT.Rule_Rec_Type,
    p_rule_stmt_tbl       IN            AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    x_return_status       OUT    NOCOPY VARCHAR2,
    x_msg_count           OUT    NOCOPY NUMBER,
    x_msg_data            OUT    NOCOPY VARCHAR2
);

------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Delete_Rule
--  Type              : Public
--  Function          : Does user input validation and calls private API Delete_Rule
--  Pre-reqs          :
--  Parameters        :
--
--  Delete_Rule Parameters:
--       p_rule_rec.rule_id                 IN    NUMBER     Required
--                                          or
--       p_rule_rec.rule_name               IN    VARCHAR2   Required
--       p_rule_rec.mc_header_id            IN    NUMBER     Required
--       (                                  or
--       p_rule_rec.mc_name                 IN    VARCHAR2   Required
--       p_rule_rec.mc_revision             IN    NUMBER     Required)
--
--	 p_rule_rec.object_version_number   IN    NUMBER     Required
--
--  End of Comments

/*#
 * Procedure for deleting an MC rule.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_rule_rec Rule record of type AHL_MC_RULE_PVT.Rule_Rec_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Rule
 */
PROCEDURE Delete_Rule (
    p_api_version         IN             NUMBER,
    p_init_msg_list       IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_rule_rec            IN             AHL_MC_RULE_PVT.Rule_Rec_Type,
    x_return_status       OUT    NOCOPY  VARCHAR2,
    x_msg_count           OUT    NOCOPY  NUMBER,
    x_msg_data            OUT    NOCOPY  VARCHAR2
);

------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Copy_Rules_For_MC
--  Type              : Public
--  Function          : Does user input validation and calls private API Copy_Rules_For_MC
--  Pre-reqs          :
--  Parameters        :
--
--  Copy_Rules_For_MC Parameters:
--       p_from_mc_header_id   IN    NUMBER     Required
--                             or
--       p_to_mc_name          IN    VARCHAR2   Required
--       p_to_revision         IN    VARCHAR2   Required
--
--	 p_to_mc_header_id     IN    NUMBER     Required
--                             or
--       p_from_mc_name        IN    VARCHAR2   Required
--       p_from_revision       IN    VARCHAR2   Required
--
--  End of Comments

/*#
 * Procedure for copying all the rules of a source MC to destination MC.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_from_mc_header_id Header id of the source MC.
 * @param p_from_mc_name Name of the source MC.
 * @param p_from_revision Revision number of the source MC.
 * @param p_to_mc_header_id Header id of the destination MC.
 * @param p_to_mc_name Name of the destination MC.
 * @param p_to_revision Revision number of the destination MC.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Rules for MC
 */
PROCEDURE Copy_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_from_mc_header_id	  IN           NUMBER,
    p_to_mc_header_id	  IN           NUMBER,
    p_from_mc_name        IN           VARCHAR2,
    p_from_revision       IN           VARCHAR2,
    p_to_mc_name          IN           VARCHAR2,
    p_to_revision         IN           VARCHAR2,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2
);

--------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Delete_Rules_For_MC
--  Type              : Public
--  Function          : Does user input validation and calls private API Delete_Rules_For_MC
--  Pre-reqs          :
--  Parameters        :
--
--  Delete_Rules_For_MC Parameters:
--       p_mc_header_id   IN    NUMBER     Required
--                        or
--       p_mc_name        IN    VARCHAR2   Required
--       p_revision       IN    VARCHAR2   Required
--
--  End of Comments

/*#
 * Procedure for deleting all the rules of an MC.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_mc_header_id Header id of the MC.
 * @param p_mc_name Name of the MC.
 * @param p_revision Revision number of the MC.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Rules for MC
 */
PROCEDURE Delete_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_mc_header_id	  IN 	       NUMBER,
    p_mc_name             IN           VARCHAR2,
    p_revision            IN           VARCHAR2,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2
);

-----------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Get_Rules_For_Position
--  Type              : Public
--  Function          : Does user input validation and calls private API Get_Rules_For_Position
--  Pre-reqs          :
--  Parameters        :
--
--  Get_Rules_For_Position Parameters:
--       p_encoded_path          IN  VARCHAR2                       Required
--
--	 p_mc_header_id	         IN  NUMBER                         Required
--                               or
--       p_mc_name               IN  VARCHAR2                       Required
--       p_revision              IN  VARCHAR2                       Required
--
--       x_rule_tbl              OUT AHL_MC_RULE_PVT.Rule_Tbl_Type  Required
--
--  End of Comments

/*#
 * Procedure for getting all the rules for an MC position.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_encoded_path Path position of the MC position.
 * @param p_mc_header_id Header id of the MC.
 * @param p_mc_name Name of the MC.
 * @param p_revision Revision number of the MC.
 * @param x_rule_tbl Rule record of type AHL_MC_RULE_PVT.Rule_Rec_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Rules for position
 */
PROCEDURE Get_Rules_For_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_mc_header_id        IN           NUMBER,
    p_encoded_path        IN           VARCHAR2,
    p_mc_name             IN           VARCHAR2,
    p_revision            IN           VARCHAR2,
    x_rule_tbl		  OUT  NOCOPY  AHL_MC_RULE_PVT.Rule_Tbl_Type,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2
);

End AHL_MC_RULE_PUB;

/

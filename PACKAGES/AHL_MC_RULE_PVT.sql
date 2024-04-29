--------------------------------------------------------
--  DDL for Package AHL_MC_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMCRS.pls 120.0.12010000.2 2008/11/26 14:09:40 sathapli ship $ */


---------------------------------
-- Define Record Type for Node --
---------------------------------
TYPE Rule_Rec_Type IS RECORD (
      	RULE_ID	 	        NUMBER,
	OBJECT_VERSION_NUMBER	NUMBER,
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATED_BY		NUMBER(15)	,
	CREATION_DATE		DATE		,
	CREATED_BY		NUMBER(15)	,
	LAST_UPDATE_LOGIN	NUMBER(15),
	MC_HEADER_ID            NUMBER   	,
        -- SATHAPLI::FP ER 6504160, 25-Nov-2008, added MC_NAME and MC_REVISION to the record.
        MC_NAME                 VARCHAR2(80)    ,
        MC_REVISION             VARCHAR2(30)    ,
	RULE_NAME		VARCHAR2(80)	,
	RULE_TYPE_CODE          VARCHAR2(30)    ,
	RULE_TYPE_MEANING       VARCHAR2(80)    ,
	ACTIVE_START_DATE	DATE,
	ACTIVE_END_DATE		DATE,
        DESCRIPTION             VARCHAR2(2000)  ,
        ATTRIBUTE_CATEGORY      VARCHAR2(30)    ,
        ATTRIBUTE1              VARCHAR2(150)   ,
        ATTRIBUTE2              VARCHAR2(150)   ,
        ATTRIBUTE3              VARCHAR2(150)   ,
        ATTRIBUTE4              VARCHAR2(150)   ,
        ATTRIBUTE5              VARCHAR2(150)   ,
        ATTRIBUTE6              VARCHAR2(150)   ,
        ATTRIBUTE7              VARCHAR2(150)   ,
        ATTRIBUTE8              VARCHAR2(150)   ,
        ATTRIBUTE9              VARCHAR2(150)   ,
        ATTRIBUTE10             VARCHAR2(150)   ,
        ATTRIBUTE11             VARCHAR2(150)   ,
        ATTRIBUTE12             VARCHAR2(150)   ,
        ATTRIBUTE13             VARCHAR2(150)   ,
        ATTRIBUTE14             VARCHAR2(150)   ,
        ATTRIBUTE15             VARCHAR2(150)   ,
        OPERATION_FLAG          VARCHAR2(1)     := null
        );

TYPE Rule_Stmt_Rec_Type IS RECORD (
	RULE_STATEMENT_ID	NUMBER          ,
	OBJECT_VERSION_NUMBER	NUMBER,
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATED_BY		NUMBER(15)	,
	CREATION_DATE		DATE		,
	CREATED_BY		NUMBER(15)	,
	LAST_UPDATE_LOGIN	NUMBER(15),
	RULE_ID                 NUMBER,
	TOP_RULE_STMT_FLAG      VARCHAR2(1),
	NEGATION_FLAG           VARCHAR2(1),
	SUBJECT_ID   		NUMBER 		,
	SUBJECT_TYPE		VARCHAR2(30) 	,
	OPERATOR		VARCHAR2(30)	,
	OBJECT_ID		NUMBER		,
	OBJECT_TYPE		VARCHAR2(30)	,
	OBJECT_ATTRIBUTE1	VARCHAR2(30),
	OBJECT_ATTRIBUTE2	VARCHAR2(30),
	OBJECT_ATTRIBUTE3	VARCHAR2(30),
	OBJECT_ATTRIBUTE4	VARCHAR2(30),
	OBJECT_ATTRIBUTE5	VARCHAR2(30),
        ATTRIBUTE_CATEGORY      VARCHAR2(30)    ,
        ATTRIBUTE1              VARCHAR2(150)   ,
        ATTRIBUTE2              VARCHAR2(150)   ,
        ATTRIBUTE3              VARCHAR2(150)   ,
        ATTRIBUTE4              VARCHAR2(150)   ,
        ATTRIBUTE5              VARCHAR2(150)   ,
        ATTRIBUTE6              VARCHAR2(150)   ,
        ATTRIBUTE7              VARCHAR2(150)   ,
        ATTRIBUTE8              VARCHAR2(150)   ,
        ATTRIBUTE9              VARCHAR2(150)   ,
        ATTRIBUTE10             VARCHAR2(150)   ,
        ATTRIBUTE11             VARCHAR2(150)   ,
        ATTRIBUTE12             VARCHAR2(150)   ,
        ATTRIBUTE13             VARCHAR2(150)   ,
        ATTRIBUTE14             VARCHAR2(150)   ,
        ATTRIBUTE15             VARCHAR2(150)   ,
        OPERATION_FLAG          VARCHAR2(1)     := null
        );


TYPE UI_Rule_Stmt_Rec_Type IS RECORD (
--	RULE_ID                 NUMBER,
	SEQUENCE_NUM		NUMBER,
	LEFT_PAREN  		VARCHAR2(30),
	RULE_STATEMENT_ID	NUMBER          ,
	RULE_STMT_OBJ_VER_NUM 	NUMBER          ,
        RULE_STMT_DEPTH         NUMBER,
	POSITION_ID		NUMBER,
        POSITION_MEANING        VARCHAR2(80)    ,
	OPERATOR		VARCHAR2(80)	,
	OPERATOR_MEANING	VARCHAR2(80)	,
	OBJECT_TYPE		VARCHAR2(30)	,
	OBJECT_TYPE_MEANING     VARCHAR2(80),
	OBJECT_ID		NUMBER	,
        OBJECT_MEANING		VARCHAR2(80),
        -- SATHAPLI::FP ER 6504160, 25-Nov-2008, added MC_REVISION to the record.
        MC_REVISION             VARCHAR2(30)    ,
	OBJECT_ATTRIBUTE1	VARCHAR2(30),
	OBJECT_ATTRIBUTE2	VARCHAR2(30),
	OBJECT_ATTRIBUTE3	VARCHAR2(30),
	OBJECT_ATTRIBUTE4	VARCHAR2(30),
	OBJECT_ATTRIBUTE5	VARCHAR2(30),
	RIGHT_PAREN		VARCHAR2(30),
	RULE_OPERATOR		VARCHAR2(80)	,
	RULE_OPERATOR_MEANING	VARCHAR2(80)	,
	RULE_OPER_STMT_ID	NUMBER,
	RULE_OPER_STMT_OBJ_VER_NUM	NUMBER,
	RULE_OPER_STMT_DEPTH	NUMBER,
        ATTRIBUTE_CATEGORY      VARCHAR2(30)    ,
        ATTRIBUTE1              VARCHAR2(150)   ,
        ATTRIBUTE2              VARCHAR2(150)   ,
        ATTRIBUTE3              VARCHAR2(150)   ,
        ATTRIBUTE4              VARCHAR2(150)   ,
        ATTRIBUTE5              VARCHAR2(150)   ,
        ATTRIBUTE6              VARCHAR2(150)   ,
        ATTRIBUTE7              VARCHAR2(150)   ,
        ATTRIBUTE8              VARCHAR2(150)   ,
        ATTRIBUTE9              VARCHAR2(150)   ,
        ATTRIBUTE10             VARCHAR2(150)   ,
        ATTRIBUTE11             VARCHAR2(150)   ,
        ATTRIBUTE12             VARCHAR2(150)   ,
        ATTRIBUTE13             VARCHAR2(150)   ,
        ATTRIBUTE14             VARCHAR2(150)   ,
        ATTRIBUTE15             VARCHAR2(150)
        );

---------------------------------
-- Define Table Type for Node --
---------------------------------
TYPE UI_Rule_Stmt_Tbl_Type IS TABLE OF UI_Rule_Stmt_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Rule_Stmt_Tbl_Type IS TABLE OF Rule_Stmt_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Rule_Tbl_Type IS TABLE OF Rule_Rec_Type INDEX BY BINARY_INTEGER;


------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Load_Rule
--  Type        : Private
--  Function    : Builds the rule record and ui rule table for display purposes
--  Pre-reqs    :
--  Parameters  :
--
--  Load_Rule Parameters:
--       p_rule_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Load_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_id		  IN 	       NUMBER,
    x_rule_stmt_tbl       OUT NOCOPY   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type);

--------------------------------
-- Start of Comments --
--  Procedure name    : Insert_Rule
--  Type        : Private
--  Function    : Writes to DB the rule record and ui rule table
--  Pre-reqs    :
--  Parameters  :
--
--  Insert_Rule Parameters:
--       p_x_rule_rec      IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Rec_Type Required
--	 p_rule_stmt_tbl IN   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments.

PROCEDURE Insert_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN           VARCHAR2 := 'JSP',
    p_rule_stmt_tbl       IN 	   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    p_x_rule_rec 	  IN OUT NOCOPY  AHL_MC_RULE_PVT.Rule_Rec_Type
);

--------------------------------
-- Start of Comments --
--  Procedure name    : Update_Rule
--  Type        : Private
--  Function    : Writes to DB the rule record and ui rule table
--  Pre-reqs    :
--  Parameters  :
--
--  Update_Rule Parameters:
--       p_rule_rec      IN   AHL_MC_RULE_PVT.Rule_Rec_Type Required
--	 p_rule_stmt_tbl IN   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments.

PROCEDURE Update_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN           VARCHAR2 := 'JSP',
    p_rule_rec 	  	  IN       AHL_MC_RULE_PVT.Rule_Rec_Type,
    p_rule_stmt_tbl       IN 	   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type);

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Rule
--  Type        : Private
--  Function    : Deletes the Rule corresponding to p_rule_rec
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Rule Parameters:
--       p_rule_rec.rule_id      IN  NUMBER  Required
--       p_rule_rec.object_version_number      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_rec		  IN 	       RULE_REC_TYPE
);

-----------------------------
-- Start of Comments --
--  Procedure name    : Copy_Rules_For_MC
--  Type        : Private
--  Function    : Copies all Rules for 1 MC to another MC
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Rule_For_MC Parameters:
--       p_from_mc_header_id      IN  NUMBER  Required
--	 p_to_mc_header_id	  IN NUMBER   Required
--
--  End of Comments.

PROCEDURE Copy_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_from_mc_header_id		  IN 	       NUMBER,
    p_to_mc_header_id		  IN 	       NUMBER);

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Rules_For_MC
--  Type        : Private
--  Function    : Deletes the Rule corresponding to 1 MC
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Rules_For_MC Parameters:
--       p_mc_header_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_mc_header_id	  IN 	       NUMBER);


-----------------------------
-- Start of Comments --
--  Procedure name    : Get_Rules_For_Position
--  Type        : Private
--  Function    : Returns all the rules that belong to a position
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Rule_For_MC Parameters:
--       p_encoded_path          IN VARCHAR2 Required
--	 p_to_mc_header_id	  IN NUMBER   Required
--
--  End of Comments.

PROCEDURE Get_Rules_For_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_mc_header_id        IN           NUMBER,
    p_encoded_path	  IN 	       VARCHAR2,
    x_rule_tbl		  OUT NOCOPY     Rule_Tbl_Type);

End AHL_MC_RULE_PVT;

/

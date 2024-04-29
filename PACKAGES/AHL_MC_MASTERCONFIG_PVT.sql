--------------------------------------------------------
--  DDL for Package AHL_MC_MASTERCONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_MASTERCONFIG_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMCXS.pls 120.0.12010000.2 2008/11/06 10:44:47 sathapli ship $ */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_MC_MasterConfig_PVT';

G_DML_CREATE 	CONSTANT 	VARCHAR2(1) 	:= 'C';
G_DML_UPDATE 	CONSTANT 	VARCHAR2(1) 	:= 'U';
G_DML_DELETE 	CONSTANT 	VARCHAR2(1) 	:= 'D';
G_DML_COPY 	CONSTANT 	VARCHAR2(1) 	:= 'X';

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Header_Rec_Type IS RECORD
(
	MC_HEADER_ID		NUMBER,
	NAME			VARCHAR2(80),
	DESCRIPTION		VARCHAR2(240),
	MC_ID			NUMBER,
	VERSION_NUMBER		NUMBER := 0,
	REVISION		VARCHAR2(30),
	MODEL_CODE              VARCHAR2(30), -- SATHAPLI::Enigma code changes, 26-Aug-2008
	MODEL_MEANING           VARCHAR2(30), -- SATHAPLI::Enigma code changes, 26-Aug-2008
	CONFIG_STATUS_CODE	VARCHAR2(30) := 'DRAFT',
	CONFIG_STATUS_MEANING	VARCHAR2(80),
	OBJECT_VERSION_NUMBER	NUMBER := 1,
	SECURITY_GROUP_ID 	NUMBER := NULL,
	ATTRIBUTE_CATEGORY 	VARCHAR2(30),
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
	OPERATION_FLAG		VARCHAR2(1) := NULL
);

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Create_Master_Config
--  Type        	: Private
--  Function    	: Creates Master Configuration header and topnode
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_x_mc_header_rec     	IN OUT 	Header_Rec_Type
-- 	p_x_node_rec          	IN OUT 	AHL_MC_Node_PVT.Node_Rec_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Create_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type

);

--  Start of Comments  --
--
--  Procedure name    	: Modify_Master_Config
--  Type        	: Private
--  Function    	: Updates Master Configuration header and topnode
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_x_mc_header_rec     	IN OUT 	Header_Rec_Type
-- 	p_x_node_rec          	IN OUT 	AHL_MC_Node_PVT.Node_Rec_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Modify_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type

);

--  Start of Comments  --
--
--  Procedure name    	: Delete_Master_Config
--  Type        	: Private
--  Function    	: Deletes/Closes Master Configuration
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_mc_header_id		IN	NUMBER
-- 	p_object_ver_num	IN	NUMBER
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Delete_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id     	IN 		NUMBER,
	p_object_ver_num        IN 		NUMBER

);

--  Start of Comments  --
--
--  Procedure name    	: Copy_Master_Config
--  Type        	: Private
--  Function    	: Makes a copy of an existing Master Configuration
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_x_mc_header_rec     	IN OUT 	Header_Rec_Type
-- 	p_x_node_rec          	IN OUT 	AHL_MC_Node_PVT.Node_Rec_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Copy_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type

);

--  Start of Comments  --
--
--  Procedure name    	: Create_MC_Revision
--  Type        	: Private
--  Function    	: Creates a revision of an exising Master Configuration
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_x_mc_header_id     	IN OUT 	NUMBER
-- 	p_object_ver_num       	IN 	NUMBER
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Create_MC_Revision
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_id     	IN OUT	NOCOPY	NUMBER,
	p_object_ver_num        IN 		NUMBER

);

--  Start of Comments  --
--
--  Procedure name    	: Reopen_Master_Config
--  Type        	: Private
--  Function    	: Reopens a closed / expired Master Configuration
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_mc_header_id     	IN 	NUMBER
-- 	p_object_ver_num       	IN 	NUMBER
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Reopen_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id     	IN		NUMBER,
	p_object_ver_num        IN 		NUMBER

);

--  Start of Comments  --
--
--  Procedure name    	: Initiate_MC_Approval
--  Type        	: Private
--  Function    	: Submits and starts approval process for Master Configuration
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Master_Config Parameters :
--      p_mc_header_id     	IN 	NUMBER
-- 	p_object_ver_num       	IN 	NUMBER
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Initiate_MC_Approval
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id     	IN		NUMBER,
	p_object_ver_num        IN 		NUMBER

);

End AHL_MC_MasterConfig_PVT;

/

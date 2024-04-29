--------------------------------------------------------
--  DDL for Package AHL_MC_MASTERCONFIG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_MASTERCONFIG_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPMCXS.pls 120.0 2005/05/26 02:15:51 appldev noship $ */
/*#
 * This is the public package that handles creation/modification/deletion of Master Configurations
 * depending on the flag that is being passed
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Master Configuration
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MASTER_CONFIG
 */
G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_MC_MasterConfig_PUB';

G_DML_CREATE 	CONSTANT 	VARCHAR2(1) 	:= 'C';
G_DML_UPDATE 	CONSTANT 	VARCHAR2(1) 	:= 'U';
G_DML_DELETE 	CONSTANT 	VARCHAR2(1) 	:= 'D';

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Process_Master_Config
--  Type        	: Public
--  Function    	: Handles creation, updation and deletion of Master Configurations
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--	p_module_type		IN	VARCHAR2	Default 'JSP'
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Process_Master_Config Parameters :
--      <other-in-params>,
-- 	<other-out-params>,
--	<other-in-out-params>
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * It handles creation , updation and deletion of Master Configurations
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_FALSE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status Return status,Standard API parameter
 * @param x_msg_count Return message count,Standard API parameter
 * @param x_msg_data Return message data,Standard API parameter
 * @param p_x_mc_header_rec Master Configuration record of type AHL_MC_MasterConfig_PVT.Header_Rec_Type
 * @param p_x_node_rec Master Configuration record  of type AHL_MC_Node_PVT.Node_Rec_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Master Configuration
 */
PROCEDURE Process_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	p_module_type		IN		VARCHAR2	:= 'JSP',
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	AHL_MC_MasterConfig_PVT.Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type
);

End AHL_MC_MasterConfig_PUB;

 

/

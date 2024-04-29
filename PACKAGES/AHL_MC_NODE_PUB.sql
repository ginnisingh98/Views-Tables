--------------------------------------------------------
--  DDL for Package AHL_MC_NODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_NODE_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPNODS.pls 120.0 2005/05/25 23:39:12 appldev noship $ */
/*#
 * This is the public package that handles creation/modification/deletion of Master Configurations Nodes
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Master Configuration
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MASTER_CONFIG
 */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_MC_Node_PUB';

G_DML_CREATE 	CONSTANT 	VARCHAR2(1) 	:= 'C';
G_DML_UPDATE 	CONSTANT 	VARCHAR2(1) 	:= 'U';
G_DML_DELETE 	CONSTANT 	VARCHAR2(1) 	:= 'D';

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Process_Node
--  Type        	: Public
--  Function    	: Handles creation, updation and deletion of Master Configuration nodes
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
--  Process_Node Parameters :
--      p_x_node_rec		IN	AHL_MC_Node_PVT.Node_Rec_Type
--	p_x_counter_rules_tbl	IN	AHL_MC_Node_PVT.Counter_Rules_Tbl_Type
--	p_x_subconfig_tbl	IN	AHL_MC_Node_PVT.SubConfig_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * It handles creation , updation and deletion of Master Configurations nodes.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_FALSE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type For Internal use only, default value 'JSP'
 * @param x_return_status Return status,Standard API parameter
 * @param x_msg_count Return message count,Standard API parameter
 * @param x_msg_data Return message data,Standard API parameter
 * @param p_x_node_rec Master Configuration record of type AHL_MC_Node_PVT.Node_Rec_Type
 * @param p_x_counter_rules_tbl Node Rule record of type AHL_MC_Node_PVT.Counter_Rules_Tbl_Type
 * @param p_x_subconfig_tbl Sub-Configuration node record of type AHL_MC_Node_PVT.SubConfig_Tbl_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Master Configuration Node
 */
PROCEDURE Process_Node
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	p_module_type		IN		VARCHAR2	:= 'JSP',
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_node_rec 	    	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type,
	p_x_counter_rules_tbl  	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Counter_Rules_Tbl_Type,
	p_x_subconfig_tbl     	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.SubConfig_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name    	: Delete_Nodes
--  Type        	: Private
--  Function    	: Deletes Master Configuration nodes
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
--  Create_Node Parameters :
--      p_node_tbl		IN	AHL_MC_Node_PVT.Node_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * It handles deletion of Master Configurations nodes.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_FALSE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status Return status,Standard API parameter
 * @param x_msg_count Return message count,Standard API parameter
 * @param x_msg_data Return message data,Standard API parameter
 * @param p_nodes_tbl Master Configuration record of type AHL_MC_Node_PVT.Node_Rec_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Master Configuration Node
 */
PROCEDURE Delete_Nodes
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_nodes_tbl		IN		AHL_MC_Node_PVT.Node_Tbl_Type
);

End AHL_MC_Node_PUB;

 

/

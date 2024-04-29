--------------------------------------------------------
--  DDL for Package AHL_MC_NODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_NODE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVNODS.pls 120.1 2005/07/04 01:59:01 tamdas noship $ */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_MC_Node_PVT';

G_DML_CREATE 	CONSTANT 	VARCHAR2(1) 	:= 'C';
G_DML_UPDATE 	CONSTANT 	VARCHAR2(1) 	:= 'U';
G_DML_DELETE 	CONSTANT 	VARCHAR2(1) 	:= 'D';
G_DML_COPY 	CONSTANT 	VARCHAR2(1) 	:= 'X';

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Node_Rec_Type IS RECORD
(
        RELATIONSHIP_ID         	NUMBER,
        MC_HEADER_ID	     		NUMBER,
	POSITION_KEY	     		NUMBER,
   	POSITION_REF_CODE       	VARCHAR2(30),
        POSITION_REF_MEANING    	VARCHAR2(80),
	--priyan MEL-CDL
   	ATA_CODE       			VARCHAR2(30),
        ATA_MEANING    			VARCHAR2(80),
        POSITION_NECESSITY_CODE 	VARCHAR2(30),
        POSITION_NECESSITY_MEANING 	VARCHAR2(80),
        UOM_CODE                	VARCHAR2(3) := 'Ea',
        QUANTITY                	NUMBER := 1,
        PARENT_RELATIONSHIP_ID  	NUMBER := NULL,
        ITEM_GROUP_ID           	NUMBER,
        ITEM_GROUP_NAME         	VARCHAR2(80),
        DISPLAY_ORDER           	NUMBER := 1,
        ACTIVE_START_DATE       	DATE,
        ACTIVE_END_DATE         	DATE,
        OBJECT_VERSION_NUMBER   	NUMBER := 1,
	SECURITY_GROUP_ID	     	NUMBER,
        ATTRIBUTE_CATEGORY      	VARCHAR2(30),
        ATTRIBUTE1              	VARCHAR2(150),
        ATTRIBUTE2              	VARCHAR2(150),
        ATTRIBUTE3              	VARCHAR2(150),
        ATTRIBUTE4              	VARCHAR2(150),
        ATTRIBUTE5              	VARCHAR2(150),
        ATTRIBUTE6              	VARCHAR2(150),
        ATTRIBUTE7              	VARCHAR2(150),
        ATTRIBUTE8              	VARCHAR2(150),
        ATTRIBUTE9             		VARCHAR2(150),
        ATTRIBUTE10             	VARCHAR2(150),
        ATTRIBUTE11             	VARCHAR2(150),
        ATTRIBUTE12             	VARCHAR2(150),
        ATTRIBUTE13             	VARCHAR2(150),
        ATTRIBUTE14             	VARCHAR2(150),
        ATTRIBUTE15             	VARCHAR2(150),
        OPERATION_FLAG          	VARCHAR2(1) := NULL,
        PARENT_NODE_REC_INDEX   	NUMBER
);

TYPE Node_Tbl_Type IS TABLE OF Node_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Counter_Rule_Rec_Type IS RECORD
(
        CTR_UPDATE_RULE_ID      NUMBER,
        RELATIONSHIP_ID         NUMBER,
        UOM_CODE                VARCHAR2(3),
        RULE_CODE               VARCHAR2(30),
        RULE_MEANING            VARCHAR2(80),
        RATIO                   NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER := 1,
        SECURITY_GROUP_ID	NUMBER,
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
        OPERATION_FLAG          VARCHAR2(1) := NULL,
        NODE_TBL_INDEX          NUMBER
);

TYPE Counter_Rules_Tbl_Type IS TABLE OF Counter_Rule_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Subconfig_Rec_Type IS RECORD
(
        MC_CONFIG_RELATION_ID   NUMBER,
        MC_HEADER_ID         	NUMBER,
        NAME			VARCHAR2(80),
        VERSION_NUMBER          NUMBER,
        RELATIONSHIP_ID        	NUMBER,
        ACTIVE_START_DATE      	DATE,
        ACTIVE_END_DATE      	DATE,
        OBJECT_VERSION_NUMBER   NUMBER := 1,
        PRIORITY                NUMBER(15),
        SECURITY_GROUP_ID	NUMBER,
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
        OPERATION_FLAG          VARCHAR2(1) := NULL
);

TYPE Subconfig_Tbl_Type IS TABLE OF Subconfig_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Create_Node
--  Type        	: Private
--  Function    	: Creates Master Configuration nodes
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
--      p_x_node_rec 	    	IN OUT 	Node_Rec_Type,
--	p_x_counter_rules_tbl  	IN OUT 	Counter_Rules_Tbl_Type,
--	p_x_subconfig_tbl     	IN OUT 	SubConfig_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Create_Node
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_node_rec 	    	IN OUT 	NOCOPY 	Node_Rec_Type,
	p_x_counter_rules_tbl  	IN OUT 	NOCOPY 	Counter_Rules_Tbl_Type,
	p_x_subconfig_tbl     	IN OUT 	NOCOPY 	SubConfig_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name    	: Modify_Node
--  Type        	: Private
--  Function    	: Updates Master Configuration nodes
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
--      p_x_node_rec 	    	IN OUT 	Node_Rec_Type,
--	p_x_counter_rules_tbl  	IN OUT 	Counter_Rules_Tbl_Type,
--	p_x_subconfig_tbl     	IN OUT 	SubConfig_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Modify_Node
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_node_rec 	    	IN OUT 	NOCOPY 	Node_Rec_Type,
	p_x_counter_rules_tbl  	IN OUT 	NOCOPY 	Counter_Rules_Tbl_Type,
	p_x_subconfig_tbl     	IN OUT 	NOCOPY 	SubConfig_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name    	: Delete_Node
--  Type        	: Private
--  Function    	: Delete Master Configuration nodes
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
--      p_relationship_id    	IN 	NUMBER,
--	p_object_ver_num	IN 	NUMBER
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Delete_Node
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_node_id    		IN 		NUMBER,
	p_object_ver_num	IN 		NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Copy_Node
--  Type        	: Private
--  Function    	: Copy existing Master Configuration node to the same or another Master Configuration
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
--      p_parent_rel_id	    	IN 	NUMBER,
--	p_parent_obj_ver_num  	IN 	NUMBER,
--	p_x_node_id           	IN OUT 	NUMBER,
--	p_x_node_obj_ver_num  	IN OUT 	NUMBER
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Copy_Node
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_parent_rel_id	    	IN 		NUMBER,
	p_parent_obj_ver_num  	IN 		NUMBER,
	p_x_node_id           	IN OUT 	NOCOPY	NUMBER,
	p_x_node_obj_ver_num  	IN OUT 	NOCOPY	NUMBER

);

--  Start of Comments  --
--
--  Procedure name    	: Copy_MC_Nodes
--  Type        	: Private
--  Function    	: Copies tree of Master Configuration nodes from one node to another
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
--      p_source_rel_id       	IN 	NUMBER,
--	p_dest_rel_id         	IN 	NUMBER,
--	p_new_rev_flag        	IN 	BOOLEAN		Default FALSE
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Copy_MC_Nodes
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY	VARCHAR2,
	x_msg_count           	OUT 	NOCOPY	NUMBER,
	x_msg_data            	OUT 	NOCOPY	VARCHAR2,
	p_source_rel_id       	IN 		NUMBER,
	p_dest_rel_id         	IN 		NUMBER,
	p_new_rev_flag        	IN 		BOOLEAN		:= FALSE,
	p_node_copy		IN 		BOOLEAN		:= FALSE
);

--  Start of Comments  --
--
--  Procedure name    	: Process_Documents
--  Type        	: Private
--  Function    	: Handles document associations with MC node
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
--      p_node_rec		IN	Node_Rec_Type,
--	p_x_documents_tbl	IN OUT	AHL_DI_ASSO_DOC_GEN_PVT.association_tbl
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Process_Documents
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_node_id		IN		NUMBER,
	p_x_documents_tbl	IN OUT	NOCOPY	AHL_DI_ASSO_DOC_GEN_PUB.association_tbl
);

--  Start of Comments  --
--
--  Procedure name    	: Associate_Item_Group
--  Type        	: Private
--  Function    	: Associates item groups to MC nodes, called by Item Group pages
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
--      p_nodes_tbl		IN	Node_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Associate_Item_Group
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_nodes_tbl		IN		Node_Tbl_Type
);

End AHL_MC_Node_PVT;

 

/

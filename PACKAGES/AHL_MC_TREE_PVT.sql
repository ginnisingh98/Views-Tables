--------------------------------------------------------
--  DDL for Package AHL_MC_TREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_TREE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMCTS.pls 120.1 2005/07/04 02:27:15 tamdas noship $ */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_MC_TREE_PVT';

-------------------------------
-- Define records and tables --
-------------------------------

--  Key for the OUT params
--	HAS_SUBCONFIGS = Should be used to display / hide the subconfiguration association table
--	IS_SUBCONFIG_NODE = Should be passed to the right-frame for displaying subconfiguration edit page
--	IS_SUBCONFIG_TOPNODE = Can be used if needed, indicates whether the node is a root node of the subconfiguration
--	IS_PARENT_SUBCONFIG = Can be used if needed, indicates whether the parent node is a subconfiguration node itself
--	POSITION_PATH = Encoded position path of the particular node
--	POSITION_PATH_ID = Position path ID created for the particular node, null if no record exists in position path tables
--	MC_HEADER_ID = The mc_header_id of the node, the subconfig mc_header_id if the node is a subconfig node
--	MC_ID = The mc_id of the MC that has the particular node, the subconfig's mc_id if the node is a subconfig node
--	VERSION_NUMBER = The version_number of the MC that has the particular node, the subconfig's version_number if the node is a subconfig node
--	CONFIG_STATUS_CODE = The config_status_code of the MC that has the particular node, the subconfig's config_status_code if the node is a subconfig node

TYPE Tree_Node_Rec_Type IS RECORD
(
	RELATIONSHIP_ID 		NUMBER,
	OBJECT_VERSION_NUMBER		NUMBER,
	POSITION_KEY 			NUMBER,
	PARENT_RELATIONSHIP_ID 		NUMBER,
	ITEM_GROUP_ID			NUMBER,
	POSITION_REF_CODE 		VARCHAR2(30),
	POSITION_REF_MEANING 		VARCHAR2(80),
	--R12
	--priyan MEL-CDL
	ATA_CODE       			VARCHAR2(30),
        ATA_MEANING    			VARCHAR2(80),

	POSITION_NECESSITY_CODE		VARCHAR2(30),
	POSITION_NECESSITY_MEANING	VARCHAR2(80),
	UOM_CODE			VARCHAR2(30),
	QUANTITY			NUMBER,
	DISPLAY_ORDER			NUMBER,
	ACTIVE_START_DATE		DATE,
	ACTIVE_END_DATE			DATE,

	NUM_CHILD_NODES			NUMBER := 0,
	HAS_SUBCONFIGS			VARCHAR2(1) := 'F',
	IS_SUBCONFIG_NODE		VARCHAR2(1) := 'F',
	IS_SUBCONFIG_TOPNODE		VARCHAR2(1) := 'F',
	IS_PARENT_SUBCONFIG		VARCHAR2(1) := 'F',

	POSITION_PATH			VARCHAR2(4000),
	POSITION_PATH_ID		NUMBER,

	MC_HEADER_ID 			NUMBER,
	MC_ID				NUMBER,
	VERSION_NUMBER			NUMBER,
	CONFIG_STATUS_CODE 		VARCHAR2(30)
);

TYPE Tree_Node_Tbl_Type IS TABLE OF Tree_Node_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Get_MasterConfig_Nodes
--  Type        	: Private
--  Function    	: Get MC Tree Nodes for Left frame UI
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER		Required
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Get_MasterConfig_Nodes Parameters :
--      p_mc_header_id  	IN 	NUMBER
--	p_parent_rel_id 	IN 	NUMBER
--	p_is_parent_subcongfig 	IN 	VARCHAR2	Default 'F'
--	p_parent_pos_path 	IN 	VARCHAR2
--	p_isTopConfigNode 	IN 	VARCHAR2	Default 'F'
--	p_isSubConfigNode 	IN 	VARCHAR2	Default 'F'
--	x_tree_node_tbl   	OUT 	Tree_Node_Tbl_Type
--
--  Key to call this API, input params to be passed
--	MC Root Node
--		p_mc_header_id = <header-id of the MC>
--		p_parent_rel_id = null
--		p_is_parent_subconfig = 'F'
--		p_parent_pos_path = null
--		p_is_top_config_node = 'T'
--		p_is_sub_config_node = 'F'
--
--	MC Node (except root node)
--		p_mc_header_id = <header-id of the MC>
--		p_parent_rel_id = <relationship-id of the MC Node>
--		p_is_parent_subconfig = 'F'
--		p_parent_pos_path = <position path of the parent-node>
--		p_is_top_config_node = 'F'
--		p_is_sub_config_node = 'F'
--
--	Subconfig Root Node (any level deep)
--		p_mc_header_id = <header-id of the subconfig>
--		p_parent_rel_id = <relationship-id of the MC node to which the subconfig is to be attached>
--		p_is_parent_subconfig = 'F' (if the MC node to which the subconfig is to be attached is not a subconfig itself, else 'T'>
--		p_parent_pos_path = <position path of the MC node to which the subconfig is to be attached>
--		p_is_top_config_node = 'T'
--		p_is_sub_config_node = 'T'
--
--	Subconfig Node (except root node, any level deep)
--		p_mc_header_id = <header-id of the subconfig>
--		p_parent_rel_id = <relationship-id of the subconfig node>
--		p_is_parent_subconfig = 'T'
--		p_parent_pos_path = <position path of the subconfig node>
--		p_is_top_config_node = 'F'
--		p_is_sub_config_node = 'T'
--
--  End of Comments  --
PROCEDURE Get_MasterConfig_Nodes
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id  	IN 		NUMBER,
	p_parent_rel_id 	IN 		NUMBER,
	p_is_parent_subconfig 	IN 		VARCHAR2 := 'F',
	p_parent_pos_path 	IN 		VARCHAR2,
	p_is_top_config_node 	IN 		VARCHAR2 := 'F',
	p_is_sub_config_node 	IN 		VARCHAR2 := 'F',
	x_tree_node_tbl   	OUT 	NOCOPY 	Tree_Node_Tbl_Type
);

End AHL_MC_TREE_PVT;

 

/

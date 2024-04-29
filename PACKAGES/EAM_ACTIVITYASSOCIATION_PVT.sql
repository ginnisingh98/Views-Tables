--------------------------------------------------------
--  DDL for Package EAM_ACTIVITYASSOCIATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ACTIVITYASSOCIATION_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVAAAS.pls 115.6 2004/06/12 00:19:30 sraval ship $ */

-- Start of comments
--	API name 	: Create_Association
--	Type		: Private.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list			IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--	p_organization_id		IN	NUMBER,
--	p_inventory_item_id		IN	NUMBER, -- id of Asset Activity
--      p_wip_entity_id			IN	NUMBER, -- id of Work Order
--	p_association_copy_option	IN	VARCHAR2 := '2' -- 1 (NONE), 2 (CURRENT), OR 3 (ALL)
                                                                -- 3 (ALL) is only valid if source work order
                                                                -- has an activity specified.
--
--	OUT		:	x_return_status			OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Associate Activity to (NONE/CURRENT/ALL) Asset Numbers linked to the Work Order.
--
-- End of comments
PROCEDURE Create_Association
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	p_target_org_id			IN	NUMBER, -- organzation Asset Activity is in
	p_target_activity_id		IN	NUMBER, -- id of Asset Activity

	-- If Copy Source is from Work Order, specify the Work_Entity_Id
        p_wip_entity_id			IN	NUMBER  := NULL, -- id of Work Order
	-- If Copy Source is from another Activity, specify the Activity Id and Org Id
	p_source_org_id			IN	NUMBER	:= NULL,
	p_source_activity_id		IN	NUMBER  := NULL,

	p_association_copy_option	IN	NUMBER := 2, -- 1 (NONE), 2 (CURRENT), OR 3 (ALL)
                                                                -- 3 (ALL) is only valid if source work order
                                                                -- has an activity specified.
	x_act_num_association_tbl	OUT	NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type,
	x_activity_association_tbl	OUT	NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type

);


-- Start of comments
--	API name 	: Create_AssetNumberAssociation
--	Type		: Private.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list			IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--	p_organization_id		IN	NUMBER, -- organzation Asset Activity is in
--	p_inventory_item_id		IN	NUMBER, -- id of Asset Activity
--	p_activity_association_tbl	IN	EAM_ActivityAssociation_PVT.Activity_Association_Tbl_Type

--	OUT		:	x_return_status			OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)

--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Association Asset Activity to all Asset Numbers in p_activity_association_tbl.
--
-- End of comments
PROCEDURE Create_AssetNumberAssoc
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	p_activity_association_tbl	IN	EAM_Activity_PUB.Activity_Association_Tbl_Type,
	x_activity_association_tbl	OUT NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type
);


PROCEDURE Inst_Activity_Template(
 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	-- input: maintenance object (id and type)
	p_maintenance_object_id		IN	NUMBER,
	p_maintenance_object_type	IN	NUMBER, -- only supports type 1 (serial numbers) for now
	-- output for activity association
	x_activity_association_id_tbl	OUT	NOCOPY EAM_ObjectInstantiation_PUB.Association_Id_Tbl_Type

	--  BUG: 3683229
	,p_class_code			IN VARCHAR2
	,p_owning_department_id		IN NUMBER
);


END EAM_ActivityAssociation_PVT;

 

/

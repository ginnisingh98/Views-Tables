--------------------------------------------------------
--  DDL for Package EAM_ACTIVITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ACTIVITY_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPACTS.pls 120.1 2005/06/12 22:06:54 appldev  $ */

-- To uniquely identify a Work Order.
-- If the Wip_Entity_Id is given, that would be enough.
-- Or user can specify the Wip_Entity_Name along with the Organization.
-- Will assigne Activity to the Work Order's organization, and its master org.
TYPE Work_Order_Rec_Type IS RECORD
(
Organization_Id		NUMBER       	:=  NULL, -- Org Id overrides Org Code if both present
Organization_Code	VARCHAR2(3)  	:=  NULL,
Wip_Entity_Id		NUMBER       	:=  NULL, -- Wip Entity Id overrides Name if both present
Wip_Entity_Name		VARCHAR2(240) 	:=  NULL
);

TYPE Activity_Association_Rec_Type IS RECORD
(
Organization_Id		NUMBER, -- organization responsible for Asset's maintenance
Asset_Activity_Id	NUMBER,
Start_Date_Active	DATE,
End_Date_Active		DATE,
Priority_Code		VARCHAR(30),
Attribute_Category	VARCHAR2(30),
Attribute1		VARCHAR2(150),
Attribute2		VARCHAR2(150),
Attribute3		VARCHAR2(150),
Attribute4		VARCHAR2(150),
Attribute5		VARCHAR2(150),
Attribute6		VARCHAR2(150),
Attribute7		VARCHAR2(150),
Attribute8		VARCHAR2(150),
Attribute9		VARCHAR2(150),
Attribute10		VARCHAR2(150),
Attribute11		VARCHAR2(150),
Attribute12		VARCHAR2(150),
Attribute13		VARCHAR2(150),
Attribute14		VARCHAR2(150),
Attribute15		VARCHAR2(150),
Owning_Department_Id	NUMBER,
Activity_Cause_Code	VARCHAR2(30),
Activity_Type_Code	VARCHAR2(30),
Activity_Source_Code	VARCHAR2(30),
Class_Code		VARCHAR2(10),
Maintenance_Object_Id	NUMBER, -- Maintenance Object Id should override asset number and serial number
Maintenance_Object_Type	NUMBER,
Instance_number 	VARCHAR2(30), -- Asset Number
Inventory_Item_Id	NUMBER, -- Asset Group
Serial_Number		VARCHAR2(30), -- Asset Serial Number
Activity_Association_Id	NUMBER, -- Derived
Tagging_Required_Flag	VARCHAR2(1),
Shutdown_Type_Code	VARCHAR2(30),
Tmpl_Flag		VARCHAR2(1),
Return_Status		VARCHAR2(1),
Error_Mesg		VARCHAR2(240)
);

TYPE Activity_Association_Tbl_Type IS TABLE OF Activity_Association_Rec_Type
	INDEX BY BINARY_INTEGER;



-- Start of comments
--	API name 	: Create_Activity
--	Type		: Public
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
--	p_asset_activity_name		IN	EAM_Activity_PUB.Item_Rec_Type,
--	p_asset_activity_description	IN	VARCHAR2 := NULL,
--      p_work_order_rec		IN	EAM_Activity_PUB.Work_Order_Rec_Type,
--	p_operation_copy_option		IN	VARCHAR2 := '2', -- 1 (NONE) or 2 (ALL)
--	p_material_copy_option		IN	VARCHAR2 := '2', -- 1 (NONE), 2 (ISSUED), OR 3 (ALL)
--	p_resource_copy_option		IN	VARCHAR2 := '2', -- 1 (NONE), 2 (ISSUED), OR 3 (ALL)
--	p_association_copy_option	IN	VARCHAR2 := '2', -- 1 (NONE), 2 (CURRENT), OR 3 (ALL)

--	OUT		:
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--	x_inventory_item_id		OUT	NUMBER -- the inventory_item_it the system has created

--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: EAM Business Object API to create Asset Activity from a Work Order.
--			Will assigne Activity to the Work Order's organization, and its master org.
--
-- End of comments
PROCEDURE Create_Activity
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	p_asset_activity		IN	INV_Item_GRP.Item_Rec_Type,
	p_template_id			IN	NUMBER 		:= NULL,
        p_template_name			IN	VARCHAR2 	:= NULL,
	p_activity_type_code		IN	VARCHAR2	:= NULL,
	p_activity_cause_code 		IN	VARCHAR2	:= NULL,
	p_shutdown_type_code		IN	VARCHAR2	:= NULL,
	p_notification_req_flag		IN	VARCHAR2	:= NULL,
	p_activity_source_code		IN	VARCHAR2	:= NULL,

        p_work_order_rec		IN	EAM_Activity_PUB.Work_Order_Rec_Type,
	p_operation_copy_option		IN	NUMBER := 2, -- 1 (NONE) or 2 (ALL)
	p_material_copy_option		IN	NUMBER := 2, -- 1 (NONE), 2 (ISSUED), OR 3 (ALL)
	p_resource_copy_option		IN	NUMBER := 2, -- 1 (NONE), 2 (ISSUED), OR 3 (ALL)
	p_association_copy_option	IN	NUMBER := 2, -- 1 (NONE), 2 (CURRENT), OR 3 (ALL)

--	x_inventory_item_id		OUT	NUMBER, -- the inventory_item_it the system has created
	x_work_order_rec		OUT	NOCOPY EAM_Activity_PUB.Work_Order_Rec_Type,

	x_curr_item_rec			OUT	NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_curr_item_return_status	OUT	NOCOPY	VARCHAR2,
	x_curr_item_error_tbl		OUT	NOCOPY	INV_Item_GRP.Error_Tbl_Type,
	x_master_item_rec		OUT	NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_master_item_return_status	OUT	NOCOPY	VARCHAR2,
	x_master_item_error_tbl		OUT	NOCOPY	INV_Item_GRP.Error_Tbl_Type,

	x_rtg_header_rec		OUT	NOCOPY	BOM_Rtg_Pub.Rtg_Header_Rec_Type,
	x_rtg_revision_tbl		OUT	NOCOPY	BOM_Rtg_Pub.Rtg_Revision_Tbl_Type,
	x_operation_tbl			OUT	NOCOPY	BOM_Rtg_Pub.Operation_Tbl_Type,
	x_op_resource_tbl		OUT	NOCOPY	BOM_Rtg_Pub.Op_Resource_Tbl_Type,
	x_sub_resource_tbl		OUT	NOCOPY	BOM_Rtg_Pub.Sub_Resource_Tbl_Type,
	x_op_network_tbl		OUT	NOCOPY	BOM_Rtg_Pub.Op_Network_Tbl_Type,
	x_rtg_return_status		OUT	NOCOPY	VARCHAR2,
	x_rtg_msg_count			OUT	NOCOPY	NUMBER,
	x_rtg_msg_list			OUT	NOCOPY	Error_Handler.Error_Tbl_Type,

	x_bom_header_rec		OUT	NOCOPY	BOM_BO_PUB.BOM_Head_Rec_Type,
	x_bom_revision_tbl		OUT	NOCOPY	BOM_BO_PUB.BOM_Revision_Tbl_Type,
	x_bom_component_tbl		OUT	NOCOPY	BOM_BO_PUB.BOM_Comps_Tbl_Type,
	x_bom_ref_designator_tbl	OUT	NOCOPY	BOM_BO_PUB.BOM_Ref_Designator_Tbl_Type,
	x_bom_sub_component_tbl		OUT	NOCOPY	BOM_BO_PUB.BOM_Sub_Component_Tbl_Type,
	x_bom_return_status		OUT	NOCOPY	VARCHAR2,
	x_bom_msg_count			OUT	NOCOPY	NUMBER,
	x_bom_msg_list			OUT	NOCOPY	Error_Handler.Error_Tbl_Type,

	x_assoc_return_status		OUT	NOCOPY	VARCHAR2,
	x_assoc_msg_count		OUT	NOCOPY	NUMBER,
	x_assoc_msg_data		OUT	NOCOPY	VARCHAR2,
	x_act_num_association_tbl	OUT	NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type,
	x_activity_association_tbl	OUT	NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type
);

PROCEDURE Copy_Activity
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	-- target activity, need to set org, item name, description
	p_asset_activity		IN	INV_Item_GRP.Item_Rec_Type,


	p_template_id			IN	NUMBER 		:= NULL,
        p_template_name			IN	VARCHAR2 	:= NULL,
	p_activity_type_code		IN	VARCHAR2	:= NULL,
	p_activity_cause_code 		IN	VARCHAR2	:= NULL,
	p_shutdown_type_code		IN	VARCHAR2	:= NULL,
	p_notification_req_flag		IN	VARCHAR2	:= NULL,
	p_activity_source_code		IN	VARCHAR2	:= NULL,

	-- source Activity
	p_source_org_id			IN	NUMBER,
	p_source_activity_id		IN	NUMBER, -- inventory_item_id
	-- source BOM
	p_source_alt_bom_designator	IN	VARCHAR2	:= NULL,
	p_source_bom_rev_date		IN 	DATE		:= sysdate,
	-- source Routing
	p_source_alt_rtg_designator	IN	VARCHAR2	:= NULL,
	p_source_rtg_rev_date		IN	DATE		:= sysdate,

	p_bom_copy_option		IN	NUMBER := 2, -- 1 (NONE) or 2 (ALL)
	p_routing_copy_option		IN	NUMBER := 2, -- 1 (NONE) or 2 (ALL)
	p_association_copy_option	IN	NUMBER := 2, -- 1 (NONE) or 2 (ALL)

	x_curr_item_rec			OUT	NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_curr_item_return_status	OUT	NOCOPY	VARCHAR2,
	x_curr_item_error_tbl		OUT	NOCOPY	INV_Item_GRP.Error_Tbl_Type,
	x_master_item_rec		OUT	NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_master_item_return_status	OUT	NOCOPY	VARCHAR2,
	x_master_item_error_tbl		OUT	NOCOPY	INV_Item_GRP.Error_Tbl_Type,

	x_assoc_return_status		OUT	NOCOPY	VARCHAR2,
	x_assoc_msg_count		OUT	NOCOPY	NUMBER,
	x_assoc_msg_data		OUT	NOCOPY	VARCHAR2,
	x_act_num_association_tbl	OUT	NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type,
	x_activity_association_tbl	OUT	NOCOPY	EAM_Activity_PUB.Activity_Association_Tbl_Type
);


PROCEDURE Create_Activity_From_Form (
	p_wip_entity_id			IN	NUMBER
	, p_asset_activity		IN	VARCHAR2 := NULL
	, p_segment1			IN	VARCHAR2 := NULL
	, p_segment2			IN	VARCHAR2 := NULL
	, p_segment3			IN	VARCHAR2 := NULL
	, p_segment4			IN	VARCHAR2 := NULL
	, p_segment5			IN	VARCHAR2 := NULL
	, p_segment6			IN	VARCHAR2 := NULL
	, p_segment7			IN	VARCHAR2 := NULL
	, p_segment8			IN	VARCHAR2 := NULL
	, p_segment9			IN	VARCHAR2 := NULL
	, p_segment10			IN	VARCHAR2 := NULL
	, p_segment11			IN	VARCHAR2 := NULL
	, p_segment12			IN	VARCHAR2 := NULL
	, p_segment13			IN	VARCHAR2 := NULL
	, p_segment14			IN	VARCHAR2 := NULL
	, p_segment15			IN	VARCHAR2 := NULL
	, p_segment16			IN	VARCHAR2 := NULL
	, p_segment17			IN	VARCHAR2 := NULL
	, p_segment18			IN	VARCHAR2 := NULL
	, p_segment19			IN	VARCHAR2 := NULL
	, p_segment20			IN	VARCHAR2 := NULL
	, p_description			IN	VARCHAR2
	, p_template_id			IN	NUMBER
	, p_activity_type_code		IN	VARCHAR2
	, p_activity_cause_code 	IN	VARCHAR2
	, p_shutdown_type_code		IN	VARCHAR2
	, p_notification_req_flag	IN	VARCHAR2
	, p_activity_source_code	IN	VARCHAR2

	, p_operation_copy_option	IN	NUMBER
	, p_material_copy_option	IN	NUMBER
	, p_resource_copy_option	IN	NUMBER
	, p_association_copy_option	IN	NUMBER
	, x_successful			OUT NOCOPY	BOOLEAN
	);

PROCEDURE Create_Activity_With_Template(
 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	p_organization_id		IN	NUMBER 		:= NULL,
	p_organization_code		IN	NUMBER		:= NULL,
	p_asset_activity		IN	VARCHAR2 := NULL,
	p_segment1			IN	VARCHAR2 := NULL,
	p_segment2			IN	VARCHAR2 := NULL,
	p_segment3			IN	VARCHAR2 := NULL,
	p_segment4			IN	VARCHAR2 := NULL,
	p_segment5			IN	VARCHAR2 := NULL,
	p_segment6			IN	VARCHAR2 := NULL,
	p_segment7			IN	VARCHAR2 := NULL,
	p_segment8			IN	VARCHAR2 := NULL,
	p_segment9			IN	VARCHAR2 := NULL,
	p_segment10			IN	VARCHAR2 := NULL,
	p_segment11			IN	VARCHAR2 := NULL,
	p_segment12			IN	VARCHAR2 := NULL,
	p_segment13			IN	VARCHAR2 := NULL,
	p_segment14			IN	VARCHAR2 := NULL,
	p_segment15			IN	VARCHAR2 := NULL,
	p_segment16			IN	VARCHAR2 := NULL,
	p_segment17			IN	VARCHAR2 := NULL,
	p_segment18			IN	VARCHAR2 := NULL,
	p_segment19			IN	VARCHAR2 := NULL,
	p_segment20			IN	VARCHAR2 := NULL,
	p_description			IN	VARCHAR2,
	p_template_id			IN	NUMBER 		:= NULL,
	p_template_name			IN	VARCHAR2 	:= NULL,
	p_activity_type_code		IN	VARCHAR2	:= NULL,
	p_activity_cause_code 		IN	VARCHAR2	:= NULL,
	p_shutdown_type_code		IN	VARCHAR2	:= NULL,
	p_notification_req_flag		IN	VARCHAR2	:= NULL,
	p_activity_source_code		IN	VARCHAR2	:= NULL,

	x_curr_item_rec			OUT NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_curr_item_return_status	OUT NOCOPY	VARCHAR2,
	x_curr_item_error_tbl		OUT NOCOPY	INV_Item_GRP.Error_Tbl_Type,
	x_master_item_rec		OUT NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_master_item_return_status	OUT NOCOPY	VARCHAR2,
	x_master_item_error_tbl		OUT NOCOPY	INV_Item_GRP.Error_Tbl_Type
);

-- From Saurabh
procedure create_bom_header(
	p_target_item_rec		IN INV_Item_GRP.Item_Rec_Type,
	--p_source_org_id			IN	NUMBER,
	--p_source_activity_id		IN	NUMBER, -- inventory_item_id

	--p_material_copy_option		IN NUMBER,

	x_bom_header_rec		OUT NOCOPY	BOM_BO_PUB.BOM_Head_Rec_Type,
	x_bom_revision_tbl		OUT NOCOPY	BOM_BO_PUB.BOM_Revision_Tbl_Type,
	x_bom_component_tbl		OUT NOCOPY	BOM_BO_PUB.BOM_Comps_Tbl_Type,
	x_bom_ref_designator_tbl	OUT NOCOPY	BOM_BO_PUB.BOM_Ref_Designator_Tbl_Type,
	x_bom_sub_component_tbl		OUT NOCOPY	BOM_BO_PUB.BOM_Sub_Component_Tbl_Type,
	x_bom_return_status		OUT NOCOPY	VARCHAR2,
	x_bom_msg_count			OUT NOCOPY	NUMBER,
	x_bom_msg_list			OUT NOCOPY	Error_Handler.Error_Tbl_Type
);

procedure create_bom_header_form(
    --p_target_item_rec		IN INV_Item_GRP.Item_Rec_Type,
    p_inventory_item_name varchar2,
    p_organization_code varchar2,
    x_return_status     OUT NOCOPY	VARCHAR2
);

PROCEDURE Create_Activity_With_Template(
 	--p_api_version           	IN	NUMBER				,
  	--p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	--p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	--p_validation_level		IN  	NUMBER	:=
						--FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	varchar2		  	,
	--x_msg_count			OUT	NUMBER				,
	--x_msg_data			OUT	VARCHAR2			,

	p_organization_id		IN	NUMBER 		:= NULL,
	p_organization_code		IN	NUMBER		:= NULL,
	p_asset_activity		IN	VARCHAR2 := NULL,
	p_segment1			IN	VARCHAR2 := NULL,
	p_segment2			IN	VARCHAR2 := NULL,
	p_segment3			IN	VARCHAR2 := NULL,
	p_segment4			IN	VARCHAR2 := NULL,
	p_segment5			IN	VARCHAR2 := NULL,
	p_segment6			IN	VARCHAR2 := NULL,
	p_segment7			IN	VARCHAR2 := NULL,
	p_segment8			IN	VARCHAR2 := NULL,
	p_segment9			IN	VARCHAR2 := NULL,
	p_segment10			IN	VARCHAR2 := NULL,
	p_segment11			IN	VARCHAR2 := NULL,
	p_segment12			IN	VARCHAR2 := NULL,
	p_segment13			IN	VARCHAR2 := NULL,
	p_segment14			IN	VARCHAR2 := NULL,
	p_segment15			IN	VARCHAR2 := NULL,
	p_segment16			IN	VARCHAR2 := NULL,
	p_segment17			IN	VARCHAR2 := NULL,
	p_segment18			IN	VARCHAR2 := NULL,
	p_segment19			IN	VARCHAR2 := NULL,
	p_segment20			IN	VARCHAR2 := NULL,
	p_description			IN	VARCHAR2,
	p_template_id			IN	NUMBER 		:= NULL,
	p_template_name			IN	VARCHAR2 	:= NULL,
	p_activity_type_code		IN	VARCHAR2	:= NULL,
	p_activity_cause_code 		IN	VARCHAR2	:= NULL,
	p_shutdown_type_code		IN	VARCHAR2	:= NULL,
	p_notification_req_flag		IN	VARCHAR2	:= NULL,
	p_activity_source_code		IN	VARCHAR2	:= NULL

	--x_curr_item_rec			OUT	INV_Item_GRP.Item_Rec_Type,
	--x_curr_item_return_status	OUT	VARCHAR2,
	--x_curr_item_error_tbl		OUT	INV_Item_GRP.Error_Tbl_Type,
	--x_master_item_rec		OUT	INV_Item_GRP.Item_Rec_Type,
	--x_master_item_return_status	OUT	VARCHAR2,
	--x_master_item_error_tbl		OUT	INV_Item_GRP.Error_Tbl_Type
);

PROCEDURE Create_Routing_Header(
	p_target_item_rec			IN INV_Item_GRP.Item_Rec_Type,

	x_rtg_header_rec		OUT NOCOPY	BOM_Rtg_Pub.Rtg_Header_Rec_Type,
	x_rtg_revision_tbl		OUT NOCOPY	BOM_Rtg_Pub.Rtg_Revision_Tbl_Type,
	x_operation_tbl			OUT NOCOPY	BOM_Rtg_Pub.Operation_Tbl_Type,
	x_op_resource_tbl		OUT NOCOPY	BOM_Rtg_Pub.Op_Resource_Tbl_Type,
	x_sub_resource_tbl		OUT NOCOPY	BOM_Rtg_Pub.Sub_Resource_Tbl_Type,
	x_op_network_tbl		OUT NOCOPY	BOM_Rtg_Pub.Op_Network_Tbl_Type,
	x_rtg_return_status		OUT NOCOPY	VARCHAR2,
	x_rtg_msg_count			OUT NOCOPY	NUMBER,
	x_rtg_msg_list			OUT NOCOPY	Error_Handler.Error_Tbl_Type
);

procedure create_routing_header_form(
    --p_target_item_rec		IN INV_Item_GRP.Item_Rec_Type,
    p_inventory_item_name varchar2,
    p_organization_code varchar2,
    x_return_status     OUT NOCOPY	VARCHAR2
);

-- from Saurabh
-- package spec.
-- wrapper API used to call Copy_Activity procedure from form
procedure Copy_Activity(
    	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

    	p_activity_item_name 		IN 	VARCHAR2 := NULL,
	p_segment1			IN	VARCHAR2 := NULL,
	p_segment2			IN	VARCHAR2 := NULL,
	p_segment3			IN	VARCHAR2 := NULL,
	p_segment4			IN	VARCHAR2 := NULL,
	p_segment5			IN	VARCHAR2 := NULL,
	p_segment6			IN	VARCHAR2 := NULL,
	p_segment7			IN	VARCHAR2 := NULL,
	p_segment8			IN	VARCHAR2 := NULL,
	p_segment9			IN	VARCHAR2 := NULL,
	p_segment10			IN	VARCHAR2 := NULL,
	p_segment11			IN	VARCHAR2 := NULL,
	p_segment12			IN	VARCHAR2 := NULL,
	p_segment13			IN	VARCHAR2 := NULL,
	p_segment14			IN	VARCHAR2 := NULL,
	p_segment15			IN	VARCHAR2 := NULL,
	p_segment16			IN	VARCHAR2 := NULL,
	p_segment17			IN	VARCHAR2 := NULL,
	p_segment18			IN	VARCHAR2 := NULL,
	p_segment19			IN	VARCHAR2 := NULL,
	p_segment20			IN	VARCHAR2 := NULL,
	p_activity_org_id 		IN 	NUMBER,
	p_activity_description 		IN	VARCHAR2,

    	p_template_id			IN	NUMBER 		:= NULL,
        p_template_name			IN	VARCHAR2 	:= NULL,
        p_activity_type_code		IN	VARCHAR2	:= NULL,
	p_activity_cause_code 		IN	VARCHAR2	:= NULL,
	p_shutdown_type_code		IN	VARCHAR2	:= NULL,
	p_notification_req_flag		IN	VARCHAR2	:= NULL,
	p_activity_source_code		IN	VARCHAR2	:= NULL,

	-- source Activity
	p_source_org_id			IN	NUMBER,
	p_source_activity_id		IN	NUMBER, -- inventory_item_id
    	p_bom_copy_option		IN	NUMBER := 2, -- 1 (NONE) or 2 (ALL)
	p_routing_copy_option		IN	NUMBER := 2, -- 1 (NONE) or 2 (ALL)
	p_association_copy_option	IN	NUMBER := 2 -- 1 (NONE) or 2 (ALL)

);

/* Procedure to assign the activity to the current maintenance organization */

PROCEDURE Activity_org_assign
( 	p_api_version           IN   	        NUMBER				,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	p_org_id	        IN		NUMBER,
	p_activity_id	        IN		NUMBER -- inventory_item_id
);




END EAM_Activity_PUB;


 

/

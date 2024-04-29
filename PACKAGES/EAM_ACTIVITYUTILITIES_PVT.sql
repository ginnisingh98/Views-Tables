--------------------------------------------------------
--  DDL for Package EAM_ACTIVITYUTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ACTIVITYUTILITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVAAUS.pls 120.1 2005/06/13 04:09:50 appldev  $ */

-- ======================================================================
-- Utility Procedures
PROCEDURE Validate_Organization
(	p_organization_id		IN	NUMBER,
	p_organization_code		IN	VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_organization_id		OUT NOCOPY	NUMBER,
	x_organization_code		OUT NOCOPY	VARCHAR2
);

-- ----------------------------------------------------------------------
PROCEDURE Validate_Work_Order
(
	p_work_order_rec		IN	EAM_Activity_PUB.Work_Order_Rec_Type,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_work_order_rec		OUT NOCOPY	EAM_Activity_PUB.Work_Order_Rec_Type
);

-- ----------------------------------------------------------------------
FUNCTION Get_Item_Concatenated_Segments(
	p_organization_id	IN	NUMBER,
	p_inventory_item_id	IN	NUMBER
)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION Get_Act_Id_From_Work_Order(
	p_wip_entity_id		IN	NUMBER
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Get_Org_Id_From_Work_Order(
	p_wip_entity_id		IN	NUMBER
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Get_Department_Code(
	p_organization_id	IN	NUMBER,
	p_department_id		IN	NUMBER
)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION Get_Resource_Code(
	p_organization_id	IN	NUMBER,
	p_resource_id		IN	NUMBER
)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION Get_Expense_Account_Id(
	p_organization_id	IN	NUMBER
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
PROCEDURE Get_Asset_From_WO(
	p_wip_entity_id		IN	NUMBER,
	x_inventory_item_id	OUT NOCOPY	NUMBER,
	x_serial_number		OUT NOCOPY	VARCHAR2
);

-- ----------------------------------------------------------------------
FUNCTION Get_Asset_Owning_Dept_Id(
	p_organization_id	IN	NUMBER,
	p_inventory_item_id	IN	NUMBER,
	p_serial_number		IN	VARCHAR2
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Get_WO_Res_Scheduled_Units(
	p_organization_id 	IN NUMBER,
	p_wip_entity_id		IN NUMBER,
	p_operation_seq_num	IN NUMBER,
	p_resource_seq_num	IN NUMBER
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Get_Master_Org_Id(
	p_organization_id	IN NUMBER
)
RETURN NUMBER;

-- ----------------------------------------------------------------------

PROCEDURE Validate_Asset_Number(
	p_instance_number	IN 	VARCHAR2,
	p_organization_id	IN 	NUMBER,
	p_inventory_item_id	IN 	NUMBER,
	p_serial_number		IN 	VARCHAR2,

	x_return_status		OUT NOCOPY 	VARCHAR2,
	x_error_mesg		OUT NOCOPY	VARCHAR2,

	x_maintenance_object_id		OUT NOCOPY	NUMBER,
	x_maintenance_object_type	OUT NOCOPY	NUMBER
);

-- ----------------------------------------------------------------------
FUNCTION Get_Cost_Activity(
	p_activity_id		IN	NUMBER
)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION Get_Locator(
	p_organization_id	IN	NUMBER,
	p_subinventory_code	IN	VARCHAR2,
	p_locator_id		IN	NUMBER
)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------
PROCEDURE Get_Op_Coordinates(
	p_organization_id	IN	NUMBER,
	p_wip_entity_id		IN	NUMBER,
	p_operation_seq_num	IN	NUMBER,
	x_x_pos			OUT NOCOPY	NUMBER,
	x_y_pos			OUT NOCOPY	NUMBER
);

-- ----------------------------------------------------------------------
FUNCTION Get_Bom_Sequence_Id(
	p_organization_id		IN	NUMBER,
	p_assembly_item_id		IN	NUMBER,
	p_alternate_bom_designator	IN	VARCHAR2
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Get_Rtg_Sequence_Id(
	p_organization_id		IN	NUMBER,
	p_assembly_item_id		IN	NUMBER,
	p_alternate_rtg_designator	IN	VARCHAR2
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Get_Gen_Object_Id(
	p_organization_id		IN	NUMBER,
	p_inventory_item_id		IN	NUMBER,
	p_serial_number			IN	VARCHAR2
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
PROCEDURE Get_Item_Info_From_WO(
	p_wip_entity_id			IN		NUMBER,
	x_source_org_id			OUT NOCOPY 	NUMBER,
	x_source_activity_id		OUT NOCOPY	NUMBER,
	x_wo_maint_id			OUT NOCOPY	NUMBER,
	x_wo_maint_type			OUT NOCOPY	NUMBER
);

-- ----------------------------------------------------------------------
FUNCTION Default_Owning_Department_Id(
	p_activity_association_id	IN	NUMBER,
	p_instance_id			IN	NUMBER,
	p_organization_id		IN	NUMBER
)
RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION Is_Item_Serialized(
	p_organization_id	IN	NUMBER,
	p_maint_id		IN	NUMBER,
	p_maint_type		IN	NUMBER

)
RETURN BOOLEAN;

-- ----------------------------------------------------------------------
g_YES	CONSTANT	NUMBER := 1;
g_NO	CONSTANT	NUMBER := 2;

-- ----------------------------------------------------------------------
-- For logging
Debug_File      	UTL_FILE.FILE_TYPE;
-- If Is_Debug NULL, treat as g_NO
Is_Debug	NUMBER := nvl(FND_PROFILE.VALUE('EAM_ABO_IS_DEBUG'), g_NO);
Debug_File_Name VARCHAR2(2000) := FND_PROFILE.VALUE('EAM_ABO_DEBUG_FILE_NAME');
Debug_File_Dir	VARCHAR2(2000) := FND_PROFILE.VALUE('EAM_ABO_DEBUG_FILE_DIR');
Log_Index		NUMBER			:= 1;

PROCEDURE Open_Debug_Session;
PROCEDURE Write_Debug(
	p_debug_message      IN  VARCHAR2
);
PROCEDURE Close_Debug_Session;
PROCEDURE Add_Message(
	p_message_level			IN	NUMBER
);
PROCEDURE Log_Item_Error_Tbl(
	p_item_error_tbl		IN	INV_Item_GRP.Error_Tbl_Type
);
PROCEDURE Log_Bom_Error_Tbl(
	p_bom_error_tbl			IN	Error_Handler.Error_Tbl_Type
);


PROCEDURE Log_Process_Rtg_Parameters(
	p_rtg_header_rec 	IN	BOM_RTG_PUB.Rtg_Header_Rec_Type,
	p_operation_tbl		IN	BOM_RTG_PUB.Operation_Tbl_Type,
	p_op_resource_tbl	IN	BOM_RTG_PUB.Op_Resource_Tbl_Type,
	p_op_network_tbl	IN	BOM_RTG_PUB.Op_Network_Tbl_Type
);
PROCEDURE Log_Rtg_Header_Rec(
	rtg_header_rec	IN	BOM_RTG_PUB.Rtg_Header_Rec_Type
);
PROCEDURE Log_Rtg_Operation_Tbl(
	operation_tbl		IN	BOM_RTG_PUB.Operation_Tbl_Type
);
PROCEDURE Log_Rtg_Op_Resource_Tbl(
	op_resource_tbl	IN	BOM_RTG_PUB.Op_Resource_Tbl_Type
);
PROCEDURE Log_Rtg_Op_Network_Tbl(
	op_network_tbl	IN	BOM_RTG_PUB.Op_Network_Tbl_Type
);

PROCEDURE Log_Process_BOM_Parameters(
	p_bom_header_rec	IN 	BOM_BO_PUB.Bom_Head_Rec_Type,
	p_bom_component_tbl	IN	BOM_BO_PUB.Bom_Comps_Tbl_Type
);
PROCEDURE Log_Bom_Header_Rec(
	bom_header_rec	IN	BOM_BO_PUB.Bom_Head_Rec_Type
);
PROCEDURE Log_Bom_Component_Tbl(
	bom_component_tbl	IN	BOM_BO_PUB.Bom_Comps_Tbl_Type
);

PROCEDURE Log_Inv_Item_Rec(
	item_rec	IN	INV_Item_GRP.Item_rec_type
);

-- ----------------------------------------------------------------------
FUNCTION Get_First_N_Messages(
	p_n		IN	NUMBER
)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------
-- From Saurabh
-- specs in EAM_ACTIVITYUTILITIES_PVT
FUNCTION BOM_Exists(
    p_org_id in number,
    p_inventory_item_id in number
)
return boolean;

FUNCTION Routing_Exists(
    p_org_id in number,
    p_inventory_item_id in number
)
return boolean;


-- ----------------------------------------------------------------------
FUNCTION IS_ACTIVITY_ASSIGNED(
	p_activity_id	IN	NUMBER,
	p_org_id        IN	NUMBER
)
RETURN BOOLEAN;

-- ----------------------------------------------------------------------
-- To be used in Activity WB view
FUNCTION get_next_service_start_date
(
	p_activity_association_id	IN	NUMBER,
	p_maintenance_object_id		IN	NUMBER,
	p_maintenance_object_type	IN	NUMBER := 3
)
RETURN DATE;

-- ----------------------------------------------------------------------
-- To be used in Activity WB view
FUNCTION get_next_service_end_date
(
	p_activity_association_id	IN	NUMBER,
	p_maintenance_object_id		IN	NUMBER,
	p_maintenance_object_type	IN	NUMBER := 3
)
RETURN DATE;
-- ----------------------------------------------------------------------


-- End of Utility Procedures
-- ======================================================================

END EAM_ActivityUtilities_PVT;

 

/

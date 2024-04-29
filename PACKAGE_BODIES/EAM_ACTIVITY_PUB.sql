--------------------------------------------------------
--  DDL for Package Body EAM_ACTIVITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ACTIVITY_PUB" AS
/* $Header: EAMPACTB.pls 120.2.12010000.2 2009/03/31 05:28:36 ngoutam ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_AssetActivity_PUB';


-- ======================================================================
-- Private Helper Functions

PROCEDURE Validate_Copy_Activity_Options(
	p_bom_copy_option		IN	NUMBER,
	p_routing_copy_option		IN	NUMBER,
	p_association_copy_option	IN	NUMBER
)
IS
BEGIN

	IF p_bom_copy_option NOT IN (1, 2) THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACTCOPY_BOM_COPY_OPT');
--		FND_MESSAGE.SET_ENCODED('BOM Copy Option should be 1 (NONE) or 2 (ALL).');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_routing_copy_option NOT IN (1, 2) THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACTCOPY_RTG_COPY_OPT');
--		FND_MESSAGE.SET_ENCODED('Routing Copy Option should be 1 (NONE) or 2 (ALL).');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_bom_copy_option NOT IN (1, 2) THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACTCOPY_ASC_COPY_OPT');
--		FND_MESSAGE.SET_ENCODED('Association Copy Option should be 1 (NONE) or 2 (ALL).');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

END;

PROCEDURE Validate_Copy_Options(
	p_work_order_rec		IN EAM_Activity_PUB.Work_Order_Rec_Type,
	p_operation_copy_option		IN NUMBER,
	p_material_copy_option		IN NUMBER,
	p_resource_copy_option		IN NUMBER,
	p_association_copy_option	IN NUMBER
)
IS
	l_activity_id_from_wo		NUMBER;
BEGIN
	-- Validate p_operation_copy_option, p_material_copy_option, and p_resource_copy_option
	IF p_operation_copy_option = 1 THEN
		-- p_operation_copy_option = 1 (NONE)
		-- p_material_copy_option and p_resource_copy_option both as to be 1 (NONE)
		IF p_material_copy_option <> 1 THEN
			-- Error: Material Copy Option has to be 1 (NONE) when Operation Copy Option is 1 (NONE).
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_MAT_COPY_OPT_NOT_NONE');
--			FND_MESSAGE.SET_ENCODED('Material Copy Option has to be 1 (NONE) when Operation Copy Option is 1 (NONE).');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		IF p_resource_copy_option <> 1 THEN
			-- Error: Resource Copy Option has to be 1 (NONE) when Operation Copy Option is 1 (NONE).
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_RES_COPY_OPT_NOT_NONE');
--			FND_MESSAGE.SET_ENCODED('Resource Copy Option has to be 1 (NONE) when Operation Copy Option is 1 (NONE).');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	ELSIF p_operation_copy_option = 2 THEN
		-- p_operation_copy_option = 2 (ALL)
		-- p_material_copy_option and p_resource_copy_option can be 1 (NONE), 2 (ISSUED), or 3 (ALL)

		IF p_material_copy_option NOT IN (1, 2, 3) THEN
			-- Error: Material Copy Option should be either 1 (NONE), 2 (ISSUED), or 3 (ALL).
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_MAT_COPY_OPT_INVALID');
--			FND_MESSAGE.SET_ENCODED('Material Copy Option should be either 1 (NONE), 2 (ISSUED), or 3 (ALL).');
			RAISE FND_API.G_EXC_ERROR;
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		END IF;
		IF p_resource_copy_option NOT IN (1, 2, 3) THEN
			-- Error: Resource Copy Option should be either 1 (NONE), 2 (ISSUED), or 3 (ALL).
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_RES_COPY_OPT_INVALID');
--			FND_MESSAGE.SET_ENCODED('Resource Copy Option should be either 1 (NONE), 2 (ISSUED), or 3 (ALL).');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	ELSE
		-- Error: Operation Copy Option should be either 1 (NONE), or 2 (ALL).
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_OP_COPY_OPT_INVALID');
--		FND_MESSAGE.SET_ENCODED('Operation Copy Option should be either 1 (NONE), or 2 (ALL).');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Validation of p_association_copy_option is independent of the others.

	-- First need to find out if source Work Order as an Activity linked to it.


	-- 2003-01-10: Enchancement: if source Work Order has no Activity, treat Copy Option All as Current
	-- So don't have to check for source Work Order Activity any more.

	/*
	l_activity_id_from_wo := EAM_ActivityUtilities_PVT.Get_Act_Id_From_Work_Order(p_work_order_rec.wip_entity_id);
	IF l_activity_id_from_wo IS NULL THEN
		-- No Activity linked to source Work Order
		IF p_association_copy_option NOT IN (1, 2) THEN
			-- Error: When Source Work Order is not linked to an Activity, Association Copy Option should be either 1 (NONE), or 2 (CURRENT).
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ASSO_COPY_OPT_NO_ACT');
--			FND_MESSAGE.SET_ENCODED('When Source Work Order is not linked to an Activity, Association Copy Option should be either 1 (NONE), or 2 (CURRENT).');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	ELSE
		-- l_activity_id_from_wo IS NOT NULL
*/
		IF p_association_copy_option NOT IN (1, 2, 3) THEN
			-- Error: Association Copy Option should be either 1 (NONE), 2 (CURRENT), or 3 (ALL).
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ASSO_COPY_OPT_INVALID');
--			FND_MESSAGE.SET_ENCODED('Association Copy Option should be either 1 (NONE), 2 (CURRENT), or 3 (ALL).');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
/*
	END IF;
*/
END;

-- ----------------------------------------------------------------------
PROCEDURE Create_Activity_Routing(
	p_target_item_rec			IN INV_Item_GRP.Item_Rec_Type,
	p_work_order_rec		IN EAM_Activity_PUB.Work_Order_Rec_Type,
	p_operation_copy_option		IN NUMBER,
	p_resource_copy_option		IN NUMBER,

	x_rtg_header_rec		OUT NOCOPY	BOM_Rtg_Pub.Rtg_Header_Rec_Type,
	x_rtg_revision_tbl		OUT NOCOPY	BOM_Rtg_Pub.Rtg_Revision_Tbl_Type,
	x_operation_tbl			OUT NOCOPY	BOM_Rtg_Pub.Operation_Tbl_Type,
	x_op_resource_tbl		OUT NOCOPY	BOM_Rtg_Pub.Op_Resource_Tbl_Type,
	x_sub_resource_tbl		OUT NOCOPY	BOM_Rtg_Pub.Sub_Resource_Tbl_Type,
	x_op_network_tbl		OUT NOCOPY	BOM_Rtg_Pub.Op_Network_Tbl_Type,
	x_rtg_return_status		OUT NOCOPY	VARCHAR2,
	x_rtg_msg_count			OUT NOCOPY	NUMBER,
	x_rtg_msg_list			OUT NOCOPY	Error_Handler.Error_Tbl_Type
)

IS
l_current_date			CONSTANT DATE := sysdate;
l_effectivity_date		CONSTANT DATE := l_current_date;
l_create_txn_type		CONSTANT VARCHAR(10) := 'CREATE';

-- misc local var
l_x_pos				NUMBER;
l_y_pos				NUMBER;

-- local variables for call the Routing Business Object API
l_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
l_operation_tbl			BOM_RTG_PUB.Operation_Tbl_Type;
l_operation_tbl_index		BINARY_INTEGER;
l_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
l_op_resource_tbl_index		BINARY_INTEGER;
l_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
l_op_network_tbl_index		BINARY_INTEGER;

l_x_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
l_x_rtg_revision_tbl		BOM_RTG_PUB.Rtg_Revision_Tbl_Type;
l_x_operation_tbl		BOM_RTG_PUB.Operation_Tbl_Type;
l_x_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
l_x_sub_resource_tbl		BOM_RTG_PUB.Sub_Resource_Tbl_Type;
l_x_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
l_x_rtg_return_status		VARCHAR2(1);
l_x_rtg_msg_count		NUMBER;
l_x_rtg_msg_list		Error_Handler.Error_Tbl_Type;

CURSOR wip_operation_cur (
	p_organization_id	IN	NUMBER
,	p_wip_entity_id		IN	NUMBER
)
IS
	SELECT 	*
	FROM 	wip_operations
	WHERE	wip_entity_id = p_wip_entity_id
	AND	organization_id = p_organization_id;

CURSOR wip_op_network_cur (
	p_organization_id	IN	NUMBER
	, p_wip_entity_id	IN	NUMBER
)
IS
	SELECT 	*
	FROM	wip_operation_networks
	WHERE	organization_id = p_organization_id
	AND	wip_entity_id = p_wip_entity_id;

CURSOR wip_resource_cur (
	p_organization_id	IN	NUMBER
,	p_wip_entity_id		IN	NUMBER
)
IS
	SELECT	*
	FROM	wip_operation_resources
	WHERE	organization_id = p_organization_id
	AND	wip_entity_id = p_wip_entity_id;

BEGIN
	EAM_ActivityUtilities_PVT.Write_Debug('---------- Entering EAM_Activity_PUB.Create_Activity_Routing ----------');
	EAM_ActivityUtilities_PVT.Write_Debug('p_operation_copy_option=' || p_operation_copy_option);
	EAM_ActivityUtilities_PVT.Write_Debug('p_resource_copy_option=' || p_resource_copy_option);
	EAM_ActivityUtilities_PVT.Write_Debug('p_target_item_rec.organization_id=' || p_target_item_rec.organization_id);
	EAM_ActivityUtilities_PVT.Write_Debug('p_target_item_rec.organization_code=' || p_target_item_rec.organization_code);
	EAM_ActivityUtilities_PVT.Write_Debug('p_target_item_rec.inventory_item_id=' || p_target_item_rec.inventory_item_id);
	EAM_ActivityUtilities_PVT.Write_Debug('p_target_item_rec.item_number=' || p_target_item_rec.item_number);
	EAM_ActivityUtilities_PVT.Write_Debug('p_work_order_rec.organization_id=' || p_work_order_rec.organization_id);
	EAM_ActivityUtilities_PVT.Write_Debug('p_work_order_rec.organization_code=' || p_work_order_rec.organization_code);
	EAM_ActivityUtilities_PVT.Write_Debug('p_work_order_rec.wip_entity_id=' || p_work_order_rec.wip_entity_id);
	EAM_ActivityUtilities_PVT.Write_Debug('p_work_order_rec.wip_entity_name=' || p_work_order_rec.wip_entity_name);


	-- Create Operations
	-- We need 1 Routing Header, table of Operations and Operation Networks, and table of Resources
	IF p_operation_copy_option = 2 THEN
		-- p_operation_copy_option = 2 (ALL)

		-- 2 a) Set up rtg_header_rec
		-- First initialize record fields to NULL
--		l_rtg_header_rec := NULL;
		-- populate fields
		l_rtg_header_rec.Assembly_Item_Name := p_target_item_rec.Item_Number;
		l_rtg_header_rec.Organization_Code := p_target_item_rec.Organization_Code;
		l_rtg_header_rec.Transaction_Type := l_create_txn_type;

		-- 2 b) Create operations
		l_operation_tbl_index := 1;
		FOR l_wip_operation_row IN wip_operation_cur(p_work_order_rec.organization_id,
							     p_work_order_rec.wip_entity_id)
		LOOP
			-- First initialize the fields of the record to NULL
--			l_operation_tbl(l_operation_tbl_index) := NULL;
			-- Then populate fields from cursor.
			l_operation_tbl(l_operation_tbl_index).Transaction_Type := l_create_txn_type;
			l_operation_tbl(l_operation_tbl_index).Organization_Code := l_rtg_header_rec.Organization_Code;
			l_operation_tbl(l_operation_tbl_index).Assembly_Item_Name := l_rtg_header_rec.Assembly_Item_Name;
			l_operation_tbl(l_operation_tbl_index).Operation_Sequence_Number := l_wip_operation_row.Operation_Seq_Num;
			l_operation_tbl(l_operation_tbl_index).Start_Effective_Date := l_effectivity_date;
			l_operation_tbl(l_operation_tbl_index).Department_Code :=
				EAM_ActivityUtilities_PVT.Get_Department_Code(l_wip_operation_row.Organization_Id,
										l_wip_operation_row.department_id);
			l_operation_tbl(l_operation_tbl_index).Operation_Description := l_wip_operation_row.Description;
			l_operation_tbl(l_operation_tbl_index).Count_Point_Type := l_wip_operation_row.count_point_type;
			l_operation_tbl(l_operation_tbl_index).Backflush_Flag := l_wip_operation_row.Backflush_Flag;
			l_operation_tbl(l_operation_tbl_index).Minimum_Transfer_Quantity := l_wip_operation_row.Minimum_Transfer_Quantity;
			l_operation_tbl(l_operation_tbl_index).Shutdown_Type := l_wip_operation_row.Shutdown_Type;
			l_operation_tbl(l_operation_tbl_index).Yield := l_wip_operation_row.Operation_Yield;
			l_operation_tbl(l_operation_tbl_index).Op_Yield_Enabled_Flag := l_wip_operation_row.Operation_Yield_Enabled;

			l_operation_tbl(l_operation_tbl_index).Attribute_Category := l_wip_operation_row.Attribute_Category;
			l_operation_tbl(l_operation_tbl_index).Attribute1 := l_wip_operation_row.Attribute1;
			l_operation_tbl(l_operation_tbl_index).Attribute2 := l_wip_operation_row.Attribute2;
			l_operation_tbl(l_operation_tbl_index).Attribute3 := l_wip_operation_row.Attribute3;
			l_operation_tbl(l_operation_tbl_index).Attribute4 := l_wip_operation_row.Attribute4;
			l_operation_tbl(l_operation_tbl_index).Attribute5 := l_wip_operation_row.Attribute5;
			l_operation_tbl(l_operation_tbl_index).Attribute6 := l_wip_operation_row.Attribute6;
			l_operation_tbl(l_operation_tbl_index).Attribute7 := l_wip_operation_row.Attribute7;
			l_operation_tbl(l_operation_tbl_index).Attribute8 := l_wip_operation_row.Attribute8;
			l_operation_tbl(l_operation_tbl_index).Attribute9 := l_wip_operation_row.Attribute9;
			l_operation_tbl(l_operation_tbl_index).Attribute10 := l_wip_operation_row.Attribute10;
			l_operation_tbl(l_operation_tbl_index).Attribute11 := l_wip_operation_row.Attribute11;
			l_operation_tbl(l_operation_tbl_index).Attribute12 := l_wip_operation_row.Attribute12;
			l_operation_tbl(l_operation_tbl_index).Attribute13 := l_wip_operation_row.Attribute13;
			l_operation_tbl(l_operation_tbl_index).Attribute14 := l_wip_operation_row.Attribute14;
			l_operation_tbl(l_operation_tbl_index).Attribute15 := l_wip_operation_row.Attribute15;

			--Added for bug 7678514
			l_operation_tbl(l_operation_tbl_index).Long_Description :=l_wip_operation_row.Long_Description;

			l_operation_tbl_index := l_operation_tbl_index + 1;
		END LOOP;

		-- 2 c) Create Operation Networks
		l_op_network_tbl_index := 1;
		FOR l_wip_op_network_row IN wip_op_network_cur(p_work_order_rec.organization_id,
							       p_work_order_rec.wip_entity_id)
		LOOP
--			l_op_network_tbl(l_op_network_tbl_index) := NULL;
			l_op_network_tbl(l_op_network_tbl_index).Transaction_Type := l_create_txn_type;
			l_op_network_tbl(l_op_network_tbl_index).Organization_Code := l_rtg_header_rec.Organization_Code;
			l_op_network_tbl(l_op_network_tbl_index).Assembly_Item_Name := l_rtg_header_rec.Assembly_Item_Name;
			l_op_network_tbl(l_op_network_tbl_index).From_Op_Seq_Number := l_wip_op_network_row.Prior_Operation;
			l_op_network_tbl(l_op_network_tbl_index).From_Start_Effective_Date := l_effectivity_date;
			l_op_network_tbl(l_op_network_tbl_index).To_Op_Seq_Number := l_wip_op_network_row.Next_Operation;
			l_op_network_tbl(l_op_network_tbl_index).To_Start_Effective_Date := l_effectivity_date;

			EAM_ActivityUtilities_PVT.Get_Op_Coordinates(
				p_organization_id => p_work_order_rec.organization_id,
				p_wip_entity_id => p_work_order_rec.wip_entity_id,
				p_operation_seq_num => l_wip_op_network_row.Prior_Operation,
				x_x_pos => l_x_pos,
				x_y_pos => l_y_pos
			);
			l_op_network_tbl(l_op_network_tbl_index).From_X_Coordinate := l_x_pos;
			l_op_network_tbl(l_op_network_tbl_index).From_Y_Coordinate := l_y_pos;

			EAM_ActivityUtilities_PVT.Get_Op_Coordinates(
				p_organization_id => p_work_order_rec.organization_id,
				p_wip_entity_id => p_work_order_rec.wip_entity_id,
				p_operation_seq_num => l_wip_op_network_row.Next_Operation,
				x_x_pos => l_x_pos,
				x_y_pos => l_y_pos
			);
			l_op_network_tbl(l_op_network_tbl_index).To_X_Coordinate := l_x_pos;
			l_op_network_tbl(l_op_network_tbl_index).To_Y_Coordinate := l_y_pos;

			l_op_network_tbl(l_op_network_tbl_index).Attribute_Category := l_wip_op_network_row.Attribute_Category;
			l_op_network_tbl(l_op_network_tbl_index).Attribute1 := l_wip_op_network_row.Attribute1;
			l_op_network_tbl(l_op_network_tbl_index).Attribute2 := l_wip_op_network_row.Attribute2;
			l_op_network_tbl(l_op_network_tbl_index).Attribute3 := l_wip_op_network_row.Attribute3;
			l_op_network_tbl(l_op_network_tbl_index).Attribute4 := l_wip_op_network_row.Attribute4;
			l_op_network_tbl(l_op_network_tbl_index).Attribute5 := l_wip_op_network_row.Attribute5;
			l_op_network_tbl(l_op_network_tbl_index).Attribute6 := l_wip_op_network_row.Attribute6;
			l_op_network_tbl(l_op_network_tbl_index).Attribute7 := l_wip_op_network_row.Attribute7;
			l_op_network_tbl(l_op_network_tbl_index).Attribute8 := l_wip_op_network_row.Attribute8;
			l_op_network_tbl(l_op_network_tbl_index).Attribute9 := l_wip_op_network_row.Attribute9;
			l_op_network_tbl(l_op_network_tbl_index).Attribute10 := l_wip_op_network_row.Attribute10;
			l_op_network_tbl(l_op_network_tbl_index).Attribute11 := l_wip_op_network_row.Attribute11;
			l_op_network_tbl(l_op_network_tbl_index).Attribute12 := l_wip_op_network_row.Attribute12;
			l_op_network_tbl(l_op_network_tbl_index).Attribute13 := l_wip_op_network_row.Attribute13;
			l_op_network_tbl(l_op_network_tbl_index).Attribute14 := l_wip_op_network_row.Attribute14;
			l_op_network_tbl(l_op_network_tbl_index).Attribute15 := l_wip_op_network_row.Attribute15;

			l_op_network_tbl_index := l_op_network_tbl_index + 1;
		END LOOP;


	END IF;	-- p_operation_option = 2

	-- 2 d) Create Resources
	IF p_resource_copy_option = 1 THEN
		-- p_resource_copy_option = 1 (NONE), do nothing
		NULL;
	ELSIF p_resource_copy_option in (2, 3) THEN
		-- p_resource_copy_option = 2 (ISSUED), or 3 (ALL)
		l_op_resource_tbl_index := 1;
		FOR l_wip_resource_row IN wip_resource_cur(p_work_order_rec.organization_id,
							   p_work_order_rec.wip_entity_id)
		LOOP
			-- First initialize the fields of the record to be NULL
--			l_op_resource_tbl(l_op_resource_tbl_index) := NULL;
			-- Then populate fields from cursor.
			l_op_resource_tbl(l_op_resource_tbl_index).Transaction_Type := l_create_txn_type;
			l_op_resource_tbl(l_op_resource_tbl_index).Organization_Code := l_rtg_header_rec.Organization_Code;
			l_op_resource_tbl(l_op_resource_tbl_index).Assembly_Item_Name := l_rtg_header_rec.Assembly_Item_Name;
			l_op_resource_tbl(l_op_resource_tbl_index).Operation_Sequence_Number := l_wip_resource_row.Operation_Seq_Num;
			l_op_resource_tbl(l_op_resource_tbl_index).Resource_Code :=
				EAM_ActivityUtilities_PVT.Get_Resource_Code(l_wip_resource_row.Organization_Id,
										l_wip_resource_row.Resource_Id);
			l_op_resource_tbl(l_op_resource_tbl_index).Op_Start_Effective_Date := l_effectivity_date;
			l_op_resource_tbl(l_op_resource_tbl_index).Resource_Sequence_Number := l_wip_resource_row.Resource_Seq_Num;

			IF p_resource_copy_option = 2 THEN
				-- p_resource_copy_option = 2 (ISSUED)
				l_op_resource_tbl(l_op_resource_tbl_index).Usage_Rate_Or_Amount :=
					l_wip_resource_row.Applied_Resource_Units;
			ELSE
				-- p_resource_copy_option = 3 (ALL)
				l_op_resource_tbl(l_op_resource_tbl_index).Usage_Rate_Or_Amount :=
					EAM_ActivityUtilities_PVT.Get_WO_Res_Scheduled_Units(
						l_wip_resource_row.Organization_Id,
						l_wip_resource_row.Wip_Entity_Id,
						l_wip_resource_row.Operation_Seq_Num,
						l_wip_resource_row.Resource_Seq_Num);
			END IF;

			l_op_resource_tbl(l_op_resource_tbl_index).Activity :=
				EAM_ActivityUtilities_PVT.Get_Cost_Activity(l_wip_resource_row.Activity_Id);
			l_op_resource_tbl(l_op_resource_tbl_index).Schedule_Flag := l_wip_resource_row.Scheduled_Flag;
			l_op_resource_tbl(l_op_resource_tbl_index).Assigned_Units := l_wip_resource_row.Assigned_Units;
			l_op_resource_tbl(l_op_resource_tbl_index).Autocharge_Type := l_wip_resource_row.Autocharge_Type;
			l_op_resource_tbl(l_op_resource_tbl_index).Standard_Rate_Flag := l_wip_resource_row.Standard_Rate_Flag;
			l_op_resource_tbl(l_op_resource_tbl_index).Principle_Flag := l_wip_resource_row.Principle_Flag;

			l_op_resource_tbl(l_op_resource_tbl_index).Attribute_Category := l_wip_resource_row.Attribute_Category;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute1 := l_wip_resource_row.Attribute1;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute2 := l_wip_resource_row.Attribute2;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute3 := l_wip_resource_row.Attribute3;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute4 := l_wip_resource_row.Attribute4;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute5 := l_wip_resource_row.Attribute5;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute6 := l_wip_resource_row.Attribute6;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute7 := l_wip_resource_row.Attribute7;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute8 := l_wip_resource_row.Attribute8;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute9 := l_wip_resource_row.Attribute9;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute10 := l_wip_resource_row.Attribute10;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute11 := l_wip_resource_row.Attribute11;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute12 := l_wip_resource_row.Attribute12;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute13 := l_wip_resource_row.Attribute13;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute14 := l_wip_resource_row.Attribute14;
			l_op_resource_tbl(l_op_resource_tbl_index).Attribute15 := l_wip_resource_row.Attribute15;

			l_op_resource_tbl_index := l_op_resource_tbl_index + 1;
		END LOOP;

	ELSE
		-- since we performed validation on p_resource_copy_option already, shouldn't reach here.
		NULL;
	END IF;

	-- 2 e) Call the Routing Business Object API
	-- Only Call Routing Business Object API if operation tabel is not empty
	IF l_operation_tbl.FIRST IS NOT NULL THEN
		Error_Handler.initialize;
		-- log call to Process_Rtg API
		EAM_ActivityUtilities_PVT.Write_Debug('>>>>>>>>>>>>>>> BOM_RTG_PUB.Process_Rtg INPUT Parameters >>>>>>>>>>>>>>>');
		EAM_ActivityUtilities_PVT.Log_Process_Rtg_Parameters(l_rtg_header_rec,
								l_operation_tbl,
								l_op_resource_tbl,
								l_op_network_tbl);

		EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_RTG_PUB.Process_Rtg **********');
		BOM_RTG_PUB.Process_Rtg(
			p_rtg_header_rec 	=> l_rtg_header_rec
			, p_operation_tbl	=> l_operation_tbl
			, p_op_resource_tbl	=> l_op_resource_tbl
			, p_op_network_tbl	=> l_op_network_tbl
			, x_rtg_header_rec	=> l_x_rtg_header_rec
			, x_rtg_revision_tbl	=> l_x_rtg_revision_tbl
			, x_operation_tbl	=> l_x_operation_tbl
			, x_op_resource_tbl	=> l_x_op_resource_tbl
			, x_sub_resource_tbl	=> l_x_sub_resource_tbl
			, x_op_network_tbl	=> l_x_op_network_tbl
			, x_return_status	=> l_x_rtg_return_status
			, x_msg_count		=> l_x_rtg_msg_count
		);
		EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_RTG_PUB.Process_Rtg **********');

		Error_Handler.Get_Message_List(l_x_rtg_msg_list);

		-- log errors
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_rtg_return_status=' || l_x_rtg_return_status);
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_rtg_msg_count=' || l_x_rtg_msg_count);
		Error_Handler.Get_Message_List(l_x_rtg_msg_list);
		EAM_ActivityUtilities_PVT.Write_Debug('Results of BOM_RTG_PUB.Process_Rtg >>>>>');
		EAM_ActivityUtilities_PVT.Log_Bom_Error_Tbl(l_x_rtg_msg_list);
		EAM_ActivityUtilities_PVT.Write_Debug('End of Results of BOM_RTG_PUB.Process_Rtg <<<<<');
		EAM_ActivityUtilities_PVT.Write_Debug('<<<<<<<<<<<<<<< BOM_RTG_PUB.Process_Rtg OUTPUT Parameters <<<<<<<<<<<<<<<');
		EAM_ActivityUtilities_PVT.Log_Process_Rtg_Parameters(l_x_rtg_header_rec,
								l_x_operation_tbl,
								l_x_op_resource_tbl,
								l_x_op_network_tbl);

		-- Assign outputs.
		x_rtg_header_rec := l_x_rtg_header_rec;
		x_rtg_revision_tbl := l_x_rtg_revision_tbl;
		x_operation_tbl	:= l_x_operation_tbl;
		x_op_resource_tbl := l_x_op_resource_tbl;
		x_sub_resource_tbl := l_x_sub_resource_tbl;
		x_op_network_tbl := l_x_op_network_tbl;
		x_rtg_return_status := l_x_rtg_return_status;
		x_rtg_msg_count	:= l_x_rtg_msg_count;
		x_rtg_msg_list	:= l_x_rtg_msg_list;

	END IF;

	EAM_ActivityUtilities_PVT.Write_Debug('---------- Exiting EAM_Activity_PUB.Create_Activity_Routing ----------');
END;

-- ----------------------------------------------------------------------
PROCEDURE Create_Activity_BOM(
	p_target_item_rec			IN INV_Item_GRP.Item_Rec_Type,
	p_work_order_rec		IN EAM_Activity_PUB.Work_Order_Rec_Type,
	p_material_copy_option		IN NUMBER,

	x_bom_header_rec		OUT NOCOPY	BOM_BO_PUB.BOM_Head_Rec_Type,
	x_bom_revision_tbl		OUT NOCOPY	BOM_BO_PUB.BOM_Revision_Tbl_Type,
	x_bom_component_tbl		OUT NOCOPY	BOM_BO_PUB.BOM_Comps_Tbl_Type,
	x_bom_ref_designator_tbl	OUT NOCOPY	BOM_BO_PUB.BOM_Ref_Designator_Tbl_Type,
	x_bom_sub_component_tbl		OUT NOCOPY	BOM_BO_PUB.BOM_Sub_Component_Tbl_Type,
	x_bom_return_status		OUT NOCOPY	VARCHAR2,
	x_bom_msg_count			OUT NOCOPY	NUMBER,
	x_bom_msg_list			OUT NOCOPY	Error_Handler.Error_Tbl_Type
)
IS
l_current_date			CONSTANT DATE := sysdate;
l_effectivity_date		CONSTANT DATE := l_current_date;
l_create_txn_type		CONSTANT VARCHAR(10) := 'CREATE';
-- local variabels for calling BOM Business Object API
l_bom_head_rec			BOM_BO_PUB.Bom_Head_Rec_Type;
l_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
l_bom_comp_tbl_index		BINARY_INTEGER;

l_x_bom_header_rec		BOM_BO_PUB.Bom_Head_Rec_Type;
l_x_bom_revision_tbl		BOM_BO_PUB.Bom_Revision_Tbl_Type;
l_x_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
l_x_bom_ref_designator_tbl	BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
l_x_bom_sub_component_tbl	BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
l_x_bom_return_status		VARCHAR2(1);
l_x_bom_msg_count		NUMBER;
l_x_bom_msg_list		Error_Handler.Error_Tbl_Type;
l_stock_enabled_flag		varchar2(1);
l_list_price_per_unit		number;
CURSOR wip_requirement_cur (
	p_organization_id	IN	NUMBER,
	p_wip_entity_id 	IN	NUMBER
)
IS
	SELECT	*
	FROM	wip_requirement_operations
	WHERE	wip_entity_id = p_wip_entity_id
	 AND	organization_id = p_organization_id;

BEGIN
	IF p_material_copy_option = 1 THEN
		-- p_material_copy_option = 1 (NONE), do nothing
		NULL;
	ELSIF p_material_copy_option IN (2, 3) THEN
		-- We need 1 BOM Header (Assembly_Item_Rec_Type) and a table of Components ( Rev_Component_Rec_Type)
		-- 2 a) Create BOM Header
--		l_bom_head_rec := NULL;
		l_bom_head_rec.Assembly_Item_Name := p_target_item_rec.Item_Number;
		l_bom_head_rec.Transaction_Type := l_create_txn_type;
		l_bom_head_rec.Organization_Code := p_target_item_rec.Organization_Code;
		l_bom_head_rec.Assembly_Type := 1;

		-- 2 b) Create table of Components
		l_bom_comp_tbl_index := 1;
		FOR l_wip_requirement_row IN wip_requirement_cur(p_work_order_rec.organization_id,
								 p_work_order_rec.wip_entity_id)
		LOOP
--			l_bom_component_tbl(l_bom_comp_tbl_index) := NULL;
			l_bom_component_tbl(l_bom_comp_tbl_index).Transaction_Type := l_create_txn_type;
			l_bom_component_tbl(l_bom_comp_tbl_index).Organization_Code := l_bom_head_rec.Organization_Code;
			l_bom_component_tbl(l_bom_comp_tbl_index).Assembly_Item_Name := l_bom_head_rec.Assembly_Item_Name;
			l_bom_component_tbl(l_bom_comp_tbl_index).Start_Effective_Date := l_effectivity_date;
			l_bom_component_tbl(l_bom_comp_tbl_index).Operation_Sequence_Number :=
				l_wip_requirement_row.Operation_Seq_Num;
			l_bom_component_tbl(l_bom_comp_tbl_index).Component_Item_Name :=
				EAM_ActivityUtilities_PVT.Get_Item_Concatenated_Segments(l_wip_requirement_row.organization_id,
											l_wip_requirement_row.inventory_item_id);
--			l_bom_component_tbl(l_bom_comp_tbl_index).Item_Sequence_Number :=
--				l_wip_requirement_row.Component_Sequence_Id;
--			l_bom_component_tbl(l_bom_comp_tbl_index).Item_Sequence_Number := l_bom_comp_tbl_index;

			IF p_material_copy_option = 2 THEN
				-- p_material_copy_option = 2 (ISSUED)
				l_bom_component_tbl(l_bom_comp_tbl_index).Quantity_Per_Assembly :=
					l_wip_requirement_row.Quantity_Issued;
			ELSE
				-- p_material_copy_option = 3 (ALL)
				l_bom_component_tbl(l_bom_comp_tbl_index).Quantity_Per_Assembly :=
					l_wip_requirement_row.Required_Quantity;
			END IF;

			l_bom_component_tbl(l_bom_comp_tbl_index).Wip_Supply_Type := l_wip_requirement_row.Wip_Supply_Type;
			l_bom_component_tbl(l_bom_comp_tbl_index).Supply_Subinventory := l_wip_requirement_row.Supply_Subinventory;
			l_bom_component_tbl(l_bom_comp_tbl_index).Location_Name :=
				EAM_ActivityUtilities_PVT.Get_Locator(l_wip_requirement_row.organization_id,
									l_wip_requirement_row.Supply_Subinventory,
									l_wip_requirement_row.Supply_Locator_Id);
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute_Category := l_wip_requirement_row.Attribute_Category;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute1 := l_wip_requirement_row.Attribute1;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute2 := l_wip_requirement_row.Attribute2;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute3 := l_wip_requirement_row.Attribute3;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute4 := l_wip_requirement_row.Attribute4;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute5 := l_wip_requirement_row.Attribute5;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute6 := l_wip_requirement_row.Attribute6;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute7 := l_wip_requirement_row.Attribute7;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute8 := l_wip_requirement_row.Attribute8;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute9 := l_wip_requirement_row.Attribute9;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute10 := l_wip_requirement_row.Attribute10;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute11 := l_wip_requirement_row.Attribute11;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute12 := l_wip_requirement_row.Attribute12;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute13 := l_wip_requirement_row.Attribute13;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute14 := l_wip_requirement_row.Attribute14;
			l_bom_component_tbl(l_bom_comp_tbl_index).Attribute15 := l_wip_requirement_row.Attribute15;

			l_bom_component_tbl(l_bom_comp_tbl_index).Comments := l_wip_requirement_row.Comments;

			-- sraval: added for Direct Items 11.5.10
			select stock_enabled_flag,list_price_per_unit
			into l_stock_enabled_flag,l_list_price_per_unit
			from mtl_system_items
			where inventory_item_id = l_wip_requirement_row.inventory_item_id
			and organization_id = l_wip_requirement_row.organization_id;

			if l_stock_enabled_flag = 'N' then
				l_bom_component_tbl(l_bom_comp_tbl_index).suggested_vendor_name := l_wip_requirement_row.suggested_vendor_name;
				l_bom_component_tbl(l_bom_comp_tbl_index).unit_price := l_wip_requirement_row.unit_price;
			end if;

			l_bom_comp_tbl_index := l_bom_comp_tbl_index + 1;
		END LOOP;
	ELSE
		-- p_material_copy_option NOT IN (1, 2, 3)
		-- Since we performed validation on p_material_copy_option in the beginning already, should not happen.
		NULL;
	END IF; -- p_material_copy_option

	-- 2 c) Call the BOM Business Object API

	-- Only call BOM Business Object API if Component Table is not empty
	IF l_bom_component_tbl.FIRST IS NOT NULL THEN

		Error_Handler.initialize;
		-- log call to Process_BOM API
		EAM_ActivityUtilities_PVT.Write_Debug('>>>>>>>>>>>>>>> BOM_BO_PUB.Process_BOM INPUT Parameters >>>>>>>>>>>>>>>');
		EAM_ActivityUtilities_PVT.Log_Process_BOM_Parameters(l_bom_head_rec,
								l_bom_component_tbl);

		EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_BO_PUB.Process_BOM **********');
		BOM_BO_PUB.Process_BOM(
			p_bom_header_rec 		=> l_bom_head_rec,
			p_bom_component_tbl 		=> l_bom_component_tbl,
			x_bom_header_rec 		=> l_x_bom_header_rec,
			x_bom_revision_tbl 		=> l_x_bom_revision_tbl,
			x_bom_component_tbl 		=> l_x_bom_component_tbl,
			x_bom_ref_designator_tbl 	=> l_x_bom_ref_designator_tbl,
			x_bom_sub_component_tbl		=> l_x_bom_sub_component_tbl,
			x_return_status			=> l_x_bom_return_status,
			x_msg_count			=> l_x_bom_msg_count
		);
		EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_BO_PUB.Process_BOM **********');

		Error_Handler.Get_Message_List(l_x_bom_msg_list);

		-- log errors
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_bom_return_status=' || l_x_bom_return_status);
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_bom_msg_count=' || l_x_bom_msg_count);
		Error_Handler.Get_Message_List(l_x_bom_msg_list);
		EAM_ActivityUtilities_PVT.Write_Debug('Results of BOM_BO_PUB.Process_BOM >>>>>');
		EAM_ActivityUtilities_PVT.Log_Bom_Error_Tbl(l_x_bom_msg_list);
		EAM_ActivityUtilities_PVT.Write_Debug('End of Results of BOM_BO_PUB.Process_BOM <<<<<');
		EAM_ActivityUtilities_PVT.Write_Debug('<<<<<<<<<<<<<<< BOM_BO_PUB.Process_BOM OUTPUT Parameters <<<<<<<<<<<<<<<');
		EAM_ActivityUtilities_PVT.Log_Process_BOM_Parameters(l_x_bom_header_rec,
								l_x_bom_component_tbl);


		-- Assign outputs.
		x_bom_header_rec := l_x_bom_header_rec;
		x_bom_revision_tbl := l_x_bom_revision_tbl;
		x_bom_component_tbl := l_x_bom_component_tbl;
		x_bom_ref_designator_tbl := l_x_bom_ref_designator_tbl;
		x_bom_sub_component_tbl	:= l_x_bom_sub_component_tbl;
		x_bom_return_status := l_x_bom_return_status;
		x_bom_msg_count := l_x_bom_msg_count;
		x_bom_msg_list := l_x_bom_msg_list;

	END IF;

END;
-- ================================================================================
PROCEDURE Get_Errors
(	p_item_error_tbl			IN	INV_Item_GRP.Error_Tbl_Type ,
	x_error_msg_old				IN	VARCHAR2,
	x_error_msg_new				OUT NOCOPY	VARCHAR2
)
IS
	l_index BINARY_INTEGER;
	l_error_msg VARCHAR2(3000);
BEGIN
	l_error_msg:=x_error_msg_old;
	l_index:=p_item_error_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		l_error_msg:=l_error_msg||p_item_error_tbl(l_index).message_text;
		l_index:=p_item_error_tbl.NEXT(l_index);
	END LOOP;
	x_error_msg_new:=l_error_msg;
END;
-- ================================================================================

-- ----------------------------------------------------------------------
PROCEDURE Create_Item(
	p_asset_activity		IN	INV_Item_GRP.Item_Rec_Type,
	p_template_id			IN	NUMBER 		:= NULL,
        p_template_name			IN	VARCHAR2 	:= NULL,

	x_curr_item_rec			OUT NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_curr_item_return_status	OUT NOCOPY	VARCHAR2,
	x_curr_item_error_tbl		OUT NOCOPY	INV_Item_GRP.Error_Tbl_Type,

	x_master_item_rec		OUT NOCOPY	INV_Item_GRP.Item_Rec_Type,
	x_master_item_return_status	OUT NOCOPY	VARCHAR2,
	x_master_item_error_tbl		OUT NOCOPY	INV_Item_GRP.Error_Tbl_Type
)
IS
l_master_organization_id	NUMBER;
l_curr_organization_id		NUMBER;
l_item_rec			INV_Item_GRP.Item_rec_type;
l_validate_org_ret_sts		VARCHAR2(1);

l_temp_org_id			NUMBER;
l_temp_org_code			VARCHAR2(3);

-- local variables for calling INV_Item_GRP package

l_x_curr_item_rec		INV_Item_GRP.Item_rec_type;
l_x_curr_item_return_status	VARCHAR2(1);
l_x_curr_item_error_tbl		INV_Item_GRP.Error_tbl_type;

l_x_master_item_rec	INV_Item_GRP.Item_rec_type;
l_x_master_item_return_status	VARCHAR2(1);
l_x_master_item_error_tbl	INV_Item_GRP.Error_tbl_type;
l_error_string			VARCHAR(2000);

BEGIN
	-- Step 2: Create Asset Activity. Call INV_Item_GRP package.

	-- Copy input activity record to a working record
	l_item_rec := p_asset_activity;

	-- Validate org id and org code
	EAM_ActivityUtilities_PVT.Validate_Organization(
		p_organization_id => l_item_rec.organization_id,
		p_organization_code => l_item_rec.organization_code,
		x_return_status => l_validate_org_ret_sts,
		x_organization_id => l_temp_org_id,
		x_organization_code => l_temp_org_code
	);
	l_item_rec.organization_id := l_temp_org_id;
	l_item_rec.organization_code := l_temp_org_code;

	IF l_validate_org_ret_sts <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- ============================================================
	EAM_ActivityUtilities_PVT.Write_Debug('-------- Beginning EAM_Activity_PUB.Create_Item --------');

	-- Save current org id
	l_curr_organization_id := l_item_rec.organization_id;
	EAM_ActivityUtilities_PVT.Write_Debug('l_curr_organization_id=' || l_curr_organization_id);

	-- 2 a) Get master org id
	l_master_organization_id := EAM_ActivityUtilities_PVT.Get_Master_Org_Id(l_curr_organization_id);
	EAM_ActivityUtilities_PVT.Write_Debug('l_master_organization_id=' || l_master_organization_id);

	-- Set attributes of l_item_rec
	l_item_rec.eam_item_type := 2; -- EAM Asset Activity

	IF l_item_rec.inventory_item_flag IS NULL OR l_item_rec.inventory_item_flag = fnd_api.g_MISS_CHAR
	THEN
		l_item_rec.inventory_item_flag := 'Y';
	END IF;

	IF l_item_rec.expense_account IS NULL OR l_item_rec.expense_account = fnd_api.g_MISS_NUM
	THEN
		-- In the Master Item form, Expense Account defaulted from Master Org. So should use Master Org.
		l_item_rec.expense_account := EAM_ActivityUtilities_PVT.Get_Expense_Account_Id(l_master_organization_id);
	END IF;
	-- Check that expense_account is not null
	IF l_item_rec.expense_account IS NULL OR l_item_rec.expense_account = fnd_api.g_MISS_NUM
	THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_EXPENSE_ACCOUNT_NULL');
--		FND_MESSAGE.SET_ENCODED('Please define the Expense Account for the Organization.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_item_rec.bom_enabled_flag IS NULL OR
		l_item_rec.bom_enabled_flag = fnd_api.g_MISS_CHAR
	THEN
		l_item_rec.bom_enabled_flag := 'Y';
	END IF;

	-- 2 c) If current org is not master org, creat Activity in master org first
	IF l_curr_organization_id <> l_master_organization_id THEN
		-- set org to master org
		l_item_rec.organization_id := l_master_organization_id;
		l_item_rec.organization_code := NULL;

		EAM_ActivityUtilities_PVT.Write_Debug('Creating MASTER Item...');
		EAM_ActivityUtilities_PVT.Write_Debug('>>>>>>>>>>>>>>> INV_Item_GRP.Create_Item INPUT Parameters >>>>>>>>>>>>>>>');
		EAM_ActivityUtilities_PVT.Write_Debug('p_template_id=' || p_template_id);
		EAM_ActivityUtilities_PVT.Write_Debug('p_template_name=' || p_template_name);
		EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_item_rec);
		INV_Item_GRP.Create_Item(
			p_Item_rec => l_item_rec,
			p_Template_Id => p_template_id,
			p_Template_Name => p_template_name,
			x_Item_rec => l_x_master_item_rec,
			x_return_status => l_x_master_item_return_status,
			x_Error_tbl => l_x_master_item_error_tbl
		);
		-- Assign outputs
		x_master_item_rec := l_x_master_item_rec;
		x_master_item_return_status := l_x_master_item_return_status;
		x_master_item_error_tbl := l_x_master_item_error_tbl;

		-- log outputs
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_master_item_return_status=' || l_x_master_item_return_status);
		EAM_ActivityUtilities_PVT.Write_Debug('Results of INV_Item_GRP.Create_Item (master item) >>>>>');
		EAM_ActivityUtilities_PVT.Log_Item_Error_Tbl(l_x_master_item_error_tbl);
		EAM_ActivityUtilities_PVT.Write_Debug('End of Results of INV_Item_GRP.Create_Item (master item) <<<<<');
		EAM_ActivityUtilities_PVT.Write_Debug('<<<<<<<<<<<<<<< INV_Item_GRP.Create_Item OUTPUT Parameters <<<<<<<<<<<<<<<');
		EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_x_master_item_rec);

		IF l_x_master_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			-- Create Item under master org fail, no use tyring to create it under child org.
			RETURN;
		END IF;
	ELSE
		-- Current Org is Master Org, no additional Item needs to be created.
		EAM_ActivityUtilities_PVT.Write_Debug('Current Org is Master Org, no additional Item needs to be created.');
		x_master_item_rec := l_x_master_item_rec; -- should be NULL
		x_master_item_return_status := FND_API.G_RET_STS_SUCCESS;
		x_master_item_error_tbl := l_x_master_item_error_tbl; -- should be NULL
	END IF;

	-- 2 d) Create Activity in current org
	-- set org to current org
	l_item_rec.organization_id := l_curr_organization_id;
	l_item_rec.organization_code := NULL;
	/*Bug3269789 - Added below code since master items form uses exp acct of child org
	  when assigning to child org*/
	/*Bug#3269789 - start*/
	     l_item_rec.expense_account := EAM_ActivityUtilities_PVT.Get_Expense_Account_Id(l_curr_organization_id);

	    -- Check that expense_account is not null
	    IF l_item_rec.expense_account IS NULL OR l_item_rec.expense_account = fnd_api.g_MISS_NUM
	    THEN
	        FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_EXPENSE_ACCOUNT_NULL');
	--      FND_MESSAGE.SET_ENCODED('Please define the Expense Account for the Organization.');
	        EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
	        RAISE FND_API.G_EXC_ERROR;
	    END IF;
	/*Bug#3269789 - end*/

	EAM_ActivityUtilities_PVT.Write_Debug('Creating CURRENT Item...');
	EAM_ActivityUtilities_PVT.Write_Debug('>>>>>>>>>>>>>>> INV_Item_GRP.Create_Item INPUT Parameters >>>>>>>>>>>>>>>');
	EAM_ActivityUtilities_PVT.Write_Debug('p_template_id=' || p_template_id);
	EAM_ActivityUtilities_PVT.Write_Debug('p_template_name=' || p_template_name);
	EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_item_rec);
	INV_Item_GRP.Create_Item(
		p_Item_rec => l_item_rec,
		p_Template_Id => p_template_id,
		p_Template_Name => p_template_name,
		x_Item_rec => l_x_curr_item_rec,
		x_return_status => l_x_curr_item_return_status,
		x_Error_tbl => l_x_curr_item_error_tbl
	);
	-- Assign outputs
	x_curr_item_rec := l_x_curr_item_rec;
	x_curr_item_return_status := l_x_curr_item_return_status;
	x_curr_item_error_tbl := l_x_curr_item_error_tbl;

	-- log outputs
	EAM_ActivityUtilities_PVT.Write_Debug('l_x_curr_item_return_status=' || l_x_curr_item_return_status);
	EAM_ActivityUtilities_PVT.Write_Debug('Results of INV_Item_GRP.Create_Item (current item) >>>>>');
	EAM_ActivityUtilities_PVT.Log_Item_Error_Tbl(l_x_curr_item_error_tbl);
	EAM_ActivityUtilities_PVT.Write_Debug('End of Results of INV_Item_GRP.Create_Item (current item) <<<<<');
	EAM_ActivityUtilities_PVT.Write_Debug('<<<<<<<<<<<<<<< INV_Item_GRP.Create_Item OUTPUT Parameters <<<<<<<<<<<<<<<');
	EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_x_curr_item_rec);

	-- ============================================================
	EAM_ActivityUtilities_PVT.Write_Debug('-------- Finished EAM_Activity_PUB.Create_Item --------');
END;

-- ======================================================================
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
	x_work_order_rec		OUT	NOCOPY	EAM_Activity_PUB.Work_Order_Rec_Type,

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
)

IS
l_api_name			CONSTANT VARCHAR2(30)		:= 'Create_Activity';
l_api_version           	CONSTANT NUMBER 		:= 1.0;

-- local variables for validating source Work Order
l_x_work_order_rec		EAM_Activity_PUB.Work_Order_Rec_Type;
l_x_work_order_ret_sts		VARCHAR2(1);

-- local variables for calling INV_Item_GRP package
l_asset_activity		INV_Item_GRP.Item_rec_type;
l_x_curr_item_rec		INV_Item_GRP.Item_rec_type;
l_x_curr_item_return_status	VARCHAR2(1);
l_x_curr_item_error_tbl		INV_Item_GRP.Error_tbl_type;
l_x_master_item_rec		INV_Item_GRP.Item_rec_type;
l_x_master_item_return_status	VARCHAR2(1);
l_x_master_item_error_tbl	INV_Item_GRP.Error_tbl_type;

-- local variabels for calling BOM Business Object API
l_x_bom_header_rec		BOM_BO_PUB.Bom_Head_Rec_Type;
l_x_bom_revision_tbl		BOM_BO_PUB.Bom_Revision_Tbl_Type;
l_x_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
l_x_bom_ref_designator_tbl	BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
l_x_bom_sub_component_tbl	BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
l_x_bom_return_status		VARCHAR2(1);
l_x_bom_msg_count		NUMBER;
l_x_bom_msg_list		Error_Handler.Error_Tbl_Type;

-- local variables for call the Routing Business Object API
l_x_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
l_x_rtg_revision_tbl		BOM_RTG_PUB.Rtg_Revision_Tbl_Type;
l_x_operation_tbl		BOM_RTG_PUB.Operation_Tbl_Type;
l_x_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
l_x_sub_resource_tbl		BOM_RTG_PUB.Sub_Resource_Tbl_Type;
l_x_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
l_x_rtg_return_status		VARCHAR2(1);
l_x_rtg_msg_count		NUMBER;
l_x_rtg_msg_list		Error_Handler.Error_Tbl_Type;

-- local variables for call Association Creation package
l_x_assoc_return_status		VARCHAR2(1);
l_x_assoc_msg_count		NUMBER;
l_x_assoc_msg_data		VARCHAR2(20000);
l_x_act_num_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;
l_x_activity_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;


-- ======================================================================
BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Create_Activity_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	-- ============================================================
	EAM_ActivityUtilities_PVT.Write_Debug('========== Entering EAM_Activity_PUB.Create_Activity ==========');
	EAM_ActivityUtilities_PVT.Write_Debug('Organization_Id=' || p_asset_activity.Organization_Id);
	EAM_ActivityUtilities_PVT.Write_Debug('Organization_Code=' || p_asset_activity.Organization_Code);
	EAM_ActivityUtilities_PVT.Write_Debug('Inventory_Item_Id=' || p_asset_activity.Inventory_Item_Id);
	EAM_ActivityUtilities_PVT.Write_Debug('Item Number=' || p_asset_activity.Item_Number);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment1=' || p_asset_activity.Segment1);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment2=' || p_asset_activity.Segment2);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment3=' || p_asset_activity.Segment3);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment4=' || p_asset_activity.Segment4);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment5=' || p_asset_activity.Segment5);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment6=' || p_asset_activity.Segment6);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment7=' || p_asset_activity.Segment7);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment8=' || p_asset_activity.Segment8);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment9=' || p_asset_activity.Segment9);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment10=' || p_asset_activity.Segment10);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment11=' || p_asset_activity.Segment11);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment12=' || p_asset_activity.Segment12);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment13=' || p_asset_activity.Segment13);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment14=' || p_asset_activity.Segment14);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment15=' || p_asset_activity.Segment15);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment16=' || p_asset_activity.Segment16);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment17=' || p_asset_activity.Segment17);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment18=' || p_asset_activity.Segment18);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment19=' || p_asset_activity.Segment19);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment20=' || p_asset_activity.Segment20);
	EAM_ActivityUtilities_PVT.Write_Debug('Description=' || p_asset_activity.Description);

	-- ============================================================
	-- Step 1: Validate inputs
	-- 1 a) Validate source Work Order
	EAM_ActivityUtilities_PVT.Validate_Work_Order(
		p_work_order_rec => p_work_order_rec,
		x_return_status => l_x_work_order_ret_sts,
		x_work_order_rec => l_x_work_order_rec
	);
	IF l_x_work_order_ret_sts <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	-- Set return parameter
	x_work_order_rec := l_x_work_order_rec;

	-- 1 b) Validate copy options
	Validate_Copy_Options(
		l_x_work_order_rec,
		p_operation_copy_option,
		p_material_copy_option,
		p_resource_copy_option,
		p_association_copy_option
	);

	-- ============================================================
	-- Step 2: Create Asset Activity. Call INV_Item_GRP package.

	l_asset_activity := p_asset_activity;

	-- Get org id from work order
	l_asset_activity.organization_id := l_x_work_order_rec.organization_id;

	l_asset_activity.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_asset_activity.EAM_ACTIVITY_CAUSE_CODE := p_activity_cause_code;
	l_asset_activity.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;
	l_asset_activity.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_asset_activity.EAM_ACTIVITY_SOURCE_CODE := p_activity_source_code;

	Create_Item(
		p_asset_activity => l_asset_activity,
		p_template_id => p_template_id,
		p_template_name => p_template_name,

		x_curr_item_rec 		=> l_x_curr_item_rec,
		x_curr_item_return_status 	=> l_x_curr_item_return_status,
		x_curr_item_error_tbl 		=> l_x_curr_item_error_tbl,
		x_master_item_rec 		=> l_x_master_item_rec,
		x_master_item_return_status 	=> l_x_master_item_return_status,
		x_master_item_error_tbl 	=> l_x_master_item_error_tbl
	);

	IF l_x_master_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_MASTER_FAILED');
--		FND_MESSAGE.SET_ENCODED('Create Activity under Master Organization failed.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_x_curr_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_CURRENT_FAILED');
--		FND_MESSAGE.SET_ENCODED('Create Activity under Current Organization failed.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

-- Set the Activity Attributes in the Item Record, don't have to do it manually
/*
	-- Overwrite Activity Properties with user-supplied values
	l_x_master_item_rec.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_x_master_item_rec.EAM_ACTIVITY_CAUSE_CODE  := p_activity_cause_code;
	l_x_master_item_rec.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_x_master_item_rec.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;

	BEGIN
		UPDATE	mtl_system_items
		SET	EAM_ACTIVITY_TYPE_CODE = p_activity_type_code,
			EAM_ACTIVITY_CAUSE_CODE = p_activity_cause_code,
			EAM_ACT_SHUTDOWN_STATUS = p_shutdown_type_code,
			EAM_ACT_NOTIFICATION_FLAG = p_notification_req_flag,
			EAM_ACTIVITY_SOURCE_CODE = p_activity_source_code
		WHERE	inventory_item_id = l_x_master_item_rec.inventory_item_id
		AND	organization_id = l_x_master_item_rec.organization_id;
	EXCEPTION
		WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_PROPERTIES');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	END;

	l_x_curr_item_rec.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_x_curr_item_rec.EAM_ACTIVITY_CAUSE_CODE  := p_activity_cause_code;
	l_x_curr_item_rec.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_x_curr_item_rec.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;

	BEGIN
		UPDATE	mtl_system_items
		SET	EAM_ACTIVITY_TYPE_CODE = p_activity_type_code,
			EAM_ACTIVITY_CAUSE_CODE = p_activity_cause_code,
			EAM_ACT_SHUTDOWN_STATUS = p_shutdown_type_code,
			EAM_ACT_NOTIFICATION_FLAG = p_notification_req_flag,
			EAM_ACTIVITY_SOURCE_CODE = p_activity_source_code
		WHERE	inventory_item_id = l_x_curr_item_rec.inventory_item_id
		AND	organization_id = l_x_curr_item_rec.organization_id;
	EXCEPTION
		WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_PROPERTIES');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	END;
*/

	-- Assign outputs
	x_curr_item_rec 		:= l_x_curr_item_rec;
	x_curr_item_return_status 	:= l_x_curr_item_return_status;
	x_curr_item_error_tbl 		:= l_x_curr_item_error_tbl;
	x_master_item_rec 		:= l_x_master_item_rec;
	x_master_item_return_status 	:= l_x_master_item_return_status;
	x_master_item_error_tbl 	:= l_x_master_item_error_tbl;

	-- ============================================================
	-- Step 3: Create Operations and Resources
	Create_Activity_Routing(
		p_target_item_rec => l_x_curr_item_rec
		, p_work_order_rec => l_x_work_order_rec
		, p_operation_copy_option => p_operation_copy_option
		, p_resource_copy_option => p_resource_copy_option

		, x_rtg_header_rec	=> l_x_rtg_header_rec
		, x_rtg_revision_tbl	=> l_x_rtg_revision_tbl
		, x_operation_tbl	=> l_x_operation_tbl
		, x_op_resource_tbl	=> l_x_op_resource_tbl
		, x_sub_resource_tbl	=> l_x_sub_resource_tbl
		, x_op_network_tbl	=> l_x_op_network_tbl
		, x_rtg_return_status	=> l_x_rtg_return_status
		, x_rtg_msg_count	=> l_x_rtg_msg_count
		, x_rtg_msg_list	=> l_x_rtg_msg_list
	);
	-- Assign outputs.
	x_rtg_header_rec := l_x_rtg_header_rec;
	x_rtg_revision_tbl := l_x_rtg_revision_tbl;
	x_operation_tbl	:= l_x_operation_tbl;
	x_op_resource_tbl := l_x_op_resource_tbl;
	x_sub_resource_tbl := l_x_sub_resource_tbl;
	x_op_network_tbl := l_x_op_network_tbl;
	x_rtg_return_status := l_x_rtg_return_status;
	x_rtg_msg_count	:= l_x_rtg_msg_count;
	x_rtg_msg_list	:= l_x_rtg_msg_list;

	-- Handle errors
	IF l_x_rtg_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_RTG_BO_FAILED');
--		FND_MESSAGE.SET_ENCODED('Call to Routing Business Object API Failed.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	-- ============================================================
	-- Step 4: Create BOM and attach it to the newly created Activity
	Create_Activity_BOM(
		p_target_item_rec => l_x_curr_item_rec
		, p_work_order_rec => l_x_work_order_rec
		, p_material_copy_option => p_material_copy_option,
		x_bom_header_rec 		=> l_x_bom_header_rec,
		x_bom_revision_tbl 		=> l_x_bom_revision_tbl,
		x_bom_component_tbl 		=> l_x_bom_component_tbl,
		x_bom_ref_designator_tbl 	=> l_x_bom_ref_designator_tbl,
		x_bom_sub_component_tbl		=> l_x_bom_sub_component_tbl,
		x_bom_return_status		=> l_x_bom_return_status,
		x_bom_msg_count			=> l_x_bom_msg_count,
		x_bom_msg_list			=> l_x_bom_msg_list
	);
	-- Assign outputs.
	x_bom_header_rec := l_x_bom_header_rec;
	x_bom_revision_tbl := l_x_bom_revision_tbl;
	x_bom_component_tbl := l_x_bom_component_tbl;
	x_bom_ref_designator_tbl := l_x_bom_ref_designator_tbl;
	x_bom_sub_component_tbl	:= l_x_bom_sub_component_tbl;
	x_bom_return_status := l_x_bom_return_status;
	x_bom_msg_count := l_x_bom_msg_count;
	x_bom_msg_list := l_x_bom_msg_list;

	-- Handle errors
	IF l_x_bom_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_BOM_BO_FAILED');
--		FND_MESSAGE.SET_ENCODED('Call to Routing Business Object API Failed.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	-- ============================================================
	-- Step 5: Update Association to Asset Numbers for the newly created activity
	IF p_association_copy_option <> 1 THEN
		-- p_association_copy_option <> 1 (NONE), call private package to create association
		EAM_ActivityAssociation_PVT.Create_Association(
			p_api_version => 1.0,
			x_return_status => l_x_assoc_return_status,
			x_msg_count => l_x_assoc_msg_count,
			x_msg_data => l_x_assoc_msg_data,

			p_target_org_id => l_x_curr_item_rec.organization_id,
			p_target_activity_id => l_x_curr_item_rec.inventory_item_id,

  			p_wip_entity_id	=> l_x_work_order_rec.wip_entity_id,
			p_association_copy_option => p_association_copy_option,

			x_act_num_association_tbl => l_x_act_num_association_tbl,
			x_activity_association_tbl => l_x_activity_association_tbl
		);
		-- Assing outputs
		x_assoc_return_status := l_x_assoc_return_status;
		x_assoc_msg_count := l_x_assoc_msg_count;
		x_assoc_msg_data := l_x_assoc_msg_data;
		x_act_num_association_tbl := l_x_act_num_association_tbl;
		x_activity_association_tbl := l_x_activity_association_tbl;

		-- Handle error
		IF l_x_assoc_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ASSOC_FAILED');
--			FND_MESSAGE.SET_ENCODED('Create Activity Associations failed.');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;

	END IF;

	-- ======================================================================

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


	EAM_ActivityUtilities_PVT.Write_Debug('========== Exiting EAM_Activity_PUB.Create_Activity ==========');

	-- ======================================================================

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Activity_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug('========== EAM_Activity_PUB.Create_Activity: EXPECTED_ERROR ==========');
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Activity_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug('========== EAM_Activity_PUB.Create_Activity: UNEXPECTED_ERROR ==========');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Activity_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
			-- log error message also
			EAM_ActivityUtilities_PVT.Write_Debug(FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST, FND_API.G_FALSE));
		END IF;
		EAM_ActivityUtilities_PVT.Write_Debug('========== EAM_Activity_PUB.Create_Activity: OTHER ERROR ==========');
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END Create_Activity;

-- ================================================================================

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
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Copy_Activity';
l_api_version           	CONSTANT NUMBER 		:= 1.0;

-- local variables
l_create_txn_type		CONSTANT VARCHAR(10) := 'CREATE';

-- local variables for validating source Work Order
l_x_work_order_rec		EAM_Activity_PUB.Work_Order_Rec_Type;
l_x_work_order_ret_sts		VARCHAR2(1);

-- local variables for calling INV_Item_GRP package
l_asset_activity		INV_Item_GRP.Item_rec_type;
l_x_curr_item_rec		INV_Item_GRP.Item_rec_type;
l_x_curr_item_return_status	VARCHAR2(1);
l_x_curr_item_error_tbl		INV_Item_GRP.Error_tbl_type;
l_x_master_item_rec		INV_Item_GRP.Item_rec_type;
l_x_master_item_return_status	VARCHAR2(1);
l_x_master_item_error_tbl	INV_Item_GRP.Error_tbl_type;

-- local variables for calling copy_bill API
l_source_bom_sequence_id	NUMBER;
l_target_bom_sequence_id	NUMBER;
l_copy_bill_error_msg		VARCHAR2(20000);

l_bom_head_rec			BOM_BO_PUB.Bom_Head_Rec_Type;

l_x_bom_header_rec		BOM_BO_PUB.Bom_Head_Rec_Type;
l_x_bom_revision_tbl		BOM_BO_PUB.Bom_Revision_Tbl_Type;
l_x_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
l_x_bom_ref_designator_tbl	BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
l_x_bom_sub_component_tbl	BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
l_x_bom_return_status		VARCHAR2(1);
l_x_bom_msg_count		NUMBER;
l_x_bom_msg_list		Error_Handler.Error_Tbl_Type;

-- local variables for call the Routing Business Object API
l_source_rtg_sequence_id	NUMBER;
l_target_rtg_sequence_id	NUMBER;

l_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;

l_x_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
l_x_rtg_revision_tbl		BOM_RTG_PUB.Rtg_Revision_Tbl_Type;
l_x_operation_tbl		BOM_RTG_PUB.Operation_Tbl_Type;
l_x_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
l_x_sub_resource_tbl		BOM_RTG_PUB.Sub_Resource_Tbl_Type;
l_x_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
l_x_rtg_return_status		VARCHAR2(1);
l_x_rtg_msg_count		NUMBER;
l_x_rtg_msg_list		Error_Handler.Error_Tbl_Type;

-- local variables for call Association Creation package
l_x_assoc_return_status		VARCHAR2(1);
l_x_assoc_msg_count		NUMBER;
l_x_assoc_msg_data		VARCHAR2(20000);
l_x_act_num_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;
l_x_activity_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Copy_Activity_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	-- ============================================================
	EAM_ActivityUtilities_PVT.Write_Debug('========== Entering EAM_Activity_PUB.Copy_Activity ==========');
	EAM_ActivityUtilities_PVT.Write_Debug('Organization_Id=' || p_asset_activity.Organization_Id);
	EAM_ActivityUtilities_PVT.Write_Debug('Organization_Code=' || p_asset_activity.Organization_Code);
	EAM_ActivityUtilities_PVT.Write_Debug('Inventory_Item_Id=' || p_asset_activity.Inventory_Item_Id);
	EAM_ActivityUtilities_PVT.Write_Debug('Item Number=' || p_asset_activity.Item_Number);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment1=' || p_asset_activity.Segment1);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment2=' || p_asset_activity.Segment2);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment3=' || p_asset_activity.Segment3);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment4=' || p_asset_activity.Segment4);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment5=' || p_asset_activity.Segment5);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment6=' || p_asset_activity.Segment6);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment7=' || p_asset_activity.Segment7);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment8=' || p_asset_activity.Segment8);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment9=' || p_asset_activity.Segment9);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment10=' || p_asset_activity.Segment10);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment11=' || p_asset_activity.Segment11);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment12=' || p_asset_activity.Segment12);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment13=' || p_asset_activity.Segment13);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment14=' || p_asset_activity.Segment14);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment15=' || p_asset_activity.Segment15);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment16=' || p_asset_activity.Segment16);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment17=' || p_asset_activity.Segment17);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment18=' || p_asset_activity.Segment18);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment19=' || p_asset_activity.Segment19);
	EAM_ActivityUtilities_PVT.Write_Debug('Segment20=' || p_asset_activity.Segment20);
	EAM_ActivityUtilities_PVT.Write_Debug('Description=' || p_asset_activity.Description);

	-- ============================================================
	-- Step 1: Validate inputs
	-- 1 a) Validate ???

	-- fixthis: any other inputs needed to be validated?

	-- 1 b) Validate copy options
	Validate_Copy_Activity_Options(
		p_bom_copy_option,
		p_routing_copy_option,
		p_association_copy_option
	);

	-- ============================================================
	-- Step 2: Create Asset Activity. Call INV_Item_GRP package.

	l_asset_activity := p_asset_activity;

	l_asset_activity.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_asset_activity.EAM_ACTIVITY_CAUSE_CODE := p_activity_cause_code;
	l_asset_activity.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;
	l_asset_activity.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_asset_activity.EAM_ACTIVITY_SOURCE_CODE := p_activity_source_code;

	Create_Item(
		p_asset_activity => l_asset_activity,
		p_template_id => p_template_id,
		p_template_name => p_template_name,

		x_curr_item_rec 		=> l_x_curr_item_rec,
		x_curr_item_return_status 	=> l_x_curr_item_return_status,
		x_curr_item_error_tbl 		=> l_x_curr_item_error_tbl,
		x_master_item_rec 		=> l_x_master_item_rec,
		x_master_item_return_status 	=> l_x_master_item_return_status,
		x_master_item_error_tbl 	=> l_x_master_item_error_tbl
	);

	IF l_x_master_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_MASTER_FAILED');
--		FND_MESSAGE.SET_ENCODED('Create Activity under Master Organization failed.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_x_curr_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_CURRENT_FAILED');
--		FND_MESSAGE.SET_ENCODED('Create Activity under Current Organization failed.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

-- Set the Activity Attributes in the Item Record, don't have to do it manually
/*
	-- Overwrite Activity Properties with user-supplied values
	l_x_master_item_rec.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_x_master_item_rec.EAM_ACTIVITY_CAUSE_CODE  := p_activity_cause_code;
	l_x_master_item_rec.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_x_master_item_rec.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;

	BEGIN
		UPDATE	mtl_system_items
		SET	EAM_ACTIVITY_TYPE_CODE = p_activity_type_code,
			EAM_ACTIVITY_CAUSE_CODE = p_activity_cause_code,
			EAM_ACT_SHUTDOWN_STATUS = p_shutdown_type_code,
			EAM_ACT_NOTIFICATION_FLAG = p_notification_req_flag,
			EAM_ACTIVITY_SOURCE_CODE = p_activity_source_code
		WHERE	inventory_item_id = l_x_master_item_rec.inventory_item_id
		AND	organization_id = l_x_master_item_rec.organization_id;
	EXCEPTION
		WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_PROPERTIES');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	END;

	l_x_curr_item_rec.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_x_curr_item_rec.EAM_ACTIVITY_CAUSE_CODE  := p_activity_cause_code;
	l_x_curr_item_rec.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_x_curr_item_rec.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;

	BEGIN
		UPDATE	mtl_system_items
		SET	EAM_ACTIVITY_TYPE_CODE = p_activity_type_code,
			EAM_ACTIVITY_CAUSE_CODE = p_activity_cause_code,
			EAM_ACT_SHUTDOWN_STATUS = p_shutdown_type_code,
			EAM_ACT_NOTIFICATION_FLAG = p_notification_req_flag,
			EAM_ACTIVITY_SOURCE_CODE = p_activity_source_code
		WHERE	inventory_item_id = l_x_curr_item_rec.inventory_item_id
		AND	organization_id = l_x_curr_item_rec.organization_id;
	EXCEPTION
		WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_PROPERTIES');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	END;
*/

	-- Assign outputs
	x_curr_item_rec 		:= l_x_curr_item_rec;
	x_curr_item_return_status 	:= l_x_curr_item_return_status;
	x_curr_item_error_tbl 		:= l_x_curr_item_error_tbl;
	x_master_item_rec 		:= l_x_master_item_rec;
	x_master_item_return_status 	:= l_x_master_item_return_status;
	x_master_item_error_tbl 	:= l_x_master_item_error_tbl;

	-- ============================================================
        -- Bug # 3662214 : Need to create Routing first and then BOM so
	-- that operation sequence number in BOM is retained.

	-- Step 3: Copy Routing
	EAM_ActivityUtilities_PVT.Write_Debug('-------- Beginning Copy Routing --------');

	-- 3 a) Check Routing Copy Option
	EAM_ActivityUtilities_PVT.Write_Debug('p_routing_copy_option=' || p_routing_copy_option);
	IF p_routing_copy_option = 2 THEN

		-- 3 b) Check if Source has Routing (sequence id)
		l_source_rtg_sequence_id := EAM_ActivityUtilities_PVT.Get_Rtg_Sequence_id(
								p_organization_id => p_source_org_id,
								p_assembly_item_id => p_source_activity_id,
								p_alternate_rtg_designator => p_source_alt_rtg_designator);
		EAM_ActivityUtilities_PVT.Write_Debug('l_source_rtg_sequence_id=' || l_source_rtg_sequence_id);

		IF l_source_rtg_sequence_id IS NULL THEN
			-- Source Activity does not have Routing, nothing to copy
			NULL;
		ELSE

			-- 4 c) Create target Routing header

--			l_rtg_header_rec := NULL;
			-- populate fields
			l_rtg_header_rec.Transaction_Type := l_create_txn_type;
			l_rtg_header_rec.Assembly_Item_Name := l_x_curr_item_rec.Item_Number;
			l_rtg_header_rec.Organization_Code := l_x_curr_item_rec.Organization_Code;

			Error_Handler.initialize;
			-- log call to Process_Rtg API
			EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_RTG_PUB.Process_Rtg **********');
			BOM_RTG_PUB.Process_Rtg(
				p_rtg_header_rec 	=> l_rtg_header_rec
				, x_rtg_header_rec	=> l_x_rtg_header_rec
				, x_rtg_revision_tbl	=> l_x_rtg_revision_tbl
				, x_operation_tbl	=> l_x_operation_tbl
				, x_op_resource_tbl	=> l_x_op_resource_tbl
				, x_sub_resource_tbl	=> l_x_sub_resource_tbl
				, x_op_network_tbl	=> l_x_op_network_tbl
				, x_return_status	=> l_x_rtg_return_status
				, x_msg_count		=> l_x_rtg_msg_count
			);
			EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_RTG_PUB.Process_Rtg **********');

			-- log errors
			EAM_ActivityUtilities_PVT.Write_Debug('l_x_rtg_return_status=' || l_x_rtg_return_status);
			EAM_ActivityUtilities_PVT.Write_Debug('l_x_rtg_msg_count=' || l_x_rtg_msg_count);
			Error_Handler.Get_Message_List(l_x_rtg_msg_list);
			EAM_ActivityUtilities_PVT.Write_Debug('Results of BOM_RTG_PUB.Process_Rtg >>>>>');
			EAM_ActivityUtilities_PVT.Log_Bom_Error_Tbl(l_x_rtg_msg_list);
			EAM_ActivityUtilities_PVT.Write_Debug('End of Results of BOM_RTG_PUB.Process_Rtg <<<<<');

			-- Handle errors
			IF l_x_bom_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_BOM_BO_FAILED');
		--		FND_MESSAGE.SET_ENCODED('Call to Routing Business Object API Failed.');
				EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			l_target_rtg_sequence_id := EAM_ActivityUtilities_PVT.Get_Rtg_Sequence_id(
							p_organization_id => l_x_curr_item_rec.organization_id,
							p_assembly_item_id => l_x_curr_item_rec.inventory_item_id,
							p_alternate_rtg_designator => NULL);
			EAM_ActivityUtilities_PVT.Write_Debug('l_target_rtg_sequence_id=' || l_target_rtg_sequence_id);

			-- 4 d) Call copy_routing API
			-- log call to copy_routing API
			EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_COPY_ROUTING.copy_routing **********');
			BOM_COPY_ROUTING.copy_routing(
				to_sequence_id		=>	l_target_rtg_sequence_id,
				from_sequence_id	=>	l_source_rtg_sequence_id,
				from_org_id		=>	p_source_org_id,
				to_org_id		=>	l_x_curr_item_rec.organization_id,
				user_id			=>	FND_GLOBAL.USER_ID,
				to_item_id		=>	l_x_curr_item_rec.inventory_item_id,
				direction		=>	1,
				to_alternate		=>	NULL,
				rev_date		=>	p_source_rtg_rev_date
			);
			EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_COPY_ROUTING.copy_routing **********');

			-- write copy_routing error message to fnd message stack and log file
			EAM_ActivityUtilities_PVT.Write_Debug('Results of BOM_COPY_ROUTING.copy_routing >>>>>');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			EAM_ActivityUtilities_PVT.Write_Debug('End of Results of BOM_COPY_ROUTING.copy_routing <<<<<');

		END IF; -- l_source_rtg_sequence_id IS NULL

	END IF; -- p_routing_copy_option

	EAM_ActivityUtilities_PVT.Write_Debug('-------- Finished Copy Routing --------');

	-- ============================================================
	-- Step 4: Copy BOM
	EAM_ActivityUtilities_PVT.Write_Debug('-------- Beginning Copy BOM --------');

	-- 4 a) Check BOM Copy Option
	EAM_ActivityUtilities_PVT.Write_Debug('p_bom_copy_option=' || p_bom_copy_option);
	IF p_bom_copy_option = 2 THEN

		-- 4 b) Check if Source has BOM (sequence_id)
		l_source_bom_sequence_id := EAM_ActivityUtilities_PVT.Get_Bom_Sequence_id(
								p_organization_id => p_source_org_id,
								p_assembly_item_id => p_source_activity_id,
								p_alternate_bom_designator => p_source_alt_bom_designator);
		EAM_ActivityUtilities_PVT.Write_Debug('l_source_bom_sequence_id=' || l_source_bom_sequence_id);

		IF l_source_bom_sequence_id IS NULL THEN
			-- Source Activity does not have BOM, nothing to copy
			NULL;
		ELSE

			-- 3 c) Create target BOM header (and get bom sequence_id)
--			l_bom_head_rec := NULL;
			l_bom_head_rec.Transaction_Type := l_create_txn_type;
			l_bom_head_rec.Assembly_Item_Name := l_x_curr_item_rec.Item_Number;
			l_bom_head_rec.Organization_Code := l_x_curr_item_rec.Organization_Code;
			l_bom_head_rec.Assembly_Type := 1;

			-- Create empty BOM header through BOM Business Object API
			Error_Handler.initialize;
			-- log call to Process_BOM API
			EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_BO_PUB.Process_BOM **********');
			BOM_BO_PUB.Process_BOM(
				p_bom_header_rec 		=> l_bom_head_rec,
				x_bom_header_rec 		=> l_x_bom_header_rec,
				x_bom_revision_tbl 		=> l_x_bom_revision_tbl,
				x_bom_component_tbl 		=> l_x_bom_component_tbl,
				x_bom_ref_designator_tbl 	=> l_x_bom_ref_designator_tbl,
				x_bom_sub_component_tbl		=> l_x_bom_sub_component_tbl,
				x_return_status			=> l_x_bom_return_status,
				x_msg_count			=> l_x_bom_msg_count
			);
			EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_BO_PUB.Process_BOM **********');

			-- log errors
			EAM_ActivityUtilities_PVT.Write_Debug('l_x_bom_return_status=' || l_x_bom_return_status);
			EAM_ActivityUtilities_PVT.Write_Debug('l_x_bom_msg_count=' || l_x_bom_msg_count);
			Error_Handler.Get_Message_List(l_x_bom_msg_list);
			EAM_ActivityUtilities_PVT.Write_Debug('Results of BOM_BO_PUB.Process_BOM >>>>>');
			EAM_ActivityUtilities_PVT.Log_Bom_Error_Tbl(l_x_bom_msg_list);
			EAM_ActivityUtilities_PVT.Write_Debug('End of Results of BOM_BO_PUB.Process_BOM <<<<<');

			-- Handle errors
			IF l_x_rtg_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_RTG_BO_FAILED');
--				FND_MESSAGE.SET_ENCODED('Call to Routing Business Object API Failed.');
				EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			l_target_bom_sequence_id := EAM_ActivityUtilities_PVT.Get_Bom_Sequence_id(
							p_organization_id => l_x_curr_item_rec.organization_id,
							p_assembly_item_id => l_x_curr_item_rec.inventory_item_id,
							p_alternate_bom_designator => NULL);
			EAM_ActivityUtilities_PVT.Write_Debug('l_target_bom_sequence_id=' || l_target_bom_sequence_id);

			-- 3 d) Call copy_bill API
			-- log call to copy_bill API
			EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_COPY_BILL.copy_bill **********');
  			BOM_COPY_BILL.copy_bill(
				to_sequence_id		=>	l_target_bom_sequence_id,
				from_sequence_id 	=>	l_source_bom_sequence_id,
				from_org_id		=>	p_source_org_id,
				to_org_id		=>	l_x_curr_item_rec.organization_id,
				user_id			=>	FND_GLOBAL.USER_ID,
				to_item_id		=>	l_x_curr_item_rec.inventory_item_id,
				direction		=>	1,
				to_alternate		=>	NULL,
				rev_date		=>	p_source_bom_rev_date,
				e_change_notice		=>	NULL,
				rev_item_seq_id		=>	NULL,
				bill_or_eco		=>	1,
				eco_eff_date		=>	NULL,
				from_item_id		=>	p_source_activity_id
			);
			EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_COPY_BILL.copy_bill **********');

			-- write copy_bill error message to fnd message stack and log file
			EAM_ActivityUtilities_PVT.Write_Debug('Results of BOM_COPY_BILL.copy_bill >>>>>');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			EAM_ActivityUtilities_PVT.Write_Debug('End of Results of BOM_COPY_BILL.copy_bill <<<<<');


		END IF; -- l_source_bom_sequence_id IS NULL

	END IF; -- p_bom_copy_option = 2

	EAM_ActivityUtilities_PVT.Write_Debug('-------- Finished Copy BOM --------');

	-- ============================================================
	-- Step 5: Update Association to Asset Numbers for the newly created activity
	EAM_ActivityUtilities_PVT.Write_Debug('-------- Beginning Copy Association --------');

	EAM_ActivityUtilities_PVT.Write_Debug('p_association_copy_option=' || p_association_copy_option);
	IF p_association_copy_option <> 1 THEN
		-- p_association_copy_option <> 1 (NONE), call private package to create association
		EAM_ActivityUtilities_PVT.Write_Debug(
			'********** Calling EAM_ActivityAssociation_PVT.Create_Association **********');
		EAM_ActivityAssociation_PVT.Create_Association(
			p_api_version => 1.0,
			x_return_status => l_x_assoc_return_status,
			x_msg_count => l_x_assoc_msg_count,
			x_msg_data => l_x_assoc_msg_data,

			p_target_org_id => l_x_curr_item_rec.organization_id,
			p_target_activity_id => l_x_curr_item_rec.inventory_item_id,
  			p_wip_entity_id	=> NULL,
			p_source_org_id => p_source_org_id,
			p_source_activity_id => p_source_activity_id,
			p_association_copy_option => p_association_copy_option,

			x_act_num_association_tbl => l_x_act_num_association_tbl,
			x_activity_association_tbl => l_x_activity_association_tbl
		);
		EAM_ActivityUtilities_PVT.Write_Debug(
			'********** Returned from EAM_ActivityAssociation_PVT.Create_Association **********');
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_assoc_return_status=' || l_x_assoc_return_status);
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_assoc_msg_count=' || l_x_assoc_msg_count);
		EAM_ActivityUtilities_PVT.Write_Debug('l_x_assoc_msg_data=' || l_x_assoc_msg_data);

		-- Assing outputs
		x_assoc_return_status := l_x_assoc_return_status;
		x_assoc_msg_count := l_x_assoc_msg_count;
		x_assoc_msg_data := l_x_assoc_msg_data;
		x_act_num_association_tbl := l_x_act_num_association_tbl;
		x_activity_association_tbl := l_x_activity_association_tbl;

		-- Handle error
		IF l_x_assoc_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ASSOC_FAILED');
--			FND_MESSAGE.SET_ENCODED('Create Activity Associations failed.');
			EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;

	END IF;

	EAM_ActivityUtilities_PVT.Write_Debug('-------- Finished Copy Association --------');

	-- ======================================================================


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

	EAM_ActivityUtilities_PVT.Write_Debug('========== Exiting EAM_Activity_PUB.Copy_Activity ==========');


	-- ======================================================================
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Copy_Activity_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug('========== EAM_Activity_PUB.Copy_Activity: EXPECTED_ERROR ==========');
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Copy_Activity_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug('========== EAM_Activity_PUB.Copy_Activity: UNEXPECTED_ERROR ==========');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO Copy_Activity_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
			-- log error message also
			EAM_ActivityUtilities_PVT.Write_Debug(FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST, FND_API.G_FALSE));
		END IF;
		EAM_ActivityUtilities_PVT.Write_Debug('========== EAM_Activity_PUB.Copy_Activity: OTHER ERROR ==========');
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END Copy_Activity;


-- ================================================================================

PROCEDURE Create_Activity_From_Form (
	p_wip_entity_id			IN	NUMBER
	, p_asset_activity		IN	VARCHAR2
	, p_segment1			IN	VARCHAR2
	, p_segment2			IN	VARCHAR2
	, p_segment3			IN	VARCHAR2
	, p_segment4			IN	VARCHAR2
	, p_segment5			IN	VARCHAR2
	, p_segment6			IN	VARCHAR2
	, p_segment7			IN	VARCHAR2
	, p_segment8			IN	VARCHAR2
	, p_segment9			IN	VARCHAR2
	, p_segment10			IN	VARCHAR2
	, p_segment11			IN	VARCHAR2
	, p_segment12			IN	VARCHAR2
	, p_segment13			IN	VARCHAR2
	, p_segment14			IN	VARCHAR2
	, p_segment15			IN	VARCHAR2
	, p_segment16			IN	VARCHAR2
	, p_segment17			IN	VARCHAR2
	, p_segment18			IN	VARCHAR2
	, p_segment19			IN	VARCHAR2
	, p_segment20			IN	VARCHAR2
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
	)
IS

	l_create_activity_ver		NUMBER := 1.0;
	l_x_return_status		VARCHAR2(1);
	l_x_msg_count			NUMBER;
	l_x_msg_data			VARCHAR2(20000);

	l_asset_activity		INV_Item_GRP.Item_Rec_Type;
	l_work_order_rec		EAM_Activity_PUB.Work_Order_Rec_Type;
	l_x_inventory_item_id		NUMBER;
	l_x_work_order_rec		EAM_Activity_PUB.Work_Order_Rec_Type;

-- output variables of inv package
	l_x_curr_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_curr_item_return_status	VARCHAR2(1);
	l_x_curr_item_error_tbl		INV_Item_GRP.Error_Tbl_Type;
	l_x_master_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_master_item_return_status	VARCHAR2(1);
	l_x_master_item_error_tbl	INV_Item_GRP.Error_Tbl_Type;
-- output variables of Routing Business Object API
	l_x_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
	l_x_rtg_revision_tbl		BOM_RTG_PUB.Rtg_Revision_Tbl_Type;
	l_x_operation_tbl		BOM_RTG_PUB.Operation_Tbl_Type;
	l_x_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
	l_x_sub_resource_tbl		BOM_RTG_PUB.Sub_Resource_Tbl_Type;
	l_x_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
	l_x_rtg_return_status		VARCHAR2(1);
	l_x_rtg_msg_count		NUMBER;
-- output variables of BOM Business Object API
	l_x_bom_header_rec		BOM_BO_PUB.Bom_Head_Rec_Type;
	l_x_bom_revision_tbl		BOM_BO_PUB.Bom_Revision_Tbl_Type;
	l_x_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
	l_x_bom_ref_designator_tbl	BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
	l_x_bom_sub_component_tbl	BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
	l_x_bom_return_status		VARCHAR2(1);
	l_x_bom_msg_count		NUMBER;
-- Routing and BOM common Error Handler
	l_x_bom_error_list		Error_Handler.Error_Tbl_Type;
	l_x_bom_error_count		INTEGER;
	l_bom_error_count		INTEGER;
	l_index				BINARY_INTEGER;
	l_x_rtg_error_list		Error_Handler.Error_Tbl_Type;
	l_x_rtg_error_count		INTEGER;
-- Activity Association
	l_x_assoc_return_status		VARCHAR2(1);
	l_x_assoc_msg_count		NUMBER;
	l_x_assoc_msg_data		VARCHAR2(20000);
	l_x_act_num_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;
	l_x_activity_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;

BEGIN

	EAM_ActivityUtilities_PVT.Open_Debug_Session;

	-- 1: Step up activity parameters
	l_work_order_rec.wip_entity_id := p_wip_entity_id;
	l_asset_activity.Description := p_description;

	-- 1.1: Set up Item Number. Use segments if specified.
	IF 	p_segment1 IS NOT NULL OR
		p_segment2 IS NOT NULL OR
		p_segment3 IS NOT NULL OR
		p_segment4 IS NOT NULL OR
		p_segment5 IS NOT NULL OR
		p_segment6 IS NOT NULL OR
		p_segment7 IS NOT NULL OR
		p_segment8 IS NOT NULL OR
		p_segment9 IS NOT NULL OR
		p_segment10 IS NOT NULL OR
		p_segment11 IS NOT NULL OR
		p_segment12 IS NOT NULL OR
		p_segment13 IS NOT NULL OR
		p_segment14 IS NOT NULL OR
		p_segment15 IS NOT NULL OR
		p_segment16 IS NOT NULL OR
		p_segment17 IS NOT NULL OR
		p_segment18 IS NOT NULL OR
		p_segment19 IS NOT NULL OR
		p_segment20 IS NOT NULL
	THEN
		l_asset_activity.Segment1 := p_segment1;
		l_asset_activity.Segment2 := p_segment2;
		l_asset_activity.Segment3 := p_segment3;
		l_asset_activity.Segment4 := p_segment4;
		l_asset_activity.Segment5 := p_segment5;
		l_asset_activity.Segment6 := p_segment6;
		l_asset_activity.Segment7 := p_segment7;
		l_asset_activity.Segment8 := p_segment8;
		l_asset_activity.Segment9 := p_segment9;
		l_asset_activity.Segment10 := p_segment10;
		l_asset_activity.Segment11 := p_segment11;
		l_asset_activity.Segment12 := p_segment12;
		l_asset_activity.Segment13 := p_segment13;
		l_asset_activity.Segment14 := p_segment14;
		l_asset_activity.Segment15 := p_segment15;
		l_asset_activity.Segment16 := p_segment16;
		l_asset_activity.Segment17 := p_segment17;
		l_asset_activity.Segment18 := p_segment18;
		l_asset_activity.Segment19 := p_segment19;
		l_asset_activity.Segment20 := p_segment20;
	ELSE
		l_asset_activity.Item_Number := p_asset_activity;
	END IF;

	-- Set EAM attributes
	l_asset_activity.EAM_ITEM_TYPE := 2; -- EAM Asset Activity

	EAM_Activity_PUB.Create_Activity(
		p_api_version => l_create_activity_ver,

		x_return_status => l_x_return_status,
		x_msg_count => l_x_msg_count,
		x_msg_data => l_x_msg_data,

		p_asset_activity => l_asset_activity,
		p_template_id => p_template_id,

		p_activity_type_code	=> p_activity_type_code,
		p_activity_cause_code 	=> p_activity_cause_code,
		p_shutdown_type_code	=> p_shutdown_type_code,
		p_notification_req_flag	=> p_notification_req_flag,
 		p_activity_source_code => p_activity_source_code,

		p_work_order_rec => l_work_order_rec,
		p_operation_copy_option => p_operation_copy_option,
		p_material_copy_option => p_material_copy_option,
		p_resource_copy_option => p_resource_copy_option,
		p_association_copy_option => p_association_copy_option,

--		x_inventory_item_id => l_x_inventory_item_id,
		x_work_order_rec => l_x_work_order_rec

-- inv variables
		, x_curr_item_rec => l_x_curr_item_rec
		, x_curr_item_return_status => l_x_curr_item_return_status
		, x_curr_item_error_tbl => l_x_curr_item_error_tbl
		, x_master_item_rec => l_x_master_item_rec
		, x_master_item_return_status => l_x_master_item_return_status
		, x_master_item_error_tbl => l_x_master_item_error_tbl

-- Routing outputs
		, x_rtg_header_rec	=> l_x_rtg_header_rec
		, x_rtg_revision_tbl	=> l_x_rtg_revision_tbl
		, x_operation_tbl	=> l_x_operation_tbl
		, x_op_resource_tbl	=> l_x_op_resource_tbl
		, x_sub_resource_tbl	=> l_x_sub_resource_tbl
		, x_op_network_tbl	=> l_x_op_network_tbl
		, x_rtg_return_status	=> l_x_rtg_return_status
		, x_rtg_msg_count	=> l_x_rtg_msg_count
		, x_rtg_msg_list	=> l_x_rtg_error_list
-- BOM outputs
		, x_bom_header_rec 		=> l_x_bom_header_rec
		, x_bom_revision_tbl 		=> l_x_bom_revision_tbl
		, x_bom_component_tbl 		=> l_x_bom_component_tbl
		, x_bom_ref_designator_tbl 	=> l_x_bom_ref_designator_tbl
		, x_bom_sub_component_tbl	=> l_x_bom_sub_component_tbl
		, x_bom_return_status		=> l_x_bom_return_status
		, x_bom_msg_count		=> l_x_bom_msg_count
		, x_bom_msg_list		=> l_x_bom_error_list

		, x_assoc_return_status 	=> l_x_assoc_return_status
		, x_assoc_msg_count		=> l_x_assoc_msg_count
		, x_assoc_msg_data		=> l_x_assoc_msg_data
		, x_act_num_association_tbl	=> l_x_act_num_association_tbl
		, x_activity_association_tbl	=> l_x_activity_association_tbl

	);

	-- Assign outputs

	IF l_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		commit;
		x_successful := TRUE;
	ELSE
		x_successful := FALSE;
	END IF;

	EAM_ActivityUtilities_PVT.Close_Debug_Session;

END Create_Activity_From_Form;


-- ================================================================================

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
	p_asset_activity		IN	VARCHAR2,
	p_segment1			IN	VARCHAR2,
	p_segment2			IN	VARCHAR2,
	p_segment3			IN	VARCHAR2,
	p_segment4			IN	VARCHAR2,
	p_segment5			IN	VARCHAR2,
	p_segment6			IN	VARCHAR2,
	p_segment7			IN	VARCHAR2,
	p_segment8			IN	VARCHAR2,
	p_segment9			IN	VARCHAR2,
	p_segment10			IN	VARCHAR2,
	p_segment11			IN	VARCHAR2,
	p_segment12			IN	VARCHAR2,
	p_segment13			IN	VARCHAR2,
	p_segment14			IN	VARCHAR2,
	p_segment15			IN	VARCHAR2,
	p_segment16			IN	VARCHAR2,
	p_segment17			IN	VARCHAR2,
	p_segment18			IN	VARCHAR2,
	p_segment19			IN	VARCHAR2,
	p_segment20			IN	VARCHAR2,
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

)
IS

l_asset_activity		INV_Item_GRP.Item_rec_type;

l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Activity_With_Template';
l_api_version           	CONSTANT NUMBER 	:= 1.0;

l_x_curr_item_rec		INV_Item_GRP.Item_rec_type;
l_x_curr_item_return_status	VARCHAR2(1);
l_x_curr_item_error_tbl		INV_Item_GRP.Error_tbl_type;

l_x_master_item_rec	INV_Item_GRP.Item_rec_type;
l_x_master_item_return_status	VARCHAR2(1);
l_x_master_item_error_tbl	INV_Item_GRP.Error_tbl_type;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Create_Act_With_Templ_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	-- ============================================================
	EAM_ActivityUtilities_PVT.Write_Debug('========== Entering EAM_Activity_PUB.Create_Activity_With_Template ==========');
	EAM_ActivityUtilities_PVT.Write_Debug('p_organization_id=' || p_organization_id);
	EAM_ActivityUtilities_PVT.Write_Debug('p_organization_code=' || p_organization_code);
	EAM_ActivityUtilities_PVT.Write_Debug('p_asset_activity=' || p_asset_activity);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment1=' || p_segment1);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment2=' || p_segment2);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment3=' || p_segment3);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment4=' || p_segment4);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment5=' || p_segment5);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment6=' || p_segment6);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment7=' || p_segment7);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment8=' || p_segment8);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment9=' || p_segment9);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment10=' || p_segment10);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment11=' || p_segment11);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment12=' || p_segment12);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment13=' || p_segment13);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment14=' || p_segment14);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment15=' || p_segment15);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment16=' || p_segment16);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment17=' || p_segment17);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment18=' || p_segment18);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment19=' || p_segment19);
	EAM_ActivityUtilities_PVT.Write_Debug('p_segment20=' || p_segment20);
	EAM_ActivityUtilities_PVT.Write_Debug('p_description=' || p_description);

	-- ============================================================
	-- Create Asset Activity. Call INV_Item_GRP package.

	l_asset_activity.organization_id := p_organization_id;
	l_asset_activity.organization_code := p_organization_code;

	-- Set up Item Number. Use segments if specified.
	IF 	p_segment1 IS NOT NULL OR
		p_segment2 IS NOT NULL OR
		p_segment3 IS NOT NULL OR
		p_segment4 IS NOT NULL OR
		p_segment5 IS NOT NULL OR
		p_segment6 IS NOT NULL OR
		p_segment7 IS NOT NULL OR
		p_segment8 IS NOT NULL OR
		p_segment9 IS NOT NULL OR
		p_segment10 IS NOT NULL OR
		p_segment11 IS NOT NULL OR
		p_segment12 IS NOT NULL OR
		p_segment13 IS NOT NULL OR
		p_segment14 IS NOT NULL OR
		p_segment15 IS NOT NULL OR
		p_segment16 IS NOT NULL OR
		p_segment17 IS NOT NULL OR
		p_segment18 IS NOT NULL OR
		p_segment19 IS NOT NULL OR
		p_segment20 IS NOT NULL
	THEN
		l_asset_activity.Segment1 := p_segment1;
		l_asset_activity.Segment2 := p_segment2;
		l_asset_activity.Segment3 := p_segment3;
		l_asset_activity.Segment4 := p_segment4;
		l_asset_activity.Segment5 := p_segment5;
		l_asset_activity.Segment6 := p_segment6;
		l_asset_activity.Segment7 := p_segment7;
		l_asset_activity.Segment8 := p_segment8;
		l_asset_activity.Segment9 := p_segment9;
		l_asset_activity.Segment10 := p_segment10;
		l_asset_activity.Segment11 := p_segment11;
		l_asset_activity.Segment12 := p_segment12;
		l_asset_activity.Segment13 := p_segment13;
		l_asset_activity.Segment14 := p_segment14;
		l_asset_activity.Segment15 := p_segment15;
		l_asset_activity.Segment16 := p_segment16;
		l_asset_activity.Segment17 := p_segment17;
		l_asset_activity.Segment18 := p_segment18;
		l_asset_activity.Segment19 := p_segment19;
		l_asset_activity.Segment20 := p_segment20;
	ELSE
		l_asset_activity.Item_Number := p_asset_activity;
	END IF;




	l_asset_activity.description := p_description;

	l_asset_activity.EAM_ACTIVITY_TYPE_CODE := p_activity_type_code;
	l_asset_activity.EAM_ACTIVITY_CAUSE_CODE := p_activity_cause_code;
	l_asset_activity.EAM_ACT_NOTIFICATION_FLAG := p_notification_req_flag;
	l_asset_activity.EAM_ACT_SHUTDOWN_STATUS := p_shutdown_type_code;
	l_asset_activity.EAM_ACTIVITY_SOURCE_CODE := p_activity_source_code;

	Create_Item(
		p_asset_activity => l_asset_activity,
		p_template_id => p_template_id,
		p_template_name => p_template_name,

		x_curr_item_rec 		=> l_x_curr_item_rec,
		x_curr_item_return_status 	=> l_x_curr_item_return_status,
		x_curr_item_error_tbl 		=> l_x_curr_item_error_tbl,
		x_master_item_rec 		=> l_x_master_item_rec,
		x_master_item_return_status 	=> l_x_master_item_return_status,
		x_master_item_error_tbl 	=> l_x_master_item_error_tbl
	);
	-- Assign outputs
	x_curr_item_rec 		:= l_x_curr_item_rec;
	x_curr_item_return_status 	:= l_x_curr_item_return_status;
	x_curr_item_error_tbl 		:= l_x_curr_item_error_tbl;
	x_master_item_rec 		:= l_x_master_item_rec;
	x_master_item_return_status 	:= l_x_master_item_return_status;
	x_master_item_error_tbl 	:= l_x_master_item_error_tbl;

	IF l_x_master_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_MASTER_FAILED');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_x_curr_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_CURRENT_FAILED');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- =============================================================

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


	EAM_ActivityUtilities_PVT.Write_Debug('========== Exiting EAM_Activity_PUB.Create_Activity_With_Template ==========');

	-- ======================================================================

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Act_With_Templ_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug(
			'========== EAM_Activity_PUB.Create_Activity_With_Template: EXPECTED ERROR ==========');
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Act_With_Templ_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug(
			'========== EAM_Activity_PUB.Create_Activity_With_Template: UNEXPECTED ERROR ==========');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Act_With_Templ_PUB;
		EAM_ActivityUtilities_PVT.Write_Debug(
			'========== EAM_Activity_PUB.Create_Activity_With_Template: OTHER ERROR ==========');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END Create_Activity_With_Template;


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

)
IS
--l_current_date			CONSTANT DATE := sysdate;
l_create_txn_type		CONSTANT VARCHAR(10) := 'CREATE';
-- local variabels for calling BOM Business Object API
l_bom_head_rec			BOM_BO_PUB.Bom_Head_Rec_Type;
l_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
l_bom_comp_tbl_index		BINARY_INTEGER;

l_x_bom_header_rec		BOM_BO_PUB.Bom_Head_Rec_Type;
l_x_bom_revision_tbl		BOM_BO_PUB.Bom_Revision_Tbl_Type;
l_x_bom_component_tbl		BOM_BO_PUB.Bom_Comps_Tbl_Type;
l_x_bom_ref_designator_tbl	BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
l_x_bom_sub_component_tbl	BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
l_x_bom_return_status		VARCHAR2(1);
l_x_bom_msg_count		NUMBER;
l_x_bom_msg_list		Error_Handler.Error_Tbl_Type;

begin
--        l_bom_head_rec := NULL;
			l_bom_head_rec.Assembly_Item_Name := p_target_item_rec.Item_Number;
			l_bom_head_rec.Transaction_Type := l_create_txn_type;
			l_bom_head_rec.Organization_Code := p_target_item_rec.Organization_Code;
			--l_bom_head_rec.Alternate_Bom_Code := l_bom_bom_row.alternate_bom_designator;
			--l_bom_head_rec.Assembly_Type := l_bom_bom_row.assembly_type;

-- fixthis??
--			Common_Assembly_Name
--			Common_Organization_Code

			/*l_bom_head_rec.Attribute_Category := l_bom_bom_row.attribute_category;
			l_bom_head_rec.Attribute1 := l_bom_bom_row.attribute1;
			l_bom_head_rec.Attribute2 := l_bom_bom_row.attribute2;
			l_bom_head_rec.Attribute3 := l_bom_bom_row.attribute3;
			l_bom_head_rec.Attribute4 := l_bom_bom_row.attribute4;
			l_bom_head_rec.Attribute5 := l_bom_bom_row.attribute5;
			l_bom_head_rec.Attribute6 := l_bom_bom_row.attribute6;
			l_bom_head_rec.Attribute7 := l_bom_bom_row.attribute7;
			l_bom_head_rec.Attribute8 := l_bom_bom_row.attribute8;
			l_bom_head_rec.Attribute9 := l_bom_bom_row.attribute9;
			l_bom_head_rec.Attribute10 := l_bom_bom_row.attribute10;
			l_bom_head_rec.Attribute11 := l_bom_bom_row.attribute11;
			l_bom_head_rec.Attribute12 := l_bom_bom_row.attribute12;
			l_bom_head_rec.Attribute13 := l_bom_bom_row.attribute13;
			l_bom_head_rec.Attribute14 := l_bom_bom_row.attribute14;
			l_bom_head_rec.Attribute15 := l_bom_bom_row.attribute15;
            */
		--l_bom_head_rec.Alternate_Bom_Code := l_bom_bom_row.alternate_bom_designator;
		--l_bom_head_rec.Assembly_Type := l_bom_bom_row.assembly_type;
	-- log call to Process_BOM API
	EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_BO_PUB.Process_BOM **********');
        BOM_BO_PUB.Process_BOM(
					p_bom_header_rec 		=> l_bom_head_rec,
					p_bom_component_tbl 		=> l_bom_component_tbl,
					x_bom_header_rec 		=> l_x_bom_header_rec,
					x_bom_revision_tbl 		=> l_x_bom_revision_tbl,
					x_bom_component_tbl 		=> l_x_bom_component_tbl,
					x_bom_ref_designator_tbl 	=> l_x_bom_ref_designator_tbl,
					x_bom_sub_component_tbl		=> l_x_bom_sub_component_tbl,
					x_return_status			=> l_x_bom_return_status,
					x_msg_count			=> l_x_bom_msg_count
				);
	EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_BO_PUB.Process_BOM **********');

        x_bom_header_rec := l_x_bom_header_rec;
				x_bom_revision_tbl := l_x_bom_revision_tbl;
				x_bom_component_tbl := l_x_bom_component_tbl;
				x_bom_ref_designator_tbl := l_x_bom_ref_designator_tbl;
				x_bom_sub_component_tbl	:= l_x_bom_sub_component_tbl;
				x_bom_return_status := l_x_bom_return_status;
				x_bom_msg_count := l_x_bom_msg_count;
				Error_Handler.Get_Message_List(l_x_bom_msg_list);
				x_bom_msg_list := l_x_bom_msg_list;
end create_bom_header;

procedure create_bom_header_form(
    --p_target_item_rec		IN INV_Item_GRP.Item_Rec_Type,
    p_inventory_item_name varchar2,
    p_organization_code varchar2,
    x_return_status     OUT NOCOPY	VARCHAR2
)is
    l_target_item_rec INV_Item_GRP.Item_Rec_Type;
    x_bom_header_rec			BOM_BO_PUB.BOM_Head_Rec_Type;
	x_bom_revision_tbl			BOM_BO_PUB.BOM_Revision_Tbl_Type;
	x_bom_component_tbl			BOM_BO_PUB.BOM_Comps_Tbl_Type;
	x_bom_ref_designator_tbl		BOM_BO_PUB.BOM_Ref_Designator_Tbl_Type;
	x_bom_sub_component_tbl			BOM_BO_PUB.BOM_Sub_Component_Tbl_Type;
	x_bom_return_status			VARCHAR2(1);
	x_bom_msg_count				NUMBER;
	x_bom_msg_list				Error_Handler.Error_Tbl_Type;

begin
       l_target_item_rec.item_number := p_inventory_item_name;
       l_target_item_rec.organization_code := p_organization_code;

       EAM_ACTIVITY_PUB.create_bom_header(
            p_target_item_rec		=> l_target_item_rec,
	        --p_source_org_id			IN	NUMBER,
	        --p_source_activity_id		IN	NUMBER, -- inventory_item_id

	        --p_material_copy_option		IN NUMBER,

	       x_bom_header_rec		=> x_bom_header_rec,
	       x_bom_revision_tbl		=> x_bom_revision_tbl,
	       x_bom_component_tbl		=> x_bom_component_tbl,
	       x_bom_ref_designator_tbl	=> x_bom_ref_designator_tbl,
	       x_bom_sub_component_tbl	=> x_bom_sub_component_tbl	,
	       x_bom_return_status	=> x_bom_return_status	,
	       x_bom_msg_count	=> x_bom_msg_count		,
	       x_bom_msg_list	=> x_bom_msg_list
        );

        x_return_status := x_bom_return_status;
end create_bom_header_form;


PROCEDURE Create_Activity_With_Template(
 	--p_api_version           	IN	NUMBER				,
  	--p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	--p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	--p_validation_level		IN  	NUMBER	:=
	--					FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	--x_msg_count			OUT	NUMBER				,
	--x_msg_data			OUT	VARCHAR2			,

	p_organization_id		IN	NUMBER 		:= NULL,
	p_organization_code		IN	NUMBER		:= NULL,
	p_asset_activity		IN	VARCHAR2,
	p_segment1			IN	VARCHAR2,
	p_segment2			IN	VARCHAR2,
	p_segment3			IN	VARCHAR2,
	p_segment4			IN	VARCHAR2,
	p_segment5			IN	VARCHAR2,
	p_segment6			IN	VARCHAR2,
	p_segment7			IN	VARCHAR2,
	p_segment8			IN	VARCHAR2,
	p_segment9			IN	VARCHAR2,
	p_segment10			IN	VARCHAR2,
	p_segment11			IN	VARCHAR2,
	p_segment12			IN	VARCHAR2,
	p_segment13			IN	VARCHAR2,
	p_segment14			IN	VARCHAR2,
	p_segment15			IN	VARCHAR2,
	p_segment16			IN	VARCHAR2,
	p_segment17			IN	VARCHAR2,
	p_segment18			IN	VARCHAR2,
	p_segment19			IN	VARCHAR2,
	p_segment20			IN	VARCHAR2,
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
)is
l_asset_activity		INV_Item_GRP.Item_rec_type;

l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Activity_With_Template';
l_api_version           	CONSTANT NUMBER 	:= 1.0;
l_init_msg_list         CONSTANT VARCHAR2(1) :=  FND_API.G_FALSE	;
l_commit CONSTANT VARCHAR2(1) :=  FND_API.G_TRUE	;
l_validation_level  NUMBER := FND_API.G_VALID_LEVEL_FULL;

l_x_curr_item_rec		INV_Item_GRP.Item_rec_type;
l_x_curr_item_return_status	VARCHAR2(1);
l_x_curr_item_error_tbl		INV_Item_GRP.Error_tbl_type;

l_x_master_item_rec	INV_Item_GRP.Item_rec_type;
l_x_master_item_return_status	VARCHAR2(1);
l_x_master_item_error_tbl	INV_Item_GRP.Error_tbl_type;
l_msg_count number;
l_msg_data varchar2(20000);
begin


	-- ============================================================
   	EAM_ActivityUtilities_PVT.Open_Debug_Session;

    create_activity_with_template(
        p_api_version => l_api_version,
  	    p_init_msg_list =>	l_init_msg_list,
	    p_commit => l_commit,
	    p_validation_level => l_validation_level,
            x_return_status => x_return_status,
            x_msg_count	=> l_msg_count,
	    x_msg_data	=> l_msg_data,
            p_organization_id => p_organization_id,
	    p_organization_code => p_organization_code,
	    p_asset_activity => p_asset_activity,
            p_segment1 => p_segment1,
            p_segment2 => p_segment2,
            p_segment3 => p_segment3,
            p_segment4 => p_segment4,
            p_segment5 => p_segment5,
            p_segment6 => p_segment6,
            p_segment7 => p_segment7,
            p_segment8 => p_segment8,
            p_segment9 => p_segment9,
            p_segment10 => p_segment10,
            p_segment11 => p_segment11,
            p_segment12 => p_segment12,
            p_segment13 => p_segment13,
            p_segment14 => p_segment14,
            p_segment15 => p_segment15,
            p_segment16 => p_segment16,
            p_segment17 => p_segment17,
            p_segment18 => p_segment18,
            p_segment19 => p_segment19,
            p_segment20 => p_segment20,
	    p_description => p_description,
	    p_template_id => p_template_id,
	    p_template_name => p_template_name,
	    p_activity_type_code => p_activity_type_code,
	    p_activity_cause_code => p_activity_cause_code,
	    p_shutdown_type_code => p_shutdown_type_code,
	    p_notification_req_flag => p_notification_req_flag,
	    p_activity_source_code => p_activity_source_code,
            x_curr_item_rec => l_x_curr_item_rec,
	    x_curr_item_return_status => l_x_curr_item_return_status,
	    x_curr_item_error_tbl => l_x_curr_item_error_tbl,
	    x_master_item_rec => l_x_master_item_rec,
	    x_master_item_return_status	=> l_x_master_item_return_status,
	    x_master_item_error_tbl => l_x_master_item_error_tbl
    );

    if (l_x_master_item_return_status = fnd_api.g_ret_sts_success AND l_x_curr_item_return_status = fnd_api.g_ret_sts_success) then
            commit;
    end if;

    /*if x_curr_item_return_status = FND_API.G_RET_STS_SUCCESS AND x_master_item_return_status = FND_API.G_RET_STS_SUCCESS then
            commit;
            x_success := TRUE;
    else
            x_success := FALSE;
    end if;*/

	-- ============================================================
	EAM_ActivityUtilities_PVT.Close_Debug_Session;

end create_activity_with_template;

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
)

IS
--l_current_date			CONSTANT DATE := sysdate;
l_create_txn_type		CONSTANT VARCHAR(10) := 'CREATE';

-- local variables for call the Routing Business Object API
l_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
l_operation_tbl			BOM_RTG_PUB.Operation_Tbl_Type;
l_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
l_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;


l_x_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
l_x_rtg_revision_tbl		BOM_RTG_PUB.Rtg_Revision_Tbl_Type;
l_x_operation_tbl		BOM_RTG_PUB.Operation_Tbl_Type;
l_x_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
l_x_sub_resource_tbl		BOM_RTG_PUB.Sub_Resource_Tbl_Type;
l_x_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
l_x_rtg_return_status		VARCHAR2(1);
l_x_rtg_msg_count		NUMBER;
l_x_rtg_msg_list		Error_Handler.Error_Tbl_Type;



BEGIN

	-- First initialize record fields to NULL
--	l_rtg_header_rec := NULL;
	-- populate fields
	l_rtg_header_rec.Assembly_Item_Name := p_target_item_rec.Item_Number;
	l_rtg_header_rec.Organization_Code := p_target_item_rec.Organization_Code;
	l_rtg_header_rec.Transaction_Type := l_create_txn_type;

	Error_Handler.initialize;
	-- log call to Process_Rtg API
	EAM_ActivityUtilities_PVT.Write_Debug('********** Calling BOM_RTG_PUB.Process_Rtg **********');
	BOM_RTG_PUB.Process_Rtg(
		p_rtg_header_rec 	=> l_rtg_header_rec
		, p_operation_tbl	=> l_operation_tbl
		, p_op_resource_tbl	=> l_op_resource_tbl
		, p_op_network_tbl	=> l_op_network_tbl
		, x_rtg_header_rec	=> l_x_rtg_header_rec
		, x_rtg_revision_tbl	=> l_x_rtg_revision_tbl
		, x_operation_tbl	=> l_x_operation_tbl
		, x_op_resource_tbl	=> l_x_op_resource_tbl
		, x_sub_resource_tbl	=> l_x_sub_resource_tbl
		, x_op_network_tbl	=> l_x_op_network_tbl
		, x_return_status	=> l_x_rtg_return_status
		, x_msg_count		=> l_x_rtg_msg_count
	);
	EAM_ActivityUtilities_PVT.Write_Debug('********** Returned from BOM_RTG_PUB.Process_Rtg **********');

	-- Assign outputs.
	x_rtg_header_rec := l_x_rtg_header_rec;
	x_rtg_revision_tbl := l_x_rtg_revision_tbl;
	x_operation_tbl	:= l_x_operation_tbl;
	x_op_resource_tbl := l_x_op_resource_tbl;
	x_sub_resource_tbl := l_x_sub_resource_tbl;
	x_op_network_tbl := l_x_op_network_tbl;
	x_rtg_return_status := l_x_rtg_return_status;
	x_rtg_msg_count	:= l_x_rtg_msg_count;
	Error_Handler.Get_Message_List(l_x_rtg_msg_list);
	x_rtg_msg_list	:= l_x_rtg_msg_list;


END Create_Routing_Header;

procedure create_routing_header_form(
    --p_target_item_rec		IN INV_Item_GRP.Item_Rec_Type,
    p_inventory_item_name varchar2,
    p_organization_code varchar2,
    x_return_status     OUT NOCOPY	VARCHAR2
)is
    l_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
    l_operation_tbl			BOM_RTG_PUB.Operation_Tbl_Type;
    l_operation_tbl_index		BINARY_INTEGER;
    l_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
    l_op_resource_tbl_index		BINARY_INTEGER;
    l_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
    l_op_network_tbl_index		BINARY_INTEGER;

    l_x_rtg_header_rec		BOM_RTG_PUB.Rtg_Header_Rec_Type;
    l_x_rtg_revision_tbl		BOM_RTG_PUB.Rtg_Revision_Tbl_Type;
    l_x_operation_tbl		BOM_RTG_PUB.Operation_Tbl_Type;
    l_x_op_resource_tbl		BOM_RTG_PUB.Op_Resource_Tbl_Type;
    l_x_sub_resource_tbl		BOM_RTG_PUB.Sub_Resource_Tbl_Type;
    l_x_op_network_tbl		BOM_RTG_PUB.Op_Network_Tbl_Type;
    l_x_rtg_return_status		VARCHAR2(1);
    l_x_rtg_msg_count		NUMBER;
    l_x_rtg_msg_list		Error_Handler.Error_Tbl_Type;

    l_target_item_rec INV_Item_GRP.Item_Rec_Type;

begin
       l_target_item_rec.item_number := p_inventory_item_name;
       l_target_item_rec.organization_code := p_organization_code;

       EAM_ACTIVITY_PUB.create_routing_header(
            p_target_item_rec		=> l_target_item_rec,


	       x_rtg_header_rec		=> l_x_rtg_header_rec,
	       x_rtg_revision_tbl	=> l_x_rtg_revision_tbl,
	       x_operation_tbl		=> l_x_operation_tbl,
	       x_op_resource_tbl	=> l_x_op_resource_tbl,
	       x_sub_resource_tbl	=> l_x_sub_resource_tbl,
	       x_op_network_tbl		=> l_x_op_network_tbl,
	       x_rtg_return_status	=> l_x_rtg_return_status,
	       x_rtg_msg_count	=> l_x_rtg_msg_count,
	       x_rtg_msg_list			=>	l_x_rtg_msg_list
        );

        x_return_status := l_x_rtg_return_status;

        --commit;
end create_routing_header_form;


-- From Saurabh
-- package body
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

    	p_activity_item_name in varchar2,
	p_segment1			IN	VARCHAR2,
	p_segment2			IN	VARCHAR2,
	p_segment3			IN	VARCHAR2,
	p_segment4			IN	VARCHAR2,
	p_segment5			IN	VARCHAR2,
	p_segment6			IN	VARCHAR2,
	p_segment7			IN	VARCHAR2,
	p_segment8			IN	VARCHAR2,
	p_segment9			IN	VARCHAR2,
	p_segment10			IN	VARCHAR2,
	p_segment11			IN	VARCHAR2,
	p_segment12			IN	VARCHAR2,
	p_segment13			IN	VARCHAR2,
	p_segment14			IN	VARCHAR2,
	p_segment15			IN	VARCHAR2,
	p_segment16			IN	VARCHAR2,
	p_segment17			IN	VARCHAR2,
	p_segment18			IN	VARCHAR2,
	p_segment19			IN	VARCHAR2,
	p_segment20			IN	VARCHAR2,
	p_activity_org_id in number,
	p_activity_description in varchar2,

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

)
is
	l_asset_activity		INV_Item_GRP.Item_Rec_Type;
	l_x_curr_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_curr_item_return_status	VARCHAR2(1);
	l_x_curr_item_error_tbl		INV_Item_GRP.Error_Tbl_Type;
	l_x_master_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_master_item_return_status	VARCHAR2(1);
	l_x_master_item_error_tbl	INV_Item_GRP.Error_Tbl_Type;

	l_x_assoc_return_status		VARCHAR2(1);
	l_x_assoc_msg_count		NUMBER;
	l_x_assoc_msg_data		VARCHAR2(20000);
	l_x_act_num_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;
	l_x_activity_association_tbl	EAM_Activity_PUB.Activity_Association_Tbl_Type;
begin

	EAM_ActivityUtilities_PVT.Open_Debug_Session;

	-- Set up Item Number. Use segments if specified.
	IF 	p_segment1 IS NOT NULL OR
		p_segment2 IS NOT NULL OR
		p_segment3 IS NOT NULL OR
		p_segment4 IS NOT NULL OR
		p_segment5 IS NOT NULL OR
		p_segment6 IS NOT NULL OR
		p_segment7 IS NOT NULL OR
		p_segment8 IS NOT NULL OR
		p_segment9 IS NOT NULL OR
		p_segment10 IS NOT NULL OR
		p_segment11 IS NOT NULL OR
		p_segment12 IS NOT NULL OR
		p_segment13 IS NOT NULL OR
		p_segment14 IS NOT NULL OR
		p_segment15 IS NOT NULL OR
		p_segment16 IS NOT NULL OR
		p_segment17 IS NOT NULL OR
		p_segment18 IS NOT NULL OR
		p_segment19 IS NOT NULL OR
		p_segment20 IS NOT NULL
	THEN
		l_asset_activity.Segment1 := p_segment1;
		l_asset_activity.Segment2 := p_segment2;
		l_asset_activity.Segment3 := p_segment3;
		l_asset_activity.Segment4 := p_segment4;
		l_asset_activity.Segment5 := p_segment5;
		l_asset_activity.Segment6 := p_segment6;
		l_asset_activity.Segment7 := p_segment7;
		l_asset_activity.Segment8 := p_segment8;
		l_asset_activity.Segment9 := p_segment9;
		l_asset_activity.Segment10 := p_segment10;
		l_asset_activity.Segment11 := p_segment11;
		l_asset_activity.Segment12 := p_segment12;
		l_asset_activity.Segment13 := p_segment13;
		l_asset_activity.Segment14 := p_segment14;
		l_asset_activity.Segment15 := p_segment15;
		l_asset_activity.Segment16 := p_segment16;
		l_asset_activity.Segment17 := p_segment17;
		l_asset_activity.Segment18 := p_segment18;
		l_asset_activity.Segment19 := p_segment19;
		l_asset_activity.Segment20 := p_segment20;
	ELSE
		l_asset_activity.item_number := p_activity_item_name;
	END IF;

	l_asset_activity.organization_id := p_activity_org_id;
	l_asset_activity.description := p_activity_description;

	EAM_ACTIVITY_PUB.Copy_Activity(
		p_api_version           => p_api_version,
	  	p_init_msg_list		=> p_init_msg_list,
		p_commit	    	=> p_commit,
		p_validation_level	=> p_validation_level,
		x_return_status		=> x_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data,

		-- target activity, need to set org, item name, description
		p_asset_activity	=> l_asset_activity,


		p_template_id		=> p_template_id,
	        p_template_name		=> p_template_name,
	        p_activity_type_code	=> p_activity_type_code,
		p_activity_cause_code 	=> p_activity_cause_code,
		p_shutdown_type_code	=> p_shutdown_type_code,
		p_notification_req_flag	=> p_notification_req_flag,
		p_activity_source_code	=> p_activity_source_code,

		-- source Activity
		p_source_org_id		=> p_source_org_id	,
		p_source_activity_id	=> p_source_activity_id	, -- inventory_item_id
		-- source BOM
		p_source_alt_bom_designator => NULL,
		p_source_bom_rev_date	=> sysdate,
		-- source Routing
		p_source_alt_rtg_designator => NULL,
		p_source_rtg_rev_date	=> sysdate,

		p_bom_copy_option	=> p_bom_copy_option	, -- 1 (NONE) or 2 (ALL)
		p_routing_copy_option	=> p_routing_copy_option	, -- 1 (NONE) or 2 (ALL)
		p_association_copy_option => p_association_copy_option	, -- 1 (NONE) or 2 (ALL)

		x_curr_item_rec		=>l_x_curr_item_rec	,
		x_curr_item_return_status => l_x_curr_item_return_status		,
		x_curr_item_error_tbl	=> l_x_curr_item_error_tbl,
		x_master_item_rec	=> l_x_master_item_rec		,
		x_master_item_return_status => l_x_master_item_return_status	,
		x_master_item_error_tbl	=> l_x_master_item_error_tbl	,

		x_assoc_return_status	=> l_x_assoc_return_status		,
		x_assoc_msg_count	=> l_x_assoc_msg_count		,
		x_assoc_msg_data	=> l_x_assoc_msg_data		,
		x_act_num_association_tbl  => l_x_act_num_association_tbl		,
		x_activity_association_tbl => l_x_activity_association_tbl
	);

	EAM_ActivityUtilities_PVT.Close_Debug_Session;

end Copy_Activity;


/* Procedure to assign the activity to the current maintenance organization */

PROCEDURE Activity_org_assign
( 	p_api_version              IN	NUMBER				,
	x_return_status		   OUT NOCOPY	VARCHAR2		,
	x_msg_count		   OUT NOCOPY	NUMBER			,
	x_msg_data		   OUT NOCOPY	VARCHAR2		,
	p_org_id		   IN	NUMBER,
	p_activity_id	           IN	NUMBER -- inventory_item_id
)IS

 l_api_name       CONSTANT VARCHAR2(30) := 'Activity_org_assign';
 l_api_version    CONSTANT NUMBER       := 1.0;
 l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


l_master_organization_id	NUMBER;
l_item_rec			INV_Item_GRP.Item_rec_type;

-- local variables for calling INV_Item_GRP package

l_x_item_rec		      INV_Item_GRP.Item_rec_type;
l_x_return_status	      VARCHAR2(1);
l_x_error_tbl		      INV_Item_GRP.Error_tbl_type;
l_x_master_item_rec           INV_Item_GRP.Item_rec_type;
l_x_master_item_return_status VARCHAR2(1);
l_x_master_item_error_tbl     INV_Item_GRP.Error_tbl_type;
l_error_string		      VARCHAR2(2000);
l_msg_string		      VARCHAR2(200);


BEGIN
  SAVEPOINT EAM_Activity_PUB;
  -- Standard call to check for call compatibility.
--EAM_ActivityUtilities_PVT.Open_Debug_Session;
  IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
  END IF;
/*
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;
*/
  -- Get master org id
  l_master_organization_id := EAM_ActivityUtilities_PVT.Get_Master_Org_Id(p_org_id);
  EAM_ActivityUtilities_PVT.Write_Debug('l_master_organization_id=' || l_master_organization_id);

  BEGIN
    -- check if the activity exists in Master organization
    SELECT segment1, segment2, segment3, segment4, segment5, segment6, segment7,
           segment8, segment9, segment10, segment11, segment12, segment13, segment14,
	   segment15, segment16, segment17, segment18, segment19, segment20, description,
           eam_activity_type_code, eam_activity_cause_code, eam_activity_source_code,
           eam_act_notification_flag, eam_act_shutdown_status, eam_item_type
      INTO l_item_rec.segment1, l_item_rec.segment2, l_item_rec.segment3, l_item_rec.segment4,
           l_item_rec.segment5, l_item_rec.segment6, l_item_rec.segment7, l_item_rec.segment8,
	   l_item_rec.segment9, l_item_rec.segment10, l_item_rec.segment11, l_item_rec.segment12,
	   l_item_rec.segment13, l_item_rec.segment14, l_item_rec.segment15, l_item_rec.segment16,
	   l_item_rec.segment17, l_item_rec.segment18, l_item_rec.segment19, l_item_rec.segment20,
	   l_item_rec.description, l_item_rec.eam_activity_type_code,
	   l_item_rec.eam_activity_cause_code, l_item_rec.eam_activity_source_code,
	   l_item_rec.eam_act_notification_flag, l_item_rec.eam_act_shutdown_status,
	   l_item_rec.eam_item_type
      FROM mtl_system_items_b
     WHERE organization_id  = l_master_organization_id
       AND inventory_item_id = p_activity_id;

    -- Validate org id and org code
    EAM_ActivityUtilities_PVT.Validate_Organization(
		p_organization_id => p_org_id,
		p_organization_code => l_item_rec.organization_code,
		x_return_status => l_x_return_status,
		x_organization_id => l_item_rec.organization_id,
		x_organization_code => l_item_rec.organization_code
	);

    IF l_x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	RAISE FND_API.G_EXC_ERROR;
    END IF;

	-- ============================================================
    EAM_ActivityUtilities_PVT.Write_Debug('-------- Beginning EAM_Activity_PUB.Activity_org_assign --------');


   IF l_item_rec.inventory_item_flag IS NULL OR
       l_item_rec.inventory_item_flag = fnd_api.g_MISS_CHAR THEN
		l_item_rec.inventory_item_flag := 'Y';
    END IF;
/*
  IF l_item_rec.expense_account IS NULL OR l_item_rec.expense_account = fnd_api.g_MISS_NUM THEN
	-- In the Master Item form, Expense Account defaulted from Master Org. So should use Master Org.
	l_item_rec.expense_account := EAM_ActivityUtilities_PVT.Get_Expense_Account_Id(l_master_organization_id);
    END IF;
    -- Check that expense_account is not null
    IF l_item_rec.expense_account IS NULL OR l_item_rec.expense_account = fnd_api.g_MISS_NUM THEN
	FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_EXPENSE_ACCOUNT_NULL');
        --FND_MESSAGE.SET_ENCODED('Please define the Expense Account for the Organization.');
	EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);

	RAISE FND_API.G_EXC_ERROR;

    END IF;

*/ -- commented for BUG# 5484686
    IF l_item_rec.bom_enabled_flag IS NULL OR
       l_item_rec.bom_enabled_flag = fnd_api.g_MISS_CHAR THEN
		l_item_rec.bom_enabled_flag := 'Y';
    END IF;

    EAM_ActivityUtilities_PVT.Write_Debug('>>>>>>>>>>>>>>> INV_Item_GRP.Create_Item INPUT Parameters >>>>>>>>>>>>>>>');
    EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_item_rec);


    INV_Item_GRP.Create_Item
                 (
			p_Item_rec => l_item_rec,
			p_Template_Id => 19,
			p_Template_Name => null,
			x_Item_rec => l_x_item_rec,
			x_return_status => l_x_return_status,
			x_Error_tbl => l_x_error_tbl
                 );
    Get_Errors
	(
	    p_item_error_tbl=>l_x_error_tbl,
	    x_error_msg_old=>l_error_string,
	    x_error_msg_new=>l_error_string
	);

    -- log outputs
    EAM_ActivityUtilities_PVT.Write_Debug('l_x_return_status=' || l_x_return_status);
    EAM_ActivityUtilities_PVT.Write_Debug('Results of INV_Item_GRP.Create_Item >>>>>');
    EAM_ActivityUtilities_PVT.Log_Item_Error_Tbl(l_x_error_tbl);
    EAM_ActivityUtilities_PVT.Write_Debug('End of Results of INV_Item_GRP.Create_Item <<<<<');
    EAM_ActivityUtilities_PVT.Write_Debug('<<<<<<<<<<<<<<< INV_Item_GRP.Create_Item OUTPUT Parameters <<<<<<<<<<<<<<<');
    EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_x_item_rec);

  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		      -- There is no record in master org... so create in both ...
		      SELECT segment1, segment2, segment3, segment4, segment5, segment6, segment7,
			     segment8, segment9, segment10, segment11, segment12, segment13, segment14,
			     segment15, segment16, segment17, segment18, segment19, segment20, description,
			     eam_activity_type_code, eam_activity_cause_code, eam_activity_source_code,
			     eam_act_notification_flag, eam_act_shutdown_status, eam_item_type
			INTO l_item_rec.segment1, l_item_rec.segment2, l_item_rec.segment3, l_item_rec.segment4,
			     l_item_rec.segment5, l_item_rec.segment6, l_item_rec.segment7, l_item_rec.segment8,
			     l_item_rec.segment9, l_item_rec.segment10, l_item_rec.segment11, l_item_rec.segment12,
			     l_item_rec.segment13, l_item_rec.segment14, l_item_rec.segment15, l_item_rec.segment16,
			     l_item_rec.segment17, l_item_rec.segment18, l_item_rec.segment19, l_item_rec.segment20,
			     l_item_rec.description, l_item_rec.eam_activity_type_code,
			     l_item_rec.eam_activity_cause_code, l_item_rec.eam_activity_source_code,
			     l_item_rec.eam_act_notification_flag, l_item_rec.eam_act_shutdown_status,
			     l_item_rec.eam_item_type
			FROM mtl_system_items_b
		       WHERE inventory_item_id = p_activity_id
			 AND ROWNUM = 1;

		      l_item_rec.organization_id := p_org_id;
		      EAM_ActivityUtilities_PVT.Write_Debug('Creating CURRENT Item...');
		      EAM_ActivityUtilities_PVT.Write_Debug('>>>>>>>>>>>>>>> INV_Item_GRP.Create_Item INPUT Parameters >>>>>>>>>>>>>>>');
		      EAM_ActivityUtilities_PVT.Log_Inv_Item_Rec(l_item_rec);

		      Create_Item(
				p_asset_activity => l_item_rec,
				p_template_id => 19,
				p_template_name => null,
				x_curr_item_rec 		=> l_x_item_rec,
				x_curr_item_return_status 	=> l_x_return_status,
				x_curr_item_error_tbl 		=> l_x_error_tbl,
				x_master_item_rec 		=> l_x_master_item_rec,
				x_master_item_return_status 	=> l_x_master_item_return_status,
				x_master_item_error_tbl 	=> l_x_master_item_error_tbl
			);
Get_Errors
	(
	    p_item_error_tbl=>l_x_master_item_error_tbl,
	    x_error_msg_old=>l_error_string,
	    x_error_msg_new=>l_error_string
	);

  END;

  -- Assign outputs
  x_return_status := l_x_return_status;

  IF nvl(l_x_master_item_return_status, FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_MASTER_FAILED');
	l_msg_string:=FND_MESSAGE.GET;
	--EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
	RAISE FND_API.G_EXC_ERROR;

  END IF;


  IF l_x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CR_ACT_CURRENT_FAILED');
	l_msg_string:=FND_MESSAGE.GET;
	--EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
	-- commented for BUG# 5484686
	RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Standard call to get message count and if count is 1, get message info.
  --fnd_msg_pub.count_and_get(p_count => x_msg_count
  --                            ,p_data => x_msg_data);
  -- commented for BUG# 5484686

  EAM_ActivityUtilities_PVT.Write_Debug('-------- Finished EAM_Activity_PUB.Activity_org_assign --------');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAM_Activity_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        -- fnd_msg_pub.count_and_get(p_count => x_msg_count
        --                          ,p_data => x_msg_data);
	-- commented for BUG# 5484686
    WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAM_Activity_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         --fnd_msg_pub.count_and_get(p_count => x_msg_count
          --                        ,p_data => x_msg_data);
	  -- commented for BUG# 5484686
    WHEN OTHERS THEN
         ROLLBACK TO EAM_Activity_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
        /* IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;*/
	 -- fnd_msg_pub.count_and_get(p_count => x_msg_count
         --                         ,p_data => x_msg_data);
	 -- commented for BUG# 5484686

	 x_msg_data:=l_msg_string||l_error_string;

END Activity_org_assign;

END EAM_Activity_PUB;

/

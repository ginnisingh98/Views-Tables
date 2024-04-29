--------------------------------------------------------
--  DDL for Package Body EAM_ACTIVITYASSOCIATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ACTIVITYASSOCIATION_PVT" AS
/* $Header: EAMVAAAB.pls 120.5.12010000.2 2009/03/21 02:29:15 jvittes ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ActivityAssociation_PVT';
G_ACT_SOURCE VARCHAR2(30) := EAM_CONSTANTS.G_ACT_SOURCE;
G_ACT_CAUSE VARCHAR2(30) := EAM_CONSTANTS.G_ACT_CAUSE;
G_ACT_TYPE VARCHAR2(30) := EAM_CONSTANTS.G_ACT_TYPE;
G_SHUTDOWN_TYPE VARCHAR2(30) := EAM_CONSTANTS.G_SHUTDOWN_TYPE;
G_ACT_PRIORITY VARCHAR2(30) := EAM_CONSTANTS.G_ACT_PRIORITY;

PROCEDURE Create_Association
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=  FND_API.G_VALID_LEVEL_FULL	,
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

)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Association';
l_api_version           	CONSTANT NUMBER 		:= 1.0;

-- local variables
l_current_date				CONSTANT DATE := sysdate;
l_wo_maint_id				NUMBER;
l_wo_maint_type 			NUMBER;
l_wo_dept_id                            NUMBER;
l_wo_wac                                VARCHAR2(10);
l_wo_priority                           NUMBER;
l_wo_tagout                             VARCHAR2(1);

-- derived info from wo item/serial number

l_wo_item_is_serialized			BOOLEAN;
l_temp_gen_object_id			NUMBER;

l_cur_source_org_id			NUMBER;
l_cur_source_activity_id		NUMBER;
l_cur_maintenance_object_id		NUMBER;
l_cur_maintenance_object_type		NUMBER;
l_cur_tmpl_flag				VARCHAR2(1);

l_x_assoc_return_status			VARCHAR2(1);
l_x_assoc_msg_count			NUMBER;
l_x_assoc_msg_data			VARCHAR2(20000);
l_activity_association_tbl		EAM_Activity_PUB.Activity_Association_Tbl_Type;
l_x_activity_association_tbl		EAM_Activity_PUB.Activity_Association_Tbl_Type;
l_default_act_assoc_rec			EAM_Activity_PUB.Activity_Association_Rec_Type;

l_act_assoc_tbl_index			BINARY_INTEGER;
l_source_activity_id			NUMBER;
l_source_org_id				NUMBER;

l_activity_cause_code			VARCHAR2(30);
l_activity_type_code			VARCHAR2(30);
l_activity_source_code			VARCHAR2(30);
l_tagging_required_flag			VARCHAR2(1);
l_shutdown_type_code			VARCHAR2(30);

--log variables
l_module             varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

CURSOR l_act_assoc_cur (
	p_source_org_id			NUMBER,
	p_source_activity_id		NUMBER,
	p_maintenance_object_id		NUMBER,
	p_maintenance_object_type	NUMBER,
	p_tmpl_flag			VARCHAR2
)
IS
	SELECT	meaa.Asset_Activity_Id, meaa.start_date_active, meaa.end_date_active,
                meaa.Priority_Code, meaa.maintenance_object_type, meaa.maintenance_object_id,
                meaa.template_flag, meaa.Attribute_Category, meaa.Attribute1, meaa.Attribute2,
                meaa.Attribute3, meaa.Attribute4, meaa.Attribute5, meaa.Attribute6,
                meaa.Attribute7, meaa.Attribute8, meaa.Attribute9, meaa.Attribute10,
                meaa.Attribute11, meaa.Attribute12, meaa.Attribute13, meaa.Attribute14,
                meaa.Attribute15,
                meaa.Activity_Association_Id, meaa.organization_id, meaa.accounting_class_code,
                meaa.owning_department_id, meaa.Activity_Cause_Code, meaa.Activity_Type_Code,
                meaa.Activity_Source_Code, meaa.Tagging_Required_Flag, meaa.Shutdown_Type_Code
	FROM	mtl_eam_asset_activities_v meaa
	WHERE	meaa.asset_activity_id = p_source_activity_id
	AND	(p_maintenance_object_type IS NULL OR meaa.maintenance_object_type = p_maintenance_object_type)
	AND	(p_maintenance_object_id IS NULL OR meaa.maintenance_object_id = p_maintenance_object_id)
	AND	(p_tmpl_flag IS NULL OR  NVL(meaa.template_flag, 'N') = p_tmpl_flag)
	AND	meaa.maintenance_object_type IS NOT NULL
	AND 	meaa.maintenance_object_id IS NOT NULL
        AND     meaa.organization_id = p_source_org_id
	AND     nvl(meaa.end_date_active,sysdate+1) > sysdate;


BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	-- Standard Start of API savepoint
    	SAVEPOINT	Create_Association_PVT;

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
	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'========== Entering EAM_ActivityAssociation_PVT.Create_Association =========='
		|| 'p_target_org_id=' || p_target_org_id
		|| 'p_target_activity_id=' || p_target_activity_id
		|| 'p_wip_entity_id=' || p_wip_entity_id
		|| 'p_source_org_id=' || p_source_org_id
		|| 'p_source_activity_id=' || p_source_activity_id
		|| 'p_association_copy_option=' || p_association_copy_option);
	end if;

	IF p_association_copy_option = 	1 THEN
		-- copy option = 1 (NONE), nothing to do
		NULL;
	ELSE
		-- copy option is not NONE, need to copy something

		-- Get Item, Serial Number info from Work Order
		IF p_wip_entity_id IS NOT NULL THEN
			-- Get the org_id, act_id, item_id, and serial number association with the WO
			EAM_ActivityUtilities_PVT.Get_Item_Info_From_WO(
				p_wip_entity_id,
				l_source_org_id,
				l_source_activity_id,
				l_wo_maint_id,
				l_wo_maint_type
			);
		ELSE
			-- p_wip_entity_id IS NULL; source activity is specified instead.
			l_source_org_id := p_source_org_id;
			l_source_activity_id := p_source_activity_id;
			l_wo_maint_id := NULL;
			l_wo_maint_type := NULL;
		END IF;

		-- Validate l_source_org_id  should not be Null
		IF l_source_org_id IS NULL THEN
			EAM_ActivityUtilities_PVT.Write_Debug('l_source_ord_id should not be NULL');
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- After this point l_source_activity_id and l_source_org_id are defined,
		-- should use them instead of p_source_activity_id and p_source_org_id.

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'l_source_org_id=' || l_source_org_id
			|| 'l_source_activity_id=' || l_source_activity_id
			|| 'l_wo_maint_id=' || l_wo_maint_id
			|| 'l_wo_maint_type=' || l_wo_maint_id);
		end if;
/*
		-- Derived Work Order item/serial number information.
		-- note gen_object_id could be Null if l_wo_serial_number is Null.
		l_wo_gen_object_id := EAM_ActivityUtilities_PVT.Get_Gen_Object_id(l_source_org_id,
										l_wo_item_id,
										l_wo_serial_number);
                EAM_ActivityUtilities_PVT.Write_Debug('l_wo_gen_object_id=' || l_wo_gen_object_id);
*/
		l_wo_item_is_serialized := EAM_ActivityUtilities_PVT.Is_Item_Serialized(l_source_org_id, l_wo_maint_id, l_wo_maint_type);

		IF l_wo_item_is_serialized  = TRUE THEN

			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'l_wo_item_is_serialized=TRUE');
			end if;

		ELSIF l_wo_item_is_serialized = FALSE THEN

			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'l_wo_item_is_serialized=FALSE');
			end if;

		ELSE
			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'l_wo_item_is_serialized=');
			end if;

		END IF;

		-- Get target Activity Properties
		BEGIN
			SELECT	eam_activity_cause_code, eam_activity_type_code, eam_act_notification_flag,
					eam_act_shutdown_status, eam_activity_source_code
			INTO	l_activity_cause_code, l_activity_type_code, l_tagging_required_flag,
					l_shutdown_type_code, l_activity_source_code
			FROM	mtl_system_items
			WHERE	inventory_item_id = p_target_activity_id
			AND	organization_id = p_target_org_id;
		EXCEPTION
			WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_PROPERTIES');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END;

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'l_activity_cause_code=' || l_activity_cause_code
			|| 'l_activity_type_code=' || l_activity_type_code
			|| 'l_tagging_required_flag=' || l_tagging_required_flag
			|| 'l_shutdown_type_code=' || l_shutdown_type_code
			|| 'l_activity_source_code=' || l_activity_source_code);
		end if;

		--Default new association record
		l_default_act_assoc_rec.Organization_Id := p_target_org_id;
		l_default_act_assoc_rec.Asset_Activity_Id := p_target_activity_id;
		l_default_act_assoc_rec.Start_Date_Active := l_current_date;
		l_default_act_assoc_rec.End_Date_Active := NULL;
--		l_default_act_assoc_rec.Inventory_Item_Id := l_wo_item_id;
--		l_default_act_assoc_rec.Serial_Number := l_wo_serial_number;

                IF (l_wo_maint_type = 3) THEN
			l_default_act_assoc_rec.Owning_Department_Id :=
				EAM_ActivityUtilities_PVT.Default_Owning_Department_Id(NULL, l_wo_maint_id, l_source_org_id);
                ELSE
			l_default_act_assoc_rec.Owning_Department_Id :=
                        	EAM_ActivityUtilities_PVT.Default_Owning_Department_Id(NULL, null, l_source_org_id);
                END IF;

		l_default_act_assoc_rec.Tmpl_Flag := 'N';
--		l_default_act_assoc_rec.Creation_Organization_Id := p_target_org_id;
		-- set Activity Columns
		l_default_act_assoc_rec.Activity_Cause_Code := l_activity_cause_code;
		l_default_act_assoc_rec.Activity_Type_Code := l_activity_type_code;
		l_default_act_assoc_rec.Activity_Source_Code := l_activity_source_code;
		l_default_act_assoc_rec.Tagging_Required_Flag := l_tagging_required_flag;
		l_default_act_assoc_rec.Shutdown_Type_Code := l_shutdown_type_code;

		-- Default cursor parameters
		l_cur_source_org_id := l_source_org_id;
		l_cur_source_activity_id := l_source_activity_id;

		IF p_association_copy_option = 2 THEN
			-- copy option = 2 (CURRENT)

			-- Default cursor parameter for CURRENT
			l_cur_tmpl_flag := 'N';

			IF l_wo_maint_id IS NOT NULL and l_wo_maint_type IS NOT NULL AND
                           ((NOT l_wo_item_is_serialized AND l_wo_maint_type = 2) OR
                            (l_wo_item_is_serialized AND l_wo_maint_type = 3)) THEN

				IF l_source_activity_id IS NOT NULL THEN
					-- Case 1a: Serial Number / Non-Serialized Item with Activity
					-- Need to limit Association cursor to current
					l_cur_maintenance_object_id := l_wo_maint_id;
					l_cur_maintenance_object_type := l_wo_maint_type;

				ELSE
					-- Case 1b: Serial Number / Non-Serialized Item without Activity
					-- Need to create Association; cursor should select no row.
					l_cur_source_org_id := NULL;
					l_cur_source_activity_id := NULL;
					l_activity_association_tbl(1) := l_default_act_assoc_rec;
					l_activity_association_tbl(1).Maintenance_Object_Id := l_wo_maint_id;
					l_activity_association_tbl(1).Maintenance_Object_Type := l_wo_maint_type;

				END IF;

			ELSIF l_wo_maint_id IS NOT NULL AND l_wo_maint_type IS NOT NULL AND
                              (l_wo_item_is_serialized AND l_wo_maint_type = 2) THEN
				-- Case 2: Serialized Item with no Serial Number
				-- Copy none, do nothing.
				l_cur_source_org_id := NULL;
				l_cur_source_activity_id := NULL;


			ELSIF l_wo_maint_id IS NULL AND l_wo_maint_type IS NULL AND
			      l_source_activity_id IS NOT NULL THEN
				-- Case 3: Copy from Activity
				-- Treat as Copy ALL, include all assoc in the Association cursor.
				l_cur_maintenance_object_id := NULL;
				l_cur_maintenance_object_type := NULL;
				l_cur_tmpl_flag := NULL;

			ELSE
				-- shouldn't be here.
				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					'Copy CURRENT: unexpected Work Order Item/Serial Number inputs.');
				end if;

				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

		ELSIF p_association_copy_option = 3 THEN
			-- copy option = 3 (ALL)

			-- Default cursor parameter for ALL
			l_cur_tmpl_flag := NULL;

			IF l_wo_maint_id IS NOT NULL and l_wo_maint_type IS NOT NULL AND
                           ((NOT l_wo_item_is_serialized AND l_wo_maint_type = 2) OR
                            (l_wo_item_is_serialized AND l_wo_maint_type = 3)) THEN

				IF l_source_activity_id IS NOT NULL THEN
					-- Case 1a: Serial Number / Non-Serialized Item with Activity
					-- Include all Associations in Association Cursor.
					l_cur_maintenance_object_id := NULL;
					l_cur_maintenance_object_type := NULL;
				ELSE
					-- Case 1b: Serial Number / Non-Serialized Item without Activity
					-- Need to create Association for current; cursor should select no row.
					l_cur_source_org_id := NULL;
					l_cur_source_activity_id := NULL;
					l_activity_association_tbl(1) := l_default_act_assoc_rec;
					l_activity_association_tbl(1).Maintenance_Object_Id := l_wo_maint_id;
					l_activity_association_tbl(1).Maintenance_Object_Type := l_wo_maint_type;
				END IF;

			ELSIF l_wo_maint_id IS NOT NULL AND l_wo_maint_type IS NOT NULL AND
                              (l_wo_item_is_serialized AND l_wo_maint_type = 2) THEN
        			-- Case 2a: Serialized Item without Serial Number - with Activity
	        		-- Copy none, do nothing.
				l_cur_source_org_id := NULL;
				l_cur_source_activity_id := NULL;

			ELSIF l_wo_maint_id IS NULL AND l_wo_maint_type IS NULL AND
			      l_source_activity_id IS NOT NULL THEN
                              	-- Case 3: Copy from Activity
				-- Include all assoc in the Association cursor.
				l_cur_maintenance_object_id := NULL;
				l_cur_maintenance_object_type := NULL;

			ELSE
				-- shouldn't be here.
				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					'Copy ALL: unexpected Work Order Item/Serial Number inputs.');
				end if;

				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

		ELSE
			-- copy option outside of valid range, shouldn't be here.
			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'Create_Association: unexpected Association Copy Option');
			end if;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;


	-- Copy associations from Cursor to table
	l_act_assoc_tbl_index := NVL(l_activity_association_tbl.LAST, 0) + 1;

        if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'l_cur_source_org_id=' || l_cur_source_org_id
			|| 'l_cur_source_activity_id=' || l_cur_source_activity_id
			|| 'l_cur_maintenance_object_id=' || l_cur_maintenance_object_id
			|| 'l_cur_maintenance_object_type=' || l_cur_maintenance_object_type
			|| 'l_cur_tmpl_flag=' || l_cur_tmpl_flag);
        end if;

	FOR l_act_assoc_row IN l_act_assoc_cur(l_cur_source_org_id,
						l_cur_source_activity_id,
						l_cur_maintenance_object_id,
						l_cur_maintenance_object_type,
						l_cur_tmpl_flag)
	LOOP

		l_activity_association_tbl(l_act_assoc_tbl_index).Organization_Id := p_target_org_id;
		l_activity_association_tbl(l_act_assoc_tbl_index).Asset_Activity_Id := p_target_activity_id;
		l_activity_association_tbl(l_act_assoc_tbl_index).Start_Date_Active := l_act_assoc_row.Start_Date_Active;
		l_activity_association_tbl(l_act_assoc_tbl_index).End_Date_Active := l_act_assoc_row.End_Date_Active;
		l_activity_association_tbl(l_act_assoc_tbl_index).Priority_Code := l_act_assoc_row.Priority_Code;
		IF l_cur_maintenance_object_type = 3 THEN
			l_temp_gen_object_id := l_cur_maintenance_object_id;
		ELSE
			l_temp_gen_object_id := NULL;
		END IF;
		l_activity_association_tbl(l_act_assoc_tbl_index).Owning_Department_Id :=
			NVL(l_act_assoc_row.Owning_Department_Id,
				EAM_ActivityUtilities_PVT.Default_Owning_Department_Id(
					NULL, l_cur_maintenance_object_id, l_cur_source_org_id));
		-- Set Activity Columns
		l_activity_association_tbl(l_act_assoc_tbl_index).Activity_Cause_Code := l_activity_cause_code;
		l_activity_association_tbl(l_act_assoc_tbl_index).Activity_Type_Code := l_activity_type_code;
		l_activity_association_tbl(l_act_assoc_tbl_index).Activity_Source_Code := l_activity_source_code;
		l_activity_association_tbl(l_act_assoc_tbl_index).Tagging_Required_Flag := l_tagging_required_flag;
		l_activity_association_tbl(l_act_assoc_tbl_index).Shutdown_Type_Code := l_shutdown_type_code;
		l_activity_association_tbl(l_act_assoc_tbl_index).Class_Code := l_act_assoc_row.accounting_Class_Code;

		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute_Category := l_act_assoc_row.Attribute_Category;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute1 := l_act_assoc_row.Attribute1;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute2 := l_act_assoc_row.Attribute2;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute3 := l_act_assoc_row.Attribute3;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute4 := l_act_assoc_row.Attribute4;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute5 := l_act_assoc_row.Attribute5;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute6 := l_act_assoc_row.Attribute6;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute7 := l_act_assoc_row.Attribute7;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute8 := l_act_assoc_row.Attribute8;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute9 := l_act_assoc_row.Attribute9;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute10 := l_act_assoc_row.Attribute10;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute11 := l_act_assoc_row.Attribute11;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute12 := l_act_assoc_row.Attribute12;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute13 := l_act_assoc_row.Attribute13;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute14 := l_act_assoc_row.Attribute14;
		l_activity_association_tbl(l_act_assoc_tbl_index).Attribute15 := l_act_assoc_row.Attribute15;

		l_activity_association_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type := l_act_assoc_row.Maintenance_Object_Type;
		l_activity_association_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id := l_act_assoc_row.Maintenance_Object_Id;
		l_activity_association_tbl(l_act_assoc_tbl_index).Tmpl_Flag := l_act_assoc_row.template_flag;

		l_act_assoc_tbl_index := l_act_assoc_tbl_index + 1;

	END LOOP;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_act_assoc_tbl_index=' || l_act_assoc_tbl_index);
	end if;

	-- assign outputs
	x_act_num_association_tbl := l_activity_association_tbl;

	-- Call Procedure to creatwe Asset Number Association
	Create_AssetNumberAssoc(
		p_api_version => 1.0,
		x_return_status => l_x_assoc_return_status,
		x_msg_count => l_x_assoc_msg_count,
		x_msg_data => l_x_assoc_msg_data,

		p_activity_association_tbl => l_activity_association_tbl,
		x_activity_association_tbl => l_x_activity_association_tbl
	);

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_x_assoc_return_status=' || l_x_assoc_return_status
		|| 'l_x_assoc_msg_count=' || l_x_assoc_msg_count
		|| 'l_x_assoc_msg_data' || l_x_assoc_msg_data);
	end if;

	-- assign outputs
	x_activity_association_tbl := l_x_activity_association_tbl;

	-- Handle errors
	IF l_x_assoc_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_AN_ASSOC_FAILED');
--		FND_MESSAGE.SET_ENCODED('Failed to create Asset Number Associations.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Bug # 4089189 : Need to default WAC and dept from WO to the Activity Association with the Asset in WO.
        IF p_wip_entity_id IS NOT NULL THEN
          BEGIN
            SELECT owning_department, class_code, maintenance_object_id, maintenance_object_type, priority, tagout_required
              INTO l_wo_dept_id, l_wo_wac, l_cur_maintenance_object_id, l_cur_maintenance_object_type, l_wo_priority, l_wo_tagout
              FROM wip_discrete_jobs
             WHERE wip_entity_id = p_wip_entity_id;

             UPDATE mtl_eam_asset_activities
                SET priority_code = nvl(l_wo_priority, priority_code)
              WHERE asset_activity_id = p_target_activity_id AND maintenance_object_id = l_cur_maintenance_object_id
                AND maintenance_object_type =  l_cur_maintenance_object_type;

             UPDATE eam_org_maint_defaults
                SET accounting_class_code = nvl(l_wo_wac, accounting_class_code),
                    owning_department_id = nvl(l_wo_dept_id, owning_department_id),
                    tagging_required_flag = nvl(l_wo_tagout, tagging_required_flag)
              WHERE object_id in (SELECT activity_association_id
                                    FROM mtl_eam_asset_activities
                                   WHERE asset_activity_id = p_target_activity_id
                                     AND maintenance_object_id = l_cur_maintenance_object_id
                                     AND maintenance_object_type =  l_cur_maintenance_object_type)
                AND object_type in (40, 60) AND organization_id = p_target_org_id;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityAssociation_PVT.Create_Association: unexpected error.'
			|| 'p_wip_entity_id=' || p_wip_entity_id);
		end if;

            	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

        END IF;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'========== Exiting EAM_ActivityAssociation_PVT.Create_Association ==========');
	end if;

	-- ============================================================

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
	x_msg_data := substr(x_msg_data,1,4000);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Association_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Association_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Association_PVT;
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
		x_msg_data := substr(x_msg_data,1,4000);
END Create_Association;


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
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_AsetNumberAssoc';
l_api_version           	CONSTANT NUMBER 		:= 1.0;

-- local variables
l_count				NUMBER;
l_object_type                   NUMBER;

l_maintenance_object_id		NUMBER;
l_maintenance_object_type	NUMBER;

l_current_date			CONSTANT DATE := sysdate;
l_act_assoc_tbl_index		BINARY_INTEGER;
l_act_assoc_tbl			EAM_Activity_PUB.Activity_Association_Tbl_Type;

l_x_return_status		VARCHAR2(1);
l_failed			BOOLEAN;

--log variables
l_module            varchar2(200) ;
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	-- Standard Start of API savepoint
    	SAVEPOINT	Create_AssetNumberAssoc_PVT;

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
	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'========== Entering EAM_ActivityAssociation_PVT.Create_AssetNumberAssoc =========='
		|| 'p_activity_association_tbl.COUNT=' || p_activity_association_tbl.COUNT);
	end if;

	-- Copy input table to local working variable
	l_act_assoc_tbl := p_activity_association_tbl;

	-- Loop through the rows of the table
	l_act_assoc_tbl_index := l_act_assoc_tbl.FIRST;
	l_failed := FALSE;

	WHILE l_act_assoc_tbl_index IS NOT NULL
	LOOP

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'l_act_assoc_tbl_index=' || l_act_assoc_tbl_index ||
			'; Organization_Id=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id ||
			'; Asset_Activity_Id=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Asset_Activity_Id ||
			'; instance_number=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Instance_number ||
			'; Inventory_Item_Id=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Inventory_Item_Id ||
			'; Serial_Number=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Serial_Number);

			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'Maintenance_Object_Id=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id ||
				'; Maintenance_Object_Type=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type);
		end if;

		-- Validate Organization
		SELECT 	count(*) INTO l_count
		FROM 	wip_eam_parameters
		WHERE 	organization_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id;

		IF l_count <> 1 THEN
			l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ORG_ID');
			l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					'Organization_Id='
					|| l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id);
			end if;

			l_failed := TRUE;
			GOTO next_in_loop;
		END IF;

		-- Validate Activity
		SELECT 	count(*) INTO l_count
		FROM	mtl_system_items
		WHERE	organization_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id
		AND	inventory_item_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Asset_Activity_Id
		AND	eam_item_type = 2;

		IF l_count <> 1 THEN
			l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ACTIVITY_ID');
--			FND_MESSAGE.SET_ENCODED('Invalid Activity Id.');
			l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					'Asset_Activity_Id='
					|| l_act_assoc_tbl(l_act_assoc_tbl_index).Asset_Activity_Id);
			end if;

			l_failed := TRUE;
			GOTO next_in_loop;

		END IF;

		IF l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active IS NOT NULL AND
			l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active IS NOT NULL
		THEN
			-- Start Date and End Date
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active <
				l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active
			THEN
				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_START_END_DATE');
--				FND_MESSAGE.SET_ENCODED('End Date cannot be before Start Date.');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'Asset_Activity_Id='
						|| l_act_assoc_tbl(l_act_assoc_tbl_index).Asset_Activity_Id
						|| 'Start_Date_Active=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active ||
						'; End_Date_Active=' || l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active);

				end if;

				l_failed := TRUE;
				GOTO next_in_loop;

			END IF;
		END IF;

		-- Validate Priority Code
		IF l_act_assoc_tbl(l_act_assoc_tbl_index).Priority_Code IS NOT NULL THEN
			select count(*) into l_count
			from mfg_lookups
			where lookup_type = g_act_priority
			and sysdate between nvl(start_date_active,sysdate)
			and nvl(end_date_active,sysdate)
			and nvl(enabled_flag, 'N') = 'Y'
			and lookup_code = l_act_assoc_tbl(l_act_assoc_tbl_index).Priority_Code;

			IF l_count <> 1 THEN
				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ACT_PRI_CODE');
--				FND_MESSAGE.SET_ENCODED('Invalid Activity Priority Code.');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'Priority_Code=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Priority_Code);
				end if;

				l_failed := TRUE;
				GOTO next_in_loop;
			END IF;
		END IF;

			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Owning_Department_Id IS NOT NULL THEN
				-- Validate Owning Department
				SELECT 	count(*) INTO l_count
				FROM 	bom_departments
				WHERE	organization_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id
				and	department_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Owning_Department_Id
				and 	(disable_date IS NULL
					or disable_date > sysdate);

				IF l_count <> 1 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_OWN_DEPT_ID');
--					FND_MESSAGE.SET_ENCODED('Invalid Owning Department Id.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Owning_Department_Id=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Owning_Department_Id);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;

				END IF;
			END IF;

			-- Validate Activity Type Code
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Type_Code IS NOT NULL THEN
					select count(*) into l_count
				from mfg_lookups
				where lookup_type = g_act_type
				and sysdate between nvl(start_date_active,sysdate)
				and nvl(end_date_active,sysdate)
				and nvl(enabled_flag, 'N') = 'Y'
				and lookup_code = l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Type_Code;

				IF l_count <> 1 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ACT_TYPE_CODE');
--					FND_MESSAGE.SET_ENCODED('Invalid Activity Type Code.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Activity_Type_Code=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Type_Code);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
			END IF;

			-- Validate Activity Cause Code
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Cause_Code IS NOT NULL THEN
				select count(*) into l_count
				from mfg_lookups
				where lookup_type = g_act_cause
				and sysdate between nvl(start_date_active,sysdate)
				and nvl(end_date_active,sysdate)
				and nvl(enabled_flag, 'N') = 'Y'
				and lookup_code = l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Cause_Code;

				IF l_count <> 1 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ACT_CAUSE_CODE');
--					FND_MESSAGE.SET_ENCODED('Invalid Activity Cause Code.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Activity_Cause_Code=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Cause_Code);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
			END IF;

			-- Validate Activity Source Code
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Source_Code IS NOT NULL THEN
				select count(*) into l_count
				from mfg_lookups
				where lookup_type = g_act_source
				and sysdate between nvl(start_date_active,sysdate)
				and nvl(end_date_active,sysdate)
				and nvl(enabled_flag, 'N') = 'Y'
				and lookup_code = l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Source_Code;

				IF l_count <> 1 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ACT_SRC_CODE');
--					FND_MESSAGE.SET_ENCODED('Invalid Activity Source Code.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Activity_Source_Code=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Source_Code);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
			END IF;

			-- Validate Shutdown Type Code
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Shutdown_Type_Code IS NOT NULL THEN
				select count(*) into l_count
				from mfg_lookups
				where lookup_type = g_shutdown_type
				and sysdate between nvl(start_date_active,sysdate)
				and nvl(end_date_active,sysdate)
				and nvl(enabled_flag, 'N') = 'Y'
				and lookup_code = l_act_assoc_tbl(l_act_assoc_tbl_index).Shutdown_Type_Code;

				IF l_count <> 1 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_SHUTDOWN_CODE');
--					FND_MESSAGE.SET_ENCODED('Invalid Activity Shutdown Type Code.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Shutdown_Type_Code=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Shutdown_Type_Code);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
			END IF;

			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Class_Code IS NOT NULL THEN
				select count(*) into l_count
				from wip_accounting_classes
				where class_code = l_act_assoc_tbl(l_act_assoc_tbl_index).Class_Code
				and organization_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id
				and class_type = 6
				and (disable_date is null or sysdate < disable_date);

				IF l_count <> 1 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_CLASS_CODE');
--					FND_MESSAGE.SET_ENCODED('Invalid Wip Accounting Class Code.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Class_Code=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Class_Code);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
			END IF;

			-- Validate Tagging Required Flag
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Tagging_Required_Flag IS NOT NULL AND
				l_act_assoc_tbl(l_act_assoc_tbl_index).Tagging_Required_Flag <> 'Y' AND
				l_act_assoc_tbl(l_act_assoc_tbl_index).Tagging_Required_Flag <> 'N'
			THEN
				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_TAG_REQ_FLAG');
--				FND_MESSAGE.SET_ENCODED('Tagging Required Flag should be either Y, N, or NULL.');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'Tagging_Required_Flag=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Tagging_Required_Flag);
				end if;

				l_failed := TRUE;
				GOTO next_in_loop;
			END IF;

			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type IS NULL or
				l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id IS NULL
			THEN
				-- Find Maintenance_Object_Id and Maintenance_Object_Type
				-- Validate Asset Number, or Inventory_Item_Id + Serial_Number
				EAM_ActivityUtilities_PVT.Validate_Asset_Number(
					p_instance_number => l_act_assoc_tbl(l_act_assoc_tbl_index).Instance_number,
					p_organization_id => l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_id,
					p_inventory_item_id => l_act_assoc_tbl(l_act_assoc_tbl_index).Inventory_Item_Id,
					p_serial_number	=> l_act_assoc_tbl(l_act_assoc_tbl_index).Serial_Number,

					x_return_status	=> l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status,
					x_error_mesg	=> l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg,

					x_maintenance_object_id => l_maintenance_object_id,
					x_maintenance_object_type => l_maintenance_object_type
				);

				l_act_assoc_tbl(l_act_assoc_tbl_index).maintenance_object_id := l_maintenance_object_id;
				l_act_assoc_tbl(l_act_assoc_tbl_index).maintenance_object_type := l_maintenance_object_type;

				IF l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status <> FND_API.G_RET_STS_SUCCESS THEN

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'Failed Validate Serial Number: Instance_number, or Inventory_Item_Id + Serial_Number'
						|| 'Return_Status=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status ||
						'; Error_Mesg=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg
						|| 'Instance_number=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Instance_number ||
						'; Inventory_Item_Id=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Inventory_Item_Id ||
						'; Serial_Number=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Serial_Number);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
			END IF;

                        -- Validate Maintenance Object Type
			-- Can only be 3 or 2.
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type NOT IN (3, 2)
			THEN
				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_MAINT_OBJ_TYPE');
--				FND_MESSAGE.SET_ENCODED('Maintenance Object Type should be 1 or 2.');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'Maintenance_Object_Type=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type);
				end if;

				l_failed := TRUE;
				GOTO next_in_loop;
			END IF;

                        -- Validate Maintenance Object Id
                        IF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type = 3
                        THEN
                                -- type = 3, id is cii.instance_id
                                SELECT count(cii.instance_id) into l_count
                                FROM   csi_item_instances cii, mtl_system_items_b msi, mtl_parameters mp
                                WHERE  cii.instance_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id
                                  AND  mp.organization_id = cii.last_vld_organization_id
                                  AND  mp.maint_organization_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id
                                  AND  cii.last_vld_organization_id = msi.organization_id
                                  AND  cii.inventory_item_id = msi.inventory_item_id
                                  AND  msi.eam_item_type in (1,3)
                                  AND  msi.serial_number_control_code <> 1
                                  AND  nvl(cii.active_start_date, sysdate-1) <= sysdate
                                  AND  nvl(cii.active_end_date, sysdate+1) >= sysdate;

                                IF l_count <> 1 THEN
                                        l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
                                        FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVLD_MT_GEN_OBJ_ID');
--						FND_MESSAGE.SET_ENCODED('Maintenance Object Id should be a valid gen_object_id.');
                                        l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
                	                                'Maintenance_Object_Id=' ||
                                                        l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id);
					end if;

                                        l_failed := TRUE;
                                        GOTO next_in_loop;
                                END IF;

                        ELSIF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type = 2
                        THEN
                                -- type = 2
                                SELECT count(inventory_item_id) into l_count
                                FROM   mtl_system_items_b msi, mtl_parameters mp
                                WHERE  msi.inventory_item_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id
                                  AND  mp.maint_organization_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id
                                  AND  mp.organization_id = msi.organization_id
                                  AND  msi.eam_item_type in (1,3);

                                IF l_count < 1 THEN
                                        l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
                                        FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVLD_MT_ITM_OBJ_ID');
--						FND_MESSAGE.SET_ENCODED('Maintenance Object Id should be a valid inventory_item_id.');
                                        l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
                	                                'Maintenance_Object_Id=' ||
                                                        l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id);
					end if;

                                        l_failed := TRUE;
                                        GOTO next_in_loop;
                                END IF;
                        ELSE
                                -- Shouldn't be here
                                l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
                                	'Maintenance_Object_Type is neither 1 nor 2');
				end if;

                                l_failed := TRUE;
                                GOTO next_in_loop;
                        END IF;


			-- Validate Tmpl_Flag, can only be NULL, Y, N.
			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag IS NOT NULL
			THEN
				IF l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag NOT IN ('Y', 'N')
				THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_TMPL_FLAG');
--					FND_MESSAGE.SET_ENCODED('Tmpl Flag should be Y, N, or NULL.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Tmpl_Flag=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
				END IF;
                        ELSE
                                l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag := 'N';
			END IF;


			IF l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag = 'Y' THEN
                		IF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type <> 2 THEN
					l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_IAA_INV_TEML_FLAG');
--					FND_MESSAGE.SET_ENCODED(' Invalid Template flag value.');
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							'Tmpl_Flag=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag);
					end if;

					l_failed := TRUE;
					GOTO next_in_loop;
                                ELSE
                                        SELECT serial_number_control_code into l_count
					FROM   mtl_system_items_b msi
					WHERE  msi.inventory_item_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id
                                          AND  rownum = 1;

                                        IF l_count = 1 THEN
                                                l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
                                                FND_MESSAGE.SET_NAME('EAM', 'EAM_NON_SERIAL_REBUILD_ASSOC');
        --					FND_MESSAGE.SET_ENCODED('Cannot assoicate Non-Serialized Rebuildables to Templates.');
                                                l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

						if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
								'Tmpl_Flag=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag);
						end if;

                                                l_failed := TRUE;
                                                GOTO next_in_loop;
                                        END IF;

				END IF;
                        ELSE
                                IF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type = 2 THEN
                                        SELECT serial_number_control_code into l_count
					FROM   mtl_system_items_b msi
					WHERE  msi.inventory_item_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id
                                          AND  rownum = 1;

                                        IF l_count <> 1 THEN
                                                l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
                                                FND_MESSAGE.SET_NAME('EAM', 'EAM_IAA_INV_TEML_FLAG');
        --					FND_MESSAGE.SET_ENCODED(' Invalid Template flag value.');
                                                l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

						if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
							l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
								'Tmpl_Flag=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag);
						end if;

                                                l_failed := TRUE;
                                                GOTO next_in_loop;
                                        END IF;
                                END IF;
			END IF;

			-- Check Unique
			select count(1) into l_count
			from mtl_eam_asset_activities
			where asset_activity_id = l_act_assoc_tbl(l_act_assoc_tbl_index).Asset_Activity_Id
			and maintenance_object_id = l_act_assoc_tbl(l_act_assoc_tbl_index).maintenance_object_id
			and maintenance_object_type = l_act_assoc_tbl(l_act_assoc_tbl_index).maintenance_object_type;
/*
			and ( -- condition for detecting overlapping dates
               			    (    (end_date_active >= l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active
                 		          or end_date_active IS NULL)
           		  	    and (start_date_active < l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active
               		          	 or l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active IS NULL
                     			 or start_date_active IS NULL)
                 		  )

             		 or   (    (end_date_active > l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active
                      		    or l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active IS NULL
               		            or end_date_active IS NULL)
              		      and (start_date_active <= l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active
              		           or start_date_active IS NULL)
            		       )

          		 or   (    (start_date_active <= l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active
           		             or start_date_active IS NULL)
               		       and (end_date_active >= l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active
               		            or end_date_active IS NULL)
                 		   )
			    );
*/

			if l_count >= 1 then
				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				fnd_message.set_name('EAM','EAM_DUPLICATE_ASSET_ACTIVITIES');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;


				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);

					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'l_count=' || l_count);
				end if;

				l_failed := TRUE;
				GOTO next_in_loop;
			end if;


			-- ----------------------------------------------------------------------
			-- Insert into database table

		BEGIN
			-- Get activity_association_id from sequence
			SELECT 	mtl_eam_asset_activities_s.nextval
			INTO 	l_act_assoc_tbl(l_act_assoc_tbl_index).activity_association_id
			FROM	dual;
		EXCEPTION
			WHEN OTHERS THEN

				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_ASSOC_ID');
--				FND_MESSAGE.SET_ENCODED('Error creating Activity_Association_Id.');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);
				end if;

				l_failed := TRUE;
				GOTO next_in_loop;
		END;

		BEGIN
			-- Insert into Database Table mtl_eam_asset_activities
			INSERT	INTO mtl_eam_asset_activities (
				Asset_Activity_Id,
				Start_Date_Active,
				End_Date_Active,
				Priority_Code,
				Last_Update_Date,
				Last_Updated_By,
				Creation_Date,
				Created_By,
				Last_Update_Login,
				Attribute_Category,
				Attribute1,
				Attribute2,
				Attribute3,
				Attribute4,
				Attribute5,
				Attribute6,
				Attribute7,
				Attribute8,
				Attribute9,
				Attribute10,
				Attribute11,
				Attribute12,
				Attribute13,
				Attribute14,
				Attribute15,
				Activity_Association_Id,
				Maintenance_Object_Id,
				Maintenance_Object_Type,
				Tmpl_Flag
			) VALUES (
				l_act_assoc_tbl(l_act_assoc_tbl_index).Asset_Activity_Id,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Start_Date_Active,
				l_act_assoc_tbl(l_act_assoc_tbl_index).End_Date_Active,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Priority_Code,
				l_current_date,
				FND_GLOBAL.USER_ID,
				l_current_date,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.LOGIN_ID,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute_Category,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute1,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute2,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute3,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute4,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute5,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute6,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute7,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute8,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute9,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute10,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute11,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute12,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute13,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute14,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Attribute15,
				l_act_assoc_tbl(l_act_assoc_tbl_index).activity_association_id,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Id,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type,
				l_act_assoc_tbl(l_act_assoc_tbl_index).Tmpl_Flag
			);


		EXCEPTION
			WHEN OTHERS THEN

				l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INSERT_ASSOC');
--				FND_MESSAGE.SET_ENCODED('Error inserting Activity Association record.');
				l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);
				end if;

				l_failed := TRUE;
				GOTO next_in_loop;

		END;

		IF l_act_assoc_tbl(l_act_assoc_tbl_index).Maintenance_Object_Type = 2 THEN
		   l_object_type := 40;
		ELSE
		   l_object_type := 60;
		END IF;

                eam_org_maint_defaults_pvt.insert_row
                (
                      p_api_version           => 1.0
                     ,p_object_type           => l_object_type
                     ,p_object_id             => l_act_assoc_tbl(l_act_assoc_tbl_index).activity_association_id
                     ,p_organization_id       => l_act_assoc_tbl(l_act_assoc_tbl_index).Organization_Id
                     ,p_owning_department_id  => l_act_assoc_tbl(l_act_assoc_tbl_index).Owning_Department_Id
                     ,p_accounting_class_code => l_act_assoc_tbl(l_act_assoc_tbl_index).Class_Code
                     ,p_area_id               => null
                     ,p_activity_cause_code   => l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Cause_Code
                     ,p_activity_type_code    => l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Type_Code
                     ,p_activity_source_code  => l_act_assoc_tbl(l_act_assoc_tbl_index).Activity_Source_Code
                     ,p_shutdown_type_code    => l_act_assoc_tbl(l_act_assoc_tbl_index).Shutdown_Type_Code
                     ,p_tagging_required_flag => l_act_assoc_tbl(l_act_assoc_tbl_index).Tagging_Required_Flag
                     ,x_return_status         => l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status
                     ,x_msg_count             => x_msg_count
                     ,x_msg_data              => l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg
                );


         	IF l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status <> FND_API.G_RET_STS_SUCCESS THEN

			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'Failed during insert in EOMD' ||
				'Return_Status=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status ||
				'; Error_Mesg=' || l_act_assoc_tbl(l_act_assoc_tbl_index).Error_Mesg);
			end if;

			l_failed := TRUE;
			GOTO next_in_loop;
		END IF;

		-- ----------------------------------------------------------------------
		-- If reach here, successful
		l_act_assoc_tbl(l_act_assoc_tbl_index).Return_Status := FND_API.G_RET_STS_SUCCESS;


		<<next_in_loop>>
		l_act_assoc_tbl_index := l_act_assoc_tbl.NEXT(l_act_assoc_tbl_index);
	END LOOP;

	-- Assign outputs
	x_activity_association_tbl := l_act_assoc_tbl;
	IF l_failed THEN
		l_x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE
		l_x_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_x_return_status=' || l_x_return_status ||
		'========== Exiting EAM_ActivityAssociation_PVT.Create_AssetNumberAssoc ==========');
	end if;

	x_return_status := l_x_return_status;

	-- ============================================================

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
	x_msg_data := substr(x_msg_data,1,4000);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_AssetNumberAssoc_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_AssetNumberAssoc_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN OTHERS THEN
		ROLLBACK TO Create_AssetNumberAssoc_PVT;
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
		x_msg_data := substr(x_msg_data,1,4000);
END Create_AssetNumberAssoc;


-- ======================================================================

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
	p_maintenance_object_type	IN	NUMBER, -- only supports type 3 (serial numbers) for now
	-- output for activity association
	x_activity_association_id_tbl	OUT	NOCOPY EAM_ObjectInstantiation_PUB.Association_Id_Tbl_Type

	,p_class_code			IN VARCHAR2
	,p_owning_department_id		IN NUMBER
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'Inst_Activity_Template';
l_api_version           	CONSTANT NUMBER 	:= 1.0;

l_current_date			CONSTANT DATE := sysdate;
l_date_insert                   DATE;
l_next_association_id		NUMBER;
l_next_row			BINARY_INTEGER;
l_activity_association_id_tbl	EAM_ObjectInstantiation_PUB.Association_Id_Tbl_Type;

l_inventory_item_id		NUMBER;
l_organization_id	NUMBER;

l_class_code			VARCHAR2(10);
l_owning_department_id		NUMBER;

--log variables
l_module            varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
l_count number;
CURSOR asset_activity_cur(
	p_maintenance_object_id		IN	NUMBER,
	p_organization_id		IN	NUMBER
)
IS
   SELECT meaa.Asset_Activity_Id, meaa.start_date_active, meaa.end_date_active,
          meaa.Priority_Code, meaa.Attribute_Category, meaa.Attribute1, meaa.Attribute2,
          meaa.Attribute3, meaa.Attribute4, meaa.Attribute5, meaa.Attribute6, meaa.Attribute7,
          meaa.Attribute8, meaa.Attribute9, meaa.Attribute10, meaa.Attribute11, meaa.Attribute12,
          meaa.Attribute13, meaa.Attribute14, meaa.Attribute15, meaa.Prev_Service_Start_Date,
          meaa.Prev_Service_End_Date, meaa.Last_Scheduled_Start_Date, meaa.Last_Scheduled_End_Date,
          meaa.Prev_Scheduled_Start_Date, meaa.Prev_Scheduled_End_Date,
          meaa.Activity_Association_Id, eomd.organization_id, eomd.accounting_class_code, eomd.owning_department_id,
          eomd.Activity_Cause_Code, eomd.Activity_Type_Code, eomd.Activity_Source_Code,
          eomd.Tagging_Required_Flag, eomd.Shutdown_Type_Code
   FROM	  mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
   WHERE  maintenance_object_id = p_maintenance_object_id AND maintenance_object_type = 2
     AND  tmpl_flag = 'Y' AND meaa.Activity_Association_Id = eomd.object_id(+) AND eomd.object_type(+) = 40
     AND  eomd.organization_id(+) = p_organization_id;
-- 2735563: Simply pick up ALL templates and copy the start and end dates to the association records
/*
	AND	(	(start_date_active IS NULL OR
			start_date_active <= l_current_date)
		AND	(end_date_active IS NULL OR
			end_date_active > l_current_date))
*/

BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	l_date_insert := l_current_date;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_ActivityAssociation_PVT.Inst_Activity_Template ===================='
		|| 'p_maintenance_object_id=' || p_maintenance_object_id
		|| 'p_maintenance_object_type=' || p_maintenance_object_type);
	end if;

    	-- Standard Start of API savepoint
    	SAVEPOINT	Inst_Activity_Template_PVT;

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


	-- maintenance object type should be 3
	IF p_maintenance_object_type <> 3 THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_MAINT_OBJ_TYPE');
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- I: Find out the inventory_item_id
	BEGIN
		SELECT cii.inventory_item_id, mp.maint_organization_id
		INTO   l_inventory_item_id, l_organization_id
		FROM   csi_item_instances cii, mtl_parameters mp
		WHERE  cii.instance_id = p_maintenance_object_id
                  AND  mp.organization_id = cii.last_vld_organization_id ;
	EXCEPTION
		WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVLD_MT_GEN_OBJ_ID');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	END;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_inventory_item_id=' || l_inventory_item_id);
	end if;

	-- II: Pick out the templates defined for this item
	FOR l_asset_activity_row IN asset_activity_cur(l_inventory_item_id, l_organization_id)
	LOOP
		-- 1: Get activity_association_id from sequence
		BEGIN
			-- Get activity_association_id from sequence
			SELECT 	mtl_eam_asset_activities_s.nextval
			INTO 	l_next_association_id
			FROM	dual;
		EXCEPTION
			WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ACT_ASSOC_ID');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END;

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'l_next_association_id=' || l_next_association_id);
		end if;

		--Bug 5137572
		Begin
  	         l_date_insert := l_current_date;
 		 SELECT COUNT(1)  INTO l_count FROM eam_pm_schedulings eps, eam_pm_activities epa
			WHERE epa.activity_association_id = l_asset_activity_row.activity_association_id
			 AND epa.pm_schedule_id = eps.pm_schedule_id
			 AND nvl(eps.tmpl_flag,   'N') = 'Y'  AND eps.auto_instantiation_flag = 'Y';
		  if ( l_count = 0 ) then
		      l_date_insert := null;
		  end if;
		Exception
		 When others then
    		      l_date_insert := null;
	        End;

		-- BUG 3683229: Default Owning Dept and Class Code from asset number
		--  if present, else default from template
		l_class_code := nvl(p_class_code,l_asset_activity_row.accounting_class_code);
		l_owning_department_id := nvl(p_owning_department_id,l_asset_activity_row.Owning_Department_Id);

		-- 2: Insert row into mtl_eam_asset_activities
		BEGIN
			-- Insert into Database Table mtl_eam_asset_activities
			INSERT	INTO mtl_eam_asset_activities (
				Asset_Activity_Id,
				Start_Date_Active,
				End_Date_Active,
				Priority_Code,
				Last_Update_Date,
				Last_Updated_By,
				Creation_Date,
				Created_By,
				Last_Update_Login,
				Attribute_Category,
				Attribute1,
				Attribute2,
				Attribute3,
				Attribute4,
				Attribute5,
				Attribute6,
				Attribute7,
				Attribute8,
				Attribute9,
				Attribute10,
				Attribute11,
				Attribute12,
				Attribute13,
				Attribute14,
				Attribute15,
				Activity_Association_Id,
				Last_Service_Start_Date,
				Last_Service_End_Date,
				Prev_Service_Start_Date,
				Prev_Service_End_Date,
				Last_Scheduled_Start_Date,
				Last_Scheduled_End_Date,
				Prev_Scheduled_Start_Date,
				Prev_Scheduled_End_Date,
				Maintenance_Object_Id,
				Maintenance_Object_type,
				Tmpl_Flag,
				Source_Tmpl_Id
			) VALUES (
				l_asset_activity_row.Asset_Activity_Id,
-- 2735563: Simply pick up ALL templates and copy the start and end dates to the association records
				l_asset_activity_row.start_date_active,
				l_asset_activity_row.end_date_active,
				l_asset_activity_row.Priority_Code,
				l_current_date,
				FND_GLOBAL.USER_ID,
				l_current_date,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.LOGIN_ID,
				l_asset_activity_row.Attribute_Category,
				l_asset_activity_row.Attribute1,
				l_asset_activity_row.Attribute2,
				l_asset_activity_row.Attribute3,
				l_asset_activity_row.Attribute4,
				l_asset_activity_row.Attribute5,
				l_asset_activity_row.Attribute6,
				l_asset_activity_row.Attribute7,
				l_asset_activity_row.Attribute8,
				l_asset_activity_row.Attribute9,
				l_asset_activity_row.Attribute10,
				l_asset_activity_row.Attribute11,
				l_asset_activity_row.Attribute12,
				l_asset_activity_row.Attribute13,
				l_asset_activity_row.Attribute14,
				l_asset_activity_row.Attribute15,
				l_next_association_id,
				l_date_insert,
				l_date_insert,
				l_asset_activity_row.Prev_Service_Start_Date,
				l_asset_activity_row.Prev_Service_End_Date,
				l_date_insert,
				l_date_insert,
				l_asset_activity_row.Prev_Scheduled_Start_Date,
				l_asset_activity_row.Prev_Scheduled_End_Date,
				p_maintenance_object_id,
				p_maintenance_object_type,
				'N',
				l_asset_activity_row.Activity_Association_Id
			);
		EXCEPTION
			WHEN OTHERS THEN
				IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INSERT_ASSOC');
					FND_MSG_PUB.ADD;
				END IF;
			RAISE FND_API.G_EXC_ERROR;
		END;

                IF l_asset_activity_row.organization_id IS NOT NULL THEN

                        eam_org_maint_defaults_pvt.insert_row
                        (
                              p_api_version           => 1.0
                             ,p_object_type           => 60
                             ,p_object_id             => l_next_association_id
                             ,p_organization_id       => l_asset_activity_row.Organization_Id
                             ,p_owning_department_id  => l_owning_department_id
                             ,p_accounting_class_code => l_class_code
                             ,p_area_id               => null
                             ,p_activity_cause_code   => l_asset_activity_row.Activity_Cause_Code
                             ,p_activity_type_code    => l_asset_activity_row.Activity_Type_Code
                             ,p_activity_source_code  => l_asset_activity_row.Activity_Source_Code
                             ,p_shutdown_type_code    => l_asset_activity_row.Shutdown_Type_Code
                             ,p_tagging_required_flag => l_asset_activity_row.Tagging_Required_Flag
                             ,x_return_status         => x_return_status
                             ,x_msg_count             => x_msg_count
                             ,x_msg_data              => x_msg_data
                        );
                END IF;

         	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- 3: Record outputs
		l_next_row := NVL(l_activity_association_id_tbl.LAST, 0) + 1;
		l_activity_association_id_tbl(l_next_row) := l_next_association_id;

	END LOOP;

	-- 4: Assign outputs
	x_activity_association_id_tbl := l_activity_association_id_tbl;


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

	x_msg_data := substr(x_msg_data,1,4000);

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_ActivityAssociation_PVT.Inst_Activity_Template ====================');
	end if;



EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Inst_Activity_Template_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Inst_Activity_Template_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN OTHERS THEN
		ROLLBACK TO Inst_Activity_Template_PVT;
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

		x_msg_data := substr(x_msg_data,1,4000);
END;


END EAM_ActivityAssociation_PVT;

/

--------------------------------------------------------
--  DDL for Package Body EAM_ACTIVITYUTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ACTIVITYUTILITIES_PVT" AS
/* $Header: EAMVAAUB.pls 120.3 2005/09/01 01:43:51 kmurthy noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ActivityUtilities_PVT';

-- ======================================================================
-- Utility Procedures
PROCEDURE Validate_Organization
(	p_organization_id		IN	NUMBER,
	p_organization_code		IN	VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_organization_id		OUT NOCOPY	NUMBER,
	x_organization_code		OUT NOCOPY	VARCHAR2
)

IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'Validate_Organization';
l_module         varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'----- Entering EAM_ActivityUtilities_PVT.Validate_Organization -----'
		|| 'p_organization_id=' || p_organization_id
		|| 'p_organization_code=' || p_organization_code);
	end if;

	-- transfer input data to output data
	x_organization_id := p_organization_id;
	x_organization_code := p_organization_code;

	IF p_organization_id IS NOT NULL AND p_organization_id <> FND_API.G_MISS_NUM THEN
		-- organization_id takes precedence
		BEGIN
			SELECT 	organization_code INTO x_organization_code
			FROM 	mtl_parameters
			WHERE 	organization_id = p_organization_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ORG_ID');
--				FND_MESSAGE.SET_ENCODED('Organization Id invalid.');
				EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
				RAISE FND_API.G_EXC_ERROR;
		END;

	ELSIF p_organization_code IS NOT NULL AND p_organization_code <> FND_API.G_MISS_CHAR THEN

		BEGIN
			SELECT	organization_id INTO x_organization_id
			FROM	mtl_parameters
			WHERE	organization_code = p_organization_code;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ORG_CODE');
--				FND_MESSAGE.SET_ENCODED('Organization Code invalid.');
				EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
				RAISE FND_API.G_EXC_ERROR;
		END;
	ELSE
		-- Error: both organization id and code are NULL
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ORG_ID_CODE_NULL');
--		FND_MESSAGE.SET_ENCODED('Organization id and organization code cannot be both NULL.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'----- Exiting EAM_ActivityUtilities_PVT.Validate_Organization -----');
	end if;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Validate_Organization: error.' ||
			'p_organization_id=' || p_organization_id ||
			'; p_organization_code=' || p_organization_code);
		end if;

		x_return_status := FND_API.G_RET_STS_ERROR;

	WHEN OTHERS THEN

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Validate_Organization: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
			'; p_organization_code=' || p_organization_code);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
PROCEDURE Validate_Work_Order
(
	p_work_order_rec		IN	EAM_Activity_PUB.Work_Order_Rec_Type,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_work_order_rec		OUT NOCOPY	EAM_Activity_PUB.Work_Order_Rec_Type
)

IS

	l_api_name			CONSTANT VARCHAR2(30)	:= 'Validate_Work_Order';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_validate_org_ret_sts		VARCHAR2(1);
	l_x_work_order_rec		EAM_Activity_PUB.Work_Order_Rec_Type;
	l_temp_org_id			NUMBER;
	l_temp_org_code			VARCHAR2(3);

BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'----- Entering EAM_ActivityUtilities_PVT.Validate_Work_Order -----'
		|| 'p_work_order_rec.Organization_Id=' || p_work_order_rec.Organization_Id
		|| 'p_work_order_rec.Organization_Code=' || p_work_order_rec.Organization_Code
		|| 'p_work_order_rec.Wip_Entity_Id=' || p_work_order_rec.Wip_Entity_Id
		|| 'p_work_order_rec.Wip_Entity_Name=' || p_work_order_rec.Wip_Entity_Name);
	end if;

	-- transfer input data to output data
	l_x_work_order_rec := p_work_order_rec;

	IF p_work_order_rec.wip_entity_id IS NOT NULL THEN
		BEGIN
			-- wip_entity_id takes precedence
			SELECT	wip_entity_name,
				organization_id
			INTO 	l_x_work_order_rec.wip_entity_name,
				l_x_work_order_rec.organization_id
			FROM 	wip_entities
			WHERE	wip_entity_id = p_work_order_rec.wip_entity_id;
		EXCEPTION
			WHEN OTHERS THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_WIP_ENTITY_ID');
--				FND_MESSAGE.SET_ENCODED('Wip Entity Id invalid.');
				EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
				RAISE FND_API.G_EXC_ERROR;
		END;

		-- also need to set org code
		Validate_Organization(
			p_organization_id => l_x_work_order_rec.organization_id,
			p_organization_code => p_work_order_rec.organization_code,
			x_return_status => l_validate_org_ret_sts,
			x_organization_id => l_temp_org_id,
			x_organization_code => l_temp_org_code
		);
		l_x_work_order_rec.organization_id := l_temp_org_id;
		l_x_work_order_rec.organization_code := l_temp_org_code;

		IF l_validate_org_ret_sts <> FND_API.G_RET_STS_SUCCESS THEN
			EAM_ActivityUtilities_PVT.Add_Message(
				'EAM_ActivityUtilities_PVT.Validate_Work_Order: wip_entity_id: organization validation failed.');
			RAISE FND_API.G_EXC_ERROR;
		END IF;

	ELSIF p_work_order_rec.wip_entity_name IS NOT NULL THEN
		-- For wip_entity_name, need to validate org first
		Validate_Organization(
			p_organization_id => p_work_order_rec.organization_id,
			p_organization_code => p_work_order_rec.organization_code,
			x_return_status => l_validate_org_ret_sts,
			x_organization_id => l_temp_org_id,
			x_organization_code => l_temp_org_code
		);
		l_x_work_order_rec.organization_id := l_temp_org_id;
		l_x_work_order_rec.organization_code := l_temp_org_code;

		IF l_validate_org_ret_sts <> FND_API.G_RET_STS_SUCCESS THEN
			EAM_ActivityUtilities_PVT.Add_Message(
				'EAM_ActivityUtilities_PVT.Validate_Work_Order: wip_entity_name: organization validation failed.');
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		BEGIN
			SELECT 	wip_entity_id INTO l_x_work_order_rec.wip_entity_id
			FROM	wip_entities
			WHERE	organization_id = l_x_work_order_rec.organization_id
			 AND	wip_entity_name = l_x_work_order_rec.wip_entity_name;
		EXCEPTION
			WHEN OTHERS THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_WIP_ENT_NAME');
--				FND_MESSAGE.SET_ENCODED('Wip Entity Name invalid.');
				EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
				RAISE FND_API.G_EXC_ERROR;
		END;

	ELSE
		-- Error: both wip entity id and code are NULL
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_WIP_ENT_ID_NAME_NULL');
--		FND_MESSAGE.SET_ENCODED('Wip Entity Id and Name cannot be both NULL.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Assign output
	x_work_order_rec := l_x_work_order_rec;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'----- Exiting EAM_ActivityUtilities_PVT.Validate_Work_Order -----');
	end if;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Validate_Work_Order: error.'||
			'wip_entity_id=' || p_work_order_rec.wip_entity_id ||
			'; wip_entity_name=' || p_work_order_rec.wip_entity_name ||
			'; organization_id=' || p_work_order_rec.organization_id ||
			'; organization_code=' || p_work_order_rec.organization_code);
		end if;

		x_return_status := FND_API.G_RET_STS_ERROR;

	WHEN OTHERS THEN

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Validate_Work_Order: unexpected error.'||
			'wip_entity_id=' || p_work_order_rec.wip_entity_id ||
			'; wip_entity_name=' || p_work_order_rec.wip_entity_name ||
			'; organization_id=' || p_work_order_rec.organization_id ||
			'; organization_code=' || p_work_order_rec.organization_code);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Item_Concatenated_Segments(
	p_organization_id	IN	NUMBER,
	p_inventory_item_id	IN	NUMBER
)
RETURN VARCHAR2
IS

	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Item_Concatenated_Segments';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_item_concatenated_segments	VARCHAR2(40);
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	IF p_organization_id IS NULL OR p_inventory_item_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT 	concatenated_segments INTO l_item_concatenated_segments
		FROM	MTL_SYSTEM_ITEMS_B_KFV
		WHERE	organization_id = p_organization_id
		 AND	inventory_item_id = p_inventory_item_id;

		RETURN l_item_concatenated_segments;
	END IF;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_NO_ITEM_NAME');
--		FND_MESSAGE.SET_ENCODED('Cannot find concatenated segment Item name.');
		EAM_ActivityUtilities_PVT.Add_Message(FND_MSG_PUB.G_MSG_LVL_ERROR);

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Item_Concatenated_Segments: error.' ||
			'p_organization_id=' || p_organization_id ||
			'; p_inventory_item_id=' || p_inventory_item_id);
		end if;

		RAISE FND_API.G_EXC_ERROR;

	WHEN OTHERS THEN

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Item_Concatenated_Segments: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
			'; p_inventory_item_id=' || p_inventory_item_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Act_Id_From_Work_Order(
	p_wip_entity_id		IN	NUMBER
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Act_Id_From_Work_Order';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_activity_id 	NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	IF p_wip_entity_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT	primary_item_id INTO l_activity_id
		FROM	wip_discrete_jobs
		WHERE	wip_entity_id = p_wip_entity_id;

		RETURN l_activity_id;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Act_Id_From_Work_Order: unexpected error.'||
			'p_wip_entity_id=' || p_wip_entity_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Org_Id_From_Work_Order(
	p_wip_entity_id		IN	NUMBER
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Org_Id_From_Work_Order';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_org_id 	NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	IF p_wip_entity_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT	organization_id INTO l_org_id
		FROM	wip_discrete_jobs
		WHERE	wip_entity_id = p_wip_entity_id;

		RETURN l_org_id;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Org_Id_From_Work_Order: unexpected error.'||
			'p_wip_entity_id=' || p_wip_entity_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Department_Code(
	p_organization_id	IN	NUMBER,
	p_department_id		IN	NUMBER
)
RETURN VARCHAR2
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Department_Code';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_department_code	VARCHAR2(10);
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_department_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT 	department_code INTO l_department_code
		FROM 	bom_departments
		WHERE	organization_id = p_organization_id
		and	department_id = p_department_id
		and 	(disable_date IS NULL
			or disable_date > sysdate);

		RETURN l_department_code;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Department_Code: unexpected error.'||
			'p_organization_id=' || p_organization_id ||
			'; p_department_id=' || p_department_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Resource_Code(
	p_organization_id	IN	NUMBER,
	p_resource_id		IN	NUMBER
)
RETURN VARCHAR2
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Resource_Code';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_resource_code		VARCHAR2(10);
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_resource_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT 	resource_code INTO l_resource_code
		FROM	bom_resources
		WHERE	organization_id = p_organization_id
		and	resource_id = p_resource_id
		and 	(disable_date IS NULL
			or disable_date > sysdate);

		RETURN l_resource_code;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Resource_Code: unexpected error.'||
			'p_organization_id=' || p_organization_id ||
			'; p_resource_id=' || p_resource_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Expense_Account_Id(
	p_organization_id	IN	NUMBER
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Expense_Account_Id';
	l_module            varchar2(200) ;
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_expense_account_id		NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT	expense_account INTO l_expense_account_id
		FROM	mtl_parameters
		WHERE	organization_id = p_organization_id;

		RETURN l_expense_account_id;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Expense_Account_Id: unexpected error.'||
			'p_organization_id=' || p_organization_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
PROCEDURE Get_Asset_From_WO(
	p_wip_entity_id		IN	NUMBER,
	x_inventory_item_id	OUT NOCOPY	NUMBER,
	x_serial_number		OUT NOCOPY	VARCHAR2
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Asset_From_WO';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_wip_entity_id IS NULL THEN
		x_inventory_item_id := NULL;
		x_serial_number := NULL;
		RETURN;
	ELSE
		SELECT 	asset_group_id, asset_number
		INTO 	x_inventory_item_id, x_serial_number
		FROM	wip_discrete_jobs
		WHERE	wip_entity_id = p_wip_entity_id;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Asset_From_WO: unexpected error.'||
			'p_wip_entity_id=' || p_wip_entity_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Asset_Owning_Dept_Id(
	p_organization_id	IN	NUMBER,
	p_inventory_item_id	IN	NUMBER,
	p_serial_number		IN	VARCHAR2
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Asset_Owning_Dept_Id';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_owning_dept_id	NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_inventory_item_id IS NULL OR p_serial_number IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT	owning_department_id INTO l_owning_dept_id
		FROM	mtl_serial_numbers
		WHERE	current_organization_id = p_organization_id
		AND	inventory_item_id = p_inventory_item_id
		AND	serial_number = p_serial_number;

		RETURN l_owning_dept_id;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Asset_Owning_Dept_Id: unexpected error.'||
			'p_organization_id=' || p_organization_id ||
			'; p_inventory_item_id=' || p_inventory_item_id ||
			'; p_serial_number=' || p_serial_number);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_WO_Res_Scheduled_Units(
	p_organization_id 	IN NUMBER,
	p_wip_entity_id		IN NUMBER,
	p_operation_seq_num	IN NUMBER,
	p_resource_seq_num	IN NUMBER
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_WO_Res_Scheduled_Units';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_scheduled_units	NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_wip_entity_id IS NULL OR
		p_operation_seq_num IS NULL OR p_resource_seq_num IS NULL
	THEN
		RETURN NULL;
	ELSE
		SELECT	scheduled_units INTO l_scheduled_units
		FROM	wip_operation_resources_v
		WHERE	organization_id = p_organization_id
		AND	wip_entity_id = p_wip_entity_id
		AND	operation_seq_num = p_operation_seq_num
		AND	resource_seq_num = p_resource_seq_num;

		RETURN l_scheduled_units;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_WO_Res_Scheduled_Units: unexpected error.'||
			'p_organization_id=' || p_organization_id ||
			'; p_wip_entity_id=' || p_wip_entity_id ||
			'; p_operation_seq_num=' || p_operation_seq_num ||
			'; p_resource_seq_num=' || p_resource_seq_num);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Master_Org_Id(
	p_organization_id	IN NUMBER
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Master_Org_Id';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_master_org_id		NUMBER;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT 	master_organization_id INTO l_master_org_id
		FROM	mtl_parameters
		WHERE	organization_id = p_organization_id;

		RETURN l_master_org_id;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Master_Org_Id: unexpected error.'||
			'p_organization_id=' || p_organization_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
PROCEDURE Validate_Asset_Number(
	p_instance_number		IN 	VARCHAR2,
	p_organization_id		IN 	NUMBER,
	p_inventory_item_id		IN 	NUMBER,
	p_serial_number			IN 	VARCHAR2,

	x_return_status			OUT NOCOPY 	VARCHAR2,
	x_error_mesg			OUT NOCOPY	VARCHAR2,

	x_maintenance_object_id		OUT NOCOPY	NUMBER,
	x_maintenance_object_type	OUT NOCOPY	NUMBER
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Validate_Asset_Number';
	l_module           varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_x_org_return_status	VARCHAR2(1);
	l_x_org_id		NUMBER;
	l_x_org_code		VARCHAR2(3);

	l_x_error_mesg		VARCHAR2(20000);

BEGIN

        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	-- Instance number takes precedence
	IF p_instance_number IS NOT NULL THEN
		BEGIN
			SELECT 	instance_id, 3
			INTO	x_maintenance_object_id, x_maintenance_object_type
			FROM	csi_item_instances
			WHERE	instance_number = p_instance_number;
		EXCEPTION
			WHEN OTHERS THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_INSTANCE_NUMBER');
--				FND_MESSAGE.SET_ENCODED('Instance number is invalid.');
				l_x_error_mesg := FND_MESSAGE.GET;

				if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
					l_x_error_mesg ||
					'p_instance_number=' || p_instance_number);
				end if;

				x_error_mesg := l_x_error_mesg;
				RETURN;
		END;
	ELSE
		-- 1) Validate Organization Id
		Validate_Organization(
			p_organization_id,
			NULL,
			l_x_org_return_status,
			l_x_org_id,
			l_x_org_code);
		IF l_x_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ORG_ID');
			l_x_error_mesg := FND_MESSAGE.GET;

			if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				l_x_error_mesg ||
				'p_instance_number=' || p_instance_number ||
				'p_organization_id=' || p_organization_id ||
				'; p_inventory_item_id=' || p_inventory_item_id ||
				'; p_serial_number=' || p_serial_number);

			end if;

			x_error_mesg := l_x_error_mesg;
			RETURN;
		END IF;

		if p_serial_number is not null then

			-- 2) Validate Asset Group and Serial Number
			BEGIN
				SELECT 	instance_id, 3
				INTO	x_maintenance_object_id, x_maintenance_object_type
				FROM	csi_item_instances
				WHERE	inventory_item_id = p_inventory_item_id
				  AND	serial_number = p_serial_number;
			EXCEPTION
				WHEN OTHERS THEN
					x_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_ASSET_GRP_NUM');
	--				FND_MESSAGE.SET_ENCODED('Asset Group, Number invalid.');
					l_x_error_mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_x_error_mesg ||
						'p_instance_number=' || p_instance_number ||
						'p_organization_id=' || p_organization_id ||
						'; p_inventory_item_id=' || p_inventory_item_id ||
						'; p_serial_number=' || p_serial_number);
					end if;

					x_error_mesg := l_x_error_mesg;
					RETURN;
			END;

		else
			-- Serial Number NULL, could be non-serialized rebuild or template
			-- only validate inventory_item_id
			declare
				l_count number;
			begin

				select	count(*) into l_count
				from	mtl_system_items
				where	inventory_item_id = p_inventory_item_id;

				if l_count >= 1 then
					x_maintenance_object_id := p_inventory_item_id;
					x_maintenance_object_type := 2;
				ELSE
					x_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_INV_ITEM_ID');
	--				FND_MESSAGE.SET_ENCODED('Invalid Inventory Item Id.');
					l_x_error_mesg := FND_MESSAGE.GET;

					if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						l_x_error_mesg ||
						'p_instance_number=' || p_instance_number ||
						'p_organization_id=' || p_organization_id ||
						'; p_inventory_item_id=' || p_inventory_item_id ||
						'; p_serial_number=' || p_serial_number);
					end if;

					x_error_mesg := l_x_error_mesg;
					RETURN;
				end if;
			end;
		end if;
	END IF;


	-- If reach here, means data valid
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Cost_Activity(
	p_activity_id		IN	NUMBER
)
RETURN VARCHAR2
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Cost_Activity';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_activity	cst_activities.activity%TYPE;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_activity_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT	activity INTO l_activity
		FROM	cst_activities
		WHERE	activity_id = p_activity_id;

		RETURN l_activity;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Cost_Activity: unexpected error.' ||
			'p_activity_id=' || p_activity_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Locator(
	p_organization_id	IN	NUMBER,
	p_subinventory_code	IN	VARCHAR2,
	p_locator_id		IN	NUMBER
)
RETURN VARCHAR2
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Locator';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_locator	mtl_item_locations_kfv.concatenated_segments%TYPE;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_subinventory_code IS NULL OR p_locator_id IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT	concatenated_segments INTO l_locator
		FROM	mtl_item_locations_kfv
		WHERE	organization_id = p_organization_id
		AND	subinventory_code = p_subinventory_code
		AND	(disable_date > sysdate or disable_date is null)
		AND	inventory_location_id = p_locator_id;

		RETURN l_locator;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Locator: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
			'; p_subinventory_code=' || p_subinventory_code ||
			'; p_locator_id=' || p_locator_id);

		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
PROCEDURE Get_Op_Coordinates(
	p_organization_id	IN	NUMBER,
	p_wip_entity_id		IN	NUMBER,
	p_operation_seq_num	IN	NUMBER,
	x_x_pos			OUT NOCOPY	NUMBER,
	x_y_pos			OUT NOCOPY	NUMBER
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Op_Coordinates';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_wip_entity_id IS NULL OR
		p_operation_seq_num IS NULL
	THEN
		RETURN;
	ELSE
		SELECT 	x_pos, y_pos INTO x_x_pos, x_y_pos
		FROM	wip_operations
		WHERE	organization_id = p_organization_id
		AND	wip_entity_id = p_wip_entity_id
		AND	operation_seq_num = p_operation_seq_num;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Op_Coordinates: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
			'; p_wip_entity_id=' || p_wip_entity_id ||
			'; p_operation_seq_num=' || p_operation_seq_num);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Bom_Sequence_Id(
	p_organization_id		IN	NUMBER,
	p_assembly_item_id		IN	NUMBER,
	p_alternate_bom_designator	IN	VARCHAR2
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Bom_Sequence_Id';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_bom_sequence_id	NUMBER;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_assembly_item_id IS NULL
	THEN
		RETURN NULL;
	ELSE
		SELECT 	bill_sequence_id INTO l_bom_sequence_id
		FROM 	bom_bill_of_materials
		WHERE	organization_id = p_organization_id
		AND	assembly_item_id = p_assembly_item_id
		AND	( (alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL)
 			  OR alternate_bom_designator = p_alternate_bom_designator);
		RETURN 	l_bom_sequence_id;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Bom_Sequence_Id: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
		    	'; p_assembly_item_id=' || p_assembly_item_id ||
			'; p_alternate_bom_designator=' || p_alternate_bom_designator);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Rtg_Sequence_Id(
	p_organization_id		IN	NUMBER,
	p_assembly_item_id		IN	NUMBER,
	p_alternate_rtg_designator	IN	VARCHAR2
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Rtg_Sequence_Id';
	l_module           varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_rtg_sequence_id	NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_assembly_item_id IS NULL
	THEN
		RETURN NULL;
	ELSE
		SELECT 	routing_sequence_id INTO l_rtg_sequence_id
		FROM 	bom_operational_routings
		WHERE	organization_id = p_organization_id
		AND	assembly_item_id = p_assembly_item_id
		AND	( (alternate_routing_designator IS NULL AND p_alternate_rtg_designator IS NULL)
 			  OR alternate_routing_designator = p_alternate_rtg_designator);
		RETURN 	l_rtg_sequence_id;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Bom_Sequence_Id: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
		    	'; p_assembly_item_id=' || p_assembly_item_id ||
			'; p_alternate_rtg_designator=' || p_alternate_rtg_designator);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Get_Gen_Object_Id(
	p_organization_id		IN	NUMBER,
	p_inventory_item_id		IN	NUMBER,
	p_serial_number			IN	VARCHAR2
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Gen_Object_Id';
	l_module         varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_gen_object_id		NUMBER;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_organization_id IS NULL OR p_inventory_item_id IS NULL OR p_serial_number IS NULL
	THEN
		RETURN NULL;
	ELSE
		SELECT	gen_object_id INTO l_gen_object_id
		FROM	mtl_serial_numbers
		WHERE	current_organization_id = p_organization_id
		AND	inventory_item_id = p_inventory_item_id
		AND	serial_number = p_serial_number;

		RETURN l_gen_object_id;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Gen_Object_Id: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
		   	'; p_inventory_item_id=' || p_inventory_item_id ||
			'; p_serial_number=' || p_serial_number);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
PROCEDURE Get_Item_Info_From_WO(
	p_wip_entity_id			IN		NUMBER,
	x_source_org_id			OUT NOCOPY 	NUMBER,
	x_source_activity_id		OUT NOCOPY	NUMBER,
	x_wo_maint_id			OUT NOCOPY	NUMBER,
	x_wo_maint_type			OUT NOCOPY	NUMBER
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Item_Info_From_WO';
	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_organization_id	NUMBER;
	l_primary_item_id	NUMBER;
	l_wo_maint_id		NUMBER;
	l_wo_maint_type		NUMBER;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_wip_entity_id IS NULL THEN
		x_source_org_id := NULL;
		x_source_activity_id := NULL;
		x_wo_maint_id := NULL;
		x_wo_maint_type := NULL;
	ELSE
		SELECT 	organization_id, primary_item_id, maintenance_object_id, maintenance_object_type
		INTO	x_source_org_id, x_source_activity_id, x_wo_maint_id, x_wo_maint_type
		FROM 	wip_discrete_jobs
		WHERE	wip_entity_id = p_wip_entity_id;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Get_Item_Info_From_WO: unexpected error.'||
			'p_wip_entity_id=' || p_wip_entity_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;
-- ----------------------------------------------------------------------
FUNCTION Default_Owning_Department_Id(
	p_activity_association_id	IN	NUMBER,
	p_instance_id			IN	NUMBER,
	p_organization_id		IN	NUMBER
)
RETURN NUMBER
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Default_Owning_Department_Id';
	l_module          varchar2(200) ;
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_owning_department_id		NUMBER;
BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	-- Defaulting logic: first activity association, then from serial number, finally EAM org parameters.
	IF p_activity_association_id IS NOT NULL THEN
		BEGIN
			SELECT owning_department_id
			INTO   l_owning_department_id
			FROM   eam_org_maint_defaults
			WHERE  object_id = p_activity_association_id AND object_type in (40, 60)
			  AND  organization_id = p_organization_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_owning_department_id := NULL;
		END;

		IF l_owning_department_id IS NOT NULL THEN
			RETURN l_owning_department_id;
		END IF;
	END IF;

	IF p_instance_id IS NOT NULL THEN
		BEGIN
			SELECT owning_department_id
			INTO   l_owning_department_id
			FROM   eam_org_maint_defaults
			WHERE  object_id = p_instance_id AND object_type = 50
			  AND  organization_id = p_organization_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_owning_department_id := NULL;
		END;

		IF l_owning_department_id IS NOT NULL THEN
			RETURN l_owning_department_id;
		END IF;
	END IF;

	IF p_organization_id IS NOT NULL THEN
		SELECT	default_department_id
		INTO	l_owning_department_id
		FROM	wip_eam_parameters
		WHERE	organization_id = p_organization_id;

		RETURN l_owning_department_id;
	END IF;

	RETURN NULL;

EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Default_Owning_Department_Id: unexpected error.'||
			'p_activity_association_id=' || p_activity_association_id ||
			'p_instance_id=' || p_instance_id ||
			'p_organization_id=' || p_organization_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
FUNCTION Is_Item_Serialized(
	p_organization_id	IN	NUMBER,
	p_maint_id		IN	NUMBER,
	p_maint_type		IN	NUMBER
)
RETURN BOOLEAN
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Is_Item_Serialized';
	l_module             varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_serial_number_control_code	NUMBER;
BEGIN
       if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	IF p_maint_type = 3 THEN
		RETURN TRUE;
	END IF;
	IF p_organization_id IS NULL OR p_maint_id IS NULL OR
	   p_maint_type IS NULL OR p_maint_type <> 2 THEN
		RETURN NULL;
	ELSE
		SELECT	msi.serial_number_control_code
		INTO	l_serial_number_control_code
		FROM	mtl_system_items msi, mtl_parameters mp
		WHERE	mp.maint_organization_id = p_organization_id
		AND	mp.organization_id = msi.organization_id
		AND	msi.inventory_item_id = p_maint_id
		AND	ROWNUM = 1;

		IF l_serial_number_control_code = 1 THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'EAM_ActivityUtilities_PVT.Is_Item_Serialized: unexpected error.' ||
			'p_organization_id=' || p_organization_id ||
			'p_maint_id=' || p_maint_id);
		end if;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- ----------------------------------------------------------------------
-- For logging
PROCEDURE Open_Debug_Session
IS
BEGIN
	IF Is_Debug = g_YES
	THEN
		Debug_File := utl_file.fopen( Debug_File_Dir,
        	                              Debug_File_Name,
              		                      'w');
		Log_Index := 1;
		utl_file.put_line(Debug_File, 'Created ' || TO_CHAR(sysdate, 'DD MON YYYY HH12:MI:SS AM') ||
					'; Debug_File_Dir=' || Debug_File_Dir ||
					'; Debug_File_Name=' || Debug_File_Name
					);
		utl_file.fflush(Debug_File);
	END IF;

EXCEPTION
	WHEN OTHERS THEN

		Is_Debug := g_NO;

		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CANNOT_CREATE_LOG_FILE');
--			FND_MESSAGE.SET_ENCODED('Cannot create log file.');
			FND_MSG_PUB.ADD;
		END IF;
END;

-- ----------------------------------------------------------------------
PROCEDURE Write_Debug(
	p_debug_message      IN  VARCHAR2
)
IS
BEGIN
	IF Is_Debug = g_YES
	THEN
		IF utl_file.is_open(Debug_File)
		THEN
			utl_file.put_line(Debug_File, '[' || Log_Index || '] ' || p_debug_message);
			utl_file.fflush(Debug_File);
			Log_Index := Log_Index + 1;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Is_Debug := g_NO;

		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ERROR_WRITING_TO_LOG');
--			FND_MESSAGE.SET_ENCODED('Error writing to log file.');
			FND_MSG_PUB.ADD;
		END IF;
END Write_Debug;

-- ----------------------------------------------------------------------
PROCEDURE Close_Debug_Session
IS
BEGIN
	IF Is_Debug = g_YES
	THEN
		IF utl_file.is_open(Debug_File)
		THEN
			utl_file.fclose(Debug_File);
		END IF;
	END IF;
END Close_Debug_Session;

-- ----------------------------------------------------------------------
PROCEDURE Add_Message(
	p_message_level			IN	NUMBER
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Add_Message';
	l_module            varchar2(200) ;
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

	l_message_text		VARCHAR2(20000);

BEGIN
        if(l_ulog) then
		l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	-- add message to fnd message stack
	IF FND_MSG_PUB.Check_Msg_Level(p_message_level)
	THEN
		-- Push message onto fnd message stack
		FND_MSG_PUB.ADD;
		-- Get translated message
		l_message_text := FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST, FND_API.G_FALSE);
	ELSE
		-- Message not pushed onto fnd message stack
		l_message_text := FND_MESSAGE.GET;
	END IF;

	-- Also output message to log file
	if (l_plog) then
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, l_message_text);
	end if;

END;

-- ----------------------------------------------------------------------
PROCEDURE Log_Item_Error_Tbl(
	p_item_error_tbl		IN	INV_Item_GRP.Error_Tbl_Type
)
IS
	l_index			BINARY_INTEGER;
BEGIN
	-- traverse whole table, add error messages to log file
	l_index := p_item_error_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		Write_Debug('Transaction_Id=' || p_item_error_tbl(l_index).transaction_id ||
				'; Unique_id=' || p_item_error_tbl(l_index).unique_id ||
				'; Organization_Id=' || p_item_error_tbl(l_index).organization_id);
		Write_Debug('Table_Name=' || p_item_error_tbl(l_index).table_name ||
				'; Column_Name=' || p_item_error_tbl(l_index).column_name ||
				'; Message_Name=' || p_item_error_tbl(l_index).message_name);
		Write_Debug('Message_Text=' || p_item_error_tbl(l_index).message_text);

		l_index := p_item_error_tbl.NEXT(l_index);
	END LOOP; -- WHILE l_next_index IS NOT NULL
END;

-- ----------------------------------------------------------------------
PROCEDURE Log_Bom_Error_Tbl(
	p_bom_error_tbl			IN	Error_Handler.Error_Tbl_Type
)
IS
	l_index			BINARY_INTEGER;
BEGIN

	Write_Debug('p_bom_error_tbl.COUNT=' || p_bom_error_tbl.COUNT);
	l_index := p_bom_error_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		Write_Debug('organization_id=' || p_bom_error_tbl(l_index).organization_id ||
				'; entity_id=' || p_bom_error_tbl(l_index).entity_id ||
				'; entity_index=' || p_bom_error_tbl(l_index).entity_index ||
				'; message_type=' || p_bom_error_tbl(l_index).message_type ||
				'; bo_identifier=' || p_bom_error_tbl(l_index).bo_identifier);
		Write_Debug('mesg_text=' || p_bom_error_tbl(l_index).message_text);
  		l_index := p_bom_error_tbl.NEXT(l_index);
	END LOOP;

END;

-- ----------------------------------------------------------------------
PROCEDURE Log_Process_Rtg_Parameters(
	p_rtg_header_rec 	IN	BOM_RTG_PUB.Rtg_Header_Rec_Type,
	p_operation_tbl		IN	BOM_RTG_PUB.Operation_Tbl_Type,
	p_op_resource_tbl	IN	BOM_RTG_PUB.Op_Resource_Tbl_Type,
	p_op_network_tbl	IN	BOM_RTG_PUB.Op_Network_Tbl_Type
)
IS
BEGIN
	Write_Debug('%%%%%%%%%% BOM_RTG_PUB.Process_Rtg Parameters %%%%%%%%%%');
	Log_Rtg_Header_Rec(p_rtg_header_rec);
	Log_Rtg_Operation_Tbl(p_operation_tbl);
	Log_Rtg_Op_Resource_Tbl(p_op_resource_tbl);
	Log_Rtg_Op_Network_Tbl(p_op_network_tbl);
	Write_Debug('%%%%%%%%%% End of BOM_RTG_PUB.Process_Rtg Parameters %%%%%%%%%%');
END;

PROCEDURE Log_Rtg_Header_Rec(
	rtg_header_rec	IN	BOM_RTG_PUB.Rtg_Header_Rec_Type
)
IS
BEGIN
	Write_Debug('rtg_header_rec.Assembly_Item_Name=' || rtg_header_rec.Assembly_Item_Name);
	Write_Debug('rtg_header_rec.Organization_Code=' || rtg_header_rec.Organization_Code);
	Write_Debug('rtg_header_rec.Alternate_Routing_Code=' || rtg_header_rec.Alternate_Routing_Code);
	Write_Debug('rtg_header_rec.Transaction_Type=' || rtg_header_rec.Transaction_Type);
	Write_Debug('rtg_header_rec.Return_Status=' || rtg_header_rec.Return_Status);
END;

PROCEDURE Log_Rtg_Operation_Tbl(
	operation_tbl		IN	BOM_RTG_PUB.Operation_Tbl_Type
)
IS
	l_index		BINARY_INTEGER;
BEGIN
	Write_Debug('operation_tbl.COUNT=' || operation_tbl.COUNT);
	l_index := operation_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		Write_Debug('l_index=' || l_index);
		Write_Debug('operation_tbl(l_index).Assembly_Item_Name=' || operation_tbl(l_index).Assembly_Item_Name);
		Write_Debug('operation_tbl(l_index).Organization_Code=' || operation_tbl(l_index).Organization_Code);
		Write_Debug('operation_tbl(l_index).Alternate_Routing_Code=' || operation_tbl(l_index).Alternate_Routing_Code);
		Write_Debug('operation_tbl(l_index).Operation_Sequence_Number=' || operation_tbl(l_index).Operation_Sequence_Number);
		Write_Debug('operation_tbl(l_index).Start_Effective_Date=' || operation_tbl(l_index).Start_Effective_Date);
		Write_Debug('operation_tbl(l_index).Department_Code=' || operation_tbl(l_index).Department_Code);
		Write_Debug('operation_tbl(l_index).Operation_Description=' || operation_tbl(l_index).Operation_Description);
		Write_Debug('operation_tbl(l_index).Transaction_Type=' || operation_tbl(l_index).Transaction_Type);
		Write_Debug('operation_tbl(l_index).Return_Status=' || operation_tbl(l_index).Return_Status);

		l_index := operation_tbl.NEXT(l_index);
	END LOOP;
END;

PROCEDURE Log_Rtg_Op_Resource_Tbl(
	op_resource_tbl	IN	BOM_RTG_PUB.Op_Resource_Tbl_Type
)
IS
	l_index		BINARY_INTEGER;
BEGIN
	Write_Debug('op_resource_tbl.COUNT=' || op_resource_tbl.COUNT);
	l_index := op_resource_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		Write_Debug('l_index=' || l_index);
		Write_Debug('op_resource_tbl(l_index).Assembly_Item_Name=' || op_resource_tbl(l_index).Assembly_Item_Name);
		Write_Debug('op_resource_tbl(l_index).Organization_Code=' || op_resource_tbl(l_index).Organization_Code);
		Write_Debug('op_resource_tbl(l_index).Alternate_Routing_Code=' || op_resource_tbl(l_index).Alternate_Routing_Code);
		Write_Debug('op_resource_tbl(l_index).Operation_Sequence_Number='||op_resource_tbl(l_index).Operation_Sequence_Number);
		Write_Debug('op_resource_tbl(l_index).Op_Start_Effective_Date=' || op_resource_tbl(l_index).Op_Start_Effective_Date);
		Write_Debug('op_resource_tbl(l_index).Resource_Sequence_Number=' || op_resource_tbl(l_index).Resource_Sequence_Number);
		Write_Debug('op_resource_tbl(l_index).Resource_Code=' || op_resource_tbl(l_index).Resource_Code);
		Write_Debug('op_resource_tbl(l_index).Transaction_Type=' || op_resource_tbl(l_index).Transaction_Type);
		Write_Debug('op_resource_tbl(l_index).Return_Status=' || op_resource_tbl(l_index).Return_Status);

		l_index := op_resource_tbl.NEXT(l_index);
	END LOOP;
END;

PROCEDURE Log_Rtg_Op_Network_Tbl(
	op_network_tbl	IN	BOM_RTG_PUB.Op_Network_Tbl_Type
)
IS
	l_index		BINARY_INTEGER;
BEGIN
	Write_Debug('op_network_tbl.COUNT=' || op_network_tbl.COUNT);
	l_index := op_network_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		Write_Debug('l_index=' || l_index);
		Write_Debug('op_network_tbl(l_index).Assembly_Item_Name=' || op_network_tbl(l_index).Assembly_Item_Name);
		Write_Debug('op_network_tbl(l_index).Organization_Code=' || op_network_tbl(l_index).Organization_Code);
		Write_Debug('op_network_tbl(l_index).Alternate_Routing_Code=' || op_network_tbl(l_index).Alternate_Routing_Code);
		Write_Debug('op_network_tbl(l_index).From_Op_Seq_Number='||op_network_tbl(l_index).From_Op_Seq_Number);
		Write_Debug('op_network_tbl(l_index).From_Start_Effective_Date='||op_network_tbl(l_index).From_Start_Effective_Date);
		Write_Debug('op_network_tbl(l_index).To_Op_Seq_Number='||op_network_tbl(l_index).To_Op_Seq_Number);
		Write_Debug('op_network_tbl(l_index).To_Start_Effective_Date='||op_network_tbl(l_index).To_Start_Effective_Date);
		Write_Debug('op_network_tbl(l_index).Transaction_Type=' || op_network_tbl(l_index).Transaction_Type);
		Write_Debug('op_network_tbl(l_index).Return_Status=' || op_network_tbl(l_index).Return_Status);

		l_index := op_network_tbl.NEXT(l_index);
	END LOOP;
END;


PROCEDURE Log_Process_BOM_Parameters(
	p_bom_header_rec	IN 	BOM_BO_PUB.Bom_Head_Rec_Type,
	p_bom_component_tbl	IN	BOM_BO_PUB.Bom_Comps_Tbl_Type
)
IS
BEGIN
	Write_Debug('%%%%%%%%%% BOM_BO_PUB.Process_BOM Parameters %%%%%%%%%%');
	Log_Bom_Header_Rec(p_bom_header_rec);
	Log_Bom_Component_Tbl(p_bom_component_tbl);
	Write_Debug('%%%%%%%%%% End of BOM_RTG_PUB.Process_Rtg Parameters %%%%%%%%%%');
END;

PROCEDURE Log_Bom_Header_Rec(
	bom_header_rec	IN	BOM_BO_PUB.Bom_Head_Rec_Type
)
IS
BEGIN
	Write_Debug('bom_header_rec.Assembly_Item_Name=' || bom_header_rec.Assembly_Item_Name);
	Write_Debug('bom_header_rec.Organization_Code=' || bom_header_rec.Organization_Code);
	Write_Debug('bom_header_rec.Alternate_Bom_Code=' || bom_header_rec.Alternate_Bom_Code);
	Write_Debug('bom_header_rec.Assembly_Type=' || bom_header_rec.Assembly_Type);
	Write_Debug('bom_header_rec.Transaction_Type=' || bom_header_rec.Transaction_Type);
	Write_Debug('bom_header_rec.Return_Status=' || bom_header_rec.Return_Status);
END;

PROCEDURE Log_Bom_Component_Tbl(
	bom_component_tbl	IN	BOM_BO_PUB.Bom_Comps_Tbl_Type
)
IS
	l_index		BINARY_INTEGER;
BEGIN
	Write_Debug('bom_component_tbl.COUNT=' || bom_component_tbl.COUNT);
	l_index := bom_component_tbl.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
		Write_Debug('l_index=' || l_index);
		Write_Debug('bom_component_tbl(l_index).Organization_Code=' || bom_component_tbl(l_index).Organization_Code);
		Write_Debug('bom_component_tbl(l_index).Assembly_Item_Name=' || bom_component_tbl(l_index).Assembly_Item_Name);
		Write_Debug('bom_component_tbl(l_index).Start_Effective_Date=' || bom_component_tbl(l_index).Start_Effective_Date);
		Write_Debug('bom_component_tbl(l_index).Operation_Sequence_Number='||bom_component_tbl(l_index).Operation_Sequence_Number);
		Write_Debug('bom_component_tbl(l_index).Component_Item_Name=' || bom_component_tbl(l_index).Component_Item_Name);
		Write_Debug('bom_component_tbl(l_index).Alternate_BOM_Code=' || bom_component_tbl(l_index).Alternate_BOM_Code);
		Write_Debug('bom_component_tbl(l_index).Item_Sequence_Number=' || bom_component_tbl(l_index).Item_Sequence_Number);
		Write_Debug('bom_component_tbl(l_index).Transaction_Type=' || bom_component_tbl(l_index).Transaction_Type);
		Write_Debug('bom_component_tbl(l_index).Return_Status=' || bom_component_tbl(l_index).Return_Status);

		l_index := bom_component_tbl.NEXT(l_index);
	END LOOP;
END;

PROCEDURE Log_Inv_Item_Rec(
	item_rec	IN	INV_Item_GRP.Item_rec_type
)
IS

BEGIN
	Write_Debug('item_rec.ORGANIZATION_ID=' || item_rec.ORGANIZATION_ID);
	Write_Debug('item_rec.ORGANIZATION_CODE=' || item_rec.ORGANIZATION_CODE);
	Write_Debug('item_rec.INVENTORY_ITEM_ID=' || item_rec.INVENTORY_ITEM_ID);
	Write_Debug('item_rec.ITEM_NUMBER=' || item_rec.ITEM_NUMBER);
	Write_Debug('item_rec.DESCRIPTION=' || item_rec.DESCRIPTION);
	Write_Debug('item_rec.EAM_ITEM_TYPE=' || item_rec.EAM_ITEM_TYPE);

	Write_Debug('item_rec.EAM_ACTIVITY_TYPE_CODE=' || item_rec.EAM_ACTIVITY_TYPE_CODE);
	Write_Debug('item_rec.EAM_ACTIVITY_CAUSE_CODE=' || item_rec.EAM_ACTIVITY_CAUSE_CODE);
	Write_Debug('item_rec.EAM_ACT_NOTIFICATION_FLAG=' || item_rec.EAM_ACT_NOTIFICATION_FLAG);
	Write_Debug('item_rec.EAM_ACT_SHUTDOWN_STATUS=' || item_rec.EAM_ACT_SHUTDOWN_STATUS);
	Write_Debug('item_rec.EAM_ACTIVITY_SOURCE_CODE=' || item_rec.EAM_ACTIVITY_SOURCE_CODE);

	Write_Debug('item_rec.INVENTORY_ITEM_FLAG=' || item_rec.INVENTORY_ITEM_FLAG);
	Write_Debug('item_rec.MTL_TRANSACTIONS_ENABLED_FLAG=' || item_rec.MTL_TRANSACTIONS_ENABLED_FLAG);
	Write_Debug('item_rec.BOM_ENABLED_FLAG=' || item_rec.BOM_ENABLED_FLAG);
	Write_Debug('item_rec.EXPENSE_ACCOUNT=' || item_rec.EXPENSE_ACCOUNT);

END;

-- ----------------------------------------------------------------------
FUNCTION Get_First_N_Messages(
	p_n		IN	NUMBER
)
RETURN VARCHAR2
IS
	l_first_n_messages	VARCHAR2(20000)	:= '';

BEGIN
	FND_MSG_PUB.RESET;
	FOR i IN 1..p_n
	LOOP
		l_first_n_messages := l_first_n_messages || FND_MSG_PUB.GET || ' || ';
	END LOOP;
	RETURN l_first_n_messages;
END;

-- ----------------------------------------------------------------------

-- From Saurabh

-- body in EAM_ACTIVITYUTILITIES_PVT
FUNCTION BOM_Exists(
    p_org_id in number,
    p_inventory_item_id in number
)
return boolean is
    l_count number;
begin
    select count(1) into l_count
    from bom_bill_of_materials
    where assembly_item_id = p_inventory_item_id and
    organization_id = p_org_id;

    if l_count > 0 then
        return true;
    else
        return false;
    end if;
end bom_exists;

FUNCTION Routing_Exists(
    p_org_id in number,
    p_inventory_item_id in number
)
return boolean is
    l_count number;
begin
    select count(1) into l_count
    from bom_operational_routings
    where assembly_item_id = p_inventory_item_id and
    organization_id = p_org_id;

    if l_count > 0 then
        return true;
    else
        return false;
    end if;
end routing_exists;


-- ----------------------------------------------------------------------
FUNCTION IS_ACTIVITY_ASSIGNED(
	p_activity_id	IN	NUMBER,
	p_org_id        IN	NUMBER
)
RETURN BOOLEAN IS
  l_count number;
BEGIN
     SELECT count(inventory_item_id) into l_count FROM mtl_system_items_b
     WHERE organization_id = p_org_id AND inventory_item_id = p_activity_id
       AND eam_item_type = 2;

     IF l_count = 0 THEN
        return FALSE;
     ELSE
        return TRUE;
     END IF;

END IS_ACTIVITY_ASSIGNED;

-- ----------------------------------------------------------------------
-- To be used in Activity WB view
FUNCTION get_next_service_start_date
(
	p_activity_association_id	IN	NUMBER,
	p_maintenance_object_id		IN	NUMBER,
	p_maintenance_object_type	IN	NUMBER
)
RETURN DATE IS
   l_date DATE;
BEGIN
   SELECT epa.next_service_start_date into l_date
     FROM eam_pm_schedulings eps, eam_pm_activities epa
    WHERE eps.maintenance_object_id = p_maintenance_object_id
      AND eps.maintenance_object_type = p_maintenance_object_type
      AND eps.default_implement = 'Y'
      AND eps.pm_schedule_id = epa.pm_schedule_id
      AND epa.activity_association_id = p_activity_association_id;
   return l_date;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     return null;
END get_next_service_start_date;

-- ----------------------------------------------------------------------
-- To be used in Activity WB view
FUNCTION get_next_service_end_date
(
	p_activity_association_id	IN	NUMBER,
	p_maintenance_object_id		IN	NUMBER,
	p_maintenance_object_type	IN	NUMBER
)
RETURN DATE IS
   l_date DATE;
BEGIN
   SELECT epa.next_service_end_date into l_date
     FROM eam_pm_schedulings eps, eam_pm_activities epa
    WHERE eps.maintenance_object_id = p_maintenance_object_id
      AND eps.maintenance_object_type = p_maintenance_object_type
      AND eps.default_implement = 'Y'
      AND eps.pm_schedule_id = epa.pm_schedule_id
      AND epa.activity_association_id = p_activity_association_id;
   return l_date;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     return null;
END get_next_service_end_date;

-- ----------------------------------------------------------------------

-- End of Utility Procedures
-- ======================================================================

END EAM_ActivityUtilities_PVT;

/

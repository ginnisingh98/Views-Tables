--------------------------------------------------------
--  DDL for Package Body EAM_OBJECTINSTANTIATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OBJECTINSTANTIATION_PUB" AS
/* $Header: EAMPMOIB.pls 120.11 2006/06/22 12:36:52 yjhabak noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ObjectInstantiation_PUB';


-- ======================================================================

-- This is a wrapper for Instantiate_Object.
-- It takes current_organization_id, inventory_item_id, serial_number
-- and looks up the Gen_Object_Id before calling Instantiate_Object.

PROCEDURE Instantiate_Serial_Number
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list			IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	-- inputs: specify a Serial Number
	p_current_organization_id	IN	NUMBER,
	p_inventory_item_id		IN	NUMBER,
	p_serial_number			IN	VARCHAR2
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'Instantiate_Serial_Number';
l_api_version           	CONSTANT NUMBER 	:= 1.0;

l_x_return_status		VARCHAR2(2000);
l_x_msg_count			NUMBER;
l_x_msg_data			VARCHAR2(4000);

l_maintenance_object_id		NUMBER;

l_module            varchar2(200) ;
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
      if( l_ulog) then
           l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
      end if;


	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_ObjectInstantiation_PUB.Instantiate_Serial_Number ===================='
		|| 'p_current_organization_id = ' || p_current_organization_id
		|| 'p_inventory_item_id = ' || p_inventory_item_id
 		|| 'p_serial_number = ' || p_serial_number);
	end if;

/* Following code has been commented for bug # 4659202.
   Instantiation process will be taken care by IB api */
/*
	BEGIN
		SELECT 	instance_id INTO l_maintenance_object_id
		FROM 	csi_item_instances
		WHERE 	inventory_item_id = p_inventory_item_id
		AND	serial_number = p_serial_number;

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'l_maintenance_object_id = ' || l_maintenance_object_id);
		end if;

	EXCEPTION
		WHEN OTHERS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_GEN_ID');
				FND_MSG_PUB.ADD;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MSG_PUB.Count_And_Get
    			(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    			);
			x_msg_data := substr(x_msg_data,1,4000);
			RETURN;
	END;


	if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
		'Calling EAM_ObjectInstantiation_PUB.Instantiate_Object...');
	end if;

	Instantiate_Object
	( 	p_api_version           	=> p_api_version,
  		p_init_msg_list			=> p_init_msg_list,
		p_commit	    		=> p_commit,
		p_validation_level		=> p_validation_level,
		x_return_status			=> l_x_return_status,
		x_msg_count			=> l_x_msg_count,
		x_msg_data			=> l_x_msg_data,
		-- input: maintenance object (id and type)
		p_maintenance_object_id		=> l_maintenance_object_id,
		p_maintenance_object_type 	=> 3
	);
*/
	-- Assign outputs
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg_count := l_x_msg_count;
	x_msg_data := l_x_msg_data;
	x_msg_data := substr(x_msg_data,1,4000);

END;

-- ======================================================================

PROCEDURE Instantiate_Object
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list			IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	-- input: maintenance object (id and type)
	p_maintenance_object_id		IN	NUMBER, -- for Maintenance Object Type of 3, this should be INSTANCE_Id
	p_maintenance_object_type	IN	NUMBER -- only supports Type 3 (Serialized Asset Numbers) for now
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'Instantiate_Object';
l_api_version           	CONSTANT NUMBER 	:= 1.0;

l_eam_instantiation_flag	VARCHAR2(1);
l_network_asset_flag            VARCHAR2(1);
l_current_status		NUMBER;
l_owning_department_id		NUMBER;
l_class_code			VARCHAR2(10);

-- local variables for call the Activity Instantiation Package
l_x_act_return_status		VARCHAR2(1);
l_x_act_msg_count		NUMBER;
l_x_act_msg_data		VARCHAR2(4000);
l_x_meter_return_status           VARCHAR2(1);
l_x_meter_msg_count               NUMBER;
l_x_meter_msg_data                VARCHAR2(4000);
l_x_pm_return_status           VARCHAR2(1);
l_x_pm_msg_count               NUMBER;
l_x_pm_msg_data                VARCHAR2(4000);
l_x_supp_return_status           VARCHAR2(1);
l_x_supp_msg_count               NUMBER;
l_x_supp_msg_data                VARCHAR2(4000);
l_x_act_association_id_tbl	EAM_ObjectInstantiation_PUB.Association_Id_Tbl_Type;


 /* R12 Hook for Asset Log #4141712*/
 l_maint_orgid			NUMBER;
 l_event_type			VARCHAR2(30)	:= 'EAM_SYSTEM_EVENTS';
 l_event_date			DATE	:= sysdate;
 l_reference			VARCHAR2(30);
 l_operational_log_flag		VARCHAR2(1);
 l_return_status		VARCHAR2(5);
 l_comments			VARCHAR2(2000)  := 'Initial Creation of Asset';

l_module             varchar2(200) ;
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_exLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_exception >= l_log_level;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

l_date				DATE;

BEGIN
      if( l_ulog) then
           l_module    := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
      end if;

	if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_ObjectInstantiation_PUB.Instantiate_Object ===================='
		|| 'p_maintenance_object_id = ' || p_maintenance_object_id
		|| 'p_maintenance_object_type = ' || p_maintenance_object_type);
	end if;

	-- Standard Start of API savepoint
    	SAVEPOINT	Instantiate_Object_PUB;

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


	-- 1: Check Maintenance Object Type, only support 3 (Serialized Asset Numbers) for now
	IF p_maintenance_object_type <> 3 THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INVALID_MAINT_OBJ_TYPE');
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- 2: add code when the column is added to MSN
	-- Check PM_INSTANTIATED flag in MSN, if flag is checked, do nothing and return SUCCESS

	select cii.instantiation_flag, cii.network_asset_flag
	  into l_eam_instantiation_flag, l_network_asset_flag
	from csi_item_instances cii
	where cii.instance_id = p_maintenance_object_id;

	begin
		select eomd.accounting_class_code, eomd.owning_department_id
		INTO l_class_code, l_owning_department_id
		FROM	csi_item_instances cii, eam_org_maint_defaults eomd, mtl_parameters mp
		WHERE	cii.instance_id = p_maintenance_object_id
		and eomd.object_type = 50
		and eomd.object_id  = cii.instance_id
		and mp.organization_id = cii.last_vld_organization_id
		and eomd.organization_id = mp.maint_organization_id;
	exception
		when others then
			l_class_code := null;
			l_owning_department_id := null;
	end;

	if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
		'l_eam_instantiation_flag=' || l_eam_instantiation_flag);
	end if;

	IF (NVL(l_eam_instantiation_flag, 'N') <> 'Y' AND NVL(l_network_asset_flag, 'N') <> 'Y' ) THEN

		IF (l_plog) THEN FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'Calling EAM_ActivityAssociation_PVT.Inst_Activity_Template...');
		END IF;

		-- 3: Call the Activity Instantiation API
		EAM_ActivityAssociation_PVT.Inst_Activity_Template(
		 		p_api_version			=> 1.0,

				x_return_status			=> l_x_act_return_status,
				x_msg_count			=> l_x_act_msg_count,
				x_msg_data			=> l_x_act_msg_data,

				p_maintenance_object_id		=> p_maintenance_object_id,
				p_maintenance_object_type	=> p_maintenance_object_type,
				-- output for activity association
				x_activity_association_id_tbl	=> l_x_act_association_id_tbl

				-- BUG: 3683229
				,p_class_code			=> l_class_code
				,p_owning_department_id		=> l_owning_department_id
			);

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'Returned from EAM_ActivityAssociation_PVT.Inst_Activity_Template'
			|| 'l_x_act_return_status = ' || l_x_act_return_status
			|| 'l_x_act_msg_count = ' || l_x_act_msg_count
			|| 'l_x_act_msg_data = ' || l_x_act_msg_data
			|| 'Calling eam_pmdef_pub.instantiate_pm_defs...');
		end if;

		eam_pmdef_pub.instantiate_pm_defs
		(
			p_api_version=>1.0,
			x_return_status=> l_x_pm_return_status,
			x_msg_count=> l_x_pm_msg_count,
			x_msg_data => l_x_pm_msg_data,
			p_activity_assoc_id_tbl=> l_x_act_association_id_tbl
		);

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'Returned from eam_pmdef_pub.instantiate_pm_defs'
			|| 'l_x_pm_return_status = ' || l_x_pm_return_status
			|| 'l_x_pm_msg_count = ' || l_x_pm_msg_count
			|| 'l_x_pm_msg_data = ' || l_x_pm_msg_data
			|| 'Calling eam_pm_suppressions.instantiate_supp_defs...');
		end if;

		-- 4.5 Instantiate suppressions
	 	eam_pm_suppressions.instantiate_suppressions(
  			p_api_version => 1.0,
			x_return_status=> l_x_supp_return_status,
			x_msg_count => l_x_supp_msg_count,
			x_msg_data => l_x_supp_msg_data,
			p_maintenance_object_id=> p_maintenance_object_id
		);

		if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'Returned from eam_pm_suppressions.instantiate_supp_defs'
			|| 'l_x_supp_return_status = ' || l_x_supp_return_status
			|| 'l_x_supp_msg_count = ' || l_x_supp_msg_count
			|| 'l_x_supp_msg_data = ' || l_x_supp_msg_data);
		end if;

		-- 5: Procedure call only successful if all sub-procedures returned status success
		IF l_x_act_return_status <> FND_API.G_RET_STS_SUCCESS OR
			l_x_pm_return_status <> FND_API.G_RET_STS_SUCCESS OR
                	l_x_supp_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_INST_API_FAILED');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- 6:Set PM_INSTANTIATED flag in MSN
		UPDATE	csi_item_instances
		SET	instantiation_flag = 'Y'
		WHERE	instance_id = p_maintenance_object_id;

		-- 7: Insert Log into EAM_ASSET_LOG for Activate Asset Event while Asset Creation
		--    with Active Status and Operational Log Flag Checked.

		SELECT  mp.maint_organization_id, cii.instance_number, cii.active_start_date, cii.operational_log_flag
		INTO  l_maint_orgid, l_reference, l_event_date, l_operational_log_flag
		FROM csi_item_instances cii, mtl_parameters mp
		WHERE cii.instance_id = p_maintenance_object_id
		AND cii.last_vld_organization_id = mp.organization_id ;

                IF (l_operational_log_flag = 'Y' ) THEN

		   eam_asset_log_pvt.insert_row
		   (
		      p_event_date	    =>	l_event_date,
		      p_event_type	    =>	l_event_type,
		      p_event_id	    =>	1,
		      p_organization_id	    =>	l_maint_orgid,
		      p_instance_id	    =>	p_maintenance_object_id,
		      p_reference	    =>	l_reference,
		      p_ref_id		    =>	p_maintenance_object_id,
		      p_instance_number	    =>	l_reference,
		      p_comments	    =>	l_comments,
		      x_return_status	    =>	l_return_status,
		      x_msg_count	    =>	x_msg_count,
		      x_msg_data	    =>	x_msg_data
		    );
                END IF;

	ELSE
		-- Instantiated already, do nothing
		NULL;
	END IF;

	-- 8: Insert into EAM_ASSET_TEXT for text Search

        eam_text_util.process_asset_update_event
        (
            p_event         => 'INSERT'
           ,p_instance_id   => p_maintenance_object_id
        );

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
		'==================== Exiting EAM_ObjectInstantiation_PUB.Instantiate_Object ====================');
	end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Instantiate_Object_PUB;

	if (l_exlog) then FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
			'==================== EAM_ObjectInstantiation_PUB.Instantiate_Object: EXPECTED ERROR ====================');
	end if;

	x_return_status := FND_API.G_RET_STS_ERROR ;

	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

	 x_msg_data := substr(x_msg_data,1,4000);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Instantiate_Object_PUB;

	if (l_exlog) then FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
			'==================== EAM_ObjectInstantiation_PUB.Instantiate_Object: UNEXPECTED ERROR ====================');
	end if;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

	x_msg_data := substr(x_msg_data,1,4000);

    WHEN OTHERS THEN
	ROLLBACK TO Instantiate_Object_PUB;

	if (l_exlog) then FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
			'==================== EAM_ObjectInstantiation_PUB.Instantiate_Object: OTHER ERROR ====================');
	end if;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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

END Instantiate_Object;

END EAM_ObjectInstantiation_PUB;


/

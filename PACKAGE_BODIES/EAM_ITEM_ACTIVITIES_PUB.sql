--------------------------------------------------------
--  DDL for Package Body EAM_ITEM_ACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ITEM_ACTIVITIES_PUB" AS
/* $Header: EAMPIAAB.pls 120.2.12010000.2 2008/11/06 23:50:44 mashah ship $ */
-- Start of comments
--	API name 	: EAM_ITEM_ACTIVITIES_PUB
--	Type		: Public
--	Function	: INSERT_ITEM_ACTIVITIES, update_item_activities
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ITEM_ACTIVITIES_PUB';

/* for de-bugging */
/* g_sr_no		number ; */

PROCEDURE print_log(info varchar2) is
PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN
/*
if (g_sr_no is null or g_sr_no<0) then
		g_sr_no := 0;
	end if;

	g_sr_no := g_sr_no+1;

	INSERT into temp_isetup_api(msg,sr_no)
	VALUES (info,g_sr_no);

	commit;
*/
  FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;

FUNCTION VALIDATE_EAM_ENABLED
	(P_ORGANIZATION_ID NUMBER)
	RETURN BOOLEAN
IS
L_STATUS NUMBER;
BEGIN
	SELECT count(*) INTO L_status
	FROM MTL_PARAMETERS
	WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
	AND NVL(EAM_ENABLED_FLAG, 'N') = 'Y';

	IF L_status > 0
	THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END VALIDATE_EAM_ENABLED;
/* function checking the item unique when both the 2 combinations are provided by the user */
FUNCTION check_item_unique (
			p_maintenance_object_type NUMBER,
			p_maintenance_object_id NUMBER,
			p_asset_group_id NUMBER,
			p_organization_id NUMBER,
			p_asset_number VARCHAR2,
			p_creation_organization_id NUMBER
		)
	RETURN boolean
IS
	l_count_rec NUMBER := 0;
BEGIN
	IF (p_maintenance_object_type = 3) THEN
		IF ( p_asset_number IS NOT NULL ) THEN
			SELECT count(*) INTO l_count_rec
			FROM csi_item_instances cii
			WHERE cii.serial_number = p_asset_number
			AND cii.instance_id = p_maintenance_object_id
			AND cii.inventory_item_id = p_asset_group_id;
		END IF;

	ELSIF (p_maintenance_object_type = 2) THEN
		IF ((p_asset_number IS NULL) AND
		    (p_maintenance_object_id = p_asset_group_id)) THEN
			SELECT count(*) INTO l_count_rec
			FROM mtl_system_items msi, mtl_parameters mp
			WHERE msi.inventory_item_id = p_asset_group_id
			AND msi.organization_id = mp.organization_id
			AND mp.maint_organization_id = p_organization_id;
		END IF;

	END IF;

	IF (l_count_rec > 0) THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;

END check_item_unique;

/* For raising error */
PROCEDURE RAISE_ERROR (ERROR VARCHAR2)
IS
BEGIN


	FND_MESSAGE.SET_NAME ('EAM', ERROR);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END;

--funcation to validate if the provided lookup code is present forthe specified type.
PROCEDURE validate_mfg_lookups(P_LOOKUP_TYPE IN VARCHAR2, P_LOOKUP_CODE in varchar2, P_MSG in varchar2)
is
   l_count number;
BEGIN
        IF P_LOOKUP_CODE IS NULL
          THEN
                RETURN ;
          END IF ;

        SELECT count(*) INTO l_count
	FROM   mfg_lookups
	WHERE  lookup_type = P_LOOKUP_TYPE
	  AND  lookup_code= P_LOOKUP_CODE;

        if l_count = 0
        then
	      fnd_message.set_name('EAM', P_MSG);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;
END;

--funciton to validate the wip entity class CLASS_TYPE = "Maintenance" <6>
PROCEDURE validate_acnt_class(P_WIP_ACNT_CLASS in varchar2, P_ORGANIZATION_ID IN NUMBER)
is
        l_count number;
  BEGIN

	IF P_WIP_ACNT_CLASS IS NULL OR P_ORGANIZATION_ID IS NULL
          THEN
                RETURN ;
          END IF ;

        SELECT count(*) INTO l_count
        from wip_accounting_classes
        where class_code = P_WIP_ACNT_CLASS
        and class_type = 6
        and organization_id = P_ORGANIZATION_ID;

        if l_count = 0
        then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_CLASS_CODE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;
END;


PROCEDURE validate_boolean_flag(p_flag IN VARCHAR2, p_msg IN VARCHAR2)
is
begin
	if(p_flag is not null)
	then
	if not 	EAM_COMMON_UTILITIES_PVT.validate_boolean_flag(p_flag)
	then
	      fnd_message.set_name('EAM', p_msg);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;
	end if;
end;


PROCEDURE validate_maintenance_object_id(p_organization_id in number, p_object_id in number, p_eam_item_type in NUMBER)
is
l_count number;
begin
          IF p_object_id IS NULL OR p_eam_item_type IS NULL OR p_organization_id IS NULL
          THEN
                RETURN ;
          END IF ;

	  if p_eam_item_type = 3 then
		select count(cii.instance_id) into l_count
		from csi_item_instances cii
		where cii.instance_id=p_object_id;
	  elsif p_eam_item_type = 2 then
		select count(msi.inventory_item_id) into l_count
		from mtl_system_items msi, mtl_parameters mp
		where msi.inventory_item_id = p_object_id
		  and msi.organization_id = mp.organization_id
		  and mp.maint_organization_id = p_organization_id
		--and eam_item_type = p_eam_item_type
		;
	  end if;

	if l_count = 0 then
	      fnd_message.set_name('EAM', 'EAM_INVALID_MAINT_OBJ_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;

END;


-- This function validates an asset group, asset activity, or
-- rebuildable item. p_eam_item_type indicates the type of item being
-- validated. Asset group: 1; Asset activity: 2; Rebuildable item: 3.
PROCEDURE validate_inventory_item_id
(
        p_organization_id in number,
        p_inventory_item_id in number
) is
l_count number:=0;
begin
        IF P_ORGANIZATION_ID IS NOT NULL AND p_inventory_item_id  IS NOT NULL
        THEN

	select count(msi.inventory_item_id) into l_count
	from mtl_system_items msi, mtl_parameters mp
	where msi.inventory_item_id=p_inventory_item_id
	and msi.organization_id = mp.organization_id
	and mp.maint_organization_id=p_organization_id
	and eam_item_type IN (1, 3);

	END IF;

	if (l_count = 0) then
	      fnd_message.set_name('EAM', 'EAM_INVALID_INVENTORY_ITEM');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;
end validate_inventory_item_id;

procedure validate_serial_number(p_serial_number in varchar2 ,p_tmpl_flag in varchar2 , p_organization_id in number )
is
   l_count number;

  BEGIN

    if nvl(p_tmpl_flag, 'N') = 'Y' and p_serial_number is not null
    then
	      fnd_message.set_name('EAM', 'EAM_IAA_SERIAL_NUMBER_NOT_NULL');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
    end if;

    if nvl(p_tmpl_flag, 'N') = 'N' and p_serial_number is null
    then
	      fnd_message.set_name('EAM', 'EAM_IAA_SERIAL_NUMBER_NULL');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
    end if;

    if nvl(p_tmpl_flag, 'N') = 'N'
    then
        select count(cii.inventory_item_id) into l_count
        from csi_item_instances cii
	where cii.serial_number = p_serial_number;

	if (l_count = 0) then
	      fnd_message.set_name('EAM', 'EAM_EZWO_ASSET_BAD');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;
    end if;
END validate_serial_number;



procedure validate_dff_segments(
			p_ATTRIBUTE_CATEGORY    IN                	  VARCHAR2 default null,
			p_ATTRIBUTE1            IN                        VARCHAR2 default null,
			p_ATTRIBUTE2            IN                        VARCHAR2 default null,
			p_ATTRIBUTE3            IN                        VARCHAR2 default null,
			p_ATTRIBUTE4            IN                        VARCHAR2 default null,
			p_ATTRIBUTE5            IN                        VARCHAR2 default null,
			p_ATTRIBUTE6            IN                        VARCHAR2 default null,
			p_ATTRIBUTE7            IN                        VARCHAR2 default null,
			p_ATTRIBUTE8            IN                        VARCHAR2 default null,
			p_ATTRIBUTE9            IN                        VARCHAR2 default null,
			p_ATTRIBUTE10           IN                        VARCHAR2 default null,
			p_ATTRIBUTE11           IN                        VARCHAR2 default null,
			p_ATTRIBUTE12           IN                        VARCHAR2 default null,
			p_ATTRIBUTE13           IN                        VARCHAR2 default null,
			p_ATTRIBUTE14           IN                        VARCHAR2 default null,
			p_ATTRIBUTE15           IN                        VARCHAR2 default null
			)
is
l_error_segments number;
l_error_message varchar2(4000);

begin
        -- validate the desc. flex fields
	if not EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field
	(
		p_app_short_name => 'INV',
		p_desc_flex_name => 'MTL_EAM_ASSET_ACTIVITIES',
                p_ATTRIBUTE_CATEGORY => p_ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1      => p_ATTRIBUTE1,
                p_ATTRIBUTE2      => p_ATTRIBUTE2,
                p_ATTRIBUTE3      => p_ATTRIBUTE3,
                p_ATTRIBUTE4      => p_ATTRIBUTE4,
                p_ATTRIBUTE5      => p_ATTRIBUTE5,
                p_ATTRIBUTE6      => p_ATTRIBUTE6,
                p_ATTRIBUTE7      => p_ATTRIBUTE7,
                p_ATTRIBUTE8      => p_ATTRIBUTE8,
                p_ATTRIBUTE9      => p_ATTRIBUTE9,
                p_ATTRIBUTE10     => p_ATTRIBUTE10,
                p_ATTRIBUTE11     => p_ATTRIBUTE11,
                p_ATTRIBUTE12     => p_ATTRIBUTE12,
                p_ATTRIBUTE13     => p_ATTRIBUTE13,
                p_ATTRIBUTE14     => p_ATTRIBUTE14,
                p_ATTRIBUTE15     => p_ATTRIBUTE15,
        	x_error_segments  => l_error_segments,
        	x_error_message   => l_error_message
	)
        then
                FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_DESC_FLEX');
                FND_MESSAGE.SET_TOKEN('ERROR_MSG', l_error_message);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        end if;

end validate_dff_segments;





procedure VALIDATE_ROW_EXISTS(P_ASSET_ACTIVITY_ID IN NUMBER,
                              P_MAINTENANCE_OBJECT_ID IN NUMBER,
			      P_MAINTENANCE_OBJECT_TYPE IN NUMBER,
			      p_tmpl_flag in varchar2,
                              x_act_assoc_id OUT NOCOPY NUMBER)
is
  BEGIN


	SELECT activity_association_id INTO x_act_assoc_id
	FROM mtl_eam_asset_activities
	WHERE maintenance_object_id = p_maintenance_object_id
	AND asset_activity_id = P_asset_activity_id
	AND maintenance_object_type = p_maintenance_object_type
	AND NVL(tmpl_flag, 'N') = NVL(p_tmpl_flag, 'N');

  EXCEPTION
        WHEN NO_DATA_FOUND THEN
	   x_act_assoc_id := -1;
        WHEN TOO_MANY_ROWS THEN
              fnd_message.set_name('EAM', 'EAM_DATA_CORRUPT');
	      fnd_message.set_token('TABLE_NAME', 'MTL_EAM_ASSET_ACTIVITIES');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
END;



PROCEDURE INSERT_ITEM_ACTIVITIES
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ASSET_ACTIVITY_ID		IN	NUMBER	,
	/*P_INVENTORY_ITEM_ID		IN	NUMBER	,*/
	P_INVENTORY_ITEM_ID		IN	NUMBER	default null,
	P_ORGANIZATION_ID		IN	NUMBER	,
	P_OWNINGDEPARTMENT_ID		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER default null,
	P_CREATION_ORGANIZATION_ID	IN	NUMBER 	default null,
	P_START_DATE_ACTIVE		IN	DATE default null	,
	P_END_DATE_ACTIVE		IN	DATE default null	,
	P_PRIORITY_CODE			IN	VARCHAR2 default null	,
	P_ACTIVITY_CAUSE_CODE		IN	VARCHAR2 default null,
	P_ACTIVITY_TYPE_CODE		IN	VARCHAR2 default null	,
	P_SHUTDOWN_TYPE_CODE		IN	VARCHAR2 default null	,
	P_MAINTENANCE_OBJECT_TYPE	IN	NUMBER default null	,
	P_TMPL_FLAG			IN	VARCHAR2 default null	,
	P_CLASS_CODE			IN	VARCHAR2 default null,
	P_ACTIVITY_SOURCE_CODE		IN	VARCHAR2 default null,
	P_SERIAL_NUMBER			IN	VARCHAR2 default null	,
	P_ATTRIBUTE_CATEGORY		IN	VARCHAR2 default null	,
	P_ATTRIBUTE1			IN	VARCHAR2 default null	,
	P_ATTRIBUTE2			IN	VARCHAR2 default null	,
	P_ATTRIBUTE3			IN	VARCHAR2 default null	,
	P_ATTRIBUTE4			IN	VARCHAR2 default null	,
	P_ATTRIBUTE5			IN	VARCHAR2 default null	,
	P_ATTRIBUTE6			IN	VARCHAR2 default null	,
	P_ATTRIBUTE7			IN	VARCHAR2 default null	,
	P_ATTRIBUTE8			IN	VARCHAR2 default null	,
	P_ATTRIBUTE9			IN	VARCHAR2 default null	,
	P_ATTRIBUTE10			IN	VARCHAR2 default null	,
	P_ATTRIBUTE11			IN	VARCHAR2 default null	,
	P_ATTRIBUTE12			IN	VARCHAR2 default null	,
	P_ATTRIBUTE13			IN	VARCHAR2 default null	,
	P_ATTRIBUTE14			IN	VARCHAR2 default null	,
	P_ATTRIBUTE15			IN	VARCHAR2 default null	,
	P_TAGGING_REQUIRED_FLAG		IN	VARCHAR2 default null	,
	P_LAST_SERVICE_START_DATE	IN	DATE default null	,
	P_LAST_SERVICE_END_DATE		IN	DATE default null	,
	P_PREV_SERVICE_START_DATE	IN	DATE default null	,
	P_PREV_SERVICE_END_DATE		IN	DATE default null	,
	P_LAST_SCHEDULED_START_DATE	IN	DATE default null	,
        P_LAST_SCHEDULED_END_DATE	IN	DATE default null	,
	P_PREV_SCHEDULED_START_DATE	IN	DATE default null	,
        P_PREV_SCHEDULED_END_DATE	IN	DATE default null	,
	P_WIP_ENTITY_ID                 IN      NUMBER default null     ,
	P_SOURCE_TMPL_ID		IN	NUMBER default null	,
	p_pm_last_service_tbl           IN      EAM_PM_LAST_SERVICE_PUB.pm_last_service_tbl

)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'APIname';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_actv_assoc_id                 number;

	l_object_found BOOLEAN;
	l_maintenance_object_type NUMBER;
	l_maintenance_object_id NUMBER;
	l_object_type NUMBER;
	l_object_id NUMBER;
	l_creation_organization_id NUMBER;
	l_asset_group_id NUMBER;
	l_org_id NUMBER;
	l_temp_org_id NUMBER;
	l_asset_number VARCHAR2(100);
	l_validated boolean;
	l_item_type number;
	l_item_id NUMBER;
	l_serial_number VARCHAR2(100);
	l_ser_num_ctrl_cd NUMBER;
	l_cur_st NUMBER;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	INSERT_ITEM_ACTIVITIES;

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

	/* for creation_organization_id = organization_id */
	l_org_id := P_ORGANIZATION_ID;

	if (P_CREATION_ORGANIZATION_ID IS NOT NULL) then
		if P_CREATION_ORGANIZATION_ID <> P_ORGANIZATION_ID then
		      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_CR_ORG_ID');
		      fnd_msg_pub.add;
		      RAISE fnd_api.g_exc_error;
		else
			l_creation_organization_id := P_ORGANIZATION_ID;
		end if;
	else
		l_creation_organization_id := P_ORGANIZATION_ID;
	end if;

        if l_creation_organization_id is not null then
                /* EAM enabled check */
        		EAM_COMMON_UTILITIES_PVT.verify_org(
        		          p_resp_id => NULL,
        		          p_resp_app_id => 401,
        		          p_org_id  => l_creation_organization_id,
        		          x_boolean => l_boolean,
        		          x_return_status => x_return_status,
        		          x_msg_count => x_msg_count ,
        		          x_msg_data => x_msg_data);
                if l_boolean = 0
            	  then
            	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
                          fnd_msg_pub.add;
                          RAISE fnd_api.g_exc_error;
            	end if;
        end if;


        IF ((p_class_code IS NOT NULL or p_owningdepartment_id IS NOT NULL) AND p_organization_id IS NULL) THEN
            fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

	-- Bug # 3441956
	BEGIN
	   select eam_item_type into l_item_type
	   from mtl_system_items
	   where inventory_item_id = p_asset_activity_id
	   and organization_id = nvl(p_organization_id, organization_id)
	   AND rownum = 1;

	   IF (l_item_type <> 2) THEN
	      raise_error('EAM_ABO_INVALID_ACTIVITY_ID');
           END IF;

        EXCEPTION
	   WHEN no_data_found THEN
	       raise_error('EAM_ABO_INVALID_ACTIVITY_ID');
        END;


	validate_mfg_lookups('WIP_EAM_ACTIVITY_PRIORITY', p_priority_code, 'EAM_PAR_INVALID_PRIORITY_CAT');

	validate_mfg_lookups('MTL_EAM_ACTIVITY_CAUSE',p_activity_cause_code, 'EAM_PAR_INVALID_ACTIVITY_CAUSE');

	validate_mfg_lookups('MTL_EAM_ACTIVITY_TYPE', p_activity_type_code, 'EAM_PAR_INVALID_ACTIVITY_TYPE');

	validate_mfg_lookups('BOM_EAM_SHUTDOWN_TYPE', P_shutdown_type_code, 'EAM_ABO_INVALID_SHUTDOWN_CODE');

	validate_mfg_lookups('MTL_EAM_ACTIVITY_SOURCE', P_activity_source_code, 'EAM_ABO_INVALID_ACT_SRC_CODE');

	validate_acnt_class(p_class_code , P_CREATION_ORGANIZATION_ID );


	if p_start_date_active>p_end_date_active
	then
	      fnd_message.set_name('EAM', 'EAM_IAA_INVALID_ACTIVE_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

	if p_last_service_start_date > p_last_service_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

	if p_prev_service_start_date > p_prev_service_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

	if p_last_scheduled_start_date > p_last_scheduled_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;


	if p_prev_scheduled_start_date > p_prev_scheduled_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

        validate_boolean_flag(p_tagging_required_flag, 'EAM_ABO_INVALID_TAG_REQ_FLAG');

	validate_boolean_flag(p_tmpl_flag, 'EAM_IAA_INV_TEML_FLAG');


	IF (p_owningdepartment_id is not null) THEN
	   l_validated := EAM_COMMON_UTILITIES_PVT.validate_department_id(p_owningdepartment_id, l_org_id);
	   IF NOT l_validated THEN
		raise_error ('EAM_ABO_INVALID_OWN_DEPT_ID');
	   END IF;
        END IF;

	validate_dff_segments(
				p_ATTRIBUTE_CATEGORY	,
				p_ATTRIBUTE1	,
				p_ATTRIBUTE2	,
				p_ATTRIBUTE3	,
				p_ATTRIBUTE4	,
				p_ATTRIBUTE5	,
				p_ATTRIBUTE6	,
				p_ATTRIBUTE7	,
				p_ATTRIBUTE8	,
				p_ATTRIBUTE9	,
				p_ATTRIBUTE10	,
				p_ATTRIBUTE11	,
				p_ATTRIBUTE12	,
				p_ATTRIBUTE13	,
				p_ATTRIBUTE14	,
				p_ATTRIBUTE15
			);
	--------------------------------------------------------------------------------------------
	IF ((p_maintenance_object_type is null or p_maintenance_object_id is null) and
	     (p_inventory_item_id is null)) THEN
	      fnd_message.set_name('EAM', 'EAM_NOT_ENOUGH_PARAM');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (p_maintenance_object_type is not null and p_maintenance_object_type NOT in (3,2)) THEN
	      fnd_message.set_name('EAM', 'EAM_INVALID_MAINT_OBJ_TYPE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_org_id := p_organization_id;
	l_asset_group_id := p_inventory_item_id;
	l_asset_number := p_serial_number;
        l_maintenance_object_type := p_maintenance_object_type;
	l_maintenance_object_id := p_maintenance_object_id;

	/* Validations for the item combinations supplied by the user */
	IF ( p_inventory_item_id IS NOT NULL and p_maintenance_object_id IS NULL ) THEN

		eam_common_utilities_pvt.translate_asset_maint_obj
		(
			P_ORGANIZATION_ID ,
			P_INVENTORY_ITEM_ID ,
			P_SERIAL_NUMBER ,
			l_object_found ,
			l_object_type ,
			l_object_id
		);

		IF (l_object_found) THEN
                       IF (l_maintenance_object_type is null) THEN
			  l_maintenance_object_type := l_object_type;
			END IF;
			IF (l_maintenance_object_id is null) THEN
			  l_maintenance_object_id := l_object_id;
			END IF;
		ELSE
			raise_error('EAM_NO_ITEM_FOUND');
		END IF;

	ELSIF ( (p_inventory_item_id IS NULL OR p_serial_number IS NULL)AND
	         p_maintenance_object_type IS NOT NULL AND p_maintenance_object_id IS NOT NULL) THEN

		eam_common_utilities_pvt.translate_maint_obj_asset
		(
			p_maintenance_object_type ,
			p_maintenance_object_id ,
			p_organization_id,
			l_object_found ,
			l_temp_org_id ,
			l_item_id ,
			l_serial_number
		);

		IF l_object_found THEN
		        IF (l_asset_group_id is null) THEN
			  l_asset_group_id := l_item_id;
			END IF;
			IF (l_asset_number is null) THEN
			  l_asset_number := l_serial_number;
			END IF;
			IF (l_org_id is null) THEN
			  l_org_id := l_temp_org_id;
			END IF;
		ELSE
			raise_error('EAM_NO_ITEM_FOUND');
		END IF;
        END IF;

	/* Check both the combinations are pointing to the same item / serial_number */
	l_validated := check_item_unique (
			l_maintenance_object_type ,
			l_maintenance_object_id ,
			l_asset_group_id ,
			l_org_id ,
			l_asset_number ,
			l_org_id
		);

	IF NOT l_validated THEN
		raise_error ('EAM_ABO_INVALID_INV_ITEM_ID');
	END IF;

	/* Template flag validation */
	begin
		SELECT msi.eam_item_type , msi.serial_number_control_code
		INTO l_item_type , l_ser_num_ctrl_cd
		FROM mtl_system_items_b msi, mtl_parameters mp
		WHERE msi.organization_id = mp.organization_id
		  AND mp.maint_organization_id = nvl(l_org_id, mp.maint_organization_id)
		  AND msi.inventory_item_id = l_asset_group_id
		  AND rownum = 1;

		if nvl (p_tmpl_flag , 'N') = 'Y' then
			if (l_maintenance_object_type = 3) then
				RAISE_ERROR ('EAM_IAA_INV_TEML_FLAG');
			end if;
			if (P_SOURCE_TMPL_ID is not null) then
				RAISE_ERROR ('EAM_SOURCE_TMPL_ID_NOT_NULL');
			end if;
			if ( l_item_type = 3 and l_ser_num_ctrl_cd = 1 )  then
				RAISE_ERROR ('EAM_NON_SERIAL_REBUILD_ASSOC');
			end if;
		else -- if non template record
			if (l_maintenance_object_type = 2) then
				if (NOT ( l_item_type = 3 and l_ser_num_ctrl_cd = 1 ))  then
					RAISE_ERROR ('EAM_IAA_INV_TEML_FLAG');
				end if;
			end if;
		end if;
	exception
		when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
	end;



	VALIDATE_ROW_EXISTS(p_asset_activity_id,
			    l_maintenance_object_id,
			    l_maintenance_object_type,
      			    p_tmpl_flag,
                            l_actv_assoc_id);

	-- validate source_tmpl_id
	IF (p_source_tmpl_id is NOT NULL) THEN

	   l_item_id := 0;
	   select count(*) into l_item_id
	   from mtl_eam_asset_activities
	   where activity_association_id = p_source_tmpl_id
	   and asset_activity_id = p_asset_activity_id
	   and inventory_item_id = l_asset_group_id
	   and tmpl_flag = 'Y';

	   IF (l_item_id = 0) THEN
	      raise_error('EAM_INVALID_TMPL_ID');
           END IF;

        END IF;

        IF (l_actv_assoc_id = -1) THEN

	  select MTL_EAM_ASSET_ACTIVITIES_S.NEXTVAL into l_actv_assoc_id from dual;
          INSERT INTO mtl_eam_asset_activities
          (
		ACTIVITY_ASSOCIATION_ID ,
		ASSET_ACTIVITY_ID	,
		MAINTENANCE_OBJECT_ID	,
		START_DATE_ACTIVE	,
		END_DATE_ACTIVE	,
		PRIORITY_CODE	,
		MAINTENANCE_OBJECT_TYPE	,
		TMPL_FLAG	,
		ATTRIBUTE_CATEGORY	,
		ATTRIBUTE1	,
		ATTRIBUTE2	,
		ATTRIBUTE3	,
		ATTRIBUTE4	,
		ATTRIBUTE5	,
		ATTRIBUTE6	,
		ATTRIBUTE7	,
		ATTRIBUTE8	,
		ATTRIBUTE9	,
		ATTRIBUTE10	,
		ATTRIBUTE11	,
		ATTRIBUTE12	,
		ATTRIBUTE13	,
		ATTRIBUTE14	,
		ATTRIBUTE15	,
		LAST_SERVICE_START_DATE	,
		LAST_SERVICE_END_DATE	,
		PREV_SERVICE_START_DATE	,
		PREV_SERVICE_END_DATE	,
		LAST_SCHEDULED_START_DATE	,
		LAST_SCHEDULED_END_DATE	,
		PREV_SCHEDULED_START_DATE	,
		PREV_SCHEDULED_END_DATE	,
		WIP_ENTITY_ID,
		SOURCE_TMPL_ID		,
		CREATED_BY           ,
		CREATION_DATE       ,
		LAST_UPDATE_LOGIN  ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY
	  )
	  VALUES
	  (
		l_actv_assoc_id,
		P_ASSET_ACTIVITY_ID	,
		l_maintenance_object_id,
		P_START_DATE_ACTIVE	,
		P_END_DATE_ACTIVE	,
		P_PRIORITY_CODE	,
		/*P_MAINTENANCE_OBJECT_TYPE	,*/
		l_maintenance_object_type,
		nvl(P_TMPL_FLAG,'N')	,
		P_ATTRIBUTE_CATEGORY	,
		P_ATTRIBUTE1	,
		P_ATTRIBUTE2	,
		P_ATTRIBUTE3	,
		P_ATTRIBUTE4	,
		P_ATTRIBUTE5	,
		P_ATTRIBUTE6	,
		P_ATTRIBUTE7	,
		P_ATTRIBUTE8	,
		P_ATTRIBUTE9	,
		P_ATTRIBUTE10	,
		P_ATTRIBUTE11	,
		P_ATTRIBUTE12	,
		P_ATTRIBUTE13	,
		P_ATTRIBUTE14	,
		P_ATTRIBUTE15	,
		P_LAST_SERVICE_START_DATE	,
		P_LAST_SERVICE_END_DATE	,
		P_PREV_SERVICE_START_DATE	,
		P_PREV_SERVICE_END_DATE	,
		P_LAST_SCHEDULED_START_DATE	,
		P_LAST_SCHEDULED_END_DATE	,
		P_PREV_SCHEDULED_START_DATE	,
		P_PREV_SCHEDULED_END_DATE	,
		P_WIP_ENTITY_ID,
		P_SOURCE_TMPL_ID	,
		fnd_global.user_id,
		sysdate,
		fnd_global.login_id,
		sysdate    ,
		fnd_global.user_id
	  );
       END IF;

       IF p_maintenance_object_type = 2 THEN
          l_object_type := 40;
       ELSE
          l_object_type := 60;
       END IF;

       IF (p_organization_Id IS NOT NULL) THEN

         eam_org_maint_defaults_pvt.update_insert_row
  	 (
	      p_api_version           => 1.0
             ,p_commit                => p_commit
	     ,p_object_type           => l_object_type
	     ,p_object_id             => l_actv_assoc_id
	     ,p_organization_id       => p_organization_Id
	     ,p_owning_department_id  => p_owningdepartment_id
	     ,p_accounting_class_code => p_class_code
	     ,p_activity_cause_code   => p_activity_cause_code
	     ,p_activity_type_code    => p_activity_type_code
	     ,p_activity_source_code  => p_activity_source_code
	     ,p_shutdown_type_code    => p_shutdown_type_code
	     ,p_tagging_required_flag => p_tagging_required_flag
	     ,x_return_status         => x_return_status
	     ,x_msg_count             => x_msg_count
	     ,x_msg_data              => x_msg_data
	 );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
	    RAISE fnd_api.g_exc_error;
         END IF;
       END IF;

       IF p_pm_last_service_tbl.count >0 THEN

	     IF (p_tmpl_flag = 'Y') THEN
	       raise_error('EAM_INVALID_METER_READING');
	     END IF;

             EAM_PM_LAST_SERVICE_PUB.process_pm_last_service
             (
			p_api_version      => p_api_version,
			p_init_msg_list    => FND_API.G_FALSE,--p_init_msg_list,
			p_commit	   => p_commit,
			p_validation_level => p_validation_level,
			x_return_status	   => x_return_status,
			x_msg_count        => x_msg_count,
			x_msg_data	   => x_msg_data,

			p_pm_last_service_tbl => p_pm_last_service_tbl,
			p_actv_assoc_id       => l_actv_assoc_id
	       );

	      x_msg_count := FND_MSG_PUB.count_msg;
	      IF x_msg_count > 0 THEN
	         RAISE FND_API.G_EXC_ERROR;
	      END IF;
        END IF;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSERT_ITEM_ACTIVITIES;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_ITEM_ACTIVITIES;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO INSERT_ITEM_ACTIVITIES;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END INSERT_ITEM_ACTIVITIES;


PROCEDURE update_item_activities
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ACTIVITY_ASSOCIATION_ID	IN	NUMBER	,
	P_ASSET_ACTIVITY_ID		IN	NUMBER	,
	P_INVENTORY_ITEM_ID		IN	NUMBER	default null,
	P_ORGANIZATION_ID		IN	NUMBER	,
	P_OWNINGDEPARTMENT_ID		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER default null,
	P_CREATION_ORGANIZATION_ID	IN	NUMBER default null,
	P_START_DATE_ACTIVE		IN	DATE default null	,
	P_END_DATE_ACTIVE		IN	DATE default null	,
	P_PRIORITY_CODE			IN	VARCHAR2 default null	,
	P_ACTIVITY_CAUSE_CODE		IN	VARCHAR2 default null,
	P_ACTIVITY_TYPE_CODE		IN	VARCHAR2 default null	,
	P_SHUTDOWN_TYPE_CODE		IN	VARCHAR2 default null	,
	P_MAINTENANCE_OBJECT_TYPE	IN	NUMBER default null	,
	P_TMPL_FLAG			IN	VARCHAR2 default null	,
	P_CLASS_CODE			IN	VARCHAR2 default null,
	P_ACTIVITY_SOURCE_CODE		IN	VARCHAR2 default null,
	P_SERIAL_NUMBER			IN	VARCHAR2 default null	,
	P_ATTRIBUTE_CATEGORY		IN	VARCHAR2 default null	,
	P_ATTRIBUTE1			IN	VARCHAR2 default null	,
	P_ATTRIBUTE2			IN	VARCHAR2 default null	,
	P_ATTRIBUTE3			IN	VARCHAR2 default null	,
	P_ATTRIBUTE4			IN	VARCHAR2 default null	,
	P_ATTRIBUTE5			IN	VARCHAR2 default null	,
	P_ATTRIBUTE6			IN	VARCHAR2 default null	,
	P_ATTRIBUTE7			IN	VARCHAR2 default null	,
	P_ATTRIBUTE8			IN	VARCHAR2 default null	,
	P_ATTRIBUTE9			IN	VARCHAR2 default null	,
	P_ATTRIBUTE10			IN	VARCHAR2 default null	,
	P_ATTRIBUTE11			IN	VARCHAR2 default null	,
	P_ATTRIBUTE12			IN	VARCHAR2 default null	,
	P_ATTRIBUTE13			IN	VARCHAR2 default null	,
	P_ATTRIBUTE14			IN	VARCHAR2 default null	,
	P_ATTRIBUTE15			IN	VARCHAR2 default null	,
	P_TAGGING_REQUIRED_FLAG		IN	VARCHAR2 default null	,
	P_LAST_SERVICE_START_DATE	IN	DATE default null	,
	P_LAST_SERVICE_END_DATE		IN	DATE default null	,
	P_PREV_SERVICE_START_DATE	IN	DATE default null	,
	P_PREV_SERVICE_END_DATE		IN	DATE default null	,
	P_LAST_SCHEDULED_START_DATE	IN	DATE default null	,
	P_LAST_SCHEDULED_END_DATE		IN	DATE default null	,
	P_PREV_SCHEDULED_START_DATE	IN	DATE default null	,
	P_PREV_SCHEDULED_END_DATE		IN	DATE default null	,
	P_WIP_ENTITY_ID                 IN      NUMBER default null,
	P_SOURCE_TMPL_ID		IN	NUMBER default null	,

	p_pm_last_service_tbl           IN      EAM_PM_LAST_SERVICE_PUB.pm_last_service_tbl
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'APIname';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);

	l_object_found BOOLEAN;
	l_maintenance_object_type NUMBER;
	l_maintenance_object_id NUMBER;
	l_object_type NUMBER;
	l_object_id NUMBER;
	l_creation_organization_id NUMBER;
	l_asset_group_id NUMBER;
	l_org_id NUMBER;
	l_temp_org_id NUMBER;
	l_asset_number VARCHAR2(100);
	l_validated boolean;
	l_cnt number;
	l_item_type number;
	l_item_id NUMBER;
	l_serial_number VARCHAR2(100);
	l_ser_num_ctrl_cd NUMBER;
	l_cur_st NUMBER;
	l_id NUMBER;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT UPDATE_ITEM_ACTIVITIES;

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

	l_cnt := 0;

	/* for creation_organization_id = organization_id */
	l_org_id := P_ORGANIZATION_ID;

	if (P_CREATION_ORGANIZATION_ID IS NOT NULL) then
		if P_CREATION_ORGANIZATION_ID <> P_ORGANIZATION_ID then
		      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_CR_ORG_ID');
		      fnd_msg_pub.add;
		      RAISE fnd_api.g_exc_error;
		else
			l_creation_organization_id := P_ORGANIZATION_ID;
		end if;
	else
		l_creation_organization_id := P_ORGANIZATION_ID;
	end if;

        if l_creation_organization_id is not null then
                /* EAM enabled check */
        		EAM_COMMON_UTILITIES_PVT.verify_org(
        		          p_resp_id => NULL,
        		          p_resp_app_id => 401,
        		          p_org_id  => l_creation_organization_id,
        		          x_boolean => l_boolean,
        		          x_return_status => x_return_status,
        		          x_msg_count => x_msg_count ,
        		          x_msg_data => x_msg_data);
                if l_boolean = 0
            	  then
            	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
                          fnd_msg_pub.add;
                          RAISE fnd_api.g_exc_error;
            	end if;
        end if;


	IF ((p_class_code IS NOT NULL or p_owningdepartment_id IS NOT NULL) AND p_organization_id IS NULL) THEN
           fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
	   fnd_msg_pub.add;
	   RAISE fnd_api.g_exc_error;
	END IF;

	-- Bug # 3441956
	BEGIN
	   select count(*) into l_cnt
	   from mtl_eam_asset_activities
	   where asset_activity_id = p_asset_activity_id
	   and activity_association_id = p_activity_association_id;

	   IF (l_cnt = 0) THEN
	      raise_error('EAM_ABO_INVALID_ACTIVITY_ID');
           END IF;

        EXCEPTION
	   WHEN no_data_found THEN
	       raise_error('EAM_ABO_INVALID_ACTIVITY_ID');
        END;

	validate_mfg_lookups('WIP_EAM_ACTIVITY_PRIORITY', p_priority_code, 'EAM_PAR_INVALID_PRIORITY_CAT');

	validate_mfg_lookups('MTL_EAM_ACTIVITY_CAUSE',p_activity_cause_code, 'EAM_PAR_INVALID_ACTIVITY_CAUSE');

	validate_mfg_lookups('MTL_EAM_ACTIVITY_TYPE', p_activity_type_code, 'EAM_PAR_INVALID_ACTIVITY_TYPE');

	validate_mfg_lookups('BOM_EAM_SHUTDOWN_TYPE', P_shutdown_type_code, 'EAM_ABO_INVALID_SHUTDOWN_CODE');

	validate_mfg_lookups('MTL_EAM_ACTIVITY_SOURCE', P_activity_source_code, 'EAM_ABO_INVALID_ACT_SRC_CODE');

	validate_acnt_class(p_class_code , P_CREATION_ORGANIZATION_ID );

	if p_start_date_active>p_end_date_active
	then
	      fnd_message.set_name('EAM', 'EAM_IAA_INVALID_ACTIVE_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

	if p_last_service_start_date > p_last_service_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

	if p_prev_service_start_date > p_prev_service_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

	if p_last_scheduled_start_date > p_last_scheduled_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;


	if p_prev_scheduled_start_date > p_prev_scheduled_end_date
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_START_END_DATE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END IF;

       validate_boolean_flag(p_tagging_required_flag, 'EAM_ABO_INVALID_TAG_REQ_FLAG');

	validate_boolean_flag(p_tmpl_flag, 'EAM_IAA_INV_TEML_FLAG');

	IF (p_owningdepartment_id is not null) THEN
	   l_validated := EAM_COMMON_UTILITIES_PVT.validate_department_id(p_owningdepartment_id, l_org_id);
	   IF NOT l_validated THEN
		raise_error ('EAM_ABO_INVALID_OWN_DEPT_ID');
	   END IF;
        END IF;

	validate_dff_segments(
				p_ATTRIBUTE_CATEGORY	,
				p_ATTRIBUTE1	,
				p_ATTRIBUTE2	,
				p_ATTRIBUTE3	,
				p_ATTRIBUTE4	,
				p_ATTRIBUTE5	,
				p_ATTRIBUTE6	,
				p_ATTRIBUTE7	,
				p_ATTRIBUTE8	,
				p_ATTRIBUTE9	,
				p_ATTRIBUTE10	,
				p_ATTRIBUTE11	,
				p_ATTRIBUTE12	,
				p_ATTRIBUTE13	,
				p_ATTRIBUTE14	,
				p_ATTRIBUTE15
			);


	--------------------------------------------------------------------------------------------
	IF ((p_maintenance_object_type is null or p_maintenance_object_id is null) and
	     (p_inventory_item_id is null)) THEN
	      fnd_message.set_name('EAM', 'EAM_NOT_ENOUGH_PARAM');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (p_maintenance_object_type is not null and p_maintenance_object_type NOT in (3,2)) THEN
	      fnd_message.set_name('EAM', 'EAM_INVALID_MAINT_OBJ_TYPE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_org_id := p_organization_id;
	l_asset_group_id := p_inventory_item_id;
	l_asset_number := p_serial_number;
        l_maintenance_object_type := p_maintenance_object_type;
	l_maintenance_object_id := p_maintenance_object_id;

	/* Validations for the item combinations supplied by the user */
	IF ( p_inventory_item_id IS NOT NULL and p_maintenance_object_id IS NULL ) THEN

		eam_common_utilities_pvt.translate_asset_maint_obj
		(
			P_ORGANIZATION_ID ,
			P_INVENTORY_ITEM_ID ,
			P_SERIAL_NUMBER ,
			l_object_found ,
			l_object_type ,
			l_object_id
		);

		IF (l_object_found) THEN
                       IF (l_maintenance_object_type is null) THEN
			  l_maintenance_object_type := l_object_type;
			END IF;
			IF (l_maintenance_object_id is null) THEN
			  l_maintenance_object_id := l_object_id;
			END IF;
		ELSE
			raise_error('EAM_NO_ITEM_FOUND');
		END IF;

	ELSIF ( (p_inventory_item_id IS NULL OR p_serial_number IS NULL)AND
	         p_maintenance_object_type IS NOT NULL AND p_maintenance_object_id IS NOT NULL) THEN

		eam_common_utilities_pvt.translate_maint_obj_asset
		(
			p_maintenance_object_type ,
			p_maintenance_object_id ,
			p_organization_id,
			l_object_found ,
			l_temp_org_id ,
			l_item_id ,
			l_serial_number
		);

		IF l_object_found THEN
		        IF (l_asset_group_id is null) THEN
			  l_asset_group_id := l_item_id;
			END IF;
			IF (l_asset_number is null) THEN
			  l_asset_number := l_serial_number;
			END IF;
			IF (l_org_id is null) THEN
			  l_org_id := l_temp_org_id;
			END IF;
		ELSE
			raise_error('EAM_NO_ITEM_FOUND');
		END IF;
        END IF;

	/* Check both the combinations are pointing to the same item / serial_number */
	l_validated := check_item_unique (
			l_maintenance_object_type ,
			l_maintenance_object_id ,
			l_asset_group_id ,
			l_org_id ,
			l_asset_number ,
			l_org_id
		);

	IF NOT l_validated THEN
		raise_error ('EAM_ABO_INVALID_INV_ITEM_ID');
	END IF;

	/* Template flag validation */
	begin

		SELECT msi.eam_item_type , msi.serial_number_control_code
		INTO l_item_type , l_ser_num_ctrl_cd
		FROM mtl_system_items_b msi, mtl_parameters mp
		WHERE msi.organization_id = mp.organization_id
		  AND mp.maint_organization_id = nvl(l_org_id, mp.maint_organization_id)
		  AND msi.inventory_item_id = l_asset_group_id
		  AND rownum = 1;

		if nvl (p_tmpl_flag , 'N') = 'Y' then
			if (l_maintenance_object_type = 3) then
				RAISE_ERROR ('EAM_IAA_INV_TEML_FLAG');
			end if;
			if (P_SOURCE_TMPL_ID is not null) then
				RAISE_ERROR ('EAM_SOURCE_TMPL_ID_NOT_NULL');
			end if;
			if ( l_item_type = 3 and l_ser_num_ctrl_cd = 1 )  then
				RAISE_ERROR ('EAM_NON_SERIAL_REBUILD_ASSOC');
			end if;
		else -- if non template record
			if (l_maintenance_object_type = 2) then
				if (NOT ( l_item_type = 3 and l_ser_num_ctrl_cd = 1 ))  then
					RAISE_ERROR ('EAM_IAA_INV_TEML_FLAG');
				end if;
			end if;
		end if;
	exception
		when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
	end;


	--------------------------------------------------------------------------------------------

	VALIDATE_ROW_EXISTS(p_asset_activity_id,
			    l_maintenance_object_id,
			    l_maintenance_object_type,
      			    p_tmpl_flag,
                            l_id);

	IF (l_id = -1) THEN
              fnd_message.set_name('EAM', 'EAM_ITEM_ACT_REC_NOT_FOUND');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	END IF;


        UPDATE mtl_eam_asset_activities
        SET
		START_DATE_ACTIVE	 =	P_START_DATE_ACTIVE	,
		END_DATE_ACTIVE	  	 =	P_END_DATE_ACTIVE	,
		PRIORITY_CODE	 	 =	P_PRIORITY_CODE	,
		ATTRIBUTE_CATEGORY	 =	P_ATTRIBUTE_CATEGORY	,
		ATTRIBUTE1	 	 =	P_ATTRIBUTE1	,
		ATTRIBUTE2	  	 =	P_ATTRIBUTE2	,
		ATTRIBUTE3	  	 =	P_ATTRIBUTE3	,
		ATTRIBUTE4	 	 =	P_ATTRIBUTE4	,
		ATTRIBUTE5	 	 =	P_ATTRIBUTE5	,
		ATTRIBUTE6	 	 =	P_ATTRIBUTE6	,
		ATTRIBUTE7	 	 =	P_ATTRIBUTE7	,
		ATTRIBUTE8	 	 =	P_ATTRIBUTE8	,
		ATTRIBUTE9	 	 =	P_ATTRIBUTE9	,
		ATTRIBUTE10	 	 =	P_ATTRIBUTE10	,
		ATTRIBUTE11	 	 =	P_ATTRIBUTE11	,
		ATTRIBUTE12	 	 =	P_ATTRIBUTE12	,
		ATTRIBUTE13	 	 =	P_ATTRIBUTE13	,
		ATTRIBUTE14	 	 =	P_ATTRIBUTE14	,
		ATTRIBUTE15	 	 =	P_ATTRIBUTE15	,
		LAST_SERVICE_START_DATE	 =	P_LAST_SERVICE_START_DATE	,
		LAST_SERVICE_END_DATE	 =	P_LAST_SERVICE_END_DATE	,
		PREV_SERVICE_START_DATE	 =	P_PREV_SERVICE_START_DATE	,
		PREV_SERVICE_END_DATE	 =	P_PREV_SERVICE_END_DATE	,
		LAST_SCHEDULED_START_DATE	 =	P_LAST_SCHEDULED_START_DATE	,
		LAST_SCHEDULED_END_DATE	 =	P_LAST_SCHEDULED_END_DATE	,
		PREV_SCHEDULED_START_DATE	 =	P_PREV_SCHEDULED_START_DATE	,
		PREV_SCHEDULED_END_DATE	 =	P_PREV_SCHEDULED_END_DATE	,
		WIP_ENTITY_ID            =      P_WIP_ENTITY_ID,
		LAST_UPDATE_LOGIN	 =	fnd_global.login_id	,
		LAST_UPDATE_DATE	 =	sysdate	,
		LAST_UPDATED_BY		 =	fnd_global.user_id

	WHERE ACTIVITY_ASSOCIATION_ID = P_ACTIVITY_ASSOCIATION_ID;

	IF (p_organization_Id IS NOT NULL) THEN

  	  IF p_maintenance_object_type = 2 THEN
	    l_object_type := 40;
	  ELSE
	    l_object_type := 60;
	  END IF;

	  eam_org_maint_defaults_pvt.update_insert_row
	    (
	      p_api_version           => 1.0
             ,p_commit                => p_commit
	     ,p_object_type           => l_object_type
	     ,p_object_id             => p_activity_association_id
	     ,p_organization_id       => p_organization_Id
	     ,p_owning_department_id  => p_owningdepartment_id
	     ,p_accounting_class_code => p_class_code
	     ,p_activity_cause_code   => p_activity_cause_code
	     ,p_activity_type_code    => p_activity_type_code
	     ,p_activity_source_code  => p_activity_source_code
	     ,p_shutdown_type_code    => p_shutdown_type_code
	     ,p_tagging_required_flag => p_tagging_required_flag
	     ,x_return_status         => x_return_status
	     ,x_msg_count             => x_msg_count
	     ,x_msg_data              => x_msg_data
	    );

	  IF x_return_status <> fnd_api.g_ret_sts_success THEN
	     RAISE fnd_api.g_exc_error;
	  END IF;

        END IF;

	IF p_pm_last_service_tbl.count >0
        THEN

	     IF (p_tmpl_flag = 'Y') THEN
	       raise_error('EAM_INVALID_METER_READING');
	     END IF;

             EAM_PM_LAST_SERVICE_PUB.process_pm_last_service
             (
			p_api_version      => p_api_version,
			p_init_msg_list    => FND_API.G_FALSE,--p_init_msg_list,
			p_commit	   => p_commit,
			p_validation_level => p_validation_level,
			x_return_status	   => x_return_status,
			x_msg_count        => x_msg_count,
			x_msg_data	   => x_msg_data,

			p_pm_last_service_tbl => p_pm_last_service_tbl,
			p_actv_assoc_id       => P_ACTIVITY_ASSOCIATION_ID
	       );

	      x_msg_count := FND_MSG_PUB.count_msg;
	      IF x_msg_count > 0 THEN
	         RAISE FND_API.G_EXC_ERROR;
	      END IF;
        END IF;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_ITEM_ACTIVITIES;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_ITEM_ACTIVITIES;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_ITEM_ACTIVITIES;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END update_item_activities;


END EAM_ITEM_ACTIVITIES_PUB;

/

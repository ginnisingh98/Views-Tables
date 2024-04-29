--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_LOG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_LOG_PUB" AS
/* $Header: EAMPALGB.pls 120.3 2005/11/10 23:23:59 jamulu noship $ */

/*
--Start of comments
--      API name        : EAM_ASSET_LOG_PUB
--      Type            : Public
--      Function        : Inserts Asset Log into EAM ASSET LOG Table
--      Pre-reqs        : None.
*/

    PROCEDURE LOG_EVENT(
		p_api_version			IN	number		:= 1.0,
		p_init_msg_list			IN      varchar2	:= fnd_api.g_false,
		p_commit			IN      varchar2	:= fnd_api.g_false,
		p_validation_level		IN      number		:= fnd_api.g_valid_level_full,
		p_event_date			IN      date		:= sysdate,
		p_event_type			IN      varchar2,
		p_event_id			IN      number,
		p_organization_id		IN	number		:= null,
		p_instance_id			IN      number		:= null,
		p_instance_number		IN      varchar2	:= null,
		p_comments			IN      varchar2	:= null,
		p_reference			IN      varchar2	:= null,
		p_ref_id			IN      number,
		p_operable_flag			IN      number		:= null,
		p_reason_code			IN      number		:= null,
		p_equipment_gen_object_id	IN      number		:= null,
		p_resource_id			IN      number		:= null,
		p_downcode			IN      number		:= null,
		p_employee_id			IN      number		:= null,
		p_department_id			IN      number		:= null,
		p_expected_up_date		IN      date		:= null,
		x_return_status         OUT NOCOPY	varchar2,
		x_msg_count		OUT NOCOPY      number,
		x_msg_data		OUT NOCOPY      varchar2)
    IS
		l_api_name                CONSTANT	varchar2(30)    :='EAM_ASSET_LOG_PUB';
		l_api_version             CONSTANT	number          := 1.0;
		l_association_id			number;
		l_validated				boolean;
		l_item_type				number;
		l_exists				boolean;
		l_instance_id				number;
		l_instance_number			varchar2(30);
		l_count					number;
		l_source_log_id				number;
		l_log_id				number		:=null;
		l_equipment_gen_object_id		number;
		l_organization_id			number		:=null;

		CURSOR cresid IS
			SELECT instance_id, instance_number
			  FROM csi_item_instances
			 WHERE equipment_gen_object_id = nvl(p_equipment_gen_object_id, equipment_gen_object_id) ;

		CURSOR corgid IS
		        SELECT mp.maint_organization_id
			  FROM csi_item_instances cii, mtl_parameters mp
			 WHERE cii.equipment_gen_object_id = nvl(p_equipment_gen_object_id, cii.equipment_gen_object_id)  AND
			       p_event_date BETWEEN active_start_date AND
			       NVL(active_end_date, SYSDATE) AND
			       cii.last_vld_organization_id = mp.organization_id;

    BEGIN
	/* Standard Start of API savepoint */
	SAVEPOINT EAM_ASSET_LOG_PUB_SV;

	/* Standard call to check for call compatibility. */
	IF NOT FND_API.Compatible_API_Call
			(       l_api_version                ,
				p_api_version                ,
				l_api_name                     ,
				G_PKG_NAME
			)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	/* Initialize message list if p_init_msg_list is set to TRUE. */
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	/* Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* API body */

	/* Start validation calls */
	/* Validation to prevent System Events Log through Public API calls */
		IF
			(p_event_type is null OR p_event_type NOT IN ('EAM_USER_EVENTS', 'EAM_OPERATIONAL_EVENTS'))
		THEN
		-- fnd_msg_pub.eventtype;
			fnd_message.set_name
					(  application  => 'EAM'
					 , name         => 'EAM_EVENT_TYPE_INVALID'
					 );
			fnd_msg_pub.add;
			x_return_status:= fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
					( p_count => x_msg_count,
					  p_data => x_msg_data
					);
			return;
		END IF;
	/* End validation calls */

	-- Default organization_id
	IF p_equipment_gen_object_id IS NULL THEN
		l_organization_id := p_organization_id;
	ELSE
		OPEN corgid;
		FETCH corgid  INTO l_organization_id;
			IF corgid%NOTFOUND THEN
				l_organization_id:=null;
			END IF;
		CLOSE corgid;
	END IF;

	/* For Multiple Record Situation*/

	BEGIN
		SELECT 1 INTO l_count
		  FROM csi_item_instances
		 WHERE equipment_gen_object_id = p_equipment_gen_object_id;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_count := 0;
		WHEN TOO_MANY_ROWS THEN
			l_count := 2;
	END;

	IF l_count = 0 THEN
		eam_asset_log_pvt.insert_row(
			p_event_date		=>	p_event_date,
			p_event_type		=>	p_event_type,
			p_event_id		=>	p_event_id,
			p_organization_id	=>	l_organization_id,
			p_instance_id		=>	l_instance_id,
			p_comments		=>	p_comments,
			p_reference		=>	p_reference,
			p_ref_id		=>	p_ref_id,
			p_operable_flag		=>	p_operable_flag,
			p_reason_code		=>	p_reason_code,
			p_resource_id		=>	p_resource_id,
			p_equipment_gen_object_id =>	p_equipment_gen_object_id,
			p_instance_number	=>	l_instance_number,
			p_downcode		=>	p_downcode,
			p_expected_up_date	=>	p_expected_up_date,
			p_employee_id		=>	p_employee_id,
			p_department_id		=>	p_department_id,
			x_return_status		=>	x_return_status,
			x_msg_count		=>	x_msg_count,
			x_msg_data		=>	x_msg_data
			);
	END IF;

	IF l_count > 1 THEN
	-- insert into log table with out asset id context and store the log id generated;

		SELECT eam_asset_log_s.NEXTVAL INTO l_log_id FROM DUAL;

		eam_asset_log_pvt.insert_row(
			p_log_id		=>	l_log_id,
			p_event_type		=>	p_event_type,
			p_event_id		=>	p_event_id,
			p_organization_id	=>	l_organization_id,
			p_instance_id		=>	p_instance_id,
			p_comments		=>	p_comments,
			p_reference		=>	p_reference,
			p_ref_id		=>	p_ref_id,
			p_operable_flag		=>	p_operable_flag,
			p_reason_code		=>	p_reason_code,
			p_resource_id		=>	p_resource_id,
			p_equipment_gen_object_id =>	p_equipment_gen_object_id,
			p_source_log_id		=>	null,
			p_expected_up_date	=>	p_expected_up_date,
			p_employee_id		=>	p_employee_id,
			p_department_id		=>	p_department_id,
			x_return_status		=>	x_return_status,
			x_msg_count		=>	x_msg_count,
			x_msg_data		=>	x_msg_data
			);

	END IF;

	FOR l_cresid IN cresid LOOP

		l_instance_id     := l_cresid.instance_id;
		l_instance_number := l_cresid.instance_number;

		-- Default organization_id
		IF p_equipment_gen_object_id IS NULL THEN
			l_organization_id := p_organization_id;
		ELSE
			OPEN corgid;
			FETCH corgid  INTO l_organization_id;
			IF corgid%NOTFOUND THEN
				l_organization_id:=null;
			END IF;
			CLOSE corgid;
		END IF;

	  IF 	   x_return_status = fnd_api.g_ret_sts_success 	THEN

		IF l_log_id IS NOT NULL THEN
		   l_equipment_gen_object_id := NULL;
		ELSE
		   l_equipment_gen_object_id := p_equipment_gen_object_id;
		END IF;

		eam_asset_log_pvt.insert_row(
			p_event_date		=>	p_event_date,
			p_event_type		=>	p_event_type,
			p_event_id		=>	p_event_id,
			p_organization_id	=>	l_organization_id,
			p_instance_id		=>	l_instance_id,
			p_comments		=>	p_comments,
			p_reference		=>	p_reference,
			p_ref_id		=>	p_ref_id,
			p_operable_flag		=>	p_operable_flag,
			p_reason_code		=>	p_reason_code,
			p_resource_id		=>	p_resource_id,
			p_equipment_gen_object_id =>	l_equipment_gen_object_id,
			p_source_log_id		=>	l_log_id,
			p_instance_number	=>	l_instance_number,
			p_downcode		=>	p_downcode,
			p_expected_up_date	=>	p_expected_up_date,
			p_employee_id		=>	p_employee_id,
			p_department_id		=>	p_department_id,
			x_return_status		=>	x_return_status,
			x_msg_count		=>	x_msg_count,
			x_msg_data		=>	x_msg_data
			);
	END IF;
	/* Standard check of p_commit. */

	/* For Multiple Record Situation*/

	END LOOP;

	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.GET
		(       p_msg_index_out          =>      x_msg_count ,
			p_data                   =>      x_msg_data
		);

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO EAM_ASSET_LOG_PUB_SV;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Get
			(       p_msg_index_out          =>      x_msg_count ,
				p_data                   =>      x_msg_data
			);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO EAM_ASSET_LOG_PUB_SV;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
			(       p_msg_index_out		 =>      x_msg_count ,
				p_data                   =>      x_msg_data
			);

		WHEN OTHERS THEN
		ROLLBACK TO EAM_ASSET_LOG_PUB_SV;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
				(       G_PKG_NAME ,
					l_api_name
				);
		END IF;

		FND_MSG_PUB.get
			(       p_msg_index_out          =>      x_msg_count ,
				p_data			 =>      x_msg_data
			);

    END LOG_EVENT;

END EAM_ASSET_LOG_PUB;

/

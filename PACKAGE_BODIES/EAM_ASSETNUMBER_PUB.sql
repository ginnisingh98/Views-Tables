--------------------------------------------------------
--  DDL for Package Body EAM_ASSETNUMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSETNUMBER_PUB" AS
/* $Header: EAMPASNB.pls 120.18.12010000.7 2009/10/27 02:34:31 jgootyag ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_AssetNumber_Pub';

PROCEDURE Insert_Asset_Number
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_object_id		OUT	NOCOPY 	NUMBER,
	p_INVENTORY_ITEM_ID	IN 	NUMBER,
	p_SERIAL_NUMBER		IN	VARCHAR2,
	p_INSTANCE_NUMBER	IN 	VARCHAR2,
	--p_INITIALIZATION_DATE	IN	DATE:=NULL,   -- always use sysdate
	p_CURRENT_STATUS	IN 	NUMBER:=3,
	p_DESCRIPTIVE_TEXT		IN	VARCHAR2:=NULL,
	p_CURRENT_ORGANIZATION_ID 	IN 	NUMBER,
	p_ATTRIBUTE_CATEGORY	IN	VARCHAR2:=NULL,
	p_ATTRIBUTE1		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE2		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE3		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE4		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE5		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE6		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE7		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE8		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE9		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE10		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE11		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE12		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE13		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE14		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE15		IN	VARCHAR2:=NULL,
	P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
        P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
	--p_STATUS_ID		IN 	NUMBER:=1,
	--p_PREVIOUS_STATUS		IN 	NUMBER:=NULL,
	p_WIP_ACCOUNTING_CLASS_CODE	IN	VARCHAR2:=NULL,
	p_MAINTAINABLE_FLAG		IN	VARCHAR2:=NULL,
	p_OWNING_DEPARTMENT_ID		IN 	NUMBER,
	p_NETWORK_ASSET_FLAG		IN	VARCHAR2:=NULL,
	p_FA_ASSET_ID			IN 	NUMBER:=NULL,
	p_PN_LOCATION_ID		IN 	NUMBER:=NULL,
	p_EAM_LOCATION_ID		IN 	NUMBER:=NULL,
	p_ASSET_CRITICALITY_CODE	IN	VARCHAR2:=NULL,
	p_CATEGORY_ID			IN 	NUMBER:=NULL,
	p_PROD_ORGANIZATION_ID 		IN 	NUMBER:=NULL,
	p_EQUIPMENT_ITEM_ID		IN 	NUMBER:=NULL,
	p_EQP_SERIAL_NUMBER		IN	VARCHAR2:=NULL,
	p_EQUIPMENT_GEN_OBJECT_ID	IN 	NUMBER,
       	p_instantiate_flag              IN      BOOLEAN:=FALSE,
	p_eam_linear_id			IN	NUMBER:=NULL
	,p_active_start_date	        DATE
	,p_active_end_date	        DATE
	,p_location		        NUMBER
	,p_operational_log_flag	  	VARCHAR2
	,p_checkin_status		NUMBER
	,p_supplier_warranty_exp_date   DATE
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Insert_Asset_Number';

l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_validate	boolean;
l_reason_failed varchar2(30);
l_gen_object_id number;
l_token varchar2(5000);
l_return_status varchar2(10);
errCode      NUMBER;
errMsg       VARCHAR2(4000);
errStmt      NUMBER;
errCount    	NUMBER;
l_count    	NUMBER;
l_instance_id	NUMBER;
l_x_return_status VARCHAR2(1);
l_x_msg_count	NUMBER;
l_x_msg_data	VARCHAR2(20000);
l_eam_item_type NUMBER;
l_current_status NUMBER;
l_serial_number_control_code NUMBER;
l_asset_meaning VARCHAR2(80);
l_rebuild_meaning VARCHAR2(80);
l_eqp_gen_obj_id NUMBER;
BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	 Insert_Asset_Number_Pub;
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
	-- Check the item type (Asset Group or Rebuildable)
	begin
		select eam_item_type,serial_number_control_code
		into l_eam_item_type, l_serial_number_control_code
		from mtl_system_items where inventory_item_id = p_inventory_item_id
		and organization_id = p_CURRENT_ORGANIZATION_ID;
	exception
		when no_data_found then
			add_error('EAM_GEN_INVALID_ITEM_TYPE');
			RAISE FND_API.G_EXC_ERROR;
	end;

	if (l_serial_number_control_code = 1 or l_serial_number_control_code = 6) then
		add_error('EAM_REB_INVALID_SERIAL_CONTROL');
		RAISE FND_API.G_EXC_ERROR;

	end if;

	-- select meaning for capital asset
	select meaning into l_asset_meaning
	from mfg_lookups
	where lookup_type = 'MTL_EAM_ASSET_TYPE'
	and lookup_code=1;

	--select meaning for rebuild asset
	select meaning into l_rebuild_meaning
	from mfg_lookups
	where lookup_type = 'MTL_EAM_ASSET_TYPE'
  	and lookup_code=3;

	-- validate the inventory item
	l_validate:= eam_common_utilities_pvt.validate_inventory_item_id
			(p_current_organization_id,
			p_inventory_item_id,
			l_eam_item_type);
	if (not l_validate) then
		add_error('EAM_ABO_INVALID_INV_ITEM');
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validate that the serial number does NOT already exist
	l_validate:=not (eam_common_utilities_pvt.validate_serial_number
			(p_current_organization_id,
			p_inventory_item_id,
			p_serial_number,
			l_eam_item_type));
	if (not l_validate) then
		add_error('EAM_ASSET_NUMBER_EXISTS');
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- Validate the serial uniqueness specified in the MTL Parameters
	eam_asset_number_pvt.serial_check(
	   p_api_version        => 1.0,
	   x_return_status      => l_return_status,
	   x_msg_count          => errCount,
	   x_msg_data           => errMsg,
	   x_errorcode          => errCode,
	   x_ser_num_in_item_id => l_validate,
	   p_inventory_item_id  => p_inventory_item_id,
	   p_organization_id    => p_current_organization_id,
	   p_serial_number      => p_serial_number
	);

	if l_return_status <> 'S' then
	   if (l_validate = TRUE) then
	      fnd_message.set_name('EAM','EAM_SER_UNIQ2');
	      fnd_message.set_token('NAME',p_serial_number);
              fnd_msg_pub.add;
              raise FND_API.G_EXC_ERROR;
	   else
	      fnd_message.set_name('EAM','EAM_SER_UNIQ1');
	      fnd_message.set_token('NAME',p_serial_number);
              fnd_msg_pub.add;
              raise FND_API.G_EXC_ERROR;
           end if;
        end if;

	-- validate that the current status is 3
	/*l_validate:=(p_current_status=3);
	if (not l_validate) then
		add_error('EAM_CURRENT_STATUS');
		RAISE FND_API.G_EXC_ERROR;
	end if;
	*/

	-- validate all the other fields
	l_validate:=validate_fields(
		p_CURRENT_ORGANIZATION_ID => p_CURRENT_ORGANIZATION_ID,
		p_INVENTORY_ITEM_ID => p_INVENTORY_ITEM_ID,
		p_SERIAL_NUMBER => p_SERIAL_NUMBER,
        	p_WIP_ACCOUNTING_CLASS_CODE => p_WIP_ACCOUNTING_CLASS_CODE,
        	p_MAINTAINABLE_FLAG => p_MAINTAINABLE_FLAG            ,
        	p_OWNING_DEPARTMENT_ID => p_OWNING_DEPARTMENT_ID,
        	p_NETWORK_ASSET_FLAG => p_NETWORK_ASSET_FLAG,
        	p_FA_ASSET_ID        => p_FA_ASSET_ID       ,
        	p_PN_LOCATION_ID      => p_PN_LOCATION_ID   ,
        	p_EAM_LOCATION_ID      => p_EAM_LOCATION_ID ,
        	p_ASSET_CRITICALITY_CODE => p_ASSET_CRITICALITY_CODE,
        	p_CATEGORY_ID         => p_CATEGORY_ID        ,
        	p_PROD_ORGANIZATION_ID => p_PROD_ORGANIZATION_ID ,
        	p_EQUIPMENT_ITEM_ID => p_EQUIPMENT_ITEM_ID,
        	p_EQP_SERIAL_NUMBER => p_EQP_SERIAL_NUMBER,
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
		p_EAM_LINEAR_ID	  => p_eam_linear_id,
		p_equipment_object_id => p_EQUIPMENT_GEN_OBJECT_ID
		,p_operational_log_flag	=> p_operational_log_flag
		,p_checkin_status	=> p_checkin_status
  		,p_supplier_warranty_exp_date => p_supplier_warranty_exp_date
        	,x_reason_failed => l_reason_failed ,
		x_token => l_token
		);

        if (not l_validate) then
                FND_MESSAGE.SET_NAME('EAM', l_reason_failed);
                if (l_reason_failed='EAM_INVALID_DESC_FLEX') then
                        FND_MESSAGE.SET_TOKEN('ERROR_MSG', l_token);
                elsif (l_reason_failed = 'EAM_REB_NETWORK_INVALID') then
                	FND_MESSAGE.SET_TOKEN('ASSET',l_rebuild_meaning);
                 elsif (l_reason_failed = 'EAM_REB_INVALID_PN_LOC') then
                	FND_MESSAGE.SET_TOKEN('ASSET',l_rebuild_meaning);
                end if;
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        end if;

	-- Bug # 4770445 : Need to check if p_eam_linear_id is null or not

	IF (p_eam_linear_id IS NOT NULL) THEN
	   -- Check if eam_linear_id already exists in MSN
   	   SELECT count(*) INTO l_count FROM csi_item_instances
   	   WHERE linear_location_id = p_eam_linear_id AND ROWNUM = 1;

	   IF (l_count > 0) THEN
             FND_MESSAGE.SET_NAME('EAM', 'EAM_LINEAR_ID_EXISTS_IN_MSN');
	     FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
	   END IF;
        END IF;

		-- For Bug 9048751
    IF  (p_EQP_SERIAL_NUMBER IS NOT NULL AND p_EQUIPMENT_ITEM_ID IS NOT NULL AND p_PROD_ORGANIZATION_ID IS NOT NULL) THEN

           SELECT gen_object_id INTO l_eqp_gen_obj_id
           FROM mtl_serial_numbers
           WHERE serial_number= p_EQP_SERIAL_NUMBER
           AND inventory_item_id = p_EQUIPMENT_ITEM_ID
           AND current_organization_id = p_PROD_ORGANIZATION_ID;

        END IF;

	eam_asset_number_pvt.create_asset
	(
	      	 P_API_VERSION                => P_API_VERSION
	      	 ,p_init_msg_list	=> p_init_msg_list
	      	 ,p_commit	    	=> p_commit
		 ,p_validation_level	=> p_validation_level
	         ,P_INVENTORY_ITEM_ID         => P_INVENTORY_ITEM_ID
	      	 ,P_SERIAL_NUMBER             => P_SERIAL_NUMBER
	      	 ,P_INSTANCE_NUMBER	      => nvl(p_instance_number,p_serial_number)
	      	 ,P_INSTANCE_DESCRIPTION      => p_descriptive_text
	         ,P_ORGANIZATION_ID           => P_CURRENT_ORGANIZATION_ID
	         ,P_CATEGORY_ID               => P_CATEGORY_ID
	      	 ,P_PN_LOCATION_ID            => P_PN_LOCATION_ID
	      	 ,P_FA_ASSET_ID               => P_FA_ASSET_ID
	      	 ,P_ASSET_CRITICALITY_CODE    => P_ASSET_CRITICALITY_CODE
	      	 ,P_MAINTAINABLE_FLAG         => P_MAINTAINABLE_FLAG
	      	 ,P_NETWORK_ASSET_FLAG        => P_NETWORK_ASSET_FLAG
	      	 ,P_ATTRIBUTE_CATEGORY        => P_ATTRIBUTE_CATEGORY
	      	 ,P_ATTRIBUTE1                =>    P_ATTRIBUTE1
	      	 ,P_ATTRIBUTE2                =>    P_ATTRIBUTE2
	      	 ,P_ATTRIBUTE3                =>    P_ATTRIBUTE3
	      	 ,P_ATTRIBUTE4                =>    P_ATTRIBUTE4
	      	 ,P_ATTRIBUTE5                =>    P_ATTRIBUTE5
	      	 ,P_ATTRIBUTE6                =>    P_ATTRIBUTE6
	      	 ,P_ATTRIBUTE7                =>    P_ATTRIBUTE7
	      	 ,P_ATTRIBUTE8                =>    P_ATTRIBUTE8
	      	 ,P_ATTRIBUTE9                =>    P_ATTRIBUTE9
	      	 ,P_ATTRIBUTE10               =>    P_ATTRIBUTE10
	      	 ,P_ATTRIBUTE11               =>    P_ATTRIBUTE11
	      	 ,P_ATTRIBUTE12               =>    P_ATTRIBUTE12
	      	 ,P_ATTRIBUTE13               =>    P_ATTRIBUTE13
	      	 ,P_ATTRIBUTE14               =>    P_ATTRIBUTE14
	      	 ,P_ATTRIBUTE15               =>    P_ATTRIBUTE15
	      	 ,P_ATTRIBUTE16               =>    P_ATTRIBUTE16
	      	 ,P_ATTRIBUTE17               =>    P_ATTRIBUTE17
	      	 ,P_ATTRIBUTE18               =>    P_ATTRIBUTE18
	      	 ,P_ATTRIBUTE19               =>    P_ATTRIBUTE19
	      	 ,P_ATTRIBUTE20               =>    P_ATTRIBUTE20
	      	 ,P_ATTRIBUTE21               =>    P_ATTRIBUTE21
	      	 ,P_ATTRIBUTE22               =>    P_ATTRIBUTE22
	      	 ,P_ATTRIBUTE23               =>    P_ATTRIBUTE23
	      	 ,P_ATTRIBUTE24               =>    P_ATTRIBUTE24
	      	 ,P_ATTRIBUTE25               =>    P_ATTRIBUTE25
	      	 ,P_ATTRIBUTE26              =>     P_ATTRIBUTE26
	      	 ,P_ATTRIBUTE27              =>     P_ATTRIBUTE27
	      	 ,P_ATTRIBUTE28              =>     P_ATTRIBUTE28
	      	 ,P_ATTRIBUTE29              =>     P_ATTRIBUTE29
	      	 ,P_ATTRIBUTE30              =>     P_ATTRIBUTE30
		 ,P_LAST_UPDATE_DATE         =>     SYSDATE
		 ,P_LAST_UPDATED_BY          =>     FND_GLOBAL.LOGIN_ID
		 ,P_CREATION_DATE            =>     SYSDATE
		 ,P_CREATED_BY               =>     FND_GLOBAL.USER_ID
		 ,P_LAST_UPDATE_LOGIN        =>     FND_GLOBAL.LOGIN_ID
		 ,p_active_start_date	     =>	  SYSDATE
		 ,p_active_end_date	     =>  NULL
		 ,p_location		     =>  NULL
		 ,p_linear_location_id	     =>	  p_eam_linear_id
		 ,p_operational_log_flag     =>	  p_operational_log_flag
		 ,p_checkin_status	=>	  p_checkin_status
		 ,p_supplier_warranty_exp_date =>   p_supplier_warranty_exp_date
		 ,p_equipment_gen_object_id  =>   l_eqp_gen_obj_id
		 ,p_owning_department_id =>  p_owning_department_id
		 ,p_accounting_class_code => p_WIP_ACCOUNTING_CLASS_CODE
		 ,p_area_id		=> P_EAM_LOCATION_ID
		 ,X_OBJECT_ID 		=> l_instance_id
		 ,X_RETURN_STATUS 	=> l_X_RETURN_STATUS
		 ,X_MSG_COUNT 		=> l_X_MSG_COUNT
		 ,X_MSG_DATA 		=> l_X_MSG_DATA
	);

	-- instantiate
	if (l_X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS) then
		RAISE FND_API.G_EXC_ERROR;
	end if;

	if (p_instantiate_flag = TRUE) then
		EAM_ObjectInstantiation_Pub.Instantiate_Object
		(
			p_api_version => 1.0,
		        P_init_msg_list => null,
		       	P_commit        => null,
		     	P_validation_level => null,
			x_return_status => l_return_status,
			x_msg_count => errCount,
			x_msg_data => errMsg,
			p_maintenance_object_id => l_instance_id,
			p_maintenance_object_type => 3
		);

		if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                	FND_MESSAGE.SET_NAME('EAM', 'EAM_INSTANTIATE_OBJECT_FAILED');
                	FND_MSG_PUB.Add;
                	RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

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
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  Insert_Asset_Number_Pub;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Insert_Asset_Number_Pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO  Insert_Asset_Number_Pub;
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
END  Insert_Asset_Number;



PROCEDURE Update_Asset_Number
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	--p_GEN_OBJECT_ID		IN  	NUMBER:=NULL,
	p_INVENTORY_ITEM_ID	IN 	NUMBER,
	p_SERIAL_NUMBER		IN	VARCHAR2,
	p_INSTANCE_NUMBER	IN 	VARCHAR2,
	P_INSTANCE_ID		IN 	NUMBER,
	--p_INITIALIZATION_DATE	IN	DATE:=NULL,
	p_CURRENT_STATUS	IN 	NUMBER:=3,
	p_DESCRIPTIVE_TEXT		IN	VARCHAR2:=NULL,
	p_CURRENT_ORGANIZATION_ID 	IN 	NUMBER,
	p_ATTRIBUTE_CATEGORY	IN	VARCHAR2:=NULL,
	p_ATTRIBUTE1		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE2		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE3		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE4		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE5		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE6		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE7		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE8		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE9		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE10		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE11		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE12		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE13		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE14		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE15		IN	VARCHAR2:=NULL,
	P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
        P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
	--p_STATUS_ID		IN 	NUMBER:=1,
	--p_PREVIOUS_STATUS		IN 	NUMBER:=NULL,
	p_WIP_ACCOUNTING_CLASS_CODE	IN	VARCHAR2:=NULL,
	p_MAINTAINABLE_FLAG		IN	VARCHAR2:=NULL,
	p_OWNING_DEPARTMENT_ID		IN 	NUMBER,
	p_NETWORK_ASSET_FLAG		IN	VARCHAR2:=NULL,
	p_FA_ASSET_ID			IN 	NUMBER:=NULL,
	p_PN_LOCATION_ID		IN 	NUMBER:=NULL,
	p_EAM_LOCATION_ID		IN 	NUMBER:=NULL,
	p_ASSET_CRITICALITY_CODE	IN	VARCHAR2:=NULL,
	p_CATEGORY_ID			IN 	NUMBER:=NULL,
	p_PROD_ORGANIZATION_ID 		IN 	NUMBER:=NULL,
	p_EQUIPMENT_ITEM_ID		IN 	NUMBER:=NULL,
	p_EQP_SERIAL_NUMBER		IN	VARCHAR2:=NULL,
	p_EAM_LINEAR_ID			IN	NUMBER:=NULL
	,P_LOCATION_TYPE_CODE		IN	VARCHAR2:=NULL
	,P_LOCATION_ID			IN	NUMBER:=NULL
	,P_ACTIVE_END_DATE		IN 	DATE:=NULL
	,P_OPERATIONAL_LOG_FLAG	  	IN	VARCHAR2
	,P_CHECKIN_STATUS		IN 	NUMBER
	,P_SUPPLIER_WARRANTY_EXP_DATE	IN	DATE
	,P_EQUIPMENT_GEN_OBJECT_ID	IN	NUMBER
	,P_DISASSOCIATE_FA_FLAG		IN	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_Asset_Number';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_validate	boolean;
l_reason_failed varchar2(30);
l_old_current_status number;
l_token varchar2(5000);
l_count NUMBER;

l_inventory_item_id	NUMBER;
l_serial_number		VARCHAR2(30);
l_organization_id	NUMBER;
l_instance_id		NUMBER;
l_eam_item_type NUMBER;
l_asset_meaning VARCHAR2(80);
l_rebuild_meaning VARCHAR2(80);
l_eqp_gen_obj_id NUMBER;
BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Update_Asset_Number_Pub;
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

	-- Check the item type (Asset Group or Rebuildable)
	begin
		select eam_item_type into l_eam_item_type
		from mtl_system_items where inventory_item_id = p_inventory_item_id
		and organization_id = p_CURRENT_ORGANIZATION_ID;
	exception
			when no_data_found then
				add_error('EAM_GEN_INVALID_ITEM_TYPE');
				RAISE FND_API.G_EXC_ERROR;
	end;

	-- select meaning for capital asset
	select meaning into l_asset_meaning
	from mfg_lookups
	where lookup_type = 'MTL_EAM_ASSET_TYPE'
	and lookup_code=1;

	--select meaning for rebuild asset
	select meaning into l_rebuild_meaning
	from mfg_lookups
	where lookup_type = 'MTL_EAM_ASSET_TYPE'
  	and lookup_code=3;

	if (p_instance_id is not null) then
		select last_vld_organization_id,inventory_item_id,serial_number
		into l_organization_id,l_inventory_item_id,l_serial_number
		from csi_item_instances
		where instance_id = p_instance_id;
	elsif	(p_instance_number is not null) then
		select last_vld_organization_id,inventory_item_id,serial_number
		into l_organization_id,l_inventory_item_id,l_serial_number
		from csi_item_instances
		where instance_number = p_instance_number;
	end if;

	if (p_inventory_item_id is not null AND p_serial_number is not null) then
		select instance_id,last_vld_organization_id
		into l_instance_id,l_organization_id
		from csi_item_instances
		where serial_number = p_serial_number
		and inventory_item_id = p_inventory_item_id;
	end if;

	if (l_instance_id = null) then
                add_error('EAM_ASSET_NUMBER_NOT_EXIST');
                RAISE FND_API.G_EXC_ERROR;
        end if;


	-- validate all the other fields
	l_validate:=validate_fields(
		p_CURRENT_ORGANIZATION_ID => p_CURRENT_ORGANIZATION_ID,
		p_INVENTORY_ITEM_ID => p_INVENTORY_ITEM_ID,
		p_SERIAL_NUMBER => p_SERIAL_NUMBER,
        	p_WIP_ACCOUNTING_CLASS_CODE => p_WIP_ACCOUNTING_CLASS_CODE,
        	p_MAINTAINABLE_FLAG => p_MAINTAINABLE_FLAG            ,
        	p_OWNING_DEPARTMENT_ID => p_OWNING_DEPARTMENT_ID,
        	p_NETWORK_ASSET_FLAG => p_NETWORK_ASSET_FLAG,
        	p_FA_ASSET_ID        => p_FA_ASSET_ID       ,
        	p_PN_LOCATION_ID      => p_PN_LOCATION_ID   ,
        	p_EAM_LOCATION_ID      => p_EAM_LOCATION_ID ,
        	p_ASSET_CRITICALITY_CODE => p_ASSET_CRITICALITY_CODE,
        	p_CATEGORY_ID         => p_CATEGORY_ID        ,
        	p_PROD_ORGANIZATION_ID => p_PROD_ORGANIZATION_ID ,
        	p_EQUIPMENT_ITEM_ID => p_EQUIPMENT_ITEM_ID,
        	p_EQP_SERIAL_NUMBER => p_EQP_SERIAL_NUMBER,
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
		p_EAM_LINEAR_ID	  => p_eam_linear_id
		,p_equipment_object_id => p_EQUIPMENT_GEN_OBJECT_ID
		,p_operational_log_flag	=> p_operational_log_flag
		,p_checkin_status	=> p_checkin_status
  		,p_supplier_warranty_exp_date => p_supplier_warranty_exp_date
        	,x_reason_failed => l_reason_failed ,
		x_token => l_token
		);

	if (not l_validate) then
		--add_error(l_reason_failed);
		FND_MESSAGE.SET_NAME('EAM', l_reason_failed);
		if (l_reason_failed='EAM_INVALID_DESC_FLEX') then
			FND_MESSAGE.SET_TOKEN('ERROR_MSG', l_token);
		elsif (l_reason_failed = 'EAM_REB_NETWORK_INVALID') then
			FND_MESSAGE.SET_TOKEN('ASSET',l_rebuild_meaning);
		elsif (l_reason_failed = 'EAM_REB_INVALID_PN_LOC') then
                	FND_MESSAGE.SET_TOKEN('ASSET',l_rebuild_meaning);
		end if;
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- Bug # 4770445 : Need to check if p_eam_linear_id is null or not
	IF (p_eam_linear_id IS NOT NULL AND p_eam_linear_id <> fnd_api.g_miss_num) THEN
   	   -- Check if eam_linear_id already exists in MSN
   	   SELECT count(*) INTO l_count FROM csi_item_instances
	    WHERE linear_location_id = p_eam_linear_id
	      AND instance_id <> l_instance_id AND ROWNUM = 1;

   	   IF (l_count > 0) THEN
             FND_MESSAGE.SET_NAME('EAM', 'EAM_LINEAR_ID_EXISTS_IN_MSN');
	     FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
	   END IF;
        END IF;

	-- check if asset is being de-activated
	if (p_active_end_date is not null or p_active_end_date <> fnd_api.g_miss_date) then
		begin
			select current_status
			into l_old_current_status
			from mtl_serial_numbers
			where inventory_item_id = l_inventory_item_id
			and serial_number = l_serial_number
			and rownum <= 1;

		exception
			when no_data_found then
				null;
		end;

		if (l_old_current_status = 3) then
			FND_MESSAGE.SET_NAME('EAM','EAM_ASSET_IN_INVENTORY');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

	-- For Bug 9048751
    IF  (p_EQP_SERIAL_NUMBER IS NOT NULL AND p_EQUIPMENT_ITEM_ID IS NOT NULL AND p_PROD_ORGANIZATION_ID IS NOT NULL) THEN

           SELECT gen_object_id INTO l_eqp_gen_obj_id
           FROM mtl_serial_numbers
           WHERE serial_number= p_EQP_SERIAL_NUMBER
           AND inventory_item_id = p_EQUIPMENT_ITEM_ID
           AND current_organization_id = p_PROD_ORGANIZATION_ID;

        END IF;

	EAM_ASSET_NUMBER_PVT.update_asset
	(
		P_API_VERSION                => 1.0
		,P_INSTANCE_ID     	     => l_instance_id
		,P_INSTANCE_DESCRIPTION      => P_DESCRIPTIVE_TEXT
		,P_INVENTORY_ITEM_ID	     => p_inventory_item_id
		,P_SERIAL_NUMBER	     => p_serial_number
		,P_ORGANIZATION_ID	     => l_organization_id
		,P_CATEGORY_ID               => P_CATEGORY_ID
		,P_PN_LOCATION_ID            => P_PN_LOCATION_ID
		,P_FA_ASSET_ID               => P_FA_ASSET_ID
		,P_ASSET_CRITICALITY_CODE    => P_ASSET_CRITICALITY_CODE
		,P_MAINTAINABLE_FLAG         => P_MAINTAINABLE_FLAG
		,P_NETWORK_ASSET_FLAG        => P_NETWORK_ASSET_FLAG
		,P_ATTRIBUTE_CATEGORY        => P_ATTRIBUTE_CATEGORY
		,P_ATTRIBUTE1                =>    P_ATTRIBUTE1
		,P_ATTRIBUTE2                =>    P_ATTRIBUTE2
		,P_ATTRIBUTE3                =>    P_ATTRIBUTE3
		,P_ATTRIBUTE4                =>    P_ATTRIBUTE4
		,P_ATTRIBUTE5                =>    P_ATTRIBUTE5
		,P_ATTRIBUTE6                =>    P_ATTRIBUTE6
		,P_ATTRIBUTE7                =>    P_ATTRIBUTE7
		,P_ATTRIBUTE8                =>    P_ATTRIBUTE8
		,P_ATTRIBUTE9                =>    P_ATTRIBUTE9
		,P_ATTRIBUTE10               =>    P_ATTRIBUTE10
		,P_ATTRIBUTE11               =>    P_ATTRIBUTE11
		,P_ATTRIBUTE12               =>    P_ATTRIBUTE12
		,P_ATTRIBUTE13               =>    P_ATTRIBUTE13
		,P_ATTRIBUTE14               =>    P_ATTRIBUTE14
		,P_ATTRIBUTE15               =>    P_ATTRIBUTE15
		,P_ATTRIBUTE16               =>    P_ATTRIBUTE16
		,P_ATTRIBUTE17               =>    P_ATTRIBUTE17
		,P_ATTRIBUTE18               =>    P_ATTRIBUTE18
		,P_ATTRIBUTE19               =>    P_ATTRIBUTE19
		,P_ATTRIBUTE20               =>    P_ATTRIBUTE20
		,P_ATTRIBUTE21               =>    P_ATTRIBUTE21
		,P_ATTRIBUTE22               =>    P_ATTRIBUTE22
		,P_ATTRIBUTE23               =>    P_ATTRIBUTE23
		,P_ATTRIBUTE24               =>    P_ATTRIBUTE24
		,P_ATTRIBUTE25               =>    P_ATTRIBUTE25
		,P_ATTRIBUTE26              =>     P_ATTRIBUTE26
		,P_ATTRIBUTE27              =>     P_ATTRIBUTE27
		,P_ATTRIBUTE28              =>     P_ATTRIBUTE28
		,P_ATTRIBUTE29              =>     P_ATTRIBUTE29
		,P_ATTRIBUTE30              =>     P_ATTRIBUTE30
		,P_LAST_UPDATE_DATE         =>     SYSDATE
		,P_LAST_UPDATED_BY          =>     FND_GLOBAL.LOGIN_ID
		,P_LAST_UPDATE_LOGIN        =>     FND_GLOBAL.LOGIN_ID
		,P_FROM_PUBLIC_API	     =>  'Y'
		,P_INSTANCE_NUMBER	     =>	  P_INSTANCE_NUMBER
		,P_LOCATION_TYPE_CODE	     => P_LOCATION_TYPE_CODE
		,P_LOCATION_ID		     => P_LOCATION_ID
		,p_active_end_date	     => P_ACTIVE_END_DATE
		,p_linear_location_id	     => P_EAM_LINEAR_ID
		,p_operational_log_flag	     => P_OPERATIONAL_LOG_FLAG
		,p_checkin_status	     => P_CHECKIN_STATUS
		,p_supplier_warranty_exp_date  => P_SUPPLIER_WARRANTY_EXP_DATE
		,p_equipment_gen_object_id   	=> l_eqp_gen_obj_id
		,p_owning_department_id	     => p_owning_department_id
		,p_accounting_class_code     => p_wip_accounting_class_code
		,p_area_id		     => p_eam_location_id
		,p_disassociate_fa_flag      => p_disassociate_fa_flag
		,X_RETURN_STATUS             => x_return_status
		,X_MSG_COUNT                 => x_msg_count
		,X_MSG_DATA                  => x_msg_data
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
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Asset_Number_Pub;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Asset_Number_Pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Asset_Number_Pub;
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
END Update_Asset_Number;


function validate_fields
(
        p_CURRENT_ORGANIZATION_ID       IN      number,
        p_INVENTORY_ITEM_ID             IN      number,
        p_SERIAL_NUMBER                 IN      varchar2,
        p_WIP_ACCOUNTING_CLASS_CODE     IN      VARCHAR2:=NULL,
        p_MAINTAINABLE_FLAG             IN      VARCHAR2:=NULL,
        p_OWNING_DEPARTMENT_ID          IN      NUMBER,
        p_NETWORK_ASSET_FLAG            IN      VARCHAR2:=NULL,
        p_FA_ASSET_ID                   IN      NUMBER:=NULL,
        p_PN_LOCATION_ID                IN      NUMBER:=NULL,
        p_EAM_LOCATION_ID               IN      NUMBER:=NULL,
        p_ASSET_CRITICALITY_CODE        IN      VARCHAR2:=NULL,
        p_CATEGORY_ID                   IN      NUMBER:=NULL,
        p_PROD_ORGANIZATION_ID          IN      NUMBER:=NULL,
        p_EQUIPMENT_ITEM_ID             IN      NUMBER:=NULL,
        p_EQP_SERIAL_NUMBER             IN      VARCHAR2:=NULL,
        p_ATTRIBUTE_CATEGORY    IN      VARCHAR2:=NULL,
        p_ATTRIBUTE1            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE2            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE3            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE4            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE5            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE6            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE7            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE8            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE9            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE10           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE11           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE12           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE13           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE14           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE15           IN      VARCHAR2:=NULL,
	p_EAM_LINEAR_ID		IN	NUMBER:=NULL,
	p_equipment_object_id	IN	NUMBER := NULL,
	p_operational_log_flag	IN      VARCHAR2 := NULL,
	p_checkin_status	IN      NUMBER := NULL,
  	p_supplier_warranty_exp_date IN     DATE := NULL,
        x_reason_failed                 OUT     NOCOPY VARCHAR2,
	x_token				OUT NOCOPY VARCHAR2
)
return boolean
is
	l_validate boolean;
	l_count number;
	l_org number;
	l_instance_id number;
	l_old_maint_flag varchar2(1);
	l_old_network_asset_flag varchar2(1);
	l_prod_equipment_type number;
	l_category_set_id number;
	l_prod_null boolean;
        l_error_segments number;
        l_error_message varchar2(1200);
        l_prod_organization_id	NUMBER;
	l_prod_inventory_item_id NUMBER;
	l_prod_serial_number	VARCHAR2(30);
	l_eam_item_type number;

begin
	select eam_item_type
	into l_eam_item_type
        from mtl_system_items
        where inventory_item_id = p_INVENTORY_ITEM_ID
  	and organization_id = p_CURRENT_ORGANIZATION_ID;

	BEGIN
            SELECT cii.instance_id, nvl(cii.maintainable_flag, 'Y'), nvl(cii.network_asset_flag, 'N'), mp.maint_organization_id
	      INTO l_instance_id, l_old_maint_flag, l_old_network_asset_flag, l_org
	      FROM csi_item_instances cii, mtl_parameters mp
             WHERE cii.serial_number = p_serial_number
	       AND cii.inventory_item_id = p_inventory_item_id
	       AND cii.last_vld_organization_id = p_current_organization_id
	       AND cii.last_vld_organization_id = mp.organization_id;

        EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       l_old_network_asset_flag := p_network_asset_flag ;
	END;

  -- validate the boolean flags
  if (p_maintainable_flag is not null and p_maintainable_flag <> fnd_api.g_miss_char) then
	l_validate:=eam_common_utilities_pvt.validate_boolean_flag
		(p_maintainable_flag);
	if (not l_validate) then
		x_reason_failed:='EAM_MAINTAINABLE_FLAG_INVALID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;

	/* Bug # 4768635 : Validate if Maintainable)_flag can be 'N' */
	IF (p_maintainable_flag = 'N' AND l_old_maint_flag = 'Y') THEN
	 BEGIN
              SELECT 1 INTO l_count
  	        FROM DUAL
               WHERE EXISTS
                     (SELECT wdj.wip_entity_id
                        FROM wip_discrete_jobs wdj
                       WHERE wdj.status_type not in (4, 5, 7, 12)
                         AND wdj.maintenance_object_id = l_instance_id
                         AND wdj.maintenance_object_type = 3
                         AND wdj.organization_id = l_org)
                  OR EXISTS
                     (SELECT wewr.asset_number
                        FROM wip_eam_work_requests wewr
                       WHERE wewr.work_request_status_id not in (4, 5, 6)
                         AND wewr.organization_id = l_org
                         AND wewr.maintenance_object_id = l_instance_id
                         AND wewr.maintenance_object_type = 3);
	    IF l_count = 1 then
              x_reason_failed:='EAM_WO_EXIST';
 	      fnd_message.set_name('EAM',x_reason_failed);
              fnd_msg_pub.add;
              return false;
	    END IF;
    	  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	     NULL;
	  END;
	END IF;

  end if;

  if (p_network_asset_flag is not null and p_network_asset_flag <> fnd_api.g_miss_char) then

  	if (l_eam_item_type = 1) then
		l_validate:=eam_common_utilities_pvt.validate_boolean_flag
			(p_network_asset_flag);
		if ( (not l_validate) or (p_network_asset_flag <> l_old_network_asset_flag) ) then
			x_reason_failed:='EAM_NETWORK_ASSET_INVALID';
			fnd_message.set_name('EAM',x_reason_failed);
	       	 	fnd_msg_pub.add;
			return false;
		end if;
	else
		if (p_network_asset_flag = 'Y') then
			x_reason_failed:='EAM_REB_NETWORK_INVALID';
			return false;
		end if;
	end if;
  end if;


  --validate linear id
if (p_EAM_LINEAR_ID is not null and p_EAM_LINEAR_ID <> fnd_api.g_miss_num) then
	l_validate := eam_common_utilities_pvt.validate_linear_id
		(p_EAM_LINEAR_ID);

		if (not l_validate) then
		x_reason_failed:='EAM_INVALID_EAM_LINEAR_ID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;
end if;


  -- validate department id
/*
  if (p_owning_department_id is null) then
	x_reason_failed:='EAM_DEPT_ID_NULL';
 	return false;
*/
  if (p_owning_department_id is not null and p_owning_department_id <> fnd_api.g_miss_num) then
	l_validate:=eam_common_utilities_pvt.validate_department_id
		(p_owning_department_id,
		p_current_organization_id);
	if (not l_validate) then
		x_reason_failed:='EAM_DEPT_ID_INVALID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;
  end if;

  -- validate wip_accounting_class_code
  if (p_wip_accounting_class_code is not null and p_wip_accounting_class_code <> fnd_api.g_miss_char) then
	l_validate:=eam_common_utilities_pvt.validate_wip_acct_class_code
		(p_current_organization_id,
		p_wip_accounting_class_code);
	if (not l_validate) then
		x_reason_failed:='EAM_WIP_ACCT_CLASS_INVALID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;
  end if;

  -- validate criticality code
  if (p_asset_criticality_code is not null and p_asset_criticality_code <> fnd_api.g_miss_char) then
	l_validate:=eam_common_utilities_pvt.validate_mfg_lookup_code
		('MTL_EAM_ASSET_CRITICALITY',
		p_asset_criticality_code);
	if (not l_validate) then
		x_reason_failed:='EAM_ASSET_CRITICALITY_INVALID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;
  end if;

  -- validate location_id
  if (p_eam_location_id is not null and p_eam_location_id <> fnd_api.g_miss_num) then
	l_validate:=eam_common_utilities_pvt.validate_eam_location_id_asset
		(p_current_organization_id,
		p_eam_location_id);
	if (not l_validate) then
		x_reason_failed:='EAM_LOCATION_ID_INVALID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;
  end if;

  -- validate category_id
  if (p_category_id is not null and p_category_id <> fnd_api.g_miss_num) then
  	l_category_set_id := 1000000014;

	SELECT  count(*) into l_count
        FROM  MTL_ITEM_CATEGORIES
        WHERE category_id = p_category_id
        AND inventory_item_id = p_inventory_item_id
        AND organization_id =  p_current_organization_id
        AND category_set_id = l_category_set_id;

	l_validate:=(l_count>0);

	if (not l_validate) then
		x_reason_failed:='EAM_CATEGORY_ID_INVALID';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	end if;
  end if;

  -- validate fa asset
	if (p_fa_asset_id is not null and p_fa_asset_id <> fnd_api.g_miss_num ) then
		-- First, check if fa is installed on the instance.
		select count(*) into l_count
		from fnd_product_installations
		where application_id=140;

		if (l_count = 0) then
			x_reason_failed:='EAM_FA_ASSET_ID_INVALID';
			fnd_message.set_name('EAM',x_reason_failed);
	        	fnd_msg_pub.add;
			return false;
		else
          		SELECT  count(*) into l_count
          		FROM  FA_ADDITIONS_B
          		WHERE asset_id = p_fa_asset_id;

			l_validate:=(l_count>0);
			if (not l_validate) then
				x_reason_failed:='EAM_FA_ASSET_ID_INVALID';
				fnd_message.set_name('EAM',x_reason_failed);
	        		fnd_msg_pub.add;
				return false;
			end if;
		end if;
	end if;

-- validate pn location id
        if (p_pn_location_id is not null and p_pn_location_id <> fnd_api.g_miss_num ) then
        	if (l_eam_item_type = 1) then

                	-- First, check if pn is installed on the instance.
                	select count(*) into l_count
                	from fnd_product_installations
                	where application_id=240;

                	if (l_count = 0) then
				x_reason_failed:='EAM_PN_LOCATION_ID_INVALID';
				fnd_message.set_name('EAM',x_reason_failed);
	        		fnd_msg_pub.add;
				return false;
                	else
                	        SELECT  count(*) into l_count
                	        FROM pn_locations_all
                	        WHERE location_id= p_pn_location_id;

                	        l_validate:=(l_count>0);
                	        if (not l_validate) then
                	                x_reason_failed:='EAM_PN_LOCATION_ID_INVALID';
                	                fnd_message.set_name('EAM',x_reason_failed);
	        			fnd_msg_pub.add;
					return false;
                	        end if;
                	end if;
                else
			x_reason_failed := 'EAM_REB_INVALID_PN_LOCATION';
			return false;
                end if;
        end if;


  -- validate production organization, equipment item, and equipment serial number
  -- The above three fields should either be all null or all not-null.
  -- If all not-null, the equipment item has to belong to the production organization.
	l_prod_null:=true;
	if (p_equipment_object_id is not null and p_equipment_object_id <> fnd_api.g_miss_num) then
		l_prod_null := false;
	end if;
	if (l_prod_null = true AND not ((p_prod_organization_id is null or p_prod_organization_id = fnd_api.g_miss_num) and
		(p_equipment_item_id is null or p_equipment_item_id = fnd_api.g_miss_num) and
		(p_eqp_serial_number is null or p_eqp_serial_number = fnd_api.g_miss_char))) then
	  l_prod_null:=false;
	  if (not (
		  (p_equipment_item_id is not null) and
		  (p_eqp_serial_number is not null))) then
		x_reason_failed:='EAM_PROD_EQP_INCOMPLETE';
		fnd_message.set_name('EAM',x_reason_failed);
	        fnd_msg_pub.add;
		return false;
	  end if;
	end if;

	if (l_prod_null=false) then
		-- Check that the current_organization is the maintenance
		-- organization for the prod_organization

		if (p_equipment_object_id is not null and p_equipment_object_id <> fnd_api.g_miss_num) then
			begin
				select current_organization_id, inventory_item_id, serial_number
				into l_prod_organization_id, l_prod_inventory_item_id, l_prod_serial_number
				from mtl_serial_numbers
				where gen_object_id = p_equipment_object_id;
			exception
				when others then
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			end;
		else
			l_prod_inventory_item_id := p_equipment_item_id;
			l_prod_serial_number := p_eqp_serial_number;
			l_prod_organization_id := p_prod_organization_id;

		end if;

	  	if (not (p_current_organization_id = l_prod_organization_id)) then
	 		select count(*) into l_count
			from mtl_parameters
			where organization_id=l_prod_organization_id
			and maint_organization_id=p_current_organization_id;

			if (l_count=0) then
				x_reason_failed:='EAM_INVALID_PROD_ORG';
				fnd_message.set_name('EAM',x_reason_failed);
	        		fnd_msg_pub.add;
				return false;
			end if;
	  	end if;

		-- Check that the equipment item belongs to the prod org
             	SELECT count(*) INTO l_count
             	FROM   MTL_SYSTEM_ITEMS_B
             	WHERE  inventory_item_id = l_prod_inventory_item_id
             	AND    organization_id = l_prod_organization_id;
		if (l_count = 0) then
			x_reason_failed:='EAM_INVALID_EQP_ITEM';
			fnd_message.set_name('EAM',x_reason_failed);
	        	fnd_msg_pub.add;
			return false;
		end if;

		-- Check that the equipment type of the eqp item is 1
             	SELECT equipment_type INTO l_prod_equipment_type
             	FROM   MTL_SYSTEM_ITEMS_B
             	WHERE  inventory_item_id = l_prod_inventory_item_id
             	AND    organization_id = l_prod_organization_id;

		if (l_prod_equipment_type is null) then
			x_reason_failed:='EAM_EQP_INVALID';
			fnd_message.set_name('EAM',x_reason_failed);
	        	fnd_msg_pub.add;
			return false;
		else
             		IF l_prod_equipment_type <> 1 -- not equipment type
             		THEN
                		x_reason_failed:='EAM_EQP_WRONG_TYPE';
                		fnd_message.set_name('EAM',x_reason_failed);
	        		fnd_msg_pub.add;
				return false;
             		END IF;
		end if;

		-- Check that the equipment serial number belongs to the
		-- equipment item
             	select count(*) into l_count
             	from mtl_serial_numbers
             	where inventory_item_id = l_prod_inventory_item_id
             	and current_organization_id = l_prod_organization_id
             	and serial_number = l_prod_serial_number;

             	if l_count = 0 then
               		x_reason_failed:='EAM_EQP_SERIAL_INVALID';
               		fnd_message.set_name('EAM',x_reason_failed);
	        	fnd_msg_pub.add;
			return false;
             	end if;
	end if;
	-- End of validation for prod org, equipment item, and eqp serial number

	if (p_checkin_status is not null and p_checkin_status <> fnd_api.g_miss_num) then
		l_validate:=eam_common_utilities_pvt.validate_mfg_lookup_code
				('EAM_ASSET_OPERATION_TXN_TYPE',
				p_checkin_status);
		if ( (not l_validate) or (p_network_asset_flag = 'Y') ) then
			x_reason_failed:='EAM_CHECKIN_STATUS_INVALID';
			fnd_message.set_name('EAM',x_reason_failed);
	        	fnd_msg_pub.add;
			return false;
		end if;

	end if;

	if (p_operational_log_flag is not null and p_operational_log_flag <> fnd_api.g_miss_char) then
		if ((nvl(p_operational_log_flag,'N') not in ('Y','N')) or
		    (p_network_asset_flag = 'Y' and p_operational_log_flag = 'Y') )  then
			x_reason_failed:='EAM_OPERATION_LOG_FLAG_INVALID';
			fnd_message.set_name('EAM',x_reason_failed);
	        	fnd_msg_pub.add;
			return false;
		end if;

	end if;

	return true;

  end validate_fields;


procedure add_error (p_error_code IN varchar2)
is
begin
	FND_MESSAGE.SET_NAME('EAM', p_error_code);
	FND_MSG_PUB.Add;
end;


END;

/

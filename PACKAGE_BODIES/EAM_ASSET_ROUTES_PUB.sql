--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_ROUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_ROUTES_PUB" AS
/* $Header: EAMPAROB.pls 120.3 2006/03/17 16:04:36 hkarmach noship $ */
-- Start of comments
--	API name 	: EAM_ASSET_ROUTES_PUB
--	Type		: Public
--	Function	: insert_asset_routes, update_asset_routes
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

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ASSET_ROUTES_PUB';
/* for de-bugging */
/*g_sr_no		number ;*/

PROCEDURE print_log(info varchar2) is
PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;

/* function checking the item unique when both the 2 combinations are provided by the user */
FUNCTION check_item_unique (
			p_maintenance_object_type NUMBER,
			p_maintenance_object_id NUMBER,
			p_asset_group_id NUMBER,
			p_organization_id NUMBER,
			p_asset_number VARCHAR2,
			P_SERIAL_NUMBER VARCHAR2,
			p_creation_organization_id NUMBER
		)
	RETURN boolean
IS
	l_count_rec NUMBER := 0;
BEGIN
	IF (p_maintenance_object_type = 1) THEN
		IF ( p_asset_number IS NOT NULL ) THEN
			SELECT count(*) INTO l_count_rec
			FROM mtl_system_items MSI , mtl_serial_numbers MSN
			WHERE MSN.serial_number = p_asset_number
			AND MSN.gen_object_id = p_maintenance_object_id
			AND MSN.inventory_item_id = MSI.inventory_item_id
			AND MSI.inventory_item_id = p_asset_group_id
			AND MSI.organization_id = p_creation_organization_id;
		END IF;

	ELSIF (p_maintenance_object_type = 2) THEN
		IF ((p_asset_number IS NULL) AND
		    (p_maintenance_object_id = p_asset_group_id)) THEN
			SELECT count(*) INTO l_count_rec
			FROM mtl_system_items
			WHERE inventory_item_id = p_asset_group_id
			AND organization_id = p_creation_organization_id;
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

PROCEDURE validate_object_id(p_organization_id 		in number,
                             p_object_id 		in number,
                             p_eam_item_type 		in number,
                             p_inventory_item_id 	in number ,
                             p_serial_number 		in string ,
			     x_return_status		out NOCOPY VARCHAR2	 ,
		             x_msg_count		OUT NOCOPY NUMBER	 ,
			     x_msg_data	    		OUT NOCOPY VARCHAR2
			    )
is

CURSOR c_val_object_id(p_organization_id number,
                       p_object_id number,
                       p_eam_item_type number,
                       p_inventory_item_id number ,
                       p_serial_number string)
IS
	SELECT
	  msn.gen_object_id
	FROM
	  mtl_serial_numbers msn,
	  mtl_system_items_b msi
	WHERE
	  msn.inventory_item_id =  p_inventory_item_id  and
	  msn.serial_number= p_serial_number  and
	  msn.current_organization_id = p_organization_id  and
	  msi.inventory_item_id = msn.inventory_item_id  and
	  msi.eam_item_type = 1 and
	  msi.organization_id = msn.current_organization_id and
	  msn.current_status=3;

   l_gen_obj_id NUMBER;

begin
          IF p_object_id IS NULL OR p_eam_item_type IS NULL OR p_organization_id IS NULL or p_inventory_item_id is null or p_serial_number is null
          THEN
                RETURN ;
          END IF ;

	  if p_eam_item_type = 1
	  then
	       open c_val_object_id (p_organization_id , p_object_id , p_eam_item_type , p_inventory_item_id , p_serial_number );
	       fetch c_val_object_id into l_gen_obj_id;
	       if c_val_object_id%FOUND
	       THEN
	            IF P_OBJECT_ID <> L_GEN_OBJ_ID
	            THEN
		      fnd_message.set_name('EAM', 'EAM_ARO_INV_GENOBJ_NOTFOUND');
	              fnd_msg_pub.add;
	              RAISE fnd_api.g_exc_error;
	            END IF;
	       ELSE
		      fnd_message.set_name('EAM', 'EAM_ARO_INV_GENOBJ_NOTFOUND');
	              fnd_msg_pub.add;
	              RAISE fnd_api.g_exc_error;
	       END IF;

	  elsif p_eam_item_type = 2
	  then
		      fnd_message.set_name('EAM', 'EAM_ARO_INV_ASSET_TYPE');
	              fnd_msg_pub.add;
	              RAISE fnd_api.g_exc_error;
	  end if;

END;

PROCEDURE validate_record_for_route(p_object_id   in number,
                                    p_asset_route in VARCHAR2,
				    p_error_msg in VARCHAR2)
is
l_asset_route varchar2(1);
BEGIN
  select network_asset_flag into l_asset_route from mtl_serial_numbers where gen_object_id = p_object_id;
  IF (p_asset_route <> nvl(l_asset_route,'N')) then
     raise_error(p_error_msg);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     raise_error(p_error_msg);
END validate_record_for_route;



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
		p_desc_flex_name => 'MTL_EAM_NETWORK_ASSETS',
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


procedure VALIDATE_ROW_EXISTS( P_NETWORK_ITEM_ID IN NUMBER ,
          		       P_NETWORK_SERIAL_NUMBER IN VARCHAR2 ,
			       P_INVENTORY_ITEM_ID IN NUMBER ,
			       P_SERIAL_NUMBER IN VARCHAR2 ,
			       P_ORGANIZATION_ID IN NUMBER,
                               p_create_flag in NUMBER,
			       p_network_association_id IN NUMBER := null)

is
        l_count number;
  BEGIN
        SELECT COUNT(*) INTO l_count
	FROM MTL_EAM_NETWORK_ASSETS
	WHERE       network_item_id= p_network_ITEM_id
		AND network_serial_number= p_network_serial_number
		AND inventory_item_id = p_inventory_item_id
		AND serial_number= p_serial_number
		AND organization_id = p_organization_id
		AND decode(p_create_flag, 0, NETWORK_ASSOCIATION_ID,1) =
                    decode(p_create_flag, 0, p_network_association_id,1);
        if (l_count = 0) then
           if (p_create_flag = 0) then
	      fnd_message.set_name('EAM', 'EAM_NETWORK_REC_NOT_FOUND');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        else
           if (p_create_flag = 1) then
	      fnd_message.set_name('EAM', 'EAM_NETWORK_REC_EXISTS');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        end if;
END;



PROCEDURE insert_asset_routes
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ORGANIZATION_ID               IN	NUMBER		,
	P_START_DATE_ACTIVE             IN	DATE	default null,
	P_END_DATE_ACTIVE               IN	DATE	default null,
	P_ATTRIBUTE_CATEGORY            IN	VARCHAR2	default null,
	P_ATTRIBUTE1	            	IN      VARCHAR2	default null,
	P_ATTRIBUTE2	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE3	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE4	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE5	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE6	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE7	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE8	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE9	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE10	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE11	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE12	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE13	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE14	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE15	            	IN	VARCHAR2	default null,
	P_NETWORK_ITEM_ID               IN	NUMBER		,
	P_NETWORK_SERIAL_NUMBER         IN	VARCHAR2		,
	P_INVENTORY_ITEM_ID             IN	NUMBER		,
	P_SERIAL_NUMBER	            	IN	VARCHAR2		,
	P_NETWORK_OBJECT_TYPE           IN	NUMBER	default null	,
	P_NETWORK_OBJECT_ID             IN	NUMBER	default null	,
	P_MAINTENANCE_OBJECT_TYPE       IN	NUMBER	default null	,
	P_MAINTENANCE_OBJECT_ID         IN	NUMBER	default null	,
	P_NETWORK_ASSET_NUMBER         	IN	VARCHAR2	default null	,
	P_ASSET_NUMBER         		IN	VARCHAR2	default null
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'APIname';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_network_id                    number;

	l_object_found BOOLEAN;
	l_network_object_type NUMBER;
	l_network_object_id NUMBER;
	l_maintenance_object_type NUMBER;
	l_maintenance_object_id NUMBER;
	l_creation_organization_id NUMBER;
	l_asset_group_id NUMBER;
	l_org_id NUMBER;
	l_temp_org_id NUMBER;
	l_serial_number VARCHAR2(100);
	l_asset_number VARCHAR2(100);
	l_validated boolean;
        l_network_item_id NUMBER;
	l_network_serial_number VARCHAR2(100);
	l_item_id NUMBER;
	l_count number;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	insert_asset_routes;
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

	/* Anand- for creation_organization_id = organization_id */

	l_org_id := P_ORGANIZATION_ID;
	l_creation_organization_id := P_ORGANIZATION_ID;


	--ver eam enabled
	EAM_COMMON_UTILITIES_PVT.verify_org(
		          p_resp_id =>NULL,
		          p_resp_app_id => 401,
		          p_org_id  => l_org_id,
		          x_boolean => l_boolean,
		          x_return_status => l_return_status,
		          x_msg_count => l_msg_count ,
		          x_msg_data => l_msg_data);
	if l_boolean = 0
	  then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;


        -- Bug # 3441956
	IF (((p_network_item_id is null or p_network_serial_number is null) and
	     (p_network_object_id is null or p_network_object_type is null) and
	     (p_network_asset_number is null)) OR
	    (p_network_object_type is not null and p_network_object_type <> 3)) THEN
	      fnd_message.set_name('EAM', 'EAM_NETWORK_REC_NOT_FOUND');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;


	IF (((p_maintenance_object_type is null or p_maintenance_object_id is null) and
	     (p_inventory_item_id is null or p_serial_number is null) and
	     (p_asset_number is null)) OR
	    (p_maintenance_object_type is not null and p_maintenance_object_type <> 3)) THEN
	      fnd_message.set_name('EAM', 'EAM_EZWO_ASSET_BAD');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_network_object_type := p_network_object_type;
        l_network_object_id := p_network_object_id;
        l_network_item_id := p_network_item_id;
        l_network_serial_number	:= p_network_serial_number;

	if (p_network_asset_number is not null and l_network_object_id IS NULL ) THEN

		begin
			select instance_id into l_network_object_id
			from csi_item_instances
			where instance_number = p_network_asset_number;

		exception when no_data_found then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end;

	END IF;

	IF (l_network_item_id IS NOT NULL AND l_network_serial_number IS NOT NULL
            AND l_network_object_id IS NULL ) THEN

		begin
			select instance_id into l_network_object_id
			from csi_item_instances
			where serial_number = l_network_serial_number
			and inventory_item_id = l_network_item_id;
		exception when no_data_found then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end;
	END IF;

        IF ((l_network_serial_number is null or l_network_item_id is null ) and
  	       (l_network_object_id is not null and l_network_object_type is not null)) THEN

		begin
			select cii.serial_number, cii.inventory_item_id
				into l_network_serial_number, l_network_item_id
			from csi_item_instances cii
			where cii.instance_id = l_network_object_id;

		exception when no_data_found then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end;

	end if;


	--validate the network object Id exists
	begin
		select count(*) into l_count
		from csi_item_instances cii
		where cii.instance_id = l_network_object_id
		and cii.serial_number = l_network_serial_number
		and cii.inventory_item_id = l_network_item_id
		and nvl(cii.network_asset_flag, 'N') = 'Y';

		if l_count < 1 then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end if;

	exception when no_data_found then
		raise_error('EAM_NETWORK_REC_NOT_FOUND');
	end;



        --validate start and end dates i.e. start date > end date
	if p_start_date_active > nvl(p_end_date_active,  p_start_date_active + 1)
	then
	      fnd_message.set_name('EAM', 'EAM_IAA_INVALID_ACTIVE_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
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
	/* Anand- Validations for the item combinations supplied by the user */

	l_maintenance_object_type := p_maintenance_object_type;
        l_maintenance_object_id := p_maintenance_object_id;
        l_asset_group_id := p_inventory_item_id;
        l_serial_number	:= p_serial_number;

	if (p_asset_number is not null and l_maintenance_object_id IS NULL ) THEN

		begin
			select instance_id into l_maintenance_object_id
			from csi_item_instances
			where instance_number = p_asset_number;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;

	END IF;

	IF (l_asset_group_id IS NOT NULL AND l_serial_number IS NOT NULL
            AND l_maintenance_object_id IS NULL ) THEN

		begin
			select instance_id into l_maintenance_object_id
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_asset_group_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;
	END IF;

        IF ((l_serial_number is null or l_asset_group_id is null ) and
  	       (l_maintenance_object_id is not null and l_maintenance_object_type is not null)) THEN

		begin
			select serial_number, inventory_item_id into
				l_serial_number, l_asset_group_id
			from csi_item_instances
			where instance_id = l_maintenance_object_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;

	end if;


	/* Check both the combinations are pointing to the same item / serial_number */

	begin
		select count(*) into l_count
		from csi_item_instances cii
		where cii.instance_id = l_maintenance_object_id
		and cii.serial_number = l_serial_number
		and cii.inventory_item_id = l_asset_group_id
		and nvl(cii.network_asset_flag, 'N') = 'N';

		if l_count < 1 then
			raise_error ('EAM_ABO_INVALID_INV_ITEM_ID');
		end if;

	exception when no_data_found then
		raise_error ('EAM_ABO_INVALID_INV_ITEM_ID');
	END ;


	--------------------------------------------------------------------------------------------
	/* validate that the row does not already exist */

	begin
		select count(*) into l_count
		from mtl_eam_network_assets mena
		where mena.network_object_id = l_network_object_id
		and mena.network_object_type = l_network_object_type
		and mena.maintenance_object_id = l_maintenance_object_id
		and mena.maintenance_object_type = l_maintenance_object_type;

		if l_count > 0 then
		      	fnd_message.set_name('EAM', 'EAM_NETWORK_REC_EXISTS');
        	      	fnd_msg_pub.add;
			RAISE fnd_api.g_exc_error;
		end if;

	exception when no_data_found then
		null;
	END ;


        select MTL_EAM_NETWORK_ASSETS_S.NEXTVAL into l_network_id from dual;


	INSERT INTO MTL_EAM_NETWORK_ASSETS (
			NETWORK_ASSOCIATION_ID	,
			ORGANIZATION_ID	,
			NETWORK_OBJECT_TYPE	,
			NETWORK_OBJECT_ID	,
			MAINTENANCE_OBJECT_TYPE	,
			MAINTENANCE_OBJECT_ID 	,
			NETWORK_ITEM_ID	,
			NETWORK_SERIAL_NUMBER	,
			INVENTORY_ITEM_ID	,
			SERIAL_NUMBER	,
			START_DATE_ACTIVE	,
			END_DATE_ACTIVE	,
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
			CREATED_BY           	,
			CREATION_DATE       	,
			LAST_UPDATE_LOGIN  	,
			LAST_UPDATE_DATE  	,
			LAST_UPDATED_BY
		      )VALUES
		      (
			l_network_id	,
			/*P_ORGANIZATION_ID	,*/
			l_org_id,
			l_NETWORK_OBJECT_TYPE	,
			l_NETWORK_OBJECT_ID	,
			/*P_MAINTENANCE_OBJECT_TYPE	,
			P_MAINTENANCE_OBJECT_ID 	,*/
			l_maintenance_object_type,
			l_maintenance_object_id ,
			l_NETWORK_ITEM_ID	,
			l_NETWORK_SERIAL_NUMBER	,
			/*P_INVENTORY_ITEM_ID	,
			P_SERIAL_NUMBER	,*/
			l_asset_group_id,
			l_asset_number	,
			P_START_DATE_ACTIVE	,
			P_END_DATE_ACTIVE	,
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
			fnd_global.user_id	,
			sysdate	,
			fnd_global.login_id	,
			sysdate    	,
			fnd_global.user_id
		      );



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
		ROLLBACK TO insert_asset_routes;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_asset_routes;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO insert_asset_routes;
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
END insert_asset_routes;


PROCEDURE update_asset_routes
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ORGANIZATION_ID               IN	NUMBER		,
	P_START_DATE_ACTIVE             IN	DATE	default null,
	P_END_DATE_ACTIVE               IN	DATE	default null,
	P_ATTRIBUTE_CATEGORY            IN	VARCHAR2	default null,
	P_ATTRIBUTE1	            	IN      VARCHAR2	default null,
	P_ATTRIBUTE2	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE3	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE4	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE5	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE6	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE7	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE8	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE9	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE10	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE11	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE12	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE13	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE14	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE15	            	IN	VARCHAR2	default null,
	P_NETWORK_ITEM_ID               IN	NUMBER		,
	P_NETWORK_SERIAL_NUMBER         IN	VARCHAR2		,
	P_INVENTORY_ITEM_ID             IN	NUMBER		,
	P_SERIAL_NUMBER	            	IN	VARCHAR2		,
	P_NETWORK_ASSOCIATION_ID        IN	NUMBER		,
	P_NETWORK_OBJECT_TYPE           IN	NUMBER	default null	,
	P_NETWORK_OBJECT_ID             IN	NUMBER	default null	,
	P_MAINTENANCE_OBJECT_TYPE       IN	NUMBER	default null	,
	P_MAINTENANCE_OBJECT_ID         IN	NUMBER	default null	,
	P_NETWORK_ASSET_NUMBER         	IN	VARCHAR2	default null	,
	P_ASSET_NUMBER         		IN	VARCHAR2	default null
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'APIname';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_dummy 			VARCHAR2(1);

	l_object_found BOOLEAN;
	l_network_object_type NUMBER;
	l_network_object_id NUMBER;
	l_maintenance_object_type NUMBER;
	l_maintenance_object_id NUMBER;
	l_creation_organization_id NUMBER;
	l_asset_group_id NUMBER;
	l_org_id NUMBER;
	l_temp_org_id NUMBER;
	l_asset_number VARCHAR2(100);
	l_validated boolean;
	l_network_item_id NUMBER;
	l_network_serial_number VARCHAR2(100);
	l_item_id NUMBER;
	l_serial_number VARCHAR2(100);
    l_count number;
BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	update_asset_routes;
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

	/* Anand- for creation_organization_id = organization_id */

	l_org_id := P_ORGANIZATION_ID;
	l_creation_organization_id := P_ORGANIZATION_ID;

	--ver eam enabled
	EAM_COMMON_UTILITIES_PVT.verify_org(
		          p_resp_id =>NULL,
		          p_resp_app_id => 401,
		          p_org_id  => P_ORGANIZATION_ID,
		          x_boolean => l_boolean,
		          x_return_status => l_return_status,
		          x_msg_count => l_msg_count ,
		          x_msg_data => l_msg_data);

	if l_boolean = 0
	  then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;

	-- Bug # 3441956
	IF (((p_network_item_id is null or p_network_serial_number is null) and
	     (p_network_object_id is null or p_network_object_type is null) and
	     (p_network_asset_number is null)) OR
	    (p_network_object_type is not null and p_network_object_type <> 1)) THEN
	      fnd_message.set_name('EAM', 'EAM_NETWORK_REC_NOT_FOUND');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;


	IF (((p_maintenance_object_type is null or p_maintenance_object_id is null) and
	     (p_inventory_item_id is null or p_serial_number is null) and
	     (p_asset_number is null)) OR
	    (p_maintenance_object_type is not null and p_maintenance_object_type <> 1)) THEN
	      fnd_message.set_name('EAM', 'EAM_EZWO_ASSET_BAD');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_network_object_type := p_network_object_type;
        l_network_object_id := p_network_object_id;
        l_network_item_id := p_network_item_id;
        l_network_serial_number	:= p_network_serial_number;


	if (p_network_asset_number is not null and l_network_object_id IS NULL ) THEN

		begin
			select instance_id into l_network_object_id
			from csi_item_instances
			where instance_number = p_network_asset_number;

		exception when no_data_found then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end;

	END IF;

	IF (l_network_item_id IS NOT NULL AND l_network_serial_number IS NOT NULL
            AND l_network_object_id IS NULL ) THEN

		begin
			select instance_id into l_network_object_id
			from csi_item_instances
			where serial_number = l_network_serial_number
			and inventory_item_id = l_network_item_id;
		exception when no_data_found then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end;
	END IF;

        IF ((l_network_serial_number is null or l_network_item_id is null ) and
  	       (l_network_object_id is not null and l_network_object_type is not null)) THEN

		begin
			select serial_number, inventory_item_id into
				l_network_serial_number, l_network_item_id
			from csi_item_instances
			where instance_id = l_network_object_id;

		exception when no_data_found then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end;

	end if;



	--validate the network object Id exists
	begin
		select count(*) into l_count
		from csi_item_instances cii
		where cii.instance_id = l_network_object_id
		and cii.serial_number = l_network_serial_number
		and cii.inventory_item_id = l_network_item_id
		and cii.network_asset_flag = 'Y';

		if l_count < 1 then
			raise_error('EAM_NETWORK_REC_NOT_FOUND');
		end if;

	exception when no_data_found then
		raise_error('EAM_NETWORK_REC_NOT_FOUND');
	end;


        --validate start and end dates i.e. start date > end date
	if p_start_date_active>p_end_date_active
	then
	      fnd_message.set_name('EAM', 'EAM_IAA_INVALID_ACTIVE_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
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
	/* Anand- Validations for the item combinations supplied by the user */

	l_maintenance_object_type := p_maintenance_object_type;
        l_maintenance_object_id := p_maintenance_object_id;
        l_asset_group_id := p_inventory_item_id;
        l_serial_number	:= p_serial_number;

	if (p_asset_number is not null and l_maintenance_object_id IS NULL ) THEN

		begin
			select instance_id into l_maintenance_object_id
			from csi_item_instances
			where instance_number = p_asset_number;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;

	END IF;

	IF (l_asset_group_id IS NOT NULL AND l_serial_number IS NOT NULL
            AND l_maintenance_object_id IS NULL ) THEN

		begin
			select instance_id into l_maintenance_object_id
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_asset_group_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;
	END IF;

        IF ((l_serial_number is null or l_asset_group_id is null ) and
  	       (l_maintenance_object_id is not null and l_maintenance_object_type is not null)) THEN

		begin
			select serial_number, inventory_item_id into
				l_serial_number, l_asset_group_id
			from csi_item_instances
			where instance_id = l_maintenance_object_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;

	end if;


	/* Check both the combinations are pointing to the same item / serial_number */

	begin
		select count(*) into l_count
		from csi_item_instances cii
		where cii.instance_id = l_maintenance_object_id
		and cii.serial_number = l_serial_number
		and cii.inventory_item_id = l_asset_group_id
		and cii.network_asset_flag = 'N';

		if l_count < 1 then
			raise_error ('EAM_ABO_INVALID_INV_ITEM_ID');
		end if;

	exception when no_data_found then
		raise_error ('EAM_ABO_INVALID_INV_ITEM_ID');
	END;


	--------------------------------------------------------------------------------------------
	/* validate that the row already exists in MTL_EAM_NETWORK_ASSETS table */

	begin
		select count(*) into l_count
		from mtl_eam_network_assets mena
		where mena.network_object_id = l_network_object_id
		and mena.network_object_type = l_network_object_type
		and mena.maintenance_object_id = l_maintenance_object_id
		and mena.maintenance_object_type = l_maintenance_object_type
		and mena.network_association_id = p_network_association_id;

		if l_count < 1 then
		      	fnd_message.set_name('EAM', 'EAM_NETWORK_REC_NOT_FOUND');
        	      	fnd_msg_pub.add;
			RAISE fnd_api.g_exc_error;
		end if;

	exception when no_data_found then
	      	fnd_message.set_name('EAM', 'EAM_NETWORK_REC_NOT_FOUND');
              	fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	END;

        UPDATE MTL_EAM_NETWORK_ASSETS
        SET
		START_DATE_ACTIVE	=	P_START_DATE_ACTIVE	,
		END_DATE_ACTIVE		=	P_END_DATE_ACTIVE	,
		ATTRIBUTE_CATEGORY	=	P_ATTRIBUTE_CATEGORY	,
		ATTRIBUTE1		=	P_ATTRIBUTE1	,
		ATTRIBUTE2		=	P_ATTRIBUTE2	,
		ATTRIBUTE3		=	P_ATTRIBUTE3	,
		ATTRIBUTE4		=	P_ATTRIBUTE4	,
		ATTRIBUTE5		=	P_ATTRIBUTE5	,
		ATTRIBUTE6		=	P_ATTRIBUTE6	,
		ATTRIBUTE7		=	P_ATTRIBUTE7	,
		ATTRIBUTE8		=	P_ATTRIBUTE8	,
		ATTRIBUTE9		=	P_ATTRIBUTE9	,
		ATTRIBUTE10		=	P_ATTRIBUTE10	,
		ATTRIBUTE11		=	P_ATTRIBUTE11	,
		ATTRIBUTE12		=	P_ATTRIBUTE12	,
		ATTRIBUTE13		=	P_ATTRIBUTE13	,
		ATTRIBUTE14		=	P_ATTRIBUTE14	,
		ATTRIBUTE15		=	P_ATTRIBUTE15	,

		LAST_UPDATE_LOGIN	=	fnd_global.login_id	,
		LAST_UPDATE_DATE	=	sysdate	,
		LAST_UPDATED_BY		=	fnd_global.user_id

	WHERE NETWORK_ASSOCIATION_ID    = P_NETWORK_ASSOCIATION_ID;


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
		ROLLBACK TO update_asset_routes;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO update_asset_routes;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO update_asset_routes;
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
END update_asset_routes;


END EAM_ASSET_ROUTES_PUB;

/

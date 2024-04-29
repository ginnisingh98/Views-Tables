--------------------------------------------------------
--  DDL for Package Body EAM_ASSETATTR_VALUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSETATTR_VALUE_PUB" AS
/* $Header: EAMPAAVB.pls 120.5 2008/02/08 05:20:18 vboddapa ship $ */
-- Start of comments
--	API name 	: EAM_ASSETATTR_VALUE_PUB
--	Type		: Public
--	Function	: insert_assetattr_value, update_assetattr_value
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

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ASSETATTR_VALUE_PUB';

/* for de-bugging */
/* g_sr_no		number ;*/

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


/* lllin: get item type. 1=assetgroup, 3=rebuildable */
FUNCTION get_item_type
(p_creation_organization_id in number,
p_inventory_item_id in number)
return number
is
        l_eam_item_type number;
begin
        select eam_item_type into l_eam_item_type
        from mtl_system_items
        where inventory_item_id=p_inventory_item_id
        and rownum=1;

        return l_eam_item_type;
exception
        when no_data_found then
                return null;
end get_item_type;



/* function checking the item unique when both the 2 combinations are provided by the user */
FUNCTION check_item_unique (
			p_maintenance_object_type NUMBER,
			p_maintenance_object_id NUMBER,
			p_asset_group_id NUMBER,
			p_organization_id NUMBER,
			p_serial_number VARCHAR2,
			p_creation_organization_id NUMBER
		)
	RETURN boolean
IS
	l_count_rec NUMBER := 0;
BEGIN
	/* As object type for assetnumbers in R12 is 3(earlier it was 1 in 11.5) */
	IF (p_maintenance_object_type = 3) THEN
		IF ( p_serial_number IS NOT NULL ) THEN

			SELECT count(*) INTO l_count_rec
			FROM mtl_system_items MSI , csi_item_instances CII
			WHERE cii.serial_number = p_serial_number
			AND cii.instance_id = p_maintenance_object_id
			AND CII.inventory_item_id = MSI.inventory_item_id
			AND MSI.inventory_item_id = p_asset_group_id;
		END IF;

	ELSIF (p_maintenance_object_type = 2) THEN
		IF ((p_serial_number IS NULL) AND
		    (p_maintenance_object_id = p_asset_group_id)) THEN

			SELECT count(*) INTO l_count_rec
			FROM mtl_system_items
			WHERE inventory_item_id = p_asset_group_id;
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


/*
procedures for validation
*/
procedure validate_application_id( P_APPLICATION_ID IN NUMBER)
is
     l_appl_name varchar2(30) ;
  BEGIN
        if p_application_id is null or p_application_id <> 401
        then
	      fnd_message.set_name('EAM', 'EAM_INVALID_APPLICATION_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;
END;

procedure validate_maintenance_object_id(p_organization_id in number, p_object_id in number, p_eam_item_type in varchar2)
is
l_count number;
begin

	  if p_eam_item_type = 1
	  then
		select count(*) into l_count
		from csi_item_instances
		where instance_id=p_object_id;
	  elsif p_eam_item_type = 2
	  then
		select count(*) into l_count
		from mtl_system_items
		where inventory_item_id=p_object_id
		and organization_id=p_organization_id;
	  end if;


	if l_count = 0 then
	      fnd_message.set_name('EAM', 'EAM_INVALID_MAINT_OBJ_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;

END;

procedure validate_assos_id( p_association_id in number,
                             p_creation_organization_id in number,
			     p_inventory_item_id in number,
			     p_attribute_category in varchar2,
			     p_eam_item_type in number)
is
	l_count number;
begin
	select count(*) into l_count
	from mtl_eam_asset_attr_groups
	where association_id = p_association_id and
	/* removing this as creation_organization_id is not used */
	/* decode(p_eam_item_type,1,creation_organization_id,1) = 	decode(p_eam_item_type,1,p_creation_organization_id,1) and */
	inventory_item_id = p_inventory_item_id
	and descriptive_flex_context_code=p_attribute_category;

	if l_count = 0 then
	      fnd_message.set_name('EAM', 'EAM_INVALID_ASSOCIATION_GROUP');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;
END;


procedure validate_descflexfield_name(P_DESCRIPTIVE_FLEXFIELD_NAME in varchar2)
is
  BEGIN
        -- Bug # 3518888.
        if (P_DESCRIPTIVE_FLEXFIELD_NAME IS NULL) then
	      RAISE_ERROR('EAM_INVALID_DFF_NAME');
        end if;
        if P_DESCRIPTIVE_FLEXFIELD_NAME <> 'MTL_EAM_ASSET_ATTR_VALUES' then
	      RAISE_ERROR('EAM_INVALID_DFF_NAME');
        end if;
END ;

procedure validate_descflex_context_code(P_ATTRIBUTE_CATEGORY in varchar2, P_APPLICATION_ID in NUMBER)
is
        l_count number;
  BEGIN


        SELECT COUNT(*) INTO l_count
	FROM   FND_DESCR_FLEX_CONTEXTS_VL
	WHERE  DESCRIPTIVE_FLEXFIELD_NAME = 'MTL_EAM_ASSET_ATTR_VALUES'
	AND    ENABLED_FLAG = 'Y'
	AND    APPLICATION_ID = p_application_id
	AND    DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attribute_category;

        if l_count = 0
        then
	      fnd_message.set_name('EAM', 'EAM_AAV_INVALID_DFF_CONTEXT');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;

END ;

procedure validate_dff_segments(
			p_app_short_name	IN			  VARCHAR:='EAM',
			p_ATTRIBUTE_CATEGORY    IN                	  VARCHAR2 default null,
			p_c_ATTRIBUTE1            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE2            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE3            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE4            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE5            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE6            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE7            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE8            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE9            IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE10           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE11           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE12           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE13           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE14           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE15           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE16           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE17           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE18           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE19           IN                        VARCHAR2 default null,
			p_c_ATTRIBUTE20           IN                        VARCHAR2 default null,
			p_n_ATTRIBUTE1            IN                        NUMBER default null,
			p_n_ATTRIBUTE2            IN                        NUMBER default null,
			p_n_ATTRIBUTE3            IN                        NUMBER default null,
			p_n_ATTRIBUTE4            IN                        NUMBER default null,
			p_n_ATTRIBUTE5            IN                        NUMBER default null,
			p_n_ATTRIBUTE6            IN                        NUMBER default null,
			p_n_ATTRIBUTE7            IN                        NUMBER default null,
			p_n_ATTRIBUTE8            IN                        NUMBER default null,
			p_n_ATTRIBUTE9            IN                        NUMBER default null,
			p_n_ATTRIBUTE10           IN                        NUMBER default null,
			p_d_ATTRIBUTE1            IN                        DATE default null,
			p_d_ATTRIBUTE2            IN                        DATE default null,
			p_d_ATTRIBUTE3            IN                        DATE default null,
			p_d_ATTRIBUTE4            IN                        DATE default null,
			p_d_ATTRIBUTE5            IN                        DATE default null,
			p_d_ATTRIBUTE6            IN                        DATE default null,
			p_d_ATTRIBUTE7            IN                        DATE default null,
			p_d_ATTRIBUTE8            IN                        DATE default null,
			p_d_ATTRIBUTE9            IN                        DATE default null,
			p_d_ATTRIBUTE10           IN                        DATE default null
			)
is
l_error_segments number;
l_error_message varchar2(4000);
l_validated boolean;

begin
        -- validate the desc. flex fields
	FND_FLEX_DESCVAL.set_context_value(p_attribute_category);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE1', p_c_ATTRIBUTE1);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE2', p_c_ATTRIBUTE2);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE3', p_c_ATTRIBUTE3);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE4', p_c_ATTRIBUTE4);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE5', p_c_ATTRIBUTE5);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE6', p_c_ATTRIBUTE6);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE7', p_c_ATTRIBUTE7);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE8', p_c_ATTRIBUTE8);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE9', p_c_ATTRIBUTE9);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE10', p_c_ATTRIBUTE10);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE11', p_c_ATTRIBUTE11);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE12', p_c_ATTRIBUTE12);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE13', p_c_ATTRIBUTE13);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE14', p_c_ATTRIBUTE14);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE15', p_c_ATTRIBUTE15);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE16', p_c_ATTRIBUTE16);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE17', p_c_ATTRIBUTE17);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE18', p_c_ATTRIBUTE18);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE19', p_c_ATTRIBUTE19);
        fnd_flex_descval.set_column_value('C_ATTRIBUTE20', p_c_ATTRIBUTE20);

        fnd_flex_descval.set_column_value('N_ATTRIBUTE1', p_n_ATTRIBUTE1);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE2', p_n_ATTRIBUTE2);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE3', p_n_ATTRIBUTE3);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE4', p_n_ATTRIBUTE4);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE5', p_n_ATTRIBUTE5);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE6', p_n_ATTRIBUTE6);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE7', p_n_ATTRIBUTE7);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE8', p_n_ATTRIBUTE8);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE9', p_n_ATTRIBUTE9);
        fnd_flex_descval.set_column_value('N_ATTRIBUTE10', p_n_ATTRIBUTE10);

	fnd_flex_descval.set_column_value('D_ATTRIBUTE1', p_d_ATTRIBUTE1);
	fnd_flex_descval.set_column_value('D_ATTRIBUTE2', p_d_ATTRIBUTE2);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE3', p_d_ATTRIBUTE3);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE4', p_d_ATTRIBUTE4);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE5', p_d_ATTRIBUTE5);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE6', p_d_ATTRIBUTE6);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE7', p_d_ATTRIBUTE7);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE8', p_d_ATTRIBUTE8);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE9', p_d_ATTRIBUTE9);
        fnd_flex_descval.set_column_value('D_ATTRIBUTE10', p_d_ATTRIBUTE10);

        l_validated:= FND_FLEX_DESCVAL.validate_desccols(
                'INV',
                'MTL_EAM_ASSET_ATTR_VALUES',
                'I',
                sysdate ) ;

        if (not l_validated) then
		l_error_segments:=FND_FLEX_DESCVAL.error_segment;
		l_error_message:= substr(fnd_flex_descval.error_message,1,4000);
                FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_DESC_FLEX');
                FND_MESSAGE.SET_TOKEN('ERROR_MSG', l_error_message);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        end if;

end validate_dff_segments;

procedure VALIDATE_ROW_EXISTS(P_ATTRIBUTE_CATEGORY IN VARCHAR2,
                              P_ASSOCIATION_ID IN NUMBER,
                              P_INVENTORY_ITEM_ID IN NUMBER,
                              P_SERIAL_NUMBER IN VARCHAR2,
                              P_CREATION_ORGANIZATION_ID IN NUMBER,
                              p_create_flag in boolean,
			      p_eam_item_type in number)
is
        l_count number;
  BEGIN
        SELECT COUNT(*) INTO l_count
	FROM  MTL_EAM_ASSET_ATTR_VALUES
	WHERE 	association_id	 	 = 	p_association_id    and
		inventory_item_id	 = 	p_inventory_item_id and
		serial_number 	 	 = 	p_serial_number	    and
		/* removing this as creation_organization_id is not used */
		/* decode(p_eam_item_type,1,creation_organization_id,1) = 	decode(p_eam_item_type,1,p_creation_organization_id,1) and */
		attribute_category	 = 	p_attribute_category;

        if l_count = 0
        then
         if NOT p_create_flag
           then
	      fnd_message.set_name('EAM', 'EAM_ATTR_VALUES_REC_NOT_FOUND');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        else
         if p_create_flag
           then
	      fnd_message.set_name('EAM', 'EAM_ATTR_VALUES_REC_EXISTS');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;
        end if;
END;



procedure insert_assetattr_value
(
	p_api_version          	IN	NUMBER			,
  	p_init_msg_list	   	IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT NOCOPY VARCHAR2	 ,
	x_msg_count		OUT NOCOPY NUMBER	 ,
	x_msg_data	    	OUT NOCOPY VARCHAR2  ,
	P_ASSOCIATION_ID	IN	NUMBER	,
	P_APPLICATION_ID	IN	NUMBER	default 401,
	P_DESCRIPTIVE_FLEXFIELD_NAME  	IN VARCHAR2 default 'MTL_EAM_ASSET_ATTR_VALUES'	,
	P_INVENTORY_ITEM_ID	IN	NUMBER	default null,
	P_SERIAL_NUMBER		IN	VARCHAR2	default null,
	P_ORGANIZATION_ID	IN	NUMBER	,
	P_ATTRIBUTE_CATEGORY	IN	VARCHAR2	,
	P_C_ATTRIBUTE1		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE2		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE3		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE4		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE5		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE6		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE7		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE8		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE9		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE10		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE11		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE12		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE13		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE14		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE15		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE16		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE17		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE18		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE19		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE20		IN	VARCHAR2	default null,
	P_D_ATTRIBUTE1		IN	DATE	default null,
	P_D_ATTRIBUTE2		IN	DATE	default null,
	P_D_ATTRIBUTE3		IN	DATE	default null,
	P_D_ATTRIBUTE4		IN	DATE	default null,
	P_D_ATTRIBUTE5		IN	DATE	default null,
	P_D_ATTRIBUTE6		IN	DATE	default null,
	P_D_ATTRIBUTE7		IN	DATE	default null,
	P_D_ATTRIBUTE8		IN	DATE	default null,
	P_D_ATTRIBUTE9		IN	DATE	default null,
	P_D_ATTRIBUTE10		IN	DATE	default null,
	P_N_ATTRIBUTE1		IN	NUMBER	default null,
	P_N_ATTRIBUTE2		IN	NUMBER	default null,
	P_N_ATTRIBUTE3		IN	NUMBER	default null,
	P_N_ATTRIBUTE4		IN	NUMBER	default null,
	P_N_ATTRIBUTE5		IN	NUMBER	default null,
	P_N_ATTRIBUTE6		IN	NUMBER	default null,
	P_N_ATTRIBUTE7		IN	NUMBER	default null,
	P_N_ATTRIBUTE8		IN	NUMBER	default null,
	P_N_ATTRIBUTE9		IN	NUMBER	default null,
	P_N_ATTRIBUTE10		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_TYPE     	IN	VARCHAR2 default null	,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER	default null,
	P_CREATION_ORGANIZATION_ID  	IN	NUMBER	default null
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_assetattr_value';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;
	l_error                         boolean;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);

	l_error_segments                VARCHAR2(5000);


	l_object_found BOOLEAN;
	l_maintenance_object_type NUMBER;
	l_maintenance_object_id NUMBER;
	l_creation_organization_id NUMBER;
	l_asset_group_id NUMBER;
	l_org_id NUMBER;
	l_temp_org_id NUMBER;
	l_validated boolean;
	l_item_type number;
	l_count number;
	l_item_id NUMBER;
	l_serial_number VARCHAR2(100);


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	INSERT_ASSETATTR_VALUE;
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
            	EAM_COMMON_UTILITIES_PVT.verify_org(
            		          p_resp_id => NULL,
            		          p_resp_app_id => 401,
            		          p_org_id  => l_CREATION_ORGANIZATION_ID,
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
        end if;

	/* validate / populate inventory_item_id, serial_number, maintenance_object_id, maintenance_object_type */

	IF ((p_maintenance_object_type is null or p_maintenance_object_id is null) and
	     (p_inventory_item_id is null or p_serial_number is null)) THEN
	      fnd_message.set_name('EAM', 'EAM_NOT_ENOUGH_PARAM');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (p_maintenance_object_type is not null and p_maintenance_object_type <> 3) THEN
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_MAINT_OBJ_TYPE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

	l_maintenance_object_type := p_maintenance_object_type;
        l_maintenance_object_id := p_maintenance_object_id;
        l_asset_group_id := p_inventory_item_id;
        l_serial_number	:= p_serial_number;
	l_org_id := p_creation_organization_id;

        IF (p_inventory_item_id IS NOT NULL) THEN

  	    /* validate item id; get item type */
   	    l_item_type:=get_item_type(p_creation_organization_id, l_asset_group_id);

        ELSE
   	    begin
		select msi.eam_item_type into l_item_type
		from mtl_system_items msi, csi_item_instances cii
		where cii.inventory_item_id = msi.inventory_item_id
		and cii.last_vld_organization_id = msi.organization_id
		and cii.instance_id = p_maintenance_object_id;

	    exception
		when no_data_found then
			raise_error('EAM_ABO_INVLD_MT_GEN_OBJ_ID');
		when too_many_rows then
			raise_error('EAM_INVALID_MAINT_OBJ_ID');
	    END;
        END IF;

	if (l_item_type is null OR l_item_type NOT IN (1,3)) then
                raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
/*        elsif (l_item_type=1 and p_organization_id is null) then
                raise_error('EAM_ASSET_ORG_ID_REQ');
        elsif (l_item_type=1 and p_organization_id <> p_creation_organization_id) then
                raise_error('EAM_ORG_ID_INCONSISTENT');
	elsif (l_item_type=3 and p_organization_id is not null) then
                raise_error('EAM_REBUILD_ORG_ID_NOT_NULL');
*/
	end if;

	if (l_item_type = 1) then

	    IF (p_inventory_item_id IS NOT NULL and p_serial_number is not null
	     and p_maintenance_object_id IS NULL ) THEN

		begin
			select instance_id, 3 into l_maintenance_object_id, l_maintenance_object_type
			from csi_item_instances
			where serial_number = p_serial_number
                        and inventory_item_id = p_inventory_item_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;


            ELSIF ((p_inventory_item_id IS NULL or p_serial_number is null) and
               (p_maintenance_object_type IS NOT NULL and p_maintenance_object_id IS NOT NULL)) THEN

		begin
			select cii.serial_number, cii.inventory_item_id
				into l_serial_number, l_asset_group_id
			from csi_item_instances cii
			where cii.instance_id = p_maintenance_object_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		END;

	    END IF;

	    /* Check both the combinations are pointing to the same item / serial_number */

	    l_validated := check_item_unique (
			l_maintenance_object_type ,
			l_maintenance_object_id ,
			l_asset_group_id ,
			l_org_id ,
			l_serial_number ,
			l_org_id
	    );

	    IF NOT l_validated THEN
		raise_error ('EAM_INVALID_COMBO');
	    END IF;

	ELSE -- Rebuildable

	    IF (p_inventory_item_id IS NOT NULL and p_serial_number is not null
	     and p_maintenance_object_id IS NULL ) THEN

	      begin
		select instance_id,3
		into l_maintenance_object_id,l_maintenance_object_type
		from csi_item_instances
		where inventory_item_id=p_inventory_item_id
		and serial_number=p_serial_number;

	      exception
		when no_data_found then
			raise_error('EAM_NO_ASSET_FOUND');
	      end;

	    ELSIF ((p_inventory_item_id IS NULL or p_serial_number is null) and
               (p_maintenance_object_type IS NOT NULL and p_maintenance_object_type = 3)) THEN

 	      begin
		select inventory_item_id, serial_number, last_vld_organization_id
		into l_asset_group_id , l_serial_number, l_temp_org_id
		from csi_item_instances
		where instance_id=p_maintenance_object_id;

		IF (l_org_id is null) THEN
		  l_org_id := l_temp_org_id;
		END IF;

	      exception
		when no_data_found then
			raise_error('EAM_NO_ASSET_FOUND');
	      end;

            END IF;

	    /* Check both the combinations are pointing to the same item / serial_number */

	    select count(*) into l_count
    	    from csi_item_instances
	    where instance_id=l_maintenance_object_id
	    and inventory_item_id=l_asset_group_id
	    and serial_number=l_serial_number;

	    if (l_count = 0) then
		raise_error('EAM_INVALID_COMBO');
	    end if;

	END IF;

	validate_application_id( P_APPLICATION_ID);

	validate_descflexfield_name(P_DESCRIPTIVE_FLEXFIELD_NAME);

	validate_descflex_context_code(P_ATTRIBUTE_CATEGORY, P_APPLICATION_ID);

	validate_dff_segments(  'EAM',
				p_ATTRIBUTE_CATEGORY	,
				p_c_ATTRIBUTE1	,
				p_c_ATTRIBUTE2	,
				p_c_ATTRIBUTE3	,
				p_c_ATTRIBUTE4	,
				p_c_ATTRIBUTE5	,
				p_c_ATTRIBUTE6	,
				p_c_ATTRIBUTE7	,
				p_c_ATTRIBUTE8	,
				p_c_ATTRIBUTE9	,
				p_c_ATTRIBUTE10	,
				p_c_ATTRIBUTE11	,
				p_c_ATTRIBUTE12	,
				p_c_ATTRIBUTE13	,
				p_c_ATTRIBUTE14	,
				p_c_ATTRIBUTE15	,
				p_c_ATTRIBUTE16	,
				p_c_ATTRIBUTE17	,
				p_c_ATTRIBUTE18	,
				p_c_ATTRIBUTE19	,
				p_c_ATTRIBUTE20	,
				p_n_ATTRIBUTE1	,
				p_n_ATTRIBUTE2	,
				p_n_ATTRIBUTE3	,
				p_n_ATTRIBUTE4	,
				p_n_ATTRIBUTE5	,
				p_n_ATTRIBUTE6	,
				p_n_ATTRIBUTE7	,
				p_n_ATTRIBUTE8	,
				p_n_ATTRIBUTE9	,
				p_n_ATTRIBUTE10	,
				p_d_ATTRIBUTE1	,
				p_d_ATTRIBUTE2	,
				p_d_ATTRIBUTE3	,
				p_d_ATTRIBUTE4	,
				p_d_ATTRIBUTE5	,
				p_d_ATTRIBUTE6	,
				p_d_ATTRIBUTE7	,
				p_d_ATTRIBUTE8	,
				p_d_ATTRIBUTE9	,
				p_d_ATTRIBUTE10
			);


/*
	IF not EAM_COMMON_UTILITIES_PVT.validate_serial_number(
		p_creation_organization_id ,
		l_asset_group_id,
		l_serial_number,
		l_item_type
	)
	THEN
	      fnd_message.set_name('EAM', 'EAM_EZWO_ASSET_BAD');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
         END IF;
*/

	 /*validate_maintenance_object_id(p_creation_organization_id , P_MAINTENANCE_OBJECT_ID, p_MAINTENANCE_OBJECT_TYPE );*/

         validate_assos_id(p_association_id, p_creation_organization_id, l_asset_group_id, p_attribute_category, l_item_type);




	VALIDATE_ROW_EXISTS(P_ATTRIBUTE_CATEGORY ,
                              P_ASSOCIATION_ID ,
                              /*P_INVENTORY_ITEM_ID ,*/
			      l_asset_group_id,
                              /*P_SERIAL_NUMBER ,*/
			      l_serial_number,
                              /*P_CREATION_ORGANIZATION_ID , */
			      p_creation_organization_id,
                              TRUE,
			      l_item_type);


        INSERT INTO MTL_EAM_ASSET_ATTR_VALUES
        (
		ASSOCIATION_ID	,
		INVENTORY_ITEM_ID	,
		SERIAL_NUMBER 	,
		ORGANIZATION_ID  	,
		ATTRIBUTE_CATEGORY	,
		C_ATTRIBUTE1  	,
		C_ATTRIBUTE2  	,
		C_ATTRIBUTE3  	,
		C_ATTRIBUTE4  	,
		C_ATTRIBUTE5  	,
		C_ATTRIBUTE6  	,
		C_ATTRIBUTE7  	,
		C_ATTRIBUTE8  	,
		C_ATTRIBUTE9  	,
		C_ATTRIBUTE10 	,
		C_ATTRIBUTE11 	,
		C_ATTRIBUTE12 	,
		C_ATTRIBUTE13 	,
		C_ATTRIBUTE14 	,
		C_ATTRIBUTE15 	,
		C_ATTRIBUTE16 	,
		C_ATTRIBUTE17 	,
		C_ATTRIBUTE18 	,
		C_ATTRIBUTE19 	,
		C_ATTRIBUTE20 	,
		D_ATTRIBUTE1  	,
		D_ATTRIBUTE2  	,
		D_ATTRIBUTE3  	,
		D_ATTRIBUTE4  	,
		D_ATTRIBUTE5  	,
		D_ATTRIBUTE6  	,
		D_ATTRIBUTE7  	,
		D_ATTRIBUTE8  	,
		D_ATTRIBUTE9  	,
		D_ATTRIBUTE10 	,
		N_ATTRIBUTE1  	,
		N_ATTRIBUTE2  	,
		N_ATTRIBUTE3  	,
		N_ATTRIBUTE4  	,
		N_ATTRIBUTE5  	,
		N_ATTRIBUTE6  	,
		N_ATTRIBUTE7  	,
		N_ATTRIBUTE8  	,
		N_ATTRIBUTE9  	,
		N_ATTRIBUTE10 	,
		APPLICATION_ID	,
		DESCRIPTIVE_FLEXFIELD_NAME	,
		MAINTENANCE_OBJECT_TYPE	,
		MAINTENANCE_OBJECT_ID	,
		CREATION_ORGANIZATION_ID               	,

		CREATED_BY           ,
		CREATION_DATE       ,
		LAST_UPDATE_LOGIN  ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY
	)
	VALUES
	(
		P_ASSOCIATION_ID	,
		/*P_INVENTORY_ITEM_ID	,
		P_SERIAL_NUMBER	,
		P_ORGANIZATION_ID	,*/
		l_asset_group_id,
		l_serial_number,
		p_organization_id,
		P_ATTRIBUTE_CATEGORY	,
		P_C_ATTRIBUTE1	,
		P_C_ATTRIBUTE2	,
		P_C_ATTRIBUTE3	,
		P_C_ATTRIBUTE4	,
		P_C_ATTRIBUTE5	,
		P_C_ATTRIBUTE6	,
		P_C_ATTRIBUTE7	,
		P_C_ATTRIBUTE8	,
		P_C_ATTRIBUTE9	,
		P_C_ATTRIBUTE10	,
		P_C_ATTRIBUTE11	,
		P_C_ATTRIBUTE12	,
		P_C_ATTRIBUTE13	,
		P_C_ATTRIBUTE14	,
		P_C_ATTRIBUTE15	,
		P_C_ATTRIBUTE16	,
		P_C_ATTRIBUTE17	,
		P_C_ATTRIBUTE18	,
		P_C_ATTRIBUTE19	,
		P_C_ATTRIBUTE20	,
		P_D_ATTRIBUTE1	,
		P_D_ATTRIBUTE2	,
		P_D_ATTRIBUTE3	,
		P_D_ATTRIBUTE4	,
		P_D_ATTRIBUTE5	,
		P_D_ATTRIBUTE6	,
		P_D_ATTRIBUTE7	,
		P_D_ATTRIBUTE8	,
		P_D_ATTRIBUTE9	,
		P_D_ATTRIBUTE10	,
		P_N_ATTRIBUTE1	,
		P_N_ATTRIBUTE2	,
		P_N_ATTRIBUTE3	,
		P_N_ATTRIBUTE4	,
		P_N_ATTRIBUTE5	,
		P_N_ATTRIBUTE6	,
		P_N_ATTRIBUTE7	,
		P_N_ATTRIBUTE8	,
		P_N_ATTRIBUTE9	,
		P_N_ATTRIBUTE10	,
		P_APPLICATION_ID	,
		P_DESCRIPTIVE_FLEXFIELD_NAME  	,
		/*P_MAINTENANCE_OBJECT_TYPE     	,
		P_MAINTENANCE_OBJECT_ID	,
		P_CREATION_ORGANIZATION_ID  	,*/
		l_maintenance_object_type,
		l_maintenance_object_id,
		p_creation_organization_id,

		fnd_global.user_id,
		sysdate,
		fnd_global.login_id,
		sysdate    ,
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
		ROLLBACK TO insert_assetattr_value;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_assetattr_value;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO insert_assetattr_value;
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
END insert_assetattr_value;


procedure update_assetattr_value
(
	p_api_version           IN	NUMBER			,
  	p_init_msg_list	   	IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT NOCOPY VARCHAR2	 ,
	x_msg_count		OUT NOCOPY NUMBER	 ,
	x_msg_data	 	OUT NOCOPY VARCHAR2  ,
	P_ASSOCIATION_ID	IN	NUMBER	,
	P_APPLICATION_ID	IN	NUMBER	default 401,
	P_DESCRIPTIVE_FLEXFIELD_NAME  IN	VARCHAR2 default 'MTL_EAM_ASSET_ATTR_VALUES'	,
	P_INVENTORY_ITEM_ID	IN	NUMBER	default null,
	P_SERIAL_NUMBER		IN	VARCHAR2 default null	,
	P_ORGANIZATION_ID	IN	NUMBER	,
	P_ATTRIBUTE_CATEGORY	IN	VARCHAR2	,
	P_C_ATTRIBUTE1		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE2		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE3		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE4		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE5		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE6		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE7		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE8		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE9		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE10		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE11		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE12		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE13		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE14		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE15		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE16		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE17		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE18		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE19		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE20		IN	VARCHAR2	default null,
	P_D_ATTRIBUTE1		IN	DATE	default null,
	P_D_ATTRIBUTE2		IN	DATE	default null,
	P_D_ATTRIBUTE3		IN	DATE	default null,
	P_D_ATTRIBUTE4		IN	DATE	default null,
	P_D_ATTRIBUTE5		IN	DATE	default null,
	P_D_ATTRIBUTE6		IN	DATE	default null,
	P_D_ATTRIBUTE7		IN	DATE	default null,
	P_D_ATTRIBUTE8		IN	DATE	default null,
	P_D_ATTRIBUTE9		IN	DATE	default null,
	P_D_ATTRIBUTE10		IN	DATE	default null,
	P_N_ATTRIBUTE1		IN	NUMBER	default null,
	P_N_ATTRIBUTE2		IN	NUMBER	default null,
	P_N_ATTRIBUTE3		IN	NUMBER	default null,
	P_N_ATTRIBUTE4		IN	NUMBER	default null,
	P_N_ATTRIBUTE5		IN	NUMBER	default null,
	P_N_ATTRIBUTE6		IN	NUMBER	default null,
	P_N_ATTRIBUTE7		IN	NUMBER	default null,
	P_N_ATTRIBUTE8		IN	NUMBER	default null,
	P_N_ATTRIBUTE9		IN	NUMBER	default null,
	P_N_ATTRIBUTE10		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_TYPE     	IN	VARCHAR2	default null,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER	default null,
	P_CREATION_ORGANIZATION_ID  	IN	NUMBER	default null
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'update_assetattr_value';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);

	l_object_found BOOLEAN;
	l_maintenance_object_type NUMBER;
	l_maintenance_object_id NUMBER;
	l_creation_organization_id NUMBER;
	l_asset_group_id NUMBER;
	l_org_id NUMBER;
	l_temp_org_id NUMBER;
	l_validated boolean;
	l_item_type number;
	l_count number;
	l_item_id NUMBER;
	l_serial_number VARCHAR2(100);

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	update_assetattr_value;
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
            	EAM_COMMON_UTILITIES_PVT.verify_org(
            		          p_resp_id => NULL,
            		          p_resp_app_id => 401,
            		          p_org_id  => l_CREATION_ORGANIZATION_ID,
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
        end if;


	/* validate / populate inventory_item_id, serial_number, maintenance_object_id, maintenance_object_type */

	IF ((p_maintenance_object_type is null or p_maintenance_object_id is null) and
	     (p_inventory_item_id is null or p_serial_number is null)) THEN
	      fnd_message.set_name('EAM', 'EAM_NOT_ENOUGH_PARAM');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (p_maintenance_object_type is not null and p_maintenance_object_type <> 3) THEN
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_MAINT_OBJ_TYPE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF;

	l_maintenance_object_type := p_maintenance_object_type;
        l_maintenance_object_id := p_maintenance_object_id;
        l_asset_group_id := p_inventory_item_id;
        l_serial_number	:= p_serial_number;
	l_org_id := p_creation_organization_id;

        IF (p_inventory_item_id IS NOT NULL) THEN

  	    /* validate item id; get item type */
   	    l_item_type:=get_item_type(p_creation_organization_id, l_asset_group_id);

        ELSE
   	    begin
		select msi.eam_item_type into l_item_type
		from mtl_system_items msi, csi_item_instances cii
		where cii.inventory_item_id = msi.inventory_item_id
		and cii.last_vld_organization_id = msi.organization_id
		and cii.instance_id = p_maintenance_object_id;

	    exception
		when no_data_found then
			raise_error('EAM_ABO_INVLD_MT_GEN_OBJ_ID');
		when too_many_rows then
			raise_error('EAM_INVALID_MAINT_OBJ_ID');
	    END;
        END IF;
        if (l_item_type is null OR l_item_type NOT IN (1,3)) then
                raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
        elsif (l_item_type=1 and p_organization_id is null) then
                raise_error('EAM_ASSET_ORG_ID_REQ');
        elsif (l_item_type=1 and p_organization_id <> p_creation_organization_id) then
                raise_error('EAM_ORG_ID_INCONSISTENT');
	elsif (l_item_type=3 and p_organization_id is not null) then
                raise_error('EAM_REBUILD_ORG_ID_NOT_NULL');
        end if;

	if (l_item_type = 1) then

	    IF (p_inventory_item_id IS NOT NULL and p_serial_number is not null
	     and p_maintenance_object_id IS NULL ) THEN

		begin
			select instance_id, 3 into l_maintenance_object_id, l_maintenance_object_type
			from csi_item_instances
			where serial_number = p_serial_number
                        and inventory_item_id = p_inventory_item_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		end;


            ELSIF ((p_inventory_item_id IS NULL or p_serial_number is null) and
               (p_maintenance_object_type IS NOT NULL and p_maintenance_object_id IS NOT NULL)) THEN

		begin
			select cii.serial_number, cii.inventory_item_id
				into l_serial_number, l_asset_group_id
			from csi_item_instances cii
			where cii.instance_id = p_maintenance_object_id;

		exception when no_data_found then
			raise_error('EAM_NO_ITEM_FOUND');
		END;

	    END IF;

	    /* Check both the combinations are pointing to the same item / serial_number */

	    l_validated := check_item_unique (
			l_maintenance_object_type ,
			l_maintenance_object_id ,
			l_asset_group_id ,
			l_org_id ,
			l_serial_number ,
			l_org_id
	    );

	    IF NOT l_validated THEN
		raise_error ('EAM_INVALID_COMBO');
	    END IF;

        ELSE -- Rebuildable

	    IF (p_inventory_item_id IS NOT NULL and p_serial_number is not null
	     and p_maintenance_object_id IS NULL ) THEN

	      begin
		select instance_id,3
		into l_maintenance_object_id,l_maintenance_object_type
		from csi_item_instances
		where inventory_item_id=p_inventory_item_id
		and serial_number=p_serial_number;

	      exception
		when no_data_found then
			raise_error('EAM_NO_ASSET_FOUND');
	      end;

	    ELSIF ((p_inventory_item_id IS NULL or p_serial_number is null) and
               (p_maintenance_object_type IS NOT NULL and p_maintenance_object_type = 3)) THEN

 	      begin
		select inventory_item_id, serial_number, last_vld_organization_id
		into l_item_id , l_serial_number, l_temp_org_id
		from csi_item_instances
		where instance_id=p_maintenance_object_id;

		IF (l_org_id is null) THEN
		  l_org_id := l_temp_org_id;
		END IF;

	      exception
		when no_data_found then
			raise_error('EAM_NO_ASSET_FOUND');
	      end;

            END IF;

	    /* Check both the combinations are pointing to the same item / serial_number */

	    select count(*) into l_count
    	    from csi_item_instances
	    where instance_id=l_maintenance_object_id
	    and inventory_item_id=l_asset_group_id
	    and serial_number=l_serial_number;

	    if (l_count = 0) then
		raise_error('EAM_INVALID_COMBO');
	    end if;

	END IF;

	validate_application_id( P_APPLICATION_ID);

	validate_descflexfield_name(P_DESCRIPTIVE_FLEXFIELD_NAME);

	validate_descflex_context_code(P_ATTRIBUTE_CATEGORY, P_APPLICATION_ID);

        validate_assos_id(p_association_id, p_creation_organization_id, l_asset_group_id, p_attribute_category, l_item_type);

	VALIDATE_ROW_EXISTS(P_ATTRIBUTE_CATEGORY ,
                              P_ASSOCIATION_ID ,
                              /*P_INVENTORY_ITEM_ID ,*/
			      l_asset_group_id,
                              /*P_SERIAL_NUMBER ,*/
			      l_serial_number,
                              /*P_CREATION_ORGANIZATION_ID , */
			      p_creation_organization_id,
                              FALSE,
			      l_item_type);

	validate_dff_segments(  'EAM',
				p_ATTRIBUTE_CATEGORY	,
				p_c_ATTRIBUTE1	,
				p_c_ATTRIBUTE2	,
				p_c_ATTRIBUTE3	,
				p_c_ATTRIBUTE4	,
				p_c_ATTRIBUTE5	,
				p_c_ATTRIBUTE6	,
				p_c_ATTRIBUTE7	,
				p_c_ATTRIBUTE8	,
				p_c_ATTRIBUTE9	,
				p_c_ATTRIBUTE10	,
				p_c_ATTRIBUTE11	,
				p_c_ATTRIBUTE12	,
				p_c_ATTRIBUTE13	,
				p_c_ATTRIBUTE14	,
				p_c_ATTRIBUTE15	,
				p_c_ATTRIBUTE16	,
				p_c_ATTRIBUTE17	,
				p_c_ATTRIBUTE18	,
				p_c_ATTRIBUTE19	,
				p_c_ATTRIBUTE20	,
				p_n_ATTRIBUTE1	,
				p_n_ATTRIBUTE2	,
				p_n_ATTRIBUTE3	,
				p_n_ATTRIBUTE4	,
				p_n_ATTRIBUTE5	,
				p_n_ATTRIBUTE6	,
				p_n_ATTRIBUTE7	,
				p_n_ATTRIBUTE8	,
				p_n_ATTRIBUTE9	,
				p_n_ATTRIBUTE10	,
				p_d_ATTRIBUTE1	,
				p_d_ATTRIBUTE2	,
				p_d_ATTRIBUTE3	,
				p_d_ATTRIBUTE4	,
				p_d_ATTRIBUTE5	,
				p_d_ATTRIBUTE6	,
				p_d_ATTRIBUTE7	,
				p_d_ATTRIBUTE8	,
				p_d_ATTRIBUTE9	,
				p_d_ATTRIBUTE10
			);


		update MTL_EAM_ASSET_ATTR_VALUES
		set
		--ASSOCIATION_ID	 = 	P_ASSOCIATION_ID		,
		--INVENTORY_ITEM_ID= 	l_asset_group_id,/*P_INVENTORY_ITEM_ID	,*/
		--SERIAL_NUMBER 	 = 	l_serial_number,/*P_SERIAL_NUMBER			,*/
		--ORGANIZATION_ID  = 	P_ORGANIZATION_ID	, do not update this field
		--ATTRIBUTE_CATEGORY = 	P_ATTRIBUTE_CATEGORY	,
		C_ATTRIBUTE1  	 = 	P_C_ATTRIBUTE1			,
		C_ATTRIBUTE2  	 = 	P_C_ATTRIBUTE2			,
		C_ATTRIBUTE3  	 = 	P_C_ATTRIBUTE3			,
		C_ATTRIBUTE4  	 = 	P_C_ATTRIBUTE4			,
		C_ATTRIBUTE5  	 = 	P_C_ATTRIBUTE5			,
		C_ATTRIBUTE6  	 = 	P_C_ATTRIBUTE6			,
		C_ATTRIBUTE7  	 = 	P_C_ATTRIBUTE7			,
		C_ATTRIBUTE8  	 = 	P_C_ATTRIBUTE8			,
		C_ATTRIBUTE9  	 = 	P_C_ATTRIBUTE9			,
		C_ATTRIBUTE10 	 = 	P_C_ATTRIBUTE10			,
		C_ATTRIBUTE11 	 = 	P_C_ATTRIBUTE11			,
		C_ATTRIBUTE12 	 = 	P_C_ATTRIBUTE12			,
		C_ATTRIBUTE13 	 = 	P_C_ATTRIBUTE13			,
		C_ATTRIBUTE14 	 = 	P_C_ATTRIBUTE14			,
		C_ATTRIBUTE15 	 = 	P_C_ATTRIBUTE15			,
		C_ATTRIBUTE16 	 = 	P_C_ATTRIBUTE16			,
		C_ATTRIBUTE17 	 = 	P_C_ATTRIBUTE17			,
		C_ATTRIBUTE18 	 = 	P_C_ATTRIBUTE18			,
		C_ATTRIBUTE19 	 = 	P_C_ATTRIBUTE19			,
		C_ATTRIBUTE20 	 = 	P_C_ATTRIBUTE20			,
		D_ATTRIBUTE1  	 = 	P_D_ATTRIBUTE1			,
		D_ATTRIBUTE2  	 = 	P_D_ATTRIBUTE2			,
		D_ATTRIBUTE3  	 = 	P_D_ATTRIBUTE3			,
		D_ATTRIBUTE4  	 = 	P_D_ATTRIBUTE4			,
		D_ATTRIBUTE5  	 = 	P_D_ATTRIBUTE5			,
		D_ATTRIBUTE6  	 = 	P_D_ATTRIBUTE6			,
		D_ATTRIBUTE7  	 = 	P_D_ATTRIBUTE7			,
		D_ATTRIBUTE8  	 = 	P_D_ATTRIBUTE8			,
		D_ATTRIBUTE9  	 = 	P_D_ATTRIBUTE9			,
		D_ATTRIBUTE10 	 = 	P_D_ATTRIBUTE10			,
		N_ATTRIBUTE1  	 = 	P_N_ATTRIBUTE1			,
		N_ATTRIBUTE2  	 = 	P_N_ATTRIBUTE2			,
		N_ATTRIBUTE3  	 = 	P_N_ATTRIBUTE3			,
		N_ATTRIBUTE4  	 = 	P_N_ATTRIBUTE4			,
		N_ATTRIBUTE5  	 = 	P_N_ATTRIBUTE5			,
		N_ATTRIBUTE6  	 = 	P_N_ATTRIBUTE6			,
		N_ATTRIBUTE7  	 = 	P_N_ATTRIBUTE7			,
		N_ATTRIBUTE8  	 = 	P_N_ATTRIBUTE8			,
		N_ATTRIBUTE9  	 = 	P_N_ATTRIBUTE9			,
		N_ATTRIBUTE10 	 = 	P_N_ATTRIBUTE10			,
		APPLICATION_ID	 = 	P_APPLICATION_ID			,
		DESCRIPTIVE_FLEXFIELD_NAME	 = 	P_DESCRIPTIVE_FLEXFIELD_NAME 	,
		MAINTENANCE_OBJECT_TYPE	 = 	l_maintenance_object_type , /*P_MAINTENANCE_OBJECT_TYPE     		,*/
		MAINTENANCE_OBJECT_ID	 = 	l_maintenance_object_id ,/*P_MAINTENANCE_OBJECT_ID			,*/
		CREATION_ORGANIZATION_ID = 	p_creation_organization_id ,/*P_CREATION_ORGANIZATION_ID  		,*/
		CREATED_BY           	 = 	fnd_global.user_id ,
		CREATION_DATE       	 = 	sysdate		   ,
		LAST_UPDATE_LOGIN  	 = 	fnd_global.login_id,
		LAST_UPDATE_DATE  	 = 	sysdate            ,
		LAST_UPDATED_BY  	 = 	fnd_global.user_id

	where
		ASSOCIATION_ID	 	 = 	P_ASSOCIATION_ID    and
		INVENTORY_ITEM_ID	 = 	l_asset_group_id and
		SERIAL_NUMBER 	 	 = 	l_serial_number and
		/* removing this as creation_organization_id is not used */
		/* decode(l_item_type,1,CREATION_ORGANIZATION_ID,1) = decode(l_item_type,1,p_creation_organization_id,1) and */
		ATTRIBUTE_CATEGORY	 = 	P_ATTRIBUTE_CATEGORY;




	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          =>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO update_assetattr_value;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data         	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO update_assetattr_value;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data         	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO update_assetattr_value;
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
        			p_data         	=>      x_msg_data
    		);
END update_assetattr_value;

END EAM_ASSETATTR_VALUE_PUB;

/

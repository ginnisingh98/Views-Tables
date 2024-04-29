--------------------------------------------------------
--  DDL for Package Body EAM_ASSETATTR_GRP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSETATTR_GRP_PUB" AS
/* $Header: EAMPAAGB.pls 120.3 2005/12/12 01:31:05 sshahid ship $ */
/*
--Start of comments
--      API name        : EAM_ASSETATTR_GRP_PUB
--      Type            : Public
--      Function        : Insert, update and validation of the asset attribute assignemnt data
--      Pre-reqs        : None.
*/

/* This procedure inserts a record in the mtl_eam_asset_attr_groups table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				P_APPLICATION_ID		IN NUMBER
--				P_DESCRIPTIVE_FLEXFIELD_NAME	IN VARCHAR2
--					DEFAULT NULL
--				P_DESC_FLEX_CONTEXT_CODE	IN VARCHAR2
--					DEFAULT NULL
--				P_ORGANIZATION_ID	IN NUMBER
--				P_INVENTORY_ITEM_ID	IN NUMBER
--				P_ENABLED_FLAG		IN VARCHAR2
--					DEFAULT NULL
--				P_CREATION_ORGANIZATION_ID IN NUMBER
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      Notes
--
-- End of comments

*/
/* for de-bugging */
/*g_sr_no		number ;*/

PROCEDURE INSERT_ASSETATTR_GRP
(	P_API_VERSION           	IN		NUMBER				,
  	P_INIT_MSG_LIST	   		IN		VARCHAR2:= FND_API.G_FALSE	,
	P_COMMIT	    		IN  		VARCHAR2:= FND_API.G_FALSE	,
	P_VALIDATION_LEVEL		IN  		NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS	    		OUT NOCOPY	VARCHAR2			,
	X_MSG_COUNT	    		OUT NOCOPY 	NUMBER				,
	X_MSG_DATA	    		OUT NOCOPY 	VARCHAR2			,
	P_APPLICATION_ID		IN		NUMBER	DEFAULT 401			,
	P_DESCRIPTIVE_FLEXFIELD_NAME	IN		VARCHAR2  DEFAULT 'MTL_EAM_ASSET_ATTR_VALUES',
	P_DESC_FLEX_CONTEXT_CODE	IN		VARCHAR2 ,
	P_ORGANIZATION_ID		IN		NUMBER				,
	P_INVENTORY_ITEM_ID		IN		NUMBER				,
	P_ENABLED_FLAG			IN		VARCHAR2 DEFAULT 'Y',
	P_CREATION_ORGANIZATION_ID	IN		NUMBER				,
	X_NEW_ASSOCIATION_ID		OUT NOCOPY	NUMBER
)

IS

l_api_name			CONSTANT VARCHAR2(30)	:='INSERT_ASSETATTR_GRP';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_association_id		number;
l_validated			boolean;
l_item_type number;
l_exists boolean;
l_org_id number;
l_creation_organization_id number;
l_boolean number;


BEGIN

	/* Standard Start of API savepoint */
	SAVEPOINT INSERT_ASSETATTR_GRP_PUB;

	/* Standard call to check for call compatibility. */
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
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

	/* validate item id; get item type */

	l_item_type:=get_item_type(p_creation_organization_id, p_inventory_item_id);
	if (l_item_type is null) then
		raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
	/*elsif (l_item_type=1 and p_organization_id is null) then
		raise_error('EAM_ASSET_ORG_ID_REQ');
	elsif (l_item_type=3 and p_organization_id is not null) then
		raise_error('EAM_REBUILD_ORG_ID_NOT_NULL');
	*/
	elsif (l_item_type<>3 and l_item_type<>1) then
		raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
	end if;

/*	-- Bug # 3518888 : Creation org id need to be validated irrespective of item type
	--if (l_item_type=1) then
		l_validated := VALIDATE_EAM_ENABLED (P_creation_ORGANIZATION_ID);
        	if (not l_validated) then
                	--raise_error('NOT_EAM_ENABLED');
			raise_error ('EAM_ABO_INVALID_CR_ORG_ID');
        	end if;
	--end if;*/

	/* validate that the row does not already exist */
	l_exists:=validate_row_exists
		(p_item_type => l_item_type,
		p_creation_organization_id => p_creation_organization_id,
		p_inventory_item_id => p_inventory_item_id,
		 P_DESC_FLEX_CONTEXT_CODE =>  P_DESC_FLEX_CONTEXT_CODE);

	if (l_exists) then
		raise_error('EAM_AAG_EXISTS');
	end if;

/*
	if p_organization_id IS NOT NULL then
		if (p_organization_id <> p_creation_organization_id) then
			raise_error('EAM_ORG_ID_INCONSISTENT');
		end if;
	end if;
*/
	l_validated := VALIDATE_DESC_FLEX_FIELD_NAME (P_DESCRIPTIVE_FLEXFIELD_NAME);
        if (not l_validated) then
                --raise_error('DFF NOT MTL_EAM_ASSET_ATTR_VALUES');
		raise_error('EAM_INVALID_DFF_NAME');
        end if;


	l_validated := CHECK_DESC_FLEX_CONTEXT_CODE (P_DESC_FLEX_CONTEXT_CODE , P_APPLICATION_ID);
        if (not l_validated) then
                --raise_error('BAD DFF CODE');
		raise_error ('EAM_INVALID_DFF_CODE');
        end if;



	l_validated := VALIDATE_FLAG_FIELD (P_ENABLED_FLAG);
        if (not l_validated) then
                --raise_error('BAD ENABLED_FLAG');
		raise_error('EAM_INVALID_ENABLED_FLAG');
        end if;

/* this is already validated earlier
	l_validated := VALIDATE_ITEM_ID (P_INVENTORY_ITEM_ID , P_ORGANIZATION_ID);
        if (not l_validated) then
               -- raise_error('BAD INVENTORY_ITEM_ID');
	        raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
        end if;
*/
	/* End validation calls */

	SELECT MTL_EAM_ASSET_ATTR_GROUPS_S.NEXTVAL INTO L_ASSOCIATION_ID FROM DUAL;

	X_NEW_ASSOCIATION_ID := L_ASSOCIATION_ID;


	INSERT INTO MTL_EAM_ASSET_ATTR_GROUPS
	(
		ASSOCIATION_ID		       ,
		APPLICATION_ID		       ,
		DESCRIPTIVE_FLEXFIELD_NAME     ,
		DESCRIPTIVE_FLEX_CONTEXT_CODE  ,
		ORGANIZATION_ID                ,
		INVENTORY_ITEM_ID              ,
		LAST_UPDATED_BY		       ,
		LAST_UPDATE_DATE               ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATE_LOGIN              ,
		ENABLED_FLAG                   ,
		CREATION_ORGANIZATION_ID
	)
	VALUES
	(
		L_ASSOCIATION_ID		,
		P_APPLICATION_ID		,
		P_DESCRIPTIVE_FLEXFIELD_NAME	,
		P_DESC_FLEX_CONTEXT_CODE	,
		P_ORGANIZATION_ID		,
		P_INVENTORY_ITEM_ID		,
		FND_GLOBAL.USER_ID		,
	        SYSDATE				,
		FND_GLOBAL.LOGIN_ID		,
	        SYSDATE				,
		FND_GLOBAL.USER_ID		,
		P_ENABLED_FLAG			,
		p_creation_organization_id
	);

	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.GET
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSERT_ASSETATTR_GRP_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Get
    		(  	p_msg_index_out  =>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_ASSETATTR_GRP_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO INSERT_ASSETATTR_GRP_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);
		END IF;

		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

END INSERT_ASSETATTR_GRP;

/*
This procedure updates a record in the mtl_eam_asset_attr_groups table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				P_APPLICATION_ID		IN NUMBER
--				P_DESCRIPTIVE_FLEXFIELD_NAME	IN VARCHAR2
--					DEFAULT NULL
--				P_DESC_FLEX_CONTEXT_CODE	IN VARCHAR2
--					DEFAULT NULL
--				P_ORGANIZATION_ID	IN NUMBER
--				P_INVENTORY_ITEM_ID	IN NUMBER
--				P_ENABLED_FLAG		IN VARCHAR2
--					DEFAULT NULL
--				P_CREATION_ORGANIZATION_ID IN NUMBER
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      Notes
*/

PROCEDURE UPDATE_ASSETATTR_GRP
(	P_API_VERSION           	IN		NUMBER				,
  	P_INIT_MSG_LIST	   		IN		VARCHAR2:= FND_API.G_FALSE	,
	P_COMMIT	    	    	IN  		VARCHAR2:= FND_API.G_FALSE	,
	P_VALIDATION_LEVEL	    	IN  		NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS	    		OUT NOCOPY 	VARCHAR2			,
	X_MSG_COUNT	    		OUT NOCOPY 	NUMBER				,
	X_MSG_DATA	    	    	OUT NOCOPY 	VARCHAR2			,
	P_ASSOCIATION_ID		IN		NUMBER				,
	P_APPLICATION_ID		IN		NUMBER DEFAULT 401				,
	P_DESCRIPTIVE_FLEXFIELD_NAME	IN		VARCHAR2  DEFAULT 'MTL_EAM_ASSET_ATTR_VALUES',
	P_DESC_FLEX_CONTEXT_CODE	IN		VARCHAR2 ,
	P_ORGANIZATION_ID		IN		NUMBER				,
	P_INVENTORY_ITEM_ID		IN		NUMBER				,
	P_ENABLED_FLAG			IN		VARCHAR2 DEFAULT 'Y',
	P_CREATION_ORGANIZATION_ID	IN		NUMBER
)
IS
	l_validated boolean;
	l_api_name			CONSTANT VARCHAR2(30)	:='UPDATE asset attr';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_item_type number;
	l_exists boolean;
	l_org_id number;
	l_creation_organization_id number;
	l_boolean number;

BEGIN

	SAVEPOINT UPDATE_ASSETATTR_GRP_PUB;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--x_return_status := 'success';

	/* API body */
	/* Start validation calls */

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

	/* validate inventory item id; get item type */
	l_item_type:=get_item_type(p_creation_organization_id, p_inventory_item_id);
	if (l_item_type is null) then
		raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
	/*elsif (l_item_type=1 and p_organization_id is null) then
		raise_error('EAM_ASSET_ORG_ID_REQ');
	elsif (l_item_type=3 and p_organization_id is not null) then
		raise_error('EAM_REBUILD_ORG_ID_NOT_NULL');
	*/
	elsif (l_item_type<>1 and l_item_type<>3) then
		raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
	end if;

/*        -- Bug # 3518888 : Creation org id need to be validated irrespective of item type
	--if (l_item_type=1) then
		l_validated := VALIDATE_EAM_ENABLED (P_creation_ORGANIZATION_ID);
        	if (not l_validated) then
                	--raise_error('NOT_EAM_ENABLED');
			raise_error ('EAM_ABO_INVALID_CR_ORG_ID');
        	end if;
	--end if;
*/

	/* validate that the row does not already exist */

	/* Validate that the row exists */
        l_exists:=validate_row_exists
                (p_item_type => l_item_type,
                p_creation_organization_id => p_creation_organization_id,
                p_inventory_item_id => p_inventory_item_id,
                 P_DESC_FLEX_CONTEXT_CODE =>  P_DESC_FLEX_CONTEXT_CODE,
		p_association_id=>p_association_id);

        if (not l_exists) then
                raise_error('EAM_ROW_NOT_EXISTS');
        end if;


	l_validated := VALIDATE_DESC_FLEX_FIELD_NAME (P_DESCRIPTIVE_FLEXFIELD_NAME);
        if (not l_validated) then
               -- raise_error('DFF NOT MTL_EAM_ASSET_ATTR_VALUES');
	       raise_error('EAM_INVALID_DFF_NAME');
        end if;


	l_validated := CHECK_DESC_FLEX_CONTEXT_CODE (P_DESC_FLEX_CONTEXT_CODE , P_APPLICATION_ID);
        if (not l_validated) then
		--raise_error('BAD DFF CODE');
		raise_error ('EAM_INVALID_DFF_CODE');
        end if;



	l_validated := VALIDATE_FLAG_FIELD (P_ENABLED_FLAG);
        if (not l_validated) then
		--raise_error('BAD ENABLED_FLAG');
		raise_error('EAM_INVALID_ENABLED_FLAG');
        end if;

/* This is already validated earlier
	l_validated := VALIDATE_ITEM_ID (P_INVENTORY_ITEM_ID , P_ORGANIZATION_ID);
        if (not l_validated) then
		--raise_error('BAD INVENTORY_ITEM_ID');
		raise_error('EAM_ABO_INVALID_INV_ITEM_ID');
        end if;
*/
/* Standard Start of API savepoint */


UPDATE MTL_EAM_ASSET_ATTR_GROUPS SET
	APPLICATION_ID		= P_APPLICATION_ID			,
	DESCRIPTIVE_FLEXFIELD_NAME	= P_DESCRIPTIVE_FLEXFIELD_NAME	,
	DESCRIPTIVE_FLEX_CONTEXT_CODE	= P_DESC_FLEX_CONTEXT_CODE	,
/*	ORGANIZATION_ID		= P_ORGANIZATION_ID			,
*/	INVENTORY_ITEM_ID	= P_INVENTORY_ITEM_ID			,
	ENABLED_FLAG		= P_ENABLED_FLAG
/*,	CREATION_ORGANIZATION_ID= x_creation_organization_id
*/
WHERE
	ASSOCIATION_ID		= P_ASSOCIATION_ID
	and creation_organization_id=p_creation_organization_id
	and inventory_item_id=p_inventory_item_id
	and descriptive_flex_context_code=p_desc_flex_context_code;


	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_ASSETATTR_GRP_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_ASSETATTR_GRP_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_ASSETATTR_GRP_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);
		END IF;

		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

END UPDATE_ASSETATTR_GRP;


/* VALIDATION 1 */

FUNCTION VALIDATE_DESC_FLEX_FIELD_NAME
	( P_DESCRIPTIVE_FLEXFIELD_NAME VARCHAR2)
	RETURN BOOLEAN
IS
BEGIN
  IF (p_descriptive_flexfield_name is null or
	P_DESCRIPTIVE_FLEXFIELD_NAME <> 'MTL_EAM_ASSET_ATTR_VALUES')
  THEN
	RETURN FALSE;
  ELSE
	RETURN TRUE;
  END IF;
END VALIDATE_DESC_FLEX_FIELD_NAME;


/* VALIDATION 2 */

FUNCTION CHECK_DESC_FLEX_CONTEXT_CODE
	(P_DESC_FLEX_CONTEXT_CODE VARCHAR2,
	P_APPLICATION_ID NUMBER)
	RETURN BOOLEAN
IS
L_STATUS NUMBER;
BEGIN
	SELECT
		count(*) INTO L_status
	FROM
		FND_DESCR_FLEX_CONTEXTS_VL
	WHERE
		DESCRIPTIVE_FLEXFIELD_NAME = 'MTL_EAM_ASSET_ATTR_VALUES'
	AND
		ENABLED_FLAG = 'Y'
	AND
		APPLICATION_ID = P_APPLICATION_ID
	AND
		DESCRIPTIVE_FLEX_CONTEXT_CODE = P_DESC_FLEX_CONTEXT_CODE;

	IF L_status > 0
	THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
EXCEPTION
	when no_data_found then
		return false;
END CHECK_DESC_FLEX_CONTEXT_CODE;


/* VALIDATION 3 */

FUNCTION VALIDATE_EAM_ENABLED
	(P_ORGANIZATION_ID NUMBER)
	RETURN BOOLEAN
IS
L_STATUS NUMBER;
BEGIN
	SELECT count(*) INTO L_status
	FROM wip_eam_PARAMETERS
	WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;


	IF L_status > 0
	THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END VALIDATE_EAM_ENABLED;


/* VALIDATION 4 */

FUNCTION VALIDATE_FLAG_FIELD
	(P_ENABLED_FLAG VARCHAR2)
	RETURN BOOLEAN
IS
BEGIN
        -- Bug # 3518888
	IF P_ENABLED_FLAG  IN ('Y', 'N')THEN
	    RETURN TRUE;
	ELSE
	    RETURN FALSE;
	END IF;
END VALIDATE_FLAG_FIELD;



/* VALIDATION 5 */

FUNCTION VALIDATE_ITEM_ID
	(P_INVENTORY_ITEM_ID NUMBER,
	P_ORGANIZATION_ID NUMBER)
	RETURN BOOLEAN
IS
L_STATUS NUMBER;
BEGIN
	SELECT count(*) INTO L_status
	FROM
		MTL_SYSTEM_ITEMS_KFV
	WHERE
		INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
	AND
		ORGANIZATION_ID = P_ORGANIZATION_ID
	AND
		(EAM_ITEM_TYPE = 1 or EAM_ITEM_TYPE=3);

	IF  L_STATUS >0
	THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

END VALIDATE_ITEM_ID;


/* get item type. 1=asset, 3=rebuildable */
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


FUNCTION validate_row_exists
	(p_item_type in number,
	p_creation_organization_id in number,
	p_inventory_item_id in number,
	P_DESC_FLEX_CONTEXT_CODE in varchar2,
	p_association_id in number default null)
return boolean
is
	l_association_id number;
begin
	/*
	if (p_item_type=1) then
		select association_id into l_association_id
		from mtl_eam_asset_attr_groups
		where creation_organization_id=p_creation_organization_id
		and inventory_item_id=p_inventory_item_id
		and descriptive_flex_context_code=p_desc_flex_context_code;
	elsif (p_item_type=3) then
	*/
		select association_id into l_association_id
                from mtl_eam_asset_attr_groups
                where inventory_item_id=p_inventory_item_id
                and descriptive_flex_context_code=p_desc_flex_context_code;
	--end if;

	if (l_association_id is null) then
		return false;
	elsif (p_association_id is not null and
		l_association_id <> p_association_id) then
		return false;
	else
		return true;
	end if;
exception
	when no_data_found then
		return false;
end;



/* private procedure for raising exceptions */

PROCEDURE RAISE_ERROR (ERROR VARCHAR2)
IS
BEGIN
	FND_MESSAGE.SET_NAME ('EAM', ERROR);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END;

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

END EAM_ASSETATTR_GRP_PUB;

/

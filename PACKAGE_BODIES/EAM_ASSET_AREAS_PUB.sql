--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_AREAS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_AREAS_PUB" AS
/* $Header: EAMPASAB.pls 120.1 2005/11/25 10:24:24 sshahid noship $ */
-- Start of comments
--	API name 	: EAM_ASSET_AREAS_PUB
--	Type		: Public
--	Function	: insert_asset_areas, update_asset_areas
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

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ASSET_AREAS_PUB';

/* private procedure for raising exceptions */
PROCEDURE RAISE_ERROR (ERROR VARCHAR2)
IS
BEGIN
/* debugging */

	FND_MESSAGE.SET_NAME ('EAM', ERROR);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END;

/*
functions for validation
*/
--location code should be unique. return success on code not found
/*not reqd as validate_location_codes already check for the same*/
/*procedure validate_location_codes( p_location_codes IN varchar2, p_organization_id in number,
	x_return_status	OUT VARCHAR2)
is
        l_count number;
  BEGIN
        SELECT count(*) INTO l_count
	FROM   MTL_EAM_LOCATIONS
	WHERE  location_codes = p_location_codes
	  and  creation_organization_id = p_organization_id;

        if l_count > 0
        then
	      fnd_message.set_name('EAM', 'EAM_AA_DUP_LOCATION_CODE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        end if;

END;
*/

PROCEDURE VALIDATE_DATES(
	P_START_DATE 		IN 	DATE	,
	P_END_DATE   		IN 	DATE	,
	x_return_status		OUT  NOCOPY 	VARCHAR2
	)
is
  BEGIN
        if p_start_date = null
        then
	      fnd_message.set_name('EAM', 'EAM_NULL_START_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        end if;


	if (p_end_date is not null and (trunc(p_start_date)>trunc(p_end_date))) then
	      fnd_message.set_name('EAM', 'EAM_INVALID_START_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

/*
        IF TRUNC(P_START_DATE) > TRUNC(SYSDATE)
        THEN
	      fnd_message.set_name('EAM', 'EAM_INVALID_START_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        ELSIF TRUNC(P_START_DATE) > TRUNC(NVL(P_END_DATE,SYSDATE))
        THEN
	      fnd_message.set_name('EAM', 'EAM_INVALID_START_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        ELSIF TRUNC(NVL(P_END_DATE, SYSDATE)) > TRUNC(SYSDATE)
        THEN
	      fnd_message.set_name('EAM', 'EAM_INVALID_END_DATE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
        END IF ;
*/
END;


procedure VALIDATE_ROW_EXISTS(P_LOCATION_CODES IN VARCHAR2 ,
                              P_CREATION_ORGANIZATION_ID IN NUMBER,
                              p_create_flag in boolean)
is
        l_count number;
  BEGIN
        SELECT COUNT(*) INTO l_count
	FROM MTL_EAM_LOCATIONS
	WHERE LOCATION_CODES = P_LOCATION_CODES AND
	      CREATION_ORGANIZATION_ID = P_CREATION_ORGANIZATION_ID;

        if l_count = 0
        then
         if NOT p_create_flag
           then
	      fnd_message.set_name('EAM', 'EAM_LOCATION_REC_NOT_FOUND');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        else
         if p_create_flag
           then
	      fnd_message.set_name('EAM', 'EAM_LOCATION_REC_EXISTS');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;
        end if;
END;


PROCEDURE insert_asset_areas
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,

	x_return_status		OUT NOCOPY 	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,

	p_location_codes	        IN 	varchar2,
	p_start_date	        	IN 	date:=null,
	p_end_date		        IN 	date:=null,
	p_organization_id	        IN 	number,
	p_description	        	IN 	varchar2:=null,
	p_creation_organization_id	IN      number
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_asset_areas';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	L_LOCATION_ID                   NUMBER;
BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	insert_asset_areas;
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

	/* Bug 3668992: effective from date is mandated. */
	if p_start_date IS NULL then
		RAISE_ERROR ('EAM_EFFECTIVE_DATE_NULL');
	end if;

	EAM_COMMON_UTILITIES_PVT.verify_org(
		          p_resp_id => NULL,
		          p_resp_app_id => 401,
		          p_org_id  => P_CREATION_ORGANIZATION_ID,
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


        /*not reqd as validate_location_codes already check for the same*/
	/*validate_location_codes(p_locatIon_codes,
	                        p_creation_organization_id,
	                        l_return_status);
	*/

	IF p_location_codes IS NULL THEN
		RAISE_ERROR ('EAM_LOCATION_CODE_NULL');
	END IF;

	VALIDATE_DATES(
		P_START_DATE =>P_START_DATE,
		P_END_DATE =>P_END_DATE,
		x_return_status=>l_return_status
		);

	if (p_organization_id is not null and p_creation_organization_id is not null and p_organization_id <> p_creation_organization_id) then
	      fnd_message.set_name('EAM', 'EAM_ORG_ID_INCONSISTENT');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;

        VALIDATE_ROW_EXISTS(P_LOCATION_CODES, P_CREATION_ORGANIZATION_ID , TRUE);

        INSERT INTO MTL_EAM_LOCATIONS
        (
		LOCATION_ID,
		LOCATION_CODES,
		START_DATE    ,
		END_DATE      ,
		ORGANIZATION_ID,
		DESCRIPTION    ,
		CREATION_ORGANIZATION_ID,

		CREATED_BY           ,
		CREATION_DATE       ,
		LAST_UPDATE_LOGIN  ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY
	)
	VALUES
	(
		WIP_EAM_LOCATIONS_S.NEXTVAL,
		P_LOCATION_CODES ,
		P_START_DATE     ,
		P_END_DATE       ,
		P_ORGANIZATION_ID,
		P_DESCRIPTION    ,
		P_ORGANIZATION_ID,

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
		ROLLBACK TO insert_asset_areas;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_asset_areas;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO insert_asset_areas;
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
END insert_asset_areas;


PROCEDURE update_asset_areas
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,

	x_return_status		OUT NOCOPY 	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,

	p_location_id	        	IN 	number,
	p_location_codes	        IN 	varchar2,
	p_start_date	        	IN 	date:=null,
	p_end_date		        IN 	date:=null,
	p_organization_id	        IN 	number,
	p_description	        	IN 	varchar2:=null,
	p_creation_organization_id	IN      number
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'update_asset_areas';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_count                         NUMBER;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	update_asset_areas;
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
	/* Bug 3668992: effective from date is mandated. */
	if p_start_date IS NULL then
		RAISE_ERROR ('EAM_EFFECTIVE_DATE_NULL');
	end if;
	EAM_COMMON_UTILITIES_PVT.verify_org(
		          p_resp_id => NULL,
		          p_resp_app_id => 401,
		          p_org_id  => P_CREATION_ORGANIZATION_ID,
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

         VALIDATE_DATES(
		P_START_DATE =>P_START_DATE,
		P_END_DATE =>P_END_DATE,
		x_return_status=>l_return_status
		);

	IF p_location_id IS NULL THEN
		RAISE_ERROR ('EAM_LOCATION_ID_NULL');
	END IF;

	IF p_location_codes IS NULL THEN
		RAISE_ERROR ('EAM_LOCATION_CODE_NULL');
	END IF;

	-- Bug # 3518888 : To check if location id exist for given org.
        --VALIDATE_ROW_EXISTS(P_LOCATION_CODES, P_CREATION_ORGANIZATION_ID , FALSE);

	SELECT COUNT(*) INTO l_count
	FROM MTL_EAM_LOCATIONS
	WHERE CREATION_ORGANIZATION_ID = P_CREATION_ORGANIZATION_ID
	AND LOCATION_ID = P_LOCATION_ID;

	IF(l_count = 0) THEN
          RAISE_ERROR('EAM_LOCATION_REC_NOT_FOUND');
	END IF;

        -- To check if new location_code does not exist for other record.
        SELECT COUNT(*) INTO l_count
	FROM MTL_EAM_LOCATIONS
	WHERE CREATION_ORGANIZATION_ID = P_CREATION_ORGANIZATION_ID
	AND LOCATION_ID <> P_LOCATION_ID
	AND LOCATION_CODES = P_LOCATION_CODES;

	IF(l_count > 0) THEN
          RAISE_ERROR('EAM_AA_DUP_LOCATION_CODE');
	END IF;

        UPDATE MTL_EAM_LOCATIONS
        SET
		LOCATION_CODES	=	P_LOCATION_CODES	,
		START_DATE	=	P_START_DATE	,
		END_DATE	=	P_END_DATE	,
		--ORGANIZATION_ID	=	P_ORGANIZATION_ID	, -- not for update
		DESCRIPTION	=	P_DESCRIPTION	,
		--CREATION_ORGANIZATION_ID = P_CREATION_ORGANIZATION_ID, --not to be updated as it is pk

		LAST_UPDATE_LOGIN = fnd_global.login_id ,
		LAST_UPDATE_DATE  = sysdate,
		LAST_UPDATED_BY   = fnd_global.user_id
	where
		LOCATION_ID = P_LOCATION_ID;




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
		ROLLBACK TO update_asset_areas;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO update_asset_areas;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO update_asset_areas;
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
END update_asset_areas;


END EAM_ASSET_AREAS_PUB;

/

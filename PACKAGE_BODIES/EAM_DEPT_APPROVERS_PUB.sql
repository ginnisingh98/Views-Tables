--------------------------------------------------------
--  DDL for Package Body EAM_DEPT_APPROVERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DEPT_APPROVERS_PUB" AS
/* $Header: EAMPDAPB.pls 120.1 2005/11/25 10:18:21 sshahid noship $ */
-- Start of comments
--	API name 	: EAM_DEPT_APPROVERS_PUB
--	Type		: Public
--	Function	: insert_dept_appr, update_dept_appr
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

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_DEPT_APPROVERS_PUB';

/*
functions for validation
*/
PROCEDURE validate_application_id( P_APPLICATION_ID IN NUMBER)
is
        l_count number;
  BEGIN

        SELECT count(*) INTO l_count
	FROM   FND_APPLICATION
	WHERE  APPLICATION_ID = p_application_id;

        if l_count = 0
        then
	      fnd_message.set_name('EAM', 'EAM_INVALID_APPLICATION_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;

END;


PROCEDURE  validate_responsibility_id (p_resp_id in number , p_resp_app_id in number )
is
        l_count number;
  BEGIN
	  IF p_resp_app_id IS NULL
	  then
              fnd_message.set_name('EAM', 'EAM_DA_INVALID_RESP');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
          end if;
        SELECT COUNT(*) INTO l_count
	FROM fnd_responsibility
	WHERE responsibility_id = p_resp_id
	And application_id = p_resp_app_id;

        if l_count = 0
        then
	      fnd_message.set_name('EAM', 'EAM_DA_INVALID_RESP');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;

END ;

procedure validate_primary_approver_id (p_primary_approver_id IN NUMBER,  p_responsibility_id IN NUMBER)
is
        l_count number;
begin
       IF P_PRIMARY_APPROVER_ID IS NULL  -- primary_approver_id IS NOT MANDATORY FIELD
       THEN
            RETURN;
       END IF;

       IF p_responsibility_id IS NULL
       THEN
	      fnd_message.set_name('EAM', 'EAM_DA_INVALID_RESP');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;

       -- primary_approver_id HAS TO BE VALID USER WITH VALID RESPONSIBILITY ID
       select count(*) into l_count
       FROM FND_USER_RESP_GROUPS GRP WHERE USER_ID = P_PRIMARY_APPROVER_ID
       AND RESPONSIBILITY_ID  = P_RESPONSIBILITY_ID;

        if l_count = 0
        then
	      fnd_message.set_name('EAM', 'EAM_DEPT_INV_PRIMARY_APPROVER');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;

END validate_primary_approver_id;

function validate_department (p_dept_id NUMBER, p_org_id NUMBER)
return boolean
is
	l_count_rec NUMBER := 0;
begin
	select count (*) into l_count_rec
	from bom_departments
	where department_id = p_dept_id
	and organization_id = p_org_id;

	if l_count_rec > 0 then --actually this should be 1
	    return true;
	end if;
	return false;
end validate_department;

function validate_dept_assign (p_dept_id NUMBER, p_responsibility_id NUMBER)
return boolean
is
	l_count_rec NUMBER := 0;
begin
	--A DEPARTMENT CAN HAVE ONLY ONE PRIMARY APPROVER
	select count (*) into l_count_rec
	from BOM_EAM_DEPT_APPROVERS
	where dept_id = p_dept_id
	and responsibility_id = p_responsibility_id;

	if l_count_rec > 0 then --actually this should be 1
	    return true;
	end if;
	return false;
end validate_dept_assign;

procedure VALIDATE_ROW_EXISTS(P_DEPT_ID IN NUMBER,
                             P_ORGANIZATION_ID IN NUMBER,
                             P_RESP_APP_ID IN NUMBER,
                             P_RESPONSIBILITY_ID IN NUMBER,
                             p_create_flag in boolean)
is
        l_count number;
  BEGIN
        -- Bug # 3518888
        IF NOT p_create_flag
           then
	      SELECT COUNT(*) INTO l_count
	      FROM BOM_EAM_DEPT_APPROVERS
	      WHERE DEPT_ID = P_DEPT_ID and
	      ORGANIZATION_ID = P_ORGANIZATION_ID      	and
	      RESPONSIBILITY_APPLICATION_ID = P_RESP_APP_ID and
	      RESPONSIBILITY_ID = P_RESPONSIBILITY_ID;
              if l_count = 0 then
	      	   fnd_message.set_name('EAM', 'EAM_DEPT_REC_NOT_FOUND');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
	      end if;

        ELSIF p_create_flag THEN
		SELECT COUNT(*) INTO l_count
		FROM BOM_EAM_DEPT_APPROVERS
		WHERE DEPT_ID = P_DEPT_ID and
	        ORGANIZATION_ID = P_ORGANIZATION_ID;
		IF l_count > 0 THEN
                   fnd_message.set_name('EAM', 'EAM_DEPT_REC_EXISTS');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
                END IF;
        END IF;
END;

PROCEDURE insert_dept_appr
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,

	x_return_status		OUT NOCOPY 	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,

	p_dept_id			IN 	NUMBER,
	p_organization_id       	IN 	NUMBER,
	p_resp_app_id			IN 	NUMBER,
	p_responsibility_id		IN 	NUMBER,
	p_primary_approver_id  		IN 	NUMBER
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_dept_appr';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_bool                          boolean;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	INSERT_DEPT_APPR;
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

	EAM_COMMON_UTILITIES_PVT.verify_org(
		          p_resp_id => NULL,
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

	/*
	if not 	EAM_COMMON_UTILITIES_PVT.validate_department_id(p_dept_id, p_organization_id)
	  then
	      fnd_message.set_name('EAM', 'EAM_DA_INVALID_DEPT');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if; */

        validate_application_id(p_resp_app_id);

	validate_responsibility_id( p_responsibility_id, p_resp_app_id);

	-- one department per organization
	l_bool := validate_department (p_dept_id , p_organization_id);
	if not l_bool then
	      fnd_message.set_name('EAM', 'EAM_DA_INVALID_DEPT');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;

        -- Bug # 3518888 : Commmenting as it is not required.
        --a dept can be assigned to one responsibility only
	/*l_bool := validate_dept_assign (p_dept_id , p_responsibility_id);
        if l_bool then
		fnd_message.set_name('EAM', 'EAM_INVALID_DEPT_RESP');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;*/

	validate_primary_approver_id (p_primary_approver_id,  p_responsibility_id);

        VALIDATE_ROW_EXISTS(P_DEPT_ID			,
			    P_ORGANIZATION_ID       	,
			    p_resp_app_id ,
			    P_RESPONSIBILITY_ID, true );


	   l_msg_count := FND_MSG_PUB.count_msg;
	   IF l_msg_count > 0 THEN
	      X_msg_count := l_msg_count;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;


        INSERT INTO BOM_EAM_DEPT_APPROVERS
        (
		DEPT_ID			,
		ORGANIZATION_ID       	,
		RESPONSIBILITY_APPLICATION_ID ,
		RESPONSIBILITY_ID	,
		PRIMARY_APPROVER_ID	,

		CREATED_BY           ,
		CREATION_DATE       ,
		LAST_UPDATE_LOGIN  ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY
	)
	VALUES
	(
		P_DEPT_ID			,
		P_ORGANIZATION_ID       	,
		p_resp_app_id ,
		P_RESPONSIBILITY_ID		,
		P_PRIMARY_APPROVER_ID		,

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
		ROLLBACK TO INSERT_DEPT_APPR;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_DEPT_APPR;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO INSERT_DEPT_APPR;
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
END INSERT_DEPT_APPR;


PROCEDURE update_dept_appr
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,

	x_return_status		OUT NOCOPY 	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,

	p_dept_id			IN 	NUMBER,
	p_organization_id       	IN 	NUMBER,
	p_resp_app_id			IN 	NUMBER,
	p_responsibility_id		IN 	NUMBER,
	p_primary_approver_id  		IN 	NUMBER



)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'update_dept_appr';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_bool                          boolean;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	UPDATE_DEPT_APPR;
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

	EAM_COMMON_UTILITIES_PVT.verify_org(
		          p_resp_id => NULL,
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


	/*if not EAM_COMMON_UTILITIES_PVT.validate_department_id(p_dept_id, p_organization_id)
	  then
	      fnd_message.set_name('EAM', 'EAM_DA_INVALID_DEPT');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;*/

	validate_application_id(p_resp_app_id);

	validate_responsibility_id( p_responsibility_id, p_resp_app_id);

	-- one department per organization
	l_bool := validate_department (p_dept_id , p_organization_id);
	if not l_bool then
	      fnd_message.set_name('EAM', 'EAM_DA_INVALID_DEPT');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	end if;

        validate_primary_approver_id (p_primary_approver_id,  p_responsibility_id);

        VALIDATE_ROW_EXISTS(P_DEPT_ID			,
			    P_ORGANIZATION_ID       	,
			    p_resp_app_id ,
			    P_RESPONSIBILITY_ID, false );

        -- Only Approver id can be updated.
        UPDATE BOM_EAM_DEPT_APPROVERS
        SET
		--DEPT_ID = P_DEPT_ID ,
		--ORGANIZATION_ID = P_ORGANIZATION_ID      	,
		--RESPONSIBILITY_APPLICATION_ID = P_RESP_APP_ID ,
		--RESPONSIBILITY_ID = P_RESPONSIBILITY_ID		,
		PRIMARY_APPROVER_ID = P_PRIMARY_APPROVER_ID  ,

		LAST_UPDATE_LOGIN = fnd_global.login_id ,
		LAST_UPDATE_DATE  = sysdate,
		LAST_UPDATED_BY   = fnd_global.user_id
	where
		DEPT_ID = P_DEPT_ID and
		ORGANIZATION_ID = P_ORGANIZATION_ID      	and
		RESPONSIBILITY_APPLICATION_ID = P_RESP_APP_ID and
		RESPONSIBILITY_ID = P_RESPONSIBILITY_ID;

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
		ROLLBACK TO UPDATE_DEPT_APPR;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_DEPT_APPR;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_DEPT_APPR;
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
END update_dept_appr;


END EAM_DEPT_APPROVERS_PUB;

/

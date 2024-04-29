--------------------------------------------------------
--  DDL for Package Body IGW_PROP_NARRATIVES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_NARRATIVES_PVT" as
/* $Header: igwvprnb.pls 115.6 2002/11/15 00:38:17 ashkumar ship $*/
PROCEDURE create_prop_narrative (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 X_ROWID 		          out NOCOPY 	        VARCHAR2,
 P_PROPOSAL_ID                    in	 	NUMBER,
 P_MODULE_TITLE                   in		VARCHAR2,
 P_MODULE_STATUS                  in		VARCHAR2,
 P_CONTACT_NAME                   in            VARCHAR2,
 P_PHONE_NUMBER                   in            VARCHAR2,
 P_EMAIL_ADDRESS                  in            VARCHAR2,
 P_COMMENTS                       in            VARCHAR2,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2)

 is

  STATUS_OF_NARRATIVES       VARCHAR2(1);

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;



BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT create_prop_narrative;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return status to success
   x_return_status := fnd_api.g_ret_sts_success;

-- first validate user rights

        VALIDATE_LOGGED_USER_RIGHTS
			(p_proposal_id		 =>	p_proposal_id
			,x_return_status         =>	x_return_status);

  check_errors;

------------------------------------- value_id conversion ------------------------------------

-------------------------------------------- validations -----------------------------------------------------

-- call table handler
   if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

         igw_prop_narratives_tbh.insert_row(
          	 x_rowid			=>	x_rowid
          	,P_PROPOSAL_ID 			=>	P_PROPOSAL_ID
 		,P_MODULE_TITLE			=>	P_MODULE_TITLE
 		,P_MODULE_STATUS		=>	P_MODULE_STATUS
 		,P_CONTACT_NAME			=>	P_CONTACT_NAME
 		,P_PHONE_NUMBER			=>	P_PHONE_NUMBER
 		,P_EMAIL_ADDRESS		=>	P_EMAIL_ADDRESS
 		,P_COMMENTS			=>	P_COMMENTS
    		,p_mode				=>      'R'
    		,x_return_status		=>	x_return_status);
    	  STATUS_OF_NARRATIVES := IGW_PROP.GET_NARRATIVE_STATUS (P_PROPOSAL_ID);
          IGW_PROP.SET_COMPONENT_STATUS ('NARRATIVE', P_PROPOSAL_ID, STATUS_OF_NARRATIVES);

   end if;

check_errors;

-- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;


-- standard call to get message count and if count is 1, get message info
fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			     p_data	=>	x_msg_data);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_narrative;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_narrative;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_NARRATIVES_PVT',
                            p_procedure_name    =>    'CREATE_PROP_NARRATIVE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END create_prop_narrative;

--------------------------------------------------------------------------------------------------------------

Procedure update_prop_narrative (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 P_PROPOSAL_ID                    in	 	NUMBER,
 P_MODULE_ID                      in		NUMBER,
 P_MODULE_TITLE                   in		VARCHAR2,
 P_MODULE_STATUS                  in		VARCHAR2,
 P_CONTACT_NAME                   in            VARCHAR2,
 P_PHONE_NUMBER                   in            VARCHAR2,
 P_EMAIL_ADDRESS                  in            VARCHAR2,
 P_COMMENTS                       in            VARCHAR2,
 p_record_version_number          IN 		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2)  is

  STATUS_OF_NARRATIVES       VARCHAR2(1);

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT update_prop_narrative;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
    x_return_status := fnd_api.g_ret_sts_success;


-- first validate user rights

        VALIDATE_LOGGED_USER_RIGHTS
			(p_proposal_id		 =>	p_proposal_id
			,x_return_status         =>	x_return_status);

  check_errors;

-- and also check locking.
 	CHECK_LOCK
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
		,x_return_status    		=>	x_return_status);

check_errors;

------------------------------------- value_id conversion ---------------------------------

-------------------------------------------- validations -----------------------------------------------------

            if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
                        igw_prop_narratives_tbh.update_row (
                                    	 x_rowid			 =>	x_rowid
              				,P_PROPOSAL_ID       		 =>	P_PROPOSAL_ID
 					,P_MODULE_ID			 =>	P_MODULE_ID
 					,P_MODULE_TITLE 		 =>	P_MODULE_TITLE
 					,P_MODULE_STATUS            	 =>	P_MODULE_STATUS
 					,P_CONTACT_NAME  		 =>	P_CONTACT_NAME
 					,P_PHONE_NUMBER 		 =>	P_PHONE_NUMBER
 					,P_EMAIL_ADDRESS  		 =>	P_EMAIL_ADDRESS
 					,P_COMMENTS   			 =>	P_COMMENTS
              				,p_mode 			 =>	'R'
              				,p_record_version_number	 =>	p_record_version_number
              				,x_return_status		 =>	x_return_status);
              		  STATUS_OF_NARRATIVES := IGW_PROP.GET_NARRATIVE_STATUS (P_PROPOSAL_ID);
     			  IGW_PROP.SET_COMPONENT_STATUS ('NARRATIVE', P_PROPOSAL_ID, STATUS_OF_NARRATIVES);

	    end if;

check_errors;

-- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;


-- standard call to get message count and if count is 1, get message info
fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			     p_data	=>	x_msg_data);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_prop_narrative;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_prop_narrative;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_NARRATIVES_PVT',
                            p_procedure_name    =>    'UPDATE_PROP_NARRATIVE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_prop_narrative;
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_narrative (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_proposal_id			 IN             NUMBER
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2)  is

  STATUS_OF_NARRATIVES       VARCHAR2(1);
  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_performing_org_id        NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_module_id                NUMBER;

BEGIN
-- create savepoint
   IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT delete_prop_narrative;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

-- initialize return_status to sucess
   x_return_status := fnd_api.g_ret_sts_success;

-- first validate user rights

        VALIDATE_LOGGED_USER_RIGHTS
			(p_proposal_id		 =>	p_proposal_id
			,x_return_status         =>	x_return_status);

  check_errors;

-- check locking
 	CHECK_LOCK
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
		,x_return_status    		=>	x_return_status);

check_errors;

-------------------------------------------- validations -----------------------------------------------------


  if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      select module_id into l_module_id from igw_prop_narratives where rowid = x_rowid;

     igw_prop_narratives_tbh.delete_row(
      	     x_rowid			=>	x_rowid,
	     p_record_version_number	=>	p_record_version_number,
             x_return_status		=>	x_return_status);


     FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS('IGW_PROP_NARRATIVES',
                                                    p_proposal_id, l_module_id);

     STATUS_OF_NARRATIVES := IGW_PROP.GET_NARRATIVE_STATUS (P_PROPOSAL_ID);
     IGW_PROP.SET_COMPONENT_STATUS ('NARRATIVE', P_PROPOSAL_ID, STATUS_OF_NARRATIVES);
  end if;


  check_errors;

  -- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;


-- standard call to get message count and if count is 1, get message info
fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			  p_data	=>	x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO delete_prop_narrative;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO delete_prop_narrative;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_NARRATIVES_PVT',
                            p_procedure_name    =>    'DELETE_PROP_NARRATIVE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

END delete_prop_narrative;

------------------------------------------------------------------------------------------
Procedure update_narrative_type_code (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 P_PROPOSAL_ID                    in	 	NUMBER,
 P_NARRATIVE_TYPE_CODE            in            VARCHAR2,
 P_NARRATIVE_SUBMISSION_CODE      in            VARCHAR2,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2)  is

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT update_narrative_type_code;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
    x_return_status := fnd_api.g_ret_sts_success;


-- first validate user rights

        VALIDATE_LOGGED_USER_RIGHTS
			(p_proposal_id		 =>	p_proposal_id
			,x_return_status         =>	x_return_status);

check_errors;

------------------------------------- value_id conversion ---------------------------------

-------------------------------------------- validations -----------------------------------------------------

            if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

                  UPDATE IGW_PROPOSALS_ALL
                  SET NARRATIVE_TYPE_CODE = P_NARRATIVE_TYPE_CODE,
                  NARRATIVE_SUBMISSION_CODE = P_NARRATIVE_SUBMISSION_CODE
                  WHERE PROPOSAL_ID = P_PROPOSAL_ID;


	    end if;

check_errors;

-- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;


-- standard call to get message count and if count is 1, get message info
fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			     p_data	=>	x_msg_data);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_narrative_type_code;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_narrative_type_code;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_NARRATIVES_PVT',
                            p_procedure_name    =>    'UPDATE_PROP_NARRATIVE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_narrative_type_code;
--------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 l_proposal_id		number;
 BEGIN
   select proposal_id
   into l_proposal_id
   from igw_prop_narratives
   where rowid = x_rowid
   and record_version_number = p_record_version_number;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;

    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_NARRATIVES_PVT',
                            p_procedure_name => 'CHECK_LOCK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
          raise fnd_api.g_exc_unexpected_error;

END CHECK_LOCK;

-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS is
 l_msg_count 	NUMBER;
 BEGIN
       	l_msg_count := fnd_msg_pub.count_msg;
        IF (l_msg_count > 0) THEN
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

 END CHECK_ERRORS;

-------------------------------------------------------------------------------------------------

PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2) is

x		VARCHAR2(1);
y		VARCHAR2(1);

BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF (IGW_SECURITY.ALLOW_MODIFY ('NARRATIVE', P_PROPOSAL_ID, FND_GLOBAL.USER_ID) = 'N') THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('IGW', 'IGW_NO_RIGHTS');
         fnd_msg_pub.add;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_NARRATIVES_PVT',
                            p_procedure_name => 'VALIDATE_LOGGED_USER_RIGHTS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise fnd_api.g_exc_unexpected_error;
END VALIDATE_LOGGED_USER_RIGHTS;


END IGW_PROP_NARRATIVES_PVT;

/

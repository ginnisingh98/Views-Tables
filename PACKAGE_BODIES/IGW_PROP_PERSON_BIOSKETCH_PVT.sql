--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_BIOSKETCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_BIOSKETCH_PVT" as
 /* $Header: igwvppbb.pls 115.3 2002/11/15 00:41:23 ashkumar ship $*/


Procedure update_prop_person_biosketch (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 P_PROPOSAL_ID               	  IN	 	NUMBER,
 P_PERSON_BIOSKETCH_ID       	  IN		NUMBER,
 P_SHOW_FLAG 		     	  IN            VARCHAR2,
 P_LINE_SEQUENCE	     	  IN		NUMBER,
 p_record_version_number          IN 		NUMBER,
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
        SAVEPOINT update_prop_person_biosketch;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
    x_return_status := fnd_api.g_ret_sts_success;

/*
-- first validate user rights

        VALIDATE_LOGGED_USER_RIGHTS
			(p_proposal_id		 =>	p_proposal_id
			,x_return_status         =>	x_return_status);

  check_errors;
*/

-- and also check locking.
 	CHECK_LOCK
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
		,x_return_status    		=>	x_return_status);

check_errors;

------------------------------------- value_id conversion ---------------------------------

-------------------------------------------- validations -----------------------------------------------------

            if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
                        igw_prop_person_biosketch_tbh.update_row (
                                    	 x_rowid			 =>	x_rowid
              				,P_PROPOSAL_ID       		 =>	P_PROPOSAL_ID
 					,P_PERSON_BIOSKETCH_ID         	=>	P_PERSON_BIOSKETCH_ID
 					,P_SHOW_FLAG      		 =>	P_SHOW_FLAG
 					,P_LINE_SEQUENCE     		 =>	P_LINE_SEQUENCE
              				,p_mode 			 =>	'R'
              				,p_record_version_number	 =>	p_record_version_number
              				,x_return_status		 =>	x_return_status);

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
              ROLLBACK TO update_prop_person_biosketch;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_prop_person_biosketch;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_PERSON_BIOSKETCH_PVT',
                            p_procedure_name    =>    'UPDATE_PROP_PERSON_BIOSKETCH',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_prop_person_biosketch;

------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 l_proposal_id		number;
 BEGIN
   select proposal_id
   into l_proposal_id
   from igw_prop_person_biosketch
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
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_PERSON_BIOSKETCH_PVT',
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

--------------------------------------------------------------------------------------------------------
/*
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
*/

END IGW_PROP_PERSON_BIOSKETCH_PVT;

/

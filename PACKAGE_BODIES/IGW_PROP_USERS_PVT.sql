--------------------------------------------------------
--  DDL for Package Body IGW_PROP_USERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_USERS_PVT" as
 /* $Header: igwvprub.pls 115.9 2002/11/15 00:46:16 ashkumar ship $*/
PROCEDURE create_prop_user (
  p_init_msg_list                IN 		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         OUT NOCOPY  		VARCHAR2
 ,p_proposal_id			 IN 		NUMBER
 ,p_proposal_number		 IN		VARCHAR2
 ,p_user_id               	 IN 		NUMBER
 ,p_user_name			 IN		VARCHAR2
 ,p_full_name			 IN		VARCHAR2
 ,p_start_date_active     	 IN		DATE
 ,p_end_date_active       	 IN		DATE
 ,p_logged_user_id		 IN     	NUMBER
 ,x_return_status                OUT NOCOPY 		VARCHAR2
 ,x_msg_count                    OUT NOCOPY 		NUMBER
 ,x_msg_data                     OUT NOCOPY 		VARCHAR2)

 is

    l_msg_data                 VARCHAR2(250);
    l_msg_count                NUMBER;
    l_error_msg_code           VARCHAR2(250);
    l_data                     VARCHAR2(250);
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(1);

   l_proposal_id              NUMBER := p_proposal_id;
   l_user_id                  NUMBER := p_user_id;
   l_person_id 		      NUMBER;



BEGIN

-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT create_user;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return status to success
   x_return_status := fnd_api.g_ret_sts_success;

------------------------------------- value_id conversion ------------------------------------
-- if proposal_id is null, then get it

   IF (p_proposal_id is null ) THEN
          IGW_UTILS.GET_PROPOSAL_ID
                           	(p_context_field	=> 'PROPOSAL_ID'
                           	,p_check_id_flag	=>  'N'
                           	,p_proposal_number 	=>  p_proposal_number
                           	,p_proposal_id		=>  p_proposal_id
                           	,x_proposal_id 		=> l_proposal_id
      				,x_return_status       	=> x_return_status);
   END IF;

-- get user_id from LOV only, suspend validations for now

    IF ((p_user_id is null) OR (p_full_name is null)) THEN
        fnd_message.set_name('IGW', 'IGW_SS_UTL_PERSON_NAME_INVALID');
        fnd_msg_pub.add;
    END IF;

/*
     IF (p_full_name is null) THEN
         l_user_id := null;
     ELSE


          IGW_UTILS.GET_PERSON_ID
                                (p_context_field	=> 	'PERSON_ID'
                                ,p_check_id_flag	=> 	'N'
                                ,p_full_name		=> 	p_full_name
                                ,p_person_id		=> 	null
                                ,x_person_id 		=> 	l_person_id
      				,x_return_status       	=> 	x_return_status);

          check_errors;

      	  IGW_UTILS.GET_PERSON_USER_ID
                                (p_context_field	=> 	'PERSON_ID'
                                ,p_check_id_flag	=> 	'N'
                                ,p_person_id		=> 	l_person_id
                                ,p_user_id		=> 	p_user_id
                                ,x_user_id 		=> 	l_user_id
      				,x_return_status       	=> 	x_return_status);
      	  check_errors;

     END IF;
*/
 check_errors;

-------------------------------------------- validations -----------------------------------------------------
-- validate that the user who has logged on has the rights to modify user

     IGW_PROP_USER_ROLES_PVT.VALIDATE_LOGGED_USER_RIGHTS
                    (p_proposal_id		=>      l_proposal_id
                    ,p_logged_user_id    	=>      p_logged_user_id
                    ,x_return_status            =>	x_return_status);
check_errors;
-- check if user has seeded role
      CHECK_IF_USER_HAS_SEEDED_ROLE
                 (p_proposal_id	         =>     l_proposal_id
                 ,p_user_id		 =>	l_user_id
                 ,x_return_status        =>	x_return_status);

-- check if start and end dates are valid
 IGW_UTILS.CHECK_DATE_VALIDITY (
  p_context_field	   =>	'IGW_SS_UTL_END_DT_BEFORE_START'
 ,p_start_date	   	   =>	p_start_date_active
 ,p_end_date	           =>	p_end_date_active
 ,x_return_status      	   =>   x_return_status	);

check_errors;

 if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

  igw_prop_users_tbh.insert_row (
    x_rowid		=>	x_rowid,
    p_proposal_id	=> 	l_proposal_id,
    p_user_id		=>	l_user_id,
    p_start_date_active	=>	p_start_date_active,
    p_end_date_active 	=>	p_end_date_active,
    p_mode 		=>	'R',
    x_return_status	=>	x_return_status);

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
              ROLLBACK TO create_user;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_user;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_USERS_PVT',
                            p_procedure_name    =>    'CREATE_PROP_USER',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);




END create_prop_user;
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_user (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         IN 	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_full_name			 IN	VARCHAR2
 ,p_start_date_active     	 IN	DATE
 ,p_end_date_active       	 IN	DATE
 ,p_logged_user_id		 IN     NUMBER
 ,p_record_version_number        IN 	NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2)  is


    l_msg_data                 VARCHAR2(250);
    l_msg_count                NUMBER;
    l_error_msg_code           VARCHAR2(250);
    l_data                     VARCHAR2(250);
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(1);

   l_proposal_id              NUMBER;
   l_proposal_id2	      NUMBER := p_proposal_id;
   l_user_id		      NUMBER;
   l_user_id2		      NUMBER := p_user_id;
   l_start_date_active	      DATE;
   l_end_date_active          DATE;
   l_person_id 		      NUMBER;

BEGIN
-- create savepoint if p_commit is true
IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_user;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
       fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
   x_return_status := fnd_api.g_ret_sts_success;

-- get proposal_id, user_id from igw_prop_users using x_rowid and record_version_number
-- and also check locking. The columns fetched are the old data, i.e., the data that is being overwritten
 CHECK_LOCK_GET_COLS
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
                ,x_proposal_id			=>	l_proposal_id
		,x_user_id			=>	l_user_id
		,x_start_date_active		=>      l_start_date_active
		,x_end_date_active		=>	l_end_date_active
		,x_return_status    		=>	x_return_status);

check_errors;

-- first validate that the user who has logged on has the rights to modify user roles

     IGW_PROP_USER_ROLES_PVT.VALIDATE_LOGGED_USER_RIGHTS
                    (p_proposal_id		=>      l_proposal_id
                    ,p_logged_user_id    	=>      p_logged_user_id
                    ,x_return_status            =>	x_return_status);


check_errors;

------------------------------------- value_id conversion (for new data) ------------------------------------

-- if proposal_id is null, then get it

   IF (p_proposal_id is null) THEN
          IGW_UTILS.GET_PROPOSAL_ID
                           	(p_context_field	=> 'PROPOSAL_ID'
                           	,p_check_id_flag	=>  'N'
                           	,p_proposal_number 	=>  p_proposal_number
                           	,p_proposal_id		=>  p_proposal_id
                           	,x_proposal_id 		=> l_proposal_id2
      				,x_return_status       	=> x_return_status);
   END IF;


  -- get user_id from LOV only, suspend validations for now

    IF ((p_user_id is null) OR (p_full_name is null)) THEN
        fnd_message.set_name('IGW', 'IGW_SS_UTL_PERSON_NAME_INVALID');
        fnd_msg_pub.add;
    END IF;



/*
     IF (p_full_name is null) THEN
         l_user_id2 := null;
     ELSE
          IGW_UTILS.GET_PERSON_ID
                                (p_context_field	=> 	'PERSON_ID'
                                ,p_check_id_flag	=> 	'N'
                                ,p_full_name		=> 	p_full_name
                                ,p_person_id		=> 	null
                                ,x_person_id 		=> 	l_person_id
      				,x_return_status       	=> 	x_return_status);
      	  check_errors;

      	  IGW_UTILS.GET_PERSON_USER_ID
                                (p_context_field	=> 	'PERSON_ID'
                                ,p_check_id_flag	=> 	'N'
                                ,p_person_id		=> 	l_person_id
                                ,p_user_id		=> 	p_user_id
                                ,x_user_id 		=> 	l_user_id2
      				,x_return_status       	=> 	x_return_status);
      	  check_errors;

     END IF;
*/
 check_errors;

-------------------------------------------- validations -----------------------------------------------------
-- now we have both old and new values. Do validations on the old values first, then do on the new
--   values if diffent from the new values.


     if ((l_proposal_id <> l_proposal_id2)
          OR (l_user_id <> l_user_id2)
          OR (to_char(l_start_date_active, 'DD:MM:YYYY') <> to_char(p_start_date_active, 'DD:MM:YYYY'))
          OR (to_char(nvl(l_end_date_active, SYSDATE), 'DD:MM:YYYY') <> to_char(nvl(p_end_date_active, SYSDATE), 'DD:MM:YYYY'))) then

         -- validate that role is not a seeded role

         CHECK_IF_USER_HAS_SEEDED_ROLE
                    (p_proposal_id     =>	l_proposal_id
                    ,p_user_id	       =>	l_user_id
                    ,x_return_status   =>	x_return_status);

         check_errors;

         CHECK_IF_USER_HAS_SEEDED_ROLE
                    (p_proposal_id     =>	l_proposal_id2
                    ,p_user_id	       =>	l_user_id2
                    ,x_return_status   =>	x_return_status);

          check_errors;

         IGW_UTILS.CHECK_DATE_VALIDITY (
                p_context_field	   	=>	'IGW_SS_UTL_END_DT_BEFORE_START'
  	       ,p_start_date		=>	p_start_date_active
 	       ,p_end_date		=>	p_end_date_active
               ,x_return_status      	=>      x_return_status);

         check_errors;

         if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
         	igw_prop_users_tbh.update_row (
    			x_rowid				=>	x_rowid,
    			p_proposal_id			=>	l_proposal_id2,
    			p_user_id			=>	l_user_id2,
    			p_start_date_active		=>	p_start_date_active,
    			p_end_date_active 		=>	p_end_date_active,
    			p_record_version_number		=>	p_record_version_number,
    			p_mode 				=>	'R',
    			x_return_status			=>	l_return_status);

          -- also update the detail records in igw_prop_user_roles
                  if ((l_proposal_id <> l_proposal_id2)  OR (l_user_id <> l_user_id2)) then
                           update igw_prop_user_roles
                           set proposal_id = l_proposal_id2,
                               user_id = l_user_id2
                           where proposal_id = l_proposal_id
                           and user_id = l_user_id;
                  end if;

          end if;

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
              ROLLBACK TO update_user;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_user;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_USERS_PVT',
                            p_procedure_name    =>    'UPDATE_PROP_USER',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_prop_user;
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_user (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_logged_user_id		 IN     	NUMBER
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2)  is

    l_msg_data                 VARCHAR2(250);
    l_msg_count                NUMBER;
    l_error_msg_code           VARCHAR2(250);
    l_data                     VARCHAR2(250);
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(1);

   l_proposal_id              NUMBER;
   l_user_id		      NUMBER;
   l_start_date_active        DATE;
   l_end_date_active          DATE;

BEGIN
-- create savepoint
   IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT delete_user;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

-- initialize return_status to sucess
   x_return_status := fnd_api.g_ret_sts_success;

-- get proposal_id, user_id, role_id from igw_prop_users using x_rowid and record_version_number
-- and also check locking
 CHECK_LOCK_GET_COLS
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
                ,x_proposal_id			=>	l_proposal_id
		,x_user_id			=>	l_user_id
		,x_start_date_active		=>	l_start_date_active
		,x_end_date_active		=>	l_end_date_active
		,x_return_status    		=>	x_return_status);

-- validate that the user who has logged on has the rights to modify user roles

     IGW_PROP_USER_ROLES_PVT.VALIDATE_LOGGED_USER_RIGHTS
                    (p_proposal_id		=>      l_proposal_id
                    ,p_logged_user_id    	=>      p_logged_user_id
                    ,x_return_status            =>	x_return_status);

check_errors;

-------------------------------------------- validations -----------------------------------------------------

-- validate that user does not have seeded roles

     CHECK_IF_USER_HAS_SEEDED_ROLE
                    (p_proposal_id	=>	l_proposal_id
                    ,p_user_id		=>	l_user_id
                    ,x_return_status   =>	x_return_status);

check_errors;

if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
     igw_prop_users_tbh.delete_row (
    		x_rowid			=>	x_rowid,
    		p_record_version_number	=>	p_record_version_number,
    		x_return_status		=>	l_return_status);
  -- also delete the child rows in igw_prop_user_roles
   delete from igw_prop_user_roles
   where proposal_id = l_proposal_id
   and user_id = l_user_id;

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
              ROLLBACK TO delete_user;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO delete_user;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_USERS_PVT',
                            p_procedure_name    =>    'DELETE_PROP_USER',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END delete_prop_user;

------------------------------------------------------------------------------------------
PROCEDURE CHECK_IF_USER_HAS_SEEDED_ROLE
(p_proposal_id	          IN  NUMBER
,p_user_id		  IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2) is

N			NUMBER;

BEGIN
 x_return_status:= FND_API.G_RET_STS_SUCCESS;

select count(*) into N
from igw_prop_user_roles
where proposal_id = p_proposal_id
and   user_id     = p_user_id
and   role_id in (select role_id from igw_roles where seeded_flag = 'Y');


if (N <> 0) then
    x_return_status:= FND_API.G_RET_STS_ERROR;
    fnd_message.set_name ('IGW', 'IGW_SEEDED_ROLE');
    fnd_msg_pub.add;
end if;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_USER_ROLES_PVT',
                            p_procedure_name => 'CHECK_IF_SEEDED_ROLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise fnd_api.g_exc_unexpected_error;
END CHECK_IF_USER_HAS_SEEDED_ROLE;
------------------------------------------------------------------------------------------

PROCEDURE CHECK_LOCK_GET_COLS
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
                ,x_proposal_id			OUT NOCOPY	NUMBER
		,x_user_id			OUT NOCOPY	NUMBER
		,x_start_date_active		OUT NOCOPY     DATE
		,x_end_date_active		OUT NOCOPY	DATE
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 BEGIN
   select proposal_id, user_id, start_date_active, end_date_active
   into x_proposal_id, x_user_id, x_start_date_active, x_end_date_active
   from igw_prop_users
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
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_USERS_PVT',
                                  p_procedure_name => 'CHECK_LOCK_GET_PK',
                                  p_error_text     => SUBSTRB(SQLERRM,1,240));
          raise fnd_api.g_exc_unexpected_error;


END CHECK_LOCK_GET_COLS;
-------------------------------------------------------------------------------------

PROCEDURE CHECK_ERRORS is
 l_msg_count 	NUMBER;
 BEGIN
       	l_msg_count := fnd_msg_pub.count_msg;
        IF (l_msg_count > 0) THEN
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

END CHECK_ERRORS;

END IGW_PROP_USERS_PVT;

/

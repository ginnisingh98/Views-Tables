--------------------------------------------------------
--  DDL for Package Body IGW_PROP_USER_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_USER_ROLES_PVT" as
/* $Header: igwvpurb.pls 115.8 2002/11/18 19:20:06 ashkumar ship $*/
PROCEDURE create_prop_user_role (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         OUT NOCOPY  	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_role_id               	 IN 	NUMBER
 ,p_role_name			 IN	VARCHAR2
 ,p_logged_user_id		 IN     NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2)

 is

  l_proposal_id              NUMBER := p_proposal_id;
  l_user_id                  NUMBER := p_user_id;
  l_role_id		     NUMBER := p_role_id;

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;



BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT create_user_role;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return status to success
   x_return_status := fnd_api.g_ret_sts_success;

------------------------------------- value_id conversion ------------------------------------
/*
-- if proposal_id is null, then get it

   IF (p_proposal_id is null) THEN
          IGW_UTILS.GET_PROPOSAL_ID
                           	(p_context_field	=> 'PROPOSAL_ID'
                           	,p_proposal_number 	=> p_proposal_number
                           	,x_proposal_id 		=> l_proposal_id
      				,x_return_status       	=> x_return_status);
   END IF;

-- if user_id is null, then get it

   IF (p_user_id is null) THEN
          IGW_UTILS.GET_USER_ID
                           	(x_user_id 		=> l_user_id
                           	,p_user_name 		=> p_user_name
      				,x_return_status       	=> x_return_status);
   END IF;
*/
-- get role_id
   IF (p_role_name is null) THEN
       l_role_id := null;
   ELSE
 --  IF (p_role_id is null) THEN
   	GET_ROLE_ID  (p_role_name 		=> p_role_name
   	  	     ,x_role_id 		=> l_role_id
      		     ,x_return_status       	=> x_return_status);
--   END IF;
   END IF;

 check_errors;

-------------------------------------------- validations -----------------------------------------------------
-- validate that the user who has logged on has the rights to modify user roles

     VALIDATE_LOGGED_USER_RIGHTS
                    (p_proposal_id		=>      l_proposal_id
                    ,p_logged_user_id    	=>      p_logged_user_id
                    ,x_return_status            =>	x_return_status);

check_errors;

-- validate that role is not a seeded role

     CHECK_IF_SEEDED_ROLE
                    (p_role_id	       =>	l_role_id
                    ,x_return_status   =>	x_return_status);


check_errors;

-- call table handler
   if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

         igw_prop_user_roles_tbh.insert_row(
          	x_rowid			=>	x_rowid,
          	p_proposal_id		=>	l_proposal_id,
    		p_user_id		=>	l_user_id,
    		p_role_id		=>	l_role_id,
    		p_mode			=>      'R',
    		x_return_status		=>	x_return_status);

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
              ROLLBACK TO create_user_role;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_user_role;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_USER_ROLES_PVT',
                            p_procedure_name    =>    'CREATE_USER_ROLE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END create_prop_user_role;
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_user_role (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         IN 	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_role_id               	 IN 	NUMBER
 ,p_role_name 			 IN	VARCHAR2
 ,p_logged_user_id		 IN     NUMBER
 ,p_record_version_number        IN 	NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2)  is


  l_proposal_id              NUMBER;
  l_proposal_id2	     NUMBER := p_proposal_id;
  l_user_id		     NUMBER;
  l_user_id2		     NUMBER := p_user_id;
  l_role_id		     NUMBER;
  l_role_id2		     NUMBER := p_role_id;


  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_performing_org_id        NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT update_user_role;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
    x_return_status := fnd_api.g_ret_sts_success;

-- get proposal_id, user_id, role_id from igw_prop_user_roles using x_rowid and record_version_number
-- and also check locking. The columns fetched are the old data, i.e., the data that is being overwritten
 CHECK_LOCK_GET_PK
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
                ,x_proposal_id			=>	l_proposal_id
		,x_user_id			=>	l_user_id
		,x_role_id			=>	l_role_id
		,x_return_status    		=>	x_return_status);

check_errors;

------------------------------------- value_id conversion (for new data) ------------------------------------
 -- first validate that the user who has logged on has the rights to modify user roles

   VALIDATE_LOGGED_USER_RIGHTS
                    (p_proposal_id		=>      l_proposal_id
                    ,p_logged_user_id    	=>      p_logged_user_id
                    ,x_return_status            =>	x_return_status);

check_errors;
/*
-- if proposal_id is null, then get it

   IF (p_proposal_id is null) THEN
          IGW_UTILS.GET_PROPOSAL_ID
                           	(p_context_field	=> 'PROPOSAL_ID'
                           	,p_proposal_number 	=> p_proposal_number
                           	,x_proposal_id 		=> l_proposal_id2
      				,x_return_status       	=> x_return_status);
   END IF;

-- if user_id is null, then get it

   IF (p_user_id is null) THEN
          IGW_UTILS.GET_USER_ID
                           	(p_user_name 		=> p_user_name
                           	,x_user_id 		=> l_user_id2
      				,x_return_status       	=> x_return_status);
   END IF;
*/

 -- get role_id
   IF (p_role_name is null) THEN
       l_role_id := null;
   ELSE
 --  IF (p_role_id is null) THEN
   	GET_ROLE_ID  (p_role_name 		=> p_role_name
   	  	     ,x_role_id 		=> l_role_id2
      		     ,x_return_status       	=> x_return_status);
--   END IF;
   END IF;

 check_errors;


-------------------------------------------- validations -----------------------------------------------------
-- now we have both old and new values. Do validations on the old values first, then do on the new
--   values if diffent from the new values.


     if (l_role_id <> l_role_id2) then

            -- validate that role is not a seeded role

            CHECK_IF_SEEDED_ROLE
                    (p_role_id	       =>	l_role_id
                    ,x_return_status   =>	x_return_status);



            CHECK_IF_SEEDED_ROLE
                    (p_role_id	       =>	l_role_id2
                    ,x_return_status   =>	x_return_status);



            check_errors;

            if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
                        igw_prop_user_roles_tbh.update_row (
                                    	x_rowid			=>	x_rowid,
              				p_proposal_id		=>	l_proposal_id2,
              				p_user_id		=>	l_user_id2,
              				p_role_id		=>	l_role_id2,
              				p_mode 			=>	'R',
              				p_record_version_number	=>	p_record_version_number,
              				x_return_status		=>	x_return_status);

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
              ROLLBACK TO update_user_role;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_user_role;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_USER_ROLES_PVT',
                            p_procedure_name    =>    'UPDATE_USER_ROLE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_prop_user_role;
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_user_role (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_logged_user_id		 IN     	NUMBER
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2)  is

  l_proposal_id              NUMBER;
  l_user_id		     NUMBER;
  l_role_id		     NUMBER;



  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_performing_org_id        NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
-- create savepoint
   IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT delete_user_role;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

-- initialize return_status to sucess
   x_return_status := fnd_api.g_ret_sts_success;


-- get proposal_id, user_id, role_id from igw_prop_user_roles using x_rowid and record_version_number
-- and also check locking
 CHECK_LOCK_GET_PK
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
                ,x_proposal_id			=>	l_proposal_id
		,x_user_id			=>	l_user_id
		,x_role_id			=>	l_role_id
		,x_return_status    		=>	x_return_status);

check_errors;

-------------------------------------------- validations -----------------------------------------------------

-- first validate that the user who has logged on has the rights to modify user roles

     VALIDATE_LOGGED_USER_RIGHTS
                    (p_proposal_id		=>      l_proposal_id
                    ,p_logged_user_id    	=>      p_logged_user_id
                    ,x_return_status            =>	x_return_status);

check_errors;
-- validate that role is not a seeded role

     CHECK_IF_SEEDED_ROLE
                    (p_role_id	       =>	l_role_id
                    ,x_return_status   =>	x_return_status);

check_errors;


  if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

     igw_prop_user_roles_tbh.delete_row(
      	     x_rowid			=>	x_rowid,
	     p_record_version_number	=>	p_record_version_number,
             x_return_status		=>	x_return_status);

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
              ROLLBACK TO delete_user_role;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO delete_user_role;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_USER_ROLES_PVT',
                            p_procedure_name    =>    'DELETE_USER_ROLE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

END delete_prop_user_role;
-----------------------------------------------------------------------------------

PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,p_logged_user_id         IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2) is

x		VARCHAR2(1);
y		VARCHAR2(1);

BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;

    select x into y
    from igw_prop_user_roles  ppr,
         igw_prop_users  ppu
    where ppr.proposal_id = p_proposal_id  	AND
         ppr.proposal_id = ppu.proposal_id      AND
         ppr.user_id = ppu.user_id   		AND
         ppr.role_id in (0,2,3)		        AND
         ppr.user_id = p_logged_user_id		AND
         sysdate >= ppu.start_date_active  	AND
         sysdate <= nvl(ppu.end_date_active, sysdate);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('IGW', 'IGW_NO_RIGHTS');
    fnd_msg_pub.add;

  WHEN too_many_rows THEN
      NULL;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_USER_ROLES_PVT',
                            p_procedure_name => 'VALIDATE_LOGGED_USER_RIGHTS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise fnd_api.g_exc_unexpected_error;
END VALIDATE_LOGGED_USER_RIGHTS;

------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK_GET_PK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
                ,x_proposal_id			OUT NOCOPY	NUMBER
		,x_user_id			OUT NOCOPY	NUMBER
		,x_role_id			OUT NOCOPY      NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 BEGIN
   select proposal_id, user_id, role_id
   into x_proposal_id, x_user_id, x_role_id
   from igw_prop_user_roles
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
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_USER_ROLES_PVT',
                            p_procedure_name => 'CHECK_LOCK_GET_PK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
          raise fnd_api.g_exc_unexpected_error;

END CHECK_LOCK_GET_PK;

---------------------------------------------------------------------------------------------------------
PROCEDURE GET_ROLE_ID
(p_role_name		  IN  VARCHAR2
,x_role_id                OUT NOCOPY NUMBER
,x_return_status          OUT NOCOPY VARCHAR2) is

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_role_name IS NOT NULL THEN
   	SELECT role_id
   	INTO x_role_id
   	FROM igw_roles_tl
   	WHERE upper(role_name) = upper(p_role_name)
   	and   language = userenv('LANG');
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('IGW', 'IGW_SS_ROLE_INVALID');
    fnd_msg_pub.add;

  WHEN too_many_rows THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('IGW', 'IGW_SS_ROLE_INVALID');
    fnd_msg_pub.add;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_USER_ROLES_PUB',
                            p_procedure_name => 'GET_ROLE_ID',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise fnd_api.g_exc_unexpected_error;
END GET_ROLE_ID;

------------------------------------------------------------------------------------
PROCEDURE CHECK_IF_SEEDED_ROLE
(p_role_id	          IN  VARCHAR2
,x_return_status          OUT NOCOPY VARCHAR2) is

N			NUMBER;

BEGIN
x_return_status:= FND_API.G_RET_STS_SUCCESS;

select count(*) into N
from igw_roles
where role_id = p_role_id AND
      seeded_flag = 'Y';

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
END CHECK_IF_SEEDED_ROLE;


-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS is
 l_msg_count 	NUMBER;
 BEGIN
       	l_msg_count := fnd_msg_pub.count_msg;
        IF (l_msg_count > 0) THEN
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

 END CHECK_ERRORS;


END IGW_PROP_USER_ROLES_PVT;

/

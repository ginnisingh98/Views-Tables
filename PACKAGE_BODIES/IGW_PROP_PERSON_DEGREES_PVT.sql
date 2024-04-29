--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_DEGREES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_DEGREES_PVT" as
 /* $Header: igwvppdb.pls 115.4 2002/11/15 00:41:41 ashkumar ship $*/


Procedure update_prop_person_degrees (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 P_PROPOSAL_ID               	  IN	 	NUMBER,
 P_PERSON_DEGREE_ID       	  IN		NUMBER,
 P_SHOW_FLAG 		     	  IN            VARCHAR2,
 P_DEGREE_SEQUENCE	     	  IN		NUMBER,
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
        SAVEPOINT update_prop_person_degrees;
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
                        igw_prop_person_degrees_tbh.update_row (
                                    	 x_rowid			 =>	x_rowid
              				,P_PROPOSAL_ID       		 =>	P_PROPOSAL_ID
 					,P_PERSON_DEGREE_ID         	 =>	P_PERSON_DEGREE_ID
 					,P_SHOW_FLAG      		 =>	P_SHOW_FLAG
 					,P_DEGREE_SEQUENCE     		 =>	P_DEGREE_SEQUENCE
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
              ROLLBACK TO update_prop_person_degrees;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_prop_person_degrees;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_PERSON_DEGREES_PVT',
                            p_procedure_name    =>    'UPDATE_PROP_PERSON_DEGREES',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_prop_person_degrees;

------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 l_proposal_id		number;
 BEGIN
   select proposal_id
   into l_proposal_id
   from igw_prop_person_degrees
   where rowid = x_rowid
   and record_version_number = p_record_version_number;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       --   FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
          FND_MESSAGE.SET_NAME('IGW','IGW_DIFFERENT_MESSAGE');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;

    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_PERSON_DEGREES_PVT',
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

-------------------------------------------------------------------------------------------------------------------
-- the following code transfers the degrees pertaining to the appropriate proposal and person from the
-- igw_person_degrees table to the igw_prop_person_degrees table and from igw_person_biosketch table to
-- the igw_prop_person_biosketch_table

PROCEDURE POPULATE_BIO_TABLES (p_init_msg_list     in    varchar2   := FND_API.G_FALSE,
 			       p_commit            in    varchar2   := FND_API.G_FALSE,
 			       p_validate_only     in    varchar2   := FND_API.G_FALSE,
			       p_proposal_id       in    number,
			       p_party_id          in    number,
			       x_return_status	   out NOCOPY   varchar2,
			       x_msg_count         out NOCOPY   number,
 			       x_msg_data          out NOCOPY   varchar2) is

degrees            igw_person_degrees%rowtype;
bio                igw_person_biosketch%rowtype;

cursor c is
    select person_degree_id,
           degree_sequence,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login
    from igw_person_degrees
    where (party_id = p_party_id) AND
          (person_degree_id not in
    (select person_degree_id from igw_prop_person_degrees
     where proposal_id = p_proposal_id));


cursor d is
    select person_biosketch_id,
           line_sequence,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login
    from igw_person_biosketch
    where (party_id = p_party_id) AND
          (enable_flag = 'Y') AND
          (person_biosketch_id not in
     (select person_biosketch_id from igw_prop_person_biosketch
      where proposal_id =  p_proposal_id));

BEGIN

-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT populate_bio_tables;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return status to success
   x_return_status := fnd_api.g_ret_sts_success;


-- delete those degrees in igw_prop_person_degrees which are not in igw_person_degrees
-- for the proposal under consideration
   delete from igw_prop_person_degrees
   where (proposal_id = p_proposal_id) AND
   person_degree_id not in
        (select person_degree_id from igw_person_degrees);

-- delete those biosketches in igw_prop_person_biosketch which are not in igw_person_biosketch
-- for the proposal under consideration

   delete from igw_prop_person_biosketch
   where (proposal_id = p_proposal_id) AND
   person_biosketch_id not in
        (select person_biosketch_id from igw_person_biosketch where enable_flag = 'Y');

-- insert those degrees not in igw_prop_person_degrees but in igw_person_degrees into
-- the table igw_prop_person_degrees for the proposal and person under consideration

    open c;
    fetch c into degrees.person_degree_id,
                 degrees.degree_sequence,
	  	 degrees.last_update_date,
                 degrees.last_updated_by,
                 degrees.creation_date,
                 degrees.created_by,
                 degrees.last_update_login;

    while c%found loop
          insert into igw_prop_person_degrees (
		 proposal_id,
                 person_degree_id,
                 degree_sequence,
                 show_flag,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 record_version_number)

          values (
		 p_proposal_id,
                 degrees.person_degree_id,
                 degrees.degree_sequence,
                 'Y',
	  	 degrees.last_update_date,
                 degrees.last_updated_by,
                 degrees.creation_date,
                 degrees.created_by,
                 degrees.last_update_login,
                 1);

    fetch c into degrees.person_degree_id,
                 degrees.degree_sequence,
	  	 degrees.last_update_date,
                 degrees.last_updated_by,
                 degrees.creation_date,
                 degrees.created_by,
                 degrees.last_update_login;

    end loop;
    close c;

-- insert those biosketches not in igw_prop_person_biosketch but in igw_person_biosketch into
-- the table igw_prop_person_biosketch for the proposal and person under consideration

    open d;
    fetch d into bio.person_biosketch_id,
                 bio.line_sequence,
	  	 bio.last_update_date,
                 bio.last_updated_by,
                 bio.creation_date,
                 bio.created_by,
                 bio.last_update_login;

    while d%found loop
          insert into igw_prop_person_biosketch (
		 proposal_id,
                 person_biosketch_id,
                 line_sequence,
                 show_flag,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 record_version_number)

          values (
		 p_proposal_id,
                 bio.person_biosketch_id,
                 bio.line_sequence,
                 'Y',
	  	 bio.last_update_date,
                 bio.last_updated_by,
                 bio.creation_date,
                 bio.created_by,
                 bio.last_update_login,
                 1);

    fetch d into bio.person_biosketch_id,
                 bio.line_sequence,
	  	 bio.last_update_date,
                 bio.last_updated_by,
                 bio.creation_date,
                 bio.created_by,
                 bio.last_update_login;

    end loop;
    close d;

 -- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;


-- standard call to get message count and if count is 1, get message info
fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			  p_data	=>	x_msg_data);


     EXCEPTION
    WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO populate_bio_tables;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name     => 'IGW_PROP_PERSON_DEGREES_PVT',
                            p_procedure_name 	 => 'POPULATE_BIO_TABLES',
                            p_error_text    	 => SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

END POPULATE_BIO_TABLES;


END IGW_PROP_PERSON_DEGREES_PVT;

/

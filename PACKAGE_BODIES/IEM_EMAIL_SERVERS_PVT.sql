--------------------------------------------------------
--  DDL for Package Body IEM_EMAIL_SERVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMAIL_SERVERS_PVT" as
/* $Header: iemvevrb.pls 115.16 2002/12/03 20:02:44 chtang shipped $ */
G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMAIL_SERVERS_PVT ';

PROCEDURE create_item_sss (p_api_version_number    IN   NUMBER,
 		     p_init_msg_list  IN   VARCHAR2,
		       p_commit	    IN   VARCHAR2,
			 p_server_name IN   VARCHAR2,
			 p_dns_name IN   VARCHAR2,
			 p_ip_address IN   VARCHAR2,
			 p_port IN   NUMBER,
			 p_server_type_id IN   NUMBER,
			 p_rt_availability IN   VARCHAR2,
			 p_server_group_id IN   NUMBER,
			p_CREATED_BY    NUMBER,
          	p_CREATION_DATE    DATE,
         	p_LAST_UPDATED_BY    NUMBER,
          	p_LAST_UPDATE_DATE    DATE,
          	p_LAST_UPDATE_LOGIN    NUMBER,
         	p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY    NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_sss';
	l_api_version_number 	NUMBER:=1.0;
	l_es_count		number:=0;
	l_seq_id		number;
	l_grp_cnt		number;
	l_type_cnt		number;
	l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

     IEM_DUP_EMAIL_SERVER    EXCEPTION;
     IEM_NON_EXISTENT_SERVER_GRP    EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		create_item_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --     select count(*) into l_es_count from iem_email_servers
   --     where UPPER(dns_name)=UPPER(p_dns_name)
   --     and ip_address=p_ip_address and port=p_port;

--	if l_es_count > 0 then
--		raise IEM_DUP_EMAIL_SERVER;
--	end if;

	SELECT iem_email_servers_s1.nextval
	INTO l_seq_id
	FROM dual;

	/* Check For Existing Server Type Id */

	Select count(*) into l_type_cnt from iem_email_server_types
	where email_server_type_id=p_server_type_id
	and rownum=1;
	IF l_type_cnt=0 THEN
		FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_TYPE');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

	/*Check For Existing Server Group Id */

	Select count(*) into l_grp_cnt from iem_server_groups
	where server_group_id=p_server_group_id
	and rownum=1;
	IF l_grp_cnt = 0 then
		--FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_GRP');
		--APP_EXCEPTION.RAISE_EXCEPTION;
        raise IEM_NON_EXISTENT_SERVER_GRP;
	END IF;
--		raise_application_error(-20002,'Server Group Id ||to_char(p_server_group_id)||' Does not Exist');

	INSERT INTO iem_email_servers
	(
	EMAIL_SERVER_ID,
	SERVER_NAME,
	DNS_NAME,
	IP_ADDRESS,
	PORT,
	SERVER_TYPE_ID ,
	RT_AVAILABILITY,
	SERVER_GROUP_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15 )
	VALUES
	(
	l_seq_id,
	p_server_name,
	p_dns_name,
	p_ip_address,
	p_port,
	p_server_type_id,
	p_rt_availability,
	p_server_group_id,
	decode(l_CREATED_BY,null,-1,l_CREATED_BY),
	sysdate,
     decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
     sysdate,
     decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN),
     decode(p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
     decode(p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
     decode(p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
     decode(p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
     decode(p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
     decode(p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
     decode(p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
     decode(p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
     decode(p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
     decode(p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
     decode(p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
     decode(p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
     decode(p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
     decode(p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
     decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
	);

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

  -- WHEN IEM_DUP_EMAIL_SERVER THEN
  --    ROLLBACK TO create_item_PVT;
  --      FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_DUP_EMAIL_SERVER');
  --      FND_MSG_PUB.Add;
  --      x_return_status := FND_API.G_RET_STS_ERROR ;
  --      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN IEM_NON_EXISTENT_SERVER_GRP THEN
      ROLLBACK TO create_item_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_GRP');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN DUP_VAL_ON_INDEX THEN
     ROLLBACK TO create_item_PVT;
	--  FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_GRP_DUP_RECORD');
	  FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_DUP_EMAIL_SERVER');
       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	create_item_sss;


PROCEDURE create_item_wrap_sss (p_api_version_number    IN   NUMBER,
 		            p_init_msg_list  IN   VARCHAR2,
		            p_commit	    IN   VARCHAR2,
			    p_server_name IN   VARCHAR2,
			 p_dns_name IN   VARCHAR2,
			 p_ip_address IN   VARCHAR2,
			 p_port IN   NUMBER,
			 p_server_type_id IN   NUMBER,
			 p_rt_availability IN   VARCHAR2,
			 p_server_group_id IN   NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY    NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_wrap_sss';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;
	l_type_cnt		number;
	l_stat		varchar2(20);
	l_count		number;
	l_email_server_id number;
	l_data		varchar2(300);
	l_email_server_type		varchar2(20);
	l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

     EXCP_EMAIL_SERVER    EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		create_item_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


     	IEM_EMAIL_SERVERS_PVT.create_item_sss(
               p_api_version_number =>1.0,
               p_init_msg_list  => FND_API.G_FALSE,
               p_commit=>FND_API.G_FALSE,
               p_server_name  => p_server_name,
               p_dns_name    => p_dns_name,
               p_ip_address  => p_ip_address,
               p_port  => p_port,
               p_server_type_id => p_server_type_id,
               p_rt_availability => p_rt_availability,
               p_server_group_id => p_server_group_id,
               p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
               	p_CREATION_DATE  =>SYSDATE,
               	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
         	p_LAST_UPDATE_DATE  =>SYSDATE,
          	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
         	p_ATTRIBUTE1   =>null,
          	p_ATTRIBUTE2   =>null,
          	p_ATTRIBUTE3   =>null,
          	p_ATTRIBUTE4   =>null,
          	p_ATTRIBUTE5   =>null,
          	p_ATTRIBUTE6   =>null,
          	p_ATTRIBUTE7   =>null,
          	p_ATTRIBUTE8   =>null,
          	p_ATTRIBUTE9   =>null,
          	p_ATTRIBUTE10  =>null,
          	p_ATTRIBUTE11  =>null,
          	p_ATTRIBUTE12  =>null,
          	p_ATTRIBUTE13  =>null,
          	p_ATTRIBUTE14  =>null,
          	p_ATTRIBUTE15  =>null,
	       x_return_status =>l_stat,
	       x_msg_count    => l_count,
	       x_msg_data      => l_data);

	IF l_stat <>'S' then
		raise EXCP_EMAIL_SERVER;
	END IF;

	-- Update Cache Audit Trail
	select email_server_type into l_email_server_type from iem_email_server_types where email_server_type_id=p_server_type_id;

	if (p_ip_address <> FND_API.G_MISS_CHAR) then
		select email_server_id into l_email_server_id from iem_email_servers
		where UPPER(dns_name)=UPPER(p_dns_name)
        	and ip_address=p_ip_address and port=p_port;
	else
		SELECT iem_email_servers_s1.currval
		INTO l_email_server_id
		FROM dual;

	end if;

	IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit         => FND_API.G_FALSE,
                        p_type => l_email_server_type,
                        p_param => 'CREATE',
                        p_value => l_email_server_id,
                        x_return_status  => l_stat,
                        x_msg_count      => l_count,
                        x_msg_data      => l_data
                        );
         -- Not raise error when failed to insert data into iem_comp_rt_stats, it is not user error.

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

   WHEN EXCP_EMAIL_SERVER THEN
          	ROLLBACK TO create_item_PVT;
           	x_return_status := FND_API.G_RET_STS_ERROR;
      --		FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_EMAIL_SVR_NOT_CREATED');
      --      	FND_MSG_PUB.Add;
   		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	create_item_wrap_sss;

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		     p_init_msg_list  IN   VARCHAR2,
		    	p_commit	    IN   VARCHAR2,
			p_email_server_id	IN NUMBER,
			p_dns_name IN   VARCHAR2,
			p_ip_address IN   VARCHAR2,
			p_port IN   NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_item';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		delete_item_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
if p_email_server_id =FND_API.G_MISS_NUM  then
	delete from iem_email_servers
	where ip_address=p_ip_address and dns_name=p_dns_name and port=p_port;
else
	delete from iem_email_servers
	where email_server_id=p_email_server_id;
end if;

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	delete_item;


 PROCEDURE update_item_sss (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2,
		    	      p_commit	    IN   VARCHAR2,
				 p_email_server_id IN	NUMBER,
				 p_server_name	 IN	varchar2,
				 p_dns_name IN   VARCHAR2,
				 p_ip_address IN   VARCHAR2,
				 p_port IN   NUMBER,
				 p_server_type_id IN 	number,
				 p_rt_availability	in varchar2,
				 p_server_group_id	in number,
         	p_LAST_UPDATED_BY    NUMBER,
          	p_LAST_UPDATE_DATE    DATE,
          	p_LAST_UPDATE_LOGIN    NUMBER,
         	p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	     x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_sss';
	l_api_version_number 	NUMBER:=1.0;
	l_es_count 	NUMBER:=0;
	l_type_cnt 	NUMBER;
	l_grp_cnt 	NUMBER;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
     IEM_DUP_EMAIL_SERVER EXCEPTION;
     IEM_NON_EXISTENT_SERVER_GRP EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_item_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  --	select email_server_id into l_es_count from iem_email_servers
  --      where UPPER(dns_name)=UPPER(p_dns_name)
  --      and ip_address=p_ip_address and port=p_port;

  --	if l_es_count <> p_email_server_id then
  --		raise IEM_DUP_EMAIL_SERVER;
  --	end if;

if p_server_type_id <>FND_API.G_MISS_NUM then
--	 Check For Existing Server Type Id

	Select count(*) into l_type_cnt from iem_email_server_types
	where email_server_type_id=p_server_type_id
	and rownum=1;
	IF l_type_cnt=0 THEN
		FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_TYPE');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
end if;

	/*Check For Existing Server Group Id */
if p_server_group_id <> FND_API.G_MISS_NUM then
	select count(*) into l_grp_cnt from iem_server_groups
	where server_group_id=p_server_group_id
	and rownum=1;
	IF l_grp_cnt = 0 then
        raise IEM_NON_EXISTENT_SERVER_GRP;
		--FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_GRP');
		--APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
end if;

 if p_email_server_id = FND_API.G_MISS_NUM then

	UPDATE IEM_EMAIL_SERVERS
	set server_name=decode(p_server_name,FND_API.G_MISS_CHAR, NULL, NULL, server_name,p_server_name),
	rt_availability=decode(p_rt_availability,FND_API.G_MISS_CHAR, NULL, NULL,rt_availability,p_rt_availability),
	server_type_id=decode(p_server_type_id,FND_API.G_MISS_NUM, NULL, NULL,server_type_id,p_server_type_id),
	server_group_id=decode(p_server_group_id,FND_API.G_MISS_NUM, NULL, NULL,server_group_id,p_server_group_id),
          LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,-1,l_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, p_ATTRIBUTE15)
	where dns_name=p_dns_name and ip_address=p_ip_address and port=p_port;
 ELSE

	UPDATE IEM_EMAIL_SERVERS
	SET server_name=decode(p_server_name,FND_API.G_MISS_CHAR, NULL, NULL,server_name,p_server_name),
	server_type_id=decode(p_server_type_id,FND_API.G_MISS_NUM, NULL, NULL,server_type_id,p_server_type_id),
	rt_availability=decode(p_rt_availability,FND_API.G_MISS_CHAR, NULL, NULL,rt_availability,p_rt_availability),
	server_group_id=decode(p_server_group_id,FND_API.G_MISS_NUM, NULL, NULL,server_group_id,p_server_group_id),
	dns_name=decode(p_dns_name,FND_API.G_MISS_CHAR, NULL, NULL,dns_name,p_dns_name),
	ip_address=decode(p_ip_address,FND_API.G_MISS_CHAR, NULL, NULL,ip_address,p_ip_address),
	port=decode(p_port,FND_API.G_MISS_NUM, NULL, NULL,port,p_port),
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY =  l_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = l_LAST_UPDATE_LOGIN,
      	      ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, p_ATTRIBUTE15)
	where EMAIL_SERVER_ID=p_email_server_id;
 end if;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION

 --  WHEN IEM_DUP_EMAIL_SERVER THEN
 --     ROLLBACK TO update_item_pvt;
 --       FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_DUP_EMAIL_SERVER');
 --       FND_MSG_PUB.Add;
 --       x_return_status := FND_API.G_RET_STS_ERROR ;
 --       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN IEM_NON_EXISTENT_SERVER_GRP THEN
      ROLLBACK TO update_item_pvt;
        FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_GRP');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN DUP_VAL_ON_INDEX THEN
   ROLLBACK TO update_item_pvt;
  -- FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_GRP_DUP_RECORD');
    FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_DUP_EMAIL_SERVER');
   FND_MSG_PUB.Add;
   x_return_status := FND_API.G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO update_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;


    IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN

         		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	update_item_sss;


 PROCEDURE update_item_wrap_sss (p_api_version_number    IN   NUMBER,
 		       p_init_msg_list  IN   VARCHAR2,
		       p_commit	    IN   VARCHAR2,
		       p_email_server_id IN	NUMBER,
			p_server_name	 IN	varchar2,
			p_dns_name IN   VARCHAR2,
			p_ip_address IN   VARCHAR2,
			p_port IN   NUMBER,
			p_server_type_id IN 	number,
			p_rt_availability	in varchar2,
			p_server_group_id	in number,
			x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	x_msg_data OUT NOCOPY VARCHAR2
			) is
	l_api_name        		VARCHAR2(255):='update_item_wrap_sss';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;
	l_type_cnt		number;
	l_stat		varchar2(20);
	l_count		number;
	l_data		varchar2(300);
	l_email_server_id number;
	l_email_server_type		varchar2(20);
	l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

     EXCP_EMAIL_SERVER    EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		create_item_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


     	IEM_EMAIL_SERVERS_PVT.update_item_sss(
               p_api_version_number =>1.0,
               p_init_msg_list  => FND_API.G_FALSE,
               p_commit=>FND_API.G_FALSE,
               p_email_server_id => p_email_server_id,
               p_server_name  => p_server_name,
               p_dns_name    => p_dns_name,
               p_ip_address  => p_ip_address,
               p_port  => p_port,
               p_server_type_id => p_server_type_id,
               p_rt_availability => p_rt_availability,
               p_server_group_id => p_server_group_id,
               	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
         	p_LAST_UPDATE_DATE  =>SYSDATE,
          	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
         	p_ATTRIBUTE1   =>null,
          	p_ATTRIBUTE2   =>null,
          	p_ATTRIBUTE3   =>null,
          	p_ATTRIBUTE4   =>null,
          	p_ATTRIBUTE5   =>null,
          	p_ATTRIBUTE6   =>null,
          	p_ATTRIBUTE7   =>null,
          	p_ATTRIBUTE8   =>null,
          	p_ATTRIBUTE9   =>null,
          	p_ATTRIBUTE10  =>null,
          	p_ATTRIBUTE11  =>null,
          	p_ATTRIBUTE12  =>null,
          	p_ATTRIBUTE13  =>null,
          	p_ATTRIBUTE14  =>null,
          	p_ATTRIBUTE15  =>null,
	       x_return_status =>l_stat,
	       x_msg_count    => l_count,
	       x_msg_data      => l_data);

	IF l_stat <>'S' then
		raise EXCP_EMAIL_SERVER;
	END IF;

	-- Update Cache Audit Trail
	select email_server_type into l_email_server_type from iem_email_server_types where email_server_type_id=p_server_type_id;

	if p_email_server_id = FND_API.G_MISS_NUM then
		select email_server_id into l_email_server_id from iem_email_servers
		where UPPER(dns_name)=UPPER(p_dns_name)
        	and ip_address=p_ip_address and port=p_port;
        else
        	l_email_server_id := p_email_server_id;
        end if;

	IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit         => FND_API.G_FALSE,
                        p_type => l_email_server_type,
                        p_param => 'UPDATE',
                        p_value => l_email_server_id,
                        x_return_status  => l_stat,
                        x_msg_count      => l_count,
                        x_msg_data      => l_data
                        );
         -- Not raise error when failed to insert data into iem_comp_rt_stats, it is not user error.

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

   WHEN EXCP_EMAIL_SERVER THEN
          	ROLLBACK TO create_item_PVT;
           	x_return_status := FND_API.G_RET_STS_ERROR;
      	--	FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_EMAIL_SVR_NOT_CREATED');
        --    	FND_MSG_PUB.Add;
   		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	update_item_wrap_sss;

PROCEDURE delete_item_batch
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2,
      p_commit          IN  VARCHAR2,
      p_group_tbl IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
 IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_item_batch';
    l_api_version_number number:=1.0;
    l_email_server_id	number;
    l_stat		varchar2(20);
    l_count		number;
    l_data		varchar2(300);
    l_server_type_id number;
    l_email_server_type		varchar2(20);

    SERVER_GROUP_NOT_DELETED     EXCEPTION;

BEGIN

--Standard Savepoint
    SAVEPOINT delete_item_batch;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

--Initialize API status return
x_return_status := FND_API.G_RET_STS_SUCCESS;

--Actual API starts here
    FOR i IN p_group_tbl.FIRST..p_group_tbl.LAST LOOP
    	l_email_server_id:=p_group_tbl(i);

	-- Update Cache Audit Trail
	select server_type_id into l_server_type_id from iem_email_servers WHERE EMAIL_SERVER_ID =l_email_server_id;

	select email_server_type into l_email_server_type from iem_email_server_types where email_server_type_id=l_server_type_id;

	IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit         => FND_API.G_FALSE,
                        p_type => l_email_server_type,
                        p_param => 'DELETE',
                        p_value => l_email_server_id,
                        x_return_status  => l_stat,
                        x_msg_count      => l_count,
                        x_msg_data      => l_data
                        );
         -- Not raise error when failed to insert data into iem_comp_rt_stats, it is not user error.

         	DELETE FROM IEM_EMAIL_SERVERS
		WHERE EMAIL_SERVER_ID =l_email_server_id;

 	END LOOP;

--Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
   WHEN SERVER_GROUP_NOT_DELETED THEN
        ROLLBACK TO delete_item_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_SERVER_GROUP_NOT_DELETED');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO delete_item_batch;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_item_batch;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
	  ROLLBACK TO delete_item_batch;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_item_batch;

END IEM_EMAIL_SERVERS_PVT ;

/

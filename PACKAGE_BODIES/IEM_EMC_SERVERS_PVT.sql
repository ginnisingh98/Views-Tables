--------------------------------------------------------
--  DDL for Package Body IEM_EMC_SERVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMC_SERVERS_PVT" as
/* $Header: iemvemcb.pls 115.8 2002/12/09 21:31:41 sboorela shipped $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMC_SERVERS_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  				 p_server_group_id IN   NUMBER,
  				 p_emc_server_name	IN   VARCHAR2,
  				 p_dns_name	IN   VARCHAR2,
  				 p_ip_address IN   VARCHAR2,
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
  		  	x_msg_count	      OUT NOCOPY NUMBER,
	  	  	x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;

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

	SELECT IEM_EMC_SERVERS_s1.nextval
	INTO l_seq_id
	FROM dual;

	/*Check For Existing Server Group Id */

	Select count(*) into l_grp_cnt from iem_server_groups
	where server_group_id=p_server_group_id
	and rownum=1;
	IF l_grp_cnt = 0 then
		FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_GRP');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

	INSERT INTO IEM_EMC_SERVERS
	(
	EMC_SERVER_ID,
	SERVER_GROUP_ID,
	EMC_SERVER_NAME,
	DNS_NAME,
	IP_ADDRESS,
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
	ATTRIBUTE15
	)
	VALUES
    (
    l_seq_id,
    p_server_group_id,
    p_emc_server_name,
    p_dns_name,
    p_ip_address,
	decode(p_CREATED_BY,null,-1,p_CREATED_BY),
	sysdate,
	decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
	sysdate,
	decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN),
	p_ATTRIBUTE1,
	p_ATTRIBUTE2,
	p_ATTRIBUTE3,
	p_ATTRIBUTE4,
	p_ATTRIBUTE5,
	p_ATTRIBUTE6,
	p_ATTRIBUTE7,
	p_ATTRIBUTE8,
	p_ATTRIBUTE9,
	p_ATTRIBUTE10,
	p_ATTRIBUTE11,
	p_ATTRIBUTE12,
	p_ATTRIBUTE13,
	p_ATTRIBUTE14,
	p_ATTRIBUTE15
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
   WHEN DUP_VAL_ON_INDEX THEN
	ROLLBACK TO create_item_pvt;
	  FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_GRP_DUP_RECORD');
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

 END	create_item;

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_emc_server_id	in number,
				 p_emc_server_name IN   VARCHAR2 ,
				 p_server_group_id IN   NUMBER,
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

if (p_emc_server_id is null or p_emc_server_id=FND_API.G_MISS_CHAR) then
	delete from IEM_EMC_SERVERS
	where emc_server_name=p_emc_server_name and server_group_id=p_server_group_id ;
else
	delete from IEM_EMC_SERVERS
	where emc_server_id=p_emc_server_id;
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

PROCEDURE update_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_emc_server_id IN NUMBER,
  				 p_server_group_id IN   NUMBER,
  				 p_emc_server_name	IN   VARCHAR2,
  				 p_dns_name	IN   VARCHAR2,
  				 p_ip_address IN   VARCHAR2,
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
	l_api_name        		VARCHAR2(255):='update_item';
	l_api_version_number 	NUMBER:=1.0;
	l_grp_cnt 	NUMBER;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

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

	if (p_server_group_id is not null OR p_server_group_id <> FND_API.G_MISS_NUM) then

		/*Check For Existing EMC Server Group */

		Select count(*) into l_grp_cnt from iem_server_groups
		where server_group_id=p_server_group_id
		and rownum=1;
		IF l_grp_cnt = 0 then
			FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_SERVER_GRP');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	end if;
if (p_emc_server_id = FND_API.G_MISS_NUM OR p_emc_server_id is null) then
	update IEM_EMC_SERVERS
	SET dns_name=decode(p_dns_name,FND_API.G_MISS_CHAR,null,null,dns_name,p_dns_name),
	ip_address=decode(p_ip_address,FND_API.G_MISS_CHAR,null,null,ip_address,p_ip_address),
          LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,last_updated_by,l_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,last_update_login,l_LAST_UPDATE_LOGIN),
            ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, null,null,ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE15, p_ATTRIBUTE15)
	where emc_server_name=p_emc_server_name and server_group_id=p_server_group_id ;
ELSE
	update IEM_EMC_SERVERS
	set server_group_id=decode(p_server_group_id,FND_API.G_MISS_NUM,null,null,server_group_id,p_server_group_id),
	emc_server_name=decode(p_emc_server_name,FND_API.G_MISS_CHAR,null,null,emc_server_name,p_emc_server_name),
	dns_name=decode(p_dns_name,FND_API.G_MISS_CHAR,null,null,dns_name,p_dns_name),
	ip_address=decode(p_ip_address,FND_API.G_MISS_CHAR,null,null,ip_address,p_ip_address),
          LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,last_updated_by,l_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,last_update_login,l_LAST_UPDATE_LOGIN),
            ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, null,null,ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE15, p_ATTRIBUTE15)
	where emc_server_id=p_emc_server_id;
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
   WHEN DUP_VAL_ON_INDEX THEN
   ROLLBACK TO update_item_pvt;
   FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_GRP_DUP_RECORD');
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

 END	update_item;

PROCEDURE delete_item_batch
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_group_tbl IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
 IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_item_batch';
    l_api_version_number number:=1.0;

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
    FORALL i IN p_group_tbl.FIRST..p_group_tbl.LAST
        DELETE
        FROM IEM_EMC_SERVERS
        WHERE EMC_SERVER_ID = p_group_tbl(i);

    if SQL%NOTFOUND then
        raise SERVER_GROUP_NOT_DELETED;
    end if;


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
END IEM_EMC_SERVERS_PVT ;

/

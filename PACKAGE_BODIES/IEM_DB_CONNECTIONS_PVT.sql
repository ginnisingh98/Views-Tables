--------------------------------------------------------
--  DDL for Package Body IEM_DB_CONNECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DB_CONNECTIONS_PVT" as
/* $Header: iemvdbcb.pls 115.4 2002/12/03 20:11:32 chtang ship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_DB_CONNECTIONS_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				 p_db_link IN   VARCHAR2,
  				 p_db_username	IN   VARCHAR2,
  				 p_db_password	IN   VARCHAR2,
  				 p_db_server_id IN   NUMBER,
  				 p_is_admin IN   VARCHAR2,
  				 p_conn_desc IN   VARCHAR2:=null,
				p_CREATED_BY    NUMBER:=null,
          	p_CREATION_DATE    DATE:=null,
         	p_LAST_UPDATED_BY    NUMBER:=null ,
          	p_LAST_UPDATE_DATE    DATE:=null,
          	p_LAST_UPDATE_LOGIN    NUMBER:=null,
         	p_ATTRIBUTE1    VARCHAR2:=null,
          	p_ATTRIBUTE2    VARCHAR2:=null,
          	p_ATTRIBUTE3    VARCHAR2:=null,
          	p_ATTRIBUTE4    VARCHAR2:=null,
          	p_ATTRIBUTE5    VARCHAR2:=null,
          	p_ATTRIBUTE6    VARCHAR2:=null,
          	p_ATTRIBUTE7    VARCHAR2:=null,
          	p_ATTRIBUTE8    VARCHAR2:=null,
          	p_ATTRIBUTE9    VARCHAR2:=null,
          	p_ATTRIBUTE10    VARCHAR2:=null,
          	p_ATTRIBUTE11    VARCHAR2:=null,
          	p_ATTRIBUTE12    VARCHAR2:=null,
          	p_ATTRIBUTE13    VARCHAR2:=null,
          	p_ATTRIBUTE14    VARCHAR2:=null,
          	p_ATTRIBUTE15    VARCHAR2:=null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;
	l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

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

	SELECT IEM_DB_CONNECTIONS_s1.nextval
	INTO l_seq_id
	FROM dual;

	/*Check For Existing Server Group Id */
if p_db_server_id <> FND_API.G_MISS_NUM THEN
	Select count(*) into l_grp_cnt from iem_db_servers
	where db_server_id=p_db_server_id
	and rownum=1;
	IF l_grp_cnt = 0 then
		FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_DB_SRV_GRP');
 			FND_MSG_PUB.ADD;
          	x_return_status := FND_API.G_RET_STS_ERROR ;
          	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data =>x_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
end if;

	INSERT INTO IEM_DB_CONNECTIONS
	(
	DB_CONNECTION_ID,
	DB_LINK,
	DB_USERNAME,
	DB_PASSWORD,
	DB_SERVER_ID,
	IS_ADMIN,
	CONNECTION_DESC,
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
	p_db_link,
	p_db_username,
	p_db_password,
	p_db_server_id,
	p_is_admin,
	decode(p_conn_desc,FND_API.G_MISS_CHAR,NULL,p_conn_desc),
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
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_db_conn_id	in number:=null,
				 p_db_username IN   VARCHAR2 :=null,
				 p_db_server_id IN   NUMBER:=null,
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
if p_db_conn_id = FND_API.G_MISS_NUM then
	delete from IEM_DB_CONNECTIONS
	where db_username=p_db_username and db_server_id=p_db_server_id ;
else
	delete from IEM_DB_CONNECTIONS
	where db_connection_id=p_db_conn_id;
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
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_db_conn_id IN NUMBER:=null,
  				 p_db_link IN   VARCHAR2:=null,
  				 p_db_username	IN   VARCHAR2:=null,
  				 p_db_password	IN   VARCHAR2:=null,
  				 p_db_server_id IN   NUMBER:=null,
  				 p_is_admin IN   VARCHAR2:=null,
  				 p_conn_desc IN   VARCHAR2:=null,
				 p_CREATED_BY    NUMBER:=null,
          	p_CREATION_DATE    DATE:=null,
         	p_LAST_UPDATED_BY    NUMBER:=null ,
          	p_LAST_UPDATE_DATE    DATE:=null,
          	p_LAST_UPDATE_LOGIN    NUMBER:=null,
         	p_ATTRIBUTE1    VARCHAR2:=null,
          	p_ATTRIBUTE2    VARCHAR2:=null,
          	p_ATTRIBUTE3    VARCHAR2:=null,
          	p_ATTRIBUTE4    VARCHAR2:=null,
          	p_ATTRIBUTE5    VARCHAR2:=null,
          	p_ATTRIBUTE6    VARCHAR2:=null,
          	p_ATTRIBUTE7    VARCHAR2:=null,
          	p_ATTRIBUTE8    VARCHAR2:=null,
          	p_ATTRIBUTE9    VARCHAR2:=null,
          	p_ATTRIBUTE10    VARCHAR2:=null,
          	p_ATTRIBUTE11    VARCHAR2:=null,
          	p_ATTRIBUTE12    VARCHAR2:=null,
          	p_ATTRIBUTE13    VARCHAR2:=null,
          	p_ATTRIBUTE14    VARCHAR2:=null,
          	p_ATTRIBUTE15    VARCHAR2:=null,
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

	if p_db_server_id is not null then

		/*Check For Existing DB Server Id */

		Select count(*) into l_grp_cnt from iem_db_servers
		where db_server_id=p_db_Server_id
		and rownum=1;
		IF l_grp_cnt = 0 then
			FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_DB_SRV_GRP');
 			FND_MSG_PUB.ADD;
          	x_return_status := FND_API.G_RET_STS_ERROR ;
          	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data =>x_msg_data);
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	end if;
if p_db_conn_id is null then
	update IEM_DB_CONNECTIONS
	set db_link=decode(p_db_link,FND_API.G_MISS_CHAR, NULL, NULL, db_link,p_db_link),
	is_admin=decode(p_is_admin,FND_API.G_MISS_CHAR, NULL, NULL,is_admin,is_admin),
	connection_desc=decode(p_conn_desc,FND_API.G_MISS_CHAR, NULL, NULL,connection_desc,p_conn_desc),
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,-1,l_LAST_UPDATED_BY),
          LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,l_LAST_UPDATE_LOGIN),
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
	where db_username=p_db_username and db_server_id=p_db_server_id;

else
	update IEM_DB_CONNECTIONS
	set db_username=decode(p_db_username,FND_API.G_MISS_CHAR, NULL, NULL,db_username,p_db_username),
	db_password=decode(p_db_password,FND_API.G_MISS_CHAR, NULL, NULL,db_password,p_db_password),
	db_link=decode(p_db_link,FND_API.G_MISS_CHAR, NULL, NULL,db_link,p_db_link),
	is_admin=decode(p_is_admin,FND_API.G_MISS_CHAR, NULL, NULL,is_admin,p_is_admin),
	connection_desc=decode(p_conn_desc,FND_API.G_MISS_CHAR, NULL, NULL,connection_desc,p_conn_desc),
	db_server_id=decode(p_db_server_id,FND_API.G_MISS_CHAR, NULL, NULL,db_server_id,p_db_server_id),
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,-1,l_LAST_UPDATED_BY),
          LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,l_LAST_UPDATE_LOGIN),
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
	where db_connection_id=p_db_conn_id;
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

PROCEDURE select_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_db_server_id	in number:=null,
				 p_is_admin IN   VARCHAR2 :=null,
				 x_db_link OUT NOCOPY   VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='select_item';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		select_item_PVT;
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
BEGIN
	SELECT DB_LINK into x_db_link
	FROM IEM_DB_CONNECTIONS
	where db_server_id=p_db_server_id
	and	is_admin=p_is_admin;
EXCEPTION WHEN NO_DATA_FOUND THEN
		FND_MESSAGE.SET_NAME('IEM','IEM_NON_EXISTENT_DBLINK_NAME');
 		FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data =>x_msg_data);
WHEN TOO_MANY_ROWS THEN
		FND_MESSAGE.SET_NAME('IEM','IEM_MORE_THAN_ONE_DBLINK');
 		FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data =>x_msg_data);
END;
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
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_item_PVT;
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
	END select_item;

END IEM_DB_CONNECTIONS_PVT ;

/

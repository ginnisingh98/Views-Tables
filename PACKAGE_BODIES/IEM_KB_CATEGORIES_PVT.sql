--------------------------------------------------------
--  DDL for Package Body IEM_KB_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_KB_CATEGORIES_PVT" as
/* $Header: iemvkbcb.pls 115.3 2002/12/02 23:52:40 sboorela shipped $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_KB_CATEGORIES_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_kb_category_id	NUMBER,
  				 p_kb_parent_category_id IN   NUMBER,
				 p_display_name		IN VARCHAR2,
  				 p_category_code IN   VARCHAR2,
  				 p_is_repos IN   VARCHAR2,
  				 p_category_order IN   NUMBER,
  				 p_category_desc IN   varchar2,
			p_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
          	p_CREATION_DATE    DATE:=SYSDATE,
         		p_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ,
          	p_LAST_UPDATE_DATE    DATE:=SYSDATE,
          	p_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ,
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

	SELECT IEM_KB_CATEGORIES_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_KB_CATEGORIES
	(
	KB_CATEGORY_ID,
	KB_PARENT_CATEGORY_ID,
	DISPLAY_NAME  ,
	CATEGORY_CODE ,
	IS_REPOSITORY ,
	CATEGORY_ORDER,
	CATEGORY_DESC ,
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
	(l_seq_id,
	p_kb_parent_category_id,
	p_display_name,
	p_category_code,
	p_is_repos,
	p_category_order,
	decode(p_category_desc,FND_API.G_MISS_CHAR,NULL,p_category_desc),
	decode(l_CREATED_BY,null,-1,l_CREATED_BY),
	sysdate,
     decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
     sysdate,
     decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN),
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
				 p_kb_category_id	in NUMBER,
				 p_kb_parent_category_id IN   NUMBER,
				 p_display_name IN   VARCHAR2 ,
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

IF p_kb_category_id =FND_API.G_MISS_NUM THEN
	DELETE FROM IEM_KB_CATEGORIES
	WHERE display_name=p_display_name AND
	kb_parent_category_id=p_kb_parent_category_id;
else
	DELETE FROM IEM_KB_CATEGORIES
	where kb_category_id=p_kb_category_id;
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
				 p_kb_category_id IN	NUMBER,
				 p_kb_parent_category_id	 IN	number,
				 p_display_name	 IN	varchar2,
				 p_category_code IN 	varchar2,
				 p_is_repos IN   VARCHAR2,
				 p_category_order IN 	number,
				 p_category_desc varchar2,
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

	update IEM_KB_CATEGORIES
	set kb_parent_category_id=decode(p_kb_parent_category_id,FND_API.G_MISS_NUM,kb_parent_category_id,p_kb_parent_category_id),
	display_name=decode(p_display_name,FND_API.G_MISS_CHAR,display_name,p_display_name),
	category_code=decode(p_category_code,FND_API.G_MISS_CHAR,category_code,p_category_code),
	is_repository=decode(p_is_repos,FND_API.G_MISS_CHAR,is_repository,p_is_repos),
	category_order=decode(p_category_order,FND_API.G_MISS_NUM,category_order,p_category_order),
	category_desc=decode(p_category_desc,FND_API.G_MISS_CHAR,category_desc,p_category_desc),
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,-1,l_LAST_UPDATED_BY),
          LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,l_LAST_UPDATE_LOGIN),
     ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
     ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
     ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
     ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
     ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
     ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
     ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
     ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
     ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
     ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
     ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
     ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
     ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
     ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
     ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
	where kb_category_id=p_kb_category_id;

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
END IEM_KB_CATEGORIES_PVT ;

/

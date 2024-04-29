--------------------------------------------------------
--  DDL for Package Body IEM_CLASSIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CLASSIFICATIONS_PVT" as
/* $Header: iemvclab.pls 115.16 2003/08/26 23:42:12 sboorela shipped $*/

/* Fixed Bug 1339176 rtripath on 11/27/00 Do the cascading delete    */
/*  08/14/01	     chtang   added create_item_wrap_sss() for 11.5.6 */
/*  06/05/02 	     chtang   fixed 2403484
/*  11/20/02 	     chtang   removed SQL%NOTFOUND in delete_item_wrap_sss
/*****************************************************************/
 G_PKG_NAME CONSTANT varchar2(30) :='IEM_CLASSIFICATIONS_PVT';

-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_account_name IN   VARCHAR2,
--  p_email_user	IN   VARCHAR2,
--  p_domain	IN   VARCHAR2,
--  p_email_password	IN   VARCHAR2,
--  p_account_profile	IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--  p_db_server_id IN   NUMBER,
--  p_server_group_id IN   NUMBER,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************


PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  				 p_email_account_id IN   NUMBER,
  				 p_classification	IN   VARCHAR2,
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
			     )is


	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq				number;
	l_cnt				number;


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

-- Take this out. Handle duplicates in exception handling.
	SELECT count(*) into l_cnt from iem_classifications WHERE EMAIL_ACCOUNT_ID=p_email_account_id AND
		CLASSIFICATION=p_classification AND rownum=1;

	IF l_cnt=0 THEN
	select iem_classifications_s1.nextval into l_seq from dual;
		INSERT INTO IEM_CLASSIFICATIONS
		(
		CLASSIFICATION_ID,
		EMAIL_ACCOUNT_ID ,
		CLASSIFICATION ,
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
		(l_seq,
		p_email_account_id,
		p_classification,
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
	p_ATTRIBUTE15);
	ELSE
   		x_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

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
	ROLLBACK TO update_item_PVT;
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

end;


-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id	in number:=FND_API.G_MISS_NUM,
--  p_account_name IN   VARCHAR2 :=FND_API.G_MISS_CHAR,

--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			 p_email_account_id	in number,
			 p_classification IN   VARCHAR2 ,
			 p_classification_id  in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 )is
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
IF p_classification_id IS NOT NULL THEN
	DELETE FROM IEM_THEMES
	WHERE CLASSIFICATION_ID=p_classification_id;
	DELETE FROM IEM_CLASSIFICATIONS
	WHERE CLASSIFICATION_ID=p_classification_id;
ELSE
	DELETE FROM IEM_CLASSIFICATIONS
	WHERE EMAIL_ACCOUNT_ID=P_EMAIL_ACCOUNT_ID
	AND CLASSIFICATION=P_CLASSIFICATION;
END IF;

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

 END;

-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure update a record in the table IEM_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_classification_id IN NUMBER:=FND_API.G_MISS_NUM,
--  p_email_account_id IN NUMBER:=FND_API.G_MISS_NUM,
--  p_classification IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE update_item (p_api_version_number    IN   NUMBER,
 		     p_init_msg_list  IN   VARCHAR2 ,
		       p_commit	    IN   VARCHAR2 ,
			 p_classification_id IN NUMBER,
			 p_email_account_id IN NUMBER,
  			 p_classification IN   VARCHAR2,
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
			 )is

	l_api_name        		VARCHAR2(255):='update_item';
	l_api_version_number 	NUMBER:=1.0;

     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

     IEM_DUPLICATE_CLASS EXCEPTION;
	PRAGMA EXCEPTION_INIT(IEM_DUPLICATE_CLASS, -00001);

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
	UPDATE IEM_CLASSIFICATIONS
	SET CLASSIFICATION=decode(p_classification,FND_API.G_MISS_CHAR,null,null,CLASSIFICATION,p_CLASSIFICATION),
      LAST_UPDATE_DATE = l_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN =decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN),
	 EMAIL_ACCOUNT_ID =decode(p_email_account_id,FND_API.G_MISS_NUM,EMAIL_ACCOUNT_ID,p_email_account_id),
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
	WHERE CLASSIFICATION_ID=p_classification_id;

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
   WHEN IEM_DUPLICATE_CLASS THEN
	ROLLBACK TO update_item_PVT;
	FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_CLASSIFICATION');
	x_return_status := FND_API.G_RET_STS_ERROR;
     IF   FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
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
 END;

/**************WRPR******************/

PROCEDURE create_item_wrap (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
  		      p_email_account_id IN   NUMBER,
  		      p_classification	IN   VARCHAR2,
             p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
                  )is
	l_api_name     VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_cnt		number;
     l_CREATED_BY NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
     l_creation_date date := SYSDATE;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
	l_classification VARCHAR2(100);
	l_classification2 VARCHAR2(100);
	IEM_DUP_CLASS       EXCEPTION;

BEGIN
  SAVEPOINT	create_item_jsp;
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
  THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Take this out when create_item procedure handles duplicates in the exception block.
  SELECT count(*) into l_cnt from iem_classifications WHERE EMAIL_ACCOUNT_ID=p_email_account_id AND
   CLASSIFICATION=p_classification AND rownum=1;

  IF (l_cnt > 0 ) then
  	raise IEM_DUP_CLASS;
--     FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_CLASSIFICATION');
--	APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

     select replace (replace ( replace (p_classification, '<', ''), '>', ''), '"', '''') into l_classification
	  from dual;

/*
     select replace (replace ( replace (p_classification, '<', '&lt;'), '>', '&gt;'), '"', '''')
	  from dual;
*/

   l_classification2 := rtrim(ltrim(l_classification, ' '), ' ');


   IEM_CLASSIFICATIONS_PVT.create_item(
                             p_api_version_number =>p_api_version_number,
                             p_init_msg_list => p_init_msg_list,
                             p_commit => p_commit,
                             p_email_account_id =>p_email_account_id,
                             p_classification => l_classification,
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
                             x_return_status =>x_return_status,
                             x_msg_count   => x_msg_count,
                             x_msg_data => x_msg_data);

     IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
     END IF;

     FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_DUP_CLASS THEN
      	    ROLLBACK TO create_item_jsp;
            FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_CLASSIFICATION');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_jsp;
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

end;


PROCEDURE create_item_wrap_sss (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
  		      p_email_account_id IN   NUMBER,
  		      p_classification	IN   VARCHAR2,
             p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
                  )is
	l_api_name     VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_cnt		number;
     l_CREATED_BY NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
     l_creation_date date := SYSDATE;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
	l_classification VARCHAR2(100);
	l_classification2 VARCHAR2(100);
	IEM_DUP_CLASS       EXCEPTION;

BEGIN
  SAVEPOINT	create_item_jsp;
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
  THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Take this out when create_item procedure handles duplicates in the exception block.
  SELECT count(*) into l_cnt from iem_classifications WHERE EMAIL_ACCOUNT_ID=p_email_account_id AND
   CLASSIFICATION=p_classification AND rownum=1;

  IF (l_cnt > 0 ) then
  	raise IEM_DUP_CLASS;
--     FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_CLASSIFICATION');
--	APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

     select replace (replace ( replace (p_classification, '<', ''), '>', ''), '"', '''') into l_classification
	  from dual;

/*
     select replace (replace ( replace (p_classification, '<', '&lt;'), '>', '&gt;'), '"', '''')
	  from dual;
*/

   l_classification2 := rtrim(ltrim(l_classification, ' '), ' ');


   IEM_CLASSIFICATIONS_PVT.create_item(
                             p_api_version_number =>p_api_version_number,
                             p_init_msg_list => p_init_msg_list,
                             p_commit => p_commit,
                             p_email_account_id =>p_email_account_id,
                             p_classification => l_classification,
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
                             x_return_status =>x_return_status,
                             x_msg_count   => x_msg_count,
                             x_msg_data => x_msg_data);

     IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
     END IF;

     FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_DUP_CLASS THEN
      	    ROLLBACK TO create_item_jsp;
            FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_INTENT');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_jsp;
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

end;

PROCEDURE delete_item_wrap
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_clas_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
 IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_item_batch';
    l_api_version_number number:=1.0;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_wrap;
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
    FOR i IN p_clas_ids_tbl.FIRST..p_clas_ids_tbl.LAST
    LOOP
        DELETE
        FROM IEM_THEMES
        WHERE classification_id = p_clas_ids_tbl(i);
        DELETE
        FROM IEM_CLASSIFICATIONS
        WHERE classification_id = p_clas_ids_tbl(i);
	END LOOP;

    IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('IEM', 'IEM_EXP_INVALID_ACCOUNT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_wrap;
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
    --Standard call to get message count and message info
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data => x_msg_data);
END delete_item_wrap;
PROCEDURE delete_item_wrap_sss
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_clas_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
 IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_item_batch_sss';
    l_api_version_number number:=1.0;
    l_status		varchar2(10);
    l_class_id		number;
    l_email_account_id  number;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_wrap;
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
  FOR j in p_clas_ids_tbl.FIRST..p_clas_ids_tbl.LAST LOOP
	l_class_id:=p_clas_ids_tbl(j);
	EXIT;
  END LOOP;
    select email_account_id into l_email_account_id
    from iem_classifications
    where classification_id=l_class_id;
    FOR i IN p_clas_ids_tbl.FIRST..p_clas_ids_tbl.LAST
    LOOP
        DELETE
        FROM IEM_THEMES
        WHERE classification_id = p_clas_ids_tbl(i);
        DELETE
        FROM IEM_CLASSIFICATIONS
        WHERE classification_id = p_clas_ids_tbl(i);
	END LOOP;
	delete from iem_account_intent_docs
	where classification_id not in
		(select classification_id from iem_classifications);
	delete from iem_theme_docs
	where account_intent_doc_id not in
		(select account_intent_doc_id from iem_account_intent_docs);
		iem_themes_pvt.calculate_weight (l_email_account_id,
		      'Q'  ,
		  	l_status	);
		iem_themes_pvt.calculate_weight (l_email_account_id,
		      'R'  ,
		  	l_status	);

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_wrap;
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
    --Standard call to get message count and message info
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data => x_msg_data);
END delete_item_wrap_sss;

PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 		      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
			 p_classification_id IN NUMBER,
			 p_email_account_id IN NUMBER,
  			 p_classification IN   VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	 x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 )is
	l_api_name        		VARCHAR2(255):='update_item';
	l_api_version_number 	NUMBER:=1.0;
     l_CREATED_BY NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
     l_creation_date date := SYSDATE;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
	l_classification VARCHAR2(100);
	l_classification2 VARCHAR2(100);
	l_cnt NUMBER := 0;

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

     select replace (replace ( replace (p_classification, '<', ''), '>', ''), '"', '''') into l_classification
		  from dual;

 l_classification2 := rtrim(ltrim(l_classification, ' '), ' ');

-- Take this out when create_item procedure handles duplicates in the exception block.
  SELECT count(*) into l_cnt from iem_classifications WHERE EMAIL_ACCOUNT_ID=p_email_account_id AND
   CLASSIFICATION=l_classification2 AND rownum=1;

  IF (l_cnt > 0 ) then
     FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_CLASSIFICATION');
     APP_EXCEPTION.RAISE_EXCEPTION;
  end if;


 IEM_CLASSIFICATIONS_PVT.update_item(
                           p_api_version_number =>p_api_version_number,
                           p_init_msg_list => p_init_msg_list,
                           p_commit => p_commit,
                           p_classification_id =>p_classification_id,
                           p_email_account_id =>p_email_account_id,
                           p_classification => l_classification,
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
                           x_return_status =>x_return_status,
                           x_msg_count   => x_msg_count,
                           x_msg_data => x_msg_data);


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
 END;
PROCEDURE update_item_wrap_sss (p_api_version_number    IN   NUMBER,
 		      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
			 p_classification_id IN NUMBER,
			 p_email_account_id IN NUMBER,
  			 p_classification IN   VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	 x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 )is
	l_api_name        		VARCHAR2(255):='update_item';
	l_api_version_number 	NUMBER:=1.0;
     l_CREATED_BY NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
     l_creation_date date := SYSDATE;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
	l_classification VARCHAR2(100);
	l_classification2 VARCHAR2(100);
	l_status		varchar2(10);
	l_cnt NUMBER := 0;
	l_email_account_id		number;
	t_email_account_id		number;
	l_classification_id		number;
	DUPLICATE_INTENT		EXCEPTION;

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

     select replace (replace ( replace (p_classification, '<', ''), '>', ''), '"', '''') into l_classification
		  from dual;

 l_classification2 := rtrim(ltrim(l_classification, ' '), ' ');

-- Take this out when create_item procedure handles duplicates in the exception block.
  SELECT count(*) into l_cnt from iem_classifications WHERE EMAIL_ACCOUNT_ID=p_email_account_id AND
   upper(CLASSIFICATION)=upper(l_classification2) AND rownum=1;

  IF (l_cnt > 0 ) then
     raise DUPLICATE_INTENT;
  end if;
	select email_account_id into l_email_account_id
	from iem_classifications
	where classification_id=p_classification_id;

 IEM_CLASSIFICATIONS_PVT.update_item(
                           p_api_version_number =>p_api_version_number,
                           p_init_msg_list => p_init_msg_list,
                           p_commit => p_commit,
                           p_classification_id =>p_classification_id,
                           p_email_account_id =>p_email_account_id,
                           p_classification => l_classification,
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
                           x_return_status =>x_return_status,
                           x_msg_count   => x_msg_count,
                           x_msg_data => x_msg_data);
	IF l_email_account_id <>p_email_account_id THEN

	-- In this case need to recalculate the score for both email accounts.

		update iem_account_intent_docs
		set email_account_id=p_email_account_id
		where classification_id=p_classification_id;
		t_email_account_id:=l_email_account_id;
			iem_themes_pvt.calculate_weight (t_email_account_id	,
									    'Q'  ,
									  	l_status	);
			iem_themes_pvt.calculate_weight (t_email_account_id	,
									    'R'  ,
									  	l_status	);
		t_email_account_id:=p_email_account_id;
			iem_themes_pvt.calculate_weight (p_email_account_id	,
										'Q',
									  	l_status	);
			iem_themes_pvt.calculate_weight (p_email_account_id	,
										'R',
									  	l_status	);
	END IF;

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
   WHEN DUPLICATE_INTENT THEN
   	FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_INTENT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

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
 END;
-- This API is called by the postman process while creating classifications
--  This is incorporated in 11.5.6 New Flow Arch.

PROCEDURE create_item_pm (p_api_version_number    IN   NUMBER,
  				 p_email_account_id IN   NUMBER,
  				 p_classification	IN   VARCHAR2,
				 p_query_response	IN   VARCHAR2,
				 x_doc_seq_num	 OUT NOCOPY NUMBER,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
               p_LAST_UPDATED_BY    NUMBER ,
               p_LAST_UPDATE_DATE    DATE,
               p_LAST_UPDATE_LOGIN    NUMBER,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2) IS
	l_cnt		number;
	l_seq		number;
	l_class_id		number;
	l_classification_id		number;
	l_doc_count			number;
	l_doc_seq_no			number;
	l_status			varchar2(10);
	DOC_EXCEP          EXCEPTION;
	CLASS_EXCEP          EXCEPTION;
 BEGIN
	x_return_status:='S';
 BEGIN
 SELECT classification_id into l_class_id
 from iem_classifications
 WHERE EMAIL_ACCOUNT_ID=p_email_account_id
 AND upper(CLASSIFICATION)=upper(p_classification) ;
	IEM_INTENT_DOCS_PVT.create_item(
			p_classification_id=>l_class_id,
			p_email_account_id =>p_email_account_id,
			p_query_response  =>p_query_response,
			x_doc_seq_no	=>l_doc_seq_no,
		      x_return_status=>l_status);
	IF l_status='E' THEN
		raise DOC_EXCEP;
	END IF;
	EXCEPTION WHEN NO_DATA_FOUND THEN
	select iem_classifications_s1.nextval into l_seq from dual;
		INSERT INTO IEM_CLASSIFICATIONS
		(
		CLASSIFICATION_ID,
		EMAIL_ACCOUNT_ID ,
		CLASSIFICATION ,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN)
		VALUES
		(l_seq,
		p_email_account_id,
		p_classification,
     	p_CREATED_BY,
		p_creation_date,
     	p_LAST_UPDATED_BY,
     	p_LAST_UPDATE_DATE,
     	p_LAST_UPDATE_LOGIN);
	IF l_status='E' THEN
		raise CLASS_EXCEP;
	END IF;
	IEM_INTENT_DOCS_PVT.create_item(
			p_classification_id=>l_seq,
			p_email_account_id =>p_email_account_id,
			p_query_response  =>p_query_response,
			x_doc_seq_no	=>l_doc_seq_no,
		      x_return_status=>l_status);
	IF l_status='E' THEN
		raise DOC_EXCEP;
	END IF;
 	END;
		x_doc_seq_num:=l_doc_seq_no;
	EXCEPTION WHEN DOC_EXCEP THEN
		x_return_Status:='E';
	WHEN CLASS_EXCEP THEN
		x_return_Status:='E';
	WHEN OTHERS THEN
		x_return_Status:='E';

	END;

END IEM_CLASSIFICATIONS_PVT;

/

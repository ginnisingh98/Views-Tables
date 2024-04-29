--------------------------------------------------------
--  DDL for Package Body IEM_EML_CLASSIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EML_CLASSIFICATIONS_PVT" as
/* $Header: iemveclb.pls 120.0 2005/06/02 14:04:19 appldev noship $*/

 G_PKG_NAME CONSTANT varchar2(30) :='IEM_EML_CLASSIFICATIONS_PVT ';
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER,
--  p_classification_id	IN   NUMBER,
--  p_score IN NUMBER,
--  p_message_id  IN NUMBER,
--  p_class_string  IN varchar2,
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
  				 p_classification_id	IN   NUMBER,
		           p_score IN NUMBER,
		           p_message_id  IN NUMBER,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
         p_LAST_UPDATED_BY    NUMBER,
         p_LAST_UPDATE_DATE    DATE,
     p_LAST_UPDATE_LOGIN    NUMBER ,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2)
		    IS
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_count 	NUMBER;

BEGIN
-- Standard Start of API savepoint
-- SAVEPOINT		create_item_PVT;
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
   select count(*) into l_count from iem_email_classifications
   where message_id=p_message_id
   and classification_id=p_classification_id;
   IF l_count=0 then
	INSERT INTO IEM_EMAIL_CLASSIFICATIONS
	(
	MESSAGE_ID,
	EMAIL_ACCOUNT_ID ,
	CLASSIFICATION_ID ,
	SCORE   ,
	CREATED_BY  ,
	CREATION_DATE ,
	LAST_UPDATED_BY ,
	LAST_UPDATE_DATE ,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	p_message_id,
	p_email_account_id,
	p_classification_id,
	p_score,
    	DECODE(p_created_by,null,-1,p_created_by),
	sysdate,
    	DECODE(p_LAST_UPDATED_BY,null,-1,p_last_updated_by),
    	sysdate,
    	DECODE(p_LAST_UPDATE_LOGIN,null,-1,p_last_update_login)
	);
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
--	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
--	ROLLBACK TO update_item_PVT;
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
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id	in number:=FND_API.G_MISS_NUM,
--  p_classification_id	IN   NUMBER:=FND_API.G_MISS_NUM,

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
			 p_email_account_id IN   NUMBER,
  			 p_classification_id	IN   NUMBER,
		      p_message_id  IN NUMBER,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_item';
	l_api_version_number 	NUMBER:=1.0;
	l_grp_cnt 	NUMBER;

BEGIN
-- Standard Start of API savepoint
--SAVEPOINT		delete_item_PVT;
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
	DELETE FROM IEM_EMAIL_CLASSIFICATIONS
	where message_id=p_message_id
	and   classification_id=p_classification_id
	and email_account_id=p_email_account_id;
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
--	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	--ROLLBACK TO delete_item_PVT;
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

PROCEDURE getClassification (p_api_version_number    IN   NUMBER,
                     p_init_msg_list  IN   VARCHAR2 ,
                     p_commit     IN   VARCHAR2 ,
                     p_email_account_id IN   NUMBER,
                     p_message_id IN   NUMBER,
                     x_Email_Classn_tbl  OUT NOCOPY EMCLASS_tbl_type,
		  		x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
                 ) is
	l_api_name        		VARCHAR2(255):='getClassification';
	l_api_version_number 	NUMBER:=1.0;
	l_cnt 	NUMBER:=1;

 CURSOR class_scr IS
 SELECT    a.classification_id,b.intent,a.score
 FROM      IEM_EMAIL_CLASSIFICATIONS a,IEM_INTENTS b
 WHERE     a.classification_id=b.intent_id
 AND       a.message_id = p_message_id
 AND       a.email_account_id = p_email_account_id;

BEGIN
-- Standard Start of API savepoint
--SAVEPOINT		getClassification_pvt;
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


      FOR class_rec in class_scr
	 LOOP
        x_Email_Classn_tbl(l_cnt).CLASSIFICATION_ID := class_rec.CLASSIFICATION_ID;
	   x_Email_Classn_tbl(l_cnt).CLASSIFICATION    := class_rec.intent;
	   x_Email_Classn_tbl(l_cnt).SCORE             := class_rec.SCORE;

	   l_cnt:=l_cnt+1;

      END LOOP;

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
	--ROLLBACK TO getclassification_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--ROLLBACK TO getclassification_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	--ROLLBACK TO getclassification_pvt;
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

PROCEDURE getClassification (p_api_version_number    IN   NUMBER,
                     p_init_msg_list  IN   VARCHAR2 ,
                     p_commit     IN   VARCHAR2 ,
                     p_email_account_id IN   NUMBER,
                     p_message_id IN   NUMBER,
				 x_category_id OUT NOCOPY NUMBER,
                     x_Email_Classn_tbl  OUT NOCOPY EMCLASS_tbl_type,
		  		x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
                 )  IS

	l_api_name        		VARCHAR2(255):='getClassification';
	l_api_version_number 	NUMBER:=1.0;
	l_cnt 	NUMBER:=1;
	l_category_map_id		number;

 CURSOR class_scr IS
 SELECT    a.classification_id,b.intent,a.score
 FROM      IEM_EMAIL_CLASSIFICATIONS a,IEM_INTENTS b
 WHERE     a.classification_id=b.intent_id
 AND       a.message_id = p_message_id
 AND       a.email_account_id = p_email_account_id;

BEGIN
-- Standard Start of API savepoint
--SAVEPOINT		getClassification_pvt;
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
	select category_map_id into l_category_map_id
	FROM IEM_RT_PROC_EMAILS
	WHERE MESSAGE_ID=p_message_id;
	x_category_id:=l_category_map_id;
  EXCEPTION WHEN OTHERS THEN
	null;
  END;
  IF l_category_map_id is null THEN
      FOR class_rec in class_scr
	 LOOP

        x_Email_Classn_tbl(l_cnt).CLASSIFICATION_ID := class_rec.CLASSIFICATION_ID;
	   x_Email_Classn_tbl(l_cnt).CLASSIFICATION    := class_rec.INTENT;
	   x_Email_Classn_tbl(l_cnt).SCORE             := class_rec.SCORE;

	   l_cnt:=l_cnt+1;

      END LOOP;
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
	--ROLLBACK TO getclassification_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--ROLLBACK TO getclassification_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	--ROLLBACK TO getclassification_pvt;
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
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER,
--  p_classification_id	IN   NUMBER,
--  p_score IN NUMBER,
--  p_message_id  IN NUMBER,
--  p_class_string  IN varchar2,
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
  				 p_classification_id	IN   NUMBER,
		           p_score IN NUMBER,
		           p_message_id  IN NUMBER,
		           p_class_string  IN varchar2,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
         p_LAST_UPDATED_BY    NUMBER ,
         p_LAST_UPDATE_DATE    DATE,
     p_LAST_UPDATE_LOGIN    NUMBER ,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_count 	NUMBER;

BEGIN
-- Standard Start of API savepoint
-- SAVEPOINT		create_item_PVT;
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
   select count(*) into l_count from iem_email_classifications
   where message_id=p_message_id
   and classification_id=p_classification_id;
   If l_count=0 then
	INSERT INTO IEM_EMAIL_CLASSIFICATIONS
	(
	MESSAGE_ID,
	EMAIL_ACCOUNT_ID ,
	CLASSIFICATION_ID ,
	SCORE   ,
	CLASSIFICATION_STRING,
	CREATED_BY  ,
	CREATION_DATE ,
	LAST_UPDATED_BY ,
	LAST_UPDATE_DATE ,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	p_message_id,
	p_email_account_id,
	p_classification_id,
	p_score,
	p_class_string,
    	DECODE(p_created_by,null,-1,p_created_by),
	sysdate,
    	DECODE(p_LAST_UPDATED_BY,null,-1,p_last_updated_by),
    	sysdate,
    	DECODE(p_LAST_UPDATE_LOGIN,null,-1,p_last_update_login)
	);
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
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
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
END IEM_EML_CLASSIFICATIONS_PVT;

/

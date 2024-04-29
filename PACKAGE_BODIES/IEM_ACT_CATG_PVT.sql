--------------------------------------------------------
--  DDL for Package Body IEM_ACT_CATG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ACT_CATG_PVT" as
/* $Header: iemvacab.pls 115.1 2002/12/05 20:09:34 sboorela shipped $*/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_ACT_CATG_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_email_account_id	IN   NUMBER,
			p_cat_tbl   IN  jtf_varchar2_Table_100,
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
	l_cat_id		number;
	l_acct_cat_seq	number;

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	delete from iem_account_categories
	where email_account_id=p_email_account_id;
IF p_cat_tbl.count>0 THEN
FOR i in p_cat_tbl.FIRST..p_cat_tbl.LAST LOOP
l_cat_id:=to_number(p_cat_tbl(i));
select IEM_ACCOUNT_CATEGORIES_S1.nextval into
l_acct_cat_seq
from dual;
INSERT INTO IEM_ACCOUNT_CATEGORIES (
ACCOUNT_CATEGORY_ID,
EMAIL_ACCOUNT_ID           ,
CATEGORY_ID    ,
CREATED_BY          ,
CREATION_DATE       ,
LAST_UPDATED_BY     ,
LAST_UPDATE_DATE    ,
LAST_UPDATE_LOGIN   ,
ATTRIBUTE1          ,
ATTRIBUTE2          ,
ATTRIBUTE3          ,
ATTRIBUTE4          ,
ATTRIBUTE5          ,
ATTRIBUTE6          ,
ATTRIBUTE7        ,
ATTRIBUTE8        ,
ATTRIBUTE9        ,
ATTRIBUTE10       ,
ATTRIBUTE11       ,
ATTRIBUTE12       ,
ATTRIBUTE13       ,
ATTRIBUTE14       ,
ATTRIBUTE15
)
VALUES
(
l_acct_cat_seq,
p_email_account_id,
l_cat_id,
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

 END	create_item;

PROCEDURE select_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			 p_email_account_id	in number,
			 x_category_tbl OUT NOCOPY jtf_varchar2_TABLE_100,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='select_item';
	l_api_version_number 	NUMBER:=1.0;
 cursor c1 is select category_id from iem_account_categories
 where email_account_id=p_email_account_id;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
	SAVEPOINT select_item_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	open c1;
	fetch c1 bulk collect into x_category_tbl;
	close c1;

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
	ROLLBACK TO select_item_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_item_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_item_pvt;
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

 END	select_item;
PROCEDURE create_item_wrap (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_email_account_id	IN   NUMBER,
			p_cat_tbl   IN  jtf_varchar2_Table_100,
		      x_return_status OUT NOCOPY VARCHAR2,
  		 	 x_msg_count	      OUT NOCOPY NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 ) IS
    l_api_name              VARCHAR2(255):='create_item_wrap';
    l_api_version_number    NUMBER:=1.0;
    l_return_status         VARCHAR2(20);
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    CREATE_ITEM_EXCP	EXCEPTION;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT  create_item_wrap_PVT;

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
	IEM_ACT_CATG_PVT.create_item (p_api_version_number=>1.0,
 						p_init_msg_list=>'F' ,
						p_commit=>'F'	    ,
						p_email_account_id=>p_email_account_id,
						p_cat_tbl=>p_cat_tbl ,
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
		      			x_return_status=>l_return_status,
  		 	 			x_msg_count=>l_msg_count,
	  	  	 			x_msg_data=>l_msg_data);
   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
			raise CREATE_ITEM_EXCP;
			x_return_status:=FND_API.G_RET_STS_SUCCESS;
  end if;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
EXCEPTION
        WHEN CREATE_ITEM_EXCP THEN
            ROLLBACK TO CREATE_ITEM_WRAP_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO CREATE_ITEM_WRAP_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO CREATE_ITEM_WRAP_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
            ROLLBACK TO CREATE_ITEM_WRAP_PVT;
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
END create_item_wrap;
END IEM_ACT_CATG_PVT ;

/

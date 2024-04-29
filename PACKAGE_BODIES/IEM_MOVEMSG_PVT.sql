--------------------------------------------------------
--  DDL for Package Body IEM_MOVEMSG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MOVEMSG_PVT" as
/* $Header: iemvmsgb.pls 115.3 2002/12/04 00:01:55 chtang noship $*/
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_MOVEMSG_PVT
-- Purpose          : APIs that are used to move messages to agent folders.
--                  : sboorela 08/13/2001 Created moveMessage() API
--		    : chtang   07/08/2002 Created moveOesMessage() API
--		    : chtang   12/03/2002 Fixed gscc error
-- NOTE             :
-- End of Comments
-- *****************************************************
G_PKG_NAME CONSTANT varchar2(30) :='IEM_MOVEMSG_PVT ';

-- Start of Comments
--  API name 	: moveMessage
--  Type	: 	Private
--  Function	: This procedure move message to agent folder
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_msgid IN   NUMBER,
--  p_email_account_id	IN   NUMBER,
--  p_tofolder	IN   VARCHAR2,
--  p_reverse	IN   VARCHAR2,
--	OUT
--   x_status	OUT	NUMBER
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE moveMessage (p_api_version_number    IN   NUMBER,
 		  	        p_init_msg_list  IN   VARCHAR2,
		    	        p_commit	    IN   VARCHAR2,
  				  p_msgid	IN   NUMBER,
  				  p_email_account_id	IN   NUMBER,
  				  p_tofolder	IN  VARCHAR2,
  				  p_reverse	IN  VARCHAR2,
		  x_status OUT NOCOPY NUMBER,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='moveMessage';
	l_api_version_number 	NUMBER:=1.0;
	l_pass VARCHAR2(30);
	l_user VARCHAR2(30);
	l_domain VARCHAR2(30);
	l_db_server_id NUMBER;
	l_str VARCHAR2(200);
	l_ret NUMBER;
	l_data  varchar2(255);
	l_stat	varchar2(10);
  l_count	number;
  l_im_link varchar2(200);
  l_im_link1 varchar2(200);
  l_folder varchar2(50);
  l_frfolder varchar2(50);
  l_tofolder varchar2(50);

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		moveMessage_PVT;
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

   	SELECT	DB_SERVER_ID,EMAIL_USER,DOMAIN,EMAIL_PASSWORD
  				INTO 	l_db_server_id,l_user,l_domain,l_pass
  				FROM IEM_EMAIL_ACCOUNTS
   				WHERE EMAIL_ACCOUNT_ID=p_email_account_id;

  	IEM_DB_CONNECTIONS_PVT.select_item(
               	p_api_version_number =>1.0,
                 	p_db_server_id  =>l_db_server_id,
               	p_is_admin =>'P',
  				x_db_link=>l_im_link1,
  				x_return_status =>l_stat,
  				x_msg_count    => l_count,
  				x_msg_data      => l_data);

		If l_im_link1 is null then
  	   l_im_link:=null;
		else
   		 l_im_link:='@'||l_im_link1;
		end if;
  	l_str:='begin :l_ret:=im_api.authenticate'||l_im_link||'(:a_user,:a_domain,:a_password);end; ';
    EXECUTE IMMEDIATE l_str using OUT l_ret,l_user,l_domain,l_pass;
   	IF l_ret=0 THEN
  	  x_return_status := FND_API.G_RET_STS_SUCCESS;
     ELSE
   		x_return_status := FND_API.G_RET_STS_ERROR;
   	END IF;

   	-- Now we are ready to call im movetoFolder
IF (p_reverse='N') THEN
   	l_frfolder :='/Inbox';
   	l_tofolder :='/'||p_tofolder;
ELSIF (p_reverse='Y') THEN
   	l_tofolder :='/Inbox';
   	l_frfolder :='/'||p_tofolder;
END IF;
   	l_str:='begin :l_ret:=im_api.movetofolder'||l_im_link||'(:a_msgid,:a_frfolder,:a_tofolder);end; ';

    EXECUTE IMMEDIATE l_str using OUT l_ret,p_msgid,l_frfolder,l_tofolder;
   IF l_ret=0 THEN
  	  x_return_status := FND_API.G_RET_STS_SUCCESS;
  	  x_status := 0;
   ELSIF l_ret=2 THEN
  	  x_return_status := FND_API.G_RET_STS_SUCCESS;
   	  x_status := 2;
   ELSIF l_ret=3 THEN
  	  x_return_status := FND_API.G_RET_STS_SUCCESS;
   	  x_status := 3;
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
	ROLLBACK TO moveMessage_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO moveMessage_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO moveMessage_PVT;
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

 PROCEDURE moveOesMessage (p_api_version_number    IN   NUMBER,
 		  	         p_init_msg_list  IN   VARCHAR2,
		    	         p_commit	    IN   VARCHAR2,
  				 p_msgid	IN   NUMBER,
  			       	 p_email_account_id	IN   NUMBER,
  				 p_tofolder	IN  VARCHAR2,
  				 p_fromfolder	IN  VARCHAR2,
		  		x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='moveOesMessage';
	l_api_version_number 	NUMBER:=1.0;
	l_pass VARCHAR2(30);
	l_user VARCHAR2(30);
	l_domain VARCHAR2(30);
	l_db_server_id NUMBER;
	l_str VARCHAR2(200);
	l_ret NUMBER;
	l_data  varchar2(255);
	l_stat	varchar2(10);
  l_count	number;
  l_im_link varchar2(200);
  l_im_link1 varchar2(200);
  l_frfolder varchar2(50);
  l_tofolder varchar2(50);

  MOVE_MSG_FAIL	EXCEPTION;

  OES_DOWN		EXCEPTION;
  PRAGMA  EXCEPTION_INIT(OES_DOWN , -04052);


BEGIN
-- Standard Start of API savepoint
SAVEPOINT		moveMessage_PVT;
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

   	SELECT	DB_SERVER_ID,EMAIL_USER,DOMAIN,EMAIL_PASSWORD
  				INTO 	l_db_server_id,l_user,l_domain,l_pass
  				FROM IEM_EMAIL_ACCOUNTS
   				WHERE EMAIL_ACCOUNT_ID=p_email_account_id;

  	IEM_DB_CONNECTIONS_PVT.select_item(
               	p_api_version_number =>1.0,
                 	p_db_server_id  =>l_db_server_id,
               	p_is_admin =>'P',
  				x_db_link=>l_im_link1,
  				x_return_status =>l_stat,
  				x_msg_count    => l_count,
  				x_msg_data      => l_data);

		If l_im_link1 is null then
  	   l_im_link:=null;
		else
   		 l_im_link:='@'||l_im_link1;
		end if;
  	l_str:='begin :l_ret:=im_api.authenticate'||l_im_link||'(:a_user,:a_domain,:a_password);end; ';
    EXECUTE IMMEDIATE l_str using OUT l_ret,l_user,l_domain,l_pass;
   	IF l_ret=0 THEN
  	  x_return_status := FND_API.G_RET_STS_SUCCESS;
     ELSE
   		x_return_status := FND_API.G_RET_STS_ERROR;
   	END IF;

   	-- Now we are ready to call im movetoFolder

   	l_frfolder :='/'||p_fromfolder;
   	l_tofolder :='/'||p_tofolder;

   	l_str:='begin :l_ret:=im_api.movetofolder'||l_im_link||'(:a_msgid,:a_frfolder,:a_tofolder);end; ';

    EXECUTE IMMEDIATE l_str using OUT l_ret,p_msgid,l_frfolder,l_tofolder;
   IF l_ret<>0 THEN
  	  raise MOVE_MSG_FAIL;
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
  WHEN MOVE_MSG_FAIL THEN
        ROLLBACK TO moveMessage_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_MOVE_DEL_MESSAGE_FAIL');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OES_DOWN THEN
        ROLLBACK TO moveMessage_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_OES_DOWN');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO moveMessage_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO moveMessage_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO moveMessage_PVT;
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



END IEM_MOVEMSG_PVT;

/

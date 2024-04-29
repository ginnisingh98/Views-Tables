--------------------------------------------------------
--  DDL for Package Body IEM_DP_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DP_LOG_PVT" AS
/* $Header: iemvlogb.pls 120.4 2006/03/10 15:18:46 chtang noship $ */

--
--
-- Purpose: Mantain Encrypted Tags
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   02/25/2005    Created
--  Liang Xia   09/01/2005    Expanded Error_Message to 2000
--  Mina Tang   03/10/2006    Fixed bug 5090395
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_DP_LOG_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID') ) ;
g_encrypted_id         NUMBER := 0;

PROCEDURE CREATE_DP_LOG (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 P_error_code		   IN   VARCHAR2 := null,
				 P_MSG				   IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number   := null,
                 p_subject         	   IN   VARCHAR2 := null,
                 p_RFC_msg_ID		   IN   VARCHAR2 := null,
				 p_received_date       IN   DATE := null,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='CREATE_DP_LOG';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_seq_id		        NUMBER := 10000;

	l_log_id				NUMBER :=0;
	l_error_msg             VARCHAR2(2000);
	l_error_code			VARCHAR2(30);
	l_RFC_msg_ID			VARCHAR2(256);
	l_subject				VARCHAR2(2000);

    logMessage              varchar2(2000);
    IEM_AGENT_INTERACTION_ID_NULL    EXCEPTION;


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

   --begins here

   --fixme after expand error_message column to 2000.
   if length(P_MSG) >2000 then
   	   	l_error_msg := substr(P_MSG,1,2000);
   else
   		l_error_msg := P_MSG;
   end if;

   BEGIN

   if ( P_error_code is null ) then
   	  l_error_code := 'NULL';
   else
      l_error_code := P_error_code;
   end if;

   if  length(p_subject)>2000  then
   	  l_subject := substr(P_SUBJECT,1,2000);
   else
      l_subject := P_SUBJECT;
   end if;

   if ( p_RFC_msg_ID is null ) then
   	  l_RFC_msg_ID := 'NULL';
   else
      l_RFC_msg_ID := substr(p_RFC_msg_ID,1,256);
   end if;

   select count(DP_LOG_ID) into l_log_id
   		  from iem_DP_LOGS
   		  where EMAIL_ACCOUNT_ID = P_acct_id
   		  and NVL(ERROR_CODE, l_error_code) = l_error_code
		  and NVL(RFC822_MESSAGE_ID,l_RFC_msg_ID)=l_RFC_msg_ID
   		  and NVL(ERROR_MESSAGE, l_error_msg)=l_error_msg;

   EXCEPTION
   when NO_DATA_FOUND then
   		null;
   end ;

   if l_log_id <> 0 then
   	  update IEM_DP_LOGS set LAST_UPDATE_DATE=sysdate
   	  	  where EMAIL_ACCOUNT_ID = P_acct_id
   		  and NVL(ERROR_CODE, l_error_code) = l_error_code
		  and NVL(RFC822_MESSAGE_ID,l_RFC_msg_ID)=l_RFC_msg_ID
   		  and NVL(ERROR_MESSAGE, l_error_msg)=l_error_msg;
   else

    --get next sequential number
   	SELECT IEM_DP_LOGS_S1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_DP_LOGS
	(
	DP_LOG_ID,
	EMAIL_ACCOUNT_ID,
	ERROR_CODE,
	ERROR_MESSAGE,
	MSG_SUBJECT,
	MSG_RECEIVED_DATE,
	RFC822_MESSAGE_ID,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	P_ACCT_ID,
	P_error_code,
	l_error_msg,
    l_subject,
	p_received_date,
    l_RFC_msg_ID,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

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
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
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
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);
 END;


END IEM_DP_LOG_PVT;

/

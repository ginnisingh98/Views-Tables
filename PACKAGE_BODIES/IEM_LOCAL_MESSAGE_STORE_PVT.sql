--------------------------------------------------------
--  DDL for Package Body IEM_LOCAL_MESSAGE_STORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_LOCAL_MESSAGE_STORE_PVT" AS
/* $Header: iemvsamb.pls 120.0 2005/06/02 13:55:48 appldev noship $ */

--
--
-- Purpose:
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- Mina Tang	05/24/2004  Created
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_LOCAL_MESSAGE_STORE_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

PROCEDURE save_message (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
		 p_inbound_message_id	IN	NUMBER,
		 p_email_account_id       IN   NUMBER,
		 p_mailproc_status	IN	VARCHAR2,
		 p_rt_classification_id	IN	NUMBER,
		 p_mail_type			NUMBER,
		 p_from_str		IN	VARCHAR2,
		 p_reply_to_str		IN	VARCHAR2,
		 p_to_str		IN	VARCHAR2,
		 p_cc_str		IN	VARCHAR2,
		 p_bcc_str		IN	VARCHAR2,
		 p_sent_date		IN	VARCHAR2,
		 p_received_date	IN	DATE,
		 p_subject             IN   VARCHAR2,
		 p_agent_id		IN	NUMBER,
		 p_group_id		IN	NUMBER,
		 p_ih_media_item_id	IN	NUMBER,
		 p_customer_id		IN	NUMBER,
		 p_message_size		IN	NUMBER,
		 p_contact_id		IN	NUMBER,
		 p_relationship_id	IN	NUMBER,
		 p_top_intent		IN	VARCHAR2,
		 p_message_text		IN	VARCHAR2,
		 p_action		IN	VARCHAR2,
		 x_message_id		OUT 	NOCOPY NUMBER,
                 x_return_status	OUT     NOCOPY VARCHAR2,
  		 x_msg_count	        OUT	NOCOPY NUMBER,
	  	 x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='save_message';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    i				INTEGER;
    insert_arch_dtl_error	EXCEPTION;
    resolved_message_error	EXCEPTION;
    l_message_id		NUMBER;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		save_message_PVT;

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

	-- Insert Record into IEM_ARCH_MSG_DTLS
	IEM_ARCH_MSGDTLS_PVT.create_item(
		P_API_VERSION_NUMBER=>p_api_version_number,
 		P_INIT_MSG_LIST=>p_init_msg_list,
 		P_COMMIT=>p_commit,
		p_MESSAGE_ID =>FND_API.G_MISS_NUM,
 		P_INBOUND_MESSAGE_ID=>p_inbound_message_id,
 		P_EMAIL_ACCOUNT_ID=>p_email_account_id,
 		P_MAILPROC_STATUS=>p_mailproc_status,
 		P_RT_CLASSIFICATION_ID=>p_rt_classification_id,
 		P_MAIL_TYPE=>p_mail_type,
 		P_FROM_STR=>p_from_str,
 		P_REPLY_TO_STR=>p_reply_to_str,
 		P_TO_STR=>p_to_str,
		P_CC_STR=>p_cc_str,
		P_BCC_STR=>p_bcc_str,
 		P_SENT_DATE=>p_sent_date,
 		P_RECEIVED_DATE=>p_received_date,
 		P_SUBJECT=>p_subject,
 		P_AGENT_ID=>p_agent_id,
 		P_GROUP_ID=>p_group_id,
 		P_IH_MEDIA_ITEM_ID=>p_ih_media_item_id,
 		P_CUSTOMER_ID=>p_customer_id,
 		P_MESSAGE_SIZE=>p_message_size,
 		P_CONTACT_ID=>p_contact_id,
 		P_RELATIONSHIP_ID=>p_relationship_id,
 		P_TOP_INTENT=>p_top_intent,
 		P_MESSAGE_TEXT=>p_message_text,
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
		x_message_id=>l_message_id,
 		X_RETURN_STATUS=>l_return_status,
 		X_MSG_COUNT=>l_msg_count,
		 X_MSG_DATA=>l_msg_data);

	IF l_return_status<>'S' THEN
		raise insert_arch_dtl_error;
	END IF;

	if (p_action = 'R') then -- resolved message, NOT pure compose message

		iem_mailitem_pub.ResolvedMessage (p_api_version_number => p_api_version_number,
 		  	      p_init_msg_list  => p_init_msg_list,
		    	      p_commit => p_commit,
	                      p_message_id => p_inbound_message_id,
			      p_action_flag => 'R',
			      x_return_status => l_return_status,
  		  	      x_msg_count => l_msg_count,
	  	  	      x_msg_data => l_msg_data);

		IF l_return_status<>'S' THEN
			raise resolved_message_error;
		END IF;

	end if;

	x_message_id := l_message_id;


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
	ROLLBACK TO save_message_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO save_message_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO save_message_PVT;
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

 END save_message;


 PROCEDURE delete_message (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
		 p_message_id		IN	NUMBER,
	         p_action_flag		IN	VARCHAR2,
                 x_return_status	OUT     NOCOPY VARCHAR2,
  		 x_msg_count	        OUT	NOCOPY NUMBER,
	  	 x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_message';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    delete_message_error	EXCEPTION;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		save_message_PVT;

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

		iem_mailitem_pub.ResolvedMessage (p_api_version_number => p_api_version_number,
 		  	      p_init_msg_list  => p_init_msg_list,
		    	      p_commit => p_commit,
	                      p_message_id => p_message_id,
			      p_action_flag => 'D',
			      x_return_status => l_return_status,
  		  	      x_msg_count => l_msg_count,
	  	  	      x_msg_data => l_msg_data);

		IF l_return_status<>'S' THEN
			raise delete_message_error;
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
	ROLLBACK TO delete_message_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_message_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO delete_message_PVT;
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

 END delete_message;


END IEM_LOCAL_MESSAGE_STORE_PVT;

/

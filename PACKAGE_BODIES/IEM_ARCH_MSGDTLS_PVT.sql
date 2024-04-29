--------------------------------------------------------
--  DDL for Package Body IEM_ARCH_MSGDTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ARCH_MSGDTLS_PVT" AS
/* $Header: iemvarmb.pls 120.0 2005/06/02 14:00:47 appldev noship $ */


-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_MSG_ARCHDTLS_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

PROCEDURE create_item (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
		 p_message_id		IN	NUMBER,
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
		 p_ATTRIBUTE1    	IN VARCHAR2,
          	 p_ATTRIBUTE2    	IN VARCHAR2,
          	 p_ATTRIBUTE3    	IN VARCHAR2,
          	 p_ATTRIBUTE4    	IN VARCHAR2,
          	 p_ATTRIBUTE5    	IN VARCHAR2,
          	 p_ATTRIBUTE6    	IN VARCHAR2,
          	 p_ATTRIBUTE7    	IN VARCHAR2,
          	 p_ATTRIBUTE8    	IN VARCHAR2,
          	 p_ATTRIBUTE9    	IN VARCHAR2,
          	 p_ATTRIBUTE10    	IN VARCHAR2,
          	 p_ATTRIBUTE11    	IN VARCHAR2,
          	 p_ATTRIBUTE12    	IN VARCHAR2,
          	 p_ATTRIBUTE13    	IN VARCHAR2,
          	 p_ATTRIBUTE14    	IN VARCHAR2,
          	 p_ATTRIBUTE15    	IN VARCHAR2,
		 x_message_id		OUT 	NOCOPY NUMBER,
                 x_return_status	OUT     NOCOPY VARCHAR2,
  		 x_msg_count	        OUT	NOCOPY NUMBER,
	  	 x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_arch_msgdtls';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    i				INTEGER;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_arch_msgdtls_PVT;

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

    --get next sequential number for msg_meta_id

    if (p_message_id = FND_API.G_MISS_NUM) then  -- MAIL_TYPE = outbound
   	SELECT IEM_MS_BASE_HEADERS_S1.nextval
	INTO l_seq_id
	FROM dual;
    else
	l_seq_id := p_message_id;
    end if;

	INSERT INTO IEM_ARCH_MSGDTLS
	(
	MESSAGE_ID,
	INBOUND_MESSAGE_ID,
	EMAIL_ACCOUNT_ID,
	MAILPROC_STATUS,
	RT_CLASSIFICATION_ID,
	MAIL_TYPE,
	FROM_STR,
	REPLY_TO_STR,
	TO_STR,
	CC_STR,
	BCC_STR,
	SENT_DATE,
	RECEIVED_DATE,
	SUBJECT,
	resource_id,
	GROUP_ID,
	IH_MEDIA_ITEM_ID,
	CUSTOMER_ID,
	MESSAGE_SIZE,
	CONTACT_ID,
	RELATIONSHIP_ID,
	TOP_INTENT,
	MESSAGE_TEXT,
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
	ATTRIBUTE15,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	decode(p_inbound_message_id, FND_API.G_MISS_NUM, null, p_inbound_message_id),
	p_email_account_id,
	p_mailproc_status,
	decode(p_rt_classification_id, FND_API.G_MISS_NUM, null, p_rt_classification_id),
	p_mail_type,
	p_from_str,
	decode(p_reply_to_str, FND_API.G_MISS_CHAR, null, p_reply_to_str),
	p_to_str,
	decode(p_cc_str, FND_API.G_MISS_CHAR, null, p_cc_str),
	decode(p_bcc_str, FND_API.G_MISS_CHAR, null, p_bcc_str),
	p_sent_date,
	decode(p_received_date, FND_API.G_MISS_DATE, null, p_received_date),
	decode(p_subject, FND_API.G_MISS_CHAR, null, p_subject),
	decode(p_agent_id, FND_API.G_MISS_NUM, null, p_agent_id),
	decode(p_group_id, FND_API.G_MISS_NUM, null, p_group_id),
	decode(p_ih_media_item_id, FND_API.G_MISS_NUM, null, p_ih_media_item_id),
	decode(p_customer_id, FND_API.G_MISS_NUM, null, p_customer_id),
	p_message_size,
	decode(p_contact_id, FND_API.G_MISS_NUM, null, p_contact_id),
	decode(p_relationship_id, FND_API.G_MISS_NUM, null, p_relationship_id),
	decode(p_top_intent, FND_API.G_MISS_CHAR, null, p_top_intent),
	decode(p_message_text, FND_API.G_MISS_CHAR, null, p_message_text),
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
     decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);


    x_message_id := l_seq_id;

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
	ROLLBACK TO create_arch_msgdtls_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_arch_msgdtls_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_arch_msgdtls_PVT;
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

 END create_item;




END IEM_ARCH_MSGDTLS_PVT;

/
